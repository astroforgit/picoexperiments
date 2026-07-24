pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- cargobot v.1.0
-- by peter antoine

-- modes
m_idle = 0
m_running = 1
m_solved = 2
m_crashed = 3
m_debugging = 4
m_run_or_debug = 5

gs_show_splashscreen = 0
gs_show_game_info = 1
gs_select_level = 2
gs_playing = 3
gs_level_finished = 4
gs_show_hint = 5

categories = {"tutorials","easy","medium","hard","crazy","impossible","bonus"}
a_right,a_left,a_down,a_reg1,a_reg2,a_reg3,a_reg4,a_empty,a_up = 26,27,28,42,43,44,45,46,99 --actions
c_has_red,c_has_yellow,c_has_green,c_has_blue,c_has_any,c_has_none,c_empty = 9,10,11,12,13,14,15 -- conditions
actions = { a_empty, a_down, a_right, a_left, a_reg1, a_reg2, a_reg3, a_reg4 }

current_level = 1
star_count = 0
start_y = 25 
registers = {}
frame_speed = 4
f,df = 0,0 -- frame, debug_frame

info_index = 1 
info_text = "cargobot is a puzzle game\nwhere the player commands a\nrobot to sort crates. if you\nstock the crates too high the\nrobot will crash. the robot\nwill also crash into the side\nof the wall when the incorrect\ninstructions are given.\n\nthere are 40 levels. each\nlevel can be solved in many\nways. the goal is to earn 3\nstars for each level by\nsolving the level in as few\nregisters as possible."

function _init()	
	cartdata("troske007_cargobot_1") -- earned stars
		
	max_piles = 8
	max_voids_between = max_piles-1
	
	ds_max_width = (max_piles*3+max_voids_between*2)	
	ds_center_of_max_width = ds_max_width\2
	
	wip_offset_x = 14
	wip_offset_y = 42			
	wip_pile_width = 9
	wip_void_width = 6
	wip_max_width = (max_piles*wip_pile_width+max_voids_between*wip_void_width)
	wip_max_height = 49 	
	wip_center_of_max_width = wip_max_width\2
	
	gs = gs_show_splashscreen
	
	initialize()	
	load_level(current_level) 
end

function add_menu()
	menuitem(1, get_speed(), mnu_speed_crane)
	menuitem(2,"select level", mnu_select_level)	
	menuitem(3,"hint", mnu_show_hint)	
end

function clear_menu()
	for i=1,3 do 
		menuitem(i)
	end
end

function get_speed()
	if (frame_speed == 1) return "robot ‹fast‘"
	if (frame_speed == 4) return "robot ‹normal‘"
	if (frame_speed == 30) return "robot ‹slow‘"	
end

function mnu_speed_crane(b)
	if (b&1 > 0) then
		if (frame_speed == 1) then frame_speed = 4
		elseif (frame_speed == 4) then frame_speed = 30		
		end
	elseif (b&2 > 0) then
		if (frame_speed == 30) then frame_speed = 4
		elseif (frame_speed == 4) then frame_speed = 1		
		end
	end		
	menuitem(1, get_speed(), mnu_speed_crane)
end

function mnu_select_level()		
	save_level_progress(current_level)	
	clear_menu()
	gs = gs_select_level
end

function mnu_show_hint()
	clear_menu()	
	gs = gs_show_hint
end

function initialize()
	cursor={x=0,y=0}	
	rp,ap,tp=1,1,1  -- register_pointer, action_pointer, tmp_pointer
	tmp = {}	    -- sub_actions	
	ffsa = false    -- fast_forward_sub_actions
	noau = 0		-- nr_of_actions_used
	jump_stack = {} 
	mode = m_idle
	crash_location=nil
	
	--registers
	for r=1,4 do
		registers[r] = {}
		local n=8
		if (r==4) n=5
		for i=1,n do
			add(registers[r], create_command(a_empty, c_empty))			
		end
	end	
end

function load_level(n)	
	cps={}
	so=0

	local nd = normalize_data(levels[n].data)
	level = { stacks=nd.stacks, solution=nd.solution, name=levels[n].name, conditions=split(levels[n].conditions), init_x=levels[n].init_x, stars=levels[n].stars, min_x=-1, max_x=-1, reg=levels[n].reg, hint=levels[n].hint }
	for x=0, 7 do
		if (level.stacks[x+1] != -1) then
			if (level.min_x == -1) then
				level.min_x = x
			else
				level.max_x = x
			end
		end
	end
	c = { x=level.init_x, y=0, crate=nil } --crane	

	nr_of_piles = level.max_x-level.min_x+1
	
	ds_start_x=ds_center_of_max_width-((nr_of_piles*4+(nr_of_piles-2))\2)	-- {8,13,18,23,28,33,38}
	wip_start_x=wip_center_of_max_width-((nr_of_piles*15+9)\2)				-- {24,39,54,69,84,99,114}

	star_count = load_star_count(n)
end

function normalize_data(data)
	local dp = split(data,"|",false)		
	return {stacks = convert(split(dp[1],",",false)), solution=convert(split(dp[2],",",false))}	
end

