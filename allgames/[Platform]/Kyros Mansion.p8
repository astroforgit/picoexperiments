pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--kyro's mansion
--by fatcrow and lilcrow
--special thanks to nerdyteachers.com

--variables

function _init()
  player={
    sp=1, --sprite
    x=59, --x position  --900 for testing
    y=59, --y position
    w=8,  --sprite width
    h=8,  --sprite height
    flp=false, --horizontal flip
    dx=0,  --horizontal speed velocity delta
    dy=0,  --vertical speed velocity delta
    max_dx=2,  --horizontal maximum speed
    max_dy=3,  --vertical maxumum speed
    acc=0.5,  --horizontal acceleration
    boost=4,  --vertical acceleration
    anim=0,  --player animation timing
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false
  }

  gravity=0.3
  friction=0.84

		--game state
		scene="splash"
		game_music=false
		gameover_music=false
		splashscreen_timer=0
		
		--splashscreen	
		fcount = 0
  logoanim=1
  logostop=31
  logofr=81
  
  --main menu
  menu_ghost_sprite=32

  --score system
  level=1
  points=0
  --high_score=0
  gameover=false
  game_completed=false

		--table of flying ghosts
  fghosts={}
  fghost_start=32  --starting sprite
  fghost_count=3  --how many sprites we have
  fghost_interval=16
  fghost_starting_wave=2
  fghost_wavetimer=0
  fghost_waveintensity=2
  explosion=false
  
		--table of flying bats
  bats={}
  bat_start=32  --starting sprite
  bat_count=3  --how many sprites we have
  bat_interval=16
  bat_starting_wave=2
  bat_wavetimer=0
  bat_waveintensity=2
  bats_animation_timer=0 

		--table of flowers
  flowers_starting_count=6
  flowers_animation_timer=0
  initialize_flowers()
  
 	--table of lava ghosts
  lghosts_starting_count=18
  lghosts_animation_timer=0
  initialize_lghosts()

 	--table of big ghosts
  bghosts_starting_count=18
  bghosts_animation_timer=0
  bghosts_y_start=(42*8)
  initialize_bghosts()     

		--skull boss
		skull_boss_x=119*8
		skull_boss_y=57*8
		skull_boss_sprite=39
  skull_boss_animation_timer=0
  
		--skinny skeleton boss
		skeleton_x=-16
		skeleton_y=(44*8)
		skeleton_sprite_top=43
		skeleton_sprite_bottom=59
  skeleton_animation_timer=0

  --table of candles
  candles_starting_count=4
  candles_animation_timer=0
  initialize_candles()  
		--for testing--
		--candle_trigger_count=4

  --table of coins
  pickups_animation_timer=0
  initialize_pickups()

  --simple camera
  cam_x=0
  cam_y=0

  --map limits
  map_start=0
  map_end=1024
    
  
end
-->8
--update and draw

function _update()



	if scene=="splash" then
	
			update_splashscreen()
	
	end


	if scene=="menu" then
	
			update_menu()
	
	end
	
	
	if scene=="gameover" then
	
			update_gameover()
	
	end
	
	if scene=="completed" then
	
			update_game_completed()
	
	end



 if scene=="game"  then


		--increase timers
		fghost_wavetimer+=1
		bat_wavetimer+=1
	 bats_animation_timer+=1
		skull_boss_animation_timer+=1
  skeleton_animation_timer+=1
  flowers_animation_timer+=1
  candles_animation_timer+=1
  lghosts_animation_timer+=1
  bghosts_animation_timer+=1
  pickups_animation_timer+=1

		--update functions
  player_update()
  player_animate()
  fghosts_update()
  flowers_update()
  lghosts_update()
  bghosts_update()
  bats_update()
  skull_boss_update()
  candles_update()
  update_pickups()
  level_update()

		--for testing--
		--if points>=20 then
		--		scene="completed"
		--end

		--highscore tracking
		--if high_score<=points then
		--		high_score=points
		--end

		--make level 3 skeleton run
		if level==3 then 
		  skeleton_update()
		end
		
		if gameover==true then 
		  scene="gameover"
		end

  --simple camera
  cam_x=player.x-64+(player.w/2)
  if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
  camera(cam_x,cam_y)
  
 end 
 
end




function _draw()



	if scene=="splash" then
	
			draw_splashscreen()
	
	end


	if scene=="menu" then
	
			draw_menu()
	
	end


 --game completed
	if scene=="completed" then
	
			draw_game_completed()
	
	end
	

 --gameover
 if scene=="gameover" then --print game over to screen
     
    draw_gameover()    

 end
 	
	
 if scene=="game"  then
 
		--bg clear
  cls()
  --map
  --map(0,0)  --old map
  map(mx, my, 0, 0, 128,64)	
   
		--player
		--2,2 = the sprite block size
  spr(player.sp,player.x,player.y,1,1,player.flp)

  --flying ghosts
  for fghost in all(fghosts) do
    
    --print ghosts
    spr(fghost.sprite,fghost.x,fghost.y)

  end

  --add ghost explosion
  if explosion==true then
    
    spr(72,explosion_x,explosion_y)
    explosion=false
   
  end
  
  --bats
  for bat in all(bats) do
    spr(bat.sprite,bat.x,bat.y,2,1)
  end
  
  --fowers
  for flower in all(flowers) do
    spr(flower.sprite,flower.x,flower.y)
  end
  
  --lava ghosts
  for lghost in all(lghosts) do
    spr(lghost.sprite,lghost.x,lghost.y)
  end
  
  --big ghosts
  for bghost in all(bghosts) do
    spr(bghost.sprite,bghost.x,bghost.y,2,2)
  end
  
  --candles
  for candle in all(candles) do
    spr(candle.sprite,candle.x,candle.y)
  end
    
  --coins
  for p in all(pu) do
  		spr(p.s, p.x, p.y)
  end

  --skull boss
  --2,2 is the player sprite size
		spr(skull_boss_sprite,skull_boss_x,skull_boss_y,2,2)

  --skeleton top
		spr(skeleton_sprite_top,skeleton_x,skeleton_y)
  --bottom
		spr(skeleton_sprite_bottom,skeleton_x,skeleton_y+8)

  --score
  print("score= "..points,2+cam_x,1+cam_y,7)
  
 end
 
 
