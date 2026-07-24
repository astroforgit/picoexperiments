pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- bob's action racing
-- by bob fungus / hackefuffel
-- Version 1.0

-- ##############################################
-- CONSTANTS
-- ##############################################

LINES = 9
CELLS_PER_LINE = 10
LINES_PER_THEME = 150
THEME_TRANSPARENT = { 14, 14, 14, 13, 14 }
THEME_FANCOLOR = { 7, 7, 7, 7, 7}
NUM_THEMES = 5
THEMES = { 0, 1, 4, 3, 2 }
INIT_SPEED = 20
MAX_SPEED = 200
INIT_SPEED = 40
CAR_MIN_Y = 128 - 10
CAR_MAX_Y = CAR_MIN_Y - 20

LAST_LINE = NUM_THEMES * LINES_PER_THEME

-- ##############################################
-- GLOBALS
-- ##############################################

g_god = false

-- game info
g_game = {}
-- 0 - loading screen
-- 1 - start screen
-- 2 - game
-- 3 - game over
-- 4 - highscore
g_game.state = 0

-- info like position for the car
g_car = {}

-- level lines containing data about the visuals and obstacles
g_lines = {}

-- loading screen data
g_loading = {}
g_loading.frames = 0
g_loading.duration = 3

-- game logic 
g_logic = {}
g_logic.lasttime = 0

-- start screen data
g_start = {}

-- highscore data
g_highscore = {}
g_highscore.filevalid = false

-- input
g_input = {}
g_input.btn = { false, false, false, false, false, false }
g_input.btnp = { false, false, false, false, false, false }

