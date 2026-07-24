pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- pipe dream
-- by ibachimo

	function _init(plyer_state)
t,t2=0,0

local p_state = (plyer_state) and plyer_state or 0
	
	p = {
		x=512,
		y=72 
	}

	player_vx, player_vy, player_state, player_hp, player_iframes,player_r = 512, 72, p_state, 3, 0, 0

	fish_dy,fish_jumpy,fish_visualx,fish_radius,restart_timer,score,big_words,find,carrying,rotate_trigger,start,mcenter,message,crown= 3 ,0 ,0, 0, 0, 0, {{39,23,39,9},{8,40,9,6,24}}, false, 0, 0


	f = {
		x=0,
		y=0,
		new_fy=0,
		last_fy=0,
		slam = false
	}

	cam  = {
		x = 512,
		y = 72,
		r = 0,
		angle = 0,
		pause = 0
	}


	x_array,y_array,e_count,angle2,projectiles,poi_index,points_of_interest,film_object,level,upgrades,select_index,upgrade_menu_offset,last_room = {0,1,0,-1},{-1,0,1,0},0,0,{},1,{},p,0,0,1,-200

 	di = 2 --starting index for string
 	dstring = "{{224,225,226,227,228,229,230,231,},{232,233,234,235,236,237,238,239,},{240,241,242,243,244,245,246,247,},{248,249,250,251,252,253,254,255,},".. -- 4 switch levelsd_arr
 			  "{192,193,194,195,196,197,214,215,},{198,199,200,201,202,203,204,205,214,215,},{194,195,196,197,},{193,194,195,196,197,},{{194,195,},{193,195,196,197,},{193,194,196,197,},{194,195,197,},{194,195,196,},},{{-12,12,},{-12,0,-12,12,},{12,0,-12,12,},{-12,12,0,},{-12,12,0,},},{{0,0,},{0,10,0,-12,},{0,10,-12,0,},{0,10,-12,},{10,0,-12,},},{{-1,-1,},{1,1,-1,-1,},{1,-1,1,1,},{1,1,-1,},{-1,-1,1,},},{{1,-1,},{1,1,-1,1,},{-1,-1,-1,1,},{1,-1,-1,},{1,-1,1,},},{{128,128,128,128,},{130,130,130,130,},{138,138,138,138,},{166,166,166,166,},{140,140,140,140,},},{{,},{132,132,132,132,},{162,162,162,162,},{168,168,168,168,},{142,142,142,142,},},{{,},{134,136,130,},{164,164,164,164,},{170,170,170,170,},{172,172,172,172,},},".. --enemy attack sprite 14 
 			  "{16,24,56,22,56,},".. --enemy agro distance 15 4
 			  "{{0,1,2,17,33,48,},{0,1,2,},{0,1,2,},{0,1,2,},{0,2,16,17,32,33,48,49},},".. --enemy invalid tiles 16 
 			  "{20,20,20,20,200,},"..--enemy health points 17 6
 			  "{{3,0,0,0,},{5,0,0,0,},{4,2,0,0,},{3,4,0,0,},{4,2,0,0,},{4,3,0,0,},{2,2,0,2,},{2,2,0,4,},},".. -- enemies per level primary_pipes 18 
 			  "{{0,0,0,0,},{0,0,0,0,},{0,0,0,0,},{0,0,0,0,},{0,0,2,0,},{0,0,2,0,},{0,0,3,0,},{0,0,3,0,},},"..  --enemies per level secondary_pipes 19 
 			  "{1,17,49,17,48,2,7,16,33,32,0,0,0,0,48,},{-22,-21,-20,-1,0,1,20,21,22,},{9,10,11,30,31,32,51,52,53,},"..--set_transition_square 22 
 			  "{0,1,0,-1,0,}," ..--xpos: trace_edge 23 
 			  "{-1,0,1,0,-1,},"..--ypos: trace_edge 24 
 			  "{78,76,78,78,106,74,108,110,110,106,74,},{{11,27,43,59,},{12,28,44,60,},{10,26,42,58,},},{70,72,102,104,},{16,17,32,33,20,21,36,37,},{194,195,196,197,},{5,5,6,5,4,},"..
 			  "{{0,1,1,0,},{0,1,1,0,},{0,1,1,0,},{0,1,1,0,},{0,1,1,0,},},}"
 	darrays = recurse_through_string(dstring) --data array

	music_tracks,music_num ,mirror,transition_mirror,transition_square,transition_rock,troffsetx,troffsety = {2,11,21,30}, 2, 0, 0

	music(0)

	level_init()

end --end of init function

function recurse_through_string(data_string)
	local tbl,contents = {},""
	while di <= #data_string do
		local d=sub(data_string,di,di)	
		di+=1
		if d == "{" then
			contents = recurse_through_string(data_string)
		elseif d == "}" then
			return tbl
		elseif d == "," then
			add(tbl,contents)
			contents = ""
		else
			contents = contents..d
		end
	end
end