end
-->8
--collisions

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down

 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h

 local x1=0	 local y1=0
 local x2=0  local y2=0

 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

 elseif aim=="right" then
   x1=x+w-1    y1=y
   x2=x+w  y2=y+h-1

 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y

 elseif aim=="down" then
   x1=x+2      y1=y+h
   x2=x+w-3    y2=y+h
 end

 --testing for hitboxs
 x1r=x1   y1r=y1
 x2r=x2   y2r=y2

 --pixels to tiles
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
  --physics
  player.dy+=gravity
  player.dx*=friction

  --controls
  -- left
  if btn(‹) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
  end
  	
  --right
  if btn(‘) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
  end

  --running sfx
		if player.running
		and player.landed then
		  --sfx(44,3) --running sfx
		end

  --slide
  if player.running
  and not btn(‹)
  and not btn(‘)
  and not player.falling
  and not player.jumping then
    --sfx(45) --slide sfx
    player.running=false
    player.sliding=true
  end

  --jump
  if btnp(—)
  and player.landed then
				sfx(41,3)
    player.dy-=player.boost
    player.landed=false   
  end


  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false

    player.dy=limit_speed(player.dy,player.max_dy)

				--if we fall down on a sprite with flag 1
    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=((player.y+player.h+1)%8)-1
    end
    
   	--if we fall down on a sprite with flag 3 
    if collide_map(player,"down",2) then
    	 --collision action
      gameover=true
    end
  		
  		--check collision upwards 
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

--player anmimation
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

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
-->8
--enemies

function fghosts_update()


  --flying ghosts creation loop
  if fghost_wavetimer==120  --every 3 seconds spawn wave
  and points <= 20000 then

  		for i=1,fghost_waveintensity do
 
      fghost={
        sprite=flr(rnd(fghost_count)+fghost_start),
        x=rnd(128*8), -- 128 pixels x 8 screens -- was flr(rnd(120)+5),
        y=i*(-fghost_waveintensity)
      }
      add(fghosts,fghost)    

  		end
    
    fghost_wavetimer=0 -- reset timer

    if fghost_waveintensity >= 8 then
      fghost_waveintensity=4
    else
      fghost_waveintensity+=1
    end 
    
  end


  --flying ghosts update
  for fghost in all(fghosts) do
		
		 	--make the flying gosts fall
		  fghost.y+=gravity
			
				--delede ghosts below bottom of game
				if fghost.y>64*8 then
						
						del(fghosts,fghost)
				
				end

		  --if the fgost is inside the player
		  --we can flip this so if player is inside ghost
		  if  fghost.y+4>=player.y
    and fghost.y+4<=player.y+8
    and fghost.x+4>=player.x
    and fghost.x+4<=player.x+8 then
     
     	--collision action
      gameover=true

    end
      
    --if the fgost is in the left vacume range
		  if player.flp==true
		  and fghost.y+4>=player.y
    and fghost.y+4<=player.y+8
    and fghost.x+4>=player.x-8
    and fghost.x+4<=player.x then
     
     	--collision action
     	sfx(40) -- vacume
      points+=10
      
      --tombstone explosion
      explosion=true
      explosion_x=fghost.x
      explosion_y=fghost.y
     
      del(fghosts,fghost)
      --gameover=true
    
    end
    
    --if the fgost is in the right vacume range
		  if player.flp==false
		  and fghost.y+4>=player.y
    and fghost.y+4<=player.y+8
    and fghost.x+4>=player.x+8
    and fghost.x+4<=player.x+16 then
     
     	--collision action
     	sfx(40) -- vacume
      points+=10
     
      --tombstone explosion
      explosion=true
      explosion_x=fghost.x
      explosion_y=fghost.y
          
      del(fghosts,fghost)
      --gameover=true
    
    end
    
  end

end



--bats flying
function bats_update()


  --flying bats creation loop
  if bat_wavetimer==480
  and points <= 20000 then
  
  		for i=1,bat_waveintensity do
 
      bat={
        sprite=20,
        x=(flr(rnd(128)-128)),
        y=(rnd(96)+128)     -- was (rnd(128)+128)
      }
      add(bats,bat)    

  		end
    
    bat_wavetimer=0 -- reset timer

    if bat_waveintensity >= 3 then
      bat_waveintensity=2
    else
      bat_waveintensity+=1
    end 
    
  end


  --flying bats update
  for bat in all(bats) do
		 		 	
  		--make the bats fly right
		  bat.x+=1
		  
		  --delede ghosts below 100
    if bat.x>128*8 then
      
      del(bats,bat)
    
    end
		 
    --1st animation sprite
    if bats_animation_timer >= 1
    and bats_animation_timer <= 3 then
      bat.sprite=20
      bat.y+=1
    end
    
    --2nd animation sprite
    if bats_animation_timer >= 4
    and bats_animation_timer <= 6 then
      bat.sprite=22
    end
    
    --3rd animation sprite
    if bats_animation_timer >= 7
    and bats_animation_timer <= 9 then
      bat.sprite=24
      bat.y-=1
    end
    
    --4th animation sprite
    if bats_animation_timer >= 10
    and bats_animation_timer <= 12 then
      bat.sprite=22
    end
    
    --reset animation loop
    if bats_animation_timer >= 13 then    
      bats_animation_timer=0
    end
		  
		  
		  --if the bat is inside the player
		  --we can flip this so if player is inside ghost
    if  player.y+4>=bat.y
    and player.y+4<=bat.y+8
    and player.x+4>=bat.x
    and player.x+4<=bat.x+16 then
     
     	--collision action
      gameover=true
    
    end
         
  end

end



--skull boss
function skull_boss_update()

  if skull_boss_animation_timer > 30 then
 
    skull_boss_sprite+=2
  
    if skull_boss_sprite>41 then

      skull_boss_sprite=39

    end
 
    skull_boss_animation_timer=0
 
  end

		  --if the players is inside the skullboss
    if  player.y+4>=skull_boss_y
    and player.y+4<=skull_boss_y+16
    and player.x+4>=skull_boss_x
    and player.x+4<=skull_boss_x+16 then
     
     	--collision action
      gameover=true
   
    end

