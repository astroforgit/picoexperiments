pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
xdebug_stop = false

level_finished = false

--level save data--
level_selector = 1
level_save_data= 1

//blink
blink_speed = 8
blink_t=blink_speed
blink=false

main_menu_selector = 1
main_menu_str={"play","speedrun mode","controls"}

game_timer = 0
speedrun_mode = false

delay_start_level = 0

actual_jmp_ctrls = 1 //1= x to jump, 2= ” to jump
actual_xo_ctrls = 1 //1 x=jmp, o=interact, 2 x=interact o=jmp
actual_xo_x = 5
actual_xo_o = 4
actual_xo_x_str = "—"
actual_xo_o_str = "Ž"
--main--
function _init()
	music(0)
	cartdata("devils_kitchen")
	load_level_time_data()
	init_game()
end

function init_game()
	if dget(level_save_data_adr) > 0 then
		level_save_data = dget(level_save_data_adr)
	else
		dset(level_save_data_adr,level_save_data)
	end
	
	if dget(jmp_ctrl_save_data_adr) > 0 then
		actual_jmp_ctrls = dget(jmp_ctrl_save_data_adr)
	else
		dset(jmp_ctrl_save_data_adr,actual_jmp_ctrls)
	end
	
	if dget(xo_ctrl_save_data_adr) > 0 then
		actual_xo_ctrls = dget(xo_ctrl_save_data_adr)
	else
		dset(xo_ctrl_save_data_adr,actual_xo_ctrls)
	end
	
	--costum menu--
	updatemenu()
	
	cur_lvl = 1
	init_machines()
	init_player()
	init_particles()
	init_world_items()
	
	actual_boxes 			= boxes_level1
	actual_machines = machines_level1
	actual_update=update_menu
	actual_draw = draw_menu
	
	--define levels--	
	actual_boxes=boxes[cur_lvl]
	actual_machines=machines[cur_lvl]
		
	player.x = level.px[cur_lvl]
	player.y = level.py[cur_lvl]
end

function _update()
	
	if not debug_stop then
		blink_t -= 1
		if blink_t <= 0 then
			blink = not blink
			blink_t = blink_speed
		end
		actual_update()
	end		
	update_ani()
end

function change_jmp_ctrls()
	if actual_jmp_ctrls == 1 then
		actual_jmp_ctrls = 2
	else
		actual_jmp_ctrls = 1
	end
	sfx(2)
	updatemenu()	
	dset(jmp_ctrl_save_data_adr,actual_jmp_ctrls)	
end

function change_ox_ctrls()
	if actual_xo_ctrls == 1 then
		actual_xo_ctrls = 2
	else
		actual_xo_ctrls = 1
	end
	sfx(2)
	updatemenu()	
	dset(xo_ctrl_save_data_adr,actual_xo_ctrls)
end

function updatemenu()	
	if actual_xo_ctrls == 1 then
		actual_xo_x = 5
		actual_xo_o = 4
		actual_xo_x_str = "—"
		actual_xo_o_str = "Ž"
	else
		actual_xo_x = 4
		actual_xo_o = 5
		actual_xo_x_str = "Ž"
		actual_xo_o_str = "—"
	end
	
	if actual_jmp_ctrls == 1 then
		menuitem(1, "change "..actual_xo_x_str.." to jmp", function() change_jmp_ctrls() end)	
	else
		menuitem(1, "change ” to jmp", function() change_jmp_ctrls() end)
	end 
	
	menuitem(2, "interact = "..actual_xo_o_str, function() change_ox_ctrls() end)
end

function _draw()
	if not debug_stop then
		cls(0)
	end	
	actual_draw()
	draw_debug()
end

--menu--
function update_menu()
	if btnp(—) or btnp(Ž) or btn(‘) then
		sfx(sfx_ui_select)
		if main_menu_selector == 1 then
			actual_update = update_lvl_selector
			actual_draw   = draw_lvl_selector
		elseif main_menu_selector == 2 then
			cur_lvl = 1
			speedrun_mode = true
			game_timer = 0
			open_level()
		end
		
	elseif btnp(”) then
		sfx(sfx_ui_switch)
		main_menu_selector -= 1
		if main_menu_selector < 1 then
			main_menu_selector = #main_menu_str
		end
	elseif btnp(ƒ) then
		sfx(sfx_ui_switch)
		main_menu_selector += 1
		if main_menu_selector > #main_menu_str then
			main_menu_selector = 1
		end
	end
	
	if main_menu_selector == 3 then
		if btnp(‹) or btnp(‘) then
			change_jmp_ctrls()
		end
	end
end

function draw_menu()
	map(17, 58,31,9,9,2)
	print_center("kitchen     ", 27, 14)
	draw_window_centered(64, 29, 0, 2, 35)
	
	for i=1, #main_menu_str do
		local str = main_menu_str[i]
		if main_menu_selector == i then 
			if blink or main_menu_selector == 3 then
				str = "‘ "..str
				print_center(str, 38+(i-1)*9, 9)
			end			
		else
			print_center(str, 38+(i-1)*9, 5)
		end
	end
	
	print("saturn91.dev", 8, 74, 11)
	map(0, 56, 0, 64, 16, 11)
	
	if main_menu_selector == 3 then
		draw_window_centered(100, 61, 1, 7, 65)
		print_center("‹ ‘:   move    ", 69,9)
		if blink then
			if actual_jmp_ctrls == 1 then
				print_center(" "..actual_xo_x_str..":      jump    ", 76,8)
			else
				print_center(" ”:      jump    ", 76,8)
			end
		end
		
		print_center(" ƒ:      eat/heal", 83,9)		
		print_center(" "..actual_xo_o_str..":      interact", 90,9)		
		print_center("-- keyboard --",99,11)
		print_center("arrows: move",106,9)
		print_center("—=x / Ž=c",113,9)
		print_center("menu: enter",120,9)
	end
end
--/menu--

-- level selector--
function update_lvl_selector()
	if btnp(‘) then
		sfx(sfx_ui_switch)
		level_selector += 1
		if level_selector > level_save_data then
			level_selector = 1
		end
	elseif btnp(‹) then
		sfx(sfx_ui_switch)
		level_selector -= 1
		if level_selector < 1 then
			level_selector = level_save_data
		end
	elseif btnp(”) then
		sfx(sfx_ui_switch)
		level_selector -= 5
		if level_selector < 1 then
			level_selector = 1
		end
	elseif btnp(ƒ) then
		sfx(sfx_ui_switch)
		level_selector += 5
		if level_selector > level_save_data then
			level_selector = level_save_data
		end
	elseif btnp(—) or btnp(Ž) then
		sfx(sfx_ui_select)
		cur_lvl = level_selector
		open_level()
	end
end

function draw_lvl_selector()
	print_center("select level:"..level_selector, 2, 9)
	local w = 12
	local box_per_line = 4
	local _line = 1
	local offx = 0
	
	for x=1, 5 do
		for y=0, 4 do
			local x1 = (x-1)*2*w+8
			local y1 = y*16+12			
			
			if x+y*5 <= level_save_data then
				if level_selector == x+y*5 then
					y1 -= 2
					draw_window(x1, y1, w, w, 12,7,1)
				else
					draw_window(x1, y1, w, w, 4, 15, 2)
				end				
				
				local _x = x1+5
				if x+y*5 > 9 then
					_x -= 2
				end
				print(x+y*5, _x, y1+4, 9)
				
			else
				draw_window(x1, y1, w, w, 2, 8, 1)
			end
		end
	end
	
	if level_t.normal[level_selector] > 0
	or level_t.speedrun[level_selector] > 0 then
		local y = flr((level_selector-1)/5)*16 + 25
		local x = ((level_selector-1)%5)*12
		
		draw_window(x, y, 80, 27, 1, 7,7)		
		print("Level "..level_selector, x+4,y+4,9)
		print("normal:  "..round_2_floats(level_t.normal[level_selector]).." s", x+4,y+11,7)
		print("speedrun:"..round_2_floats(level_t.speedrun[level_selector]).." s", x+4,y+18,7)
	end				
	
	map(0, 59, 0, 104, 16, 3)
	
	if blink then print_center("— / Ž to select", 96, 11) end
end
--/level selector--

