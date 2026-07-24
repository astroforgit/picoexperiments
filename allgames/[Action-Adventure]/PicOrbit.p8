pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- planets
-- by niels ehlen


--- global variables ---

_sf = 128 -- scaling for drawing
_massscale = 0.2 -- mass scaling for drawing
_playerscale = 1.
_dt = 0.02 -- timestep
_gc = 0.001 --  gravity constant
_gm = 0.01 -- gravity modifier (lorentzian lineshape) - modifies the maximum gravitational force
_cutoff_max = 100 -- cutoff distance where gravity of body is still considered in calculation
_cutoff_min = 0.0001 -- cutoff distance where gravity of body is still considered in calculation
_start_temp = 300 -- starting temperature of player in Kelvin
_temp_scale = 8.0 -- scaling the temperature calculation
_d_temp = -1 -- temperature change of player per frame in Kelvin
_temp_g = 0.3-- broadening of temperature distribution
_t_hot0 = 330 -- hot temperature
_t_hot1 = 375 -- game end temperature (hot)
_t_cold0 = 270 -- cold temperature
_t_cold1 = 225 -- game end temperature(cold)
_seed = flr(rnd(1000))
_num_planets = 3
_gameover_msg = ''

--- general functions ---

-- Cauchy Lorentz distribution curve centered around 0 with broadening g
function lorentzian(x, g)
	return 1/(3.1415*g*(1 + (x/g)*(x/g)))
end


--- player ---

-- create player character
function create_player(px, py, vx, vy, m, col)
	local ax, ay = calculate_force(px, py)
	-- local player
	local player = {
		x = px,
		y = py,
		dx = vx,
		dy = vy,
		ddx = ax,
		ddy = ay,
		m = m,
		clr = col,
		fline = create_fieldline(px,py,100, 0.01, col),
		temp = _start_temp
	}
	-- update function, uses velocity verlet algorithm
	function player:update(gravity)
		if debug then
			self.fline.sx, self.fline.sy = self.x, self.y
			self.fline:update()
		end
		-- take acceleration from last simulation step
		local ax0, ay0 = self.ddx, self.ddy
		if not gravity then
		 	ax0, ay0 = 0, 0
		end
		-- update position based on new acceleration
		self.x += self.dx * _dt + 0.5*ax0*_dt*_dt
		self.y += self.dy * _dt + 0.5*ay0*_dt*_dt
		-- calculate acceleration at new position
		local ax1, ay1 = 0, 0
		if _gravity then
			ax1, ay1 = calculate_force(self.x, self.y)
		end
		-- update velocity
		self.dx += 0.5*(ax0 + ax1)*_dt
		self.dy += 0.5*(ay0 + ay1)*_dt
		-- "save" acceleration from this step
		self.ddx = ax1
		self.ddy = ay1
		-- update temperature
		self.temp += (_d_temp + calculate_temperature(self.x, self.y))*_dt*_temp_scale

		if self.temp < _t_cold1 then
			_deathtimer:update()
			_gameover_msg = 'snowball!'
		elseif self.temp > _t_hot1 then
			_deathtimer:update()
			_gameover_msg = 'heat death!'
		else
			_deathtimer:reset()
		end
		if _deathtimer.ct >= 5 then
			_gamestate = 'gameover'
			sfx(17)
			gover_menu.x0 += cam.x
			gover_menu.y0 += cam.y
		end
	end

	-- draw player
	function player:draw()
		if debug and _gravity then
			self.fline:draw()
		end
		line(_sf * self.x, _sf*self.y, _sf*self.x+_sf*0.2*self.ddx, _sf*self.y+_sf*0.2*self.ddy,7)
		if self.temp > _t_hot1-5 then
			pal(3,4)
			pal(7,9)
			pal(12,9)
		elseif self.temp > _t_hot0 then
			pal(3,4)
			pal(7,12)
		elseif self.temp < _t_cold0 and self.temp >= _t_cold1+5 then
			pal(3,7)
			pal(9,3)
		elseif self.temp < _t_cold1+5 then
			pal(3,7)
			pal(12, 7)
			pal(9,7)
		end
		if _sf > 105 then
			spr(2, _sf*self.x-4, _sf*self.y-4)
		elseif _sf > 65 then
			spr(16, _sf*self.x-4, _sf*self.y-4)
		else
			spr(1, _sf*self.x-4, _sf*self.y-4)
		end
		self:draw_eyes()
		pal()
		--circfill(_sf*self.x, _sf*self.y, self.m*_playerscale, self.clr)
	end

	function player:draw_eyes()
		local eyelength = 2
		local a = 0
		local dirx, diry = 0, 0
		if _gravity and m_met(self.ddx, self.ddy) > 0.00001 then
			a = 0.5*m_met(self.ddx, self.ddy)
			dirx, diry = self.ddx/a, self.ddy/a
		else
			a = 0.5*m_met(self.dx, self.dy)
			dirx, diry = self.dx/a, self.dy/a
		end
		line(_sf*self.x+1+dirx, _sf*self.y-eyelength*0.5+diry, _sf*self.x+1+dirx, _sf*self.y+eyelength*0.5+diry,0)
		line(_sf*self.x-1+dirx, _sf*self.y-eyelength*0.5+diry, _sf*self.x-1+dirx, _sf*self.y+eyelength*0.5+diry,0)
	end

	function player:delete()
		self = nil
	end
	
	return player
end

