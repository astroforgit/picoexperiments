pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- another world [survival]
-- by paul nicholas

-- [sfx]
-- 08: kick
-- 09: squish worm
-- 10: pew pew
-- 11: pew pew 2
-- 12: start shield
-- 13: blast ready
-- 14: blast fire
-- 15: shield up
-- 16: death: toast
-- 18: boom (title)

-- fields
debug = false
game_state = 0 -- 0=title, 1=intro?, 2=level_intro, 3=game_play, 4=level_end, 5=lose_life, 9=game_over
anim_state = 0 -- 0=none, 1=playing anim
anim_post_func = nil
game_counter = 0
backgrounds={8,64,72}
cols_pewpew = {8,2,2,2}
cols_blast = {7,7,7,7}
cols_splash = {7,12,12,7}
cols_pewpew_death = {7,12,0,0}
shake = 0
beast_blink = -1
musicflag=1

-- anims
anim_death_worm = 1
anim_gun_pickup = 3
-- other constants
gun_pewpew_speed = 10
--gun_pewpew_speed = debug and .25 or 10


function _init()
	-- 64x64 mode
	poke(0x5f2c,3)

 -- init cart data
 cartdata("pn_awsurvival") 
 -- load saved data
 game_level=dget(0)>0 and dget(0) or 1

	-- menu options
 menuitem(1,"toggle music",function()
   musicflag=1-musicflag
   music(musicflag)
 end)
 menuitem(5,"!wipe progress!",function()
  dset(0,-1)
 end)

 -- final init
	init_anim()
	init_title()
end

function _update60()

	-- playing animation
	if anim_state == 1 then
		playback_update()
		return
	end

	-- todo: diff. modes (title/game/cutscenes?)
	if game_state == 0 then
		-- title screen
		if btnp(4) then 
			game_state = 2 -- level intro
			-- init anything?
			init_game()
		end
	

	elseif game_state == 2 then		
		-- level intro message
		if btnp(4) then					
			-- init anything?
			init_level()
			-- skip intro
			game_state = 3
		end

	elseif game_state == 3 or game_state ==5 then
		-- main game update routine
		-- (runs even during lose life)
		update_game()

		if game_state == 5 then
			-- delay before restarting
			game_counter += 1
			if game_counter > 150 then
				-- restart level (go back to leven intro)
				game_state = 2
			end
		end
	elseif game_state == 4 then
		-- delay before next level
		game_counter += 1
		if game_counter > 150 then
			-- next level
			game_level += 1
   dset(0,game_level)
			level_count = game_level%3
			if (level_count == 0) level_count = 3
			-- (go to level intro)
			game_state = 2
		end
	end

end

function _draw()
	if game_state > 0 then
		cls()
		-- clip to widescreen ratio
		clip(0,16,64,32)
	end
	
	--apply shake (if applicable)
  doshake()

	-- drawing animation?
	if anim_state == 1 then
    playback_draw(tfoff)
		return
  end

	if game_state == 0 then
		-- draw title screen
		draw_title()
	
	elseif game_state == 1 then		
		-- draw intro cutscene
		draw_game_intro()

	elseif game_state == 2 then		
		-- draw level intro message (e.g. "level x:")
		draw_level_intro()
		
	
	elseif game_state >= 3 then
		-- draw game elements
		draw_game()
	end

	if debug then
    print("cpu:"..flr(100*stat(1)).."%", 0, 56, 12) 
    print("mem:"..flr(stat(0)/1024*100).."%", 36, 56, 12)
  end
end

-- --------------------------------
-- initialise routines
-- --------------------------------
function init_title()
	-- todo: anything here?
	game_state = 0
 music(10)
end

function init_anim()
	-- 'load anim strings'
  lstr_offset = 1
	lstrs = {}
	-- {string, next_offset}
	-- worm pt.1
  lstrs[1]={">14l-1t2a26352630241005t3526393f2c3f1005t35262a262f381001t2a282c2e2b281775r0010402fc10>00l-1t251d301d2b1b1005t301d343627361005t301d251d2a2f1000t251f2725261f1775t-1r0010402fc10>0fl20211e22d5l26202620d5t251d301d2b1b1005t301d343627361005t301d251d2a2f1000t-1t-1t-1t261e2021261f1774t57235a2556260775r0010402fc10>0fl1f1d2020d5l251c251fd5t24192f192a171005t2f19333226321005t2f192419292b1000t-1t-1t-1t251a1f1d251b1774t561f592155220775r0010402fc10"
						,2}
	-- worm pt.2
  lstrs[2]={">0ft*1b0b331955391dd5t*1d10251f00301115t*032f251f40301115t3f0b340f4612100at350f2b274512100at47122b263b2b100at29303a2b2c25100at3b2b28303a30100at091012260e10155at18101b2312241ff5t0b10133217101ff5t1c23163c13241ff5t0e2f1025122f1555t16291929172b1555r0010402fc15>0fl1821182185t*1b0b331955391dd5t*1d10251f00301115t*032f251f40301115t181c15201d1e1007t152018261d1e100at1d1d18262025100at1a3020251827100at2025193023301005t091012260e10155at18101b2312241ff5t0b10133217101ff5t1c23163c13241ff5t0e2f1025122f1555t16291929172b1555r0010402fc15>1el1821182187t*1b0b331955391dd5t*1d10251f00301115t*032f251f40301115t1236113a17361b57t113a153e18361b5at163717401e3b1b5at1e4d1e3c183f1b5at1e3c1f4d284d1b55t091012260e10155at18101b2312241ff5t0b10133217101ff5t1c23163c13241ff5t0e2f1025122f1555t16291929172b1555r0010402fc15>1el1825182187t*1b0b331955391dd5t*1d10251f00301115t*032f251f40301115t1236113a17361057t113a153e18361b5at163717401e3b1b5at1e4d1e3c183f1b5at1e3c1f4d284d1b55t091012260e10155at18101b2312241ff5t0b10133217101ff5t1c23163c13241ff5t0e2f1025122f1555t16291929172b1555r0010402fc15"
						,nil}
	-- gun
	lstrs[3]={">32l161f1a1f05l1a1f1e2305o092802d16o0d2602d16o0a2603516t09141e2f212c1005t0a140d111e2e1005t1a23282624211005t1e28282619231005t442f340f430f1dd5t310a2d1c2f0a1dd5r0010402f515>3cl161f1a1f05l1a1f1e2305o092802d16o0d2602d16o0a2603516t09141e2f212c1005t0a140d111e2e1005t1a23282624211005t1e28282619231005t442f340f430f1dd1t310a2d1c2f0a1dd1t1920202528251ff5t1920181c1e211ff5t1e20241d2b251ff5t2127222a26261ff5t2426362827201ff5t2821312037281ff5t37294b2c481a1ff5t2b203729491a1ff5r0010402f510>1el5919631605l64166b1e05o092802d16o0d2602d16o0a2603516t36006c45733a1115t380040*08723b1115t6226862e7c211115t6c33862e5f261115t442f340f43101dd1t310b2d1c2f0b1dd1t5f1e7230862b1ff5t5f1e62196c211ff5t6a207c168e2b1ff5t712f7538812e1ff5t7c2eab33841e1ff5t86219e1ead331ff5tad35e13dd90e1ff5t8e1ead35dc0e1ff5t08641d651a5e0ff5r0010402f511"
						,nil}

end

function init_game()
	level_count = game_level%3
	if (level_count == 0) level_count = 3
 if (musicflag>0) music(1)
end

function init_level()
	-- init
	game_state = 2
	player = {}
	pewpews = {} -- lasers/pewpews
	shields = {}
	tentacles = {}
	worms = {}
	soldiers = {}
	particles={}

	-- seed level to be consistent
	srand(game_level)

	-- calc max enemies for this wave
	level_remain_worm_count = 0
	level_remain_soldier_count = 0
	-- calc max of each on-screen at any one time
	level_concurr_worm_count = 0
	level_concurr_soldier_count = 0

	-- init player
	init_player()

	if level_count == 1 then
		-- tentacle only for "outdoors" zone
		new_tentacle()
	end
	if level_count <= 2 then
		-- calc # worms for this level
		level_remain_worm_count = game_level
		level_concurr_worm_count = max(3, flr(game_level/2))
		-- create (ground) worms
		for x=1, max(3,level_concurr_worm_count/2) do
			-- random place on floor (with gap for player)
			local xpos = rnd(20)-5
			if (flr(rnd(2)) == 0) xpos += 45
			new_spawn(1, 1, xpos)
		end
	end
	
	if level_count == 2 then
		-- create (ceiling) worms
		for x=1,level_concurr_worm_count/2 do
			-- random place on ceiling (with gap)		
			local xpos = rnd(25)-5
			if (flr(rnd(2)) == 0) xpos += 40
			new_spawn(1, 2, xpos)
		end
	end

	if game_level == 3 then
		-- cinematic!
			play_anim(anim_gun_pickup, function()			
				-- code to run after gun pickup
			end)
	end

	if game_level >= 3 then
		-- player can fire now!
		player.hasgun = true
		-- calc # soldiers for this level
		level_remain_soldier_count = game_level
		level_concurr_soldier_count = max(1, flr(game_level/2)-1)
		-- determine max difficulty at current level		
		local max_soldier_type
		if game_level >= 4 then 
			max_soldier_type = 3
		else
			max_soldier_type = 2
		end
		-- create soldiers
		for x=1,level_concurr_soldier_count do
			local new_sold_type = max(2, flr(rnd(max_soldier_type))+1)
			new_spawn(2, new_sold_type, nil)
		end
	end
end


