pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- by jonbro
-- v 0.5

-- changelog
-- 0.5
-- fixed long standing "out of memory" bug
-- tweaked quest bonus
-- added highscore saving
-- 0.4
-- quest where you have to bring at least 2 of one item to the exit
-- enemy that wanders until it sees you, at which point it paths towards where it last saw you
-- 0.3
-- fogs now effect the enemies that they are throw at
-- better memory management (maybe)
-- in game sound effects

-- todo:
-- item that pushes enemies back on diagonals (or shoots on diagonals)
-- step (allows you to move without an enemy turn, and step into walls and on enemies)
-- enemy that can drop a bomb and run away
-- enemy that warps other enemies
-- animations for bow, throw, attack, helmet hit

-- not todo:
-- xp stuff

best_score = 0
last_score = 0
if cartdata("jonbro_delia_mute") then
	best_score = dget(0)
end
function set_final_score(final)
	last_score = final
	if best_score < final then
		best_score = final
		dset(0, best_score)
	end
end

drawmap = map
sizex = 14
sizey = 8
max_actors = 128
debug = false

-------------------
-- state machine --
-------------------

function _init()
	score = 0
	music(0)
	_init_quest()
	current_update = _title_update
	current_draw = _title_draw
end
function _init_quest()
	actor = {}
	particle = {}
	player = make_player(0,flr(rnd(sizey)))
	current_quest = quests[flr(rnd(count(quests)))+1]
	current_quest:init()
	last_quest_failed = false
	current_level = 1
	build_next_level()
end
function build_next_level()
	if current_quest.max_level < current_level or current_quest:complete() then
		if not current_quest:complete() then
			last_quest_failed = true
		end
		_quest_complete_init()
		return
	end
	local valid_map = make_map()
	while  valid_map ~= true do
		valid_map = make_map()
	end
	if(current_quest.after_level_get) current_quest:after_level_get();
end
function _update()
	current_update()
end

function _title_update()
	if btnp(4) then
		_init_quest()
		_init_game()
	end
end
function _title_draw()
	cls()
	if last_score > 0 then
		print("last score: " .. last_score, 0, 16)
	end
	if best_score > 0 then
		print("high score: " .. best_score, 0, 24)
	end
	camera(-8,16)
	local d = function(cy,sy) drawmap(10,cy, 0,sy+56, 6,2) end
	d(0,0)
	d(2,16)
	d(4,40)
	d(6,56)
	color(7)
	print("in", 0,34+56)
	if(flr(counter/20)%2 == 0) print("press z to start", 56,122);
end
function _init_game()
	current_update = _game_update
	current_draw = _game_draw
	music(-1)
end
function _game_update()
	foreach(actor, update_actor)
end
function setup_scene_data()
	scene_data = {rect_height=0,text_x=128,time=0,update=function(data)
		data.time+=1
		if(data.rect_height < 128)then
			data.rect_height+=flr(data.time/4);
		end
		if data.rect_height > 20 and data.text_x ~= 0 then
			data.text_x = max(0, data.text_x-flr(data.time/4));
			if data.text_x == 0 and data.after_slide then data:after_slide() end
		end
	end}
end
function _game_over_init()
	bg_draw = current_draw
	current_quest = nil
	current_update = _game_over_update
	current_draw = _game_over_draw
	setup_scene_data()
	sfx(12, 0)
	sfx(13,1)
	set_final_score(score)
	scene_data.after_slide = function(data)
		scene_data.update = function()
			if btnp(4) then
				_init()
			end
		end
		data.display_score = function()
			print("final score: "..score,0,80,7)
			if(flr(counter/20)%2 == 0) print("press z to continue", 0,122);
		end
	end
end
function _game_over_update()
	scene_data:update()
end
function _game_over_draw()
	bg_draw()
	camera(0,0)
	rectfill(0,64-scene_data.rect_height/2,128,64+scene_data.rect_height/2,0)
	drawmap(0,6, scene_data.text_x,56, 10,2)
	if scene_data.display_score then scene_data:display_score() end
end
function _quest_complete_init()
	bg_draw = current_draw
	current_update = _quest_complete_update
	current_draw = _quest_complete_draw
	setup_scene_data()
	scene_data.after_slide = function(data)
		local display_score = score
		local bonus_multiplier = current_quest.bonus_multiplier 
		if last_quest_failed then
			bonus_multiplier = 1
			sfx(16,0)
			sfx(17,1)
		else
			sfx(16,0)
			sfx(15,1)
		end
		score = display_score + (current_level-1)*bonus_multiplier
		scene_data.update = function()
			if display_score < score then
				if counter%5 == 0 then
					display_score+=1
				end
			elseif btnp(4) then
				_init_quest()
				_init_game()
			end
		end
		data.display_score = function()
			print("current score: "..display_score,0,80,7)
			print("quest bonus: x"..bonus_multiplier,0,86,7)
			print("dungeon score: "..(current_level-1),0,92,7)
			if display_score == score then
				if(flr(counter/20)%2 == 0) print("press z to continue", 0,122);
			end
		end
	end
end
function _quest_complete_update()
	scene_data:update()
end
function _quest_complete_draw()
	bg_draw()
	camera(0,0)
	rectfill(0,64-scene_data.rect_height/2,128,64+scene_data.rect_height/2,0)
	drawmap(0,0, scene_data.text_x,56, 10,2)
	if not last_quest_failed then
		drawmap(0,2, scene_data.text_x+44,56, 10,2)
	else
		drawmap(0,4, scene_data.text_x+44,56, 10,2)
	end
	if scene_data.display_score then scene_data:display_score() end
end

counter = 0
function _draw()
	counter+=1
	current_draw()
	draw_console()

	-- for capturing the cart image
	-- _draw_cart_img()
	-- color(15)
	-- print(stat(0), 0,8)
end
function _draw_cart_img()
	camera(0,0)
	palt(0,false)
	rectfill(0,88,128,200,0)
	camera(9,0)
	drawmap(10,0, 20,90, 6,2)
	drawmap(10,2, 20,108, 6,2)
	drawmap(10,4, 86,90, 6,2)
	drawmap(10,6, 78,108, 6,2)
	print("in", 66,104,7)
