pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ghost house
-- by kittenm4ster and aubrianne
-- for #spookyseptemberjam

-- constants
fps = 60
state_menu = 1
state_cutscene = 2
state_transition = 3
state_title = 4

function _init()
	-- globals
	art = nil
	coroutines = {}
	sel = 1
	inventory = {}
	titleflicker = 1
	creditcolor1 = 9
	creditcolor2 = 7
	ghostcount = 0

	state = state_title
	showtitle = true
	load_room(10)
	menuy = roomh - 5
	music(6)

	cr(function()
		room.cam = {x = 0, y = -5}

		wait(fps * 3)

		local len = fps * 4
		for i = 1, len do
			room.cam.y = ease_in_out_quad(i, -5, 24, len)
			yield()
		end
		showtitle = false

		repeat yield() until stat(24) == -1
		state = state_cutscene
		wait(fps)
		show_message('you find yourself outside a house on halloween night...')
		wait(20)
		state = state_menu
	end)
end

function load_room(n)
	room = rooms[n]

	local addr = room_art_addr[n][1]
	local len = room_art_addr[n][2]

	local shapes, patterns
	if len > 0 then
		local reader = new_painting_reader(addr, len)
		shapes, patterns = parse_painting(reader)
	else
		shapes = {}
		patterns = {}
	end

  art = {
    shapes = shapes,
    patterns = patterns,
  }

	prevroomh = roomh or 0
	roomh = 0
	for _, s in pairs(shapes) do
		for _, p in pairs(s.points) do
			roomh = max(roomh, p.y + 1)
		end
	end
	menuy = roomh + 4

	room.coroutines = room.coroutines or {}
	room.sprites = room.sprites or {}

	if not room.didinit and room.init then
		room:init()
		room.didinit = true
	end

	if room.post_load then
		room:post_load()
	end

	sel = 1
end

function cr(func)
	add(coroutines, cocreate(func))
end

function room_cr(func)
	add(room.coroutines, cocreate(func))
end

function _update60()
	update_coroutines(coroutines)
	update_coroutines(room.coroutines)

	if state == state_menu then
		update_menu()
	elseif state == state_title then
		titleflicker -= .007
	end
end

function update_coroutines(coroutines)
  for cr in all(coroutines) do
    if costatus(cr) ~= 'dead' then
      assert(coresume(cr))
    else
      del(coroutines, cr)
    end
  end
end

function _draw()
  cls(1)

	draw_room()

	if room.cam then
		camera(room.cam.x, room.cam.y)
	end

	if room == rooms[10] and state ~= state_title then
		rectfill(0, menuy - 2, 127, 150, 1)
	end

	if state == state_menu then
		draw_menu()
	elseif state == state_cutscene and message then
		color(7)
		print(message, 3, menuy)
		if prompt then
			camera()
			print(prompt, 3, 120)
		end
	elseif state == state_transition then
		draw_wipe()
	end

	if room.cam then
		camera(room.cam.x, room.cam.y)
	end

	if state == state_title then
		draw_titles()
	end

	foreach(room.sprites, draw_sprite_speech)
end

function draw_titles()
	if showtitle then
		local title = 'ghost house'
		for i = 1, #title do
			s = sub(title, i, i)
			if rnd() > titleflicker then
				bigprint(s, 5 + ((i - 1) * 11), 3)
			end
		end
	end

	if stat(20) % 2 == 0 and creditcolorn ~= stat(20) then
		creditcolorn = stat(20)
		creditcolor1, creditcolor2 = creditcolor2, creditcolor1
	end

	if creditcolor1 == 7 then
		y1 = 124
		y2 = 125
	else
		y1 = 125
		y2 = 124
	end

	cprint(' y k t e m s e ', 64, y1, creditcolor1)
	cprint(' a k r u d   y a b i n e', 64, y1 + 7, creditcolor1)

	cprint('b   i t n 4 t r', 64, y2, creditcolor2)
	cprint('b c g o n s b   u r a n ', 64, y2 + 7, creditcolor2)
	cprint('for spooky september jam 2019', 64, 139, 9)
end

function show_message(msg)
	message = wrap(msg, 30)
	wait(fps * 2)
	prompt = 'press é to continue'
	repeat yield() until btnp(é)
	message, prompt = nil, nil
end

function draw_room()
  for i = 1, #art.shapes do
		if room.cam then
			camera(room.cam.x, room.cam.y)
		end

		for s in all(room.sprites) do
			if i == s.i then
				pal()
				draw_sprite(s)
			end
		end
		if i == room.specdrawi then
			room:specdraw()
		end

		if room.palette then
			apply_palette(room.palette)
		end

    local shape = art.shapes[i]
    draw_shape(shape, true)
		fillp()
		camera()
  end

	pal()
end

function apply_palette(p)
	for c, v in pairs(p) do
		pal(c, v)
	end
end

function draw_sprite(s)
	if room.spritecamy then
		camera(0, room.spritecamy)
	end

	local sx, sy, sw, sh, dx, dy, dw, dh, flipx = get_sspr_params(s)

	if s.clipbox then
		clip(s.clipbox.x, s.clipbox.y, s.clipbox.w, s.clipbox.h)
	end

	if s.palette then
		apply_palette(s.palette)
	end

	sspr(sx, sy, sw, sh, dx, dy, dw, dh, s.flipx)

	if s.palette then
		pal()
	end
	clip()

	camera()
end

function get_sspr_params(s)
	local sx, sy = spr_xy(s.s)
	local dx, dy = add_offset(s, s.offset)
	local sw = (s.sw or 1) * 8
	local sh = (s.sh or 1) * 8
	local dw = sw * (s.scale or 1)
	local dh = sh * (s.scale or 1)

	return sx, sy, sw, sh, dx, dy, dw, dh, s.flipx
end

function draw_sprite_speech(s)
	local sx, sy, sw, sh, dx, dy, dw, dh, flipx = get_sspr_params(s)

	if s.txt then
		cprint(s.txt, dx + (dw / 2), s.y - 7 - (s.scale or 1), 7, 1, 0)
	end
end