function convert(data) -- table_of_strings
	for i=1, #data do
		local r = {}  
		if (#data[i] == 1) then
			if (data[i] == "4") then
				r=-1
			elseif (data[i] == "0") then
				r={}
			else
				add(r, sub(data[i],1,1))
			end
		else 
			for j=1,#data[i] do
				add(r, sub(data[i],j,j))
			end
		end
		data[i] = r
	end	
	return data
end

function _update60()
	if (gs == gs_playing) then		
		update_crane_particles()

		if (mode == m_running) then
			f+=1					
			-- stop running
			if (btnp(Ž))  then
				mode = m_idle
				f=0
				load_level(current_level)
			-- running
			elseif (f%frame_speed==0) then			
				handle_process()
				f=0
			end

		elseif (mode == m_debugging) then
			if (ffsa) then
				df+=1
				if (df%1==0) then			
					handle_process()
					df=0
				end
			else
				-- stop debugging
				if (btnp(Ž))  then
					mode = m_idle
					df = 0
					load_level(current_level)
				-- step by step
				elseif (btnp(—)) then
					handle_process()
				end
			end

		elseif (mode == m_run_or_debug) then			
			if (noau > 0) then
				-- run			
				if (btnp(—)) then
					process_action()
					mode = m_running

				-- debug step by step
				elseif (btnp(Ž))  then								
					process_action()
					mode = m_debugging  				
				end
			elseif (btnp(Ž)) then
				mode = m_idle
			end

		-- crashed		
		elseif (mode == m_crashed) then
			if (btnp(Ž))  then
				mode = m_idle
				f=0
				df=0
				load_level(current_level)
			end

		-- building
		elseif (btn(—)) then
			local a_index = index_by_val(actions, registers[cursor.y+1][cursor.x+1].action)
			local c_index = index_by_val(level.conditions, registers[cursor.y+1][cursor.x+1].condition)
			if (btnp(ƒ)) then
				if (a_index == #actions) then a_index = 1 else a_index += 1 end
				registers[cursor.y+1][cursor.x+1] = create_command(actions[a_index], level.conditions[c_index])  		
				sfx(4)
			elseif (btnp(”)) then
				if (#level.conditions > 1) then 					
					if (c_index == #level.conditions) then c_index = 1 else c_index += 1 end
					registers[cursor.y+1][cursor.x+1] = create_command(actions[a_index], level.conditions[c_index])  			
					sfx(5)
				else
					sfx(3)
				end
			elseif (btnp(‹)) then 				
				if (registers[cursor.y+1][cursor.x+1].action != a_empty or registers[cursor.y+1][cursor.x+1].condition != c_empty) then					
					registers[cursor.y+1][cursor.x+1].action = a_empty
					registers[cursor.y+1][cursor.x+1].condition = c_empty
					sfx(6)
				else
					sfx(3)
				end
			end		

		--starting (when m_idle)
		elseif (btnp(Ž)) then  -- start_playing   
			noau = get_nr_of_actions_used()			
			rp,ap,tp=1,1,1 --register_pointer, action_pointer, tmp_pointer
			tmp={}		
			jump_stack = {}			
			mode = m_run_or_debug

		-- navigating		
		else 
			if (btnp(‹)     and cursor.x > 0) then cursor.x -= 1
			elseif (btnp(‘) and ((cursor.y==3 and cursor.x < 4) or (cursor.y!=3 and cursor.x < 7))) then cursor.x += 1
			elseif (btnp(”) and cursor.y > 0) then cursor.y -= 1
			elseif (btnp(ƒ) and ((cursor.y==2 and cursor.x < 5) or (cursor.y<2 and cursor.x < 8))) then cursor.y += 1			
			end  		
		end	

	elseif (gs == gs_level_finished) then
		if (btnp(—)) then
			save_level_progress(current_level)	
			gs = gs_select_level
		end  	

	elseif (gs == gs_select_level) then
		if (btnp(—)) then 
			initialize()	
			load_level(current_level) 		
			load_level_progress(current_level)
			add_menu()
			gs = gs_playing			
		elseif (btnp(‹)) then change_level(1)
		elseif (btnp(‘)) then change_level(2)
		end  	

	elseif (gs == gs_show_hint) then
		if (btnp(—)) then
			add_menu()
			gs = gs_playing
		end  	
	
	elseif (gs == gs_show_game_info) then
		if (btnp(—)) then
            if (info_index == 2) then
				gs = gs_select_level
            else
                info_index += 1
            end
        end        

	elseif (gs == gs_show_splashscreen) then
        if (btnp(—)) then
            gs = gs_show_game_info            
        end  
	end
end

function handle_process()	
	if (#tmp > 0) then
		if (mode == m_debugging) then
			if (tmp[1].action == a_down or tmp[1].action == a_up) then
				ffsa = true
			end
		end		
		process_sub_action()
		
	else
		if (mode == m_debugging and ffsa) then
			ffsa = false
		end
		if (ap > #registers[rp]) then
			-- nothing to do anymore, wait until user stops
		else
			-- activate next action
			ap+=1
			if (ap <= #registers[rp]) then				
				if (registers[rp][ap].action != a_empty) then
					process_action()
				else
					-- ignoring a_empty
					if (mode == m_debugging) then
						ffsa = true
					end
				end	
			elseif (ap > #registers[rp]) then
				-- end of current register, go back to previous if any
				if (#jump_stack > 0) then
					rp = jump_stack[#jump_stack].rp
					ap = jump_stack[#jump_stack].ap
					deli(jump_stack, #jump_stack)
					if (ap < #registers[rp]) then
						ap += 1						
						process_action()
					end								
				end
			else					
				mode = m_idle
			end
		end
	end
end

function create_command(action, condition)
	local cmd = {}
	cmd.action = action
	cmd.condition = condition
	return cmd
end

function process_action()	
	-- 1. get action by register_pointer and action_pointer
	-- 2. move action to tmp_actions
	-- 3. unfold actions
	-- 3. execute tmp_actions
	-- 4. increment pointers	
	local atp = registers[rp][ap]			
	if (should_perform_action(atp.condition, c.crate)) then	
		if (atp.action == a_down) then
			steps = min(6,7-#level.stacks[c.x+1])
			if (c.crate != nil) then				
				if (#level.stacks[c.x+1] == 6) then 
					mode = m_crashed			
					crash_crane("down");				
				elseif (#level.stacks[c.x+1] > 0) then
					steps -= 1
				end	
			end
			for i=1,steps do	
				add(tmp, atp)
			end
			for i=1,steps do	
				add(tmp, create_command(a_up, c_empty))
			end
		else
			add(tmp, atp) 
		end
	end
end

function should_perform_action(c, cr)	
	if (c == c_empty) return true
	if (c == c_has_any    and cr != nil) return true
	if (c == c_has_none   and cr == nil) return true
	if (c == c_has_red    and cr == "3") return true  
	if (c == c_has_yellow and cr == "1") return true  
	if (c == c_has_green  and cr == "7") return true  
	if (c == c_has_blue   and cr == "5") return true  	
	return false
end

function process_sub_action()
	if (tmp[tp].action == a_down) then		
		c.y+=1
		sfxc()
		if (#tmp==steps) then			
			if (c.crate != nil) then
				add(level.stacks[c.x+1], c.crate) 
				c.crate = nil
			end
		end

	elseif (tmp[tp].action == a_up)	then	
		c.y-=1		
		if (#tmp==steps) then			
			if (c.crate == nil) then
				if (#level.stacks[c.x+1] > 0) then							
					c.crate = level.stacks[c.x+1][#level.stacks[c.x+1]] -- add crate to crane							
					deli(level.stacks[c.x+1], #level.stacks[c.x+1]) 	-- remove crate from stack
				end
			else						
				add(level.stacks[c.x+1], c.crate) 
				c.crate = nil
			end
		end	

	elseif (tmp[tp].action == a_left) then	
		if (c.x-1 >= level.min_x) then
			c.x-=1
		else
			mode = m_crashed			
			crash_crane("left");
		end	

	elseif (tmp[tp].action == a_right) then	
		if (c.x+1 <= level.max_x) then 
			c.x+=1
		else
			mode = m_crashed			
			crash_crane("right");
		end	

	elseif (tmp[tp].action == a_empty) then -- do nothing		
	elseif (tmp[tp].action == a_reg1) then jump_to_register(1)	
	elseif (tmp[tp].action == a_reg2) then jump_to_register(2)
	elseif (tmp[tp].action == a_reg3) then jump_to_register(3)	
	elseif (tmp[tp].action == a_reg4) then jump_to_register(4)
	end
	
	deli(tmp,1) -- remove executed action

	if (is_solved()) then		
		mode = m_solved
		clear_menu()
		local new_star_count = calculate_star_count(current_level)		
		if (star_count < new_star_count) then
			star_count = new_star_count
			save_star_count(current_level)
		end		
		sfx(7)
		gs = gs_level_finished   
	end		
end

function calculate_star_count(lvl)		
	local ac = get_nr_of_actions_used()
	if (ac <= levels[lvl].stars[3]) return 3
	if (ac <= levels[lvl].stars[2]) return 2
	if (ac <= levels[lvl].stars[1]) return 1
	return 0
end

function get_nr_of_actions_used()
	local cnt=0;
	for r=1, #registers do		
		for a=1, #registers[r] do
			if (registers[r][a].action != a_empty) then
				cnt += 1
			end
		end
	end
	return cnt
end

function load_star_count(lvl)
	return dget(lvl)
end

function save_star_count(lvl)
	dset(lvl, star_count)
end

function jump_to_register(r)
	add(jump_stack, {rp=rp, ap=ap})	
	rp,ap = r,1	
	if (registers[rp][ap].action != a_empty) then
		process_action()
	else
		-- ignoring a_empty
		if (mode == m_debugging) then
			ffsa = true
		end
	end		
end

function is_solved()	
	-- hack for level 20: 7 stacked crates allowed as final result in this level	
	if (current_level==20) return (c.x == 0 and c.crate == "7" and tostring(level.stacks) == "        { 1:      { 1:7 2:7 3:7 4:7 5:7 6:7 } 2: { 1:1 } 3: { 1:1 } 4: { 1:1 } 5: { 1:1 } 6: { 1:1 } 7:{ } 8:-1 }") 
	return (tostring(level.stacks) == tostring(level.solution))
end

function change_level(b)
	if (b&1 > 0) then
		if (current_level > 1) then	current_level-=1
		else current_level = #levels
		end
	elseif (b&2 > 0) then
		if (current_level < #levels) then current_level+=1
		else current_level = 1
		end
	end	
	initialize()		
	load_level(current_level)
end

function _draw()	
	if (gs == gs_playing)               then draw_playing()		
	elseif (gs == gs_level_finished)    then draw_level_finished()
	elseif (gs == gs_select_level)      then draw_select_level()
	elseif (gs == gs_show_hint)         then draw_hint()		
	elseif (gs == gs_show_game_info)    then draw_game_info()
	elseif (gs == gs_show_splashscreen) then draw_splashscreen()
	end
end

function draw_playing()
	screen_shake()
	cls(1)	
	draw_solution(4,6,level.solution,5)
	draw_work_in_progress()		
	draw_crane()
	draw_registers()
	draw_cursor()		
	draw_text()	
	draw_crane_particles()  
end

function draw_solution(ox,oy,t,rc)
	rectfill(ox-2, oy-2, ds_max_width-1+ox+2, 14+oy+1, 0)
	rect(ox-2, oy-2, ds_max_width-1+ox+2, 14+oy+1, rc)	
	for y=0,6 do		
		for x=level.min_x, level.max_x do
			pset(ox+ds_start_x+1+((x-level.min_x)*5), oy+y+(y*1), get_pico8_color(t[x+1][7-y]))						
		end
	end			
	for i=0, nr_of_piles-1 do
		for si=0,2 do
			pset(ox+ds_start_x+si+(i*5), oy+14, 15)		
		end
	end	
end

function draw_work_in_progress()
	rect(0,start_y-1,127,85,15)	
	rectfill(0,start_y,127,84,0)
	for y=0,5 do		
		for x=level.min_x, level.max_x do
			if (level.stacks[x+1][6-y] != nil) then
				zspr(level.stacks[x+1][6-y], 2, 2, wip_offset_x+wip_start_x+1+((x-level.min_x)*15), wip_offset_y+2+y+(wip_offset_y-wip_max_height)+(y*7), 0.5)	
			end
		end
	end			
	for i=0, nr_of_piles-1 do		
		line(wip_offset_x+wip_start_x+(i*15), wip_offset_y+wip_offset_y, wip_offset_x+wip_start_x+(i*15)+wip_pile_width-1, wip_offset_y+wip_offset_y, 15)		
	end	
	
	if (nr_of_piles==8) then
		draw_pilar(1, start_y, 9, 4, (mode == m_crashed and crash_location == "left"))
		draw_pilar(123, start_y, 9, 4, (mode == m_crashed and crash_location == "right"))
	else
		draw_pilar(wip_offset_x+wip_start_x-10, start_y, 9, 4, (mode == m_crashed and crash_location == "left"))
		draw_pilar(wip_offset_x+wip_start_x+(nr_of_piles*15), start_y, 9, 4, (mode == m_crashed and crash_location == "right"))
	end
end

function draw_crane()		
	if (mode != m_crashed) then
		line(wip_offset_x+wip_start_x+((c.x-level.min_x)*15)+4, start_y, wip_offset_x+wip_start_x+((c.x-level.min_x)*15)+4, start_y+(c.y*8),7) --arm			
		spr(33,wip_offset_x+wip_start_x+((c.x-level.min_x)*15),start_y+1+(c.y*8),1.5,1)
		if (c.crate != nil) then				
			zspr(c.crate, 2, 2, wip_offset_x+wip_start_x+((c.x-level.min_x)*15)+1, (c.y-1)*8+37, 0.5)							
		end
	end
end

function draw_pilar(x,y,c1,c2,broken)	
	line(x+1,y,x+1,84,c1) 	--hor1
	line(x+2,y,x+2,84,c2) 	--hor2
	line(x,y,x+3,y,c1) 		--hor3
	line(x,y+1,x+3,y+1,c2) 	--hor4
	line(x,83,x+3,83,c1) 	--ver1
	line(x,84,x+3,84,c2) 	--ver2	
	if (broken) then		
		rectfill(x,start_y,x+4,start_y+15,0)						
		if (crash_location == "left") then
			pset(x+1,start_y+15,9)			
		elseif (crash_location == "right") then
			pset(x+2,start_y+15,4)			
		end
	end
end

function draw_registers()
	for y=1, #registers do		
		spr(42+y-1,0,90+(y-1)*10)		
		for x=1, #registers[y] do			
			spr(registers[y][x].condition,9+(x-1)*8+(x-1)*1,88+(y-1)*8+(y-1)*2)
			spr(registers[y][x].action,9+(x-1)*8+(x-1)*1,90+(y-1)*8+(y-1)*2)
		end
	end
	line(0,90,0,126,1)
	line(8,90,8,126,1)
	rectfill(54,118,80,126,1)	
end

function draw_cursor()	
	if (mode == m_idle) then
		if (btn(—)) then -- building
			spr(30, 9+cursor.x*8+(1*cursor.x), 90+cursor.y*8+(2*cursor.y))	
		else -- navigating
			spr(29, 9+cursor.x*8+(1*cursor.x), 90+cursor.y*8+(2*cursor.y))	
		end
	elseif ((mode == m_running or mode == m_debugging) and ap <= #registers[rp] and registers[rp][ap].action != a_empty) then		
		if (registers[rp][ap].condition == c_empty) then
			rect(8+(ap-1)*8+(1*(ap-1)),  89+(rp-1)*8+(2*(rp-1)), 17+(ap-1)*8+(1*(ap-1)), 97+(rp-1)*8+(2*(rp-1)), 10) 					
		else
			rect(8+(ap-1)*8+(1*(ap-1)),  87+(rp-1)*8+(2*(rp-1)), 17+(ap-1)*8+(1*(ap-1)), 97+(rp-1)*8+(2*(rp-1)), 10) 					
		end
	end
end

function draw_text()	
	if (mode == m_idle and btn(—)) then
		printo("build",83,90,9,0)		
		printo("ƒaction",83,98,13,0)
		if (#level.conditions == 1) then
			printo("”condition",83,106,5,0)		
		else
			printo("”condition",83,106,13,0)		
		end
		if (registers[cursor.y+1][cursor.x+1].action != a_empty or registers[cursor.y+1][cursor.x+1].condition != c_empty) then
			printo("‹clear",83,114,13,0)
		else
			printo("‹clear",83,114,5,0)
		end
		--toolbox		
		rect(52,4,119,21,9)
		rectfill(55,2,84,6,1)
		printo("toolbox",56,2,9,0)
		if (#level.conditions > 1) then -- only c_empty
			for i=2, #actions do spr(actions[i],46+((i-1)*8)+((i-1)*1),9) end
		else
			for i=2, #actions do spr(actions[i],46+((i-1)*8)+((i-1)*1),11) end
		end
		for i=1, #level.conditions do
			spr(level.conditions[i],46+(i*8)+(i*1),18)
		end 
	
	elseif (mode == m_run_or_debug) then
		printof("* level "..current_level.." *",44,7,2,0)   				
		printof(level.name,44,16,6,0)
		printo("navigate",83,90,9,0)   
		printo("‹‘”ƒ",83,98,13,0)
		printo("—=change",83,106,13,0)
		printo("Ž=start",83,114,13,0)			
		printo("enter=options",71,122,13,0)		
	
		if (noau > 0) then
			rect(25,49,111,91,0)
			rect(26,50,110,90,11)
			rect(27,51,109,89,0)
			rectfill(28,52,108,88,1)

			printof("start robot...",0,62,9)   				
			printo("—=run",38,78,6,0)
			printo("Ž=debug",68,78,6,0)		
		else
			rect(18,49,108,91,0)
			rect(19,50,107,90,8)
			rect(20,51,106,89,0)
			rectfill(21,52,105,88,1)

			printof("robot cannot start",0,60,9,0)   				
			printof("no actions defined",0,68,9,0)   				
			printo("Ž=back",50,80,6,0)
		end

	elseif (mode == m_debugging) then
		printof("* level "..current_level.." *",44,7,2,0)   				
		printof(level.name,44,16,6,0)		
		printo("debugging..",83,90,11,0)
		printo("   next",83,100,13,0)
		printo("   step",83,108,13,0)
		printo("—=",83,104,13,0)
		printo("Ž=stop",83,118,13,0)	

	elseif (mode == m_running) then
		printof("* level "..current_level.." *",44,7,2,0)   				
		printof(level.name,44,16,6,0)
		printo("running...",83,90,11,0)
		printo("Ž=stop",83,98,13,0)			
		if (f%2==0) then
			printo("\147",83,106,6,0)		
		end

	elseif (mode == m_crashed) then
		printof("* level "..current_level.." *",44,7,2,0)   				
		printof(level.name,44,16,6,0)
		printo("crashed...",83,90,8,0)
		printo("Ž=retry",83,98,13,0)			

	else -- navigating		
		printof("* level "..current_level.." *",44,7,2,0)   				
		printof(level.name,44,16,6,0)
		printo("navigate",83,90,9,0)   
		printo("‹‘”ƒ",83,98,13,0)
		printo("—=change",83,106,13,0)
		printo("Ž=start",83,114,13,0)			
		printo("enter=options",71,122,13,0)			
	end
end

function draw_splashscreen()
	cls(0)  
	local a = {1,3,5,7}  
	for y = 0, 7 do   		
		for x = 0, 7 do  			
			local r = flr(rnd(4)) + 1 			
			zspr(a[r], 2, 2, (x*16), (y*16), 1)		
       end
	end                 	
	rectfill(33,33,94,94,1)
	printo("cargobot",48,40,9,0)   
    printc("v1.0",52,6)    
    printc("by",63,5)    
	printc("peter antoine",73,5)        
	printo("— to start",42,86,7,0)	      
    wait(3)               
end

function draw_game_info()
	cls(1)	
	printof("game info ["..tostr(info_index).."/2]",0,6,7,0)		
	if (info_index == 1) then
		print(info_text,6,20,9)	
		printo("— next page",40,120,7,0)	      
	else		
		print("following actions can be used:",5,20,9)
		rect(5,28,48,49,9)
		for i=0, 2 do spr(26+i,8+i*8+i*2,31) end
		for i=0, 3 do spr(42+i,8+i*8+i*2,40) end
		print("following conditions can be",5,57,9)
		print("used depending on the level.",5,65,9)
		print("the action will only execute",5,73,9)
		print("if the robot is holding:",5,81,9)
		rect(5,90,112,114,9)
		for i=0, 5 do spr(9+i,8+i*8+i*2,94) end 
		print("none",74,98,9)
		print("any color",74,106,9)		
		line(62,97,62,99,9)
		line(62,100,70,100,9)
		line(52,97,52,107,9)
		line(52,108,70,108,9)
		printo("— to start",42,120,7,0)	      
	end	
end

function draw_hint()
	cls(1)	
	printof("hint",0,2,7,0)	
	print(level.hint,5,12,9)	
	printo("— to start",42,120,7,0)	      
end

function draw_level_finished()
	cls(1)	
	printof("! level finished !",0,10,11,0)	
	draw_work_in_progress()		
	draw_crane()
	printof("you earned "..star_count.." stars",0,96,9,0)	
	draw_stars(49,107,star_count)	
	printo("— to start",42,120,7,0)	      
end

function draw_select_level()
	cls(1)
	printof("select level",0,2,7,0)	
	printc(categories[((current_level-1)\6)+1],11,5)	
	draw_stars(48,36,star_count)		
	if (star_count > 0) then
		printof("-"..current_level.."-",0,19,11)
		printof(levels[current_level].name,0,28,11,0)		
		rect(38,43,89,101,11)
	else
		printof("-"..current_level.."-",0,19,8)
		printof(levels[current_level].name,0,28,8,0)		
		rect(38,43,89,101,8)
	end
	rectfill(39,44,88,100,13)	
	printc("start",48,0)
	draw_solution(45,55,level.stacks,13)	
	line(44,70,83,70,0)
	printc("goal",74,0)
	draw_solution(45,81,level.solution,13)
	line(44,96,83,96,0)
	printo("‹                ‘",24,71,13)	
	printc("shortest solution: "..level.reg.." registers",109,0)
	printc("shortest solution: "..level.reg.." registers",108,13)
	printo("— to start",42,120,7,0)	      
end

function draw_stars(x,y,n)	
	printo("\143 \143 \143",x,y,5,0)	
	if (n>=1) printo("\143",x,y,9,0)	
	if (n>=2) printo("\143",x+12,y,9,0)	
	if (n==3) printo("\143",x+24,y,9,0)	
end

function screen_shake()
    local off_x=16-rnd(32)
    local off_y=16-rnd(32)
    off_x*=so
    off_y*=so  
    camera(off_x,off_y)
    so*=0.95
    if so<0.05 then
        so=0
    end
end

function crash_crane(dir)
	so=0.3
	crash_location = dir
	local colors = {6,9}
	if (c.crate != nil) then
		add(colors, get_pico8_color(c.crate))	
	end	    
	local x = 0
    local y = start_y+1+(c.y*8)+4	
	if (crash_location == "down") then x=(c.x*15)+15
	elseif (nr_of_piles==8 and crash_location == "left") then x=1		
	elseif (nr_of_piles==8 and crash_location == "right") then x=123		
	elseif (crash_location == "left") then x=wip_offset_x+wip_start_x-10
	elseif (crash_location == "right") then x=wip_offset_x+wip_start_x+(nr_of_piles*15)	
	end
    for i=0, 60 do
        create_crane_particles(x,y, colors)
	end
	sfx(2)
end

function create_crane_particles(x,y,colors) 	
	local new = {x=x, y=y, c=colors[flr(rnd(#colors))+1]} 
    local angle = rnd()
    local speed = rnd(2)+1
	    
    new.dx=sin(angle)*speed 
    new.dy=cos(angle)*speed

    new.age=flr(rnd(25))
    add(cps,new)
end

function update_crane_particles() 
    for cp in all(cps) do
        if cp.age > 60 or cp.y > 127 or cp.y < 0 or cp.x > 127 or cp.x < 0 then
            del(cps,cp)
        else
            cp.x+=cp.dx
            cp.y+=cp.dy
            cp.age+=1
            cp.dy+=0.15 
        end
    end
end

function draw_crane_particles()        
    for cp in all(cps) do    
        line(cp.x,cp.y,cp.x+cp.dx,cp.y+cp.dy,cp.c)       
    end
end

function index_by_val(t, v)
	for i=1, #t do
		if (t[i] == v) return i
	end
end

function get_pico8_color(s)
	if (s=="1") return 9
	if (s=="3") return 8
	if (s=="5") return 12
	if (s=="7") return 11
	return 0
end

function save_action_condition(action,condition,offset)	
	poke(0x1000+offset,(condition<<4)|action) 
end

function save_level_progress(lvl)	
	local level_offset = (lvl-1)*29
	local a_c_cnt = 0;  
	for rp=1, #registers do		
		for ap=1, #registers[rp] do                  
			save_action_condition(action_to_color(registers[rp][ap].action), registers[rp][ap].condition, level_offset+a_c_cnt)
			a_c_cnt += 1			
		end
	end	  	
	--	0x1000-0x1fff / 4096-8191 Map (rows 32-64)
	--	0x2000-0x2fff / 8192-12287 Map (rows 0-31)
	cstore(0x1000, 0x1000, (lvl*29))
end

function load_level_progress(lvl)    
	local a_c_cnt = 0;  
	for rp=1, #registers do		
		for ap=1, #registers[rp] do                  
			local pixels = peek(4096+((lvl-1)*29)+a_c_cnt, 1)			
			if (pixels != 0) then				
				local action = color_to_action(pixels&15)
				local condition = (pixels>>4)&15			
				registers[rp][ap] = create_command(action, condition)
			end
			a_c_cnt += 1			
		end
	end	  
end

function action_to_color(a)  
	if (a==a_right) return 1
	if (a==a_left)  return 2
	if (a==a_down)  return 3
	if (a==a_reg1)  return 4 
	if (a==a_reg2)  return 5 
	if (a==a_reg3)  return 6 
	if (a==a_reg4)  return 7 
	if (a==a_empty) return 8 
end

function color_to_action(c)
	if (c==1) return a_right 
	if (c==2) return a_left  
	if (c==3) return a_down
	if (c==4) return a_reg1   
	if (c==5) return a_reg2   
	if (c==6) return a_reg3   
	if (c==7) return a_reg4   
	if (c==8) return a_empty
end
  
function sfxc()
	if (frame_speed > 1) then
		sfx(0)
	else
		sfx(1)
	end
end

function zspr(n,w,h,dx,dy,dz)
    sx = 8 * (n % 16)
    sy = 8 * flr(n / 16)
    sw = 8 * w
    sh = 8 * h
    dw = sw * dz
    dh = sh * dz  
    sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

function printc(s,y,c)
	local x = 64-#s*2
	print(s,x,y,c)	
end

function printo(s,x,y,fc,bc)    
    print(s,x+1,y,bc)
    print(s,x-1,y,bc)
    print(s,x,y+1,bc)
    print(s,x,y-1,bc)
    print(s,x,y,fc)
end

function printof(s,bx,y,fc,bc)		
	printo(s,((128+bx)\2)-#s*2,y,fc,bc)    
end

function tostring(any)
    if type(any)=="function" then 
        return "function" 
    end
    if any==nil then 
        return "nil" 
    end
    if type(any)=="string" then
        return any
    end
    if type(any)=="boolean" then
        if any then return "true" end
        return "false"
    end
    if type(any)=="table" then
        local str = "{ "
        for k,v in pairs(any) do
            str=" "..str..tostring(k)..":"..tostring(v).." "
        end
        return str.."}"
    end
    if type(any)=="number" then
        return ""..any
    end
    return "unkown"
end

function wait(a) 
    for i=1, a do 
        flip() 
    end 
end

levels =
{
	--[[01]] { data="4,4,4,1,0,4,4,4|4,4,4,0,1,4,4,4",                             name="cargo 101",         conditions="15",                  init_x=3, reg=3,  stars={3,3,3},    hint="down, right, down." },
	--[[02]] { data="4,4,1,0,0,0,4,4|4,4,0,0,0,1,4,4",                             name="transporter",       conditions="15",                  init_x=2, reg=4,  stars={5,5,4},    hint="reuse the solution from level\n1 and loop through it." },
	--[[03]] { data="4,4,4,1111,0,4,4,4|4,4,4,0,1111,4,4,4",                       name="re-curses",         conditions="15",                  init_x=3, reg=5,  stars={10,5,5},   hint="move 1 crate to the right, go\nback to the original position\nand then loop." },
	--[[04]] { data="4,5371,0,0,0,0,0,4|4,0,0,0,0,0,1735,4",                       name="inverter",          conditions="15",                  init_x=1, reg=10, stars={15,10,10}, hint="move all blocks 1 spot to the\nright, and repeat." },
	--[[05]] { data="4,4,15555,0,0,4,4,4|4,4,0,5555,1,4,4,4",                      name="from beneath",      conditions="10,12,13,14,15",      init_x=2, reg=5,  stars={8,6,5},    hint="go right once if holding blue,\ntwice if holding yellow and\nleft if holding none.\nrepeat." },
	--[[06]] { data="4,4,0,333,777,555,4,4|4,4,333,777,555,0,4,4",                 name="go left",           conditions="15",                  init_x=2, reg=9,  stars={15,9,9},   hint="move each pile to the left.\nrepeat." },
	
	--[[07]] { data="4,4,5371,0,0,4,4,4|4,4,0,0,5371,4,4,4",                       name="double flip",       conditions="9,10,11,12,13,14,15", init_x=2, reg=5,  stars={12,6,5},   hint="go right once if holding any,\ntwice if holding blue, and\nleft if holding none.\nrepeat." },
	--[[08]] { data="4,4,0,333,555,777,4,4|4,4,333,555,777,0,4,4",                 name="go left 2",         conditions="9,11,12,13,14,15",    init_x=2, reg=4,  stars={8,6,4},    hint="go right if holding none, and\nleft if holding any.\nrepeat." },
	--[[09]] { data="4,4,0,515151,0,4,4,4|4,4,555,0,111,4,4,4",                    name="shuffle sort",      conditions="15",                  init_x=3, reg=9,  stars={15,10,9},  hint="alternate left and right, and\nmake sure to use f2 to shorten\nyour solution." },
	--[[10]] { data="1,1,1,1,1,1,0,3333|1,1,1,1,1,1,3333,0",                       name="go the distance",   conditions="9,10,13,14,15",       init_x=0, reg=4,  stars={12,6,4},   hint="go right if holding none, and\nleft if holding red.\nrepeat." },
	--[[11]] { data="4,4,0,773733,0,4,4,4|4,4,333,0,777,4,4,4",                    name="color sort",        conditions="9,11,13,14,15",       init_x=3, reg=8,  stars={14,10,8},  hint="go over each of the 3 piles\nand drop or pick up based on\nthe color. when over the left\npile drop if red, when over\nthe right pile drop if green.\nall in f1 is possible" },
	--[[12]] { data="5555,5555,5555,0,0,0,0,4|0,0,0,0,5555,5555,5555,4",           name="walking piles",     conditions="12,14,15",            init_x=0, reg=9,  stars={13,11,9},  hint="move each pile 3 slots to the\nright, and then repeat. this\nmethod can be implemented with\n10 registers." },	
	
	--[[13]] { data="4,1375,0,1375,0,1375,0,4|4,0,5731,0,5731,0,5731,4",           name="repeat inverter",   conditions="9,10,11,12,13,14,15", init_x=1, reg=5,  stars={9,7,5},    hint="it can be done with the usual\n5 instructions and clever\nusage of conditional modifiers" },
	--[[14]] { data="4,4,0,5511,1515,0,4,4|4,4,5555,0,0,1111,4,4",                 name="double sort",       conditions="10,12,13,14,15",      init_x=3, reg=10, stars={20,14,10}, hint="sort, go right, sort, go left.\nrepeat. use at most 14\ninstructions." },
	--[[15]] { data="4,1111,77,7,7,77,0,4|4,0,77,7,7,77,1111,4",                   name="mirror",            conditions="10,11,13,14,15",      init_x=1, reg=6,  stars={9,7,6},    hint="use at most 7 registers. there\nare various known solutions\nwith 6 registers in f1" },
	--[[16]] { data="4,777777,0,0,0,0,0,4|4,7,7,7,7,7,7,4",                        name="lay it out",        conditions="11,14,15",            init_x=1, reg=7,  stars={13,9,7},   hint="move the pile one slot to the\nright and bring one crate back\nto the left." },
	--[[17]] { data="0,1,1,1,1,1,1,0|0,0,0,0,0,0,0,111111",                        name="the stacker",       conditions="10,14,15",            init_x=4, reg=8,  stars={12,10,8},  hint="go left until you find an\nempty slot, and then move the\nlast yellow crate one slot to\nthe right. repeat." },
	--[[18]] { data="4,737,77737,3737,377,0,4,4|4,73,7773,373,3,77777,4,4",        name="clarity",           conditions="9,11,13,14,15",       init_x=1, reg=6,  stars={9,7,6},    hint="a disguised version of mirror"	},	
	
	--[[19]] { data="0,0,111,1,0,0,11,4|111111,0,0,0,0,0,0,4",                     name="come together",     conditions="10,14,15",            init_x=0, reg=7,  stars={15,9,7},   hint="you can go right and find a\nyellow crate, but when bring-\ning it back how do you know\nwhen to stop so that you don't\ncrash into the wall? in f2\nuse the programming stack to\ncount the number of times you\nhave to go right until you\nfind a yellow crate, then go\nback left that same number of\ntimes. another way to look at\nit: f2 is a recursive function\nthat goes right until it finds\na crate, and then it goes back\nto the original position. it\ncan be implemented with 4\nregisters" },
	--[[20]] { data="0,1,177,1,17,1,7777,4|7777777,1,1,1,1,1,0,4",                 name="come together 2",   conditions="10,11,13,14,15",      init_x=0, reg=8,  stars={12,10,8},  hint="another stack puzzle. re-use\nthe solution from the previous\nlevel with a small modifi-\ncation" },
	--[[21]] { data="7,55,7,0,555,7,55,55|755,0,7555,0,0,75555,0,0",               name="up the greens",     conditions="11,12,13,14,15",      init_x=0, reg=7,  stars={12,9,7},   hint="very similar to the previous\ntwo levels but let the stack\nunwind and reset when you find\na green. to do this only go\nleft if holding a blue." },
	--[[22]] { data="7777,3,0,3,0,0,3,0|0,3,7,3,7,7,3,7",                          name="fill the blanks",   conditions="9,11,13,14,15",       init_x=0, reg=11, stars={20,14,11}, hint="as in the 'lay it out' level,\nmove the entire pile one slot\nto the right and bring one\ncrate back to the left, except\nin the first iteration." },
	--[[23]] { data="155,0,0,0,15,0,0,4|0,55,0,1,0,5,1,4",                         name="count the blues",   conditions="10,12,13,14,15",      init_x=0, reg=9,  stars={15,12,9},  hint="another stack puzzle. the\nnumber of blues indicates how\nmany times to go right with\nthe yellow." },
	--[[24]] { data="0,51,0,115,1515,51,5,0|111111,0,0,0,0,0,0,555555",            name="multi sort",        conditions="10,12,13,14,15",      init_x=0, reg=7,  stars={16,11,7},  hint="come together for yellows, the\nstacker for blues. go forward\nuntil you fing a crate. if\nblue, move it one slot further\nand come all the way back\n(using the stack) empty handed\nif yellow, bring it back and\ndrop it. repeat." },	
	
	--[[25]] { data="5555,0,55,0,555555,0,5555,0|55,55,5,5,555,555,55,55",         name="divide by two",     conditions="12,14,15",            init_x=0, reg=12, stars={20,14,12}, hint="wind up the stack for every\ntwo crates. move 1 crate back\neach time it unwinds." },
	--[[26]] { data="4,4,555,0,333,4,4,4|4,4,0,535353,0,4,4,4",                    name="the merger",        conditions="9,12,13,14,15",       init_x=2, reg=6,  stars={9,7,6},    hint="use the stack once in each\nblue, and unwind it in each\nred." },
	--[[27]] { data="77777,0,33,0,555,0,1111,0|7,7777,0,33,5,55,0,1111",           name="even the odds",     conditions="9,10,11,12,13,14,15", init_x=0, reg=10, stars={13,11,10}, hint="if the pile ahs an odd number\nof crates, leave 1 crate\nbehind, otherwise move all of\nthem. use a sequence of moves\nthat undoes itself when\nrepeated to move the crates\nright, and make sure to\nexecute it an even number of\ntimes." },
	--[[28]] { data="4,711717,0,111,0,777,4,4|4,0,717117,0,711717,0,4,4",          name="genetic code",      conditions="10,11,13,14,15",      init_x=1, reg=16, stars={29,20,16}, hint="the left piles gives instruc-\ntions for how to construct the\nright pile. wind up the entire\nstack on the left and unwind\non the right." },
	--[[29]] { data="0,51371,0,355771,0,37135,0,4|5555,0,3333,0,7777,0,1111,4",    name="multi sort 2",      conditions="9,10,11,12,13,14,15", init_x=0, reg=17, stars={25,17,17}, hint="go over each pile and either\npick up conditional on none if\nover the even slots, or drop\nconditional on the correspon-\nding color if over the odd\nslots." },
	--[[30]] { data="4,4,333,0,777,4,4,4|4,4,777,0,333,4,4,4",                     name="the swap", 	     conditions="9,11,13,14,15",       init_x=3, reg=7,  stars={15,12,7},  hint="merge the piles in the middle,\nchange parity, and unmerge." },	
	
	--[[31]] { data="0,5355,3535,555,3,35,5,0|0,555,55,555,0,5,5,33333",           name="restoring order",   conditions="9,12,13,14,15",       init_x=0, reg=15, stars={29,20,15}, hint="for each pile move the reds 1\nslot to the right and the\nblues 1 slot to the left, but\nmake sure to wind up a stack\nfor the blues so that you can\nput them back afterwards.\nrepeat for each pile." },
	--[[32]] { data="3,333,777,0,3333,33,7777,7|333,3,0,777,33,3333,7,7777",       name="changing places",   conditions="9,11,13,14,15",       init_x=0, reg=16, stars={20,18,16}, hint="switch each pair of piles, in\nplace. first move the left\npile to the right, winding up\nthe stack. then move all\ncrates to the left slot.\nfinally, unwind the stack\nmoving a crate to the right\neach time." },
	--[[33]] { data="0,35,5353,53,5353,0,535353,0|0,53,3535,35,3535,0,353535,0",   name="palette swap",      conditions="9,12,13,14,15",       init_x=1, reg=14, stars={29,18,14}, hint="go left and go right. each\ntime you do so, wind up the\nstack. when no more crates are\nleft, unwind the stack going\nleft and going right.\nrepeat." },
	--[[34]] { data="4,4,111,11,1,0,4,4|4,4,0,1,11,111,4,4",                       name="mirror 2",          conditions="10,14,15",            init_x=2, reg=10, stars={20,15,10}, hint="move the top crate of the 2nd\npile one slot to the right,\nand bring the left pile all\nthe way to the right." },
	--[[35]] { data="3,333,3,33333,0,33,3333,333|333,3,33333,0,33,3333,333,3",     name="changing places 2", conditions="9,14,15",             init_x=0, reg=10, stars={25,19,10}, hint="as in 'changing places', swap\npiles. do that once for each\npair of consecutive piles and\nyou're done." },
	--[[36]] { data="0,75755,575,7557,57,57775,0,4|0,77555,755,7755,75,77755,0,4", name="vertical sort",     conditions="11,12,13,14,15",      init_x=0, reg=18, stars={29,20,18}, hint="draw on ideas from previous\nsort levels." },	

    --[[37]] { data="777777,0,0,0,0,0,0,4|77,0,7,7,7,0,7,4",                       name="count in binary",   conditions="11,14,15",            init_x=0, reg=9,  stars={29,15,9},  hint="count up all the numbers in\nbinary: 1, 10, 11, 100,..." },	
    --[[38]] { data="0,55,5,55555,0,55,5555,3|55,55,55,55,55,55,55,3",             name="equalizer",         conditions="9,12,13,14,15",       init_x=0, reg=10, stars={29,20,10}, hint="draw on ideas from previous\nlevels." },	
    --[[39]] { data="0,55,55,55,55,55,0,4|55555,0,0,0,0,0,55555,4",                name="parting the sea",   conditions="12,14,15",            init_x=0, reg=10, stars={29,14,10}, hint="draw on ideas from previous\nlevels." },	
    --[[40]] { data="4,4,13,0,31,4,4,4|4,4,31,0,13,4,4,4",                         name="the trick",         conditions="9,10,13,14,15",       init_x=3, reg=8,  stars={29,10,8},  hint="bring the right pile to the\nmiddle, then the left pile to\nthe middle. finally unmerge\nthe piles to their respective\nsides." }	
}
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000008888880099999900bbbbbb00cccccc00899bbc00555555000000000
000000000549999999999450052888888888825005dccccccccccd50053bbbbbbbbbb3508888888899999999bbbbbbbbcccccccc8899bbcc5555555500000000
00700700095499999999454008528888888825200c5dccccccccd5d00b53bbbbbbbb353000000000000000000000000000000000000000000000000000000000
00077000099000000000544008800000000052200cc0000000005dd00bb000000000533000000000000000000000000000000000000000000000000000000000
00077000049044055055944002802205505582200dc0dd055055cdd003b033055055b33000000000000000000000000000000000000000000000000000000000
00700700044049905055944002202880505582200dd0dcc05055cdd003303bb05055b33000000000000000000000000000000000000000000000000000000000
00000000044009990055944002200888005582200dd00ccc0055cdd003300bbb0055b33000000000000000000000000000000000000000000000000000000000
00000000044050999055944002205088805582200dd050ccc055cdd0033050bbb055b33000000000000000000000000000000000000000000000000000000000
00000000044055099905944002205508880582200dd0550ccc05cdd00330550bbb05b3300000000066666666666666666666666699000099bb0000bb00000000
00000000044055009990944002205500888082200dd05500ccc0cdd003305500bbb0b3300000000066611666666116666666666690000009b000000b00000000
00000000044055050994944002205505088282200dd055050ccdcdd0033055050bb3b33000000000666111666611166666111116000000000000000000000000
00000000044055055044944002205505502282200dd0550550ddcdd0033055055033b33000000000666111166111166666111116000000000000000000000000
00000000044049999999044002202888888802200dd0dccccccc0dd003303bbbbbbb033000000000666111666611166666611166000000000000000000000000
00000000040444444444404002022222222220200d0dddddddddd0d003033333333330300000000066611666666116666666166690000009b000000b00000000
000000000044444444444400002222222222220000dddddddddddd0000333333333333000000000066666666666666666666666699000099bb0000bb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777000000000000000000000000000000000000000000000000000000000000000000888888888888888888888888888888885555555500000000
00000000007777700000000000000000000000000000000000000000000000000000000000000000888778888887778888877788888787885555555500000000
00000000667777766000000000000000000000000000000000000000000000000000000000000000888878888888878888888788888787885555555500000000
00000000600000006000000000000000000000000000000000000000000000000000000000000000888878888887778888887788888777885555555500000000
00000000600000006000000000000000000000000000000000000000000000000000000000000000888878888887888888888788888887885555555500000000
00000000600000006000000000000000000000000000000000000000000000000000000000000000888777888887778888877788888887885555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888888888888888888888888888885555555500000000
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
001400002b6102b6101b6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002b6102b610286000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c630366302f63029620296000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001200000013001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000f0301f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00001c63000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000170501d05022050270502c05032050380503d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002e00029000000001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