end



--skeleton
function skeleton_update()

 	if skeleton_x <= 128*8 then
	 	
		 	--run right
    skeleton_x+=1

		else
	
				--reset x pos
 	  skeleton_x=-16
				  
		end	

		
  if skeleton_animation_timer >= 1
  and skeleton_animation_timer <= 3 then
    
    skeleton_sprite_bottom=59
 
  end

  if skeleton_animation_timer >= 4
  and skeleton_animation_timer <= 6 then
    
    skeleton_sprite_bottom=85
 
  end
  
    if skeleton_animation_timer >= 7
  and skeleton_animation_timer <= 9 then
    
    skeleton_sprite_bottom=59
 
  end
  
  if skeleton_animation_timer >= 10
  and skeleton_animation_timer <= 12 then
    
    skeleton_sprite_bottom=87
 
  end
  
  if skeleton_animation_timer >= 13 then
    
    skeleton_animation_timer=0
 
  end
  

		--if the players is inside the skeleton
  if  player.y+4>=skeleton_y
  and player.y+4<=skeleton_y+16
  and player.x+4>=skeleton_x
  and player.x+4<=skeleton_x+16 then
     
   	--collision action
    gameover=true
   
  end

end


--flowers initialization
function initialize_flowers()

  --creates the flowers table
  flowers={}

	 for i=1,flowers_starting_count do
 
    flower={
      sprite=16,
      x=134*i,
      y=104
    }
    add(flowers,flower)    

 end

end


--flowers update
function flowers_update()

  --for every flowers list item do
  for flower in all(flowers) do

    --first animation sprite
    if flowers_animation_timer >= 1
    and flowers_animation_timer <= 29 then
      flower.sprite=16
    end

    --second animation sprite
    if flowers_animation_timer >= 30
    and flowers_animation_timer <= 59 then
      flower.sprite=17
    end

  		--go right and animate
    if flowers_animation_timer >= 60 
    and flowers_animation_timer <= 89 then
      flower.sprite=18
      flower.x+=1
    end
  
    --go left and animate
    if flowers_animation_timer >= 90
    and flowers_animation_timer <= 119 then
      flower.sprite=19
      flower.x-=1
    end
  
    --reset animation loop
    if flowers_animation_timer >= 120 then    
  	   flowers_animation_timer=0
    end
  
  
  		--flower collisions
    --if the flower is inside the player
    if  flower.y+4>=player.y
    and flower.y+4<=player.y+8
    and flower.x+4>=player.x
    and flower.x+4<=player.x+8 then

     --collision action
     gameover=true

    end

    --if the flower is in the left vacume range
    if player.flp==true
    and flower.y+4>=player.y
    and flower.y+4<=player.y+8
    and flower.x+4>=player.x-8
    and flower.x+4<=player.x then

     --collision action
     sfx(40) -- vacume     
     points+=20
     
     --tombstone explosion
     explosion=true
     explosion_x=flower.x
     explosion_y=flower.y
     
     del(flowers,flower)

    end

    --if the flower is in the right vacume range
    if player.flp==false
    and flower.y+4>=player.y
    and flower.y+4<=player.y+8
    and flower.x+4>=player.x+8
    and flower.x+4<=player.x+16 then

     --collision action
     sfx(40) -- vacume
     points+=20
     
     --tombstone explosion
     explosion=true
     explosion_x=flower.x
     explosion_y=flower.y
     
     del(flowers,flower)

    end  
   
  end
  
end



--lava ghosts initialization
function initialize_lghosts()

  --creates the lava ghosts table
  lghosts={}

	 for i=1,lghosts_starting_count do
 
    lghost={
      sprite=48,
      x=160+(i*24), --116+(i*16),
      y=496  --104 for testing
    }
    add(lghosts,lghost)    

 end

end

--lava ghosts
function lghosts_update()

  --for every lava ghosts list item do
  for lghost in all(lghosts) do

  		--go up and animate
    if lghosts_animation_timer >= 1 
    and lghosts_animation_timer <= 39 then
      lghost.sprite=48
      lghost.y-=1
    end
  
    --hang in the air
    if lghosts_animation_timer >= 40 
    and lghosts_animation_timer <= 90 then
      lghost.sprite=49
    end
    
    --go down and animate
    if lghosts_animation_timer >= 91
    and lghosts_animation_timer <= 129 then
      lghost.sprite=50
      lghost.y+=1
    end
  
    --reset animation loop
    if lghosts_animation_timer >= 130 then    
  	   lghosts_animation_timer=0
    end
  
    
    --lava ghosts collisions
    --if the lava ghost is inside the player
    if  lghost.y+4>=player.y
    and lghost.y+4<=player.y+8
    and lghost.x+4>=player.x
    and lghost.x+4<=player.x+8 then

    --collision action
    gameover=true

    end
    
    --if the lghost is in the left vacume range
    if player.flp==true
    and lghost.y+4>=player.y
    and lghost.y+4<=player.y+8
    and lghost.x+4>=player.x-8
    and lghost.x+4<=player.x then
 
      --collision action
      sfx(40) -- vacume
      points+=30
      
      --tombstone explosion
      explosion=true
      explosion_x=lghost.x
      explosion_y=lghost.y
     
      
      del(lghosts,lghost)

    end

    --if the lghost is in the right vacume range
    if player.flp==false
    and lghost.y+4>=player.y
    and lghost.y+4<=player.y+8
    and lghost.x+4>=player.x+8
    and lghost.x+4<=player.x+16 then
 
      --collision action
      sfx(40) -- vacume
      points+=30
     
      --tombstone explosion
      explosion=true
      explosion_x=fghost.x
      explosion_y=fghost.y
           
      del(lghosts,lghost)
      
    end

  end
  
end



--big ghosts initialization
function initialize_bghosts()

  --creates the big ghosts table
  bghosts={}

	 for i=1,bghosts_starting_count do
 
    bghost={
      sprite=35,
      x=60+(i*48), --116+(i*16),
      y=42*8
    }
    add(bghosts,bghost)    

 end
 
end