end
function _game_draw()
	cls()
	camera(0,0)
	if current_quest ~= nil then
		print("level "..current_level .."/"..current_quest.max_level.."   score:"..score, 0,1,7)
	end
	camera(0,-8)
	for x=0,sizex-1 do
		for y=0,sizey-1 do
			if map[x][y] == 2 then
				spr(66, x*8,y*8)
			end
		end
	end
	local map_draw_order = {item_map, enemy_map,fog_map}
	-- loop through the map and draw the correct floor sprites
	palt(0,false)
	-- render the outer walls
	camera(-8,-16)
	for y=0,sizey-1 do
		for x=-1,sizex do
			spr(66, x*8,8*sizey)
			spr(66, x*8,-8)
		end
		spr(66, -8,y*8)
		spr(66, sizex*8,y*8)
	end
	-- render the level floor / walls
	for y=0,sizey-1 do
		for x=0,sizex-1 do
			-- print(map[x][y])
			spr(map[x][y]+64, x*8,y*8)
		end
	end
	-- render the various maps
	palt()
	for y=0,sizey-1 do
		for x=0,sizex-1 do
			-- print(map[x][y])
			camera(-8,-8)
			foreach(map_draw_order, function(m)
				if(m[x][y] ~= 0 and m[x][y].draw~=nil) m[x][y]:draw();
			end)
			foreach(fog_map[x][y],function(f) f:draw() end)
			if(player.x == x and player.y==y) player:draw()
		end
	end
	-- draw the player
	-- foreach(actor, draw_actor)
	for i=1,player.max_health do
		local f = function(ndx) spr(ndx, 85+i*9,-8) end
		if player.health < i then
			f(131)
		else
			f(147)
		end
	end
	-- draw the particle systems
	foreach(particle, function(v) v.draw(v) end)
	-- draw the current quest
	if (current_quest) display_quest()
end

-------------
-- console --
-------------

local console_data = {
	current_line = 0,
	line_buffer = {"","","","","","","","","",""}
}

function draw_console()
	if not debug then
		return
	end
	for i=1,10 do
		local to_print = console_data.current_line-10-(i-10)
		while to_print < 1 do to_print+=10 end
		print(console_data.line_buffer[to_print], 70, (i)*8, 8)
	end
end
function log(txt)
	console_data.line_buffer[console_data.current_line+1] = txt
	console_data.current_line = (console_data.current_line+1)%10
end
-------------
-- utility --
-------------
-- builds a blank map and returns it
function get_map(default)
	local default = default or 0
	local map = {}
	for x=0,sizex-1 do
		map[x] = {}
		for y=0,sizey-1 do
			if default == "table" then
				map[x][y] = {}
			else
				map[x][y] = default
			end
		end
	end
	return map
end
-- left, right, up, down
function get_directions(node)
	return {
		get_node(node.x-1, 	node.y),
		get_node(node.x+1, 	node.y), -- right
		get_node(node.x,node.y-1), -- up
		get_node(node.x, 	node.y+1)}-- down
end
function check_direction(x,y)
	local c = 0
	local out = -1
	foreach(get_directions(get_node(0,0)), function(d)
		if d.x == x and d.y == y then out = c end
		c += 1
	end)
	return out
end
	-- left, right, up, down < pico-8
	-- up, right, down, left < us d:

local item_positions = {
	{0, 64+24},
	{32, 64+24},
	{16, 64+16},
	{16, 64+32},
}

function make_actor(k,x,y)
	local a = {}
	a.kind = k
	a.life = 1
	a.x=x a.y=y
	a.t=0
	a.max_health = 2
	a.health = 2
	a.shake_x = 0
	a.shake_y = 0
	a.hflip = false
	a.standing = false
	a.lost_turn = 0
	a.dx = a.x*8; a.dy = a.y*8
	a.debug = ""
	if (count(actor) < max_actors) then
		add(actor, a)
	end
	return a
end
function update_actor(pl)
	pl.t += 1
	pl.shake_x *= 0.75
	pl.shake_y *= 0.75
	local xshake = 0
	local yshake = 0
	if (pl.shake_x > 0) xshake = flr(rnd(pl.shake_x))*2;
	if (pl.shake_y > 0) yshake = flr(rnd(pl.shake_y))*2;
	pl.dx = ((pl.x*8)-pl.dx)*0.5+pl.dx+xshake
	pl.dy = ((pl.y*8)-pl.dy)*0.5+pl.dy+yshake

	if pl.update then
		pl:update()
	end
end
function draw_actor(pl)
	if pl.draw then
		pl:draw()
	end
end


------------
-- player --
------------
function make_player(x,y)
	local p = make_actor(1,x,y)
	p.update = player_update
	p.health = 3
	p.max_health = 3
	p.draw = function(pl)
		spr(128+(pl.t/10)%2, flr(pl.dx),flr(pl.dy-2),1,2,pl.hflip)
		-- draw the items the player has picked up
		camera(-4,-12)
		local circular = {0,2,1,3}
		for i=0,3 do
			local pos = item_positions[i+1]
			if p.use and flr((counter+circular[i+1]*2)/10)%2 == 0 and pl.items[i] and pl.items[i].data.on_use then
				-- spr(68, pos[1]-3, pos[2]+4,2,2)
			else
				spr(68, pos[1]-3, pos[2]+4,2,2)
			end
			if pl.items[i] ~= nil then
				spr(pl.items[i].data.large_spr, pos[1]-3, pos[2]+4,2,2)
			end
		end
		if not p.use then
			print("z to use", -3,77,5)
		else
			print("z to move", -3,77,5)
		end
	end
	p.remove_item = function(item)
		for i=0,3 do
			if p.items[i] == item
				then p.items[i] = nil
			end
		end
	end
	p.hit = function(enemy)
		log("hit by enemy")
		if player.health <= 0 then
			return
		end
		sfx(0,3)
		-- check to see if the player has an item in the direction of the enemy
		local edir = check_direction(enemy.x-p.x, enemy.y-p.y)
		p.shake_x = -(enemy.x-p.x)*3
		p.shake_y = -(enemy.y-p.y)*3
		local process_basic = true
		if p.items[edir] ~= nil and p.items[edir].data.on_enemy_attack then
			log("enemy hit " .. p.items[edir].data.name)
			process_basic = p.items[edir].data.on_enemy_attack(enemy, p, p.items[edir])
		end
		if process_basic then
			player.health -= 1
			if player.health <= 0 then
				_game_over_init()
				return
			end
		end
	end
	p.items = {}
	return p