--- particles ---
-- setup particle system
particles = {}
function create_particle(x,y,dx,dy,ddx,ddy,lifetime, size, color)
	local particle = {
		x 	= x or 0, -- pos x
		y 	= y or 0, -- pos y
		dx 	= dx or 0, -- vel x
		dy 	= dy or 0, -- vel y
		ddx	= ddx or 0, -- acc x
		ddy	= ddy or 0, -- acc y
		lt	= lifetime or 0, -- lifetime in frames
		t	= 0,
		clr	= color or 0, -- color
		s	= size or 1
	}
	-- update the particle
	function particle:update()
		self.t += 1/self.lt
		if self.t <= 1 then
			self.x += self.dx
			self.y += self.dy
			self.dx += self.ddx
			self.dy += self.ddy
		end
	end
	-- draw the particle
	function particle:draw()
		circfill(_sf*self.x, _sf*self.y, self.s*_sf/128, self.clr)
	end
	
	function particle:delete()
		if selt.t > 1 then
			self = nil
		end
	end

	return particle
end


--- stars ---
-- setup background stars
stars = {
	num = 0,
	maxnum = 128
}

function create_star(x, y, lifetime0, lifetime1)
	local star = {
		x 	= x or 0, -- pos x
		y 	= y or 0, -- pos y
		lt0	= lifetime0 or 0, -- lifetime in frames
		lt1 = lifetime1 or 0,
		t	= 0,
		state = 0,
		sprite_version = 0,
	}
	-- update the particle
	function star:update()
		self.sprite_version = flr(rnd(2))
		self.t += 1/self.lt0
		if self.t > 1 then
			self.t += 1/self.lt1
			if self.t > 2 then
				self:delete()
			end
		end
	end
	-- draw the particle
	function star:draw()
		local sprite = 3
		if self.t <= 0.3 then
			sprite = 3
		elseif self.t <= 0.5 then
			sprite = 4 + 4 * self.sprite_version
		elseif self.t <= 0.6 then
			sprite = 5 + 4 * self.sprite_version
		elseif self.t <= 0.7 then
			sprite = 6 + 4 * self.sprite_version
		elseif self.t <= 1.0 then
			sprite = 7 + 4 * self.sprite_version
		elseif self.t <= 2.0 then
			sprite = 3
		end
		spr(sprite, self.x*_sf, self.y*_sf)
	end

	function star:delete()
		stars.num -= 1
		del(stars, self)
	end

	stars.num += 1
	add(stars, star)
end

-- create a field of stars
function stars:update(x, y)
	while (self.num < self.maxnum) do
		create_star(x+(rnd(2)-1)*256/_sf, y+(rnd(2)-1)*256/_sf,rnd(300), 1)
	end
	for s in all(self) do
		s:update()
	end
end

function stars:draw()
	for s in all(self) do
		s:draw()
	end
end

function stars:delete_all()
	for s in all(self) do
		s:delete()
	end
end

--- planets ---

-- hold all celestial bodies in scene
bodies = {}

-- create a celestial body
function create_body(px, py, m, col, type, heat)
	local body = {
		x	= px,
		y	= py,
		m	= m,
		clr	= col,
		type = type or 'star',
		heat = heat or 20,

		update = function(self)
			if (self.type == 'star') self:create_aurora()
			for p in all(self.particles) do
				p:update()
			end
			self:delete_particles()
		end,
		-- delete body
		delete = function(self)
			del(bodies, self)
		end,
		-- draw body
		draw = function(self, boolean)
			local count = 0
			circfill(_sf*self.x, _sf*self.y, self.m*_massscale*_sf/128, self.clr)
			for p in all(self.particles) do
				p:draw()
			end
			self:draw_eyes()
			-- draw circles for heating zones
			--[[
			if debug then
				local count = 0
				for a=1.2,0.8,-0.1 do
					circ(_sf*self.x, _sf*self.y, _sf*_temp_g*sqrt((self.heat/10.0+a*_d_temp*3.1415*_temp_g)/(-a*_d_temp*3.1415*_temp_g)),8+count)
					count += 1
				end
			end
			--]]
		end,
		particles = {},
		flines = {}
	}

	-- radiate heat
	function body:radiate(x,y)
		local d = m_met(x-self.x, y-self.y)
		return self.heat*lorentzian(d, _temp_g) / 10.0
	end

	-- add fieldlines to body
	function body:add_fieldlines()
		local test = 0.005*self.m*_massscale
		for angle=0,1,0.0625 do
			local tx, ty = cos(angle), sin(angle)
			local fl = create_fieldline(self.x+tx*test, self.y+ty*test, 50, -0.05, 2, true, true)
			--add(self.flines, fl)
		end
	end

	-- create the aurora of the body
	function body:create_aurora()
		local test = 0.005*self.m*_massscale
		local angle = rnd(1)
		local tx, ty = cos(angle), sin(angle)
		local size = rnd(3)
		if size < 1.5 then
			p = create_particle(self.x+tx*test, self.y+ty*test, 0.001*tx, 0.001*ty, 0, 0, 50, size, 8+flr(rnd(3)))
		else
			p = create_particle(self.x+tx*test, self.y+ty*test, 0.001*tx, 0.001*ty, 0, 0, 20, size, self.clr)
		end
		add(self.particles, p)
	end

	-- draw the eyes of the body towards the player
	function body:draw_eyes()
		local eyelength = 2
		if plyr then
			local a = 1.7*m_met(self.x-plyr.x, self.y-plyr.y)/(_massscale*self.m)
			local dirx, diry = -(self.x-plyr.x)/a, -(self.y-plyr.y)/a
			line(_sf*self.x+1+dirx, _sf*self.y-eyelength*0.5+diry, _sf*self.x+1+dirx, _sf*self.y+eyelength*0.5+diry,0)
			line(_sf*self.x-1+dirx, _sf*self.y-eyelength*0.5+diry, _sf*self.x-1+dirx, _sf*self.y+eyelength*0.5+diry,0)
		else
			line(_sf*self.x+1, _sf*self.y-eyelength*0.5, _sf*self.x+1, _sf*self.y+eyelength*0.5,0)
			line(_sf*self.x-1, _sf*self.y-eyelength*0.5, _sf*self.x-1, _sf*self.y+eyelength*0.5,0)
		end
	end
	-- delete old particles from particle list
	function body:delete_particles()
		for p in all(self.particles) do
			if p.t > 1 then
				del(self.particles, p)
			end
		end
	end

	body:add_fieldlines()
	add(bodies, body)
	for fl in all(fieldlines) do
		fl:update(true)
	end

	return body