--big ghosts
function bghosts_update()

  --for every big ghosts list item do
  for bghost in all(bghosts) do

  		--random move and animate
    if bghosts_animation_timer >= 1 
    and bghosts_animation_timer <= 39 then
      bghost.sprite=37
      bghost.y+=flr(rnd(3) - 1)
      
    end
    
   	--contain the big ghosts
 			if bghost.y >= bghosts_y_start+16 then
 			  bghost.y+=-1
 			end
 			if bghost.y <= bghosts_y_start-16 then
 			  bghost.y+=1
 			end
   
    --reset animation loop
    if bghosts_animation_timer >= 130 then    
  	   bghosts_animation_timer=0
    end
    
    --big ghosts collisions
    --if the players is inside the
    --big ghosts
    if  player.y+4>=bghost.y
    and player.y+4<=bghost.y+16
    and player.x+4>=bghost.x
    and player.x+4<=bghost.x+16 then

    --collision action
    gameover=true

    end

  end
  
end
-->8
--levels

function level_update()

		--level 1 doors
  if  player.y <= 104
  and player.y >= 96
  and player.x > 954
  and player.x < 975 then

				----go to level 02
				----door hitbox actions
    sfx(43) --door sound
    points+=100
    level=2
    cam_y=59+70
    player.x=59     --x position
    player.y=59+128 --y position

				--for testing--
				--go to last level
			 --door hitbox actions
    --sfx(43) --door sound
    --points+=300
    --level=4
    --cam_y=384
    --player.x=59         --x position
    --player.y=59+128+128+128 --y position

  end  

		--level 2 doors
  if  player.y <= (30*8)
  and player.y >= (28*8)
  and player.x <= (115*8)
  and player.x >= (112*8) then

				--door hitbox actions
    sfx(43) --door sound
    points+=200
    level=3
    cam_y=256
    player.x=59         --x position
    player.y=59+128+128 --y position

  end

		--level 3 doors
  if  player.y <= (46*8)
  and player.y >= (44*8)
  and player.x <= (126*8)
  and player.x >= (123*8) then

				--door hitbox actions
    sfx(43) --door sound
    points+=300
    level=4
    cam_y=384
    player.x=59         --x position
    player.y=59+128+128+128 --y position

  end
  
end
-->8
--pickups triggers

function initialize_candles()

  --candles triggers
  candle_trigger_count=0
   
  --creates the candles table
  candles={}

	 for i=1,candles_starting_count do
 
    candle={
      sprite=116,
      x=(117*8)+(8*i),
      y=(60*8)
    }
    add(candles,candle)    

 end

end


function candles_update()

  --for every candles table item do
  for candle in all(candles) do

    --first animation sprite
    if candles_animation_timer >= 1
    and candles_animation_timer <= 9 then
      candle.sprite=116      
    end
    
    --second animation sprite
    if candles_animation_timer >= 10
    and candles_animation_timer <= 19 then
      candle.sprite=117
    end

    --3rd animation sprite
    if candles_animation_timer >= 20
    and candles_animation_timer <= 29 then
      candle.sprite=118
    end
    
    --4th animation sprite
    if candles_animation_timer >= 30
    and candles_animation_timer <= 39 then
      candle.sprite=119
    end

    --animation reset
    if candles_animation_timer >= 40 then    
      candles_animation_timer=0
    end


  		--candles collisions
    --if the flower is inside the player
    if  candle.y+4>=player.y
    and candle.y+4<=player.y+8
    and candle.x+4>=player.x
    and candle.x+4<=player.x+8 then

     --collision action
     sfx(46) --coin pickup sfx
     points+=50
     candle_trigger_count+=1
     del(candles,candle)

    end

  end

		if candle_trigger_count>=4 then
		  
		  --game_completed = true
				scene="completed"
		
		end
  
end



--initialize the coins
function initialize_pickups()

  -- list of coin pickups
  pu = {}

		-- level 01
  add(pu, {s=101, x=1*8,   y=12*8})
  add(pu, {s=101, x=81*8,  y=12*8})
  add(pu, {s=101, x=92*8,  y=3*8 })

		-- level 02
  add(pu, {s=101, x=38*8,  y=20*8})
  add(pu, {s=101, x=57*8,  y=28*8})
  add(pu, {s=101, x=109*8, y=20*8})
  add(pu, {s=101, x=125*8, y=20*8})

		-- level 03
  add(pu, {s=101, x=2*8,    y=44*8})
  add(pu, {s=101, x=123*8,  y=45*8})
  add(pu, {s=101, x=126*8,  y=45*8})

 	-- level 04
  add(pu, {s=101, x=95*8,   y=57*8})
  add(pu, {s=101, x=97*8,   y=57*8})
   
end


--update coins
function update_pickups()


  for p in all(pu) do
  	
  		--coin animations  	
    p.s+=0.2
    
    if p.s >= 104 then

      p.s=101
      --p.x+=1
    
    end					
  	
  		--coins collisions
    --if the flower is inside the player
    if  p.y+4>=player.y
    and p.y+4<=player.y+8
    and p.x+4>=player.x
    and p.x+4<=player.x+8 then
    
      --collision action
      sfx(46) --coin pickup sfx
      points+=100
      del(pu,p)

    end  		
  		
  end

end
-->8
--menus and splash screen



--menus
function update_menu()
		
		--menu buttons
  if btnp(—) then
  
  		sfx(50)  --button sfx
    scene="game"
  
  end
  
  --player animation
  if time()-player.anim>.1 then
    
    player.anim=time()
    player.sp+=1
    menu_ghost_sprite+=1
    
    if player.sp>6 then
      player.sp=3
    end
    
    if menu_ghost_sprite>34 then
      menu_ghost_sprite=32
    end
    
  end
  
  --menu ghost animation
  if time()-player.anim>.1 then
    player.anim=time()
    menu_ghost_sprite+=1

  end
 
 	
		--music
		if game_music==false then
			 --music
  		music(0,3)
  		game_music=true		
		end
    

end