end
function player_update(pl)
	if pl.lost_turn > 0 then
		pl.lost_turn -= 1
		-- run the enemy turn
		enemy_turn_runner(pl)
	end
	if pl.use then player_update_use(pl) else player_update_move(pl) end
end
function player_update_use(pl)
	if (btnp(4)) then pl.use = false; return end
	-- todo: should highlight the items that actually have use functions
	for i=0,3 do
		if(btnp(i)) then
			log("pressed dir")
			log(pl.items[i])
		end
		if btnp(i) and pl.items[i] ~= nil and pl.items[i].data.on_use ~= nil then
			log("item on_use:"..pl.items[i].data.name)
			np = get_directions(get_node(0,0))[i+1]
			if pl.items[i].data.on_use(np, pl, pl.items[i]) then
				pl.use = false
				enemy_turn_runner(pl)
				return
			end
		end
	end
end
function player_update_move(pl)
	local np = {x=pl.x, y=pl.y}
	if (btnp(4)) then pl.use = true; return end

	for i=0,3 do
		if btnp(i) then
			np = get_directions(get_node(pl.x, pl.y))[i+1]
		end
	end
	if inmap(np.x, np.y) and
		(np.x ~= pl.x or np.y ~= pl.y) then
		-- check for walls and move the player
		local run_enemy_turn = false
		if enemy_map[np.x][np.y] ~= 0 then
			-- attack the enemy on that cell
			local dir = check_direction(np.x-pl.x, np.y-pl.y)
			if pl.items[dir] ~= nil and pl.items[dir].data.on_player_attack then
				pl.items[dir].data.on_player_attack(enemy_map[np.x][np.y], pl, pl.items[dir])
			elseif enemy_map[np.x][np.y] ~= 0 then
				enemy_hit(enemy_map[np.x][np.y],dir)
			end
			run_enemy_turn = true
		elseif item_map[np.x][np.y] ~= 0 then
			-- determine which direction to add the item to
			local dir = check_direction(np.x-pl.x, np.y-pl.y)
			pl.debug = dir
			if dir >= 0 then
				-- pick up the item
				sfx(8,3)
				local item = item_map[np.x][np.y]
				item_map[np.x][np.y] = 0
				pl.items[dir] = item
				del(actor, item)
				del(level_items, item)
				run_enemy_turn = true
			end
		elseif map[np.x][np.y] == 0 then
			if np.x < pl.x then pl.hflip = true elseif np.x > pl.x then pl.hflip = false end
			pl.x = np.x
			pl.y = np.y
			run_enemy_turn = true
		elseif map[np.x][np.y] == 1 then
			current_level += 1
			pl.x = np.x
			pl.y = np.y
			build_next_level()
		end
		if run_enemy_turn then
			enemy_turn_runner(pl)
		end
	end
end
function player_fog_check(pl)
	foreach(fog_map[pl.x][pl.y], function(f)
		if f.data.on_step then f.data:on_step(pl) end
	end)
end
function enemy_turn_runner(pl)
	player_fog_check(pl)
	foreach(actor, function(a)
		if a.kind == 2 and a.turn ~= nil then
			foreach(fog_map[a.x][a.y], function(f)
				if f.data.on_step then f.data:on_step(a) end
			end)
			if (a.health > 0) a.turn(a);
		end
	end)
	foreach(actor, function(a)
		if (a.kind == 4 or a.kind == 5) and a.turn ~= nil then
			a.turn(a)
		end
	end)
	if (current_quest and current_quest.on_after_turn) current_quest:on_after_turn();
	pl.use = false
end


-----------
-- enemy --
-----------
local enemy_types = {
	{
		name="standard",
		max_health=2,
		sprites={130,146}
	},
	{
		name="more health",
		max_health=3,
		sprites={136,135,134}
	},
	{
		name="path sight",
		max_health=1,
		move=function(e)
			-- check to see if we can see the player
			foreach(get_directions(get_node(0,0)), function(direction)
				local n = get_node(e.x+direction.x, e.y+direction.y)
				while inmap(n.x, n.y) and map[n.x][n.y] == 0 do
					if player.x == n.x and player.y == n.y then
					-- if we can, update the last seen postion
						e.last_seen = get_node(player.x, player.y)
						return
					end
					n = get_node(n.x+direction.x, n.y+direction.y)
				end
			end)
			-- if we have a last seen position, move towards it
			if e.last_seen then
				local els = e.last_seen
				if els.x == e.x and els.y == e.y then
					e.last_seen = nil
				else
					enemy_map[e.x][e.y] = 0
					if els.x < e.x then
						e.x -= 1
					elseif els.x > e.x then
						e.x += 1
					elseif els.y < e.y then
						e.y -= 1
					elseif els.y > e.y then
						e.y += 1
					end
					enemy_map[e.x][e.y] = e
				end
			end
			-- otherwise just hang out
		end,
		draw = function(e)
			if e.last_seen then
				e.s_draw(164)	
			else
				e.s_draw(163)
			end
		end,
		sprites={163}
	}
}
local shield_sprites = {148,132,149,133}
for i=1,4 do
	add(enemy_types, {name="shielded_"..i, max_health=1,hit_dir=(i-1),sprites={shield_sprites[i]},
		on_hit=function(e,dir)
			if dir ~= e.data.hit_dir then
				e.health -= 1
			end
		end})
end
function make_enemy(x,y)
	local e = make_actor(2, x, y)
	enemy_map[x][y] = e
	e.hit = enemy_hit
	e.direction_pref = flr(rnd(4))
	e.data = enemy_types[flr(rnd(count(enemy_types)))+1]
	e.turn = enemy_turn
	e.health = e.data.max_health
	e.max_health = e.data.max_health
	e.on_hit = e.data.on_hit
	e.draw = e.data.draw or enemy_draw
	e.s_draw = function(ndx) spr(ndx, e.dx,(e.dy+8),1,1,e.hflip) end
	return e
