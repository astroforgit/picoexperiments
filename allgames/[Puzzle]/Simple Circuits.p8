pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--simplecircuits
--by jem_hunter

function _init()
	--cart data setup
	cartdata("jem_hunter_electrician_1")
	hscore = dget(0)
	if hscore == nil then
		hscore = 0
		dset(0, 0)
	end
	--music menu item
	menuitem(1, "mute music", togglemusic)
	mus = true
	--colour blind mode menu item
	menuitem(2, "colourblind-off", cbtoggle)
	cblind = false
	--variables used for scores and levels
	playstate = 1
	levels = {0, 150, 350, 700}
	score = 0
	jobs = 0
	successmsg = "job completed successfully"
	failmsg = "you didn't work fast enough"
	strikemsg = "one strike gained"
	threestrikemsg = "you are fired"
	strikeremovemsg = "one strike removed"
	timecols = {5, 8, 10, 11}
	--setup the main menu
	menuinit()
end

function _update()
	--update the correct window based on the play state
	if playstate == 1 then
		menuupdate()
	elseif playstate == 2 then
		gameupdate()
	elseif playstate == 3 then
		trupdate()
	elseif playstate == 4 then
		instupdate()
	end
end

function _draw()
	--draw the correct window based on the play state
	if playstate == 1 then
		menudraw()
	elseif playstate == 2 then
		gamedraw()
	elseif playstate == 3 then
		trdraw()
	elseif playstate == 4 then
		instdraw()
	end
end
-->8
--special draw functions

function shade (l)
	--adjust the colours based on the shade level
	if l == 0 then 
		pal()
	else
		for c = 0, 15 do
			pal(c, sh[l][c + 1], 1)
		end
	end
end

function tile (t, x, y, l, p, e)
 --draw the tile with id t at pos x,y. l - locked, p - power, e - extra
 if t != 0 then
 	
 	--display / hide locks
 	if l != 0 then
 		pal(3, 2)
 		pal(15, 6)
 	else
 		pal(15, 3)
 	end
 	--draw the tile
 	sspr(0, 8, 16, 18, x, y, 16, 18)
		pal()
		
		--add extras for colour blind mode
		if cblind then
			if (e == 1) sspr(16, 64, 16, 16, x, y, 16, 16)
			if (e == 2) sspr(72, 80, 16, 16, x, y, 16, 16)
			if (e == 3) sspr(88, 80, 16, 16, x, y, 16, 16)
			if (e == 4) sspr(104, 80, 16, 16, x, y, 16, 16)
		end
		
		local data = tdata[t]
		
		--draw the first wire (and power)
		if data[1] != -1 and data[2] != -1 then
			if (p[1] == 1) pal(1, 10)
			sspr(data[1], data[2], 16, 16, x, y, 16, 16)
			pal()
		end
		
		--draw the second wire or extra object (with power)
		if data[3] != -1 and data[4] != -1 then
			local sp = {data[3], data[4]}
			if p[2] == 1 then
				pal(1, 10)
				local b = 0
				if sp[1] == 112 and sp[2] == 48 then
					sp[1] = 40
					sp[2] = 64
					b = 1
				end
				if e != 0 then
					pal(4, extracol[e][2])
					if b == 0 then
						pal(3, extracol[e][2])
					else
						pal(3, extracol[e][1])
					end
				end
			else
				if (e != 0) pal(2, extracol[e][1])
				if (e != 0) pal(3, extracol[e][2])
			end
			sspr(sp[1], sp[2], 16, 16, x, y, 16, 16)
			pal()
		end
		
	end
end


function pointer (x, y, d, h, e, inv)
	--draw the pointer
	--first time setup
	if poff == nil then
		poff = 0
		pch = 1
	end
	
	--sprite position
	local sp = {8, 0}
	local off = flr(poff / 5)
	
	--if held down
	if d then 
		sp = {16, 0}
		off = 4
	end
	--if holding a tile
	if h > 0 then 
		sp = {16, 8}
		tile(h, x - 4, y - 4 + off, 0, {0,0}, e)
	end
	
	--get the y position based on offset and down
	yp = y + off
	--invert cursor
	if (inv) yp = y - off
	
	--draw the pointer
	sspr(sp[1], sp[2], 8, 8, x, yp, 8, 8, inv, inv)
	
	--increment offset
	poff += pch
	--bound offset and reverse
	if poff > 15 then
		poff = 15
		pch = -1
	end
	if poff < 0 then
		poff = 0
		pch = 1
	end
end

function shake ()
	--screen shaking (thanks to nerdyteachers.com)
	--random positions
	local x = rnd(shakeintensity) - (shakeintensity / 2)
	local y = rnd(shakeintensity) - (shakeintensity / 2)
	--move camera
	camera(x, y)
	--reduce movement amount
	shakeintensity *= 0.8
	--stop shaking
	if (shakeintensity < 0.3) shakeintensity = 0
end

