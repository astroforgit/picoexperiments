pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


--------------------------------
--------- meowlionaire ---------
--                            --
-- the rich hoard their $$$$$ --
--      beyond our reach.     --
--  there's one cat with the  --
-- can-do attitude to take it --
-- back. take meowlionaire to --
--  the hoard in the sky and  --
-- bring back some $$$ to the --
--       cats of earth!       --
--                            --
--     eggnog games: 2019     --
--       eggnog.itch.io       --
--------------------------------
--------------------------------



-- hey, thanks for playing
-- meowlionaire! it's been nice
-- to put out a short, simple
-- game like this while
-- working on leaving the tree
-- for the last six months.
-- i hope you enjoy playing
-- this lil game. and remember,
-- if you're an actual
-- millionaire, don't forget to
-- contribute fairly to taxes
-- and charities instead of
-- hoarding your gold coins.
-- :)
--
-- - - andrew

cartdata("eggnog_meowlionaire_1")

function _init()
	music(-1)
	first_memory_check()
	intro_init()
	const_init()
	bg_init(0,0)
	objects_init()
	p_init(60,74,0)
	ui_init()
	bg_adjust()
	win_init()
	swap_palette("firstload")
end

menuitem(1,"music on/off", function() toggle_music() end)
menuitem(3,"reset memory", function() reset_memory() end)
menuitem(4,"swap palette", function() swap_palette("swap") end)

function _update()
	if state == "gameplay" then
 	p_update()
 	objects_update()
 	ui_update()
 	game_timer()
 	respawn_timer()
	elseif state == "win" then
		win_update()
	elseif state == "intro" then
		intro_update()
		objects_update()
	end
end

function _draw()
	cls(bgcol)
	pal(15,fgcol)
	foreach(dust,dust_draw)
	map(0,0,bg.x,bg.y,128,64)
	objects_draw()
	p_draw()
	ui_draw()
	if btn(5) then
		draw_quadrant_map()
	end
	if state == "win" then
		win_draw()
	elseif state == "intro" then
		intro_draw()
	end
	test_draw()
end

function test_draw()
end

-->8
-- player functions

function p_init(x,y,flash)
	p = {
	x = x,
	y = y,
	w = 6,
	h = 6,
	xd = 0,
	yd = 0,
	jump = -4.75,
	s = 17,
	sf = false,
	state = "air",
	respawn_timer = 0,
	flash = flash,
	quad = 1,
	showquad = true,
	jettimer = 90,
	fallproof = 0
	}
end

function p_update()
	p_input()	
	p_movement()
	p_collision()
	p_anim()
end

function p_draw()
	if flr((p.flash/2)%2) == 0 then
		spr(p.s,p.x,p.y-1,1,1,p.sf)
	end
end

function p_die()
	bg_init(respawn.bgx,respawn.bgy)
	objects_init()
	p_init(respawn.px,respawn.py,30)
	ui_init()
	item_reload()
	sfx(8)
end

--------------------------------
  --- detailed p functions ---
--------------------------------

function p_collision()
	-- set current quadrant for
	-- map purposes
	local x = flr((p.x-bg.x)/8)
	local y = flr((p.y-bg.y)/8)
	if x/16>0 and
				x/16<9 and
				y/16>0 and
				y/16<5 then
	p.quad = get_coin_quadrant(x,y)
	end
	-- check for floors
	local l = flr((p.x+2-bg.x)/8)
	local r = flr((p.x+5-bg.x)/8)
	local b =	flr((p.y+7-bg.y)/8)
	local t =	flr((p.y-bg.y+3)/8)
	local bl = mget(l,b)
	local br = mget(r,b)
	local tl = mget(l,t)
	local tr = mget(r,t)
	if fget(bl,0) or
				fget(br,0) then
		-- set gridshift. screen is
		-- offset by a couple pixels
		-- due to scrolling, so
		-- subtract the difference
		-- before calculating, and
		-- add it back in after
		-- snapping to the grid
		local gs = bg.y%8
		p.y = flr((p.y-gs)/8)*8 + gs +1
		if p.state != "jetpack" then
			p.state = "ground"
		end
		p.yd = 0
	else
		if p.state != "jetpack" then
			p.state = "air"
		end
	end
	if	fget(tl,0) or
				fget(tr,0) then
		local gs = bg.y%8
		p.y = flr((p.y-gs)/8)*8 + gs + 4
		p.yd = 0
		if p.state != "jetpack" then
			p.state = "roof"
		end
	end
	-- check for walls
	local l = flr((p.x+1-bg.x)/8)
	local r = flr((p.x+6-bg.x)/8)
	local b =	flr((p.y+6-bg.y)/8)
	local t =	flr((p.y+4-bg.y)/8)
	local bl = mget(l,b)
	local br = mget(r,b)
	local tl = mget(l,t)
	local tr = mget(r,t)
	if fget(bl,0) or
				fget(tl,0) then
		local gs = bg.x%8
		p.x = flr((p.x-gs)/8)*8 + gs +7
	end
	if	fget(br,0) or
				fget(tr,0) then
		local gs = bg.x%8
		p.x = flr((p.x-gs)/8)*8 + gs + 1
	end
	-- grab coins on all four
	-- corners of player
	if fget(bl,3) then
		coin_grab(l,b)
	elseif fget(br,3) then
		coin_grab(r,b)
	elseif fget(tl,3) then
		coin_grab(l,t)
	elseif fget(tr,3) then
		coin_grab(r,t)
	end
	-- death plane (bottom of map)
	if bg.y < -450 then
		p_die()
	end
	-- flicker if you just died
	if p.flash > 0 then
		p.flash -= 1
	else
		p.flash = 0
	end
end

function p_anim()
	if p.state == "ground" then
		-- walking animation
 	if btn(0) or
 				btn(1) then
 		if p.s < 21 then
 			p.s = 21
 		end
 		if p.s < 24.75 then
 			p.s += 0.25
 		else
 			p.s = 21
 		end
 		if p.s == 21 or
 					p.s == 23 then
 			sfx(1)
			end
 	elseif btn(2) then
 		p.s = 42
		elseif btn(3) then
			p.s = 41
 	else
 	-- idle animation
 		if p.s < 20.75 then
 			p.s += 0.25
 		else
 			p.s = 17
 		end
 	end
 elseif p.state == "roof" then
 	if p.s < 25 then
 		p.s = 25
 	end
 	if p.s < 28.75 then
 		p.s += 0.25
 	else
 		p.s = 25
 	end  
		if btn(0) or
					btn(1) then
 		if p.s == 25 or
 					p.s == 27 then
 			sfx(6)
 		end
		end
	elseif p.state == "air" then
		if p.s < 29 then
			p.s = 29
		end
		if p.yd+bg.yd < 0 then
			p.s = 29
		elseif p.yd+bg.yd < 2 then
			p.s = 30
		else
			if p.s < 34.75 then
				p.s += .25
			else
				p.s = 31
			end 
		end
	elseif p.state == "jetpack" then
		p.s = 35 
		-- add smoke and noise
		i = 3
		if p.sf == true then
			i = -3
		end
		for j = 1,2 do
			add(smoke,smoke_make(p.x+i+rnd(2)-1,p.y+rnd(2)-1,88+j))
		end
		sfx(6)	
	end
end

