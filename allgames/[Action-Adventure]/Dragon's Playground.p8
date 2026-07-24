pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--dragon's playground
--extar 2020
--made for tom hall's rndgame2020 game jam

--v1.1
---additions:
----fillp effect, particle transparency

--todo:
--take out stuff that isn't working:
	--wheat
	--reduce number of trees and shrubs

--add treasure to pick up	
--add sound effects
--add difficulty/different dragons
---gold: regen, more health (easy mode)
---red: normal
---black: gain notoriety quicker, more elves and knights. (hard)

---is it worth making all scenery one type differentiated by classes like how npcs work?

function _init()
	menuitem(1,'reset',function() title_init() end)
	high_score_easy=0
	high_score_normal=0
	high_score_hard=0
	title_init() 
end

function title_init()
	_update=title_update
	_draw=title_draw
	
	music(0)
	story_scroll=56
	difficulty=2
	title_skip=0
end

function title_update()
	if (time()>6 or title_skip==1) and btnp(—) then
		game_init()
	end
	
	if (btn(”) or btn(ƒ) or btn(‹) or btn(‘) or btn(Ž) or btn(—)) then
		title_skip=1
	end
	
	if btnp(‹) then
		difficulty-=1
	elseif btnp(‘) then
		difficulty+=1
	end
	if difficulty==0 then
		difficulty=3
	elseif difficulty==4 then
		difficulty=1
	end
	if difficulty==1 then
		difficulty_text='easy'
	elseif difficulty==2 then
		difficulty_text='normal'
	elseif difficulty==3 then
		difficulty_text='hard'
	end
end