end
function enemy_draw(e)
	e.s_draw(e.data.sprites[e.health])	
end
function enemy_turn(e)
	local found_player = false
	if e.lost_turn > 0 then
		e.lost_turn -= 1
		return
	end
	foreach(get_directions(get_node(e.x,e.y)), function(dir)
		if dir.x == player.x and dir.y == player.y then
			player.hit(e)
			found_player = true
		end
	end)
	if found_player ~= true then
		if e.data.move then
			e.data.move(e)
		else
			enemy_move(e)
		end
	end
end
function enemy_move(e)
		-- try to move the enemy towards the player
	e.path = get_pathfinder().find_path(
		get_node(e.x, e.y), get_node(player.x, player.y),
		function(x,y)
			return inmap(x,y) and map[x][y] ~= 2 and enemy_map[x][y] == 0
		end,
		nil,
		e.direction_pref
	)
	if count(e.path) >= 2 then
		enemy_map[e.x][e.y] = 0
		e.x = e.path[2].x
		e.y = e.path[2].y
		enemy_map[e.x][e.y] = e
	end
end
function enemy_hit(e,dir)
	if e == nil then return end
	if dir ~= nil then
		e.shake_y = get_directions(get_node(0,0))[dir+1].y*3
		e.shake_x = get_directions(get_node(0,0))[dir+1].x*3
	end
	sfx(7,3)
	if e.on_hit then
		e:on_hit(dir);
	else
		e.health -= 1
	end
	if e.health == 0 then
		enemy_kill(e,dir)
	end
end
function enemy_kill(e,dir)
	-- spawn a ghost!
	make_ghost(e.x, e.y, e.data.sprites[e.health+1])
	del(actor, e)
	del(level_items, e)
	enemy_map[e.x][e.y] = 0
	if(current_quest and current_quest.on_enemy_kill) current_quest:on_enemy_kill()
end

function make_ghost(x,y,sprite)

	local ghost = make_actor(7,(x+1)*8,(y+2)*8)
	add(particle, ghost);
	local age = 0
	ghost.draw = function()
		camera(0,0)
		local remap_col = ((age/5)%3)+1
		if remap_col == 1 then return end
		local cols = {0,5,6}
		for i=0,15 do
			pal(i, cols[remap_col])
		end
		spr(sprite,ghost.x,ghost.y)
		pal()
	end
	ghost.update = function()
		age += 1
		ghost.y -= 0.5+(age/20)
		if age > 30 then
			del(particle, ghost)
			del(actor, ghost)
		end
	end
end
-----------
-- foggs --
-----------
function make_fog(x,y,data)
	local f = make_actor(4, x, y)
	add(fog_map[x][y], f)
	add(level_items, f)
	f.ps = make_particle_system(x,y+1,data)
	f.turn = fog_turn
	f.data = data
	f.age = 0
	f.draw = function()
		f.ps:draw()
	end
	f.on_del = function()
		del(fog_map[x][y], f)
		f.ps.dead = true
	end
	return f
end
function fog_turn(f)
	f.age += 1
	f.ps.genrate = f.age*2
	if f.age > 2 then
		del(actor, f)
		f.on_del()
	end
end


-----------
-- items --
-----------
function get_throwing_point(direction, player, item)
	-- move in the direction 3 spaces or until you hit a wall
	local last_point = get_node(player.x, player.y)
	local next_point = get_node(player.x+direction.x, player.y+direction.y)
	local move_count = 0
	while 
		inmap(next_point.x, next_point.y) and
		move_count < 3 and
		map[next_point.x][next_point.y] == 0
	do
		if enemy_map[next_point.x][next_point.y] ~= 0 then
			return next_point.x,next_point.y
		end
		last_point = next_point
		move_count+=1
		next_point = get_node(next_point.x+direction.x, next_point.y+direction.y)
	end
	return last_point.x, last_point.y
end
function potion_on_use(direction, player, item)
	-- explode the potion on the map at this point
	local target_x, target_y = get_throwing_point(direction, player, item)
	make_fog(target_x, target_y,item.data)
	player.remove_item(item)
	sfx(10,3)
	return true
end
function bomb_on_use(direction, player, item)
	-- explode the potion on the map at this point
	local target_x, target_y = get_throwing_point(direction, player, item)
	make_bomb(target_x, target_y,item.data)
	sfx(10,3)
	player.remove_item(item)
	return true
end
local item_types = {
	{
		name="boots of travel",small_spr=38,large_spr=9,
		on_use=function(direction, player, item)
			-- search the map in the correct direction for an enemy
			local next_point = get_node(player.x+direction.x, player.y+direction.y)
			local prev_point = get_node(player.x, player.y)
			while inmap(next_point.x, next_point.y) and
				map[next_point.x][next_point.y] == 0
			do
				prev_point = next_point
				next_point = get_node(next_point.x+direction.x, next_point.y+direction.y)
			end
			player.x = prev_point.x
			player.y = prev_point.y
			player.remove_item(item)
			sfx(9,3)
			return true
		end,
	},
	{
		name="bomb",small_spr=39,large_spr=11,
		on_use=bomb_on_use,
	},
	{
		name="green potion",small_spr=24,large_spr=36,
		on_use=potion_on_use,
		t="potion",
		colors = {11,3,5},
		on_step=function(fog, actor)
			log("fog step")
			-- heals whatever steps on it
			sfx(11,3)
			actor.health = min(actor.max_health, actor.health+1)
		end
	},
	{
		name="blue potion",small_spr=7,large_spr=0,
		t="potion",
		on_use=potion_on_use,
		colors = {12,1,13},
		on_step=function(fog, actor)
			-- causes whatever is on it to lose a turn
			actor.lost_turn += 1
		end
	},
	{
		name="red potion",small_spr=23,large_spr=4,
		t="potion",
		on_use=potion_on_use,
		on_step=function(fog, actor)
			log("fog step")
			-- red potion does damage to the thing that steps on it
			actor:hit()
		end
	},
	{
		name="bow",small_spr=8,large_spr=34,
		on_use=function(direction, player, item)
			-- search the map in the correct direction for an enemy
			local next_point = get_node(player.x+direction.x, player.y+direction.y)
			while inmap(next_point.x, next_point.y) do
				if enemy_map[next_point.x][next_point.y] ~= 0 then
					enemy_hit(enemy_map[next_point.x][next_point.y],check_direction(direction.x,direction.y))
					player.remove_item(item)
					return true
				end
				next_point = get_node(next_point.x+direction.x, next_point.y+direction.y)
			end
		end,
	},
	{
		name="helmet",small_spr=6,large_spr=2,
		on_enemy_attack = function(enemy,player,item)
			-- destroy the item, the player doesn't take damage though
			player.remove_item(item)
			return false
		end,
	},
	{
		name="sword",small_spr=22,large_spr=32,
		on_player_attack = function(enemy,player,item)
			log("player sword attack")
			-- destroy the item and double hit the enemy
			player.remove_item(item)
			enemy_hit(enemy)
			enemy_hit(enemy)
			return false
		end,
	}
}

