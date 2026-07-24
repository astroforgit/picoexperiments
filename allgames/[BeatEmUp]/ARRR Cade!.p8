pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-------------------------------
--arrrcade--
--samia r. & daniel o.
--last version
------------------------------
--global defines (finetuning)
--design
player_hp = 5
player_speed = 1

blockdropfreq = 100--64

barrel_hp = 2
chest_hp = 2

enemy_spawnfreq = 64--durchschnittliche spawn freq

jack_hp = 3
jack_speed = 0.6

dan_hp = 3
dan_speed = 0.4

--performance
max_enemies = 16
collision_recheck_freq= 8

--music
music_on = true
musicstr = "on"
--sounds
sfx_shoot = 0
sfx_explode = 1
sfx_jump = 6
sfx_grounded = 9
sfx_hardfall = 10
sfx_sword = 3
sfx_gameover = 4
sfx_coin = 7
sfx_heart  = 2
sfx_pickup = 8
sfx_hurt = 11
sfx_skeletonhurt = 12
sfx_blockdamage = 22
-------------------------------
--game loop
 game_intro = 0
 game_menu = 1
 game_running = 2
 game_won = 3
 game_over = 4

game_state = game_intro
difficulty = "easy"
games_won = 0
games_lost = 0
game_tips = {
 "you can fly in the air using the recoil of the gun :)",
 "barrels can drop hearts while chest can drop coins!",
 "choose wisely wether you want to shoot or move - you can't do both at a time!",
 "you can crush zombies by smashing barrels and chests on them!",
 "dodging zombies with bombs in close combat can be difficult, try jumping away instead!",
 "always switch to sword when enemies come closer!",
 "december 2017::gfx+sfx+music: samia, code: daniel:: thank you for playing! ‡"
}
shake = false
function _init()
 debug = false
 if game_state == game_intro then
  music(0,0,4)
 end
 if game_state == game_running then
  if music_on then
   music(3,0,4)
  end
  frame = 0
  player_init()
  enemy:init() 
 end
end
function _update()
 frame += 1
 frame %= 128
 if game_state == game_intro then
  if btnp(5) then
   ship.x = 0
   music(-1,0)
   music(2,0,4)
   game_state = game_menu
  end
  ship:update()
  wave:update()
  zombieship:update()
  if ship.x>= 0 then
   if cade_talks() then
    if cade_text ~= cade_text2 then
     speechbubble.s = ""
     cade_text = cade_text2
     cade_textindex = 1
    else
     game_state = game_menu
    end
   end
  end
 elseif game_state == game_menu then
  titlelogo_update()
  menu_cade_update() 
  ship:update()
  wave:update()
  game_tips:update()
 elseif game_state == game_running then
  objects:update()
  player_update()
  explosion:update()

  block_drop()
  enemy:spawn()

  itemparticle:update()
  particles:update()
  spr_particles:update()
  dust:update()

 elseif game_state == game_won then
  cam.x = lerp(
  cam.x,
  player.x,--mid( 58, player.x, 68),
  cam.speed
  )
  cam.y = lerp(cam.y,player.y,cam.speed)

  particles:update()
  if frame % 8 == 0 then
   particles:create(
    player.x-rnd(2)+rnd(2),
    player.y-rnd(2)+rnd(2),
    rnd(15),
    32,true
   )
  end
  if btnp(5) then
   level:clear()
   game_state = game_running
   game_over_circ.scale = 8
   _init()
  elseif btnp(4) then
   level:clear()
   if music_on then
    music(-1,0)
    music(2)
   end
   game_state = game_menu 
  end
 elseif game_state == game_over then
  
  particles:update() 
  game_over_circ:update()
  cam.x = lerp(
  cam.x,
  player.x,
  cam.speed
  )
  cam.y = lerp(cam.y,player.y,cam.speed)

  if game_over_circ.scale < 0.3
  then
   if player.astate < 6 then
    sfx(sfx_hurt,3)
    player.astate = 6
    player.ffindex = 1
    frame = 0
   end
   if frame % 126 == 0
   and player.ffindex < 6
   then
    player.ffindex +=1
   elseif btnp(5) then
    level:clear()
    game_state = game_running
    game_over_circ.scale = 8
    _init()
   elseif btnp(4) then
    level:clear()
    if music_on then
   	 music(-1,0)
   	 music(2)
    end
    game_state = game_menu    
   end
  else   
  end
  if frame % 32 == 0 then
   particles:create(
    player.x-rnd(2)+rnd(2),
    player.y-rnd(2)+rnd(2),
    8,
    8+rnd(8)
   )
  end
 end
 --debug on off
 if btnp(0,1) then
  if debug then
   debug = false
  else
   debug = true
  end
 end
end
shakecounter = 0

function _draw()
 palt(0,false)--black -> opaque
 palt(11,true)--blue -> transparent
 palt(12,true)--green -> transparent
 if game_state == game_intro then
  cls(12)
  buttons_draw()
  spr(0,ship.x+menu_cadex,ship.y+menu_cadey,2,2)
  ship:draw()
  zombieship:draw()
  wave:draw()
  print("press x to skip",64,120,13)
  if ship.x>= 0 then
   speechbubble:draw()
  end
 elseif game_state == game_menu then
  cls(12)
  palt(12,true)--green -> transparent
  buttons_draw()
  spr(0,ship.x+menu_cadex,ship.y+menu_cadey,2,2)
  ship:draw()
  buttons_print()
  local col = 3
  if difficulty == "hard" then col = 8 end
  print("won: "..tostr(games_won).." / lost: "..tostr(games_lost),30,ship.y+86,col)
  wave:draw()
  titlelogo_draw()
  game_tips:cycleprint()
  print("press ‹ or ‘ + x ",28,96,13)
  if explainthegame then
   for ix=0,128,32 do
    for iy=0,128,32 do
     spr(192,ix,iy,16,16)
    end
   end
   print("   you control capt. cade and\n the blocks thrown by his crew!\n\n  fight the zombies to survive!\n   stack the blocks to escape!\n\n˜controls˜˜˜˜˜˜˜˜˜˜˜\nmove cade     = ‹ or ‘\ndump down     = ƒ\njump          = ”\n\nmove block    = z + ‹ or ‘\nsmash block   = z + ƒ\n\nshoot/attack  = x + ‹,‘,ƒ,”\nswitch weapon = z + ”\n\nyou can aim in 8 directions\nand shoot around the corner!\n\n         (press ‹ or ‘)",0,2,7)
  end
   elseif game_state == game_running then
  cls(0)
  if shake then
   camera(-rnd()*rnd(4),rnd()*rnd(4))
   shakecounter+=1
   if shakecounter%8==0 then
    camera()
    shakecounter = 0
    shake = false
   end
  end
  level:draw()
  objects.blocks:draw()
  dust:draw()
  explosion:draw()
  objects.chars:draw()
  player_draw()
  objects.projectiles:draw()
  particles:draw()
  spr_particles:draw()
  itemparticle:draw()
-- camera()
  ui:draw()

  --debug....---
  if debug then
   print("cpu: "..stat(1)
    .."\nblc: "..#objects.blocks
    .."\nchr: "..#objects.chars
    .."\nitm: "..#objects.items
    .."\npjt: "..#objects.projectiles
   ,0,0)
   print(tostr(player.grounded)
   .."\nvy:"..player.vy
   .."\ny:"..player.y
   ,player.x,player.y-20)
  end
 elseif game_state == game_won then
  if abs(cam.x-player.x)+abs(cam.y-player.y) > 8 then
    cls(rnd(0))
  else
   if frame % 16 == 0 then
    cls(rnd(15))
   end
  end
  if frame % 32 == 0 then
   if player.flip_x then
    player.flip_x = false
   else
    player.flip_x = true
   end
  end
  camera(cam.x-64,cam.y-64)
  player_draw()
  particles:draw()
  print ("congratulations!!\n   you've made it!",player.x-22,player.y-32,6)
  camera () 
  print("games won: "..tostr(games_won).."\ngames lost: "..tostr(games_lost).."\nx-restart z-back to menu",2,110,6)
 elseif game_state == game_over then
  cls(0)
  camera(cam.x-64,cam.y-64)

  level:draw()
  objects.blocks:draw()

  game_over_circ:draw()
  
  dust:draw()
  explosion:draw()
  objects.chars:draw()
  objects.projectiles:draw()
  spr_particles:draw()

  objects.projectiles:draw()
  player_draw()
  particles:draw()
  print ("captain cade\n  is dead!",player.x-16,player.y-32,8)
  print ("captain cade\n  is dead!",player.x-17,player.y-32,2)
  camera ()
  print("games won: "..tostr(games_won).."\ngames lost: "..tostr(games_lost).."\nx-restart z-back to menu",2,110,6)
 end
end

-------------------------------
--level
level = {
 gravity =  0.25
}

function level:draw()
 --background map
 map(0,12,0,0,16,16)
 for i=0,16 do
  spr(70,i*8,64)
 end
end

function level:clear()
 pobj = nil
 del(playersword)
 del(plaergun)
 for k, v in pairs(objects) do
  if type(v)=="table" then
   for obj in all(v) do
    del(v,obj)
   end
  end
 end
end
-------------------------------
--collision
function collision(obj,other)
 if other.x+other.cw*0.5
  > obj.x-obj.cw*0.5
 and other.y+other.ch*0.5
   > obj.y-obj.ch*0.5
 and other.x-other.cw*0.5
   < obj.x+obj.cw*0.5
 and other.y-other.ch*0.5
   < obj.y+obj.ch*0.5
 then
   return true
 else
  return false
 end
end
-------------------------------
--objects

objects={
-- static={},
-- moving={}
 chars={},
 blocks={},
 items={},
 projectiles={}
}


--template data
--sprite
obj_sx = {} obj_sy = {}
obj_sw = {} obj_sh = {}
--collision
obj_cw = {} obj_ch = {}

