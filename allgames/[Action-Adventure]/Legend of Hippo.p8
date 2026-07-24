pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- by elastiskalinjen

p1x = 64
p1ox = p1x
p1y = 64
p1oy = p1y
p1xtile = flr(p1x/8)
p1ytile = flr(p1y/8)

p1acc = 0.3
p1speed = 0.7

p1startspeed = 0.7
p1halfspeed = p1startspeed / 1.5

p1dx = 0
p1dy = 0
p1state = 0
p1angle = 0
p1size = 3.8
p1lives = 3
p1weapon = 0
p1dustcounter = 0

startbulletspeed = 0.7
curr_b_spd = startbulletspeed
maxbulletspeed = 5
p1bulletangle = 0

p1bspdx = 0
p1bspdy = 0
p1velx = 0
p1vely = 0

hardwall = 3
normalwall = 1
destroyablewall = 7

p1explodetimerstart = 16
p1explodetimer = 0
p1bcrumbsdur = 12
breadcrumb_timer = p1bcrumbsdur

p1win = false
p1goal = false
p1lost = 0
p1key = false

p1spr = 55
p1t, p1f, p1s = 0, 1, 8 --t, f, s
p1sprnormal = {55, 56, 57, 58}
p1sprbomb = {42, 43, 44, 45}
p1sprcharg = {2, 3}

ppc=0

function updateplayer()
	saveoldpos()
	spawnbreadcrumbs()
	animateplayer()
	player_item_collision()

	if p1state < 2 then
		move()
		aim()
	elseif p1state == 2 then
		shoot()
	elseif p1state == 3 then
		calc_bullet_vel()
		isbullet()
	elseif p1state == 4 then
		explode()
	end
	p1bulletangle = getangle(p1x, p1y, p1ox, p1oy)

	if p1state == 1 or p1state == 3 then 
		if ppc < 2 then
			ppc+=1
		else
			ppc=0
			init_particle(p1x+rnd(4)-rnd(4),p1y-rnd(4)+rnd(4),1+rnd(2),circol,0.01,0.01)
		end
	end
end

function move()
	p1dx *= 0.85
	p1dy *= 0.85

	p1dx=min(p1dx, p1speed)
	p1dx=max(p1dx,-p1speed)
	p1dy=min(p1dy, p1speed)
	p1dy=max(p1dy,-p1speed)

	if abs(p1dx) >= 0.1 or abs(p1dy) >= 0.1 then
			if p1dustcounter < 16 then
				p1dustcounter+=1
			else
				p1dustcounter=1
				sfx(24+flr(rnd(2)))
				init_particle(p1x,p1y+4,2,13,0.1,0.1)
			end
	end

	if not wal_coll(p1x + p1dx, p1y, p1size, p1size, solid_wall)
		and not wal_coll(p1x + p1dx, p1y, 1, 1, side_wall) then
		p1x+=p1dx
 	else
		p1dx*=-0.5
 	end

 	if not wal_coll(p1x, p1y + p1dy, p1size, p1size, solid_wall)
	 and not wal_coll(p1x, p1y + p1dy, 1, 1, side_wall)then
		p1y+=p1dy
 	else
		p1dy*=-0.5
 	end

	if btn(0) then p1dx-=p1acc end
	if btn(1) then p1dx+=p1acc end
	if btn(2) then p1dy-=p1acc end
	if btn(3) then p1dy+=p1acc end
end

function saveoldpos()
 	p1ox = p1x
	p1oy = p1y
	p1xtile = flr(p1x/8)
	p1ytile = flr(p1y/8)
end

function aim()
	if is_held(4) then
		if p1speed == p1halfspeed then
			p1f=1
		end
		if p1speed > p1halfspeed then
			p1speed-=0.015
		end
		p1state = 1
		p1angle = getangle(p1x,p1y,p1ox,p1oy)
		chargeshoot()
	end

	if is_released(4) then
		p1speed = p1startspeed
		if p1state == 1 then
			p1state = 2
		end
	end
end

function chargeshoot()
	if curr_b_spd < maxbulletspeed then
		curr_b_spd+=0.06 + (p1weapon/100)
		sfx(9)
	end
end

function shoot()
	sfx(10)
	p1state=3
	p1bspdx=curr_b_spd * (1 + p1weapon/10)
	p1bspdy=curr_b_spd
	p1f=1
end

function calc_bullet_vel()
	p1velx = cos(p1angle) * p1bspdx
	p1vely = sin(p1angle) * p1bspdy
end

function isbullet()
	local issolidx = false

	if p1weapon == 0 or p1weapon == 2 then
		if wal_coll(p1x + p1velx, p1y, p1size, p1size, solid_wall) or
			wal_coll(p1x + p1velx, p1y, 1, 1, side_wall) then
			issolidx = true
		end
	else
		if wal_coll(p1x + p1velx, p1y, p1size, p1size, hard_wall) or
			wal_coll(p1x + p1velx, p1y, 1, 1, side_wall) then
			issolidx = true
		end
	end

	if not issolidx then
			p1x += p1velx
 	else
		bounce(false)
 	end

	local issoliddy = false
	if p1weapon == 0 or p1weapon == 2 then
		if wal_coll(p1x, p1y + p1vely, p1size, p1size, solid_wall) or
			wal_coll(p1x, p1y + p1vely, 1, 1, side_wall) then
			issoliddy = true
		end
	else
		if wal_coll(p1x, p1y + p1vely, p1size, p1size, hard_wall) or
			wal_coll(p1x, p1y + p1vely, 1, 1, side_wall) then
			issoliddy = true
		end
	end
 	if not issoliddy then
		p1y += p1vely
 	else
	 	bounce(true)
 	end

	p1bspdx *=0.97
	p1bspdy *=0.97

	if abs(p1velx) <= 0.5 and abs(p1vely) <= 0.5 then
		p1dx = 0
		p1dy = 0
		curr_b_spd = startbulletspeed

		if p1weapon < 2 then
			p1state = 0
			if p1weapon == 1 then
				remove_item_under_player()
			end
		else
			p1state = 4
			p1explodetimer = p1explodetimerstart
		end
	end
end

function remove_item_under_player()
	if p1fgetvalue == fgetpots then
		destroy_pot(p1x/8, p1y/8, nil)
	end
	if p1fgetvalue ~= 0 and p1fgetvalue ~= 16 and p1fgetvalue ~= fgethurt then
		mset(p1x/8, p1y/8, 90)
		sfx(17)
	end
end

function bounce(isy)
	shake+=0.02
	small_expl(p1x,p1y,circol,1)
	if isy then
		if p1weapon == 0 then
			p1bspdy *= -0.8
			sfx(1)
		elseif p1weapon == 1 then
			p1bspdy *= -0.2
			p1bspdx *= 0.4
			sfx(2)
		else
			p1bspdy *= -0.01
			p1bspdx *= -0.01
			sfx(3)
		end
	else
		if p1weapon == 0 then
			p1bspdx *= -0.8
			sfx(1)
		elseif p1weapon == 1 then
			p1bspdx *= -0.2
			p1bspdy *= 0.4
			sfx(2)
		else
			p1bspdy *= -0.01
			p1bspdx *= -0.01
			sfx(3)
		end
	end
end

function resetpos()
	p1x = p1ox
	p1y = p1oy
end

function switchweapon()
	if btnp(5) then
		if p1weapon < 2 then p1weapon+=1 else p1weapon=0 end
		bouncey = 0.1
		sfx(0)
	end
end

function spawnbreadcrumbs()
	if breadcrumb_timer > 0 then
		breadcrumb_timer -= 1
	else
		breadcrumb_timer = p1bcrumbsdur
		place_breadcrumb(p1x, p1y)
	end
end

fgetsteps = 16
fgetpots = 129
fgethurt = 32
function player_item_collision()
	p1fgetvalue = fget(mget(p1x/8, p1y/8))
	if gamestate == 3 then
		if p1fgetvalue == fgetsteps then
			p1win = true
			small_expl(p1x,p1y,circol,8)
		end
		if not (p1state == 3 and p1weapon == 1) and p1fgetvalue == fgethurt then
			player_died()
		end
		if p1fgetvalue == 64 then
			p1key = true
			sfx(22)
			mset(p1x/8,p1y/8,112)
			small_expl(p1x,p1y,1,3)
		end
		if p1fgetvalue == 196 and p1key then
			p1win = true
			mset(p1x/8,p1y/8,54)
			small_expl(p1x,p1y,circol,8)
		end
	end
end

function drawplayer()
	local shouldflip = false
	if p1state < 2 then
		drawplayercircle()
		draw_cursor()
		if p1dx < 0 then
			shouldflip = true
		end
	end
	spr(p1spr,p1x-p1size,p1y-p1size,1,1,shouldflip,false)
end

function draw_cursor()
	if p1state == 1 then
		spr(26+p1weapon, p1x-p1size+cos(p1angle)*7, p1y-p1size+sin(p1angle)*7)
	end
end

function drawplayercircle()
	if curr_b_spd > 0 then
		circol = 9
		if p1weapon == 1 then
			circol = 12
		elseif p1weapon == 2 then
			circol = 8
		end
		circ(p1x, p1y, curr_b_spd*2.2, 7)
		circ(p1x, p1y, curr_b_spd*2.5, circol)
	end
end

function animateplayer()
	local animationarray = nil
	if p1state < 1 then
		p1s = 6
		animationarray = p1sprnormal
	elseif p1state <= 2 then
		p1s = 8
		animationarray = p1sprcharg
	elseif p1state == 3 then
		p1s = 12
		animationarray = {48+ p1weapon*2,48+p1weapon*2+1}
	elseif p1state == 4 then
		p1s = 5
		animationarray = p1sprbomb
	end

	if (p1state < 1 and (abs(p1dx) > 0.1 or abs(p1dy) > 0.2)) or p1state >= 1 then
 		p1t = (p1t + 1) % flr(p1s)
 		if (p1t == 0) p1f = p1f %#animationarray + 1
	end
	p1spr = animationarray[p1f]
end

bouncey = 0
function updateweaponui()
	if abs(bouncey) > 0.01 then
		bouncey = 3*abs(sin(1*time()))
	else
		bouncey = 0
	end
end

function updateui()
	updateweaponui()
end

function drawui()
	rectfill(113, 113-bouncey, 122, 122, 2)
	spr(32+p1weapon,114,114-bouncey)
	rect(113, 113-bouncey, 122, 122, 15)
	draw_game_timer()
end