-- ##############################################
-- MATH
-- ##############################################
g_pow2 = 
{
 { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
 { 0, 0, 0, 0, 0, 0, 0, 0, 0, 2 },
 { 0, 0, 0, 0, 0, 0, 0, 0, 0, 4 },
 { 0, 0, 0, 0, 0, 0, 0, 0, 0, 8 },
 { 0, 0, 0, 0, 0, 0, 0, 0, 1, 6 },
 { 0, 0, 0, 0, 0, 0, 0, 0, 3, 2 },
 { 0, 0, 0, 0, 0, 0, 0, 0, 6, 4 },
 { 0, 0, 0, 0, 0, 0, 0, 1, 2, 8 },
 { 0, 0, 0, 0, 0, 0, 0, 2, 5, 6 },
 { 0, 0, 0, 0, 0, 0, 0, 5, 1, 2 },
 { 0, 0, 0, 0, 0, 0, 1, 0, 2, 4 },
 { 0, 0, 0, 0, 0, 0, 2, 0, 4, 8 },
 { 0, 0, 0, 0, 0, 0, 4, 0, 9, 6 },
 { 0, 0, 0, 0, 0, 0, 8, 1, 9, 2 },
 { 0, 0, 0, 0, 0, 1, 6, 3, 8, 4 },
 { 0, 0, 0, 0, 0, 3, 2, 7, 6, 8 },
 { 0, 0, 0, 0, 0, 6, 5, 5, 3, 6 },
 { 0, 0, 0, 0, 1, 3, 1, 0, 7, 2 },
 { 0, 0, 0, 0, 2, 6, 2, 1, 4, 4 },
 { 0, 0, 0, 0, 5, 2, 4, 2, 8, 8 },
 { 0, 0, 0, 1, 0, 4, 8, 5, 7, 6 },
 { 0, 0, 0, 2, 0, 9, 7, 1, 5, 2 },
 { 0, 0, 0, 4, 1, 9, 4, 3, 0, 4 },
 { 0, 0, 0, 8, 3, 8, 8, 6, 0, 8 },
 { 0, 0, 1, 6, 7, 7, 7, 2, 1, 6 },
 { 0, 0, 3, 3, 5, 5, 4, 4, 3, 2 },
 { 0, 0, 6, 7, 1, 0, 8, 8, 6, 4 },
 { 0, 1, 3, 4, 2, 1, 7, 7, 2, 8 },
 { 0, 2, 6, 8, 4, 3, 5, 4, 5, 6 },
 { 0, 5, 3, 6, 8, 7, 0, 8, 1, 2 },
 { 1, 0, 7, 3, 7, 4, 1, 8, 2, 4 }
}

-----------------------------
-- init a large int
-----------------------------
function i32_init()
	val = {}
	val.low = 0
	val.high = 0
	return val
end

-----------------------------
-- init a large int
-----------------------------
function i32_set(low, high)
	val = {}
	val.low = low
	val.high = high
	return val
end

-----------------------------
-- add int to large int
-----------------------------
function i32_add16(a, b)
	res = i32_init()
	res.high = a.high
	res.low = a.low + b
	if( res.low < 0) then
		res.high += 1
		res.low = res.low + 32768
	end
	return res
end

-----------------------------
-- add two large ints
-----------------------------
function i32_add32(a, b)
	res = i32_init()
	res.low = a.low + b.low
	if( res.low < 0) then
		res.high += 1
		res.low = res.low + 32768
	end
	res.high += a.high + b.high
	return res
end

-----------------------------
-- compare two large ints
-- a < b -> -1
-- a == b -> 0
-- a > b -> 1
-----------------------------
function i32_compare(a, b)
	if( a.high < b.high ) then
		return -1
	elseif( a.high > b.high ) then
		return 1
	else
		if( a.low < b.low ) then
			return -1
		elseif( a.low > b.low ) then
			return 1
		else
			return 0
		end
	end
end

-----------------------------
-- large int to string
-----------------------------
function i32_tostr(a, b)
	
	digits = {}
	for i = 1, 10 do
		digits[i] = 0
	end
	
	-- low
	for i = 0, 14 do
		if( band( a.low, shl( 1, i ) ) > 0) then
			p = g_pow2[i + 1]
			carry = 0
			for j = 10, 1, -1 do
				digits[j] += p[j] + carry
				carry = 0
				if(digits[j] >= 10) then
					carry = 1
					digits[j] -= 10
				end
			end
		end
	end
	
	-- high
	for i = 0, 14 do
		if( band( a.high, shl( 1, i ) ) > 0) then
			p = g_pow2[i + 16]
			carry = 0
			for j = 10, 1, -1 do
				digits[j] += p[j] + carry
				carry = 0
				if(digits[j] >= 10) then
					carry = 1
					digits[j] -= 10
				end
			end
		end
	end
	
	first = 1
	if(b == false) then
		for i = 10, 1, -1 do
			if(digits[i] > 0) then
				first = i
			end
		end
	end
	
	s = ""
	
	for i = first, 10 do
		s = s .. tostr(digits[i])
	end
	return s
end

-- ##############################################
-- HELPERS
-- ##############################################

-------------------------------
-- print a string centered
-------------------------------
function printcenter(y, s, c)
	x = 64 - ((#s / 2) * 4)
	print(s, x, y, c)
end

-- ##############################################
-- HIGHSCORE
-- ##############################################

-----------------------------
-- load highscore
-- load top 10 scores from
-- file.
-----------------------------
function highscoreload()
	if(cartdata("bar")) then
		g_highscore.filevalid = true
		for i = 1, 10 do
			g_highscore[i] = i32_set(dget(2 * (i - 1)), dget(2 * (i - 1) + 1))
		end
	else		
		for i = 1, 10 do
			g_highscore[i] = i32_init()
		end
		highscoresave()
	end
end

-----------------------------
-- save highscore
-- store top 10 scores to
-- file
-----------------------------
function highscoresave()
	for i = 1, 10 do
		dset(2 * (i - 1), g_highscore[i].low)
		dset(2 * (i - 1) + 1, g_highscore[i].high)
	end
end

-----------------------------
-- enter highscore
-- returns pos (1..10) or
-- -1 if not in list
-----------------------------
function highscoreset(score)
	for i = 1, 10 do
		if( i32_compare(score, g_highscore[i]) > 0 ) then
		
			for j = 9, i, -1 do
				g_highscore[j + 1] = g_highscore[j]
			end
		
			g_highscore[i] = score
			
			highscoresave()
			
			return i
		end
	end
	
	return -1
end

-- ##############################################
-- INPUT
-- ##############################################

-----------------------------
-- check for input
-----------------------------
function input()

	for i = 0, 6 do
		g_input.btnp[i + 1] = btn(i) and not g_input.btn[i + 1]
		g_input.btn[i + 1] = btn(i)
	end
end


-----------------------------
-- check for player input
-----------------------------
function playerinput()
	-- no steering
	if not g_input.btn[1] and not g_input.btn[2] then
		g_car.steer = 0
	-- left
	elseif(g_input.btnp[1]) then
		g_car.steer = -1
		sfx(7, 2, 0, 17)
	-- right
	elseif(g_input.btnp[2]) then
		g_car.steer = 1
		sfx(7, 2, 0, 17)
	end
end

-- ##############################################
-- LINE HANDLING
-- ##############################################

-------------------------------
-- init a single line
-------------------------------
function initline(index, yoffset, empty)
	
	themeidx = min(NUM_THEMES, 1 + flr((g_lines.linenumber / LINES_PER_THEME)))
	
	g_lines[index] = {}
	g_lines[index].theme = THEMES[themeidx]
	-- g_lines[index].theme = 4
	
	g_lines[index].yoffset = yoffset
	g_lines[index].cells = {}
	
	-- clc middle cell
	middle = flr(g_lines.center / 16) + 2
	g_lines[index].xoffset = -24 + (g_lines.center % 16)

	-- move center
	g_lines.center += g_lines.move
	g_lines.center = mid(g_lines.center, 24, 128 - 24)
	g_lines.moves -= 1
	if(g_lines.moves < 1) then
		g_lines.move = flr(rnd(5)) - 2
		g_lines.moves = flr(rnd(10)) + 4
	end
	

	-- fence
	g_lines.nextfence -= 1
	fence = (g_lines.nextfence < 1) and (g_lines.linenumber < (LAST_LINE - 10))
	if(fence) then
		g_lines.nextfence = flr(rnd(10)) + 5
		fenceside = flr(rnd(2))
		fencedist = 1 + flr(rnd(3))
	-- last line is all fence!
	elseif(g_lines.linenumber == (LAST_LINE)) then
		fence = true
		fenceside = 2
	end
	


	-- fill cells
	for i = 1, CELLS_PER_LINE do
		g_lines[index].cells[i] = {}
		g_lines[index].cells[i].background = 0
		g_lines[index].cells[i].obstacle = 0
		dist = i - middle
		
		if(g_lines.linenumber < (LAST_LINE)) then
			-- street
			-- middle
			if( dist == 0) then
				g_lines[index].cells[i].background = 2
			-- left
			elseif( dist == -1 ) then
				g_lines[index].cells[i].background = 1
			-- right
			elseif( dist == 1 ) then
				g_lines[index].cells[i].background = 3
			end
		end
		
		-- fence
		if(fence) then
			if(fenceside == 0) and (dist < -fencedist) then
				g_lines[index].cells[i].obstacle = 1
			elseif(fenceside == 1) and (dist > fencedist) then
				g_lines[index].cells[i].obstacle = 1
			elseif(fenceside == 2) then
				g_lines[index].cells[i].obstacle = 1
			end
		end
	end

	-- obstacles
	if(not fence) then
	
		-- last few lines get special treatment
		lastrows = g_lines.linenumber > (LAST_LINE - 6)
	
		-- random count. the lower counts have a higher probability!
		-- 0: 2/5
		-- 1: 2/5
		-- 2: 1/5
		if(lastrows) then
			numobst = flr(rnd(3)) + 3
		else
			numobst = flr(rnd(2))
			if(numobst == 0) then
				numobst = flr(rnd(3))
			else
				numobst = flr(rnd(2))
			end
		end
		
		-- place 'em
		while(numobst > 0) do
			
			-- rand pos
			pos = flr(rnd(CELLS_PER_LINE)) + 1
			
			-- check position, foreground must be empty, 
			-- otherwise it gets crouded in da house
			if(g_lines[index].cells[pos].obstacle == 0) then
				
				-- if the destination is a street, we use da oil, man.
				-- except for the last rows. Fans everywhere!
				if(g_lines[index].cells[pos].background != 0 and not lastrows) then
					-- c'mon, be fair. Place no more than one oil every few g_lines
					if(g_lines.lastoil > 10) then
						g_lines[index].cells[pos].obstacle = 2
						g_lines.lastoil = 0
					end
				
				-- otherwise randomize us a nice sprity baby.
				-- start with the mountain. fence and oil are not used now!
				-- in case of the last rows it's fans over fans!
				else
					-- 1/3 Fan
					if( lastrows or (flr(rnd(3)) == 0) ) then					
						g_lines[index].cells[pos].obstacle = 8
					-- 2/3 obst
					else
						g_lines[index].cells[pos].obstacle = 3 + flr(rnd(5))
					end
				end
				
				numobst -= 1
			end
		end
		
	end
	
	-- some stats
	g_lines.linenumber += 1
	g_lines.lastoil += 1
end

-------------------------------
-- init all g_lines initially
-------------------------------
function initlines()
	yoffset = 128 - 16
	for i = 1, LINES do
		initline(i, yoffset, true)
		yoffset -= 16
	end
end

-- ##############################################
-- COLLISION
-- ##############################################

-------------------------------
-- check if two bounding boxes
-- overlap in y
-------------------------------
function overlapy(a, b)
	return (b.top <= a.bottom) and (b.bottom >= a.top)
end

-------------------------------
-- check if two bounding boxes
-- overlap
-------------------------------
function overlap(a, b)
	return (b.top <= a.bottom) and (b.bottom >= a.top)
		and (b.left <= a.right) and (b.right >= a.left)
end

-------------------------------
-- handle collision
-------------------------------
function handlecollision(i, j)
	
	-- obstacle type
	otype = g_lines[i].cells[j].obstacle
	
	-- nothing
	if(otype == 0) then
	
	-- dying fan
	elseif(otype == 9) then
	
	-- fan
	elseif(otype == 8) then
		g_lines[i].cells[j].obstacle = 9
		g_lines[i].cells[j].start = time()
		
		if( g_game.state == 2 ) then
		
			-- don't have a mul yet...
			if(not g_god) then
				for k = 1,10 do
					g_logic.score = i32_add32(g_logic.score, g_logic.distance)
				end
			end
			
			g_logic.speed *= 0.9
			if(g_logic.speed < INIT_SPEED) then
				g_logic.speed = INIT_SPEED
			end
			
		end
		
		sfx(2, 1, 0, 32)
		
	-- oil
	elseif(otype == 2) and not g_god then
		if( g_game.state == 2 ) then
			g_game.state = 3
			g_game.time = time()
			g_car.state = 2
			sfx(5, 0)
		end
	-- hard obstacle
	elseif not g_god then
		if( g_game.state == 2 ) then
			g_game.state = 3
			g_game.time = time()
		end
		if(g_car.state != 1) then
			g_car.animation = 1
			g_car.state = 1
			sfx(1, 0, 0, 4)
		end
	end
end

-------------------------------
-- get bbox for obstacle
-- the bounding boxes vary for
-- different obstacle types
-------------------------------
function getbbox(cellbox, xoffset, otype)
	obox = {}
	obox.bottom = cellbox.bottom
	
	-- fan
	if(otype == 8) then
		obox.top = cellbox.top
		obox.left = xoffset
		obox.right = xoffset + 16
	-- oil
	elseif(otype == 2) then
		obox.top = cellbox.bottom - 12
		obox.left = xoffset + 2
		obox.right = xoffset + 12
	-- other
	else
		obox.top = cellbox.bottom - 10
		obox.left = xoffset + 2
		obox.right = xoffset + 12
	end
	
	return obox
end

-------------------------------
-- collision detection
-------------------------------
function collisiontest()


	-- car's bounding box
	carbox = {}
	carbox.left = g_car.x - 7
	carbox.right = g_car.x + 7
	carbox.top = g_car.y - 5
	carbox.bottom = g_car.y + 7

	-- check each line
	for i = 1, LINES do
		
		-- cell's bounding box
		linebox = {}
		linebox.top = g_lines[i].yoffset
		linebox.bottom = linebox.top + 16
		
		if( overlapy(carbox, linebox) ) then
			
			-- check tiles
			for j = 1, CELLS_PER_LINE do
				
				-- only if there is an obstacle
				if(g_lines[i].cells[j].obstacle > 0) then
				
					-- cell's bounding box depends on type
					cellbox = getbbox(linebox, g_lines[i].xoffset + 16 * (j - 1), g_lines[i].cells[j].obstacle)
					
					-- bam!
					if(overlap(carbox, cellbox)) then
						handlecollision(i, j)
					end
				end
			end
		end
	end
end

-- ##############################################
-- GAME
-- ##############################################

-------------------------------
-- start a new game
-------------------------------
function startgame()
	g_car = {}
	g_car.x = 64
	g_car.y = CAR_MIN_Y
	g_car.animation = 0
	g_car.frame = 0
	-- state: 0 = ok
	--        1 = crashed
	--        2 = sliding
	g_car.state = 0
	g_car.steer = 0
	
	g_lines = {}
	g_lines.linenumber = 0
	g_lines.center = 64
	g_lines.move = 0
	g_lines.moves = 5
	g_lines.nextfence = flr(rnd(5)) + 5
	g_lines.lastoil = 0
	
	g_logic.speed = INIT_SPEED
	g_logic.pixelbuffer = 0
	g_logic.distance = i32_init()
	g_logic.score = i32_init()
	
	sfx(0, 0)
	sfx(4, 1, 0, 12)
	
	initlines()
	
	g_game.state = 2
	g_game.fanframe = 0
end

-------------------------------
-- set car animation based on
-- state and passed frames
-------------------------------
function animatecar()
	
	g_car.frame += 1
	
	-- driving: base animation on current speed
	if(g_car.state == 0) then
		n = flr(4 + (1 - (g_logic.speed - INIT_SPEED) / (MAX_SPEED - INIT_SPEED)) * 11)
	-- dead (hit hard obstacle)
	elseif(g_car.state == 1) then
		n = 10
	-- sliding
	else
		n = 20
	end
	
	-- animation change
	if(g_car.frame >= n) then
		-- sliding
		if( g_car.state == 2) then
			g_car.animation += 1
			if(g_car.animation > 3) then
				g_car.animation = 0
			end
		else
			g_car.animation = 1 - g_car.animation
		end
		
		g_car.frame = 0
	end
	
	-- sliding: move car towards top
	if( g_car.state == 2) then
		if(g_car.y > -64) then
			g_car.y -= g_logic.speed * dt
		end
	end
	
end

-------------------------------
-- update during game
-- dt - delta time in seconds
-------------------------------
function updategame(dt)	

	animatecar()

	-- ----------------
	-- game running ---
	if( g_game.state == 2 ) then
	
		f = (g_logic.speed - INIT_SPEED) / (MAX_SPEED - INIT_SPEED)
		g_car.y = flr(CAR_MIN_Y + f * (CAR_MAX_Y - CAR_MIN_Y))
		
		-- steering
		playerinput()
		if(g_input.btn[5] or g_input.btn[6]) then
			steerspeed = 2
		else
			steerspeed = 1
		end
		g_car.x += g_car.steer * steerspeed
		if(g_car.x < 6) then g_car.x = 6
		elseif(g_car.x > 122) then g_car.x = 122 end
		
		-- move level
		g_logic.pixelbuffer += g_logic.speed * dt
		numpixels = flr(g_logic.pixelbuffer)
		if(numpixels > 0) then
			g_logic.pixelbuffer -= numpixels
			for i = 1, LINES do
				g_lines[i].yoffset += numpixels
				-- line has passed the screen
				if( g_lines[i].yoffset > 128) then
					g_lines[i].yoffset -= 128 + 16
					initline(i, g_lines[i].yoffset, true)
					
					g_logic.distance = i32_add16(g_logic.distance, 1)
					if(not g_god) then
						g_logic.score = i32_add32(g_logic.score, g_logic.distance)
					end
					
					g_logic.speed += 1
					if( g_logic.speed > MAX_SPEED) then
						g_logic.speed = MAX_SPEED
					end
				end
			end
		end
		
		collisiontest()
		
	-- ----------------
	-- game over (player dead, delay)
	elseif( g_game.state == 3 ) then
	
		collisiontest()
		
		if((time() - g_game.time) > 2) or g_input.btnp[5] or g_input.btnp[6] then
			g_game.state = 4
			
			sfx(3, 1, 0, 32)
			sfx(-1, 0)
			
			g_highscore.rank = highscoreset(g_logic.score)
			--printh("reached rank " .. tostr(g_highscore.rank))
		end
		
	-- ----------------
	-- high score (with dead player in bg)
	elseif( g_game.state == 4 ) then
	
		if(g_input.btnp[5] or g_input.btnp[6]) then
			startgame()
		end
		
	end
	
end

-------------------------------
-- set palette according to 
-- theme
-------------------------------
function setthemepal(theme)
	pal()
	palt(0, false)
	palt(THEME_TRANSPARENT[theme + 1], true)
end

-------------------------------
-- set fan color according to 
-- theme
-------------------------------
function setthemefan(theme)
	pal(7, THEME_FANCOLOR[theme + 1])	
end

-------------------------------
-- draw a given line
-------------------------------
function drawline(index)
	x = g_lines[index].xoffset
	y = flr(g_lines[index].yoffset)
	
	theme = g_lines[index].theme * 32
	
	
	for cell = 1, CELLS_PER_LINE do

		setthemepal(g_lines[index].theme)

		-- grass
		if(g_lines[index].cells[cell].background == 0) then
			spr(64 + theme, x, y)
			spr(64 + theme, x + 8, y)
			spr(64 + theme, x, y + 8)
			spr(64 + theme, x + 8, y + 8)
		-- street left
		elseif(g_lines[index].cells[cell].background == 1) then
			spr(80 + theme, x, y)
			spr(81 + theme, x + 8, y)
			spr(80 + theme, x, y + 8)
			spr(81 + theme, x + 8, y + 8)
		-- street center
		elseif(g_lines[index].cells[cell].background == 2) then
			spr(82 + theme, x, y, 2, 1)
			spr(81 + theme, x, y + 8, 1, 1)
			spr(81 + theme, x + 8, y + 8, 1, 1)
		-- street right
		elseif(g_lines[index].cells[cell].background == 3) then
			spr(81 + theme, x, y)
			spr(80 + theme, x + 8, y, 1, 1, true, false)
			spr(81 + theme, x, y + 8)
			spr(80 + theme, x + 8, y + 8, 1, 1, true, false)
		end
		
		-- obstacle
		
		-- fence
		if(g_lines[index].cells[cell].obstacle == 1) then
			spr(65 + theme, x, y + 8, 2, 1)
			
		-- fan
		elseif(g_lines[index].cells[cell].obstacle == 8) then
			setthemefan(g_lines[index].theme)
			spr(32 + 2 * g_game.fansprite, x, y, 2, 2)
		-- dying fan
		elseif(g_lines[index].cells[cell].obstacle == 9) then
			setthemefan(g_lines[index].theme)
			spriteframe = flr(min((time() - g_lines[index].cells[cell].start), 0.5) * 6)
			spr(40 + 2 * spriteframe, x, y, 2, 2)

		-- other
		elseif(g_lines[index].cells[cell].obstacle > 1) then
			spr(64 + theme + g_lines[index].cells[cell].obstacle * 2, x, y, 2, 2)
		end
		
		x += 16
	end
end

-------------------------------
-- draw all g_lines
-------------------------------
function drawlines()

	-- calc fansprite for all fans
	g_game.fansprite = (time() / 1) 
	g_game.fansprite = g_game.fansprite - flr(g_game.fansprite)
	g_game.fansprite = flr(g_game.fansprite * 6)
	if( g_game.fansprite > 3 ) then
		g_game.fansprite = 6 - g_game.fansprite
	end
	
	for i = 1, LINES do
		drawline(i)
	end
	
	pal()

end

-------------------------------
-- draw the car
-------------------------------
function drawcar() 
	palt(0, false)
	palt(14, true)
	
	-- normal
	if( g_car.state == 0) then

		-- no steering
		if(g_car.steer == 0) then
			spr( 2 * g_car.animation,
			g_car.x - 8, 
			g_car.y - 8, 2, 2)
		-- left
		elseif(g_car.steer < 0) then
			spr( 8 + 2 * g_car.animation,
			g_car.x - 8, g_car.y - 8, 2, 1)
			spr( 16 + 2 * g_car.animation,
			g_car.x - 8, g_car.y, 2, 1)
		-- right
		elseif(g_car.steer > 0) then
			spr( 24 + 2 * g_car.animation,
			g_car.x - 8, g_car.y - 8, 2, 1)
			spr( 16 + 2 * g_car.animation,
			g_car.x - 8, g_car.y, 2, 1)
		end
		
	-- crashed
	elseif( g_car.state == 1) then
		spr( 4 + 2 * g_car.animation,
			g_car.x - 8, 
			g_car.y - 8, 2, 2)
	-- sliding
	elseif( g_car.state == 2) then
		if( g_car.animation == 0 ) then
			spr( 0, g_car.x - 8, g_car.y - 8, 2, 2)
		elseif( g_car.animation == 1 ) then
			spr( 12, g_car.x - 8, g_car.y - 8, 2, 2)
		elseif( g_car.animation == 2 ) then
			spr( 0, g_car.x - 8, g_car.y - 8, 2, 2, false, true)
		else
			spr( 12, g_car.x - 8, g_car.y - 8, 2, 2, true, false)
		end
		
	end
	
end

-------------------------------
-- draw the current score
-------------------------------
function drawscore()
	s = i32_tostr(g_logic.score, true)
	x = 128 - 4 * #s
	y = 1
	
	--print(s, x + 1, y + 1, 5)
	rectfill( 128 - 40 - 1, 0, 128, 6, 5)
	print(s, x, y, 7)
end

-------------------------------
-- draw the highscore screen
-------------------------------
function drawhighscore()
	rectfill(28 - 2, 24 - 2, 128 - 28 - 2, 128 - 24 - 2, 6)
	rectfill(28 + 2, 24 + 2, 128 - 28 + 2, 128 - 24 + 2, 0)
	rectfill(28, 24, 128 - 28, 128 - 24, 5)
	printcenter(26, "game over", 7)
	
	y = 26 + 12
	for	i = 1, 8 do
	
		if(i == g_highscore.rank) then
			colors = { 1, 8, 2, 9, 3, 10 }
			col = (time() / 0.5)
			col -= flr(col)
			col *= 6
			col += 1
			col = colors[flr(col)]
		else
			col = 7
		end
	
		print(tostr(i), 38, y, col)
		print(i32_tostr(g_highscore[i]), 38 + 12, y, col)
		
		y += 7
	end
	
	col = (time() / 0.75)
	col -= flr(col)
	if(col > 0.5) then
		printcenter(128 - 26 - 5, "press a button", 7)
	end
end

-------------------------------
-- draw game
-------------------------------
function drawgame()
	cls(14)
	drawlines()
	drawcar()
	drawscore()
	
	if(g_game.state == 4) then
		drawhighscore()
	end
end

-- ##############################################
-- LOADING SCREEN
-- ##############################################

-------------------------------
-- update loading screen
-- dt - delta time in seconds
-------------------------------
function updateloadingscreen(dt)

	-- update color array
	if(g_loading.frames % 10 == 0) then
		-- create color array
		if( g_loading.colors == nil) then
			g_loading.colors = {}
			for i = 1,16 do
				g_loading.colors[i] = i
			end
		end
		
		-- shuffle color array
		for i = 1,100 do
			a = 1 + flr(rnd(16))
			b = 1 + flr(rnd(16))
			t = g_loading.colors[a]
			g_loading.colors[a] = g_loading.colors[b]
			g_loading.colors[b] = t
		end
	end
	
	g_loading.frames += 1
	g_loading.duration -= dt

	if(g_input.btnp[5] or g_input.btnp[6] or (g_loading.duration < 0)) then
		g_game.state = 1
		g_start.frame = 0
		sfx(-1, 0)
		sfx(4, 1, 0, 12)
	end
end

-------------------------------
-- draw loading screen
-------------------------------
function drawloadingscreen()
	for i = 0,7 do
		rectfill(0, i * 16, 128, (i + 1) * 16, g_loading.colors[i + 1])
	end
	
	rectfill(14, 24, 128 - 14, 128 - 24, 5)
	
	palt(0, false)
	palt(14, true)
	
	sspr(112, 0, 16, 16, 64 - 16, 64 - 16, 32, 32)
end

-- ##############################################
-- START SCREEN
-- ##############################################

-------------------------------
-- update start screen
-------------------------------
function updatestartscreen(dt)
	g_start.frame += 1
	if(g_start.frame == 32767) then
		g_start.frame = 0
	end
	
	if(g_input.btnp[5] or g_input.btnp[6]) then
		startgame()
	end
end

-------------------------------
-- draw start screen
-------------------------------
function drawstartscreen()
	cls(0)
	spr(224, 3, 64 - 32, 16, 2)
	
	cols = { 0, 5, 6, 7, 7, 6, 5, 0 }
	
	f = g_start.frame / 300
	if(g_start.frame == 300) then
		g_start.frame = 0
	end
	
	if(f < 0.5) then
		if(f > 0.25) then
			f = 0.5 - f
		end
		f *= 40
		f = min(f, 3) + 1
		printcenter(48, "a game by bob fungus", cols[flr(f)])
	else
		f -= 0.5
		if(f > 0.25) then
			f = 0.5 - f
		end
		f *= 40
		f = min(f, 3) + 1
		printcenter(48, "pico-8 port by hackefuffel", cols[flr(f)])
	end
	
	col = flr(g_start.frame / 10) % 8
	printcenter(72, "press a button", cols[col + 1])
	
	pal()
	palt(0, false)
	palt(14, true)
	pal(0, 1)
	pal(5, 0)
	
	x = 16
	y = 68
	spriteframe = flr(g_start.frame / 10) % 6
	if( spriteframe > 3 ) then
		spriteframe = 6 - spriteframe
	end
	spr(32 + 2 * spriteframe, x, y, 2, 2)
	
	x = 128-16-16
	y = 68
	spriteframe = flr((g_start.frame + 7) / 10) % 6
	if( spriteframe > 3 ) then
		spriteframe = 6 - spriteframe
	end
	spr(32 + 2 * spriteframe, x, y, 2, 2)
	
	pal()
	
end

-- ##############################################
-- API FUNCTIONS
-- ##############################################

-----------------------------
-- init application
-----------------------------
function _init()
	highscoreload()
	sfx(6, 0)
end

-------------------------------
-- update main function
-------------------------------
function _update60()
	
	dt = time() - g_logic.lasttime
	g_logic.lasttime = time()
	
	input()
	
	if(g_game.state  == 0 ) then
		updateloadingscreen(dt)
	elseif(g_game.state  == 1 ) then
		updatestartscreen(dt)
	else
		updategame(dt)
	end
	
end

-------------------------------
-- draw main function
-------------------------------
function _draw()
	
	if( g_game.state == 0) then
		drawloadingscreen()
	elseif( g_game.state == 1) then
		drawstartscreen()
	else
		drawgame()
	end
end
__gfx__
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1d1dd1eeeeeeeeeeed777777777777de
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceee7eeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0d0000eeeeeeeeeed7aaaa9999aaaa7d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eee7ee7eeeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee050000ee1dd1eeee7aaaa977779aaa97
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeceeceee7eeeeeeeeeeeee100eeeeeeeeeeeeedddeeee0825ee0d00eeee7aaa97999979aa97
ee100eef8ee100eeee100eef8ee100eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeee100eef8e0d00eeee100eef8e0d00eee02889ee2500eeee7aaa979aaa79aa97
eedd5029820dd5eeeed00029820d00eeeeeee6e066eeeeeeeeeee66066eeeeeeeed00029820dddeeeeddd029820100ee0200888ee00eeeee7a99947777499947
ee100089820100eeeedd5089820dd5eeee000606888000eeee000606888000eeeed0008982e100eeeed0008982e100ee02908288882eeeee7a99994774999947
ee100e88820100eeee102e88820100eeeeddd068880dddeeeeddd068880dddeeeeddde8882eeeeeeee100e8882eeeeee02008977899feeee7a99994774999947
eeeeee87c2eeeeeeeeeeee87c2eeeeeeee000908005000eeee000908005000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee020089cc8888eeee7a999f7777f49947
eeeee887c22eeeeeeeeee887c22eeeeeeee598299220100eeee598299220100eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee02908222222eeeee7a99f499994f4947
10059829922051001005982992205100e10288888888dddee10288888888dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0200822e000eeeee7944777777772447
dd52888888882d00d002888888882dd5edd880000008100eedd880000008100eee100eeeeeeeeeeeeedddeeeeeeeeeeee02880ee1dd1eeee7947244444444447
d008800000088d00d008800000088d00e10020900902100ee10020900902100eeed000ef8ee100eeeed000ef8ee100eeee0825ee0d00eeee794f777777724447
10002090090201001000209009020100e10002222220100ee10002222220100eeeddd029820100eeee100029820dddee111dd1ee0500eeee79444444444444f7
100e02222220edd5dd5e02222220e100e100e000000e100ee100e000000e100eee100e89820d00eeee100e89820d00ee0000d0eeeeeeeeeed722222222222f7d
100ee000000ee100100ee000000ee100eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8882edddeeeeeeee8882e100ee000050eeeeeeeeeeed777777777777de
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88ee8eeee
eeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeee067760eeeeeeeeee067760eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeeee8eeeeef8e8ee8f98eeef8e
eeeeee0000eeeeeeeeeee067760eeeeeeeeee000000eeeeeeee02000000e0eeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeee88eeeeeeeee88e82eeee8f88eee82e
eeeee067760eeeeeeeeee000000eeeeeee0ee0ff0f0ee0eeee07e0ff0f0e70eeeeeee067760eeeeeeeeeee0000eeeeeee8f988ee88ee8f98eeee8eef822e8eee
eeeee000000eeeeeeeeee0ff0f0eeeeee07000ffff00070eee0700ffff0070eeeee02000000e0eeeeeeee067760eeeeeee988888f988988eee882ee82982eeee
eeeee0ff0f0eeeeeeeeee0ffff0eeeeeee0777ffff6770eeeee077ffff670eeeee07e0ff0f0e70eeeee02000000e0eeeee88888898888eeee8f82828f882e88e
eeeee0ffff0eeeeeeeee07ffff60eeeeeee0077666600eeeeeee07766660eeeeee0700ffff0070eeee07e0ff0f0e70eeeee889f988888eeee898e82e982e8f98
eeee07ffff60eeeeeee0777666660eeeeeeee077660eeeeeeeeee077660eeeeeeee077ffff670eeeee07e0ffff0e70eeeeeef2000088eeeee888888282ee8f82
eee0777666660eeeee070077666070eeeeeee077660eeeeeeeeee077660eeeeeeeee07766660eeeeeee077ffff660eeeeeee90777708eeeeee88888282ee882e
eee0707766070eeeeee0e077660e0eeeeeeee076660eeeeeeeeee076660eeeeeeeeee077660eeeeeeeee07766660eeeeeeee000000088eeeeee8888882ee82ee
eee0707766070eeeeeeee076660eeeeeeeeee010000eeeeeeeeee010000eeeeeeeeee077660eeeeeee888077668ffeeeeee080ff0f08f8eeeeee8ff9882e8e8e
eeee00766600eeeeeeeee010000eeeeeeeee01000000eeeeeeee01000000eeeeeeeee076660eeeeeeeef807768ff8eeeee0780ffff0898eee8eef988888888f8
eeeee010000eeeeeeeee01000000eeeeeee0100ee0000eeeeee0100ee0000eeeeeee8010000feeeeeee8805688f888eeee807ffffff08f8eef88f88888888282
eeee01000000eeeeeeee010ee000eeeeee0000ee550000eeee0000eee50000eeeeef010f80008eeeeee8880000088eeee8f9087fff08998ee8e8f8888888822e
eeee010ee00055eeeeee000e500055eeeee00555555005eeee000e55555000eeee880108800088eeeeee88888888eeeeee888e88888e88eeeee88f98888882ee
eeee000550005eeeeeee000550005eeeeeee555eee555eeeeee55555ee550eeeee88000ee00088eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888222eee
333333335ea95e5a9ee5a95e00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbb3d105eeeeeee3b7b3d05eeeeeeeeeeee305eeeeee
33333333aaaaaaaaaaaaaaaa00000000eeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee33bbbbeeeeeebbbb333d10eeeeeeeb77b3350eeeeeeeeeee3b50eeeeee
33333333449224492244922400000000eeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeee0dcccccbbeeeeb77b3b33515eeeee3bbbbb3d055eeeeeeee37b315eeeee
33333333e592e5592e5592e500000000eeeeee009eeeeeeeeeeeeeeeeeeeeeeeeeee1dc6676cccbeebb77bb7b3d10eeeee3333333031015eeeeee37b350eeeee
33333333059405e9405e940500000000eeeeeeaa9eeeeeeeeeeeeeeeeeeeeeeeeee1dccccccccc3eebb77bbb33d50eeee3bbb33033333105eeee3b733315eeee
33333333999499994999949900000000eeeeee7999eeeeeeeeeeeeeeeeeeeeeeeee1ccc676ccc3eeebbbbb3333d50eee3b77bb3303bb3311eee337b3bb50eeee
3333333344934449b444944400000000eeeee7a999112eeeeeeeeeeeeeeeeeeeee1d666cccccc3eeebbbbbb37bd10eee3b77bb330b77b350eee3b7bbbb315eee
33333333223b323b1323912300000000eeee7a999492eeeeeeeee66dd5eeeeeeee1ccccccc663eeeeebbbbb3bb515eee3bbbbb3d0b7bb3d0ee3b7bb733350eee
367d5d55555555555555555555555555e9aaa99949499eeeeeee6776d55eeeeee1dccccccccc3eeeeeebbb33d510eeee3bbbb3d03bbbb350ee3b7b7b3b3315ee
336dd555555555555555555555555555999949a99444999eeee67776dd5eeeeee0c676cc676c3eeeeeeee000001eeeeee3bb3d0033bb3d10eeb7b7b37bb350ee
367d5555555555555555555775555555442227a942124444eee67776dd10eeeee0cccccccccc3eeeeeeee49450eeeeeeee330045033d510eeeb7bbb3bb33d0ee
3376d555555555555555555775555555e4227a9111111124eee67766dd10566ee0cccccccccc3eeeeeeee479405555eeeeeeee4950000eeeeeebbb3333d500ee
367ddd55555555555555555775555555eeeaa91111eeeeee765d666dd510676de01cc6776ccc3eeeeeee4979450055eeeeeeee47950eeeeeeeeee40000000eee
6376d555555555555555555775555555eaa99111eeeeeeee6515dddd510067d5ee01cc6ccccc3eeeeee4979445005eeeeeeee49794000555eeee49794405555e
367d5555555555555555555775555555e99111eeeeeeeeee510e555110055d50eee001ccccc3eeeeeeee4994445eeeeeeeee49794450005eeeee4994440055ee
336ddd55555555555555555555555555eeeeeeeeeeeeeeeeeeeee10005eeeeeeeeeee001d3eeeeeeeeeee44445eeeeeeeeeee47944455eeeeeeee4444055eeee
99999999eef2eeef2eeef2ee00000000050eeeeeeee555eeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
9999999a4444444444444444000000005605eeeeee50005eeeeeeeeeeeeeeeeeeeeee4499aaaeeeeeeeee3eeeeeeeeeeeeeeeeea3eeeeeeeeeeeeeee30eeeeee
99a5999922222222222222220000000000005eeeee50065eeeeeeeeeeeeeeeeeeeee44999999aaeeeeeeeb3eeeeeeeeeeeeeeeab33eeeeeeeeeeeee3330eeeee
99999999ee40eee40eee40ee00000000e50005eee5005eeeeeeeeeeeeeeeeeeeeee44949994499aeeeeee37053eeeeeeeebeeeab30eeee3eeeeeeeeab30eeeee
99999999eef2eeef2eeef2ee00000000ee5000ee5000ee55eeeeeeeeeeeeeeeeee42999999a499aeeeee3bab3beeeeeeeb7beeabb0eee730eeeebee7b30ee0ee
99999999444444444444444400000000eee5005e005ee500eeeeeeeeeeeeeeeeee24999999999aeeee3b77ab770eeeeee37bee7b30eee730eeeabee7b303030e
99999999222222222222222200000000e55ee55505e55056eeeeeeeeeeeeeeeee429999999999aeeeee3377ba335eeeee3ab777b30777b30eeea3be3b300330e
99999a994004940440049400000000005005555555500000eee66666d5eeeeeee029999999999aeeeeeeb77a3b7b3eeee3ab3bab30bbb330eee37ab7b3bb330e
a77f66666666666666666666666666665000000055555005ee677776655eeeeee029999994a99aeeee3b7b7abb33eeeee33bbbabb0033300eeee37aab33330ee
97f66666666666666666666666666666500600000055600eee6777766d55eeeee029999999999aeeeeeeb37abb30eeeeee3333bb3000300eeeeee33ab3000eee
677f6666666666666666666776666666e505e0000056005eee6777766d20eeeee02999a999999aeeeee5bbbab330eeeeeeeee33b30eeeeeeeeeeeeeab303eeee
97f66666666666666666666776666666eeee0050056500eeeee667666d2055eee004999999999eeeee5763bbb305eeeeee6ee37b30eeeeeeeeeeeeea330e56de
577f6666666666666666666776666666500000556500000e765d6666d520555ee4029999994a9eeeee77653b3305555ee6c0537b3055555ee66eeeeab30567d5
a7f6666666666666666666677666666606000000000006006525dddd520055eeee00299999992eeee676605b350555eee65053bb305555ee6765e6ebb3056755
677f6666666666666666666776666666006605eeeee50000520e555200055eeeee4002499942eeeee65650033055eeeeeeeeee350555eeee67d567d5b345dd50
97f6666666666666666666666666666650005eeeeeee5005eeeeeeeeeeeeeeeeeee42002222eeeeee52255eeeeeeeeeeeeeeeeeeeeeeeeee6d506d555eeeeeee
66666666677777776277776200000000eeeeeeeddeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd2eeeeeeee
666666667666666661666661000000007dedeed7cdeee7deeeee6776ddeeeeeeeeeee222222eeeeeeee777777eeeeeee9aaaaaaaaaa9eeeeeeeed66d2eeeeeee
666666666dddddddd1ddddd100000000d2eeeed7cdeeed2eee67766666ddeeeeeeee2dccddd2eeeee7771111777eeeeea999999999992eeeeeee676d2eeeeeee
666dd666112221111122222100000000eeeedee7dd2edeeee77666666666ddeeeee2dccccc2ddeee7771c7ccc777eeeea995559955992eeeeeed676d22eeeeee
66de6676677762677777776100000000eedd2eeddcd2eeeee766666666666deeeee2777cccd2deee6777cccc7776deeea959999599592eeeeee676ddd2eeeeee
66d66f76ddddd2ddddddddd100000000ed7d2ddd7cd2eddee77766666666d5eeeeddcccccccd2dee767766cc7ddd2eeea959559599592eeeeed66776dd2eeeee
66667766221111222221111100000000edcded2ecd2ed7cde777776666dd52eeeedcccc777cd2dee6767666c25252eeea959959599592eeeee67666dd22eeeee
66666666000000000000000000000000edddcdd2d2eed7d2e7dcd7776d5552eeeedccccccccc26ee76666dcc25522eeea995599955992eeeed777766dd22eeee
676d1555555555555555555555555555eeddccd2d2eedd2ee7d7cc776d5552eeeddccccccccc26ee67666dc225251eeea999999999992eeed66777766dd1eeee
6676d155555555555555555565555555eeedddddd2eed2eee7dcccd76d5552eeeddcc77cccccd67e76666dc2d5521eee4222222222222eeed76666dddd122eee
6666d155555555555555555665555555eeeed77cdd2ededee7ccccd76d555155edccccccccccdd7e67666dc2d5251eeee751eeeee751eeeed6777666dddd1eee
666dd155555555555555555665555555edee7ccddcdddd7de6c2dcd76d555155edcccccccc777d7e76666dc2d5521555e751eeeee751eeeeed67776ddd21eeee
676d1555555555555555555665555555e7dd7cdd77ccd2d2edc277776d552155eddccccccccdd67e67666c7c25251555e752eeeee751eeeeeeeddd22211555ee
676d1555555555555555555665555555eded7ddd7ccdd22e7cc266776d21155eee76dddddddd67eed66667cc25515555e752555ee752555eeeeee7d2155555ee
666d1555555555555555555655555555eeedd7cddcddd2eeccd1dd666d115eeeeee7777777777eeeedd66cc2d215555ee7525eeeee525eeeeeeee76d1555eeee
676d1555555555555555555555555555eeeedddddd222eee2112eedd255eeeeeeeeeeeeeeeeeeeeeeeeddd22d5555eeeeeeeeeeeeeeeeeeeeeeee67d15eeeeee
eeeeeeeeddf6dddf6dddf6dd00000000dddddddeeddeddddddddddddddddddddddddddddddddddddddd22222dd200ddddd23bbb332ddddddddddd2222ddddddd
eeeeeeeeffffffffffffffff000000007ededde7feddd7edddd57777775dddddddddd222222ddddddd23bbb322eee0ddd23b7fbb332ddddddddd23bb32dddddd
eeeeeeee446224462244622400000000e2dddde7feddde2dd577999999675ddddddd22222222ddddd23bffbb3ea9840d2eee3ffeee32dddddddd2b7bb322dddd
eeeeeeeed562d5562d5562d500000000ddddedd7ee2dedddd799aaaaaa9975ddddd22ecccce2ddddd2bf7fbb3e9d840dea984bea984300dddd2233bfbb332ddd
eeeeeeee056405d6405d640500000000ddee2ddeefe2ddddd77aaaaaaa6652ddddd2e77cccce2dddd2bfffbb3e8840dde9d843e9d840330dd23b333bffb322dd
eeeeeeee666466664666646600000000de7e2eee7fe2deedd7777666665520dddd22cccccccc62ddd2bffbb33344432de8842be88420b332d3b7b333bf3eee2d
eeeeeeee44624446e444644400000000defede2dfe2de7fed7fff6eee45250dddd2eccc777cc6eddd23bbeee333bbb3034443b34440bfb3033bfb333b3ea9842
eeeeeeee2efe22effe2efe2e00000000deeefee2e2dde7e2d77f6e6e444520dddd2cccccccccceddd223ea9843b7ffb023bbbb3303bffb303333333bb3e9d840
e8222212222222222222222222222222ddeeffe2e2ddee2dd7fff6eee45250dddd2ccccccccccf2d23bbe9d843bffbb0233bb3303bffeee33feee3b7b3e88420
8a91112e222222222222222222222222dddeeeeee2dde2ddd77f6e6e444520ddd2ecc77ccccccfed2b7fe884223bbb30d233332033bea9842ea984bbfb344420
89d81221222222222222222772222222dddde77fee2dededd7fff6eee45250ddd2cccccccccccfed2bffb4444223330ddd220002033e9d842e9d843bb3333202
e8881122222222222222222772222222dedd7ffeefeeee7ed77f6e6e44452055d2cccccc777ccf7d23bb3249422000ddddd29444200e88422e8842333333202d
8a911212222222222222222772222222d7ee7fee77ffe2e2de7ff6eee4525055d2ecccccccccff7dd233249942055dddddd24a9444034440d2442222200002dd
89d82e22222222222222222772222222dede7eee7ffee22dd5ef6e6e44450555dd7ffffffffff7dddd2249a94205555ddddd24a94405000ddd22224994200555
8dd81221222222222222222772222222dddee7feefeee2dddd55e6eee420555ddde7777777777dddddd49a9942025ddddddd24994420555ddddd249a94420555
e8811122222222222222222222222222ddddeeeeee222ddddddd5220002555ddddddddddddddddddddd24994220dddddddd22449422055dddddd29a94422055d
66666666e7761eeeee67761e00000000eeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777763777eeeeeeee777d2eeeeeeeeeeeeeeeeeeeeee
66766666676c617756677c6100000000ee666eeee66cc6eeeeeeeeeeeeeeeeeeeeeee222222eeeeeeeeb7777367776eeeeee77766d2eeeeeeeeeee76eeeeeeee
67cd6666677d6777d6777d6700000000e6cc66ee7ccc6eeeeeeeeeeeeeeeeeeeeeee2dccddd2eeeeeeeb77663077606eeeee70606d2eeeeeeeee7776deeeeeee
66666666557555575555755500000000e7c7cee6ccc7eeeeeeeeeeeeeeeeeeeeeee2dccccc2ddeeee77766337c6c006eeeee77966d2eeeeeeee77776dd55eeee
66666666ee75ee575eee75ee00000000e76c6eecc66eeeeeeeeeeeeeeeeeeeeeeee2cccc6cd2deeee777600777c03077e0ee77496d2eeeeeee777766cd576eee
666667d6ee75ede75ede75ed00000000e6c6ee6c7cee66eeeeee6776deeeeeeeeeddccc7cccd2deee77663b7760337770ee84774644eeeeeeeee76cd5e776d55
66666666d6765d6765d6765d00000000ee6ee6c7cce6cc7eeee677776deeeeeeeedccc7ccccd2deeee6b30b7603b377300d4884444d0eeeeeeeeeeeee7777c6d
66666666677766777667776600000000eeee6c7cccccccc6ee677776d5eeeeeeeedcc7cccccc26eeeee33bb003b31000e00dd744dd20e0eeeeeeeeeeee77c6d5
7d7ddddddddddddddddddddddddddddde6e6c6ccccccccccee6777cdd55eeeeeeddc6ccccccc26eeeeee3333d31100deeeed764d6d000eeeeeeee66cddeeeeee
6d7ddddddddddddddddddddddddddddd6c67ccccc6cc6cc6eeeccc66cd5eeeeeeddccccc6cc6d67eeeeeee000000deeeee6778466d2ee0eeeeee6776cd5eeeee
66ccdddddddddddddddddddddddddddde6e6cccc7cc7cc7eeee66776cd2155eeedccccc7cc7cdd7eeeeeeee9450eeeeee677884666d0eeeeeee67776cd21eeee
77d7ddddddddddddddddddd77dddddddeee6ccc6cc6cc6eeeee6776cdd21566eedcccc6cc6cccd7eeeeeeeea940eeeeee777764666dd0eeeeee6776ccd21eeee
66c7ddddddddddddddddddd77dddddddee6cccccc6cc6cee765d66cdd521676deddccccccccdd67eeeeeee9a9450555ee777766666dd055e765d66ccd521555e
7d7cddddddddddddddddddd77ddddddde7ccccccecccceee6525dddd521167d5ee76dddddddd67eeeeeee9a94450555ee777766666dd05556525dddd5211555e
6d7dddddddddddddddddddd77ddddddde7ccccce6ccc6eee525e555221155d55eee7777777777eeeeeeee99945005eeee67776666dd2055e521e5552211555ee
6d6dddddddddddddddddddddddddddddee777ceee677eeeeeeeee211155eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee677766dd2055eeeeeee2111555eeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666d000000000006600000000000000000000d66d000000000000066000000000000000000000066666d000000000000000006600000000000000000000000
666666d0000000000660000066000000000000d6666d000000006600660000000000000000000000666666d00000000000000006600000000000000000000000
660006600000000006600000a6000000000005600066500000006600000000000000000000000000660006600000000000000000000000000000000000000000
7700577009a77a90077077654a49a77700000670007760567770777077009a77a90009a7a90000007700577009a77a90056777077009a7a90004a7a400000000
777777a09a7777a90770777a049a77770000077000777067777077707709a7777a90977777900000777777a09a7777a90677770770977777909a777a90000000
aaaaaa00aa9009aa0aa0009a909aa00000000aaaaaaaa0aaa400aa00aa0aa9009aa0aa909aa00000aaaaaa00aa9559aa0aaa400aa0aa909aa0aa404aa0000000
aa009aa0aa0000aa0aa0000aa009a90000000aaaaaaaa0aa0000aa00aa0aa0000aa0aa000aa00000aa009aa0aa5005aa0aa0000aa0aa000aa0aa000aa0000000
99000990990000990990000990009940000009900099909900009900990990000990990009900000990009909950059909900009909900099099000990000000
99000940494004940494004940000994000009900099909994009900990494004940990009900000990009904940549909994009909900099099505990000000
44444450544444450544444450444445000004400044405444404440440544444450440004400000440004405444444405444404404400044044444440000000
44444500054444500054444500444450000004400044400544405440440054444500440004400000440004400544504400544404404400044000444440000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005440000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444450000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444500000000
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
00010208050200203005020010100402001020080300b020060300403003030030200605012050120501205013050130501305001050010500105001050010500105001050080500805003050010500105007050
0009000039650386502f6501d650146500d6500665001650016500165002650026500265002650026500265002650026500165001650016500165000650006500065000650006500065000650006500065000650
000100000e2500b2500b25012250132500e2500e250162501f250212501b250172501a250252502c2502c25026250242502a2503025034250342502d250292502b2503025034250372503825038250322502a250
000300003c250352502f2502c250302502e25029250232501d2501a250192501b2501c250192501625013250102500e2500c2500b2500a2500a2500b2500d2500a25007250052500425005250042500325003250
000700002a2701b2602e2601f260332602225036240252403a230272203c2202b2103d2101f200162001c2001f200282002c20033200372002b200122001a2001f200252002b2003020036200362000000029200
0002001f21050260502c05031050350503905038050340502d050250501f0501a050150500d0500c0500c0500d0500e050120501b05022050270503105035050360503505033050300502c05027050230501e050
0010000b173503d3503435009350283502735020350373500c350273502f350003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000200000d3100e3100f3101031012310133101431014310143101531016310163101531015310143101331012310113100f31000300003000130001300013000230002300003000a3000e300023000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