--
obj_cade = 1
obj_sx[obj_cade] = 0
obj_sy[obj_cade] = 0
obj_sw[obj_cade] = 16
obj_sh[obj_cade] = 16
obj_cw[obj_cade]  = 5
obj_ch[obj_cade]  = 12
--
obj_jack = 2
obj_sx[obj_jack]  = 0
obj_sy[obj_jack]  = 64
obj_sw[obj_jack]  = 16
obj_sh[obj_jack]  = 16
obj_cw[obj_jack]  = 5
obj_ch[obj_jack]  = 13
--
obj_dan = 3
obj_sx[obj_dan]  = 0
obj_sy[obj_dan]  = 80
obj_sw[obj_dan]  = 16
obj_sh[obj_dan]  = 16
obj_cw[obj_dan]  = 5
obj_ch[obj_dan]  = 13
--
obj_barrel = 4
obj_sx[obj_barrel]  = 0
obj_sy[obj_barrel]  = 32
obj_sw[obj_barrel]  = 16
obj_sh[obj_barrel]  = 16
obj_cw[obj_barrel]  = 12
obj_ch[obj_barrel]  = 16
--
obj_chest = 5
obj_sx[obj_chest]  = 0
obj_sy[obj_chest]  = 48
obj_sw[obj_chest]  = 16
obj_sh[obj_chest]  = 16
obj_cw[obj_chest]  = 12
obj_ch[obj_chest]  = 16
--
obj_brokenwood = 6
obj_sx[obj_brokenwood]  = 32
obj_sy[obj_brokenwood]  = 32
obj_sw[obj_brokenwood]  = 8
obj_sh[obj_brokenwood]  = 8
obj_cw[obj_brokenwood]  = 0
obj_ch[obj_brokenwood] = 0
--
obj_platform = 7
obj_sx[obj_platform]  = 56
obj_sy[obj_platform]  = 32
obj_sw[obj_platform]  = 8
obj_sh[obj_platform]  = 8
obj_cw[obj_platform]  = 8
obj_ch[obj_platform]  = 2
--
obj_cannonball = 8
obj_sx[obj_cannonball]  = 64
obj_sy[obj_cannonball]  = 32
obj_sw[obj_cannonball]  = 5
obj_sh[obj_cannonball]  = 5
obj_cw[obj_cannonball]  = 6
obj_ch[obj_cannonball]  = 6
--
obj_gun = 9
obj_sx[obj_gun]  = 0
obj_sy[obj_gun]  = 16
obj_sw[obj_gun]  = 16
obj_sh[obj_gun]  = 16
obj_cw[obj_gun]  = 0
obj_ch[obj_gun]  = 0
--
obj_sword = 10
obj_sx[obj_sword]  = 64
obj_sy[obj_sword]  = 16
obj_sw[obj_sword]  = 16
obj_sh[obj_sword]  = 16
obj_cw[obj_sword]  = 0
obj_ch[obj_sword]  = 0
--
obj_bomb = 11
obj_sx[obj_bomb]  = 72
obj_sy[obj_bomb]  = 40
obj_sw[obj_bomb]  = 7
obj_sh[obj_bomb]  = 8
obj_cw[obj_bomb]  = 8
obj_ch[obj_bomb]  = 8
--
obj_explosion = 12
obj_sx[obj_explosion]  = 48
obj_sy[obj_explosion]  = 40
obj_sw[obj_explosion]  = 8
obj_sh[obj_explosion]  = 8
obj_cw[obj_explosion]  = 0
obj_ch[obj_explosion]  = 0
--
obj_swordstrike = 13
obj_sx[obj_swordstrike]  = 88
obj_sy[obj_swordstrike]  = 24
obj_sw[obj_swordstrike]  = 5
obj_sh[obj_swordstrike]  = 8
obj_cw[obj_swordstrike]  = 5
obj_ch[obj_swordstrike]  = 5
--
obj_coin = 14
obj_sx[obj_coin]  = 72
obj_sy[obj_coin]  = 48
obj_sw[obj_coin]  = 8
obj_sh[obj_coin]  = 8
obj_cw[obj_coin]  = 4
obj_ch[obj_coin]  = 4
--
obj_heart = 15
obj_sx[obj_heart]  = 64
obj_sy[obj_heart]  = 48
obj_sw[obj_heart]  = 7
obj_sh[obj_heart]  = 7
obj_cw[obj_heart]  = 4
obj_ch[obj_heart]  = 4
-----------------------------
--template for object creation
function obj_template()
 return {
  --identity/type
  t,
  --position
  x,y,
  --movement
  vx=0,vy=0,
  --collision
  grounded = false,
  groundobj = nil,
  letfall = false,
  cx,cy,
  cw,ch,
  oldy = 0,
  --animation
		findex = 1,
  ffreq  = 18,
  astate = 1,--
  frames = {},
  scale = 1,
  --combat
  cooldown =0,
  damage=false,
  hp = 1,
  --sprites
  sx,sy,--pixel position on sheet
  sw,sh--pixel size (width&height)
 }
end


function objects:create(_x,_y,_t)
 local obj = obj_template()
 obj.t = _t
 obj.x = _x
 obj.y = _y
 --get collision (hitbox) data
 obj.cw = obj_cw[_t]
 obj.ch = obj_ch[_t]
 --get sprite data for sspr
 obj.sx = obj_sx[_t]
 obj.sy = obj_sy[_t]
 obj.sw = obj_sw[_t]
 obj.sh = obj_sh[_t]
 return obj
end

function objects.chars:create(_x,_y,_t)
 local obj = objects:create(_x,_y,_t)
 if _t == obj_cade then
  obj.frames = {
		 {0,0}, --1 = none
		 {0,1}, --2 idle
		 {0,5},  --3 jump up
		 {0,3},  --4 jump down
		 {0,4},  --5 walk
		 {6,6,6,7,7,7}   --6 die
		}
		obj.hp = player_hp
		obj.speed = player_speed
 elseif _t == obj_jack then
  obj.frames = {
		 {1,0}, --1 = attack
		 {0,1}, --2 idle
		 {2,3},  --3 jump up
		 {3,4},  --4 jump down
		 {1,2},  --5 walk
		 {5,6,7,8} --6 die
		}
		obj.hp = jack_hp
		obj.speed = rnd(jack_speed*0.25)+jack_speed*0.75
 elseif _t == obj_dan then
  obj.frames = {
		 {1,0}, --1 = attack
		 {0,1}, --2 idle
		 {2,3},  --3 jump up
		 {3,4},  --4 jump down
		 {1,2},  --5 walk
		 {5,6,7,8} --6 die
		}
		obj.hp = dan_hp
		obj.speed = rnd(dan_speed*0.25)+jack_speed*0.75
 end
 add(objects.chars,obj)
 return obj
end

function objects.blocks:create(_x,_y,_t)
 local obj = objects:create(_x,_y,_t)
 --individual block data
 if _t ==obj_platform then
  obj.grounded = true
 end
 if _t ==obj_cannonball then
  obj.vx = flr(-rnd(1)+rnd(1))
--  obj.vy = --flr(4 +rnd(4))
 end
 if _t == obj_chest then
  obj.hp = chest_hp
 end
 if _t == obj_barrel then
  obj.hp = barrel_hp
 end
 --save to table
 add(objects.blocks,obj)
 return obj
end


function objects.projectiles:create(_x,_y,_vx,_vy,_t,_owner)
 local obj = objects:create(_x,_y,_t)
 obj.vx = _vx
 obj.vy = _vy
 obj.owner = _owner
 if obj.t == obj_bomb then
  obj.cooldown = rnd(24) + 8
 elseif obj.t == obj_swordstrike then
  obj.cooldown = 6
 end
 add(objects.projectiles,obj)
 return obj
end

frame = 0
function objects:update()
 objects.chars:update()
 objects.blocks:update()
 objects.projectiles:update()
end


--delete when leaving the screen
function objects:leftscreen(obj)
 if obj.x < 0 or obj.x > 128
 or obj.y < -2 or obj.y > 128
 then
  return true
 end
end


function objects.chars:update()
 for chr in all(objects.chars) do


  if chr.t ~= obj_cade then
   enemy:update(chr)
  end
  --animation update
  if (frame%chr.ffreq == 0) then
 		chr.findex += 1
 		if (chr.findex > #chr.frames[chr.astate]) then
 			chr.findex = 1
 		end
 	end
  if chr.hp>0 then
   if chr.damage then
    chr.hp -=1
    particles:create(chr.x,chr.y,8)
    chr.damage = false
   end
   --animation
   chr.astate = 2 -- idle
   if chr.vx ~= 0 then
    chr.astate = 5 -- walk
   end
   if chr.vy < 0 then
    chr.astate = 3 --jump down
   elseif chr.vy > 0 then
    chr.astate = 4 --jump up
   end

   --grounded if on bottom
   if chr.y+(chr.sh*chr.scale)*0.5 > 124 then
    if --chr.grounded == false
     chr.vy ~= 0
     --and frame %collision_recheck_freq == 0
    then
     sfx(sfx_grounded,1)
     dust:create(chr.x,chr.y,chr.vy+chr.vx,-chr.vx,-chr.vy)
    end
    chr.grounded = true
    chr.vy = 0
    chr.y = 125-(chr.sh*chr.scale)*0.5
   end
   --move by velocity
   chr.x += chr.vx*chr.speed
   --not grounded (falling)
   if not chr.grounded then
    --save old position
    local old = {x=chr.x, y=chr.y}

    --add gravity + velocity
    --to pos (fall)
    chr.y += chr.vy*chr.speed
           + level.gravity
    --add gravity
    chr.vy += level.gravity
    --check for collision when falling
    if chr.vy > 0 then
   --  for k, v in pairs(objects) do
    --  if type(v)=="table" then
     --  for other in all(v) do
      --  if other ~=chr
     for other in all(objects.blocks) do
      if other.t ~= obj_coint
      and other.t ~= obj_heart
      then
       if chr.letfall==false
       or (chr.letfall
       and other ~= chr.groundobj
       and other.y <= chr.y)
       then
        if collision(chr,other) then
         if chr.y > chr.oldy+4 then --frame %collision_recheck_freq ~= 0 then
          sfx(sfx_grounded,1)
          dust:create(chr.x,chr.y,chr.vy+chr.vx,-chr.vx,-chr.vy)
         end
         other.grounded = false
         chr.x = old.x
         chr.y = old.y
         chr.vy = 0
         chr.groundobj = other
         chr.grounded = true
         chr.oldy = chr.y
        end
       end
      end
     end
     --  end
    --  end
   --  end
    end

   --grounded(not moving)
   else

    chr.letfall = false

    --recheck collision all 8 frames
    if frame%collision_recheck_freq== 0 then
     chr.grounded = false
    end

    --delete when out of screen
    if objects:leftscreen(chr) then
     del(objects.chars,chr)
    end
  	end
  end
 end
end

function objects.blocks:update()
 for blk in all(objects.blocks) do

  --delete when out of screen
  if objects:leftscreen(blk) then
   del(objects.blocks,blk)
  end
  if blk.t == obj_coin
  or blk.t == obj_heart
  then
   item_update(blk)
  end
  --damage
  if blk.damage then
   blk.hp-=1
   
   sfx(sfx_blockdamage,1)
   if blk.hp<= 0 then
    if blk.t == obj_chest
    or blk.t == obj_barrel then
     item_drop(blk.x,blk.y,blk.t)
     particles:create(
      blk.x,
      blk.y,
      15,32,true
     )
    end
    if blk.t == obj_coin then
     particles:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
      10,16
     )
    end
    if blk.t == obj_heart then
     particles:create(
      blk.x-blk.cw*0.25,
      blk.y-blk.ch*0.25,
      8,16
     )
    end
    del(objects.blocks,blk)
   end
   --damage calc over .. reset
   blk.damage = false
  end

  --ground if on bottom
  if blk.y+blk.sh*0.5 > 122 then
   --let cannonballs and platforms pass
   if blk.t  ~= obj_platform
   and blk.t ~= obj_cannonball
   then
    if blk.vy ~=0
    then
    	dust:create(blk.x,blk.y,blk.vy+blk.vx,-blk.vx,-blk.vy)
     	sfx(sfx_grounded,1)
    	if blk.vy >= 4 then
     	sfx(sfx_hardfall,1)
     end
    end
    blk.grounded = true
    blk.vy = 0
   end
  end

  --not grounded (falling)
  if blk.grounded == false then
   --save old position
   local old = {x=blk.x, y=blk.y}

   --player controlled fall
   if pobj == blk then
    blk.x += blk.vx
    blk.y += blk.vy
    for other in all(objects.blocks) do
     if other ~= blk then
      if collision(blk,other)
      and (other.t == obj_chest 
       or other.t == obj_barrel) 
      then
       pobj = nil
      end
     end
    end
   --normal fall
   else
    --move by velocity
    blk.x += blk.vx
    --add gravity
    blk.vy += level.gravity
    --fall
    blk.y += blk.vy
   end


   --check for collision
   for k, v in pairs(objects) do
    if type(v)=="table" then
     for other in all(v) do
      if other ~=blk then
       if collision(blk,other)
       and (other.t == obj_platform and other.damage) ==false
       and other.t ~= obj_cannonball
       then
        --if fast enough
        if blk.vy > 6
        then
         other.damage = true
        end

        --ignore chars for grounding
        if (other.t == obj_chest 
        or other.t == obj_barrel)
        and other.y > blk.y+8 then
         if other ~= blk.groundobj then
      			 dust:create(blk.x,blk.y,blk.vy+blk.vx,-blk.vx,-blk.vy)
         	sfx(sfx_grounded,1)
         	if blk.vy >= 4 then
          	sfx(sfx_hardfall,1)
          end
         end
         blk.x = old.x
         blk.y = old.y
         blk.vy = 0
         blk.grounded = true
         blk.groundobj = other
        end
       end
      end
     end
    end
   end



  --grounded(not moving)
  else

   --disable pobj
   if pobj == blk then
    pobj = nil
   end
   --recheck all 8 frames
   if frame %collision_recheck_freq == 0
    and blk.t ~= obj_platform then
    blk.grounded = false
   end
  end
 end