--menus
function draw_menu()

		cls()

		--pentagram
		spr(12,47+cam_x,28+cam_y,4,4)

  --text centred by function
  --for testing--
  --text_mansion="h"
  --print(text_mansion,hcenter(text_mansion),58,8)
  text_kyrosmansion="kyro's mansion"
		print(text_kyrosmansion,hcenter(text_kyrosmansion)+cam_x,64+cam_y,9)
  text_studios="press — to start"
		print(text_studios,hcenter(text_studios)+cam_x-2,70+cam_y,8)
  
		--player
		spr(player.sp,59-6+cam_x,59+20+cam_y,1,1,player.flp)

		--menu ghost
		spr(menu_ghost_sprite,59+6+cam_x,59+20+cam_y)

end



--update gameover
function update_gameover()
		
		--timers
		skull_boss_animation_timer+=1

		--gameover audio
		if gameover_music==false then
				
				--gameover sound
  		sfx(47)
  		gameover_music=true

  end  
	
		--press x to start over
  if btnp(—) then

  		sfx(50)  --button sfx  
  		_init()
    scene="game"
    
  end

		--skill boss gameover animation
  if skull_boss_animation_timer > 30 then
 
    skull_boss_sprite+=2
  
    if skull_boss_sprite>41 then
      skull_boss_sprite=39
    end
 
    skull_boss_animation_timer=0
 
  end
  
end


--draw gameover
function draw_gameover() 

	 cls()
 
 	--old text
  --print('game over',44+cam_x,53+cam_y,7)
		--print("press— to start",30+cam_x,63+cam_y,7)

		--text centred by function
  --text_mansion="h"
  --print(text_mansion,hcenter(text_mansion)+cam_x,58+cam_y,8)
  text_gameover="game over"
		print(text_gameover,hcenter(text_gameover)+cam_x,64+cam_y,9)
  text_studios="press — to start"
		print(text_studios,hcenter(text_studios)+cam_x-2,70+cam_y,8)
  
		--ghost
		spr(skull_boss_sprite,56+cam_x,44+cam_y,2,2)


end



--update game complete
function update_game_completed()

		--press x to return to the main menu
  if btnp(—) then
  
  		sfx(50)  --button sfx
  		_init()
  		points=0 --reset points		
  		scene="menu"
    
  end

end


--draw game completed
function draw_game_completed() 

  cls()
  
  --old text
  --print('game completed',33+cam_x,64+cam_y,7)
  --print("score= "..points,2+cam_x,1+cam_y,7)

		--text centred by function
		text_congratulations="congratulations"
  print(text_congratulations,hcenter(text_congratulations)+cam_x,46+cam_y,7)
  text_gamecompleted="mansion completed!"
		print(text_gamecompleted,hcenter(text_gamecompleted)+cam_x,53+cam_y,7)

  text_points="score= "..points
  print(text_points,hcenter(text_points)+cam_x,64+cam_y,9)
  text_studios="press — for main menu"
		print(text_studios,hcenter(text_studios)+cam_x-2,70+cam_y,8)
 
  text_created="game created by"
		print(text_created,hcenter(text_created)+cam_x,82+cam_y,7)  
  text_credits="fatcrow and lilcrow"
		print(text_credits,hcenter(text_credits)+cam_x,88+cam_y,7)
    

end



--update splash screen
function update_splashscreen()

		--splashscreen variables
		splashscreen_timer+=1
		fcount += 1
				
		--intro sfx
		if splashscreen_timer == 1 then
		
		  sfx(48)  -- logo sfx
	  	sfx(49)  -- logo music
	 
	 end
		
		--go to next scene after 
		if splashscreen_timer >= 90 then
		
		scene="menu"
		
		end
				
end



--draw splashscreen
function draw_splashscreen() 

	 cls()
	 logo()
  --print('splashscreen',44+cam_x,53+cam_y,7)
		--print("press— to start",30+cam_x,63+cam_y,7)

end


--splashscreen logo update
function logo()

 local cx = 55
 local cy = 45
 
 local frx=logofr%16*8
 local fry=flr(logofr/16)*8
 
 for s=0,logoanim do
 
  for x=0,15 do
   camera(rnd(30/fcount),
          rnd(30/fcount))
   for y=0,15 do
   
    if(x+y==s) then
     pset(cx+x,cy+y,7)
    elseif(x+y == s-1) then
     pset(cx+x,cy+y,6)
    elseif(x+y<s-1) then
     pset(cx+x,cy+y,
      sget(frx+x,fry+y))
    end
    
   end
   
  end
  
 end
 
 if(logoanim<=logostop) logoanim+=1
 if(fcount > 35) then
 
 	--text centred by function
  text_fatcrows="fat crows"
		print(text_fatcrows,hcenter(text_fatcrows),64,9)
  text_studios="studios"
		print(text_studios,hcenter(text_studios),70,8)
    
 end
 
end



--centering text functions
--use case
--textlabel="this is some cool text!!!"
--print(textlabel,hcenter(textlabel),vcenter(textlabel),8)

function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end
 
