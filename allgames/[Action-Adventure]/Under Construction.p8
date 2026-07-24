pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
-- under construction
-- by glip and eevee

-- this is pretty stripped down
-- to fit the compressed limit.
-- original cart:
-- https://c.eev.ee/under-construction/under-construction.p8

animframedelay = 4

minfrac = 0.0000152587890625

function ceil(n)
	return flr(n + 1 - minfrac)
end

function merge(a, b)
	for k, v in pairs(b) do
		a[k] = v
	end
	return a
end

function sort(l, kf)
	local k = {}
	kf = kf or function(v) return v end
	for i = 1, #l do
		k[i] = kf(l[i])
	end
	for i = 2, #l do
		local j = i
		while j > 1 and k[j - 1] > k[j] do
			k[j], k[j - 1] = k[j - 1], k[j]
			l[j], l[j - 1] = l[j - 1], l[j]
			j -= 1
		end
	end
end

function perlin(xdim, ydim)
	local cos, rnd, sin = cos, rnd, sin
	local function s(t)
		return t * t * t * (6 * t * t - 15 * t + 10)
	end
	local function lerp(t, a, b)
		return a + t * (b - a)
	end
	local s2 = sqrt(0.5)
	local g = {}
	for x = 1, xdim do
		local row = {}
		g[x] = row
		for y = 1, ydim do
			local angle = rnd(1)
			row[y] = {
				cos(angle), sin(angle)}
		end
		row[0] = row[ydim]
	end
	g[0] = g[xdim]

	return function(x, y)
		local x1 = min(flr(x), xdim - 1)
		local y1 = min(flr(y), ydim - 1)
		local x2, y2 = x1 + 1, y1 + 1
		local gx1, gx2 = g[x1], g[x2]
		local dx1, dx2, dy1, dy2 =
			x - x1, x - x2,
			y - y1, y - y2
		local sy = s(dy1)
		local n = lerp(
			s(dx1),
			lerp(sy,
				gx1[y1][1] * dx1 +
				gx1[y1][2] * dy1,
				gx1[y2][1] * dx1 +
				gx1[y2][2] * dy2),
			lerp(sy,
				gx2[y1][1] * dx2 +
				gx2[y1][2] * dy1,
				gx2[y2][1] * dx2 +
				gx2[y2][2] * dy2))
		return s(
			n * s2 + 0.5)
	end
end

