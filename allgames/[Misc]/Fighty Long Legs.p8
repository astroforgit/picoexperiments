pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- smash like multiplayer game
-- by sebastian lind

players = {} 

respawn_time = 120

small_length, small_stamina, small_lag = 12, 15, 8

long_stamina, stretching_stamina, long_lag = 16, 0.5, 12

knock_back_dec_fastest, knock_back_dec_fast, knock_back_dec_slow = 0.8, 0.88, 0.93

start_speed, start_size, start_acc = 1, 4, 0.15

stamina_recharge, stamina_max, stamina_over_use = 0.3, 43, 0.5

shoot_d_normal, shoot_d_banana, shoot_speed,speed_up, missile_speed = 15, 40, 1.9, 2, 3

power_up_times={
	180, -- shoot
	180, -- banana
	180, -- speed
	300, -- invis
	360, -- flight
	240  -- missile
}

function init_player(x, y, player, stocks, is_ai, is_hat)
	local p = {
	x = x,
	y = y,
	ox = x-1,
	oy = y,
	dx = 0,
	dy = 0,
	flip = false,

	speed = start_speed,
	percentage = 1,
	acc = start_acc,

	attack_speed = 0,
	attack = 0,
	state = 0,
	angle = 0,
	size = start_size,
	
	oax = 0,
	oay = 0,
	nax = 0,
	nay = 0,
	px = 0,
	py = 0,

	spr = 16 + 16 * player,
	col = player == 1 and 2 or 10,
	player = player, -- change to id ...

	stretch = false,
	respawn = false,
	is_outside = false,
	won = false,
	confirm = -1,

	is_ai = is_ai,
	ai_walk_steps=0,
	ai_stretch_steps=0,
	ai_w_x = 64,
	ai_w_y = 64,
	ai_attack_range=20+flr(rnd(10)),
	
	knock_back_speed = knock_back_dec_fast,

	respawntimer = 0,
	stock = stocks,

	stamina = stamina_max,
	walk_slow = 1,
	walk_fast = 1,
	end_lag = 0,

	power = 0,
	power_up = 0,
	power_up_start_time = 0,
	power_up_time = 0,
	shoot_delay=shoot_d_normal,
	stretch_sfx,
	wing_c=0,
	missile_speed=0,
	missile_on=false,
	
	leglx = x - 3,
	legly = y + 6,
	legrx = x + 2,
	legry = y - 4,
	legs = init_legs(x, y, 1.5),

	h_on = is_hat,
	h_a = 0,
	h_p = 0,
	hat = is_hat and 1+flr(rnd(31)) or 0,
	h_x = x,
	h_y = y,
	}
	add(players, p)
end

function updateplayers()
	for k,p in pairs(players) do
		if p.state == 0 then
			recover_stamina(p) 
			if p.is_ai then
				ai_logic(p)
			else
				movement(p)
			end
		end

		for k,op in pairs(players) do
			if p.player ~= op.player then
				p.flip = p.x < op.x
				collision(p,op)
				missile(p,op)
			end 
		end

		if (not p.stretch and p.missile_on == false)update_legs(p.legs, p)
		if (p.power_up > 0)handle_powerup(p)
		if (p.shoot_delay > 0)p.shoot_delay-=1
		p.is_outside = p.x >= 128 or p.x <= 0 or p.y >= 128 or p.y <= 0
		if p.hat > 0 then 
			if p.h_on then 
				p.h_x = p.x
				p.h_y = p.y
			else
				lose_hat(p)
			end
		end 

		if countdown <= 0 then
			if p.state == 0 then 
				if not p.stretch then
					if p.walk_slow == 1 and not p.respawn then
						if p.power_up ~= 1 and p.power_up ~= 2 then
							if (not p.missile_on)do_small_attack(p)
							do_long_attack(p)
						elseif p.shoot_delay <= 0 then
							do_shoot(p)
						end
					end
				else
					stretching(p)
				end
			elseif p.state == 1 then
				attacking(p)
			elseif p.state == 2 then
				retrackting(p)
			elseif p.state == 3 then
				push_back(p)
			elseif p.state == 4 then
				end_lag(p)
			end
			outside_of_arena(p)
			respawn(p)
		end
	end
end

function missile(p, op)
	if p.power_up == 6 and p.missile_on and not op.respawn then
		shake+=0.005
		sfx(40)
		local angle = angle(op.x,op.y,p.x,p.y)
		initparticle(p.x-rnd(4)+rnd(4),p.y-rnd(4)+rnd(4),-angle,0.5,1+flr(rnd(2)), 7)
		p.spr=25 + 16 * p.player
		p.missile_speed = lerp(p.missile_speed, missile_speed, 0.2)
		p.x+=p.missile_speed * cos(angle)
		p.y+=p.missile_speed * sin(angle)
	end
end

function end_missile(p)
	p.power_up=0
	p.power_up_time=0
	p.missile_speed=0
	p.missile_on=false
	reset_legs(p.legs, p)
end

function recover_stamina(p)
	if p.stamina < stamina_max then
		p.stamina += stamina_recharge
	elseif p.stamina >= stamina_max then
		p.stamina = stamina_max
		p.walk_slow = 1
	end
	
	if p.stamina < 0 then
		p.walk_slow = stamina_over_use
		p.stamina = 0
	end
	if p.walk_slow < 1 and flr(p.stamina) % 5 == 0 then
		initparticle(p.x-rnd(4)+rnd(4),p.y,0.75-rnd(0.04)+rnd(0.04),1+rnd(1), 1+flr(rnd(2)), 12)
	end
end

function end_lag(p)
	if p.end_lag > 0 then 
		p.end_lag -= 1
	else
		p.state = 0
	end
end

function collision(p,op) --also messy
	if (not p.respawn and not op.respawn) and p.state ~= 3 and op.state ~= 3 then
		if a_circ_collision(p,op) then 
			local p_power_distance = distance(p.oax,p.oay,p.nax,p.nay)
			local op_power_distance = distance(op.oax,op.oay,op.nax,op.nay)
			
			local p_angle = angle(p.x, p.y, p.oax, p.oay)
			local op_angle = angle(op.x, op.y, op.oax, op.oay)

			local prevdx = p.dx
			local prevdy = p.dy

			if (p.power_up == 6 and op.state == 0) or (op.power_up == 6 and p.state == 0) then --missile attack
				shake+=0.25
				sfx(42)
				if p.power_up == 6 then
					end_missile(p)
					op.state = 3
					op.knock_back_speed = 0.9
					op.angle = p_angle
					distribute_power(op, 40, 1)
				else
					end_missile(op)
					p.state = 3
					p.knock_back_speed = 0.9
					p.angle = op_angle
					distribute_power(p, 40, 1)
				end
			elseif p.state ~= 1 and op.state ~= 1 then -- both just moves
				p.x = p.ox
				p.y = p.oy
				op.x = op.ox
				op.y = op.oy
				p.stretch = false
				op.stretch = false
				p.state = 0
				op.state = 0

				p.dx = op.dx
				p.dy = op.dy
				op.dx = prevdx
				op.dy = prevdy
				if op.is_ai then 
					op.speed /= 2
				end
				sfx(21)

				initparticle(p.x-rnd(4)+rnd(4),p.y-rnd(4)+rnd(4),-p_angle,0.5,1+flr(rnd(2)), 7)
			elseif p.state == 1 and op.state ~= 1 then -- just one attack
				if(p.attack==1) then sfx(20) else sfx(24) end
				shake+=0.12
				hitstun = 4
				p.state = 2
				op.state = 3
				op.knock_back_speed = knock_back_dec_fast

				op.angle = p_angle
				distribute_power(op, p_power_distance, 1)
				for i=0,3 do
					initparticle(op.x+rnd(8)-rnd(8),op.y+rnd(8)-rnd(8), p_angle-rnd(1)/20 +rnd(1)/20, 3+rnd(2)*op.knock_back_speed,1+flr(rnd(3)), p.col)
				end
			elseif p.state == 1 and op.state == 1 then -- both attack
				shake+=0.10
				p.state = 3
				op.state = 3
				
				op.angle = p_angle
				p.angle = op_angle
				distribute_power(op, p_power_distance, 0.75)
				distribute_power(p, op_power_distance, 0.75)

				-- calculate a small attack as a block
				if p.attack == 1 and op.attack ~= 1 then
					p.knock_back_speed = knock_back_dec_fast
					op.knock_back_speed = knock_back_dec_slow
					hitstun = 10
					sfx(23)
				elseif p.attack == 1 and op.attack == 1 then
					p.knock_back_speed = knock_back_dec_fast
					op.knock_back_speed = knock_back_dec_fast
					hitstun = 8
					sfx(22)
				else
					p.knock_back_speed = knock_back_dec_slow
					op.knock_back_speed = knock_back_dec_slow
					local midx = lerp(p.x, op.x, 0.5)
					local midy = lerp(p.y, op.y, 0.5) 
					initcircle(midx, midy, 4, 40, 7)
					hitstun = 12
					sfx(25)
				end 

				for i=0,4 do
					initparticle(op.x+rnd(8)-rnd(8),op.y+rnd(8)-rnd(8), p_angle-rnd(1)/20 +rnd(1)/20, 3+rnd(2)*op.knock_back_speed,2+flr(rnd(3)), p.col)
					initparticle(p.x+rnd(8)-rnd(8),p.y+rnd(8)-rnd(8), op_angle-rnd(1)/20 +rnd(1)/20, 3+rnd(2)*p.knock_back_speed,2+flr(rnd(3)), op.col)
				end
			end
		end
	end
