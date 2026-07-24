pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- dRAGONDELL
-- BY rELSQUI

cartdata('relsqui_dragondell')

function fr(i) return flr(rnd(i)) end
function choose(a) return a[fr(#a)+1] end
function twixt(i, lo, hi) return i > lo and i < hi end
function is_a(o, cls) return getmetatable(o) == cls end
function opp(dir) return bxor(dir, 1) end
function is_in(o, l) for i in all(l) do if o == i then return true end end return false end

function unpack(t, from)
	from = from or 1
	if (from > #t) return
	return t[from], unpack(t, from+1)
end

function parse(s)
	local result = {}
	for i=1,#s,4 do add(result, sub(s, i, i+3)+0) end
	return unpack(result)
end

local last_heard = {}
function ssfx(s)
	if not last_heard[s] or t() - last_heard[s] > 1 then
		sfx(s)
		last_heard[s] = t()
	end
end

function end_music(game)
	sfx(52, -2)
	music(-1)
	if (game.music) music(25, 0, 7)
	game.current_music = 25
end

function carve_from(x, y, maze)
	local dirs = { parse"   0   1   2   3" }
	for i = #dirs, 1, -1 do
		local swap = fr(#dirs) + 1
		dirs[i], dirs[swap] = dirs[swap], dirs[i]
	end
	for dir in all(dirs) do
		local nx, ny = x, y
		if (dir == 0) nx -= 1
		if (dir == 1) nx += 1
		if (dir == 2) ny -= 1
		if (dir == 3) ny += 1
		if twixt(nx, -1, maze.width) and twixt(ny, -1, maze.height) and maze[nx][ny] == nil then
			maze[x][y][dir + 1] = true
			maze[nx][ny] = { false, false, false, false }
			maze[nx][ny][opp(dir) + 1] = true
			carve_from(nx, ny, maze)
		end
	end
end

function create_maze(width, height)
	local maze, start_x, start_y = { width = width; height = height; }, fr(width), fr(height)
	for x = 0, width - 1 do
		maze[x] = {}
	end
	maze[start_x][start_y] = { false, false, false, false }
	carve_from(start_x, start_y, maze)
	return maze
end

local game = {
	width = 5;
	height = 4;
	difficulty = 1;
	music = true;
	flicker = true;
	start_state = {};
	main_state = {};
	portal_state = {};
	end_state = {};
	royals_left = 0;
	treasure_left = 0;
	del_blinking = 1;
	royal_blinking = 37;
}

function game:reset()
	self.state, self.player, self.royals_left, self.treasure_left, self.start_time, self.end_time = self.start_state, Player(), 0, 0, t(), nil
	if (self.music and self.current_music ~= 0) music(-1) music(0, 0, 3)
	self.current_music = 0
end

function game:draw_hud()
	local p = self.player
	rectfill(parse"   4 121  54 126   5")
	rectfill(parse"   5 122  55 127   13")
	rectfill(parse"   5 122  54 126   2")
	for i = 1, min(5, p.treasure) do spr(58, -1 + (i * 8), 121) end
	if (p.treasure > 5) spr(parse"  20  49 122")

	rectfill(parse"  72 121 122 126   5")
	rectfill(parse"  73 122 123 127  13")
	rectfill(parse"  73 122 122 126   2")
	for i = 1, min(5, p.keys) do spr(42, 64 + (i * 9), 122) end
	if (p.keys > 5) spr(parse"  20 119 122")

	rectfill(parse" 120   5 126  47   5")
	rectfill(parse" 121   6 127  48  13")
	rectfill(parse" 121   6 126  47   2")
	for i = 1, min(5, p.royals_rescued) do spr(41, 121, i * 7) end
	if (p.royals_rescued > 5) spr(20, 123, 42)
end

function game.start_state:update()
	if (not self.knight_x) self.knight_x, self.step, self.counter = 12, -6, 0

	self.counter = (self.counter + 1) % 15
	if (self.counter == 0) self.knight_x += self.step
	if (self.knight_x < -10) self.step = 6
	if (self.knight_x > 86) self.step = -6

	game.del_blinking, game.royal_blinking = (game.del_blinking % 2374) + 1, (game.royal_blinking % 2837) + 1

	if btnp(4) then
		sfx(58)
		last_heard[47] = t()
		game:create_rooms()
		game.state = game.main_state
	end
	if (btnp(0)) game.difficulty = max(0, game.difficulty-1)
	if (btnp(1)) game.difficulty = min(2, game.difficulty+1)
end

function game.start_state:draw()
	rectfill(parse"   0   0 127  64  12")
	rectfill(parse"   0  65 127 127   3")
	for x = 0, 15 do spr(36, x * 8, 64) end
	spr(6, self.knight_x, 67, 1, 1, self.step > 0)
	spr(parse"  26  35  72")
	spr(parse"  30  15  82")
	spr(parse"  47  58  78")
	spr(parse"  47  35  90")
	spr(parse"  71  56  16  13  12")
	if (flr(game.del_blinking/3) % 71 == 0) spr(128, 88, 72)
	if (flr(game.royal_blinking/3) % 40 == 0) spr(129, 104, 72)
	rectfill(parse"  11   9 116  30   2")
	line(parse"  11   9 115   9   8")
	line(parse"  11   9  11  29   8")
	line(parse" 116  30  12  30   1")
	line(parse" 116  30 116  10   1")
	line(parse"  40   0  40   8   4")
	line(parse"  87   0  87   8   4")
	line(parse"  41   0  41   8   5")
	line(parse"  88   0  88   8   5")
	spr(parse"  64  14  12   7   2")
	spr(parse"  96  66  12   6   2")
	local diff = game.difficulty+1
	local str = {'     tourist  ‘', '‹ adventurer ‘', '‹   veteran'}
	local col = {parse"  12   9   8"}
	print(str[diff], 3, 110, col[diff])
	print('press Ž to start', 3, 120, 2)
end

function game.main_state:update()
	local p = game.player
	p:update()
	game.current_room:alert_knights(p.loc, function(k)
		p.seen_by[k.id] = true
		if k.step ~= k.charge and k.step ~= k.stand then
			k:change_state(k.chase, p.loc:copy())
		end
	end)
	for timer in all(game.current_room.timers) do timer:tick() end
	for k in all(game.current_room.knights) do k:check_for_player() end
	if (p.royals_rescued == 0 and p:count_followers() == game.royals_left) p.conga = true
	if (game.treasure_left == 0 and game.royals_left == 0) p.completed = true
	game.current_room:update_danger()
end

function game.main_state:draw()
	game.current_room:draw()
	game:draw_hud()
end

function game.portal_state:update()
	game.current_room.portal_timer:tick()
	self.counter += 1
	if self.counter > 45 then
		game.state = game.end_state
		end_music(game)
	end
end

function game.portal_state:draw()
	if self.counter < 15 then
		game.current_room:draw()
		game:draw_hud()
	else
		rectfill(0, 0, 127, 127, black)
		if self.counter < 30 then
			game.player:draw()
			game.current_room:draw_portal()
		else
			if (game.flicker and band(self.counter, 1) == 1) game.player:draw()
			game.current_room:draw_portal()
		end
	end
end

function game.end_state:update()
	if (btnp(4)) sfx(58) game:reset()
end

function game.end_state:draw()
	game.end_time = game.end_time or t()
	local player, points, knights_seen, seen_by = game.player, parse"   0   0   0"
	local followers, treasure, royals_rescued = player:count_followers(), player.treasure, player.royals_rescued
	-- we can't use #count or all() because these are hashes, not lists
	for knight, saw in pairs(player.knights_seen) do knights_seen += 1 end
	for knight, seen in pairs(player.seen_by) do seen_by += 1 end

	local segments = {
		{'treasure', treasure * 25},
		{'royal reunions', royals_rescued * 50},
		{'keyring', player.keys * 5},
		{'friendly', followers * 10},
		{'fierce', player.knights_toasted * 5},
		{'greedy', (treasure - royals_rescued - followers) * 5},
		{'selfless', treasure == 0 and royals_rescued * 20 or 0},
		{'quick', flr((player.speed_cap - (game.end_time - game.start_time)) * 2.5)},
		{'stealthy', (knights_seen - seen_by) * 5},
		{'shadow', seen_by == 0 and knights_seen * 5 or 0},
		{'conspicuous', knights_seen == seen_by and seen_by * 5 or 0},
		{'long shots', player.long_shots * 20},
		{'close shaves', player.close_shaves * 30},
		{'nick of time', player.nick_of_time and 30 or 0},
		{'conga line', player.conga and royals_rescued * 5 or 0},
		{'pacifist', player.knights_toasted == 0 and knights_seen * 5 or 0},
		{'survivor', player.survived and 500 or 0},
		{'completionist', player.completed and 100 or 0}
	}

	function printsegment(row, label, points, color)
		local color = color or 6 + band(row, 1)
		print(label, 10, row * 8, color)
		print(points, 90, row * 8, color)
	end

	rectfill(parse"   0   0 127 127   3")

	local row = 2
	for segment in all(segments) do
		if segment[2] > 0 then
			segment[2] *= (game.difficulty + 1)
			printsegment(row, unpack(segment))
			points += segment[2]
			row += 1
		end
	end

	if (points > dget(0)) dset(0, points) print('!! new high score !!', 24, (row+4)*8, 12)
	printsegment(row+1, 'your score', points, 10)
	printsegment(row+2, 'high score', dget(0), 9)
	print('press Ž to play again', parse"   2 120   2")
end

function game:create_rooms()
	local max_x, max_y = self.width, self.height
	local maze, size, royal_colors, to_add = create_maze(max_x, max_y), max_x * max_y, {parse"   8  11  12"}, {}
	local goal_count = flr((size-3)/3)
	self.royals_left, self.treasure_left = goal_count, goal_count

	for i = 1, goal_count do add(to_add, 26) add(to_add, 42) add(to_add, 0) end
	for i = 1, 3 do add(to_add, -1) end
	while #to_add < size do add(to_add, -2) end

	local next_color_index, key_count, rooms = 1, 0, {}
	for x = 0, max_x - 1 do
		rooms[x] = {}
		for y = 0, max_y - 1 do
			local valid, goal = false, choose(to_add)
			del(to_add, goal)
			while not valid do
				rooms[x][y] = Room(unpack(maze[x][y]))
				local room = rooms[x][y]
				if goal == 42 then
					local loc = room:random_location(true, true)
					room.decoration[loc.x][loc.y] = 42
					room:add_goal(loc)
				elseif goal == 26 then
					local loc = room:add_obstacle(26)
					room:add_goal(loc)
				elseif goal == 0 then
					local color = choose(royal_colors)
					local loc = room:add_npc(Royal, color)
					room:add_goal(loc)
				elseif goal == -1 then
					room:add_castle(royal_colors[next_color_index])
				elseif goal == -2 then
					room:add_npc(Knight)
				end
				if (rnd(4) < 3) room:add_npc(Knight)
				valid = room:validate()
				if (valid and goal == -1) next_color_index += 1
			end
		end
	end

	self.rooms, self.loc = rooms, Location(fr(max_x), fr(max_y))
	self.rooms[self.loc.x][self.loc.y].obstacles[2][2] = nil
	self:change_room_loc(self.loc)
end

function game:change_room(direction)
	local new_loc = self.loc:copy()
	new_loc:shift(direction)
	self:change_room_loc(new_loc)
end

function game:change_room_loc(new_loc)
	if (self.current_room) self.current_room:unload()
	self.loc = new_loc
	self.current_room = self.rooms[self.loc.x][self.loc.y]
	self.current_room:load()
	self.current_room:update_danger()
	if not game.player.rooms_seen[self.current_room.id] then
		game.player.speed_cap += 10
		game.player.rooms_seen[self.current_room.id] = true
	end
end

function towards(source, dest)
	local dx, dy = source.x - dest.x, source.y - dest.y
	if dx > 0 then xdir = 0 elseif dx < 0 then xdir = 1 end
	if dy > 0 then ydir = 2 elseif dy < 0 then ydir = 3 end
	if (not xdir and not ydir) return {nil, nil}
	if (not xdir) return {ydir, nil}
	if (not ydir) return {xdir, nil}
	if (abs(dx) > abs(dy)) return {xdir, ydir}
	return {ydir, xdir}
end

function Class(superclass)
	local cls = {}
	cls.next_id, cls.__index = 0, cls
	superclass = superclass or {}
	function superclass.__call(cls, ...)
		local c = {}
		setmetatable(c, cls)
		c.id = cls.next_id
		cls.next_id += 1
		c:constructor(...)
		return c
	end
	setmetatable(cls, superclass)
	return cls
end

Location = Class()
function Location:constructor(x, y)
	self.x, self.y = x, y
end

function Location:__eq(other)
	return self.x == other.x and self.y == other.y
end

function Location:copy()
	return Location(self.x, self.y)
end

function Location:next_to(other)
	local test_loc = self:copy()
	test_loc.y -= 1
	if (test_loc == other) return 2
	test_loc.y += 2
	if (test_loc == other) return 3
	test_loc.y -= 1
	test_loc.x -= 1
	if (test_loc == other) return 0
	test_loc.x += 2
	if (test_loc == other) return 1
	return nil
end

function Location:between(a, b)
	if (self.x < a.x and self.x < b.x) return false
	if (self.x > a.x and self.x > b.x) return false
	if (self.y < a.y and self.y < b.y) return false
	if (self.y > a.y and self.y > b.y) return false
	return true
end

function Location:shift(direction)
	if direction == 0 then
		self.x -= 1
	elseif direction == 1 then
		self.x += 1
	elseif direction == 2 then
		self.y -= 1
	elseif direction == 3 then
		self.y += 1
	end
end

function Location:oob()
	return self.x < 0 or self.x > 15 or self.y < 0 or self.y > 15
end

Timer = Class()
function Timer:constructor(maximum, callback, destructing)
	self.current, self.maximum, self.callback, self.destructing = 1, maximum, callback, destructing
end

function Timer:tick()
	self.current = (self.current % self.maximum) + 1
	if self.current >= self.maximum then
		self.callback()
		if (self.destructing) del(game.current_room.timers, self)
	end
end

Sprite = Class()
function Sprite:constructor(left, right, up, down)
		self.facing, self.face = fr(4), {}
		self:replace(left, right, up, down)
end

function Sprite:replace(left, right, up, down)
	if not right then
		right, up, down = left, left, left
	elseif not up then
		up, down, right = right, right, left
	elseif not down then
		down, up, right = up, right, left
	end
	self.face[0], self.face[1], self.face[2], self.face[3] = left, right, up, down
end

function Sprite:draw_at(loc)
	local flip_h = self.face[0] == self.face[1] and self.facing == 1
	local flip_v = self.face[2] == self.face[3] and self.facing == 2
	spr(self.face[self.facing], loc.x * 8, loc.y * 8, 1, 1, flip_h, flip_v)
end

Particle = Class()
function Particle:constructor(type, x, y, flip)
	-- TODO: move the particle timing logic in here
	-- as well as horizontal flip logic (so ! stays over sprite heads, for example)
	self.type, self.x, self.y, self.flip = type, x, y, flip or false
end

function Particle:draw()
	spr(self.type, self.x * 8, self.y * 8, 1, 1, self.flip)
end

Shadow = Class()
function Shadow:constructor(parent)
	self[0], self[1], self[2], self[3], self.parent = {}, {}, {}, {}, parent
	self:update()
end

function Shadow:update()
	local loc, full, i = self.parent.loc, 0b1111111111111111, 0
	while i < loc.y do
		self[0][i] = shl(full, abs(i - loc.y) + 15 - loc.x)
		-- TODO: try using explicit logical shift
		-- we use this slightly pre-shifted literal to keep lua from helpfully shifting 1s in from the left
		self[1][i] = shl(shr(0b0111111111111111.1, abs(i - loc.y) + loc.x), 1)
		self[2][i] = bxor(full, bor(shl(full, abs(i - loc.y - 1) + 15 - loc.x), shl(shr(0b011111111111111.1, abs(i - loc.y) + loc.x), 1)))
		self[3][i] = 0
		i += 1
	end
	while i < 16 do
		self[0][i] = shl(full, abs(i - loc.y) + 15 - loc.x)
		self[1][i] = shl(shr(0b0111111111111111.1, abs(i - loc.y) + loc.x), 1)
		self[2][i] = 0
		self[3][i] = bxor(full, bor(shl(full, abs(i - loc.y + 1) + 15 - loc.x), shl(shr(0b011111111111111.1, abs(i - loc.y) + loc.x), 1)))
		i += 1
	end
	if (is_a(self.parent, Knight) and game.current_room) game.current_room.danger_needs_update = true
end

function Shadow:contains(x, y, direction)
	return band(self[direction][y], shl(1, 15 - x)) ~= 0
end

VisibleThing = Class(Object)
function VisibleThing:constructor(sprite, loc, facing)
	self.sprite, self.loc = sprite, loc
	self.shadow = Shadow(self)
	if (facing) self.sprite.facing = facing
end

function VisibleThing:draw()
	self.sprite:draw_at(self.loc)
end

Obstacle = Class(Object)
function Obstacle:constructor(spr, x, y)
	self.type, self.loc = spr, Location(x, y)
	self.shadow = Shadow(self)
end

function Obstacle:add_shadow(room)
	-- TODO: use sprite flags for this property
	if (self.type == 49) return
	for x = 0, 15 do for y = 0, 15 do for dir = 0, 3 do
		if (self.shadow:contains(x, y, dir)) add(room.obstacle_shadows[dir][x][y], self)
	end end end
end

Room = Class()
function Room:constructor(exit_left, exit_right, exit_up, exit_down)
	local pix_spr = {0, 36, 0, 0, 0, 16, nil, 52, 0, 0, 48, 49, 0, 21}

	function sp_map(room, dx, dy)
		for x = 0,15 do for y = 0,15 do
			local p = sget(x+dx, y+dy)
			if (is_in(p, {parse"   2   6   7   8  11  12  14"})) room.obstacles[x][y] = pix_spr[p]
		end end
	end

	local archetypes = {
		{ trees = 4 + fr(6); bushes = 4 + fr(5); rocks = 4 + fr(4); water = 3 + fr(3); },
		{ trees = 10 + fr(4); bushes = 2 + fr(3);  rocks = fr(2); water = fr(4); },
		{ trees = fr(2); bushes = 0; rocks = 10 + fr(4); water = 0; },
		-- watery has a lot of cover objects because water is going to override a lot of them
		{ trees = 4 + fr(4); bushes = 5 + fr(4); rocks = 2 + fr(4); water = 7 + fr(4); }
	}

	local set_pieces = {
			function() end,
			function() end,
			function() end,

			function(room)
				-- divided in quarters
				sp_map(room, 0, 112)
				local o = room.obstacles
				if (room.exit[0]) for x=1,4 do for y=7,8 do o[x][y] = nil end end
				if (room.exit[1]) for x=11,14 do for y=7,8 do o[x][y] = nil end end
				if (room.exit[2]) for x=7,8 do for y=0,4 do o[x][y] = nil end end
				if (room.exit[3]) for x=7,8 do for y=11,14 do o[x][y] = nil end end
			end,

			function(room)
				-- center block
				sp_map(room, 32, 96)
				local o = room.obstacles
				if (room.exit[0]) for x=1,3 do for y=7,8 do o[x][y] = nil end end
				if (room.exit[1]) for x=12,14 do for y=7,8 do o[x][y] = nil end end
				if (room.exit[2]) for x=7,8 do for y=0,3 do o[x][y] = nil end end
				if (room.exit[3]) for x=7,8 do for y=12,14 do o[x][y] = nil end end
			end,

			function(room)
				-- tree circle
				sp_map(room, 0, 96)
			end,

			function(room)
				-- moat
				sp_map(room, 32, 112)
				local o = room.obstacles
				if room.exit[0] then
					o[1][7] = nil
					o[1][8] = nil
				end
				if room.exit[1] then
					o[14][7] = nil
					o[14][8] = nil
				end
				if room.exit[2] then
					o[7][1] = nil
					o[8][1] = nil
				end
				if room.exit[3] then
					o[7][14] = nil
					o[8][14] = nil
				end
			end,

			function (room)
				-- river
				for x=0,15 do for y=0,15 do if (room.obstacles[x][y] == 49) room.obstacles[x][y] = nil end end
				sp_map(room, 16, 64+fr(4)*16)
			end,

			function (room)
				-- garden w/bushes
				local o = room.obstacles
				for x=0,15 do for y=0,15 do if (is_in(o[x][y], {16, 21})) o[x][y] = nil end end
				sp_map(room, 0, 80)
				if not room.exit[0] then
					o[1][6] = 21
					o[1][9] = 21
				end
				if not room.exit[1] then
					o[14][6] = 21
					o[14][9] = 21
				end
				if not room.exit[2] then
					o[6][1] = 21
					o[9][1] = 21
				end
				if not room.exit[3] then
					o[6][14] = 21
					o[9][14] = 21
				end
			end
	}

	local roomtype, sp, obstacles, decor_types, decor_count = choose(archetypes), choose(set_pieces), {}, {parse"  30  31  47  46"}, 20 + fr(5)
	self.visible_things, self.knights, self.timers, self.decoration, self.obstacles, self.exit, self.danger_needs_update = {game.player}, {}, {}, {}, obstacles, {exit_right, exit_up, exit_down}, false
	self.exit[0] = exit_left

	for x = 0, 15 do
		obstacles[x] = {}
		self.decoration[x] = {}
	end

	for i = 1, decor_count do
		local x = fr(14) + 1
		local y = fr(14) + 1
		local type = 30
		local j = fr(20)
		if j < 1 then
			type = 46
		elseif j < 3 then
			type = 31
		elseif j < 5 then
			type = 47
		end
		self.decoration[x][y] = type
	end

	for key, sprite in pairs({trees = 48, rocks = 16, bushes = 21}) do
		for i = 1, roomtype[key] do self:add_obstacle(sprite) end
	end

	for i = 1, roomtype.water do
		local base_x = fr(10) + 2
		local base_y = fr(10) + 2
		for x = base_x, base_x + 2 do
			for y = base_y, base_y + 2 do
				obstacles[x][y] = 49
			end
		end
	end

	for x = 1, 14 do
		obstacles[x][0] = 52
		obstacles[x][15] = 36
	end
	for y = 0, 15 do
		obstacles[0][y] = 36
		obstacles[15][y] = 36
	end

	self.goals = {}
	if self.exit[0] then
		obstacles[0][6] = 52
		obstacles[0][7] = nil
		obstacles[0][8] = nil
		-- this is a hash: y*width+x, but all those are constant
		add(self.goals, 112)
	end
	if self.exit[1] then
		obstacles[15][6] = 52
		obstacles[15][7] = nil
		obstacles[15][8] = nil
		add(self.goals, 127)
	end
	if self.exit[2] then
		obstacles[7][0] = nil
		obstacles[8][0] = nil
		add(self.goals, 7)
	end
	if self.exit[3] then
		obstacles[7][15] = nil
		obstacles[8][15] = nil
		add(self.goals, 247)
	end

	sp(self)
end

function Room:validate()
	-- cribbed from itty bitty citty, thx nornagon
	function open(pt) return twixt(pt.x, -1, 16) and twixt(pt.y, -1, 16) and self:get_type(pt.x, pt.y) == nil end
	local seen, to_find = {}, {}
	for g in all(self.goals) do add(to_find, g) end
	local front = {{x=2; y=2}}
	while #front > 0 do
		local check = front[#front]
		del(front, check)
		local hash = check.y*16+check.x
		if open(check) then
			seen[hash] = true
			del(to_find, hash)
			if (#to_find == 0) break
			for dx=-1,1 do for dy=-1,1 do
				if abs(dx)+abs(dy) == 1 then
					local h = (check.y+dy)*16+check.x+dx
					if (not seen[h]) front[#front+1] = {x=check.x+dx; y=check.y+dy}
				end
			end end
		elseif self:get_type(check.x, check.y) == 26 then
			del(to_find, hash)
		end
	end
	return #to_find == 0
end

function Room:add_goal(loc)
	add(self.goals, loc.y*16+loc.x)
end

function Room:get_type(x, y)
	if (x < 0 or y < 0 or x > 15 or y > 15) return nil
	if (not self.obstacles[x]) return nil
	if (not self.obstacles[x][y]) return nil
	if (is_a(self.obstacles[x][y], Obstacle)) return self.obstacles[x][y].type
	return self.obstacles[x][y]
end

function Room:obstacle_at(loc, except)
	local type = self:get_type(loc.x, loc.y)
	if (type and type ~= except) return self.obstacles[loc.x][loc.y]
	return nil
end

function Room:at(loc, except)
	for thing in all(self.visible_things) do if (thing and thing ~= except and thing.loc == loc) return thing end
	return self:obstacle_at(loc)
end

function Room:random_location(empty, unhidden)
	function middleish_random() return fr(12) + 2 end

	local loc = Location(middleish_random(), middleish_random())
	while (unhidden and self:get_type(loc.x, loc.y+1) == 48) or (empty and self:at(loc)) do
		loc = Location(middleish_random(), middleish_random())
	end
	return loc
end

function Room:add_npc(type, color)
	if (type == Knight and game.difficulty == 0) return
	local loc = self:random_location(true)
	add(self.visible_things, type(self, loc, game.player.sprite.facing, color))
	return loc
end

function Room:add_obstacle(type)
	local loc = self:random_location(true, true)
	self.obstacles[loc.x][loc.y] = type
	return loc
end

function Room:add_portal()
	self.portal, self.portal_offset, self.portal_step = self:random_location(true, true), -2, 1
	self.portal_timer = Timer(20, function()
		self.portal_offset += self.portal_step
		if (self.portal_offset ~= -1) self.portal_step *= -1
	end)
	add(self.timers, self.portal_timer)
	self:add_goal(self.portal)
end

function Room:add_castle(color)
	local o, x, y = self.obstacles, fr(11)+3, fr(11)+3
	self.castle_color = color
	o[x][y] = 37
	o[x+1][y] = 38
	o[x][y+1] = 53
	o[x+1][y+1] = 54

	self.castle_near = {}
	self.castle_near[(y+2)*16+x] = true
	self.castle_near[(y+2)*16+x+1] = true

	add(self.goals, (y+2)*16+x)
	add(self.goals, (y+2)*16+x+1)
end

function Room:unload()
	self.obstacle_shadows, self.danger, self.treetops = nil, nil, nil
	for x = 0, 15 do
		for y = 0, 15 do
			if (self.obstacles[x][y]) self.obstacles[x][y] = self.obstacles[x][y].type
			if (is_in(self.decoration[x][y], {9, 25})) self.decoration[x][y] = nil
		end
	end
end

function Room:load()
	self.danger = {}
	self.obstacle_shadows = {}
	for dir = 0, 3 do
		self.obstacle_shadows[dir] = {}
	end
	for x = 0, 15 do
		for dir = 0, 3 do
			self.obstacle_shadows[dir][x] = {}
		end
		for y = 0, 15 do
			for dir = 0, 3 do
				self.obstacle_shadows[dir][x][y] = {}
			end
			if (self.obstacles[x][y]) self.obstacles[x][y] = Obstacle(self.obstacles[x][y], x, y)
		end
	end

	self.treetops = {}
	for x = 0, 15 do
		self.danger[x] = {}
		for y = 0, 15 do
			self.danger[x][y] = {}
			current = self:get_type(x, y)
			if current then
				mset(x, y, current)
				self.obstacles[x][y]:add_shadow(self)
			else
				mset(x, y, 0)
			end
			mset(x + 16, y, 0)
			mset(x + 32, y, 0)
			mset(x + 48, y, 0)
			if current == 49 then
				if (self:get_type(x - 1, y) == 49) mset(x + 16, y, 49)
				if (self:get_type(x, y - 1) == 49) mset(x + 32, y, 49)
			else
				if current == 48 then
					add(self.treetops, {x * 8, y * 8 - 11})
					add(self.treetops, {x * 8 - 3, y * 8 - 6})
					add(self.treetops, {x * 8 + 3, y * 8 - 6})
				end
				if self:get_type(x - 1, y) == 49 then
					if (self:get_type(x, y - 1) == 49 and self:get_type(x - 1, y - 1) == 49) mset(x + 48, y, 51)
					if (self:get_type(x, y + 1) == 49 and self:get_type(x - 1, y + 1) == 49) mset(x + 48, y, 35)
				end
				if self:get_type(x + 1, y) == 49 then
					if (self:get_type(x, y - 1) == 49 and self:get_type(x + 1, y - 1) == 49) mset(x + 48, y, 50)
					if (self:get_type(x, y + 1) == 49 and self:get_type(x + 1, y + 1) == 49) mset(x + 48, y, 34)
				end
			end
		end
	end

	local p = game.player
	for k in all(self.knights) do
		if not p.knights_seen[k.id] then while abs(k.loc.x - p.loc.x) < 4 and abs(k.loc.y - p.loc.y) < 4 do k.loc = self:random_location(true) end end
		p.knights_seen[k.id] = true
		k.sprite.facing = p.sprite.facing
		k:change_state(k.stand)
		add(self.timers, Timer(20, function() k:change_state(k.default_state) end, true))
	end
	self.danger_needs_update = true
end

function Room:update_danger()
	if (not self.danger_needs_update) return
	for x = 0, 15 do
		for y = 0, 15 do
			self.danger[x][y] = {}
			for k in all(game.current_room.knights) do
				if k.shadow:contains(x, y, k.sprite.facing) then
					local blocked = false
					for o in all(self.obstacle_shadows[k.sprite.facing][x][y]) do
						if k.shadow:contains(o.loc.x, o.loc.y, k.sprite.facing) and o.loc:between(k.loc, {x=x; y=y;}) then
							blocked = true
							break
						end
					end
					if (not blocked) add(self.danger[x][y], k)
				end
			end
		end
	end
	self.danger_needs_update = false
end

function Room:alert_knights(loc, cb)
	local klist = self.danger[loc.x][loc.y]
	if (game.difficulty == 2 and #klist > 0) klist = self.knights
	for k in all(klist) do cb(k) end
end

function Room:draw()
	self.particles = {}
	rectfill(parse"   0   0 127 127   3")

	line(parse"   0   0  55   0   2")
	line(parse"  72   0 127   0   2")
	if (not self.exit[2]) line(parse"  56   0  71   0   2")

	for x = 0, 15 do
		for y = 0, 15 do
			local decoration = self.decoration[x][y]
			if (decoration) spr(decoration, x * 8, y * 8)
			if (#self.danger[x][y] > 0) spr(33, x * 8, y * 8)
			if (#self.danger[x][y] > 1) spr(33, x * 8, y * 8, 1, 1, true, true)
		end
	end

	map(parse"  16   0  -4   1  16  16")
	map(parse"  32   0   0  -3  16  16")
	map(parse"  48   0   0   1  16  16")
	pal(8, self.castle_color or 8)
	map(parse"   0   0   0   1  16  16")
	pal()

	for thing in all(self.visible_things) do thing:draw() end
	if (self.portal) self:draw_portal()
	for t in all(self.treetops) do spr(32, t[1], t[2]) end
	for particle in all(self.particles) do particle:draw() end
end

function Room:draw_portal()
	spr(39, self.portal.x * 8, self.portal.y * 8 + self.portal_offset)
	spr(55, self.portal.x * 8, (self.portal.y + 1) * 8 + self.portal_offset)
end

Fireball = Class(VisibleThing)
function Fireball:constructor(loc, facing)
	getmetatable(Fireball).constructor(self, Sprite(4, 5), loc:copy(), facing)
	self.origin = loc:copy()
	self.age = 0
	self.timer = Timer(2, function()
		local room = game.current_room
		self.loc:shift(self.sprite.facing)
		local collider = room:at(self.loc)
		if is_a(collider, Knight) then
			if (self.age > 9) game.player.long_shots += 1
			collider:toast()
			self:destroy()
		elseif is_a(collider, Royal) then
			collider:dodge(self.sprite.facing)
		elseif self.loc:oob() or room:obstacle_at(self.loc, 49) then
			self:destroy()
		elseif game.current_room.decoration[self.loc.x][self.loc.y] == 9 then
			self:destroy()
		elseif game.difficulty > 1 then
			room:alert_knights(self.loc, function(k) k:change_state(k.chase, self.origin) end)
		end
		self.age += 1
	end)
	add(game.current_room.timers, self.timer)
end

function Fireball:destroy()
	del(game.current_room.visible_things, self)
	del(game.current_room.timers, self.timer)
end

Character = Class(VisibleThing)
function Character:draw()
	self.sprite:draw_at(self.loc)
	local p
	if (self.charmed) p = Particle(14, self.loc.x, self.loc.y - 1)
	if (self.alarmed) p = Particle(15, self.loc.x, self.loc.y - 1)
	if (self.smoking) p = Particle(62, self.loc.x, self.loc.y - 1, band(game.player.fireball_charge/5, 1) == 1)
	if (p) add(game.current_room.particles, p)
end

function Character:move(direction)
	local move_result = {true, nil}
	if (not direction) return move_result
	local old_loc = self.loc:copy()
	self.sprite.facing = direction
	self.loc:shift(direction)
	if self.loc:oob() then
		move_result = {false, nil}
	else
		collider = game.current_room:at(self.loc, self)
		if collider then
			if is_a(collider, Royal) and collider.following and not (self.loc:oob() or old_loc:oob()) then
				collider.loc = old_loc
				collider:check_castle()
				move_result = {true, collider}
			else
				move_result = {false, collider}
			end
		else
			if (self == game.player) sfx(62)
		end
	end
	if move_result[1] then
		self.shadow:update()
	else
		self.loc = old_loc
	end
	return move_result
end

function Character:count_followers()
	local followers = 0
	local f = self.followed_by
	while f do
		followers += 1
		f = f.followed_by
	end
	return followers
end

NPC = Class(Character)
function NPC:constructor(room, ...)
	getmetatable(NPC).constructor(self, ...)
	self.room, self.step, self.wander_speed, self.patrol_speed = room, self.wander, 20 + fr(20), 15 + fr(5) - (game.difficulty * 3)
	-- wrap step callback in a function so it'll re-evaluate what it is every time
	self.timer = Timer(self.wander_speed, function() self:step() end)
	add(self.room.timers, self.timer)
end

function NPC:move_towards(target_loc)
	local move_result, choices = {false, nil}, towards(self.loc, target_loc)
	for dir in all(choices) do
		if (not dir) break
		move_result = self:move(dir)
		if (move_result[1]) break
	end
	return move_result
end

function NPC:turn()
	if is_in(self.sprite.facing, {2, 3}) then
		if rnd(2) < 1 then
			choices = {0, 1}
		else
			choices = {1, 0}
		end
	else
		if rnd(2) < 1 then
			choices = {2, 3}
		else
			choices = {3, 2}
		end
	end
	local test_loc = self.loc:copy()
	test_loc:shift(choices[1])
	if self.room:at(test_loc) or test_loc:oob() then
		self.sprite.facing = choices[2]
	else
		self.sprite.facing = choices[1]
	end
	self.room.danger_needs_update = true
end

function NPC:dodge(direction)
	if (is_in(self.sprite.facing, {direction, opp(direction)})) self:turn()
	self:move(self.sprite.facing)
end

function NPC:change_state(new_state, ...)
	if (self.step == self.charge and new_state != self.charge and is_a(self, Knight)) self.sprite:replace(parse"   6   8   7")

	self.alarmed, self.charmed = false, false
	if new_state == self.charge then
		if (self.step ~= self.charge and self.step ~= self.chase) ssfx(57)
		self.timer.maximum = 6 - (game.difficulty * 2)
		if (is_a(self, Knight)) self.sprite:replace(parse"  22  24  23")
		self.alarmed = true
	elseif new_state == self.chase then
		if (self.step ~= self.charge and self.step ~= self.chase) ssfx(57)
		self.chase_time = 0
		self.chasing = ...
		self.timer.maximum = 7 - (game.difficulty * 2)
		self.alarmed = true
	elseif new_state == self.wander then
		self.timer.maximum = self.wander_speed
	elseif new_state == self.patrol then
		self.timer.maximum = self.patrol_speed
	elseif new_state == self.spin then
		self.timer.maximum = self.patrol_speed + 10
	elseif new_state == self.follow then
		self.timer.maximum = 4
		self.charmed = true
		add(self.room.timers, Timer(30, function() self.charmed = false end, true))
		self:start_following(...)
	end

	self.step = new_state
end

function NPC:stand()
end

function NPC:charge()
	local move_result = self:move(self.sprite.facing)
	if move_result[2] == game.player then
		sfx(51)
		game.player.sprite:replace(17, 19, 18)
		game.player.update = function() end
		self:change_state(self.stand)
		game.player.seen_by[self.id] = true
		game.state = game.end_state
		end_music(game)
	elseif not move_result[1] then
		self:change_state(self.default_state)
	end
end

function NPC:wander()
	local choice = rnd(20)
	if (choice < 1) return
	if (choice < 3) self:turn()
	if (not self:move(self.sprite.facing)[1]) self:turn()
end

function NPC:patrol()
	if (not self:move(self.sprite.facing)[1]) self:turn()
end

function NPC:spin()
	local next = {parse"   2   3   1   0"}
	local next_face = next[self.sprite.facing+1]
	if twixt(self.loc.x, 4, 11) and twixt(self.loc.y, 4, 11) or not self:move_towards(Location(7, 8))[1] then
		self.sprite.facing = next_face
		self.room.danger_needs_update = true
	end
end

function NPC:chase()
	self.chase_time += 1
	if (self.loc == self.chasing or not self:move_towards(self.chasing)[1] or self.chase_time > 16) self:change_state(self.default_state)
end

function NPC:follow()
	if (self.following.loc:oob()) return
	local towards_following = self.loc:next_to(self.following.loc)
	if towards_following then
		self.sprite.facing = towards_following
		return
	end

	local target_loc = self.following.loc:copy()
	target_loc:shift(opp(self.following.sprite.facing))
	self:move_towards(target_loc)
end

function NPC:start_following(target)
	local last_follower = target
	while last_follower.followed_by ~= nil do last_follower = last_follower.followed_by end
	if (last_follower == self) return
	if self.following and self.followed_by then
		self.followed_by.following, self.following.followed_by = self.following, self.followed_by
		self.followed_by = nil
	elseif self.following then
		self.following.followed_by = nil
	elseif self.followed_by then
		self.followed_by.following = nil
	end
	self.following = last_follower
	last_follower.followed_by = self
end

function NPC:stop_following()
	if (not self.following) return
	if (self.followed_by) self.followed_by.following = self.following
	self.following.followed_by, self.following, self.followed_by = self.followed_by, nil, nil
end

Knight = Class(NPC)
function Knight:constructor(room, loc, facing)
	getmetatable(Knight).constructor(self, room, Sprite(parse"   6   8   7"), loc, facing)
	self.default_state = choose({self.patrol, self.spin})
	self:change_state(self.default_state)
	self.timer.current = fr(self.timer.maximum)
	add(room.knights, self)
	self.room = room
end

function Knight:draw()
	if self.default_state == self.spin then
		pal(13, 5)
	end
	getmetatable(Knight).draw(self)
	pal()
end

function Knight:charge()
	getmetatable(Knight).charge(self)
	if (self.step ~= self.charge) self.sprite:replace(6, 8, 7)
end

function Knight:check_for_player()
	if (is_in(self.step, {self.charge, self.stand}) or self.toasted) return
	local towards_player = self.loc:next_to(game.player.loc)
	if (towards_player and towards_player ~= opp(self.sprite.facing)) self.sprite.facing = towards_player

	local watching = self.loc:copy()
	local found = nil
	while not watching:oob() and (not found or is_a(found, Fireball)) do
		watching:shift(self.sprite.facing)
		found = self.room:at(watching)
	end
	if (found == game.player) self:change_state(self.charge)
end

function Knight:toast()
	if (self.toasted) return
	local x, y, room = self.loc.x, self.loc.y, self.room
	if (self.loc:next_to(game.player.loc) and self.sprite.facing ~= game.player.sprite.facing) game.player.close_shaves += 1
	sfx(50)
	game.player.knights_toasted += 1
	del(room.timers, self.timer)
	del(room.knights, self)
	del(room.visible_things, self)
	self.toasted, room.danger_needs_update = true, true
	local old_decor = room.decoration[x][y]
	room.decoration[x][y] = 9
	add(room.timers, Timer(18, function()
		room.decoration[x][y] = 25
		add(room.timers, Timer(18, function()
			room.decoration[x][y] = old_decor == 42 and old_decor or nil
		end, true))
	end, true))
end

Royal = Class(NPC)
function Royal:constructor(room, loc, facing, color)
	local base = 16 * fr(4) + 11
	getmetatable(Royal).constructor(self, room, Sprite(base, base + 2, base + 1), loc, facing)
	local secondaries = {parse"   0   1   2   3   4   5   6   7   2   9  10   5   1  13  14  15"}
	self.primary_color, self.secondary_color = color, secondaries[color + 1]
end

function Royal:draw(...)
	pal(11, self.primary_color)
	pal(5, self.secondary_color)
	getmetatable(Royal).draw(self, ...)
	pal()
end


function Royal:move(...)
	local result = getmetatable(Royal).move(self, ...)
	self:check_castle()
	return result
end

function Royal:check_castle()
	local room = self.room
	if room.castle_color == self.primary_color and room.castle_near[self.loc.y*16+self.loc.x] then
		sfx(54)
		self:stop_following()
		self:change_state(self.stand)
		self.sprite.facing = 2
		del(room.timers, self.timer)
		game.player.royals_rescued += 1
		game.royals_left -= 1
		if (game.royals_left == 0) game.current_room:add_portal()
		add(room.timers, Timer(15, function()
			self.charmed = true
			self.loc:shift(2)
			add(room.timers, Timer(10, function() del(room.visible_things, self) end, true))
		end, true))
	end
end

function Royal:charm(charmer)
	if (not self.charmed) self:change_state(self.follow, charmer)
end

Player = Class(Character)
function Player:constructor()
	getmetatable(Player).constructor(self, Sprite(parse"   1   3   2"), Location(2, 2), 1)
	self.treasure, self.royals_rescued, self.knights_toasted, self.keys, self.fireball_charge, self.fireball_cooldown, self.close_shaves, self.long_shots, self.speed_cap, self.fireball_max, self.fireball_charge_max, self.fireball_cooldown_max, self.knights_seen, self.rooms_seen, self.seen_by = 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 30, 15, {}, {}, {}
end

function Player:update()
	self.charming, self.smoking, self.fireball_cooldown = false, false, max(0, self.fireball_cooldown - 1)
	if btn(4) then
		self.charming = true
	else
		last_heard[47], last_heard[55] = 0, 0
	end
	if btn(5) and self.fireball_cooldown == 0 then
		if self.fireball_charge == 0 then ssfx(52) end
		self.fireball_charge += 1
		if self.fireball_charge > self.fireball_charge_max then
			ssfx(53)
			add(game.current_room.visible_things, Fireball(self.loc, self.sprite.facing))
			add(game.current_room.timers, Timer(self.fireball_max, function()
				self.fireball_charge, self.fireball_cooldown = 0, self.fireball_cooldown_max
			end, true))
		else
			self.smoking = true
		end
	else
		sfx(52, -2)
		last_heard[52], last_heard[53], self.fireball_charge = parse"   0   0   0"
	end

	if self.charming then
		self:charm_facing()
		self.charmed = true
	else
		self.charmed = false
	end
	local shift = nil
	if (btnp(0)) shift = 0
	if (btnp(1)) shift = 1
	if (btnp(2)) shift = 2
	if (btnp(3)) shift = 3
	self:move(shift)
end

function Player:move(direction)
	local move_result = getmetatable(Player).move(self, direction)
	local room_d = game.current_room.decoration
	if move_result[1] then
		local x, y = self.loc.x, self.loc.y
		local decor = room_d[x][y]
		if decor == 42 then
			sfx(61)
			self.keys += 1
			room_d[x][y] = nil
		elseif decor == 10 then
			sfx(60)
			self.treasure += 1
			game.treasure_left -= 1
			room_d[x][y] = nil
		end
	else
		if is_a(move_result[2], Obstacle) then
			local obstacle = move_result[2]
			local o_loc = obstacle.loc
			if obstacle.type == 26 then
				if self.keys > 0 then
					sfx(59)
					self.keys -= 1
					game.current_room.obstacles[o_loc.x][o_loc.y] = nil
					room_d[o_loc.x][o_loc.y] = 10
					mset(o_loc.x, o_loc.y, nil)
				else
					sfx(48)
				end
			else
				sfx(48)
			end

		elseif is_a(move_result[2], Knight) and not move_result[2].toasted then
			move_result[2].sprite.facing = opp(self.sprite.facing)

		elseif move_result[2] == nil then
			local follower_x, follower_y
			if direction == 1 then
				self.loc.x, follower_x, follower_y = 0, -1, self.loc.y
			elseif direction == 0 then
				self.loc.x, follower_x, follower_y = 15, 16, self.loc.y
			elseif direction == 2 then
				self.loc.y, follower_x, follower_y = 15, self.loc.x, 16
			else
				self.loc.y, follower_x, follower_y = 0, self.loc.x, -1
			end

			local old_room = game.current_room
			game:change_room(direction)

			local collider, follower = game.current_room:at(self.loc), self.followed_by
			if (is_a(collider, Royal) or is_a(collider, Knight)) collider:dodge(self.sprite.facing)
			while follower do
				follower.charmed = false
				del(old_room.visible_things, follower)
				del(old_room.timers, follower.timer)
				add(game.current_room.visible_things, follower)
				add(game.current_room.timers, follower.timer)
				follower.room, follower.loc, follower.sprite.facing = game.current_room, Location(follower_x, follower_y), self.sprite.facing
				follower = follower.followed_by
			end
		end
	end

	if self.loc == game.current_room.portal then
		sfx(49)
		for k in all(game.current_room.knights) do if (is_in(k.step, {k.charge, k.chase})) self.nick_of_time = true end
		game.state, game.portal_state.counter, self.survived = game.portal_state, 0, true
	end
end

function Player:charm_facing()
	local charm_loc = self.loc:copy()
	charm_loc:shift(self.sprite.facing)
	local charmed = game.current_room:at(charm_loc)
	if (not is_a(charmed, Royal)) ssfx(47) return

	ssfx(55)
	charmed.sprite.facing = opp(self.sprite.facing)
	charmed:charm(self)
end

function add_toggle(i, var, on_text, off_text, on_fn, off_fn)
	menuitem(i, game[var] and on_text or off_text, function()
		game[var] = not game[var]
		add_toggle(i, var, on_text, off_text, on_fn, off_fn)
		if (game[var] and on_fn) on_fn()
		if (not game[var] and off_fn) off_fn()
	end)
end

function _init()
	game:reset()
	add_toggle(4, 'flicker', 'disable flicker', 'enable flicker')
	add_toggle(5, 'music', 'music off', 'music on', function() music(game.current_music, 0, 7) end, function() music(-1) end)
end

function _update()
	game.state:update()
end

function _draw()
	game.state:draw()
end
__gfx__
00000000000bbb9009bbb90009bbb90000000000000f9800800dddd0080dddd0800dddd010011110000000000a9a900000a9a90000a9a9000000000000000000
0000000000bbbbb99bbbbb909bbbbb9000000000000f8900800776d008067760800dddd0100111100000000009999000009999000099990000e0e00000000000
00700700bbb3bbbbbb3b3bb0bbbbbbb0088800000008990080066dd0080d66d0800dddd010011110000a00000cfcf90009cfcf90099999900e8e8e0000008000
00077000bbb666b99bbbbb909bbbbb9089a988ff000898006d2ddd22062dddd26d2dddd211111111009a89000ffff90009ffff90099999900e888e0000008000
0007700000dcccd00d666d000dcccd008f7f99890089f9808dd82ddd08dd82dd8ddddddd111111110a99aa9a0555b00000555b0000b99b0000e8e00000008000
0070070000caccc00ccacc000ccccc0089a98998008a7a8080d28dd608dd28d68dddddd61011111100000000fb5b5f000fb5b5f00f5bb5f0000e000000000000
0000000000ccccb00bcccb000ccbcc00088800000089f98080ddddd6080dddd680ddddd6101111110000000005b55500055b5550055555500000000000008000
000000000ecacceeeecacee0eccbcce0000000000008880080020020080200208002002010010010000000000151555005155150055555500000000000000000
00066600000000000000000000000000000000000005e50000000000000dddd0000dddd000000000000000000a9a900000a9a90000a9a9000000000000000000
006ddd600000000000dcbdd0000000000a0000000eb3335e000dddd000867760008dddd000000000004555400111100000111100001111000000000000000000
06d6ddd5000000000dccbcc000000000999000005b3b3335000776d0008266d00062ddd0000000000545554502424100012424100111111000000b0000000000
6d6dddd50090dccdcccccccc009b9b000400000005b33e3500266dd20d8dddd20062ddd000000000054555450444410001444410011111100000b00000570000
6ddddd5d0bb9ccccdc9b9b9d0dccccd0000000005e333355886888680d6d82dd00ddddd000000000049424940555b00000555b0000b11b000b00b00000797000
ddddd5d5b33bccdcddbbbbbddccccccd00000000533e353500dd28dd0d6ddddd008dddd000010000049444944b5b540004b5b540045bb54000b0b00000075500
d5d55d55bb6cddcbbd33b33bcccbcccd0000000053535355000ddddd008dddd0008dddd0001111000494449405b55500055b55500555555000b0b00000050000
0d555550000bcced000bbb000ddbddd0000000000555555000000202000200200002002011111111000000000151555005155150055555500005b00000000000
00355500000000000000000000000000222222220000000000000000007067000000000000000000000000000a9a900000a9a90000a9a9000000000000000000
03b333500000000000000000000000002555255508800000000000880760c670000000000a0a0a000aa900000999900000999900009999000000078000000000
3b3b353500000000000000000000000022222222088008800088008876c0cc670000000009a9a900090999990cfcf00000cfcf00009999000000088500800000
53b333550008000000000000000000005525552505000d0000d000506c0c0cc60000000009999900049404040ffff00000ffff0000999900000005500e800000
53533535000000000000000000000000222222220500dddddddd00506c0cc0c60000000004444400000000000555b00000555b0000b55b000788000000b00e00
53335355000000000000000000000000255525557f6d55555555d7f66cccc0c6000000000000000000000000fb5b5f000fb5b5f00f5bb5f00887500000b00880
05353550000000000000000cc0000000222222227f6d55555555d7f66c0c0c0600000000000000000000000005b55000005b5500005555000788500000b5b000
0055550000000000000000cccc000000552555257f666666666667f6760ccc6d00000000000000000000000001515000001551000055550000550000000b0000
0042220000cccc00000000cccc000000555555557f666666666667f60760c6700000000000000000000000000a9a900000a9a90000a9a9000000000000000000
004422000ccc7cc00000000cc0000000666666667f666655566667f600766700000000000000000000aaa9000111100000111100001111000000600000000000
00424200ccccc66c0000000000000000622262227f656545456567f60000000008888000088800000afeef400242400000242400001111000000060000000000
00442200cccccccc0000000000000000622262227f656545456567f600000000999a999a89a988900ae999400444400000444400001111000006060000000000
00444200c7cccccc0000000000000000666666667f666545456667f6000000007ff77ff78f7f99090ae999400555b00000555b0000b55b000006000000000000
04442442cc66cccc0000000000000000226222627f666545456667f600000000999a999a89a9800009f994404b5b540004b5b540045bb5400060000000000000
421421200cccccc00000000000000000226222627f6d0000000dd7f60000000008888000088800000044440005b55000005b5500005555000006000000000000
0000000000cccc000000000000000000666666660000000000000000000000000000000000000000000000000151500000155100005555000000000000000000
aaaaaa0000aaaaaa0000000aa0000000aaaaa000000aaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
a99999a000a944499000000a9000000a99999a0000a99999a0000000000000000000000000000000000000000000000000000000000000000000000000000000
a944499900a90004990000a9990000a9944499900a99444999000000000000000000000000000000000000000000000000000000000000000000000000000000
a900049900a90000990000a9990000a9900049900a99000999000000000000000000000000000000000000000000000000000000000000000000000000000000
a900009900a90000990000a9990000a9000009900a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900004990a9000099000a90099000a9000004400a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900000990a9000099000a90099000a9000000000a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900000990a9000099000a90099000a9000000000a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900000990a9000990000a9aa99000a9000000000a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900000990a9aaa99000a994499900a90000aaa00a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900000990a944990000a990049900a9000099900a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a900009900a900499000a900009900a9000009900a90000099000000000000000000000000000000000000000000000000000000000000000000000000000000
a9000a9400a90009900a9900009990a9a00009900a99000a99000000000000000000000000000000000000000000000000000000000000000000000000000000
a9aaa94000a90004990a9900004990a99aaa99900a99aaa990000000000000000000000000000000000000000000000000000000000000000000000000000000
a999440000a90000990a900000099009999999000099999990000000000000000000000000000000000000000000000000000000000000000000000000000000
444400000044000044044000000440004444440000044444000000000000000333b3bbbb33bbbbbb33bbbbbb33bbbb333bbbbb33355333333555550000000000
aa00000aa00aaaaaa0000aaaaaaaa00aa0000000aa0000000000000000000033bbb3333333bbbbbbb3bbbbbb3bbbbbb33bbbb33bbb5533335533355000000000
a900000a900a99999a000a999999900a90000000a9000000000000000000003bbbb33bbbb33bbbbbb3bbbbb33bbbbbbb333333bbbbb555555333335000000000
a990000a900a944499900a944444400a90000000a9000000000000000000003bbbb3bbbbbb33bbbb333bbb33333bbbbb3bb33bbbbbb553335533335000000000
a990000a900a900049900a900000000a90000000a900000000000000000003333b33bbbbbbb333333333333bbb33bbbb3bbb33bbbb5533333555555000000000
a999000a900a900009900a900000000a90000000a900000000000000000033bb333bbbbbbb333bb333bb33bbbbb33bbb3bbbb355555333333533355000000000
a999000a900a900004990a900000000a90000000a90000000000000000033bbbbb3bbbbbb33bbbbb3bbbb33bbbbb33b33bbbbb55335533335533335000000000
a999900a900a900000990a9aaaaaa00a90000000a9000000000000000003bbbbbb3bbbb333bbbbbb3bbbbb33bbbb33333bbbbb53333555555333335000000000
a909900a900a900000990a999999900a90000000a9000000000000000003bbbb3333333333bbbbb33bbbbbb3bbbb3bbb33bbbb53333355355333335000000000
a909990a900a900000990a944444400a90000000a900000000000000055553333bb33bbb3bbbbbb333bbbbb33bbb3bbbb33bbb53333335335533355550000000
a900990a900a900000990a900000000a90000000a9000000000000005533533bbbb3bbbb3bbbbb33b33bbbb333333bbbbb33b555333355333553553355000000
a900999a900a900000990a900000000a90000000a90000000000000053335bbbbb33bbbb3bbbb33bbb33bb333bb33bbbbb335555533553333555533335500000
a9000999900a900009900a900000000a90000000a90000000000000353335bbbb33bbbbb3bb333bbbbb35553bbbb33bbbb355333555553333533553333500000
a9000499900a9000a9400a900000000a90000000a90000000000000353355bbbb33bbbb555533bbbbbbb5355bbbbb33bb5553333355555335533355333500000
a9000099900a9aaa94000a9aaaaaa00a9aaaaaa0a9aaaaaa00000003555555bb555bbb5533553bbbbbb55335bbbbb35555553333335335555333355333500000
a9000049900a999440000a999999900a99999990a999999900000000553335555355b55333353bbbbb5533355bbbb55333353333335333555333555533500000
4400000440044440000004444444400944444440444444440000000053333553333555333335555bb55333335bbbb53333355333335333355555533555500000
88222299a9a9a9a000000000000000000000000000000000000000005333353333335533335535555553333355bb553333335553335333335535533335520000
bbb229989a9a9a9a0ccccc0000000000000000000000000000000000533355333333533335533355355333335555553333335555555533335333553333520000
bbbbb9829ffff99900000c0000000000000000000000000000000000533555533335533335333353335533335533555333335533555533355333355333520000
bbbbbb52ffffff990000777000000000000000000000000000000000555533553355553355333353333533355333355533355333355555555333355535520000
bbbbbbb9fffffff900000c0000000000000000000000000000000000055333355553355353333553333555555333353555553333335333555533352555220000
33bbbbb96ef66fff00000c0000000000000000000000000000000000005333335533335553333553333553553333353335553333335333355533552222200000
bbbbbbb8feffffff00000c0000000000000000000000000000000000005553335333335355335555333533353333353333553333355333353555522522000000
bbbbbbbbfeefffff00000cccccc00000000000000000000000000000055555335333335335555535535533353333353333355333555533353355225552000000
00000000000000000000000000c00000000000000000000000000000053335535333355333555333555333355333553333355555553553553335255552000000
00000000000000000000000000c00000000000000000000000000000053333555533553333535333555333335555555333553355533355553335255552000000
00000000000000000000000000c00000000000000000000000000000053335533555533333335333535533335533555555533335533335255555255552000000
00000000000000000000000000c00000000000000000000000000000055335333333553353333535533533355333353335533333533335222222225522000000
00000000000000000000000007770000000000000000000000000000005555333333555553333555333555555333353333553333533335225255522220000000
00000000000000000000000000c00000000000000000000000000000005335333335533353333555333553355333353333553333553355255255552000000000
00000000000000000000000000ccccc0000000000000000000000000005335533355333355335535555533335533555333555335555552255255552000000000
00000000000000000000000000000000000000000000000000000000005333555555333355555333555333335555525555525555222222555255552000000000
00000000000000000000000000000000000000000000000000000000005533222225333552253333555333335222222222222252255255555225522000000000
0b000067760000b000000000000000c0000000000000000000000000000555255525535522253333525533355222225555525222555255552222220000000000
000007777770000000000000000000c0000000000000000000000000000000255522555222255335522555552252522555525525555255522000000000000000
000000e77e00000000000000000000c0000000000000000000000000000000225222222255225555255222222552552555225525555222220000000000000000
000000e77e00000000000000000070c0000000000000000000000000000000022222222225522252225555255552555222255525522222000000000000000000
00700e7777e007000000000ccccc7cc0000000000000000000000000000000000000044422222222222222255522555222255222220000000000000000000000
067ee770077ee7600000000c00007000000000000000000000000000000000000000000444442222222222222225552222222200000000000000000000000000
07777700007777700000000c00000000000000000000000000000000000000000000000000444444444442229822222992222200a0a0a0a00000000000000000
07777700007777700000000c00000000000000000000000000000000000000000000000000000044444444228822229922222200a9a9a9a00000000000000000
067ee770077ee7600007000c0000000000000000000000000000000000000000000000000000000004444455bbb229982222200a9a9a9a9a0000000000000000
00700e7777e007000cc7cccc00000000000000000000000000000000000000000000000000000000004445bbbbbbb982222220099ffff9990000000000000000
000000e77e0000000c0700000000000000000000000000000000000000000000000000000000000000444bbbbbbbbb5222992009ffffff999000000000000000
000000e77e0000000c00000000000000000000000000000000000000000000000000000000000000004bbbbb73bbbbb999920099cffc6ff99900000000000000
00000777777000000c000000000000000000000000000000000000000000000000000000000000000bbbbbbb33bbbbb982220099defdffff9990000000000000
0b000067760000b00c000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbb82222009ffeffffff9990000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbb2222009ffeefffff9999000000000000
0000000000000000000000000000000000000002200000000000000000000000000000000000000000bb66666bbbbbbb2220009fffffefff9990000000000000
00000000000000000000000000ccccc0000000022000000000000000000000000000000000000000000466666bbbbbbd22200099ffe8fff99990000000000000
00000070070000000000000000c00000000000088000000000000000000000000000000000000000000444d666bbbbd2222000999fffffe99900000000000000
000077b77b77000000000000077700000000000000000000000000000000000000000000000000000004444d66bbbbd2222000099efffe999000000000000000
0007b777777b70000000000000c000000000000000000000000000000000000000000000000000000004444d66bbbd22222000002feeef222282000000000000
00077770077770000000000000c000000000000000000000000000000000000000000000000000000004ddccccccccd22220000822fff2222822220000000000
007b77000077b7000000000000c00000000000222200000000000000000000000000000000000000000dcccccccccccdd2200022822222228222222000000000
00077000000770000000000000c0000002200022220002200000000000000000000000000000000000dcccccfacccccccc220022282222282222222200000000
000770000007700000000cccccc0000008800022220008800000000000000000000000000000000000dcccccaaccccccccd20022228222822222222220000000
007b77000077b70000000c00000000000000008888000000000000000000000000000000000000000dccccccccccccccccc20021222888222222222222000000
000777700777700000000c00000000000000000000000000000000000000000000000000000000000dcccccccccccccccccc00212228a8222222222222200000
0007b777777b700000000c0000000000000000000000000000000000000000000000000000000000ddccccccccccccc5ccccc021122888222221012222200000
000077b77b7700000000777000000000000000000000000000000000000000000000000000000000dcccc5ccfacccc555cccc021122222222211001222220000
000000700700000000000c0000000000000000022000000000000000000000000000000000000000dcccc5ccaacccc555ccccc21122222222211000122220000
00000000000000000ccccc0000000000000000022000000000000000000000000000000000000000cccc55cccccccc5555cccc21222222222218100112222000
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccc55ccccccccc5525cccc1822222222282210011222000
00000002200000000000000000000000000000000000000000000000000000000000000000000000cccc55ccccccccc55225ccb3282222228822221001222200
00000002200000000c000000000000000cccccccccccccc000000000000000000000000000000000bbb35dccfaccccc552223bbb22888888222222210ffff000
00000002200000000c000000000000000c777777777777c000000000000000000000000000000000bbbb5dccaaccccc55222bbbf22222222222122211feff000
00000002200000000c000000000000000c700000000007c0000000000000000000000000000000fab3bbddcccccccccc5222b3fe222222222221222211fff000
00000008800000000c070000000000000c700000000007c0000000000000000000000000000000a0b3bbddcccccccccc53222ee1222222222221122221ff0000
00000000000000000cc7ccccc00000000c700000000007c0000000000000000000000000000000a00904ddcccccccccc53b22001222222222222122221110000
000000000000000000070000c00000000c700000000007c00000000000000000000000000000009999044dccccc5cccc553b2201222222222222112222110000
022220000002222000000000c00000000c700000000007c00000000000000000000000000000000a00444dcccc55dccc553bbb12222222222222112222210000
088880000008888000000000c00000000c700000000007c00000000000000000000000000000000a44444dcccc55dcccc53bbb12222222222222111222110000
000000000000000000000000c00070000c700000000007c00000000000000000000000000000004a9444ddddcc55dddcc5233312222222222222111221100000
000000000000000000000000cccc7cc00c700000000007c00000000000000000000000000000444a444ddccccc55ccccc5222212222222222222111111000000
000000022000000000000000000070c00c700000000007c000000000000000000000000000000009990dccccc55cccccc50022112222222222111111dd000000
000000022000000000000000000000c00c700000000007c000000000000000000000000000000000000dccccd55ccccc550000d111222222111111dddd000000
000000022000000000000000000000c00c777777777777c0000000000000000000000000000000000000ddddd55cccdd5000066d111111111111066ddd000000
000000022000000000000000000000c00cccccccccccccc000000000000000000000000000000000000055555555555500000ddddd00000000000dddd0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010a06080c1700c1500c1350c1750c1750c1750c1700c1700c1000c1050c1000c1050c1000c1050c1000c1000c1000c1050c1000c1050c1000c1050c1000c1050c1000c105001000010000100001000010000100
010a06080c1700c1450c1700c1450c1700c1450c1700c1700c1000c1050c1000c1050c1000c1050c1000c1050c1000c1050010000100001000010000100001000010000000000000000000000000000000000000
0101000318735186450c1351863518755186351875518635187551863518755186351875518635007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010a06080c0700c0500c0350c0750c0750c0750c0700c0700c0000c0050c0000c0050c0000c0050c0000c0000c0000c0050c0000c0050c0000c0050c0000c0050c0000c005000000000000000000000000000000
01010020003720c3050c3000c3050a3720c3050c3000c3000c3000c305003720c3050c3000c305003720c3050a3720c3050030000300003000a3720030000300003000030000372003000030000300003000a372
010a06080c0700c0600c0500c0450c0700c0450c0700c0700c0000c0050c0000c0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000c0350c0750c0750c07500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000c1861500005000000000018615000050000000000186150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
011400200c8300c8200c8100013500125001150013000125001150013500125001150013000125001150c8300c8200c8100013500125001150c8300c8200c8100c8000c8000c8000010500105001050010000105
011400201fb101fb101fb1513015130151301513010130151301513015130151301515010150151501521b1521b1021b1515015150151501521b1521b1021b1523b0023b0023b051700517005170051700017005
011400140c61513b000061518f2018f2018f200c61513b000061518f2018f2018f2018f2018f2018f200c61513b000061518f2018f2018f2018f2018f2018f200c60513b0013b050c60513c0513c050c60513b00
01140020180201f0201f0201f0101f0101f0101f0121f0121f0152602026010260121f0201f0201f0101f0101f0101f0101f0101f0121f0152602026010280202900029002280052600026000260002600226002
01140020001351fe101fe1000135130150013500120130150ca150013500135130150013521e1021e100013515015001350013515015001150012521e1021e100010523e0023e000010517005001050010000105
011400200c8300c8200c8100013500125001150013000125001150c8300c8200c8100013000125001150013500125001150013500125001150c8300c8200c8100c8000c8000c8000010500105001050010000105
0114002023b1023b1023b1517015170151701517010170151701523b1023b1023b1521b1021b1021b1515015150151501515015150151501521b1021b1021b151200012005130051300513005130051300013005
01140020001351fe101fe100013513015001350012013015001150013500135130150013521e1021e100013515015001350013515015001150012521e1021e100010523e0023e000010517005001050010000105
0114002012010120151301513015130151301513010130151301513015130151301515010150151501521b1521b1021b1515015150151501521b1521b1021b1523b0023b0023b051700517005170051700017005
0114002029020290122802026020260102601026012260121f02518020180101f02526020260101f015240151f025260202601026010260102601226012260122600000000000000000000000000000000000000
011400200313522e1022e100313516015031350312016015031150313503135160150313523e1023e100313517015031350313517015031150312523e1023e100010523e0023e000010517005001050010000105
011400200313524e1024e100313518015031350312018015031150313503135180150313523e1023e100313517015031350313517015031150312523e1023e100010523e0023e000010517005001050010000105
011400201f02022020220102201022010220102201222012220152602026010260121f0201f0201f0101f0101f0101f0101f0101f0121f01529020290102b0202900029002280052600026000260002600226002
011400202602026012260121f0201f0101f0101f0121f0121f02526020260101f02524020240101f015240151f025260202602026020260102601226012260122600000000000000000000000000000000000000
0114002026020260151f0251d0251f0252602026020260102601226012260151ae100f8151be101be102602026012290252b0202b012290252602026012240250000000000000000000000000000000000000000
011400200a8351de101de100a835110150a9350a935110150a9350a9350a9351de10088351fe101fe10088350f0150893508935130150893508935089351be100000000000000000000000000000000000000000
01140020031351fe101fe1003135130150313503135130150313503135031351fe10021351de101de1002135110150213502135110150213505135051351de100000000000000000000000000000000000000000
0114002022030220251f0551d0551f05522030220302202022022220122201522e1022510225151f5151d5151f51522510225102251022512225122251522e100000000000000000000000000000000000000000
0114002022020220151f0251d0251f02522020220202201022012220122201522e1022510225151f5151d5151f51522510225102251022512225122251522e100000000000000000000000000000000000000000
0114002026020260151f0051f0201f0201f0101f0101f0101f0121f0121f0151ae100f8151be101be102602026012290252b0202b012290252602026012240250000000000000000000000000000000000000000
01140020001351fe101fe1000135130150013500135130150013500135001351fe10021351de101de1002135110150213502135110150213505135051151de100000000000000000000000000000000000000000
01140020001351fe101fe1000135130150013500135130150013500135001351fe100b83522e1022e100b835160150b9350b835160150b9350b9350b93522e100000000000000000000000000000000000000000
011400200b83522e1022e100b835160150b9350b835160150b9350b9350b93522e100983520e1020e10098351401509935098351401509935099350993520e100000000000000000000000000000000000000000
0114002022720227151f0051b7201b7101b7101b7101b7101b7121b7121b7121a7111971119710195151971019515197101971019710195151971019515195150000000000000000000000000000000000000000
011400200c61513b000061518f2018f2018f200c61513b000061518f2018f2018f200c615145152051518f201471518f200c6152051518f202071518f2018f200c60513b0013b050c60513c0513c050c60500000
0114002022725257251b7201b7101b7101b7101b7101b7101b7121b7121b7121a7111971119710195151971019515197101971019710195151971019515195150000000000000000000000000000000000000000
01140020177201e7201e7101e7101e7101e7101e7121e7121e7152572025710257121e7201e7101e7101e7101e7101e7101e7121e7121e7152572025712277201900000000000000000000000000000000000000
011400200713526e1026e10071351a01507135071201a01513a1507135071351a0150713527e1027e10071351b01507135071351b015139100712527e1027e100010523e0023e000010517005001050010000105
01140020287202871027720257202571025710257122571225710257102571525000250002ae102ae10250001e0151b0151b0151e015250052372023712257201900000000000000000000000000000000000000
011400200713528e1028e10071351c01507135071201c0150711507135071351c0150713527e1027e10071351b01507135071351b015071150712527e1027e100010523e0023e000010517005001050010000105
011400202672026710257202372023710237102371023710237122371223715250002500021e1021e1025000150151b0051b00515015250052300021e1021e101900000000000000000000000000000000000000
011400200413523e1023e100413517015041350412017015041150413504135170150413525e1025e100413519015041350413519015041150412525e1025e100010523e0023e000010517005001050010000105
0114002026e0023e1023e1017005170151700517005170150b0050b0050b005170150b00521e1021e100b005150150b0050b005150150b0050b00521e1021e101900000000000000000000000000000000000000
011400200413526e1026e10041351a01504135041201a0150411504135041351a0150413525e1025e100413519015041350413519015041150412525e1025e100010523e0023e000010517005001050010000105
010e00200503005020050150c0300c0200c0150c0300c0150503005020050150c0300c0200c0150c0300c0150303003020030150a0300a0200a0150a0300a0150303003020030150a0300a0200a0150a0300a015
010e00200c0331c715260000c0130c6151c7151c7150c0230c0331c7151a0050c0130c6150c0331c7150c0230c0330c0050c0050c0230c6150c005210000c0230c03300f3000f050c0230c6150c03300f300c023
010e00001a7301c7211c71530205157401574015730157201571015712157121c715000001c715000000000018500000001a71518505155051a715155051a715185001a715185001a7151a71500f051a7151a715
000e0000000001571500f300000000000157151571500f30000001571500f301571500000157151571500f3000f0000f30137150000000000137151370513715000001371500f30137151371500f301371513715
010e000000000000000000000000000000000000000000000000000000000001c715000001c715000000000018500000001a71518505155051a715155051a715185001a715185001a7151a715000001a7151a715
010200001d3551d7451d3351375513345137350070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0106000025043220431f0331c0331a023180231502312013110130e0130c0130a013070130301301013085010431709517053170a517063170b517073270c527083270d526093260e5260a3360f5360b33610536
0108000029c6129c6129c5128c5124c4123c4123c3121c311ec211dc211cc111cc111ac1117c1116c1114c1118c0018c0118c0118c0118c0118c0118c0118c0118c0118c0118c0118c0118c0118c0118c0118c01
010300002e3322b33128332263312333221331203321d3311b3221a3211932217321153221332112322103210e3120c3110b31209311073120631104312033110231201311013120031100300003000030000300
012200000fa2415a311fa4128a5108a0208a0208a0208a0201a0201a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a0200a02
0002000002215006200341500630052150063008415006300b215006400d415006401022500640124250065011225006400f425006400d2150064009415006300621500630054150063003215006300341500620
010c0000293302932529335293352e3302e3250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002b3352d3352f335303352f3352d3352b33500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
010100000c235183350c235183350c2351800500005000051822524325182252432518225183050c005180050c435182350c335184350c235180050c005180051842524325184252432518425243151841500005
010200000b2200c4200d3200e220103201142013320172201b3101f41023310272100000027220203201d4201932015220123200f4200d3200b2200a320084100731006210053100030000000000000000000000
0104000026147281472b1472814726137281372b1372813726027280272b0272802726717287172b7172871700300003000030000300003000030000300003000030000300003000030000300003000030000300
010200001d6651e655083410a4410b3410c4310d3310f43111321134211532117411193111b4111b3011d3011830510305163050f3050e3050d3050c3050b3050a30509305083050630505305043050000000000
01040000323303231037330373103b3303b3153c30537305343053230534305373053c30500305003050030500305003050030500305003050030500305003050030500305003050030500305003050030500305
010300002833529335303350e3050d3050c3050b3050a305093050830507305063050530504305033050230501305013050430503305013050730506305063050530504305043050330502305013050130501305
010100000c13500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 08 09 0a 3f
00 0d 0e 0a 3f
00 08 10 0a 3f
00 0d 0e 0a 3f
00 0c 0b 0a 3f
00 0f 11 0a 3f
00 12 14 0a 3f
00 13 15 0a 3f
00 0c 0b 0a 3f
00 0f 11 0a 3f
00 12 14 0a 3f
00 13 15 0a 3f
00 17 16 0a 3f
00 18 1a 0a 3f
00 17 1b 0a 3f
00 18 1a 0a 3f
00 1c 1a 0a 3f
00 1d 1a 0a 3f
00 1e 1f 20 3f
00 1e 21 20 3f
00 23 22 0a 3f
00 25 24 0a 3f
00 27 26 0a 3f
00 29 28 0a 3f
02 29 28 0a 3f
01 2a 2b 2c 2d
02 2a 2b 2e 2d
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