function p_input()
	-- count jump safety frames
	if p.state == "ground" then
		p.fallproof = 8
	else
		if p.fallproof > 0 then
			p.fallproof -= 1
		else
			p.fallproof = 0
		end
	end
	-- jump
	if btnp(4) and
--				p.state == "ground" then
				p.fallproof > 0 then
		p.yd = p.jump
		sfx(0)
		p.fallproof = 0
	end
	-- variable jump height
	if p.state != "jetpack" and
				p.yd < 0 and
				btn(4) == false then
		p.yd += 1.2
	end
	-- detatch from roof
	if btnp(4) and
				p.state == "roof" then
		sfx(2)
		p.yd = maxfall
	end
	-- stop jetpack
	if btnp(4) and
				p.state == "jetpack" and
				p.jettimer > 5 then
		sfx(2)
		p.jettimer = 90
	end
	-- if jet timer is up, end the
	-- jetpack behavior
	if p.jettimer > 89 and
				p.state == "jetpack" then
		p.state = "air"
		p.jettimer = 90
		gravity = .6
	end
	-- apply gravity
	if p.state != "roof" then
 	if p.yd < maxfall then
 		p.yd += gravity
 	else
 			p.yd = maxfall
 	end
	end	
end

function p_movement()
	-- jetpack behavior
 if p.state == "jetpack" then
		if p.yd>0 then 
			p.yd = -1
		end
		-- while timer's running,
		-- augment gravity
		p.jettimer += 1
 	gravity = -.045
 end
	-- input
	if btn(0) then
		p.sf = false
		if p.x > scroll.l then
			p.xd = -1
			bg.xd = 0
		else
			p.xd = 0
			bg.xd = 1
		end
	elseif btn(1) then
		p.sf = true
		if p.x < scroll.r then
	 	p.xd = 1
			bg.xd = 0
		else
			p.xd = 0
			bg.xd = -1
		end
	else
		p.xd = 0
		bg.xd = 0
	end
	-- move player
	p.x += p.xd
	if p.y > scroll.b then
		bg.yd = 2
		p.yd = 0
	elseif p.y < scroll.t then
		bg.yd = -3
		p.y+=3
	else
		bg.yd = 0
	end
	p.y += p.yd
	-- scroll background
	bg.x += bg.xd
	bg.y -= bg.yd
end

function player_detect(v)
	if p.x > v.x + v.w or
				p.x + p.w < v.x or
				p.y > v.y + v.h or
				p.y + p.h < v.y then
		return false
	else
		return true
	end
end

function respawn_timer()
	-- every 15 frames spent on
	-- the ground, set a respawn
	-- point
	if p.state == "ground" then
		if	p.respawn_timer < 15 then
			p.respawn_timer += 1
		else
			p.respawn_timer = 0
			set_respawn_location()
		end
	else
		p.respawn_timer = 0
	end
end

function set_respawn_location()
	respawn = {
	px = p.x,
	py = p.y,
	bgx = bg.x,
	bgy = bg.y
	}
end

function respawn_recall()
	p.x = respawn.px
	p.y = respawn.py
	bg.x = respawn.bgx
	bg.y = respawn.bgy
end
-->8
-- bg functions

function bg_init(x,y)
	bg = {
	x = x,
	y = y,
	xd = 0,
	yd = 0
	}
end

function bg_adjust()
	-- sets tile appearance based
	-- on surrounding tiles
	for x = 0,128  do
		for y = 0,64 do
			local current_spr = 0
			local tile = mget(x,y)			
			-- check if there is a tile
			if fget(tile,0) then
				current_spr = 64 			
				local left = mget(x-1,y)
				local right = mget(x+1,y)
				local top = mget(x,y-1)
				local bottom = mget(x,y+1)
				if fget(left,0) then
					current_spr += 1
				end
				if fget(right,0) then
					current_spr += 2
				end
				if fget(top,0) then
					current_spr += 4
				end
				if fget(bottom,0) then
					current_spr += 8
				end
 			mset(x,y,current_spr)
			elseif fget(tile,2) then
	 		add(jetpack,jetpack_make(x*8,y*8))
			elseif fget(tile,5) then
 			-- 2nd or 3rd playthrough
 			-- will use these instead,
 			-- to replace the tiles that
 			-- were removed after the
 			-- first playthrough
 			mset(x,y,4)
  		coincount += 1
  		set_quadrant_count(x,y)
			end
			-- both regular tiles and
			-- tiles that were picked
			-- up in previous run have
			-- been set as regular tiles.
			-- now, check if this quad
			-- is valid. if so, place the
			-- coin and add to the quad
			-- count. if not, convert the
			-- map point to tile 16 (an
			-- invisible coin marker)
			if fget(tile,3) then
				local quad_complete = dget(get_coin_quadrant(x,y))
				if quad_complete == 1 then
 				coincount += 1
 				set_quadrant_count(x,y)
				elseif quad_complete == 0 then
					mset(x,y,16)
				end
			end
		end
	end
end

function item_reload()
	-- sets tile appearance based
	-- on surrounding tiles
	for x = 0,128  do
		for y = 0,64 do
			local current_spr = 0
			local tile = mget(x,y)
			if fget(tile,2) then
	 		add(jetpack,jetpack_make(x*8+bg.x,y*8+bg.y))
	 	end
		end
	end
end

function get_coin_quadrant(x,y)
	-- quads are 16 tiles wide,
	-- 16 tiles tall
	local quadx = ceil((x+1)/16)
	local quady	= flr(y/16)
	return quadx + quady*8
end

function set_quadrant_count(x,y)
	-- add one value to the
	-- coinquad table
	local quad = get_coin_quadrant(x,y)
	coinquad[quad] += 1
end
-->8
-- object functions

function objects_init()
	smoke = {}
	jetpack = {}
	splode = {}
	dust = {}
	mapcoin_init()
	dust_dump()
end

function objects_update()
	foreach(smoke,smoke_update)
	foreach(jetpack,jetpack_update)
	foreach(splode,splode_update)
	foreach(dust,dust_update)
end

function objects_draw()
	foreach(smoke,smoke_draw)
	foreach(jetpack,jetpack_draw)
	foreach(splode,splode_draw)
	mapcoin_rotate()
end

function dust_dump()
	for x = 1,8 do
		for y = 1,8 do
			add(dust,dust_make(x*16+rnd(12)-6,y*16+rnd(12)-6,(rnd(3)+1)/2,(rnd(3)+1)/2))
		end
	end
end

function dust_make(x,y,xd,yd)
	local new_dust = {
	x = x,
	y = y,
	xd = xd,
	yd = yd
	}
	return new_dust
end

function dust_update(v)
	obj_scroll(v)

-- move dust
	v.x += v.xd
	v.y += v.yd
-- wrap around screen
	if v.x > 128 then
		v.x = 0
 elseif v.x < 0 then
 	v.x = 128
 end
 if v.y > 128 then
 	v.y = 0
 elseif v.y < 0 then
 	v.y = 128
 end
end

function dust_draw(v)
	pset(v.x,v.y,6)
end

function mapcoin_init()
	mapcoin = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	t = 1
	}
	-- grab coin anim data from
	-- spritesheet pixel by pixel
	-- and add it to a table
	for i = 1,4 do
		for x = 1,8 do
			for y = 0,7 do
				local pixelx = 23 + x + i*8
				local pixely = 48 + y	
				local pixelc = sget(pixelx,pixely)
				mapcoin[i][x+y*8] = pixelc
			end
		end
	end	