end

function objects.projectiles:update()
 for pjt in all(objects.projectiles) do

  --delete when out of screen
  if objects:leftscreen(pjt) then
   del(objects.projectiles,pjt)
  end


  if pjt.t == obj_bomb then
   --spawn particles for bomb
   if frame%8 == 0 then
    local poffset
    local pcolor
    if rnd(10)>7 then
     pcolor = 9
    else
     pcolor = 10
    end
    particles:create(
     pjt.x - 2,
     pjt.y - 2,
     pcolor
     ,
     flr(rnd(4)+4),
     true
    )

   end
   pjt.cooldown-=1
   if pjt.cooldown<=0 or pjt.y > 124then
    explosion:create(pjt.x-8,pjt.y-8)
    explosion:create(pjt.x+8,pjt.y+8)
    del(objects.projectiles,pjt)
   end

   pjt.vy += level.gravity
  elseif pjt.t == obj_swordstrike then
   pjt.cooldown-=1
   if pjt.cooldown<=0 then
    del(objects.projectiles,pjt)
   end
  end

  pjt.x += pjt.vx
  pjt.y += pjt.vy
  for chr in all(objects.chars) do
  	if chr ~= pjt.owner
  	and collision(pjt,chr) then
  	 chr.damage = true
    if pjt.t == obj_bomb then
     explosion:create(pjt.x-8,pjt.y-8)
     explosion:create(pjt.x+8,pjt.y+8)
    end

   	del(objects.projectiles,pjt)
  	end
  end
 end
end

function objects.chars:draw()
 for obj in all(objects.chars) do
  local sxanimation =0
  if obj.t == obj_jack or obj.t == obj_dan then
   sxanimation = obj.frames[obj.astate][obj.findex]*obj.sw
 	end
  if obj ~= player then
   sspr(
    obj.sx+sxanimation,
    obj.sy,
    obj.sw,
    obj.sh,
    obj.x - obj.sw * 0.5,--upper left corner
    obj.y - obj.sh * 0.5,--of the sprite
    obj.sw,
    obj.sh,
    obj.flip_x,
    obj.flip_y
   )
   if debug then
    rect(
     obj.x-obj.cw*0.5,
     obj.y-obj.ch * 0.5,
     obj.x+obj.cw*0.5,
     obj.y+obj.ch * 0.5,
     7
    )
    print("hp: "..obj.hp
          .."\ngrnd: "..tostr(obj.grounded)

    ,obj.x-20,obj.y-20)

    line(obj.x+obj.vx*7,obj.y+obj.vy*7,obj.x,obj.y)
   end
  end
 end
end
function objects.blocks:draw()
 for obj in all(objects.blocks) do
  local sxanimation = 0
  if obj.t == obj_chest or obj.t == obj_barrel then
   if obj.hp==1 then
    sxanimation = 16
   end
  end

  sspr(
   obj.sx+sxanimation,
   obj.sy,
   obj.sw,
   obj.sh,
   obj.x - obj.sw * 0.5,--upper left corner
   obj.y - obj.sh * 0.5,--of the sprite
   obj.sw,
   obj.sh,
   obj.flip_x,
   obj.flip_y
  )
  if debug then
   rect(
    obj.x-obj.cw*0.5,
    obj.y-obj.ch * 0.5,
    obj.x+obj.cw*0.5,
    obj.y+obj.ch * 0.5,
    7
   )
  --line(obj.x,obj.y+16,obj.x+obj.vx,obj.y+obj.vy)
   print("hp: "..obj.hp
         .."\ngrnd: "..tostr(obj.grounded)

   ,obj.x-20,obj.y-20)

   line(obj.x+obj.vx*7,obj.y+obj.vy*7,obj.x,obj.y)
  end
 end
end

function objects.projectiles:draw()
 for obj in all(objects.projectiles) do
  if rnd(3) > 1 and obj.vy ~= 0 then
   local _amount = rnd(4)
   for i=1, _amount do
   	pset(
     obj.x-(obj.vx*rnd(3)),
     obj.y-(obj.vy*rnd(3))
     ,6
    )
   end
  end
  sspr(
   obj.sx,
   obj.sy,
   obj.sw,
   obj.sh,
   obj.x - obj.sw * 0.5,--upper left corner
   obj.y - obj.sh * 0.5,--of the sprite
   obj.sw,
   obj.sh,
   obj.flip_x,
   obj.flip_y
  )
  if debug then
   rect(
    obj.x-obj.cw*0.5,
    obj.y-obj.ch * 0.5,
    obj.x+obj.cw*0.5,
    obj.y+obj.ch * 0.5,
    7
   )
   --line(obj.x,obj.y,obj.x+obj.vx,obj.y+obj.vy)
   print("hp: "..obj.hp
         .."\ngrnd: "..tostr(obj.grounded)

   ,obj.x-20,obj.y-20)

   --line(obj.x-20,obj.y-20,obj.x,obj.y)
  end
 end
end

function player_draw()
 --hardcode overdraw player sprite
 sspr(
  player.sx+player.frames[player.astate][player.findex]*player.sw,
  player.sy,
  player.sw,
  player.sh,
  player.x - player.sw * 0.5- ((player.scale-1)*(player.sw*0.5)),
  player.y - player.sh * 0.5 - ((player.scale-1)*(player.sh*0.5)),--of the sprite
  player.sw*player.scale,
  player.sh*player.scale,
  player.flip_x,
  player.flip_y
 )
 if player.hp>0
 and rnd(3) > 1 and player.vy ~= 0 then
  local _amount = rnd(4)
  for i=1, _amount do
  	pset(
    player.x-rnd(3)+rnd(3)-(player.vx*rnd(3)),
    player.y+8-(player.vy*rnd(3))
    ,6
   )
  end
 end
 --playergun
 if player.invobj == obj_gun then
  sspr(
   playergun.sx+playergun.frames[playergun.astate][playergun.findex]*playergun.sw,
   playergun.sy,
   playergun.sw,
   playergun.sh,
   playergun.x - playergun.sw * 0.5,--upper left corner
   playergun.y - playergun.sh * 0.5,--of the sprite
   playergun.sw,
   playergun.sh,
   playergun.flip_x,
   playergun.flip_y
  )
 --player sword
 elseif player.invobj == obj_sword then
  sspr(
   playersword.sx+playersword.frames[playersword.astate][playersword.findex]*playersword.sw,
   playersword.sy,
   playersword.sw,
   playersword.sh,
   playersword.x - playersword.sw * 0.5,--upper left corner
   playersword.y - playersword.sh * 0.5,--of the sprite
   playersword.sw,
   playersword.sh,
   playersword.flip_x,
   playersword.flip_y
  )
 end
 if debug then
  rect(
   player.x-player.cw*0.5,
   player.y-player.ch * 0.5,
   player.x+player.cw*0.5,
   player.y+player.ch * 0.5,
   7
  )
 end
end
-------------------------------
--explosion
explosion = {}

function explosion:create(_x,_y)
 shake = true
 local exp = {
  x = _x,
  y = _y,
  vx = rnd(1)-rnd(1),
  vy = 3+rnd(),

  sx = obj_sx[obj_explosion],
  sy = obj_sy[obj_explosion],
  sw = obj_sw[obj_explosion],
  sh = obj_sh[obj_explosion],
  cw = 1,
  ch = 1,

  scalex = 1+rnd(),
  scaley = 1+rnd(),

  damage = true,
  --animation
		findex = 1,
  ffreq  = 4,
  frames = {0,1,2}
 }
 sfx(sfx_explode,2)
 add(explosion,exp)
-- particles:create(_x,_y,9,24)
 spr_particles:create(_x,_y,obj_explosion,4)
end
function explosion:update()
 for exp in all(explosion) do
  if frame % exp.ffreq == 0 then
   exp.findex += 1
    --cycled through animation frames?
   if exp.findex > #exp.frames then
    --smoke frame remains..
    exp.findex = #exp.frames
   end
  end
  --half through animation?
 -- if frame / exp.ffreq
 -- < exp.ffreq*#exp.frames*0.5
  if exp.findex == 1 then
   exp.cw += 3
   exp.ch += 3
 -- elseif frame / exp.ffreq
 -- == exp.ffreq*0.5
  elseif exp.findex == 2 then
   exp.cw += 4
   exp.ch += 4
   if exp.damage == true then
    --spread damage
    for k, v in pairs(objects) do
     if type(v)=="table" then
      for other in all(v) do
       if other.t ~= obj_coin
       and other.t ~= obj_heart then
        if collision(exp,other) then
         other.damage = true
        end
       end
      end
     end
    end
    exp.damage = false
   end
 -- elseif frame / exp.ffreq
 -- > exp.ffreq*0.5
  elseif exp.findex == 3 then
   exp.x += exp.vx
   exp.y -= exp.vy

   exp.cw -= 0.5
   exp.ch -= 0.5

   if exp.cw < 0 then
    del(explosion,exp)
   end
  end
 end
end
function explosion:draw()
 for exp in all(explosion) do
  --debug circ
  sspr(
   exp.sx+exp.frames[exp.findex]*exp.sw,
   exp.sy,
   exp.sw,
   exp.sh,
   exp.x-exp.cw,exp.y-exp.ch,
   exp.cw*exp.scalex,exp.ch*exp.scaley
  )
 end
end


-------------------------------
--block drop
blockdropadd = 0
function block_drop()
 if frame % (blockdropfreq+blockdropadd) == 0 then