function new_spawn(new_enemytype, new_subtype, new_xpos)

	local xpos = new_xpos
	if new_enemytype == 1 then
		-- worm
		if xpos == nil then
			xpos = (flr(rnd(2)) == 0) and -3 or 64
		end
		new_worm(xpos, new_subtype)
		
	elseif new_enemytype == 2 then
		-- soldier
		if xpos == nil then
			xpos = (flr(rnd(2)) == 0) and rnd(10)-20 or rnd(10)+64
		end
		new_soldier(
			xpos, 30,
			new_subtype, 
			1,
			5,
			true)	
	end
end

-- create new "worm"
function new_tentacle() 
	local tentacle = {
		x = 30,
		state = 0,
		y = 41,
		h = 0,
		max_height = 10,
		move_counter = 0,
		move_speed = .05,
		max_sleep = 200,
		move_frame = 0,
		curr_anim={192,193,194},
		frame = 1,
		frame_delay = 0,
		anim_speed = 6,
	}
	add(tentacles, tentacle)
end

function new_soldier(new_x, new_y, new_type, new_state, new_ai_state, face_player)
	soldier = {
		x = new_x,
		y = new_y,
		type = new_type, 
		ai_state = new_ai_state,
		state = new_state, 
		flip = face_player and (new_x>player.x) or false,
		walk_speed = 0.25,
		frame_delay = 0,
		anim_speed = 6,
		anim_walk = {128,129,130,131,132,133,134,135},
		anim_idle_side = {161},
		anim_idle_front = {161},
		anim_idle_crouch = {163},
		anim_kick_stand = {165},
		anim_punch_crouch = {163,163,163,164},
		anim_shoot_stand = {165},
		anim_shoot_crouch = {166},
		anim_dead_pewpew = {136,136,137,138,137,138,139,-1},
		trans_col = 12,
		frame = 1,
		hasgun = true,
		gun_mode = 0,
		gun_trigger_pressed = false,
		gun_trigger_count = 0,
		advance_max_dist = 2,
		shoot_delay = 0,
		shoot_next_delay = 0,
		shoot_max_count = 5,
		shoot_max_delay = 20,
		hitbox = {x=3,y=4,w=1,h=11},
		can_advance = new_type > 1,
		visible = true
	}
	soldier.curr_anim = soldier.anim_walk
	add(soldiers, soldier)
end

function new_shield(new_x, new_y)
	local height = 16
	local newshield = {
		x = new_x,
		y = new_y,
		power = 6,
		h = height,
		hitbox = {
			x=0,
			y=-height,
			w=0,
			h=height}
	}
	add(shields, newshield)
 sfx(15)
	return newshield
end

function new_pewpew(new_x, new_y, new_vx, new_vy, new_type, new_origin)
	local pew_length = new_type == 1 and gun_pewpew_speed*2 or 64
	local newpewpew = {
		x = new_x,
		y = new_y,
		new = true,
		vx = new_vx,
		vy = new_vy,
		length = 0,
		max_length = new_vx>0 and -pew_length or pew_length,
		frame = 0,
		type = new_type,
		hitbox = {
			x=0,
			y=0,
			w=0,
			h=0},
		origin = new_origin
	}
	add(pewpews, newpewpew)

 if new_type==1 then
  sfx(10+flr(rnd(2)))
 else
  -- blast ready sfx?
  sfx(14,3)
 end
end

