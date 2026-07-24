pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--     â‚¬ come on, animals â‚¬
--     â‚¬     by rousr     â‚¬
--     â‚¬                  â‚¬
--     â‚¬   @rabblrouser   â‚¬
--     â‚¬   @babyj3ans     â‚¬
--     â‚¬                  â‚¬
--     â‚¬  (c)2017 rousr   â‚¬
--     â‚¬  http://rou.sr   â‚¬
--

-------------------
---- todo
--------- 
--- general (0/4):
--
-- [ ] - tween falling on match
-- [ ] - points for matches
-- [ ] - timer
-- [ ] - grass fade in anim
--
--- system (2/2):
-- 
-- [x] - add state system
-- [x] - encapsulate current 'game' into game state
--
--- menu (2/2):
--
-- [x] - title fade in/out
-- [x] - standard/puzzle options
--
--- standard (0/1):
--
-- [ ] - refill empty slots after matches
--
--- puzzle (0/2):
--
-- [ ] - fix 'empty' block
-- [ ] - increasing animal count per level
--
---- bugs (0/2) ---
--
-- [ ] - matching 4+ in a row doesn't seem to work every single time
-- [ ] - occasional blank tile spot
--
-------------------

----
-- initialize data
----

---
-- constants
sprites={ 1, 2,    4, 5, 6, 7, 8, 9,10,
         17,18,19,20,21,22,23,24,25,26 }
animals  = { 8,9,10,11,12,13,2 }
altimals = { 9,10,11,12,13,2,8 }
impassable = 16
bonus = { 48, 49, 50 } 

---
-- game data
level = 1
score = 0
possible_matches = 0

---
-- grid data
grid = { }
cascades = { }
rows = 10
cols = 10
topy = flr((128 - 11*rows)*0.5) + 1

---
-- selected grid cell data
selected = { } 
selected.x = 0
selected.y = 0
selected.on = false;