--  blockdropadd = flr(-rnd(32)+rnd(32))
  --spawn object
  local nextobj
  if rnd(10)>=5 then
   nextobj = obj_chest
  else
   nextobj = obj_barrel
  end

  if (pobj~=nil
   and (pobj.grounded == true
   or pobj.vy <= 0.5)
   and difficulty == "easy")
  or (pobj~=nil
   and difficulty == "hard")
  or pobj == nil
  then
   pobj =
   --snapped spawn? flr((rnd(128))/8)*8,0
   objects.blocks:create(flr((rnd(128))/8)*8,2,nextobj)
   pobj.vy = 1
  end
 end
end
-------------------------------
--player (mirror of char 1)
player = {}
playergun ={}
function player_init()
 player = objects.chars:create(64,8,obj_cade)
 player.grounded = false
 player.invobj = obj_sword
 player.coins = 0
 player.hp = player_hp

 playersword = objects:create(player.x,player.y,obj_sword)
 playersword.frames = {
		{0,0},--just hold it..
		{0,1}--swing
	}
	playersword.ffreq = 4

 playergun = objects:create(player.x,player.y,obj_gun)

 playergun.frames = {
		{0,0},--just hold it..
		{0,1,2,3}--shoot
	}
	playergun.ffreq = 4
end