end

function distribute_power(pl, power_distance, strength)
	pl.power = ((power_distance / 8) * pl.percentage) * strength
	pl.percentage += power_distance / 30 * strength
	if pl.power_up == 6 then
		initcircle(pl.x, pl.y, 3, 40, 7)
		hitstun = 20
		end_missile(pl)
	end
	if pl.is_ai then 
		pl.speed = 0
	end
	if pl.h_on and pl.hat > 0 and pl.power > 2 then 
		sfx(8)
		pl.h_on = false
		pl.h_a = pl.angle
		pl.h_p = pl.power * 1.5
	end
end

function outside_of_arena(p)
	local is_dead = not p.respawn and game_state ~= 3 and p.power_up ~= 5 and
		((not circ_collision(p.x,p.y,arenax,arenay,4,arenarad) and 
		p.state == 0 and not p.stretch) or 
		(p.state ~= 0 and p.is_outside))
	if is_dead then
		shake+=0.08
		initcircle(p.x, p.y, 3, 80, p.col)
		for i = 0, 20 do
			initparticle(p.x+4,p.y+4, 0.05*i, 3, 2+flr(rnd(2)), 7)
			initparticle(p.x+4,p.y+4, 0.05*i, 6, 4+flr(rnd(4)), p.col)
		end
		remove_stock(p)
	end
end

function remove_stock(p)
	if not p.respawn then
		p.respawn = true
		p.stretch = false
		p.percentage = 1
		p.stamina = stamina_max
		p.walk_slow = 1
		p.ai_stretch_steps = 0
		p.walk_fast = 1
		p.state = 0
		p.angle = 0
		p.power = 0
		p.hat = 0
		p.x = 60 + rnd(8)
		p.y = 60 + rnd(8)
		p.spr=18 + 16 * p.player
		p.power_up = 0
		p.power_up_time = 0
		p.missile_speed = 0
		p.missile_on = false
		sfx(29)
		reset_legs(p.legs, p)
		p.stock -= 1

		if p.stock == 0 then
			game_over()
		end
	end
end

function respawn(p)
	if p.respawn then
		if p.respawntimer < respawn_time then
			p.respawntimer+=1
			if (p.respawntimer % 4 == 0)initparticle(p.x,p.y, 0.75, 1 + flr(rnd(2)),1+flr(rnd(2)), p.col)
		else 
			p.spr=16 + 16 * p.player
			p.respawntimer = 0
			p.respawn=false
			sfx(43)
			-- can stick here...
		end
	end
end

function handle_powerup(p)
	if p.power_up == 3 then
		p.walk_fast = speed_up
		if abs(p.dx) > 1.7 or abs(p.dy) > 1.7 then
			initparticle(p.x-4+rnd(8),p.y-4+rnd(8), 0,0, rnd(2), 10)
		end
	end
	if p.power_up == 5 then
		if p.wing_c < 1.9 then
			p.wing_c+=0.1	
		else
			p.wing_c=0
		end
	end

	if p.power_up_time > 0 then 
		p.power_up_time-=1
	else
		if (p.power_up == 6)end_missile(p)
		p.power_up_time = 0
		p.power_up = 0
		p.walk_fast = 1
	end
end

function movement(p)	
	p.ox = p.x
	p.oy = p.y
	
	p.dx *= 0.85
	p.dy *= 0.85

	local speed =  p.speed * p.walk_slow * p.walk_fast
	local acc = p.acc * p.walk_fast

	p.dx=min(p.dx, speed)
	p.dx=max(p.dx,-speed)
	p.dy=min(p.dy, speed)
	p.dy=max(p.dy,-speed)

	local moved = false
	if btn(0, p.player) then 
		p.dx-= acc
		moved=true
	end
	if btn(1, p.player) then 
		p.dx+= acc
		moved=true
	end
	if btn(2, p.player) then 
		p.dy-= acc
		moved=true
	end
	if btn(3, p.player) then 
		p.dy+= acc
		moved=true
	end

	p.x+=p.dx
	p.y+=p.dy
	if moved then
		p.angle = angle(p.x, p.y, p.ox, p.oy)
	end
end

function ai_logic(p) -- messy code, does somewhat its job
	local n_a = 0
	for k, op in pairs(players) do		
		if p.player ~= op.player then
			local distance_to_player = distance(op.x, op.y, p.x, p.y)
			local is_running_away = p.percentage > 2.6 and op.percentage < 3 and distance_to_player < 22 and (arenatime >= halftime and is_half_time)

			-- determine walking angle
			if p.respawn and (arenatime < halftime and is_half_time) then
				n_a=angle(arenax + rnd(4) - rnd(4), arenay + rnd(4) - rnd(4), p.x, p.y)
			elseif #power_ups > 0 and power_ups[1].transparent_c <= 0 then 
				n_a = angle(power_ups[1].x, power_ups[1].y, p.x, p.y)
			elseif p.ai_stretch_steps > 0 then
				p.ai_stretch_steps-=1
				if p.x < 4 or p.y < 4 or p.x > 124 or p.y > 124 then
					n_a=angle(arenax, arenay, p.x, p.y)
				else
					n_a=angle(p.x, p.y, op.x, op.y)
				end
			elseif p.ai_walk_steps > 0 then
				p.ai_walk_steps-=1
				n_a = angle(p.ai_w_x, p.ai_w_y, p.x, p.y)
				
				if distance(p.ai_w_x, p.ai_w_y, p.x, p.y) < 6 then
					p.ai_walk_steps = 0
				end
			elseif circ_collision(op.x, op.y, arenax, arenay, 4, arenarad) then
				if is_running_away then
					n_a=angle(p.x, p.y, op.x, op.y)
				else
					n_a=angle(op.x, op.y, p.x, p.y)
				end
			else
				random_w_point(p) -- just walk somewhere else
			end
		
			--attack
			if not p.respawn and not op.respawn and not p.missile_on and countdown <= 0 and p.walk_slow == 1 and p.ai_stretch_steps <= 0 then
				if p.power_up ~= 1 and distance_to_player < p.ai_attack_range and (p.stamina > 30 or op.percentage > 3.5) then
					-- pick new attack range
					p.ai_attack_range = 21 + flr(rnd(10))
					--attack not in walking direction
					if is_running_away or p.ai_walk_steps > 0 then 
						p.angle  = angle(op.x, op.y, p.x, p.y)
					else
						p.angle = n_a
					end
					small_attack(p)
					return
				elseif (p.power_up == 1 or p.power_up == 2) and p.shoot_delay <= 0 then
					shoot(p)
				end
			end

			-- check if it should walk randomly or stretch
			if p.ai_walk_steps <= 0 and p.ai_stretch_steps <= 0 and (arenatime > halftime and is_half_time)
			 and (distance_to_player > 36 or op.respawn or countdown > 0 or op.state == 3 or p.respawn) then
				local step_r = rnd()

				if step_r > 0.98 and not op.respawn and not p.respawn and countdown <= 0 and p.walk_slow == 1 then -- stretch 
					p.ai_stretch_steps = 24 + flr(rnd(50))
					long_attack(p)
				elseif step_r > 0.9 or op.respawn then -- walk random
					random_w_point(p)
				end
			end
		end
	end

	p.speed=lerp(p.speed, start_speed * 0.7, 0.03)
	p.ox = p.x
	p.oy = p.y

	p.x += p.speed * cos(n_a) * p.walk_slow * p.walk_fast
	p.dx = p.x - p.ox	
	p.y += p.speed * sin(n_a) * p.walk_slow * p.walk_fast
	p.dy = p.y - p.oy
