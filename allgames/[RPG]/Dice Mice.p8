pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- a dice rougelite
-- by sebastian lind

game_state = 0

game_over_width = 0
game_over_p_t = 0
game_start_again = 0
game_start = false
spawn_dices = false
start_draw_width = 128

function _init()
	palt(3, true) -- dark green is transparent
  palt(0, false)
	init_all_effects()
	setup_game()
	music(1)
end

function setup_game()
	-- player
	encounters = 1
	max_dice_nr = 6

	max_health = 42
	health = max_health
	attack = 0
	defence = 0

	current_bandage = 0
	bandage_threshold = 21
	bandage_heal_value = 10

	gained_rerolls = 1
	rerolls = gained_rerolls
	loot_pick = 0

	pick_dices = false
	attacking = false
	select_dices = false
	last_attack = false
	loot_stage = false
	show_info = false
	show_info_s = 0
	spinning = false

	attack_dice_selected = 1
	dice_selected = 1
	core_selected = 1
	attack_dices = {false, false, false, false, false}
	dices_kept = {}
	dice_picked = 0
	last_dice_picked_nr = 1 

	loot_width = 0
	s_dices_width = 10
	loot_selected = 1
	player_loot = {}
	encounter_selected = 1
	encounter1 = 1
	encounter2 = 2

	error_message_c = 0
	error_message_y = 0

	attack_circle = 0
	t = 0

	p1_shake = 0
	p1_shakex = 0
	p1_shakey = 0

	e_shake = 0
	e_shakex = 0
	e_shakey = 0
	
	p1x = 2
	p1y = 110

	-- enemy
	e1x = 120
	e1y = 117
	e_gain_attack = false
	e_shield_up = false

	-- init loot 
	loot_easy = {}
	loot_hard = {}
	for i=1, 16 do 
		add(loot_easy, i)
		add(loot_hard, i)
	end
end

