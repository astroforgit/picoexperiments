pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- 8-bit emperor

-- set game bounds and define common sizes
local tile = 8;
local letter = tile / 2;
local game = {
	width = tile * 16,
	height = tile * 16,
    border_forgiveness = 4;
	sky_height = tile * 3.5,
	playable_y_start = tile * 6,
	start_offset = 9
}

-- friction applied every frame, greater in sand (sand is terrain 0)
local friction = 0.11
local terrain = 0;

local score = 0;
local high_score = 0;
local t = time(); -- the current time in seconds
local scene_change = time();

ready_to_start = false;
ready_to_restart = false;
ready_to_show = false;

-- dev: show stats
local stats = false;

-- define player size and accelleration capability
local player = {
	alive = true,
	width = tile * 2,
	height = 4, -- simulate "hitbox" being on tires
	sprite_height = tile * 2,
	accelerating = false,
	started_accelerating = false,
	transitioning = false,
	death_length = .6,
	offroad = false,
	accel = {
		x = 0.19,
		decay = 0.09,
		y = 2.3
	},
	max_x_vel = 2.75,
	min_x_vel = -2.6,
	kick = 2,
	x = true, -- set in start_game()
	y = true, -- set in start_game()
	vel = { true, true }, -- set in start_game()
	particles = {},
	sprite_fps = 6,
	sprites = {
		default = { 10, 12 },
		transition = { 14 },
		accelerating = { 42, 44 },
		explosion = { 34, 36, 38, 40 }
	}
}

-- sound channels
local channels = {
	player = 0,
	fx = 1,
	misc = 2
}

-- course props and storage
local progress = 0;
local course_speed = 8.2; -- speed along course in pixels per frame
local total_chunks = 3000; -- number of course chunks to pre-generate
local last_chunk = true;
local course = {};
local visible_course = {};

-- background parallax
local bg = {
	colors = {15, 15, 15, 15, 15, 15, 10},
	sand = 9, -- background sand color
	color_ratio = 1 / 10, -- add discolored particle this much of the time
	height = game.height - game.sky_height, -- height of background (how many rows of particles to process)
	y_rarity = 1, -- calculate every nth row
	x_rarity = 1, -- calculate every nth pixel
	min_depth = game.height / 3, -- y position where we stop calculating any faster ("closer") rows
	speed = course_speed * 7.06, -- multiplier for speed as a function of y position
	damp = 10, -- slow all speeds, real speed = speed / damp
	ticker = 0, -- incremented to draw ever couple frames
	frequency = 30,
	parallax = {} -- object to store colors by coordinate
}

-- chunk properties reference
local chunks = {
	straight = {
		x = 0,
		y = 0,
		offset_start = 0,
		offset_end = 0,
		w = 16,
		h = 3
	},
	down_slight = {
		x = 0,
		y = 21,
		offset_start = 0,
		offset_end = 1,
		w = 16,
		h = 4
	},
	down = {
		x = 0,
		y = 3,
		offset_start = 0,
		offset_end = 2,
		w = 16,
		h = 5
	},
	down_long = {
		x = 16,
		y = 6,
		offset_start = 0,
		offset_end = 3,
		w = 24,
		h = 6
	},
	up_slight = {
		x = 0,
		y = 25,
		offset_start = 1,
		offset_end = -1,
		w = 16,
		h = 4
	},
	up = {
		x = 0,
		y = 8,
		offset_start = 2,
		offset_end = -2,
		w = 16,
		h = 5
	},
	up_long = {
		x = 16,
		y = 0,
		offset_start = 3,
		offset_end = -3,
		w = 24,
		h = 6
	},
	gap = {
		x = 0,
		y = 13,
		offset_start = 0,
		offset_end = 0,
		w = 16,
		h = 3
	},
	gap_up = {
		x = 16,
		y = 24,
		offset_start = 4,
		offset_end = -4,
		w = 16,
		h = 7
	},
	gap_down = {
		x = 16,
		y = 17,
		offset_start = 0,
		offset_end = 4,
		w = 16,
		h = 7
	},
	gap_long = {
		x = 16,
		y = 12,
		offset_start = 1,
		offset_end = 0,
		w = 24,
		h = 5
	},
	gap_mega = {
		x = 40,
		y = 0,
		offset_start = 1,
		offset_end = 0,
		w = 40,
		h = 5
	},
	fence = {
		x = 0,
		y = 16,
		offset_start = 1,
		offset_end = 0,
		w = 16,
		h = 5
	}
}

local terrain_types = {
	'player',
	'road',
	'sand',
	'sky',
	'fence',
	'fence'
}

-- =======================================================
-- function on app start
-- =======================================================

function make_course()

	-- define course
	local offset = game.start_offset;
	for i = 0, total_chunks do
		-- pick a map chunk and save index (for reference in separate object)
		course[i] = select_chunk(i, offset);
		course[i].index = i;

		-- position this chunk based on last offset
		course[i].offset = offset;

		-- save the difference in offset for the next chunk
		offset += course[i].offset_end;
	end

