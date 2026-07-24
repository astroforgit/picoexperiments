pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- a deck building game
-- by sebastian lind

m_t="ç music off"
a_n_t="ã auto next"
a_a_t="Ç auto attack"
function _init()
	load_save()
	menuitem(1,m_t..is_on(music_off), function() toggle_music() end)
	menuitem(2,a_n_t..is_on(auto_next), function() toggle_auto_next() end)
	menuitem(3,a_a_t..is_on(auto_attack), function() toggle_auto_attack() end)
	if (not music_off)music(1,300)

	pal(0, 129, 1)
end

function is_on(boolean) 
	if boolean then 
		return ":á"
	end
	return ":Ö"
end

function bool_to_num(value)
  return value and 1 or 0
end

function num_to_bool(value)
  return value==1 and true or false
end

function change_menu(bool,menu_i)
	bool=not bool
	sfx(1)
	dset(6+menu_i,bool_to_num(bool))
	return bool
end

function toggle_auto_next()
	auto_next=change_menu(auto_next,2)
	menuitem(2,a_n_t..is_on(auto_next),function() toggle_auto_next()  end)
end

function toggle_music()
	music_off=change_menu(music_off,1)
	if music_off then
		music(0,200)
	else
		music(game_state == 0 and 1 or 11,200)
	end
	menuitem(1,m_t..is_on(music_off),function() toggle_music()  end)
end

function toggle_auto_attack()
	auto_attack=change_menu(auto_attack,3)
	menuitem(3,a_a_t..is_on(auto_attack),function() toggle_auto_attack()  end)
end

function reset_match()
 play_cards,lane_cards,graveyard,game_state={},{},{},1
end

function start_match(boss_id)
	if(not music_off)music(11,200)
	sfx(1)
	ba_unlock_s,bo_unlock_s,tim,lane_i="","",0,0
	shake+=0.1
	for i=0,20 do
		init_particle(rnd(128),rnd(128),30+rnd(30),0,0,-4-rnd(3))
	end
	init_boss(boss_id)
	reset_stats(true)
	shuffle(deck)
	shuffle(lane_deck)
	start_lane(2)
end

