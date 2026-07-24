pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- pico pico micromix
-- by starsculptor


scrn = {}

--start the game
function _init()
	cls()
 show_title()
end

--put like this for states
function _update()
	scrn.upd()
end

--put like this for states
function _draw()
	scrn.drw()
end

--when we want to go to title
function show_title()
	scrn.upd = update_title
	scrn.drw = draw_title
	
	--variables for colors for 
 --candy text
 message_c1 = 8
 message_c2 = 9
 message_c3 = 10
 message_c4 = 11
 message_c5 = 12
 message_c6 = 13
 message_2frame = 1
 
 y1 = 45
 y2 = 54
 move_down = y2+8
	wait = 25
	
	bg_move = 0
	
	menuitem(1)
	menuitem(2)
end

--when we want to go to menu
function show_menu()
	scrn.upd = update_menu
	scrn.drw = draw_menu

	color_cycle = 0
	
	--1 = mega man x3
	--    blast hornet's theme
	--2 = sonic advance 3
	--    twinkle snow zone
	--3 = guilty gear x2
	--    blue water blue sky
	selected = 1
	
	--for the background
	bgy=0
	
	--for the fancy background
 --that plays beneath the arrows
 bg = 1
 
 bgcol1=7
 bgcol2=12
 bgcol3=13
 bgcol4=1
 
 menupart = 1
 difficulty = 1
 
	menuitem(1)
	menuitem(2)
end

--when we're in the title
--a button press to exit title
function update_title()
	if wait == 0 then
		if (btnp(4) or btnp(1,4) or btnp(5) or btnp(1,5)) then
		 show_menu()
		 cls()
		end
	end
	  
	color_message()
	
	bg_move += 1
	if bg_move >= 32 then
		bg_move = 0
	end
end

--what to be drawn in the title
function draw_title()
	--map(16, 1, 0, 0, 17, 17)
	cls()
	if move_down > 0 then
		pal(2,5)
		sspr(48,41,7,7,34,y1-move_down)
		sspr(43,34,3,7,42,y1-move_down)
		sspr(41,41,7,7,46,y1-move_down)
		sspr(34,34,8,7,54,y1-move_down)
		sspr(48,41,7,7,66,y1-move_down)
		sspr(43,34,3,7,74,y1-move_down)
		sspr(41,41,7,7,78,y1-move_down)
		sspr(34,34,8,7,86,y1-move_down)

		sspr(47,34,8,7,35,y2-move_down)
		sspr(43,34,3,7,44,y2-move_down)
		sspr(41,41,7,7,48,y2-move_down)
		sspr(34,41,7,7,56,y2-move_down)
		sspr(34,34,8,7,64,y2-move_down)
		sspr(47,34,8,7,73,y2-move_down)
		sspr(43,34,3,7,82,y2-move_down)
		sspr(55,43,7,7,86,y2-move_down)
		pal(2,5)
		move_down -= 1
	else
		title_bg()
		if wait > 0 then
			wait -= 1 end
		ssprc(48,41,7,7,34,y1,7,7,6)
		ssprc(43,34,3,7,42,y1,3,7,6)
		ssprc(41,41,7,7,46,y1,7,7,6)
		ssprc(34,34,8,7,54,y1,8,7,6)
		ssprc(48,41,7,7,66,y1,7,7,6)
		ssprc(43,34,3,7,74,y1,3,7,6)
		ssprc(41,41,7,7,78,y1,7,7,6)
		ssprc(34,34,8,7,86,y1,8,7,6)

		ssprc(47,34,8,7,35,y2,8,7,6)
		ssprc(43,34,3,7,44,y2,3,7,6)
		ssprc(41,41,7,7,48,y2,7,7,6)
		ssprc(34,41,7,7,56,y2,7,7,6)
		ssprc(34,34,8,7,64,y2,8,7,6)
		ssprc(47,34,8,7,73,y2,8,7,6)
		ssprc(43,34,3,7,82,y2,3,7,6)
		ssprc(55,43,7,7,86,y2,7,7,6)
		
		--map(16, 1, 0, 0, 17, 17)
		if wait == 0 then
			printb("press z to start",33,105,7)
		end
	end
end

function title_bg()
	for xx=0,6 do
		for yy=0,6 do
			sspr(55,50,16,16,-32+xx*32-bg_move,-32+yy*32+bg_move,32,32)
		end
	end
end

--when we're in the menu
--a button press to exit menu
function update_menu()
	if btnp(4) and menupart == 1 then
	menupart=2
	difficulty=1
	elseif btnp(5) and menupart == 2 then
	menupart=1
 elseif btnp(4) and menupart == 2 then
	run_game() end

	----difficulty
	--if (btnp(2) or btnp(2,1)) then ddiff = 2 end
	--if (btnp(3) or btnp(3,1)) then ddiff = 1 end

	--track
	if menupart == 1 then
		if (btnp(0) or btnp(0,1)) then
			selected -= 1
		end
		if (btnp(1) or btnp(1,1)) then
			selected += 1
		end
	end
	if menupart == 2 then
		if (btnp(0) or btnp(0,1)) then
			difficulty = 1
		end
		if (btnp(1) or btnp(1,1)) then
			difficulty = 2
		end
	end
	
	if selected <= 0 then
		selected = 3
	elseif selected >= 4 then 
		selected = 1
	end
end



--what to be drawn in the menu
function draw_menu()
	cls()
	
	bh=5+11
	if false then
		spr(223,0,bh)
		spr(223,16,bh)
		spr(223,32,bh)
		spr(223,48,bh)
		spr(223,120,bh)
		spr(223,104,bh)
		spr(223,88,bh)
		spr(223,72,bh)
	end

	tracky=5
	if menupart==1 then
		if btn(0,1) or btn(0) then printb("<",43,tracky,7)
			else printb("<",43,tracky,14) end
		if btn(1,1) or btn(1) then printb(">",81,tracky,7)
	 	else	printb(">",81,tracky,14) end
		printb("track " .. selected,50,tracky,10)
	else
		if btn(0,1) or btn(0) then printb("<",37,tracky,7)
			else printb("<",37,tracky,14) end
		if btn(1,1) or btn(1) then printb(">",87,tracky,7)
		 else	printb(">",87,tracky,14) end
		printb("difficulty",44,tracky,10)
	end

	if menupart == 2 then
		if difficulty == 1 then
			printb("medium",52,tracky+11,7)
		elseif difficulty == 2 then
			printb("hard",56,tracky+11,7)
		end
	end
	
	if selected==1 then
		if menupart == 1 then
			printb("abandoned armory",32,tracky+11,7)
			printb("mega man x3",42,tracky+20,7)
		end
		pal(9,11)
		pal(8,3)
		bgcol1=7
 	bgcol2=10
 	bgcol3=11
 	bgcol4=3
 	bg=bgcol1
	elseif selected==2 then
		if menupart == 1 then
			printb("twinkle snow zone",30,tracky+11,7)
			printb("sonic advance 3",34,tracky+20,7)
		end
		pal(10,14)
		pal(9,8)
		pal(8,2)
		bgcol1=7
 	bgcol2=14
 	bgcol3=8
 	bgcol4=2
 	bg=bgcol1
	else
		if menupart == 1 then
			printb("blue water blue sky",26,tracky+11,7)
			printb("guilty gear xx",36,tracky+20,7)
		end
		pal(10,12)
		pal(9,13)
		pal(8,1)
		bgcol1=7
 	bgcol2=12
 	bgcol3=13
 	bgcol4=1
 	bg=bgcol1
	end

	--where we want the rectangle
	--to start on the y axis
	boxy= 36
	--let's draw the rectangle
	menu_rect()


	bgy+=1/360
	clip(15,boxy+7,98,42)
	if selected==1 then
		for m=0,359 do
		 background_color()
			circ(64+m/5*cos(bgy+m/100*3),64+m/5*sin(bgy+m/200*2),1,bg)
		end
	elseif selected==2 then
		for m=0,359 do
		 background_color()
			circ(64+m/5*cos(bgy+m/100*3),64+m/5*sin(bgy+m/100*3),1,bg)
		end
	else
		for m=0,359 do
		 background_color()
			circ(64+m/2*sin(bgy+m/100*5),64+m/10*cos(bgy+m/500*2),1,bg)
		end
	end
	
	clip()
 -- printb("press z to start",30,50,7)
	printb("controls",48,98,10)
	printb("”",37,108,1)
	printb("‹",28,115,1)
	printb("ƒ",37,115,1)
	printb("‘",46,115,1)
	if btn(2,1) then printb("e",39,108,7)
		else printb("e",39,108,8) end
	if btn(0,1) then printb("s",30,115,7)
		else printb("s",30,115,11) end
	if btn(3,1) then printb("d",39,115,7)
		else printb("d",39,115,12) end
	if btn(1,1) then printb("f",48,115,7)
		else printb("f",48,115,9) end
	if btn(2) then printb("”",83,108,7)
		else printb("”",83,108,8) end
	if btn(0) then	printb("‹",74,115,7)
		else printb("‹",74,115,11) end
	if btn(3) then printb("ƒ",83,115,7)
		else printb("ƒ",83,115,12) end
	if btn(1) then printb("‘",92,115,7)
		else printb("‘",92,115,9) end
end

function menu_rect()
	--topleft corner
	spr(211,8,boxy)
	--left wall
	sspr(0,104,7,8,8,boxy+8,7,40)
	--top wall
	sspr(8,104,8,7,16,boxy,96,7)
	--topright corner
	spr(210,112,boxy)
	--right wall
	sspr(24,112,8,8,112,boxy+8,8,40)
	--bottomleft corner
	spr(224,8,boxy+48)
	--bottom wall
	sspr(8,112,8,8,16,boxy+48,96,8)
	--bottomright corner
	spr(226,112,boxy+48)
	
	pal()
end

