pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- banana chase
-- extar 2019,2020

function reset()
	
	--resets any changes to the map made by mset
	reload(0x1000,0x1000,0x2000)

	player={
		--draw-based coords
		spr_x=64,
		spr_y=320,
		sp=1,
		--map based coords
		x=8,
		y=40,
		pears=0,
		skips=0,
		flip=false,
		facing='r',
	}
	birds={}
	cheats=false
	cheat_buffer={}
	chest_areas={'south swamp', 'south lake', 'temple walls', 'sand bank', 'temple lake'}
	completed_areas={}
	--used to stop mushrooms from underflowing target score after level is complete
	current_game_high_score=0
	difficulty='normal'
	difficulty_option=2
	--variable to control player eat animation. must a better way than this.
	eat_cycles=0 --used for eat animation
	gorillas={}
	encounter=0 --controls speech section
	explosions={}
	flag={
		wall=0,
		exit=1
	}
	frame=0 --used for eat animation
	fruit={}
	fruit_number=0
	gametimer=0
	game_state='splash'
	gameoverscreentime=0
	hide_ui=false
	mapx=0
	mapy=0
	mapx_offset=0
	mapy_offset=0
	--test debug 1
	max_fruit_level=0
	mission_areas={'north wood', 'south woods', 'south woods', 'south swamp', 'north swamp', 'riverside', 'central woods', 'grasslands', 'badlands', 'outer walls', 'temple ruins', 'temple walls', 'north ruins', 'south ruins', 'deep forest', 'hidden plains', 'flooded ruins', 'the well', 'dead forest', 'shady thicket', 'central swamp', 'the towers', 'haunted woods', 'lost clearing', 'magic orchard', 'coastal ruins', 'sand bank', 'coastal dunes'}
	muzak={
		woods=0,
		splash=1, --unnused 
		wizards_house=2,
		coast=3,
		ruins=5,
		haunted_woods=6,
		temple=10,
		grasslands=16,
		swamp=22,
		overture=26,
		game_over=52
	}
	next_fruit_countdown=rnd(90)
	fruit_countdown_max=90
	on_mission=false
	pears={}
	player_can_move=false
	points_popups={}
	score=0
	shortcut1=false
	sound={
		--eat_fruit=0,
		start_level=1,
		player_move=2,
		bonus_fruit=3,
		wizard_spell=4,
		rotten_fruit=5,
		--music 1=6,
		--splash music=7,
		open_chest=8,
		game_over=9,
		remove_tree=10,
		eat_mushroom=11,
		advance_chat=12,
		level_complete=13,
		bonus_skip=14,
		cheats=15,
		banana=16,
		strawberry=17,
		plum=18,
		orange=19,
		pineapple=20,
		pineapple_alt=21,
		fruit_upgrade=22,
		gorilla_move=23,
		gorilla_attack=24,
		gorilla_eat=25,
		bird_charge=26,
		bird_crash=27,
		bird_flap=28,
		skip_pickup=35
	}
	sparkles={}
	speech={
		'i must have fallen asleep',
		'where am i?',
		'i`m hungry!',
		'hey! this is my magic forest.',
		'if you eat all the fruit,',
		'i`ll show you the way out.',
		'yep, you`re good at eating.',
		'okay, past my house is more',
		'fruit that you can eat.',
		'hi! this is where i live.',
		
		'the way out is over there.',
		'will you do me a favour?',
		'there`s five magic pears',
		'hidden around the forest.',
		'will you get them for me?',
		'this just looks like an',
		'ordinary pear. oh well.',
		'i am no ordinary pear!',
		'huh. weird.',
		'not weird.',

		'magic.',
		'there are four more of us.',
		'you better get a move on.',
		'this seems like work...',
		'just enjoy the free food.',
		'yes, you`re right.',
		'by the way,',
		'if you want to skip an area,',
		'we can help you with that.',
		'well, that`s all of them.',
		
		'will you take us back now?',
		'okay.',
		'we`re magic, remember.',
		'we`ll open shortcuts for you.',
		'here are your pears.',
		'cheers, you`re the best.',
		'see you later.',
		'bye!',
		'bye! thanks for finding us!'
	}
	splashscreentime=0 --needed?
	stats={bananas=0,strawberries=0,plums=0,oranges=0,pineapples=0,red_mushrooms=0,brown_mushrooms=0,walk_distance=0}
	stats_messages={}
	stat_to_show=1
	stat_x=127
	streak=0
	stun_time=0
	target_score=0
	target_score_default=250
	time_complete=0
	time_start=0
	tips={
		'eat two of the same fruit to get a bonus fruit',
		'as you explore the forest, you will find new fruit',
		'monty doesn`t like mushrooms, they end your points streak',
		'eating the same fruit in a row earns more points',
		'further into the forest are fruits worth more points',
		'pineapples are worth 256 points',
		'you can eat leftover fruit after an area has been cleared',
		'earn points after clearing an area to get level skips',
		'press Ž to use a level skip',
		'it takes well over a year for a pineapple to reach perfect ripeness',
		'help monty eat all the fruit',
		'the wizard says yes',
		'say yes to the best'
	}
	tip_to_show=ceil(rnd(#tips))
	tip_x=127
	tortoises={}
	game_time=0
	wizard={
		x=0,
		y=0,
		c=7,
		show=false,
		sp=23,
	}
	wizard_poof=wizard.show
end

function _init()
	reset()
	high_score=0
	time_best_easy=3599
	time_best_normal=3599
	time_best_hard=3599
	menuitem(1,'reset',function() reset() end)
end

function clear_entities()
	for sp in all(sparkles) do
		del(sparkles,sp)
	end
	for ex in all(explosions) do
		del(explosions,ex)
	end
end

--src=https:--pico-8.fandom.com/wiki/centering_text
function hcenter(s)
  return 64-#s*2
end

function _update()
	
	if clear_particles!=area then
		clear_entities()
		clear_particles=area
	end
	
	if on_mission==false and #fruit==0 and on_exit==false and game_time>999 then
		game_time=0
	end

	if splashscreentime>75 and game_state=='splash' then
		clear_entities()
		game_state='title'
		game_time=0
	end
	
	if game_state=='title' then
	 cheat_input()
	end
	
	if game_state=='main' then	
		wizard_appear()
		popup_update()
		if score>current_game_high_score then
			current_game_high_score=score
		end
		gametimer+=(1/30)
		level_flow()
		
		if player_can_move==true then
			player_controls()
			spawn_new_fruit()
			map_music()
			update_gorillas()
			update_tortoises()
		end
			
		update_player_sprite()
		update_areas()
		update_explosions()
		update_sparkles()
		update_fruit()
		update_pears()
		update_birds()
		
		game_time+=1
	end
	
end

function _draw()

	cls()
	pal()

	if game_state=='splash' then
		splash()
	elseif game_state=='title' then
		title()
	elseif game_state=='game over' then
		game_over_screen()
	elseif game_state=='main' then
		
		draw_map()
		
		--draw entities. entities all have a pink alpha channel
		pal()
		palt(0,false)
		palt(14,true)
		
		draw_wizard()
		draw_player()
		draw_fruit()
		draw_gorillas()
		draw_tortoises()
		draw_birds()
		draw_pears()
		draw_explosions()
		draw_sparkles()
		--spr(5,player.x*8,player.y*8)
		
		--map independent draw operations after this (ui stuff) doesn't use (mapx*8) or (mapy*8)
		camera()
		
		draw_chat_box()
		draw_popups()
		draw_ui()

	end

	--other debug crap
	--print('mem:'..stat(0)..' cpu:'..stat(1)..' sys:'..stat(2),0,108,7)

end

-->8
--map code
function draw_map()
	--copied/derived from mboffin's/dylan bennet's adventure game tutorial
	mapx=flr(player.x/16)*16
	mapy=flr(player.y/16)*16
	camera(mapx*8,mapy*8)

	map(0,0,0,0,128,64)
end

function check_mission_area(area)
	for i = 1, #mission_areas do
		if mission_areas[i]==area then
			return true
		end
	end
	return false
end

function check_chest_area(area)
	for i = 1, #chest_areas do
		if chest_areas[i]==area then
			return true
		end
	end
	return false
end

function check_completed_area(area)
	for i = 1, #completed_areas do
		if completed_areas[i]==area then
			return true
		end
	end
	return false
end

function map_music()

	if current_music!=area then
		if stat(24)!=area_music then
			music(area_music)
		end
		current_music=area
	end
end

function update_areas()
	if mapx==0 and mapy==0 then
		area='north wood'
		area_music=muzak.woods
	elseif mapx==0 and mapy==16 then
		area='wizard`s house'
		area_music=muzak.wizards_house
	elseif mapx==0 and mapy==32 then
		area='south woods'
		area_music=muzak.woods
	elseif mapx==0 and mapy==48 then
		area='south swamp'
		area_music=muzak.swamp
	elseif mapx==16 and mapy==0 then
		area='north swamp'
		area_music=muzak.swamp
	elseif mapx==16 and mapy==16 then
		area='riverside'
		area_music=muzak.coast
	elseif mapx==16 and mapy==32 then
		area='central woods'
		area_music=muzak.woods
	elseif mapx==16 and mapy==48 then
		area='grasslands'
		area_music=muzak.grasslands
	elseif mapx==32 and mapy==0 then
		area='temple lake'
		area_music=muzak.temple
	elseif mapx==32 and mapy==16 then
		area='badlands'
		area_music=muzak.ruins
	elseif mapx==32 and mapy==32 then
		area='south lake'
		area_music=muzak.ruins
	elseif mapx==32 and mapy==48 then
		area='outer walls'
		area_music=muzak.ruins
	elseif mapx==48 and mapy==0 then
		area='temple ruins'
		area_music=muzak.temple
	elseif mapx==48 and mapy==16 then
		area='temple walls'
		area_music=muzak.swamp
	elseif mapx==48 and mapy==32 then
		area='north ruins'
		area_music=muzak.ruins
	elseif mapx==48 and mapy==48 then
		area='south ruins'
		area_music=muzak.ruins
	elseif mapx==64 and mapy==0 then
		area='deep forest'
		area_music=muzak.woods
	elseif mapx==64 and mapy==16 then
		area='hidden plains'
		area_music=muzak.grasslands
	elseif mapx==64 and mapy==32 then
		area='flooded ruins'
		area_music=muzak.ruins
	elseif mapx==64 and mapy==48 then
		area='the well'
		area_music=muzak.ruins
	elseif mapx==80 and mapy==0 then
		area='dead forest'
		area_music=muzak.haunted_woods
	elseif mapx==80	and mapy==16 then
		area='shady thicket'
		area_music=muzak.haunted_woods
	elseif mapx==80 and mapy==32 then
		area='central swamp'
		area_music=muzak.swamp
	elseif mapx==80	and mapy==48 then
		area='the towers'
		area_music=muzak.ruins
	elseif mapx==96 and mapy==0 then
		area='haunted woods'
		area_music=muzak.haunted_woods
	elseif mapx==96	and mapy==16 then
		area='lost clearing'
		area_music=muzak.woods
	elseif mapx==96 and mapy==32 then
		area='magic orchard'
		area_music=muzak.woods
	elseif mapx==96	and mapy==48 then
		area='coastal ruins'
		area_music=muzak.coast
	elseif mapx==112 and mapy==0 then
		area='sunken ruins'
		area_music=muzak.ruins
	elseif mapx==112 and mapy==16 then
		area='sand bank'
		area_music=muzak.coast
	elseif mapx==112 and mapy==32 then
		area='coastal dunes'
		area_music=muzak.coast
	elseif mapx==112 and mapy==48 then
		area='southern coast'
		area_music=muzak.coast
	end
end
-->8
--ui overlay code
function popup_update()
	for popup in all(points_popups) do
		popup.y-=0.1
		popup.life-=1
		if popup.life<0 then
			del(points_popups,popup)
		end
	end
end

function popup_message(amount,x,y,life)
	
	local popup={
		amount=amount,
		x=x,
		y=y,
		life=life
		}
	
	add (points_popups,popup)
				
end

function draw_popups()
	--sets points popup colour blink
	if game_time%6<2 then
		popcol=7
	else
		popcol=10
	end
	--prints points popups
	for popup in all(points_popups) do
		print(popup.amount,popup.x,popup.y,popcol)
	end
end

function drop_shadow(string,x,y,c)
	print(string,x+1,y+1,0)
	print(string,x,y,c)
end

function draw_ui()
	if hide_ui==false then
		drop_shadow('“',0,0,10)
		time_secs=tostr(flr((time()-time_start)%60))
		if #time_secs==1 then
			time_secs='0'..time_secs
		end
		if time()-time_start<10 then
			drop_shadow('0:0'..flr((time()-time_start)%60),7,0,7)
		else
			drop_shadow(flr((time()-time_start)/60)..':'..time_secs,7,0,7)
		end
		drop_shadow('score:',32,0,10)
		drop_shadow(score,56,0,7)
		if encounter>=17 then
			drop_shadow('pears:'..player.pears..'/5',91,0,10)
			if player.pears==5 then
				print(player.pears..'/5',115,0,game_time%8+8)
			else
				print(player.pears..'/5',115,0,7)
			end
		end
		if player.skips>0 then
			drop_shadow('level skips: '..player.skips,1,7,10)
			print(player.skips,53,7,7)
		end
		if cheats==true then
			print('cheats: press — to skip level',0,121,8)
		end
	else
		drop_shadow('—',0,0,10)
	end
end

function draw_chat_box()
	if speaker=='monkey' then
		text_colour=10
		background=1
	elseif speaker=='wizard' then
		text_colour=0
		background=7
	elseif speaker=='pear' then
		text_colour=10
		background=3
	end
	--chat box
	if show_chat==true then
		rectfill(6,30,8+(#current_chat*4),38,text_colour)
		rectfill(7,31,7+(#current_chat*4),37,background)
		print(current_chat,8,32,text_colour)
		if game_time%30<15 then
			rectfill(6,40,14,46,text_colour)
			print('—',7,41,background)
		end
	end
end
-->8
--level code

function level_flow()

	--cut scenes (player can't move)
	if game_state=='main' and player_can_move==false then
		if encounter==0 then
			show_chat=true
			current_chat=speech[1]
			speaker='monkey'
		elseif encounter==1 then
			current_chat=speech[2]
		elseif encounter==2 then
			current_chat=speech[3]
		end
		--start level 1
		if encounter==3 then --first level, only bananas
			player_can_move=true
			show_chat=false
			run_mission()
		end
		--level 1 outro
		if encounter==4 then
			current_chat=speech[4]
			speaker='wizard'
			show_chat=true
			wizard.show=true
			wizard.x=14
			wizard.y=33
		elseif encounter==5 then
			current_chat=speech[5]
		elseif encounter==6 then
			current_chat=speech[6]
			target_score=ceil(score/target_score_default)*target_score_default
		end
		--start level 2
		if encounter==7 then --level 2, strawberries
			show_chat=false
			wizard.show=false
			player_can_move=true
			run_mission()
		end
		--level 2 outro
		if encounter==8 then
			current_chat=speech[7]
			show_chat=true
			wizard.show=true
			wizard.x=14
			wizard.y=33 
		elseif encounter==9 then
			current_chat=speech[8]
		elseif encounter==10 then
			current_chat=speech[9]
		end
		if encounter==11 then --unlock south woods trees
			mset(12,32,120)
			mset(13,32,120)
			mset(12,33,17)
			mset(13,33,17)
			sfx(sound.remove_tree)
			create_explosion(12.5,32.5,20,9)
			create_sparkles(12.5,32.5,9)
			show_chat=false
			wizard.show=false
			player_can_move=true
			encounter=12
		end
		--first visit to wizard's house
		if encounter==12 and area=='wizard`s house' then
			show_chat=true
			wizard.show=true
			wizard.x=7
			wizard.y=26
			current_chat=speech[10]
			if cutscene_music!=encounter then
				music(muzak.wizards_house)
				cutscene_music=encounter
			end
		elseif encounter==13 then
			current_chat=speech[11]
		elseif encounter==14 then
			current_chat=speech[12]
		elseif encounter==15 then
			current_chat=speech[13]
		elseif encounter==16 then
			current_chat=speech[14]
		elseif encounter==17 then
			current_chat=speech[15]
		elseif encounter==18 then
			show_chat=false
			wizard.show=false
			player_can_move=true
		end
		--player has collected first pear
		if player.pears>0 then
			if encounter==19 then
				show_chat=true
				speaker='monkey'
				current_chat=speech[16]
			elseif encounter==20 then
				current_chat=speech[17]
			elseif encounter==21 then
				speaker='pear'
				if cutscene_music!=encounter then
					music(muzak.wizards_house)
					cutscene_music=encounter
				end
				current_chat=speech[18]
			elseif encounter==22 then
				speaker='monkey'
				current_chat=speech[19]
			elseif encounter==23 then
				speaker='pear'
				current_chat=speech[20]
			elseif encounter==24 then
				current_chat=speech[21]
			elseif encounter==25 then
				current_chat=speech[22]
			elseif encounter==26 then
				current_chat=speech[23]
			elseif encounter==27 then
				speaker='monkey'
				current_chat=speech[24]
			elseif encounter==28 then
				speaker='pear'
				current_chat=speech[25]
			elseif encounter==29 then
				speaker='monkey'
				current_chat=speech[26]
			elseif encounter==30 then
				speaker='pear'
				current_chat=speech[27]
			elseif encounter==31 then
				current_chat=speech[28]
			elseif encounter==32 then
				current_chat=speech[29]
			elseif encounter==33 then
				show_chat=false
				player_can_move=true
			end
		end
		--player has all 5 pears
		if player.pears>4 then
			if encounter==34 then
				show_chat=true
				speaker='monkey'
				current_chat=speech[30]
			elseif encounter==35 then
				speaker='pear'
				if cutscene_music!=encounter then
					music(muzak.wizards_house)
					cutscene_music=encounter
				end
				current_chat=speech[31]
			elseif encounter==36 then
				speaker='monkey'
				current_chat=speech[32]
			elseif encounter==37 then
				speaker='pear'
				current_chat=speech[33]
			elseif encounter==38 then
				current_chat=speech[34]
			end
			if encounter==39 then
				show_chat=false
				player_can_move=true
			end
			--second visit to wizard's house
			if encounter==40 and area=='wizard`s house' then
				show_chat=true
				speaker='monkey'
				current_chat=speech[35]
			elseif encounter==41 then
				wizard.show=true
				wizard.x=7
				wizard.y=26
				speaker='wizard'
				current_chat=speech[36]
			elseif encounter==42 then
				speaker='monkey'
				current_chat=speech[37]
			elseif encounter==43 then
				speaker='wizard'
				current_chat=speech[38]
			elseif encounter==44 then
				speaker='pear'
				current_chat=speech[39]
			elseif encounter==45 then
				show_chat=false
				wizard.show=false
				player_can_move=true
				mset(0,22,120)
				mset(1,22,120)
				mset(0,23,120)
				mset(1,23,120)
				sfx(sound.remove_tree)
				create_explosion(0.5,23.5,20,9)
				create_sparkles(0.5,23.5,9)
			end
		end
		
		--advances chat window
		if btnp(—) and show_chat==true then
			encounter+=1
			sfx(sound.advance_chat)
		end
	end

	--go to cut-scene section, stops player moving 
	if score>target_score and encounter==3 then
		encounter+=1
		player_can_move=false
		on_mission=false
	end
	if score>target_score and encounter==7 then
		encounter+=1
		player_can_move=false
		on_mission=false
	end
	if area=='wizard`s house' and encounter==12 then
		player_can_move=false
	end
	if player.pears>0 and encounter==18 then
		encounter+=1
		player_can_move=false
		sfx(sound.level_complete)
	end
	if player.pears>4 and encounter==33 then
		encounter+=1
		player_can_move=false
		sfx(sound.level_complete)
	end
	if player.pears>4 and area=='temple ruins' and shortcut1!=true then
		player_can_move=true
		mset(56,15,120)
		mset(57,15,120)
		mset(56,16,121)
		mset(57,16,121)
		mset(56,17,105)
		mset(57,17,105)
		sfx(sound.remove_tree)
		create_explosion(56.5,15.5,20,9)
		create_sparkles(56.5,15.5,9)
		shortcut1=true
	end
	
	if area=='wizard`s house' and player.y>20 and encounter==39 then
		player_can_move=false
		encounter+=1
	end
	
	--you win
	if player.pears>4 and encounter==45 and player.x==mid(0,player.x,1) and player.y==mid(22,player.y,23) then
		if #explosions==0 and #sparkles==0 then
			time_complete=time()-time_start
			clear_entities()
			sfx(sound.game_over)
			encounter+=1
			game_state='game over'
		end
	end
	
	--non-cut-scene levels
	if score>target_score and on_mission==true then
		on_mission=false
		sfx(sound.level_complete)
		if encounter>6 then
			message='area complete!'
			popup_message(message,hcenter(message),64,60)
			add(completed_areas,area)
		end
	end
	if on_mission==false then
		for f in all(fruit) do
			if f.name=='red_mushroom' or f.name=='brown_mushroom' then
				f.rot_time=-1
				--del(fruit,f)
			end
		end
	end
	
	--level skips
	if on_mission==false and score>target_score+target_score_default and extra_target_scores==2 then
		player.skips+=1
		popup_message('bonus level skip!',max(0,(player.x-mapx)*8-38),(player.y-mapy)*8,60)
		extra_target_scores-=1
		sfx(sound.skip_pickup)
	end
	if on_mission==false and score>target_score+(target_score_default*2) and extra_target_scores==1 then
		player.skips+=1
		popup_message('bonus level skip!',max(0,(player.x-mapx)*8-38),(player.y-mapy)*8-6,60)
		extra_target_scores-=1
		sfx(sound.skip_pickup)
	end
	--adds non-mission areas to completed areas
	if check_completed_area(area)==false and check_mission_area(area)==false then
		add(completed_areas,area)
	end
	
	--spawn magic pear chests
	if check_completed_area(area) and check_chest_area(area) and on_mission==false and on_exit==false then
			
		if area=='south swamp' then
			spawn_chest(6,57)
			del(chest_areas,area)
		end
		if area=='south lake' then
			spawn_chest(35,35)
			del(chest_areas,area)
		end
		if area=='temple walls' then
			spawn_chest(62,19)
			del(chest_areas,area)
		end
		if area=='sand bank' then
			spawn_chest(118,22)
			del(chest_areas,area)
		end
		if area=='temple lake' then
			spawn_chest(41,13)
			del(chest_areas,area)
		end
	end
end

function run_mission()
	if check_mission_area(area) then
		del(mission_areas,area)
		if score==0 then
			target_score=target_score_default
		else
			target_score=ceil(score/target_score_default)*target_score_default
		end
		extra_target_scores=2
		--stops mushrooms picked up after level-complete underflowing score back to lower target
		if target_score<current_game_high_score then
			target_score+=target_score_default
		end
		if max_fruit_level<5 then
			max_fruit_level+=1
		end
		next_fruit_countdown=rnd(fruit_countdown_max)
		message='score '..target_score..' points!'
		popup_message(message,hcenter(message),58,60)
		streak=0
		on_mission=true
		game_time=0
		sfx(sound.start_level)
		if area=='grasslands' then
			spawn_gorilla(26,61)
		elseif area=='outer walls' then
			spawn_bird(39,56)
		elseif area=='riverside' then
			spawn_bird(30,24)
		elseif area=='coastal ruins' then
			spawn_gorilla(104,56)
		elseif area=='the well' then
			spawn_bird(71,52)
		elseif area=='the towers' then
			spawn_tortoise(87,56)
		elseif area=='coastal dunes' then
			spawn_tortoise(121,36)
			spawn_tortoise(121,42)
		elseif area=='haunted woods' then
			spawn_gorilla(96,3)
		elseif area=='dead forest' then
			spawn_tortoise(88,7)
		elseif area=='shady thicket' then
			spawn_tortoise(89,24)
		elseif area=='lost clearing' then
			spawn_gorilla(109,29)
		elseif area=='magic orchard' then
			spawn_gorilla(107,45)
		elseif area=='hidden plains' then
			spawn_gorilla(72,23)
			spawn_tortoise(70,20)
			spawn_tortoise(74,24)
		elseif area=='central swamp' then
			spawn_tortoise(85,38)
			spawn_tortoise(83,43)
		elseif area=='flooded ruins' then
			spawn_bird(72,46)
		elseif area=='deep forest' then
			spawn_tortoise(71,7)
		elseif area=='temple ruins' then
			spawn_bird(51,4)
			spawn_bird(55,9)
		end
		--enemy test area
		if area=='south woods' then
			--spawn_gorilla(13,34)
		end
	end
end
-->8
--player code
function player_controls()

	if stun_time>0 then
		stun_time-=1
	end

	player.newx=player.x
	player.newy=player.y
	player.oldx=player.x
	player.oldy=player.y
	
	--cheats debug
	if btnp(—) then
	end
	
	if btnp(Ž) then
	end

	if btnp(—) then 
		if cheats==true then
			score+=target_score_default
		else
			if hide_ui==true then
				hide_ui=false
			else
				hide_ui=true
			end
		end
	end
	
	if btnp(Ž) and player.skips>0 then
		if on_mission==true then
			player.skips-=1
			score+=target_score_default
			popup_message(target_score_default,(player.x-mapx)*8,(player.y-mapy)*8,30)
			popup_message('level skipped!',max(0,(player.x-mapx)*8),(player.y-mapy)*8-6,60)
			sfx(sound.bonus_skip)
		else
			popup_message('can`t skip!',max(0,(player.x-mapx)*8-10),(player.y-mapy)*8,60)
		end
	end
	
	--player movement controls
	if player.x==player.spr_x/8 and player.y==player.spr_y/8 and stun_time<=0 then
		if btn(‹) then player.newx-=1 sfx(sound.player_move) player.facing='l' end
		if btn(‘) then player.newx+=1 sfx(sound.player_move) player.facing='r' end		

		--keep player on current area (x movement)
		if (player.newx<mapx or player.newx>mapx+15) and (not fget(mget(player.x,player.y),1) or on_mission==true) then
			player.newx=player.oldx
		end
		
		--x scenery collision
		if fget(mget(player.newx,player.newy),0) then
			open_chest()
			player.newx=player.oldx
		end
		--tortoise x collision
		for tortoise in all(tortoises) do
			if tortoise.x==player.newx and tortoise.y==player.newy then
				player.newx=player.oldx
			end
		end
		
		if btn(”) then player.newy-=1 sfx(sound.player_move) end
		if btn(ƒ) then player.newy+=1 sfx(sound.player_move) end
		
		--keep player on current area (y movement)
		if (player.newy<mapy or player.newy>mapy+15) and (not fget(mget(player.x,player.y),1) or on_mission==true) then
			player.newy=player.oldy
		end
				
		--y scenery collision
		if fget(mget(player.newx,player.newy),0) then
			open_chest()
			player.newy=player.oldy
		end
		--tortoise y collision
		for tortoise in all(tortoises) do
			if tortoise.x==player.newx and tortoise.y==player.newy then
				player.newy=player.oldy
			end
		end
	end
	
	if player.newx!=player.oldx or player.newy!=player.oldy then
		stats.walk_distance+=1
	end
	
	player.x,player.y=player.newx,player.newy
	
	--display a message upon entering new area
	if fget(mget(player.x,player.y),1) then
		on_exit=true
		current_area=area
	else
		if (on_exit==true or current_area!=area) and on_mission==false then
			for popup in all(points_popups) do
				del(points_popups,popup)
			end
			message=area
			popup_message(message,hcenter(message),96,60)
			on_exit=false
			--if area has a standard mission, run it.
			run_mission()
			current_area=area
		end
	end
	player.x,player.y=mid(0,player.x,127),mid(0,player.y,63)

end

function update_player_sprite()
	--walk animation for monkey
	if cheats==false then
		--if btn(”) or btn(ƒ) or btn(‹) or btn(‘) then
		if player.x*8!=player.spr_x or player.y*8!=player.spr_y and game_time%2<1 then
			if player.flip==true then
				player.flip=false
			else
				player.flip=true
			end
		end
	else
	--facing animation for pilot
		if player.facing=='r' and cheats==true then
			player.flip=false
		else
			player.flip=true
		end
	end
	--player sprite trails behind the hitbox
	if player.x*8!=player.spr_x then
		if player.x*8>player.spr_x then
			player.spr_x+=2
		else
			player.spr_x-=2
		end
	end
	if player.y*8!=player.spr_y then
		if player.y*8>player.spr_y then
			player.spr_y+=2
		else
			player.spr_y-=2
		end
	end
end

function draw_player()
	if cheats==true then
		palt()
		if not(stun_time>0 and game_time%4<2) then
			spr(player.sp,player.spr_x,player.spr_y,1,1,player.flip)
		end
		palt(14)
	else
		if not(stun_time>0 and game_time%4<2) then
			spr(player.sp,player.spr_x,player.spr_y,1,1,player.flip)
		end
	end
end
-->8
--fruit/chest code
function fruit_collide(ax,ay,bx,by)
	if ax+8>bx and ax<bx+8 and ay+8>by and ay<by+8 then
		return true
	end
end

function bonus_fruit_explosion(x,y,t,c)
	if bonus_circle==true then
		create_explosion(x/8,y/8,t,c)
		bonus_circle=false
	end
end

--new function for fruit x and y
function find_free_square()
	check='not_done'
	while check!='done' do
	
		--picks random coords on current map area
		nfx=flr(rnd(16))+mapx
		nfy=flr(rnd(15))+mapy+1 --stop fruit appearing at top level of screen where ui is

		--picks new random coords if on top of wall tile or too close to player
		while fget(mget(nfx,nfy),0) or abs(nfx-player.x)<2 or abs(nfy-player.y)<2 do
			nfx=flr(rnd(16))+mapx
			nfy=flr(rnd(15))+mapy+1
		end

		--checks if coords match any fruit positions
		coords_match=false
		for i=1,#fruit do
			--coords used need to be draw-style coords
			if fruit[i].x/8==nfx and fruit[i].y/8==nfy then
				coords_match=true
			end
		end
		
		if coords_match==false then
			check='done'
		end
	end
end

function search_table_coords_for_matching_coords()
	coords_match=false
	for i=1,#fruit do
		if fruit[i].x==nfx and fruit[i].y==nfy then
			coords_match=true
		end
	end
end

--used when placing fruit
function spawn_chest(x,y)
	mset(x,y,21)
	create_explosion(x,y,20,10)
end

function open_chest()
	if fget(mget(player.newx,player.newy),2) then
		mset(player.newx,player.newy,22)
		player.pears+=1
		player.skips+=1
		create_explosion(player.newx,player.newy,20,10)
		spawn_pear(player.newx,player.newy)
		sfx(sound.open_chest)
	end
end

function spawn_new_fruit()
	next_fruit_countdown-=1
	--new fruit appears every 0 to 3 seconds
	--10% of the time, a mushroom will appear too	
	if next_fruit_countdown<0 and on_mission==true then
		if rnd(100)>90 then
			new_fruit(flr(rnd(2)+99))
			next_fruit_countdown=rnd(fruit_countdown_max)
		end
		new_fruit(1)
		next_fruit_countdown=rnd(fruit_countdown_max)
	end
end

function spawn_pear(x,y)
	local pe={
	x=x,
	y=y,
	sprite=7,
	age=60,
	rise=0
	}
	add(pears,pe)
end

function update_pears()
	for pe in all (pears) do
		if pe.rise>-8 then
			pe.rise-=0.5
			create_sparkles(pe.x,pe.y,game_time%8+8)
		end
		pe.age-=1
		if pe.age<0 then
			del(pears,pe)
			create_explosion(pe.x,pe.y,20,14)
			create_explosion(pe.x,pe.y-1,20,11)
			create_explosion(pe.x,pe.y-2,20,14)
			create_explosion(pe.x+1,pe.y-1,20,9)
			create_explosion(pe.x-1,pe.y-1,20,9)
		end
	end
end

function draw_pears()
	for pe in all (pears) do
		spr(pe.sprite,pe.x*8,pe.y*8+pe.rise)
	end
end

function new_fruit(level)
	fruit_number+=1
	find_free_square()
	if level==1 then
		local f={
			sp=2,
			x=nfx*8,
			y=nfy*8,
			colour=10,
			id=fruit_number,
			level=1,
			name='banana',
			rot_time=300,
			points=1,
			sfx=16
			}
		bonus_fruit_explosion(f.x,f.y,10,f.colour)
		add (fruit,f)
	elseif level==2 then
		local f={
			sp=36,
			x=nfx*8,
			y=nfy*8,
			colour=8,
			id=fruit_number,
			level=2,
			name='strawberry',
			rot_time=450,
			points=4,
			sfx=17
		}
		bonus_fruit_explosion(f.x,f.y,10,f.colour)
		add (fruit,f)
	elseif level==3 then
		local f={
			sp=35,
			x=nfx*8,
			y=nfy*8,
			colour=2,
			id=fruit_number,
			level=3,
			name='plum',
			rot_time=600,
			points=16,
			sfx=18
		}
		bonus_fruit_explosion(f.x,f.y,10,f.colour)
		add (fruit,f)
	elseif level==4 then
		local f={
			sp=51,
			x=nfx*8,
			y=nfy*8,
			colour=9,
			id=fruit_number,
			level=4,
			name='orange',
			rot_time=750,
			points=64,
			sfx=19
		}
		bonus_fruit_explosion(f.x,f.y,10,f.colour)
		add (fruit,f)
	elseif level==5 then
		local f={
			sp=52,
			x=nfx*8,
			y=nfy*8,
			colour=11,
			id=fruit_number,
			level=5,
			name='pineapple',
			rot_time=900,
			points=256,
			sfx=20
		}
		bonus_fruit_explosion(f.x,f.y,10,f.colour)
		add (fruit,f)
	elseif level==99 then
		local f={
			sp=53,
			x=nfx*8,
			y=nfy*8,
			colour=7,
			id=fruit_number,
			level=99,
			name='red_mushroom',
			points=-5,
			rot_time=450,
			sfx=11,
			stun_time=30
			}
		add (fruit,f)
			
	elseif level==100 then
		local f={
			sp=54,
			x=nfx*8,
			y=nfy*8,
			colour=15,
			id=fruit_number,
			level=100,
			name='brown_mushroom',
			rot_time=600,
			points=-10,
			sfx=11,
			stun_time=60
		}
		add (fruit,f)
	end
end

function update_fruit()
	--fruit eating sequence
	for f in all(fruit) do
	local score_payload=0
		if fruit_collide(player.spr_x,player.spr_y,f.x,f.y) then
			create_sparkles(player.x,player.y,f.colour)
			del(fruit,f)
			eat_cycles=2
			score_payload+=f.points
			--stats updating
			if f.name=='banana' then
				stats.bananas+=1
			elseif f.name=='strawberry' then
				stats.strawberries+=1
			elseif f.name=='plum' then
				stats.plums+=1
			elseif f.name=='orange' then
				stats.oranges+=1
			elseif f.name=='pineapple' then
				stats.pineapples+=1
			elseif f.name=='red_mushroom' then
				stats.red_mushrooms+=1
			elseif f.name=='brown_mushroom' then
				stats.brown_mushrooms+=1
			end
			
			--mushrooms end your streak
			if f.name=='red_mushroom' or f.name=='brown_mushroom' then
				streak=1
				popup_message('penalty!',(player.x-mapx)*8,(player.y-mapy)*8-6,30)
				sfx(sound.eat_mushroom)
				stun_time+=f.stun_time
			else
				--eating fruit consecutively creates higher level fruit worth more points
				streak+=1
				if last_fruit!=f.name and streak>1 then
					streak=1
				end
				if streak%2==0 then
					sfx(f.sfx)
					sfx(sound.fruit_upgrade)
				else
					sfx(f.sfx)
				end
				if streak%2==0 and streak>0 then
					next_fruit_level=f.level+1
					if next_fruit_level>max_fruit_level then
						next_fruit_level=max_fruit_level
					end
					bonus_circle=true
					new_fruit(next_fruit_level)
					popup_message('bonus!',(player.x-mapx)*8,(player.y-mapy)*8-6,30)
				end
			end
			score_payload+=f.points*(streak-1)
			last_fruit=f.name
			popup_message(score_payload,(player.x-mapx)*8,(player.y-mapy)*8,30)
			score+=score_payload
		end
		--rotten fruit disappears
		f.rot_time-=1
		if f.rot_time<0 then
			create_explosion(f.x/8,f.y/8,5,4)
			del(fruit,f)
			sfx(sound.rotten_fruit)
		end	
	end
end

function draw_fruit()
	--draws fruit
	for f in all(fruit) do
		--fruit about to disappear wobbles
		if  f.rot_time<120 and game_time%4<3 then
			spr(f.sp,f.x,f.y-1)
		else
			spr(f.sp,f.x,f.y)
		end
	end
end
-->8
--screens
function splash()
	cls()
	rect(51,56,73,81,4)
	rectfill(52,55,74,79,5)
	rect(52,55,74,80,9)
	spr(3,55,56,2,2)
	print('extar',53,74,4)
	print('extar',54,73,9)
	splashscreentime+=1
	if stat(24)!=26 and current_music!='overture' then
		music(muzak.overture)
		current_music='overture'
	end
	if btnp(—) then
		splashscreentime+=75
	end
end

function update_tips()
	
	tip_x-=1
	
	if tip_x<0-(#tips[tip_to_show])*4 then
		tip_to_show=ceil(rnd(#tips))
		tip_x=127
	end

end

function update_stats()
	
	stats_messages[1]='you ate '..stats.bananas..' bananas'
	stats_messages[2]='you ate '..stats.strawberries..' strawberries'
	stats_messages[3]='you ate '..stats.plums..' plums'
	stats_messages[4]='you ate '..stats.oranges..' oranges'
	stats_messages[5]='you ate '..stats.pineapples..' pineapples'
	stats_messages[6]='you ate '..stats.red_mushrooms..' red mushrooms'
	stats_messages[7]='you ate '..stats.brown_mushrooms..' brown mushrooms'
	stats_messages[8]='you walked '..(stats.walk_distance/1000)..' kilometres' 
	
	stat_x-=1
	
	if stat_x<0-(#stats_messages[stat_to_show])*4 then
		stat_to_show+=1
		if stat_to_show>8 then
			stat_to_show=1
		end
		stat_x=127
	end

end


function title()
	cls()
	--pick a random faded out map area
	for i=0,7 do
		pal(i,0)
	end
	for i=8,15 do
		pal(i,1)
	end
	pal(4,1)
	map(0,32,0,0,16,16)
	pal()
	palt(14)
	
	sspr(80,0,48,32,16,8,96,64)
	
	titletext1='mystery of the magic forest'
	titletext2='press —+Ž to start'
	titletext3='difficulty: easy normal hard'
		
	print(titletext1,hcenter(titletext1),82,10)
	print(titletext2,hcenter(titletext2),88,7)
	print(titletext3,hcenter(titletext3),94,7)
	if difficulty=='easy' then
		print('easy',56,94,10)
		line(56,100,70,100,10)
	elseif difficulty=='normal' then
		print('normal',76,94,10)
		line(76,100,98,100,10)
	elseif difficulty=='hard' then
		print('hard',104,94,10)
		line(104,100,118,100,10)
	end
	update_tips()
	print(tips[tip_to_show],tip_x,110,9)
	
	print('v2.1 2019, 2020',1,122,7)
	if cheats==true then
		print('cheats',0,115,8)
	end

	if btn(—) and btn(Ž) then 
		if difficulty=='easy' then
			target_score_default=125
		elseif difficulty=='normal' then
			target_score_default=250
		elseif difficulty=='hard' then
			target_score_default=500
		end
		time_start=time()
		game_state='main'
		music(muzak.woods)
	end
	--menu
	if btnp(‘)	then
		difficulty_option+=1
	end
	if btnp(‹) then
		difficulty_option-=1
	end
	if difficulty_option<1 then
		difficulty_option=3
	elseif difficulty_option>3 then
		difficulty_option=1
	end
	if difficulty_option==1 then
		difficulty='easy'
	elseif difficulty_option==2 then
		difficulty='normal'
	elseif difficulty_option==3 then
		difficulty='hard'
	end
end

--src=https://pastebin.com/skuBnY4g
function cheat_input()
 if (btnp(”)) add(cheat_buffer,'”')
 if (btnp(ƒ)) add(cheat_buffer,'ƒ')
 if (btnp(‹)) add(cheat_buffer,'‹')
 if (btnp(‘)) add(cheat_buffer,'‘')
 if (btnp(—)) add(cheat_buffer,'—')
 if (btnp(Ž)) add(cheat_buffer,'Ž')
		 
	while #cheat_buffer>10 do
		del(cheat_buffer,cheat_buffer[1])
	end

	cheatstr=''
	for i=1,#cheat_buffer do
		cheatstr=cheatstr..cheat_buffer[i]
	end
	
	if cheatstr=='””ƒƒ‹‘‹‘—Ž' then
		cheats=true
		cheatbuffer={}
		player.sp=6
		wizard.sp=5
		wizard.c=10
		if cheat_sound_played!=true then
			sfx(sound.cheats)
			cheat_sound_played=true
		end	
	end		
end

function game_over_screen()
		
	clear_entities()
	
	if stat(24)!=52 and current_music!='game_over' then
		music(muzak.game_over)
		current_music='game_over'
	end
	
	for i=0,7 do
		pal(i,0)
	end
	for i=8,15 do
		pal(i,1)
	end
	pal(4,1)
	map(0,16,0,0,16,16)
	pal()
	palt(14)
	sspr(80,0,48,32,40,0)
	sspr(56,8,8,8,32,40,16,16)
	sspr(8,0,8,8,56,40,16,16)
	sspr(56,0,8,8,80,40,16,16)
	
	if difficulty=='easy' then
		if time_complete<time_best_easy and cheats==false then
			time_best_easy=time_complete
		end
	elseif difficulty=='normal' then
		if time_complete<time_best_normal and cheats==false then
			time_best_normal=time_complete
		end
	elseif difficulty=='hard' then
		if time_complete<time_best_hard and cheats==false then
			time_best_hard=time_complete
		end
	end
		
	--calculates min:sec.fracs for current playthrough
	time_complete_seconds=tostr(flr(time_complete%60))
	if #time_complete_seconds==1 then
		time_complete_seconds='0'..time_complete_seconds
	end
	time_complete_fractions=flr((time_complete%1)*1000)

	--calculates min:sec.fracs for best easy playthrough
	time_best_easy_seconds=tostr(flr(time_best_easy%60))
	if #time_best_easy_seconds==1 then
		time_best_easy_seconds='0'..time_best_easy_seconds
	end
	time_best_easy_fractions=flr((time_best_easy%1)*1000)
	
	--calculates min:sec.fracs for best hard playthrough
	time_best_normal_seconds=tostr(flr(time_best_normal%60))
	if #time_best_normal_seconds==1 then
		time_best_normal_seconds='0'..time_best_normal_seconds
	end
	time_best_normal_fractions=flr((time_best_normal%1)*1000)
	
	--calculates min:sec.fracs for best hard playthrough
	time_best_hard_seconds=tostr(flr(time_best_hard%60))
	if #time_best_hard_seconds==1 then
		time_best_hard_seconds='0'..time_best_hard_seconds
	end
	time_best_hard_fractions=flr((time_best_hard%1)*1000)

	message='game over!'
	print(message,hcenter(message),58,10)
	print('it took you'..' '..flr(time_complete/60)..':'..time_complete_seconds..'.'..time_complete_fractions,16,66,7)
	--print(flr(time_complete/60)..':'..time_complete_seconds..'.'..time_complete_fractions,16,72,7)
	if cheats==true then
		print('but you`re a cheater\nso it doesn`t count!',16,80,8)
	else
		print('best times:',16,73,10)
		print('easy   '..flr(time_best_easy/60)..':'..time_best_easy_seconds..'.'..time_best_easy_fractions,16,80,7)
		print('normal '..flr(time_best_normal/60)..':'..time_best_normal_seconds..'.'..time_best_normal_fractions,16,86,7)
		print('hard   '..flr(time_best_hard/60)..':'..time_best_hard_seconds..'.'..time_best_hard_fractions,16,92,7)
	end
	
	gameoverscreentime+=1
	
	if gameoverscreentime>60 then
		print('press — to reset',16,101,8)
		print('press Ž to save screenshot',16,107,7)

		if btnp(—) then
			reset()
		end
		if btnp(Ž) then
			extcmd('screen')
		end
	end
	
	update_stats()
	print(stats_messages[stat_to_show],stat_x,115,9)
end
-->8
--npcs
function wizard_appear()
	if wizard_poof!=wizard.show and game_state=='main' then
		create_explosion(wizard.x,wizard.y,20,wizard.c)
		create_sparkles(wizard.x,wizard.y,wizard.c)
		wizard_poof=wizard.show
		sfx(sound.wizard_spell)
	end
end

function draw_wizard()
	if wizard.show==true then
		spr(wizard.sp,wizard.x*8,wizard.y*8)
	end
end

function spawn_gorilla(x,y)
	local gorilla={
		x=x,
		y=y,
		sp=32,
		score=0,
		score_payload=0,
		old_x=0,
		old_y=0
	}
	gorilla.sp_x=gorilla.x*8
	gorilla.sp_y=gorilla.y*8
	add (gorillas,gorilla)
end

function update_gorillas()
	for gorilla in all(gorillas) do
		gorilla.old_x=gorilla.x
		gorilla.old_y=gorilla.y
		if time()%1==0 then
			if player.x<gorilla.x then
				gorilla.x-=1
			elseif player.x>gorilla.x then
				gorilla.x+=1
			end
			--scenery collision x
			if fget(mget(gorilla.x,gorilla.y),0) then
				gorilla.x=gorilla.old_x
			end
			if player.y<gorilla.y then
				gorilla.y-=1
			elseif player.y>gorilla.y then
				gorilla.y+=1
			end
			--scenery collision y
			if fget(mget(gorilla.x,gorilla.y),0) then
				gorilla.y=gorilla.old_y
			end
			if gorilla.x!=gorilla.old_x or gorilla.y!=gorilla.old_y then
				sfx(sound.gorilla_move)
			end
		end
		--gorillas eat fruit
		for f in all(fruit) do
			if gorilla.sp_x==f.x and gorilla.sp_y==f.y then
				create_sparkles(f.x,f.y,f.colour)
				sfx(sound.gorilla_eat)
				del (fruit,f)
			end
		end
		--gorilla deduct points
		if gorilla.x==player.x and gorilla.y==player.y then
			score-=10
			gorilla.score_payload-=10
			gorilla.touching=true
			gorilla.score+=10	
		else
			--display points payload
			if gorilla.score_payload<0 and gorilla.touching==true then
				popup_message(gorilla.score_payload,(gorilla.x-mapx)*8,(gorilla.y-mapy)*8,30)
				gorilla.score_payload=0
				sfx(sound.gorilla_attack)
				gorilla.touching=false
			end
		end

		if gorilla.score>=250 or on_mission==false then
			--display points payload on death
			if gorilla.score_payload<0 then
				popup_message(gorilla.score_payload,(gorilla.x-mapx)*8,(gorilla.y-mapy)*8,30)
				gorilla.score_payload=0
				sfx(sound.gorilla_attack)
				gorilla.touching=false
			end
			create_explosion(gorilla.x,gorilla.y,15,5)
			create_sparkles(gorilla.x,gorilla.y,5)
			del(gorillas,gorilla)
		end
		--sprite animation
		if gorilla.x!=gorilla.sp_x/8 or gorilla.y!=gorilla.sp_y/8 then
			if game_time%8<4 then
				gorilla.sp=48
			else
				gorilla.sp=32
			end
		else
			gorilla.sp=32
		end		
	end
end

function draw_gorillas()
	for gorilla in all(gorillas) do
		spr(gorilla.sp,gorilla.sp_x,gorilla.sp_y)
		
		--gorilla's sprite trails behind
		if gorilla.sp_x/8<gorilla.x then
			gorilla.sp_x+=1
		end
		if gorilla.sp_x/8>gorilla.x then
			gorilla.sp_x-=1
		end
		if gorilla.sp_y/8<gorilla.y then
			gorilla.sp_y+=1
		end
		if gorilla.sp_y/8>gorilla.y then
			gorilla.sp_y-=1
		end
	end
end

function spawn_tortoise(x,y)
	local tortoise={
		x=x,
		y=y,
		sp=39,
		id=rnd(999),
		score=0,
		old_x=0,
		old_y=0
	}
	tortoise.sp_x=tortoise.x*8
	tortoise.sp_y=tortoise.y*8
	add (tortoises,tortoise)
end

function update_tortoises()
	for tortoise in all(tortoises) do
		tortoise.old_x=tortoise.x
		tortoise.old_y=tortoise.y
		if game_time%10==0 then
			if btn(‘) then
				tortoise.x-=1
			end
			if btn(‹) then
				tortoise.x+=1
			end
			--scenery collision x
			if fget(mget(tortoise.x,tortoise.y),0) then
				tortoise.x=tortoise.old_x
			end
			--player collision x
			if player.x==tortoise.x and player.y==tortoise.y then
				tortoise.x=tortoise.old_x
			end
			--y movement
			if btn(ƒ) then
				tortoise.y-=1
			end
			if btn(”) then
				tortoise.y+=1
			end
			--scenery collision y
			if fget(mget(tortoise.x,tortoise.y),0) then
				tortoise.y=tortoise.old_y
			end
			--player collision y
			if player.x==tortoise.x and player.y==tortoise.y then
				tortoise.y=tortoise.old_y
			end
			if tortoise.x!=tortoise.old_x or tortoise.y!=tortoise.old_y then
				sfx(sound.gorilla_move)
			end
			--check if tortoise is in same area as player
			if flr(player.x/16)*16!=flr(tortoise.x/16)*16 or flr(player.y/16)*16!=flr(tortoise.y/16)*16 then
				tortoise.x=tortoise.old_x
				tortoise.y=tortoise.old_y
			end
			--tortoise-tortoise collision
			local my_x=tortoise.x
			local my_y=tortoise.y
			local my_id=tortoise.id
			for i=1,#tortoises do 
				if my_x==tortoises[i].x and my_y==tortoises[i].y and my_id!=tortoises[i].id then
					tortoise.x=tortoise.old_x
					tortoise.y=tortoise.old_y
				end
			end
		end
		--eating fruit
		for f in all(fruit) do
			if tortoise.sp_x==f.x and tortoise.sp_y==f.y then
				create_sparkles(f.x,f.y,f.colour)
				sfx(sound.gorilla_eat)
				del (fruit,f)
			end
		end
		if on_mission==false then
			create_explosion(tortoise.x,tortoise.y,15,3)
			create_sparkles(tortoise.x,tortoise.y,3)
			del(tortoises,tortoise)
		end
		--sprite animation
		if tortoise.x!=tortoise.sp_x/8 or tortoise.y!=tortoise.sp_y/8 then
			if game_time%8<4 then
				tortoise.sp=55
			else
				tortoise.sp=39
			end
		else
			tortoise.sp=39
		end		
	end
end

function draw_tortoises()
	for tortoise in all(tortoises) do
		spr(tortoise.sp,tortoise.sp_x,tortoise.sp_y)
		
		--tortoise's sprite trails behind
		if tortoise.sp_x/8<tortoise.x then
			tortoise.sp_x+=1
		end
		if tortoise.sp_x/8>tortoise.x then
			tortoise.sp_x-=1
		end
		if tortoise.sp_y/8<tortoise.y then
			tortoise.sp_y+=1
		end
		if tortoise.sp_y/8>tortoise.y then
			tortoise.sp_y-=1
		end
	end
end

function spawn_bird(x,y)
	local bird={
		x=x,
		y=y,
		charging='no',
		charge_direction=1,
		cooldown=0,
		flip_x=false,
		has_hit=false,
		sp=37,
		score=0,
		old_x=0,
		old_y=0
	}
	bird.sp_x=bird.x*8
	bird.sp_y=bird.y*8
	add (birds,bird)
end

--bird charges along x or y axis at player. knocks off 50 points each hit.
function update_birds()
	for bird in all(birds) do
		--bird charges left/right if y-aligned with player
		if player.y==bird.y and bird.cooldown==0 and bird.charging=='no' then
			bird.charging='x'
			sfx(sound.bird_charge)
			if player.x<bird.x then
				bird.charge_direction=-1
				bird.flip_x=true
			else
				bird.charge_direction=1
				bird.flip_x=false
			end
		end
		--bird charges up/down if x-aligned with player
		if player.x==bird.x and bird.cooldown==0 and bird.charging=='no' then
			bird.charging='y'
			sfx(sound.bird_charge)
			if player.y<bird.y then
				bird.charge_direction=-1
			else
				bird.charge_direction=1
			end
		end
		if bird.charging=='x' and game_time%2==0 then
			bird.x+=bird.charge_direction
		end
		if bird.charging=='y' and game_time%2==0 then
			bird.y+=bird.charge_direction
		end
		--bird hits a wall or edge of area and stuns itself
		if fget(mget(bird.x,bird.y),0) or (flr(player.x/16)*16!=flr(bird.x/16)*16 or flr(player.y/16)*16!=flr(bird.y/16)*16) then
			if bird.charging=='x' then
				bird.x-=bird.charge_direction
			else
				bird.y-=bird.charge_direction
			end
			bird.charging='no'
			bird.cooldown=30
			sfx(sound.bird_crash)
			bird.has_hit=false
		end
		--bird deducts points
		if bird.has_hit==false and player.x==bird.x and player.y==bird.y then
			score-=40
			popup_message('-40',(bird.x-mapx)*8,(bird.y-mapy)*8,30)
			bird.has_hit=true
			bird.score+=40
			sfx(sound.gorilla_attack)
		end
		if bird.score>=250 then
			del(birds,bird)
		end
		--peck animation whilst charging
		if bird.charging=='no' then
			bird.sp=37
		else
			if game_time%4>1 then
				bird.sp=38
				if game_time%8>3 then
					sfx(sound.bird_flap)
				end
			else
				bird.sp=37
			end
		end
		if on_mission==false then
			create_explosion(bird.x,bird.y,15,10)
			create_sparkles(bird.x,bird.y,10)
			del(birds,bird)
		end
	end
end

function draw_birds()
	for bird in all(birds) do
		if bird.cooldown>0 then
			bird.cooldown-=1
		end
		--bird flickers whilst stunned
		if bird.cooldown>0 and game_time%2==0 then
		else
			spr(bird.sp,bird.sp_x,bird.sp_y,1,1,bird.flip_x)
		end
		--bird's sprite trails behind
		if bird.sp_x/8<bird.x then
			bird.sp_x+=4
		end
		if bird.sp_x/8>bird.x then
			bird.sp_x-=4
		end
		if bird.sp_y/8<bird.y then
			bird.sp_y+=4
		end
		if bird.sp_y/8>bird.y then
			bird.sp_y-=4
		end	
	end
end

-->8
--particle effects
function create_explosion(x, y, t, c)
	for i=1,4 do
		local ex={
			x=x,
			y=y,
			r=rnd(i),
			t=rnd(t),
			c=c
		}
		add(explosions,ex)
	end
end

function update_explosions()
	for ex in all(explosions) do
		if #explosions>0 then
			ex.r+=1
			ex.t-=1
			if ex.t<0 then
				del(explosions,ex)
			end
		end
	end
end

function draw_explosions()
	for ex in all(explosions) do
		circ(ex.x*8+4, ex.y*8+4, ex.r, ex.c)
	end
end

function create_sparkles(x,y,c)
	for i=1,10 do
		local sp={
			x=x,
			y=y,
			xc=(rnd(1)-0.5)/2,
			yc=(rnd(1)-0.5)/2,
			c=c,
			age=30
		}
		add(sparkles,sp)
	end
end

function update_sparkles()
	for sp in all(sparkles) do
		if #sparkles>0 then
			sp.x+=sp.xc
			sp.y+=sp.yc
			sp.age-=1
			if sp.age<0 or game_state!='main' then
				del(sparkles,sp)
			end
		end
	end
end

function draw_sparkles()
	for sp in all(sparkles) do
		circ(sp.x*8,sp.y*8,0,sp.c)
	end
end
__gfx__
00000000e444444ee44eeeee0000000090000000ee9aa9ee05888e00e999beee44444444444444447a7a7a0eee007a007a7a70ee0a7a7a0e007a00eee07a00ee
00000000e47ff74eaaaeeeee0000009949900000e9aaaa9e058dd7709eebb9ee4444444444444444aaaaaa70e07aaa70aaaaaa007aaaa740a7aa7a0e07a77a0e
00700700eeffffee9aaeeeee0000994494499000eec44cee0888d770eeeb9b9e4444444444444444aa4444aa00a44aa4aa44aa47a444aa40aaa4a7407a4aa740
00077000f4f55f4eaaaaeeee0099440090044990ee4404ee088888e0eebbb9be4444444444444444aa4000aa47a40aa4aa40aa4aa400aa40aa444aa0aa44aa40
00077000f444444fe9aaaaee09440000900004497799999e00666600e3bbbb9b4444444444444444aa4000aa4aa40aa4aa40aa4aa400aa40aa400aa4a4004a40
00700700e44ff4efee9aaaa40999440090044999669aa99e06887860eb3bbbb94444443434444444aa4000aa4aa40aa4aa40aa4aa400aa40aa400aa4a40e0a40
00000000444ee44eeeeea9ae094099449449904996dddd9e06888800e3b3b3be4444434343444444aa7a7aa40aa4aaa4aa40aa4aa40aaa40aa400aa4aa00aa40
00000000ffeeeffeeeeeeeee0940009949900049ee5ee5ee00500500ee3b3bee4444443434344444aaaaaa40e0aaaaa4aa40aa40aaaaaa40aa400aa4aaaaaa40
33333333333333333333333309400004940000493333333333999999ee7777ee4444434343444444aa44aaa0ee0aaaa4aa40a40e0aaaaa40aa400a404aaa4a40
3b3733b3333333333333333309400994949900493a4444a33b922229ee0000ee4444443434344444aa404aaa0ee04444044040eee0444440a40e040e0444040e
3333333333333333333333330949944090449949a4444a4933944449777777774444444343444444aa400aaa40ee0000e00e0eeee000000e00eee0e0f000e0ee
3333b33333333333333333330944400090004449947a494939000009ee4f4f4e4444444444444444aa400aa440eeeeeeeeeeeeee0940eeeeeee00e0f4f40eeee
333333373333333333b33b33009944009004499094aa499290000092eeffff4e4444444444444444aa7a7a440eeeeeeeeeeeee00940eeeeeee04f04ff4f40eee
37333b333333333333b3b3330000994494499000a9999949a9999949e777777e4444444444444444aaaaa440eeeeeeeeeee000999490eeeeee0ff4ffff4f0eee
b3333333333333333bbbbb3300000099999000009444494294444942e777777e4444444444444444aa44440eeeeeeeeeee09994444490eeeee044ff7f4f40eee
33333b33333333333333333300000000900000002999992329999923ee7ee7ee4444444444444444044000eeeeeeeeeee094444f44ff40eeeee0ff7f7ff40eee
eeeeeeee3333b4b3b4b3b333eeeebeeebebbbbebeeeee9aeeeeeeeeeeeeeeeee4444444454444444e00eeeee0000000ee09444ff44fff0eeee094ff7ff40eeee
eeee555e3b3b3b4b3b4b3b3beeeebbeeebbbbbbeeeee4a00eeeeeeeeeeeee9994444545544455444eeeeeee0a7a7a7a009444470ff70f0eeee04442ff40eeeee
e5555000b4b4b3b4b3b3b4b3e122bbbe8b8b8b8baaee444eaaeeeeeeeebbea9a4504544044544444eeeeee07aaaaaaa404ff4f77ff77f0ee0049444200eeeeee
e55058584b3b4b4b3b4b3b3b12222bee9889889899a9a4ee99a9a4eeeb33b9994445454540444450eeeeee0aaaa44aa404ff4ffffffff0e094944440eeeeeeee
55005555b4b3b4b3b4b3b4b3112222eee888888e949a9aee949a9444b3bb3b9e4445505554444455eeeee07aaa400444024f4ffffffff0094944420eeeeeeeee
050005503b4b3b4b4b3b4b3b121222eee898898ee404aaeee404a4a9b3333b9e4444450544444005eeee0aaaa440e000e0244ffff00f0094944420eeee00000e
05500005b3b4b4b4b4b4b4b3112121eeee8888eeee0eeeee00eee40a9e99e9ee4044405044555554eeee0aaa400eeeee000244fffff44949444200eee0a7a740
0055055e3b3b4b4b4b4b3b3be1111eeeeee88eeeee00eeee0eeeee0e9e99e9ee4504454544450554eeee0aaa40eeeee0990444424242444424207a0e07aaaa40
eeeeeeee3333b4b4b4b3b333ee99b9eeebaeabaeee8878eeeeffffeeeeeeeeee4450505044505455eeee0aaa40eeeee040702424242400004207aa700aa44a40
eeee555e33334b4b4b4b3333e99bbb9eeebabaeee878888effffffffeeeee9994444550544550445eeee0aaa40eeee0207a0424242407a7a007aa4a4aa440a40
e555500033334544454533339999b999eebabaeee888878e4ffffff4eebbea9a4444455544050444eeee0aaa440eee040aa000004407aaaa40aa4040aaaaaa40
e5505858333545454544533349999999ee9999ee8878887804444440eb33b9994444054004500544eeeee0aaa40ee0020aa7a7a7007a444a40aaaa40aaaaa40e
55005555335454434454453399999999e949494e88887888e00ff00eb3bb3b9e4440550500555554eeeee0aaaaa00aa00aaa44aaa0aa400a40044aa4aaa4440e
50000550344343533543354349999999e494949ee788887eeefffeeeb3333b9e4455540450554455eeeeee0aaaaaaaa40aa4004aa4aaaaaa40aaaaa40aaaaaa0
500000053334435434343333e999999ee949494eeee66eeeee440eee99ee99ee4444445455455444eeeeee044aaaaa440aa40e0aa40aaaaaa44aaa40e0aaaa44
550ee0553333333433333333ee4949eeee9494eeeee66eeeee00eeeee9ee9e9e4444444445445444eeeeeee00444440000440e04440444444404440ee0444440
333434344364434346434343ddddddc7ddddddc73333333333333333333333333338989898989333444444444454444445444444ddddddc7ddddddc765666565
334344444444444434444434cc7ccdddcc7ccddd3333343433343434343333333389898989895933444444444444444444444444cc7ccdddcc7ccddd65555550
34344444dddddd4444444443ddddddd7ddddddd7333343434343434343433333389898989895459344444444dddddd4444444444ddddddd7ddddddd765555555
434464dddd7cdddddd444644dc7dc7cddc7dc7cd3334343434344444443433338989898989542459444454dddd7cdddddd444544dc7dc7cddc7dc7cd55555550
44444ddddddddd7cddd44443cdddddddcddddddd333343444444444444433333355555555544424344444ddddddddd7cddd44444cdddddddcddddddd65555550
34444ddcc7cccddddd7d6444dddddddddddddddd333434444444444444343333349944999454242344444ddcc7cccddddd7d5444dddddddddddddddd55555550
4644d7dddddddccccccdd444dc7ccdd444dccddd334344444444444444434333347c4477c44442434544d7dddddddccccccdd444dc7ccdd444dccddd65555555
3444ddcccddd7ddddddddd44dddddd43344dddcc34344444444444444444343334cc44ccc45424234444ddcccddd7ddddddddd44dddddd44454dddcc60500500
444dddd7ddddddc7cccddd44dddddd433344ddc73344444444444444444443333555455554444243444dddd7dd3dddb7cccddd44dddddd44444dddc744444345
444ddcddcc7ccddddddddd44cc7ccd444444cddd3434444444444444444434333444444444542423444ddcddcc3c53bddddddd44cc7ccd45444dcddd45444444
444dddddddddddd7cdc7cd46ddddddd4444dddd73344444444444444444443433444444444444243444ddddddb355357cdc7cd45ddddddd444ddddd744454444
44dddd7ddc7dc7cdddddd444dc7dc7cddc7dc7cd343444444444444444444433355544999454242344dddd7ddb3dc3cdddddd444dc7dc7cddc7dc7cd44444344
44dc7ccccdddddddcccdd444cdddddddcddddddd33444444444444444444434334664477c444423344dc7ccccb5b53ddcccdd444cdddddddcddddddd44444444
34ddddd7ddddddddddddd443dddddddddddddddd343444444444444444444433346644ccc454233344ddddd7d55b55bdddddd444dddddddddddddddd43444444
44dddddddc7ccddddd77d444dc7ccddddc7ccddd334344444444444444444343346645555444333344dddddddc7bcdbddd77d444dc7ccddddc7ccddd44445454
34dcccddddddddcc7ccdd444ddddddccddddddcc343444444444444444443433346644444453333344dcccddddddd55c7ccdd444ddddddccddddddcc44444444
44dd7dddccc7cddddddc7444ddddddc3333b3b33334344444444444444434343344444444444444444dd7dddccc7cddddddc7444444445444444455455444444
444dddddddddddc7ddddd464ccbc3dd33b3b3bb33334344444444444444434334444444444445444444dddddddddddc7ddddd454444444444444444455454554
4444dccc7ccccddddd7dd4443dbd3bd333bbbbb333334344444444444443434344344344444444444444dccc7ccccddddd7dd444446665665656664444444554
4644dddddddddddc7cdd44443cbdcbc33b3bbbb333333434444444444434333344343444444554444544dddddddddddc7cdd4444445555555555504455554554
44444ddd7cdd7cddddd444433db3dbdb3b3bbbb3333333434444444343433333433333444455554444444ddd7cdd7cddddd44444546555555555504455554554
344644444dd4444444443434bdb3dbdb3bbbbbb33333343434343434343333334444444444444444444544444dd4444444444444446550500065504444444444
444444444444444343434343bcb3cddb33bbbbbb3333334343434343333333334444434444444554444444444444444444444444446555444455554455455554
3434343434343434343333333dd3ddcb3b3b3b333333333333343433333333334443444454444444444444445444444444444444445550444565504455455554
4544444444555544446550443333333333333333333333334b44b64b33b3b3b39393939394949494364545233645452333333333446555454465504444333333
444454444465504444555045366666666666666666666603654464563b4b4a4b3939393949494949364545233645452336433333456550444455504544343443
566566654465505466655566362222522225522225222203b65b55b4b4a3b4b39393939394949494364545233645452336453333446550666565554433333443
5555555544465044555555553645545459a55a9545455403444544653b4b4b3b3939393949494949364545233655450336453323445555555555504444443443
55555555446550445555555536522544224444224452250365b54b44b3b4b4a49393939394949494364545236555555036454523446555555555504444443443
055000054455504400055050330003644466654440300033455655643b3b4b3b3939393949494949364545230500005036454523440050005000504433333333
40544444546555444465504433333364460000544033333344456444333444339393939394949494364545233055550336454523444444544444444444344443
44444444446550444465505433333365552222555033333344555554334444433939393949494949364545233300003336454523445444444444544444344443
122212221222122212221222122212221534261187871111569082928393829283936567656597976565a5151515151515151515153636c507079797070707e6
7411878711111154647411115491676583938686839365658393656583936565214646212146218787214646464646468665869797866596656565a4e5151515
1323132313231323132313231323132315251111211111111155839382928393656765656565656565a4e5151515151515151515151536c59696866565868617
75111111111154916781646491f66565176565866565656565656596656565654646464646462111112146214646212165656565656565656565a41515151515
12222121214611211111111111111222152511464621110111566690839382926565806690656565a4e5151515151515151515b5151515c59665656565656517
751111546464916565656765676565651786a4b4c46565656565f56565f5f56546211222212112221111122221461222656586a4b4b4b4b4b4b4e51515151515
132346211111111111111111111113231525211121112111111101566690839365657501556565a4e51515151515151515151515153615c56565658696656517
816464919665656565656565656565961765a5b5c5a4b4c4f56565a4b4c4f56546211323111113231111132311211323656565a6b6b6e4d4b6b6e41515151515
12222111111111112111211111111222152546212146214611111111115666669696816491a4b4e5151515151515151515b5361536b515c56565659665656517
9665656517f665f6f6f66765656596171765a6b6c6a5b5c5868665a5b5c5f5f546462111111111111111111121464621866565656565a5c56565a51515151515
132311112111111111211111112113233426212146211111111101111177777756a4b4b4b4e5151515151515151515151515b515361515c5676565656565f517
96f6656517f6f6f6f6f6f665656765171765a4b4c4a6b6c6f59686a6b6c6f5f521462111111111111111111111214621659665869665a6c68665a6b6e4151515
122211111111211111111111111112222677211111211111111111111112227777051515151515151515151515151515151515151515d4c665656565d6e6f517
1765f6651765f6f6f66565f6656565961765a5b5c5f586869665968665f5656512221111122211111222111112222146869686966565656586656565a5151515
13231111111111111111111121111323122277112146211111111111111323122206164415151515151515151515151515151515d4b6c6f5656565d627e78617
1765656517f6f6f6f6f66565656565979786a6b6c6f56596658686969665656513231111132311111323111113232146656565866565656565658665a5151515
122211111111111111211111112112221323122211111111112177211112221323122205151515151515151515151515151515d4c66565656565d627e796f517
d7656565176565f6659665656565659797658665f5869665a4b4c4966565968046211111111111111111111111214646656586a4b4b4b4b4b4b4b4b4e5151515
1323111111111121111111111111132312221323110111110111111111132312221323053615151515151515151515151515d4c66565869665d627e786f58617
a4b4b4c41765f66565966565656565961765656565968686a5b5c5869665807621462111111111111111111111214621656565a6b6b6b6b6b6b6e41515151515
12221121211111112111111121111222132312221111111111111111111222132312220536151515151515151515151515d4c6658665656565d727e6f5f5f517
a5b515c51765656596176565656565171765656565a4b4c4a6b6c6a4b4c476878721122211111222111112221111122265656565658665866565a51515151515
132311112146211111112121111113231222132311117721111101117713231222132305153615151515151515151515d4c66586d6e686658665d727e6868617
a5b515c51765656596176565d66565171796656586a5b5c5a4b4c4a5b5c574878746132311111323111113231121132386658665866565656565a51515151515
122211462121111111214611112112221323122211112121111111111112221323122205361515151515151515d4b6b6c66565d6f4e76596868665d727e66517
a5b5b5c51765656596176565966565171796656596a6b6c6a5b5c5a6b6c68174214621111111111111111111214621216565a4b4b4b4b4b4b4b4e51515151515
13234611112121111111211111211323122213231111112121117711111323122213230515151515d4b6b6b6b6c665e6179686d7e786869686658665d7e76517
a5b5b5c51765656565176565176565171796656565658686a6b6c68686656581462111211111112111111121214646466565a6b6b6b6b6b6b6b6b6e415151515
12221222122212221222122212221222132311114621212146111111111222132304144515151515c5d60765f6f66517f4f48665658686178665868665868617
a5b5b5c517656565651765651765651717656596659665658665866565656565122221461222214612222146122221468665866565656565866565a515151515
13231323132313231323132313231323122287872121462121211111111323122205363636361515c517676597976517f4f49686979796f4f4f4f4f4f4f4f4f4
a6b6b6c6d707070707270707270707e7d7078292070782920707829207078292132346461323464613234646132346216565656597978665656565a515151515
24122212220424122277122277041424132387871222464646464646461222132306164436363636c51767659797651717d607079797070707070707070707e6
d60707070707070707270707070707e682928393829283938292839382928393d60707070707744621464654070707e665656565979796656565a4e515151515
251323132305251323771323044515254646464613234646464646464613234611122206b6b6b6b6c6176565f6f6671717d7e665656565f66565f6656565f617
17868686866596656517f696f696f6178393829283938292839382928393829217806666666676212121215666669017966565966565966565a4151515151515
35141414144535141414141445341626464646464646464621012111464646461113231155966586651786966565d6e7d7e61765656565656565656565656517
1786868665656565659665656565f61796968393866583936565839365658393177511211121211111112111111155966565656565966565a415151515151515
36d4b6b6b61616161616161616261187871146464646462111212101464612221111115491656565d6e786f5658617d6e6179665070796070707070796070717
1786658665656565656565659665f617968696656565656565656565656565651775111121115464741111211111551796656565656565a41515151515151515
15c58665751111112111112111111187871146212121114646112146464613231222115565658665968686f5659617d7e717176565f565656565659665656517
1786866565d6e665656565656565f61796f586866565656565f6f6f66586866565751121111155177521211111115596656596659665a4151515151515151515
36c56565751111211111111104244646464621210111464621464611464646461323115690868665966565f58665d70707e717f565656565f565966565656517
17f6f66565d727070707e6659665f6176586f56565f665656565f6f665658686657511112111551775111111211155656565656565a415151515151515151515
15c56565a4141414142411110525122246462146110111462146460146014646111111115586658617d696f6f6656586d607e765070707070796960707079617
17f69665656517a4b4c417656565f61765f66565f4f46565f496f6f6f4f465868681646464649117656464646464919797656565a41515151515151515151515
1525666605363636362511110525132321464646214646111111112111462101111222115565866517d767f6f66565651765f56565656596966565f6f6656517
17f66565966517a515c517656565651765656565f4f4f665f4f4f6f6f4f4656565656596650707270707070707966597976565a4151515151515151515151515
36252121053416b6e42511210535142421464621114646214646462146212146111323115596969627070707070765f5176565f5f5f586868665656565656597
97656565656517a515c51765656565979765656565f6f6f6f665f6f665656597976565656565651780666666669065656565a415151515151515151515151515
1525111105250155a52521110616442521464621011121210146211146211101111111115565659617d6e6f6f6f5656517f565656565d6e6d6e6656565f66597
97656596656517a6b6c61765656565979765f66565f6f6f6f665656565656597976565656565651775111111115565656596a515151515151515151515151515
1525111105256491a525111146770525464601112121214646212101462146111112221155f5659617d7e7f6f66565f517659665f586d7f4f4e7866565658617
1765659665d627070707e765966565176565f6f6f4f46565f4f46586f4f46565666665656565651775111111549165656565a515151515151515151515151515
36251121062666660626111111110525461121464611114646214646462146461113231155f586651767658665866565176565656586d6f4f4e6866565866717
1765656565d7e7f6f6f6f6659665651765656565f4f46565f4f48665f4f46565111156656565656581646464916565656565a515151515151515151515151515
36251111111121211111111111460525012146114646460111461146212111878711111155f5f565176765f565656565176596656565d7e7d7e7656565676717
179696656565656596f6f69665656517656565656565f665656586866565866511111155a4b4b4b4b4b4b4b4b4b4b4b4b4b4e515151515151515151515151515
36251111211111112111111121770525464621212101464601460146461111878711115491966565966565866565969797656596656565866565656586829217
176565656565656596f6f665966565176565656565f6f665656565868686866511111155a5151515151515151515151515151515151515151515151515151515
15351414141414141414141414144535141414141414141414142412224612221222115565658665656565656565969797656565966565656565868686839317
179665659665656565f6f6656565961765658292656582926565829265658292122204b4e5151515151515151515151515151515151515151515151515151515
363636363636153615361515361536153636153636151536363625132346132313231155659665656565866565676565d70707070707070707070707070707e7
d70707070707070707070707070707e7829283938292839382928393829283931323051515151515151515151515151515151515151515151515151515151515
__gff__
0000000000000000000000000000000000000000000501000000000000000000000101000000000001010000000000000001010000000000010100000000000001010101010000000101010101010101010101010100000001010101010101000101010100000000000001010101010001010101010101010202010101010100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
11111111111111111111111111111111606161616260626062606260616161627374747474757f7f7b65677b12777b10101010101110117f1112117a12117a11313221223132212231327f7f7f212221383928293839282938395656383928293839282938392829383928293839282951515151515151515151515151515151
1111111111212211111111121211111112646412121212121264126412121212227a7a7a7a127f7f7f7f7f7f7f7f7f64107f7f7f127f7f7f1010117b12127b117f7f313211113132111111121131323128293839282938395669565656563839282938392829383928293839282938395151515151514d6b6b6b4e5151515151
1212121111313211111111111212111112121264646412646412641212646464327a7a7a7a7f7f7f7f7f7f7f7f7f7f6464107c117c11121010111112111111117f7f7f2122111111122122112122212238395656383928295656282956562829383956563839685638396856383956565151515151515c6d69695a5151515151
1111111111111112111111111111111212111240414141414141421264404142227a7b7b7a10116412117f101011646464107a107a111011111111111111111121227f3132112122123132113132313228295656282938392829383956563839565656565668565656565656565656565151515151515c714a4b5e5151515151
1111111111111111111111111111111111111260445b51515b5b526464504362327b77647b11127c117f107c1112117878107b117b111011737474747475111131327f212211313211111112117f2122383956693839565638395656565628295656566956566828295656566956565651514d6b6b6b6c716a6b4e5151515151
11111112111111212221221111121111116411115063635b5b63526412606277404141414142117b1010107b1164117878107f1110101011107a7a7c7a12111111111131321112111121221121223132282956565656565656565669282938395656565656565638392829282956565651515c697070707270695a5151515151
11111111111111313231321111112122111264115051635b63515212116412115e515163515d414142101064107f12454710111110121212117a7b7b7a7f117878111211121111121131327f3132212238392829565628295656282938392829565656282956565656383938395656564e515d4b4b4b4c716f696a4e51515151
2122111111111111112122121111313211111112606161616161621111111221515151515151635152104042111111555710111264646464127b7f127b7f11787811112122111211212221222122313228293839282938395656383928293839565656383956565656565628295669566a4e515151515c7d7070695a51515151
31322122111211111131321111111111121111111111111111111111111264315151515151515151521050534141425557117374747474757c111264127f1111212211313212111131323132313221223839565638395656565656563839282956566856565628296856563839565656565a515151515d4b4b4b4b5e51515151
111131321111111111111211111111787811111111111211111211116411121151515151515151515210505151515d4c5711117a12127a117a11117c7f7f11113132111211117f2122111112111131322829566956565656695669562829383956565656565638395656565628295656566a4e51515151515151515151515151
11111111111111111111111111111178781111121111111112111140414264115151515151515143621060445151515c5710117a11127a117b11117b7f11121111117f7f11117f313211212211212221383956565656282956565656383956797956282956565656565656563839565656566a4e515151515151515151515151
111112111211112122212211111111121111111140424042111111505b526412515151515151515277107c505151515c1847117b11117b117f7f7f7f7f12111121227f7f21221211111131321131323128295669282938395656565656565679795638395656685656566956565656797969566a6b6b4e515151515151515151
111112111111113132313211121111111111111160626062111111505b52121151515151515151527c107a505151515d4c571111111111117f111211111211113132212231321111112122111111212238392829383956565656282969562829565656565669565656565656565656797956565656566a4e5151515151515151
111112111111111112111111111111111212111112111111121111606162641251515151515151527b107b50515151515c57111112127f7f7f1111111111117c212231322122111211313212121131322829383956565656282938392829383956562829565628295656282956562829566869566956565a5151515151515151
1111111111111211111111111112111111111111111112111111111112111145515151515151515341414154515151515c1847121211117c11117c111211127a313221223132111121227f11212221223839565656562829383928293839282928293839282938392829383928293839686956565656566a6b4e515151515151
1111121111111178781111111211111147111111111111111111787811114519515151515151515151515151515151515d4c57111111117b21227b111111117b212231321111787831327f7f3132313228297979282938392829383928293839383928293839282938392829383928296868685679795656566a4e5151515151
1111111121221178781111111111212241414211111211111111787811451969383976564a5e63635163515151515151515c4f4f4f4f4f4f4f4f4f4f4f4f4f4f31321110111178781111111011111111383979793839282938392829383928292122313221223132212231322122313269695669797956565656565668566868
2122111131321111111111111112313251515211111111111111111145195628295656565a635b5163515b5151515151515c7d7e7d697d7e7d7e7d7e7d7e7d7e11121010111111111012111210111111282956565656383956563839565638393132111131321111313211113132212269695656566969565656565656685668
3132121111111111111112111121222144515342111112111111114519695638395656565a63635b635b5b5151515151515d4c56685668565f565f565608660911101210111111111112111111111111383956565656565656565656565f666611111111111111111111111111113132695656565656564a4b4b4b4b4c565668
1111111111121121221111111131323150515152111111111112115556562829282956566a6b6b6b4e63515b5151515151515c56565f684a4b4c56565f57105511101111111110111110101111111121292829565656565656565f7656571111111111111111111111111111112122215656564a4b4b4b5e515151515d4c5656
111111111111123132111111212221225051515211111111111111555669383938395656695656566a6b4e5b5151515151515c5f5628295a5b5c56696e18461912111111111212111111111111111131393839565f565676565f56565f5711787811111111111211111111111131323156564a5e4d6b6b6b6b6b6b4e515d4c56
1112111111111111111112113132313260445153421111111111116509565669282956565656565656566a4e5b51515151515d4c5638396a6b6c56567d707070641212111111101111101211111011112829565f5656565656565628295711787811111111126412111111111111212256565a515c0866096856686a4e515d4c
212211111211111111111111112122212250514362111111121111116509282938395656565669565656565a515151515151515c564a4b4c565f565f56565f561212641211111111111110111112111138395f565676565656282938395711111111111112114041414212111111313256565a515c571055565656566a4e515c
313211111111111121221111113132313250515211111112111111121155383976565656565656565656565a5b5151515151515c565a5b5c56565656685f566912646412111111111111111111111121292829565656562829383956685711111111111264125051515264121121227769565a515c1846194a4c5668565a515d
11121111111121223132212221222122405451534211111111111111115556282956566956566d706e56566a4e5151515151515d4c6a6b6c566856685f685f561264126412111012111111111111113139383956565f563839565f5f561846472122111112645051515212111131327769565a515d4c564a5e514c56566a4e51
111112111111313248493132313231326061445152111111111112111155693839565656566d7e6f715656565a515151515151515c56565f565f56565656685f64641212111111111111121112111111282956565656565628295f68282956573132111264126061616212111111212256565a51515d4b5e51515c5656565a51
11111111111111115859126464212264212250515342111111111111115569797956565656715656566956565a515151515151515c565656685f5f5670707070641211121111111212126412641211113839565656765f5638392829383956571111111264121264126412111111313256566a4e51515151514d6c5656565a51
40414211111111111111111264313264313250514362111112111111115569797956565656566f56565656565a515151515151515d4c4a4b4c5f56282956686812111264121112646464646464641221292829565668566856563839565f5657111112641212641211121111112122216956565a515151514d6c565656565a51
505153421111111211111111121264644041544362111111111111454619282956566956567d70567e56564a5e51515151515151515c5a5b5c695638395f686911121264121111121212126464121231393839565f565668565f5656565656577777641264121211111111111131323156564a5e5151514d6c56685656565a51
5063515341414211111111111164121250515152641211111111451928293839282956565656565656564a5e5151515151515151515c6a6b6c6956565f56565612646412111111111264646412641212282956562829565628295f56282956184041426412111111111111111111212256566a6b6b6b6b6c56685656564a5e51
5063636363635341414141421111111150515152111111111145195638392829383928295656565656565a515151515151515151515d4c56566956565f5628291264121111111112646412126464646438392829383928293839282938392829505152771111111111111111212231326856696969696956695668564a5e5151
6061616161616161616161627878641250514362787812114519566928293839282938395656797956565a51515151515151515151515d4c56567979565638391112787811111111121211111212646428293839282938392829383928293839606162771112117878111212313277775656567979565668696856565a515151
__sfx__
000300001c7501975001850057500d75012750187501d7502175012500185003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c0003c000
000200000405007150081500915010050130500f150151501a1501f0502405024050270503105034050331503b0503c0503c050371503d0503f050370502815027150261502105011150101500d1500000000000
010100000012002120001200012001120011200112001120011200120000200002000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001c7501975001850057500d75012750187501d7502175012550185501d5501f55020550000000000000000000001d5502255027550295502d5502f550345503a55015050190501d050250502b05035050
00040000101531115310153101530e153316001a2501f250292502c250276502565023650216401d6401a640186301563014630106200f6200d6200b6100a6100861006610056100461002610016100161000610
0103000002650106500f0500d0500a050080500405000050016300062000620016100061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000603000000060300c000000300c00005030010000c0000c000130000400006530005000450000500070000700015000005000653006500070000c0000c00006500130000600006530075300653003500
0110000000133001030d1030013324635021050013300103001330210302103001332463500103011030210300133001030210300133246350210300133021030013302103011030013324635001032463524635
000600000732508435093450c42510335144451932523435000420100203052000021d00509005020050000529005234053f405234053f405234053f4052d4053f405234053f405234053f405234053f4052d405
01030000390573705733057310572f0572b0572905727057260572405722057200571f0571c0571b0571a0571805716057150571305712057110570f0570e0570c0570a057080570505703057010570005700007
000200000a0501205017050190501805015050120500e0500b050265601b5501e5502000022550265501f6502b55019650305501265035550066500664036060066303e050066203a050066103d050066103c050
00020000134501335013250104500c450094500745005450034500245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000003030155301d0301f5301a0300e5300503010530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000055002551105511d5512c5513a5510e551105501e1501e1500000334552345423453234522345221e1501e1500000034552345423453234522345220000000000000000000000000000000000000000
01050000092500a2500b2500c2500d2520e2520f2521125214252192521c252212522525229250302503225032240000003224000000322300000032230000003222000000322200000032210000003221000000
010800000c4300c330114301133017430173301533216332153321633215322163221532216322153121631215312163121531216312153120030000300003000030000300003000030000300003000030000300
010300001c7501975001850057500d75012750187501d750217501803524035180352403518035240351803518000180001800018000180001800018000180001800018000180001800018000180001800018000
010300001d7501a75002850067500e75013750197501e750227501a035260351a035260351a035260351a0351a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a0001a000
010300001e7501b75003850077500f750147501a7501f750237501c035280351c035280351c035280351c0351c0001c0001c0001c0001c0001c0001c0001c0001c0001c0001c0001c0001c0001c0001c0001c000
010300001f7501c750048500875010750157501b75020750247501d035290351d035290351d035290351d0351d0001d0001d0001d0001d0001d0001d0001d0001d0001d0001d0001d0001d0001d0001d0001d000
01030000207501d750048501575011750167501c75021750257501f0552b0551f0552b0551f0552b0551f0551f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f000
01030000207501d750048501575011750167501c7502175025750000002b055370552b055370452b045370452b035370352b035370252b025370252b015370150000000000000000000000000000000000000000
00030000000001970001800057000d70012700187001d7002170012500185001d5001f50020500000000000000000000001d5502255027550295502d5502f550345503a5503a5003a5003a5003a5003a5003a500
000300000315003150051500715006150061500415002150001000010000100001000010000100021500515008150091500515002150001500010000100001000010000100001000010000100001000010000100
000400000b150071500415003150011500905316053180531c0531d0531d0531b0531404312033100230c01305600046000360002600016000160000600000000000000000000000000000000000000000000000
000400000b150071500415003150011500023304243072530b2330d2430f2531523318243072530b2330d243102501623014240162501a2301c24000600000000000000000000000000000000000000000000000
000200002a030310303604006640076402e03035030096400a6402e03034030380301064014640156403603039030136401464014630146301463012630116300e6300a63008630076300463000630206001b600
0004000002240072400b240186431864311340113400f3400c3400734002340003400530003300023000230002300023000030000300003000030000000000000000000000000000000000000000000000000000
000200001365019050210502700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000603000000060300c000000300c00005030010000c0000c000130000400006530005000450000500070000700015000005000653006500070000c0000c00006500130000600006530075300653003500
011000001852518525185250000018525185251852500000185251852518525000001852518525185250000017525175251752500000175251752517525000001a5251a5251a525000001a5251a5251a52500000
011000001a0351a0351a7151a0351a035187151a0351903519035197351a01519035197151971519715197151d0351d035187151d0351d035187151d0351c0351c035187151d0351f0351f7151f7151f7151f715
011000000000500005132151321513215132151321500005122151221512215000051221512215122150000500005000051321513215132151321513215000051721516215152151421517215000050000500000
01100000027110e7111a711267112671226712267122671226712267122671226712267111a7110e71102711027110e7111a7112671126712267122671226712267111a7110e71102711267111a7110e71102711
0110000029025290251d71529025290251d7152802528025280251d71528025280251d7151d7151d7151d7152d0252d0251d7152d0252d0251d7152b0252b0252b0251d7152b0252b0251d7151d7151d7151d715
01020000092500a2500b2500c2500d2520e2520f2521125214252192521c252212522525229250302503225032240000003224000000322300000032230000003222000000322200000032210000003221000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000c20000200002250022500225012250022500000000000000000225002250022501225002250000000000000000022500225002250122500225000000120001200012000120006200072001220017200
011400000c22000225002250022500225012250022500000000000000000225002250022501225002250000000000000000022500225002250122500225000000122501225012250122506225072251222517225
011400100c3230c0000c3230c3231f6350c0000c0000c2230c5030c503132230c2231f6350c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c5030c0000c0000c000
011400000022500205002250020500225012250020500225002050022500225002050022501225002050020500225002050022500205052250422500205002250020500225002250020505225042250020500205
010e002017022170221702217022170221702217022170220e0220e0220e0220e0220e0220e0220e0220e02210022100221002210022100221002210022100220e0220e0220e0220e0220d0220d0220d0220d022
011c0000231252312523125237252372523725231252312521125237252372523725211252312523125237252372523725231252312523125237252372523725211252312523125237251e725237252312523125
011c00000b0330b0300b0330b0300b0330b0300b0330b0300e0330e0300e0330e0300e0330e0300e0330e03010033100301003310030100331003010033100300e0330e0300e0330e0300d0330d0300d0330d030
0112000029025290251d71529025290251d7152802528025280251d71528025280251d7151d7151d7151d7152d0252d0251d7152d0252d0251d7152b0252b0252b0251d7152b0252b0251d7151d7151d7151d715
01120000027110e7111a711267112671226712267122671226712267122671226712267111a7110e71102711027110e7111a7112671126712267122671226712267111a7110e71102711267111a7110e71102711
011200001a0351a0351a7151a0351a035187151a0351903519035197351a01519035197151971519715197151d0351d035187151d0351d035187151d0351c0351c035187151d0351f0351f7151f7151f7151f715
011200000e03304030050300403002030040300503004030020300403005030040300e0330403005030040300e033040300503004030020300403005030040300e0330403005030040300e033040300503004030
011800000000500005132151321513215132151321500005122151221512215000051221512215122150000500005000051321513215132151321513215000051721516215152151421517215000050000500000
011800000c02300003000030c02318023000030c0230c0230c02300003000030c023180230000300003000030c02300003000030c023180230000300003000030c02300003000030c02318023000030000300003
011800000702207022070220702208022080220802208022000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
011400001852518525185250000018525185251852500000185251852518525000001852518525185250000017525175251752500000175251752517525000001a5251a5251a525000001a5251a5251a52500000
01140000070200c0200302000020000200002001020000200302003020030200002001020000200000000000070200c02003020000200002000020010200002000022060220c0220802200022070220c02208022
011000000904500000000450204500000040450504500000000000000000045020450000004045050450000009045000000004502045000000404505045000000000000000070450904507045050450204500000
01100000187151871518715187151d7151d7151f7151f7152171521715217151f7151f7151f7151d7151d7151871518715187151c7151c7151c7151d7151d7151d7151c7151c7151c7151a7151a7151871500005
011000001871518715187151871521715217151f7151f7151d7151d7151d7151c7151c7151c7151a7151a7151871518715000051c7151c715000051d7151d715000051c7151c715000051a7151a7150000500005
01100000022120020202212002020e212002020020200202022120020202212002020e212002020020200202022120020202212002020e212002020020200202022120020202212002020e212002020020200202
01100000025300253009530000000b530000000000000000025300253009530000000b530000000000014530135300000009530000000b530000000000000000000000453009530000000b530000000000000030
__music__
03 06 42 43 44
03 07 42 43 44
03 3f 3e 43 44
01 3b 3d 43 44
02 3b 3c 43 44
03 3a 39 43 44
01 37 38 43 44
00 37 38 43 44
00 37 38 36 44
02 37 38 36 44
01 35 42 33 44
00 35 42 33 44
00 35 34 33 44
00 35 34 33 44
00 35 33 34 44
02 35 32 34 44
01 31 42 43 44
00 31 42 43 44
00 31 30 43 44
00 31 30 43 44
00 31 30 2f 44
02 31 30 2f 44
01 2d 2e 43 44
00 2d 2e 2c 44
00 2d 2e 2c 44
02 2d 42 2c 44
01 07 42 43 44
00 07 42 43 44
00 07 1d 43 44
00 07 1d 43 44
00 07 1d 3c 44
00 07 1d 3c 44
00 07 1d 3c 3f
00 07 1d 3c 3f
00 07 1d 3e 3f
00 07 1d 3e 3f
00 07 1d 1e 3f
00 07 1d 1e 3f
00 07 1d 1e 1f
00 07 1d 1e 1f
00 07 1d 20 1f
00 07 1d 20 1f
00 07 1d 20 22
00 07 1d 1f 22
00 07 1d 20 21
00 07 1d 20 21
00 07 1d 3b 21
00 07 1d 3b 21
00 07 1d 3b 44
00 07 1d 3b 44
00 41 1d 3b 44
02 41 1d 3b 44
01 07 1d 3c 3b
00 07 1d 3c 3b
00 07 1d 3c 3f
00 07 1d 3c 3f
00 07 1d 3c 3b
00 07 1d 3c 3b
00 07 1d 3f 3b
02 07 1d 3f 3b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