function title_draw()
	pal()
	cls()
	map(64,0,0,0,32,32)
	palt(0,false)
	palt(14,true)
	spr(46,56,56,2,2)
	pal(0,1)
	string='extar presents'
	drop_shadow(string,64-#string*2,74,9)
		
	if time()>2 or title_skip==1 then
		if difficulty==1 then
			pal(8,9) pal(2,4) pal(14,10)--gold dragon colours
			
		elseif difficulty==2 then
			--default red dragon
		elseif difficulty==3 then
			pal(8,5) pal(2,0) pal(14,6) --black dragon colours
		end
		palt(14,false)
		palt(0,true)
		spr(86,32,81,8,2)
		palt(14,true)
		palt(0,false)
		spr(1,0,86,2,2)
		spr(1,112,86,2,2)
	end
	if time()>4 or title_skip==1 then
		string='part of rndgame jam'
		drop_shadow(string,64-#string*2,98,9)
		string='may 15-24 2020'
		drop_shadow(string,64-#string*2,104,9)
		print('v1.1',0,123,5)
	end
	if time()>6 or title_skip==1 then
		string='press — to begin your conquest'
		drop_shadow(string,64-#string*2,112,9)
		string='‹ '..difficulty_text..' ‘'
		drop_shadow(string,64-#string*2,120,8)
		clip(0,0,128,55)
	end
	if time()>8 or title_skip==1 then
		story_scroll-=0.1
		string='you are azron,\nterrifying dragon\nand scourge of the realms.\n\nthis pathetic kingdom will\nknow true fear once you\ndescend upon it.\n\nslay the weak, arogant wizards,\nwho hide in their petty towers\nand the realm is yours.\n\nbeware the elves,\nfriends of the forest.\n\nquesting knights seek\nto end your reign of terror.\nincinerate them.\n\nconsume the livestock to\nreplenish your draconic might.\n\nterrorise the peasants,\nwho cower in their homes.\n\nall must burn.'
		drop_shadow(string,8,story_scroll,8)
	end
end

function game_init()	
	
	_update=game_update
	_draw=game_draw

	elf_vecx=0
	elf_vecy=0

	music(-1)

	anim_clock=0
	ashes={}
	burning={}
	burnt_farms={}
	burnt_shrubs={}
	burnt_towers={}
	burnt_trees={}
	dragon={
		breath_x=0,
		breath_y=0,
		cooldown=0,
		facing='u',
		fire_charge=0,
		h=2,
		hp=100,
		hp_max=100,
		inertia_x=0,
		inertia_y=0,
		momentum_x=0,
		momentum_y=0,
		notoriety=0,
		sp=1,
		sp_facing=1,
		sp_flap=0,
		w=2,
		x=56,
		xp=0,
		y=56,
	}
	fireballs={}
	hits={}
	hit_circles={}
	missiles={}
	npcs={}
	occupied_tiles={}
	smoke={}
	sparks={}
	treasures={}
	total_particles=0
	
	populate_map()
	
	if difficulty==1 then
		dragon.hp+=100
		dragon.hp_max+=100
	elseif difficulty==2 then
		dragon.hp+=100
		dragon.hp_max+=100
	end	
end

function game_update()

	anim_clock+=1
	if anim_clock>120 then
		anim_clock=1
	end

	update_burning()
	update_dragon()
	update_npcs()
	update_fireballs()
	update_particles()
	update_scenery()
	update_treasures()
	
	dragon_eat()
	update_enemy_missiles()

end

function game_draw()

	cls()
	draw_map()
	pal()
	palt(0,false)
	palt(14,true)
	--scenery layer
	draw_ashes()
	draw_burnt_scenery()
	draw_scenery()
	--characters layer
	draw_entities()
	--fire layer
	draw_burning()
	draw_fireballs()
	--flying characters
	draw_dragon()
	draw_particles()
	--rect(dragon.x,dragon.y,dragon.x+16,dragon.y+16,10)
	--ui (camera is reset)
	camera()
	draw_ui()
	
	if seen_hints!=true then
		rectfill(8,16,117,57,0)
		rectfill(7,15,116,56,1)
		drop_shadow('— - breathe fire\nŽ - charge breath',8,16,10)
		drop_shadow('eat cows, deer and peasants\nto replenish health.',8,34,7)
		drop_shadow('slay all the wizards.',8,50,8)
		if anim_clock==119 or (btn(0) or btn(1) or btn(2) or btn(3)) then
			seen_hints=true
		end
	end
	
	--drop_shadow('rndgame2020',1,116,7)
	--drop_shadow('dragon`s playground - day 9',1,122,8)
	--debug
	--print(stat(0)..' '..stat(1),1,108,10)
	--print(dragon.x..','..dragon.y,1,102,10)
	
end

function game_over_init()
	music(8)
	string=' '
	game_over_time=90
	
	_update=game_over_update
	_draw=game_over_draw
end

function game_over_update()
	if game_over_time==0 and btnp(—) then
		title_init()
	end
end

function game_over_draw()

	pal()
	rectfill(8,64,120,83,0)
	rectfill(7,63,119,82,1)

	if difficulty==1 and dragon.notoriety>high_score_easy then
		high_score_easy=dragon.notoriety
	elseif difficulty==2 and dragon.notoriety>high_score_normal then
		high_score_normal=dragon.notoriety
	elseif difficulty==3 and dragon.notoriety>high_score_hard then
		high_score_hard=dragon.notoriety	
	end
	
	if high_score_easy>0 then
		rectfill(8,40,85+(#tostr(high_score_easy)*4),47,0)
	end
	if high_score_normal>0 then
		rectfill(8,46,93+(#tostr(high_score_normal)*4),53,0)
	end
	if high_score_hard>0 then
		rectfill(8,53,85+(#tostr(high_score_hard)*4),59,0)
	end

	if high_score_easy>0 then
		rectfill(7,39,84+(#tostr(high_score_easy)*4),46,1)
	end
	if high_score_normal>0 then
		rectfill(7,45,92+(#tostr(high_score_normal)*4),52,1)
	end
	if high_score_hard>0 then
		rectfill(7,51,84+(#tostr(high_score_hard)*4),58,1)
	end	
	
	if high_score_easy>0 then
		drop_shadow('high score (easy): '..high_score_easy,8,40,9)
	end
	if high_score_normal>0 then
		drop_shadow('high score (normal): '..high_score_normal,8,46,8)
	end
	if high_score_hard>0 then
		drop_shadow('high score (hard): '..high_score_hard,8,52,5)
	end
	if dragon.hp>0 then
		drop_shadow('mighty azron, the kingdom is\nyours.\nall tremble at your name.',8,64,10)
	else
		drop_shadow('foul azron, you were slain\nby a '..dragon.last_hit..'.\nthe realm is safe once more.',8,64,10)
	end
	
	rectfill(8,88,120,107,0)
	rectfill(7,87,119,106,1)
	if dragon.notoriety>5000 then
		string='your evil deeds are legend.\nyou inspire dread amongst\nthe bravest of heroes.'
	elseif dragon.notoriety>4000 then
		string='your name is synonymous\nwith death. the brave dare\nnot speak your name.'
	elseif dragon.notoriety>3000 then
		string='bards acr0ss the realm\nsing songs of your\ngrim deeds.'
	elseif dragon.notoriety>2000 then
		string='those who witnessed your\npower tell tall tales\nof your evil schemes.'
	elseif dragon.notoriety>1000 then
		string='exaggerated tales of your\ndeeds are used\nto frighten children.'	
	elseif dragon.notoriety>0 then
		string='local historians have\ninaccurately recorded some\nof your modest deeds.'
	end
	drop_shadow(string,8,88,10)
	
	if game_over_time>0 then
		game_over_time-=1
	else
		string='press — to restart'
		rectfill(64-(#string*2),115,64+(#string*2+5),122,0)
		rectfill(63-(#string*2),114,64+(#string*2+4),121,1)
		drop_shadow(string,64-#string*2,115,10)
	end
	
end
-->8
--dragon code

function update_dragon()

	if difficulty==1 and time()%1==0 and dragon.hp<dragon.hp_max then
		dragon.hp+=1
	end

	if btn(‹) then
		dragon.x-=2
		if dragon.facing=='r' then
			dragon.x+=1
		end
		dragon.momentum_x=-1
		dragon.inertia_x-=1		
		if dragon.flame_on==false then
			dragon.facing='l'
		end
	end
	if btn(‘) then
		dragon.x+=2
		if dragon.facing=='l' then
			dragon.x-=1
		end
		dragon.momentum_x=1
		dragon.inertia_x+=1
		if dragon.flame_on==false then
			dragon.facing='r'
		end
	end
	if btn(”) then
		dragon.y-=2
		if dragon.facing=='d' then
			dragon.y+=1
		end
		dragon.momentum_y=-1
		dragon.inertia_y-=1
		if dragon.flame_on==false then
			dragon.facing='u'
		end
	end
	if btn(ƒ) then
		dragon.y+=2
		if dragon.facing=='u' then
			dragon.y-=1
		end
		dragon.momentum_y=1
		dragon.inertia_y+=1
		if dragon.flame_on==false then
			dragon.facing='d'
		end
	end
	if not btn(‹) and not btn(‘) then
		dragon.momentum_x=0
	end
	if not btn(”) and not btn(ƒ) then
		dragon.momentum_y=0
	end
	
	if dragon.facing=='u' then
		dragon.breath_x=dragon.x+0
		dragon.breath_y=dragon.y-12
	elseif dragon.facing=='d' then
		dragon.breath_x=dragon.x+0
		dragon.breath_y=dragon.y+12
	elseif dragon.facing=='l' then
		dragon.breath_x=dragon.x-12
		dragon.breath_y=dragon.y+0
	elseif dragon.facing=='r' then
		dragon.breath_x=dragon.x+12
		dragon.breath_y=dragon.y+0
	end
	
	if not (btn(Ž) or btn(—)) then
		dragon.fire_charge+=1
	end
	if btn(Ž) then
		dragon.fire_charge+=2
	end
	if dragon.fire_charge>100 then
		dragon.fire_charge=100
	end
	--cheat
	if btnp(4) and btn(5) then
		--wizards-=1
	end
	
	if btn(—) and not btn(Ž) and dragon.fire_charge>0 then
		spawn_fireball()
		dragon.flame_on=true
		dragon.fire_charge-=1
	else
		dragon.flame_on=false
	end
	
	if dragon.cooldown>0 then
		dragon.cooldown-=1
	end
		
	if btn(—) and dragon.fire_charge==0 and dragon.cooldown==0 then
		spawn_fireball()
		dragon.flame_on=true
		dragon.cooldown=10
	end
	
	dragon.x=mid(0,dragon.x,504)
	dragon.y=mid(0,dragon.y,504)
	
	--flapping
	if (btn(”) or btn(ƒ) or btn(‹) or btn(‘)) and time()%1==0 then
		dragon.sp_flap=64
		sfx(4)
	end
	if not (btn(”) or btn(ƒ) or btn(‹) or btn(‘)) and time()%2==0 then
		dragon.sp_flap=64
		sfx(4)
	end
	if time()%1==0.5 then
		dragon.sp_flap=0
	end
	if dragon.facing=='u' or dragon.facing=='d' then
	 dragon.sp_facing=1
	else
		dragon.sp_facing=14
	end
	
	dragon.sp=dragon.sp_facing+dragon.sp_flap
	--dragon inertia
	dragon.inertia_x=mid(-8,dragon.inertia_x,8)
	dragon.inertia_y=mid(-8,dragon.inertia_y,8)
	if not (btn(”) or btn(ƒ) or btn(‹) or btn(‘)) then
		if dragon.inertia_x!=0 then
			if dragon.inertia_x<0 then
				dragon.x-=1
				dragon.inertia_x+=1
			else
				dragon.x+=1
				dragon.inertia_x-=1
			end
		end
		if dragon.inertia_y!=0 then
			if dragon.inertia_y<0 then
				dragon.y-=1
				dragon.inertia_y+=1
			else
				dragon.y+=1
				dragon.inertia_y-=1
			end
		end
	end
	--dying
	if dragon.hp<=0 then 
		game_over_init()
	end
	--winning
	if wizards<=0 then
		game_over_init()
	end
end

function spawn_fireball()
	local fireball={
		age=0,
		dir=dragon.facing,
		drift=rnd(2)-1,
		sp=ceil(rnd(4))+32,
		x=dragon.breath_x,
		y=dragon.breath_y,
		}
	fireball.momentum_x=dragon.momentum_x
	fireball.momentum_y=dragon.momentum_y
	add (fireballs,fireball)
	sfx(1)
	if not(btn(0) or btn(1) or btn(2) or btn(3)) then
		fireball.drift*=0.5
	end
end

function update_fireballs()
	for fireball in all(fireballs) do
		spawn_spark(fireball.x,fireball.y)
		if fireball.dir=='u' then
			fireball.y-=4
			fireball.x+=fireball.drift
		elseif fireball.dir=='d' then
			fireball.y+=4
			fireball.x+=fireball.drift
		elseif fireball.dir=='l' then
			fireball.x-=4
			fireball.y+=fireball.drift
		elseif fireball.dir=='r' then
			fireball.x+=4
			fireball.y+=fireball.drift
		end
		fireball.age+=1
		if fireball.age>12 then
			del(fireballs,fireball)
		end
		fireball.sp+=1
		if fireball.sp>36 then
			fireball.sp=33
		end
		if fireball.momentum_x!=null then
			fireball.x+=fireball.momentum_x
		end
		if fireball.momentum_y!=null then
			fireball.y+=fireball.momentum_y
		end
	end
end

function draw_fireballs()
	for fireball in all(fireballs) do
		spr(fireball.sp,fireball.x,fireball.y)
	end
end
		
function draw_dragon()
	
	if difficulty==1 then
		pal(8,9) pal(2,4) --gold dragon colours
	elseif difficulty==2 then
		--default red dragon
	elseif difficulty==3 then
		pal(8,5) pal(2,0) --black dragon colours
	end

	--dragon sprite is offset by -4. does this need fixing?
	
	if dragon.facing=='u' then
		spr(dragon.sp,dragon.x-4,dragon.y-4,dragon.w,dragon.h)
	elseif dragon.facing=='d' then
		spr(dragon.sp,dragon.x-4,dragon.y-4,dragon.w,dragon.h,false,true)
	elseif dragon.facing=='l' then
		spr(dragon.sp,dragon.x-4,dragon.y-4,dragon.w,dragon.h,true)
	elseif dragon.facing=='r' then
		spr(dragon.sp,dragon.x-4,dragon.y-4,dragon.w,dragon.h,false,true)
	end
	if dragon.flame_on and anim_clock%2==0 then
		if dragon.facing=='u' then
			spr(20,dragon.breath_x,dragon.breath_y)
		elseif dragon.facing=='d' then
			spr(20,dragon.breath_x,dragon.breath_y,1,1,false,true)
		elseif dragon.facing=='l' then	
			spr(13,dragon.breath_x,dragon.breath_y,1,1,true)
		elseif dragon.facing=='r' then
			spr(13,dragon.breath_x,dragon.breath_y)
		end
	end
end

function dragon_eat()
	for npc in all (npcs) do
		if check_collide(npc.x,npc.y,dragon.x,dragon.y) and npc.edible then
			dragon.hp+=npc.food
			if difficulty<3 then
				dragon.hp+=npc.food
			end
			dragon.hp=min(dragon.hp,dragon.hp_max)
			dragon.notoriety+=npc.fame
			spawn_ashes(npc.x,npc.y,'blood')
			sfx(8)
			del(npcs,npc)
		end
	end
end
-->8
--hud

function drop_shadow(string,x,y,c)
	print(string,x+1,y+1,0)
	print(string,x,y,c)
end

function draw_ui()
	--hp
	if dragon.hp>dragon.hp_max*0.75 then
		dragon.hp_colour=11
	elseif dragon.hp>dragon.hp_max*0.5 then	
		dragon.hp_colour=10
	elseif dragon.hp>dragon.hp_max*0.25 then
		dragon.hp_colour=9
	else
		dragon.hp_colour=8
	end
	rectfill(1,1,100+2,4,0)
	if dragon.hp>0 then
		rectfill(2,2,1+((100/dragon.hp_max)*dragon.hp),3,dragon.hp_colour)
	end
	--notoriety
	
	drop_shadow('notoriety: ',1,6,10) drop_shadow(dragon.notoriety,45,6,7)
	drop_shadow('Š:'..wizards..'/'..wizards_max,104,1,7)
	
	--fire charge
	if dragon.fire_charge>0 then
		local box_colour=10
		if dragon.fire_charge>99 and anim_clock%10==0 then
			box_colour=8
		end
		rect(124,126,126,24,box_colour)
	end
	if dragon.fire_charge>0 then
		line(125,125,125,125-(dragon.fire_charge),8)
	end
end
-->8
--map code

--used to see whether to allow draws or updates for entities *s*creen widths away from the dragon
function near_dragon(x,y,s)
	if abs(x-mid(dragon.x,64,448))<s*72 and abs(y-mid(dragon.y,64,448))<s*72 then
		return true
	else
		return false
	end
end

--populate fields
function spawn_wheat(x,y)
	wheat={
		sp=12,
		x=x,
		y=y,
		}
	add (wheats,wheat)
	--add_to_occupied_tiles(wheat.x,wheat.y)
end

function add_to_occupied_tiles(x,y)
	local tile={
		x=x,
		y=y,
		}
	add (occupied_tiles,tile)
end

function find_new_coords(tile_w,tile_h)
	--new_x=8
	--new_y=8
	new_x=ceil(rnd(62))*8
	new_y=ceil(rnd(60))*8
	check_done=false
	while check_done==false do
		tile_is_definitely_free=true
		for tile in all (occupied_tiles) do
			for ih=1,tile_h do
				for iw=1,tile_w do
					--add_to_occupied_tiles((tower.x-8)+(iw*8),(tower.y-8)+(ih*8))
					if (new_x-8)+(tile_w*8)==tile.x and (new_y-8)+(tile_h*8)==tile.y then
						tile_is_definitely_free=false
						break
					end
				end
			end
		end
		if tile_is_definitely_free==true then
			check_done=true
		else
			new_x=ceil(rnd(62))*8
			new_y=ceil(rnd(60))*8
		end
	end
end

function populate_map()
	
	farms={}
	fields={}
	shrubs={}
	trees={}
	towers={}
	wheats={}
	farms_max=ceil(rnd(30))
	trees_max=ceil(rnd(300))
	fields_max=2+ceil(trees_max/100)
	towers_max=7
	wizards_max=towers_max
	wizards=towers_max
	
	for i=1,fields_max do
		field_h=ceil(rnd(2))+4
		field_w=ceil(rnd(2))+4
		find_new_coords(field_w,field_h)
		local field={
			h=field_h,
			w=field_w,
			x=flr(rnd(64))*8,
			y=flr(rnd(63))*8,
			}
		add (fields,field)
		for ih=1,field.h do
			for iw=1,field.w do
				add_to_occupied_tiles((field.x-8)+(iw*8),(field.y-8)+(ih*8))
			end
		end
	end
	for i=1,towers_max do
		find_new_coords(2,4)
		local tower={
			h=4,
			hp=400,
			hp_max=400,
			sp=9,
			w=2,
			x=new_x,
			y=new_y,
			--x=flr(rnd(62))*8,
			--y=flr(rnd(61))*8,
			}
		add (towers,tower)
		for ih=1,tower.h do
			for iw=1,tower.w do
				add_to_occupied_tiles((tower.x-8)+(iw*8),(tower.y-8)+(ih*8))
			end
		end
	end
	for i=1,farms_max do
		find_new_coords(2,2)
		local farm={
			h=2,
			hp=100,
			hp_max=100,
			sp=5,
			w=2,
			x=new_x,
			y=new_y,
			--x=flr(rnd(64))*8,
			--y=flr(rnd(63))*8,
			}
		add (farms,farm)
		for ih=1,farm.h do
			for iw=1,farm.w do
				add_to_occupied_tiles((farm.x-8)+(iw*8),(farm.y-8)+(ih*8))
			end
		end
	end
	for i=1,trees_max do
		find_new_coords(1,2)
		local tree={
			id=ceil(rnd(32767)),
			h=2,
			hp=50,
			hp_max=50,
			sp=7,
			w=1,
			x=new_x,
			y=new_y,
			--x=flr(rnd(63))*8,
			--y=flr(rnd(63))*8,
			}
		--mset(tree.x/8,tree.y+1/8,29)
		add (trees,tree)
		add_to_occupied_tiles(tree.x,tree.y)
		add_to_occupied_tiles(tree.x,tree.y+8)
	end
	for i=1,trees_max do
		find_new_coords(1,1)
		local shrub={
			id=ceil(rnd(32767)),
			hp=25,
			hp_max=25,
			sp=39,
			x=new_x,
			y=new_y,
			--x=flr(rnd(64))*8,
			--y=flr(rnd(63))*8,
			}
		add (shrubs,shrub)
		add_to_occupied_tiles(shrub.x,shrub.y)
	end
	--put wheat in fields
	for field in all (fields) do
		for i=1,#fields do
			for wheat_y=1,field.h do
				--single row
				for wheat_x=1,field.w do
					spawn_wheat((field.x)+(wheat_x*8),(field.y)+(wheat_y*8))
				end
			end
		end
	end

	for i=1,trees_max/8 do
		spawn_npc('deer',ceil(rnd(63))*8,ceil(rnd(63))*8)
	end
	
	for i=1,farms_max do
		spawn_npc('cow',ceil(rnd(63))*8,ceil(rnd(63))*8)
	end
end

function draw_scenery()

	--plants layer
	for wheat in all(wheats) do
		if near_dragon(wheat.x,wheat.y,1) then
			spr(wheat.sp,wheat.x,wheat.y)
		end
	end
	for shrub in all(shrubs) do
		if near_dragon(shrub.x,shrub.y,1) then
			spr(shrub.sp,shrub.x,shrub.y)
		end
	end
	for tree in all(trees) do
		if near_dragon(tree.x,tree.y,1) then
			spr(tree.sp,tree.x,tree.y,tree.w,tree.h)
		end
	end
	--buildings layer
	for farm in all(farms) do
		if near_dragon(farm.x,farm.y,1) then
			spr(farm.sp,farm.x,farm.y,farm.w,farm.h)
		end
	end
	for tower in all(towers) do
		if near_dragon(tower.x,tower.y,2) then
			spr(tower.sp,tower.x,tower.y,tower.w,tower.h)
		end
	end
end

function draw_map()
	--mapx=dragon.x-8
	--mapy=dragon.y-8
	camera(mid(0,dragon.x-56,384),mid(0,dragon.y-56,384))
	cam_x=mid(0,dragon.x-56,384)
	cam_y=mid(0,dragon.y-56,384)
	map(0,0,0,0,64,64)
	
end
-->8
--scenery code

function check_collide(ax,ay,bx,by)
	if ax+8>bx and ax<bx+8 and ay+8>by and ay<by+8 then
		return true
	end
end

--collision function for wide and tall entities
function check_collide_2(ax,ay,bx,by,bh,bw)
	if ax+8>bx and ax<bx+bw*8 and ay+8>by and ay<by+bh*8 then
		return true
	end
end

function spawn_burnt_farm(x,y)
	local burnt_farm={
		h=1,
		sp=37,
		w=2,
		x=x,
		y=y,
		}
		add(burnt_farms,burnt_farm)
end

function spawn_burnt_tower(x,y)
	local burnt_tower={
		h=3,
		sp=27,
		w=2,
		x=x,
		y=y,
		}
	add(burnt_towers,burnt_tower)
end

function update_scenery()
	
		for tree in all (trees) do
		if tree.on_fire==true and time()%1==0 then
			tree.hp-=1
		end
		--don't bother checking for fireball damage for trees not on the screen (should alleviate slowdown)
		if near_dragon(tree.x,tree.y,1) then
			for fireball in all (fireballs) do
				if check_collide (fireball.x,fireball.y,tree.x,tree.y) then
					tree.hp-=1
				end
			end
		end
		if tree.hp<0 then
			spawn_burnt_tree(tree.x,tree.y)
			sfx(2)
			burn_time(tree.id)
			del(trees,tree)
			dragon.notoriety+=2
		end
		if tree.hp<=tree.hp_max/2 and tree.on_fire!=true then
			spawn_burning(tree.x,tree.y,tree.id)
			tree.on_fire=true
		end
	end
	
	for shrub in all (shrubs) do
		if shrub.on_fire==true and time()%1==0 then
			shrub.hp-=1
			dragon.notoriety+=1
		end
		--don't bother checking for fireball damage if not on screen)
		if near_dragon(shrub.x,shrub.y,1) then
			for fireball in all (fireballs) do
				if check_collide (fireball.x,fireball.y,shrub.x,shrub.y) then
					shrub.hp-=1
				end
			end
		end
		if shrub.hp<0 then
			spawn_burnt_shrub(shrub.x,shrub.y)
			sfx(2)
			burn_time(shrub.id)
			del(shrubs,shrub)
		end
		if shrub.hp<=shrub.hp_max/2 and shrub.on_fire!=true then
			spawn_burning(shrub.x,shrub.y,shrub.id)
			shrub.on_fire=true
		end
	end
	
	for wheat in all (wheats) do
		--don't bother checking for fireball damage if not on screen)
		if near_dragon(wheat.x,wheat.y,1) then
			for fireball in all (fireballs) do
				if check_collide (fireball.x,fireball.y,wheat.x,wheat.y) then
					spawn_smoke(wheat.x,wheat.y)
					if rnd(1)>0.75 then
						spawn_temp_burning(wheat.x,wheat.y)
					end
					spawn_ashes(wheat.x,wheat.y)
					sfx(2)
					--burn_time(wheat.id)
					del(wheats,wheat)
					dragon.notoriety+=1
				end
			end
		end
	end
	
	for farm in all (farms) do
		if farm.on_fire==true and time()%1==0 then
			farm.hp-=1
		end
		--don't bother checking for fireball damage if not on screen)
		if near_dragon(farm.x,farm.y,1) then
			for fireball in all (fireballs) do
				if check_collide (fireball.x,fireball.y,farm.x,farm.y) then
					farm.hp-=1
				end
			end
		end
		if farm.hp<0 then
			spawn_burnt_farm(farm.x,farm.y+8)
			sfx(2)
			burn_time(farm.id)
			del(farms,farm)
		end
		if farm.hp<=farm.hp_max/2 and farm.on_fire!=true then
			spawn_burning(farm.x,farm.y,farm.id)
			farm.on_fire=true
			for i=1,ceil(rnd(4)) do
				spawn_npc('farmer',farm.x+(ceil(rnd(4))*8)-16,farm.y+16)
			end
		end
	end
	
	for tower in all (towers) do
		if tower.on_fire==true and time()%1==0 then
			tower.hp-=1
		end
		--don't bother checking for fireball damage if not on screen)
		if near_dragon(tower.x,tower.y,1) then
			for fireball in all (fireballs) do
				if check_collide_2(fireball.x,fireball.y,tower.x,tower.y,tower.h,tower.w) then
					tower.hp-=1
				end
			end
		end
		if tower.hp<0 then
			spawn_burnt_tower(tower.x,tower.y+8)
			sfx(2)
			burn_time(tower.id)
			del(towers,tower)
		end
		if tower.hp<=tower.hp_max/2 and tower.on_fire!=true then
			spawn_burning(tower.x,tower.y,tower.id)
			tower.on_fire=true
			spawn_npc('wizard',tower.x,tower.y+24)
		end
	end
end

function spawn_burnt_tree(x,y)
	local burnt_tree={
		h=2,
		sp=8,
		w=1,
		x=x,
		y=y,
		}
		add(burnt_trees,burnt_tree)
end

function spawn_burnt_shrub(x,y)
	local burnt_shrub={
		sp=40,
		x=x,
		y=y,
		}
		add(burnt_shrubs,burnt_shrub)
end

function draw_burnt_scenery()
	for burnt_farm in all (burnt_farms) do
		spr(burnt_farm.sp,burnt_farm.x,burnt_farm.y,burnt_farm.w,burnt_farm.h)
	end
	for burnt_shrub in all (burnt_shrubs) do
		spr(burnt_shrub.sp,burnt_shrub.x,burnt_shrub.y)
	end
	for burnt_tree in all (burnt_trees) do
		spr(burnt_tree.sp,burnt_tree.x,burnt_tree.y,burnt_tree.w,burnt_tree.h)
	end
	for burnt_tower in all (burnt_towers) do
		spr(burnt_tower.sp,burnt_tower.x,burnt_tower.y,burnt_tower.w,burnt_tower.h)
	end
end

function spawn_burning(x,y,id)
	local burn={
		id=id,
		sp=ceil(rnd(4))+32,
		x=x,
		y=y,
		}
	add (burning,burn)
end

function spawn_temp_burning(x,y)
	local burn={
		--id=id,
		sp=ceil(rnd(4))+32,
		time=ceil(rnd(120))+120,
		x=x,
		y=y,
		}
	add (burning,burn)
end

--this gives burns a set time after the building is destroyed before they fizzle
--is it necessary?
function burn_time(id)
	for burn in all (burning) do
		if burn.id==id then
			burn.time=ceil(rnd(120))+120
		end
	end
end

function update_burning()
	for burn in all (burning) do
		if total_particles<600 then
			spawn_smoke(burn.x,burn.y)
		end
		burn.sp+=1
		if burn.sp>36 then
			burn.sp=33
		end
		if burn.time!=null then
			burn.time-=1
			--performance
			if #burning>20 then
				burn.time-=5
			end
			if burn.time<1 then
				del(burning,burn)
			end
		end
	end
end

function draw_burning()
	for burn in all (burning) do
		spr(burn.sp,burn.x,burn.y)
	end
end
-->8
--npc code

function spawn_ashes(x,y,class)
	--performance, stops multiple ashes being stacked
	local space_free=true
	for ash in all (ashes) do
		if ash.x==x and ash.y==y then
			return false
		end
	end
	if class=='ash' or class==null then
		local ash={
			class=class,
			sp=11,
			x=x,
			y=y,
		}
		add (ashes,ash)
		sfx(3)
	elseif class=='blood' then
		local ash={
		class=class,
		sp=67,
		x=x,
		y=y,
		}
		add (ashes,ash)
		sfx(3)
		if rnd(1)<0.5 then
			ash.x_flip=true
		else
			ash.x_flip=false
		end
		if rnd(1)<0.5 then
			ash.y_flip=true
		else
			ash.y_flip=false
		end
	end
end

function draw_ashes()
	for ash in all (ashes) do
		spr(ash.sp,ash.x,ash.y)
		if ash.class=='blood' then
			spr(ash.sp,ash.x,ash.y,1,1,ash.x_flip,ash.y_flip)
		else
			spr(ash.sp,ash.x,ash.y)
		end
	end
end

--only knight uses stun time, must be a better way of disabling wandering routine for when knight is stunned that doesn't require placeholder stun variables on all other npcs
function spawn_npc(class,x,y)
	if class=='cow' then
		local npc={
			class=class,
			edible=true,
			fame=2,
			food=10,
			hp=30,
			hp_max=30,
			id=ceil(rnd(32767)),
			move_step=60,
			move_step_max=60,
			on_fire=false,
			sp=19,
			sp_x=x,
			sp_y=y,
			stun_time=0,
			target_x=x,
			target_y=y,
			x=x,
			y=y,
			}
		add (npcs,npc)
	elseif class=='deer' then
		local npc={
			class=class,
			edible=true,
			fame=1,
			food=8,
			hp=20,
			hp_max=20,
			id=ceil(rnd(32767)),
			move_step=60,
			move_step_max=60,
			on_fire=false,
			sp=55,
			sp_x=x,
			sp_y=y,
			stun_time=0,
			target_x=x,
			target_y=y,
			x=x,
			y=y,
			}
		add (npcs,npc)
	elseif class=='elf' then
		local npc={
			attack_speed=30,
			class=class,
			cooldown=0,
			edible=false,
			fame=40,
			hp=100,
			hp_max=100,
			id=ceil(rnd(32767)),
			missile_damage=10,
			missile_pierce=false,
			missile_sp=52,
			missile_sp_flip=false,
			missile_speed=2,
			move_step=30,
			move_step_max=30,
			on_fire=false,
			sp=54,
			sp_x=x,
			sp_y=y,
			stun_time=0,
			target_x=x,
			target_y=y,
			x=x,
			y=y,
			}
		add (npcs,npc)
	elseif class=='farmer' then
		local npc={
			class=class,
			edible=true,
			fame=10,
			food=5,
			hp=40,
			hp_max=40,
			id=ceil(rnd(32767)),
			move_step=20,
			move_step_max=20,
			on_fire=false,
			sp=3,
			sp_x=x,
			sp_y=y,
			stun_time=0,
			target_x=x,
			target_y=y,
			x=x,
			y=y,
			}
		add (npcs,npc)
	elseif class=='knight' then
		local npc={
			cooldown=0,
			charge_direction=1,
			charging='no',
			class=class,
			edible=false,
			fame=50,
			flip_x=false,
			hp=200,
			hp_max=200,
			id=ceil(rnd(32767)),
			move_step=40,
			move_step_max=40,
			on_fire=false,
			sp=4,
			sp_x=x,
			sp_y=y,
			stun_time=0,
			target_x=x,
			target_y=y,
			x=x,
			y=y,
			}
		add (npcs,npc)
	elseif class=='wizard' then
		local npc={
			attack_speed=30,
			class=class,
			cooldown=0,
			edible=false,
			fame=100,
			hp=200,
			hp_max=200,
			id=ceil(rnd(32767)),
			missile_damage=1,
			missile_pierce=true,
			missile_sp=56,
			missile_sp_flip=false,
			missile_speed=3,
			move_step=60,
			move_step_max=60,
			on_fire=false,
			sp=53,
			sp_x=x,
			sp_y=y,
			stop_fire=25,
			stun_time=0,
			target_lock=0,
			target_x=x,
			target_y=y,
			x=x,
			y=y,
			}
		if difficulty==1 then
			npc.start_fire=20
		elseif difficulty==2 then
			npc.start_fire=15
		elseif difficulty==3 then
			npc.start_fire=10
		end
		add (npcs,npc)
	end
end

function spawn_treasure(x,y,n)
	for i=1,n do
		local treasure={
			x=x+(ceil(rnd(2))-1)*8,
			y=y+(ceil(rnd(2))-1)*8,
			}
		treasure_roll=rnd(20)
		if treasure_roll>18 then
			treasure.sp=51
			treasure.value=100
		elseif treasure_roll>14 then
			treasure.sp=49
			treasure.value=50
		else
			treasure.sp=50
			treasure.value=10
		end
		add (treasures,treasure)
	end
end

function update_treasures()
	for treasure in all (treasures) do
		if check_collide(treasure.x,treasure.y,dragon.x,dragon.y) then
			dragon.notoriety+=treasure.value
			del(treasures,treasure)
			sfx(7)
		end
	end
end

function new_edge_coords()
	edge_x=((ceil(rnd(4))-1)*504)
	--x is either 0 or 512
	if edge_x<=512 then
		edge_y=flr(rnd(504))
	--y is either 0 or 512
	else
		edge_y=flr(rnd(2))*504
		edge_x=flr(rnd(504))
	end
end

function update_npcs()
	if #trees<trees_max and time()%1==0 then
		if rnd(100)<(trees_max-#trees)*0.1 then
			new_edge_coords()
			spawn_npc('elf',edge_x,edge_y)
		end
	end
	if time()%1==0 then
		if rnd(100)<dragon.notoriety/400 then
			new_edge_coords()
			spawn_npc('knight',edge_x,edge_y)
		end
	end

	for npc in all (npcs) do
		npc.move_step-=1
		--npcs run around when on fire
		if npc.on_fire==true then
			npc.move_step-=2
		end
		
		--npcs that are on fire spawn burning
		if npc.on_fire==true and anim_clock%5==0 then
			spawn_burning(npc.x,npc.y,npc.id)
		end
		
		--knights that are charging don't wander around
		if  npc.class=='knight' and npc.charging!='no' then
			if npc.charging!='no' and near_dragon(npc.x,npc.y,1) then --is the knight charging?
				if npc.charging=='x' then
					npc.x+=npc.charge_direction
					if npc.charge_direction>0 and npc.x-dragon.x>32 then
						npc.charging='no'
						npc.stun_time=45
					end
					if npc.charge_direction<0 and npc.x-dragon.x<-32 then
						npc.charging='no'
						npc.stun_time=45
					end
				end
				if npc.charging=='y' then
					npc.y+=npc.charge_direction
					if npc.charge_direction>0 and npc.y-dragon.y>32 then
						npc.charging='no'
						npc.stun_time=45
					end
					if npc.charge_direction<0 and npc.y-dragon.y<-32 then
						npc.charging='no'
						npc.stun_time=45
					end
				end
			end
		--npcs wander around aimlessly unless they are charging knights.
		else
			if npc.move_step<1 then
				old_x=npc.x
				old_y=npc.y
				npc.move_step=npc.move_step_max
				if npc.sp_x==npc.target_x and npc.sp_y==npc.target_y then
					npc.target_x=mid(0,npc.x+((ceil(rnd(7))-4)*8),504)
					npc.target_y=mid(0,npc.y+((ceil(rnd(7))-4)*8),504)
					if near_dragon(npc.x,npc.y,1) then
						if npc.class=='farmer' then
							if rnd(1)<0.25 then
								sfx(0)
							end
						elseif npc.class=='wizard' then
							sfx(10)
						elseif npc.class=='elf' then
							sfx(11)
						elseif npc.class=='cow' and rnd(1)<0.5 then
							sfx(12)
						elseif npc.class=='deer' then
							sfx(13)
						end
					end
				end
				--npc hitbox
				if npc.x!=npc.target_x then
					if npc.x<npc.target_x then
						npc.x+=8
					else
						npc.x-=8
					end
				end
				if npc.y!=npc.target_y then
					if npc.y<npc.target_y then
						npc.y+=8
					else
						npc.y-=8
					end
				end
				--npc scenery collision
				for tile in all (occupied_tiles) do
					if npc.x==tile.x and npc.y==tile.y then
						npc.x=old_x
						npc.y=old_y
						npc.target_x=mid(0,npc.x+((ceil(rnd(7))-4)*8),504)
						npc.target_y=mid(0,npc.y+((ceil(rnd(7))-4)*8),504)
					end
				end
			end
		end
		--sprite trailing
		if npc.x!=npc.sp_x then
			if npc.x>npc.sp_x then
				npc.sp_x+=2
			else
				npc.sp_x-=2
			end
		end
		if npc.y!=npc.sp_y then
			if npc.y>npc.sp_y then
				npc.sp_y+=2
			else
				npc.sp_y-=2
			end
		end
		
		--npc.x=mid(0,npc.x,504)
		--npc.y=mid(0,npc.y,504)
		
		if npc.on_fire==true then
			npc.hp-=1
			dragon.notoriety+=1
		end
		for fireball in all (fireballs) do
			if check_collide (fireball.x,fireball.y,npc.x,npc.y) then
				npc.hp-=1
			end
		end
		if npc.hp<0 then
			--spawn_burnt_farm(farm.x,farm.y+8)
			sfx(2)
			spawn_ashes(npc.x,npc.y)
			burn_time(npc.id)
			if npc.class=='wizard' then
				wizards-=1
				spawn_treasure(npc.x,npc.y,ceil(rnd(4))+4)
				sfx(15)
			elseif npc.class=='elf' then
				spawn_treasure(npc.x,npc.y,ceil(rnd(4))+1)	
			elseif npc.class=='knight' then
				spawn_treasure(npc.x,npc.y,ceil(rnd(4))+2)
			elseif npc.class=='farmer' then
				spawn_treasure(npc.x,npc.y,ceil(rnd(8))-7)
			end
			del(npcs,npc)
		end
		if npc.hp<=npc.hp_max/2 and npc.on_fire!=true then
			spawn_burning(npc.x,npc.y,npc.id)
			npc.on_fire=true
		end
		
		--wizard firing fire sequence
		if npc.class=='wizard' and near_dragon(npc.x,npc.y,2) and sqrt((dragon.x-npc.x)^2+(dragon.y-npc.y)^2)<64 then
			npc.casting=true
			npc.target_lock+=1
			if npc.target_lock>npc.start_fire then
				if npc.target_lock>npc.stop_fire then
					npc.target_lock=-10
				end
				npc.cooldown=npc.attack_speed+rnd(npc.attack_speed)
				local vector=atan2((dragon.x-npc.x),(dragon.y-npc.y))
				local vecx=cos(vector)
				local vecy=sin(vector)
				if vecx>0 then
					npc.missile_sp_flip_x=false
				else
					npc.missile_sp_flip_x=true
				end
				if vecy>0 then 
					npc.missile_sp_flip_y=false
				else
					npc.missile_sp_flip_y=true
				end
				if abs(vecx)<0.5 then
					npc.missile_sp=56
				else
					npc.missile_sp=72
				end
				enemy_missile(
					npc.x,
					npc.y,
					vecx*npc.missile_speed,
					vecy*npc.missile_speed,
					npc.missile_sp,
					npc.missile_sp_flip_x,
					npc.missile_sp_flip_y,
					npc.missile_damage,
					npc.missile_pierce,
					npc.class
				)
				sfx(5)
			end
		elseif npc.class=='wizard' then
			npc.casting=false
			npc.target_lock=0
		end
		
		--elf firing sequence
		if npc.class=='elf' and near_dragon(npc.x,npc.y,2) and sqrt((dragon.x-npc.x)^2+(dragon.y-npc.y)^2)<64 then
			npc.cooldown-=1
			if npc.cooldown<1 then
				npc.cooldown=npc.attack_speed+rnd(npc.attack_speed)
				local vector=atan2((dragon.x-npc.x),(dragon.y-npc.y))
				local vecx=cos(vector)
				local vecy=sin(vector)
				if vecx>0 then
					npc.missile_sp_flip_x=false
				else
					npc.missile_sp_flip_x=true
				end
				if vecy>0 then 
					npc.missile_sp_flip_y=false
				else
					npc.missile_sp_flip_y=true
				end
				if abs(vecx)<0.5 then
					npc.missile_sp=68
				else
					npc.missile_sp=52
				end
				enemy_missile(
					npc.x,
					npc.y,
					vecx*npc.missile_speed,
					vecy*npc.missile_speed,
					npc.missile_sp,
					npc.missile_sp_flip_x,
					npc.missile_sp_flip_y,
					npc.missile_damage,
					npc.missile_pierce,
					npc.class
				)
				sfx(14)
			end
		end
	
		if npc.class=='knight' then
		
			--charging knights don't have sprite trailing
			if npc.charging!='no' then
				npc.sp_y=npc.y
				npc.sp_x=npc.x
			end
		
			if npc.stun_time>0 then
				npc.stun_time-=1
			else
				--knight charge decision behaviour
				if abs(dragon.y-npc.y)<8 and npc.cooldown==0 and npc.charging=='no' then
					npc.charging='x'
					sfx(9)
					if dragon.x<npc.x then
						npc.charge_direction=-4
						npc.flip_x=true
					else
						npc.charge_direction=4
						npc.flip_x=false
					end
				end
				--knight charges up/down if x-aligned with dragon
				if abs(dragon.x-npc.x)<8 and npc.cooldown==0 and npc.charging=='no' then
					npc.charging='y'
					sfx(9)
					if dragon.y<npc.y then
						npc.charge_direction=-4
					else
						npc.charge_direction=4
					end
				end
			end
			--knight hits
			if check_collide(dragon.x,dragon.y,npc.x,npc.y) then
				dragon.hp-=2
				dragon.last_hit=npc.class
				spawn_hit(npc.x,npc.y)
				spawn_hit_circle(npc.x,npc.y)
				spawn_ashes(npc.x,npc.y,'blood')
				sfx(6)
			end
			--knights can't charge off-screen
			if npc.charging!='no' and npc.x!=mid(0,npc.x,504) or npc.y!=mid(0,npc.y,504) then
				npc.x=mid(0,npc.x,504)
				npc.y=mid(0,npc.y,504)
				npc.charging='no'
				npc.stun_time=45
			end
		end
	end
end

function enemy_missile(x,y,vx,vy,sp,sp_flip_x,sp_flip_y,damage,pierce,class)
	local missile={
		class=class,
		damage=damage,
		pierce=pierce,
		sp=sp,
		sp_flip_x=sp_flip_x,
		sp_flip_y=sp_flip_y,
		vx=vx,
		vy=vy,
		x=x,
		y=y,
	}
	add (missiles,missile)
end

function update_enemy_missiles()
	for missile in all (missiles) do
		missile.x+=missile.vx
		missile.y+=missile.vy
		if check_collide(missile.x,missile.y,dragon.x,dragon.y) then
			dragon.hp-=missile.damage
			dragon.last_hit=missile.class
			spawn_hit(missile.x,missile.y)
			spawn_hit_circle(missile.x,missile.y)
			spawn_ashes(missile.x,missile.y,'blood')
			sfx(6)
			if missile.pierce==false then
				del(missiles,missile)
			end
		end
		if mid(missile.x,0,512)!=missile.x or mid(missile.y,0,512)!=missile.y then
			del(missiles,missile)
		end
	end
end

function draw_entities()
	for npc in all (npcs) do
		if not (npc.stun_time>0 and anim_clock%4>2) then
			spr(npc.sp,npc.sp_x,npc.sp_y)
		end
		if npc.class=='wizard' and npc.casting==true and anim_clock%2==0 then
			circ(npc.x+4,npc.y+4,10,12)
		end
	end
	
	for treasure in all(treasures) do
		spr(treasure.sp,treasure.x,treasure.y)
	end
	
	for missile in all (missiles) do
		spr(missile.sp,missile.x,missile.y,1,1,missile.sp_flip_x,missile.sp_flip_y)
	end
end

-->8
--particle code

function spawn_smoke(x,y)
	--if stat(1)<0.95 and anim_clock%3==1 then
	if total_particles<600 and anim_clock%3==1 then
		local puff={
			age=30+rnd(30),
			c=ceil(rnd(2))+4,
			rise=rnd(1)/1.5,
			r=0.1,
			x=x+rnd(8),
			y=y-rnd(8),
			}
		add(smoke,puff)
	end
end

function spawn_spark(x,y)
	--if stat(1)<0.95 and anim_clock%3==1 then
	if total_particles<600 and anim_clock%3==1 then
		local spark={
			age=rnd(20),
			c=ceil(rnd(3))+7,
			drift=(rnd(2)-1)/5,
			rise=rnd(1)/2, --lots of random numbers and/or decimals causing slowdown?
			x=x+ceil(rnd(8)),
			y=y+ceil(rnd(8)),
			}
		add(sparks,spark)
	end
end

function spawn_hit(x,y) --(x,y,c)
	for i=1,10 do
		local hit={
			x=x+4,
			y=y+4,
			xc=(rnd(1)-0.5)/2,
			yc=(rnd(1)-0.5)/2,
			c=8,--c=c,
			age=10,
		}
		add(hits,hit)
	end
end

function spawn_hit_circle(x,y) --(x,y,c)
	local hit_circle={
		x=x+rnd(8),
		y=y+rnd(8),
		r=5,
		c=7,
		age=10,
	}
	add(hit_circles,hit_circle)
end

function update_particles()
	total_particles=#smoke+#sparks
	for puff in all (smoke) do
		puff.age-=1
		if total_particles>500 then
			puff.age-=1
		end
		if puff.age<1 then
			del(smoke,puff)
		end
		puff.x+=(rnd(2)-1)/5
		puff.y-=puff.rise
		puff.r+=0.1
	end
	for spark in all (sparks) do
		spark.age-=1
		if total_particles>500 then
			spark.age-=1
		end
		if spark.age<1 then
			del(sparks,spark)
		end
		spark.x+=spark.drift
		spark.y-=spark.rise
	end	
	for hit in all(hits) do
		hit.x+=hit.xc
		hit.y+=hit.yc
		hit.age-=1
		if hit.age<0 then
			del(hits,hit)
		end
	end
	for hit_circle in all (hit_circles) do
		hit_circle.age-=1
		if hit_circle.age<1 then
			del(hit_circles,hit_circle)
		end
	end
end

function draw_particles()
	fillp(0b01011010010110100101.1)
	for puff in all (smoke) do
		if near_dragon(puff.x,puff.y,1) then
			--pset(puff.x,puff.y,5)
			--if anim_clock%2==1 then
			circfill(puff.x,puff.y,puff.r,puff.c)
			--end
		end
	end
	for spark in all (sparks) do
		if near_dragon(spark.x,spark.y,1) then
			pset(spark.x,spark.y,spark.c)
		end
	end
	for hit in all (hits) do
		if near_dragon(hit.x,hit.y,1) then
			pset(hit.x,hit.y,hit.c)
		end
	end
	for hit_circle in all (hit_circles) do
		if hit_circle.age%2==0 then
			circ(hit_circle.x,hit_circle.y,hit_circle.r,hit_circle.c)
		end
	end
	fillp()
end
__gfx__
00000000eeeeeee88eeeeeeeeee9eeeeee6666eeeee99999999999eeeeebeeeeeeeeeeeeeeeeeee71eeeeeeeeeeeee5eeee9eeeeeee999eeeeeee888888eeeee
00000000eeeeee8228eeeeeeee9499eeee00006eee9a999a9aa9a9eeeebbbeeeeeeeeeeeeeeeeeec1eeeeeee5eeeeeeeae9eea9aee99aee9eeeeeee22228eeee
00700700eeeeeea22aeeeeee44444444e656566eee999aa99a99a9eeeebbbeeeeee4eeeeeeeeee71c1eeeeeeeee50eee9a9ae99aa9a999eeeeeee8888888eeee
00077000eeeeee2222eeeeeeeedfdeeee565656ee9aa9a99aa9a949eebbbbeeeeee5eeeeeeeeeec1c1eeeeeee05050509a9a9a9aaa9aeaeeeeeeee222288eeee
00077000e888eee88eee888eeefff49488888888e9999a9aa9aa929ebbbbbbeeee5eeeeeeeeee7171c1eeeee0505050e9a9a9a9aaaa9eeeeeeeeeee2228eeeee
0070070082888e2222e88828eee99944565566589aa9aa9a9aa954593bbbb3eeee45eeeeeeeeec1c1c1eeeeeee5050ee9a9a9a9a9999a9e9eeee888e88eeeeee
000000008282282882882828eee4444e566666589999a99a99995259eb3bbeeeee5eeeeeeeee7171c1c1eeee5eeeeee09a9a9a9aee9a9eeeeeeee282222e2a8e
000000008282282222822828eee4e4ee8522252899a9aaa9a9a954593333beee4e45eeeeeeeec1c1c1c1eeeeeee0eeeeeaeaeaeaeee9a9eee828282828282228
3333333382822e2882e22828eeeeeeeee9eee9eee99999999994545e3b333bee5e545eeeeee717171c1c1eeeeeeeeeeeeeeeeeee000000008828282828282228
333333338e82e882288e28287ee7eeeeeeeaeeeeee5242424242545eb3bbbbeee545eeeee77c1c1c1c1c177eeeeeeeeeeeeeeeee00000000eeeee282222e2a8e
333333338e8ee828828ee8e8e07777009e9ee9e9ee5444444004545eeb33beeeee54eeeee75771c1c1c7756eeee00eeeeeeeeeee00000000eeee888e88eeeeee
33333333eeeee8e22e8eeeee474007009a999a9aee5440044004545eb33333be4e4545eee57667777776656eee060000eeeeeeee00000000eeeeeee2228eeeee
33333333eeeeeee88eeeeeee77700777999a99a9ee5400004004545ebb3b3bbee454eeeee56665666566650ee5666000ee0eeeee00000000eeeeee222288eeee
33333333eeeeeee22eeeeeeeff777700e9a9a99eee5400004444545eee22eeeeee45eeeee00555555555500ee0055550ee50eeee00000000eeeee8888888eeee
33333333eeeeeee88eeeeeeeee5e76e0ee9aa9eeee540000424252eeee44eeeeee54eeeeee757665766565eeee050665e0050eee00000000eeeeeee22228eeee
33333333eeeeeeee8eeeeeeeee6e76e7eeaaa9eeeee2000024245eeee44e4eeee54e4eeeee706655665550eeee70665500555eee00000000eeeee888888eeeee
34343434eeee9eeeeeee9eeee9ee9eee99e9eeeeeeeeeeeeeeee5eeeeebbbbeeeeeeeeeeeee5555555550eeeeee5550555550eee00000000eeeeeeee9eeeeeee
43434343e99e9eeee9e99eeeee99ee9ee9e9ee9eee54eeeeeeee0e0eebb3bbbbeeeeeeeeeee7657665765eeeeee7650005765eee00000000eeeeee99499eeeee
34343434ee9e99eeeee99e9eee9e999e999a9eeeee024eeeeee2545eb3bbb3bbeeeeeeeeeee7656555660eeeeee7650005660eee00000000eeee994494499eee
43434343999999e9ee99999ee99999eee9a9999eee542ee42ee4020e3b333b3beeee5e5eeee0555006550eeeeee0550ee6550eee00000000ee9944ee9ee4499e
3434343499a9aa9e9e9aaaa99e9a9a99e99aa9eeee02eeee4ee2545e33b3b3b3e54e45eeeee7665007655eeeeee7660e07655eee00000000e944eeee9eeee449
4343434399aaa9999999aa9ee9aaa99e99aaa999ee54eeee2424020ee3b3333eeee45eeeee766550076565eeee766550070505ee00000000e99944ee9ee44999
34343434e9aaaa9ee9aaa99ee99aaa9ee99aa99eee020505424254eeeee44eeeeee54eeee75555500655550ee75505500655550e00000000e94e994494499e49
43434343ee9999eeee9a99eeee9999eeee9999eeeee4505024240eeeee4e44eeee5e54eee76657677666565ee76650077606565e00000000e94eee99499eee49
44444444eeeeeeeeeee7aeeeeeeeeeeeeeeeeeeeeeeeceeee4bbbbbe4ee4eeeeeeeedeeee76556600665565ee76550600600565e00000000e94eeee494eeee49
44444444e944499eee7a9aeeeeeeeeeeeeeeeeeeeeecceee46ecfcbe949eeeeeeeeecdeee05555022655550ee05050000005550e00000000e94ee9949499ee49
4444444494449449ea9aa7eeeee7beeeeeeeeeeeee9999ee46efff99e4449eeeeeeecceee76560244476650ee76560000000650e00000000e949944e9e449949
4444444494a49449e9799aaeee7bb3ee99eeee6ecccccccc46ebbb99e4444999eeedceeee76560055566555ee76000000000555e00000000e9444eee9eee4449
444444449999999279aa797ee7b33b3ee44444679e0406ee46bbbbb9ee944449eeecceeee05550244465550ee05500555500550e00000000ee9944ee9ee4499e
4444444494449429aa79a79aebbb3b3e99eeee7e4c7776ce46b4444bee24fff4eeeedceee76650059565765ee76005555500765e00000000eeee994494499eee
444444449222929ee79e99eeee3bb3eeeeeeeeee4c777ccc46bbbbbbee24ee24eeeecdeee76550244465660ee76505555500660e00000000eeeeee99999eeeee
44444444999999eeaeeaee7aeee33eeeeeeeeeee4e77cccce4e4ee4eee24ee24eeeeceeeee555024446550eeee555555556550ee00000000eeeeeeee9eeeeeee
33333333eeeeeee88eeeeeeeeee8e8eeeee9e9ee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000eeeeeeeeeeeeeeee
33b333a3eeeeee8228eeeeeee8eeee8eeee949ee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000eeeeeeeeeeeeeeee
33333333eeeeeea22aeeeeeeeee8eeeeeeee4eee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000eeeee888888eeeee
333333b3eeeeee2222eeeeeeee8e8eeeeeee4eee000000000000000000000000ecceeddeecceedde00000000000000000000000000000000eeeee8888888eeee
33733333eee8eee88eee88eee8e8e8e8eeee4eee000000000000000000000000cdccdccccdccdccc00000000000000000000000000000000eeeeeee2228eeeee
33333333ee888e2222e888eeee8e8e8eeeee4eee000000000000000000000000eeedceeeeeedceee00000000000000000000000000000000eeee888e88eeeeee
b3333b33ee882828828888eee8eeeeeeeee766ee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000eeeee282222e2a8e
33333333ee882822228288ee8eee8ee8eeee7eee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000ee88282828282228
3b333333ee882e2882e288ee0111111111111111111111118008008888ee00008888e0000008e000008888ee0008e0008e000ee0088888eee888282828282228
33333b33ee88e882288e88ee110000000000100000000001282880888888ee0088888e0000888e000888888820888e0088e008e28888888eeeeee282222e2a8e
33333b33eee8e828828e8eee00010101010101010101010008898088822288e0882228e0088228e008822222288888e0888e088288222222eeee888e88eeeeee
33333333eeeee8e22e8eeeee10101010101010101010100129888088820088e288200882088208e208820000088228828888888288888e00eeeeeee2228eeeee
3b3b3333eeeeeee88eeeeeee10010000000000000001010180898088820088828820088208e20882088208ee0882088288888882088888e0eeeee8888888eeee
33b33b3beeeeeee88eeeeeee1010000000000000000110019898809982009982898e9822088e88920982088e29820892898898920022298eeeeee8888888eeee
333333b3eeeeeeee8eeeeeee1001000000000000000101019999809992009992989999800988999208920099289209829829898200009899eeeeeeeeeeeeeeee
3b333333eeeeeeeeeeeeeeee1010000000000000000110019a9990a9a9a9a92099a22992a9922a9a299a9a9a2999a992a92099a299a9a9a2eeeeeeeeeeeeeeee
33333333000000000000000010010000000000000001010199aa90aaaaaa2200aaa20aa2aaa20aaa20aaaaa220aaaa22aa200aa2aaaaaa220000000000000000
33334443101110110000000010100000101010100001100199000002222220000222002202220022200222220002222002200022022222200000000000000000
3343333300000000000000001001000000000000000101019a099999009900099999909909909999909999909999909909909900990999000000000000000000
3333333311101110111111111010000001010101000110010a0aaaaaa0aa000aaaaaa0aa0aa0aaaaa0aa0aa0aa0aa0aa0aa0aaa0aa0aa0aa0000000000000000
4333334400000000000000001001000000000000000101010a077007707700077007707707707000007707707707707707707770770770770000000000000000
333443331011101110111011101000001010101000011001aa077777707700077777707777707077707777007707707707707707770770770000000000000000
343333430000000000000000100100000000000000010101aa0aaaaa00aaaa0aaaaaa0000aa0a00aa0aa0aa0aa0aa0aa0aa0aa0aaa0aa0aa0000000000000000
3333333311101110111011101010000001010101000110010a099000009999099009909999909999909909909999909999909900990999000000000000000000
33333333000101111110100010010000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000
35333335001011111111010010100000000000000001100100000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000101111110100010010000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333010011111111001010101111111111111111100100000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000101111110100010010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333001011111111010010100010101010101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000
33533333000101111110100010000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000
33333533010011111111001011111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
07010101010101010101010107010101010101010101010101010101010101010101010101010101010101010101010102020202030303020202020202030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101070101010101010101010101010101010101010101010101010101010101010101010102020203030303030302020303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101070101010101010101010101010101010101010101010101010101010101010101010202020203030303030303030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101070101010101010101010101010101010101010101010101010101010101010101020202020303030303030303030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101070101010101010101010101010101010101010101010101010101010101010101020202030303030303030303030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101070101010101010101010101010101010101010101010101010101010101010101020203030303030303030303030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07010101010101010101010107010101010101010101010101010101010101010101010101010101010101010101020203030303030302020203030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07010101010101010101010107010101010101010101010101010101010101010101010101010101010101010101020203030303030202020202020303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070101010101010101010701010101010101010101010101010101010101010101010101010101010101010101020203030303020202020202020203030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010707010101010107070101010101010101010101010102020101010101010101010101010101010101010101020203030302020202020202020202030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101070707070701010101010101010101010202020202010101010101010101010101010101010101010101020203030202020202020202020202030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010102020203030202010101010101050505050505010101010101010101020202030202020202020202020202020303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101010101010101010101010101020202030303020201010101050505050505050505050501010101010101020202020202020201010101020202020202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020101010101020202020201020202020303030202020101010101050101010101010101050505010101010101020202020201010101010101010101010202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020202020202020203030202020303030302020201010101010101010101010101010101010505050101010101010202020101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02030303030303030303030303030302020202010101010101010101010101010101010101010505050501010101010101010101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303030303030303030202020202020101010101010101010101010101010101010101010505050505010101010101010101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030302020202020202020201010101010101010101010101010101010101010101010101010505050505010101010101010101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03020202020101010101010101010101010101010101010101010101010101010101010101050505050505050505010101010101010101010101010101010102
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020201010101010101010101010101010101010101010101010101010101010101010105050505050505050505050501010101010101010101010101010102
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020101010101010101010101010101010101010101050101010101010101010101050505050505050505050505050505010101010101010101010101010202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010101010101010101010101010101010101010101050505050501010101010505050505050505050501010101050505010101010101010101010101010202
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010101010101010105050505050505050505050505050505050101010101010105050101010101010101010101020203
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010101010101010101010105050505050505050105050505010101010101010101050501010101010101010101020203
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010101010101010101010101010101010101010505050505010101010101010101010101010101010101010101020303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010101010101010101010101010101010101010505050501010101010101010101010101010101010101010102020303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010505010101010101010101010101010101050505050501010101010101010101010101010101010101010202030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101050505050505050505050505010101010101010105050505050101010101010101010101010101010101010202020202030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010505050505050505050101010105010101010101010505050505050101010101010101010101010101010102020202020203030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010105050505050505010101010101010101010101010101050505050505010101010101010101010101010102020202020202030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010505050505050101010101010101010101010101010505050505050501010101010101010101010101020202020203030303030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010105050505050501010101010101010101010101010101050505050505050101010101010101010101010102020203030303030303030303030303
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000010101000101000000000000000000000101010001010101010000000000000001010100010101010000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3030303030305050202020101010101010101010101010404040101010505010505010101010101010101010101010202030303030202020101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303020201010101010101010101010101040404040401010104040101040104040104010101010101010202030303030202010101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030302020102020101010101010101010101040404040401010404040404010104040401010101010101010102020303030202010101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030202010101020201020201010101010101010104040401010404040401040404040101010101010101010102020203030201010101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303020201010101010102020202020101010101010101040101040404040404040404010101010101010101010101020203030201010101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3020202020101010101010201020303020201010101010101040104040404040404040401010101010101010101010101020202030201010101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020201010101010101020202020202030201010101010101010104040404040401010101010101010101010101010101010202020201010101010101010101072000000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2010202010102010202010202020102020201010101010101010101040404040101010101010101010101010101010101010102020101010101010101010101061616161535454646454545561616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010102020202010201010101020202020101010101010101040401010101010101010101010101010101010101010101010101010101010101010101010101061616161636464646464646561616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1020202030302020101010101010101010101010101010101010404040401010101010101010101010101010101010101010101010101060101010101010101072005354636464646464646554550071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020303030202010101010101010101010101010101010101010404010101010101010101010101010101010101010101010106010601060606010101010101072006364646464646464646464650071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2030303020201010101010101010101010101010101010101010101010101010101010101010101010101010101010606060101060106060106010101010101072006364646464646464646464650071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020101010101010101010101010101010101010101010101010101010101010101010101010101010106060606060606060606060601010101010101072006364646464646464646464650071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010601060606060606060606010101010101010101072007374747474747474747474750071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101060106060606060606060606010101010101010101062626262626262626262626262626262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101060601060606060606060101010101010101010101061616161616161616161616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101060606060606060606060101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010202020202020202010101010101010101010101010101010101010101010101010106060606060601010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010102020203030303030302020101010202020201010101010101010101010101010101010106010606060601010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010102030303030303030303020201020203030201010101010101010101010101010101010106060601010601010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010102020202020303030303030202020303030201010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101020202020303030303030303030201010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101020203030303030303030201010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101020203030303030303020201010101010101010101010101010101010101010101010101010101010101010101010102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101020303030303030303020202020101010101010101010101010101010101010101010101010101010101010101020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010102020303030303030303030303020201010101010101010101010101010101010101010101010101010101010202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010102030303020303020203030303030202020201010101010101010101010101010101010101010101010202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010102030302020202020202030303030303030202020101010101010101010101010101010101010102020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101070707070701010101010102030202010101010102020203030202030303020101010101010101010101010101010101010202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010707010101010107070101010102030201010101010101010202020202020202020101010101010101010101010101010102020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1070101010101010101010701010102020201010101010101010101010101010101010101010101010101010101010101010202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7010101010101010101010107010101010101010101010101010101010101010101010101010101010101010101010101020202030302020202020202020303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800002f45437454394543a4543b4543b454384542c4540e4000340001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000000463302603046030260303603036030360302603026030260301603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000026130462305633066230c613000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00003363433635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000c6540c655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000019550336532d6531c6530f653316530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000000036350186502e3501d6502e350206503235020650353501b650000001360000000000000860000000000000000002600000000000000000006000000000000000000000000000000000000000000
010400001505015050000000000039052330523904233042390323303239022330223901233012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001b150151500d150081500c150121501c15021150141000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000181521825200002000021f1521f2521f1521f25200102002020010200202181521825200102002021f1521f2521f1521f2521f1521f2521f1521f2520000200002000000000000000000000000000000
0108000018550185501e5501e55022550225502155022550215502255021550225502155022550215500040000400000000000000000000000000000000000000000000000000000000000000000000000000000
010400002c250207202c220207202b2501f7202b2201f7201c2501c7201c2201c7200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0107000003150051500515008150091500b1500b1500c1500c1500c1500c1500a1400813005120001100010000200002000020000200002000000000000000000000000000000000000000000000000000000000
00040000080500c050000000000000000000000b0500c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000c24300200006000050007000070000700007000070000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000184501f450244502b45200000244502b4502b4522b4522b45200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000022500425007250092500c2500f25011250122501525017250192501c2501e25021250232502525027250282502a2502c2502c2502d2502e2502f2502f2503125032250332503525036250372503a250
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01100000112500020011255112550c250002000c2550c4550c250002000c2550c2550c250002000c2550c4550c250002000c2550c2550c250002000c2550c4550e25000000000000000000000000000000000000
011000001825000200182551825513250002001325513455132500020013255132551325000200132551345515250002001525515255102500020010255104551025000000102551045510450003001045510455
011000000525005255052500525500250002550025000255002500025500250002550025000255002500025500250002550025000255002500025500250002550225002250022550000000000000000000000000
011000000c2500c2550c2500c25507250072550725007255072500725507250072550725007255072500725509250092550925009255042500425504250042550425004255042500425504250042550425004255
011000001145000000104500e4500c4500c4500c4500c4500c4450000012450134501545013450154501745018450184551845518455184501845518455184551a4501a4501a4501a44500000000000000000000
01100000184500000017450154501345013450134401343000000000000e450104601245013450154501545021440000001f4501e4601c4501c4501c4501c4401c43000000184501a4501c4501e4501f4501f450
011000000c250002000c2550c2550e250002000e2550e26510250002001025510255102550020010255002051c25000200102551025510255002001d250002001025510255102550020018250002001a25000300
011000000025000255002500025502250022550225002255042500425504250042550425004255042500425510250102550425004255042500425511250112550425004255042500425500250002550225002255
0110000012450134501545017450184501845518455184551a4501a4551a4551a4551a4501a4551a4551a45513450124501045010450104501045010450104500b450104501345017455174501c4501f45023455
011000001c450000001e4501f45023450234502345023450234500000023450244502345000000214500000021450000001f4501e4501c4501c4501c4501c4501c450000001c4501a45018450174501545013450
011000000c373000030c3730c37324673000030c373000030c373000030c3730c37324673000030c373000030c373000030c3730c37324673000030c373000030c373000030c3730c37324673000030c37300003
01100000344503b45037450344503b45037450344502f450284502f4502b450284502f4502b45028450234501c450234501f4501c450234501f4501c45017450104501745013450104501745013450104500b450
011000001525000200152551525515255002001525500200152500020015255152551525500200152550020515250002001525515255152550020016250002001525515255152550020011250000001325000300
011000001025010255042500425504250042550425004255102501025504250042550425004255042500425510250102550425004255042500425511250112550425004255042500425500250002550225002255
011000000c373000030c3730c37324673000030c373000030c373000030c3730c37324673000030c373000030c373000030c3730c3732467300003246730000300000000000c3730c37324673000030c37300003
014000003c6350000000000000000c000180002400030635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c3730000000000000000000000000186730000000000000000c37300000186730000000000000000c3730000000000000000000000000186730000000000000000c3730000018673000030c3730c373
011000000443004430044300443004430044300443004430044300443004430044300443004430044300443004430044300443004430044300443004430044300443004430044300443004430044300443004435
011000001c250002001025510255102550020010255002001c250002001025510255102550020010255002051c25000200102551025510255002001d250002001025510255102550020018250002001a25000300
__music__
00 3f 42 43 3c
00 3f 3e 43 3c
00 3f 3e 3d 3c
00 3f 3e 3d 3c
00 3f 3a 3b 3c
00 3f 3a 3b 3c
00 3f 3a 3b 39
00 3f 3a 3b 39
00 38 3a 3d 3c
00 3f 3a 3d 44
01 3f 3a 37 36
00 33 34 37 35
00 3f 3a 37 36
00 33 34 37 35
00 2e 30 37 32
02 2d 2f 37 31
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