--game--
function update_game()
	actual_boxes=boxes[cur_lvl]
	actual_machines=machines[cur_lvl]
	
	if delay_start_level > 0 then
		delay_start_level -= 1/30
		blink = false
	else
		if not level_finished and player.alive then
			game_timer += 1/30
			update_attacks()
			update_player()
			update_enemies()
			update_cannons()
			update_springs()
			update_machines()
			if check_end() then
				save_level_time_data(cur_lvl, game_timer)
				win()
			end
		elseif level_finished then
			update_end_lvl_menu()
		elseif not player.alive then
			update_lose()
		end		
	end	
end

function draw_game()
	draw_map()
	draw_kitchen()
	draw_enemies()
	draw_player()
	update_particles()
	draw_items()
	draw_attacks()
	draw_ui()
	if level_finished then
		draw_level_finished()
	end
	
	if delay_start_level > 0 then
		draw_window_centered(80, 30, 4, 15, nil, 2)
		print_center("-"..get_lvl_title().."-", 57, 9)
		print_center("level"..cur_lvl.."/"..#level.x, 67, 10)
	end	
	
	if not player.alive then
		draw_lose()
	end
end

function draw_ui()
	draw_p_health()
	draw_game_time()
	draw_devil_ui()
	local x = -8
	local y = -8
	temp = player_on_top_mach()
	if temp	 > 0 then
		x = machines.x[cur_lvl][temp]-level.x[cur_lvl]
		y = machines.y[cur_lvl][temp]-level.y[cur_lvl]
	end
	temp = player_on_top_box()
	if temp  > 0 then
		x = boxes.x[cur_lvl][temp]-level.x[cur_lvl]
		y = boxes.y[cur_lvl][temp]-level.y[cur_lvl]
	end
	temp = player_on_top_of_item()
	if temp > 0 then
		x = world_item.x[temp]/8
		y = world_item.y[temp]/8
	end
	print(actual_xo_o_str,x*8,y*8-8, 7)		
end
--/game--

function update_end_lvl_menu()
	if btnp(—) then
		if cur_lvl < #level.x then
			load_next_level()
			level_finished = false
		else
			level_finished = false
			init_game()
		end
	end
end

function update_lose()
	if btnp(—) then
		speedrun_mode = false
		init_game()
	elseif btnp(Ž) then
		speedrun_mode = false
		last_lvl = cur_lvl
		init_game()
		cur_lvl = last_lvl
		open_level()
	end
end

lose_selector = 1

function draw_lose()
	draw_window_centered(80,41)
	print_center("master is not happy!", 52, 10)
	print_center("...", 59, 8)
	print_center("— back to menu", 69, 7)  
	print_center("Ž restart level", 76, 7)	
end

function draw_level_finished()
	draw_window_centered(80,30)
	if cur_lvl < #level.x then
		print_center("one devil is fed!", 52, 10)
		print_center("more are waiting...", 59, 8)
		if blink then print_center("— next level", 69, 7) end 
	else
		print_center("your shift is over!", 52, 10)
		print_center("enjoy our spreartime", 59, 8)
		if blink then print_center("— back to menu", 69, 7) end 
	end
end

function load_next_level()
	cur_lvl += 1
	if level_save_data < cur_lvl then
		dset(level_save_data_adr, cur_lvl)
	end	
	open_level()
end

function open_level()
	player.x = level.px[cur_lvl]
	player.y = level.py[cur_lvl]
	player.dx = 0
	player.dy = 0
	init_devil()
	init_world_items()
	init_particles()
	init_cannons()
	delay_start_level = 2
	devil_pos.x = -1	
	actual_update = update_game
	actual_draw   = draw_game
	if not speedrun_mode then
		game_timer = 0
	end	
end

function draw_game_time()
	seconds =flr(game_timer%60)
	minutes =flr(game_timer/60)
	if seconds < 10 then
		print(minutes..":0"..seconds, 30, 0, 7)
	else
		print(minutes..":"..seconds, 30, 0, 7)
	end	
end






-->8
--player--
function init_player()
	player={
   sp=1,
   x=10,
   y=110,
   w=7,
   h=8,
   dx=0,
   dy=0,
   max_dx=2,
   max_dy=4,
   acc=0.5,
   boost=4,
   anim=0,
   running=false,
   jumping=false,
   falling=false,
   sliding=false,
   landed	=false,
   alive 	= true,
   health = 3,
   item_id= -1
 }
	--const--
	gravity=0.3
	friction=0.7
	
	time_dmg_blink = 1
	time_last_p_damage = -time_dmg_blink
	player_blink = 0
	player_blink_speed = 4
end

function draw_player()
	if time() - time_last_p_damage >= time_dmg_blink
 or player_blink > player_blink_speed then	
		spr(1, player.x,player.y)
	end
	
	player_blink -= 1
	if player_blink <= 0 then
		player_blink = player_blink_speed*2
	end
	
	if player.item_id > 0 then
		spr(items.img[player.item_id], player.x+4,player.y)
	end
end

function update_player()
	move_player()
	check_for_traps()	
	
	if btnp(actual_xo_o) then
		
		if player.item_id == -1 then
			pick_up_food()
		else
			place_item()
		end			
	end
	
	if btnp(ƒ) then
		player_eat()
	end
end

function win()
	level_finished = true
end

function pick_up_food()
	if player.item_id <= 0 then
		
		temp = player_on_top_of_item()
		if temp > 0 then
			player.item_id = world_item.id[temp]
			world_item.id[temp]=-1
			return
		end	
		
		if collide_map(player,"right",3)
		or collide_map(player,"left",3)
		or collide_map(player,"down",3) then

			temp=player_on_top_box()	
			if temp > 0 then
				player.item_id = boxes.item_id[cur_lvl][temp]
				return
			end
		
			temp = player_on_top_mach()			
			if temp > 0 then
				if machines.proc_dt[cur_lvl][temp] <= 0 then
					player.item_id = machines.item_id[cur_lvl][temp]
					machines.item_id[cur_lvl][temp] = -1
					return
				end
			end
		end	
	end		
end

function place_item()
	if player.item_id > 0 then			
		temp = player_on_top_mach()	
		if temp > 0 
		and machine_can_process(machines.typ[cur_lvl][temp], player.item_id) then	
			local machine_item = machines.item_id[cur_lvl][temp]
			machine_start(machines.typ[cur_lvl][temp], player.item_id)
			machines.item_id[cur_lvl][temp] = player.item_id
			machines.proc_dt[cur_lvl][temp] = machine_types.proc_t[machines.typ[cur_lvl][temp]+1]
			player.item_id = machine_item
			return
		end
			
		//devil
		if player_on_top_devil()
		and devil_eat(player.item_id) then
			player.item_id = -1
			return
		end
		
		//drop item on floor
		if player.landed and player_on_top_mach()<=0 then
			add_w_item(player.x,player.y,player.item_id)
			player.item_id = -1
		end		
	end	
end

function move_player()
	--physics
		if player.dy > 0 then
			player.dy+=gravity * 1.5
		else		
			player.dy+=gravity
		end
  
  player.dx*=friction

  --controls
  if btn(‹) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
  end
  if btn(‘) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
  end

  --slide
  if player.running
  and not btn(‹)
  and not btn(‘)
  and not player.falling
  and not player.jumping then
    player.running=false
    player.sliding=true
  end  
  
  //springs
  local touched_spring = player_on_top_spring()
  if touched_spring > 0	then
  	if springs.t[touched_spring] <= 0 then
  		sfx(sfx_spring)
	  	if player.dy>0 then
	  		player.dy = -player.dy*1.4
	  	else
	  		player.dy = -100
				end				
		  player.landed=false
		  springs.t[touched_spring] = 0.2
			end  	
  else
  	--jump
	  if((btnp(actual_xo_x) and actual_jmp_ctrls == 1)
	  or (btn(”) and actual_jmp_ctrls == 2))
	  and player.landed then
	  		sfx(sfx_jump)
	  		add_par(player.x+2,player.y+8,0.2,0.5,5,6)
					add_par(player.x+2,player.y+8,0.2,0.5,5,5)
	    player.dy-=player.boost
	    player.landed=false
	  end
  end
 	--check collision up and down
  if player.dy>0 then
   player.falling=true
   player.landed=false
   player.jumping=false

   player.dy=limit_speed(player.dy,player.max_dy)

   if collide_map(player,"down",0) then
    player.landed=true
    player.falling=false
    player.dy=0
    player.y-=((player.y+player.h+1)%8)-1
  	end
  elseif player.dy<0 then
   player.jumping=true
   if collide_map(player,"up",0) then
     player.dy=0
   end
  end

  --check collision left and right
  if player.dx<0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"left",0) then
      player.dx=0
    end
  elseif player.dx>0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"right",0) then
      player.dx=0
    end
  end

  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end

  player.x+=player.dx
  player.y+=player.dy