end

function calculate_temperature(x,y)
	local sum = 0
	for b in all(bodies) do
		sum += b:radiate(x,y)
	end
	return sum
end

--- gravity ---
fieldlines = {}


function calculate_force(x,y)
	local ax = 0
	local ay = 0
	-- code uses a modified gravity with lorentzian shape to stabilize simulation
	for b in all(bodies) do
		local d = m_met(x - b.x, y - b.y)
		if d < _cutoff_max and d > _cutoff_min then
			ax += _gc*b.m*(b.x-x)/(_gm*d + d*d*d)
			ay += _gc*b.m*(b.y-y)/(_gm*d + d*d*d)
		end
	end
	return ax, ay
end

-- draw a forcefield on the screen between world coordinates x0,y0,x1,y1 (handles conversion to camera space)
function draw_forcefield(x0, y0, x1, y1, dx, dy)
	local dx = dx or 6
	local dy = dy or 6
	for i = x0,x1,dx do
		for j = y0,y1,dy do
			local tx, ty = calculate_force(i,j)
			line(_sf*i,_sf*j,_sf*i+5*tx, _sf*j+5*ty,2)
		end
	end
end


-- create a fieldline starting from (x,y) going for n linepieces with color col
function create_fieldline(x, y, n, dn, col, static, collect)
	local fline = {
		sx = x,
		sy = y,
		clr = col or 0,
		n = n or 10,
		dn = dn or 0.01,
		static = static or false,
		xc = {},
		yc = {},
		anim_frame = 1 + flr(rnd(n-1)),
		d = flr(rnd(1000))
	}

	-- update the fieldline if it's part of a moving body
	function fline:update(override)
		if not self.static or override then
			self.xc, self.yc = {}, {}
			add(self.xc, self.sx)
			add(self.yc, self.sy)
			local tx, ty = self.sx, self.sy
			for i=1,self.n do
				local ax, ay = calculate_force(tx, ty)
				tx += self.dn*ax/m_met(ax, ay)
				ty += self.dn*ay/m_met(ax, ay)
				add(self.xc, tx)
				add(self.yc, ty)
			end
		end
	end

	-- draw the fieldline
	function fline:draw()
		if debug then
			local tx, ty = self.sx, self.sy
			for i=2,#self.xc do
				if i % 2 == 0 then
					line(_sf*tx,_sf*ty, _sf*self.xc[i], _sf*self.yc[i], self.clr)
				end
				tx = self.xc[i]
				ty = self.yc[i]			
			end
		end
	end

	-- delete the fieldline
	function fline:delete()
		del(fieldlines, self)
	end

	fline:update(true)
	if (collect) add(fieldlines, fline)
	return fline
end

-- draw all fieldlines that are collected
function draw_fieldlines()
	for f in all(fieldlines) do
		f:draw()
	end
end


--- Camera ---
function create_cam(x,y)
	local cam = {
		x = x or 0,
		y = y or 0,
		dy = 0,
		dx = 0,
		offsetx = 64,
		offsety = 64,
	}
	-- update the camera based on player position and gamestate
	function cam:update(player)
		if _gamestate == 'playing' then
			offsetx = _sf*player.x - self.x
			offsety = _sf*player.y - self.y
			local val = 64
			val -= min(m_met(offsetx-64, offsety-64),63)
			self.x += (offsetx-64)/val
			self.y += (offsety-64)/val
		elseif _gamestate == 'gameover' then
		else
			self.x, self.y = 0, 0
		end
	end
	---
	function cam:draw()
		camera(self.x, self.y)
	end

	function cam:reset()
		camera(0,0)
	end
	
	function cam:delete()
		self = nil
	end
	return cam
end

-- draw temperature region on screen
function create_zone(camera, min, max, col)
	local zone = {
		min = min or -0.01,
		max = max or 0.01,
		xlist = {},
		ylist = {},
		clist = {},
		clr = col
	}

	function zone:evaluate(cam)
		self.xlist = {}
		self.ylist = {}
		for i=-512,511,4 do
			for j=-512,511,4 do
				local xx, yy = (cam.x + i)/_sf, (cam.y+j)/_sf
				local t_ = (_d_temp + calculate_temperature(xx, yy))*_dt*2--*_temp_scale
				if t_ < self.max  and self.min < t_ then
					if j/4 % 2==0 then
						add(self.xlist, (cam.x+i)/_sf)
					else
						add(self.xlist, (cam.x+i+2)/_sf)
					end
					add(self.ylist, (cam.y+j)/_sf)
				end
			end
		end
	end
	
	function zone:draw()
		for i=1,#self.xlist do
			pset(self.xlist[i]*_sf, self.ylist[i]*_sf, self.clr)
		end
	end

	function zone:delete()
		self = nil
	end

	zone:evaluate(camera)
	return zone