function print_current_info()
	if level_won > 0 and doorstate == 1 then
		local le = level
		if (game_mode == 2)le=cur_f_p_level
		local currentinfo = "    level: " .. le
		if le == 31 and level_won == 1 then 
			currentinfo = "  last level!!"
		end
		rectfill(camx,camy+72, camx+128,camy+80,0)
		print(currentinfo,camx+32, camy+74,7)
	end
end

function explode()
	if p1explodetimer > 0 then
		p1explodetimer-=1
	else
		p1state = 0
		shake+=0.15
		for x=p1xtile-1, p1xtile+1 do
			for y=p1ytile-1, p1ytile+1 do
				init_explosion(x,y)
			end
		end
	end
end

-->8
-- k hand

keys={}

function is_held(k) return band(keys[k],1) == 1 end
function is_pressed(k) return band(keys[k],2) == 2 end
function is_released(k) return band(keys[k],4) == 4 end

function upd_key(k)
 if keys[k] == 0 then
	if btn(k) then keys[k] = 3 end
 elseif keys[k] == 1 then
	if btn(k) == false then keys[k] = 4 end
 elseif keys[k] == 3 then
	if btn(k) then keys[k] = 1
	else keys[k] = 4 end
 elseif keys[k] == 4 then
	if btn(k) then keys[k] = 3
	else keys[k] = 0 end
 end
end

function init_keys()
	for a = 0,5 do keys[a] = 0 end
end

function upd_keys()
		for a = 0,5 do upd_key(a) end
end
-->8
--main loops

function _init()
	init_keys()
	load_config()
	set_menu_data()
	fadecounter = 14
	fadestate = 2
end

game_mode = 0
function _update60()
	if game_mode == 0 then
		if is_main_menu_active() then
			update_whole_menu()
		elseif next_screen == 0 then
			if not has_loaded_map then
				has_loaded_map = true
				load_map_from_str(cur_ow_str)
			end
			move_ow_camera()
			update_overworldplayer()
		elseif next_screen == 1 then
			update_remix()
		end
		back_menu()
	else
		upd_keys()
		if doorstate == 3 then
			if gamestate == 3 and not p1win then
				foreach(explosions,update_explosion)
				updateplayer()
				foreach(enemies,update_enemy)
			end
			update_game_timer()
		end
		animate_fire()
		foreach(coins,update_coin)
		foreach(pots,update_pot)
		foreach(particles,update_particle)
		updateui()
		if p1state < 2 then
			switchweapon()
		end
		handle_gamestate()
		if p1lost >= 1 and doorstate == 4 then
			update_game_over()
		end
	end

	screentransition()
	animate_door()
end

game_over_fading = false
function update_game_over()
	if btnp(4) and not game_over_fading and p1lost == 1 and game_mode == 1 then
		game_over_fading = true
		sfx(22)
		fadestate = 1
	end

	if btnp(5) then
		sfx(37)
		reset_to_menu()
	end
	if cur_diff == 0 and record_easy < cur_f_p_level then
		dset(3,cur_f_p_level)
		record_easy = cur_f_p_level
	elseif cur_diff == 1 and record_medium < cur_f_p_level then
		dset(4,cur_f_p_level)
		record_medium = cur_f_p_level
	elseif cur_diff == 2 and record_hard < cur_f_p_level then
		dset(5,cur_f_p_level)
		record_hard = cur_f_p_level
	end
	if game_over_fading and fadestate == 2 then
		p1lives = 3
		p1lost = 0
		doorstate = 2
		game_over_fading = false
		reset_entities()
		switch_level()
	end
end

function reset_to_menu()
	if game_mode ~= 0 then
		start_door_shut(12+game_mode)
		game_mode=0
		gamestate=3
		p1lives=3
		p1lost=0
		level_won=0
		fade(0)
		game_over_fading=false
		reset_entities()
	end
end

function _draw()
	if game_mode == 0 then
		draw_whole_menu()
		if next_screen > -1 and not is_main_menu_active() then
			if next_screen == 0 then
					draw_whole_board()
			elseif next_screen == 1 then
				draw_remix()
			elseif next_screen == 2 then
				draw_option()
			end
		end
	else
		do_shake()
		cls(0)
		map(0, 0, 0, 0, 128, 128)
		foreach(particles,draw_particle)
		if (doorstate == 2 or gamestate == 3) and not p1win then
			drawplayer()
		end
		foreach(coins,draw_entity)
		foreach(explosions,draw_explosion)
		if (doorstate == 2 or gamestate == 3) and not p1win then
			foreach(enemies, draw_enemy)
		end
		print_current_info()

		camera()
		drawui()
	end

	camera()
	drawdoors()
	if gamestate == 5 and game_mode > 0 and p1lost >= 1 and doorstate == 4 then
		draw_game_over()
	end
end

function draw_game_over()
	local wave = sin(time())
	circfill(64,64,70-wave*5,0)
	circfill(64,64,60-wave*2,1)
	circfill(64,64,50-wave*3,2)
	circfill(64,64,24+wave*4,9)

	local text="you definitely lost"
	local sprite=124
	local offset=0
	if p1lost == 2 then
		text="you definitely won"
		sprite=35
		if (game_mode == 1)offset=42
	end
	-- make bigger
	zspr(sprite,1,1,52,52-wave*2,3)
	print(text,26,23+wave*2,8)
	print(text,26,22+wave*2,9)
	rectfill(0,110-wave*4,128,122-wave*4,doorcolor)
	if p1lost == 1 and game_mode == 1 then
		print("Ž continue",6+wave*5,114-wave*4,7)
	elseif game_mode == 2 then
		print("score: "..cur_f_p_level,6+wave*5,114-wave*4,14)
	end
	print("— menu", 94-wave*5-offset, 114-wave*4,7)
end

function drawdoors()
	if doorstate == 2 and game_mode >= 1 then
		inithearts(24,40,6,28)
	end
	if doorrx > 0.1 then
		rectfill(0,0,doorrx,128,doorcolor)
		rectfill(doorlx,0,128,128,doorcolor)
	end
end

-->8
-- help functions
function getangle(x1,y1,x2,y2)
 	return atan2(x1-x2,y1-y2)
end

function angle_lerp(angle1,angle2,t)
 angle1=angle1%1
 angle2=angle2%1

 if abs(angle1-angle2) > 0.5 then
	if angle1 > angle2 then
	 angle2+=1
	else
	 angle1+=1
	end
 end

 return ((1-t)*angle1+t*angle2)%1
end

