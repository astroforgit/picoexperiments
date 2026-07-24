pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--          fire & blade          
--        a game by maximus       

cartdata("codename_sword_by_maximus_b2_ajs")
version = "beta 3"

spd = 1 -- 1 for 60 fps
				-- 2 for 30
debug_mode = false
god_mode = false

state_splash = 0
state_menu = 1
state_game = 2
state_over = 3
state_cart = 4
state = state_splash

save_score = 0
save_score_chain = 1
save_score_multi = 2
save_score_old = 7
save_chain = 8
save_multi = 9


--============================--
-- 8 directions
	direc = {}
	direc.u = atan2(0, -1)
	direc.d = atan2(0, 1)
	direc.l = atan2(-1, 0)
	direc.r = atan2(1, 0)
	direc.ul = atan2(-1, -1)
	direc.ur = atan2(1, -1)
	direc.dl = atan2(-1, 1)
	direc.dr = atan2(1, 1)


--============================--
-- sound bank

	sound = {}
	sound.player_hit = 11
	sound.player_attack = 3
	sound.player_dash = 2
	sound.enemy_die = 0
	sound.point_get = 6
	sound.point_lose = 7
	sound.point_spawn = 9
	sound.bonus_life = 12

	sound.godmode_on = 13
	sound.godmode_off = 14

	sound.tv_in = 16
	sound.tv_out = 15

	sound.music = {}
	sound.music.hopeful_resistance = 0


--============================--
-- mode change

	function godmode()
		god_mode = not god_mode
		if god_mode then sfx(sound.godmode_on)
		else             sfx(sound.godmode_off) end
	end


--============================--
-- generic functions
	
	generic = {}

	-- wait
		-- warning! only one wait can be active at any given time!
		generic.wait_time = 0
		generic.wait_function = nil
		generic.wait_arg = nil

		function generic:wait_func(t, f)
			self.wait_time = t
			self.wait_function = f
		end

		function generic:wait_update()
			if self.wait_function then
				if self.wait_time > 0 then
					self.wait_time -= spd
				else
					self.wait_function()
					self.wait_function = nil
				end
			end
		end


--============================--
-- player

	-- player setup
		player = {}
		player.x = 0
		player.y = 0
		player.vxs = 0
		player.vys = 0

		player.max_speed = 1.25
		player.accel = 0.25
		player.deccel = 0.96 -- percentage based
		player.friction = 0.88 -- deccel when over max_speed

		player.input = {}
		player.input.attack = 4  -- z
		player.input.direction = 0 -- from 0 to 1: 0.25 up 0.5 left
		player.input.is_move = false
		player.input.dash = 5 -- x

		player.radius = 2.5
		player.collision_force = 3

		player.alive = true
		player.health = 5
		player.health_bonus_score_interval = 2000
		player.health_bonus_score = player.health_bonus_score_interval

		player.score = 0
		player.drawn_score = 0
		player.multi_hits = 0
		player.best_multi_hits = 0
		player.chain = 0
		player.best_chain = 0
		player.should_multi_hits_update = false

		player.fuel = {}
		player.fuel.amount = 1
		player.fuel.regen = 1/10

		player.attack = {}
		player.attack.direction = 0
		player.attack.is_attacking = false
		player.attack.fuel_spend = 1/2.5

		player.dash = {}
		player.dash.force = 5
		player.dash.is_dashing = false
		player.dash.fuel_spend = 1/1

		player.sprite = 0
		player.sprite_empty = 1
		player.sprite_damage = 2
		player.flash = 0
		player.flash_period = 10
		player.dir_sprite_start = 4
		player.dir_sprite_number = 8

		player.particle_speed_offset = 0.25 -- speed > max_speed + this
		player.particle_delay_max = 2
		player.particle_delay = player.particle_delay_max
		player.particle_lifetime = 30


		function player:reset()
			player.x = 0
			player.y = 0
			player.vxs = 0
			player.vys = 0
			player.input.direction = 0
			player.input.is_move = false
			player.alive = true
			if not god_mode then player.health = 5
			else player.health = 1000 end
			player.health_bonus_score_interval = 2000
			player.health_bonus_score = player.health_bonus_score_interval
			player.score = 0
			player.drawn_score = 0
			player.multi_hits = 0
			player.best_multi_hits = 0
			player.chain = 0
			player.best_chain = 0
			player.should_multi_hits_update = false
			player.fuel.amount = 1
			player.attack.is_attacking = false
			player.dash.is_dashing = false
			player.flash = 0
			player.particle_delay = player.particle_delay_max
		end


	-- update
		function player:update()
			player.input:control()
			player:move()
			player.fuel:update()
		end


	-- bonus life check
		function player:bonus_life_check()
			--[[
			if player.score >= player.health_bonus_score then
				player.health_bonus_score += player.health_bonus_score_interval
				player.health += 1
				sfx(sound.bonus_life)
			end
			--]]
		end


	-- input
		function player.input:control()
			player.input.is_move = true

			-- up + left
			if btn(2) and btn(0) then
				player.input.direction = direc.ul
			-- up + right
			elseif btn(2) and btn(1) then
				player.input.direction = direc.ur
			-- down + left
			elseif btn(3) and btn(0) then
				player.input.direction = direc.dl
			-- down + right
			elseif btn(3) and btn(1) then
				player.input.direction = direc.dr
			-- left
			elseif btn(0) and not btn(1) then
				player.input.direction = direc.l
			-- right
			elseif btn(1) and not btn(0) then
				player.input.direction = direc.r
			-- up
			elseif btn(2) and not btn(3) then
				player.input.direction = direc.u
			-- down
			elseif btn(3) and not btn(2) then
				player.input.direction = direc.d
			-- no key pressed
			else
				player.input.is_move = false
			end

			-- actions
			if btn(player.input.attack) then
				player:dofire()
			end

			if btn(player.input.dash) then
				player:dodash()
			end
		end
	

	-- move
		function player:move()
			local speed = sqrt(player.vxs ^ 2 + player.vys ^ 2)
			-- hori and vert speed
			if player.input.is_move and speed < player.max_speed then
				player.vxs += cos(player.input.direction) * player.accel
				player.vys += sin(player.input.direction) * player.accel
			end

			-- decceleration
			local speed = sqrt(player.vxs ^ 2 + player.vys ^ 2)
			local direction = atan2(player.vxs, player.vys)
			player.vxs = cos(direction) * speed * player.deccel
			player.vys = sin(direction) * speed * player.deccel

			-- clamp max speed
			if speed > player.max_speed then
				player.vxs = cos(direction) * speed * player.friction
				player.vys = sin(direction) * speed * player.friction
			end

			-- particles
			if speed > player.max_speed + player.particle_speed_offset then
				player.particle_delay -= spd
				if player.particle_delay < 0 then
					particle:create(player.x, player.y, particle.generic, player.particle_lifetime)
					player.particle_delay = player.particle_delay_max
				end
			end

			-- finalize
			player.x += player.vxs * spd
			player.y += player.vys * spd
		end


	-- physics
		function player:collision(e)
			if player.alive and e.alive then
				sfx(sound.player_hit)

				local x = e.x - player.x
				local y = e.y - player.y
				local d = atan2(x, y)+0.5
				player:push(d, player.collision_force)
				enemy:kill(e)
				player:damage(e.damage)
				enemy:create_outside(rnd(1))
			end
		end


		function player:push(direction, force)
			player.vxs += cos(direction) * force
			player.vys += sin(direction) * force
		end


	-- actions
		function player:dofire()
			if player.fuel.amount == 1 then
				player.attack.direction = player.input.direction
				sfx(sound.player_attack)
				player.attack.is_attacking = true
			end
		end


		function player:dodash()
			if player.fuel.amount == 1 then
				sfx(sound.player_dash)
				player.dash.is_dashing = true
				player:push(player.input.direction, player.dash.force)
			end
		end


	-- fuel
		function player.fuel:update()
			-- attack
			if player.attack.is_attacking then
				player.should_multi_hits_update = true
				player.fuel.amount -= player.attack.fuel_spend * spd/2
				attack:create()
				if player.fuel.amount < 0 then
					player.attack.is_attacking = false
					player.fuel.amount = 0
				end
			-- dash
			elseif player.dash.is_dashing then
				player.fuel.amount -= player.dash.fuel_spend * spd/2
				if player.fuel.amount < 0 then
					player.dash.is_dashing = false
					player.fuel.amount = 0
				end
			-- regen
			else
				player.fuel.amount += player.fuel.regen * spd/2
				if player.fuel.amount > 1 then
					player.fuel.is_regening = false
					player.fuel.amount = 1
					if player.should_multi_hits_update then
						player.should_multi_hits_update = false
						high.update_bonus()
					end
				end
			end
		end


	-- damage
		function player:damage(amount)
			player.chain = 0
			if player.flash == 0 then
				player.flash = player.flash_period
				player.health -= 1
				if player.health <= 0 then
					if (not debug_mode) player:die()
				end
			end
		end


		function player:die()
			high:update_highscore(player.score)

			player.alive = false
			player.vxs = 0
			player.vys = 0
			menuitem(1)
			over:reset()
			--transition:to(state_over)
		end


	-- visual
		function player:draw_object()
			-- player
			local s

			if player.flash > 0 then
				s = player.sprite_damage
				player.flash -= spd/2
			else
				player.flash = 0
				if player.fuel.amount < 1 then
					s = player.sprite_empty
				else
					s = player.sprite
				end
			end

			if player.alive then
				local d = player.input.direction -- direction of input
				local index = ((d + 0.0625)%1)*player.dir_sprite_number
				local off = 2

				-- flamethrower head
				local off_x = 0
				local off_y = 0
				if (player.input.direction == direc.l) then off_x = -off
				elseif (player.input.direction == direc.r) then off_x = off
				elseif (player.input.direction == direc.u) then off_y = -off
				elseif (player.input.direction == direc.d) then off_y = off
				elseif (player.input.direction == direc.ul) then
					off_x = -off
					off_y = -off
				elseif (player.input.direction == direc.ur) then
					off_x = off
					off_y = -off
				elseif (player.input.direction == direc.dl) then
					off_x = -off
					off_y = off
				elseif (player.input.direction == direc.dr) then
					off_x = off
					off_y = off
				end

				spr(player.dir_sprite_start+flr(index), draw.offset.x-4+off_x, draw.offset.y-4+off_y)

				spr(s, draw.offset.x-4, draw.offset.y-4)
			end
		end


