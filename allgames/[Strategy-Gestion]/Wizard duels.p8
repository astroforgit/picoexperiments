pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--wizard duels
--by @dollarone
--for the 4th alakajam



--print string with outline.
function printo(str,startx,starty,col,col_bg)
	print(str,startx+1,starty,col_bg)
	print(str,startx-1,starty,col_bg)
	print(str,startx,starty+1,col_bg)
	print(str,startx,starty-1,col_bg)
	print(str,startx+1,starty-1,col_bg)
	print(str,startx-1,starty-1,col_bg)
	print(str,startx-1,starty+1,col_bg)
	print(str,startx+1,starty+1,col_bg)
	print(str,startx,starty,col)
end

--print string centered with 
--outline.
function printc(
	str,x,y,
	col,col_bg,
	special_chars)

	local len=(#str*4)+(special_chars*3)
	local startx=x-(len/2)
	local starty=y-2
	printo(str,startx,starty,col,col_bg)
end

function change_speed() 
	gamespeed-=1
	if gamespeed==0 then
		gamespeed=9
	end
end


function _init()
	menuitem(1, "change gamespeed", change_speed)
	info=false
	gamespeed=4
	can_see_enemy_crystals=true
	cards= {}
	cards[1] = "goblin_spearman"
	cards[2] = "goblin_archer"
	cards[3] = "skeleton"
	cards[4] = "ogre"

	restart()
	intro_init()
end

function restart()
	time=0
	ticks=-20

	show_cards_timeout=-20
	card_selected=1


	crystals_player=0
	crystals_enemy=0

	palt(14,true)
	palt(0,false)

	init_lanes()
	wizard_player = spawn("wizard", 0, false)
	wizard_enemy = spawn("wizard", 0, true)
	
	friends = {}
	enemies = {}

	top_crystal = 0
	bot_crystal = 0

	top_crystal_sprite=27
	bot_crystal_sprite=27

	attack_timeout = 30
	cooldown=0
	turns=1
	friend_death = {}
	enemy_death = {}

	errors = {}
	errors["spawn_occupied"] = "   can't spawn - \n lane is occupied"
	errors["not_enough_crystals"] = "   can't spawn -\nnot enough crystals!"
	errormsg=""
	error_countdown=0
	gameover=false
end

function spawn(name, lane, unfriendly)
	unit = {}
	unit.special = nil
	unit.lane=lane
	unit.maxhp = 1
	unit.attack = 1
	unit.cost = 1
	unit.pos=1

	if (name == "ogre") then
		unit.maxhp = 3
		unit.attack = 3
		unit.cost=3
		unit.spr=76
		unit.snd=6
	elseif (name == "goblin_spearman") then
		unit.maxhp = 2
		unit.spr=64
		unit.snd=0
	elseif (name == "goblin_archer") then
		unit.special = "ranged"
		unit.cost=2
		unit.spr=68
		unit.snd=4
	elseif (name == "skeleton") then
		unit.attack = 2
		unit.spr=72
		unit.snd=7
	elseif (name == "wizard") then
		unit.maxhp = 10
		unit.attack = 3
		unit.cost=10
		unit.lane=0
		unit.pos=0
		unit.spr=108
		unit.snd=5
	end
	if unfriendly then
		if lane==2 then
			unit.pos = 5
		else
			unit.pos = 11
		end
	end
	unit.hp=unit.maxhp
	unit.spr_attack=unit.spr+2
	unit.attacking = 0
	unit.rip=0
	unit.acted=false
	unit.spr_normal=unit.spr
	unit.burning = false
	return unit

end

function _update60()
	ticks+=1
	if ticks%60==0 and time<5 then
		time+=1
	end
	if (intro) then
		intro_update() 
		return
	end

	if gameover then
		if btnp(4) or btnp(5) then
			restart()
		end
		return
	end

	turn=false
	if (ticks%(60*gamespeed)==0) then
		turn=true
	end

	if (ticks%(60*gamespeed)==(30*gamespeed)) then
		sfx(-1,3)
		for i=1,#friends do
			if friends[i].hp < 1 then
				add(friend_death, friends[i])
				friends[i].burning=false
				friends[i].spr = 171
				lanes[friends[i].lane][friends[i].pos]["occupied"] = false
			else
				friends[i].spr = friends[i].spr_normal
			end
		end
		for e=1,#enemies do
			if enemies[e].hp < 1 then
				add(enemy_death, enemies[e])
				enemies[e].burning=false
				enemies[e].spr = 171
				lanes[enemies[e].lane][enemies[e].pos]["occupied"] = false
			else
				enemies[e].spr = enemies[e].spr_normal
			end
		end

		if wizard_player.hp < 1 then
			gameover=true
			result="lose"
			ticks=-20
		end

		if wizard_enemy.hp < 1 then
			gameover=true
			result="win"
			ticks=-20
		end
		if wizard_player.hp < 1 and wizard_enemy.hp < 1 then
			result="draw"
		end

	end

	if cooldown>0 then
		cooldown-=1
	end

	if btnp(4) then
	end

	if turn then
		turns+=1
		if top_crystal==1 then
			top_crystal_sprite=42
		elseif top_crystal==2 then
			top_crystal_sprite=26
		end
		if bot_crystal==1 then
			bot_crystal_sprite=42
		elseif bot_crystal==2 then
			bot_crystal_sprite=26
		end

		if (turns%2==0) then
			crystals_player+=1
			crystals_enemy+=1
		end
		if turns%5==0 then
			if (top_crystal==1) then
				crystals_player+=1
				top_crystal_sprite=12
			end
			if (top_crystal==2) then
				crystals_enemy+=1 
				top_crystal_sprite=10
			end
			if (bot_crystal==1) then
				crystals_player+=1
				bot_crystal_sprite=12
			end
			if (bot_crystal==2) then
				crystals_enemy+=1
				bot_crystal_sprite=10
			end

		end
		-- cleanup
		for w=1,#enemy_death do
--			lanes[enemies[e].lane][enemies[e].pos]["occupied"] = false
			del(enemies,enemy_death[w])
		end
		enemy_death={}
		for w=1,#friend_death do
--			lanes[friends[i].lane][friends[i].pos]["occupied"] = false
			del(friends,friend_death[w])
		end
		friend_death={}

		for i=1,#friends do
			friends[i].spr = friends[i].spr_normal
			friends[i].acted=false
		end
		for e=1,#enemies do
			enemies[e].spr = enemies[e].spr_normal
			enemies[e].acted=false
		end
		wizard_enemy.spr = wizard_enemy.spr_normal
		wizard_enemy.acted=false
		wizard_player.spr = wizard_player.spr_normal
		wizard_player.acted=false

		-- update crystals
		top_pos5=0
		top_pos6=0
		top_pos7=0

		for i=1,#friends do
			if(friends[i].lane==1) then
				if(friends[i].pos==5) then
					top_pos5=1
				elseif(friends[i].pos==6) then
					top_pos6=1
				end
			end
		end
		for e=1,#enemies do
			if(enemies[e].lane==1) then
				if(enemies[e].pos==7) then
					top_pos7=2
				elseif(enemies[e].pos==6) then
					top_pos6=2
				end
			end
		end

		if (top_pos6==1 and top_pos7==0) then
			if (top_crystal !=1) then
				sfx(15)
			end
			top_crystal=1
			top_crystal_sprite=42
		elseif (top_pos6==2 and top_pos5==0) then
			if (top_crystal !=2) then
				sfx(15)
			end
			top_crystal=2
			top_crystal_sprite=26
		end

		bot_pos5=0
		bot_pos6=0
		bot_pos7=0

		for i=1,#friends do
			if(friends[i].lane==3) then
				if(friends[i].pos==5) then
					bot_pos5=1
				elseif(friends[i].pos==6) then
					bot_pos6=1
				end
			end
		end
		for e=1,#enemies do
			if(enemies[e].lane==3) then
				if(enemies[e].pos==7) then
					bot_pos7=2
				elseif(enemies[e].pos==6) then
					bot_pos6=2
				end
			end
		end

		if (bot_pos6==1 and bot_pos7==0) then
			if (bot_crystal !=1) then
				sfx(15)
			end
			bot_crystal=1
			bot_crystal_sprite=42
		elseif (bot_pos6==2 and bot_pos5==0) then
			if (bot_crystal !=2) then
				sfx(15)
			end
			bot_crystal=2
			bot_crystal_sprite=26
		end


		-- attack -- add deaths and clean up later	
		for i=1,#friends do
			for e=1,#enemies do
				if(friends[i].lane == enemies[e].lane and friends[i].pos == enemies[e].pos-1) then
					friends[i].spr=friends[i].spr_attack
					friends[i].acted=true
					sfx(enemies[e].snd)
					enemies[e].hp -= friends[i].attack
				end
			end
		end

		for i=1,#friends do
			for e=1,#enemies do
				if(not friends[i].acted and friends[i].lane == enemies[e].lane and friends[i].special == "ranged") then
					if(friends[i].pos == enemies[e].pos-2) then
						friends[i].spr = friends[i].spr_attack
						friends[i].acted=true
						sfx(enemies[e].snd)
						enemies[e].hp -= friends[i].attack
					end
				end
			end
		end
		for i=1,#friends do
			last = 11
			if friends[i].lane==2 then
				last=5
			end
			if(not friends[i].acted and friends[i].pos==last) then
				friends[i].spr = friends[i].spr_attack
				friends[i].acted=true
				wizard_enemy.hp -= friends[i].attack
				if (not wizard_enemy.acted) then
					friends[i].hp -= wizard_enemy.attack
					friends[i].burning=true
					sfx(5,1)
					sfx(3,3)
					wizard_enemy.acted=true
					wizard_enemy.spr = wizard_enemy.spr_attack
				end
			end
		end


		-- attack -- add deaths and clean up later
		for e=1,#enemies do
			for i=1,#friends do
				if(friends[i].lane == enemies[e].lane and friends[i].pos == enemies[e].pos-1) then
					enemies[e].spr = enemies[e].spr_attack
					enemies[e].acted=true
					sfx(enemies[e].snd)
					friends[i].hp -= enemies[e].attack
				end
			end
		end

		for e=1,#enemies do
			for i=1,#friends do
				if(not enemies[e].acted and friends[i].lane == enemies[e].lane and friends[i].pos == enemies[e].pos-2) then
					if(enemies[e].special == "ranged") then
						enemies[e].spr = enemies[e].spr_attack
						sfx(enemies[e].snd)
						enemies[e].acted=true
						friends[i].hp -= enemies[e].attack
					end
				end
			end
		end

		for e=1,#enemies do
			if(not enemies[e].acted and enemies[e].pos==1) then
				enemies[e].spr = enemies[e].spr_attack
				enemies[e].acted=true
				wizard_player.hp -= enemies[e].attack
				if (not wizard_player.acted) then
					enemies[e].hp -= wizard_player.attack
					enemies[e].burning=true
					sfx(5,1)
					sfx(3,3)
					wizard_player.acted=true
					wizard_player.spr = wizard_player.spr_attack
				end
			end
		end

			-- move

		for i=1,#friends do
			move=not friends[i].acted
			if move then
				if lanes[friends[i].lane][friends[i].pos+1]["occupied"] == false then
					lanes[friends[i].lane][friends[i].pos+1]["occupied"] = true
					lanes[friends[i].lane][friends[i].pos]["occupied"] = false
					friends[i].pos+=1
					
				end
				if(friends[i].lane==2) then
					if(friends[i].pos > 5) then
						friends[i].pos = 5
					end
				else
					if(friends[i].pos > 11) then
						friends[i].pos = 11
					end
				end
			end
		end

		for e=1,#enemies do
			move=not enemies[e].acted
			if move then
				if lanes[enemies[e].lane][enemies[e].pos-1]["occupied"] == false then
					lanes[enemies[e].lane][enemies[e].pos-1]["occupied"] = true
					lanes[enemies[e].lane][enemies[e].pos]["occupied"] = false
					enemies[e].pos-=1
					
				end
				if(enemies[e].pos < 1) then
					enemies[e].pos = 1
				end
			end
		end
	end
	if btnp(1) or btnp(2) or btnp(3) then
		lane = 2
		if btnp(2) then
			lane = 1
		end
		if btnp(3) then
			lane=3
		end
		unittype = card_selected-- flr(rnd(4)) + 1

		if (unittype==2 and crystals_player <2) or (unittype==1 and crystals_player <1) or
			(unittype==3 and crystals_player <1) or (unittype==4 and crystals_player <3) then
			errormsg=errors["not_enough_crystals"]
			error_countdown=ticks+attack_timeout*3
			show_cards_timeout=ticks-1
		end
		if (lanes[lane][1]["occupied"]==false) then
			if unittype==2 and crystals_player>=2 then
				add(friends, spawn("goblin_archer", lane, false))
				crystals_player-=2
				lanes[lane][1]["occupied"]=true
				show_cards_timeout=ticks-1
			elseif unittype==1 and crystals_player>=1 then
				add(friends, spawn("goblin_spearman", lane, false))
				crystals_player-=1
				lanes[lane][1]["occupied"]=true
				show_cards_timeout=ticks-1
			elseif unittype==3 and crystals_player>=1 then
				crystals_player-=1
				add(friends, spawn("skeleton", lane, false))
				lanes[lane][1]["occupied"]=true
				show_cards_timeout=ticks-1
			elseif crystals_player>=3 then
				crystals_player-=3
				add(friends, spawn("ogre", lane, false))
				lanes[lane][1]["occupied"]=true
				show_cards_timeout=ticks-1
			end
		else
			errormsg=errors["spawn_occupied"]
			error_countdown=ticks+attack_timeout*3
			show_cards_timeout=ticks-1
		end
	end

	if flr(rnd(100)) == 1 then

		lane = flr(rnd(3)) + 1
		unittype = flr(rnd(4)) + 1
		last=11
		if lane==2 then
			last=5
		end
		if (lanes[lane][last]["occupied"]==false) then
			if unittype==2 and crystals_enemy>=2 then
				crystals_enemy-=2
				add(enemies, spawn("goblin_archer", lane, true))
				lanes[lane][last]["occupied"]=true
			elseif unittype==1 and crystals_enemy>=1 then
				crystals_enemy-=1
				add(enemies, spawn("goblin_spearman", lane, true))
				lanes[lane][last]["occupied"]=true
			elseif unittype==3 and crystals_enemy>=1 then
				crystals_enemy-=1
				add(enemies, spawn("skeleton", lane, true))
				lanes[lane][last]["occupied"]=true
			elseif crystals_enemy>=3 then
				crystals_enemy-=3
				add(enemies, spawn("ogre", lane, true))
				lanes[lane][last]["occupied"]=true
			end
		end
	end
	if btnp(0) then
		info = not info
	end
	if (btnp(4)) then
		card_selected-=1
		if card_selected<1 then
			card_selected = 4
		end

		show_cards_timeout=ticks+attack_timeout*6
	end
	if (btnp(5)) then
		card_selected+=1
		if card_selected>4 then
			card_selected=1
		end
		show_cards_timeout=ticks+attack_timeout*6
	end


end

function _draw()
	cls(0)
	if (intro) then
		intro_draw()
		return
	end
	map(0,0,0,0,16,16)
	
	spr(top_crystal_sprite,7*8+4, 0)
	spr(43,7*8+4, 8)
	spr(bot_crystal_sprite,7*8+4, 12*8)
	spr(43,7*8+4, 13*8)

	for i=1,#enemies do
		draw_unit(enemies[i], true)
	end	

	for i=1,#friends do
		draw_unit(friends[i], false)
	end	

	if(gameover) then
		offset = flr(ticks/4)
		--offset = min(15,offset)

		if (result=="lose" or result=="draw") then
		
			if (ticks%20<10) then
				wizard_player.spr = 141
			else
				wizard_player.spr = 169
			end
			if offset>20 then
				wizard_player.spr = 173
			end

			if (ticks%20<10) then
				wizard_enemy.spr = 137
			else
				wizard_enemy.spr = 139
			end
		end

		if (result=="win" or result=="draw") then

			if (ticks%20<10) then
				wizard_enemy.spr = 141
			else
				wizard_enemy.spr = 169
			end
			if offset>20 then
				wizard_enemy.spr = 173
			end
		end
		if (result=="win") then

			if (ticks%20<10) then
				wizard_player.spr = 137
			else
				wizard_player.spr = 139
			end
		end


		pal(1,2)
		pal(12,8)
		if ((result=="lose" or result=="draw") and offset>4) then
			spr(wizard_player.spr,0,5*8-5+min(offset-4,20)-1,2,2)
		else
			spr(wizard_player.spr,0,5*8-3-1,2,2)
		end
		pal(1,1)
		pal(12,12)

		if ((result=="win" or result=="draw") and offset>4) then
			spr(wizard_enemy.spr,14*8,5*8-5+min(offset-4,20)-1,2,2,true,false)
		else
			spr(wizard_enemy.spr,14*8,5*8-1-3,2,2,true,false)
		end


		--towers

		if (result=="win" or result=="draw") then
			if offset<18 then

				crashspr = 30
				if ticks%10 > 5 then
					crashspr = 46
				end

				spr(151,15*8,6*8-1+offset,1,3,true,false)
				spr(151,13*8,6*8-1+offset,2,3)

				spr(crashspr, 15*8,8*8+1)
				spr(crashspr, 13*8,8*8+1, 2,1,true,false)

				spr(44,15*8,9*8)
				spr(60,13*8,9*8)
				spr(62,14*8,9*8)
				spr(44,15*8,10*8)
				spr(59,13*8,10*8)
				spr(61,14*8,10*8)
			else
				spr(45,116,8*8)
				spr(45,108,8*8,1,1,true,false)
			end	
		else
			spr(151,15*8,6*8-1,1,3,true,false)
			spr(151,13*8,6*8-1,2,3)		

		end

		if (result=="lose" or result=="draw") then
			if offset<18 then

				crashspr = 30
				if ticks%10 > 5 then
					crashspr = 46
				end

				spr(151,0,6*8-1+offset,1,3)
				spr(151,1*8,6*8-1+offset,2,3,true,false)

				spr(crashspr,   0,8*8+1)
				spr(crashspr, 1*8,8*8+1, 2,1,true,false)

				spr(44,0,9*8)
				spr(60,8,9*8)
				spr(62,16,9*8)
				spr(44,0,10*8)
				spr(59,8,10*8)
				spr(61,16,10*8)
			else
				spr(45,4,8*8)
				spr(45,12,8*8,1,1,true,false)
			end

		else

			spr(151,0,6*8-1,1,3)
			spr(151,1*8,6*8-1,2,3,true,false)
		end			
	else

		spr(151,0,6*8-1,1,3)
		spr(151,1*8,6*8-1,2,3,true,false)

		spr(151,15*8,6*8-1,1,3,true,false)
		spr(151,13*8,6*8-1,2,3)
	end

	if (not gameover) then
		pal(1,2)
		pal(12,8)
		spr(wizard_player.spr,0,5*8-3-1,2,2)
		pal(1,1)
		pal(12,12)

		spr(wizard_enemy.spr,14*8,5*8-1-3,2,2,true,false)
	end

	spr(1,0,0,1,1,true,true)
	spr(1,15*8,0,1,1,false,true)
	spr(1,0,15*8,1,1,true, false)
	spr(1,15*8,15*8,1,1)

	spr(2,3*8,3*8,1,1,true,true)
	spr(2,12*8,3*8,1,1,false,true)
	spr(2,3*8,10*8,1,1,true, false)
	spr(2,12*8,10*8,1,1)
	--print("turn " .. turns, 52, 24, 0)
	if (error_countdown>ticks and not gameover) then
		printo(errormsg, 25,34,2,0)
	end

	if(info) then
		u = 0
		for i=1,wizard_player.hp do
			spr(104, 1, 46+i*6)
			u = i
		end
		for i=1,wizard_player.attack do
			spr(120, 1, 46+u*6+i*5)
		end
		u = 0
		for i=1,wizard_enemy.hp do
			spr(104, 122, 46+i*6)
			u = i
		end
		for i=1,wizard_enemy.attack do
			spr(120, 122, 46+u*6+i*5)
		end

	end


	arc(121,6,5,(ticks%(60*gamespeed))/(60*gamespeed),6)
	print(gamespeed, 120,4,13)

	if(gameover) then
		if result=="draw" then
			printo("it's a " .. result .. "!\n\n game over", 43,34,2,0)
		else
			printo("you " .. result .. "!!\n\ngame over", 46,34,2,0)
		end
	end
	
	if (not gameover) then
		spr(25,8,7*8)
		spr(25,9,7*8)
		if (crystals_player>9) then
			print(crystals_player, 9,7*8+2,2)
		else
			print(crystals_player, 11,7*8+2,2)
		end
	end
	if (can_see_enemy_crystals and not gameover) then
		spr(25,111,7*8)
		spr(25,112,7*8)
		if (crystals_enemy>9) then
			print(crystals_enemy, 112,7*8+2,1)
		else
			print(crystals_enemy, 114,7*8+2,1)
		end
	end

	if(show_cards_timeout>ticks and not gameover) then
		spr(131, 53-15, 25,3,4)
		spr(131, 53-10, 25,3,4)
		spr(131, 53-5, 25,3,4)
		draw_card(53, 25, card_selected)
	end

end

function draw_card(x, y, id)
	spr(131, 53, 25,3,4)
	cost=1
	if id == 1 then		
		card_spr = 64
		hp=2
		att=1
	elseif id == 2 then
		card_spr = 68
		hp=1
		att=1
		cost=2
	elseif id == 3 then
		card_spr = 72
		hp=1
		att=2
	elseif id == 4 then		
		card_spr = 76
		hp=3
		att=3
		cost=3
	end
	pal(1,2)
	pal(12,8)
	spr(card_spr, 53+4, 25+2,2,2)
	pal(1,1)
	pal(12,12)

	print(hp, 53+2,25+19,6)
	print(att, 53+12,25+19,6)
	print(cost, 53+12,25+19+6,6)
	if (id==2) then
		spr(122, 53+2,25+19+6)
	end

end
function arc(x, y, r, angle, c)
  circfill(x, y, r, 0)
 if angle < 0 then return end
 for i = 0, .75, .25 do
  local a = angle
  if a < i then break end
  if a > i + .25 then a = i + .25 end
  local x1 = x + r * cos(i)
  local y1 = y + r * sin(i)
  local x2 = x + r * cos(a)
  local y2 = y + r * sin(a)
  local cx1 = min(x1, x2)
  local cx2 = max(x1, x2)
  local cy1 = min(y1, y2)
  local cy2 = max(y1, y2)
  clip(cx1, cy1, cx2 - cx1 + 2, cy2 - cy1 + 2)
  circ(x, y, r, c)
  clip()
 end
end

function draw_unit(unit, unfriendly)
	flips = unfriendly
	if (not unfriendly) then
		pal(1,2)
		pal(12,8)
	end
	sprite = unit.spr
	if (unit.attacking>ticks) then
		sprite = unit.spr_attack
	end
	
	if unfriendly and unit.spr==171 then
		flips=false
	end
	spr(sprite, lanes[unit.lane][unit.pos]["x"]*8, lanes[unit.lane][unit.pos]["y"]*8, 2, 2, flips, false)
	if(info) then
		for i=1,unit.hp do
			spr(104, lanes[unit.lane][unit.pos]["x"]*8 + i*6 - (unit.hp*2), lanes[unit.lane][unit.pos]["y"]*8 -6 )
		end
		for i=1,unit.attack do
			spr(120, lanes[unit.lane][unit.pos]["x"]*8 + i*6 - (unit.attack*2), lanes[unit.lane][unit.pos]["y"]*8 + 16 )
		end
	end
	if (not unfriendly) then
		pal(1,1)
		pal(12,12)
	end

	if (unit.burning) then
		if (ticks%10<5) then
			spr(96, lanes[unit.lane][unit.pos]["x"]*8, lanes[unit.lane][unit.pos]["y"]*8, 2, 2)
		else
			spr(98, lanes[unit.lane][unit.pos]["x"]*8, lanes[unit.lane][unit.pos]["y"]*8, 2, 2)
		end
	end



end
function init_lanes() 
	lanes = {}
	lanes[1] = {}
	lanes[2] = {}
	lanes[3] = {}

	for i=0,6 do
		lanes[2][i] = {}
		lanes[2][i]["x"]=1+(i*2)
		lanes[2][i]["y"]=7
		lanes[2][i]["occupied"]=false
	end

	for i=0,12 do
		if (not lanes[1][i]) then
			lanes[1][i] = {}
			lanes[3][i] = {}
			lanes[1][i]["occupied"]=false
			lanes[3][i]["occupied"]=false
		end
		if i>9 then
			lanes[1][i]["x"]=13
			lanes[1][i]["y"]=-18+(i*2)

			lanes[3][i]["x"]=13
			lanes[3][i]["y"]=31-(i*2)
		elseif i<10 and i>2 then
			lanes[1][i]["x"]=-5+(i*2)
			lanes[1][i]["y"]=1

			lanes[3][i]["x"]=-5+(i*2)
			lanes[3][i]["y"]=13
		elseif i<4 then
			lanes[1][i]["x"]=1
			lanes[1][i]["y"]=7-(i*2)

			lanes[3][i]["x"]=1
			lanes[3][i]["y"]=7+(i*2)
		end
	end
	for l=1,3 do
		lanes[l][0]["occupied"]=true
		if (l==2) then
			lanes[l][6]["occupied"]=true
		else
			lanes[l][12]["occupied"]=true
		end
	end
end

function intro_init()
  map_x = 130
  map_y_org = 24
  offs=17
  music(0)
  intro=true
end

function intro_update()
	map_x -= 1
	if map_x < -350 or btnp(4) or btnp(5) then
		intro=false
		music(2)
	end
end

function intro_draw()
	
	map_y = map_y_org 
	spr(offs+1, map_x+48, map_y)
	spr(offs+1, map_x+80, map_y)
	spr(offs+1, map_x+96, map_y)

	map_y += 8
	spr(offs+5, map_x+32, map_y)
	spr(offs+7, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+5, map_x+56, map_y)
	spr(offs+7, map_x+64, map_y)
	spr(offs+3, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+5, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+5, map_x+152, map_y)
	spr(offs+7, map_x+160, map_y)
	spr(offs+3, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+5, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
	spr(offs+3, map_x+216, map_y)

	map_y += 8
	spr(offs+1, map_x+32, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+1, map_x+56, map_y)
	spr(offs+1, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+1, map_x+112, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+1, map_x+152, map_y)
	spr(offs+1, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y += 8
	spr(offs+2, map_x+32, map_y)
	spr(offs+7, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+56, map_y)
	spr(offs+7, map_x+64, map_y)
	spr(offs+6, map_x+72, map_y)

	spr(offs+2, map_x+80, map_y)
	spr(offs+1, map_x+88, map_y)

	spr(offs+2, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs+7, map_x+160, map_y)
	spr(offs+6, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+2, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y += 16
	spr(offs+1, map_x+104, map_y)
	spr(offs+1, map_x+152, map_y)
	spr(offs+4, map_x+168, map_y)

	map_y += 8

	spr(offs+7, map_x+24, map_y)
	spr(offs+7, map_x+32, map_y)
	spr(offs+3, map_x+40, map_y)

	spr(offs+5, map_x+48, map_y)
	spr(offs+1, map_x+56, map_y)

	spr(offs+5, map_x+64, map_y)
	spr(offs+7, map_x+72, map_y)
	spr(offs+3, map_x+80, map_y)
	
	spr(offs+5, map_x+88, map_y)
	spr(offs+7, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+1, map_x+112, map_y)
	
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+7, map_x+152, map_y)
	spr(offs+1, map_x+160, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+3, map_x+192, map_y)

	spr(offs+7, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
	spr(offs+3, map_x+216, map_y)

	spr(offs+5, map_x+224, map_y)
	spr(offs+1, map_x+232, map_y)

	map_y += 8

	spr(offs+1, map_x+24, map_y)
	spr(offs+1, map_x+40, map_y)

	spr(offs+1, map_x+48, map_y)

	spr(offs+1, map_x+64, map_y)
	spr(offs+1, map_x+80, map_y)
	
	spr(offs+1, map_x+88, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+1, map_x+112, map_y)
	
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+1, map_x+152, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+1, map_x+216, map_y)

	spr(offs+2, map_x+224, map_y)
	spr(offs+3, map_x+232, map_y)

	map_y += 8

	spr(offs+7, map_x+24, map_y)
	spr(offs+7, map_x+32, map_y)
	spr(offs+6, map_x+40, map_y)

	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+64, map_y)
	spr(offs+7, map_x+72, map_y)
	spr(offs+6, map_x+80, map_y)
	
	spr(offs+2, map_x+88, map_y)
	spr(offs+7, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+6, map_x+128, map_y)

	spr(offs+2, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs+1, map_x+160, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+2, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+6, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+1, map_x+216, map_y)

	spr(offs+7, map_x+224, map_y)
	spr(offs+6, map_x+232, map_y)

	map_y += 8

	spr(offs+1, map_x+24, map_y)

end
__gfx__
eeeeeeeeeeeeeeeecccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddd33333333eee66eee33333333eee66eeeeddddddeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeecccccccceee5bbb5ee5bbb5eee5bbb5eeee5bbb5ee5bbb5edddddddd33bbb333ee6cc6ee33333333ee6886ee5555555555666655eeeeeeee
eeeeeeeeeeeeeeeecccccccce555c3c5555c3c5e555c3c5ee555c3c5555c3c5edddddddd3b333b33e6cccc6e33333333e688886ee555555ee544445eeeeeeeee
eeeeeeeeeeeeeee0ccccccc3e5e533355e53335e5e53335ee5e533355e53335edddddddd333333336cccccc6333bbb3368888886e555555ee544445eeeee44ee
eeeeeeeeeeeeeee0ccccccc3e552cc5e5552cc5e5552cc5ee552cc5e552cc25edddddddd333333336cccccc633b333b368888886e555555ee544445eeee4454e
eeeeeeeeeeeeee00cccccc33ee52225eee52225eee52225eee52225ee52225eedddddddd33333333e6cccc6e33333333e688886ee555555ee544445eee44544e
eeeeeeeeeeeee000ccccc333ee1555eeeee511eeeee555eeeee555ee11555eeedddddddd33333333ee6cc6ee33333333ee6886eee555555ee554455eee4544ee
eeeeeeeeeee00000ccc33333eee1e11eee11eeeeee11e11eeee11eeeee11eeeedddddddd33333333eee66eee33333333eee66eeeee5555eeee5555eeeee44eee
eeeeeeeeeeeeeeee1111111011111111110000001111111000000111111111101111111166666666eee66eeeeee66eee1111111100000000eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee1111111011111111111100001111111000011111111111101111111177777777ee6116eeee6776ee1111111100000000ee5555eeeeee5555
eeeeeeeeeeeeeeee1111111001111111111110001111111000111111111111001111111177777777e611116ee677776e1111111100000000e5d77d555555ddd5
eeeeeeeeeeeeeeee1111111001111111111111001111111001111111111111001111111177777777611111166777777611111111000000005d7777ddddddd7dd
eeeeeeeeeeeeeeee1111111000111111111111001111111001111111111110001111111177777777611111166777777611111111000000005d7777d77777d77d
eeeeeeeeeeeeeeee1111111000011111111111100000000011111111111100001111111177777777e611116ee677776e111111110000000ee5d777dd777d77dd
eeeeeeeeeeeeeeee1111111000000111111111100000000011111111110000001111111177777777ee6116eeee6776ee11111111000000eeee5d7dd577dd5dd5
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000077777777eee66eeeeee66eee1111111100000eeeeee555555555555e
333333bba33333333333333333333333444445544444455454444444454444445dddddddd5ddddddeee66eeeeee66eee33333333eeeeeeeeeeeeeeeeeeeeeeee
3333bbbbbb3333333333333bbb333333444444455555544454444444454444445dddddddd5ddddddee6226eeeee66eee33333333eeeeeeeeeee55555555eeeee
333b3bb3bbbb3333333333bbbbb33333555554444444445554444444454444445dddddddd5dddddde622226eeee66eee33333333eeeeeeeeee5dddddd77dd555
333bb3bbb3b3b33333333b3b5b3b333344444555555555445555555555555555555555555555555562222226eee66eee33333333eeeeeeeee5dd777d777dd7dd
3333abb3bbba533333333ba3bbba333345004444444444444544444444454444d5ddddddddd5dddd62222226ee6666ee33333333555555eee5d777d5777d777d
33bbbbbb3bbbb3333333bbbb5bbbb33344500444555555554544444444454444d5ddddddddd5dddde622226ee555555e3333333356666555e5d777d577dd777d
3bb3bb5bbbbb33333333abbba5bb3b3354444455444444444544444444454444d5ddddddddd5ddddee6226eeeeeeeeee333333335d666566ee5d7dddd7d577dd
3b5bbabbb3bbb333333bb5bbbbbbb533455555444555555455555555555555555555555555555555eee66eeeeeeeeeee3333333355555555eee555555555555e
3babb3bbbbbbba33333bbbbbbb3bba3354444444544444454444444445444444ddddddddd5ddddddcccccccc5ddddddd5dddddddddddddd5ddddddd5cccccccc
bbb3bbb55bbbbbb333abbbbabbbb3bb345555555445555444444444445444444ddddddddd5ddddddcccccccc5ddddddd5dddddddddddddd5ddddddd5cccccccc
bbbbbb5445bb3bb333b3bbb555babbb344444444454444554444444445444444ddddddddd5ddddddcccccccc5ddddddd5dddddddddddddd5ddddddd5cccccccc
3bbbb54545bbbb33333bab54445bbb33555555555445554455555555555555555555555555555555cccccccc55555555555555555555555555555555ccccccc3
3333334543333333333333344433333344444444445444554444444454444444dddddddd5dddddddcccccccc5ddddddd5dddddddddddddd5ddddddd5ccccccc3
3335444445433333333333444443333355555555554404444444444454444444dddddddd5dddddddcccccccc5ddddddd5dddddddddddddd5ddddddd5cccccc33
3344354434333333333334534454333344444444444444444444444454444444dddddddd5dddddddcccccccc555555555ddddddd55555555ddddddd5ccccc333
33333333333333333333333333333333555555555555555555555555555555555555555555555555cccccccc55555555555555555555555555555555ccc33333
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6d6eeeeeeeeeeeee6d6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeee22eeeeeeeeeeeeeeeee
eeeeeee6eeeeeee6eeeeeeee6eeeeeeeee6d6665ee64eeeeee6d6665ee64eeeeeeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeee0000000ee2442eeee0000eeeeeeee
eeeee6666eeeeee6eeeeee6666eeeeeeeee5d43356e4eeeeeee5d4335e64eeeeeeeeeeeeeeeeeeeeeeeee7177eeeeeeeee000fffffee2442eee0000000eeeeee
eeee666666eeee66eeeee666666eeeeeeee4433365ee4eeeeee44333356e4eeeeeeee777eeeeeee6eeeee7771eeeeeeeee00f0ff0fe24442e0000fffffeeeeee
eee93313139eee66eeeee933339eeeeeeee43316135e4eeeeee43313136e4eeeeeee7171eeeeeee6eeeeee77eeeeeeeee000fff9ffe244420000f0ff0feeeeee
eee93333339eee4eeeee93313139eeeeeee43663335ee4eeeee43333336ee4eeeeee7777eeeeee66eee7777eeeeeeeeee000f4444fe244420000fff9ffeeeeee
eeee933039eeee4eeeee93333339eeeeeee4630035eee4eeeee44330356ee4eeeeeee77eeeeeee66ee776677eeeeeeee00ff145541f2444200eef0000feeeeee
eee11333311ee44eeeeee933039eeeeeeee613333111146eeee41333316114eeee77766777eee666e7e66e7e7eeeeeee0fff114411f44442eeff105501feeeee
ee1111331111e4eeeee11133331eeeeee364444444444466e3311111116ee4eee7e7e66e7e7ee66ee776e7ee7eeeeeee0ff1111111f4442eefff100011ffeeee
e1111111111114eeee1111133111eeeee3361111111ee46ee3311111116ee4eee7ee7777ee7e666e7e777ee7eeeeeeeeeff1111111ff442efff11111ffffeeee
311e111111e113eeee11e1111111e6eeeeee661111ee4eeeeeee1111116e4eee7ee7e66e7ee716ee7eee7717eeeeeeeeeff1111111fff2eefff122fffffeeeee
33ee555555ee43eee433444444336666eeee556655ee4eeeeeee5555556e4eee7eee7777ee171eee7eee7e71eeeeeeeeeff555555524feeeffff24ff4222eeee
eeee555555ee4eeeeee5555555eee6eeeeee555566e4eeeeeeee55555564eeeeeee7eeee7e11eeee6eee7ee116eeeeeeeff5555555242eeeefffff444444222e
eeee55ee55ee4eeeeee555e555eeeeeeeeee55ee5564eeeeeeee55ee5564eeeeeee7eeee7eeeeeeee77e6eee6666eeeeeee555e555e2eeeee55fff2224444442
eeee44ee44eeeeeeeee44eee44eeeeeeeeee44ee44eeeeeeeeee44ee44eeeeeeeee7eeee7eeeeeeeeeeee77ee66666eeeee44eee44eeeeeee44e444ee2244442
eeee444e444eeeeeeee444ee444eeeeeeeee444e444eeeeeeeee444e444eeeeeeee677ee677eeeeeeeeeeeeeeee66666eee444ee444eeeeee444eeeeeee2222e
eee9eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8e8eeeeee6eeeee777606686eeeeeeeeeeee111111ee00eeeeee111111eeeee
eeeaeee9e9eaeeeeeeeeae9e9eeeeeeeeeeee88888eeeeeeeeeee888888eeeee88888eeee676eeee77777688666eeeeeeeee11ccccc10fc0eeee11ccccc11eee
ee9aaeeaaee9eeeeeeee9eeaaeeaeeeee8e88898888eeeee8ee8889998888eee88888eee67776eee7776688866666eeeeee11cc1001c0c70eee11cc1001cc1ee
eeaa9eaa9e9aaeeeeeeaa9e9eae9eeeeeee8889999888eeee8888999999988eee888eeeee676eeee776dd888666eeeeeee11cc1000010cc0ee11cc100001c1ee
ee9aeaaaaaaa9aeeeea9eaeaeaaae9eee8898889999988ee8e8999999999999eee8eeeeeee6eeeee66d776886eeeeeeeee1c1cc00000c00eee1c1cc00000c1ee
eeaa9aeeeeeaeaeeeeaaeee9eaa9aeeeee8999999999999ee8888999aaaaaa99eeeeeeeeeeeeeeeedd776888eeeeeeeee1c1f4c0444c110ee1c1f4c0444c11ee
ee99eeaaaeeee9eeee9aeeeeae9e9eeee888999999aaaa99ee88999aaaaaaaa9eeeeeeeeeeeeeeee7766888eeeeeeeeee1c1f4c4fffc1f0ee1c1f4c4fffc1eee
eee9e9eeeeaaeeeeeeeeaeeeeee89eeee8889999aaaaaaa9e88999aaaa777aa9eeeeeeeeeeeeeeee668888eeeeeeeeeeee1111ccfffcff0eee1111ccfffc1eee
eee9eeeeeea9e9eeee9e9aeeee9e9eeee889999aaaa77aa9899999aaa7777aa9eeeeeeeeee8eeeeeee44eeeeeeaeeeeeeee1c111ccc1110eeee1c111ccc11eee
eeeeeee9eee988eeee8e9eee9ee88eee889999aaaa7777a9889999aaaa777aa9e4eeeeeee9a9eeeee6e44eeeea9aeeeeeee11cc1111ccc0eee001cc111cc1eee
eee8e8eeee8eeeeeeeeee8ee8e8e8eee899999aaaaa77aa98889999aaaaaaa9944666eee8a7a8eee6eee4eeeea9aeeeeeeee1ccc11111c0eeee0000c111c1eee
eeee8eeeeeee8eeeeee8eeeee8e8eeee8889999aaaaaaa99899999999aaaa99ee4eeeeeeea9aeeeee6e44eeea999aeeeeeee1cccc111e10eeeee1cc0000f1eee
eeeee8eee88eeeeeeeeee88ee88eeeeeee8999999aaaa99e8888899999999eeeeeeeeeee8eee8eeeee44eeeee888eeeeeeee1c1cc011ee0eeeee1c1cc0f0000e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888999999999eeeeee88889988eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeceeeeee1eeeeeeeeceeeeee09990
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88899988eeeee8eeeeee88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0970
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00e
555555555555555555000000e222222222222222222222eecccccccceeeee222222ee00eeeee111111ee00eeeeee111111ee00eeeeee111111eeeeeeeeeeeee6
5eeeeeeeeeeeeeeee500000022000000000000000000022ecccccccceeee228888820fc0eee11ccccc10fc0eeee11ccccc10fc0eeee11ccccc11eeeeeee66ee4
5eeeeeeeeeeeee44e500000020000000000000000000002ecccccccceee2288200280c70ee11cc1001c0c70eee11cc1001c0c70eee11cc1001cc1eeeee6666e4
5eeeeeffffeee4444500000020000000000000000000002eccccccccee22882000020cc0e11f41000010cc0ee11cc1000010cc0ee11cc100001c1eeeeee33ee4
5eeeef0ff0fee4444500000020000000000000000000002eccccccccee2828800000820ee1cf4c00000c10eee1c1cc00000c10eee1c1cc00000c1eee43333333
5eeeefff9ffee4444500000020000000000000000000002ecccccccce282f4804448220e1c111c0444c110ee1c1f4c0444c110ee1c1ccc0444c111ee43433ee4
5eeeef4444fe44444500000020000000000000000000002ecccccccce282f484fff82f0e1c1c1c4fffc1f0ee1c1f4c4fffc1f0ee1c11cc4fffcc4f1e443333e4
5eeff945549f4444e500000020000000000000000000002eccccccccee222288fff8ff0ee11c11cfffcff0eee1111ccfffcff0eee1f41ccfffcc4f1ee43ee3ee
5efff994499f4444e500000020000000000000000000002ecccccccceeeeeeeeeeeeeeeeee1cc11ccc1110eeee1c111ccc1110eee1f41cccccc111eeeeeee44e
5eff9999999f444ee500000020000000000000000000002ecccccccceeeeeeeeeeeeeeeeee11cc1111ccc0eeee11cc1111ccc0eeee11111111c1c1eeeeeee644
5eff9999999ff44ee500000020000000000000000000002ecccccccce555e555e555e555eee1ccc11111c0eeeee1ccc11111c0eeeee1ccc11111c1eeee6336e4
5eff9999999fffeee500000020000000000000000000002ecccccccce565556555655565eee1cccc111e10eeeee1cccc111e10eeeee1cccc111e1eeeee4436e4
5eff555555544feee500000020000000000000000000002ecccccccce566666666666666eee1c1cc011ee0eeeee1c1cc011ee0eeeee1c1cc011eeeeee344f333
5eff555555544eeee500000020000000000000000000002ecccccccce555555555555555ee1cc1cc011ee0eeee1cc1cc011ee0eeee1cc1cc011eeeeee34436e4
5eee555e555eeeeee500000020000000000000000000002ecccccccce5dddd5ddd5dddddee111cccc111e0eeee111cccc111e0eeee111cccc111eeeeee333344
5eee44eee44eeeeee500000020000000000000000000002eccccccccee55665666566666eeeee1111eeeeeeeeeeee1111eeeeeeeeeeee1111eeeeeeeee3ee34e
5eee444ee444eeeee500000020000000000000000000002ecccccccceee5555555555555eeee111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6eeee6e
55555555555555555500000020000000000000000000002ecccccccceeee566656656665eee11ccccc11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4e44e4e
58558588555555885500000020000000000000000000002ecccccccceeee566656656665ee11cc1001cc1eeeeeee555555555eeeeeeee111111eeeeee4e44e4e
58558585858558555500000020000008080000000000002ecccccccceeee555555555555e11cc100001c1eeeeee55666666655eeeee111cccc111eeee444444e
58888588555558885500000020000088888000000400002ecccccccceeee565666566566e1c1cc00000c1eeeee5566666666655eee11ccc1001c1eeee44444ee
58558585558558558500000020000088888000004466602ecccccccceeee5656665665661c11cc0444cc1eeeee5600660600665ee11ccc1000011eeeee444eee
58558585555555885500000020000008880000000400002ecccccccceeee55555555555511f4cc4fffc1111eee5606060606065ee1ccc100000c1eeeee4e4eee
55555555555555555500000020000000800000000000002ecccccccceeee566656665666e1f41ccfffccc4f1e55600660600665ee1c1c000044c1eeeeeeeeeee
55885588855558885500000020000000000000000000002ecccccccceeee566656665666ee111cccccccc4f1e56606060606665ee1c1c44fffc11eee00828200
58558558558555558500000020000000000000000060002ecccccccceeee555555555555eee111111cc1111ee56666666666665eee11ccfffccc1eeec0c0c080
58888558555555885500000020000000000000000676002ecccccccceeee566666566665eee1cc111111c1eee56666666666665eeee111111ccc1eee00008200
58558558558555558500000020000000000000006777602ecccccccceeee566666566665eee1cccc111e1eeee56655665555665eee14f1c111cc11eec0c0c080
58558558555558885500000020000000000000000676002ecccccccceeee555555555555eee1c1cc011eeeeee56655556655665eee14f1cc0114f1ee00008282
55555555555555555500000020000000000000000060002ecccccccceeee566566665666ee1cc1cc011eeeeee56666666666665eee111ccc0114f1eec0c0c080
00000000000000000000000022000000000000000000022ecccccccceeee566566665666ee111cccc111eeeee56666666666665eeee11cccc1111eee00000082
000000000000000000000000e222222222222222222222eecccccccceeee555555555555eeeee1111eeeeeeee55555555555555eeeeee1111eeeeeeec0c0c080
eeeee222222ee00eeeeee222222eeeeeeeeee444eeeeeeee80800000820000000000828282828282000000000000008200000000828282000000000000000082
eeee228888820fc0eeee228888822eeeeeee444444eee44e8080808080808080808000000000808000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c080
eee2288200280c70eee22882002882eeeee4444444ee44440080008282000000008282000000000000000000a200008200000000000082820000000000000000
ee22882000020cc0ee228820000282eeee44444444ee4444000000000000000000800000000000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c080
ee2828800000800eee282880000082eee4e444444fee444400800082000000000082000000000000000000000000008282000000000000820000000000000000
e282f4804448220ee282f480444822eeee4444444fe444440000f000000000000080c00000000000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c080
e282f484fff82f0ee282f484fff82eeeee44444449f4444e00800082000000008282000000000000000000000000008282000000000082820000008282000000
ee222288fff8ff0eee222288fff82eeee44f494499f4444e80808080000080000080c0c00000000000000000000000000000000000c0c0c0c0c0c0c0c0c0c080
eee282228882220eeee2822288822eeee4f4494999f444ee00800082000000828282000000000000000000000000828282000000008282000000828282820000
eee228822228880eee00288222882eeeef44949999ff44ee80808080000080040480c0c0c00000000000000000000000000000000000c0c0c0c0c0c0c0c0c080
eeee28882222280eeee0000822282eeeeff9999999fffeee008000820000000000828282000000000082828282828200000000000082000000828200008200f0
eeee28888222e20eeeee2880000f2eeeeff555555544feee80808080000080000080c0c0c0c00000000000000000000000000000000000c0c0c0c0c0c0c0c080
eeee28288022ee0eeeee282880f0000eeff555555544eeee04800082820000000000008200000000008200000000000000000000828200000082000000828282
eee288288022ee0eeee2882880209990eee555e555eeeeee00000000000080040480c0c0c0c0c00000000000000000000000000000000000c0c0c0c0c0c0c080
eee2228888222e0eeee2228888220970eee44eee44eeeeee00800082828200000000f08282000000008282820000000000000000820000008282000000000000
eeeeee2222eeeeeeeeeeee2222eee00eeee444ee444eeeee00000000000080000080c0c0c0c0c0c00000000000000000000000000000000000c0c0c0c0c0c080
eeeee111111ee00eeeeee111111eeeeeeee9eeeeeeeeeeee04800000828282928282828282000000000000828200000000000082820000008200000000000000
eeee11ccccc10fc0eeee11ccccc11eeeeeeaeee9e9eaeeee80808080000080040480c0c0c0c0c0c0c00000000000000000000000000000000000c0c0c0c0a080
eee11cc1001c0c70eee11cc1001cc1eeee9aaeeaaee9eeee00800000000000000000000000a20000000000008282000000008282000000828200000000000000
ee11cc1000010cc0ee11cc100001c1eeeeaa9eaa9e9aaeee80808080000080000080c0c0c0c0c0c0c0c00000000000000000000000000000000000c0c0a0a080
ee1c1cc00000c00eee1c1cc00000c1eeee9aaaaaaaaa9aee04800000000000000000000000000000000000000082828282828200000000820000000000000000
e1c1f4c0444c110ee1c1f4c0444c11eeeeaa9aaa9aaaaaee80808080000080040480c0c0c0c0c0c0c0c0c00000000000000000000000000000000000c0a0a080
e1c1f4c4fffc1f0ee1c1f4c4fffc1eeeee9999aaaa9aa9ee00800000000000000000000000000000a20000000000000000000000000082828282000000000000
ee1111ccfffcff0eee1111ccfffc1eeeeee989aaaaaaa9ee80808080000080000080c0c0c0c0c0c0c0c0c0c00000000000000000000000000000000000a0a080
eee1c111ccc1110eeee1c111ccc11eeeeee9899aa9a999ee04808000000000000000000000000000000000000000000000000000008282000082828282828282
eee11cc1111ccc0eee001cc111cc1eeeeee88999999988ee80808080000080040480c0c0c0c0c0c0c0c0c0c0c000000000000000c0c0000000000000a0a0a080
eeee1ccc11111c0eeee0000c111c1eeeeee8889888888eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee1cccc111e10eeeee1cc0000f1eeeeeee888888888eee00000000000000000080c0c0c0c0c0c0c0c0c0c0c0c00000000000000000000000000000a0a0a080
eeee1c1cc011ee0eeeee1c1cc0f0000eeeeee888888eeeee00000000000000000000000000000000000000909090909090909000000000000000000000000000
eee1cc1cc011ee0eeee1cc1cc0109990eeeeeeeeeeeeeeee00000000000000000080c0c0c0c0c0c0c0c0c0c0c0c0c0000000000000000000000000f0a0a0a080
eee111cccc111e0eeee111cccc110970eeeeeeeeeeeeeeee80808080808080808080808080808080808080808080808080808080808080808080808080808080
eeeeee1111eeeeeeeeeeee1111eee00eeeeeeeeeeeeeeeee80808080808080808080808080808080808080808080808080808080808080808080808080808080
__gff__
0000000000000000010100010000000400000000000000000000000001000000000000000000000000000001010000000000000000000000000001000000000000000000000000000000000000000000010001000100010001000100010001000101010101010101000000000000000001010101010101010000000000000000
0000000000000000000000000000000001000001000001000000000000000000000000000000000000000000000000020000000000000000000000010000000000000000000000000000000000000000000000000100000000000000000000000000000001010000000000000000000000000000010100000000000000000000
__map__
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c09090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909080808080808080808080808080808080808080808080808080808
2c0b0b09090b0b09090b0b09090b0b2c00000000000000000000000000000900000000000000000000000000000000000000000000000009000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000008
2c0b0b09090b0b09090b0b09090b0b2c00000000000000000000000000000900000000000000000000000000000000000000000000000009000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000f00000008
2c09093a3a3a3a3a3a3a3a3a3a09092c000000000000000000000000000009404009000000000000000000000000000000000000000000090000000000000000000000000000090000094040091c1c00000000000000000000000000000000000000000000080000000000000000000000000000080808080808080808000008
2c09093a3a3a3a3a3a3a3a3a3a09092c00000000000000000000000000000900000900000000000000000f00000000000000000000000009000000000048494a4b000000000009000009000009001c1c000000000000000000000000000000000000000000080000000808080808080808080000080808080808080808000008
2c0b0b3a3a3a3a3a3a3a3a3a3a0b0b2c00000000000000000000000000000940400909090900000009090909000000000009090900000009000000000058595a5b00000000000900000940400900001c000000000000000000000000000000000000000000084040400808080808080808080000080808080808080808000008
2c0b0b3a3a3a3a3a3a3a3a3a3a0b0b2c00000000000000000000000000000900000900000900000009000009000000000009000000000009000000000068696a6b00000000000900000900000900001c1c000000001c1c1c1c0000001c1c1c1c00001c4040080000000808080808080808080000000000000000000000000008
2c3c3627363736273627363736263e2c00000000000000000000000000000940400909090900000009090909000000000009000000000909000000000078797a7b0000000000090000094040090000001c1c00001c1c0000000000000000001c1c1c1c0000084040400800000000000000000000000000000000000000000008
2c3b3626362636373626362636273d2c00000000000000000000000000000900000900000000000000000000000000000009000000090909000000000000000000000000000009000009000009000000001c1c1c1c000000000000000000000000001c4040080000000800000000000000000000080808080808080808080808
2c3c3e3a3a3a3a3a3a3a3a3a3a3c3e2c000000000000000000000000000009404009000000000000000000000000000000090000000000000000000000000000000000000000000000004040090000000000000000000000000000000000000000001c0000084040400800000000000000000000000000000000000000000008
2c3b3d3a3a3a3a3a3a3a3a3a3a3b3d2c000000000000000000000000000009000009000f0000000000000000000000000009090000000000000000000000000000000f000000000000000000090f00000000000000000000000000000000000000001c4040080000000800000808080808080000000000000000000000000008
2c3c3e202120232023222320213c3e2c000000000000000000000000000009404009090909000000090909090909090909090909090909090909090909090909090909090909090909090909091c1c000000000000000000000000000000000000001c0000084040400800000808080808080808080808080808080808000008
2c3b3d303132333031323330333b3d2c000000000000000000000000000009000009000009000000090000090000001c1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c4040080000000800000000000000000000000000000000000008000008
2c3c3839382838393829382838283e2c0000000000000000000000000000094040090909090000000909090900001c1c00000000000000000000000000000000000000000000000000000000000000001c0000000000000000000000000000000000000000084040400800000000000000000000000000000000000008000008
2c3c3829383938293829382838293e2c0000000000000000000000000000090000090000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000000000000000001c1c1c1c000000000000000000000000080000000800000000000000000000000000000000000008000008
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000000000000000000094040090000000000000000000000001c1c0f00000000000000000000000000000000000000000000000000000000000000000000001c1c00001c1c00000000001c1c1c1c4040084040400808080808080808080000080808080808080808000008
090000002c002c2c2c002c2c2c2c2c00000000000000000000000000000009000009000000000000000000000000001c1c1c1c1c00000000001c1c0000000000000000001c000000001c1c1c000000000000001c1c00000000000000001c1c1c0000000000080000000808080808080808080000080808080808080808000008
090000000000000000000000000000000000000000000000000000000000094040090909090000000909090900000000001c1c00000000000000000000001c0000000000000000000000001c1c1c1c1c1c1c1c1c000000000000000000001c000000004040084040400800000000000000000000000000000000000008000008
0900000000000000000000000000000000000000000000000000000000000900003b000f09000000090000090000000000001c000000000000000000000000000000000000000000000000000000000000000000000000001c1c000000001c0000000f0000080000000800000000000000000000000000000000000008000008
090000000000000000000000000000000000000000000000000000000000094040090909090000000909090900000000001c1c00000000000000000000000000000000000000000000000000000000000000000000001c1c1c1c000000001c404040080808084040400800000808080808080808080808080808000008000008
0900000000000000000000000000000000000000000000000000000000000900000900000000000000000000000000000f1c00000000000000000000000000000000000000000000000000000000000000000000001c1c00001c1c0000001c000000080000000000000800000000000000000000000000000000000008000008
09000000000000000000000000000000000000000000000000000000000009404009000000000000000000000000001c1c1c0000000000000000000000000000000000000000000000000000000000000000001c1c1c000000001c0000001c404040080000000000080800000000000000000000000000000000000008000008
09000000000000000000000000000000000000000000000000000000000009000009000f00000000000000000000001c00000000000000000000000000000000000000000000001c1c1c00000000001c1c1c1c1c0000000000001c0000001c000000084040400808080808080808000008080808080808080808080808000008
09000000000000000000000000000000000000000000000000000000000009404009090909000000090909090000001c0f0000000000000000000000000000000000000000001c1c001c1c000000001c000000000000000000001c0000001c404040080000000800000000000000000008000000000000000000000000000008
09000000000000000000000000000000000000000000000000000000000009000009000009000000090000090000001c1c1c1c000000000000000000000000000000000000001c0000001c0000001c1c0000000000001c1c00001c0000001c000000084040400800000000000000000008000000000000000000000000000008
090000000000000000000000000000000000000000000000000000000000094040090909090000000909090900000000001c000000000000000000000000000000000000001c1c0000001c1c00001c000000000000001c1c000f1c0000001c404040080000000800000808080808080808000008080808080808080808080808
09000000000000000000000000000000000000000000000000000000000009000009000000000000000000000000001c1c1c000000000000000000000000000000000000001c00000000001c00001c000000001c1c1c1c1c1c1c1c0000001c000000084040400800000800000000000000000008000000000008000000000008
09000000000000000000000000000000000000000000000000000000000009404009000000000000000000000000001c00000000000000000000000000000000000000001c1c00000000001c00001c1c000000000000000000001c0000001c404040080000000800000800000000000000000008000000000008000000000008
09000000000000000000000000000000000000000000000000000000000009000009000000000000000000000000001c000000000000001c1c1c1c1c1c000000001c0000001c1c0000001c1c0000001c00000000000000000000000000001c000000084040400800000800000000000000080808000000000008000f00000008
09000000000000000000000000000000000000000000000000000000000009404009090909090909090909090000001c1c000000001c1c1c000000001c1c00000000000000001c0000001c000000001c1c1c0000000000000000000000001c404040080000000000000800000000000000000008000000000008080800000008
0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c1c1c1c1c1c000000000000001c1c000000000000001c1c00001c0000000000001c1c1c000000001c1c1c1c00001c000000084000000000000000000000000000000008000000000008000000000008
09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c1c000000000000001c001c1c00000000000000001c1c1c00001c00000000001c40404008000000000000000000000000000f000008000000000008000000000808
__sfx__
0107000017634186331c6232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f015300152d01528015300152d01529015280152d0152b0152d015290152d015280152b0152d0152f015300152d015340152f015320152d015300152b0152d015280152901526015280152401526015
011000002301524015210151c01524015210151d0151c0151f0151c015210151d015230151c0151f0152301524012240122401224015210051d00523005210052400523005260052400528005260052b00528005
0110000a0062604626056260062602626006260562602626046260062605626036260062605626036260062605626076260062601626056260562602626006260462605626026260062605626076260462604626
01020000296202b6220c6220c02200022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000029230282302923026230290002323000000000001f230000001c2201a2201722014220142200010000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000186340c633137530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000186340c633305150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003463630621306213062124621246212461200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000305000000030550305503050000000305503055030500000003055030550305000000030550305503050000000305503055030500000003055030550305000000030550305503050000000305503055
011000000005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000005500055
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000000000000000c7630c763000000000015623000000c7630c7630c763000000c7630000015623156230000000000
011000001f74000000000000000000000000001d740000001f740000000000000000000000000018740000001f7400000020740000001f740000001d740000001f74000000000000000000000000001a74000000
011000001b740000000000000000000000000018740000001b740000000000000000000000000018740000001b740000001d740000001f740000001d740000001874000000000000000000000000000000000000
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000000000000000c7630c763000000000015623000000c7630c7630c763000000c7630000015623156231562315623
011000002473030730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b1501b1521b15218150181551815518152181521b1511b15200000000001810018105181551815000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b1201b1221b12218120181251812518122181221b1211b1211312113122161201612218120181221811013100131111311016111161101811118110000001b1201d1201b1201a12018120161201b120
011000001b1201b1221b1221d1201d1251d1251e1221e1221f1211f12122121221222412024122241202412218110000001311113110161111611018111181101d1111d1101b1111b11018111181100000000000
011000002602000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000290402e040290402d00029000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018122181221812213120131251312518122181221b1211b12113121131221612016122181201812218110131001311113110161111611018111181100000000000000000000000000000000000000000
0110000022120241222212222122221121f1051f1251f12522122221211f1211d1211b1251f1251b1211b12118121181211812018120181201810118111181101d1111d1101b1111b11018111181101811000000
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
01 01 42 43 44
04 02 42 43 44
01 0b 42 0a 44
00 0b 42 09 44
00 0b 42 0a 44
00 0b 42 09 44
00 0b 0c 0a 44
00 0b 0d 09 44
00 0b 0c 0a 44
02 0e 0d 09 44
00 0a 06 11 44
00 0b 0d 15 44
00 0a 06 12 44
00 0b 0d 16 44
00 0b 0d 09 44
02 0b 06 16 44
00 0a 06 11 44
00 0b 0d 15 44
01 0a 06 12 44
02 0b 07 16 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