end

function random_w_point(p)
	p.ai_walk_steps = 20 + flr(rnd(60))
	p.ai_w_x, p.ai_w_y = get_point_in_circle(arenax,arenay,arenarad)
end

function get_point_in_circle(x,y,rad)
	local random_r = (rad-10) * sqrt(rnd())
	local theta = rnd() * 2 * 3.14
	return x + random_r * cos(theta), y + random_r * sin(theta)
end

function do_shoot(p)
	if btnp(4, p.player) and not p.respawn then
		shoot(p)
	end
end

function shoot(p)
	for k, op in pairs(players) do
		if p ~= op then
			sfx(p.power_up == 1 and 26 or 44)
			initbullet(p.x,p.y, angle(op.x,op.y,p.x,p.y), p.player,p.power_up)
			p.shoot_delay = p.power_up == 1 and shoot_d_normal or shoot_d_banana
			p.spr = 21 + 16 * p.player
		end
	end
end

function do_small_attack(p)
	if btnp(4, p.player) then
		small_attack(p)
	end
end

function small_attack(p)
	p.dx = 0
	p.dy = 0
	p.oax = p.x
	p.oay = p.y
	p.nax = p.x + cos(p.angle) * small_length
	p.nay = p.y + sin(p.angle) * small_length
	p.state = 1
	p.attack = 1
	sfx(37)
	p.stamina-=small_stamina
	p.end_lag = small_lag
	
end

function do_long_attack(p)
	if btn(5,p.player) then
		long_attack(p)
	end
end

function long_attack(p)
	if p.power_up == 6 then 
		if (not p.missile_on)shake+=0.1
		sfx(12)
		p.missile_on=true
		return
	end
	p.spr=22 + 16 * p.player
	p.dx = 0
	p.dy = 0
	p.oax = p.x
	p.oay = p.y
	p.stretch = true
	p.end_lag = long_lag
end

function attacking(p)
	p.x=lerp(p.x,p.nax,0.35)
	p.y=lerp(p.y,p.nay,0.35)
	
	if distance(p.x, p.y, p.nax, p.nay) < 0.5 then 
		p.state = 2
		p.spr=19 + 16 * p.player
	end
end

function retrackting(p)
	p.x=lerp(p.x,p.oax,0.25)
	p.y=lerp(p.y,p.oay,0.25)
	p.size=lerp(p.size,start_size,0.3)
	if distance(p.x, p.y, p.oax, p.oay) < 0.5 then 
		p.state = 4
		p.spr = 16 + 16 * p.player
	end
end

function stretching(p)
	local distance = distance(p.x, p.y, p.oax, p.oay)
	if (btn(5, p.player) or p.ai_stretch_steps > 0) and not p.is_outside and p.walk_slow == 1 then
		p.stamina-= stretching_stamina
		p.speed = (start_speed - (distance / 42) * start_speed)
		if p.speed < 0 then
			p.speed = 0
		end
		local new_stretch_sfx = min(30 + flr(distance / 10),35)
		if (new_stretch_sfx ~= p.stretch_sfx) then 
			sfx(new_stretch_sfx)
			p.stretch_sfx = new_stretch_sfx
		end
	else
		p.state = 1
		p.stamina -= long_stamina
		local angle = angle(p.oax, p.oay,p.x, p.y)
		p.speed = start_speed
		p.stretch = false
		p.attack = 2
		sfx(36)
		p.dx = 0
		p.dy = 0
		p.nax = p.oax + cos(angle) * distance
		p.nay = p.oay + sin(angle) * distance
	end
end

function push_back(p)
	p.power*=p.knock_back_speed
	p.spr=20 + 16 * p.player

	local ox = p.x
	local oy = p.y
	p.x = p.x + cos(p.angle) * p.power
	p.y = p.y + sin(p.angle) * p.power
	--calc delta instead
	p.dx = p.x - ox
	p.dy = p.y - oy

	if p.power < 0.1 then
		p.state = 0
		p.spr=16 + 16 * p.player
	end
end

function lose_hat(p)
	p.h_p *= 0.99 
	p.h_x = p.h_x + cos(p.h_a) * p.h_p
	p.h_y = p.h_y + sin(p.h_a) * p.h_p
end

function draw_player(p)
	if p.power_up ~= 4 then
		local bounce = p.spr % 2 == 0 and 1 or 0
		if p.power_up == 5 then
			fillp()
			circfill(p.x,p.y+8,4+bounce,2)
			fillp()
		end
		if not p.respawn and not p.missile_on and (p.power_up ~= 5 or (p.power_up == 5 and p.stretch == true)) then
			draw_legs(p.legs, p)
		end
		local b_dead = p.respawn and bounce*2 or 0
		spr(p.spr, p.x-4, p.y-4+b_dead,1,1,p.flip)
		
		if p.hat > 0 then
			spr(127+p.hat,p.h_x-4, p.h_y-9-bounce,1,1,p.flip)
		end
		if p.power_up == 5 then 
			spr(178+p.wing_c,p.x-12,p.y-3-bounce)
			spr(178+p.wing_c,p.x+4,p.y-3-bounce,1,1,true)
		end
	end

--print(p.missile_speed, p.x, p.y, 2)
end

--legs

function init_legs(x, y, speed)
	local legs = {
		rx = x - 3,
		ry = y + 6,
		lx = x + 3,
		ly = y + 6,
		speed = speed,
		stop = false,
		area = 10,
		pointx = x,
		pointy = y + 4,
	}
	return legs
end

function update_legs(l, p)
	if not l.stop then
		local dist = distance(l.rx, l.ry, l.pointx, l.pointy)
		l.rx += p.dx * l.speed
		l.ry += p.dy * l.speed
		if dist >= l.area then 
			l.lx = p.x + 3
			l.ly = p.y  + 6
			l.pointx = l.rx
			l.pointy = l.ry
			l.stop = true
			if not p.respawn then 
				if game_state == 3 and not p.won then 
					p.spr = 23 + 16 * p.player
				else
					p.spr = 16 + 16 * p.player
				end
			end
		end
	else
		local dist = distance(l.lx, l.ly, l.pointx, l.pointy)
		l.lx += p.dx * l.speed
		l.ly += p.dy * l.speed
		if dist >= l.area then 
			l.rx = p.x - 3
			l.ry = p.y + 6
			l.pointx = l.lx
			l.pointy = l.ry
			l.stop = false
			if not p.respawn then 
				if game_state == 3 and not p.won then 
					p.spr = 24 + 16 * p.player
				else
					p.spr = 17 + 16 * p.player
				end
			end
			sfx(28)
			initparticle(l.rx + rnd(5),l.ry, 0.01, -0.5, 1, 7)
		end
	end
end

function reset_legs(l, p)
	l.rx = p.x - 3
	l.ry = p.y + 6
	l.lx = p.x + 3
	l.ly = p.y + 6
end

function draw_legs(l, p)
	line(p.x - 2, p.y + 3, l.rx, l.ry, 7)
	line(p.x + 2, p.y + 3, l.lx, l.ly, 7)
end

bullets={}
function initbullet(x, y, angle, player, type)
	local start_spr=160 + player * 2 + (type-1) * 4
	
	local b={
		x=x,
		y=y,
		angle = angle,
		player = player,
		incol = 8,
		size = 2,
		speed = type == 1 and shoot_speed or 0,
		type = type,
		s_spr = start_spr,
		spr = start_spr,
		knock_back = type == 1 and 15 or 10,
		damage = type == 1 and 0.5 or 1,
		col = player == 1 and 9 or 13,
		timer=0
	}
	add(bullets, b)
end

function updatebullets()
	for k,b in pairs(bullets) do
		b.x+=b.speed*cos(b.angle)
		b.y+=b.speed*sin(b.angle)

		bullet_collision(b)

		if b.timer < 30 then 
			b.timer+=1
		else
			b.timer=0
			if b.spr > b.s_spr then 
				b.spr-=1
			else
				b.spr+=1
			end
		end
		if b.x >= 128 or b.x <= 0 or b.y >= 128 or b.y <= 0 then
			del(bullets, b)
		end
	end