end

--- ui
-- create ui for temperature
function create_temp_ui(camera, player, dx, dy)
	local ui = {
		cam = camera,
		plr = player,
		dx = dx,
		dy = dy,
		s_top = 13,
		s_middle = 29,
		s_bottom = 45,
		s_bar = 14,
		s_arrow = 12,
		s_del_mid = 28,
		s_del_ext = 44
	}

	function ui:draw()
		-- draw thermometer
		-- fill bar
		local num = flr((self.plr.temp - _t_cold1+5)/5)
		for i=1,num do
			local c = 13
			if _t_cold1 + 5*i < _t_cold1+15 then
				c =13
			elseif _t_cold1-5 + 5*i < _t_cold0 then
				c=12
			elseif _t_cold1-5 + 5*i < _t_hot0 then
				c=11
			elseif _t_cold1+5 + 5*i < _t_hot1 then
				c=10
			else
				c=9
			end

			if 31-i > 0 then
				pal(11,c)
				spr(self.s_bar, self.cam.x+self.dx, self.cam.y+dy+31-i)
				pal()
			end
			
		end
		-- draw shape
		spr(self.s_top, self.cam.x+self.dx, self.cam.y+dy)
		spr(self.s_middle, self.cam.x+self.dx, self.cam.y+dy+8)
		spr(self.s_middle, self.cam.x+self.dx, self.cam.y+dy+16)
		spr(self.s_bottom, self.cam.x+self.dx, self.cam.y+dy+24)

		-- draw delta
		-- curser position
		local pos = 16
		local temp_dt = (_d_temp + calculate_temperature(self.plr.x, self.plr.y))*_dt*2--*_temp_scale
		if temp_dt < -0.07 then
			pos = 29
		elseif temp_dt > 0.07 then
			pos = 2
		else
			pos = 29 - 28/0.14 * (temp_dt+0.07)
		end

		spr(self.s_arrow, self.cam.x+self.dx-8, self.cam.y+dy+pos)
		spr(self.s_del_mid, self.cam.x+self.dx-8, self.cam.y+dy+16)
		spr(self.s_del_ext, self.cam.x+self.dx-8, self.cam.y+dy+24)
		pal(12,9)
		spr(self.s_del_mid, self.cam.x+self.dx-8, self.cam.y+dy+8, 1, 1, false, true)
		spr(self.s_del_ext, self.cam.x+self.dx-8, self.cam.y+dy, 1, 1, false, true)
		pal()
	end

	return ui
end

-- create ui for strength of gravity
function create_grav_ui(camera, player, dx, dy)
	local ui = {
		cam = camera,
		plr = player,
		dx = dx,
		dy = dy,
		s_left = 60,
		s_middle = 61,
		s_right = 62,
		s_cursor = 63
	}

	function ui:draw()
		local length = 11
		-- draw background sprites if gravity is enabled
		if _gravity then
			spr(57, self.cam.x+self.dx, self.cam.y+self.dy)
			for i=1,length do
				spr(58, self.cam.x+self.dx+8*i, self.cam.y+self.dy)
			end
			spr(59, self.cam.x+self.dx+8*(length+1), self.cam.y+self.dy)
		end
		-- draw cursor
		local pos = 0
		pos = (8*length+6)*_gc/0.01
		spr(self.s_cursor, self.cam.x+self.dx+5+pos, self.cam.y+self.dy)
		-- draw bar
		spr(self.s_left, self.cam.x+self.dx, self.cam.y+self.dy)
		for i=1,length do
			spr(self.s_middle, self.cam.x+self.dx+8*i, self.cam.y+self.dy)
		end
		spr(self.s_right, self.cam.x+self.dx+8*(length+1), self.cam.y+self.dy)
	end

	return ui
end

--- setup