function make_item(x,y,sprite_ndx,force)
	local i = make_actor(3, x, y)	
	local item_index = flr(rnd(count(item_types)))+1
	if force ~= nil then
		item_index = force
	end
	i.data = item_types[item_index]
	item_map[x][y] = i
	i.draw = function()
		spr(i.data.small_spr, i.x*8,(i.y+1)*8-2,1,1,i.hflip)
	end
	return i
end

----------
-- bomb --
----------
function make_bomb(x,y,data)
	local f = make_actor(5, x, y)
	add(fog_map[x][y], f)
	add(level_items, f)
	f.data = data
	f.age = 4
	f.draw_count = 0
	f.draw = function()
		if counter%(f.age^3)==0 then
			f.draw_count += 1
		end
		if f.draw_count%2 == 0 then
			pal(5,8);pal(6,8)
		end
		spr(f.data.small_spr, x*8,(y+1)*8)
		pal()
	end
	f.turn = function(bomb)
		f.age-=1
		if f.age == 0 then
			f.on_del()
			sfx(14,3)

			-- get red potion
			local potion = nil
			foreach(item_types, function(v) if v.name == "red potion" then potion = v end end)
			local explode_potion = function(x,y)
				if inmap(x,y) then
					local fog = make_fog(x, y, potion)
					if map[x][y] == 2 then
						map[x][y] = 0
					end
				end
			end
			foreach(get_directions(get_node(x,y)), function(dir)
				explode_potion(dir.x,dir.y)
			end)
			explode_potion(f.x,f.y)
			del(level_items, f)
		end
	end

	f.on_del = function()
		del(fog_map[x][y], f)
	end
	return f
end

----------------------
-- particle systems --
----------------------
function make_particle_system(x,y,data)
	data = data or {}
	local i = make_actor(4, x, y)
	i.particles = {}
	i.nextgen = 1; i.genrate = 1
	i.colors = data.colors or {8,9,10}
	i.draw = particle_system_draw
	i.update = particle_system_update
	i.dead = false
	return i
end
function particle_system_update(ps)
	ps.nextgen -= 1
	if ps.nextgen <= 0 and not ps.dead then
		for i=1,3 do
			ps.nextgen = ps.genrate
			add(ps.particles, {x=rnd(6)-3, y=rnd(6)-3, age=0, speed=-rnd(0.75), lifetime=10+rnd(5)})
		end
	end
	foreach(ps.particles, function(p)
		p.y+=p.speed
		p.x += rnd(p.age*0.08)-p.age*0.04
		p.age += 1
		if p.age > p.lifetime then
			del(ps.particles, p)
		end
	end)
	if ps.dead and count(ps.particles) == 0 then
		del(actor, ps)
	end