--============================--
-- attack projectile

	-- attack setup
		attack = {}
		attack.sprite_l = 39
		attack.sprite_u = 55
		attack.sprite_ul = 23
		attack.sprite_number = 5-1 -- -1 is apparently needed

		attack.spread = 16 -- 1 is full circle, 2 half, 4 a quarter, etc.
		attack.radius = 4
		attack.base_speed = 1
		attack.create_distance = 4
		attack.lifetime = 12

		attack.id_count = 0
		attack.projectiles = {}

		function attack:reset()
			attack.id_count = 0
			attack.projectiles = {}
		end


	-- create
		function attack:create()
			local player_speed = sqrt(abs(player.vxs^2) + abs(player.vys^2))
			if player_speed < player.max_speed+0.25 then
				-- the +0.25 is for error on the max speed (it fluctuates a lot)

				local a = {}
				a.id = attack.id_count
				attack.id_count += 1

				local d = player.attack.direction
				local d_rand = d + (rnd(1)-0.5)/attack.spread
				a.x = player.x + cos(d) * attack.create_distance
				a.y = player.y + sin(d) * attack.create_distance
				a.vxs = player.vxs + cos(d_rand) * attack.base_speed
				a.vys = player.vys + sin(d_rand) * attack.base_speed
				a.lifetime = attack.lifetime
				a.radius = attack.radius

				a.sprite_flip_x = false
				a.sprite_flip_y = false
				if d == direc.l then
					a.sprite = attack.sprite_l
				elseif d == direc.ul then
					a.sprite = attack.sprite_ul
				elseif d == direc.u then
					a.sprite = attack.sprite_u
				elseif d == direc.ur then
					a.sprite = attack.sprite_ul
					a.sprite_flip_x = true
				elseif d == direc.r then
					a.sprite = attack.sprite_l
					a.sprite_flip_x = true
				elseif d == direc.dr then
					a.sprite = attack.sprite_ul
					a.sprite_flip_x = true
					a.sprite_flip_y = true
				elseif d == direc.d then
					a.sprite = attack.sprite_u
					a.sprite_flip_y = true
				elseif d == direc.dl then
					a.sprite = attack.sprite_ul
					a.sprite_flip_y = true
				end

				add(attack.projectiles, a)
			end
		end


	-- move / physics
		function attack:move_all()
			for k,a in pairs(attack.projectiles) do
				a.lifetime -= spd
				if a.lifetime <= 0 then
					del(attack.projectiles, a)
				else
					a.x += a.vxs * spd
					a.y += a.vys * spd
				end
			end
		end


		function attack:collision(me, other)
			if other.points > 0 then
				sfx(sound.enemy_die)

				if player.alive then
					player.multi_hits += 1

					local points = (other.points + player.chain) * player.multi_hits
					player.score += points
					ptext:create(other.x, other.y, points)
					other.points = 0 -- needed so as not to count points multiple times

					-- needs to go last, so you don't get 11 points on first kill
					player.chain += 1-- * player.multi_hits

					player:bonus_life_check()
				end

				enemy:kill(other)
				enemy:create_outside(rnd(1))
			end
		end


	-- visual
		function attack:draw(a)
			-- -3.5 instead of -4 to compensate for lack of round
			local x = draw.offset.x + a.x - player.x - 3.5
			local y = draw.offset.y + a.y - player.y - 3.5

			--a.sprite_index = (a.sprite_index + spd/2) % attack.sprite_number
			--spr(attack.sprite_start+flr(a.sprite_index), x, y)
			-- fucking magic
			if a.lifetime > attack.lifetime/2 then
				local p = (a.lifetime / attack.lifetime)
				local s = flr(attack.sprite_number * p)

				spr(a.sprite+s, x, y, 1, 1, a.sprite_flip_x, a.sprite_flip_y)
			elseif a.lifetime < attack.lifetime/3 then
				local p = (a.lifetime / (attack.lifetime/3))
				local s = attack.sprite_number - flr(attack.sprite_number * p)
				spr(a.sprite+s, x, y, 1, 1, a.sprite_flip_x, a.sprite_flip_y)

			else
				spr(a.sprite, x, y, 1, 1, a.sprite_flip_x, a.sprite_flip_y)
			end
		end


