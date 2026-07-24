pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- drop
-- a game by simon cambier

left, right, up, down, fire1, fire2 = 0, 1, 2, 3, 4, 5
black, dark_blue, dark_purple, dark_green, brown, dark_gray, light_gray, white, red, orange, yellow, green, blue, indigo, pink, peach =
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
-- ‹‘”ƒðŸ…¾—
f_collide = 0 -- flag 0: collision
f_broken = 1

tick = 1 / 60

base_speed = 5

-- M3X6 by daniel linssen
poke(0x5600, 4, 4, 7)
poke4(0x5700, unpack(split"0x0000.0000,0x0000.0000,0x0202.0202,0x0000.0200,0x0000.0505,0x0000.0000,0x0505.0705,0x0000.0507,0x0407.0106,0x0000.0203,0x0204.0100,0x0000.0401,0x0102.0502,0x0000.0305,0x0000.0102,0x0000.0000,0x0101.0102,0x0000.0201,0x0202.0201,0x0000.0102,0x0205.0000,0x0000.0005,0x0702.0000,0x0000.0002,0x0000.0000,0x0000.0102,0x0700.0000,0x0000.0000,0x0000.0000,0x0000.0200,0x0202.0404,0x0000.0101,0x0505.0506,0x0000.0305,0x0202.0302,0x0000.0702,0x0204.0403,0x0000.0701,0x0403.0403,0x0000.0304,0x0406.0505,0x0000.0404,0x0403.0107,0x0000.0304,0x0503.0106,0x0000.0605,0x0204.0407,0x0000.0202,0x0502.0506,0x0000.0305,0x0605.0503,0x0000.0304,0x0002.0000,0x0000.0002,0x0002.0000,0x0000.0102,0x0102.0400,0x0000.0402,0x0007.0000,0x0000.0007,0x0402.0100,0x0000.0102,0x0204.0403,0x0000.0200,0x0505.0506,0x0000.0601,0x0604.0300,0x0000.0705,0x0505.0301,0x0000.0705,0x0101.0600,0x0000.0701,0x0505.0604,0x0000.0705,0x0705.0600,0x0000.0601,0x0702.0204,0x0000.0202,0x0705.0600,0x0000.0304,0x0505.0301,0x0000.0505,0x0202.0002,0x0000.0202,0x0202.0002,0x0000.0102,0x0305.0101,0x0000.0505,0x0202.0202,0x0000.0402,0x0707.0300,0x0000.0507,0x0505.0300,0x0000.0505,0x0505.0600,0x0000.0305,0x0305.0700,0x0000.0101,0x0705.0600,0x0000.0404,0x0101.0600,0x0000.0101,0x0701.0600,0x0000.0304,0x0207.0202,0x0000.0202,0x0505.0500,0x0000.0705,0x0505.0500,0x0000.0205,0x0705.0500,0x0000.0507,0x0205.0500,0x0000.0505,0x0605.0500,0x0000.0304,0x0204.0700,0x0000.0701,0x0101.0103,0x0000.0301,0x0202.0101,0x0000.0404,0x0202.0203,0x0000.0302,0x0000.0502,0x0000.0000,0x0000.0000,0x0000.0403,0x0000.0201,0x0000.0000,0x0507.0506,0x0000.0505,0x0507.0503,0x0000.0705,0x0101.0106,0x0000.0701,0x0505.0503,0x0000.0305,0x0103.0107,0x0000.0701,0x0301.0106,0x0000.0101,0x0501.0106,0x0000.0705,0x0507.0505,0x0000.0505,0x0202.0207,0x0000.0702,0x0404.0407,0x0000.0304,0x0503.0505,0x0000.0505,0x0101.0101,0x0000.0701,0x0507.0705,0x0000.0505,0x0505.0503,0x0000.0505,0x0505.0506,0x0000.0305,0x0103.0507,0x0000.0101,0x0505.0506,0x0000.0403,0x0503.0507,0x0000.0505,0x0407.0106,0x0000.0304,0x0202.0207,0x0000.0202,0x0505.0505,0x0000.0705,0x0505.0505,0x0000.0205,0x0705.0505,0x0000.0507,0x0202.0505,0x0000.0505,0x0205.0505,0x0000.0202,0x0202.0407,0x0000.0701,0x0302.0204,0x0000.0402,0x0202.0202,0x0000.0202,0x0602.0201,0x0000.0102,0x0704.0000,0x0000.0001,0x0205.0200,0x0000.0000"))
-- poke(0x5f58,0x81)

-- game-wide options & values

control_classic = 1
control_mobile = 2

level_random = 1
level_daily = 2

options = {controls = control_classic, level = level_random}

player_color = white
bg_color = dark_blue

gs = nil -- game/global state

function log(str)
	printh(t() .. "\t" .. tostr(str))
end

--
-- simple ecs
-- https://github.com/namuol/pico8-ecs
--
ecs = {}

function containsall(e, keys)
	for _, name in pairs(keys) do
		if e[name] == nil then
			return false
		end
	end

	return true
end

function ecs.entitieswith(entities, componentnames)
	local results = {}
	for entity in all(entities) do
		if containsall(entity, componentnames) then
			add(results, entity)
		end
	end

	return results
end

function ecs.world()
	local world = {}

	local componentsbyname = {}
	function world.component(name)
		if not componentsbyname[name] then
			componentsbyname[name] = componentsbyname.size
		end

		return componentsbyname[name]
	end

	local entities = {}
	function world.addentity(components)
		local id = #entities + 1
		entities[id] = components
		return id
	end

	function world.removeentity(id)
		entities[id] = nil
	end

	function world.getcomponents(id)
		return entities[id]
	end

	function world.invoke(funcs)
		for func in all(funcs) do
			entities = func(entities)
		end
	end

	return world