end
function particle_system_draw(ps)
	foreach(ps.particles, function(p)
		pset(ps.x*8+4+p.x, ps.y*8+4+p.y, ps.colors[flr(p.age/p.lifetime*#ps.colors)+1])
	end)
end

--------------------
-- map generation --
--------------------
function get_add_position(found_callback)
	local found_position = false
	local rand_xy = function() return flr(rnd(sizex)), flr(rnd(sizey)) end
	local allow_place = function(x,y) 
		return map[x][y] == 0 and
			x ~= player.x and
			y~=player.y and
			enemy_map[x][y] == 0 and
			item_map[x][y] == 0;
	end
	while not found_position do
		local x,y = rand_xy()
		if allow_place(x,y) then
			found_callback(x,y)
			found_position = true
		end
	end
end
function make_map()
	
	-- clear the map
	map = get_map()
	enemy_map = get_map()
	item_map = get_map()
	fog_map = get_map("table")
	foreach(level_items, function(i)
		if i.on_del then i:on_del() end
		del(actor, i) 
	end)
	level_items = {}
	-- put in the exit on the right somewhere
	doory = flr(rnd(8));
	doorx = sizex-1
	if player.x ~= 0 then
		doorx = 0
	end
	map[doorx][doory] = 1

	-- put random walls on the map
	local wallcount = 0
	while wallcount <= 18 do
		local x = flr(rnd(sizex))
		local y = flr(rnd(sizey))
		if map[x][y] == 0 then
			map[x][y] = 2
			wallcount += 1;
		end
	end
	local enemycount = 0
	while enemycount < current_level do
		get_add_position(function(x,y)
			add(level_items, make_enemy(x,y))
			enemycount += 1;
		end)
	end
	local itemcount = 0
	while itemcount <= 2 do
		get_add_position(function(x,y)
			add(level_items, make_item(x,y,6))
			itemcount += 1;
		end)
	end

	if map[player.x][player.y] ~= 0 then
		return false
	end
	-- check to see if the map is exitable
	local exitpath = get_pathfinder().find_path(
		get_node(doorx,doory), get_node(player.x, player.y),
		function(x,y)
			return inmap(x,y) and map[x][y] ~= 2
		end
	)
	return count(exitpath) > 0
end
function inmap(x,y)
	return x>=0 and x<sizex and y>=0 and y<sizey
end


-- quests

quests = {
	{
		desc1 = "exit with 3",
		desc2 = "potions before",
		display_incomplete = function(q)
			color(5)
			print("level 5", 64,108)
		end,
		max_level = 5,
		init = function(q)
			q.completed = false
		end,
		bonus_multiplier = 3,
		complete = function(q)
			q.after_level_get(q)
			return q.completed
		end,
		on_after_turn = function(q)
			q.after_level_get(q)
		end,
		after_level_get = function(q)
			-- check to seef if the players inventory is all potions
			local potioncounter = 0

			for index=0,3 do
				local i = player.items[index];
				if i and i.data.t and i.data.t == "potion" then
					potioncounter += 1
				end
			end
			if potioncounter >= 3 then q.completed = true end
		end
	},
	{
		desc1 = "heal 4 hearts",
		desc2 = "before level 5",
		display_incomplete = function(quest)
			for i=1,quest.target_heals do
				local f = function(ndx) spr(ndx, 55+i*9,110) end
				if quest.heals < i then
					f(131)
				else
					f(147)
				end
			end
		end,
		max_level = 5,
		complete = function(quest)
			return quest.target_heals <= quest.heals;
		end,
		init = function(q)
			q.target_heals = 4
			q.heals = 0
			q.last_health = 3
			q.heal_guarentee = 2
		end,
		bonus_multiplier = 3,
		on_after_turn = function(q)
			if(player.health > q.last_health) q.heals += player.health - q.last_health
			q.last_health = player.health;
		end,
		after_level_get = function(q)
			if q.heal_guarentee > 0 then
				local force_potion = rnd(1)>0.5
				if(q.max_level-current_level<=q.heal_guarentee) force_potion = true
				if force_potion then
					get_add_position(function(x,y)
						add(level_items, make_item(x,y,6,3))
					end)
				end
			end
		end
	},
	{
		desc1 = "get to level 4",
		desc2 = "with < 3 kills",
		display_incomplete = function(q)
		end,
		max_level = 4,
		complete = function(q)
			return q.kills < 3 and current_level == 4
		end,
		init = function(q)
			q.kills = 0
			q.boot_guarentee = 2
		end,
		display_incomplete = function(q)
			for i=1,2 do
				local f = function(ndx) spr(ndx, 55+i*9,110) end
				if q.kills < i then
					f(160)
				else
					f(161)
				end
			end
		end,

		bonus_multiplier = 2,
		on_enemy_kill = function(q)
			q.kills += 1
		end,
		after_level_get = function(q)
			if q.boot_guarentee > 0 then
				local force_potion = rnd(1)>0.5
				if(q.max_level-current_level<=q.boot_guarentee) force_potion = true
				if force_potion then
					get_add_position(function(x,y)
						add(level_items, make_item(x,y,6,1))
					end)
				end
			end
		end
	},
	{
		desc1 = "4 levels",
		desc2 = "no green potions",
		display_incomplete = function(q)
		end,
		max_level = 4,
		complete = function(q)
			return current_level == 5
		end,
		init = function(q)
		end,
		bonus_multiplier = 4,
		after_level_get = function(q)
			-- wipe any green potions
			local allowed_items = {}
			foreach(item_types, function(v) if v.name ~= "green potion" then add(allowed_items, v) end end)
			for y=0,sizey-1 do
				for x=0,sizex-1 do
					if item_map[x][y]~=0 and item_map[x][y].data.name == "green potion" then
						item_map[x][y].data = allowed_items[flr(rnd(count(allowed_items)))+1]
					end
				end
			end
		end
	}
};

function display_quest()
	camera(0,0)
	color(8)
	print("quest: ", 64,90)
	color(5)
	print(current_quest.desc1, 64,96)
	print(current_quest.desc2, 64,102)
	if current_quest:complete() ~= true then
		current_quest:display_incomplete()
	else
		print("quest complete!", 64, 110)
		print("exit to score", 64, 116)
	end
end

-- pathfinder
function get_node(x,y,g)
	local node = {x=x,y=y,g=0}
	return node
end
function get_pathfinder()
	local pathfinder = {
		open_list={},
		open_list_count = 0,
		closed_list ={}
	}
	pathfinder.node_key = function(node)
		return node.x .. "_" .. node.y
	end
	pathfinder.lowest_cost_node = function()
		local lowest = nil
		foreach(pathfinder.open_list, function(v)
			if lowest == nil or (lowest.f > v.f and v ~= nil) then
				lowest = v
			end
		end)
		return lowest
	end
	-- returns a list of nodes to the nesw of the node that was passed in
	pathfinder.get_neighbors = function(node)
		opts = get_directions(node)
		if pathfinder.direction_pref ~= 0 then
			local old_opts = opts
			local new_opts = {}
			for i=1,4 do
				new_opts[i] = old_opts[((i-1)+pathfinder.direction_pref)%4+1]
			end
			opts = new_opts
		end
		nodes = {}
		foreach(opts, function(opt)
			-- (in the original version of this code, i eliminated options as it went)
			-- right now, i am only eliminating stuff outside the map
			-- could take a callback to determine cost / elimination etc
			if pathfinder.elim_func(opt.x,opt.y) then
				opt.g = pathfinder.cost_func(opt.x,opt.y,node.g);
				opt.parent = node;
				add(nodes, opt);
			end
		end)
		return nodes
	end
	pathfinder.find_node = function(x,y,list)
		local list = list or pathfinder.open_list
		foreach(list, function(v)
			if v.x == x and v.y == y then return v end
		end)
	end
	pathfinder.standard_cost = function(x,y,last)
		return last + 1
	end
	pathfinder.standard_elim = function(x,y)
		return inmap(x,y)
	end
	pathfinder.find_path = function(start_node, end_node, elim_func, cost_func,direction_pref)
		if not current_quest then return {} end
		pathfinder.direction_pref = direction_pref or 0
		pathfinder.elim_func = elim_func or pathfinder.standard_elim
		pathfinder.cost_func = cost_func or pathfinder.standard_cost
		add(pathfinder.open_list, start_node)
		pathfinder.open_list_count = 1
		path_found = false
		pathfinder.closed_keys = {}
		local find_attempts = 0
		-- ugly hack to keep it from timing out if there isn't a clear path to the end
		-- not sure why this is necessary
		while count(pathfinder.open_list) > 0 and path_found ~= true and find_attempts < 128 do
			find_attempts+=1
			-- find the lowest f node on the open list
			lowest = pathfinder.lowest_cost_node()
			-- move it to the closed list
			add(pathfinder.closed_list, lowest);
			del(pathfinder.open_list, lowest)
			pathfinder.closed_keys[lowest.x .. "_" .. lowest.y] = true
			pathfinder.open_list_count = pathfinder.open_list_count - 1
			-- if the lowest that we moved was the end node, then we have found the path
			if lowest.x == end_node.x and lowest.y == end_node.y then
				path_found = true
			end
			-- get the neighbors for the lowest cost node
			foreach(pathfinder.get_neighbors(lowest), function(v)
				-- if the neighbor isn't on the open list, add it
				if pathfinder.closed_keys[v.x .. "_" .. v.y] then
				else
					local neighbor_node = pathfinder.find_node(v.x,v.y)
					if neighbor_node == nil then
						-- first calculate the fgh scores for this node (g already calculated in the get neighbors chunk)
						v.h = abs(v.x-end_node.x)+abs(v.y-end_node.y)
						v.f = v.h+v.g
						add(pathfinder.open_list, v)
						pathfinder.open_list_count = pathfinder.open_list_count + 1
					elseif neighbor_node.g > v.g then
						-- if it already was on the open list but the cost is lower on the new node, then recalculate from the end
						v.h = abs(v.x-end_node.x)+abs(v.y-end_node.y)
						v.f = v.h+v.g
						del(pathfinder.open_list, neighbor_node)
						add(pathfinder.open_list, v)
					end
				end
			end)
		end
		local path = {}
		-- now build the path from the end
		if path_found then
			local nextn = pathfinder.closed_list[count(pathfinder.closed_list)]
			while nextn ~= nil do
				add(path, nextn)
				nextn = nextn.parent
			end
			path = reverse(path)
		end
		pathfinder.open_list = {}
		pathfinder.closed_list = {}
		pathfinder.closed_keys = {}
		return path
	end
	return pathfinder
end
function reverse(t)
	local out = {}
	for i=count(t),1,-1 do
		add(out, t[i])
	end
	return out
end

if peek(0x4300) == 0 then
  poke(0x4300,1)
  load("cards")
  run()
else
  poke(0x4300,0)
end
__gfx__
00000009990000000000000000000000000000000000000006666660000990000044000000000000000000000000000000999000000000000000000000000000
00000099499000000000000000000000000000090000000066166166000440000050400004444444400000000000000559000900000000000000000000000000
0000074999470000000007676670000000000094900000006106601600d44d000050040004555555540000000000000555000900000000000000000000000000
0000074444470000000076666666000000000749470000006606606600dccd00005009000455555554000000000000656600009a000000000000000000000000
0000067444760000000767666666600000000744470000006601106600d11d000050090004455555440000000000665555550000000000000000000000000000
0000066777660000007666666666660000007077707000006600006600d11d000050040005444444450000000006656555555000000000000000000000000000
0000066666660000006655516655160000006000006000006660066600d11d000050400000555555500000000066565556555500000000000000000000000000
00000061c16000000066555166551600000069999960000006600660000dd0000044000000444444400000000065655565555500000000000000000000000000
000000dcccd000000066555166551600000d9999999d000000007000000990000009900000444444400000000666555555555550000000000000000000000000
000000dcccd000000066555166551600000d9999999d000000076000000440000664466000444444440000000565565555555550000000000000000000000000
000000d1c1d000000066655555516600000d8999998d00000007600000d44d00ddd44ddd00444444440000000555555555555550000000000000000000000000
000000d111d000000066666555166600000d8888888d00000007600000d99d00d000000d00444444444440000056555565555500000000000000000000000000
000000d111d000000006666555166000000d8898989d0000000760000d8888d0dbbbbbbd04444444444444400055555555555500000000000000000000000000
000000d111d000000000666555160000000d8888888d000000555500d888888dd333333d04444444444444400005555555555000000000000000000000000000
000000d111d0000000000000000000000000d88989d0000000044000d888888dd333333d05555000055555500000555555550000000000000000000000000000
0000000ddd000000000000000000000000000ddddd000000000990000dddddd0dddddddd00000000000000000000005555000000000000000000000000000000
00000007000000000000054000000000000000999900000000000000000699000000000000000000000000000000000000000000000000000000000000000000
00000076600000000000050400000000000000499400000044444400000650900000000000000000000000000000000000000000000000000000000000000000
000000776000000000000500400000000000074444700000455544000065550a0000000000000000000000000000000000000000000000000000000000000000
00000076600000000000050004000000007777444477770044444000065655500000000000000000000000000000000000000000000000000000000000000000
00000076600000000000050004400000006007777770060044444400066555500000000000000000000000000000000000000000000000000000000000000000
00000076600000000000050004400000006000444400060044444444055555500000000000000000000000000000000000000000000000000000000000000000
00000076600000000000050009900000006000000000060044444444055555500000000000000000000000000000000000000000000000000000000000000000
000000766000000000000500099000000600bbbbbbbb006055445555005555000000000000000000000000000000000000000000000000000000000000000000
000000766000000000000500099000000dbbbbbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000766000000000000500099000000dbbbbbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000766000000000000500044000000dbbbbbbbbbbbbd000000000000000000000000000000000000000000000000000000000000000000000000000000000
000555555555000000000500044000000d33bbbbbbbb33d000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000444000000000000500440000000d3333333333b3d000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000994000000000000500400000000d33333b3b3b3bd000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000999000000000000504000000000dd33333b3b33dd000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000009990000000000005400000000000dddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660000000000000050550555777777777777777400000000000000000000000000000000000000000000000000000000000000000003330000000000
0000000066000000b3bb0b3b0055f110700000000000000400bbb33300bbbb3300bbbbbb00bb0b3000bbbbb000bbbb300bb000bb00bb3000000333000bbbb000
000000006656600033350b331111444070000000000000040b3355330bb333350b3333350b3303330b3333330b3333330b30003b0bb33000000333000b333300
00000000665660005535055504404440700000000000000403b550530bb333350b33355503333333033333350b3353330330000b0b333000000333000b333330
000000006656656600000000f555000f70000000000000040b30000303333355033330000300300303355555033503330b300003033b300000b3333003353333
00000000665665660bbbb3b3455555047000000000000004033000b3000333000333000003300033033000000350003303b000330b3330000b33333503505333
00000000665665660b3333330111f500700000000000000403333b33000333000333500003300033033bbb000330003303300033033330000333333503300533
00000000665665660335355550044005700000000000000403333330000333000333500003300033033333300330003303300033033330000355555503300033
6666666600000000000000000000000070000000000000040330003300033300033330000350003300555533035000330b30003303300000033bbb3303500033
6666666600000000000000000000000070000000000000040330003300033b000333300003300033000000330330003303300033033000000333333303300033
66666666000000000000000000000000700000000000000403500033000333000333300003300033000000330330005303b00033033000000350003303300033
6666666600000000000000000000000070000000000000040350003500033300033b300003300033000000330330b05503300033035000000350003503300b33
666666660000000000000000000000007000000000000004030000330003330003333bbb033bbb3300bbbb33033b330503300b350330000003000033033bb333
55555555000000000000000000000000700000000000000403500035000333000533333b033333350bb3333303303330033bbb35033000000350003503333335
55555555000000000000000000000000700000000000000403500035000335000533335303335335033353350333033503533335035000000350003503335350
55555555000000000000000000000000444444444444444405500055000050000055555500555550005555350035505503555555055000000550005505555500
000000000000000000000000000000000000000000000000035000000b3000350b3000b300000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000330bbbb033000b50b3000b300000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000330333303b000b50330b0b300000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000330003303330b35033030b500000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000033bbb330333b3350330303500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000003333335003333500300300500000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000033353550003350003b3333500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000555550000050000355555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000002200220058888800066600008222280082222800822228000000000000000000000000000000000000000000000000000000000
000000000000000008888880255225526588888005555500882aa288882112888821128800000000000000000000000000000000000000000000000000000000
000000000000000008288280255555526588888008888800882aa288882112888821128800000000000000000000000000000000000000000000000000000000
000000000000000082222a28255555526588a880088a880082a22a2882a22a2882122a2800000000000000000000000000000000000000000000000000000000
0000000000000000882882880255552065eeeee00eeeee0080255208802552088026620800000000000000000000000000000000000000000000000000000000
00444000000000008222222800255200052888200288820080055008800660088000000800000000000000000000000000000000000000000000000000000000
04999000004440008000000800022000008888800888880080066008800000088000000800000000000000000000000000000000000000000000000000000000
04191000049990002000000200000000008080800808080080000008800000088000000800000000000000000000000000000000000000000000000000000000
4499900004191000000000000ee00ee0088888500888880000000000000000000000000000000000000000000000000000000000000000000000000000000000
039993004499900008888880e88ee88e088888560888880000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333330039993000828828088888888088888560888880000000000000000000000000000000000000000000000000000000000000000000000000000000000
903330903333333082a22a2888888888088a8856088a880000000000000000000000000000000000000000000000000000000000000000000000000000000000
004440009033309088288288088888800eeeee560eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444000004440008222222800888800028882500288820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444000044444008000000800088000088888000555550000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505000005005002000000200000000080808000606060000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555777777770005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555766666660555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55005500665566555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55005500665566555000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555667766775333333500888800008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555556666666653333335088aa880082aa2800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005050500060606053333335828ee828888ee8880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505050006060605555555588888888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4b4c4a4a4770700070704f4a4d474b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c585a5770707070705f58584e5e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
484b49464d4a474a0000494c474a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5859565d585857580000565c5758707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4b474d4a4f707070704b464b4c4a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d5e4e58585f7070707066565e67580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4b4b494a704b4c4a46704b464b47474b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
665e565870596758567066565957575900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01010000180700c5710c7710c0700c0510c7510c7510c7530c03018030240000c0000c0000c000000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
01100000070700000009075090050907509005221022a60520002000001d004090051c00200000201020000007072000000907509005090750000022004000001d0040000020004000001d004000000000000000
0110002007070020000907500000090750000008000000000000000000000000000000000000000000000000070700000009075000000907500000000000907509075000000a0750a0750b0050b0750b0750c005
011000200c070000000f075396050f075005053b605000003b605000002f6052f6052c5032f60500005000000c070000000f075000050f075000000f070000050f0700f0700f0000c0700c0700c0000b0750b075
01100020005050000500505000053c6553c6250000500005000050000500005000053c6353c6050000500005000050000500005000053c6553c6250000000000000000000000000000003b6553b6053b60500005
01100000285702857028570000000000000000000000000000000000000000000000295502b5512b5502b5502d500345503455034550345500000000000000000000028500345502755127550295003555035550
01100020000000000000000000002d5502d5502d5500000000000000002b5502b5502b55000000000000000000000215502155021550000001b5501b5501b5500000000000295502955029550295500000000000
00010000070400706008060126500a6400c6403a6500a0100a0100801004610076100860008600016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000003270032700a2700a2700c2701325013240182301823022220222102e2002e2002e2002e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a070180200b03001040010500176001770027700276002760266402764028640286302a6302b6302c6302d6302d6202e620306203062031620316203262032610326103261033610346103461036610
000600002d320013202d34001340283500a3500937008330063200530003300023000165001650016500164001620016100000000000000000000000000000000000000000000000000000000000000000000000
00100000033101f32005330223400a3502e3600f3702e3702e3602e3502e3302e3102e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200000160701607026070260701e0701e0701607016070160701607016070160701607016070120701207012070120701207012070120701207012070120701207012070120701207012070120701207000000
002000001f0701f0701d0701d0701507015070240702407024070240700c0700c0700c0700c0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f0700f07000000
0005000001071030710b07111071280713f0710165017570016500a5600165006560016500165006550016400164001640036400363004630046300d530046200462004620056200462001610026100261008510
0010000003370033700f3700f37022370223701b2701b2501b2301b22000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c3700c370163701637022370223700f1600f1500f1300f12000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001117011170131701317013170131700c1700c1500c1360c11400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 42 43 44
00 02 42 43 44
00 03 42 43 44
00 03 42 43 44
01 01 04 05 44
00 02 04 05 44
00 03 04 06 44
02 03 04 06 44
00 0c 0d 43 44
04 10 11 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
