pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- little space rangers
-- by @tmi_robot
-- collision and anim handler dervied from
-- @matthughson's advanced micro platformer

-- FOUNDATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- shorthand functions for common randomizations, to save tokens
function frnd(n)
	return flr(rnd(n))
end

function frnda(n, o)
	local addval = o or 1
	return frnd(n)+addval
end

-- clear a table of data
function table_clear(t)
	local count = #t
	for i=0, count do t[i]=nil end
end

-- print a centered string (used a lot, order of params is to make it cheaper for most cases)
function printc(str, y, col, x)
	print(str, (x or 64)-(#str*4)/2, y, col or 7)
end

-- flash the entire pallette white, for invulnerabilty frames
function pal_flash_invuln()
	for i=1,15 do
		pal(i, 7)
	end
end

-- check if is something is near the current view, for playing sounds mostly
function is_near_screen(tar)
	if tar.x < cam.pos_x+96 and tar.x > cam.pos_x-96 then
		return true
	end
	return false
end

-- check if something is within "reach": for prompt displays, grabbing items, and teleporting crewmates
function is_near(source, target, range)
	local sx, sy, tx, ty = source.x, source.y, target.x, target.y
	if sx > tx-range and sx < tx+range and sy > ty-range and sy < ty+range then
		return true
	end
	return false
end

function find_nearby_item(source)
	for i,v in pairs(list_items) do
		if not v.is_eq and is_near(source, v, 5) then
			return v
		end
	end
	return nil
end

-- check used when checking any two bounds against each other
function int_rects(x1, y1, w1, h1, x2, y2, w2, h2)
	if x1+w1<x2 or x2+w2<x1 or y1+h1<y2 or y2+h2<y1 then
    return false
	end
  return true
end

-- check for checking collisions (taking into account center offsets and bounds)
function int_cols(e1, e2)
	if int_rects(e1.x-e1.col_w/2, e1.y+e1.col_off-e1.col_h, e1.col_w, e1.col_h, e2.x-e2.col_w/2, e2.y+e2.col_off-e2.col_h, e2.col_w, e2.col_h) then
		return true
	end
	return false
end

-- check for doing collision against a tile for projectiles
function int_col_to_tile(e)
	for i=-e.col_w/2, e.col_w/2, e.col_w do
		for j=0, e.col_h, e.col_h do
			local itile=mget((e.x+i)/8, (e.y+e.col_off-j)/8)
			if fget(itile, 0) then
				if e.dx < 0 then
					e.x = (e.x+i)
				end
				return true
			end
		end
	end
	return false
end

-- check for bopping enemies on the head
function landing_on_target(e1, e2)
	if e1.y+3 < e2.y+2 and e1.dy >= 0 then
		return true
	end
	return false
end

-- check if you are pushing sideways against collision, to stop motion
function coll_side(self)

	local x,y,offset,dx = self.x, self.y, 8/3, self.dx

	local xpoff8, xmoff8 = (x+offset)/8, (x-offset)/8

	for i=-offset,offset,2 do
		if fget(mget(xpoff8,(y+i)/8),0) then
			self.dx=0
			self.x=flr(xpoff8)*8-offset
			return true
		end
		if fget(mget(xmoff8,(y+i)/8),0) then
			self.dx=0
			self.x=flr(xmoff8)*8+8+offset
			return true
		end
	end
	return false
end

-- check if you're on or have impacted a floor, stop motion, play impact
function coll_floor(self)
	if self.dy<0 then
		return false
	end

	local landed, x,yh28, w3 = false, self.x, (self.y+4)/8, 8/3

	for i=-w3,w3,2 do
		local tile=mget((x+i)/8,yh28)

		local ty = flr(self.y+4)%8
		if fget(tile,0) or (fget(tile,1) and ty <=1) then
			self.dy, self.y, self.grounded, self.airtime, landed =
				0, (flr(yh28)*8)-4, true, 0, true
		end
	end
	return landed
end

-- check if you've hit a ceiling, stop motion
function coll_roof(self)
	local x,yh28,w3 = self.x, (self.y-4)/8, 8/3

	for i=-w3,w3,2 do
		if fget(mget((x+i)/8,yh28),0) or yh28*8 < 0 then
			self.dy, self.y, self.jump_hold_time =
				0, flr(yh28)*8+12, 0
		end
	end
end

-- check if the tile you're on is an ice tile
function is_on_ice(x,y)
	return fget(mget(flr(x/8),flr(y/8)+1),2)
end

-- add to the player's score, and make a floating particle with the score #
function score_add(x,y,amt)
	g_score += amt
	m_textfloat(x,y, ""..amt)
end

function updatemission()
	g_mission += 1
	dset(2,g_mission)
end

function updatehighscore()
	g_score_high = max(g_score, g_score_high)
	dset(0,g_score_high)
end

-- PARTICLES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

list_parts = {}

-- foundation: particle object, moves through space for a duration
function m_part(x,y, dy, frame, col, dur)
	local p =
	{
		x=x,
		y=y,
		frame=frame,
		col=col,
		dur=dur,

		time=0,
		dx=0,
		dy=dy,
		ddy=0,
		flipx=false,

		draw=function(self)
			pal(7,self.col)
			spr(self.frame, self.x, self.y, 1, 1, self.flipx)
			pal()
		end,

		update=function(self)
			if self.time > self.dur then
				del(list_parts, self)
				return
			end
			self.x += self.dx
			self.y += self.dy
			self.dy += self.ddy
			self.time += 1
		end,
	}
	add(list_parts,p)
	return p
end

-- create a particle that has a text string as its visual
function m_textfloat(x,y, text, dy)
	local t =
	{
		x=x,
		y=y,
		dy=dy or .3,
		text=text,
		dur=20+5*#text,

		draw=function(self)
			printc(self.text, self.y, 7, self.x)
		end,

		update=function(self)
			self.dur-=1
			if self.dur == 0 then
				del(list_parts, self)
			else
				self.y -= self.dy
			end
		end,
	}
	add(list_parts, t)
	return t
end

-- particle effect of a projectile hitting something
function eff_proj_impact(x,y)
	m_part(x-2,y-4, 0, 117, 10, 3)

	for i=1, 5 do
		local fx=rnd(.2)+.3
		if frnd(2) == 0 then
			fx= -fx
		end

		local newp = m_part(x-2,y-2, -(rnd(1)+.3), 109, 8, frnda(5,5))
		newp.dx, newp.ddy = fx, .1
	end
end

-- particle effect for dying in acid
function eff_burn(x, y, col)
	for i=1, 5 do
		m_part(x-frnda(6), y-frnd(8), -(rnd(.25)+.25), 109, col, frnda(15,5))
	end
end

-- particle effect for being bopped or shot
function eff_explode(x,y, color)
	for i=0,15 do
		local fx=rnd(1)+.3
		if frnd(2) == 0 then
			fx= -fx
		end

		local newp = m_part(x-4,y, -(rnd(1)+.3), 109, color or 8, frnda(10,5))
		newp.dx, newp.ddy = fx, .1
	end
end

-- particle effect for the ship crash smoke and end home smoke
function eff_smoke(x,y)
	local pox = frnd(3)
	if frnd(2) == 0 then
		pox = 0-pox
	end

	m_part(x-pox, y+frnd(3), -(rnd(.25)+.25), 111+frnd(2), 0, frnda(10,30))
end

-- particle effect for the teleporter item use
function eff_transport(x,y)

	for i=1, 5 do
		local pox = frnda(2)
		if frnd(2) == 0 then
			pox = 0-pox
		end

		local c = frnd(3)

		if c == 0 then
			c = 7
		else
			c = 12
		end

		m_part(x-pox, y, -(rnd(.25)+.25), 109, c, frnda(10,30))
	end

	for j=0, 9, 9 do
		for k=0, 1 do
			local newp = m_part(x, y-j+k, -1.5, 114, 12-k*5, 20)
			if j==9 then
				newp.dy += 3
				newp.ddy = -.15
			else
				newp.ddy = .15
			end
		end
	end
end

-- particle effect for sliding on "ice/mud" surfaces
function eff_slide(x,y, flipx, speed, color)
	local px=x-5
	if flipx then
	 	px=x-2
	end

	local newp = m_part(px, y, -rnd(1)-speed/2, 109+frnd(2), color, frnda(3,2))
	local dx = -rnd(1)-speed/2
	if flipx then
		dx = 0-dx
	end
	newp.dx, newp.ddy = dx, planet.grav
end


-- foundation object for projectiles -- things that fly and hit actors for amage
list_projs = {}

function m_proj(x,y, dx, own, is_enemy)
	local p =
	{
		x=x,
		y=y,
		col_w=4,
		col_h=4,
		col_off=2,

		range_cur=0,
		dx=dx,
		own=own,
		is_enemy=is_enemy,

		flipx=false,

		draw=function(self)
			spr(113, self.x-4, self.y-4, 1, 1, self.flipx)
		end,

		update=function(self)
			self.x += self.dx
			self.range_cur += self.dx

			if abs(self.range_cur) > 48 then
				del(list_projs, self)
				return
			end
			if int_col_to_tile(self) then
				self:impact()
			end
		end,

		impact=function(self)
			eff_proj_impact(self.x, self.y)
			if is_near_screen(self) then
				sfx(9)
			end
			del(list_projs,self)
		end,
	}

	add(list_projs,p)
	return p
end

-- PLANETS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- planet object that describes all color and hazard information for the current planet
function m_planet()
	g_diff = 2
--	printh("diff: 2 base")
	local p=
	{
		colors=
		{
			 {  3, 11, 5, 4,  2,  0 }, -- grass
			 {  1, 13, 5, 2, 11,  0 }, -- acid
			 {  2, 13, 8, 5,  8,  0 }, -- lava
			 { 13,  7, 5, 6, 12, 12 }, -- ice
		},

		toxiclevel=0,
		species="human",

		init=function(self)

			while p1.species == self.species do
				self.species = crew_data.species.names[max(1,frnda(5))]
			end
			self.aciddeath = false
			local b = frnda(1.5+min(2,.5*g_planet)) -- later planets higher chance of deadlier types

			self.biome = b

			if b == 4 then
				self.aciddeath, self.frict = true, .75
				g_diff += 4
--				printh("diff: +4 ice")
			else
				if b == 3 then
					self.aciddeath = true
					g_diff += 4
--					printh("diff: +4 lava")
				end
				self.frict = .95
			end

			if frnd(100) < min(15, 2*g_planet) then -- later planets higher chance of toxic, and more deadly toxin
				self.toxiclevel = max(250, 750-250*frnd(g_planet/3))
				g_diff += 2
--				printh("diff: +2 toxic")
			end

		  local g = frnd(5.5+.5*g_planet) -- later planets higher chance of high gravity
		  if g <= 1 then
		    g = .15
				g_diff -= 2
--				printh("diff: -2 low grav")
		  elseif g <= 5 then
		    g = .2
		  else
		    g = .3
				g_diff += 2
--				printh("diff: +2 high grav")
		  end
			self.grav = g
		end,

		draw=function(self)

			local colors = self.colors[self.biome]

			cls(colors[1])
			pal(11, colors[2])
			pal(5, colors[3])
			pal(4, colors[4])
			pal(1, colors[5])
			pal(12, colors[6])

			map(0,0,0,0,400,128)

		end,
	}
	p:init()
	return p
end

-- based on the map tile type, spawn an enemy
function spawn_enemy(tile, x, y)
	local schance = min(30,10+5*g_planet) -- chance for spawning spiked versions is greated in later planets
	if frnd(100) <= 30+5*g_planet+10*g_level then -- base chance of any creature
		if (tile == 118 and frnd(100) < 10+2*g_planet+10*g_level) or tile == 87 then -- enemy crew replacement or spawn
			m_crew_ai(x,y, true, planet.species)
			return
		elseif tile == 118 then -- spiker or crawler
			if frnd(100) < schance then
				m_ene_spiker(x, y)
			else
				m_ene_crawler(x, y)
			end
		elseif tile == 119 then
			m_ene_crawler(x, y)
		elseif tile == 120 then -- stationary crawler
			m_ene_crawler(x,y,true)
		elseif tile == 123 then -- buzzer or flyer (up/down)
			if frnd(100) < schance then
				m_ene_buzzer(x,y)
			else
				m_ene_flyer(x,y)
			end
		end
	end
end

-- spawn a random item, lower chance for later planets (unless overridden with "forced" type)
function spawn_item(x,y, force)
	if frnd(100) < 75-(7*g_planet) or force then
		m_item_type(x, y)
	end
end

-- compute the score for a level (trans score holds it for display until the space transition)
function level_score()
	g_score_trans += (100 + g_diff*25)*(2-g_dmgd)
end

-- check if the planet is the final planet (for setting up end home)
function is_planet_final()
	 return g_planet == 9
end

-- a "level" is an 8 screen strip of gameplay made from randomized map chunks
-- clear all level data and build the next level out of map chunks, based on current planet values
function level_clear_and_build()
	table_clear(list_enemies)
	table_clear(list_projs)
	table_clear(list_crew_ai)
	table_clear(list_items)
	table_clear(list_parts)

	reload(0x2000, 0x2000, 0x1000) -- reload original map data

	local block_sel_x, block_sel_y = 999, 999

  -- go through every chunk of a level, find a chunk from the area of possible chunks, and copy it into the level strip
	for block_cur_x=0, 7 do
		repeat
			if g_level == 0 and block_cur_x == 0 then
				block_sel_x, block_sel_y = 0, 0
			-- if this is the last chunk of the last level on a planet, use the ship rescue map chunk
			elseif g_level == g_level_end and block_cur_x == 7 then
				block_sel_x, block_sel_y = 7, 0
				if is_planet_final() then -- on the final level of the game, use the "home" chunk
					block_sel_y = 4
				end
			else
				if block_cur_x == 1 and g_level > 0 and frnd(100) <= 1 then -- chance for a rare map chunk area (never in the first level of a plent)
					block_sel_x, block_sel_y = frnda(4), 0
				else
					repeat
						-- allow choice of harder map chunks (those lower in the y coords of the map chunk) if you're on a later planet
						block_sel_x, block_sel_y = frnd(8), min(4, frnda(2.25+.5*g_planet))
					until block_sel_x ~= 7 or block_sel_y ~= 4
				end
			end

		until g_block_last_x ~= block_sel_x or g_block_last_y ~= block_sel_y

		g_block_last_x, g_block_last_y = block_sel_x, block_sel_y

	  -- go through each horizontal strip of the pasted chunk and look for special tiles
		for y=0, 11 do
			local is_replacing_ice = true
			-- for "mud/ice" tiles, see if we should replace them with grass (earlier planets have higher chance of using grass)
			if frnd(50+10*g_planet) > 50 then
				is_replacing_ice = false
			end
			for x=0, 15 do
				local tile, xp, yp = mget(x+block_sel_x*16, y+block_sel_y*12), x*8+block_cur_x*128+4, y*8+4
				-- if we are not in a higher gravity planet, remove "helper ledges"
				if tile == 44 or tile == 45 then
					if planet.grav ~= .3 then
						tile = 0
					end
				end
				-- replace mud/ice tiles with grass if we've decided to
				if is_replacing_ice and tile >= 26 and tile <= 38 then
					tile -= 25
				end
				if tile >= 240 then -- each planet type has unique "decoration" tiles to replace the basic "decoration" tile
					tile += 4*(planet.biome-1)
				end
				if tile >= 87 and tile <= 127 then -- for enemy tiles, create an enemy at the tile location
					spawn_enemy(tile, xp, yp)
					tile = 0
				end
				if tile == 78 then -- for item tiles, create an item at the tile location
					spawn_item(xp, yp)
					tile = 0
				end
				if tile == 72 then -- for cargo tile, create random cargo or friendly crewmember
					local cchance = frnd(100)
					if cchance < 40 then -- replace with nothing
						tile = 0
					elseif cchance < 55 then -- replace with crew
						m_crew_ai(xp,yp-4, false, p1.species)
						tile = 0
					elseif cchance < 70 then -- replace with big cargo
						tile = 73
					end
				end
				-- having used the original tile's data, replace it if we did something with it
				mset(x+block_cur_x*16, y, tile)
			end
		end
	end
end

-- ITEMS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

list_items={}

-- basic item object, responds to gravity, can be held, dropped in acid, using it uses energy
function m_item(x,y)
	local i=
	{
		name="head",
		x=x,
		y=y,
		frame=0,
		flipx=false,

		dx=0,
		dy=0,

		max_dx=1,
		max_dy=2,
		grounded=false,

		airtime=0,

		is_eq=false,
		own=nil,
		ene_max=100,
		ene_cur=100,
		score=50,

		update=function(self)
			if self.is_eq then
				if self.ene_cur <= 0 then
					self.own.eq_item = nil
					del(list_items, self)
				end
				return
			end

			local frict, s_dx = planet.frict, self.dx

			if self.grounded then
				if is_on_ice(self.x, self.y) then
					if s_dx > 0.1 or s_dx < -.01 then
						if abs(s_dx) > rnd(1.5) then
							eff_slide(self.x, self.y, self.flipx, abs(s_dx), planet.colors[planet.biome][6])
						end
					end
					frict = .4
				end

				if s_dx > 0.1 then
					s_dx -= 1*(0.08 - 0.08* (1-frict))
					self.flipx = false
				elseif s_dx < -0.1 then
					s_dx += 1*(0.08 - 0.08 * (1-frict))
					self.flipx = true
				else
					s_dx = 0
				end
			end

			s_dx=mid(-self.max_dx,s_dx,self.max_dx)
			self.x+=s_dx
			self.dx=s_dx

			coll_side(self)
			a_handle_grav(self)
			a_coll_floor(self)
			coll_roof(self)
		end,

		draw_base=function(self)
			if self.is_eq then
				local hoffset=3
				if self.own.flipx then
					hoffset = 0-hoffset
				end

				spr(self.frame,
					self.own.x-4+hoffset,
					self.own.y-6,
					1, 1,
					self.own.flipx)
			else
				spr(self.frame,
					self.x-4,
					self.y-4,
					1, 1,
					self.flipx)
			end
		end,

		dmg=function(self, amt, instakill)
			eff_burn(self.x, self.y, planet.colors[planet.biome][5])
			del(list_items, self)
		end,

		use_base=function(self, pass)
			if self.own ~= p1 then
				return true
			end

			local ene_peruse = 25
			if self.own.species == "greebo" then
				ene_peruse = 20
			end
			if self.ene_cur >= ene_peruse and pass then
				self.ene_cur -= ene_peruse
				if self.own == p1 then
					ui_bar_ene:change_value(self.ene_cur)
				end
				return true
			else
				ui_bar_ene.icon_flash_frames = 12
				sfx(5)
				return false
			end
		end,
	}
	return i
end

-- overrides to the basic item object to make unique item types
-- head of a crewmember
function m_headitem(head, x,y, dx, dy, flipx, eye, skin, hair, beard)
	local i = m_item(x,y)
	i.frame, i.flipx, i.dx, i.dy, i.eye, i.skin, i.hair, i.beard, i.score =
	head, flipx, dx, dy, eye, skin, hair, beard, 100

	i.use=function(self)
	end

	i.draw=function(self)
		if self.is_eq then
			local hoffset=4
			if self.own.flipx then
				hoffset = 0-hoffset
			end

			draw_head(self.frame,
				self.own.x-4+hoffset,
				self.own.y-2,
				self.own.flipx, self.eye, self.skin, self.hair, self.beard)
		else
			draw_head(self.frame, self.x-4, self.y, self.flipx, self.eye, self.skin, self.hair, self.beard)
		end
	end

	add(list_items, i)
	return i
end

function m_item_gun(x,y)
	local i = m_item(x,y)
	i.name, i.frame = "\151 blaster", 76

	i.use=function(self)
		if self:use_base(true) then
			local s_o, pdx, poffset = self.own, 2, 2
			if(s_o.flipx) then
				pdx = -pdx
				poffset = -poffset
			end
			if is_near_screen(self.own) then
				sfx(8)
			end
			local p = m_proj(s_o.x+poffset, s_o.y, pdx, s_o, s_o.is_enemy)
			p.flipx = s_o.flipx
		end
	end

	i.draw=function(self)
		i:draw_base()
	end

	add(list_items, i)
	return i
end

function m_item_tele(x,y)
	local i = m_item(x,y)
	i.name, i.frame = "\151 teletron", 77

	i.use=function(self)
		local t = nil
		foreach(list_crew_ai, function(i)
			if is_near(i, self.own, 10) then
				t = i
			end
		end)

		if self:use_base(t) then
			eff_transport(t.x-4, t.y)
			score_add(t.x, t.y-8, 75+25*t.dept)
			sfx(7)
			del(list_crew_ai, t)
		end
	end

	i.draw=function(self)
		i:draw_base()
	end

	add(list_items, i)
	return i
end

function m_item_heal(x,y)
	local i = m_item(x,y)
	i.name, i.frame = "\151 healizer", 78

	i.use=function(self)
		if self:use_base(self.own.hp_cur < self.own.hp_max) then
			self.own:heal(25)
			if is_near_screen(self.own) then
				sfx(6)
			end
		end
	end

	i.draw=function(self)
		i:draw_base()
	end

	add(list_items, i)
	return i
end

-- make items of specific types
function m_item_type(x, y, type)
	if not type then
		type = frnd(100)
	end

	if type <= 50 then
		return m_item_gun(x,y)
	elseif type <= 85 then
		return m_item_tele(x,y)
	else
		return m_item_heal(x,y)
	end
end

-- ACTORS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- functions shared by all moving/animating objects (enemies and crewmembers)
-- update function for any flying actor
function a_move_air(self)

	local dy = self.dy

	if self.com.ml == true then
		if dy<0 then
			dy-=g_acc
		else
			dy-=g_dec
		end
		self.com.mr=false
	elseif self.com.mr == true then
		if dy>0 then
			dy+=g_acc
		else
			dy+=g_dec
		end
	end

	self.dy=mid(-self.max_dy,dy,self.max_dy)

	self.y += self.dy
end

-- flip directions - used when impacting or deciding to turn in air/ledge
function a_doflipx(self)
	local flipx = self.flipx

	if self.grounded then
		if self.com.ml == true then
		  flipx = true
		elseif self.com.mr == true then
			flipx = false
		end
	else
		if self.dx < 0 then
			flipx = true
		elseif self.dx > 0 then
			flipx = false
		end
	end
	self.flipx = flipx
end

-- update function for any ground moving actor
function a_move_ground(self)
	x, y, dx, grounded = self.x, self.y, self.dx, self.grounded

	local frict = planet.frict
	if grounded and is_on_ice(x, y) then
		gcolor = planet.colors[planet.biome][6]
		if dx > 0.1 or dx < -.01 then
			if abs(dx) > rnd(1) then
				eff_slide(x, y, self.flipx, abs(dx), gcolor)
			end
		end
		frict = .4
	end

	a_doflipx(self)

	if self.com.ml==true then

		if dx<0 then
			if grounded then
				dx-=g_acc - (g_acc * (1-frict))/2
			else
				dx-=g_acc
			end
		else
			if grounded then
				dx-=g_dec - (g_dec * (1-frict))
			else
				dx-=g_dec
			end
		end
		self.com.mr=false
	elseif self.com.mr==true then

		if dx>0 then
			if grounded then
				dx+=g_acc - (g_acc * (1-frict))/2
			else
				dx+=g_acc
			end
		else
			if grounded then
				dx+=g_dec - (g_dec * (1-frict))
			else
				dx+=g_dec
			end
		end
	else
		if grounded then
			if dx > 0.1 then
				dx -= 1*(g_dec - (g_dec * (1-frict)))
			elseif dx < -0.1 then
				dx += 1*(g_dec - (g_dec * (1-frict)))
			else
				dx = 0
			end
		end
	end

	dx=mid(-self.max_dx,dx,self.max_dx)

	x+=dx
	if x < 4 then
		x, dx = 4, 0
	end
	self.x, self.dx = x, dx
end

-- handle the pull of gravity, and respond to impacting things
function a_handle_grav(self)
	self.dy+=planet.grav
	self.dy=mid(-self.max_dy,self.dy,self.max_dy)
	self.y+=self.dy

	local tile=mget(self.x/8,(self.y+3)/8)

	if fget(tile,3) then
		self:dmg(25, planet.aciddeath)
	end

	-- die if falling into pit
	if(self.y > 102) then
		self:dmg(1000, true)
	end
end

-- check if you're about to reach a ledge (used by enemies to turn around)
function a_is_ledge_ahead(self)

	local m = 10
	if planet.biome == 4 then
	 	m = 15
	end
	local checkahead = self.dx*m

	local ctile=mget((self.x+checkahead)/8,(self.y+4)/8)
	if self.grounded and not(fget(ctile,0) or fget(ctile,1)) then
		if(self.com.mr and self.dx > 0) or (self.com.ml and self.dx < 0) then
			return true
		end
	end
	return false
end

-- check if there's a wall ahead (used by enemies to turn around)
function a_is_wall_ahead(self)

	local checkahead = self.dx*10

	local ctile=mget((self.x+checkahead)/8,self.y/8)
	if fget(ctile,0) then
		if(self.com.mr and self.dx > 0) or (self.com.ml and self.dx < 0) then
			return true
		end
	end
	return false
end

-- respond to hitting the floor
function a_coll_floor(self)
	--returning true means we landed this frame
	local grounded_precheck = self.grounded

	if not coll_floor(self) then
		self.grounded=false
		self.airtime+=1
		return false
	end

	if grounded_precheck == false and self.grounded == true then
		if is_on_ice(self.x, self.y) then
			for i=1, 6 do
				local newp = m_part(self.x-4, self.y, -(rnd(.25)+.5), 109, planet.colors[planet.biome][6], frnda(5,5))
				local dx = rnd(.25)+.4

				if frnd(2) == 0 then
					dx = 0-dx
				end

				newp.dx, newp.ddy = dx, .15
			end
		end
		return true
	end

	return false
end

-- reverse directions
function a_reverse_dir(self)
	if self.com.ml then
		self.com.ml, self.com.mr  = false, true
	elseif self.com.mr then
		self.com.mr, self.com.ml = false, true
	end
end

-- how AI actors check for actions while moving on the ground
function a_move_ground_logic(self)
	local should_reverse = false
	if coll_side(self) then
		should_reverse = true
	elseif a_is_wall_ahead(self) then
		should_reverse = true
	elseif a_is_ledge_ahead(self) then
		should_reverse = true
	end

	if should_reverse then
		a_reverse_dir(self)
	end

	return should_reverse
end

-- update an actors animation frame, and loop as necessary
function a_anim_update(self)
	self.animtick-=1
	if self.animtick<=0 then
		self.curframe+=1
		local a=self:get_anim_data(self.curanim)

		self.animtick=a.ticks
		if self.curframe>#a.frames then
			self.curframe=1
		end
	end
end

-- define an animation set for an actor
function a_anim_set(self, anim)
	if(anim==self.curanim)return

	local a=self:get_anim_data(anim)
	self.animtick, self.curanim, self.curframe = a.ticks, anim, 1
end

-- get the current frame of the animation set playing on an actor
function a_get_curframe(self)
	return self:get_anim_data(self.curanim).frames[self.curframe]
end

-- handle invulnerability flash for a specific actor
function a_set_invuln_flash(self)
	if self.invuln_frames > 0 and self.invuln_frames % 5 == 0 then
		pal_flash_invuln()
		return true
	end
	return false
end

-- heal a specific actor, and play a particle
function a_heal(self, amt)
	if amt > 0 and not self.is_dead then
		self.hp_cur += amt
		local x, y = self.x-4, self.y-4

		for i=1, 5 do
			local pox = frnda(3)
			if frnd(2) == 0 then
				pox = 0-pox
			end

			m_part(x+pox, y+4, -(rnd(.25)+.25), 109, 11, frnda(10,15))
		end

		local newp = m_part(x,y, -1, 115, 11, 15)
		newp.ddy = .05

		if self.hp_cur > self.hp_max then
			self.hp_cur = self.hp_max
		end
	end
end

-- ENEMIES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- definitions for all the non-crew member enemies. fliers and crawlers
-- variants define small behavior changes and override animation lookups to point to their unique frame data
list_enemies = {}

-- base enemy class
function m_ene(x,y)

	local e=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		col_w=8,
		col_h=8,
		col_off=4,

		max_dx=.75,
		max_dy=2,

		grounded=false,
		airtime=0,

		hp_max=25,
		hp_cur=25,
		invuln_frames=0,
		is_boppable=true,

		curanim="move",
		curframe=1,
		animtick=0,
		flipx=true,
		color=planet.colors[planet.biome][5],

		com =
		{
			ml = true,
			mr = false,
		},

		die=function(self)
			eff_explode(self.x, self.y, self.color)
			del(list_enemies, self)
		end,

		dmg=function(self, amt)
			if self.invuln_frames == 0 then
				self.hp_cur -= amt
				if self.hp_cur <=0 then
					self:die()
					return true
				else
					self.invuln_frames = 6
				end
			else
				return false
			end
		end,

		attack=function(self, target)
			target:dmg(25)
		end,

		update_base=function(self)

			if self.invuln_frames > 0 then
				self.invuln_frames -= 1
			end
			return true
		end,

		draw=function(self)
			if not a_set_invuln_flash(self) then
				pal(1, self.color)
				pal(9, self.color-2)
			end

			spr(a_get_curframe(self),
				self.x-4,
				self.y-4,
				1, 1,
				self.flipx)

			pal()
		end,
	}

	add(list_enemies, e)
	return e
end

-- flying enemy
flyer_data =
{
	anims=
	{
		["move"]=
		{
			ticks=15,
			frames={124, 125},
		},
	},
}

function m_ene_flyer(x,y)
	local e = m_ene(x,y)
	e.col_h, e.max_dx, e.max_dy, e.origin =
	5, .75, .75, y

	e.get_anim_data = function(self,anim)
		return flyer_data.anims[anim]
	end

	e.attack=function(self, target)
		target:dmg(25)
	end

	e.update=function(self)
		if self:update_base() then

			-- assume flying can never hit walls
			a_move_air(self)

			if (self.y < self.origin-16 and self.com.ml) or (self.y > self.origin+16 and self.com.mr) then
				a_reverse_dir(self)
			end

			a_anim_update(self)
		end
	end
	return e
end

-- flying spiked enemy
buzzer_data =
{
	anims=
	{
		["move"]=
		{
			ticks=15,
			frames={126, 127},
		},
	},
}

function m_ene_buzzer(x,y)
	local e = m_ene_flyer(x,y)
	e.is_boppable = false
	e.get_anim_data = function(self,anim)
		return buzzer_data.anims[anim]
	end
end

-- ground crawling enemy
crawler_data =
{
	anims=
	{
		["move"]=
		{
			ticks=15,
			frames={119, 120},
		},
	},
}

function m_ene_crawler(x,y, is_static)
	local e = m_ene(x,y)
	e.col_h, e.max_dx, e.is_static = 5, .75, is_static

	e.get_anim_data = function(self,anim)
		return crawler_data.anims[anim]
	end

	e.attack=function(self, target)
		target:dmg(25)
	end

	e.update=function(self)
		if self:update_base() then
			if not self.is_static then
				a_move_ground(self)

				a_move_ground_logic(self)

				a_handle_grav(self)
				a_coll_floor(self)

				coll_roof(self)
			end

			if self.com.ml or self.com.mr then
				a_anim_set(self, "move")
			end

			a_anim_update(self)
		end
	end

	return e
end

-- spiked ground crawling enemy
spiker_data =
{
	anims=
	{
		["move"]=
		{
			ticks=15,
			frames={121, 122},
		},
	},
}

function m_ene_spiker(x,y)
	local e = m_ene_crawler(x,y)
	e.is_boppable = false
	e.get_anim_data = function(self,anim)
		return spiker_data.anims[anim]
	end
end

-- CREW MEMBERS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- All functions for handling enemy, friendly, and player crew members
function draw_head(head, x,y, flipx, eye, skin, hair, beard)
	pal(5, beard)
	pal(4, hair)
	pal(15, skin)
	pal(12,eye)
	spr(head, x, y, 1, 1, flipx)
	pal()
end

crew_data =
{
	species =
	{
		names={"human", "greebo", "fuzzi", "demi", "robo"},
		["human"]=
		{
			names_s="brandon,bryan,fernando,harrison,ian,jack,jerry,jim,john,matt,ryan,ryon,shane,tom",
			names_f="amy,cate,jessica,kat,lauren,linda,melissa,rachel,samantha,sarah,sophia,steph",
			heads={80,81,82,83,84,85},
			eyes={11,12},
			skins={4,15},
			hair={0,5,6,4,10},
			trait=96,
		},
		["greebo"]=
		{
			names_s="garbl,grabl,glak,greg,grok,groog",
			heads={86,87},
			eyes={8,10,14},
			trait=97,
		},
		["fuzzi"]=
		{
			names_s="auri,bubba,bunbun,fluffy,hannah,hopper,mitzi,panda,spot",
			heads={88,89},
			skins={0,4,5,7},
			eyes={8,11,12},
			trait=98,
		},
		["demi"]=
		{
			names_s="j'mok,j'kspur,j'tok,k'duk,k'kul,k'rak",
			heads={90,91},
			eyes={10,11,14},
			trait=99,
		},
		["robo"]=
		{
			names_s="001,010,100,110,101,011",
			heads={92,93},
			eyes={8},
			trait=100,
		},
		["ixi"]=
		{
			names_s="vix,vex,vox,vee",
			heads={94,95},
			eyes={10,11,12},
			trait=101,
		},
	},

	dept_colors={12,8,10},

	anims=
	{
		["stand"]=
		{
			ticks=1,
			frames={65},
			h_off=0,
			v_off=0,
		},
		["move"]=
		{
			ticks=7,
			frames={66,67,68,69},
			h_off=1,
			v_off=0,
		},
		["jump"]=
		{
			ticks=1,
			frames={64},
			h_off=1,
			v_off=0,
		},
		["slide"]=
		{
			ticks=1,
			frames={70},
			h_off=1,
			v_off=0,
		},
		["duck"]=
		{
			ticks=1,
			frames={71},
			h_off=0,
			v_off=1,
		}
	},
}

function m_crew(x,y, species)

	local c=
	{
		name="maggie",
		x=x,
		y=y,

		dx=0,
		dy=0,

		col_w=4,
		col_h=7,
		col_off=4,

		max_dx=1,
		max_dy=2,

		jump_speed=-1.75,

		jump_hold_time=0,
		min_jump_press=3,
		max_jump_press=10,

		jump_btn_released=true,
		grounded=false,

		airtime=0,

		hp_max=100,
		hp_cur=100,
		invuln_frames=0,
		is_dead=false,

		jump_button=
		{
			update=function(self)
				self.is_pressed=false
				if self.jumpcom then
					if not self.is_down then
						self.is_pressed=true
					end
					self.is_down=true
					self.ticks_down+=1
				else
					self.is_down=false
					self.is_pressed=false
					self.ticks_down=0
				end
			end,

			jumpcom=false,
			is_pressed=false,
			is_down=false,
			ticks_down=0,
		},

		curanim="move",
		curframe=1,
		animtick=0,
		flipx=true,

		species="human",
		dept=2,
		skin=15,
		hair=12,
		beard=15,
		head=80,
		eye_col=13,
		blood=8,

		com =
		{
			ml = false,
			mr = false,
			j = false,
			d = false,
		},

		get_anim_data=function(self,anim)
			return crew_data.anims[anim]
		end,

		eq_item=nil,

		swap_nearby_item=function(self)
			local found_item = find_nearby_item(self)
			if found_item ~= nil then
				if self.eq_item ~= nil then
					self:drop_item()
				end
				self:equip_item(found_item)
				sfx(25)
			elseif self.eq_item ~= nil then
				self:drop_item()
			end
		end,

		use_eq=function(self, noene)
			if self.eq_item ~= nil then
				self.eq_item:use(noene)
			end
		end,

		equip_item=function(self,i)
			self.eq_item, i.is_eq, i.own =
				i, true, self

			if self == p1 then
				ui_bar_ene.is_hidden, ui_bar_ene.maxval = false, i.ene_max
				ui_bar_ene:set_value(i.ene_cur)
			end
		end,

		drop_item=function(self)
			if self.eq_item then

				self.eq_item.is_eq,
				self.eq_item.x,
				self.eq_item.y,
				self.eq_item.dx,
				self.eq_item.dy,
				self.eq_item = false, self.x, self.y, self.dx, self.dy, nil

				if self == p1 then
					ui_bar_ene.is_hidden = true
				end
			end
		end,

		die_base=function(self, instakill)
			if self.is_dead then
				return false
			end

			local x, y = self.x, self.y
			self.hp_cur = 0
			self:drop_item()

			if instakill then
				eff_burn(x,y, planet.colors[planet.biome][5])
			else

				local fx=rnd(1)
				if self.dx < 0 then
					fx = 0-fx
				elseif frnd(2) == 0 then
					fx = 0-fx
				end

				local fy= -(rnd(1)+1)

				m_headitem(self.head, x, y-8, self.dx+fx, fy, self.flipx, self.eye_col, self.skin, self.hair, self.beard)
				eff_explode(x, y, self.blood)
			end
			self.is_dead = true
			return true
		end,

		dmg_base=function(self, amt, instakill)
			if self.is_dead or amt <= 0 then
				return false
			end

			if instakill then
				self:die(instakill)
				return true
			elseif self.invuln_frames == 0 then
				self.hp_cur -= amt
				if self.hp_cur <=0 then
					self:die(instakill)
				else
					if self == p1 then
						self.invuln_frames = 40
					else
						self.invuln_frames = 6
					end
				end
				return true
			else
				return false
			end
		end,

		heal_base=function(self, amt)
			a_heal(self,amt)
		end,

		attack=function(self, target)
			target:dmg(25)
		end,

		init=function(self, species)
			if species == "maggie" then
				return
			end

			if species ~= nil then
				self.species = species
			else
				if frnd(100) < 50 then
					species = crew_data.species.names[max(2,frnda(5))]
				else
					species = "human"
				end
			end

			local skin, hair = nil, nil

			self.beard = 0
			local cd_s = crew_data.species[species]
			if species ~= "human" then
				if cd_s.skins then
					skin = cd_s.skins[frnda(#cd_s.skins)]
				end
			else
				skin = cd_s.skins[frnda(#cd_s.skins)]
				if(skin == 4) then
				 	hair = cd_s.hair[frnda(2)]
				else
					hair = cd_s.hair[frnda(#cd_s.hair)]
				end
				if hair then
					if frnd(4) == 0 then
						self.beard = hair
					else
						self.beard = skin
					end
				end
			end

			if species == "robo" then
				self.hp_max = 125
				self.blood = 10
			elseif species == "fuzzi" then
				self.jump_speed = -2
			elseif species == "demi" then
				self.max_dx = 1.25
			elseif species == "ixi" then
				self.hp_max = 25
			end

			self.hp_cur = self.hp_max

			self.head = cd_s.heads[frnda(#cd_s.heads)]

			local nl = cd_s.names_s

			if species == "human" and self.head > 82 then
				nl = cd_s.names_f
			end

			self.name = rnd(split(nl))
			self.eye_col = cd_s.eyes[frnda(#cd_s.eyes)]
			self.species, self.skin, self.hair = species, skin, hair
			self.dept = frnda(3)
		end,

		bop=function(self)
			sfx(1)
			score_add(self.x, self.y, 50)
			self.airtime, self.jump_hold_time, self.dy =
				0, 0, -1.5
		end,

		update_base=function(self)
			if self.is_dead then
				return
			end

			if self.invuln_frames > 0 then
				self.invuln_frames -= 1
			end

			a_move_ground(self)
			coll_side(self)

			self.jump_button.jumpcom = self.com.j
			self.jump_button:update()

			if self.jump_button.is_down then
				local on_ground = self.grounded or self.airtime < 5
				local new_jump_btn = self.jump_button.ticks_down < 10

				if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
					if(self.jump_hold_time==0) and self == p1 then
						sfx(2)
					end
					self.jump_hold_time+=1
					if self.jump_hold_time<self.max_jump_press then
						self.dy=self.jump_speed
					end
				end
			else
				self.jump_hold_time=0
			end

			a_handle_grav(self)

			if a_coll_floor(self) and self == p1 then
				sfx(3)
			end

			if self.airtime > 0 then
				if self.dx > 0.1 or self.dx < -0.1 then
					a_anim_set(self,"jump")
				else
					a_anim_set(self,"stand")
				end
			end

			coll_roof(self)

			if self.com.d and not self.com.ml and not self.com.mr then
				a_anim_set(self,"duck")
			else
				if self.grounded then
					if self.com.mr then
						if self.dx<0 then
							a_anim_set(self,"slide")
						else
							a_anim_set(self,"move")
						end
					elseif self.com.ml then
						if self.dx>0 then
							a_anim_set(self,"slide")
						else
							a_anim_set(self,"move")
						end
					else
						a_anim_set(self,"stand")
					end
				end
			end

			a_anim_update(self)

		end,

		draw=function(self)
			if self.is_dead then
				return
			end

			local a = crew_data.anims[self.curanim]
			local frame, yboboffset, hoffset, e, s, h, b =
			a.frames[self.curframe], 0, a.h_off, self.eye_col, self.skin, self.hair, self.beard

			if self.curanim == "move" and frame % 2 == 0 then
				yboboffset = -1
			end

			if self.flipx then
				hoffset = 0-hoffset
			end

			if self.curanim == "jump" and self.dx < 0.1 and self.dx > -0.1 then
				hoffset = 0
			end

			if a_set_invuln_flash(self) then
				e,s,h,b = 7, 7, 7, 7
			else
				pal(7,crew_data.dept_colors[self.dept])
				pal(1,0)
			end

			spr(frame,
				self.x-4,
				self.y-4+yboboffset,
				1,1,
				self.flipx)

			draw_head(self.head,
				self.x-4+hoffset,
				self.y-4+yboboffset+a.v_off,
				self.flipx,
				e, s, h, b)

			pal()
		end,
	}

	c:init(species)
	return c
end

function m_player(species)
	local p = m_crew(50,65, species)
	p.dy, p.dx, p.com.mr = -2, 1, true

	p.dmg=function(self, amt, instakill)
		if self:dmg_base(amt,instakill) then
			sfx(0)
			g_dmgd=1
			cam:shake()
			ui_bar_hp:change_value(self.hp_cur)
		end
	end

	p.die=function(self, instakill)
		if self:die_base(instakill) then
			sfx(4)
			music(-1)

			local newp = m_part(self.x-4, self.y-8, -.75, 116, 7, 30)
			newp.ddy, newp.flipx = .02, self.flipx

			updatemission()
			updatehighscore()
			g_gamestate = 4
		end
	end

	p.heal=function(self, amt)
		self:heal_base(amt)
		ui_bar_hp:change_value(self.hp_cur)
	end

	p.update=function(self)
		local itile_x = flr(self.x/8)
		local itile_y = flr(self.y/8)
		itile = mget(itile_x, itile_y)
		if itile >= 72 and itile <= 73 then
			mset(itile_x, itile_y, 0)
			score_add(itile_x*8+4, itile_y*8, 25+25*(itile%72))
			sfx(13)
		end
		self:update_base()
	end

	return p
end

function a_random_jump(self, tperiod)

	local c_j = false
	if self.grounded then
		if ticks % tperiod == 0 then
			c_j = true
		end
	else
		if frnd(100) > 25 then
			c_j = true
		end
	end
	self.com.j = c_j
end

list_crew_ai = {}

function m_crew_ai(x,y, is_enemy, species)
	local ai = m_crew(x,y, species)
	ai.hp_max, ai.hp_cur, ai.is_boppable, ai.is_enemy =
	25, 25, true, is_enemy

	if is_enemy then
		ai.max_dx = .75
		if ai.dept > 1 then
			ai:equip_item(m_item_type(0,0,10))
		else
			if frnd(75+5*g_planet) > 50 then
				ai:equip_item(m_item_type(0,0,100))
			end
		end
	end

	if ai.dept < 3 then
		ai.com.ml = true
	end

	ai.dmg=function(self, amt, instakill)
		self:dmg_base(amt,instakill)
	end

	ai.die=function(self,instakill)
		if self:die_base(instakill) then
			if self.is_enemy then
				del(list_enemies, self)
			else
				del(list_crew_ai, self)
			end
		end
	end

	ai.heal=function(self,amt)
		self:heal_base(amt)
	end

	ai.update=function(self)

		if ai.is_enemy then
			if ai.eq_item ~= nil and ticks % 50 == 0 and frnd(2) == 0 then
				ai:use_eq()
			end

			if self.dept == 3 then
				if ticks % 30 == 0 then
					self.flipx = not self.flipx
				end
				a_random_jump(self, 100)
			else
				a_move_ground_logic(self)
			end
		else
			self.com.ml = false
			a_random_jump(self, 10)
		end

		self:update_base()
	end

	if is_enemy then
		add(list_enemies, ai)
	else
		add(list_crew_ai, ai)
	end

	return ai
end

function m_cam(target)
	local c=
	{
		tar=target,
		pos_x = target.x,

		shake_remaining=0,
		shake_force=0,

		update=function(self)

			local pos_x, tar_x =
					self.pos_x, self.tar.x

			self.shake_remaining=max(0,self.shake_remaining-1)

			if pos_x+8<tar_x then
				pos_x+=min(tar_x-(pos_x+8),4)
			end
			if pos_x-8>tar_x then
				pos_x+=min(tar_x-(pos_x-8),4)
			end

			self.pos_x = mid(64, pos_x, 960)
		end,

		cam_pos=function(self)
			local shk_x, shk_y = 0,0
			local force = self.shake_force

			if self.shake_remaining>0 then
				shk_x=rnd(force)-force/2
				shk_y=rnd(force)-force/2
			end
			return self.pos_x-64+shk_x,-32+shk_y
		end,

		shake=function(self)
			self.shake_remaining=15
			self.shake_force=2
		end
	}

	return c
end

function m_ui_bar(y, w, col_change, col_fill, maxval, icon, is_hidden, breakatzero)

	local b = {
		y=y,
		w=w,

		maxval=maxval,
		cur=maxval,
		peak=maxval,
		icon=icon,
		is_hidden=is_hidden,
		breakatzero=breakatzero,

		change_pulse_ticks=0,
		icon_flash_frames=0,
		delay=0,

		col_change=col_change,
		col_fill=col_fill,

		update=function(self)
			if self.delay > 0 then
				self.delay -= 1
			else
				if self.peak > self.cur then
					self.peak -= 2
				else
					self.peak = self.cur
				end
			end

			if self.peak <= 0 and self.breakatzero then
				self.is_hidden=true
			end

			if self.change_pulse_ticks > 0 then
				self.change_pulse_ticks -= 1
			end
			if self.icon_flash_frames > 0 then
				self.icon_flash_frames -= 1
			end
		end,

		draw=function(self)
			if self.is_hidden then
				return
			end

			local y, y1, w = self.y, self.y+1, self.w

			if self.icon_flash_frames > 0 and self.icon_flash_frames % 2 == 0 then
				pal_flash_invuln()
			end

			spr(self.icon, 2, y-1.5)
			pal()

			rectfill(12,y,13+w,y+4,0)
			rectfill(13,y1,12+w,y+3,5)
			if self.peak > self.cur then
				rectfill(13,y1, max(13, 12+(self.peak/self.maxval*w)), y+3, self.col_change)
			end
			if self.change_pulse_ticks > 0 then
				rectfill(13,y1, 12+(self.peak/self.maxval*w), y+3, 7)
			else
				if self.cur > 0 then
					local l = self.cur/self.maxval*w
					rectfill(13,y1, 12+l, y+3, self.col_fill)
				end
			end
		end,

		set_value=function(self, newval)
			self.cur, self.delay, self.change_pulse_ticks, self.peak =
				newval, 0, 0, newval
		end,

		change_value=function(self, newval)
			if newval < 0 then
				newval = 0
			end
			if newval > self.maxval then
				newval = self.maxval
			end
			if newval < self.cur then
				self.delay, self.cur, self.change_pulse_ticks = 20, newval, 10
			else
				self.cur=newval
			end

		end,
	}
	return b
end

-- INITIALIZATION AND GAME LOOP >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function _init()
	cartdata("tmirobot_lilspace_13")
	g_score_high, g_game_won, g_mission = dget(0), dget(1), dget(2)
	startup()
end

function setup()
	if frnd(100) == 0 and not g_resetrace then
		p1=m_player("maggie")
	else
		p1=m_player(g_resetrace)
	end

	--planet=m_planet()

	ui_bar_hp = m_ui_bar(13,p1.hp_max/2,10, 11,p1.hp_max, 74)
	ui_bar_ene = m_ui_bar(23,50,9, 12, 100, 75, true, true)
end

function reset()
	g_planet, g_block_last_x, g_block_last_y, g_score, g_acc, g_dec, g_level, g_level_end, g_gamestate,
 	g_waitforinput, g_dmgd, g_score_trans,
	ticks =
	-1, 999, 999, 0, 0.075, 0.15, 0, 0, 3,
	false, 0, 0,
	0
	reload(0x2000, 0x2000, 0x1000)
	setup()
end

function startup()
	reset()
	g_gamestate = 0
	g_difftext = "all clear!|seems safe?|seems ok|be careful|stay frosty|feels unsafe|this is bad|not good...|oh no...|why me?!?|we're doomed!|we're dead|impossible!|it's hopeless|"
	g_crashtext = "that can't be good...|eh..we were out of fuel anyway!|hold onto your butts!|i may have lied on my resume...|i was just reheating my lunch!|did anyone else hear that?|here we go again!|oh you've got to be kidding me!|why is a dog piloting the ship?|tell my mom i loved her!|i'm not a fan of this!|i regret nothing!|i said don't touch that!|why is this happening again!?|i didn't touch anything!|we're under attack!|this is fine|space eels in the engine core!|should i not press that button?"
	music(0)
	trans_space_into()
end

-- TRANSITIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- set up the variables to load the player into a new planet from space
function trans_planet_into()
	g_planet+=1
	g_level, g_dmgd, ui_bar_ene.is_hidden, planet
		= 0, 0, true, m_planet()

	if g_planet >= 4 and frnd(2) == 1 then -- chance of extra level in later planets
		g_level_end = 1
		g_diff += 2
--		printh("diff: +2 second level")
	end

	level_clear_and_build()
	p1.x, p1.y, p1.dy, p1.dx, p1.com.mr, g_gamestate = 50,65, -2, 1, true, 3

	cam=m_cam(p1)
	cam:update()
	cam:shake()
--	 printh("-------- diff total:"..g_diff.." ----------")
	m_textfloat(70, 56, split(g_difftext,"|")[g_diff+frnda(2,1)], .1)
	sfx(11)
end

-- set up the variables for transitioning into space
function trans_space_into()
	table_clear(list_parts)
	g_ship_crash, g_ship_x, g_ship_y, g_ship_dy = 0, 56, 128, -1
end

-- set up variables for transitioning between levels
function trans_level()
	g_level += 1
	level_score()
	p1.x, p1.y, p1.dx, p1.dy = 8, 71, 0,0
	level_clear_and_build()
	if p1.eq_item then
		add(list_items, p1.eq_item)
	end
end

-- UPDATE LOOPS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function _update60()

	ticks+=1
	if g_gamestate < 2 then
		update_space()
	else
		update_game()
	end
end

function update_game()

	if p1.x > 1020 then
		trans_level()
	end
	if g_gamestate == 3 and g_level == g_level_end and p1.y > 63 and p1.x > 956 and p1.x < 968 then -- arrived at ship/house location
		level_score()

		if p1.eq_item ~= nil then
			g_score_trans += p1.eq_item.score
			del(list_items, p1.eq_item)
			p1.eq_item, ui_bar_ene.is_hidden = nil, true
		end

		p1:heal(25)

		if is_planet_final() then
			sfx(14)
			m_part(950, 60, -.5, 74, 8, 80)
			g_gamestate, g_game_won, p1.is_dead = 2, 1, true
			g_score += g_score_trans

			dset(1, 1)
			updatehighscore()
			updatemission()
		else
			sfx(12)
			sfx(26)
			g_gamestate = 1
			trans_space_into()
		end
		return
	end

	if ticks % 10 == 0 then
		if g_level == 0 then
			eff_smoke(38,58)
		end
		if g_level == g_level_end and is_planet_final() then
			eff_smoke(960,52)
		end
	end

	if not p1.is_dead and planet.toxiclevel > 0 and ticks % planet.toxiclevel == 0 then
		p1.hp_cur -= 5
		ui_bar_hp:change_value(p1.hp_cur)
		sfx(10)
		if p1.hp_cur <= 0 then
			p1:die()
		else
			local newp = m_part(p1.x-4, p1.y-6, -.75, 106, 11, 30)
			newp.ddy, newp.flipx = .02, p1.flipx
		end
	end

	p1.com.ml, p1.com.mr, p1.com.d, p1.com.j = btn(0), btn(1), btn(3), btn(4)

	p1:update()
	cam:update()

	if btnp(5) then
		if g_gamestate == 2 then
			startup()
			return
		end
		if g_gamestate == 4 then
			reset()
			trans_planet_into()
			return
		end
		if p1.com.d then
			p1:swap_nearby_item()
		else
			p1:use_eq()
		end
	end

	local fu = function(i) i:update() end
	foreach(list_items, fu)
	foreach(list_parts, fu)
	foreach(list_projs,fu)
	foreach(list_crew_ai, fu)

	foreach(list_enemies,
		function(e)
			e:update()

			if not p1.is_dead and int_cols(p1, e) then
				if e.is_boppable and landing_on_target(p1, e) then
					p1:bop()
					e:die()
					return
				end
				e:attack(p1)
			end

			foreach(list_projs,
				function(p)
					if int_cols(p,e) and not p.is_enemy then
						score_add(e.x, e.y, 25)
						e:dmg(25)
						p:impact()
					end
				end)
		end)

	if not p1.is_dead then
		foreach(list_projs,
			function (p)
				if int_cols(p,p1) and p.own ~= p1 then
					p1:dmg(25)
					p:impact()
				end
			end)
	end

	ui_bar_hp:update()
	ui_bar_ene:update()
end

function update_space()
	if g_ship_y < 62 then
		g_waitforinput, g_ship_y, g_ship_dy = true, 62, .9
		if g_gamestate == 1 then -- ship reached center and we've finished a planet
			sfx(28)
			score_add(64, 64, g_score_trans)
			g_score_trans = 0
			updatehighscore()
		end
	elseif g_waitforinput then
		local hardmode = false
		if btnp(4) and g_game_won > 0 and g_gamestate == 0 then
			hardmode, g_resetrace = true, "ixi"
			setup()
		end
		if btnp(5) or hardmode then
			g_ship_crash, g_waitforinput = 1, false
			music(-1)
			sfx(24)

			m_textfloat(64, 50, rnd(split(g_crashtext, "|")), .1)
		end
	else
		g_ship_y += g_ship_dy
		if g_ship_crash > 0 then
			g_ship_x += .35
			eff_proj_impact(g_ship_x+frnd(5),g_ship_y+frnd(5))
			eff_smoke(g_ship_x, g_ship_y)
		end
	end

	if g_ship_y > 129 then
		trans_planet_into()
	else -- stars
		if ticks % 2 == 0 then
			local c, dx = frnda(3), -2

			if c > 2 then
				c, dx = 7, -4
			end

			local p = m_part(129, frnd(128), 0, 109, c , 120)

			p.dx = dx+frnd(2)
		end
		foreach(list_parts, function(p) p:update() end)
	end
end

-- DRAW FUNCTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function _draw()
	if g_gamestate < 2 then
		draw_space()
	else
		draw_game()
	end
end

function draw_space()
	camera(0,0)
	cls()
	foreach(list_parts, function(p) p:draw() end)
	spr(60, g_ship_x, g_ship_y, 2,1)

	if g_waitforinput then
		draw_status()
	end
end

function draw_game()
	camera(cam:cam_pos())
	planet:draw()

	pal()

	local fd = function(i) i:draw() end
	foreach(list_crew_ai, fd)
	foreach(list_enemies, fd)
	p1:draw()

	foreach(list_projs, fd)
	foreach(list_parts, fd)
	foreach(list_items, fd)
	draw_hud()
end

function draw_status()
	local s = ""
	if g_gamestate == 0 then
		s = "little space rangers"
	elseif g_gamestate == 1 then
		s = "planet "..(g_planet+1)..": cleared!"
	elseif g_gamestate == 2 then
		s = "mission "..g_mission..": success!"
	elseif g_gamestate == 4 then
		s = "mission "..g_mission..": failed"
	end

	if g_gamestate ~= 3 then
		rectfill(0, 27, 128, 53, 0)
		local newhigh =  ""
		if g_gamestate ~= 0 then
			if g_score == g_score_high then
				newhigh=" new!"
			end
  -- UNDO >> Easy spot to temporarily get some tokens back when I go over
		 	printc("score:"..g_score.." / best:"..g_score_high..""..newhigh.."", 38)
			printc("press \151 to continue", 46, 5, 62)
		else
			camera(0, -14)
			printc("v1.3 created by @tmi_robot", 38, 2)
			printc("high score:"..g_score_high.."", 104)
			printc("press \151 to start", 62, 5, 62)
			if g_game_won > 0 then
				pal(6, 10)
				pal(5, 9)
				printc("press \142 for hard mode", 70, 5, 62)
			end
			map(80, 0, 0, -11, 16, 12)
			pal()
		end
		printc(s, 30, 8)
	end
end

function draw_hud()

	camera(0,0)
	if g_gamestate == 3 then
		rectfill(0, 0, 128, 31, 0)
	else
		rectfill(0, 0, 128, 21, 0)
	end

	ui_bar_hp:draw()
	ui_bar_ene:draw()

	print(""..p1.name, 3, 3,7)

	if(p1.eq_item ~= nil) then
		print(""..p1.eq_item.name, 80,23)
	else
		if not p1.is_dead and find_nearby_item(p1) ~= nil then
			print("\131+\151 grab item", 3, 23)
		end
	end
	spr(crew_data.species[p1.species].trait, 108, 1)
	print(""..p1.species, 80, 3)

	local picon = 103
	if planet.grav == .2 then
		picon = 104
	elseif planet.grav == .3 then
		picon = 105
	end
	spr(picon, 107, 12)
	print(""..(g_planet+1)..":"..(g_level+1), 92, 13)

	if planet.toxiclevel > 0 then
		spr(109-planet.toxiclevel/250, 116, 12)
	end

	local pc = planet.colors[planet.biome]

	pal(4, pc[2])
	pal(1, pc[5])
	spr(102, 79, 12)

	draw_status()
end
__gfx__
01234567bbbbbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbb00bbbbbb00bbbbbb00bbbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbb5444444b5444444
89abcdef555bb5b55bb5bbb55b555b55bb5b555555b5b5bbb55bb5bbbb55b55bb55b55b55b5b55b55b55b55b555b5bbb5bb5b5b5bbb55b55b5444444bb544444
00700700444554544554555445444544b54544444454545bb545545bb544545bb5454454454544544544545b00454b5b45545454bb544500bb544444b5444444
00077000444444444444444444444444bb544444444444bbbb54445bb54445bbbb54444444444444444445bb000005454444444455400000bb544444bb544444
00077000444444444444444444444444b54444444444445bbb5445bbbb5445bbbb54444444444444444445bb000000000000000000000000bb544444b5444444
00700700444444444444444444444444bb5444444444445bb544445bb544445bb5445544454455444455445b000000000000000000000000b5444444b5444444
00000000444444444444444444444444b54444444444445bbb5445bbbb5555bbbb55bb555b55bb5555bb55bb000000000000000000000000bb544444bb544444
00000000444444444444444444444444b54444444444445bb544445b0bbbbbb00bbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000b5444444b5444444
4444445b4444445b4444444444444444b54444444444445bb544445bb544445bbbbbbb5445bbbbbbcccccccccccccccccccccccc0cccccccccccccc00cccccc0
4444445b4444445b4444444444444444b54444444444445bbb5445bbbb5445bb555bb544445bb5b5555cccccccccccccccccc555c5cccccc5ccccc5ccccccccc
444445bb444445bb4444444444444444bb544444444445bbb544445bb544445b44455444444554544445555555555555555554445555cc5c4555c55555555c55
4444445b444445bb4444444444444444b54444444444445bbb5445bbbb54445b4444444444444444444444444444444444444444bb545545444454bbbb54455b
444445bb4444455b4444444444444444bb544444444445bbb54445bbbb5445bb4444444444444444444444444444444444544444b54444444444445bbb5445bb
4444445b444445bb4554455445445544b54544444454445bb545545bb544445b4444444444444444454445544444444444444454bb5444444444445bb544445b
444445bb444445bb5bb55bb55b55bb55bb5b555555b555bbbb5bb55bbb5445bb4444444444444444444445544444444444444444b54444444444445bbb5445bb
4444445b4444445bbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbb00bbbbbb0b544445b4444444444444444444444444444444444444444b54444444444445bb544445b
0cccccc00cccccccccccccccccccccc0cccccccccccccccccccccccc1111111100000666660000000000000000000000bbbbbbbbbbbbbbbb0000000000000000
cc55c55cc55c55c55c5c55c55c55c55c555c5ccc5cc5c5c5ccc55c55111111110006652e256600000000000000000000555b5bbbbbb55b550000000000000000
5544545555454454454544544544545500454c5c45545454cc544500111111110065002e20056000000000000000000000454b5bbb5445000000000000000000
b54445bbbb54444444444444444445bb000005454444444455400000111111110650888888005600000008000099990000005545554500000000000000000000
bb5445bbbb54444444444444444445bb00000000000000000000000011111111060888888888060000000908009aa90000000000000000000000000000000000
b544445bb5445544454455444455445b00000000000000000000000011111111650888000008056000000909009aa9000000000000000000000aa00000000000
bb5555bbbb55bb555b55bb5555bb55bb000000000000000000000000111111116008882e20000060000009999999a90000000000000000000055aa00aa000000
0bbbbbb00bbbbbbbbbbbbbbbbbbbbbb000000000000000000000000011111111600888888888006000009aaaaaaa990000000000000000000055aaa0aa000000
000000000000000000000000000000000000000044444444444444444444444460000000088800600099aaaaaaaaa9000aaaaa0000000000aaaaaaa9aa000000
00000000000000000000000000000000000000004444444444444544455444446508002e2888056009999aaaaaaaaa9088aaaaaaaa000000aaaaaaa9aaa00000
000000000000000000000000000000000000000044444444444444444554444406088888888806009aaaa9aaaaaaaa9088aaaaaaaaaaaa00aaaaa9a9aaa00000
0000000000000b000000000000000000000440004444444444444444444444440650088888805600a2222a9aaa222aa98aa9aaaaaa2222a0aaaa9aaaaaa00000
000000b00000b0000000000000000000000440004444444444444444444445440065000000056000a2222a9aaa222aa9aa9aaaaa9aaaaaaa0aaaaaaa9aaa0000
00000b000000b00b0000000000000000004440004444444444444444444444440006652e25660000a2222a9aaa222aa9a9999999aaaaaaaa00aaaaa999aa0000
000b0b0000b0b0b00044000000004400004444004444444444444454445444440000066666000000a2222a9aaa999aa90aaaaaaaaaaa99a000044a99999aa000
000b0b0000b0b0b00444400004004440004444004444444444444444444444440000000000000000a2222a9aaaaaaaa9000aa0000000aa000044444999444a40
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001234560
0000000000000000000000000000000000000000000000000000000000000000000000000000000000880880000cc00000000000000000000000000089abcde8
000000000000000000000000000000000000000000000000000000000000000000000000000000000888888800cccc0000000000000000000000000000700700
000000000000000000000000000000000000000000000000000000000000000000000000099999aa0888888800c11c0000000000000000000000000000077000
00000000000000000000000000000000000000000000000000000000000000000009999a022222220088888000c11c0000000000000000000000000000077000
007777000077770000777700007777000077770000777700007777000000000000022222099a99aa0008880000cccc0000000000000000000000b00000700700
01111110001111000011110000111100001111000111110000111100007777009a099a9a099999aa0000800000cccc0000066800000090000006600000000000
00000000001001000010100000011000001001000000010001001000001001009a09999a099999aa000000000000000000060000000600000006600000000000
00000400000000000000000000000000000000000000040000000000000000000000000000f0f0000000000000808000000800000008000000a00a0000000000
004444000044440000ffff0000444400004444000044440000bbb00000bbbb0000f00f0000ffff000008080000080800000600000066660000a00a0000a00a00
004fff00004fff0000ffff00044fff4000444f00004fff0000bbbb0000bbbb0000ffff0000ffff00002828000028280000666600006666000aaa99900aaa9990
00fcfc00004cfc0000fcfc00044cfc40004cfc0004fcfc400bbcbc0000bcbc0000fcfc0000fcfc00002c2c00002c2c00006ccc00006ccc0000a8980000a89800
00555500005555000055550000ffff0004ffff0000ffff0000bbbb0000bbbb0000ffff0000ffff00002222000022220000666600006666000099990000999900
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000011100000000000000000000088800000000000000000000000000000000000000000000000000
0000000000c000000000000000000000000000000000000000144110000000000009990000088800000000000000000000000000000000000000000000000000
000000000ccc000000a0000000a00000080800000808000001444411000bbb00000999000008880000bbbb000099990000888800000000000000000000555000
000000000c1c00000aaa000000aa00008888800088888000044144140000000000000000000000000bbbbbb00999999008888880000000000007000005555500
000000000ccc00c0aaaaa0a0aaaaa0a088888080888880000111111100bbbbb000999990008888800bb0bb000990990008808800000700000007000005555500
000000000ccc0ccc00a00aaa00aa0aaa088808880888088800411440000bbb0000099900000888000bbbbbb00999999008888880000000000000000005555500
000000000ccc00c000a000a000a000a00080008000800000000144000000b0000000900000008000000b0b000009090000080800000000000000000000555000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007777000000000001100001000000000000000000000000000000002000200200000000000000000000000000000000
00000000000000000000000000077000077777700000000019190010000000000000000000000000000110002929002000000000000000000010101000010100
00055000000000000000000000077000077077000070070011110100000000000000000000100100001001000220020000000000000000000111111100111110
00555500000088000000000007777770077777700007700000001000000000000011110001000010001001000000200010000001000000000011111001111111
005555000088aa800777777007777770000707000007700000010101001111100119191001000010001111000002002011000011001111000119191100191910
0005500000008800000000000007700070000007007007000010010101119191011ddd1000111100001111000020022201111110011919100011111001111111
0000000000000000000000000007700007777770000000000100091911111111111ddd1101911910019119100200292901191910111111110111111100111110
00000000000000000000000000000000700000070000000010000111111111111111111101111110011111102000022200111100100000010010101000010100
00130f40201172727272e020501f006700333f4081a1a1b1b1c1c191501f006700000000000000000000000f84e053011f130f00000000230000000000136700
0f2300131f71e400000067000000000000230f133f71000000000000000000000000000000000000000000000000847100000000001f40205353535353535311
102020735353301020305353531020102030207353535373535353535320203020503f0f43336700000000402053535320302050000000d1e100000040202010
1020201010535000000040a1b1b1c191102020101001e40f0000b700003343402050000000f1000000d1e1000000405310500000401063735353535353536373
536353535353536353535373535353535363535353535353535353735353535353632010a1b1a1c1500000e05353535373535311727272f001727272e0637353
53635353535311727272e07353535353536353535353101050000000c2401053730172727271727272e011727272e06353117272e05353535353735353535353
53536373535373535363535353535363535353735363735353635353535353635353637353535353010000f05363735353535353302010536320302053535353
5353637353537310302053535353536353535373536373530100000000e053635373102030732010306373103020735353531030735353535353535353535363
000000411100000000000000e0510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000067e0010000000000000000000000000067e0110000000000000000000000000000000000e05100000f3f1fe4130f1f0f3f0300
00000000610000000000000061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000f3f0000000f84f0110000000000000000000000000f844151000000000000000000000000000000000071000000b0c0c0c0c0c0c0c0802050
00000000007700000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000033d1e1000000b0c0f00100000000000033e484000000b0d000000000000000000f84670000000000000000711300000000000000000000004111
000000000fe4130000001f8413000000000000000000000000000000000000000000000084000000000087000000000000000000000000000000000000000000
00000000000042e0110f67000000e0110000000000004240500f840000000000000000b70000b0c0c0d00000b70000000071d000000000000000000000000071
0000000012223200000012223200000000000fe4670000008433000003e46700000000007000000000007000000000000033840000001367840f000000000000
0013841f000000f001c0d0b70000f011000000000000004151c0d000000000000f1f000000000000000000000000133f00718467433367030f673300b7000071
000000000000000084000000000000000000b0c0d000b7425262b700b0c0d000000000000000002300000000003300000042620000b7b0c0c0d000b700000000
0042526200b700e01100000067e441510000000000000000000000b71f0f0000b0d000000003840000e433000000b0d000e0a0c0c0c0c0c0c0c0c0d000000071
0000000000000000f10000000000000000000000000000000000000000000000000000000000b70200000000b70200000000000000000000000000000000030f
00000000000023e001000000b0d00000000000000000000000000000b0d000000000000000426200004262000000000000610000000000000000000000003371
000000000000000061000000000000000000000000000000000000000000000000000000870000000000e400000000000000000000000000000000000000b0d0
00000000000042f0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b071
0000000013330f6700131f00000000003f0f0000870000008700000087000000130f0000020000000000020000000013000f000000000000e400000000001f67
000f0000000000f011030000000f1f67030f0000000000000000000000000377000f000000000023670300000000334303330000000f1f2300b7334300008471
205000004010203020302050000000402050000060000000600000006000004020500000000000000000000000000040203050d2000000d1e1000000c2401020
203050d2000000e001d00000c240102020500000031f77e4003f6733000040202050000000c240a1c150d2000000402020500000001222e1000040a00000b0e0
53117272e053536353535311727272e0530172727172727271727272717272e0631172727272727272727272727272e063730172727272e01172727272e07353
63730172727272e01172727272e073537311000080901020101090a00000e053531172727272f053530172727272e053531172727272727100007172727272e0
53532010535373535363535310302063537320306310302073102020533010735373302010203020201020301020207353536320103010735330101010535363
53536320103010735330101010535363530100000000f063731100000000f0635353102010105353535310303010536353533010201020110000e01020202063
00007100000000000000000000000061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000071000000000000000000007100000000000000000000000000000000000000000000000000000000000000000000
0000718400003f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000e400000000000000000000713f0000000000000000006100000000000000000000000000000000000000000000000000000000000000000000
000041500f672f8467e41f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000840f84030000000000000000712f0000840f678400001f3f00000000000000000000000000000000000000000000000000000000000000000000
00000041201090909090500000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000042525262000000000000000041508400b0c0c0d0008440a000000000840000000f00000000000000000000000000000000000000000000000040
00000000415100000000713f00000f71000000000000000000000000000000000000000000000084000000000000000000000000000000000000000000000000
000000002300000000000003000000000000004150000000000000405100000000007000000070000000000000000000000000000000000000000000000000f0
0000000000000000000041a003138051000000000000001367000000000000000000000000004252620000000000000000000000000000000000000000000000
00000000020000000000000200000000000000007167843f000f1f710000000000000000000000000000000000000000000000000000000000000000000000e0
0000000000000000000000b0c0c0d000000000000000b0c0c0d00000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000041909050c08090510000000000000000b7000000b7000300b7000000000000000000000000000000000000f0
0000000000000000b70000000000000000000000b700000000000000b70000000000000000b7000000b700000000000000000000000000000000000000000000
00000000000000000000000000b7000000000000000000610000000000000000000000000000000000c270000000000000000000000000a2b2000000000000f0
3f0f001f1300000000000f0033674300030f0000000000000000000000000067330f0300000000000000000003670f23131f000000b7000000b7000000236703
030f00008700000f770000870000031f0023000013330f7700131f00000003000f000000000023000000000000003343000f13230f1f00a3b30f030000000fe0
2081a1c1c150000000c240a1b1a1c1201020500000002367e40f000000c2402030201050000000020000004020101020302050d200000002000000c240302030
20500000600000405000006000004020205000004010203020302050000040202050000000c2700000000000000040203020302030302010102081a1b1c19153
53535353531100000000e07353535353537311000000809090a000000000e0535373530100000000000000e063535373535301000000000000000000e0536353
73110000717272e0117272710000e05353117272e0535363535353117272e0535311000000000000000000000000e05353535353736353535353535353536353
63735353630100000000f053535363735353110000000000000000000000e0635353531100000000000000f053535353637311000000000000000000f0635353
53010000e0101063732030110000f063535320105353735353637353203053635301000000000000000000000000f06353735353535353735353536353535353
0000000000000000080bb0000000080000000000000000000e3bbbb0000000000000000000000000004444400000000000000000000000000055550000000000
0000000000000000898bb000080089800000000000000000033bbb3e00ee3300000000000000000000455440000000000000000000055550005cc50000000000
000000000000000008bbbb00898008b00000000000333e0000bbbb330ee3333000000000000000000445444000044400000000000055c5500055c55000550000
08000000008888000000b80008000b00000000000ee33ee00003eb0033333ee30000000000054400045555400004540000000000005c55500555555000550000
89800800082992800000898000b00b00000000000ee3333000b33bb033333ee30000000000445400044444440044540000000000005c5c500557555000550500
0800898008888880000bb80000bbb080033033000333ee3003ebbb333ee33333000004400444554004555544004555400055055005555c550557575000550500
00b008000022220000bbbb000bbb08980330b303000bbb00033bbbe30ee333300440444404554450044544440045454000775c50057777550777775000555500
00b00b000b0bb0b00bbbb00000bbb08000b0b00b000bbb000bbbbbbb00bbbb0045544554054445400444444400444440077777777777777777777777005c5500
__gff__
0001010101010101010101020202010101010101010101010101050505050505050505050606060800000000020200000000000000010101000000000000000000000000000000008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000e12150000000000000000000000170017000000000000000000000000f300000e361100000000000000000f351000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000017000000000000000000000000001700170000000000000000000000f3f2f3000e371100000000000000000f351000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000031483000000000000000170000000000000000000000000016001700000000f37600f3000000080105000f35150000f17648f1000014371000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000b060d000000000000001748f0f177000006f3480000004ef0001748f100000b0c0c0d000000000e10000e150000000b0c0c0d000000141100000000000000002829000000000000000000000000000000000000000000000400000000000000000000000000000004
00000000000000000000000000000000000000f04800000017000000f0314800000e01050c0d0000140905272727040500170c0d000000f3f376000000001411001748f1f3000000000000f3f1481700000000535a565c38395d575b540000000000000000000000000000000000000f0000000000000000000000000000000f
050000000000000000000000000000000000000b060d0000160000000b060d0000143715000000f0f1001409090912110017000000f348f2f248f3000000001700160c0c0d0000000000000b0c0c1600000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000e
110000000000000000000000000000000000000016f3002e0000000000160000000017000000000b0d0000000000001700160000000b0c0c0c0c0d00002e0017000000f30000000000000000f3000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000f
11f30000002e000000000000000000000000f1f04ef2573e3ff03457f3f0f1f000001600000000000000f1f30000f317000000000000000000000000003e3f170000f3f2f100f076f3f000f1f2f3320000000000000000000000000000000000000000000000002a2b00f3000000000f0000000000000000000000000000f30f
10f2f1f04e3e3f4e34f3000000f0313200f00401010219363719180302180305000030000000000000000b0d0000f21700f100000000000000000000000b04110000040205000b0c0c0d0004020532000000000000000000000000000000000000f03132f3f1003a3bf0f2f10000f30e00333132f030003c3d32f10000f3f20e
350102021836371801181a1b1c1903020301353535353535353535353637353501010500f3000000002e0000f348043702050000000000007b00000000000e37010212131500002e00000b1412130303000000000000000000000000000000000302030203030201010202181a1c193503020302011818373619181a1c190235
353635353535353535353535353535353536353536373535353535353535353536373505f27748f1773e3f77f204373535100000001f2d00002c1f0000000f35351048003234763e3f76340000480e37000000000000000000000000000000003535353537363535353535353535363535353535373635353535353535353635
35353535363535353535353535353535353535353535353535353735353535353535353501010101183736190135353535112727271727272727172727270e3536370102010102010103020301013535000000000000000000000000000000003535373535353535373535353635353535373535353535373535353635353535
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030f000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f04e3000000031483300000000000000007b0000000000000000000000000000000000242600007b08020500000048f1f0007b0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000078000000000000000000007b000b0c0d0000000b0c0d7b00000048304e0000000000000000003048000000487630000000000000000014110000000b0c0d00000000000000000000
304876f00000000000000000304876f000000000000000000032300000000000000000000000007b00780000000000000000000000007b0020007b0000000000000000000000000076f376000000000000000b0c0d0000000000000000000b0d0000000b0c0d00000000000000314817000000000000000000f04e3000000000
0b0c0c0d00000000000000000b0c0c0d00000000000000000021222300000000000000000000000000200000000000000000000000000000000000003300000000000000003331f1f3f2f3f1300000000000000000000030764ef00000000000000000000000000000000000000809110000000000000000000b0c0d00000000
0000000000000000000000000000000000000000000078000000000000000000000000000020000000000000000000000000000020000000000000002000000000000000f00401030201010205f00000000000000000000b0c0c0d00000000000000000000000000242600000000001700000000000000000000000000000000
0030f00000000032000000000031f07600f0320000001f0000004e48000032773300000000000000004e000000000077f0000000000000334e320000000030f00000300402373535353535353601050033300000000000000000000000003100f131f000000000000000000000f1761700f000003076f1000032763100003000
010203050000001d1e00000004020101020305000000170000001d1e0000040202052d000000000000200000002c0402010500000000002122230000000004020102013535353535363735353537350201050000f077000000000000f0f1040202090a0d00000000000000000b0c0c0e02050000040105000004020500000402
353535112727270f102727270f363735353710272727172727270e1127270e3637112727272727272727272727270f3737110000000000000000000000000f3735373535353535363535353535353535351100000405000048770000040235351048300000003076f000000000f0480e351127270e351127270f351127270e35
35353535020103353501020235353535353535020102370301023736020235353535030102020302030201030101353535100000000000000000000000000e3535353536373535353535353535353536351000000f110000040500000e3535363502050000000402030500000004013735350201353537020136373502033536
0000143535351213131213353535110000143537110000000000000e35351100000e353615000000000000000014121500000f3535353635353635353535351100000000000000000000000000141311000000000000000000000000000000170017000000000000000000000000f30000000014361312133535353535353511
0000001436100000000000141213150000001435100000000000000f373515000014371000000000000000000000f30000000e3535363735353535353537131500000000000000000000000000f3001700000000000000000000000000000017001700000000f0f1324ef034f0f3f2f100000000160000000e12133637353510
000000000e110000000048f14e0000000000000e1148f0000000000e3515000000000e15000000000000000000f1f2f300000e3635353535351312353510000000000000000032f00000760000f24e17000000000000327600000000f0764e1700170000000b0c0c0c0c08090902020500000000000000001600001412133711
000000001415000000000b0c0d0000000000000f100c0d000000000f110000000000170000000000f0760000001d1b1e00000f351312133610000014351148f00000000000040305000402050004031100000000000402090a000000080902110017330000000000000000000014361000000000004e007b0000000000001415
00000000000000007b00000000000000000000141500000000004e0e10000000000016000000000b0c0d0000000e3711000014110000000f114800000f36020500000076000e13150014131500141311f0f10000000e1500000000000000141100170d00000000000000000000001411000000f0483200000000000000000000
000000000000000000000000000000000000000000000000000b0c14150000000000f1763000000000000000000f35100000001600000014150d00001413121500000b0c0c17007631000076003000170b0c0d000017003276300033310000170017000000f0000000003200000000170000000b0c0d000000000000f076f3f1
000000000000000000000000000000000000000000000000000000000000000000000b0c0d00000000000000000e36110000000000000000000000000000000000000000f017000b0c0d000b0c0d0016000000000017000b0c2525250c0d001600160000000c2d7b002c0c000033f11700000000000000000076000402020205
00000000f3060000002c06f00000000000000000f0007600007600f1f0000000000000000000002426000000770f351100000000007b000000007b00000000000000000b0c17000000000000000000000000000b0c1700000000000000000000000000000000000000000000000b0c1700000000000000000401033537353511
__sfx__
010500000f16323063240632510300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001e73329751262002300023000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000013023180212302124000365003f5002300005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001b01300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001a4351c4351d4351c4351a4351843518435184351a4351a4351a435000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000423504235180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000003334033300f3241831518325243212432100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001022410220102241c2201c424104201042428420283261c3261c326103260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000033430f3431b3332732300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000c3350c333043030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303003030030300303
010a0000046560035410607006020060200602006050060504600106001060000600006000060000600000000c7050f7050c7050f705117050f7050c7050f705117050f7050c7050f7050c7050f7050e7050f705
011000001064504647106371063704622046220461504615007050370500705037050070503705007050370500705037050070503705007050370500705037050070503705007050370500705037050000000000
010800000105501055010550105501055010550105501055030550305506055080550a05508055080550a05500005000050000500005000050000500005000050000500005000050000500005000050000500005
0005000012555165551955520555275552a5552c5552a555005050050500505035050050500505005050050500505005050050505505005050050500505005050050500505005050350500505005050050500505
0110000018055180551a0551a0551c0551c0551d0551d0551a0551a0551d0551c0551a05518055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c1300c1000010500100001400c1000c1300c100001300c10000040001050c1050c10500105001050c1300c1000010500100001400c1000c1300c100001300c10000040001050c1050c105001050c102
010c00000e033000000e03300000000000000000000000000e0330e0330e0330c1000c1000010000100000000e033000000e033001000c1000c1000c100000010e0330e0330e033101050c1050c1051110511105
010c00000c1350c1350c13500000000000000000000000000c1350a1350c13500000000000000000000000000c1350c1350c13500000000000000000000000000c1350a1350c1350000000000000000000000000
010c00000c1350c1350c13500000000000000000000000000c1350a1350c13500000000000000000000000000c1350a1350c13500000000000000000000000000a1350e1350c1350000000000000000000000000
010c00000c1350c1350c13500000000000000000000000000c1350a1350c13500000000000000000000000000c1350a1350c13500000000000000000000000000a1350e1350c1350000000000000000000000000
010c00000c1350c1350e1350e1350c1050c1050d1350d1350e1350e13502135021350e1350e1351d1040d1050e1350e13510135101350c1050c10512135121350e1350e1350e1350e1350c1350c1351110511105
010c00000e1350e1350c1350c135000000000010135101350e1350e13500000000000e1050e10500000000000e1350e1350c1350c135000000000010135101350e1350e1350c1350c13500000000000000000000
010c00000c1350c1350e1350e1350c1050c1050f1350f1350c1350c13500135001350c1350c1351d1040d1050c1350c1350e1350e1350c1050c1050f1350f1350c1350c13500135001350a1350a1351110511105
010c00000c1350c1350e1350e1350c1000c1000c1350c1350a1350a13507135071350a1350a1350d1000d1000c1350c1350e1350e1350c1000c1000c1350c1350a1350713500135001350c1350c1351110511105
01060000033530f45310643106431065610655106351062610616140551405512055120550f0550f0550d0550d0550c0550c0550c0550c0550c0550c0550c0550c05000000020000000002000000000000000000
010400000155311553005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
00050000095550c5551855521555295551155515505185051a5051f50525505225051b50508505005050050500505005050050505505005050050500505005050050500505005050350500505005050050500505
001000001e0201b0201e0201d02020020220202502025020060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001e4251f425214251a4251a425214252342525425264252542526425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0f 42 43 44
00 0f 10 43 44
01 0f 10 11 44
00 0f 10 12 44
00 0f 10 16 44
00 0f 10 17 44
00 0f 10 16 44
02 0f 10 17 44
00 0f 10 15 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 0f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