end

function splode_make(x,y,s)
	local new_splode = {
	x = x,
	y = y,
	s = s,
	smax = s+3.75
	}
	return new_splode
end

function splode_update(v)
	obj_scroll(v)
	if v.s < v.smax then
		v.s += 0.25
	else
		del(splode,v)
	end
end

function splode_draw(v)
	spr(v.s,v.x,v.y)
end

function mapcoin_rotate()
	-- rotate all coins on the map
	if mapcoin.t < 16 then
		mapcoin.t += 1
	else
		mapcoin.t = 1
		-- also snap the map sprite
		if p.showquad == true then
					p.showquad = false
		else
					p.showquad = true
		end
	end
	-- every four frames, swap out
	-- frame 4 with rotating coin
	-- sprite
	if mapcoin.t%4 == 0 then
		-- spin the ui icons
 	if ui.s < 103 then
 		ui.s += 1
 	else
 		ui.s = 100
 	end
		-- spin the bg coins
		local sprite = ceil(mapcoin.t/4)
	 for x = 1,8 do
	 	for y = 0,7 do
				local table_pix = x+y*8
				sset(31+x,0+y,mapcoin[sprite][table_pix])
	 	end
	 end
	end
end

function obj_scroll(v)
	v.x+=bg.xd
	v.y-=bg.yd
end

function obj_anim(v)
	if v.s < v.maxs+0.75 then
		v.s += 0.25
	else
		v.s = v.mins
	end
end

function jetpack_temp_grab(v)
	-- player grabs jetpack
	if player_detect(v) and
		v.state == "visible" then
		p.y -= 2
		sfx(5)
		v.state = "invisible"
		p.state = "jetpack"
		p.jettimer = 0
		-- add a grab effect
		add(splode,splode_make(v.x,v.y,108))
	end
	-- time until jetpack
	-- reappears. kills player's
	-- jetpack state when it
	-- reappears
	if v.state == "invisible" then
		if v.timer < 90 then
			v.timer += 1
		else
			for i = 1,5 do
				add(smoke,smoke_make(v.x+rnd(6)-3,v.y+rnd(6)-3,90))
			end
			v.timer = 0
			v.state = "visible"
		end
	end
end

function coin_grab(i,j)
	-- swap coin out for invisible
	-- uncollectable coin tile
	mset(i,j,16)
	-- if this is the first coin
	-- collected, kick off music &
	-- reset time if no quadrants
	-- have been completed
	if score == 0 then
		music(0)
		local quad_check = 0
	 for i = 1,32 do
			if dget(i) == 0 then
				quad_check += 1
			end
		end
		-- if no quads finished,
		-- reset the timer so the
		-- player doesn't have to
		-- reset manually.
		if quad_check == 0 then
			for i = 40,42 do
				dset(i,0)
			end
 		timer.second = dget(40)
 		timer.minute = dget(41)
 		timer.hour = dget(42)
		end
	end
	-- add to total score and
	-- subtract from coinquad
	-- table
	score += 1
	local quad = get_coin_quadrant(i,j)
	coinquad[quad] -= 1
	-- if this is the last coin
	-- in a quadrant, reward the
	-- player with some praise and
	-- a jingle
	if coinquad[quad] == 0 then
		dset(quad,0)
		ui.message = true
		ui.quadval = quad
	end
	add(splode,splode_make(i*8+bg.x,j*8+bg.y,80))
	-- win the game if this is
	-- the last coin on the map
	if score == coincount then
		music(-1)
		finaltime = tostr("~~~" .. timer.hour ..".".. timer.minute ..".".. timer.second .. "." .. timer.frame .. "~~~")
		state = "win"
		gravity = .6
		-- wipe all memory so the
		-- next round has quadrants
		-- and timer reset.

	end
	ui.timer = 60
	sfx(7)
end

function jetpack_make(x,y)
	local new_jetpack = {
	x = x,
	y = y,
	w = 8,
	h = 8,
	s = 96,
	maxs = 99,
	mins = 96,
	state = "visible",
	timer = 0
	}
	return new_jetpack
end

function jetpack_update(v)
	obj_scroll(v)
	obj_anim(v)
	jetpack_temp_grab(v)
end

function jetpack_draw(v)
	if v.state == "visible" then
		spr(v.s,v.x,v.y)
	end
end

function smoke_make(x,y,s)
	local new_smoke = {
	x = x,
	y = y,
	s = s
	}
	return new_smoke
end

function smoke_update(v)
	obj_scroll(v)
	if v.s < 95.75 then
		v.s += 0.25
	else
		del(smoke,v)
	end
end

function smoke_draw(v)
	spr(v.s,v.x,v.y)
end 
-->8
-- ui, constants

function ui_init()
	ui = {
	s = 103,
	quadval = 0,
	message = false,
	messagey = 28,
	messaget = 30
	}
end

function ui_update()
	-- raise up the message bar
	if ui.message == true then
		if ui.messagey > 0 then
			ui.messagey -= 1
		else
			if ui.messaget == 30 then
					sfx(10)
			end
  	-- count for 2 seconds
  	if ui.messaget > 0 then
  				ui.messaget -= 1
  	else
  		ui.messaget = 30
  		ui.message = false
  	end
		end
	-- return to offscreen
	elseif ui.message == false then
		if ui.messagey < 28 then
			ui.messagey += 1
		else
			ui.messagey = 28
		end
	end
end

function ui_draw()
	if score > 0 then
		spr(ui.s,5,5)	
		thicc_print(score.."/"..coincount,18,7,10,0)
		spr(ui.s-16,5,15)	
		thicc_print(timer.hour ..".".. timer.minute ..".".. timer.second,18,17,10,0)
		thicc_print("map —",99,7,10,0)
		if ui.messagey < 27  then
			local offset = 0
			if ui.quadval > 9 then
				offset = -2
			end
			rectfill(-1,112+ui.messagey,129,129,7)
			rect(-1,112+ui.messagey,129,129,0)
			thicc_print("quadrant ".. ui.quadval .." complete!",25+offset,118+ui.messagey,10,0)
		end
	end
end

function thicc_print(str,x,y,c1,c2)
	print(str,x-1,y,c2)
	print(str,x+1,y,c2)
	print(str,x,y-1,c2)
	print(str,x,y+1,c2)
	print(str,x,y,c1)
end

function const_init()
	state = "intro"
	gravity = .6
	maxfall = 2
	bgcol = 7
	fgcol = 0
	score = 0
	coincount = 0
	audio = true
	finaltime = "well done, our hero!"

	timer = {
		status = false,
		frame = 0,
		second = dget(40),
		minute = dget(41),
		hour = dget(42)
	}
	-- coinquad keeps tabs on
	-- which quads are complete
	-- as the game goes on.
	coinquad = {}
	for i = 1,32 do
		coinquad[i] = 0
	end
		
	scroll = {
	l = 35,
	r = 86,
	t = 35,
	b = 86
	}
	
	respawn = {
	px = 64,
	py = 70,
	bgx = 0,
	bgy = 0
	}
end

function toggle_music()
	if score > 0 then
 	if audio == true then
 		audio = false
 		music(-1)
 	else
 		audio = true
 		music(0)
 	end
	end
end	