end

function check_for_traps()
	if (collide_map(player,"left",2)
	and not collide_map(player,"left",7))
	or (collide_map(player,"right",2)
	and not collide_map(player,"right",7))
	or (collide_map(player,"down",2)
 and not collide_map(player,"down",7)) then
		player_damage()
	end
end

function player_damage()	
	if time() - time_last_p_damage > time_dmg_blink then
		sfx(sfx_damage)
		add_par(player.x+2,player.y+8,4,0,1,8)
		player_bounce()
		player.health -= 1
		if player.health <= 0 then
			kill()
		end
		time_last_p_damage = time()
	end 	
end

function player_bounce()
	player.dy -=player.boost/2
	player.jumping = true
end

function kill()
	player.alive = false
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

function draw_p_health()
	local str = ""
	for i=1, player.health do
		str = str.."‡"
	end
	
	print(str,8)
end

function player_on_top_mach()
	for i=1, #machines.item_id[cur_lvl] do
		local x = machines.x[cur_lvl][i]-level.x[cur_lvl]
		if x  > (player.x-4)/8
		and x < (player.x+4)/8
		and machines.y[cur_lvl][i]-level.y[cur_lvl] == flr(player.y/8) then
			return i
		end
	end
	return -1
end

function player_on_top_spring()
	if collide_map(player,"left",1)
	or collide_map(player,"right",1)
	or collide_map(player,"down",1) then
		for i=1, #springs.x do
			if  springs.x[i] > (player.x-4)/8
			and springs.x[i] < (player.x+4)/8
			and springs.y[i] == flr(player.y/8) then
				return i
			end
		end
	end 
	
	return -1
end

function player_on_top_box()
	for i=1, #boxes.item_id[cur_lvl] do
		if  boxes.x[cur_lvl][i]-level.x[cur_lvl] > (player.x-4)/8
	 and boxes.x[cur_lvl][i]-level.x[cur_lvl] < (player.x+4)/8 
		and boxes.y[cur_lvl][i]-level.y[cur_lvl] == flr(player.y/8) then
			return i
		end
	end
	return -1
end

function player_on_top_devil()
		return collide_map(player,"left",7)
	or  collide_map(player,"right",7)
end

function player_eat()
	if player.item_id > 0
	and items.p_eat[player.item_id] then
		if player.health < 3 then
			devils.atk_t[cur_lvl] = 0
			player.health += 1
			player.item_id = -1
			sfx(sfx_eat)
		end
	end
end
-->8
--map/level--
level={
	x={  0,  16,  32, 48, 64,   80, 96, 112, 0,16,   32, 48, 64, 80, 96},
	y={  0,   0,   0,  0,  0,    0,  0, 0,  16,16,   16, 16, 16, 16, 16},
px={ 10,  10,  18, 10, 12,   10, 10, 10, 16,10,   10, 10, 10, 10, 10},
py={104, 112, 104,112, 40,  112,112, 112,80,112,  96,96,  104,104,104}
}

cannons={
 x={},
 y={},
 dirx={},
 diry={}
}

springs={
	x={},
 y={},
 active={}
}

cur_lvl=0
cannon_f = 2.5
cannon_t = 0

function draw_map()
	map(level.x[cur_lvl],level.y[cur_lvl],0,0,16,16)
	animate_map()
end

old_blink = false

function get_lvl_title()
	if cur_lvl <= 5 then
		return "salad"
	elseif cur_lvl <= 10 then
		return "entre"
	elseif cur_lvl <= 15 then
		return "main corse" 
	elseif cur_lvl <= 20 then
		return "desert"
	elseif cur_lvl <= 25 then
		return "*hic*"
	end	
end

function animate_map()
	if blink != old_blink then
		local x
		local y
		for x = level.x[cur_lvl], level.x[cur_lvl]+16 do
			for y = level.y[cur_lvl], level.y[cur_lvl]+16 do
				if fget(mget(x,y), 6) then
					mset(x,y, mget(x,y)+2)
				elseif fget(mget(x,y), 5) then
					mset(x,y, mget(x,y)-2)
				end
			end
		end
	end
	
	old_blink = blink	
end

function init_cannons()
	cannons={
	 x={},
	 y={},
	 dirx={},
	 diry={}
	}
	local ctr = 0
	for x = level.x[cur_lvl], level.x[cur_lvl]+15 do
		for y = level.y[cur_lvl], level.y[cur_lvl]+15 do
			if fget(mget(x,y), 4) then
				ctr += 1
				cannons.x[ctr] = x - level.x[cur_lvl]
				cannons.y[ctr] = y - level.y[cur_lvl]
				if mget(x,y) == 59 then
					cannons.dirx[ctr] = -1
				elseif mget(x,y) == 61 then
					cannons.dirx[ctr] = 1
				else
					cannons.dirx[ctr] = 0
				end
				
				if mget(x,y) == 62 then
					cannons.diry[ctr] = 1
				elseif mget(x,y) == 63 then
					cannons.diry[ctr] = -1
				else
					cannons.diry[ctr] = 0
				end				
			end
		end
	end
	
	springs={
		x={},
	 y={},
	 t={}
	}
	ctr = 0
	for x = level.x[cur_lvl], level.x[cur_lvl]+15 do
		for y = level.y[cur_lvl], level.y[cur_lvl]+15 do
			if fget(mget(x,y), 1) then
				ctr+=1
				springs.x[ctr] = x - level.x[cur_lvl]
				springs.y[ctr] = y - level.y[cur_lvl]
				springs.t[ctr] = 0
			end
		end
	end
end

function update_cannons()
	cannon_t -= 1/30
	if cannon_t <= 0 then
		for i = 1, #cannons.x do
			sfx(sfx_weapon)
			add_attack(2,(cannons.x[i]+cannons.dirx[i])*8,(cannons.y[i]+cannons.diry[i])*8,cannons.dirx[i],cannons.diry[i])
		end
		cannon_t = cannon_f
	end	
end

function update_springs()
	for i = 1, #springs.x do
		if springs.t[i] > 0 then
			mset(springs.x[i]+level.x[cur_lvl], springs.y[i]+level.y[cur_lvl], 56)
			springs.t[i] -= 1/30
		else
			mset(springs.x[i]+level.x[cur_lvl], springs.y[i]+level.y[cur_lvl], 55)
		end
	end
end

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down

 local x=obj.x+level.x[cur_lvl] * 8
 local y=obj.y+level.y[cur_lvl] * 8
 local w=obj.w											 
 local h=obj.h

 local x1=0	 local y1=0
 local x2=0  local y2=0

 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

 elseif aim=="right" then
   x1=x+w-1    y1=y
   x2=x+w  y2=y+h-1

 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y

 elseif aim=="down" then
   x1=x+2      y1=y+h
   x2=x+w-3    y2=y+h
 end

 --pixels to tiles
 x1/=8    y1/=8
 x2/=8    y2/=8

 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
 end
end
-->8
--utils--
max_debug=4
_debug_log={
	"","","","","","","","","",""
}

function round_2_floats(float)
	return flr(float*100)/100
end

//each obj needs x,y,w,h (pos + dimension)
function collides(obj1, obj2)
	if (obj1.x < obj2.x + obj2.w ) and
				(obj1.x + obj1.w > obj2.x) and
			 (obj1.y < obj2.y + obj2.h) and
				(obj1.y + obj1.h > obj2.y) then
		return true
	else
		return false
	end
end

function debug_col(obj)
	return "x:"..obj.x.." y:"..obj.y.." w:"..obj.w.." h: "..obj.h
end