--============================--
-- enemy

	-- enemy setup
		enemy = {}

		enemy.max_count = 30
		enemy.points = 10
		enemy.damage = 1
		enemy.radius = 4
		enemy.collision_force = 3

		enemy.sprite_start = 16
		enemy.sprite_number = 3
		enemy.sprite_speed_base = 0.3
		enemy.sprite_speed_rand = 0.05

		enemy.speed = {}
		enemy.speed.start = 0.6
		enemy.speed.base = enemy.speed.start
		enemy.speed.bonus = 0.05
		enemy.speed.rand = enemy.speed.base * 0.5
		enemy.accel = {}
		enemy.accel.base = 0.03
		enemy.accel.rand = 0.01
		enemy.friction = 5
		enemy.target_length = 16

		enemy.particle_lifetime = 40

		enemy.spawn = {}
		enemy.spawn.init_amount = 3
		enemy.spawn.time = 12*60
		enemy.spawn.countdown = enemy.spawn.time
		enemy.spawn.despawn_range = 160

		enemy.id_count = 0 -- to ensure unique id's
		enemy.enemies = {}


		function enemy:reset()
			enemy.id_count = 0
			enemy.enemies = {}
			enemy.wreck.wrecks = {}
			enemy.speed.base = enemy.speed.start
			enemy.speed.rand = enemy.speed.base * 0.6
			enemy.spawn.countdown = enemy.spawn.time
		end


		function enemy:speed_up(mul)
			enemy.speed.base += enemy.speed.bonus * mul
			enemy.speed.rand = enemy.speed.base * 0.6
		end


	-- creation / kill
		function enemy:new_id()
			local id = enemy.id_count
			enemy.id_count += 1
			return id
		end


		function enemy:count()
			local count = 0
			for k,v in pairs(enemy.enemies) do
				count += 1
			end

			return count
		end


		function enemy:create(x, y)
			if enemy:count() < enemy.max_count then
				local e = {}
				e.id = enemy:new_id()
				e.alive = true

				e.x = x
				e.y = y
				e.vxs = 0
				e.vys = 0
				e.max_speed = enemy.speed.base + rnd(enemy.speed.rand)
				e.accel = enemy.accel.base + rnd(enemy.accel.rand)

				e.points = enemy.points -- needed so as not to count points multiple times
				e.radius = enemy.radius
				
				e.sprite = enemy.sprite_start
				e.sprite_index = flr(rnd(enemy.sprite_number))
				e.sprite_speed = enemy.sprite_speed_base + rnd(enemy.sprite_speed_rand)

				enemy.enemies[#enemy.enemies+1] = e
			end
		end


		function enemy:create_outside(d)
			local x = player.x + cos(d) * 128
			local y = player.y + sin(d) * 128

			enemy:create(x, y)
		end


		function enemy:create_outside_mul(d, dist_mul)
			local x = player.x + cos(d) * 128 * dist_mul
			local y = player.y + sin(d) * 128 * dist_mul

			enemy:create(x, y)
		end


		function enemy:kill(e)
			particle:create_cloud(e.x, e.y, particle.generic, enemy.particle_lifetime)

			e.alive = false
			--sfx(sound.enemy_die)
			enemy.wreck:create(e.x, e.y)
			del(enemy.enemies, e)
		end


		function enemy:clear()
			for k,v in pairs(enemy.enemies) do
				local e = enemy.enemies[k]
				--enemy.wreck:create(e.x, e.y)
				enemy.enemies[k] = nil
			end
		end


	-- move / physics
		function enemy:move(e)
			local target_x = player.x + player.vxs * enemy.target_length / e.max_speed
			local target_y = player.y + player.vys * enemy.target_length / e.max_speed

			local dx = target_x - e.x
			local dy = target_y - e.y
			local d = atan2(dx, dy)
			
			e.vxs += cos(d) * e.accel
			e.vys += sin(d) * e.accel

			local speed = sqrt(e.vxs^2 + e.vys^2)
			local direction = atan2(e.vxs, e.vys)

			if speed > e.max_speed then
				local thresh = speed - enemy.friction - e.max_speed
				local difference = speed - e.max_speed
				if thresh < 0 then
					e.vxs += cos(direction+0.5) * difference
					e.vys += sin(direction+0.5) * difference
				else
					e.vxs += cos(direction+0.5) * enemy.friction
					e.vys += sin(direction+0.5) * enemy.friction
				end
			end

			e.x += e.vxs * spd
			e.y += e.vys * spd
		end


		function enemy:move_all()
			for k,v in pairs(enemy.enemies) do
				enemy:move(v)
			end
		end


		function enemy:collision(me, other)
			local x = other.x - me.x
			local y = other.y - me.y
			local d = atan2(x, y)+0.5
			enemy:push(me, d, enemy.collision_force)
		end


		function enemy:push(e, direction, force)
			e.vxs += cos(direction) * force
			e.vys += sin(direction) * force
		end


	-- visual
		function enemy:draw(e)
			local x = draw.offset.x + e.x - player.x
			local y = draw.offset.y + e.y - player.y

			e.sprite_index = (e.sprite_index + e.sprite_speed*spd) % enemy.sprite_number
			spr(e.sprite+e.sprite_index, x-4, y-4)

			-- todo: maybe put this in its own draw function, so that it can
			-- be draw either on top, or below all enemies. currently it just
			-- draws the pointers in a random order.

			if player.alive then
				draw:marker(x, y, 8)
			end
		end


	-- enemy wreck
		enemy.wreck = {}
		enemy.wreck.max_count = 50
		enemy.wreck.sprite_start = 32
		enemy.wreck.sprite_number = 7
		enemy.wreck.wrecks = {}

		function enemy.wreck:create(x, y)
			-- create the new wreck
			local w = {}
			w.x = flr(x)
			w.y = flr(y)
			local s = flr(rnd(enemy.wreck.sprite_number))
			w.sprite = enemy.wreck.sprite_start + s

			enemy.wreck.wrecks[#enemy.wreck.wrecks+1] = w

			-- remove the first found wreck, when exceeding max_count
			if enemy.wreck:count() > enemy.wreck.max_count then
				for i=1, #enemy.wreck.wrecks do
					del(enemy.wreck.wrecks, enemy.wreck.wrecks[i])
					break
				end
			end
		end


		function enemy.wreck:remove(w)
			for k,v in pairs(enemy.wreck.wrecks) do
				if w == v then
					enemy.wreck.wrecks[k] = nil
				end
			end
		end


		function enemy.wreck:count()
			count = 0
			for k,v in pairs(enemy.wreck.wrecks) do
				count += 1
			end
			return count
		end


		function enemy.wreck:draw(w)
			local x = draw.offset.x + w.x - player.x - 4
			local y = draw.offset.y + w.y - player.y - 4

			spr(w.sprite, x, y)
		end


		function enemy.wreck:draw_all()
			for i=1, #enemy.wreck.wrecks do
				local w = enemy.wreck.wrecks[i]
				if w != nil then
					enemy.wreck:draw(w)
				end
			end
		end


	-- enemy spawn

		function enemy.spawn:update()
			if not debug_mode then
				enemy.spawn.countdown -= spd

				if enemy.spawn.countdown < 0 then
					enemy:speed_up(1)
					enemy:create_outside(rnd(1))
					enemy.spawn.countdown = enemy.spawn.time
				end
			end
		end


		function enemy.spawn:despawn_check()
			for k,e in pairs(enemy.enemies) do
				local x = e.x - player.x
				local y = e.y - player.y

				if abs(x) > enemy.spawn.despawn_range or abs(y) > enemy.spawn.despawn_range then
					del(enemy.enemies, e)
					local d = atan2(x, y) + 0.5 - 0.125 + rnd(0.25)
					enemy:create_outside(d)
				end
			end
		end


--============================--
-- points

	-- point setup
		point = {}

		point.points = 100
		point.chain_multiplier = 10
		point.radius = 5
		point.suck_radius = 40
		point.suck_speed = 2
		point.lifetime = 5*60
		point.particle_lifetime = 30

		point.sprite_start = 51
		point.sprite_number = 1
		point.sprite_speed = 0.25
		point.sprite_spawn_number = 3
		point.sprite_spawn_speed = 0.15

		point.spawn_time = 8*60
		point.spawn_countdown = point.spawn_time
		point.spawn_distance = 40

		point.id_count = 0
		point.list = {}

		function point:reset()
			self.id_count = 0
			self.list = {}
			point.spawn_countdown = point.spawn_time
		end


	-- creation

		function point:new_id()
			local id = self.id_count
			self.id_count += 1
			return id
		end


		function point:create(x, y)
			sfx(sound.point_spawn)

			local p = {}
			p.id = self:new_id()

			p.x = flr(x)
			p.y = flr(y)
			p.points = self.points -- needed so as not to count points multiple times
			p.radius = self.radius
			p.sprite_index = -point.sprite_spawn_number
			p.lifetime = point.lifetime

			add(self.list, p)
		end


		function point:create_behind()
			local d
			if abs(player.vxs) > 0 or abs(player.vys) > 0 then
				d = atan2(player.vxs, player.vys) + 0.5
			else
				d = player.input.direction + 0.5
			end

			local x = player.x + cos(d) * point.spawn_distance
			local y = player.y + sin(d) * point.spawn_distance
			point:create(x, y)
		end


	-- kill / collision
		function point:kill(p)
			particle:create_cloud(p.x, p.y, particle.point, point.particle_lifetime)
			del(point.list, p)
		end


		function point:collision(p)
			if player.alive then
				sfx(sound.point_get)
				local points = p.points + player.chain * point.chain_multiplier
				ptext:create(p.x, p.y, points)
				player.score += points
				p.points = 0
				point:kill(p)

				player:bonus_life_check()
			end
		end


	-- update / visual

		function point:update_all()
			for k,p in pairs(point.list) do
				p.lifetime -= spd

				if p.lifetime < 0 then
					sfx(sound.point_lose)
					point:kill(p)
				end
			end
		end


		function point:draw(p)
			local x = draw.offset.x + p.x - player.x
			local y = draw.offset.y + p.y - player.y

			if p.sprite_index >= 0 then -- normal
				p.sprite_index = (p.sprite_index + point.sprite_speed*spd) % point.sprite_number
			else -- spawn
				p.sprite_index += point.sprite_spawn_speed*spd
			end

			spr(point.sprite_start+p.sprite_index, x-4, y-4)
			--spr(106, x-4, y-4)
			
			for i=0.33, 1, 0.33 do
				local speed = 4
				local length = 10

				if     p.sprite_index >= 0 then length = 4.0
				elseif p.sprite_index >= -1 then length = 3.5
				elseif p.sprite_index >= -2 then length = 3.0
				end

				if p.sprite_index >= -2 then
					local a = p.lifetime / point.lifetime * speed + 0.08
					local x2 = flr(x) + cos(i+a) * (length + 0.75)
					local y2 = flr(y) + sin(i+a) * (length + 0.75)

					pset(x2, y2, 3)
				end

				if p.sprite_index >= -1 then
					local a = p.lifetime / point.lifetime * speed + 0.04
					local x2 = flr(x) + cos(i+a) * (length + 0.5)
					local y2 = flr(y) + sin(i+a) * (length + 0.5)

					pset(x2, y2, 11)
				end

				if p.sprite_index >= 0 then
					local a = p.lifetime / point.lifetime * speed
					local x2 = flr(x) + cos(i+a) * (length + 0.25)
					local y2 = flr(y) + sin(i+a) * (length + 0.25)

					pset(x2, y2, 10)
				end
			end

			if player.alive then
				draw:marker(x, y, 11)
			end
		end


	-- spawn

		function point:spawn_update()
			if not debug_mode then
				self.spawn_countdown -= spd

				if self.spawn_countdown < 0 then
					self:create_behind()
					self.spawn_countdown = self.spawn_time
				end
			end
		end


--============================--
-- particles

	particle = {}
	particle.sprites = {19,20,21,22,-1}

	particle.generic = {7,6,5}
	particle.point = {10,11,3}

	particle.list = {}

	function particle:reset()
		particle.list = {}
	end


	function particle:create(x, y, color, lifetime)
		local p = {}
		p.x = flr(x)
		p.y = flr(y)
		p.color = color
		p.lifetime = lifetime
		p.lifetime_max = lifetime

		add(self.list, p)
	end


	function particle:create_cloud(x, y, color, lifetime)
		local r = 3 + rnd(1)
		local a
		if rnd(1) < 0.5 then a = 3
		else                 a = 4
		end

		for i=1,a do
			local d = i/a
			local x2 = x + cos(d) * r
			local y2 = y + sin(d) * r
			local l = lifetime*0.8 + rnd(lifetime*0.4)
			particle:create(x2, y2, color, l)
		end
	end


	function particle:update_all()
		for k,p in pairs(particle.list) do
			if p.lifetime <= 0 then
				del(particle.list, p)
			else
				p.lifetime -= spd
			end
		end
	end


	function particle:draw(p)
		local x = draw.offset.x + p.x - player.x
		local y = draw.offset.y + p.y - player.y

		local percent = 1 - p.lifetime / p.lifetime_max
		local index = flr(percent * (#particle.sprites-1)) + 1

		local sprite = particle.sprites[index]
		if sprite != -1 then
			for i=1, 3 do
				pal(particle.generic[i], p.color[i])
			end
			spr(sprite, x-4, y-4)
			pal()
		end
	end


--============================--
-- collisions
	function collisions()
		-- points sucking and collision
		if player.alive then
			for k,p in pairs(point.list) do
				local x = p.x - player.x
				local y = p.y - player.y

				if abs(x) < point.suck_radius and abs(y) < point.suck_radius then
					local dist = sqrt(abs(x^2) + abs(y^2))

					if 0 < dist and dist < point.suck_radius then
						local d = atan2(x, y) + 0.5
						local speed = (1 - dist / point.suck_radius) * point.suck_speed
						p.x += cos(d) * speed
						p.y += sin(d) * speed
					end

					if 0 < dist and dist < player.radius+point.radius then
						point:collision(p)
					end
				else
					p.x = flr(p.x)
					p.y = flr(p.y)
				end
			end
		end


		-- 56.641% @20 enemies
		local checked = {}

		for k,e in pairs(enemy.enemies) do
			-- player
			local x = e.x - player.x
			local y = e.y - player.y
			-- this "if" fixes the random collision bug
			-- it happens because 182^2 is greater than the max possible
			-- number, and so it overflows
			if abs(x) < 16 and abs(y) < 16 then
				local dist = sqrt(abs(x^2) + abs(y^2))
				if 0 < dist and dist < player.radius+enemy.radius then
					--debug.log[18] = "dist "..dist
					player:collision(e)
				end
			end

			-- attack
			for k,a in pairs(attack.projectiles) do
				local x = e.x - a.x
				local y = e.y - a.y
				if abs(x) < 16 and abs(y) < 16 then
					local dist = sqrt(abs(x^2) + abs(y^2))
					if 0 < dist and dist < a.radius + e.radius then
						attack:collision(a, e)
					end
				end
			end

			-- enemies
			for k,other in pairs(enemy.enemies) do
				if checked[other.id] != true then
					local x = other.x - e.x
					local y = other.y - e.y
					if abs(x) < 16 and abs(y) < 16 then
						local dist = sqrt(abs(x^2) + abs(y^2))
						if 0 < dist and dist < enemy.radius*2 then
							enemy:collision(e, other)
						end
					end
				end

			checked[e.id] = true
			end
		end
	end


--============================--
-- floor
	floor = {}
	floor.sprite = 12
	-- having it be 4x4 tiles instead of 2x2 givs about 1-2% extra cpu
	floor.sprite_tile_size_x = 4
	floor.sprite_tile_size_y = 4

	floor.sprite_width = floor.sprite_tile_size_x * 8
	floor.sprite_height = floor.sprite_tile_size_y * 8
	floor.repeat_x = 128 / floor.sprite_width
	floor.repeat_y = 128 / floor.sprite_height

	function floor:draw()
		local x = -(player.x%floor.sprite_width)
		local y = -(player.y%floor.sprite_height)

		for iy=0, floor.repeat_y do
			for ix=0, floor.repeat_x do
				local nx = x+ix*floor.sprite_width
				local ny = y+iy*floor.sprite_height
				spr(floor.sprite, nx, ny, floor.sprite_tile_size_x, floor.sprite_tile_size_y)
			end
		end
	end


--============================--
-- resets

	reset = {}

	function reset:menus()
		splash:reset()
		menu:reset()
	end


	function reset:game()
		player:reset()
		attack:reset()
		enemy:reset()
		point:reset()
		particle:reset()
	end


--============================--
-- states

	-- i would strongly advise against looking at these functions

	-- splash
		splash = {}
		splash.sprite = 64
		splash.w = 4
		splash.h = 4
		splash.max_x = -32
		splash.sound = 10

		splash.text = {}
		splash.text.sprite = 68
		splash.text.w = 4
		splash.text.h = 1
		splash.text.x = 0

		-- 60 is 1 second
		splash.timer_adv_logo = 0
		splash.timer_adv_logo_max = 30
		splash.timer_adv_text = 0
		splash.timer_adv_text_max = 30
		splash.timer_hang = 0
		splash.timer_hang_max = 30

		function splash:reset()
			splash.timer_adv_logo = 0
			splash.timer_adv_text = 0
			splash.timer_hang = 0
		end


		function splash:update()
			-- skip splash
			if btnp(player.input.attack) then
				transition:to(state_menu)
			elseif btnp(4, 1) then
				state = state_cart
			end

			-- logic for animation
			if self.timer_adv_logo < self.timer_adv_logo_max then
				self.timer_adv_logo += spd
			else

				self.timer_adv_logo = self.timer_adv_logo_max
				if self.timer_adv_text < self.timer_adv_text_max then
					self.timer_adv_text += spd
				else

					self.timer_adv_text = self.timer_adv_text_max
					if self.timer_hang < self.timer_hang_max then
						self.timer_hang += spd
					else

						self.timer_hang = self.timer_hang_max
						transition:to(state_menu)
					end
				end
			end
		end


		function splash:draw()
			-- lower left
			print(version, 1, 122, 7)

			-- text
			if self.timer_adv_logo == self.timer_adv_logo_max then
				local xp = -sin(splash.timer_adv_text / splash.timer_adv_text_max / 4)
				local x = (64 - (8*self.w)/2-18) + xp*36
				local y = 64 - (8*self.text.h)/2
				spr(self.text.sprite, x, y, self.text.w, self.text.h)
			end

			-- image
			local xp = -sin(splash.timer_adv_logo / splash.timer_adv_logo_max / 4)
			local x = 128 - xp*(64+16+18)--(64 - (8*self.w)/2) - xp*18
			local y = 64 - (8*self.h)/2
			rectfill(x, y, x+8*self.w, y+8*self.h-1, 0) -- black background
			spr(self.sprite, x, y, self.w, self.h)
		end


	-- menu
		menu = {}

		menu.flash = {}
		menu.flash.timer_max = 30
		menu.flash.timer = menu.flash.timer_max
		menu.flash.is_showing = true

		menu.move_sprite = 84
		menu.move_w = 4
		menu.attack_sprite = 126
		menu.dash_sprite = 127
		menu.fab_sprite_fire = 100
		menu.fab_sprite_amp = 104
		menu.fab_sprite_blade = 105

		menu.continued = false

		menu.text_1 = "you have activated the alarm"
		menu.text_2 = "system in an infinite stretching"
		menu.text_3 = "room, and you must now flee from"
		menu.text_4 = "the killer spinning robots."


		function menu:reset()
			menu.flash.timer = menu.flash.timer_max
			menu.flash.is_showing = true
			menu.continued = false
		end


		function menu:update()
			-- z to continue
			if btnp(4) and not self.continued then
				self.continued = true
				sfx(sound.tv_out)
				transition:dofade(transition.tv_fade_time, "tv_out", true)
				generic:wait_func(30, function() transition:to(state_game) end)
			end

			-- flash
			self.flash.timer -= spd
			if self.flash.timer < 0 then
				self.flash.timer = self.flash.timer_max
				self.flash.is_showing = not self.flash.is_showing
			end
		end


		function menu:draw()
			-- story
			local y = -128
			print(self.text_1, 0, y, 7)
			y += 6
			print(self.text_2, 0, y, 7)
			y += 6
			print(self.text_3, 0, y, 7)
			y += 6
			print(self.text_4, 0, y, 7)


			-- cart art
			spr(128, 0, 0, 16, 8)

			-- fire & blade
			local color = {-1, 5, 1}
			for iy=2, 0, -1 do
				if iy > 0 then
					pal(7, color[iy+1])
					pal(6, color[iy+1])
				end

				local y = 46+iy
				local x = 13
				for i=0, 3 do
					spr(menu.fab_sprite_fire+i, x+10*i, y)
				end

				local x = 55
				spr(menu.fab_sprite_amp, x, y)

				local x = 67
				for i=0, 4 do
					spr(menu.fab_sprite_blade+i, x+10*i, y)
				end

				pal()
			end

			-- border
			rect(0, 64, 127, 64, 13)
			rect(0, 65, 127, 65, 1)


			-- instructions
			local x = 8
			local y = 64 + 12
			print("move:", x, y+1, 5)
			print("move:", x, y, 7)
			spr(self.move_sprite, x+32, y-1, self.move_w, 1)

			y += 10
			print("attack:", x, y+1, 5)
			print("attack:", x, y, 7)
			spr(self.attack_sprite, x+32, y-1, 1, 1)

			y += 10
			print("dash:", x, y+1, 5)
			print("dash:", x, y, 7)
			spr(self.dash_sprite, x+32, y-1, 1, 1)


			-- highscore
			if high.score > 0 then
				local x = 127 - 8 - #"hiscore" * 4
				local y = 64 + 18

				print("hiscore", x, y+1, 5)
				print("hiscore", x, y, 7)

				x = x + (#"hiscore" * 4 / 2) - (#(""..high.score) * 4 / 2)
				y += 8
				print(high.score, x, y+1, 5)
				print(high.score, x, y, 7)
			end


			-- flash
			if self.flash.is_showing then
				local x = 64 - (#over.text_retry + 3) * 4 / 2 -- center
				local y = 128-16
				spr(self.attack_sprite, x, y-1, 1, 1)
				print("to start", x+3*4, y+1, 5)
				print("to start", x+3*4, y, 7)
			end
		end


	-- game over
		over = {}

		over.over_sprite1 = 72
		over.over_sprite2 = 76
		over.over_w = 4
		over.over_h = 2

		over.text_resist  = "why do you resist? you know"
		over.text_outcome = "the outcome will be the same"
		over.text_retry = "to retry"

		over.flash = {}
		over.flash.timer_max = 30
		over.flash.timer = menu.flash.timer_max
		over.flash.is_showing = true

		over.continued = false
		over.skip_delay = 30
		over.skip_sprite = menu.attack_sprite


		function over:reset()
			over.flash.timer = menu.flash.timer_max
			over.flash.is_showing = true
			over.skip_delay = 30
			over.continued = false
		end


		function over:update()
			-- z to continue
			if self.skip_delay < 0 and btnp(4) and not self.continued then
				self.continued = true
				music(-1)
				sfx(sound.tv_out)
				transition:dofade(transition.tv_fade_time, "tv_out", true)
				generic:wait_func(30, function() transition:to(state_game) end)
			end

			-- flash
			if self.skip_delay < 0 then
				self.flash.timer -= spd
				if self.flash.timer < 0 then
					self.flash.timer = self.flash.timer_max
					self.flash.is_showing = not self.flash.is_showing
				end
			else
				self.skip_delay -= spd
			end
		end


		function over:draw()
			-- game over
			local x = 64 - 4 - 8*self.over_w
			local y = 24
			spr(self.over_sprite1, x, y, self.over_w, self.over_h)
			x = 64 + 4
			spr(self.over_sprite2, x, y, self.over_w, self.over_h)

			-- story
			y += 20
			print(over.text_resist, 10, y+1, 2)
			print(over.text_resist, 10, y, 8)
			y += 7
			print(over.text_outcome, 8, y+1, 2)
			print(over.text_outcome, 8, y, 8)


			-- score
			local text = {}
			if high.new then
				text[0] = "new hiscore! "..player.score
				text[1] = "best chain: "..player.best_chain
				text[2] = "best multi kill: "..player.best_multi_hits
				if high.score_old > 0 then
					text[3] = ""
					text[4] = "old best: "..high.score_old
				end
			else
				text[0] = "score: "..player.score
				text[1] = "best chain: "..player.best_chain
				text[2] = "best multi kill: "..player.best_multi_hits
				text[3] = ""
				text[4] = "hiscore: "..high.score
			end

			local adjust_y = 0

			for i=0, #text do
				if text[i] == "" then adjust_y -= 4 end
				local x = 64 - #text[i] * 4 / 2 -- center
				local y = 64 + 8*i + adjust_y
				print(text[i], x, y+1, 5)
				print(text[i], x, y, 7)
			end

			-- godmode
			if god_mode then
				local s = "god mode"
				print(s, 128-(#s*4), 128-6, 6)
			end

			-- flash
			if self.skip_delay < 0 and self.flash.is_showing then
				local x = 64 - (#over.text_retry + 3) * 4 / 2 -- center
				local y = 128-16

				spr(self.skip_sprite, x, y-1, 1, 1)
				print(over.text_retry, x + 3*4, y+1, 5)
				print(over.text_retry, x + 3*4, y, 7)
			end
		end


	-- cart
		-- absolute values rock! /s
		cart = {}

		cart.fab_sprite_fire = 100
		cart.fab_sprite_amp = 104
		cart.fab_sprite_blade = 105


		function cart:draw()
			-- cart art
			spr(128, 0, 0, 16, 8)

			-- fire & blade
			local color = {-1, 5, 1}
			for iy=2, 0, -1 do
				if iy > 0 then
					pal(7, color[iy+1])
					pal(6, color[iy+1])
				end

				local y = 46+iy
				local x = 13
				for i=0, 3 do
					spr(menu.fab_sprite_fire+i, x+10*i, y)
				end

				local x = 55
				spr(menu.fab_sprite_amp, x, y)

				local x = 67
				for i=0, 4 do
					spr(menu.fab_sprite_blade+i, x+10*i, y)
				end

				pal()
			end

			-- border
			rectfill(0, 64, 127, 64, 6)
			rectfill(0, 65, 127, 66, 13)
			rectfill(0, 67, 127, 68, 5)
			rectfill(0, 69, 127, 71, 1)

			-- ribbon
			rectfill(0, 90, 127, 107, 1)
			rect(-1, 89, 128, 108, 13) -- edge

			rectfill(29, 82, 62, 115, 1) -- logo bg
			--rectfill(29, 81, 62, 81, 13)
			--rectfill(29, 116, 62, 116, 13)

			-- a game by maximus
			rectfill(30, 83, 61, 114, 0) -- black bg
			spr(splash.sprite, 30, 83, splash.w, splash.h)
			print("a", 66+1, 92, 13)
			print("game", 72+1, 92, 13)
			print("by", 90+1, 92, 13)
			print("a", 66, 92, 7)
			print("game", 72, 92, 7)
			print("by", 90, 92, 7)
			spr(splash.text.sprite, 66, 98, splash.text.w, splash.text.h)
		end


		function cart:update()
			if btnp(4, 1) then
				transition:to(state_splash)
			end
		end


--============================--
-- score highscore
	high = {}
	high.score = dget(save_score)
	high.score_old = dget(save_score_old)
	high.score_chain = 0
	high.score_multi_hits = 0
	high.new = false

	high.chain = dget(save_chain)
	high.multi_hits = dget(save_multi)


	function high:update_highscore(s)
		high:update_bonus() -- has to be run here
		-- save highscore and related bonuses
		if s > high.score and not debug_mode and not god_mode then
			dset(save_score_old, high.score)
			high.score_old = high.score

			dset(save_score, s)
			dset(save_score_chain, player.best_chain)
			dset(save_score_multi, player.best_multi_hits)
			high.score = s
			high.score_chain = player.best_chain
			high.score_multi_hits = player.best_multi_hits
			high.new = true
		else
			high.new = false
		end

		-- save best bonuses
		if player.best_chain > high.chain then
			high.chain = player.best_chain
			dset(save_chain, player.best_chain)
		end
		if player.best_multi_hits > high.multi_hits then
			high.multi_hits = player.best_multi_hits
			dset(save_multi, player.best_multi_hits)
		end
	end

	function high:update_bonus()
		high:update_chain()
		local hits = player.multi_hits
		
		if hits == 0 then
			player.chain = 0
		elseif hits > player.best_multi_hits then
			player.best_multi_hits = hits
		end

		player.multi_hits = 0
	end

	function high:update_chain()
		if player.chain > player.best_chain then
			player.best_chain = player.chain
		end
	end


--============================--
-- transition

	-- setup
		transition = {}

		transition.fade_time = 0
		transition.fade_time_max = 0
		transition.fade_type = nil
		transition.fade_should_hold = false

		transition.tv_fade_time = 6

	-- transition
		function transition:to(st)
			-- remove old menu items
			menuitem(1)

			-- set global state
			state = st

			if st == state_splash then
				music(-1)
				reset:menus()
			elseif st == state_menu then
				music(-1)
				reset:menus()
			elseif st == state_game then
				sfx(sound.tv_in)
				transition:dofade(transition.tv_fade_time, "tv_in")
				music(-1)
				music(sound.music.hopeful_resistance, 2000, 12)
				menuitem(1, "suicide", function() player:die() end)
				ptext:reset()
				reset:game()
				if not debug_mode then
					for i=1, enemy.spawn.init_amount do
						enemy:create_outside_mul(rnd(1), 1.5)
					end
				else
					enemy:speed_up(-enemy.spawn.init_amount)
				end
			end
		end

	-- fade

		function transition:dofade(t, f, hold)
			self.fade_type = f
			self.fade_time = t
			self.fade_time_max = t
			self.fade_should_hold = hold
		end


		function transition:draw_fade()
			if self.fade_type == "tv_in" then
				self:fade_tv(self.fade_time / self.fade_time_max)
			elseif self.fade_type == "tv_out" then
				self:fade_tv(1-(self.fade_time / self.fade_time_max))
			end
		end


		function transition:update_fade()
			if self.fade_time > 0 then
				self.fade_time -= spd
			else
				if not self.fade_should_hold then
					self.fade_type = nil
				end
			end
		end


		function transition:fade_tv(d)
			local p = -cos(d/4)+1
			local fade_height = flr(p * 64)

			local drawn_ratio = 64 / (64 - fade_height)
			local drawn_ratio2 = (64 - fade_height) / 64

			-- top displacement
			for y=63,0,-drawn_ratio do
				for x=0,127 do
					local pixel = pget(x, flr(y))
					pset(x, flr(fade_height + y/drawn_ratio), pixel)
				end
			end

			-- bottom displacement
			for y=64,127,drawn_ratio do
				for x=0,127 do
					local pixel = pget(x, flr(y))
					pset(x, flr(fade_height + y/drawn_ratio), pixel)
				end
			end

			-- black bars
			rectfill(0, 0, 127, fade_height, 0)
			rectfill(0, 127, 127, 127-fade_height, 0)
		end


--============================--
-- draw vars/functions

	-- setup
		draw = {}
		draw.offset = {}
		draw.offset.x = 64
		draw.offset.y = 64

		draw.heart_offset_x = 1
		draw.heart_offset_y = 1

		draw.fuel_segments = 3
		draw.fuel_offset_x = 128-8*draw.fuel_segments-1
		draw.fuel_offset_y = 1
		draw.fuel_offset_rect_y = 3
		draw.fuel_length = 128-draw.fuel_offset_x-6
		draw.fuel_height = 2
		draw.fuel_color1 = 3
		draw.fuel_color2 = 11

		draw.score_offset_x = 102 --128-32
		draw.score_offset_y = 2
		draw.score_color1 = 7
		draw.score_color2 = 5
		draw.chain_offset_x = 106
		draw.chain_offset_y = 2

		draw.sprite = {}
		draw.sprite.heart = 110
		draw.sprite.heart_hit = 111
		draw.sprite.fuel_start = 52
		draw.sprite.fuel_mid = 53
		draw.sprite.fuel_end = 54
		draw.sprite.chain = 3

		draw.marker_distance = 60

		draw.distortion_amount = 4


	-- objects
		function draw:objects()
			for k,p in pairs(particle.list) do
				particle:draw(p)
			end

			for k,p in pairs(point.list) do
				point:draw(p)
			end

			for k,e in pairs(enemy.enemies) do
				enemy:draw(e)
			end

			player:draw_object()

			for k,a in pairs(attack.projectiles) do
				attack:draw(a)
			end
		end


	-- ui
		function draw:ui()
			-- hearts
			for i=0, player.health-1 do
				if player.flash > 0 then
					-- flashed heart
					spr(draw.sprite.heart_hit, draw.heart_offset_x+i*8, draw.heart_offset_y)
				else
					-- normal heart
					spr(draw.sprite.heart, draw.heart_offset_x+i*8, draw.heart_offset_y)
				end
			end

			local length = draw.fuel_length * player.fuel.amount
			local x1 = draw.fuel_offset_x + 2 + draw.fuel_length
			local y1 = draw.fuel_offset_rect_y
			local x2 = x1 - length
			local y2 = y1 + draw.fuel_height


			--[[
			rectfill(x1, y1, x1-draw.fuel_length, y2, 0) -- black background
			-- fuel
			for i=0, draw.fuel_segments-1 do
				if i == 0 then
					spr(draw.sprite.fuel_start, draw.fuel_offset_x, draw.fuel_offset_y)
				elseif i == draw.fuel_segments-1 then
					spr(draw.sprite.fuel_end, draw.fuel_offset_x+i*8, draw.fuel_offset_y)
				else
					spr(draw.sprite.fuel_mid, draw.fuel_offset_x+i*8, draw.fuel_offset_y)
				end
			end
			
			-- visual fuel
			rectfill(x1, y1, x2, y2, draw.fuel_color1)
			rectfill(x1, y1, x2, y1, draw.fuel_color2)
			--]]

			-- score
			local score_string = ""..player.drawn_score
			local off_x = draw.score_offset_x - #score_string * 4
			print(player.drawn_score, off_x, draw.score_offset_y+1, draw.score_color2)
			print(player.drawn_score, off_x, draw.score_offset_y, draw.score_color1)

			spr(draw.sprite.chain, draw.chain_offset_x, 1)
			local off_x = draw.chain_offset_x + 9
			local c = player.chain
			if     #(""..c) == 1 then c = "00"..c
			elseif #(""..c) == 2 then c = "0"..c
			else c = ""..c end
			print(c, off_x, draw.score_offset_y+1, draw.score_color2)
			print(c, off_x, draw.score_offset_y, draw.score_color1)

			-- godmode
			if god_mode then
				local s = "god mode"
				print(s, 128-(#s*4), 128-6, 6)
			end
		end


	-- enemy/point marker

		function draw:marker(x, y, color)
			if x < 0 or x > 127 or y < 0 or y > 127 then
				local ind_x = x - draw.offset.x
				local ind_y = y - draw.offset.y
				local d = atan2(ind_x, ind_y)
				local new_x = cos(d) * draw.marker_distance + draw.offset.x
				local new_y = sin(d) * draw.marker_distance + draw.offset.y
				rectfill(new_x-1, new_y-1, new_x, new_y, color)
			end
		end


	-- distort
		function draw:distort(a)a=min(a,64)for y=0,127 do local r=flr(-a+rnd(a*2)+0.5)local s,e,l,m=max(-r,0),max(r,0),64-abs(r),24576+y*64memcpy(m+e,m+s,l)end end


--============================--
-- point text
	
	-- setup
		ptext = {}
		ptext.lifetime = 0.75*60
		ptext.color = 7
		ptext.color2 = 5
		ptext.goto_x = draw.score_offset_x + 1
		ptext.goto_y = draw.score_offset_y + 6
		ptext.list = {}

		function ptext:reset()
			self.list = {}
		end


	-- create
		function ptext:create(world_x, world_y, points)
			local t = {}
			t.points = points
			t.lifetime = ptext.lifetime

			local start_x = draw.offset.x + world_x - player.x
			start_x += #(""..points)*4/2 -- center
			local start_y = draw.offset.y - 3 + world_y - player.y
			--local x = start_x - self.goto_x
			--local y = start_y - self.goto_y
			local x = self.goto_x - start_x
			local y = self.goto_y - start_y
			t.m = sqrt(abs(x^2) + abs(y^2))
			t.d = atan2(x, y)
			t.x = start_x
			t.y = start_y
			t.start_x = start_x
			t.start_y = start_y
			add(self.list, t)
		end


	-- singular update / draw
		function ptext:draw(t)
			local s = ""..t.points
			local x = t.x-(#s*4)
			local y = t.y
			print(s, x, y+1, ptext.color2)
			print(s, x, y, ptext.color)
		end

		function ptext:update(t)
			local p = sin((1 - t.lifetime / self.lifetime) / 4)

			t.x = t.start_x - cos(t.d) * t.m * p
			t.y = t.start_y - sin(t.d) * t.m * p

			t.lifetime -= spd
			if t.lifetime < 0 then
				player.drawn_score += t.points
				del(self.list, t)
			end
		end


	-- all update / draw
		function ptext:draw_all()
			for k,v in pairs(ptext.list) do
				ptext:draw(v)
			end
		end

		function ptext:update_all()
			for k,v in pairs(ptext.list) do
				ptext:update(v)
			end
		end


--============================--
-- debug

	-- debug setup
		debug = {}
		debug.log = {}

	-- debug update

		function debug:update()
			if debug_mode then
				if btnp(4, 1) then
					if enemy:count() < enemy.max_count then
						enemy:speed_up(1)
						enemy:create_outside(rnd(1))
					end
				end

				if btnp(5, 1) then
					point:create_behind()
				end
			end
		end

	-- draw
		function debug:draw()
			if debug_mode then
				--debug.log[2] = "speed "..sqrt(player.vxs ^ 2 + player.vys ^ 2)
				--debug.log[3] = "enemies "..enemy:count()
				--debug.log[4] = "wrecks "..enemy.wreck:count()

				local c = stat(1)*100
				debug.log[4] = "chain: "..player.chain
				debug.log[5] = "multi: "..player.multi_hits
				debug.log[19] = "dev mode"
				debug.log[20] = "cpu "..c.."%"

				-- draw lines
				for k,v in pairs(debug.log) do
					print(v, 0, k*6, 6)
				end
			end
		end


--============================--
-- init, update and draw

	function main_update()
		if state == state_splash then
			splash:update()
		-- ^state_splash

		elseif state == state_menu then
			menu:update()
		-- ^state_menu

		elseif state == state_game then
			if player.alive then
				player:update()
				enemy.spawn:despawn_check()
				point:spawn_update()
				ptext:update_all()
			else
				if (btnp(4, 1)) debug_mode = not debug_mode
				if (btnp(5, 1)) godmode()
				over:update()
			end
			attack:move_all()
			enemy:move_all()
			collisions()
			enemy.spawn:update()
			point.update_all()
			particle.update_all()

			debug:update()
		-- ^state_game

		elseif state == state_over then
			over:update()
		-- ^state_over

		elseif state == state_cart then
			cart:update()
		-- ^state_cart
		end

		generic:wait_update()
		transition:update_fade()
	end


	function _draw()
		cls()
		if state == state_splash then
			splash:draw()
		-- ^state_splash

		elseif state == state_menu then
			menu:draw()
		-- ^state_menu

		elseif state == state_game then
			floor:draw()
			enemy.wreck:draw_all()
			draw:objects()
			if player.alive then
				draw:ui()
				ptext:draw_all()
			else
				draw:distort(0.75)
				over:draw()
			end
		-- ^state_game
		
		elseif state == state_over then
			over:draw()
		-- ^state_over
		
		elseif state == state_cart then
			cart:draw()
		-- ^state_cart
		end

		-- distortion
		if player.flash > 0 then
			local p = (player.flash / player.flash_period) ^ 2
			draw:distort(p * draw.distortion_amount)
		end

		transition:draw_fade()
		debug:draw() -- debug
	end


--============================--
-- don't edit this directly
-- set spd on top line instead

if spd == 2 then
	function _update()
		main_update()
	end
elseif spd == 1 then
	function _update60()
		main_update()
	end
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end
__gfx__
00444400002222000077770000000000000000000000000000077000000000000000000000000000000000000000000011110110101001001111011010100100
04999940024444200777777000000000000000000000077000055000077000000000000000000000000000000000000010000000000000001000000000000000
49779942249944227777777677777555000000000000556000055000065500000000000000000000000000000000000010000000000000001000000000000000
49779942249944227777777670057005000005570000550000000000005500007550000000000000000000000000000010000000000000001000000000000000
49999942244444227777777670057005000005560000000000000000000000006550000000550000000000000000550000000000000000000000000000000000
49999442244442227777777677755555000000000000000000000000000000000000000007550000000550000000557010000000000000001000000000000000
02444420022222200677776000000000000000000000000000000000000000000000000006600000000550000000066010000000000000001000000000000000
00222200002222000066660000000000000000000000000000000000000000000000000000000000000660000000000000000000000000000000000000000000
00007000000000700770000000000000000000000006500000050000000aaa00000aaa00000a9900000940000000000010000000000000001000000000000000
000760007700076000600007000000000006600000050000000000000aa999400aa994000aa94000099400000094000000000000000000000000000000000000
000880000678860000088076000600000065500000000000000000000a9940000a9400000a400000090000000900000010000000000000001000000000000000
778f8270008f8200008f820000677500065006606500006650000000a9900000a9400000a9000000940000000400000000000000000000000000000000000000
06888266008882000088820000675000065065005000000500000005a9400000a900000094000000400000000000000000000000000000000000000000000000
00022000007226607702200000055000005660000000000000000000a9000000a400000090000000000000000000000010000000000000001000000000000000
00076000076000766000060000000000000550000006600000000000040000000000000000000000000000000000000000000000000000000000000000000000
00070000070000000000067000000000000000000000500000005000000000000000000000000000000000000000000000000000000000000000000000000000
0000005505000000000000550000000050000000000005000005000000a9400000a9000000940000000000000000000011110110101001001111011010100100
050000000500000005000000502205500522000000020500000502000a9900000a9400000a900000094000000000000010000000000000001000000000000000
500220000002200000220000021100000210000000000000000021000a9400000a9000000a400000090000000400000010000000000000001000000000000000
00222100052221550221020002000000020000205520200050200100a9900000a9400000a9000000940000009000000010000000000000001000000000000000
00222100502221000010020000000000000002100522210000220000a9900000a9400000a9000000940000009000000000000000000000000000000000000000
000115000001100000011000000002100020005000011000000110500a9400000a9000000a400000090000000400000010000000000000001000000000000000
050000500005000050000000050011000012005000000050005000000a9900000a9400000a900000094000000000000010000000000000001000000000000000
0500000000050000000000505000000000000000050000050005000000a9400000a9000000940000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000aa000000aa000000aa000000990000009900010000000000000001000000000000000
000000000000000000000000000000000077776766666666666666000aa99aa00aa99aa00aa99aa0099449900040040000000000000000000000000000000000
000000000000000000000000000bb000070000000000000000000050a999999aa994499a99400499040000400000000010000000000000001000000000000000
00000000000b3000000ab00000baa300071111111111111111111150994004999400004940000004000000000000000000000000000000000000000000000000
0000300000033000000bb00000bab300061111111111111111111150400000040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000033000005555555555555555555500000000000000000000000000000000000000000010000000000000001000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f77f7fff77777777777777f77fffffff000000000000000000000000000000000888880008888800888088808888888008888800880008808888888088888800
ff7777777777777776dd555567ffffff77651677d7765677d776516771d7777d8888888088888880888888808888888088888880880008808888888088888880
ffff7777777776d500000155777f7776777d5777dd77d77dd777d5777d77d6778822222088222880888888808822222088222880880008808822222088222880
dd45d6ddddd510001dd55d5676d6f66d7776d77751d777d157776d7775777dd68820222088202880882828808802022088220880880008808802202088202880
51155555551005d6f7ff7dd6ddd67d65777777775156765157777777715d77758820020088002880882808808800002088020880880008808800200088200880
5555555551016f777f77fd66d666d6667767767751d777d1577677677d7657778800000088000880882208808800000088000880880008808800000088000880
55555155100f7f6666ffd6666665667677d77d77dd77d77dd77d77d77d776d778808888088888880880208808888800088000880880008808888800088888820
5555555500676d55ddd501111115561577567577d7765677d7756757756777768808888088888880880008808888800088000880888088808888800088888800
111111050df550015550000000005011077777000777770007777700077777008802288088222880880008808822200088000880288088208822200088222880
000000115f50000000000110555510f5777577707775577077777770775577708802288088022880880008808820200088000880288888208802200088202880
00000055d5000000055550505d0651d5775557707755577075555570775557708802088088020880880008808820000088000880028882008802000088000880
00010151500154551d5555d005046005755555707555577075555570775555708800088088000880880008808800000088000880008882008800000088000880
05115d5100564ffffd0015d550055001755555707755577077555770775557708888888088000880880008808888888088888880002820008888888088000880
5715f551054544f640d50054dd500555777777707775577077757770775577702888882088000880880008808888888028888820002800008888888088000880
5d5f61101000554df5ff00154d500001577777505777775057777750577777502222222022000220220002202222222022222200000200002222222022000220
00d750100110054ff4f751f605d11dd1055555000555550005555500055555002020020020000220020000002020022020200200000200002002202000000020
554750105f40004ffff755d655104f77777777777777777777777700777777770777700077777700770000000077770077777700777777770000000000000000
fffd10004445004ffff7d055f100561d777777777777777777777777777777777777770077777777770000007777777777777777777777770088088000770770
15ff000001ff05f6ff77fd10005505017700000000077000770000777700000077000700770000777700000077000077770000777700000008f8888207777776
0004f500514f55105710df1004f765dd666666000006600066666660666666000666600666666660660000006666666666000066666666000088882000777760
00001450d41f55450fd5150044f7f5f6660000000006600066000066660000006600060666000066660000006600006666000066660000000002820000067600
00000011051f50f7547f0000451114dd660000000006600066000066660000006600006066000066660000006600006666000066660000000000200000006000
55555000000f404f10ff0054505005d5660000006666666666000066666666666666666066666666666666666600006666666666666666660000000000000000
44444510000f104f505f000005ff401d660000006666666666000066666666660666660666666600666666666600006666666600666666660000000000000000
dddfd4451005004f105f00004ff77600000000000000770000000000000000000777770000000000000000000000000000000000000000000777770007777700
dffffff64500154f105f05414fff6770000000000007007000033000000000007777777000000000000000000000770000000000000000007755577077575770
ffffffffff4505ff105d0e554f750d76077755000075507000300300777775557700007077777077077706000007007000000000000000007777577077575770
ffffffffffff40d750552554ff505dd6705070500070050003880300700570050666660070077007706070600075007000000000000000007775777077757770
f777777777fff40d501d1155f505776d705070500507750003008000700570056600006677077777070666000570570000000000000000007757777077575770
f77777777777ff500001005550577f77077555000500500080338000777555556600006000000000000000005007500000000000000000007755577077575770
7777777777777ff00000154d00ffffff000000000055000080080000000000006666666000000000000000005005000000000000000000005777775057777750
6ff7777f777ffffd0000015d55feffff000000000000000008800000000000000666606600000000000000000550000000000000000000000555550005555500
d6666dd10000000001f777feee8e8484442222220202000000000000000000110010101000000000000000000000000000000000001000000000000000000000
6d67777776d500000e6efeee4e484844242222022020202020000000101010001110000000000000000000000000000000000000000001100000000000000000
d6667777777776d56eeeeeee48898484422222220202020002010010000000000001110000000000000000000000000000000000000222444444222000000000
6d66677777777767eeeee48484484442222220202020202020000000000000000000001100000000000000000000000000000002488488888848444442200000
d66d667777777767e84848e8484444222220220222020202020200000000000000000000110000000000000000000000000048e88e4844444484282242422000
dd6666667777666e4e448989848442422222022022222020202020000000000000000000001100000000000000000000004e8e4e48e888884444424222224222
04dd6d66666666ee848848484444422222222222202022220202002000000000000000000000111000000000000000004e8e4e84898444448482424242222222
01dfd6d6d6666e884844848448442222222222222222222022020200000000000000000000000001110000000000002eeeee8e4eee8e88884844442222222222
0005d6d6d6d6de44848848448422422222222222222222222022020200000000000000000000000000110000000004eeeeeee4e8484898448442422222220202
0000146d6ddde4848444448424422444442424222222222222222020200000000000000000000000000011000000eeefeeeee4e4e48484844844442222222220
0000015fdd6d4848448484444444444444444444444222222220220200000000000000000000000000000011102eef777feeee8e84e848488484422222202022
00000005dfdd444448484444444448448484848444444422222222220200000000000000000000000000010115ee77777feee4e44e8984844424242222222220
000000005ddd484844444844848484884848484844444244222222022000000000000000000000011111101024e777777eee4e48e89884848482422222020002
0000000005f44444484844844848484884848484884844444222222202000000000000001011111000000000eef777777eeee8e4488484844444242222222220
0000000000144244424484488488888488888888484848444442222240200000001011111100000000000014ee777777feee9e4e4e4898484844222222202002
000000000002244444844488488989898989898484848448444442222200011111010000000000000000004eee77777fee9e8e84848484848424422222020220
00000000000044244444884889884888889888988848484448244222220210000000000000000000000002eeefefffeeeee8e98e489888484444222222222002
000000000002224444844889889898999889988998848488448444422220000000000000000000000000044eeeeeeeeee4e98e48988984848242422220202200
0000000000002422444888988989898889989898889888448844844422200000000000000000000000004e9e9eeeeeee9e8e4898898884844444222222220020
000000000000222444484988984489899889889899889488844844442220000000000000000000000002e8e4ee9e9e49e8e98988988948448442222220202200
00000000000022442484889898989898899899898898889448848482420000000000000000000000000449e4e4e4e4e84988e844889884844242222202202020
000000000000226e444898898e9e9899989898989899898884484444242000000000000000000000000e8e4e9e4e4e9e8e989848988484848424222220202002
00000000000004666484889849898948898989898988988948848848222550000000000000000000004894e484e8984894848984889848482442222222202020
000000000011266fff4489489844498998989989898988988848444424055110000000000000000000e98e44e989e4e9e8989889898884844442222202020200
0001111111115ff6f67f4889894989898989889898989889898448442245550100000020000000000248e98e98e4898844898498888984844422222020202022
111111101000d7777ffff4989844989898989989898989884848444422545455100002220000000004498e98e989849489889889898848484442222222020200
110000000000677777777f6d89498989898988989898898988484842245555455550000000000000048e4489484e448898498898889884844442222202202202
0000000000057777777777ffae9489898989898989889898848444244454545444221000000000000898989e8498444948988989898848484422222222022020
00000000000d777777777777fdd4949898989898889888844844844455454444494510000000000019848e849844984849898988888988444422222022202020
000000000007777777777777fff64d494989898998899898848445454544696aeae45510000000054e4494984984898988989898988848884442222220220202
0000000000577777777777777fffa9a494989898889884844499494444da4f4f4ea4445510001d77f84484898489898989898889898988484444222224022220
0000000000677777777777777ff49d4a4949949849484884849499a9a9a4aeaffaffdd5555567777f49898984498448989898998988884848442222222222002
00000000007777777777777faa9aaa94a4a94949888484484499a449449ae9a4affff4dd4ff77777f84444449849898989889888898988844444422220202220
000000004477777777777faafaf4a4a4aa4f949494444844444444f4a494a9aaa9a9f7fffff77777f44444484984989898989899889898888444242222220202
000000044f77777777ffaafaaa9a9f9aea944494949949449444455115444a49eaf777fffaf77777e98989894894898989898989898888484884422222222020
000000444ff7777fafaaafaaf9f9e9ae9944994949444449444440201044444fafffffffaff77777f89898989898989898989898988989884844242222202202
000004924f7ffaaafafafafaaa4aa999949949449444449444405552444444fffffafafaf9f77777f98989898989898989898989898898848444422222222020
00004420ffaa9ffaaaafaaaf9fa499e94944944444944444440020205449faaafaffafaeaf777777789898989898989898989898989889888884442222022222
0004420249e9fa9fafaaafaa994a499994444444444444444520020004afafffafafaeaafa777777798989898989898998998989898988848444442222220200
00442004949aaafaaaaafa9999949944444444444444444554504505eafaffaafafafaaeaf7777777e9898989898998989989989898898988484442222222022
044200449afaeaaaafaa99999444444444244444444555554524504aafafaaffafafafaaaf7777777f8989898989889898898898989888884844422222202202
444000294aaaaaaaa9a9999e9944444020002244454220402450225499fafaaafafafaffaa777777779894999898998989989989898989898484442222220220
44400049f9f9aea999999e99494445220024045554552444054200049494499aaaaaafaaaf77777777e998988989889898898898988898884844442222222202
440000499faa99999499499444444222022244222524245244452449949499949999a9aeaf777777777989989989898989989989889988848484422222202020
42000499f994999949949494999944444444444452224444444444944949994999494999444aff77777e48898898989898898898988889848444424222022202
4000049949994999994949444444444444444444444224442449949999999994999494994444444444df94889889888989898988898988984844422222220202
4000449449499a999994999949444444449444444444444499944994999999494949949440244944400088948948989898989889898898848444422222022020
02044494999999999949944494444449494494444444499999499999999999949444494442044444400044488488898889888989888988448444222222220202
0024494999999a99e494494944494494449444449499999994999999999949944449944442444444000004844844448988989888989844884442422245555555
0004499499aa9999999a4494494494494944494949949949999999aa9999949444444442250524440000004848888f7fa4498988848484444444444545555555
0049949999a999994944944944944494944944999999999949999aa999994944494442240040054240000004444449777777ffa9949494444444454455515515
0999949a9a9999999994949449444949999999949999999999a9aa9a9994944444442540422020540000000284848477777777777fff6afa4ad45ad455555555
99494499a9a99999494944494494944999944999a99999999a9a999999444944444424252052004540000000244844a777777777777777767777777764555555
949499aaaa9999a99494a9449449499444499949999a99999aaaaa99949944444444245025252004240000000244844f77777777777777777777777666645555
9999499aaa9a999a99a94949444994949994499499a9999499aa9a99949494444444454520202402540000000022484f77777777777777777777777f6f666fdd
949499aaaaa99a9a494494944499494944449499999999499aaaa9944994444444444242540540252220000000004244f77777777777777777777766f66f6666
999949aaa999a4a994994494949999949494999999994499aaaa999949444444444245452240225040400000000004249777777777777777777777f666f666f6
9944499a99faaa9a49949444499949994949994a949994499aa9a94949944444444444545254522245220000000000224f77777777777777777776ff6f66fd66
994444a9a9aaf9a99949494949499499949449a999a94994aaa99994994444444444445425404050525500000000000024f777777777777777777f66fdf66f65
9494499aa9aa9a9994999444499999999944a999949494499a99a994994444444444444452545222404200000000000005f77777777777777777f6f6f6fdf660
4994999999aa9a999994949994994a4afafa9a9949a94999aa9a99499444444444444455504522404450000000000000004f77777777777777776f6f6f6f6640
4499499aa9aa9a9999494949994aafaa9a9e9a9499999499999999949944444444444444424502445044000000000000000a777777777777777ff6f6f666f610
494999a99aa9a99949949499eaae99afaea99a999999949a9a9a999994444444444444445444222442545000000000000005f777777777777776ff6f66f66d00
499999a99a9a99999a44a4ad9aaaaffaa999a9999a999999999a994994444944499494994499444440540000000000000000af777777777777ff6f6f6f66f500
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050000000500000000000000
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
0000000000000000000000000000001f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000366403864039640196400c640066401c63020620076200464018640316302c63023620126200a6200b620086200a6000a600000000000000000000000000000000000000000000000000000000000000
000100002562422611216211f6211d6312a6312662123631296312662124621226212863125621226211f6311d63124621206111c621186111261501600006000060000600006000060000600006000060000600
000100002f6142d6212b6412a6512965129651286512765126651266412664125631226211f6111a6152860027600276002760010600156002560024600236002260021600206001f6000f6000f6001360013600
000100002563422621216311f6311d6412a6412663123641296412663124631226312864125631226311f6411d64124631206211c6311862112621226311d6211862111625016000060000600006000060000600
00010000276541a656106560a6560d6561065619656196562a6563865611646086360462505610096100961000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000366503865039650196500c650066501c6400d630076300465018640316302c62023610126100a6100b610086100a6000a600000000000000000000000000000000000000000000000000000000000000
00010000246402464011450124511346115461184611b4711e471214712647129471304410463004630056300f620106200a6000a600000000000000000000000000000000000000000000000000000000000000
000100002462024620224701f4711d4711b47119471174611546113461114610e4510b4410463004630056300f630106200e6200d6200c6100b6100b610000000000000000000000000000000000000000000000
000100000f4601346014470174701c4700d6500c6401d6301f6301660008600036000360003600036001c2001a2001f200212001a2001f200212001a2001f2001a2001f200212001a2001f200212001a2001f200
000100000f4601346014470174701c4701f470224700f4500d4301a440214500d6500c6401d6301f6301d6001f6001f200212001a2001f200212001a2001f2001a2001f200212001a2001a2001a2001f20021200
0001000015670226712f67131671326712d6612e65122651296412d641326312163120631286412765129651276512664124631206311d6311c621176111261111641106410f6310e6210d6210c6110b6110a611
0001000015670226712f67131671326712d6612e65122651296412d641326312163120631296412c651296512765125641204511e4511b4611946116461124610f4710c4710a4710747106471044710347103471
00020000142101e21012220122301c230112301c230112402c240122401824012240122401224027240132401c24016240142401f2501725017250262502f2501c2501d2502c2502224028240362402d24031240
000100001e4501e4501e4501e4501e4501e4501e4501e4501e4401e4401e4301e4301e4201e4201e4101e41022450224502245022450224502245022450224502244022440224302243022420224202241022410
00010000224502245022450224502245022450224502245022440224402243022430224202242022410224101e4501e4501e4501e4501e4501e4501e4501e4501e4401e4401e4301e4301e4201e4201e4101e410
000200003805430051250511905108041030211603114031120110f0110f0110f0012800125001220011f0011d00124001200011c001180011200501000000000000000000000000000000000000000000000000
00020000090110c021130311e04125051300513705125031150110f0110d01109004070010e001227011f7011d70124701207011c701187011270501700007000070000700007000070000700007000070000700
011000001860500000000000000030605000000000000000306050000018605256053061530625306453066518665000000000000000306750000018675000001867518603186051866530675186653067530675
011000001866500000306050000030675306000000000000306650000018665256053067525605186650000018665000000000000000306750000018645186653067518665186051866530675186653065530675
0110000018665000000000000000306752a2002a2002a2001e2001e20018645186653067518665186051864518665000001860530604306750000018665000001860318645186653060530675186653060518645
011000000647506475064550645506405064750645506455064050647506455064550640506475064550645509475094750945509455094050947509455094550b4050b4750b4750b4750b4750b4550b4550b455
01100000064750647506455064550640506475064550645506475064750645506455064050647506455064550647509475094550945509405094750945509455094750b4750b4550b4550b4050b4750b4550b455
01100000192401924019240192401924019231192301922119220192201c2411c2401e2401e24017241172401c2411c2401c2401c2401e2411e2401e2401e2401c2411b2411b2401b2401c2411c2401b2411b240
01100000192401924019240192401924019231192301922119220192201c2411c2401e2401e24017241172401c2411c2401c2401c2401e2411e2401e2401e2311e2401e2401c2411c2401e2411e2401e2401e240
01100000192401924019240192401924019231192301922119220192201e2411e2401c2401c24017241172401c2411c2401c2451c2401c2401c2451c2401c2401c2411c2401c2401c2401b2401b2401b2401b240
01100000172401724017221172401724017221172401724017240172401723117230172301722117220172201e2411e2401e2451e2401e2401e2451e2511e2501c2411c2401c2401b2401c2401b2401b2401b240
011000000b2000b2000b2000b2000b2000b2000b2000b2000b2000b2000b2000b2000b2000b20117214172211e2311e2301e2301e2301e2301e2301e2301e2301e2411e2401e2401e2401e2511e2501e2501e250
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
00 41 15 1a 11
01 41 15 16 13
00 41 15 17 13
00 41 15 18 13
02 41 14 19 12
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
