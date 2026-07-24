pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--close to the edge
--felipe larral

function _init() logo_init() end
t=0
function menu_init()
music(12)
	_update=menu_update
	_draw=menu_draw
	 init_parallax()
	
end

function menu_update()
fade_in()
	t+=1
	if (btnp(—)) c1_init()
	if (btnp(Ž)) c1_init()
	if (btnp(ƒ)) c1h_init()
--	if (btnp(—,1)) l1c_init()	
	 update_parallax()
end

function menu_draw()
	
	
	cls(15) 
	
	map(1,2)
	draw_parallax()
	
	print("close",55,15,0)
	print("close",54,15,8)
	
		print("to",59,25,0)
print("to",60,25,8)
	
print("the edge",49,35,0)
print("the edge",48,35,8)
	
-----------------------------
	
--print("ride",56,15,0)
	--print("ride",57,15,8)
	
	--	print("the",58,24,0)
--	print("the",57,24,8)
	
	--	print("lizard",53,33,0)
--	print("lizard",52,33,8)


print("press Ž or —",36,88,7)
if t/15%2 >1 then

	print("press Ž or —",36,88,13)
   end 
end


-->8
--level 1

function l1_init()
cls()
music(20)
	_update=l1_update
	_draw=l1_draw
 
 init_parallax()
 player= {
 sp=1,
 x=20,--420, 320
 y=62,
 w=5,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.2
 friction=0.9
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l1_update()
fade_in()

 update_parallax()
 player_update()
player_animate()
 cam_x=player.x-64+(player.w/2)
 if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
 camera(cam_x,0)
 
 if (btnp(—,1)) l1c_init()	
end

function l1_draw()
cls(12)



   
   --rectfill(0,0,128,128,0)
  --map(0,48,0,-64,16,16)
   --map(0,48,0,64,16,16)
    draw_parallax()
    map(0,0)
spr(player.sp,player.x,player.y,1,1,player.flp)    
end

------------coop----------

function l1c_init()
music(20)
cls()
	_update=l1c_update
	_draw=l1c_draw
 
 init_parallax()
 player= {
 sp=1,
 x=20,--420, 320
 y=62,
 w=5,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 
 player2= {
 sp=1,
 x=48,--420, 320
 y=64,
 w=5,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.2
 friction=0.9
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l1c_update()
fade_in()
 update_parallax()
 player_update()
player_animate()
 player2_update()
player2_animate()
 cam_x=player.x-64+(player.w/2)
 if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
 camera(cam_x,0)
end

function l1c_draw()
cls(12)



   
   --rectfill(0,0,128,128,0)
  --map(0,48,0,-64,16,16)
   --map(0,48,0,64,16,16)
    draw_parallax()
    map(0,0)
spr(player.sp,player.x,player.y,1,1,player.flp) 
spr(player2.sp,player2.x,player2.y,1,1,player2.flp)       
end


--level 1 hard----------

function l1h_init()
cls()
music(20)
	_update=l1h_update
	_draw=l1h_draw
 
 init_parallax()
 playerh= {
 sp=1,
 x=20,--420, 320
 y=62,
 w=5,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.2
 friction=0.9
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l1h_update()
fade_in()

 update_parallax()
 playerh_update()
playerh_animate()
 cam_x=playerh.x-64+(playerh.w/2)
 if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
 camera(cam_x,0)
 
 
end

function l1h_draw()
cls(12)



   
   --rectfill(0,0,128,128,0)
  --map(0,48,0,-64,16,16)
   --map(0,48,0,64,16,16)
    draw_parallax()
    map(0,0)
spr(playerh.sp,playerh.x,playerh.y,1,1,playerh.flp)    
end

-->8
--colission

function collide_map(obj,aim,flag)
  
  local x=obj.x    local y=obj.y
  local w=obj.w    local h=obj.h

  local x1=0    local y1=0
  local x2=0    local y2=0

  if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

  elseif aim=="right" then
   x1=x+w    y1=y
   x2=x+w+1  y2=y+h-1

  elseif aim=="up" then
   x1=x+1    y1=y-1
   x2=x+w-1  y2=y

  elseif aim=="down" then
   x1=x      y1=y+h
   x2=x+w    y2=y+h
  end
 
 x1/=8    y1/=8
	x2/=8    y2/=8
	
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
    return true
	else
    return false
	end
end
-->8
--player

function player_update()
if collide_map(player,"down",2) then
  over1_init()
end

if collide_map(player,"down",6) then
  over2_init()
end

if collide_map(player,"down",7) then
  over3_init()
end

if collide_map(player,"up",3) then
  c2_init()
end

if collide_map(player,"down",3) then
  c2_init()
end

if collide_map(player,"right",3) then
  c2_init()
end


if collide_map(player,"down",4) then
  c3_init()
end

if collide_map(player,"up",4) then
  c3_init()
end

if collide_map(player,"right",4) then
  c3_init()
end

if collide_map(player,"right",5) then
 player.sp=24
  win_init()
  
end



  --physics
  player.dy+=gravity
  player.dx*=friction
  
  --controls
  if btn(‹) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
    
    
  end
  if btn(‘) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
    
  end
  --slide
  if player.running
  and not btn(‹)
  and not btn(‘)
  and not player.falling
  and not player.jumping then
    player.running=false
    player.sliding=true
  end

  --jump
  if btnp(—)
  and player.landed then
    player.dy-=player.boost
    player.landed=false
    sfx(1)
  end
  
  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false

    player.dy=limit_speed(player.dy,player.max_dy)

    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=((player.y+player.h+1)%8)-1
    end
  elseif player.dy<0 then
    player.jumping=true
    if collide_map(player,"up",1) then
      player.dy=0
    end
  end

  --check collision left and right
  if player.dx<0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"left",1) then
      player.dx=0
    end
  elseif player.dx>0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"right",1) then
      player.dx=0
    end
  end

  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end

  player.x+=player.dx
  player.y+=player.dy
  
  
  --limit player to map
  if player.x<map_start then
    player.x=map_start
  end
  if player.x>map_end-player.w then
    player.x=map_end-player.w
  end
 
end


function player_animate()
  if player.jumping then
    player.sp=7
  elseif player.falling then
    player.sp=8
  elseif player.sliding then
    player.sp=9
  elseif player.running then
    if time()-player.anim>.1 then
      player.anim=time()
      player.sp+=1
      if player.sp>6 then
        player.sp=3
      end
    end
  else --player idle
    if time()-player.anim>.3 then
      player.anim=time()
      player.sp+=1
      if player.sp>2 then
        player.sp=1
      end
    end
  end
end


--player 2-------------------

function player2_update()
if collide_map(player2,"down",2) then
  over1_init()
end

if collide_map(player2,"down",6) then
  over2_init()
end

if collide_map(player2,"down",7) then
  over3_init()
end

if collide_map(player2,"up",3) then
  c2_init()
end

if collide_map(player2,"down",3) then
  c2_init()
end

if collide_map(player2,"right",3) then
  c2_init()
end

if collide_map(player2,"down",4) then
  c3_init()
end

if collide_map(player2,"up",4) then
  c3_init()
end

if collide_map(player2,"right",4) then
  c3_init()
end

if collide_map(player2,"right",5) then
 player2.sp=24
  win_init()
  
end



  --physics
  player2.dy+=gravity
  player2.dx*=friction
  
  --controls
  if btn(‹,1) then
    player2.dx-=player2.acc
    player2.running=true
    player2.flp=true
    
    
  end
  if btn(‘,1) then
    player2.dx+=player2.acc
    player2.running=true
    player2.flp=false
    
  end
  --slide
  if player2.running
  and not btn(‹,1)
  and not btn(‘,1)
  and not player2.falling
  and not player2.jumping then
    player2.running=false
    player2.sliding=true
  end

  --jump
  if btnp(—,1)
  and player2.landed then
    player2.dy-=player2.boost
    player2.landed=false
    sfx(1)
  end
  
  --check collision up and down
  if player2.dy>0 then
    player2.falling=true
    player2.landed=false
    player2.jumping=false

    player2.dy=limit_speed(player2.dy,player2.max_dy)

    if collide_map(player2,"down",0) then
      player2.landed=true
      player2.falling=false
      player2.dy=0
      player2.y-=((player2.y+player2.h+1)%8)-1
    end
  elseif player2.dy<0 then
    player2.jumping=true
    if collide_map(player2,"up",1) then
      player2.dy=0
    end
  end

  --check collision left and right
  if player2.dx<0 then

    player2.dx=limit_speed(player2.dx,player2.max_dx)

    if collide_map(player2,"left",1) then
      player2.dx=0
    end
  elseif player2.dx>0 then

    player2.dx=limit_speed(player2.dx,player2.max_dx)

    if collide_map(player2,"right",1) then
      player2.dx=0
    end
  end

  --stop sliding
  if player2.sliding then
    if abs(player2.dx)<.2
    or player2.running then
      player2.dx=0
      player2.sliding=false
    end
  end

  player2.x+=player2.dx
  player2.y+=player2.dy
  
  
  --limit player to map
  if player2.x<map_start then
    player2.x=map_start
  end
  if player2.x>map_end-player2.w then
    player2.x=map_end-player2.w
  end
 
end


function player2_animate()
  if player2.jumping then
    player2.sp=7
  elseif player2.falling then
    player2.sp=8
  elseif player2.sliding then
    player2.sp=9
  elseif player2.running then
    if time()-player2.anim>.1 then
      player2.anim=time()
      player2.sp+=1
      if player2.sp>6 then
        player2.sp=3
      end
    end
  else --player idle
    if time()-player2.anim>.3 then
      player2.anim=time()
      player2.sp+=1
      if player2.sp>2 then
        player2.sp=1
      end
    end
  end
end



-------player hard mode-------


function playerh_update()
if collide_map(playerh,"down",2) then
  over1h_init()
end

if collide_map(playerh,"down",6) then
  over2h_init()
end

if collide_map(playerh,"down",7) then
  over3h_init()
end

if collide_map(playerh,"up",3) then
  c2h_init()
end

if collide_map(playerh,"down",3) then
  c2h_init()
end

if collide_map(playerh,"right",3) then
  c2h_init()
end


if collide_map(playerh,"down",4) then
  c3h_init()
end

if collide_map(playerh,"up",4) then
  c3h_init()
end

if collide_map(playerh,"right",4) then
  c3h_init()
end

if collide_map(playerh,"right",5) then
 playerh.sp=24
  win_init()
  
end



  --physics
  playerh.dy+=gravity
  playerh.dx*=friction
  
  --controls
  if btn(‹) then
    playerh.dx-=playerh.acc
    playerh.running=true
    playerh.flp=true
    
    
  end
  if btn(‘) then
    playerh.dx+=playerh.acc
    playerh.running=true
    playerh.flp=false
    
  end
  --slide
  if playerh.running
  and not btn(‹)
  and not btn(‘)
  and not playerh.falling
  and not playerh.jumping then
    playerh.running=false
    playerh.sliding=true
  end

  --jump
  if btnp(—)
  and playerh.landed then
    playerh.dy-=playerh.boost
    playerh.landed=false
    sfx(1)
  end
  
  --check collision up and down
  if playerh.dy>0 then
    playerh.falling=true
    playerh.landed=false
    playerh.jumping=false

    playerh.dy=limit_speed(playerh.dy,playerh.max_dy)

    if collide_map(playerh,"down",0) then
      playerh.landed=true
      playerh.falling=false
      playerh.dy=0
      playerh.y-=((playerh.y+playerh.h+1)%8)-1
    end
  elseif playerh.dy<0 then
    playerh.jumping=true
    if collide_map(playerh,"up",1) then
      playerh.dy=0
    end
  end

  --check collision left and right
  if playerh.dx<0 then

    playerh.dx=limit_speed(playerh.dx,playerh.max_dx)

    if collide_map(playerh,"left",1) then
      playerh.dx=0
    end
  elseif playerh.dx>0 then

    playerh.dx=limit_speed(playerh.dx,playerh.max_dx)

    if collide_map(playerh,"right",1) then
      playerh.dx=0
    end
  end

  --stop sliding
  if playerh.sliding then
    if abs(playerh.dx)<.2
    or playerh.running then
      playerh.dx=0
      playerh.sliding=false
    end
  end

  playerh.x+=playerh.dx
  playerh.y+=playerh.dy
  
  
  --limit player to map
  if playerh.x<map_start then
    playerh.x=map_start
  end
  if playerh.x>map_end-playerh.w then
    playerh.x=map_end-playerh.w
  end
 
end


function playerh_animate()
  if playerh.jumping then
    playerh.sp=7
  elseif playerh.falling then
    playerh.sp=8
  elseif playerh.sliding then
    playerh.sp=9
  elseif playerh.running then
    if time()-playerh.anim>.1 then
      playerh.anim=time()
      playerh.sp+=1
      if playerh.sp>6 then
        playerh.sp=3
      end
    end
  else --player idle
    if time()-playerh.anim>.3 then
      playerh.anim=time()
      playerh.sp+=1
      if playerh.sp>2 then
        playerh.sp=1
      end
    end
  end
end




--------------------------

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
-->8
--parallax
function init_parallax()
    --tables to hold map pieces
    map_bg={} --bg layer 1
    map_mg={}    --mg layer 2
    map_fg={} --fg layer 3
   
    --spawn initial map. index i
    --creates copy of map at right
    --of screen, ready to move into
    --view.
    for i=0,1 do
       -- level 1
        spawn_map(i*328,0,0.05)
        spawn_map(i*200,0,0.2)
        spawn_map(i*228,0,0.1)
        spawn_map(i*110,0,0.2)
        spawn_map(i*428,0,0.1)
         spawn_map(i*528,0,0.2)
          spawn_map(i*628,0,0.1)
          spawn_map(i*628,0,0.2)
           spawn_map(i*728,0,0.2)
            spawn_map(i*828,0,0.1)
            spawn_map(i*928,0,0.1)
            --level 2
            spawn_map(i*110,126,0.2)
            spawn_map(i*210,126,0.2)
            spawn_map(i*310,126,0.2)
             spawn_map(i*228,126,0.1)
            spawn_map(i*110,126,0.2)
           spawn_map(i*428,126,0.1)
            spawn_map(i*528,126,0.2)
             spawn_map(i*628,126,0.1)
            spawn_map(i*628,126,0.2)
             spawn_map(i*728,126,0.2)
            spawn_map(i*828,126,0.1)
            spawn_map(i*928,126,0.1)
     --level 3
     spawn_map(i*110,226,0.2)
      spawn_map(i*228,226,0.1)
     spawn_map(i*328,226,0.1)
     spawn_map(i*310,180,0.2)  
        spawn_map(i*110,226,0.2)
        spawn_map(i*428,226,0.1)
         spawn_map(i*528,226,0.2)
          spawn_map(i*628,226,0.1)
          spawn_map(i*628,226,0.2)
           spawn_map(i*728,226,0.2)
            spawn_map(i*828,226,0.1)
            spawn_map(i*928,226,0.1)
              spawn_map(i*450,256,0.05)
    end
end

function update_parallax()
    foreach(map_bg,update_map)
   foreach(map_mg,update_map)
    foreach(map_fg,update_map)
end

function draw_parallax()
        foreach(map_bg,draw_map)
        foreach(map_mg,draw_map)
        foreach(map_fg,draw_map)
end

function update_map(m)
    m.x-=m.l --move map to left
   
    --if map off edge of screen
    if m.x<-128 then
        if m.l==0.05 then
            del(map_bg,m) --delete map
        end
        if m.l==0.2 then
            del(map_mg,m) --delete map
        end
        if m.l==0.1 then
            del(map_fg,m)
        end
        --add new map to right
        spawn_map(16*8,0,m.l)
    end
end

function spawn_map(x,y,l)
    local m={}
    m.x=x
    m.y=y
    m.l=l
    --add map bit to correct layer
    if l==0.05 then
        add(map_bg,m)
    end
    if l==0.2 then
        add(map_mg,m)
    end
    if l==0.1 then
        add(map_fg,m)
    end
end

function draw_map(m)
    if m.l==0.05 then
        map(16,48,m.x,m.y,16*2,16)
    end
    if m.l==0.2 then
        map(0,48,m.x,m.y,16,16)
    end
    if m.l==0.1 then
        map(49,48,m.x,m.y,16,16)
    end
end
------- end of parallax --------
--------------------------------
-->8
--win/lose

function over1_init()

	music(0)
 _update=over1_update
 _draw=over1_draw

end


function over1_update()


	if (btnp(—)) l1_init()	
 if (btnp(—,1)) l1c_init()	
end



function over2_init()
	music(0)
 _update=over2_update
 _draw=over2_draw

end


function over2_update()


	if (btnp(—)) l2_init()	
if (btnp(—,1)) l2c_init()	
end

function over3_init()
	music(0)
 _update=over3_update
 _draw=over3_draw

end


function over3_update()


	if (btnp(—)) l3_init()
	if (btnp(—,1)) l3c_init()		

end








function over1_draw()

camera()


--rectfill(16,56,109,72,7)
	print("game over",45,3,1)
	print("press —",47,10,1)
		print("game over",44,3,7)
	print("press —",46,10,7)
	
end

function over2_draw()

camera()


--rectfill(16,56,109,72,7)
	print("game over",44,6,6)
	print("press —",46,13,6)
		print("game over",44,5,13)
	print("press —",46,12,13)
	
end

function over3_draw()

camera()


--rectfill(16,56,109,72,7)
	print("game over",44,6,0)
	print("press —",46,13,0)
		print("game over",44,5,7)
	print("press —",46,12,7)
	
end


function win_init()
music(25)
	cls(7)
 _update=win_update
 _draw=win_draw

end


function win_update()


	if (btn(Ž)) logo_init()	

end


function win_draw()

cls(12) 
	camera()
	map(112,32)
--rectfill(16,56,109,72,7)
	print("the end",14,18,2)
	print("thanks for playing!",8,6,8)

end


-->8
--level 2

function l2_init()
music(2)
cls()
	_update=l2_update
	_draw=l2_draw
 
 init_parallax()
 player= {
 sp=1,
 x=20,
 y=167,
 w=4,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.5,
 boost=4,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.25
 friction=0.83
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l2_update()
fade_in()
 update_parallax()
 player_update()
player_animate()
 cam2_x=player.x-64+(player.w/2)
 if cam2_x<map_start then
     cam2_x=map_start
  end
  if cam2_x>map_end-128 then
     cam2_x=map_end-128
  end
 camera(cam2_x,126)
 if (btnp(—,1)) l2c_init()	
end

function l2_draw()
cls(15)

  
map(0,0)
      

 
 
spr(player.sp,player.x,player.y,1,1,player.flp)  
 draw_parallax()  
 rectfill(0,0,1024,127,15)
end

----------level 2 coop------------------

function l2c_init()
music(2)
cls()
	_update=l2c_update
	_draw=l2c_draw
 
 init_parallax()
 player= {
 sp=1,
 x=20,
 y=167,
 w=4,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.5,
 boost=4,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 
 player2= {
 sp=1,
 x=48,
 y=197,
 w=4,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.5,
 boost=4,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.25
 friction=0.83
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l2c_update()
fade_in()
 update_parallax()
 player_update()
player_animate()
player2_update()
player2_animate()
 cam2_x=player.x-64+(player.w/2)
 if cam2_x<map_start then
     cam2_x=map_start
  end
  if cam2_x>map_end-128 then
     cam2_x=map_end-128
  end
 camera(cam2_x,126)
end

function l2c_draw()
cls(15)

  
map(0,0)
      

 
 
spr(player.sp,player.x,player.y,1,1,player.flp)
spr(player2.sp,player2.x,player2.y,1,1,player2.flp)    
 draw_parallax()  
 rectfill(0,0,1024,127,15)
end

--level 2 hard------------

function l2h_init()
music(2)
cls()
	_update=l2h_update
	_draw=l2h_draw
 
 init_parallax()
 playerh= {
 sp=1,
 x=20,
 y=167,
 w=4,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.5,
 boost=4,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.25
 friction=0.83
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l2h_update()
fade_in()
 update_parallax()
 playerh_update()
playerh_animate()
 cam2_x=playerh.x-64+(playerh.w/2)
 if cam2_x<map_start then
     cam2_x=map_start
  end
  if cam2_x>map_end-128 then
     cam2_x=map_end-128
  end
 camera(cam2_x,126)
 	
end

function l2h_draw()
cls(15)

  
map(0,0)
      

 
 
spr(playerh.sp,playerh.x,playerh.y,1,1,playerh.flp)  
 draw_parallax()  
 rectfill(0,0,1024,127,15)
end
-->8
--level 3

function l3_init()
music(7)
cls()
	_update=l3_update
	_draw=l3_draw
 
 init_parallax()
 player= {
 sp=1,
 x=26,
 y=295,
 w=6,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.2
 friction=0.9
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l3_update()
fade_in()
 update_parallax()
 player_update()
player_animate()
 cam3_x=player.x-64+(player.w/2)
 if cam3_x<map_start then
     cam3_x=map_start
  end
  if cam3_x>map_end-128 then
     cam3_x=map_end-128
  end
 camera(cam3_x,256)
 if (btnp(—,1)) l3c_init()	
end

function l3_draw()
cls(1)

  draw_parallax()
map(0,0,0,0,128,64)
      
 
 rectfill(0,0,1024,127,0)
 
spr(player.sp,player.x,player.y,1,1,player.flp)

end

-----------------coop---------

function l3c_init()
music(7)
cls()
	_update=l3_update
	_draw=l3_draw
		_update=l3c_update
	_draw=l3c_draw
 
 init_parallax()
 player= {
 sp=1,
 x=26,
 y=295,
 w=6,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
	 player2= {
 sp=1,
 x=35,
 y=293,
 w=6,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.2
 friction=0.9
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l3c_update()
fade_in()
 update_parallax()
 player_update()
player_animate()
 player2_update()
player2_animate()
 cam3_x=player.x-64+(player.w/2)
 if cam3_x<map_start then
     cam3_x=map_start
  end
  if cam3_x>map_end-128 then
     cam3_x=map_end-128
  end
 camera(cam3_x,256)
end

function l3c_draw()
cls(1)

  draw_parallax()
map(0,0,0,0,128,64)
      
 
 rectfill(0,0,1024,127,0)
 
spr(player.sp,player.x,player.y,1,1,player.flp)
spr(player2.sp,player2.x,player2.y,1,1,player2.flp)
end


--level 3 hard----------------

function l3h_init()
music(7)
cls()
	_update=l3h_update
	_draw=l3h_draw
 
 init_parallax()
 playerh= {
 sp=1,
 x=26,
 y=295,
 w=6,
 h=6,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.3,
 boost=2,
 anim=0,
 running=false,
 jumping=false,
 falling=false,
 sliding=false,
 landed=false,
 }
 gravity=0.2
 friction=0.9
   --simple camera
  cam_x=0
  --map
  map_start=0
  map_end=1024
end

 


function l3h_update()
fade_in()
 update_parallax()
 playerh_update()
playerh_animate()
 cam3_x=playerh.x-64+(playerh.w/2)
 if cam3_x<map_start then
     cam3_x=map_start
  end
  if cam3_x>map_end-128 then
     cam3_x=map_end-128
  end
 camera(cam3_x,256)
 if (btnp(—,1)) l3c_init()	
end

function l3h_draw()
cls(1)

  draw_parallax()
map(0,0,0,0,128,64)
      
 
 rectfill(0,0,1024,127,0)
 
spr(playerh.sp,playerh.x,playerh.y,1,1,playerh.flp)

end
-->8
--other

function logo_init()
music(1)
_update=logo_update
	_draw=logo_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function logo_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    menu_init()
    end
if btn(—) or btn (Ž) then
menu_init()
end    
    
end

function logo_draw()
cls()
print("entretecho producciones",18,56,1)
print("presenta",78,76,1)

print("entretecho producciones",18,55,7)
print("presenta",78,75,7)
end

function fadeout()
local fade,c,p={[0]=0,17,18,19,20,16,22,6,24,25,9,27,28,29,29,31,0,0,16,17,16,16,5,0,2,4,0,3,1,18,2,4}
  fading+=1
  if fading%fadespeed==1 then
    for i=0,15 do
      c=peek(24336+i)
      if (c>=128) c-=112
      p=fade[c]
      if (p>=16) p+=112
      pal(i,p,1)
    end
    if fading==7*fadespeed+1 then
      cls()
      pal()
      fading=-1
    end
  end
end

function fade_in()

local fade,c,p={[0]=0}
  fading+=1
  if fading%fadespeed==1 then
    for i=0,15 do
      c=peek(24336+i)
      if (c>=128) c-=112
      p=fade[c]
     end
    if fading==7*fadespeed+1 then
      cls()
      pal()
      fading=-1
    end

end
end

--
function c1_init()
music(6)
_update=c1_update
	_draw=c1_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function c1_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    l1_init()
    end

    
end

function c1_draw()
cls(12)
map(96,3)
draw_parallax()
print("chapter 1",18,56,1)
--print("morning",78,76,1)

print("chapter 1",18,55,7)
--print("morning",78,75,7)
end
--

function c2_init()
music(6)
_update=c2_update
	_draw=c2_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function c2_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    l2_init()
    end

    
end

function c2_draw()
cls(15)
camera()
map(50,16)

print("chapter 2",28,76,6)
--print("sunset",78,76,6)

print("chapter 2",28,75,13)
--print("sunset",78,75,1)
end

--

function c3_init()
music(6)
init_parallax()

_update=c3_update
	_draw=c3_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function c3_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    l3_init()
    end

    
end

function c3_draw()
cls(1)
camera()
draw_parallax()


print("chapter 3",18,56,0)
--print("night",78,76,0)

print("chapter 3",18,55,7)
--print("night",78,75,7)


end
-->8
------hard mode---------
function c1h_init()
music(30)
_update=c1h_update
	_draw=c1h_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function c1h_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    l1h_init()
    end

    
end

function c1h_draw()
cls(8)
map(96,3)
draw_parallax()
print("chapter 1",18,56,1)
--print("morning",78,76,1)

print("chapter 1",18,55,7)
--print("morning",78,75,7)
end
--

function c2h_init()
music(30)
_update=c2h_update
	_draw=c2h_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function c2h_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    l2h_init()
    end

    
end

function c2h_draw()
cls(8)
camera()
map(50,16)

print("chapter 2",28,76,6)
--print("sunset",78,76,6)

print("chapter 2",28,75,13)
--print("sunset",78,75,1)
end

--

function c3h_init()
music(30)
init_parallax()

_update=c3h_update
	_draw=c3h_draw
	pal(0,128,1) -- force disrupt
pal()

fading=0
fadespeed=5
last = time()
end

function c3h_update()
 if (time() - last) > 2 then
    fadeout()
    end
  if (time() - last) > 3 then
    
    l3h_init()
    end

    
end

function c3h_draw()
cls(8)
camera()
draw_parallax()


print("chapter 3",18,56,0)
--print("night",78,76,0)

print("chapter 3",18,55,7)
--print("night",78,75,7)


end

-------game over hard-----

function over1h_init()

	music(0)
 _update=over1h_update
 _draw=over1_draw

end


function over1h_update()


	if (btnp(—)) l1h_init()	
 
end



function over2h_init()
	music(0)
 _update=over2h_update
 _draw=over2_draw

end


function over2h_update()


	if (btnp(—)) c1h_init()	

end

function over3h_init()
	music(0)
 _update=over3h_update
 _draw=over3_draw

end


function over3h_update()


	if (btnp(—)) c1h_init()


end





__gfx__
00000000000000000000000000000000000000000000000000000000000500000666665000000000000000000000000000000000005555000000000060000000
00000000066666500666665006666650666665000666665066666500006900000050090000000000000000000000000000000000055555500555555066600000
00700700005009000050090000500000050009000050000005000900060099880050900066666500000330000003333330000000555555555555555566000000
000770008050900008509000085009008500900008500090850090006509908080509900085090000333300333333333330000005555555565555555d6000000
00077000805909000859090080599000850990008059990085099000850966880869658008590900334344000333330444440000565555550655555566600000
007007008869658808696580886909008699658888690090869965888689800888688568086965083330004444444000000440005665555006555550d6000000
00000000086885600868856808686588086885600868856808688560086000000000008008688550030000000444400000000000055650000065550066000000
00000000008000800080008008000800800000800080080080000008800800000000000800800068000000000044443333000000000000500065550066000030
00333300000000000000066600000000000000000000000000005500003333000555555555555550000000000044000043000000555500000065550000000000
03555530033333300007766600000000000000000000655000006500035555305555555555555555000000000444000004300000555550000065550000000000
65555555353553550000666600000077700000000000666055000000335555550066655555555555000000004444000004330000555550000065550000000000
65555555655535550000666600077777777777700000000065000000355555550000065555555550000000004440000000000000555555000006550000000000
06555555065555550007666666777777777777700555000000055500355555550000006665555550000000044400000000000000555555000006500000004000
0066555506555550000067d666666666666666660665500000065550306555550000000006655500000000044400000000000000555555500006500000004000
00065550006555000000666600000000000000000066500000066550006655500000000000055500000444444400000000000000555555505000000000444000
50006500006555000007666600000000000000000000000000000000300655000000000000000000000434434440000000000000555555500000000544004000
00000006006555000000000000000003333333333333535333335000555555555555555540000000033354553345550000055555555555000000066600000000
00000006006555000000000000000033333333333333333333333330555555555555555540000000335555555545555005555555555555500007766600000000
00000776006555000000000000000033333333333353535533535353555555555555555540000000355555555555555555555555555555550000666600000000
0000006d000655000077700000000033333533333335555555555555555555555555555540000000555555555555555555555555555555550000666600000000
00007766000655006777777000000033335333333535555555555555555555555555555544000000555555555555555555555555555555550007666600040000
0000006600065600666666660000033333333333535555555555555505550000555555554000000055655555555555505565555555555550000067d600044000
00000766500660000000000000000333333333333555555555555555000000005655555540000000655555555555555065555555555555500000666600040440
00000766000600500000000000000333333533353555555555555555000000005566555540000000655555555555555065555555555555500007366300040004
0066660000ffff005555555500000333333353555555555533333333444444445555554444455555665655555555555055555555555555550000066660000000
066667600ffff7f05555555500000033333333355555555535333353440404045555555045555555666555555555555005555555555555500007766666600000
66666676ffffff7f5555555500000003335355555555555555355535440404045555555055555555066555655555550005655555555555550000666666000000
66666676ffffff7f55555550000000033335555555555555535555554444444455555544455555550066555555550050005655555555555000006666d6000000
67666666f7ffffff5555555000000000353555555555555555555555040004005555545555555555000655565500000000066555555555000007666666600000
66766666ff7fffff555555500000000053555555555555555555555500000000555555505565555500000055500000050000555555555500000067d6d6000000
066666600ffffff05555555000000000555555555555555555555555000000005555555065555555000000000005000000000555555550000000666666000000
0066660000ffff005555555000000000555555555555555555555555000000005555555565555555000000000000005000000005555000000007766666000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddd00000000000000000000ddd00000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd0000000000000000000dd000000
00000000000ddddddddd00000000000000000000000000000000000000000000000000000000000000000000000ddddddddd0dddd0000000000000000d000000
000000000ddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000dddddddddddd0ddd00000000000000ddd00000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000d000000000000dddd0000dddddd000dddd000000000000d000000
000ddddddddddddddddddddddddddddddd00dddddd000ddddddddd0000000000000000000dd00000000000ddd0d000d0dddddddd00d0dd0000000000dd000000
00ddd0ddddddddddddddddddddddddd00000dddddddddddd00000000000000000000000ddd00000000000d000ddddddd0ddddddddd0d00dd00000000dd000000
00ddd0dddddddddddddddddddddddddddddddddddddd00000000000000000000000000ddd0000000000dd00ddddddd00000dddd0ddddd00ddd00000000000000
00ddd00ddddddddddddddddddddddddddddddddddd00000000000000000000000000ddddd00000000dd0dddddddd0dddddd000dddddddd00ddd0000000000000
000ddd0ddddddddddddddddddddddddd0d0000dd0d00000000000000000000000000dd0d00000000d0ddd00ddd0000d00dddd00d0ddddddd0d0dd00000000000
00000dd00ddddd0ddddddddddddddddd00000000000000000000000000000000000dddd0000000dddddd0ddd00dddd0000000dddd000dddddddd0d0000000000
00000dd000dddd0dddddddddddddddd0000000000000000000000000000000000ddd0d000000ddddd00ddd00ddd000000000000dddd00ddd0dd0ddd000000000
00000ddddddddd0dddddddddddddddd0000000000000000000000000000000000dddd000000d00d0d0dd000dd0000000000000000ddd0dddddddd0d000000000
000000d00ddddd0ddddddddddddd0dd000000000000000000000000000000000ddd0d00000d00d0dddd00dd00000000000000000000dddddd0dddddd00000000
000000000dd0ddd0ddddddddddd00d00000000000000000000000000000000d0dddd00000dddd0dd0d00d00000000000000000000000dddddddddd0d00000000
0000000000d0ddd0dddddddddd00d000000000000000000d0000000000000d0ddd000000ddd00d0dd00d00000000000000000ddd00000d0dddddddddd0000000
000000000000ddd0dddddddd00dd0000000000000000000d0000000000000dddd000000ddd000ddd000d000000000000000ddddd000000ddddddddddd0000000
000000000000ddd0ddddddd00dd000000000000000000ddddd0000000000dddd000000ddd000ddd000d00000000000000000dddd0000000dddddddd00d000000
000000000000ddd0ddddddd0dddd000000000000000000d0d00000000000d0dd00000dddd0dddd00dd000000000000000000ddd000000000dddddddd0d000000
0000000000000dd0ddddddd0ddd00000000000000000ddddddd00000000ddddd00000ddd00dd000d00000000000000000000dddd000000000d0ddddd0d000000
0000000000000dd0dddddd00ddd0000000000000000000ddd000000000dd0dd00000dddd00d000d00000000000000000000ddddd0000000000d0dddd0dd00000
0000000000000dd0dddddd0ddd0000000000000000000dddd000000000dddddd0000ddd00dd000d000000000000dd0000000dddd0000000000dd0dddd0d00000
0000000000000ddddddddd0ddd0000000000000000000d0ddd00000000ddd0d000000dd0dd000d000000000000dd0000000dd0dd00000000000dd0ddddd00000
0000000000000ddddddddd0dd00000000000000000000dddd000000000dd0d0000000d0d0d00d0000000000ddddd00000000000d000000000000dddd0ddd0000
00000000000000dddddddd0d0000000000000000000dddddddd000000d0ddd0000d0ddd0dd0d000000000dddddd000000000000d0000000000000ddddd0d0000
00000000000000ddddddd00dd0000000000000000000dddddd0000000dddd0000dddddd0d00d00000000dddddd00000000000ddddd000000000000d0d0dd0000
0000000000000ddd0ddddddd0d000000000000000000dddd0d00000000ddd0000dd0dd0dd0d00000000dddd0d0000000000000d0d00000000000000ddd0dd000
0000000000000ddd0d0dddd00000000000000000000ddddddd0000000dddd0000dddd00ddd000000000ddd0d00000000000000ddd000000000000000ddddd000
0000000000000d0d0d0ddd0000000000000000000000dd0dddd000000ddd0000000dd00d0000000000ddd0dd00000000000dddd0ddd00000000000000dd0dd00
00000000000000dd0d00d000d0000000000000000000dddddd0000000ddd000d00ddd0dd000000000ddd00d00000000000000dddd0000000000000000ddddd00
0000000000000ddd0d0d000d00d0000000000000000dd0dddd000000dddd00dd0dddddd0000000000d0d0d000000000000000d0ddd000000000000000dddddd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000002d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000032526200000000000000000000000000000000000000003141000000000000000000000000000000000000003141000000000000
00000000000000000000000000000000000000000000000000000000000000000000e00000000071000000000000000000001100000000000000000000000000
00000000000000000000000033c3d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300
000000a0b0c000000000000000000000000000000000000000f20000000100000000e1000000000061000000c2d200000000e100000000000000000000000000
00000000000000000000000061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000130000000000
000000a1b10000000000000000000000000000000000325263d2920000000000000000000000000000000000a3b3000000000000000000000000000000000000
e0000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000f20000000000000000001300
0000324252620000000000010000000000000000000033c3828373920000000000000000000000000000000000000000000000000000000000c253d200000000
120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c283920022000002d703000000
0000334382d3000000000051000000000000000000000061c3d39273920000000000f200000000000000000000000000000000000000000000c3538200000000
000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000c3d39200000000e367000002d7
000000c3d3c1000000000000000000000000000000000000000092737392f100a0c28392f20000000000000000000000000000000000000000d0c3d300000000
0000000000000000a0c2d20000000000000000000000000000000000000000000000000000000000000000000000000000000000009200000000e3f402d7e3f4
000000000000d00000000000000000000000000000000000000092007393828392a3b39201920000000000000000000000000000000000000000000000000000
000000000000000000a3b3000000000000000000000002f4000000000000000000000000000000000000f100f200000000000000009200000000e267e2f4e267
0000000000000000000000000000000000000000000000000000737373c382d39200009200927100000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000021f40000000000000000000000000000000000c283737392000000000000009200324252636363636363
0000000000000000000000000000000000000000f200000000000000000092009200009200920000e0000000000000000000000000000002d700000000000000
0000000000000000000000000000000002d70000000021f40000000000000000000000007100000000a3b3000092000000000000007392334363636353538253
0000000000000000000000000000000000003243837392000000000000007373737373920093d2c0e10000000000000000000000000000c2d200000000000000
0000000000000000000000000000000021f400000000c28373920002f40000000011000000000000000000000073737373737373737373739382636363638253
00000000000000000000000000000000000033c3d300737373737373737392000000000000a3b300000000000000000000000000002200c3d300000000000000
00000000000000000000000000000000819132526200a3b300737393d2000000001200000000000000000000000000000000000022000000c353535363535353
00000000000000000000000000000000000000005100000000000000000092000000000000000000000000000031410000000000000000000000000000000000
00000000000000000000000000000000610033c3d3000000000000a3b300000000000000000022000000000000000000000000000000000000a3825382535353
47474747474747474747474747474747474747474747474747474747470092004747474747474747474747474747474747474747474747474747474747474747
47474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747c35353538253
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000031410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006627670000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000057566627670000
0000000000000000000000000000000000000414243444546474740000748494a4b4c4d4e4000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000057576627576700
0000000031410000000000000000000000000515253545550000000000758595a5b5c5d5e5f50000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000576627576700
0000000000000000000000000000000000000616263646000000005666768696a6b600d6e6f60000000056660000000000000000220000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000576627666700
0000000000000000000000000000000000000717273747000000005767778797a7b70000e7f70000000057670000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000576627666700
__gff__
000000000000000000000000000303230303000000000003030300000003000000000000030303000300030303032300130b030003030303030300000303232300000000000000000000000000000000000000000000000000000000000000000000000043434300000000000000000007000000834343000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0d1500002100000000000000
0000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000e000000000000000000000000000d0000000000000000000000310000
00000a0b0c0000000000000000000000000000000000000018190000001e00000000000000000000000b0c00000000000000000000000000000000000000000000000000170000000000000000000000000a0d000000001e000000000a2c2d000000151e0000000000000000002c2d0000000000160000000000000000000000
00001a1b1c0000000000100000000000000000000000000000000000100000000000000000000000232426000000000000000e00000000000000000000000000000d0000160000000000000000001100000016000000150000000000003a3b00000000000000000000000e00003c3d1c00000000000000000000002324260c00
00002a2b000011000000000000000000000000000000002325260000000000000000000000110000333a3b000000100000001e0000000000000000000000000000000010000023242536260c0000210000000000000000000000000000000000000000000000000000001e000000000000000000000000000000003334350000
00003a3b00002115000000000000002c2d000000110000333a3b0000000000000000000016210000000000000000000000000000000000000000000000000000181900000000333435363b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003a3b0000
0000000000000000000000000000003a3b00000021000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000003a273b150000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000002324260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000
0000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000333a3b000000000015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000131400000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000013140000000000000000000000000000000000000000000000131400000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000013140000000000000000000000000013140000000000000000000000000000000000000000220000002f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000220000000000000000000000000000000000001314000000000000000000000000002c391d0000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000003c283d000000000000000000002f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000002f0000000000000000000000000000000000000000002f000000000000000000000000000000002900000000000000000000000d290000000000000000000000000000000000000000002200000000000000000000000000000000000000001314000000000000000000
0000000000000000000000000000000000000000002c38372900000000000000000000000000000000002c28383737373729000000000000000000000029000000000000000000000000290000002f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002c2d00000000000000002f0000000e000000003c3d0029000000001f00000000000000181900000035353b000000002900000000000000000000002900000000000000000000000037373737372900000000000000000000002c2d0000000000000000001314000000000000000000000000000000000000000000000000
00003a3b000000000000002c2d2900001e15000000001600373737373739352d000000000016000000003a3b00000000003737373737373737373737373737290000000000000000000000000000002900000000000000000000003c3b000000000000000000000000000000000000000e000000000000000000000000000000
00000000000000000000003c3d290000000000000000000000000000003c3532000000000000000000000000000d000000000000000000000000000000000029000000000000000000000022000000290000000000000000000000000000000000000000000000002f000000000000001e160000000000000000000000300000
0000000000000000000000000029000000000000000000000000000000003a3b000000000000000000000000000000000000002f000000000000000022000029000000000000001f000000000000002900000000000000000000000000000000000000000000002c2d2900000000000000000000000000000000000000000000
0000000000000d000000000000000000000000000000000000002200000000000000000000000000000000000000000000002c2d2900000000000000000000373737373737373739282d0000000000292f000000000000000d00000000000000000000000000003c3d2900000000000000000000000000002f000000000e0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3d290000000000000000000000000000000000003c35350000000000392d290000000000001500000000002200000000000000000000000000000000000000000000002c282d290000001e0000
0000000000000000000000000000000022000000000000000000000000000000000000000000002200000000000000000000000029000000000000000000131400000000000000153c3d00000000003a3b3737392d00000000000000000000000000007c7d0000000000000d000000000000000000003c353529000000160000
000000000000000000007c7d00000000000000000000000000000000000000000000000000000000000000000000000000000000373729000000000000000000000000000000000000000000000000000000003c3d00000000000000000000000000006c4f00000000220000000000007c7d00000000003c3d29002200000000
000000007c7d000000006c4f0000000000000000000000000000007c7d0000000000000000000000000000000000000000000000000029000000007c7d00000000007c7d0000000000000000000000000000000000000000000000007c7d0000006c7d6c4f7c7d0000000000000000006c4f6c4f000000000029000000000000
6464646475766566646475666465766464646464646464646464647576656664646464646464646464646464646464646464646464642964646464757664646465667576646464646464646464646464646464646464646464646464757664656675767576757664646464646464656675767576646464646464646464657664
__sfx__
010400001902019020180201602015020110200f0200a020080200702006720047200272001720004000030000300003000030000300004000040000400004000040000000000000000000000000000000000000
01040000300130c0003100131000330003400035700377003a0003170133705300000c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000000601d000040601e0001a0000506005060020600f7000406006700057000300304000010001500027500275002750027500000000000000000000000000000000000000000000000000000000000000
0110002019020190201a0202f0051b0202f0051c0201d0201d0201d020150202d0052f0052d0052f0052d0052f0052d0052d0052d0052d0052f0052f5052f0052f5052f0052f0052d5052d0052d0050000000000
010b00203c5143b5143b5153c5143c5153b5143c5143b5153c5143b5153b5143c5153b5143c5153b5143c5153b5143c5143b5153b5143b5153b5143c5153c5143c5143c5153c5143b5153b5143b5143c5153c514
010b0020397153b7153c7153b714397143b7153c714397153c7143b71539714397143971539714397143c7153b7153c7143b7143b7153b7143c7153b7143c715397143c7153b71439715397143b7153c7143b715
01130020020700207000615006250207300615020700207000615006150207002070006250061502075020730061500615020700062500625020700207300615000700007000615006250007000070006250b070
011300002361521735237352173523735215352353521535237352173523735217352373521735237352173523735217352373521730237302173023730217312173121731217312373123731217312373121731
011300002473124731247312473124731247312373123731267312673126731267312673226732267322673300000000000000024730267302473026730267302373026730247302373026730247302373026733
011000000f7120f7120f7120f7120f7120f7120f7120f712187000370003700037000370002700197000270019700027000270002700000000000000000000000000000000000000000000000000000000000000
011000001371213712137121371213712137121371213702000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f7101f7101f7101f7101f7101f7101f7101f710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b000008073090730507307073090730b0730807309073060700307306073070730607309073050730707309073050730807309073080730907305073090730507009070050730907300000090730000005073
011000080276002760027600276002760027600276002760027600276002760027620276002760027660276002760027600276002760027600276002760027600276002760027600276002760027600276002760
011800000207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207502075020750207504075040750407504075
011800000707507075070750707507075070750707507075070750707507075070750707509075090750907507075070750707507075070750707507075070750707507075070750707507075070750707507075
011800000007300000126450000000073000001764500000000730000017645276050007328515176450000000073000001764500000000730000017645000000007300000176452841500073283151764500603
010c00201a7411a7011a7411a7411a7011874118741187411a7411a7411a7411a7411a7411874118741187411a7411a7411a7411a7411a7411874518745187451a7451a7451a7051a7451a705187451870518745
010c0020187331a7331a7331a73300733007331a7331a7331a7331a7330e7331a733000331a733000331a733000331a733000331a733000331a7331a7331a7331a7331a7331a7331a73318733187331a7331a733
010c00201f7401d7401c740217001f700217401f7401d740237021f740227401f74020740227401f7401c740217401f7401d740217401f7401d7401f740217402372034720317221f702307201f7023272030720
010c0000267003270032700327003270032700327003270032700327003270032700327003270032700327003270032700327001a7001a7001a7001a7001a70024615233001f4201f300246151f4201f2001f420
012800003b7203b7253b70037720397203b7253b7253c7253b7203972039720397203972039720267002670037720397253b7253b7213b7213672136721367213672537700377253772537725377203772037720
0114002037705397153b7153c7153e7153c7153c7153b71539715397153b7153c7153e7153b7153c7153e7153e71539715397153b7153c7153e7153e7153b7153e7153c7153b7153b7153b715397153971539715
011400002f7152d7152f7152b7152f7152b7152d7152b7152f715297152f715297152d7152b7152f71529715297152b7152d715297152f715297152d7152b7152f715297152d7152a7152f715297152d7152b715
015000100b0650b0050b0050b0650b5050b0050b0050b065000000000006005060650600000000000000b00500000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000377203772037720377203772037720377203772037700377013b7213b7213b7213b7213b7013b7013b7013b7013b71139721397213972139721397213970139701397213972139721377213771137714
001400003b7123b7123b7123b7123b7123b7123b7123b712000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
018c00042460424605246112461500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600003771037711377113771137711377113771137711377113771137711377113771137711377113771137711377113771137711377113771137711377113771137711377113771137711377113771137715
011000181775017751177511775117751177511775117751177011770117701177011775117751177511775113751137511375113751137511375113751137510c70100000000001275112751127511275112701
011800001f7221f7221f7221f7221f7221f7221f7221f702000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002671126711267112671126701
001000182372123721237212372123721237212372123721000000000000000237242372023720267212672126721287212872128721287212872128721287210000000000000001e7111e7111e7111e7111e701
011e0000137011375113751137511375113751137511370100000000001c7011c7011c7011c7011c7011c7011f7011f7011f7011f7011f7011f7011f7011f7011f701217011f701217011d7011f7012170100000
001e00000e7010e7010e5210e5210e5210e5210e5010e701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e00000e7010e5110e5110e5110e5110e5110e5110e501000000000000000000001770000000177000000017700000001770000000000001770017700167001570015700000000000000000000000000000000
011000180005315705000530000310645000000005300203000530000310645393030005329505000530060510645000030005300003000530710510645006050000000000000000000000000000000000000000
011000180706007060070600706002515025150906009060090600906004515045150a0600a060045150451500060000600006000060000600451503060045150000000000000000000000000000000000000000
010c00000e5110e5110e5110e5110e5110e5110e5110e5111a5111a5111a5111a5111a5111a5111a5111a5110e5100e5100e5100e5120e5120e5120e5120e5120e5120e5120e5120e5120e5120e5120e5120e511
011000180806008060080600806004515045150a0600a0600a0600a06004515045150b0600b060045150451506060060600606006060060600606004515045150000000000000000000000000000000000000000
01100018377123771237712377123771237712297002b7003971239712397122d7003471034710347132970030710307103071030710307113271132711297000000000000000000000000000000000000000000
011000183771037710377103771300000000003971039710397123971239712397113771137711377103771034714347143471434714347143471439700397000000000000000000000000000000000000000000
010c0000035120351103511035110351103511035111b5111b5111b5111b5111b5111b5111b5111b5111b51103511035110351203512035120351203512035120351203512035120351203512035120351203512
01100018387103871038710387103871000000000003b7003b7123b7123b712000003871238712387103871036710367113671136711387113871038710000000000000000000000000000000000000000000000
011000183871038713387153871538713387133870038713387113871338711387153871138713387153870036715367133671536711367153671136713387000000000000000000000000000000000000000000
000d0000000002f32030320287203742038420000003a42000000383203c4202d0203e42000000393203932031720393203272031720373202c7201e720207203f4203e4203c4203942037420354203342031420
000d00001632017320000001b320000001f320000002132000000233202d52025320305202532033520243203552022320365203652036520365203652035520355203452032520305202e520285200000000000
010d00000955009550095500955009550075500755007550075500755007550075500655006550065500655006550065500455004550045500455004550045500455004550045500955009550095500955009550
010d00000255002550025500255002550025500255002550005500055000550005500055000550005500055002550025500255002550025500255002550025500055000550005500055000550005500055000550
010d000030420304203a420384203a420384230050000500015000150001500015000150001500015000150000500005000050000500005000050000500005000550005500055000550005500055000550005500
011000000042000420004200042000420004200042000425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000642006420064200642006420064200642006425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
04 00 42 43 44
04 02 03 43 44
01 04 05 0d 44
01 04 42 06 07
01 41 42 06 07
03 41 42 06 08
04 09 0a 0b 44
01 0e 10 12 14
01 0e 10 11 44
01 0f 10 13 44
02 0e 10 11 14
01 09 0a 0b 44
01 15 16 18 1b
00 19 1a 1b 44
01 17 16 43 44
01 17 16 19 18
01 1c 42 43 44
03 1b 42 43 44
01 1d 1e 1f 44
04 20 21 22 44
01 23 27 24 25
01 23 24 28 25
01 23 27 24 25
01 23 26 2a 29
02 23 26 2b 29
01 2c 2d 43 44
01 2c 2d 2e 44
01 2c 2d 2e 44
01 41 30 2e 2f
03 2e 2f 43 44
04 31 32 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