end

function bullet_collision(b)
	for k, p in pairs(players) do
		if (b.player ~= p.player and not p.respawn and p.power_up ~= 5) then
			if circ_collision(b.x,b.y,p.x, p.y, b.size, 4) then
				if p.state ~= 3 then 
					p.state = 3
					sfx(b.type == 1 and 27 or 41)
					p.angle = b.type == 1 and b.angle or angle(b.x,b.y,p.x,p.y)
					p.knock_back_speed = b.type == 1 and knock_back_dec_fastest or knock_back_dec_slow
					distribute_power(p, b.knock_back, b.damage)
				end
				for i=0, 3 do initparticle(b.x,b.y,0,0,2,b.incol) end
				del(bullets, b)
			end
		end
	end
end

function draw_bullet(b)
	spr(b.spr,b.x-4,b.y-4)
end

-->8
--particles
particles={}
function initparticle(x,y,sangle,sspeed,size,col)
	local p={
		x=x,
		y=y,
		angle= sangle == 0 and rnd(0) or sangle,
		speed = sspeed == 0 and rnd(2) or sspeed,
		size=size,
		col=col
	}
	add(particles,p)
end

function updateparticle(p)
	p.speed*=0.9
	p.x+=p.speed*cos(p.angle)
	p.y+=p.speed*sin(p.angle)
	local speed = p.size > 5 and 0.4 or 0.09
	p.size -= speed
	if(p.size <=0)del(particles,p)
end

function drawcircpart(p)
	circfill(p.x,p.y,p.size,p.col)
end

circles={}
function initcircle(x,y,speed, maxsize, col)
	local p={
		x=x,
		mx=x,
		y=y,
		size=0,
		maxsize=maxsize,
		col=col,
		speed=speed
	}
	add(circles,p)
end

function updatecircle(p)
	p.size += p.speed
	if(p.size >=p.maxsize)del(circles,p)
end

function drawcircle(p)
	circ(p.x,p.y,p.size,p.col)
	circ(p.x,p.y,p.size-1,p.col)
end

power_ups={}
function init_powerup(x,y,type)
	local p={
		x=x,
		y=y,
		size=5,
		type=type,
		spr=111+type,
		t=0,
		flip=false,
		flipped=false,
		transparent_c=5,
		delay=50
	}
	sfx(39)
	add(power_ups,p)
end

function update_powerup(p)
	if p.transparent_c <= 0 then
		if p.t < p.delay then
			p.t+=1
		else
			if p.delay == 50 then
				p.delay=5
			else
				p.delay=50
				p.flipped=not p.flipped
			end
			p.t=0
			p.flip=not p.flip
		end
	
		for pl in all(players) do 
			if not pl.respawn and a_circ_collision(p, pl) then
				pl.power_up = p.type
				shake+=0.08
				pl.power_up_time = power_up_times[p.type]
				pl.power_up_start_time = pl.power_up_time
				sfx(9)
				del(power_ups, p)
			end
		end
	else
		p.transparent_c-=1
	end
end

function draw_powerup(p)
	if p.flip then
		line(p.x,p.y-p.size,p.x,p.y+p.size,6)
		line(p.x, p.y+p.size,p.x,p.y+p.size+2,0)
	else
		circfill(p.x, p.y+p.size, p.size-1, 0)
		if p.transparent_c <= 0 then 
			circfill(p.x,p.y,p.size,2)
		end
		spr(p.spr,p.x-p.size+1,p.y-p.size+1,1,1,p.flipped)
		circ(p.x,p.y,p.size,6)
	end
end


-->8
--main

function start_match(with_ai)
	sfx(15)
	sfx(16)
	music(-1,200)
	game_state=1
	countdown = 60 * 4
	g_countdown=180
	is_draw = false
	ti=0

	for i=0,20 do
		initparticle(rnd(128),rnd(128), 0.01, 0.01,30+flr(rnd(20)), 1)
	end

	for k,v in pairs(players) do players[k]=nil end
	for k,v in pairs(stones) do stones[k]=nil end
	for k,v in pairs(grass) do grass[k]=nil end
	for k,v in pairs(power_ups) do power_ups[k]=nil end
	for k,v in pairs(clouds) do clouds[k]=nil end
	for k,v in pairs(bullets) do bullets[k]=nil end

	local stocks = m_set[1][2][c_set[1]]
	arenatime = m_set[2][2][c_set[2]] * 60
	halftime = arenatime / 2
	arenarad = 80

	is_half_time = m_set[3][2][c_set[3]]
	is_item_on = m_set[4][2][c_set[4]]
	local is_hats_on = m_set[5][2][c_set[5]]

	init_player(20, 64, 0,stocks,false,is_hats_on)
	init_player(110, 64, 1,stocks,with_ai,is_hats_on)

	init_stone(6,5,1)
	init_stone(-3,110,2)
	init_stone(116,-1,2)
	init_stone(109,82,2)
	init_stone(48,82,1)

	shake+=0.15
	--init_powerup(40,40,2) -- test

	arenaspr = 26 + 2 * flr(rnd(3))

	for i=0, 32 do
		local x=20+rnd(90)
		local y=20+rnd(80)
		if not circ_collision(x+4,y+4,arenax,arenay,6,arenainner) and
				circ_collision(x+4,y+4,arenax,arenay,1,arenarad) then
			init_grass(x,y)
		end
	end
end

hitstun = 0
function _init()
	cartdata("elastiskalinjen_fll")
	music_off=dget(0)
	if (music_off==0)music(7)
	menuitem(1,m_t..is_on(music_off), function() toggle_music() end)

	local bread = stat(6)
	if bread == "skip main" then
		main_menu_shown=true
		ma_x_b = 86
	end
end

music_off,m_t=0," music:"
function toggle_music()
	music_off= music_off == 1 and 0 or 1
	dset(0,music_off)
	if music_off == 1 then music(-1,200) else music(game_state == 0 and 0 or 7,200) end
	menuitem(1,m_t..is_on(music_off),function() toggle_music()  end)
end

function is_on(state) 
	return state==1 and "off" or "on"
end

function _update60()
	if game_state == 0 then 
		update_menu()
	elseif game_state >= 1 then
		spawn_waves()
		spawn_clouds()
		if hitstun == 0 then
			foreach(stones, update_stone)
			foreach(waves, update_wave)
			foreach(grass, update_grass)
			foreach(particles, updateparticle)
			foreach(circles, updatecircle)
			foreach(power_ups, update_powerup)
			foreach(clouds, update_cloud)
			updateplayers()
			updatebullets()

			if game_state == 1 then
				if countdown < 0 then
					update_arena()
					spawn_power_up()	
				else 
					countdown-=1
				end
			else
				update_game_over()
			end
		else
			hitstun -=1
		end
	end
end

function _draw()
	if game_state == 0 then 
		draw_menu()
	elseif game_state >= 1 then 
		cls(12)
		doshake()

		if arenatime <= halftime then
			spr(72,arenax-8, arenay + 24,2,2)
		end

		foreach(stones, draw_stone)
		foreach(waves, draw_wave)
		drawarena()
		foreach(grass, draw_grass)
		foreach(power_ups, draw_powerup)
		foreach(circles, drawcircle)
		foreach(bullets, draw_bullet)
		foreach(players, draw_player)
		foreach(particles, drawcircpart)

		foreach(clouds, draw_cloud)

		camera()
		if game_state == 3 then
			draw_game_over()
		end
		ui()
	end
end

-->8
--foliage

water_t=0
function spawn_waves()
	water_t = timer(water_t,40,spawn_wave)
end

function spawn_wave()
	local x=rnd(128)
	local y=rnd(128)
	if not circ_collision(x+4,y+4,arenax,arenay,1,arenarad) then
		init_wave(x,y)
	end
end

grass={}
function init_grass(x,y)
	local p={
		x=x,
		y=y,
		spr=48 + flr(rnd(2)) * 3,
		sspr=0,
		flip = flr(rnd(2)) == 0 and false or true,
		t=0
	}
	add(grass,p)
end

function update_grass(p)
	if p.move then
		if p.t < 10 then
			p.t+=1
		else
			p.t=0
			if p.sspr < 2 then
				p.sspr+=1
			else
				p.sspr=0
				p.move=false
			end
		end
	else
		for player in all(players) do
			if circ_collision(p.x+4,p.y+4,player.x,player.y,5,5) then
				p.move = true
			end
		end
	end
	
	if not circ_collision(p.x+4,p.y+4,arenax,arenay,1,arenarad-6) then
		del(grass, p)
	end
