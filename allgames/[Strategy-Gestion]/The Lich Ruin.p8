pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--the lich ruin
--by @dollarone
--based on "wizard duels"
--which was made for the 4th alakajam

function _init()
	intro_init()
	reset()
end
function reset()
	info, can_see_enemy_crystals,
	has_lost_life, has_challenged_lich, has_found_first_spell,
	story_marker, lich_wins, diff, cols, intro_story, 
	difficulty,
	specials_spr,map_music, map_themes, battle_themes,
	my_cards, enemy_cards,
	friend_spells, enemy_spells,
	friend_death, enemy_death,
	wiz_x, wiz_y,wiz_spr,wiz_flip,
	ticks, errormsg, gameover, state,
	challengers,stories,cards=
		true, true,
		false, false, false,
		1, 0, 1, {5,6,7,6,5},
				{"   for years, the wise magelords",
				"ruled harberia in peace.",
				"   but now, everything is in",
				"danger. the evil lich lord",
				"afgorkon has taken up residence",
				"in the old ruin on the island of",
				"funeris.",
				"   a young magelord (you!)",
				"sets off on a journey to",
				"challenge the lich and banish it",
				"from harberia.",
				"   but first, you will need to",
				"find some spells!",
				"   well done, you have your",
				"first spell! now go challenge",
				"someone!",
				"   look for challengers that say",
				"they will give you a reward if",
				"you can beat them - that's how",
				"you find new spells and other",
				"upgrades!",
				"   a good starting point might",
				"be the ogre hermit south-east",
				"by the river.",
				"   here's how challenges look",
				"and how they work:",
				"   excellent!",
				"this spell spawns a panther,",
				"which has 3 attack, 2 health",
				"and also moves with haste.",
				"   this creature is a great",
				"counter to the various goblins,",
				"as they all have 3 health or",
				"less.",
				"   try to spend your crystals",
				"more efficiently than your",
				"opponent, and also try to take",
				"control over the crystal towers",
				"- this is the key to victory!",
				"   mad grefzl is no longer",
				"blocking your way!",
				"   now you must explore harberia",
				"and gather more spells before",
				"finding and challenging the evil",
				"lich lord afgorkon.",
				"   challenge magelords to be",
				"rewarded with spells and",
				"upgrades - the latter can only",
				"be applied once each, so choose",
				"wisely!",
				"   good luck, young magelord",
				"- harberia believes in you!",
				"   impressive work, young", 
				"magelord!",
				"   you have been rewarded with",
				"a different type of spell.",
				"   this spell does not spawn a",
				"creature, and so cannot claim",
				"crystal towers.",
				"   they cannot be shot down by",
				"weapons either.",
				"   but beware: these spells move",
				"quickly and don't care if they",
				"hit friend or foe!", ""},
	{{"normal","hp is reset after each battle"},
				{"hard","lose a battle? lose 1 max hp"},
				{"brutal","your hp does not reset at all"}},
		{15,121,14,13,124},1,{36,56},{2,24,10,44},
		{}, {}, {}, {}, {}, {}, 4, 19, 131, false,
		0,"",false, 10, {}, {}, {}
	palt(14,true)
	palt(0,false)
	add(stories,{"oh you don't have any spells!", "  do you want a free one?"})
	add(stories,{"        young wizard -", "  you must defeat me to pass"})
	add(stories,{"you've already defeated me.","    friendly rematch?"})
	add(stories,{" do you want to learn about", "    how challenges work?"})
	add(stories,{" challenge me if you dare."})
	add(stories,{"  young wizard - let's see","    how far you've come."})
	add(stories,{"         turn back", "      or face defeat!"})
	add(stories,{"     if you can beat me", " i will give you a reward!"})
	add(stories,{"           grrr!"})
	add(stories,{"   get lost little wizard!","you're no match for my powers!"})
	add(stories,{"a wizard without spells, huh?","find my cousin in the woods..."})
	add(stories,{"some spells shouldn't be used"})
	add(stories,{"some spells shouldn't be used", "  - but times are desperate"})
	add(cards,generate_card( 1, 1,1, 1,206,207,0,{},	1,2))
	add(cards,generate_card( 2, 3,1, 2, 64, 66,0,{},	2,2))
	add(cards,generate_card( 3, 2,1, 2, 68, 70,4,{1},	2,2))
	add(cards,generate_card( 4, 2,1, 3,236,238,5,{1,2}, 2,2))
	add(cards,generate_card( 5, 1,3, 2, 72, 74,0,{},	2,2))
	add(cards,generate_card( 6, 1,2, 2,192,194,4,{1},	2,2))
	add(cards,generate_card( 7, 1,2, 2,122,106,0,{3},	2,1))
	add(cards,generate_card( 8, 4,4, 4, 76, 78,6,{},	2,2))
	add(cards,generate_card( 9, 2,3, 3,220,204,0,{3},	2,1))
	add(cards,generate_card(10, 2,4, 3,163,165,6,{},	2,2))
	add(cards,generate_card(11, 5,1, 4,137,139,0,{4},	2,2))
	add(cards[11].modifiers,4)
	add(cards,generate_card(12, 3,2, 4,131,110,5,{1,2}, 2,2))
	add(cards,generate_card(13, 4,3, 5,224,226,8,{1,2}, 2,2))
	add(cards,generate_card(14, 7,5, 6,169,141,9,{},	2,2))
	add(cards,generate_card(15, 1,4, 3,100,102,8,{2,3},	2,2))
	add(cards,generate_card(16, 1,1, 2,109, 17,9,{2,3},	1,1))
	add(cards,generate_card(17, 1,0, 1,228,124,9,{5,3},	1,1))
	add(challengers, createchallenger(12,21, "      zark", get_card(1), 1, 12, {1}, 0, 11, 5, 3, true))
	add(challengers, createchallenger(10,2,  "      bzom", get_card(1), 9, 0, {1}, 0, 1, 1, 3, false, get_card(1)))
	add(challengers, createchallenger(2,26,  "     gbzrak", get_card(2), 1, 3, {2}, 0, 11, 5, 9, false, get_card(2)))
 	add(challengers, createchallenger(13,27, "      mbraz", get_card(3), 1, 12, {3}, 0, 11, 5, 6, true, get_card(3)))
	add(challengers, createchallenger(21, 24,"   mad grefzl", get_card(4), 4,0, {1,2,3,4}, 2, 2, 8, 9, true))
	add(challengers, createchallenger(15, 16,"   thrun dhuz", get_card(4), 1,12, {1,2,4,9}, 1, 8, 0, 9, true, get_card(4)))
	add(challengers, createchallenger(64, 18,"      dovre", get_card(14), 3,5, {14,8,5,6,9}, 2, 5, 0, 7, true, get_card(14)))
	challengers[7].unit.spr=36
	add(challengers, createchallenger(42,9,  "    sir eric", get_card(11), 5, 0, {11,2,3}, 2, 8, 0, 7, false, get_card(11))) 
	add(challengers, createchallenger(99,2,  "  magelord isil", get_card(12), 0, 1, {4,11,7,8,16}, 3, 12, 6, 2, false))
	add(challengers, createchallenger(38,5,  "  magelord agar", get_card(12), 0, 2, {5,6,7,8,10,16}, 3, 6, 4, 3, false, true))
	add(challengers, createchallenger(85,28, "magelord garandhir", get_card(12), 1, 13, {1,2,3,4,8,9,17}, 2, 6, 3, 1, true, 3))
	add(challengers, createchallenger(96,24, "magelord charchul", get_card(12), 0, 5, {5,6,7,8,11,16,15}, 3, 6, 3, 2, true, 4))
	add(challengers, createchallenger(3,0,   " magelord alrik", get_card(12), 9, 10, {2,3,4,8,15}, 2,6, 9, 3, false, get_card(15)))
	add(challengers, createchallenger(31,6,  "magelord asakban", get_card(12), 1, 12, {2,3,4,11,15}, 2, 6, 3, 3, true, 5))
	add(challengers, createchallenger(81,12, "magelord zakary", get_card(12), 6, 7, {2,8,17}, 4,6, 9, 1, true, get_card(17)))
	add(challengers, createchallenger(44,28, "magelord fredzar", get_card(12), 5, 6, {8,9,10,4,16}, 2, 6, 3, 1, false, 2))
	add(challengers, createchallenger(120,25,"magelord bhazzur", get_card(12), 8, 9, {1,11,16,15}, 3, 6, 9, 2, true, get_card(16)))
	add(challengers, createchallenger(61,3,  "magelord razkal", get_card(12), 2, 4, {8,11,6,16,17}, 2, 6, 3, 3, true, 1))
	add(challengers, createchallenger(12, 11,"    kittrina", get_card(9), 1,8, {9}, 0, 9, 2, 3, false))
	add(challengers, createchallenger(21, 9, "     k'ryk", get_card(8), 5,8, {8,9}, 1, 8, 7, 6, true, get_card(9)))
	add(challengers, createchallenger(57, 24,"     k'rax", get_card(8), 13,1, {8,9,2,4}, 2, 2, 2, 4, false)) 
	add(challengers, createchallenger(82, 23,"     k'rok", get_card(8), 7,5, {8,9,1,2,3}, 2, 2, 2, 7, false)) 
	add(challengers, createchallenger(53, 19,"     k'raik", get_card(8), 6,2, {8,1,2,3}, 2, 8, 0, 7, true, get_card(8)))
	add(challengers, createchallenger(93, 4, "     k'rix", get_card(8), 9, 0, {8,5,6,7}, 2, 5, 0, 1, true)) 
	add(challengers, createchallenger(106,22," zarkon a'lam", get_card(10), 1,12, {10,1,2,3,4}, 2, 8, 0, 8, false, get_card(10)))
	add(challengers, createchallenger(105,28," duzek a'rian", get_card(10), 5,12, {10,1,2,3}, 2, 2, 2, 5, true))
	add(challengers, createchallenger(55, 6, "     barnes", get_card(5), 5,13, {5,6,7}, 1, 8, 0, 6, true, get_card(5)))
	add(challengers, createchallenger(62, 12,"     johnson", get_card(5), 1,8, {5,6,7,11}, 2, 2, 2, 4, true))
	add(challengers, createchallenger(71, 15,"    walliams", get_card(6), 5,13, {6,5,7,8,2}, 2, 8, 0, 1, false, get_card(6)))
	add(challengers, createchallenger(86, 17,"      ruff", get_card(7), 5,13, {7,5,6,2,3}, 1, 9, 0, 4, false, get_card(7)))
	add(challengers, createchallenger(97, 11,"       zed", get_card(4), 5,12, {1,2,3,4,5,6,7}, 2, 2, 2, 2, true))
	add(challengers, createchallenger(116,11,"   necromancer", get_card(4), 0,0, {5,6,7,8,9,10,17}, 4, 7, 11, 5, true))
	add(challengers, createchallenger(120,10,"     spectre", get_card(4), 7,13, {4,5,6,7,8,9,11,16}, 3, 7, 11, 8, true))
	add(challengers, createchallenger(120,4, "  lord afgorkon", get_card(13), 1,0, {2,4,5,6,7,8,9,10,11,12}, 2, 10, 12, 20, true))
	wizard_player=get_card(12)
	wizard_player.darkcolorreplace, wizard_player.lightcolorreplace,wizard_player.hp=2,8,10
end
function play_map_music()
	music(map_themes[map_music])
	map_music+=1
	if map_music==3 then
		map_music=1
	end
end
function createchallenger(x,y, name, u, darkcolor, lightcolor, ccards, tactic, story, special, map, flipp, treasure)
	unit={}
	unit.x,unit.y,unit.name,unit.unit,unit.cards,unit.tactic, unit.treasure,
	unit.darkcolorreplace,unit.lightcolorreplace,unit.special,
	unit.story, unit.map, unit.flip, unit.won, unit.mapx,unit.mapy=
		x,y,name,u,ccards, tactic, treasure,
		darkcolor,lightcolor, special, stories[story],
		map,flipp,false,22,15
	if map%3==1 then
		unit.mapx,unit.mapy=68,16
	elseif map%3==2 then
		unit.mapx,unit.mapy=98,1
	end	
	return unit
end
function new_match()
	wizard_enemy=c.unit
	wizard_enemy.hp,wizard_enemy.darkcolorreplace, wizard_enemy.lightcolorreplace,
	enemy_cards, current_tactic, player_last_played_unit, enemy_last_played_unit,
	card_selected, deep_freeze_action_lane, crystals_player, crystals_enemy,
		ticks,time,turns,result,friends, enemies,show_cards_timeout, error_countdown=
		wizard_enemy.wizhp,c.darkcolorreplace,c.lightcolorreplace, c.cards, c.tactic, nil, nil,
		1, -1, 0, 0, 60,0,0,"", {}, {}, -20, 0
	init_lanes(c.map)
	if diff!=3 then
		wizard_player.hp=wizard_player.wizhp
	end