----
-- fade functions
--- http://kometbomb.net/pico8/fadegen.html?new
----
local fadetable={
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
 {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
 {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
 {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
 {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
 {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
 {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
 {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
 {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
 {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
 {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
 {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
 {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
 {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
 {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,0)
  else
   pal(c,fadetable[c+1][flr(i+1)])
  end
 end
end

----
-- penner tweens
-- grabbed from: https://github.com/emmanueloga/easing/blob/master/lib/easing.lua
----

local function inquad(t, b, c, d)
  t = t / d
  return c*t^2+b
end

local function outquad(t, b, c, d)
  t=t/d
  return -c*t*(t-2)+b
end

local function inoutquad(t, b, c, d)
  t= t/d*2
  if (t<1) then return c/2*t^2+b
  else return -c/2*((t-1)*(t-3)-1)+b
  end
end

----
-- grid functions
----

-- get cell at pos
function grid_cell(x, y)
	if x < 0 or x >= cols or y < 0 or y >= rows then return nil end
	return grid[y*rows+x]
end

function grid_index(x, y)
	return y*rows+x
end

-- get pos of index
function grid_pos(index)
	local x = flr(index/rows)
	local y = flr(index%rows)
	return x, y
end

-------------------
-- gameplay functions
-------------------

---
-- returns a table of matches
-- along the row at y 
function checkmatches_row(y, check_possible)
	matches = { }
	
	local poss = 0
	local inarow = 0
	local prev = -1

	for x=0,cols do
		local cell = nil
		if x ~= cols then
			cell = grid_cell(x,y)
		end
		
		if cell ~= nil and prev ~= impassable and cell.n == prev then
			inarow += 1
		else
			if inarow >= 3 then
				matches[#matches+1] = { 
					startx=x-inarow,
					y=y,
					run=inarow,
					n=prev
				}
			elseif check_possible and inarow == 2 then
				local sx = x-inarow
				local lx = x-1

				local tc = grid_cell(sx, y-1)
				if tc ~= nil and tc.n == prev then poss += 1 end
				tc = grid_cell(sx, y+1)
				if tc ~= nil and tc.n == prev then poss += 1 end
				tc = grid_cell(lx, y+1)
				if tc ~= nil and tc.n == prev then poss += 1 end
				tc = grid_cell(lx, y+1)
				if tc ~= nil and tc.n == prev then poss += 1 end
			end
			
			inarow = 1
			if cell == nil or cell.is_cascading then prev=impassable
			else prev=cell.n end
		end
	end

	return matches, poss
end

---
-- returns a table of all 
-- matches col at x
function checkmatches_col(x, check_possible)
	matches = { }

	local poss = 0
	local inarow = 0
	local prev = -1

	for y=0,rows do
		local cell = nil
		if (y ~= rows) then 
			cell = grid_cell(x,y)
		end

		if cell ~= nil and prev ~= impassable and cell.n == prev then
			inarow += 1
		else 
			if inarow >= 3 then
				matches[#matches+1] = {
					starty=y-inarow,
					x=x,
					run=inarow,
					n=prev
				}
			elseif check_possible and inarow == 2 then
				local sy = y-inarow
				local ly = y-1

				local tc = grid_cell(x-1, sy)
				if tc ~= nil and tc.n == prev then poss += 1 end
				tc = grid_cell(x+1, sy)
				if tc ~= nil and tc.n == prev then poss += 1 end
				tc = grid_cell(x-1, ly)
				if tc ~= nil and tc.n == prev then poss += 1 end
				tc = grid_cell(x+1, ly)
				if tc ~= nil and tc.n == prev then poss += 1 end
			end

			inarow=1
			if cell == nil or cell.is_cascading then prev=impassable
			else prev=cell.n end
		end
	end

	return matches, poss
end

---
-- remove matches and add score
function score_matches(matches)
 	if #matches == 0 then
		return false
	end
	
	
	-- empty all the squares
	for i=1,#matches do
		local match=matches[i]
		
		if match.startx ~= nil then
			x = match.startx
			for c=1,match.run do
				local cell = grid_cell(x, match.y)
				cell.n = nil
				x += 1

				score += 1
				if c > 3 then score +=1 end
				if c > 4 then score +=1 end
			end
		elseif match.starty ~= nil then
			y = match.starty
			for c=1,match.run do
				local cell = grid_cell(match.x, y)
				cell.n = nil
				y += 1

				score += 1
				if c > 3 then score +=1 end
				if c > 4 then score +=1 end
			end
		end
	end
end 

---
-- cascade and fill in holes
function start_cascades()
	-- search bottom up
	for y=rows-1,0,-1 do
		for x=0,cols-1 do
			local cell = grid_cell(x, y)
			if cell.n == nil then
				-- found a missing one
				local placed = false
				local falling = 0
				-- now search up until we find a new piece, or the top
				for ny=y-1, 0, -1 do
					local ncell = grid_cell(x, ny)
					if ncell.n ~= nil  then
						if ncell.is_cascading then
							falling += 1
						else
							cell.n = ncell.n
							ncell.n = nil

							cell.is_cascading = true
							cell.dy = ncell.y
							cell.sy = ncell.y
							cell.startframe = frame

							cascades[#cascades+1] = cell
							placed = true
							break
						end
					end
				end

				if not placed then
					--if its the top, then its y = top - ((1 + #pieces) * pieceh)
					cell.n = impassable
					if currentmode == "marathon" then cell.n = sprites[flr(rnd(#sprites))+1] end
					local ny = cell.y
					ny = topy - 11 - (falling * 11)

					cell.dy = ny
					cell.sy = ny
					cell.startframe = frame

					cell.is_visible = true -- i think always
					cascades[#cascades+1] = cell
				end
			end
		end
	end
end

cascade_duration = 18
function update_cascades()
	local check = false
	newcasc = { }
	for cind=1,#cascades do
		local cell   = cascades[cind]
		local starty = cell.sy
		local endy   = cell.y
		local start  = cell.startframe
		
		local cy = endy - starty
		local t = (frame - start)/cascade_duration
		
		cell.dy = inquad(t,starty,cy,1) 

		if cell.dy >= endy then
			cell.dy = endy 
			cell.is_cascading = false
			check=true
		else
			--cell.is_visible = cell.dy >= topy
			newcasc[#newcasc+1]=cell
		end
	end
	
	cascades=newcasc

	if check then 
		stoke_camera();
		foundmatches = update_matches() 
		score_matches(foundmatches)
		start_cascades()
	end
end

function update_matches()
	local foundmatch = false
	local poss = 0
 	possible_matches = 0
	
	local tm = { }
	local mm = { }
	for r=0,rows-1 do
		mm, poss = checkmatches_row(r, true)
		for i=1,#mm do 
			match = mm[i] 
			tm[#tm+1]=match 
		end
		possible_matches += poss
	end

	for c=0,cols-1 do
		mm, poss = checkmatches_col(c, true)
		for i=1,#mm do 
			match = mm[i] 
			tm[#tm+1]=match 
		end
		possible_matches += poss
	end
  	
  	return tm
end

function update_selected(dx, dy)
	lx = selected.x; ly=selected.y
	lo = selected.on
	selected.x += dx;
	selected.y += dy;

	if selected.on then
		selected.x = max(0, selected.x)
		selected.y = max(0, selected.y)

		selected.x = min(cols - 1, selected.x)
		selected.y = min(rows - 1, selected.y)
	else 
		if (selected.x < 0) selected.x = cols-1
		if (selected.x == cols) selected.x = 0

		if (selected.y < 0) selected.y = rows-1
		if (selected.y == rows) selected.y = 0
	end

	local nx=selected.x;local ny=selected.y;
	local n = grid_cell(nx, ny)

	if n.n == impassable then
		selected.x = lx
		selected.y = ly
		selected.on = false
	else 
		if selected.on and 
			(lx ~= nx or ly ~= ny) then

		  	local o = grid_cell(lx, ly)
		  	n.n,o.n=o.n,n.n
		  	
		 	foundmatches = update_matches()
			
			if #foundmatches > 0 then
				score_matches(foundmatches)
				start_cascades()
			elseif currentmode == "marathon" then
		  		selected.on = false
		  		n.n,o.n=o.n,n.n
		  		selected.x = lx
		  		selected.y = ly
		 	end
		end

		if dx != 0 or dy != 0 then 
			selected.on = false
		elseif on then 
			selected.on = not selected.on
		end
	end

	-- play select sound
	if selected.on then
		if selected.on ~= lo then
			sfx(17)
		-- play pipper sound (but not both)
		elseif selected.x ~= lx or selected.y ~= ly then
			sfx(16)
		end
	end
end

function draw_selection()
	local s = selected
	local n = grid_cell(s.x,s.y)
	dx=11+s.x*11;dy=11+s.y*11
	dx-=1;dy-=1;
	sspr(0,0, 2, 2, dx,   dy)
	sspr(6,0, 2, 2, dx+8, dy)
	sspr(6,6, 2, 2, dx+8, dy+8)
	sspr(0,6, 2, 2, dx,   dy+8)
end

camera_shake = {
	start = 0,
	duration = 0,
	colors = 0,

	x = 0,
	y = 0,

	levels = {
		{
			maxlvl = 2,
			duration = 1.6,
			dx = { max = 9, count = 5, rnd = 6 },
			dy = { max = 6, count = 4, rnd = 4 },
			colors = false
		},
		{
			maxlvl = 3,
			duration = 2,
			dx = { max = 16, count = 8, rnd = 9 },
			dy = { max = 11, count = 8, rnd = 6 },
			colors = false
		},
		{
			maxlvl = 4,
			duration = 3,
			dx = { max = 22, count = 14, rnd = 8 },
			dy = { max = 16, count = 12, rnd = 5 },
			colors = false
		},
		{
			maxlvl = 6,
			duration = 3,
			dx = { max = 34, count = 20, rnd = 10 },
			dy = { max = 21, count = 15, rnd = 8 },
			colors = false
		},
		{
			maxlvl = 100,
			duration = 3.8,
			dx = { max = 55, count = 30, rnd = 15 },
			dy = { max = 30, count = 22, rnd = 12 },
			colors = true
		},
	},

	dx = {
		start = 0,
		change = 0,
		
		starttime = 0,
		duration = 0,
		max=0,
		count=0,
	},

	dy = {
		start = 0,
		change = 0,

		starttime = 0,
		duration = 0,
		max=0,
		count=0
	},
}

function stoke_camera(hard)
	sfx(18)
	camera_shake.start = frame
	maximum_overdrive = false
	for i=1,#camera_shake.levels do
		l = camera_shake.levels[i]
		if level <= l.maxlvl then
			break
		end
	end

	if l == nil then
		if not maximum_overdrive then
			camera_shake.duration = 2.0
			camera_shake.dx.count = 8 + flr(rnd(9))
			camera_shake.dy.count = 8 + flr(rnd(6))
			camera_shake.dx.max = 16
			camera_shake.dy.max = 11
			camera_shake.colors = false
		else
			-- maximum overdrive
			camera_shake.duration = 3.8
			camera_shake.dx.count = 30 + flr(rnd(15))
			camera_shake.dy.count = 22 + flr(rnd(12))
			camera_shake.dx.max   = 55
			camera_shake.dy.max   = 30
			camera_shake.colors = true
		end
	else
		camera_shake.duration = l.duration
		camera_shake.dx.count = l.dx.count + flr(rnd(l.dx.rnd))
		camera_shake.dy.count = l.dy.count + flr(rnd(l.dy.rnd))
		camera_shake.dx.max = l.dx.max
		camera_shake.dy.max = l.dy.max
		camera_shake.colors = l.colors
	end
end

function update_camerashake()
	if (camera_shake.duration > 0) then
		function do_shake(d)
			done = false
			if d.duration == 0 then
				done = true
			else 
				t = frame - d.starttime
				t = t * dt -- convert to seconds
			    t = t / d.duration -- convert to [0, 1]

			    done = t >= 1
			end

		   	if (done) then
		   		ct = frame - camera_shake.start
		   		ct = ct * dt
		   		ct = camera_shake.duration - ct

		   		d.duration = camera_shake.duration / d.count
		   		d.starttime = frame

		   		neg = true
		   		if d.change < 0 then neg = false end
		   		d.change = flr(rnd(d.max))
		   		if neg then d.change *= -1 end
		   		t = 0
		   	end
			
		    -- linear interp
		    return d.start + (d.change * t)
		end

		if camera_shake.colors and frame % 2 == 0 then 
			for c=1,15 do pal(c,0,1) end
			pal(0,flr(rnd(16)),1) 
		end

		camera_shake.x = do_shake(camera_shake.dx)
		camera_shake.y = do_shake(camera_shake.dy)
		camera(camera_shake.x, camera_shake.y)

		t = frame - camera_shake.start
		t = t * dt
		camera_shake.duration -= t
	else
		pal()
		camera()
	end
end

----
-- state management
function set_gamestate(s)
	if currentmode ~= nil then
		local mode = gamemodes[currentmode]
		if (mode.leave) mode:leave()
	end

	currentmode = s
	local mode = gamemodes[currentmode]
	if (mode.enter)	mode:enter()
end

-------------------
-- pico-8 built-in
-------------------

dt=1/30
frame=-1
function _update()
	frame = frame+1
	local m = gamemodes[currentmode]
	m:update()
end

function _draw()
	local m = gamemodes[currentmode]
	update_camerashake()
	m:draw()
end

------------------------------
-- game states
---------------

---------------
-- title / menu
---------------
function draw_scrollies()
	for i=0,13 do
		for j=0,13 do
			s = scrollies[i*14+j]
			n = s[1]
			x = s[2]
			y = s[3]
			spr(n,flr(x),flr(y))
			x += 0.4; y+=0.4;
			if x >= 130 then x-=140 end
			if y >= 130 then y-=140 end 
			s[2]=x;s[3]=y
		end
	end
end

---
-- title state
--
function title_enter()
	fadetime = 0 
	fadeduration=1.2
	
	scrollies = { }
	border=flr((128%15)*0.5)
	
	for i=0,13 do
	 for j=0,13 do
	 	n = sprites[flr(rnd(#sprites))+1]
	 	scrollies[i*14+j] = {n,(j-1)*10,(i-1)*10}
	 end
	end
end

function title_update()
	for i=0,5 do
		if btnp(i) then 
			set_gamestate("entermenu")
			break
		end
	end
end

function title_draw()
	cls()
	pal()
	if fadetime ~= nil then 
		fadetime += dt
		fade(16-flr(16*(fadetime/fadeduration)))
		if fadetime >= fadeduration then
			fadetime = nil
			pal()
		end
	end
	draw_scrollies()
	
	rectfill(0, 40, 128, 90, 0)
	if frame%30 > 15 then print("press any key", 38, 73, 7) end
	print("(c)2017 rousr", 38, 83, 5)
	
	sspr(8, 40, 55, 21, 36, 45)
end

---
-- enter menu state
--
function entermenu_enter()
 	menutime = 0
	menuduration = 2
	fadetime = 0
	fadeduration = 0.8
 	tc=animals[flr(rnd(#animals))+1]
end

function entermenu_update()
 	for i=0,5 do
 		if btnp(i) then
 			set_gamestate("menu")
 	 		break
 		end
 	end
end

function entermenu_draw()
 	cls()
	pal()
	draw_scrollies()
	t = min(menutime/menuduration, 1)
	y = inoutquad(t,90,20,1)
	
	rectfill(0, 40, 128, y, 0)
 	print("(c)2017 rousr", 38, y-7, 5)
	sspr(8, 40, 55, 21, 36, 45)
	
	if fadetime ~= nil then 
		fadetime += dt
		fade(16-flr(16*(fadetime/fadeduration)))
		if fadetime >= fadeduration then
			fadetime = nil
			pal()
		end
	end
 
 	if y>105 then 
  		y=72
	  	-- draw selector
	  	rectfill(0, y, 128, y+10, animals[tc])
	 	
	 	-- draw options
	 	print("puzzle", 54, 75, 7)
	 	print("marathon", 50, 86, 7)
	end
 
	menutime += dt
 	if menutime >= menuduration then
 		set_gamestate("menu")			
 	end
end

---
-- menu state 

function menu_enter() 
	tc=animals[1]
	selection=0 
end

function menu_update() 
	if frame%10 == 5 then
		n=#altimals
		c=altimals[1]
		for i=1,n-1 do
			altimals[i]=altimals[i+1]
		end
		altimals[n]=c
	end
	
 	if (btnp(2) or btnp(3)) then
 		if (selection == 1) then 
 			selection = 0
 		else 
 			selection = 1 
 		end
 		tc = altimals[1]

 		-- play menu nav sound
 		sfx(16) 
 	end
	
	if (btnp(4) or btnp(5)) then
		gs = "tut_puzzle"
		
		-- play menu select sound
		sfx(17)
		if selection == 1 then gs = "tut_mara" end
		set_gamestate(gs)
	end
end

function menu_draw() 
 	cls()
 	draw_scrollies()

	rectfill(0, 40, 128, 110, 0)
	print("(c)2017 rousr", 38, 103, 5)
	for i=1,#animals do
	 	pal(animals[i],altimals[i])
	end
	sspr(8, 40, 55, 21, 36, 45)
	pal()

 	y=72
 	if selection==1 then y=83 end
 	-- draw selector
 	rectfill(0, y, 128, y+10, tc)
 	-- draw options
	print("puzzle", 54, 75, 7)
	print("marathon", 50, 86, 7)
end


-------------------
-- tutorial functions
-------------------
tutorial_selection = "good" -- or "nah"

function tutorial_modal()
--modal window
	rectfill (5,85,120,22,5)  -- bg
	rectfill (5,15,58,30,5)   -- title tab

--dialog	
	print("how to play", 10, 20,7)
 	print("match sets of animals by", 15, 37, 6)
	print("pressing ” ƒ ‹ ‘ to", 17, 47, 6)
 	print("move and by pressing c", 19, 57, 6)
	print("to select an animal!", 23, 67, 6)

--button selector	
	if tutorial_selection == "nah" then
		rectfill(15,80,110,94,8)
		rectfill(20,82,45,92,7)
		print("nah.",27,85,5)
 		print("sounds good!",55,85,7)
		rect( 10, 80, 115, 30,8)	
		print("         ” ƒ ‹ ‘   ", 17, 47, 8)
	else-- "good"
		rectfill(15,80,110,94,10)
  		rectfill(50,82,105,92,7)
		print("nah.",27,85,5)	
 		print("sounds good!",55,85,5)
		rect( 10, 80, 115, 30,10)
		print("         ” ƒ ‹ ‘   ", 17, 47, 10)
 	end
end

---
-- tut marathon
function tut_enter()
	tutorial_selection = "good"
end

function tut_update()
	if (btnp(4) or btnp(5)) then
		local nextmode = "marathon"
		if (currentmode ~= "tut_mara") nextmode = "puzzle"
		if tutorial_selection == "good" then set_gamestate(nextmode) end
		if tutorial_selection == "nah" then set_gamestate("title") end 
	end
		
	if (btnp(0) or btnp(1)) then
		if tutorial_selection == "nah" then
			tutorial_selection = "good"
		else
			tutorial_selection = "nah"
		end
	end
end

function tut_draw()
	cls(0) 
	-- background
 	for x = 0,120,8 do
 		for y = 0,120,8 do
 			spr(52,x,y)
 		end
 	end
	tutorial_modal()
end

---------------
-- game specific
---------------
function game_enter()
	score = 0
	music(0)
	sx = flr((128 - 11*cols)*0.5) + 1
	sy = flr((128 - 11*rows)*0.5) + 1
	for y=0,rows do
		for x=0,cols do
		 local n = flr(rnd(#sprites)+1)
			local index= grid_index(x, y)
			dx = sx+x*11;dy = sy+y*11
			grid[index] = { 
				n = sprites[n],
				x = dx,
				y = dy,
				dx = dx,
				dy = dy,
				sx = dx,
				sy = dy,
				is_cascading = false,
				is_visible = true
			}
			
			local cell = grid[index]
		end
	end
		
	goagain = true
	while(goagain) do
		matches = update_matches()
		goagain = #matches > 0
		for i=1,#matches do
			local match=matches[i]
			local c = nil 			
			if match.startx ~= nil then
				y = match.y
				x = match.startx
				x += flr(rnd(match.run))
		  	else 
				x = match.x
				y = match.starty
				y += flr(rnd(match.run))
		  	end
	 		c = grid_cell(x, y)
			os = c.n
	 		while(c.n == os) do c.n = sprites[flr(rnd(#sprites))+1] end
		end
	end
end

function game_draw()
 	cls(3) --3

	-- background
 	for x = 0,120,8 do
 		for y = 0,120,8 do
 			spr(51,x,y) --51
 		end
 	end
 
	color(0)
	sx = flr((128 - 11*cols)*0.5)
	sy = flr((128 - 11*rows)*0.5)
	rectfill(sx, sy, sx+11*cols, sy+11*rows)
	sx += 1;
	sy += 1;

	for y=0,rows-1 do
	 	for x=0,cols-1 do
		 	local cell = grid_cell(x,y)
		 	n = cell.n
			dx = cell.dx
			dy = cell.dy
			if cell.is_visible == true then
			 	if selected.on and
			    	x == selected.x and
			    	y == selected.y then
			  		color(5)
			 		rectfill(dx, dy, dx+10, dy+10)   
				end
			 	spr(n, dx+1,dy+1)
	 		end
	 	end
	end
	
	draw_selection()

	color(3)
	rectfill(0, 0, 128, 7)
	for x=0,128,8 do
		spr(51, x, 0)
	end
end

function game_update()
	x=0;y=0;on=false
	if(btnp(0)) x -= 1;
	if(btnp(1)) x += 1;
	if(btnp(2)) y -= 1;
	if(btnp(3)) y += 1;
	--if #cascades == 0 then
		if(btnp(4)) on = true; 
	--end

	update_selected(x, y)
	update_cascades()

	if score >= maxscore then
		level += 1

		if currentmode == "puzzle" then
			local m = gamemodes[currentmode]
			m:enter()
		elseif currentmode == "marathon" then
			maxscore += level * 20
			marathon_poolanimals(animalperlevel)
		end
	end
end

function gameover_draw()
	local win = true
	if currentmode == "puzzle" and level < 8 then
		win = false
	end

	color(0)
	sx = flr((128 - 11*cols)*0.5)
	sy = flr((128 - 11*rows)*0.5)
	rectfill(sx, sy, sx+11*cols, sy+11*rows)
	
	
	local dx = 36
	-- draw "you"
	sspr(0, 64, 27, 12, dx, 45)
	dx += 28
		
	if win then
		sspr(28, 64, 28, 12, dx, 45)
		dx += 28
	else
		sspr(0, 80, 36, 12, dx, 45)
		dx += 37
	end

	sspr(55, 64, 3, 12, dx, 45)

	color(7)
	print("score: " .. score, 45, 61)
	print("press — or Ž", 38, 67)
end

---------------
-- marathon
---------------
function marathon_poolanimals(num)
	for i=1,num do
		if #spritelist > 0 then
			n = flr(rnd(#spritelist))+1
			sprites[#sprites+1] = spritelist[n]
			
			newspritelist = { }
			for i=1,#spritelist do
				if i ~= n then
					newspritelist[#newspritelist+1]=spritelist[i]
				end
			end

			spritelist = newspritelist
		else
			break
		end
	end
end

function marathon_leave()
	sprites = originallist
end

function marathon_enter()
	maxscore = level * 20
	animalperlevel = 3

	originallist = sprites
	spritelist = { }
	sprites = { }

	for i=1,#originallist do
		spritelist[i]=originallist[i]
	end

	marathon_poolanimals(4)
 	game_enter() 
end

function marathon_draw()  
	if game_over then 
		game_draw()

		gameover_draw()
	else 
		game_draw()

		local scoretext = "" .. score

		color(3)
		rectfill(110, 121, 119, 128)

		color(6)
		print("matches: " .. possible_matches, 2, 122)
		print(scoretext, 116-(3*#scoretext), 122)

		color(7)
		print(level, 123, 121)

		color(0)
		rectfill(121, 119-(8*#sprites), 126, 119)
		x = 120
		y = 119-8
		for i=1,#sprites do
			spr(sprites[i], x, y)
			y -= 8
		end
	end
end

function marathon_update() 
	if not game_over then
		game_update()

		if possible_matches == 0 and #cascades == 0 then
			game_over = true
		end
	else
		for i=4, 5, 1 do
			if btnp(i) then
				game_over = false;
				music(0, -1)
				set_gamestate("title")
			end
		end
	end
end

---------------
-- puzzle
---------------
function puzzle_enter()
	maxscore = level * 20
	game_enter() 
end

function puzzle_draw()  
	game_draw() 
	color(3)
	rectfill(123, 9, 125, 118)
	color(5)
	rectfill(124, 10, 124, 117)
	fill = flr((score/maxscore)*(117-10))
	color(7)
	rectfill(124, 117-fill, 124, 117)
	color(7)
	print(level, 123, 121)
end

function puzzle_update()
	game_update()
end

------------------------------
-- gamestates
---------------
gamemodes = {
 	title = {
		enter  = title_enter,
		draw   = title_draw,
		update = title_update,
 	},
	
	entermenu = {
 		enter  = entermenu_enter,
 		draw   = entermenu_draw,
 		update = entermenu_update,
 	},
 	
 	menu = {
  		enter  = menu_enter,
	  	draw   = menu_draw,
  		update = menu_update,
 	},
 
 	tut_mara = {
  		enter  = tut_enter,
  		update = tut_update,
  		draw   = tut_draw
 	},
	
	marathon = {
		enter  = marathon_enter,
		update = marathon_update,
	 	draw   = marathon_draw,
	 	leave  = marathon_leave
	 },
 
	tut_puzzle = {
		enter  = tut_enter,
		update = tut_update,
		draw   = tut_draw
	},
	puzzle = {
		enter  = puzzle_enter,
		update = puzzle_update,
		draw   = puzzle_draw,
	},
}

set_gamestate("title")
__gfx__
770000770499994006666660079009700770077004f44f4007000070044004400d0000d005555550044004400000000000000000000000000000000000000000
7000000749999994666666667699996707700770477447747e7007e70f4444f00dddddd05775577504f44f400000000000000000000000000000000000000000
0000000099099099777667779979979907700770f704407f7ee77ee744444444dd7dd7dd57099075477447740000000000000000000000000000000000000000
0000000099999999505555059909909907777770577447757777777744044044dd0dd0dd57799775470440740000000000000000000000000000000000000000
0000000099999999555005559799997977e77e770f4994507307703744444444dddddddd5559a555ff4444ff0000000000000000000000000000000000000000
0000000079999997555555557990099777e77e774459a5446777777644f00f446666666655555555f44e844f0000000000000000000000000000000000000000
7000000777955977057ee750997997997775577745f94f540678876044655644d7e88e7d555775554f4444f40000000000000000000000000000000000000000
77000077067007600005500009677690077777700ffffff000677600044ff4400dddddd00577775004ffff400000000000000000000000000000000000000000
888888880ee00ee00490094007777770770000770bbbbbb005000050076006700b3003300033b300000000000000000000000000000000000000000000000000
888778880eeeeee049944994777777777f7557f7b77cc77b4a9009a476655667375335730b333b30001ccc000000000000000000000000000000000000000000
88788788e77ee77e999999997707707707777770b70cc07b499999946005500633b3b333030330b007ccc1c00000000000000000000000000000000000000000
87878878e70ee07e990990997779977767077076377cc77305a99950507557053333b3b303b333b00cccc7c10000000000000000000000000000000000000000
87887878eeeeeeee990990996779977656777767bbc99cbb099a99906006600638787873999aaaaac0c00c0c0000000000000000000000000000000000000000
88788788ee8888ee799999977677e76777f55f75bc39a3cb09090aa055566555388888839999999a00c000c00000000000000000000000000000000000000000
88877888ee5885ee779559777778877777500577b3b9333b00a44a0056600665378787830a5005a00cc00c000000000000000000000000000000000000000000
888888880eeeeee006700760067877600677776003333330000a90000558e5500333333000aaaa000c0000c00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbb0000bbbb0000bbbb00b000000b0000000600000000b000000b3bbbbbbb0000000000000000000000000000000000000000000000000000000000000000
0888888008888880088888800b0000b000000060000b000b0b0000b033b33b330000000000000000000000000000000000000000000000000000000000000000
a877778ea877778ea877778e00b00b00000006000000000000b00b00bb3bbbbb0000000000000000000000000000000000000000000000000000000000000000
a878888ea878878ea878878e0000b000000060000b000b000000b0003b3333b30000000000000000000000000000000000000000000000000000000000000000
a878888ea878878ea877778e000b00000006000000000000000b00003b3333b30000000000000000000000000000000000000000000000000000000000000000
a877778ea877778ea878878e00b00b0000600000000b000b00b00b003bbbb3bb0000000000000000000000000000000000000000000000000000000000000000
0888888008888880088888800b0000b006000000000000000b0000b033b33b330000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc0000cccc00b000000b600000000b000b00b000000bb3bbbbb30000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777770077777700770077007777770000777777007777770000000000000000000000000000000000000000000000000000000000000000000000
00000000007777770077777700777777007777770000777777007777770000000000000000000000000000000000000000000000000000000000000000000000
00000000007700000077007700777777007700000000770077007700770000000000000000000000000000000000000000000000000000000000000000000000
00000000007700000077007700770077007777700000770077007700770000000000000000000000000000000000000000000000000000000000000000000000
00000000007700000077007700770077007777700000770077007700770000000000000000000000000000000000000000000000000000000000000000000000
00000000007700000077007700770077007700000000770077007700770000000000000000000000000000000000000000000000000000000000000000000000
00000000007777770077777700770077007777770000777777007700770700000000000000000000000000000000000000000000000000000000000000000000
00000000007777770077777700770077007777770000777777007700770770000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888899999999aaaaaaaabbb00bbbccccccccddd00000222222220000000000000000000000000000000000000000000000000000000000000000
000000008888888899999999aaaaaaaabbbbbbbbccccccccddd00000222222220000000000000000000000000000000000000000000000000000000000000000
000000008888888899999999aaaaaaaabbbbbbbbccccccccddd00000222000000000000000000000000000000000000000000000000000000000000000000000
00000000888008889990099900aaaa00bbbbbbbbccc00cccddd00000222000000000000000000000000000000000000000000000000000000000000000000000
00000000888008889990099900aaaa00bbb00bbbccc00cccddd00000222222220000000000000000000000000000000000000000000000000000000000000000
00000000888888889990099900aaaa00bbb00bbbccccccccddd00000222222220000000000000000000000000000000000000000000000000000000000000000
00000000888888889990099900aaaa00bbb00bbbccccccccddd00000222222220000000000000000000000000000000000000000000000000000000000000000
00000000888008889990099900aaaa00bbb00bbbccc00cccddd00000000002220000000000000000000000000000000000000000000000000000000000000000
000000008880088899900999aaaaaaaabbb00bbbccc00cccdddddddd000002220000000000000000000000000000000000000000000000000000000000000000
000000008880088899900999aaaaaaaabbb00bbbccc00cccdddddddd222222220000000000000000000000000000000000000000000000000000000000000000
000000008880088899900999aaaaaaaabbb00bbbccc00cccdddddddd222222220000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666660666666660666666660bbbbbbbbb0bbbbbbb0bbbbbbbb06666000000000000000000000000000000000000000000000000000000000000000000000
6777677760677777760677777760b777b777b0b77777b0b777777b06776000000000000000000000000000000000000000000000000000000000000000000000
6707670760670000760670770760b707b707b0b70007b0b700007b06776000000000000000000000000000000000000000000000000000000000000000000000
6707670760670770760670770760b707b707b0b77077b0b707707b06776000000000000000000000000000000000000000000000000000000000000000000000
6707770760670770760670770760b707b707b0bb707bb0b707707b06776000000000000000000000000000000000000000000000000000000000000000000000
6700000760670770760670770760b707b707b0bb707bb0b707707b06776000000000000000000000000000000000000000000000000000000000000000000000
6777077760670770760670770760b707b707b0bb707bb0b707707b06666000000000000000000000000000000000000000000000000000000000000000000000
55570755505707707505707707503707770730337073303707707300000000000000000000000000000000000000000000000000000000000000000000000000
55570755505707707505707707503707070730377077303707707305555000000000000000000000000000000000000000000000000000000000000000000000
55570755505700007505700007503700700730370007303707707305775000000000000000000000000000000000000000000000000000000000000000000000
55577755505777777505777777503777377730377777303777777305775000000000000000000000000000000000000000000000000000000000000000000000
55555555505555555505555555503333333330333333303333333305555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee0eeeeeeee0eeeeeeee0eeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e777eeeee0e777777e0e777777e0e777777e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e707eeeee0e700007e0e700007e0e700007e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e707eeeee0e707707e0e707777e0e707777e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e707eeeee0e707707e0e707777e0e707777e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e707eeeee0e707707e0e700007e0e700007e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e707eeeee0e707707e0e777707e0e707777e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87078888808707707808777707808707777800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87077777808707707808777707808707777800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87000007808700007808700007808700007800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87777777808777777808777777808777777800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888808888888808888888808888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010d00001d0101d01021300213001c0101c01021300213001a0101a01021300213001c0101c0102130021300180101801013000130001301013010130001300018010180101f3001f30013010130101f3001f300
010d0000150101501021505215051801018010245052450513010130101c5051c505100101001010000100001101011010110001f50518010180101d5051c5051d0101d0101f505215051c0101c0102350524505
010d00001c0101c0101c0001d0001d0101d0101a0001a0001a0101a0101a000130001301013010130001a000180101801013000130001301013010130001300018010180101f3001f30013010130101f3001f300
010d00001c0101c0101c0001d0001d0101d0101a0001a0001a0101a0102630523305130101301023305293051f0101f01018000180001d0101d01018000180001c0101c01018000180001a0101a0101800018000
010d00000c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c1100c11013110131101311013110131101311013110131101311013110131101311013110131101311013110
010d00001511015110151101511015110151101511015110151101511015110151101511015110151101511018110181101811018110181101811018110181101811018110181101811018110181101811018110
010d00001d01021000130101a0001d01021000130101c0051d01021000130101a0001d01021000130101c0051d01021000130101a0001d01021000130101c0051d01021000130101a0001d01021000130101c005
010d00001c0101300013010130001c0101300013010130001c0101300013010130001c0101c00013010000001801021000130101a0001801021000130101c0051801021000130101a0001801021000130101c005
010d00001c0101c0001c0101c0001c010130001c010130001a010000001a010130001a010000001a010000001f0001f00021300213001d0001d00021300213001c0001c00021300213001a0001a0002130021300
010d0000181101110018110111001811011100181101110013110111001311011100131101110013110111001111010100111101510011110151001111015100101101510010110151001011015100101101a100
010d00001311013110131101311013110131101311013110131101311013110131101311013110131101311013110131101311013110131101311013110131101311013110131101311013110131101311013110
010d00001c1101110018110111001c1101110018110111001c1101110018110111001c1101110018110111001c1101110018110111001c1101110018110111001c1101110018110111001c110111001811011100
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001801021000130101a0001801021000130101c0051801021000130101a0001801021000130101c0051d01021000130101a0001d01021000130101c0051d01021000130101a0001d01021000130101c005
011000001d01021000130101a0001d01021000130101c0051d01021000130101a0001d01021000130101c0051c01021000130101a0001c01021000130101c0051c01021000130101a0001c01021000130101c005
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002d050000000000000000000000000000000000000000000000000000000000000
010400001355013550175501755000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010400001755017550135501355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0107000015073150730e0730e07310003100030c0030c0030500305003050030500305003050030e0030c0030c0030e00310003110030c0030e00310003110030e0031000311003130030e003100031100313003
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 04 43 44
00 01 05 43 44
00 02 04 43 44
00 01 05 43 44
00 00 04 09 44
00 01 05 09 44
00 02 04 09 0b
00 01 05 09 0b
00 02 04 09 0b
00 01 05 09 0b
00 02 04 09 44
00 01 05 09 44
02 02 09 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
