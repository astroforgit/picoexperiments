pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--toyrogue 1.05
--extar 2021
-- toy box jam 2 start cart
-- by that tom hall and friends

--throwing animation is fucked

--make advice text appear when using scrolls and tablets?

--add palette/dimming effect when messages are on screen

--particle effects on throw/hit in combat

--colour-coded palette swapped weapons

function _init()
	version=1.05
	anim_frame=0
	splash_init()
	--difficulty=3 full_reset() init_game() sell_item_prompt=false
end

function _update60()

	anim_frame+=1
	if anim_frame<0 then
		anim_frame=0
	end

	_upd()
	
	update_particles()
	
	update_popups()
	
	update_circle_wipe()
end

function _draw()
	_drw()
	
	draw_popups()
	
	draw_circle_wipe()
	
	--debug test crap
	
end
-->8
--game
function init_game()
	--full_reset()
	init_enemies()
	init_items()
	init_quests()
	
	--prepare level has to happen after items are generated
	create_level()
	
	music(12)
	
	update_player_stats()
	
	_upd=update_game
	_drw=draw_game
end

function update_game()
	
	update_particles()
	quest_update()
	
	if player_hp<1 then
		init_game_over()
	end
	
	old_upd=_upd
	old_drw=_drw
	
	old_player_x=player_x
	old_player_y=player_y
	
	if do_wipe!=true then
		if btnp(î) then
			player_y-=1
		end
		if btnp(É) then
			player_y+=1
		end
		if btnp(ã) then
			player_x-=1
		end
		if btnp(ë) then
			player_x+=1
		end
		if btnp()<15 and btnp()>0 then
			sfx(19)
		end
		if btnp(é) then
			toggle_inventory()
		end
	end
	
	if fget(mget(player_x,player_y),0) then --player wall collision
		player_x=old_player_x
		player_y=old_player_y
		sfx(21)
	else
		if btnp()<15 and btnp()>0 then		
			player_is_running=false
		end
	end
	
	update_entities()
	
	if btnp(ó) and do_wipe!= true then
		if mget(player_x,player_y)==190 then --exit stairs/portal --leave level
			if player_has_exit_rested==false and (player_hp<player_hp_max or player_stamina<player_stamina_max) then
				player_has_exit_rested=true
				rest(1,"exit")
			else
				check_victory()
				sfx(12)
				hours+=1
				enemy_growth()
				init_circle_wipe(player_x,player_y,create_level)
				stats_levels_explored+=1
			end
		elseif mget(player_x,player_y)==21 then --tent
			if player_hp==player_hp_max and player_stamina==player_stamina_max then
				create_message({"you do not need to rest."},"tent")
			else
				rest(2,"tent")
				enemy_growth()
				enemy_growth()
			end
		end
	end
	--if btnp(ó) then
		--create_level()
	--end
	--update_circle_wipe()
	
	update_helper(1)

end

function rest(_duration,_location)

	sfx(14)
	heal_amount=0
	stamina_increase=0
	if player_hp<player_hp_max then
		heal_amount=min(player_hp_max-player_hp,ceil(rnd(player_hp_max/2)))
		player_hp+=heal_amount
	end
	if player_stamina<player_stamina_max then
		stamina_increase=min(player_stamina_max-player_stamina,ceil(rnd(player_stamina_max)))
		player_stamina+=stamina_increase
	end
	--			player_hp=min(player_hp,player_hp_max)
	local heal_message={"you rest for ".._duration.."hr"}
	if heal_amount>0 then
		add(heal_message,"+"..heal_amount.."hp")
	end
	if stamina_increase>0 then
		add(heal_message,"+"..stamina_increase.."ap")
	end
	create_message(heal_message,_location)
	hours+=_duration
	stats_rest_hours+=_duration

end

function draw_game()
	cls()
	palt(0,false)
	colours()
	map()
	pal()
	
	draw_particles()
	
	draw_entities()
	
	--player
	--spr(player_sp,player_x*8,player_y*8)
	local _px=player_x*8
	local _py=player_y*8
	--animate player
	if player_sp_x!=_px or player_sp_y!=_py then
		if player_sp_x<_px then
			player_sp_x+=1
		elseif player_sp_x>_px then
			player_sp_x-=1
		end
		if player_sp_y<_py then
			player_sp_y+=1
		elseif player_sp_y>_py then
			player_sp_y-=1
		end
	end
	
	draw_player(player_sp_x,player_sp_y)
	--hud
	
	
	if mget(player_x,player_y)==21 then
		cool_print("tent: ó rest",1,1,9)
	end
	if mget(player_x,player_y)==190 then
		cool_print("exit: ó go to next area",1,1,9)
	end
	
	print_helper(1)
	
end

--mash these three palette functions into one big one

function colours() --blue two-bit background palette?
		
	level_palettes={
		{0,1},
		{0,2},
		{0,3},
		{0,4},
		{0,5},
		{1,13},
		{2,5},
		{3,11},
		{4,9},
		{5,6},
		}
	level_colour=level_colour or random_table_item(level_palettes)
	
	palette={0,1,0,1,1,5,1,7,7,13,13,2,13,5,7,7}
	for i=0,15 do
		pal(i,palette[i+1])
	end
	pal(5,level_colour[1])
	pal(6,level_colour[2])
end

function combat_colours() --combat background colours
	palette={0,1,2,3,4,1,1,13,8,9,10,11,12,13,14,15}
	for i=0,15 do
		pal(i,palette[i+1])
	end
end	


function whiteout()
	for i=1,15 do
		pal(i,7)
	end
end

function init_circle_wipe(x,y,_finish_command,_arg1)
	if do_wipe!=true then
		do_wipe=true
		circ_radius=1
		circ_radius_change=5
		circ_x=x*8+4
		circ_y=y*8+4
		popups={}
		finish_command=_finish_command
		arg1=_arg1
	end
end

function update_circle_wipe()
	if do_wipe==true then
		circ_radius+=circ_radius_change
		if circ_radius>182 then
			circ_radius_change=-5
			finish_command(arg1)
			popups={}
		end
		if circ_radius<1 then		
			do_wipe=false
		end
	end
end

function draw_circle_wipe()
	if do_wipe==true then
		circfill(circ_x,circ_y,circ_radius,0)
	end
end

-->8
--init
function full_reset()
	-- item_sprites={26,27,28,29,30,44,45,47,48,49,50,51,52,53,154,230}
	cursor_y=0
	cursor_y_sp=0
	
	defeated_enemies={}
	inventory={}
	particles={}
	popups={}
	
	stat_names={
		"attack",
		"defence",
		"health",
		"throw",
		"luck"
		}
		
	stats_base=11-difficulty*2
	
	player_base_stats={}
	for i=1,5 do
		add(player_base_stats,stats_base)
	end	
	
	hours=0
	xp=0
	next_level=100
	level=1
	player_gold=0
	player_hp_max=nil
	player_stamina=10+level
	player_stamina_max=player_stamina
	
	player_derived_stats={}
	for i=1,5 do
		add(player_derived_stats,0)
	end	

	player_hold_stats={0,0,0,0,0}
	player_name='hero'
	player_weapon_stats={0,0,0,0,0}
	
	player_current_item='none'
	player_current_item_id=0
	player_current_item_sp=-1
	player_current_weapon='none'
	player_current_weapon_id=0
	player_current_weapon_sp=-1
	
	player_sp=25
	player_sp_x=56
	player_sp_y=56
	
	player_x=7
	player_y=7
	show_inventory=true
	player_is_running=false
	
	stats_collected_items=0
	stats_enemies_slain=0
	stats_total_damage=0
	stats_items_thrown=0
	stats_dodges=0
	stats_damage_blocked=0
	stats_levels_explored=1
	stats_rest_hours=0
	
	init_helper()
	
end

function reset_map_cursor()
	cursor_dx=0
	cursor_dy=0
	cursor_xy=rnd(1)
	cursor_delta=rnd(1)
	if cursor_delta<0.5 then
		cursor_delta=1
	else
		cursor_delta=-1
	end
	if cursor_xy<0.5 then
		cursor_dx=cursor_delta
	else
		cursor_dy=cursor_delta
	end
	if cursor_x!=mid(2,13,cursor_x) then
		cursor_dx=-cursor_dx
	end
	if cursor_y!=mid(2,13,cursor_y) then
		cursor_dy=-cursor_dy
	end
	cursor_steps=randup(14)
	if cursor_steps>7 and rnd(1)<0.5 then
		cursor_steps-=3
	end
	add(test,cursor_steps)
end

function randup(_num)
 return ceil(rnd(_num))
end