end

function filtered_entities(entities, filters)
	return all(ecs.entitieswith(entities, filters))
end

function iterate()
	for y = 0, 16 do -- rows
		for x = 0, 16 do -- columns
			local tile = mget(x, y)
		end
	end
end

--
-- coroutines manager
--
local coroutines = {}

function addcoroutine(fn)
	local c= cocreate(fn)
	add(coroutines, c)
	return c
end

function startcoroutine(c)
	coresume(c)
end

function stopcoroutine(c)
	for k,v in ipairs(coroutines) do
		if c == v then coroutines[k] = nil break end
	end
end

function _coresolve()
	for co in all(coroutines) do
		if costatus(co) ~= "dead" then
			coresume(co)
		else
			stopcoroutine(co)
		end
	end
end

--[[
	Original: https://gist.github.com/tesselode/e1bcf22f2c47baaedcfc472e78cac55e
	moves rectangle A by (dx, dy) and checks for a collision
	with rectangle B.
	if no collision occurs, returns false.
	if a collision does occur, returns:
	- the time within the movement when the collision occurs (from 0-1)
	- the x component of the normal vector
	- the y component of the normal vector
	the goal is to find the time range in which rectangle A
	is overlapping rectangle B on the X axis, and the time range
	in which they overlap on the Y axis. when they're overlapping
	on both axes, that's when there's a collision, and the beginning
	of that time range is when the collision starts, which is
	what we want to return.
]]
function sweep(a, dx, dy, b)
	--[[
		first let's find out when the rectangles start and stop overlapping
		on the X axis.
	]]
	local entryTimeX, exitTimeX, entryTimeY, exitTimeY
	if dx == 0 then
		--[[
			if rectangle A isn't moving on the X axis and it's already overlapping
			rectangle B on the X axis, then we'll just say it started overlappnig
			forever ago and will never stop overlapping.
		]]
		if a.x < b.x + b.w and b.x < a.x + a.w then
			--[[
			if rectangle A isn't moving on the X axis *and* it's not already
			overlapping, then A will never collide with B, so we can just stop now.
		]]
			entryTimeX = -32767
			exitTimeX = 32767
		else
			return false
		end
	else
		--[[
			otherwise, we know that the amount of distance rectangle
			A has travel to overlap rectangle B on this axis is the
			distance between the near sides of the boxes.
			if A is moving right, then the distance is the left edge of
			B minus the right edge of A. if A is moving left, then it's
			the left edge of A minus the right edge of B.
		]]
		local entryDistanceX
		if dx > 0 then
			entryDistanceX = b.x - (a.x + a.w)
		else
			entryDistanceX = a.x - (b.x + b.w)
		end
		--[[
			once we have the distance rectangle A has to travel to overlap
			with rectangle B on the X axis, we can figure out the time it
			takes to overlap, which is distance / speed. in this case,
			speed is the amount we're travelling on the X axis in this
			movement, which is the absolute value of dx.
		]]
		entryTimeX = entryDistanceX / abs(dx)
		--[[
			as you might guess, the exit distance is the distance between the
			far sides of the rectangles.
		]]
		local exitDistanceX
		if dx > 0 then
			exitDistanceX = b.x + b.w - a.x
		else
			exitDistanceX = a.x + a.w - b.x
		end
		-- and the exit time is just distance / speed again
		exitTimeX = exitDistanceX / abs(dx)
	end
	-- now we'll do the same for the y-axis.
	if dy == 0 then
		if a.y < b.y + b.h and b.y < a.y + a.h then
			entryTimeY = -32767
			exitTimeY = 32767
		else
			return false
		end
	else
		local entryDistanceY
		if dy > 0 then
			entryDistanceY = b.y - (a.y + a.h)
		else
			entryDistanceY = a.y - (b.y + b.h)
		end
		entryTimeY = entryDistanceY / abs(dy)
		local exitDistanceY
		if dy > 0 then
			exitDistanceY = b.y + b.h - a.y
		else
			exitDistanceY = a.y + a.h - b.y
		end
		exitTimeY = exitDistanceY / abs(dy)
	end
	--[[
		now we have the separate time ranges when rectangles A and B
		overlap on each axis. the time range when they're actually colliding
		is when both time ranges overlap. if the time ranges never overlap,
		there's no collision. we can check this the same way we check
		for overlapping boxes.
	]]
	if entryTimeX > exitTimeY or entryTimeY > exitTimeX then
		-- log(entryTimeX..", "..exitTimeY.."\t\t"..entryTimeY..", "..exitTimeX)
		return false
	end
	--[[
		if they do collide, then the time when they start colliding must be
		the later of the two entry times. after all, upon the first entry time,
		the rectangles are only overlapping on one axis.
	]]
	local entryTime = max(entryTimeX, entryTimeY)
	--[[
		if the entry time is outside of the range 0-1, that means no collision
		happens within this span of movement.
	]]
	if entryTime < 0 or entryTime > 1 then
		return false
	end
	--[[
		the last step is to get the normal vector. the normal vector is a
		unit vector pointing left, right, up, or down that represents which
		way rectangle B would push rectangle A to stop it from moving.
		we know whether the collision is horizontal or vertical from which
		entry happens last, and we know the sign of the vector from the
		direction rectangle A moved.
	]]
	local normal_x, normal_y = 0, 0
	if entryTimeX > entryTimeY then
		normal_x = dx > 0 and -1 or 1
	else
		normal_y = dy > 0 and -1 or 1
	end
	return entryTime, normal_x, normal_y
end

