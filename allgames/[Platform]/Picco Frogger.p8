pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- frogger 0.9
-- 2020 paul hammond

-- debug
version="0.9"
debug_stats=false
noversion=false

-- cartridge data
cartdata("phammond_frg_1p8")

-- constants
fps=60

-- movement
d_none=0
d_up=1
d_down=3
d_left=4
d_right=2

xinc={} xinc[0]=0 xinc[1]=0 xinc[2]=1 xinc[3]=0 xinc[4]=-1
yinc={} yinc[0]=0 yinc[1]=-1 yinc[2]=0 yinc[3]=1 yinc[4]=0

-- enums
gs_titles=0
gs_game=1

s_gamestart=-2
s_levelstart=-1
s_levelcomplete=-3
s_playing=0
s_loselife=2
s_gameover=9

r_water=0
r_road=1
r_bank=2
r_home=3
r_start=4

t_log=0
t_croc=1
t_turtle=2
t_vehicle=10

ds_none=0
ds_diving=1
ds_underwater=2
ds_surfacing=3

n_empty=0
n_home=1
n_croc=2
n_fly=3

-- sfx and music
sfx_timeup=0
sfx_playerdead=1
sfx_froghome=2
sfx_jump=3
sfx_snake=5
sfx_lady=6

music_titles=30
music_gameover=40
music_start=0
music_playing=4
music_levelcomplete=16

-- titles
title_x=0
title_text="paul hammond 2020  thanks to @s_yanik for enhanced graphics  testing by finn and lucas. programming and music by paul hammond  press q to quit mid-game"

-- game state
game_state=gs_titles

-- mode
mode=dget(0)

-- enhanced gfx mode
gfxplus=false
gfxoff1=0
gfxoff2=0
gfxoff3=0

function _init()
 -- game session
 game=session:new()

 -- enable kb
 poke(24365,1)

 -- initialise
 reset_titles()
end

function reset_titles()
 flash=false
 flashcounter=0
 game_state=gs_titles
 title_counter=0
 title_x=0

 -- clear sfx
 sfx(-1)

 -- title music
 music(music_titles)

 -- new hi score?
 if game.score!=nil and game.score>hiscore then
  hiscore=game.score

  -- save (per mode)
  dset(1+mode,hiscore)
 end

 -- mode
 modeupdate(0)

 -- transition
 transition.fadein()
end

function reset_newgame()
 game_state=gs_game
 game:reset_newgame()

 -- stop music
 music(-1)
end

function _update60()
 -- counters
 flashcounter=(flashcounter+1)%60
 flash=flashcounter<30
 
 -- toggle gfx
 if btnp(4) then
  gfxplus=not gfxplus
  if gfxplus then
   gfxoff1=64
   gfxoff2=-32
   gfxoff3=4
  else
   gfxoff1=0
   gfxoff2=0
   gfxoff3=0  
  end
 end

 -- update
 if game_state==gs_titles then
  update_titles()
 else
  update_game()
 end

 -- transition
 if (transition.active) transition.process()

 -- quit game?
 if (kb("q")) game.gameover=true
end

function update_game()
 game:update()

 -- game over?
 if (game.gameover) reset_titles()
end