function start_game(cam)
	for b in all(bodies) do
		b:delete()
	end
	stars:delete_all()
	_gravity = true
	_gamestate='playing'
	setup_start_conditions()
	cam.x = plyr.x
	cam.y=plyr.y
	menu_timer:delete()
	_gametimer:reset()
	_d_temp *= sqrt(#bodies)
	z_habitable = create_zone(cam,-0.01, 0.01, 11)
	ui_temp = create_temp_ui(cam, plyr, 118, 94)
	ui_grav = create_grav_ui(cam, plyr, 4, 118)
	music(0)
	for b in all(bodies) do
		printh(b.x)
	end
	printh('ende')
end

function setup_start_conditions()
	srand(_seed)
	-- terrain generation
	local px, py = rnd(1.0), rnd(1.0) -- random player start coordinates
	for i=1, _num_planets do
		local bx, by = rnd(1.0), rnd(1.0) --  random body coordinates
		-- reroll if too close to other bodies
		for b in all(bodies) do
			while m_met(bx-b.x, by-b.y) < 0.5 do
				bx, by = rnd(1.5), rnd(1.5)
				while m_met(bx-px, by-py) < 0.5 do
					bx, by = rnd(1.5), rnd(1.5) --  reroll if too close to player start position
				end
			end
		end
		create_body(bx,by,20+rnd(60),8+flr(rnd(5)), 'star', 20+rnd(5)) -- instantiate body
	end
	-- create player
	local apx, apy = calculate_force(px, py) -- check direction of force at player start coordinate
	local speed = rnd(0.6) -- random starting speed
	plyr = create_player(px, py, speed*apy/m_met(apx, apy), -speed*apx/m_met(apx, apy), 1.5, 4) -- instantiate player with velocity perpendicular to force
end

function change_seed(p)
	_seed = p
end

function change_num_planets(p)
	_num_planets = p
end

function restart_game()
	_d_temp /= sqrt(#bodies)
	cam:delete()
	for b in all(bodies) do
		b:delete()
	end
	stars:delete_all()
	z_habitable:delete()
	_seed = flr(rnd(1000))
	_sf = 128
	_gc = 0.001
	_init()
end

--- main functions ---

function _init()
	music(0)
	debug = false
	cam = create_cam(0,0)
	_gamestate = 'title'
	menu = create_menu(33,64,10,10,1,'*menu*')
	i_planets = create_menu_item('# planets: ', _num_planets, 1, 5, change_num_planets)
	i_seed = create_menu_item('seed: ', _seed, 0, 999, change_seed)
	i_start = create_button('start', 21, 22, 23, start_game, cam)
	menu:add_item(i_planets)
	menu:add_item(i_seed)
	menu:add_item(i_start)
	menu:build()
	create_game_over_screen()
	menu_timer = create_timer()
	_gametimer = create_timer()
	_deathtimer = create_timer()
	_title_bod = create_body(500,500,40,10, 'star',10)
end

function _update()
	if _gamestate == 'playing' then
		-- zoom
		if btnp(”) then
			_sf += 5
			cam.x = cam.x + (_sf*plyr.x - (_sf-5)*plyr.x)
			cam.y = cam.y + (_sf*plyr.y - (_sf-5)*plyr.y)
		elseif btnp(ƒ) and _sf>5 then
			_sf -= 5
			cam.x = cam.x + (_sf*plyr.x - (_sf+5)*plyr.x)
			cam.y = cam.y + (_sf*plyr.y - (_sf+5)*plyr.y)
		end
		-- change strength of gravity
		if btn(‘) and _gc <= 0.00975  then
			_gc += 0.00025
		elseif btn(‹) and _gc > 0.00025 then
			_gc -= 0.00025
		end
		-- turn on/off gravity
		if btnp(—) then
			_gravity = not _gravity
		end

		if btnp(Ž) then
			--debug = not debug
		end
		-- update player and camera
		plyr:update(_gravity)
		cam:update(plyr)
		if _gametimer.ct % 1 == 0 then
			stars:update(plyr.x, plyr.y)
		end
		for b in all(bodies) do
			b:update()
		end
		_gametimer:update()
		menu_timer:update()
	elseif _gamestate == 'title' then
		if menu_timer.ct > 0.8+rnd(100) then
			--sfx(7+flr(rnd(2)))
			menu_timer:reset()
		end
		if btnp(—) or btnp(Ž) then
			_gamestate = 'menu'
		end
		if _gametimer.ct % 1 == 0 then
			stars:update(64/_sf,64/_sf)
		end
		_gametimer:update()
		menu_timer:update()
		_title_bod:update()
	elseif _gamestate=='menu' then
		if menu_timer.ct > 0.8+rnd(100) then
			--sfx(7+flr(rnd(2)))
			menu_timer:reset()
		end
		menu:input()
		_gametimer:update()
		menu_timer:update()
		_title_bod:update()
	elseif _gamestate=='gameover' then
		gover_menu:input()
		if _gametimer.ct % 1 == 0 then
			stars:update(64/_sf,64/_sf)
		end
	end
end

function _draw()
	if _gamestate == 'playing' then
		cls(1)
		cam:draw()
		stars:draw()
		if (debug) draw_fieldlines()
		z_habitable:draw()
		plyr:draw()
		
		--print(plyr.y)
		for b in all(bodies) do
			b:draw()
		end
		if debug then
			print(flr(plyr.temp), cam.x, cam.y, 7)
			print((_d_temp + calculate_temperature(plyr.x, plyr.y))*_dt*_temp_scale, _sf*plyr.x+8, _sf*plyr.y-5, 7)
			print(_gc, cam.x, cam.y + 8, 7)
			print('fps '..stat(7), cam.x, cam.y + 16, 7)
			print('timer '.._gametimer.ct, cam.x, cam.y+24, 7)
		end

		if _deathtimer.ct > 0 then
			if _deathtimer.ct % 1 == 0 then
				sfx(16)
			end
			print(4-flr(_deathtimer.ct), _sf*plyr.x+8, _sf*plyr.y,7)
		end
		ui_temp:draw()
		ui_grav:draw()
	elseif _gamestate == 'title' then
		cls(1)
		cam:draw()
		stars:draw()
		draw_title_screen(cam, _title_bod)
		if debug then
			print('timer '..menu_timer.ct, cam.x, cam.y+24, 7)
		end
	elseif _gamestate == 'menu' then
		cls(1)
		cam:draw()
		stars:draw()
		draw_menu_screen(cam, _title_bod)
		if debug then
			print('timer '..menu_timer.ct, cam.x, cam.y+24, 7)
		end
	elseif _gamestate == 'gameover' then
		cls(1)
		cam:draw()
		stars:draw()
		draw_game_over_screen(_gameover_msg)
	end
end
-->8
--- math functions ---

-- metric
function m_met(x,y)
	return sqrt(x*x + y*y)
end


-->8

-- generate menu item
function create_menu_item(s, v, min, max, func)
	local item = {
		string = s,
		value = v,
		min_val = min or 0,
		max_val = max or 10,
		type = 'value',
		func = func
	}


	function item:apply()
		self.func(self.value)
	end

	-- calculate width of menu item
	function item:get_width()
		--if self.max_val
		return #(self.string..tostr(self.max_val))
	end
	
	-- handle input
	function item:input()
		if btnp(‘) then
			local b=self:change_value(self.value+1)
			if b then
				sfx(13)
			else
				sfx(15)
			end
		elseif btnp(‹) then
			local b=self:change_value(self.value-1)
			if b then
				sfx(14)
			else
				sfx(15)
			end
		end
	end

	-- update value of menu item
	function item:change_value(nv)
		local bool = false
		if nv <= self.max_val and nv >= self.min_val then
			bool = true
			self.value = nv
			self:apply()
		end
		return bool
	end

	-- draw menu item
	function item:draw(x, y, selected)
		print(self.string..self.value, x, y, 8)
	end

	return item
end


-- generate a button
function create_button(s, sprite_left, sprite_middle, sprite_right, func, argument)
	local item = {
		string = s,
		func = func,
		arg = argument,
		s_l = sprite_left,
		s_m = sprite_middle,
		s_r = sprite_right,
		type='button'
	}

	-- get the width
	function item:get_width()
		return 6
	end

	-- interaction
	function item:input()
		if btnp(—) then
			sfx(12)
			self:apply()
		end
	end

	-- press button
	function item:apply()
		self.func(self.arg)
	end

	-- draw button
	function item:draw(x, y, selected)
		if selected then
			pal(8,3)
		end
		spr(self.s_l, x+1, y)
		spr(self.s_m, x+9, y)
		spr(self.s_r, x+17, y)
		print(self.string, x+(24-#self.string*4)*0.5+1, y+2, 8)
		pal()
	end

	return item
end

-- generate a menu
function create_menu(x0,y0,w,h,ws,title)
	local menu = {
		x0 = x0,
		y0 = y0,
		w = w or 40, -- width
		h = h or 40, -- height
		ws = ws or 0, -- whitespace above first item
		title = title,
		items = {}, --  holds all menu items
		cur_item = 1, -- current selected item
		-- sprites for background
		s_ul = 18, s_um = 19,s_ur = 20,
		s_ml = 34, s_mm = 35, s_mr = 36,
		s_dl = 50, s_dm = 51, s_dr = 52,
		-- selection sprites
		s_select_l = 37, s_select_r = 38
	}

	-- add item to menu
	function menu:add_item(item)
		add(self.items, item)
	end

	-- get item from menu
	function menu:get_item(n)
		return self.items[n]
	end

	-- build menu
	function menu:build()
		local w,h = self.w,self.h
		for i in all(self.items) do
			if i:get_width()*4 > w then
				w = i:get_width()*4
			end
		end
		if #self.title*4 > w then
			w = #self.title*4
		end
		h = #self.items*8
		if self.title then
			h += 8
		end
		h += self.ws*8
		self.w = w
		self.h = h
	end

	-- handle the input
	function menu:input()
		if btnp(2) and self.cur_item > 1 then
			sfx(11)
			self.cur_item -= 1
		elseif btnp(3) and self.cur_item < #self.items then
			self.cur_item += 1
			sfx(11)
		end
		local item = self:get_item(self.cur_item)
		item:input()
	end

	-- draw the menu
	function menu:draw()
		spr(self.s_ul, self.x0, self.y0)
		local sw = flr(self.w/8 + 1)
		-- build horizontal menu lines
		for i=0, sw do
			if i > 0 and i < sw then
				spr(self.s_um, self.x0+i*8, self.y0)
				spr(self.s_dm, self.x0+i*8, self.y0+self.h+8)
			end
			-- build vertical menu lines
			for j=1, self.h/8 do
				if i > 0 and i < sw then
					spr(self.s_mm, self.x0+i*8, self.y0+j*8)
				elseif (i==0) then
					spr(self.s_ml, self.x0+i*8, self.y0+j*8)
				else
					spr(self.s_mr, self.x0+i*8, self.y0+j*8)
				end
			end
		end
		spr(self.s_ur, self.x0+sw*8, self.y0)
		spr(self.s_dl, self.x0, self.y0+self.h+8)
		spr(self.s_dr, self.x0+sw*8, self.y0+self.h+8)

		local offset = self.ws*8
		if self.title then
			offset += 8
		end

		-- fill menu with content
		-- fill title
		if self.title then
			print(self.title, self.x0+(self.w+12-#self.title*4)*0.5, self.y0+7, 8)
		end
		-- fill menu items
		local j = 1
		for it in all(self.items) do
			if j == self.cur_item then
				if it.type=='value' then
					it:draw(self.x0+8, self.y0+7+(j-1)*8+offset)
					spr(self.s_select_l, self.x0+6, self.y0+6+(j-1)*8+offset)
					spr(self.s_select_r, self.x0+it:get_width()*4+2, self.y0+6+(j-1)*8+offset)
				elseif it.type=='button' then
					it:draw(self.x0+(self.w+12-it:get_width()*4)*0.5, self.y0+7+(j-1)*8+offset, true)
				end
			else
				if it.type!='button' then
					it:draw(self.x0+8, self.y0+8+(j-1)*8+offset)
				else
					it:draw(self.x0+(self.w+12-it:get_width()*4)*0.5, self.y0+8+(j-1)*8+offset, false)
				end
			end

			j+=1
		end
	end
	return menu
end

function create_game_over_screen()
	music()
	gover_menu = create_menu(28,30,60,1,2,'*game over*')
	reset_button = create_button('reset', 21, 22, 23, restart_game)
	gover_menu:add_item(reset_button)
	gover_menu:build()
end

function draw_game_over_screen(message)
	gover_menu:draw()
	print(message, gover_menu.x0+(gover_menu.w+12-#message*4)*0.5, gover_menu.y0+16)
	print('time: '..flr(_gametimer.ct), gover_menu.x0+(gover_menu.w+12-#message*4)*0.5, gover_menu.y0+24)
end

function draw_menu_screen(camera, body)
	draw_title(camera, body)
	menu:draw()
end

function draw_title(camera, body)
	local sx, sy = ellipse(_gametimer.ct/5, 15, 25)
	if (_gametimer.ct/5)%1 > 0.27 and (_gametimer.ct/5)%1 < 0.73 then
		body.m = 30
		body.clr = 9
		body.x = (sx+60)/_sf
		body.y = (sy+40)/_sf
		body:draw()
		spr(64,18,20,12,4)
	elseif (_gametimer.ct/5)%1 < 0.27 and (_gametimer.ct/5)%1 > 0.23 then
		body.m = 35
		body.clr = 9
		body.x = (sx+60)/_sf
		body.y = (sy+40)/_sf
		body:draw()
		spr(64,18,20,12,4)
	elseif (_gametimer.ct/5)%1 > 0.73 and (_gametimer.ct/5)%1 < 0.77 then
		body.m = 35
		body.clr = 9
		body.x = (sx+60)/_sf
		body.y = (sy+40)/_sf
		body:draw()
		spr(64,18,20,12,4)
	else
		spr(64,18,20,12,4)
		body.m = 40
		body.clr = 10
		body.x = (sx+60)/_sf
		body.y = (sy+40)/_sf
		body:draw()
		--spr(76, sx-8+60, sy-8+40, 2, 2)
	end
end

function draw_title_screen(camera, body)
	draw_title(camera, body)
	print("press any button", camera.x+(128-4*#"press any button")/2, camera.y+100, 8)
end

function ellipse(t, a, b)
	local x = a*cos(t-0.30)
	local y = b*sin(t)
	return x,y
end

-- timer
function create_timer()
	local timer = {
		st = time(), -- start time
		ct = 0 --  run time in s
	}
	
	-- reset the timer
	function timer:reset()
		self.st = time()
		self.ct = 0
	end

	-- update the timer, call every update!
	function timer:update()
		self.ct = time() - self.st
	end

	-- delete timer
	function timer:delete()
		self = nil
	end
	return timer
end

__gfx__
00000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000088888888007777000bbbbbb000000000
000000000000000003ccc33000000000000000000000000000000000000000000000000000000000000000000000000000000000070000700000000000000000
0070070000077000333cc33300000000000d0000000d0000000d0000000d000000d0d00000d0d00000d0d00000d0d00000000000700000070000000000000000
00077000003c330033cccc33000d000000ddd00000d2d00000d9d00000dad000000d00000002000000090000000a000000000000700000070000000000000000
00077000003cc9003cccccc900000000000d0000000d0000000d0000000d000000d0d00000d0d00000d0d00000d0d00000000000700007770000000000000000
007007000007700033cccc9900000000000000000000000000000000000000000000000000000000000000000000000000000000700000070000000000000000
000000000000000003cc7c3000000000000000000000000000000000000000000000000000000000000000000000000000000000700000770000000000000000
00000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000700000070000000000000000
00000000000000000088888888888888888888000000000000000000000000000000000000000000000000000000000000bbbbbb700007770000000000000000
000770000000000008ffffffffffffffffffff800877777777777777777778000000000000000000000000000000000000000000700000070000000000000000
003c3300000000008f88ffffffffffffffff88f88777777777777777777777800000000000000000000000000000000000000000700000770000000000000000
03ccc330000000008f8ffffffffffffffffff8f8877777777777777777777780000000000000000000000000000000000000cccc700000070000000000000000
033ccc90000000008ffffffffffffffffffffff88777777777777777777777800000000000000000000000000000000000000000700007770000000000000000
003cc900000000008ffffffffffffffffffffff88777777777777777777777800000000000000000000000000000000000000000700000070000000000000000
00077000000000008ffffffffffffffffffffff88777777777777777777777800000000000000000000000000000000000000ccc700000770000000000000000
00000000000000008ffffffffffffffffffffff80877777777777777777778000000000000000000000000000000000000000000700000070000000000000000
00000000000000008ffffffffffffffffffffff88880000000000888000000000000000000000000000000000000000000000000700007770000000000000000
00000000000000008ffffffffffffffffffffff880000000000000080000000000000000000000000000000000000000000000cc700000070000000000000000
00000000000000008ffffffffffffffffffffff80000000000000000000000000000000000000000000000000000000000000000700000770000000000000000
00000000000000008ffffffffffffffffffffff80000000000000000000000000000000000000000000000000000000000000000700000070000000000000000
00000000000000008ffffffffffffffffffffff8000000000000000000000000000000000000000000000000000000000000000c700007770000000000000000
00000000000000008ffffffffffffffffffffff80000000000000000000000000000000000000000000000000000000000000000700000070000000000000000
00000000000000008ffffffffffffffffffffff88000000000000008000000000000000000000000000000000000000000000000070000700000000000000000
00000000000000008ffffffffffffffffffffff88880000000000888000000000000000000000000000000000000000000000000007777000000000000000000
00000000000000008ffffffffffffffffffffff80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008ffffffffffffffffffffff80000000000000000000000000000000000000000c0c0c0c00000000000000777000000007700000080000000
00000000000000008ffffffffffffffffffffff80000000000000000000000000000000000000c0c0c0c0c0c0c00000000007000000000000070000080000000
00000000000000008ffffffffffffffffffffff800000000000000000000000000000000000000c0c0c0c0c0c000000000007000000000000070777080000000
00000000000000008f8ffffffffffffffffff8f80000000000000000000000000000000000000c0c0c0c0c0c0c00000007007000000000000070707080000000
00000000000000008f88ffffffffffffffff88f800000000000000000000000000000000000000c0c0c0c0c0c000000000007000000000000070777080000000
000000000000000008ffffffffffffffffffff800000000000000000000000000000000000000c0c0c0c0c0c0c00000000007000000000000070000080000000
00000000000000000088888888888888888888000000000000000000000000000000000000000000000000000000000000000777777777777700000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaa000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa0000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaa000000009999000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa00000999999990000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa00009999999999000
888888888888800000000000000000000008888888888888880000000000000000888880000000000000008880000000aaaaaa5aa5aaaaaa0009995995999000
8ffffffffffff800000000000000000000087777777777777780000000000000008fff80000000000000008ff8000000aaaaaa5aa5aaaaaa0099995995999900
8fffffffffffff80000000000000000000087777777777777778000000000000008fff80000000077777008fff800000aaaaaa5aa5aaaaaa0099995995999900
8fffffffffffff80777770000000000000087777777777777778000000000000008fff800000003777c3308fff800000aaaaaaaaaaaaaaaa0099999999999900
888fff888ffffff3777c33000000000000087778888888877778000000000000008fff8000000333ccc3338fff800000aaaaaaaaaaaaaaaa0099999999999900
008fff8008ffff333ccc33300000000000087778000000087778000000000000008fff8000000333ccc3338fff800000aaaaaaaaaaaaaaaa0009999999999000
008fff80008fff333ccc33300000000000087778000000087778000000000000008fff800000033cccccc38fff8000000aaaaaaaaaaaaaa00009999999999000
008fff80008fff33cccccc300000000000087778000000087778000000000000008fff800000033ccccc998fff8000000aaaaaaaaaaaaaa00000999999990000
008fff80008fff33ccccc9900000000000087778000000087778000000000000008fff800000033ccccc998fff80000000aaaaaaaaaaaa000000009999000000
008fff80008fff33ccccc9900000000000087778000000087778000000000000008fff8000000033cc7c308fff800000000aaaaaaaaaa0000000000000000000
008fff88888ffff33cc7c3000000000000087778000000087778000000000000008fff80000000077777088fff88000000000aaaaaa000000000000000000000
008fffffffffff80777770000000000000087778000000087778000000000000008fff800000000000008fffffff800000000000000000000000000000000000
008fffffffffff80000000000000000000087778000000087778000000000000008fff800000000000008ffffffff80000000999999000000000000000000000
008fffffffffff80000000000000000000087778000000087778000000000000008fff800000000000008ffffffff80000099999999990000000000000000000
008fff8888888880888000088888888000087778000000087778008888888800008fff88888000088800888fff88880000999999999999000000000000000000
008fff80000000008ff80008fffffff800087778000000087778008fffffff80008ffffffff80008ff80008fff80000000999999999999000000000000000000
008fff80000000008fff8008ffffffff80087778000000087778008ffffffff8008fffffffff8008fff8008fff80000009999959959999900000000000000000
008fff80000000008fff8008ffffffff80087778000000087778008ffffffff8008fffffffff8008fff8008fff80000009999959959999900000000000000000
008fff80000000008fff8008fff8888880087778ccccccc87778008fff888888008fff88ffff8008fff8008fff80000009999959959999900000000000000000
008fff80000000008fff8008fff80cccccc87778000000087778cc8fff8c0000008fff808fff8008fff8008fff80000009999999999999900000000000000000
008fff80000000008fff8cc8fff8c00000087778000000087778008fff80cccccc8fff808fff8008fff8008fff80000009999999999999900000000000000000
008fff8000000ccc8fff8008fff8000000087778000000087778008fff800000008fff8c8fff8008fff8008fff80000009999999999999900000000000000000
008fff8cccccc0008fff8008fff8888880087778888888887778008fff800000008fff888fff8cc8fff8008fff80000000999999999999000000000000000000
0c8fff80000000008fff8008ffffffff80087777777777777778008fff800000008fffffffff8008fff8cc8fff80000000999999999999000000000000000000
008fff80000000008fff8008ffffffff80087777777777777778008fff800000008fffffffff8008fff8008fff8cc00000099999999990000000000000000000
00888880000000008888800888888888800888888888888888880088888000000088888888888008888800888880000000000999999000000000000000000000
00888880000000008888800888888888800888888888888888880088888000000088888888888008888800888880000000000000000000000000000000000000
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
004000000205202052020520205202052020520205202052000520005200052000520005200052000520005205052050520505205052050520505205052050520205202052020520205202052020520205202052
014000000061000611006110061102621026210262102611046110461104611046110462104621046210461105611056110561105611056210562105621056110461104611046210462104621046110461104611
014000000e4140e4120e4120e4220e4220e4320e4320e432104311043210432104221042210422104221042211421114221142211432114321143211432114221342113422134221343213432134221342213412
014000001f5541d5511c5511a5511854117531155211351113515245142452124531245212451500000000011c5541a551185511755115541135311152110511105151f5141f5211f5311f5211f5150000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00003c714377103b71035710397103471037710327103571030710347102f710327102d710307102b7103770030700357002f700347002d700327002b70030700297002f700287002d700267002b70024700
010a00003771430710357102f710347102d710327102b71030710297102f710287102d710267102b7102471000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003601039010000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001d0501b0001b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002401429015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000240141f015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001801418015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000735006350003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000a00000435004350043500435004350043000430000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
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
01 00 42 43 44
00 00 01 43 44
00 00 01 02 44
00 00 02 03 44
00 00 01 03 44
00 00 02 43 44
02 02 03 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
