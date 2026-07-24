pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--main

--flags
wall=0
text=1
interact=2
special=3
stairs=4
water=5

--consts
dirs={
	x={0,1,0,-1,1,1,-1,-1},
	y={1,0,-1,0,1,-1,1,-1}
}

function _init()
	init_storage()
	init_game()
end

-->8
--drawing

function clear_screen()
	cls()
	palt(0,false)
end

function draw_player()
	local plr_spr=is_water(plr.x,plr.y) and 18 or 1
	palt(0,false)
	spr(plr_spr,plr.x*8,plr.y*8)
end

function draw_debug()
	for i=1,#debug do
		print(debug[i],map_x*8,map_y*8+i*6,7)
	end
end

function draw_monster_data(mon)
	draw_monster(mon)
	draw_hp_bar(mon)
end

function draw_all_monsters()
	foreach(monsters,draw_monster_data)
end

function draw_framed_rect(x,y,w,h)
	rectfill(x,y,x+w,y+h,0)
	rectfill(x+1,y+1,x+w-1,y+h-1,6)
	rectfill(x+2,y+2,x+w-2,y+h-2,0)
end

function draw_fog()
	local dun_index=is_dungeon()
	if not dun_index then return end
	local curr_fog=fog[dun_index]
	for x=1,16 do
		for y=1,16 do
			if curr_fog[x][y] then
				palt(0,false)
				spr(127,(map_x+x-1)*8,(map_y+y-1)*8)
			end
		end
	end
end

function unfog()
	local dun_index=is_dungeon()
	if not dun_index then return end
	local curr_fog=fog[dun_index]
	for x=1,16 do
		for y=1,16 do
			local fx,fy=map_x+x-1,map_y+y-1
			if dist(plr.x,plr.y,fx,fy)<4 then
				curr_fog[x][y]=false
			end
		end
	end
end

function framed_text(text,x,y,col)
	for i=1,8 do
			print(text,x+dirs.x[i],y+dirs.y[i],0)		
	end

	print(text,x,y,col)
end

function shadow_text(text,x,y,text_col,shadow_col)
	print(text,x,y+1,shadow_col)
	print(text,x,y,text_col)
end

function draw_message()
	if message_timer>0 and 
				active_message~="" then
		local x=64-#active_message*2+map_x*8
		local y=64-flr(20/-message_timer)+map_y*8
		framed_text(active_message,x,y,6)
		message_timer-=1
	end
end
-->8
--map and camera

function draw_map()
	map(0,0,0,0,128,64)
end

function set_camera()
	map_x=flr(plr.x/(16))*16
	map_y=flr(plr.y/(16))*16
	camera(map_x*8,map_y*8)
end


function is_walkable(x,y,switches)

	if not switches then switches={} end

	local tile=mget(x,y)

	if is_water(x,y) and switches.is_floater then
		return true
	elseif not is_special(x,y) or not switches.is_player then
		return not fget(tile,wall)
	else
		--special items
 	if tile==97 and inventory.lamp then
 		return true
		elseif tile==96 and inventory.boat then
			return true
		elseif tile==112 and inventory.cloak then
			return true
		else
			return false
		end
 end
end

function is_text(x,y)
	local tile=mget(x,y)
	return fget(tile,text)
end

function is_interactive(x,y)
	local tile=mget(x,y)
	return fget(tile,interact)
end

function is_special(x,y)
	local tile=mget(x,y)
	return fget(tile,special)
end

function is_stairs(x,y)
	local tile=mget(x,y)
	return fget(tile,stairs)
end

function is_water(x,y)
	local tile=mget(x,y)
	return fget(tile,water)
end

function map_area_index()
	return (map_y/16)*8+map_x/16
end

function location_index(x,y)
	return y*128+x
end

function index_to_coords(index)
	return index%128,flr(index/128)
end

function get_random_border_tile()
	local tries,x,y=0
	local dirs={"left","right","up","down"}
	repeat
		local offset=flr(rnd(16))
		local where=rnd(dirs)
		if where=="left" then
			x=map_x
			y=map_y+offset
		elseif where=="right" then
			x=map_x+15
			y=map_y+offset
		elseif where=="up" then
			x=map_x+offset
			y=map_y
		elseif where=="down" then
			x=map_x+offset
			y=map_y+15
		end
		tries+=1
		if tries>=10000 then
			return nil,nil
		end
	until is_walkable(x,y)

	return x,y
end


function is_out_of_screen(tx,ty)
	return tx<map_x or 
								tx>map_x+15 or
								ty<map_y or
								ty>map_y+15
end

function is_safe()
	return not map_areas[map_area_index()+1]
end
-->8
--player

function make_player()
	plr={
	 x=54,
	 y=23,
		lvl=1,
		xp=0,
		hp=20,
		hpmax=20,
		atk=3,
		def=0,
		gold=0,
		attack=attack,
		die=function()
			transition_out()
			t_cover=0
			if inventory.essence and 
						is_essence_active() then
				essence_resurrection()
				set_camera()
				resume_music()
				return				
			end
			music(16)
			game_over_pos=280
			map_x=0
			map_y=0
			_draw=draw_game_over
			_update=update_game_over 
		end
	}
end

function check_levelup()
	local to_level=next_lvl(plr.lvl)
	if plr.xp>=to_level then
		plr.lvl+=1
		plr.hpmax+=8
		plr.xp-=to_level
		plr.hp=plr.hpmax
		sfx(51)
		message("you grow in power!",2)
	end
end

function next_lvl(lvl)
	return (lvl+1)*(lvl+1)*4
end
-->8
--gameplay

function update_game()
	if t_cover>0 then
		return
	end
	--handle_music()
	attacked=false
	moved=false
	local move_x,move_y=handle_keys()
	if btnp(—) and not active_text then
		if stats_mode==draw_status_bar then	
			stats_mode=draw_stats	
			sfx(59)
 	else
			stats_mode=draw_status_bar
			sfx(58)
		end
	end
	
	if active_text or 
				stats_mode==draw_stats then
		return
	end
	
	if btnp(Ž) and inventory.wand then
		if not is_wand_active() then
			sfx(52)
			return
		end
		wand_attack()
		move_monsters()
		handle_spawning()
		advance_item_turn()
		ring_regeneration()
		return
	end
	
	if move_x==0 and move_y==0 then
		return
	end
	
	local tx,ty=plr.x+move_x,plr.y+move_y
	local mon=is_monster_at(tx,ty)
	if is_text(tx,ty) then
		display_text(tx,ty)
	elseif mon then
		handle_attack(mon)
	elseif is_interactive(tx,ty) then
		handle_interact(tx,ty)
	elseif is_dungeon() and is_out_of_screen(tx,ty) then
		bump_into_wall()
	elseif is_stairs(tx,ty) then
		handle_stairs(tx,ty)
	elseif is_walkable(tx,ty,{is_player=true}) then
		move_player(tx,ty)
	else
		bump_into_wall()
	end
	
	if moved then
		move_monsters()
		handle_spawning()
		if is_final_dungeon() then
			final_dungeon_update()
		end
		advance_item_turn()
		ring_regeneration()
	end
end

function is_monster_at(x,y)
	for m in all(monsters) do
		if m.x==x and m.y==y then
			return m
		end
	end
	return nil
end

function handle_keys()
	local move_x,move_y=0,0
	if btnp(‹) then 
		move_x=-1 
	elseif btnp(‘) then
	 move_x=1
	elseif btnp(ƒ) then
	 move_y=1
	elseif btnp(”) then
	 move_y=-1
	end

	return move_x,move_y
end

function attack(self,other)
	other.hp-=max(0,self.atk-other.def)+flr(rnd(2))
	if other.hp<=0 then
		other:die()
		if self==plr then
			plr.xp+=other.xp
			plr.gold+=other.gold+ceil(rnd(other.gold))
			check_levelup()
		end
		if other==dark_lord then
			transition_out()
			map_x=0
			map_y=0
		--[[	if is_mirror_whole() then
				music(34)
			else
				music(16)
			end
			--]]
			good_ending=false
			music(16)
			_draw=draw_ending
			_update=update_ending
		end
		if other==behemoth then
			add_armor(4)
			active_text={
				"the mighty behemoth falls",
				"and among its many stolen",
				"posessions you find the",
				"ancient shield of giants!"
			}
		end
	end
end

function interact_with(obj)
	if not obj then return end
	if not obj.touched then
		sfx(59)
		if not obj.repeatable then
			obj.touched=true			
		end
		active_text=obj.text_before
		obj:action()
		--the action might revert touched
		if obj.touched then
			mset(obj.x,obj.y,obj.sprite_after)
		end
	
	else
		active_text=obj.text_after
	end
end

function heal()
	local healing_amount=plr.hpmax-plr.hp
	while healing_amount>0 and plr.gold>0 do
		plr.gold-=1
		plr.hp+=1
		healing_amount-=1
	end
	plr.gold=max(plr.gold,0)
	sfx(56)
end

function add_weapon(weapon)
	sfx(56)
	plr.atk=max(plr.atk,weapon)
end

function add_armor(armor)
	sfx(56)
	plr.def=max(plr.def,armor)
end

function handle_music()
	if is_dungeon() then
		if not player_in_dungeon then
			player_in_dungeon=true
			pattern=is_final_dungeon() and 28 or 18
			music(pattern)
		end
	else
		if player_in_dungeon then
			music()
			player_in_dungeon=false
		end
	end
end

function resume_music()
	if is_dungeon() then
		pattern=is_final_dungeon() and 28 or 18
		music(pattern)
	else
		music()
	end
end

function display_text(x,y)
	active_text=get_text(x,y)
	sfx(59)
end

function handle_attack(mon)
	sfx(61)
	plr:attack(mon)
	attacked=true
	moved=true
end

function handle_interact(x,y)
	local obj_index=location_index(x,y)
	local obj=story_map[obj_index]
	interact_with(obj)
end

function bump_into_wall()
	sfx(62)
end

function handle_stairs(x,y)
	local obj_index=location_index(x,y)
	local stair=stair_map[obj_index]
	local mx,my=index_to_coords(stair)
	plr.x,plr.y=mx,my
	sfx(57)
	transition_out()
	set_camera()
	resume_music()