function mset2x2(x,y,t)
	mset(x,y,t)
	mset(x+1,y,t+1)
	mset(x,y+1,t+16)
	mset(x+1,y+1,t+17)
end

function is_playing(i)
	for c=16,19 do
		if stat(c) == i then
      return true
    end
	end
	return false
end

--
-- screen shake https://www.lexaloffle.com/bbs/?tid=28306
--
shake_offset=0
function screen_shake(x,y)
	local fade = .90
	local offset_x = 16-rnd(32)
	local offset_y = 8-rnd(16)
	offset_x *= shake_offset
	offset_y *= shake_offset
	camera(x+offset_x/8,y+offset_y*2)
	shake_offset*=fade
	if shake_offset<0.05 then shake_offset=0 end
end

function strlen(str, nbspecialchars)
	return (#str-nbspecialchars)*4 + nbspecialchars*8
end

--
-- save score in persistent storage
--
function save_highscore(score)
	dset(0, score[1])
	dset(1, score[2])
end

--
-- retrieve score from persistent storage
--
function get_highscore()
	return {dget(0),dget(1)}
end

-- https://www.lexaloffle.com/bbs/?pid=22677
function add_points(points)
	score[1] += points
	while score[1] >= 1000 do
		score[1] -= 1000
		score[2] += 1
	end
end

function add_distance(dist)
	distance[1] += dist
	while distance[1] >= 1000 do
		distance[1] -= 1000
		distance[2] += 1
	end
end

function get_score(score)
	local padded_ones = tostr(flr(score[1]))
	while #padded_ones < 3 do padded_ones = "0"..padded_ones end
	-- local padded_ones = (#tostr(flr(score_ones)) == 2 and "0" or "00") .. flr(score_ones)
	-- local padded_thousands = (#tostr(score_thousands) == 2 and "0" or "00") .. score_thousands
	return (score[2] > 0 and score[2] or "") .. padded_ones
end

function round(num, numDecimalPlaces)
	numDecimalPlaces = min(numDecimalPlaces or 0, 2)
	local mult = 10^(numDecimalPlaces or 0)
	return flr(num * mult + 0.5) / mult
end

--
-- normalize a value
--
function norm(val, min, max)
	return mid(0, (val-min)/(max-min), 1)
end

local oldprint = print
function print(t,x,y,col1,col2)
	if col2 then
		for i=-1,1 do
			for j=-1,1 do
				oldprint(t, x+i, y+j, col2)
			end
		end
	end
	oldprint(t, x, y, col1)
end

function str_width(str)
	return print(str,0,-8)
end

function print_shade(t,x,y,col1,col2)
	print(t,x,y+1,col2)
	print(t,x+1,y+1,col2)
	print(t,x,y,col1)
end

function print_alt(t,x,y,col1,col2)
	print("\014"..t,x,y,col1,col2)
end

function print_alt_shade(t,x,y,col1,col2)
	print_shade("\014"..t,x,y,col1,col2)
end

function collides(x, y)
	return fget(mget(x, y), f_collide)
end

function get_velocity(vel, accel, friction, max)
	if accel ~= 0 then
		return mid(-max, vel + accel * tick, max)

	elseif friction ~= 0 then
		local delta = friction * tick
		if vel - delta > 0 then
			return vel - delta

		elseif vel + delta < 0 then
			return vel + delta

		else
			return 0
		end
	end
	return mid(-max, vel, max)
end

function set_state(state, ...)
	local args = {...}
	if gs and gs._leave then gs._leave() end
	gs = state
	if gs and gs._enter then gs._enter(unpack(args)) end
end

function get_player_entity()
	return {
		pc = true, -- player controlled
		palt = red,
		spr = 33,
		anims={
			idle={33},
			run={32, 33, 34, 35, 32, 36, 37, 38},
			fall={48, 48, 48, 49, 49, 49},
		},
		curr_anim="run",
		standing=false,
		last_bounce=0,
		flip=false,
		size = {x=2, y=4},
		offset = {x=3, y=4},
		pos = {x=7.5*8, y=0*8},
		speed = 100,
		accel = {x=0, y=0},
		vel = {x=0, y=0},
		maxvel = {x=50, y=300},
		friction = {x=75, y=0},
		bounciness = .35,
		min_bounce_vel = 40,
	}
end

function get_score_entity(x,y,score)
	return {
		_t=t(),
		pos={x=x,y=y},
		label=score,
		ttl=2
	}
end

function add_around(val, max)
	val += 1
	return val <= max and val or 1
end

function sub_around(val, max)
	val -= 1
	return val >= 1 and val or max
end

function sys_draw(entities)
	for e in filtered_entities(entities, {"pos", "spr"}) do
		if e.pc then
			pal(white, player_color)
		end
		if e.palt then
			palt(e.palt, true)
		end
		if e.pal then
			pal(e.pal[1], e.pal[2])
		end
		spr(e.spr, e.pos.x, e.pos.y, 1, 1, e.flip)
		pal(white, white)
		if e.palt then
			palt(e.palt, false)
		end
		if e.pal then
			pal(e.pal[1], e.pal[1])
		end
	end
	return entities
end

function sys_print(entities)
	for e in filtered_entities(entities, {"pos", "label"}) do
		print_alt(e.label, e.pos.x, e.pos.y, orange, black)
	end
	return entities
end

function sys_label(entities)
	for e in filtered_entities(entities, {"pos", "label", "_t"}) do
		local diff = 1-norm(t(), e._t, e._t+3)
		e.pos.y -= diff/8
	end
	return entities
end
function sys_ttl(entities)
	-- sprites
	for e in filtered_entities(entities, {"ttl"}) do
		e.ttl -= tick
		if e.ttl <= 0 then del(entities, e) end
	end
	return entities
end
function sys_input(entities)
	for e in filtered_entities(entities, {"accel", "pc", "speed"}) do
		e.accel = {x=0, y=0}

		if options.controls==control_classic then
			-- classic controls
			if btn(left) then e.accel.x = -e.speed end
			if btn(right) then e.accel.x = e.speed end
		else
			-- mobile controls
			if btn(left) or btn(right) or btn(up) or btn(down) then e.accel.x = -e.speed end
			if btn(fire1) or btn(fire2) then e.accel.x = e.speed end
		end
	end
	return entities
end
function sys_vel(entities)
	for e in filtered_entities(entities, {"accel", "vel", "maxvel"}) do
		e.friction = e.friction or {x=0,y=0}
		-- add gravity to y velocity
		e.vel.y += gravity * tick
		-- add the accel values
		e.vel.x = get_velocity(e.vel.x, e.accel.x, e.friction.x, e.maxvel.x)
		e.vel.y = get_velocity(e.vel.y, e.accel.y, e.friction.y, e.maxvel.y)
	end
	return entities
end
function sys_collision(entities)
	for e in filtered_entities(entities, {"accel", "vel", "pos", "size"}) do
		e.offset = e.offset or {x = 0, y = 0}
		-- build tables to check aabb sweeping
		local rectA = {
			x = flr(e.pos.x + e.offset.x),
			y = flr(e.pos.y + e.offset.y),
			w = e.size.x,
			h = e.size.y
		}
		local rectB = {x = nil, y = nil, w = 8, h = 8}

		e.collision = {}

		-- get "central" tile
		local cx, cy = round((e.pos.x + 4) / 8), round((e.pos.y + 4) / 8)
		-- check all surrounding tiles
		for j = cy - 1, cy + 1 do
			for i = cx - 1, cx + 1 do
				if not collides(i, j) then
					goto continue
				end
				rectB.x = i * 8
				rectB.y = j * 8
				-- check aabb collision between the player and the tile
				local entryTime, normal_x, normal_y = sweep(rectA, e.vel.x * tick, e.vel.y * tick, rectB)
				if entryTime then
					if normal_x ~= 0 and e.collision.x == nil then
						e.collision.x = {entryTime, normal_x, normal_y}
					end
					if normal_y ~= 0 and e.collision.y == nil then
						e.collision.y = {entryTime, normal_x, normal_y}
					end
					if normal_x ~= 0 or normal_y ~= 0 then
						e.collision.block = {i, j}
					end
				end
				::continue::
			end
		end
	end
	return entities
end

function sys_collision_response(entities)
	for e in filtered_entities(entities, {"collision", "min_bounce_vel", "bounciness", "vel", "pos", "offset"}) do
		for k,v in pairs({e.collision.x, e.collision.y}) do
			if k == nil then goto continue end
			local entry_time, normal_x, normal_y = v[1], v[2], v[3]
			if entry_time then

				-- sticky blood
				if e.sticky and e.vel then
					if normal_x ~= 0 then e.pos.x += e.vel.x * entry_time * tick end
					if normal_y ~= 0 then e.pos.y += e.vel.y * entry_time * tick end
					e.vel=nil
					goto continue
				end

				-- collision response on x axis
				if normal_x~=0 then
					if e.bounciness > 0 and abs(e.vel.x) > e.min_bounce_vel then
						e.vel.x *= -e.bounciness
					else
						e.vel.x *= entry_time
					end
				end

				-- collision response on y axis
				if normal_y~=0 then
					if e.pc then -- only the player can screen shake and explode blocks
						-- impact "force"
						local force = max(0,(e.vel.y-100)/110)
						-- splat the player
						if force>.1 then e.last_bounce=t() end
						-- explode blocks if the vel is high enough
						if e.vel.y>150 then
							-- screen shake
							shake_offset = force
							score_bonus(entities, e.pos.x, e.pos.y-16)
							destroy_block(e, e.collision.block[1], e.collision.block[2])
						end
						-- if we're not already playing the "explode" sfx,
						-- play a "bump" sfx
						-- elseif not is_playing(1) then
							if e.vel.y > 55 then
								sfx(0, 1)
							elseif e.vel.y > 40 then
								sfx(2, 1)
							end
						-- end
					end

					if e.bounciness > 0 and abs(e.vel.y) > e.min_bounce_vel then
						e.vel.y *= -e.bounciness
					elseif e.vel then -- FIXME: shouldn't check for e.vel, weird bug
						e.vel.y *= entry_time
					end
				end
			end
			::continue::
		end

		-- determine if standing on ground
		e.standing = e.vel and abs(e.vel.y)<.2

		-- clean the collision response
		e.collision = nil
	end
	return entities
end
function sys_move(entities)
	for e in filtered_entities(entities, {"pos", "vel"}) do
		e.pos.x += e.vel.x*tick
		e.pos.y += e.vel.y*tick

		e.pos.x = round(e.pos.x, 2)
		e.pos.y = round(e.pos.y, 2)
	end
	return entities
end
function sys_shift_entities(entities)
	for e in filtered_entities(entities, {"pos"}) do
		e.pos.y -= 8
	end
	return entities
end
function sys_clear(entities)
	for e in filtered_entities(entities, {"pos", "particle"}) do
		local y = e.pos.y - camera_y
		-- mostly to clean particles
		if y > 128 + 8 or y < -32 then
			del(entities, e)
		end
	end
	return entities
end

function sys_animate(entities)
	for e in filtered_entities(entities, {"vel", "anims", "flip", "spr"}) do
		e.last_bounce = e.last_bounce or 0
		e.anim_step = e.anim_step or 1
		local curr = e.curr_anim or "idle"
		local anim = e.anims[curr]

		-- flip
		if e.vel.x<0 then e.flip = true
		elseif e.vel.x>0 then e.flip = false end

		if not e.standing and t()-e.last_bounce<.5 then
			e.curr_anim="fall"
		else
			if abs(e.vel.x)<.2 and abs(e.vel.y)<.2 then
				e.curr_anim="idle"
			else
				e.curr_anim="run"
			end
		end

		-- animate step
		e.anim_step+=tick*20
		local i = flr(e.anim_step)
		if (i>#anim) then e.anim_step=1 i=1 end
		e.spr = anim[i]
	end
	return entities
end
function sys_gameover(entities)
	for e in filtered_entities(entities, {"pc", "pos"}) do
		local y = e.pos.y - camera_y
		if y > 128 + 8 or y < -32 then
			log("gameover")

			-- save highscore
			if options.level == level_daily then
				if score[2] > highscore[2] or score[2] == highscore[2] and score[1] > highscore[1] then
					save_highscore(score)
					highscore = get_highscore()
				end
			end
			-- remove player
			del(entities, e)

			-- show game over screen
			transition_to_gameover()
		end
	end
	return entities
end


function state_mainmenu()
	local menu = {}

	local lbl_x = 8
	local lbl_y = 8*7
	local lbl_hs = "highscore: "..get_score(highscore)

	function start_game()
		set_state(states.game)
	end

	function set_controls(option)
		options.controls=option
	end

	function set_level(option)
		options.level=option
	end

	local mitems = {
		{label="play", cb=start_game, desc="PRESS \015Ž\014 OR \015—\014 TO PLAY"},
		{
			label="level:   ",
			options={"RANDOM", "DAILY"},
			options_desc={
				"EACH RUN IS UNIQUE",
				"A RUN A DAY\nKEEPS THE BOREDOM AWAY"
			},
			selected=options.level,
			cb=set_level
		},
		{
			label="controls:",
			options={"CLASSIC", "MOBILE"},
			options_desc={
				" LEFT: \015‹\014\nRIGHT: \015‘",
				" LEFT: \015‹‘”ƒ\014\nRIGHT: \015Ž—"
			},
			selected=options.controls,
			cb=set_controls
		},
	}
	local curr_mitem = 1

	function menu._enter()
		world = ecs.world()
		lbl_hs = "hIGHSCORE: "..get_score(highscore)

		local p = get_player_entity()
		p.pc = false
		p.pos = {x=24*8+2, y=12}
		p.bounciness = 0.963
		world.addentity(p)
	end

	function menu._update()
		local curr = mitems[curr_mitem]

		-- activate menu item
		if btnp(fire1) or btnp(fire2) then
			if curr.cb then curr.cb() end
		end

		-- change selected menu item
		if btnp(up) then
			curr_mitem = sub_around(curr_mitem, #mitems)
		elseif btnp(down) then
			curr_mitem = add_around(curr_mitem, #mitems)
		end

		-- change selected option
		if curr.options then
			if btnp(left) then
				curr.selected -= 1
			elseif btnp(right) then
				curr.selected += 1
			end
		end

		if curr.selected then
			if curr.selected < 1 then curr.selected = #curr.options end
			if curr.selected > #curr.options then curr.selected = 1 end
		end
		if (curr.options) then
			curr.cb(curr.selected)
		end

		world.invoke({
			sys_vel,
			sys_collision,
			sys_collision_response,
			sys_move
		})
	end

	function menu._draw()
		cls()
		-- draw the map on the right, with the ball
		camera(16*8, 2*8)
		map(16, 0, 16*8+4, 0, 16, 24)
		world.invoke({sys_animate,sys_draw})

		-- reset the camera and draw the labels
		camera()

		-- menu items
		for i,v in ipairs(mitems) do
			local y = lbl_y+i*8
			local color2 = v.label == mitems[curr_mitem].label and red or nil
			print_alt_shade(v.label, lbl_x, y, white, color2)
			if v.options then
				print_shade(" \015‹\014 "..v.options[v.selected].." \015‘", lbl_x + (#v.label)*4, y, white, color2)
			end
		end

		-- option description
		local item = mitems[curr_mitem]
		if item.options_desc then
			local s = item.selected
			print_alt_shade(item.options_desc[s], lbl_x, 8*12, light_gray, dark_gray)
		elseif item.desc then
			print_alt_shade(item.desc, lbl_x, 8*12, light_gray, dark_gray)
		end

		-- print(lbl, lbl_x, lbl_y, white)
		-- highscore
		print_alt(lbl_hs, 64-(#lbl_hs*2), 120, orange)
		-- last score
		if score[1]>1 or score[2]>1 then
			print_alt("lAST SCORE: "..get_score(score), 1, 1, white, red)
		end
	end

	return menu
end
function state_game()
	local game = {}
	local player

	local dead = false
	local speed
	local over = 6
	local camera_bg = 0
	local bg_base_y = 24 -- first map row for bg
	local f_patterns = {
		{0b0000010100000101.1}, -- lcd 1
		{0b1111000000000000.1}, -- top to bottom
		{0b0100001001000010.1}, -- wiggle
		{0b0000111100001111.1}, -- blinds
		{0b0000001100110000.1}, -- 2x2 squares
		{0b1000000000000000.1}, -- party lights
		{0b1000010000100001.1}, -- rain up left
		{0b0001001001001000.1}, -- rain up right
		{0b1010000000001010.1}, --
		{0b0110100101100000.1}, -- jellyfish
		{0b0011001111001100.1}, -- checkered 2x
	}
	local f_pattern = {}

	local p_count=0
	local p_index=1

	local combo = 0
	local combo_timer = 0
	local blocks_broken = 0
	local blocks_destroyed = 0
	local max_combo = 0

	function game._enter()
		local date = stat(80)..stat(81)..stat(82)

		-- set the seed
		if options.level == level_daily then
			srand(date)
		else
			srand(date..stat(83)..stat(84)..stat(85))
		end

		world = ecs.world()

		player = get_player_entity()
		world.addentity(player)

		-- reset values
		dead = false
		camera_y = 0
		camera_bg = 0
		speed = base_speed
		score = {0, 0}
		bg_color = rnd({dark_blue, dark_purple, dark_green, dark_gray})

		combo = 0
		combo_timer = 0
		max_combo = 0
		blocks_broken = 0
		blocks_destroyed = 0

		repeat -- avoid wrong color pairings
			player_color = rnd({orange, yellow, green, blue, indigo, pink})
		until not (
			bg_color == dark_purple and (player_color == pink or player_color == indigo)
			or bg_color == dark_green and player_color == green
		)

		-- choose a pattern
		f_pattern = {}
		for p in all(rnd(f_patterns)) do -- copy it to not alter base table if the pattern changes later
			add(f_pattern, p)
			-- add(f_pattern, 0b0)
		end
		p_count=0
		p_index=1

		-- generate the background map
		generate_bg()

		-- generate the starting rows
		for y=0,16+over do
			if y == 4 then base_row(y)
			elseif y<8 then empty_row(y)
			elseif y>=8 then fill_row(y) end
		end

	end

	function game._update()
		world.invoke({
			sys_input,
			sys_vel,
			sys_collision,
			sys_collision_response,
			sys_move,
			sys_ttl,
			sys_label,
			sys_clear,
			sys_gameover
		})

		-- speed 45 is becoming hard to manage
		if not dead then
			if speed<45 then speed += tick * (10/speed) end
		end
		-- alter the base speed with a normalized value from player's pos
		local normalized_y = norm(player.pos.y, 40, 140)
		local alter = .8 + (normalized_y*.7) -- 0.8 - 1.5
		local unit = tick * speed * alter
		if not dead then
			add_points(unit)
			add_distance(unit)
		end

		-- fake infinite scroll for the foreground
		camera_y += unit
		if camera_y > over*8 then
			fill_row(17+over)
			shift_map()
			world.invoke({sys_shift_entities})
			camera_y -= 8
		end

		-- and for the background
		p_count += 1
		if p_count % 30 == 0 then
			p_index += 1
			if (p_index > #f_pattern) p_index = 1
		end

		camera_bg += unit/8
		if (camera_bg > 176) then -- lower limit of the map
			shift_bg_map()
			generate_bg(24+16, 63)
			camera_bg -= 176
			-- take 22 - 38
		end

		-- combo
		combo_timer -= tick
		if combo_timer <= 0 then
			combo = 0
		end
	end

	function game._draw()
		cls()

		-- background
		screen_shake(0, camera_bg)
		pal(dark_blue, bg_color)
		map(0, bg_base_y, 0, 0, 16, 38)
		fillp(f_pattern[p_index])
		camera()
		rectfill(0,0,128,128,black)

		-- draw foreground map
		palt(black, false)	-- disable transparency for blocks
		palt(red, true)			-- set transparency on red pixels
		-- camera(0, camera_y)
		screen_shake(0, camera_y)
		map(0, 0, 0, 0, 16, 24)
		-- reset transparency
		palt(black,true)
		palt(red,false)

		-- draw entities
		world.invoke({sys_print, sys_animate, sys_draw})

		-- print score
		screen_shake(0, 0)
		local lblscore = get_score(score)
		local lblbest = get_score(highscore)
		print_shade("score: "..lblscore, 1, 1, light_gray, dark_gray)

		-- print highscore if not a daily
		if options.level ~= level_daily then
			print(" best: "..lblbest, 1, 9, dark_gray, black)
		end
	end

	function game._leave()
	end

	---
	--- state related functions
	---

	function explode_block(i, j)
		local m = mget(i,j)
		local f = fget(m)
		if fget(m, f_broken) then
			log('destroy')
			-- destroy
			mset(i,j,0)
			blocks_broken += 1
		elseif fget(m, f_collide) then
			-- break
			mset(i,j,m+16)
			blocks_destroyed += 1
		end
	end

	function destroy_block(e, block_x, block_y)
		sfx(1)
		explode_block(block_x, block_y)
		make_particles(e.pos.x+e.offset.x, e.pos.y+e.offset.y, e.flip, e.vel.y)
	end

	function score_bonus(entities, x, y)
		combo += 1
		combo_timer = 2
		max_combo = max(max_combo, combo)
		local bonus = 50*(2^(combo-1))
		add(entities, get_score_entity(x, y, bonus.."PTS"))
		add_points(bonus)
	end

	function generate_bg(from, to)
		from = from or 24
		from += from%2
		to = to or 63
		-- clear
		for x=0,15 do
			for y=from,to do
				mset(x,y,0)
			end
		end
		-- set tiles
		local success=0
		for y=from,to,2 do
			for x=0,15,2 do
				if rnd(1)<.6 and success<rnd(4) then
					success+=1
					mset2x2(x,y,rnd({
						--64,66,68,70,72,
						-- 68, 70, 72, 74,
						96,98,100,102,
						--104,106
					}))
				else
					success = 0
				end
			end
		end
	end

	function get_particle(x,y)
		return {
			particle=true,
			spr=rnd({16,16,16,24,25,26}),
			offset={x=4,y=7},
			pos = {x=x, y=y},
			accel = {x=0, y=0},
			vel = {x=rnd(200)-100, y=-rnd(50)-25},
			maxvel = {x=50, y=300},
			size={x=1,y=1},
			friction = {x=20, y=0},
			min_bounce_vel=0,
			bounciness=0
		}
	end

	function make_particles(x, y, flip, vel)
		-- stone chips
		for _=1,rnd(10)+10 do
			local particle=get_particle(x,y)
			world.addentity(particle)
		end

		-- spitting blood
		local blood = 10
		for i=1,blood do
			local particle=get_particle(x,y)
			particle.pal={red, player_color}
			particle.sticky=true
			particle.spr=50
			particle.vel.x=(rnd(100))*(flip and -1 or 1)
			particle.vel.y=-rnd(50)-50
			particle.friction.x=0
			world.addentity(particle)
		end

		-- some blood on the block
		for i=1,3 do
			local particle=get_particle(x,y)
			particle.pal={red, player_color}
			particle.sticky=true
			particle.spr=50
			particle.vel={x=0,y=0}
			particle.pos.y=y-3
			particle.pos.x+=rnd(4)-2
			world.addentity(particle)
		end
	end

	function transition_to_gameover()
		dead = true
		-- accelerate background scrolling
		local it = t()
		local c = addcoroutine(function()
			local duration = 2
			repeat
				speed += tick*speed*4
				duration -= tick
				shake_offset = (t()-it)*2
				yield()
			until duration <= 0

			set_state(states.gameover, score, blocks_broken, blocks_destroyed, max_combo)
		end)
		startcoroutine(c)
	end

	--
	-- clear a row of all tiles
	--
	function empty_row(y)
		for x=0,15 do
			mset(x, y, 0)
		end
	end

	--
	-- base 2 blocks that start the game
	--
	function base_row(y)
		for x=0,15 do
			if (x == 7 or x == 8) then mset(x, y, rnd({2,3,4,5}))
			else mset(x, y, 0) end
		end
	end

	--
	-- place random collidable blocks
	--
	function fill_row(y)
		-- reduce the width to augment difficulty with score
		local margin = min(score[2], 4)
		for x=0,15 do
			if x<=margin or x>=15-margin then mset(x,y,0)
			else
				local t = rnd({2,3,4,5})
				if (rnd(5)<=score[2]+1) t+=16 -- chance to have an already broken block
				if rnd(1) > 0.93 then mset(x,y, t) else mset(x, y, 0) end
			end
		end
	end

	function shift_map()
		for y=0,17+over do
			for x=0,15 do
				mset(x,y-1, mget(x,y))
			end
		end
	end

	function shift_bg_map()
		for y=0, 15 do
			local j = y+bg_base_y+22
			for x=0,15 do
				local t = mget(x,j)
				mset(x, bg_base_y+y, t)
			end
		end
	end

	return game
end
function state_gameover()
	local state = {}
	local lbl_score = ""
	local lbl_gameover = ""
	local lbl_distance = ""
	local center_x = 0
	local blocks_broken = 0
	local blocks_destroyed = 0
	local max_combo = 0
	local camera_y = -192
	local scroll = true

	local x_lbl = 24
	local y_lbl = 16
	local x_val = x_lbl + 72

	local menu = {"try again", "back to menu"}
	local selected = 1

	function state._enter(score, b_broken, b_destroyed, m_combo)
		scroll = true
		blocks_broken = b_broken
		blocks_destroyed = b_destroyed
		max_combo = m_combo
		lbl_score = get_score(score)
		lbl_distance = get_score(distance)
		selected = 1

		if options.level == level_daily then
			lbl_gameover = "dAILY RUN OVER"
		else
			lbl_gameover = "rUN OVER"
		end
		center_x = 64-#lbl_gameover*2
		shake_offset = 30
	end

	function state._update()
		if camera_y >= 0 then
			scroll = false
			camera_y = 0
		elseif scroll then
			camera_y += 5
		end
		screen_shake(0, camera_y)
		-- camera(0, camera_y)

		if btnp(fire1) or btnp(fire2) then
			if selected == 1 then
				set_state(states.game)
			else
				set_state(states.mainmenu)
			end
		end
		if btnp(up) or btnp(down) then
			selected = add_around(selected, #menu)
		end
	end

	function state._draw()
		cls()
		print_alt(lbl_gameover, center_x, y_lbl, bg_color, white)

		print_alt("bROKEN BLOCKS:", x_lbl, y_lbl+16, white)
		print_alt(blocks_broken, x_val, y_lbl+16, player_color)

		print_alt("dESTROYED BLOCKS:", x_lbl, y_lbl+24, white)
		print_alt( blocks_destroyed, x_val, y_lbl+24, player_color)

		print_alt("dISTANCE:", x_lbl, y_lbl+32, white)
		print_alt(lbl_distance.."M", x_val, y_lbl+32, player_color)

		print_alt("mAXIMUM COMBO:", x_lbl, y_lbl+40, white)
		print_alt(max_combo, x_val, y_lbl+40, player_color)

		print_alt("tOTAL SCORE:", x_lbl, y_lbl+52, player_color)
		print_alt(lbl_score, x_val, y_lbl+52, player_color)

		for i, item in ipairs(menu) do
			local curr = i == selected
			print_alt(item, 16, 100+(i-1)*10, white, curr and red or nil)
		end
		-- print_alt("tRY AGAIN. \015Ž —\014", 1, 112, white)
	end

	function state._leave()
	end

	return state
end

function _init()
	cartdata("scambier_drop_1")
	highscore = get_highscore()
	world = {}
	iterate()
	-- game-related globals
	camera_y = 0
	camera_bg = 0
	gravity = 240
	score = {0, 0}
	distance = {0, 0}

	-- gamestates
	states = {
		mainmenu = state_mainmenu(),
		game = state_game(),
		gameover = state_gameover()
	}
	-- activate mouse
	-- poke(0x5F2D, 0x1)
	log("")
	log("start game")
	set_state(states.mainmenu)
end

function _update60()
	tick = 1 / stat(7)
	_coresolve()
	gs._update()
end

function _draw()
	gs._draw()
	pal()
	-- draw mouse cursor
	-- pset(stat(32), stat(33), blue)
	-- print(stat(7), 0, 120, stat(7) >= 60 and green or red, black)
	-- print(flr(stat(1) * 100) .. "%", 15, 120, stat(1) > .8 and red or stat(1) > .5 and orange or green, black)
end

__gfx__
00000000000000006666666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006000000660000006600000066000000600000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000990006000000660666606606666066006660600000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000009099006066660660000006606006066000060600000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000009999006066660660000006606006066060000600000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000990006000000660666606606666066066600600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006000000660000006600000066000000600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006666666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006668666666668666666866666668666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006008000660008006600000066000000600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006000000660606006606606886006600600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006066000660000006606000068880000600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008066600668000006888000068060000800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008000800680606606806666066066608800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008000800880000008600000086000080600000000000000000000000000060000000060000000000000000000000000000000000000000000
00006000000000006868666886668668686666686866866800000000000000000006600000066000000660000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000088880000888800008888000088880000888800000000000000000000000000000000000000000000000000000000000000000000000000
00888800008778000087788000877880088778000887780008877800000000000000000000000000000000000000000000000000000000000000000000000000
00877800008778000087778008877780087778000877788008777880000000000000000000000000000000000000000000000000000000000000000000000000
00877800008778000887778008777780087778000887778008777780000000000000000000000000000000000000000000000000000000000000000000000000
00877800008778000878788008888780088778000878788008888780000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08777780878777800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0877778088777780000080000000d0000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01101111000010100111111000111110011111000011111001111100001111100011111111111100000001111110000000000000000000000000000000000000
10000000000000011111111110111111100000100100000111111110011111110111111111111110000111111111100000000000000000000000000000000000
10000000000000011110000111000011100000100100000111111110011111111111011111101111001111111111110000000000000000000000000000000000
00001100001100010110110000100001100000100100000111111110011111111111011111101111011111111111111000000000000000000000000000000000
00010010010010000101001001001001100000100100000111111110011111111111011111101111011111111111111000000000000000000000000000000000
10010000000010011101001000001001100001100110000111111110011111110111111111111110111111111111111100000000000000000000000000000000
11001000000100011100110000010001011111000011111001111100001111100011111111111100111111111111111100000000000000000000000000000000
11100000000000011100000000000001000000000000000000000000000000000001111111111000111111111111111100000000000000000000000000000000
11100000000000001100000000000001000000000000000000000000000000000011111111111100111111111111111100000000000000000000000000000000
11101000000100001100110000010001011111000011111001111100001111100111111111111110111111111111111100000000000000000000000000000000
11110000000010001101000001001001100001100110000111111110011111111111111111111111111111111111111100000000000000000000000000000000
01110010010010010101001001001001100000100100000111111110011111111110001111000111011111111111111000000000000000000000000000000000
01101100001100010100110000110001100000100100000111111110011111111111111111111111011111111111111000000000000000000000000000000000
01110000000000010100000000000001100000100100000111111110011111110111111111111110001111111111110000000000000000000000000000000000
11111111000000011111111100000001100000100100000111111110011111110011111111111100000111111111100000000000000000000000000000000000
00000111110011100111111111001110011111000011111001111100001111100000000000000000000001111110000000000000000000000000000000000000
00111111111111000011111111111100001111111111110000111111111111000111111111111110011111111111111000000000000000000000000000000000
00111111111111000011111111111100001111111111110000111111111111001111111111111111111111111111111100000000000000000000000000000000
11000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001100000000000000000000000000000000
11000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001100000000000000000000000000000000
11000000000000111100111111110011110011111111001111001111111100111100000111110011110011011111001100000000000000000000000000000000
11000000000000111100111111110011110011111111001111001111111100111100000111110011110011011111001100000000000000000000000000000000
11001111111100111100000000000011110011000011001111000000001100111100000000110011110000000011001100000000000000000000000000000000
11001111111100111100000000000011110011000011001111000000001100111100110000110011110011000011001100000000000000000000000000000000
11001111111100111100000000000011110011000011001111001100000000111100110000110011110011000011001100000000000000000000000000000000
11001111111100111100000000000011110011000011001111001100000000111100110000000011110011000000001100000000000000000000000000000000
11000000000000111100111111110011110011111111001111001111111100111100111110110011110011111011001100000000000000000000000000000000
11000000000000111100111111110011110011111111001111001111111100111100111110110011110011111011001100000000000000000000000000000000
11000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001100000000000000000000000000000000
11000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001100000000000000000000000000000000
00111111111111000011111111111100001111111111110000111111111111001111111111111111111111111111111100000000000000000000000000000000
00111111111111000011111111111100001111111111110000111111111111000111111111111110011111111111111000000000000000000000000000000000
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
0000010101010000000000000000000000000303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000202030000050202000004040002040200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000205000200030003000200030003000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000202000500020400000500020003050200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000204030400040002000302000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000006050080500a0400d050111500e0500e050120500e0500d05009050000500001000010000100d10009100041000210003500055000860000000000000000000000000000000000000000000000001000
00020000066400664006650086000a65009650086500f60007650066501160007650076500b6500d6000b65009650046000461004610016100061001610016000160001600016000060000600016000060000600
000100000000004050040500405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