function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end
__gfx__
00000000004444400044444000044444000444448804444400044444000444448004444400000000000000555500000000000000000000666600000000000000
00000000008888800088888008888888080888880088888880888888008888880888888804444400000055088055000000000000000666000066600000000000
0070070008f71f1008f71f10800ff71f808ff71f000ff71f080ff71f080ff71f000ff71f08888800000500088000500000000000666000000000066600000000
0007700008fffff008fffef0006ffffe006ffffe006ffffe006ffffe806ffffe006ffffe8ff71f00005500088000550000000066000000000000000066000000
00077000006bb00000bbbb000fbbb3000fbbb3000fbbb3000fbbb30000bbb3000066bb308ffffe00050000088000005000000608880000000000008880600000
0070070000bbbbf00f6bb0f0006bb6f6006bb6f6006bb6f6006bb6f60f6bb6f60066bb6f66bbb3f0050000088000005000006008008800000000880080060000
000000000f6b5666006b56660bb0500000b500000bb0500000b5000000b5000000000b566f6bb560500000088000000500060008000088000088000080006000
0000000000b0050000b005000000500000b500000000500000b500000b500000000000b50000bb55500088888888000500060008000000800800000080006000
03333330000000000000000000000000010000000000001000000000000000000000000000000000500088888888000500600000800000088000000800000600
03633630033333300333333003333330061000100100016000000010010000000000001001000000500000088000000500600000800008800880000800000600
033ee330036336300336363003636330061100a11a001160000000a11a000000000000a11a000000050088888888005000600000800080000008000800000600
00333300033ee33003335330033533300066100dd00166000000000dd00000000000000dd0000000050088888888005006000000800800000000800800000060
20033002203333020033330220333300000611111111600011111111111111110000111111110000005500088000550006000000088000000000088000000060
03033030030330300003303003033000000066611666000006666661166666600111666116661110000500088000500006000000880000000000008800000060
00333300003333000032330000332300000006011060000000006601106600001666006116006661000055088055000060000008080000000000008080000006
00033000000330000003300000033000000000000000000000000000000000001600000000000061000000555500000060000080080000000000008008000006
00777600007776000077760000077777777660000000000000000000000066666666000000000000000000000777777060008800008000000000080000880006
07777760077777600777776000077777777660000007777777766000000677777777600000006666666600007777777760080000008000000000080000008006
07577560077171600717176007777777777776600007777777766000006777777777760000067777777760007077770706800000008000000000080000000860
07777760077777600777776007755577775556600777777777777660007777777777770000677777777776007077770706888888888888888888888888888860
07755760077117600771176077750077770057660775557777555660007757777775770000777777777777007777777706000000000800000000800000000060
07777760077777600777776077750077770057667775007777005766007775777757770000775777777577000707707000600000000800000000800000000600
07777760077777600777776077777777777777767775007777005766007667577576670000777577775777000000000000600000000800000000800000000600
06066060060660600606606077777777777777767777777777777776007687777778670000766757757667000777777000600000000080000008000000000600
00999800009998000099980077777777777777767777777777777776000557777775500000768777777867007077770500060000000080000008000000006000
09199180099999800999998077777750057777777777777777777776000777777777700000055777777550007007700500060000000080000008000000006000
09999980091991800999998077777777777777777777775005777777000777766777700000077777777770007077770500006000000008000080000000060000
09911980099999800919918077777777777777777777777777777777000766655666700000077776677770007007700500000600000008000080000000600000
09911980099119800991198077777777777777777777777777777777000007077070000000076665566670000077770000000066000000800800000066000000
09999980099999800991198077777777777777777507550770557077000006066060000000007777777700000700005000000000666000088000066600000000
09999980099999800999998075075507705570777507550770557077000077777777000000007777777700000700005000000000000666088066600000000000
08088080080880800808808075075507705570770000000000000000000077777777000000000000000000000700005000000000000000666600000000000000
0032330000000000006666008585c5c558885ccc00099000008bb0000008000000055000555555555555555500000000bbbbbbbbbbbbbbbb5555555566666666
03333330000000000666666088555c5558855c5c00588500bb00b00000bb0bb80056650051cccccffccccc15888856853b333bbb3bbb3bbb55555555dddddddd
323e323e000000006665665685855c5558585ccc055555508bb0b00000b0bb000566665051c8cccffccc8c1588588888444433b443bb33b35555555555555555
33333333000be10066666666999999999999999905566550000bb30080bbb0000666666051c8cccffccccc1588885858444444344bb344345555555555555555
e3233332000828006566666650505050050505050556655000bbbb00b00bb3000655556051cccccffccccc15858868885444444444b444445555555555555555
333333330001eb0066666667505050500505050505566550bb0bbbb0bbbbb3b80666666051c8cc8ffc8ccc155688888844444445444445445555555555555555
333333330000300006656670505050500505050500566500800bb3b000bbb3000655556051cc8ccffccc8c15899898594444444444544444dddddddddddddddd
333333330000300000777700505050500505050500066000000bb380000bb3000666666051cccc8ffccc8c159985998944454444444444446666666666666666
33333333000bbbb000000000505050500505050570777705000bb300707777050000000051cc8c8ffccc8c1596999996bbbbbb0000bbbbbb6666666655555555
333333e300bb9bbbbbb00000505050500505050570077005000bb30070077005000b000051cccccffc8ccc15995599993b3bbbb00bbb3bbbdddddddd55555555
332333330bbb9bbbbbb9bb00505050500505050570777705000bb30070777705000bbb3351c8cccffc88cc15699999594433bbbbbbbb33335555555555555555
33333333bbbb999bbb99bb00505050500505050570077005000bb300700770050000bbb351c8c8cffc8ccc1599999999444333bbbbb344355555555555555555
33333333bbbbbbbbbbbbbbb0505050500505050500777700000bb300007777000000bbb351cc8ccffccc8c159d99969d5444433bb3b454445555555555555555
333e3323bbbbb99bbbbb9bb0505050500505050507000050000bb3000700005000000bb451cccccffccccc159959999944444443b34444455555555555555555
2333333300bbbb9999b99bb0505050500505050500700500000bb30077000005000000b4511111111111111599999d9944444444b45444445555555555555555
3333333300bbbbbbbb99bb00505050500505050500070000000bb300000000050000000455555555555555559d99999d44454444444444445555555555555555
0077777700003344433bb00070000007000000000009a0000009a0000009a0000009a0000009999440000000666666664444444444444444ffffffff7ffffff7
0777766600000044430000000707707000000007009aaa00009aaa000009a000009aaa00009989999990000088888888444444444544444444444f4447477f74
766777770000004440000000007007000000007009a00aa000a0aa00000aa00000aa0a00099989999998990055555555444444444444454444444f4444744744
76777777000000444000000007077070000077070aa00aa000a0aa00000aa00000aa0a00999988899988990055555555444544444444444444444f4447477f74
77767777000000444000000007077070000700700aa00aa000a0aa00000aa00000aa0a009999999999999990555555554444444444444444fffffffff7f77f7f
077666670000004440000000007007000007070709a00aa000a0aa00000aa00000aa0a00999998899999899055555555444444454444444444f4444444744744
0777777700000044400000000707707000707070009aaa00009aaa000009a000009aaa00009999888898899088888888444444444444444444f4444447f77474
00667076000000444000000070000007770707070009a0000009a0000009a0000009a000009999999988990066666666444444444444454444f4444474f44447
777777000000444470777777000000000002800000028000000280000002800056666666666666656666666644444444444444446666666600ff4f00ffffffff
66667770000044446777666700055000002888000028880000028000002888005688888886888865868888884555555445555554d6dddddd00ff4f0000444400
7776667700004444677667770066660002800880008088000008800000880800568000000680006506800000454444544544445456d5555500ff4f0000f4ff00
7777776700004444777677770005500008800880008088000008800000880800568000000680006506800000454444544544445456d555550044440000f4ff00
766777770000444477777776000550000880088000808800000880000088080056666666666666656666666645444454454444546666666600f4ff0000f4ff00
77667770000044447767776600055000028008800080880000088000008808005688868888888685888886884544445445444454ddddd6dd00f4ff0000f4ff00
77777770000044447777677700055000002888000028880000028000002888005680068000000685000006804555555445555554555556d500f4ff0000444400
70077700000044446777007700666600000280000002800000028000000280005680068000000685000006804994444444444444555556d50044440000ff4f00
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5
d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7
d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4
e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5
f500000094a4000000000000000000000094a4000000000000000000000094a4000000000000000000000094a4000000000000000000000094a4000000000000
000000000094a4000000000000000000000094a4000000000000000000000094a4000000000000000000000094a4000000000000000000000094a400000000f5
f500000095a5000000000000000000000095a5000000000000000000000095a5000000000000000000000095a5000000000000000000000095a5000000000000
000000000095a5000000000000000000000095a5000000000000000000000095a5000000000000000000000095a5000000000000000000000095a500000000f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0b000f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a1b100f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054c7b754f5
f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7c700f5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7
d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054
000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054000054a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d0e0f00000c0d0e0f00000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1d1e1f10000c1d1e1f10000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c2d2e2f20000c2d2e2f20000a7
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3d3e3f30000c3d3e3f30000a7
a7000000000000000000000000000000000000000000b6b6b6b6b6b6b6b6b6b6b60000b6b60000b6b60000b6b6000000000000b6b600b6b6b6b600b6b6000000
000000b6b6b60000000000b6000000000000000000000000000000006487970000648797740000000000000000000000000000000000000000000000000000a7
a700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b6b600000000000000000000000000b6b6
b6b60000000000b6b6b60000000000000000000000000064879774006587970000658797656400879764000000000000000084848400373737370084848400a7
a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a797b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4
b4b4b4b4b4b4b4b4b4b4b4b487a7a7a7a7a7a7a797007465879765646587977400658797656564879765740087a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7
a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a797b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5
b5b5b5b5b5b5b5b5b5b5b5b587a7a7a7a7a7a7a797746565879765656587976564658797656565879765656487a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000401010301000000000000040000000004010103030100000000000000000000010000000001000100000000000303030000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060700000000000000000000000000000000000000000000000000000000000000000000000000000000060700000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000006070000042000000000000000000000000000000000000006072727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000006070000000000000000000000000000000000000000000000060700000000000000000000000000000000000000000000000000000000000000000000000000000000060727000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006070000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000607000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006070000000000000000000000000000000000000000000000000005353000053530000545400005454
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007d7d53537d534344547d54547d7d
0000000000000000000000000000000000000000000000000000000000000000000051520000000000000000000000000000000000000051520000000051520061620000000000000000000000000000000000000000000000004800480048410000000000000000000000515200000000007d7d53537d535354547d54547d7d
00000000000000000000000000000000000000000000000000000000000000000000615152000000000000000000000000000000000000615152000000615152710000000000000000000000004040000000000000000000005d4d4c4c4d4d5c0048000000000000000000615152000000007d7d53537d535354547d54547d7d
4000000000000000000000000048480000000000000000000040400000000000515271616251520000000000000000000000000000515271616251520071616271515200000000000000004040505040000000000000415d4d6c6c6c6d6c6c6c4c4c5c4100000000005800716162000000007d7d53537d537c7b547d54547d7d
4d5c414140400000000000005d4c4c5c000041410000000040505040400000006162717141616241000000000000000000000000006162717141616241717141716162000000000040005d4c4c4c4d4d4c5c410000415d6c6d6c6d6c6c6c6c6d6c6d6d5c0000414100696a717141000000647d7d53537d537c7c547d54547d7d
4c4d4c4d4d4c4d4d4c4c4d4d4c4d4d4d4c4d4c4d4c4d4c4c4c4d4c4d4d4c4c4d4c4d4d4c4d4d4c4c4d4d4d4c4c4d4d4c4c4d4d4c4d4c4d4d4c4d4d4c4c4d4d4d4c4c4d4d4c4c4d4d4c4d4d4c4d4d4d4c4d4c4d4c4d4c4c4d4d4c4d4d4d4c4d4c4d4c4d4c4d4d4c4c4d4d4c4c4d4d4c4d4d4c4d4d4c4c4d4d4c4c4d4d4c4d4d4c
6c6d6c6d6d6c6d6d6c6d6c6d6d6c6d6c6c6d6c6d6c6c6d6c6d6c6d6c6d6d6c6d6c6d6c6d6c6c6d6d6c6d6c6c6d6c6d6c6d6d6d6c6d6c6d6c6d6c6c6d6d6c6d6c6c6d6c6d6c6d6d6d6d6c6d6d6c6d6c6c6d6c6d6c6c6d6d6c6d6d6c6d6c6c6d6c6d6c6c6d6d6c6c6d6c6d6c6d6d6d6d6c6d6d6d6c6c6d6c6d6c6d6d6d6d6c6d6d
5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f
6e6e6e6e6e6e6f6f6f6f6e6f6f6f6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6e6f6f6e6e6e6e6e6e6f6f6f6f6e6f6f6f6e6e6e6f6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6e6f6f6f6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6e6f6f6e6e6e6e6e6e6f6f6f6f6e6f6f6f6e6e6e6f6e6e6e6e6e6e6f6e6e6e6e6e6e6e6e
6e6e6e6e6e6e6e6e6f6e6e6f6e6f6f6f6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6e6e6f6e6e6e6e6e6e6e6e6e6f6e6e6f6e6f6f6f6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6e6e6f6e6f6f6f6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6e6e6f6e6e6e6e6e6e6e6e6e6f6e6e6f6e6f6f6f6e6e6e6e6e6e6e6e6e6e6f6e6e6e6e6e6e
7f00000000000000000000000000007f00000000000000000000000000007f00000000000000000000000000007f00000000000000000000000000007f00000000000000000000000000007f00000000000000000000000000007f00000000000000000000000000007f00000000000000000000000000007f00000000000000
7e00000000000000000000000000007e00000000000000000000000000007e00000000000000000000000000007e00000000000000000000000000007e00000000000000000000000000007e004f4f004f4f4f000000000000007e00000000000000000000000000007e0000000000004f4f0000000000007e00000000000000
7e00000000000000000000000000007e000000000a0b00000000000000007e0000000000004f4f4f00000000007e00000000000000000000000000007e000000004f4f004f4f004f4f00007e000000000000000000000a0b00007e0000004f4f4f4f634f4f00004f4f4f00004f4f4f000000004f004f004f7e4f4f004f4f4f00
7e00000000000000000000000000007e000000001a1b00000000000000007e00000000000000000000000000007e0000000000000000000000005e5e7e00000000000000000000000000007e000000000000000000001a1b00007e00000000000000000000000000007e00000000000000000000000000007e00000000000000
7e00000000000000000000000000007e00000000000000000000000000007e00000000000000000000000000007e004f4f4f4f00000000005e5e5f5f7e004f4f004f0000000000000000007e00000048480000000000000000007e00000000000000000000000000007e00000000000000000000000000007e00000000000000
7e00000000000000000000000000007e00000000000000000000000000007e000000000000000000485e0000007e00000000000000005e5e5f5f5f5f7e0000000000004f000000000000007e0000005e5e0000000000000000007e00000000005e00000000000000007e00000000000000000000000000007e00000000000000
7e00000000000000000000000000007e00000000000000000000004800007e0000000000000000005e5f5e48007e000000000000005e5f5f5f5f5f5f7e00000000000000004f4f000000007e0000005f5f5e00004800000000007e000000645e5f5e000000000000007e00000000000000000000000000007e00000000000000
7e000000000000000000005e5e00007e00000000000000000048485e5e007e00000000000000005e5f5f5f5e5e7e0000000000000000005f5f5f5f5f7e00000000000000000000000000007e005e005f5f5f48485e005e4848007e5e5e5e5e5f5f5f5e5e5e5e5e5e5e7e5e5e5e5e5e5e5e5e5e5e5e5e5e5e4f4f4f4f4f000000
7e00000000000000485e5e5f5f00007e0000000000000000005e5e5f5f007e000000000048485e5f5f5f5f5f5f7e0000000000000000000000005f5f7e0000000048485e5e000000005e007e5e5f5e5f5f5f5e5e5f5e5f5e5e007e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f4e4e4e4e4e4e4e4e4e4e4e4e4e4e7e00000000000000
7e0000000000645e5e5f5f5f5f00007e0000645e0048485e5e5f5f5f5f007e00000048005e5e5f5f5f5f5f5f5f7e4848005e00005e0000485e005f5f7e000000005e5e5f5f00005e5e5f645e5f5f5f5f5f5f5f5f5f5f5f5f5f5e7e00000000000000000000000000007e000000000000457c7b45000000007e00000000000000
7e4848005e5e5e5f5f5f5f5f5f48007e5e5e5e5f5e5e5e5f5f5f5f5f5f007e5e5e5e5e5e5f5f5f5f5f5f5f5f5f5e5e5e5e5f485e5f48485e5f5e5f5f7e48485e5e5f5f5f5f5e5e5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f7e00000000000000000000000000645e000000000000007c7c00000000007e005e5e00000064
5e5e5e5e5f5f5f5f5f5f5f5f5f5e5e5e5f5f5f5f5f5f5f5f5f5f5f5f5f5e5e5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5e5f5f5e5e5f5f5f5f5f5e5e5e5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f5f5e5e5e5e
7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d
__sfx__
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000100301003010030100300b0400b0400b0400b04006040060400604006040070400704007040070400f0300f0300f0300f0300b0400b0400b0400b040060400604006040060400f0300f0300f0300f030
011400000c073000000000000000246530000000000000000c073000000c07300000246530000000000000000c073000000000000000246530000000000000000c07300000000000c07324653000000000024653
0114000028350283212831128301233502332123311233011e3501e3211e3111e3011f3501f3211f3111f3011b3501b3211b3111b301233502332123311233011e3501e3211e3111e3011b3501b3211b3111b301
011400002823528235000002823500000282350000000000282350000000000282350000028235000002823528235000000000028235000000000028235000002823528235000002823528235000002823500000
011400001c5520000000000000001e552000001e552000001e552000001f551000002355223552235522755227552000001f55100000235522355123551275521e5520000000000000001e552000001e5521e552
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
00020000016500265003650056500a65010650166501a650027500375002750027500d60013600136001b60023600010000100001000000000000000000000000000000000000000000000000000000000000000
00020000000000a4500b4500c4500d4500f450124501545018450194501b4501c4501e45024450314500000021400244002540000000274002840000000284000000029400294000000028400284000000000000
000200000100001150011500115002150021500315008150141501615015150121500d15008150081500a1500a150031500115001150001500115004150051500615008150091500a1500b1500c1500e1500d150
000200001715017110051500615007150091500d15011150141501715018150171501615013150101500e1500b150091500815008150081500b1500e15010150121501215014150141501415013150111500f150
000100000461000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003000000061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000000035000350003500035000350003500b3500b3500b3500c3500d3500e35010350143501a3501f350213502435027350153502b3502c3502c3502d3502d350282002a2003f200302003020000000
00030000000002e0502d0502b05029050270502505023050210501f0501d0501b05019050170501505013050100500e0500d0500b050090500705004050020500105000650006500015000150007500015000150
00040000106201263010640106400f6300e6300d6300c6300a6300963007630066300663005630046300463002630016300163001620006200062000620006100061000610006100061000610006100061000610
0110000021357213570000015357153571535700000103570c3570c3570c3570c3570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00002135303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 03 42 43 44
00 03 42 43 44
01 03 02 43 44
00 03 02 43 44
00 01 02 03 44
00 01 02 03 44
00 01 02 03 44
00 01 02 03 44
00 01 05 04 44
00 01 05 04 44
00 01 05 02 44
00 01 05 02 44
00 01 03 05 44
00 01 03 05 44
00 01 02 03 44
02 01 02 03 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
