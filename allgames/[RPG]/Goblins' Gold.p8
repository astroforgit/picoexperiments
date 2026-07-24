pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init and menu


function _init() 
 cartdata("playmedusa_goblinnest")
 mainmenu_init()
end


-- mainmenu and gameover

function mainmenu_init()
 _update = mainmenu_update
 _draw = mainmenu_draw
end


function mainmenu_update()
 if btnp(—) then
  sfx(fx_startgame)
  wait(40)
		game_init()
 end
end


function mainmenu_draw()
 cls()
 spr(64,15,2,96,96)
 local score=dget(0)
 local highscore="highscore: "..score
 local pressx="press — to begin"
 local by="@playmedusa,2020"
 print(highscore,64-#highscore*2,104,9)
 print(pressx,64-#pressx*2,112,6)
 print(by,64-#by*2,120,1)
end


-- gameover


function gameover_init() 
 _update = gameover_update
 _draw = gameover_draw
end


function gameover_update() 
 if btnp(—) then
		mainmenu_init()
 end
end


function gameover_draw() 
 game_draw()
 local topx=35
 local topy=35
 local w=60
 local h=45
 
 rect(topx,topy,topx+w,topy+h,5)
 rectfill(topx+1,topy+1,topx+w-1,topy+h-1,0)
 print("game over", topx+5, topy+5,7)
 print("score: "..game_state.score,topx+5,topy+15,6)
 print("highscore:"..dget(0),topx+5,topy+25,6)
 print("press —", topx+5, topy+35,6)
end

-- ending

function ending_init() 
 _update = ending_update
 _draw = ending_draw
end


function ending_update() 
 if btnp(—) then
		mainmenu_init()
 end
end


function ending_draw() 
 cls()
 local topx=35
 local topy=35
 local w=60
 local h=45
 
 if game_state.level==10 and #deadpools>0 then
  print("you leave the goblins' nest")
  print("with your bag full of gold...")
  print("but an empty soul.")
  print("within those caves")
  print("the worst monster was you!")
 else
  print("finally understood, didn't you?")
  print("it wasn't worth it.")
  print("you leave all loot behind")
  print("for those who survived")
  print("the slaughter.")
 end
 
 rect(topx,topy,topx+w,topy+h,5)
 rectfill(topx+1,topy+1,topx+w-1,topy+h-1,0)
 print("the end", topx+5, topy+5,7)
 print("your score: "..game_state.score,topx+5,topy+15,6)
 print("highscore:"..dget(0),topx+5,topy+25,6)
 print("press —", topx+5, topy+35,6)
end
-->8
-- game

actors = {}
monsters = {}
deadpools = {}
items = {}
fxs = {}
skipframe = 0
game_state = {
 level = 1,
 score = 0,
 gems = 0,
 walls = nil,
 floor = nil
}
levels = nil



function game_init() 
 _update = game_update
 _draw = game_draw
 begin_game() 
end


function begin_game()
 levels = setup_levels()
 game_state.level = 1
 game_state.score = 0
 start_level()
end


function start_level()
	vignette(true,0,0,50) 
 actors = {}
 monsters = {}
 deadpools = {}
 items = {}
 skill_cd = {}
 if game_state.level < 9 then
 	generate_level(game_state.level)
  p = a_player()
  generate_monsters()
 else
  show_ending_level()
  p = a_player()
  for i=1,15 do
 		an_innocent()
 	end
 end
end


function end_level()
 game_state.level += 1
 if game_state.level < 9 then  
 	start_level()
 	sfx(fx_stairs)
 else
  ending_init()
 end
end


function generate_monsters() 
 for i=1,game_state.level+1 do
  spawn_monster()
 end
end


function spawn_monster()
 local monster_list = {
  a_slime,
		a_goblin,
  a_fat_goblin,
  a_lancer,
  a_fly,
  a_bomber,
  a_mage
 }
 local i=flr(1+rnd(min(game_state.level,#monster_list)))
 local m=monster_list[i]()
 while dist(m.tile,p.tile) < 5 do
  m.tile=random_empty_tile()
 end
 m.pivot_point = tile_to_point(m.tile)
end



function game_update()  
 if skipframe > 0 then 
  skipframe -= 1
  return
	end
 
 -- adding stairs
 if (#monsters==0 or game_state.level==9) and game_state.gems==0 then
  game_state.gems = -1
  local tile = random_empty_tile()
  for e in all(deadpools) do
   if same_pos(e.tile,tile) then
    del(deadpools,e)
   end
  end
  mset(tile.x,tile.y,spr_stairs)
  sfx(fx_stairs_appear)
 end
 
 -- turns
 if is_turn(p) then 
  if p.brain(p) then   
   cooldown_skills()   
   end_turn(p)
  end
 else    
  update_speed(p)
  monsters_turn()
 end 
end



function monsters_turn()
 for i=#monsters,1,-1 do  
  local mob = monsters[i]  
  update_speed(mob)
   if is_turn(mob) then
    if mob.stunned > 0 then
		   mob.stunned -= 1 
	 	 else
	  	 if mob.brain != nil then
	  	  mob.brain(mob)  
	  	 end
	  	end
 	 	end_turn(mob)	   	  	 	
  	end
 end
end


function game_draw() 
 cls()
	map()
	
 for e in all(deadpools) do
  local pos = screen_pos(e)
  spr(e.sprite,pos.x,pos.y,1,1,e.fliph)
 end
 
 for i in all(items) do
  local pos = screen_pos(i)
  spr(i.sprite,pos.x,pos.y)
 end

	for e in all(actors) do
	 if (is_alive(e)) slide(e)
		local pos = screen_pos(e)
		spr(e.sprite,
		 pos.x,
		 pos.y,
		 1,1,e.fliph
		)		 

		if e.stunned>0 then
			spr(spr_stunned,
			 pos.x,pos.y)
		end
	end
	
	for e in all(monsters) do
		draw_hp(e)
	end
	
	for fx in all(fxs) do
	 spr(fx.sprite,fx.position.x,fx.position.y,1,1)
	 fx.update(fx)
	end
	
	if _camerashake != 0 then
  doshake()
 end	
 
 draw_ui()
end


function draw_hp(e)
 for i=0,e.hp-1 do
  if e.hp != e.maxhp then
   local pos = screen_pos(e)
	  spr(spr_life, 
	   pos.x-(e.hp-1) + i*2, 
 	  pos.y-4)
 	end
	end		
end

 
function draw_ui()
 local level="level:"..game_state.level
 local score="score:"..game_state.score 
 local title=levels[game_state.level].title 
 
 text_panel(score,127-#score*4,2,0,5,7)
 text_panel(level,2,2,0,5,7)
 text_panel(title,64-#title*4/2,121,0,5,7)
 
 panel(54 - p.maxhp*4-2,0,p.maxhp*8+2,10,0,5)
	for i=0,p.hp-1 do
		spr(spr_heart, 
   54 - p.maxhp*4 + 8*i, 
	  2) 
	end
	
	panel(68,0,20,10,0,5)
	if skill_available("quickspin") then
 	spr(spr_quickspin,70,2)
	 print("—",79,3,7)
	else
	 print(skill_cd[1].heat,76,3)
	end
end


function panel(x,y,w,h,c1,c2)
 rectfill(x,y,x+w,y+h,c1)
 rect(x,y,x+w,y+h,c2)
end

function text_panel(text,x,y,c1,c2,text_c)
 local w = #text*4
 local h = 6
 rectfill(x-2,y-2,x+w,y+h,c1)
 rect(x-2,y-2,x+w,y+h,c2)
 print(text,x,y,text_c)
end


function slide(mob)
 local speed = #mob.movement_queue+1
 speed = max(speed, 0.25*magnitude(mob.offset))
 if (mob.offset.x > 0) mob.offset.x = max (0, mob.offset.x - speed)
 if (mob.offset.x < 0) mob.offset.x = min (0, mob.offset.x + speed)
 if (mob.offset.y > 0) mob.offset.y = max (0, mob.offset.y - speed)
 if (mob.offset.y < 0) mob.offset.y = min (0, mob.offset.y + speed)
 
 local slide_done = mob.offset.x == 0 and mob.offset.y == 0

 if (slide_done == false) return 
 if (#mob.movement_queue == 0) return
 
 local from_to = mob.movement_queue[1]
 local from = from_to[1]
 local to = from_to[2]
 mob.pivot_point = to
 mob.offset.x = (from.x - to.x)
 mob.offset.y = (from.y - to.y)
 del(mob.movement_queue, from_to) 
end

-->8
-- map


function generate_level(i)
 game_state.walls = levels[i].walls
	game_state.floor = levels[i].floor
 random_map_diggers()
	place_gems()
end

function show_ending_level()
 game_state.walls = levels[8].walls
	game_state.floor = levels[8].floor
 empty_map()
end

function place_gems() 
 local total_gems = 3
 for i=1,total_gems do
  a_gem(random_empty_tile())
 end
 game_state.gems=total_gems
end


-- map generation

function empty_map()
	for x=0,15 do
  for y=0,15 do         
   if x==0 or x==15 or y==0 or y==15 then   
	   mset(x,y,rnd_item(game_state.walls))
	  else
 	  mset(x,y,game_state.floor)
 	 end
  end
 end
end


function all_map_wall()
		for x=0,15 do
    for y=0,15 do         
      mset(x,y,rnd_item(game_state.walls))
    end
  end
end


function random_map()
 for x=0,15 do
  for y=0,15 do
 	 if rnd() < 0.3 or in_bounds(point(x,y))==false then
	   mset(x,y,rnd_item(game_state.walls))
 	 else
    mset(x,y,game_state.floor)
	  end
  end
 end
end


function random_map_diggers()
  all_map_wall()
  local diggers = {
    point(7,7),
    point(7,7)
  }

  local area = 16*16
  local covered = 0
  while covered < area*0.4 do
    for j=1,#diggers do
      local dig=diggers[j]
					 if is_solid(dig) then
						  covered += 1
						end
      mset(dig.x, dig.y, game_state.floor)
		    local nn = neighbours(dig)      
		    diggers[j] = nn[1]
						for n in all(nn) do
						  if is_solid(n) then
						    diggers[j] = n
						    break
						  end		    
						end
    end
  end
end


-- map and tile tools


function neighbours(pos)
  local result = {}
  local delta = {
    point(0,-1), point(0,1),
    point(-1,0), point(1,0)
  }
  for d in all(delta) do
    local p = point(
    	 pos.x + d.x,
    	 pos.y + d.y
    )
    if in_bounds(p) then
      add(result,p)
    end
  end
  return shuffle(result)
end

function neighbours8(pos)
  local result = {}
  local delta = {
    point(-1,-1), point(1,1),
    point(1,-1), point(-1,1),
    point(0,-1), point(0,1),
    point(-1,0), point(1,0)
  }
  for d in all(delta) do
    local p = point(
    	 pos.x + d.x,
    	 pos.y + d.y
    )
    if in_bounds(p) then
      add(result,p)
    end
  end
  return shuffle(result)
end


function random_tile()
  local x = flr(rnd(15))
	 local	y = flr(rnd(15))
  return point(x,y)
end


function random_empty_tile()
		local p = random_tile()		
  while is_empty(p) == false do
  	 p = random_tile()
  end
  return p
end

function random_empty_tile_away_from_player()
		local p = random_tile()		
  while is_empty(p) == false and dist(p,p.tile) < 5 do
  	 p = random_tile()
  end
  return p
end


function in_bounds(tile)
  return tile.x > 0 and tile.x < 15 and tile.y > 0 and tile.y < 15
end


function is_empty(tile)
  return is_walkable(tile) and get_actor_at(tile)==nil
end


function is_walkable(tile)
	 return fget(mget(tile.x, tile.y), f_solid) == false
end


function get_actor_at(tile)	 		
	 for e in all(actors) do
	   if same_pos(e.tile, tile) and is_alive(e) then
	     return e
	   end
	 end
		return nil
end	


function get_item_at(tile)	 		
 for e in all(items) do
  if same_pos(e.tile, tile) and is_alive(e) then
   return e
  end
 end
 return nil
end

function is_exit(tile)
 return fget(mget(tile.x,tile.y),f_exit)
end

function is_solid(tile)
  return fget(mget(tile.x, tile.y), f_solid) 
end	


function same_pos(point_a, point_b)
 return point_a.x == point_b.x and point_a.y == point_b.y
end


function distance_dir(from,to,closest)
  local nn = neighbours(from)
  local best_dir = point(0,0)
  local best_dist = -99
  if closest then
    best_dist = 99
  end
  for n in all(nn) do
    if is_walkable(n) then       
					local v = point(to.x - n.x, to.y - n.y)
					local d = dist(to, n)
					if (closest and d < best_dist) or (closest==false and d > best_dist) then
					  best_dir = point(n.x-from.x, n.y-from.y)
					  best_dist = d
					end
			end	
  end
  return point(sign(best_dir.x), sign(best_dir.y))
end


function dist(p1, p2)
 local v = point(p1.x - p2.x, p1.y - p2.y)
 return abs(v.x) + abs(v.y)
end

-->8
-- actions and turns

function update_speed(actor)
 if actor.speed_countdown > 0 then
  actor.speed_countdown -= 1
 end 
 if actor.speed_countdown == 0 then
  if actor.attack_countdown > 0 then
   actor.attack_countdown -= 1
  end
 end
 return actor.speed_countdown == 0
end


function is_turn(actor)
 return actor.speed_countdown == 0 
end


function end_turn(actor)
 actor.speed_countdown = actor.speed
end


-- brains


function ai_keys(actor)
 local dx=0
 local dy=0
 if (btnp(0)) dx=-1
 if (btnp(1)) dx=1
 if (btnp(2)) dy=-1
 if (btnp(3)) dy=1
 if (dx!=0) dy=0
 if (dy!=0) dx=0
 if btnp(—) then
  dx=0
  dy=0
  quickspin()
 end
 try_move(actor,dx,dy)
 if dx > 0 then
  actor.fliph = true
	end
 if dx < 0 then
  actor.fliph = false
 end
 return (abs(dx)+abs(dy))!=0
end


function ai_random(actor)
 local dx=0
 local dy=0
 local dir = flr(rnd(4))
 if (dir==0) dx=-1
 if (dir==1) dx=1
 if (dir==2) dy=-1
 if (dir==3) dy=1
 try_move(actor,dx,dy)
 actor.fliph = dx>0
 return true
end


function ai_zombie(actor)
 if rnd(100) < 25 then
  ai_random(actor)
  return
 end
 local d = distance_dir(actor.tile,p.tile,true)  
 if (d == nil) return
 try_move(actor,d.x,d.y)
 actor.fliph = d.x>0
	return true
end


function ai_lancer(actor)
 local d = distance_dir(actor.tile,p.tile,true)  
 if (d == nil) return
 local attack_tile = point(
  actor.tile.x + d.x*2, 
  actor.tile.y + d.y*2
 )
 if (try_attack(actor, attack_tile)) return
 try_move(actor,d.x,d.y)
 actor.fliph = d.x>0
	return true
end


function ai_mage(actor)
 local dist = dist(actor.tile, p.tile)
 local d = nil
 if dist < 5 then //too close, retreat
  d = distance_dir(actor.tile,p.tile,false)   
 end
 if dist > 6 then //too far, close in
  d = distance_dir(actor.tile,p.tile,true)   
 end
 if (d != nil) then
  try_move(actor,d.x,d.y)
  actor.fliph = d.x>0
 else 
  if #deadpools > 0 then
   shuffle(deadpools)
   if is_empty(deadpools[1].tile) then
	   invoke(actor,deadpools[1].tile,a_skeleton)
	   del(deadpools,deadpools[1])
	   stun(actor,3)
	  end
  end
 end 
	return true
end


function invoke(actor,tile,mob)
 local m = mob()
 m.tile = tile
 m.pivot_point = tile_to_point(tile)
 fx(spr_magic,screen_pos(actor),tile_to_point(tile),10)
end


function ai_bomber(actor)
 local dist = dist(actor.tile, p.tile)
 local d = nil
 if dist < 3 then //too close, retreat
  d = distance_dir(actor.tile,p.tile,false)   
 end
 if dist > 5 then //too far, close in
  d = distance_dir(actor.tile,p.tile,true)   
 end
 if (d != nil) then
  try_move(actor,d.x,d.y)
  actor.fliph = d.x>0
 else 
  throw_bomb(actor.tile,p.tile)
  stun(actor,2)
 end 
	return true
end


function ai_bomb(actor)
 shakecamera(0.25)
 del(monsters, actor)
 del(actors, actor) 
 local nn = neighbours(actor.tile)  
 add(nn,actor.tile)
 sfx(fx_bomb)
	for n in all(nn) do
	 local other = get_actor_at(n)	 
 	if (other != nil and other != actor) then 	 printh("fu")
  	hit(other, 1)
 	end
 	if is_walkable(n) then
 		a_explosion(n)
 	end	 
 end
 a_explosion(actor.tile) 
 return true
end


function throw_bomb(from,to)
 local nn = neighbours(to)
 for n in all(nn) do
  if is_empty(n) then
   local bomb = a_bomb(from)
   move(bomb,n)
   return
  end
 end
end


function ai_explosion(actor)
 del(monsters, actor)
 del(actors, actor) 
 return true
end


function ai_scared(actor)
 if rnd(100) < 25 then
  ai_random(actor)
 return
 end
 local d = distance_dir(actor.tile,p.tile,false)  
 if (d == nil) return
 try_move(actor,d.x,d.y)
 return true  
end


--- utils


function try_move(actor, dx, dy)
 local new_tile = point(actor.tile.x + dx, actor.tile.y + dy)
 if is_walkable(new_tile) == false then
  bump(actor, new_tile)  
  if (actor.is_player) sfx(fx_bump)   
 else
	 if get_actor_at(new_tile)==nil then
	  move(actor, new_tile)  
	 else
	  try_attack(actor, new_tile)
	 end
 end
end


function try_attack(actor,tile)
 local other = get_actor_at(tile) 
 if other != nil and actor.is_monster != other.is_monster then
	 if actor.attack_countdown <= 0 then
	  actor.attack_countdown = actor.attack_speed
   hit(other, 1)
   bump(actor, other.tile)
   return true
  end
 end
 return false
end


function screen_pos(mob)
 local pivot = mob.pivot_point
 if (is_dead(mob)) pivot = mob.tile
	local x = mob.pivot_point.x + mob.offset.x 
	local y = mob.pivot_point.y + mob.offset.y
	return point(x,y)
end



function move(actor, new_tile)
 add(actor.movement_queue, {tile_to_point(actor.tile), tile_to_point(new_tile)})
 actor.tile = new_tile
 step_on(new_tile, actor)
 if (actor.is_player) sfx(fx_walk)
end


function step_on(tile, actor)
 if actor.is_monster == false then
  local item = get_item_at(tile)
  if (item != nil) then
	 	game_state.score += 1
	 	game_state.gems -= 1
			del(items,item)
	 	spawn_monster()
	 	sfx(fx_coin)
	 end
	 if is_exit(tile) then  
	 	end_level()
	 end
 end
end

function bump(actor, tile) 
 local half_way = point(
 	(actor.tile.x*8 + tile.x*8)/2, 
 	(actor.tile.y*8 + tile.y*8)/2
 )

 add(actor.movement_queue, 
  {tile_to_point(actor.tile), 
  half_way}
 )
 add(actor.movement_queue, 
  {half_way, 
  tile_to_point(actor.tile)}
 ) 

 
end


function tile_to_point(tile)
 return point(tile.x*8, tile.y*8)
end


function hit(actor, damage)
 actor.hp -= damage
 shakecamera(0.05)
 stun(actor,1)
 sfx(fx_sword)
 if actor.hp <= 0 then
  die(actor)
  sfx(fx_death)
 end
end


function die(actor)
 if actor.is_monster then
  actor.sprite = spr_blood
 else
  actor.sprite = spr_player_dead
 end
 actor.hp = 0
 if actor.is_monster then
  del(monsters, actor)
  del(actors, actor)
  if (actor.has_blood) add(deadpools, actor)
 else
  game_over()
 end   
end

function game_over() 
 sfx(fx_gameover)
 local highscore = dget(0)
 if highscore < game_state.score then	 
	 dset(0, game_state.score)
 end
 gameover_init()
 skipframe = 20
end


function is_dead(actor)
 return actor.hp == 0
end


function is_alive(actor)
 return actor.hp != 0
end


function stun(actor,turns)
 if (actor.is_monster==false) return
 if (actor.can_be_stunned==false) return 
 actor.stunned=turns
 actor.been_stunned=true
end
-->8
-- actors add levels

function actor(sprite, hp, speed, attack_speed, tile, is_monster)
 local a = {
  sprite = sprite,
  maxhp = hp,
  hp = hp,
  speed = speed,
  is_monster = is_monster,
  is_player=(is_monster==false),
  stunned = 0,    
  attack_speed = attack_speed,
  has_blood = true,
  can_be_stunned = true,

		tile = tile,
		offset = point(0,0),
		fliph = false,							
				
		speed_countdown = speed,
		attack_countdown = attack_speed,				
				
		movement_queue = {},
		pivot_point = tile_to_point(tile),				
 }
 add(actors,a)
 if (is_monster) add(monsters,a)
 return a
end


function a_player()
 local a = actor(
  spr_player,
  3,
  2,
  1,
  random_empty_tile(),	   
  false
 )
 a.brain = ai_keys
	return a
end


function a_slime()
 local a = actor(
  spr_slime,
  2,
  2,
  1,
  random_empty_tile(),
  true
 )
 a.brain = ai_zombie
 return a
end


function a_goblin()
 local a = actor(
  spr_goblin,
  1,
  1,
  2,
  random_empty_tile(),
  true
 )	 
 a.brain = ai_zombie
 return a
end


function a_fat_goblin()
 local a = actor(
  spr_fatgoblin,
  3,
  4,
  1,
  random_empty_tile(),
  true
 )	 
 a.brain = ai_zombie
 a.can_be_stunned = false
 return a
end


function a_lancer()
 local a = actor(
  spr_lancer,
	 2,
	 2,
	 1,
  random_empty_tile(),
  true
 )	 
 a.brain = ai_lancer
 return a
end


function a_fly()
 local a = actor(
  spr_fly,
  1,
  2,
  1,
  random_empty_tile(),
  true
 )	 
 a.brain = ai_random
 return a
end


function a_bomber()
 local a = actor(
  spr_bomber,
  1,
  2,
  1,
  random_empty_tile(),
  true
 )	 
	a.brain = ai_bomber
	return a
end


function a_bomb(tile)
 local a = actor(
  spr_bomb,
  -1,
  2,
  2,
  tile,
  true
 )	
 a.has_blood = false
 a.brain = ai_bomb
 return a
end


function a_explosion(tile)
 local a = actor(
  spr_explosion,
  0,
  1,
  1,
  tile,
  true
 )	 
 a.brain = ai_explosion
 return a
end


function a_mage()
 local a = actor(
  spr_mage,
  1,
  2,
  1,
  random_empty_tile(),
  true
 )
 a.brain = ai_mage
 return a
end


function a_skeleton()
 local a = actor(
  spr_skeleton,
  1,
  4,
  1,	   
  random_empty_tile(),
  true
 )
 a.has_blood = false
 a.brain = ai_zombie
 return a
end


function a_gem(tile)
 local a = {
 	sprite = spr_gem,
  tile = tile,
  pivot_point = tile_to_point(tile),
  offset = point(0,0)
 }
 add(items, a)
 return a
end


function an_innocent()
 local a = actor(
  spr_ending[flr(1+rnd(#spr_ending))],
  1,
  4,
  1,	   
  random_empty_tile(),
  true
 )
 a.brain = ai_scared
 if a.sprite==29 then
  a.brain=nil
 end
	 
 return a
end


function setup_levels() 
 local levels = {
	 {
	  title="the forest",
	  walls={spr_wall_1},
	  floor=spr_floor_1
  },
  {
	  title="approaching the lair",
	  walls={spr_wall_1, spr_wall_2},
	  floor=spr_floor_2
  },
  {
	  title="old town ruins",
	  walls={spr_wall_2,spr_wall_3},
	  floor=spr_floor_3
  }, 
  {
	  title="the dungeon",
	  walls={spr_wall_3},
	  floor=spr_floor_4
  },
  {
	  title="cave entrance",
	  walls={spr_wall_3, spr_wall_4, spr_wall_5},
	  floor=spr_floor_5
  },
  {
	  title="the caves",
	  walls={spr_wall_4, spr_wall_5},
	  floor=spr_floor_5
  },
  {
	  title="deeper levels",
	  walls={spr_wall_5, spr_wall_6},
	  floor=spr_floor_6
  },
  {
	  title="goblin's lair",
	  walls={spr_wall_6},
	  floor=spr_floor_7
	 },
	 {
	  title="goblins' precious treasures",
	  walls={spr_wall_6},
	  floor=spr_floor_7
	 }
 }

	return levels;
end
-->8
-- util


function point(x, y)
 return {x=x, y=y}
end


function fx(sprite,from,to,frames)
 if (to==nil) to=from
 local fx = {
 	sprite=sprite,
 	frames=frames,
 	from=from,
 	to=to,
 	elapsed=0,
 	position=from,
 	update=function(self) 
 	 self.elapsed+=1
 	 if self.elapsed==self.frames then
 	  del(fxs,self)
 	 end
 	 local t = self.elapsed/self.frames
 	 self.position.x = self.from.x*(1-t) + self.to.x*t
 	 self.position.y = self.from.y*(1-t) + self.to.y*t
 	end
 }
 add(fxs,fx)
end


function magnitude(vector)
 return sqrt(vector.x*vector.x + vector.y*vector.y)
end



function shuffle(t)
  for n=1,#t*2 do -- #t*2 times seems enough
    local a,b=flr(1+rnd(#t)),flr(1+rnd(#t))
    t[a],t[b]=t[b],t[a]
  end
  return t
end


function rnd_item(t)
 return t[flr(rnd(#t)+1)]
end


function sign(x)
  if (x > 0) return 1
  if (x < 0) return -1
  return 0
end

_camerashake = 0 

function shakecamera(str)
 _camerashake += str
end

function doshake()
 -- this function does the
 -- shaking
 -- first we generate two
 -- random numbers between
 -- -16 and +16
 local shakex=8-rnd(16)
 local shakey=8-rnd(16)

 -- then we apply the shake
 -- strength
 shakex*=_camerashake
 shakey*=_camerashake
 
 -- then we move the camera
 -- this means that everything
 -- you draw on the screen
 -- afterwards will be shifted
 -- by that many pixels
 camera(shakex,shakey)
 
 -- finally, fade out the shake
 -- reset to 0 when very low
 _camerashake = _camerashake*0.9
 if _camerashake<0.025 then
  camera(0,0)
  camerashake=0
 end
end

function zspr(n,w,h,dx,dy,dz)
 sx = 8 * (n % 16)
 sy = 8 * flr(n / 16)
 sw = 8 * w
 sh = 8 * h
 dw = sw * dz
 dh = sh * dz
 sspr(sx,sy,sw,sh, dx,dy,dw,dh)
end


function vignette(fadein,x,y,t)
 _vignette = {
  x=x,
  y=y,
  t=t,
  elapsed=0,
  fadein=fadein,
  last_update=_update,
  last_draw=_draw  
 } 
 _update=vignete_update
 _draw=vignete_draw
end

function vignete_update()
 _vignette.elapsed+=1
 if _vignette.elapsed==_vignette.t then
  _update=_vignette.last_update
  _draw=_vignette.last_draw
 end
end

function vignete_draw()
 print("")
end

 	

function wait(a) for i = 1,a do flip() end end

 
-->8
-- skills
skill_cd={}

function cooldown_skills()
 for i=#skill_cd,1,-1 do  
  local s=skill_cd[i]
  s.heat-=1
  if (s.heat==0) then
   sfx(fx_zap_ready)
   del(skill_cd,s)
  end
 end
end

function skill_available(id)
 for s in all(skill_cd) do
  if (s.id==id) return false
 end
 return true
end


function quickspin() 
 if (skill_available("quickspin")==false) return
 local nn=neighbours8(p.tile)
 for n in all(nn) do
  fx(spr_quickspin,screen_pos(p),tile_to_point(n),5)
	 local other = get_actor_at(n) 
	 if other != nil then
   hit(other, 1)   
  end
 end 
 sfx(fx_zap)
 add(skill_cd, {id="quickspin",heat=10})
end

-->8
-- constants

-- sprites
spr_wall_1 = 33
spr_wall_2 = 34
spr_wall_3 = 35
spr_wall_4 = 36
spr_wall_5 = 37
spr_wall_6 = 38

spr_floor_1 = 49
spr_floor_2 = 50
spr_floor_3 = 51
spr_floor_4 = 52
spr_floor_5 = 53
spr_floor_6 = 54
spr_floor_7 = 55

spr_stairs = 58

spr_life = 16
spr_heart = 17
spr_blood = 32
spr_player_dead = 48
spr_bomb = 59
spr_explosion = 60
spr_magic = 61
spr_stunned = 62
spr_gem = 63
spr_quickspin = 57

-- flags
f_solid = 0
f_wall = 1
f_gem = 2
f_exit = 3

-- creatures
spr_player = 1

spr_slime = 2
spr_goblin = 3
spr_fatgoblin = 4
spr_lancer = 5
spr_fly = 6
spr_bomber = 7
spr_mage = 8
spr_skeleton = 9

spr_ending = {29,30,30,30,31,45,46,47}

--fx
fx_walk=0
fx_bump=1
fx_sword=2
fx_death=3
fx_stairs=4
fx_coin=5
fx_stairs_appear=6
fx_bomb=7
fx_gameover=8
fx_startgame=9
fx_zap=10
fx_zap_ready=11
__gfx__
00000000044444c00000000000000000003330000000006000dd0000440000000002209000666600000000000000000000000000000000000000000070707070
00000000444444c4000000000033300000a3a0000033306000dd0000004033300022224000a6a6000000000000000000000000000000000000000000a0f0c0a0
007007004fff44c40000000000a3a0000333343000a3a06000d00dd00111a3a000a3a24000666600000000000000000000000000000000000000000090e06090
0007700041ff1fc4003330000033343033444433003330500333ddd01d111330003332400060600000000000000000000000000000000000000000008020d040
000770006666ffc4033333000300440333444433000443300a3a0000311114400022224000000000000000000000000000000000000000000000000020101020
007007006cc6d5550a33a33000044400304444030004405003330000111333400022223006066606000000000000000000000000000000000000000010000010
000000006cc6ddf00333333000300300304444030044405000000000011144400019114006000006000000000000000000000000000000000000000000000000
0000000006600d000333333300300300003003000030305000000000000300300022224000060600000000000000000000000000000000000000000007ab3100
000000000ee0ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666000
00000000e88e88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006366600
00000000e88888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033300006a36600
002220008888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333000a3a00006333600
002820000888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a3a00033300006232600
00222000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033300044400002222200
00000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044400344430003222300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000343400030300000222000
0000200000bbbb000005501166dddd0709444409044442044200009400000000000000000c0000c0000000000000000000000000000000000044400000004440
002282000bbbbbb006001000ddddd5064444420400022000200990020000000000000000c7c0c000000000000000000000000000003330000434440000043444
028222200bbbbbb065500066dddd510d44402204990000940094440000000000000000000c7c7c0000000000000000000000000000a3a00004a344000004a344
002882820bbb3bb05510505500000000000000004444094409444420000000000000000000c7c000000000000000000000000000006660000433340000333334
0288882003b34b3011000000dd0766dd04099944044200000944442000000000000000000c7c7c00000000000000000000000000006664000423240000a3a324
282822000034430000060660d506dddd420944440220004400444200000000000000000000c0c7c0000000000000000000000000033644000222220000333220
02020820b004400050650555510ddddd2204404400009002900420090000000000000000c0000c00000000000000000000000000040444000322230000432220
00000200303342301000005500000000000000000999440044000094000000000000000000000000000000000000000000000000040303000022200000444220
0000000000000000000000000000000000000000000000000000000000000000000000000c0000c0555555550000007000008008000000020000000000000000
000000004000000000000500000010000000000000040000000000000000000000000000c7c0c0000000000000004a0008909080202008000a00a00000011000
0000000000004040030000000000000000000100000000000040000000000200000000000c7c7c005500000000040007008a7a9008000000aaa0000a00177100
04444000000002000000000005000000000000000000001000000020000000000000000000c7c0005505500000111000800777a8202000000a000a00019aa710
4444440000000000000000300000000000000000000000000000000000000000000000000c7c7c005505505001611100009a7a00000008000000a0a0019aa710
4ff44450004000000000000000010050000000000200000002000000000000000000000000c0c7c055055050011111000089a89000808a800a000a00019aa710
466844550020004000050000000000000100000000000000000004000200000000000000c0000c0055055050011111000800000800000800000a000000199100
6688ff8d000000000000000000000000000000000000000000000000000000000000000000000000550550500011100000008000800000020000000000011000
00000000000011111000000111100000000011111110000011000000001100000000000000110000001111100011000000000000000000000000000000000000
00000000001133333100001333311000001133333331000133100000013310000110000001331000113333310133100000000000000000000000000000000000
00000000013333333100013333333100013333333333100133100000013310001331000001331001333333331133100000000000000000000000000000000000
00000000133311131000133311133310133331111133100133100000013310001333100001331013331111331333100000000000000000000000000000000000
00000001333100010001331100013310013310000133101333100a0a013310001333100001310133110000111331000000000000000000000000000000000000
00000013311000000013331000013310013310001331001333100000013310001333310013310133100000001331000000000000000000000000000000000000
00000133310000011013310000013310013311113310001331000000133100013313310013310133311100001331000000000000000000000000000000000000
00000133100000133113310000013310013313333331001331000000133100013313331013310013333311001331000000000000000000000000000000000000
00001331000000133133100000133100013313311333101331000000133100013311333113310001133333100110000000000000000000000000000000000000
00001331000001331133100000133100133101100133101331000000133100013100133113100000011133310000000000000000000000000000000000000000
00001331000113331133100001331000133100000133101331011111133100133100133313100000000013310000000000000000000000000000000000000000
00001331111333331133100013331000133100011331013331133333133100133100013333100110001133310000000000000000000000000000000000000000
00001333333331310133311133310000133111133331013333333333133100133100001333101331113333100000000000000000000000000000000000000000
00000113333111310013333333100000133333333110013331111111133100133100000133101333333311000000000000000000000000000000000000000000
00000001111013310001333311000000011333311000001110000000011000011000000011001333331100000000000000000000000000000000000000000000
00000000000013310000111100000000000111100000000000000000000000000000000000000111110000000000000000000000000000000000000000000000
00000000000001100000000000000000777770000777770000777000000777777777000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000007799999a00799999a00799a000007999999999a00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000079999999a079999999a0799a0000079999999999a0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007999aaa99a7999aaa999a799a000000799aaaaa999a000000000000000000000000000000000000000000000000000000000
0000000000000000000000000007999a000aa7999a000a99a799a000000799a0000a99a000000000000000000000000000000000000000000000000000000000
000000000000000000000000007999a000000799a0000799a799a00000079a00000799a000000000000000000000000000000000000000000000000000000000
00000000000000000000000000799a0000077799a0000799a79a000000799a00000799a000000000000000000000000000000000000000000000000000000000
00000000a0a00000000000000799a0000079999a0a00799a0a9a000000799a0000799a0000000a0a000011000000000000000000000000000000000000000000
0000000000000000000000000799a0007799a99a0000799aa99a000000799a077799a00000000000000111100000000000000000000000000000000000000000
0000000000000000000a0a000799a7779999a99a000799a0a99aa77770a99aa9999aa0a000000000000a1a110000000000000000000000000000000000000000
00000000000000000000000007999999999aa999aa7999a0a99a99999aa999999aa0000000000000000111100000000000000000000000000000000000000000
00000000000000000000000001a99999aa9a0a999999aa00a99999999aa99aaaa000000000000000001111100000000000000000000000000000000000000000
000000000000000000000000111aaaaaa99a00a9999a0000a99aaaaaa00aa0000000000000000000001111111000000000000000000000000000000000000000
00000000000000000000000011111111a99a000aaaa000000aa00000000000000000000000000000001111111100000000000000000000000000000000000000
00000000000000000000000001111111a99a00000000000000000000000000000000000000000000011111111100000000000000000000000000000000000000
0000000000000000000000000011111a99a000000000000000000000000000000000000000000000011111111000000000000000000000000000000000000000
0000000000000000000000000011111a99a000000000000a00a00000000000000000000000000000011111111000000000000000000000000000000000000000
00000000000000000000000000111111aa0000000000000000000000000000000000000000000000010111111000000000000000000000000000000000000000
00000000000000000000000000010110000000000000000000000000000000000000000000000000010111111000000000000000000000000000000000000000
0000000000000000000000000000010000000000000000000000000000000000000a00a000000000010100001000000000000000000000000000000000000000
0000000000a000a00000000000000000000000000000000111111000000000000000000000000000000110100000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000111111110000000000000000000000000000000000000a00a000000000000000000000000000000000
00000000000000000000000000000000000000000000111111111111100000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000011aa11aa111000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a000a000000001aa11aa110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001111111110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001111111110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000111000000000000000000000000011111111111000000000000000000000111110000000000000000000000000000000000000000000000
00000000000000011111100000000000000000000011111111111111111000000000000000001111111000000000000000000000000000000000000000000000
00000000000000111111110000000000000000000111111111111111111110000000000000011111111111000000000000000000000000000000000000000000
0000000000001111aa11a1000000000000000000011111111111111111111000000000000001aa11aa1110000000000000000000000000000000000000000000
0000000000000111aa11a1000000000000000000111111111111111111111110000000000001aa11aa1100000000000000000000000000000000000000000000
00000000000000111111110000000000000000011111111111111111111111100000000000011111111100000000000000000000000000000000000000000000
00000000000000011111100000000000000000011100111111111011100111100000000000001111111100000000000000000000000000000000000000000000
00000000000000111111111100000000000000011000111111101111100001100000000000011111111110000000000000000000000000000000000000000000
00000000000011111111111110000000000000011100011010111110001111100000000000111111111111111000000000000000000000000000000000000000
00000000001111111111111111000000000000011100010100100011100111000000000011111111111111111100000000000000000000000000000000000000
00000000011111111111111111000000000000001000010000000001001100000000000011111111111111111100000000000000000000000000000000000000
00000000011111111111111111000000000000000000000000000000100000000000000011111111111111111110000000000000000000000000000000000000
00000000011011111111111111000000000000000000000099999900000000000000000111111111111111111111000000000000000000000000000000000000
00000000010011111111111111100000000000000000000944444490000000000000000110111111111111001111000000000000000000000000000000000000
00000000011111111101111100010000000000000000099444444000000090000000000001111111111111000011000000000000000000000000000000000000
00000000011111111110100110100000000000000099944444440000000940000000000111101111111110001111000000000000000000000000000000000000
00000000000110110111101000000000000000000944444444499999944400000000000001001111110110001110000000000000000000000000000000000000
00000000000001100101011010000000000000000944444444944444444400000000000000011111111110000110000000000000000000000000000000000000
00000000000000111110100000100000000000009444444444444444444400000000999000001110111100000000000000000000000000000000000000000000
00000000000010001101000000000000000000094444444444444444990000000999440000001100101011000000000000000000000000000000000000000000
00000000000000010010101100000000000000094444444444444444449999999444440000010110110000000000000000000000000000000000000000000000
00000000000000001110000000000000000000094444444444444444444444444444400000000110100100000000000000000000000000000000000000000000
00000000000000000011000000000000000000094444449444449444444444444444400000000001100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000094444444944444444444444444444000000000010100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000944444444494444994444444444444999999990000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000444444444449444444444444449999444444000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000444444444444444444444444444444444440000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000044444444444444444444444444444224200000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007777644444444444444444444444424444440000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000776666644444244444444444444442444000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000007766666dd11444442444444444444499000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000077666666d5555114244444444424442444449000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000076666666665555551444244144442444444244990000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000076666666661555555114442114444222424444000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007666666ddd155555551124151144444444000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000766666ddddd15555555512415511111000000066000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000006666d1dddd15555555551441551111dd0000655000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000007666dddd116555555555511555011ddddf00550000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000007666d11666555555555555550000ddddfff550000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000076666666655555555555555d00000ddff5567000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006666666dd115555555551ddd000000055666770000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066666dddddd111111ddddddd00000055066667700000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000006666dddddddddddddddddddd00000555000666670000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000066ddddddd0000000011ddddd0000550000066667700000000000000000000000000000000000000000000000000000
000000000000000000000000000000000006ddddd1100000000001dddd0000000000000666670000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000ddddd10000000000001dddd0000000000000006667700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000dddd1000000000000001dddd000000000000000666677000000000000000000000000000000000000000000000000
00000000000000000000000000000000000ddd100000000000000001dd5000000000000000006666700000000000000000000000000000000000000000000000
00000000000000000000000000000000000ddd000000000000000000555000000000000000000666677000000000000000000000000000000000000000000000
00000000000000000000000000000000000065000000000000000000055600000000000000000006666700000000000000000000000000000000000000000000
00000000000000000000000000000000000005000000000000000000005560000000000000000000066600000000000000000000000000000000000000000000
00000000000000000000000000000000000005000000000000000000000550000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000550000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000003000000000000000303030303030000030000000000000000000000000000000308000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001561014620126200f6100c60006600006002150020500205001f5001e5001e5001d5001b5001a5001950018500165001450012500105000e5000d5000b50009500085000650003500005000850007500
000200000c6400c6400c6300c6200c6100c6000c6000c6000c6000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0002000006610076100a6200c62011630166401a66000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500000656008560095600756004560035400352000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0004000014633146331e6031e60311603116031463314633006030060300603006030d6230d623006030060300603006030060305613056130060300603006030060300603006030060300603006030060300603
000200002605026030260202602026020260203202032040320503205032050320503204032040320303202032020320103c0003c0003c0000000000000000000000000000000000000000000000000000000000
010a000013550005000e5500050013520005001f55000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000176701766017660176601765016650156501465012650106500d640096400663005630046200362002610016100161001610076000760007600076000760007600076000760007600076000760007600
010c0000175401150010500135001154013504135001050010542105421054210542105421350013500105000e5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c50000500
00080000101400c100331001014010100101403310217142171421714217142171421714217142171421714200102001020010200102001020010200102001020010200102001020010200102001020010200102
000200002b1603016033160301502d130291202a120311303414034160311702d17028170271702f1603215034140321302b130231201e1100010000100001000010000100001000010000100001000010000100
000200001e2501e2501e2501120028250282502825032200312503125031250002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
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
02 07 08 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