function game_timer()
	-- run timer if you've
	-- collected at least 1 coin
	if score > 0 then
 	if timer.frame < 29 then
 		timer.frame += 1
 	else
 		timer.frame = 0
 		if timer.second < 59 then
 			timer.second += 1
 		else
 			timer.second = 0
 			if timer.minute < 59 then
 				timer.minute += 1
 			else
 				timer.minute = 0
 				timer.hour += 1
 			end
 		end
 		-- set timer to memory once
 		-- every 30 frames.
			dset(40,timer.second)
			dset(41,timer.minute)
			dset(42,timer.hour)
 	end
	end
end

function draw_quadrant_map()
	-- grid
	local w = 10
	local h = 8
	local xshift = 14
	local yshift = 40
	-- map bg
	rectfill(xshift+w-2,yshift+h-2,w*9+xshift+2,h*5+yshift+2,7)
	rect(xshift+w-2,yshift+h-2,w*9+xshift+2,h*5+yshift+2,0)
	for x = 1,8 do
		for y = 1,4 do
			local quad = x+((y-1)*8)
			local tx = x*w+xshift
			local ty = y*h+yshift
			rect(tx,ty,tx+w,ty+h,0)
			local count = coinquad[quad]
			if count > 0 then
				print(count,tx+2,ty+2,0)
			else
				rectfill(tx+1,ty+1,tx+w-1,ty+h-1,10)
			end
			-- draw current quadrant
			if p.quad == quad and
						p.showquad == true then
				rectfill(tx+1,ty+1,tx+w-1,ty+h-1,10)
				spr(40,tx+1,ty)
			end
		end
	end
end
-->8
-- victory functions

function win_init()
	win = {
	y = -128,
	s = 36,
	sf = false,
	catx = 60,
	caty = 73,
	timer = 150
	}
	
	wincoin = {}
	
	congrats = {}
	local str = "congratulations!"
	for i = 1,#str do
		congrats[i] = {
		x = i*5+21,
		y = 30,
		s = sub(str,i,i),
		v = (i/20) - 3.1,
		vy = 0
		}
	end
	
	march = {}
	for i = 1,10 do
		add(march,march_make(i*10+8,91))
		add(march,march_make(i*10+13,99))
	end
end

function win_update()
	foreach(wincoin,wincoin_update)
	wincat_update()
	foreach(congrats,congrats_update)
	foreach(march,march_update)
	win_screen_functions()
end

function win_draw()
	local q = win.y
	-- bg fill
	rectfill(20,20+q,108,108+q,7)
	-- stand
	rect(20,81+q,108,89+q,0)
	foreach(march,march_draw)
	foreach(wincoin,wincoin_draw)
	spr(win.s,win.catx,win.caty+q,1,1,win.sf)
	foreach(congrats,congrats_draw)
	print("you've redistributed\nthe hoarded wealth!!",25,43+q,0)
	-- score
	local timex = 65-#finaltime*2
	finaltime = tostr("~~~ " .. timer.hour ..".".. timer.minute ..".".. timer.second .. "." .. timer.frame .. " ~~~")
	print(finaltime,timex,83+q,0)
	-- border and mask
	rect(20,20+q,108,108+q,0)
	rectfill(0,0+q,19,128+q,7)
	rectfill(0,0+q,128,19+q,7)
	rectfill(109,0+q,128,128+q,7)
	rectfill(0,109+q,128,128+q,7)
	line(0,128+q,128,128+q,0)
	if win.timer < 50 then
		print("press Ž to play again",21,116+win.timer,0)
	end
end

function win_screen_functions()
	-- drop the screen
	if win.y < 0 then
		win.y += 6
	else
		win.y = 0
	end
	if win.y < 0 and
				win.y > -8 then
		music(63)
	end
	-- count until you can restart
	-- the game
	if win.timer > 0 then
		win.timer -= 1
	else
		win.timer = 0
	end
	if win.timer == 0 and
				btn(4) then
		reset_memory()
	end
end

function march_make(x,y)
	local palette = {4,5,6,9,10,13,14}
	local roll = ceil(rnd(7))
	local col = palette[roll]
	local new_march = {
	x = x,
	y = y,
	s = 21,
	maxs = 24,
	mins = 21,
	c = col
	}
	return new_march
end

function march_update(v)
	obj_anim(v)
	-- walk to the left
	if v.x > 11 then
		v.x -= 1
	else
		v.x = 110
	end
end

function march_draw(v)
	pal(15,v.c)
	spr(v.s,v.x,v.y+win.y)
	pal(15,0)
end

function congrats_update(v)
	-- move in a sin wave
	if v.v < 3 then
		v.v += .02
	else
		v.v  = -3
	end
	v.vy = sin(v.v)*2
end

function congrats_draw(v)
	thicc_print(v.s,v.x,v.y+v.vy+win.y,10,0)
end

function wincat_update()
	-- animate meowlionaire
	if win.s < 39.75 then
		win.s += 0.25
	else
		if win.sf == true then
			win.sf = false
		else
			win.sf = true
		end
		win.s = 36
	end
	-- throw coins
	if win.s == 36 or 
				win.s == 38 then
		local coindir = -1.5
		if win.sf == true then
			coindir = 1.5
		end
		add(wincoin,wincoin_make(win.catx+coindir*2,win.caty-5,coindir))
	end 
end

function wincoin_make(x,y,xd)
	local new_wincoin = {
	x = x,
	y = y,
	xd = xd,
	yd = -5,
	s = 100,
	maxs = 103,
	mins = 100 
	}
	return new_wincoin
end

function wincoin_update(v)
	obj_anim(v)
	-- apply gravity
	v.yd += gravity
	-- move coin
	v.x += v.xd
	v.y += v.yd
	-- clear coin when offscreen
	if v.y > 130 or
				v.y < -10 then
		del(wincoin,v)
	end
end

function wincoin_draw(v)
	spr(v.s,v.x,v.y+win.y)
end
-->8
-- intro functions

function intro_init()
	intro = {
	timer = 0,
	maxtimer = 90,
	catx = 70,
	caty = 60,
	wave = 0,
	rectsize = 86
	}
end

function intro_update()
	-- cat sine wave
	intro.wave = sin(intro.timer/20)*10
	-- add jetpack smoke
	if intro.timer < 50 then
 	add(smoke,smoke_make(66+intro.catx,intro.caty+intro.wave,88))
 	add(smoke,smoke_make(55-intro.catx,intro.caty-intro.wave,88))
	end
	if intro.timer == 50 then
		sfx(12)
		for x = 1,8 do
 		for y = 1,4 do
  		add(smoke,smoke_make(42+(x*4)+(rnd(4)-2),50+(y*4)+(rnd(4)-2),88+x/4+y/2))
 		end
		end
	end
	-- eggnog ding first frame
	if intro.timer == 0 then
		sfx(11)
	end
	-- run intro timer
	if intro.timer < intro.maxtimer then
		intro.timer += 1
	else
		intro.timer = 0
		smoke = {}
		state = "gameplay"
 	add(splode,splode_make(60,61,124))
	end
	-- bring in the cat
	if intro.timer > 20 and
				intro.timer < 50 then
		intro.catx -= 2
		sfx(6)	
	end
	-- shrink the border and show
	-- the game area
	if intro.timer > 50 then
		intro.rectsize -= 2
	end
end