function start_lane(total)
	local m_total=0
	local i=1
	while (#lane_cards < 4) do
		init_card(get_next_lane_index(),i,false)
		if lane_cards[i].type == 2 then
				if m_total < total then
					m_total+=1
					i+=1
				else
					del(lane_cards,lane_cards[i])
				end
		else
			i+=1
		end
	end
	init_card(3,5,false)
end

function _update60()
	tim = time()
	handle_game_over()
	if game_state == 1 then
		is_draw_ready,is_shuffle_ready,is_grave_ready=can_draw(),can_shuffle(),can_grave()
		update_heart()
		update_shield()
		update_boss()
		handle_graveyard()
		handle_turn_over()
	end
	foreach(play_cards,update_card)
	foreach(lane_cards,update_card)
	foreach(resources,update_resource)
	foreach(card_effects,update_card_effect)
	foreach(particles,update_particle)

	if game_state == 0 then
		handle_menu()
	elseif game_state == 1 then
		if not card_played and not next_turn and not graveyard_show and confirm==-1 then
			if (btnp(ã) or btnp(ë)) change_selected()
			if (btnp(î) or btnp(É)) change_row()
			if btnp(4) then
				if is_draw_ready then
					draw_from_deck()
				elseif is_shuffle_ready then
					shuffle_deck()
				elseif is_grave_ready and not graveyard_show then
					show_graveyard()
				elseif b_select == 1 and row_select == 2 then
					attack_boss()
				end
			end
		end
		handle_confirm_box()
		react_to_confirmation()
	elseif game_state == 2 then
		update_xp()
	end
end

function _draw()
 cls(0)
 for c=0,255 do
  spr(graveyard_show and 198 or (207+background_id),c%16*8,flr(c/16)*8)
 end
 if game_state == 0 then
	draw_menu()
 else
	draw_game()
 end
end

function drawp(p,func,...)
 fillp(p)
 func(...)
 fillp()
end

function draw_menu()
	local wave=sin(tim)*1.1
	camera(0,m_camera_y)
	spr(119,28,4-wave*2,9,6)

	print("ã choose background ë",18,88,menu_lane == 0 and 12 or 7)
	print("ã    choose boss    ë",18,96,menu_lane == 1 and 8 or 7)
	foreach(particles,draw_particle)
	if menu_lane == 0 then
		draw_b_menu()
	elseif menu_lane == 1 then
		draw_bo_menu()
	elseif menu_lane == 2 then
		drawp(0b0011001111001100.1,rectfill,30-bu_l_i,104,98+bu_l_i,120,1)
	elseif menu_lane == 3 then
		draw_about(wave)
	elseif menu_lane == -1 then
		draw_stats(wave)
	end

	rect(30-bu_l_i,104,98+bu_l_i,120,7)
	print("start" .. (menu_lane == 2 and " ó/é" or ""), menu_lane == 2 and 42 or 54,110,7)

	if(menu_lane > -1)spr(150,119,m_camera_y+4+wave)
	if(menu_lane < 3)spr(166,119,114+m_camera_y+3-wave)
end

function draw_b_menu()
	rectfill(0,64,128,80,0)
	for i=0,8 do
		spr(208+i,4+i*16,68)
		if (i >= back_unlock) spr(192,4+i*16,68)
		drawp(0b0011001111001100.1,rect,4+back_l_i*16-1,67,4+back_l_i*16+8,76,7)
	end
end

function draw_bo_menu()
	rectfill(0,64,128,80,0)
	local b=(1-boss_l_i)*16
	for i=0,7 do
		spr(224+i*2,8+i*24+b,64,2,2)
		if i >= boss_unlock then
			spr(193,1+i*24+b+12,68)
		end
	end
	print(boss_stats[boss_i][2], 8+boss_l_i*24-1+b,56,8)
	drawp(0b0011001111001100.1,rect,8+boss_l_i*24-1+b,63,8+boss_l_i*24+15+b,80,7)
end

-- this was painful to do, hopefully helpful for some!

htp_text = "\^icontrols\^-i\n\nmove cursor: ãëîÉ\naction button: é/z\nsecondary button: ó/x\n\n\^irules\^-i\n\nevery turn starts by you\ndrawing five cards from your\ndeck.\n\nyour deck always starts with\nthe same ten cards, seven\nmediocre bards and the three\ncommon guards.\n\nin order to win you will need\nto buy and defeat cards in the\nmiddle lane to build a better\ndeck.\n\nto do that,first draw from\nyour deck by pressing\nthe action button,then\nselect which card you want to\nplay and again press\nthe action button.\nafter that,select the monster\nor minion you want to\nslay/buy.\n\nif you want to read more about\nthe cards,press the secondary\nbutton on them at any time.\n\n"
htp_1 = "\^icards\^-i\n\nthere are three types of cards:\n\n\^wminions\^-w\n\ncost gold to buy and are\nindicated by the color of light\nblue or brown for common cards.\n\nwhen bought,they are put in the\ngraveyard and will be shuffled\nin the deck when there are no\ncards left to draw from your\ndeck.the effects of the minions are\nactivated when they are played.\n\n\^wmonsters\^-w\n\ncost attack to slay and are\nindicated by the color of\ndark purple.\n\nmonsters in the lane attack\nevery turn for one damage\nso keep that in mind.\nthe effects are played out\nwhen slaying them.\n\nafter doing its effects the\nmonster is removed from play.\n\n"
htp_2 = "\^wbosses\^-w\n\neach boss has different effects.\nthey will only attack when\ntheir criteria are met.\n\nthe criteria are always\ndepending how many turns\na player have taken.\nwhen the number of turns\ncorresponds to the criteria,\nthe boss will attack and\nthe turns will reset to zero.\n\nbosses will also boost up their\nattack,it follows a\nsimilar pattern to the\ncriteria.\n\non every turn end\nthe boss will add one\npoint to the boost,when all\nthe dots are filled up\nthe boss attack will increase\nand the dots will reset to zero.\n\none really important thing\nto keep in mind is to\nremember to attack the boss,\nthis will attack the boss\nwith your remaining attack\nso if you plan to slay monsters\ndo that first.\n\n* an option exist in the\npause menu to auto attack\non turn end.\n\n"
htp_3 = "\^iend turn\^-i\n\nif you have no cards left\nto play and you have done\neverything you planned this\nturn,press the action button on\nyour deck and the turn will end.\n\nthree things will always\nbe checked.\n\nfirst all your resources will\nreset (excluding block\nthat will reset last).\nthen if monsters exist in the\nlane they will attack.\nand lastly if the criteria of\nthe boss are met,it too\nwill attack.\n\nthen five new cards can be\ndrawn again and a\nnew turn starts.\n\n\^igame end\^-i\n\neach game will have you trying\nto reduce the current boss\nhealth to zero.\n\nif you manage that you will\nbe rewarded with lots of xp\nto unlock more bosses\nand backgrounds.\n\nif the boss manages to reduce\nyour health to zero the game\nends as well,only rewarding\nyou xp for how much health you\nmanaged to reduce\nfrom the boss.\n"
function draw_about(wave)
	print(htp_text..htp_1..htp_2..htp_3,2,m_camera_y+24+scroll_text_y,7)
	rectfill(0,m_camera_y,128,m_camera_y+18,0)
	print("how to play",1,4+m_camera_y,12)
	print("scroll text: ã ë",1,m_camera_y+12,13)
end

function draw_stats(wave)
	print("info",2,4+m_camera_y,14)
	local win_rate = games_won > 0 and flr(games_won / games_played * 100) or 0
	local stat_s= "level: " .. level .. "\n\nxp: " .. xp .. " / " .. xp_goal .. "\n\ngames played: " .. games_played .. "\n\nwin rate: " .. win_rate .. " %"
	print(stat_s,4,m_camera_y+18,7)
		print("this game was made by:\nsebastian lind @elastiskalinjen\n\nmusic/sfx:\njose ramon garcia @bibikigl\n\nmain tester:\nsimon lind @ytfftw",2,m_camera_y+72,14)
end

function draw_game()
	draw_grave_deck()

	if graveyard_show then
		draw_show_graveyard()
	else
		draw_boss()
		for i=1,max_cards_out do
			draw_card_line(d_s_x+2-i*20,d_l_y,i == 5 and 12 or 1)
		end
		for i=1,3 do
			circfill(5+i*5,80,1,i > g_pick and 1 or 12)
		end
		for i=1,max_cards_out do
			draw_card_line(d_s_x+2-i*20,d_s_y,2)
		end
		foreach(lane_cards,draw_card)
		foreach(play_cards,draw_card)

		if game_state == 1 then
			draw_deck()
			draw_lane_deck()
			draw_pointer()
			draw_confirm()
			draw_timer()
		end
	end

	doshake()
	foreach(card_effects,draw_card_effect)
	draw_ui()
	foreach(particles,draw_particle)
	foreach(resources,draw_resource)

	if (game_state == 2 and level_delay <=10) draw_xp()
end

local function splitd(input, delim, ...)
 local out, pos = {}, 0
 if type(input) == "string" then
  local item
  for i = 1, #input do
   if sub(input, i, i) == delim then
    item = sub(input, pos, i - 1)
    add(out, tonum(item) or item)
    pos = i + 1
   end
  end
  item = sub(input, pos)
  add(out, tonum(item) or item)
 end
 if ... then
  for i = 1, #out do
   out[i] = splitd(out[i], ...)
  end
 end
 return out
end


-->8
-- gameplay

function reset_stats(start)
	if start then
		row_select,c_select,l_select,b_select,active_card_index,grave_index,deck_index,max_cards_out,start_draws,turns,next_turn,next_turn_timer=0,0,1,1,-1,1,0,5,5,0,false,0
		deck={1,1,1,1,1,1,1,2,2,2}
  	play_area,r_draws,r_health,r_block,g_pick,r_attack={false,false,false,false,false},start_draws,30,0,0,0
	else
		r_draws=0
	end
	r_gold,r_destroy,r_remove,r_discard,r_gravedig,r_convert,r_boost=0,0,0,0,0,0,0,0
end

function attack_boss()
 sfx(r_attack>0 and 0 or 5)
	boss_health-=r_attack
	shake=0.1
	for i=1,r_attack do
		init_particle(boss_x+rnd(74),boss_y+rnd(card_s_h),3+rnd(3),8)
	end
	boss_h_y,r_attack=r_attack,0
end

function show_graveyard()
	sfx(1)
	graveyard_show,grave_index=true,1
	for c in all(graveyard) do
		c.y,c.x,c.w,c.h=card_r_y,card_r_x,card_r_w,card_r_h
		c.state=5
	end
end

function go_to_next_turn()
	next_turn,confirm=true,-1
	turns+=1
	reset_stats(false)
	next_turn_timer=180
end

timer_y,block_t=130,0
function handle_turn_over()
	if next_turn_timer > 0 then
		timer_y = lerp(timer_y,49,0.3)
		if next_turn_timer == 1 then
			if(r_block < 0)block_t+=1
			if (r_block > 0 or block_t > 1) r_block,block_t=0,0
			next_turn=false
			b_select,row_select=0,0
		elseif next_turn_timer == 30 then
			check_turn_boss()
		elseif next_turn_timer == 60 then
			if r_attack > 0 and auto_attack then
				b_select,row_select=1,2
				attack_boss()
			else
				r_attack=0
			end
		elseif next_turn_timer == 64 then 
			if (auto_attack)b_select,row_select=1,2
		elseif next_turn_timer == 120 then
			sfx(1)
			local a=false
			for c in all(lane_cards) do
				if c.type == 2 then
					a=true
					shake+=0.05
					init_resource("o",218,c.x,c.y-4)
					init_particle(c.x+rnd(c.w),c.y+rnd(c.h),1+rnd(2),6)
				end
			end
			if (a)sfx(0)
		elseif next_turn_timer == 150 then
			draw_from_deck()
		elseif next_turn_timer == 180 then
			r_draws=5
			for c in all(play_cards) do
				c.state=4
			end
			if is_shuffle_ready then 
				shuffle_deck()
			end
		end
		next_turn_timer-=1
	else
		timer_y=lerp(timer_y,130,0.2)
	end
end

function handle_game_over()
	if game_state == 1 and (r_health < 1 or boss_health < 1) then
		music(-1,300)
		game_state=2
		shake+=0.3
		for i=0,#deck do
			init_card_effect(d_s_x,d_s_y,rnd(128),rnd(128),2,8)
		end
		for c in all(lane_cards) do
			c.state=6
		end
		for c in all(play_cards) do
			c.state=6
		end
		games_played+=1
		dset(5,games_played)
		if boss_health <= 0 then
			sfx(6)
			games_won+=1
			dset(6,games_won)
		else
			sfx(7)
		end
		get_xp()
	end

	if game_state == 2 and c_xp == xp then
		if btnp(4) then
			reset_match()
			start_match(boss_i)
		end
		if btnp(5) then
			sfx(2)
			reset_match()
			if(not music_off)music(1,300)
			menu_lane,game_state=0,0
		end
	end
end

function shuffle_deck()
	if #graveyard > 0 then
		sfx(9)
		deck_index,deck=0,{}
		shake+=0.05
		for c in all(graveyard) do
			add(deck,c.id)
			init_card_effect(grave_x+rnd(4),grave_y+rnd(4),d_s_x,d_s_y,2,8)
		end
		graveyard={}
		shuffle(deck)
	end
end

function handle_graveyard()
	grave_x=lerp(grave_x,row_select == 2 and b_select == 0 and grave_s_x-16 or grave_s_x,0.1)

	if graveyard_show then
		if btnp(4) then
			dig_the_grave()
		elseif btnp(5) then
			sfx(2)
			graveyard_show=false
		end

		for c in all(graveyard) do
			c.y=lerp(c.y,card_r_y,0.1)
		end
		if btnp(ë) then
			sfx(4)
			if grave_index < #graveyard then
				grave_index+=1
			else
				grave_index=1
			end
			graveyard[grave_index].y=48
		elseif btnp(ã) then
			sfx(4)
			if grave_index > 1 then
				grave_index-=1
			else
				grave_index=#graveyard
			end
			graveyard[grave_index].y=48
		end
	end
end

function dig_the_grave()
	if can_grave_dig() then
		sfx(1)
		r_gravedig-=1
		local remove_i=grave_index
		grave_index=1
		local play_area_index = find_a_card_position()
		if play_area_index ~= -1 then
			init_card(graveyard[remove_i].id,play_area_index,true)
		end
		del(graveyard,graveyard[remove_i])
	end
end

function draw_from_deck()
	sfx(3)
	for i=1, #play_area do
		if can_draw() and not play_area[i] then
			local play_area_index = find_a_card_position()
			if play_area_index ~= -1 then
				deck_index+=1
				r_draws-=1
				init_card(deck[deck_index],play_area_index,true)
			end
		end
	end
end

function get_next_lane_index()
	if lane_i == #lane_deck then
		lane_i=0
		shuffle(lane_deck)
	end
	lane_i+=1
	return lane_deck[lane_i]
end

function change_row()
	if btnp(î) then
		if row_select < 2 then
			row_select+=1
			sfx(4)
		end
	end
	if btnp(É) then
		if row_select > 0 then
			row_select-=1
			sfx(4)
		end
	end
	if row_select ~= 0 then
		for i=1,#play_cards do
			play_cards[i].active=false
		end
	end
	if row_select ~= 1 then
		for i=1,#lane_cards do
			lane_cards[i].active=false
		end
	end
	highlight_active_card()
end

function change_selected()
	if #play_cards == 0 and row_select == 0 then
		c_select = 0
		return
	end

	if btnp(ë) then
		sfx(4)
		if row_select == 0 then
			if c_select-1 == -1 then
				c_select = #play_area+1
			end
			c_select = find_next_card_in_area(c_select-1,-1)
		elseif row_select == 1 then
   l_select = (l_select-2)%#play_area+1
		elseif row_select == 2 then
   b_select = 1-b_select
		end
	elseif btnp(ã) then
		sfx(4)
		if row_select == 0 then
			c_select = find_next_card_in_area(c_select+1,1)
		elseif row_select == 1 then
   l_select = l_select%#play_area+1
		elseif row_select == 2 then
   b_select = 1-b_select
		end
	end
	highlight_active_card()
end

function highlight_active_card()
	if row_select == 0 then
		active_card_index=-1
		for i=1,#play_cards do
			if play_cards[i].play_index == c_select then
				play_cards[i].active=true
				active_card_index=i
			else
				play_cards[i].active=false
			end
		end
	elseif row_select == 1 then
		active_card_index=-1
		for i=1,#lane_cards do
			if lane_cards[i].play_index == l_select then
				lane_cards[i].active=true
				active_card_index=i
			else
				lane_cards[i].active=false
			end
		end
	end
end

function find_a_card_position()
	for i=1, #play_area do
		if not play_area[i] then
			play_area[i]=true
			return i
		end
	end
	return -1
end

function find_next_card_in_area(index,dir)
	if index == 0 or index > #play_area then
		return 0
	elseif play_area[index] then
		return index
	else
		return find_next_card_in_area(index+dir,dir)
	end
end

function react_to_confirmation()
	if btnp(5) and not next_turn and ((c_select == 0 and row_select == 0) or (b_select == 1 and row_select == 2)) then
		if confirm == -1 then
			if (b_select == 1 and row_select == 2) or check_resources_resources_left() then
				confirm=0
			else 
				confirm=1
			end
			sfx(1)
		elseif confirm == 2 then
			confirm=-1
		end
	end

	if confirm == 1 then
		if b_select == 1 and row_select == 2 then
			r_health,confirm=0,-1
		elseif c_select == 0 and row_select == 0 then
			go_to_next_turn()
		end
	end
end

function check_resources_resources_left() 
	local monsters=0
	local mineons=0
	for e in all(lane_cards) do 
		if e.type == 2 and r_attack >= e.cost then
			monsters+=1
		elseif e.type <= 1 and r_gold >= e.cost then
			mineons+=1
		end
	end

	return r_draws > 0 or (r_attack > 0 and monsters > 0) or (r_gold > 0 and mineons > 0) 
	or (r_gravedig > 0 and #graveyard > 1) or (r_convert > 0 and monsters > 0) or #play_cards > 0
	or (r_attack > 0 and not auto_attack)
end

confirm,confirm_y=-1,150
function handle_confirm_box()
	if confirm == 0 then
		confirm_y=lerp(confirm_y,40,0.2)
		if btnp(4) then
			confirm=1
			sfx(1)
		end
		if btnp(5) then
			confirm=2
			sfx(2)
		end
	else
		confirm_y=lerp(confirm_y,150,0.2)
	end
end

function can_draw()
	return deck_index < #deck and
	#play_cards < max_cards_out and
	c_select == 0 and
	row_select == 0 and
	not card_played and r_draws > 0
end

function can_shuffle()
	return c_select == 0 and
	row_select == 0 and
	deck_index == #deck
end

function can_grave()
	return b_select == 0 and
	row_select == 2 and
	#graveyard > 0
end

function can_grave_dig()
	return r_gravedig > 0 and
	#play_cards < max_cards_out and
	#graveyard > 1
end

background_id,boss_i,menu_lane,m_camera_y,back_l_i,boss_l_i,bu_l_i,scroll_text_y,scroll_text_sp=1,1,0,0,0,0,0,0,0.4
function handle_menu()
	if btnp(2) and menu_lane > -1 then
		scroll_text_y=0
		menu_lane-=1
		sfx(4)
	end
	if btnp(3) and menu_lane < 3 then
		menu_lane+=1
		sfx(4)
	end

	if menu_lane == 0 then
		if btnp(0) and background_id > 1 then
			background_id-=1
			sfx(4)
		end
		if btnp(1) and background_id < back_unlock then
			background_id+=1
			sfx(4)
		end
		back_l_i=lerp(back_l_i,background_id-1+0.05,0.2)
	elseif menu_lane == 1 then
		if btnp(0) and boss_i > 1 then
			boss_i-=1
			sfx(4)
		end
		if btnp(1) and boss_i < boss_unlock then
			boss_i+=1
			sfx(4)
		end
		boss_l_i=lerp(boss_l_i,boss_i-1+0.05,0.2)
	elseif menu_lane == 2 then
		if btnp(4) or btnp(5) then
			reset_match()
			start_match(boss_i)
		end
	elseif menu_lane == 3 then
		if btn(0) then
			if(scroll_text_sp < 1.2)scroll_text_sp+=0.01 
			if(scroll_text_y < 0)scroll_text_y +=scroll_text_sp
		elseif btn(1)  then
			if(scroll_text_sp < 1.2)scroll_text_sp+=0.01
			if(scroll_text_y > -800)scroll_text_y -=scroll_text_sp
		else
			if(scroll_text_sp > 0.4)scroll_text_sp-=0.02
		end
	elseif menu_lane == -1 then
		if (flr(tim * 1000) % 2 == 0)init_particle(rnd(128),rnd(128)-128,5+rnd(5),2,0,-2-rnd(3))
	end

	if menu_lane == 2 then
		bu_l_i=lerp(bu_l_i,12,0.2)
	else
		bu_l_i=lerp(bu_l_i,0,0.2)
	end

	if menu_lane < 0 then
		m_camera_y=lerp(m_camera_y,-128,0.15)
	elseif menu_lane > 2 then
		m_camera_y=lerp(m_camera_y,128,0.15)
	else
		m_camera_y=lerp(m_camera_y,0,0.15)
	end
end

-->8
-- draw

grave_s_x,grave_x,grave_y,gold_x,attack_x,block_x,draw_x,discard_x,destroy_x,remove_x,health_x=114,114,24,1,19,37,55,73,91,109,120
function draw_ui()
rectfill(0,121,128,128,1)
print(get_action_string(),2,122,7)

rectfill(0,0,128,8,1)
spr(1,gold_x,0)
print(r_gold,10,2,10)

spr(2,attack_x,0)
print(r_attack,28,2,6)

spr(8,block_x,sh_time/10)
print(r_block,47,2,13)

spr(3,draw_x,0)
print(r_draws,64,2,2)

spr(9,discard_x,0)
print(r_discard,82,2,5)

spr(4,destroy_x,0)
print(r_destroy,100,2,9)

rectfill(109,0,128,19,1)

spr(6,remove_x,0)
print(r_remove,118,2,4)

spr(h_spr,110,11)
print(r_health,health_x,13,8)
end

function draw_card_line(x,y,c)
	rect(x-1,y-1,x+card_s_w+1,y+card_s_h+1,c)
end

function draw_deck()
	draw_card_line(d_s_x,d_s_y,0)
	if deck_index ~= #deck then
		rectfill(d_s_x,d_s_y,d_s_x+card_s_w,d_s_y+card_s_h,2)
		spr(196,d_s_x+2,d_s_y+8)
	end
	rect(d_s_x,d_s_y,d_s_x+card_s_w,d_s_y+card_s_h,8)
	if c_select == 0 and row_select == 0 then
		drawp(0b0011001111001100.1,rect,d_s_x-1,d_s_y-1,d_s_x+card_s_w+1,d_s_y+card_s_h+1,not is_draw_ready and 14 or 7)
		print("d:"..#deck - deck_index, d_s_x-1, d_s_y-8,14)
	elseif r_draws > 0 then
		rect(d_s_x-1,d_s_y-1,d_s_x+card_s_w+1,d_s_y+card_s_h+1,14)
	end
end

function draw_lane_deck()
	if not card_read then
		if lane_i < #lane_deck then
			rectfill(l_d_s_x,d_l_y,l_d_s_x+card_s_w,d_l_y+card_s_h,1)
			spr(197,l_d_s_x+2,d_l_y+8)
		end
		rect(l_d_s_x,d_l_y,l_d_s_x+card_s_w,d_l_y+card_s_h,12)
		draw_card_line(l_d_s_x,d_l_y,0)
	end
end

function draw_grave_deck()
	if #graveyard > 0 then
		rectfill(grave_x,grave_y-1,grave_x+card_s_h,grave_y+card_s_w,5)
		rect(grave_x+1,grave_y,grave_x+card_s_h-1,grave_y+card_s_w-1,1)
	end
	if r_gravedig > 0 and not graveyard_show then 
		spr(5,grave_x-9,grave_y+2)
	end
	spr(15,grave_x+4,grave_y+2)
	drawp(row_select == 2 and b_select == 0 and 0b0011001111001100.1 or nil,rect,grave_x,grave_y-1,grave_x+card_s_h,grave_y+card_s_w,6)
end

function get_action_string()
	if (game_state == 2 and c_xp == xp) return "é = retry | ó = back to menu"
	if game_state == 1 then
		if c_select == 0 and row_select == 0 then
   return (is_draw_ready and "é = draw" or
          (is_shuffle_ready and "é = shuffle" or
          (#play_cards == max_cards_out and "å = area full" or
          (r_draws == 0 and "å = no draws" or
          "")))) .. " | ó = end turn"
		else
			if card_read then
				return "ó = close"
			elseif row_select == 0 then
    return (r_discard > 0 and "é = discard" or
           (r_destroy > 0 and "é = destroy" or
            "é = play")) .. " | ó = " .. (card_choose and "cancel" or "read")
			elseif row_select == 1 then
    return (r_convert > 0 and lane_cards[active_card_index].type == 2 and "é = convert" or
           (r_remove == 0 and
            (lane_cards[active_card_index].type ~= 2 and
             (r_gold >= lane_cards[active_card_index].cost and "é = buy" or "å = coins missing") or
             (r_attack >= lane_cards[active_card_index].cost and "é = slay" or "å = attack missing")) or
            "é = remove")) .. " | ó = " .. (card_choose and "cancel" or "read")
			elseif row_select == 2 then
    return (b_select == 0 and
            (graveyard_show and
             (can_grave_dig() and "é = dig grave | " or
             (r_gravedig > 0 and #play_cards == max_cards_out and "å = play area full | " or
             (r_gravedig > 0 and #graveyard == 1 and "å = 1 card left | " or ""))
            ) .. "ó = close" or
            (is_grave_ready and "é = show graveyard" or "å = no cards in graveyard")) or
           (r_attack > 0 and "é = attack" or "å = no attack") .. " | ó = forfeit")
			end
		end
	else
		return ""
	end
end

function draw_timer()
	if timer_y < 128 then
		local anim=2*(3-flr(next_turn_timer/60))-2
		spr(160+anim,56,timer_y+4,2,2)
		spr(216,2,100 - anim*20)
	end
end

function draw_pointer()
	if play_cards ~= nil and play_area[c_select] == false then
		spr(row_select==0 and 13 or 14,card_s_x+2-((c_select-1)*20),d_s_y+10)
	end
end

function draw_confirm()
	rectfill(0,confirm_y,128,confirm_y+32,2)
	local is_deck_selected = c_select == 0 and row_select == 0
	local c_text = is_deck_selected and "end turn?" or "forfeit?"
	local d_text = is_deck_selected and "you have resources left" or " sure you want to give up?"
	print(d_text, is_deck_selected and 16 or 7, confirm_y+15,is_deck_selected and 9 or 14)
	print(c_text,46,confirm_y+4,7)
	print("é = yes | ó = no", 26, confirm_y+26,7)
end

function draw_show_graveyard()
	print(grave_index ..  " of " .. #graveyard .. " is shown",4,32,6)
	draw_card(graveyard[grave_index])
	print("ã/ë browse cards",4,graveyard[grave_index].y+52,7)
	if r_gravedig > 0 then 
		print("shovels left: ", 4,14,6)
	end
	for i=0,r_gravedig-1 do 
		spr(5,56+i*10,12)
	end
end

-->8
-- play_cards
d_s_x,d_s_y,d_e_y,l_d_s_x,l_d_s_y,d_l_x,d_l_y=107,93,81,107,48,89,52
card_s_x,card_s_y,card_s_h,card_s_w=89,93,24,12

--play
card_dp_y=52 --deck
card_lp_y=20 --lane

card_r_y,card_r_x,card_r_w,card_r_h,card_played,card_read,card_destroyed,card_choose=42,2,124,46,false,false,false,false

reset_match()

game_state=0

function init_card(id,play_index,is_in_deck)
	local the_card=all_cards[id]

	local c={
		is_in_deck=is_in_deck,
		x=is_in_deck and d_s_x or l_d_s_x,
		y=is_in_deck and d_s_y-4 or l_d_s_y,
		ex=is_in_deck and card_s_x-((play_index-1)*20) or d_l_x-((play_index-1)*20),
		ey=is_in_deck and card_s_y or d_l_y,
		id=id,
		im_id=15+id+((flr((id-1)/16))*16),
		cost=the_card[1],
		name=the_card[2],
		type=the_card[3],
		effects=parse_effects(the_card[4]),
		play_index=play_index,
		active=false,
		state=0,
		w=card_s_w,
		h=card_s_h,
		pc=8,
	}

	c.s_desc = c.type >= 2 and not is_in_deck and "when slain:" or "when played:" 
	c.desc,c.col,c.hcol,c.ccol=get_effects_desc_id(c.effects),parse_type_col(c.type)

	add(is_in_deck and play_cards or lane_cards,c)
end

function card_intro_s(c)
	if distance(c.x,c.y,c.ex,c.ey) > 0.5 then
		c.x,c.y,c.w,c.h=lerp(c.x,c.ex,0.1),lerp(c.y,c.ey,0.1),lerp(c.w,card_s_w,0.2),lerp(c.h,card_s_h,0.2)
	else
		c.x,c.y,c.w,c.h=c.ex,c.ey,card_s_w,card_s_h
		c.state=1
	end
end

function card_idle_s(c)
	if c.active then
		c.y=lerp(c.y,c.ey-8,0.1)
		if not card_played then
			if btnp(4) then -- play
				local fail=false
				if c.is_in_deck then
					if r_discard > 0 or r_destroy > 0 then
						card_choose,c.state=true,8
					else
						c.state=2
					end
					card_played=true
				elseif c.type == 2 and not c.is_in_deck and r_convert > 0 then -- convert
					card_played,c.state=true,2
				elseif c.type >= 1 and not c.is_in_deck and r_remove > 0 then --destroy mid
					card_choose,card_played,c.state=true,true,8
				elseif c.type <= 1 and r_gold >= c.cost then --buy
					card_played,c.state=true,2
				elseif c.type == 2 and r_attack >= c.cost then --slay
					sfx(0)
					card_played,c.state=true,2
				else
					fail=true
					shake+=0.06
				end
    sfx(fail and 5 or 1)
			end
			if btnp(5) then --read
				sfx(2)
				card_played,card_read,c.state=true,true,5
			end
		end
	else
		c.y=lerp(c.y,c.ey+1,0.5)
	end
end

function card_choose_s(c)
	c.y=lerp(c.y,c.is_in_deck and d_s_y-12+sin(tim)*2 or l_d_s_y-12+sin(tim)*2,0.4)
	if btnp(4) then
		sfx(1)
		if c.is_in_deck then
			if r_discard > 0 then
				c.state=4
				r_discard-=1
			elseif r_destroy > 0 then
				r_destroy-=1
				card_destroyed,c.state=true,4
			else
				c.state=2
			end
		else
			r_remove-=1
			card_destroyed,card_played,c.state=true,true,4
		end
	end
	if btnp(5) then
		card_played,card_choose,c.state=false,false,0
		sfx(2)
	end
end

function card_play_s(c)
	local dest = c.is_in_deck and card_dp_y or card_lp_y
	c.y=lerp(c.y,dest,0.3)
	if (c.y < dest+2)c.state = 3
end

function card_action_s(c)
local init_resources=false
	if c.is_in_deck then
		init_resources=true
	else
		if c.type <= 1 then
			r_gold-=c.cost
			init_particle(grave_x,grave_y,1+rnd(3),6)
			add(graveyard,c)
		elseif c.type == 2 then
			if r_convert > 0 then
				r_convert-=1
				shake+=0.075
				init_particle(grave_x,grave_y,1+rnd(3),6)
				add(graveyard,c)
			else
				r_attack-=c.cost
				shake+=0.05
				init_resources=true
			end
		end
	end
	if init_resources then
		for e in all(c.effects) do
			for i=1,e.num do
				init_resource(e.id,e.s_id,c.x+rnd(c.w),c.y+rnd(c.h))
			end
		end
	end
	c.state = 4
end

function card_destroy_s(c)
	card_played,card_read,card_choose=false,false,false

	if c.is_in_deck then
		play_area[c.play_index]=false
		if not card_destroyed then
			add(graveyard,c)
			init_particle(grave_x+rnd(c.w),grave_y+rnd(c.h),1+rnd(2),6)
		end
		del(play_cards,c)
	else
		del(lane_cards,c)
		local id=1
		if c.play_index == 5 and g_pick < 3 then
			id=3
			g_pick+=1
		else
			id=get_next_lane_index()
		end
		init_card(id,c.play_index,false)
		change_selected()
	end

	if not card_destroyed then
		for i=0,4 do
			init_particle(c.x+rnd(c.w),c.y+rnd(c.h),1+rnd(2),random_col(0,c.hcol,c.col))
		end
	else
		sfx(10)
		shake+=0.1
		for i=0,10 do
			init_particle(c.x+rnd(c.w),c.y+rnd(c.h),2+rnd(4),random_col(0,8,9),rnd(4)-2,-3+rnd(2))
		end
		card_destroyed=false
	end

	if row_select == 0 and auto_next then 
		c_select = find_next_card_in_area(c_select,1)
		highlight_active_card()
	end
end

function card_read_s(c)
	c.y,c.x,c.w,c.h=lerp(c.y,card_r_y,0.4),lerp(c.x,card_r_x,0.4),lerp(c.w,card_r_w,0.3),lerp(c.h,card_r_h,0.3)

	if btnp(5) then
		sfx(1)
		card_played,card_read,c.state=false,false,0
	end
end

function explode_card(c)
		init_particle(c.x+rnd(c.w),c.y+rnd(c.h),1+rnd(2),6)
		c.ex+=rnd(100)-rnd(50)
		c.ey+=rnd(100)-rnd(50)
		c.state=7
end

function card_exploded(c)
	c.y,c.x=lerp(c.y,c.ey,0.3),lerp(c.x,c.ex,0.3)
	if c.pc > 0 then
		c.pc-=1
	else
		init_particle(c.x+rnd(c.w),c.y+rnd(c.h),1+rnd(2),random_col(1,5,0),0,-3)
		c.pc=8
	end
end

local update_card_funcs={[0]=card_intro_s,card_idle_s,card_play_s,card_action_s,card_destroy_s,card_read_s,explode_card,card_exploded,card_choose_s}

function update_card(c)
 update_card_funcs[c.state](c)
end

function draw_card(c)
	if (card_read == true and c.state == 5) or card_read == false then
		rectfill(c.x,c.y,c.x+c.w,c.y+c.h,c.col)

		line(c.x,c.y,c.x+c.w,c.y,c.hcol)
		rectfill(c.x+1,c.y+4,c.x+10,c.y+24,0)
		line(c.x+1,c.y+4,c.x+10,c.y+4,1)
		spr(c.im_id,c.x+2,c.y+8,1,2)
		print(c.cost,c.x+1,c.y+1,c.ccol)

		drawp(c.active and 0b0011001111001100.1 or nil,line,c.x,c.y+c.h,c.x+c.w,c.y+c.h,1)

		if c.active then
   local hcol = row_select == 0 and (r_destroy > 0 and 8 or (r_discard > 0 and 12 or 7)) or (row_select == 1 and (r_convert > 0 and 13 or (r_remove > 0 and 2 or 7)))

			drawp(c.active and 0b0011001111001100.1 or nil,rect,c.x-1,c.y-1,c.x+c.w+1,c.y+c.h+1,hcol)
			if c.state ~=5 then
				rectfill(0,11,106,19,1)
				local eff=c.effects
				local x_b=1
				print(c.name,2,13,c.hcol)
				for e in all(c.effects) do
					for n=1,e.num do
						spr(e.s_id,(#c.name*3.5)+4+x_b*8,11)
						x_b+=1
					end
				end
				if r_convert > 0 and c.type == 2 and not c.is_in_deck then
					spr(221,c.x+2,c.y-10)
				end
			end
		end
		if c.state == 5 then --read
			if c.y < card_r_y+1 then
				print(c.name,c.x+card_s_w+4,c.y+4,7)
				print(c.s_desc,c.x+card_s_w+4,c.y+14,c.hcol)
				print(c.desc,c.x+card_s_w+4,c.y+21,7)
			end
			line(c.x+card_s_w+4,c.y+12,c.x+c.w-2,c.y+12,1)
			if not c.is_in_deck and c.type == 2 then
				spr(12,c.x+c.w-16,c.y+2)
				spr(218,c.x+c.w-8,c.y+2)
			end
		end
	else --not active
		if (c.is_in_deck) drawp(0b0011001111001100.1,rect,c.x+1,c.y+1,c.x+c.w-1,c.y+c.h-1,2)
	end
end

resources={}
function init_resource(id,spr,x,y)
	local r={
		id=id,
		spr=spr,
		x=x,
		y=y,
		speed=0.08+(flr(rnd(10))/100)
	}

	local col,ex,ey=0,8,-2
	if id == "c" then
		ex,col=gold_x,10
		r_gold+=1
	elseif id == "a" then
		ex,col=attack_x,7
		r_attack+=1
	elseif id == "d" then
		ex,col=draw_x,2
		r_draws+=1
	elseif id == "b" then
		ex,col=block_x,5
		r_block+=1
	elseif id == "t" then
		ex,col=discard_x,6
		r_discard+=1
	elseif id == "k" then
		ex,col=destroy_x,0
		r_destroy+=1
	elseif id == "h" then
		ex,ey,col=health_x-8,11,9
		r_health+=1
	elseif id == "r" then
		ex,col=remove_x,2
		r_remove+=1
	elseif id == "o" then
		if r_block > 0 then
			ex,ey,sh_time=block_x+rnd(4),rnd(6),50
			r_block-=1
			init_particle(block_x,2,2,2)
		else
			ey,ex=11,health_x-8
			r_health-=1
		end
		col=8
	elseif id == "g" then
		ex,ey,col=grave_x+2,16,4
		r_gravedig+=1
	elseif id == "m" then
		init_particle(gold_x,2,2,9)
		r_attack+=r_gold
		ex,r_gold,col=attack_x,0,9
	elseif id == "e" then
  	ex,ey,col=l_d_s_x+2,l_d_s_y+8,2
		r_convert+=1
	elseif id == "i" then
  	ex,ey,col=d_s_x+2,d_s_y+8,10
		for c in all(play_cards) do
			local need_re_desc=false
			for e in all(c.effects) do
				if e.id == "a" then
					e.num+=1
					need_re_desc,shake=true,0.1
					for i=0,4 do init_particle(c.x+rnd(card_s_w),c.y,2+rnd(2),8+rnd(2),0,-2-rnd(2)) end
				end
			end
			if (need_re_desc)c.desc=get_effects_desc_id(c.effects)
		end
	elseif id == "s" then
		init_particle(block_x,2,2,12)
		r_attack+=r_block
		ex,r_block,col=attack_x,0,13
	elseif id == "p" then
		init_particle(block_x,2,2,12)
		ex,col=block_x,5
		if (r_block > 0)r_block=0
		r_block-=1
	elseif id == "j" then
		for i=1,4 do
			lane_cards[i].state=4
		end
  	ex=l_d_s_x+2,l_d_s_y+8
	end
	r.ex,r.ey,r.tcol=ex,ey,col
	add(resources,r)
end

function update_resource(r)
	r.x,r.y=lerp(r.x,r.ex,r.speed),lerp(r.y,r.ey,r.speed)
	init_particle(r.x+4,r.y+4,1,r.tcol,0.01,0.01)
	if distance(r.x,r.y,r.ex,r.ey) <= 1 then
		if (r.tcol ~= 8)sfx(8)
		del(resources,r)
	end
end

function draw_resource(r)
	spr(r.spr,r.x,r.y)
end

-->8
--boss

boss_s_x=12
function init_boss(id)
	local boss_p=boss_stats[id]
	boss_turns,boss_name,boss_effects,boss_health,boss_b_threshold=boss_p[1],boss_p[2],parse_effects(boss_p[3]),boss_p[4],boss_p[5]
	boss_sprite,boss_y,boss_x,boss_i_y,boss_h_y,boss_s_y,boss_t_boost,boss_w,boss_s_hp=222+id*2,11,boss_s_x,0,0,0,0,86,boss_health
end


boss_stats=splitd("3,earl dracula,o4,42,3;2,baby sharky,o2t2,32,2;5,captain l,o1d1c1,48,1;2,number two,o2p3,40,4;4,gassy bat,o6j1,46,4;1,spitfire lama,o1k1,44,3;4,gloomy leo,o7e1,52,4;6,spark-Y,o6j1t1,60,2",";",",")

function update_boss()
	if (row_select == 2 and b_select == 1) or card_read or (row_select == 0 and c_select == 0) then
		boss_x,boss_i_y=lerp(boss_x,boss_s_x,0.1),lerp(boss_i_y,0,0.1)
		boss_s_y=3*abs(sin(0.4*tim))
		boss_h_y=lerp(boss_h_y,0,0.1)
	else
		boss_x,boss_i_y=lerp(boss_x,-68,0.2),lerp(boss_i_y,10,0.2)
	end
end

function check_turn_boss()
	if turns == boss_turns then
		sfx(0)
		for e in all(boss_effects) do
			for i=1,e.num do
				shake+=0.05
				init_particle(boss_x+rnd(74),boss_y+rnd(card_s_h),3+rnd(3),9)
				init_resource(e.id,e.s_id,boss_x+6,boss_y+4+rnd(16))
			end
		end
		boss_x+=24
		turns=0
	end

	boss_t_boost+=1
	sfx(54)
	if boss_t_boost == boss_b_threshold then
		boss_t_boost=0
		for e in all(boss_effects) do
			for i=1,e.num do
				if e.id == "o" then 
					e.num+=1
					break
				end
			end
		end
	end
end

function draw_boss()
	rectfill(boss_x,boss_y,boss_x+boss_w,boss_y+card_s_h+1,2)
	if (boss_health > 0) spr(boss_sprite,boss_x+2,boss_y+card_s_h-16+boss_s_y-boss_h_y,2,2)

	print(boss_name,boss_x+2,boss_y+2,8)

	drawp(row_select == 2 and b_select == 1 and 0b0011001111001100.1 or nil,rect,boss_x,boss_y,boss_x+boss_w,boss_y+card_s_h+1,8)

	print(boss_health,boss_x+77,boss_y+10+boss_i_y,8)
	spr(217,boss_x+77,boss_y+1+boss_i_y)
	print(turns,boss_x+70,boss_y+10+boss_i_y,9)
	spr(12,boss_x+68,boss_y+1+boss_i_y)

	if boss_x > -32 and boss_health > 0 then
		print(boss_turns.."  =",boss_x+20,boss_y+18,7)
		spr(12,boss_x+23,boss_y+16)
		local x_b,b_sp=1,0
		for e in all(boss_effects) do
			print(e.num,boss_x+23+b_sp+x_b*14,boss_y+18,7)
			if (e.num >= 10) b_sp+=4
			spr(e.s_id,boss_x+28+b_sp+x_b*14,boss_y+16)
			x_b+=1
		end
		local boss_l=#boss_name
		for i=0,boss_b_threshold-1 do
			local c=i < boss_t_boost and 8 or 1
			circfill(boss_x+16+boss_l*3+i*4, boss_y+3,1,c)
		end
	end
end

-->8
--help

function lerp(var,target,pow)
	return var+pow*(target-var)
end

function shuffle(tbl)
	for i=#tbl,2,-1 do
		local j = 1+flr(rnd(i))
		tbl[i],tbl[j] = tbl[j],tbl[i]
	end
	return tbl
end

shake=0
function doshake()
	local shakex,shakey=16-rnd(32),16-rnd(32)
	shakex*=shake
	shakey*=shake
	camera(shakex,shakey)
	shake=shake*0.95
	if(shake < 0.05)shake=0
	if(shake >= 0.3)shake=0.25
end

function distance(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

-->8
-- misc

h_time,h_spr=0,10
function update_heart()
	if r_health < 15 then
		if h_time < 60 then
			h_time+=1
		else
			h_time=0
			h_spr=21-h_spr
		end
	end
end

sh_time=0
function update_shield()
	if (sh_time > 0)sh_time-=1
end

function random_col(c1,c2,c3)
 return ({c1,c2,c3})[flr(rnd(3))+1]
end

--8
-- effects

particles={}
function init_particle(x,y,rad,col,dx,dy)
	local p={
		x=x,
		y=y,
		dx=dx or rnd(2)-1,
		dy=dy or rnd(2)-1,
		rad=rad,
		col=col,
		sp=rad > 20 and 0.8 or 0.1,
	}
	add(particles,p)
end

function update_particle(p)
	p.dx*=0.9
	p.dy*=0.9
 p.x+=p.dx
 p.y+=p.dy
	p.sp+=rnd(1)/100
	p.rad-=p.sp
	if (p.rad <=0)del(particles,p)
end

function draw_particle(p)
	circfill(p.x,p.y,p.rad,p.col)
end

card_effects={}
function init_card_effect(x,y,ex,ey,col,hcol)
	local c={
		x=x,
		y=y,
		ex=ex,
		ey=ey,
		speed=0.1+flr(rnd(25))/100,
		col=col,
		hcol=hcol
	}

	add(card_effects,c)
end

function update_card_effect(c)
	c.x,c.y=lerp(c.x,c.ex,c.speed),lerp(c.y,c.ey,c.speed)
	if distance(c.x,c.y,c.ex,c.ey) <= 1 then
		del(card_effects,c)
	end
end

function draw_card_effect(c)
	rectfill(c.x,c.y,c.x+card_s_w,c.y+card_s_h,c.col)
	rect(c.x,c.y,c.x+card_s_w,c.y+card_s_h,c.hcol)
	spr(196,c.x+2,c.y+8)
end

-->8
-- all cards

--par: cost,name,type,effects
--type: 0 starter,1 purchased,2 monster
--effect: c coin,a attack,b block,d draw,k destroy
--        g gravedig,r remove mid,t discard,h heal,
--				o hurt player,m transform,e convert,i boost,
--				s slam,p unblock, j boom

all_cards=splitd("0,mediocre bard,0,c1;0,common guard,0,a1;2,shiny knight,0,a2;2,crafty chef,1,t1d2;1,apprentice distiller,1,k1;1,'giant' spider,2,c1;5,shifty barkeep,1,g1;1,young wizard,1,t1d1c1;4,legendary sword,1,k1a3;2,redheaded dragon,2,k1;2,light priest,1,c3;4,sacred tree,1,t1d3;4,bob the ghost,2,t1d2b1;3,fleshy planty,2,c3;4,rabbit warrior,1,a4c1;2,friendly goul,1,r1;3,confused cyclope,2,o1a2;7,old hero,1,a5d1;6,slimey friend,1,b2a2d1;5,flaming faun,2,d2b1;4,holiday spirit,1,c3b2;4,sneaky sage,2,t1d2c1;4,proud skeleton,1,a3b2;8,wise king,1,b4d1r1k1;5,sleepy witch,1,d1k2;4,senile enchantress,2,d2;3,defensive wanderer,1,b4;2,weird slimey,2,b1c2;3,business woman,1,a1d1c1;3,vacant paladin,1,a3;4,fabled monkey,2,a2b1;1,borug the orc,1,a2;3,magical fox,1,k1r1;3,great fishing rod,1,t1g1;2,áliving potion,1,h1a1;2,mean flower,2,c1h1;7,flaming body,2,h4d2;1,chill shield,1,b2s1;2,old hermit,1,o2d2;8,paragon,1,a8;8,STRAWBERRY g,2,d3a3;2,water blobs,2,c3;2,ethernal feral demon,2,d1;2,batty bat,1,t1h1b1;4,ninja splatty,2,g1;1,underground alchemist,1,m1;5,double agent witch,1,e1;5,death's wife,2,e1c1;3,persevering florist,1,c2k1;2,sad trumpet,2,i1;4,dj-bOnEy,1,i2;4,shiny godness,2,c1m1;3,blocky buddy,2,b1s1;8,the wall,2,b6d2;3,shy ninja,1,c2a2",";",",")


lane_i=0
lane_deck=splitd("4,4,5,5,6,6,6,7,7,8,8,9,9,10,10,11,11,11,12,13,13,14,14,15,15,16,16,17,17,18,18,19,20,20,21,21,22,22,23,23,24,25,25,26,26,27,27,28,28,28,29,29,30,30,30,31,31,32,32,32,33,33,34,34,35,35,36,36,37,38,39,39,40,41,42,42,43,43,44,44,45,46,46,47,47,48,49,49,49,50,50,51,51,52,53,54,55,55,55",",")


function parse_effects(effects_string)
	local nr_of_effects=#effects_string/2
	local all_effects={}
	for i=1, nr_of_effects do
		local c_effect_i=i-1+i
		local c_effect_char=sub(effects_string,c_effect_i,c_effect_i)
		local c_number_i=c_effect_i+1
		local c_number_char=sub(effects_string,c_number_i,c_number_i)

		add(all_effects,init_effect(c_effect_char,c_number_char))
	end
	return all_effects
end

function card_char_form(nr)
 return nr>1 and " cards" or " card"
end

function shovel_char_form(nr)
 return nr>1 and " shovels" or " shovel"
end

local desc_funcs = {card_char_form, shovel_char_form}

-- {{"c",1,"gain ",0," gold"},...}
-- effect id: "c", sprite: 1, description: "gain " .. num .. " gold"
-- 0 is num,1 is card_char_form(num),2 is shovel_char_form(num)
local effects_data = splitd("c,1,gain ,0, gold;a,2,gain ,0, attack;d,3,draw ,0,1;k,4,destroy ,0,1;g,5,gain ,0,2,\n to take ,0,1,\n from the graveyard;r,6,remove ,0,1, from lane;t,9,discard ,0,1;b,8,add ,0, armor;h,219,heal ,0, health;o,218,take ,0, health;m,220,transform all gold \ninto attack;e,221,convert an enemy \ninto an ally;i,222,boost all your current\nattack cards by ,0;s,223,transform all block \ninto attack;p,144;j,194",";",",")
for e in all(effects_data) do
 effects_data[e[1]]=e
end

function get_effects_desc_id(effects)
	local desc="-"
	for e in all(effects) do
		if (desc~="-") desc = desc .. "\n-"
  for i=3,#effects_data[e.id] do
   local part = effects_data[e.id][i]
   desc = desc .. (part==0 and e.num or (type(part) == "number" and desc_funcs[part](e.num) or part))
  end
 end
	return desc
end

function parse_type_col(t)
	if t == 0 then
		return 4,15,9
	elseif t == 1 then
		return 13,12,10
	elseif t == 2 then
		return 2,14,8
	end
end

function init_effect(id,nr_string)
	local c={
		id=id,
		num=tonum(nr_string)
	}
	local s_id=1
 	s_id=effects_data[id][2]
	c.s_id=s_id
	return c
end

level_delay=80
function update_xp()
	if level_delay > 0 then
		level_delay-=1
	else
		c_xp=lerp(c_xp,xp,0.075)
		if xp-c_xp < 1 then
			c_xp=xp
		end
		if c_xp >= xp_goal then
			level_up()
		end
	end
end

-- xp

c_xp,xp_x,xp_y,xp_w=0,12,56,104
function get_xp()
	xp+=abs(boss_health-boss_s_hp)
	if boss_health <= 0 then
		xp+=15
		xp+=(30-(30-r_health))
		if boss_unlock < 8 and boss_i == boss_unlock then
			boss_unlock+=1
			bo_unlock_s="boss"
			dset(3,boss_unlock)
		end
	end
	dset(0,xp)
end

function load_save()
 	cartdata("elastiskalinjen_xp")
	xp,xp_goal=dget(0),dget(1)
 	c_xp=xp
 	if (xp_goal == 0)xp_goal=50
	level=max(dget(2),1)
	boss_unlock,back_unlock=max(dget(3),1),max(dget(4),1)
	games_played,games_won=dget(5),dget(6)
	music_off,auto_next,auto_attack=num_to_bool(dget(7)),num_to_bool(dget(8)),num_to_bool(dget(9))
end

function level_up()
	xp,c_xp=xp-flr(c_xp),0
	level+=1
	xp_goal=50+level*20
	dset(0,xp)
	dset(1,xp_goal)
	dset(2,level)
	if back_unlock < 8 then
		ba_unlock_s="background"
		back_unlock+=1
		dset(4,back_unlock)
	end
end

xp_s=" xp"
function draw_xp()
	drawp(0b0011001111001100.1,rectfill,0,0,128,120,0)

	rectfill(xp_x-4,xp_y-20,xp_x+xp_w-2,xp_y+48,0)
	spr(147,xp_x+60,xp_y-18)
	print("level:" .. level,xp_x+69, xp_y-16,13)
	print("" .. flr(c_xp) .. "/" .. xp_goal .. xp_s,xp_x,xp_y-6,7)
	line(xp_x,xp_y,xp_w,xp_y,1)
	line(xp_x,xp_y,xp_x+(xp_w-xp_x)*(c_xp/xp_goal),xp_y,7)
	print("damage dealt: " .. boss_s_hp - boss_health .. xp_s,xp_x+2,xp_y+4,12)
	spr(149,xp_x+xp_w-11,xp_y)
	if boss_health <= 0 then
		print("you won!",xp_x+8,xp_y-16,7)
		if xp - c_xp <= 20 then
			print("boss killed: 15" .. xp_s,xp_x+2,xp_y+12,12)
		end
		if xp - c_xp < 3 then
			print("health left: " .. (30-(30-r_health)) .. xp_s,xp_x+2,xp_y+20,12)
		end
	end

	local won_s = boss_health <= 0 and "you won!" or "you lost!"
	print(won_s,xp_x+8,xp_y-16,7)
	local won_spr = boss_health <= 0 and 145 or 146
	spr(won_spr,xp_x-2,xp_y-18)

	line(xp_x,xp_y+28,xp_w,xp_y+28,1)

	if xp - c_xp < 2 then
		u_p(bo_unlock_s,9,32)
		if boss_unlock < 8 and bo_unlock_s == "" then
			spr(193,xp_x-2,xp_y+31)
			print("win next boss to unlock",xp_x+8,xp_y+32,7)
		end

		u_p(ba_unlock_s,9,42)
		if back_unlock < 8 and ba_unlock_s == "" then
			spr(192,xp_x-2,xp_y+40)
			print("level up to unlock",xp_x+8,xp_y+42,7)
		end
	end
end

function u_p(s,x,y)
	if s ~= "" then
		spr(148,xp_x-2,xp_y+y-3)
		print("new " .. s .. " unlocked",xp_x+x,xp_y+y,9)
	end
end
__gfx__
00000000000000000000000000000000000000000000004000000000000330000000000000000000000000000000000000000000000000000000000007776660
000000000000000000000660088888800008880000000042044420040303033002222220005d6600082008200000000004444110000000000000000077777666
0070070000aaa7000000667008222280088990080000042004420400033333032ddd777205500670872088820070280007d7dd60888888882222222271177116
000770000aaa77704006670008282280089a99880000420004204020003333302d1166725dddddd5e882888208828820007a9600082222800222222071177116
000770000aaaa7a0026670000821828089aaa9800604200002040240003330302dd1677206d767608e8888220888882000066000008228000022220072277226
007007000aaaaaa0042700000822128029aaa988656000000440244000d3000002d1672006d767600888822000888200006a9600000880000002200076677666
0000000009aaaa90444200000822228002aaa22065510000000244402d3230d002dd772006d76760008822000002200006a99960000000000000000077777766
00000000009999002400400008888880002222005510000002444440022222000022220006d76760000220000000000004444110000000000000000007676760
000004400056650000aa99006677776604400220e022220e004424009044409000a7a000000828001111000000333b00077777600033bb000060066000066000
04444440057667500aaa99900677777000bbb3000222222004242240044444000a987a0000077280011111000333bb3077777776036677b006400460006ddd00
04ffff40676116760aaaa990077777700bb3333026d226d244ff2f444444444000a9a0000871028811444110333b3b3b70770777036117b0064dd46006d6d6d0
f11f11ff512112150a1111900676767001133110011221104f1ff1f40d1d1d0000a1a00a088807880414141033bb43bb0277207733eeeebb0717717002d22d20
fffdffff661111660aa11990ff1ff1ff06633dd0012662104ffffff20ffeff000a112a000888712884444480bb39a33b707707763e7878eb0d7777d00d8282d0
024444a90661166000aa99000ffffff003333330026226202ff44ff208fff8000a111a000818812878444870b339a33376776776e788887e0d7777d000222220
08244a9a02611620001991000ffffff000333300028228202f4ff4f4089b9880aa112aa001128828072227603b3bbb3b711176600e2222e0007e7d0000011100
888299a10022220099111199047ff74024133142202222024d4444d488d9dda89999999a81712888977277792bb3b33b711116000deeeed0011771a9002e1110
8899991207d22d709a9999a9747777473243342302555520724444277dccc4880a556aa088112882d977769d20333330722227000033330077111a990068e110
89919128766dd66719aaaa91642222463224422302dddd20d724427d77cc4c880a667a000888882a7d9669d740223020772267060b03b000777aaa900d888e12
9911912811766711199aa99164444446b2bb222322252522d7d44d7d877fccc80a567a00a0888820079449700404f04067767700b033b0b077aa991002888622
991991285d16615d59a99a95642482463b33222002dddd20d776677d8dccccc8aa667a000088982a079889700024220006677760000b3b3b6a99a91022e688e2
99991128d67667655aa99aa564288246333aa22022252522d777777d8dccccc80a567a0aa989a8e94498e944002400000066777700f3bf30b9a7711120ee8802
199112285166661d099aa99074484487044a944002dddd20d766667d844994480a667a00a929a2a97dd99dd700220000000666760fd33df23b9711112011e600
11112288d51661d502a99a20742248870222222022252522d677776d867777780a667aa099a9aea976d99d670224f0007067060704ffff202332221100111ee0
222228885d511d5509222290744228472222222222dddd2207777770867767780a667a009aa99a99776776774244420000070060044444202222211000011111
000ee000004444000dedded00010002100777d00010000200000000000a0a90000088e000000ddd00067650000bbbb0000aaa000077007700009990000111100
20eeee0204444440dcceeccd02010201072727d010000001007777000799996000e8888000dd111d007665000b7733b00a9aa900770000770999d94001bb3310
eee22eee06655440c77dd77c02002000077976d02000000207077070764444760888ffe00d111111001ff1000b3b33b009949a907000000794dddd991bbbb331
ee2712eef6ff654fccceeccca2202240009828001077770107700770741441468e8ffff80116611105ffff50b373373ba44449aa760000679d1d1dd91b1b3131
0e6116e067f7f5f40cccccc0a9222940096287d0277776d2077777706444444648ff1f1816d6d611025ff520b733707b914144a967777776911d11d91bbb3331
02e77e206fdfff64eccddcce82929280476288d4070660d00677776026644662488ffef00f1f1f6d0ddd88d0b7b3363ba4e44aaa061771604d2d2d491b7b3731
18eeee816ffff64402cccc20289998207677288d1166dd110006600d446666464422ff2266fff066dd98228db333333b79447749071771709477749411222231
188118810dffd040002cc200041994007761666d221dd122000760dd4d6666d64442222060fff060dd8211280b3733b00a77a4aa07777770899dd99801311311
018118100dddd0000dddddd00022400077776dddd221122d07777dd07a6666978442222260222060dd8111180b7073b08a88a8a20e6767207899998701d33310
21888812d2dd2460eceeeece09dd444007716dd0d22e822d7777dd6027a669782d44222201111166dd81ed18b3363b3b8a988828eee2221077899877212dbb1b
1d1981d1442244d0ecddddce99999944076dddd0dde888dd700dd67727da9d7222d4422211111116d9812218b3b3333b78888227e222211079688697b122db1b
d1d88d1d44444d5dccceeccc9249492477666ddddd2882dd77dd070087766772022dff21012e2116998111180b3333b077488477e221111149666694b1322d13
dd1981dd4dd444d5dccddccd90999404777166dd0d7227d07dd6777086777768012dff101fe88f109982112800b33b00088888202211110164966946b1332213
1dd18dd1d9addd0d0dccccd0d2994921777666dd02222220dd067000276666722222dd401288e2119928228202b33b2088828222201001006696946631333213
211981124dd4440ddccddccd0029920076667ddd020220200557755026777762222222d4112221112992882900e222008888282201000010966696690b3a9320
221d81224444440f0dccccd0001001000766ddd02020020200577500876677782222222411222111029922990044410088828222010000100966669004499440
0000100000000000000000000999aa9000088000000000000004400000000000088888000000c7c00000000000d00d00007f22000e2e22200555555000777000
0002210000000200009441009aaaaaa908888880dd0dd0dd000f420044000044228822880c0c0c00080000000dd00dd007ffff20e12211125555555555555700
00e22210000242200794416091ffff1a8989a888dc7777cd00f444204007600470880782c7c00001008008e00d1001d07fffff22101101f151d11d1505555570
00e222100042004007791660aa1ff1fa289aa982c7cccc7c004444204061160422882220707100c08080888e0d1001d0fd7dd7d2f1ff1fff20f2022276665557
0e2721100420002406867860affffffa08aaaa80c7c76c7c0074442440711604081188761710010002880028d110011dd702207d1fddff112fffff2271616555
0e77d2400420000407288860a8f88f8a08aaa980c7cccc7c044447400460064088888766010c1000288e81021ff01ff1fd7dd7d221fff1122f88fff206666755
122724210420000207872260aaffffaa089aaa80c227622c54455550006006008e88766e0001c0c0228e800012f11f210ffef2200d2112d052ffff2016e6d245
2222222204200006078788609aaaaaa9088aaa90c60cc06c55225530007667008887668800100c7c2288e0001ffffff10fe0ef2001dddd100211121006661444
d222221d0440006707888860099999900898aa98c7c76c7c055555330f77760058766e88010017072888e000100ff0010ffeff201e1111215255521512622442
971dd17904200070118782110001100002228a98c7cccc7c055555337f7277f0556688e8c0000171228e80001f0ff0f17ffffff2ed2222d1d5555551112144d2
0999999009400760611111160030000002802828c7c76c7c01155133f72f277f0468e8880c00c010288e810211dffd11ffffff7222dddd211555556511144d12
059999509a907600787117860003000b02802808c7cccc7c03a51313f2222277445e88e200cc000002880028116dd611ff737ff2e21111210555466111ffd120
0299952019006000781ee186b00b30b30820280016dccd61333933337222227248558e800c7cc1c18080888e1180081173f3f3722d2222d20555551501ff1220
021952201109700072111126bb033bb308808200166dd66133a33133222252d20880888017071000008008e011800811f070733f21dddd115551511104d12122
0222222010090900672112660bb3333000808200016666103933333125225d22080008800171010008000000010000107000f03722111121555515114d111212
22eeee2200099900000000000033330000000200001111003a933331555d5d2d02000020001000100000000001000010f0000003222222215551511141112122
0066660000aaaa000222222000667600021001200110011000111100000000000000000000000000000000000000000000000000000000000000000000000000
067676700a0a0a70200000020696996005555550010cd01001111110000000000000000000000000000000000000000000000000000000000000000000000000
776767670acacaaa207777026727a276500550050100001011111111000000000000000000000000000000000000000000000000000000000000000000000000
6d6d66d6a9999aa72200002267aaaa765075570501099010f595595f000000000000000000000000000000000000000000000000000000000000000000000000
f61f61ff998899aa1107701176aaaa675dd55dd5010880101f1111f1000000000000000000000000000000000000000000000000000000000000000000000000
6ffffff6988889a00177771076099067000550000108801001111110000000000000000000000000000000000000000000222200000000000000000000000000
6ff88ff69188190000700700760aa067000550001102201100111100000000000000000000000000000000000000000000222222220000000000000000000000
647ff74699119900000dd00062aaaa26000550001102201161711710000000000000000000000000000000000000000000222222227220000000000000000000
5477772509999000000760002aaff7a20dddddd01600006166177111000000000000000000000000000000000000000002222222277222222000000000000000
d422284d00222a00067677602aaff792d777666d1155551176611dd1000000000000000000000000000000000000000002222222272222222222000000000000
54448985000a70a070076007299aa9a2d777666d111d11111766ddd1000000000000000000000000000000770000000002222222777222222772222200000000
d444384d00aa70200076770029a977a25d7766d501d5dd101d766d250000000000000000000000000000007700000000022222222dd277222772222222200000
05d54445000aa2000006700029a77ff255d76d55116565115dd762d5000000000000000000000000000000770000000000222222222277222772222222222000
0423424d000a0000006776002aafaaf2555dd55501dd5d105ddd2225000000000077777077777077770777770777770007727277277277772777772222222000
04322240000a0000007007000aaf77a0055005501111d1115dd2d221000000000077777077777077770777770777770007727277277277772777772222222000
0444444000aaa200006006000f9a79a002000020111111115ddddd11000000000077077000077077000770770770000007727277277277222772772222220000
000000000099990000777700001551000000000011111111000e2000000000000077000077777077000770770777770007727277277277222772772222220000
088888000a2222a00777777000155100007000700111111100e00200000000000077077077077077000770770000770007727277277277222772772222220000
855570000a7aaa90071771700022220000070700001111110e000020000000000077777077777077000777770777770007777777277277772772772222200000
855100680aaaa990071771700227e2200288788000011110200000020000000000ddddd0ddddd0dd000ddddd0ddddd000ddddddd2dd2dddd2dd2dd2222200000
8550006800a799000767767002e22220228878800000111002000020000000000000000000000000000000000000000000000222222222222222222220000000
00000680000a90000677776002722e20267777700000110002200220000000000000000000000000000000000000000000000002222222222222222220000000
000d6680000a9000007777000deeeed0628878800000100000200200000000000000000000000000000000000000000000000002272222222222222220000000
00888800009494000067670000dddd00228878800000000000222200000000000000000000000000000000000000000000000027722222227222222000000000
0fff4444444141110000000000000000fff444444441111000222200000000000000000000000000000000000000000000002227222222277222000000000000
0ff4444444441111ff770000000076ffff4444444414111000200200000000000000000000000000000000000000000000222277727722270000000000000000
07dd77ddddddddd6ffdd70000007ddff7dddaddddddddd600220022000000000000000000000000000000000000000002022772dd27722777000000000000000
07dd7dddddddddd6f4dd7700007d7df479a7a9aaada99960020000200000000007777700000000000000000077777000222277222277772dd000000077777000
0077dd7dddddd66044d7d77007d7dd4407779aa99999660020000002000777770777770777700000007777707777707777727727727777200077777077777000
00077dd9dd99660044dd7d707ddddd44007997aaa9996000020000e0000777770770770777707777707777707707727777727727727722277077777077000000
000077aa9996600044ddddd77ddddd44000779a99966000000200e00000770770777770770007777707707707727722227727727727722277077077077777000
000000767660000044ddddd67adadd4400007776660000000002e000000770770770000770007700007707707727727777727727727722277077777000077000
000007776660000044dddd9769a9aa44000007676600000000000000000770770777770770007777707707707727727727727727727777277077000077777000
00007d9a99d6000044aada9669a9a94400007da9dd60000000000000000777770ddddd077000000770777770dd2dd2777772772772dddd2770777770ddddd000
0007d97aaa9d600044a9a9966999a9440007ddddddd6000000000000000777770000000dd000777770ddddd0002222ddddd2772dd222222772ddddd000000000
007979aa99999600149999600699a914007d7ddddddd60000000000000077000000000000000ddddd0000000022222222222dd222222222dd200000000000000
079a7a9aaaaa99604199966000699a4107d7ddddddddd60000000000000770000000000000000000000000000222222222222222222222222200000000000000
069aaa999999a99611996600000699117ddddddddddddd6000000000000dd0000000000000000000000000000222222222222222222222222220000000000000
0fff4444444141111199600000006911fff444444441111000000000000000000000000000000000000000000000022222222222222222222220000000000000
0ff44444444411111166000000000611ff4444444414111000000000000000000000000000000000000000000000000022222222222222222222200000000000
00777700008888000000000000dddd00000880000002200001000010000000000000000000000000000000000000000000022222222222222222000000000000
0700007008000080000428900d0000d0008008000020020000111100000000000000000000000000000000000000000000022222222222222222000000000000
0700007008000080000209000d0000d0008008800220022001111110000000000000000000000000000000000000000000000002222222222222000000000000
7777777788888888001d1100dddddddd018008800c20022001011010000000000000000000000000000000000000000000000000000222222222000000000000
777557778881188801d11110ddd22ddd011001800cc00c2001011010000000000000000000000000000000000000000000000000000000222220000000000000
777757778888188801111110dddd2ddd011001100cc00c0000111100000000000000000000000000000000000000000000000000000000000220000000000000
577777751888888101d111102dddddd20010010000c00c0001011010000000000000000000000000000000000000000000000000000000000000000000000000
0555555001111110001111000222222000011000000cc00010000001000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100100000000000000000000000000000000000000000000000000000000000000000000000000
0110011001000010111111110001111000000110001111000100001000100100400000000880088000000760000000000004400002200220a000000000044000
010000100100001001000010001110000001011001111110000000000111011049000000878088880000766000e0080000777600272222727a0a0a0000777600
000000000110011000100100011000100000100001011010000100000111111029900000e88888884007660008828880007996002262262277a727a000711600
0000000001111110000110000100011000010100011111100000100001111110299000008e888888017660000e8888800079760052276225aa99999900717600
010000100101101000100100000111000010000000100100000000000011110029000000088888800416000008888820079a99605526d255a902002007dc1160
011001100011110011111111011110000100000000011000010000100001100020000000008888000a400000008882007979a99d05d55d50900900907d7dc11d
00000000000000000000000000000000000000000000000000100100000000000000000000088000d0040000000820000666ddd000555500000099000666ddd0
000009900a900000000000c700000000990924990449099000000000011000000000000045080000000dd0000dd0000000088800888e00000000666651100000
0009a888889a9000000000c707000000099994494499990000000000177100000000000500900000000110000110000000e888888888888000d6d6dddd110000
000981881889000000000cc72770000099f0ffd999fd9ff9000000011171100011000004080800d100d11060011d0000088888888888888800d64dd6d2110000
000888888888000000000cc722770000111ffff99dfff9f900000111111111101111011501d0dd1100d11676611d0000088888888888888800d4a4dd29210000
00008711788200000000cc17227700009fd111fffff55ff90000000552520000011110111d0d111000d17667671d0000888882777688888e00d646dd12110000
00008788782200000000ccc72777000044f111fffff77992000000077699a0000111107117011110000dc1661cd0000088882777776888e000ddddddd1110000
00662888822550000000cccc7777000042fddd1111fdd9440000000776999a000011102882011100000016776100000088881117111788880005a1d191900000
0006722222770000000cccccc677666029fff2f11f2ff9920000006677609990011111122111111000006555560000008888d07770d1888000005a1a19000000
00016777567d0000000ccccc66776666999f2ff77ff2f444000066ddd77700000001111111111000000661551660000080886c676c67288000100aa991001000
001117677711d00000ccccccc7776660949f2f7777f2f999000666ddd5777000000011111d11000000006d11d6000000008e7ce88c778800001d0d2dd4011000
01111115611121d00ccccc11cc7760009294277117744409066ddddd5577600000005111111d0000000006dd60000000008077888c770800005d649429121100
01882115515288210cccccccccc000009294941771949940dddddd5557776000000511111111d00000000676700d6d6000007ceeeec6000006d5299999942160
18882d1111888821cccccc11ccc0000099494477779409447555557777660000000511111111d00000009d6d6966dd6d00000ef27fe0000012dd498998921165
1282111111d882d1000ccccc6cccc00099494944949449900666666666000000000511111111d00000007a8897dd66d600000e2222e000005255288888842165
1d211115111d211d00cccccc77ccc00022424944949904400000202000000000000051111115000000066699676ddddd000006eeee7000005ddd548888221225
1d1115111511111d00cccccc7770000022429920220990440000e0e0000000000000010000100000006767666677d6d6000007666670000055d5dd1414151115
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000
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
000100002e620073302b6300433023630073301d6301b63019630186301663014630116300c6300863005630046200462006320086200462001620003200162003620063200562003610016100b3200061000620
000400002e73332545327433253500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003276326754157432174400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000032763395653476332565397633456532763395651a6441a6421a6321a6321a6221a6221a6121a61200000000000000000000000000000000000000000000000000000000000000000000000000000000
010300003e72302665002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000326131a765326133176330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0115000026761297652d765307652f7652b7652d7652d763327523275532742327453273232735327223272400000000000000000000000000000000000000000000000000000000000000000000000000000000
011500003276132765317633176530763307652f7632f7652d7532d7552d7422d7452d7322d7352d7222d72400000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002672332735000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001a6441a6421a6341a6321a6241a6221a6141a6121a6001a6001a6001a6001a6001a6001a6001a6001a6001a6001a6001a6001a6001a6001a6001a6000000000000000000000000000000000000000000
000400000060000600006000060004320186202a3200832006320236201e6201a6201762013620126200b62003320056200062000600006000060000600006000060000600006000060000600006000060000600
001500002673028730297302673028730287322573025732267302873029730267302b7302b7322b7322b7342d7302b730297302d7302b7302b73228730287322973128735267352873525730257322573225734
001500001a7351d7351a7351d7351c7351f7351c7351f7351a7351d7351a7351d735187351c735187351c735187351d735187351d735187351c735187351c7351a7351d7351a7351d735197351c735197351c735
001500000e0350e0240e0200e020090350902409020090200e0350e0240e0200e0200c0350c0240c0200c020110351102411020110200c0350c0240c0200c0200e0350e0240e0200e02009035090240902009020
001500000262339615396153961502623396153961539615026233961539615396150262339615396153961502623396153961539615026233961539615396150262339615396153961502623396153961539615
00150000267302873029730267302873028732257302573226730297302d73032730307303073230732307342e7312d7352b7352e7352d7312b735297352d7352b73729733287352973526731267352673526734
001500001a7351d7351a7351d7351c7351f7351c7351f7351a7351d7351a7351d735187351c735187351c735187351d735187351d735187351c735187351c7351a7351d735197351c7351a7351d7352173526735
001500000e0350e0240e0200e020090350902409020090200e0350e0240e0200e0200c0350c0240c0200c020110351102411020110200c0350c0240c0200c0200e0350e02409025090240e0350e0240e0200e020
001500000262339615396153961502623396153961539615026233961539615396150262339615396153961502623396153961539615026233961539615396150262339615026153961502623216152d61539615
001500003272326525327272652531723255253172725525327232652532727265253472328525347272852535723295253572729525347232852534727285253272326525327272652531723255253172725525
001500001d7231d1251d7211d1251c7231c1251c7211c1251d7231d1251d7211d1251f7231f1251f7211f125217232112521721211251f7231f1251f7211f1251d7231d1251d7211d1251c7231c1251c7211c125
001500000e0350e0250e0250e025090350902509025090250e0350e0250e0250e0250c0350c0250c0250c025110351102511025110250c0350c0250c0250c0250e0350e0250e0250e02509035090250902509025
001500003272326525327272652531723255253172725525327232652532727265253472328525347272852535723295253572729525347232852534727285253272326525317272552532723295253972726525
001500001d7231d1251d7211d1251c7231c1251c7211c1251d7231d1251d7211d1251f7231f1251f7211f125217232112521721211251f7231f1251f7211f1251d7231d1251c7211c1251d7231a125157210e125
001500000e0350e0240e0200e020090350902409020090200e0350e0240e0200e0200c0350c0240c0250c025110351102411020110200c0350c0240c0200c0200e0350e02409025090240e0350e0240e0200e020
001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001500001a7101a7101a7201a7201c7301c7301c7401c7401d7401d7401d7301d7301c7201c7201c7101c7101a7101a7101a7201a7201c7301c7301c7401c7401d7401d7401d7301d7301f7201f7201f7101f710
001500000e0430e0300e0200e010090430903009020090100e0430e0300e0200e0100c0430c0300c0200c010110431103011020110100c0430c0300c0200c0100e0430e0300e0200e01009043090300902009010
001500001d7101d7101d7201d7201f7301f7301f7401f740217402174021730217301f7201f7201f7101f7101d7101d7101d7201d7201f7301f7301f7401f74021740217401f7301f7301d7201d7201d7101d710
001500001a7101a7101a7201a7201c7301c7301c7401c7401d7401d7401d7301d7301c7201c7201c7101c7101a7101a7101a7201a7201c7301c7301c7401c7401d7401d7401c7301c7301a7201a7201a7101a710
001500000e0430e0300e0200e010090430903009020090100e0430e0300e0200e0100c0430c0300c0200c010110431103011020110100c0430c0300c0200c0100e0430e03009020090100e0430e0300e0200e010
001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001500001a7131a7151a7231a7251c7331c7351c7431c7451d7431d7451d7331d7351c7231c7251c7131c7151a7131a7151a7231a7251c7331c7351c7431c7451d7431d7451d7331d7351f7231f7251f7131f715
001500000e0430e0300e0200e010090430903009020090100e0430e0300e0200e0100c0430c0300c0200c010110431103011020110100c0430c0300c0200c0100e0430e0300e0200e01009043090300902009010
001500001d7131d7151d7251d7251f7331f7351f7451f745217432174521735217351f7231f7251f7151f7151d7131d7151d7251d7251f7331f7351f7451f74521743217451f7331f7351d7231d7271d7151d717
001500001a7131a7151a7251a7251c7331c7351c7451c7451d7431d7451d7351d7351c7231c7251c7151c7151a7131a7151a7251a7251c7331c7351c7451c7451d7431d7451c7331c7351a7231a7251a7151a715
001500000e0430e0300e0200e010090430903009020090100e0430e0300e0200e0100c0430c0300c0200c010110431103011020110100c0430c0300c0200c0100e0430e03009020090100e0430e0300e0200e010
001500002673028520297302652028730285222573025522267302852029730265202b7302b5222b7322b5242d7302b520297302d5202b7302b52228730285222973128525267352852525730255222573225524
001500001a5251d7351a5251d7351c5251f7351c5251f7351a5251d7351a5251d735185251c735185251c735185251d735185251d735185251c735185251c7351a5251d7351a5251d735195251c735195251c735
001500000e0331a025260251a025090331502521025150250e0331a025260251a0250c033180252402518025110331d025290251d0250c0331802524025180250e0331a025260251a02509033150252102515025
00150000267302852029730265202873028527257302552226730295202d73732527307303052230732305242e7312d5252b7332e5252d7312b525297332d5252b73729523287352d52532731325253273532524
001500001a5251d7351a5251d7351c5251f7351c5251f7351a5251d7351a5251d735185251c735185251c735185251d735185251d735185251c735185251c7351a5251d735195251c7351a5251d7352152526735
001500000e0331a025260251a025090331502521025150250e0331a025260251a0250c033180252402518025110331d025290251d0250c0331802524025180250e0331a02509023150250e0331a0252602532025
001500003271226012327172601231722250223172725022327322603232737260323472228022347272802235712290123571729012347222802234727280223273226032327372603231722250223172725022
001500001d0121d7171d0121d7121c0221c7271c0221c7221d0321d7371d0321d7321f0221f7271f0221f722210122171721012217121f0221f7271f0221f7221d0321d7371d0321d7321c0221c7271c0221c722
001500000e0331a0250e0251a025090331502509025150250e0331a0250e0251a0250c033180250c02518025110331d025110251d0250c033180250c025180250e0331a0250e0251a02509033150250902515025
001500003271326012327122601231723250223172225022327332603232732260323472328022347222802235713290123571229012347232802234722280223273326032317332503232743290453974526045
001500001d0131d7121d0121d7121c0231c7221c0221c7221d0331d7321d0321d7321f0231f7221f0221f722210132171221012217121f0231f7221f0221f7221d0331d7321c0331c7321d0231a725150250e725
001500000e0331a0250e0231a025090331502509023150250e0331a0250e0231a0250c033180250c02318025110331d025110231d0250c033180250c02318025020330e0250902315025020330e025020230e025
001500001a0151a7151a0151a7151c0251c7251c0251c7251d0351d7351d0351d7351f0251f7251f0251f725210152171521015217151f0251f7251f0251f7251d0351d7351d0351d7351c0251c7251c0251c725
001500000e0331a0250e0251a025090331502509025150250e0331a0250e0251a0250c033180250c02518025110331d025110251d0250c033180250c025180250e0331a0250e0251a02509033150250902515025
001500001a015267151a015267151c025287251c025287251d035297351d035297351f0252b7251f0252b725210152d715210152d7151f0252b7251f0252b7251d035297351c035287351a025297252102526725
001500000e0331a0250e0231a025090331502509023150250e0331a0250e0231a0250c033180250c02318025110331d025110231d0250c033180250c02318025020330e0250902315025020330e025020230e025
001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002623216152d61539615
00040000277132d5152e5232772500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 0b 0c 0d 0e
00 0f 10 11 12
00 13 14 15 0e
00 16 17 18 12
00 25 26 27 0e
00 28 29 2a 12
00 2b 2c 2d 0e
00 2e 2f 30 12
00 41 31 32 44
02 41 33 34 35
01 19 1a 1b 44
00 1c 1d 1e 44
00 1f 20 21 44
02 22 23 24 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