font_height = 6
font_width = 4
function printat(lines, anchor, a, c, borderc, bgc)
	local va = sub(a, 1, 1)
	local ha = sub(a, 2, 2)
	local vm = ({t=0, m=0.5, b=1})[va]
	local hm = ({l=0, m=0.5, r=1})[ha]

	if type(lines) == "string" then lines = {lines} end
	local th = #lines * font_height - 1
	local y = anchor.y - th * vm

	if borderc or bgc then
		local maxlen = 0
		for line in all(lines) do
			maxlen = max(maxlen, #line)
		end
		local maxw = font_width * maxlen - 1

		local x = flr(anchor.x - maxw * hm)
		local rx, ry, rw, rh =
			x - 4, y - 4,
			x + maxw + 3, y + th + 3
		if bgc then
			rectfill(rx, ry, rw, rh, bgc)
		end
		if borderc then
			rect(rx, ry, rw, rh, borderc)
		end
	end

	for line in all(lines) do
		local tw = font_width * #line - 1
		local x = anchor.x - tw * hm
		print(line, x, y, c)
		y += font_height
	end
end

function class(base, proto)
	proto = proto or {}
	proto.__index = proto
	local meta = {}
	setmetatable(proto, meta)
	if base then
		meta.__index = base
	end
	function meta:__call(...)
		local this = setmetatable({}, self)
		if this.init then
			this:init(...)
		end
		return this
	end
	return proto
end

vec2 = class()

function vec2:init(x, y)
	self.x = x or 0
	self.y = y or 0
end

function vec2:copy()
	return vec2(self.x, self.y)
end

function vec2:__add(other)
	return vec2(
		self.x + other.x,
		self.y + other.y)
end

function vec2:__mul(n)
	return vec2(
		self.x * n,
		self.y * n)
end

function vec2:__sub(other)
	return self + other * -1
end

function vec2:elemx(other)
	return vec2(
		self.x * other.x,
		self.y * other.y)
end

function vec2:at(anchor)
	return box(
		anchor.x, anchor.y,
		self.x, self.y)
end

function vec2:max()
	return max(self.x, self.y)
end

box = class()

function box:init(l, t, w, h)
	if w < 0 then
		l += w
		w *= -1
	end
	if h < 0 then
		t += h
		h *= -1
	end
	self.l = l
	self.t = t
	self.w = w
	self.h = h
end

function box.__index(self, key)
	if key == "r" then
		return self.l + self.w
	elseif key == "b" then
		return self.t + self.h
	else
		return box[key]
	end
end

function box:__add(offset)
	return box(self.l + offset.x, self.t + offset.y, self.w, self.h)
end

function box:overlaps(other)
	return (
		self.l < other.r and
		self.r > other.l and
		self.t < other.b and
		self.b > other.t
	)
end

function box:dist(other)
	local x, y
	if self.l < other.l then
		x = other.l - self.r
	else
		x = self.l - other.r
	end
	if self.t < other.t then
		y = other.t - self.b
	else
		y = self.t - other.b
	end
	return vec2(x, y)
end

actor = class{
	enabled = true,
	pose = "default",
	poses = {},
	shape = box(0, 0, 1, 1),
}

function actor:init(pos)
	self.pos = pos
	self:reset()
end

function actor:reset()
	self:set_pose"default"
end

function actor:blocks()
	return fget(self.sprite:current(), 7)
end

function actor:coll()
	return self.shape + self.pos
end

function actor:oncollide(other, delta)
end

function actor:update()
end

function actor:draw()
end

function actor:set_pose(pose)
	if self.poses[pose] then
		self.pose = pose
		self:set_sprite(self.poses[pose])
	end
end
function actor:set_sprite(s)
	self.sprite = to_sprite(s)
end

mobactor = class(actor, {
	is_mobile = true,
	min_speed = 0.015625,
	max_speed = 0.25,
	friction = 0.625,
})

function mobactor:init(pos)
	self.pos0 = self.pos0 or pos
	actor.init(self, pos)
end

function mobactor:reset()
	actor.reset(self)

	self.pos = self.pos0
	self.vel = vec2()
	self.facing_right = false
	self.ground = true
end

function mobactor:blocks()
	return true
end

gravity = 1/32
terminal_velocity = 7/8

function mobactor:update()
	local abs, vec2 = abs, vec2

	local v = self.vel
	local friction = self.friction
	if not self.ground then
		friction = 1 - (1 - friction) / 2
	end
	v.x *= friction
	if abs(v.x) > self.max_speed then
		v.x = sgn(v.x) * self.max_speed
	elseif abs(v.x) < self.min_speed then
		v.x = 0
	end
	v.y = min(
		v.y + gravity,
		terminal_velocity)

	local prevx = self.prevx or 0
	self.prevx = v.x
	if v.x ~= 0 then
		self.facing_right = v.x < 0
	end
	if v.y ~= 0 then
		self.ground = false
	end

	local move = v:copy()

	if abs(v.x) < abs(prevx) then
		local goalx = self.pos.x + move.x
		local d1 = goalx - flr(goalx + 0.5)
		if abs(d1) < 1/16 then
			move.x -= d1
		end
	end

	local coll = self:coll()
	local delta = vec2(
		abs(move.x),
		abs(move.y))
	local sign = vec2(
		sgn(move.x),
		sgn(move.y))

	local nearx = sign.x > 0 and "r" or "l"
	local neary = sign.y > 0 and "b" or "t"
	local boundx = abs(curzone.box[nearx] - coll[nearx])
	if delta.x > boundx then
		delta.x = boundx
		v.x = 0
	end
	local boundy = abs(curzone.box[neary] - coll[neary])
	if delta.y > boundy then
		if v.y > 0 then
			self.ground = true
		end
		delta.y = boundy
		v.y = 0
	end

	local blockers = {}
	local moverange = coll + vec2()
	if sign.x > 0 then
		moverange.w += delta.x
	else
		moverange.l -= delta.x
	end
	if sign.y > 0 then
		moverange.h += delta.y
	else
		moverange.t -= delta.y
	end
	local function add_blocker(other)
		if not other.enabled then
			return
		end
		if other.oncollide == actor.oncollide and not other:blocks() then
			return
		end
		local otherbox = other:coll()
		if not coll:overlaps(otherbox) and moverange:overlaps(otherbox) then
			local dist = coll:dist(otherbox)
			local order = dist.x * delta.y + dist.y * delta.x
			add(blockers, {
				actor = other,
				dist = dist,
				order = order,
				coll = otherbox,
			})
		end
	end
	for actor in all(curzone.mobs) do
		if actor ~= self and
			abs(self.pos.x - actor.pos.x) + abs(self.pos.y - actor.pos.y) <= 8
		then
			add_blocker(actor)
		end
	end
	for x = flr(moverange.l), ceil(moverange.r) do
		for y = flr(moverange.t), ceil(moverange.b) do
			add_blocker(curzone:tile(vec2(x, y)))
		end
	end
	sort(blockers, function (blocker)
		return blocker.order
	end)
	local movedby = vec2()

	for blocker in all(blockers) do
		local dist = blocker.dist - movedby
		dist.x = max(0, dist.x)
		dist.y = max(0, dist.y)
		local ymult = delta.y * dist.x
		local xmult = delta.x * dist.y
		local step = dist:copy()
		if dist.x == 0 or dist.y == 0 then
		elseif ymult > xmult then
			step.y = delta.y * dist.x / delta.x
		elseif xmult > ymult then
			step.x = delta.x * dist.y / delta.y
		end

		delta -= step
		movedby += step
		coll += (step:elemx(sign))

		local newdist = coll:dist(blocker.coll)
		local touchx = newdist.x == 0
		local touchy = newdist.y == 0
		if touchx or touchy then
			if touchx and touchy then
				if delta.x > delta.y then
					touchx = false
				else
					touchy = false
				end
			end

			local force = move:copy()
			if not touchx or delta.x == 0 then
				force.x = 0
			end
			if not touchy or delta.y == 0 then
				force.y = 0
			end
			blocker.actor:oncollide(self, force)

			if blocker.actor:blocks() then
				if touchx then
					delta.x = 0
					v.x = 0
				else
					delta.y = 0
					if v.y > 0 then
						self.ground = true
					end
					v.y = 0
				end
			end
		end
	end
	movedby += delta
	self.pos += (movedby:elemx(sign))

	local pose = "default"
	if not self.ground then
		if v.y <= 0 then
			pose = "jumping"
		else
			pose = "falling"
		end
	elseif v.x ~= 0 then
		pose = "walking"
	end
	self:set_pose(pose)
end

function mobactor:draw()
	self.sprite:drawat(self.pos, self.facing_right)
end

playeractor = class(mobactor, {
	is_player = true,

	xaccel = 0.125,
	max_jump_time = 4,
	yaccel = 19/128,
	aircontrol = 0.5,
})

function playeractor:reset()
	mobactor.reset(self)
	self.jumptime = 0
end

function playeractor:update()
	local xmult = 1
	if not self.ground then
		xmult = self.aircontrol
	end
	if btn(0) then
		self.vel.x -= self.xaccel * xmult
	elseif btn(1) then
		self.vel.x += self.xaccel * xmult
	end
	if btn(2) then
		if self.jumptime < self.max_jump_time then
			self.vel.y -= self.yaccel
			self.jumptime += 1
		end
	elseif self.ground then
		self.jumptime = 0
	else
		self.jumptime = 999
	end

	mobactor.update(self)
end

transientactor = class(actor, {
	is_transient = true,
})

function transientactor:init(...)
	actor.init(self, ...)
	if not self.sprite then
		self.sprite = to_sprite(
			mget(self.pos.x, self.pos.y))
	end
	self.enabled = fget(self.sprite:current(), progress.displayact - 1)
end

_tiledefs = {}

function declare_tile(data)
	if data.sprite then
		data.sprite = to_sprite(data.sprite)
	end
	if data.poses then
		for name, sprref in pairs(data.poses) do
			data.poses[name] = to_sprite(sprref)
		end
	end

	local sprite = data.sprite or (data.poses and data.poses.default)
	local for_tiles = data.for_tiles or sprite.frames

	local cls = data.class
	data.class = nil
	if cls then
	elseif data.reset or data.update or
		data.draw or data.poses or
		(sprite and #sprite.frames > 1)
	then
		cls = decoractor
	else
		cls = transientactor
	end

	class(cls, data)

	for _key, tileno in pairs(for_tiles) do
		if not _tiledefs[tileno] then
			_tiledefs[tileno] = class(
				data,
				{ sprite = to_sprite(tileno) })
		end
	end
end

_oneoff_actors = {}
function oneoff_actor(data)
	setmetatable(data, data.class or actor)
	add(_oneoff_actors, data)
	return data
end

decoractor = class(actor, {
	is_decor = true,
	_sprchange = false,
})

function decoractor:set_sprite(s)
	actor.set_sprite(self, s)
	mset(self.pos.x, self.pos.y, self.sprite:current())
	self._sprchange = true
end
function decoractor:reset()
	self.enabled = fget(self.sprite.frames[1], progress.displayact - 1)
	local t = 0
	if self.enabled then
		t = self.sprite:current()
	end
	mset(self.pos.x, self.pos.y, t)
end
function decoractor:update()
	if curtime % animframedelay == 0 or
		self._sprchange
	then
		mset(self.pos.x, self.pos.y, self.sprite:current())
		self._sprchange = false
	end
end

_tiletrans = {}

function declare_transparency(tiles)
	local trans = tiles.trans
	for tileno in all(tiles) do
		_tiletrans[tileno] = trans
	end
end

_spritedefs = {}
_spritedef = class()

function _spritedef:init(frames, skip)
	self.frames = frames
	self.skip = skip
end

function _spritedef:current()
	local time = curtime % (#self.frames * animframedelay)
	local frame = flr(time / animframedelay) + 1

	frame += self.skip
	if frame > #self.frames then
		frame -= #self.frames
	end

	return self.frames[frame]
end

function _spritedef:drawat(pos, hflip, vflip)
	local tileno = self:current()
	local trans = _tiletrans[tileno]
	if trans then
		palt(0, false)
		for c in all(trans) do
			palt(c, true)
		end
	end
	spr(tileno, pos.x * 8, pos.y * 8,
		1, 1, hflip, vflip)
	if trans then
		palt()
	end
end

function declare_sprite(args)
	local skip = 0
	for tileno in all(args) do
		_spritedefs[tileno] = _spritedef(
			args, skip)
		if args.name then
			_spritedefs[args.name] = _sprite[tileno]
		end
		skip += 1
	end

	return _spritedefs[args[1]]
end
function declare_sprites(defs)
	foreach(defs, declare_sprite)
end

function to_sprite(val)
	if type(val) == "number" then
		return _spritedefs[val]
			or declare_sprite{val}
	elseif type(val) == "string" then
		return _spritedefs[val]
	elseif #val > 0 then
		return declare_sprite(val)
	else
		return val
	end
end

function to_ramp(conv)
	local ret = {}
	for color = 0, 15 do
		local ramp = {}
		ret[color + 1] = ramp
		while color do
			add(ramp, color)
			color = conv[color + 1]
		end
	end
	return ret
end

blackramp = to_ramp{
	nil, 0, 0, 1,
	2, 1, 5, 6,
	2, 8, 9, 3,
	13, 5, 8, 14,
}
whiteramp = to_ramp{
	5, 12, 8, 5,
	9, 6, 15, nil,
	14, 10, 15, 10,
	6, 12, 15, 7,
}

function apply_ramp_fade(ramp, proportion)
	pal()
	for color = 0, 15 do
		local colorramp = ramp[color + 1]
		local slot = flr(#colorramp * proportion + 1)
		pal(color, colorramp[slot], 1)
	end
end

mapzone = class()

function mapzone:init(...)
	self.box = box(...)
	self.actors = {}
	self.mobs = {}
	self.decor = {}
end

function mapzone:tile(pos)
	local decor = self.decor[pos.y * 128 + pos.x]
	if decor then return decor end

	local tileno = mget(pos.x, pos.y)
	if _tiledefs[tileno] then
		return _tiledefs[tileno](pos)
	end

	return transientactor(pos)
end

function mapzone:set_tile(pos, tileno)
	local d = pos.y * 128 + pos.x
	if self.decor[d] then
		del(self.actors, self.decor[d])
		self.decor[d] = nil
	end

	mset(pos.x, pos.y, tileno)
end

function mapzone:reset()
	local mset, vec2 = mset, vec2
	if not self.inited then
		self.inited = true

		for x = self.box.l, self.box.r do
			for y = self.box.t, self.box.b do
				local tilecls = _tiledefs[mget(x, y)]
				if tilecls and
					not tilecls.is_transient
				then
					local actor = tilecls(
						vec2(x, y))
					add(self.actors, actor)
					if actor.is_mobile then
						mset(x, y, 0)
					end
				end
			end
		end

		for actor in all(_oneoff_actors) do
			add(self.actors, actor)
		end

		for actor in all(self.actors) do
			if actor.is_decor then
				self.decor[actor.pos.y * 128 + actor.pos.x] = actor
			elseif actor.is_mobile then
				add(self.mobs, actor)
			end
			if actor.is_player then
				player = actor
			end
		end
	end

	if progress.andre == 1 then
		local p = vec2(34, 54)
		self:set_tile(p, 97)
		p.x += 1
		p.y += 1
		self:set_tile(p, 97)
	elseif progress.andre == 2 then
		mset(34, 54, 0)
		mset(35, 55, 0)
		mset(34, 55, 109)
		mset(34, 56, 125)
	end
	mset(127, 16, progress.m and 95 or 0)
	progress.m = false
	mset(96, 58, progress.m2 and 95 or 0)
	progress.m2 = false
end

function mapzone:draw(cam, flag)
	flag = bor(flag or 0, shl(1, progress.displayact - 1))
	camera(cam.l * 8, cam.t * 8)

	local x = flr(cam.l)
	local y = flr(cam.t)
	map(x, y, x * 8, y * 8, 17, 17, flag)
end

scene = class{
	onenter = function() end,
	onexit = function() end,
	get_music = function() end,
}

function scene:init(obj)
	merge(self, obj or {})
end

curtime = 0
function scene:update()
	curtime = (curtime + 1) % 20160

	for layer in all(self.layers) do
		if layer.update then
			layer:update()
		end
	end
end

function scene:draw()
	local pal, camera = pal, camera
	cls()
	for layer in all(self.layers) do
		pal()
		camera()
		layer:draw()
	end
end

scenefader = class(scene)
function scenefader:init(newscene, duration, ramp)
	self.newscene = newscene
	self.oldscene = game.scene
	self.timer = 1
	self.duration = duration
	self.ramp = ramp or blackramp

	if not self.oldscene then
		self.reverse = true
	end
end
function scenefader:onenter()
	game:changemus(self.newscene:get_music(), self.duration)
end
function scenefader:update()
	self.timer += 1
	if self.timer >= self.duration then
		if not self.reverse then
			self.reverse = true
			self.timer = 1
		elseif self.timer > 0 then
			self.timer -= 1
			game:set_scene(self.newscene)
		end
	end
end
function scenefader:draw()
	rectfill(0, 0, 128, 128, 9)
	if self.reverse then
		self.newscene:draw()
	else
		self.oldscene:draw()
	end

	local prop = self.timer / self.duration
	if self.reverse then
		prop = 1 - prop
	end
	apply_ramp_fade(self.ramp, prop)
end

textscene = class(scene)

function textscene:init(texts, color)
	self.texts = texts
	self.color = color or 7
end
function textscene:draw()
	cls()
	pal()
	printat(self.texts, vec2(64, 64), "mm", self.color)
end

cam = box(0, 0, 16, 16)
margin = 6
map_layer = {
	update_camera = function(self)
		local b = curzone.box
		local focus = player:coll()
		cam.l = max(
			min(cam.l, max(b.l, focus.l - margin)),
			min(b.r, focus.r + margin) - cam.w)
		cam.t = max(
			min(cam.t, max(b.t, focus.t - margin)),
			min(b.b, focus.b + margin) - cam.h)
	end,
	reset = function(self)
		curzone:reset()
		for a in all(curzone.actors) do
			a:reset()
		end
		self:update_camera()
	end,
	update = function(self)
		for a in all(curzone.actors) do
			if a.enabled then
				a:update()
			end
		end
		self:update_camera()
	end,
	draw = function(self)
		curzone:draw(cam)
		for a in all(curzone.actors) do
			if a.enabled and
				a:coll():overlaps(cam)
			then
				a:draw()
			end
		end
	end,
}

game = {
	pending_scene = nil,
	scene = nil,
	curmusic = 20,
	taskhdl = 1,
	tasks = {},
}

function game:initialize()
	if self.curmusic then
		self:_music(self.curmusic)
	end

	for tileno, def in pairs(_spritedefs) do
		if type(tileno) == "number" and
			not _tiledefs[tileno] and
			(#def.frames > 1 or _tiletrans[tileno])
		then
			declare_tile{
				class = decoractor,
				sprite = def,
			}
		end
	end

	for t = 0, 127 do
		local flags = fget(t)
		if band(flags, 31) == 0 then
			fset(t, bor(flags, 31))
		end
	end

	map_layer:reset()
end

function game:schedule(tics, callback)
	local handle = self.taskhdl
	self.taskhdl += 1
	self.tasks[handle] = {
		time = tics,
		callback = callback,
	}
	return handle
end

function game:update()
	for handle, task in pairs(self.tasks) do
		task.time -= 1
		if task.time <= 0 then
			task.callback()
			self.tasks[handle] = nil
		end
	end

	if self.pending_scene then
		if self.scene then
			self.scene:onexit()
		end
		self.scene = self.pending_scene
		self.pending_scene = nil
		self.scene:onenter()
	end
	self.scene:update()
end

function game:draw()
	self.scene:draw()
end

function game:set_scene(scene)
	self.pending_scene = scene
end

function game:changemus(track, fadelen)
	track = track or -1
	if track == self.curmusic then
		return
	end
	if self.curmusic ~= -1 and track ~= -1 then
		self:_music(-1, fadelen)
		self:schedule(fadelen, function()
			self:_music(track, fadelen)
		end)
	else
		self:_music(track, fadelen)
	end
	self.curmusic = track
end
function game:_music(track, fadelen)
	if fadelen then
		fadelen = fadelen * 100 / 3
	end
	music(track, fadelen)
end

function _init()
	game:initialize()

	fog = {}
	local w, h = 4, 8
	local foggen = perlin(w, h)
	local fv = {}
	for x = 0, 127 do
		fv[x] = {}
		for y = 0, 127 do
			fv[x][y] = foggen(
				(x + 0.5) / 128 * w,
				(y + 0.5) / 128 * h)
			local fogval = (
				fv[x][y]
				+ fv[x % 64][y % 64] / 2
				+ fv[x % 32][y % 32] / 4
				) / 1.75
			if fogval > 0.5 then
				fog[y * 128 + x] = true
			end
		end
	end
end

function _update()
	game:update()
end

function _draw()
	game:draw()
end

progress = {
	act = 1,
	displayact = 1,
	fires = 0,
	fires0 = 0,
	clarity = 0,
	radios = 0,
	radios0 = 0,
	mr5loss = {0, 0, 0, 0},
	deaths = 0,
	all_deaths = 0,
	andre = 0,
}

acts = {
	{
		music = 0,
		start = "you open your eyes",
		death = function()
			if progress.deaths < 10 then
				return "you open your eyes again"
			else
				return "you open your eyes again?"
			end
		end,
	},
	{
		music = 16,
		start = "your head is pounding",
		death = function()
			local r = progress.radios / progress.radios0
			local l = progress.radios0 - progress.radios
			if progress.deaths < 10 then
				if l == 0 then
					return "your head is clear"
				elseif l <= 2 then
					return "your head is clearing"
				elseif r < 1 then
					return "your head is aching"
				else
					return "your head is pounding"
				end
			else
				if r < 1 then
					return {"you wish for relief", "from this noise"}
				else
					return "death is better than silence"
				end
			end
		end,
	},
	{
		music = 11,
		start = {"bodies around you", "writhe in agony"},
		death = function()
			if progress.deaths < 10 then
				if player.touched then
					return "you stop hurting"
				else
					return {"you don't want", "to feel like this"}
				end
			else
				if player.touched then
					return {"you end yourself", "as you've ended another"}
				else
					return {"each death feels", "more real than the last"}
				end
			end
		end,
	},
	{
		music = 24,
		start = "you smell smoke",
		death = function()
			local s = progress.fires / progress.fires0
			if progress.deaths >= 10 then
				return "your self-sacrifice failed"
			elseif s == 0 then
				return "you cough violently"
			elseif s < 0.5 then
				return "you start coughing"
			elseif s < 1 then
				return "you want to cough"
			else
				return "you can breathe again"
			end
		end,
	},
	{
		music = 0,
		start = "this is really familiar",
		death = function()
			if progress.deaths < 10 then
				return "wait, is it familiar?"
			else
				return "death is familiar"
			end
		end,
	},
}

act5_results = {
	bad = {
		music = 28,
		player_starts = {},
		end_texts = {
			{"don't ever bother", "looking for me"},
			"the static will always be there",
			"i still can't feel anything",
			"i'm suffocating again",
			"again again again again again",
		},
		epilogue = {
			"i hate how hard you tried;",
			"so very hard, and for what?",
			"you belong nowhere",
			"this wretched world is yours",
			"again",
		},
		epilogue_bg = 0,
	},
	ok = {
		music = 7,
		player_starts = {
			nil,
			vec2(24, 21),
			vec2(49, 22),
			vec2(88, 21),
			vec2(110, 21),
		},
		end_texts = {
			"i make out your silhouette",
			{"a scream echoes", "somewhere in your mind"},
			"is my pain yours?",
			"a confused haze lifts",
			"existence tricks us no longer",
		},
		epilogue = {
			"why you are here, i do not know",
			"does it matter?",
			"it must not; it never has",
			"our endless waltz",
				"in this broken city",
			"we've shared this moment before",
		},
		epilogue_bg = 1,
	},
	good = {
		music = 14,
		deathless = true,
		player_starts = {
			vec2(124, 31),
		},
		end_texts = {
			"i see your hopeful face",
			"i hear you whisper, \"this time\"",
			{"this time what?", "", "i am touched, regardless"},
			"startled, i gasp, and i burn",
			{"but it's okay,", "", "because this pain is real,", "", "and so am i"}
		},
		epilogue = {
			"there are no words",
				"for my gratitude",
			"this moment of clarity",
				"is timeless",
			"no malice, no hate",
			"not this time",
			"and i hope, never",
			"",
			"i may live on",
			"my heart touching yours",
			"i am free from this prison",
			"our bond carries us forward",
			"in your memory i dwell",
			"",
			"thank you",
		},
		epilogue_bg = 3,
	},
}

curzone = mapzone(
	0, 0, 128, 64)

function transition(duration, midscene, otherscene, callback)
	game:set_scene(scenefader(
		midscene, duration))
	game:schedule(duration * 2 + 30, function()
		local res
		if callback then
			res = callback()
		end
		if res ~= false then
			game:set_scene(scenefader(
				otherscene, 15))
		end
	end)
end

function die(texts, force)
	if (progress.deathless and not force) or progress.transitioning then
		return
	end
	progress.deaths += 1
	progress.all_deaths += 1
	progress.transitioning = true

	local function pd(x, y)
		return box(x, y, 0, 0):dist(player:coll()):max()
	end
	if progress.andre < 2 and pd(35, 55) <= 8 then
		progress.andre += 1
	end

	progress.m = pd(128, 14) < 2
	progress.m2 = pd(98.5, 59.5) < 4

	if not texts then
		texts = acts[progress.act].death()
	end
	transition(
		30, textscene(texts),
		mainscene, function()
			progress.transitioning = false
			map_layer:reset()
		end)
end

function nextact(texts)
	if progress.transitioning then
		return
	end
	progress.deaths = 0
	progress.transitioning = true
	if not texts then
		if progress.act >= 5 then
			texts = act5_results[progress.ending].end_texts[progress.displayact]
		else
			texts = acts[progress.act + 1].start
		end
	end
	local color = 7
	if progress.act == 5 then
		color = mr5.head_colors[progress.displayact]
	end
	local callback = _advanceact
	if progress.act >= 5 and progress.displayact >= 5 then
		callback = function()
			game:set_scene(scenefader(
				creditscene, 150, whiteramp))
			return false
		end
	end

	transition(
		60, textscene(texts, color),
		mainscene, callback)
end

function _advanceact()
	if progress.act == 5 then
		progress.displayact += 1
	else
		progress.act += 1
		if progress.act == 5 then
			progress.displayact = 1
		else
			progress.displayact = progress.act
		end
	end

	if progress.act >= 5 and not progress.ending then
        local mr5ok = 0
        for act = 1, 4 do
            if progress.mr5loss[act] < 5 then
                mr5ok += 1
            end
        end
        if mr5ok == 0 then
            progress.ending = "bad"
        elseif mr5ok == 4 then
            progress.ending = "good"
        else
            progress.ending = "ok"
        end

        progress.deathless = act5_results[progress.ending].deathless

        acts[2].music = 16

        progress.clarity = 0
        for _pos, decor in pairs(curzone.decor) do
            if decor.act5truereset then
                decor:act5truereset()
            end
        end
	end

	if progress.act == 5 then
		local start = act5_results[progress.ending].player_starts[progress.displayact]
		if start then
			player.pos0 = start
		end
	end

	progress.transitioning = false
	map_layer:reset()
end

mainscene = scene{
	layers = {
		{
			update = function(self)
			end,
			draw = function(self)
				circfill(32, 32, 13, 5)
				circfill(32, 32, 12, 6)
			end,
		},
		map_layer,
		{
			shiftx = 0,
			shifty = 0,
			update = function(self)
				if curtime % 20 == 0 then
					self.shiftx = (self.shiftx + 1) % 128
				end
				if curtime % 70 == 0 then
					self.shifty = (self.shifty + 1) % 128
				end
			end,
			draw = function(self)
				if progress.displayact ~= 4 then return end
				if progress.clarity >= 6 then
					return
				end
				local cl = progress.clarity + 3
				pal(0, 1)
				pal(5, 2)
				pal(6, 5)
				pal(7, 6)
				local fog, pset, pget = fog, pset, pget
				local dx = flr(cam.l * 6.4 + self.shiftx)
				local dy = flr(cam.t * 6.4 + self.shifty)
				local idx, yidx
				for y = 0, 127 do
					yidx = (y + dy) % 128 * 128
					for x = y * ceil(cl / 3) % cl, 127, cl do
						idx = yidx + (x + dx) % 128
						if fog[idx] then
							pset(x, y, pget(x, y))
						end
					end
				end
			end,
		},
	},
}
function mainscene:get_music()
	return acts[progress.displayact].music
end
function mainscene:update()
	scene.update(self)

	if btn(5) then
		die("try, try again", true)
	end
end

titlescene = scene()
titlescene.time = 0
function titlescene:update()
	if btn(4) or btn(5) then
		transition(
			30,
			textscene(acts[progress.act].start),
			mainscene)
	end

	if not self.extra then
		if self.time % 30 == 0 and
			rnd(30 * 60) < self.time
		then
			self.extra = "teeth"
			self.time = 0
		end
	elseif self.extra == "teeth" then
		if self.time > 90 then
			self.extra = nil
			self.time = 0
		end
	end
	self.time += 1
end
function titlescene:draw()
	cls()
	for x = 0, 127, 8 do
		local v = fog[4 * 128 + x + 4]
		if v then
			spr(6, x, 24)
			spr(38, x, 32)
		else
			spr(6, x, 32)
		end
		if x == 24 then
			palt(0, false)
			palt(4, true)
			spr(1, x, v and 16 or 24)
			palt()
		elseif x == 112 then
			spr(31, x, 0)
			spr(v and 31 or 19, x, 8)
			spr(31, x, 16)
			if not v then
				spr(31, x, 24)
			end
		end
		for y = 40, 111, 8 do
			local v = fog[(y + 4) * 128 + x + 4]
			local s
			if y <= 56 then
				if v then s = 38 else s = 22 end
			elseif y <= 80 then
				if v then s = 22 else s = 39 end
			else
				if v then s = 39 else s = nil end
			end
			spr(s, x, y)
		end
	end

	local pt = vec2(0, 128)
	printat({"u d r c n t u t o ", ""}, pt, "bl", 10)
	printat({" n e   o s r c i n", ""}, pt, "bl", 7)
	printat({"", "by glip and eevee"}, pt, "bl", 6)

	pt = vec2(128, 128)
	printat({"press z or x", "x to restart"}, pt, "br", 5)

	if self.extra == "teeth" then
		local tiles = {64, 80}
		if abs(45 - self.time) > 37 then
			pal(7, 5)
		elseif abs(45 - self.time) > 30 then
			pal(7, 6)
		elseif self.time % 10 > 5 then
			tiles = {65, 81}
		end
		spr(tiles[1], 4, 4)
		spr(tiles[2], 4, 12)
		pal()
	end
end
game:set_scene(titlescene)

creditscene = scene()
creditscene.camtop = -128
creditscene.castroll = {
	{
		{110, 126},
		"glitchedpuppet", 13,
		"art, music, concept", 14,
	},
	{
		{111, 127},
		"eevee", 13,
		"code, credits, this sprite", 14,
	},
	{
		{1},
		"mole", 4,
		"really digs this game", 7,
	},
	{
		{121},
		"radio", 1,
		"over and out", 7,
	},
	{
		{104},
		"fire", 9,
		"started from scratch", 7,
	},
	{
		{62, 61, 46},
		"pain tower", 2,
		"scars easily", 7,
	},
	{
		{59, 15, 21},
		"s'mitten", 11,
		"yearns for your touch", 7,
	},
	{
		{18},
		"lil chomper", 3,
		"lurks underfoot", 7,
	},
	{
		{64, 80},
		"gnash", 6,
		"wants you for dinner", 7,
	},
	{
		{66, 96, 53},
		"peeps", 8,
		"saw nothing, honest", 7,
	},
	{
		{84},
		"twinkle", 10,
		"wonders where you are", 7,
	},
	{
		{29, 114, 30},
		"ex-sign", 5,
		"used to mark a spot", 7,
	},
	{
		{48},
		"chair", 4,
		"stylish yet functional", 7,
	},
}
function creditscene:onenter()
	game:changemus(act5_results[progress.ending].music)
	if progress.andre >= 2 then
		add(self.castroll, {
			{109, 125},
			"andre", 14,
			"the ultimate peep", 7,
		})
	end
end
function creditscene:update()
	scene.update(self)
	if btn(2) and self.camtop > -128 then
		self.camtop -= 1
		self.done = false
	elseif not self.done and curtime % 4 == 0 then
		self.camtop += 1
	end
end
function creditscene:draw()
	cls()
	camera(0, self.camtop)
	local p = vec2(8, 8)
	local left = true
	for cast in all(self.castroll) do
		local side = "r"
		if left then
			p.x = 8
			side = "l"
		else
			p.x = 112
		end
		local tiles = cast[1]
		if #tiles < 2 then
			p.y += 4
		end

		for tileno in all(tiles) do
			to_sprite(tileno):drawat(p * 0.125, not left)
			if tileno == 46 or tileno == 62 then
				local n = curtime % 64 / 16
				pset(p.x + 3 + n % 2, p.y + 3 + n / 2, 0)
			end
			p.y += 8
		end

		local anchor = p:copy()
		anchor.y -= 1 + 4 * #tiles
		if left then anchor.x += 12 else anchor.x -= 4 end
		printat(cast[2], anchor, "b" .. side, cast[3])
		anchor.y += 2
		printat(cast[4], anchor, "t" .. side, cast[5])
		left = not left
		p.y += 8
		if #tiles < 2 then
			p.y += 4
		end
	end

	local epilogue = act5_results[progress.ending].epilogue
	rectfill(0, p.y, 128, p.y + font_height * #epilogue + 64, 6)
	p.x = 28
	p.y += 4
	for act = 1, 5 do
		local headidx = 1
		local torso, legs = 85, 101
		if act == 5 then
			if progress.all_deaths < 5 then
				headidx = 4
			elseif progress.all_deaths >= 55 then
				headidx = 5
			elseif progress.ending == "good" then
				headidx = 2
			elseif progress.ending == "bad" then
				headidx = 3
			end
		else
			local loss = progress.mr5loss[act]
			if loss == 0 then
				headidx = 2
			elseif loss >= 5 then
				headidx = 3
			end
		end
		if headidx == 3 then
			torso, legs = 86, 102
		end
		local p8 = p * 0.125
		to_sprite(mr5.head_sprites[act][headidx]):drawat(p8)
		p8.y += 1
		to_sprite(torso):drawat(p8)
		p8.y += 1
		to_sprite(legs):drawat(p8)
		p.x += 16
	end

	local epicolor = act5_results[progress.ending].epilogue_bg
	p.x = 64
	p.y += 28
	printat("m i 5 t e r f i v e", p, "tm", 0)
	p.y += 8
	printat("make5 perfect 5en5e", p, "tm", epicolor)
	p.y += 16
	printat(epilogue, p, "tm", 7, 0, epicolor)
	p.y += #epilogue * font_height

	p.x = 64
	p.y += 80
	printat("thanks for playing!", p, "bm", 7)
	p.y += 4
	printat("floraverse.com", p, "tm", 12)

	p.y += 62
	spr(110, 2, p.y - 16)
	spr(126, 2, p.y - 8)
	spr(111, 118, p.y - 16, 1, 1, true)
	spr(127, 118, p.y - 8, 1, 1, true)

	p.x = 12
	printat({"@glitchedpuppet", "glitchedpuppet.com"}, p, "bl", 1)
	p.x = 116
	printat({"@eevee", "eev.ee"}, p, "br", 1)

	if self.camtop + 128 >= p.y + 2 then
		self.done = true
	end
end

declare_transparency{
	1, 2, 3, 4, 5,
	103,
	69, 70, 73, 74, 75, 76,
	85, 86, 88, 89, 90, 91, 92,
	101, 102, 105, 106, 107, 108,
	117, 118, 122, 123, 124,

	trans = {4},
}

declare_sprites{
	{53, 63},
	{66, 67, 68, 67},
	{96, 112, 113, 112},
	{64, 65},
	{80, 81},
	{84, 100, 116},
	{104, 120},
	{74, 90}, {76, 92}, {69, 70},
}

declare_tile{
	class = playeractor,
	shape = box(0.125, 0, 0.75, 1),
	poses = {
		default = 1,
		walking = {2, 3},
		jumping = 4,
		falling = 5,
	},
	reset = function(self)
		playeractor.reset(self)
		self.touched = false
	end,
}

declare_tile{
	sprite = 7,
	shape = box(0, 0, 0.75, 1),
	oncollide = function(self, actor, d)
		if actor.is_player and d.x < 0 then
			die()
		end
	end,
}
declare_tile{
	sprite = 8,
	shape = box(0.25, 0, 0.75, 1),
	oncollide = function(self, actor, d)
		if actor.is_player and d.x > 0 then
			die()
		end
	end,
}

declare_tile{
	for_tiles = {18, 34},
	poses = {
		default = 18,
		chomping = 34,
	},
	reset = function(self)
		decoractor.reset(self)
		self:set_pose"default"
		self.stander = nil
		self.stand_timer = -1
	end,
	oncollide = function(self, actor, d)
		if actor == self.stander then return end
		if actor.is_player and d.y > 0 then
			self.stander = actor
			self.stand_timer = 30
		end
	end,
	update = function(self, curzone)
		if self.stander then
			if self.stander.pos.y == self.pos.y - 1
				and self.stander.pos.x > self.pos.x - 1
				and self.stander.pos.x < self.pos.x + 1
			then
				self.stand_timer -= 1
				if self.stand_timer <= 0 then
					self.stand_timer = 0
					self:set_pose"chomping"
					die()
				end
			else
				self:reset()
			end
		end
	end,
}

function _draw_iris(pos)
	local iris = pos * 8 + vec2(3, 3)
	if player.pos.x > pos.x then
		iris.x += 1
	end
	if player.pos.y > pos.y then
		iris.y += 1
	end
	pset(iris.x, iris.y, 0)
end

function _eye_try_propagate(pos)
	local below = curzone:tile(pos + vec2(0, 1))
	if below._eyepropagate then
		below:_eyepropagate()
	end
end
function _eye_collide(self, actor, d)
	if actor.is_player and progress.displayact >= 3 then
		actor.touched = true
		if self.pose == "default" then
			self.pain = 1
			self:set_pose(1)
		end
		_eye_try_propagate(self.pos)
	end
end

declare_tile{
	poses = {
		default = 62,
		115,
	},
	reset = function(self)
		self:set_pose"default"
	end,
	oncollide = _eye_collide,
	draw = function(self)
		if self.sprite:current() == 62 then
			_draw_iris(self.pos)
		end
	end,
}

declare_tile{
	poses = {
		default = 46,
		45,
		61,
	},
	reset = function(self)
		self:set_pose"default"
		self.pain = nil
	end,
	oncollide = _eye_collide,
	update = function(self)
		if self.pain and self.pain < 2 then
			if rnd() * (self.pain + 1) < 0.0625 then
				self.pain += 1
				if self.pain == 1 then
					_eye_try_propagate(self.pos)
				end
				self:set_pose(self.pain)
			end
		end
	end,
	_eyepropagate = function(self)
		if not self.pain then
			self.pain = 0
		end
	end,
	draw = function(self)
		if self.pose == "default" then
			_draw_iris(self.pos)
		end
	end,
}
declare_tile{
	for_tiles = {45, 61},
	oncollide = _eye_collide,
	_eyepropagate = function(self)
		_eye_try_propagate(self.pos)
	end,
}

declare_tile{
	poses = {
		default = 119,
		broken = 121,
	},
	shape = box(0, 0.5, 1, 0.5),
	is_radio = true,
	init = function(self, ...)
		actor.init(self, ...)
		progress.radios0 += 1
	end,
	oncollide = function(self, actor, d)
		if progress.act == 2 and self.pose == "default" and actor.is_player and d.y > 0 then
			self:set_pose"broken"
			progress.radios += 1
			local r = progress.radios
			local r0 = progress.radios0
			local m
			if r >= r0 then
				m = -1
			elseif r0 - r <= 2 then
				m = 33
			elseif r * 2 >= r0 then
				m = 31
			end
			if m then
				game:changemus(m, 15)
				acts[2].music = m
			end
		end
	end,
	draw = function(self)
		if self.pose == "default" then
			for d in all{0, 3} do
				local r = (curtime - d * 3) % 45 / 3
				if r < 8 then
					local color = 6
					if r >= 6 then
						color = 5
					end
					circ(self.pos.x * 8 + 1, self.pos.y * 8, r, color)
				end
			end
		end
	end,
	act5truereset = function(self)
		self:set_pose"default"
	end,
}

declare_tile{
	class = mobactor,
	sprite = 103,
	reset = function(self)
		mobactor.reset(self)
		self.enabled = progress.act == 4
	end,
	oncollide = function(self, actor, d)
		if d.x ~= 0 then
			self.vel.x += d.x
		end
	end,
	update = function(self)
		mobactor.update(self)

		local x = flr(self.pos.x + 0.5)
		local y = flr(self.pos.y + 0.5)
		local tile = curzone:tile(vec2(x, y))
		if tile.extinguish then
			tile:extinguish()
		end
	end,
}

function _fatal_to_touch(self, actor, d)
	if actor.is_player then
		die()
	end
end

declare_tile{
	shape = box(0, 0.375, 1, 0.625),
	sprite = to_sprite(104),
	init = function(self, ...)
		decoractor.init(self, ...)
		progress.fires0 += 1
	end,
	reset = function(self)
		if not self.extinguished then
			decoractor.reset(self)
		end
	end,
	oncollide = function(self, actor, d)
		if actor.is_player then
			if progress.act == 4 and progress.deaths >= 10 then
				die{"you wonder if that", "cleanses your soul"}
			else
				die()
			end
		end
	end,
	extinguished = false,
	extinguish = function(self)
		if not self.enabled then return end
		self.enabled = false
		self.extinguished = true
		self:set_sprite(0)
		progress.fires += 1
		progress.clarity = flr(
			6
			* progress.fires
			/ progress.fires0)
	end,
	act5truereset = function(self)
		self.extinguished = false
		self:set_sprite(104)
	end,
}

declare_tile{
	sprite = declare_sprite{21, 37},
	oncollide = _fatal_to_touch,
}
declare_tile{
	sprite = declare_sprite{59, 60},
	oncollide = _fatal_to_touch,
}

function reset_broken_tile(self)
	if progress.displayact == 1 then
		self:set_pose"default"
	else
		self:set_pose"broken"
	end
end
for pair in all{{16, 32}, {28, 44}, {31, 19}, {57, 20}, {58, 49}} do
	declare_tile{
		for_tiles = {pair[2]},
		poses = {
			default = to_sprite(pair[1]),
			broken = to_sprite(pair[2]),
		},
		reset = reset_broken_tile,
		update = function() end,
	}
end

mr5 = oneoff_actor{
	pos = vec2(118, 61),
	shape = box(0, 0, 1, 3),
	is_mobile = true,
	blocks = function(self)
		return true
	end,
	reset = function(self)
		actor.reset(self)
		self.timer = 0
		self.state = "neutral"
	end,
	update = function(self)
		local dist = self:coll():dist(player:coll()):max()
		local near = dist < 3

		local act = progress.act
		local m = "update" .. act
		self[m](self, near)

		self.timer += 1
		if self.state == "appeased" and self.timer > 90 then
			nextact()
		elseif self.state == "angered" and self.timer > 90 then
			progress.mr5loss[act] += 1

			local texts = self.die_texts[act][progress.mr5loss[act]]

			local call = die
			if progress.mr5loss[act] >= 5 then
				call = nextact
			end
			call(texts)
		end
	end,
	update1 = function(self, near)
		if near and (player.pos.x < self.pos.x) == player.facing_right then
			near = false
		end

		if near then
			if self.state == "neutral" or self.state == "relaxing" then
				self.state = "approached"
				self.timer = 0
			end
		else
			if self.state == "approached" then
				self.state = "relaxing"
				self.timer = 0
			end
		end
		if self.state == "approached" and self.timer > 60 then
			self.state = "angered"
			self.timer = 0
		elseif self.state == "relaxing" and self.timer > 150 then
			self.state = "appeased"
			self.timer = 0
		end
	end,
	update_condition = function(self, near, condition)
		if near and self.state == "neutral" then
			if condition then
				self.state = "appeased"
				self.timer = 0
			else
				self.state = "angered"
				self.timer = 0
			end
		end
	end,
	update2 = function(self, near)
		self:update_condition(near, progress.radios == progress.radios0)
	end,
	update3 = function(self, near)
		self:update_condition(near, not player.touched)
	end,
	update4 = function(self, near)
		self:update_condition(near, progress.fires == progress.fires0)
	end,
	update5 = function(self, near)
		self:update_condition(near, true)
	end,
	head_sprites = {
		{73, 105, 89},
		{74, 122, 106},
		{75, 107, 91},
		{76, 124, 108},
		{69, 118, 117, 88, 123},
	},
	head_colors = {14, 11, 9, 8, 12},
	ok_texts = {
		"i see you",
		{"shh", "i hear you"},
		{"wait", "did you feel that?"},
		"ah",
	},
	ng_texts = {
		"it's so dark",
		{"shh", "i can't hear you"},
		"it hurts",
		"i can't breathe",
	},
	die_texts = {
		{
			"weren't you just here?",
			"no, it couldn't be",
			"i've never seen you before",
			"hmm",
			"yes, you were never here",
		}, {
			"weren't you just here?",
			"no, that would be absurd",
			"no one would endure this",
			"hmm",
			"but you did, didn't you?",
		}, {
			"you feel ashamed",
			"why do you keep hurting?",
			"you can't understand it",
			{"do you feel more real", "when you hurt?"},
			{"do you feel more real", "when you hurt others?"},
		}, {
			"you want to hit something",
			{"there's nothing here", "worth hitting"},
			{"there's nothing here", "worth anything"},
			"you want to hit nothing",
			"you want nothing",
		},
	},
	draw = function(self)
		local drawpos = self.pos:copy()
		if self.state == "approached" then
			local v = flr(self.timer % 4 / 2)
			if v == 1 then
				drawpos.x += 0.125
			end
		end

		local head, torso, legs
		local heads = self.head_sprites[progress.displayact]
		local head = heads[1]
		local torso, legs = 85, 101
		if progress.act == 5 then
			if progress.ending == "bad" then
				head = heads[3]
			elseif progress.ending == "good" then
				head = heads[2]
			end
		elseif self.state == "angered" then
			head = heads[3]
		elseif self.state == "appeased" then
			head = heads[2]
		end
		if self.state == "angered" then
			torso, legs = 86, 102
		end
		for _n, sprite in pairs{head, torso, legs} do
			to_sprite(sprite):drawat(drawpos)
			drawpos.y += 1
		end

		local midtop = (self.pos + vec2(self.shape.w / 2, -0.75)) * 8
		local function mr5say(texts, color)
			printat(texts, midtop, "bm", color, 5, 0)
		end

		local state = self.state
		if progress.act == 5 then
			if state == "appeased" then
				mr5say("...", 6)
			end
		elseif state == "angered" then
			mr5say(self.ng_texts[progress.act], 8)
		elseif state == "appeased" then
			mr5say(self.ok_texts[progress.act], 13)
		elseif state == "approached" or state == "relaxing" then
			local color = 14
			if state == "relaxing" then
				color = 2
			end
			mr5say({"don't look", "at me"}, 9)
		end
	end,
}

__gfx__
00000000444777444447774444477744444777444447774455555555550000000000000500555555000005550555550555565500666666666600006600005000
00000000447777744477777444777774447777744477777465656565005500000000055005656565000055550556655055655050666666665500055500050000
00000000477077774770777747707777477077774770777756556556050052000025555056556556005555555555655065555500666666660550550000050000
00000000477777744777777447777774477777747777777605005505500000000000000555665565056555555556050555505550666666660055500000050000
00000000476767744777677446777776777777764777777450550050000000000000000056555650555555050506655556550055666666660555000000050000
00000000477677644776674446677764467777444776774405005505550000000000005505056505555555000556655555655000666666665565500000005000
00000000447777444777774444777744447777444477677400505050055550000005555050505050550550005556555055655500666666665060550000005000
00000000447447444744447444476444444744744444444405000000500000000000000505050555500055555555650055555000666666660060055000005000
55555555000500000005650000005050000000000005500050005005555555555655055055555500000005555055555500666600600000600560000055005055
55566555000050500055650000000550550000550055550000500000555555555505055065656560000055555055050500677600560006506600000055000555
55600655000055000555655000000050055005500555555000050000555555555005065556556555000555555555550500677600056065006000000055000055
56000065000050500555655000000050500500055555555005000505555555555005550565665565055555005555555500555500005660005600000055000055
56000065050500000556655005000050000000005555555000050000555555555005550656555650000055550655055500677600000560000560000055000055
55600655005500000056550005500005500000005655565005000050555555555055500505056505000555555555055500677600006656000056000055500055
55566555050500000056550005050005055000550056560000005500555555555565500555505050000056665555555000677600065005600006000055050055
55555555000050000005500005000050555055550000000000000000555555556555505505050505000055555555550000555500650000560006000055000055
05555505666660000050655055555555000000000005500005055005000050000000000000000005555550000500500000606600500000055000000500066600
50566555665656000550005556555565500000000055550000500550000000000000000000000005555555000050500000075600500000055000000500666660
55600655666566665566005556555565055000000555555050555050050500505050005000000005550555000005650000677500500770055007700506660006
56007065665655665500055556565565500500005555555005050505000000005050005000500055550055500555556500555000507007055077770566600000
56070005566666565550655055555555000000005555555550555050000000005550005000550055555550500056665000000600507007055077770566600000
55000600055556665556055056565565500000005055500505050050005050005550055005555055555055500505650000675600500770055007700566600000
50566550006005560555055056565565050000006050500650505505000000505555055505555555555055555005505000057600500000055000000506660060
55055555006000050005550055555555500000000060600005050500000000005555555555555555555555550005000000555500500000055000000500666600
55550000000555500000050550500000000600000066660000000000000000000505005000050005555555550000000000707000500000050055550000666600
55550000555500500000005005000000000600000670066055505555000000005050050055505550500500500000000000505070500000050500005006700660
60060000050500000500050000500000000606000665066005555000000000005050500005555550050500500050500070505050507005055007700506605660
60060000050000500050505000050000000606000665566050505055000600000000500050000005050500500055555050555550500750055077770506655660
60060000050050500005000000505050060606000066660000500550000600600505050000000000050050500575755055566650500570055077770500666600
55555550050055050050000005000500060606600000600050055555600600605055050050000055050050050555575005560650505007055007700500600000
60060060000005050500000000000050060600600060000005505055600600600505050005555550005050050557555005566650500000055000000500006000
60060060550000555050000000000505600600660060600055555550660606660505500055555555555555550055550000555500500000055000000500006000
00000700000070700066660000000000000000004444004444400444565556555655065544400440404440444404404444447447006666000005055555555000
00007000000700770666066000000000000000004440070444007044565556555655065504000004440404444404404444747474006776000000555555555500
00077000007700700660066000655600000000004000670440076044565556555650065540066004440404440400404047447774006776000055555555055500
00000000000000000660066006600660000000004400700400067044565556555650565500600604400000040400004077477674005555000565555555005550
00777000000000707775577777755777666556664007604440670044565556555655565500600600405757040007704076776747006776005555550555555050
00077000070077700775577007755770000550004076004440760004565556555055565540755700407575040070070047766774006776005555550055505550
00707000777007700775777000766700000000004000004440070444565556550055565040077004400000044007700447666744006776005505500055505555
07770000770000000077770000000000000000004400040444000444565556550005565004000040440004444400044444767444005555005000555555555555
07007000700000000000000066666666000050004440444444404444556555554404444444400444404440444440444444744474555555550555550500000050
00777000000007700000066666666666000060004040444444404444055005554000400444000044440404444404040447447747555665550556655000000500
07077000700077700006666666666666006060604400444444404444005555560050005040050004440404444000404447476774556006555555655006666550
07707000770007000066666666666666000767004440044444400444000565555050700540050004400000040405000444777744560000655556050562665605
00070000070000000666666666666666566676654444040444040444005550050007705040050004407575040000004047676744560000650506655566656600
07700000000000706666666666555666000767004444004440440044000555655005700540005004405757040055500047766747556006550556655506566600
00770000700007706666666655555556006060604404044444400404000005555400004540005004400000044000000477667774555665555556555005662600
00070000070077006666666655555555000050004440004444040440000000054450044544000044440004444405044447767444555555555555650000066000
00000000000000000000000666666666000000004444000444440044444465440006006044400444444444444400444400444400a00000000400804000200020
00555550003333300060006666666666060000064040004444440404446556540066006044000044004440044400444440044004500300004ff8a8f402200220
05500055033111330660006066666666006050604400000444400044465655540060000040000e04440404440400004444000044505000004f1181f4024e0240
50060005311666130660006066665666000757004444004044040404455556540660606000e000044000000404000004444040445500c00001771d1004ee4440
0666006016611661066000006656556600557550404000044444004445655555067600600000e00040550504000900044400000475550000f1771d1f00e41414
67777776677c77760600600065565566000757004400044444400404555655556676006040d0d0d040505504009a090440040400e50000000f1161f0004444e4
00777770007cc77000006000655555560060506044400004440404445655556567760670400ddd0440000004400990040044044050000000f011110f00f44440
0000000000000000000000005555555506000006440004444440004455555555777666764400004444000444440004444440044455000000000ff0000ffff4ff
0000000000000000000660000055550000007000444444444044444007000000000060000000000044040444000000004444444475500700000dff000fffffff
0055555000000000000566000500005000000000444440040d0444000600000060000000000670004404044400050040444000447755770000ffdf0000ffffff
0555555500555550000056005000000500500050440405000dd040d00600000000006000000600004404044405000440440898047777700000fffd000044fff4
55555555555555550000560050000005000565004440504000dc0cd00600000000600060066055004000000400044440440989047337777000f4ff0000244f42
00000000055555500000660050555505700676074405044400cdcdc055555600066660000505560040beba0404444440440898047c7770070fdffd0000244442
066666600055550000006500500606050005650044050444400c7c0056665677067666065560560040973c04000000004440004477770000ffdf0d0004444440
0000000000000000000660005006060500500050440040444000c004577756076766766657705607400000040004400044440444500000004d0f0d000f424020
0000000000000000000650005006000500007000444044440400004055555600777776765505565744000444000000004440044400000000400f0d00fff20020
61b17000000090b1006162c0009091000000a162617000008071c000717182620000e0000000000012000000e300000000000080a3a3a3700000000000f00080
a3a370002100000000000000002300000000000061000062000000e2000000e2000000e300000062626260600000000000000000f100f10000a1c07000000080
a0b170000000b0b1006262c000626100000000a0626170000071a20001020102a200e1000000739091000000e200000000000023000000330000000000310023
00000000600000210000000023000000000000000000006100000062000000e2000000e200000062006262620000000060006000f100f10000a0b07000008061
b1c0330000a1b07190b171c000006190910000000000000092718162a20071b07100e1000090600062000043e200000000002300000000003300000000312300
0000000061000060002100230000000000000000000072000000610000000062000000e20000006200620062000000003100f100f187f10000a1b07000008061
b0c000332390b0717100717000000062006200000000928271710072710061007100e100900062246293a3a3a3a313a3a3a370000000000080a313a3a3a37000
0000000072000061006023000000000000000000000000007200000061002300610000e2000000616261006100000000f100f190606060606060600000008062
c0700023336271717100b10000000062009091000092717171b100a171006200626060606200626200610000d3000000000000000000000000f0000000000000
00000000000000720061002100000000000000000000000000000061002300610000006200000062616261720000009060606000000000000000000000000080
70002300806272717190b1000000006161616260606060609170000090606060600000006262620061006100d3820000000000000000000000f0000000000000
00000000000000000072006000000000000000000000000000000000230000000000006100000061727272000090606262700000000000000000000000000080
702300000080627171b1700000e00072007262006162610062700080b000000000000000000000000000000075b10000000000000000e46000f0000000000000
7700e4f4000000000000006100210000000000000000000000000023000000000000610000000072007200009062620070000000000000210073009060606060
b070000000a162620062720090606060700062006100610062700080620000000000000000b3000000000000000000000000000000e4b1816363607000009060
6060c0f1000000000000007200600000000000000000000000002300000000000000000061009060606060606200627000000000437300906060606100610000
71c00000000062620062006200626162000061726100610061000000000000000000000000f00000e30000000000000000000000000075816060c0000000f000
000000f10000e4f400000000006100e4f40037000000e3000023000000000000000000000080626100e100f06262700000000060606060620062006100610000
71c0000000000062626272620062b1b0000061007200006100000000000000000000c30000f00000e20000000000000000000060000080c00000b0009282f000
00000031000062620000000000720080b1a3e5a3e5a3e5a3a3e5a30000000000000000000080626100f300f06170000000000062006200626262006161610000
6271c000000000006261620061b000b0700061617200000000000000000000000000f00000f00000e20000000000000000000062000000b00000756060c0f000
000000f00000616100000000000080626261b072b000b0000081001300000000000000000000806200f20053006270000000006261620061006100f0000000e3
0062c000000000006100610061b000b1000000000000009282000000009091939393939393939393939393700080934170000061000092a2000000000081f000
000000f00000000000929393700080626261b072b000b03700810000a37000000000000000000080620000f2006170000000000000006161000000f0000000e2
006171c00000000072006100610062b0000000000000906060910090916161000000f00000f000f0000000310000000000809393939393b10000000000b0f400
000000f00000928293937000330090606060b060b060b0606081332300330000000000000000000080610000616293937000000000000072000000520000a2f1
240061b10000000072726261000062b1008060607000810062b170616100c1000000f000000000f000000031000000000000000000000000000000000075b100
000000f00000939370000000009062610000610061006100006223330000a370000000000000000080626161006200008093000000000000000000000000f1f1
006162c00000000000000000000000000000616100806200c0000000c10000000000f00000000004000000906091000000000000000000000000000000000000
000000f0000000000000000000616100000061006100610000610000332300000000120000000000806200620061000000809393700076007700000000a0f1b0
6100b170000000000000000000000000000072720000726170000000000000000000f00000000005000000616261000000000000000000000000000000000000
000000f0000000000000000000610000000072007200720000610000230000000000270000000000806200626261c100c1000080419393939341000000f1f1f1
00b07000000000000000730000000000000000000000000000000000000000000000f00000000000000000006100004500000000000000470000000000000000
00000080930000000000000000000000000000000000000000729091000000000000270000770000806362623300000000000000f10000f100f1000023f1c2f1
62b07000000000009060606091000000000000000000000000000000000000e30000000000000000000000000000000000000000000000000000000000000000
0000000080930000000000c300000000000000000000000000006262000000000000e10090606060917000000033000000000000f100003100f1002300a1b0c0
62b1000000d500006200720072000000000000000000e30000000000000000e20000000000000000000023000000000000004500000000000000000047000000
0000000000809393000000f000000000000000009091000000006161000000000000606062006200627000000000330000000000310000f100f12300000000b0
700000000002000062c161c172a20000000000000000e20000000000330000e20073007700730076232300000000000000000000000000000090609100004600
00000000000000f1000000f0000000000092820062020000000000610000000080b00000620062006270000000000033000000003100a3a3a313000000000061
70000000000100008100720062b07000000000e30000e200e3000000003360606060606060606060937000000000004600000000000000000062006200000000
00000000000000f1000000f00000000092a360916162009091000000000000806200000062006100617000000000000033000000a3a30000f0000000004300a0
61700000002700e481c0000062b00000e30000e200906000e20000008093f17474740000747474f1700000000000000000000000000000000061620000000000
0000000090919393630076f086009063a300e13300610001629370000000806200000000616161e4700000000000e3000033000000000000f0000080a3a3a3a3
6261700000e1006281c0006270000000e200906060626260609100000033f18474740600747484f10023000000000000000000009060910000006100e3000000
0000000061620000a3639363936362000000e1003300006211000000000080620000000061006270610000000000e2000000330000000000f000860000e20000
b062700000606081b100000000000000e2006162c162c100c26100003380f17474740006747484f1233300000000000000008093b062629100000000e2000000
0000909172000000000000000000f0004500f2004533007211000000008062000000e30062006270000000000000e20000a3a3a3a313a3a3a3a313a3a3a3a3a3
71620000000000000000000000000000d300006100000061006100002333f17474840000847474f1330000000000000000000023810061620000009060609100
0000626100000000000000000000f0001100f2001100330011000000008062000000e20062006270000000000080939393f0000000000000000000f000007401
b0b10000d40000060000000000000000e23300000061b200c261000000a160606060606060606060a223000000000000000023336200720000009062d2626291
0000720000000000000000000000f3001100f2001100003311000000806200000000d3006162617000000080a362000000f0000000626262000000f000008101
c0000000f00000f00007000000000000e2003300000000000072000000a0b16262b16262b162b0b1b10000000000c200000000006100009060606162e2620062
9100000000000000e00000000000000011000000f000000033000000806200000000e20000006170000080620023000000240000627474746200000600007401
60700000f000b2f000f0000000000000e200003300000000007200e000a1c03380f10023f12300a1c00000000000f000000000000000806200620062d2610000
6270000000000000e100000000000000f0000000f00000002333008062c16200c200d200000062700000003323f200000014006174d036d07461000400008102
62b1f400f000f0f000f00000000000906091000033000000000000e100a1c00033f12300f17000a1c00000000000f0000000000000000061c1610061d3000000
610000000000d100e100000000000000f0000000f000002300003390620062000000d30022006170000000233300000000150061d0357135d061000500a07163
00b17000f000f0f000f000777300908100b1700000330000000000e100a1c00023f13380f13300a1c00000000000f00000000000000000610061000000000000
00000000906060606060609100000000f00000001100230000009062006261610000d200e1006370000023000033000000000061d074d032d06100000080a371
006162609100f0f073f000906091818362b1700000003373000003e103a1c02300f10033f10033a1c00086000033f02300007300000000000000000000000000
00009060620062006100620091007600f00086001123000000906200620061000080d270e1006170002300000000330000000062d032d074d062000000906362
62006100626060606060606200618300836160606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060
60606200620061006200610061606060606060606060606060620061610061000080e270e16263702300004300000033770073623574d0323662006060626262
__gff__
0000000000008080808000000000800000009000801c0000008000000098000000989000001c0000000000000080800080801818000080000080801c1c80800010100000000000000000000000808080101000001800000000000000008080000000000018000088080000000000000000000080180000820802000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000081b170b000b001b0b1b0c1a0b0000000032000000000000000000000006060d0d0d0d0d0d0d0d170d0d2616260d530d0d0d170d0d0d0d000000000000001e0000000000000000001a180c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f000000
0000001a171b17071b0a1b171b0c0a17070000320009060606060619000000000016060d0d0d630d0d0d230d0d002c1663170d0d63170d0d0d0d001c001c002c001e001c002c00000000001a0b3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f000000
3e00000817171b2616161616161b17260c003200002626262800260b00670068000000060d0d230d0d0d170d0d00670047230d0d23170d0d0d0d000000000000001e0000000000000000001a1b0000000000000000000000000000000000000000000000000000000000000000000000000000000600083a3a07000013001d00
2e00001a171b1b160000000000160b170c320000000a102a202a100b0606061900000000060d170d0d630606060606060606065317470d0d0d63000000770000001e00000000000000300000000000000000000000000000000000000000000000000000000000003e000000000000000000000818270027000700081f000000
2e0000000b172600000000000000261b0b000000001a26261626171b2620262000000000260d230d06062627261626262626000606230d0d6347000006060619001e00000000000009193900000000000037000034000000000000000000340000007700000000002e000000000000000000004e2a000000070000081f001d00
2e01001a171b1600000000000000161726000000000b2600001626161616162600000000160d17530016270000260016002600000006060d060606060000000006061900000000002626263939393939393939393939143914003900000839391406060614392439393914240000000000004e0c260027070000000813000000
0606001a171b1677000000000000161b0c00000000260000000016001600160c00000000000d17230016001c162c271c001600000000000d00000000000000000000001900000000161616262600001f00003332001f330000000f000000001300162626001f003200000f0000000814393a1b00000000070000082616001d00
261606060606060607000000080606060c00000000260000210016000027001833000000320606060000000000160000160000000000006300000000000000000000002706060606061900161600001f000032330013003300000f000000321f00001626001f3200000013000000000047474700270000160700000826000000
1626161626161616070000000800162606292829290b00001e0000000027000b00330032000000000000272c002b002c000000000000001700000000000000000000000016271626162600000000000000320000331f000033000f000032001f0000161600130000000006000000000047484700000016260700000008001d00
0016001616001600070000320816000016060606171728001e0000002600260c00003200000000000000002600000000002906060600001700000000000000000000000000160016001600000000001332000000001f0000003313003200001f00000016001f0000000026000000000047474700002700001607000008260000
1600160000160000073332000816001600160026060606001e7700001626160033320033000009061900000000002b00291700000028291700000000000000000000000000000000000000000000001f00000000001f3700006713320000001f00000000081f0000000016000000000048474700000000160007000000080016
0000000000001600073233000816160000001616001626060606190000000000323300003300260026190000000000291717001c001717170000000000000000000000000000000000313a3a313a09061900000009061900000906190000090619000027001f0000000000000000000000484700000000002607000000080000
00000000001600000700003308160016000000000026001600260019280000320000330000332616261600000000060606060000000606060000000000000000000000000000000000001300000000110000000000000000000000270000000026000000001f0000000016000000000000004700000000160007000008261600
000041000000160007000000080000000000160016000000000026000619320000000033000026001627002928291616001600000000160006190068000000000000000000000e0000001300000000110000000000000062000000520d0d0000160d0d00001f0000000000000000000000004800000000001626070008160008
000051000000000007000000080000000000000000000000000000000026000000000000330016002700290606060016001600000000160016000606061900000000000000001e0000080607000000110000000000000000006200530d630000260d0d00001f0000000000000000000000000000000000160016070008000008
00000000004000000733000008000000000000000000001c000000000000060619006700003327000009060000000016001600004200160016000000002706061900000000001e00001a1b000000001500000000000000000000001747170000160d0d00001f0000000000000000000054000000540000002607000000080000
00000000005000270700330008270000000000000000002000000000000000000006060619000906060000000000002700270000000027002700000000272716261900003206190000001100000000000000000000000000000000171717000026536300001f000000000000000000000f0000000f0000160700000000000800
00000000000000160700003308160000000000000000001c0000000000000000000000001600160000000000000000003e0000000000270000000000000000161626193200162600000011000000000000000000000062000000291700170000261717000906190000000000000000000f000f000f0027070000000000000008
00000000000000070000000033080000000000000000001e0000000000000000000000002700270000000000000000002e00000000000000000000000000000016162600002716000000110000000000000000000000000000291717291700001600170026162600000000000000000000000f00000016000000000000000008
00000000000000070000000032080000410000000000001e0000000029280000000000000068091900000000000000002e000000000000000000000000000000001616000016270000001100000000000000000000000000291717171717000026001700162c1600000000000000000000007400002700000000000000000008
00004000000000070000003200080000510000000000001e000000090606193a3a3a3a3a3a3a26263a3a0919000009193939140700000000000000000000000000002700000027000000110000000000000000000000000017171017001700002628170000000000000000000000000000000000002700000000000000000826
00005000000000070000320000080000000000000000001e00000000000000000f000f000f000016000026260000162600000f0000000008070000000000000000270000002700000000150000000000000000000000002617171717281700001617170000000000000000000000000000000000000000000000000000770816
00000000000027073332000000082700000000000000000906190000001c00001c000f000f000000003216260000261600000f000000000f0000000000000000000000000000000000000000000000000000000000090606060606171717000000060606060619000000000000000e0000000000000000000000000008060626
000000000000070032330000000008000000000000000026002600000000000000000f000f0000273200271600001626000919000000000f000000000008140700000000000000000000000000000000000000000926162600261606061768000600260026002600000e00000000720000000000000000000000000826261600
000000000000073200003300000008000000000000000026260000000000000000002b000f000032000000270000002700262607000000130000000000000f0000000000000000000000000000000000000000082600260026000016000606060000160026002600001e000e0000720000000e00000000000000000826160027
0000410000000700000000330000080016000000090619262600091900000000000000000f0032000000270000002700001616000000000b0012000000000f0000000000000000000000000000000000000000000000000000000000000000000000270016001600001e007200001e00000072000e0000000000000008261600
000051000027070000000000330008270000270026260c000016001626190000000000000f32000000000027000000270000270000000026000b070000000f00083a3a3a313a3a3a3a3a3106060619000000000000000000000000000000000000000000000027000072005400001e00000074001e0000000000000000082616
0000002700160700000e000000330008262700001a2018330027321600260000000000002f00000000000000000027000027000000000000080c000000000f00001300000000000000000000000000003e0000000000000000000000000000000000000000000000002f00000000640000000000540000000000000000000826
1600270016070000001e0000000033000816000016181b003332270a17174f000000000000000000000027000000000000002700000000000000000000000f00000f00000000000000000000000000002e003e007700000000000000000000000000000000000000000000000000000000000000000067000000000000000008
271600160700000000720000000000330008260016000000323308172726264f00000000000000000000002700000027000000000000000000000000083a3a070013000000000000000000000000000026002e003e000000000000000000000000000000000000000000000000000000000000000000060600003e0000000008
1626160700000000001e0000000000003308001600000032000029170026002607000000000000000000000000002700000000000000000000000000000f003300130000000000000000000000000032160026002e00003e0000003e0000003e000000000000000000000000000000000000000000001f0000002e0000000008
16260c00000000090606060c000077000000260016003200000a17172627002600000000000000000000000000000000000000000000000000000000000f6000331f0000000000000000000000003200000016002600002e0000002e0000002e0000000000000006060600000000000000000000060013000009190000000008
__sfx__
00100010046000160004600034000460002400024000240003400044000440001600016000340004600046001760015620156301563016630166301763017630176301b6301c6301c6301d6301d6301d6301d630
001000200373004730037300372003720037200372003730037300373002730027300474004730037300274003720037200272002720017300173002730017300373003730037300373005730057300472003720
001000200572005720077200872005710027100171001710017100171001720017200272001720037200573007720087200672006730057300373001730017300373005730087300974009730077300573003730
011000201c522105221c522105221c522105221c522105221c522105221c522105221c522105221c52210522195320d532195320d532195320d532195320d532195320d532195320d532195320d532195320d532
011000100105001050010500105001050010500105001050010600106001060010600106001060010600106000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100200000009630000000860000000000000000000000000000760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100020144100b410000001c4101a4100000016410184100000000000000000000016410000000a4100000013410074101041007410044101041000000000000441000000074100641010410104100000000000
01400020144220b422000001c4241a422000001642218423144220b422000001c4241a42200000164221842313423074221042107424044231042400000000001342307422104210742404423104240000000000
012000200433404233044320433504237042340504308043041320423404232141331223400433050420704400235003350043300532007330033407044040440043400632002330013200436002340704205047
012000200b0370b0570b0370b0570b0370b0570b0370b0570b0370b0570b0370b0570b0370b0570a7370a75709037090570903709057090370905709037090570903709057090370905709037090570b7370b757
0140003f1a7311c732157321f735237340000023735000001f7311f7311c7341a735217351f733217321f7311a7311c732157331f735237340000023735017051a7361c7311a732187311c7351a735217321f735
014000200d1441015510142101530a1450a14612152101450d1441015510142101530a1450a1461215210145121030f1450d1460f1420d1460d1470d1420d145121070f143121420f1450d1460d1470d1420d145
001000201c523105271c525105261c522105241c523105271c525105261c521105271c525105221c52610524195330d533195350d531195370d534195330d532195350d536195370d534195330d535195360d532
0120002010522105221052210522105221052210522105220d5320d5320d5320d5320d5320d5320d5320d53210522105221052210522105221052210522105220d5320d5320d5320d5320d5320d5320d5320d532
011000202322523204212241c2271a2221a2221a2001a3272322423224213231c2241a3251a2221a3001a22223324212262322221322232252122623222212211c3221c3231a2231a30018225182001a2271a227
001000201a5351a5351a5351a5351a5351a5351a5351a5351c5351c5351c5351c5351c5351c5351c5351c5351a5351a5351a5351a5351a5351a5351a5351a5351c5351c5351c5351c5351c5351c5351c5351c535
00400020287341c736287321c737287341c736287371c732287351c736287321c737287331c736287341c73724742187432474418746247421874724743187442474618743247421874424746187422474718743
011000201c225232041f2241c22718222212221a2001a2271c2241f2041c2231c2251a323212221a3001c2221f3241a2261f2221a3221f2251a2261f2221a2211c3221c3231a2231a30018225182001a2271a227
01400020241371d1421c1331a145241371d1421c1331a144241371d1421c1341a147241371d1441c1331a144235641f56218563175651c56321562173071e564235641f56218563175651c56321562173071e564
01800020127541475616754197520f754167560f7510d752127541475616754197520f754167560f7540d7521275414756167540d7520f754167560f7510d7521e7542075622754197521b754227561b75319752
01100020191211912319121191230110001100011000c100121201212012120121201f1000410004100051001b1211b1231b1211b123041000410005100051001912019120191201912006100021001d1001c100
01100020220352203519035190351e0331e0331b0331b0331e0351e0351b0351b0351e0331e0331b03319033190351e0351b0351e03520033200331e03320033200352003519035190352003320033200331b033
01080020146340f600146330f606186041960112035126341160313603146000f603146330f603146330d603146310f602146330f6070d602146040f637146320f6040d6320d604146020f637146030f63114633
01100020146340f630146330f636186041960112035126341160313603146000f603146330f603146330d603146310f632146330f6370d602146040f637146320f6040d6320d604146020f637146030f63114633
0140002017634186331b6271b6231262514623166261762310624116231462716623106271362514625156230b6240d6230f6271062406627096230c6240e6250363705632066330863402627036250464504643
014000201113211130111331113511142111421114211145101311013010133101351014210142101421014511131111301113311135111421114211142111451013110130101331013510142101421014210145
014000200d2200d2200d2200d2200d2200d2200d2200d22009220092200922009220092200922009220092200d2200d2200d2200d2200d2200d2200d2200d2201522015220152201522015220152201522015220
014000201213212132121331213612142121421214312146111311113211133111351114211142111431114712131121321213312135121421214212143121471113111132111331113511142111421114311146
014000200d2200d2200d2200d2200d2200d2200d2200d22016220162201622016220162201622016220162200d2200d2200d2200d2200d2200d2200d2200d2201622016220162201622016220162201622016220
014000202a0242a0222a0042a022250252a0222a0222502224022290222700224022290222702227022290220100025025250252a0252e02425021250222a02217000290242e0242902424024290212902224022
0120002012030121301203012150120301213012050121300f0300f1300f0300f1500f0300f1300f0500f1300d0300d1300d0300d1500d0300d1300d0500d1300f0300f1300f0300f1500f0300f1300f0500f130
0120002012030121301203012150120301213012050121300f0300f1300f0300f1500f0300f1300f0500f1300d0300d1300d0300d1500d0300d1300d0500d1300803008130080300815008030081300805008130
0110002022030220301c0001a0001e030220301e030000002203022030111000000000000000001b030190301e0301e03000000000001e0301b0301e020000002002020020000000000000000000000000000000
01100020126341e132126311e434121331e6311d5321d4361c633282341c636285351c133286321a53126435126331e237126341e733125331e6321a2311a3361f6332b5341f6352b2331f1342b6320f73125433
01100020126441e142126411e444121431e6411d5421d4461c643282441c646285451c143286421a54126445126431e247126441e743125431e6421a2411a3461864324544186452424318144246420f74125443
014000202522419222192222522325224192221922225221212241522215222212232122415222152222122125224192221922225223252241922219222252212122415222152222122321224152221522221221
014000201b3042754228542275422554125545255422554500602255422a5442754125541255452554225545006042954225544295422554125545255422554500604295422a5422754125541255452554225545
012000202444124414244412465424451246542445124654184511865418451186541845118654184511865421451214012145121401214512140121451214011545115401154511540115451154011545115401
001000001b3042755228554275520060518646006041860400604255522a554275512555118646006041860400604295522655429552255521864625552255520060426554295522655425551186460060418604
01100020126441e142126411e444121431e6411d5021d4061964325244196462554519143256422154121445126431e247126441e743125431e64219201193061f6432b5441f6452b2431f1442b6420f74125443
014000202560319603256031960300000073000000000000000000000000000043000000000000000000000000000000000000000000000000730000000000002520319200252031920125613196232563319643
012000201d23712134222320d6322110515537221350d636227370f433221321213422407104331d13415235197320d23322432126351c1020e3351c6370e132214331223622232116331c604154371e63316532
01100020276450d6040f6450d604276450d6040f6450d6040f6450d604276450d645276450d6040f6450d6040f6450d6040f6450d604276450d6050f6450d6040f6450d6040f6450d6040f6450d604276450d645
011000200d63100002000042a446000062a4442763200007000012a6441904200001350332504226003200341e044000020c6410000400001000021e0441e0412373117731177011d64400001000020000418006
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
01 41 42 09 05
01 41 08 09 05
00 41 09 08 05
00 08 09 0a 05
02 08 09 0a 05
01 03 04 05 44
00 03 04 05 44
01 10 0f 05 44
01 10 0f 05 44
00 10 0f 05 0e
02 10 0f 05 11
01 0d 42 05 04
01 0d 0b 05 04
02 0d 0b 05 07
01 13 17 43 44
03 13 15 16 44
01 18 19 1a 44
00 18 1b 1c 44
00 18 19 1a 44
02 18 1b 1c 1d
01 1e 42 43 44
00 1f 42 43 44
00 1e 20 43 44
02 1f 20 43 44
01 21 28 43 44
01 21 23 43 44
01 27 23 43 44
02 27 23 24 44
01 29 42 43 44
01 29 2a 43 44
02 29 2a 2b 44
01 19 1a 43 44
02 1b 1c 43 44
01 19 42 43 44
02 1b 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
