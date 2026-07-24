pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--niji-famicart
--by guerragames
--[[
todo:
- (done) make flowers explode (done)
-- (done)after connecting, pause everything, shake them a little 
   and explode with particles with gravity in their color (done)
- (done) speed up every 100 points?
- (done) add a new flower type every 200 points?
- (done) white flowers (frozen) can be thawed by destroying flowers nearby
- (done) sound effects
- (done) show added score on top of each flower's explosion
- (done) hi-score storing

- fancy starting logo display (also after game over screen has been up for a while)

- pirannah plants appear at a certain rate... increase that rate evey 500 points?
-- pirannah plants can only be destroyed by destroying flowers nearby
-- make pirannah plants attach automatically to the front and slowly creep towards the back
--]]

----------------------------
-- vector2d
----------------------------
function magnitude( x, y )
  return sqrt( x * x + y * y )
end

----------------
function normalizewithmag( x, y )
  local mag = magnitude( x, y )
  local one_over_mag = 1 / mag

  x = x * one_over_mag
  y = y * one_over_mag

  return x, y, mag
end

----------------------------
-- print_outline
----------------------------
function print_outline( text, x, y, color, backc )
  local offsetx = (#text * 0.5)*4
  
  print( text, x - offsetx - 1, y - 0, backc )
  print( text, x - offsetx - 1, y - 1, backc )
  print( text, x - offsetx + 0, y - 1, backc )
  print( text, x - offsetx + 1, y - 1, backc )
  print( text, x - offsetx + 1, y + 0, backc )
  print( text, x - offsetx + 1, y + 1, backc )
  print( text, x - offsetx - 0, y + 1, backc )
  print( text, x - offsetx - 1, y + 1, backc )
  
  print( text, x - offsetx, y, color )
end

----------------------------
-- logo - niji logo
----------------------------
logo={}

logo.sprites = {128,130,132,130}
logo.widths = {16,9,16,9}
logo.x = 128
logo.speed = 3
logo.dismissed = false

------------
logo.launch = function()
 logo.x = 128
 logo.speed = 3
 logo.dismissed = false
end

------------
logo.update = function()
 
 if logo.dismissed then
  if logo.speed < 10 then 
   logo.speed += 0.5
  end
 
  if logo.x > -76 then
   logo.x -= logo.speed
  else
   logo.x = -76
  end
 
 else 
  if logo.speed > 1 then 
   logo.speed -= 0.1
  end
 
  if logo.x > 76 then
   logo.x -= logo.speed
  else
   logo.x = 76
  end
 end
 
 if show_start_msg then
  if btn(4) and btn(5) then
   _init()
   logo.dismissed = true
   show_start_msg = false
  end
 end
end

------------
logo.draw = function()
 local xoffset = 0
 for i=1, #logo.sprites do
  local x1 = logo.x + xoffset
  local y1 = tracks.eval(x1+8)
  spr( logo.sprites[i], x1, y1-16, 2, 2 )
  
  xoffset += logo.widths[i]
  
 end
 
 if show_start_msg then
  print_outline( "press <z> and <x>", 64, 102, 7, 1 )
  print_outline( "to play!", 64, 110, 7, 1 )
 end 
end

----------------------------
-- gameovers - game over letters
----------------------------
gameovers={}

gameovers.sprites_game = {136,138,140,142}
gameovers.sprites_over = {168,170,172,174}
gameovers.x = -128
gameovers.speed = 20
gameovers.timer = 0
gameovers.dismissed = true

------------
gameovers.launch = function()
 gameovers.x = 128
 gameovers.speed = 20
 gameovers.timer = 0
 gameovers.dismissed = false
end

------------
gameovers.update = function()

 gameovers.timer += one_frame
 
 if gameovers.dismissed then
  if gameovers.speed < 10 then 
   gameovers.speed += 0.5
  end
 
  if gameovers.x > -128 then
   gameovers.x -= gameovers.speed
  else
   gameovers.x = -128
  end
 else 
  if gameovers.speed > 1 then 
   gameovers.speed -= 0.5
  end
 
  if gameovers.x > 64 then
   gameovers.x -= gameovers.speed
  else
   gameovers.x = 0
  end

  -- after 10 seconds, dismiss the game over message and bring back the logo 
  if gameovers.timer > 10.0 then
   gameovers.dismissed = true
   logo.launch()
  end
 end
 
 -- wait for explosions to finish before displaying and allowing a new game
 if flowers.exploding_index == -1 then
  if not gameovers.dismissed or not logo.dismissed then
   show_restart_msg = true
  
   if btn(4) and btn(5) then
    
    if gameover then
     music(0) -- restart the music when restaring the game, feels like a fresh start
    end
    
    _init()
    
    gameovers.dismissed = true
    logo.dismissed = true
   end
  end
 end

end

------------
gameovers.draw = function()
 if gameovers.dismissed then
  for i=1, #gameovers.sprites_game do
   local x1 = gameovers.x + 16*(i-1)
   local x2 = x1 + 64
   local y1 = tracks.eval(x1+8)
   local y2 = tracks.eval(x2+8)
   spr( gameovers.sprites_game[i], x1, y1-16, 2, 2 )
   spr( gameovers.sprites_over[i], x2, y2-16, 2, 2 )
  end
 else
  for i=1, #gameovers.sprites_game do
   local x1 = gameovers.x + 16*(i-1)
   local x2 = 128 - 64 - gameovers.x + 16*(i-1)
   local y1 = tracks.eval(x1+8)
   local y2 = tracks.eval(x2+8)
   spr( gameovers.sprites_game[i], x1, y1-16, 2, 2 )
   spr( gameovers.sprites_over[i], x2, y2-16, 2, 2 )
  end
 end
 
 if show_restart_msg and not show_start_msg then
  local color = 7
  print_outline( "press <z> and <x>", 64, 102, color, 1 )
  print_outline( "to play again!", 64, 110, color, 1 )
 end 
end

----------------------------
-- explosions
----------------------------
explosions={}
explosions.count = 100

for i=1,explosions.count do
 explosions[i] = {}
 explosions[i].bits = {}
 explosions[i].bits.count = 20

 for j=1,explosions[i].bits.count do
  explosions[i].bits[j] = {}
 end
end

explosions.init = function()
 explosions.next = 1

 for i= 1, explosions.count do
  local explosion = explosions[i]
  explosion.timer = 0

  for j=1,explosion.bits.count do
   local bit = explosion.bits[j]
   
   bit.x = 0
   bit.y = 0
   bit.dx = 0
   bit.dy = 0
   bit.ddx = 0
   bit.ddy = 0
   bit.color = 9
   bit.size = 1
  end
 end
end

explosions.init()

function make_explosion( x, y, size, timer, color )

 local explosion = explosions[explosions.next]
 
 explosion.timer = timer

 for j=1,explosion.bits.count do
  local bit = explosion.bits[j]
  
  bit.x = x
  bit.y = y
  
  local dx, dy, mag = normalizewithmag( -1 + rnd(2), -rnd(1) )
  local speed = 2 + rnd(6)
  
  bit.color = color
  bit.size = size
  
  bit.dx = dx * speed
  bit.dy = dy * speed

  bit.ddx = 0
  bit.ddy = 0.5
  
 end
 
 explosions.next += 1
 
 if ( explosions.next > explosions.count ) then
  explosions.next = 1
 end
end

---------------

explosions.update = function()

 for i=1,explosions.count do
  local explosion = explosions[i]
 
  if explosion.timer > 0 then
   explosion.timer -= one_frame

   for j=1,explosion.bits.count do
    local bit = explosion.bits[j]
    bit.dx += bit.ddx
    bit.dy += bit.ddy
    bit.x += bit.dx
    bit.y += bit.dy
	bit.size -= 0.3
   end
  end
 end

end

--------------------

explosions.draw = function()
 for i=1,explosions.count do
  local explosion = explosions[i]
  
  if explosion.timer > 0 then
   for j=1,explosion.bits.count do
    local bit = explosion.bits[j]
	circfill( bit.x, bit.y, bit.size+1, 0 )
   end

   for j=1,explosion.bits.count do
    local bit = explosion.bits[j]
    circfill( bit.x, bit.y, bit.size, bit.color )
   end
  end
 end
end

------------------------------
-- stars
------------------------------
stars = {}
stars.max_count = 100
stars.frequency = .4
stars.timer = 0

------------------------------
stars.random_color = function()
 local colors = {7,6,8,12,10}
 return colors[ flr(rnd(#colors)) + 1 ]
end

------------------------------
stars.random_size = function()
 return rnd(2)
end

------------------------------

for i=1,stars.max_count do
 local star = {}
 star.active = false
 star.x = 0
 star.y = 0
 star.speed = 0
 star.color = stars.random_color()
 star.size = stars.random_size()
 add(stars, star)
end

-- activate some stars from the start
for i=1,20 do
 local star = stars[i]
 star.active = true
 star.x = rnd(128)
 star.y = rnd(128)
 star.speed = .1 + rnd(.5)
 star.color = stars.random_color()
 star.size = stars.random_size()
end

----------
stars.update = function()
 stars.timer += one_frame

 if stars.timer >= stars.frequency then
  
  local star_index = flr(rnd(stars.max_count)) + 1
  local star = stars[star_index]
  
  if not star.active then
   stars.timer = 0
  
   star.active = true
   star.x = 128 + 4
   star.y = rnd(128)
   star.speed = .1 + rnd(.5)
   star.color = stars.random_color()
   star.size = stars.random_size()
  end
 end
 
 for i=1,stars.max_count do
  local star = stars[i]
  
  if star.active then
   star.x -= star.speed
   star.color = stars.random_color()
   star.size = stars.random_size()
  end
  
  if star.x + 4 < 0 then
   star.active = false
  end
 end
end

----------

stars.draw = function()
 for i=1,stars.max_count do
  local star = stars[i]

  if star.active then
   circfill( star.x, star.y, star.size, star.color )
  end
 end
end

------------------------------
-- clouds
------------------------------
clouds={}
clouds.max_count = 10
clouds.frequency = 2
clouds.timer = 0

for i=1,clouds.max_count do
 local cloud = {}
 cloud.active = false
 cloud.x = 0
 cloud.y = 0
 cloud.speed = 0
 add(clouds, cloud)
end

----------
clouds.update = function()
 clouds.timer += one_frame

 if clouds.timer >= clouds.frequency then
  
  local cloud_index = flr(rnd(clouds.max_count)) + 1
  local cloud = clouds[cloud_index]
  
  if not cloud.active then
   clouds.timer = 0
  
   cloud.active = true
   cloud.x = 128
   cloud.y = 128 - 48 + flr(32*cloud_index/clouds.max_count)
   cloud.speed = 0.2 + 1.0*(cloud_index/clouds.max_count)
  end
 end
 
 for i=1,clouds.max_count do
  local cloud = clouds[i]
  
  if cloud.active then
   cloud.x -= cloud.speed
  end
  
  if cloud.x + 32 < 0 then
   cloud.active = false
  end
 end
end

----------
clouds.draw = function()
 
 -- the moon!
 spr( 38, 32, 4, 2, 2 )
 
 for i=0,5 do
  spr(200,-32+(i*32 - clouds.timer*60)%192,96,4,4)
 end
 for i=0,5 do
  spr(196,-32+(i*32 - clouds.timer*80)%192,96,4,4)
 end
 for i=0,5 do
  spr(192,-32+(i*32 - clouds.timer*120)%192,96,4,4)
 end

 for i=1,clouds.max_count do
  local cloud = clouds[i]
  
  if cloud.active then
   spr( 10, cloud.x, cloud.y, 4, 4 )
  end
 end
end

-------------------
-- score_bubbles
-------------------
score_bubbles = {}
score_bubbles.max_count = 22
score_bubbles.index = 1
score_bubbles.next = 1

for i=1, score_bubbles.max_count do
 local score_bubble = {}
 score_bubble.x = 0
 score_bubble.y = 0
 score_bubble.score = 0
 score_bubble.timer = 0.0
 add( score_bubbles, score_bubble )
end

-------------------

score_bubbles.launch = function( x, y, score, timer )
 local score_bubble = score_bubbles[score_bubbles.next]
 
 score_bubble.x = x
 score_bubble.y = y
 score_bubble.score = score
 score_bubble.timer = timer
 
 score_bubbles.next += 1
 
 if score_bubbles.next > score_bubbles.max_count then
  score_bubbles.next = 1
 end
end

--------------------
score_bubbles.update = function()
 for i=1, score_bubbles.max_count do
  local score_bubble = score_bubbles[i]
  
  if score_bubble.timer > 0.0 then
   score_bubble.timer -= one_frame
   score_bubble.y -= 0.1
  end
 end
end

--------------------
score_bubbles.draw = function()
 for i=1, score_bubbles.max_count do
  local score_bubble = score_bubbles[i]
  
  if score_bubble.timer > 0.0 then
   print_outline( "+"..score_bubble.score, score_bubble.x, score_bubble.y, 7, 1 )
   score_bubble.timer -= one_frame
   score_bubble.y -= 2
  end
 end
end

-------------------

ftypes  = {
 { color =  8, sprite = 4 },
 { color = 11, sprite = 36 },
 { color = 14, sprite = 4 },
 { color =  9, sprite = 36 },
 { color = 13, sprite = 4 },
 { color = 10, sprite = 36 },
 { color = 12, sprite = 4 },
}

------------------------------
-- flowers
------------------------------
flowers = {}
flowers.w = 16
flowers.hw = flowers.w/2
flowers.h = 16
flowers.hh = flowers.h/2
flowers.max_count = 22
flowers.front_index = 1
flowers.separation = 6
flowers.main_y = 0
flowers.selected = flowers.front_index
flowers.clicked = false
flowers.blink_rate = 0.1
flowers.blink_timer = 0.0
flowers.explosion_duration = 0.1
flowers.exploding_index = -1

for i=1,flowers.max_count do
 local flower = {}
 flower.x = i * flowers.separation
 flower.y = 0
 flower.ftype_index = 1
 flower.explosion_timer = 0.0
 flower.dead = true
 flower.frozen = false
 add(flowers, flower)
end

flowers[1].ftype_index = 1
flowers[1].dead = false
flowers[1].frozen = true

-----------------
flowers.init = function()
 flowers.front_index = 1
 flowers.separation = 6
 flowers.main_y = 0
 flowers.selected = flowers.front_index
 flowers.clicked = false
 flowers.blink_timer = 0.0
 flowers.exploding_index = -1

 for i=1,flowers.max_count do
  local flower = flowers[i]
  flower.x = i * flowers.separation
  flower.y = 0
  flower.ftype_index = 1
  flower.explosion_timer = 0.0
  flower.dead = true
  flower.frozen = false
 end

 flowers[1].ftype_index = 1
 flowers[1].dead = false
 flowers[1].frozen = true
end

-----------------
function copy_flower( target, source )
 target.ftype_index = source.ftype_index
 target.dead = source.dead
 target.frozen = source.frozen
end

-----------------
flowers.match_check = function()
 local found_match = false

 flowers.exploding_index = -1

 if flowers.front_index >= 4 then
 
  for i = 1, flowers.front_index-2 do
   local ftype_index1 = flowers[i].ftype_index
   local ftype_index2 = flowers[i+1].ftype_index
   local ftype_index3 = flowers[i+2].ftype_index
   
   local clicked_and_selected = flowers.clicked and
                                ( flowers.selected == i or 
                                  flowers.selected == i+1 or 
                                  flowers.selected == i+2 )
   -- check for match-3
   if not clicked_and_selected and
      not flowers[i].frozen and 
      not flowers[i+1].frozen and 
	  not flowers[i+2].frozen and
      ftype_index1 == ftype_index2 and ftype_index1 == ftype_index3 then

	found_match = true
	
    if flowers.exploding_index == -1 then
     flowers.exploding_index = i
    end
	
    flowers[i].explosion_timer = flowers.explosion_duration
    flowers[i+1].explosion_timer = flowers.explosion_duration
    flowers[i+2].explosion_timer = flowers.explosion_duration
	
	-- check if nearby flowers are frozen
	if i-1 > 1 then
	 if flowers[i-1].frozen and not flowers[i-1].dead then
	  flowers[i-1].frozen = false
	  sfx(rnd()>0.5 and 3 or 4)
      make_explosion( flowers[i-1].x, flowers[i-1].y - flowers.hh + flowers.main_y*6, 3, 2, 7 )
	 end
	end
		
    if i+3 <= flowers.front_index then
	 if flowers[i+3].frozen and not flowers[i+3].dead then
	  flowers[i+3].frozen = false
	  sfx(rnd()>0.5 and 3 or 4)
      make_explosion( flowers[i+3].x, flowers[i+3].y - flowers.hh + flowers.main_y*6, 3, 2, 7 )
	 end
	end
	
   end
  end
 end
 
 return found_match
 
end


-----------------
flowers.erased_matched = function()

   for i = 2, flowers.max_count-1 do
	local left_alive = true
	
	while left_alive and flowers[i].dead do
     left_alive = false
	 
	 for j = i, flowers.max_count-1 do
	  copy_flower( flowers[j], flowers[j+1] )
      
	  if not flowers[j].dead then
	   left_alive = true
	  end
	  
	 end
	 
	 flowers[flowers.max_count].dead = true
	  
	end
   end
 
 for i = 1, flowers.max_count do
  if not flowers[i].dead then
   flowers.front_index = i
  end
 end
 
 
 while flowers.selected > 2 and flowers[flowers.selected].dead do
  flowers.selected -= 1
 end
 
end

-----------------
flowers.insert = function( index, ftype_index, frozen )
 
 if frozen then
  sfx(6)
 else
  sfx(5)
 end
 
 flowers.front_index += 1
 
 local new_flower = flowers[index + 1]

 if index + 1 < flowers.front_index then
  for i = flowers.front_index - 1, index, -1 do
   copy_flower( flowers[i+1], flowers[i] )
   flowers[i + 1].y = tracks.eval( flowers[i + 1].x )
  end
 end
 
 new_flower.ftype_index = ftype_index
 new_flower.dead = false
 new_flower.frozen = frozen
 new_flower.y = tracks.eval( new_flower.x )
 
 local found_match = flowers.match_check()
 
 if found_match then
  pause_game()
 end

 if flowers.front_index >= flowers.max_count then
  flowers.gameover()
 end

end

-----------------
flowers.gameover = function()
 flowers.exploding_index = 1
 
 for i = 1, flowers.max_count do
  flowers[i].explosion_timer = flowers.explosion_duration
 end

 regular_speed = 2 
 gameover = true
 game_paused = false
 
 gameovers.launch()

 if hi_score < score then
  hi_score = score
  dset(0,hi_score)
 end

end

-----------------
flowers.recompute_separation = function()
 local min_sep = 6
 local max_sep = 12
 
 flowers.separation = max_sep - (flowers.front_index/flowers.max_count)*(max_sep-min_sep)
 
 for i=1,flowers.max_count do
  flower = flowers[i]
  flower.x = i * flowers.separation
 end
end

-----------------
flowers.update = function()
 
 -- adjust selected just in case
 if flowers.front_index <= 1 then
  flowers.selected = -1
 elseif flowers.front_index == 2 then
  flowers.selected = 2
 end
 
 -- if we're currently selecting a frozen flower or selecting nothing, 
 -- try to select a non-white or -1 if not found
 if flowers.selected == -1 or flowers[flowers.selected].frozen then
  for i = flowers.front_index, 2, -1 do
   if flowers[i].frozen then
    if flowers[i+1] and not flowers[i+1].dead then 
	 flowers.selected = i+1
	else
	 flowers.selected = -1
	end
	
	break
   end
  end
 end

 if btnp(5) then
  flowers.clicked = not flowers.clicked
  
  if flowers.clicked then
   if flowers.selected != -1 then
    sfx(1)
   end
  else
   if flowers.selected != -1 then
    sfx(2)
   end
   
   local found_match = flowers.match_check()
   
   if found_match then
    pause_game()
   end
  
  end
 end

 if btn(1) then
  if flowers.selected != -1 then
   if flowers.selected < flowers.front_index and flowers.front_index >= 2 then
    if not flowers[flowers.selected+1].frozen then
     flowers.selected += 1
   
     if flowers.clicked then
	  local swapped_ftype_index = flowers[flowers.selected].ftype_index
      flowers[flowers.selected].ftype_index = flowers[flowers.selected-1].ftype_index
	  flowers[flowers.selected-1].ftype_index = swapped_ftype_index
     end
    end
   end
  end
 end

 if btn(0) then
  if flowers.selected != -1 then
   if flowers.selected > 1 and flowers.front_index >= 2 then
    if not flowers[flowers.selected-1].frozen then   
     flowers.selected -= 1
  
     if flowers.clicked then
      local swapped_ftype_index = flowers[flowers.selected].ftype_index
      flowers[flowers.selected].ftype_index = flowers[flowers.selected+1].ftype_index
	  flowers[flowers.selected+1].ftype_index = swapped_ftype_index
     end
    end
   end
  end
 end
 
 if btn(2) then
  flowers.main_y -= 1
  
  if flowers.main_y < 0 then
   flowers.main_y = 0
  else
   sfx(0)
  end
 end

 if btn(3) then
  flowers.main_y += 1

  if flowers.main_y > 6 then
   flowers.main_y = 6
  else
   sfx(0)
  end
 end 

 for i = 1, flowers.front_index do
  local flower = flowers[i]
  local offsety = 0
    
  if flowers.selected == i then
   if flowers.clicked then
    flowers.blink_timer -= one_frame
	if flowers.blink_timer <= 0.0 then
	 flowers.blink_timer = flowers.blink_rate
	end
	
	offsety = -8
   end
  end

  flower.y = tracks.eval( flower.x ) + offsety  
 end 
 
 flowers.recompute_separation()
end

----------------
flowers.paused_update = function()
 -- check exploding flowers
 if flowers.exploding_index != -1 then
  local flower = flowers[flowers.exploding_index]
  
  if flower.explosion_timer > 0.0 then
    local scale = 1.0 - flower.explosion_timer / flowers.explosion_duration
	
	flower.y -= scale * 4
	flower.explosion_timer -= one_frame
  else
   local color = ftypes[flower.ftype_index].color
   sfx(rnd()>0.5 and 3 or 4)
   
   local flower_y = flower.y - flowers.hh + flowers.main_y*6
   
   make_explosion( flower.x, flower_y, 5, 2, color )
   
   flower.dead = true
   
   score += score_multiplier
   score_multiplier += 1
   
   score_bubbles.launch( flower.x, flower_y, 10*score_multiplier, 0.1*score_multiplier )
   
   -- fix up the explosion offset we added previously
   flower.y = tracks.eval( flower.x )
   
   flowers.exploding_index += 1
   
   while flowers[flowers.exploding_index] and
         flowers[flowers.exploding_index].explosion_timer <= 0.0 do
    flowers.exploding_index += 1
   end
   
   if not flowers[flowers.exploding_index] then
    flowers.erased_matched()
	
	flowers.exploding_index = -1
	
	-- check for matches again.
	local found_match = flowers.match_check()
	
	if not found_match then
	 unpause_game()
	end
   end
  end
 end
end

----------------
flowers.gameover_update = function()

 for i = 1, flowers.front_index do
  local flower = flowers[i]
  flower.y = tracks.eval( flower.x )
 end
 
 -- check exploding flowers
 if flowers.exploding_index != -1 then
  local flower = flowers[flowers.exploding_index]
  
  if flower.explosion_timer > 0.0 then
    local scale = 1.0 - flower.explosion_timer / flowers.explosion_duration
	
	flower.y -= scale * 4
	flower.explosion_timer -= one_frame
  else
   local color = ftypes[flower.ftype_index].color
   sfx(rnd()>0.5 and 3 or 4)
   make_explosion( flower.x, flower.y - flowers.hh + flowers.main_y*6, 5, 2, color )
   
   flower.dead = true
      
   flowers.exploding_index += 1
   
   while flowers[flowers.exploding_index] and
         flowers[flowers.exploding_index].explosion_timer <= 0.0 do
    flowers.exploding_index += 1
   end
   
   if not flowers[flowers.exploding_index] then
    flowers.exploding_index = -1
   end
  end
 end
end

-----------------
flowers.draw = function()

 for i = 1, flowers.front_index do
  local flower = flowers[i]

  if not flower.dead then 
   if flowers.selected == i then
    pal(0,7)
   
    if flowers.clicked then
 	 if flowers.blink_timer <= 0.0 then
	  pal(0,0)
	 else
	  pal(0,7)
	 end
    end
   end
   
   local color = ftypes[flower.ftype_index].color
   local sprite = ftypes[flower.ftype_index].sprite
   
   if flower.frozen then
    pal( 8, 7 )
   else
    pal( 8, color )
   end 
	
   spr( sprite, flower.x-flowers.hw, flower.y - flowers.h + flowers.main_y*6 + 3, 2, 2 )
  
   --line(flower.x-flowers.hw,0,flower.x-flowers.hw,128,7)
  
   pal(0,0)
   pal(8,8)
  end
 end

 --local front = flowers[flowers.front_index]
 --print( "f="..front.x..","..flowers.main_y, 60, 6, 7 )
 
end

------------------------------
-- enemies
------------------------------
enemies = {}
enemies.max_count = 10

enemies.spawn_timer = 0
enemies.spawn_count = 0
enemies.next = 1
enemies.spawn_rate = 2
enemies.max_ftype = 4

for i=1,enemies.max_count do
 enemy = {}
 enemy.active = false
 enemy.x = -8
 enemy.y = 0
 enemy.speed = 0
 enemy.ftype_index = 1
 add(enemies, enemy)
end 

------------

enemies.init = function()

 enemies.spawn_timer = 0
 enemies.spawn_count = 0
 enemies.next = 1
 enemies.spawn_rate = 2
 enemies.max_ftype = 4

 for i=1,enemies.max_count do
  local enemy = enemies[i]
  enemy.active = false
  enemy.x = -8
  enemy.y = 0
  enemy.speed = 0
  enemy.ftype_index = 1
 end 

end

------------
enemies.spawn = function()
 local enemy = enemies[enemies.next]
 
 enemy.active = true
 enemy.x = 128 + 16
 enemy.ftype_index = 1 + flr( rnd( enemies.max_ftype ) )
 
 enemy.y = ftypes[enemy.ftype_index].color - 8
 enemy.sprite = ftypes[enemy.ftype_index].sprite
 
 enemy.speed = 0
 
 enemies.spawn_count += 1

 -- every 50 enemies, add a new type (max 7 types) 
 if enemies.spawn_count % 50 == 0 then
  if enemies.max_ftype < #ftypes then
   enemies.max_ftype += 1
  end 
 end
 
 -- every 20 enemies, increase the base speed a little
 if enemies.spawn_count % 10 == 0 then
   
   if regular_speed < 6.0 then
    regular_speed += 0.1
   end
 end
 
 if enemies.spawn_count % 20 == 0 then
   if enemies.spawn_rate > 1.0 then
    enemies.spawn_rate -= 0.1
   end	
 end
 
end

------------
enemies.update = function()
 
 if btn(4) then
  enemies.spawn_timer -= 3*one_frame
 else
  enemies.spawn_timer -= one_frame
 end
 
 if not gameover and logo.dismissed then
  if enemies.spawn_timer <= 0 then
  
   enemies.spawn()
  
   enemies.next += 1
  
   if enemies.next > enemies.max_count then
    enemies.next = 1
   end
  
   enemies.spawn_timer = enemies.spawn_rate
  end
 end
 
 for i = 1, enemies.max_count do
  local enemy = enemies[i]
  
  if enemy.active then
   enemy.x -= enemy.speed + main_speed
  
   if enemy.x <= -16 then
    enemy.active = false
	local color = 8 + enemy.y
	
	if not gameover then
     flowers.insert( 1, enemy.ftype_index, true )
    end
   end
  end
 end
end

------------
enemies.draw = function( min_y, max_y )
 for i = 1, enemies.max_count do
  local enemy = enemies[i]
  if enemy.active then 
   --print( "e="..enemy.x..","..enemy.y, 60, 0, 7 )
   
   if enemy.y >= min_y and enemy.y <= max_y then 
    local y = tracks.eval( enemy.x )
    local color = 8 + enemy.y
	pal( 8, color )
    spr( enemy.sprite, enemy.x - 8, y + 6 * (enemy.y-2), 2, 2 )
    pal( 8, 8 )
	
	--line(enemy.x, 0, enemy.x, 128, 7)
   end
  end
 end
end

------------------------------
-- tracks
------------------------------
tracks ={}
tracks.track_lenght_x = 32
tracks.ys={}
tracks.count = 10
tracks.scroll_x = 0
tracks.next = 6

for i = 0, tracks.count do
 add( tracks.ys, flr( 34 + rnd( 40 ) ) )
end

------------
tracks.init = function()
 tracks.scroll_x = 0
 tracks.next = 6
 
 for i = 0, tracks.count do
  tracks.ys[i+1] = flr( 34 + rnd( 40 ) )
 end
 
end

------------
tracks.eval = function(x)

 local real_x = x + tracks.scroll_x
 
 local track_num = flr(real_x/tracks.track_lenght_x)
 local track_rem = real_x%tracks.track_lenght_x
 local track_lerp = track_rem/tracks.track_lenght_x

 local y1 = tracks.ys[1+(track_num+2)%(tracks.count-2)]
 local y2 = tracks.ys[1+(track_num+3)%(tracks.count-2)]
 
 return y1 + track_lerp*(y2-y1)
 
end

-------------
tracks.next_random = function()
 tracks.ys[1 + (tracks.next + 1)%tracks.count] = flr(34+rnd(40))
 tracks.next += 1
 
 if tracks.next > tracks.count then
  tracks.next = 1
 end
end

-------------
tracks.update = function()
  local last_start_i = flr(tracks.scroll_x/tracks.track_lenght_x)+3
 
  tracks.scroll_x += main_speed
  tracks.scroll_x %= ((tracks.count-2) * tracks.track_lenght_x)
 
  local this_start_i = flr(tracks.scroll_x/tracks.track_lenght_x)+3
 
  if last_start_i != this_start_i then
   tracks.next = (this_start_i + 3)%(tracks.count-2) + 1
   tracks.next_random()
   random_count += 1
  end  
end

-------------
tracks.draw = function()
 local start_i = flr( tracks.scroll_x / tracks.track_lenght_x ) + 3

 for i = start_i, start_i + 5 do
  px=-tracks.scroll_x+(i-3)*(tracks.track_lenght_x)
  x =-tracks.scroll_x+(i-2)*(tracks.track_lenght_x)

  local i1 = (i-1)%(tracks.count-2) + 1
  local i2 = (i)%(tracks.count-2) + 1
  
  py = tracks.ys[i1]
  y  = tracks.ys[i2]
  
  for j = 0, 6 do
   local yoffset = 6 * j
    
   line( px, 0 + yoffset + py, x, 0 + yoffset + y, j + 8 )
   line( px, 1 + yoffset + py, x, 1 + yoffset + y, j + 8 )

   if flowers.main_y == j then
    line( px, 2 + yoffset + py, x, 2 + yoffset + y, 7 )
   end
   
   line( px, 3 + yoffset + py, x, 3 + yoffset + y, j + 8 )
   line( px, 4 + yoffset + py, x, 4 + yoffset + y, j + 8 )
  end
 end
end

------------------------------
-- globals
------------------------------

one_frame = 1/30

t = 0
regular_speed = 2
main_speed = regular_speed

random_count = 0

gameover = false
game_paused = false
show_start_msg = true
show_restart_msg = false

score_multiplier = 1
score = 0
hi_score = 0

--------------------
-- on-launch function calls
-------------------
cartdata( "niji" )

tracks.init() -- don't need to re-init the tracks since they're always random
logo.launch()
music(0)

--------------------
function pause_game()
 if not game_paused then
  game_paused = true
  main_speed = 0
  score_multiplier = 1
 end
end

--------------------
function unpause_game()
 if game_paused then
  game_paused = false
  main_speed = regular_speed
 end
end

------------------------------
-- main touch
------------------------------

function _touch()

 for i = 1, enemies.max_count do
  local enemy = enemies[i]
  
  if enemy.active then
   local front_flower = flowers[flowers.front_index] 
   local front_x = front_flower.x
   local front_y = flowers.main_y
  
   if enemy.y == front_y then
    if enemy.x <= front_x + flowers.w then
	 local insertion_index = flr( enemy.x / flowers.separation )
	 
	 if insertion_index > flowers.front_index then
	  insertion_index = flowers.front_index
	 elseif insertion_index < 1 then
	  insertion_index = 1
	 end
	 
	 local color = 8 + enemy.y
	 
	 flowers.insert( insertion_index, enemy.ftype_index, false )
	 enemy.active = false
	end
   end   
   
  end
  
 end
end

------------------------------
-- main init
------------------------------

function _init()
 
 hi_score = dget(0)
 
 -- init globals
 t = 0
 regular_speed = 2
 main_speed = regular_speed

 random_count = 0

 gameover = false
 game_paused = false
 show_restart_msg = false

 score_multiplier = 1
 score = 0
 
 -- init objects
 enemies.init()
 flowers.init()
end


------------------------------
-- main update
------------------------------

function _update()
 t += one_frame

 if not logo.dismissed then
  tracks.update()
  stars.update()
  clouds.update()
  
  enemies.update()
  flowers.gameover_update()
  
 elseif gameover then
  
  tracks.update()
  stars.update()
  clouds.update()
  
  enemies.update()
  flowers.gameover_update()

 elseif not game_paused then 

  tracks.update()


 -- speed up button
  if btn(4) then
   main_speed = 3*regular_speed
  else
   main_speed = regular_speed
  end
 
  stars.update()
  clouds.update()
 
  enemies.update()
  _touch()

  flowers.update()

 else
  flowers.paused_update()  
 end
 
 explosions.update()
 score_bubbles.update()
 
 gameovers.update()
 logo.update()
 
end


------------------------------
-- main draw
------------------------------

function _draw()
 cls()
 palt()
 palt( 0, false )
 palt( 2, true )
 
 stars.draw()
 clouds.draw()
 
 tracks.draw()

 if score == 0 then 
  print( "scr:0", 1, 1, 7 )
 else
  print( "scr:"..score.."0", 1, 1, 7 )
 end

 if hi_score == 0 then 
  print( "hi:0", 128 - 4*4, 1, 7 )
 else
  local txt = "hi:"..hi_score.."0"
  print( txt, 128 - #txt*4, 1, 7 )
 end
 
 
 --print( "dist: "..random_count, 4, 4, 7 )

 --print( "max type: "..enemies.max_ftype, 4, 10, 7 )
 --print( "rate: "..enemies.spawn_rate, 4, 16, 7 )
 --print( "speed: "..main_speed, 4, 22, 7 )
 --print( "multiplier: "..score_multiplier, 4, 28, 7 )
 
 
 print( "guerragames 2016", 128-16*4, 128-6, 0 )

 gameovers.draw()
 logo.draw()
 
 if logo.dismissed then  
  enemies.draw( 0, flowers.main_y )
  flowers.draw()
  enemies.draw( flowers.main_y, 6 )
 end
 
 explosions.draw()
 score_bubbles.draw()
 
 --rect(0,0,127,127,7)
 
 flip()
end
__gfx__
00000000000000000000000000000000222000000000022222200000000002222200222002222222222222222222200000022222222222220000000000000000
00000000000000000000000000000000200088888888000222077777777770222077020770022222222222222220077777700222222222220000000000000000
0000000000000000000000000000000000888999999888002077777777777702207c7077c7022222222222222207777777777022222222220000000000000000
00000000000000000000000000000000088999099099988020777777777777020777c7777c700222222222222077777777777702222222220000000000000000
0000000000000000000000000000000008899909909998802077777777777702077777777777022222222222207777077077c702222222220000000000000000
00000000000000000000000000000000088889999998888007777777777777700cc77c77c7760222222222220777770770777c70222222220000000000000000
0000000000000000000000000000000000888888888888000777770770777770200c60c60c602222222222220777770770777c70222222220000000000000000
00000000000000000000000000000000200088888888000207777707707777702220020020022222222222207777777777777777000022220000000000000000
00000000000000000000000000000000222000000000022207777707707777702222222222222222222220007777777777777777777700220000000000000000
000000000000000000000000000000002002220bb022200207777777777777702222222222222222222007777777777777777777777777020000000000000000
000000000000000000000000000000000bb0020bb0200bb007077777777770702222222222222222220777777777777777777777777c77020000000000000000
000000000000000000000000000000000b0bb00bb00bb0b0207770777707770222222222222222222077777777777777777777777777c7700000000000000000
000000000000000000000000000000000bb0bb0bb0bb0bb0207777000077770222222222222222222077777777777777777777777777c7700000000000000000
0000000000000000000000000000000020bb0b0bb0b0bb0220777777777777022222222222222222077777777777777777777777777cc7700000000000000000
000000000000000000000000000000002200b0bbbb0b002222077770077770222222222222222222077777777777777777777777cccc77020000000000000000
0000000000000000000000000000000022220000000022222220000220000222222222222222222220777777c7777777777777777cc777020000000000000000
00000000000000000000000000000000222222200222222222200000022222220000000000000000207c777cc777777cc77777777cc700220000000000000000
0000000000000000000000000000000022022208802220222220aaaaa0022222000000000000000022077ccc7777777cc77777777cc702220000000000000000
00000000000000000000000000000000208020888802040222220aaaaaa022220000000000000000222007777777777cc777c777cc7702220000000000000000
000000000000000000000000000000002088088888808802222220aaaaaa022200000000000000002222200077c777cc700777cc777022220000000000000000
000000000000000000000000000000000888888888888840222220aaaaaaa022000000000000000022222222077cccc770200777700222220000000000000000
0000000000000000000000000000000008880088800888402222220a0a0aa0220000000000000000222222222007777002222000022222220000000000000000
0000000000000000000000000000000008808808088088402222220a0a0aaa020000000000000000222222222220000222222222222222220000000000000000
0000000000000000000000000000000008888888888884402222220a0a0aaa020000000000000000222222222222222222222222222222220000000000000000
000000000000000000000000000000002088888888888402222220aaaaaaaa020000000000000000222222222222222222222222222222220000000000000000
00000000000000000000000000000000220488888844402222200a0aaaa0aa020000000000000000222222222222222222222222222222220000000000000000
000000000000000000000000000000002220044444400222000aaa0aaa0aa0220000000000000000222222222222222222222222222222220000000000000000
0000000000000000000000000000000022222000000222220aaaaaa000aaa0220000000000000000222222222222222222222222222222220000000000000000
000000000000000000000000000000002200020b3000022220aaaaaaaaaa02220000000000000000222222222222222222222222222222220000000000000000
0000000000000000000000000000000020bb300b30bb3022220aaaaaaaa022220000000000000000222222222222222222222222222222220000000000000000
000000000000000000000000000000000bbbb30b0bbbb30222200aaaa00222220000000000000000222222222222222222222222222222220000000000000000
00000000000000000000000000000000200000000000002222222000022222220000000000000000222222222222222222222222222222220000000000000000
22222000002222222000222222220002000000220000002200000022222222200000022200000022000000220000000200000002222222200000002000000022
22200887880022220777022222207770088880020888802208888022222222208888022208888022088880020888880208888802222222208888802088888022
22077008888802220777022222207770080088000800802208008022222222208008022208008022080008000800080208000802222222208000802080008022
22077770078880220777702222077770080008800800802208008022222222208008022208008022090000900900090209000902222222208000802090009022
22207777708878022077702222077702090000990900902209009022222222209009022209009022090000090900090209000902222222208000802090009022
222200777708880222077702207770220900000999009022090090222222222090090222090090220a000000aa000a020a000a0200000020a000a020a000a022
222222077770888020807770077708020a000000aa00a0220a00a02222222220a00a02220a00a0220a0000000a000a020a000a020aaaa020a000a020a000a022
200002200777078020780777777078020a0000000a00a0220a00a02200000020a00a02220a00a0220b00000000000b020b000b020b00b020b000b020b000b022
077770000077088008887077770778700b00b0000000b0220b00b0220bbbb020b00b02220b00b0220b000b0000000b020b000b020b00b020b000b020b000b022
007777777777088008887700008888700b00bb000000b0220b00b0220b00b020b00b02220b00b0220c000cc000000c020c000c020c00c000c000c020c000c022
200007777770880208888888778888800c00ccc00000c0220c00c0220c00c000c00c02220c00c0220c000c0c00000c020c000c020c000ccc0000c020c000c022
220880000008870220877888778888020c00c0cc0000c0220c00c0220c000ccc000c02220c00c0220d000d00d0000d020d000d020dd00000000dd020d000d022
220788888888802220877888888877020d00d00dd000d0220d00d0220d000000000d02220d00d0220d000d000d000d020d000d0200dd000000dd0020d000d022
222088788878802222008888888800220d00d000dd00d0220d00d02200d0000000d002220d00d0220eeeee0200eeee020eeeee02200eeeeeeee00220eeeee022
222200888880022222220000000022220eeee0200eeee0220eeee022200eeeeeee0022220eeee022000000022000000200000002220000000000222000000022
22222200000222222222220000222222000000220000002200000022220000000002222200000022222222222222222222222222222222222222222222222222
2002220b302220022002220b30222002200000020000000220000000222222220000000200000002000000000000000000000000000000000000000000000000
0bb0020b30200b300bb0020b30200b30008888000888880000888880022222200888880008888800008888800088888000888880000000000888880008888800
0b0bb00b300bb0300b0bb00b300bb030088888808888888008888888022222208888888088888880088888880888888808888888000000008888888088888880
0b033b0b30b330300b033b0b30b33030088008888800088008800088022222208800088088000880088000888880008808800088000000008800088088000880
0b303b0b30b303300b303b0b30b30330099000999900099009900099022222209900099099000990099000099990009909900099000000008800088099000990
2033030b303033022033030b30303302099000099900099009900099000000009900099099000990099000009990009909900099000000008800088099000990
2200303b330300222200303b330300220aa00000aa000aa00aa000aa00aaaa00aa000aa0aa000aa00aa000000aa000aa0aa000aa00aaaa00aa000aa0aa000aa0
2222000b300022222222000b300022220aa000000a000aa00aa000aa0aaaaaa0aa000aa0aa000aa00aa0000000a000aa0aa000aa0aaaaaa0aa000aa0aa000aa0
000000000000000000000000000000000bb00b0000000bb00bb000bb0bb00bb0bb000bb0bb000bb00bb00000000000bb0bb000bb0bb00bb0bb000bb0bb000bb0
000000000000000000000000000000000bb00bb000000bb00bb000bb0bb00bbbbb000bb0bb000bb00bb000b0000000bb0bb000bb0bb00bb0bb000bb0bb000bb0
000000000000000000000000000000000cc00ccc00000cc00cc000cc0cc000ccc0000cc0cc000cc00cc000cc000000cc0cc000cc0cc00ccccc000cc0cc000cc0
000000000000000000000000000000000cc00cccc0000cc00cc000cc0cc0000000000cc0cc000cc00cc000ccc00000cc0cc000cc0cc000ccc0000cc0cc000cc0
000000000000000000000000000000000dd00ddddd000dd00dd000dd0ddd00000000ddd0dd000dd00dd000dddd0000dd0dd000dd0ddd00000000ddd0dd000dd0
000000000000000000000000000000000dddddd0ddddddd00ddddddd00dddddddddddd00ddddddd00dd000ddddd000dd0dd000dd00ddd000000ddd00dd000dd0
0000000000000000000000000000000000eeee000eeeee0000eeeee0000eeeeeeeeee0000eeeee000eeeeeee0eeeeeee0eeeeeee000eeeeeeeeee000eeeeeee0
0000000000000000000000000000000020000002000000022000000022000000000000220000000200eeeee000eeeee000eeeee00000eeeeeeee00000eeeee00
20000002000000022000000022222222222222220000000220000000000000022000000000000002200000000000000220000002000000022000000000000002
00888800088888000088888002222222222222200888880000888888888888000088888888888800008888888888880000888800088888000088888888888800
08888880888888800888888802222222222222208888888008888888888888800888888888888880088888888888888008888880888888800888888888888880
08800888880008800880008802222222222222208800088009900000000009900888000000008880088800000000888008800888880008800888000000000880
09900099990009900990009902222222222222209900099009900000000009900990000000000990099000000000099009900099900009900990000000000990
0990000999000990099000990222222220000000990009900aa0000000000aa00990009999000990099000999000099009900009000009900990099999999990
0aa00000aa000aa00aa000aa0222222200aaaa00aa000aa00aa0000000000aa00aa00aaaaaaaaaa00aa00aaaaa000aa00aa0000000000aa00aa00aaaaaaaaa00
0aa000000a000aa00aa000aa022222220aaaaaa0aa000aa00bb0000000000bb00aa00aaaaaaaaaa00aa00aaaaa000aa00aa0000000000aa00aa0000000aa0002
0bb00b0000000bb00bb000bb022222220bb00bb0bb000bb00bb0000000000bb00bb00bbb00000bb00bb0000000000bb00bb00b000b000bb00bb0000000bb0002
0bb00bb000000bb00bb000bb022222220bb00bbbbb000bb00cc0000000000cc00bb00bbb00000bb00bb0000000000bb00bb00bb0bb000bb00bb00bbbbbbbbb00
0cc00ccc00000cc00cc000cc022222220cc000ccc0000cc00cc0000000000cc00cc000cccc000cc00cc00ccccc000cc00cc00ccccc000cc00cc00cccccccccc0
0cc00cccc0000cc00cc000cc022222220cc0000000000cc00dd0000000000dd00cc0000000000cc00cc00ccccc000cc00cc00ccccc000cc00cc0000000000cc0
0dd00ddddd000dd00dd000dd022222220ddd00000000ddd00dd0000000000dd00ddd00000000ddd00dd00dd0dd000dd00dd00dd0dd000dd00ddd000000000dd0
0dddddd0ddddddd00ddddddd0222222200dddddddddddd000eeeeeeeeeeeeee000dddddddddddd000dddddd0ddddddd00dddddd0ddddddd00dddddddddddddd0
00eeee000eeeee0000eeeee002222222200eeeeeeeeee00200eeeeeeeeeeee00200eeeeeeeeee00200eeee000eeeee0000eeee000eeeee0000eeeeeeeeeeee00
20000002000000022000000022222222220000000000002220000000000000022200000000000022200000020000000220000002000000022000000000000002
00000000000000000000000000000000000000000000000000000000000000002000000000000002200000020000000220000000000000022000000000000002
00000000000000000000000000000000000000000000000000000000000000000088888888888800008888000888880000888888888888000088888888888800
00000000000000000000000000000000000000000000000000000000000000000888888888888880088888808888888008888888888888800888888888888880
00000000000000000000000000000000000000000000000000000000000000000888000000008880088008808800088008880000000008800888000000008880
00000000000000000000000000000000000000000000000000000000000000000990000000000990099009909900099009900000000009900990000000000990
00000000000000000000000000000000000000000000000000000000000000000990009990000990099009909900099009900999999999900990099999000990
00000000000000000000000000000000000000000000000000000000000000000aa00aaaaa000aa00aa00aa0aa000aa00aa00aaaaaaaaa000aa00aaaaa000aa0
00000000000000000000000000000000000000000000000000000000000000000aa00aa0aa000aa00aa00aaaaa000aa00aa0000000aa00020aa0000000000aa0
00000000000000000000000000000000000000000000000000000000000000000bb00bb0bb000bb00bb000bbb0000bb00bb0000000bb00020bb000000000bbb0
00000000000000000000000000000000000000000000000000000000000000000bb00bbbbb000bb00bbb000b0000bbb00bb00bbbbbbbbb000bb00bb000bbbb00
00000000000000000000000000000000000000000000000000000000000000000cc000ccc0000cc000ccc000000ccc000cc00cccccccccc00cc00ccc000ccc00
00000000000000000000000000000000000000000000000000000000000000000cc0000000000cc0200ccc0000ccc0020cc0000000000cc00cc00cccc000ccc0
00000000000000000000000000000000000000000000000000000000000000000ddd00000000ddd02200ddd00ddd00220ddd000000000dd00dd00ddddd000dd0
000000000000000000000000000000000000000000000000000000000000000000dddddddddddd0022200dddddd002220dddddddddddddd00dddddd0ddddddd0
0000000000000000000000000000000000000000000000000000000000000000200eeeeeeeeee002222200eeee00222200eeeeeeeeeeee0000eeee000eeeee00
00000000000000000000000000000000000000000000000000000000000000002200000000000022222220000002222220000000000000022000000000000002
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111222222221111111222211112221100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222221111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222ddd22222ddddddddd222ddddd2222ddd1111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
22222222222222222222222222222222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
22cc22222ccccc2222ccc2222cccc222dddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd1111111111111111111111111111111100000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000500001104015040190301f1001a100161001310010100101003310037100157001570016700167001670014600282002620012200252002320009100120000000000000000000000000000000000000000000
000500000b270152701c2701a50001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001d270152700b2701a50001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500003066022660166601064009640066200161004600016000160001600086000a60001600026000360004600056000560000000000000000000000000000000000000000000000000000000000000000000
00050000376602e66023660156400c6400a6200161004600016000160001600086000a60001600026000360004600056000560000000000000000000000000000000000000000000000000000000000000000000
000300001f07026070190500b04004000030000100003700037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000241701e1701615010140101400b1300b12005120041700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000024775247752877524775247752977524775247752b77524775247752d77524775247752b7752b77524775247752977524775247752b77524775247752d77524775247752b77524775247752977529775
0114000018072180721807218072180721807218072180721d0721d0721d0721d0721d0721d0721d0721d0721f0721f0721f0721f0721f0721f0721f0721f0722107221072210722107221072210721f0721d072
011400002d0722d0722d0722d0722d0722d0722d0722d0722f0722f0722f0722f0722f0722f0722f0722f0723007230072300723007230072300723007230072320723207232072320722d0722d0722b0722b072
01140000300723007230002280023200232072320022f0722f0022f0022f0022d0022d0022d0022d0022f0022d0722d072300022b0022f0022b0722b002300722b0022f0722b0022b0722b0022b0722d0722b072
01140000300753007530075280053200532075320752f0752f0052f0752f0052f0752f0752f0752f0752f0052d0752d075300052b0052f0052b0752b005300752b0052f0752b0052b0752b0052b0752d0752b075
0114000039075390753907528005320053707537075370753b0753b0753b07537005370053907539075390753c0753c0753c0752b0052f0053b0753b0753b0753e0753e0753e075350052b0053c0753c0753c075
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000024063000002d6432400324063240632d6430000024063240632d6432406324003240632d6430000024063000002d6432400324063240632d6430000024063240632d6432406324063240632d64324003
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0a 08 43 44
01 0a 14 43 44
00 0a 0b 14 44
00 0a 0c 14 44
01 0a 0d 14 44
00 0a 0d 14 44
00 0a 0e 14 44
00 0a 0e 14 44
00 0a 0f 14 44
00 0a 0b 14 44
02 0a 0c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 0a 0b 43 44
00 0a 0c 43 44
01 0a 0d 14 44
00 0a 0d 14 44
01 0a 0e 14 44
01 0a 0e 43 44
00 0a 0f 43 44
00 0a 0b 43 44
00 0a 0c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