function say(sprite, txt)
	for i = 1, #txt do
		sprite.txt = sub(txt, 1, i)
		wait(3)
	end
	wait(max(30, #txt * 10))
	sprite.txt = nil
end

function draw_menu()
	local y1 = menuy
  local h = 8

	if room.name == 'bedroom' then
		y1 -= 1
		h = 7
	end

	cprint(room.name, 64, y1, 7)

	for i, action in pairs(room.actions) do
		local y = y1 + 8 + (h * (i - 1))
		local arrow = '  '
		if i == sel then
			rectfill(0, y - 1, 127, y + 5, 7)
			color(1)
			arrow = 'è'
		else
			color(7)
		end
		print(arrow .. action.txt, 1, y)
	end
end

function do_action(action)
	add(coroutines, cocreate(function()
		state = state_cutscene
		wait(10)

		local r1, r2 = action:func(room)

		for r in all({r1, r2}) do
			if r == true then
				del(room.actions, action)
			elseif type(r) == 'number' then
				load_room(r)
				transition()
			elseif type(r) == 'string' then
				wait(20)
				show_message(r)
			end
		end

		wait(20)

		state = state_menu
	end))
end

function transition()
	state = state_transition
	wipe()

	if room.post_transition then
		state = state_cutscene
		room:post_transition()
	end
end

function update_menu()
	if btnp(2) then
		sel -= 1
	end
	if btnp(3) then
		sel += 1
	end
	sel = mid(1, sel, #room.actions)

	if btnp(é) then
		do_action(room.actions[sel])
	end
end

function add_offset(pos, offset)
	if not offset then
		return pos.x, pos.y
	end
	return pos.x + offset.x, pos.y + offset.y
end

function wipe()
  memcpy(0x4300, 0x6000, 6912)

	wipeh = max(prevroomh, roomh)
	wipeh = min(wipeh, 6912 / 64)
	local midaddr = (wipeh / 2) * 64

	wipeoffset = 0
	while wipeoffset < midaddr do
		wait(2)
		wipeoffset += (64 * 2)
		wipeoffset = min(wipeoffset, midaddr)
	end
end

function draw_wipe()
	local len = (wipeh * 64) - (wipeoffset * 2)

  memcpy(0x6000 + wipeoffset, 0x4300 + wipeoffset, len)

  color(7)
  local y = wipeoffset / 64
  if wipeoffset < (8192 - 6912) then
    rectfill(0, 108, 127, 127 - y, 1)
  end
end

function ease_linear(t, b, c, d)
	return ((t / d) * c) + b
end

function ease_in_quad(t, b, c, d)
	t = t / d
	return c * (t ^ 2) + b
end

function ease_out_quad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function ease_in_out_quad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t ^ 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

function bezier(path, v)
	local points = {}
	for i = 1, #path - 1 do
		local a, b = path[i], path[i + 1]
		add(points, {
			x = lerp(a.x, b.x, v),
			y = lerp(a.y, b.y, v)
		})
	end

	if #points == 1 then
		return points[1]
	end

	return bezier(points, v)
end

function lerp(a, b, v)
	return a + ((b - a) * v)
end

function lerp_path(path, v)
	-- determine segment
	local segcount = #path - 1
	local i = min(flr(segcount * v) + 1, segcount)

	-- return progress on segment
	local v2 = (v * segcount) - (i - 1)
	local a, b = path[i], path[i + 1]
	return {
		x = lerp(a.x, b.x, v2),
		y = lerp(a.y, b.y, v2)
	}
end

function lerp_path_1d(path, v)
	-- determine segment
	local segcount = #path - 1
	local i = min(flr(segcount * v) + 1, segcount)

	-- return progress on segment
	local v2 = (v * segcount) - (i - 1)
	local a, b = path[i], path[i + 1]
	return lerp(a, b, v2)
end

function play_anim(anim)
	for v = 1, anim.len do
		anim:update(v)
		yield()
	end
end

function update_path_anim(path, v, len, ease, posinterp)
	local w = ease(v, 0, 1, len)
	return posinterp(path, w)
end

function update_1d_path(path, v, len, ease)
	local w = ease(v, 0, 1, len)
	return lerp_path_1d(path, w)
end

-- item sprites
fruit = {i = 80, s = 78, sw = 2, sh = 2, x = 36, y = 64}
handle = {s = 74, x = 0, y = 0}
cookie1 = {i = 110, s = 90, x = 100, y = 72}
cookie2 = {i = 110, s = 90, x = 109, y = 68}
cookie3 = {i = 110, s = 90, x = 112, y = 73}

-- ghost sprites
hallghost = {i = 59, s = 70, x = 0, y = 0, offset = {x = -4, y = -4}}
pianoghost = {
	i = 51, s = 71, x = 0, y = 0, clipbox = {x = 0, y = 0, w = 87, h = 100}
}
diningghost = {i = 56, s = 73, x = 0, y = 0, scale = 2}
showerghost = {i = 44, s = 75, x = 69, y = 8}
bedghost = {i = 5, s = 77, x = 0, y = 0, offset = {x = -4, y = -4}}

hallghost_anim_1 = {
	sprite = hallghost,
	len = 66,
	path = {
		{x = 36, y = 48},
		{x = 41, y = 48},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_out_quad, bezier)
		self.sprite.x = pos.x
		self.sprite.y = pos.y
	end
}

hallghost_anim_2 = {
	sprite = hallghost,
	len = 200,
	path = {
		{x = 41, y = 48},
		{x = 47, y = 69},
		{x = 110, y = 74},
		{x = 20, y = 21},
		{x = 83, y = 31},
		{x = 79, y = 49},
		{x = 115, y = -1}
	},
	scalepath = {1, 1, 1, .7, .7, .8},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_linear, bezier)
		self.sprite.x = pos.x
		self.sprite.y = pos.y

		self.sprite.scale = update_1d_path(self.scalepath, v, self.len, ease_linear)
	end
}

pianoghost_anim_1 = {
	sprite = pianoghost,
	len = 220,
	path = {
		{x = 45, y = 43},
		{x = 45, y = 41},
		{x = 45, y = 37},
		{x = 45, y = 31},
		{x = 45, y = 28},
		{x = 45, y = 31},
		{x = 45, y = 28},
		{x = 45, y = 31},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_linear, lerp_path)
		self.sprite.x = pos.x
		self.sprite.y = pos.y
	end
}

pianoghost_anim_2 = {
	sprite = pianoghost,
	len = 100,
	path = {
		{x = 45, y = 31},
		{x = 40, y = 29},
		{x = 39, y = 28},
		{x = 91, y = 26},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_linear, bezier)
		self.sprite.x = pos.x
		self.sprite.y = pos.y

		if v > 30 then
			pianoghost.s = 72
		end
	end
}

diningghost_anim_1 = {
	sprite = diningghost,
	len = 182,
	path = {
		{x = 97, y = 34},
		{x = 97, y = 31},
		{x = 97, y = 34},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_linear, lerp_path)
		self.sprite.x = pos.x
		self.sprite.y = pos.y
	end
}
diningghost_anim_2 = {
	sprite = diningghost,
	len = 126,
	path = {
		{x = 97, y = 34},
		{x = 95, y = 31},
		{x = 30, y = 28},
		{x = -30, y = 70},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_linear, bezier)
		self.sprite.x = pos.x
		self.sprite.y = pos.y
	end
}

showerghost_anim_1 = {
	sprite = showerghost,
	len = 192,
	path = {
		{x = 70, y = 10},
		{x = 68, y = 11},
		{x = 68, y = 14},
		{x = 68, y = 16},
		{x = 68, y = 16},
		{x = 68, y = 16},
		{x = 68, y = 16},
		{x = 68, y = 16},
		{x = 68, y = 16},
		{x = 68, y = 16},
		{x = 68, y = 20},
		{x = 68, y = 19},
		{x = 68, y = 37},
		{x = 67, y = 40},
	},
	scalepath = {.2, 1, 2, 2, 2, 2},
	update = function(self, v)
		self.sprite.scale = update_1d_path(self.scalepath, v, self.len, ease_linear)

		local pos = update_path_anim(self.path, v, self.len, ease_linear, bezier)
		self.sprite.x = pos.x - (self.sprite.scale * 4)
		self.sprite.y = pos.y - (self.sprite.scale * 4)

		if v == self.len then
			self.sprite.s = 76
		end
	end
}
showerghost_anim_2 = {
	sprite = fruit,
	len = 104,
	path = {
		{x = 72, y = 71},
		{x = 72, y = 71},
		{x = 67, y = 47},
		{x = 67, y = 42},
	},
	scalepath = {1.0, 1.0, 0.9, 0.7},
	update = function(self, v)
		self.sprite.scale = update_1d_path(self.scalepath, v, self.len, ease_linear)

		local pos = update_path_anim(self.path, v, self.len, ease_out_quad, bezier)
		self.sprite.x = pos.x - (self.sprite.scale * 8)
		self.sprite.y = pos.y - (self.sprite.scale * 8)

		if v >= 62 then
			self.sprite.i = 43
		else
			self.sprite.i = 45
		end

		if v >= 80 then
			sset(90, 34, 9)
			sset(93, 34, 9)
			sset(98, 34, 9)
			sset(101, 34, 9)
		end
	end
}
showerghost_anim_3 = {
	sprite = showerghost,
	len = 99,
	path = {
		{x = 67, y = 40},
		{x = 136, y = 22},
		{x = -60, y = 38},
	},
	scalepath = {2, 2, 2, 1.9, 3},
	update = function(self, v)
		self.sprite.scale = update_1d_path(self.scalepath, v, self.len, ease_linear)

		local pos = update_path_anim(self.path, v, self.len, ease_in_quad, bezier)
		self.sprite.x = pos.x - (self.sprite.scale * 4)
		self.sprite.y = pos.y - (self.sprite.scale * 4)

		if v >= 51 then
			self.sprite.i = 42
			fruit.i = 41
		end

		if not fruit.ghostoffset then
			fruit.ghostoffset = {
				x = fruit.x - showerghost.x,
				y = fruit.y - showerghost.y,
				scaleq = showerghost.scale / fruit.scale
			}
		end
		fruit.x, fruit.y = add_offset(self.sprite, fruit.ghostoffset)
		fruit.scale = self.sprite.scale / fruit.ghostoffset.scaleq
	end
}

bed_anim = {
	len = 152,
	path = {
		{x = 0, y = 0},
		{x = 0, y = 1},
		{x = 0, y = -2},
		{x = 0, y = -1},
		{x = 0, y = 1},
		{x = 0, y = -2},
		{x = 0, y = -1},
		{x = 0, y = 1},
		{x = 0, y = -2},
		{x = 0, y = -1},
		{x = 0, y = 1},
		{x = 0, y = -2},
		{x = 0, y = -1},
		{x = 0, y = 0},
		{x = 0, y = 1},
		{x = 0, y = 0},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_linear, lerp_path)
		local shapes = {
			art.shapes[6],
			art.shapes[35],
			art.shapes[37],
			art.shapes[39],
			art.shapes[40]
		}
		for _, shape in pairs(shapes) do
			shape.offset = {x = 0, y = pos.y}
		end
	end
}

bedghost_anim_1 = {
	sprite = bedghost,
	len = 58,
	path = {
		{x = 44, y = 79},
		{x = 47, y = 88},
		{x = 59, y = 91},
		{x = 60, y = 91},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_out_quad, bezier)
		self.sprite.x = pos.x
		self.sprite.y = pos.y

		if v >= 36 then
			self.sprite.flipx = true
		end
	end
}

bedghost_anim_2 = {
	sprite = bedghost,
	len = 134,
	path = {
		{x = 59, y = 91},
		{x = 88, y = 121},
		{x = 61, y = 12},
		{x = 132, y = 50},
	},
	update = function(self, v)
		local pos = update_path_anim(self.path, v, self.len, ease_in_quad, bezier)
		self.sprite.x = pos.x
		self.sprite.y = pos.y

		self.sprite.flipx = false
		self.sprite.i = 86
	end
}

font = 'abcdefghijklmnopqrstuvwxyz'

function font_i(chr)
	for i = 1, #font do
		if sub(font, i, i) == chr then
			return i
		end
	end
	return -1
end

function font_xy(chr)
	local i = font_i(chr) - 1
	if i == -2 then
		return nil
	end

	local x = (i % 11) * 11
	local y = flr(i / 11) * 14
	local w = letter_w(x, y)

	return x, y, w
end

function letter_w(x, y)
	for u = x + 9, x, -1 do
		for v = y, y + 12 do
			if sget(u, v) > 0 then
				return u - x + 1
			end
		end
	end
end

function bigprint(s, x, y)
	y += sin(t() * .5) * 2.5

	for i = 1, #s do
		local y2 = y + (cos(t()*.87 + x/12)) * 2
		local sx, sy, w = font_xy(sub(s, i, i))
		if sx then
			sspr(sx, sy, 10, 13, x, y2, 10, 13)
		end
		x = x + (w or 10) + 1
	end
end

function assign(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end
end

function cprint(s, x, y, c, bg, minx)
	local x = x - flr(txtw(s) / 2)
	if minx then
		x = max(minx, x)
	end

	if bg then
		for yo = -1, 1 do
			for xo = -1, 1 do
				if not (yo == 0 and xo == 0) then
					print(s, x + xo, y + yo, bg)
				end
			end
		end
	end

	print(s, x, y, c)
end

function deep_copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		if type(v) == 'table' then
			t2[k] = deep_copy(v)
		else
			t2[k] = v
		end
	end
	return t2
end

function distance(a, b)
	return sqrt(((a.x - b.x) ^ 2) + (a.y - b.y) ^ 2)
end

function insert(t, v, i)
	for j = #t, i, -1 do
		t[j + 1] = t[j]
	end
	t[i] = v
end

function rnd_int(a, b)
	return flr(rnd((b + 1) - a)) + a
end

function shallow_copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

function spr_xy(s)
  local x = (s % 16) * 8
  local y = flr(s / 16) * 8
  return x, y
end

function txtw(txt)
	txt = tostr(txt)
	local w = 0
	for i = 1, #txt do
		if sub(txt, i, i) == 'é' then
			w += 8
		else
			w += 4
		end
	end
	return max(0, w - 1)
end

function wait(frames)
	for i = 1, frames do
		yield()
	end
end

function wrap(s, w)
	if #s <= w then
		return s, 1
	end

	local new = ''
	local a, b = 1, w + 1

	while b > a do
		local c = sub(s, b, b)
		if c == ' ' or c == '\n' then
			new = new .. sub(s, a, b - 1) .. '\n'
			a = b + 1
			b = a + w
		else
			b -= 1
		end
		if b > #s then
			b = #s
			new = new .. sub(s, a)
			break
		end
	end
	return new
end

rooms = {}

room_art_addr = {
	[1] = {0x0f67, 697},
	[2] = {0x1220, 775},
	[3] = {0x1527, 653},
	[4] = {0x17b4, 693},
	[5] = {0x1a69, 567},
	[6] = {0x1ca0, 1009},
	[7] = {0x2091, 739},
	[8] = {0x2374, 0},
	[9] = {0x2374, 1097},
	[10] = {0x27bd, 2115},
}

rooms[1] = {
	name = 'hall',
	post_transition = function(self)
		if not self.didintromusic then
			self.didintromusic = true
			music(0)
			repeat yield() until stat(24) == -1 or (stat(24) == 1 and stat(20) >= 2)
			show_message(
				'what a very old house! i wonder if anyone still lives here...')
		end
	end,
	actions = {
		{
			txt = 'say "hello?"',
			func = function(self, room)
				ghostcount += 1
				music(2)
				add(room.sprites, hallghost)
				play_anim(hallghost_anim_1)

				for v = 1, hallghost_anim_2.len do
					hallghost_anim_2:update(v)
					yield()
				end
				del(room.sprites, hallghost)

				return "oh my! it seems there are ghosts in this house!", true
			end
		},
		{
			txt = 'go through the left door',
			func = function(self)
				self.txt = 'go left to the piano room'
				return 2
			end
		},
		{
			txt = 'go through the right door',
			func = function(self)
				self.txt = 'go right to the dining room'
				return 3
			end
		},
		{
			txt = 'go up the stairs',
			func = function()
				return 5
			end
		}
	}
}

rooms[2] = {
	name = 'piano room',
	actions = {
		{
			txt = 'check behind the curtain',
			func = function()
				return 'there is a spider behind the curtain. you pay no attention to it.'
			end
		},
		{
			txt = 'play the piano',
			func = function(self, room)
				if pianoghost.found then
					return 'great playing! i can tell you have been practicing.'
				end

				music(4)

				ghostcount += 1
				add(room.sprites, pianoghost)
				play_anim(pianoghost_anim_1)
				play_anim(pianoghost_anim_2)
				pianoghost.found = true
				del(room.sprites, pianoghost)

				return 'a ghost came out! it must have enjoyed the music.'
			end
		},
		{
			txt = 'leave the piano room',
			func = function() return 1 end
		}
	}
}

rooms[3] = {
	name = 'dining room',
	init = function(self)
		add(self.sprites, fruit)
	end,
	actions = {
		{
			txt = 'pick up the bowl of fruit',
			func = function(self, room)
				inventory.fruit = true
				fruit.palette = nil
				del(room.sprites, fruit)
				return "you put the bowl of fruit in your pocket.", true
			end,
		},
		{
			txt = 'blow out the candle',
			func = function(self, room)
				ghostcount += 1

				fruit.palette = {
					[2] = 1
				}
				room.palette = {
					[7] = 2,
					[9] = 1,
				}
				del(art.shapes, art.shapes[79])

				add(room.sprites, diningghost)
				sfx(21)
				play_anim(diningghost_anim_1)
				play_anim(diningghost_anim_2)
				del(room.sprites, diningghost)

				return true, 'the ghost ran away! perhaps it was afraid of the dark!'
			end
		},
		{
			txt = 'go to the kitchen',
			func = function() return 4 end
		},
		{
			txt = 'exit to the hall',
			func = function() return 1 end
		},
	}
}

rooms[4] = {
	name = 'kitchen',
	post_load = function(self)
		if inventory.handle and not self.addedhandleaction then
			self.addedhandleaction = true
			insert(self.actions, {
				txt = 'put the handle on the door',
				func = function(self, room)
					sfx(34)
					add(room.sprites, handle)
					handle.i = 29
					handle.x, handle.y = 105, 54
					room.hasdoorhandle = true
					inventory.handle = nil
					return 'the handle fits perfectly!', true
				end
			}, 1)
		end
	end,
	actions = {
		{
			txt = 'open the door on the right',
			func = function(self, room)
				if room.hasdoorhandle then
					if ghostcount == 5 then
						return 'the door opens. behind it are some stairs which lead ' ..
									 'you down into a basement...', 9
					else
						return "hmmm the door still won't open. maybe you need to " ..
						       "explore the house a bit more..."
					end
				else
					return 'there is no handle on that door! what a silly door. it ' ..
					'must be broken.'
				end
			end
		},
		{
			txt = 'go back to the dining room',
			func = function() return 3 end
		}
	}
}

rooms[5] = {
	name = 'landing',
	init = function()
		add(room.sprites, handle)
		handle.i = 50
		handle.x, handle.y = 119, 34
	end,
	actions = {
		{
			txt = 'enter the left door',
			func = function(self)
				self.txt = 'enter the bedroom'
				return 6
			end
		},
		{
			txt = 'enter the middle door',
			func = function(self)
				self.txt = 'enter the bathroom'
				return 7
			end
		},
		{
			txt = 'enter the right door',
			func = function(self, room)
				if room.gothandle then
					return "since the handle broke off, there's no way to open it."
				else
					sfx(34)
					inventory.handle = true
					room.gothandle = true
					del(room.sprites, handle)
					return 'the door handle breaks off! you put it in your pocket in ' ..
					       'case you need it later.'
				end
			end
		},
		{
			txt = 'go down the stairs',
			func = function()
				return 1
			end
		}
	}
}

rooms[6] = {
	name = 'bedroom',
	actions = {
		{
			txt = 'check under the pillows',
			func = function()
				return "there is a tooth under one of the pillows! " ..
				       "you'd better leave it there."
			end
		},
		{
			txt = 'say "are any ghosts here?"',
			func = function(self, room)
				room.speech = 'nope!'

				room.specdrawi = 5
				room.speechx = 31
				room.specdraw = function(self)
					print(self.speech, self.speechx, room.speechy, 7)
				end

				local len = 37
				for i = 1, len do
					room.speechx = ease_out_quad(i, 27, 24, len)
					room.speechy = ease_out_quad(i, 81, 8, len)
					yield()
				end
				wait(fps * 1.33)
				room.specdraw = nil
				room.specdrawi = nil

				insert(room.actions, {
					txt = 'jump on the bed',
					func = function(self, room)
						if not room.ghostleft then
							music(8)
						end

						play_anim(bed_anim)

						if not room.ghostleft then
							ghostcount += 1
							add(room.sprites, bedghost)
							play_anim(bedghost_anim_1)
							play_anim(bedghost_anim_2)
							del(room.sprites, bedghost)
							room.ghostleft = true

							return 'oops! there was a ghost after all, and it did not ' ..
							       'seem to enjoy all the noise.'
						end
					end
				}, 2)

				return 'it sounds like this room does not contain any ghosts.', true
			end
		},
		{
			txt = 'leave the bedroom',
			func = function() return 5 end
		}
	}
}

rooms[7] = {
	name = 'bathroom',
	post_load = function(self)
		if inventory.fruit and not self.addedfruitaction then
			self.addedfruitaction = true
			insert(self.actions, {
				txt = 'put bowl of fruit on toilet',
				func = function(self, room)
					ghostcount += 1
					inventory.fruit = nil
					fruit.i = 36
					fruit.x = 64
					fruit.y = 63
					fruit.scale = 1
					add(room.sprites, fruit)
					wait(40)

					music(10)
					add(room.sprites, showerghost)
					play_anim(showerghost_anim_1)

					room_cr(function()
						local started = false
						while true do
							local v = sin(t() * .8) * 1.2
							if abs(v) < .1 then
								started = true
							end

							if started then
								room.spritecamy = sin(t() * .8) * 1.2
							end
							yield()
						end
					end)

					play_anim(showerghost_anim_2)
					showerghost.s = 75
					wait(14)
					showerghost.s = 76
					wait(14)
					showerghost.s = 75
					wait(20)
					play_anim(showerghost_anim_3)

					return
						'ghost fact: some ghosts like to eat oranges in the shower.',
						true
				end
			}, 2)
		end
	end,
	actions = {
		{
			txt = 'look in the mirror',
			func = function()
				return "lookin' good!"
			end
		},
		{
			txt = 'leave the bathroom',
			func = function() return 5 end
		}
	}
}

rooms[9] = {
	name = 'secret basement',
	init = function(self)
		add(self.sprites, hallghost)
		add(self.sprites, pianoghost)
		add(self.sprites, diningghost)
		add(self.sprites, bedghost)
		add(self.sprites, showerghost)
		add(self.sprites, cookie1)
		add(self.sprites, cookie2)
		add(self.sprites, cookie3)

		assign(hallghost, {i = 30, s = 86, x = 10, y = 54, scale = 2})
		room_cr(function()
			while true do
				hallghost.x = 10 + sin(t() * .2) * 1.5
				hallghost.y = 53 + cos(t() * .3) * 1.6
				yield()
			end
		end)

		assign(pianoghost, {i = 90, s = 87, x = 49, y = 39, scale = 1})
		room_cr(function()
			while true do
				pianoghost.y = 39 + sin(t() * .2) * 1.8
				yield()
			end
		end)

		assign(diningghost, {i = 70, s = 89, x = 96, y = 35, scale = 1})
		room_cr(function()
			while true do
				diningghost.x = 96 + sin(t() * .15) * 1.5
				diningghost.y = 35 + cos(t() * .1) * .9
				yield()
			end
		end)

		assign(showerghost, {i = 110, s = 91, x = 72, y = 68, scale = 2})
		room_cr(function()
			while true do
				showerghost.y = 68 + cos(t() * .2) * 1.6
				yield()
			end
		end)

		assign(bedghost, {i = 110, s = 93, x = 107, y = 49, scale = 1, flipx = true})
		room_cr(function()
			while true do
				bedghost.y = 49 + sin(t() * .25) * .9
				yield()
			end
		end)
	end,
	post_transition = function()
		music(13)
		wait(20)
		say(hallghost, "hey!")
		say(hallghost, "it's you!")
		say(pianoghost, "you're here!")
		say(showerghost, 'we made you cookies!')
		say(diningghost, 'surprise!')
		say(bedghost, 'á ')
	end,
	actions = {
		{
			txt = 'do a dance',
			func = function()
				show_message('you do a very good dance.')
				say(showerghost, 'sweet moves')
			end
		},
		{
			txt = 'eat a cookie',
			func = function(self, room)
				show_message("you try to share with the ghosts, but they can't eat " ..
				             "any, because they are ghosts. therefore, you eat all " ..
										 "of the cookies.")
				del(room.sprites, cookie1)
				wait(20)
				del(room.sprites, cookie2)
				wait(20)
				del(room.sprites, cookie3)
				wait(90)

				say(pianoghost, "well, that's the end of the game")
				say(diningghost, "happy halloween! ")
				say(hallghost, "feel free to hang out")
				say(hallghost, "as long as you want")

				return true
			end
		},
	}
}

-- title screen
rooms[10] = {
	name = 'spooky house',
	actions = {
		{
			txt = 'go inside the spooky house',
			func = function()
				return 1
			end
		},
		{
			txt = 'run away',
			func = function()
				return 'a mysterious force prevents you from leaving!'
			end
		}
	}
}

-- vector-paint dist library

function draw_shape(shape, enablecache)
	local points = shape.points
	color(shape.col)
	fillp(art.patterns[shape.pi])

	if shape.offset then
		camera(-shape.offset.x, -shape.offset.y)
	end

	if #points == 1 then
		pset(points[1].x, points[1].y)
	elseif #points == 2 then
		line(points[1].x, points[1].y, points[2].x, points[2].y)
	elseif #points >= 3 then
		fill_polygon(shape, enablecache)
	end
end

function find_bounds(points)
	local x1 = 32767
	local x2 = 0
	local y1 = 32767
	local y2 = 0
	for _, point in pairs(points) do
		x1 = min(x1, point.x)
		x2 = max(x2, point.x)
		y1 = min(y1, point.y)
		y2 = max(y2, point.y)
	end

	return x1, x2, y1, y2
end

function find_intersections(points, y)
	local xlist = {}
	local j = #points

	for i = 1, #points do
		local a = points[i]
		local b = points[j]

		if (a.y < y and b.y >= y) or (b.y < y and a.y >= y) then
			local x = a.x + (((y - a.y) / (b.y - a.y)) * (b.x - a.x))

			add(xlist, x)
		end

		j = i
	end

	return xlist
end

function fill_polygon(p, enablecache)
	if not p.linecache then
		p.linecache = {}

		local x1, x2, y1, y2 = find_bounds(p.points)
		for y = y2, y1, -1 do
			local xlist = find_intersections(p.points, y)
			sort(xlist)

			for i = 1, #xlist - 1, 2 do
				local x1 = flr(xlist[i])
				local x2 = ceil(xlist[i + 1])
				add(p.linecache, {x1 = x1, x2 = x2, y = y})
			end
		end
	end

	-- draw the cached scanlines
	for _, l in pairs(p.linecache) do
		rectfill(l.x1, l.y, l.x2, l.y, p.col)
	end

	if not enablecache then
		p.linecache = nil
	end
end

function sort(t)
	for i = 2, #t do
		local j = i
		while j > 1 and t[j - 1] > t[j] do
			t[j - 1], t[j] = t[j], t[j - 1]
			j -= 1
		end
	end
end

function new_painting_reader(addr, len)
	return {
		offset = 0,
		addr = addr,
		len = len,

		get_next_byte = function(self)
			local byte = peek(self.addr + self.offset)
			self.offset += 1
			return byte
		end,

		eof = function(self)
			return self.offset >= self.len
		end,

		end_of_shapes = function(self, patterncount)
			if patterncount > 0 then
				return self.offset == self.len - (patterncount * 2) - 1
			else
				return self:eof()
			end
		end
	}
end

function parse_painting(reader)
	local shapes = {}
	local patterns = {}
	local maxpat = 0

	-- read each shape
	repeat
		local shape = {
			points = {}
		}

		-- read the fill-pattern index and point count
		local b1 = reader:get_next_byte()
		shape.pi = shr(band(b1, 0b11000000), 6)
		local pointcount = band(b1, 0b00111111)

		-- update running pattern count
		maxpat = max(maxpat, shape.pi)

		-- read the color
		shape.col = reader:get_next_byte()

		-- read each point
		for i = 1, pointcount do
			local x = reader:get_next_byte()
			local y = reader:get_next_byte() - 1
			add(shape.points, {x = x, y = y})
		end

		add(shapes, shape)
	until reader:end_of_shapes(maxpat)

	if maxpat > 0 then
		for i = 1, maxpat do
			local b1 = reader:get_next_byte()
			local b2 = reader:get_next_byte()
			local pattern = bor(shl(b1, 8), b2)
			add(patterns, pattern)
		end
		local tb = reader:get_next_byte()
		for i = 1, maxpat do
			local mask = shr(0b10000000, i - 1)
			if band(tb, mask) > 0 then
				patterns[i] += 0x0.8
			end
		end
	end

	return shapes, patterns
end

__gfx__
00077770000007777700000007777700000777770000007777700000077777000000077777000077000077000777777700007777777000077000700000000000
00700007000070000070000070000070007000007000070000070000700000700000700000700700700700707000000070070000000700700707070000000000
07000000700700000007000700000007070000000700700000007007000000070007000000070700700700707000000700070000007000700707007000000000
70007700070700070007007000077707070007000700700077770007000777700070000770070700700700700770077000007700070000700707007000000000
70070070070700707007007000700070070070700070700700000007007000000070007007700700700700700070070000000070070000700707007000000000
70077770070700770070007007000000070070070070700777700007007777000070070000000700777700700070070000000070070000700770070000000000
70000000070700000007007007000000070070070070700000070007000000700070070007700700000000700070070000000070007000700000007000000000
70007700070700077000707007000000070070070070700077700007000777000070070070070700077000700070070000000007007000700077000700000000
70070070070700700700707000700070070070070070700700000007007000000070007007070700700700700070070000007007007000700700700700000000
70070070070700777000707000077707070077700070700077770007007000000070000770070700700700700770077700070770007000700700700700000000
70070070070700000000700700000007070000000070700000007007007000000007000000070700700700707000000070070000007000700700700700000000
07070070700070000007000070000070007000000700070000070000707000000000700000700070700707007000000700007000070000707000707000000000
00700007000007777770000007777700000777777000007777700000070000000000077777000007000070000777777000000777700000070000070000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000077000077000770000770000077777000007777700000007777700000777770000000777700000777777700000700007000007000070000000000
70700000000700700700707007007007000700000700070000070000070000070007000007000007000070007000000070007070070700070700707000000000
70070000000700700700707007007007007000000070700000007000700000007070000000700070000007007000000700070070070070700700700700000000
70070000000700700700707000707007070000700070700077707007000070007070007770700070077770000770077000070070070070700700700700000000
70070000000700077000707000077007070007070070700700707007000707007070070070700070700000000070070000070070070070700700700700000000
70070000000700000000707000007007070070070070700777007007007007007070077700700070077700000070070000070070070070700700700700000000
70070000000700700700707007000007070070070070700000070007007007007070000007000007000070000070070000070070070070700707000700000000
70070000000700777700707007700007070070070070700077700007007070007070007700700000777007000070070000070070070070700707007000000000
70070000000700700700707007070007070070700070700700000007007070007070070700700070000700700070070000070070070070700707007000000000
70007777000700700700707007007007070007000070700700000007000700070070070700700707777700700070070000070007700070700070007000000000
70000000700700700700707007007007070000000700700700000007000000007070070700700700000000700070070000070000000070070000070000000000
70000007000070700707007070000707007000007000070700000000700007707070070707000070000007000007070000007000000700007000070000000000
07777770000007000070000700000070000777770000007000000000077770070007700070000007777770000000700000000777777000000777700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700007000077000770000770007700000777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070070700700707007007007070070007000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070070070700707007007000700070007000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070070070700707007000700000700000777770070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070070070700707007000070000700000000700070000000000000077777700777777007777770010000000007770000077700022222000009990000000000
70070070070070070070000007007000000077000700000000777770770770777707707770777707111000000777777007777770022277200099999000099900
70070070070007000770000007007000000700007000000007707077777777777777777777777777010000007707707777077077222222200999999900999990
70077770070070000007000007007000007000770000000077777777777707777777077777700777000000007777777777777777077070702222222222222222
70070070070700077000700070070000070007000700000077770077777777707777777077777777000000007000000770000007077777702222222222222222
70000000070700700700700070070000070077777070000077777777077777000777770007777777000000007777777770000007070000702222222222222222
07000000700700700700700070070000070000000070000077777777007770000077700000077770000000007777777777000077077777700222222222222220
07707707700707000707000070700000070000000700000070707707000777000777000000007700000000000777777007777770070770700222222222222220
00770077000070000070000007000000007777777000000000000000077777700000000007777770009999000007770000000000022222000022222222222200
00000000000000000000000000000000000000000000000000777770770770770000000070777707091999900777777000000000022277200002222222222000
00000000000000000000000000000000000000000000000007707077777777770000000077777777999991997797797700000000222222200000022222200000
00000000000000000000000000000000000000000000000077777777770000770000000077077077919999997777777700000000077070700000000000000000
00000000000000000000000000000000000000000000000077077777777007700000000077700777999999197000000700000000077777700000000000000000
00000000000000000000000000000000000000000000000077700077077777000000000007777777999919997700007700000000077000700000000000000000
00000000000000000000000000000000000000000000000077777777007770000000000000077770099999907777777700000000077777700000000000000000
00000000000000000000000000000000000000000000000070707707000777000000000000007700009999000777777000000000070770700000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000040100010f700d7e410e420207392d4926020b121b1c0817061
60417041906020f6b0f670d640c65076b076414090c7009651962177102c1953a05312409006e1e4a2c47206b14090d1a1d151e0109000602063e15390337003
80e2a0e2e1201053a05302602065e1559035700580e4a0e4e1409052d1520263b273822010f2a0f2f16c19f4a01580458045b055e1f4e12090f61096906c19f2
a01380338053a053e1f2e120900631a42220909422051320904110d1e020904251a322201055a055e14010c1a1c190623162322090a32253039090e4e225d215
0315d32514e414f4d3f4c31513449cb332b3a263d363e24090b004c01210d11054749cb322739232c1f0004110e1f042514020b3c294c294d2b3d22020a3f294
f2401006c00622a671a6402020a313a4132020a333a43320208363c46320208393c4936912007400f4f7f4f74427c325d325d355648574859485b485e445d4f2
d4d2e4d2b4d294d2840354033423d361c3c02003744574455465548584859475a4e2a4d264e284e2640354509017c315c315b3f6b3f724509033c341c3006400
6451b3202031b331e1202017b317c15090f7d187f187f387f3a7c3202084b2c3b2402096c117c128b017b19020748274a05480347024700470e390d3a0d38250
20c1d121c100a000b031e1402097129704f744f7f1c09023d263d263f253f253d363d363242324230423e333e333031090a7134020b032b004304430021090a0
132010f3a054a0402073c3d4d3d4e373e32010e3b0e3826c12f3a00490449064b06482e3822010f4a0f4e170203314e41435244534e4347334033420109704f7
442010b01420544090b582a592b5a2c59240908282729282a29292749c94221621f610670036a1c48294321070b582449c94229492f404f4f210708282689952
644284e184d174d10052106899966486842684165416009610aaaa7202d0dd0a3090750053113100c4216510531172a072a363533473d31136107610a6d3f714
f7005010719070000010002451d3409061910041000161615090718050000010004071d0909041130033002451d3136304630443032341934421313300630004
31b38892f75466d356d324737353002400f4f7f49090f71496d366203610e311f36356d356f3f754201056f3365020103650f3312010145114632010146346d3
401026a0f5e0f531361140102631f571f5b13691401036b1f5d1f51236e1401036120622f582367240104682f5a2f5e236f24010d5d095f09551d53120105311
53524010d551957195c1d5a14010d5c195e19522d5124010d52295429582d5824010d59295a295e2d5e2201036801451401065d06593059305f04010d4213461
34e2d4e22090e47134a12090e4d134f12090e43234422090e49224922090a421a4f22090645164f22010413300632010000481a320100034036320100363d363
2010d3631473201056f3f754ec9172a061004010819041b371d3a1c3d1c3e1a322b352937293621182113c9932f0127332833020c40053c012104090d321d331
c323e3232010c331c33320108243b2232010e223d3332010e353e3412010e311161020100610862020108620a6f32010a6c3f714e110a3f3b333f313f3a2f392
83725392835223520362d252a2a242b242d222f202030223622372d38223e233e2b3e233133313b313335333639363339333202042c293c22020e30383232020
831322132020f392d3a22020d3a263a240702342634243a2f2a22070320383035020b3b2b3c29303b3d2c3a2202052c202f2d010130403437253227322143293
729372e37293b293b224c2a3037320200353c2732020c2732273201082c071302010501082112010719031d3401031d391d3e1c322a34c99d1c071c3b123b133
2010f11053c0201053c0d4102010651073012010330182a02010c12053f0201053e01510201000216171201071c00030102042f2102062f2102092f21020b2f2
1020d2f2102003f2102023f2102053f2102083f2201023624362201013824382e5a57bffaaaa0040200010f710f7150015201000b050802010804000706812d7
c3e0c300840015f715f7c320100193c7934010c35076600613c3132020266026f11010f5602020f560e5132020c550b523202085507523402045504513251325
502020f450f4232020b450b423202074508433402044504433342324502020f350f31320101363f6632020d3b034b0201080f200332020d30134012020e36134
612010135313832020e3b134b12020e31234122020f372346220109040f740202044a025a02020440135012020445135512010c250c2932010f15002a32010a1
50b1932010d050f0d3202034b135b15519d310b370e353c343c333c33383636333335323630353f2231370e210034023304310432063308310a3502020441235
122020446235622010d090a1902010f190c2902020f3c235c22010f003b10320100203b203202045b046b02010f043b143201050508043201002430243201090
20b0e320100243c243202045014601202045613661202055c126c1202045122612202045723672202045c226c24010f523f323e333163350909024900470f270
8490b4409070430083000480b305194620566026c21623367376439673c64317733733f6500730b610a65076204610209040d360f4209010e340f42090001420
054090f1c380f38014c1f3409000d421f421150015407090f310549015f0d4409031a40084009411e44090f0d40115c0b411d49090f7f2c79447a457d4b7b4f7
15f7e4d7a4f7d35c99b7b457d47715f715f715207070530093207070a300f320104750579320104780f780201057e2f7e22010f663f69320105733d733407057
b48715111531a44070428331a457b44693309054d24482546240706483448344d264d240908404542424f35483f7fd903e5a5a025010321153f0e37104746244
442120740005f705d2147921e600f301620000100005910582a49271a261b241c231e221233163519381b3c1b3b1c3c1c33466b456d1f761f710447781935163
109300c37070e4a4e4a315833533e543f5a4c5d46070b3c224a264c264543464a3443010c600f301720020101453b353201034c234542010f57325632010b3f2
b3132010b373b3932010d593a5932010b5a385a3401075734573658335832010459315932010e4b3c5c32010c5c3c5d42010f5a3c5c3401005e3950495540534
2010e464c5842090c4d3c4a4209044c34474409044b3c4d3d4b3849340904414c434d41484f340904464c484d4648444209046b406a44090f76176b156b4f705
2010e7b186f1201086f186b44090919300c300745204201096c4e7052010e7b1e7052010b7f1b7632010b763576320105763571220105702b7f120101712b622
2010b622b6632010b66317632010176317122010c6a3b7b32010b7b3b7e32010b7e3c6d32010c6c3c6a32010b604171420101714176420101764b6542010b654
b60420104714a7242010b724b7842010b78447742010477447140170440044c024e00401f3310471249134915491748184619441841174f054d044c0e190b3b2
b3c1a3d1a3c1839173715351f221d231d231a261a271b271929182b49281a261a241d241034133515371739183b183c173c183d193e1a312a3c2409082a46105
f10592c4509042144205000500644204807081b30204028450d46074003400c331932010321400742010128450d4201050d450742010507400342010221481a3
201002840224201020f351c3201051c3a1f32010a1046034101060342010603410f3d090b0b3b023b023c00311f21133213321f201d2d0d2c0e2b003c0b32010
42c480052010421442052010b19300d3409011a321a321831173409060c36093709370c38788d7da00a8210010f700f79374131293416331d2c0e2c0e3000420
2014101403b0200044c004c0e231d231d23173d1a35443f7a3f7050005b19000d3a0a38090606022a002b0026362537333540354f034d085a065d06513175317
c0f6a0f770f7c3a44322c3218311e0a0d0c004004420109080f1b0201064e055c0201027b0f790201001e0c1e02010c1e0c1a32010412241722010b402b45220
10f7e057f0201057f057a3201035113553201035118421441107f402b30205070520108421844352101514256305531533052305f215d235c265e226b226a236
8226723652465256525672467256a2f7d2f7f256c246e256f326d326e285139543a56326e3f6846664758365536533452345347210c105c154d144b114c1f3a1
d39183a163c143a113a103e1b202d212030233f123f143124322638253a233b223d213f223f23313431353339343b3f7b4f705f60502c302d302e32214024412
5412056411f7e256c2751345634534f7b450108405932423f3332404052070f7b422732070f7d266a22070b223f2232070f22323632070236353b32070c33494
052070c1c2f1c2207002d222f2207022f22213207002e3221420709553e674207075e29503207095039533207025d265d2207075d216b2207012541205207056
d256e320702263826320706662668220704652565210705692107012531070f14310704533107045633070554355435553107055432070557355144010158415
0545054594207055a455054010b2d3b205030503c3207003040305eeeef5fa0864210000f700f755567482e300a4019030e4208320f140736053e00321f261e2
a1f212331233224322423293429370e34090b2a1b3b1b3d3b2c36010e75596a4b2d300a400062806309065a4450565b4e220f35404a4d3c4a3f4a31583356355
43455375238503850395f2a5e295b2b5b2c592c582b532c591b541e531d501d5f0b5e0c5d0c5d0a5c0a5c0759055806570556045506540353025203520f430c4
3094207480d38273a293b3d30434b0901830c6f0c624e5e3e531549154d36404e514b64418c440102600c3f092d0e00080903600d3e092d0e00010009221d331
e610607092a08280a260c270d290b2b040100890f621172408744010b57195d384d374c14010d2e183d173a3e2a360900865467493149324568498b520202300
03802020431073902020435043902020b250c290607073e063b083a0b3b0b3d093f02020c290e2b02020a2b0b2d02020b2d0d2d02020d2d0f2a09020f2a0f290
23705380839073c043a0139003a02020c390b3c02020b3c083b0907063c043a0239003b0f2c013f013f043f063d0202093d093f0202083f073c06070a2409220
b200e220e230c2502020d341d3d36070334023204300732073305350309096c4961586e46070a3909370b350e370e380c3a079270444d3d3a2937293c0e39024
5094e005f0252115413531a551f5610691c5b145c1154215c2c423a473949374c364182223f0a0208023a0d371b342831223f133611371434133e03330903605
465546158070b0b311b371a3819371535143e043903380707123b133023322533273a193a15371333412608360f350e3501083d1e2d1d2f1230283023010d202
2322d232619024050425f3c4135522b52206a106d1c4d1c4c174f111f1530284f1c41265e384f3f3049214f114f324142444012096b4461545b4457465747544
65345514c5e3c593066316a32673d6a3e6c3966420101683e5f32010e5f3d5442010d54426642010d5446564201036d4658420207231728320106684a6642010
c6a3a6a32010a6a386342010863446442010464426942010568446f42010269446c42090f6a2f7922090a5b274c2209093d2c2d2409000242014203500553070
2014002400f32010301430542010206420052010301530352010206400741010200580904784574537b537e54706f706e755a7552010b755b70620103725a7f5
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
05027f4674457b547a537f54020174487b5502017b547f5402017956785402017651754f0201765e755c0202690469380409411f1e111e12412004091e11022003201e120209411f232502092325042002092b230a1c0209372112180202391e321b02023c1d351a02023b1f392002023b21392202022b1d2c1e02022c202b1f
02022c222b2202022c242b24a5b5a1000004090e4b46495c560b550a07254f2550265125522451235222512250234f234e02012450244d030728502d522852c51246010b010f4b46494601451200010a010e4a0a5500558512470147495d567f557f010b074b3b4948414f3d4e2c502c532a542950214e1c4c16400b014a3c48
47424e3e4d2b4f2b522a532a4f224d1d4b174004093a01392a192a1702c411380238281b28190311074d3a4d394b37463544343c341c361637123a123d133e153f1a4022402b3f483c4b3b0201453649380201493848390201473a1c3e13077d3a7c397434683261335e3459375a385c3c644167416649685567557155714478
437a427c3f0201763a703b0201703b6d3b02016d3b6539020165395e3611076b0e6d0c710975087a0c7d107f197f1c7d227b257a27752b712b6b266821671b681311016b106d0e700c740b780e7a127c197c1c7a2179237825742870286b246920681b691402097637763502096b346b32020974357832020974327835020969
326d2f0209692f6d3202016f35723602097537773802096a346c350e0972357134702b702b6d296d296b2d6c2d6d2b6e2b702d702f70346f35020919153a150e0759365534523450365138504350455347574a5b4a5d495f3e603a5d3712075749564e5551535154535355405541523f503d4e3d4c3c4a3d48414545444b454e
47514502015c345a3602015a365a3902094834463402015a395c3c02094733473502015d3d624102094d384b380e094c364b364b074b074805480546094707480649064b084b0a4b364a3602094409470a02094c374c3902076c177312020906490b4402076d1370110a07105510490e460d450b460947084b0a4d0d4d0f4b05
010d490b470b480a4a0c4b02090c49064902015a3c51390201584a504502015049514a0201504b4d4d02014c4d484e0201474e414d0201414d3e4c0201563d593e0301524e4e504c5202016241684302016c437843020129522c52020129512e4d010123510101255101012350edb77bdeffb400080200017f007f1473124f18
4d1a2217001248127f174d1a221700150045313a43397f390202601f603105017f394f37004100557f55040900124e1a4c1b00152f0950184d1a4b1e4b234d1d4e23501c5121521c5422551d5621581d59225b1c5c215e1b5f21611b6320641c651a651f6620671d6919691e6a206b1b6c196d1c6e1f701971157318741d7519
74167819791c7a1c7a187d1c7d187f1b7f14721202074e1d4d1f02075619551c0207591a581e020760165f1902076518641c02076a18691b02075e1c5e1e02075119501b020770146f17020774157517020779177a1a02077d157e1702076d1b6d1d0207531e532007011b051d03210324042606253c1a3e13095021503a6c3e
6c3f6d407240743f7f3d7f2d762f732e732c722c72176c196e2e542c542a542004077f2b732d732f7f2d04076c2f6c2d552b542c06077b09780775097509760a7a0a06074f134e124d114b134c144e1406073d123b103b113a123b133c130607280f29102b102c0f2a0d290e0201053e05400709333b004100553e5548524840
33390402414240444145424404023a4339453a463b450402324531473248334704022a4629482a492b4804022148204a214b224a04021749164c174d194c04020c4b0b4f0d4f0e4e0402004e00500051025002074144464602073a45464b02073347374902072a482c490207214a234b0207174b1b4f02070c4d105402070051
0155010747460101464b040138493b4b3a4c374a01012d4a0401244c264f284e254b01011c500101115504014240333c0043004c0402303c2f3e303f313e04022a3c293e2a3f2b3e0402243d233f2440253f04021d3f1c411d421e410402163f15411642174104020f400e420f4310420402074106430744084302073b41303d
02072a3e35420207243f2d4302071d402645020716401e4602070f411548020707430a4a0202363e384102023b403b410202323d334002022e41334002022743274502022442254502022241234502022040214404022f382f3c323b333802021e3f1f4302020f48164602020d4514430207044a004b07091c061e0421042305
2507253d1b3f02070347004802027e297e410202772977410202782a7d2a0402792a7a307a347c2a040275337b317e34773602070244004502070b45054802070d480a4a02071b40194502071f421d460207283d274202072b3f2a4402072f402e430207323b004102073339484002074240004c0602683568394f3d2c352c32
413005026438643d4f41303830340d02643c643f62426244644463446346634761476146604260425f3d0a02513f53425145504a504c4f4c4f4b4e454c434c400709643658345033403137322f33503902076635463501013c3301023d3301013d3401073c340407403041314132403202074235433402024335423404014f34
503450334f3202014b334a3402074a334b3402027433744002027b337b4006070c090d0a0f0a10090e070d0806075f0e600f620f630e610c600dfb5e0004017f00000100807f80c7a20067176453616c657f677f800080c9a2481b3d1a3d1e431e461f41213f2347224b22e0a22a16201419120f100d0f000f001605150d1514
1717190e190818041700180020061f0d1e141e0f2015201c212321261f1d1e191c201d271a301b261c2b1f2621dea272246c2365256226592360236424692261205d1f551f57215723532155204e1c4a1c4b255026532459256128662868276c266e26722775287c277f261f0136102f172a1828252b262b322c322c3d2b3d2b
401d411d6c326c5e6c666c64516341663f5c405c375b324d2442303e2c3e253e223e21411c43183a1736111302806d6569736c52701c6f286c136c05731874057c2b7a3f77307c27815780507b79786c7d807fc5a93d573557365636553c5606076463615661575f635f56645703076140644c644448172e1e2e1a311b321935
1437193d1b3d1e0a023408350928173217350f360f3a1742173e123509070247294b254c1f4e1e4b1f471e472104021c322b332b3c1a3c040262306a3c5c3c5c311302665364515e505c4e434e434d3c4d394a364e2f4d2c51315133503f504151465145525f525d5304022b50225120532a5304021e531c5620561e5304025d
365a324333413604022a3d1e3e1c402a400402673f653c5d3d5d3f02092b3d1b3d02092b331b33020963315c3102095e354d2402094d243f32020943183a1802093a18360f020935113317020932182818020935083504080731263a273a323a3236283529313231320209411b3e1b0209291a301a02093f183e1a02093e1a39
1a0209391a35130109311902092d182d4e02093e1b3e3102093d1f2d1f020930263b2602093b263b3402093026303402092f333c330409352635333633362602094929492f02094a2f4f2f0c074639583a584854485642523f4f3a4b3e49414742494846480209502f502902094a294f290209393b39490209393b323b020932
3b324902093249394902093243394302093e2b422f020927262a2602092a262a2a02092a2a2c1f02092c1f2b1b020928182726020943183e2402094539593902095939594802095239524802094b394b4802094539454802095c49434905094449444e5b4e5b4e5b4902092b6b1d6b0c0746555a56596557655960565c565749
57485e476049654665020922422842020928422850020922422250020922492849020922502b500209224e2c4e02092d4a434a0209434d3d4d0209354d2d4d01093c4b02093150394802093948415002093f314d2302094d235e3402093250394902093949405002095b334233020942305a3001095a3201092c4f0409471e47
1a481a481e04094a1b4b1b4b1e4a1e02095b395b4802094239424902095b374137020941373f390209403b404904096740603f6046634202095d40624002096a3c5d3c02092a401c40020920571c57020920542a5402092b532c5202092c523152020932514051020941524452020945535c5302095d54675402096456646602
0964665e6602095d674467020964565e56020945555b5502095b555b6502095355536502094c554c65020945554565020943664357030943564353415303093f563f533d530209405240650209325132650309355333543356030931532f542f5602092e542e660209226422590309225922562456030928562a562a5802092b
572b66020932523f52020921552a5502092b552e52020920581d5802095e55665542171d582058421721552b5542172e524452421745535c5382175e55665542175b3741378419423342305a305a330607333b383c3846363d353c33468519444a444d3e4d3b4a434a8419344d374a2d4a2d4d8219224f2c4f05072342274327
4d2543234d02094a2d4f2dc4175a4a5a4c454c444a02094541594102095e565e650209455d5b5d02091d411d5302091d591d6502092b322b2b0209644e5d4e84195d4e5f506450644e020964505f5002093e323e4a010941380209403b423902092249284902096046604d02093843334302095a65466502095e686468020964
68646a0209646a5e6a02095e6a5e68020955695b6902095b695b6b02095b6b556b0209556b5569020945694b6902094b694b6b02094b6b456b0209456b456902094d69536902095369536b0209536b4d6b02094d6b4d69020733533f53020741534453020731532e5302072b56215602096442644d02096148644904093d693d
573557356907073b643764365c375a3a593c5b3c5d05013c643a5f395d385f366402092964295c0209295c245ccca26a127017771a7d1880187c1b771d751c7e1f7f21741f721f0209245c24640209246429640407285d275f2560255c020924612961c3a7634161406143cba267276c29712777287129732b7b2b7e2c782d6f
2c6529c8a227094211451154194a1746123f0f2407cda25f09651067145f1555165b166619691b711d5f146a15620d580802074b6d3c7702077f6d006f020700787f770702676c6b6b6d686d636c606a5e685e02076e796e6a02074e664e7902073a663a7902071e791e6b84a92e663266326b2e6b84a93f664366436b3f6b02
0932662e6602092e6b326b02094066426602021c6400670209406b426b45a91d652a662b662b6b1d6b02091d652b65c3a7482f482b452fc3a7512a552f512fc3a74e284d264c284e177f6a526b4d664a6a3d6b3b66376b006c01793b793b784b784e797f7902027f6767650209666c665602095e606460020934533e5307021c
6a186a13681263145f195d1c5e07021360105f0a60086409670e6814660402086100640168076806026d6173617763776675686c68050278647d637f657e687868c1a17a64cda10266066406650b6313641a611b6316611864116211660b620766cba17d6675656b62686167646d616b65736272667a647b66aaaa5555a5a5e0
__sfx__
011e00000c5500c5500c5500c5500c5500c5500c5500c550181001810018100181001810018100181001810018100181001810018100181001810018100181001810018100000000000000000000000000000000
01100000185771b5671e55721547185371b5271e51721517185051b5071e507215070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000185771c5672055723547185371c5272051723517185171c51720517235170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003e61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500003f51500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300000c0620c0450c0250c01500000220542203222022220120000000000000001106211045110251101508062080450802508015000000000014014140221403214022140121401500000000000703207022
011300000701207012070150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01160000005640c5550c5350c5150000000000000000756207525005000f5620f525005000b5620b5250b5150b5050000000000000001b5001f500235001ba401ba601ba501ba501ba401ba301ba201ba101ba10
011000000205300000000000000024b250000000000020030205300000020530000024b252400000000000000205300000000000000024b250000000000020530000000000020530000024b25000000000000000
011800001c1201c1101c1201c1101d1201d1101f1201f1101f1201f1101d1201d1101c1201c1101a1201a110191371c1371f136221372813028120281102810222125000001f12500000211251e125000001d125
011800000000010115000000f11519100000000c10000100001050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e000013550135521b5501b552175501755217552185501a5501b5501a55018550175501755217552000000c5001a5000000000000000000000000000000000000000000000000000000000000000000000000
011e00000c8700c8000f8700c800138700c8000f8700f8000e8700f800148701780013870178000b870178000c8700c8000f8700c800138700c8000f8700f872118710f800148701780013870178000b8700c800
011e000018335000051e3351f335203351f3351e3351f33517335000051f335000051d335000051a3350000518335000051e3351f335203351f335233352433526335000051d3350000520335000051f33500005
011e000000560005600056000560035600356003560035600b8700b8700b8700b8700b8700b8700b8700000013530135321353213532135321353213532135320753500000000003731535315323152f31500000
011e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000175301753217532175321753217532175350000000000000000b500000000000000000
011e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d5301d5321d5321d5321a53500000000000000000000000000000000000
011e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020530205321f53500000000000000000000000000000000000
011600000d5500000000000000000e5500f5501055200500000000000000000000000000010550005000000000000115501255013552005000000000000225402554028542289322892228912289122891228915
010b00001155011552000000000000000155501a5500b5500b55200000000000000000000000001455014552000000000000000185501d5500e5500e552000000000000000000000000000000000000000000000
01110000015500555100000000000655009551000000000005550085510000000000085500b5510000000000075500a5510000015051000000000015550185511b5511b5521b5521b5421b5321b5221b5121b515
0110000000000000001894019940199301a9301a9201a9201a9101a9101a9101a9101a91500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000018555000001a555000001c555000001e55500000000000000000000000000000019555000001b555005051d555005001f555005000000001000215610000000000000000000000000000000000023500
010c00000000000000000000000023545225452154520545000000000000000000000000000000000000000000000000000000000000000000000000000000000050013501000000000000000000000000000000
01100000000000000000000000000000000000000000000000000000001a9401a9301b9301b9201b9201b9101b9101b9101b91500000000000000000000000000000000000000000000000000000000000000000
011000000e8500c8000c8000c8000c8000c800158500c800188500c8000c8001a8500c8000c80013850158510c8000c800138500c800118500c800118000e85011850138500c8500c8500c8500d8500d8500d850
011000000e8700c8000c8000c8000c8000c800158700c800188700c8000c8001a8700c8000c8001f87021871218000e870118700c800188701a870118000e8700587005870078700787008870088700987009870
011000000205300000000000000024b250000000000020530000000000020530000024b252400000000000000205300000000000000024b250000000000020530000000000020530000024b25000000000000000
011000001ba101ba101ba201ba401ba601ba501ba401ba301ba201ba101ba101ba10000000000000000000001aa101aa101aa201aa401aa601aa501aa401aa301aa101aa101aa101aa1000000000000000000000
0110000000000000000000000000000000000027514275222b5212b5222b52200000000000000022514225220d5210d5220d5220d5220c0000c0000c000225000c000215000c0000000000000000000000000000
011000000000000000000050cc300cc330cc33000000cc33000000cc330cc03000000cc33000000cc330cc3300000000000cc33000000cc330cc33000000cc33000000cc030000000000000000cc030cc030cc03
010900002961500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 08 42 43 44
04 09 42 43 44
04 0a 42 43 44
04 0b 42 43 44
00 0c 42 43 44
04 0d 42 43 44
00 11 12 13 14
04 0f 10 43 44
00 17 42 43 44
04 18 42 43 44
00 19 42 43 44
00 1a 42 43 44
04 1b 42 43 44
01 1c 1e 43 44
00 1d 0b 43 44
00 1c 1e 43 44
00 1d 0b 43 44
00 41 1e 1f 44
02 41 0b 21 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