end

local lvl = {
	zero = 4,
	one = 15,
	two = 50,
	three = 100
}

function select_chunk(i, offset)
	local chunk = {};
	local chunk_names = {};

	-- define possible chunks based on how far along we are
	if (i <= lvl.zero) then
		-- keep first few chunks straight
		chunk_names = {'fence'}
	elseif (i > lvl.zero) and (i <= lvl.one) then
		-- gentle ups and downs for level 1
		chunk_names = {'straight', 'straight', 'up_slight', 'up', 'up_long', 'down_slight', 'down', 'down_long', 'gap'}
	elseif (i > lvl.one) and (i <= lvl.two) then
		-- a bit harder
		chunk_names = {'straight', 'straight', 'up', 'up_slight', 'up_long', 'down', 'down_slight', 'down_long', 'gap', 'gap_long', 'fence'}
	elseif (i > lvl.two) and (i <= lvl.three) then
		-- pretty challenging
		chunk_names = {'straight', 'up', 'up_long', 'down', 'down_long', 'gap', 'gap_long', 'gap_mega', 'fence'}
	elseif (i > lvl.three) then
		-- real real tough
		chunk_names = {'straight', 'up', 'up_long', 'down', 'down_long', 'gap', 'gap_up', 'gap_down', 'gap_long', 'gap_mega', 'fence'}
	end

	-- get random chunk
	local chunk_name = chunk_names[max(1, ceil(rnd(#chunk_names)))];

	-- get properties of selected chunk
	chunk = copy_table(chunks[chunk_name]);

	-- no gaps after a long gap
	if ((last_chunk == 'gap_long') or (last_chunk == 'gap_mega')) and (sub(chunk_name, 1, 3) == 'gap') then
		return select_chunk(i, offset)
	end

	-- try again if this takes us off screen
	if ((offset + chunk.h) - chunk.offset_start > game.height / tile)
		or ((offset - chunk.offset_start) + chunk.offset_end < game.playable_y_start / tile) then
		return select_chunk(i, offset)
	end

	-- return chunk if valid
	last_chunk = chunk_name;
	return chunk;
end

function _init()

	-- define bg colors by pixel coordinate
	for y = 0, bg.height / bg.y_rarity do
		for x = 0, game.width / bg.x_rarity do
			if (rnd(1) < bg.color_ratio) then
				bg.parallax[x..','..y] = {
					x = x,
					y = y,
					color = bg.colors[max(1, ceil(rnd(#bg.colors)))]
				}
			end
		end
	end

    -- define particle array
    local sand_colors = {7, 8, 9, 10};
    for i = 1, 80 do
        player.particles[i] = {
            x = -1,
            y = -1,
            age = 0,
            speed = ceil(rnd(6)),
            sand_color = sand_colors[ceil(rnd(#sand_colors))]
        }
    end

	-- build course for this instance of cart
	make_course();

	-- clear screen and start title scene
	set_scene('title');

end

-- =======================================================
-- scene managementf
-- =======================================================

function set_scene(new_scene)

	cls()

	scene_change = time();

	scene = new_scene;

end

function start_game()

	-- reset player position
    player.alive = true;
    player.just_died = false;
    player.started_accelerating = false;
    player.transitioning = false;
	player.x = game.width / 4;
	player.y = (game.start_offset + 1) * tile;
	player.vel.x  = 2;
	player.vel.y = 0;
    player.death_timer = 0;

	-- reset score and timer
	score = 0;
	progress = 0;
	sfx(2, channels.player);

	-- reset visible course
	visible_course = {};
	for i = 1, 3 do
		visible_course[i] = course[i];
	end

	-- set scene (clear screen)
	set_scene('game');

end

-- =======================================================
-- helper functions
-- =======================================================

function ceil(num)
	return flr(num+0x0.ffff)
end

function copy_table(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end

function center_string(the_string)
	return (game.width / 2) - (#the_string * (letter / 2))
end

-- index in array is the number, value is sprite id
local big_numbers = {
    160,
    162,
    164,
    166,
    168,
    170,
    172,
    174,
    192,
    194
}

function draw_big_number(number, x, y)

    -- don't draw any multi digit number
    if (number > 9) then
        return false;
    end

    spr(big_numbers[number + 1], x, y, 2, 2);

end

local number_names = { 'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine' }

function number_name(number)

    return number_names[number];

end

-- =======================================================
-- title scene
-- =======================================================

function title_update()

	-- start game on button press, if ready
	ready_to_start = t > 2;

	-- show instructions
	show_instructions = t > 1;

	if (btn(4)) and (ready_to_start) then
		sfx(6, channels.misc);
		set_scene('intro');
	end

end

function title_draw()

	-- draw awful title sprite
	local title_width = 16;
	local title_height = 6;
	local title_y = 1;
	spr(64, (game.width / 2) - ((title_width * tile) / 2), title_y * tile, title_width, title_height);

	-- show credits
    local credit_string_1 = "based on 'black emperor'";
    local credit_string_2 = "by tomas vicuna";
	print(credit_string_1, center_string(credit_string_1), (((title_height + title_y) * tile) + (tile * 0)), 7);
	print(credit_string_2, center_string(credit_string_2), (((title_height + title_y) * tile) + (tile * 1)), 7);
    -- get random color
	local start_colors = {8, 10, 11, 12}
    local random_color = start_colors[(ceil(t * 10) % #start_colors) + 1];

	if (show_instructions) then

	    local accel_string = "'z' to accelerate";
		print(accel_string, center_string(accel_string), (((title_height + title_y) * tile) + (tile * 3)), 7);

		local arrows_string = "'up'/'down' to steer";
		print(arrows_string, center_string(arrows_string), (((title_height + title_y) * tile) + (tile * 4)), 7);

	end

	if (ready_to_start) then

		local start_string = "hit 'z' to begin this course";
		print(start_string, center_string(start_string), (((title_height + title_y) * tile) + (tile * 6)), random_color);

	end

	-- play soun effect when showing instructions
	if (t == 1) or (t == 2) then
        sfx(4, channels.misc);
    end

    local byline_string_1 = "by";
    local byline_string_2 = "walt mitchell";
	print(byline_string_1, game.width - (letter * #byline_string_1), 12, 1);
	print(byline_string_2, game.width - (letter * #byline_string_2), 20, 1);

    local twitter_string_1 = "@tomvicuna";
    local twitter_string_2 = "@waltcodes";
	print(twitter_string_1, 0, game.height - tile, 1);
	print(twitter_string_2, game.width - (letter * #twitter_string_2), game.height - tile, 1);

end

-- =======================================================
-- intro scene
-- =======================================================

function intro_draw()

	local slide_time = .5
	local intro_string = '';

	-- set string based on time passed
	if (time() - scene_change <= slide_time * 1) then

		rectfill(0, 0, game.width, game.height, 8);
		intro_string = 'ready';

	elseif (time() - scene_change > slide_time * 1) and (time() - scene_change <= slide_time * 2) then

		rectfill(0, 0, game.width, game.height, 9);
		intro_string = 'ready set';

	elseif (time() - scene_change > slide_time * 2) and (time() - scene_change <= slide_time * 3) then

		rectfill(0, 0, game.width, game.height, 3);
		intro_string = 'ready set drive';

	else

		-- start game after 3 "slides"
		start_game();

	end

	-- play soun effect on slide change
	if (time() - scene_change == slide_time * 1) or (time() - scene_change == slide_time * 2) then
		sfx(6, channels.misc);
	elseif (time() - scene_change == slide_time * 3) then
		sfx(7, channels.misc);
	end

	-- print the centered string
	print(intro_string, center_string(intro_string), (game.height / 2) - letter, 7)
end

-- =======================================================
-- game scene
-- =======================================================

function game_update_player()

    -- movement up and down
    if (btn(2)) then
        player.y = max(player.y - player.accel.y, game.playable_y_start);
    end
    if (btn(3)) then
        player.y = min(player.y + player.accel.y, game.height - player.height);
    end

    -- use player position on grid to calculate position on current course
    -- all measurements in tiles
    local player_x = (player.x + (player.width/2)) / tile;
    local player_y = (player.y + (player.height/2)) / tile;

    -- default to sand (no map tile)
    terrain = 0

	-- see if within any current caurse chunk and get tile
	local course_width = 0;
	for i = 1, #visible_course do
		local chunk = visible_course[i];
		local mapped_x = player_x + chunk.x - course_width + (progress / tile);
		local mapped_y = player_y + chunk.y - (chunk.offset - chunk.offset_start);

        -- if mapped player position is within a currently visible chunk, get tile
        if (mapped_x < chunk.x + chunk.w)
            and (mapped_x > chunk.x)
            and (mapped_y > chunk.y)
            and (mapped_y < chunk.y + chunk.h) then
            -- get map tile on current course, if within it
            terrain = mget(mapped_x, mapped_y);
        end

        -- count tiles in course so far
        course_width += chunk.w;
    end

    -- offroad friction if not on a map tile
    if (terrain == 0) then
        -- apply extra friction for sand
        player.vel.x -= (friction * 3)

        -- start playing sand effect
        if (player.offroad == false) then
            player.offroad = true
            sfx(3, channels.fx);
        end

    else
        -- otherwise, stop sound effect and apply normal amount of friction
        player.offroad = false;
        player.vel.x -= friction
        sfx(-1, channels.fx);
    end

    -- accellerate or decellerate based on input
    if (btn(4)) then
        player.vel.x = min(player.vel.x + player.accel.x, player.max_x_vel)
        player.accelerating = true;
        player.transitioning = false;

        -- play acceleration sfx and save state
        if (player.started_accelerating == false) then
        	player.transitioning = true;
            sfx(1, channels.player);
            player.started_accelerating = true;
            player.vel.x += player.kick;
        end
    else
        player.vel.x = max(player.vel.x - player.accel.decay, player.min_x_vel);
        player.accelerating = false;
        player.transitioning = false;

        -- play decceleration sfx and save state
        if (player.started_accelerating == true) then
        	player.transitioning = true;
            sfx(2, channels.player);
            player.started_accelerating = false;
            player.vel.x -= player.kick;
        end
    end

    -- up score
    score += 2.5

    -- end game if off screen or hitting obstacle
    if (player.x + player.width < 0 - game.border_forgiveness)
        or (player.x > game.width + game.border_forgiveness)
        or (terrain_types[terrain] == 'fence') then
        game_kill_player()
    end

end

function game_move_player()

    -- apply velocity
    player.x += player.vel.x
    player.y += player.vel.y

end

function game_kill_player()
    player.alive = false;
    player.just_died = true;
    player.vel.x = -(course_speed);
    player.death_timer = time();

    -- stop other sound effects and play game over sound
    sfx(-1, channels.player);
    sfx(-1, channels.fx);
    sfx(0, channels.player)
end

function game_update_particles()

    -- move sand particles
    local max_age = 5;

    for i = 1, #player.particles do
        local particle = player.particles[i];
        particle.x -= particle.speed;
        particle.y += flr(rnd(5)) - 2;

        -- reset particle if over max age
        if (particle.age > max_age) and (player.alive) then
            particle.age = 0;
            player.particles[i].x = player.x;
            player.particles[i].y = player.y + (player.height / 2);
        end

        -- age particle based on if player is offroad or not
        local distance = (terrain == 0) and 5 or 1;
        particle.age += ceil(rnd(3)) / distance;
    end

end

function game_update_course()

    -- move along course
    progress += course_speed; -- course speed in pixels per second

end

function game_update()

    game_update_course();
    game_update_particles();

    if (player.alive) then

        -- if alive, update vel and such based on input
        game_update_player();

    elseif (time() - player.death_timer > player.death_length) then

        -- if player is dead, countdown to game over
        game_over();

    end

    -- move player based on new velocity
    game_move_player()

end

function game_draw_background()

	-- set sky color based on progression
	local sky_color = 12; -- default
	local initial_threshold = 3000;
	local score_level = 2000; --
	if (score > initial_threshold + (score_level * 6)) then
		sky_color = 0;
	elseif (score > initial_threshold + (score_level * 4)) then
		sky_color = 1;
	elseif (score > initial_threshold + (score_level * 3)) then
		sky_color = 2;
	elseif (score > initial_threshold + (score_level * 2)) then
		sky_color = 14;
	elseif (score > initial_threshold + score_level) then
		sky_color = 13;
	end

	-- draw sky
	rectfill(0, 0, game.width, game.sky_height, sky_color)

	-- background mountain
	rectfill(0, game.sky_height - 4, game.width, game.sky_height - 1, 15)

	-- draw background sand
	rectfill(0, game.sky_height, game.width, game.height, bg.sand);

end

function game_draw_score()

	-- position score on sky based on number of characters
	local score_string = ""..flr(score);
    print_number_from_smallest(flr(score), #score_string, game.width - (#score_string * 16) - (tile * 1), (tile * 1));

end

function print_number_from_smallest(number, decimal, x, y)


    -- get last decimal point
    local small_number = number % 10;

    -- draw last decimal point
    draw_big_number(small_number, x + ((decimal - 1) * 16), y)

    -- move on if numbers left
    local new_number = flr(number / 10);
    if (new_number > 0) then
        print_number_from_smallest(new_number, decimal - 1, x, y);
    end

end

function game_draw_parallax()
	for coordinates, value in pairs(bg.parallax) do

		-- calculate x offset from base position, y position, and time
		local base_speed = min(value.y + 1, bg.min_depth) * (bg.speed * bg.y_rarity); -- base row speed is a function of the y position * overall speed
		local offset = flr((t * base_speed) / bg.damp);-- offset from original x is speed over time
		local raw_x = (value.x * bg.x_rarity) - offset -- the raw x position is the original x minus the offset (moving left to right), after damping
		local new_x = raw_x % game.width; -- loop raw x offset within screen bounds

		local newy = (value.y * bg.y_rarity) + game.sky_height; -- y position
		rectfill(new_x, newy, new_x + bg.x_rarity - 1, newy + bg.y_rarity - 1, value.color); -- draw

	end
end

function game_draw_mountain_range(speed, mountain_tile, row)

	-- draw mountains
	local mountain_width = tile * 2;
	local mountain_height = tile;

	for i = 0, ceil(game.width / mountain_width) + 1 do

		-- parallax
		local base_speed = bg.speed;
		local offset = flr((t * (base_speed / speed)) / bg.damp);-- offset from original x is speed over time
		local raw_x = (i * mountain_width) - offset -- the raw x position is the original x minus the offset (moving left to right), after damping
		local new_x = (raw_x % (game.width + mountain_width)) - mountain_width; -- loop raw x offset within screen bounds
		spr(mountain_tile, new_x, game.sky_height - (mountain_height * row), mountain_width / tile, mountain_height / tile);

	end

end

function game_draw_course()

	if (#visible_course < 3) then

	end

	local course_width = 0;
	for i = 1, #visible_course do
		local chunk = visible_course[i];
		local last_chunk_end = course_width - progress;
		local this_chunk_end = last_chunk_end + (chunk.w * tile);

		-- draw map
		map(chunk.x, chunk.y, last_chunk_end, (chunk.offset - chunk.offset_start) * tile, chunk.w, chunk.h);

		-- count course length
		course_width += (chunk.w * tile);

		-- see if previous chunk is off screen and stop tracking it
		if (last_chunk_end < 0) then
			-- todo
		end

		-- get next chunk
		if (last_chunk_end < game.width) and (this_chunk_end > game.width) then
			visible_course[i+1] = course[i+1];
		end

	end

end

function game_draw_particles()

    -- draw if accelerating or in sand
    if (terrain == 0) or (player.accelerating) then
	    for i = 1, #player.particles do
	        local relative_color = (terrain == 0) and 4 or player.particles[i].sand_color;
	        pset(player.particles[i].x, player.particles[i].y, relative_color);
    	end
    end

end

function game_draw_player()

    -- player sprite default
    local spritesheet = player.sprites.default;
    local sprite;
    local frame = (t * player.sprite_fps);

    if (player.alive) then

        if (player.accelerating) then
            spritesheet = player.sprites.accelerating;
        end

        if (player.transitioning) then
        	spritesheet = player.sprites.transition;
        end

	    -- show sprite from selected spritesheet
	    sprite = spritesheet[flr(frame % #spritesheet) + 1];

    else
    	-- show explosion
        local splode = flr(((time() - player.death_timer) / player.death_length) * #player.sprites.explosion) + 1;
        sprite = player.sprites.explosion[splode];
    end

    -- display sprite
	spr(sprite, player.x, player.y - (player.sprite_height - player.height), 2, 2);

end

function game_draw()

	game_draw_background();
	game_draw_parallax();
	game_draw_mountain_range(13, 32, 1.5);
	game_draw_score();
	game_draw_mountain_range(4, 48, 1);
	game_draw_course();
	game_draw_particles();
	game_draw_player();

	if (player.just_died) then
		rectfill(0, 0, game.width, game.height, 7);
		player.just_died = false;
	end

end

-- =======================================================
-- game over scene
-- =======================================================

-- one time function on game over
function game_over()

    ready_to_restart = false;
    ready_to_show = false;
    ready_to_start = false;
    score_shown = false;
    high_score = max(flr(score), high_score);
    last_score = flr(score);
    timer = time();
    sfx(4, channels.player);

    set_scene('game_over');

end

function game_over_update()
	-- restart game on button press, if ready
	ready_to_restart = time() - timer > 2;
    ready_to_show = time() - timer > .5;

    -- play sound effect on score show
    if (score_shown == false) and (ready_to_show) then
        sfx(4, channels.player);
        score_shown = true;
    end

    -- restart on button press
	if (btn(4) and ready_to_restart) then
		sfx(6, channels.fx);
		set_scene('intro');
	end

	-- go back to title after a bit
	if (time() - timer > 15) then
		set_scene('title');
	end

end

function game_over_draw()

	cls();

    -- get random color for backgroind and score
	local score_colors = {8, 10, 11, 12}
    local random_color = score_colors[(ceil(t * 10) % #score_colors) + 1];

    if (ready_to_show) then

        -- show last score
        local score_string = ""..flr(score);
    	print_number_from_smallest(flr(score), #score_string, (game.width / 2) - (#score_string * 8), (tile * 3) + 2);

    	-- default high score message
    	local high_score_string = "high score: "..high_score;
    	local high_score_color = 7;

    	-- new high score styles
    	if (high_score == flr(score)) then
	    	high_score_string = "new high score"
	    	high_score_color = random_color;
	    end

    	print(high_score_string, center_string(high_score_string), (game.height / 2) - (tile * 2), high_score_color);

    else
        -- fill screen with rainbow before showing score
        rectfill(0, 0, game.width, game.height, random_color);
    end

	if (ready_to_restart) then
		-- show message to restart
		local restart_message = 'press \'go\' to restart course'
		local new_course_message = 'restart cart for new course'
		print(restart_message, center_string(restart_message), (game.height / 2) + (tile * 3), 7)
		print(new_course_message, center_string(new_course_message), (game.height / 2) + (tile * 4), 8)
	end

end

-- =======================================================
-- update nad draw run every frame
-- =======================================================

function _update()

	-- save the current time in seconds
	t = time();

	if ( scene == 'title' ) then
		title_update()
	elseif ( scene == 'game' ) then
		game_update()
	elseif ( scene == 'game_over' ) then
		game_over_update()
	end

end

function _draw()

	if ( scene == 'title' ) then
		title_draw();
	elseif ( scene == 'intro' ) then
		intro_draw();
	elseif ( scene == 'game' ) then
		game_draw();
	elseif ( scene == 'game_over' ) then
		game_over_draw();
	end

	if (stats) then
		print("mem "..stat(0), 5, 1, 8)
		print("fps "..stat(1), 5, 9, 8)
	end

	if (log) then
		print(log, 5, 5, 8)
	end

end
__gfx__
00000000888888885555555599999999cccccccc7777777799977777599999999999f95900000000000000000000000000000000000000000000000000000000
00000000888888885555555599999999cccccccc666666669966666659599999999999f500000000000000000000000000000000000000000000077700000000
00700700888888885555555599999999cccccccc5555555599555555959999999999999500000000000000077700000000000000000000000000075500000000
00077000888888885555555599999999cccccccc991ddd69991ddd69999999f99999999500000000000000075500000000000007770000000000077700006000
00077000888888885555555599999999cccccccc9956667999566679599999999999999500000000000000077700000000000007550000000000011100010600
00700700888888885555555599999999cccccccc777777779977777795999999f999995500000000000000d11100600000000007770000000000d11111100d00
00000000888888885555555599999999cccccccc555555559995555559999999999995550000000000000d1111111600000000d1110060000000d1110000aa67
00000000888888885555555599999999cccccccc4441d6449941d64459995999999999590000000000000d1110000d0000000d11111116000000d110aaaa6ad7
000000006666666655555555555555555555555dd555555599999996699999997777779900000000aaaaad11aaaaaa6700000d1100000d0000aad11a88888690
00000000555555555555555555555555555555d99d5555559999996556999999666666690000000000a88d11d8886ad7aaaaad11daaaaa67aa98d11daaaaa860
0000000055555555555555555555555555555d9999d5555599999655556999995555555900000000009999d11daa869000a888d11d886ad700999d11d22292d1
000000005555555555555555555555555555d999999d55559999655555569999991ddd6900000000011109d111229260019999d111aa869001110d1119912711
00000000555555555555555555555555555d99999999d5559996555555556999995666790000000011017d11109920d110107d11122292d111017111000d0101
0000000055555555555555555555555555d9999999999d5599655555555556997777777900000000107067166001d70111716716609927111070671066d01110
000000005555555555555555555555555d999999999999d59655555555555569555555990000000011011600066d101110101600066dd1011101160000000000
000000005555555555555555ddddddddd99999999999999d65555555555555564441d64900000000011100000000111001110000000011100111000000000000
00000007f00000000899000000000000889999880000880000000000000050000000000000000000000000000000000000077700000660000000000000000000
0000007fff0000008999990000000000899999988088888004454405005000000550000000500000000077700006600000075500001006000000000000000000
000007ff7ff0000099aaaa900000000089aaaa998889998805aaaa00500044550500000050000000000075500010060000077700010006770000000000000000
00007ff7f7ff7f0099a77a988009998099a88a999899999854a99a444500444005079050550000000000777001000677000d1111100a6ad70000000000000000
0007ff7fff7ffff09aa77aa9989999989aa88aa9999999984aa999a4444440050057995055005000000d1111100a6ad7000d11000aaaa6900000000000000000
707ffffffff7f7ff9a7777a9999aaa999a8888a99a9aaa994a9999a4484a9944005759655a069005000d11000aaaa690000d1100aa8889600000000000000000
f7ffffffffff7f7f9aaa77aa999a7a999a8888a9999a8a990a999994444a98440099599500569505000d1100aa888960000d110aa8aa92d00000000000000000
ffffffffffffffff999aaaaaaaaa7a999aa888a9aaaa8a980aa999a4aaaa99400009990566669900000d110aa8aa92d0000d11da8a8221d10000000000000000
000000000000000089999aaa77aaaa9989aaaaaa88a9aa9804aa9aaa99a499450000900099649905000d11da8a8220d1000ad11da89117110000000000000000
0000000000000000008999aa77aaa9988999aa9a888aa9980444aa8a99999440000000a079999500000ad11da89107010aaa8d11890dd1010000000000000000
0000000000000000000899aa777aa9988899a99a8888a9990504a8999889940005000a997aa095000aaa8d11890dd0110a999d1166d011100000000000000000
0000000099990000000899aaaaaaa99808899aaa888aa99805004aa9998994450500566999a995050a999d1166d01110a9110d10000000000000000000000000
00000009999f9000000099aaaaaa9998008899aaaaaa9998005004aa999940050050056690995000a9011d100000000010107100000000000000000000000000
009990999999f900000089999999998000089999aaa999880005044400a440050005055500655000107017100000000011716770000000000000000000000000
0999f99999999f900000089999998000000888999999988000000000000005500000000000000000110116770000000010101000000000000000000000000000
99999f99999999f90000000000000000000088888888880000000005500500000000000000000000011100000000000001110000000000000000000000000000
00aaaaaaaaaaaaaa0000aaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaaaaaa00aaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000
00aaaaaaaaaaaaaa0000aaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaaaaaa00aaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000
aa99999999999999aa009999999999999999aa009999999999999999990099999999999999999900000000000000000000000000000000000000000000000000
aa99999999999999aa009999999999999999aa009999999999999999990099999999999999999900000000000000000000000000000000000000000000000000
99999900000099999900999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
99999900000099999900999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
99999900000099999900999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
99999900000099999900999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
009999aaaaaa99ffffffffff99aaaaaa999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
009999aaaaaa99f88888888899aaaaaa999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
00999999999999f88888888899999999999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
00999999999999f88888888899999999999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
aa999900000099449900444499000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
aa99990000009999aa00999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
99999900000099999900999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
99999900000099999900999999000000999999000000009999990000000000000099999900000000000000000000000000000000000000000000000000000000
999999aaaaaa99999900999999aaaaaa99999900aaaaaa999999aaaaaa0000000099999900000000000000000000000000000000000000000000000000000000
999999aaaaaa99999900999999aaaaaa99999900aaaaaa999999aaaaaa0000000099999900000000000000000000000000000000000000000000000000000000
00999999999999990000999999999999999900009999999999999999990000000099999900000000000000000000000000000000000000000000000000000000
00999999999999990000999999999999999900009999999999999999990000000099999900000000000000000000000000000000000000000000000000000000
fffffffffffffffeffffff00000000000fefffffffffffffffffefffffffffffffffeffffffffffffffffff000000fffffffffff0ffffffffffffffffff00000
f888888888888882f888888000000000f82f88888888888888882f888888888888882f8888888888888888880000f88888888888ef8888888888888888880000
f888888888888882f88888880000000f882f88888888888888882f888888888888882f888888888888888888800f8888888888882f8888888888888888888000
f888888888888882f8888888800000f8882f88888888888888882f888888888888882f88888888888888888882f88888888888882f8888888888888888888800
f888888888888882f888888888000f88882f88888888888888882f888888888888882f8888888888888888882f888888888888882f8888888888888888888880
f888888822222222f88888888880f888882f88888882222228882f888888822222222f888888822222288882f8888882222222882f8888888222222888888888
f888888800000000f888888888888888882f88888880000008882f888888800000000f88888880000008882f88888820000000282f8888888000000888888888
f888888800000000f888888828888828882f88888880000008882f888888800000000f88888880000008882f88888800000000082f8888888000000888888888
f888888800000000f888888802888208882f88888880000008882f888888800000000f88888880000008882f88888800000000082f8888888000000888888888
f888888800000000f888888800282008882f88888880000008882f888888800000000f88888880000008882f88888800000000082f8888888000000888888888
f888888877777700f888888800020008882f88888880000008882f8888888ffffff00f88888880000008882f88888800000000082f8888888000000888888888
f888888888888800f888888800000008882f88888880000008882f888888888888800f88888880000008882f88888800000000082f8888888000000888888888
f888888888888800f888888800000008882f8888888ffffff8882f888888888888800f8888888ffffff8882f88888800000000082f8888888ffffff888888882
f888888888888800f888888800000008882f88888888888888882f888888888888800f88888888888888882f88888800000000082f8888888888888888888820
f888888888888800f888888800000008882f88888888888888882f888888888888800f88888888888888882f88888800000000082f8888888888888888888200
f888888822222200f888888800000008882f88888888888888882f888888822222200f88888888888888882f88888800000000082f8888888888888888888800
f888888800000000f888888800000008882f88888888888888882f888888800000000f88888888888888882f88888800000000082f8888888888888888888880
f888888800000000f888888800000008882f88888882222222222f888888800000000f88888882228888882f88888800000000082f8888888222888888888888
f888888800000000f888888800000008882f88888880000000000f888888800000000f88888880002888882f88888800000000082f8888888000288888888888
f888888800000000f888888800000008882f88888880000000000f888888800000000f88888880000288882e888888f0000000f82f8888888000028888888888
f88888887777777ef888888800000008882f88888880000000000f8888888fffffffef8888888000002888828888888fffffff882f8888888000002888888888
f888888888888882f888888800000008882f88888880000000000f888888888888882f88888880000002888828888888888888882f8888888000000288888888
f888888888888882f888888800000008882f88888880000000000f888888888888882f88888880000000288882888888888888882f8888888000000028888888
f888888888888882f888888800000008882f88888880000000000f888888888888882f88888880000000028888288888888888882f8888888000000002888888
f888888888888882f888888800000008882f88888880000000000f888888888888882f88888880000000002888828888888888882f8888888000000000288888
f888888888888882f888888800000008882f88888880000000000f888888888888882f88888880000000000288882888888888880f8888888000000000028888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777777000007777777e00000077777777777770007777777777777007777770000777777777777777777777700777777777777700777777777777777
07888888888888800078888888800000788888888888888078888888888888807888880000788888788888888888888807888888888888887888888888888888
78888888888888880078888888800000788888888888888878888888888888887888880000788888788888888888888878888888888888887888888888888888
78888888888888880000078888800000000000000028888800000000002888887888880000788888788882000000000078888200000000000000000000888888
78888800008888880000078888800000000000000008888800000000000888887888880000788888788880000000000078888000000000000000000007888882
78888800008888880000078888800000000000000008888800000000000888887888880000788888788880000000000078888000000000000000000078888820
7888880000888888000007888880000000000000007888820000000000788882e888880000788888e88888000000000078888000000000000000000788888200
7888880000888888000007888880000000777777778888207777777777888820028888e777888888028888e77777770078888e77777777000000007888882000
78888800008888880000078888800000078888888888820088888888888888800028888888888888002888888888888078888888888888800000078888820000
78888800008888880000078888800000788888000000000000000000002888880000000000888888000000000028888878888000000888880000788888200000
78888800008888880000078888800000788880000000000000000000000888880000000000888888000000000008888878888000000888880007888882000000
78888800008888880000078888800000788880000000000000000000000888880000000000888888000000000008888878888000000888880078888820000000
7888887777888888000007888880000078888800000000000000000000e888880000000000888888000000000078888878888000000888880788888200000000
e8888888888888820777788888888880788888e777777777777777777788888200000000008888887777777777888888e8888777777888827888882000000000
02888888888888207888888888888888788888888888888828888888888888200000000000888888e88888888888888202888888888888207888820000000000
00288888888882002888888888888882e88888888888888802888888888882000000000000888888028888888888882000288888888882007888200000000000
00777777777777000077777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07888888888888800788888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888888888888887888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888887888800000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888887888800000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888887888800000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e888800000088882e888800000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02888777777888200288877777788888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888888800028888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888880000000000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888880000000000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888880000000000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888000000888880000000000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e8888777777888820000000000088882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02888888888888200000000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00288888888882000000000000088200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
1111111111111111111111111111111100000000000000000000000000000000161111111111111100060505050505050505000000000000000000000000000000000000000000000000000006050518000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202120202021212020202120202020200000000000000000000001611111111020202020202020202020700000000000000000000000000000000000000000000000000000000000000000008111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131300000000000016111111110202020202020213131313131302020207000000000000000000000000000000000000000000000000000000000000000008120202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111700000000000000000011111111111112120202020202131313131400000000000002020207000000000000000000000000000000000000000000000000000000000000000000081313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202120202020211111111170000000012121212121212121313131314000000000000000000000000060505050505050505000000000000000000000000000000000000000000000006050505050518000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313120212020202021111111113131313131313140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000151313131312020212120211111111111111170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000015131313131302020202020202021111111117000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000016111111111113131313131302020202020202111111111700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000161111111112020212020200000000000015131313130202121212121211111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111120202020202131313131300000000000000000000001513131313121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1202020202021313131314000000000000000000000000000000000000000000151313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313140000000000000000000000000000000000000006050518000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111110700000000000008111111111111111111110700000000000000000000000000000000081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212070000000000000000000802121212121212130700000000000000000000000000000000081200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131307000000000000081313131313131313070000000000000000000000000000000008131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000060505050505050505051800000000000000000000000006050505051800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1202020212020202121202020212021212121212121212140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131313131313131314000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000605050505050505050518000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111170000000000000000000000000000001611111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121111111111111100000000000000161212121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131312121212121212121200000000000000151313131313131313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000015131313131313131300000000000000161111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000016111111111111111100000000000000150202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111112121212121212121200000000000000001513131313131313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313140000000000000011111111111117000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000012121212121212170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000013131313131313140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001165013650136501345013450134501345013650136501365028650286502765026650266501745017450154501345013450206501f6501d6501c6501b6501a650074500745006450074500745007450
001300200b62010620156201a6201f6202162021620216202162022620226202362023620246202562026620266202862028620296202a6202a6202c6202d6202f6202f6202f6203062030620306203562035620
001100200762005620026200762003620056200662003620046200662006620016200762004620066200562005620086200162003620086200862008620026200662004620026200162006620066200162007620
00040020186100f610086100f61015140111400e6100e61010610186101061012610146100e6100e61013610126100a6100b610141400f14009610166102161014610156100c6100e61019610166100a61018610
000100002855028550285502865028550285502855028550256502555025650255502555025550255502565028550286502855028550286502855028550286502b5502b5502b5502b6502b6502b5502b6502b550
00020000196501965019650196501a6501a65021650226402264022640206401d6401b64018640166401464012640106400d6400b6400b6400b6400b6400b6400b6400b6400f640146401a64021640276402a640
000100002d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d7502d750
000100003875038750387503875038750387503875038750387503875038750387503875038750387503875038750387503875038750387503875038750387503875038750387503875038750387503875038750
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