function intro_draw()
	local q = intro.rectsize
	rectfill(64-q,64-q,64+q,64+q,7)
	rect(64-q,64-q,64+q,64+q,0)
	foreach(smoke,smoke_draw)
	-- before splosion, draw eggnog
	-- logo and flying cats
	if intro.timer < 50 then
		spr(104,49,57,4,2)
 	spr(35,64+intro.catx,intro.caty+intro.wave,1,1,false)
 	spr(35,57-intro.catx,intro.caty-intro.wave,1,1,true)
	end
end
-->8
-- memory functions

function swap_palette(i)
	-- swap the palettes if this
	-- was chosen through the
	-- menu. if it's the startup
	-- palette check, then skip
	-- this step.
	if i == "swap" then
		if dget(50) != 1 then
			dset(50,1)
		else
			dset(50,0)
		end
	end
	-- set the palette swap if
	-- it's turned on.
	if dget(50) == 1 then
		for i = 0,15 do
		pal(i, i+128, 1)
		end
	else
		for i = 0,15 do
		pal(i, i, 1)
		end
	end
end

function reset_memory()
	-- reset completed quadrants
	for i = 1,32 do
		dset(i,1)
	end
	--	reset timer in memory
	for i = 40,42 do
		dset(i,0)
	end
	_init()
end

function first_memory_check()
	-- check if all the coins
	-- have been collected when 
	-- game launches
	local j = 0
	for i = 1,32 do
		j += dget(i)
	end
	
	-- if they have, wipe the
	-- completed quadrants.
	if j == 0 then
		for i = 1,32 do
			dset(i,1)
		end
	end