function random_table_item(_table)
	return _table[randup(#_table)]
end

function create_level()
	
	player_has_exit_rested=false
	level_colour=random_table_item(level_palettes)
	init_items()
	floors={}
	floor_enemies={}
	floor_items={}
	particles={}
	
	new_map_cave_3()
end

function new_map_cave_3()
	
	walls={1,201,203,218}
	current_wall=random_table_item(walls)
	current_wall_2=current_wall+1
	for x=0,15 do
		for y=0,15 do
			if rnd(1)<0.7 then
				mset(x,y,current_wall) --walls
			else
				mset(x,y,current_wall_2) --walls
			end
		end
	end
	floor_tiles=rnd(120)+8
	if floor_tiles>63 and rnd(1)<0.5 then
		floor_tiles-=rnd(62)
	end
	msets=0
	cursor_x,cursor_y=player_x,player_y
	repeat
		if fget(mget(cursor_x,cursor_y),0) then
			create_floor_tile(cursor_x,cursor_y)
		end
		if rnd(1)<0.5 then --x
			if rnd(1)<0.5 then
				cursor_x-=1
			else
				cursor_x+=1
			end
		else--y
			if rnd(1)<0.5 then
				cursor_y-=1
			else
				cursor_y+=1
			end
		end
		if cursor_x!=mid(1,14,cursor_x) or cursor_y!=mid(1,14,cursor_y) then
			if #floors>0 then
				new_tile=random_table_item(floors)
				cursor_x,cursor_y=new_tile.x,new_tile.y
			else
				cursor_x,cursor_y=player_x,player_y
			end
		end
	until msets>floor_tiles
	find_free_tile()
	mset(new_tile.x,new_tile.y,190) --place exit
	for i=1,#floors/10 do
		place_item()
		place_enemy()
	end
	
	mset(player_x,player_y,21)--create tent
end

function find_free_tile()
	repeat
		tile_number=randup(#floors)
	until (floors[tile_number].x!=player_x and floors[tile_number].y!=player_y)
	new_tile=floors[tile_number]
	del(floors,floors[tile_number])
end

function create_floor_tile(_cx,_cy)
	floor_tiles_table={0,0,0,0,9,9,10,10,11,12}

	floor_sprite=random_table_item(floor_tiles_table)
	mset(_cx,_cy,floor_sprite)
	msets+=1
	add_to_floors_array(_cx,_cy)
end

function add_to_floors_array(_x,_y)
	local floor={x=_x,y=_y}
	add(floors,floor)
end

--quest section
function init_quests()
	
	quests_complete={1,1,1,1}
	--1 - enemy collection
	---2 - item collection
	----3 - equip a weapon
	-----4 - gain a level
	
	enemy_collection={}
	for i=1,#enemy_names do
		add(enemy_collection,enemy_names[i])
	end
	
	item_collection={}
	for i=1,#item_names do
		add(item_collection,item_names[i])
	end
	
	--equip a weapon quest
end

function check_collection(_name,_collection)
	for i=1,#_collection do
		if _collection[i]==_name then
			del(_collection,_collection[i])
		end
	end
end

function check_victory() --happens when player leaves a level
	
	if #enemy_collection<1 then
		quests_complete[1]=0
	end
	
	if #item_collection<1 then
		quests_complete[2]=0
	end
	
	quests_outstanding=0
	for i=1,#quests_complete do
		quests_outstanding+=quests_complete[i]
	end
	if quests_outstanding==0 then
		sfx(12)
		init_circle_wipe(player_x,player_y,init_you_win)
	end
end

function quest_update()
	if #enemy_collection==0 then
		complete_quest(1,"slay one of each enemy")
	end
	
	if #item_collection==0 and #popups==0 then		
		complete_quest(2,"collect one of each item type")
	end
	
	if player_current_weapon!='none' then
		complete_quest(3,"equip a weapon")
	end
	
	if level>1 then
		complete_quest(4,"gain a level")
	end
end

function complete_quest(_num,_string)
	if quests_complete[_num]==1 then
		quests_complete[_num]=0
			
		create_message({"quest complete!",_string})
		sfx(47)
		sfx(48)
	end
end

-->8
--entities
function init_enemies()
	enemy_pool={}
	floor_enemies={}
	enemy_sprites={98,100,102,104,110,117,123,128,228,231,236,241}
	enemy_names={'slime','gremlin','dragon','snake','robot','skull','claw-beast','ninja', 'chicken-lord','space-hopper','war-snail','warrior'}
	enemy_base_stats={
		{0,0,0,0,0}, --slime
		{3,0,0,0,0}, --gremlin
		{7,7,20,7,7}, --dragon
		{0,2,0,0,0}, --snake
		{0,0,10,0,0}, --robot
		{0,0,0,0,10}, --skull
		{7,0,5,0,0}, --claw-best
		{4,1,5,0,0}, --ninja
		{0,0,0,30,5}, --chicken
		{1,1,1,0,0}, --space-hopper
		{0,5,0,0,0}, --snail
		{3,3,10,3,3} --warrior
		}
	enemy_threats={
		{"[gurgles threateningly]"},
		{"i love a midnight snack!",},
		{"i like my heroes...","medium rare!"},
		{"ssseriousssly?","you'll regret thisss!"},
		{"i'm sorry, "..player_name..",","i'm afraid i can't","let you do that."},
		{"boo!","hah! did i make you jump?"},
		{"you're going to feel","the pinch!"},
		{"hiya.","i mean, hiii-yaaah!"},
		{"who are you","calling chicken?"},
		{"i'm gonna' bounce","on your head!"},
		{"bad things come","to those who wait."},
		{"have at ye!","to battle!"}
		}
	
	for i=1,#enemy_sprites do
		
		local enemy={}
		
		enemy.points=0
		
		local enemy={
			sp=enemy_sprites[i],
			name=enemy_names[i],
			threat=enemy_threats[i],
			x=i+1,
			y=1,
			}
		enemy.points=0
		for j=1,5 do
			local stat=randup(10)+enemy_base_stats[i][j]
			enemy[j]=stat
			enemy.points+=stat
		end
		--enemy.hp_max=enemy[3]
		add(enemy_pool,enemy)
	end
end

function enemy_growth()
	local _r=randup(5)
	for i=1,12 do
		enemy_pool[i][_r]+=1
		enemy_pool[i][3]+=1
	end
	enemy_pool[3][_r]+=1
end

function place_enemy()
	if #floors>0 then
		find_free_tile()
		--local _enemy=new_table(enemy_pool[ceil(rnd(#enemy_pool))])
		local _enemy=new_table(random_table_item(enemy_pool))
		local _x=new_tile.x
		local _y=new_tile.y
		_enemy.shuffle=0
		_enemy.shuffle_max=rnd(100)+60
		_enemy.x=_x
		_enemy.y=_y
		_enemy.y_offset=0
		
		add(floor_enemies,_enemy)
	end
end

function init_items()
	floor_items={}
	item_pool={}
	item_sprites={26,27,28,29,30,44,45,47,48,49,50,51,52,53,114,117,122,154,211,225,227,230,26,27,28,47}
	item_names={'sword','pick','hammer','shield','key','potion','chest','spear','medalion','scroll','relic','jug','tablet','bag','orb','skull','jewel','spyglass','totem','flower','chicken','roast','sabre','kama','warhammer','polearm'}
	--item types, 1=weapon, 2=carry, 3=consume
	item_types={1,1,1,2,2,3,3,1,2,3,2,3,3,3,2,2,2,2,2,2,3,3,1,1,1,1}
	generate_item_stats()
end

function generate_item_stats()
	for i=1,#item_sprites do
		local effect=randup(11)-6
		local type=item_types[i]
		local stat=randup(5)
		local item={
			effect=effect,
			sp=item_sprites[i],
			name=item_names[i],
			type=type,
			stat=stat,
			}
		item.stat_print=stat_names[stat]
		if item_types[i]==1 then
			item.use='wield'
		elseif item_types[i]==2 then
			item.use='hold'
		elseif item_types[i]==3 then
			item.use='use'
		end
		item.full_name=item.name..' of '..item.stat_print..' '..item.effect
		add(item_pool,item)
	end
end

function draw_entities()

	--special terrain
	for x=0,15 do
		for y=0,15 do
			if mget(x,y)==21 then
				spr(21,x*8,y*8)
			end
			if mget(x,y)==190 then
				spr(190,x*8,y*8)
			end
		end
	end

	for item in all (floor_items) do
		if item.flicker==true then
			whiteout()
		end
		spr(item.sp,item.x*8,item.y*8)
		pal()
	end

	for enemy in all (floor_enemies) do
		pal()
		e_x_8=enemy.x*8
		e_y_8=(enemy.y*8)+enemy.y_offset
		if time()%2<1 then
			if enemy.sp==117 or enemy.sp==123 then
				pal(1,8)
				spr(enemy.sp,e_x_8,e_y_8)
			else
				--pal()
				spr(enemy.sp+1,e_x_8,e_y_8)
			end
		else	
			spr(enemy.sp,e_x_8,e_y_8)
		end
	end
	pal()
end

function new_table(tabl)
	local new_table={}
	
	for k,v in pairs(tabl) do
		new_table[k]=v
	end
	
	return new_table
end

function place_item(_x,_y)

	if #floors>0 then
		find_free_tile()
		local _item=new_table(item_pool[ceil(rnd(#item_pool))])
		local x=_x or new_tile.x
		local y=_y or new_tile.y
		_item.flicker=false
		_item.flicker_timer=0
		_item.flicker_max=randup(100)+60
		_item.x=x
		_item.y=y
		add(floor_items,_item)
	end
end

function update_entities() --update step
	for item in all (floor_items) do --item collision
		if item.x==player_x and item.y==player_y then --item pickup
			if #inventory<10+level then
				local send_name=item.name
				check_collection(send_name,item_collection)
				add_to_floors_array(player_x,player_y)
				item.id=time()
				create_popup(item.full_name,player_x*8,player_y*8)
				add(inventory,item)
				del(floor_items,item)
				sfx(10)
				stats_collected_items+=1
			else
				if #popups==0 then
					create_popup('inventory is full',player_x*8,player_y*8,9)
					sfx(4)
				end				
			end
		end
		
		item.flicker_timer-=1 --item flickering
		if item.flicker_timer<0 then
			item.flicker_timer=item.flicker_max
		end
		if item.flicker_timer<6 then
			item.flicker=true
		else
			item.flicker=false
		end
	end
	
	for enemy in all (floor_enemies) do
		if enemy.x==player_x and enemy.y==player_y and player_is_running==false then --enemy collision
			if enemy.has_spoke!=true then
				sfx(7)
				enemy_threat=enemy.threat
				if #enemy_threat>0 then
					create_message(enemy_threat,enemy.name)
				end
				enemy.has_spoke=true
				
			else
				local enemy_payload=enemy
				del(enemies,enemy)
				init_circle_wipe(player_x,player_y,init_combat,enemy_payload)
			end
			player_x=old_player_x
			player_y=old_player_y
		end
		
		if enemy[3]<1 then --kill enemies
			add_to_floors_array(enemy.x,enemy.y)
			place_item(enemy.x,enemy.y)
			del(floor_enemies,enemy)
			sfx(9)
		end
		enemy.shuffle-=1 --shuffle enemies
		if enemy.shuffle<1 then
			enemy.shuffle=enemy.shuffle_max
		end
		if enemy.shuffle<30 then
			enemy.y_offset=0
		else
			enemy.y_offset=1
		end
	end
end

-->8
--combat

function init_combat(enemy)
	
	stats_x=6
	stats_y=57
	stats_weapon_message='weapon: '..player_current_weapon
	stats_item_message='item: '..player_current_item
	stats_width=max(#player_name*4,48) --44px=width of 'defence: 99'
	
	en_combat_x=96
	en_combat_y=32
	en_stats_x=64
	en_stats_y=76
	
	cursor_y=100
	cursor_y_sp=100
	options_x=6
	options_y_min=100
	options_y_max=118
	pl_combat_x=32
	pl_combat_y=32
	
	current_enemy=enemy--new_table(enemy)
	if current_enemy.hp_max==nil then
		current_enemy.hp_max=enemy[3]
	end
	del(floor_enemies,enemy)
	music(18)
	_upd=update_combat
	_drw=draw_combat
	
end

function init_queue(_player_action,_arg1,_enemy_action)

	combat_animation_step=1

	q_player_action=_player_action
	q_arg1=_arg1
	q_enemy_action=_enemy_action

	_upd=queue_action
	
end

function queue_action()
	current_function='queue action'
	if combat_animation_step==1 then
		if q_player_action!=nil and #popups==0 then
			q_player_action(q_arg1)
		else
			next_animation_step()
		end
	elseif combat_animation_step==2 and #popups==0 then
		q_enemy_action()
	elseif combat_animation_step==3 and #popups==0 then
		combat_animation_step=0
		_upd=update_combat
	end	
end

function next_animation_step()
	combat_animation_step+=1
end

function update_combat()
	current_function='update combat'
	update_player_stats()

	update_particles()

	if player_hp>0 and current_enemy[3]>0 then
		
		update_cursor(options_y_min,options_y_max)
		
		if do_wipe!=true then
			
			if run_active==true then
				run_active=false
				sfx(17)
				init_circle_wipe(player_x,player_y,return_to_dungeon)
				player_is_running=true
				player_x=current_enemy.x
				player_y=current_enemy.y
			end
		
			if btnp(ó) then
				if player_stamina>0 then
					if cursor_y==options_y_min then --attack
						if player_current_weapon=='none' then
							sfx(4)
							create_message({'no weapon equipped!'})
						else
							init_queue(do_player_hit,'attack',do_enemy_hit)
						end
					elseif cursor_y==options_y_min+6 then --throw
						if #inventory>0 then
							return_cursor_position=cursor_y
							cursor_y=-1
							update_cursor(6,#inventory*6)
							_upd=update_combat_inventory
							_drw=draw_combat_inventory
						else
							sfx(4)
							create_message({"inventory is empty!"})
						end
					elseif cursor_y==options_y_min+12 then --eat
						if #inventory>0 then
							toggle_inventory()			
						else
							sfx(4)
							create_message({"inventory is empty!"})
						end
					end
				elseif cursor_y!=options_y_min+18 then
					sfx(4)
					create_message({"not enough stamina!"})
				end
				if cursor_y==options_y_min+18 then --run
					
					init_queue(nil,nil,do_enemy_hit)
					run_active=true
					
				end
			end
		end
	else --someone has 0 health
		if current_enemy[3]<=0 then
			init_circle_wipe(player_x,player_y,init_victory)			
		elseif player_hp<=0 then
			init_circle_wipe(player_x,player_y,init_game_over)
		end
	end
end

function do_player_hit(action)
	current_function='do_player_hit'

	player_stamina-=1
	
	popup_x=en_combat_x+12
	popup_y=en_combat_y

	if action=='attack' then
		init_anim_player_attack()
		hit_type=player_derived_stats[1]
	elseif action=='throw' then
		del(inventory,inventory[chosen_object_num])
		current_enemy[chosen_object.stat]=max(0,current_enemy[chosen_object.stat]+chosen_object.effect) --changes enemy stat
		hit_type=player_derived_stats[4] --calculates hit
		stats_items_thrown+=1
		--init_anim_player_throw()
		next_animation_step()
	end
	if rnd(100)<player_derived_stats[5] then --lucky player does double damage
		create_popup("lucky hit!",pl_combat_x,pl_combat_y-6,10)
		player_hit=(hit_type*2)-current_enemy[2]
	else
		player_hit=hit_type-current_enemy[2]
	end
	if rnd(100)>current_enemy[5] then
		player_hit=randup(max(0,player_hit))
		if player_hit>0 then
			current_enemy[3]-=player_hit
			stats_total_damage+=player_hit
			sfx(16)
			create_popup(player_hit..' damage',popup_x,popup_y,9)
			create_blood_splatter(en_combat_x+12,en_combat_y+4,3,'combat')
		else
			sfx(11)
			create_popup("attack blocked",popup_x,popup_y,8)
		end
	else
		sfx(17)
		create_popup("attack missed!",popup_x,popup_y,8)
	end
	current_enemy[3]=max(current_enemy[3],0)
end
--animation stuff
function init_anim_player_attack()
	o_x=pl_combat_x
	pl_combat_x+=48
	old_upd=_upd
	_upd=anim_player_attack
end

function anim_player_attack()
	pl_combat_x-=1
	if pl_combat_x<=o_x then
		pl_combat_x=o_x
		--combat_animation_step+=1
		next_animation_step()
		_upd=old_upd
	end
end

function init_anim_player_throw()
	show_throw_sprite=true
	throw_sp=chosen_object.sp
	--throw_x=pl_combat_x+12
	--throw_y=pl_combat_y+12
	throw_x,throw_y=pl_combat_x+12,pl_combat_y+12
	old_upd=_upd
	_upd=anim_player_throw
end

function anim_player_throw()
	current_function='anim_player_throw'
	throw_x+=3
	if throw_x>en_combat_x then
		show_throw_sprite=false
		--next_animation_step()
		
		do_player_hit('throw')
		_upd=old_upd
	end
end

function do_enemy_hit()

	popup_x,popup_y=pl_combat_x+12,pl_combat_y

	if current_enemy[3]>0 then
		local enemy_attack_strength=0
		if rnd(100)<current_enemy[5] then --player takes double damage if the enemy is lucky
			create_popup("lucky hit!",en_combat_x,en_combat_y-6,10)
			enemy_hit=(current_enemy[1]*2)-player_derived_stats[2]
			enemy_attack_strength=current_enemy[1]*2
		else
			enemy_hit=current_enemy[1]-player_derived_stats[2]
			enemy_attack_strength=current_enemy[1]
		end
		init_anim_enemy_attack()
		stats_damage_blocked+=min(enemy_attack_strength,player_derived_stats[2])
		if rnd(100)>player_derived_stats[5] then --player gets hit if they are not lucky
			enemy_hit=randup(max(0,enemy_hit))
			if enemy_hit>0 then
				player_hp-=enemy_hit
				sfx(16)
				create_popup(enemy_hit..' damage',popup_x,popup_y,8)
				create_blood_splatter(pl_combat_x+12,pl_combat_y+4,3,'combat')
			else
				sfx(11)
			create_popup("attack blocked",popup_x,popup_y,9)
			end
		else
			sfx(17)
			create_popup("attack dodged!",popup_x,popup_y,9)
			stats_dodges+=1
		end
	else
		next_animation_step()
	end
	player_hp=max(player_hp,0)
end

function init_anim_enemy_attack()
	o_x=en_combat_x
	en_combat_x-=48
	old_upd=_upd
	_upd=anim_enemy_attack
end

function anim_enemy_attack()
	
	en_combat_x+=1
	if en_combat_x>=o_x then
		en_combat_x=o_x
		next_animation_step()
		_upd=old_upd
	end
end

function return_to_dungeon()
	add(floor_enemies,current_enemy)
	music(12)
	create_blood_splatter(current_enemy.x,current_enemy.y)
	_upd=update_game
	_drw=draw_game
end

function draw_combat()
	
	pl_x=(player_sp%16)*8
	pl_y=flr(player_sp/16)*8
	en_x=(current_enemy.sp%16)*8
	en_y=flr(current_enemy.sp/16)*8
	
	cls()
	combat_colours()
	map(112,16,0,0,16,16)
	pal()
	--graphics area
	--characters on screen
	draw_particles()
	player_colours()
	sspr(pl_x,pl_y,8,8,pl_combat_x,pl_combat_y,24,24)
	pal()
	palt()
	sspr(en_x,en_y,8,8,en_combat_x,en_combat_y,24,24,true)
	
	--throw item
	if show_throw_sprite==true then
		spr(throw_sp,throw_x,throw_y)
	end	
	--windows
	
	--player stat sheet
	cool_window(stats_x-3,stats_y-3,stats_width,40)
	cursor(stats_x,stats_y,9)
	
	player_stat_print={
		player_name,
		"attack: "..player_derived_stats[1],
		"defence: "..player_derived_stats[2],
		"throw: "..player_derived_stats[4],
	}
	
	for i=1,4 do
		cool_print(player_stat_print[i],stats_x,stats_y+(i-1)*6)
	end
	cursor(stats_x,stats_y+24)
	print_hp(player_hp,player_hp_max)
	cursor(stats_x,stats_y+30)
	print_ap()
	
	--enemy stat sheet
	cool_window(en_stats_x-3,en_stats_y-3,52,34)
	en_stats_c=8 --enemy stat colour
	cool_print(current_enemy.name,en_stats_x,en_stats_y,en_stats_c)
	cool_print(current_enemy.points..'xp',ex_stats_x,en_stats_y+6,en_stats_c)
	cool_print('attack: '..current_enemy[1],en_stats_x,en_stats_y+12,en_stats_c)
	cool_print('defence: '..current_enemy[2],en_stats_x,en_stats_y+18,en_stats_c)
	print_hp(current_enemy[3],current_enemy.hp_max,en_stats_x,en_stats_y+24)

	--combat options area
	cool_window(options_x-3,options_y_min-3,28,28)
	spr(210,options_x-8,cursor_y_sp-1)
	options_c=8
	if player_current_weapon!='none' then
		attack_colour=options_c
	else
		attack_colour=5
	end
	if #inventory>0 then
		inventory_action_colour=options_c
	else
		inventory_action_colour=5
	end
	if player_stamina<1 then
		attack_colour=5
		inventory_action_colour=5
	end
	cool_print('attack',options_x,options_y_min,attack_colour)
	cool_print('throw',options_x,options_y_min+6,inventory_action_colour)
	cool_print('items',options_x,options_y_min+12,inventory_action_colour)
	cool_print('run',options_x,options_y_min+18,options_c)
	
end

function update_combat_inventory()

	update_player_stats()
	update_cursor(6,#inventory*6)
	if btnp(é) then
		cursor_y=return_cursor_position
		cursor_y_sp=return_cursor_position
		_upd=update_combat
		_drw=draw_combat
	end
	if btnp(ó) then --throw
		if inventory[flr(cursor_yd6)].is_equipped!=true then
			chosen_object=inventory[flr(cursor_yd6)]
			chosen_object_num=cursor_yd6
			
			sfx(3)
			cursor_y=-1
			_upd=update_combat
			_drw=draw_combat
			--init_queue(do_player_hit,'throw',do_enemy_hit)
			init_queue(init_anim_player_throw,nil,do_enemy_hit)
		else
			sfx(4)
			_upd=update_combat
			_drw=draw_combat
			create_message({"can't throw equipped items!"})
		end
	end
end

function draw_combat_inventory()
	if #inventory>0 then
		cool_window(0,3,126,#inventory*6+4)
		for i=1,#inventory do
			if inventory[i].effect<0 then
				item_colour=8
			elseif inventory[i].effect>0 then
				item_colour=11
			end
			if inventory[i].is_equipped==true then
				item_colour=9
			end
			cool_print(inventory[i].full_name,10,i*6,item_colour)
		end
		spr(210,1,cursor_y_sp-1) --cursor
		
		spr(inventory[cursor_yd6].sp,117,cursor_y-2) --item sprite
	else
		cool_window(7,3,120,10)
		cool_print('inventory empty!',10,6,8)
	end
end

-->8
--screens

function splash_init()

	--game_state='splash'
	cx={63,51,75,63,63,51,75,63}
	cy={43,48,48,52,56,63,63,68}
	lines={}
	
	music(21)
	_upd=splash_update
	_drw=splash_draw
end

function splash_update()
	if btnp(ó) or anim_frame>=400 then
		init_title()
	end
end

function splash_draw()
	cls()
	if anim_frame<200 then
		n1=ceil(rnd(8))
		repeat 
			n2=ceil(rnd(8)) 
		until (n1!=n2)
		for i=1,2 do
			local l={
				x1=cx[n1],
				y1=cy[n1],
				x2=cx[n2],
				y2=cy[n2],
				}
			add(lines,l)
		end
		for l in all (lines) do
			if l.y1==52 or l.y1==56 or l.y2==52 or l.y2==56 then
				line(l.x1,l.y1+1,l.x2,l.y2+1,4)
				if l.y1<46 and l.y2<46 then
					line(l.x1,l.y1,l.x2,l.y2,9)
				end
			end
			if l.y1==l.y2 or (l.y1+l.y2==111 and l.x1!=l.x2) then
				del(lines,l)
			end
		end
		
		for l in all (lines) do
			if not(l.y1==60 or l.y1==64 or l.y2==60 or l.y2==64) then
				line(l.x1,l.y1+1,l.x2,l.y2+1,4)
				line(l.x1,l.y1,l.x2,l.y2,9)
			end
		end
		
			sspr(0,80,34,7,46,73)
			print('presents',48,82,9)
		
	elseif anim_frame<400 then
		--print('toy box jam 2',37,57,8)
		print('toy',37,57,8)
		print('box',53,57,11)
		print('jam',69,57,12)
		print('2',85,57,9)
		print('18TH december 2020',27,63,7)
		print('-',61,69,7)
		print('1ST february 2021',31,75,7)
	end
end

function init_title()
	anim_frame=0
	cam_y=-128
	cam_target=0
	cursor_x=0
	cursor_y=0
	difficulty=2
	menu_step=0
	player_sp=25
	
	_upd=update_title
	_drw=draw_title
end

function update_title()
	if cam_y<cam_target and anim_frame%2==0 then
		cam_y+=1
	end
	if btnp(ó) then
		if cam_y<cam_target then
			cam_y=cam_target
			anim_frame=300
		else
			menu_step_forward()
			--menu_step+=1
			--sfx(1)
		end
		
	end
	if menu_step==1 then
		cursor_y=90
		if difficulty==1 then
			cursor_x=23
			difficulty_colour=11
			difficulty_colour_2=3
			difficulty_message="+6 to all stats"
		elseif difficulty==2 then
			cursor_x=43
			difficulty_colour=9
			difficulty_colour_2=4
			difficulty_message="+3 to all stats"
		elseif difficulty==3 then
			cursor_x=71
			difficulty_colour=8
			difficulty_colour_2=2
			difficulty_message="no bonuses"
		end
		if btnp(ã) then
			difficulty-=1
		end
		if btnp(ë) then
			difficulty+=1
		end
		if btnp(ã) or btnp(ë) then
			anim_frame-=anim_frame%90
			sfx(19)
		end
		if difficulty<1 then
			difficulty=3
		elseif difficulty>3 then
			difficulty=1
		end
	elseif menu_step==2 then
		cam_target=128
	end
	
	if cam_y==128 or (btn(é) and btnp(ó)) then
		init_character_creation()
		camera()
	end
end

function draw_title()

	cls()
	camera(0,cam_y)
	pal(4,1)
	map(112,0,0,0,16,16)
	pal()
	map(112,0,0,0,16,3)
	draw_player(8,8)
	pset(93,82,0)--covers annoying flashing pixel
	if cam_y>=0 then
		if anim_frame>300 or menu_step>0 then
			rectfill(35,42,90,50,0)
			sspr(0,72,54,7,36,43) --title sprite
		end
		if anim_frame>360 and menu_step==0 and anim_frame%90<45 then
			cool_print_centre("press ó to start",57,7,1)
		end
		if menu_step==1 then
			title_window("select difficulty",77,7)
			title_window("easy normal hard",91,7)
			title_window(difficulty_message,105,difficulty_colour)
			if anim_frame%90<45 then
				pal(7,difficulty_colour)
				pal(6,difficulty_colour_2)
				spr(210,cursor_x,cursor_y)
				pal()
			end
		end
	end
	print("extar 2021                 V"..version,1,123,1)
end

function init_character_creation()
	
	full_reset()
	
	current_letter=8
	free_points=0
	letters="abcdefghijklmnopqrstuvwxyz-' "
	screen_start=anim_frame
	menu_scroll=0
	menu_y_target=45
	menu_step=1
	name_character=1
	_upd=update_character_creation
	_drw=draw_character_creation
end

function update_character_creation()
	if menu_step==1 then
		cursor_x=8
		cursor_y=22
		if btnp(ã) then
			cursor_x-=4
			name_character-=1
			find_current_letter()
			sfx(19)
		end
		if btnp(ë) then
			cursor_x+=4
			name_character+=1
			find_current_letter()
			sfx(19)
		end
		if name_character<1 then --adds another letter onto end of name
			name_character=#player_name
		elseif name_character>#player_name then
			player_name=player_name..sub(letters,1,1)
			find_current_letter()
		end
		if btnp(é) and #player_name>1 then
			player_name=sub(player_name,1,#player_name-1)
			sfx(4)
		end
		if name_character>#player_name then
			name_character=#player_name
			find_current_letter()
		end
		cursor_x=name_character*4+4
		
		if btnp(î) then
			current_letter-=1 --letter up
		end
		if btnp(É) then
			current_letter+=1 --letter down
		end
		
		if current_letter<1 then --wraps current letter
			current_letter=#letters
		elseif current_letter>#letters then
			current_letter=1
		end
		replace_letter() --updates the name_character to current_letter
		
		if btnp()>0 and btnp()<15 then
			anim_frame-=anim_frame%90
			sfx(19)
		end
		
		if current_letter<1 then
			current_letter=#letters
		elseif current_letter>#letters then
			current_letter=1
		end
		
		menu_step_forward(63)

	elseif menu_step==2 then --onto stat choice
		if btnp(ó) then
			menu_step_forward(123)
			cursor_x=2
			cursor_y=1
		end

		menu_step_backward(45)
			
	elseif menu_step==3 then
		menu_step_forward()

		menu_step_backward(63)

		if btnp(î) then
			cursor_y-=1
			if cursor_y<1 then
				cursor_y=5
			end
		end
		if btnp(É) then
			cursor_y+=1
			if cursor_y>5 then
				cursor_y=1		
			end
		end
		if btnp(ë) then
			if free_points>0 then
				player_base_stats[cursor_y]+=1
				free_points-=1
				sfx(5)
			else
				sfx(4)
			end
		end
		if btnp(ã) then 
			if player_base_stats[cursor_y]>max(1,9-difficulty*3) then
				player_base_stats[cursor_y]-=1
				free_points+=1
				sfx(2)
			else
				sfx(4)
			end
		end
	elseif menu_step==4 then
		if btnp(ó) then
			if free_points==0 then
				init_game()
			else
				menu_step_forward()
			end
		end
		menu_step_backward(123)

	elseif menu_step==5 then
		if btnp(ó) then
			init_game()
		end
		if btnp(é) then
			menu_step_backward(123)
			menu_step-=1
		end
	end
	
	if anim_frame%3==0 then
		if menu_scroll<menu_y_target then 
			menu_scroll+=1
		elseif menu_scroll>menu_y_target then
			menu_scroll-=3
		end
	end
end

function menu_step_forward(_y_target)
	if btnp(ó) then
		menu_step+=1
		menu_y_target=_y_target or 128
		sfx(1)
	end
end

function menu_step_backward(_y_target)
	if btnp(é) then
		menu_step-=1
		menu_y_target=_y_target
		sfx(4)
	end
end

function find_current_letter()
	for i=1,#letters do
		if sub(player_name,name_character,name_character)==sub(letters,i,i) then
			current_letter=i
		end
	end
end

function replace_letter()
	old_player_name=player_name
	for i=1,#player_name do
		if i==1 then
			if name_character==1 then
				player_name=sub(letters,current_letter,current_letter)
			else
				player_name=sub(old_player_name,1,1)
			end
		else
			if name_character==i then
				player_name=player_name..sub(letters,current_letter,current_letter)
			else
				player_name=player_name..sub(old_player_name,i,i)
			end
		end
	end
end

function draw_character_creation()
	
	cursor_yt6=cursor_y*6
	
	cls()
	colours()
	map(112,0,0,0,16,16)
	pal()
	camera()
	cursor(10,10,7)
	print('what is your name, hero?')
	new_line(2)
	print(player_name)
	if anim_frame%90<45 and menu_scroll==45 then
		color(10)
		print('î',cursor_x,cursor_y)
		print('ãÉë',cursor_x-8,cursor_y+12)
		color(7)
	end
	new_line()
	cursor(10,40,7)
	if menu_scroll==45 then
		color(10)
		print("ó: confirm, é: backspace")
		color(7)
	else
		new_line()
	end
	print(player_name..". is that correct?")
	new_line()
	color(7)
	if menu_step==2 then
		while ord(player_name,#player_name)==32 do
			player_name=sub(player_name,1,#player_name-1)
		end
		color(10)
		print("ó - yes é - no")
	elseif menu_step>2 then
		print("yes")
	elseif menu_step<2 then
		print("no")
	end
	new_line()
	print("very well. tell me, "..player_name)
	print("where does your strength lie?")
	new_line()
	for i=1,#player_base_stats do
		print(stat_names[i]..': '..player_base_stats[i])
	end
	print("free points:"..free_points,70,112,7)
	
	if menu_step==3 and menu_scroll==123 then
		color(10)
		print('î',2,79+cursor_yt6)
		print('É',2,79+6+cursor_yt6)
		print('ãë',54,82+cursor_yt6)	
		print("ó: confirm é: cancel",10,118)
	end

	rectfill(0,menu_scroll,127,127,0)
	
	if menu_step==4 then
		title_window("press ó to begin your quest ",56,9)
		title_window("or é to go back",67,9,1)
	end
	if menu_step==5 then
		message="are you sure? you still have"
		cool_window(63-#message*2-4,43,#message*4+6,18)
		cool_print_centre(message,47)
		cool_print_centre("free points to spend!",53)
		title_window("ó: i am sure é: go back",67,9,2)
	end
	
end

function toggle_inventory()
	if show_inventory==true then
		init_inventory()
		show_inventory=false
		sfx(5)
		has_used_inventory=true
	else
		_upd=return_upd
		_drw=return_drw
		show_inventory=true
	end
	
end

function init_inventory()
	cursor_y=6
	cursor_yd6=1
	cursor_y_sp=6
	return_upd=_upd
	return_drw=_drw
	_upd=update_inventory
	_drw=draw_inventory
end

function update_inventory()

	update_player_stats()

	update_cursor(6,#inventory*6)
	
	if btnp(ã) then
		init_quest_window()
		sell_item_prompt=false
	end
	
	if btnp(ë) and #inventory>0 then --sell item
		if inventory[cursor_yd6].is_equipped!=true then
			sell_item_prompt=true
		else
			create_message({"can't sell equipped items!"})
		end
	end
	
	if btnp(é) then
		toggle_inventory()
		sell_item_prompt=false
	end
	if btnp(ó) then
		if sell_item_prompt==true then
			sell_item(cursor_yd6)
			sell_item_prompt=false
		else
			use_item(cursor_yd6)
		end
		update_cursor(6,#inventory*6)
	end
	update_helper(2)
end

function update_cursor(_min_y,_max_y)

	cursor_y_sp=mid(_min_y,_max_y,cursor_y_sp)

	if btnp(î) then
		cursor_y-=6
		sell_item_prompt=false
	end
	if btnp(É) then
		cursor_y+=6
		sell_item_prompt=false
	end
	if btnp()<15 and btnp()>0 then
		sfx(19)
	end
	if cursor_y<_min_y then
		cursor_y=_max_y
		cursor_y_sp=_max_y
	elseif cursor_y>_max_y then
		cursor_y=_min_y
		cursor_y_sp=_min_y
	end
	
	if cursor_y_sp<cursor_y then
		cursor_y_sp+=1
	elseif cursor_y_sp>cursor_y then
		cursor_y_sp-=1
	end
	
	cursor_yd6=cursor_y/6
end

function use_item(num)
	
	fortune_cookies={
		"uncertainty brings opportunity",
		"hope is around the corner",
		"your lucky number is "..player_derived_stats[5],
		"a dragon brings luck",
		"play super mumtaz bros.!",
		"have you tried picomen yet?",
		"happy toyboxjam!",
		"a happy time is ahead",
		"you will be lucky",
		"a journey begins soon",
		-- advice={
		"throw bad items at enemies.",
		"you can rest in your tent",
		"thrown items affect stats",
		"luck helps dodge attacks",
		"lucky attacks do double damage",
		"level up to carry more",
		"use run to go through enemies",
		}
	
	old_player_hp_max=player_hp_max
	old_player_hp=player_hp
	
	if #inventory>0 then
		local _item=inventory[num]
		
		if _item.type==1 then --wield
			player_weapon_stats={0,0,0,0,0}
			player_weapon_stats[_item.stat]=_item.effect
			old_weapon=player_current_weapon
			player_current_weapon=_item.full_name
			player_current_weapon_id=_item.id
			player_current_weapon_sp=_item.sp
			sfx(1)
		end
		
		if _item.type==2 then --hold
			player_hold_stats={0,0,0,0,0}
			player_hold_stats[_item.stat]=_item.effect
			old_item=player_current_item
			player_current_item=_item.full_name
			player_current_item_id=_item.id
			player_current_item_sp=_item.sp
			sfx(1)
		end
		
		if _item.type==3 then --eat
			player_base_stats[_item.stat]+=_item.effect
			del(inventory,inventory[num])
			sfx(3)
			create_message({"you find a fortune cookie!",random_table_item(fortune_cookies)})
		end
		_item.is_equipped=true
	end
	
	for item in all (inventory) do
		if item.is_equipped==true and player_current_item_id!=item.id and player_current_weapon_id!=item.id then
			item.is_equipped=false
		end
	end
end

function sell_item(num)
	
	local _item=inventory[num]
	
	player_gold+=max(_item.effect,0)
	del(inventory,inventory[num])
	sfx(5)

end

function draw_inventory()
	--cls()
	camera()
	return_drw()
	cool_window(2,2,123,72)
	line(3,62,125,62,9)
	line(4,63,124,63,0)
	cool_print('items held: '..#inventory..'/'..10+level..' gold: '..player_gold,6,66,7)
	
	clip(2,5,125,56)
	offset=-max(cursor_y_sp-54,0)
	if #inventory>0 then	--prints contents of inventory
		for i=1,#inventory do
			item_colour=7
			if inventory[i].effect<0 then
				item_colour=8
			elseif inventory[i].effect>0 then
				item_colour=11
			end
			if inventory[i].is_equipped==true then
				item_colour=9
			end
			local _item_name=inventory[i].full_name
			cool_print(_item_name,10,(i*6)+offset,item_colour)
		end
		spr(210,1,cursor_y_sp-1+offset) --cursor
		if sell_item_prompt==true then
			cool_print("sell?",96,offset+cursor_y,9)
			message_1="sell "..inventory[cursor_yd6].full_name
			message_2="for "..max(0,inventory[cursor_yd6].effect).." gold?"
			cool_window(63-#message_1*2-4,8,#message_1*4+6,24)
			cool_print_centre(message_1,12)
			cool_print_centre(message_2,18)
			cool_print_centre("ó: yes",24,9,1)
		else
			cool_print(inventory[cursor_yd6].use,96,cursor_y+offset,9)
		end
		spr(inventory[cursor_yd6].sp,116,cursor_y+offset)
		
	else
		cool_print('inventory empty!',5,5,8)
	end	
	
	clip()
	--bottom stats window?
	cool_window(1,78,125,48)
	--player item graphics
	cool_window(111,96,11,11)
	draw_player(113,99)
	cool_window(96,111,11,11)
	spr(player_current_weapon_sp,98,113)
	cool_window(111,111,11,11)
	spr(player_current_item_sp,113,113)
	
	--player stats
	print_player_stats(5,82,7)
	
	--other stats window
	cool_window(51,99,41,23)
	cool_print('lvl: '..level,55,103,7)
	cool_print('xp: '..xp,55,109,7)
	print_hp(player_hp,player_hp_max,55,115)
	
	print_helper(2)
	
end

function init_helper()
	helper={
		{"é inventory ","ó interact "}, --game
		{"é return ","ó use item ","ã quests ","ë sell "}, --inventory
		{"é return to game ","ë inventory "}, --quests
	}
end

function update_helper(_num)

	key_press=""
	if btnp(é) then
		key_press="é"
	end
	if btnp(ó) then
		key_press="ó"
	end
	if btnp(ã) then
		key_press="ã"
	end
	if btnp(ë) then
		key_press="ë"
	end
	for i=1,#helper[_num] do
		if sub(helper[_num][i],1,1)==key_press then
			del(helper[_num],helper[_num][i])
			break
		end	
	end
end

function print_helper(_num)
	message=""
	for i=1,#helper[_num]do
		message=message..helper[_num][i]
	end
	if time()%2<1 then
		helper_colour=10
	else
		helper_colour=7
	end
	cool_print(message,2,121,helper_colour)
end

function draw_player(_x,_y)
	player_colours()
	
	spr(player_sp,_x,_y)
	if anim_frame%120<60 then
		player_sp=25
	else
		player_sp=24
	end
	pal()
	--palt()
end

function player_colours()
	--pal(1,10)--torso?
	--pal(5,8)--torso
	--pal(6,8)--torso
	--pal(9,15) --skin tone
	--pal(10,4) --hair
	--pal(12,6) --legs
	--palt(14,true) --no helmet
	--palt(15,true) --no helmet
	if player_current_weapon_sp==-1 then --no weapon
		palt(13,true)
	else
		pal(5,6)
		pal(13,6)
	end
	if player_current_item_sp==-1 then --no item
		palt(2,true)
		palt(7,true)
	else
	
	end
end

function print_player_stats(_x,_y,_c)
	cool_print("weapon: "..player_current_weapon,_x,_y,_c)
	cool_print("item: "..player_current_item,_x,_y+6,_c)
	for i=1,5 do
		if player_base_stats[i]>player_derived_stats[i] then
			stat_colour=8
		elseif player_base_stats[i]<player_derived_stats[i] then
			stat_colour=11
		else
			stat_colour=_c
		end
		cool_print(stat_names[i]..": "..player_derived_stats[i],_x,_y+(i+1)*6,stat_colour)
	end
end

function print_hp(_hp,_hp_max,_x,_y)

	if _hp>_hp_max/2 then
		hp_colour=11
	elseif _hp>_hp_max/3 then
		hp_colour=10
	elseif _hp>_hp_max/4 then
		hp_colour=9
	else
		hp_colour=8
	end
	cool_print(_hp.."/".._hp_max.."hp",_x,_y,hp_colour)
end

function print_ap()

	local _ap=player_stamina
	local _ap_max=10+level
	if _ap>_ap_max/2 then
		ap_colour=11
	elseif _ap>_ap_max/3 then
		ap_colour=10
	elseif _ap>_ap_max/4 then
		ap_colour=9
	else
		ap_colour=8
	end
	cool_print(_ap.."/".._ap_max.."ap",nil,nil,ap_colour)
end

function update_player_stats() --this needs to go somewhere more sensible
	
	old_health=player_derived_stats[3]
	
	for i=1,5 do
		player_derived_stats[i]=player_base_stats[i]+player_weapon_stats[i]+player_hold_stats[i]
	end
	
	if player_hp_max==nil then
		player_hp_max=player_derived_stats[3]
		player_hp=player_hp_max
	end
	
	if old_health!=player_derived_stats[3] then
		player_hp+=player_derived_stats[3]-old_health
		player_hp_max+=player_derived_stats[3]-old_health
	end
	
	player_stamina_max=10+level
	
end

function init_victory()
	
	if current_enemy[3]<1 then
		stats_enemies_slain+=1
	end
	
	old_level=level
	victory_step=1
	music(6)
	send_name=current_enemy.name
	check_collection(send_name,enemy_collection)
	
	_upd=update_victory
	_drw=draw_victory
end

function update_victory()
	if btnp(ó) then
		victory_step+=1
		if victory_step==2 then --add enemy xp
			xp+=current_enemy.points
			sfx(1)
			if xp<next_level then
				victory_step=4
			end
		elseif victory_step==3 then --work out new player level (can repeat)
			check_xp()
			if xp>=next_level then
				victory_step-=1
			end
		elseif victory_step>=4 then
			return_to_dungeon()--init_circle_wipe(63,63,return_to_dungeon)
		end
	end
end

function draw_victory()
	cls()
	cool_window(8,8,112,112)
	spr(current_enemy.sp,108,12)
	cursor(12,12,7)
	cool_print('victory!')--,ox,oy,10)
	--new_line()
	cool_print(current_enemy.name..' defeated!')--,ox,oy+6,7)
	if victory_step==1 then
		cool_print('xp: '..xp..' +'..current_enemy.points..'xp')--,ox,oy+18)
		cool_print('level: '..level)--,ox,oy+24)
		cool_print('you need '..max(0,next_level-xp)..'xp to\nreach level '..level+1)--,ox,oy+30)
		--new_line()
	elseif victory_step>=2 then
		cool_print('xp: '..xp)--,ox,oy+18)
		cool_print('level: '..level)--,ox,oy+24)
		cool_print('you need '..max(0,next_level-xp)..'xp to\nreach level '..level+1)--,ox,oy+30)
		--new_line()
	end
	if victory_step>=3 then
		if old_level!=level then
			cool_print('new level! excellent!')
			--new_line()
		end
	end
	color(10)
	if victory_step<3 then
		cool_print('press ó/x')
		--new_line(2)
	else
		cool_print('press ó/x to\ncontinue your quest')
		--new_line(2)
	end
	draw_player(@0x5f26,@0x5f27)
end

function check_xp()
	if xp>=next_level and level<10 then
		level+=1
		xp-=next_level
		next_level=next_level+next_level
		sfx(12)
		for i=1,5 do
			player_base_stats[i]+=1
		end
	end
end

function init_game_over()
	music(0)
	end_message_1="you have died heroically\nsomewhere in the dungeon"
	end_message_2="\nmeet an untimely end"
	end_message_3="too bad!"
	init_end()
end

function init_you_win()
	music(6)
	end_message_1="you have completed your\nheroic quest"
	end_message_2="\nbanish evil"
	end_message_3="what an achievement!"
	init_end()
end
	
function init_end()
	create_level(3)
	stats_x=128
	stats_num=1
	_upd=update_end
	_drw=draw_end
end

function update_end()
	if time()%1==0 then
		create_level()
	end
	
	if btnp(é) then
		if restart_confirm==true then
			restart_confirm=false
		else
			extcmd('screen')
		end
	end
	
	if btnp(ó) then
		if restart_confirm!=true then
			restart_confirm=true
			sfx(1)
		else
			sfx(12)
			splash_init()
		end		
	end
end

function draw_end()
	cls()
	palt(0,false)
	colours()
	map()
	pal()
	draw_entities()
	
	--clip(10,10,109,109)
	cool_window(10,10,108,72)
	cursor(14,14,7)
	cool_print(player_name..',')
	cool_print(end_message_1)
	--new_line(2)
	cool_print('it took you '..hours..' hours to'..end_message_2)
	--new_line(3)
	
	stats={
		'you reached level '..level,
		'you collected '..stats_collected_items..' items',
		'you slain '..stats_enemies_slain..' enemies',
		'you inflicted '..stats_total_damage..' points of damage',
		'you threw '..stats_items_thrown..' items at enemies',
		'you dodged '..stats_dodges..' enemy attacks',
		'you blocked '..stats_damage_blocked..' points of damage',
		'you explored '..stats_levels_explored..' levels of the dungeon',
		'you rested for '..stats_rest_hours..' hours',
		}
	if stats_x<0-#stats[stats_num]*4 then
		stats_x=128
		stats_num+=1
		if stats_num>#stats then
			stats_num=1
		end
	end
	stats_x-=1
	clip(14,14,100,100)
	cool_print(stats[stats_num],stats_x)
	clip(10,10,109,109)
	--new_line(1)
	cool_print(end_message_3,14)
	
	title_window("ó reset é screenshot",88,9,2)

	if restart_confirm==true then
		cls()
		title_window("reset the game?",56,9)
		title_window("ó reset game é cancel",70,9,2)
	end
end

function create_message(_message,_title)
	
	window_title=_title
	window_message_table=_message
	longest_string=0
	for i=1,#window_message_table do
		longest_string=max(longest_string,#window_message_table[i])
	end
	longest_string*=2
	
	old_update=_upd
	old_draw=_drw
	
	_upd=update_message
	_drw=draw_message

end

function update_message()

	if btnp(ó) then
		_upd=old_update
		_drw=old_draw
	end

end

function draw_message()

	_y_coord=63-#window_message_table*3
	
	cool_window(63-longest_string-4,_y_coord-3,longest_string*2+6,#window_message_table*6+6)
	
	for i=1,#window_message_table do
		cool_print(window_message_table[i],63-longest_string,_y_coord+(i*6)-5,10)
	end
	
	x_button_y=_y_coord+(#window_message_table*6)+1
	
	cool_print('è',55+longest_string,x_button_y,1)
	if time()%2<1 then
		cool_print('ó',55+longest_string,x_button_y,9)
	else
		cool_print('ó',55+longest_string,x_button_y,10)
	end
	
	if window_title!=nil then
		cool_window(63-longest_string-4+3,_y_coord-13-1,#window_title*4+6,12)
		cool_print(window_title,63-longest_string+3,_y_coord-9-1,9)
	end
end

function create_popup(_string,_x,_y,_c,_t)
	_x=_x or 63
	local popup={
		message=_string,
		x=_x-#_string*2,
		y=_y or 63,
		c=_c or 7,
		t=_t or 60,
		}
	popup.x=mid(0,popup.x,127-#_string*4)
	add(popups,popup)
end

function update_popups()
	for popup in all (popups) do
		popup.t-=1
		if popup.t<1 then
			del(popups,popup)
		end
		popup.y-=0.1
		popup.y=max(0,popup.y)
	end
end

function draw_popups()
	for popup in all (popups) do
		rectfill(popup.x,popup.y,popup.x+(#popup.message*4-2),popup.y+4,0)
		cool_print(popup.message,popup.x,popup.y,popup.c)
	end
end

function init_quest_window()

	transition_lock=true

	back_to_inventory=false

	cam_x_offset=128
	cam_x_target=0
 
	quest_descrip={"slay the monsters","recover the artifacts","equip a weapon","gain a level"}
 
	_upd=update_quest_window
	_drw=draw_quest_window
end

function update_quest_window()
	
	if cam_x_offset!=cam_x_target then
		transition_lock=true
	else
		transition_lock=false
	end

	if cam_x_offset>cam_x_target then
		cam_x_offset-=4
	elseif cam_x_offset<cam_x_target then
		cam_x_offset+=4
	end
	if btnp(ë) then
		cam_x_target=128
		back_to_inventory=true
	end
	if btnp(é) and transition_lock==false then
		toggle_inventory()
	end
	
	if back_to_inventory==true and cam_x_offset==cam_x_target then
		_upd=update_inventory
		_drw=draw_inventory
	end
	
	update_helper(3)
end

function draw_quest_window()
	
	camera()
	if back_to_inventory==true then
		draw_inventory()
	end

	camera(cam_x_offset,0)
	if cam_x_offset==0 then
		draw_inventory()
	end
	cool_window(2,2,124,124)

	cool_print('quest log',6,6,9)

	for i=1,#quests_complete do
		if quests_complete[i]==1 then
			cool_print(quest_descrip[i],6,i*6+12,7)
		else
			cool_print('quest complete',6,i*6+12,7)
		end
	end
	cursor(6,48)
	for i=1,#enemy_collection do
		cool_print(enemy_collection[i],6,42+i*6)
	end
	
	for i=1,min(#item_collection,24) do
		if i<13 then
			--cursor(48+6,42+i*6)
			item_collection_x=56
			item_collection_y=42+i*6
		else
			--cursor(48+6+36,42+(i-12)*6)
			item_collection_x=90
			item_collection_y=42+(i-12)*6
		end
		--cool_print(item_collection[i])
		cool_print(item_collection[i],item_collection_x,item_collection_y)
	end
	
	print_helper(3)
end
-->8
--particles

function create_blood_splatter(_x,_y,_delta,_class)
	
	_class=_class or 'floor'
	_delta=_delta or 1
	
	for i=1,30 do
		local pixel={
			class=_class,
			c=8,
			x=_x*8+4,
			y=_y*8+4,
			dx=rnd(_delta*2)-_delta,
			dy=rnd(_delta*2)-_delta,
			}
		if _class=='combat' then
			pixel.x/=8
			pixel.y/=8
			pixel.fall=0
			pixel.target_y=rnd(16)+pixel.y+16
		end
		add(particles,pixel)
	end
end

function update_particles()

	for pixel in all (particles) do
		pixel.x+=pixel.dx
		pixel.y+=pixel.dy
		pixel.dx*=0.9
		pixel.dy*=0.9
		if pixel.class=='floor' then
			if abs(pixel.dy)<0.1 then
				pixel.dy=0
			end
			if abs(pixel.dx)<0.1 then
				pixel.dx=0
			end
			if fget(mget(pixel.x/8,pixel.y/8),0) then
				pixel.dx,pixel.dy=0,0
			end
			
		--combat blood
		elseif pixel.class=='combat' then
			if abs(pixel.dy)<0.1 then
				pixel.dy=0
			end
			if abs(pixel.dx)<0.1 then
				pixel.dx=0
			end
			
			if pixel.y>pixel.target_y then
				pixel.fall=0
				pixel.dx,pixel.dy=0,0
			else
				if pixel.fall<3 then
					pixel.fall+=0.05
					pixel.y+=pixel.fall
				end
			end
		end	
	end
	
end

function draw_particles()
	for pixel in all (particles) do
		if pixel.class=='floor' then
			if _drw==draw_game then
				pset(pixel.x,pixel.y,pixel.c)
			end
		elseif pixel.class=='combat' then
			if _drw==draw_combat then
				pset(pixel.x,pixel.y,pixel.c)
			else
				del(particles,pixel)
			end
		end
	end
end		
-->8
--functions

function new_line(num)
	for i=1,(num or 1) do
		poke(0x5f27,@0x5f27+6)
	end
end

function cool_window(_x,_y,_w,_h) --needs to go in a more general section
	local x1=_x
	local y1=_y
	local x2=_x+_w
	local y2=_y+_h
	rectfill(x1+1,y1+1,x2+1,y2+1,0)
	rectfill(x1,y1,x2,y2,1)
	rect(x1+1,y1+1,x2,y2,0)
	rect(x1,y1,x2,y2,9)
end

function title_window(_string,_y,_c,_extra)
	local pad=_extra or 0
	local padded_string=(#_string)+pad
	
	cool_window(63-padded_string*2-4,_y-4,padded_string*4+6,12)
	cool_print_centre(_string,_y,_c,_extra)
end

function cool_print(_string,_x,_y,_c)

	local _c1=_c or @24357--@0x5f25
	local _x1=_x or @0x5f26
	local _y1=_y or @0x5f27

	print(_string,_x1+1,_y1+1,0)
	print(_string,_x1,_y1,_c1)
	if _y==nil then
		poke(0x5f27,@0x5f27+6) --newline
	end
end

function cool_print_centre(_string,_y,_c,_extra)
	local pad=_extra or 0
	local padded_string=(#_string)+pad
	cool_print(_string,63-padded_string*2,_y,_c)
end
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500900000dddd00656565650d04400000044000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000940050dddddd0666666650d0ff0000d0ff00006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050944900dddddddd662226650d0aa0000d0aa00700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605009494000555555066666665d88880070d88880200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc0765676007600760076676700944949006666660665556650f088802d8d880f200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655941144506dd6c6066111665000660f20f06600200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767669410014406dd6c6066111665006aa602006aa6000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655654410014406dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000712826007282160
a979979400e88000d75cc57dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500612825006282150
a71991740e111800d77cc77dd75cc57d271881722718817203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
4444440044440044004404444400044440004444004400440444444000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
00990009900990990099099009909900990990099099009909900000202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
00aa000aa00aa0aa00aa0aa00aa0aa00aa0aa00000aa00aa0aa0000002282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
007700077007700777700777770077007707707770770077077770001111111006ddddd071100115600006000000000056776665575757777576755757777775
00aa000aa00aa000aa000aa00aa0aa00aa0aa00aa0aa00aa0aa000000ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
009900099009900099000990099099009909900990990099099000006d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
004400004444000044000440044004444000444440044440044444406522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000000000000000000000000000000000000000000000000000052220001050c00c000555500000000940000000056776665555575555567665556677665
4444440440044044444400444400444440000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
9900000990099000990009900990990099000000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
aa000000aaaa0000aa000aa00aa0aa00aa00000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
7777000007700000770007777770777770000000d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
aa000000aaaa0000aa000aa00aa0aa00aa000000dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
9900000990099000990009900990990099000000211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
444444044004400044000440044044004400000020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00000000000000000000000000000000000000002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
b3b00b3b0bbbbbb00000000000000900aaaaaaaaaaaaaaaa99449944444444449999999955555555555555555556555555565556dd5555dd0000000000088000
b039930bbbb33bbb0000000000009a90aaa999aaaaaa99aa94449444444444449944449955565566655665565665556555655565d566665d0000000000800800
00999200b33bb33b0000000000000900aaaaaa9aaaaaaa9a44444444444444444444444466666666666666665566565556555655566666650000000008099080
00944200b393323b0000090000e00b00aa9aaa9a99aaaaaa14141414994499449911119956556555665556555655555565556555566666650000000080900908
009992000099920000909a900eae0300a9aaa9aaaa9aaaaa41414141944494449411114966666666666666665555566555565556566666650000000080900908
099999200444992009a9090000e00300a9aaaaaaaaaaa9aa111111114444444499111199556656556555655655556555556555655d6666d50000000008099080
044499200999992000900b0000b00300aa99aaaaaa999aaa00000000444444444411114466666666666666665665556656555655d5dddd5d0000000000800800
029992200299922000b0030000300300aaaaaaaaaaaaaaaa00000000444444449911119955555555555555556555555665556555dd5555dd0000000000088000
00000000002222200777000000044000000aa000007000000777700000bbbbbbbbbbbbbbbbbbbb005555555555555555000000000000000000000bbb00990000
2222222202944442067770000049940000a7aa0000700000070070000b333b333b333b3333b333b065566556655665560000000000000000000b3b3b00049000
44444444029999420677770000444200007aa90000700000070070000b34333433343334433343b06666666666666666000000000000000000bbb3bb09094090
44444444022222220677777000494200007aa9007770000077077000b3444444444444444444443b66666666666666550b00000000000000003b3b3094994949
222222220294949206777700004992000a7aaa907770000077077000b3344444444444444444433b6666666666666655b0b0bb00000000000bb3bbb099494490
222222220294949206777000004942000aaa99900000000000000000bb34444444444444444443bb666666666555666600b0b0b0000000000b3b3b0009949900
2442442402949492066600000049920000666d000000000000000000b3344224422442244224433b6556655665556556000b0000077707703bbb000000949000
22422424002222200000000000042200000000000000000000000000b3222222222222222222223b5555555555555555000b0000777777773300000000040000
00aaa900000ee0000000000000800000000008000000000000000000008008000000000000808000000000000fffff000fffff000fffff00002ee20000000000
00666d000eeaaee0000ee0000877000000007780000008000007000000088000000000000008800000000800f44444f0f44444f0f44444f002222220002ee200
067176d00eeaaee00eeaaee0a717000770f0717a70007780000770700088e800080880800088e80008088000f4fff4f0f4fff4f0f4fff4f0047ff74002222220
6771766db0beeb0b0eeaaee00877777777ff77807777717a0004007708888e800088e80008888e800088e800f4f4f4f0f4f4f4f0f4f4f4f0471ff17404ffff40
6771116db3bbbb3b0bbeebb0077fff7777fff77077fff780009994400818818008888e800818888008888e80f4f444f0f4f444f0f4f444f00ffffff0471ff174
6777766d3bb1b1bb33bb1b1b077ff770077f7770077ff7700949994002888e8001888e100288888001888e80f4ff22f0f4ff1e10f4fff1e1002222000ffffff0
067766d03bbbbbbb33bbbbbb0077770000777a0000a77700099494400288888002888880022288800222888044422220444feee0444feeee00eeee0000eeee00
00666d000333333003333330000a0a0000a000000000a00009944400002228000022280000222200002222000422220004eeeee004eeeeee0040040000400400
0002ee20002ee200002ee2000000000000000000002ee2000022ee00000000000022ee000022ee000022ee00022ee00000000000002222000000000002222000
002222220222222002222220002ee2000000000002222220022222200022ee00022222200222222002222220222222000022ee00022222200022220022222200
0447ff74047ff760014ff4100222222000000000071ff170044447f002222220044447f0044447f0044447604441ff0002222220044444400222222044444440
0471ff17471ff1644f1ff1f401ffff1000000000477ff774044f71f004444ff0044f71f0044f71f0044f716044ff1d0004441ff04f4444f404444440f4444f40
00ffffff0ffffd6d0fffffd04f1ff1f4002ee2000ffffff000fffff0044f71f000fffff000fffff000fffd6d0ff4d666044ff1f00ffffff04f4444f4ffffff00
00222200002222d000222d6d0ffffff002222220002222000022220000fffff00022220000222200002222d002222d0000fffff0002222000ffffff000222200
00eee40000eeee4000eeee6000eeee00011ff11000eeee0000eeee0000eeee0000eee400004eee0000eeee400eeee00000eeee0000eeee0000eeee0004eeee00
004000000040040000400460004004004ffffff40040040000400400004004000040000000000400004004000400400000400400004004000040040000000400
__gff__
0001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000170000200000202000
01010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d8d8d8d8d8d8d8c8d8d8d8d8d8d8d8d8
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900090900000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000909000900000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090909090000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090909090000090009000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090009000900090909090900
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000909090009000000000900000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900090009090000000909000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000090909000009000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000009000009000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101019c01010101010101010101
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101013c019c0101013c010101013c01
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101ac8d8d8e01013f3f3f3f01
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101019c01013fdada3f01
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001013c01010101019c01013fdadb3f01
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b3b3b3b3b3b3b3b9c3b3b3fdada3f3b
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090000000009090909000000090909
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090900090909090909090909090909
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090909090909090909090909090000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090909090909090909000000090909
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090909000000000000000000000909
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6
__sfx__
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
010c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
01 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