end

function handle_spawning()
	if rnd()<map_danger[map_area_index()+1] then
		spawn_random_monster()
	end
end

function move_player(x,y)
	plr.x,plr.y=x,y
	sfx(63)
	moved=true
end

function advance_item_turn()
	if inventory.ring then
		ring_turn+=1
	end
	
	if inventory.wand then
		wand_turn+=1
	end
	
	if inventory.essence then
		essence_turn+=1
	end
end

function ring_regeneration()
	if inventory.ring and 
				ring_turn>20 and 
				plr.hp<plr.hpmax then
		plr.hp+=1
		sfx(54)
		ring_turn=0
	end
end

function is_wand_active()
	return wand_turn>=100
end

function is_essence_active()
	return essence_turn>=200
end

function wand_attack()
	sfx(53)
	wand_turn=0
	for i=1,8 do
		local x,y=plr.x+dirs.x[i],plr.y+dirs.y[i]
		local mon=is_monster_at(x,y)
		if mon then
			old_atk=plr.atk
			plr.atk=20
			plr:attack(mon)
			plr.atk=old_atk
		end
	end
	camera()
	rectfill(0,0,127,127,7)
	flip()
end

function essence_resurrection()
	sfx(50)
	essence_turn=0
	plr.x=54
	plr.y=20
	plr.hp=flr(plr.hpmax/2)
	local mon=is_monster_at(54,20)	
	if mon then mon:remove_monster() end
	active_text={
		"your soul was restored thanks",
		"to the wizard essence you",
		"carry.beware,for it takes",
		"a long time indeed for the",
		"essence to regain its",
		"life-giving powers."
	}
end
-->8
--text

function setup_text()
	texts={}
	add_text(54,19,
		{"long ago all demons were",
			"trapped in a magical mirror",
			"and sealed by the gods.",
			"the mirror was entrusted to",
			"the kings of men for",
			"safekeeping,but it has been",
			"stolen!" 
		})
	add_text(49,20,
		{"we don't know who stole and",
			"shattered the mirror,but",
			"it must have been a sorcerer",
			"of considerable power,and",
			"of great evil."
		})
	add_text(59,20,
		{"the mirror has been shattered",
			"into three shards.you must",
			"find them!"
		})
	add_text(53,21,
		{"it is said that the hero",
			"of the land shall seek out",
			"magical artifacts from the",
			"dawn of time and use them",
			"in the quest to defeat",
			"a great evil.is it a legend",
			"or could it be?..."
		})
	add_text(55,21,{"find the mirror pieces and", "restore peace to the kingdom!"})
	add_text(59,24,
		{"return to me to record your",
			"deeds in the royal chronicle."
		})
	add_text(53,27,
		{"now that the demons fled",
			"the mirror,they roam the land",
			"freely..."
		})	
	add_text(50,23,
		{"talk to everyone you meet!",
			"you never know what insight",
			"they may bring into your",
			"quest!"
		})
	add_text(49,29,
		{"the sage in the village to",
			"the east is very wise.she",
			"may be able to aid you on",
			"your journey."
		})
	add_text(58,27,
		{"there is a healer in the",
		 "eastern village, but he",
		 "will ask for gold to pay",
		 "for the herbs he needs",
		 "to perform his arts."
		})
	add_text(98,38,
		{"i heard that a sword of",
			"a great hero was hidden",
			"somewhere in the northeast",
			"and should the need arise,",
			"another hero shall wield",
			"it in battle."
		})
	add_text(99,34,{
		"three shards of the mirror",
		"were hidden in three dungeons",
		"by the mad sorcerer.",
		"in your quest you will need",
		"a lamp to guide you through",
		"the northern swamps;a boat",
		"to navigate the treacherous",
		"waters of the southern lake;",
  "and an elven cloak to protect",
		"you from the freezing winter",
		"of the icy mountains.",
		"know also this:you cannot", 
		"defeat the sorcerer by force,",
		"you must capture his essence",
		"from wherever it is kept."
	})
	add_text(99,40,{
		"an old druid lives alone",
		"to the southeast of here.",
		"it is said he is the last",
		"keeper of a magic artifact."
	})
	add_text(105,45,{
		"there is another village",
		"to the northwest of the",
		"castle,just south of the",
		"icy mountains.you might",
		"ask around there for",
		"clues as well."
	})
	add_text(110,41,{
		"beware the wasteland to the",
		"south.a mighty behemoth",
		"guards the bridge and the",
		"land is full of dangerous",
		"monsters.but there lies the",
		"lair of the mad sorcerer."
	})
	add_text(103,34,{
		"if you travel around,you",
		"might find some old treasures",
		"buried or locked in chests.",
		"i heard of a magical ring",
		"that will heal the wounds",
		"and soothe the spirit of",
		"its bearer,but i do not know",
		"where it might be hidden."
	})
	add_text(110,35,{
		"there is a stone circle",
		"to the north of here",
		"left by the ancients.",
		"it might be worth visiting."
	})
	add_text(107,33,{
		"there is a shipwright in the",
		"western village.maybe you",
		"could ask him to make",
		"a boat for you."
	})
	add_text(20,26,{
		"if you want to dig something",
		"up, you need a shovel.",
		"look around, someone might",
		"have a spare one."
	})
	add_text(22,20,{
		"if you mend the mirror,",
		"you might be able to trap",
		"the essence of the mad",
		"sorcerer in it. legends",
		"say that the sorcerer",
		"is otherwise immortal",
		"but who knows whether they",
		"are true?"
	})
	add_text(27,27,{
		"some people don't want to",
		"live in villages and they",
		"settle in remote parts of",
		"the land.",
	})
	add_text(27,23,{
		"men cannot comprehend the",
		"magical powers that course",
		"through the land,but the",
		"ancients,who wielded it,",
		"once imbued a simple wand",
		"with terrible destructive",
		"power-whatever the wand",
		"touched was struck as if",
		"by lightning.",
		"if you can find it,",
		"maybe you could use its",
		"powers for good?"
	})
	add_text(25,22,{
		"western village"
	})
	
	add_text(104,38,{
		"eastern village"
	})
end 

function add_text(x,y,message)
	texts[x+y*128]=message
end

function get_text(x,y)
	return texts[x+y*128]
end

