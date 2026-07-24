pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- boulder run 0.9
-- 2019 paul hammond

-- debug
version="0.9"
--debug_stats=false

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

ts_titles=0
ts_select=1

s_levelstart=-1
s_levelstart2=-2
s_levelcomplete=-3
s_playing=0
s_timeup=1
s_gameover=2

e_none=-1
e_amoeba=0
e_boulder=1
e_butterfly=2
e_diamond=3
e_dirt=4
e_exit=5
e_explosion=8
e_firefly=9
e_magicwall=10
e_player=11
e_solid=12

sfx_dig=0
sfx_move=1
sfx_collect=2
sfx_crack=3
sfx_explode=4
sfx_whistle=5
sfx_whistle_end=6
sfx_expose=7
sfx_diamond=8
sfx_boulder=9
sfx_magicwall=10
sfx_amoeba=11
sfx_timeup=12

music_titles=2
music_select=32

-- constants
fps=60
screen_width=128
screen_height=128
tile_size=8

-- game state
game_state=gs_titles

-- titles
title_state=ts_titles
start_cave=1
start_level=1
start_map=nil
preview=nill
title_counter=0
title_x=0
title_text="2019-2020 pico-8 version based on the 1984 original by peter liepa  testing by finn and lucas. programming and music by paul hammond (select screen by peter liepa)  thanks to guerragames (title animation), www.boulder-dash.nl (information)  press q to quit mid-game"

-- game session
game=nil