function show_results()
	scrn.upd = update_results
	scrn.drw = draw_results

	--if for whatever reason music
	--is playing, let's stop that
	music(-1)
	
	--set where to show combo on
	--x axis
	maxcombo_x = (#(maxcombo .. "")*2) - 2

	if score2 > 0 then
		score_string = score2 .. score1_string
	else score_string = score1 .. "" end
	
 score_x = (#(score_string)*2) - 2

	--popup info
	popup_timer = 0
	popup = false
	
	--this will be changed if the
	--player misses any notes
	perfect = true
	
	for i=1,#arrow_y do
		if arrow_hit[i] != 1 then
			perfect = false
		end
	end
end

function update_results()	
	--let's keep moving through
	--the fadeout
	fadeout_z += 1
 if fadeout_z >= 80 then fadeout_z = 64 end

	popup_timer += 1

	if popup_timer >= 45 then
		popup = true end

	if popup then
		if (btnp(4) or btnp(1,4)) then show_menu() end
	end
end

function draw_results()
	results_anim()
    
	rectfill(31,31,96,80,0)
	map(16, 1, 0, 0, 17, 17)

	color_message()

 if perfect then
 	candy_results()
 end

	--score info
	printb("score:", 53, 37, 8)
	printb(score_string, 62-score_x, 45, 7)

	--combo info
	printb("max combo:", 45, 63, 8)
	printb(maxcombo, 62-maxcombo_x, 71, 7)

	--popup draw
	if popup then
		rect(35,99,92,111,7)
		rect(34,98,93,112,10)
		rect(33,97,94,113,9)
		rect(32,96,95,114,8)
		rectfill(36,100,91,110,0)

		printb("z: main menu",40,103,7)
	end
end

--when we want to start playing
function run_game()
	--initialize the buttons
	init_buttons()

	bgy=0

	bgcol1=7
	bgcol2=1
	bgcol3=2
	bgcol4=14

	--let's change the state
	scrn.upd = update_game
	scrn.drw = draw_game
 
 --instead of objects, we have
 --parallel tables for arrows
 --each new arrow gets an entry
 --in each of these
 
 --x coordinate on spritesheet
 arrow_sx = {}
 --y coordinate on spritesheet
 arrow_sy = {}
 --x coordinate on screen
 arrow_x = {}
 --y coordinate on screen
 arrow_y = {}
 --visibility of arrow
 arrow_vis = {}
 --column arrow is in
 arrow_col = {}
 --if an arrow is hit
 arrow_hit = {}
 --if the arrow is a hold arrow
 arrow_hold = {}
 --if arrow is still being drawn
 arrow_hold_active = {}
 --length of hold arrow
 arrow_hold_length = {}
 --colors 1 and 2 of arrow
 --these are only called if
 --it's a hold arrow
 arrow_color1 = {}
 arrow_color2 = {}

 --data for each of the four
 --lanes on whether there is
 --currently a hold
 lhold = false
 dhold = false
	uhold = false
	rhold = false

 --how high up we want arrows
 --to spawn on y axis
 arrow_spawn = -160
 --originally -154

 current_y = arrow_spawn

 --let's get the x cor on the
 --spritesheet that each
 --arrow needs, so that we can
 --flash it
 leftup_x = 0
 downright_x = 17

	--we also need to switch arrow
	--states so they flash in sync
	--this will be on a timer also
	arrow_state = 1
	arrow_timer = 3

 --let's get beatmap data going
 beat = 0
 row = 0
 
 if selected==1 then
 	musz=0
 	colz=112
 elseif selected==2 then
 	musz=18
 	colz=96
 else
 	musz=57
 	colz=72
 end

 -- 68 for test
 --112 for blast hornet
 -- 96 for sonic
 -- 72 for may's theme
 column = colz

 --music of course
 -- 0 for blast hornet
 --18 for sonic
 --57 for may's theme
 music(musz,1)

	--the current note we're on
	--we will use this information
	--to check to see where we
	--are in the music, and if we
	--need to change where the
	--notes are located
 note = -1
 lastnote = note

	--the colors to draw hold
	--arrows at
 draw_color1 = 0
	draw_color2 = 0

	--the length to draw hold notes to
	len = 8

	--scorestuff	
	combo = 0
	maxcombo = 0
	missed = 0
	--destination health, for
	--interpolation
	dhealth = 1
	--shown health
	health = dhealth

	--if the game is currently ending
	ending = false

	--for dithering the health bar
	dither_state = 1

 --and let's clear the screen
 cls()

 --for the fancy background
 --that plays beneath the arrows
 bg = bgcol1
 
 --below 1k
 score1 = 0
 --1k to 999k
 score2 = 0
 
 score1_string = "000"
 
 fadeout = false
 fadeout_z = -85
 
 --variables for candy text
 note_hit_timer = 0
 note_miss_timer = 0
 candy_speed = 14
 candy_height = 4
	candy_time = 0
	
	combo_display = "0"
	
	message_c1 = 8
 message_c2 = 9
 message_c3 = 10
 message_c4 = 11
 message_c5 = 12
 message_c6 = 13
 message_2frame = 1
 
	menuitem(1, "restart track", function() run_game() end)
	menuitem(2, "main menu", function() show_menu() music(-1) end)
end

function update_game()
	lastnote = note
	note = stat(23)
	beat = (lastnote != note)
	
	bleft.pressedlast = bleft.pressed
	bright.pressedlast = bright.pressed
	bup.pressedlast = bup.pressed
	bdown.pressedlast = bdown.pressed

	bleft.pressed = false
	bright.pressed = false
	bup.pressed = false
	bdown.pressed = false
	
 if (btn(0)) or (btn(0,1)) then bleft.pressed = true end
 if (btn(1)) or (btn(1,1)) then bright.pressed = true end
 if (btn(2)) or (btn(2,1)) then bup.pressed = true end
 if (btn(3)) or (btn(3,1)) then bdown.pressed = true end

 blinking_buttons()
 button_sprite(bleft)
 button_sprite(bdown)
 button_sprite(bup)
 button_sprite(bright)
 
 --we run the beatmap
 beatmap()
 --as well as check if the
 --player hit an arrow
 hit_arrow()

	--borders for if the player is
	--pressing buttons
 borders(bleft)
 borders(bdown)
 borders(bup)
 borders(bright)
 
 if fadeout == false then
	 for i=1,#arrow_y do
 		arrow_y[i] += 2
 		if arrow_hit[i] == 0 and arrow_y[i] > 127 then
 			arrow_hit[i] = -1
 			combo = 0
 			take_damage()
 			missed += 1 end
	 end
	end

 if combo > maxcombo then
 	maxcombo = combo end
 
 blinking_arrows()

	--let's keep dhealth between 0 and 1
	dhealth = mid(0,dhealth,1)

	--let's interpolate health
 health -= (health-dhealth)*.1

	--if it's over, let's clear the map 
 if ending or fadeout then clear_map() end

	score_calc()

	if fadeout then fadeout_z += 1 end
 if fadeout_z >= 80 then fadeout_z = 64 end

	color_message()
	
	combo_display = combo .. ""
end

function score_calc()
	--make sure score isn't higher
	--than 9,999,999
	score2 = mid(0,score2,9999)
	if score2 == 999 then score1 = mid(0,score1,999) end

	--transfer numbers from score1
	--to score2 to score3 if need
	--be
	if score1 > 1000 then
		score2 += flr(score1/1000)
		score1 = score1%1000
	end

	score2 = mid(0,score2,9999)
	if score2 == 999 then score1 = mid(0,score1,999) end

	if score1 == 0 then
		score1_string = "000" end
	if score1 < 10 and score1 > 0 then
		score1_string = ("00" .. score1) end
	if score1 < 100 and score1 >= 10 then
		score1_string = ("0" .. score1) end
	if score1 >= 100 then
		score1_string = "" .. score1 end
end

--what we want to be shown on
--the screen during a stage
function draw_game()
	--make the map
	cls()
	
	--background
	bgy+=1/360
	for m=0,359 do
	 background_color()
		if (45+m/5*cos(bgy+m/100*3) < 87) then
			circ(45+m/5*cos(bgy+m/100*3),64+m/5*sin(bgy+m/200*2),1,bg) end
	end

	----debug info
	--print("com: " .. combo, 96, 78, 7)
	--print("max: " .. maxcombo, 96, 85, 7)

	--print(row-32 .. ", " .. column,96, 92, 7)
	--if (stat(23) != -1) then
	--	current_y = arrow_y[1] end
	--if (current_y != nil) then
	--	print("y: " .. current_y,96,99,7) end
	--print(": " .. stat(23)+1,96,106,7)
	--print(stat(0),96,113,7)
	--print(stat(1),96,120,7)

	for i=1,#arrow_x do
		if arrow_vis[i] and arrow_y[i] > -17 and arrow_y[i] - arrow_hold_length[i] < 128 then
 		sspr(arrow_sx[i], arrow_sy[i], 17, 17, arrow_x[i], arrow_y[i])
 		if arrow_hold[i] then
 			--z is the current arrow
 			--this will be used in
 			--the draw
 			draw_hold_arrow(i)
 		end
 	end
 end
	
 map(0, 0, 0, 0, 16, 16)
 
 draw_stats()
 
 --let's draw those four buttons
 sspr(0,bleft.sprite,17,17,9,102)
 sspr(17,bdown.sprite,17,17,28,102)
 sspr(17,bup.sprite,17,17,47,102,17,17,false,true)
 sspr(0,bright.sprite,17,17,66,102,17,17,true,false)
 --and their borders
 if (bleft.borderstate != 0) then
 	sspr(bleft.border_x,109,19,19,8,101) end
 if (bdown.borderstate != 0) then
 	sspr(bdown.border_x,90,19,19,27,101) end
 if (bup.borderstate != 0) then
 	sspr(bup.border_x,90,19,19,46,101,19,19,false,true) end
 if (bright.borderstate != 0) then
 	sspr(bright.border_x,109,19,19,65,101,19,19,true,false) end

	candy_text()
	fail_text()

	if fadeout then
		fadeout_anim()
		results_anim() end
end

function background_color()
	if bg == bgcol1 then
		bg = bgcol2
	elseif bg == bgcol2 then
		bg = bgcol3
	elseif bg == bgcol3 then
		bg = bgcol4
	elseif bg == bgcol4 then
		bg = bgcol1
	end
end

function calculate_color(z)
	if arrow_col[z] == 1 then
		if arrow_state == 1 then
			arrow_color1[z] = 11
			arrow_color2[z] = 3
		end
		if arrow_state == 2 then
			arrow_color1[z] = 3
			arrow_color2[z] = 11
		end
	end
	if arrow_col[z] == 2 then
		if arrow_state == 1 then
			arrow_color1[z] = 12
			arrow_color2[z] = 13
		end
		if arrow_state == 2 then
			arrow_color1[z] = 13
			arrow_color2[z] = 12
		end
	end
	if arrow_col[z] == 3 then
		if arrow_state == 1 then
			arrow_color1[z] = 14
			arrow_color2[z] = 8
		end
		if arrow_state == 2 then
			arrow_color1[z] = 8
			arrow_color2[z] = 14
		end
	end
	if arrow_col[z] == 4 then
		if arrow_state == 1 then
			arrow_color1[z] = 10
			arrow_color2[z] = 9
		end
		if arrow_state == 2 then
			arrow_color1[z] = 9
			arrow_color2[z] = 10
		end
	end
end

function draw_hold_arrow(z)
	calculate_color(z)
	--if we have a left arrow
	--refer to x values to see columns
 if arrow_col[z] == 1 then
 	--left vert border
 	line(arrow_x[z], arrow_y[z]+7, arrow_x[z], arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color1[z])

		--left diag border
		line(arrow_x[z]+1, arrow_y[z]+7 - (arrow_hold_length[z]), arrow_x[z]+8, arrow_y[z] - (arrow_hold_length[z]), arrow_color1[z])

		--left inner arrow
		for zz=1,6 do
			line(arrow_x[z]+zz, arrow_y[z]+7-zz, arrow_x[z]+zz, arrow_y[z] + 9 - zz - (arrow_hold_length[z]), arrow_color2[z])
		end
		--inside arrow
		pset(arrow_x[z]+8, arrow_y[z] + 5, arrow_color1[z])
		line(arrow_x[z]+9, arrow_y[z] + 5, arrow_x[z]+9, arrow_y[z] + 4, arrow_color1[z])
		line(arrow_x[z]+10, arrow_y[z] + 5, arrow_x[z]+10, arrow_y[z] + 3, arrow_color1[z])

		--middleish inner arrow
		line(arrow_x[z]+7, arrow_y[z], arrow_x[z]+7, arrow_y[z] + 2 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+8, arrow_y[z]-1, arrow_x[z]+8, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+9, arrow_y[z]-1, arrow_x[z]+9, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+10, arrow_y[z]-1, arrow_x[z]+10, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color1[z])

		--middle outer border
		line(arrow_x[z]+9, arrow_y[z] - (arrow_hold_length[z]), arrow_x[z]+10, arrow_y[z] - (arrow_hold_length[z]), arrow_color1[z])

		--right outer border
		line(arrow_x[z]+11, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_x[z]+14, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_color1[z])

		--right inner arrow
		rectfill(arrow_x[z]+11, arrow_y[z] + 5, arrow_x[z]+14, arrow_y[z] + 7 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+15, arrow_y[z]+6, arrow_x[z]+15, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color2[z])
		
		--leftmost outer border
		pset(arrow_x[z]+15, arrow_y[z]+7 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+16, arrow_y[z]+7, arrow_x[z]+16, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color1[z])
	end
	if arrow_col[z] == 2 then
		--left vert border
 	line(arrow_x[z], arrow_y[z]+5, arrow_x[z], arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_color2[z])
		
		--left upper inner
		rectfill(arrow_x[z]+1, arrow_y[z] + 5, arrow_x[z]+2, arrow_y[z] + 7 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+3, arrow_y[z] + 6, arrow_x[z] + 3, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+4, arrow_y[z] + 7, arrow_x[z] + 4, arrow_y[z] + 9 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+5, arrow_y[z] + 8, arrow_x[z] + 5, arrow_y[z] + 10 - (arrow_hold_length[z]), arrow_color1[z])

		--left outer border
		pset(arrow_x[z]+1, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+2, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_x[z]+5, arrow_y[z] + 9 - (arrow_hold_length[z]), arrow_color2[z])

		--middle inner and outer
		--(they use the same color)
		line(arrow_x[z]+6, arrow_y[z] + 1, arrow_x[z] + 6, arrow_y[z] + 2 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+7, arrow_y[z], arrow_x[z] + 7, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+8, arrow_y[z] - 1, arrow_x[z] + 8, arrow_y[z] - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+9, arrow_y[z], arrow_x[z] + 9, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+10, arrow_y[z] + 1, arrow_x[z] + 10, arrow_y[z] + 2 - (arrow_hold_length[z]), arrow_color2[z])

		--right outer border
		pset(arrow_x[z]+15, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+14, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_x[z]+11, arrow_y[z] + 9 - (arrow_hold_length[z]), arrow_color2[z])

		--right upper inner
		rectfill(arrow_x[z]+14, arrow_y[z] + 5, arrow_x[z]+15, arrow_y[z] + 7 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+13, arrow_y[z] + 6, arrow_x[z] + 13, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+12, arrow_y[z] + 7, arrow_x[z] + 12, arrow_y[z] + 9 - (arrow_hold_length[z]), arrow_color1[z])
 	line(arrow_x[z]+11, arrow_y[z] + 8, arrow_x[z] + 11, arrow_y[z] + 10 - (arrow_hold_length[z]), arrow_color1[z])

		--right vert border
 	line(arrow_x[z]+16, arrow_y[z]+5, arrow_x[z]+16, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_color2[z])
	end
	if arrow_col[z] == 3 then
		--left vert border
 	line(arrow_x[z], arrow_y[z]+7, arrow_x[z], arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color2[z])

		--left inner to very middle
		--inner
		for zz=1,4 do
			line(arrow_x[z]+zz, arrow_y[z]+7-zz, arrow_x[z]+zz, arrow_y[z] + 9 - zz - (arrow_hold_length[z]), arrow_color1[z])
		end
		for zz=5,8 do
			line(arrow_x[z]+zz, arrow_y[z]+7-zz, arrow_x[z]+zz, arrow_y[z] + 9 - zz - (arrow_hold_length[z]), arrow_color2[z])
		end
		--left outer border
		line(arrow_x[z]+1, arrow_y[z] + 7 - (arrow_hold_length[z]), arrow_x[z]+7, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color2[z])

		--middle outer border
		pset(arrow_x[z]+8, arrow_y[z] - (arrow_hold_length[z]), arrow_color2[z])

		--right inner
		for zz=5,8 do
		 line(arrow_x[z]+7+zz, arrow_y[z]-2+zz, arrow_x[z]+7+zz, arrow_y[z] + zz - (arrow_hold_length[z]), arrow_color1[z])
		end
		for zz=9,11 do
			line(arrow_x[z]+zz, arrow_y[z]-9+zz, arrow_x[z]+zz, arrow_y[z]-7+zz - (arrow_hold_length[z]), arrow_color2[z])
		end
		--right outer border
		line(arrow_x[z]+15, arrow_y[z] + 7 - (arrow_hold_length[z]), arrow_x[z]+9, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color2[z])

		--right vert border
 	line(arrow_x[z]+16, arrow_y[z]+7, arrow_x[z]+16, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color2[z])
	end
	--this is just the code for
	--left arrows, but with the x
	--values all reversed
	if arrow_col[z] == 4 then
	--right vert border
 	line(arrow_x[z]+16, arrow_y[z]+7, arrow_x[z]+16, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color1[z])

		--right diag border
		line(arrow_x[z]+15, arrow_y[z]+7 - (arrow_hold_length[z]), arrow_x[z]+8, arrow_y[z] - (arrow_hold_length[z]), arrow_color1[z])

		--right inner arrow
		for zz=10,15 do
			line(arrow_x[z]+zz, arrow_y[z]-9+zz, arrow_x[z]+zz, arrow_y[z]-7+zz - (arrow_hold_length[z]), arrow_color2[z])
		end
		--inside arrow
		pset(arrow_x[z]+8, arrow_y[z] + 5, arrow_color1[z])
		line(arrow_x[z]+7, arrow_y[z] + 5, arrow_x[z]+7, arrow_y[z] + 4, arrow_color1[z])
		line(arrow_x[z]+6, arrow_y[z] + 5, arrow_x[z]+6, arrow_y[z] + 3, arrow_color1[z])

		--middleish inner arrow
		line(arrow_x[z]+9, arrow_y[z], arrow_x[z]+9, arrow_y[z] + 2 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+8, arrow_y[z]-1, arrow_x[z]+8, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+7, arrow_y[z]-1, arrow_x[z]+7, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z]+6, arrow_y[z]-1, arrow_x[z]+6, arrow_y[z] + 1 - (arrow_hold_length[z]), arrow_color1[z])

		--middle outer border
		line(arrow_x[z]+7, arrow_y[z] - (arrow_hold_length[z]), arrow_x[z]+6, arrow_y[z] - (arrow_hold_length[z]), arrow_color1[z])

		--left outer border
		line(arrow_x[z]+5, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_x[z]+2, arrow_y[z] + 6 - (arrow_hold_length[z]), arrow_color1[z])

		--left inner arrow
		rectfill(arrow_x[z]+5, arrow_y[z] + 5, arrow_x[z]+2, arrow_y[z] + 7 - (arrow_hold_length[z]), arrow_color2[z])
		line(arrow_x[z]+1, arrow_y[z]+6, arrow_x[z]+1, arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color2[z])
		
		--leftmost outer border
		pset(arrow_x[z]+1, arrow_y[z]+7 - (arrow_hold_length[z]), arrow_color1[z])
		line(arrow_x[z], arrow_y[z]+7, arrow_x[z], arrow_y[z] + 8 - (arrow_hold_length[z]), arrow_color1[z])
	end
end

--let's run through the beatmap
function beatmap()
	--if it's a beat and we're not
	--ending
	if (beat) and (ending == false) then
		--reset if gone off
		--spritesheet
		new_line_check()
	 
	 extended = true
	 
	 --let's correct any desync
	 --that may have happened
	 desync_correction()
	 
	 --extract and play beatmap
		if (sget(column, row) == 11)
		or ((difficulty > 1) and (sget(column, row) == 12)) then
			new_arrow(1) end
		if (sget(column+1, row) == 11)
		or ((difficulty > 1) and (sget(column+1, row) == 12)) then
			new_arrow(2) end
		if (sget(column+2, row) == 11)
		or ((difficulty > 1) and (sget(column+2, row) == 12)) then
			new_arrow(3) end
		if (sget(column+3, row) == 11)
		or ((difficulty > 1) and (sget(column+3, row) == 12)) then
			new_arrow(4) end
			
		--hold arrows
		if (sget(column, row) == 3) then
			if (sget(column, row-1) != 3) then
				new_arrow(5) end
			if (sget(column, row-1) == 3) and extended then
				extend_arrow()
			end
		end
		if (sget(column+1, row) == 3) then
			if (sget(column+1, row-1) != 3) then
				new_arrow(6) end
			if (sget(column+1, row-1) == 3) and extended then
				extend_arrow()
			end
		end
		if (sget(column+2, row) == 3) then
			if (sget(column+2, row-1) != 3) then
				new_arrow(7) end
			if (sget(column+2, row-1) == 3) and extended then
				extend_arrow()
				held = false
			end
		end
		if (sget(column+3, row) == 3) then
			if (sget(column+3, row-1) != 3) then
				new_arrow(8) end
			if (sget(column+3, row-1) == 3) and extended then
				extend_arrow()
			end
		end
		--end
		if (sget(column+3, row) == 4) then
			clear_map() end
		--loop
		if (sget(column+3, row) == 2) then
			row = -1 end

	if (sget(column, row) != 3) then
		for i=1,#arrow_hold_active do
	  if (arrow_hold_active[i] and arrow_col[i] == 1) then
	   arrow_hold_active[i] = false
	  end
	 end
	end
	if (sget(column+1, row) != 3) then
		for i=1,#arrow_hold_active do
	  if (arrow_hold_active[i] and arrow_col[i] == 2) then
	   arrow_hold_active[i] = false
	  end
	 end
	end	
	if (sget(column+2, row) != 3) then
		for i=1,#arrow_hold_active do
	  if (arrow_hold_active[i] and arrow_col[i] == 3) then
	   arrow_hold_active[i] = false
	  end
	 end
	end
 if (sget(column+3, row) != 3) then
		for i=1,#arrow_hold_active do
	  if (arrow_hold_active[i] and arrow_col[i] == 4) then
	   arrow_hold_active[i] = false
	  end
	 end
	end
	
	--finally let's add 1 to the
	--row
	row += 1
	end
end

function new_line_check()
	if (row == 128) then
	row = 0
	column += 4 end
end

function fadeout_anim()
	for z=0,7 do
		sspr(55,66,16,16,fadeout_z+z*16,fadeout_z+112-z*16,16,16)
	end
	for cnt=1,12 do
		for z=0,11 do
			sspr(108,124,4,4,fadeout_z+z*16-cnt*16,fadeout_z+112-z*16,16,16)
		end
	end
	if (btnp(4) or btnp(1,4)) then fadeout_z = 79 end
end

function candy_results()
	candy_time += 1
	px=36
	py=10
	ssprc(48,41,7,7,px,py+sin((candy_time)/candy_speed)*candy_height,7,7,6)
	ssprc(55,83,7,7,px+8,py+sin((candy_time+2)/candy_speed)*candy_height,7,7,6)
	ssprc(34,41,7,7,px+16,py+sin((candy_time+4)/candy_speed)*candy_height,7,7,6)
	ssprc(62,83,7,7,px+24,py+sin((candy_time+6)/candy_speed)*candy_height,7,7,6)
	ssprc(55,83,7,7,px+32,py+sin((candy_time+8)/candy_speed)*candy_height,7,7,6)
	ssprc(41,41,7,7,px+40,py+sin((candy_time+10)/candy_speed)*candy_height,7,7,6)
	ssprc(62,43,7,7,px+48,py+sin((candy_time+12)/candy_speed)*candy_height,7,7,6)
end

function candy_text()
	if note_hit_timer > 0 then
	--candy_time moves up to wave text in sine wave
		candy_time += 1
 	ssprc(34,69,7,7,24,20+sin((candy_time)/candy_speed)*candy_height,7,7,8)
 	ssprc(41,69,7,7,32,20+sin((candy_time+2)/candy_speed)*candy_height,7,7,8)
 	ssprc(48,69,7,7,40,20+sin((candy_time+4)/candy_speed)*candy_height,7,7,8)
 	ssprc(34,76,7,7,48,20+sin((candy_time+6)/candy_speed)*candy_height,7,7,8)
 	ssprc(41,76,7,7,56,20+sin((candy_time+8)/candy_speed)*candy_height,7,7,8)
 	ssprc(45,83,3,7,65,20+sin((candy_time+10)/candy_speed)*candy_height,3,7,8)
		note_hit_timer -= 1
	end
end

function fail_text()
	if note_miss_timer > 0 then
		sspr(34,83,8,7,32,20-flr(note_miss_timer/2),8,7)
 	sspr(42,83,3,7,41,20-flr(note_miss_timer/2),3,7)
 	sspr(48,83,7,7,45,20-flr(note_miss_timer/2),7,7)
 	sspr(48,83,7,7,53,20-flr(note_miss_timer/2),7,7)		
		note_miss_timer -= 1
	end
end

function ssprs(sx, sy, sw, sh, x, y, w, h, col1, col2)
	pal(col1,6)
	pal(col2,5)
	sspr(sx,sy,sw,sh,x,y,w,h)
	pal()
end
	
function ssprc(sx, sy, sw, sh, x, y, w, h, col)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip(0,y,127,1)
	pal(col,message_c1)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip(0,y+1,127,1)
	pal(col,message_c2)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip(0,y+2,127,1)
	pal(col,message_c3)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip(0,y+3,127,1)
	pal(col,message_c4)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip(0,y+4,127,1)
	pal(col,message_c5)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip(0,y+5,127,1)
	pal(col,message_c6)
	sspr(sx,sy,sw,sh,x,y,w,h)
	clip()
	pal()
end

function results_anim()
	for x=0,9 do
  for y=0,9 do
   sspr(108,124,4,4,fadeout_z+x*16-96,fadeout_z+y*16-96,16,16)
  end
 end
end

function color_message()
	message_2frame+= 1
 if message_2frame > 2 then
  message_c1 += 1
	 if message_c1 > 14 then message_c1 = 8 end
		message_c2 += 1
		if message_c2 > 14 then message_c2 = 8 end
		message_c3 += 1
		if message_c3 > 14 then message_c3 = 8 end
		message_c4 += 1
		if message_c4 > 14 then message_c4 = 8 end
		message_c5 += 1
		if message_c5 > 14 then message_c5 = 8 end
		message_c6 += 1
		if message_c6 > 14 then message_c6 = 8 end
		message_2frame -= 2
 end
end

function clear_map()
	if ending != true then
	 ending = true end
	if stat(23) == -1 then
		fadeout = true end
	if fadeout_z >= 79 then
		show_results() end
end

--if the player misses a beat
function take_damage()
 dhealth -= .15
 note_hit_timer = 0
 note_miss_timer = 15
end

function draw_stats()
	--health
	for yset=2, 6 do
		if yset%2 == 1 then
			dither_state = 1
		elseif yset%2 == 0 then
			dither_state = 2
		end
		for xset=92, 92+flr(35*health) do
			if dither_state == 1 then
				if health >= (2/3) then pset(xset,yset,11) end
				if health < (2/3) and health >= (1/3) then pset(xset,yset,10) end
				if health < (1/3) and health >= 0 then pset(xset,yset,8) end

				dither_state = 2
			elseif dither_state == 2 then
				if health >= (2/3) then pset(xset,yset,3) end
				if health < (2/3) and health >= (1/3) then pset(xset,yset,4) end
				if health < (1/3) and health >= 0 then pset(xset,yset,14) end
				dither_state = 1
			end
		end
	end
	
	if flr(35*health) == 0 then
		if fadeout != true then
			sfx(63,0)
			music(-1)
			clear_map()
			fadeout = true
		end
	end

	--outer rectangle
	line(92, 0, 127, 0, 1)
	line(92, 8, 127, 8, 1)

	--inner rectangle
	rect(92, 1, 127, 7, 7)

	--score
	sspr(55,34,11,9,92,9,11,9)
	sspr(55,34,11,9,102,9,11,9)
	sspr(55,34,11,9,112,9,11,9)
	sspr(55,34,6,9,122,9,6,9)
	for x=0,1 do
		print(score1%10,124-x,11,0+10*x)
		print(flr((score1%100)/10),119-x,11,0+10*x)
		print(flr(score1/100),114-x,11,0+10*x)
		print(score2%10,109-x,11,0+10*x)
		print(flr((score2%100)/10),104-x,11,0+10*x)
		print(flr((score2%1000)/100),99-x,11,0+10*x)
		print(flr(score2/1000),94-x,11,0+10*x) end

	clip(0,14,128,2)
		print(score1%10,123,11,9)
		print(flr((score1%100)/10),118,11,9)
		print(flr(score1/100),113,11,9)
		print(score2%10,108,11,9)
		print(flr((score2%100)/10),103,11,9)
		print(flr((score2%1000)/100),98,11,9)
		print(flr(score2/1000),93,11,9)
	clip()

	--line(92,18,127,18,6)
	
	--combo
 --#combo_display
 if combo < 10 then
		pal(14,6)
		pal(2,5)
	elseif combo >= 10 and combo < 25 then
		--current pallette is fine
	elseif combo >= 25 and combo < 50 then
		pal(14,12)
		pal(2,1)
	elseif combo >= 50 and combo < 75 then
		pal(14,10)
		pal(2,4)
	elseif combo >= 75 and combo < 100 then
		pal(14,11)
		pal(2,3)
	elseif combo >= 100 and combo < 125 then
		pal(7,10)
		pal(14,8)
	elseif combo >= 125 and combo < 150 then
		pal(14,12)
		pal(2,7)
		pal(7,1)
	elseif combo >= 150 and combo < 175 then
		pal(14,10)
		pal(2,7)
		pal(7,4)
	elseif combo >= 175 and combo < 200 then	
		pal(14,11)
		pal(2,7)
		pal(7,3)
	elseif combo >= 200 and combo < 250 then
		pal(7,5)
		pal(14,6)
		pal(2,7)
	else
	 pal(2,0)
	 pal(14,7)
	end
 if #combo_display == 1 then
		ssprn(sub(combo_display,1,1),106)
 elseif #combo_display == 2 then
 	ssprn(sub(combo_display,1,1),102)
 	ssprn(sub(combo_display,2,2),110)
 elseif #combo_display == 3 then
 	ssprn(sub(combo_display,1,1),98)
 	ssprn(sub(combo_display,2,2),106)
 	ssprn(sub(combo_display,3,3),114)
 end
 pal()
 
 printb("combo",100,ycor-8,7)
 printb("playing:",95,ycor+50,7)
 printb("track ".. selected,96,ycor+58,7)
end

function ssprn(num,x)
	ycor = 62
	if num == "0" then
		sspr(48,76,7,7,x,ycor)
	elseif num == "1" then
		sspr(34,48,7,7,x,ycor)
	elseif num == "2" then
		sspr(41,48,7,7,x,ycor)
	elseif num == "3" then
		sspr(48,48,7,7,x,ycor)
	elseif num == "4" then
		sspr(34,55,7,7,x,ycor)
	elseif num == "5" then
		sspr(41,55,7,7,x,ycor)
	elseif num == "6" then
		sspr(48,55,7,7,x,ycor)
	elseif num == "7" then
		sspr(34,62,7,7,x,ycor)
	elseif num == "8" then
		sspr(41,62,7,7,x,ycor)
	elseif num == "9" then
		sspr(48,62,7,7,x,ycor)
	end
end

function extend_arrow()
	for i=1,#arrow_hold_active do
		if (arrow_hold_active[i]) then
			arrow_hold_length[i] += len
		end
	end
	extended = false
end

function desync_correction()
 --failsafe to see if we just
	--skipped a note in a frame
	if (note-lastnote == 2) or (note-lastnote == -30) then
		row += 1
		new_line_check()
 end

	--if your computer is super
 --shitty, maybe it skipped
 --2 notes
 if (note-lastnote == 3) or (note-lastnote == -29) then
		row += 1
 	new_line_check()
	 row += 1
		new_line_check()
 end

	--if your computer just
 --skipped 3 notes in a frame
 --then what the fuck are you
	--even doing??????????
 if (note-lastnote == 4) or (note-lastnote == -28) then
	 row += 1
		new_line_check()
 	row += 1
	 new_line_check()
		row += 1
 	new_line_check()
	end

	--yea idk if you miss 4 notes
	if (note-lastnote == 5) or (note-lastnote == -27) then
 	row += 1
		new_line_check()
 	row += 1
		new_line_check()
 	row += 1
	 new_line_check()
		row += 1
 	new_line_check()
	end

	--if you stutter and go back
	--by 1 note
	if (note-lastnote == -1) or (note-lastnote == 31) then
	 row -= 1
	end

	--if you stutter and go back
	--by 2 notes
	if (note-lastnote == -2) or (note-lastnote == 30) then
		row -= 2
	end
	
	--stutter for 3 notes
	if (note-lastnote == -3) or (note-lastnote == 29) then
		row -= 3
	end

	--stutter for 4 notes
	if (note-lastnote == -4) or (note-lastnote == 28) then
		row -= 4
	end
end

--when we want to make a new
--arrow
function new_arrow(atype)
	local i
	--left hit arrow
	if (atype == 1) then
 	arrow_create(leftup_x,0,9,1,false,false,0,0,0)
	--down hit arrow
	elseif (atype == 2) then
		arrow_create(downright_x,0,28,2,false,false,0,0,0)
	--up hit arrow
	elseif (atype == 3) then
		arrow_create(leftup_x,17,47,3,false,false,0,0,0)
	--right hit arrow
	elseif (atype == 4) then
		arrow_create(downright_x,17,66,4,false,false,0,0,0)
	--left hold arrow
	elseif (atype == 5) then
	 arrow_create(leftup_x,0,9,1,true,true,0,0,0)
	--down hold arrow
	elseif (atype == 6) then
		arrow_create(downright_x,0,28,2,true,true,0,0,0)
 --up hold arrow
	elseif (atype == 7) then
		arrow_create(leftup_x,17,47,3,true,true,0,0,0)
	--right hold arrow
	elseif (atype == 8) then
		arrow_create(downright_x,17,66,4,true,true,0,0,0)
	end
end

function arrow_create(sx,sy,x,col,hold,active,length,color1,color2)
	add(arrow_sx,sx)
	add(arrow_sy,sy)
	add(arrow_x,x)
	add(arrow_y,arrow_spawn)
	add(arrow_vis,true)
	add(arrow_col,col)
	add(arrow_hit,0)
	add(arrow_hold,hold)
	add(arrow_hold_active,active)
	add(arrow_hold_length,length)
	add(arrow_color1,color1)
	add(arrow_color2,color2)
end

--let's check to see if the
--player just hit an arrow
function hit_arrow()
	hit_math(bleft, 1)
 hit_math(bdown, 2)
 hit_math(bup, 3)
	hit_math(bright,4)
end

--the math to do if we hit a note
function hit_math(direction, col)
 if direction.pressed then
 	for i=1,#arrow_vis do
 		if arrow_vis[i] and arrow_col[i] == col then
 			if arrow_y[i] <= 106 and arrow_y[i] >= 98 then
					--if it's a simple note
					if (arrow_hold[i] == false and (direction.pressedlast != direction.pressed)) and fadeout == false then
						arrow_vis[i] = false
						arrow_hit[i] = 1
						combo += 1
						get_points()
						dhealth += .020
						note_hit_timer = 15
						note_miss_timer = 0
						candy_time = 0
					end
					--if it's a new hold note
					--and we just pressed
					if arrow_hold[i] and (direction.pressedlast != direction.pressed) and (arrow_hit[i] == 0) and fadeout == false then
						--we want to make sure
						--trails stays smooth
						arrow_hold_length[i] -= (arrow_y[i] - 100)
						
						--and then let's relocate
						--the button and say it's
						--hit
						arrow_y[i] = 100
						arrow_hit[i] = 1
						
						note_hit_timer = 15
						note_miss_timer = 0
						candy_time = 0
						
						--and let's add to that combo
						combo += 1
						
						get_points()
						
						dhealth += .020
						
					--if it's a hold note and
					--we're continuing to press
					--and it's not done yet
					elseif arrow_hold[i] and (arrow_hit[i] == 1) and arrow_hold_length[i] > 0 and direction.pressedlast == direction.pressed then
						arrow_y[i] = 100
						arrow_hold_length[i] -= 2
						if fadeout then
							arrow_vis[i] = false
						end
						if note_hit_timer < 3 and note_hit_timer > 0 then note_hit_timer = 3 end
						
						if beat and fadeout == false then
							get_points()
							dhealth += .002
						end
					--if it's a hold note and
					--we're continuing to press
					--and it just finished
					elseif arrow_hold[i] and (arrow_hit[i] == 1) and arrow_hold_length[i] == 0 then
						arrow_vis[i] = false
						if fadeout == false then
							get_points()
							dhealth += .002
							end
					end
				end
 		end
 	end
 end
 --we also want to make arrows
 --invisible if the player
 --stops holding a hold note
 if (direction.pressedlast != direction.pressed) and (direction.pressed == false) then
		for i=1,#arrow_vis do
			if arrow_vis[i] and arrow_hit[i] == 1 and (arrow_col[i] == col) and arrow_hold[i] == true then
				arrow_vis[i] = false
			end
		end
	end
end

function get_points()
	score1 += 1 + flr(flr(combo/2)*1.5)
end

function blinking_arrows()
	if beat then arrow_timer += 1 end
	if arrow_timer >= 4 then
		arrow_timer = 0
		if arrow_state == 1 then
		 arrow_state = 2
		 leftup_x = 34
 	 downright_x = 51
		elseif arrow_state == 2 then
		 arrow_state = 1
		 leftup_x = 0
 	 downright_x = 17
		end

 	for i=1,#arrow_sx do
 		if (arrow_col[i] == 1) or (arrow_col[i] == 3) then
 			arrow_sx[i] = leftup_x
 		elseif (arrow_col[i] == 2) or (arrow_col[i] == 4) then
 			arrow_sx[i] = downright_x
 		end
 	end
	end
end

function blinking_buttons()
	if beat then flashing_timer +=1 end
 if flashing_timer >= 4 then
 	flashing_timer = 0
 	flashing(bleft)
 	flashing(bdown)
 	flashing(bup)
 	flashing(bright)
 end
end

function flashing(button)
 if button.state == 1 then
 	button.state+=1
 elseif button.state == 2 then
  button.state-=1
 end
end

function button_sprite(button)
	if (button.state == 1 and button.pressed == false) then
		button.sprite = 34 end
	if (button.state == 2 and button.pressed == false) then
	 button.sprite = 51 end
	if (button.state == 1 and button.pressed == true) then
	 button.sprite = 68 end
 if	(button.state == 2 and button.pressed == true) then
	 button.sprite = 85 end
end

function init_buttons()
 --let's initialize the 4
 --buttons
 bleft = {}
 bdown = {}
 bup = {}
 bright = {}
 
 --timers for left down up and
 --right
 flashing_timer = 3
 
 --we also want to define which
 --sprite to use, which will be
 --alternated and flashing
 bleft.sprite = 34
 bdown.sprite = 34
 bup.sprite = 51
 bright.sprite = 51
 
 --when the buttons flash, they
 --alternate between a state of
 --1 and 2
 bleft.state = 1
 bdown.state = 1
 bup.state = 2
 bright.state = 2
 
 --let's declare whether or not
 --they're held
 bleft.pressed =  false
 bdown.pressed = false
 bup.pressed = false
 bright.pressed = false
 
 --let's declare whether or not
 --they were held last frame
 bleft.pressedlast =  false
 bdown.pressedlast = false
 bup.pressedlast = false
 bright.pressedlast = false
 
 bleft.borderstate = 0
 bdown.borderstate = 0
 bup.borderstate = 0
 bright.borderstate = 0
 
 bleft.border_x = 34
 bdown.border_x = 34
 bup.border_x = 34
 bright.border_x = 34
end

function borders(button)
	if (button.pressed) then
	 button.border_x = 34
		button.borderstate = 1 end
	if (button.pressed == false) and (button.borderstate > 0 and button.borderstate < 3) then
		button.border_x = 34
		button.borderstate += 1
 elseif (button.pressed == false) and (button.borderstate == 3) then	
		button.border_x = 53
		button.borderstate += 1
	elseif (button.pressed == false) and (button.borderstate == 4) then	
		button.borderstate = 0
	end
end

function printb(text, x, y, col)
	for xx=x-1,x+1 do
		for yy=y-1, y+1 do
			print(text, xx, yy, 1)
		end
	end
	print(text, x, y, col)
end
__gfx__
0000000033300000000000000c0000000000000000bbb00000000000000d0000000037773777b77737777737b7770000b777b777777b777bb7773773b7777337
000000037730000000000000c7c00000000000000b77b0000000000000d7d0000000377737777777377777377777000077777777777777777777377377777337
00000037773000000000000c777c000000000000b777b000000000000d777d0000003777777777773777777777770000777c77777c777777777c377377c77337
00000b77730000000000000c777c000000000003777b0000000000000d777d0000003777777777c7377777777c7700007b77777b77b777b77777377377777337
0000b777300000000000000c777c00000000003777b00000000000000d777d00000073777c7b777b3777c77b777b000077777777777777777b777777777b7777
000b7773000000000000000c777c0000000003777b000000000000000d777d0000007377777777773777777777770000777cc777c7777c7777777c7777777c77
00b77733333bbbb00ddd000dc7cd000ddd003777bbbbb333300ccc000cd7dc000ccc737777777777777c77777777000077777c77777777c7777cb7777c77b777
0b777b7777b7777b0d77d00d7c7d00d77d03777377773777730c77c00c7d7c00c77c7377b7c77c7777777bc777c7000077377737737777737777777c77777c77
b777b7777b777777bd777d0d777d0d777d37773777737777773c777c0c777c0c777c7737777777377377777773770000773777377377777377b77337b7773773
0b777b7777b7777b00d777dd777dd777d0037773777737777300c777cc777cc777c0773777777737737777777377000077377737737777737777733777773773
00b77733333bbbb0000d777d777d777d00003777bbbbb33330000c777c777c777c0077377c7b77377377b77c737700007777777777777777c777733777c73773
000b7773000000000000c777c7c777c0000003777b000000000000d777d7d777d000773777777737737777777377000077777777777777777777733777773773
0000b7773000000000000c777c777c000000003777b000000000000d777d777d0000777377777737b777777773770000b7777777777b7777777b7777777b7777
00000b7773000000000000c77777c00000000003777b000000000000d77777d000007773b7c7777777777bc777b700007c77777777c77777777777b777777b77
00000037773000000000000c777c000000000000b777b000000000000d777d0000007773777777777b7777777777000077c7b7777c7777b7c77777777c777777
000000037730000000000000c7c00000000000000b77b0000000000000d7d000000077737777c77777777777c7770000777b7777b77777777777777777777777
0000000033300000000000000c0000000000000000bbb00000000000000d00000000b777717377b737777737777b00007777b77777777b77b77773737b773737
00000000e000000000000009990000000000000000800000000000000aaa00000000777771737777377777377777000077777777777777777777737377773737
0000000e7e00000000000009779000000000000008780000000000000a77a00000007777777777773777777777770000c7777777777c7777777c7373777c3737
000000e777e0000000000009777900000000000087778000000000000a777a00000077777777b7773777777777b700007b7777b777b777b77777737377773737
00000e77777e0000000000009777a00000000008777778000000000000a7779000007b77bc77777737777bc77777000077777777777777777b77777777b77777
0000e777e777e0000000000009777a00000000877787778000000000000a7779000077777777777b377777777b770000777c777cc777c77777777b777777777b
000e777e7e777e0000000000009777a00000087778787778000000000000a777900077777777777777c7777777770000777777c7777777c7777c7777c7777777
0087778777877780000aaaa99999777a0000e777e777e777e00009999aaaaa777900777777cb77b77777bc7777b700007b77b77777b7b7777777777777777777
087778877788777800a7777a7777a777a00e777ee777ee777e00977779777797779077b7777773777737777737770000777777777777777777b737377b777373
87778087778087778a777777a7777a777ae777e0e777e0e777e97777779777797779777777777377773777773777000077b7777b7b777b777777373777777373
87780087e780087780a7777a7777a777a0e77e00e787e00e77e097777977779777907777bc7773777737cb7737770000777777c7777777c7c7773737777c7373
8880008e7e800088800aaaa99999777a00eee000e878e000eee009999aaaaa777900777777777377773777773777000077c77c777c77777c7777373777777373
000000e777e0000000000000009777a00000000087778000000000000000a7779000777b777777777b777777777700007777777777777777777b373777b77373
000000e777e000000000000009777a00000000008777800000000000000a77790000777777cbb77777777cb7b777000077c7b7777c77b7777777373b7777b373
000000e777e00000000000009777a00000000000877780000000000000a777900000777777777c77b77777777c770000777b7777777b7777c7777777c7777777
000000e777e0000000000009777900000000000087778000000000000a777a0000007772777777c777777777777c000077c777777c7777777777777777777777
0000000e7e00000000000009779000000000000008780000000000000a77a00000000000731737737737737737370000b77777b777b7b777b7777337b7773377
00000000e000000000000009990000000000000000800000000000000aaa0000000000007317377377377377373700007777777c77777c777777733777773377
0000000055500000000000000600000000076666200762072007662eeeeeeeeeee000000777737737737777737370000777777777777777777c773377c773377
0000000500500000000000006060000000666666620662066266662eddddedddde000000777737737737777737370000b7777b777b7777b77777733777773377
0000005000500000000000060006000000662226620662066666662eddddedddde000000c7b73773773777cb373700007777777c7777777c7b77733777b73377
0000060005000000000000060006000000662006620662066662662eddddedddde000000777737737737777737370000777c7777777c77777777733777773377
0000600050000000000000060006000000662006620662062622662eddddedddde000000777737737c777777373700007b7733777b773737777c7337777c3377
0006000500000000000000060006000000266666220662062220662211112111120000007b7c37737777cb773737000037773377377737377777733777773377
006000555556666005550005606500055502222220022202200022221111211112000000777737733777777737370000377733773777373777b773377b773377
06000600006000060500500506050050057666620076666276666202111121111200000077773773377777773737000037773377377737377777733777773377
600060000600000065000505000505000566666626666662662266222222222222000000c7b73773377777bc3737000077773377777737377c777337c7773377
06000600006000060050005500055000506622662662222266206627620662766666200077773773773777773737000077773377777737377777733777773377
0060005555566660000500050005000500662062266200006620662662066266666620007777777777377777777700007777337777773737777b7777777b7777
0006000500000000000060006060006000666662066200006666622266662222662220007b7c77777737bc777777000077773377777737377777777777777777
000060005000000000000600060006000066226622666620662222002662200066200000777777b7777377777b770000b7777777777b7777c777777777c77777
00000600050000000000006000006000002220222022222022200000666620006620000077777c7777737777777c000077777777777777777777777777777777
000000500050000000000006000600000007eee207eeee207eeee20662266200662000001737b7777337737377b70000777b7b7777b777b7b777777b7b777b77
00000005005000000000000060600000000eeee20eeeeee2eeeeee222202220022200000173777777337737377770000777777c77777777c77c777c77c777777
0000000055500000000000000600000000022ee202222ee22222ee2000000000001000001737777773377373777700007777777777777777777b7c7777b77777
0000000066600000000000000500000000000ee20000ee2200eee2200030000001d1000017377773733773733377000077b7b777777b777b7777777777c77777
0000000600600000000000005050000000000ee2000ee2200022ee2003b300001dcd1000173777737337737333770000777777c7777777c7b77777b77b77777b
0000006000600000000000050005000000000ee200eeeee20eeee2203b7b3001dc7cd100173777737337737333770000c7777777c777777777c77c777c777777
0000050006000000000000050005000000000222002222220222220003b300001dcd10007777777373377373337700007b7773737b773773777bc77777b77777
0000500060000000000000050005000000007ee207eeeee207eee2000030000001d100007777777c733773733377000077737373773737737777777777c77777
00050006000000000000000500050000000eeee20eeeeee2ee22220000000000001000001773773737737777777b00007773737377373773b777b777b777777b
00500066666555500666000650560006660eeee20eee2222eeeee200000000000000000017737737377377777777000077737373773737737777777777777777
0500050000500005060060060506006006ee22e202eeee20eeeeee200020000000000000777377373773777777b70000777373737737377377b77777777b7777
5000500005000000560006060006060006eeeeee20222ee2e222ee20028200000090000013777737377377777777000077777373777737737777777777777777
0500050000500005006000660006600060222ee220eeee222eeee22028e8200009a9000013777737377377777b77000077377373737737737b7777b7b7777b77
005000666665555000060006000600060000022200222220022222028e7e82009a7a9000737777373773777777770000773773737377377377777b7b7777b7b7
00050006000000000000500050500050007eeeee207eee2007eee20028e8200009a900003777777737737777b777000077377373737737737777777777777777
0000500060000000000005000500050000eeeeee2eeeeee2eeeeee200282000000900000377777773773777777770000777777777777777777b77777777b7777
00000500060000000000005000005000002222e22ee22ee2ee22ee200020000000000000777377b7737777b77737000077b77b77b7777b773773777773377777
0000006000600000000000050005000000000ee202eeee222eeeee2000000000000000007773777773777777773700007777c7777777777c3773777773377777
000000060060000000000000505000000000ee220ee22ee20222e22dddddddd666666660777777777777777777370000777777777777777737737b777337777b
000000006660000000000000050000000000ee2002eeee2200ee220dddddddd66666660077777c7777777c77773700007b7777b77b7777b73773777773377777
0000000066600000000000000700000000002220002222200022200dddddddd66666600077bcb777c77b77b7773700007777c7777777c7773773b77773377b77
0000000600600000000000007070000000078888178888107888881dddddddd666660000777777777777777777370000c777777777c77777c7777b77777c77b7
0000006000600000000000070007000000888888188888818888881dddddddd6666000007777777777777777777c00007b777733777b73737b77777777b77777
0000070006000000000000070007000000881111188118818811111dddddddd6660000007bc7777cbc77c777777700007773773377377373777c77737c773777
0000700060000000000000070007000000881088188108118888810dddddddd66000000077777737777777733777000077737733773773737737777337773777
0007000600000000000000070007000000881088188888108811110dddddddd60000000077777737777777733777000077737733773773737737777337773777
007000666667777006660006000600066618888818811881888881066666666000000000bc77773777cb77733777000077777733777773737737777337773777
07000000000000070600600600060060060111111111011111111106666666000000000077777737777777733777000077777733777773737737777337773777
70000000000000007600060600060600060078810788888107eee20666666000000000007777773777777773777b000077777733777773737737777337773777
070000000000000700600066000660006008888818888881eeeeee266666000000000000c77b7b77b77c7777777700007777773377777373777b7773777b7777
007000666667777000060006000600060008818811188111ee22ee266660000000000000777777777777777777b70000777b7777b77777777777777777777777
000700060000000000007000000000700088118810088100ee20ee2666000000000000007777c777777777c77777000077777777777777777777777777777777
000070006000000000000700000007000088888810088100ee20ee26600000000000000077317b77777377b773770000b77777b77b77b7777373777773377777
0000070006000000000000700000700000811188100881002eeee226000000000000000077317777777377777377000077777c7777777c777373777773377777
0000006000600000000000070007000000110011100111000222220000000000000000007777777777777777737700007777777777777777737377b773377b77
0000000600600000000000007070000000e200e882e827810e8888276666627666662000777777b777777b777377000077b7777b77b777b77373777773377777
0000000066600000000000000700000000882888828828818888882666666266666620007bc77777b77c77777377000077777c777777777c7373777b7337b777
0000000077700000000000000600000000888888828828818882222662222266222220007777777b7777777b73770000777c7777777c7777737377b773377b77
000000070070000000000000606000000088882882882881288882066666206666620000777777777777777777c7000077b7373777b773377777777777777777
000000700070000000000006000600000082822882882111022888266222206622220000bc7777b777cb77b777770000b7773737b77773377777377777777773
00000600070000000000000600060000008222088288288108888226666620662000000077777377777737773777000077773737777773373737377737737773
000060007000000000000006000600000022000222222111022222022222202220000000777773777777377737770000777c3737c77773373737377737737773
000600070000000000000006000600000000000000070000000000000000006000000000c77b7377bc7737773777000077c737377c7773373737377737737773
0060007777766660077700070007000777000000007070000000000000000606000000007777737777773777377700007c77373777c773373737377737737773
06000000000000060700700700070070070000000700070000000000000060006000000077777777777777777b77000077773737777773373737377737737773
60000000000000006700070700070700070000007000007000000000000600000600000077bc777bc77b7b7777770000777b3737777b7337777b377777b77773
060000000000000600700077000770007000000070000070000000000006000006000000777777c7777777c7777b000077773737777773377777777777777777
0060007777766660000700070007000700000000700000700000000000060000060000007777c7777777777c7777000077777777777777747777777777777777
0006000700000000000060000000006000777700700000700777766660060000060066667317737377373737773700007b77b77777b700007337777773737777
00006000700000000000060000000600007000707000007070007600060600000606000673177373773737377737000077777777777700007337777773737777
0000060007000000000000600000600000700007700000770000760000660000066000067777737377773737773700007777777b7777000073377b77737377b7
000000700070000000000006000600000070000070000070000076000006000006000006777773737777373777370000b7777c777b7700007337777773737777
000000070070000000000000606000000007000000000000000700600000000000000060bc777373c7b737377737000077777777777700007337b7777373777b
000000007770000000000000060000000000700000000000007000060000000000000600777773737777373777370000777c777b777c000073377b77737377b7
00000000000000000000000000000000000007000000000007000000600000000000600077777373777737377c77000077c7777777c700007337777773737777
000000000000000000000000000000000000007000000000700000000600000000060000c77b73737b7c37377777000037777737377700007337777b7373b777
89a7a980888888888888880000888888000000070000000700000000006000000060000077777373777737377773000037777737377700007337777773737777
89a7a980999999999999998008999999000000007000007000000000000600000600000077777373777737377773000037777737377700007337b77773737b77
89a7a980aaaaaaaaaaaaaa9889aaaaaa000000000700070000000000000060006000000077bc7373c7b737377773000077777777777700007337777773737777
89a7a9807777777777777a9889a7777700000000007070000000000000000606000000007777737377773737737700007777777777770000733777b7737377b7
89a7a980aaaaaaaaaaaa7a9889a7aaaa00000000000700000000000000000060000000007777777777777777737700007777b777777700007777777777777777
89a7a98099999999999a7a9889a7a99900000000000777700000000000000066660000007bc777777b7c77777377000077777c77777700007777b7777777777b
89a7a98088888888889a7a9889a7a98800000000007000700000000000000600060000007777b777777777b73777000077b777c77b7700007777777777777777
89a7a98000000000089a7a9889a7a980000000000700007000000000000060000600000077777c7777777c77377700007777777b777700007777737377773737
89a7a98000000000089a7a98089a7a980000000070000070000000000006000006000000377377b77737b77773730000b7777777777b0000b777737377b73737
89a7a98888888888889a7a98089a7a98000000070000070000000000006000006000000037737777773777777373000077777777777700007c7773737c773737
89a7a99999999999999a7a98089a7a9800000070000070000000000006000006000000003773777777377777737300007777b7777777000077c77373c7773737
89a7aaaaaaaaaaaaaaaa7a98089a7a98000007000007777777000000600000666666600037737733773773777373000077c77c7777c700007777737377773737
89a777777777777777777a98089a7a98000070000000000000700006000000000000060037737733773773777373000077777777777700007b777373777b3737
89aaaaaaaaaaaaaaaaaaaa98089a7a980007000000000000000700600000000000000060377377337737737773730000b777777b777b000077c7737377c73737
089999999999999999999980089a7a98007000000000000000007600000000000000000637737733777773777373000077c7777777c70000777c73737c773737
008888888888888888888800089a7a980007000000000000000700600000000000000060377377337777777c7373000073777377377700007777737377773737
12e7e2100000012e7e2100000000000000007000000000000070000600000000000006007777b77737777737373700007377737737770000777b737377b73737
12e7e2100000012e7e21000000000000000007000007777777000000600000666666600077777777377777373737000073777777377700007777737377773737
12e7e2100000012e7e21000000000000000000700000700000000000060000060000000077777b7737777737373700007377777b377700007777737377773737
12e7e2100000012e7e21000000000000000000070000070000000000006000006000000077777777773777373737000077777777777700007777737377773737
12e7e2100000012e7e210000000000000000000070000070000000000006000006000000777777b77737773737370000377777c77737dd667b77737377b73737
12e7e2100000012e7e210000000000000000000007000070000000000000600006000000777777777737773737370000377777777737dd66777b7777b7777777
12e7e2100000012e7e2100000000000000000000007000700000000000000600060000007777777b777377773737000037777b77773766dd7777777777777777
12e7e2100000012e7e21000000000000000000000007777000000000000000666600000077777777777377773734000077777777777766dd7777777777777774
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d3d1d1d1d1d1d1d1d1d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d00000000000000000e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d00000000000000000e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d00000000000000000e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d00000000000000000e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d00000000000000000e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000d00000000000000000e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f200000000000000e0e1e1e1e1e1e1e1e1e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000f1f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000001023510235102351023510235102351023510235102351023510235102351023510235102351023510235102351023510235102351023510235102351023510235102351023510235102351023510235
011000000923509235092350923509235092350923509235082350823508235082350823508235082350823507235072350723507235072350723507235072350623506235062350623506235062350623506235
011000000923509235092350923509235092350923509235092350923509235092350923509235092350923509235092350923509235092350923509235092350923509235092350923509235092350923509235
011000000920509205092050920509405094050940509405084052323523235202052323523235172351723507205072050720507205072050720507205072050620523235232350820523235232351723517235
0110000009205092050920509205094050940509405094050840528235282352020528235282351c2351c23507205072050720507205072050720507205072050840528235282352020528235282351c2351c235
0110000009205092050920509205092050920509205092050620528235282352820028235282351c2351c235082052d205282052720526205262052420524205062052d235282352723526230262322623524235
0110000009205092050920509205094050940509405094050840523235232352020523235232351723517235072050720507205072050720507205072050720506205212351c2351b2351a2301a2321a23518235
01100000212302123221232212352320023235242352d2352c2302c2322c2322c2352c2002823228232282352b2302b2322b2322b2322b2322b2352b200072052a2302a2322a2322a2322a235242322423224235
01100000152301523215232152351720017235182352123520230202322023220235202001c2321c2321c2351f2301f2321f2321f2321f2321f2351f2001f2051e2301e2321e2321e2321e235182321823218235
011000002823028230282302823228232282322823228232282322823228232282352c2002820228202282052123521235212302123521235212352123021235212352123521230212351f235212322123221235
011000001c2301c2301c2301c2321c2321c2321c2321c2321c2321c2321c2321c2352c2002820228202282051c2351c2351c2301c2351c2351c2351c2301c2351c2351c2351c2301c2351a2351c2321c2321c235
01100000212302123221232212352320023235242352d2352c2302c2322c2322c2352c2002823228232282352b2302b2322b2322b2352b2023023230232302352a2302a2322a2322a2352a205302323023230235
01100000152301523215232152351720017235182352123520230202322023220235202001c2321c2321c2351f2301f2321f2321f2352b2052423224232242351e2301e2321e2321e2351e205242322423224235
011000002d2302d2302d2302d2322d2322d2322d2322d2322d2322d2322d2322d2352c2002820228202282052123521235212302123521235212352123021235212352123521230212351f235212322123221235
01100000212022120521232212351f2352123524202242302423224232242322423224232242352820228205212022120521232212351f2352123523202232302323223232232322323223232232352120221205
011000001c2021c2051c2321c2351a2351c2351f2021f2301f2321f2321f2321f2321f2321f23528202282051c2021c2051c2321c2351a2351c2351e2021e2301e2321e2321e2321e2321e2321e2352120221205
01100000212022120521232212351f23521235242022423024235232322323526232262352323223235242302423224232242322423224232242322423224232242322423224232242351f205212022120221205
011000001c2021c2051c2321c2351a2351c235242021f2301f2351e2321e23521232212351e2321e2351f2301f2321f2321f2321f2321f2321f2321f2321f2321f2321f2321f2321f2351e2021e2051f20521202
011000002123021230212302123221232212322123221232212322123221232212352c2002820228202282051c2351c2351c2301c2351c2351c2351c2301c2351c2351c2351c2301c2351a2351c2321c2321c235
011000201504315003150430c00015043150430c605150431504315003150430c00015043150432d645150431504315003150430c00015043150430c605150431504315003150430c00015043150432d64515043
011000201804318603180431860318043180431860518043180432100318043180001804318043246451804318043186031804318603180431804318605180431804318003180431800018043180432464518043
011000000923509235092350923509235092350923509235092350923509235092350923509235092350923508235082350823508235082350823508235082350823508235082350823508235082350823508235
0110002015240152451c2451a2401a24521240212451c2401c2421c2421c2452b2001f24521245232452624026242262452424523240232451f2401f24522240222422224521240212451f2401f2451d2401d245
011000000e3400e3450e34509340093450e3400e3450c3400c34513340133451834018345133450c3400c34513340133451334515340153451534015345163401634511340113450e3400e345113450a34516345
0110002015240152451c2451a2401a24521240212451c2401c2421c2421c2452b2001f24521245232452624026240262452424523240232451f2401f245222402224029240292452924029245292452b24529245
011000000e3400e3450e34509340093450e3400e3450c3400c34513340133451834018345133450c3400c3451334013345133451534015345153401534516340163421634516340163450c345183450c3450d345
01100020281402814528100251402514523145251452c1402c1422c1452c1052c100001002c1002c1422c1452b1422b1422b145231422314521140231452a1402a1422a1422a1452910229140291422914529105
01100020281422814528100251402514523145251452c1402c1422c1450010000100001002c1002c1422c1452b1422b1422b145231402314521140231452a1402a1422b1452d1452a1422a105291402914229145
011000001a745157451a745157451a745157451a745157451c745177451c745177451c745177451c745177451f7451a7451f7451a7451f7451a7451f7451a745257472b7472d7472b747257472b7472d7472b747
011000001a7471e74721747267472a7472d7473274736747187471c7471f74724747287472b7473074734747177471a7471f747237472174726747287472d7472e747297472674722747327472e7472974726747
011000001e7451f74521745267452673526725287452674526745267452673526735267252672526705177051e7451f74521745267452673526725287452674526735287452574521745257452b7452d7452b745
011000000e3300e33509330093350e3300e335093300933510330103350b3300b33510330103350b3300b33513330133350e3300e33513330133350e3300e335153301533510330103350d3300d3350933009335
011000000e3300e33509330093350e3300e335093300933510330103350b3300b33510330103350b3300b33513330133351333013335133301333513330133351533015335173301733518330183351933019335
011000001a3301a335153301533512330123350e3300e33510330103351733017335103301033517330173351333013335133301333513330133350e3300e3351533015335103301033519330193351c3301c335
011000001a3301a335153301533512330123350e3300e335103301033517330173351c3301c33510330103351033010335173301733513330133351a3301a335153301533510330103350e3300e3350d3300d335
011000001333013335153001233012335123050e3350933009335153350933515335093351533509335153351333013335153001233012335123050e3350933009335153350b335173350c335183350d33519335
011000202b5452d5402d545285452a5402a54525545285452a545235452154523545215452354529540295452b5452d5402d545285452a5402a545265452d5452d5452d5352d5252d5252d5402d5422d5451d205
011000201e5452b5452b5452d5452d5452d5452f5452f545345452d5452d5452b545345452d5452d5452b5452a5452b5452b5452d5452d5452d5452f5452f545345452d5452d5452b54534545395453954539545
011000203463518003180433463534605180431804318003346351800318043346353460518043180431800334635180031804334635346051804318043180033463518003180433463534635180431804334635
011000202813228132271322313228132271322313228132271322313228132271322313228132271322313228132281322713223132281322713223132281322713223132281322713223132281322713223132
011000202813228132271322313228132271322313228132271322313228132271322313227132281322713223130231322313223132231322313521130231302513025132251352313023132231352013020135
01100020281322813227132231322813227132231322813227132231322813227132231322713228132271322f1302f1322f1322f1322f1322f1322f1322f1350810020102201022010220102201022010220105
011000200634006345063450634506345063450634506345063450634506345063450634506345063450634508340083450834508345083450834508345083450834508345083450834508345083450834508345
01100020093400934509345093450934509345093450934509345093450934509345093450934509345093450b3400b3450b3450b3450b3450b3450b3450b345093400934509345093450b3400b3450b3450b345
01100020093400934509345093450934509345093450934509345093450934509345093450934508345093450b3400b3450b3450b3450b3450b3450b3450b345083400834508345083450834508345063450b345
01100020281402814523145281452f1402f145231452714528140281422814228142281422814523145271452814028145231452f145231452d1452c1452a145281402814228142281452810527145281452a140
011000202c1402c1402c1422c1422c1422c1422c1422c1422c1422c1422c1422c145281022810527145251452714027145281452514025142251422514525145271402714528140281452a1402a1452c1402c145
011000202c1402c1402c1422c1422c1422c1422c1422c1422c1422c1422c1422c145281022810527145251452714027145281452514025142251422514525145231402314223142231422314223145281002a100
01100020093400934009342093420934209342093420934209342093420934209342093420934508345093450b3400b3400b3420b3420b3420b3420b3420b3420b3420b3420b3420b3420b3420b345093450b345
011000200d3400d3450d3450d3450d3450d3450d3450d3450d3450d3450d3450d3450d3450d3450b3450d34509340093450934509345093450934509345093450834508345083450834508345083450b34509345
011000200d3400d3400d3420d3420d3420d3420d3420d3420d3420d3420d3420d3420d3420d3450d3450b34509340093420934209342093420934209345093450b3420b3420b3420b3420b3420b3420b3420b345
01100020093400934509345093450934509345093450934509345093450934509345093450934508345093450b3400b3450b3450b3450b3450b3450b3450b3450b3450b3450b3450b3450b3450b345093450b345
011000200634006345063450634506345063450634506345063450634506345063450634506345063450634508340083450834508345083450834508345083450834508345083450834508345083450834508345
01100020093400934509345093450934509345093450934509345093450934509345093450934509345093450b3400b3450b3450b3450b3450b3450b3450b345093400934509345093450b3400b345093450b340
011000202d1402d1422d1422d1422d1422d1452c1452d1452f1422f1422f1422f1452a1402a14528140281452c1402c1422c1422c1422c1422c1452a1452c1452d1402d1422d1422d1452c1402c1452714027145
0110002028140281422814228142281422814527145281452a1422a1422a1452c1422c1422c1452d1402d14534140341423414234142341423414234142341453314033142331423314233142331423314233145
011000201804318043346053463534605346351804334635346053463534605346353460534635180033463518043180433460534635346053463518043346353460534635346053463534605346351800334635
011000202860228602276022310228102271022310228102271022c1052c5452c5452c5452a5422a5452754528542285452f50223505235002150520505285022750223502287022770223702286022760223602
011000201804318043346053463534635346051804334635346053463534605346353460534635180033463518043180433460534635346353460518043346353460534635346053463534605346353463534635
011000202c54228542255422c54228542255422c542285422c54228542255422c54228542255422f5422f54228542275422354228542275422354228542275422854227542235422854227542235422854227542
011000202c54228542255422c54228542255422c542285422c54228542255422c54228542255422f5422f5422d5422d5422d5422d5422d5422d5422c5422a542285422854228542285422a5422a5422c5422c542
011000202d5322d5322d5322d5322d5322d5322d5322d5322d5322d5322d5322d5322d5322d5322d5322d5352f5322f5322f5322f5322f5322f5322f5322f5322f5322f5322f5322f5322f5322f5322f5322f535
01100020315323153231532315323153231532315323153231532315323153231532315323153231532315352f5322f5322f5322f5322f5322f5322f5322f5352f5322f5322f5322f5322f5322f5322f5322f535
000400002505225052250522405024050230502205021050200501f0501d0501d0501c0501b0501a0501905018050180501705016050140501305012050100500f0500d0500a0500905007050040500205001050
__music__
00 41 42 43 14
01 00 03 04 14
00 00 05 06 14
00 01 07 08 13
00 02 09 0a 13
00 01 0b 0c 13
00 02 12 0d 13
00 15 0e 0f 13
00 02 10 11 13
00 00 03 04 14
00 00 05 06 14
00 01 07 08 13
00 02 09 0a 13
00 01 0b 0c 13
00 02 12 0d 13
00 15 0e 0f 13
00 02 10 11 13
04 41 42 43 13
00 16 17 43 1d
00 18 19 43 1d
00 1a 1c 1f 26
00 1b 1c 20 26
00 1a 1e 21 26
00 1b 1e 22 26
00 41 24 43 23
00 41 25 43 23
00 16 17 1d 26
00 18 19 1d 26
00 1a 1c 1f 26
00 1b 1c 20 26
00 1a 1e 21 26
00 1b 1e 22 26
00 41 24 23 26
00 41 25 23 26
00 16 42 43 1d
04 18 42 43 1d
01 27 2a 43 38
00 28 2b 43 38
00 27 2a 43 38
00 29 2c 43 38
00 41 30 2d 39
00 3b 32 2f 3a
00 39 33 2d 3a
00 3c 31 2e 3a
00 3d 34 36 3a
00 3e 35 37 3a
00 27 2a 43 38
00 28 2b 43 38
00 27 2a 43 38
00 29 2c 43 38
00 41 30 2d 39
00 3b 32 2f 3a
00 39 33 2d 3a
00 3c 31 2e 3a
00 3d 34 36 3a
00 3e 35 37 3a
04 41 42 43 38
02 41 42 43 38
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