end	
function generate_card(id,maxhp,attack,cost,spr,spr_attack,sfx_attack,specials,width,height)
	unit={}
	unit.id,unit.wizhp,unit.spr_falling1,unit.spr_falling2,unit.spr_defeat,
	unit.spr_win1,unit.spr_win2,unit.sfx_attack,unit.specials,
	unit.maxhp,unit.hp,unit.attack,unit.cost,unit.pos,unit.oldpos,unit.height,unit.width,
	unit.spr,unit.spr_attack,unit.acted,unit.spr_normal,unit.modifiers,unit.freezetime=
		id,10,spr_attack,spr_attack, spr_attack, spr, spr_attack, sfx_attack, specials,
		maxhp,maxhp,attack,cost,1,1,height,width,spr,spr_attack,false,spr,{},0
	if contains(unit.specials, 1) then
		unit.spr_win2=spr
	end
	if unit.id==12 then
		unit.spr_falling1,unit.spr_falling2,unit.spr_defeat,unit.spr_win1,unit.spr_win2=
			133,131,173, 131,135		
	elseif unit.id==13 then
		unit.wizhp,unit.spr_falling1,unit.spr_falling2,unit.spr_defeat,unit.spr_win1,unit.spr_win2=
			15,224,196,244,224,196
	end
	return unit
end
function contains(t, n)
	for i=1,#t do
		if t[i]==n then
			return true
		end
	end
	return false
end
function copy(o)
	local l
	if type(o)=='table' then
		l={}
		for k, v in pairs(o) do
			l[k]=copy(v)
		end
	else
		l=o
	end
	return l
end
function get_card(id)
	return copy(cards[id])
end
function spawn(spell, lane, unfriendly)
	unit=copy(spell)
	if unfriendly then
		unit.pos=#lanes[lane]-1
	end
	unit.oldpos,unit.lane=unit.pos,lane
	return unit
end
function not_collide(x,y)
	return not fget(mget(x,y),0)