function new_worm(new_x, new_state)	
	local newworm = {
		x = new_x,
		state = new_state,
		y = new_state==1 and 38 or 17,
		worm_anim_crawl = {190,191},
		worm_anim_hang = {185,186,187,188,189,188,187,186},
		worm_anim_fall = {187},
		anim_speed = 30,
		hitbox = {x=2,y=6,w=3,h=1},
		max_hangcount = 10
	}
	newworm.frame_delay = rnd(newworm.anim_speed)+1
	newworm.curr_anim = newworm.worm_anim_crawl
	newworm.frame = flr(rnd(#newworm.worm_anim_crawl))+1
	add(worms, newworm)
end

function init_player()
	player = {
		x = 30,
		y = 30,
		flip = false,
		state = 0,
		walk_speed = 0.25,
		frame_delay = 0,
		anim_speed = 6,
		anim_walk = {200,201,202,203,204,205,206,207},
		anim_idle_side = {233},
		anim_idle_front = {232},
		anim_idle_crouch = {235},
		anim_kick_stand = {234},
		anim_kick_crouch = {236},
		anim_shoot_stand = {237},
		anim_shoot_crouch = {238},
		anim_dead_punched = {224},
		anim_dead_worm = {233,233,225,225,233,233,225,225,226,226,226,226,226,227,227,224,-1}, -- "-1" means don't loop
		anim_dead_pewpew = {195,195,196,197,196,197,198,-1},
		trans_col = 2,
		frame = 1,
		hasgun = false,
		gun_mode = 0,
		gun_trigger_pressed = false,
		gun_trigger_count = 0,
		hitbox = {x=3,y=4,w=1,h=11},
		visible = true
	}
	player.curr_anim = player.anim_idle_side
	
end

--
-- update routines
-- 

function update_game()
		update_tentacles()
		update_soldiers()
		update_worms()
		update_shields()
		update_pewpews()
		update_particles()
		update_player_control()
		update_spawns()
end


function update_spawns()
	if #worms < level_concurr_worm_count 
	 and level_concurr_worm_count > 0 then
		new_spawn(1, flr(rnd(level_count))+1, nil)
		level_concurr_worm_count -= 1
	end
	if #soldiers < level_concurr_soldier_count
	 and level_remain_soldier_count > 0 then
		local max_soldier_type = 2
		local new_sold_type = flr(rnd(max_soldier_type))+2
		new_spawn(2, new_sold_type, nil)
		level_remain_soldier_count -= 1
	end

	if #worms + level_concurr_worm_count
			+ #soldiers + level_remain_soldier_count == 0 
	then
		game_state = 4
		game_counter = 0
	end
end


function update_tentacles()
	for t in all(tentacles) do
		if t.state == 0 then
			if player.x == t.last_player_x then
				t.move_counter += 1
			else
				t.move_counter = 0
			end		
			if t.move_counter > t.max_sleep then
				t.state = 1
				t.move_counter = 0
				t.h = -1+(t.move_speed)
			end

		elseif t.state == 1 then
			if player.x == t.last_player_x then
				t.h += t.move_speed
			else
				t.state = 2
			end			
			if t.h > t.max_height 
			 and player.x == t.last_player_x then
    -- tentacle death
				t.state = 3
				t.anim_count = 0
				player.visible = false
    sfx(40)

			elseif game_state == 5 then
				t.state = 2
			end

		elseif t.state == 2 then
			t.h -= t.move_speed
			if t.h <= 0 then
				t.h = 0
				t.state = 0
				t.move_counter = 0
			end

		elseif t.state == 3 then
			local next_frame = update_curr_anim(t)
			if (next_frame) t.anim_count += 1
			if t.anim_count >= #t.curr_anim then
				t.state = 4
				boom(
					t.x+1,
					t.y,
					30,
					0.5,
					0.25,
					0.5,
					30, 
					cols_splash, 
					0.15,
					44 
				)
				lose_life()
			end
		elseif t.state == 4 then
		end

		t.last_player_x = player.x
		if t.state == 0 then			
			t.x = mid(9, player.x, 54)
		end
		
	end
end

function update_soldiers()
	for s in all(soldiers) do
		s.muz_x = (s.state==7 or s.state==3) and (s.flip and s.x-1 or s.x+8)
				or (s.flip and s.x or s.x+7)
		s.muz_y = (s.state==7 or s.state==3) and s.y+9 
				or s.y+7
		s.muz_y -= 1

		s.fully_visible = s.muz_x > 4 and s.muz_x < 59

		if s.ai_state == 0 then

		elseif s.ai_state == 5 then

			if collide(player, s) 
			 and s.state != 6
			 and game_state != 5
			then
    -- punch death
				s.ai_state = 6
				s.state = 5
				player.state = 8
				player.punched_by = s
				lose_life()
    --
    s.frame_delay=1
		  s.frame=1
    sfx(42)
			end

			if game_state == 5 
			 and player.punched_by != s then
				s.ai_state = 0
				s.state = 0
			end

			if s.state == 0 then
			elseif s.state == 1 then
				s.dir = s.x<player.x and 1 or -1
				s.flip = (s.dir < 0)
				if (s.walk_counter == nil) then
					s.walk_counter=0
				end
				if s.frame_delay == 0 then
					s.x += s.dir
					s.walk_counter += 1

					if (s.walk_counter > s.advance_max_dist) then
						s.state = (flr(rnd(2)) == 0) and 6 or 7
						s.shoot_counter = nil
					end
				end
				
			elseif s.state == 2 then

			elseif s.state == 3 then

			elseif s.state == 6 or s.state == 7 then

				s.shoot_delay += 1
				if (s.shoot_delay >= s.shoot_next_delay) then
					if s.gun_mode == 0 then
						if (s.shoot_counter == nil) then
							s.shoot_counter=0	
							s.shoot_next_count=flr(rnd(s.shoot_max_count))+5
							if not s.fully_visible then
								s.shoot_next_count = 1
							end
						end
							if (s.shoot_counter < s.shoot_next_count-1) then
								if s.fully_visible then
									new_pewpew(
										s.muz_x,
										s.muz_y,
										s.flip and -gun_pewpew_speed or gun_pewpew_speed,
										0,
										1,
										2)
								end
								s.shoot_delay=0
								s.shoot_next_delay=flr(rnd(s.shoot_max_delay))+10
							end
						if (s.shoot_counter == s.shoot_next_count) then
							if s.can_advance and (flr(rnd(2)) == 0) then
								s.gun_mode = 1
							else
								s.state = (flr(rnd(2)) == 0) and 6 or 7
							end
							s.shoot_counter = nil
						end
						
					elseif s.gun_mode >= 1 then
						if (s.shoot_counter == nil) then
							s.shoot_counter=0	
							s.shoot_next_count=1
							s.shoot_delay=0
							s.shoot_next_delay=flr(rnd(s.shoot_max_delay))+35
						end

						if (s.shoot_counter == s.shoot_next_count) then
							if s.type > 1 and s.gun_mode == 1 
							 and ((flr(rnd(3)) <= 1) or s.type<3 or not s.fully_visible) then
								s.curr_shield = new_shield(s.muz_x, s.y+16)
								s.state = 1
								s.gun_mode = 0
								s.walk_counter = nil

							elseif s.type > 2 and s.gun_mode == 1 then
								s.gun_mode = 2
								s.shoot_counter = nil
								return
							elseif s.type > 2 and s.gun_mode == 2 then
									new_pewpew(
										s.muz_x,
										s.muz_y,
										s.flip and -gun_pewpew_speed or gun_pewpew_speed,
										0,
										2,
										2)
								s.gun_mode = 0
								s.shoot_counter = nil
							end
						end
					end

					if s.shoot_counter then
						s.shoot_delay=0
						s.shoot_counter += 1
					end

				end

			end

		elseif s.ai_state == 6 then

		elseif s.ai_state == 19 then
				s.anim_count += 1
				if s.anim_count == 20 then
					boom(
						s.x+4,
						s.y+7,
						30,
						0.5,
						0.75,
						0.25,
						50, 
						cols_pewpew_death,
						0.15,
						45 
					)
					del(soldiers, s)
				end

		end

		if (s.state == 0) s.curr_anim = s.anim_idle_side
		if (s.state == 1) s.curr_anim = s.anim_walk
		if (s.state == 2) s.curr_anim = s.anim_idle_side
		if (s.state == 3) s.curr_anim = s.anim_idle_crouch

		if (s.state == 5) s.curr_anim = s.anim_punch_crouch

		if (s.state == 6) s.curr_anim = s.anim_shoot_stand
		if (s.state == 7) s.curr_anim = s.anim_shoot_crouch

		local next_frame = update_curr_anim(s)
		
	end
end

function update_player_control()
	player.prev_state = player.state

	if game_state == 3 then
		player.kick = nil

		-- gun fire pos calc (in case we need it)
		player.muz_x = (player.state==7 or player.state==3) and (player.flip and player.x-1 or player.x+8)
					or (player.flip and player.x or player.x+7)
		player.muz_y = (player.state==7 or player.state==3) and player.y+9 
					or player.y+7

		-- fire 1
		if btn(4) then
			-- kick/shoot
			if player.state==3 or player.state==5 then
				player.state=5
			else
				player.state=4
			end
			-- check for "kick" attack
			if (player.state == 4 or player.state == 5)
				and (player.prev_state != 4 and player.prev_state != 5)	
			then
				-- set kick collision for this cycle
				player.kick = {
					x = player.state==5 and (player.flip and player.x-2 or player.x+8)
								or (player.flip and player.x-1 or player.x+7),
					y = player.y+13,
					hitbox = {x=0,y=0,w=1,h=2}
				}
    sfx(8)
			end

		elseif (not btn(4)) and (player.state==4 or player.state==5) then
			-- released kick
			if player.state==5 then
				player.state=3
			else
				player.state=0
			end

		elseif btn(5) and player.hasgun then
			-- shoot
			-- change player state/anim accordingly
			if player.state==3 or player.state==7 then
				player.state=7
			else
				player.state=6
			end
			-- gun modes
			if (not player.gun_trigger_pressed) then 
				player.gun_trigger_count = 0 
				-- create pewpew
				new_pewpew(
					player.muz_x,
					player.muz_y,
					player.flip and -gun_pewpew_speed or gun_pewpew_speed,
					0,
					1,
					1)
			else
				-- still holding trigger
     --printh(player.gun_trigger_count)
				if player.gun_trigger_count < 5 then
					-- do nothing (already shot!)
				elseif player.gun_trigger_count >=5 and player.gun_trigger_count <=12 then
					-- shield mode
					player.gun_mode = 1
     -- blast ready sfx?
     if (player.last_gun_trigger_count<= 5 and player.gun_trigger_count >= 5) sfx(12,3)
				else
					-- blast mode
					player.gun_mode = 2
     -- blast ready sfx?
     if (player.last_gun_trigger_count<= 12 and player.gun_trigger_count >= 12) sfx(13,3)
				end 
			end
			player.gun_trigger_pressed = true
   player.last_gun_trigger_count=player.gun_trigger_count 
			player.gun_trigger_count += .1

		-- released gun trigger
		elseif (not btn(5)) and player.gun_trigger_pressed then
			player.gun_trigger_pressed = false
			-- determine fire mode
			if player.gun_mode == 0 then
				-- do nothing (already shot!)
			elseif player.gun_mode == 1 then
				-- create shield
				new_shield(
					player.state==7 and (player.flip and player.x-1 or player.x+8)
					or (player.flip and player.x or player.x+7), 
					player.y+16)
			else
				-- create blast
				new_pewpew(
					player.muz_x,
					player.muz_y,
					player.flip and -gun_pewpew_speed or gun_pewpew_speed,
					0,
					2,
					1)
			end 
			-- reset gun
			player.gun_mode = 0


		-- left
		elseif btn(0) then
			player.x-=player.walk_speed
			player.flip=true
			player.state=1 -- walking
		-- right
		elseif btn(1) then
			player.x+=player.walk_speed 
			player.flip=false 
			player.state=1 -- walking
		-- up
		elseif btn(2) then
			player.state=0 -- idle
		-- down
		elseif btn(3) then
			player.state=3 -- crouching
		
		-- no key pressed
		elseif player.state==1 or player.state==2 
		--and game.state == 3  -- player not "died"
		then
			-- go to idle
			player.state=0 -- idle
		end

	else
		-- player died

		if player.state == 10 then
			-- pewpew death
			player.anim_count += 1
			if player.anim_count == 20 then
				boom(
					player.x+4, -- x
					player.y+7, -- y
					30,
					0.5, -- angle (0.5=up)
					0.75, -- spread angle
					0.25,   -- speed
					50,  -- lifetime
					cols_pewpew_death, -- colors
					0.15,-- gravity (0.15),
					45   -- ground (land if set)
				)
			end
		end

	end -- check player is "alive"


	-- select correct anim
	local curr_anim = {}
	if (player.state == 0) player.curr_anim = player.anim_idle_side
	if (player.state == 1) player.curr_anim = player.anim_walk
	if (player.state == 2) player.curr_anim = player.anim_idle_side
	if (player.state == 3) player.curr_anim = player.anim_idle_crouch

	if (player.state == 4) player.curr_anim = player.anim_kick_stand
	if (player.state == 5) player.curr_anim = player.anim_kick_crouch
	if (player.state == 6) player.curr_anim = player.anim_shoot_stand
	if (player.state == 7) player.curr_anim = player.anim_shoot_crouch

	if (player.state == 8) player.curr_anim = player.anim_dead_punched
	if (player.state == 9) player.curr_anim = player.anim_dead_worm
	if (player.state == 10) player.curr_anim = player.anim_dead_pewpew

	-- update player anim frame
	update_curr_anim(player)
end

function update_worms()
	for w in all(worms) do
		-- update worm anim frame
		w.frame_delay += 1
		if w.frame_delay > w.anim_speed then

			if w.state == 1 or w.state == 2 then
				-- move
				w.dir= w.x<player.x and 1 or -1
				if (w.frame==2) w.x += w.dir

			elseif w.state == 3 then
				-- wait + hang
				w.move_counter += 1
				if w.move_counter >= w.max_hangcount then
					-- switch to fall
					w.state = 4
					w.curr_anim = w.worm_anim_fall
					w.anim_speed = 3
				end

			elseif w.state == 4 then
				-- fall
				w.y += 2
				if w.y >= 42 then
					-- switch to crawl floor
					w.state = 1
					w.curr_anim = w.worm_anim_crawl
					w.anim_speed = 30
					w.y = 38
					w.frame = 0
				end
			end
			-- loop anim
			w.frame_delay = 0
			w.frame += 1			
		end
		if (w.frame > #w.curr_anim) w.frame=1

		if game_state == 3
		 and (w.state == 1 or w.state == 2)
		 and collide(player, w) then
   -- worm death
   sfx(41)
			play_anim(anim_death_worm, function()
				player.state = 9
				lose_life()
			end)

		-- check for "kick" frame
		elseif player.kick 
			and collide(player.kick, w) then
   -- kill worm
			del(worms, w)
			boom(
					w.x+1,
					w.y+7,
					5,
					player.flip and .375 or .625,
					0.25,
					0.4,
					20, 
					{0,0,0,0},
					0.15,
					46 
				)
   sfx(9)

		elseif w.state == 2
		 and player.x > w.x-10 and player.x < w.x+7 then
			w.state = 3
			w.move_counter = 0
			w.curr_anim = w.worm_anim_hang
			w.anim_speed = 5
		end
	end
end

function update_shields()
 for s in all(shields) do
	s.power -= 0.01
	if (s.power < 1) del(shields, s)
 end
end

function update_pewpews()
 for p in all(pewpews) do

	if p.state != -1 then
		p.moved = false

		if not p.new 
		 and not p.moved then
			p.x+=p.vx
			p.y+=p.vy
			p.moved = true
			p.length = 0
			if p.y > 64
				or p.y < 0
				or p.x > 70
				or p.x < -5
			then
				del(pewpews,p)
			end
		end


		::do_while_growing::
		local still_growing = false

		if abs(p.length) < abs(p.max_length) then
			-- grow
			p.length = p.vx>0 and p.length-1 or p.length+1
			p.hitbox.x = p.vx>0 and 0 or -p.length 
			p.hitbox.w = abs(p.length)
			still_growing = true
		end

			for s in all(shields) do
				if collide(p, s) 
				 and ((p.vx>0 and p.x<s.x) or (p.vx<0 and p.x>s.x))
				then
					p.state = -1
					p.frame = 0

					if (p.type == 2) 
					 and p.origin == 1 then 
						del(shields,s)
						boom(
							p.x-p.length,
							p.y,
							20,
							p.vx>0 and .25 or .75,
							0.25,
							0.5,
							5,
							cols_blast,
							0.15,
							50 
						)
					else
						boom(
							p.x-p.length, 
							p.y,
							3,
							p.vx>0 and .25 or .75,
							0.25,
							0.5, 
							3, 
							cols_pewpew,
							0.15,
							50
						)
					end

					goto skip_while
				end
			end

		if p.origin == 1 then

			-- enemies
			for s in all(soldiers) do
				if collide(p, s) then
					-- remove pewpew
					del(pewpews,p)
					-- todo: kill soldier (toast anim)
					s.ai_state = 19
					s.state = 10
					s.curr_anim = s.anim_dead_pewpew
					s.anim_speed = 3
					s.anim_count = 0
					s.trans_col = 2
     sfx(16)
				end	
			end

		else
			if collide(p, player) then
				-- remove pewpew
				p.state = -1	-- dead
				p.frame = 0
				player.state = 10
				player.anim_speed = 3
				player.anim_count = 0
				lose_life()
    sfx(16)
			end 
		end

		if (still_growing) goto do_while_growing

		::skip_while::

		p.new = false
	else
		if p.frame >= 1 then
			del(pewpews,p)
		end
 	end
	p.frame += 1
 end
end

function lose_life()
	game_state = 5
	game_counter = 0
end

function update_curr_anim(obj)
	local return_val = false
	obj.frame_delay += 1
	if obj.frame_delay > obj.anim_speed then
		obj.frame_delay = 0
		obj.frame += 1
		return_val = true
	end
	-- check for "don't loop" frames
	if (obj.curr_anim[obj.frame] == -1) obj.frame -= 1
	if (obj.frame > #obj.curr_anim) obj.frame=1
	return return_val
end

-- 
-- draw routines
-- 

function play_anim(anim_num, cont_with_func)
	lstr_offset = anim_num
	loadfromstring(lstrs[anim_num][1])
	playback_init()
	playback_update()
	anim_state = 1
	anim_post_func = cont_with_func
	if (cont_with_func) cont_with_func()
end

function draw_title()

	-- draw "elevator doors closing" transition (kinda!)
	line(game_counter+1,0,game_counter+1,64,10)
	line(64-game_counter-1,0,64-game_counter-1,64,10)
	rectfill(0,0,game_counter,64,0)
	rectfill(64,0,64-game_counter,64,0)

	-- draw title
	spr(0,0,16,8,3)
	game_counter += 1



	if game_counter == 100 then
		shake += 0.25
  sfx(18,3)
	elseif game_counter > 100 then
		rect(16,33,50,41,0)
		rect(15,32,49,40,8)
		pset(20,35,0)
		print("survival", 18, 34, 0)
		print("survival", 17, 34, 8)
	end
	
	center_text("press \x8e/z", 43, (flr(time())%2==0) and 7 or 0)
end

function draw_game_intro()
	center_text("<game intro>", 30, 7)
end

function draw_level_intro()
	center_text("wave "..game_level, 22, 14)
	center_text("press \x8e/z", 43, (flr(time())%2==0) and 7 or 0)
end


function draw_game()
		-- draw background
		draw_background()

		-- draw game elements
		draw_tentacles()
		for s in all(soldiers) do
			draw_person(s)
		end
		draw_person(player)
		draw_worms()
		draw_shields()
		draw_pewpews()
		draw_particles()

		draw_foreground()

		if game_state == 4 then
			center_text("level clear", 30, 7)
		end
end

function draw_background()
	spr(backgrounds[level_count],0,16,8,4)
end

function draw_foreground()
	if (level_count == 1) then
		palt(0, false)
		palt(12, true)
		spr(55,8,40,1,1)
		pal()
	elseif (level_count == 3) then
		-- draw pillars
		rectfill(7,20,10,47,0)
		rectfill(46,20,49,50,0)
	end
end

function draw_tentacles()	
 	for t in all(tentacles) do 
		if t.state < 3 then
			for n=0,1,.04 do
				m=n+t.move_frame
				-- v3
				s=1*sin(m*2.5)
				local x=t.x+s*1
				local y=42+n*25-t.h
				local dx=n*5
				if y<42 then
					line(x-dx/2,y,x+dx/2,y,0)
				end
			end
			t.move_frame+=.0075
		elseif t.state == 3 then
			-- killing player
			palt(0, false)
			palt(12, true)
			spr(t.curr_anim[t.frame], t.x-1, t.y-11, 1, 2)
			pal()
		end
	end
end

function draw_person(person)
	-- only draw if visible!
	if (not person.visible) return

	if (debug) draw_hitbox(person)

	if (debug and person.kick) draw_hitbox(person.kick)	

	palt(0, false)
	palt(person.trans_col, true)
	spr(person.curr_anim[person.frame],	person.x, person.y, 1, 2, person.flip)
	pal()

	-- person still alive?
	if person.state <= 7 then

		-- gun effects
		if person.gun_mode == 0 then
			-- do nothing extra
		elseif person.gun_mode == 1 then
			-- shield mode
			pset(
					person.muz_x,
					person.muz_y, 
					flr(rnd(2))==0 and 7 or 12) --8 or 2)
		else
			-- blast mode
			circfill(
					person.muz_x,
					person.muz_y, 
					flr(rnd(2))==0 and 0 or 1,
					flr(rnd(2))==0 and 7 or 12)
		end

	end
end



function draw_worms() 
	palt(0, false)
	palt(12, true)
 	for w in all(worms) do 
	 	if (debug) draw_hitbox(w)
		-- crawling
		if w.state == 1 or w.state == 2 then
			spr(w.curr_anim[w.frame],	w.x, w.y, 1, 1, w.dir==1, w.state==2)
		elseif w.state == 3 or w.state == 4 then
			spr(w.curr_anim[w.frame],	w.x, w.y, 1, 1)
		end
 	end
 	pal()
end

function draw_shields()
 local col
 for s in all(shields) do    
	if (debug) draw_hitbox(s)
	for p = 1,s.power do
		pset(s.x, s.y-rnd(s.h), 8)
	end
 end
end

function draw_pewpews()
 local col
 for p in all(pewpews) do
	if p.type == 1 then
		-- red pewpew
		line(p.x, p.y, p.x-p.length, p.y, 8)
	else
		-- blast
		rectfill(p.x, p.y-1, p.x-p.length, p.y+1, 12)
		rectfill(p.x, p.y, p.x-p.length, p.y, 7)
		local boom_dist = 1.5*p.vx
		if p.frame < 4 
		 and abs(p.length) > abs(boom_dist) then
			circfill(player.x + boom_dist, p.y, 3, 12)
			circfill(player.x + boom_dist, p.y, 2, 7)
		end
	end
	if (debug) draw_hitbox(p)
 end
end

function draw_hitbox(obj)
	rect(
		obj.x+obj.hitbox.x, 
		obj.y+obj.hitbox.y, 
		obj.x+obj.hitbox.x+obj.hitbox.w, 
		obj.y+obj.hitbox.y+obj.hitbox.h, 8)
	-- top-left
	pset(obj.x+obj.hitbox.x,
			obj.y+obj.hitbox.y,
			12)
end


-- 
-- helper functions
-- 

-- (modified from: https://www.lexaloffle.com/bbs/?pid=20541#p20541)
function collide(obj, other)
    if
				flr(other.x+other.hitbox.x+other.hitbox.w) >= flr(obj.x+obj.hitbox.x) and 
        flr(other.y+other.hitbox.y+other.hitbox.h) >= flr(obj.y+obj.hitbox.y) and
        flr(other.x+other.hitbox.x) <= flr(obj.x+obj.hitbox.x+obj.hitbox.w) and
        flr(other.y+other.hitbox.y) <= flr(obj.y+obj.hitbox.y+obj.hitbox.h)
    then
        return true
    end
end

function center_text(str, y, c0)
  x=31.75-flr((#str*4)/2)
  print(str,x,y,c0)
end


function doshake()
 -- https://www.lexaloffle.com/bbs/?tid=28306
 --
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)
 shakex*=shake
 shakey*=shake
 camera(shakex,shakey)
 shake = shake*0.95
 if (shake<0.05) shake=0
end


-- particles code 
-- https://www.lexaloffle.com/bbs/?tid=28260

function boom(_x,_y,_amount,_angle,_spread_angle,_speed,_lifetime,_cols,_gravity,_floor)
 for i=0,_amount do
  spawn_particle(_x,_y,_angle,_spread_angle,_speed,_lifetime,_cols,_gravity,_floor)
 end
end

function spawn_particle(_x,_y,_angle,_spread_angle,_speed,_lifetime,_cols,_gravity,_floor)
 local new={}
 local angle = _angle-rnd(_spread_angle)+(_spread_angle/2)
 local speed = _speed+rnd(2*_speed)
 new.x=_x
 new.y=_y
 new.dx=sin(angle)*speed
 new.dy=cos(angle)*speed

	new.lifetime = _lifetime
	new.gravity = _gravity
	new.floor = _floor
	new.cols = _cols
 new.age=flr(rnd(_lifetime/3))
 add(particles,new)
end

function update_particles()
 for p in all(particles) do
  if p.age > p.lifetime --80 
   or p.y > 128
   or p.y < 0
   or p.x > 128
   or p.x < 0
   then
   del(particles,p)
  else
   if not p.landed then
	   p.x+=p.dx
	   p.y+=p.dy
   end
   
   if (p.floor and p.y>p.floor) then
    p.landed = true
   end
   p.age+=1
   p.dy+=p.gravity
  end
 end
end

function draw_particles() 
 local col
 for p in all(particles) do
	local phase=p.lifetime/4
  if p.age > phase*3 then col=p.cols[4]
  elseif p.age > phase*2 then col=p.cols[3]
  elseif p.age > phase then col=p.cols[2]  
  else col=p.cols[1] end
  pset(p.x,p.y,col)

 end
end


-- enargy's vector animation (vaca)
-- https://www.lexaloffle.com/bbs/?tid=29757

function get_char(s,e)
  return sub(gloadstring,s or start,e or s or start)
end

function loadfromstring(str)
  gloadstring=str
  if str=='' then return end
  
  vals={}

  frames={}
  fid=0
  fds={}
  flines={}
  frects={}
  fcircs={}
  frames={}
  tfoff=1
  fc=0
  strmod=0
  for s=1,#str do
    if s+strmod<=#str then
      char=get_char(s+strmod)
      if char=='>' then
		      fid+=1
		      loff=0
		      coff=0
		      toff=0
		      roff=0
		      
		      fds[fid]=('0x'..get_char(s+strmod+1,s+strmod+2))+0
		      
		      strmod+=2

		      frames[fid]={}
		      flines[fid]={}
		      fcircs[fid]={}
		      frects[fid]={}
		      if fid>1 then 
		        for i=1,#flines[fid-1] do
		          flines[fid][i]=flines[fid-1][i]
  		        if flines[fid][i]==nil then
  		          flines[fid][i]=-1
  		        end
  		      end
  		      for i=1,#fcircs[fid-1] do
		          fcircs[fid][i]=fcircs[fid-1][i]
  		        if fcircs[fid][i]==nil then
  		          fcircs[fid][i]=-1
  		        end
  		      end
  		      for i=1,#frames[fid-1] do
  		        frames[fid][i]=frames[fid-1][i]
  		        if frames[fid][i]==nil then
  		          frames[fid][i]=-1
  		        end
  		      end
  		      for i=1,#frects[fid-1] do
  		        frects[fid][i]=frects[fid-1][i]
  		        if frects[fid][i]==nil then
  		          frects[fid][i]=-1
  		        end
  		        
  		      end
		      end
		    
		    elseif char=='l' then
		      loff+=1
		      if get_char(s+strmod+1,s+strmod+2) == '-1' then
		        flines[fid][loff]=-1
		      else
				      //setup values
				      //calculate values
				      start=s+strmod
				      start+=1
				      vals={}
				      for i=1,4 do
				        //print(start..':0x'..sub(str,start,start+1))
				        if get_char()=='*' then
				          start+=1
				          mod=-1
				        else
				          mod=1
				        end
						      add(vals,("0x"..get_char(start,start+1))+0)
						      vals[i]*=mod
		  		      start+=2
						    end
						    for i=1,2 do
						      //print(start..':0x'..sub(str,start,start))
				        add(vals,("0x"..get_char())+0)
		  		      start+=1
		  		    end
		  		    vals[8]=vals[6]
		  		    flines[fid][loff]=vals
				      strmod+=10
				    end
		      
		    elseif char=='o' then
		      
		      //add the circ
		      //setup container
		      coff+=1
		      if get_char(s+strmod+1,s+strmod+2) == '-1' then
		        fcircs[fid][coff]=-1
		      else
				      start=s+strmod
				      start+=1
				      vals={}
				      for i=1,3 do
				        if get_char()=='*' then
				          start+=1
				          mod=-1
				        else
				          mod=1
				        end
						      add(vals,("0x"..get_char(start,start+1))+0)
						      vals[i]*=mod
		  		      start+=2
						    end
						    for i=1,2 do
				        add(vals,("0x"..get_char())+0)
		  		      start+=1
		  		    end
		  		    vals[8]=("0x"..get_char())+0
				      fcircs[fid][coff]=vals
				      strmod+=8
		      end
		    elseif char=='t' then
		      //add the tri
		      //setup container
		      toff+=1
		      if get_char(s+strmod+1,s+strmod+2) == '-1' then
		        frames[fid][toff]=-1
		      else
				      //setup values
				      start=s+strmod
				      start+=1
				      vals={}
				      for i=1,3 do
				        //x
				        if get_char()=='*' then
				          start+=1
				          xmod=-1
				        else
				          xmod=1
				        end
				        local x="0x"..get_char(start,start+1)
				        x+=0
						      //y
						      if get_char(start+2)=='*' then
				          start+=1
				          ymod=-1
				        else
				          ymod=1
				        end
						      local y="0x"..get_char(start+2,start+3)
						      y+=0
						      add(vals,{x*xmod,y*ymod})
		  		      start+=4
						    end
						    for i=1,4 do
				        add(vals,("0x"..(get_char()))+0)
		  		      start+=1
		  		    end
		  		    vals[8]=vals[7]
		  		    vals[7]=vals[6]
		  		    vals[6]=vals[5]
				      frames[fid][toff]=vals
				      strmod+=15
		      end
		    elseif char=='r' then
		      //add the rect
		      //setup container
		      roff+=1
		      if get_char(s+strmod+1,s+strmod+2) == '-1' then
		        frects[fid][roff]=-1
		      else
				      start=s+strmod
				      start+=1
				      vals={}
				      for i=1,4 do
				        if get_char()=='*' then
				          start+=1
				          mod=-1
				        else
				          mod=1
				        end
						      add(vals,("0x"..get_char(start,start+1))+0)
						      vals[i]*=mod
		  		      start+=2
						    end
						    for i=1,3 do
				        add(vals,("0x"..get_char())+0)
		  		      start+=1
		  		    end
		  		    
  		  		  vals[8]=vals[7]
				      frects[fid][roff]=vals
				      strmod+=11
				    end
				  end
   end
  end
  lines=flines[1]
  circs=fcircs[1]
  tris=frames[1]
  rects=frects[1]
  loff=1
  coff=1
  toff=1
  roff=1
  
end


function playback_init()
 
  tlines={}
  for i,l in pairs(flines[tfoff]) do
    local td=l
    if td==-1 then
    else
      tlines[i]={}
      for il=1,8 do
        tlines[i][il]=td[il]
      end
    end
 	end
  tcircs={}
  for i,c in pairs(fcircs[tfoff]) do
    local td=c
    if td==-1 then
    else
      tcircs[i]={}
      for il=1,8 do
        tcircs[i][il]=td[il]
      end
    end
  end
  trects={}
  for i,r in pairs(frects[tfoff]) do
    local td=r
    if td==-1 then
    else
      trects[i]={}
      for il=1,8 do
        trects[i][il]=td[il]
      end
    end
  end
  temptris={}
  for i,tri in pairs(frames[tfoff]) do
    local td=tri
    if td==-1 then
    else
      temptris[i]={}
		    local p1=td[1]
      local p2=td[2]
      local p3=td[3]
      temptris[i]={{p1[1],p1[2]},{p2[1],p2[2]},{p3[1],p3[2]},td[4],nil,td[6],td[7],td[8]}
    end
  end

end
function playback_update()
  
  fc +=1
  --percent of second

  if not temptris
    or not tlines
    or not trects
    or not tcircs then
    playback_init() end

  
  if fc >= fds[tfoff]  then
    
    fc = 1
    tfoff+=1
    if tfoff > #frames then
      tfoff=1
			if lstrs[lstr_offset][2] then
				lstr_offset = lstrs[lstr_offset][2]
				next_anim = lstrs[lstr_offset][1]
				loadfromstring(next_anim)
				playback_init()
				playback_update()
			else
				anim_state = 0
				if (anim_post_func) anim_post_func()
			end
    end
    playback_init()
    return

    
  end
  
  
  if tfoff+1 > #frames then return end
  
  local fdp=fc/(fds[tfoff])
  local fd=(fds[foff])

  local af=frames[tfoff]
  local afp=frames[tfoff+1]
  //add pairs
  for tri=1,#temptris do
      local _p=temptris[tri]
      if not _p then
      else
      local _pd=afp[tri]
      local _po=af[tri]
      if not _po then _po=_pd end
      if not _pd or _pd==-1 then
      else
		      for i=1,3 do
		        local p=_p[i]
		        local pd=_pd[i]
		        local po=_po[i]
		        if p[1]
		          != pd[1] then
		          p[1] = po[1]+((pd[1]-po[1])*fdp)
		
		        end
		        if p[2]
		          != pd[2] then
		          p[2] = po[2]+((pd[2]-po[2])*fdp)
		
		        end
		        
		      end
		    end
		    end
    end
    local af=flines[tfoff]
  local afp=flines[tfoff+1]
  //add pairs
  for l=1,#tlines do
      local _p=tlines[l]
      if not _p then
      else
      local _pd=afp[l]
      local _po=af[l]
      if not _po then _po=_pd end
      if not _pd or _pd==-1 then
      else
		      
		        local p=_p
		        local pd=_pd
		        local po=_po
		        for i=1,4 do
		        if p[i]
		          != pd[i] then
		          //todo:try this
		          //as a function..
		          //(if not slower,it
		          //will save tokens)
		          p[i] = po[i]+((pd[i]-po[i])*fdp)
		
		        end
		      end
		    end
		  end
	 end
  local af=fcircs[tfoff]
  local afp=fcircs[tfoff+1]
  //add pairs
  for c=1,#tcircs do
      local _p=tcircs[c]
      if not _p then
      else
      local _pd=afp[c]
      local _po=af[c]
      if not _po then _po=_pd end
      if not _pd or _pd==-1 then
      else
		      
		        local p=_p
		        local pd=_pd
		        local po=_po
		        for i=1,3 do
		        if p[i]
		          != pd[i] then
		          p[i] = po[i]+((pd[i]-po[i])*fdp)
		
		        end
		        end
		      end
		      end
		    end
					 local af=frects[tfoff]
			  local afp=frects[tfoff+1]
			  
			  //add pairs
			  for r=1,#trects do
      local _p=trects[r]
      if not _p then
      else
      local _pd=afp[r]
      local _po=af[r]
      if not _po then _po=_pd end
      if not _pd or _pd==-1 then
      else
		      
		        local p=_p
		        local pd=_pd
		        local po=_po
		        for i=1,4 do
				        if p[i]
				          != pd[i] then
				          p[i] = po[i]+((pd[i]-po[i])*fdp)
				
				        end
				      end
		        
		      end  
		      end
		    end
end
function playback_draw(foff, type)
  
  if not foff then foff=tfoff end
  local _tt
  if temptris then
    _tt=temptris
  else
    _tt=frames[foff]
  end
  local _ll
  if tlines then
    _ll=tlines
  else
    _ll=lines
  end
  local _cc
  if tcircs then
    _cc=tcircs
  else
    _cc=circs
  end
  local _rr
  if trects then
    _rr=trects
  else
    _rr=rects
  end


  local mind=5
  local maxd=5
  
  //todo:pre-arrange ordered
  //     lists
  //   ...
  // update ordered tables
  //only at start of keyframe..
  
  local tdraw_order={}
  
  //add pairs
  for t=1,#_tt do
    if _tt[t] != -1 and _tt[t] then
		    local dord = _tt[t][8] or 5
		    if not tdraw_order[dord] then
		      tdraw_order[dord]={}
		      mind=min(mind,dord)
		      maxd=max(maxd,dord)
		    end
		    add(tdraw_order[dord],_tt[t])
		  end
  end
  
  local ldraw_order={}
  //add pairs
  for l=1,#_ll do
    if _ll[l]!=-1 and _ll[l] then
		    local dord = _ll[l][8] or 5
		    if not ldraw_order[dord] then
		      ldraw_order[dord]={}
		      mind=min(mind,dord)
		      maxd=max(maxd,dord)
		    end
		    add(ldraw_order[dord],_ll[l])
		  end
  end
  
  local cdraw_order={}
  //add pairs
  for c=1,#_cc do
    if _cc[c]!=-1 and _cc[c] then
		    local dord = _cc[c][8] or 5
		    if not cdraw_order[dord] then
		      cdraw_order[dord]={}
		      mind=min(mind,dord)
		      maxd=max(maxd,dord)
		    end
		    add(cdraw_order[dord],_cc[c])
		  end
  end
  
  local rdraw_order={}
  //add pairs
  for r=1,#_rr do
    if _rr[r]!=-1 and _rr[r] then
		    local dord = _rr[r][8] or 5
		    if not rdraw_order[dord] then
		      rdraw_order[dord]={}
		      mind=min(mind,dord)
		      maxd=max(maxd,dord)
		    end
		    add(rdraw_order[dord],_rr[r])
		  end
  end

  ob=nil
  tt=nil
  
  for dord=mind,maxd do
  local cc = cdraw_order[dord]
  
  
  if cc then
    //pairs
    for i=1,#cc do
      if cc[i][5]!=1 then
        circ(cc[i][1],cc[i][2],cc[i][3],cc[i][4])
      else
        circfill(cc[i][1],cc[i][2],cc[i][3],cc[i][4])
      end
    end
  end
  local rr = rdraw_order[dord]
  if rr then
    //add pairs
    for i=1,#rr do
      if rr[i][6]!=1 then
        rect(rr[i][1],rr[i][2],rr[i][3],rr[i][4],rr[i][5])
      else
        rectfill(rr[i][1],rr[i][2],rr[i][3],rr[i][4],rr[i][5])
      end
    end
  end
  local ll= ldraw_order[dord]
  if ll then
    //add pairs
    for i=1,#ll do
      line(ll[i][1],ll[i][2],ll[i][3],ll[i][4],ll[i][5])
    end  
  end
  
  local tt = tdraw_order[dord]
  
  
  if tt then
    //add pairs
    for tri=1,#tt do
    local ttri=tt[tri]
    local tp1={flr(ttri[1][1]),flr(ttri[1][2])}
    local tp2={flr(ttri[2][1]),flr(ttri[2][2])}
    local tp3={flr(ttri[3][1]),flr(ttri[3][2])}
    
    
    x1=tp1[1]
    x2=tp2[1]
    x3=tp3[1]
    y1=tp1[2]
    y2=tp2[2]
    y3=tp3[2]
    
    if ttri[4]!=1 then
      local col=ttri[6]
      line(x1,y1,x2,y2,col)
      line(x2,y2,x3,y3,col)
      line(x3,y3,x1,y1,col)
    else
		    if y2 < y1 then
		      y1,y2=y2,y1
		      x1,x2=x2,x1
		    end
		    if y3 < y2 then
		      y2,y3=y3,y2
		      x2,x3=x3,x2
		    end
		    if y2 < y1 then
		      y1,y2=y2,y1
		      x1,x2=x2,x1
		    end
		    if x1-x2 == 0 then
		      m12=0
		    else
		      m12=(x1-x2)/(y1-y2)
		      if y1-y2==0 then
		        mi2=0
		      end
		    end
		    
		    if x2-x3 == 0 then
		      m23=0
		    else
		      m23=(x2-x3)/(y2-y3)
		      if y2-y3==0 then
		        m23=0
		      end
		    end
		      
		    if x3-x1 == 0 then
		      m13=0
		    else
		      m13=(x3-x1)/(y3-y1)
		      if y3-y1==0 then
		        mi3=0
		      end
		    end
		    
		    sx=x1
		    ex=x1
		    usem23=false
		    if y1==y2 then
		      ex=x2
		      
		    end
		    
		    for scanline=y1,y3 do
		      local pass=true
		    
		      if scanline > 127 or scanline<0 then
		        pass=false
		          
		      end
		    
		        if usem23 then
		          ex+=m23
		        else
		          ex+=m12
		        end
		        sx += m13
		        if scanline>=y2 then
		          if usem23==false then
		            ex=x2
		          end
		          usem23 = true
		          
		        end
		        if scanline==y3 then
		          sx=x3
		          ex=x3
		          if y2==y3 then
		            sx=x2
		            ex=x3
		          end
		        end
		        
		        
		        local col=ttri[6]
		        if blink then
		          col=obj
		          if objs[obj][12]==2 then
		             return
		          end
		        end
		        if band(scanline,1)==1 then
		          col=ttri[7]
		          rectfill(sx,scanline,ex,scanline,col)
		        else
		          rectfill(sx,scanline,ex,scanline,col)
		        end
		      
   end   
  
   
  end end
  end end
  

end
function to_hex(int,places)
  if not int then
  		return '00'
  end
  pre=''
  if int < 0 then
     int=-int
     pre='*'
  end
  hex="0123456789abcdef"
  tens=flr(int/16)
  tens=sub(hex,tens+1,tens+1)
  ones=int%16
  ones=sub(hex,ones+1,ones+1)
  if places then
    return ""..ones
  end
  return pre..tens..ones
end
__gfx__
00000111111111110001110011111111111100111111111111110111111000001119cccccccccccccccc66ccccccccccccccccccccccc6cccccccccccccccccc
00001cccccc11ccc1001c101cccc11ccccc1001c1cccc11cccc101ccccc100005119cccccccccccccccccc67cccccccccccccccccccccccc6ccccccccccccccc
00001cc111c11c1c1001c11cc11c111c1111001c1c11111c11c101c111c1000055115cccccccccc6ccccccc6ccccccccccccccccccccccccccc6cccccccccccc
0001cc1001c11c11c101c11c101c101c11c1111c1c11101c11c101c1001c1000159151cccccccc6cccccccc67ccccccccccccccccccccccccccccc6ccccccccc
0001cc1101c11c11c101c11c101c101c11cccccc1ccc101cccc101c1001c10001551119cccccccc6ccccccc66cccccccccccccccccccccccccccccccc6cccccc
001ccccc11c11c101c11c11c101c101c11c1111c1c11101cc11101c10001c1001111115cccc6ccccccccccc66ccccccccccccccccccccccccccccccccccc6ccc
001cc11cccc11c101c11c11c111c101c11c1001c1c11111c1c1001c10001c10011111159ccccccccccccccc7ccccccccccccccccccccccccccccccc00cccccc6
01cc1001ccc11c1001c1c11cccc1001111c1001c1cccc11c11c101c100001c10111111511ccccccccccccc66cc6ccccccccccccccccccccccccccc80000ccccc
01cc10001cc1111001c1c111111000000111001111111111101101c100001c101155115519ccccccccc666ccccc19cc6cccccccccccccccccccccc000000cccc
1cc1000001c11110001cc100000000011111111111111111100001c1000001c11115555911ccccccccccccccccc159cccccc6cc6c6ccccccccccccc000000ccc
1111000001c11c10001cc10000000001c11ccccc1cccc11c100001c1000001c111111551111cccccccccccccccc155ccccccccccccccccc6c6ccccc0c50c0ccc
0000000001c11c100001c1000000001c11c1111c1c11c11c100001c1000001c111111111511cccccccccccccccc155cc6cccccccccddccccccc6c6c555555555
0000000001c11c100101c100000001c11c10001c1c11c11c100001c100001c1011155115111cccccccccccccccc555cc5ccccccccc5d9cccccccccc155555555
0000000001c11c101c10110000001c11c111111c1cccc11c100001c10001c100111111115116c6cccccc9cccccc555cc5cccccccc5dddccccccccccc11111111
0000000001c11c101c1000000001c11ccccccccc1cc1111c111101c1001c10001111111151111cccc6ccdc6cc6c5559c5ccccccccddddcccccccccc555511155
0000000001c11c11ccc10000001c1111111111111c1c111cccc101c101c100001111111151555cccccccdccccc15515c5c6cccc6cc5dd96cccccccc555555155
0000000001c11c11c1c1000001c11100000000001c11c111111101c11c10000011511111111111ccccccdccccc15515c5cccccccc5ddddccc6c6cc1555555155
0000000001c11c1c101c10001c11c1111111111111111111111111c1c10000001115511111115155cccdddcccc15515c5ccccccddddddddddccc151115155555
0000000001c11ccc101c1111c11ccccccccccccccccccccccccc11cc1000000011111511111155155ddddddddd51515d5dddddddddddd5ddddd1555555515555
0000000001c11cc10001cccc111111111111111111111111111111c1000000001111151111151115555dddddd151515d5dddddddddddd5ddddd1555555111115
0000000001111110000111110000000000000000000000000000011000000000111115111111111111ddddd1111155555ddddddddddd55dddd15555555555555
00000000000000000000000000000000000000000000000000000000000000001111111111111111111155555555555555555555555555555555555555555555
0000000000000000000000000000000000000000000000000000000000000000111111111ddddddddddddddddddd5dddddddddd5dddddddddddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000111111dd5d51111111111111111111111111111111111111111115ddd5555555
0000000000000000000000000000000000000000000000000000000000cccccc11dd5dd55111111111111111111111111111111111111111111111155dd55555
0000000000000000000000000000000000000000000000000000000000ccccccddddd55111111111111111111111111111111111111111111111111115d1d555
00000000000000000000000000000000000000000000000000000000c0ccccccddddd1ddddddddddddd6ddddd1ddddd6ddddddddddddd1dddddddddd6ddddddd
00000000000000000000000000000000000000000000000000000000cc0ccccc1111151111155511111111111511111155511111111115111111511111111111
00000000000000000000000000000000000000000000000000000000cc0cc0cc5555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000cc0c0ccc5555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000cc0c0ccc5555555555555555111111155555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000cc0c0ccc1111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111155555555551111111111111110000000000000000000000000000000000000000000000000000000000000000
11111111111ccc11111ccccccccccccccccccccccc55556c11111111111111cc0000000000000000000000001111111110000000000000000000000000000000
1cc1111116ccccc1111cccccccccccccccccccccccc55ccccccc1111c11ccccc0000000000000000000001111111111111110000000000000000000000000000
cccc11111cccc6c111cccccccccccccccccccccccccc5ccc6cccccccc11ccccc0000000000000000000111111111111111111100000000000000000000000000
cccc1111ccccccc1116ccccccccccccccccccccccccc5cccccccccccc1cccccc0000000000000000001111111111111111111110000000000000000000000000
cccc1111cccccccc11cccccccccccccccccccccccccccccccc6cccccc1ccccc10000000000000000011111111111111111111111000000000000000000000000
cccc1111cccccccc11ccccc6ccccccccccccccccccccccccccccccccc1ccccc10000000000000000111111111111111111111111100000000000000000000000
cccc111ccccccccc11cccccccc6ccccccccccccccccccccccccc6cccc1ccccc10c70000000000001111111111111111111111111110000000000000000000000
cccc111ccccccccc11ccccccccccc6ccccccccccccccccccccccccccccccccc10c710000000000111111150cc0cc011111111111111000000000001111111111
cccc111ccccccccc11cccccccccccccccccccccccccccccccccccc6cccccccc1cc760000000001111111560cc0cc0c11111111111111000000000c1111111116
ccccc11ccccccccc11ccccccccccccccc6ccccccccccccccccccccccccccccccccc760000000011111156c0cc0cc0cc1111111111115000000000cc11111116c
6ccc611c6ccccccc11cccccccccccccccccccc6ccccccccccccccccc6cccccccccc76600000011111150cc0cc0cc0cc0111111111150c000000c0cc01111116c
ccccc11cccc6cc6c11cccccccccccccccccccccccccccccccccccccccccccccccccc7600000011111560cc0cc0cc0cc0c11111111560c000000c0cc0c111116c
ccccc11ccccccccc11c6ccccccccccccccccccccccc6cccccccccccccc6ccccccccc7660000011111560cc0cc0cc0cc0c11111111560c00000cc0cc0c111116c
155551156969cccc11ccccc6ccc6ccccccccccccccccccccccccccccccccccccccccc760000111111560cc0cc0cc0cc0c11111111560cc0000cc0cc0c11116cc
1555511555559ccc11ccccccccccccc6ccc6cccccccccccc6ccccccccccc6cccccccc760000111111560cc0cc0cc0cc0c11111111560cc0000cc0cc0c11116cc
155551155551555511566cccccccccccccccccccccccccccccccc6ccccccccc1ccccc760000111111560cc0cc0cc0cc0c11111111560cc0000cc0cc0c11116cc
1115511555155555115559ccccccccccccccccccccccccccccccccccccccccc1ccccc760000d11111560cc0cc0cc0cc0c11111111560cc0000cc0cc0c11116cc
11155115dddd55551155556cccccccccccccccc9ccccccccccccccccccccccc1ccccc760000dd1111560cc0cc0cc0cc0c11111111560cc0000cc0cc0c11116cc
115551155555551511555159cccccccccccccccdccccccccccccccccccccccc1ccccc7600006dd111560cc0cc0cc0cc0c11111111560cc0000cc0cc0c11116cc
1155111555555155115515556ccccccccccccccdcdcccccccccdd9ccccccccc1ccccc7600006ddd11150cc0cc0cc0cc0111111111150cc0000cc0cc0111116cc
dddd1116555551551155555555556cccccccccddcd9ccccccdddddd9ccccccc1ccccc76000066ddd11156c0cc0cc0cc11111111111156c0000cc0cc1111116cc
1111111d5551155511555555555556dddddddddddddddddddddddddddddddd11ccccc760000666ddd111560cc0cc0c11111111111111560000cc0c11111116cc
1116111555555555115555555551116ddddddddddddd1ddddddddddddddddd11ccccc7600006666ddd11150cc0cc0111111111111111150000cc0111111116cc
666d1115555555511115555551155555555555dddddd1dddddd11dddddddd111ccccc7600006666dddd1111111111111111111111111110000111111111116cc
6ddd1111555555511111555dddd555555555555ddddd1ddddddddddddddd1111ccccc76000066666dddd111111111111111111111111110000111111111116cc
dddd111115555511111111555555555555555555dd1111ddddd11ddddd111111ccccc760000666666dddd11111111111111111111111110000111111111116cc
1111111111111111111111111111111111111111111111111511115511111111ccccc7600006666666dddd1111111111111111111111110000111111111116cc
5551111111155111111111155555555555551555111111155511115555555511ccccc7600006666666ddddd111111111111111111111110000111111111116cc
55555555555555555555555555555555515155555555555555555555555555556666655000055555555555555555555555555555555555000055555555555555
55151555555555555555555555555555555555555555555555555555555555556665555000055555555555555555555555555555555555000055555555555555
55555555555555555555555555555555555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2222222222222222222222222222222222222222222222222222222222222222
cc67cccccc67cccccc67cccccc67cccccc67cccccc67cccccc67cccccc67cccc2222222222222222222222222222222222222222222222222222222222222222
cc576ccccc576ccccc576cc0cc576cc0cc576ccccc576ccccc576cc0cc576cc0222ccc2222222222222222222222222222222222222222222222222222222222
cc007cc0cc007cc0cc007c0ccc007c0ccc007cc0cc007cc0cc007c0ccc007c0c22ccccc222222222222222222222222222cccc22222222222222222222222222
cc020c0ccc020c0ccc020c76cc020c76cc020c0ccc020c0ccc020c76cc020c7622c777c222277722222000222222222222c77c22222772222220022222222222
cc077c76cc077c76cc07777ccc07777ccc077c76cc077c76cc07777ccc07777c22c777c222277722222000222222222222c77c22222772222220022222222222
cc06777ccc06777cc60677ccc60677cccc06777ccc06777cc60677ccc60677cc2cc777c222277722222000222222222222c7cc22222222222222222222222222
cc0067cccc0067ccc6006cccc6006ccccc0067cccc0067ccc6006cccc6006ccc2c77ccc222722222220222222222222222c7c222222722222220222222222222
cc000ccccc000ccccc000ccccc000ccccc000ccccc000ccccc000ccccc000ccc2c77cccc22722222220222222222222222c7ccc2222722222220222222222222
cc777ccccc777ccccc777ccccc7776cccc777ccccc777ccccc777ccccc7777cc2c77777c22272722222020222222222222c777c2222227222222202222222222
cc677ccccc6777cccc7766cccc77666ccc776cccccc777cccc6777cccc67777c2c77cccc22722222220222222222222222c7ccc2222722222220222222222222
c66777cccc6677cccc776ccccc77c66cc77766cccc7777cccc777ccccc66c77c2c77777c22772722220020222222222222c7cc22222222222222222222222222
c66c77cc00677cccc077ccccc007c00cc77c66cc007ddcccc077ccccc006c00cccc7777c2227227222202202222222222cc77c22222722222220222222222222
000c00cc00c00cccc000ccccc00cc00c000c00cc00c00cccc000ccccc00cc00cc77777cc277227222002202222222222cc7c7c22222272222222022222222222
00cc00cc0cc00cccc000cccc00ccc00000cc00cc0cc00cccc000cccc00ccc000c77777cc272272222022022222222222c7cc7cc2272222222022222222222222
c00c000cccc000cccc000cccc00cccccc00c000cccc000cccc000cccc00cccccc7cc777c277277722002000222222222cc7c77c2227277222202002222222222
00000000cccccccc00000000cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc67cccc00000000ccccccccccccccccc67ccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc576ccc00000000ccccccccccccccccc576cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc007cc000000000ccccccccccccccccc007cccccc67cccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc020c0c00000000cccc67cccccc67ccc020cccccc576ccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc077c7600000000cccc576ccccc576cc077cccccc007ccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc06777c00000000cccc007ccccc007cc077c00ccc020ccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc0067cc00000000cccc020ccccc020cc06777ccc077cccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc288ccc00000000ccc770ccccc007ccc2866cccc077cc000000000000000000cccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccccccccccccccc
00000000cc000ccc00000000cc7770cccc0077ccc000ccccc067777c0000000000000000ccc0cccccccc0ccccccc0ccccccc0cccccccc0cccccccccccccccccc
00000000cc677ccc00000000c0770cccc000777cc677ccccc00666cc0000000000000000c00cccccccc0cccccccc0cccccccc0cccccccc00cccccccccccccccc
00000000cc677ccc00000000c06777ccc077677cc677ccccc07777cc0000000000000000ccccccccccc0cccccccc0cccccccc0cccccccccccccccccccccccccc
00000000cc677ccc00000000cc6677cccc67767766677ccccc6777cc0000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000cc000ccc00000000c0600cccc0600c7700600cccc0600ccc0000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000cc000ccc0000000000600ccc00600ccc00c00ccc00600ccc0000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccc0cccc
00000000cc0000cc00000000000000cc000000cc000000cc000000cc0000000000000000cccccccccccccccccccccccccccccccccccccccccc0000cccc0c0ccc
cccccccccccccccccccccccc22222222222222222222222222222222000000002222222222222222222222222222222222222222222222222222222222222222
cccccccccccccccccccccccc22222222222222222222222222222222000000002222222222222222222222222222222222222222222222222222222222222222
cccccccccccccccccccccccc22222222222222222222222222222222000000002222222222222222222222222222222222222222222222222222222222222222
cccccccccccccccccccccccc22cccc22222222222222222222222222000000002222222222222222222222222222222222222222222222222222222222222222
ccccc49cccc49ccccccccccc22c77c22222772222220022222222222000000002229922222299222222992222229922222299222222992222229922222299222
cccccff0cccf0cccccc9cccc22c77c22222772222220022222222222000000002224f2222224f2222224f2222224f2222224f2222224f2222224f2222224f222
cccccf0ccc0011cccccf0ccc22c7cc2222222222222222222222222200000000222f2222222f2222222f2222222f2222222f2222222f2222222f2222222f2222
cccc0011ccf10fcccc011ccc22c7c222222722222220222222222222000000002220222222202222222022222220222222202222222022222220222222202222
ccccf10fc0f00fccc0f0fccc22c7ccc222272222222022222222222200000000222f2222222f2222222f2222222f2222222f2222222f2222222f2222222f2222
c000f00f00c01ccc00c1cccc22c777c222222722222220222222222200000000222ff222222f2222222f22222220f222222f2222222f2222222f2222222ff222
0000f01f00c65ccc00757ccc22c7ccc222272222222022222222222200000000222ff222222f22222225f22222f52f222225f222222f2222222ff22222f52f22
000cf65f007657cc007c7ccc22c7cc2222222222222222222222222200000000222f5222222522222225622222f522222225622222252222222f522222f52222
ccccc65cccc77ccccccccccc2cc77c22222722222220222222222222000000002226522222256222222562222225622222256222222652222226522222265222
ccccc65ccccccccccccccccccc7c7c22222272222222022222222222000000002262522222752222222562222225262222526222227522222226522222262522
ccccc65cccccccccccccccccc7cc7cc2272222222022222222222222000000002722522222752222222577222252267227226222227622222226772222622572
cccc6776cccccccccccccccccc7c77c2227277222202002222222222000000002272772222277222222772222277272222727722222772222227722222772722
22222222222222222222222222222222000000000000000000000000000000002222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222000000000000000000000000000000002222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222000000000000000000000000000000002222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222000000000000000000000000000000002222222222222222222222222222222222222222222222222222222222222222
22222222222299222222222222222222000000000000000000000000000000002224922222299222222992222222222222222222229922222222222222222222
2222222222224f22222222222222222200000000000000000000000000000000222ff2222224f2222224f2222222222222222222224f22222222222222222222
222222222222f222222222992222222200000000000000000000000000000000222ff222222f2222222f2222222992222992222222f222222229922222222222
22222222222202222222224f22222222000000000000000000000000000000002200002222202222222002222224f22224f22222220220022224f22222222222
222222222222f222222222f2222222220000000000000000000000000000000022f00f22222f222222f0f222222f22222f2222222f0fff22222f222222222222
222222222222f22222222202222222220000000000000000000000000000000022f00f22222f222222f00f2222202222200222222f0222222220220022222222
222222222222f222222222f229f222220000000000000000000000000000000022f65f22222f2222222002f2220f2222f0f222222252222222f0fff222222222
2222222222225222222222f224f0222200000000000000000000000000000000222652222225222222255222220f2222f00f22222252222222f0222222222222
0222222222225222222222f222200222000000000000000000000000000000002226522222252222222625222255f2222552f222226522222225552222222222
99f555222222522222222252222f0022000000000000000000000000000000002226522222252222222622522266522226255222262522222226252222222222
990f25222225222222227252222f7522000000000000000000000000000000002226522222252222222622572765222222622522762522222276522222222222
0ff66772222772222227555222275552000000000000000000000000000000002267762222277222222772722727722227722277272772222766772222222222
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
010200200c7700c7700c7700b7710b7700c7710c7700c7700c7700c7700c7700c7720c7700c7720c7700c7700c7700c7720a7710a7720c7710c7700c7700c7700c7700c7700c7700c7700c7700b7710c7710c770
011000200c1700c1710c1610c1510c1410c1410c1510c1610c1710c1710c1610c1510c1410c1410c1510c1610c1710c1710c1610c1510c1410c1410c1510c1610c1710c1710c1610c1510c1410c1410c1510c161
010300082474024731247212471124711247212473124741000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c1700c1710c1610c1510c1410c1410c1510c1610c1710c1710c1610c1510c1410c1410c1510c1610c1710c1710c1610c1510c1410c1410c1510c1610c1710c1710c1610c1510c1410c1410c1510c161
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000e6251f625001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
010e00001b63410615006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
010600000b57113751025010050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000000000000000000000000000000000000000000000000000000000
010600000d57115751045010050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010700000f6631b6100f6110060100600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010a00060014000131001110010100111001310010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010800000617312271061510623106321064110630100300003000030000300003000030000300003000030000300003000030000300003000030000300003000000000000000000000000000000000000000000
010600003462018611006010060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000000
010300001165029610116502961011640116102964011610296301161011630296101162029600116101160029610116002961000000000000000000000000000000000000000000000000000000000000000000
010300001165029610116502961011640116102964011610296301161011630296101162029610116201161029610116102961029601000010000000000000000000000000000000000000000000000000000000
010a00000467010670046511c641046311c611046111c601005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000000000000000
011000000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000000000000000
010800000805108011000010000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000000000
012800010493000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0140000023a4023a4123a411fa401fa411fa4121a4021a4121a4121a3121a1121a011fa401fa411fa411aa401aa411aa411ea401ea411ea411ea311ea111ea01000001ca401ca411ca311ca111ca010000000000
0120000023a3023a3023a311fa301fa301fa3121a3021a3021a3121a3021a2121a2021a1121a1021a01000001fa301fa301fa311aa301aa301aa311ca301ca301ca311ca301ca211ca201ca101ca111ca0100000
012000000992009920099200992009920099200992009920099200992009920099200992009920099200992004920049200492004920049200492004920049200492004920049200492000920009200292002920
012000000492004920049200492004920049200492004920049200492004920049200492004920049200492000920009200092000920009200092000920009200092000920009200092000920009200092000920
012000000992009920099200992009920099200992009920099200992009920099200992009920099200992004920049200492004920049200492004920049200492004920049200492003920039200392003920
0120000023a3023a3023a311fa301fa301fa3121a3021a3021a3121a3021a2121a2021a1121a1021a01000001fa301fa301fa311aa301aa301aa311ca301ca301ca311ca301ca211ca201fa401fa4021a4021a40
0120000023a3023a3023a311fa301fa301fa3121a3021a3021a3121a3021a2121a2021a1121a1021a01000001fa301fa301fa311aa301aa301aa311ca301ca301ca311ca301ca211ca201ea401ea401ea311ea30
012000000092000920009200092000920009200092000920009200092000920009200092000920009200092000920009200092000920009200092000920009200092000920009200092000920009200092000920
012000001fa301fa301fa301fa311fa301fa211fa201fa1121a3021a3021a3021a3121a3021a2121a2021a1123a3023a3023a3023a3023a3023a3123a3023a2123a2023a1123a1023a1028a3026a3026a3026a30
012000000492004920049200492004920049200492004920049200492004920049200492004920049200492004920049200492004920049200492004920049200492004920049200492000920009200292002920
0120000021a3023a3523a3023a3023a3123a3023a3023a3023a2123a2023a2023a2023a1123a1023a1023a1023a0123a0023a0023a0023a0023a0023a0023a01000000000000000000001fa301fa3021a3021a30
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000000000000000000000001861134641186410c631006210063100621006110060100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000000403004031d413000000040300403046611d601004030000000000000000000000000000000000000000000000f05300000000000040300403030530040300403004030040300403004030000000000
01150000000030f07300003000030f07300003000030f07300003000030f07300003000030f073000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
01 19 17 43 44
00 18 1b 43 44
00 19 17 43 44
00 1a 1c 43 44
00 1d 1e 43 44
02 1f 20 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 15 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