function debug(txt)
	if txt != sub(_debug_log[1],0,#_debug_log[1]-3) then
		for i=10, 2, -1 do
			_debug_log[i] = _debug_log[i-1]
		end
		_debug_log[1] = txt.." x"..1
	else
		_int = sub(_debug_log[1],#_debug_log[1],#_debug_log[1])+0
		if _int < 5 then
			_debug_log[1] = sub(_debug_log[1],0,#_debug_log[1]-1)..(_int+1)
		else
			_debug_log[1] = sub(_debug_log[1],0,#_debug_log[1]-2)..">5"
		end		
	end
end

function draw_debug()
	for i=1, 10 do
		print(_debug_log[i], 2, 128-(1+i)*7, 7)
	end
end

--print in center--
function print_center(s, y, col)
		if col == nil then
  	col = 7
  end
  
  print(s, 64-#s*2,y, col)
end

function vcenter(s)
  return 61
end

function draw_window_centered(width, height, col1, col_frame, y, col_low)
	
	local x1 = (128-width)/2 
	
	local y1					
	
	if y == nil then
		y1=(128-height)/2
	else
		y1=y
	end
	
	draw_window(x1, y1, width, height, col1, col_frame, col_low)
end

function draw_window(x1, y1, width, height, col1, col_frame, col_low)
	if col_frame == nill then col_frame = 7 end
	if col1 == nill then col1 = 0 end
	
	local x2 = x1+width	
	local y2=y1+height 
	
	rectfill(x1+1, y1, x2-1, y1, col_frame)
	if col_low != nil then
		col_frame = col_low
	end
	rectfill(x1+1, y2, x2-1, y2, col_frame)
	
	rectfill(x1, y1+1, x2, y2-1, col1)
end

-->8
--kitchen machinery--
boxes={
	x={
		{10},
		{30, 17},
		{33,46, 44},
		{59},
		{78,76},
		--
		{89,93},
		{98,109},
		{125},
		{1,5},
		{17,19},
		--
		{45},
		{50,53},
		{66,76},
		{93},
		{97,97,99}},
	y={
		{14},
		{14,  3},
		{13,13,2},
		{12},
		{5,5},
		--
		{2,3},
		{14,3},
		{3},
		{19,26},
		{30,30},
		--
		{18},
		{28,26},
		{29,29},
		{24},
		{29,26,24}},
	item_id={
		{ 9},
		{ 7, 3},
		{ 11, 9,7},
		{ 7},
		{ 9, 3},
		--
		{12,14},
		{12,14},
		{3},
		{3,12},
		{7,14},
		--
		{1},
		{1,3},
		{14,3},
		{14},
		{1,3,14}}
}

machines={
	x={},
	y={},
	typ={},
	item_id={},
	proc_dt={},
	num={}	
}

machine_types={
	proc_t={2,2,2,1,1}
}

function init_machines()
	machines={
		x={
			{ 7},					
			{29,24},
			{36},
			{52},
			{71,73},
			--
			{82,84},
			{101,103},
			{114,116},
			{11,13},
			{19},
			--
			{40},
			{56,59,61},
			{68,72},
			{89},
		 {102,106,110}},
		y={
			{11},
			{11, 9},
			{4},
			{2},
			{13,13},
			--
			{14,14},
			{6,6},
			{4,6},
			{19,19},
			{26},
			--
			{22},
			{25,27,24},
			{25,25},
			{19},
			{29,29,24}},
		// 0 = oven, 1 = boil, 2 = fri 3 = cut, 4 = toaster
		typ={
			{3},
			{3, 1},
			{3},
			{3},
			{1, 3},
			--
			{4, 3},
			{4, 3},
			{3,2},
			{1,4},
			{3},
			--
			{0},
			{3,0,2},
			{1,0},
			{0},
			{0,3,2}},
		item_id={
			{-1},
			{-1,-1},
			{-1},
			{-1},
			{-1,-1},
			--
			{-1,-1},
			{-1,-1},
			{-1,-1},
			{-1,-1},
			{-1},
			--
			{-1},
			{-1,-1,-1},
			{-1,-1},
			{-1},
			{-1,-1,-1}},
		proc_dt={
			{0},
			{0, 0},
			{0},
			{0},
			{0,0},
			--
			{0,0},
			{0,0},
			{0,0},
			{0,0},
			{0},
			--
			{0},
			{0,0,0},
			{0,0},
			{0},
			{0,0,0}}
	}
	
	machines_sfx = 0
end

function draw_kitchen()
	draw_boxes()
	draw_machines()
end

function draw_boxes()
	for i=1, #boxes.item_id[cur_lvl] do
		spr(items.img[boxes.item_id[cur_lvl][i]],(boxes.x[cur_lvl][i]-level.x[cur_lvl])*8, (boxes.y[cur_lvl][i]-level.y[cur_lvl])*8)
	end
end

function draw_machines()
	for i=1, #machines.item_id[cur_lvl] do
		if machines.item_id[cur_lvl][i] >= 0 then
			local x = (machines.x[cur_lvl][i]-level.x[cur_lvl])*8
			local y = (machines.y[cur_lvl][i]-level.y[cur_lvl])*8		
			spr(items.img[machines.item_id[cur_lvl][i]],x,y)
			//draw progress bar
			if machines.proc_dt[cur_lvl][i] > 0 then
				rectfill(x,y-4,x+(1-machines.proc_dt[cur_lvl][i]/machine_types.proc_t[machines.typ[cur_lvl][i]+1])* 8, y-2, 11)	
			end	
		end
	end
end

function machine_can_process(machine_typ, item_id)
	//0 = oven
	if machine_typ == 0 then
		return items.oven[item_id] > 0
	end
	//1 = boil
	if machine_typ == 1 then
		return items.boil[item_id] > 0
	end
	//2 = fry
	if machine_typ == 2 then
		return items.fry[item_id] > 0
	end
	//3 = cut
	if machine_typ == 3 then
		return items.cut[item_id] > 0
	end
	//4 = toaster
	if machine_typ == 4 then
		return items.toast[item_id] > 0
	end
	return false
end

function machine_start(machine_typ, item_id)
	if machine_typ == 0 then
		sfx(sfx_oven,2)
		machines_sfx+=1
	end
	
	if machine_typ == 1 or machine_typ == 2 then
		sfx(sfx_boil,2)
		machines_sfx+=1
	end
	
	if machine_typ == 3 then
		sfx(sfx_cutting,2)
		machines_sfx+=1
	end
	
	if machine_typ == 4 then
		sfx(sfx_toaster,2)
		machines_sfx+=1
	end	
	
end

function get_process_result(machine_typ, item_id)
	//0 = oven
	if machine_typ == 0 then
		return items.oven[item_id]
	end
	//1 = boil
	if machine_typ == 1 then
		return items.boil[item_id]
	end
	//2 = fry
	if machine_typ == 2 then
		return items.fry[item_id]
	end
	//3 = cut
	if machine_typ == 3 then
		return items.cut[item_id]
	end
	
	//4 = toast
	if machine_typ == 4 then
		return items.toast[item_id]
	end
	
	debug("error get_process_result: -> nil!")
	return nil
end

function start_machine(id)
	actual_machines.proc_dt[id] = actual_machines.proc_t[id]
end

function update_machines()
	if machines_sfx <= 0 then
		sfx(-1,2)
	end

	for i=1,#machines.item_id[cur_lvl] do
		if machines.item_id[cur_lvl][i] > 0 then
			if machines.proc_dt[cur_lvl][i] - 1/30 > 0 then
				machines.proc_dt[cur_lvl][i] -= 1/30				
			else
				if machines.proc_dt[cur_lvl][i] > 0 then
					machines_sfx-=1
					sfx(sfx_ready)
					machines.proc_dt[cur_lvl][i] = 0
					machines.item_id[cur_lvl][i] = get_process_result(machines.typ[cur_lvl][i],machines.item_id[cur_lvl][i])
				end
			end
		end
	end 
end

-->8
--item--
items={
	// 1 = raw chicken
	// 2 = cooked chicken
	// 3 = raw patato
	// 4 = cooked patato
	// 5 = cut patato
	// 6 = fries
	// 7 = tomato
	// 8 = cut tomato
	// 9 = salad
	//10 = cut salad
	//11 = cucumber
	//12 = bread
	//13 = toast
	//14 = steak raw
	//15 = tartare
	//16 = steak
	id		 = {1 ,      2,    3,   4,    5,   6,   7,   8,    9,  10,  11,   12,  13,   14,  15,  16},
	img		=	{65,	    66,   67,  68,   69,  70,  71,  72,   73,  74,  75,   76,  77,   78,  79,  80},
	oven = { 2,      0,	   0,   0,    0,   0,   0,   0,    0,   0,   0,    0,   0,   16,   0,   0},
	boil	= { 0,      0,    4,   0,    0,   0,   0,   0,    0,   0,   0,    0,   0,    0,   0,   0},
	cut  = { 0,      0,    5,   0,    0,   0,   8,   0,   10,   0,   0,    0,   0,   15,   0,   0},
	fry  = { 0,      0,    0,   0,    6,   0,   0,   0,    0,   0,   0,    0,   0,    0,   0,   0},
	toast= { 0,      0,    0,   0,    0,   0,   0,   0,    0,   0,   0,   13,   0,    0,   0,   0},
	p_eat= {false,true,false,true,false,true,true,true,false,true,true,false,true,false,true,true}
}

world_item={
	x={},
	y={},
	w={},
	h={},
	id={}
}

item_buf_size = 10
act_w_item = 1

function init_world_items()
	for i=1, item_buf_size do
		world_item.x[i]=0
		world_item.y[i]=0
		world_item.w[i]=6
		world_item.h[i]=4
		world_item.id[i]=0
	end
end

function add_w_item(x,y,id)
	world_item.x[act_w_item]=x
	world_item.y[act_w_item]=y
	world_item.id[act_w_item]=id
	act_w_item += 1
	if act_w_item > item_buf_size then
		act_w_item = 1
	end
end

function draw_items()
	for i=1, item_buf_size do
		if world_item.id[i] > 0 then
			spr(items.img[world_item.id[i]],
				world_item.x[i],
				world_item.y[i]
			)
		end
	end
end

function player_on_top_of_item()
	for i=1, item_buf_size do
		if world_item.id[i] > 0 
		and collides(
			player,
			{x=world_item.x[i],
				y=world_item.y[i],
				w=world_item.w[i],
				h=world_item.h[i],
			}) then
			return i
		end
	end
	return -1
end

function update_items()
	//bounce?
end
-->8
--devil--

devil_pos={
 x = 0,
 y = 0
}

attacks={
	ani={},
	x  ={},
	y  ={},
	dx ={},
	dy ={},
	attack_buffer_size = 40,
	attack_index = 1
}

last_sec = 0

function init_devil()
	devils={
		item_id={
		{10},
		{8,4},
		{11,8,10},
		{8},
		{10,4},
		--
		{13,15},
		{15,13},
		{6},
		{13,4},
		{8,15},
		--
		{2},
		{2,6},
		{16,4},
		{16},
		{16,6,2}},
		hunger={
		{2},
		{2,2},
		{1,2,2},
		{1},
		{2,2},
		--
		{2,2},
		{1,1},
		{2},
		{2,2},
		{2,2},
		--
		{2},
		{2,2},
		{2,1},
		{2},
		{1,1,1}},
		atk_t={12,15,15,17,20 ,20,20,15,15,15,  10,15,15,15,15},
		atk_f={12,15,15,17,20 ,20,20,15,15,15,  10,15,15,15,15},
		atk_ids={
		{1},
		{1,2},
		{2},
		{2,3},
		{1,3},
		--
		{1,2,3},
		{1,2,3},
		{2,3},
		{2,3},
		{2,3},
		--
		{1},
		{2,3},
		{3},
		{1,2,3},
		{1,2}},
		atk_targeted={false,false,true,false,true,   false,false,false,false,true,  true,false,true,false,true}
	}
	
	for i = 1, attacks.attack_buffer_size do
		attacks.ani[i] = 0
		attacks.x[i] = 0
		attacks.y[i] = 0
		attacks.dx[i] = 0
		attacks.dy[i] = 0
	end
	attacks.attack_index = 1
end

function get_actual_devilpos()
	enemies={
		x={},
		y={},
		orx={},
		ory={},
		dx={}
	}
	devil_found = false
	for x = level.x[cur_lvl], level.x[cur_lvl]+15 do
		for y = level.y[cur_lvl], level.y[cur_lvl]+15 do
			init_enemeys(x,y)
			if fget(mget(x,y),7) 
			and not devil_found 
			and not fget(mget(x,y),2) then
				devil_pos.x = 8*(x - level.x[cur_lvl])
				devil_pos.y = 8*(y - level.y[cur_lvl])
				devil_found = true
			end
		end
	end
	if not devil_found then
		debug("err: lvl:"..cur_lvl.."-no devil found!")
	end
end

function draw_devil_ui()
	if devil_pos.x == -1 then
		get_actual_devilpos()
	end
	local _cursor = 0
	for i=1, #devils.item_id[cur_lvl] do
		if devils.hunger[cur_lvl][i] > 0 then
			_cursor+=1
			spr(items.img[devils.item_id[cur_lvl][i]], 128-(_cursor-1)*20-10, -2)
			print(devils.hunger[cur_lvl][i].."x", 128-(_cursor-1)*20-18, 0, 7)
		end		
	end
	
	if devils.atk_t[cur_lvl] <= 4 then
		sec = flr(devils.atk_t[cur_lvl])
		if sec != last_sec then sfx(sfx_warn_atk) end
  if blink then
  	spr(96,devil_pos.x+4,devil_pos.y-8)
  end
		last_sec = sec
	else
		sec = 0
	end
	
	
end

function devil_eat(item_id)
	for i=1, #devils.item_id[cur_lvl] do
		if devils.item_id[cur_lvl][i]==item_id 
		and devils.hunger[cur_lvl][i] > 0 then
			devils.hunger[cur_lvl][i] -= 1
			devils.atk_t[cur_lvl] = devils.atk_f[cur_lvl] 
			add_par(devil_pos.x+8,devil_pos.y+4,0.3,1,4,4)
			sfx(sfx_delivered)
			return true
		end
	end	
	return false
end

function check_end()
	for i=1, #devils.item_id[cur_lvl] do
		if devils.hunger[cur_lvl][i] > 0 then
			return false
		end 
	end
	
	return true
end

function add_attack(ani,x,y,dx,dy)
	attacks.ani[attacks.attack_index] = ani
	attacks.x[attacks.attack_index] = x
	attacks.y[attacks.attack_index] = y
	attacks.dx[attacks.attack_index] = dx
	attacks.dy[attacks.attack_index] = dy
	
	attacks.attack_index+=1
	if attacks.attack_index > attacks.attack_buffer_size then
		attacks.attack_index = 1
	end
end

function update_attacks()
	devils.atk_t[cur_lvl] -= 1/30
	
	if devils.atk_t[cur_lvl] <= 0 then
		index = flr(rnd()*#devils.atk_ids[cur_lvl])+1		
		
		devils.atk_t[cur_lvl] = devils.atk_f[cur_lvl] 
		if devils.atk_targeted[cur_lvl] then
			local dx = player.x - devil_pos.x
			local dy = player.y - devil_pos.y
			
			local len = sqrt(dx*dx+dy*dy)
			dx /= len
			dy /= len		
			
			add_attack(index,devil_pos.x,devil_pos.y,dx,dy)
		else
			local x = 1
			local y = 1
			
			if player.x < devil_pos.x then
				add_attack(index,devil_pos.x,devil_pos.y,-1,0)
			else
				x *= -1
				add_attack(index,devil_pos.x,devil_pos.y,1,0)
			end
			
			if player.y < devil_pos.y then
				add_attack(index,devil_pos.x,devil_pos.y,0,-1)
			else
				y *= -1
				add_attack(index,devil_pos.x,devil_pos.y,0,1)
			end	
			
			add_attack(index,devil_pos.x,devil_pos.y,y,x)		
		end	
		devils.atk_f[cur_lvl] -= 1
		if devils.atk_t[cur_lvl] < 5 then
			devils.atk_f[cur_lvl] = 5
		end
	end
	
	for i = 1, attacks.attack_buffer_size do
		if attacks.ani[i] > 0 then
			attacks.x[i] += attacks.dx[i]
			attacks.y[i] += attacks.dy[i]
		
			if collides(player, {x=attacks.x[i],y=attacks.y[i],w=7,h=7}) then
				player_damage()
				attacks.ani[i] = 0
			end		
		
			if attacks.x[i] < -8
			or attacks.x[i] > 16*8 
			or attacks.y[i] < -8
			or attacks.y[i] > 16*8 then 
				attacks.ani[i] = 0
			end
		end
	end
end

function draw_attacks()
	for i = 1, attacks.attack_buffer_size do
		if attacks.ani[i] > 0 then
			animate(attacks.ani[i],attacks.x[i],attacks.y[i])
		end
	end
end
-->8
--particle system--
particle={
	x={},
	y={},
id={},
 t={},
dx={},
dy={},
col={} 
}

cur_particle = 1

num_of_particles = 20

function init_particles()
	for i=1, num_of_particles do
		particle.x[i] = 0
		particle.y[i] = 0
		particle.id[i] = 0
		particle.t[i] = 0
		particle.dx[i] = 0
		particle.dy[i] = 0
		particle.col[i]=0
	end
end

function update_particles()
	local act_col=7
	for i=1, num_of_particles do
		if particle.t[i] > 0 then
			particle.t[i]-= 1/30
			particle.x[i]+=particle.dx[i]
			particle.y[i]+=particle.dy[i]
			if act_col != particle.col[i] then
				pal()				
				pal(7,particle.col[i])
				act_col=particle.col[i]							
			end			
			draw_sub(2, particle.id[i], particle.x[i], particle.y[i])
		end
	end
	pal()
end

function add_par(x,y,t,v,num,col)
	if num == nil then
		num = 1
	end
	
	if v==nil then
		v=1
	end
	
	if col==nil then
		col=7
	end
	
	for i=1, num do
		particle.x[cur_particle]=x
		particle.y[cur_particle]=y
		particle.t[cur_particle]=t
		particle.id[cur_particle]=flr(rnd()*4)
		local dx=rnd()*(2)-1
		local dy=rnd()*(2)-1
		len = sqrt(dx*dx+dy*dy)
		particle.dx[cur_particle]=dx/len*v
		particle.dy[cur_particle]=dy/len*v
		particle.col[cur_particle]=col
		cur_particle+=1
		if cur_particle > num_of_particles then
			cur_particle = 1
		end
	end
end

function pov(a,b)
	r = 1
	for i=1, b do
		r*=a
	end
	return a;
end

function draw_sub(sprite, num, x, y)
	local page =sprite/64 - sprite%64/64
	local o_x = sprite%64%16*8
	local o_y = 8*(sprite/16)
	if(num==1)then
		o_x+=4		
	end
	if(num==2)then	
		o_y+=4	
	end
	if(num==3)then
		o_x+=4	
		o_y+=4	
	end
	sspr(
		o_x,
		o_y,
		4,
		4,
	 x,
	 y
	)
end
-->8
--sounds--
sfx_ready					= 0
sfx_damage 			= 1
sfx_jump 					= 2
sfx_oven						= 3
sfx_boil   			= 4
sfx_delivered = 5
sfx_ui_select = 6
sfx_ui_switch = 7
sfx_cutting   = 8
sfx_warn_atk  = 9
sfx_toaster			=10
sfx_weapon    =11
sfx_spring				=12
sfx_eat       =13
-->8
--animations--
animations={
	//id={1,2,3,4},
	frames={
		{112,113,114,115,112,113,114,115},
		{116,117},
		{118,119,120,121,118,119,120,121},
		{16,17}
	},
	flpx={
		{false,false,false,false,false,true,true,true},
		{false,false},
		{false,false,false,false,false,true,true,true},
		{false,false}
	}, 
	flpy={
		{false,false,false,false,true,true,false,true},
		{false,false},
		{false,false,false,false,true,true,false,true},
		{false,false}
	},
	frame={1,1,1,1},
	spd  ={2,5,2,5}
}

lasttime_100ms = 0

function animate(ani, x, y)
	spr(
		animations.frames[ani][animations.frame[ani]],
		x,
		y,
		1,
		1,
		animations.flpx[ani][animations.frame[ani]],
		animations.flpy[ani][animations.frame[ani]])
end

function update_ani()
	if flr(time()*100) != lasttime_100ms then
		for i=1, #animations.frames do
			if(flr(time()*100)) % animations.spd[i] == 0 then
				animations.frame[i] += 1
				if animations.frame[i] > #animations.frames[i] then
					animations.frame[i] = 1
				end 
			end
		end
	end	
	
	lasttime_100ms = flr(time()*100)
end
-->8
--highscores and save data--
level_save_data_adr = 0
//adr level_times = 1 - 50
level_t={
	normal			={},
	speedrun ={}
}
jmp_ctrl_save_data_adr = 51
xo_ctrl_save_data_adr = 52

function load_level_time_data()
	
	for i=1, 25 do
		local temp = (i-1)*2+1
		level_t.normal[i] = dget(temp)
		level_t.speedrun[i] = dget(temp+1)
	end
end

function save_level_time_data(level, t)
	local temp = (level-1)*2+1
	if speedrun_mode then
		if dget(temp+1) > t or dget(temp+1) == 0 then
			level_t.speedrun[level] = t
			dset(temp+1,t)
		end
	else
		if dget(temp) > t or dget(temp+1) == 0 then
			level_t.normal[level] = t
			dset(temp,t)
		end
	end	
end
-->8
--enemies--
enemies={
	x={},
	y={},
	orx={},
	ory={},
	dx={}
}

function init_enemeys(x,y)	
	if fget(mget(x,y),7) and fget(mget(x,y),2) then
		enemies.x[#enemies.x+1] = 8*(x - level.x[cur_lvl])
		enemies.y[#enemies.x] = 8*(y - level.y[cur_lvl])
		enemies.dx[#enemies.x]= 1
		enemies.orx[#enemies.x]=8*(x - level.x[cur_lvl])
		enemies.ory[#enemies.x]=8*(y - level.y[cur_lvl])
	end
end

function update_enemies()
	for i = 1, #enemies.x do
		local temp={x,y,w,h}
		temp.x = enemies.x[i]
		temp.y = enemies.y[i]
		temp.w = 4
		temp.h = 8
		if collide_map(temp,"right",0)
		or collide_map(temp,"left",0) then
			enemies.dx[i] *= -1
		end		
		enemies.x[i]+=enemies.dx[i]
		if collides(temp, player) then
			player_damage()
		end		
	end
end

function draw_enemies()
	for i = 1, #enemies.x do
		rectfill(
		enemies.orx[i],
		enemies.ory[i],
		enemies.orx[i]+7,
		enemies.ory[i]+7,
		0)
		animate(4, enemies.x[i], enemies.y[i])
	end
end
__gfx__
00000000777777770700000000000000000000000000000000000000000000002000000244444444444444444444444444444444444444444444444444444444
00000000067777607770007700000000000000000000000000000000000000002000000200000000200000000000000220000000000000022000000200000000
007007000b6666b00700077700000000000000000000000000000000000000002000000204440040244400400444004224440040044400422444004204440040
000770000bbbbbb00000000000000000000000000000000000000000000000002000020200000000200000000000000220000000000000022000000200000000
000770000b9bb9b00000000000000000000000000000000000000000000000002000000200000000200000000000000220000000000000022000000200000000
007007000bb33bb07700007000000000000000000000000000000000000000002022000200004000200040000000400220004000000040022000400200004000
000000000bbbbbb07770077700000000000000000000000000000000000000002000000200000000200000000000000220000000000000022000000200000000
00000000003333000700077000000000000000000000000000000000000000000222222000000000200000000000000202222222222222200222222022222222
00000000000000000000000000000000000000000000000000000000000000000000000000000002000000002000000000000002200000002000000244444444
00000000200200000000000000000000000000000000000000000000000000000000000000000002022000002020000000002202200000002000000220000002
20020000922900000000000000000000000000000000000000000000000000000000000000000002000000002000000000000002202000002020000224440042
92290000288200000000000000000000000000000000000000000000000000000000000000000202000000002000000000000002200000002000000220000002
28820000222200000000000000000000000000000000000000000000000000000000000000220002000000202000000000000002200000002000020220000002
22220000022000000000000000000000000000000000000000000000000000000000000000000002000000002000000000000002200000202000200220004002
02200000022000000000000000000000000000000000000000000000000000000000000000000002000000002000022020000002200000002000000220000002
e00e00000ee000000000000000000000000000000000000000000000000000000000000022222220222222222000000000000002022222222000000220000002
00000000000000000000000000000000000000000000000000000000000000000000000000000000066666600006600000066000000000000000000000000000
00800000000008000000000000000000000000000000000000000000000000000000000009999990509999056666666666666666000000000000000000000000
00800000000008000000000000000000000000000000000000000000000000000000000040000004500000050500005005000050000000000077770000000000
00088eeeeee8800000800000000008000000000000000000000000000000000000000000400000045000000505c7cc5005f7ff50006666440755557000000000
00000e8888e0000070788eeeeee880000000000000000000000000000000000000000000400000045000000505cccc5005ffff50077777000777777000000000
7070e8a88a8e000066600e8888e000000000000000000000000000000000000000000000400000045666666505cc7c5005ff7f50099999900766667000000000
66608888888800700600e8a88a8e00700000000000000000000000000000000000000000200000025099990505cccc5005ffff50004004000666696000000000
06008872278800700600888888880070000000000000000000000000000000000000000002222220555555550566665005666650004004000655556000000000
06008888888800600600887227880060000000000000000000000000000000000000000006006006000000002002000200000000200200022222222244500644
06008888888800600220882222880060000000000000000000000000099999900000000066066066888800882000200288008888200020020204400000056000
02200888888002200002088888800220000000000000000000000000000660000000000066066066888888886200044288888888244000060044440004456040
99999999999999999999999999999999000000000000000000000000006006000999999066065066889888980666644288888888244666600044440000056000
00400422224004000040042222400400000000000000000000000000060000600066660035066063888888880555544288988898244555500005602000444400
00404022220404000040402222040400000000000000000000000000006006006600006633333335888888885200044288888888244000050005600000444400
00440022220044000044002222004400000000000000000000000000000660000066660055355535898888882022000288888888202200020005600000044000
00400012210004000040001221000400000000000000000000000000222222222222222233335533888888882000000289888888200000022250062222222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000700000007000aaaa0000999900000a000000090000000000000022222000bbbb00000000000000000000000000000000000000000000006000
0000000000eee770004447700aaaa9a0099444900a0a00a009090090008bb8000022e2200b3bb3b000bb0b000000b30000aaaa00009999000eee000007060700
000000000eee8070044420700a9aaa90094494900a0a00a0090900900888b8800888880003b33b30033bbbb0000b32000a9999a0094242900888e00007e88700
0777777008e800000242000009aaaa90094444900a0a0090090900f008888880088788000bb3b3307633bb6700b32000009999000024420002788e000788e700
7666666700800000002000000099990000222200090900000f0f0000008888000088800000333300077777700032000000999900002442000022200000777000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0444f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02744f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a99a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a9779a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a9779a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a999999a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a997799a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00556000000055000000000007000000000000000088880000550000000007000070700007550000000000000000000000000000000000000000000000000000
050060000005006000000050706000000088880008aaa98005000000000007700007050077005000000000000000000000000000000000000000000000000000
0000600000000600000000055660000008a9a9808aa999a870000070050070050007005000700000000000000000000000000000000000000000000000000000
0000600000006000766000055006005008a779808a9779a807777700500700055007005000070000000000000000000000000000000000000000000000000000
0000600000060000006666660500600508a799a08a97999870000070507000505007000000007000000000000000000000000000000000000000000000000000
0006660506600000766000000000060508a99a80899999a800000500770000000507000000000770000000000000000000000000000000000000000000000000
000606057060500050000000000000600088a80008aa9a8000055000070000000070700000500700000000000000000000000000000000000000000000000000
00070750075500000550000000000000000000000088880000000000000000000000000000055000000000000000000000000000000000000000000000000000
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
09999999000000999999990099000000990007070000990009900000099900000000000000000000000000000000000000000000000000000000000000000000
08888888900000888888800088000000880006660000880000890000988890000000000000000000000000000000000000000000000000000000000000000000
08800000890000880000000088000000880000600000880000880009800089000000000000000000000000000000000000000000000000000000000000000000
08800000089000880000000088000000880000600000880000000098000008900000000000000000000000000000000000000000000000000000000000000000
08800000088900880000000088000000880000600000880000000088000000800000000000000000000000000000000000000000000000000000000000000000
08800000008800880000000088000000880000600000880000000088000000000000000000000000000000000000000000000000000000000000000000000000
08800000008800880000000088000000880009400000880000000088900000000000000000000000000000000000000000000000000000000000000000000000
08800000008800889990000088000000880004440000880000000008800000000000000000000000000000000000000000000000000000000000000000000000
08800000008800888880000088900009880004440000880000000000899000000000000000000000000000000000000000000000000000000000000000000000
08800000008800880000000008800008800000420000880000000000088999000000000000000000000000000000000000000000000000000000000000000000
08800000008800880000000008800008800000600000880000000000000888000000000000000000000000000000000000000000000000000000000000000000
08800000008800880000000008800008800000600000880000000000000008900000000000000000000000000000000000000000000000000000000000000000
08800000088000880000000008890098800000600000880000000090000008800000000000000000000000000000000000000000000000000000000000000000
08800000880000880000000000889988000000600000880000000089000008800000000000000000000000000000000000000000000000000000000000000000
08899999800000889999900000088880000006660000889999999008999998000000000000000000000000000000000000000000000000000000000000000000
08888888000000888888880000008800000005050000888888888000888880000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0f0f0f0f0d0000000002400000000000c1c2c3c4c5c6c7c8c0000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000021200c0d000000000000d1d2d3d4d5d6d7d8d0000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000031300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a090909090b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000a09090909090909090b000d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90909090909090909090909090909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000800000000010101010101010184840200000000000001010101010101c0c0a0a0000000000008080808080800c0c0a0a000000002020545112511111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a001a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a0000001a1a1a1a1a1a1a1a1a1a1a00000000001a1a1a1a1a1a1a1a1a1a1a1a1a0000001a1a1a1a1a1a1a1a1a1a1a1a1a0000001a1a1a1a1a1a1a1a1a1a1a1a1a0000
1c00000000000000000000000000001b1c00000000000000000000000000001b1c0000000000000000001e000000001b1c000000000000000000000000001b001c00000000000000000000001d0000001c000000000000000000000000001b001c000000000000000000000000001b001c000000000000000000000000001b00
1c00000000000000000000000000001b1c00000000000000000000000039391b1c0000000000000000001e002900001b1c0000002d0000000000000000001d001c0000000000000000000000001d1a001c000000000000000029000000001d001c000000000000000000000000001d001c000000000000000000000000001d00
1c00000000000000000000002021001b1c290000000000000c090d00000c0f001c000000000000000c0f1a0f0d00001b1c00000c090b000a0f0f0f0b0000001b1c00000000000a0b001f00000000001b1c00000c0f0f0f0f0f0f0f0d0029001b1c00000000000000000000000029001b1c00000000000000000000000029001b
1c00000000000000000000003031001b1c0d000000000000001e00202100001b1c0000002d000000000000000000001b1c0000001d1c391e000000080000001b1c000000000c1a1c391e00000000001b1c00000000000000000000000c0d001b1c00000000000c3f0f3f0f0f0f0f0f1b1c002d0000000c3f0f3f0f0f0f0f0f1b
1c0000000000000000000a090f0f0f1b1c00000000000000001e00303100001b000f0f0f0b0000000000000000000a001c000000001d1a19000000000a0d001b1c0000000000001d1a1a0f0b2900291b00090909090f3f0f0f0b00000000001b1c00000000000000000000000000001b1c000e0000000000000000000000001b
1c0000000000000000001b1c0000001b003a3a090b00000c0f0f0f0f0f0f0f1b1c0000001b0b002021001f00000a00001c00000000000000000000001e00001b000f0d00000000000000001d0f0f0f1b001a1a1a19000000001d0b000000001b1c000000002e002d000000000000001b1c0000002c000000000000000000001b
1c00000000001f00000a001c0000001b1c1a1a1a19000000000000000000001b00090909001c0030310a1900001b00000009090b00000000000c0b001e00001b1c00000000000000000000000000001b1c0000000000000000001d0b0000001b000d0000000a0f0d000000000000001b000d00000e000020210000000000001b
1c00000000001e39391b001c0000001b1c00000000000000000000000000001b001a1a0000000909091c0000001b00000000001c000000000e001e0008000c001c00000000000000000000000000001b1c000000000000000000001d0d00001b1c000000003b0000000000000000001b1c00000000000030310000000000001b
1c00000c0f0f1a1a1a1a1a1c0000001b1c000000000e00002b0000000000001b1c00001b00000000001c00000c1a1a000000001c000e000000001e000000001b1c000000001f000011001f000000001b1c000000001f00001f0000000000001b1c000000001e00000e0000000000001b1c000000000a090909090d000000001b
1c000000000000000000001e0000001b1c000000000000001f0000000000001b1c00001d1a1a1a1a1a1900000000001b0000001c0000000000001e000000001b1c0000000c1a0f0f0f0f1c000000001b1c0000000c1c39391d0f0f0f0f0d001b3d0000000a190000000000000000001b1c0f0f0f3e1a3e1a3e1900000000001b
1c0e00000000002d0000001e0000001b1c000000000000001e000000002d001b1c00000000000000000000000000001b0000001c0000000000001e00000e001b1c0000000000000000001e000000001b1c000000001d1a19000000000000001b1c0000001e00000000000e000000001b1c0000000000000000000000000e001b
1c000000000c0f0f0d00001e0000001b1c0000000000000c1c0000000c0f0f001c0000000000000000000e000000001b001a1a190000000e00001e290000001b1c000e000000000000001b0d0000001b1c00000e00000000000000002021001b000d00001e000000000000002021001b1c00000000000000000000000000001b
1c000000000000000000001e0000001b1c000000000000001b0d00000000001b1c29000000000000000000000000291b1c0020210000000000001d0d0000001b1c0000000000002b002d1e002021001b1c00000000000000000000003031001b1c0000003b000000000000003031001b1c00000000000000000000000e00001b
1c0909090b0000001f00291e0000001b1c000000000000001e0000000000291b0009090b00000a090909090b000a09001c00303100000000000000000000001b1c0000000a0b000a09091c003031001b1c002e002d00000a0b00000a090909001c0029001e00000a0b00000a090909001c0000000000000000001f000000001b
1c0000001c3a3a3a1b0909000909091b1c0909093a3a0909090939090909091b0000001c3a3a1b000000001c391b00000009090909093a3a3a3a3a3a3a3a3a1b1c3a3a3a1b1c391b000000090909090000090909090909001c3a3a1b00000000000909091c39391b1c3a3a1b00000000000909090909090909091c3a3a3a3a1b
001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a1a00001a1a1a1a1a1a1a1a1a1a1a1a1a1a000000001a1a1a1a1a1a1a1a1a1a1a1a0000000000000000000000000000000000
1c00000000000000000000000000001b1c00000000000000000000000000001b1c00000000000000000000000000001b1c00000000000000000020210000001b1c00000000000000000000000000001b1c00000000000000000000000000001b0000190000000000000000000000001b00000000000000000000000000000000
1c00000000000000000000000000001b1c00000000000000000000000000001b1c00000000000000000000000029001b1c00000000000000000030310000001b3d00000000002021000000000000001b1c00000000000000000000000000001b0019000000000000000000001f00001b00000000000000000000000000000000
1c290000000000000000002b002e001b1c0000000000000000001f000000001b1c00000000000000000000000c0f0f1b1c3a3a3a1f000000000c0f0f0d00001b1c00000000003031000000000000001b1c00000000000000002a00000000001b1c00000000000000000000001e3a3a1b00000000000000000000000000000000
000d00000000000000000c0f0f0f0f001c0000000c0b000000001e000000391b1c00000000000e0000000e000000001b3d1a1a1a19000000000000000000001b1c000000000c0f0f0f0f0b000000001b1c00000000001f00000e00001f00001b1c00000000000000000000001d1a1a1b00000000000000000000000000000000
1c00000000001f00000000000000001b1c000000001e000000001e0000000c001c00000e00000000000000000000001b1c00000000000000000000000000001b1c00000e0000000000001b0d0000001b1c000000000a1c3a3a3a3a3a1e00001b1c0000001f000000000000000000001b00000000000000000000000000000000
1c00000000001e00000000000000001b1c000000001b0d0000001e000000001b1c000000000000002a0000000000001b1c00000000000000000000000000001b1c0000000000000000001e000000001b1c00000c3f1a1a1a1a1a1a1a1900001b000d00001e000000000000000000001b00000000000000000000000000000000
1c00000000001e00000000000000001b1c000000001e000000371e000000001b1c000000000000000e0000000000001b1c00000000000000000000000000001b000d00000000000000001e000000001b1c00000008000000000000000000001b1c0000001e0000000c0b00000000001b00000000000000000000000000000000
1c00003700001e00000000000000001b1c370000001e0000000c1c370000001b000d000000000000000000000000001b1c0000000000003700000000002c001b1c0000000000000000001e000000001b000d000000000000000000000029001b1c0000291e002021001e000000002c1b00000000000000000000000000000000
1c00000e00001e37000000000000001b000d0000001e002021001b0d0000001b1c00000000000000000000000000001b1c0000000000001f2d000000000c0f001c0000002b0000002a001e000000001b1c0000000a0d000000000000000c0f001c00000c1c003031001e000000000c0000000000000000000000000000000000
1c00000000291b0d000000000000001b1c00002d001e003031001e000000001b1c0000000e000000000000000000001b1c0000000029001b0d0000000000001b1c0f0f0f0f0f0f0f0f0f19000000001b1c0000001e000e00000000000000001b1c2900001b0f0f0f0f1a0f0d0000001b00000000000000000000000000000000
1c000000000c1900000000000000001b000f0f0f0f1a0f0f0f0f19000000001b1c00000000000000000000000020211b1c0000000c0d001e0000002a0000001b1c00000000000000000000000000371b1c0000001e00000e00001f001000001b000d00003d000000000000000000001b00000000000000000000000000000000
1c00000000000000000000000020211b1c00000000000000000000000000001b1c00000000000000000000003730311b1c0029000000001e00000c0f0d00001b3d000000000000000000000000000e1b1c0000001e002021000c0009090909001c0000001e000000000000000000001b00000000000000000000000000000000
1c00370000000000003700000030311b1c00000000000000000000000000001b00090b0000000000000000000a09090000090b000000001e000000000000001b1c002900001f00100000001f2900001b1c0037001e00303100001b00000000001c2900001e002a1f001f2d000037001b00000000000000000000000000000000
1c001f0000000000001f0000000a09001c290029001f000000101f000037001b00001c3a3a3a3a3a3a3a3a3a1b00000000001c393939391e393939393939391b0009090909000909090909000909090000090909000909090909000000000000000909090909091c391b09090909090000000000000000000000000000000000
1c3a1e3a3a3a3a3a3a1e3a3a3a1b000000090909090009090909000909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100000320103601024000230002400023000240002900033000330002f0002f0002e0002e0002b0003100020000310002a0002a000150000c00007000030000000002000000000000000000000000000000000
000100000705008050060500405001050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000011050180501d0501e05019050140500d05004050020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500040305002040030500204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00020255004550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005003550000500005000050000500005000050000500005000050000500
00030000075300a550075500b550085500b550075500a55006550095500c5500d5501155000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0004000004010090200e02027020220301e0001b0001b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000075100d510135101752012540115400e5600a560025400053020500225002450026500275001250009500045000050000500005000050000500005000050000500005000050000500005000050000500
0002001e1304003050007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000001b0501f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001900040131000310003100031000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0003000009050136101c050201402403027040251301c1201d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0501a05010040180301404010040160301c0301e0202104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000090501c4400f0501b44013050154301a04008450110300600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000007050090500a0500a0500a0500e0000e0500e0500e0500d0500d0500e00012050130501505015050160500e00006000000000e0000e0000d0000d0000d0000e0000e0000e0000e0000e0000e0000e000
000f00201b5101b5201b5101b5201e5101e5201f5101f5201b5101b5201a5101a5201851018520165001650018510185201b5101b5201d5101d5201f5101f5201d5101d52018510185201b5101b5201d5101d520
000f00000c023000000000000000186150000003000000000c023000000000000000186150000003000000000c023000000000000000186150000003000000000c02300000000000000018615000000300000000
000f00001b0101b0201b0101b0201e0101e0201f0101f0201b0101b0201a0101a0201801018020160001600018010180201b0101b0201d0101d0201f0101f0201d0101d02018010180201b0101b0201d0101d020
000f000022510225201f5101f520225102252022510225201f5101f52024510245201f5101f52016500165001f5101f52022510225201f5101f520225102252024510245201b5101b52018510185201851018520
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
01 41 42 10 44
00 41 42 10 0f
00 41 42 10 11
00 41 42 0f 12
00 41 42 10 11
02 41 42 10 12
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