end

function draw_grass(p)
	spr(p.spr + p.sspr,p.x, p.y,1,1,p.flip)
end

waves={}
function init_wave(x,y)
	local w={
		x=x,
		y=y,
		back=false,
		t=0,
		spr=56
	}
	add(waves,w)
end

function update_wave(p)
	if p.t < 8 then
		p.t+=1
	else
		p.t=0
		if not p.back then 
			if p.spr < 59 then
				p.spr+=1
			else
				p.back=true
			end
		else
			if p.spr > 56 then
				p.spr-=1
			else
				del(waves,p)
			end
		end
	end
end

function draw_wave(p)
	spr(p.spr,p.x, p.y)
end

stones={}
function init_stone(x,y,size)
	local p={
		x=x + rnd(16) - rnd(16),
		y=y + rnd(16) - rnd(16),
		size=size,
		spr = size == 1 and 60 or 99,
		t=0
	}
	add(stones,p)
end

function update_stone(p)
	if p.t < 61 then
		p.t+=1
	else
		p.t=0
		if p.size == 2 then 
			if p.spr < 101 then
				p.spr+=2
			else
				p.spr=99
			end
		else
			if p.spr < 61 then
				p.spr+=1
			else
				p.spr=60
			end
		end
	end
end

function draw_stone(p)
	spr(p.spr,p.x,p.y,p.size,1)
end

clouds={}
function init_cloud(x,y)
	local nr_puffs = 8 + flr(rnd(5))
	local radius = 8 + flr(rnd(16))
	local height = 3 + flr(rnd(6))

 	local min_x = x - radius
 	local max_x = x + radius
 	local min_y = y - height
 	local max_y = y + height

	puffs={}
	for i=1, nr_puffs do
		puff={
			x=flr(min_x + rnd(max_x-min_x - 1)),
			y=flr(min_y + rnd(max_y-min_y - 1)),
			r=flr(3 + rnd(9))
		}
		add(puffs, puff)
	end
	local p={
		x=x,
		y=y,
		puffs=puffs,
		t=0,
		h=height,
		speed = nr_puffs * 0.025
	}
	add(clouds,p)
end

function update_cloud(c)
	c.t+=0.01
	c.x+=c.speed
	for p in all(c.puffs) do 
		p.x+=c.speed
		p.y+=sin(c.t) * (0.03 * (16 / p.r))
	end
	if (c.x > 164)del(clouds, c)
end

function draw_cloud(c)
	for p in all(c.puffs) do 
		circfill(p.x, p.y, p.r, 7)
	end
end

cloud_t,cloud_s=0,560+rnd(560)
function spawn_clouds()
	cloud_t = timer(cloud_t, cloud_s, spawn_cloud)
end

function spawn_cloud()
	cloud_s=720 + rnd(560)
	init_cloud(-40, 8+rnd(112))
end

-->8
--arena

arenax,arenay,arenarad,arenastart,arenainner,arenacolor,arenaspr=64,62,80,60,30,3,26+2*flr(rnd(3))
function update_arena()
	arenatime-=1
	if arenatime <= 0 then 
		game_over()
	end
	if arenarad > arenastart+1 then
		arenarad-=0.1
	end
	if is_half_time and arenatime <= halftime and arenarad > arenainner + 1 then
		arenarad-=0.05
	end
end

function drawarena()
	circfill(arenax,arenay,arenarad,arenacolor)
	circfill(arenax,arenay,arenainner,1)
	circ(arenax,arenay,arenarad,7)

	if arenarad > arenainner + 4 then
		for i=1,#wedge_arr do
			spr(wedge_arr[i][1],wedge_arr[i][2],wedge_arr[i][3])
		end
	end
	spr(arenaspr,arenax-8,arenay-8,2,2)
	for i=1,#sp_points do
		circ(sp_points[i][1],sp_points[i][2],4,13)
	end
end

set_p_delay=12*60
power_up_spawn_delay=set_p_delay + (flr(rnd(8)) * 60)
is_item_on=true
function spawn_power_up()
	if is_item_on then 
		if power_up_spawn_delay > 0 then
			power_up_spawn_delay -= 1
		else
			power_up_spawn_delay = set_p_delay + (flr(rnd(8)) * 60)
			local random = rnd(sp_points)
			initparticle(random[1],random[2],0,-1,3,7)
			init_powerup(random[1],random[2], 1+flr(rnd(6)))
		end
	end
end

wedge_arr={
	{55,73,35},
	{55,44,35},
	{54,72,85},
	{54,52,85}
}

sp_points={
	{arenax-16, arenay-16},
	{arenax+16, arenay-16},
	{arenax+16, arenay+16},
	{arenax-16, arenay+16}
}

-->8
--ui

function ui()
	draw_player_ui()
	draw_countdown()
end

function draw_player_ui()
	rectfill(0, 127, 64, 128,9)
	rectfill(64, 127, 128, 128,8)
	
	rectfill(0, 120, 40, 128,9)
	spr(7,40,120,2,1)

	rectfill(88,120,128,128,8)
	spr(9,88-16,120,2,1)

	for i=1, #players do
		local p = players[i]
		local percentage = abs(100 - (-flr(-(p.percentage * 100))))
		print(""..percentage  .. "%", 2 + (i-1) * 109, 121, 7)

		for y=1, p.stock do
			spr(4+i, (10 + (i-1) * 65) + y * 9, 120)
		end
		local x = (i-1) * 83
		line(x, 119, x + p.stamina, 119, p.col)
		if p.power_up_time > 0 then 
			line(x, 118, x + (43 * p.power_up_time / p.power_up_start_time), 118, 13)
			spr(247+p.power_up, x+1, 110)
		end
	end
	local c_spr=(game_state == 3 and g_countdown < 239) and 13 or 11
	spr(c_spr,56,118,2,1)
	local time = game_state == 3 and g_countdown or arenatime
	print(ceil(time/60),60,120,7)
end

function draw_countdown()
	if countdown > 0 then
		fillp(‡)
		circfill(arenax,arenay,24 + sin(t())*6,0)
		fillp()
		spr(70 - flr(countdown/60) * 2, 56,56, 2, 2)
		circ(arenax,arenay,24 + sin(t())*5,7)
	end
end

-->8
--help

shake=0
function doshake()
	local shakex=16-rnd(32)
 	local shakey=16-rnd(32)
 
	shakex*=shake
	shakey*=shake
	camera(shakex,shakey)
	shake=shake*0.95
	if(shake < 0.05)shake=0
end