function calcdist(x1,y1, x2, y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

solid_wall = 0
hard_wall = 2
side_wall = 3

-- 1 tile only
function wal_coll(x,y,w,h, wall_type)
	return is_wall_type(x-w,y-h, wall_type) or
	is_wall_type(x+w,y-h, wall_type) or
	is_wall_type(x-w,y+h, wall_type) or
	is_wall_type(x+w,y+h, wall_type)
end

function is_wall_type(x, y, type)
 	val=mget(x/8,y/8)
 	return fget(val,type)
end

function circcoll(x1,y1,rad1,x2,y2,rad2)
	return calcdist(x1,y1,x2,y2) < (rad1+rad2)
end

function animate(o)
 o.t = (o.t + 1) % flr(o.s)
 if (o.t == 0) o.f = o.f %#o.sp + 1
end

function lerp(var,target,pow)
	return var+pow*(target-var)
end

-->8
--entities

explosions={}
function init_explosion(tilex,tiley)
	local e={}
	e.x=tilex*8
	e.y=tiley*8
	e.time=30

	sfx(5)
	local currentmget = mget(tilex,tiley)
	if fget(currentmget,hard_wall) then
		mset(tilex,tiley,112)
	end

	if fget(currentmget) == fgetpots then
		destroy_pot(tilex, tiley, nil)
	end

	for en in all(enemies) do
		if circcoll(e.x+4,e.y+4,3,en.x,en.y,4) then
			enemy_kill(en)
		end
	end
	add(explosions, e)
end

function update_explosion(e)
	e.time -= 1
	if e.time < 0 then
		del(explosions, e)
	end
end

function draw_explosion(e)
	local animframe = 3 - flr(e.time / 10)
	spr(8 + animframe, e.x, e.y)
end

function destroy_pot(tilex, tiley, pot)
	mset(tilex, tiley, 112)
	current_nr_of_pots-=1
	sfx(6)
	small_expl(tilex*8,tiley*8,4,3)
	shake+=0.05
	if pot ~= nil then
		del(pots, pot)
	else
		for p in all(pots) do
			if p.x/8 == tilex and p.y/8 == tiley then
				del(pots, p)
				break
			end
		end
	end
end

function init_entity(tilex, tiley, spr)
	local e={}
	e.x = tilex * 8
	e.y = tiley * 8
	e.spr = spr
	return e
end

coins={}
function init_coin(tilex, tiley)
	local e = init_entity(tilex, tiley, 73)
	e.time = 0
	add(coins, e)
end

function update_coin(e)
	if e.time < 20 then
		e.time +=1
	else
		e.time = 0
		if (e.spr == 73) then e.spr = 74 else e.spr = 73 end
	end

	if not (p1state == 3 and p1weapon == 1) and circcoll(p1x-4,p1y-4,4,e.x,e.y,3) then
		del(coins, e)
		sfx(16)
		small_expl(p1x,p1y,11,3)
	end
end

function draw_entity(e)
	spr(e.spr,e.x,e.y)
end

pots={}
function init_pot(tilex, tiley)
	add(pots, init_entity(tilex, tiley, 89))
end

function update_pot(e)
	if circcoll(p1x-4, p1y-4, 8, e.x, e.y, 4) and p1state == 3 and p1weapon == 0 then
		destroy_pot(e.x/8, e.y/8, e)
		p1bspdx*=0.2
		p1bspdy*=0.2
		del(pots, e)
	end
end

-->8
-- enemies

breadcrumbs={}
max_number_of_breadcrums= 12
function place_breadcrumb(x, y)
	if #breadcrumbs > max_number_of_breadcrums then
		removefirst(breadcrumbs)
	end
	if #breadcrumbs > 0 then
		local firstbreadcrumb = breadcrumbs[#breadcrumbs]
		if calcdist(x,y, firstbreadcrumb.x, firstbreadcrumb.y) > 12 then
			addbreadcrumb(x,y)
		end
	else
		addbreadcrumb(x, y)
	end
end

function addbreadcrumb(x,y)
	local b={}
	b.x = x
	b.y = y
	b.index = 0.001
	b.timer = 120
	add(breadcrumbs, b)
end

function removefirst(table)
	for b in all(table) do
		del(table, b)
		return
	end
end

function bread_to_follow(crumblist, entity, index, closetreshold)
	if index > #crumblist then
		return crumblist[index], 1
	end
	local breadcrumtofollow = crumblist[index]
	local dist = calcdist(breadcrumtofollow.x, breadcrumtofollow.y, entity.x, entity.y)

	if dist < closetreshold and index+1 < #crumblist then
		return bread_to_follow(crumblist, entity, index+1, closetreshold)
	end

	return breadcrumtofollow, index
end

enemies={}
enemychargerange = 36
duration_until_reset_of_bci = 160
function init_enemy(tilex, tiley, type)
	local e={}
	e.x = tilex * 8 + 4
	e.ox = e.x
	e.y = tiley * 8 + 4
	e.oy = e.y

	e.type = type
	e.angle = 0
	e.size = 3

	local spr = 0
	local bspd=0
	if (e.game_mode == 2)bspd=cur_diff*0.2
	if type == 0 then
		e.enemy_start_speed = 0.6+bspd
		spr = 4
	elseif type == 1 then
		e.enemy_start_speed = 0.2+bspd
		spr = 20
	elseif type == 2 then
		e.enemy_start_speed = 0.7+bspd
		spr = 36
	elseif type == 3 then
		e.enemy_start_speed = 0.3
		spr = 12
	end

	e.speed = e.enemy_start_speed
	e.bread_i = 1
	e.l_breadcumb_c = duration_until_reset_of_bci
	e.hit = false
	e.hitangle = 0
	e.t, e.f, e.s = 0, 1, 12
	e.sp = {spr, spr + 1, spr + 2, spr + 3}

	add(enemies, e)
end

function update_enemy(e)
	e.ox = e.x
	e.oy = e.y
	animate(e)
	-- move -> charging
	if p1state == 1 and circcoll(p1x,p1y,curr_b_spd*2.2,e.x,e.y,4) then
		e.x += e.speed*2*cos(-e.angle)
		e.y += e.speed*2*sin(-e.angle)
		sfx(4)
		curr_b_spd*=0.94
		if circcoll(p1x,p1y,1,e.x,e.y,4) then
			player_died()
		end

		return
	end
	if circcoll(p1x, p1y, 4, e.x, e.y, 4) then
		if p1weapon == 0 and p1state == 3 and e.type ~= 1 then
			enemy_hit(e)
		else
			if p1weapon == 1 and p1state == 3 then
				sfx(0)
			elseif e.type == 1 and p1weapon == 2 and p1state >= 3 then
				p1bspdx *= -0.1
				p1bspdy *= -0.1
			else
				player_died()
			end
		end
	end

	local eget = mget(e.x/8,e.y/8)
	if e.type == 2 and eget ~= 46 and eget ~= 47 then
		mset(e.x/8,e.y/8,46+flr(rnd(2)))
		sfx(24)
		small_expl(e.x,e.y,15,1)
	end

	local targetangle = 0
	if e.hit == false then
		targetangle = get_enemy_target_angle(e)
	else
		targetangle = e.hitangle
		enemy_glide(e)
	end
	move_enemy(targetangle, e)

	if e.type == 3 then
		check_goal_collision(e)
	end

 	countdown_and_reset(e)
end

function check_goal_collision(e)
	local currentmget = mget(e.x/8, e.y/8)
	if currentmget == 123 then
		p1goal = true
		enemy_kill(e)
	end
end

function enemy_hit(e)
	if e.hit == false then
		e.angle = p1bulletangle
		sfx(19)
		e.speed = 0.2 + get_impact() * 1.7
		p1bspdx *= 0.5
		p1bspdy *= 0.5
		curr_b_spd *= 0.5
		e.hit = true
		e.hitangle = p1bulletangle
		shake+=0.06
	end
end

function get_impact()
	if abs(p1bspdx) > abs(p1bspdy) then 
		return abs(p1bspdx)
	else 
		return abs(p1bspdy)
	end
end

function enemy_glide(e)
	if abs(e.speed) > 0.1 then
		e.speed = lerp(e.speed, 0, 0.07)
	else
		e.hit = false
		e.speed = e.enemy_start_speed
	end
end

function get_enemy_target_angle(e)
	local playerdist = calcdist(p1x, p1y, e.x, e.y)

	if playerdist > enemychargerange then
		if #breadcrumbs > 0 then
			return get_breadcumb_angle(e)
		else
			return -1
		end
	else
		reset_breadcumb(e)

		return get_player_angle(e)
	end
end

function get_breadcumb_angle(e)
	local crumbtofollow = nil
	local last_bread_i = e.bread_i
	crumbtofollow, e.bread_i = bread_to_follow(breadcrumbs, e, e.bread_i, 6)
	if last_bread_i ~= e.bread_i then
		reset_breadcumb_timer(e)
	end

	return getangle(crumbtofollow.x, crumbtofollow.y, e.x, e.y)
end

function get_player_angle(e)
	return getangle(p1x, p1y, e.x, e.y)
end

function move_enemy(move_angle, e)
	if move_angle ~= -1 then
		e.angle = angle_lerp(e.angle, move_angle, 0.1)
		local velocityx = e.speed * cos(e.angle)
		local velocityy = e.speed * sin(e.angle)

		local kx = 0
		local ky = 0
	 	kx, ky = keep_away(e)
		velocityx -= kx
		velocityy -= ky

		if not wal_coll(e.x + velocityx, e.y, e.size, e.size, solid_wall) and not
			wal_coll(e.x + velocityx, e.y, 1, 1, side_wall) then
			e.x += velocityx
		else
			enemy_crash_if_hit(e)
		end

		if not wal_coll(e.x, e.y + velocityy, e.size, e.size, solid_wall) and not
			 wal_coll(e.x, e.y + velocityy, 1, 1, side_wall) then
			e.y += velocityy
		else
			enemy_crash_if_hit(e)
		end
	end
end

function enemy_crash_if_hit(e)
	if e.hit == true then
		if e.speed > 2 then
			enemy_kill(e)
		else
			e.speed = e.enemy_start_speed
			e.hit = false
		end
	end
end

function enemy_kill(e)
	shake+=0.1
	small_expl(e.x,e.y,2,4)
	del(enemies, e)
	sfx(18)
end

function countdown_and_reset(e)
	if e.l_breadcumb_c > 0 then
		e.l_breadcumb_c -= 1
	else
		reset_breadcumb(e)
	end
end

function reset_breadcumb(e)
	e.bread_i = 1
	reset_breadcumb_timer(e)
end

function reset_breadcumb_timer(e)
	e.l_breadcumb_c = duration_until_reset_of_bci
end

min_dist = 8
limitpush = 12
function keep_away(e)
	local vx = 0
	local vy = 0
	for enemy in all(enemies) do
		if e ~= enemy then
			if calcdist(e.x, e.y, enemy.x, enemy.y) < min_dist then
				vx -= (e.x - enemy.x) / limitpush
				vy -= (e.y - enemy.y) / limitpush
			end
		end
	end

	return vx, vy
end

function draw_enemy(e)
	if e.type == 0 then
		fillp(0b0011001111001100.1)
		circfill(e.x, e.y+4, 3, 1)
		fillp()
	end
	spr(e.sp[e.f], e.x - e.size, e.y - e.size, 1, 1, e.angle < 0, false)
end

-->8
-- level

function spawn_entity()
	current_nr_enemies = 0
	current_nr_coins = 0
	current_nr_of_pots = 0

	for x=(camx/128)*16, (camx/128)*16+16 do
		for y=(camy/128)*16, (camy/128)*16+16 do
			local currentmget = mget(x,y)
			if currentmget == 4 then
				mset(x,y,112)
				init_enemy(x,y,0)
				current_nr_enemies+=1
			elseif currentmget == 12 then
				mset(x,y,119)
				init_enemy(x,y,3)
			elseif currentmget == 20 then
				mset(x,y,112)
				init_enemy(x,y,1)
			elseif currentmget == 36 then
				mset(x,y,17)
				init_enemy(x,y,2)
			elseif currentmget == 1 then
				mset(x,y,112)
				p1x = x*8+4
				p1y = y*8+4
			elseif currentmget == 73 then
				init_coin(x,y)
				mset(x,y,112)
				current_nr_coins+=1
			elseif currentmget == 89 then
				init_pot(x,y)
				current_nr_of_pots+=1
			end
		end
	end
end

fire_counter = 24
function animate_fire()
	if fire_counter > 0 then
		fire_counter-=1
	else
		fire_counter = 24
		for x=(camx/128)*16, (camx/128)*16+16 do
			for y=(camy/128)*16, (camy/128)*16+16 do
				local currentmget = mget(x,y)
				local rand = flr(rnd(2))
				if currentmget == 67 then
					if (rand == 1)mset(x,y,102)
				elseif currentmget == 102 then
					mset(x,y,67)
				elseif currentmget == 115 then
					if (rand == 1)mset(x,y,103)
				elseif currentmget == 103 then
					mset(x,y,115)
				end
			end
		end
	end
end

fadestate = 0
fadecounter = 0
fadespeed = 0.4
function screentransition()
	if fadestate == 1 then
		fadecounter += fadespeed
		if fadecounter >= 14 then
			fadestate = 2
			fadecounter = 14
		end
	else
		fadecounter-=fadespeed
		if (fadecounter <= 0) then
			fadestate = 3
			fadecounter = 0
		end
	end
	fade(fadecounter)
end

camx = 0
camy = 0
gamestate = 3
current_nr_enemies = 0
current_nr_coins = 0
current_nr_of_pots = 0
function handle_gamestate()
	if gamestate == 3 then
		check_current_level_rule()
	elseif gamestate == 5 then
		if doorstate == 3 then
			gamestate = 6
		end
	elseif gamestate == 6 then
		nextlevel()
	end
end

doorrx = 0
doorlx = 128
doorspeed = 0
doorstate = 0
doorcolor = 1
doorcounter = 80
function animate_door() --bad code
	if doorstate == 1 then
		if doorrx < 10 then
			doorspeed = 0.01
		else
			doorspeed = 0.2
		end
		doorrx = lerp(doorrx, 64, doorspeed)
		doorlx = lerp(doorlx, 64, doorspeed)

		if doorrx >= 63.5 then
			if p1lives > 0 and p1lost ~= 2 then
				doorstate = 2
				shake+=0.05
				if (game_mode ~= 0)switch_level()
			else
				doorstate = 4
			end
		end
	elseif doorstate == 2 then
		if doorrx > 53 then
			doorspeed = 0.01
		elseif doorrx > 10 then
			doorspeed = 0.075
		else
			doorspeed = 0.05
		end
		doorrx = lerp(doorrx, -1, doorspeed)
		doorlx = lerp(doorlx, 128, doorspeed)

		if doorrx <= 0.5 then
			if doorcounter > 0 then 
				doorcounter-=1
			else
				doorcounter = 80
				doorstate = 3
				doorlx = 128
				doorrx = 0
			end
		end
	end
end

level_won = 0
function check_current_level_rule()
	if level_won == 0 then
		local c_rule=level_rules[level]
		if (c_rule == 0 and p1win == true)
		or (c_rule == 1 and #enemies == 0)
		or (c_rule == 2 and #coins == 0)
		or (c_rule == 3 and game_timer <= 2)
		or (c_rule == 4 and #enemies == current_nr_enemies and game_timer <= 2)
		or (c_rule == 5 and #coins == current_nr_coins and game_timer <= 2)
		or (c_rule == 6 and current_nr_of_pots <= 0)
		or (c_rule == 7 and p1goal == true)
		then
			levelwon()
		end
	end

	if game_timer <= 0 then
		sfx(17)
		reset_player()
		if level_won == 1 then
			if (game_mode == 1 and level < 32) or (game_mode == 2 and cur_f_p_level < 32) then
				doorcolor = 1
				go_to_next_level()
			else
				go_to_game_over(true)
			end
		else
			doorcolor = 8
			p1lives -= 1
			if game_mode == 2 and cur_f_p_level == 32 then
				go_to_game_over(true)
			elseif p1lives > 0 then
				go_to_next_level()
			else
				go_to_game_over(false)
			end
		end
	end
end

function levelwon()
	if level_won == 0 then
		level_won = 1
		sfx(7)
		shake=0.2
		reset_entities()
		for x=3+(camx/128)*16, (camx/128)*16+12 do
			for y=3+(camy/128)*16, (camy/128)*16+12 do
				if (mget(x,y) ~= 86)mset(x,y,46+rnd(2))
				sfx(26)
				init_particle(x*8+rnd(4)-rnd(4),y*8-rnd(4)+rnd(4),1+rnd(3),6+rnd(2),0,-4)
			end
		end
	end
end

function go_to_game_over(won)
	gamestate = 5
	doorstate = 1
	fadestate = 1
	if not won then
		p1lost = 1
		sfx(12)
	else
		doorcolor = 3
		p1lost = 2
		sfx(27)
	end
end

function go_to_next_level()
	gamestate = 5
	doorstate = 1
	fadestate = 1
	p1win = false
	p1goal = false
	sfx(13)
end

function switch_level()
	if level_won == 1 and game_mode == 1 then
		level += 1
		ow_curr_level = level
		if ow_beaten_levels < level then
			ow_beaten_levels = level
			dset(1, ow_beaten_levels)
		end
	elseif game_mode == 2 then
		cur_f_p_level+=1
		level = scrambled_levels[cur_f_p_level]
	else
		reload(0x1000, 0x1000, 0x1000)
		reload(0x2000, 0x2000, 0x1000)
	end
	camx, camy = get_camera_pos(level)
	reset_entities()
	spawn_entity()
end

function reset_player()
	p1dx = 0
	p1dy = 0
	p1bspdx = 0
	p1bspdy = 0
	p1state = 0
	animationarray = p1sprnormal
	p1f = 1
	p1spr = animationarray[p1f]
	curr_b_spd = startbulletspeed
end

function nextlevel()
	tim = 0
	sfx(14)
	level_won = 0
	p1key = false
	gamestate = 3
	if game_mode == 1 or (game_mode == 2 and cur_diff == 0) then
		game_timer = level_timer[level]
	else
		game_timer = f_level_timer[level]
	end
end

function get_camera_pos(current_level)
	local camerax = ((current_level-1) % 8) * 128
	local cameray = flr(((current_level-1) / 8)) * 128

	return camerax, cameray
end

function player_died()
	level_won = 2
	game_timer = 0
	small_expl(p1x,p1y,8,6)
end

function reset_entities()
	for k,v in pairs(breadcrumbs) do breadcrumbs[k]=nil end
	for k,v in pairs(enemies) do enemies[k]=nil end
	for k,v in pairs(coins) do coins[k]=nil end
	for k,v in pairs(pots) do pots[k]=nil end
	for k,v in pairs(particles) do particles[k]=nil end
end

level=1
level_rules={0,1,2,3,4,5,6,7,0,2,3,6,0,1,7,4,0,6,2,5,3,7,1,0,1,2,4,6,7,3,2,1}
level_timer={500,400,500,500,500,400,500,500,700,600,600,800,600,700,600,240,800,400,500,500,360,500,600,600,520,530,500,520,500,800,660,1080}
f_level_timer={200,180,240,500,500,420,250,140,180,340,600,420,460,450,460,240,340,360,410,400,400,400,320,520,420,500,500,400,400,840,640,920}

function get_rule_string(current_rule)
	if current_rule == 0 then
		return " get to the exit!"
	elseif current_rule == 1 then
		return "kill all enemies!"
	elseif current_rule == 2 then
		return "pick up all coins!"
	elseif current_rule == 3 then
		return  " try to survive!"
	elseif current_rule == 4 then
		return "survive,no killing!"
	elseif current_rule == 5 then
		return "survive,no coins!"
	elseif current_rule == 6 then
		return "destroy all pots!"
	elseif current_rule == 7 then
		return "    score a goal!"
	end
end

tim = 0
function inithearts(x,y,height,speedLimiter)
	tim += 0.5
	for i=1, 3 do
		local healthsprite
		if i <= p1lives then
			healthsprite = 75
		else
			healthsprite = 77
		end
		spr(healthsprite,x+((i-1)*32),y+sin((tim+i)/speedLimiter)*height,2,2)
		rectfill(0,y+32,128,y+40,0)
		print(get_rule_string(level_rules[level]),x+4,y+34+sin(tim/speedLimiter)*1,7)
	end
end

local fadetable={
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
 {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
 {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
 {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
 {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
 {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
 {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
 {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
 {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
 {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
 {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
 {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
 {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
 {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
 {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

-- by comet bomb
function fade(i)
 for c=0,15 do
	if flr(i+1)>=16 then
	 pal(c, 1)
	else
	 pal(c,fadetable[c+1][flr(i+1)])
	end
 end
end

shake=0
function do_shake()
	local shakex=16-rnd(32)
 	local shakey=16-rnd(32)

	shakex*=shake
	shakey*=shake
	camera(camx+shakex,camy+shakey)
	shake=shake*0.95
	if(shake < 0.05)shake=0
	if(shake >= 0.3)shake=0.25
end

game_timer = level_timer[level]
timerx = 4
timery = 114
function update_game_timer()
	if game_timer > 0 then
		game_timer-=1
		if game_timer <= 180 and game_timer % 60 == 0 then
			sfx(23)
		end
	end
end

function draw_game_timer()
	if game_timer < 360 and gamestate == 3 then
		local speed_up = 3+game_timer/60
		local fusex = 4+game_timer/4
		local bombspr = 59
		if(fusex < 6)bombspr = 10
		spr(bombspr+(game_timer / speed_up % 2), timerx, timery)
		line(timerx+4,timery,timerx+fusex,timery,4)
		if fusex > 6 then
			pset(timerx + fusex, timery, 8)
			for i=0, 3 do
				pset(timerx + 2 + fusex - rnd(4), timery+rnd(4)-rnd(4), 8+rnd(3))
			end
		end
		if game_timer <= 180 and game_timer > 0 then
			print(ceil(game_timer / 60), timerx + 2, timery - 5 + fusex / 8, 8)
		end
	end
end

particles={}
function init_particle(x,y,rad,col,dx,dy)
	local p={}
	p.x=x
	p.y=y
	p.dx=dx
	p.dy=dy
	if(dx == 0)p.dx=rnd(2)-1
	if(dy == 0)p.dy=rnd(2)-1
	p.rad=rad
	p.col=col
	add(particles,p)
end

function update_particle(p)
	p.dx*=0.9
	p.dy*=0.9
 	p.x+=p.dx
 	p.y+=p.dy
	p.rad-=0.1
	if p.rad <=0 then
		del(particles,p)
	end
end

function draw_particle(p)
	circfill(p.x,p.y,p.rad,p.col)
end

function small_expl(cx,cy,ccol,nr)
	for i=0, nr do
		init_particle(cx+rnd(4)-rnd(4),cy-rnd(4)+rnd(4),1+rnd(3),ccol,0,0)
	end
end

-->8
-- menu

menu_item = 0

m_def_size = 8
m_max_size = 16

m_adv_size = m_def_size
m_rand_size = m_def_size
m_opt_size = m_def_size
p_size = 0
pulse_timer = 0
next_screen = -1

cur_menu_string = ""
cur_menu_color = 0
cur_b_size = 0
current_x = 0
current_y = 0

has_loaded_map = false

function load_config()
	cartdata("elastiskalinjen_bulletjumper")
	ow_curr_level = dget(0)
	if ow_curr_level == 0 then
		ow_curr_level = 1
	end
	ow_beaten_levels = dget(1)

	cur_diff = dget(2)
	fp_menu_vert = cur_diff

	record_easy = dget(3)
	record_medium = dget(4)
	record_hard = dget(5)
end

function is_main_menu_active()
	return (m_adv_size <= 157 and m_opt_size <= 157 and m_rand_size <= 157) or next_screen == -1
end

function back_menu()
	if btnp(5) and next_screen >= 0 then
		if next_screen == 0 then
			has_loaded_map = false
			clear_overworld_map()
		end
		sfx(39)
		next_screen = -1
		time_f = 0
	end
end

function update_whole_menu()
	control_menu()
	m_adv_size = resize(m_adv_size,0)
	m_rand_size = resize(m_rand_size,1)
	m_opt_size = resize(m_opt_size,2)

	if next_screen == -1 then
		cur_b_size = lerp(cur_b_size,0,0.1)
	else
		cur_b_size = lerp(cur_b_size,-40,0.1)
	end

	update_pulse()
end

function update_pulse()
	if pulse_timer > 0 then
		pulse_timer -= 1
	else
		pulse_timer = 30
		p_size = 2
		sfx(34+rnd(3))
	end
	p_size = lerp(p_size, 0, 0.1)
end

function control_menu()
	if next_screen == -1 then
		if btnp(1) then
			if menu_item < 2 then
				menu_item+=1
			else
				menu_item=0
			end
			set_menu_data()
			sfx(31+menu_item)
		end
		if btnp(0) then
			if menu_item > 0 then
				menu_item-=1
			else
				menu_item=2
			end
			set_menu_data()
			sfx(31+menu_item)
		end
		if btnp(4) then
			next_screen = menu_item
			sfx(38)
		end
		if btnp(5) then
			p_size=2
			sfx(37)
		end
	end
end

function set_menu_data()
	if menu_item == 0 then
		cur_menu_string = "adventure"
		cur_menu_color = 13
		current_x = 24
		current_y = 24
	elseif menu_item == 1 then
		cur_menu_string = "remix"
		cur_menu_color = 14
		current_x = 64
		current_y = 64
	else
		cur_menu_string = "about"
		cur_menu_color = 2
		current_x = 104
		current_y = 104
	end
	cur_b_size = 8
end

function resize(menu_item_size,menu_option)
	if menu_item == menu_option then
		if menu_item == next_screen then
			menu_item_size = lerp(menu_item_size,160,0.1)
		else
			menu_item_size = lerp(menu_item_size,m_max_size,0.1)
			menu_item_size += p_size
		end
	else
		if next_screen == -1 then
			menu_item_size = lerp(menu_item_size,m_def_size,0.2)
		else
			menu_item_size = lerp(menu_item_size,0,0.3)
		end
	end
	return menu_item_size
end

function draw_whole_menu()
	cls(0)
	camera()
	draw_menu_background()
	if next_screen == -1 then
		draw_menu_lines()
	end
	draw_current_item()
	spr(1,86,11+p_size*2,1,1,true)
	print("LEGEND\n  OF\n   HIPPO",86,20+p_size*2,cur_menu_color)
	print("@elastiskalinjen",62,113+m_opt_size,12)

	draw_menu_item(24, 24, 13, m_adv_size, 0)
	draw_menu_item(64, 64, 14, m_rand_size, 1)
	draw_menu_item(104, 104, 2, m_opt_size, 2)
end

function draw_menu_item(x,y,color,size,item)
	if size > 2 then
		circfill(x, y, size, color)
		circ(x, y, size, 7)
	end
	if size < 150 and size >= 5 then
		if size > m_def_size + 4 then
				zspr(61+item,1,1,x-8,y-8-p_size*3,2)
		else
				spr(61+item,x-4,y-4)
		end
	end
end

function draw_menu_background()
	for x=0, 16 do
		for y = 0, 16 do
			local sprite = 29
			if x % 2 == 0 or y % 2 == 0 then
				sprite = sprite + menu_item
			else
				if menu_item ~= 2 then
					sprite = sprite + menu_item + 1
				else
					sprite = 29
				end
			end
			spr(sprite, x*8, y*8)
		end
	end
end

function draw_menu_lines()
	fillp(0b10010111001101001.1)
	line(24,24, 104,104, 7)
	fillp()
	line((40+cur_b_size) / 2, 122-cur_b_size, current_x,current_y, cur_menu_color)
end

function draw_current_item()
	circfill(12, 124-cur_b_size, 28+cur_b_size+p_size*2, cur_menu_color)
	circ(12, 124-cur_b_size, 28+cur_b_size+p_size*2, 7)
	print(cur_menu_string, 2, 121-cur_b_size, 7)
end

function zspr(n,w,h,dx,dy,dz)
	sx = shl(band(n,0x0f),3)
	sy = shr(band(n,0xf0),1)
	sw = shl(w,3)
	sh = shl(h,3)
	dw = sw*dz
	dh = sh*dz
	sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

function lerp(var,target,pow)
	return var+pow*(target-var)
end

ow_p1x = -20
ow_p1y = -20
ow_p1_sprite = 1
ow_curr_level = 1
ow_beaten_levels = 3
ow_p1_flip=false
ow_draw_number=false
ow_main_clr = 1

ow_points={}
function init_ow_point(x,y)
	local p={}
	p.x=x
	p.y=y
	add(ow_points, p)
end

ow_foliages={}
function init_ow_foliage(x,y,spr)
	local f={}
	f.x=x
	f.y=y
	f.spr=spr
	add(ow_foliages, f)
end

function draw_sprite(s)
	spr(s.spr, s.x, s.y)
end

function load_map_from_str(map_string)
	if sub(map_string,1,1) == "{" then
		local x = ""
		local y = ""
		local spr = ""
		local parameters_done = 0
		local types_done = 0

		for i=1, #map_string do
			local current_char = sub(map_string,i,i)
			if current_char == "{" then
				parameters_done = 0
			elseif current_char == "}" then
				if types_done == 0 then
					init_ow_point(tonum(x), tonum(y))
						if #ow_points == ow_curr_level then
							ow_p1x = ow_points[ow_curr_level].x-4
							ow_p1y = ow_points[ow_curr_level].y-4
							ow_camera_x = ow_p1x-64
							ow_camera_y = ow_p1y-64
						end
				else
					-- 73=offset
					init_ow_foliage(tonum(x), tonum(y), tonum(spr) + 73)
				end
				x = ""
				y = ""
				spr = ""
			elseif current_char == "|" then
				types_done += 1
			elseif current_char == "," then
				parameters_done += 1
			elseif parameters_done == 0 then
				x = x .. current_char
			elseif parameters_done == 1 then
				y = y .. current_char
			else
				spr = spr .. current_char
			end
		end
	end
end

function clear_overworld_map()
	for k,v in pairs(ow_points) do ow_points[k]=nil end
	for k,v in pairs(ow_foliages) do ow_foliages[k]=nil end
end

function draw_whole_board()
	cls(13)
	print("adventure",4,4,7)
	camera(ow_camera_x, ow_camera_y)
	print("home",4,4,7)
	print("lair",528,582,7)
	draw_ow_board()
	draw_ow_points()
	draw_ow_player()
	foreach(ow_foliages,draw_sprite)
end

function draw_ow_player()
	spr(ow_p1_sprite,ow_p1x,ow_p1y+sin(time()),1,1,ow_p1_flip)
	if ow_draw_number then
		print(ow_curr_level, ow_p1x+1, ow_p1y + 12, 7)
	end
end

c_p=0b1001011001101001.1
function draw_ow_board()
	fillp(c_p)
	for h=0, 10 do
		line(0,h*127,635,h*127,ow_main_clr)
		line(h*127,0,h*127,635,ow_main_clr)
	end
	fillp()
end

function draw_ow_points()
	if #ow_points > 0 then
		for p=1, #ow_points do
			if p > 1 then
				local point = ow_points[p]
				local lastpoint = ow_points[p-1]
				line(point.x,point.y,lastpoint.x,lastpoint.y,ow_main_clr)
			end
		end

		for p=1, #ow_points do
			local point = ow_points[p]
				local coldp = ow_main_clr
				if p == ow_beaten_levels then
					coldp = 12
				elseif p > ow_beaten_levels then
					coldp = 8
				end
				circfill(point.x,point.y, 5, coldp)
				if p == ow_curr_level then
					circ(point.x,point.y, 5, 7)
				else
					circ(point.x,point.y, 5, 2)
				end
		end
	end
end

function update_overworldplayer()
	if ow_curr_level <= #ow_points then
		local point = ow_points[ow_curr_level]
		ow_p1x = lerp(ow_p1x, point.x-4, 0.2)
		ow_p1y = lerp(ow_p1y, point.y-4, 0.2)
		local distance = sqrt(((point.x-ow_p1x)/10)^2+((point.y-ow_p1y)/10)^2)*10
		if (distance < 8) then ow_draw_number = true else ow_draw_number = false end
	end

	if btnp(1) and ow_curr_level < ow_beaten_levels and (ow_curr_level+1) <= #ow_points then
		ow_curr_level+=1
		ow_p1_flip = true
		dset(0,ow_curr_level)
		sfx(28)
	end

	if btnp(0) and (ow_curr_level-1) >= 1 then
		ow_curr_level-=1
		ow_p1_flip = false
		dset(0,ow_curr_level)
		sfx(29)
	end

	if btnp(4) and game_mode == 0 then
		start_play(ow_curr_level,false)
	end
end

function start_play(level_start,is_remix)
	reload(0x1000,0x1000,0x1000)
	reload(0x2000,0x2000,0x1000)
	if is_remix then
		level = scrambled_levels[level_start]
		game_mode = 2
		if cur_diff > 0 then
			game_timer = f_level_timer[level]
		else
			game_timer = level_timer[level]
		end
		if cur_diff == 2 then
			p1lives = 1
		end
	else
		level = level_start
		game_mode = 1
		game_timer = level_timer[level]
	end
	sfx(41)
	sfx(16)
	start_door_shut(12+game_mode)
	camx, camy = get_camera_pos(level)
	spawn_entity()
end

function start_door_shut(dcolor)
	doorlx=63
	doorrx=63
	doorstate=1
	doorcolor=dcolor
end

ow_camera_x=0
ow_camera_y=0
function move_ow_camera()
	ow_camera_x=lerp(ow_camera_x,ow_p1x-64,0.1)
	ow_camera_y=lerp(ow_camera_y,ow_p1y-64,0.1)
end

cur_ow_str="{30,40}{54,65}{38,104}{99,156}{113,222}{150,144}{203,217}{241,180}{268,235}{301,287}{250,327}{274,380}{233,427}{173,429}{115,453}{69,503}{69,558}{111,612}{156,575}{153,526}{185,488}{228,532}{298,579}{351,532}{390,479}{435,429}{475,372}{511,318}{561,292}{611,319}{556,364}{518,597}|{6,37,32}{26,14,32}{50,12,34}{15,53,34}{5,12,34}{26,88,33}{106,143,33}{152,413,35}{187,392,35}{167,402,35}{149,395,35}{187,454,35}{206,442,35}{239,353,32}{255,296,32}{304,251,32}{269,261,32}{267,195,32}{237,212,32}{131,428,33}{116,432,33}{246,390,33}{265,401,33}{148,450,33}{131,459,33}{110,236,33}{95,228,33}{148,127,34}{168,143,34}{130,144,34}{200,232,36}{184,223,36}{181,206,37}{83,461,37}{114,491,37}{71,569,34}{98,615,34}{120,611,34}{96,603,34}{84,563,34}{315,522,36}{364,553,36}{422,469,34}{389,448,34}{411,410,34}{456,443,34}{446,359,34}{497,390,34}{489,296,34}{531,338,34}{398,507,36}{480,417,36}{13,25,36}{573,396,37}{533,382,37}{109,620,34}{185,495,34}{548,584,36}{474,610,36}{496,564,36}{72,12,32}{14,69,32}{560,316,36}{497,307,32}{520,329,32}{543,351,32}{570,375,32}{108,597,34}{174,565,34}{222,559,34}{183,526,34}{279,508,37}{297,525,37}{314,543,37}{335,563,37}{350,577,37}{366,588,37}{575,284,35}{607,332,35}{102,61,32}{92,89,32}{110,85,32}{524,633,37}{319,303,32}{85,514,32}{54,514,32}{363,465,36}{428,386,36}{562,573,32}{537,646,32}{555,615,32}{498,639,32}{461,618,32}{475,582,32}{491,553,32}{495,591,34}{531,603,34}{510,611,34}{558,268,35}"

fp_menu_vert = 0
fp_menu_hor = 0
record_easy = 3
record_medium = 1
record_hard = 5

cur_diff = 0
current_level_won = 0
function update_remix()
	fp_menu_vert = move_menu(fp_menu_vert,false,3)
	fp_menu_hor = move_menu(fp_menu_hor,true,2)
	time_f+=(cur_diff+2)*3
	if fp_menu_hor == 0 then
		cur_diff = fp_menu_vert
		dset(2,cur_diff)
	end

	if btnp(4) then
		start_remix()
	end
end

cur_f_p_level = 0
function start_remix()
	time_f=0
	scrambled_levels={}
	cur_f_p_level = 1
	for i=1,32 do
		scrambled_levels[i]=i
	end
	scrambled_levels = shuffle(scrambled_levels)
	start_play(cur_f_p_level,true)
end

function shuffle(tbl)
	for i=#tbl,2, -1 do
		local j = 1+flr(rnd(i))
		tbl[i],tbl[j] = tbl[j],tbl[i]
	end
	return tbl
end

time_f=0
function draw_remix()
	print("remix",4,4,7)
	local record = 0
	if cur_diff == 0 then
		record = record_easy
	elseif cur_diff == 1 then
		record = record_medium
	else
		record = record_hard
	end

	print("record: ".. record, 8,16,7)
	rect(8,24,120,78,7)
	hi_cur_diff(0)
	rect(14,82,46,100,7)
	print("easy",23,88,7)
	fillp()

	hi_cur_diff(1)
	rect(48,82,80,100,7)
	print("medium",53,88,7)
	fillp()

	hi_cur_diff(2)
	rect(82,82,114,100,7)
	print("hard",91,88,7)
	fillp()

	for x=9,119 do
		rectfill(x,77,x,50+((cur_diff+1)*7)*-sin((x+time_f)/1080),2)
	end
	make_pattern_hor(1)
	rect(8,104,120,122,7)
	local b_t="start?"
	if fp_menu_hor == 1 then
		b_t="staart!"
	end
	print(b_t,53,110,7)
	fillp()
end

function make_pattern_hor(t_hor)
	if fp_menu_hor == t_hor then
		fillp(c_p)
	else
		fillp()
	end
end

function hi_cur_diff(t_ver)
	if cur_diff == t_ver then
		if fp_menu_hor == 0 then
			fillp(c_p)
		else
			fillp(0b1111111111111111.1)
		end
	else
		fillp()
	end
end

function move_menu(menu_opt,is_horizontal,num_of_menu)
	local add = false
	if is_horizontal then add = btnp(3) else add = btnp(1) end
	if add then
		if menu_opt < num_of_menu-1 then menu_opt+= 1 else menu_opt = 0 end
		sfx(34+menu_opt)
	end
	local subt = false
	if is_horizontal then subt = btnp(2) else subt = btnp(0) end
	if subt then
		if menu_opt > 0 then menu_opt -= 1 else menu_opt = num_of_menu-1 end
		sfx(34+menu_opt)
	end
	
	return menu_opt
end

function draw_option()
	print("about",4,4,7)
	local wave = sin(time())
	circfill(110,20,33+wave*3,1)
	circ(110,20,33+wave*3,7)
	zspr(125,1,1,87,4+wave,5)
	print("controls",6,42+wave*1.5,7)
	print("* move: ‹”‘ƒ",8+wave*2,52,14)
	print("* charge dash: Ž/z",8+wave*2,60,14)
	print("* switch ability: —/x",8+wave*2,68,14)
	print("this game was made by:\nsebastian lind @elastiskalinjen",2,114-wave,1)
end

menuitem(1,"go to menu", function() reset_to_menu() sfx(1) end)
__gfx__
00000000002222000000000000222200027777200022220000222200002222006777777600888800700000770000000007666770000000000766677007666770
0000000022711722002222000271172007177170027777200222222002777720fd666667087aa980000709070000800077767777076667707007600777767777
0070070002222220027117201022220121177112271771722277772227177172dfddfdf78a98989808a000900000009071176117777677777227622771176117
000770002e2e2220002222000332e2e327777772211771122717717221177112dfff6df7878988980098000800a8000072276226711761177777777772276227
00077000222222000b32e2e00033222022677622277777722117711227777772f666dff789989898087008000000807067767766722762260776776077767767
0070070003333b00033322200033330022266222226776222777777222677622f6f6ffff898888980008009000890000d667667d677677660667667076676677
00000000033333b0013333100023320002222220022662200267762002266220f6ffffff089999800890708000070000dd6766ddd667667d0d6766d00d6766d0
0000000003333330000002000020000000222200002222000026620000222200fffffff60088880000008007000000000dddddd0dddddddd0dddddd00dddddd0
666ff666ffffffffdddddddd00000000071771700bbbbbb0000000000bbbbbb01111111100000000000000000000000000000000010110100000000010011001
6ff66ff6ffffffff7666666d08888800b1177113b71771730bbbbbb0b717717301010101000000000099990000dccd0000844800110000110110011001000010
6ffffff6ffffffff7666666d088888000378873001177110b7177173011771100000000000000000090000900d0000d008000080001001000010010000111100
f6ffff6fffffffff7666666d00888000003663000378873001177110037887300000000000000000090070900c0c70c00808a080100110010001100010100101
f6ffff6fffffffff7666666d00888000000330000036630003788730003663000000000000000000090a00900c0cc0c008022080100110010001100010100101
6ffffff6ffffffff7666666d00080000000bb0000003300000366300000330000000000000000000090000900d0000d008000080001001000010010000111100
6ff66ff6ffffffff7666666d0000000003bbbb3003bbbb3003b33b3003bbbb3060000006000000000099990000dccd0000222200110000110110011001000010
666ff666ffffffff6dddddd60008000000300300000003000030000000300300d666666d00000000000000000000000000000000010110100000000010011001
000000000000000000004400000a0a00000777000000000000077700000000002122222222212222000044490000440a0000400000004400ffffffffffffffff
09aaaa9001c77c100004200000aa8a0000777770000777000077777000077700d1ddddddddd1dddd000420a0000420a000040400000429a07df666fff6f66666
0aa77aa00c7717c008f8888000222200001777100077777000177710007777701111111111111111087888800088800a0008809000788000ff66ffdff6f6f6ff
0a7717a00c7117c00f8778802271172200777770001777100077777000177710222222122222212287877888087888800078890008888880f6fff6fffff66fff
0a7117a00cc77cc0087717800222222008877780007777700887778000777770dddddd1dddddd1dd287117822781788208888880287117827f6666ffff66666f
09a77a900cccccc0027117200222e2e2808888080887778008888880088777801111111111111111228778220288882000288200028778207666f6ffffff66ff
099aa9900dccccd0028778200022222210288201018888101028820101888810222122222212222202288220002882000002200000288200fff6dd6fffffff6f
0000000000000000000000000000000000200000002002000000020000200200ddd1dddddd1ddddd00222200000220000000000000022000ffffffffffffffff
009009009009900900711100000dd0000000444000004400d111111d002222000000000000022220000000000000044400004444000000770000000000000000
09aaaa9009aaaa9001cccc1000dccd00000420000004204014499441027117200022220000271172002222000004400000141100000007700077770000777700
9aa77aa90aaaaaa07cc77ccd0dccccd008f888800088800040000004002222000271172000022220027117200014110006111110000077000777777007700770
0a7717a0aaaaaaaadc7717cd1cccccc18f87788808f88880400000040b32e2e00022220000b32e2e0022220001611110d11d7111000770000077770007000770
0a7117a09a7117a9dc7117cd1c7117c1287717822f88888240000004b33322200b32e2e0033332220b32e2e00d1d711011777711707700000077770000007700
99a77a9909aaaa90dcc77ccd0dccccd0227117220271172040000004303333030333222003333330033322200117711011111111077000000007700000077000
099aa990099aa9900dccccd000dccd00028778200028820040000004102332010133331010233201013333100111111001111110077000000000000000000000
009009009009900900111100000dd000002222000002200040000004002000000020020000000200002002000011110000011000700700000007700000077000
662666666111111111111111dddd8ddd11111116dd16dddddddd61dd7666666d4f4444f2000330000003300000000000000000000000000000000000d111111d
dd2ddddd1166666666666666ddd99ddd66666611dd16dddddddd61dd676666d144ffff2200377300003b73000022222000222200002222000222220014499441
22222222161ddddddddddddd11142111ddddd161dd16dddddddd61dd66dddd1144f11f2203733b300037b3000288888202888820028888202888882044900944
6266666616d1dddddddddddd66655166dddd1d61dd16dddddddd61dd66d11d1144f15f22373bb3b3003bb30028eee8822888888228888200288eee8249000094
d2dddddd16dd1dddddddddddddd421ddddd1dd61dd16dddddddd61dd66d15d1144ffff22373bb3b3003bb30028ee888828888882288882022888ee8249000094
2222222216ddd1ddddddddddddd421dddd1ddd61dd16dddddddd61dd66dddd114d2222d203733b30003bb30028e88888888888822888820022888e8244900944
6662666616dddd1dddddddddddd421ddd1dddd61dd16dddddddd61dd6d5555d1d222222d003bb300003bb3002888888888888882288888200028888244900944
ddd2dddd16ddddd1dddddddddddd1ddd1ddddd61dd16dddddddd61ddd555555d2222222200033000000330002888888888888882288882000288888244444444
6666626616dddddd1dddddddddddddd1dddddd61dddddddddddddddddddddddd6771117667999976ffffffff28888888888888822882000228888882fdfddffd
ddddd2dd16ddddddd1dddddddddddd1ddddddd61dddddddd44444446d1d1d11d7616661d7911119dffffffff02888888888888200288220002888820ffffffff
2222222216dddddddd111111111111dddddddd611111111144444656011011017661116d7299992dffffffff02888888888888200288882200288820ffffffff
6626666616dddddddd116666666611dddddddd616666666644465656000000007666166d44242222ffffffff00288888888882000028820002888200ffffffff
dd2ddddd16dddddddd161dddddd161dddddddd61dddddddd46565656000000007669166d44444422ffffffff00028888888820000002880002882000ffffffff
2222222216dddddddd16d1dddd1d61dddddddd61dddddddd56565656000000007666166d44444222ffffffff00002888888200000000282002820000ffffffff
6666266616dddddddd16dd1dd1dd61dddddddd61dddddddd56565656000000007699966d7442222dffffffff00000288882000000000028202200000ffffffff
dddd2ddd16dddddddd16ddd11ddd61dddddddd61dddddddd56565656000000006dddddd66dddddd6ffffffff00000022220000000000002000000000ffffffff
6666626616dddddddd16ddd11ddd61dddddddd61ddddddddddd8dddddddd1ddd2222221d00011000000000000001100000111100001011000001100011111111
ddddd2dd16dddddddd16dd1dd1dd61dddddddd61ddddddddddd98dddddd421dd22222221001bb100001111000013310001778810001151000015510061111166
2222222216dddd11dd16d1dddd1d61dd11dddd61dddddddd11142111ddd421dd2222222101bbbb10013333100133331001778810001551000156651022111222
6666662616ddd11ddd161dddddd161ddd11ddd61dddddddd66655166ddd421dd2222222101bbbb1013333331013333101878887101511510156dd651dd222ddd
dddddd2d16ddd1dddd116666666611dddd1ddd6166666666ddd421dd66655166222222211bbbbbb113333331013333101888888115155151156dd651dddddddd
2222222216dd1ddddd111111111111ddddd1dd6111111111ddd421dd11142111222222211bbbbbb1133333310133311018e22e811556655115555551dddddddd
6666266616ddddddd1dddddddddddd1ddddddd61ddddddddddd421ddddd99ddd222222211112211101332310013313310187781015611651165115d1dddddddd
dddd2ddd16dddddd1dddddddddddddd1dddddd61dddddddddddd1ddddddd8dddddd1dddd001441000014410001331331001661001561165111111111dddddddd
6777777616ddddd1dddddddddddd1ddd1ddddd61ffffffff1ff1fff13b3b3b3b3b3b3b3bb77777777777777bb3b3b3b300000000000000006fffffff00000000
7666666d16dddd1dddddddddddd421ddd1dddd61ffddddfff1f55f1fbbbbbbb3bbbbbbb37bbbbbbbbbbbbbb73b3b3b3b0222220000777700ffffff6f00000000
7666666d16ddd1ddddddddddddd421dddd1ddd61fd6666dfff5dd5ff3bbbbbbb3bbbbbbb7bbbbbbbbbbbbbb7b3b3b3b32271172277066077ffff6f6f00000000
7666666d16dd1dddddddddddddd421ddddd1dd61fd6ff6dff5d11d51bbbbbbb3777777777bbbbbbbbbbbbbb73b3b3b3b02c22c20077777707fdd666f00000000
7666666d16d1dddddddddddd66655166dddd1d61fd6ff6df15d15d5f3bbbbbbb3bbbbbbb7bbbbbbbbbbbbbb7b3b3b3b302d22d20707077707fd6fffd00000000
7666666d161ddddddddddddd11142111ddddd161fd6666dfff5dd5ffbbbbbbb3bbbbbbb37bbbbbbbbbbbbbb73b3b3b3b02d2e2ed777777007ddfddfd00000000
7666666d1166666666666666ddd99ddd66666611ffddddfff1f55f1f3bbbbbbb3bbbbbbb7bbbbbbbbbbbbbb7b3b3b3b300d2222200000000766666dd01010101
6dddddd66111111111111111ddd8dddd11111116ffffffff1fff1ff1b3b3b3b3b3b3b3b3b77777777777777b3b3b3b3b00000000000000006dddddd611111111
92929292929292929292929292929282929292929292929292929292929292828282828282828282828282828292929292929292929292929292929292929292
92929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292
821424242424f62424f6242424244482821424242424242424242424242444828214242424242424242424242424448282142424f624242424242424f6244482
821424242424242424242424242444828214f624242424242424242424f644828214242424242424242424242424448282142424242424242424242424244482
821525345555f7f7f7f7555534354582821525343455555555555555553545828215255555555555555555555535458282152555555555555555555555354582
8215255534555555555555345535458282152555553455555555345555354582821525345555345555555555553545828215255555553455f455345555354582
821554848484f5f5f5f58484846445828215540707f5f5f5f5f5f5f5f5644582821554f5f5f5f5f5f5f5f5f5f564458282165407070707079107070707644582
82155407070707070707070707644582821554747407959595950774746445828215549421219475757575757564458282155442070707420707074207644582
82155457578474747474845757644582821554071075757575757575756445828215541194411111111141941164458282155407940707079107079507644582
821554074007070707070740076446828215547441070707070707c0746445828215540707420791919191919164458282155407070707070707070707644582
82155457070707070707070757644582821554070791910101010195916445828215541141111111111111411164458282155407070740079194070707644582
82155475757575757575757575644582821554070707070707070707076445828215547575757591919191919164458282155475757575757575757575644582
82155457070707070707070757644582821554808091910101010101916445828215541111111111111111011164458282155475757575759175757575644582
82155407919191919191919107644582821554070707070707070707076445828215549191919191848484848464458282155491919191919191919191644582
82155484848484848484848484644582821554a5a591910101757501916445828215541111011111111101670164458282155407070791910707070707644682
821554747474740707747474746445828215548787878797a7878774876445828215549191919191849595212164458282155491919191919191919191644582
82155474747441575741747474644582821554575791910101919101916445828215541101670111111111011164458282155407079491910707079407644582
821554747474740707747474746445828215547777777777777777b7746445828215549191919191849507070764458282155491919191919191919191644582
821554f5f5f507070707f5f5f5644582821554a5a591910101919101916445828215541111011111111111111164458282155407077591917575757575644582
821554212141410707414121216445828215547777777777777777b7746445828215549191919191840707070764458282155407070707849191919191644582
8215545707070707070707075764458282155457579191e795919101916445828215541141111101010111411164458282155407959191940707070707644582
821554070707070707070707076445828215547710777777777777b7746445828215549191919191757507070764458282155407850707849191070707644582
82155457070707071007070757644582821554a5a59191757591910191644582821554e79441e7e710e74194e764458282155407079191070710070707644582
821554070707070707070707076445828215547777777777777777b7746445828215549191919191919110070764458282155407070707849191071007644582
82155457575757575757575757644582821554575701010101010101916445828215540707070707070707070764458282155407070791070707070707644582
82155407070707071007070707644582821554777777777777777774776445828215549191919191919107070764458282155475757575759191070707644682
82152656565637565637565656364582821526565656565656565656563645828215265656565637813756565636458282152656565656563781375656364582
82152656565656565656565656364582821526565656565656565656563645828215265656565656565656815636458282152656565656565656568156364582
82172727272727272727272727274782821727272727272727272727272747828217272727272727272727272727478282172727272727272727272727274782
82172727272727272727272727274782821727272727272727272727272747828217272727272727272727272727478282172727272727272727272727274782
82929292929292929292929292929292829292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929282
92929292929292929292929292929282929292929292929292929292929292829292929292929292929292929292928292929292929292929292929292929282
92929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292
92929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292
821424242424f624f6242424242444828214f6242424242424242424f62444828214242424242424242424242424448282142424242424242424242424244482
821424242424242424242424242444828214242424242424242424242424448282142424242424242424242424244482821424f62424242424242424f6244482
82152534555555f45555555555354582821525555555555555345534553545828215255555555534553455345535458282152555555555555555553434354582
82152555555555555534343455354582821525555555555555555555553545828215255555555555553455345535458282152555555555555555555555354582
82155442749507070707070707644582821554757575757575757575756445828215545774070775757575575764458282155475757575757575750707644582
82155475757575757577777775644682821554070707670710076707076445828215544007070707757407070764458282155495950707070784f5f541644582
82155475749507070707070707644582821554919191919191079407916445828215540774074040409140404064458282155491919191959595919407644582
82155491919191918797a7879164458282155480808067808080678080644582821554079407070791070710076445828215549507070707078401a5a5644582
82155491740707410784070707644582821554919191919191070707916445828215548484757575759175404064458282155491950707070795917575644682
8215549174919177c077777791644582821554010101670101016701016445828215547575757507918407070764458282155407400707747474845757644582
82155491740707070784757575644582821554919191919191757542916445828215540707070707919191750764458282155491950707070795919191644582
82155474b79177777777777791644582821554676767676767676767676445828215549191919107917575757564458282155407070707744221848484644582
82155491748484848484919191644582821554919191919191919191916445828215540775757575919191910764458282155491757575070775919191644582
82155474b77777777777777791644582821554070707070707671157956445828215540707079107070707070764458282155407070707747575212121644682
82155491742121212121919191644582821554747474919191919191916445828215540707919191919191917564458282155491919191750707919191644582
82155474b77777777777777791644582821554074007074107671157956445828215540707079107070707940764458282155407070707740707070707644582
82155491740707070707070707644582821554212121919191919191916445828215547575919191919191919164458282155491950707070707079591644582
82155474b77577777777777791644582821554676767676767671157956445828215547575759107070707070764458282155407070707740707070707644582
82155491740707070707070707644582821554808080919191919191916445828215540707079191919191070764458282155491950707070707079591644582
82155475749175778797a78791644582821554111167111111676767676445828215540707070707757575757564458282155474747474740707070707644582
82155407850707070707575757644582821554111101919191919191916445828215540707109191919191070764458282165491747474071007747491644582
821554917591917577771077916445828215541111671142116711575764468282155407940707079184070707644582821554c0777777770707070707644582
82155407070707070707571057644582821554100101919191919191916445828215547575759191079191757564458282155491757575070707757591644582
82165491919191917577777791644582821554111167111111671157576445828215547507757575918494400764458282155477777777771007070707644582
82152656375656565656568156364582821526375637565656565656563645828215265656565656565656565636458282152656565656378137565656364582
82152656565656565656815656364582821526565656565656565656563645828215265656565656565656375636458282152656565637568156375656364582
82172727272727272727272727274782821727272727272727272727272747828217272727272727272727272727478282172727272727272727272727274782
82172727272727272727272727274782821727272727272727272727272747828217272727272727272727272727478282172727272727272727272727274782
92929292929292929292929292929282929292929292929292929292929292829292929292929292929292929292928292929292929292929292929292929282
92929292929292929292929292929282929292929292929292929292929292829292929292929292929292929292928292929292929292929292929292929282
__gff__
00000000000000000000000000000000000000000000000008200000000000000000000000000000030300000000000000000000000000000000000000000000030303080308080105000000000000c4030308080308102040810000000000000303080803080808030000000000000800030308030020000000000000000010
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050
404142424242424242424242424244606041424242424242424242424242446060414242424242424242424242424460604142426f4242424242426f424244606041424242424242424242424242446060414242426f42424242426f424244606041424242424242424242424242446060414242424242424242424242424460
4051524355555555555555554353546060515255555555555555555555535460605152555555555555555555555354606051525555555555555555555553546060515255555555555555555555535460605152555555555555555555555354606051525555555543435555555553546060515255435555555555554355535460
4051457070707070707070707046546060514575757575757575757575465460605145477070707070707070474654606051457070707070707070707046546060514547475f5f5f5f5f5f4747465460605145474749494747494947474654606051454747475f70705f47474746546060514577774747474747477777465460
405145707070757575757556704654606051455a045a5a5a5a5a5a5a5a466460605145477070707049707070474654606061457047477070707047477046546060514547101010101010101047465460605145471270701212707012474654606051454748475a70595a47484746546060514577477b7b7b7b7b7b4777465460
405145707070757047474747474654606051457e7e7e7e7e7e7e7e7e7e46546060514512705f5f5f5f5f5f5f70465460605145704704707070700447704654606051457e7e7e7e7e7e7e7e7e7e465460605145497070700470707070494654606051454747475a70705a47474746546060514577477b7b7b7b7b7b4777465460
405145707070757047474848474654606051454848487070707048484846546060514570705a48484848485a704654606051457012101010101010127046546060514570047070047070700470465460605145497070477070477070494654606051455f5f5f5a70705a5f5f5f46546060514577777777777777777777465460
405145707070757012121212474654606051454747477070707047474746546060514570705a5f5f485f5f5a704654606051457070104875754810707046546060514570707070707070707070465460605145497070497070497070494654606051457070597070707070707046546060514577777777770c77777777465460
405145707070757070707070474654606051454747477070707047474746546060514570705a495a485a495a704654606051457070104875754810707046546060514570707070707070707070465460605145497070497070497070494654606051457070707070707070597046546060514577777777777777777777465460
405145707070757070704747474654606051454747477070707047474746546060514570705a5a4848485a5a704654606051457070101010101010707046546060514570707070707070707070465460605145497070477070477070494654606051455f5f5f5f70705f5f5f5f46546060514578787878797a78787878465460
405145707070757575757559474654606051451259127070707012591246546060514570705a5a5f5f5f5a5a704654606051457047707070707070477046546060514570757070707070707570465460605145497070477070477070494654606051454747475a70705a47474746546060514577777777777777777777465460
4051455970707070707501754746546060614570707070700170707070465460605145597070707001707070594654606051457047477070017047477046646060514547707070700170707047465460605145477070127070127070474654606051454748475a70015a47484746546060514577777777770177777777465460
4051455959707070707575754746546060514570707070707070707070465460605145595970707070707059594654606051457012127070707012127046546060514547477070707070704747465460605145477070707001707070474654606051454747475a70705a47474746546060514577777777777777777777465460
4051627365656565656565657363546060516265656573656573656565635460605162656565656565656565656354606051626565656573187365656563546060516265656565656565656565635460605162656565656565656565656354606051626565656573736565656563546060516265736565656565657365635460
4071727272727272727272727272746060717272727272727272727272727460607172727272727272727272727274606071727272727272727272727272746060717272727272727272727272727460607172727272727272727272727274606071727272727272727272727272746060717272727272727272727272727460
5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050
5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050
6041424242424242424242424242446060414242424242424242424242424460604142424242424242424242424244606041424242424242424242424242446060414242424242424242424242424460604142426f4242424242426f424244606041424242424242424242424242446060414242424242424242424242424460
6051524355557f7f7f7f55554353546060515255555555555555554355535460605152554355555555555543555354606051525555555555555555555553546060515255435555555555554355535460605152555555555555555555555354606051525555555555555555555553546060515255555543555543555555535460
605145707048707070704870704654606051454849707057575770707046546060514570047070707070700470465460605145575757575757575757574654606051455f5f5f5f5f5f5f5f5f5f4654606051455f5f5f757575755f5f5f4654606051457777777777777777777746546060514557575770707070575757465460
605145047048474747474870044654606051454870705719191970704946546060514570707070757570707070465460605145707070597070707070704654606051455a5a5a5a5a5a5a5a5a5a4654606051451170707070707070041146546060514577047777777777770c7746546060514519190404040404041919465460
605145707012121212121270704654606051455757571919191970704846546060514570705770757570577070465460605145707070707057575757574654606061457e7e7e7e7e7e7e7e7e7e465460605145117057575757575770114654606051457777777777777777777746546060514519195757575757571919465460
6051457070707070707070707046546060514519194848481919707048465460605145575719707070701957574654606051457070707070191970707046546060514570017070707070700470466460605145757019707070701970754654606051457777777777777777777746546060514519191919191919191919465460
60514548484848474748484848465460605145191970497019197070484654606051451919195757575719191946546060514570707070571919705970465460605145474770707070707047474654606051457570197070017019707546546060514578787878797a7878787846546060514519191919191919191919465460
6051454848484847474848484846546060514519197070701919707048465460605145107e7e7e7e7e7e7e7e104654606051457070707070191970707046546060514512127070707070701212465460605145757019707070701970754654606051457777777701777777777746546060514519191919191919191919465460
6051454848484812124848484846546060514519195757571919575757465460605145107557575757575775104654606051455757575757191957575746546060514570707048484848487070466460605145757019707070701970754654606051457777777777777777777746546060514519191919191919191919465460
60514548481212494912124848465460605145707070707070191919594654606051451075197070707019751046546060514570197070707070701970465460605145707070485f755f487070465460605145117019575757571970114654606051457777777777777777777746546060514519197070707070701919465460
6051454812707070707070124846546060514570700170707019191975465460605145107519707001701975104654606051457019707070017070197046546060614570707048755675487070465460605145117070707070707004114654606051457777477b7b7b7b47777746546060514519195770707070571919465460
60514548700170707070707048465460605145597070707070191919594654606051451075197070707019751046546060514570197070707070701970465460605145597070485a755a487059465460605145111111757575751111114654606051457777474747474747777746546060514519191970017070191919465460
6051626573186565656565736563546060516265731873656565656565635460605162657365656565656573656354606051626565656573187365656563546060516265656565656565656565635460605162656565656565656565656354606051626565656565656565656563546060516265656573656573656565635460
6071727272727272727272727272746060717272727272727272727272727460607172727272727272727272727274606071727272727272727272727272746060717272727272727272727272727460607172727272727272727272727274606071727272727272727272727272746060717272727272727272727272727460
5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050
__sfx__
00020000150100702007020090300d0500400006000070000a0000f000160001e0002400000000000000120001200012000120000200002000020000200002000020001200012000120001200012000220001200
0002000021150155301653007020020200d7001a700180001c700237001c700230001c0001d400234001d400234001d400234001d400234001d000247001d700247001d7001d700247001570024700177001d700
00010000155400b540030400105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001a1501915017050140500b010040100302000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000302003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000012010131401a1601d1501916015170131700e1600e1500b0400a050040500c0400b0400a040040300003004020010200a020076000660000600000000000000000000000000000000000000000000000
000100001b05019050030500d05009050070500505002050010500105006000030000110003100021000110003000030000110001200012000010000000020000000000200012000120000200020000400006000
0013000009120091200a1300b140101301c15012000161301a14024150201001d1701c1001b0001b00006000351001b0001c0001a000190001900000000000000000010000100000000000000100000000010000
000600000101005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000010100101003010030100401005010050000400004000050000500005000070000a0000e0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000202017120141400b1400a13008110041100215000150200001d0001a000080000c7000f7000060000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000510025203f500005001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000210501c03019030130300f0300a03006000010500a0000205007000050000505005000070500a05009000060500000005000040000405000000000000000000000000000000000000000000000000000
000300000405005050080500b0500c0501005015050190501f070260502e050350500000000000000000000000000000000000000000000000000000000016500165002650010500105000050000500300003000
00040000081200f140141601a1501f1202a04033040261002e1002e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002a1502414019140121300d130070300603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001873027040237002370021700167000d700127000f7000f7001470012700127000f7001470014700127001470012700127001470012700217001670023700147001470012600146000f7000f7000d700
000600000864009650076300061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000004010266302764018640086300e6301763017630126300963008630030300103000010007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000010140101500e1701a0701a05019010037200070000700007000070000700007003e000007000070000700007000070000700007000070000700007000070000700007000070000700007000070010700
001000002305027050130500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001c0501f0501905012050120500a0500905008050105500d5500c5500b5500a550085500755007550055500455003550015500150000500075000f5000950000500005000050000500005000050000500
0005000014050230202a0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000012020191300e7200070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100000302003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000902003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002f6502d65021650196500d6400d6400c6400a6400a6300b6300b6300b6200b6200b6200a6300a6300a630096300864008640076300563003030030300103001020010100001000000000000000000000
001200000a01010020170301a040150501405013050000501305016050190501d050210502305021050000500f05014050180501c0501e05019050180500005024050290402c0302f02035010000000000000000
000800000201005030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000403002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000004050070500d0501605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001011017100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000f13012100290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000081200d1000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000201002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000090200f530130400a00003000005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0003000003e1003e1003e1004e1004e1006e1007e2008e2009e300ae300de300ee3010e3012e3015e3018e301ee3025e302be30160000d0000b00009000070000700006000040000400002000000000001000010
0003000023e2020e201fe201ee201ce201be201ae2019e2017e2015e2013e2011e100ee100be1009e1004e1004e1002e1002e1007e0006e0005e0004e0003e0002e0002e0000e0000e0002e0002e0002e0002e00
005a0000090500a050100502005021000200001b000180000d05012000140501a0502205027050100000000000000070000705002000030500905010050150501d00003000200001b0201c000260502d03036050
000c00001d0101f010210202402026020290302d03030000170001a0001f00009000010100002001000210000b0001a0001f000250002b0002d000310002e0002800021000010001a0001e000250002600029000
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
06 01 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
