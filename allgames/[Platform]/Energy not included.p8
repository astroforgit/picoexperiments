pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--main--
c64_blink_f = 0.5
c64_blink_t = c64_blink_f

boot_time = 0
dot_cnt = 0 
dot_upd = 0

function _init()
	wait = 0
	time_delta = 0
	lasttime = time()
	utils_init()
	p_act_update = update_init
	p_act_draw =  draw_init
	sfx(8)
end

function update_init()
	if boot_time >= 10 then
		_startgame()	
	end
	boot_time += time_delta
end

function draw_init()
	if boot_time > 0.2 then
		print_text_center("saturn91.dev pico-8", 19, 11)
	end
	
	dot_upd +=1
	
	if dot_upd >= 8 then
		dot_upd 	= 0
		dot_cnt += 1
		
		if(dot_cnt > 3) then
			dot_cnt = 1
		end 
	end	
	
	local dot = ""
	
	for i=1, dot_cnt do
			dot = dot..". "
		end
	
	if boot_time > 0.4 and boot_time < 2.4 then	
		print("loading "..dot, 18, 27, 11)
	end
	
	if boot_time > 2.4 and boot_time < 4.4 then
		print("open eni.p8 "..dot, 18, 27, 11)
	end
	
	if boot_time > 4.4 then
		print("open eni.p8 ", 18, 27, 11)
	end
	
	if boot_time > 4.4 and boot_time < 6.4 then
		print("res ram "..dot, 18, 35, 11)
	end 
	
	if boot_time > 6.4 then
		print("res ram ", 18, 35, 11)
	end
	
	if boot_time > 6.4 and boot_time < 8.4 then
		print("add rnd bugs "..dot, 18, 43, 11)
	end 
	
	if boot_time > 8.4 then
		print("add rnd bugs", 18, 43, 11)
	end 
	
	if boot_time > 8.4 then
		print("start game"..dot, 18, 51, 11)
	end 
end

function _startgame()
	cartdata("eni")
	music(0)
	init_cart()
end

function init_cart()
	get_highscore()
	init_enemies()
	init_bullets()
	init_powerups()
	init_floating_texts()
	clear_map()
	init_map()	
	init_player()	
	p_act_update = update_menu
	p_act_draw =  draw_menu
end

function _update()
	if wait <= 0 then
		p_act_update()
		upgrade_shakes()	
	else
		wait -= time_delta
	end
	time_delta = time() - lasttime
	c64_blink_t -= time_delta
	if c64_blink_t <= 0 then
		if mget(18,14)==89 then
			mset(18,14,90)
		else
			mset(18,14,89)
		end
		
		c64_blink_t = c64_blink_f
	end
end

function _draw()
	pal(1, 1+128,1)
	cls(0)
	p_act_draw()
	cutscreen()
	draw_debug()	
	lasttime = time()
end

function cutscreen()
	map(4,0,0,0,16,16)
end

function draw_raw(sprite,x,y,w,h,flipx)
	if(w==nil)then
		w=1
	end
	
	if(h==nil)then
		h=1
	end
	spr(
		sprite,
		x+16+shake_off.x,
		y+16+shake_off.y+camera_yoffset,
		w,
		h,
		flipx)
end

-->8
--screen-shake--
t_shake={
	x_in={0,0,0,0,0,0,0,0},
	y_in={0,0,0,0,0,0,0,0},
	x			={0,0,0,0,0,0,0,0},
	y			={0,0,0,0,0,0,0,0},
	t			={0,0,0,0,0,0,0,0}
}
shake_index = 1

shake_off={
	x=0,
	y=0
}

shake_f = 0.05
last_shake = 0