end
__gfx__
0000000007777777000000000000000000ffff008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777777700000000000000000faaa7f08800008800000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777770000000007700770faaaaa7f8088880800000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777770000000007077070faaaaaaf8008800800000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777778787878707000070faaaaaaf8088880800000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077777777ffffffff07077070f9aaaaaf8000008800000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777777000ff000077007700f9aaaf08808080800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777700ffffff00700007000ffff008080808800000000000000000000000000000000000000000000000000000000000000000000000000000000
700000070000000000f0f00000f0f0000000000000f0f0000000000000000000000000000000000000000000000000000000000000f0f0000000000000000000
0000000000f0f0000fafaf000fafaf0000f0f0000fafaf0000f0f00000f0f00000f0f000000000000000000000000000000000000fafaf0000f0f00000000000
000000000fafaf000faaaf000faaaf000fafaf000faaaf000fafaf000fafaf000fafaf000a0a000000a0000000000a000000a0a00faaaf000fafaf0000f0f0f0
000000000faaaf000ffffff00ffffff00faaaf000fffff000faaaf000faaaff00faaaf000fff0a000fffa0a00a0afff000a0fff00fffff000faaaff00fafaff0
000000000ffffff00ffffff007ff7ff007ff7ff007ff7ff00ffffff00ffffff00ffffff007fffff007fffff00fff7ff00fff7ff007ff7ff00ffffff00faaaff0
0000000007ff7ff007ff7ff00ffffff00ffffff00ffffff007ff7ff007ff7ff007ff7ff00fff7ff00fff7ff007fffff007fffff00ffffff007ff7ff00ffffff0
000000000ffffff0000f00f0000f00f00ffffff0000f0ff00ffffff00ffff0f00ffffff00f00fff00f00fff00fff00f00fff00f0000ffff00ffff0f007ff7f00
70000007000f00f0000f00f0000f00f0000f00f0000000f000f000f0000f0000000f0f0000f000f00f000f00f00000f00f00000f0000f0f0000000000fffff00
00000000000000000000000000f0f00000f0f0000000000000f0f00000000000000000000000000000f0f0000000000000000000000000000000000000000000
00000f000000f00000000f000fafaf000fafaf0000f0f0000fafaf0000f0f00000000000000000000fafaf000000000000000000000000000000000000000000
000f0ff0000fff00000f0ff00faaaf000faaaf000fafaf000faaaf000fafaf00000fff0000f0f0000faaaf000000000000000000000000000000000000000000
00fafaf000fafaf000fafaf00ffff7f00fffff000faaaf000fffff000faaaf0000fafaf00fafaf0007ff7ff00000000000000000000000000000000000000000
00faaaf000faaaf000faaaf007f7f77f07ff7ff00ffffff007ff7ff00ffffff000faaaf00faaaf000ffffff00000000000000000000000000000000000000000
00fffff000fffff000fffff00fffff7f0ffffff007ff7ff00ffffff007ff7ff000fffff00ffffff00ffffff00000000000000000000000000000000000000000
007ff7f000f7ff70007ff7f0000ffff0000f0ff00ffffff0000f0ff00ffffff0007ff7f007ff7ff0000f00f00000000000000000000000000000000000000000
00fffff000fffff000fffff00000f0f0000000f0000f00f0000000f0000f00f000fffff00ffffff0000f00f00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ff00ff00ff00ff00ff00ff00ff00ff00f7777f00f7777f00f7777f00f7777f00ff00ff00ff00ff00ff00ff00ff00ff00f7777f00f7777f00f7777f00f7777f0
f77ff77ff77ff77ff77ff77ff77ff77ff777777ff777777ff777777ff777777ff77ff77ff77ff77ff77ff77ff77ff77ff777777ff777777ff777777ff777777f
f777777f7777777ff777777777777777f777777f7777777ff777777777777777f777777f7777777ff777777777777777f777777f7777777ff777777777777777
0f7777f0777777f00f777777777777770f7777f0777777f00f777777777777770f7777f0777777f00f777777777777770f7777f0777777f00f77777777777777
0f7777f0777777f00f777777777777770f7777f0777777f00f777777777777770f7777f0777777f00f777777777777770f7777f0777777f00f77777777777777
f777777f7777777ff777777777777777f777777f7777777ff777777777777777f777777f7777777ff777777777777777f777777f7777777ff777777777777777
f77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff77ff777777ff777777ff777777ff777777ff777777ff777777ff777777ff777777f
0ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00f7777f00f7777f00f7777f00f7777f00f7777f00f7777f00f7777f00f7777f0
00000000000000000000000000000000ffffffff0ffffff000ffff000ffffff0000000000000000000000000009aa900009a0000009a6000000a600000000000
000ff0000000000000000000000000000f7777f000f77f00000ff00000f77f000000000000000000000990000a0000a00a0660a0000006000000000000000600
00fa7f00000ff0000000000000f00f0000faaf0000faaf00000ff00000faaf000000000000099000009aa9009006600900600609060000090000000006000000
0faaa7f000fa7f00000ff00000000000000ff000000ff000000ff000000ff000000aa000009aa90009a66a90a060060a0600006a6000000a6000000a00000000
0f9aaaf000f9af00000ff00000000000000ff000000ff000000ff000000ff000000aa000009aa90009a66a90a060060aa6000060a0000006a000000600000000
00f9af00000ff0000000000000f00f0000f77f0000f77f00000ff00000f77f000000000000099000009aa9009006600990600600900000600000000000000060
000ff0000000000000000000000000000faaaaf000faaf00000ff00000faaf000000000000000000000990000a0000a00a0660a0006000000000000000600000
00000000000000000000000000000000ffffffff0ffffff000ffff000ffffff0000000000000000000000000009aa9000000a9000006a9000006a00000000000
0ff00ff000f00f00000ff00000f00f0000ffff00000ff000000ff000000ff00000fffffffffffffffffffffffffff00000000000000000000000000000000000
f77ff77f0f7ff7f000f77f000f7ff7f00faaa7f000fa7f0000fa7f0000fa7f0000f7777777777777777777777777f00000ffff00000000000000000000000000
f777777f0f7777f000f77f000f7777f0faaaaa7f0faaa7f000fa7f000faaa7f000f7fff77ff77ff7ff777ff77ff7f0000f7777f0000ff0000000000000f00f00
f778877f0f7877f000f77f000f7787f0faaaaaaf0faaaaf000faaf000faaaaf000f7f777f777f777f7f7f7f7f777f0000f7887f000f99f00000ff00000000000
f777777f0f7777f000f77f000f7777f0faaaaaaf0faaaaf000faaf000faaaaf000f7ff77f777f777f7f7f7f7f777f0000f9999f000faaf00000ff00000000000
f99ff99f0f9999f000f99f000f9999f0f9aaaaaf0f9aaaf000f9af000f9aaaf000f7f777f7f7f7f7f7f7f7f7f7f7f0000faffaf0000ff0000000000000f00f00
faf00faf0faffaf000faaf000faffaf00f9aaaf000f9af0000f9af0000f9af0000f7fff7fff7fff7f7f7ff77fff7f00000f00f00000000000000000000000000
0f0000f000f00f00000ff00000f00f0000ffff00000ff000000ff000000ff00000f7777777777777777777777777f00000000000000000000000000000000000
00fff000ffff00fff00f000f0f0000f00fff000f00f00fff00f00fff000ffff000f7777ff7fff7fff7fff77ff777f00000000000000000000000000000000000
0faaaf0faaaaffaaaffaf0fafaf00faffaaaf0faffaffaaaffaffaaaf0faaaaf00f777f777f7f7fff7f777f77777f0000ffffff0000000000000000000000000
fafafafafffffafffafaf0fafaf00fafafffafafafafafffafafafffafaffff000f777f777fff7f7f7ff77fff777f0000f0000f000ffff000000000000f00f00
fafafafaaaf0faf0fafafffafaf00fafaf0fafafafafaaaaafafaaaaafaaaf0000f777f7f7f7f7f7f7f77777f777f0000f0000f000f00f00000ff00000000000
fafafafaff00faf0fafafafafaf00fafaf0fafafafafafffafafafafffaff00000f777fff7f7f7f7f7fff7ff7777f0000f0000f000f00f00000ff00000000000
fafafafafffffafffafafafafaffffafafffafafafafaf0fafafaffaffaffff000f7777777777777777777777777f0000f0000f000ffff000000000000f00f00
fafafaffaaaaffaaaf0faaaf0faaafaffaaaffaffaffaf0fafafaf0faffaaaaf00fffffffffffffffffffffffffff0000ffffff0000000000000000000000000
0f0f0f00ffff00fff000fff000fff0f00fff00f00f00f000f0f0f000f00ffff00000000000000000000000000000000000000000000000000000000000000000
00000000100010000000000000004040404040000000000000004000000000001000000010404000101010101000104010101010000000004040404040404040
40000000000000000000101040104040104040404000000000000000001010101040101010100000000010000000100000100000401010404040100000000000
00000000000000000000000000000000000000000000000000400000000000001000000000404040404040404040104040404040000000004000000000000000
40000000000000000000001040104040104010404010000000000000101040404040404040101000000010000000004000000040404040401010100000000000
00000000000000000000000000100000000000000000000000400000000000001000000000104010000000100000101000404040100000004000404040404000
40000000000000000000001040101010104010104000000000000010101040404040404040101010000010000000001000000000001010401000000000000000
00000000000000000000000000101000000000000000000000000000000000001000000000004000000000101000001000401040100000004000000000000000
40000000000000000000001040404040404040404000000000000010404000000010000000104040000010100000000000000000004040401000000000000000
00000000000000000000000000101010000000000000000000000000000000101000000000001000000010101010000000404040000000000040404040404040
00000000000000000000000000000000001000001000000000000010401000400000004000104010000000100000000000000000101010101000000000000000
00000000000000000000000010101010100000000000000000000000000010100000000000000000000000101010101000100000000000000040000000000040
00000000000000000000000000000000000000000000000000000010401000100040001000104010000000101010101010101010100000000000000000000000
00000000000000101010101010404040101010100000003000000000000010000010101010101010101000404040404000000000000000000040000000000040
00000000000000000000000000000000000000000000000000000010101000000010000000101010000000404040404040404040400000000000000000000000
00000000000000104040404040404040404040100000001000000010101010000040404040404040404000000000001010000000000000000000404040404000
00000000000000001010101010100000000000000000000000000000000000000000000000000000000000100000000000000000100000003000000000000000
00001010101010104010404010101010104040100000101010000010404040404010000010101010101000000000000000000000000000000000400000004000
00000000000000101040404040100000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000
00001040404040104010404040404040404040100000000000000010401010101010000040404040404000000000100000000000000000000000004040400000
00000000001010104040101040400000000000000000000000000000000000000000000000000000000000000000000000000000000040404040400000000000
00001040404040104040401040101010404040100000000000000010404040404040000000000000000000000000004040000000000000000000004030400000
00000000001040404010404040100000104010404040000000000000000000000000000000000000000000000000101010000000000010104010100000000000
00001040101010101010101010101010104040101000000000001010100000001010001010404010100000000000001010000000000000000000104010401000
00000000101040101010401010100000101010404010000000404040404040400000000000000000000000000000004000000000000000404040000000000000
00001040000000000000000000000000104010101000000000001010000000404010400010404010004000000000000000000000000000000000104040401000
00000000104040104040404040100000104040404010000000404040404040400000000000000000004040400000000000000000001010101010101000000000
00001010000000000000000000000000000000101000000000001010000000404040400010101010001000000000000000000000000000000000101010101000
00000010104010104010104010100000101040401010000000404040404040400000000000000010101010101010000000000000101040404040401010000000
00000000000000100000000000000000001000101010000000000010000010404040104040404040400000000000000000000000000000000000404040404000
00000040404040404040404010000000001040401000000000404040404040400000000000001010404040404010100010101010104040404040404010000000
00000000000010101000000000000010000000101010000000000010404010101010104040000000100000000000000000000000000000000000100000001000
00000010104010101010104010000000001010101000000000000000000000000000000000101040401040104040101010404040101010404040101010000000
00001010101010101010000000000000000000101010000000000010104040404040404010000000004000000000000000000000000000000000000000000000
00000000104040404040404010000000000000000000000000000000000000000000000000404040401040104040404010401040401040404040401040400000
00101040404040404010100000000000000000101010100000000000101010000000101010000000001000000000000000000000000000000000000000000000
00000000001040404040101010000000000000000000000000000000400000000000000000000010401010104010000010404040401040101010401040400000
00104040404040404040100000000000000000101010100000000000101000000000000000000000000000000000000000000000000000000000000000000000
00000000001010404010101000000000000000000000000000004000300040000000000000000000001010101010100010404010101040404040401040400000
00104040404040404040101000101010101010104010100000000000101000000000000000000000000000000000000000000000000000000000000000000000
00000000000010101010000000000000000000000000000000001040104010000000000000000000004010404040404010404040401040404040401010100000
00101010404010101010101010104040404040404010100000000010101000000000000000000000000000000000000000000000000000003000001010100000
00000000000040404040000000000010401000000000000000400000100000400000000000000000104040404040104010101010001040404040404010000000
00001040404040404040404040404040000000401010400000001010404000000000000000001010101000101010101010101000000000001010101000000000
00000000000000000000100000001010401010000000000000100000000000100000000000000000101040404010404040101000001040404040404010000000
00001040104010401040104010101040404040401040400000001040401010000000000000001040401040401040401040401010000000101040404040101000
00000000000000000000000010000010401000000000000000004040404040000000000010401000001040404010401010100000101010404040404040000000
00001040404040404040404010404040104040401010400000001040404010000000000000101040101010404040401040404010100010104040104040404040
00000000000000000000000000000010401000000000000040001000100010004000001010001010004040101010404010000000000010104040404010000000
00001040401040104010404010401010104040404010100000001010404010000000000000101040404010404010404040104040101010404010101040101010
00000000000000000000000000000010401000000000000010004000100040001000000000000000001040404010104010401040000000101040404010000000
00001010404040404040404010404040404040104010000000001040401010000000000010101010404010104010404010101040404040401010101010101040
40000000000000000000000000000010401000000000000000400000100000400000000000000000101040104040404010401010000000401040404040000000
00000010101010101040101010400000404040104010000000001040404000000000000010404040401010101010101010401040000000000000101040404040
10004000000000000000000000000010401000000000000000100000000000100000000000000000101000100010100010404040001010401010404040000000
00000000400000000040404040400040401010100000000030001010101000000000000010404040404010000000104040401010004040404000100040404040
00001000000000000000000000000040404000000000000000004000400040000000000000000000000000100010000010404040001040404010404040000000
00000000100000000010404040404040101000000000001010101000000000000000000010104040100000000000000010404000001040401000000040101040
00400000000000000000000000000010101000000000000000101040104010100000000000000000000000100010001010404040101040104010404040000000
00000000004000000010104010101040401000000000404040404040000000000000000000101040100000000000000010101000001010101000404010101010
00100000000000000000000000000040404000000000000000000040104000000000000000000000000000000010000000000010101010101010101040300000
00000040001000000000104040404040101000000000100000000010000010000000100000001010101000004000001010001010004040404000101010000000
00000000000000000000000000000000000010001000100010000000000000001000000000000000000000000000001010100000000000404040401010100000
00000010000000000000101000000010100000000000000000000000000000001000000000000000000000001000000000000010100000000010100000000000
00000000000000000000000000000000000000000000000000001000000010000000000000000000000000000000000000000010000000000000000000100000
__gff__
0001020408100000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101000000000000000000000000000000000000000008080808000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000404040000000000000000000001010100000000000000000000000000000000010101010000000100000100000100000000000000000000000000000000000000000000010101010101000000
0000000000000000000000000000000000000000000000000000000001000004000000010100000000000000000000000000000104010400000000000001010101010101010100000000000000000000000001040404040100000000000000010100000101010104010101010401010101000000000001010404040401010001
0000000000000000000000000000000000000000000000000000000000000001000004000004000000000000000000000000000404040404000000000001040404040404040100000000010101000000000001040404040100000000000000000000000104040404010404040401040404000001000401040404040404010401
0000000000000000000000000000000000000000000000000000000000000000000001000000000004040404040404040400000401040104000000000001000004040400000100000001010401000000000001010404040100000000000000010000000101010404010401010401040101000000000401040404040404040401
0000000000000000000000000000000000000000000000000000000000000000000004000004000004040401010404040400000004040404040000040101010000040000010101000001040401010000000004040404040100000000000000010000000104040404010404010401040401000000000401040104040104040101
0000040470717273747576770404000000000000000000000000000000000000000001000001000004040101040404010400000004010401040000040100000000000000000001010101010404010000000001010101010000000000000000010100000101010104010101010401010101000000000101040101010104010101
0000000000000000000000000000000000000000000000040404000000000000000000000000000004010101010104040400000004040404040400010104010100000001010400000100000401010100000004040404040000000000000000000000000404040404040404040404040404000000000104040401040404040401
0000000000000000000000000000000000000000000004000000040000000000000000000000000004040404040404040400000000040104010400010404040101040101040401000000010404010100000004040404040000000000000000000001000104040104040101040401010101000100000101040401040401040401
0000000000000000000000000000000000000000000404000000040400000000000000000000000004010104040101010400000004040404040400010404010101040101010101010100010101010101000001000000010000000000000000000000000101040104010000010401040404000000000404040401040101010401
0000000000000000000000000000000000000000000404040004040400000000000000000000000004040404040104040400000004010401040000010404040101010104040404040100000001010401000000000000000000000000000001040100000101010104010000010401040101000001000101010101010101010401
0000000001010101010101010000000000000000040401040004010404000000000000000000000004040101010101040100000004040404040000010104040000000104040404040100000000040401010000000000000000000000000001040100000104010104010000010401040401000001000404040401040404040401
0000000000010004040001000000000000000404040004040404040004040400000000000000000004040401010404040400000401040104000000010404040101000104040404040101000001040101010000000000000000000000000001040101000104040104040101040401010101000101000404040401010404040401
0000000000000001010000000000000000000104040404010401040404040101000000000000000004040404040404010400000404040404000000010101010100000104040404040101010000000000010100000000000000000000000001040100000000000000000000000000000000000000000000000000010101010000
0000000000040000000004000000000000000004040004040404040004040001000000000000000001000100000100010100000104010400000000000000010000010104040404040100000000000000000101000101010101010000000001040104010001000000000000000000000000010000000000000000000000000000
0000000000040000000004000000000000000004010001040404010001040001000000000000000000000000000000000000000000000000000000000000010000000004040404040000010000010101040101000104040404010000000001040100010101000000000000000000000100000000000000000000000000000000
0000000004000000000000040000000000000000000004040404040000000001000000000000000000000000000000000000000000000000000000000000010404010100010301000000010100000004040404040104040104010100000001040404040401000101010101010101000000000000000000000000000000000000
0000000004000004040000040000000000000000000001040404010000000001010000000000000001010101010000000000000000000000000000000000010104040100010101010100000000000004010401040104040404040100000001040404040401000000000000000000000000000000000000000000000000000000
0000000004000004040000040000000000000000000001040304010000000000010000000000000001040404010000000000000000000000000000000000000104040100000004040100000101010104040404040404010101040100000001040404040401000000000000000000000000000000000000000000000000000000
0000000004000000000000040000000000000000000001010101010000000000010000000000000101040404010100000000000000000000000000000000000101040101010104040000010104040101010401040104040404040000000001010101010401000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000010100000000000104040404040100000000000000000000000000000000000001040000000004040000010404040404010101040404010101010000000000000000010401010104010101010100000000000000000000000000000000000000
0000000000030000000000000000000000000000000000000000000000000000010100000000010104040404040101000000000000000004040400000000000101010101010104040001010404040404040104040404010404040404000000000000010401040101010404040100000000000000000000000000000000000000
0000000001010101010101010101010404040401000000000000000000000000010101000000010404040404040401000000000000040000000000040000000104040404040101010101040401040104040101010104040404040104000000000000040404040404010404040400000000000000000000000000000000000000
0000010101040101010404040404040404040101000101010101010100000000010404040401010404040404040401010000000000000004040400000000000104040404040104040404000000000000000000000101010104040404000000000000010404010104010104040100000000000000000000000000000000000000
0000010404040404010101010104010101010100000104040404040100000400010401040401040404040404040404010404000004000400000004000400000104040401040404040404000000010000000000000000000101000000000000000000010404040104040101010100000000000000000000000000000000000000
0000010404040404010404000104010004040400010104010101010100000400010401010101010104040404040101010101010004000400030004000400000101010101010101010101000000000000000000000000000000000000000000000000010104040104040404040400000000000000000000010104010100000000
0000000000010101010404000101010004040400010404000000000000040000010401040404040400040404000404040404010004000400000004000400000404040404040404040401010001000000000000000000000000000000000000000000000104010104040404040100000000000000010101010404040401000000
0000000000000000040404000000000001010101010101000000000000040000010401000000000000000400000000000000010000000004040400000000000000000000000000000000010000000000000000000000000000000000000000000000000104040104010404040101000000000001010101040404010401000000
0000000001000000010101000000000001040400000000000100000004000000010401000000000100000300000100000000010000040000000000040000000000000000000000000000010000010000000000000000000000000000000000000000000104010101010401010101010003000101010404040101010401000000
0000000000000000000000000001010101010100000000000400000004000000010404000000000000010101000000000000010000000004040400000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000010001040401010101010101040401010104040401000000
0400040000000000040004000001040404040400000001040100000400000000010101000000000000000400000000000000010000000000000000000000000000000000000000000000010000000101000000000000000000000000000000000000000000000000010001040404040401040404040401040404040404000000
0400040004000400040004000101040404040400000004000000000400000000010100000101010104040104040100010000000000000000000000000000000000000000000000000000010004040104040104040400000000000000000000000003000000000000000001010000000101010000010401040401010104000000
0100010004000400010001000001010101010100010401000000040000000000010100040404040404010101040404040404000000000000000000000000000000000000000000000000010004040404040101040100000000000000000000010101010100000000000001000000040000040000040401010101010100000000
__sfx__
01020000243402b341000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000c52000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001f34024341000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001844000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001844000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000c2401f2400c2400c00018000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001844000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002b44030440304000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000014460104600e4600c460180000c00014400104000e4000c400000000000014400104000e4000c40000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001d2701030009300292752b2752d2752e270247002d2700000018270050001d27000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e0000292752b2752d2752e275292052b2052d2052e205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000303703c3703c3503c33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d4730c3000c0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003057300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000000455000003050530505305050000000000000000000000000000000c6000045500455000000045500000000000000030505305050000000000000000000000000000000000000455000000040500000
011400000045500000305053056530665000000000000000000000000000000004553065500455000000045500000000000000030565306650000000000000000000000000004550040530655000000040500000
0114000000455000003050530565306650000000000000000000000000000000c6000045500455000000045500000000000000030565306650000000000000000000000000000000000000455000000040500000
01140000285702450028500245002857029570245002b57024500245002450024500245002450029570285702d5702450024500245002d5703457024500325702450024500245002450024500245003757026500
0114000034570355702d50035570325702f5002d5702f57027500245002450024500275002f5702d5702b57024500245002450024500135002b570245002b5702850024500245002450024500295702857026570
0114000034570355702d50035570325702f5002d5702f57027500245002450024500275002f5702d5702b57024500245002450024500135002b57024500305702850024500245002450024500295002b57026500
01140000295700050000500115002957028570265002657024500245002450024500245002657028570295702857024500245002b57028570245702f5702d5702650024500245002450000500005003457000000
0114000035570300000000000000000000000000000000000000000000000000000035570365703750037570305003050030500305003050030500305003050030500305003050030500375702b5703050030500
011400000032000320003200032300300003000030000300003250030000320003000c3250c325003000032000320003200032000323003000030000300003000032500300003200030013325133250030000320
01140000102300c500102000c20010230112300c200132300c2000c2000c2000c2000c2000c2001123010230152300c2000c2000c20015230102300c2000e2300c2000c2000c2000c2000c2000c2001323026500
01140000102301123015200112300e2301720015230172300f2000c2000c2000c2000f2001723015230132300c2000c2000c2000c20013200132300c20013230102000c2000c2000c2000c20011230102300e230
01140000102301123015200112300e2301720015230172300f2000c2000c2000c2000f2001723015230132300c2000c2000c2000c20013200132300c2000c230102000c2000c2000c2000c20011200132300e200
01140000112300c2000c2001120011230102300e2000e2300c2000c2000c2000c2000c2000e2301023011230102300c2000c20013230102300c23017230152300e2000c2000c2000c2000c2000c200102300c200
01140000112300c2000c2000c2000c2000c2000c2000c2000c2000c2000c2000c200112301223013200132300c2000c2000c2000c2000c2000c2000c2000c2000c2000c2000c2000c20013230132300c2000c200
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000182701a270182701d270000001d2701f2701d2701f270212701f27024270000000000000000000002427524270000002d27000200292702b270002002927000200002000020035270000000000000000
011000000c3530c353376550c303000000c35337655000000c3530c353376550c303000003765537655376550c3530c353376550c303000000c35337655000000c3530c303376550c303376550c3033760500000
0110000005450114500040011450054000040005450004000c45000450004000045000400004000c450004000c45007450004000745007400004000c450004000545000400004500040005450004000040000400
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400003035024351243500035100300003000030000300000000c0000000000000003502435124350303513035124500000000000000000000000000000000243510c000243510e30000000243510000000000
011400002635002351183002835000300003002635002351000000c000000000000026350283502430029350303002450000000130002b3552b350130002b350243530c000243510e30000000243510000000000
011400000b45500000305052f565306650000000000000000000000000000000b45530665094550000007455000000000000000134553066500000000000000000000000000e4550040530655000000040500000
011400002435026350100002835000000000000000000000293002830000000263000000000000000000000028350263502400023350000002330000000233052330523305233051000023305243502635028350
0114000029350283502b3002b3502430024300243002430024300243002430024300243002430024300243002d3502b3502430026350243002430024300243002430024300243502430023350243502635024300
011400000045500000305053056530665000000000000000000000000000000004553065500455000000045500000000000000037565306550000000000000000000000000074550040530655000000040500000
01140000074550000030505375653066500000000000000000000000000000007455306550745500000074550000000000000003b565306550000000000000000000000000074550040530655000000040500000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 13 42 43 44
00 13 42 43 44
01 14 42 43 44
00 14 42 43 44
00 14 16 43 44
00 14 17 43 44
00 14 16 43 44
00 14 18 43 44
00 14 19 43 44
00 14 1a 43 44
00 14 42 1b 44
00 14 42 1b 44
00 14 16 1b 1c
00 14 17 1b 1d
00 14 16 1b 1c
00 14 18 1b 1e
00 14 19 1b 1f
00 14 1a 1b 20
00 14 42 43 44
00 14 42 43 44
00 14 28 43 44
00 2a 29 43 44
00 14 28 43 44
00 2a 29 43 44
00 2d 2b 43 44
00 2e 2c 43 44
00 2d 2b 43 44
02 2e 2c 43 44
00 14 28 43 44
00 2a 29 43 44
00 14 28 43 44
02 2a 29 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 23 24 25 44