function message (t, bc, fc, tc, btext)
	--display a message to the screen (text, back colour, front colour, text colour, bottom text)
	rectfill(20, 40, 107, 87, fc)
	rect(21, 41, 106, 86, bc)
	local yp = 43
	--print text
	for mes in all(t) do
		print(mes, 64 - (#mes * 2), yp, tc)
		yp += 6
	end
	print(btext, 62 - (#btext * 2), 80, tc)
	
end

function thprint(t, x, y, ic, oc)
	--thick text print (thanks to pixelbytes)
	--print background
	for r = y - 1, y + 1 do for i = x - 1, x + 1 do print(t, i, r, oc) end end
	--print text
	print(t, x, y, ic)
end

function togglemusic ()
	--toggle the music on or off
	mus = not mus
	--remove and re-add correct menu item
	menuitem(1)
	if mus then
		menuitem(1, "mute music", togglemusic)
	else
		menuitem(1, "unmute music", togglemusic)
	end
end

function cbtoggle()
	--toggle colourblind mode on or off
	cblind = not cblind
	--remove menu item and re-add correct one
	menuitem(2)
	if cblind then
		menuitem(2, "colourblind-on", cbtoggle)
	else
		menuitem(2, "colourblind-off", cbtoggle)
	end
end
-->8
--generation

function generate(d)
	
	--limit difficulty
	if (d > 100) d = 100
	
	--empty grid data
	local grid = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}
	local gridextra = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}
	local lock = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}
	
	--direction data
	local dires = {{0,-1},{1,0},{0,1},{-1,0}}
	local invdires = {3,4,1,2}
	
	--id offsets for bulbs and batteries
	local bulboff = 13
	local battoff = 9
	
	--d from 0 to 100
	--d affects - number of pairs, number of locked, number of empty
	local minp = 2 + max((flr(d / 17) - 1), 0)
	local maxp = 3 + flr(d / 20)
	--local numpairs = flr(rnd(flr(d / 20) + 3)) + 2 + flr(d / 35)
	local numpairs = flr(rnd(maxp - minp)) + minp
	--number of tiles left avaliable
	local tilesleft = 24 - flr((100 - d) / 14)
	local totalpairs = 0
	--add paths
	for p = 1, numpairs do
		local added = false
		local att = 0
		--try 100 times
		while not added and att < 100 do
			local toadd = {}
			local start = {-1, -1}
			--select start point
			while start[1] == -1 do
				
				start = {flr(rnd(5)) + 1, flr(rnd(5)) + 1}
				if grid[start[2]][start[1]] != 0 then
					start  = {-1,-1}
				end
			
			end
		
			--create chain
			local current = {start[1], start[2]}
			local maxlen = flr(rnd(5 + flr(d /40))) + 2
			local done = false
			local path = {}
			--keep moving
			while maxlen > 0 and not done do
			
				local poss = {}
				--get availiable directions
				for di = 1, 4 do
					
					local n = {current[1] + dires[di][1], current[2] + dires[di][2]}
					if n[1] > 0 and n[1] < 6 and n[2] > 0 and n[2] < 6 then
						local used = false
						
						for p in all(path) do
							if (p[1][1] == n[1] and p[1][2] == n[2]) used = true
						end
						
						if (not used) add(poss, di)
					end
					 
				end
				
				--if there is not a direction availiable
				if #poss < 1 then
					done = true
					--the path is done
					add(path, {current, 0})
				else
					--pick a direction
					local d = poss[flr(rnd(#poss)) + 1]
					--if this is the end - stop
					if (maxlen <= 1) d = 0
					--add position to path
					add(path, {current, d})
					--if continuing - update current position
					if (d != 0) current = {current[1] + dires[d][1], current[2] + dires[d][2]}
				end
				
				--reduce length remaining
				maxlen -= 1
			end
			
			--pick a random colour
			local c = flr(rnd(4)) + 1
			--check if tiles can be added
			--create toadd list of tiles
			local canadd = true
			local numadded = 0
			
			--if the path has at less than 3 tiles it cannot be added
			if (#path < 3) canadd = false
			
			--iterate down the path
			for p = 1, #path do
				--get position and direction going to
				local po = path[p][1]
				local di = path[p][2]
				local ldi = 0
				--get the direction you came from
				if (p != 1) ldi = invdires[path[p-1][2]]
				
				--first is a bulb
				if p == 1 then
					--must be empty
					if grid[po[2]][po[1]] == 0 then
						add(toadd, {po, bulboff + di, c})
						numadded += 1
					else
						canadd = false
					end
				elseif p == #path then
					--last if battery
					--must be empty
					if grid[po[2]][po[1]] == 0 then
						add(toadd, {po, battoff + ldi, c})
						numadded += 1
					else
						canadd = false
					end
				else
					--wire
					if grid[po[2]][po[1]] == 0 then
						--if empty - just add correct wire based on directions
						if ldi == 1 or di == 1 then
							if ldi == 2 or di == 2 then
								add(toadd, {po, 3, 0})
								numadded += 1
							elseif ldi == 3 or di == 3 then
								add(toadd, {po, 1, 0})
								numadded += 1
							elseif ldi == 4 or di == 4 then
								add(toadd, {po, 4, 0})
								numadded += 1
							end
						elseif ldi == 2 or di == 2 then
							if ldi == 3 or di == 3 then
								add(toadd, {po, 5, 0})
								numadded += 1
							elseif ldi == 4 or di == 4 then
								add(toadd, {po, 2, 0})
								numadded += 1
							end
						elseif ldi == 3 or di == 3 then
							if ldi == 4 or di == 4 then
								add(toadd, {po, 6, 0})
								numadded += 1
							end
						end
						
					else
						--if there was some wire there
						if grid[po[2]][po[1]] < 10 then
							--check for possible pair - add if possible
							if (ldi == 2 or di == 2) and (ldi == 4 or di == 4) and grid[po[2]][po[1]] == 1 then
								add(toadd, {po, 7, 0})
							elseif (ldi == 1 or di == 1) and (ldi == 3 or di == 3) and grid[po[2]][po[1]] == 2 then
								add(toadd, {po, 7, 0})
							elseif (ldi == 1 or di == 1) and (ldi == 4 or di == 4) and grid[po[2]][po[1]] == 5 then
								add(toadd, {po, 8, 0})
							elseif (ldi == 2 or di == 2) and (ldi == 3 or di == 3) and grid[po[2]][po[1]] == 4 then
								add(toadd, {po, 8, 0})
							elseif (ldi == 1 or di == 1) and (ldi == 2 or di == 2) and grid[po[2]][po[1]] == 6 then
								add(toadd, {po, 9, 0})
							elseif (ldi == 3 or di == 3) and (ldi == 4 or di == 4) and grid[po[2]][po[1]] == 3 then
								add(toadd, {po, 9, 0})
							else
								canadd = false
							end
						else
							canadd = false
						end
					end
				end
			end
			
			--if no conflicts and there was something to add
			if canadd and #toadd > 0 and tilesleft - numadded >= 0 then
				--add the tiles and extras to the grids
				for a in all(toadd) do
					grid[a[1][2]][a[1][1]] = a[2]
					gridextra[a[1][2]][a[1][1]] = a[3]
				end
				--successfully added
				added = true
				totalpairs += 1
				--reduce number of tiles remaining
				tilesleft -= numadded
			end
			
			--performed an attempt
			att += 1
			
			--end of attempt while loop
		end
		
		--end of pairs for loop
	end
	
	--calculate tiles used
	local tiletotal = 25 - tilesleft
	
	--lock some pieces
	--up to half may be locked max
	local maxlock = flr(tiletotal / 2)
	--chance to lock based on difficulty
	local lockch = (flr(d / 5) * 2)
	
	--iterate tiles
	for x = 1, 5 do
		for y = 1, 5 do
			--random number
			local r = flr(rnd(100)) + 1
			
			--if it can be locked and is a tile
			if grid[y][x] != 0 and maxlock > 0 then
				local lo = lockch
				--*1.7 chance for bulb and battery
				if grid[y][x] > 9 then
				 lo = flr(lo * 1.7)
				else
					--less likely to lock a wire - even less as difficulty increases
					lo = flr(lo * (0.7 - (d/170)))
				end
				--if random is less than chance
			 if r <= lo then
			 	--lock the tile
			 	lock[y][x] = 1
			 	maxlock -= 1
			 end
			end
			
		end
	end
	
	--add / convert some tiles
	--iterate for each tile
	for x = 1, 5 do
		for y = 1, 5 do
			
			--if there isn't a tile
			if grid[y][x] == 0 then
				--if another tile can be added
				if tilesleft > 0 then
					--1 in 3 - add another tile
					if flr(rnd(3)) + 1 == 1 then
						--random tile added
					 grid[y][x] = flr(rnd(9)) + 1
						tilesleft -= 1
					end
				end
			else
				--if there is a tile
				--if it is not a bulb or battery
				if grid[y][x] < 10 then
					--and it isn't locked
					if lock[y][x] == 0 then
						--1 in 8 chance to upgrade
						if flr(rnd(8)) + 1 == 1 then
							--upgrade to double (2 of each go to the same pair)
							if (grid[y][x] == 1 or grid[y][x] == 2) grid[y][x] = 7
							if (grid[y][x] == 4 or grid[y][x] == 5) grid[y][x] = 8
							if (grid[y][x] == 3 or grid[y][x] == 6) grid[y][x] = 9
						end
					end
				end
			end
			
		end
	end
	
	--scramble remaining
	--200 times
	for i = 1, 200 do
		
		--two random tiles
		local r1 = {flr(rnd(5)) + 1, flr(rnd(5)) + 1}
		local r2 = {flr(rnd(5)) + 1, flr(rnd(5)) + 1}
		
		--if neither are locked
		if lock[r1[2]][r1[1]] == 0 and lock[r2[2]][r2[1]] == 0 then
			--swap tiles (use temp so data is not lost)
			local temp = grid[r1[2]][r1[1]]
			local etemp = gridextra[r1[2]][r1[1]]
			grid[r1[2]][r1[1]] = grid[r2[2]][r2[1]]
			gridextra[r1[2]][r1[1]] = gridextra[r2[2]][r2[1]]
			grid[r2[2]][r2[1]] = temp
			gridextra[r2[2]][r2[1]] = etemp
		end
	end
	
	--calculate time allowed (less as difficulty increases)
	local ti = flr((100 - d) / 2) + 20
	
	--add time for each pair present
	ti += totalpairs * 10
	
	--return tables and generation data
	return grid, gridextra, lock, totalpairs, ti
end

-->8
--main game

function gameinit()
	--setup music
	if mus then
		music(0, 2000)
		plmus = true
	else
		plmus = false
	end
	--variables created
	--lever sprites
	lspr = 0
	ch = false
	lch = 1
	--shade table
	sh = {{0,1,1,5,5,5,6,7,14,5,10,6,13,13,14,15},{0,1,1,1,1,1,7,7,6,1,6,6,6,6,6,6},{0,0,0,0,0,0,7,7,7,0,7,7,7,7,7,7}}
	--shade position
	s = 0
	sch = 1
	schi = false
	t = {24, 24}
	--get difficulty
	diff = flr(score / 10)
	--perform generation
	g, gextra, l, pairnum, ttime = generate(diff) 
	--vert1, hor1, topr1, topl1, botr1, botl1, cross2, topl2, topr2, bat1, bat2, bat3, bat4, end1, end2, end3, end4
	tdata = {{24, 0, -1, -1},{40, 0, -1, -1},{56, 0, -1, -1},{72, 0, -1, -1}, {88, 0, -1, -1},{104, 0, -1, -1},{24, 0, 40, 0},{72, 0, 88, 0},{56, 0, 104, 0},{16, 16, 112, 32},{32, 16, 112, 32},{48, 16, 112, 32},{64, 16, 112, 32},{16, 16, 112, 48},{32, 16, 112, 48},{48, 16, 112, 48},{64, 16, 112, 48}}
	--{level 1 out dir, level 2 out dir}
	pow = {{{0,0},{0,0},{0,0},{0,0},{0,0}},{{0,0},{0,0},{0,0},{0,0},{0,0}},{{0,0},{0,0},{0,0},{0,0},{0,0}},{{0,0},{0,0},{0,0},{0,0},{0,0}},{{0,0},{0,0},{0,0},{0,0},{0,0}}}
	--power directions (layer 1 then layer 2)
	pdir = { {{3,0,1,0},{0,0,0,0}},
										{{0,4,0,2},{0,0,0,0}},
										{{2,1,0,0},{0,0,0,0}},
										{{4,0,0,1},{0,0,0,0}},
										{{0,3,2,0},{0,0,0,0}},
										{{0,0,4,3},{0,0,0,0}},
										{{3,0,1,0},{0,4,0,2}},
										{{4,0,0,1},{0,3,2,0}},
										{{2,1,0,0},{0,0,4,3}},
										{{1,1,1,1},{0,0,0,0}},
										{{2,2,2,2},{0,0,0,0}},
										{{3,3,3,3},{0,0,0,0}},
										{{4,4,4,4},{0,0,0,0}},
										{{5,0,0,0},{0,0,0,0}},
										{{0,5,0,0},{0,0,0,0}},
										{{0,0,5,0},{0,0,0,0}},
										{{0,0,0,5},{0,0,0,0}}}
	--cursor data
	cur = {3,3}
	zdown = false
	zheld = false
	theld = 0
	theldextra = 0
	--extra colours for tiles
	extracol = {{2,8}, {1,12}, {3,11}, {9,10}}
	--power stack
	psta = {}
	--basic directions (u, r, d, l)
	dirs = {{0,-1},{1,0},{0,1},{-1,0}}
	--inverse direction positions
	invd = {3, 4, 1, 2}
	--power data
	pon = true
	pframe = 0
	--screen shake info
	shakeintensity = 0
	shakemax = 7
	--if player has died
	dead = false
	--time (or job happiness)
	hap = ttime * 30
	maxhap = hap
	hapdist = {5,9,13,17,24}
	hapcol = {0, 8, 10, 11}
	haplen = {0, 20, 60, 100}
	--if the player has won
	victory = false
	honf = 0
	--bar position
	barp = {32, 128}
	--checking for change variables
	oldcur = {3,3}
	plspr = lspr
	pcha = false
	pick = 0
	--time until game start
	starttime = 30 * 4
	--winning screen variables
	playing = false
	timewon = 0
	--if the power is still changing
	powerchanging = false
	--current score multiplier
	mulpos = 4
	--number of wires and locked tiles used
	wireused = 0
	lockedused = 0
	
	--add all batteries to power stack
	for x = 1, 5 do
		for y = 1, 5 do
				
			if g[y][x] > 9 and g[y][x] < 14 then
				add(psta, {x, y, pdir[g[y][x]][1][1], gextra[y][x], 1})
				pow[y][x][1] = 1
			end
					
		end
	end
	
	--fill with power before start
	for times = 0, 50 do
		local pnew = {}
		--iterate power stack
		for powpos in all (psta) do
			
			--if the power goes somewhere
			if powpos[3] != 0 then
				
				--get the tile it is going to
				pos = {powpos[1] + dirs[powpos[3]][1], powpos[2] + dirs[powpos[3]][2]}
				--if it is on the board
				if pos[1] > 0 and pos[1] < 6 and pos[2] > 0 and pos[2] < 6 then
					--if there is a tile there
					if g[pos[2]][pos[1]] != 0 then
						--get the cable directions of the destination tile
						local p1 = pdir[g[pos[2]][pos[1]]][1][invd[powpos[3]]]
						local p2 = pdir[g[pos[2]][pos[1]]][2][invd[powpos[3]]]
						--if there is an input for layer 1
						if p1 != 0 then
							--update power value
							pow[pos[2]][pos[1]][1] = powpos[5]
							--if the power goes somewhere - add it to next stack
							if (p1 > 0 and p1 < 5) add(pnew, {pos[1], pos[2], p1, powpos[4], powpos[5]})
							--if it is a bulb
							if p1 == 5 then
								--if power is off
								if powpos[5] == 0 then
									--switch bulb off
									pow[pos[2]][pos[1]][2] = powpos[5]
								else
									--if the bulb matches the colour - turn it on
									if (powpos[4] == gextra[pos[2]][pos[1]]) pow[pos[2]][pos[1]][2] = powpos[5]
								end
							end
						else
							--if there is a second wire
							if p2 != 0 then
								--update the power
								pow[pos[2]][pos[1]][2] = powpos[5]
								--if it goes somewhere - add it to the next stack
								if (p2 > 0 and p2 < 5) add(pnew, {pos[1], pos[2], p2, powpos[4], powpos[5]})
							else
								--if it was empty - keep checking here
								add(pnew, powpos)
							end
						end
						
					else
						--if it was empty - keep checking here
						add(pnew, powpos)
					end
				
				end
			
			end
		
		end
		--update stack to new version
		psta = pnew
	end
	
end

function gameupdate()
	--transitions
	if ch then
		--if lever is moving
		lspr += lch
		if lspr > 12 then
			lspr = 12
			lch = -1
			ch = false
		end
		if lspr < 0 then
			lspr = 0
			lch = 1
			ch = false
			schi = true
		end
	end
	
	if schi then
		--if shade is changing
		s += sch
		if s < 0 then
			s = 0
			schi = false
			sch = 1
			pon = true
			--if reached light point
			--add all batteries to power stack (on)
			for x = 1, 5 do
				for y = 1, 5 do
				
					if g[y][x] > 9 and g[y][x] < 14 then
						add(psta, {x, y, pdir[g[y][x]][1][1], gextra[y][x], 1})
						pow[y][x][1] = 1
					end
					
				end
			end
			
		end
		if s > 21 then
			s = 21
			schi = false
			sch = -1
		end
	end
	--power
	--if there is a stack and the game is still playing
	if #psta > 0 and playing and not dead and not victory then
		--frame delay
		pframe += 1
		--halved for turning on
		if (pon) pframe += 1
		
	 if pframe > 35 then
			pcha = false
			pframe = 0
			local pnew = {}
			--iterate stack
			for powpos in all (psta) do
				--if the power is going somewhere
				if powpos[3] != 0 then
					--get the destination tile
					pos = {powpos[1] + dirs[powpos[3]][1], powpos[2] + dirs[powpos[3]][2]}
					--if it is within the grid
					if pos[1] > 0 and pos[1] < 6 and pos[2] > 0 and pos[2] < 6 then
						--if there is a tile there and not a battery
						if g[pos[2]][pos[1]] != 0 and (g[pos[2]][pos[1]] < 10 or g[pos[2]][pos[1]] > 13) then
							--get wire positions
							local p1 = pdir[g[pos[2]][pos[1]]][1][invd[powpos[3]]]
							local p2 = pdir[g[pos[2]][pos[1]]][2][invd[powpos[3]]]
							--if there is a layer 1
							if p1 != 0 then
								--if the power will change
								if pow[pos[2]][pos[1]][1] != powpos[5] then
									--power has changed
									pcha = true
									--update power
									pow[pos[2]][pos[1]][1] = powpos[5]
								end
								--if there is somewhere to go - add tile to stack
								if (p1 > 0 and p1 < 5) add(pnew, {pos[1], pos[2], p1, powpos[4], powpos[5]})
								--if it is a bulb
								if p1 == 5 then
									--if power is off
									if powpos[5] == 0 then
										--switch off
										pow[pos[2]][pos[1]][2] = powpos[5]
									else
										--if power types match
										if powpos[4] == gextra[pos[2]][pos[1]] then
											--if this will change the power
										 if pow[pos[2]][pos[1]][2] != powpos[5] then
										 	--update power
										 	pow[pos[2]][pos[1]][2] = powpos[5]
												pcha = true
											end
										end
									end
								end
							else
								--if there is second wire
								if p2 != 0 then
									--if the power wiil change
									if pow[pos[2]][pos[1]][2] != powpos[5] then
										--update the power
										pow[pos[2]][pos[1]][2] = powpos[5]
										pcha = true
									end
									--if there is somewhere to go - add to new stack
									if (p2 > 0 and p2 < 5) add(pnew, {pos[1], pos[2], p2, powpos[4], powpos[5]})
								else
									--if this is not switching of - add it to the stack again
									if (powpos[5] != 0) add(pnew, powpos)
								end
							end
							
						else
							--if it is not a battery
							if g[pos[2]][pos[1]] < 10 or g[pos[2]][pos[1]] > 13 then
								--if the power is not going off - add it to the stack again
								if (powpos[5] != 0) add(pnew, powpos)
							end
						end
					
					end
				
				end
			
			end
			--update the stack to the new version
			psta = pnew
		
		end
		
	end
	--inputs
	--z pressed first time
	if btnp(4) and not zdown and not zheld and playing then
		zdown = true
		zheld = true
	end
	--z released
	if (not btn(4)) zdown = false
	--z activation
	if not zdown and zheld then
		--lever position
		if cur[1] == -1 then 
			--if it is not already changine
			if not ch and not schi and not bulbch and not powerchanging then
				--going off
				if lspr == 0 then
					--shade is changing
					schi = true
					--remove all going on power from the stack
					local toremove = {}
					for p in all(psta) do
						if (p[5] == 1) add(toremove, p)
					end
					for p in all(toremove) do
						del(psta, p)
					end
					--turn power off
					pon = false
					--add all batteries as off to the stack
					for x = 1, 5 do
						for y = 1, 5 do
				
							if g[y][x] > 9 and g[y][x] < 14 then
								add(psta, {x, y, pdir[g[y][x]][1][1], gextra[y][x], 0})
								pow[y][x][1] = 0
							end
					
						end
					end
					
				end
				--lever is changing
				ch = true
			end
		else
			--if not on lever
			--if not holding a tile
			if theld == 0 then
				--if current tile is present and not locked
				if g[cur[2]][cur[1]] != 0 and l[cur[2]][cur[1]] == 0 then
					--if there is no power in the tile
					if pow[cur[2]][cur[1]][1] == 0 and pow[cur[2]][cur[1]][2] == 0 then
						--pick up the tile and remove from grid
						theld = g[cur[2]][cur[1]]
						theldextra = gextra[cur[2]][cur[1]]
						g[cur[2]][cur[1]] = 0
						gextra[cur[2]][cur[1]] = 0
						pick = 1
					else
						--electrocuted
						shakeintensity = shakemax
						dead = true
						playing = false
					end
				end
			else
				--if holding a tile
				--if the grid at the current position is empty
				if g[cur[2]][cur[1]] == 0 then
					--insert the tile into the grid
					g[cur[2]][cur[1]] = theld
					gextra[cur[2]][cur[1]] = theldextra
					theld = 0
					theldextra = 0
					pick = 2
				end
			end
		end
		--z has been released
		zheld = false
	end
	--left pressed (while allowed)
	if btnp(0) and not ch and playing then
		--if on the board
		if cur[1] != -1 then
			--if not at the edge
			if cur[1] > 1 then
			 --move left (not holding z now)
				cur[1] -= 1
				zheld = false
			end
		else
			--if on the lever - move onto grid
			cur[1] = 5
			cur[2] = 3
			zheld = false
		end
	end
	--right pressed (when allowed)
	if btnp(1) and not ch and playing then
		--if the cursor isn't on the lever
		if cur[1] != -1 then
			--if not on the right edge
			if cur[1] < 5 then
				--move right
				cur[1] += 1
				zheld = false
			else
				--if on right edge and not holding a piece
				if theld == 0 then
					--move to lever
					cur[1] = -1
					cur[2] = -1
					zheld = false
				end
			end
		end
	end
	--up pressed (when allowed)
	if btnp(2) and not ch and playing then
		--if not at top or lever
		if cur[1] != -1 then
			if cur[2] > 1 then
				--move up
				cur[2] -= 1
				zheld = false
			end
		end
	end
	--down pressed (when allowed)
	if btnp(3) and not ch and playing then
		--if not on lever or bottom row
		if cur[1] != -1 then
			if cur[2] < 5 then
				--move down
			 cur[2] += 1
			 zheld = false
			end
		end
	end
	
	--wincheck
	--if the power is on and the player is not holding a bulb and the gae is running
	if pon and theld < 14 and not victory and not dead and playing and not pcha then
		
		local won = true
		
		--iterate all tiles
		for x = 1, 5 do
			for y = 1, 5 do
				
				--if the tile is a bulb
				if g[y][x] >= 14 then
					--if the power not on then player hasn't won
					if (pow[y][x][2] != 1) won = false
				end
				
			end
		end
		
		--update victory
		victory = won
		--if the player has won
		if victory then
			--no longer playing
			playing = false
			wireused = 0
			lockedused = 0
			--stop the music
			music(-1)
			--play win sound
			sfx(18)
			--count wires and locked
			for x = 1, 5 do
				for y = 1, 5 do
					if g[y][x] > 0 and g[y][x] < 10 then
						if (pow[y][x][1] == 1) wireused += 1
						if (pow[y][x][2] == 1) wireused += 1
					end
					if l[y][x] == 1 then
						if pow[y][x][1] == 1 or pow[y][x][2] == 1 then
							lockedused += 1
						end
					end
				end
			end
			
		end
	end
	
	--if the player has won and wait time not done - reduce wait time
	if (victory and timewon < 60) timewon += 1
	
	--move bar
	if (barp[2] > 112 and starttime < 30) barp[2] -= 1
	
	--move to score screen
	if victory and timewon >= 60 and btnp(4) then
		trinit({pairnum, wireused, lockedused, mulpos})
		playstate = 3
	end
	
	--return to main menu
	if dead and shakeintensity <= 0 and btnp(4) then
		menuinit()
		playstate = 1
	end
	
	--sound
	--cursor moved
	if oldcur[1] != cur[1] or oldcur[2] != cur[2] then
		--play one of the sounds
		sfx(5, -1, flr(rnd(6)) * 2, 2)
		--update cursor
		oldcur = {cur[1], cur[2]}
	end
	
	--if the lever changed
	if plspr != lspr then
		--play one of the sounds
		sfx(9, -1, flr(rnd(6)) * 2, 2)
		--if moved from top - power off sound
		if (plspr == 0) sfx(7)
		--if reached top - power on sound
		if (plspr == 1 and lspr == 0) sfx(6)
		--update old position
		plspr = lspr
	end
	
	--if the power has changed
	if pcha then
		--if the power is on
	 if pon then
	 	--random powering up sound
			sfx(8, -1, flr(rnd(5)) * 3, 3)
		else
			--random powering down sound
			sfx(8, -1, 16 + (flr(rnd(5)) * 3), 3)
		end
		--power has finished changing
		pcha = false
	end
	
	--if a tile has been moved
	if pick > 0 then
		--picked up
		if pick == 1 then
			--random sound - pick up
			sfx(10, -1, flr(rnd(4)) * 3, 3)
		else
			--random sound - put down
			sfx(10, -1, 13 + (flr(rnd(4)) * 3), 3)
		end
		pick = 0
	end
	
	--if music is on and muted
	if not mus and plmus then
		--turn music off
		music(-1)
		plmus = false
	end
	--if music is off and not muted
	if mus and not plmus then
		--if playing
		if not dead and not victory then
			--play the music
			music(0, 2000)
		end
		--music is playing
		plmus = true
	end
	
	--if the player is dead - no music
	if (dead) music(-1)
	
	--if the first start time has elapsed
	if starttime >= 30 then
		--if a number should change
		if starttime == 120 or starttime == 90 or starttime == 60 then
			--play a starting beep
			sfx(12, -1, flr(rnd(3)) * 7, 7)
		--at go
		elseif starttime == 30 then
			--start chime plays
			sfx(12, -1, 21, 11)
		end
	end
	
	--time adjust
	if playing then
		--if time is not up or game over - reduce time by 1
		if (hap > 0 and not victory and not dead) hap -= 1
		--flash offset increment
		honf += 1
		--wrap offset at 10
		if (honf > 10) honf = 0
	else
		--if still starting
		if starttime > 0 then
			--decrememnt time
			starttime -= 1
			--as the game begins - start playing
			if (starttime == 0) playing = true
		end
	end
end

function gamedraw()
	--clear screen and reset palette
	cls()
	pal()
	
	--screen main
	map(0, 0, 0, 0, 16, 16)
	--bulbs (above)
	sspr(0, 64, 16, 16, 16, 1, 16, 16)
	sspr(0, 64, 16, 16, 56, 5, 16, 16)
	sspr(0, 64, 16, 16, 96, 1, 16, 16)
	--lever
	sspr(0 + (16 * flr(lspr / 2)), 32, 16, 32, 111, 48, 16, 32)
	
	--tiles
	for x = 1 , 5 do
		for y = 1, 5 do 
			tile(g[y][x], t[1] + ((x - 1) * 16), t[2] + ((y - 1) * 16), l[y][x], pow[y][x], gextra[y][x])
		end
	end
	
	--lower border
	map(0, 0, 0, 0, 16, 16, 1)
	
	--pointer
	if not ch and playing then
		if cur[1] != -1 then
			--grid cursor
			pointer(28 + ((cur[1] - 1) * 16), 23 + ((cur[2] - 1) * 16), zheld, theld, theldextra, false)
		else
			--if not changing lever
			if lch > 0 then
				--top arrow
				pointer(114, 37, zheld, theld, theldextra, false)
			else
				--bottom arrow
				pointer(115, 83, zheld, theld, theldextra, true)
			end
		end
	end
	
	--bar
	map(0, 17, barp[1], barp[2], 8, 2)
	
	--time
	print("time", 41, barp[2] + 2, 10)
	--time string
	local ti = ":"
	
	--calculate seconds
	local sec = ceil(hap / 30)
	local se = sec
	--calcilate minutes
	local minu = flr(sec / 60)
	--remove whole minutes from seconds
	sec -= minu * 60
	
	--if minutes is less than 10
	if minu < 10 then
		--add a 0 to front and then to string
		ti = "0" .. tostr(minu) .. ti
	else
		--just add to string
		ti = tostr(minu) .. ti
	end
	
	--if seconds are less than 10
	if sec < 10 then
		--add to string with 0
		ti = ti .. "0" .. tostr(sec)
	else
		--just add to string
		ti = ti .. tostr(sec)
	end
	
	--calculate the time percentage
	local hp = (hap / maxhap) * 100
	--main and lower colour positions
	local mcp = 0
	local lcp = 0
	--iterate each colour (backwards)
	for i = #hapcol, 1, -1 do
		--if the percentage is less than or equal to that position
		if hp <= haplen[i] then
			--set the colour positions
			mcp = i
			lcp = i - 1
		end
	end
	
	--if not out of time
	if lcp > 0 then
		--if within 5 seconds of boundary and flash offset is on
		if se - ((haplen[lcp] / 100 * maxhap) / 30) <= 5 and honf > 4 and playing then
			--print time in lower colour
			thprint(ti, 39, barp[2] + 9, 3, hapcol[lcp])
		else
			--print time in main colour
			thprint(ti, 39, barp[2] + 9, 3, hapcol[mcp])
		end
	else
		--if not playing or out of time
		--print time in main colour
		thprint(ti, 39, barp[2] + 9, 3, hapcol[mcp])
	end
	
	--current score multiplier position is the main colour position
	mulpos = mcp
	
	--reputation
	print("rank", 65, barp[2] + 2, 10)
	local rmsg = tostr(score)
	--make number up to 4 digits
	for i = #rmsg + 1, 4 do
		rmsg = "0" .. rmsg
	end
	print(rmsg, 65, barp[2] + 9, 7)
	
	--strikes
	if (strikes < 1) pal(8, 3)
	print("—", 85, barp[2] + 9, 8)
	pal()
	if (strikes < 2) pal(8, 3)
	print("—", 85, barp[2] + 3, 8)
	pal()
	
	--intro
	if starttime > 0 then
		--number of seconds to start
		local st = flr(starttime / 30)
		--if there is still time to wait
		if st > 0 then
			--print number
			thprint(st, 64 - (#tostr(st) * 2), 60, 12, 7)
		else
			--print go
			thprint("go", 60, 60, 12, 7)
		end
	end
	
	--electrocuted message
	if dead and shakeintensity == 0 then
		message({"","electrocuted","","your job ends here", "jobs completed:" .. tostr(jobs)}, 8, 2, 7, "Ž - back to menu")
	end
	
	--victory message
	if victory and timewon >= 60 then
		message({"","","circuit complete"}, 11, 3, 7, "Ž - results")
	end
	
	--colour adjust
	palt(15, true)
	shade(flr(s / 7))
	
	--shaking
	if shakeintensity > 0 then
		shake()
		sfx(11, -1, flr(rnd(9)) * 2, 2)
	else
		camera(0,0)
	end
	
end
-->8
--main menu

function menuinit()
	--update score
	if score > hscore then
		hscore = score
		local h = dget(0)
		if hscore > h then
			dset(0, hscore)
		end
	end
	
	--caculate highscore message
	scoremsg = tostr(hscore)
	for i = #scoremsg, 3 do
		scoremsg = "0" .. scoremsg
	end
	scoremsg = "highest grade : " .. scoremsg
	
	--menu controls
	options = {"play","instructions"}
	menupos = 1
	menutype = 1
	subopt = {"novice (0)", "trainee (150)", "technician (350)", "engineer (700)"}
	title = "simple circuits:"
	subt = "remember to turn the power off"
	oldmp = menupos
	oldmt = menutype
	playatt = 0
	tostartdiff = 0
	tostart = -1
	--game scores - reset here
	score = 0
	jobs = 0
	strikes = 0
	--reset palette
	pal()
end

function menuupdate()
	--up pressed (not at top)
	if btnp(2) and menupos > 1 and tostart < 0 then
		--move up
		menupos -= 1
	end
	
	--down pressed
	if btnp(3) and tostart < 0 then
		--increase for main
		if menutype == 1 and menupos < #options then
			menupos += 1
		end
		--increase for diff select
		if menutype == 2 and menupos < #subopt then
			menupos += 1
		end
	end
	
	--Ž pressed
	if btnp(4) and tostart < 0 then
		
		--if selecting diff
		if menutype == 2 then
			--if unlocked
			if levels[menupos] <= hscore then
				--get ready to start
				tostartdiff = levels[menupos]
				tostart = 30
				playatt = 1
			else
				--locked
				playatt = 2
			end
		end
		
		--pressing play - open diff menu
		if (menutype == 1 and menupos == 1) menutype = 2
		--open instructions
		if menutype == 1 and menupos == 2 then
			--play accept sound
			sfx(13, -1, flr(rnd(5)) * 2, 2)
			--move to instructions
			instinit()
			playstate = 4
		end
	end
	
	--— pressed
	if btnp(5) and tostart < 0 then
		--move back to main
		if menutype == 2 then
			menutype = 1
			menupos = 1
		end
	end
	
	--starting
	if tostart > 0 then
	 tostart -= 1
	 if tostart == 0 then
	 	--move to game
	 	score = tostartdiff
	 	gameinit()
	 	playstate = 2
	 end
	end
	
	--sfx
	--moving position sounds
	if oldmp != menupos then
		sfx(5, -1, flr(rnd(6)) * 2, 2)
		oldmp = menupos
	end
	
	--moving menu layer sounds
	if oldmt != menutype then
		if oldmt < menutype then
			--moving forward
		 sfx(13, -1, flr(rnd(5)) * 2, 2)
		else
			--moving backward
			sfx(13, -1, 10 + flr(rnd(5)) * 2, 2)
		end
		oldmt = menutype
	end
	
	--press play
	if playatt != 0 then
		--not allowed
		if (playatt == 2) sfx(14, -1, 0, 15)
		--allowed
		if (playatt == 1) sfx(14, -1, 16, 16)
		playatt = 0
	end
	
end

function menudraw()
	cls()
	--print title
	print(title, 64 - (#title * 2), 20, 13)
	print(subt, 64 - (#subt * 2), 26, 13)
	
	--print main menu
	if menutype == 1 then
		for o = 1, #options do
			--if selected
			if o == menupos and menutype == 1 then
				thprint(options[o], 64 - (#options[o] * 2), 65 + ((o - 1) * 12), 0, 7)
			else
				print(options[o], 64 - (#options[o] * 2), 65 + ((o - 1) * 12), 7)
			end
		end
	end
	
	--difficulty menu
	if menutype == 2 then
		--sub header
		local tmsg = "select starting rank:"
		print(tmsg, 65 - (#tmsg * 2), 53, 7)
		--print options
		for o = 1, #subopt do
			local c = 1
			--coloured based on unlock
			if (hscore >= levels[o]) c = 7
			--if selected
			if menupos == o then
				thprint(subopt[o], 64 - (#subopt[o] * 2), 65 + ((o - 1) * 12), 0, c)
			else
				print(subopt[o], 64 - (#subopt[o] * 2), 65 + ((o - 1) * 12), c)
			end
		end
	end
	
	--print the highscore
	print(scoremsg, 64 - (#scoremsg * 2), 120, 7)
	
end
-->8
--transition screen

function trinit(toadd)
	--update high score
	if score > hscore then
		hscore = score
		local h = dget(0)
		if hscore > h then
			dset(0, hscore)
		end
	end
	
	--add a job completed - max 999
	jobs += 1
	if (jobs > 999) jobs = 999
	
	--score multipliers
	mpliers = {0, 0.5, 1, 2}
	
	--setup music
	if mus then
	 music(3)
	 plmus = true
	else
		plmus = false
	end
	
	--calculate total score
	ach = flr(((toadd[1] * 3) + toadd[2] + (toadd[3] * 2)) * (mpliers[toadd[4]]))
	
	wait = 65
	multpos = toadd[4]
	
	--setup each text - so they look nice
	pairtxt = tostr(toadd[1] * 3)
	for i = #pairtxt, 4 do
		pairtxt = " " .. pairtxt
	end
	
	wiretxt = tostr(toadd[2])
	for i = #wiretxt, 4 do
		wiretxt = " " .. wiretxt
	end
	
	locktxt = tostr(toadd[3] * 2)
	for i = #locktxt, 4 do
		locktxt = " " .. locktxt
	end
	
	multxt = tostr(mpliers[toadd[4]])
	if flr(mpliers[toadd[4]]) == mpliers[toadd[4]] then
		multxt = multxt .. ".0"
	end
	multxt = "* " .. multxt
	for i = #multxt, 4 do
		multxt = " " .. multxt
	end
	
	jobtxt = tostr(jobs)
	for i = #jobtxt, 2 do
		jobtxt = "0" .. jobtxt
	end
	
	--change in strikes
	strchange = 0
	
	pal()
end

function trupdate()
	
	--change music based on option
	if not mus and plmus then
		music(-1)
		plmus = false
	end
	if mus and not plmus then
		music(3)
		plmus = true
	end
	
	--if waiting
	if wait > 0 then
		wait -= 1
	else
		--if there are still points
		if ach > 0 then
			--move a point
			ach -= 1
			score += 1
			if (score > 9999) score = 9999
			sfx(17)
		else
			--once done
			if wait == 0 then
				--out of time
				if multpos == 1 then
					--add a strike
				 strikes += 1
				 sfx(14, -1, 0, 15)
				 strchange = 1
				 --game over sound
				 if (strikes >= 3) sfx(19)
				end
				--green time
				if multpos == 4 and strikes > 0 then
					--strike removed
					strikes -= 1
					sfx(14, -1, 16, 16)
					strchange = -1
				end
				wait -= 1
			end
			
		end
	end
	
	--Ž pressed
	if btnp(4) and wait < 0 then
		if strikes < 3 then
			--next level
			gameinit()
	 	playstate = 2
		else
			--game ends
			menuinit()
			playstate = 1
		end
	end
	
end

function trdraw()
	cls()
	--changing texts
	local scoretxt = tostr(score)
	local achtxt = tostr(ach)
	for i = #scoretxt, 3 do
		scoretxt = "0"..scoretxt
	end
	for i = #achtxt, 3 do
		achtxt = "0"..achtxt
	end
	
	local strtxt = ""
	for i = 1, 3 do
		if (strikes >= i) strtxt = strtxt .. "—"
	end
	
	--messages
	if multpos > 1 then
		--good job
		print(successmsg, 64 - (#successmsg * 2), 8, 11)
		--strike removed
		if (multpos == 4 and wait < 0 and strchange < 0) print(strikeremovemsg, 64 - (#strikeremovemsg * 2), 89, 11)
	else
		--failed
		print(failmsg, 64 - (#failmsg * 2), 8, 8)
		--strike added
		if wait < 0 and strchange > 0 then
			print(strikemsg, 64 - (#strikemsg * 2), 89, 8)
			--fired
			if (strikes >= 3) print(threestrikemsg, 64 - (#threestrikemsg * 2), 109, 8)
		end
	end
	
	--print all the information
	thprint("pairs *3 : " .. pairtxt, 36, 22, 0, 7)
	thprint("wires : " .. wiretxt, 48, 30, 0, 7)
	thprint("locks *2 : " .. locktxt, 36, 38, 0, 7)
	thprint(" time : ", 48, 46, 0, 7)
	thprint(multxt, 80, 46, 0, timecols[multpos])
	thprint("__________________", 28, 54, 0, 7)
	thprint("total :  " .. achtxt, 48, 62, 0, 7)
	thprint("your rank :  " .. scoretxt, 32, 70, 0, 7)
	
	thprint("jobs completed :   "..jobtxt, 12, 78, 0, 7)
	
	thprint("strikes : ", 40, 100, 0, 7)
	
	thprint(strtxt, 80, 100, 0, 8)
	
	--once updates done
	if wait < 0 then
		--if not gameover
		if strikes < 3 then
			print("Ž - next job", 38, 119, 7)
		else
			print("Ž - main menu", 36, 119, 7)
		end
	end
end
-->8
--instructions screen

function instinit()
	--information
	openingmsg = {"you have a new job","it is up to you to fix the", "circuits that have been", "installed incorrectly", "", "-connect the bulb indicators", "to the matching power supply", "", "-do not move a component while", "it is powered", "", "-the lever on the left toggles", "the power but because the boxes", "are in cupboards it will plunge", "you into darkness, try to", "remember the colours", "", "-work fast", "out of time - gain a strike", "perform well - remove one"}
	controls = {"controls", "", "menus", "", "‹”‘ƒ - navigate", "Ž - accept", "— - back", "", "gameplay", "", "‹”‘ƒ - move cursor", "Ž - pick up / put down", "Ž - flip switch"}
	--current view
	view = 1
	--icon
	iconoff = 0
	iconch = -1
	icontime = 0
end

function instupdate()
	--— pressed
	if btnp(5) then
		--go back to menu
		sfx(13, -1, 10 + flr(rnd(5)) * 2, 2)
		menuinit()
		playstate = 1
	end
	
	--update icon time
	icontime += 1
	
	--at 5 move icon
	if icontime >= 5 then
		--update offset
		iconoff += iconch
		--limit at -3
		if iconoff < -3 then
			iconoff = -3
			iconch = 1
		end
		--limit at 0
		if iconoff > 0 then
			iconoff = 0
			iconch = -1
		end
		--reset timer
		icontime = 0
	end
	
	--move left and right between screens
	if (btnp(0) and view == 2) view = 1
	if (btnp(1) and view == 1) view = 2
	
end

function instdraw()
	cls()
	
	--overview screen
	if view == 1 then
		local ypos = 1
		
		--iterate and pring messages
		for i = 1, #openingmsg do
			--first line is green
			if i == 1 then
				print(openingmsg[i], 64 - (#openingmsg[i] * 2), ypos, 11)
				--extra offset
				ypos += 2
			else
				print(openingmsg[i], 1, ypos, 7)
			end
			--if it is a blank line
			if openingmsg[i] == "" then
				--small offset
				ypos += 3
			else
				--large offset
				ypos += 7
			end
		end
	else
		--controls screen
		local ypos = 1
		
		--iterate and print lines
		for i = 1, #controls do
			--headers are green with extra offset
			if i == 1 or i == 3 or i == 9 then
				ypos += 5
				print(controls[i], 64 - (#controls[i] * 2), ypos, 11)
			else
				print(controls[i], 1, ypos, 7)
			end
			ypos += 7
		end
		
	end
	
	--print correct directional icon at offset
	if view == 1 then
		print("‘", 120, 122 + iconoff, 15)
	else
		print("‹", 0, 122 + iconoff, 15)
	end
end
__gfx__
000000000055000000550000000000d11d0000000000000000000000000000d11d000000000000d11d000000000000000000000000000000000000005dd1111d
000000000577550005775500000000d11d0000000000000000000000000000d11d000000000000d11d000000000000000000000000000000000000005dd1111d
007007005777775057777750000000d11d0000000000000000000000000000d11d000000000000d11d000000000000000000000000000000000000005dd1111d
000770005777757557777575000000d11d0000000000000000000000000000d11d000000000000d11d000000000000000000000000000000000000005dd1111d
000770005777755057777550000000d11d0000000000000000000000000000d11d000000000000d11d000000000000000000000000000000000000005dd1111d
007007000555750005557500000000d11d0000000000000000000000000000d11d000000000000d11d000000000000000000000000000000000000005dd1111d
000000000005750000005000000000d11d000000dddddddddddddddd000000d111dddddddddddd111d00000000000000dddddddddddddddd000000005dd1111d
000000000000500000000000000000d11d0000001111111111111111000000d111111111111111111d0000000000000d1111111111111111d00000005dd1111d
066666666666666000550000000000d11d00000011111111111111110000000d1111111111111111d0000000000000d111111111111111111d000000d1111dd5
663333333333336605775500000000d11d000000dddddddddddddddd00000000dddddddddddddddd00000000000000d111dddddddddddd111d000000d1111dd5
633f33333333f33657777750000000d11d000000000000000000000000000000000000000000000000000000000000d11d000000000000d11d000000d1111dd5
63ff33333333ff3657777575000000d11d000000000000000000000000000000000000000000000000000000000000d11d000000000000d11d000000d1111dd5
633333333333333657777550000000d11d000000000000000000000000000000000000000000000000000000000000d11d000000000000d11d000000d1111dd5
633333333333333605555500000000d11d000000000000000000000000000000000000000000000000000000000000d11d000000000000d11d000000d1111dd5
633333333333333600000000000000d11d000000000000000000000000000000000000000000000000000000000000d11d000000000000d11d000000d1111dd5
633333333333333600000000000000d11d000000000000000000000000000000000000000000000000000000000000d11d000000000000d11d000000d1111dd5
6333333333333336000000d11d000000000000000000000000000000000000000000000000000000111111115555555555555555dddddddddddddddddddddddd
6333333333333336000000d11d000000000000000000000000000000000000000000000000000000111111115dddddddddddddd5111111111111111dd1111111
6333333333333336000000d11d000000000000000000000000000000000000000000000000000000111111115dddddddddddddd5111111111111d1d11d1d1111
6333333333333336000000d11d000000000000000000000000000000000000000000000000000000111111115ddd00000000ddd511111111111d11d11d11d111
63ff33333333ff36000000d11d000000000000000000000000000000000000000000000000000000111111115dd1d000000d1dd51111111111111d1111d11111
633f33333333f336000000d11d000000000000000000000000000000000000000000000000000000111111115dd11d0000d11dd5dddddddddddddddddddddddd
6633333333333366000000d11d000000000000000ddddddd0000000000000000ddddddd000000000111111115dd111d00d111dd5555555555555555555555555
63666666666666360000000000000000000000000111111100000000000000001111111000000000111111115dd1111dd1111dd5555555555555555555555555
66333333333333660000000000000000000000000111111100000000000000001111111000000000000000005dd1111dd1111dd555555555d1111dd55dd1111d
06666666666666600000000000000000000000000ddddddd000000d11d000000ddddddd000000000000000005dd111d11d111dd5dddddddddd111dd55dd111dd
000000000000000000000000000000000000000000000000000000d11d0000000000000000000000000000005dd11d1111d11dd5ddddddddd1dd1dd55dd1dd1d
000000000000000000000000000000000000000000000000000000d11d0000000000000000000000000000005dd1d111111d1dd500000000d111ddd55ddd111d
000000000000000000000000000000000000000000000000000000d11d0000000000000000000000000000005ddd11111111ddd500000000d1d11dd55dd11d1d
000000000000000000000000000000000000000000000000000000d11d0000000000000000000000000000005dddddddddddddd500000000d11d1dd55dd1d11d
000000000000000000000000000000000000000000000000000000d11d000000000000000000000000000000555555555555555500000000d1111dd55dd1111d
000000000000000000000000000000000000000000000000000000d11d0000000000000000000000000000005555555555555555ddddddddd1111dd55dd1111d
00008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111dddd1111000011110000111100001111000011110000111100001111000011110000111100001111000011110000111100001111000000006666000000
11dddddddddddd11110082555558001111000000000000111100000000000011110000000000001111000000000000111100000000000011000dddddddddd000
1dddddddddddddd1100025577775000110000000000000011000000000000001100000000000000110000000000000011000000000000001000d22222222d000
16666a0000a66661100057577775000110000a0000a0000110000a0000a0000110000a0000a0000110000a0000a0000110000a0000a00001000d2222a222d000
16666a0000a66661100005777775000110000a0000a0000110000a0000a0000110000a0000a0000110000a0000a0000110000a0000a00001000d222a2222d000
1666aa0000aa666110dddd55775ddd0110008855555800011000aa0000aa00011000aa0000aa00011000aa0000aa00011000aa0000aa0001000d22aaaa22d000
166aa000000aa6611ddddddd55ddddd1100a25577775a001100aa000000aa001100aa000000aa001100aa000000aa001100aa000000aa001000d2222a222d000
1dd1000000001dd1166660000006666110015757777510011001000000001001100100000000100110010000000010011001000000001001000d222a2222d000
1dd1000000001dd1166600000000666110ddd5777775dd011001000000001001100100000000100110010000000010011001000000001001000d22222222d000
1dd1000000001dd116610000000016611ddddd55775dddd11001000000001001100100000000100110010000000010011001000000001001000dddddddddd000
1dd1000000001dd11dd1000000001dd1166660005506666110010000000010011001000000001001100100000000100110010000000010010000000000000000
1dd1000000001dd11dd1000000001dd1166600000000666110010255555010011001000000001001100100000000100110010000000010010000000000000000
1dd1dddddddd1dd11dd1dddddddd1dd11dd1000000001dd11ddd85577775ddd11dd1dddddddd1dd11dd1dddddddd1dd11dd1dddddddd1dd10000000000000000
1dd1dddddddd1dd11dd1dddddddd1dd11dd1dddddddd1dd11ddd57577775ddd11dd1000000001dd11dd1dddddddd1dd11dd1dddddddd1dd10000000000000000
100100000000100110010000000010011001000000001001100105777775100116660000000066611dd1000000001dd11dd1000000001dd10000000000000000
100100000000100110010000000010011001000000001001100100557750100116666000000666611dd1000000001dd11dd1000000001dd10000000000000000
10010000000010011001000000001001100100000000100110010000550010011dddddddddddddd116610000000016611dd1000000001dd10000000000000000
100100000000100110010000000010011001000000001001100100000000100110dddddddddddd0116660000000066611dd1000000001dd10000007777000000
1001000000001001100100000000100110010000000010011001000000001001100100dddd00100116666000000666611dd1000000001dd10000070000700000
100110000001100110011000000110011001100000011001100110000001100110012255555210011dddddddddddddd116611000000116610000700000070000
1000110000110001100011000011000110001100001100011000110000110001100085577775000110dddddddddddd0116661100001166610000703530070000
10000100001000011000010000100001100001000010000110000100001000011000575777750001100001dddd10000116666100001666610000700353070000
10000100001000011000010000100001100001000010000110000100001000011000057777750001100001dddd10000116666100001666610000700000070000
1000000000000001100000000000000110000000000000011000000000000001100000557750000110002855555200011dddddddddddddd10000070000700000
11000000000000111100000000000011110000000000001111000000000000111100000055000011110085577775001111dddddddddddd110000007777000000
001111000011110000111100001111000011110000111100001111000011110000111100001111000011575777751100001111dddd1111000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000057777750000000000dddd0000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000557750000000008888888800000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000008888888800000000000000000000
000dddd66dddd000000000000000000055555555000000000000000011111111dd1111111111111155555555d1111dd1d1111dd55555555555555555d5555555
0000dd6666dd00000000011111100000dddddddd00000000000000001111111111dd11111111111155555555d1111dddd1111dd55555555555555555d5555555
00000d6666d000000000000000000000dddddddd0000000000000000111111111111dd111111111155555555d1111dd5d1111dd55555555555555555d5555555
00000066660000000000000000000000d0000000000000000000000011111111111111dd1111111155555555d1111dd5d1111dd55555555555555555d5555555
000000799700000000000000000000000d0d00000000007777000000dddddddd111111111111111155555555d1111dd5d1111ddddddddddddddddd55d5555555
0000779aa977000001000000000000100d00d000000007444470000055555555111111111111111155555555d1111dd5d1111dddddddddddddddddd5d5555555
000799a99a997000010000000000001000d00000000074444447000055555555111111111111111155555555d1111dd5d1111dddddddddddddddddddd5555555
00079a9999a970000100000000000010dddddddd000074343447000055555555111111111111111155555555d1111dd5d1111dd1111111111111111dd5555555
00799a9999a997000100000000000010d1111dd500007443434700001111111d1111111100000000111111111111111dd1111dd111111111555555555dd1111d
00799a9999a997000100000000000010d1111dd500007444444700001111111d1111111100000000ddddddddddddddddd1111dd111111111dddddddd5dd1111d
00799a9aa9a997000100000000000010d11d1dd500000744447000001111111d11111111000000005555555555555555d1111dd111111111dddddddd5dd1d11d
007979a99a9997000000000000000000d1d11dd500000077770000001111111d11111111000000005555555555555555d1111dd1111111110000000d5dd11d1d
00079799999970000000000000000000d111ddd500000000000000001111111d11111111000000005555555555555555d1111dd1dddddddd0000d0d05ddd111d
00079979999970000000000000000000d1dd1dd500000000000000001111111d11111111000000005555555555555555d1111dd1d5555555000d00d05dd1dd1d
00007799997700000000011111100000dd111dd500000000000000001111111d11111111000000005555555555555555d1111dd1d555555500000d005dd111dd
00000077770000000000000000000000d1111dd500000000000000001111111d11111111000000005555555555555555d1111dd1d5555555dddddddd5dd1111d
0123456789abcdef5555bbbb33333333bbbb5555bbbbbbbbb33333333333333b0000000000000000000000000000000000000000000000000000000000000000
01555567eaa6ddef55bbb33333333333333bbb5533333333b33333333333333b0800080000000001100000000000010110100000000001100110000000000000
01111177666666665bb333333333333333333bb533333333b33333333333333b0080800000000000000000000000000000000000000000000000000000000000
00000077777777775b33333333333333333333b533333333b33333333333333b0008000000000000000000000000000000000000000000000000000000000000
0000000000000000bb33333333333333333333bb33333333b33333333333333b0080800000000000000000000000000000000000000000000000000000000000
0123456789abcdefb3333333333333333333333b33333333b33333333333333b0800080000000000000000000100000000000010010000000000001000000000
01155567e5a6ddefb3333333333333333333333b33333333b33333333333333b0000000000000000000000000000000000000000010000000000001000000000
0111117761666666b3333333333333333333333b33333333b33333333333333b0000000001000000000000100100000000000010000000000000000000000000
00000077707777770000000000000000000000000000000000000000000000000000000001000000000000100100000000000010000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000001000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000010010000000000001000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000010110100000000001100110000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8989898989898989898989898989898900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
889d878787878787878787878787878700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f2b9e3d3d3d3d3d3d3d3d842c8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f9f2a2a2a2a2a2a2a2a2a2a948a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a1f8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a8c8d8e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a9c989700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a9c989700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a9c989700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a9c989700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a8b9a9b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f0f2a2a2a2a2a2a2a2a2a2a1f8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f3f2a2a2a2a2a2a2a2a2a2a3e8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f3b2e2d2d2d2d2d2d2d2d2f3c8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f8a8a8a8a8a8a8a8a8a8a8a8a8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
898f8a8a8a8a8a8a8a8a8a8a8a8a8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a2a5a5a5a5a5a5a4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a6a3a3a3a3a3a3a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0650c1250c0250c0150c0550e1250e0250e0150c0650c1250c0250c0150c0550e1250e0250e0150c0650c1250c0250c0150c0550e1250e0250e0150c0650c1250c0250c0150c0550e1250e0250e015
0110000010552105311152111511000000000000000000000c5520c5310e5210e5110000000000000000000010552105311152111511000000000000000000000e5520e531105211051100000000000000000000
011000000c5040c5040c5450e5450e5450c5450c5050c5050c5050c505105451154511545105450c5050c5050c5050c5050c5450e5450e5450c5450c5050c5050c5050c5050e54510545105450e5450c5050c505
01100000105000e500105000c500105000c5000e500105000c5000e500105000c50010500105000e5000c500105000e5000c500105000c5000e500105000c5000e500105000c5000e500105000c5000e50010500
000300000575008750047500875005750097500475006750017500475005750077500070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400000011001110021100211003110041200612007120091200a1200b1300d1300e130101301213014140171401a1401c1401e140201502215025150281502a15010500105001050000500005000050000500
000400002d1502615023150201501e1501a140171401414011140101300e1300d1300c1300b1300a1200812007120071200512004110041100311003110021100111000100001000110000100001000010000100
000300001121013210142400f21010210122400c2100e21010240122101321015240082100b2100e24002200112100f2100b2400f2100d2100a2400f2100e2100d2400921008210052400f2100c2100a24000200
000100000b640056400c64007640086400564009640076400b6400a64004640036400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000076100d620176300a610106201a630046100b620166300e610146201b63000600316301b62005610346301f6200b6102d630116200361028630106200361000600006000060000600006000060000600
000300002e6502e650206501d650276502865032650316502a650286501e6501e650206502065026650266502a650276500060010600106001060010600106001060010600106001060010600106001060010600
000400001d770207702277024770277702a7702e770177701a7701f770247702a7702e77032770187701e7702277024770277702b7702e7703a7703d7503e7503e7503e7503e7503e7503e7503e7503e7503e750
0002000025245262452324525245242452524527245292452224523245201401f1401c1401b14015140141401714015140101400e14033100381003c1003e1000010000100001000010000100001000010000100
000200002a05024050210501b0501705014050110500f0500f0500f0500e0500e0500e0500e0500e050000000e0500f050110501205014050170501a0501d0502105024050280502b0502f050320503605039050
01200000105120e512105120c512105120c5120e512105120c5120e512105120c51210512105120e5120c512105120e5120c512105120c5120e512105120c5120e512105120c5120e512105120c5120e51210512
0120000010713000001d7130000010713117001171300000107130000011713000001071300000117130000010713000001171300000107130000011713000001071300000117130000010713000001171300000
000100002675026750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002403226032280322803226032280322b0322b03228032290322d0322d032290322b03230032300322b0322d03232032320322f0323003234032340323203234032370323703234032350323903239032
000800001c0311a03117031170311a0311803115031150311803117031130311303117031150311103111031150311103110031100311303111031100311003111031100310e0310e03105331053310533105331
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 01 42 43 44
03 01 02 03 44
02 41 42 43 44
03 0f 10 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