--problem levels: 231
function level_init()

	level_group = (level < 6) and ceil((level+2)/2) or 4
	s,scroll_dir,scroll_offset,startingx,startingy = 0,-1,48,10,5
	if level > 0 then
	clear_entire_map()
	end
	for i = 0,1 do
		local success = false
		while not success do
			local tile = darrays[level_group][flr(rnd(7)+1)] 
			if i == 0 and last_room then
				tile = last_room
			end
				tile1 = {
					x = nil,
					y = startingy,
					t = tile
				}
			success = place_rooms(tile1)
			last_room = (level == 7) and 231 or tile
		--success = true
		end
		startingy+=9
	end 

	enemies,particles,jewels = {},{},{}

	ept = {{},{{0.125,0.375,0.625,0.875},4,8,7,true,-.7,0,8},{{0},4,15,7,true,-.5,0,8},{{0,0.125,0.25,0.375,0.5,0.625,0.75,0.875},2,20,2,1,0,0,8},{{0,0,0},5,80,7,true,-.5,0,8}} -- enemy particle type
	tiles = record_map(0)
	secondary_pipes = segment_pipes3(darrays[6]) -- get the secondary pipes (thuis has to be 1st)
	swap_intersecting_pipes(secondary_pipes) -- switch tiles 198 and 199 to 214 and 215
	swap_underwater_pipe_tiles(secondary_pipes) -- switch the underwater tiles using 198 and 199 as delimeters
	primary_pipes = segment_pipes3(darrays[5]) -- get the primary pipes
	tiles = record_map(0) -- re - store the tiles
	primary_switches = place_switches(primary_pipes,1,darrays[20])
	secondary_switches = place_switches(secondary_pipes,2,darrays[21])
	rotate_flags = place_rotate_flags(primary_pipes,darrays[7]) 
	rock_groups = place_rocks_and_connect_rflags2()
	leak_puddles = {{},{}}
	active_secondary_pipe,active_secondary_switch,active_primary_pipe,active_primary_switch,switch_dir,current_rflag_group,current_rflag,vh=1,1,1,1,1,1,1,-1
	if level == 0 then
		can_scroll,next_position,rock_index,current_rock,p.angle,player_r  = true,rotate_flags[current_rflag_group][current_rflag+switch_dir],0,nil,get_angle(rotate_flags[current_rflag_group][2],p),get_radius(rotate_flags[current_rflag_group][2],p) --writing the map level to the screen.
		rotate(rotate_flags[current_rflag_group][2],p,player_r,p.angle)
		--initialize the fish
		if primary_switches[1][1].ct2 == 194 then --this statement sets the side of the fish for the start
			f.x,fish_visualx,r_spd = 554, 584,-.0065
		else
			f.x, fish_visualx, r_spd  = 470, 440,.0065
		end
		f.y,fish_jumpy,fish_radius= 90,90,51
		angle = get_angle(p,f) --angle
	else
		set_transition_square()
		place_segment(false) -- this takes the first segment of the map and blows it up to the normal tiles
	end

	if transition_rock then
		rock_groups[1].x,rock_groups[1].y = 512 - troffsetx,76 - troffsety 
		local last_switch = primary_switches[#primary_switches][#primary_switches[#primary_switches]]
		last_switch.x,last_switch.y,player_vx,player_vy = 512,76,512,76
 	end
		can_change_rspd = true
	if level < 2 or level == 8 then 
		local sp_switch = primary_switches[2][1]
		sp_switch.state,active_secondary_pipe = 'up',2
		create_leak(sp_switch,1,2,false)
	end
	create_leak(primary_switches[1][1],1,current_rflag_group,false)

	if level == 8 then
		create_enemy(primary_switches[1][2].x,primary_switches[1][2].y+48,5)
	end
end

function place_rooms(tile,range1,range2)
	local spr_x, spr_y,last_startingx=(tile.t%16)*8,flr(tile.t/16)*8,startingx
	for y=0,7 do
		for x=0,7 do			
			local col = sget(spr_x+x,spr_y+y)
			if col ~= 15 then
				if tile.x == nil then
					tile.x = startingx - x 
					local right_edge = tile.x + 7 -- make it less than 8 so you don't get stuck
				end
				local new_tile = 192+col
				if col == 207 then new_tile = 0 end
				mset(tile.x+x,tile.y+y,new_tile)
				if col == 1 and y == 7 then -- ISSUE. TO DO. the starting x is getting put in position 0 which is causing infinite loops. this cannot be in spot 0
					startingx = tile.x+x
				end
			end
		end
	end
	mset(startingx,tile.y+8,193)
	return true
end

function clear_entire_map(tile_array)
	for y = 0, 31 do -- used to be 45 changed to try and get the third sprite sheet to show up
		for x = 0, 128 do
			if falls_between(mget(x,y),191,216) and y < 5 then

			else
				mset(x,y,0)
			end
		end 
	end
end

function record_map(r) -- store all the tiles in an array so they can be worked with
	local tiles,num = {},0
	for yp=0,25 do
	 	for xp=0,20 do
 	  		local tile = mget(xp,yp)
 			local t = {
 		 		x = abs(xp-r),
 		 		y = yp,
 		 		t = tile,
 		 		num = num,
 		 		group = nil,
 		 		rock_number = nil,
 		 		flag = nil
 			} 
 		 	add(tiles,t)
 		 	num+=1
 		end
 	end
 	return tiles
end

function get_radius(obj1,obj2)
	local a,b = (obj2.x-obj1.x)/16,(obj2.y-obj1.y)/16
	return sqrt(a*a+b*b)*16
end

function rotate(obj1,obj2,radius,angle)
	obj2.x = obj1.x + radius * cos(angle)
	obj2.y = obj1.y + radius * sin(angle)	
end

function get_angle(obj1,obj2)
	local dx,dy = obj2.x-obj1.x,obj2.y-obj1.y
	 return atan2(dx,dy)
end

function array_contains_item(item,array) -- does and array contain the specific item
	for i in all(array) do
		if item == tonum(i) then
			return true
		end
	end
	return false
end

function scroll_object(y)
 	return y + scroll_offset*scroll_dir
end

function get_surrounding_tiles(tile) -- get the surrounding tiles 
	local tiles = {}
	for id,x in pairs(x_array) do
		add(tiles,mget(x+tile.x,y_array[id]+tile.y))
	end
	return tiles
end

function falls_between(num,range1,range2)
	return num > range1 and num < range2
end

function swap_intersecting_pipes(pipe_array)
 	for id, pipe in pairs(pipe_array) do
 		for id, p in pairs(pipe) do
 			local x,y,new,surrounding = p.x,p.y,p.t+16,get_surrounding_tiles(p)
	 		if p.t == 198 and array_contains_item(surrounding[4],{192,194,196}) and array_contains_item(surrounding[2],{192,195,197}) then
	 			mset(x,y,new)
	 			p.t = new
	 		elseif p.t == 199 and array_contains_item(surrounding[1],{193,196,197}) and array_contains_item(surrounding[3],{193,194,195}) then
	 		 	mset(x,y,new)
	 		 	p.t = new
	 		end
 		end
	end
end

function swap_underwater_pipe_tiles(pipe_array) -- this sets up the tiles so that if you encounter 198 or 199 then the rest of the tiles are underwater until you hit that 198 or 199 again
	local delimiter_tiles = {198,199}
	for id, pipe in pairs(pipe_array) do
		local underwater = -1
		for k,p in pairs(pipe) do
			if array_contains_item(p.t,delimiter_tiles) then
				underwater *= -1
			end

			if underwater == 1 and falls_between(p.t,199,206) then
				p.t = p.t+16
				mset(p.x,p.y,p.t)
			end
		end
	end
end

function segment_pipes3(tile_array)
	local pipes, checked  = {},{}
	for id, t in pairs(tiles) do
		local check_item = tonum(t.x..t.y)
		if array_contains_item(t.t,tile_array) and not array_contains_item(check_item,checked) then
			local pipe,nodes = {},find_path3(t,nil,tile_array)
			for i = #nodes, 1, -1 do
				local node = nodes[i]
				local p = {
					x = node.x,
					y = node.y,
					xpos = abs(node.x-mirror*20)*48,
					ypos = node.y*48,
					num = i,
					t = node.t
				}
				add(pipe,p)
				add(checked,tonum(node.x..node.y))
			end
			add(pipes,pipe)
		end
	end
	return pipes
end

function place_rotate_flags(pipe_array, tile_array)
	local r_flag_groups,r_flags,num_between,tile_obj = {}, {}, 0
	for id, pipe in pairs(pipe_array) do
		local first_switch = primary_pipes[id][1]
		local first_flag = {
			x = first_switch.xpos+32,
			y = first_switch.ypos+28,
			t = first_switch.t,
			group = id,
			num = 1,
			controls = {0,0}
		}
		add(r_flags,first_flag)
		tile_obj = get_object_tile(first_flag)
		tile_obj.flag = {id,1}
		if #primary_switches[id] > 0 and id ~= 1 then
			first_switch.y = first_flag.y+52
		end
		for key, p in pairs(pipe) do
			local flag = 
			{
				x = p.xpos+32,
				y = p.ypos+28,
				t = p.t,
				between = num_between,
				group = id,
				num = #r_flags+1,
				rock_index = nil,
				controls = {0,0}, -- going up or down on the rocks
				switch = nil
			}
			if id == 1 then
				for k, switch in pairs(secondary_switches[id]) do
					if get_radius(flag,switch) < 64 then
						switch.flag = #r_flags + 1
					end
				end
			end

			num_between+=1
			if array_contains_item(p.t,tile_array) then
				add(r_flags, flag)
				num_between = 0
			end
		end
		add(r_flag_groups,r_flags)
		r_flags = {}
	end
	return r_flag_groups
end

function place_rocks_and_connect_rflags2()
	local rock_groups, m = {},mirror*20
	if transition_rock then
		add(rock_groups,transition_rock)
	end
	for id, group in pairs(rotate_flags) do
		if id > 3 then break end
		for key, flag in pairs(group) do
			local flagx, flagy, r_index = (flag.x-32)/8/6, (flag.y-28)/8/6, {4,0,0,4}
			for i=1,4 do
				local tile = mget(abs(flagx+x_array[i]-m),flagy+y_array[i])
				if tile == 206 then
					local new = true
					local current_rock_group = {
						x = (flagx+x_array[i])*48,
						y = (flagy+y_array[i])*48,
						connected_rflags = {nil,nil}, --connected flags holds the values of the rflags on either side of the rock. each should look like {1,2},{1,5} index[1] should be group, index[2] is flag
						pipe_group = id, -- this is used for the last one for every segment
						vertical = true,
						complete = true,
						rocks = {},
					}
					flag.controls[i%2+1]=#rock_groups+1
					if #rock_groups > 0 then -- go through the rocks that have already been stored and check to see if their x/y position matches the current surrounding tile if it does use that one instead.
						for index,old_group in pairs(rock_groups) do
							if old_group.x == current_rock_group.x and old_group.y==current_rock_group.y then
								current_rock_group,flag.controls[i%2+1],new = old_group,index,false
								if key == 1 then 
									local switch = primary_switches[id][1]
									switch.rock_num,switch.c1.y  = index,switch.y-28 
									--this is to make the rock between the old and new pipes straight rather than angled
									local rocks2 = old_group.rocks[2]
									rocks2.offsetx,rocks2.offsety= 31,27

									current_rock_group.complete = (level < 2) and true or false
								end
							end
						end
					end
					flag.rock_index = r_index[i]
					current_rock_group.connected_rflags[r_index[i]%3+1] = flag
					current_rock_group.vertical = abs(y_array[i])

					if new then	
						local x_positions, y_positions = {3,3,3}, {1,3,5}

						if current_rock_group.vertical==0 then
							x_positions=y_positions
							y_positions={3,3,3}
						end

						for i = 1,3 do
							local rock = {
								x=0,
								y=0,
								offsetx=x_positions[i]*8+7,
								offsety=y_positions[i]*8+3
							}
							add(current_rock_group.rocks,rock)
						end

						local multiplier=flag and (flag.t+mirror)%2 or 0 -- this needs fixing
						local middle_rock,middle_rock_offset=current_rock_group.rocks[2],47-32*multiplier
						if current_rock_group.vertical==1 then
							middle_rock.offsetx = middle_rock_offset
						else
							middle_rock.offsety= middle_rock_offset
						end

						add(rock_groups,current_rock_group) 
					end
				end
			end
		end
	end
	return rock_groups
end

function place_switches(pipe_array,primary,enemy_array)
	local group,switches = {},{}
	for id, pipe in pairs(pipe_array) do
		local count = 1
		for key, p in pairs(pipe) do
			local first_seg,switch_state = pipe[1]
			switch_state = (#switches == 0 and id == 1) and 'up' or 'down'
			local switch = {
				x = p.xpos+32, -- for actual interaction in the map
				y = p.ypos+28, -- for actual interaction in the map
				xpos = p.x, --for debugging and seeing in the map layout 
				ypos = p.y, --for debugging and seeing in the map layout
				state = switch_state, --whether the button is up or down
				num = count, -- need this for pipe progress
				vh = nil,
				c1 = {  x = first_seg.xpos+18, y = first_seg.ypos } ,--- these are the corner positions for the sludge leak
				c2 = { x = first_seg.xpos+18, y = first_seg.ypos+100}, -- these are the corner positions for the sludge leak
				ct1 = first_seg.t, -- ct1 is the first corner tile they determine whether the slude will go up or down
				ct2 = nil,-- ct2 is the first corner tile they determine whether the slude will go up or down
				flag = nil,
				enum = nil,
				visible = true

			}
			switch.vh = array_contains_item(p.t,{192,214}) and 1 or -1
			local valid_tiles ={192,193,200,201,202,203,204}
			if primary == 1 then --primary pipe specific stuff
				add(valid_tiles,214)
				add(valid_tiles,215)
				if key == 1 and falls_between(id,1,4) then -- makes sure the corners are set correctly for the first tile.
					switch.c1.y = pipe_array[id-1][#pipe_array[id-1]].ypos+1 
					add_corners_for_switch(switch,pipe,darrays[31])
					add(switches,switch)
					count +=1
				end

			   --place_enemies(switch)
			end
			
			local surrounding = get_surrounding_tiles(p)
			if (array_contains_item(194,surrounding) or array_contains_item(195,surrounding) or
				array_contains_item(196,surrounding) or  array_contains_item(197,surrounding)) and
				array_contains_item(p.t,valid_tiles) then 

				if id == 1 then
					place_enemies(enemy_array,primary,switch)
				end

				add_corners_for_switch(switch,pipe,darrays[31])
				add(switches,switch)
				count +=1
			end
		end
		add(group,switches)
		switches = {}
	end
	return group
end

function place_enemies(enemy_array,primary,switch)
	local num_enemies,offset = 0,switch.vh * (12*sgn(rnd(10)-10)) --was 12
	for id, enemy_num in pairs(enemy_array[level+1]) do
		if tonum(enemy_num)>0 and switch.num%2<primary then
		create_enemy(switch.x+offset,switch.y+offset,id,switch)
		offset*=-1
		enemy_array[level+1][id]-=1
		num_enemies+=1
		end
	end
	if switch.num ~= 1 and primary == 1 then
		create_jewel(switch.x+offset,switch.y+offset-3,num_enemies)
	end
end

function add_corners_for_switch(switch,pipe,tile_array)
	local finish,c1x,c1y,c2x,c2y = 0

	for id, p in pairs(pipe) do
		if switch.xpos == p.x and switch.ypos == p.y then
			finish = 1
		end
		if array_contains_item(p.t,tile_array) and finish == 0 then
			c1x, c1y, switch.ct1 = p.xpos, p.ypos, p.t 
		elseif array_contains_item(p.t,tile_array) and finish == 1 then
			c2x, c2y, switch.ct2 = p.xpos, p.ypos, p.t  

			switch.c2.x, switch.c2.y = c2x+48, c2y+42 -- these two statements are for when it is the first switch and the leak needs to go the pipe[1]
			if c1x == c2x then -- for switches on vertical chunks
				switch.c1.x, switch.c1.y, switch.c2.x, switch.c2.y = c1x+18, c1y+40, c2x+48, c2y+28
			elseif c1y == c2y then -- for switches on horizontal chunks
				switch.c1.x, switch.c1.y, switch.c2.x, switch.c2.y  = c1x+35, c1y+18, c2x+18, c2y+48
			end
			break
		end
	end
end

function get_object_tile(obj) 
	local tile_x, tile_y = flr((obj.x/8)/6), flr(((obj.y+(s*scroll_offset))/8)/6)
	return tiles[tile_y*21+abs(tile_x-(20*mirror))+1]
end

function secondary_pipe_progress()
	local switch = secondary_switches[active_secondary_pipe][active_secondary_switch]-- this represents the switch on the secondary pipe that you have to press to make progress
	local parent,destination
	local proj_spr = nil
	switch.state = 'up'

	if falls_between(flr(get_radius(switch,f)),0,8) and switch.state =='up' and f.slam then 
		switch.state = 'down' 
		if active_secondary_switch ~= #secondary_switches[active_secondary_pipe] then 
			active_secondary_switch += 1 
			switch = secondary_switches[active_secondary_pipe][active_secondary_switch]
			parent = rotate_flags[current_rflag_group][switch.flag]
			destination = parent
		else
			active_secondary_pipe += 1 
			active_secondary_switch = 1
			if active_secondary_pipe < 4 then
			primary_switches[active_secondary_pipe][active_secondary_switch].state = 'up' -- if you are at the last switch on the pipe, set the next first switch on the priamry pipe to up
			end
			switch = primary_switches[current_rflag_group+1][1]
	
			if switch.rock_num then
				parent = rock_groups[switch.rock_num]
				destination = parent.rocks[2]
			end
			proj_spr = 70
		end
		points_of_interest,	projectiles, cam.pause = {}, {}, 0
		create_projectile(switch,get_radius(switch,destination),get_angle(destination,switch),parent,destination,proj_spr)
		add(points_of_interest,switch)
		add(points_of_interest,p)
		player_state = 3
	end
end


function primary_pipe_progress(contact_obj,screen_focus)
	local switch, flag_group, use_previous, on_screen_count, multiplier, next_switch = primary_switches[active_primary_pipe][active_primary_switch], rotate_flags[current_rflag_group], false, 1, 1 
	if switch.state =='up' and falls_between(flr(get_radius(switch,contact_obj)),0,10) and (contact_obj.slam == nil or contact_obj.slam) then --and f.shock_wave_size < 20 then		
	 		if contact_obj == f then
	 			switch_dir*=-1
	 		end  
			for id, s in pairs(primary_switches[active_primary_pipe]) do
				if s.state == 'down' and abs(screen_focus.x-s.x) < 64 and abs(screen_focus.y-s.y-4) < 64 and abs(switch.num-s.num) <= player_state  then
					next_switch = s

					use_previous = ((next_switch.x == switch.x or next_switch.y == switch.y) and player_state == 1) and true or false

					if current_rock then 
						multiplier = -1
					end 
					active_primary_switch = id
					on_screen_count+=1
					break
				end
			end

			if on_screen_count == 1 and active_primary_switch ~= 2 then
				local paralell_switch_increment = 
				    flag_group[#flag_group].between*2 + 
				    flag_group[current_rflag-1].between - 1
					next_switch = primary_switches[active_primary_pipe][active_primary_switch-paralell_switch_increment]
					active_primary_switch, multiplier = next_switch.num,-1
			end
			switch.state,next_switch.state = 'down','up'
			if (next_switch.y < flag_group[2].y and next_switch.num == 1 and array_contains_item(current_rflag,{2,3}) or ((level < 4 or level == 8) and active_primary_switch == #primary_switches[active_primary_pipe]) ) then
				del(leak_puddles[current_rflag_group],leak_puddles[current_rflag_group][#leak_puddles[current_rflag_group]]) --to do: the leaks aren't showing up in the right place when you hit the switch from the rocks.
			else create_leak(next_switch,switch.vh*multiplier,current_rflag_group,use_previous) end
	end
end

function create_leak(switch, vh, group, use_previous)
	local puddle_group = leak_puddles[group]
	local last_leak = puddle_group[#puddle_group]
	if #puddle_group > 0 and use_previous then
		del(puddle_group,last_leak)
		add(puddle_group,last_leak)
	else
		if #puddle_group > 0 then
			del(puddle_group,last_leak)
		end

		local next_corner = (switch_dir == 1) and switch.ct1 or switch.ct2
		local other_corner = (switch_dir == 1) and switch.ct2  or switch.ct1 
		local x_offset, y_offset, spin_dir = 0, 0, 1

		for id, comparison in pairs(darrays[9]) do
			local base = tonum(darrays[8][id])
			for key, compare in pairs(comparison) do
				if next_corner == base and other_corner == tonum(compare) then
					if vh == 1 then
						x_offset, spin_dir = tonum(darrays[10][id][key]), tonum(darrays[13][id][key])
					else
						y_offset, spin_dir = tonum(darrays[11][id][key]), tonum(darrays[12][id][key])
					end
				end
			end
		end

		if mirror == 1 then
			spin_dir*=-1
		end

		local xmod = mirror*-1.8*x_offset+x_offset
		local leak = {
		x1 = switch.c1.x + xmod,
		y1 = switch.c1.y + y_offset,
		x2 = switch.c2.x + xmod,
		y2 = switch.c2.y + y_offset,
		x_offset = sgn(x_offset),
		y_offset = sgn(y_offset),
		switch = switch,
		timer = 5,
		vh = vh ,
		spin_direction = spin_dir * abs(r_spd),
		other_corner = other_corner
		}

		if switch.c2.x < switch.c1.x then
			leak.x1,leak.x2  = switch.c2.x + x_offset, switch.c1.x + x_offset
		end
		if switch.c2.y < switch.c1.y then
			leak.y1,leak.y2 = switch.c2.y + y_offset, switch.c1.y + y_offset
		end

		add(puddle_group,leak)
	end
end


function place_segment(clear)
	local rock_tiles = {}
	for id, i in pairs(tiles) do
		if i.t ~= 0 then
			if clear and falls_between(i.y,s-3,s+5) then
				place_tiles(i,true)
			end
			if not clear and falls_between(i.y,s-3,s+5) then
				if i.t == 206 and (s~=1) then
					add(rock_tiles,i)
				else
					place_tiles(i,false)
				end
			end
		end
	end

	if #rock_tiles > 0 then
		for id, i in pairs(rock_tiles) do
			place_tiles(i,true)
		end
	end

end

function place_tiles(tile,clear)
	local spr_x, spr_y = (tile.t%16)*8, flr(tile.t/16)*8
	local offset = (tile.t ~= 206) and 5 or 7
	local mir = (s < 2) and transition_mirror or mirror
	for x=0,offset,1 do
		local m = x+-2*x*mir
		for y=0,offset,1 do			
			local col = sget(spr_x+x,spr_y+y)
			if col==1 and (s==1 or s==2) then col = 0 end
			local offset_x,offset_y = abs(tile.x-20*mir) * 6+mir*7,tile.y * 6	
			if clear then
				mset(offset_x+m,y+offset_y-s*6,0)
			else
				mset(offset_x+m,y+offset_y-s*6,darrays[22][col])
			end
		end
	end
end

function collision_with_tile(obj,tile_array)
	return array_contains_item(mget(obj.x/8,obj.y/8),tile_array)
end

function collision_with_rock(obj,rock_number) 
	if rock_number~=0 and rock_number and rock_groups[rock_number].complete then
		for rock in all(rock_groups[rock_number].rocks) do
			if falls_between(get_radius(obj,rock),0,10) then
			 return true
			end
		end
	end
	return false
end

function fish_in_leak_puddle() 
		for id, puddles in pairs(leak_puddles) do
			for key, puddle in pairs(puddles) do
				if falls_between(f.x,puddle.x1,puddle.x2) and falls_between(f.y,puddle.y1, puddle.y2) then
					return puddle
				end
			end
		end
	return nil
end

function create_projectile(switch,radius, angle,parent,destination,sprite)
	local proj = {
		x = switch.x,
		y = switch.y-4,
		switch = switch,
		r = radius,
		angle = angle,
		par = parent,
		dest = destination,
		sprite = sprite
	}
	add(projectiles,proj)
end

function trace_edge(obj,invalid_tiles)
	local tile_obj, dir, count  = {x = flr(obj.x/8), y = flr(obj.y/8)},obj.next_dir, 0
	for i=1,4 do
		--enemy 1 and 2 {0,1,4}
		if array_contains_item(get_surrounding_tiles(tile_obj)[i],invalid_tiles)  then
			if obj.next_dir~=i and count == 0 then
			obj.next_dir = i
			count+=1
			end
			dir = obj.next_dir%4 + 1
		end
	end
	local tile = mget(tile_obj.x+darrays[25][dir],tile_obj.y+darrays[26][dir])
	if not array_contains_item(tile,invalid_tiles) then
		return {{x=obj.x+darrays[25][dir]*8,y=obj.y+darrays[26][dir]*8,si=dir}}
	else
		return nil
	end

end

function create_enemy(xpos,ypos,e_type,switch)
	local e = {
		x = flr(xpos/8)*8,
		y = flr(ypos/8)*8,
		vx = flr(xpos/8)*8,
		can_attack = true,
		contact_dmg = false,
		r = 0,
		angle = 0,
		si =  darrays[14][e_type][1],
		ai = 1, -- animation index
		flip_x = false,
		type = e_type,
		state = 1,
		next_dir = 1,
		pathi = 1,
		path = nil,
		timer = 0,
		can_find = false,
		offset_x = 0,
		offset_y = 0,
		switch = switch,
		hp = tonum(darrays[19][e_type])

	}
	local tile = get_object_tile(e)
	e.offset_x = abs(tile.x-mirror*20)*48-e.x
	e.offset_y = tile.y*48-e.y
	add(enemies,e)

end

function state0()
	mcenter,big_words,message =rotate_flags[1][1],{{39,23,39,9},{8,40,9,6,24}},"press —+Ž"
	if btn"4" and btn"5" then
		start = true

	end

	if start then 
		fish_visualx = fish_visualx+sgn(p.x-f.x)
	end

	if abs(fish_visualx-f.x) < 2 then
	music(2)
	player_state = 2
	end

end

function state1() 

	sfx(51)
	fish_visualx,fish_dy = f.x,0

	if current_rflag_group == 2 and cam.r > 0 then
		cam.r -= 1
	end
	rotate(next_position,p,player_r,p.angle)

	local fish_future = {
		x = f.x,
		y = f.y,
		r = fish_radius+10,
	}
	rotate(p,fish_future,fish_future.r,angle)

	if collision_with_tile(fish_future,{16,17,32,33}) then
		if can_change_rspd then
			r_spd,can_change_rspd = r_spd*-1,false
		end
		rotate_trigger = 1
	end

	if rotate_trigger == 1 then
		angle += r_spd*2
	end

	rotate(p,f,fish_radius,angle)

	primary_pipe_progress({x = player_vx, y=player_vy},next_position)

	local dir = flr(p.angle*101)%2

	if dir == 0 then
	 	player_vx = p.x
	 	if btn"2" and carrying == 0 then
	 		player_vy = p.y -14
	 	elseif btn"3" and carrying == 0 then
	 		player_vy = p.y + 14
	 	else player_vy = p.y end
	else
		player_vy = p.y 
	    
	    if btn"1" and carrying == 0   then 
	    	player_vx,select_index = p.x+12,2
		elseif btn"0" and carrying == 0then player_vx,select_index = p.x-11, 0 
		else player_vx,select_index = p.x,1 end
	end

	fish_jumpy = f.y
	
	if flr(player_r) > 0 then
		player_r -= 3 --p.speed
	else
		local player_tile,puddles = get_object_tile(p),leak_puddles[current_rflag_group]
		local ptx = abs(player_tile.x-mirror*20)
		if #puddles > 0 then 
			local other_corner = puddles[1].other_corner
			if player_tile.t == other_corner then 
				local active_switch = primary_switches[active_primary_pipe][active_primary_switch]
				del(puddles,puddles[#puddles])
				if active_primary_switch <=2 and active_switch.y < p.y  then
					switch_dir =-1
				else
					switch_dir*=-1 
					create_leak(active_switch,active_switch.vh*-1,current_rflag_group,false)
				end

			end
		end
		if next_position.num then
			current_rflag, current_rflag_group,rock_index = next_position.num, next_position.group,next_position.rock_index  
		end
	 	sfx(-1)
		player_r, player_vy, player_vx, can_change_rspd, rotate_trigger, player_state = 0, p.y, p.x, true, 0, 2
		find = (current_rock == nil) and true or false
	end

end

function state2()

	message,fish_visualx,next_position = "",f.x
	local this_flag, action = rotate_flags[current_rflag_group][current_rflag]

	if active_primary_pipe ~= current_rflag_group then 
		active_primary_pipe,active_primary_switch,switch_dir = current_rflag_group,1,1
	end


	if cam.r < 14 and carrying==0 and s~=0 then cam.r +=1 end

	if btn"4" then
		angle+=r_spd*(.8)
	end 

	local fish_future,last_rock_index,v_ctrl,h_ctrl,rock_increment = {
		x = f.x,
		y = f.y,
		r = fish_radius
	},rock_index,this_flag.controls[2],this_flag.controls[1]

	if carrying == 0 and fish_radius> 20 then
		rotate(p,fish_future,fish_future.r,angle+r_spd*2)
		if collision_with_tile(fish_future,darrays[30]) or collision_with_rock(fish_future,v_ctrl) or collision_with_rock(fish_future,h_ctrl) then --to do: figure out collision after finished w/ segment
			if fish_dy == 0 then
				r_spd *= -1
			elseif fish_dy > 0 and abs(fish_jumpy+fish_dy-f.y) <= 7 then
				fish_dy = -3
			end
		end 
		if fish_future.y<40 and current_rflag == 1 and level == 0 then
			r_spd *= -1
		end


		local puddle = fish_in_leak_puddle()
		if puddle and fish_dy == 0 and fish_radius >= 48 then
			r_spd,action = puddle.spin_direction,1
		end
	end

	local button_input = (btn()%3==1) and -1 or 1

	if v_ctrl ~= 0 then
		if (btnp"3" or btnp"2") and falls_between(rock_index+button_input,-1,5) then
			rock_index += button_input
			current_rock,action = v_ctrl,1
		end
	end

	if h_ctrl ~= 0 then
		if (btn"0" or btn"1") and falls_between(rock_index+button_input,-1,5) then
			rock_index += button_input
			current_rock,action = h_ctrl,1
		end
	end


	if current_rock then
		local rock = rock_groups[current_rock]
		transition_rock = rock_groups[current_rock]
		if array_contains_item(rock_index,{0,4}) then
			next_position = rock.connected_rflags[max(rock_index/2,1)]
			if active_secondary_pipe > current_rflag_group and next_position.num == 1 then rock.complete = false end
			current_rock = nil
		else
			if not rock.complete and rock_index == 2 then
				rock_index = last_rock_index
			else
				next_position,angle2 = rock.rocks[rock_index],get_angle(p,rock.rocks[2])
			end
		end
		if array_contains_item(rock_index,{1,3}) then 
			carrying = 1
			fish_jumpy = f.y
		end
	else
		p.x, p.y, next_position = this_flag.x, this_flag.y, rotate_flags[current_rflag_group][current_rflag+switch_dir]
	end


	if action and next_position then
		p.speed,p.angle,player_r,angle,player_state  = 3, get_angle(next_position,p),get_radius(next_position,p),get_angle(p,f),1 
	end

	if btnp"5" and fish_dy==0 then
		fish_dy=-6
		sfx(52)
		if carrying == 1 then
			angle,carrying= angle2,0
		end

	elseif btnp"5" and fish_dy~=0 then
		f.slam,fish_dy = true,5
		sfx(53)
		create_particle(fish_future.x,fish_future.y,0,0,10,0,0,2,6,nil)--shock wave
	end

		f.last_fy = (f.newfy ~= 0) and f.new_fy

		f.new_fy=f.y

		fish_jumpy = fish_jumpy+fish_dy+f.new_fy-f.last_fy 

		if fish_jumpy<f.y and carrying == 0 then
			if fish_dy<5 then
				fish_dy=fish_dy+.7
			end
		else
			f.slam,fish_dy,fish_jumpy = false,0,f.y
		end

	if carrying == 0 then
		if fish_radius< 50 then
			fish_radius+=3
		else
			angle += r_spd
		end
	end

	vh = (current_rflag == 1) and -1

	rotate(p,f,fish_radius,angle)

	if secondary_switches[active_primary_pipe] and #secondary_switches[active_primary_pipe] > 0 then
	secondary_pipe_progress()
	end
	
	primary_pipe_progress(f,p)


end

function state3() 
	if poi_index == 3 then cam.r = 0 player_state = 2 find = true poi_index = 1 fish_dy = -4  angle = get_angle(p,f) del(projectiles,projectiles[1]) return end
	film_object = points_of_interest[poi_index]
	cam.r,cam.angle = get_radius(cam,film_object),get_angle(film_object,cam)

	local proj = projectiles[1]
	if flr(cam.r) > 3 then 
		cam.r-= 3
	else
		proj.switch.state = 'up'
		if film_object == primary_switches[current_rflag_group+1][1] then
			create_leak(film_object,1,active_secondary_pipe,false)
		end
		rotate(proj.dest,proj,proj.r,proj.angle)

		if proj.r  >  flr(0) then
			if proj.sprite then proj.sprite = darrays[29][flr(t%8/2)+1] end
			proj.r -= 2
		else
			if proj.sprite then proj.par.complete = true end 
			proj.sprite = nil
		end
		if cam.pause < 60 then
		cam.pause += 1
		else
		poi_index += 1
		end
	end

end

function state4()
	player_vy = p.y 
	mcenter,start= cam,nil
	fish_radius +=3
	rotate(p,f,fish_radius,angle)
	sfx(-1)
	restart_timer += 1
	if btn"4" and btn"5" and restart_timer > 50 then
		--clear_entire_map()
		reload(0x2000, 0x2000, 0x1000)
		_init(2)
		mcenter = rotate_flags[1][1]
		music(2)
	end
end


function create_particle(x,y,angl,speed,duration,size,fill,grow,color,dmg,msg)
	local p = {
		startx=x,
		starty=y,
		x = x,
		y = y,
		radius = 0,
		angle = angl,
		time = 0,
		duration = duration,
		speed = speed,
		size = size,
		fill = fill,
		grow = grow,
		color = color,
		dmg = dmg,
		msg = msg

	}
	add(particles,p)
end

function move_map(dir)
	scroll_dir=dir*-1
	place_segment(true)
	offset_player()
	if s == 1 and upgrades < level then
		player_r,s = player_r+96,1
	end
	s+=dir

	place_segment(false)
	can_scroll = false
end

function _update()
	if player_state == 0 then
		state0()
	elseif player_state == 1 then
		cam.angle = angle
		state1()
	elseif player_state == 2 then
		cam.angle = angle
		state2()
	elseif player_state == 3 then
		state3()
	elseif player_state == 4 then
		state4()
	elseif player_state == 5 then
		state4()
	end

	if not can_scroll and current_rflag_group ~= 2 then
		can_scroll=true
	end
	rotate(film_object,cam,cam.r,cam.angle)
	if can_scroll then
		if cam.y >= 164 then
			move_map(1)
		elseif cam.y <= 70 and s>1 then
			move_map(-1)
		end
	end


 	function offset_player()
 		cam.y,player_vy,p.y,fish_jumpy,f.y = scroll_object(cam.y),scroll_object(player_vy),scroll_object(p.y),scroll_object(fish_jumpy),scroll_object(f.y)
	end


	if rock_index == 1 or rock_index == 3 then
		if fish_radius > 0 then
			fish_radius -= 4
		else
			--carrying = 1
			fish_radius = 0
		end
		cam.r = fish_radius / 2
	end

	if player_iframes > 0 then
		player_iframes -= 1
	else
		player_iframes = 0
	end

	if player_hp == 0 then
		if cam.r>0 then
			cam.r -= 1
		end
		big_words,message ={{22,6,24,9},{38,55,9,40}},"score: "..score.."\n\nplay again \n  —+Ž"
		player_state = 4
	end

	if crown then 
		big_words,message = {{57,38,54},{56,23,25}},"score: "..score.."\n\nplay again \n  —+Ž"
		player_state = 5 
	end

	local splash_size = abs(fish_dy)+2
	if can_scroll and abs(fish_jumpy-f.y)<10 and carrying == 0 and player_state ~= 0 and player_state ~= 3 then
		create_splash(f,splash_size,splash_size/2,splash_size,splash_size/2,-.25,12)
	end


	t+= .75
	t2+=.025



end


function get_transition_square()
	local square =  {}
	for id, o in pairs(darrays[23]) do
		add(square,tiles[get_object_tile(p).num+o+1].t)
	end
	return square
end


function set_transition_square()
	for id, a in pairs(darrays[24]) do
		tiles[a+1].t = transition_square[id]
	end
end

function create_splash(obj,count,speed,dir,size,grow,col)
	for i=1,count do
 		create_particle(obj.x,obj.y,rnd(6),speed,rnd(dir)+1,size,1,grow,col,nil)
	end
end

function find_path3(obj1,obj2,valid_tiles,offsetx,offsety)
	local startx, starty = obj1.x, obj1.y
	local checked, i, found, ids = {{x=startx,y=starty,t=obj1.t,p=0,si=1}}, 1, false, {}
	add(ids,tonum(checked[1].x..checked[1].y))
	repeat 
		if i >= 32765 then return nil end
		local par = checked[i] --parent
		if par == nil then break end
		for j=1,4 do
			local itemx,itemy=par.x+x_array[j],par.y+y_array[j]
			local item = {
						x=itemx,
						y=itemy,
						t = nil,
						p=i,
						si=j
					}
			local id,tnum = tonum(itemx..itemy),mget(itemx,itemy)
			item.t = tnum
			if not array_contains_item(id,ids) and array_contains_item(tnum,valid_tiles) and not found then
				add(ids,id)
				add(checked,item)
				if obj2  then
					if itemx == obj2.x and itemy == obj2.y then found = true end
				end
			end
		end
		i += 1
	until found == true 

	local nodes={}
	i = #checked--checked[#checked].p
	while i ~= 0 do

		add(nodes,checked[i])
		local last_node = nodes[#nodes]
		if obj2 then
			last_node.x = abs(last_node.x-mirror*20)*48 - offsetx
			if last_node.si%2==0 and mirror == 1 then 
				last_node.si=last_node.si%4+2 end
			last_node.y = last_node.y*48-offsety-s*48
		end
		i = last_node.p

	end


	return nodes

end

function create_jewel(x,y,jtype)
	local t= max(jtype,1)
	local j = {
		x = flr(x/8)*8,
		y = flr(y/8)*8,
		type = t,
		points = t*50
	}
	add(jewels,j)
end

function drawwave(cornerx,cornery,pvh,width,height,timer)
	for i=0,max(width,height),2 do
		local wave=(sin((i+t)/16)+sin((i+t2)/32))
		local x,y,half_w,half_h=wave,wave,width/2,height/2
		if i%timer==0 then
			if pvh == 1 then -- vertical
				circfill(cornerx+half_w,cornery,half_w,3)
				rectfill(cornerx+x,cornery+i,cornerx+x+width,cornery+1+i,3)
				circfill(cornerx+half_w,cornery+height,half_w,3)
			else
				circfill(cornerx,cornery+half_h,half_h,3) 
				circfill(cornerx+width,cornery+half_h,half_h,3)
				rectfill(cornerx+i,cornery+y,cornerx+1+i,cornery+y+height,3) 
			end
		end
	end
end

function draw_switches(switch_groups,identifier)
	local switch_frames = {66,96,98}
	for id,switches in pairs(switch_groups) do 
		for key, switch in pairs(switches) do


			if not can_scroll then
				switch.y = scroll_object(switch.y)
				if identifier == 'p' then
					switch.c1.y,switch.c2.y = scroll_object(switch.c1.y),scroll_object(switch.c2.y) 
				end
			end

			if s~=1 and s~=2 then
				if switch.state == 'down' then 
					spr(64,switch.x-7,switch.y-10,2,2)
					switch.visible = true
				else
					if identifier == 'p' then
						local puddle = leak_puddles[id][1]
						if puddle then
							if switch.vh == 1 then
								rectfill(switch.x-2,switch.y,switch.x+2,switch.y+20*puddle.y_offset,3)
							else
								rectfill(switch.x,switch.y-2,switch.x+(16*puddle.x_offset)+(mirror*-1*32*puddle.x_offset),switch.y+2,3)
							end
						end
					end
					if switch.visible == true  then
						spr(switch_frames[flr(t%21/7)+1],switch.x-7,switch.y-10,2,2)
					end
				end
			end
			--print(s.num,s.x-8,s.y-8)
		end
	end
end

function draw_words(obj,words)
	if obj and words then
		for id, word in pairs(words) do
			for key, letter in pairs(word) do
				spr(letter,obj.x-(#word*5)-4+key*8,(obj.y-60+id*13)+flr((t+(key*3))%33/11)+1)
			end
		end
	end
end

function _draw()
local camx,camy = cam.x,cam.y
local top_of_screen = camy-64
camera(camx-64,top_of_screen)
local reset_flag = rotate_flags[2][1]
if p.x == reset_flag.x and p.y == reset_flag.y then
		transition_square, transition_mirror = get_transition_square(), mirror
		mirror, troffsetx, troffsety = flr(rnd(10))%2, p.x - transition_rock.x, p.y - transition_rock.y
		level,upgrade_menu_offset,p.x,p.y = level + 1, 100,rotate_flags[1][1].x,rotate_flags[1][1].y
		level_init()
else
cls(0)
pal()
map(0,0,0,0,128,32,1)

	for id, puddles in pairs(leak_puddles) do
		local mcount = 200
		for key, puddle in pairs(puddles) do
			if not can_scroll then
				puddle.y1, puddle.y2 = scroll_object(puddle.y1), scroll_object(puddle.y2)
			end
			local width,height = abs(puddle.x1 - puddle.x2),abs(puddle.y1- puddle.y2)
			if puddle.timer > 1 then
				puddle.timer-=1
			end
			if active_primary_switch==1 then mcount=300 end
			drawwave(puddle.x1,puddle.y1,puddle.vh,min(width,mcount),min(height,mcount),puddle.timer)
			mcount = mcount-(max(width,height))
		end
	end

	if level == 0 and s<1 then
		rectfill(482,12,542,67,0)
	end


map(0,0,0,0,128,32,2)
	
	local rock_sprite = 68
	for rock_group in all(rock_groups) do
		if not can_scroll then
			rock_group.y = scroll_object(rock_group.y)
		end
		if #enemies == 0 and level == 8 then rock_group.complete = true end

		for key, rock in pairs(rock_group.rocks) do
			rock.x,rock.y = rock_group.x+rock.offsetx,rock_group.y+rock.offsety
			local draw = true
			if key == 2 then 
				if rock_group.complete then rock_sprite = 70 else draw = false end 
			else
				rock_sprite = 68
			end
			if s==1 or s==2 then
				draw = false
			end

			if draw then 
				spr(rock_sprite,rock.x-7,rock.y-6,2,2)
			end
		end
	end
	draw_switches(secondary_switches,'s')

	draw_switches(primary_switches,'p')


	for id,rflags in pairs(rotate_flags) do
		for key, flag in pairs(rflags) do
			if not can_scroll then
				flag.y = scroll_object(flag.y)
			end
		end
	end

	for id, projectile in pairs(projectiles) do
		if not can_scroll then
			projectile.y = scroll_object(projectile.y)
		end
		if projectile.sprite  then
			spr(projectile.sprite,projectile.x-7,projectile.y-7,2,2)
		end
	end

	local phurt = false

	for e in all(enemies) do

		local d,fd,enemy_type = get_radius(e,{x = player_vx,y = player_vy}),get_radius(e,f),e.type

		local part = ept[enemy_type] --particle type

		if not can_scroll then
			if e.path then
				for j in all(e.path) do
					j.y = scroll_object(j.y) 
				end
			end
			e.y = scroll_object(e.y)
			--e.state = 1
		end


		local c = 3
		if e.contact_dmg then 
			c = 8
			 if d < 8 then
			 	phurt = true
			 end
		else
			if t%e.timer == 0 then pal(3,8) else pal() end
		end

		local active = true

		if enemy_type == 3 and e.switch.state == 'down' then
			active,e.contact_dmg,e.timer = false,false,0
		end

		e.vx = e.x-3

		if enemy_type == 3then
			e.x,e.y = e.switch.x-4,e.switch.y+2
			--e.y = e.switch.y+2
			if e.switch.state == 'up'then
				e.switch.visible = false
			end
		end

		if active then
			 if e.state == 1 then
			 	e.path,e.pathi,e.r,e.angle = nil
				if current_rflag >= 2 then
					if enemy_type ~= 4 then
						if d<128then
							e.path =  trace_edge(e,darrays[18][enemy_type])--find_path(e,p)
							e.pathi = 2
						end
					else
						local start = get_object_tile(e) --TO DO: GOT TO GET THE PATHFINDING ALGORITHM WORKING WITH THE MIRROR

						local goal = get_object_tile(p)

						if start ~= goal then 
							e.path = find_path3(start,goal,darrays[5],e.offset_x,e.offset_y) 
							e.pathi = #e.path 
						end
					end
				end
				if e.path then e.state = 2 end

			elseif e.state == 2 and can_scroll then
				if find and enemy_type == 4 then 
					e.state = 1 
				else

					if flr(e.r) ~= 0 then 
						if player_state ~= 3  then e.r-=.5 end

					else 
						e.r=0 
						if e.pathi > 1 then
							e.pathi -= 1
							local this_node = e.path[e.pathi]
							e.angle,e.r = get_angle(this_node,e),get_radius(e,this_node)
						else
							e.state = 1
						end

					end
					e.si = darrays[14][enemy_type][e.path[e.pathi].si]
					e.flip_x = (darrays[33][enemy_type][e.path[e.pathi].si] == '1') and true or false

					if enemy_type == 1 and d<30 then
						pal(3,8)
						pal(11,14)
						e.ai, e.contact_dmg = 1, true 
					else e.contact_dmg = false end
					if enemy_type ~= 3 then -- 3 doesn't move, it's stuck in the switch hole
						rotate(e.path[e.pathi],e,e.r,e.angle)
					end

					if enemy_type == 3 or enemy_type == 5 then
						local target = next_position
						if player_state == 2 then target = rotate_flags[current_rflag_group][current_rflag] end
						local part_angle = get_angle(e,target)
						part[1][1] = part_angle
						if enemy_type == 5 then
							part[1][2], part[1][3] = part_angle + .02, part_angle + -.02
						end
					end
				end
				if d<=tonum(darrays[17][enemy_type]) and enemy_type ~= 1 then e.ai = 1 e.state = 3 e.timer = tonum(darrays[32][enemy_type]) e.can_attack = true end 

			elseif e.state == 3 then
				if time()%1==0 and player_state ~= 3 then e.timer-=1 end
				if e.timer > 2 then
					e.si = darrays[15][enemy_type][e.next_dir]
					if player_vx > e.x then e.flip_x = true else e.flip_x = false end
				elseif e.timer == 2 then -- need the entire expression because otherwise the animation doesn't continue
					
					if e.ai < #darrays[16][enemy_type] and t%6==0 then
						e.ai += 1
					end
					e.si = darrays[16][enemy_type][e.ai]
					if e.can_attack then

						for id,a in pairs(part[1]) do
							create_particle(e.vx+7,e.y,a,.8,140,2,part[5],0,part[8],'p')					
						end
						e.contact_dmg,e.can_attack = true,false
					end
					pal(3,8)
					pal(11,14)
				elseif e.timer == 0 then
					c,e.ai,e.contact_dmg,e.state=3,1,false,2
				end
			end
			
			if enemy_type == 5 then
				drawwave(e.x-7,e.y+16,0,22,8,1)
				rectfill(e.x-8,e.y-8,e.x+16,e.y+20,3)
				circ(e.x+4,e.y-8,12,11)
				circfill(e.x+4,e.y-7,12,3)
				spr(15,e.vx+4,e.y-25,1,1)
			end
			if fd < 12 and f.slam and abs(fish_jumpy-f.y)<18 and player_state ~= 3 then
				create_splash(e,30,3,7,7,-.8,3)
				e.hp -= 20
			end

			if e.hp>0 then
				if level==8 and current_rflag > 1 then
					local sx = camx-48
					print("boss",camx-8,cam.y+51,7)
					rectfill(sx,camy+60,sx+flr(e.hp*.48),camy+57,8)
				end
			else
				if level == 8 then rock_groups[2].complete = true end
				del(enemies,e)
				local addition = enemy_type*100
				create_particle(e.vx,e.y,0,0,12,2,0,0,0,nil,addition)
				score += addition
			end

			spr(e.si,e.vx,e.y-14,2,2,e.flip_x,false)
		end
	end
	find = false
	local body,hands  = {x= player_vx, y = player_vy-8},{x = 0, y = 0}
	rotate(body,hands,4,angle)


	for jewel in all(jewels) do
		jewels[#jewels].x = 0 
		if not can_scroll then
			jewel.y = scroll_object(jewel.y)
		end
		
		local d = get_radius(body,jewel)
		if d <= 6 then 
			local addition = jewel.type*50
			create_particle(player_vx+4,jewel.y,0,0,12,2,0,0,0,nil,addition)
			sfx(50)
			score+=addition del(jewels,jewel) 
		end 
		spr(darrays[28][jewel.type][flr(t%24/6)+1],jewel.x,jewel.y)
	end



	if player_iframes%2==0 then
		circfill(player_vx,player_vy,4,1)-- player
		local frame = 0
		if player_iframes ~= 0 then frame = 5 end
		spr(darrays[27][player_state+1+frame],player_vx-7,player_vy-16,2,2)
		if player_state < 4 then
			if fish_radius > 4 then
				line(hands.x,hands.y,f.x,fish_jumpy,1)
			end
			circfill(hands.x,hands.y,2,7)
			circ(hands.x,hands.y,2,1)
		end
	end

	if carrying == 0 then
		if player_state ~= 1 then
		circfill(fish_visualx,f.y,4,0) -- fish shadow 
		end
	else 
		spr(30,f.x-8,fish_jumpy-28,2,2)
	end

	for part in all(particles) do
		local origin,d  = { x = part.startx, y = part.starty },get_radius(part,body)
		if not can_scroll then
			part.starty = scroll_object(part.starty)
			origin.y = scroll_object(origin.y)
			part.y = scroll_object(part.y)
		end
		rotate(origin,part,part.radius,part.angle)



		if part.msg  then 
			print(part.msg,part.x-8,part.y-8,7)
		else
			if part.fill == 0 then
				circ(part.x,part.y,part.size,6)
			else
				local col = part.color
				if part.dmg == 'p' and t%1.5== 0 then col = 14 end
				circfill(part.x,part.y,part.size,col)
			end
		end

		if player_state ~= 3 then

			if d<8 and part.dmg == 'p' then 
				part.sprite, part.time, phurt = 189, part.duration-3, true 
			end

			if part.time < part.duration then
				part.radius +=part.speed

				part.size += part.grow

				part.time += 1
			else 
				del(particles,part)
			end

		end
	end

	if fish_dy ~= 0 and fish_jumpy<=f.y and player_state ~= 0 then
		spr(30,f.x-4,fish_jumpy-8,2,2,(flr(time()%2)==0),false)
	end

	if phurt and player_iframes == 0 then
	 	player_hp-=1
	 	player_iframes = 50
	end

	if player_state ~= 0 then
		for i = 1, player_hp do
			print('‡',camx-71+i*7,top_of_screen,14)
		end
			print(score,camx+48,top_of_screen,7)
	end

	-- upgrade menu between levels
	if player_state == 1 then
		if upgrades < level  then	
			local y1, msg, spr_i = p.y+upgrade_menu_offset, " level "..level.."\ncomplete!", 62
			if (level+1)%2==0 then
				spr_i = 14
			end
			if level == 9 then 
				spr_i, msg = 15,' you got \nthe crown!'
			end
			if btnp(5) then
				upgrades += 1
				if spr_i == 14 then 
					player_hp += 1
				elseif spr_i == 15 then
					crown = 1 
					music(32)
				end
				if level < 8 then
					if music_tracks[flr(level/3)+1] ~= music_num then
						music_num = music_tracks[flr(level/3)+1]
						music(music_num)
					end
				elseif level == 8 then
					music(30)
				else 
					music(32)
				end

			end

			spr(spr_i,509,y1)
			
			print(msg,camx-17,y1+12,7)

			if upgrade_menu_offset > 20 then upgrade_menu_offset -= 1 end
		end
	end
end
	draw_words(mcenter,big_words)
	print(message,camx-18,camy+24,7)
end
__gfx__
000000001010101010101010111111115555555555555555000aa0000aaaaaa00aaaa0000aaaaaa0000000000066660000aaaa00000000000000000000000000
000000000101010101010101111111115555555555555555000aa0000aa00aa00aa00a000aa0000000000000066666600aaaaaa00000000000000000a000000a
00700700101010101010101011111111555555555555555500a00a000aa000000aa00a000aa00000066ccdd066dddd66aa9999aa0a00a0000ee00ee09a0aa0a9
00077000010101010101010111111111555555555555555500a00a000aa000000aa00a000aaaa00066ccccdd66d66d66aa9aa9aa000000000eeeeee0aaa88aaa
0007700010101010101010101111111155555555555555550aaaaaa00aa000000aa00a000aa00000ccdddd5566d66d66aa9aa9aa00a0a0a00eeeeee099988999
0070070001010101010101011111111155555555555555550aa00aa00aa000000aa00a000aa000000ccdd55066dddd66aa9999aa0000000000eeee00aaaaaaaa
0000000010101010101010101111111155555555555555550aa00aa00aa00aa00aa00a000aa0000000cdd500066666600aaaaaa00a00a000000ee00000000000
0000000001010101010101011111111155555555555555550aa00aa00aaaaaa00aaaa0000aaaaaa0000c50000066660000aaaa00000000000000000000000000
2222222222222222222222222222222255555550555555550aaaaaa00aaaaaa00aa000aa0aa00aa000000000000760000007a000000000000000000111000000
2222222222222222222222222222222255555500055555550aa00aa0000aa0000aaa0aaa0aaa0aa00000000000766600007aaa00000000000001111666110000
2222222222222222222222222222222255555000505555550aa00000000aa0000aa0a0aa0aaa0aa0067ccdd00766d66007aa9aa0060600000001111167761000
2222222222222222222222222222222255550000050555550aa00000000aa0000aa000aa0aa0aaa066ccccdd0766d66007aa9aa0000000000001111161766110
2222222222222222222222222222222255500000505055550aa0aaa0000aa0000aa000aa0aa0aaa0ccdddd550d66d66009aa9aa00060060000011ee166666cc1
2222222222222222222222222222222255000000050505550aa00aa0000aa0000aa000aa0aa00aa00ccdd5500d66d66009aa9aa00000000011111111666666c1
2222222222222222222222222222222250000000505050550aa00aa0000aa0000aa000aa0aa00aa000cdd50000d66600009aaa000606060017777777666666c1
2222222222222222222222222222222200000000050505050aaaaaa00aaaaaa00aa000aa0aa00aa0000c5000000d60000009a000000000000017777761ccc6c1
22222222222222222222222222222222505050500000000000aaaa000aaaaa000aaaa0000aaaaaa000007000000770000007700000000000001d777771ccc6c1
2222222222222222222222222222222255050505000000050aa00aa00aa00aa00aa00aa00aa00aa0007700000007700000077000000000000001d77771ccc6c1
2222222222222222222222222222222255505050000000550aa00aa00aa00aa00aa00aa00aa000000777cdd000066000000aa0000c00c000011c11dddd1cc6c1
2222222222222222222222222222222255550505000005550aa00aa00aa00aa00aa00aa00aaa0000677cccdd00066000000aa000000000001ccccc11dd1c1610
2222222222222222222222222222222255555050000055550aa00aa00aaaaaa00aaaa0000000aaa07cdddd5500066000000aa000000c00c0111cccddddd16610
2222222222222222222222222222222255555505000555550aa00aa00aa000000aa00aa000000aa00ccdd550000dd000000990000c0000000001cdddddd66100
2222222222222222222222222222222255555550005555550aa00aa00aa000000aa00aa00aa00aa000cdd500000dd00000099000000c00c000001dddd6611000
22222222222222222222222222222222555555550555555500aaaa000aa000000aa00aa00aaaaaa0000c5000000dd00000099000000000000000011111100000
2222222222222222222222222222222200000000000000000aa00aa00aa000aa0aa00aaa0aa00aa00000000000067000000a7000000000000000000000000000
2222222222222222222222222222222200000000000000000aa00aa00aa000aa0aa000aa0aa00aa0000000000066670000aaa700000000000000000000000000
2222222222222222222222222222222200000000000000000aa00aa00aa000aa0aa000aa0aa00aa0066ccdd0066d66700aa9aa700c00c0000000000000000000
1212121212121212121212121212121202020202020202020aa00aa00aa000aa0aa000aa0aa00aa066ccccdd066d66700aa9aa70000000000000000000000000
2121212121212121212121212121212120202020202020200aa00aa00aa000aa0aa000aa00a00a00ccdddd55066d66d00aa9aa90000c00c00000000000000000
1212121212121212121212121212121202020202020202020aa00aa000aa0aa00aa0a0aa000aa0000ccdd550066d66d00aa9aa900c0000000000000000000000
2121212121212121212121212121212120202020202020200aa00aa0000aaa000aaa0aaa000aa00000cdd50000666d0000aaa900000c00c00000000000000000
1212121212121212121212121212121202020202020202020aaaaaa00000a0000aa000aa000aa000000c50000006d000000a9000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000a0000000a000000111000001110000011100000111000
00000000000000000000000000000000000000000000000000000000000000000000ddd0000000000019a0aaa0a9100001777100017771000177710001777100
000000000000000000000ffffff00000000000000000000000ddddddddddd0000000dddddd000000017aaa888aaa711001777111117771000177711111777100
00000000000000000000ffffffff0000000000000000000000ddddddddddd5000000ddddddddd000017999888999711001777777777771000177777777777100
00000000000000000000ffffffff00000000dddddddd000000ddddddddddd5000000ddddddddd000017aaaaaaaaa711000111777771111000011177777111100
000000000000000000004ffffff400000000dddddddd000000ddddddddddd5000000ddddddddd000001117171711111000011717171000000001171717100000
00000ffffff0000000004444444400000000dddddddd000000ddddddddddd5000000ddddddddd000001e777777100000001e777777100000001e777777100000
0000ffffffff000000004444444400000000dddddddd000000ddddddddddd5000000ddddddddd000011177771710110000017777171000000001777717100000
0033ffffffff330000034444444430000000dddddddd000000ddddddddddd5000000ddddddddd000177111111111771000001111110000000000111111000000
00034ffffff4300000034444444430000000dddddddd000000ddddddddddd5000000ddddddddd000177117777711771000001777771000000000177777100000
000034444443330000003444444300000000dddddddd000000ddddddddddd5000000ddddddddd000011017777710110000001777771000000000177777100000
00030333333000000000033333300000000055555555000000ddddddddddd5000000555dddddd000000017777710000000011777771100000000177777100000
00000000300000000000000000000000000000000000000000ddddddddddd5000000000555ddd000000017777710000000171777771710000000177777100000
00000000000000000000000000000000000000000000000000055555555555000000000000555000000111111100000001717777777171000001111111000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001777717777100000171711171710000017777177771000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001111101111100000017171717100000011111011111000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000100000000
00000ffffff0000000000000000000000000000000000000000006d000000000000000000ddd00000000000000e000000000001e100000000000001e10000000
0000ffffffff000000000ffffff000000000000000000000000006dd00000000000000dddddd0000000000000e00000000000177710000000000017771000000
0000ffffffff00000000ffffffff00000000000000000000000006ddd0000000000ddddddddd0000000000000e00000000000177710000000000017771000000
00004ffffff400000000ffffffff00000000000000000000000006dddd000000000ddddddddd00000000000000e0000000111777771110000011177777111000
000044444444000000004ffffff400000000000000000000000006dddd000000000ddddddddd000000000000000e000001771711171771000177171117177100
000044444444000000004444444400000000000000000000000006dddd000000000ddddddddd0000000000001111100001771711171771000177171117177100
03b0444444440b0000004444444400000000000000000000000006dddd000000000ddddddddd0000000000017777710001771777771771000177177777177100
00bb44444444bb0000004444444430000000033003330000000006dddd000000000ddddddddd0000011100177111771000001111110000000000111111000000
003b44b44b44b00000034444444430000003333333333000000006dddd000000000ddddddddd0000177710171777171000001777771000000000177777100000
0033443b4444303003034444444430300000003333300000000006dddd000000000ddddddddd0000177711111777171000001777771000000000177777100000
000034334bb3000000003443443300000003330003330000000006dddd000000000dddddd5550000177777777777171000011777771100000000177777100000
0000033333300000003333333333000000300033300033000000005ddd000000000ddd5550000000011177777111171000171777771710000000177777100000
00000000000000000033303333303000000330003000000000000005dd0000000005550000000000001111711177717101717777777171000001111111000000
000000000000000000000030333033000000000000000000000000005d000000000000000000000001e777777177177100171711171710000017777177771000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001777117111111100017171717100000011111011111000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00000000000000000000000000000000000000
00000000000000000000000000000000001111000000000000000000000000000000000000000000000ffffffff0000000b0000000000b0000b0000000000b00
0000000000000000000000000000000001b1b1000000000000000000000000000000000000000000000ffffffff00000001b00b00b00b100001b00b00b00b100
00000000000000000000000000000000000111011000000000000033bbb0000000000000000000000004ffffff4000000001bb1001bb10000001bb1001bb1000
000000000000000000000000000000000013111bb110000000003311113bb000000000bbb3300000000444444441000000011110011110000001111001111000
0000000000000000000000000110000000001bb33bb1000000033333333b30000000bb333333300000004444444b100000001100001100000000110000110000
0000000000000000000000011bb110000001b333333b1000000333333bbb0000000bb3111133300000014444444bb100000000000000000000bbb000000bbb00
00000000000000000000001bb33bb10000131bb333331000000333bbbb333000000b333333330000001b344444b3b10000000000000000000b000b0000b000b0
0000000110000000001111b333333b100013111b333b3100000003333333b000000bb333333330000013333333333b100000000000000000b00000100100000b
0000011bb110000001b1b13b1bb3331000133133bbbb3100000bb333bb3b00000003bb33333bb00000133333333333b10000011111100000b00000111100000b
00001bb33bb1000000011333111b3b3100131111333331000000bbb333330000000003333bb000000013311133333b310000100000010000b00000100100000b
0001b333333b1000001313333133bb3100013331111310000000003333330000000333333333b0000011333333bbbb1100000000000000000b000000000000b0
00013333333310000001133311113331000113311333100000000bbb3330000000000333bbb0000001313333bb331111000000000000000000bb00000000bb00
0013333333333100000013333331113100013133311310000000003333000000000000b333000000131313331313113100000000000000000000000000000000
00133333333331000000333333333333003333113331330000000003b00000000000000b30000000111111331111133100000000000000000000000000000000
00000000000000000000000000444440000000000000000000000000011000000001000001100000000000000110000000000000000000000000000000000000
00000000004444400000000004444444000ffffff0000000000000011bb11000001b10011bb11000000000011bb1100000000000000000000000000000000000
0000000004444444000000001114444400ffffffff0000000000001bb33bb10001b3111bb33bb1000000001bb33bb10000b0000000000b000000000000000000
0000000001144444000011113bb1144400ffffffff000000000001b333333b101b3131b333333b10000001b333333b10001b00b00b00b100000000b00b000000
000000011bb114440001bbb0333bb144004ffffff40000000000013331333310111311333133331000000133313333100001bb1001bb100000bbbb1001bbbbb0
0000001bb33bb144001b333b33333b14004444444410000000001313133333310001131313333331000013131333333100011110011110000011111001111100
000001b333333b14001b333311bbb3140004444444b1000000001333333333310000133333333b31000013333333333100001100001100000011110000111100
000001b311133314001b33333b333b3100144444443310000000131113333331000013111333b33100001311133333b100000000000000000100000000000010
00001b33333333310001b333b3333331001b4444b1bb31101111133333333331000013b1bb333331000013111b1bb3b100000000000000000000000000000000
000013333333333100001333b333333101b333333111b3b11b1b133b1bb333310000131111b3b3310001331111111bb100001111111100000000111111110000
0000133333333b310000133333333b310133111133133bb101111331111b3b3100001333133bb131011b3313133133b100011111111110000001111111111000
00001333333bb3100000133b1bb333100133111131111331013113333133bb3100001331111331311bb313333311113100011111111110000001111111111000
0011133333bb311011111333111b3b10013311113333111000111333111133110000133333111131133313333333311100011111111110000001111111111000
01331333bb3311101b1b13333133bb10001313313333331000001333333111110000133333311131131313333333331100001100001100000000110000110000
13131331313113100111133311113310013133333333331000001333333311110000133333333331133113333333333100000000000000000000000000000000
11111331111133100131133333311110131313333333331000001333333333310000133333333331111013333333333100000000000000000000000000000000
cccccccccc4994cccc4994cccc4994cccccccccccccccccccccccccccc6666cccccccccccc2222cccc2222cccc2222cccccccccccccccccccccccccccccccccc
cccccccccc4994cccc4994cccc4994cccccccccccccccccccccccccccc1111cccccccccccc2222cccc2222cccc2222cccccccccccccccccccccdcccccccccccc
44888844cc8aa8cccc444444444444cccc444444444444cccccccccccc1111cc22222222cc2222cccc222222222222cccc222222222222cccccccccccccccccc
99aaaa99cc8aa8cccc444499994444cccc444499994444cc11111111cc1111cc22222222cc2222cccc222222222222cccc222222222222cccdcccdcccccccccc
44aaaa44cc8aa8cccc444444444444cccc444444444444cc11111111cc1111cc22222222cc2222cccc222222222222cccc222222222222cccccccccccccccccc
55333355cc8aa8cccc555555555555cccc499455554994cc11111111cc1111ccffffffffcc2222ccccffffffffffffcccc2222ffff2222cccccdcccccccccccc
cccccccccc4994cccccccccccccccccccc4994cccc4994cccccccccccc1111cccccccccccc2222cccccccccccccccccccc2222cccc2222cccccccccccccccccc
cccccccccc4994cccccccccccccccccccc4994cccc4994cccccccccccc1111cccccccccccc2222cccccccccccccccccccc2222cccc2222cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc6666cccc4994cccccccccccc6666cccc1111cccc1111cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc6666cccc4994cccccccccccc1111cccc1111cccc1111cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc44888844cc8aa8cccccccccccc1111cccc1111cccc1111cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc99aaaa99118aa81111111111cc1111cccc111111111111cccc111111111111cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc99aaaa99118aa81111111111cc1111cccc111111111111cccc111111111111cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc55333355118aa81111111111cc1111cccc111111111111cccc111111111111cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc1111cccc4994cccccccccccc1111cccccccccccccccccccc1111cccc1111cccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc1111cccc4994cccccccccccc1111cccccccccccccccccccc1111cccc1111cccccccccccccccccc
f1fffff9ff1fff9ffffff1ffff1ffff91ffffff9fff1fffffffff1fffff1fff9ff1ffff9ffffff1ffffffff1f1ffff9ffffffff1fff1fff9fff1ffffffff1ff9
f1fffff9ff205f9f9ffff1ffff2005f9205fff179ff1ffff9ffff1fffff1c86bff205ff79f405f1ff9fffff1f1ffff9f9fff4003fff1fff79ff205ffffff1ff9
f205fff9ffff1f9f7ffff205fffff1f7ff1f4039adf205ff7ffff205fff265ffc886788ba678787dfa6888d1f205ff9fa88678dffff200599ffff1fff4003ff9
fff1f1f9f4003f9f1e405ff1fffff1f9ff1f1fe9f7fff1ff94005ff1fffe91ff7fff205fff1f2039ff05f463fc8768bfff403f9fc8868d19a88403fff1ffffcb
fff203e1f1ffff9f1f1f1ff1fff403f9ff203f1bf9f403ffa78d1ff1fff463ff9f1fff1ffc76886bfc87d17ff9f205ffc87888bf1e405719ff7788dff200059f
fffffff1f20fff9f1fff2003fff1fff9ffffff1ff9f1fffff1f92003fc67bfff1e20003ff9205ffff1e2639ffa8df1ff9f1fffff1f1f1a7bfff20f9ffefff19f
fffffff1feffff9f1ffffffffff205e1ffffff1ff1e20ffff1f9fffff1e20fff1ffffffffadf1ffff1ff7f9ffff1e20f1e20ffff1f2f203ffffeff9ff18f037f
fffffff1f18886bf1ffffffffffff1f1ffffff1ff1ffffff03e1fffff1ffffff1fffffffff1e20fff1ffa8bffff1ffff1fffffff1ffffffffff188bff1a888bf
fffff1f9fffff1fff1fffff91ff9ffffff1ff9ffff1fffffff1ff9ffff1ffffffff1ffffffffff1ff1ff9fffff1ffff91ffffff9f1fffff9f1fffff9f1fffff9
c688f1f98dfc8786f1fffff91ffa86dffc7dfa8f8d1fc886fc7dfa8f8d1fc88688d1c88d9f405f1fc768bffffc76fff91c86888bf205c68bf1c8dff9c7688df9
1e4603f7fa4603e1c768866b2005ff7ff926057ff92065e1f926057ff92065e1ff9265e1a678787d91f405e5f91a86f9265e4005fff17405f19f7ff971fffa8b
1f1788f9f719fff19205ffffefc7df9ff7fad17ff9ff91f1f7fad17ff9ff91f1ff9e91f1403f203971f1c7d1463f4659cb1f1ff1f4039ef1f2659ff79205e405
1f2059f9f9265ff1a887688816b2659ff1e4639ffa6463f1f1e4639ffa6463f1ff9463f11fefc86b9203719119fc7b199f203ff1f1ff9403fe91a86ba687d1f1
1fef17f9f7ea7df1fff205f71ffe917ff1f19e9fff719ef1f1f19e9fff719ef1ff919ef1203cbfff9fff926326063e39a688f403f1ff71fef1b205e5fff263e3
1f2039f7f92039f1fffef1f71ff2639ff1f2637fff9263f1f1f2637fff9263f1ff9263f1eff9ffffa888bf9ee9f7fff9fff7f1fef20063c1f1fff1f1fffe9fff
1ffffa8bfa688bf1fff203e11fffa8bff1ffa8bfffa6bff1f1ffa8bfffa6bff1ffa6bff1186bffffffffffa11bfa888bfff1e203ffffa8b1f1fff203fff1bfff
__gff__
0301010103000300030300000000000003030303030300030303000000000000030303030303000303000000000000000303030303030000030000000000000000000000000000000303000000000000000000000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000cfcfcfcfcf00000000000000000000000000000000000000000000000000000000000000000000000000000000000004241504140415040415241504142524040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cfcfc1cfcf00000000000000000000000000000000000000000000000000000000000000000000000000000000000004142515040425141524142425240414250400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cfcfc1cfcf00000000000000000000000000000000000000000000000000000000000000000000000000000000000004041524250414000000000015042425241500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014252415140000000000000025141514150400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025141514000000000000000000251415142500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015241524150000000000000000152424150400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024151415240000000000000000241415142500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014250414150000343434340000042524250400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024151425140000101010100000141514150400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004242514250000101010100000252425240400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030303101010100303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030303101010100303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030303101010100303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101101010100101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0123000017011170111702117021170311703117021170210b0100b0100b0100b0100b0100b0100b0100b01016011160111602116021160311603116021160210d0100d0100d0100d0100d0100d0100d0100d010
0123000019012200121902220022190322003219022200221900023000000000000000000000000000000000190121c012190221c022190321c032190221c0220000000000000000000000000000000000000000
002300002054020540205402054020540205402054000000000001e5451e5451e5451e5451c5401c5401c5101c5401c5401c5401c5401c5401c5401c5401c5400000021545215452154521545205402054020510
012300000e6250000000000000000e6250000000000000000e6250000000000000000e6250000000000000000e6250000000000000000e6250000000000000000e6250000000000000000e625000000000000000
0023000017020170211703117041170411704117031170210b0200b0200b0200b0200b0200b0200b0200b02009021090210902109021090310903109021090211502115021150211502115021150211502115021
002300002054020540205402054020540205402054020540000001e5451e5451e5451e5451c5401c5401c51019540195401954019540195401954019540195400050021545215452154521545205402054020510
01150010070530d0501a645070530d0550d0501a6450d05007053100551a6451405512055100551a6450b050070530d0550d0000d0540d0550d0550d0000d0540d05510055120551405512055100550b0500b050
0015000019120191200000017120170001905525055190551900019055250551905500000000001e1300000019130191300000017130000001905525055190550000019055250551905500000000001e13000000
011500001e1201e120110001d1201d00000000000000000000000000000000000000000000000023120231001e1201e120110001d120000000000000000000000000000000000000000000000000002313000000
01150000070531a6001a6450705300000070531a6450000007053000001a6450705300000070531a6450000007053000001a6450705300000070531a6450000007053000001a6450705300000070531a64500000
011500001e12019120161201c12019120161201e12020120001001c1201b12019120181201b1201e1201b1201c120001000010000100001000010000100001000010000100001000010000100001002310000100
001500000a050160511a6450a055160510a0541a6450a05514050200551a6451405520055140551a64514050070530d0501a645070530d0550d0501a6450d050070530d0501a645070530d0550d0501a6450d054
001500001e12019120161201c12019120161201e12020120001001c1201b12019120181201b1201e1201b12019120191221912200100001000010000100001000010000100001000010000100001002310000100
001500000805008050080500805008050080500805000000000000605506055060550605504050040500405504050040500405004050040500405004050040400000009055090550905509055080500805008050
001500000805008050080500805008050080500805000000000000605506055060550605504050040500405001050010500105001050010500105001050010500105001050010500105001050010500105001050
001500000000014521145201252014520155201852018520185201852018520185200000000000000000000000000195211952018520195201b5201c5201c5201c5201c5201c5201c52000000000000000000000
01150000000001e5211b520195201b5201c5201e5201e5201e5201e5201e5201e5200000000000000000000000000000001c5251b5251c5251e5251f525205202052025520185001e5201e5201c5200000000000
00150000000001e5511b530195301b5301c5301e5301e5301e5201e5201e5101e5100000000000000000000000000000001c5551b5551c5551e555205551955219552195510d5510155100000000000000000000
00150000070530f0101a6351a6350f010070531a6450000007053000001a6450000007053000001a6450d010070530d0101a6451a6450d010070531a6450000007053000001a6450000007053000001a64500000
011000000e2351a235320151023518235320151a235320151d23532015320151c235320151a2353201510230102301a235320151123518235320151a23532015182353201532015152353201518235152350e230
011000000212002120306200415013433134003062505150091500915030630071501343305150306250415004150041503063013400134330515037625130000015000150306303062513433001503062502150
001000000e2351a235320151023518255320151a235320152123532015320151f235320151d23532015182303200024230320151a23522235320151f235320152123500000000000000000000000000000000000
001000001a0321a0321a0321a03218032000001a0521a0521d0521d0521d0521d052000000000000000000001c0321c0321c0321c0321a0321a0001c0321c0321f0321f0321f032000001f100000002110000000
001000001a0321a0321a0321a03218032000001a0321a0321d0321d0321d0321d032000000000000000000002403224032240322403222032220021f0321f03221032210322103221032000001f1000000021100
001000001a0521a0521a0521a05218052000001a0521a0521d0521d0521d0521d052000000000000000000002405224052240522405222052220021f0521f05221052210522100021050000001f0501d0501d050
001000001c5501c550005001a5501a5501a5501a550195501955019550005001f550195001d5501c550005001d5501d5501d5501c5501c55000500005001d5501d55000500005000050000500005001a5501c550
001000000c0500c050306200a055134330a0003062009050090500905030620090501343300000306200000002050020503062000050134330000030620020500205002050306200205013433020503062000000
001000001d550005001855018550005001d550005001c5501c5501c5501c55000500005001d5501f55021550215502155000500005000000000000000000000000000000000000021550005001f5501d5501d550
0010000011050110503062011055134330a0003062009050090500905030620090501343300000306200000002050020503062000050134330000030620020500205002050306200205013433020503062000000
001000001d550005001855018550005001d550005001c5501c5501c5501c55000500005001a550195501a5501a5501a55000500005000050000500005000050000500005000050021500005001f5001d50000500
001000000212002120306200415013433134003062505150091500915030630071501343305150306250415004150041503063013400134330515037625130000915009150306200915013433000003062000000
00100000182251822518000182251822518000182251522500000152250000015225152251522500000000001a2251a225000001a2251822518000182251a225000001a225000001a2251a2251a2250000000000
001400000734507345376350e3450734507345376350e3450734507345376350e3450734507345376350e3450734507345376350e3450734507345376350e3450734507345376350e3450734507345376350e345
001400002655026521265110000000000000002155015100245502452100000225502255000000215552655026550265212651100300000000000021550151002455024521000002255016100000002155526550
001400002655026521265110000000000000001f550000001e5501e521000001f5552155500000225551a5501a5501a5211a51100000000000000000000000000000000000000000000000000000000000000000
001400002655026521265110000000000000001f550000001e5501e521000001f5552155500000225501f5501f5501f5211f51100000000000000000000000000000027555275552755527555265502655526550
00140000023550235532635093550235502355326350935502355023553263509355023550235532635093550735507355376350e3550735507355376350e3550735507355376350e3550735507355376350e355
001400002655026521265110000000000000000000000000000002455524555245552455522550225552255022550225212251100000000000000000000000000000027555275552755527555265502655526550
001400002655026521265110000000000000000000000000000002455524555245552455522550225551f5501f5501f5211f51100000000000000000000000000000027000270002700027000260002600026000
001400001a000134331a03413400134331a034134000e0001a000134331a03413400134331a034134000e0001a000134331a03413400134331a034134000e0001a000134331a03413400134331a034134000e000
001000001a016220161e0161a0161a016220161e0161a0160000000000000000000000000000000000000000220161e0161a01622016220161e0161a0162201616000120000e0001600000000000000000000000
001000001a1421a1421a1421a1421a1421a1421a14200000000000000018142181421814216142161421614216155161421614216142161421614216142161421614200000000001b1421b1421b1421a1421a142
001000001a1421a1421a1421a1421a1421a1421a14218000180000000018142181421814216142161421614213142131421314213142131421314213142131420c0000f5000f5000f5000e5000e5000000000000
001000001307300000071510725207353074540745113552076730705007050070500705007050070500705013073000000715107252073530745407451135520767307050070500705013053076540765400000
002300001f53021530180002253026530245002453022530295302b5302450024530265302450024530225301f5301f5301f5201f5101f5100000000000000001f57500000000000000000000000000000000000
002300000f02513025160251b0250f02513025160251b0251102515025180251d0251102515025180251d02513025170251a0251f02513025170251a0251f0250707500000000000000000000000000000000000
002300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300253002530025300252f0202f020000002f05500000000000000000000000000000000000
001400000e4330e4330e000000000e4330e43300000000000e4330e43300000000000e4330e43300000000000e4330e43300000000000e4330e43300000000000e4330e43300000000000e4330e4330000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000005000050300703006030050300403003030520305100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100100061000610006100061000610006100061001610006100161001610016100161001610036100361000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000c4300e43010430114301343015430174300c430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000c6710c6610c6510c6410c6310c6210c61100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__music__
00 00 01 02 03
02 04 01 05 03
00 41 06 43 44
01 41 06 07 08
00 41 0a 0b 44
00 41 06 07 08
00 41 0b 0c 44
00 41 0d 0f 12
00 41 0e 10 12
00 41 12 0f 0d
02 41 12 11 0e
00 41 13 43 44
00 41 15 43 44
01 41 16 14 13
00 41 17 14 15
00 41 16 14 13
00 41 18 1e 15
00 41 1f 1a 19
00 41 1f 1c 1b
00 41 1f 1a 19
02 41 1f 1c 1d
01 41 20 27 44
01 41 21 27 20
00 41 22 27 20
00 41 21 27 20
00 41 23 27 20
00 41 25 2f 24
00 41 26 2f 24
00 41 25 2f 24
02 41 26 2f 24
01 41 29 2b 28
02 41 2a 2b 28
00 41 2d 2e 2c
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