function _init()
 -- dev
 --local s=tiles_to_string(52)
 --printh(s)
 --printh("#: "..#s)
 --stop()

 -- initialise
 reset_titles()
 start_map=maps:get(start_cave)
 
 -- enable kb
 poke(24365,1) 

end

function reset_titles()
 game_state=gs_titles
 title_state=ts_titles
 title_x=0
 
 -- clear sfx
 sfx(-1)
 
 -- music
 music(music_titles)
end

function reset_newgame()
 preview=nil
 game=session:new(0) 
 game:reset_newgame()
 game_state=gs_game
 
 -- stop music
 music(-1) 
end

function _update60()
 if game_state==gs_titles then
  update_titles() 
 else
  update_game()
 end
end

function update_game()
 game:update()
end

function update_titles()
 title_counter+=0.005

	if title_state==ts_titles then
		update_titles_titles() 	
	else
		update_titles_select()
	end
end

function update_titles_titles()
 -- scroll text
 title_x+=0.5
 if (title_x>150+#title_text*5) title_x=0
 
 -- input
 if btnp(5) then
  title_state=ts_select
  preview=nil
  
  -- music
  music(music_select)
 end
end

function update_titles_select()
 local changed=false
 
 -- change cave/ level
 if btnp(4) then
  reset_titles()
 elseif btnp(5) then
  reset_newgame()
 elseif btnp(1) then
  start_cave+=1
  if (start_cave>mapcount) start_cave=1
  changed=true
 elseif btnp(0) then
  start_cave-=1
  if (start_cave<1) start_cave=mapcount
  changed=true
 elseif btnp(2) then
  start_level+=1
  changed=true
 elseif btnp(3) then
  start_level-=1
  changed=true
 end
 
 if (start_level>#start_map.p) start_level=1
 if (start_level<1) start_level=#start_map.p
 
 -- update preview
 if (changed or preview==nil) then
  start_map=maps:get(start_cave)
  if (preview==nil) preview=session:new(-1)
  preview:reset_newgame(start_level)
 end
 preview:update()
end

function _draw()
 if game_state==gs_titles then
  draw_titles()
 else
  draw_game()
 end
 
-- if debug_stats then
--  rectfill(0,116,60,127,10)
--  ? "cpu: "..(100*(stat(1)/2)).."%",0,116,1
--  ? "mem: "..stat(0),0,122
-- end 
end

function draw_game()
 game:draw()
end

function draw_titles()
 cls(0)

	if title_state==ts_titles then
		draw_titles_titles() 	
	else
		draw_titles_select()
	end
end

function draw_titles_titles()
 -- background
 tbg()
 
 -- title
 drawlogo(20)
 
 -- other
 printc("press — to start",50+sin(title_counter*3)*3,7,false,0,-2,true)
 
 printc("controls",70,10,false,0,0,true)
 printc("— dig without moving",79,7,false,0,-2,true)
 printc("Ž give up",88,7,false,0,-2,true)
 if (title_counter<1) print(version,112,1,7)

 -- scroll text
 for y1=-1,1 do
  for x1=-1,1 do
   ? title_text,128-title_x+x1,120+y1,0
  end
 end
 ? title_text,128-title_x,120,14
end

function draw_titles_select()
 -- preview
 if (preview!=nil) preview:draw()
 pal()
 
 -- select menu
 ?"cave:"..start_map.n.." ‹‘",14,0,7
 ?start_map.n,34,0,14 
 ?"level:"..start_level.." ƒ”",68,0,7
 ?start_level,92,0,14
 
 camera(0,-40+sin(title_counter)*12)
 drawlogo(0)
 printc("select starting level",10,10,nil,nil,1,true)
 printc("— start   Ž back",18,7,nil,nil,-2,true)
 
 camera()
end

function drawlogo(y)
 pal(7,0)
 for y1=-1,1 do
  for x1=-1,1 do
   map(23,0,20+x1,y+y1,11,1)
  end
 end
 pal(7,11)
 map(23,0,20,y,11,1)
 pal()
end
-->8
-- classes

-- session
session={}

function session:new(idx)
 return init_obj({index=idx},self)
end

function session:reset_newgame()
 local s=self
 
 s.camspeed=60/fps
 s.camtrack=nil
 s.lives=3
 s.score=0 
 s.flash=false
 s.flashcount=0
 s.message=""
 s.white=0
 
 s.cave=start_cave
 s.level=start_level
 
 -- animations
 s.an_amoeba=create_anim(52,4,0.2)
 s.an_diamond=create_anim(36,4,0.2)
 s.an_firefly=create_anim(32,4,0.2)
 s.an_butterfly=create_anim(48,3,0.2)
 s.an_magicwall=create_anim(26,4,0.2)

 -- objects
 -- note: circular ref causes memory leak if recreating!
 s.input=input:new(s.index)
 if (s.player==nil) s.player=player:new(s)
 if (s.arena==nil) s.arena=arena:new(s)
 
 -- reset
 s.startintermission=s.arena.intermission
 s:reset_level(false,true)
end

function session:reset_level(progress,newgame)
 local s=self
 
 -- must progress?
 if (not newgame and s.arena.intermission) progress=true
 
 -- next cave
 if (progress) then
  s.cave+=1
  if s.cave>mapcount2 then
   s.cave=1
   s.level+=1
  end
 end

 -- reset
 s:initialiselevel()
 s:setstate(s_levelstart)
 if s.index==-1 then
  if s.camtrack!=nill then
   s.camx=s.camtrack.x*tile_size-(screen_width-tile_size)/2
   s.camy=s.camtrack.y*tile_size-(screen_height-tile_size)/2
  end
  s.arena:expose(true)
 else
  s.camx=s.arena.exit.x*tile_size-(screen_width-tile_size)/2
  s.camy=s.arena.exit.y*tile_size-(screen_height-tile_size)/2
 end
 if s.arena.intermission then
  s.message="intermission"
 else
  s.message="cave "..s.arena.name.."  level "..s.level  
 end
 if (not newgame) s.startintermission=false
  
 -- sfx
 sfx(-1)
 gsfx(sfx_expose)
end

function session:setstate(s,c)
 if (c==nil) c=0
 self.state=s
 self.statecount=c
end

function session:cameraupdate()
 local s=self 
 local arena=s.arena
 
 -- initialise
 local origx=s.camx
 local origy=s.camy
 local camspeed=s.camspeed

  -- find tracking object
 if s.camtrack!=nil then
  -- player dead?
  if s.camtrack.type!=e_player and arena.playercount!=0 then
   -- find next closest
   local mindist=9999
   local closest
   local tempdist
   for y=0,arena.height_tiles-1 do
    for x=0,arena.width_tiles-1 do
     local e2=arena:getentity(x,y)
     if e2.type==e_player then
      tempdist=sqrt(abs(x-s.camtrack.x)^2+abs(y-s.camtrack.y)^2)
      if mindist>tempdist then
       closest=e2
       mindist=tempdist
      end
     end
    end
   end
   if (closest!=nill) s.camtrack=closest
  end
 end
 
 -- track
 if s.camtrack!=nil then
  -- x
		local target=(s.camtrack.x*tile_size)-(screen_width/2)+(tile_size/2)
		if (abs(s.camx-target)>screen_width/5) s.cammovex=true
 
		if s.cammovex then
			if s.camx<target then
				s.camx+=s.camspeed
    if s.camx>=target then
     s.camx=target
     s.cammovex=false
    end
			elseif s.camx>target then
				s.camx-=s.camspeed
    if s.camx<=target then
     s.camx=target
     s.cammovex=false
    end
			end
		end
 
  -- y
		local target=(s.camtrack.y*tile_size)-(screen_height/2)+(tile_size/2)
		if (abs(s.camy-target)>screen_height/5) s.cammovey=true
 
		if s.cammovey then
			if s.camy<target then
				s.camy+=s.camspeed
    if s.camy>=target then
     s.camy=target
     s.cammovey=false
    end
			elseif s.camy>target then
				s.camy-=s.camspeed
    if s.camy<=target then
     s.camy=target
     s.cammovey=false
    end
			end
		end
 end
 
 -- finalise
 s:cameralimit()
 s.camstatic=(origx==s.camx and origy==s.camy)
end

function session:cameralimit()
 local s=self
 local arena=s.arena
 
 if arena.width<screen_width then
  s.camx=-(screen_width-arena.width)/2
 else
  s.camx=min(max(0,s.camx),arena.width-screen_width) 
 end
 if arena.height<screen_height-tile_size then
  s.camy=(-(screen_height-arena.height-tile_size)/2)
 else
  s.camy=min(max(0,s.camy),arena.height-screen_height+tile_size)
 end
end

function session:initialiselevel()
 local s=self
 
 -- reset map and camera
 s.arena:initialise(s.cave,s.level)

 -- other
 s.collected=0
 s.time=s.arena.mapdef.time
 s.player:reset()
end

function session:update()
 local s=self
 local arena=s.arena

 -- input
 s.input:update()
 
 -- arena
 arena:update()
 
 -- player
 s.player:update()
 
 -- camera
 s:cameraupdate()

 -- animations
 animate(s.an_amoeba)
 animate(s.an_diamond)
 animate(s.an_firefly)
 animate(s.an_butterfly)
 animate(s.an_magicwall)
 
 -- flash
 s.flashcount=(s.flashcount+1)%10
 s.flash=s.flashcount>4
 
 -- state
 if s.state==s_levelstart then
  -- level start (expose)
  arena:expose()
  s.statecount+=0.25
  if s.camstatic and arena.move then
   if (s.statecount<30) s.statecount=30
   if s.statecount>=50 then
    arena:expose(true)
    s:setstate(s_levelstart2)
   end
  end
 elseif s.state==s_levelstart2 then
  -- level start (waiting until safe)
  s.statecount+=0.25
  if s.index!=-1 and arena.move and arena.fallingcount==0 then
   s:setstate(s_playing)
   if s.index!=-1 then
    s.white=5
    gsfx(sfx_crack)
    arena:entitytoparticles(s.camtrack)
   end
   s.message=""
  end
 elseif arena.move and s.index!=-1 then
  if s.state==s_playing then
   -- playing
   if arena.playercount==0 then
    -- no players left
    if (arena.explodecount==0 and (arena.fallingcount==0 or s.lives>1)) s:lifelost()
   elseif s.time>0 then
    s.time-=0.1
    if s.time<=0 then
     s.time=0
     s.message="out of time"
     gsfx(sfx_timeup)
     s:setstate(s_timeup)
    end    
   end
  elseif s.state==s_gameover then
   -- game over
   s.statecount+=1
   if (s.statecount>=10) reset_titles()
  end
 elseif s.state==s_timeup then
  -- time up
   s.statecount+=1
   if (s.statecount==200) s:lifelost()
 elseif s.state==s_levelcomplete then
  -- complete
  if flr(s.time)>=1 and not arena.intermission then
   -- bonus
   s.time-=1
   s:scoreadd(1)
  else
   if s.statecount==0 and arena.intermission then
    -- bonus life?
    if s.lives<9 and not s.startintermission then
     s.message="bonus life"
     s:lifeadd()
    else
     s.message="no bonus life"
    end
   end
   
   -- sfx
   if (s.statecount==1) gsfx(sfx_whistle_end)

   s.statecount+=1
   if (s.statecount==120) s:reset_level(true)
  end
 end
 
 -- die button
 local f2=s.input.fire2_time
 if s.state==s_playing then
  s.message=""
  if f2==0 then
  elseif f2>=1 then
   s:lifelost()  
  else
   s.message="give up in "..flr(10-f2*9)
  end
 end
 
 -- quit?
 if (key_hit("q")) reset_titles()
end

function session:draw()
 local s=self
 
 -- initialise
 if s.white==0 then
  cls(0)
 else
  cls(7)
  s.white-=1
 end
 camera(s.camx,s.camy)
 
 -- draw
 clip(0,tile_size,128,128)
 s.arena:draw()
 clip()
 
 -- finalise
 camera(0,0)
 pal()
 
 -- score panel
 if s.index!=-1 then
  if s.message=="" then
   ? pads(s.arena.mapdef.diamondsrequired,3),0,1,10
   ? "",12,1,7
   ? pads(s.arena.mapdef.diamondpoints,3),16,1,7
   ? pad0(s.collected,2),32,1,10
   ? pads(flr(s.time),3),54,1,7
   ? "‡"..s.lives,76,1
   ? pad0(s.score,6),100,1,7
  else
   printc(s.message,1,7)
  end
 end
end

function session:scoreadd(v)
 self.score+=v
end

function session:lifeadd()
 self.lives+=1
end

function session:lifelost()
 local s=self
 
 if s.arena.intermission then
  s:reset_level(true)
 else
  s.lives-=1
  if s.lives==0 then
   s:setstate(s_gameover)
   s.message="game over"
  else
   s:reset_level(false)
  end
 end
end


-- arena
arena={}

function arena:new(s)
 return init_obj({session=s},self)
end

function arena:initialise(cave,level)
 local s=self
 
 -- initialise
 s.amoebacangrow=false
 s.amoebacount=0
 s.amoebaflag=0
 s.amoebatime=0
 s.exit=nill
 s.exitsopen=false
 s.explodecount=0
 s.fallingcount=0
 s.flashcount=0
 s.magicwallcount=0
 s.magicwallstate=0
 s.magicwalltime=0
 s.move=false
 s.movecount=0
 s.playercreated=false
 s.playercount=999
 s.pushcount=0
 
	-- get map def
 local md=mapdef:new()
 s.mapdef=md
 md:load(cave,level)
 
 -- initialise map
 s.width_tiles=md.width
 s.height_tiles=md.height
 s.width=s.width_tiles*tile_size
 s.height=s.height_tiles*tile_size
 s.speed=1
 s.time=md.time
 s.name=md.name
 s.intermission=md.intermission
 s.slowtime=md.slowtime

 -- create map entities
 s.entities={}
 s.updated={}
 for i=0,s.height_tiles-1 do s:parsetilerow(md.data[i],i) end

 -- finalise map 
 s.updated={}
 for y=0,s.height_tiles-1 do
  s.updated[y]={}
  for x=0,s.width_tiles-1 do
   s.updated[y][x]=false
  end
 end
 
 -- other
 s.particles={}
end

function arena:parsetilerow(data,row)
 local s=self
	local i,e
 
 s.entities[row]={}
	
 for i=1,s.mapdef.width do
  local t=sub(data,i,i)
  e=entity:new()
  e:init(t,i-1,row)
  
  -- save exit
  if (e.type==e_exit) s.exit=e

  -- set tracking entity
  if(t=="p") s.session.camtrack=e

  s.entities[row][i-1]=e
 end
end

function arena:update()
 local s=self
 
 -- initialise
 local p=s.session.player
	
 -- move counter
 s.movecount+=s.speed
 if s.movecount>=tile_size then
  s.move=true
  s.movecount-=tile_size
 else
  s.move=false
 end
 
 -- move?
 if s.move then
  -- initialise
  for y=0,s.height_tiles-1 do
   for x=0,s.width_tiles-1 do
    local e=s:getentity(x,y)
    e.oldx=x
    e.oldy=y
    e.softdig=false
    s.updated[y][x]=false
   end
  end
  s.amoebacangrow=false
  s.amoebacount=0
  s.explodecount=0
  s.fallingcount=0
  s.magicwallcount=0
  s.playercount=0
  s.playerpushed=false
  local oldamoebacount=s.amoebacount
  
  -- entities
  if s.time>0 then
   for y=0,s.height_tiles-1 do
    for x=0,s.width_tiles-1 do
     if not s.updated[y][x] then
      -- initialise
      local e=s:getentity(x,y)
    
      -- process
      if s.session.state!=s_playing and s.session.state!=s_levelstart2 then
       -- skip processing
      elseif e.type==e_boulder then
       -- boulder
       s:process_boulder(e)      
      elseif e.type==e_diamond then
       -- diamond
       s:process_boulder(e)
      elseif e.type==e_explosion then
       -- explosion
       s:process_explosion(e)
      elseif e.type==e_firefly then
       -- firefly
       s:process_firefly(e)
      elseif e.type==e_amoeba then
       -- amoeba
       s:process_amoeba(e)
      elseif e.type==e_butterfly then
       -- butterfly
       s:process_butterfly(e)
      elseif e.type==e_magicwall then
       -- magic wall
       s:process_magicwall(e)
      elseif e.type==e_player then
       -- player
       s:process_player(e)
      end
     end
    end
   end

   -- amoeba to boulders/ diamonds?
   if s.amoebaflag==0 and oldamoebacount==0 and s.amoebacount>0 and s.session.index!=-1 then
    -- start sfx
    gsfx(sfx_amoeba,3)
   end
   if s.amoebacount==0 then
    -- no test
   elseif s.amoebaflag!=0 then
    -- finished
   elseif not s.amoebacangrow then
    s.amoebaflag=2
    
    -- stop sfx
    sfx(-1) 
   elseif s.amoebacount>=(s.width_tiles*s.height_tiles)/4.4 then
    s.amoebaflag=1
    
    -- stop sfx
    sfx(-1)
   end
   
   -- amoeba timer
   if s.playercreated then
    s.amoebatime+=0.1
   end
   
   -- magic wall timer
   if s.playercreated and s.magicwallstate==1 then
    s.magicwalltime+=0.1
    if magicwallcount==0 or s.magicwalltime>=s.slowtime then
     s.magicwallstate=2
     
     -- stop sfx
     gsfx(-1,3)
    end
   end

   -- finalise
   if s.playerpushed then
    if (s.pushcount==10) s.pushcount=0
   else
    s.pushcount=0
   end
   p.lastdir=p.dir
   p.nextdir=d_none
  end
 end

 -- particles
 s:process_particles()
end

function arena:particlesadd(count,x,y,r,c1,c2)
 local s=self
 
 for i=1,count do
  local r2=0.5+rnd(2.5)
  local x1=x-r+rnd(r*2)
  local y1=y-r+rnd(r*2)
  local c  
  if rnd(6)<2 then
   c=c2
   r2=1
  else
   c=c1
  end
     
  add(s.particles,{x=x1,y=y1,r=r2,c=c,ttl=40})
 end
end

function arena:process_particles()
 local s=self
 
 for i=#s.particles,1,-1 do
  local p=s.particles[i]

  p.ttl-=1
  if p.ttl==0 or p.r<0.5 then
   del(s.particles,p)
  else
   if (p.r>0.5) p.r-=0.09
  end
 end
end

function arena:draw()
 local s=self
 
 -- initialise
 local session=s.session
 
 -- palette
 pal(10,s.mapdef.col1)
 pal(4,s.mapdef.col2)
 pal(7,s.mapdef.col3)
 
 -- particles
 for i=#s.particles,1,-1 do
  local p=s.particles[i]
  circfill(p.x,p.y,p.r,p.c)
 end
 
 -- find tile range to draw based on camera
 local startx=max(0,flr(session.camx/8))
 local starty=max(0,flr(session.camy/8))
 local endx=startx+17
 local endy=starty+16

 -- render (bottom to top so entities appear to drop from inside magic walls)
 for y=endy-1,starty,-1 do
  for x=startx,endx-1 do
   if x<s.width_tiles and y<s.height_tiles and x>-1 and y>-1 then
    local e=s:getentity(x,y)
    
    -- interpolate pos
    local tilex=e.x*tile_size tiley=8+e.y*tile_size
    local drawx=(e.oldx*tile_size)+((x-e.oldx)*s.movecount) 
    local drawy=8+(e.oldy*tile_size)+((y-e.oldy)*s.movecount)
    local frm=-1
    local flipx=false
    
    -- entity
    if not e.exposed then
     -- unexposed
     frm=8
    elseif e.type==e_none then
     -- blank
     frm=-1
    elseif e.type==e_boulder then
     -- boulder
     frm=6
    elseif e.type==e_diamond then
     -- diamond
     frm=session.an_diamond.sprite
    elseif e.type==e_dirt then
     -- dirt
     frm=5
    elseif e.type==e_exit then
     -- exit
     if s.exitsopen and session.flash then
      frm=14
     else
      frm=13
     end
    elseif e.type==e_explosion then
     -- explosion
     frm=40+e.count
    elseif e.type==e_firefly then
     -- firefly
     frm=session.an_firefly.sprite
    elseif e.type==e_amoeba then
     -- amoeba
     frm=session.an_amoeba.sprite
    elseif e.type==e_butterfly then
     -- butterfly
     frm=session.an_butterfly.sprite
    elseif e.type==e_player then
     -- player
     frm=session.player.anim.sprite
     flipx=session.player.anim.flipx
     
     -- soft dig?
     if e.softdig then
      spr(5,tilex,tiley)
      rectfill(drawx,drawy,drawx+tile_size-1,drawy+tile_size-1,0)
     end
    elseif e.type==e_solid then
     -- solid
     frm=8
    elseif e.type==e_wall then
     -- wall
     frm=7
    elseif e.type==e_magicwall then
     -- magic wall
     if s.magicwallstate==0 then
      -- dormant
      frm=7
     elseif s.magicwallstate==1 then
      -- active
      frm=session.an_magicwall.sprite
     elseif s.magicwallstate==2 then
      -- expired
      frm=30
     end
    else
     -- unknown
     frm=1
    end
    if (frm!=-1) spr(frm,drawx,drawy,1,1,flipx)
   end
  end
 end
end

function arena:openexits()
 local s=self

 for y=0,s.height_tiles-1 do
  for x=0,s.width_tiles-1 do
   local e=s:getentity(x,y)
   if (e.type==e_exit) e.solid=false
  end
 end
	
 s.exitsopen=true
 s.session.white=5
 gsfx(sfx_crack)
end

function arena:process_boulder(e)
 local s=self
 
 -- checks
 if (e.y>=s.height_tiles-1) return
 
 if e.still then
  -- stationary
  if s:getentity(e.x,e.y+1).type==e_none then
   -- start fall
   e.still=false
   s:entitymove(e.x,e.y,e.x,e.y+1)
  elseif s:getentity(e.x,e.y+1).rounded and s:getentity(e.x,e.y+1).still then
   -- roll to one side?
   if s:getentity(e.x-1,e.y).type==e_none and s:getentity(e.x-1,e.y+1).type==e_none then
    -- left
    s:entitymove(e.x,e.y,e.x-1,e.y)
   elseif s:getentity(e.x+1,e.y).type==e_none and s:getentity(e.x+1,e.y+1).type==e_none then
    -- right
    s:entitymove(e.x,e.y,e.x+1,e.y)
   end
  end
 else
  -- currently falling
  if s:getentity(e.x,e.y+1).type==e_none then
   e.still=false
   s:entitymove(e.x,e.y,e.x,e.y+1)
  elseif s:getentity(e.x,e.y+1).explosive then
   e.still=true
   s:explode(s:getentity(e.x,e.y+1))
  else
   if s:getentity(e.x,e.y+1).type==e_magicwall then
    -- hit magic wall
    if s.magicwallstate==0 then
     -- dormant
     s.magicwallstate=1
     
     -- sfx
     gsfx(sfx_magicwall,3)     
    elseif s.magicwallstate==1 then
     -- active
     local e2=s:getentity(e.x,e.y+2)
     if e2.type==e_none then
      if e.type==e_boulder then
       e2:init("*")
      else
       e2:init("o")
      end
      e2.oldy-=1
      s:entityupdated(e2)
     end
     e:init(" ")     
    elseif s.magicwallstate==2 then
     -- expired
     e.still=true
    end
   else
    -- landed
    e.still=true
    if s:getentity(e.x,e.y+1).rounded and s:getentity(e.x,e.y+1).still then
      if s:getentity(e.x-1,e.y).type==e_none and s:getentity(e.x-1,e.y+1).type==e_none then
      -- can move left
      e.still=false
      s:entitymove(e.x,e.y,e.x-1,e.y)
     elseif s:getentity(e.x+1,e.y).type==e_none and s:getentity(e.x+1,e.y+1).type==e_none then
      -- can move right
      e.still=false
      s:entitymove(e.x,e.y,e.x+1,e.y)
     end
    end
    
    -- sfx
    if e.type==e_diamond then
     gsfx(sfx_diamond,flr(rnd(3))*2,2)
    else
     gsfx(sfx_boulder)
    end
   end
  end  
 end
 
 -- track falling count
 if (not e.still) s.fallingcount+=1
end

function arena:process_player(e)
 local s=self
 local session=s.session
 
 -- initialise
 local ok=true
 local magicmove=session.player.fire
	
		-- track player count
		s.playercount+=1
		e.dir=session.player.nextdir
		s.playercreated=true
				
  if e.dir!=d_none then
   -- find destination tile			
   local newx=e.x+xinc[e.dir]
   local newy=e.y+yinc[e.dir]
   local e2=s:getentity(newx,newy)
   
   -- push
   if e2.canpush and (e.dir==d_left or e.dir==d_right) and not s.updated[e2.y][e2.x] then
    if not s.playerpushed then
     s.pushcount+=1
     s.playerpushed=true
    end
    ok=s.pushcount<=8 and (s.pushcount%2)==0
    if ok then
     if s:getentity(e.x+xinc[e.dir]*2,e.y+yinc[e.dir]).type==e_none then
      s:entitymove(e.x+xinc[e.dir],e.y+yinc[e.dir],e.x+xinc[e.dir]*2,e.y+yinc[e.dir])
     else
      ok=false
     end
    end
   else
    ok=not e2.solid
   end
   
   if ok then
    -- new pos
    local newx=e.x+xinc[e.dir]
    local newy=e.y+yinc[e.dir]
    local newe=s:getentity(newx,newy)
    
    -- dig sfx
    if newe.type==e_dirt then
     gsfx(sfx_dig)
    else
     gsfx(sfx_move)
    end
    
    -- collect diamond
    if newe.type==e_diamond then
     session.collected+=1     
     if session.collected>s.mapdef.diamondsrequired then
      session:scoreadd(s.mapdef.bonuspoints)
     else
      session:scoreadd(s.mapdef.diamondpoints)
     end
     gsfx(sfx_collect)
     
     -- open exits?
     if session.collected==s.mapdef.diamondsrequired then
      s:openexits()
     end
    end     
    
    -- don't actually move?
    if magicmove then
     -- particles
     s:entitytoparticles(e2)
     
     s:getentity(newx,newy):init(" ")
     newx = e.x
     newy = e.y
    end
    
    -- complete?
    if s:getentity(newx,newy).type==e_exit then
     session:setstate(s_levelcomplete)
     gsfx(sfx_whistle)
    end

    -- move
    s:entitymove(e.x,e.y,newx,newy)
   end
  end
		
 -- finalise
 session.player.dir=e.dir
 if (e.dir==d_left or e.dir==d_right) session.player.facing=e.dir
 if (e.dir!=d_none) s.playertilecounter=0
end

function arena:process_explosion(e)
 local s=self
 
 -- track
 s.explodecount+=1
 
 -- process
 e.count+=1
 if (e.count==6) e:init(e.to)
end

function arena:process_amoeba(e)
 local s=self
 
 -- initialise
 local range=0
 local movedir=0
 local cangrow=false
 	
		-- track
		s.amoebacount+=1
  
  -- doesn't use standard move so flag as updated
  s:entityupdated(e)
  
  -- not in select
  if (s.session.index==-1) return

  if s.amoebaflag==0 then
   -- can grow?
   for dir=1,4 do
    local e2=s:getentity(e.x+xinc[dir],e.y+yinc[dir])
    if e2.type==e_none or e2.type==e_dirt then
     cangrow=true
     if (movedir==0 or rnd(2)<1) movedir=dir
    end
   end
   
   -- expand?
   if cangrow then
    s.amoebacangrow=true
    if s.amoebatime>s.slowtime then
     range=4
    else
     range=70
    end
    if rnd(range)<1 then
     local e2=s:getentity(e.x+xinc[movedir],e.y+yinc[movedir])
     e2:init("a")
     s:entityupdated(e2)
    end
   end
  elseif s.amoebaflag==1 then
   -- to boulder
   e:init("o")
  elseif s.amoebaflag==2 then
   -- to diamond
   e:init("*")
  end
end

function arena:process_magicwall(e)
 local s=self
 	
		-- track
		s.magicwallcount+=1
  
  -- doesn't use standard move so flag as updated
  s:entityupdated(e)
end

function arena:process_firefly(e)
 local s=self
 
 -- initialise
	local trydir,newx,newy
	
		if s:isentitytouching(e.x,e.y,e_player) or s:isentitytouching(e.x,e.y,e_amoeba) then
			-- explode
			s:explode(e)
		else
			-- move
			newx=e.x
			newy=e.y
			trydir=e.dir-1
   if (trydir==0) trydir=4
			
   if s:getentity(e.x+xinc[trydir],e.y+yinc[trydir]).type==e_none then
				e.dir=trydir
    if s:getentity(e.x+xinc[e.dir],e.y+yinc[e.dir]).type==e_none then
					newx=e.x+xinc[e.dir]
					newy=e.y+yinc[e.dir]
				end
			end
   if s:getentity(e.x+xinc[e.dir],e.y+yinc[e.dir]).type==e_none then
				newx=e.x+xinc[e.dir]
				newy=e.y+yinc[e.dir]
			else
				e.dir+=1
    if (e.dir==5) e.dir=1
			end
			
			s:entitymove(e.x,e.y,newx,newy)
		end
end

function arena:process_butterfly(e)
 local s=self
 
 -- initialise
	local trydir,newx,newy
	
	if s:isentitytouching(e.x,e.y,e_player) or s:isentitytouching(e.x,e.y,e_amoeba) then
			-- explode
			s:explode(e)
		else
			-- move
			newx=e.x
			newy=e.y
			trydir=e.dir+1
   if (trydir==5) trydir=1
			
   if s:getentity(e.x+xinc[trydir],e.y+yinc[trydir]).type==e_none then
				e.dir=trydir
    if s:getentity(e.x+xinc[e.dir],e.y+yinc[e.dir]).type==e_none then
					newx=e.x+xinc[e.dir]
					newy=e.y+yinc[e.dir]
				end
			end
   if s:getentity(e.x+xinc[e.dir],e.y+yinc[e.dir]).type==e_none then   
				newx=e.x+xinc[e.dir]
				newy=e.y+yinc[e.dir]
			else
				e.dir-=1
    if (e.dir==0) e.dir=4
			end
			
			s:entitymove(e.x,e.y,newx,newy)
		end
end

function arena:isentitytouching(x,y,t)
 local s=self
 
 return (y>0 and s:getentity(x,y-1).type==t) or (y<s.height-1 and s:getentity(x,y+1).type==t) or (x>0 and s:getentity(x-1,y).type==t) or (x<s.width-1 and s:getentity(x+1,y).type==t)
end

function arena:entitymove(x,y,newx,newy)
 local s=self
 
 -- get entity
 local e=s:getentity(x,y)
 s:entityupdated(e)
 
 if newx!=x or newy!=y then
  -- get entity at new pos
  local e2=s:getentity(newx,newy)

  -- soft dig?
  e.softdig=(e.type==e_player and e2.type==e_dirt)
  
  -- move
  e.x=newx
  e.y=newy
  s:entityupdated(e)  
  s.entities[newy][newx]=e

  -- particles
  s:entitytoparticles(e2)
  
  -- blank old pos
  s.entities[y][x]=e2
  e2:init(" ",x,y)
 end
end

function arena:entitytoparticles(e)
 local s=self

 local px=(e.x+0.5)*tile_size
 local py=(e.y+1.5)*tile_size
 if e.type==e_dirt then
  s:particlesadd(12,px,py,tile_size/2,10,4)
 elseif e.type==e_diamond or e.type==e_player then
  s:particlesadd(6,px,py,tile_size/2.25,7,10)
 end
end

function arena:explode(e)
 local s=self

 -- don't explode?
 if (s.session.index==-1 or (e.type==e_player and s.session.state!=s_playing)) return
 
 -- register explosion
 s.explodecount=1
 
 -- what to explode to?
 m=" "
 if (e.type==e_butterfly) m="*"
 
 -- explode tiles
 for y=e.y-1,e.y+1 do
  for x=e.x-1,e.x+1 do
   if x>-1 and y>-1 and x<s.width and y<s.height then
    local e2=s:getentity(x,y)
    if not e2.indestructible then
     e2:init("!")
     e2.count=0
     e2.to=m
     s:entityupdated(e2)
    end
   end
  end
 end
 
 -- sfx
 gsfx(sfx_explode) 
end

function arena:expose(all)
 local s=self
 
 for y=0,s.height_tiles-1 do
  if all then
   for x=0,s.width_tiles-1 do
    s:getentity(x,y).exposed=true
   end
  else
   s:getentity(flr(rnd(s.width_tiles)),y).exposed=true
  end
 end
end

function arena:getentity(x,y)
 return self.entities[y][x]
end

function arena:entityupdated(e)
 self.updated[e.y][e.x]=true
end


-- map entity
entity={}

function entity:new()
 return init_obj({exposed=false},self)
end

function entity:init(m,x,y)
 local s=self
 
 if x!=nil then
  s.x=x
  s.oldx=x  
 end
 if y!=nil then
  s.y=y
  s.oldy=y
 end
 s.type=e_none
 s.dir=d_none
 s.indestructible=false
 s.solid=false
 s.canpush=false
 s.rounded=false
 s.explosive=false
 s.still=true
 s.softdig=false
 
 -- type-specific
 if m==" " then
  -- blank
	elseif m=="." then
  -- dirt
  s.type=e_dirt
 elseif m=="#" then
  -- solid
  s.type=e_solid
  s.solid=true
  s.indestructible=true
 elseif m=="*" then
  -- diamond
  s.type=e_diamond
  s.rounded=true
 elseif m=="&" then
  -- firefly
  s.type=e_firefly
  s.solid=true
		s.dir=d_left
		s.explosive=true
 elseif m=="x" then
  -- butterfly
  s.type=e_butterfly
  s.solid=true
		s.dir=d_right
		s.explosive=true
 elseif m=="a" then
  -- amoeba
  s.type=e_amoeba
  s.solid=true
  s.amoebaflag=0
 elseif m=="o" then
  -- boulder
		s.type=e_boulder
  s.solid=true
  s.canpush=true
  s.rounded=true
 elseif m=="e" then
  -- exit
		s.type=e_exit
  s.solid=true
  s.indestructible=true
 elseif m=="!" then
  -- explosion
		s.type=e_explosion
  s.solid=true
 elseif m=="p" or m=="q" then
  -- player (p=starting, q=other)
		s.type=e_player
  s.solid=true
  s.explosive=true
  if (m=="p") s.exposed=true
 elseif m=="w" then
  -- wall
		s.type=e_wall
  s.solid=true
  s.rounded=true
 elseif m=="m" then
  -- magic wall
		s.type=e_magicwall
  s.solid=true
 end
end


-- map def
mapdef={}

function mapdef:new()
 return init_obj({},self)
end

function mapdef:load(cave,level)
 local s=self
 
 -- get map
 local m=maps:get(cave)
 local p=nil
 if (level>#m.p) level=#m.p
 
 -- set properties
 if (m.i==nil) m.i=false
 s.intermission=m.i
 s.col1=m.c1
 s.col2=m.c2
 s.col3=m.c3
 s.name=m.n
 if (m.w==nil) m.w=40
 s.width=m.w
 if (m.h==nil) m.h=22
 s.height=m.h
 s.data={}
 s.randomseed=0

 -- parameters may be omitted to save space so assume previous
 for i=1,level do
  p=m.p[i] 
  if (p.t!=nil) s.time=p.t  
  if (p.d!=nil) s.diamondsrequired=p.d
  if (p.dp!=nil) s.diamondpoints=p.dp
  if (p.bp!=nil) s.bonuspoints=p.bp
  if (p.at!=nil) s.amoeba_time=p.at
  if (p.rs!=nil) s.randomseed=p.rs
  if (p.st!=nil) s.slowtime=p.st
 end

 -- decode
 s:data_init_blank()
 if (m.pat!=nil) s:data_from_pat(m.pat)
 
 -- random entities
 s:data_createrandom(m)
 
 -- finalise
 s:data_finalise()
end

function mapdef:data_createrandom(m)
 local s=self
 
		-- add random
		local r1=0
  local r2=s.randomseed
  local d=""
  local row=""
  local t=""
  for y=1,s.height-1 do
   row=""
   for x=0,s.width-1 do
    r1,r2=s:nextrandom(r1,r2)
    local obj="."
    local e=""
    local v=0
    
    if s.randomseed!=-1 then
     for i=0,3 do
      if i==0 then
       e=m.e1
       v=m.v1
      elseif i==1 then
       e=m.e2
       v=m.v2
      elseif i==2 then
       e=m.e3
       v=m.v3
      else
       e=m.e4
       v=m.v4
      end
      
      if e!=nil then
       if (r1<v) obj=e
      end
     end
    end
    
    -- replace tile?
    t=sub(s.data[y],x+1,x+1)
    if t=="-" then
     row=row..obj
    else
     row=row..t
    end
   end
   s.data[y]=row
  end
end

function mapdef:nextrandom(r1,r2)
 local tempr1,tempr2,r,c
	tempr1=band(r1,1)*128 
 tempr2=band(shr(r2,1),127)
	
	r=r2+band(r2,1)*128
	c=(r>255)
 r=band(r,255)
	
	r+=19
 if (c) r+=1
	c=(r>255)
	r2=band(r,255)
	
 r=r1+tempr1
 if (c) r=r+1 
	c=(r>255)
	r=band(r,255)
	
 r+=tempr2
 if (c) r+=1 
	r1=band(r,255)
 
 return r1,r2
end

function mapdef:data_init_blank()
 local s=self
 
 -- wall border (exclude exits)
 for y=0,s.height-1 do
  local row=""
  for x=0,s.width-1 do row=row.."-" end
  s.data[y]=row
 end
end

function mapdef:data_finalise()
 local s=self
 
 -- wall border (exclude exits)
 for y=0,s.height-1 do
  for x=0,s.width-1 do
   if y==0 or y==s.height-1 or x==0 or x==s.width-1 then
    local t=sub(s.data[y],x+1,x+1)
    if (t!="e") s.data[y]=sub(s.data[y],0,x).."#"..sub(s.data[y],x+2)
   end
  end
 end
end

function mapdef:data_from_pat(pat)
 local s=self
 
 -- parse
 local pos=1
 local p=""
 local d=""
 local dat={}
 local c=""
 local draw=false
 repeat
  c=sub(pat,pos,pos)
  if c=="|" then
   if (d!="") add(dat,d)
   draw=true
  elseif pos==#pat then
   d=d..c
   if (d!="") add(dat,d)
   draw=true
  elseif c>="0" and c<="9" then
   d=d..c  
  elseif c=="," then
    add(dat,d)
    d=""
  else
   if p=="" then
    p=c
   else
    add(dat,c)
   end
  end
  
   -- draw
  if draw then
   -- entries 2 to 5 will always be numbers, only 6 may be a character
   numify(dat,2,4)
   
   if p=="h" then
    -- horizonal line
    s:data_setxy(dat[2],dat[3],dat[1],dat[4])
   elseif p=="v" then
    -- vertical line
    s:data_setxy(dat[2],dat[3],dat[1],1,dat[4])
   elseif p=="\\" then
    -- diagonal (down-right)
    for i=0,dat[4]-1 do s:data_setxy(dat[2]+i,dat[3]+i,dat[1]) end
   elseif p=="/" then
    -- diagonal (down-left)
    for i=0,dat[4]-1 do s:data_setxy(dat[2]-i,dat[3]+i,dat[1]) end
   elseif p=="c" then
    -- single entity
    s:data_setxy(dat[2],dat[3],dat[1])
   elseif p=="!" then
    -- outline rectangle or square
    if (dat[5]==nil) dat[5]=dat[4]
    s:data_setxy(dat[2],dat[3],dat[1],dat[4])
    s:data_setxy(dat[2],dat[3]+dat[5]-1,dat[1],dat[4])
    s:data_setxy(dat[2],dat[3],dat[1],1,dat[5])
    s:data_setxy(dat[2]+dat[4]-1,dat[3],dat[1],1,dat[5])
 --   for y=0,tonum(dat[5])-1 do
 --    s:data_setxy(tonum(dat[2]),tonum(dat[3])+y,dat[1])
 --    s:data_setxy(tonum(dat[2])+tonum(dat[4])-1,tonum(dat[3])+y,dat[1])
 --   end
 --   for x=0,tonum(dat[4])-1 do
 --    s:data_setxy(tonum(dat[2])+x,tonum(dat[3]),dat[1])
 --    s:data_setxy(tonum(dat[2])+x,tonum(dat[3])+tonum(dat[5])-1,dat[1])
 --   end
   elseif p=="r" then
    -- rectangular block
    s:data_setxy(dat[2],dat[3],dat[1],dat[4],dat[5])
    if (dat[6]!=nil) s:data_setxy(dat[2]+1,dat[3]+1,dat[6],dat[4]-2,dat[5]-2)
--    for y=0,dat[5]-1 do 
--     for x=0,dat[4]-1 do
--      s:data_setxy(dat[2]+x,dat[3]+y,dat[1])
--      if dat[6]!=nil and x!=0 and x!=dat[4]-1 and y!=0 and y!=dat[5]-1 then
--       -- fill (if different from outline)
--       s:data_setxy(dat[2]+x,dat[3]+y,dat[6])
--      end
--     end
--    end
   elseif p=="d" then
    -- duplicate rectangular block
    local copies=(#dat-4)/2
    for c=0,copies-1 do
     for y=0,dat[4]-1 do 
      for x=0,dat[3]-1 do
       s:data_setxy(tonum(dat[5+c*2])+x,tonum(dat[6+c*2])+y,s:data_getxy(dat[1]+x,dat[2]+y))
      end
     end
    end
   end
   
   -- reset
   draw=false
   p=""
   d=""
   dat={}   
  end
  
  pos+=1  
 until pos>#pat
end

function mapdef:data_getxy(x,y)
 return sub(self.data[y],x+1,x+1)
end

function mapdef:data_setxy(x,y,m,w,h)
 local s=self
 
 -- can also specify width and height
 if(w==nil) w=1
 if(h==nil) h=1
 
 for y1=y,y+h-1,1 do
  if y1>=0 and y1<s.height then
   local row=s.data[y1]
   for x1=x,x+w-1,1 do
    if (x1>=0 and x1<s.width) row=sub(row,1,x1)..m..sub(row,x1+2)
   end
   s.data[y1]=row
  end
 end
end


-- player
player={}

function player:new(s)
 return init_obj({session=s},self)
end

function player:reset()
 local s=self
 
 s.facing=d_right
 s.fire=false
 s.dir=d_none
 s.lastdir=d_none
 s.nextdir=d_none
 s.anim=create_anim(20,6,0.5) s.anim.sprite=16
end

function player:update()
 local s=self
 
 -- initialise
 local session=s.session
 local i=session.input
 local arena=session.arena
 
 -- input disabled?
 if (session.index!=-1 and session.state==s_playing) then
  -- control smoothing (i.e., if player is still and presses a direction, don't ignore it if its not move time)
  if s.lastdir==d_none and i.dir!=d_none then
   s.nextdir=i.dir
   s.lastdir=-99
  elseif s.lastdir==-99 then
   -- next move already established
  else
   s.nextdir=i.dir
  end
  
  s.fire=i.fire
 end

 -- animate
 local a=s.anim

 if session.index!=-1 and (session.state==s_levelstart or session.state==s_levelstart2) then
  -- safe
  if session.flash then
   a.sprite=14
  else
   a.sprite=13
  end
 elseif s.dir==d_none and s.session.state!=s_levelcomplete then
  -- still
  if (a.sprite>18) a.sprite=16
  if arena.move then
   if (rnd(16)<=1) a.sprite=17 else a.sprite=16  
  end
 else
  -- running
  animate(a)  
  a.flipx=(s.facing==d_right)
 end
end
-->8
-- helper
function numify(a,x,l)
 for i=0,l-1 do
  a[x+i]=tonum(a[x+i])
 end
end

function key_hit(k)
 return stat(30) and stat(31)==k
end

function gsfx(s,c)
 if (game_state==gs_game) sfx(s,c)
end

function init_obj(o,self)
 setmetatable(o,self)
 self.__index=self
 return o
end

function create_anim(st,len,sp,flx)
 return {i=st,l=len,s=sp,sprite=st,flipx=flx}
end

function animate(a)
	if(a.c==nil) a.c=0
 a.sprite=a.i+a.c
 a.c=(a.c+a.s)%a.l
end

function pad0(n,l)
 local s="0000000000"..n
 return sub(s,#s-l+1)
end

function pads(n,l)
 local s="          "..n
 return sub(s,#s-l+1)
end

function printc(s,y,c,bg,bgc,offx,shad)
 local x=64-#s*2
 if (offx!=nil) x+=offx
 if shad then
  for y1=-1,1 do
   for x1=-1,1 do
    ? s,x+x1,y+y1,0
   end
  end
 end
	if (bg) rectfill(x-1,y-1,#s*4+x-1,y+5,bgc)
	? s,x,y,c
end


-- input
input={}

function input:new(idx)
 return init_obj({index=idx,fire2_time=0},self)
end

function input:update()
 local s=self
 
 s.up=btn(2)
 s.down=btn(3)
 s.left=btn(0)
 s.right=btn(1)
 s.fire=btn(5)
 s.fire2=btn(4)
 if s.fire2 then
  s.fire2_time+=1/fps
 else
  s.fire2_time=0
 end
 s.fire_hit=btnp(5)
 
 s.dir=d_none
 if (s.up) s.dir=d_up
 if (s.down) s.dir=d_down
 if (s.left) s.dir=d_left
 if (s.right) s.dir=d_right
end

-->8
-- serialisation

designer="0123456789abcdefghijklmnopqrstuvwxyz!@#$%^&*(){}[]<>.,:;~?+=-_|`"
tokens="pqe#.ow*&- xam  "
layout=tokens.."hvrc\\/d         0123456789,|   !"

function map_from_tiles(name,y)
 local m={n=name,i=false,w=40,h=22,p={}}
 local x=0
 local i=0
 local c=0
 local v=""
 local mn=""
 local count=0
 local s=""
 
 -- intermission?
 m.i=sub(name,1,1)=="x"
 
 -- header
 --  colours
 for i=1,3 do
  m["c"..i]=mget(x+i-1,y)-64
 end
 --  random
 i=1 count=1
 repeat
  c=mget(x+2+i,y)
  if c==124 or c<112 then
  	if mn!="" then
  		m["e"..count]=mn
  		m["v"..count]=tonum(v)
  	 count+=1
  	end
  	if (c!=124) mn=sub(tokens,c-79,c-79)
  	v=""
  elseif c>=112 then
   v=v..(c-112)
  end
   i+=1
 until c==124 or i==20
 
 -- layout
 m.pat=""
 i=0
 local y2=0
 repeat
  c=mget(x+i,y+1+y2)
  if c==125 then
  	-- line continue
  	y2+=1
  	i=80
  else
   s=sub(layout,c-79,c-79)
   i+=1
   m.pat=m.pat..s
  end
 until c==124 or i==128
 
 -- level
 local level=1
 i=0
 repeat
  c=mget(x+i,y+2)
  v=""  
  if c==124 then
   break
		elseif c==125 then
			level+=1
			i+=1
		else
   for count=1,3 do v=v..(mget(x+i+count,y+2)-112) end
   
   if (m.p[level]==nil) m.p[level]={}
   local p=m.p[level]
   v=tonum(v)
			
			if c==94 then
			 m.w=v
			elseif c==95 then
			 m.h=v
   elseif c==104 then
   	p.t=v
   elseif c==105 then
   	p.dp=v
   elseif c==106 then
   	p.bp=v
   elseif c==107 then
   	p.d=v
   elseif c==108 then
   	p.rs=v
   elseif c==109 then
   	p.st=v
   end
   
   i+=4
  end
 until i>=127

 return m
end

--function tiles_to_string(y)
-- local s=""
-- local splitx=0
-- 
--	for ln=0,2 do
--	 for x=0,128 do
--	  local t=mget(x+splitx,y+ln)-63
--	  if t<1 then
--	   -- split?
--	   if (ln<2 or splitx!=0) break
--	   if mget(79,y+ln)!=0 then
--	    s=s.."'"
--	    splitx=79-x
--	   end
--	  else
--	   s=s..sub(designer,t,t)
--	  end
--	 end
--	 s=s.."/"
--	end
--	
--	return s
--end

function string_to_tiles(s)
	-- clear
	for y=0,2 do
	 for x=0,127 do
	  mset(x,52+y,0)
	 end
	end
	
	local y=52
	local x=0
	for i=1,#s do
	 local c=sub(s,i,i)
	 if c=="/" then
	  -- new line
	 	y+=1
	 	x=0
	 	if (y>54 and i<#s) break
	 elseif c=="'" then
	  -- split
	  x=80
	  mset(79,y,125)
	 else
	 	for j=1,#designer do
	 	 if sub(designer,j,j)==c then
	 	  mset(x,y,63+j)
	 	  break
	 	 end
	 	end
	 	x+=1
	 end
	end
end

function map_from_string(name,s)
 string_to_tiles(s)
 return map_from_tiles(name,52)
end
-->8
-- maps
-- ref: https://codeincomplete.com/posts/javascript-boulderdash/decoded_cave_data.pdf

maps={
 data={
  -- debug
  --"db",52,
  
  -- classic
  "a",0,
  "b",4,
  "c",8,
  "d",12,
  "x1","d27/yq]+]+]>+]<=zg>+>=zl;+<=zk;+>=zr;+]<=zi]>+]<-/%[][*[[:^[>[u[],v[].-/",

  "e",20,
  "f",24,
  "g",28,
  "h",32,
  "x2","6d7/yk]+]+]>+].=!l]+>+:=@l]<+>+:=!n]+,+,=@n]<+,+,=!l]+:+,=@l]<+:+,=!o<+>+,=zg]+.=zi]<+.-/%[][*[][^[][u[],v[].-/",
  
  "i",40,
  "j",44,
  "k",48,
  "l","5f7q[:[l[,[n[[?-/zg>+]~=zi>?+<[=xm][+>+]~=#][+>+]+]~+].+>+]~+>+<<+>=wm<+.+]]=wm<+~+]]=wm<+]<+],=wm<+]:+]]=yk>[+<+.+.+q=zo><+>=_/%]~[*[]?^[<[&[[[-/",
  "x3","147/yq]+]+]>+]<=zg:+<=zi]>+;=yo][+[?+.+.=wn]+]<+?-/%[<[*[[?^[][u[],v[].-/",
  
  "m",60,
  "n",56,
  "o",36,
  "p",16,
  "x4","14f/yl[~+<+>+<=wt~+,+>=wt~+?+>=yq~+][+>+<=yq~+[:+>+>=!l,+:+>=zi:+?=zg<+<-/%[<[*[[:^[>[u[],v[].)[[>-/",
  
  -- puzzle
  "p1","98f/zg]+[]=zi[]+]<=xm;+]+]<=wm]+:+]>=zl,+]=ym~+.+<+<=zh~+,=zn:+]=zn]>+]=zl]<+]=ym]<+.+<+<=zh]>+,=wt[?+?+>=wl[?+;+>=ym,+]]+<+<=_/%[.,*[[.^[<[&[[[u[],v[].)[[,-'zh:+]<-/",
  "p2","28f/zg]+[;=zi[;+]]=xj;+]+[[~=zh]>+;=yk<+>+,+,+q=zr.+:=zl.+<=#<+<+,+,+[~+<=wj]+~+]>=zh;+]<=yq,+?+,+]=zm;+]>=zo;+?=xq.+?+>=xq][+?+>-/%[:[*[]~^[,[&[[[u[],v[],-/",
  "p3","936/wg.+]+:=zi[[+[]=xl<+<+;=zm<+[?=zn<+][=#<+<+]+?+.+<+:+<+~+<+][+<+]<+<=xj<+]<+,=xq]+]?+<=#]+]<+<+?+>+]<+,+]<+;+]<+?+]<+]]+]<=_/%[:[*[]~^[,[&[[[u[],v[<>)[[]-'wt]+]~+]>=zo]>+]~-/"
 }
}
mapcount=#maps.data/2
mapcount2=mapcount-3

function maps:get(s)
 local n=maps.data[s*2-1]
 local d=maps.data[s*2]
 
 if type(d)=="string" then
  return map_from_string(n,d) 
 else
  return map_from_tiles(n,d) 
 end
end
-->8
-- title background

_t=0
_c=0
_p={4,5,6,0,0,0,5,4,13,7,0,0,0,5,4,9,7,0,0,0,5,2,9,7,0,0,0,5,4,14,7,0,0,0,5,13,14,15,0,0,0,5,2,12,4,0,0,0,5,1,9,11,0,0,0,5}
_pl=#_p

function tbg()
 _t+=0.075
 _c+=0.02
 
 for y=-64,64,3 do
  local d=y%6/3*3
  local y2=y*y
  for x=-68+d,64,5 do
   local a=atan2(x,y)
   local r=sqrt(x*x+y2)/80
   local c=3*r*cos(r/2+a*2-_t/10)+2*sin(_t/16)
   c=_p[1+flr(_c+c%3)%_pl]
   circfill(x+64,y+64,2,c)
  end
 end
end
__gfx__
0000000000000000000000000000000000000000aa0aaaaa00777700077707774444444400000000000000000000000000000000444444444444444400000000
000000000bbbbb000bbbbb0000bbbb000bbbb000aaaa44aa077a7770000000004004400400bbbbb00bbbbb000b0000b00b000b00400440044000000400bbbb00
007007000b0000b00b0000b00b0000b00b000b00aaaaaaaa44a4a77777707770470447040b0000000b0000b00b0000b00b00b00047044704400000040b0000b0
000770000b0000b00bbbbb000b0000000b0000b0a4aaaaaa44444477000000004444444400bbbb000b0000b00b0000b00bbb000044444444400000040b000000
000770000bbbbb000b0000b00b0000000b0000b0aaaaaa0a40444a470777077744444444000000b00bbbbb000b0000b00b00b00044444444400000040b00bbb0
007007000b0000000b0000b00b0000b00b000b00aaaa4aa0440444a700000000400440040b0000b00b0000000b0000b00b000b0040044004400000040b0000b0
000000000b0000000bbbbb0000bbbb000bbbb000aaaaaaaa04404440777077704704470400bbbb000b00000000bbbb000b0000b0470447044000000400bbbb00
00000000000000000000000000000000000000000aaaaaaa00444400000000004444444400000000000000000000000000000000444444444444444400000000
00400400004004000000000000000000000440000004400000000000000000000000000000044000077707770777077707770777077707770444044400000000
04044040044444400bbbbbb00bbbbbb0044044000440440000044000000440000004400004404400040a040aa040a0400a040a0440a040a0000000000b0000b0
04444440044444400b0000000b00000004444400044444000440440004404400044044000444440077707770777077707770777077707770444044400b0000b0
00044000000440000bbbbb000bbbbb000004400000044000044444000444440004444400000440000a040a0440a040a0040a040aa040a040000000000bbbbbb0
07077070070770700b0000000b00000007077000070770000007700000077000000770000707700007770777077707770777077707770777044404440b0000b0
00044000000440000b0000000b000000000440000004400000744000000440000074400000044000040a040aa040a0400a040a0440a040a0000000000b0000b0
00a77a0000a77a000bbbbbb00b0000000aa77aa000aaaa70000aa0000007a000000aa00000aaaa7077707770777077707770777077707770444044400b0000b0
077007700770077000000000000000007700000707700070007707000007700000770700077000700a040a0440a040a0040a040aa040a0400000000000000000
4444444400000000444444447777777700077000000770000007700000077000000000000000000000044000a004400400044000000000000000000000000000
40000004044444404777777474444447007aa70000700700007777000074470000000000000000000a000040000000000a000040000000000bbbbb00000000b0
404444040477774047444474740000470744447007aaaa7007000070077777700000000000a0040000a77a0000a77a000000000000a00400000b0000000000b0
4047740404744740474004747404404777777777744444477aaaaaa770000007000a40000a077040a070070aa070070aa00aa00a0004a000000b0000000000b0
404774040474474047400474740440477000000777777777744444477aaaaaa70004a000040770a0a070070aa070070aa00aa00a000a4000000b00000b0000b0
4044440404777740474444747400004707aaaa700700007007777770074444700000000000400a0000a77a0000a77a000000000000400a00000b00000b0000b0
4000000404444440477777747444444700744700007aa70000700700007777000000000000000000040000a000000000040000a0000000000bbbbb0000bbbb00
44444444000000004444444477777777000770000007700000077000000770000000000000000000000440004004400a00044000000000000000000000000000
70000007070000700070070007000007477404777740004777400047774000470777777000007700007000070770000007777700000777707777770000000000
a700007a0a7007a000a00a000770007704774774077444777774047707744477777000770070077007700077777000007770077000700077770007700b000000
4470074404700740004004000777007747777777777777777777477777777777077000770770007707700077077000000770007707700000770007700b000000
7777777707777770007777000777707777777774777777777777777777777777077077000770007707700077077000000770007707777700770007000b000000
0007700000077000000770000770777747777740477777447777777447777744077000770770007707700077077000000770007707700000770770000b000000
aa7007aa0a7007a000a00a000770077704777400047774004774474004777400077000700077007000770070077000000770007000770007770077700b000000
4700007404700740004004000700007004777740477747447740047447774744077777000007770000077700077777770777770000077770700007000bbbbbb0
70000007070000700070070000000000477747747774047777400047777404770000000000000000000000000000000000000000000000000000000000000000
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
cc9cc9cc000990009999999999999999dd0ddddd003333000333033300033000999999996d0d0d0d00000000030000303390009303330333000000000a000000
c9c99c9c099099009177711990099009dddd99dd0399993000000000003dd30093333339d6d090d0000000000d3003d003399933090d090d0a000a00aaa00000
c999999c099999009175551993099309dddddddd99d999933330333003999930939999390d0d0d0d000000000930039033333333333033300a0a0a000a000000
ccc99ccc000990009177711999999999d9dddddd99999993000000003333333393900939d0d0d0d0000aa00003333330333333330d090d0900a0a0000a00a0a0
c3c33c3c030330009175551999999999dddddd0d90999d930333033330000003939009390d0d0d0d00000000000330009333339903330333000000000a00aaa0
ccc99ccc000990009177711990099009dddd9dd09999999d0000000003dddd3093999939d0d090d0000000000d3003d009333900090d090d0a0000a00a00a0a0
ccd33dcc0dd33dd09115551993099309dddddddd0909d9903330333000399300933333390d0d0d0d00000000093003909333939933303330aaaaaaaaaaa00000
cddccddc3300000399999999999999990ddddddd00999900000000000003300099999999d0d0d0d00000000003000030333909330d090d090a0000a00a000000
000000000007700000000000000000007000000000000007777777000000000000aaaa000000000000000000000a00000aa000000aa000000333033300000000
000007000007700077777777000000000700000000000070760607000b0000b00a0000a0000000000000000000aaa000a0000000a0000000000000000b0000b0
000007700007700076060607000000000070000000000700706067000bb00bb0a00a000a00000000000000a00a0aaa00a00a000009800000330333030bb000b0
777777770007700070606067000770000007000000007000760607570b0bb0b0a00a000a00a0000000a00aaa00a0a000a0a0a00a00800aa00aaa00000b0b00b0
777777770007700076060607000770000000700000070000777777070b0000b0a00aaa0a0aaa00000aaa00a00aaa000000a0a00aa980a00aa090a3330b00b0b0
0000077007777770706060670000000000000707707000000050b0b70b0000b0a000000aaaaaa000aaaaa000aaaaa000000000aa0080900aa099a0000b000bb0
000007000077770077777777000000000000007777000000007b0b070b0000b00a0000a00aaa00000aaa00000aaa000000000a0a0088800aa000a3030b0000b0
000000000007700000000000000000000000077777700000007777770000000000aaaa0000a0000000a0000000a00000000000aa00000aa00aaa000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee00000000e00eeeeeee0f000000000000000
00bbbb0000bb000000bbb00000bbbb000000b0000bbbbbb000bbbb000bbbbbb000bbbb0000bbbb0000000000000ee0000000ee00eeeeeee0f000000007777770
0b000bb00b0b00000b000b000b0000b0000bb0000b0000000b000000000000b00b0000b00b0000b000000000000ee000000eee00eeeeeee0f00f000007000070
0b00b0b0000b000000000b000000bb0000b0b0000bbbbb000bbbbb0000000b0000bbbb000b0000b000000000000ee00000eeee00eeeeeee000f0f00007000070
0b0b00b0000b000000bbb000000000b00b00b000000000b00b0000b00000b0000b0000b000bbbbb000000000000ee00000eeee00eeeeeee000f0f0f007000070
0bb000b0000b00000b0000000b0000b00bbbbbb00b0000b00b0000b0000b00000b0000b0000000b00000b000000ee000000eee00eeeeeee000000fff07000070
00bbbb000bbbbb000bbbbb0000bbbb000000b00000bbbb0000bbbb00000b000000bbbb0000bbbb000000b000000ee0000000ee00eeeeeee0000000f007777770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000ee00000000e00eeeeeee0000000f000000000
24c444a50797075507570785070727c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06d51747a71757a787b736052707a717b7066517a757a71727b7066517a71737a71727b706652787a737a71717b706652787a71717a71717b7367547a747b736
753747a727b736753747a71707b736751727a71747b736a51747a71767b736751797a71767b706451747a71737a787b7362507a737c700000000000000000000
86172707d6072707b607170796071707a6072707c6070717d786171707b6071757c6070737d786170707b6072707c6070747d786079707c6070757d786078707
c6070767c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1757f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44d474a51707075507870785070727c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36052707a717b736252707a72707b7466527a727a71707b756652747a727a71707b706451727a71727a737b706d51727a71737a737c700000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86172707b607175796071707b6072707d6070787c6070717d7b6072707c6072797d7b6072707c6073707d7b6072757c6073717d7b6073707c607372786174707
c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
97e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44d4745527470775172707c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
266557a787a71737a71737a7a5b736451727a787b726652757a787a71737a71737a7a5b736453717a787b706651777a71767a797b706a51777a71777a797b736
0577a71707b7362587a71707c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86175707b607775796070757a6071707c6170707d7c6173777d786173707b6078707c6174707d7b6078757c6275717d786172707b6079707c6075717c7000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1707f200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14447400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36051737a717b736253797a72707b7266517a727a72717a71777a745b7467567a737a71757b756752707a737a71757b726a567a797a71757a737b7068567a717
07a71757b7f76577a747a71737b7f76597a767a797b7f7651717a787a757b7266537a747a737a71747a785b7167547a71747a747b736a547a747b7d700000000
86175707b607172796072757a6076707d786173707d786172707d786171707d786170707c7000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d736a51737a727b736a51737a747b736a51737a767b736a51737a787c70000000000000000000000000000000000000000
1717c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
544474a5170707558707850727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16651707a717a797b716652707a717a797b716653707a717a797b7166597a71727a797b706651727a71737a71777b7066557a797a797b706651757a797a797b7
06652757a797a797b756653787a777a71717b736052707a71787b736253787a71757b7367547a717b736751747a717b736752747a717b736753747a717b7d700
86172707b6070767a607070796075707d7c6070747d786175707c6170727d7c6175717d786274707c6170707c700000000000000000000000000000000000000
000000000000000000000000000000d7367547a72707b736753757a72717c7000000000000000000000000000000000000000000000000000000000000000000
402120b0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94346400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060547a717a767b736250707a70717b7165527a727a777b7366527a70797b7367527a71707b76627a727a717a797a747a727a767a727a787a727a71707a727a7
1727a727b7163527a71727a757b716a517a71797a727b76617a71727a727a797a737a71727a757a71727a777a71727a797a71727a71717a71727b7d700000000
86076707b607178796075707a6070707e5071757f5072737d6070717c70000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d706d517a71787a71737b736851737a71787c7000000000000000000000000000000000000000000000000000000000000
1747f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54947400000057000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
26451707a787a71737a71737a7a5b746b51717a797a71717b716451727a787a71727b716451747a787a71727b716451767a787a71727b716451787a787a71727
b716452707a787a71727b716452727a787a71727b7360537a717b736253797a71787b736852727a757b736552727a767b7d70000000000000000000000000000
86175707b607370796071707a6072707d786174757b6073757d786174707b6074707d786173757b6074727d786173707b6074757c70000000000000000000000
000000000000000000000000000000d7662727a757a717a727a72747a757a72767a757a72787a757a73707a757a73727a757c700000000000000000000000000
17377600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1494b455074707c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36051787a717b736251707a717b736c52707a717b7066557a71767a73707b706b557a71777a73707b7065557a71787a73707b7264557a71797a73707a727c700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86176707d6174707b607570796070757a6070787c6070707d786175757b6075757c6070717d786175707b6076707c6070727d786174757b6077707c6070737d7
86174707b6078707c6070747c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4445465a70767055707570577070797c0000000000000038393a3b3c3d3e003e3a3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6350737a727b635273787a71767b6056717a777a73707b6056797a71747a73707c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
687175706b707170697071706a7072706c7071707d687077706c7071717d687077706c7071727d687074706c7071737d687073706c7071747c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444d475a7076705570757057707079587070727c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
635071787a71797b635271787a72707b6056717a767a73787b6056717a71737a73787b6156787a717a72707b615671767a717a72707b615672747a717a72707b615673727a717a72707b605a717a737a73787b605a717a797a73787b605a717a71767a73787b615a72707a717a72707c00000000000000000000000000000000
687175706b707170697072706a7075706c7070737d687171706c7070706b7071727d687077706b7070796c7070717d6b7071736c7078777d6b7071736c7078787c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4449475671707055707570577070797c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6350737a727b635273797a71787c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
687175706b707274697071756a7072706c7070707d687170706b7072736c7075707d687079706b7072746c7075747d687078706b7072736c7075727d687077706b7072716c7075757c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
424947557072707c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6350717a717b635273787a72707b6254787a787a747a747b625a797a797a727a727b635b797a797b66787a787a747a747a71767a787a72737a787a73727a787c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
687172706b707376697070756a7071756c7070707d687170706c7171707d687078706c7171727d687076706c7171757d687075706c7171797c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71760a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444e4f557075707c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6350717a717b635273797a727b6254787a71777a747a747a5a7b635871707a71787b66787a71777a747a747a71767a71777a72747a71777a73727a71777b7f5670777a787a767a787b7f5671757a787a767a787b605d777a787a767b605d71757a787a767c000000000000000000000000000000000000000000000000000000
687175706b707172697071706a7072706c7070716d7072707d6b7071756c7172707d6b7071756c7172797d6b7071756c7172767d6b7071726c7172737c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7512000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444e477c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6350717a717b635273787a72707b625a787a787a737a737b635871707a787b6357797a71707b66787a787a737a737a71767a787a72747a787a73727a787a787a71747a71767a71747a72747a71747a73727a71747c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
687175706b707074697075706a7079707d687172706b7070757d687079706b7070767d687076706b7070777d687073706b7070787c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7613000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d4e4f557075707c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6352737a71787b635073787a71787b6056717a717a73787b625a717a727a73787a727b615471707a717a737b615472797a717a737b6357737a737b6358747a737b635873757a737b635773767a737b625971717a717a71787a737b66717a717a73787a737a717a747a717a777a717a71707a717a71737b7d0000000000000000
687175706b707074697074706a7076706c7070707d687172706b7070766c7072707d687170706b7070776c7072717d687079706b7070786c7072727d687078706c7072737c000000000000000000007d6259717a71747a73787a737c000000000000000000000000000000000000000000000000000000000000000000000000
770f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444e4b5a71707055707470587070727c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6056717a757a71727b605672787a737a71717b605c72707a72707a727b635072707a717b635273797a757b6357747a747b6357747a71727b6357747a72707b635773747a727b635773747a71707b635773747a72707c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
687172706b707175697071706a7072706c7070726d7077757d6b7072706c7070777d6b7072756c7070787d6c7071707d7070797c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
781f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100003b667326372c62726617206171c61716627126370d6470865705667036670365701617006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607
000100000264001620016100160001600016000160001600016000160001600016000160001600016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000101001a7571975718757177571575713757117570f7570d7570c7570c7570c7570c7570d7570e7570f75710757127571475717757187571a7571570715707147071570716707187071a7071a7071c7071c707
000200003f6703c66039660376502f640226200b61007610056100361002610026100161004600046000460003600036000360000000000000000000000000000000000000000000000000000000000000000000
000300003f6513e6513e6513d6513b651396413664134641306312d63127631216211c62117621116110b61106611036110161100601006010060100601006010060100601006010060100601006010060100601
001000003f5513d5513b55139551375513555133551315512f5512d5512b55129551275512555123551215511f5511d5511b55119551175511555113551105510d5510a551085510555102551005010050100501
00020000255512555125551000012e5512e5512e55101501000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000900203f5203b5202e520315203e520395202a520325203a5202a5203f550335502d55033550285503d550355502b5503d5503055029550325502b5503f550305503a5503b550305503b550315502955034550
001000003e520395203c520375203a520365200050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200003e660376602f660276601f6601a6601766013660116600f6400e6400c6400b6400b640096400864007640066400563004630036300263002620016200162001610016100161001610000000000000000
000600203f7253b7252e725317253e725397252a725327253a7252a7253f755337552d75533755287553d755357552b7553d7553075529755327552b7553f755307553a7553b755307553b755317552975534755
010a0020055560655602556045560a55608556025560655604556025560955602556065560a55607556055560955606556085560b556065560355606556095560555609556025560755608556065560a55607556
010f0000105751051500000000000c5750c5150000000000105651051500000000000c5650c5150000000000105551051500000000000c5550c5150000000000105451051500000000000c5450c5150000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110002018035180151c0351c0151f0351f0151c0351c03522035220151c0351c0151f0351f0151c0351c0151e0351e0152203522015250352501522035220152803528015220352201525035250152203522015
0110000018035180151c0351c0151f0351f0151c0351c03522035220151c0351c0151f0351f0151c0351c01518035180151c0351c0151f0351f0151c0351c03522035220151c0351c0151f0351f0151c0351c015
011000001d0351d01521035210152403524015210352101528035280152103521015240352401521035210151d0351d0152103521015240352401521035210152803528015210352101524035240152103521015
01100000180450c015000151c01518035000450c0151c03522045160150a0151f0350a015130150a0151c035180450c015000151c01518035000150c0151c03522045160150a0151f0350a015130450a0151c035
011000200c0533f205332053f205246350c0533f305000000c053000003f4053f205246353f205000000c0530c0533f3053f20500000246350c0530c6003f4050c053000003f3050c053246350c0533f4050c053
011000001d0451101505015210151d035050451101521035270451b0150f015240350f015180150f015210351d0451101505015210151d035050151101521035270451b0150f015240350f015180450f01521035
011000000c0533f205332053f205246350c0533f305000000c053000003f4053f205246353f205000000c0530c0533f3050c05300000246350c0530c6003f4050c053000003f3052464524625246452464524645
0110000000700007000070000700007000070000700007000070000700007000070000700007000070000700187001c7001a7001d7001b7001e7001c7001f700187501c7201a7501d7201b7501e7201c7501f720
011000201f4522145221432224622244222432214522142224471244502441522462224422241021462214223045230445304252e4522e4452e4252d4522d4422145221432214252245222435224252345223435
0110000024455244252441522455224252241521455214151f4551f4251f4151d4551d4251d4151c4551c415185501c5201a5501d5201b5501e5201c5501f5200c522105220e522115220f522125121051213512
011000201f5601e5301f5001f560215001f51009600095001f560005001f510215002156000500215100050022560245302450022560225002251000500225102156000500215101d5001d560005001d51000500
01100000280501b5201a520195201852017520165201552014520135201252011520105200f5100e5100d5101c5301b5101a510195101851017510165101551014510135101251011510105100f5100e5100d510
0110000024575245452452522575225452252521575215351f5751f5451f5251d5751d5451d5251c5751c5351d5621c5321c5221d5621d5321d5221c5621c5522256222532225222156221532215222456224532
011000002b4622b4422b42529462294422942528452284352b4552b4352b42529455294352942528455284252b4622b4422b42529462294422942528452284352b4552b4352b4252945529435294252845528425
011000002b4552b4252b41529455294252941528455284152645526425264152445524425244152245522415185501c5201a5501d5201b5501e5201c5501f5200c522105220e522115220f522125121051213512
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c4351640518435164050c4351640518435154050c4351540518435154050c4350e405184350e405124350e4051e4350e405124350e4051e4350e405124350e4051e4350e405124350e4051e4350e405
011000000c4351640518435164050c4351640518435154050c4351540518435154050c4350e405184350e4050c4351640518435164050c4351640518435154050c4351540518435154050c4350e405184350e405
01100000114352e4001d4352e400114352e4001d4352d400114352e4001d4352e400114352e4001d4352d400114352e4001d4352e400114352e4001d4352d400114352e4001d4352e400114352e4001d4352d400
011000000c7350c715007152e7000c7352e70000725007150c7350c705007152e7000c7350c703007150070511735117150571526700117352670005715267001173511705057152670011735267000572505715
011000000c7350c715007152e7000c7352e70000725007150c7350c705007152e7000c7352e70000715007050c7350c715007152e7000c7352e70000725007150c7350c705007152e7000c7352e7000071500705
010b000000140000002404000000001400000029040000000c140000002404000000001400000029040000000a1400000028040000000a140000002904000000161400000026040000000a140000002704000000
010b000024040000001f040000001c04000000180400000022040000001d040000001a040000000a14000000280400000024040000001f040000001c040000001d040000001a0400000016140000000a14000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b000018040180201c0401c0201f0401f02024040240201b0401b0201d0401d0201f0401f020260402602020040200202204022020240402402027040270202204022020290402902023040230202804028020
010b0000180401802024040240201f0401f0201a0401a020220402202026040260201a0401a0202204022020180401802024040240201f0401f0201a0401a0202004020020300403002024040240202004020020
010b000022040220202e0402e020110401102018040180201e0401e0202e0402e02022040220201e0401e0201f0401f0202304023020210402102024040240201d0401d0201d0401d02029040290201d0401d020
010b00002404024020240402402024040240202404024020240402402024040240202404024020240402402024040240202404024020240402402024040240202404024020240402402024040240202404024020
010b0000240402402028040280202404024020290402902024040240202804028020240402402029040290202404024020280402802024040240202904029020220402202026040260202e0402e0202704027020
010b00002404024020300403002024040240202e0402e02024040240202d0402d02024040240202b0402b02022040220202e0402e02022040220202e0402e0202e0402e020290402902022040220202e0402e020
010b00002404024020280402802024040240202904029020240402402028040280202404024020290402902024040240202804028020240402402029040290202e0402e02026040260202e0402e0202704027020
010b0000280402802024040240201f0401f0201c0401c020260402602022040220201d0401d02016040160202b0402b020280402802024040240201f0401f020260402602022040220201d0401d0201604016020
010b00000014000100131400010018040001001b040001001614000100151400010016140001001d14000100141400010014140001002004000100141400010016140001001d0400010015140001001b04000100
010b000000140001000014000100001400010000140001000a140001000a140001000a140001000a14000100001400010000140001000014000100001400c100161400c100161400c100161400c1001614000100
010b00000a140000000a140000000a140000000a14000000121400000012140000001214000000121400000007140000001314000000071400000013140000000514000000051400000000140000000014000000
010b000000150000000015000000001500000000150000000c150000000c15000000001500000000150000000a150000000a150000000a150000000a15000000161500000016150000000a150000000a15000000
010b00000014000000180400000000140000001d040000000c140000001804000000001400000018040000000a1400000018040000000a140000001804000000161400000022040000000a140000002204000000
010b00000014000000001400000000140000002b040000000c140000000c14000000001400000028040000000a140000000a140000000a140000000a14000000161400000016140000000a140000000a14000000
__music__
03 41 18 43 44
01 41 42 43 44
00 14 2b 43 44
00 15 2c 43 44
01 14 18 1e 28
00 15 18 1f 29
00 14 18 1e 28
00 15 18 1f 29
00 16 18 20 2a
00 15 18 1f 29
00 16 18 20 2a
00 15 18 43 29
00 14 18 1e 28
00 15 18 1f 29
00 14 18 1e 28
00 15 18 1f 29
00 16 18 20 2a
00 15 18 1f 29
00 16 18 20 2a
00 15 1a 43 29
00 17 18 1c 29
00 17 18 1d 29
00 19 18 21 2a
02 17 1a 22 29
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 32 3a 43 44
00 33 3b 43 44
00 34 3c 43 44
00 35 3d 43 44
00 36 3e 43 44
00 37 3f 43 44
00 38 2d 43 44
02 39 2e 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