function init_dices(nr)
	for i = 0, (nr-1) do 
		init_dice(64 + cos(((i+1) / 5) + 0.045) * 32, 64 + sin(((i+1) / 5) + 0.045) * 32, #dices)
	end
end

function _update60()
	foreach(effects, update_effect)
	foreach(particles, update_particle)
	foreach(texts, update_text)

	if game_state == 0 then
		update_start()
	elseif game_state == 1 then 
		update_dices()
		game_loop()
	elseif game_state >= 2 then
		update_gameover()
	end
end

function update_gameover()
	t += 0.01
	game_over_width = lerp(game_over_width, game_start_again == 0 and 128 or 0, 0.2)
	if (btnp(4) or btnp(5)) and game_over_width > 127 and game_start_again == 0 then
		game_start_again = 1
		sfx(36)
	end

	if game_start_again == 0 then
		if game_over_p_t < 4 then 
			game_over_p_t += 1
		else
			game_over_p_t = 0
			init_particle(rnd(128), rnd(128), 0.25, 1 + rnd(3), 3 + rnd(5), game_state == 2 and 9 or 11)
		end
	end

	if game_start_again == 1 and game_over_width < 112 then 
		for k,v in pairs(dices) do dices[k]=nil end
		game_start_again = 2
		start_game(false)
	end
	if game_start_again == 2 and game_over_width < 1 then 
		game_state = 1
		game_start_again = 0
	end
end

function update_start()
	t += 0.01
	if btnp(4) or btnp(5) then 
		game_start = true
		sfx(1)
	end

	if game_start then 
		start_draw_width = lerp(start_draw_width, 0, 0.2)
		if start_draw_width < 112 and not spawn_dices then
			sfx(0)
			music(0,200)
			spawn_dices = true
			start_game(true)
		end
		if start_draw_width < 1 then 
			game_state = 1
			spawn_dices = false
			game_start = false
		end
	end
end

function start_game(isFirst)
	if not isFirst then 
		for k,v in pairs(dices) do dices[k]=nil end
		init_all_effects()
		setup_game()
	end

	new_monster(true)
	init_dices(5)
	t = 0
	init_text(isFirst and "s t a r t" or "a g a i n", 64, 116, 12, 1, 40)
	for i=1,24 do 
		init_particle(rnd(128), rnd(112), 0.25, 1 + rnd(3), 3 + rnd(4), i % 2 == 0 and 1 or 1)
	end
end

function game_loop()
	t += 0.01

	attack_circle = lerp(attack_circle, attacking and 32 or 0, 0.1)
	loot_width = lerp(loot_width, loot_stage and encounters < 10 and 32 or 0, 0.1)
	e1x = lerp(e1x, attacking and 65 or 120, 0.1)
	e1y = lerp(e1y, attacking and 64 or 117, 0.1)
	s_dices_width = lerp(s_dices_width, select_dices and 16 or 10, 0.1)
	show_info_s = lerp(show_info_s, show_info and 10 or 0, 0.1)

	if e1x > 119.4 and e1x < 120 then 
		e1y = 117
		e1x = 120
		-- only get more if less than start
		if e1hp > 0 and e_gain_attack and e1attack < e1_max_attack then 
			e1attack+=1
			init_text("+1",e1x - 14, e1y - 15,11,3,30)
			sfx(43)
			for i=1,3 do 
				init_particle(e1x+rnd(16)-16, e1y+rnd(16)-16, 0.25, 1 + rnd(2), 1 + rnd(4), i % 2 == 0 and 3 or 11)
			end
		end
	end
	
	e_shakex, e_shakey, e_shake = shake_xy(e_shakex, e_shakey, e_shake)
	p1_shakex, p1_shakey, p1_shake = shake_xy(p1_shakex, p1_shakey, p1_shake)

	handle_error_message() 

	if loot_stage then 
		if loot_pick > 0 then
			loot_state()
		elseif encounters < 9 then
			encounter_state()
		elseif encounters == 9 then
			init_boss()
		end
	elseif not pick_dices then
		if not spinning and btn(4) and #dices > 0 and dices[1].state == 0 and dices[1].rsp < 0.02 then
			sfx(2)
			spinning = true
		else 
			spinning = false
		end 
		check_for_all_dices_stopped()
	elseif not attacking then
		-- choose what to keep
		if rerolls > 0 then
			if btnp(ë) then 
				find_next_selected()
			elseif btnp(ã) then 
				find_prev_selected()
			end
		end

		if #dices == 0 and #effects == 0 then -- new turn
			if rerolls > 0 and #dices_kept < 5 then 
				reroll()
			else
				sort_by_value(dices_kept)
				attacking = true
				dice_picked = 0
			end
		end
	elseif attacking and not loot_stage then
		attack_state()
	end
end

function handle_error_message() 
	if error_message_c > 0 then
		error_message_c -=1
		error_message_y = lerp(error_message_y, 13, 0.15)
	else 
		error_message_y = 0
	end
end

function reroll() 
	rerolls -= 1
	if reroll_0_kept and #dices_kept == 0 then 
		damage_enemy(10, 1)
		if (e1hp < 1)e1hp = 1 -- maybe feels a little cheated
	end
	init_dices(5 - #dices_kept)
	pick_dices = false
	dice_selected = 1
	if (reroll_heal)heal(1)
	init_text("reroll",64,50,7,13,36)
	sfx(26)
end

function should_get_loot()
	-- normally skip loot on flee
	if core_selected == 3 and flee_loot and not flee_loot_used then 
		flee_loot_used = true
		return true
	end

	return core_selected ~= 3
end

function attack_state() 
	if btnp(ë) then
		if select_dices then 
			attack_dice_selected = loopforward(attack_dice_selected, #dices_kept)
			sfx(27)
		else
			core_selected = loopbackward(core_selected, 5)
			sfx(11)
		end
	elseif btnp(ã) then
		if select_dices then 
			attack_dice_selected = loopbackward(attack_dice_selected, #dices_kept)
			sfx(28)
		else 
			core_selected = loopforward(core_selected, 5)
			sfx(10)
		end
	end
	if select_dices then 
		if last_attack and #effects == 0 then
			attacking = false
			select_dices = false
			last_attack = false
			pick_dices = false
			convert_6_power_used = false
			dice_selected = 1
			attack_dice_selected = 1
      
			if health <= 0 then -- game over
				game_state = 3
				shake+=0.2
				sfx(35)
			elseif e1hp > 0 then -- next turn
				rerolls = gained_rerolls
				init_dices(5)
			elseif encounters >= 10 then -- game won
			  shake+=0.2
				for k,v in pairs(effects) do effects[k]=nil end
				game_state = 2
				sfx(37)
			else -- loot!
				sfx(22)
				b_damage_w_hurt = 0
				b_g_block = 0
				get_loot(e1difficulty == 1)
				loot_stage = true
				local nr_loot = 1 + ((double_easy_loot and e1difficulty == 1) and 1 or 0)
				loot_pick = should_get_loot() and nr_loot or 0
			end
		end

		if btnp(4) and not last_attack and not loot_stage then
			attack_dices[attack_dice_selected] = not attack_dices[attack_dice_selected]
			sfx(attack_dices[attack_dice_selected] and 21 or 29)
		end

		if not last_attack and not loot_stage and btnp(É) then -- select all
			for i=1, #dices_kept do
				if (i <= #attack_dices)attack_dices[i] = true
			end
			sfx(21)
		end

		if not last_attack and not loot_stage and btnp(î) then -- check and make attack
			local can_do_attack = false
			error_message = ""

			local isSomeThingSelected = false
			for i=1, #attack_dices do 
				if attack_dices[i] then 
					isSomeThingSelected = true 
					break
				end
			end

			if not isSomeThingSelected then 
				error_message = "you have to select a dice"
			elseif core_selected == 1 then -- attack core
				if not do_weak_spot() then -- first check for weak spot 
					can_do_attack = do_attack()
				else 
					can_do_attack = true -- boom!
				end
			elseif core_selected == 2 then 
				can_do_attack,error_message = do_reduce()
			elseif core_selected == 3 then
				can_do_attack,error_message = do_flee()
			elseif core_selected == 4 then
				can_do_attack,error_message = do_bandage()
			elseif core_selected == 5 then
				can_do_attack,error_message = do_break()
			end

			if can_do_attack then -- remove dices
				sfx(34)
				local dices_left = {}
				local attack_dices_left = {}
				for i=1, #attack_dices do 
					if not attack_dices[i] then
						add(dices_left, dices_kept[i])
						add(attack_dices_left, false)
					end
				end

				dices_kept = dices_left
				if #dices_left > 0 and e1hp > 0 then	
					attack_dices = attack_dices_left
					attack_dice_selected = 1
					select_dices = false
				else
					last_attack = true
					attack_dices = {false, false, false, false, false}
					if e1hp > 0 then
						local damage = e1attack
						damage -= defence + b_g_block
						if (damage < 1)damage=1 -- 1 damage is the lowest!
						health -= damage
						if is_b_damage_w_hurt and b_damage_w_hurt < 6 then 
							b_damage_w_hurt+=1
							sfx(46)
							init_text("+1",p1x + 23, p1y - 11,14,2,30)
							for i=1,3 do 
								init_particle(p1x+rnd(16), p1y-rnd(5), 0.25, rnd(2), 2 + rnd(4), i % 2 == 0 and 8 or 9)
							end
						end
						if (hurt_enemy_when_hurt)damage_enemy(ceil(damage / 2), 1)
						if health < 0 and extra_life then -- survive 1 hit!
							health = 0
							heal(1)
							init_particle(p1x+rnd(16), p1y-rnd(5), 0.25, rnd(2), 2 + rnd(4), 8)
							extra_life = false
							sfx(44)
						end
						if game_state == 1 then
							for i=1, e1attack do 
								init_effect(e1x-4+rnd(8)-4, e1y-4+rnd(8)-4, p1x+rnd(8)-4, p1y+rnd(8)-4, 58, 3, 2)
							end
						end
					end
				end
			else
				error_message_c = 50
				sfx(23)
			end
		end
	end

	if not select_dices and not last_attack then
		show_info = btn(5)
		if btnp(4) then 
			select_dices = true
			show_info = false
			sfx(20)
		end
	end

	if select_dices and btnp(5) then 
		select_dices = false
		attack_dices = {false, false, false, false, false}
		sfx(30)
	end
end

function loot_state()
	if btnp(ë) then 
		loot_selected = loopforward(loot_selected, 3)
		sfx(27)
	elseif btnp(ã) then 
		loot_selected = loopbackward(loot_selected, 3)
		sfx(28)
	end

	if loot_width > 16 and btnp(4) then
		loot_pick-=1
		sfx(32)
		local loot_picked = loot[loot_selected]
		add(player_loot, loot_picked)
		get_loot_effect(loot_picked) 
		-- delete from pool so you can only 1 of each
		if loot_picked <= 16 then 
			del(loot_easy, loot_picked)
		else 
			del(loot_hard, loot_picked - 16)
		end

		init_particle(16 + #player_loot * 5, 112, rnd(1), 0.5, 2 + rnd(3), 1)
		if loot_pick == 0 then 
			new_encounter()
		else
			loot_width /= 3
			get_loot(e1difficulty == 1)
		end 
	end
end

function encounter_state() 
	if btnp(ë) then 
		encounter_selected = 2
		sfx(27)
	elseif btnp(ã) then 
		encounter_selected = 1
		sfx(28)
	end

	if btnp(4) then
		sfx(33)
		local selected_encounter = encounter_selected == 1 and encounter1 or encounter2
		encounter_decided(selected_encounter)
	end
end

function encounter_decided(encounter) 
	if encounter <= 2 then --easy / hard monste1r
		new_monster(encounter == 1)
	elseif encounter == 3 then -- rest
		resting()
	else -- random
		encounter_decided(rnd_int(3))
	end
	if (encounter < 4) then 
		init_encounter_text(encounter)
		encounters+=1
	end

	if encounter < 3 then -- set player values
		new_round()
	else 
		new_encounter()
	end
end

function resting() 
	local rest_p = rest_heal_full and 1 or 0.5
	heal(ceil(max_health * rest_p))
end

function new_round()
	rerolls = gained_rerolls
	if bonus_rerolls > 0 then 
		rerolls += bonus_rerolls
		bonus_rerolls = 0
	end
	dices_kept = {}
	dice_picked = 0

	loot_stage = false
	init_dices(5)
end

function new_monster(easy)
	local enemy_list = easy and easy_enemies or hard_enemies
	local enemy = rnd_int(#enemy_list)
	local enemy_stats = split(enemy_list[enemy])
	e1spr = (easy and 62 or 94) + enemy * 2
	e1hp = enemy_stats[1]
	if red_hp_n_encounter then 
		e1hp = ceil(e1hp / 2)
		red_hp_n_encounter = false
		init_text("half hp", e1x - 8, e1y - 24, 2, 1, 40)
	end
	e1attack = enemy_stats[2]
	e1_max_attack = e1attack + 2
	e1defence = enemy_stats[3]
	e1difficulty = enemy_stats[4]
	e_gain_attack = e1difficulty == 2 -- gain attack on hard monster
end

function init_boss() 
	if heal_before_boss then 
		heal_before_boss = false 
		heal(25)
	end
	e1spr = 46
	e1hp = 42
	e1attack = 15
	e1_max_attack = 99
	e1defence = 7
	e1difficulty = 3
	encounters = 10
	e_shield_up = true
	e_gain_attack = true
	new_round()
end

function do_attack()
	local attack_damage = 0
	local dices_active = 0
	for i=1, #attack_dices do 
		if attack_dices[i] then
			local dice_nr = dices_kept[i]
			if (dice_nr == 1 and dice_1_dd)dice_nr = 5
			attack_damage += dice_nr
			dices_active += 1
		end
	end
	
	attack_damage += attack
	attack_damage += b_damage_w_hurt
	if (attack_heals)heal(1)
	if (dd_on_low_health and health < 14)attack_damage = attack_damage * 2
	if unlucky_hit and attack_damage < 6 then 
		attack_damage = 6
		shake+=0.2
		-- add effect?
	end
	
	--do attacking!
	damage_enemy(attack_damage, dices_active)
	
	return true
end

function do_bandage()
	local bandage_values = 0
	local dices_active = 0
	for i=1, #attack_dices do 
		if attack_dices[i] then
			local dice_nr = dices_kept[i]
			bandage_values += dice_nr
			dices_active += 1
		end
	end

	for i=1, dices_active do 
		init_effect(p1x+8+cos(0.3 * rnd(1))*(16+rnd(16)), p1y+8+sin(0.3 * rnd(1))*(16+rnd(16)), p1x+8, p1y+8, 142, 2, 9)
	end
	
	current_bandage += bandage_values
	if current_bandage >= bandage_threshold then -- heal 
		current_bandage = 0
		heal(bandage_heal_value)
		p1_shake+=0.1
		sfx(49)
	end
	
	return true
end

function damage_enemy(damage, effects)
	damage -= e1defence
	if (damage < 0)damage = 0
	if not e_shield_up then -- blocks all damage!
	  e1hp -= damage
	end
	for i=1, effects do 
		init_effect(p1x+rnd(8)-4, p1y+rnd(8)-4, e1x-4+rnd(8)-4, e1y-4+rnd(8)-4, 59, 13, 1)
	end
end

function do_reduce()
	local matching = check_attack_dices(2) 

	if matching == 0 then
		return false, "only pairs allowed"
	end

	local reduce_attack = matching
	if (reduce_double)reduce_attack = reduce_attack * 2
	if e1attack == 2 then
		return false, "attack can only be as low as 2"
	end

	-- do reducing!
	e1attack -= reduce_attack
	if (e1attack < 2)e1attack = 2
	for i=1, reduce_attack do 
		init_effect(p1x+rnd(8)-4, p1y+rnd(8)-4, e1x-4+rnd(8)-4, e1y-4+rnd(8)-4, 50, 13, 1)
	end

	return true
end

function do_break() 
	local matching = check_attack_dices(3) 
	if matching == 0 then
		return false, "only trips allowed"
	end
	if e1defence == 0 then
		return false, "armor can only be as low as 0"
	end

	if (block_heals)heal(4)
	if break_b_gain_block and b_g_block < 4 then 
		b_g_block += 1
		sfx(47)
		init_text("+1",p1x + 23, p1y - 11,14,2,30)
	end
	-- do break!
	local remove_armor_value = reduce_4_block and 5 or 4
	e1defence -= remove_armor_value
	if (e1defence < 0)e1defence = 0
	init_effect(p1x+rnd(8)-4, p1y+rnd(8)-4, e1x-4+rnd(8)-4, e1y-4+rnd(8)-4, 50, 13, 1)

	return true
end

function do_weak_spot()
	local matching = check_attack_dices(easier_weak and 4 or 5) 
	if matching == 0 then
		return false
	end

	e1hp = encounters < 10 and 0 or flr(e1hp / 2)
	break_shield()
	init_effect(p1x+8, p1y+8, 64, 56, 183, 13, 4)

	return true
end

function do_flee()
	local dice_values = {false, false, false, false, false, false} -- 1 to 6
	for i=1,#attack_dices do
		if attack_dices[i] then --enabled
			if not dice_values[dices_kept[i]] then -- value has not been seen 
				dice_values[dices_kept[i]] = true
			else 
				return false, "only straight allowed"
			end
		end
	end

	local first_value = true
	local matching = 0
	for i=1, #dice_values do
		if (matching == 4) break
		if first_value then -- find marked value
			if dice_values[i] then
				first_value = false
				matching += 1
			end
		elseif dice_values[i] then 
			matching += 1
		else 
			return false, "straight of 4 or higher"
		end
	end
	
	if encounters < 10 then
		if flee_heals_rest then 
			resting()
		else 
			heal(10)
		end
		e1hp = 0
		init_text("flee!",64,16,4,2,40)
		sfx(38)

		for i=1, 12 do 
			init_particle(rnd(128), rnd(128), 0, 0, 5 + rnd(3), 0)
		end
	else
		break_shield()
		-- e1attack = flr(e1attack / 2) -- bonus for doing it the "right way"
	end

	return true
end

function break_shield()
	if encounters == 10 and e_shield_up then 
		e_shield_up = false
		sfx(41)
		init_text("destroyed!",64,32,4,2,40)
		for i=1, 16 do 
			init_particle(e1x+4+rnd(4)-2, e1y+4+rnd(4)-2, i / 16, 2 + rnd(3), 3 + rnd(2), i % 2 == 0 and 14 or 2)
		end
	end
end

function check_attack_dices(nr) 
	local matching = 0
	local prev_value = -1

	for i=1, #attack_dices do 
		if attack_dices[i] then
			if prev_value == -1 or prev_value == dices_kept[i] then
				matching += 1
				prev_value = dices_kept[i]
				if nr == 2 and matching == 2 then -- special rule for pair
					prev_value = -1
				end
			else
				return 0 -- did not match
			end
		end
	end

	if nr == 2 and not (matching == 2 or matching == 4) then -- 1 or 2 pairs allowed
		return 0
	elseif nr ~= 2 and matching ~= nr then 
		return 0
	end

	return matching
end

function check_for_all_dices_stopped() 
	local all_stopped = true
	if (#dices <= 0)all_stopped = false
	for d in all(dices) do 
		if d.state ~= 2 then 
			all_stopped = false
		end
	end
	if all_stopped then
		pick_dices = true
		sortByX(dices)
		dice_selected = 1
		dices[dice_selected].selected = true
	end
end

function select_dice()
	for i=1,#dices do
		if (dices[i] ~= nil)dices[i].selected = i == dice_selected
	end
end

function find_next_selected() 
	dice_selected = loopforward(dice_selected, #dices)
	select_dice()
	sfx(5)
end

function find_prev_selected() 
	dice_selected = loopbackward(dice_selected, #dices)
	select_dice()
	sfx(6)
end

function find_new_selected() 
	if (dice_selected > #dices)dice_selected = 1
	select_dice()
end

function new_encounter()
	if rest_option then 
		encounter1 = 3
	else 
		encounter1 = random_encounter(false)
	end
	encounter2 = random_encounter(true)
	loot_width = encounters < 9 and loot_width / 3 or loot_width
	if (heal_on_n_encounter)heal(4)
end

-- not really random, favoring the player
function random_encounter(isSecond)
	local r_e = rnd_int(4)

	if not isSecond or r_e ~= encounter1 then
		return r_e
	elseif encounter1 == 2 then 
		return 3
	elseif encounter1 == 4 then 
		return 1
	else
		return 4
	end
end

function heal(amount)
	health += amount
	sfx(45)
	if (health > max_health)health = max_health
	local max = amount <= 10 and amount or 10
	for i=1, max do 
		init_particle(p1x+8+rnd(16)-8, p1y+8+rnd(16)-8, 0.25, 1 + rnd(2), 1 + rnd(4), i % 2 == 0 and 3 or 11)
	end
end

function get_loot(easy)
	loot = {}
	-- here is were I found out copy a table is a reference and not a copy...
	local s = shallow_copy(easy and loot_easy or loot_hard)
	for i=1, 3 do 
		local l = s[rnd_int(#s)]
		add(loot, easy and l or l + 16)
		del(s, l)
	end
end

function _draw()
	cls(0)
	draw_background()
	if game_state == 1 then 
		draw_pentagon()
		rectfill(0,0, 128, s_dices_width, 0)
	end
	foreach(texts, draw_text)
	camera_shake()
	if (game_state == 1 or spawn_dices)foreach(particles, draw_particle)
	foreach(dices, draw_dice)
	foreach(dices, draw_dice_ui)
	foreach(effects, draw_effect)

	-- ui
	camera()
	if game_state == 1 or spawn_dices then 
		local space = max(s_dices_width * 0.7 + 2, 10)
		local sp_h = max(s_dices_width * 0.45 - 2, 2)

		print(dbg, 92, sp_h, 2) --debug
		if encounters < 10 then 
			print(encounters .. "/9", 116, sp_h + 1 , 12)
		else 
			spr(139, 116, sp_h + 1)
		end
		spr(182, 107, sp_h + 1)

		draw_player()
		draw_enemy()
		draw_controls()

		for i=1, #dices_kept do 
			spr(31 + dices_kept[i], sp_h + 1 + (i - 1) * space, sp_h)
		end
		if select_dices and #dices_kept > 0 then
			for i=1, #attack_dices do 
				if (attack_dices[i])rect(sp_h + (i - 1) * space, sp_h - 1, sp_h + (i - 1) * space + 8, sp_h + 7, 13)
			end
			fillp(Å)
			rect(sp_h -1 + (attack_dice_selected - 1) * space, sp_h - 2, sp_h - 1 + (attack_dice_selected - 1) * space + 10, sp_h + 8, 12)
			fillp()
		end
		if attacking then
			if (error_message_c > 0 and error_message_y > 6)print(error_message, 2, 14 + error_message_y, 8)
			draw_core_ui()
			if (show_info and s_dices_width < 11)draw_info_ui()
		end 
		
		if loot_stage or loot_width > 2 then
			draw_loot_stage()
		end
	end

	if game_state == 0 then
		draw_start_game()
	elseif game_state > 1 then
		draw_game_over()
	end

	--line(0,64,128,64,8)
	--line(64,0,64,128,8)
end

function draw_game_over()
	rectfill(0,0,128, game_over_width, game_state == 2 and 1 or 2)
	foreach(particles, draw_particle)
	spr(128,8, game_over_width - 116 - sin(t)*2.1,5,2)
	if (game_start_again == 0)rspr(112, game_state == 2 and 80 or 96, 16, 16, sin(t/ 2) * 0.1, 64, 64, 56, 56)
	spr(game_state == 2 and 133 or 160,70, game_over_width - 116 + sin(t)*2.1, 6, 2)

	local game_over_str = game_state == 3 and "try again é/ó" or "play again é/ó"
	if (abs(sin(t / 2)) % 2 >= 0.3)print(game_over_str, 60 - #game_over_str * 2, game_over_width - 8, 0)
end

function draw_start_game()
	fillp(ï)
	rectfill(0,0,128, start_draw_width, 1)
	local circ_s = sin(t)*6.1 + start_draw_width - 80
	circfill(64,64, circ_s, 13)
	fillp()
	
	if not spawn_dices then 
		rspr(6 * 16, 0, 16, 16, t / 2, 64, 64, 56, 56)
		spr(174, 56 + cos(t/3) * circ_s,  56 + sin(t/3) * circ_s, 2, 2)
		spr(206, 56 + cos(t/3 - 0.5) * circ_s,  56 + sin(t/3 - 0.5) * circ_s, 2, 2)

		if (abs(sin(t / 2)) % 2 >= 0.3)print("press é/ó", 43, 4, 13)
		print("sebastian lind @elastiskalinjen", 2, start_draw_width - 7, 7)
	end
	
	spr(168, 40, start_draw_width - 80 + sin(t)*2.1, 6, 4)
end

function draw_player()
	spr(44, p1x + p1_shakex, p1y + sin(t) * 2.1 + p1_shakey, 2, 2)
	
	if not show_info or s_dices_width > 11 then -- stats
		print(health, p1x + 9 - (health > 9 and 2 or 0), p1y - 10, 14)
		spr(42,p1x, p1y - 11)
		spr(16, p1x + 18, p1y-3)
		print(attack + b_damage_w_hurt, p1x + 25, p1y-3, 14)
		spr(17, p1x + 18, p1y + 5)
		print(defence + b_g_block, p1x + 25, p1y+5, 14)
	end

	for i=1, #player_loot do
		spr(223 + player_loot[i], 25 + i * 7 - (i > 9 and 63 or 0), 112 - (i > 9 and 8 or 0))
	end
end

function draw_enemy()
	if e1hp > 0 or #effects > 0 then
		spr(e1spr, e1x - 8 + e_shakex, e1y - 8 + e_shakey + cos(t) * 1.9, 2, 2)
		if not attacking and e1y > 112 then
			spr(43, e1x - 9, e1y - 18) 
			print(e1hp, e1x - 2, e1y - 17, 11)
			spr(166, e1x - 17, e1y - 10)
			print(e1attack, e1x - 23 + (e1attack < 10 and 4 or 0), e1y-10, 11)
			spr(167, e1x - 17, e1y - 2)
			print(e1defence, e1x - 23 + (e1defence < 10 and 4 or 0), e1y-2, 11)
		else 
			if e_shield_up then 
				circ(e1x, e1y + cos(t) * 1.9, 12, 14)
				fillp(Å)
				circfill(e1x - 5, e1y - 8 + cos(t) * 1.9, 2, 7)
				fillp()
			end
		end
	end
end

function draw_loot_stage()
	rectfill(0, 64 - loot_width, 128, 64 + loot_width, loot_pick > 0 and 1 or 2)
	if loot_width > 12 then
		local title = loot_pick > 0 and "- select loot -" or "choose your next encounter"
		print(title, 64 - #title * 2, 64 - loot_width + 2, loot_pick > 0 and 7 or 0)
		
		if loot_pick > 0 then
			local enemyd_text = "monster destroyed"
			print(enemyd_text, 64 - #enemyd_text * 2, 64 - loot_width + 9, 0)
			
			for i=1, 3 do 
				if loot_selected == i then 
					spr(39, -6 + i * 32, 52)
					local loot_desc = loot_text[loot[i]]
					print(loot_desc, 64 - #loot_desc * 2, 64 + loot_width - 6, 12)
				end
				local bounce = loot_selected == i and sin(t)*1.1 or 0
				spr(223 + loot[i], -6 + i * 32, 64 + bounce)
			end
		elseif encounters < 10 then
			spr(40, encounter_selected == 1 and 36 or 84, 44 + sin(t)*2.1)
			spr(190 + encounter1 * 2, 32, 56 - (encounter_selected == 1 and sin(t)*0.9 or 0), 2, 2)
			spr(190 + encounter2 * 2, 80, 56 - (encounter_selected == 2 and sin(t)*0.9 or 0), 2, 2)
			fillp(Å)
			line(16,72,112,72,0)
			fillp()
			local encounter_desc = encounter_text[encounter_selected == 1 and encounter1 or encounter2]
			print(encounter_desc, 64 - #encounter_desc * 2, 64 + loot_width - 6, 14)
		end
	end
end

function draw_controls()
	rectfill(0,121,128,128, 0)
	local control_t = ""
	if pick_dices and not attacking then 
		control_t = "ã ë | keep é | remove ó"
	elseif #dices > 0 and dices[1].state == 0 then
		control_t = "spin é"
	elseif attacking and not select_dices then 
		control_t = "ã ë | choose: é | help ó"
	elseif attacking and select_dices then 
		control_t = "ã ë | pick é | confirm î"
	elseif loot_stage then
		control_t = loot_pick > 0 and "ã ë | pick: é" or "ã ë | choose: é"
	end

	print(control_t, 2, 122, 12)
end

p=14790.5
o=~p+.5

function draw_background()
	for i=0,3 do
		local j = (i*39 - 0.5) - 17
		fillp(p)
		rectfill(j, 0, j + 8, 128, 1)
		fillp(o)
		local l = (i*39 - 0.5) - 17
		rectfill(0, l, 128, l+8, 1)
	end
	fillp()
end

function move_background()
	return (#dices > 0 and dices[1].state == 0) or (attacking and not select_dices)
end

function draw_pentagon()
	for i = 0, 4 do
		local x = 64 + cos(((i + 1) / 5) + 0.045) * 32
		local y = 64 + sin(((i + 1) / 5) + 0.045) * 32

		local iscoreSelected = core_selected - 1 == i and attacking
		local bounce = (iscoreSelected and not select_dices) and sin(t) * 0.9 or 0
		local c_size = 4 + (attack_circle / 9) + bounce
		
		if attacking then
			local cx = 64 + cos(((i + 1) / 5) + 0.045) * attack_circle
			local cy = 64 + sin(((i + 1) / 5) + 0.045) * attack_circle
			line(cx, cy, 64, 64, iscoreSelected and 2 or 13)
		end

		circfill(x, y, c_size, iscoreSelected and 2 or 13)
		if attacking then
			local blink = (iscoreSelected and not select_dices and ceil(bounce) == 1) and 1 or 0
			if encounters == 10 and i == 2 then -- draw an unique symbol
				spr(141 - blink, x - 4, y - 4)
			else 
				spr(49 + i * 2 - blink, x - 4, y - 4)
			end

			if iscoreSelected then 
				local a = angle(x, y, e1x, e1y)
				local core_value = ""
				if core_selected == 1 and e1hp > 0 then 
					core_value = "".. e1hp
				elseif core_selected == 2 then 
					core_value = "" .. e1attack
				elseif core_selected == 5 then 
					core_value = "".. e1defence
				end
				print(core_value, e1x - #core_value * 2 + cos(a) * 16, e1y - 6 + sin(a) * 16, 7)
			end
		end
	end

	-- center dot
	local center_size = attacking and 7 - attack_circle / 4 or 7
	circfill(64, 64, center_size, 13)
	if (not attacking)print(rerolls, 63,62, 7)
end

function draw_core_ui()
	rectfill(0, s_dices_width + 2, 128, s_dices_width + 8, 1)
	local core_desc = ""
	if core_selected == 1 then 
		core_desc = "heart core | damage by: value"
	elseif core_selected == 2 then
		core_desc = "attack core | limit by: pairs"
	elseif core_selected == 3 then
		if encounters > 9 then 
			core_desc = "break core | crack by: straight"
		else
			core_desc = "run core | flee by: straight"
		end
	elseif core_selected == 4 then 
		core_desc = "bandage core | heal by: " .. current_bandage .. "/" .. bandage_threshold 
	elseif core_selected == 5 then 
		core_desc = "defence core | remove by: trips"
	end
	print(core_desc, 2, s_dices_width + 3, 13)
end

function draw_info_ui()
	if (show_info_s > 8)spr(155,18,111 + sin(t) * 2.1)
	for i=0,7 do 
		circfill(30 + i * 12, 110 + sin(i / 3)*1.1, show_info_s + (i % 2 == 1 and 1 or 0), 7)
	end
	local core_info = ""
	if core_selected == 1 then 
		core_info = "lower the monster's hp\nto zero to defeat him!"
	elseif core_selected == 2 then
		core_info = "hit this core to limit\nthe monster's attack."
	elseif core_selected == 3 then 
		if encounters > 9 then
			core_info = "there is a crack in his\ndefences here..."
		else
			core_info = "you will flee from the\nfight but get no loot..."
		end
	elseif core_selected == 4 then
		if encounters > 9 then 
			core_info = "might not defeat him\nbut will still hurt him!"
		else
			core_info = "keep hitting this core\nto heal " .. bandage_heal_value .. " hp!"
		end
	elseif core_selected == 5 then 
		core_info = "hit this core to remove\nthe monster's armor."
	end
	if (show_info_s > 8)print(core_info, 24, 104, 0)
end

-->8
-- dice

dices={}
function init_dice(x, y, id) 
	local d = {
		ox = x,
		x = x,
		oy = y,
		y = y,
		spr = 0,
		a = 0,
		ta = 0,
		rsp = 0,
		state = 0,
		number = 1,
		angle_max_speed = 0.04 + rnd(3) / 100,
		dice_nr_speed = rnd(2) / 10,
		id = id,
		selected = selected
	}
	add(dices, d)
end

function update_dices()
	for k,d in pairs(dices) do
		update_dice(d)
		for k,od in pairs(dices) do
			dice_collision(d, od)
		end
	end
end

function dice_collision(d, od) 
	if not pick_dices and d.state >= 1 and od.state >= 1 and d.id ~= od.id and circ_collision(d.x, d.y, 8, od.x, od.y, 8) then 
		shake+=0.01
		d.x = d.ox
		d.y = d.oy
		od.x = od.ox
		od.y = od.oy
		if(d.state == 1)d.number += rnd(2) / 10
		if (od.stated == 1)od.number += rnd(2) / 10
		sfx(4)

		if d.rsp > od.rsp then 
			d.rsp *= 0.7
			d.rsp += od.rsp / 20
			od.rsp = d.rsp
			od.a = d.a + rnd(1) / 100
			d.a += 0.5
			od.rsp *= 0.75
		else
			od.rsp *= 0.7
			od.rsp += d.rsp / 20
			d.rsp = od.rsp
			d.a = od.a + rnd(1) / 100
			od.a += 0.5
			d.rsp *= 0.75
		end
	end 
end

function update_dice(d)
	d.ox = d.x 
	d.oy = d.y
	if d.state == 0 then 
		if btn(4) then
			if d.rsp < d.angle_max_speed then 
				d.rsp += 0.0012 
			end
		else 
			if d.rsp > 0.02 then 
				d.state = 1
			else
				d.rsp = lerp(d.rsp, 0, 0.01)
			end
		end
		d.a -= d.rsp
	elseif d.state == 1 then 
		d.x += d.rsp * 60 * cos(d.a)
		d.y += d.rsp * 60 * sin(d.a)
		-- bounce random
		local outside = false
		if d.x < 8 then
			d.x = 8
			outside = true
		end
		if d.x > 120 then
			d.x = 120
			outside = true
		end
		if d.y < 24 then
			d.y = 24
			outside = true
		end
		if d.y > 100 then
			d.y = 100
			outside = true
		end
		if outside then 
			-- sound
			new_bounce_angle(d)
		end
		
		if d.number < max_dice_nr then 
			d.number += d.dice_nr_speed + d.rsp * 2
		else 
			d.number = 1
		end

		if d.rsp > 0.005 then 
			d.rsp -= 0.00018
		else 
			d.state = 2
			d.number = rou(d.number)
			d.ta = flr(d.a)
		end
	elseif d.state == 2 then
		if d.selected then
			d.a = lerp(d.a, d.ta, 0.1)
			
			if rerolls <= 0 or btnp(4) then -- keep
				d.state = 3
				if (d.number == 7)d.number = 1
				sfx(7)
			elseif btnp(5) then -- remove
				if d.number == 7 then -- copy
					d.state = 3
					d.number = last_dice_picked_nr
					shake+=0.05
					sfx(48)
					init_particle(d.x+rnd(4)-rnd(4), d.y+rnd(4)-rnd(4),0.25, 1.5, 3 + rnd(2), 2)
				elseif convert_6_power and not convert_6_power_used then --transmute
					d.state = 3
					d.number = 6
					convert_6_power_used = true
					shake+=0.05
					sfx(9)
					init_particle(d.x+rnd(4)-rnd(4), d.y+rnd(4)-rnd(4),0.25, 1.5, 3 + rnd(2), 10)
				else
					d.state = 4
					sfx(8)
				end
			end
		end
	elseif d.state == 3 then 
		init_effect(d.x, d.y, 4 + dice_picked * 12, 2, 31 + d.number, 13, 0)
		dice_picked += 1
		last_dice_picked_nr = d.number
		del(dices, d)
		find_new_selected()
	elseif d.state == 4 then 
		for i=0,4 do
			local c = i == 0 and 7 or 13
			init_particle(d.x+rnd(4)-rnd(4), d.y+rnd(4)-rnd(4),rnd(1), 1, 2 + rnd(2), c)
		end
		del(dices, d)
		find_new_selected()
	end
end

function new_bounce_angle(d)
	d.a = d.a + (rnd(25) / 100)
	d.rsp *= 0.85
	init_particle(d.x+rnd(4)-rnd(4), d.y+rnd(4)-rnd(4), rnd(1), 1, 1 + rnd(2), 7)
	sfx(3)
end

function draw_dice(d)
	-- rspr(8, 0, 8, 8, d.a, d.x, d.y, 17, 17)
	rspr(rou(d.number) * 16, 0, 16, 16, d.a, d.x, d.y, 17, 17)
	-- circ(d.x, d.y, 8, 8)
end

function draw_dice_ui(d)
	if d.state == 2 then 
		if rerolls > 0 and d.selected then 
			fillp(Å)
			rect(d.x - 8, d.y - 8, d.x + 8, d.y + 8, 12)
			fillp()
		end
		print(d.number < 7 and d.number or "?", d.x - 2 , d.y - 15, 12)
	end
end

-->8
-- draw a rotated, scaled
-- sprite at dy,dy with dw,dh
-- as dimensions
--     sx,sy,sw,sh - pos,dimensions
--     in spritesheet
--     a - angle
--     dx,dy,dw,dh - pos,dimensions
--     on screen
-- serious performance issues
-- with large values of dw,dh
function rspr(sx,sy,sw,sh,a,dx,dy,dw,dh)
	sx,sy,sw,sh,a,dx,dy,dw,dh=
		sx or 0, sy or 0,
		sw or 8, sh or 8,
		a or 0,
		dx or 0, dy or 0,
		dw or 8, dh or 8
	
	local s1,c1 = sin(a+0.125),cos(a+0.125)
	local half_dw,half_dh = dw/2,dh/2
	local x1,y1 = half_dw*c1,half_dh*s1
	local x2,y2 = half_dw*s1,half_dh*-c1
	local x3,y3 = half_dw*-c1,half_dh*-s1
	local x4,y4 = half_dw*-s1,half_dh*c1

	local dx1,dy1=(x4-x1)/dh,(y4-y1)/dh
	local dx2,dy2=(x3-x2)/dh,(y3-y2)/dh
			
	local dtxx,dtxy=(x1-x2)/dw,(y1-y2)/dw

	local dsx,dsy=sw/dw,sh/dw
	for y=0,dh-1 do
		local ssx,px,py=sx,dx+x2,dy+y2
		for x=0,dw-1 do
			local col=sget(ssx,sy)
			if (col ~= 3)pset(px,py,col)
			px+=dtxx
			py+=dtxy
			ssx+=dsx
		end
		sy+=dsy
		x2+=dx2
		y2+=dy2
	end
end

-->8
-- help

shake=0
is_shake=true
cam_x = 0
cam_y = 0
function camera_shake()
	if is_shake then
		local shakex=16-rnd(32)
		local shakey=16-rnd(32)
	
		shakex*=shake
		shakey*=shake
		camera(cam_x + shakex, cam_y + shakey)
		shake=shake*0.95
		if(shake > 0.2)shake=0.18
		if(shake < 0.05)shake=0
	end
end

function shake_xy(x, y, value)
	local shakex=8-rnd(16)
	local shakey=8-rnd(16)
	shakex*=value
	shakey*=value
	x=shakex
	y=shakey
	value=value*0.9
	if (value < 0.04)value=0
	return x, y, value
end

function distance(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

function circ_collision(x1,y1,rad1,x2,y2,rad2)
	return distance(x1,y1,x2,y2) < rad1+rad2
end

function rect_colllision(ax,ay,aw,ah,bx,by,bw,bh)
	return not ((ax > bx+bw) or (ax+aw < bx) or (ay > by+bh) or (ay+ah < by))
end

function angle(x1,y1,x2,y2)
 	return atan2(x1-x2,y1-y2)
end

function lerp(var,target,pow)
	return var+pow*(target-var)
end

function rou(x) return flr(x+.5) end

function sortByX(a)
   for i=1,#a do
			local j = i
			while j > 1 and a[j-1].x > a[j].x do
				a[j],a[j-1] = a[j-1],a[j]
				j = j - 1
			end
   end
end

function sort_by_value(a)
   for i=1,#a do
			local j = i
			while j > 1 and a[j-1] > a[j] do
				a[j],a[j-1] = a[j-1],a[j]
				j = j - 1
			end
   end
end

function shallow_copy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
				copy[orig_key] = orig_value
			end
	else -- number, string, boolean, etc
		copy = orig
	end
  return copy
end

function loopforward(value, threshold)
	return value < threshold and value + 1 or 1
end

function loopbackward(value, threshold)
	return value > 1 and value - 1 or threshold
end

function rnd_int(value)
	return flr(rnd(value)) + 1
end

-->8
--particles
particles={}
function init_particle(x,y,angle,speed,rad,col)
	local p={
		x = x,
		y = y,
		angle = angle,
		speed = speed,
		rad = rad,
		col = col
	}
	add(particles,p)
end

function update_particle(p)
	p.speed*=0.9
	p.x+=p.speed*cos(p.angle)
	p.y+=p.speed*sin(p.angle)
	local speed = p.rad > 5 and 0.4 or 0.09
	p.rad -= speed
	if(p.rad <=0)del(particles,p)
end

function draw_particle(p)
	if (p.rad < 2)fillp(Å)
	circfill(p.x,p.y,p.rad,p.col)
	fillp()
end

effects={}
function init_effect(x,y,ex,ey,spr,col,type)
	local slower = type == 2 and 0.7 or 1
	if (type == 4)slower = 1.5
	local e={
		x = x,
		y = y,
		ex = ex, 
		ey = ey,
		lx = x + 4,
		ly = y + 4,
		spr = spr,
		col = col,
		speed = (0.1 + (flr(rnd(12)) / 100)) * slower,
		type = type,
	}
	add(effects,e)
end

function update_effect(e)
	if not e.stop then 
		e.x = lerp(e.x, e.ex, e.speed)
		e.y = lerp(e.y, e.ey, e.speed)

		e.lx = lerp(e.lx, e.x+4, 0.12)
		e.ly = lerp(e.ly, e.y+4, 0.12)	
		
		if distance(e.x, e.y, e.ex, e.ey) < 4 then
			if e.type == 0 then 
				add(dices_kept, e.spr - 31)
			else
				init_particle(e.x+4+rnd(4)-2, e.y+4+rnd(4)-2, rnd(1), 1 + rnd(2), 2 + rnd(2), e.type == 1 and 11 or 14)
			end
			if e.type == 1 then 
				if (not e_shield_up)e_shake += 0.1
				sfx(e_shield_up and 42 or 25)
			elseif e.type == 2 then 
				p1_shake += 0.04
				sfx(24)
			elseif e.type == 4 then 
				shake += 0.2
				sfx(40)
				init_text("boom!!!", 64, 20, 11, 1, 40)
				for i=1, 16 do 
					init_particle(e1x+4+rnd(4)-2, e1y+4+rnd(4)-2, i / 16, 4 + rnd(4), 4 + rnd(3), i % 2 == 0 and 11 or 1)
				end
			end
			del(effects, e)
		end
	end
end

function draw_effect(e)
	fillp(Å)
	line(e.lx, e.ly, e.x+4, e.y+4, e.col)
	fillp()
	spr(e.spr, e.x, e.y)
end

texts={}
function init_text(text,x,y,c1,c2,d)
	local t={
		text=text,
		x=x,
		y=y,
		c=c1,
		c2=c2,
		sd=d,
		d=d
	}
	add(texts, t)
end

function update_text(t)
	if t.d > 0 then 
		t.d-=1
		t.y-=0.1
		if t.d < t.sd / 2 then 
			t.c = t.c2
		end
	else 
		del(texts, t)
	end
end

function draw_text(t)
	print(t.text, t.x - #t.text * 2, t.y, t.c)
end

dbg= ""
function debug(value) 
	dbg = value
end

loot_text = {
	-- easy
	"gain 1 armor",
	"gain 7 hp",
	"heal 18 hp",
	"gain 2 attack",
	"gain 2 temporary rerolls",
	"next monster's hp is halved",
	"heal 4 hp on every new encounter",
	"removing armor also heals 4 hp",
	"bandages now heals for 15 hp",
	"survive 1 hit that would kill",
	"heal 25 hp before boss",
	"rest is always an encounter",
	"rerolling heals 1 hp",
	"remove 5 armor instead of 4",
	"every 1 dice now deals 5 dmg",
	"1 flee still gets you loot",
	-- hard
	"gain 1 more reroll",
	"heal 1 hp on every attack",
	"bomb can be hit by quads",
	"deal 2x damage more if hp < 14",
	"gain +1 attack when hurt, max=6",
	"you can now roll a copy dice",
	"resting now heals to full",
	"remove 1 dice to make it a 6",
	"reroll when 0 kept deals 10 dmg",
	"two pairs limits twice as much",
	"pick 2 normal loot instead of 1",
	"gain +1 armor on removal, max=4",
	"flee heals you as resting does",
	"dealing < 6 now deals 6 dmg",
	"reflect back half the dmg taken",
	"jump to the boss and heal 10 hp",
}

function init_all_effects() 
	red_hp_n_encounter = false
	heal_on_n_encounter = false
	block_heals = false
	extra_life = false
	heal_before_boss = false
	rest_option = false
	reroll_heal = false
	reduce_4_block = false
	dice_1_dd = false
	flee_loot = false
	flee_loot_used = false
	attack_heals = false
	easier_weak = false
	dd_on_low_health = false
	is_b_damage_w_hurt = false
	b_damage_w_hurt = 0
	rest_heal_full = false
	convert_6_power = false
	convert_6_power_used = false
	reroll_0_kept = false
	reduce_double = false
	double_easy_loot = false 
	break_b_gain_block = false
	b_g_block = 0
	flee_heals_rest = false
	unlucky_hit = false
	hurt_enemy_when_hurt = false
	bonus_rerolls = 0
end

function get_loot_effect(loot)
	if loot == 1 then
		defence += 1
	elseif loot == 2 then 
		max_health += 7
		heal(7)
	elseif loot == 3 then 
		heal(18)
	elseif loot == 4 then 
		attack += 2
	elseif loot == 5 then 
		bonus_rerolls = 2
	elseif loot == 6 then 
		red_hp_n_encounter = true
	elseif loot == 7 then 
		heal_on_n_encounter = true
	elseif loot == 8 then 
		block_heals = true
	elseif loot == 9 then 
		bandage_heal_value = 15
	elseif loot == 10 then 
		extra_life = true
	elseif loot == 11 then 
		heal_before_boss = true
	elseif loot == 12 then 
		rest_option = true
	elseif loot == 13 then 
		reroll_heal = true
	elseif loot == 14 then 
		reduce_4_block = true
	elseif loot == 15 then 
		dice_1_dd = true
	elseif loot == 16 then 
		flee_loot = true
	elseif loot == 17 then 
		gained_rerolls += 1
	elseif loot == 18 then 
		attack_heals = true
	elseif loot == 19 then 
		easier_weak = true
	elseif loot == 20 then 
		dd_on_low_health = true
	elseif loot == 21 then 
		is_b_damage_w_hurt = true
	elseif loot == 22 then 
		max_dice_nr = 7
	elseif loot == 23 then 
		rest_heal_full = true
	elseif loot == 24 then 
		convert_6_power = true
	elseif loot == 25 then 
		reroll_0_kept = true
	elseif loot == 26 then 
		reduce_double = true
	elseif loot == 27 then 
		double_easy_loot = true
	elseif loot == 28 then 
		break_b_gain_block = true
	elseif loot == 29 then 
		flee_heals_rest = true
	elseif loot == 30 then 
		unlucky_hit = true
	elseif loot == 31 then 
		hurt_enemy_when_hurt = true
	elseif loot == 32 then 
		encounters = 9
		heal(10)
		sfx(39)
	end
end

encounter_text = {
	"a monster - plain and simple",
	"monster leader - better loot",
	"rest - heal for 50 % of hp",
	"random - what can it be?"
}

function init_encounter_text(encounter)
	local e_text = "resting!"
	if encounter == 1 then 
		e_text = "monster"
	elseif encounter == 2 then 
		e_text = "leader"
	end
	init_text(e_text,64,16,14,2,40)
end

-- hp, attack, defence, difficulty (don't touch this)
easy_enemies = {
	"27,7,15,1", -- trash blob

	"61,9,3,1", -- donut

	"34,14,2,1", -- silverfisk

	"26,15,4,1", -- hotdog

	"55,8,5,1", -- banana

	"45,12,3,1", -- possum

	"72,10,0,1", -- poop

	"1,9,25,1", -- spider
}

hard_enemies = {
	"50,13,4,2", -- drunk

	"28,25,0,2", -- fly

	"40,11,6,2", -- fox

	"30,9,11,2", -- trash panda

	"46,10,5,2", -- moose

	"5,5,26,2", -- seagull

	"80,8,1,2", -- bear

	"35,6,16,2", -- fish
}
__gfx__
00000000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
0000000077777777777777777777777777dd77777777777777dd77777777777777dd77777777dd7777dd77777777dd7777dd77777777dd7777777dddddd77777
007007007777777777777777777777777d6dd777777777777d6dd777777777777d6dd777777d6dd77d6dd777777d6dd77d6dd777777d6dd77777d77dd77d7777
000770007777777777777777777777777dddd777777777777dddd777777777777dddd777777dddd77dddd777777dddd77dddd777777dddd7777d77777777d777
0007700077777777777777777777777777dd77777777777777dd77777777777777dd77777777dd7777dd77777777dd7777dd77777777dd7777d7777777777d77
00700700777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777d777777777777d7
00000000777777777777777dd777777777777777777777777777777dd777777777777777777777777777777dd777777777dd77777777dd777d77777dd77777d7
0000000077777777777777d6dd7777777777777777777777777777d6dd7777777777777777777777777777d6dd7777777d6dd777777d6dd77dd777d6dd777dd7
3333e333eeeeee33777777dddd7777777777777777777777777777dddd7777777777777777777777777777dddd7777777dddd777777dddd77dd777dddd777dd7
333e3333e3333e337777777dd777777777777777777777777777777dd777777777777777777777777777777dd777777777dd77777777dd777d77777dd77777d7
e3e33333e3333e337777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777d777777777777d7
3e3333333e33e3337777777777777777777777777777dd77777777777777dd7777dd77777777dd7777dd77777777dd7777dd77777777dd7777d7777777777d77
e3e3333333ee3333777777777777777777777777777d6dd777777777777d6dd77d6dd777777d6dd77d6dd777777d6dd77d6dd777777d6dd7777d77777777d777
3333333333333333777777777777777777777777777dddd777777777777dddd77dddd777777dddd77dddd777777dddd77dddd777777dddd77777d77dd77d7777
33333333333333337777777777777777777777777777dd77777777777777dd7777dd77777777dd7777dd77777777dd7777dd77777777dd7777777dddddd77777
33333333333333337777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
377777333777773337777733377777333777773337777733377777333cccccc333300333333333333333333333333333333ee3444443ee333344433333444333
77777773707777737077777370777073707770737077707377000773cccccccc3300003333cccc333e33e3333b33b333333e2e44444e2e33334f4424444f4333
77777773777777737777777377777773777777737777777370777073cc3333cc333003333c3333c3eeeeee33bbbbbb333333e4404440e3333334044044443333
77707773777777737770777377777773777077737077707370707073c333333c333003333c3333c3eeeeee33bbbbbb33e3334444444443333334444424443333
77777773777777737777777377777773777777737777777370777073cc3333cc3300003333c33c333eeee3333bbbb33332334e44444444333334444444443334
777777737777707377777073707770737077707370777073770007733cc33cc330000003333cc33333ee333333bb33333e334444444444433344ee4444443343
3777773337777733377777333777773337777733377777333777773333cccc3330033003333333333333333333333333323344ffff44444e3347887844433343
33333333333333333333333333333333333333333333333333333333333cc333303333033333333333333333333333332e3377fffff763333348888844773344
366336633333333333336366333333663333333333333333666633333666333336666663363333633333333b333333e33233d76dd776d33333341144467d3343
666666663363363333363666333336663333366333333663633363336333633363333336636666363333b3b333333eeee3317d776ddd1133336644d677d72334
666666663666666333636663333366633363366663333666633636336336363363666636633333363333bb333333ee3e3211111666d11ee332226d6662222243
66666666366666636336663663366633333336633333366363633363636663636366663636366363333bbbb3333ee33e311ee1111dd11eee22222dd222222223
3666666336666663366363633666633366363663633366663633363636366636633333363633336333bbb333333e33e3311eeee1116112e22442262222224423
366666633366663333663633336633333333666633363663336363363363633663333336633333363bbb333333e333331112ee21111111214442222222444422
33666633333663333636333336363333663336633333366333363336333633363633336336333363bbb333333e3333331111221111d1111114122d2222144122
33366333333333336333633363336333333363333333333633336666333366633366663333666633bb333333e333333311111111111111112122222222211222
3333336dd333333333333ffffff33333393333333333339333333388333333333333333340333333333337555731333333333333444333333333333333333333
333ddddddddd333333377eaee77f3333339366d555553933333338888f3333333333333443333333333370757071333333333334443333333333333333333333
33377711707b3333337007ee7007f333333d5555555553333333f8888f3333333333333493333333333337dfd7f33333333333444433333333253333333352d3
33b707bb777bb333337077ff7707ef3333277255552772333333f8778ff33333333333aa933333333636ffffff53333333333344443333333233533333353323
33bb7b88b7bbbb333ad77dffd77deef323700755557007323333f7007ff33333333333779333333333fffffff553333333333444443333333233530053533323
33bbb2222bbbbb33ffa11f88f11febff22700755557007223333f1771ff3333333333707793333333efff555555533333333f444444333335333507705332335
335b55555bbbb5d3faf333ff333ffecf22d77d5555d77d223333f2112fff333333333700793333333388665555553333333f0f244f2443335353071170353535
3dddddddddbbdd3dfeec33333333faef32511522225115233333f82288ff33333333ad77d993333338ee8365555553333324f442f0f443332320070070033232
3dd1dd111dbd1d3df8bf33333333fe8f335552888825553333383f8888ff33333333a911999333333e88e83555555533333114444f44233323330dddd0253332
33d5dd555ddd5dd3feef33333333ceef33335512215533333333888a888f3333333aaa99999933333888e835155555533388811114424333533520dd02535335
33d5dd555dbd5d33cae8f333333febaf339955555555993333333f8988f83333333aaa8899993333338e8ee11555555333488888811442435353320025333535
33d5dd555ddd5d333feecf3333f8aef3333355555555333333333f88a8ff333333aaa9333999933333333223355555533324488888844244d32333225333323d
33d5dd555ddd5d3333beebffff8eec33333393555539333333333f8988f433333aaa933333999933333333633355555134424444444424445335335555335335
33d5dd555ddd5d33333f8eeceeeef333333393355339333333333f8a88443333aaa9333333399993333333373e25555134442222222244433532353333532353
33d5dd555ddd5d333333fceeb8fa3333333339344393333333333f8888433333aa93333333339999333333337331333133444444444444333535335335335353
33dddddddddddd3333333ffffff3333333333939939333333333388338333333a93333333333399933333333333311133334444444444333353d33533533d353
33335555555333333335555333333333333433333333343333d53555335d333333333333333333333333333333333333333333333333333333333333b3333333
3336555555553355338555888333333333343a88a9344433335100005551d33373373433334373373337773333333333333344333344333333336ddbdd633333
3365555555553533320558282833333333449aaaa992433333337007005533333767334444337673397707733333333333334e4444e433333337d37333d63333
335555555555553330555282823fff33334e2244224e43333330010000333333677b34444443b77699977773333333333333304404e43333336d3333b33d6333
37117ffff71173533555502220ffdff3333400440044333330555511003333333bb7344444437bb3bb3377733333333333334ff44443333337d1111bb111d633
3377dffffd7733333155550005fdfdf333334444444355330066655511d333333b3b74444447b3b33b37773755533333333300ff4443344336dcccccccccd633
33dd4ff224dd93333115555555dfdfdd334444444443555333220d5555533333333b34044043b3333b377775755553333333ffff44433ff36dc7ccbcc8cccd63
33992bbb8299933311133355555dfd333ee4444474335555333dd555555d3333333b31444413b333333777775555573333333ff444334bb36dcc88799fcccd63
33991bbbb19999331333335555555333322447777333355433555b55bbbbdb3333331144441133333b377777777555733334444443344bb36dc880f999c8cd63
339991b1b993993331b3332555255533300b7777743334443666b66666b666633331114444111333333377777777557733444444444443b36dcc8899b98ccd63
33f399bb9993f3333b332235552555333bb37777743334443661661116b6166333111112211111333333377777777775344444b4444433336dcccc8888c8cd63
33f344b44433f333333333335255555333b4477774443344336d66ddd666d633331111111111113333333323377777554ff4bbbb44ff33b336d7ccbc8cccd633
33ff4b44b43ff3333b3333322355552333b4477744444344336d66ddd666d63333511115511115333333332332333777f22f1dd14f22f33336dbbbbbcb44d633
33f344333433f33333333333333355333344477744744443336d66ddd666d6333355155555515533333333e33e3333372ff25dd542ff2333336d447bb4dd6333
333343333433333333333333333323333474477744774443336d66ddd666d6333355322332235533333333e33e3333332ff267d542ff23333336d4444d663333
3333f3333f333333333333333333333334744777447774333366666666666633335332333323353333333ee3ee33333332245dd5442233333333666666333333
3000003330000333300000333330000333000033300003333000033300003333000003333300003333300003c3333c3336666663336366333333333333333333
07777703077770300777770333077770307777030a7aa0330a7aa030aaaa0300aaaaa03330aaaa03330aaaa0cccccc3366333366363363633344443333333333
30777770777703077777777033077770307777030a7aa030a7aaa030aaaa00aa77aaaa0330aa7aa0330aa7a0c3cc3c3363333336663336363434344333333333
307777707777007777dd77770307777030777703007aaa00aaaaaa00aaa00aaaaaaaaaa030a7aaaa030a7aa03cccc33363333336636363363443334333333333
33077770777030777d00d777030777703077770330aaaa00a7aaaa00aaa00a7aa00aaaa030a7aaaa030aaaa033cc333363333336663336363433344333333333
330777777770077770330777700777703077770330a7aa00aaaaaa0aaaa0aa7a0330aaaa00a7aaaaa00aaaa03333333363333336636363363443434333333333
333077777703077770330777700777703077770330aaaa0aaa0aaa0aaaa0aaaa0330aaaa00aaaaaaaa0aaaa03333333366333366366363633344443333333333
3330777777030777703307777007777030777703330aaa0aaa0aaa0aaa00aaaa0330aaaa00aaaa0aaaaaaaa03333333336666663336366333333333333333333
3333077770330777703307777007777030777703330aaa0aaa0aaa0aaa00aaaa0330aaaa00aaaa00aaaaaaa03333777733333333333333333333333333333333
3333077770330777703307777007777030777703330aaa0aa000aa0aaa00aaaa0330aaaa00aaaa00aaaaaaa03337777733333333333333333333333333333333
3333077770333077770077770307777707777703330aaaaaa030aaaaaa030aaaa00aaaa030aaaa030aaaaaa03337777733333333333333333333333333333333
3333077770333077777777770330777777777033330aaaaaa030aaaaa0330aaaaaaaaaa030aaaa0330aaaaa03337777733333333333333333333333333333333
333307777033330dd7777dd03330dd77777dd0333330aaaaa0309aaaa0333099aaaa990330aaaa0330aaaaa03377777733333333333333333333333333333333
33330dddd03333300dddd003333300ddddd003333330999903330999903333009999003330999903330999903377777333333333333333333333333333333333
33333000033333333000033333333300000333333333000033333000033333330000333333000033333000033777333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333337333333333333333333333333333333333333333
37bbb333333333b7bbb3333333bbb1b131bbbbbbbbbbb333333b333333bbbbbb3300000003333333333000033333330000033330000000033444433333333333
1bbbbb3333337bbbbbbb33333bb7bb1116b1bb7bb1b161333333b33333b3333b3077777770333333330777703333007777703307777777704949944333333333
b1bb1133333bbbb1bbbb1333bbbbbb6616b6b1bb1666613333333b3b33b3333b0777777777033333330777703330777777770307777777704999999433333333
161b613333b11b11b11bb1311b1bb166166666b766b66133333333b3333b33b307777ddd77703333330777703307777777770307777dddd04999999944333333
16bb61333316bb61166bb1316b6b11161111161b6111133333333b3b3333bb3307777000d7770333330777703307777000003307777000034999994999433333
16bd6133316db613316b1b116b6db131333316db6133333333333333333333330777703307777033330777703077770333333307777033334999999999943333
16bd6133316db613316dd1116b6dbbb1333316db6133333333333333333333330777703307777033330777703077770333333307777000034aaa999999994433
16db6133316db613316bd613166ddbb6133316db6133333333333333333333330777703307777033330777703077770333333307777777034a9aaaa9999a9943
16db6133316dd613316dd613311ddbb6613316dd613333333cccc333333333ee0777703307777033330777703077770333333307777ddd034aaaaaaaaaaa4494
16db6133316db613316dd61313311bb6613316bd61333333c3333c3333333eee0777703307777033330777703077770333333307777000334aa44aaaaaa49944
16dd61111316d661166d613161111b66613316bd61333333c3333c333ee3eee3077770007777d033330777703307777000003307777000034a4994aa9aa4aa44
16dd66666116666666666131666dd666613316dd61333333c3333c33333eee3307777777777d033333077770330d777777770307777777704a4aa4a999aa44a4
16dd66666131666666661331666db6661333166661333333c3333c333eeee333077777777dd03333330777703330dd77777d0307777777704aa44aaa9aaaaaa4
1666666661331166661133316666666133331666613333333333333333ee3e330dddddddd0033333330dddd0333300ddddd0330dddddddd04aaaa9aaa4aaaaa4
311111111333331111333333111111133333311113333333333333333e3e3e333000000003333333333000033333330000033330000000034aaaaaaa494a4aa4
33333333333333333333333333333333333333333333333333333333e33333333333333333333333333333333333333333333333333333333444444444443443
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333111313333
33333333333333333300333333330033333333333333333333330000003333333000003333000033333000033333333300033330000000033333111bbb1b1333
33333333333333333003330000333003333000000000033333300000000033330aa9aa0330aaaa03330a99a0333333309aa0330a9a99aaa03331bbbb7bbbb133
33333300003333330033000000003300330000000000003333300333330003330a999a0330aaaa0333099a9033333309aaaa030a99aaaaa0331bb7bbbbbbbb13
33330000000033330030000000000000330000000000003333300033333003330aa99a0330aaaaa0330aaaa0333300aaaaaa030999a4444031b7bbbbbbbbbb13
30300000000033033000330000330003330033000033003333300003333003330aaaaaa00a9aaaa0330aaa033330aaa0000033099aa00003165bbb5bbbbb5b61
30000300000000033300333003330033330333300333303333330033330003330aaaaaa00999aaa0330aaa03330aaa033333330aaaa0333316616b11bbbb1661
33003300030000333330000000000033333333333333333333333333300033330aaa0aa00990aaa0330aa903330a9a033333330aaa900033316d66dddbbbd613
33300000033003333330003033000333303333333333330333333330000333330a990aa00aa0aaa033099aa030a99a033333330aaaa9aa03316d66ddd7bbd613
330000000000033333003033303000333000000000000003333333000333333304990aaaaaa0aaa03309aaa030a9aa033333330aaaa44403316d6bddd6b6d613
3300300000300333300303030303000330000000000000033333330033333333304a00aaaaa0aa903330aaa030aaaa0333333309aaa00033316d66ddd6b6d613
3000030303000033330000000000003330000000000000033333330033333333304400999a00a9903330aaa0330aa990000033099aa00003316d66ddd666d613
3000333333300033333000000000033330000000000000033333330033333333330030999a0099a0333099a03304aa9999aa0309aaaa44a0316d66ddd6b6d613
3000303000030003330003333300033330000000000000033333333333333333333330a9a400aaa0330a9990333044a99aa4030aaaa40040316d66ddd666d613
30000000000000033300333333300333303333333333330333333300333333333333304044304440330444403333004444403304444033033166666666666613
30000000000000033000333333300033303333333333330333333300333333333333330300330003333000033333330000033330000333333311111111111133
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3533335338333383333bb33333333763333aa33333388333333223333b3333b33443333333333333333333333333333333333333383883833333333333333333
35655553388338833337b3333333766333999933338f8833332222333bbbbbb334443333366336633e3333e333222233333b3333388558833377773333333333
36555553388888833b7bbbb333376633399339933f888f83322222233b5555b3344b4333366d6d633eeeeee33200002333bbb333385555833d7777d333324433
35555553328888233bbbbbb33636633339333393383ff383337777333b5555b333bbb43336d6d6633e3ee3e332000023373b373338555583377dd77332244443
3355553333288233333bb3333363333339933993333ff3333372273333b55b33333b4443336d6d3333e22e33320000233b7373b3338558333d7777d333344243
3335533333388333333bb3333636333333999933333ff33333722733333bb3333333444333d6d633333333333200002333bbbb33333883333377773332244443
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3377773333333883333333333333333333383333377dd77333333b333373773333333333332222333344443333388333333bb333333334333c3333c33aa99993
377777733333882332233223366336633328833337d77d733333b3b337b3b773335d5d3332777723344444433387783333bb77b3333343433cccccc33a999993
377dd773333882333222222336866863332288333d7dd7d333b33b3337b33b73353333533277272334499443388778833bbb77b3333223333c7777c33a999993
377dd773383823333228322336888863332228833d7dd7d33b3b343337733b733d3d53d33272772339999993387777833bb77773332222333c7777c333999933
377777733383333338238233336886333222223337d77d7333b3343337b3b7733535335332777723349499433387783333bb77b33322223333c77c3333399333
3377773338383333332238333366663332233333377dd77333433433337b3b33333d5d333322223334444943387887833bb7bb7333322333333cc33333999933
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000c00001e0350c0450f05511055180551800513055160551b0551f05527055180552405529055300551f0051f005220053300500005000050000500005000050000500005000050000500005000050000500005
01060000150551a055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000200000302501015000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000300000101104021140010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
00040000050110e021190010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000600000253507545005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000600000654502535005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
0009000000545055350a5350000518025000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000800000562507055030350a70500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000000203203612090421603202602220320000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
0006000007045070050c0050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0006000004545055050c5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
001000000955000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000085520c502155021550221512000020000200002000021555200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
011000000000200002000020000200002000021800200002070520000200002000020000200002000020000200042000020000200002000020000200002000020705200002000020000209002000020000200002
001000000903003050000100000000020000000300000000000300000001010000000002000000030000000000030000000101000000000200000006000000000003000000010100000000020000000204000000
001000000050400504055440f504095540050400504115440f504005040050400504005040050400504005040050400504055440f5040a5540050400504075440050400504005040050400504005040050400504
0110000000504005040c5540f504115540050400504135540f5040050400504005040050400504005040050400504005040c5540f5041155400504005040c5540050400504005040050400504005040050400504
011000000003000000000000000001020000000300000000000300000000000000000101000000030000000007010050300202002010000200004000000000000000000100030000000001000030000300001000
0010000000504005040c5540f504115540050400504135540f50400504005040050400504005040050400504005040f5040f50405504035040350403504005040050400504005040050400504005040050400504
000600000a0350f725080050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000600000554406504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
001000001105606036025260051600506000060150600506040060200601006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
000b0000010520c522025320000203002070020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000100000561009030130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c03506145023050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000600000c05501055167550070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
0003000007725057050d5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
0003000005725050050d5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000600000153406504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
000600000a04508725037350051500505005050170500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
0005000000050050500a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000040340c5440f5041155400504005041354400504000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000001054055440f5040a55400504005040754400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000027540f744117040170405704017040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704
00100000075520c5520f55213552225121b55216552000021355213552000020a552000020c502055220000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000c00000a0350c0450f05511055180551800513055160551b0550303507055130552400529005300051f0051f005220053300500005000050000500005000050000500005000050000500005000050000500005
00100000075220c5320f542135521f5121b5020f54220502165521d52225502225520e502295322e5222b50200002000020000200002000020000200002000020000200002000020000200002000020000200002
00060000040340c544170540702404024030140105400004040000200001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000030370a037120571301714017160171902728037050270000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007
00100000056430b023000330f0431102300003140031600318003140031a003150031b003180031d00320003006031b0031c0031a6031e0031e0031f0031f0032000322603236030060300603006030060300603
0004000002611036310634111061240510b6410902105031000310002100011026410000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000200000562018030000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000050140f724000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000c0000020441074402034080341a7541d7040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000500000401411024130040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704
000800000162411044165240303400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
00070000070250f045187250000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000d00000061405044050540f05400004000041256400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
0010000000615070450a0550f055000051b0452003500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
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
01 41 42 43 44
01 41 0f 0e 44
00 41 0f 0e 10
00 11 0f 43 10
02 41 12 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