function update_titles()
 if (title_counter<1000) title_counter+=1
 
 -- scroll text
 title_x+=0.5
 if (title_x>150+#title_text*5) title_x=0

 -- mode
 if (btnp(0)) modeupdate(-1)
 if (btnp(1)) modeupdate(1)
 
 -- demo game
 game:update()

 -- new game?
 if (btnp(5)) reset_newgame()
end

function _draw()
 -- draw
 if game_state==gs_titles then
  draw_titles()
 else
  game:draw()
 end

 -- transition
 if (transition.active) transition.draw()

 -- debug
 if debug_stats then
  rectfill(0,0,60,17,10)
  ? "cpu: "..(100*(stat(1)/2)).."%",0,0,1
  ? "mem: "..stat(0),0,6
  ? "fps: "..stat(7),0,12
 end
end

function draw_titles()
 -- demo game
 game:draw()

 -- version
 if (title_counter<120 and not noversion) print(version,116,1,7)

 -- title
 map(8,2,53,max(12,36-title_counter/4),3,2) 
 pal(11,10)
 for y=-1,1 do
  for x=-1,1 do
   map(0,0,16+x,24+y,13,2)  	
  end
 end
 pal()
 map(0,0,16,24,13,2)

 -- mode etc
 local m="mode "..mode+1
 if mode==0 then
  m="easy"
 elseif mode==1 then
  m="normal"
 elseif mode==7 then
  m="crazy"
 end
 printc("‹ "..m.." ‘",44,7,-4,true)
 if hiscore>0 then
  printc("high "..hiscore.."0",62,10,0,true)
 else
  printc("no high score",62,10,0,true)
 end 
 
 if (flash) printc("— to start",72,7,-2,true)

 -- enhanced gfx
 if title_counter<320 then
  camera(-30,min(-84,-128+title_counter/2))
  rectfill(0,0,68,24,0)
  print("Ž/z toggle gfx+",3,2,7)
  spr(76,3,8,2,2)
  spr(100,23,8,3,2)
  spr(96,51,8,2,2)
  camera()
 end
 
 -- scroll text
 for y1=-1,1 do
  for x1=-1,1 do
   ? title_text,128-title_x+x1,121+y1,0
  end
 end
 ? title_text,128-title_x,121,14 
end

function modeupdate(dir)
 local lastmode=mode
 mode=(mode+dir)%8

 -- reset demo game
 game:reset_newgame()

 -- save default mode
 dset(0,mode)

 -- load hi-score
 hiscore=dget(1+mode)
end
-->8
-- classes


-- session
session={}

function session:new()
 return init_obj({},self)
end

function session:reset_newgame()
 local s=self

 -- title screen demo?
 s.demo=(game_state==gs_titles)
 s.gameover=false

 -- general
 s.lives=3
 s.score=0
 s.level=1
 
 -- objects
 s.input=input:new(s.index)
 s.player=player:new(s,false)
 s.lady=player:new(s,true)
 s.traffic=traffic:new(s)
 s.snake=snake:new(s)

 -- reset level
 s:reset_level(true)
end

function session:reset_level(newgame)
 local s=self

 -- sfx
 sfx(-1)

 -- collections
 s.particles={}

 -- reset
 if newgame then
  s:setstate(s_gamestart)
 else
  s:setstate(s_levelstart)
 end
 
 -- objects
 s.traffic:initialise()
 s.player:reset()
 s.snake:reset()
 s.lady:reset()

 -- nests
 s.nests={}
 for i=0,4 do
  add(s.nests,{state=n_empty,statecount=0,x=4+i*24,y=0})
 end
 
 -- other
 s.leveltime=0
 s.time=30
 s.homecount=0
 
 -- transition
 if (newgame and not s.demo) transition.fadein()
end

function session:reset_newlife()
 local s=self
 
 s.time=30
 s.message=""
 s.player:reset()
 
 s:setstate(s_playing)
 
 -- music
 if (not s.demo) music(music_playing) 
end

function session:setstate(s,c)
 if (c==nil) c=0
 self.state=s
 self.statecount=c
end

function session:update()
 local s=self
 local traffic=s.traffic

 -- input
 s.input:update()
 
 -- objects
 traffic:update()
 s.snake:update()
 s.lady:update()
 s:update_nests()
 
 -- particles
 s:update_particles()
 
 -- state
 if s.state==s_gamestart then
  -- ##########
  -- game start
  -- ##########
  if s.statecount==1 then
   if (not s.demo) music(music_start)
   s:setstate(s_levelstart)
  end 
 elseif s.state==s_levelstart then
  -- ###########
  -- level start
  -- ###########
  if s.statecount==1 then
   s.message="level "..s.level
  elseif s.statecount>=100 then
   s.message=""
   s:setstate(s_playing)
  end
  
  -- player
  if (not s.demo) s.player:update()
 elseif s.state==s_playing then
  -- #######
  -- playing 
  -- #######
  -- timers
  if (not s.demo) s.time-=1/fps
  if s.time<=0 then
   s.message="time up!"
   s:setstate(s_loselife)
   
   -- sfx
   gsfx(sfx_timeup,3)   
  end
  if s.leveltime<=45 and s.leveltime+1/fps>45 then
   s.traffic:speedup()
  end
  if (not s.demo) s.leveltime+=1/fps
  
  -- player
  if (not s.demo) s.player:update()  
 elseif s.state==s_levelcomplete then
  -- ##############
  -- level complete
  -- ##############
  if s.statecount==1 then
   s.message="level cleared"
   
   -- music
   gsfx(-1)
   if (not s.demo) music(music_levelcomplete)    
  elseif s.statecount==150 then
   -- next level
   s.level+=1   
   s:reset_level(false)
   
   -- music
   if (not s.demo) music(music_playing)   
  end
 elseif s.state==s_loselife then
  -- #########
  -- lose life
  -- #########
  if s.statecount==1 then
   s.player.active=false
   s:particlesadd(12,s.player.x+4,s.player.y+4,4,11)
   s:particlesadd(12,s.player.x+4,s.player.y+4,2,8)
   
   -- stop music
   music(-1)
   
   -- sfx
   gsfx(sfx_playerdead,1)
  elseif s.statecount==90 then
   s.lives-=1
   if s.lives==0 then
    s:setstate(s_gameover)
   else
    s:reset_newlife()
   end
  end
 elseif s.state==s_gameover then
  -- #########
  -- game over
  -- #########
  if s.statecount==1 then
   s.message="game over"
   
   -- sfx
   sfx(-1)
   music(music_gameover) 
  elseif s.statecount==220 then
   s.gameover=true
  end
 end
 
 -- collisions
 if s.state==s_playing or s.state==s_levelstart then
  local hit,dead=false,false

  if mode!=0 and (s.player.x<-5 or s.player.x>125) then
   -- #############
   -- out of bounds
   -- #############
   dead=true
   s.message="out of bounds!"
  elseif s.player.rowtype==r_home and s.player.movecount==0 then
   -- #####
   -- home?
   -- #####
   local homenest=nil
   for n in all(s.nests) do
    if abs((n.x+8)-s.player.x)<5 then
     homenest=n
     break
    end
   end

   if not homenest then
    dead=true
    s.message="missed!"
   elseif homenest.state==n_empty or homenest.state==n_fly or (homenest.state==n_croc and homenest.statecount<45) then
   	-- home
   	if homenest.state==n_fly then
   	 s:scoreadd(20)
   	else
     s:scoreadd(5)
   	end
    if s.player.carrying then
     s:scoreadd(15)
    end
    s:scoreadd(flr(s.time/2))
    
   	homenest.state=n_home

    -- reset
   	s.time=30
   	s.player:reset()
    
   	-- all home?
   	s.homecount+=1
   	if s.homecount==5 then
   	 s:setstate(s_levelcomplete)
    else
     -- sfx
     gsfx(sfx_froghome,3)    
   	end
   else
   	-- occupied
   	dead=true
   	if homenest.state==n_croc then
   	 s.message="eaten by croc!"
   	else
   	 s.message="occupied!"
   	end
   end
  elseif s.player.x>-6 and s.player.x<122 then
   -- ############################
   -- hit vehicle or water object?
   -- ############################
   if s.player.hitrect then
    for rw in all(traffic.rows) do
     for i in all(rw.items) do
      if i.divestate!=ds_underwater and rectsoverlap(s.player.hitrect,i) then
       hit=true
       break
      end
     end
    end
    
    if s.player.rowtype==r_water and s.player.movecount==0 then
     if not hit then
      dead=true
      s.message="drowned!"
     end
    elseif hit and s.player.rowtype==r_road then
     dead=true
     s.message="splat!"
    end

    -- #################################
    -- test other objects (e.g. snakes)?
    -- #################################
    if not dead then
     -- snake
     if s.snake.active then
      if rectsoverlap(s.player.hitrect,s.snake) then
       dead=true
       s.message="eaten!"
      end
     end

     -- lady frog     
     if s.lady.active then
      if rectsoverlap(s.player.hitrect,s.lady.hitrect) then
       s.player.carrying=true
       s.lady.active=false
       s:particlesadd(8,s.lady.x+4,s.lady.y+4,1,14)
       
       -- sfx
       gsfx(sfx_lady,3)
      end      
     end
    end
   end
  end

  -- dead?
  if dead then
   s:setstate(s_loselife)
  end
 end
  
 -- state counter
 if (s.statecount<1000) s.statecount+=1
end

function session:draw()
 local s=self
 
 -- initialise
 cls(3)

 -- camera
 camera(0,-1)
 
 -- background
 spr(152+gfxoff3,0,0)
 spr(152+gfxoff3,120,0)
 rectfill(0,8,128,58,1)
 rectfill(0,59,128,67,2)
 rectfill(0,68,128,117,5)
 rectfill(0,118,128,127,3)

 -- nests
 for n in all(s.nests) do
  spr(149+gfxoff3,n.x,n.y,3,1)
  
  if n.state==n_home then
   -- frog home
   spr(147,n.x+8,n.y)
  elseif n.state==n_fly then
   -- fly
   sprscaled(148,n.x+8,n.y,min(1,n.statecount/20))
  elseif n.state==n_croc then
   -- croc
   local offx=0
   if n.statecount<60 then
    offx=-10+n.statecount/6
   elseif n.statecount>200 then
    offx=-(n.statecount-200)/6
   end
   clip(n.x+6,n.y,10,9)
   spr(139,n.x+6+offx,n.y,2,1)
   clip()
  end
 end

 -- traffic
 s.traffic:draw()

 -- score panel
 if (not s.demo) s:draw_scorepanel()

 -- snake
 s.snake:draw()
 
 -- lady frog
 s.lady:draw()

 -- player
 if s.state==s_levelstart or s.state==s_playing then
  s.player:draw()
 end

 -- particles
 for p in all(s.particles) do
  circfill(p.x,p.y,p.r,p.c)
 end
 
 -- finalise camera
 camera(0,0)

 -- message
 if (not s.demo and s.message) printc(s.message,48,7,0,true)
end

function session:draw_scorepanel()
 local s=self
 
 -- initialise
 --rectfill(0,118,128,128,11)
 
 -- level
 --prints(s.level,3,121,7)
 
 -- lives
 for i=1,s.lives do print("‡",127-i*6,120,8) end

 -- time
 if s.time>0 then
  -- make bar orange if just about to speed up
  local c=8
  if s.leveltime>=43 and s.leveltime<45 then
   if (s.time*10)%2<=1 then
    c=9
   else
   	c=10
   end
  end

  rectfill(0,59,1+s.time*(127/30),67,c)
 end
 
 -- score
 if flash or s.score<hiscore or hiscore==0 then
  local sc="0"
  if (s.score!=0) sc=s.score.."0"
  print(sc,1,120,7)
 end
end

function session:scoreadd(v)
 local s=self
 
 -- score
 local oldscore=s.score
 s.score+=v
 
	-- bonus life?
 if (oldscore<150 and s.score>=150) or (oldscore<500 and s.score>=500) then
  s.lives+=1
  --gsfx(sfx_bonuslife,0)
 end
end

function session:particlesadd(count,x,y,r,c)
 local s=self

 local r2,x1,y1,dx,dy,ttl
 
 for i=1,count do
  x1=x-r+rnd(r*2)
  y1=y-r+rnd(r*2)
  dx=rnd(1)-0.5
  dy=rnd(1)-0.5
  
  r2=0.5+rnd(r)  
  ttl=30+flr(rnd(15))
     
  add(s.particles,{x=x1,y=y1,r=r2,c=c,dx=dx,dy=dy,ttl=ttl})
 end
end

function session:update_particles()
 local s=self
 
 for i=#s.particles,1,-1 do
  local p=s.particles[i]

  p.ttl-=1
  if p.ttl==0 or p.r<0.5 then
   del(s.particles,p)
  else
   if (p.r>0.5) p.r-=0.09
   p.x+=p.dx
   p.y+=p.dy
  end
 end
end

function session:update_nests()
 local s=self
 
 local croccount=0
 for n in all(s.nests) do
  if (n.state==n_croc) croccount+=1
 end
 
 for n in all(s.nests) do
  -- activate croc/ fly?
  if n.state==n_empty then
   if n.statecount>=0 and randi(0,2000-mode*150)==1 and (croccount==0 or (croccount==1 and (s.level>5 or mode>5))) then
    if randi(1,4)==1 then
     n.state=n_fly
    else
     n.state=n_croc
    end
    n.statecount=0
   end 
  elseif n.state==n_fly then
   -- fly
   if n.statecount>240 then
    n.state=n_empty
    n.statecount=-120
   end
  elseif n.state==n_croc then
   -- croc
   if n.statecount==260 then
    n.state=n_empty
    n.statecount=-120
   end
  end
  
  -- counters
  if (n.statecount<1000) n.statecount+=1
 end
end


-- traffic
traffic={}

function traffic:new(s)
 return init_obj({session=s},self)
end

function traffic:initialise()
 local s=self
 local session=s.session
 
 -- initialise
 s.statecount=0
 s.counter=0

 -- mode/level
 local levelresolved=session.level+mode%4
 local speedmultiplier=0.9+mode/10
 
 -- define traffic rows
 s.rows={}
 
 -- 1 - logs
 local r=s:addrow(r_water,9,1,0.4*speedmultiplier)
 if levelresolved<3 then
  for i=0,2 do s:addlog(r,i*6,4,i==1 or levelresolved>5) end 	
 elseif levelresolved<5 and mode<7 then
  for i=0,1 do s:addlog(r,i*7,4,i==1 or mode>4) end
 else
  s:addlog(r,6,6,true)
 end

 -- 2 - turtles
 local r=s:addrow(r_water,19,-1,0.35*speedmultiplier)
 if levelresolved<3 then  
  for i=0,2 do s:addturtle(r,i*6,2,i==1,120) end
 else
  for i=0,1 do s:addturtle(r,i*8,2,i==1 or levelresolved>7,90,30*i) end
 end

 -- 3 - long logs
 local r=s:addrow(r_water,29,1,0.45*speedmultiplier)
 if levelresolved<3 and mode<5 then
  for i=0,1 do s:addlog(r,i*9,7,false) end
 else
  s:addlog(r,9,9,false)
 end

 -- 4 - short logs
 local r=s:addrow(r_water,39,1,0.6*speedmultiplier)
 if levelresolved<4 and mode<5 then
  for i=0,2 do s:addlog(r,i*6,3,false) end
 else
  for i=0,1 do s:addlog(r,i*8,3,false) end
 end

 -- 5 - turtles
 local r=s:addrow(r_water,49,-1,0.25*speedmultiplier)
 if levelresolved<3 then
  for i=0,1 do s:addturtle(r,i*8,3,i==1,60) end
 elseif levelresolved<5 then
  for i=0,2 do s:addturtle(r,i*6,2,i==2,60) end
 else
  for i=0,1 do s:addturtle(r,i*6,2,i==1 or levelresolved>7,60,i*20) end
 end

 -- 6 - bank
 local r=s:addrow(r_bank,59,0,0)

 -- 7 - trucks
 local r=s:addrow(r_road,69,-1,0.2*speedmultiplier)
 if levelresolved>4 or mode>5 then
  for i=0,2 do s:addvehicle(r,i*6,3,36) end
 else
  for i=0,1 do s:addvehicle(r,i*10,3,36) end
 end

 -- 8 - racing cars
 local r=s:addrow(r_road,79,1,0.7*speedmultiplier)
 if levelresolved==1 then
  s:addvehicle(r,6,2,12)
 elseif levelresolved<4 then
  for i=0,1 do s:addvehicle(r,i*6,2,12) end
 else
  for i=0,2 do s:addvehicle(r,i*5,2,12) end
 end

 -- 9 - sedans
 local r=s:addrow(r_road,89,-1,0.225*speedmultiplier)
 for i=0,2 do s:addvehicle(r,i*6,2,14) end

 -- 10 - diggers
 local r=s:addrow(r_road,99,1,0.4*speedmultiplier)
 if levelresolved>4 or mode>6 then
  for i=0,2 do s:addvehicle(r,i*6,2,32) end
 else
  for i=0,1 do s:addvehicle(r,i*9,2,32) end
 end

 -- 11 - cars
 local r=s:addrow(r_road,109,-1,0.45*speedmultiplier)
 if levelresolved>4 or mode>5 then
  for i=0,3 do s:addvehicle(r,i*4,2,34) end 	
 else
   for i=0,2 do s:addvehicle(r,i*6,2,34) end
 end
end

function traffic:addrow(rowtype,y,dir,basespeed)
 local row={type=rowtype,y=y,dir=dir,basespeed=basespeed,items={},speed=basespeed,counter=0}
 add(self.rows,row)
 return row
end

function traffic:addlog(row,x,w,croc)
 local t=t_log
 if (croc) t=t_croc

 for i=0,w-1 do
  local item={type=t,x=(x+i)*8,y=row.y,w=8,h=8}
  if i==0 then
   item.sprite=39
   item.ladyactivator=true
  elseif i==w-1 then
   item.sprite=41
  else
   item.sprite=40
  end
  add(row.items,item)
 end
end

function traffic:addturtle(row,x,w,diver,diveinterval,divestatecount)
 if (divestatecount==nil) divestatecount=0

 for i=0,w-1 do
  local item={type=t_turtle,x=x*8+i*16,y=row.y,w=16,h=8,diver=diver,diveinterval=diveinterval,divestate=ds_none,divestatecount=divestatecount}
  add(row.items,item)
 end
end

function traffic:addvehicle(row,x,w,sprite)
 for i=0,w-1 do
  local item={type=t_vehicle,x=(x+i)*8,y=row.y,w=8,h=8,sprite=sprite+i}
  add(row.items,item)
 end
end

function traffic:speedup()
 local s=self

 for row in all(s.rows) do
  row.speed=row.basespeed*1.4
  if (row.speed>1.5) row.speed=1.5
 end
end

function traffic:update()
 local s=self
 local session=s.session
 
 -- process
 for row in all(s.rows) do
  -- row counter (used for animations etc)
  row.counter+=row.speed/50

  for i in all(row.items) do
   i.x+=row.dir*row.speed
    
   -- wrap
   if i.x<-25 then
    i.x+=152
   elseif i.x>127 then
    i.x-=152
   end

   -- turtle diving?
   if i.diver then
   	i.divestatecount+=1

   	if i.divestate==ds_none then
   	 if i.divestatecount==i.diveinterval then
   	  i.divestate=ds_diving
   	  i.divestatecount=0
   	 end
   	elseif i.divestate==ds_diving then
   	 if i.divestatecount==45 then
   	  i.divestate=ds_underwater
   	  i.divestatecount=0
   	 end   	 
   	elseif i.divestate==ds_underwater then
   	 if i.divestatecount==i.diveinterval then
   	  i.divestate=ds_surfacing
   	  i.divestatecount=0
   	 end
    elseif i.divestate==ds_surfacing then
   	 if i.divestatecount==45 then
   	  i.divestate=ds_none
   	  i.divestatecount=0
   	 end    	
   	end
   end

   -- animate turtle
   if i.type==t_turtle then
   	if i.divestate==ds_diving then
   	 i.sprite=224+flr(i.divestatecount/11.25)*2
   	elseif i.divestate==ds_surfacing then
   	 i.sprite=230-flr(i.divestatecount/11.25)*2
   	else
     i.sprite=232+flr((s.counter*8)%4)*2
    end
   end
  end
 end
 
 -- state counters
 if (s.statecount<10000) s.statecount+=1 
 s.counter+=0.01
end

function traffic:draw()
 local s=self

 for row in all(s.rows) do
  for i in all(row.items) do
   if i.type==t_turtle then
   	-- turtle
   	if i.divestate!=ds_underwater and i.sprite!=nil then
   	 spr(i.sprite+gfxoff2,i.x,i.y-4,2,2)
   	end
   elseif i.sprite then
   	-- generic, e.g., log or vehicle
   	spr(i.sprite+gfxoff1,i.x,i.y-4,1,2)
   end
  end
 end
end


-- player
player={}

function player:new(s,lady)
 return init_obj({session=s,lady=lady},self)
end

function player:reset()
 local s=self
 local session=s.session
 
 -- general
 s.active=not session.demo
 s.carrying=false
 s.dir=d_up
 s.dir_buffered=d_none
 s.dir_bufferedcount=0
 s.x=60
 s.y=120
 s.w=9
 s.h=6
 s.hitrect=nil
 s.sprite=0
 s.movecount=0
 s.rowtype=r_start
 
 -- lady frog?
 if s.lady then
  s.active=false
  s.ladyappearcount=randi(180,900)
  s.y=30
 end
 
 s:setstate(ps_normal) 
end

function player:setstate(s,c)
 if c==nil then c=0 end
 self.state=s
 self.statecount=c 
end

function player:update()
 local s=self
 local session=s.session
 local i=session.input
 local traffic=session.traffic

 -- activate lady frog?
 if s.lady and not s.active and not session.player.carrying then
  s.ladyappearcount-=1
  if s.ladyappearcount<0 then
   for ti in all(traffic.rows[3].items) do
    if ti.ladyactivator and ti.x<-10 and ti.x>-12 then
     s.active=true
     s.ladyloops=0
     s.ladyappearcount=randi(180,1800)
     s.ladycounter=0
     s.ladymovecount=0
     s.movecount=0
     s.dir=d_right
     s.x=-11
    
     break
    end
   end
  end
 end
 
 -- active?
 if (not s.active) return
 
 -- determine row
 local rowindex,row=flr((s.y+5)/10),nil
 if (rowindex>0 and rowindex<12) row=traffic.rows[rowindex]
 if row then
  s.rowtype=row.type
 elseif rowindex==0 then
  s.rowtype=r_home
 elseif rowindex==12 then
  s.rowtype=r_start
 end

 if s.state==ps_normal then
  -- ======
  -- normal
  -- ======
  if s.lady then
   -- ====================
   -- lady frog controller
   -- ====================
   i={dir=d_none}
   
   if s.movecount==0 then
    s.ladycounter+=1
    if s.ladycounter==30 then
     s.ladycounter=0
     
     if randi(1,2)==1 then
      i.dir=s.dir
      
      if s.ladymovecount==4 then
       s.ladymovecount=0
       if i.dir==d_right then
        i.dir=d_left
       else
        i.dir=d_right
       end
      end
      
      s.ladymovecount+=1       
     end
    end
   end
  else
   -- ========================================
   -- buffer player input for less frustration
   -- ========================================
   if i.dir!=d_none then
    s.dir_buffered=i.dir
    s.dir_bufferedcount=10
   elseif s.dir_bufferedcount>0 then
    s.dir_bufferedcount-=1
   else
    s.dir_buffered=d_none
   end
  end

  -- move
  if s.movecount==0 then
   -- wrap x position (for easy mode)
   if s.x<-25 then
    s.x+=152
   elseif s.x>127 then
    s.x-=152
    
    -- deactivate lady frog
    if s.lady then
     s.ladyloops+=1
     if (s.ladyloops==3) s.active=false
    end
   end
   
   -- use buffered input?
   if (not s.lady and i.dir==d_none) i.dir=s.dir_buffered
   
   if i.dir==d_down and rowindex==12 then
    -- can't move off bottom of screen
   --elseif not s.lady and (s.x<-8 or s.x>128) then
   	-- can't move if off screen too much (log or turtle will wrap and carry player back on)
   elseif i.dir!=d_none then
    s.dir=i.dir
    s.movecount=10
    
    -- sfx
    if (not s.lady) gsfx(sfx_jump,3)    
   end
  else
   s.x+=xinc[s.dir]
   s.y+=yinc[s.dir]
   s.movecount-=1
  end
  
  -- move with water?
  if row and row.type==r_water then
   -- keep movement consistent moving left and right, regardless of water direction
   s.x+=row.dir*row.speed
   
   -- smooth x position so 1 pixel jump does not occur
   for i in all(row.items) do
    if s.hitrect and rectsoverlap(s.hitrect,i) then
     -- match fractional portion
     local fr=i.x-flr(i.x)
     s.x=flr(s.x)+fr
     break
    end
   end
  end

  -- keep on screen unless on water
  if not row or row.type!=r_water then
   if (s.x<0) s.x=0
   if (s.x>120) s.x=120
  end
 end
 
 -- calculate hit rectangle
 if row and row.type==r_water then
  s.hitrect={x=s.x+2.5,y=s.y+1,w=3,h=6}
 else
  s.hitrect={x=s.x+1,y=s.y,w=6,h=6}
 end 
 
 -- state counter
 if (s.statecount<1000) s.statecount+=1
 
 -- animate
 if s.dir==d_left or s.dir==d_right then
  s.sprite=6
 else
  s.sprite=0
 end
 s.flipx=s.dir==d_left
 s.flipy=s.dir==d_down
 if s.movecount!=0 then
  s.sprite+=2*flr(s.movecount/5)--(flr(s.movecount*0.2)*2)
 end
 
end

function player:draw()
 local s=self
 
 if s.active then
  if s.lady then
   if gfxplus then
    pal(7,14)
    pal(6,2)
   else
    pal(11,14)   
   end
  elseif s.carrying and flash then
   if gfxplus then
    pal(7,14)
    pal(6,2)
   else
    pal(11,14)   
   end
   pal(11,14)
  end
  
  local offy=0
  if (s.dir==d_down) offy=-1
  spr16(s,gfxoff1,offy)
  
  pal()
 end
end


-- snake
snake={}

function snake:new(s)
 return init_obj({session=s},self)
end

function snake:reset()
 local s=self
 local session=s.session

 s.active=false
 s.interval=600-session.level*45-mode*45
 s.speed=0.25
 s.counter=s.interval
 s.x=-24
 s.y=60
 s.w=16
 s.h=8
end

function snake:update()
 local s=self
 local session=s.session

 if s.counter>0 then
  s.counter-=1
 else
  -- sfx
  if (not s.active) gsfx(sfx_snake,2)
 
  s.active=true
  s.x+=s.speed
  
  if s.x>132 then
   s.x=-24
   s.active=false
   s.counter=s.interval
   
   -- stop sfx
   gsfx(-1,2)
  end
 end
end

function snake:draw()
 spr(131+2*flr((self.x/2)%4),self.x,self.y,2,1)
end
-->8
-- helper
function debugrect(e)
 rect(e.x,e.y,e.x+e.w-1,e.y+e.h-1,14)
end

function gsfx(n,c)
 if (game_state==gs_game and game.state!=s_gameover) sfx(n,c)
end

function spr16(e,sprite_offset,y_offset)
 -- offset 16x16 sprites by 4 pixels to account for margins
 if (y_offset==nil) y_offset=0
 if (e.active) spr(e.sprite+sprite_offset,e.x-4,e.y-4+y_offset,2,2,e.flipx,e.flipy)
end

function sprscaled(frame,x,y,scale)
 local size=8*scale
 local offset=(8-size)/2
 local ssx=(frame/16-flr(frame/16))*128
 local ssy=flr(frame/16)*8
 sspr(ssx,ssy,8,8,x+offset,y+offset,size,size)
end

function rectsoverlap(e1,e2)
 return e1.x<e2.x+e2.w and
        e2.x<e1.x+e1.w and
        e1.y<e2.y+e2.h and
        e2.y<e1.y+e1.h
end

function randi(n1,n2)
 return flr(n1+rnd(n2-n1))
end

function kb(k)
 return stat(30) and stat(31)==k
end

function init_obj(o,self)
 setmetatable(o,self)
 self.__index=self
 return o
end

function printc(s,y,c,offx,shad)
 local x=64-#s*2
 if (offx!=nil) x+=offx
 if shad then
  for y1=-1,1 do
   for x1=-1,1 do
    ? s,x+x1,y+y1,0
   end
  end
 end
	? s,x,y,c
end

function prints(s,x,y,c)
 for y1=-1,1 do
  for x1=-1,1 do
   ? s,x+x1,y+y1,0
  end
 end

	? s,x,y,c
end


-- input
input={}

function input:new()
 return init_obj({},self)
end

function input:update()
 local s=self
 
 s.up=btnp(2)
 s.down=btnp(3)
 s.left=btnp(0)
 s.right=btnp(1)
 --s.fire=btnp(5)
 
 s.dir=d_none
 if (s.up) s.dir=d_up
 if (s.down) s.dir=d_down
 if (s.left) s.dir=d_left
 if (s.right) s.dir=d_right 
end
-->8
-- effects

-- transition
transition={active=false,complete=true,effect=false}

transition.fadein=function()
 local t=transition
 
 t.effect="fadein"
 t.active=true
 t.complete=false
 t.value=0
end
 
transition.process=function()
 local t=transition
 
 if (not t.active) return 
 
 if t.effect=="fadein" and not t.complete then
  t.value+=0.8
  if t.value>=30 then
   t.complete=true
   t.active=false
  end
 end
 
 return t.complete
end

transition.draw=function()
 local t=transition
 
 if (not t.active) return 
 
 if t.effect=="fadein" then
  for x=0,128,20 do
   for y=0,128,20 do
   	circfill(x,y,24-t.value,1)
   end
  end
 end
end


-->8
-- todo

--[[

  
]]--
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000b000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000b00bb00b00000000b00bb00b000000000bbb00bb00000000bbb0000bbb00000000bb000bb00000000000000000000000000000000000
0000b00bb00b00000000b0bbbb0b00000000b0bbbb0b00000000000b0b0000000000000bb0b0000000000b0bb0b00000088888800888880000dddd0000dddd00
0000b0bbbb0b000000000bbbbbb0000000000bbbbbb000000000000bbbb0000000000000bbbb000000000000bbbb000088811888881188800dddddddddddddd0
00000bbbbbb00000000000bbbb000000000000bbbb0000000000000bbbbb000000000000bbbbb00000000000bbbbb0008818888888811878d7dd11dddddd1ddd
000000bbbb00000000000bbbbbb0000000000bbbbbb000000000000bbbbb000000000000bbbbb00000000000bbbbb0008818888888811888ddd11dddddddd1dd
0000bbbbbbbb000000000b0000b000000000bb0000bb00000000000bbbb0000000000000bbbb000000000000bbbb00008818888888811888ddd11dddddddd1dd
0000b000000b00000000b000000b00000000b000000b00000000000b0b0000000000000bb0b0000000000b0bb0b000008818888888811878d7dd11dddddd1ddd
0000b000000b00000000b000000b000000000b0000b0000000000bbb00bb00000000bbb0000bbb00000000bb000bb00088811888881188800dddddddddddddd0
00000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000000000000088888800888880000dddd0000dddd00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa00aaaaa0000cccc0000cccc00006666000666666666666666004444444444444444444400000000000000000000000000000000000000000000000000
aaa11aaaaa11aaa00cccccccccccccc0666666665666666666666666044444444444444444444440000000000000000000000000000000000000000000000000
aa1aaaaaaaa11a9ac7cc111cccc11ccc611666665666666666666666444444444444444444444444000000000000000000000000000000000000000000000000
aa1aaaaaaaa11aaaccc111ccccccc1cc611666665666666666666666444444444444444444444444000000000000000000000000000000000000000000000000
aa1aaaaaaaa11aaaccc111ccccccc1cc611666665666666666666666444444444444444444444444000000000000000000000000000000000000000000000000
aa1aaaaaaaa11a9ac7cc111cccc11ccc611666665666666666666666444444444444444444444444000000000000000000000000000000000000000000000000
aaa11aaaaa11aaa00cccccccccccccc0666666665666666666666666044444444444444444444440000000000000000000000000000000000000000000000000
0aaaaaa00aaaaa0000cccc0000cccc00006666000666666666666666004444444444444444444400000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000001600100070000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000011601670070000000160167007000000000777007700000000777000077700000000770007700000000000000000000001110000111000
000161167007000000116166770700000001616677070000000001170700000000000007707000000000171770700000092228222288880010d11ddddddddd00
00016166770700000001166677700000000116667770000000000017777000000000000077770000000000017777000096811888881186801fdc66666666dde0
00001666777000000000116667000000000001667700000000000017777700000000000077777000000000017777700088688888888c1872df1cffffffffc116
00001166770000000000166667700000000016667770000000000016666700000000000166667000000000016666600088688888888c18821d1cffffffffc116
00016666777700000000161100700000000166110077000000000016666100000000000166661000000000016666100088c88888888c18821d1cffffffffc116
00016111110700000001610000070000000161000007000000000116161000000000111660610000000006166061000088c88888888c1872df1cffffffffc11d
00016100000700000001610000070000000016000070000000001666106600000000666110177700000001661016700096811888881186801f1c55555566dd20
000111000000000000016100000700000000010000000000000001110011000000001111000000000000001100010000192222822228881010d11ddddddddd00
00000000000000000001110000000000000000000000000000000000000000000000000000000000000000000000000011111111111111000001110000111000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa00aa7770000cc111111fffc0000dddd000dddddddddddddd6000000000000000000000000000000000000000000000000000000000000000000000000
89a11aaaaa11aa7006cc1c9941cccc8096dd11600dd66666666666df000000000000003b00000000000000000000000000000000000000000000000000000000
991aaaaaaaac1a97c7cc1fd941cccccf61c66ad01d66d66d666d66df00000000330553bb113b0000000000000000000000000000000000000000000000000000
991aaaaaaaac1aa7ccc1ffd941cccccf61c66a11ddd6d66d666d66df00000333333333b3223bbb00000000000000000000000000000000000000000000000000
991aaaaaaaac1aa7ccc1ffd941cccccf61c66a11ddd6d66d666d66df003333333333333b3bbbbbbb000000000000000000000000000000000000000000000000
991aaaaaaaac1a97c7cc133241cccccf61c66ad01d66d66dd66d66df03333a9b9b93ab9a43b3b3b7000000000000000000000000000000000000000000000000
82911aaaaa11aa7016ccc3e221cccc8096dddd600da66666666666af339c9333333333b322253333000000000000000000000000000000000000000000000000
199999911a99971001cccf3111111c0011ddcc101aaaaaaaaaaaaaa6393333333333353311233300000000000000000000000000000000000000000000000000
11111111111110000111111111110000111111100111111111111111933c33003335533b12330000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111111111110000000000000053300000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000bbbb0000000000bb000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bbb0000000000bbbbbbb00bb000bbbb0000000bb0bbb0000000bb0000000000440000000000000000000000000000000
0000000000000000000000000000000bbbbbb0000000bbb0000bbbbb00bb0bbbb000bbbbb00bb00000bbbb000440044444000000000000000000000000000000
001111011110011100111100bb0000bb0000bbbbb00bb0000000bb00bb00000bbbbbb0000000bb00bbb00bbb4004444a0a000000000000000000000000000000
01ffff1ffff11fff11ffff1000b0bbb0000000bb0bbb000000000000000000000bb0000000000bbbbb0000bb44440a0000000000000000000000000000000000
1ff1ff11ff11ff111ff1ff10000bb0000000000000000000000000000000000000000000000000bb00000000444000000a000000000000000000000000000000
1fffff11ff11ff101ff1ff10000000000000000000000000000000000000000000000000000000000000000044440a0a0a000000000000000000000000000000
1ff11101ff11ff111ff1ff1000000000000000000000000000000000000000000000000000000000000000004444444444000000000000000000000000000000
1ff1001ffff1ffff1ffff1000000000000000000333333311111111113333333333333333333bbb111d111111335333333333333000000000000000000000000
0110000111101111011110000000000000000000333333111111111111333333333333333933bb31d11111111153333333a33333000000000000000000000000
0000000000000000000000000bb00bb0000ccc003333331111111111113333333333333333d3bb311c1d1111113539333bd33333000000000000000000000000
000000000000000000000000b00bb00b8bcc8800333333111111111111333333333333333333bb31d11111111153333333333333000000000000000000000000
0000000000000000000000000bbbbbb0bb88888033333311111111111133333333333333833d3b3111d1111111353e333d333933000000000000000000000000
000000000000000000000000b0bbbb0b8bcc880033333311111111111133333333333333d33ebb31d11111111153339338d33da3000000000000000000000000
0000000000000000000000000b0000b0000ccc00333333111111111111333333333333333333bb11111111111135b33333333333000000000000000000000000
00000000000000000000000000bbbb000000000033333311111111111133333333333333bbbbb31111d11111115bbbbb33333333000000000000000000000000
bbbbbbbbbbb0bbbbbbbbb000000000bbbbbb00000000000bbbbbbbb0000000bbbbbbbb00bbbbbbbbbbb0bbbbbbbbb00000000000000000000000000000000000
bbbbbbbbbbb0bbbbbbbbbbb00000bbbbbbbbbb0000000bbbbbbbbbbb0000bbbbbbbbbbb0bbbbbbbbbbb0bbbbbbbbbbb000000000000000000000000000000000
bbbbbbbbbbb0bbbbbbbbbbb0000bbbbbbbbbbbb00000bbbbbbbbbbbb000bbbbbbbbbbbb0bbbbbbbbbbb0bbbbbbbbbbb000000000000000000000000000000000
bbbb00000000bbbb000bbbbb00bbbbbb00bbbbbb000bbbbbb0000bbb00bbbbbb0000bbb0bbbb00000000bbbb000bbbbb00000000000000000000000000000000
bbbb00000000bbbb0000bbbb00bbbb000000bbbb000bbbb00000000b00bbbb00000000b0bbbb00000000bbbb0000bbbb00000000000000000000000000000000
bbbb00000000bbbb0000bbbb0bbbbb000000bbbbb0bbbbb0000000000bbbbb0000000000bbbb00000000bbbb0000bbbb00000000000000000000000000000000
bbbbbbbbbbb0bbbb000bbbbb0bbbb00000000bbbb0bbbb00000000000bbbb00000000000bbbbbbbbbbb0bbbb000bbbbb00000000000000000000000000000000
bbbbbbbbbbb0bbbbbbbbbbbb0bbbb00000000bbbb0bbbb00000000000bbbb00000000000bbbbbbbbbbb0bbbbbbbbbbbb00000000000000000000000000000000
bbbbbbbbbbb0bbbbbbbbbb000bbbb00000000bbbb0bbbb000000bbbb0bbbb000000bbbb0bbbbbbbbbbb0bbbbbbbbbb0000000000000000000000000000000000
bbbb00000000bbbbbbbbbb000bbbb00000000bbbb0bbbb000000bbbb0bbbb000000bbbb0bbbb00000000bbbbbbbbbb0000000000000000000000000000000000
bbbb00000000bbbb000bbbb00bbbbb000000bbbbb0bbbbb00000bbbb0bbbbb00000bbbb0bbbb00000000bbbb000bbbb000000000000000000000000000000000
bbbb00000000bbbb000bbbb000bbbb000000bbbb000bbbb00000bbbb00bbbb00000bbbb0bbbb00000000bbbb000bbbb000000000000000000000000000000000
bbbb00000000bbbb0000bbbb00bbbbbb00bbbbbb000bbbbbb000bbbb00bbbbbb000bbbb0bbbb00000000bbbb0000bbbb00000000000000000000000000000000
bbbb00000000bbbb0000bbbb000bbbbbbbbbbbb00000bbbbbbbbbbbb000bbbbbbbbbbbb0bbbbbbbbbbb0bbbb0000bbbb00000000000000000000000000000000
bbbb00000000bbbb00000bbbb000bbbbbbbbbb0000000bbbbbbbbbbb0000bbbbbbbbbbb0bbbbbbbbbbb0bbbb00000bbbb0000000000000000000000000000000
bbbb00000000bbbb00000bbbbb0000bbbbbb00000000000bbbbbbbb0000000bbbbbbbb00bbbbbbbbbbb0bbbb00000bbbbb000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700030000070000000007770000000000000000000000000000000000000000042200000042000000420000000042000000420000000420000000000000000
07000bccc000070000070000000700000000000000000000000000000000000000420039b3042000000420039b300420000004239b300442000044c9b304cc70
0030ccc3c3c30000007000ccc000700000000000000000000000000000000000000023939b9300000000023939b930000000023939b93000000023939b930000
000cccbc3ccc000000000c3c3c000000000000ccc000000000000000000000000982323bb3b9300000048323bb3b930000982323bb3b93000982323bb3b93000
300c3cc9ccbc00300000ccccccc3000000000ccccc0000000000000c00000000955223b93a33b3000095223b93a33b300955223b93a33b30955223b93a33b300
000cc3c3c3cc300000000c3ccc000000000000ccc0000000000000000000000045552b23b33b3300004552b23b33b330045552b23b33b33045552b23b33b3300
0030ccccbcc00000007000ccc0007000000000000000000000000000000000000582333b3b33b00000048333b3b33b0000582333b3b33b000582333b3b33b000
070000c9c030070000070000003700000000000000000000000000000000000000053223233b0000000053223233b000000053223233b00000053223233b0000
0070000300007000000000777000000000000000000000000000000000000000004200323204200000042003232004200000042323204442000044c23204cc70
00000377700000000000000000000000000000000000000000000000000000000042200000042000000420000000042000000420000000420000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000070000000007770000000000000000000000000000000000000000077000000077000000770000000770000007700000007700000000000000000
070000ccc00007000007000000070000000000000000000000000000000000000077003333077000000770333300770000007733330077700000777333007770
0000ccccccc00000007000ccc0007000000000000000000000000000000000000000333333330000000033333333000000003333333300000000333333330000
000ccccccccc000000000ccccc000000000000ccc000000000000000000000000003333333333000000333333333300000033333333330000003333333333000
000ccccccccc00000000ccccccc0000000000ccccc0000000000000c000000000033333333333300003333333333330000333333333333000033333333333300
000ccccccccc000000000ccccc000000000000ccc000000000000000000000000033333333333300003333333333330000333333333333000033333333333300
0000ccccccc00000007000ccc0007000000000000000000000000000000000000003333333333000000333333333300000033333333330000003333333333000
070000ccc00007000007000000070000000000000000000000000000000000000000333333330000000033333333000000003333333300000000333333330000
00700000000070000000007770000000000000000000000000000000000000000077003333077000000770333300770000007733330077700000777333007770
00000077700000000000000000000000000000000000000000000000000000000077000000077000000770000000770000007700000007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
a0a1a2a3a4a5a6a7a8a9aaabacbdbdbdbfbfbfbf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9babbbcbdbdbd0000bfbf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
868788898a8b8c8d8081828dbdbdbdbd0000bf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
969798999a9b9cbd909192bdbdbdbdbd0000bf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bdbdbdbdbdbdbdbdbdbdbdbdbdbdbd000000bfbf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a0000bfbf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4abf00bfbf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000bf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f8f9fafbfcfdbfbfbfbfbf00000000000000bf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f6f7bfbfbfbfbfbfbf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010410201877018750187301871515700167001670018700187501873018720187151d7001d7001d7001e7001872018710187101871519700187001770016700187101871018710187150b700097000370001700
010100003a550375503655034550315502f5500a5002c5502a55028550255502355022550205501e5501d5501b5501a550195500a50017550155501455013550115500f5500e5500c5500a55007550025500a500
010400001b372073721c37205302273721337228372003021b322073221c32205302333221f32234322003021b312073121c31205302333121f31234312003020f5120751210512053021b512075121c51200302
010100002177725777287772a7772c7772d7772e7672d7672c7672a7672875726757237571f7471b74716747127470f7370c7270972705727017270a71705717037170f7370c7270972705727017270a71705717
010300002d17731177341773617738177391773a16739167381673616734157321572f1572b14727147221471e1471b1371812715127111270d1270a11705117031170010722107201071d1071c1071c1071a107
0102002008047030370a0370f017130171601719017190271a0371a047180370b0370801708017090170a02711037130471204712047130471601717017150170603704047040570404704027080170301703037
010500001757417542175722453126571285510050000500175241751217522245112652128511005000050017730177021772024701267102850100500005001720017202172002420126200285010050000500
011000000a15700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000915700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000466006670086700a6700b6700d6700d6700e6700f6700e6600c6600c6600c6600a6600b6600a66008650086500865008650056500564004630026200262000610006100061000610006001c6001a600
00050000303762f3762d3762b366273762536623366213661f3661e3661d3661b36619356183561735616356153461334611346103360f3360e3260c3260a3260831606316043160230600306003061c3061a306
010814200c7710a771077710476101761007610a76108761057610376100761007610975107751047510275100741007410774105731027310172100721037210072100721017210072100711017110071100711
0109000018570185601855018540185301852018512185121c5701c5501c5401c5301c5201c5121b5701b5321c5701c5601c5501c5401c5301c5201c5121c5121d5701d5501d5401d5301d5201d5121e5701e532
010900001f5701f5501f5301f51217570175601755017540175301753017522175121750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500
01090000175701756017550175401753017520175121751218570185501854018530185201851219570195201a5701a5501a5301a512135701355013530135121a5701a5501a5301a5121b5701b5501b5301b512
010900001c5701c5601c5501c5401c5301c5201c5121c512000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0109000018570185601855018540185301852018510185121b5701b5501b5401b5301b5201b5121a5701a5201b5701b5601b5501b5401b5301b5201b5121b5121d5701d5501d5401d5301d5221d5121e5701e522
010900001f5701f5501f5301f51217570175601755017540175301753017522175120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000265702655026530265122557025550255302551224570245502453024512225702255022530225121f5701f5501f5301f5121a5701a5501a5301a5122257022550225302251221570215502153021512
010900001f5701f5601f5501f5401f5301f5201f5121f512000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070020233552333523325233151f3551f3351f3251f3151f3551f3351f3251f3151f3551f3351f3251f315233552333523325233151f3551f3351f3251f3151f3551f3351f3251f3151f3551f3351f3251f315
010700202435524335243252431524355243352432524315233552333523325233152335523335233252331521355213352132521315213552133521325213152131507305073050730521315083050830008100
010700202435524335243252431524355243352432524315233552333523325233152335523335233252331521355213352132521315213552133521325213152835528335283252831528355283352832528315
01070020263552633526325263152435524335243252431523355233352332523315213552133521325213151f3551f3351f3251f3151f3151f3051f3051f3051331505305053050530513315073050730507305
010700200705004100041000410013050071000710007100070500410004100041001305007100071000710007050041000410004100130500710007100071000705004100041000410013050071000710007100
010700200c050041000410004100180500710007100071000c050041000410004100180500710007100071000c050041000410004100180500710007100071000c05004100041000410018050071000710007100
010700200905004100041000410015050071000710007100090500410004100041001505007100071000710009050041000410004100150500710007100071000905004100041000410015050071000710007100
01070020130500410004100180001805007100071000710017050230000910009100150500b1000b1000b1001305004100041000410013000071000710007100150000910009100091001c0500b1001d0500b100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000c3750c3450c315293050c3250c3153030535305183751834518315293050c3250c315303053530513375133451331529305133251331530305353051337513345133152930513325133153030535305
01070000113751134511315073051132511315133051330511375113451131517305113251131513305133050c3750c3450c3151a3050c3250c31513305133051337513345133151730513325133151330513305
01070000153751534515315073051532515315133051330515375153451531517305153251531513305133051137511345113151a305113251131513305133051137511345113151730511325113151330513305
0107000021072210322307223032240722405224032240121f0721f0521f0321f0121c0721c0521c0321c0121d0721d0321c0721c032170721705217032170121807218052180321802218022180121801218015
010700001d355243052135524305183552430521355243051f3552430523355243051a3552830523355283051d35528305213552430518355243052135528305183552930513355293050c355293052930529305
010a00002970029700297002970029700297002970029700297002970029700297002970029700297002970029700297002970029700297002970029700297002970029700297002970028700287002970029700
010a00002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b7002b700
010a00002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002c7002e7002e7002e7002e7002e7002e7002e7002e700
010a00001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7001c7002370023700237002370023700237002370023700237002370023700237002370023700237002370021700217001f7001f700
010a00002470024700247002470024700247002470024700247002470024700247002470024700247002470024700247002470024700247002470024700247002470024700247002470023700237002370023700
010800001f7001f7001f5001f500183001e5001f5001f5001f5001f5001f5001f500183001830018300183001b3001b3001b3001b3001b3001b3001b3001b3001a3001a3001a3001a3001a3001a3001a3001a300
010700001f5701f5501f5301f515215702155021530215151f5701f5501f5301f5151c5701c5201d5501d5251f5701f52021550215201f5701f5201e5501e5201f5701f5501f5301f5151c5701c5201a5501a520
01070000185701855018530185101a5701a5501a5301a5101c5701c5501c5301c5101d5701d5501d5301d5101a5701a5501a5301a5101c5701c5501c5301c5101d5701d5501d5301d5101c5701d5001d5701d500
01070000185701855018530185101a5701a5501a5301a5101c5701c5501c5301c5101a5701a5501a5301a5101857018550185301851013570135501353013510185701855018530185101c5701d5001d5701d500
010700001c5721c5521c5321c5121d5721d5521d5321d5121c5721c5521c5321c51218572185221a5521a5221c5721c5221d5521d5221c5721c5221a5521a5221c5721c5521c5321c51218572185221555215522
010700001d0751d0551f0751f05521075210551d0751d0551f0751f055210752105523075230551f0751f0551c0751c0551a0751a05518075180551c0751c0551a0751a055180751805517075170551a0751a055
010700001d0751d0551f0751f05521075210551d0751d0551f0751f055210752105523075230551f0751f0552407524055240352401523075230552303523015210752105521035210151c5751c5551d5751d555
010c00001d4451d4051d4151d4051b4451b4051a4451a4051a4151a405164451640515425154051141511405184451840518415184052844529405264451d4050e4251c405184451c40522445214052d4351c405
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003c6350c3033c6150c3030c3030c3030c0730c3030c0730c3030c0730c3033c6250c3030c0730c3033c6350c3033c6150c3030c3030c3030c0730c3030c0730c3030c0730c3033c6350c3030c0730c303
010800201f5001f5001f5001f500185001e5001f5001f5001f5001f5001f5001f500185001850018500185001b5001b5001b5001b5001b5001b5001b5001b5001a5001a5001a5001a5001a5001a5001a5001a500
0108002016500165001650016500165001650016500165001650016500165001650018500185001850018500185001850018500185001b5001b5001b5001b5001a5001a5001a5001a50016500165001650016500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000185701854018520185101c5701c5401c5201c510135701354013520135101c5701c5401c5201c510185701854018520185101c5701c5401c5201c510135701354013520135101c5701c5401c5201c510
01090000175701754017520175101a5701a5401a5201a510115701154011520115101a5701a5401a5201a510175701754017520175101a5701a5401a5201a510115701154011520115101a5701a5401a5201a510
0109000013570135401352013510175701754017520175100e5700e5400e5200e5101757017540175201751013570135401352013510175701754017520175101157011540115201151017570175401752017510
01090000135701354013520135100b5700b5400b5200b5100e5700e5400e5200e510115701154011520115100c5700c5400c5200c51013570135401352013510155701554015520155100b5700b5400b5200b510
01090000185701854018520185101b5701b5401b5201b510135701354013520135101b5701b5401b5201b510185701854018520185101b5701b5401b5201b510135701354013520135101b5701b5401b5201b510
0109000013570135401352013510165701654016520165100e5700e5400e5200e5101657016540165201651013570135401352013510175701754017520175101157011540115201151017570175401752017510
01080020180501f030183201f0101f0501f0300c3201f0101f3001530018350103001f0501f030183101f0101f0501f0300c3501f0100c0001500018320100001f0501f030183501f0100c000150000c31015300
010800001f050220301f3202201022050220301f3202201022050220301d3502201024050240301d3102401024050240301d3502401024050240301d3202401024050240301d3402401024030240201832524010
011000000510005000051000500005100050000510005000051000500005100050000510005000031000400005100050000510005000051000500005100050000510005000051000500005100050000310004000
0106000030600000000c6000000018600000000c600000000c600000000c600000001c300343000c600000003060000000004000000018600000000c400000003c6000000000400000000c5001a5002850035500
__music__
01 14 18 43 44
00 15 19 43 44
00 16 1a 43 44
00 17 1b 43 44
01 1e 29 43 44
00 1f 2a 43 44
00 1e 29 43 44
00 1f 2b 43 44
00 1e 29 43 44
00 1f 2a 43 44
00 1e 29 43 44
00 1f 2b 43 44
00 20 2c 43 44
00 1e 2d 43 44
00 20 2c 43 44
02 1e 2e 43 44
00 21 22 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 36 0c 43 44
00 37 0d 43 44
00 38 0e 43 44
00 36 0f 43 44
00 3a 10 43 44
00 37 11 43 44
00 3b 12 43 44
02 36 13 43 44
00 41 42 43 44
00 41 42 43 44
00 36 37 43 44
00 41 42 43 44
00 3c 3d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