function shake(x_in, y_in, t)
	local si = shake_index
	t_shake.x_in[si] = x_in
	t_shake.y_in[si] =y_in
	t_shake.t[si] = t
	shake_index += 1
	if(shake_index > #t_shake.t)then
		shake_index = 1
	end
end

function upgrade_shakes()
	if(time()-last_shake >= shake_f)then
		shake_off.x = 0
		shake_off.y = 0
		for i=1, #t_shake.t do
			if(t_shake.t[i]>0)then
				t_shake.t[i] -= time_delta
				t_shake.x[i] = -sign(t_shake.x[i])* rnd(t_shake.x_in[i])
				t_shake.y[i] = -sign(t_shake.y[i])* rnd(t_shake.y_in[i])
				shake_off.x += t_shake.x[i]
				shake_off.y += t_shake.y[i]
			end
		end
		last_shake = time()
	end	
end
-->8
--player--
function init_player()
	player={
		x 						= 16,
		y 						= 0,
		w							= 16,
		h							= 16,
		spr_idle= {33},
		spr_run	= {1,3},
		spr_fal	= {5},
		spr_jmp = {7},		
		act_spr = 1,
		dx						= 0,
		dy						= 0,
		acc 				= 1,
		boost			= 6,			//jump strenght
		flipx			=	false,
		runinng = false,
		sliding	= false,
		falling = false,
		jumping = false,
		landed  = false,
		t_ani			= 0,
		ani_s			= 0.1,
		sprite  = 1,
		did_fall= false,
		energy		= 100,
		max_ener= 100
	}
	
	player_invonurable_t = 0
	
	player_jump_energy_cost = 5
	
	--physics--
	gravity = 0.3
	friction= 0.8
end

function update_player()
	//physics
	player.dy += gravity
	player.dx *= friction
	
	//movement
	local direction = get_movement_x()
	player.dx += direction*player.acc
	
	player.running =
	 abs(direction) > 0.1 and
	 not falling and
	 not jumping
	 
	player.sliding = 
		running and 
		abs(direction) <0.1
	
	--check collision x axis--
	if abs(player.dx) > 0 then
		player.flipx = player.dx < 0
		player.x += player.dx		
		
		if check_col_map(player, true)>0 then
			direction = sign(player.dx)
			player.x -= player.dx
			
			while not check_col_map(player, true) do
				player.x += direction
			end			
		end	
		
		player.dx = 0		
	end
	
	--check collision y-axis
	if player.dy>0 then
		//goimg down
		player.falling = true
		player.landed = false
		player.jumping = false
		
		player.y += player.dy
		cor = check_col_map(player, false)
						
		if cor > 0 then
			player.falling = false
			player.landed = true
			player.dy = 0
			player.y -= cor
			player.y=flr(player.y)
		else
			player.y -= player.dy
		end
	else
		//going up
		if player.dy<0 then
			player.jumping = true
			
			player.y += player.dy
			cor = check_col_map(player, false)
		
			if cor > 0 then
				player.falling = true
				player.dy = 0
				player.y += cor-player.h
				player.y=flr(player.y)
			else
				player.y -= player.dy
			end
		end	
	end	
	
	if player.energy >= player_jump_energy_cost then
		if (btnp(”) or btnp(—)) and player.landed then
			player.dy -= player.boost
			player.landed = false
			sfx(0,3)
			player.energy -= player_jump_energy_cost
		end
	end
	
	
	if btnp(Ž) then
		shoot()
	end
	
	if not player.falling and player.did_fall then
		shake(0,1,0.1)
	end
	
	player.x += player.dx
	player.y += player.dy
	
	player.did_fall = player.falling
	
	if(check_col_enem_player()) then
		hit_player(30)
	end
	
	if player_invonurable_t > 0 then
		update_flicker()
	end	
	
	player_invonurable_t -= time_delta
	
	if player.energy < 0 then
		player.energy = 0
		game_over()
	end
end

function hit_player(value)
	if player_invonurable_t <= 0 then
		player.energy -= value
		shake(1, 1, 0.2)
		player_invonurable_t = 3
		sfx(5,3)
		add_floating_txt(
			player.x,
			player.y,
			"-"..value,
			20,
			8)
	end	
end

function draw_player()
	act_ani = player.spr_idle
	
	if player.running then
		act_ani = player.spr_run
	end
	
	if player.jumping then
		act_ani = player.spr_jmp
	end
	
	if player.falling then
		act_ani = player.spr_fal
	end
	
	if player.act_spr > #act_ani then
		player.act_spr = 1
	end	
	
	player.t_ani += time_delta
	if player.t_ani >= player.ani_s then
		player.t_ani = 0
		player.act_spr += 1
		if player.act_spr > #act_ani then
			player.act_spr = 1
		end
	end 	
	player.sprite = act_ani[player.act_spr]
	
	draw_raw(
		player.sprite,
		player.x,
		player.y,
		player.w/8,
		player.h/8,
		player.flipx
	)	
end

function get_movement_cmd_x()
	if(btnp(‹)) return-1
	if(btnp(‘)) return 1
	return 0
end

function get_movement_cmd_y()
	if(btnp(”)) return-1
	if(btnp(ƒ)) return 1
	return 0
end

function get_movement_x()
	if(btn(‹)) return-1
	if(btn(‘)) return 1
	return 0
end

function get_movement_y()
	if(btn(”)) return-1
	if(btn(ƒ)) return 1
	return 0
end

function check_col_player(x,w,y,h)
	if collision(
		player.x,
	 16, 
	 player.y,
	 16,
	 x,
	 w/8,
	 96-y+1,
	 h/8
	)then
		return true		
	end
	return false
end
-->8
--game--
loose = false
wait_game = 0

game_over_screen_w = 80

function update_game()
	if not lose then
		change_color_mode(false)
		update_map()
		update_bullets()
		update_enemies()
		update_player()
		upgrade_powerups()
		update_camera()
	else	
		update_flicker()
		
		if btnp(— or Ž) then
			display_player_height()
			add_highscore(flr(player_height))
			p_act_update = update_highscore
			p_act_draw = draw_highscore
		end		
	end	
end

function draw_game()
	draw_enemies()
	draw_map()
	draw_player()
	draw_bullets()
	draw_powerups()
	draw_floating_txt()
	draw_hud()
	if lose then
		draw_game_over()
	end
end

function game_over()
	t_flicker_loose = flicker_loose_f
	lose = true
	sfx(1,3)
end

function draw_game_over()
	local box_left= (128-game_over_screen_w)/2+1
	local box_top = 50

	rectfill(
		box_left-1,
		box_top-1,
		box_left+game_over_screen_w+1,
		box_top+30+1,
		10)

	rectfill(
		box_left,
		box_top,
		box_left+game_over_screen_w,
		box_top+30,
		0)
		
	print("out of energy...",box_left+12,box_top+2,10)
	print("height:"..flr(player_height),box_left+18,box_top+11,7)
	print("— to restart",box_left+14,box_top+25,7)
end





 
-->8
--map--
map_t_h=24
map_t_w=12
ani_t = 0
ani_f = 0.5

current_height = 0

--lava--
const_lava_sprite = 25
lava_level = 6
lava_speed = 2
lava_t     = 0

function clear_map()
	col_map = {}
	for x = 1, map_t_w do
	 col_map[x] = {}
	 for y = 1, map_t_h do
	 	col_map[x][y] = 0
		end
	end
end

function init_map()
	lose = false
	current_height = 0
	
	//create walls left and right
	for y = lava_level+1, map_t_h do
		col_map[1][y]=9
		col_map[12][y]=9
	end 
	
	//generate platforms
	for y=lava_level+7, map_t_h do
		get_rnd_platform_l(y)
	end
	
	//generate start ground
	for x = 1, 3 do
		col_map[x+1][lava_level+4]=9
	end
	

	//create lava
	for x = 1, map_t_w do		
		for y = 1, lava_level do
			col_map[x][y]=25
		end
	end
end

function draw_map()	
	for x = 1, map_t_w do
	 for y = 1, map_t_h do
	 	if col_map[x][y] > 0 then
	 		local sprite = col_map[x][y]
	 		if col_map[x][y] == const_lava_sprite then
	 			sprite = lava_sprite
				end 
					 		
	 		draw_raw(sprite ,(x-1)*8,96-y*8+1)
			end
		end
	end
end

function update_map()
	if player.y < -50 then
		shift_up_map(1)
	end
	
	ani_t += time_delta
	
	if ani_t > ani_f then
		ani_t = 0
		if lava_sprite == const_lava_sprite then
			lava_sprite = const_lava_sprite+1
		end
	else
	 lava_sprite=const_lava_sprite
	end	
end

function check_col_map(obj, is_x)
	for x = 1, map_t_w do
		for y = 1, map_t_h do
			if col_map[x][y] > 0 then
				if is_x then
					if collision(				
						obj.x+0.5*obj.w-1, 
						obj.w, 
						obj.y-2, obj.w, 
						x*8,
						8, 
						(12-y)*8, 
						8
					) then
						return 1
					end
				else
					local y2 = (12-y)*8
					if collision(				
						obj.x+0.5*obj.w-1, 
						obj.w-2, 
						obj.y+5,
						obj.h-6, 
						x*8-1,
						8, 
						y2, 
						8
					) then
						if col_map[x][y] == 25 then
							game_over()
							return 0
						end
						return (obj.y+obj.h - y2 -1)
					end
				end				
			end
		end
	end
	return 0 	
end

function shift_up_map(d_y)
	for x = 1, map_t_w do
		for y = d_y, map_t_h do
			local _y = y-d_y
			if _y <= lava_level then
				col_map[x][_y] = 25
			else
				col_map[x][_y] = col_map[x][y]
			end			
		end
	end
	current_height +=d_y
	
	player.y += d_y*8	
	
	
	shift_enemies(d_y)
	shift_up_bullets(d_y)
	shift_powerups(d_y)
	shift_floating_texts(d_y)

	//build plattforms
	for y = map_t_h-d_y+1,map_t_h do
		get_rnd_platform_l(y)
	end 
end

function generate_platform(y)
	//left 
	if (y-1)%10 == 0 then
		return 1
	else
		//right
		if (y-1)%5 == 0 then
			return 2
		else
			return 0	//nothing
		end
	end
end

function get_rnd_platform_l(y)
	local index = generate_platform(y+current_height)
	if index > 0 then
		
		local e_id = 0
		if rnd()>0.5 then
			e_id = flr(rnd(#t_def_enemies.sprites)+1)	
		end
		
		if e_id > 0 then
			e_x = 0
			if index == 1 then
				e_x = 3*8
			end
			
			if index == 2 then
				e_x = 9*8
			end
			add_enemy(e_id, e_x, (y+1)*8)
		end	
		
		for x = 1, 3 do
			if index == 1 then
				col_map[1+x][y]=9
			end
			if index == 2 then
				col_map[12-x][y]=9
			end
		end
	else
		for x = 2, 11 do
			col_map[x][y]=0
		end
	end
end
-->8
--camera--
camera_yoffset = 0

function update_camera()
	camera_yoffset = 96-(player.y+96/2+8)+1
end
-->8
--enemies--
function init_enemies()
	enemy_index = 1
	t_enemy={
		id= {0,0,0,0,0,0,0,0,0,0,0,0},
		x = {0,0,0,0,0,0,0,0,0,0,0,0},
		y = {0,0,0,0,0,0,0,0,0,0,0,0},
		hp= {0,0,0,0,0,0,0,0,0,0,0,0},
		d = {0,0,0,0,0,0,0,0,0,0,0,0},
		ai= {1,1,1,1,1,1,1,1,1,1,1,1}
	}
	
	enem_ani_t = 0
	enem_ani_f = 0.2
	enem_shoot_f = 2
	enem_shoot_t = 0
	
	t_def_enemies={
		sprites={
			{52,53},
			{54,55},
			{56,57},
			{58,59}
		},
		w	={8				,8				,8,   8    },
		h	={8				,8				,8,   8    },
		hp={2				,3				,3,   3    },
		sp={1				,2				,0,   0    },
		fx={false,false,true,false}
	}
	
	enem_bul_index = 1
	
	t_enem_bul={
		x = {0,0,0,0,0,0,0,0,0,0,0,0},
		y = {0,0,0,0,0,0,0,0,0,0,0,0},
		d = {0,0,0,0,0,0,0,0,0,0,0,0}
	}
end


function add_enemy(id, x, y)
	t_enemy.id[enemy_index]=id
	t_enemy.x[enemy_index] = x
	t_enemy.y[enemy_index] = y
	t_enemy.hp[enemy_index] = t_def_enemies.hp[id]
	t_enemy.ai[enemy_index] = 1
	t_enemy.d[enemy_index] = t_def_enemies.sp[id]
	enemy_index += 1
	
	if enemy_index > #t_enemy.id then
		enemy_index = 1
	end
end

function draw_enemies()
	for i=1, #t_enemy.id do
		local e_id = t_enemy.id[i]
		if e_id>0 then
			draw_raw(
				t_def_enemies.sprites[e_id][t_enemy.ai[i]],
				t_enemy.x[i],
				96-t_enemy.y[i]+1,
				t_def_enemies.w[e_id]/8,
				t_def_enemies.h[e_id]/8,
				t_def_enemies.fx[e_id] and t_enemy.x[i] >48
			)
		end	
	end
	
	draw_enem_bul()
end

function update_enemies()
	enem_shoot_t += time_delta
	local shoot = false
	if enem_shoot_t > enem_shoot_f then
		shoot = true
		enem_shoot_t = 0
	end
	
	enem_ani_t += time_delta
	local update_ani = enem_ani_t >= enem_ani_f
	if update_ani then
		enem_ani_t = 0
	end 
	
	for i=1, #t_enemy.id do
		local id = t_enemy.id[i]
		
		if id > 0 then
			//update animation
			if update_ani then
				t_enemy.ai[i] +=1 
				if t_enemy.ai[i] > #t_def_enemies.sprites[id] then
					t_enemy.ai[i] = 1
				end
			end
			
			update_enemy(i,shoot)
			
		end
	end
	
	update_enem_bul()
end

function update_enemy(index, shoot)
	
	local x = t_enemy.x[index]
	local y = t_enemy.y[index]
	x += t_enemy.d[index]
	
	if t_enemy.x[index] < 48 then
		if x > 24 or x < 8 then
			x -= t_enemy.d[index]
			t_enemy.d[index] = -t_enemy.d[index]
		end
		
		if t_enemy.d[index] == 0 and shoot then
			add_enem_bul(x,y,1)
		end
	else
		if x > 80 or x < 64 then
			x -= t_enemy.d[index]
			t_enemy.d[index] = -t_enemy.d[index]
		end
		
		if t_enemy.d[index] == 0 and shoot then
			add_enem_bul(x,y,-1)
		end
	end
			
	t_enemy.x[index] = x				
end

function check_col_enem_player()
	for i=1, #t_enemy.id do
		if t_enemy.id[i] > 0 then
			if check_col_player(
				t_enemy.x[i],
				t_def_enemies.w[t_enemy.id[i]],
				t_enemy.y[i],
				t_def_enemies.h[t_enemy.id[i]]
			) then
				kill_enemy(i)
				return true
			end
		end		
	end
	return false
end

function kill_enemy(index)
	if rnd() > 0.3 then
		add_powerup(t_enemy.x[index],t_enemy.y[index])
	end		
	t_enemy.id[index] = 0
	shake(1,2,0.2)
	sfx(4,2)
end

function shift_enemies(d_y)
	for i=1, #t_enemy.id do
		if t_enemy.id[i] > 0 then
			t_enemy.y[i] -= d_y*8
			if t_enemy.y[i]/8 < 6 then
				t_enemy.id[i] = 0
			end
		end		
	end
	
	for i=1, #t_enem_bul.d do
		if abs(t_enem_bul.d[i]) > 0 then
			t_enem_bul.y[i] -= d_y*8
		end
	end
end

function add_enem_bul(x,y,d)
	t_enem_bul.x[enem_bul_index] = x
	t_enem_bul.y[enem_bul_index] = y
	t_enem_bul.d[enem_bul_index] = d
	enem_bul_index +=1
	if enem_bul_index > #t_enem_bul.d then
		enem_bul_index = 1
	end
	sfx(7,3)
end

function update_enem_bul()
	for i=1, #t_enem_bul.d do
		if abs(t_enem_bul.d[i]) > 0 then
			t_enem_bul.x[i] += t_enem_bul.d[i]
			if t_enem_bul.x[i] > 128 or t_enem_bul.x[i] < 0 then
				t_enem_bul.d[i] = 0
			end
			
			if check_col_player(
				t_enem_bul.x[i],
				8,
				t_enem_bul.y[i],
				8) then
				hit_player(20)
				t_enem_bul.d[i] = 0
			end		
		end	
	end
end

function draw_enem_bul()
	for i=1, #t_enem_bul.d do
		if abs(t_enem_bul.d[i]) > 0 then
			draw_raw(
				36,
				t_enem_bul.x[i],
				96-t_enem_bul.y[i]+1
			)
		end
	end
end
-->8
--bullets--
function init_bullets()
	t_bullets={
		d ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		x ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		y ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	}
	bullet_index = 1
	bullet_cool_down = .5
	bullet_last_shoot = bullet_cool_down	
end

function shoot()
	if bullet_last_shoot >= bullet_cool_down then
		if player.flipx then
			t_bullets.d[bullet_index] = -2
			t_bullets.x[bullet_index] = player.x
		else
			t_bullets.d[bullet_index] = 2
			t_bullets.x[bullet_index] = player.x + 16
		end	
		
		t_bullets.y[bullet_index] = player.y+4 
		
		bullet_index += 1
		
		if bullet_index > #t_bullets.d then
			bullet_index = 1
		end
		
		sfx(2,3)
		bullet_last_shoot = 0
	else
		sfx(3,3)
	end
end

function update_bullets()
	bullet_last_shoot += time_delta
	for i=1, #t_bullets.d do
		if abs(t_bullets.d[i]) > 0 then
			t_bullets.x[i] += t_bullets.d[i]
		
			//delete bullets outside window
			if t_bullets.x[i] < 0 or t_bullets.x[i] > 127 then
				t_bullets.d[i] = 0
			end	
		
			//check col with enemies
			for e = 1, #t_enemy.id do
				if t_enemy.id[e] > 0 then
					if check_enem_bul_col(e,i) then					
						t_bullets.d[i] = 0
						kill_enemy(e)
					end
				end
			end				
		end				
	end
end

function draw_bullets()
	for i=1, #t_bullets.d do
		if abs(t_bullets.d[i]) > 0 then
			draw_raw(
				51,
				t_bullets.x[i],
				t_bullets.y[i],
				1,
				1
			)
		end		
	end
end

function shift_up_bullets(d_y)
	for i=1, #t_bullets.d do
		if abs(t_bullets.d[i]) > 0 then
			t_bullets.y[i] += d_y*8
		end		
	end
end

function check_enem_bul_col(enem,bul)
	return collision(
		t_bullets.x[bul],
	 4, 
	 t_bullets.y[bul]-4,
	 10,
	 t_enemy.x[enem],
	 t_def_enemies.w[t_enemy.id[enem]],
	 96-t_enemy.y[enem]+1,
	 t_def_enemies.h[t_enemy.id[enem]]/8
	)		
end
-->8
--hud--
local energy_bar_l = 30
local energy_bar_h = 6

player_height = 0

function draw_hud()
	rectfill(16,16,112,24,1)
 line(16,24,112,24,3)
 display_player_height()
 display_player_energy()
end

function display_player_height()
 player_height = 
 	current_height +
 	(player.y+16+
 	camera_yoffset)/8
 print("height: "..flr(player_height), 19, 17, 7)
end

function display_player_energy()
	//draw frame
	rectfill(
		16+96-energy_bar_l-1,
		16+(8-energy_bar_h)/2,
		16+96-1,
		16+energy_bar_h+(8-energy_bar_h)/2
		,5)
		
	//draw bar
	rectfill(
		16+96-energy_bar_l-1,
		16+(8-energy_bar_h)/2,
		16+96-energy_bar_l-1+(player.energy/player.max_ener)*energy_bar_l,
		16+energy_bar_h+(8-energy_bar_h)/2
		,10)	
		
	print(player.energy.."/"..player.max_ener,16+96-energy_bar_l-1+2,16+(8-energy_bar_h)/2+1,11)		
end
-->8
--screen effects--
flicker_f = 0.2
t_flicker	= 0
dark 					= false

function update_flicker()
	t_flicker += time_delta
	if t_flicker >= flicker_f then
		t_flicker = 0
		dark = not dark
	end
	change_color_mode(dark)
end
-->8
--main menu--

local shake_f = 2
local shake_t = 0
local shake_l = 0.1
local cur_shake_f = 0
local menu_player={
	x=96/2+8+32,
	y=96/2+8
}

function update_menu()
	
	shake_t -= time_delta
	
	if shake_t <= 0 then
		change_color_mode(true)
		shake(1,1,shake_l)
		cur_shake_f = rnd(shake_f)+shake_f
		shake_t = cur_shake_f
	else
		if shake_t < cur_shake_f - shake_l then
			change_color_mode(false)
		end
	end
		
	if btnp(—) then
		p_act_update = update_game
		p_act_draw			= draw_game
	end
end

function draw_menu()
	//draw title
	map(0,0,shake_off.x + 16+32,shake_off.y+16+10,4,2)
	
	//draw line
	for x=1, 12 do
		spr(68, shake_off.x+((x-1)*8)+16,shake_off.y+ 44)
	end
	
	//dev_text
	print("by saturn91",16+26,16+32,12)

	print("— to start",16+26,16+45,7)
	
	//draw player falling
	spr(5,
		shake_off.x+menu_player.x,
		shake_off.y+menu_player.y,
		2,
		2)
		
	//draw floor
	for x=0, 2 do
			spr(9,
			shake_off.x+x*8+19,
			shake_off.y+8*8+17
			)
	end
	
	//draw enemy
	spr(52,
			shake_off.x+1*8+19,
			shake_off.y+7*8+17
			)
		
	//draw lava
	for x=0, 12 do
		for y = 10, 12 do
			spr(26,
			shake_off.x+x*8+16,
			shake_off.y+y*8+16
			)
		end
	end
	rectfill(23+17,105,23+17+50,111,0)
	print("major jam 3",23+21,89+17,7)
end
-->8
--powerups--
function init_powerups()
	power_ups={
		x	={0,0,0,0,0,0,0,0},
		y	={0,0,0,0,0,0,0,0},
		dy={0,0,0,0,0,0,0,0},
		t	={0,0,0,0,0,0,0,0},
		bl={0,0,0,0,0,0,0,0}
	}
	
	powerup_index = 1
	powerup_show_t= 4
	powerup_blink	= 7
	powerup_energy= 20
end

function add_powerup(x,y)
	power_ups.x[powerup_index] = x
	power_ups.y[powerup_index] = y
	power_ups.t[powerup_index] = powerup_show_t
	power_ups.dy[powerup_index]= 1
	power_ups.bl[powerup_index]= powerup_blink
	
	
	if power_ups.x[powerup_index] < 14 then
		power_ups.x[powerup_index]+= 4
	end
	
	powerup_index += 1
	
	if powerup_index > #power_ups.t then
		powerup_index = 1
	end
end

function upgrade_powerups()
	for i = 1, #power_ups.t do
		if power_ups.t[i] > 0 then
			power_ups.bl[i] -= 1
			if power_ups.bl[i] == 0 then
				power_ups.bl[i] = powerup_blink
				power_ups.dy[i] = - power_ups.dy[i]
			end
			power_ups.t[i] -= time_delta
		else
			power_ups.t[i] = 0
		end
	end
	
	powerup_col_with_player()
end

function draw_powerups()
	for i = 1, #power_ups.t do
		if power_ups.t[i] > 0 then
			if power_ups.dy[i] > 0 or power_ups.t[i] > 1 then
				draw_raw(
					35,
					power_ups.x[i],
					96-power_ups.y[i]+1+power_ups.dy[i],
					1,
					1
				)
			end			
		end
	end
end

function shift_powerups(d_y)
	for i = 1, #power_ups.t do
		if power_ups.t[i] > 0 then
			power_ups.y[i] -= d_y*8
		end
	end
end

function powerup_col_with_player()
	for i = 1, #power_ups.t do
		if power_ups.t[i] > 0 then
			if check_col_player(
				power_ups.x[i],
				8,
				power_ups.y[i],
				8) then
				power_ups.t[i] = 0
				player.energy += powerup_energy
				add_floating_txt(player.x,player.y,"+"..powerup_energy,10,10)
				sfx(6)	
				if player.energy > player.max_ener then
					player.energy = player.max_ener
				end
			end
		end
	end	
end
-->8
--floating texts--
function init_floating_texts()
	actual_floatingtext_index = 1
	floating_txt={
		x		={0,0,0,0,0,0,0,0,0,0},
		y		={0,0,0,0,0,0,0,0,0,0},
		txt={"","","","","","","","","",""},
		t		={0,0,0,0,0,0,0,0,0,0},
		col={0,0,0,0,0,0,0,0,0,0}
	}	
end

function add_floating_txt(x,y,string,t,col)
	local i = actual_floatingtext_index
	floating_txt.x[i] = x
	floating_txt.y[i] = y
	floating_txt.txt[i]=string
	floating_txt.t[i]=t
	if(col!=nil)then
		floating_txt.col[i] = col
	else
		floating_txt.col[i]=7
	end
	if(i < #floating_txt.x)then
		actual_floatingtext_index+=1
	else
		actual_floatingtext_index=1
	end	
end

function draw_floating_txt()
	for i = 1,#floating_txt.x do
		if(floating_txt.t[i]>0)then
			floating_txt.t[i] -= 1
			floating_txt.y[i] -= 1
			print(
				floating_txt.txt[i],
				floating_txt.x[i]+16+shake_off.x,
				floating_txt.y[i]+16+shake_off.y+camera_yoffset,
				floating_txt.col[i]
			)
		end
	end 
end

function shift_floating_texts(d_y)
	for i = 1,#floating_txt.x do
		if(floating_txt.t[i]>0)then
			floating_txt.y[i] -= d_y*8
		end
	end
end
-->8
--highscore--
highscores={
	0,0,0,0,0,0,0,0,0,0
}

last_highscore = -1


local blink_f = 12
local blink_t = blink_f
local blink = true
local highscore_shown = 0
local show_highscore_t= 3

function get_highscore()
	for i=1, #highscores do
		highscores[i]=dget(i)
	end
end

function delete_hightscore()
	for i=1, #highscores do
		highscores[i]=0
		dset(i,0)
	end
end

function save_highscore()
	for i=1, #highscores do
		dset(i,highscores[i])
	end
end

function add_highscore(height)
	last_highscore = height
	for i=1, #highscores do
		local temp = highscores[i]
		if height > highscores[i] then
			highscores[i] = height
			height = temp
		end
	end
	save_highscore()
end

function draw_highscore()
	change_color_mode(false)
	print_text_center("--highscore-- ",24,7)
	for i=0,12 do
		spr(68,i*8+1+16,31)
		spr(68,i*8+1+16,17)
		spr(84,i*8+1+16,103)
	end
	
		//draw floor
	for x=0, 2 do
			spr(9,
			x*8+80,
			8*8+17
			)
	end
	
	//draw enemy
	spr(52,
			1*8+80,
			7*8+17
			)
	//player
	spr(1,24,60,2,2)	
	print_text_center("your score: "..last_highscore.."m",107,9)	
	
	draw_scores(35)
	
	if highscore_shown >= show_highscore_t and not blink then
		draw_continue_box()
	end
end

function draw_scores(y)
	//get last highscore pos
	local hs_pos = -1
	
	blink_t -= 1
	
	if blink_t == 0 then
		blink_t = blink_f
		blink = not blink
	end
	
	for i=1, #highscores do
		if highscores[i] == last_highscore then
			hs_pos = i
			break
		end
	end
	
	for i=1, #highscores do
		local indexer = "  "
		local col = 5
		if i== hs_pos then
			col = 11
			indexer="‘"
		else
			if i==1 then
				col = 10
			else
				if i==2 then
					col=9
				else
					if i==3 then
						col=5
					end
				end
			end
		end
		
		if blink or i != hs_pos then
			print_text_center(tostr(indexer..highscores[i]).."m ",(i-1)*7+y, col)
		end		
	end
end

function draw_continue_box()
	local box_left= 47
	local box_top = 41+16+1
	draw_box(box_left, box_top, box_left+34, box_top+10, 7, 0, 1)
	print("press —", box_left+2,box_top+3,7)
end

function update_highscore()
	if btnp(—) or btnp(Ž) then
		init_cart()
		highscore_shown = 0
	end
	
	highscore_shown += time_delta
end
-->8
--ui--
function draw_box(x1, y1, x2, y2, col1, col2, t)
	if(t==nil) then
		t=1
	end
	rectfill(x1, y1, x2, y2, col1)//frame color
	rectfill(x1+t, y1+t,x2-t , y2-t, col2)//content color
end
-->8
--utils--
function utils_init()
	debug_str={"","","","","","","","","","","",""}
	debug_col={10,10,10,10,10,10,10,10,10,10,10,10}
end

function collision(x1, w1, y1, h1, x2, w2, y2, h2)

	if (x1 < x2 + w2 and
	   x1 + w1 > x2 and
	   y1 < y2 + h2 and
	   y1 + h1 > y2) then
	   
	   return true
	end
	return false
end

function debug(text, col)
	if(debug_str[1] != text)then
		for i=#debug_str, 2, -1 do
			debug_str[i]=debug_str[i-1]
			debug_col[i]=debug_col[i-1]
		end
		debug_str[1]=text	
		if(col!=nil)then
			debug_col[1] = col
		else
			debug_col[1] = 10
		end	
	end
end

function draw_debug()
	for i=1, #debug_str do
		print(debug_str[i], 2, 128-i*6+1, debug_col[i])
	end
end

function sign(num)
	if(abs(num)>0)then
		return abs(num)/num
	else
		return 1
	end	
end

function change_color_mode(dark)
	if dark then
		for i=1, 15 do
			pal(i,i+128,1)
		end
	else
		for i=0, 15 do
			pal(i,i,1)
		end
	end	
end

function print_text_center(txt, y, col)
	print(txt, (127-4*#txt)/2, y, col)
end
__gfx__
00000000000000000000000000000000000000000080000000000000000000000000000067777776000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000088800000000000000000555ccc5500076000067000000000000000000000000000000000000000000000000
00700700000000555ccc5500080000000000000000800000000000000000c5000000500070000007000000000000000000000000000000000000000000000000
0007700000000c5000000500888cc0555ccc5500000c00000000000000cc0500a9a0500070000007000000000000000000000000000000000000000000000000
00077000080cc0500a9a050008000c50000005000000c0555ccc550008000500a9a0500070000007000000000000000000000000000000000000000000000000
00700700888000500a9a0500000000500a9a050000000c5000000500888005000000500070000007000000000000000000000000000000000000000000000000
000000000800cc5000000500000000500a9a0500000000500a9a05000800c55cccc5500076000067000000000000000000000000000000000000000000000000
000000000000cc55cccc55000000cc5000000500000000500a9a05000000ccccccccc00067777776000000000000000000000000000000000000000000000000
00000000000cccccccccc0000000cc55cccc55000000cc5000000500000cccc66666660098889888898889880000000000000000000000000000000000000000
00000000000ccccc66666660000cccccccccc0000000cc55cccc5500000ccc999cccc00089888988889888980000000000000000000000000000000000000000
00000000000cccc999ccc000000ccccc66666600000cccccccccc000000ccc99ccccc00088988898888988890000000000000000000000000000000000000000
00000000000cccc99cccc000000cccc999ccc000000ccccc66666600000cccccccccc00088898889988898880000000000000000000000000000000000000000
000000000000cccccccc00000000ccc99ccc0000000cccc999ccc0000000cccccccc000098889888898889880000000000000000000000000000000000000000
0000000000000cc00cc0000000000cc000cc00000000ccc99ccc000000000cc00cc0000089888988889888980000000000000000000000000000000000000000
000000000000ccc00cc0000000000cc00ccc0000000c0cc000cc0c000000ccc00cc0000088988898888988890000000000000000000000000000000000000000
000000000000c00000cc0000000000cc0c0000000000cc00000cc0000000c00000cc000088898889988898880000000000000000000000000000000000000000
00000000000000000000000000000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000111111108aaa9800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000555ccc55001ccccccc8aaaaa980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c50000005006c7c7c7c8aa77aa80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080cc0500a9a05006c7c7c7c8aa77aa80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888000500a9a05001ccccccc82aaaaa80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000800cc5000000500011111110822aa800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000cc55cccc550000000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cccccccccc00000aaaa00000000000000000000000000000000000000000000000000090990900000000000000000000000000000000000000000
00000000000ccccc666666600aa999a0000000000088880000000000099999900000000000000000099999900909909000000000000000000000000000000000
00000000000cccc999ccc000a999999a008888000808808009999990088888800000000000000000086886800999999000000000000000000000000000000000
00000000000cccc99cccc000a997799a080880800888888008888880080880800999900509999050088998800868868000000000000000000000000000000000
000000000000cccccccc0000a997799a088888800888888008088080088668809888866698886660088888800889988000000000000000000000000000000000
0000000000000cc00cc00000a999999a088888800027780008866880020000800222200502222050008008000889988000000000000000000000000000000000
0000000000000cc00cc000000a9999a0002778000020080000200800020000800056000000560000008008000080080000000000000000000000000000000000
000000000000cc0000cc000000aaaa00020000800020080002000080020000800555600005556000008008000080080000000000000000000000000000000000
00000000006000666600066660006666000000000000066666666666666000006666666666666666666666660000000000000000000000000000000000000000
00666666666000066000006600000660bb00bb000006655555555555555660008888888855555555555555550000000000000000000000000000000000000000
0066666666600006660000660000066000bb00bb0065555555555555555556005555555555575557755555550000000000000000000000000000000000000000
0066600000600006666000660000066000000000065555555555555555555560aaaaaaaa55755575755555550000000000000000000000000000000000000000
00660000000000066066006600000660000000000655555555555555555555605555555555775575755555550000000000000000000000000000000000000000
00660000000000066006606600000660000000002555555555555555555555563333333355757575755555550000000000000000000000000000000000000000
00660000000000066000666600000660000000002555555555555555555555565555555555757577755555550000000000000000000000000000000000000000
00666600000000066000066600000660000000002555555555555555555555561111111155777555755555550000000000000000000000000000000000000000
00666600000000066000006600000660000000005555555655555555255555555555555555555555555555550000000000000000000000000000000000000000
00660000000000066000006600000660880088005555555655555555255555558888888855566555555665550000000000000000000000000000000000000000
00660000000000066000006600000660008800885555555655555555255555555555555555688655556aa6550000000000000000000000000000000000000000
0066000000000006600000660000066000000000555555565555555525555555aaaaaaaa5d8888655daaaa650000000000000000000000000000000000000000
0066600000600006600000660000066000000000555555565555555525555555555555555d8888655daaaa650000000000000000000000000000000000000000
00666666666066066000006606600660000000005555555655555555255555553333333355d88d5555daad550000000000000000000000000000000000000000
006666666660660660000066066006600000000055555556555555552555555555555555555dd555555dd5550000000000000000000000000000000000000000
00000000006000666600066660006666000000005555555655555555255555551111111155555555555555550000000000000000000000000000000000000000
00000000000000000000000000000000000000002555555555555555555555566666666600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002555555555555555555555565555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002555555555555555555555565555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000255555555555555555555205555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000255555555555555555555205555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000025555555555555555552005222225500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000002255555555555555220006151512500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000022222222222222000006515152500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006151512500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006515152500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006151512500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005666665500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002222222200000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4041424345464646464646464646464646464647000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525357566666666666666666666666665655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057550000000000000000000000005755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057584848494a46464646464668465955000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000065666666666666666666666678666667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001000011010110501205016050190501c0501e000210002300024000240001c05020050200501f0001c0001b0000000000000000000000000000000000000000000000000000000000000000000000000
00060000120501a050180501e0502405021050200501d0501705013050100500c0500905008050070500605003050030500205002050000000000000000000000000000000000000000000000000000000000000
0001000009050180501f0502205024050250502505022050190500e05005050010500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000070500a050090500705003050040500605007050050500205002050010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000462005050050500862007050066200605008050080500d62004020040500705003620030500605008620060500305007050016100205002050006100060000600006000060000600006000060000600
0001000020050220502305023050200501705013050110500f0500d05008050040500305000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000003050050500c050100501305016050190501f05027050200501b0501e0502305027050220502d0502d050000000000000000000000000000000000000000000000000000000000000000000000000000
00020000130501e0501e0501a050140500d05017050190501c0501d0500e050080500705004050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002505025050160001a0002a0502a05024000260002a0002c0002b0002a000270002600027000290002b0002b0000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c6150000018615000000c51000000000000000018615000000000018500245100000018510000000c6150000018615000000c5100000000000000001861500000000000000024510000001851000000
0110000024010000002401000000280102801029010000002801000000280100000029010290102b0100000024010000002401000000280102801029010000002401000000240100000026010240102801000000
011000002800000000280000000026010260102801000000280000000029010000002901028000290100000024010000002401000000280102801029010000002401000000240100000026010290102801000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0a 42 43 44
00 0a 0b 43 44
00 0a 0c 43 44
00 0a 42 43 44
02 41 0b 0c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