end
function _update60()
	ticks+=1
	if intro then
		intro_update() 
		return
	end
	if state==20 then
		if btnp"4" and death_timeout<ticks-150 then
			if wizard_enemy.hp<1 then
				play_map_music()
				state,gameover=1,false
			else
				reset()
			end
		end
		return
	elseif state>10 and state<15 then
		if btnp"4" or btnp"5" then 
			if state==11 or state==14 then
				state=1
			else
				state+=1
			end
		end
		return
	elseif state==10 then
		if btnp"4" then 
			state=11
			play_map_music()
		elseif btnp"5" then 
			diff+=1
			if diff>3 then
				diff=1
			end
		end
		return
	elseif state==2 then
		c.unit.spr,trigger_treasure_music,special=c.unit.spr_normal,true,c.special
		if has_challenged_lich and special==6 then
			c.story,c.treasure,c.special=
				stories[13],get_card(12),0
		end
		if special==5 and #my_cards>0 and not c.won then
			if c.x==12 then -- yuurgh
				c.story=stories[5]
			else
				c.story=stories[8]
			end
		end
		if btnp"4" then
			if special==1 then
				if c.won then
					state=4
				else
					state,result=4,"win"
					music"-1"
				end
				return
			end
			if #my_cards==0 then
				errormsg="you can't challenge me -\n  you have no spells!"
			else
				can_see_enemy_crystals,state=true,0
				new_match()
				if special>9 then
					can_see_enemy_crystals=false
					music(battle_themes[4])
				else
					music(battle_themes[flr((c.map-1)/3)+1])
				end
				return
			end
		end
		if btnp"5" then
			state=1
		end
		return
	elseif state==4 then
		special=c.special
		if special==1 and c.won then
			state=13
			return
		elseif result!="win" or c.won then
			state=1
			play_map_music()
			return
		end
		if not c.won and special==2 or special==8 or special==11 then
			c.y+=2
			c.won=true
		end
		if special==8 then
			state,story_marker=11,40
			play_map_music()
			return
		end
		if c.treasure==nil then
			c.won,state,c.story=true,1,stories[3]
			play_map_music()
			return
		end
		if trigger_treasure_music then
			music"-1"
			sfx"53"
			trigger_treasure_music=false
		end
		if btnp"4" or btnp"5" then
			if special==4 then
				wizard_player.attack+=1
			else
				add(my_cards,c.treasure)
			end
			play_map_music()
			c.won,state,c.story=true,1,stories[3]
			if special==1 then
				c.story,state,story_marker=stories[4],12,14
			elseif special==7 then
				state,story_marker=11,27
			elseif special==9 and not has_found_first_spell then
				state,story_marker,has_found_first_spell=11,53,true
			end
		end
		return
	elseif state==5 then
		if result!="win" or c.won then
			state=1
			play_map_music()
			return
		end
		if trigger_treasure_music then
			music"-1"
			sfx"53"
			trigger_treasure_music=false
		end
		checkcardbuttons()
		sel_upgrade,c.unit.spr=nil,c.unit.spr_normal
		if btnp"3" then
			state=1
			play_map_music()
			return
		end
		if btnp"2" then
			state,sel_upgrade,tres=6,copy(my_cards[card_selected]),c.treasure
			if tres==1 then
				sel_upgrade.maxhp+=2
				sel_upgrade.hp=sel_upgrade.maxhp
			elseif tres==2 then
				sel_upgrade.attack+=2
			elseif tres==3 then
				add(sel_upgrade.modifiers,4)
				add(sel_upgrade.specials,4)
			elseif tres==4 then
				add(sel_upgrade.specials,2)
			elseif tres==5 then
				add(sel_upgrade.specials,3)
			end
			sel_upgrade.cost+=1
		end
		return
	elseif state==6 then
		if btnp"5" then
			state=5
		elseif btnp"4" then
			play_map_music()
			my_cards[card_selected]=sel_upgrade
			c.won,state,sel_upgrade,c.story=true,1,nil,stories[3]
		end
		return
	elseif state==1 then
		errormsg,oldx,oldy,moved="",wiz_x,wiz_y,false
		if ticks%5==0 then
			if btn"0" and not_collide(wiz_x-1, wiz_y) and not_collide(wiz_x-1, wiz_y+1) then
				wiz_x-=1
				wiz_flip,moved=true,true
			end
			if btn"1" and not_collide(wiz_x+2, wiz_y) and not_collide(wiz_x+2, wiz_y+1) then
				wiz_x+=1
				wiz_flip,moved=false,true
			end
			if btn"2" and not_collide(wiz_x, wiz_y-1) and not_collide(wiz_x+1, wiz_y-1) then
				wiz_y-=1
				moved=true
			end
			if btn"3" and not_collide(wiz_x, wiz_y+2) and not_collide(wiz_x+1, wiz_y+2) then
				wiz_y+=1
				moved=true
			end
		end
		if moved then 
			if ticks%10<5 then
				wiz_spr=131
			else
				wiz_spr=133
			end
		end
		for i=1,#challengers do
			chal=challengers[i]
			if (chal.x == wiz_x or chal.x+1 == wiz_x or chal.x == wiz_x+1) and
				(chal.y == wiz_y or chal.y+1 == wiz_y or chal.y == wiz_y+1) then

				c,state,wiz_x,wiz_y=chal,2,oldx,oldy
			end
		end
		if fget(mget(50,60),7) then
			state=2
		end
		return
	end
	if btnp"0" then
		info=not info
	end
	if gameover then
		sfx(-1,3)
		show_cards_timeout,error_countdown=0,0
		if state<20 and ((diff==2 and wizard_player.hp<1 and wizard_player.wizhp<1) or (diff==3 and wizard_player.hp<1) or
			(wizard_enemy.id==13 and wizard_enemy.hp<1)) then
			if wizard_enemy.hp<1 then
				music"21"
				sfx"20"
			else
				sfx"35"
			end
			state,death_timeout,info=20,ticks+110,false
		end
		if btnp"4" or btnp"5" then
			updatewizard(wizard_player)
			updatewizard(wizard_enemy)
			state,gameover=4,false
			if c.special==3 then
				if c.won then
					state=1
				else
					state=5
				end
			end
		end
		return
	end
	checkcardbuttons()
	if ticks<240 then
		return
	end
	turn,something_burning=false,false
	if ticks%120==0 then
		turn=true
	end
	if ticks%120==60 then
		if not something_burning then
			sfx(-1,3)
		end
		updatehalfturn(friends, friend_death)
		updatehalfturn(enemies, enemy_death)
		if wizard_player.hp<1 and not gameover then
			gameover,result,ticks=true,"lose",0
			if wizard_enemy.hp<1 then
				result="draw"
			elseif diff==2 then
				wizard_player.wizhp-=1
			end
			music"23"
			if wizard_enemy.id==13 then
				has_challenged_lich=true
			end
		end
		if wizard_enemy.hp<1 and not gameover then
			gameover,result,ticks=true,"win",0
			if wizard_enemy.id==13 then
				lich_wins+=1
				has_challenged_lich=true
				if lich_wins==3 then
					c.treasure,c.won=get_card(13),false
				end
			else
				music"22"
			end
		end
		move(friends, true, true)
		move(enemies, false, true)
		updatecrystals()
	end
	if turn then

		turns+=1
		for w=1,#enemy_death do
			del(enemies,enemy_death[w])
		end
		enemy_death={}
		for w=1,#friend_death do
			del(friends,friend_death[w])
		end
		friend_death={}
		harvestcrystals()
		updatefreeze(friends)
		updatefreeze(enemies)
		updatewizard(wizard_player)
		updatewizard(wizard_enemy)
		attack(friends,enemies,true,false)
		attack(friends,enemies,true,true)
		for i=1,#friends do
			updatewizardattack(wizard_enemy,friends[i], #lanes[friends[i].lane]-1)
		end
		attack(enemies,friends,false,false)
		attack(enemies,friends,false,true)
		for e=1,#enemies do
			updatewizardattack(wizard_player,enemies[e], 1)
		end
		move(friends, true, false)
		move(enemies, false, false)
		updatecrystals()
	end
	if btnp"1" or btnp"2" or btnp"3" then
		player_spawn_lane=2
		if btnp"2" then
			player_spawn_lane=1
		elseif btnp"3" then
			player_spawn_lane=3
		end
		if my_cards[card_selected].cost > crystals_player then
			errormsg,error_countdown,show_cards_timeout="   can't spawn -\nnot enough crystals!",ticks+90,ticks-1
		elseif lanes[player_spawn_lane][1]["occupied"]==false then
			player_last_played_unit=spawn(my_cards[card_selected], player_spawn_lane, false)
			add(friends, player_last_played_unit)
			crystals_player -= my_cards[card_selected].cost
			lanes[player_spawn_lane][1]["occupied"], show_cards_timeout=true, ticks-1
		else
			errormsg,error_countdown,show_cards_timeout="   can't spawn - \n lane is occupied",ticks+90,ticks-1
		end
	end

	if rand(1500)==1 then
		current_tactic=max(0,current_tactic-1)
	end
	if rand(1000)==1 then
		current_tactic=c.tactic
	end
	if c.special>10 and rand(500)==1 then
		current_tactic=rand(3)+2
	end
	enemy_unit_to_be_played,enemy_spawn_lane=nil,rand(3) + 1
	spawning=get_action_from_tactic()
	last=#lanes[enemy_spawn_lane]-1
	if spawning>0 and ready_to_cast() and lanes[enemy_spawn_lane][last]["occupied"]==false and crystals_enemy>=enemy_unit_to_be_played.cost then
		crystals_enemy-=enemy_unit_to_be_played.cost
		lanes[enemy_spawn_lane][last]["occupied"],player_last_played_unit,
		enemy_last_played_unit=true,nil,spawn(enemy_unit_to_be_played, enemy_spawn_lane, true)
		add(enemies, enemy_last_played_unit)
	end
end
function ready_to_cast()
	return enemy_unit_to_be_played!=nil
end
function can_spawn_unit(unit_ids, not_nil, lane, ignore_lane)
	if enemy_unit_to_be_played!=nil then
		return enemy_unit_to_be_played
	end
	if not_nil==nil then
		return nil
	elseif not_nil!=false then
		lane=not_nil.lane
	end
	for i=1,#unit_ids do
		if contains(c.cards, unit_ids[i]) and (first_unit_in_lane[lane]>99 or ignore_lane) then
			return cards[unit_ids[i]]
		end
	end
	return nil
end
function rand(i)
	return flr(rnd(i))
end
function get_action_from_tactic()
	first_unit_in_lane = {}
	for i=1,3 do
		first_unit_in_lane[i]=get_first_unit_in_lane(i)
	end
	if current_tactic==3 then
		enemy_unit_to_be_played=can_spawn_unit({16}, player_last_played_unit, 0, false)
	elseif current_tactic==4 then
		if player_last_played_unit!=nil and deep_freeze_action_lane<0 then
			deep_freeze_action_lane=player_last_played_unit.lane
		end
		if deep_freeze_action_lane>0 and turns%5==0 then
			enemy_unit_to_be_played=can_spawn_unit({17}, false, deep_freeze_action_lane, false)
		end
		if rand(1000)==0 then
			deep_freeze_action_lane=-1
		end
	end
	if current_tactic>1 then
		if enemy_last_played_unit!=nil and contains({2,8,11,14},enemy_last_played_unit.id) then
			enemy_unit_to_be_played=can_spawn_unit({12,4,6,3}, enemy_last_played_unit, 0, true)
			if ready_to_cast() then
				return 1
			end
		end
		if player_last_played_unit!=nil and contains({8,12,13,14},player_last_played_unit.id) then
			enemy_unit_to_be_played=can_spawn_unit({15,16}, player_last_played_unit, 0, false)
		end		
	end
	if current_tactic>0 and player_last_played_unit!=nil then
		if first_unit_in_lane[player_last_played_unit.lane]==101 or contains({1},player_last_played_unit.id) then
			enemy_unit_to_be_played=can_spawn_unit({2,3,4,12,11}, player_last_played_unit, 0, true)
			if ready_to_cast() then 
				return 1
			end
		end
		if contains({5,15,7,11},player_last_played_unit.id) then
			enemy_unit_to_be_played=can_spawn_unit({1,16}, player_last_played_unit, 0, true)
		end
		if contains({8},player_last_played_unit.id) then
			enemy_unit_to_be_played=can_spawn_unit({12,10,14,15,16}, player_last_played_unit, 0, true)
		end
		if contains({2},player_last_played_unit.id) then
			enemy_unit_to_be_played=can_spawn_unit({9}, player_last_played_unit, 0, true)
		end
	end	
	if current_tactic>0 and turns<9 then
		enemy_unit_to_be_played=can_spawn_unit({9,7}, false, 1, true)
		if rand(2)==0 then
			enemy_spawn_lane=3
		end
	end	
	if ready_to_cast() and rand(80)<crystals_enemy then
		return 2
	end
	while enemy_unit_to_be_played==nil or contains({15,16,17}, enemy_unit_to_be_played.id) do
		enemy_unit_to_be_played=get_card(enemy_cards[rand(#enemy_cards) + 1])
	end
	if rand(300)<crystals_enemy then
		return 3
	else
		return 0
	end
end
function get_first_unit_in_lane(lane)
	first_unit=0
	for i=1,#enemies do
		enemie=enemies[i]
		if enemie.lane==lane and enemie.pos>first_unit then
			first_unit=enemie.pos
		end
	end
	for i=#friends,1,-1 do
		friend=friends[i]
		if friend.lane==lane and friend.pos>first_unit then
			return 100+friend.id
		end
	end	
	return first_unit
end
function checkcardbuttons()
	if btnp"4" then
		card_selected-=1
		if card_selected<1 then
			card_selected=#my_cards
		end
		show_cards_timeout=ticks+180
	end
	if btnp"5" then
		card_selected+=1
		if card_selected>#my_cards then
			card_selected=1
		end
		show_cards_timeout=ticks+180
	end
end
function updatehalfturn(group, death_group)
	for i=1,#group do
		g=group[i]
		if g.id<15 then
			group[i].spr=g.spr_normal
		elseif g.freezetime>0 then
			group[i].hp-=3
		end
		if contains(g.modifiers, 2) then
			if g.freezetime>0 then
				del(group[i].modifiers, 2)
				group[i].freezetime=0
			else
				group[i].hp-=1
				if g.hp>0 then
					something_burning=true
				end
			end
		end
		if group[i].hp<1 then
			add(death_group, group[i])
			del(group[i].modifiers, 2)
			if g.id<15 then
				group[i].spr, group[i].height, group[i].width = 
				171, 2, 2
			else
				group[i].spr, group[i].height, group[i].width = 
				0, 1, 1
			end
			lanes[g.lane][g.pos]["occupied"]=false
		end
	end
end
function updatefreeze(group)
	for i=1,#group do
		group[i].spr,group[i].acted=group[i].spr_normal,false
		if group[i].freezetime>0 then
			group[i].freezetime-=1
		end
	end
end
function updatewizard(wizard)
	wizard.spr,wizard.acted=wizard.spr_normal,false
end
function updatefallingsprite(wizard,p1)
	falling,x=result=="draw" or (p1 and result=="lose") or (not p1 and result=="win"),112

	if falling then
		if ticks%20<10 then
			wizard.spr = wizard.spr_falling1
		else
			wizard.spr = wizard.spr_falling2
		end
		if offset>20 then
			wizard.spr = wizard.spr_defeat
			if wizard.id==13 then
				wizard.height=1
			end
		end
	else
		if ticks%20<10 then
			wizard.spr = wizard.spr_win1
		else
			wizard.spr = wizard.spr_win2
		end
	end
	if p1 then
		x=0
	end
	replacecolours(wizard.darkcolorreplace,wizard.lightcolorreplace)
	if offset>4 and falling then
		spr(wizard.spr,x,35+min(offset-4,20)-1+16-wizard.height*8,wizard.width,wizard.height,not p1,false)
	else
		spr(wizard.spr,x,52-wizard.height*8,wizard.width,wizard.height,not p1,false)
	end
	replacecolours(1,12)
end
function updatefallingtower(p1)
	x=104 
	if p1 then
		x=0
	end
	if result=="draw" or (not p1 and result=="win") or (p1 and result=="lose") then
		if offset<18 then
			crashspr = 30
			if ticks%10 > 5 then
				crashspr = 46
			end
			clip(0,47,128,24)
			spr(199,x,47+offset,3,3)
			clip()
			spr(crashspr, x+16,63)
			spr(crashspr, x,63, 2,1,true,false)
		else
			spr(16,x+12,63)
			spr(16,x+4,63,1,1,true,false)
		end	
	else
		spr(199,x,47,3,3)		
	end
end
function updatewizardattack(wizard, target, lastpos)
	if not target.acted and target.pos==lastpos then
		target.spr,target.acted=target.spr_attack,true
		wizard.hp-=target.attack
		sfx(target.sfx_attack)
		if wizard==wizard_player then
			has_lost_life=true
		end
		if target.id>14 then
			target.hp-=3
		elseif not wizard.acted then
			if contains(target.modifiers,4) then
				del(target.modifiers,4)
			else
				target.hp-=wizard.attack
				if contains(wizard.specials, 2) then
					add(target.modifiers, 2)
					sfx(3,3)
				end
			end
			sfx(wizard.sfx_attack,1)
			wizard.spr,wizard.acted=wizard.spr_attack,true
		end
	end
end
function updatecrystals()
	updatecrystallane(1)
	updatecrystallane(3)
end
function updatecrystallane(lane)
	for x=3,8 do
		crystal_trigger=0
		cryst=lanes[lane][x]["crystal"]
		if cryst>0 then
			for i=1,#friends do
				friend=friends[i]
				if friend.lane==lane and friend.pos==x and friend.id<15 then
					crystal_trigger=21
				end
			end
			for e=1,#enemies do
				enemie=enemies[e] --sic
				if enemie.lane==lane and enemie.pos==x and enemie.id<15 then
					crystal_trigger=11
				end
			end
			if crystal_trigger>0 then
				if flr(cryst/10)!=flr(crystal_trigger/10) then 
					lanes[lane][x]["crystal"]=crystal_trigger
					if crystal_trigger==21 then
						sfx"7"
					end
				end
			end
		end
	end
end
function harvestcrystals()
	crystals_player+=1
	crystals_enemy+=1
	for lane=1,3,2 do
		for x=3,8 do
			if lanes[lane][x]["crystal"]>9 then
				lanes[lane][x]["crystal"]+=1
				if lanes[lane][x]["crystal"]==26 then
					crystals_player+=1
					lanes[lane][x]["crystal"]=21
					sfx"15"
				elseif lanes[lane][x]["crystal"]==16 then
					crystals_enemy+=1
					lanes[lane][x]["crystal"]=11
				end
			end
		end
	end
end	
function attack(attackgroup,targetgroup,friendly,ranged)
	offset=1
	if ranged then
		offset=2
	end
	if friendly then
		offset*=-1
	end
	for e=1,#attackgroup do
		attacker=attackgroup[e]
		for i=1,#targetgroup do
			target,rangetest=targetgroup[i],contains(attacker.specials,1)
			if not ranged then
				rangetest=true
			end
			if not attacker.acted and target.lane == attacker.lane and 
				target.pos == attacker.pos-offset and rangetest and attacker.freezetime==0 then
				if (ranged and target.id>14) or attacker.freezetime>0 then
					-- do nothing
				else
					if target.id<15 or attacker.id>14 then
						attackgroup[e].spr,attackgroup[e].acted=attacker.spr_attack,true
						sfx(attacker.sfx_attack)
					else
						targetgroup[i].hp -= 3
					end
					if contains(target.modifiers,4) then
						del(targetgroup[i].modifiers,4)
					else
						targetgroup[i].hp -= attacker.attack
						if contains(attacker.specials,2) then
							add(targetgroup[i].modifiers, 2)
							sfx(3,3)
						elseif contains(attacker.specials, 5) then
							targetgroup[i].freezetime=3
						end
					end
					if attacker.id>14 then
						attackgroup[e].hp -= 3
					end
				end
			end
		end
		friendly_fire(e, attackgroup, offset)
	end
end
function friendly_fire(e,attackgroup,offset)
	attacker=attackgroup[e]
	if not attacker.acted and attacker.id>14 then
		for i=1,#attackgroup do
			friendlytarget=attackgroup[i]
			if  friendlytarget != attacker and friendlytarget.lane == attacker.lane and 
				friendlytarget.pos == attacker.oldpos-offset and 
				((contains(friendlytarget.specials,3) and friendlytarget.blocked) or 
				not contains(friendlytarget.specials,3))
				then
				attackgroup[e].spr,attackgroup[e].acted=attacker.spr_attack,true
				sfx(attacker.sfx_attack)
				if contains(friendlytarget.modifiers,4) then
					del(attackgroup[i].modifiers,4)
				else
					attackgroup[i].hp -= attacker.attack
					if attackgroup[i].id>14 then
						attackgroup[i].hp-=3
					end
					if contains(attacker.specials, 2) then
						add(attackgroup[i].modifiers, 2)
						sfx(3,3)
					elseif contains(attacker.specials, 5) then
						attackgroup[i].freezetime=3
					end
				end
				attackgroup[e].hp-=3
			end
		end
	end
end
function move(group, friendly, sprinters)
	change=-1
	if friendly then
		change=1
	end
	for i=1,#group do
		g=group[i]
		if not sprinters then
			group[i].blocked=false
			group[i].oldpos=group[i].pos
		end
		lane,mov=g.lane,not g.acted and not g.blocked and g.freezetime==0 and g.hp>0
		if sprinters then
			mov = mov and contains(g.specials,3)
		end
		if mov then
			if lanes[lane][g.pos+change]["occupied"] == false then

				lanes[lane][g.pos+change]["occupied"],
				lanes[lane][g.pos]["occupied"],
				group[i].oldpos=
					true,false,g.pos
				group[i].pos+=change
			else
				group[i].blocked=true
				if g.id>14 then
					friendly_fire(i, group, change)
				end
			end
		end
	end
end
function draw_upgrade()
	tres,desc=c.treasure,"  (two health)"
	if tres==1 then
		spr(104,15,10)
		spr(104,22,10)
	elseif tres==2 then
		spr(120,15,10)
		spr(120,22,10)
		desc="  (two attack)"
	elseif tres==3 then
		spr(13,15,10)
		desc="(shield)"
	elseif tres==4 then
		spr(121,15,10)
		desc="(fire attack)"
	elseif tres==5 then
		spr(14,15,10)
		desc="(haste)"
	end
	spr(105,43,22)
	print("add   ".. desc .. " to a spell\n\n  also add   to the spell cost", 0,10,2)
	for i=1,max(card_selected-1,1) do
		draw_card(53, 45, my_cards[i])
	end
	for i=#my_cards,min(card_selected+1,#my_cards),-1 do
		draw_card(53, 45, my_cards[i])
	end
	if sel_upgrade!=nil then
		print("\x8e to confirm, \x97 to cancel",22,90,2)
		draw_card(53, 35, sel_upgrade)
	else
		print("\x8e \x97 to select card\n\n   \x94 to upgrade!\n\n   \x83 to skip upgrade",22,90,2)
		draw_card(53, 45, my_cards[card_selected])
	end
end
function draw_treasure()
	if c.special==4 then
		print("you beat me! wow!\nin return, i will\nupgrade your wand's\nattack power!",30,40,2)
	elseif c.treasure==nil or c.special==6 then
		return
	else
		print("you have received:",30,40,2)
		just_draw_card(54,50, c.treasure)
	end
	print("thanks! \x8e \x97", 38, 88,2)
end
function draw_challenge()
	unit=c.unit
	replacecolours(c.darkcolorreplace,c.lightcolorreplace)
	print(c.name,32,1,2)
	spr(unit.spr, 64 - unit.width*4, 17 - unit.height*4, unit.width, unit.height, c.flip, false)
	if c.special<10 then 
		print("check out my spells!",25,28,2)
		l=#c.cards
		for i=1,l do
			x=42-l*12+i*24
			if l>5 then
				x=45-l*60/l+i*120/l
			end
			just_draw_card(x, 37, get_card(cards[c.cards[i]].id))
		end
	end
	for i=1,#c.story do
		print(c.story[i], 10,66 + 8*i,2)
	end
	replacecolours(1,12)
	if c.special!=1 then
		print("challenge me?",37,90,2)
	end
	print("yes \x8e        no \x97", 25, 100,2)
	print(errormsg,18,110,2)
end
function _draw()
	cls"0"
	if intro then
		intro_draw()
		return
	end
	if state==11 or state==12 then
		for i=0,13 do
			print(intro_story[i+story_marker], 1, i*10, 5)
		end
		return
	elseif state==13 or state==14 then
		map(22,15,0,0,26,26)
		init_lanes(1)
		draw_crystal_tower(lanes[3][5])
		draw_corners()
		spr(199,0,47,3,3)
		spr(199,104,47,3,3)
		if state==13 then
			draw_crystal_tower(lanes[1][6])
			print("   crystal tower.\nclaim it and get a\nbonus crystal every\nfive turns!",25,25,0)
			spr(108,51,17)
			print("your tower.\ndefend it\nat all costs!",1,73,0)
			spr(108,0,65)
			print("your enemy's\ntower.\ndestroy it!",80,73,0)
			spr(108,107,65)
			print("\x94\n \x91 press arrow to\n\x83  cast spell in lane",14,54,7)
			print("\x8b toggle unit info",26,1,7)
			print("       \x8e and \x97\nbrowse and select spell",19,116,7)
		else
			print("when you cast a spell, a unit\nwill spawn in the chosen lane,\nwith attributes as per the\nspell description:",5,1,7)
			draw_card(62, 24, get_card(4))
			print("health      attack\n  mods      cost",28,43,0)
			print("this spell's mods are:",20,66,7)
			print("ranged attack\nfire attack",40,73,0)
			spr(15,33,73)
			spr(121,33,79)
			print("any unit that reaches the\nenemy's tower, will attack it.\nonce the health of the tower\nis zero, it falls and you win!",5,104,7)
		end
		return
	elseif state==10 then
		map(117,0,36,14,7,7)
		l_spr,offset,col=196,ticks/16,cols[flr(ticks/10)%4+1]
		if ticks%32<16 then 
			l_spr=224
		end
		spr(l_spr,60,50,2,2)
		print("the",36,sin(offset/4)+4,col)
		print("lich",55,cos(offset/3)+4,col)
		print("ruin",78,sin(offset/2)+4,col)
		print("\x8e start",49, 76, 5)
		print("\x97 change difficulty",24, 86, 5)
		print("difficulty: " .. difficulty[diff][1],30, 105, 5)
		print(difficulty[diff][2],6, 115, 5)
		return
	end
	if state==2 then
		draw_challenge()
		return
	elseif state==4 then
		draw_treasure()
		return
	elseif state==5 or state==6 then
		draw_upgrade()
		return
	elseif state==1 then
		cls"3"
		rectfill((110-wiz_x)*8, (6-wiz_y)*8, (132-wiz_x)*8, (8-wiz_y)*8-1,12)
		map(wiz_x-7, wiz_y-6, 0,0, 16, max(0,38-wiz_y))
		replacecolours(2,8)
		spr(wiz_spr,56,48,2,2,wiz_flip,false)
		for i=1,#challengers do
			replacecolours(challengers[i].darkcolorreplace,challengers[i].lightcolorreplace)
			spr(challengers[i].unit.spr, (challengers[i].x-wiz_x+7)*8+8 - challengers[i].unit.width*4, (challengers[i].y-wiz_y+6)*8+8 - challengers[i].unit.height*4, challengers[i].unit.width, challengers[i].unit.height, challengers[i].flip, false)
		end
		replacecolours(1,12)
		return
	end
	map(c.mapx,c.mapy,0,0,16,16)
	
	for i=1,#enemies do
		draw_unit(enemies[i], true, wizard_enemy)
	end
	for i=1,#friends do
		draw_unit(friends[i], false, wizard_player)
	end
	for i=3,8 do
		draw_crystal_tower(lanes[1][i])
		draw_crystal_tower(lanes[3][i])
	end
	if gameover then
		offset = flr(ticks/4)
		updatefallingsprite(wizard_player,true)
		updatefallingsprite(wizard_enemy,false)
		updatefallingtower(true)
		updatefallingtower(false)
	else
		replacecolours(2,8)
		spr(wizard_player.spr,0,36,2,2)
		spr(199,0,47,3,3)
		if wizard_player.spr==110 then
			spr(125,8,6*8-4)
		end
		replacecolours(wizard_enemy.darkcolorreplace,wizard_enemy.lightcolorreplace)
		spr(wizard_enemy.spr,112,52-wizard_enemy.height*8,wizard_enemy.width,wizard_enemy.height,true,false)
		spr(199,104,47,3,3)
		if wizard_enemy.spr==110 then
			spr(125,112,44,1,1,true,false)
		end
		replacecolours(1,12)
	end
	draw_corners()
	if info then
		draw_wiz_info(wizard_player,1)
		draw_wiz_info(wizard_enemy,122)
	end
	if gameover then
		if result=="draw" then
			print("it's a draw!", 43,44,0)
		else
			print("you " .. result .. "!", 46,44,0)
		end
	else
		if error_countdown>ticks then
			print(errormsg, 25,44,0)
		end
		arc(121,6,5,ticks%120/120,6)
		rectfill(8,57,16,63,7)
		offset_x=11
		if crystals_player>9 then
			offset_x=9
		end
		print(crystals_player, offset_x,58,2)
	end
	if can_see_enemy_crystals and not gameover then
		rectfill(111,57,119,63,7)
		offset_x=114
		if crystals_enemy>9 then
			offset_x=112
		end
		print(crystals_enemy, offset_x,58,1)
	end
	if show_cards_timeout>ticks and not gameover then
		for i=1,max(card_selected-1,1) do
			draw_card(53, 24, my_cards[i])
		end
		for i=#my_cards,min(card_selected+1,#my_cards),-1 do
			draw_card(53, 24, my_cards[i])
		end
		draw_card(53, 24, my_cards[card_selected])
	end
	if ticks<240 and not gameover and show_cards_timeout<ticks then
		print("get ready!\n    " .. 4-flr(ticks/60), 45,44,0)
	end
	if state==20 then
		rectfill(-1,0,ticks-death_timeout,35,0)
		rectfill(128,128,128-(ticks-death_timeout),71,0)
		if death_timeout<ticks-128 then
			if wizard_enemy.hp<1 then
				print("           amazing!\n      you have defeated\n the evil lich lord afgorkon\nand brought peace to harberia!",6,11,7)
				print(" the magelords all thank you,\n   and you are awarded the\n      honourable rank of\n        grand magelord!",6,73,7)
				if diff>1 then
					print(difficulty[diff][1] .. " mode",57-diff*5,1,diff*3)
				end
			else
				print("game over!",45,29,7)
			end
		end
	end
end
function replacecolours(dark,light)
	pal(1,dark)
	pal(12,light)
end
function draw_corners()
	spr(1,0,0,1,1,true,true)
	spr(1,120,0,1,1,false,true)
	spr(1,0,120,1,1,true,false)
	spr(1,120,120)
end
function draw_wiz_info(wizard, x)
	v = 0
	for i=1,wizard.hp do
		spr(104, x, 46+i*6)
	end
	for i=1,wizard.attack do
		spr(120, x, 36-i*5)
		v = i
	end
	if contains(wizard.specials,2) then
		spr(121, x, 30-v*5)
	end
end
function draw_crystal_tower(val)
	v=val["crystal"]
	if v<0 then
		return
	elseif v==5 then
		pal(12,5)
	elseif v>20 then
		replacecolours(2,8)
	end
	spr(4+v%10,val["x"]*8+4,val["y"]*8+2)
	replacecolours(1,12)
	spr(25, val["x"]*8+4, val["y"]*8+10)
end
function draw_card(x, y, sel)
	spacing=4
	if #my_cards<8 then
		spacing=8
	elseif #my_cards<12 then
		spacing=6
	end
	index=0
	for i=1,#my_cards do
		if my_cards[i].id==sel.id then
			index=i
		end
	end
	card_x=x-#my_cards*spacing+index*spacing + flr(#my_cards/2)*spacing -2
	just_draw_card(card_x,y,sel)
end
function just_draw_card(card_x,y,card)
	spr(128, card_x, y,2,2)
	spr(128, card_x+15, y,1,2, true, false)
	offset_y=y+16
	if #card.specials>2 then
		spr(144, card_x, offset_y)
		spr(144, card_x+7, offset_y,2,1,true,false)
		offset_y+=8
	end
	spr(128, card_x, offset_y,2,2, false, true)
	spr(128, card_x+7, offset_y,2,2, true, true)
	replacecolours(2,8)
	if card.id==9 then
		rectfill(11+card_x - card.width*4, y+5, 27+card_x - card.width*4, y+14, 13)
	end
	spr(card.spr_normal, 12+card_x - card.width*4, y+10 - card.height*4, card.width, card.height)
	replacecolours(1,12)
	print(card.maxhp, 2+card_x,y+19,6)
	print(card.attack, 12+card_x,y+19,6)
	spr(104, card_x+6, y+19)
	spr(120, card_x+16, y+19)
	print(card.cost, 12+card_x,y+25,6)
	spr(105, card_x+16, y+25)	
	for i=1,#card.specials do
		spr(specials_spr[card.specials[i]], -2+card_x+i*4-14*flr(i/3) +min(flr(i/3),2)*2*i,y+25+7*flr(i/3))
	end
end
function arc(x,y,r,angle,c)
	circfill(x,y,r,0)
	if angle<0 then return end
 	for i=0,.75,.25 do
		local a = angle
		if a<i then break end
		if a>i+.25 then a = i+.25 end
		local x1,y1,x2,y2 = 
			x + r * cos(i),
			y + r * sin(i),
			x + r * cos(a),
			y + r * sin(a)
		local cx1,cx2,cy1,cy2 = 
			min(x1, x2),
			max(x1, x2),
			min(y1, y2),
			max(y1, y2)
		clip(cx1,cy1,cx2-cx1+2,cy2-cy1+2)
		circ(x,y,r,c)
		clip()
	end
end
function draw_unit(unit, unfriendly, wizard)
	flips = unfriendly
	if unit.spr==171 then
		flips=false
	end
	col=0
	if unit.id==9 then
		col=2
		if unfriendly then
			col=1
		end
	end
	changex,changey,percent=
		lanes[unit.lane][unit.pos]["x"]-lanes[unit.lane][unit.oldpos]["x"],
		lanes[unit.lane][unit.pos]["y"]-lanes[unit.lane][unit.oldpos]["y"],
		min(ticks%120,59)%60 /59
	if unit.acted or unit.blocked or unit.freezetime>0 or gameover or unit.hp<1 then
		percent=1
	elseif contains(unit.specials,3) then
		percent=min(ticks%60,59)%60 /59
	end
	unit_x,unit_y=
		(lanes[unit.lane][unit.pos]["x"] - changex)*8 + percent*changex*8,
		(lanes[unit.lane][unit.pos]["y"] - changey)*8 + percent*changey*8
	if unit.id==12 and wizard_enemy.id==13 and unfriendly then
		pal(15,2)
	end
	replacecolours(wizard.darkcolorreplace,wizard.lightcolorreplace)
	if unit.freezetime>0 and unit.spr!=171 then
		for i=0,13 do
			pal(i,7)
		end
		pal(15,7)
		if unit.id!=12 then
			pal(12,wizard.lightcolorreplace)
		end
	end	
	spr(unit.spr, unit_x + 16 - unit.width*8, unit_y + 8 - unit.height*4, unit.width, unit.height, flips, false)
	for i=0,15 do
		pal(i,i)
	end
	if info and unit.spr!=0 and unit.spr!=171 then
		for i=1,unit.hp do
			spr(104, unit_x + i*6 - unit.hp*3+3, unit_y-4)
		end
		for i=1,unit.attack do
			spr(120, unit_x + i*6 - unit.attack*3 - #unit.specials*3 +2, unit_y+16)
		end
		for i=1,#unit.specials do
			spr(specials_spr[unit.specials[i]],  unit_x + (unit.attack)*4 + i*5 - #unit.specials*2, unit_y+16)
		end
	end
	if contains(unit.modifiers, 2) and unit.spr!=171 then
		fire_spr=98
		if ticks%10<5 then
			fire_spr=96
		end
		spr(fire_spr, unit_x + 8 - unit.width*4, unit_y, 2, 2)
	end
	if contains(unit.modifiers, 4) then
		offset_x=8*unit.width-3
		if unfriendly then
			offset_x=-5
		end
		spr(143, unit_x + offset_x, unit_y, 1, 2, unfriendly, false)
	end
end
function init_step(x,y)
	step={}
	step["x"],step["y"],step["occupied"],step["crystal"]=x,y,false,-1
	return step
end
function init_lane(delta,maptype)
	lane,vertical_steps={},3
	if delta<0 and maptype%3==2 then
		vertical_steps=2
	elseif delta>0 and maptype%3>0 then
		vertical_steps=2
	end
	for i=0,vertical_steps do
		lane[i] = init_step(1,7+i*2*delta)
	end
	for i=1,6 do
		lane[vertical_steps+i] = init_step(i*2+1,7+vertical_steps*2*delta)
	end
	for i=1,vertical_steps-1 do
		lane[vertical_steps+i+6] = init_step(13,7+(vertical_steps-i)*2*delta)
	end
	if maptype<4 then
		lane[vertical_steps+3]["crystal"] = 5
	elseif maptype < 7 then
		lane[vertical_steps+3-delta]["crystal"] = 5
	elseif maptype < 10 then
		lane[vertical_steps+3+delta]["crystal"] = 5
	elseif maptype < 13 then
		lane[vertical_steps+3-delta*2]["crystal"] = 5
	elseif maptype < 16 then
		lane[vertical_steps+3+delta*2]["crystal"] = 5
	elseif maptype < 19 then
		lane[vertical_steps+3+delta*2]["crystal"] = 5
		lane[vertical_steps+3-delta*2]["crystal"] = 5
	else
		lane[vertical_steps+4]["crystal"] = 5
	end		
	lane[vertical_steps*2+6],lane[0]["occupied"]=init_step(13,7),true
	lane[vertical_steps*2+6]["occupied"]=true
	return lane
end
function init_lanes(maptype)
	lanes={}
	for i=1,3 do
		lanes[i] = {}
	end
	for i=0,6 do
		lanes[2][i] = init_step(1+(i*2),7)
	end
	lanes[2][0]["occupied"],lanes[2][6]["occupied"],lanes[1],lanes[3]=
		true,true,init_lane(-1,maptype),init_lane(1,maptype)
end
function intro_init()
  map_x,map_y,offs,intro,logo= 
  130,24,17,true,
  {0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 	0,5,7,1,5,7,3,1,0,1,0,5,7,1,5,1,5,7,3,5,7,1,5,7,3,0,0,0,
	 	0,1,0,1,1,0,1,1,0,1,0,1,0,1,1,0,1,0,1,1,0,1,1,0,6,0,0,0,
	 	0,2,7,1,2,7,6,2,1,2,1,2,7,1,1,0,2,7,6,1,0,1,2,7,6,0,0,0,
	 	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,4,0,0,0,0,0,0,0,0,0,
	 	7,7,3,5,1,5,7,3,5,7,1,1,0,1,5,1,7,1,1,5,7,3,7,7,3,5,1,0,
	 	1,0,1,1,0,1,0,1,1,0,1,1,0,1,1,0,1,0,1,1,0,1,1,0,1,2,3,0,
	 	7,7,6,1,0,2,7,6,2,7,1,2,7,6,2,1,2,1,1,2,7,6,1,0,1,7,6,0,
	 	1}
  music"0"
end
function intro_update()
	map_x-=1
	if map_x<-350 or btnp"4" or btnp"5" then
		intro=false
		music(battle_themes[2])
	end
end
function intro_draw()
	offset_y=0
	for i=1,#logo do
		if logo[i]>0 then
			if i>112 then
				offset_y=8
			end
			spr(offs+logo[i], map_x+8*(i%28), map_y+flr(i/28)*8+offset_y)
		end
	end
end
__gfx__
eeeeeeeeeeeeeeee565555663333333333333333eee76eeeeee76eeeeee76eeeeee76eeeeee76eeeeeeeee9999eeeeeee5655599e727eeeeeeaeeeeeee44eeee
eeeeeeeeeeeeeeee555445553355533333333333ee7116eeee7116eeee7116eeee7cc6eeee7cc6eeeeeee9aaaa9eeeeee5665655ee727eeeeaeeeeeee6e44eee
eeeeeeeeeeeeeeee545445453533353333333333e711116ee711116ee71cc16ee7c11c6ee7cccc6eeeee9a9999a99eeee5555554ee727eeeeeaeeeee6eee4eee
eeeeeeeeeeeeeee054544545333333333335553371111116711cc11671c11c167c1111c67cccccc6ee99aaaaaaaaa99ee5655454e727eeeeeaeeeeeee6e44eee
eeeeeeeeeeeeeee054dddd45333333333353335371111116711cc11671c11c167c1111c67cccccc699a99aaaaaa99aa9e56554ddeeeeeeeeeeeeeeeeee44eeee
eeeeeeeeeeeeee00545445453333333333333333e711116ee711116ee71cc16ee7c11c6ee7cccc6e9aaaa999999aaaa9e5555454eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee000545445453333333333333333ee7116eeee7116eeee7116eeee7cc6eeee7cc6ee9999aaaaaaaa9999ee555454eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeee00000555555553333333333333333eee76eeeeee76eeeeee76eeeeee76eeeeee76eeee559999aa999955eeeee5555eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee7ae11111110111111111100000011111110000001111111111011111111eee76eeee54555999955545e9955565e56665666eeeeeeeeeeeeeeee
eeeeeeeeeeee99aa11111110111111111111000011111110000111111111111011111111eee76eeee54444555544445e5566565e55555555ee5555eeeeee5555
eeeeeeeeeee8899a11111110011111111111100011111110001111111111110011111111eee76eeee55444000044455e4556555e66566665e5d77d555555ddd5
eeeeeeeeeeee889a11111110011111111111110011111110011111111111110011111111eee76eeee54550000005545e4545565e665666655d7777ddddddd7dd
555555eeeee8899a11111110001111111111110011111110011111111111100011111111ee7766eee54440000004445e4545655e555555555d7777d77777d77d
56666555eeee99aa11111110000111111111111000000000111111111111000011111111e555555ee55440000004455e4545655e65544556e5d777dd777d77dd
5d666566eeeee7ae11111110000001111111111000000000111111111100000011111111eeeeeeeedd555000000555dd454555ee54544545ee5d7dd577dd5dd5
55555555eeeeeeee00000000000000000000000000000000000000000000000000000000eeeeeeeedddd555555555ddd5555eeee54555545eee555555555555e
333333bba33333333333333333333333eeeeee555eeeeeee05555555505555555dddddddd5ddddddddddddddddddddddee55555e55544545eeeeeeeeeeeeeeee
3333bbbbbb3333333333333bbb333333eeeee556555eeeee05555555505555555dddddddd5dddddde44ddd4dd4ddd44ee556665554544545eee55555555eeeee
333b3bb3bbbb3333333333bbbbb33333eeee55556655eeee05555555505555555dddddddd5dddddde44eee4444eee44e5566666554dd4555ee5dddddd77dd555
333bb3bbb3b3b33333333b3b5b3b3333eee5566566655eee00000000000000005555555555555555e44eee4ee4eee44e5666666554d44545e5dd777d777dd7dd
3333abb3bbba533333333ba3bbba3333ee556665666665ee5055555555505555d5ddddddddd5dddde44eee4444eee44e5665566554555545e5d777d5777d777d
33bbbbbb3bbbb3333333bbbb5bbbb333ee5666655666665e5055555555505555d5ddddddddd5dddde44eee4ee4eee44e5656556554544545e5d777d577dd777d
3bb3bb5bbbbb33333333abbba5bb3b33e5566666566666555055555555505555d5ddddddddd5dddde44eee4444eee44e5566665554544545ee5d7dddd7d577dd
3b5bbabbb3bbb333333bb5bbbbbbb533e566666656666665000000000000000055555555555555555555ee4ee4ee5555e555555555555555eee555555555555e
3babb3bbbbbbba33333bbbbbbb3bba33e5666666656666655555555550555555ddddddddd5ddddddcccccccc5ddddddd5dddddddddddddd5ddddddd533333333
bbb3bbb55bbbbbb333abbbbabbbb3bb355666666656666655555555550555555ddddddddd5ddddddcccccccc5ddddddd5dddddddddddddd5ddddddd533333333
bbbbbb5445bb3bb333b3bbb555babbb356666666656666555555555550555555ddddddddd5ddddddcccccccc5ddddddd5dddddddddddddd5ddddddd533333333
3bbbb54545bbbb33333bab54445bbb33566666666566655e00000000000000005555555555555555cccccccc5555555555555555555555555555555533333333
3333334543333333333333344433333356666666656665ee5555555505555555dddddddd5dddddddcccccccc5ddddddd5dddddddddddddd5ddddddd533333333
333544444543333333333344444333335566666665655eee5555555505555555dddddddd5dddddddcccccccc5ddddddd5dddddddddddddd5ddddddd533333333
33443544343333333333345344543333e55566665555eeee5555555505555555dddddddd5dddddddcccccccc555555555ddddddd55555555ddddddd533333333
33333333333333333333333333333333eee555555eeeeeee00000000000000005555555555555555cccccccc5555555555555555555555555555555533333333
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6d6eeeeeeeeeeeee6d6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44444eeeee4eeeeeeeeeeeeeeeee
eeeeeee6eeeeeee6eeeeeeee6eeeeeeeee6d666eee64eeeeee6d666eee64eeeeeeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeee4444444eee444eeee4444eeeeeeee
eeeee6666eeeeee6eeeeee6666eeeeeeeee5d4bbe6e4eeeeeee5d4bbee64eeeeeeeeeeeeeeeeeeeeeeeee7c77eeeeeeeee444fffffeee444eee4444444eeeeee
eeee666666eeee66eeeee666666eeeeeeee44bbb6eee4eeeeee44bbbbe6e4eeeeeeee777eeeeeee6eeeee777ceeeeeeeee44fcffcfee4444e4444fffffeeeeee
eeeebbcbcbeeee66eeeeeebbbbeeeeeeeee4bbc6cbee4eeeeee4bbcbcb6e4eeeeeee7c7ceeeeeee6eeeeee77eeeeeeeee444fff9ffee44444444fcffcfeeeeee
eeeebbbbbbeeee4eeeeeebbcbcbeeeeeeee4b66bbbeee4eeeee4bbbbbb6ee4eeeeee7777eeeeee66eee7777eeeeeeeeee444f4444fee44444444fff9ffeeeeee
eeeeeb00beeeee4eeeeeebbbbbbeeeeeeee46b00beeee4eeeee44bb0be6ee4eeeeeee77eeeeeee66ee776677eeeeeeee44ff145541fe444e44eef4444feeeeee
eee11bbbb11ee44eeeeeeebb0beeeeeeeee61bbbb111146eeee41bbbb16114eeee77766777eee666e7e66e7e7eeeeeee4fff114411f4444eeeff145541feeeee
ee1111bb1111e4eeeee111bbbb1eeeeeeb64444444444466ebb11111116ee4eee7e7e66e7e7ee66ee776e7ee7eeeeeee4ff1111111f444eeefff144411ffeeee
e1111111111114eeee11111bb111eeeeebb61111111ee46eebb11111116ee4eee7ee7777ee7e666e7e777ee7eeeeeeeeeff1111111ff44eefff11111ffffeeee
b11e111111e11beeee11e1111111e6eeeeee661111ee4eeeeeee1111116e4eee7ee7e66e7ee716ee7eee7717eeeeeeeeeff1111111fffeeefff144fffffeeeee
bbee000000ee4beee4bb444444bb6666eeee006600ee4eeeeeee0000006e4eee7eee7777ee171eee7eee7e71eeeeeeeeeff000000044feeeffff44ff4444eeee
eeee000000ee4eeeeee0000000eee6eeeeee000066e4eeeeeeee00000064eeeeeee7eeee7e11eeee6eee7ee116eeeeeeeff00000004eeeeeefffff444444444e
eeee00ee00ee4eeeeee000e000eeeeeeeeee00ee0064eeeeeeee00ee0064eeeeeee7eeee7eeeeeeee77e6eee6666eeeeeee000e000eeeeeee00fff4444444444
eeee44ee44eeeeeeeee44eee44eeeeeeeeee44ee44eeeeeeeeee44ee44eeeeeeeee7eeee7eeeeeeeeeeee77ee66666eeeee44eee44eeeeeee44e444ee4444444
eeee444e444eeeeeeee444ee444eeeeeeeee444e444eeeeeeeee444e444eeeeeeee677ee677eeeeeeeeeeeeeeee66666eee444ee444eeeeee444eeeeeee4444e
eee9eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeee8eee8eee8e8eeeeee6eeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeee111111eeeee
eeeaeee9e9eaeeeeeeeeae9e9eeeeeeeeeeeeeeeeeeeeeeeeeee8988898e898e88888eeee676eeeeeeeeeeeeeeee7666eeeee000ee7aaeeeeeee11ccccc11eee
ee9aaeeaaee9eeeeeeee9eeaaeeaeeeeeeeeeeeeeeeeeeee8ee8988998888eee88888eee67776eeeeeee766767e7776eeeee00007a989aeeeee11cc1001cc1ee
eeaa9eaa9e9aaeeeeeeaa9e9eae9eeeeeeeeeeeeeeeeeeeee8888999999988eee888eeeee676eeeeeee7ee7e7e67c77eeee000e0ee888aeeee11cc100001c1ee
ee9aeaaaaaaa9aeeeea9eaeaeaaae9eeeeeeeeeeeeeeeeee8e9989999999998eee8eeeeeee6eeeeeeee7ee7e7ee677c7ee000eee7a989aeeee1c1cc00000c1ee
eeaa9aeeeeeaeaeeeeaaeee9eaa9aeeeeeeee8eeee8899eee8889999aaaaa998eeeeeeeeeeeeeeeeeeee7667e76e677eee00eeeeee7aaeeee1c1f4c0444c11ee
ee99eeaaaeeee9eeee9aeeeeae9e9eeeeeeeeee88899999eeee8999aaaa7aa98eeeeeeeeeeeeeeeeeeee6e7ee76eeeeeeeeeeeeeeeeeeeeee1c1f4c4fffc1eee
eee9e9eeeeaaeeeeeeeeaeeeeee89eeeeeeeee88999aa999e88999aaaa777a98eeeeeeeeeeeeeeeeeee66e67e676eeeeeeeeeeeeeeeeeeeeee1111ccfffc1eee
eee9eeeeeea9e9eeee9e9aeeee9e9eeeee88ee8999aa77a9889999aaa7777a98eeeeeeeeeeeeeeeeeeeeeeeeeeee66eeeedeeeeeccc11eeeeee1c111ccc11eee
eeeeeee9eee988eeee8e9eee9ee88eeeeeee8889aaa77779888999aaa7777a98e4eeeeeeeeaeeeeeeeeeeeeeeee66eeee7d7eeee11cc1eeeee001cc111cc1eee
eee8e8eeee8eeeeeeeeee8ee8e8e8eeeeeeee8999aaa7799ee88999aaaa77a9844666eeeeaaaeeeeeee766767e7777eeed6deeee111c1eeeeee0000c111c1eee
eeee8eeeeeee8eeeeee8eeeee8e8eeeee8ee8889999aa99e888998999aaaa998e4eeeeeeea9aeeeeee7ee7e7e77c7c7ee7d7eeee000f1eeeeeee1cc0000f1eee
eeeee8eee88eeeeeeeeee88ee88eeeeeeeeeee88889999eee88899999999998eeeeeeeeeee8eeeeeee7ee7e7e67777eeeedeeeeeeef0000eeeee1c1cc0f0000e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88889999888eeeeeeeeeeeeeeeeeeeee7667e7ee66eeeeeeeeeeeeee09990eee1cc1cc0109990
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eee8e898888eeeeeeeeeeeeeeeeeeeeeee6e7ee76eeeeeeeeeeeeeeeeee0970eee111cccc110970
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8ee8ee8ee8eeeeeeeeeeeeeeeeeeeee6e67e676eeeeeeeeeeeeeeeeee00eeeeee11111eee00e
e22222222222222233335555eeee111111ee00eeeeee111111ee00eeeeee111111ee00eeeeee6ee6eeeeeeeeeeeeeeee55555555eeeeeeeee555eeeee1eeeeee
220000000000000033355333eee11ccccc10fc0eeee11ccccc10fc0eeee11ccccc10fc0eeeee666655555555eeee6ee65dddddd5eeeeeee555655eee7117eeee
200000000000000035553333ee11cc1001c0c70eee11cc1001c0c70eee11cc1001c0c70eeeee66665dddddd5eeee66665dddddd5eeeeee55766655ee7717eeee
200000000000000055333335e11cc1000010cc0ee11cc1000010cc0ee11f41000010cc0eeeee6c6c5dddddd5eeee66665d6dd0d5eeeeee57660665eee7177eee
200000000000000053333355e1c1cc00000c10eee1c1cc00000c10eee1cf4c00000c10eeeeee66665d6dd6d5eeee6c6c5d660005eeee5555444605eee7117eee
2000000000000000333335531c1f4c0444c110ee1c1f4c0444c110ee1c111c0444c110ee000006665d6666d5eeee66665d666000eee55774100465eee7717eee
2000000000000000335555331c1f4c4fffc1f0ee1c1f4c4fffc1f0ee1c1c1c4fffc1f0ee000001615d6666d5eeeee6665d664400ee557411414655eeee717eee
200000000000000055533333e1111ccfffcff0eee1111ccfffcff0eee11c11cfffcff0eee14111115d6666d5eee111615dd44dd0ee5766444455555eee717eee
200000000000000033333355ee1c111ccc1110eeee1c111ccc1110eeee1cc11ccc1110eee14111115dd66dd5ee1111005d446dd5e557667d665dddd5ee717eee
200000000000000033355553ee11cc1111ccc0eeee11cc1111ccc0eeee11cc1111ccc0eee14e11115dd66dd5eee11111ff4dddd5e576657dd66555d5ee717eee
200000000000000035555533eee1ccc11111c0eeeee1ccc11111c0eeeee1ccc11111c0eee14e11115dddddd5eeee11114ffddd5555765557dd666655e7717eee
200000000000000055555555eee1cccc111e10eeee11cccc111e10eeeee1cccc111e10eeef4e000055dddd55eeee000005dddd5e57665d5577766665e7117eee
200000000000000055555533eee1c1cc011ee0eeee1cc1cc011ee0eeeee1c1cc011ee0eeeff0000005dddd5eeee00000055dd55e57655d5555566655e7177eee
200000000000000035555333ee1cc1cc011ee0eeee1c1cc0111ee0eeee1cc1cc011ee0eeee4000e0055dd55eeee000e0045dd5ee57655dd5ee55555e7717eeee
200000000000000035555533ee111cccc111e0eeeee1cccc111ee0eeee111cccc111e0eeeee44ee44e5dd5eeeee44eee445555ee55665555eeeeeeee7117eeee
200000000000000055333533eeeee1111eeeeeeeeeee11111eeeeeeeeeeee1111eeeeeeeeee444e4445555eeeee444eeeeeeeeeee5555eeeeeeeeeeee1eeeeee
eeeeeeeeeeeeeeeecccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeccccccc33ccccccceeeeee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee33333355
eeeeeeeeeeeeeeeeccc66ccceeeeeeeeeeeeeeeeeeeeeeeeeeee44e4ccccc333333ccccceeeee55766655eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee33337773
eeeeeeeeeeeeeeeecc65555ceeeeeee4444eeeeeeeeeeeeeee447c44ccc3333333333ccceeeee57606065eeeeeee555555555eeeeeeee111111eeeee33370703
e444949444444eeecc5555dceeeee44447c4eeeeeeeeeeeee4444447cc333333333333cceeeee57644465eeeeee55666666655eeeee111cccc111eee35577775
4444949444444444ccc55dcceeeee47c4444444eeeeeeeeee444444ecc333333333333cceee55574100455eeee5566666666655eee11ccc1001c1eee55337755
4eeee9eeeeeee4e4cccccccceeee4444444447eeeeeeeeee447c447ec33333333333333cee5577541414d55eee5600660600665ee11ccc1000011eee33333553
4eeee9eeeeeee4e4cccccccceeee44444447eeeeeeeeeeee444444eec33333333333333ce557666541146d55ee5606060606065ee1ccc100000c1eee33355533
4eeee9eeeeeee4e4cccccccceeee4449e7eeeeeeeeeeeeee444447ee3333333333333333e5766666414666d5e55600660600665ee1c1c000044c1eee55553333
4e5559555555e4eecccccccceee144498888eeeeeeeeeee14444988e3333333333333333e5766566646556d5e56606060606665ee1c1c44fffc11eee33333333
45000900000554eecc66ccccee41144497e8eeeeeeee444114449e8ec33333333333333c55765666666656d5e56666666666665eee11ccfffccc1eee33388333
45000900000504eec65555cce441144444eeeeeeeee54441144497eec33333333333333c57665666666656d5e56666666666665eeee111111ccc1eee33882283
55555555555555eec55555cce4451114447eeeeeeee45e111114447ecc333333333333cc57665565555655d5e56655665555665eee14f1c111cc11ee33382283
5dd5ddd5dd5dd5eec5555dcce454111144447eeeeeeeee1111114447cc333333333333cc576655665e566555e56655556655665eee14f1cc0114f1ee33338833
56656665665665eecc55dcccee1111111ee4eeeeeeeeee1111111ee4ccc3333333333ccc556555665e56665ee56666666666665eee111ccc0114f1ee3b353333
e555555555555eeecccccccce441111144eeeeeeeeeee441111144eeccccc333333ccccce55556665e55555ee56666666666665eeee11cccc1111eee3bb5bb33
eeeeeeeeeeeeeeeecccccccce454eeee454eeeeeeeeee454eeee454eccccccc33ccccccceeee55555eeeeeeee55555555555555eeeeee1111eeeeeee3b5bb333
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555eeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000eeeeeeeeeeeeee00ceeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6e6665eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0111111110110ee00eeeeeee000000eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeee6966665eeeee555e555e555e555555e555ee011111111011100e0eeeeeeeee00c07eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee78787eeee6765555eeeee5655565556555655655565e011111111101005ee00eeee00000000eeeeeee6eeeeeeeee
eeeee777eeeeeeeeeeee777eeeeeeeeeeeee075700eeee6e5665e555e5666666666666666666665e000000000000445eee00000000000007eeeeee6eeebbceee
eeee7c7ceeee611eeee7c7ceeee611eeeee0007000ee005e56655565e5555555555555555555555ee54444444454445eeee0000000005500eebbe666ebc0beee
eeee7777eee6eee1eee7777eeee6ee1eee0000000000076e55556666e5dddd5ddd5dddddd5dddd5ee50044400454555eeee500000e00055eebcbce4eeebbeeee
eeeee77ee4644441eeee77ee4446441ee00000000000005e65655555ee55665666566666656655eee50055500555005eee55000eeee000eeebb0be4ebbbbb6ee
ee7776674446111ee777667444e611eee00000000000005eeeeeeeeeeee555555555555555555eeee55555555550005eeeeeeeeeeee0ee0eeebbee4eb444b666
e7e7e66e447eeeee7e7e66e447eeeeee0000000000000e5eeeeeeeeeeeee57665665666566d5eeeee54400004450005e0eeeeeeeeee0000ebbbbbbbeeebbe6ee
e7ee777744eeeeee7ee777744eeeeeee070000000000ee5eeeeeeeeeeeee57665665666566d5eeeee54044440450055e0ee0000000e0000ebebbee4eee1111ee
7ee7e66e7eeeeeee7e7e66e7eeeeeeee060000000000ee5eeeeeeeeeeeee5555555555555555eeeee55044440555555e0e0000000000c0ceeebbeeeee11eebee
eeee7777eeeeeeeeeee7777eeeeeeeeeee0000000000ee5ee555e555eeee57666656656666d5eeeee55004440555545e000000000000000eee111eeeebeeeeee
eee7eeee7eeeeeeeee7eeee7eeeeeeeeee0000000000eeee55655565eeee57666656656666d5eeeee54044440454445ee00005e00000707ee11e1eeeeeeeeeee
eee7eeee7eeeeeeeee7eeee7eeeeeeeee000000000000eee66666666eeee5555555555555555eeeee54044440454455eeee000eee0055eeeebeebeeeeeeeeeee
eee77eee77eeeeeeee77eee77eeeeeeee000000000000eee55555555eeee57666566566666d5eeeee550444405555eeeeee5000ee00055eeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeee9aa9ee7eee7ee33333333eee55555eeee57666566566666d5eeeeba3ee33bbba3eeeeed1111eeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee56555555569889a7d767d7e33333333eeee5666eeee5555555555555555eeeebbbbbbbbbbbbbbeeeee11111eeeeeeeeed11111eeeeeeeee
eeeee777eeeeeeeeee7ee777ee7a97a9e7d6d7ee3333aa33eeee5666eeee57666656665666d5eeeebbbb3abbbbbbba3eeeee11111eeeeeeeeeee11111eeeeeee
eeee78787eeeeeeeee0078787009aa9ee66766ee3333a9a3eeee5555eeee57666656665666d5eeeebbbbbbbbba3bbbbeeeeeddddddeeeeeeeeeeddddddeeeeee
eeee075700eeee6eee0007570000eeeee7d6d7ee33335aa3e5555665eeee5555555555555555eeeeba3bbbbbbbbbbbbeeee6bbcbcb6eeeeeeee6bbcbcb6eeeee
eee0007000eee696ee0000700000eeee7d767d7e33b3533355655665eeee57566666566666d5eeeebbbbb4abbbbbba3eeee6bb666b6eeeeeeee6bb666b6eeeee
ee000000000ee676ee0000000000eeeee7eee7ee333b5b3366665555eeee57566666566666d5eeee555555555bbbbb5eeeee666066eeeeeeeeee66609a7ee9a7
e00000000000ee6eeee00000000eeeeeeeeeeeee3333533355555666eeee5555555555555555eeeeeeeeeeeee55555eeeee111bbb11eeeeeeee1111ba711ba7e
e000000000000e5eeee00000000eeeeeeeeeeeeeeeeeeeeeeeebbbbbb3ab33bbccccccccccc33333cccccccc33333cccee1111111111eeeeeee1111ba711ba7e
000000000000076eeee00000000eeeeeeeeeeeeeeeeeeeeeeeabbbbabbbbbbbaccccccccccccc333cccccccc333ccccce111111cc1111eeeeee1111c9a71e9a7
070000000000005eeee00000000eeeeeeeee077700eeeeeeeeb3bbbbbbbbbbbbcccccccccccccc33cccccccc33ccccccb11e11c111e11beeeeee11c111eeeeee
060000000000005eee000000000eeeeeee0070707000e66eeebbabbbba3bbbbbccccccc3ccccccc33ccccccc3cccccccbbe11cccc11ebbeeeee11cccc11eeeee
ee0000000000ee5eee0000000000eeeee0000757005567c6ebbb3bbbbbbbb3abccccccc3ccccccc33ccccccc3ccccccceee1111c111eeeeeee11111c111eeeee
ee0000000000ee5eee0000000000eeee055555755500066ee5bbbb4bbba3bbbbcccccc33cccccccc33ccccccccccccccee111cc11111eeeee1111cc1111eeeee
e000000000000e5ee000000000000eee00000000000000eeee55555555bbb555ccccc333cccccccc333cccccccccccccee1111111111eeeee111111111eeeeee
e000000000000e5ee000000000000eee000000000000000eeeeeeeeee55555eeccc33333cccccccc33333ccccccccccceeee555e555eeeeeeeee555e555eeeee
__gff__
0100010000000000000001010100000000000000000000000001010101010000010101010101000000000101010100000101010101010000000001000000000000000000000000000000000000000000010001000100010001000100010001000101010101010101000000000000000001010101010101010000000001000000
0000000000000000000101010101010001000080800000000001010101010100010100000000000000010101010000000101000100010000000101010100000000000000000001010101010100000000010001000100010101010101000000000000000001000101010101010000000001000100010001010101010101000100
__map__
c7c8c93f3f3f3f3f3f0a0b222320213f2223fb3a3a3a3a3a3a3a3a3a3a3a3a3af93f828282828282828282828220213f3f3f2c2c2c2c2c2c2c2c2021c7c9c7c9fb3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3ac7c8c900c7c8c93a3a3af9
d72dd93f3f22233f3f1a1b32333031e532333a3a3a3aa73fe5e5e53f3f3f3fa83ab7828282828282828282828230313f3f3f2cabacabacabac2c3031d7c6e6d93a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3ad7d8c6d6e6d8d93a3a3a3a
3f3f3f3f3f32333fe52a2b3f3f3f0303043636373a37360303040403033f3f3fa83af9828282cacb2223cacb82828222233f2cbbbcbbbcbbbc2c3f3fe70202e93a3aa7b8f83f3f3fcacb3f3f3f3f3f3f3fa83aa722233f3f3f3f3f20213fcacb20213f3fa83a3a3a3a3a3a3a3a3a3aa73f3f3f3f3fe7e8e81de8e8e93fa83a3a
2c3f3f3f3f3f3f20213f3f3f3f3f03030436363a3a3a360303040403033fc7c8c93a3acacb3fdadb3233dadb82828232333f2c0303030303032c3f20213f3fbf3a3ab8a73f2023bfdadbbfa0a1cacb3f3fb8a7bf32333f2021bfbf3031bfdadb30313f3f3f3a3a3a3a3a3a3a3a3a3a3f3f3f3fabace7e8e82de8e8e93f3f3a3a
3f3f3f3f3f3f3f30313f3f3f202304043fe53a3a3a3ab73f3f3f3f04043fd7d8d93a3adadb030404a0a10404828292823f3f2cabacabacabac2c3f30313f3fbf3a3aa73f3f32313f3f3f3fb0b1dadbbfb8a73f3fbfbfbf30313f3f3f3f3f3f3f3f3f3f3c3627363736273627363736263e3f82bbbc82828282829282823f3a3a
22213f3f2223e5e5e520213f303304043f3f3a3a3a3a3a3a3a3af904043fe702e93a3a3f03030404b0b104043f3f828222232cbbbcbbbcbbbc2c3f3f3f3f3fbf3a3a3f2223bf3f3f040403030404363637363f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3b3626362636373626362636273d3f82828282af8282828282823f3a3a
30313f3f32333f3fe5303122233f030322233a3a3a3a3a3a3a3a3a030304043f3f3a3acacb3f0303040403030404828232332c0303030303032c3f3f3f3f3fbf3a3a3f32333f0303040403030404363637363f3f3f3f3f3f3f3f3ff6f7eaeaf7eb3f3f3c3e3a3a3a3a3a3a3a3a3a3a3c3e3fabac8282828282828282af3f3a3a
3f3f3f3f3f3f3f3f3f3f3f32333f030332333a3aa70a0b3fa83a3a030304043f3f3a3adadb3f03030404030304048282823f2c0303030303032c3f3f3f3f3fbf3a3a3fbf3f3f03033f3f3f3f3f3f3f3ab73f3f3f3f3f3f20213f3fbfbfbfbfbfbf3f3f3b3d3a3a3a3a3a3a3a3a3a3a3b3d3fbbbc82828282828282abac3f3a3a
222304040303040403030404030304043f3f3a3a3f0c1ce53f3a3ab73f36273fb83a3a3f030304043f3f3f3f030382823f3f2c3f3f3f3f3f3f2c3f3f3f3f3fbf3a3abfbf3f3f04043fcacb3fcacb3f3a3a3a3a3a3a3af930313f3f3f3fbfbf2021bf3f3c3627363736273627363736263e3f828282abac82829282bbbc3f3a3a
323336260303040403030404030336362cb83a3a3f3f3f3f3f3a3a3a3a36373a3a3a3acacb030404cacb3f3f03038282823f2c2c3f3f2c2c2c2c3f3f3f3f3f3f3a3abf3f3f3f0404bfdadbbfdadbbf3a3aa7c7c8c9a83a22233f3f3f3f3fbf3031bf3f3b3626362636373626362636273d3f829282bbbc8282828282823f3a3a
fb3a36373a3a3a3a3a3a3a3a3a3a36363a3a3af83f3f3f3f3ffa3a3a3a36263a3a3a3adadb040303dadb3f3f04048282823f3f3f040422233f3f3f3f3f3f3f3f3a3abf3f3f3f03033f3f3f3f3f3f3f3a3abfd7d8d9e53a32333f3f3f3f3f3fbfbf3f3f3c3e3a3a3a3a3a3a3a3a3a3a3c3e3f8282828282828282af82823f3a3a
3a3a36263a3a3a3aa73f3f3f3f3f3636040303040403030424250304043627e5a83a3ab70404030322233f3f040482828222233f040432333f3f3f3f3f3f3f3f3a3a3f3f3f3f03033f3f3f3f3f3f3f3a3abfe702e9e53a3fbfbf3f3f3f3f3f3f3f3f3f3b3d3a3a3a3a3a3a3a3a3a3a3b3d3f82af8282828282828282823f3a3a
3a3a36373a3a3aa73f3f3f3f3f3f0404040303040403030434350304040303e5b83a3a3af93fcacb3233f6eb0303f6f7eb32333f03030404030304040303042736373604030304043ffb3af93f3f3ffaf83f3f3fbfe53a3f3fbfbf3f3f3f3f3f3f3f3f3c3627363736273627363736263e3f8282828282928282abac823f3a3a
3a3a36273a3af83f3f3f20213f3f20212223e5e53f2223e52021e52223e5e5fb3a3a3a3a3ab7dadbe5e5e5e50303e5e5e5e53f3f03030404030304040303042636263604030304043f3a3a3a3f3f3f3f3f3f3fbfbfe53a3f3f22233f3f3f3f3f3f3f3f3b3626362636373626362636273d3fabac8282abac82afbbbc823f3a3a
3aa727362021e53f3f3f30313f3f303132332021e53033e53031e53233e5e5fa3a3a3a3a3a3a3a3a3af93f3f040403030404030304043ffb3a3a3a3a3af93f3f3a3ab73f3f3f3f3fb83a3a3ab73f3f3f3f3fbfe5e5b83a3f3f30313f3f3f3f2223bf3f3f3f3a3a3a3a3a3a3a3a3a3a3f3f3fbbbc8282bbbc82828282823f3a3a
3a3f04043031e5e53f3f3f3f3f3f3f3f3f3f3031e5e53f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3fa83a3a3f3f040403030404030304043f3a3a3a3a3a3a3ab7b83a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3af83f3f20213f3f3fbf3233bf3f3fb83a3a3a3a3a3a3a3a3a3ab73f3f3f3f3f3f3f3f3f3f3f3f3fb83a3a
3a3f0404222322233f3f3f3f3f3f3f3f3f3f3fe5e53f3f04040303040403030404030304043f3f3fa83ab73f36363f3f3f3f3f3f3f3fb83a3a3a3a3a3a3a3a3a3a3aa73f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f22233f3f3f30313f3f2223bffb3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a
3a3f0404323332333f3f3f3f3f3f3f3f3f3f3fe5e53f3f04040303040403030404030304043f20213ffa3a3a36363a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3af83f2c3f04040303040403030404030304043f32333f3f3fbf3f3f3f32333f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a
3a3f0303043fe520233f0a0b3f0a0b3f0a0be5e520213f0303fb3a3a3a3a3a3a3a3af903033f30313f3f3f3f36363f3f3f3f24252c3f3f3f3f2425a83aa7a83aa73f24253f04040303040403030404030304043f22233f3f22233f3f3f3fcacb3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a
3a3f3f0304043f3033e51a1b3f1a1b3f1a1b202130313f03033a3a3a3a3a3a3a3a3a3a03033f3f3f3f3f3f3f03033f3f3f3f34353f3f3f0a0b34352c3ab7b8f83f3f34353f0303fb3a3a3a3a3a3a3a3af903033f3033abac32333f3f3f3fdadbfa3a3af9a83a3a3a3aa73f3fa83a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a
3a3f3f3f0303043f3f2c2a2b3f2a2b3f2a2b3033e53f3f04043a3a3a3a3a3a3a3a3a3a04040303040403030404043f3f3f24253f3f3f3f0c1c2c3f3f3a3aa73f3f3f24253f03033a3a3a3a3a3a3a3a3a3a03033f3fbfbbbcbf20213f3f3fbfbf2021a83abf3a3a3a3ac7c8c8c93a3a3aa722233f3f3f3f3fc7c8c9a83a3a3a3a
3a3f24253f0304043f3f3f3f3f3fa0a13f3fe522233f3f04043a3a3a3a3a3a3a3a3a3a040403030404030304043f3f3f3f34352c3f3f24253f3f3f3ffaf83f3f3f3f34353f04043a3a3a3a3a3a3a3a3a3a04043f3f2021bfbf30313f3f3fcacb3031bf3ab73a3a3a3ad7d891d93a3a3a3f30313f3f22233fd7d8d93f3a3a3a3a
3a2c34353f3f0303043f3f3f3f3fb0b13f3f3f32333f3f3c3627363736273627363736263e3f3f3f3f3f3f3f3f3f3f242524253f3f3f34352c3f3f3f3f3f3f3f24252c3f3f04043a3a3a3a3a3a3a3a3a3a04043f3f30313fbfbf3f3f3f3fdadb3f3f3ffa3a3a3a3a3a3f3f3f3fa2b2a23f3f20213f32333fe71de93ffa3a3a3a
3a0a0b3f3f3f3f0304043f3f3f3f3f3f3f3f3f3f2c3f3f3b3626362636373626362636273d3f3f3f3f3f3f24253f2c343534353f3f3f3f3f3f3f3f3f3f3f3f3f34353f3f3f36362736373627362736373626363f3f3f3f3f3f3f3f3f3f3fa0a13f3fcacba83a3a3a3a3f3f3f3fb2a2a23f3f30313f3f3f3fe72de92021a83a3a
3a1a1b24253f3f3f03030404030304040303040403033f3c3e3a3a3a3a3a3a3a3a3a3a3c3e3f3f3f3f3f3f3435242524252c3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f36362636263637362636263627363f3f3f3f3f3f3f3f3f3f3fb0b13f3fdadbbf3a3a3a3ab73f3fb83a3a3a3f3f3f3f3f3f3f3f3f3f3f32313f3a3a
3a2a2b34352c3f3f3f030404030304040303040403033f3b3dfa3a3a3a3a3a3a3a3af83b3d3f3f3f2425c7c93f343534353f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f04042021222320232023222104043f20233f3f3f3f3f3f3fcacb3f3f3f3f3f3f3a3a3a3a3a3a3a3a3a3a3a3f3f3f3f3f3f3f3f3f3f3f3f22213a3a
3a3f3f3f3f3f3f3f3f3f0a0b3f3f3f0a0b3f20212c3f3f3c3e202120232021222320213c3e3f3f3f3435d7d9242524253f3f3f3f3f3f3f24253f3fa0a13f3f3f3f3f3f3f3f04043233303132313031303304043f323320233f3f3f3fbfdadb3f3f3f3fcacb3a3a3a3a3a3a3a3a3a3a3a3f3f3f3f3f3f3f3f3f3f3f3f32313a3a
3a3f3f3f3f3f3f3f3f3f1a1b3f3f3f1a1b3f30313f3f3f3b3d303132333031323330333b3d3f3f3f3f3fe7e9343534353f3f2c3f3f3f2c34353f3fb0b13f3f3f0a0b2c3f3f03030404030304040303040403033f3f3f32333f3f3f3fbfbfbfbfbfbfbfdadbfa3a3a3a3a3a3a3a3a3af83f3f3f3f3f3f3f3f3f3f3f2021e53a3a
3a3f24253f3f3f3f3f3f2a2b3f3f3f2a2b3fe5e53f3f3f3c3839382838393829382838283e3f3f3f2425e7e93f3f3f3f3f3f3f3f3f3f24250a0b3f3f3f3f3f3f0c1c24253f03030404030304040303040403033f3f3f3fcacb3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f20213f3031b83a3a
3ab734352c3f3fe5b83a3a3a3a3a3a3a3a3a3af920213f3c3829383938293829382838293e3f3fbf3435e7e93f3f3f3f3f3f3f3f3f3f34350c1c3f0a0b3f3f3f242534353f20232021222322232223202122233f3f3f3fdadbbf3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f22213f22233031e53fb83a3a3a
3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a30313f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f24253f24253f24253f3f24253f3f3f24253f24252c0c1c3f0a0b34353f3f3f30333033303332333231323132333f22213f3fbff6eaf7f7eaeaeaf7eaeb3f222122233f3f3f3f222122233f202132313f3231fb3a3a3a3a3a3a3a
fa3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3af8e53ff6f7eaeaf7f7eaf7eaf7f7eaf7f7eaeb34353f34352c34352c3f34352c2c2c34353f34353f3f3f3f0c1c3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f32333f3f3f3f3f3f3f3f3f3f3f3f3f3f323332333f3f3f3f303332313f30313fe53f3f3ffa3a3a3a3a3a3af8
__sfx__
010700000b63418633106232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f015300152d01528015300152d01529015280152d0152b0152d015290152d015280152b0152d0152f015300152d015340152f015320152d015300152b0152d015280152901526015280152401526015
011000002301524015210151c01524015210151d0151c0151f0151c015210151d015230151c0151f0152301524012240122401224015210051d00523005210052400523005260052400528005260052b00528005
0110000a0062604626056260062602626006260562602626046260062605626036260062605626036260062605626076260062601626056260562602626006260462605626026260062605626076260462604626
01030000296102b6120c6120001200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000029230282302923026230290002323000000000001f230000001c2201a2201722014220142200010000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000186340c633137530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002473000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00003462630621306213061124611246112461200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c22609702000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000305503055
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000000000000000c7630c763000000000015623000000c7630c7630c763000000c7630000015623156230000000000
011000001f7301f7321f7220000000000000001d7301d7321f7301f7321f72200000000000000018730187321f7301f73220730207321f7301f7321d7301d7321f7301f7321f7220000000000000001a70000000
011000001b7301b7321b72200000000000000018730187321b7301b7321b72200000000000000018730187321b7301b7321d7301d7321f7301f7321d7301d7321873018732187220000000000000000000000000
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000000000000000c7630c763000000000015623000000c7630c7630c763000000c7630000015623156231562315623
011000002473030730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000305000000030550305503050000000305503055030500000003055030550305000000030550305503050000000305503055030500000003055030550305000055020550305505055030550205503055
011000000005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000005500055000500000000055000550005002055030550505507055050550205505055
011000000505000000050550505505050000000505505055050500000005055050550505000000050550505505050000000505505055050500000005055050550405000000040550405502050000000405504055
011000000005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000005500055000500000000055000420b03109031070310503104031020310003100031
01100000187551b7551d7551f7551d7551f75520755227551b7551d7551f755227551f7552275524755267551d755207552475526755227552675527755297552b7552e7552e7412b74230740307322475118751
011000000c055000000c0550c0550f0550c05500000000000c055000000c0550c0550f0550c05500000000000c055000000c0550c0550f0550c05500000000000b055000000b0550b055090550b0550000000000
01100000110550000011055110551405511055000000000011055000001105511055140551105500000000001105500000110551105514055110550000000000100550000010055100550e055100550000000000
011000000c055000000c0550c0550a0550c05500000000000f055000000f0550f0550e0550f0550000000000110550000011055110550f0551105500000000001205500000120551205513055130550000000000
011000000005000000000550005500050000000005500055030500000003055030550205000000030550305505050000000505505055030500000005055050550605000000060550605507050000000705507055
01100000050500570505055050550505000000050550505505050000000505505055050500000005055050550505000000050550505505050000000505505055070500000008055080550a050000000a0550a055
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156231560300000000000c7630c763000000000015623000000c7630c7630c763000000c76315603156230c7631562315623
01100000000500000000055000550005000000000550005503050000000305503055020500000003055030550505000000050550505503050000000505505055070500000007055070550c050000000c0550c055
011000000c055000000c0550c0550a0550c05500000000000f055000000f0550f0550e0550f0550000000000110550000011055110550f0551105500000000001305500000130551305518045180450000000000
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000000000000000c7630c763000000000015623000000c7630c7631874317743157431374315623156231562315623
011000000505005705050550505505050000000505505055050500000005055050550505000000050550505505050000000505505055050500000005055050550c055097050c0550c0550a050000000a0550a055
011000000c7630c763000000000015623000000c7630c7630c763000000c763000000c7531560315623156230c713000000000000000000000000000000000000000000000000000000000000000000000000000
01100000110550000011055110550f055110550000000000130550000013055130551804518045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000505000000050550505503050000000505505055070500000007055070550c0500c0520c0520c0520c0420c0320c0220c012000000000000000000000000000000000000000000000000000000000000
011000000c763000000c7630000015623000000c763000000c763000000c763000001562300000000000000000000000000c7630000015623000000c763000000c7630c763000000000015623000000000000000
0143000000000000000000000000000000000000000000001f0121c0121c0121f01218012180121a0121c0121d0121f012210121a0121a0121a0121801217012180121a0121c0121801218012180120000000000
01100000110550000011055110550f0551105500000000000f055000000f0550f0550c0450c045000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000505000000050550505503050000000305503055030500000003055030550005000052000520005200042000320002200012000000000000000000000000000000000000000000000000000000000000
011000000c7630c76324515000001562300000245150c7630c763000002451500000156230000024515000000c7630c76324515000001562300000245150c7630c7631874324515177431562315743137430c753
011000000c7430c703245050000015615000000c7030c7430c743000002450526500245150000000000000000c7430c73324505000001561500000245050c7330c74300000245050000015615156152450515605
011000000505000000050550505505050000000505505055030500000003055030550305000000030550305502050000000205502055020500000002055020550005000000000550005500050000000005500055
011000000505000000050550505505050000000505505055030500000003055030550305000000030550305507050000000705507055070500000007055070550005000000000550005500050000000005500055
011000000c055000000e025000000f0250000011025000000f0250000011025000000e025000000f025000000e025000000f02511005110250000013025000000c025000000c025000000a025000000c02500000
011000000015500000000000000000000000000000000000071550000000000000000000000000000000000000155000000000000000000000510505155000000715500000000000000000000000000000000000
01100000001550010500105000000000000000051550000007155000000710500000071050000005155000000015500000000000000000000051050515500000071550000000000000000c1550c1050c10500000
01100000001550c10505105001050710500000051550c105071550c1050715505155071550a1550c155000000c155000000a105000000c10500000051550000007155000000c1550a15507155051550015502105
01100000031550c10507105001050a10500000021550c105031550c1050315505155071550515503155000000515500000071050000008105000000a1550000007155000000c1550a15507155051550015502105
011000000c7430c743245050000015615000000c7430c7430c74300000245050c743156150000000000000000c7430c7332450500000156150c7430c7430c7330c74300000245050c74315615156152451515605
0110000003155031550010500000000000000008155000000a1550000007105000000710500000081550000003155000000000000000000000510508155000000a15500000000000000002130021320213202122
0110000003155031050000000000000000000000000000000a1550000000000000000000000000081550000003155000000000000000000000710508155000000a15500000000000000000000000000000000000
011000001b75500000000000000000000000001b75500000000000000000000000001b7550000000000000001d7550000000000000000f7050000022755000000f7050000000000000001f7551f7020000000000
011000001875500000000000000000000000001f755000000000000000000000000024755000000000000000187550000000000000000f7050000024755000000f70500000000000000022755157050000000000
011000000c7430c743245050000015615000000c7430c7430c74300000245050c743156150000000000000000c7430c7332450500000156150c7430c7430c7330c74300000156150c74315615156152451515615
011000001f7301f7351f7321f7322173521735217352173524730247322473224732247322473224722187210c711007110000000000000000000000000000000000000000000000000000000000000000000000
011000000605008051080550805008045080550704100031060500805108055080500804508055070410003100000060500805108050080450805507041000310805007051070550705007045070550704000031
01100000080500a0510a0550a0500a0550a0550804100031080500a0510a0550a0500a0550a055080410003100000080500b0510b0500b0550b05508041000310805007051070550705007055070550704000031
011000000015500000000000000000000000000000000000071550000000000000000000000000000000000005155000000000000000000000510505105000000015500000000000000000000000000000000000
011000000315500000000000000000000000000000000000001550000000000000000000000000000000000005155041050410504105041050410506155000000715500000000000000000000000000000000000
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000015613156231562315623156230000000000000000c7630c7630c763000000c76300000156230c7631562315623
011000200c7630c763000000000015623000000c7630c7630c763000000c76300000156230000015613156230c7631562315623156230c7630c76315623156231876318763177631776315763157631376313763
01100000061302c700081302a70000000277000813000000061302770008130257002470023700031000000006100000000313000000011300000003130000000813007121071110000000000000000000000000
0110000008130000000a1300000008100000000a1300000008130000000a1300000000000000000a100000000a100000000b1320b1220b100000000b130000000813007121071110000000000000000000000000
011000000015500000001550000000000000000015500000071550000007155000000000000000071550000005155000000515500000000000510505155000000015500000001550000000000000000015500000
011000000315500000031550000000000000000315500000001550000000155000000000000000001550000005155000000515500000000000510506155000000715500000071550000000000000000515500000
__music__
01 01 42 43 44
04 02 42 43 44
01 0b 42 11 44
00 0b 42 10 44
00 0b 42 11 44
00 0b 42 10 44
00 0b 0c 11 44
00 0b 0d 10 44
00 0b 0c 11 44
02 0e 0d 10 44
01 0e 15 0a 44
00 0e 15 13 44
00 1a 16 12 44
00 1a 16 12 44
00 0e 17 18 44
00 1a 17 18 44
00 0b 15 0a 44
00 0b 15 0a 44
00 1a 16 19 44
00 1a 16 1e 44
00 0e 17 18 44
02 1d 1c 1b 44
04 1f 20 21 44
04 1f 24 25 44
01 0b 0a 43 44
00 1a 0a 43 44
00 0b 0a 43 44
00 0e 0a 43 44
00 0b 0a 2a 44
00 0b 0a 2a 44
00 0b 28 2a 44
00 0e 29 2a 44
00 0b 0a 2a 44
00 0b 0a 2a 44
00 26 28 2a 44
02 26 29 2a 44
01 27 2b 43 44
00 27 31 43 44
00 2f 2c 43 44
00 2f 30 43 44
00 2f 2d 33 44
00 2f 2e 32 44
00 2f 2d 33 44
02 34 2e 32 44
01 0e 36 43 44
00 0e 36 43 44
00 1a 37 43 44
01 0e 36 3c 44
00 0e 36 3c 44
00 3a 37 3d 44
00 22 42 3c 44
00 22 42 3c 44
00 22 42 3d 44
00 0e 36 3c 44
00 0e 36 3c 44
02 3b 37 3d 44
01 27 38 43 44
00 27 39 43 44
00 2f 3e 43 44
00 2f 3f 43 44
00 2f 3e 33 44
00 2f 3f 32 44
00 2f 3e 33 44
02 2f 3f 32 44