function player_update()
 if player.damage then
  itemparticle:create(ui.x+ player.hp * 10,ui.y,obj_heart,true)
  sfx(sfx_hurt,3)
  shake = true
 end
 --test test test
 if player.hp >= 6 then
  player.scale = 2
  player.cw = obj_cw[obj_cade]*2
  player.ch = obj_ch[obj_cade]*2
 else
  player.scale = 1
  player.cw = obj_cw[obj_cade]
  player.ch = obj_ch[obj_cade]
 end
 --losing condition
 if player.hp <= 0 then
  music(-1,300)
  sfx(sfx_gameover)
  games_lost += 1
  game_state = game_over
 end
 --winning condition
 if player.y < -player.sh*0.5 then
  music(-1)
  if music_on then
   music(5,0,4)
  end
  games_won += 1
  game_state = game_won
 end
 --player weapons lil messy hard code :(
 --gun---
 playersword.flip_x = player.flip_x
 playergun.flip_x = player.flip_x

 local psword_offset = 0
 if playersword.flip_x then
  psword_offset = -14
 else
  psword_offset = 14
 end

 local pgun_offset = 0
 if playergun.flip_x then
  pgun_offset = -14
 else
  pgun_offset = 14
 end

 playersword.x = player.x+psword_offset
 playersword.y = player.y+2

 if (frame%playersword.ffreq == 0) then
		playersword.findex += 1
		if (playersword.findex > #playersword.frames[playersword.astate]) then
			playersword.findex = 1
			playersword.astate = 1
		end
	end

 playergun.x = player.x+pgun_offset
 playergun.y = player.y+2

 if (frame%playergun.ffreq == 0) then
		playergun.findex += 1
		if (playergun.findex > #playergun.frames[playergun.astate]) then
			playergun.findex = 1
			playergun.astate = 1
		end
	end


 --reset vel x
 player.vx = 0

 if player.cooldown > 0 then
  player.cooldown-= 1
 end
 --attack !
 if btn(5) then
  if player.cooldown<=0 then
   local _vx=0
   local _vy=0
   if btn(0) then
    _vx = -1
    player.flip_x = true
   end
   if btn(1) then
    _vx = 1
    player.flip_x = false
   end
   if btn(2) then
    _vy = -1
   end
   if btn(3) then
    _vy = 1
   end
   --throwback from gun
   if player.invobj == obj_gun then
    if _vx~=0
    and player.x > 2
    and player.x < 126
    then
     player.vx =  -(_vx*1.5)
    end
    if _vy~=0 then
     player.vy =  -(_vy*1.1)
    end
   end
   if _vx ~= 0 or _vy ~= 0 then
    player.cooldown = 8
    if player.invobj == obj_gun then
     objects.projectiles:create(
      playergun.x,playergun.y-2,
      _vx*4,_vy*4,
      obj_cannonball,
      player)
      sfx(sfx_shoot,3)
      dust:create(
       playergun.x,
       playergun.y-8,
       5,
       0,-2)
     playergun.astate = 2
    elseif player.invobj == obj_sword then
     --check if hit something
     for chr in all(objects.chars) do
      if chr ~= player
      --other is in range
      and abs(player.x-chr.x)<8
      and abs(player.y-chr.y)<6
      then
       chr.damage=true
      end
     end
     objects.projectiles:create(
      player.x,player.y,
      _vx*4,_vy*4,
      obj_swordstrike,
      player)
     playersword.astate = 2
     sfx(sfx_sword,3)
    end
   end
  end
 --move tetris blocks and
 --navigate through inventory
 elseif btn(4) then

  if btn(0) and pobj~=nil
  and pobj.x > 8 then
   pobj.x-=4
   particles:create(pobj.x,pobj.y,6,8)
   
  end
  if btn(1) and pobj~=nil
  and pobj.x < 120 then
   pobj.x+=4
   particles:create(pobj.x,pobj.y,6,8)
   
  end
  --throw tetris block down
  if btn(3) and pobj~=nil
  and player.coins > 0
  then

   player.coins-=1
   itemparticle:create(ui.x,ui.y,obj_coin,true)
   particles:create(pobj.x,pobj.y,10,32)
   pobj.vy = 4
   pobj = nil
  end
  --switch inventory item
  if btnp(2) then
   if player.invobj == obj_gun then
    player.invobj = obj_sword
   elseif player.invobj == obj_sword then
    player.invobj = obj_gun
   end
  end
 --no violence? move then...
 else
  if btn(0) and player.x > 2 then
   player.vx = -1
   player.flip_x = true
  end
  if btn(1) and player.x < 126 then
   player.vx = 1
   player.flip_x = false
  end
  --jump
  if btn(2)
  and player.grounded then
   player.vy = -3.5*player.speed
   player.grounded = false
   player.y-=3
   sfx(sfx_jump,3)
   --player.flip_x = true
  end
  --let fall (jump down)
  if btn(3)
  and player.grounded
  and player.groundobj ~= nil then
   player.letfall = true
   player.grounded = false
  -- player.vy = 1
  -- player.y+=2
  end
 end
end
--------------------------------
--enemy
enemy={
 jacks,--how many jack and dans
 dans  --are there?
}
function enemy:init()
 enemy.spawnfreq = enemy_spawnfreq
end
function enemy:create(obj)
 local x
 local y= rnd(120)
 if rnd(10)>5 then
  x = 124
 else
  x = 2
 end
 objects.chars:create(x,y,obj)
end
function enemy:spawn()
 if frame % enemy.spawnfreq == 0
  and #objects.chars < max_enemies+1
 then
  local obj
  if rnd(10)>4 then
   obj = obj_jack
  else
   obj = obj_dan
  end
  if player.y < 70 then
   obj = obj_dan
  end
  enemy:create(obj)
  --more spawns in relation
  --to block count
  local additionalcount =
   #objects.blocks/4
  for i=0, additionalcount do
   if rnd(10) > 8 then
    if rnd(10)>4 then
     obj = obj_jack
    else
     obj = obj_dan
    end
    if player.y < 80+rnd(10) then
     obj = obj_dan
    end
    enemy:create(obj)
   end
  end
  --only player ingame?
  if #objects.chars < 2 or player.y < 60 then
   enemy:create(obj)
   --more spawns!
   enemy.spawnfreq = rnd(enemy_spawnfreq*0.5)
  else
   enemy.spawnfreq = rnd(enemy_spawnfreq)+enemy_spawnfreq*0.5
  end
 end
end
function enemy:update(chr)
 --cooldown decrease
 if chr.cooldown>0 then
  chr.cooldown-=1
 end
 --damage sound
 if chr.damage and chr.hp>0 then
  sfx(sfx_skeletonhurt,1)
 end
 --kill if necessary
 if chr.hp <= 0 and chr.hp > -100 then
  if chr.t == obj_dan then
   explosion:create(chr.x-4,chr.y)
   objects.projectiles:create(
    chr.x,chr.y,
    (-rnd()+rnd())*0.5,-rnd(2)-1.5,
    obj_bomb,chr
   )
  else--eif rnd(10)>6 then
   explosion:create(chr.x,chr.y)
  end

  item_drop(chr.x,chr.y)
  chr.astate = 6
  chr.findex = 1
 --lastminute code alert!
  chr.hp = -100
 end
 --hardcode death state wait for anim
 if chr.hp == -100 and chr.findex==#chr.frames[chr.astate]-1
 and frame%chr.ffreq*0.9 == 0
 then
  del(objects.chars,chr)
 end
 if chr.hp > 0 then
  --randomize velocity
  if chr.vx ~= 0 then
   chr.vx += rnd()*chr.vx*0.25
  end
 --jack .. a skeleton with a sword
  if chr.t == obj_jack then

   --get horizontal distance to player
   if abs(chr.x-player.x) <= 8 then
    --close enough for melee?
    if abs(chr.y-player.y) < 8
    and abs(chr.x-player.x) >= 4
    then
     --cooldown passed
     if chr.cooldown <= 0 then
      --player.hp -= 1
      chr.astate = 1
      player.damage = true
      chr.cooldown = 24
      sfx(sfx_sword,1)
     --idle for cooldown
     else
      chr.astate = 2
     end
    --to high or low for melee?
    elseif chr.grounded then
     --player above? -> jump
     if chr.y > player.y then
      chr.vy = -3.5*chr.speed
      chr.y-=3
      chr.grounded = false
      sfx(sfx_jump,1)
     --player below? -> fall
     elseif chr.groundobj ~= nil then
      chr.letfall = true
      chr.grounded = false
     end
    end
   --not close enough .. get closer
   else
    if player.x > chr.x then
     chr.vx = 1+rnd()*0.125
     chr.flip_x = true
    else
     chr.vx = -1-rnd()*0.125
     chr.flip_x = false
    end
   end
  end
 --skeleton with a bomb
 --he will stay on the groundlane,
 --if the player is to high, he will
 --throw boms, otherwise he will
 --detonate
  if chr.t == obj_dan then
   --spawn particles for bomb
   if frame%8 == 0 then
    local poffset
    if chr.flip_x then
     poffset = 4
    else
     poffset = -4
    end
    local pcolor
    if rnd(10)>7 then
     pcolor = 9
    else
     pcolor = 10
    end
    particles:create(
     chr.x + poffset,
     chr.y - 2,
     pcolor
     ,
     flr(rnd(4)+12),
     true,16
    )
   end
   --ai logic
   --get horizontal distance to player
   if abs(chr.x-player.x) < 8 then
    --close enough for detonation?
    if abs(chr.y-player.y) < 8 then
     --detonate!!!!
     chr.hp=0
    -- del(objects.chars,chr)
    --to high or low for detonation?
    elseif chr.grounded then
     --player above? -> jump
     if chr.y > player.y then

      --cooldown passed?
      --throw bomb upwards!
      if chr.cooldown <= 0 then
       objects.projectiles:create(
        chr.x,chr.y,
        0,-5-rnd(4),
        obj_bomb,chr)
       chr.cooldown = 32
      --idle for cooldown
      else
       chr.astate = 2
      end
     --player below? -> fall
     elseif chr.groundobj ~= nil then
      chr.letfall = true
      chr.grounded = false
     end
    end
   --not close enough .. get closer
   else
    if player.x > chr.x then
     chr.vx = 1+rnd()*0.125
     chr.flip_x = true
    else
     chr.vx = -1-rnd()*0.125
     chr.flip_x = false
    end
   end
  end
 end
end
-------------------------------
--items
--item drop
function item_drop(_x,_y,_t)
 if rnd(10)>5 then
  if _t == nil then
   if rnd(10)>3 then
    _t = obj_chest
   else
    _t = obj_barrel
   end
  end
  local idrop-- = obj_coin
  if _t == obj_chest then
   idrop = obj_coin
  end
  if _t == obj_barrel then
   idrop = obj_heart
  end
  if idrop ~= nil then
   objects.blocks:create(_x,_y,idrop)
  end
 end
end
function item_update(obj)
 obj.y = obj.y + sin(frame/8)*0.3
 if abs(player.x-obj.x)
   +abs(player.y-obj.y)
   < 12
 then
  --if obj.t == obj_coin then
  -- player.coins +=1
 -- end
  --if obj.t == obj_heart then
  -- player.hp +=1
  --end
 itemparticle:create(obj.x,obj.y,obj.t)
 sfx(sfx_pickup,1)
 del(objects.blocks,obj)
 end
end
-------------------------------
--cam
cam = {x=64,y=64,speed=0.05}
function lerp(a,b,t)
 if (t<0) then return a end
 if (t>1) then return b end
 return a + (b-a)*t
end
-------------------------------
--ui
ui = {
 x = 2,
 y = 2
}
function ui:draw()
 --block spawn
 local length =
 frame % (blockdropfreq+blockdropadd)
 line(
  ui.x,
  ui.y-2,
  ui.x+length,
 	ui.y-2,
 	15
 )

 --health display
 for i=1,player.hp do
  spr(
   104,
   ui.x+ i * 10,
   ui.y
  )
 end
 --coin display
 spr(
  105,
  ui.x,
  ui.y+6
  )
 print(player.coins,ui.x+10,ui.y+8,7)
end
-------------------------------
--particles
particles = {}
function particles:create(_x,_y,_c,_a,_circl,_lifeadd)
 if _a == nil then
  _a = 16
 end
 for i=1, _a do
  local angle = rnd()
  local speed = 1 + rnd()
  local p = {
   x = _x,
   y = _y,
   vx = (-rnd(1)+rnd(1))*speed,
   vy = (-rnd(1)+rnd(1))*speed,
   c = _c,--rnd(15) for random color
   life = 8+ rnd(20)
  }
  if _circl ~= nil and _circl then
   p.vx = sin(angle)*speed
   p.vy = cos(angle)*speed
  end
  if _lifeadd ~= nil then
   p.life += _lifeadd
  end
  add(particles,p)
 end
end
function particles:update()
 for p in all(particles) do
  if p.life > 32 then
   del(particles,p)
  else
   p.x += p.vx
   p.y += p.vy
   p.life += 1
  end
 end
end
function particles:draw()
 for p in all(particles) do
  pset(p.x,p.y,p.c)
 end
end

spr_particles = {}
function spr_particles:create(_x,_y,_t,_a)
 for i=1, _a do
  local speed = rnd(4)+4
  local p = {
   x = _x,
   y = _y,
   vx = (-rnd(1)+rnd(1))*speed,
   vy = -rnd(1)*speed,
   t = _t,
   life =  32 + rnd(32)
  }
  add(spr_particles,p)
 end
end

function spr_particles:update()
 for p in all(spr_particles) do
  if p.life > 64 then
   del(spr_particles,p)
  else
   p.x += p.vx
   p.y += p.vy
   p.x = p.x + cos(p.y/32)
   p.life += 1
  end
 end
end
function spr_particles:draw()
 for p in all(spr_particles) do
  if p.t == obj_brokenwood then
   spr(68,p.x,p.y)
  end
  if p.t == obj_explosion then
   spr(73,p.x,p.y)
  end
 end
end
-------------------------------
--item particles
itemparticle = {}
function itemparticle:create(_x,_y,_t,_lost)
 local p = {
  x=_x,
  y=_y,
  t=_t,
  vx=-rnd()+rnd(),
  vy = 1,
  l=false
 }
 if _lost then p.l = true end
 add(itemparticle,p)
end
function itemparticle:update()
 for p in all(itemparticle) do
  if p.l == false then
   if p.t == obj_coin then
    p.x = lerp(p.x,ui.x,0.1)
    p.y = lerp(p.y,ui.y,0.1)
    if (abs(p.x-ui.x)+abs(p.y-ui.y) )
    < 8 then
     player.coins +=1
     sfx(sfx_coin,1)
     del(itemparticle,p)
    end
   elseif p.t == obj_heart then
    p.x = lerp(p.x,ui.x+ (player.hp+1) * 10,0.1)
    p.y = lerp(p.y,ui.y,0.1)
    if (abs(p.x-(ui.x+ (player.hp+1) * 10))+abs(p.y-ui.y) )
    < 10 then
     if player.hp <= 9 then
      player.hp +=1
     else
      player.coins +=1
     end
     sfx(sfx_heart,1)
     del(itemparticle,p)
    end
   end
  else
   p.x += p.vx
   p.vy += level.gravity
   p.y += p.vy
  end
 end
end
function itemparticle:draw()
 for p in all(itemparticle) do
  sspr(
   obj_sx[p.t],
   obj_sy[p.t],
   obj_sw[p.t],
   obj_sh[p.t],
   p.x,
   p.y,
   obj_sw[p.t]*0.8,
   obj_sh[p.t]*0.8
  )
 end
end

-------------------------------
--dust
dust = {}
function dust:create(_x,_y,_scale,_vx,_vy)
 for i=1, _scale*3 do
  if _vx == nil then
   _vx = 0
  end
  if _vy == nil or _vy == 0 then
   _vy = -1
  end
  local d = {
   x = _x-rnd(12)+rnd(12),
   y = _y+8-rnd(8)+rnd(8),
   r = _scale*rnd()*0.5,
   vx = _vx,
   vy = _vy,
   life = 20 + rnd(20)
  }
  add(dust,d)
 end
end
function dust:update()
 for d in all(dust) do
  d.x += d.vx
  d.y += d.vy *0.5
  d.r -= 0.1
  d.life -= 1
  if d.life < 0
  or d.y<0 or d.x < 0
  or d.y > 128 or d.y > 128 then
   del(dust,d)
  end
 end
end

function dust:draw()
 for d in all(dust) do
  circfill(
   d.x,
   d.y,
   d.r,
   6
  )
 end
end

-------------------------------
--game_over_circ
game_over_circ = {
 sx = 48,
 sy = 48,
 x=0,y=0,
 sw = 16,
 sh = 16,
 scale = 8
}
function game_over_circ:update()
 game_over_circ.x = player.x
  - game_over_circ.sw* 0.5
  * game_over_circ.scale
 game_over_circ.y = player.y
  - game_over_circ.sh* 0.5
  * game_over_circ.scale
 if game_over_circ.scale >0.01 then
  game_over_circ.scale-=0.4
 end
end
function game_over_circ:draw()

 sspr(
  game_over_circ.sx,
  game_over_circ.sy,
  game_over_circ.sw,
  game_over_circ.sh,
  game_over_circ.x,
  game_over_circ.y,
  game_over_circ.sw *
  game_over_circ.scale,
  game_over_circ.sh *
  game_over_circ.scale
 )
 --top overdraw
 rectfill(
  cam.x-68,
  cam.y-68,

  cam.x+68,

  game_over_circ.y,
  0
 )
 --bottom overdraw
 rectfill(
  cam.x-68,
  cam.y+68,

  cam.x+68,

  game_over_circ.y+
  game_over_circ.sh*
  game_over_circ.scale-4,
  0
 )
 --left overdraw
 rectfill(
  cam.x-68,
  cam.y-68,
  game_over_circ.x,
  game_over_circ.y+
  game_over_circ.sh*
  game_over_circ.scale,
  0
 )
 --right overdraw
 rectfill(
  game_over_circ.x+
  game_over_circ.sw*
  game_over_circ.scale-4,
  cam.y-68,
  cam.x+68,
  cam.y+68,
  0
 )
end
-------------------------------
--intro
ship = {
 x = -140,
 y = 0
}

function ship:draw()
 map(0,0,ship.x,ship.y,24,12)
 line(--rope
  ship.x + 24*8,
  ship.y + 3*9,
  ship.x + 18*8,
  ship.y,7
 )
 line(--rope
  ship.x + 24*8,
  ship.y + 3*9,
  ship.x + 18*8,
  ship.y,7
 )
end
function ship:update()
 if ship.x<0 then
  ship.x += 1
 end
 ship.y = ship.y + sin(frame/64)*0.125
end
wave = {
 x = 0,
 y = 86,
 d = 0
}
function wave:update()
 if wave.d == 0  then
  wave.x += 0.25
  if wave.x > 12 then
   wave.d = 1
  end
 end
 if wave.d == 1 then
  wave.x -= 0.25
  if wave.x < 1 then
   wave.d= 0
  end
 end
 wave.y = wave.y + sin(frame/32)*0.125
end
function wave:draw()
 for i = 0, 32 do
   spr(254,-32+wave.x+i*8,wave.y)
  end
  rectfill(0,wave.y+8,128,128,1)
end
zombieship ={
 x =128,
 y =80
}
function zombieship:update()
 zombieship.x -= 1.75
 zombieship.y = zombieship.y + sin(frame/16)*0.5
end
function zombieship:draw()
 map(
  27,4,
  zombieship.x,zombieship.y,
  5,2
 )
end
speechbubble = {
x=2,
y=54,
w = 124,
h = 48,
s = ""
}
function speechbubble:draw()
 sspr(
  112,112,16,8,
  speechbubble.x,
  speechbubble.y,
  speechbubble.w,
  speechbubble.h
 )
 print(
  speechbubble.s,
  speechbubble.x+10,
  speechbubble.y+20,
  0
 )
end
function speechbubble:addchar(chr)
 if chr == "+" then 
  chr = "\n"
 end
 speechbubble.s= speechbubble.s..chr
end
cade_text = "arrr... it's captain cade!+something weird is going+on in the lower deck...          "
cade_text2 = "i need to get down there+and check it out!     "
cade_textindex = 1
function cade_talks()
 if frame%2 == 0 then
  speechbubble:addchar(
   sub(
    cade_text,
    cade_textindex,
    cade_textindex
   )
  )
  cade_textindex+=1
  if cade_textindex >= #cade_text then
   return true
  else
   return false
  end
 end
end
--menu
function titlelogo_draw()
 titlelogo_arr:draw()
 titlelogo_cade:draw()
end
function titlelogo_update()
 if titlelogo_arr.x < 4 then
  titlelogo_arr.x+=2
 end
 if titlelogo_arr.y < 8 then
  titlelogo_arr.y+=2
 end
 if titlelogo_cade.x > 50 then
  titlelogo_cade.x-=2
 end
 if titlelogo_cade.y > 8 then
  titlelogo_cade.y-=2
 end
end
titlelogo_arr = {x=-32,y=-32}
function titlelogo_arr:draw()
 map(
  27,0,
  titlelogo_arr.x,titlelogo_arr.y,
  6,2
 )
end
titlelogo_cade = {x=128,y=90}
function titlelogo_cade:draw()
 map(
  33,0,
  titlelogo_cade.x,titlelogo_cade.y,
  10,2
 )
end
game_tips_x = 128
game_tips_index = 1
function game_tips:update()
 if game_tips_x > -#game_tips[game_tips_index]*4 then
  game_tips_x -=1
 else
  game_tips_x=128
  if game_tips_index<#game_tips then
   game_tips_index+=1
  else
   game_tips_index=1
  end
 end
end
function game_tips:cycleprint()
 print(
  game_tips[game_tips_index],
  game_tips_x,120,
  7
 )
end
menu_cadex = 32
menu_cadey = 40
explainthegame = false
b1_x = 8 b1_y = 42
b2_x = 80 b2_y = 42
b3_x = 48 b3_y = 54
b4_x = 112 b4_y = 42
function buttons_draw()
 sspr(--barrel-music
  0,32,16,16,
  ship.x+b1_x,ship.y+b1_y,
  14,14
 )
 sspr(--wood-start
  0,48,16,16,
  ship.x+b2_x,ship.y+b2_y,
  14,14
 )
 sspr(--chest-controls
  56,32,8,8,
  ship.x+b3_x,ship.y+b3_y,
  16,8
 )
 
 sspr(--barrel-difficulty
  0,32,16,16,
  ship.x+b4_x,ship.y+b4_y,
  14,14
 )
end
function buttons_print()
 print("help",b1_x,ship.y+b1_y+4)
 print("music "..musicstr,b2_x-7,ship.y+b2_y+4)
 print("start",b3_x-1,ship.y+b3_y-4)
 print(difficulty,b4_x,ship.y+b4_y+4)
end
function menu_cade_update() 
 if btnp(0) and menu_cadex >8 and menu_cadey==40 then
  menu_cadex-=8
 end
 if btnp(1) and menu_cadex<112 and menu_cadey==40 then
	 menu_cadex+=8
 end
 if menu_cadex == b1_x then
  b1_y = 20
  if btnp(5) then
   explainthegame = true
  end
 else
  b1_y = 42
  explainthegame = false
 end
 if menu_cadex == b2_x then
  b2_y = 20
  if btnp(5) then
   if music_on then
    music(-1)
    musicstr = "off"
    music_on = false
   else
    music(2,0,4)
    musicstr = "on"
    music_on = true
   end
  end  
 else
  b2_y = 42
 end
 if menu_cadex == b4_x then
  b4_y = 20
  if btnp(5) then
   if difficulty == "easy" then
    difficulty = "hard"
    games_won = 0
    games_lost = 0
    --sprite overdraw
    for ix=0, 79 do
     for iy=96, 127 do
      if sget(ix,iy)==3 then
       sset(ix,iy,8)
      end
     end
    end
    blockdropfreq = 48
    player_hp = 3
    player_speed = 1.1
    barrel_hp = 1
    chest_hp = 1
    
    enemy_spawnfreq = 8
    
    jack_hp = 3
    jack_speed = 0.8
    
    dan_hp = 3
    dan_speed = 0.7
   else
    difficulty = "easy"
    games_won = 0
    games_lost = 0
    --sprite overdraw
    for ix=0, 79 do
     for iy=96, 127 do
      if sget(ix,iy)==8 then
       sset(ix,iy,3)
      end
     end
    end
    blockdropfreq = 100
    player_hp = 5
    player_speed = 1
    
    barrel_hp = 2
    chest_hp = 2
    
    enemy_spawnfreq = 64
    
    jack_hp = 3
    jack_speed = 0.6
    
    dan_hp = 3
    dan_speed = 0.4
   end
  end
 else
  b4_y = 42
 end
 if menu_cadex == b3_x then
  b3_y = 32
  if btnp(5) then
   menu_cadey+=1
  end
 else
  b3_y = 54
 end
 if menu_cadey>40 then
  menu_cadey +=1
  if menu_cadey >=60 then
   menu_cadex = 32
   menu_cadey = 40
   wave.y = 86
   game_state = game_running
   _init()
  end
 end
end
__gfx__
bbbbbb0006600bbbbbbbbbbbbbbbbbbbbbbbb000660bbbbbbbbbbb0006600bbbbbbbbb0006600bbbbbbbbb0006600bbbbbbbbbbbbbbbbbbbbbbbb0006600bbbb
bbbb0000600000bbbbbbbb0006600bbbbbb0000600000bbbbbbb0000600000bbbbbb0000600000bbbbbb0000600000bbbbbbbbb0006600bbbbb0000600000bbb
bbb00000600000bbbbbb0000600000bbbb00000600000bbbbbb00000600000bbbbb00000600000bbbbb00000600000bbbbbbb0000600000bbb00000600000bbb
bb000000066000bbbbb00000600000bbb000000066000bbbbb000000066000bbbb000000066000bbbb000000066000bbbbbb00000600000bb000000066000bbb
b00055f7ff00bbbbbb000000066000bb00055f7ff00bbbbbb000bbbbbbbbbbbbb00055f7ff00bbbbb00055f7ff00bbbbbbb000000066000b00055ffff00bbbb8
bbb555f0ff00bbbbb00055f7ff00bbbbbb555f0ff00bbbbbbbbb55f7ff00bbbbbbb555f0ff00bbbbbbb555f0ff00bbbbbb00055ffff00bbbbb555f00f00bbbbb
bbbbd5ffffffbbbbbbb555f0ff00bbbbbbb15ffffffbbbbbbbb555f0ff00bbbbbbbb15ffffffbbbbbbbb15ffffffbbbbbbbb555f00f00bbbbbb15ffffffb8bbb
bbbb155555555bbbbbbb15ffffffbbbbbbb155555555bbbbbbbb15ffffffbbbbbbbb155555555bbbbbbb155555555bbbbbbbbd5ffffffbbbbbb155555555bbbb
bb91115555555bbbbbbb155555555bbbb91115555555b555bbbb155555555bbbbb91115555555bbbbb91115555555bbbbbbbb155555555bbb91815855555bb8b
bb1111d555555bbbbb91115555555bbbb1111d555555045bbb91115555555bbbbb1111d555555bbbbb1111d555555bbbbbb91115555555bb811118885555b88b
bb1111d66d10bbbbbb1111d555555bbbb1111d66d10004bbbb1111d555555bbbb11111d66d10bbbbb11111d66d10bbbbbbb1111d588888bbbb8888888808bbbb
bb1111d66d10bbbbbb1111d66d10bbbbb1111d66d10bb4bbb11111d66d10bbbbb11b11166d10bbbbb11b11d66d10b0bbbbb1111d66d10b8b11188d88d10bb8b8
bbdd0009900bbbbbbb1111d66d10bbbbb110009900bbbbbbb11b11d66d10bbbbbffb00099000bbbbbffb0009900000bbbbb1181886d888bb11b18868d10b88bb
bbff444b000bbbbbbb110009900bbbbbbff444b000bbbbbbbffb0009900bbbbbbbbbb444000bbbbbbbbb444bb00000bbbbbdd00099008bb8ffb0009900bbb88b
bbbbb44b000bbbbbbbffb44b000bbbbbbbbb44b000bbbbbbbbbbb44400bbbbbbbbbbbb4440bbbbbbbb9444bbbbbbbbbbbbbff444b000b8bbbbb444b800bbbb8b
bbbbb99bb000bbbbbbbbb99bb000bbbbbbbb99bb000bbbbbbbbbbb99000bbbbbbbbbbbb0900bbbbbbbbbbbbbbbbbbbbbbbb9444b0000b8bbb9444bb000bbbb8b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb67bbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbb88bbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbbbbbbbbbbb6bbbbbb667bbbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbbbbbbbbbb8bb88bbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbb6bbbbabbbbbbbbbb666bb6bbbbbb6666bbbbbbbbbbbbdbbbbbbbdbbbbbbbbbbbbbbbbbbbbbbbbbb8b8bbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbb5bbbbbbbbbbbbbbb66bbbbbbbb6667bbbbbbbbbbbbdddbbbbbbb6667bbbbbbbbbbbbbbbbbb8bb88bbbbb00bbb
555555bbbbbbbbbb555555b589bbbbbb555555b8a9bbbbbb555555bbbbbbbbbbb6667bbbbbbbbbbbbbbddbbbbb66667bbbbbbbbbbbbbbbbbbbbbb8bbbbb000bb
065666bbbbbbbbbb065666b5aa77bbbb065666baa7b77bbb065666bb6b99bbbbb6667bbbbbbbbbbbbbbbdbbbb66666bbbbbbbbbbbbbbbbbbbbb11819bbb0000b
0455bbbbbbbbbbbb0455bb589abbbbbb0455bb59aabbbbbb0455bbb66bbbbbbbb666bbbbbbbbbbbbbbbbddbb66667bbbbbbbbbbbbbbbbbbb9fd11811bb50000b
44bbbbbbbbbbbbbb44bbbbb589bbbbbb44bbbbb569bbbbbb44bbbb66bbbbbb9bb667bbbbbbbbbbbbbbbbbdb666667bbbbbbbbbbbbbbbbbbb4fd188111d550000
4bbbbbbbbbbbbbbb4bbbbbbbbbbbbbbb4bbbb6b9bbbbbbbb4bbbb66bbbbbbbbbb66bbbbbbbbbbbbbbbbbbb666667bbbbbbbbbbbbbbbbbbbb4401881155550000
0bbbbbbbbbbbbbbb0bbbbb9b9bbbbbbb0bbb66bbb9bbbbbb0bbbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbb566667bbbbbbbbbbbbbbbbbbbbb440888d85fff0660
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb666bbbbabbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbb55677bbbbbbbbbbbbbbbbbbbbbbbb40888855f0f6006
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbb0b9888585f0f6006
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbbbbbbbbbb009d88555fff0000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbbbbbbbbbbb000818855f000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb880888555f000888
bbbb00000000bbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbbb6bbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0044444400bbbbbb0044444400bbbbbb49bb99bbbb4bbb5b5b5b5bbbbbbbb50065bbbbbb66bbbbbbbbbbbba42bbbbbbaaaaa999bbbbbbbbbbbbaa99994bbb
bb004424222200bbbbbb4424222200bbbb44bb55bbbbbb59050505056565565650605bbbbb66666bbbbbbbbba942bbbbba9444222292bbbbbbbbba9994492bbb
b00555555555500bb00bbb555555500bb44b455bbbbbbb55404040405454545450005bbbb656566bbbbbbbbaa942bbbbba44222bbb94bbbbbbbba94222242bbb
b05555111111110bb05000111111110bbbbb55bbbbbbbbbb4040404045454544b555bbbbb566666bbbbbbbaa4942bbbbbb942bbbbb94bbbbbbba9442bbbbbbbb
04452452554254400445240255425440bbbb4bbbbb559bbb0505050565655656bbbbbbbbbb56665bbbbbbba42942bbbbbb942bbbbba2bbbbbbba442bbbbbbbbb
04524524425225400452452442522540bbbbbbbbbbb559bbb5b5b5b5bbbbbbbbbbbbbbbbb566655bbbbbba94b942bbbbbba42bbbbba2bbbbbba942bbbbbbbbbb
04524524425425400452452042542540bbbbb59bbbbb559bbbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbbbbba42bb92bbbbbba42bbbb992bbbbbba94bbbbbbbbbbb
04524524425425400452452402542540bbbbb59bbbbbb59bbbbbbbbbb98888b9bbbbbbbbbbb9bbbbbbbba94bbb92bbbbbba444499942bbbbbba44bbbbbbbbbbb
04524524425425200452452442542520bbbbb45bbbbbbbbbbbba8a9b8899988bbbb66bbbbbb5bbbbbbbba99bbb942bbbbba4aaaaa92bbbbbbba44bbbbbbbbbbb
04524524425225100452452442522510bbbbb455bbbbbbbbb998aabb89aa998bbb66666bbb000bbbbbbaa4aaaaaa992bbba42b942bbbbbbbbba942bbbbbbbbbb
0445245422525110044524502250b110bbb99b455bbbbb44bb989aabbaa77a88b666666bb00550bbbbba444444492bbbbba42b9942bbbbbbbbba442bbbbbbbbb
b05555551521210bb055555015200b0bbbbb44bbbbb555bbbb98a8ab89a77798b566666b0000550bbbb942bbbbb92bbbbba42bbaa42bbbbbbbba9444222992bb
b00115111212100bb0011510121200bbbbbbb49bbb44bbb4bb9a999b899aa989bb56665b0000000bbb942bbbbbbb92bbbba42bbbaa4442bbbbbba999444492bb
bb002221221200bbbb00200b021200bbbbbbbb4bbbbbbbbbb9bb99bbb889888bb566655b0100000bb942bbbbbbbb92bbbba42bbbba9999bbbbbbbaaa9aa92bbb
bbb0000000000bbbbbb000bb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbbbb555bbb01110bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0000000000bbbbbb0000000000bbbbbbbbbbbbbbbbbbb0000000000000000b00b00bbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00054444450000bb00054444450000bbbbbbbbbbbbbbbbb0000000bb00000000e80880bb0aaa40bbbbbaa94442bbbbbbbbbba9aa9992bbbbbbbba92bbbbbbbb
0044544444450400bb04544444450400bbbbbbbbbbbbbbbb00000bbbbbb0000008e8820b0a999940bbaa94999942bbbbbbbba94442222bbbbbbbb9994bbbbbbb
0444544444452440bb00044444452400bbbbbbbbbbbbbbbb000bbbbbbbbbb0000888820b0a9a9940ba4942bbbb942bbbbbba94422bbbbbbbbbbbba994bbbbbbb
0444544444452440000bb0444445240bbbbbbbb66bbbbbbb000bbbbbbbbbb000b08820bb0a9aa440bbba42bbbbb942bbbbba922bbbbbbbbbbbbbba992bbbbbbb
04445444444524400400b0444445240bbbbbbbb6bbbbbbbb00bbbbbbbbbbbb00bb020bbb04994a40bbba42bbbbb942bbbba942bbbbbbbbbbbbbbba94bbbbbbbb
044404444425244004440444442520bbbbbbbbbbbbbbbbbb00bbbbbbbbbbbb00bbb0bbbbb044440bbbba42bbbbb992bbbba942bbbbbbbbbbbbbbba94bbbbbbbb
042452444240242004245244424000b0bbbbbbbbbbbbbbbb0bbbbbbbbbbbbbb0bbbbbbbbbb0000bbbbba42bbbbbba22bbba9aaaa99942bbbbbbbba94bbbbbbbb
04440442424522400444044242450000bbbbb6bbbbbbb6660bbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbba42bbbbbba42bbba9422444222bbbbbbbba92bbbbbbbb
02420424242022100242042424202210bbb6bbbbbbbbb66b00bbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbba42bbbbbba42bbba942bbbbbbbbbbbbbbba92bbbbbbbb
05250219951011200525021995101120bbbbbbbbbbbbbb5b00bbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbb942bbbbbba42bbba942bbbbbbbbbbbbbbb992bbbbbbbb
00000009900000000000000990000000bbbbbbbbbbbbbbbb000bbbbbbbbbb000bbbbbbbbbbbbbbbbbbba42bbbbb9942bbba942bbbbbbbbbbbbbbbb92bbbbbbbb
02220224411011100200002441101110b66b4455bb44b44b000bbbbbbbbbb000bbbbbbbbbbbbbbbbbbb942bbbb99422bbbaa942bbbbbbbbbbbbbbbbbbbbbbbbb
0222022222101110020bb02222101110b666b4444555554600000bbbbbb00000bbbbbbbbbbbbbbbbbba99929999442bbbbb4aaa9a9992bbbbbbbba94bbbbbbbb
091102111110119009bbb01111101190b5644444444b44460000000bb0000000bbbbbbbbbbbbbbbbbbbbba9444442bbbbbbb444222222bbbbbbbba92bbbbbbbb
000000000000000000bbb00000000000b55b66444bb444b50000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb05550bbbbbbbbbbb05550bbbbbbbbbbb05550bbbbb6bbbbb05550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb0555550bbbbbbbbb0555550bbbbbbbbb0555550bbbb66bbb0555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb055555550bbbbbbb055555550bbbbbbb055555550bbb66bb055555550bbbbbbbbbbb05550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb088558850bbb6bbb088558850bbb6bbb088558850bbb66bb088558850bbbbbbbbbb055b550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb078557850bbb66bb078557850bbb66bb008557850bbb66bb008557850bbbbbbbbb05b555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bdbb055555550bbb66bb055555550bbb66bb055555550bbb66bb055555550bbbbb6bbb088558b50bbbbbbbbbbdbd5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bdbbb05555509bbb66bbb05555509bbb66bbb05555509bbbb66bb05555509b8bbb66bb008557850bbbbbbbbdbbbb650bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dbbbb0505050bbbb66bbb0505050bbbb66bbb0505050bbbbb65bb0505050bb0bbbb6bb055555550bbb6bbbbbbdb8bd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dbbbbbbbb050bbbb66bbbbbbb050bbbb66bbbbbbb050bbbbbb50bbbbb050b0bbbb66bbb055555095bbbbbb00bbb7bbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbb
dbdbbb22211222bbb66bbb22211222bbb66bbb22211222bbbb55bb02211220bbbb6bb5b0505050bbbbbbbb05bb5b550bbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbb
bbdbbb02211220bbd65b0002211220bbb65b0002211220bbbbb500b221122bbbbbb6bbbb22211222bb6b6bb0bd55d095bbbbbbb000b6b5bbbbbbbbbbbbbbbbbb
bbdbb0b221122b0dbb500bb221122b0bbb500bb221122b0bbbbbbbb221122bbbbbb65b00b2211220bb6bb5bb5b5050bbbbbbbbbb050bbbbdbbbbbbbbbbbbbbbb
bbbd055b111118bdbb55bbbb11111b8bbb55bbbb11111b8bbbbbbbbb11111bbbb6bb500b0b2b122b0bbbbbbbbbbbbbb0bbbb6bbbbbb51bb5bbbbbbbbbbbbbbbb
bb6655b0bbb00bbdbbb5bbb0bbbb0bbbbbb5bbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbb5bbbb111b1b8bb6db00b2211bbbbbbbbbbb01b1b78bbbbbbbbbbbbbbbbb
6666bbbb0bb0bbbdbdbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbbbbbbb00bbb00bbbb6bbbb2b0bbb102b6bb500b0b2b122b0bbbbb2b0d188b5d0bbbbbbbb651bb5b
66bbbbbb0b0bbbbbbddbbbb0bbbb0bbbbbbbbbbb0b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0b1bb0bbbbbbbbbbb00bb0b8bbb5b5b5121511d2bbb60b01b157805
bbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbb0ddd0bbbbbbbbbbbb0ddd0bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbb0ddddd0bbbbbbbbbb0ddddd0bbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb9b0ddddddd0bbbb9bb0ddddddd0bbb9bbb0ddddddd0bbbb9bb0ddddddd0bbbbbb9b0ddddddd0bbbb89bbb0ddd0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b9bbb088dd88d0bbbbbbb088dd88d0bbbbb9b088dd88d0bbb9b9b088dd88d0bbbb9bbb088dd88d0bbbb5bbb0bddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb89b078dd78d0bbb98bb078dd78d0bbbb8bb078dd78d0bbbb8bb078dd78d0bbbbb89b078dd78d0bbbb5bb0dbbdddb0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb5bb00dddddd0bbbb59b00dddddd0bbb95bb00dddddd0bbbb5bb00dddddd0bbbbb5bb00dddddd0bbbbb0b088dd88b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb5bbb0ddddd0bbbbb5bbb0ddddd0bbbbb5bbb0ddddd0bbbbb5bbb0ddddd0bb8bbb5bbb0ddddd0bbbb00bb078bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000bb0d0d0d0bbbb000bb0d0d0d0bbbb000bb0d0d0d0bbbb000bb0d0d0d0bb8bb000bb0d0d0d0bbbb000b0bbddddd0bbb9bbbbbbbbb0b0bbbbbbbbbbbbbbbbb
b0000bbbbb0d0bbbb0000bbbbb0d0bbbb0000bbbbb0d0bbbb0000bbbbb0d0bb8bb0000bbbbb0d0bbbbbbbbb0dddd70bbbbb89bbbbbbbbb0bbbbbbbbbbbbbbbbb
b000b0018dddd81bb000b0018dddd81bb000b0018dddd81bb000b0018dddd80bbb000b0018dddd81bbbbbbb0d0d0d0b0bbbb0bbbdbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb11bbb10bbbbbbbbb11bbb10bbbbbbbbb11bbb10bbbbbbbbb11bbb11bbbbbbbbbb11bbb10bbbbbbbbbbb0d0bb8b00bbbbddb88d0bbbbbbbbbbbbbbbbb
bbbbbbbb11dbd8b8bbbbbbbb11dbd88bbbbbbbbb11dbd8b8bbbbbbbb11dbd8bbbbbbbbbbb11dbd8b8bbbbb0b1bbddd0b8bbb0bb088bbb0bbbbbbbbbbbbbbbbbb
bbbbbbbbb1db88b8bbbbbbbbb1db88bbbbbbbbbbb1db88b8bbbbbbbbb1db88bbbbbbbbbbbb1db88b8bbbbbbbb11bbbbbbbbbbbb078d0d0b0bbbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbb0bbbbbbbbbbb0bbbb0bbbbbbbdddbbdbd8bbbbbbbbbbbb0bbbb8bbbbbbbbbbbbbbb
bbbbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbbbbbbb0bbbbb0bbbbbbbbb00bbb08bbbbbbbbbb0bbbb0bbbbbbbbbbb1db88bbbbbbb0b1bbd7d0b8bbbbb9bbdb8bdb0
bbbbbbbb0bbbb8bbbbbbbbbbb0b8bbbbbbbbbbb0bbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbb0bbbb8bbbbbbbbdb0bb0b0bbbbbbbbbb11bbbbbbbbb980d78b0d000
149414521442134214941442144214421442111111111442d494d452d442d342d494d442d442d442ccccccccccccccccccccccccccc45666ccccccccbbbbbbbb
144414521223344214441445122215421453555555553342d444d452d2233442d444d445d222d542cccccccccccccccccccccccccc5566666cccccccbbbbbbbb
111114521111334211111445111115421553555555555332ddddd452dddd3342ddddd445d111d542cccccccccccccccccccccccc5556666666ccccccbbbbbbbb
14421455144213421342144514321542155511111111d332d442d455d4421342d342d445d432d542cccccccccccccccccccccc5556666666666cccccbbbbbbbb
1442145214421345144214451432154215511111111d1351d442d452d4421345d442d445d432d542ccccccccccccccccccccc566666666666666ccccbbbbbbbb
144214521452134514321445153215421551111111d11352d442d452d4521345d432d445d532d542ccccccccccccccccccc55666666666666666ccccbbbbbbbb
144214551452134514351445153215421551111111111332d442d455d452d345d435d445d532d542ccccccccccccccccc55566666666666666666cccbbbbbbbb
1442145514521345143514451533154515511111d1111d52d442d455d452d345d435d445d5331545ccccccccccccccccc55556566666666666666cccbbbbbbbb
144214551452144513451445153315451551111d111d1d52d442d4551452d445d345d445d533d545ccccccccccc42cccc55556566666666666666cccbbbbbbbb
14451445144214451342144515451545155111d111d11d52d445d4451442d445d342d4451545d545ccccccccccc42cccc55566666666666666666cccbbbbbbbb
1445144514421442134214451445154215511d111d111352d445d4451442d442d342d4451445d542ccccccccccc444ccccc55666666666666666ccccbbbbbbbb
144514451445144214421452144514421551d11111111d52d445d4451445d442d442d452d445d442ccccccccccc42cccccccc566666666666666ccccbbbbbbbb
14421445144514421452145214451442155d111111115d52d442d4451445d4421452d4521445d4424444444444444444cccccc5556666666666cccccbbbbbbbb
1442144214421442145214521445144215555dddddddd551d442d442d442d442145214521445d442cc2ccc2cccc22ccccccccccc5556666666ccccccbbbbbbbb
144212221442122214521223334512221255555555555521d442d222d442d222145212233345d222cc4ccc4cccc42ccccccccccccc5566666cccccccbbbbbbbb
144211111342111115421111334511111222133213331231d442ddddd342d1dd1542dddd3345ddddcc4ccc4cccc42cccccccccccccc45666ccccccccbbbbbbbb
1452144213421442154215323445144211dddd1111111111d452d442d342d4421542d5323445d4422242224222242222cccccccccccc4444bbbbb9bbbbbbbbbb
145214421342144215451332144514424144444444433333d4521442d34214421545d3321445d4424444444444444444ccccccccccc44445bbbbbb9bbbbbbbbb
145214421345144215451342144214422155224225522232d4521442d3451442d545d342144214425555444422222555cccccccccc444454b99999999999999b
14551442144514421545154215421442111111111111ddddd4551442d4451442d545d542d54214424445444444444444ccccccccc44445449ff77ff7777ff779
145214421445144215451542154214424444441444444333d4521442d445d442d545d542d542d4424555422244555524cccccccc4444544c977ff77ffff77ff9
145215421442144215451442154214422422221225552222d4521542d442d442d545d442d542d4424425444425442224ccccccc4444544cc9ff77ff7777ff779
145215421442145515451445154214421ddddd111111111dd452154214421455d545d445d542d4422255222222224444cccccc4444544ccc977ff77ffff77ff9
14521542142514521445144515451445224233345544414514521542d425145214451445d545d4455225555544555555ccccc4444544ccccb99999999999999b
14521542142514521445144515451442bbbbbbbbbbbbbbbb14521542d425145214451445d54514422442222222242222bbbbbbbb444cccccbbbbbbbbbbbbbbbb
14521542142514521445144514451452bbbbbbbbbbbbbbbb14521542d42514521445144514451452444444444444444cbbbbbbbb44ccccccbbbbbbbbbb1bb11b
14551542145514521445144514451452bbbbbbbbbbbbbbbbd4551542d4551452d44514451445145244445555222225ccbbbbbbbb4cccccccbbbbbbbbbbbbbbbb
14551542145514421445145514421452bbbbbbbbbbbbbbbbd45515421455144214451455144214522224544244444cccbbbbbbbbccccccccbbb1bbbbbbbb1bbb
12221542122214521252154512221455bbbbbbbbbbbbbbbbd222154212221452125215451222d455444455554455ccccbbbbbbbbccccccccbb111bbbbbb111bb
11111522111114551111154211111455bbbbbbbbbbbbbbbbd11115221ddd145511111542d111145544445442254cccccbbbbbbbbccccccccb11111bbbbb1b1bb
14441522144214551444154514421445bbbbbbbbbbbbbbbb144415221442145514441545144214455552222222ccccccbbbbbbbbcccccccc11111111bb11b111
14941422144214551494144514421445bbbbbbbbbbbbbbbb14941422144214551494144514421445222225554cccccccbbbbbbbbcccccccc11111111111bbbbb
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
cacacccdcecacacccdcecacccdcecacacacccdcecacacacaca00004a4b4c4d4c4d4e4f4a4b6a6b6c6d6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacadcdddecacadcdddecadcdddecacacadcdddecacacacaca00005a5b5c5d5c5d5e5f5a5b7a7b7c7d7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacccdcecacacccdcecacccdcecacacacccdcecacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacadcdddecacadcdddecadcdddecacacadcdddecacacaeced00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacadbcacacacadbcacacadbcacacacacadbcacacaecedfd00008485868789000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cacacadbcacacacadbcacacadbcacacacacadbcacaecedfdca0000c9c7c7c9c9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dadadadbdadacacadbdadadadbdadadadadadbdadaedfdcaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebebebebebeadadafaebebebebebebebebebebebfbcacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebc4c5ebebebebebebebebebebc4c5ebebebebfbcacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebd4d5ebebebebebebebebebebd4d5ebebebfbcacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebebebebebebebebebebebebebebebebebfbcacacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebebebebebebebebebebebebebebebebfbcacacacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c6c7c8c9c6c7c8c9c6c7c8c9c6c7c8c9cacacacacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6d7d8d9d6d7d8d9d6d7d8d9d6d7d8d9cacacacacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6e7e8e9e6e7e8e9e6e7e8e9e6e7e8e9cacacacacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f6f7f8f9f6f7f8f9f6f7f8f9f6f7f8f9cacacacacacacacaca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c4c5c0f6f7f8f9c1c4c5c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d4d5d0d6d7d8d9d1d4d5d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e0e6e7e8e9e1e2e3e0e1e2e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f0f6f7f8f9f1f2f3f0f1f2f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d0d1d2d3d0d1d2d3d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1c4c5e0e1e2e3e0e1c4c5e0e1e2e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1d4d5f0f1f2f3f0f1d4d5f0f1f2f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d0d1d2d3d0d1d2d3d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4e5e4e5e4e5e4e5e4e5e4e5e4e5e4e500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4e5e4e5e4e5e4e5e4e4e5e4e5e4e5e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000765008650096500b6500d6500e6500f650266500f6500e6501d650156501165008650056500165001650016200160001600026000160002700017001350013500135001350013500017000170002700
01040000000000c6501065014650177501c6501d6501f6501c65019650166501565013650106500e6500b65009650076500565003650016500162001620016200162001620016200162007600056000260000000
00030000000000a5500c550151501771011550115100f1100d1000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000000201642077520275208753000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
011800002c210252101c210162101c210202101c2101c2101b2101b2101a2121a2121a2121a2121a2121a2151c3001c3001a2001a200000000000000000000000000000000000000000000000000000000000000
00200000242501425024250182501d25007250102502a250182000920001200232002320024200242000020000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001b020190201d0201e0201f020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000000000000235502b5502c5502d5502b5502b5502e5503255035550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003225022250172501625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000132431c103031000110002100000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01100000132531c103031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00001c121061211c1210000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
010f00000011405111021110000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
011400001c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221a2221a2221a2221a2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221f2221f2221f2221f222
011400001057110571105711057110571105711057110571105711057110571105710e5710e5710e5710e57110571105711057110571105711057110571105711057110571105711057113571135711357113571
011400001365300003000000000013653000030000300003136530000300003000031365313653136530000013653000030000300003136530000300003000031365300000000000000013653136531365300000
011400001c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221a2221a2221a2221a2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221c2221f2221f2221f2221f222
011600280005200050030530300001053000020005200050030530000001053000000005200050030530000001053000000005201050000500300001050000530005000050030530300000052000500105303003
01160020180541805018055235001805418050180551b05018054180501b050180001b0541b0501b0501a0551e0541d0501e0551b0501b0541a05018055180041805018055180001b0541a054180501a0501b055
011600000c0500c0500c0550f0000c0500c0500c0550d0000c0500c0500c0550c0000f0500f0500f055080000d0500d0500d055000000b0500b0500b055050000c0500c0500c0550000008050080500805500000
01160000240352400524035240052403524005240352700524035240052403524005240352500524035240052403528005250352400527035240052503524005220352e005250352e0052703528005280352a000
011600003a0733a0733a0733a0733a0733a0733a0733a07319003190031900019000190001900019000190001b0001b0001b0001b0001b0001b0001b0001b0002200022000220001e0001e0001e0001900019000
01080000296532b6532b600296001d6001c600186001c600186001c600186001c600186001c6001f60018600266002960024600186001a6001d60029600266002b6002d60029600286002d600296002b60029600
010700000231000411104110541100411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100020184120c412184120c412184120c412184120c4121441211412144120c41214412164121441203412184120c412184120c412184120c412184120c4120541211412054120f41205412114120541212412
01100000184120c412184120c412184120c412184120c4121441211412144120c412144121641214412034120541211412054120f41205412114120541214412034120f41211412134121141203412114120f412
011000000061318600186001860034613186001860018600006131860000600186003461300603006130060300613006030060300613346130060300603006030061300613000030061334613006133461300613
010800001d2111d2111d2111d2111d2111d2111d2111d2111c2111c2111c2111c2111c2111c2111c2111c21118211182111821118211182111821118211182112421124211242112421124211242112421124211
0108000021211212112121121211212112121121211212111d2111d2111d2111d2111d2111d2111d2111d21128211282112821128211282112821128211282112421124211242112421124211242112421124211
010800001d412114121d412294121d412114121d41229412284121c4122841234412284121c4122841234412184120c4121841224412184120c41218412244122441230412244120c41224412184122441230412
010800002141215412214122d4122141215412214122d4121d412114121d412294121d412114121d41229412284121c4122841210412284121c41228412344122441230412244120c41224412184122441230412
0108000011325113251d3251d3251132511325113251132510325103251c3251c325103251032510325103250c3250c32518325183250c3250c3250c3250c3251832518325243252432518325183252432524325
01080000153251532521325213251532515325153251532511325113251d3251d325113251132511325113251c3251c32528325283251c3251c3251c3251c3251832518325243252432518325183251832518325
010800001054310500105430000017643005030050300503000000000010543005031764300503005030050310543000001054300503176430050300503005031760000000105430050317643005031050000000
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
01 11 42 43 44
00 11 13 43 44
03 11 13 14 44
01 18 1a 43 44
02 19 1a 43 44
01 1b 1d 21 1f
02 1c 1e 21 20
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