function draw_text()
	if active_text then
		text_x=map_x*8+4
		text_y=map_y*8+48-flr(#active_text/2)*6
		
		rectfill(text_x-2,text_y-2,text_x+121,text_y+#active_text*6+14,0)
		rectfill(text_x-1,text_y-1,text_x+120,text_y+#active_text*6+13,6)
		rectfill(text_x,text_y,text_x+119,text_y+#active_text*6+12,0)

		for i=1,#active_text do
			print(active_text[i],text_x+4,text_y+4+((i-1)*6),9)			
		end

		print("—",text_x+110,text_y+#active_text*6+sin(time()*2)+6,6)
	end
	
	if btnp(—) and active_text then
		active_text=nil
		sfx(58)
	end
end


function message(text,duration)
	active_message=text
	message_timer=duration*30
end

-->8
--monsters

function make_monster(x,y,kind)
	local monster={
		x=x,
		y=y,
		hp=kind.hp,
		hpmax=kind.hp,
		atk=kind.atk,
		def=kind.def,
		spd=kind.spd,
		xp=kind.xp,
		floater=kind.floater,
		gold=kind.gold,
		move_counter=0,
		sprite=kind.sprite,
		move=move_monster,
		check_dir=determine_dir,
		die=remove_monster,
		attack=attack,
		pal_swap=false
	}

	return monster
end

function make_tough_monster(x,y,kind)
	local monster={
		x=x,
		y=y,
		hp=kind.hp*2,
		hpmax=kind.hp*2,
		atk=kind.atk+2,
		def=kind.def+2,
		spd=max(1,kind.spd-1),
		xp=kind.xp*2,
		floater=kind.floater,
		gold=kind.gold*2,
		move_counter=0,
		sprite=kind.sprite,
		move=move_monster,
		check_dir=determine_dir,
		die=remove_monster,
		attack=attack,
		pal_swap=true
	}

	return monster
end

function move_monster(mon,mov_x,mov_y)
	if is_dungeon() and dist(plr.x,plr.y,mon.x,mon.y)>4 then
		return
	end
	if not is_dungeon() and mon.x<16 then
		return
	end
	mon.move_counter+=1

	local tx,ty=mon.x+mov_x,mon.y+mov_y
	if plr.x==tx and plr.y==ty then
		mon:attack(plr)
		if not attacked then
			sfx(60)			
		end

	elseif is_walkable(tx,ty,{is_floater=mon.floater}) and	mon.move_counter%mon.spd==0 and not is_monster_at(tx,ty) then
		mon.x+=mov_x
		mon.y+=mov_y
	end
end

function determine_dir(monster)
	local mx,my,px,py=monster.x,monster.y,plr.x,plr.y
	local mov_x,mov_y,tdist=0,0,999

	for i=1,4 do
		local tx,ty=mx+dirs.x[i],my+dirs.y[i]
		local new_dist=dist(tx,ty,px,py)
		if new_dist<=tdist and 
					is_walkable(tx,ty,{is_floater=monster.floater}) and 
					not is_monster_at(tx,ty) then
			tdist=new_dist
			mov_x,mov_y=dirs.x[i],dirs.y[i]
		end
		if is_player_at(tx,ty) then
			return dirs.x[i],dirs.y[i]
		end
	end	

	return mov_x,mov_y
end

function is_player_at(x,y)
	return x==plr.x and y==plr.y
end

function draw_monster(monster)
	if monster.pal_swap then
		pal(8,5)
	end
	palt(0,false)
	spr(monster.sprite,
		monster.x*8,monster.y*8)
	pal()
end

function remove_monster(self)
	del(monsters,self)
end

function move_monsters()
	for m in all(monsters) do
		if not is_safe() or not is_out_of_screen(m.x,m.y) then 
			m:move(m:check_dir())
		end
	end
end

function get_random_enemy()
	local pool,mon,mon_data=map_areas[map_area_index()+1]

	if not pool then
		return nil
	end
	mon=rnd(pool)

	mon_data=monster_types[mon]

	return mon_data
end

function spawn_random_monster()
	local mon=get_random_enemy()
	local x,y=get_random_border_tile()
	if mon and x then
		add(monsters,make_monster(x,y,mon))
	end
end
-->8
--data

monster_types={
	imp={
		hp=8,
		atk=0,
		def=0,
		spd=2,
		xp=1,
		gold=1,
		sprite=48
	},
	bandit={
		hp=12,
		atk=1,
		def=0,
		spd=2,
		xp=2,
		gold=2,
		sprite=49
	},
	zombie={
		hp=15,
		atk=1,
		def=2,
		spd=3,
		xp=3,
		gold=3,
		sprite=50
	},
	octopus={
		hp=17,
		atk=2,
		def=1,
		spd=1,
		xp=4,
		gold=3,
		sprite=51,
		floater=true
	},
	spider={
		hp=14,
		atk=1,
		def=1,
		spd=1,
		xp=5,
		gold=2,
		sprite=52
	},
	scorpion={
		hp=18,
		atk=2,
		def=1,
		spd=2,
		xp=6,
		gold=3,
		sprite=53
	},
	swarm={
		hp=18,
		atk=2,
		def=2,
		spd=1,
		xp=7,
		gold=2,
		sprite=54,
		floater=true
	},
	demon={
		hp=25,
		atk=3,
		def=3,
		spd=1,
		xp=10,
		gold=4,
		sprite=55
	},
	drake={
		hp=20,
		atk=4,
		def=3,
		spd=1,
		xp=15,
		gold=4,
		sprite=59
	},
	giant={
		hp=30,
		atk=4,
		def=4,
		spd=3,
		xp=20,
		gold=5,
		sprite=60
	},
	blob={
		hp=15,
		atk=2,
		def=4,
		spd=3,
		xp=10,
		gold=10,
		sprite=61
	},
	bat={
		hp=10,
		atk=3,
		def=1,
		xp=10,
		spd=1,
		gold=3,
		floater=true,
		sprite=62
	},
	behemoth={
		hp=40,
		atk=3,
		def=3,
		spd=0,
		xp=15,
		gold=15,
		sprite=56
	},
	darklord={
		hp=70,
		atk=4,
		def=4,
		spd=2,
		xp=20,
		gold=0,
		sprite=58
	}
}

weapons={
	nil,
	nil,
	"sword",
	"master sword",
	"elven sword",
	"truesteel sword",
	"moonsteel sword"
}

shields={
	"shield",
	"hero's shield",
	"shield of kings",
	"dwarven shield",
	"shield of giants"
}

map_areas={
	nil,--0
	{"bandit","bandit","imp","zombie","spider","bat","giant"},
	{"bandit","bandit","imp","zombie","spider","bat","giant"},
	{"imp","imp","imp","bandit","spider"},
	{"spider","spider","swarm","octopus","blob"},
	{"imp","imp","imp","bandit","spider"},
	{"imp","imp","imp","bandit","spider"},
	{"imp","imp","imp","bandit","spider"},	
	nil,--8
	nil,
	{"imp","imp","imp","bandit","spider"},	
	nil,
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	nil,--16
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	nil,
	{"imp","imp","imp","bandit","spider"},	
	nil,--24
	{"spider","spider","swarm","octopus","octopus","octopus","blob","bat","bat"},
	{"spider","spider","swarm","octopus","octopus","octopus","blob","bat","bat"},
	{"scorpion","scorpion","zombie","zombie","octopus","octopus","demon","drake"},
	{"scorpion","scorpion","zombie","zombie","octopus","octopus","demon","drake"},
	{"imp","imp","imp","bandit","spider"},	
	{"imp","imp","imp","bandit","spider"},	
	nil
}

map_danger={
	0,
	0.1,
	0.1,
	0.05,
	0.1,
	0.05,
	0.05,
	0.05,
	0,
	0,
	0.05,
	0,
	0.05,
	0.05,
	0.05,
	0.05,
	0,
	0.05,
	0.05,
	0.05,
	0.05,
	0.05,
	0,
	0.05,
	0,
	0.1,
	0.1,
	0.15,
	0.15,
	0.05,
	0.05,
	0
}

interactive_objects={
	{
		x=123,
		y=60,
		text_before={
			"this lamp will ensure",
			"that you don't get lost",
			"in the deadly swamps of",
			"the north."
		},
		text_after={
			"remember,the lamp you",
			"have will guide you through",
			"the northern swamps."
		},
		action=function()
		 take_item("lamp") 
		 sfx(56)
		end,
		sprite_before=7,
		sprite_after=7
	},
	{
		x=124,
		y=3,
		text_before={
			"you found a master sword!"
		},
		action=function() add_weapon(4) end,
		sprite_before=19,
		sprite_after=20
	},
	{
		x=72,
		y=3,
		action=function() end,
		sprite_before=32,
		sprite_after=17,
		text_before={
			"abandoned ruin"
		}
	},
	{
		x=7,
		y=3,
		action=function() take_item("shard_left") end,
		sprite_before=19,
		sprite_after=20,
		text_before={
			"you found a mirror shard!"
		}
	},
	{
		x=109,
		y=45,
		sprite_before=7,
		sprite_after=7,
		text_before={
			"let me heal your wounds!"
		},
		action=heal,
		repeatable=true
	},
	{
		x=98,
		y=46,
		sprite_before=8,
		sprite_after=8,
		text_before={
			"this shield has been the",
			"pride of my family for",
			"generations.please,take",
			"it.may it aid you in your",
			"quest to mend the magic",
			"mirror."
		},
		text_after={
			"go forth and put the shield",
			"to good use!"
		},
		action=function() add_armor(1) end
	},
	{
		x=29,
		y=18,
		sprite_before=8,
		sprite_after=8,
		text_before={
			"yes,i can build you a boat",
			"for 100 gold pieces."
		},
		text_after={
			"i hope this boat serves",
			"you well!"
		},
		action=function(self)
			if plr.gold>=100 then
			
				take_item("boat")
				plr.gold-=100
				sfx(56)
				active_text={
					"here is your boat,i'll",
					"take the 100 gold pieces."
				}
			else
				self.touched=false
			end
		end
	},
	{
		x=99,
		y=7,
		text_before={
			"the ground here is unusual."
		},
		sprite_before=85,
		sprite_after=86,
		action=function(self)
			if inventory.shovel then
				inventory.cloak=true
				active_text={
					"you found an elven cloak!"
				}
				sfx(56)
			else
				self.touched=false
				self.text_before={
					"looks like someone has been",
					"digging here."
				}
			end
		end
	},
	{
		x=60,
		y=2,
		sprite_before=8,
		sprite_after=8,
		text_before={
			"i can sell you this shovel",
			"for 50 gold pieces"
		},
		text_after={
			"i hope you dig up something",
			"valuable!"
		},
		action=function(self)
			if plr.gold>=50 then
				take_item("shovel")
				plr.gold-=50
				sfx(56)
				active_text={
					"here's the shovel, and",
					"i'll take the 50 gold."
				}
			else
				self.touched=false
			end
		end
	},
	{
	 x=53,
	 y=52,
	 sprite_before=34,
	 sprite_after=40,
	 text_before={
	 	"lair of the mad sorcerer"
	 },
	 action=function() end
	},
	{
		x=59,
		y=24,
		sprite_before=8,
		sprite_after=8,
		repeatable=true,
		action=function() 
			save_game() 
			sfx(56)
		end,
		text_before={
			"return to me to record your",
			"deeds in the royal chronicle.",
			"(game saved)"
		}
	},
	{
		x=9,
		y=27,
		action=function() take_item("shard_middle") end,
		sprite_before=19,
		sprite_after=20,
		text_before={
			"you found a mirror shard!"
		}
	},
		{
		x=0,
		y=32,
		action=function() take_item("shard_right") end,
		sprite_before=19,
		sprite_after=20,
		text_before={
			"you found a mirror shard!"
		}
	},
	{
	 x=19,
	 y=02,
	 sprite_before=32,
	 sprite_after=17,
	 text_before={
	 	"ice maze"
	 },
	 action=function() end
	},
	{
	 x=27,
	 y=55,
	 sprite_before=32,
	 sprite_after=17,
	 text_before={
	 	"flooded tunnels"
	 },
	 action=function() end
	},
	{
		x=17,
		y=58,
		sprite_before=85,
		sprite_after=86,
		text_before={
			"the ground here is unusual"
		},
		action=function(self)
			if inventory.shovel then
				add_weapon(5)
				active_text={
					"you found an elven sword!"
				}
				sfx(56)
			else
				self.touched=false
			end
		end
	},
	{
		x=29,
		y=1,
		text_before={
			"you found the shield of the",
			"ancient kings!"
		},
		action=function() add_armor(2) end,
		sprite_before=19,
		sprite_after=20
	},
	{
		x=4,
		y=46,
		text_before={
			"you find the ancient wand!"
		},
		action=function() 
			take_item("wand")
		end,
		sprite_before=19,
		sprite_after=20
	},
		{
		x=15,
		y=11,
		text_before={
			"you find the life essence!"
		},
		action=function() 
			take_item("essence")
		end,
		sprite_before=19,
		sprite_after=20
	},
	{
		x=8,
		y=23,
		text_before={
			"you found the ring",
			"of the wizards!"
		},
		action=function() 
			take_item("ring")
			sfx(56)
		end,
		sprite_before=19,
		sprite_after=20
	},
	{
		x=8,
		y=55,
		text_before={
			""
		},
		action=function() 
			active_text=is_mirror_whole() and
			{
				"finally,you face the mad",
				"sorcerer himself.his evil",
				"presence makes you nauseous",
				"but you feel the mirror",
				"of destiny resonate with",
				"the forgotten magic of the",
				"ancients.the sorcerer steps",
				"forward and hesitates,just",
				"for a split second,but",
				"this gives you confidence",
				"in your ability to defeat",
				"him once and for all!"
			} or
			{
				"finally,you face the mad",
				"sorcerer himself.his evil",
				"presence makes you nauseous",
				"and the mirror shards you",
				"have resonate with faint",
				"traces of power.",
				"something feels wrong..."
			}
		end,
		sprite_before=119,
		sprite_after=117
	},
	{
		x=98,
		y=38,
		text_before={
			"this old pickaxe? you can",
			"have it.maybe it will aid",
			"you in your journey."
		},
		action=function()
			take_item("pickaxe")
			sfx(56)
		end,
		text_after={
			"have you found any use",
			"for the pickaxe?"
		},
		sprite_before=8,
		sprite_after=8
	},
	{
		x=66,
		y=2,
		text_before={
			"this spot looks unusual"
		},
		action=function(self)
			if inventory.pickaxe then
				active_text={
					"you break the rock with",
					"the pickaxe!"
				}
			else
				self.touched=false
			end
		end,
		sprite_before=71,
		sprite_after=17
	},
	{
		x=49,
		y=62,
		sprite_before=57,
		sprite_after=57,
		text_before={
			"we,dwarves,usually don't",
			"go out to the surface,but",
			"i have been chosen to stand",
			"watch and bestow this finely",
			"crafted shield upon the hero",
			"who is questing to mend the",
			"magic mirror."
		},
		text_after={
			"did you know that the frame",
			"of the mirror was fashioned",
			"from moonsteel by a dwarven",
			"smith? seek a weapon made",
			"from the same metal and you",
			"shall prevail over all foes!"
		},
		action=function()
			add_armor(3)
		end
	},
	{
		x=36,
		y=55,
		text_before={
			"this boulder looks unusual"
		},
		action=function(self)
			if inventory.pickaxe then
				active_text={
					"you find the truesteel sword!"
				}
				add_weapon(6)
			else
				self.touched=false
			end
		end,
		sprite_before=87,
		sprite_after=86
	},
	{
		x=22,
		y=16,
		text_before={
			"this spot looks unusual"
		},
		action=function(self)
			if inventory.pickaxe then
				active_text={
					"you break the rock with",
					"the pickaxe!"
				}
			else
				self.touched=false
			end
		end,
		sprite_before=63,
		sprite_after=17
	},
	{
		x=83,
		y=42,
		sprite_before=85,
		sprite_after=86,
		text_before={
			"the ground here is unusual"
		},
		action=function(self)
			if inventory.shovel then
				add_weapon(7)
				active_text={
					"you found a moonsteel sword!"
				}
				sfx(56)
			else
				self.touched=false
			end
		end
	},
	{
		x=8,
		y=49,
		sprite_before=44,
		sprite_after=44,
		text_before={
			""
		},
		action=function(self)
			if is_mirror_whole() then
				good_ending=true
				music(34)
				_draw=draw_ending
				_update=update_ending
			else
				self.touched=false
				active_text={
					"the shards you have resonate",
					"with the altar,but something",
					"seems to be missing..."
				}
			end
		end
	}
}

stairs_list={
	{
		--dungeon 1
		from=location_index(72,3),
		to=location_index(0,15)
	},
	{
		--back
		from=location_index(0,15),
		to=location_index(72,3)
	},
	{
		--dungeon 4
		from=location_index(53,52),
		to=location_index(8,63)
	},
	{
		--back
		from=location_index(8,63),
		to=location_index(53,52)
	},
	{
		--dungeon 2
		from=location_index(19,2),
		to=location_index(0,16)
	},
	{
		--back
		from=location_index(0,16),
		to=location_index(19,2)
	},
		{
		--dungeon 3
		from=location_index(27,55),
		to=location_index(8,39)
	},
	{
		--back
		from=location_index(8,39),
		to=location_index(27,55)
	},
	{
		--to gold chest
		from=location_index(66,2),
		to=location_index(27,1)
	},
	{
		--back
		from=location_index(27,1),
		to=location_index(66,2)
	},
	{
		--to hidden river
		from=location_index(22,16),
		to=location_index(70,46)
	},
	{
		--back
		from=location_index(70,46),
		to=location_index(22,16)
	}
}

dungeon_coords={
	location_index(0,0),
	location_index(0,16),
	location_index(0,32),
	location_index(0,48)
}

dungeon_monsters={
	{8,1,"bandit","t"},
	{1,1,"bandit"},
	{2,1,"bandit"},
	{14,0,"spider"},
	{5,7,"bandit"},
	{15,11,"zombie"},
	{6,15,"imp","t"},
	{10,14,"zombie"},
	{5,16,"spider"},
	{9,18,"giant"},
	{9,24,"bandit","t"},
	{14,22,"imp","t"},
	{0,19,"bandit","t"},
	{9,30,"zombie","t"},
	{14,28,"zombie"},
	{1,29,"bandit"},
	{3,23,"giant"},
	{13,37,"swarm"},
	{4,36,"scorpion"},
	{11,33,"spider","t"},
	{2,33,"octopus"},
	{5,41,"imp","t"},
	{6,47,"swarm"},
	{10,47,"swarm"}
}

svkeys={
	hp=0,
	hpmax=1,
	lvl=2,
	xp=3,
	gold=4,
	atk=5,
	def=6,
	lamp=7,
	boat=8,
	shovel=9,
	cloak=10,
	shardl=11,
	shardm=12,
	shardr=13,
	exists=14,
	pickaxe=15,
	ring=16,
	wand=17,
	essence=18
}

win_text={
	"as the mad sorcerer falls,you",
 "catch his escaping essence",
 "inside the mirror of destiny.",
	"the mirror vibrates with the",
	"incredible power trapped within.",
	"the land is once again free of",
	"demonic presence and you can go ",
	"back home a hero!",
	"",
	"dedicated to the memory of ben",
	"daglish, whose incredible c64",
	"tunes inspired dreams of fantasy",
	"and adventure in the 10 year",
	"old me.thank you for playing!"
}

fail_text={
	"as the mad sorcerer falls,his",
	"essence escapes and solidifies",
	"as a demon of incredible power.",
	"without the magic of the mirror",
	"of destiny you are unable to",
	"stop it and its shadow falls",
	"over the land which shall",
	"never be free again.this is",
	"the end of the magic kingdom.",
	"",
	"better luck next time!",
	"",
	"...and thank you for playing."
}

final_tough_monsters={
	"bat",
	"spider",
	"zombie",
	"octopus"
}

final_monsters={
	"demon",
	"drake",
	"scorpion"
}
-->8
--utils

function dist(fx,fy,tx,ty)
	local dx,dy=fx-tx,fy-ty
	return sqrt(dx*dx+dy*dy) 
end

function init_transition()
	t_cover=0
end

function transition_out()
	music(-1,300)
	local x,y=map_x*8,map_y*8
	while t_cover<128 do
		rectfill(x,y,x+t_cover,y+127,0)
		t_cover+=4
		flip()
	end
end

function transition_in()
	local x,y=map_x*8,map_y*8
	if t_cover>0 then
		rectfill(x,y,x+t_cover,y+127,0)
		t_cover-=4
	end
end
-->8
--ui

function draw_status_bar()
	local x,y=map_x*8+4,plr.y%16>7 and map_y*8+4 or map_y*8+112
	draw_framed_rect(x,y,40,10)
	print("hp: "..plr.hp.."/"..plr.hpmax,x+3,y+3,10)
	framed_text("—:stats",x+86,y+3,6)
	if inventory.wand then
		framed_text("Ž:wand",x+50,y+3,is_wand_active() and 6 or 2)
	end
end

function draw_stats()
	local x,y=map_x*8+4,map_y*8+20
	draw_framed_rect(x,y,120,80)
	print("level:  "..plr.lvl,x+3,y+3,6)
	print("xp:     "..plr.xp,x+3,y+9,6)
	print("next:   "..next_lvl(plr.lvl),x+3,y+15,6)
	print("power:   "..plr.atk-2,x+70,y+9,6)
	print("defense: "..plr.def+1,x+70,y+15,6)
	print("gold:    "..plr.gold,x+70,y+3,6)
	
	print("weapon: "..weapons[plr.atk],x+3,y+27,6)
	print("shield: "..shields[plr.def+1],x+3,y+33,6)
	print("items",x+3,y+42,9)
	if inventory.lamp then
		spr(21,x+4,y+52)
	end
	if inventory.boat then
		spr(18,x+19,y+52)		
	end
	if inventory.cloak then
		spr(22,x+34,y+52)		
	end
	if inventory.shovel then
		spr(23,x+49,y+52)		
	end
	if inventory.pickaxe then
		spr(24,x+64,y+52)
	end
	if inventory.ring then
		spr(41,x+79,y+52)
	end
	if inventory.wand then
		if not is_wand_active() then pal(10,2) end
		spr(42,x+94,y+52)
		pal()
	end
	if inventory.essence then
		if not is_essence_active() then pal(10,2) end	
		spr(43,x+109,y+52)
		pal()
	end
	if is_mirror_whole() then
		--spr(35,x+19,y+70)
		sspr(24,16,8,8,x+56,y+62,16,16)
	else 
		if inventory.shard_left then
			spr(36,x+3,y+70)
		end
		if inventory.shard_middle then
			spr(37,x+19,y+70)
		end
		if inventory.shard_right then
			spr(38,x+36,y+70)
		end
	end
	print("—",x+110,y+72+sin(time()*2),6)
end

function draw_hp_bar(ent)
	if ent.hp>=ent.hpmax then
		return
	end
	local w,wmax=ceil(ent.hp*(8/ent.hpmax)),8
	local x,y=ent.x*8,ent.y*8
	rectfill(x-2,y-5,x+wmax,y-3,0)
	line(x-1,y-4,x+w-1,y-4,9)	
end

-->8
--story progression

function init_story()
	inventory={
		boat=false,
		cloak=false,
		lamp=false,
		shovel=false,
		pickaxe=false,
		ring=false,
		wand=false,
		essence=false,
		shard_left=false,
		shard_middle=false,
		shard_right=false
	}	
	init_interactive_objs()
end

function take_item(item)
		inventory[item]=true
end

function init_interactive_objs()
	story_map={}
	for obj in all(interactive_objects) do
		local obj_index=location_index(obj.x,obj.y)
		mset(obj.x,obj.y,obj.sprite_before)
		story_map[obj_index]=obj
		story_map[obj_index].touched=false
		story_map[obj_index].index=obj_index		
	end
end

function init_stairs()
	stair_map={}
	for stair in all(stairs_list) do
		stair_map[stair.from]=stair.to
	end 
end

function is_mirror_whole()
	return inventory.shard_left and
							 inventory.shard_middle and 
							 inventory.shard_right
end
-->8
--dungeons

function populate_dungeons()
	for item in all(dungeon_monsters) do
		local x,y,kind,tough=item[1],item[2],item[3],item[4]
		local make_function=tough and make_tough_monster or make_monster
		add(monsters,make_function(x,y,monster_types[kind]))
	end
end

function make_dungeon_fog()
	fog={}
	for i=1,4 do
		fog[i]={}
		for x=1,16 do
			fog[i][x]={}
			for y=1,16 do
				fog[i][x][y]=true
			end
		end
	end
end

function is_dungeon()
	for i,dun in pairs(dungeon_coords) do
		if location_index(map_x,map_y)==dun then
			return i
		end
	end
	return false
end

function is_final_dungeon()
	return is_dungeon() and map_y>47
end

function final_dungeon_update()
	final_dungeon_turn+=1
	if final_dungeon_turn>=10 then
		final_dungeon_turn=0
		for i=0,1 do
			local tough=rnd()<0.5
			local mon_table=tough and final_tough_monsters or final_monsters
			local make_function=tough and make_tough_monster or make_monster			
			mon=rnd(mon_table)
			add(monsters,make_function(7+i*2,53,monster_types[mon]))			
		end
	end
end
-->8
--game screens


function init_game()
	setup_vars()
 setup_map()
	make_player()
	setup_text()
	init_story()
	init_stairs()
	make_dungeon_fog()
	initialize_special_monsters()
	populate_dungeons()
	init_transition()
	init_title()
end

function setup_map()
 map_x=0
 map_y=0
 player_in_dungeon=false
end

function setup_vars()
 stats_mode=draw_status_bar
 monsters={}
 debug={}
 game_over_pos=140
 --used to track the actions
 --of certain items
 ring_turn=1
 wand_turn=100
 essence_turn=200
 final_dungeon_turn=0
 
 active_message=""
 message_timer=0
end

function init_title()
	music()
	title_cursor=0
	_draw=draw_title
	_update=update_title
end

function initialize_special_monsters()
	behemoth=make_monster(77,53,monster_types.behemoth)
	add(monsters,behemoth)
	dark_lord=make_monster(8,52,monster_types.darklord)
	add(monsters,dark_lord)
end

function draw_title()
	clear_screen()
	spr(72,36,36,8,3)
	spr(120,39,61,8,1)
	shadow_text("new game",50,80,title_cursor==0 and 10 or 5,title_cursor==0 and 4 or 0)
	shadow_text("continue",50,87,title_cursor==1 and 10 or 5,title_cursor==1 and 4 or 0)
	print("a game by president of space",10,110,9)
	transition_in()
end

function update_title()
	if (btnp(”) or btnp(ƒ)) and save_exists() then
		sfx(55)
		title_cursor=title_cursor==0 and 1 or 0
	end
	if btnp(—) or btnp(Ž) then
		sfx(56)
		if title_cursor==0 and save_exists() then
			_draw=draw_title_overwrite
			_update=update_title_overwrite
			return
		elseif title_cursor==0 then
			save_game()
		else
			load_game()
		end
		_draw=draw_game
		_update=update_game
		transition_out()
		set_camera()
		resume_music()
	end
end

function draw_title_overwrite()
	clear_screen()
	spr(72,36,36,8,3)
	spr(120,39,61,8,1)
	print("there is a game in progress",14,74,8)
	print("overwrite?",48,84,9)
	print("yes",60,94,title_cursor==0 and 10 or 5)
	print("no",62,100,title_cursor==1 and 10 or 5)
end

function update_title_overwrite()
	if (btnp(”) or btnp(ƒ)) then
		sfx(55)
		title_cursor=title_cursor==0 and 1 or 0
	end
	if btnp(—) or btnp(Ž) then
		sfx(56)
		if title_cursor==0 then
			save_game()
			_draw=draw_game
			_update=update_game
			transition_out()
			set_camera()
			resume_music()
		else
			_draw=draw_title
			_update=update_title
			title_cursor=0
		end
	end
end


function draw_game()
	clear_screen()
	draw_map()
	set_camera()
	draw_player()
	draw_all_monsters()
	draw_fog()
	unfog()
	draw_text()
	stats_mode()	
	draw_debug()
	draw_message()
	transition_in()
end


function draw_game_over()
	clear_screen()
	cls()
	camera()
--	print("game over",50,60,8)
	spr(9,50,flr(game_over_pos/2),4,2)
end

function update_game_over()
	game_over_pos=max(100,game_over_pos-1)
	if btnp(—) or btnp(Ž) then
		transition_out()
		init_game()
	end
end

function draw_ending()
	clear_screen()
	end_message=good_ending and
		{13,25,125,9,28,10,123,14,15,10,123,124,25,125,122,29} or
		{126,25,14,31,30,10,124,15,12,120,29}
	message_x=good_ending and 0 or 3
	end_text=good_ending and win_text or fail_text
	if not good_ending then
		pal(13,9)
		pal(1,4)
	else 
		pal(8,13)
		pal(13,12)		
		pal(5,1)
	end
	camera()
	for i,letter in pairs(end_message) do
			spr(letter,(i-1+message_x)*8,10)
	end
	for i,txt_line in pairs(end_text) do
		shadow_text(txt_line,0,20+i*7,8,5)
	end
	pal()
	palt(0,false)
	transition_in()
end

function update_ending()
	if btnp(—) or btnp(Ž) then
		transition_out()
		init_game()
	end	
end
-->8
--save and load

function init_storage()
	cartdata("president_shards_of_destiny")
end

function save_game()
	dset(svkeys.exists,100)
	dset(svkeys.hp,plr.hp)
	dset(svkeys.hpmax,plr.hpmax)
	dset(svkeys.atk,plr.atk)
	dset(svkeys.def,plr.def)
	dset(svkeys.lvl,plr.lvl)
	dset(svkeys.xp,plr.xp)
	dset(svkeys.gold,plr.gold)
	dset(svkeys.lamp,inventory.lamp and 1 or 0)
	dset(svkeys.boat,inventory.boat and 1 or 0)
	dset(svkeys.shovel,inventory.shovel and 1 or 0)
	dset(svkeys.pickaxe,inventory.pickaxe and 1 or 0)
	dset(svkeys.ring,inventory.ring and 1 or 0)
	dset(svkeys.wand,inventory.wand and 1 or 0)
	dset(svkeys.essence,inventory.essence and 1 or 0)
	dset(svkeys.cloak,inventory.cloak and 1 or 0)
	dset(svkeys.shardl,inventory.shard_left and 1 or 0)
	dset(svkeys.shardm,inventory.shard_middle and 1 or 0)
	dset(svkeys.shardr,inventory.shard_right and 1 or 0)
end


function load_game()
	plr.hp=dget(svkeys.hp)
	plr.hpmax=dget(svkeys.hpmax)
	plr.atk=dget(svkeys.atk)
	plr.def=dget(svkeys.def)
	plr.lvl=dget(svkeys.lvl)
	plr.xp=dget(svkeys.xp)
	plr.gold=dget(svkeys.gold)
	inventory.lamp=load_bool(svkeys.lamp)
	inventory.boat=load_bool(svkeys.boat)
	inventory.shovel=load_bool(svkeys.shovel)
	inventory.pickaxe=load_bool(svkeys.pickaxe)
	inventory.ring=load_bool(svkeys.ring)
	inventory.wand=load_bool(svkeys.wand)
	inventory.essence=load_bool(svkeys.essence)
	inventory.cloak=load_bool(svkeys.cloak)
	inventory.shard_left=load_bool(svkeys.shardl)
	inventory.shard_middle=load_bool(svkeys.shardm)
	inventory.shard_right=load_bool(svkeys.shardr)
end

function load_bool(key)
	return dget(key)==1 and true or false
end

function save_exists()
	return dget(svkeys.exists)==100
end
__gfx__
000000000a0aaa00090909000999000000990000909990000099000009990000009900000ddddd000ddddd00d00000d00dddddd00ddddd00d00000d0d0000000
000000000a0a0a0009999900090900900099000090909000009900000909009000990000dd111dd0dd111dd0dd000dd0d1111110dd111dd0d00000d0d0000000
007007000a0aaaa009090900099900900999900090999090099990000999009009999000d1000110d10001d0d1d0d1d0d0000000d1000110d00000d0d0000000
00077000aaaa00a009000900099999909099090099999990909909000999999090990900d000ddd0d00000d0d01d10d0dddd0000d0000000d00000d0d0000000
000770000a0a0aa000999000999900900099000009999990009900009999009000990000d00011d0ddddddd0d00100d0d1110000d0000000d00000d0d0000000
00700700000aaa0009999900999990900900900000999090099990009999909009009000dd000dd0d11111d0d00000d0d0000000dd000dd0d00000d0d0000000
00000000000a0a00009090009999909009009000009090009999990099999090090090001ddddd10d00000d0d00000d01dddddd01ddddd101ddddd10dddddd00
00000000000000000000000000000000000000000000000000000000000000000000000001111100100000101000001001111110011111000111110011111100
9999990099000000000a0000090009000000000000aa00000000000000aaa00000aaa0000ddddd00d00000d00dddddd0dddddd00000d0000ddddddd000000000
909009909900000000aa000009999900555555500a00a00000aaa000000a00000aaaaa00d11111d0d00000d0d1111110d11111d0000d0000d111111000000000
99999990990990000aaa00000000000050000050aaaaaa0000a0a000000a0000a00a00a0d00000d01d000d10d0000000d00000d0000d0000d000000000000000
9900909099099000000a000090090090500000500a0aa0000aa00a00000a0000000a0000d00000d00d000d00dddd0000dddddd10000d0000dddd000000000000
0999999099099090a00a0aa099909990555555500aa0a0000a000a0000aaa000000a0000d00000d001d0d100d1110000d111d000000d0000d111000000000000
0009000099099090aaaaaa0000000000000000000a00a000a000a0a000aaa000000a0000d00000d000d0d000d0000000d0001d0000010000d000000000000000
00090000990990900aaaa0009999999055555550aaaaaa000aaa0aa0000a0000000a00001ddddd10001d10001dddddd0d00001d0000d0000d000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000001111100000100000111111010000010000100001000000000000000
0999990099000000888888000aaaaa000aaaa00000000a00000000000000000044000000000000000000a000aa00aa0000000000044444000000000000000000
999999909900000080080880a000a0a0a00aa00000000aa0000000000000000044000000000a0000000aa0a00a00a00000000000044444000000000000000000
900090909909900088888880a0000aa0a0aa00000000aaa00000000000000000440440000aaaa000000a0a000a00a00000000000000000000000000000000000
999999909909909080008080aa0000a0aa00000000aaa0a0000000000000000044044000a00aaa0000aaa000a0000a0009999990004440000000000000000000
909000909909909088888880a0a000a0a00000000aa00a0000000aa00000000044044040a000a0000aa00000a0000a0099999900004440000000000000000000
999999900000000080800080a00000a000000000a000a0000000a0a000000000440440400a00a000aa000000aaaaaa0000000000000000000000000000000000
9000009099099090088888800aaaaa00000000000aaa00000000aa00000000004404404000aa0000a00000000aaaa00009999000044444000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808880000088800008888800000000000088000000000000008880008088808000000000008880000008000000888000000000000080800000070000
80888080808080000808080080888080000000000800000000880000088888008888888009000900080808000888880000808000000000008088808000707000
88888880808880800080800080080080008008008000000000800800808880808808088009999900088088800088088088808880008800008808088000077700
88080880088888800080800088888880080880808080000000008800800800808888888009090900008080808008888088888880080088008888888000000700
08888800008880800808080008880800800800800888000008800000888088808888888009999900008888808088800088888880808000800888880000700000
80808080008080000008000088888880808080800888880008000800888888808088808009999900008880808008880080888080800000800088800077000070
00808000008080000080800080808080808080808080800000008800080008008080808000909000088880800888800080808080088888000008000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000333000000000600000500006660666004440400000000400005000000ddddd00dd0000dd000000dddd00000ddddddd0000dddddd00000ddddd00000
00000000333003000000000000505000000000004404044040000000005000000dddddd00dd0000dd00000dddddd0000dddddddd000ddddddd000dddddd00000
0005000003303330000600000500050060666060440404000004000000000500ddd000000dd0000dd0000ddd00ddd000dd0000ddd00dd000ddd0ddd000000000
0000000000003330600000000500050000000000044004400000000005000500dd00ccc00dd0000dd0000dd0000ddd00dd00000dd00dd0c00dd0dd00ccc00000
0000005003303300000000605000005066606660440044400000004050000050dd0c00000dd0000dd000ddd0000ddd00dd00000dd00dd00c0dd0dd0c00000000
0000000033300000000000005000005000000000440404404000000000000000dd0000000dd0000dd000dd000000dd00dd00000dd00dd0000dd0dd0000000000
0500000033000000060000000000000060666060040444000004000000000000ddd000000dddddddd000dd000000dd00dd00000dd00dd0000dd0ddd000000000
00000000000000000000000000000000000000000000000000000000000000000dddd0000dddddddd000dddddddddd00dd0000ddd00dd0000dd00dddd0000000
050505000066000000000000002000000000500000000000500000500066000000dddd000dd0000dd000dddddddddd00dddddddd000dd0000dd000dddd000000
50505050066666000000000000220000000000000001000000500500066666000000ddd00dd0cc0dd000dd000000dd00ddddddd0000dd0000dd00000ddd00000
050505006666060000001000202002000000000000000100550555006666060000c00dd00dd0000dd000dd0cccc0dd00dd000ddd000dd0000dd000c00dd00000
5050505066666660000000000202200005000000001000000000050066066660000c0dd00dd0000dd000dd000000dd00dd0c00ddd00dd0000dd0000c0dd00000
050505006066606000000000002202000000050000000000500000506066606000000dd00dd0000dd000dd000000dd00dd00c00dd00dd0000dd000000dd00000
50505050666606600001000000020000050000000100000050000500666606600000ddd00dd0000dd000dd000000dd00dd00000dd00dd000ddd00000ddd00000
0505050006666600100000000002000000000000000001000550505006666000dddddd000dd0000dd000dd000000dd00dd00000dd00ddddddd00dddddd000000
0000000000000000000000000000000000000000000000000000000000000000ddddd0000dd0000dd000dd000000dd00dd00000dd00dddddd000ddddd0000000
c000ccc000000000dd000d000100010050505550100000000dd0ddd0d000ddd00000000000000000000000000000000000000000000000000000000000000000
0ccc00001001000000ddd000101010100000000001001010dd0dd0000ddd00000ccc00000cc0000cc000cc000000cc00cc00000cc000ccccc0000ccc00000000
0000000001100000000000000100010055005550000001000dddddd0000000000000000000000000000000000000000000000000000000000000000000000000
ccc00cc000001010000000000000000000000000000000000dd0ddd0ddd00dd00000000000000000000000000000aa00aaa00000000000000000000000000000
000cc00010000100d0000dd0010001005505505011000000ddddd000000dd000000000000000000000000000000a44a0aa400000000000000000000000000000
cc0000c0011000000dddd000101010100000000000010100dd0dddd0dd0000d0000000000000000000000000000a00a0a4000000000000000000000000000000
00cccc0000001100000000000100010055550550010110000ddddd0000dddd000000000000000000000000000004aa40a0000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440040000000000000000000000000000000
7070070000070000000300000000000007070700500500504440444050050050ddddd0000dddddd00ddddd00ddddddd0000d0000d00000d0d00000d000000000
0700000000777000003330000000700070000070005050000000000000505000d1111d00d1111110d11111d0111d1110000d0000dd0000d01d000d1000000000
0007000007770700003330000000070000707000050005004044404005000500d00001d0d0000000d0000010000d0000000d0000d1d000d00d000d0000000000
7000007007000700033333000000000070000070500500500000000050050050d00000d0dddd00001ddddd00000d0000000d0000d01d00d001d0d10000000000
0700000070000070033333000000000000707000050005004440444005000500d00000d0d1110000011111d0000d0000000d0000d001d0d0001d100000000000
0000700070000070330303307000000070000070005050000000000000505000d0000d10d0000000d00000d0000d0000000d0000d0001dd0000d000000000000
7700007000000000000300000700000007070700500500504044404050050050ddddd1001dddddd01ddddd10000d0000000d0000d00001d0000d000000000000
00000000000000000000000000000000000000000000000000000000000000001111100001111110011111000001000000010000100000100001000000000000
56665656665666566656565666565656340404040404040404042424242424242404040404040404140414140404044444440424044444444444444444141414
14140404040404042404040404041414141404040404060606040404040404040414141404045454545454545454545454040404041514140404040404043434
56565656665666566656565666565656340404040404040404040404141404042424242404040404141414040404040414440424044414141414141414140414
04040404150404042424040404040404040404040404040606150404040404040454545454045454646454406464645454040404140414141404040404343434
66666656665656566666665666565656340404040404252525252514140404040404042424041414140404040404041414440424044414141414141414040404
04041504040414040424242424242424242404041504040606040404040404040454646054045440646454545464645454040414141414141414040404043434
56565656565656565656565656565656340404040404040425252525352525040404040424242424040404040404041414444424444404141414141414040404
04040404041414141414241414040404042424040404040606040404040404040454646454045464646464646464605454041414040415140414140404343434
56566656565666565656665656666656343404040404042525352525252504040404040404040424242424041414141414040424040404041414141424242424
04040404040404141414241414040404040424040404040406060404040404040454546454045454546454545454545454040404141414140414140404043434
56566656565666565656665656566656343434040404252504252535042525252504040404040404140424240404040414242424242404040404242424141424
24040404041504040424241404040404040404240404242405050524040404040404042404040404042404040404040404040414140414141414140404043434
56566666666666565656666666666656343434040404040404252525352525252525040404040414041404242424242424240404042424242424241414140404
24240404140404242424040404040404040404242424240606060624240404040404502404042424012404141414040404040414141414041404141404040434
56565656565656561256565656565656343434040404040425250414141404040404040404141404141424242404040414141414042404041414141414140404
04242424242424240404040404040404141414343404040606060604242424242424242424242424242424240414140404040414141414141414140404043434
56666656666666565656666666565656343404040404040404040404041414141404040414141414042424040404040414141414042404041414141414040404
14040404041404041414040404040414143434343434060606060404040404040404045004242424242424240404040404040404040404041404040404043434
56565656565666565656665656565656343404040404040404040404040404040404141414040404242404040404040414141414042404141414141414041414
14140415041414141414140404041414143404040434340606060414140404040404141414140404042424240404500404040404040404040404040404343434
56666666666666665666666666666656340404040404040404141414140404040404140404040424240404040404040414141414042414141414141414041414
14040404141435351414040404141414343404750434340606060414141404040404140424242424040404242424242424240404040404041504040404343476
56565666565656665666565666565656340404040404040404040414141414141414141404042424040404040404040404141414042404141414140414041414
14141414143514141435043434353534343404040434060606060404041414040404042424040424546454545464540404242424040404040404040404040676
56665656565656565656565656566656340404040404040404040414141414141404040404242404040404141404040404040414042424040404141414041414
14141414353434343434343434343434343434063434340606060404040404040414142414041424546464546464540404040424240404041415040404040676
56665666666666665666666666566656343404040404040404041414141414141414042424240404040414041404040404040404040424041434343414040404
04040434343434340606343406063434060606063434060606060404040404040454546454541424544064646430540404040404240404041415141404040676
56565666565656665666565666565656343434340404040414141414141414141414042424040414040414040404140414343434343434343434343434343414
34343434343411040606060606060606063434343425060606040404141404040454406464541424545454545454540404040404042404040414141404040676
56665666565656565656565666566656343434340404141414141414141414141414040404040414141404040404143434343434343434343434343434343434
34343434343434340606063434343434343425252525060606040404140404040454545454540424040404040404040415150404040424040414140404040676
575757575757d2575757d25757575757343434040404141414141414141414141414040404040404040404040434343434252525252534253434342525252534
34343425343435343434343434343434252525252525250606060404040404040454545454542424040404040404040404040404040424242404140404060676
575757575757d257c257d25757575757343404040414140606141414141414141414140404040404040404040414043434252515252525252525252525253434
34342525253534342435352425352525250606252525060606060404040404040404040404042404040414141404041414141415040404042404140606767676
575757575757d2575757d25757575757341414141414060606060606060606061414060604040406040404040404343434342525352525252535252534343434
25452524454524453535252424242506060606060606060604040404040404141414140404242404141414140404041404041414140404042424041404060676
575757575757d2575757d25757575757341414141406060606060606060606060606060604060606060414040404043434252525252525152525253434342525
25252545253525253525252506050606060606060606060604040404040414140404141404240404140404040404141414141414140404040424241414040676
57575757575757575757575757575757343414140606060606060604040606060606060606060606061414040404343425252525252225252525343434342525
45254535353525252525250606050606060606060606060404040414141414040404041424240414040404040414140404141414040404040404241414140676
67676767675757575757575767676767343414140606060606060414140606060606060606060606060606060404343425252525252525253525252534342525
25353525252525252506060606050606060404060606040404040404040404040404040424240404141404041414040415141414040404040414241414060676
67676767676757575757576767676767343414140606060606041404141406060606060404350406060606060404343434252535252525252525343434252525
35352525252525060606060606050624242404040404040404140404040404040404040424240404041414141404140404141404040404141414240404067676
67676767676767575757676767676767341414140606060606141402041406060606060675040406060606060404043434252525252525252534343425252535
35252525060606060606060604242424042404040404040404140406040404040404242424040404040414040414140414141414141414141404042404040676
67676767676767675767676767676767341414060606060606041404141406060606060606060606060606060404043434342525352525253434342525353525
25252506060606060606060404040404042424140404040404140406060604040404042404040404141414040415040414041414041414040404042404060676
67676767676767675767676767676767343414060606060606060414040606060606060606060606060606061404043434343425252525343425253535252525
25060606060606040404040404040404040424242424241414140406060604040404242404040414140404041414141404141414141404040454546454540676
67676767676767675757575757575767341414060606060606060606060606060606060604060606060606141404043434343425252525252535350425252506
06060606060604040404040404040414040404040404242404040404060606040424240404040404040414140414140404040414140404040454646464540676
67676767676767676767676767675767341414060606060606060606060606061406060404060614040406060414043434252525252525252535353525250606
06060606040404040404040404040614140404040404042424040404060606042404040404040404041415151404040404040614140404040454646454540476
67676767676767675757575757675767341414140606060606060606060614141404141414060614140414060604040434252525253525252525352525060676
06040404040404040604040404040606041414040606040424240404040505240404040404040414141404040406060606060606060606040454646464540676
67676767676767675767676757575767341414141406141414140606141414141404040404040404141414040606060634343425252525250606062525250676
76060406060606060606061414067606060414040606060404242424240506040606060404040404040404040406060606060676060606060454545454540676
67676767676767675767676757576767343414141414143434141414141434140404043434340404040404040434340604933434343406060676760606060676
76060676767676767606060606067676060606060676060606060606060606060606060606060606060606060606767676767676767676760606040406060676
67676767676767671267676767676767343434343434343434343434343434343434343434343434343434343434343434343434347676767676767676767676
76767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676767676
__gff__
0000030303030305050000000000000003100005010000000000000000000000051005000000000010000000050100000000000000000000000500000000000500000001010100040000000000000000000100000005000500000000000000002908010001000101000000000000000008010000010001040000000000000001
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
6363636364636363636363646364636371717171717171717171717171717171717171717170717171717171717171717171714343434343434343434343434343434343434343434343434343434343434343436767676767676767676767676767676767676767676767676767676767676767676767676767676767676767
6363636364636363636363636363636371717170707070717171711173737373737171717171717170707070717170704040714040404040404545454545404343434343434040434340404343434343434343606060606767676760606040404067676760606060404040676767674060606760676060606060606760606067
6363636364636363636363646364636371717020707070707070707171737371717071717171717070727270707170707040404040404040404546464645404343434740405140404040414043434343434340404060606067676060604040406060404040404040404040406767404040606760606040404040606060406067
6363636364636363636363646364636371717070707070707070707071717171707070707171707070727270707070707040404040404040404546454545404343434340404040402040414140404343434343404040606060676060606060606040414140404040404040404040404141606060676040514041414040404343
6463646464646363636364646364646471717170727070707070707272717170707070707171707070707070707070707040424040404040404040404040404343434340404040404040404141404343434343404040406060606060404040414140405141414040404040514040414040406060606040404041404040404343
6363636363636363636363646364636371717170727272707070707070727272727070707171717070707070707070404040404040404040404041404040404343434040404041404040404041404043434340404040406060606060404040414051414140514040404040404040414040404060414040404041404040404343
6364646464646464646464646364636371717070727072707070707070707070727272707171717070727272707070717070404042404040414140404040434343434040404141414051404041404343434040404040406060606060404040414140404040404140404040404040414040404060606740404040404040404043
6363636363636463636363636363636371717070727272707070707070707070707070707171717072727272707070717140404040424040414040404040434343434040404141404040404040404343434340404040406060606060404040405140404040405140404040404040414040404041606741404040404040404043
6463646463636463646363646364646471717070707272727070707272707070707070707171717070707272707071717170404040404040404040404043434343434040414141404040405140404043434340406060406060606060404040404040404040404140404040404040404040404041406060414040514040404343
6363636363636463646464646364636371717072727072727270707072727070707070707071717070707070707071717171404040404240404040404043434343404040414040404040404041414343434340404060606060606060404040404051404040514040404040404040404040514040416060414141404040404043
6363636463636363636364636364636371717070727270707070707072727272707070707070717070707070707071717170404040404240404040404043434343404051404040414141404041414343434340404040404060606060404040404141405140414040414141404040404040404040416040404041414140404043
6464646464646463646464636363636371717070707270707070707072707272727070707070707070727270707071717170404040404240404040404043434343434040404040404141404041414143434340404040404060606040404040404041404040414140404040414040404040404060606040404040404040404043
6363636363636363636363636364636371707070707070717070707072707072727070707072727272727070707071717170404040404242424040404043434343434041414040404141404041414143434340404040404060606060606040404041404040404140404040414140404040404060414040414141404040404343
6363636464646364636464646364636371717070717071717070717170707070707070707272707070707070717171717140404040404040424242404043434343404141405140404141404041414141434343404040404060606060406060604060606060414140404040404141404040404041414141414141404040404343
6464636463636364636363646364646471717171717171717171717171717070707070707070717170707070717171717170404040404040404042424242434361414140404040404040404040414143434340404040404040606060404040606060414060606060414040514041404040404040414040404141404040404343
2163636463636364636363636363636371717171717171717171717171717171707070707071717171717070717170704040404040404040404040434342424361614040404061404061404040406161434340404040404040606060604040404040414040404060606041414141404040404040404140404140404040404043
217373747373747373737373737373737171404071713f717170707171717171717171717171714071717171717070404141414141414141414141434341424161616161616161616161616161616161434340404040404040606060604040404040404040404040416060404040404040404040404151404141404040404043
7373737474737473747474737473737371404040707140407040704545454545704041417140404040407171404040404141414141414141414141414141424100616161616161616161616161616140404040404040404040406060604040404040404040404040404040404141404040404141404041404040414040404043
7474737373737373737373737474747371404040404040407040404546464645404040414140404040404040404040444444444444444444444444444441424040406161614061616161406161616140404040404040404040406060604040404040404040404040404040414041404040404141414040514041404040404043
7373737473747474737373737373737371404040454545454540404546464645404040404041414040404140404040444450504450500250504450504441424240404040404040404040404040404040404040404040404040606060404040404040414140404040404040414140404040404041404040404141404040404343
7373737473737374737474747374747443717140454603464540404546464545404040404040414140404141404040444403505050505050505050044441404240404040404040404040404040404040404040404040404040606060604040404040404041414140514040414140404040405141404040404141414040404343
7374747473737374737473737374737343434340454546454540404242424240404040404040404141404041404040444450504450055005504450504441404240404040404040404040404040404040404040404040404040406060604040404040404141404041414141414140404040404041404040414141404040404343
7374737373747373737473737374737343434040404042424210424242424240404040414141414040414040414040444444444444444244444444444441404240404040404040404040404040404040404040404040404040606060604040404040414140404040404040414140404040404040414040404141404040404043
7374737373747373737373737374737343434340404040404040420542424240404040404040414141404141404040444450045044404240445050504441404240404040404040404040404040404040404040404040404040606060604040404040414140404141404141414140404040404040414040404141404040404043
7373737373747373737373737373737343434345454540404041424240424040404040404040404041404040404040444450505044404242425050044441404242404040404040404040404040404040404040404040404060606060404040404040404040404141414141415140404041414140404140404141404040404043
7474747473737374747474747373737343434045464640404142424546454040404040404040414140404040404040444444424444404240445050504441414042424242404040404040404040404040404040404040406060606060404040404040404040414040404141404040404041404141414141414141404040434343
7373737373747474737373747474737343434045044640414242454646464540404040404040404040404040404141444440424040404240444444444441414140404042424240404040404040404040404040404040406060604040404040404040404040414040404141414040404041414140404140404040404040434343
7373737373747373737373737374737343404045454541424240450646464541414040404040404040404041414140444440424040044240445004504441414140404040424242424240414140404040404040414141606060414141404040404040404041414040414140404041404040414141414140404040404040404343
7474737473747373737373737374737343404040404040424240404545454040404040404040404040404041404140444440424040404240445050504441414141414141414141414241414141414141414141414141606060414141414141414040404041404040404141404040414040414141414141404040404040404343
7373737473747373737373737374737343434040404040404242404040404040404040404040404040404041414040444403424240404240445050504441414141414141414141414241414141414141414141414140606060604040404141414141404041414140414141414141414040414141404141404040404040434343
7373747473747474747374747474737343404040404040404042424240404041404040414040404040404040404040444440404242424242425050504441414141414141414041414241414141414141414140404040406060604040404040414141414140404040404040404040404040404041414041404040404043434343
7373747373737373737373737373737343434340404040404040424240404041414141414040404040414141404040444444404240444444444444444441414141414141404040404240414141414141414140404040606060604040404040414141414140404545454545454545454545404040404041414040404040404343
__sfx__
010d00001802418041180611807118071180711806118061180611805118051180511804118041180411804118041180311803118031180311803118031180211802118021180211802118021180211802118025
010200000c1500c1410c1310c1210c1310c1410c1510c1310c1210c1210c1110c1110c1150c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c100
010d00001811218122181321814218142181421814218142181421814218142181421813218132181321813218132181221812218122181221812218122181221811218112181121811218112181121811218115
010800000401404011040110401104021040210402104021040310403104031040410404104041040510405104051040510404104041040410403104031040310402104021040210402104011040110401104015
01100000180161b0161f0161b016180161b0161f0161b016180161b0161f0161b016180161b0161f0161b016180161b0161f0161b016180161b0161f0161b016180161b0161f0161b016180161b0161f0161b016
010200000c5500c5410c5310c5210c5310c5410c5510c5310c5210c5210c5110c5110c5150c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c5000c500
01100000180161c0161f0161c016180161c0161f0161c016180161c0161f0161c016180161c0161f0161c016180161c0161f0161c016180161c0161f0161c016180161c0161f0161c016180161c0161f0161c016
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200002182221822218222182228822288222682226822288222882228822288222882228822248222482223822238222482224822268222682226822268222682226822268222682226822268222382223822
0112000024822248222382223822218222182221822218221f8221f8221f8221f8222382223822238222382221822218222182221822218222182221822218222182221822218222182221822218222182221822
01120000248222482224822248222b822288222682226822288222882228822268272882726822248222482226822268222682226822268222682224822248222b8222b822288222882224822248222382223822
0112000024822248222382223822218222182221822218221f8221f8221f8221f822238222382223822238221c8221c8221c8221c8221c8221c8221c8221c8222082220822218222182223822238222682226822
0112000024822248222382223822218222182221822218221f8221f8221f8221f8222382223822238222382221822218222182221822218222182221822218222182221822218222182221822218222182221822
01120000158221582215822158221c8221c8221a8221a8221c8221c8221c8221c8221c8221c8221882218822178221782218822188221a8221a8221a8221a8221a8221a8221a8221a8221a8221a8221782217822
011200001882217822178221582215822158221582217822178221782217822188221882217822178251582215822158221582215822158221582215822158221582215822158221582215822158221582215825
011200001ca101ca101ca101ca1024a1024a1023a1023a1024a1024a1024a1024a1024a1024a1021a1021a101fa101fa1021a1021a1023a1023a1023a1023a1023a1023a1023a1023a1023a1023a1021a1021a10
0112000023a1023a101fa101fa101ca101ca101ca101ca101fa101fa101fa101fa101fa101fa101fa101fa1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a15
0110000009d5009d5009d5009d5009d0009d0009d5309d5100d0000d0000d0000d000ad500ad5000d0000d0009d5009d5009d5009d5000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d00
0112000023a1023a101fa101fa101ca101ca101ca101ca101fa101fa101fa101fa101fa101fa101fa101fa1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a1021a10
0112000023a1023a101fa101fa101ca101ca101ca101ca101fa101fa101fa101fa101fa101fa101fa101fa1020a1020a1020a1020a1020a1020a1021a1021a1023a1023a1026a1026a1024a1024a1023a1023a10
0110000015c1015c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c1115c2115c2115c3115c3115c4115c4115c4115c3115c3115c2115c2115c1115c1115c10
0113000028c2528c0528c2528c0028c2528c0528c2529c0528c2529c0528c2529c0528c2528c052bc202bc2028c2526c0528c2526c0528c2526c0528c2526c0528c2523c0528c2524c0528c2523c0524c2024c20
01100000158121581215812158121c8121c8121a8121a8121c8121c8121c8121c81218812188121881218812178121781218812188121a8121a81218812188121781217812178121781213812138121381213812
011000001581215812158121581215812158121581215812158121581215812158121581215812158121581215812158121581215812158121581215812158121781217812178121781213812138121381213812
011200001c9101c910219102191024910249102191021910249102491021910219101c9101c91021910219101f9101f9102391023910269102691023910239101f9101f91023910239101a9101a9101f9101f910
011200001d9101d9102191021910249102491021910219102391023910249102491023910239101f9101f9101c9101c910219102191024910249102191021910249102491021910219101c9101c9102191021910
0112000018910189101c9101c9101f9101f9101c9101c91021910219101f9101f9101c9101c91018910189101a9101a910139101391017910179101a9101a9101f9101f9101d9101d9101c9101c9101a9101a910
011200001d9101d9102191021910249102491021910219101f9101f9102391023910269102691023910239101c9101c9102091020910239102391020910209102491024910239102391020910209102391023910
011200001c9101c910219102191024910249102191021910249102491021910219101c9101c91021910219101d9101d910219102191024910249102191021910249102491021910219101d9101d9102191021910
0112000018910189101c9101c9101f9101f9101c9101c9101f9101f9101c9101c91018910189101c9101c910139101391017910179101a9101a9101791017910149101491017910179101c9101c9101791017910
011000001081210812108121081210812108121081210812108121081210812108121081210812108121081210812108121081210812108121081210812108121081210812108121081210812108121081210812
011300000412502125041250212507120071210212504125041000410024102241020212500105021250210504125021250412502125071200712102125001200012000120001250010000125071050012502105
011200000902209022090220902209022090220902209022090220902209022090220902209022090220902207022070220702207022070220702207022070220702207022070220702207022070220702207022
011200000502205022050220502205022050220502205022070220702207022070220702207022070220702209022090220902209022090220902209022090220902209022090220901209012090120901209015
011200000c0220c0220c0220c0220c0220c0220c0220c02210022100221002210022130221302213022130220702207022070220702207022070220702207022070220702207022070220c0220c0220b0220b022
01120000050220502205022050220502205022050220502207022070220702207022070220702207022070220402204022040220402204022040220402204022080220802208022080220b0220b0220b0220b022
01130000178121781217812178121781217812178121781217812178121781217812178121781217812178121781217812178121781217812178121781217812188121881218812188121f8121f8121f8121f812
011300001c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c812
011300001c8121c8122381223812248122481223812238121f8121f8121f8121e8121e8121e8121e8121e8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c8121c812
011300001c8121c8122381223812248122481223812238121f8121f8121f8121e8121e8121e8121e8121e8121881218812188121881218812188121881218812178121781218812188121c8121c8121881218812
011000001501215012150121501215012150121501215012150121501215012150121501215012150121501500000000000000000000000000000000000000000000000000000000000000000000000000000000
01150000218322183221832238322483224832238322383221832218321f8321f83221832218322183221832238371f8322183221832218322183221832218352183421832218322383224832248322383223832
0115000021832218321f8321f83221832218322183221832218322183221832218322183221832218322183221832218322183221832218322183221832218322183221832218322183221832218322183221832
011500002483224832248322683228832288322683226832248322483223832238322483224832248322483226837238322483224832248322483224832248352483424832248322683228832288322683226832
011500002b8322b8322b8322b8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d8322d832
011500000512205122111220512211122111220712207122131220712213122131220912209122151220912215122151220912209122151220912215122091220512205122111220512211122111220712207122
011500001312207122131221312209122091220912209122091220912209122091220912209122091220912209122091220912209122091220912209122091250010200102001020010200102001020010200102
01010000176222360026600236002160024600286002460028600246002d600286002d60028600216022160221602216052160021600216002160021600216002160021600216002160021600216002160021600
011500001de301de301de701de301de701de301fe301fe301fe701fe301fe701fe3021c3021c3021c7021c3021c7021c3021c3021c3021c7021c3021c7021c301de301de301de701de301de701de301fe301fe30
011500001fe701fe301fe701fe3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c3021c301de001de001de001de001de001de001fe001fe00
0007000008613086110a6110b6210c6210d6210d62110631116311463116631196311d6312064123641276412b6412e651306513165130651306512e6512c6512b6412964126641216311c631176211162110615
010500002815028151281112d1112d1412d1412d1112d1112d1312d1312d1112d1112d1212d1212d1112d11100100001000010000100001000010000100001000010000100001000010000100001000010028100
000300000465004650006000060000600006000060000600236000060000600006002660000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01020000292532925326253002032625300203002032225300203002032225300203002032025300203002031e25300203002031c253002031b25300203002031a2530520301203152531c203002031125300203
010200002d5202d5212d5212d5212d5212d5112d5112d5112d5112d51535500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300000f0501205015050190501e050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a0001a0501a0501a05005000270502605028050290502805027040280302903028020260202801000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000d6500460000600006000a6400460004600006000863005600056000560006620006002460024600036100d600006001160000610006001c6001d6001e60000600006000060000600006000060000600
000300001813017140161401414012140101400e1400b1500a1500915007160061600416003150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000415004150041500515006150081500a1500c1500e1501115014150181501a15000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200001647013460104600d4600a45008440074400644019440174401540013400104000d400084000240000400004000040000400004000040000400004000040000400004000040000400004000040000400
000100001a2701526012250112500f2400d2400b2400a240092400823007230052300523003220032100020000200002000020000200002000020000200002000020000200002000020000200002000020000200
00030000100700d070080700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0700d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 08 18 43 44
00 09 19 43 44
00 08 18 20 44
00 09 19 21 44
00 0a 1a 22 44
00 0b 1b 23 44
00 0a 1a 22 44
00 0c 19 21 44
00 08 18 20 44
00 09 19 21 44
00 08 18 20 44
00 09 19 21 44
00 0a 1a 22 44
00 0b 1b 23 44
00 0a 1a 22 44
02 0c 19 21 44
01 0d 42 20 0f
04 0e 42 21 10
01 11 42 14 44
00 11 42 14 44
01 11 16 14 44
00 11 16 14 44
00 11 17 14 44
00 11 1e 14 44
01 11 16 14 44
00 11 16 14 44
00 11 17 14 44
02 11 1e 14 44
01 1f 15 43 44
00 1f 15 43 44
01 1f 15 26 44
00 1f 15 27 44
00 1f 15 24 44
02 1f 15 25 44
01 29 2b 2d 30
00 2a 2c 2e 31
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