function distance(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

function circ_collision(x1,y1,x2,y2,rad1,rad2)
	if(distance(x1,y1,x2,y2) < rad1+rad2) then return true else return false end
end

function a_circ_collision(a, b)
	if(distance(a.x,a.y,b.x,b.y) < a.size+b.size) then return true else return false end
end

function angle(x1,y1,x2,y2)
 	return atan2(x1-x2,y1-y2)
end

function lerp(var,target,pow)
	return var+pow*(target-var)
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

function timer(timer,threshold,fun)
	if timer < threshold then 
		timer+=1
	else 
		timer=0
		if (fun ~= nil)fun()
	end
	return timer
end

-->8
--menu

game_state=0
ti=0
td=0
r=5
s=8

sel_x = 40

ma_i=0
ma_x=2
ma_y=15
ma_l=0
ma_s_i=0
ma_s_x=3
ma_s_y=24

cur_i=0
cur_c=0

main_menu_shown=false
ma_x_b=0

function update_menu()
	ti+=0.015
	td+=r
	if ma_l == 0 then
		ma_i=move_cursor(ma_i, 3)
	else
		ma_s_i=move_cursor(ma_s_i,#c_set-1)
		move_setting_cursor()
	end

	ma_y=lerp(ma_y,15+ma_i*16,0.3)
	ma_s_y=lerp(ma_s_y,11+ma_s_i*10,0.35)
	sel_x=lerp(sel_x,40,0.09)
	
	if cur_c < 12 then
		cur_c+=1
	else
		cur_c=0
		cur_i = cur_i == 0 and 1 or 0
	end
	
	if ma_l < 2 then
		if btnp(4) then
			if(ma_l == 0)sfx(2)
			if not main_menu_shown then
				main_menu_shown = true
			elseif ma_x_b > 77 then
				if ma_l == 0 then 
					ma_l=1
				elseif ma_l == 1 and ma_i < 2 then
					ma_l=2
				end
			end
		elseif btnp(5) then
			if(ma_l > 0)sfx(3)
			ma_l=0
			ma_s_i=0
		end
	elseif ma_l == 2 then
		if game_state == 0 then
			start_match(ma_i == 0)
		end
	end
	
	if main_menu_shown then 
		ma_x_b=lerp(ma_x_b, 86, 0.055)
	end
end

function move_setting_cursor()
	if btnp(1) then
		sfx(0)
		if c_set[ma_s_i+1] < #m_set[ma_s_i+1][2] then
			c_set[ma_s_i+1]+=1				
		else 
			c_set[ma_s_i+1]=1
		end
	elseif btnp(0) then
		sfx(0)
		if c_set[ma_s_i+1] > 1 then
			c_set[ma_s_i+1]-=1				
		else 
			c_set[ma_s_i+1]=#m_set[ma_s_i+1][2]
		end
	end	
end

function move_cursor(cursx, maxn)
	if btnp(3) then
		sfx(1)
		if (ma_l == 0)sel_x=0
		cursx = timer(cursx, maxn, nil)
	elseif btnp(2) then
		sfx(1)
		if (ma_l == 0)sel_x=0
		if cursx > 0 then
			cursx-=1
		else
			cursx=maxn
		end
	end

	return cursx
end

function draw_menu()
 cls(1)
	
 for x=0,128,1 do
  fillp(„)
  rectfill(x,0,x,s*-sin((x+td)/2160),12)
		rectfill(x,128,x,80+s*-sin((x+td)/1080),3)
  rectfill(x,128,x,90+s*-sin((x+td/3)/720),11)
  fillp()              
	end
	
	if not main_menu_shown or ma_x_b < 75 then 
		draw_startscreen()
	else
		draw_main_memu()
		
		if ma_l == 1 then
			local endi = ma_i*16+95
			if endi > 119 then 
				endi = 119
			end
			rectfill(1,23+ma_i*16,126,endi,0)
		
			if ma_i < 2 then   
				draw_match_settings()
			elseif ma_i == 2 then 
				draw_controls()
			else 
				draw_about()
			end
		end
	end
	
	draw_help()
end

function draw_startscreen()
	zspr(210,4,1,8+cos(ti)*4-ma_x_b,16,2)
	zspr(226,3,1,8-cos(ti)*3-ma_x_b,32,2)
	zspr(242,3,1,8+cos(ti)*4-ma_x_b,48,2)
	
	zspr(208,2,3,80+ma_x_b,16+sin(ti)*2,2)
	
	if flr(ti) % 2 == 0 and ma_x_b == 0 then
		print("press start Ž", 34,80,7)
	end
end

function draw_main_memu()
	for i=1, #menu_items do 
		local bonus = ma_i+1 == i and 2 or 0
		if bonus == 2 then
			rectfill(0,i*16-1,87+sel_x,i*16+5,12)
			if sel_x > 24 then 
				spr(192+cur_i,64+sel_x,i*16-3)
				spr(194+ma_i*2+cur_i,76+sel_x,i*16-3)
			end 
		end
		if ma_l == 0 or bonus == 2 then
			local c= (bonus == 2) and 1 or 7
			print(menu_items[i],12+bonus,i*16,c)
		end
	end
	
	if (ma_l == 0)spr(202+cur_i,ma_x,ma_y)
end

function draw_help()
	rectfill(0,121,128,128,0)
	local text = main_menu_shown and "Ž confirm — back" or by
	print(text,2,122,7)
end

function draw_match_settings()
	for i=1,#m_set do 
		local bonus = ma_s_i+1 == i and 2 or 0
		spr(217+i,10+bonus,ma_y+2+i*10)
		print(m_set[i][1],24+bonus, ma_y+4+i*10,7)
		
		local setting=m_set[i][2][c_set[i]]
		if setting == false then 
			setting = "off"
		elseif setting == true then 
			setting = "on"
		end
		print("<       >", 80, ma_y+4+i*10,7)
		local b= bonus == 2 and cur_i or 0
		print(setting,93, ma_y+4+i*10-b,12)
	end
	print(m_set[ma_s_i+1][3],4,ma_i*16+80,12)
	spr(204+cur_i,ma_s_x,ma_y+ma_s_y)
end

function draw_controls()
	for i=1, #controls do
		spr(235+i,4,40+i*18)
		print(controls[i][1],16,41+i*18,7)
		print(controls[i][2],4,48+i*18,12)
	end
end

by="sebastian lind @elastiskalinjen"
function draw_about()
	spr(206,2,73)
	print("this game was made by",12,75,7)
	print(by,2,83,12)
	
	spr(207,2,95)
	print("goal of the game",12,96,7)
	print("try to knock your opponent\noutside of the arena!",2,105,12)
end

menu_items={
	"player vs cpu",
	"player vs player",
	"controls",
	"about",
}

c_set={
	3,
	3,
	1,
	1,
	1,
}

m_set={
	{
	"stock",
	{1,2,3},
	"set the number of stock."
	},
	{
	"time limit",
	{20,40,60,80,99},
	"set the length of each match."
	},
	{
	"half time",
	{true,false},
	"set if you want the arena to\nshrink after half time."
	},
	{
	"items",
	{true,false},
	"set if you want to play with\nitems."
	},
	{
	"hats",
	{true,false},
	"set if you want to play with\nhats."
	}
}

controls={
	{"move", "‹”‘ƒ"},
	{"fast attack", "press Ž"},
	{"stretch attack", "hold —, move then release —"}
}
-->8
--game over 

is_draw=false 
function game_over()
	game_state = 3
	ti=0
	for i = 0, 20 do
		initparticle(arenax,arenay, 0.05*i, 4, 4+flr(rnd(2)), 7)
	end
	initcircle(arenax, arenay, 4, 120, 7)
	shake+=0.1

	local p1_stocks = players[1].stock
	local p2_stocks = players[2].stock
	local p1_won = false
	local p2_won = false

	if p1_stocks > p2_stocks then 
		p1_won = true
	elseif p1_stocks < p2_stocks then 
		p2_won = true
	elseif p1_stocks == p2_stocks then
		local p1_percentage = players[1].percentage
		local p2_percentage = players[2].percentage

		if p1_percentage < p2_percentage then
			p1_won = true
		elseif p1_percentage > p2_percentage then
			p2_won = true
		end
	end
	
	if not p1_won and not p2_won then 
		is_draw = true
		music(9)
	else
		music(10)
	end
	players[1].won = p1_won
	players[2].won = p2_won
end

g_countdown=240
function update_game_over()
	ti+=0.015
	if arenarad < 80 then 
		arenarad+=0.2
	end
	for p in all(players) do
		if btnp(4, p.player) then
			sfx(18)
			p.confirm = 1
			if players[2].is_ai then 
				players[2].confirm = 1
			end
		elseif btnp(5, p.player) then
			sfx(19)
			p.confirm = 2
			if players[2].is_ai then
				players[2].confirm = 2
			end
		end
	end
	local p1confirm = players[1].confirm
	local p2confirm = players[2].confirm
	if p1confirm > 0 and p1confirm == p2confirm then 
		g_countdown-=1
	else
		g_countdown=240
	end
	if g_countdown <= 0 then
		if p1confirm == 1 and p2confirm == 1 then
			start_match(ma_i == 0)
		elseif p1confirm == 2 and p2confirm == 2 then
			run("skip main")
		end
	end
end

function draw_game_over()
	local b = sin(ti)*2
	if (is_draw)zspr(232,4,1,24,52+b,3)
	rectfill(0,102,128,128,0)
	for p in all(players) do
		if not is_draw then
			zspr(214,3,1, 15 + p.player * 64,32-b,2)
			local text_id = p.won and 229 or 245
			zspr(text_id,3,1,13+p.player*64,64+b,2)
		end
		spr(1+p.player, 28+p.player*64, 24-b)
		if not p.is_ai then
			print("Ž rematch",1+p.player*83,104,p.confirm == 1 and 7 or 1)
			print("\n— menu",1+p.player*83,104,p.confirm == 2 and 7 or 1)
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000999990000000000000000000000888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000aa00aa002200220999999000000000000000000008888880111111111111110022222222222222000000000
0070070000000000000000000000000000000000a00aa00a20022002999999909000000000000008088888881111111111111111222222222222222200000000
0007700009999990088888800000000000000000a000000a20000002999999999900000000000088888888881111111111111111222222222222222200000000
00077000999999998878878800000000000000000a0000a002000020999999999990090000800888888888881111111111111111222222222222222200000000
007007009979979988788788000000000000000000a00a0000200200999999999999990000888888888888881111111111111111222222222222222200000000
0000000099999999888888880000000000000000000aa00000022000999999999999999008888888888888881111111111111111222222222222222200000000
00000000999119998881188800000000000000000000000000000000999999999999999988888888888888880111111111111110022222222222222000000000
09999990009999000999999009999990099999900999999009999990099999900099990000000009000dddddddddd00000000dddddd000000000000dd0000000
9999999909999990900000097799779977997799979979999999999999999999099999900999999900d0000000000d000000d000000d0000000dd00dd00dd000
979979999999999990000009779977999999999999999999979979999999999999999999977977990d000000000000d0000d00dddd00d00000d00d0000d00d00
999999999799799990700709999999999111199991111999999999999799799999999999999999990d000000000000d000d0000dd0000d000d0000d00d0dd0d0
991199999999999990000009911119999222299999229999911119999c99c9999799799991199999d00000000000000d0d000d0000d000d00d0000d00d0dd0d0
99229999992299999002200992222999999999999999999992222999991199997799779999999999d00000000000000dd000d00dd00d000d00d00d0000d00d00
99999999099999900900009099999999099999909999999999999999992299990c229c9009999999d00000000000000dd0d000d00d000d0d000dd00dd00dd000
09999990009999000099990009999990009999000999999009999990099999900099990000000009d00000000000000dd0dd0d0000d0dd0ddd0000d00d0000dd
08888880000880000008800008888880888888880788788008888880088888800008800000000008d00000000000000dd0dd0d0000d0dd0ddd0000d00d0000dd
87887888088888800880088077887788778877888788788887887888888888880888888008888888d00000000000000dd0d000d00d000d0d000dd00dd00dd000
878878888788788887007008778877888888888888888888878878888788788888888888878788880dd0000000000dd0d000d00dd00d000d00d00d0000d00d00
8888888887887888870070088888888888118888811118888888888887887888888888888787888800d0000000000d000d000d0000d000d00d0dd0d00d0000d0
881188888888888880000008811118888822888888228888811118888d88d888778877888111888800d0000000000d0000d0000dd0000d000d0dd0d00d0000d0
88228888888888888011000882222888888888888888888882222888881188888d888d888222888800d0000000000d00000d00dddd00d00000d00d0000d00d00
88888888882288888022000888888888088888808888888888888888882288888d228d8808888888000d00000000d0000000d000000d0000000dd00dd00dd000
888888888888888808888880888888880088880088888888888888888888888888888888000000080000dddddddd000000000dddddd000000000000dd0000000
00000000000000000000000000000000000000000000000000000000000333330000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000303000000000000000000000000000077000000d5500000d55000000000000000000
00000000000000000000000000000000000000000000000000000000000000300000000000000000000000000070070000555560005555600000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000077770007000070005566d0005566d00000000000000000
00b000000000000000000b0000000000000000000000000000000000000000000077770007777770070000707000000700556dd000556dd00000000000000000
b0bb0b000b0b0b0000b0bb0b0b00000000b000000000000b0303030000000000000000000000000070000007000000000555d5d07555d5d70000000000000000
bbbbbbb00bbbbbb00bbbbbbb0bb0bb000bbb0bb000bb0bbb03333330000000000000000000000000000000000000000075555dd7077777700000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333000000000000000000000000000000000000000007777770000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444444444444444444444444444400000000000000000000000000000000
00007777777770000000777777777000000077777700000077777770077777774444444444444444444444444444444400000000000000000000000000000000
00007777777770000000777777777000000077777700000077777770077777774444444444444444444444444444444400000000000000000000000000000000
00000000000770000000770000777000000077077700000077000770077000774444444444444444444444444444444400000000000000000000000000000000
00000000000770000000777000777000000000077700000077000770077000774444444444444444444444444444444400000000000000000000000000000000
00000000000770000000777007770000000000077700000077000000077000774444444444444444444444444444444400000000000000000000000000000000
00007777777770000000000077700000000000077700000077000000077000774444444444444444444444444444444400000000000000000000000000000000
00007777777770000000007777000000000000077700000077077770077000770444444444444440044444444444444000000000000000000000000000000000
00000000000770000000077770000000000000077700000077077770077000770044444444444400007444444444470000000000000000000000000000000000
00000000000770000000077000000000000000077700000077000770077000770074444444444700000777777777700000000000000000000000000000000000
00000000000770000000777000077000000000077700000077000770077000770007777777777000000000000000000000000000000000000000000000000000
00007777777770000000777777777000000007777777000077777770077777770000000000000000000000000000000000000000000000000000000000000000
00007777777770000000777777777000000007777777000077777770077777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006dd00000000000006dd000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000066dddddd6500000066dddddd65000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000066d5d55dd665500066d5d55dd665500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066dd55555d65550066dd55555d65550000000000000b000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ddd55555555d5550ddd55555555d5550000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000dd555555666dd5507d555555666dd557000000000b00b00000000000000000000000000000000000000000000000000000000000
000000000000000000000000766565566ddd55570777777777777770000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007700000700000777000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077700007770000077770007000070007707700000007007077070000000000000000000000000000000000000000000000000000000000000000000000000
00777000007770000000770007070770077070700077777000777700000000000000000000000000000000000000000000000000000000000000000000000000
07770700077777000077700007007070070070000770777007077070000000000000000000000000000000000000000000000000000000000000000000000000
07777000077077700777000007000070077077000777777007777770000000000000000000000000000000000000000000000000000000000000000000000000
00777700070000700077700000700700070070000077777000700700000000000000000000000000000000000000000000000000000000000000000000000000
00007700000000000000770000077000070070000000007007077070000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000077770000060000000555000007700000000000000000000220000000000000000000000000000000bb000000000000047777000888822
00dddd000000000000777707000770000005550507606060000000000000000002e2e00000000000000000000eeeee2000b8af00000000000047677700788886
0dddddd004000040007777000007600000555100606000600000000000000000e222ee0000bbbb0000000000aaeeeaa00b88acf000fffd000047766700777762
0dddddd044000044077777700076700000755000600000600a0909000fffd000ee2222000bbbbbb000000000a2a2a2a0b88acce90fffffd00027776007888820
02ddd22044000044077777700067700006765100600000600aaaa990fffffd00000d00000b77bbb00000000099929990b8acce9ff8fffd8f0040007708777660
0d222ddd4200002406aa77600077670005655510060006600a88aa90f11ffd00000f000003737bbb00d6d0000112111000070000ff8888ff0020000008888220
ddddddd042000024779966770066760055555551060006000a22aaa0fffff22200000000303333b00655562002222220000700000ffffff00000000078888226
00dddd000000000007777770000000000000000000000000000000000000000000000000000000002d656d222222222200000000000000000000000007776660
00000000fff0fff00000e820a800800077000770000088807820782019999000000bb00000000aaa000000000008888000000000000000000717700000000000
0000000017701770000888828308a8088200082000088207882088209999794000bbbb00000aaaaa000000000007778800000000007777009977700000000000
000800000d000d000008888200308303820008200088200088208820919999000bbbbbb00aaaaa9900e220000077777007000070077777600006000000000000
0097f0000f000f000000882003b00b30820008200888200006000600099a9a400bbbbbb0aaaa00990e7662000017717077700777077a77600007000000000000
0a777e000f000f00000072004ff4f42288888820088882000700070000a9a90000022000a2992299e7d11620006996707e7007e707aa97600077670000000000
00b7d0000f000f000007000004444220088882000676767007000700009a99400004400009999900e7dd1620007777707e7777e7726967260777776000000000
000c000000000000000000000444422000888000000000000000000000a9a90000000000000000000ee222000000000077700777772122660777767700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000990000022220000022000000ff0000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000
099aa990009999000228822000222200000af000000990000008a000000220000000000000000000000000000000000000000000000000000000000000000000
09aaaa90099aa9900288882002288220000aa000000a9000000aa0000002a0000000000000000000000000000000000000000000000000000000000000000000
09aaaa90099aa990028888200228822000aaaa0000aaaa0000aaaa0000aaaa000000000000000000000000000000000000000000000000000000000000000000
099aa99000999900022882200022220000aafaa00aaafaa00aafaa000aafaaa00000000000000000000000000000000000000000000000000000000000000000
009999000009900000222200000220000aaf0fa0aaaf0faa0af0faa0aaf0faaa0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000aff000faaf00000aaf000ffaa00000fa0000000000000000000000000000000000000000000000000000000000000000
0000060005dd00600077777000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05ddddd0005ddd000777777700000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555dd00005ddd00700777700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000605d0000065d00000077700077777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006420000004200000007700077707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000420000042000000000700077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000420000020000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000070000000000000000000000000000000000777770000777000770000000000000000000000000000000077770000777070
00777700000000000700007076700767000000000777777000000000077777707666667007666700777700000000000000000000000000000700007007000077
079999700077770076700767076776700777777078888887077777707d1dddd77677767007767700777770007777700000000000000000007000070770070700
7999999707999970076776707dddddd778888887787887877d6dd8877116d8870707667000767000777777707777777000000000000000007070000770707007
79799797799999977dddddd77d7dd7d778788787787887877111d2277d1dddd70076670000767000777777707777777077700000000000007000070770700707
79999997797997977d7dd7d77dddddd778788787788888877d1dbbd77dddbbd70077700000767000777770007777700077777000777770007007700770077007
79911997799999977dddddd77dd11dd778888887788118877ddd33d7077777700076700000767000777700000000000077777000777770000700007007000070
79922997799229977dd22dd77dd22dd7788228877882288707777770000000000077700000070000770000000000000077700000000000000077770000777700
00000000000000008888808088880080008088888080008070007077777070077000000000000000000000000000000000000000000000000000000000000000
00000000000000008000808080008080008080808008080007070070007070007000000000000000000000000077770007777770007777000077770000000000
00000000000000008000008080000080008080808008080007070070007070007000000000000000077007700700707000700700070000700777777000000000
00000000070887008888008080880088888000800000800000700070007070007000000000000000700770077000700700077000777777770777777000000000
00000000700882008000008080808080008000800000800000700070007070007000000000000000700000077007000700700700070707070770777000000000
00000070007788008000008080008080008000800000800000700070007070007000000000000000070000707070000707000070707070700700077700000000
000000bbbb0070008000008008880080008000800000800000700077777077777000000000000000007007000700007007777770070707077770777000000000
00b0bb333bbb70000000000000000000000000000000000000000000000000000000000000000000000770000077770007777770777777770777770000000000
0bbb33333333b0007000077777070007077770007007007070700077000070007770007777000777007007007000000000000000000000000077007000000000
00bb331111333b007000070007077007070007007007007070770007000070007007007000707000707007007000000000000000000000700000000000000000
0bb3313333133bb07000070007077707070000007007007070707007000070007000707000707000707007007000000077700070077770077700777700000000
0b33133dd3313b007000070007070707070770007007007070707007000070007000707777007777707007007000000007007777070700700007707000000000
bb3313dddd313b007000070007070077070707007007007070700707000070007000707070007000707007007000000077700070077770070070777700000000
0b3313dddd313bb07007070007070077070007007007007070700707000070000007007007007000707007007000000070700000707000700707000000000000
0b33133dd3313b007777077777070007007770007770777070770777000000007770007000707000707770777000000070700000707000007070077000000000
0b33313333133b000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000
00b333111133bbb09000099999099990099999007000077777077777077777000000000000000000000000000000000000000000000000000000000000000000
0b7b33333333b0009000090000090009090009007000070007070007070000000000000000000000000000000000000000000000000000000000000000000000
0070bbb3333bb0009000090000090000090000007000070007070000070000000111110001111100000000000000000000000000011111000000000000000000
09977bbbbbbb0b009000009999090990009990007000070007007770007777001100011011000110000000000000000000000000110101100000000000000000
02990b07bb0b00009000090000090909000009007000070007000007070000001101011011010110000000000000000000000000111011100000000000000000
079907000b0000009009090000090009090009007000070007070007070000001100011011000110000000000000000000000000110101100000000000000000
00000007000000009999099999009990099999007777077777077777077777000111110001111100000000000000000000000000011111000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080808080000000000000000000000000000000000000000000000000000000000000000000000000808080800000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000230101e0101e0100401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000080400f040170401804000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000180451d0452a0452c0452d0051e0051d0051b0051b0051b0051a0051a00519005190051900519005190051800517005170051d0051f0052200523005260052600510005100051000510005100050f005
00050000290451f04517045170452d0051e0051d0051b0051b0051b0051a0051a00519005190051900519005190051800517005170051d0051f0052200523005260052600510005100051000510005100050f005
000f00000e7530e753050050e753050050e7530e753050050e743030050e7430e743050050e743050050e7430e743050050e743050050e7430e743050050e743030050e743057430500505743050050374503705
000f000002000110000900003000010000100003000020000206011000090000307001000020600300003070000000f0001100004000000000500011000050000507011000050700700013000070700000000000
000f00100203300003020330000300033010030000300003010330000300003030330000302033000030103300003000030000301003000030000301003020030000302003000030000300003010030000300003
000f000002000110000900003000010000100003000020000204011000090000305001000020400300003050000000f0001100004000000000500011000050000504011000050400700013000070400000000000
000f00000552308503050050e703050050e7030e703050050e703030050e7030e703050050e703050050e7030e703050050e703050050e7030e703050050e703030050e7030e703050050e703050050500505005
0005000008054080541205401074010740c0540d054140542005429774297042b704350043700413004210041a0041f0042100405004050040e0041300415004260042b0042d00407004070041d0041f00421004
000f00100201300003020130000300013010030000300003010130000300003030130000302013000030101300003000030000301003000030000301003020030000302003000030000300003010030000300003
000f00000000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030303311003030331d7321f7031d033000031d033
0004000002a3203a4219a0227a021da0216a0216a0216a0210a0211a0211a021ba021da0216a0216a0216a021da0216a0216a0216a0218a0216a0218a0216a0229a0216a0229a0216a0229a0216a0229a0211a02
000f000016e3516e3519e5527e651de4516e3516e3516e3510e3511e3511e551be551de4516e3516e3516e351de4116e3116e3116e3118e0516e3118e0516e3129e0516e3129e0516e3129e0516e3129e0511e31
000f00000f0550f0550f0550a0450a0450a0450f0450f0350f0451104511045110451604516045160450f0450f0450f0451604516045160450c0450c0450c0451304513045130450f0450f0450f0451804518045
000600000603003051030310003100e01000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
001400001304013040007000070000700130001304013040007000070000700020001304013040000000070000000000001805018050000000000000000000000000000000000000000000000000000000000000
000f000000032150421f0421b0421604216042160421604218042180421d042110420f0420c0420c0420c0420f042130420904203042070420700200072040020400204002030020200205002030020000200002
001000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000502000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001455314503255033450317503195031a50326503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
000600000603314503255033450317503195031a50326503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
000700001456311573255033450317503195031a50326503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
000700002973114563115731150317503195031a50326503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
000600001d06319003255033450317503195031a50326503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
000700000307714563115731150017503195031a50326503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
001000000063500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000000453300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
000300000053400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
00050000170670b057040470f9570c95708a4720a571da5715a470fa570ea570ba570ba570ba5708a5708a4706a4705a4705a4704a4702a4701a370cc0700c070ac0700c0700c0708c0700907009070090700907
000a00000074010700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000a00000374010700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000a00000774010700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000a00000c7400c700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000a0000137400c700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000a0000187400c700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000f00000003116751007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000600001275106031250013400117001190011a00126001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000f000012040070501b76022770277702e75033740377303f730110002b7400b0003770000000060000400003000000000200002000000000000000000000000000000000000000000000000000000000000000
000800000413403034060340050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
0002000015050030500572006720097200c72010720147201c72008020080501b1001d1001610016100161001d100161001610016100181001610018100161002910016100291001610029100161002910011100
0003000006526085360b5460f546155461a5460102601026005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506005060050600506
000300000007000070000501d03012030120300a01008010070100a02009020060200a02003010030100101000010000100001000500005000050000500005000050000500005000050000500005000050000500
00090000077100f720010100351000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000600000553008530075000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
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
00 07 42 43 44
00 41 05 43 44
00 41 06 43 05
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
01 41 06 43 44
02 41 06 07 44
07 11 42 06 44
07 04 42 06 0b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
