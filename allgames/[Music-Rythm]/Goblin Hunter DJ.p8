pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function _init()

    -- save / load data & high score --  

    cartdata("goblin_hunter_v1")
    -- dset(0,0)

    new_high_score = false
    high_score = 0

    function manage_high_score(score)
        high_score = dget(0)
        if score > high_score then
            dset(0, score)
            high_score = score
            new_high_score = true
        end
    end


    -- frame count --
    frame_count = 0
    seconds = 0


    function manage_frame_count()

        if frame_count / 61 == 1 then
            frame_count = 0
            seconds = seconds + 1
        end
        
        frame_count = frame_count + 1
    end

    -- game state --

    game_state = "title"

    function manage_game_time()
        if game_state == "play" then
            if seconds >= 180 then
                reset_game()
            end
        end
    end

    function reset_game()
        game_state = "retry"
        manage_high_score(score)
        music(-1, 300)
        camera_x = 0
        camera_y = 0
        frame_count = 0
        seconds = 0
        combo = 0
        misses_this_level = 0
        hits_this_level = 0
        current_jam_level = 1
        gobs = {}
        gobs_in = {}
        gobs_out = {}
        good_hit_row_one = false
        good_hit_row_one_timer = 0
        bad_hit_row_one = false
        bad_hit_row_one_timer = 0
        jam_level_transition = false
        jam_level_transition_timer = 0
        jam_level_transition_message = ""

        create_gobs()
    end


    function start_game()
        game_state = "play"
        total_hits = 0
        total_misses = 0
        score = 0
        high_score = 0
        new_high_score = false
        row_one_incoming = {}
        row_one_miss = {}
        row_one_hit = {}
        update_song(current_jam_level)
    end


    function handle_alt_buttons() 

        if game_state == "title" then

            if btnp(4) then
                start_game()
            end

            if btnp(5) then
                start_game()
            end

        end

        if game_state == "retry" then

            if btnp(4) then
                start_game()
            
            end

            if btnp(5) then
                start_game()
            end
        end
    end

    function draw_title()
        print("goblin hunter: dj edition", 15, 7, 14)

        spr(192, 10, 25,2, 2, false, false)
        print("up", 30, 30, 7)

        spr(194, 10, 45,2, 2, false, false)
        print("right", 30, 50, 7)


        spr(192, 10, 65,2, 2, false, true)
        print("down", 30, 70, 7)

        spr(194, 10, 85,2, 2, true, false)
        print("left", 30, 90, 7)

        spr(196, 58, 25,2, 2)
        print("button 1 (z)", 77, 30, 7)

        spr(198, 58, 45,2, 2)
        print("button 2 (x)", 77, 50, 7)

        spr(14, 80, 78, 2,2, true, false)
        spr(144, 60, 80, 4, 3, true, false)
        spr(133, 64, 75, 2, 2)
        spr(133, 73, 82, 2, 2)

        print("press z or x to begin", 23, 115, 9)
    end

    function draw_retry()

        print("nice set !", 40, 20, 6)

        print("hits:", 40, 30, 8)
        print(total_hits, 63, 30, 9)


        print("misses:", 40, 40, 8)
        print(total_misses, 70, 40, 9)


        print("score:", 40, 50, 8)
        print(score, 65, 50, 9)

        if new_high_score then
            print("new high score:", 20, 65, 12)
            print(high_score, 85, 65, 9)
        else
            print("current high score:", 20, 65, 8)
            print(high_score, 100, 65, 9)
        end

        print("press z or x to spin again", 15, 80, 8)
        
    end


    -- speakers --

    speaker = {
        w = 4,
        h = 4
    }

    speaker_sprites = {
        64,
        68
    }

    amp_stack_coords = {
        {
            x = 37,
            y = - 8,
            s = 1
        },
        {
            x = 20,
            y = 8,
            s = 1
        },
        {
            x = 3,
            y = 24,
            s = 1
        },
        {
            x = - 14,
            y = 40,
            s = 2
        },
        {
            x = 26,
            y = - 16,
            s = 1
        },
        {
            x = 9,
            y = 0,
            s = 2
        },
        {
            x = -8,
            y = 16,
            s = 1
        }
    }

    function draw_amp_stack()
        foreach(amp_stack_coords, function(coord) 
            spr(speaker_sprites[coord.s], coord.x, coord.y, speaker.w, speaker.h)
        end)
    end

    function manage_stack_sprites()
        foreach(amp_stack_coords, function(coord)  
            if frame_count % (flr(rnd(5)) + 3) == 0 then
                if coord.s == 1 then
                    coord.s = 2
                else
                    coord.s = 1
               end
            end
        end)
    end

    -- dj hunter --
    dj_hunter = {
        base = 0,
        bop_base = 2,
        base_arm = 4,
        bop_arm = 6,
        base_arm_2 = 8,
        bop_up = 10,
        base_out = 12,
        base_pump = 14,
        state = "jam",
        flipped = false,
        x = 45,
        y = 30,
        w = 2,
        h = 2
    }

    dj_hunter_sprite_state = 1

    dj_jam_basic = {
        0,
        2
    }

    dj_dance_one = {
        4,
        6
    }

    dj_dance_two = {
        8,
        10
    }

    dj_pump = {
        12,
        14
    }

    dj_freakout = {
        4,
        10,
        6,
        8,
        14,
        12,
        14,
        4,
        6,
        10,
        8
    }

    function manage_dj_anim(anim, random, rate)

        local anim_rate = rate

        if random then
            anim_rate = flr(rnd(14) + 7)
        end

        if frame_count % anim_rate == 0 then
            if dj_hunter_sprite_state >= #anim then
                dj_hunter_sprite_state = 1
            else 
                dj_hunter_sprite_state = dj_hunter_sprite_state + 1
            end
        end
    end

    function manage_dj_by_state()

        if dj_hunter.state == "jam" then
            manage_dj_anim(dj_jam_basic, false, 10)
        elseif dj_hunter.state == "dance_one" then
            manage_dj_anim(dj_dance_one, false, 10)
        elseif dj_hunter.state == "dance_two" then
            manage_dj_anim(dj_dance_two, false, 10)
        elseif dj_hunter.state == "pump" then
            manage_dj_anim(dj_pump, false, 5)
        elseif dj_hunter.state == "freak_out" then
            manage_dj_anim(dj_freakout, true, 5)
        end
    end


    dj_buffer = false
    dj_state_buffer = 0
    dj_state_buffer_cap = 80
    function manage_dj_state()

        if dj_buffer == false then
            if seconds % 5 == 0 then
                
                dj_buffer = true

                local new_state = flr(rnd(4) + 1)

                if new_state == 1 then
                    dj_hunter.state = "jam"
                elseif new_state == 2 then
                    dj_hunter.state = "dance_one"
                elseif new_state == 3 then
                    dj_hunter.state = "dance_two"
                elseif new_state == 4 then
                    dj_hunter.state = "freak_out"
                elseif new_state == 5 then
                    dj_hunter.state = "pump"

                end
            end
        else 
            if dj_state_buffer < dj_state_buffer_cap then
                dj_state_buffer = dj_state_buffer + 1
            else
                dj_buffer = false
                dj_state_buffer = 0
            end
        end
    end


    function dj_state_over_ride(state)

        dj_hunter.state = state
        dj_buffer = true
        dj_state_buffer = 0
    end

    function draw_dj_hunter_by_state()

        if dj_hunter.state == "jam" then
            spr(dj_jam_basic[dj_hunter_sprite_state], dj_hunter.x, dj_hunter.y, dj_hunter.w, dj_hunter.h, dj_hunter.flipped)
        elseif dj_hunter.state == "dance_one" then
            spr(dj_dance_one[dj_hunter_sprite_state], dj_hunter.x, dj_hunter.y, dj_hunter.w, dj_hunter.h, dj_hunter.flipped)
        elseif dj_hunter.state == "dance_two" then
            spr(dj_dance_two[dj_hunter_sprite_state], dj_hunter.x, dj_hunter.y, dj_hunter.w, dj_hunter.h, dj_hunter.flipped)
        elseif dj_hunter.state == "pump" then
            spr(dj_pump[dj_hunter_sprite_state], dj_hunter.x, dj_hunter.y, dj_hunter.w, dj_hunter.h, dj_hunter.flipped)
        elseif dj_hunter.state == "freak_out" then
            spr(dj_freakout[dj_hunter_sprite_state], dj_hunter.x, dj_hunter.y, dj_hunter.w, dj_hunter.h, dj_hunter.flipped)
        end

    end

    -- turn tables --
    tt_base = {
        sprite_number = 128,
        x = 50,
        y = 23,
        w = 4,
        h = 4
    }

    tt_disk = {
        x = 62,
        y = 25,
        w = 2,
        h = 2
    }

    tt_sprites = {
        133,
        135,
        137,
        139
    }

    disk_offset = {
        x = - 10,
        y = 8
    }

    disk_state = 1

    function draw_turntables()
        draw_tt_base()
        draw_disks()
    end

    function draw_tt_base()
        spr(tt_base.sprite_number, tt_base.x, tt_base.y, tt_base.w, tt_base.h)
    end

    function draw_disks()
        spr(tt_sprites[disk_state], tt_disk.x, tt_disk.y, tt_disk.w, tt_disk.h)
        spr(tt_sprites[disk_state], ( tt_disk.x + disk_offset.x ), ( tt_disk.y + disk_offset.y ), tt_disk.w, tt_disk.h)
    end

    function manage_disk_state()
        if frame_count % 5 == 0 then

            local next_state = disk_state + 1

            if next_state > 4 then next_state = 1 end

            disk_state = next_state

        end
    end


    gob_count = 10
    gobs = {}
    gobs_in = {}
    gobs_out = {}


    -- 1 is green, 2 pink
    gob_colors = {
        1,
        2
    }

    gob_basic_1 = {
        34,
        35
    }

    gob_pump_1 = {
        37,
        36
    }

    gob_groove_1 = {
        38,
        39
    }

    gob_rage_1 = {
        40,
        41
    }

    gob_basic_2 = {
        50,
        51
    }

    gob_pump_2 = {
        52,
        53
    }

    gob_groove_2 = {
        54,
        55
    }

    gob_rage_2 = {
        56,
        57
    }


    other_gobs = 5

    function create_gobs()
        for i = 1, gob_count do
            add(gobs, {
                x = flr(rnd(40)) + 85,
                y = flr(rnd(70)) + 10,
                c = flr(rnd(2)) + 1,
                state = "basic",
                sprite_state = 1,
                flipped = false,
                w = 1,
                h = 1,
                v = 1.2,
                tx = 0,
                ty = 0 
            })
        end

        for i = 1, other_gobs do

            add(gobs, {
                x = flr(rnd(90)) + 30,
                y = flr(rnd(10)) + 78,
                c = flr(rnd(2)) + 1,
                state = "basic",
                sprite_state = 1,
                flipped = false,
                w = 1,
                h = 1,
                v = 1.2,
                tx = 0,
                ty = 0 
            })

        end
    end


    function manage_gobs_in()
        for gob in all(gobs_in) do
            if frame_count % 5 == 0 then
                gob.x = gob.x - gob.v
            end
            if gob.x <= gob.tx then
                add(gobs, gob)
                del(gobs_in, gob)
            end
        end
        manage_gobs_in_state()
    end

    function manage_gobs_out()
        for gob in all(gobs_out) do
            if frame_count % 5 == 0 then
                gob.x = gob.x + gob.v
            end
            if gob.x >= gob.tx then
                del(gobs_del, gob)
            end
        end
        manage_gobs_out_state()
    end

    function add_new_gobs(gob_number)

        for i = 1, 3 do

            add(gobs_in, {
                x = flr(rnd(90)) + 100,
                y = flr(rnd(10)) + 78,
                c = flr(rnd(2)) + 1,
                state = "rage",
                sprite_state = 1,
                flipped = false,
                w = 1,
                h = 1,
                v = 1.2,
                tx = flr(rnd(90)) + 30,
                ty = flr(rnd(10)) + 78 
            })

        end

        for i = 1, 5 do

            add(gobs_in, {
                x = flr(rnd(40)) + 120,
                y = flr(rnd(70)) + 10,
                c = flr(rnd(2)) + 1,
                state = "rage",
                sprite_state = 1,
                flipped = false,
                w = 1,
                h = 1,
                v = 1.2,
                tx = flr(rnd(40)) + 85,
                ty = flr(rnd(70)) + 10 
            })

        end

    end

    function remove_gobs(gob_number)

        local gob_indexes = {}

        for i = 1, 8 do
            local value_is_unique = false

            while not value_is_unique do
                local rnd_gob = get_random_gob_index()

                if #gob_indexes < 1 then
                    add(gob_indexes, rnd_gob)
                    value_is_unique = true
                else
                    local found_match = false
                    for i in all(gob_indexes) do
                        if gob_indexes[i] == rnd_gob then
                            found_match = true
                        end
                    end

                    if not found_match then
                        value_is_unique = true
                        add(gob_indexes, rnd_gob)
                    end
                end
            end
        end

        for i in all(gob_indexes) do

            if gobs[i] != nil then
                gobs[i].tx = gobs[i].x + 120
                gobs[i].state = "basic"
                add(gobs_out, gobs[i])
                del(gobs, gobs[i])
            end
        end
    end

    function get_random_gob_index()
        return flr(rnd(#gobs)) + 1
    end

    function manage_gob(gob, anim, random, rate)

        local anim_rate = rate

        if random then
            anim_rate = flr(rnd(8) + 3)
        end

        if frame_count % anim_rate == 0 then

            if gob.sprite_state >= #anim then
                gob.sprite_state = 1
            else
                gob.sprite_state = gob.sprite_state + 1
            end
        end
    end

    function draw_gobs_in()
        for gob in all(gobs_in) do
                if gob.c == 1 then
                    spr(gob_rage_1[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                else
                    spr(gob_rage_2[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                end
        end
    end



    function draw_gobs_out()
        for gob in all(gobs_out) do
                if gob.c == 1 then
                    spr(gob_basic_1[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)
                else
                    spr(gob_basic_2[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)
                end
        end
    end


    gob_state_buffer = false
    gob_state_buffer_timer = 0
    gob_state_buffer_timer_cap = 80

    function manage_gob_state()


        if gob_state_buffer == false then
            if seconds % 5 == 0 then
                gob_state_buffer = true
                for g in all(gobs) do

                    local new_state = flr(rnd(3) + 1)

                    if new_state == 1 then
                        g.state = "basic"
                    elseif new_state == 2 then 
                        g.state = "pump"

                    elseif new_state == 3 then 
                        g.state = "groove"

                    elseif new_state == 4 then
                        g.state = "rage"

                    end 
                end
            end
        else

            if gob_state_buffer_timer < gob_state_buffer_timer_cap then
                gob_state_buffer_timer = gob_state_buffer_timer + 1
            else
                gob_state_buffer = false
                gob_state_buffer_timer = 0
            end
        end
    end

    function manage_gobs_in_state()
        for gob in all(gobs_in) do
            if gob.c == 1 then
                manage_gob(gob, gob_rage_1, false, 5)
            else
                manage_gob(gob, gob_rage_2, false, 5)
            end
        end
    end

    function manage_gobs_out_state()
        for gob in all(gobs_out) do
            if gob.c == 1 then
                manage_gob(gob, gob_basic_1, false, 10)
            else
                manage_gob(gob, gob_basic_2, false, 10)
            end
        end
    end


    function over_ride_gob_state(state)

        for g in all(gobs) do
            g.state = state
        end
    
        gob_state_buffer = true
        gob_state_buffer_timer = 0 

    end

    function manage_gobs_by_state()
        for gob in all(gobs) do

            if gob.state == "basic" then

                if gob.c == 1 then
                    manage_gob(gob, gob_basic_1, false, 10)
                else
                    manage_gob(gob, gob_basic_2, false, 10)
                end
            elseif gob.state == "pump" then

                if gob.c == 1 then
                    manage_gob(gob, gob_pump_1, false, 10)
                else
                    manage_gob(gob, gob_pump_2, false, 10)

                end
            elseif gob.state == "groove" then

                if gob.c == 1 then
                    manage_gob(gob, gob_groove_1, false, 10)
                else
                    manage_gob(gob, gob_groove_2, false, 10)
                end
            elseif gob.state == "rage" then

                if gob.c == 1 then
                    manage_gob(gob, gob_rage_1, false, 5)
                else
                    manage_gob(gob, gob_rage_2, false, 5)
                end
            end
        end
    end

    function draw_gobs_by_state()
        for gob in all(gobs) do
            if gob.state == "basic" then
                if gob.c == 1 then
                    spr(gob_basic_1[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)
                else
                    spr(gob_basic_2[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)
                end
            elseif gob.state == "pump" then

                if gob.c == 1 then
                    spr(gob_pump_1[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                else
                    spr(gob_pump_2[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                end
            elseif gob.state == "groove" then

                if gob.c == 1 then
                    spr(gob_groove_1[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                else
                    spr(gob_groove_2[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                end
            elseif gob.state == "rage" then

                if gob.c == 1 then
                    spr(gob_rage_1[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                else
                    spr(gob_rage_2[gob.sprite_state], gob.x, gob.y, gob.w, gob.h, gob.flipped)

                end
            
            end
        end
    end


    -- score --

    score = 0
    combo = 0
    combo_cap = 7

    function manage_score(postive)

        if positive == 0 then
            score = combo + 1
            if combo < combo_cap then
                combo = combo + 1
            end
        else
             score = score - 1
             combo = 0
        end
    end


    -- hit management --


    target_one = {
        target = 1,
        targets = {
            up = 1,
            right = 2,
            down = 3,
            left = 4
        },
        x = 85,
        y = 97,
        box = {x1=0, y1=0, x2=17, y2=17},
        w = 17,
        h = 17,
        c = 9,
        active = false
    }

    row_one_speed = 1.5
    row_one_frames_buffer = 30
    buffer_counter_one = 0
    row_one_buffer_active = false

    row_one_incoming = {}
    row_one_hit = {}
    row_one_miss = {}

    good_hit_row_one = false
    good_hit_row_one_timer = 0

    bad_hit_row_one = false
    bad_hit_row_one_timer = 0


    function manage_row_one_collisions()
        local hit_check = false
        for h in all(row_one_incoming) do
            if h.x > (target_one.x - 5) then
                if coll(target_one, h) then
                    target_one.active = true
                    target_one.target = h.type
                    hit_check = true
                end
            end
        end

        if not hit_check then
            target_one.active = false
            target_one.target = -1
        end
    end

    function check_key_down_target_one(type)
        if target_one.active and target_one.target == type then
            for h in all(row_one_incoming) do
                if coll(target_one, h) then
                    h.hit = true
                    positive_hit(h)
                    good_hit_row_one = true
                end
            end
        else
            negative_hit()
            bad_hit_row_one = true
        end
    end

    function positive_hit(hit_obj)
        trigger_flare_hit()
        nice_hit()
        local obj_data = assign_hit_obj_sprite(2, hit_obj.type)

        score = score + combo * 1

        hits_this_level = hits_this_level + 1
        total_hits = total_hits + 1

        if combo < combo_cap then
            combo = combo + 1
        end

        hit_obj.sprite = obj_data.sprite
        add(row_one_hit, hit_obj)
        del(row_one_incoming, hit_obj)

    end 

    function negative_hit()
        trigger_flare_miss()
        trigger_screen_shake()
        sfx(33)
    end

    function miss_check()
        for h in all(row_one_incoming) do
            if h.x > (target_one.x + target_one.box.x2 + 2) then
                local obj_data = assign_hit_obj_sprite(3, h.type)
                h.sprite = obj_data.sprite

                score = score - 5
                combo = 0

                misses_this_level = misses_this_level + 1
                total_misses = total_misses + 1
                negative_hit()

                add(row_one_miss, h)
                del(row_one_incoming, h)
            end
        end
    end

    function out_of_bounds_check()

        -- for h in all(row_one_incoming) do
        --     if h.x > 150 then
        --         del(row_one_incoming, h)
        --     end
        -- end

        for h in all(row_one_hit) do
            if h.x > 150 then
                del(row_one_hit, h)
            end
        end

        for h in all(row_one_miss) do
            if h.x > 150 then
                del(row_one_miss, h)
            end
        end

    end

    function manage_gameplay_keydowns()

        if ( btnp( 0 )) then
            check_key_down_target_one(4)
        end

        if ( btnp( 1 )) then
            check_key_down_target_one(2)
        end

        if ( btnp( 2 )) then
            check_key_down_target_one(1)
        end

        if ( btnp( 3 )) then
            check_key_down_target_one(3)
        end

        if ( btnp( 4 )) then
            check_key_down_target_one(5)

        end

        if ( btnp( 5 )) then
            check_key_down_target_one(6)

        end

    end

    function manage_good_hit_row_one()
        if good_hit_row_one then
            good_hit_row_one_timer = good_hit_row_one_timer + 1 
            if good_hit_row_one_timer >= 7 then
                good_hit_row_one = false
                good_hit_row_one_timer = 0
            end
        end
    end

    function manage_bad_hit_row_one()
        if bad_hit_row_one then
            bad_hit_row_one_timer = bad_hit_row_one_timer + 1 
            if bad_hit_row_one_timer >= 7 then
                bad_hit_row_one = false
                bad_hit_row_one_timer = 0
            end
        end
    end


    function manage_hit_creation_row_one()

        if not row_one_buffer_active then
          
            if frame_count % flr(rnd(10) + 5) == 0 then
                make_row_one_object()
                row_one_buffer_active = true
            else
                no_object = true
            end
        else
            no_object = true
        end

        if row_one_buffer_active then
                buffer_counter_one = buffer_counter_one + 1
            if buffer_counter_one >= jam_levels[current_jam_level].spawn_buffer then
                row_one_buffer_active = false
                buffer_counter_one = 0
            end
        end

    end

    function manage_hit_objects()

        for h in all(row_one_incoming) do 
            h.x = h.x + jam_levels[current_jam_level].row_speed
        end


        for h in all(row_one_miss) do 
            h.x = h.x + jam_levels[current_jam_level].row_speed
        end
        

        for h in all(row_one_hit) do 
            h.x = h.x + jam_levels[current_jam_level].row_speed
        end

    end

    function draw_hits(collection)
        for h in all(collection) do
            spr(h.sprite, h.x, h.y, h.w, h.h, h.flipped_x, h.flipped_y)
        end
    end

        numbah = 0
    function make_row_one_object()

        numbah = numbah + 1
        local rndnumb = flr(rnd(jam_levels[current_jam_level].types) + 1)
        local obj_info = assign_hit_obj_sprite(1, rndnumb)
    
        add(row_one_incoming, {
            x = 0,
            y = 98,
            box = {x1=0, y1=0, x2=16, y2=16},
            w = 2,
            h = 2,
            v = row_one_speed,
            hit = false,
            state = 1,
            sprite = obj_info.sprite,
            flipped_x = obj_info.flipped_x,
            flipped_y = obj_info.flipped_y,
            type = rndnumb
        })

    end

    function assign_hit_obj_sprite(state, type)

        flipped_x = false
        flipped_y = false

        if state == 1 then
            if type == 1 then
                sprite = 192
            elseif type == 2 then
                sprite = 194
            elseif type == 3 then
                sprite = 192
                flipped_y = true
            elseif type == 4 then
                sprite = 194
                flipped_x = true
            elseif type == 5 then
                sprite = 196
            elseif type == 6 then
                sprite = 198
            end
        elseif state == 2 then
         
            if type == 1 then
                sprite = 200
            elseif type == 2 then
                sprite = 202
            elseif type == 3 then
                sprite = 200
                flipped_y = true
            elseif type == 4 then
                sprite = 202
                flipped_x = true
            elseif type == 5 then
                sprite = 204
            elseif type == 6 then
                sprite = 206
            end
        elseif state == 3 then
            if type == 1 then
                sprite = 224
            elseif type == 2 then
                sprite = 226
            elseif type == 3 then
                sprite = 224
                flipped_y = true
            elseif type == 4 then
                sprite = 226
                flipped_x = true
            elseif type == 5 then
                sprite = 228
            elseif type == 6 then
                sprite = 230
            end
        end

        return {flipped_x = flipped_x, flipped_y = flipped_y, sprite = sprite}
    end


    function draw_target_one()

        if target_one.active then
            rectfill(target_one.x, target_one.y, target_one.x + target_one.w, target_one.y + target_one.h, 10)
        else
            rectfill(target_one.x, target_one.y, target_one.x + target_one.w, target_one.y + target_one.h, target_one.c)
        end


        if good_hit_row_one then
            rect(target_one.x - 1, target_one.y - 1, target_one.x + target_one.w + 1, target_one.y + target_one.h + 1, 11)
        elseif bad_hit_row_one then
            rect(target_one.x - 1, target_one.y - 1, target_one.x + target_one.w + 1, target_one.y + target_one.h + 1, 8)
        else
            rect(target_one.x - 1, target_one.y - 1, target_one.x + target_one.w + 1, target_one.y + target_one.h + 1, 6)
        end

    end


    function trigger_flare_hit()
        target_flare_hit_active = true
    end

    function trigger_flare_miss()
        target_flare_miss_active = true
    end

    target_flare_hit_timer = 0
    target_flare_hit_active = false
    flare_hit_box = {x = target_one.x, y = target_one.y, x2 = target_one.x + target_one.w, y2 = target_one.y + target_one.h}
    flare_hit_ratio = 1.1
    function manage_target_flare_hit()
        if target_flare_hit_active then
            if frame_count % 5 == 0 then
                target_flare_hit_timer = target_flare_hit_timer + 1
            end
            if target_flare_hit_timer < 4 then
                flare_hit_box.x = flare_hit_box.x - flare_hit_ratio
                flare_hit_box.y = flare_hit_box.y - flare_hit_ratio
                flare_hit_box.x2 = flare_hit_box.x2 + flare_hit_ratio
                flare_hit_box.y2 = flare_hit_box.y2 + flare_hit_ratio
            else
                target_flare_hit_active = false
                target_flare_hit_timer = 0
                flare_hit_box = {x = target_one.x, y = target_one.y, x2 = target_one.x + target_one.w, y2 = target_one.y + target_one.h}
            end
        end
    end


    target_flare_miss_timer = 0
    target_flare_miss_active = false
    flare_miss_box = {x = target_one.x, y = target_one.y, x2 = target_one.x + target_one.w, y2 = target_one.y + target_one.h}
    flare_miss_ratio = .15
    function manage_target_flare_miss()
        if target_flare_miss_active then
            if frame_count % 10 == 0 then
                target_flare_miss_timer = target_flare_miss_timer + 1
            end
            if target_flare_miss_timer < 4 then
                flare_miss_box.x = flare_miss_box.x - flare_miss_ratio
                flare_miss_box.y = flare_miss_box.y - flare_miss_ratio
                flare_miss_box.x2 = flare_miss_box.x2 + flare_miss_ratio
                flare_miss_box.y2 = flare_miss_box.y2 + flare_miss_ratio
            else
                target_flare_miss_active = false
                target_flare_miss_timer = 0
                flare_miss_box = {x = target_one.x, y = target_one.y, x2 = target_one.x + target_one.w, y2 = target_one.y + target_one.h}
            end
        end
    end

    flare_hit_colors = {11,10}
    flare_hit_index = 1
    function draw_target_flare_hit()
        if frame_count % 2 == 0 then
            flare_hit_index = 1
        else
            flare_hit_index = 2
        end
        rect(flare_hit_box.x, flare_hit_box.y, flare_hit_box.x2, flare_hit_box.y2, flare_hit_colors[flare_hit_index])
    end

    flare_miss_colors = {8,13}
    flare_miss_index = 1
    function draw_target_flare_miss()
        if frame_count % 2 == 0 then
            flare_miss_index = 1
        else
            flare_miss_index = 2
        end
        rect(flare_miss_box.x, flare_miss_box.y, flare_miss_box.x2, flare_miss_box.y2, flare_miss_colors[flare_miss_index])
    end


    camera_x = 0
    camera_y = 0
    screen_shake_timer = 0
    screen_shake_active = false
    function manage_screen_shake()
        if screen_shake_active then

            local shake_x = flr(rnd(2))
            local shake_y = flr(rnd(2))

            if screen_shake_timer == 0 then
                camera_x = shake_x
                camera_y = shake_y
            else
                if camera_x > 0 then
                    camera_x = shake_x * -1
                else
                    camera_x = shake_x
                end

                if camera_y > 0 then
                    camera_y = shake_y * -1
                else
                    camera_y = shake_y
                end
            end


            screen_shake_timer = screen_shake_timer + 1


            if screen_shake_timer > 9 then
                screen_shake_timer = 0
                screen_shake_active = false
                camera_x = 0
                camera_y = 0
            end
        end
    end

    function trigger_screen_shake()
        screen_shake_active = true
    end


    -- collion logics --
    function abs_box(s)
    	local box = {}
    	box.x1 = s.box.x1 + s.x
    	box.y1 = s.box.y1 + s.y
    	box.x2 = s.box.x2 + s.x
    	box.y2 = s.box.y2 + s.y
    	return box
    end

    function coll(a,b)

    	local	box_a = abs_box(a)
    	local	box_b = abs_box(b)
    
    	if box_a.x1 > box_b.x2 or
    				box_a.y1 > box_b.y2 or
    				box_b.x1 > box_a.x2 or
    				box_b.y1 > box_a.y2 then
    				return false
    	end
    
    	return true
    end

    -- frame --
    function draw_frame()
        rect(0, 0, 127, 127, 7)
    end


    function draw_hit_tray()
        rect(0, 100, 127, 110, 6)
        rectfill(0, 101, 127, 109, 13)
    end


    -- music -- 

    songs = {
        0,
        6,
        2,
        10
    }

    function update_song(level) 
        music(-1, 300)
        music(songs[level], 0, 10)
    end

    good_sfx = {34,35,36}
    function nice_hit()
        local index_choice = flr(rnd(3)) + 1
        sfx(good_sfx[index_choice])
    end


    -- jam level mgmt --

    total_hits = 0
    total_misses = 0

    current_jam_level = 1

    hits_this_level = 0
    misses_this_level = 0

    jam_level_transition = false
    jam_level_transition_timer = 0
    jam_level_transition_message = ""

    jam_levels = {
        {
            row_speed = .9,
            types = 4,
            hits_to_progress = 25,
            misses_to_fail = 5,
            spawn_buffer = 50
        },
        {
            row_speed = 1.3,
            types = 4,
            hits_to_progress = 40,
            misses_to_fail = 8,
            spawn_buffer = 36
        },
        {
            row_speed = 1.7,
            types = 6,
            hits_to_progress = 55,
            misses_to_fail = 9,
            spawn_buffer = 28
        },
        {
            row_speed = 2.4,
            types = 6,
            hits_to_progress = 35,
            misses_to_fail = 8,
            spawn_buffer = 26
        }
    }

    jam_level_sprites = {
        165,
        167,
        169
    }

    jam_tile_offset = 16


    function draw_level_display()
        local j_count = 1
        local offest = jam_tile_offset

        for j = 1, 8 do

            if j <= 4 then

                if j_count > current_jam_level then
                    spr(165, -15 + offest, 111, 2, 2)
                else
                    spr(167, -15 + offest, 111, 2, 2)
                end
            elseif j > 4 then

                spr(169, -15 + offest, 111, 2, 2)

            end

            j_count = j_count  + 1
            offest = offest + jam_tile_offset 


        end

        offest = offest - (jam_tile_offset * 3)

        print("score: ", -20 + offest, 120, 8)
        print(score, 5 + offest, 120, 9)

    end

    function manage_jam_level()

        if jam_levels[current_jam_level].hits_to_progress <= hits_this_level then
            jam_level_up()
        end

        if jam_levels[current_jam_level].misses_to_fail <= misses_this_level then
            jam_level_down()
        end

    
    end


    function jam_level_up()
        
        hits_this_level = 0
        misses_this_level = 0

        jam_level_transition = true
        row_one_incoming = {}

        over_ride_gob_state("rage")
        dj_state_over_ride("pump")
        get_jam_level_transition_message(true, current_jam_level)

        if #jam_levels != current_jam_level then
            current_jam_level = current_jam_level + 1
            update_song(current_jam_level)
        end

        add_new_gobs()

    end

    function jam_level_down()
        hits_this_level = 0
        misses_this_level = 0

        jam_level_transition = true
        row_one_incoming = {}
        get_jam_level_transition_message(false, current_jam_level)

        if current_jam_level > 1 then
            current_jam_level = current_jam_level - 1
            update_song(current_jam_level)
        end

        remove_gobs()

    end

    function manage_jam_level_transition()

        if frame_count % 60 == 0 then jam_level_transition_timer = jam_level_transition_timer + 1 end

        if jam_level_transition_timer > 4 then
            jam_level_transition = false
            jam_level_transition_timer = 0
        end

    end

    function get_jam_level_transition_message(level_up, level)

        local message = ""

        if level_up then
            if level == 1 then
                message = "spin that shit, dj!"
            elseif level == 2 then
                message = "goblins are vibing!"
            elseif level == 3 then
                message = "goblins bout to rage!"
            elseif level == 4  then
                message = "goblins vibing hard!!"
            end
        else
            if level == 1 then
                message = "not going well!"
            elseif level == 2 then
                message = "get the beat back!"
            elseif level == 3 then
                message = "vibe is damaged!"
            elseif level == 4 then
                message = "get it together!"
            end
            
        end

        jam_level_transition_message = message

    end


    transition_colors = {12,14,7}
    transition_index = 0 
    function draw_jam_level_transition_message()
        if frame_count % 6 == 0 then
            if transition_index < 3 then
                transition_index = transition_index + 1
            else
                transition_index = 0
            end
        end
        print(jam_level_transition_message, 2, 103, transition_colors[transition_index])
    end


    -- testing function --

    function draw_b_boxes()

        rect(target_one.x + target_one.box.x1, target_one.y + target_one.box.y1, target_one.x + target_one.box.x2, target_one.y + target_one.box.y2, 10 )

        for h in all(row_one_incoming) do
            rect(h.x + h.box.x1, h.y + h.box.y1, h.x + h.box.x2, h.y + h.box.y2, 10 )
        end

    end

    ---------------------

    create_gobs()


end

function _update60()

    if game_state == "play" then
        manage_frame_count()
        manage_game_time()
        manage_disk_state()
        manage_stack_sprites()
        manage_dj_state()
        manage_dj_by_state()
        manage_gob_state()
        manage_gobs_by_state()
        manage_gobs_in()
        manage_gobs_out()

        if jam_level_transition then
            manage_jam_level_transition()
        else
            manage_hit_creation_row_one()
            manage_gameplay_keydowns()
        end

        manage_hit_objects()
        manage_row_one_collisions()
        manage_good_hit_row_one()
        manage_bad_hit_row_one()
        manage_target_flare_hit()
        manage_target_flare_miss()
        manage_screen_shake()
        out_of_bounds_check()
        manage_jam_level()
        miss_check()
    else
        handle_alt_buttons()
    end



end

function _draw()
    cls()
    camera(camera_x, camera_y)

    if game_state == "play" then
        map(7, 5, 0, 0, 100, 100)
        draw_amp_stack()
        draw_dj_hunter_by_state()
        draw_turntables()
        draw_gobs_by_state()
        draw_gobs_in()
        draw_gobs_out()
        draw_hit_tray()
        draw_level_display()
        draw_target_one()
        draw_hits(row_one_incoming)
        draw_hits(row_one_hit)
        draw_hits(row_one_miss)

        if jam_level_transition then
            draw_jam_level_transition_message()
        end

        if target_flare_hit_active then
            draw_target_flare_hit()
        end

        if target_flare_miss_active then
            draw_target_flare_miss()
        end
    end

    if game_state == "title" then
        draw_title()
    end

    if game_state == "retry" then
        draw_retry()
    end

    draw_frame()
end

__gfx__
00001111110000000000011111100000000011111100000000000111111000000000111111000000000001111110000000001111110000000000111111000000
00010555501000000000105555010000000105555010000000001055550100000001055550100000000010555501000000010555501000000001055550100000
0011ccbcbc11000000011ccbcbc110000011ccbcbc11000000011ccbcbc110000011ccbcbc11000000011ccbcbc110000011ccbcbc1100000011ccbcbc110000
0011ccbcbc11000000011ccbcbc110000011ccbcbc11000000011ccbcbc110000011ccbcbc11000000011ccbcbc110000011ccbcbc1100000011ccbcbc110000
00015555551000000000155555510000000155555510000000001555555100000001555555100000000015555551000000015555551000000001555555100000
00000555500000000000005555000000000005555000000000000055550000000000055550000000000500555505000000000555500000000050055550005000
000066ccc6000000000066ccc6000000000066ccc6000000000066ccc6000000000066ccc6000000000566ccc6050000000066ccc6000000000566ccc6050000
000656ccc6500000000656ccc6500000000656ccc6555000055556ccc6500000005556ccc6500000000656ccc6500000005556ccc6555000000656ccc6500000
0006566c665000000006566c665000000006566c660000000006666c660500000006666c660500000006666c660000000006666c660000000006666c66000000
0006566c665000000006566c665000000006566c660000000006666c660000000006666c660000000006666c660000000006666c660000000006666c66000000
0000666c660000000000666c660000000000666c660000000000666c660000000000666c660000000000666c660000000000666c660000000000666c66000000
00000111110000000000011111000000000001111100000000000111110000000000011111000000000001111100000000000111110000000000011111000000
00000110110000000000011011000000000001101100000000000110110000000000011011000000000001101100000000000110110000000000011011000000
00001110111000000000111011100000000011101110000000001110111000000000111011100000000011101110000000001110111000000000111011100000
00001110111000000000111011100000000011101110000000001110111000000000111011100000000011101110000000001110111000000000111011100000
00005550555000000000555055500000000055505550000000005550555000000000555055500000000055505550000000005550555000000000555055500000
00000000000000000030300000000000303030030030300000303000003030000030300030303003000000000000000000000000000000000000000000000000
000000022222222003333330003030000333333033333333033333300333333033a3a33303a3a330000000000000000000000000000000000000000000000000
000000211111111233a3a3330333333003a3a33003a3a33003a3a33333a3a3300333333003333330000000000000000000000000000000000000000000000000
00000211111111220333333033a3a3330333333003333330333333300333333303aaa33003aaa330000000000000000000000000000000000000000000000000
000021111111121203aaa3300333333003aaa33003aaa33003aaa33003aaa33003aaa33003aaa330000000000000000000000000000000000000000000000000
00021111111121120333333003aaa330033333300333333003333330033333300333333003333330000000000000000000000000000000000000000000000000
00211111111211123330033333333333333003333330033303300333333003303330033333300333000000000000000000000000000000000000000000000000
02111111112111123330033333300333333003333330033303300333333003303330033333300333000000000000000000000000000000000000000000000000
211111111211111200e0e00000000000e0e0e00e00e0e00000e0e00000e0e00000e0e000e0e0e00e000000000000000000000000000000000000000000000000
22222222211111200eeeeee000e0e0000eeeeee0eeeeeeee0eeeeee00eeeeee0eefefeee0efefee0000000000000000000000000000000000000000000000000
2111111121111200eefefeee0eeeeee00efefee00efefee00efefeeeeefefee00eeeeee00eeeeee0000000000000000000000000000000000000000000000000
21111111211120000eeeeee0eefefeee0eeeeee00eeeeee0eeeeeee00eeeeeee0efffee00efffee0000000000000000000000000000000000000000000000000
21111111211200000efffee00eeeeee00efffee00efffee00efffee00efffee00efffee00efffee0000000000000000000000000000000000000000000000000
21111111212000000eeeeee00efffee00eeeeee00eeeeee00eeeeee00eeeeee00eeeeee00eeeeee0000000000000000000000000000000000000000000000000
2111111122000000eee00eeeeeeeeeeeeee00eeeeee00eee0ee00eeeeee00ee0eee00eeeeee00eee000000000000000000000000000000000000000000000000
0222222220000000eee00eeeeee00eeeeee00eeeeee00eee0ee00eeeeee00ee0eee00eeeeee00eee000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022222222222200000000000000000000222222222222000000000000000000000000000000000000000000000000000000000000000000
00000000000000000211111111112120000000000000000002111111111121200000000000000000000000000000000000000000000000000000000000000000
0000000000000000211dd1111d1211200000000000000000211dd1111d1211200000000000000000000000000000000000000000000000000000000000000000
000000000000000211d11111d121d120000000000000000211d11111d121d1200000000000000000000000000000000000000000000000000000000000000000
0000000000000021111111111211d1200000000000000021111111111211d1200000000000000000000000000000000000000000000000000000000000000000
00000000000002111111111121111120000000000000021111111111211111200000000022222222222222222222222200000000000000000000000000000000
00000000000021111111111211111120000000000000211111111112111111200000000000000000000000000000000022000000000000000000000000000000
000000000002111111111121ddd11120000000000002111111111121ddd111200000000000000000000000000000000200200000000000000000000000000000
00000000002111111111121d111d112000000000002111111111121ddddd11200000000000000000000000000000002000020000000000000000000000000000
0000000002111111111121d1ddd1d1200000000002111111111121dd11ddd1200000000000000000000000000000020000020000000000000000000000000000
000000002111111111121d1dddd1d120000000002111111111121dd1dd1dd1200000000000000000000000000000200000200000000000000000000000000000
0000000211d1111d11211d1dddd1d1200000000211d1111d11211d1ddd1dd1200000000000000000000000000002000002222222222222220000000000000000
000000211d1111d11211d1dd1dd1d120000000211d1111d11211dd1d1d1dd1200000000000000000000000000020000020000000000000000000000000000000
000002111111111121d1d1d1d1d1d120000002111111111121d1d1dd1d1dd1200000000000000000000000000200000200000000000000000000000000000000
00002222222222221d1d1d1d1d1d112000002222222222221d1dd1d1d1dd11200000000000000000000000002000002000000000000000000000000000000000
00002111111111121d1d1dd1dd1d1d2000002111111111121d1dd1ddd1dd1d200000000000000000000000020000020000000000000000000000000000000000
000021dd1111dd12111d1dddd1d11200000021dd1111dd12111dd1dd1dd112000000000000000000000000200000200000000000000000000000000000000000
000021d111111d12111d1dddd1d12000000021d111111d12111dd1dd1dd120000000000000000000000002000002000000000000000000000000000000000000
00002111111111121111d1dd1d12000000002111111111121111dd11dd1200000000000000000000000020000020000000000000000000000000000000000000
00002111111111121111dd11d120000000002111111111121111ddddd12000000000000000000000000200000200000000000000000000000000000000000000
000021111111111211111ddd12000000000021111111111211111ddd120000000000000000000000002000002000000000000000000000000000000000000000
00002111111111121111111120000000000021111111111211111111200000000000000000000000020000020000000000000000000000000000000000000000
00002111111111121d1111120000000000002111111111121d111112000000000000000000000000200000200000000000000000000000000000000000000000
00002111111111121d1d11200000000000002111111111121d1d1120000000002222222222222222000002000000000000000000000000000000000000000000
00002111111111121dd112000000000000002111111111121dd11200000000000000000000000000000020000000000000000000000000000000000000000000
00002111111111121d1120000000000000002111111111121d112000000000000000000000000000000200000000000000000000000000000000000000000000
000021d111111d121112000000000000000021d111111d1211120000000000000000000000000000002000000000000000000000000000000000000000000000
000021d111111d121120000000000000000021d111111d1211200000000000002222222222222222220000000000000000000000000000000000000000000000
000021dd1111dd121200000000000000000021dd1111dd1212000000000000000000000000000000000000000000000000000000000000000000000000000000
00002111111111122000000000000000000021111111111220000000000000000000000000000000000000000000000000000000000000000000000000000000
00000222222222220000000000000000000002222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000ddd6660000000000666666000000000066666600000000006666dd00000000000000000000000000000
000000000000000000000000000000000000000000006dddddd6000000006dddddd6000000006dddddd6000000006ddddddd0000000000000000000000000000
00000000000000000000000000000000000000000006ddddd6dd6000000dddd66ddd60000006dd6dddddd0000006dddddddd6000000000000000000000000000
0000000000000000000000000000000000000000006ddddddd6dd60000ddddddddddd600006dd6dddddddd00006dddddddddd600000000000000000000000000
0000000000000002222222222222200000000000006dddd67dddd60000ddddd76dddd600006dddd67ddddd00006dd6d76d6dd600000000000000000000000000
0000000000000021111111111111120000000000006d6dd76dddd600006dddd67ddddd0000ddddd76dddd600006dd6d67d6dd600000000000000000000000000
0000000000000211111111111111212000000000006dd6ddddddd600006ddddddddddd0000dddddddd6dd600006dddddddddd600000000000000000000000000
00000000000021111111111111121120000000000006dddddddd60000006dd66ddddd000000dddddd6dd60000006dddddddd6000000000000000000000000000
000000000002111111111111112111200000000000006dddddd6000000006dddddd6000000006dddddd600000000ddddddd60000000000000000000000000000
0000000000211111111111111211d1200000000000000666ddd000000000066666600000000006666660000000000dd666600000000000000000000000000000
00000000021111111111111121111120000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
00000000211111111111111211d11200000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
00000002111111111111112111112000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
000000211111111111111211d1120000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
00000211111111111111211111200000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
0000211111111111111211d112000000000000007666666666666667766666666666666777777777777777770000000000000000000000000000000000000000
00021111111111111121111120000000000000007655555555555567763333333333336777777777777777770000000000000000000000000000000000000000
00211111111111111211d11200000000000000007655555555555567763333333333336777777777777777770000000000000000000000000000000000000000
02111111111111112111112000000000000000007655555555555567763333333333336777777777777777770000000000000000000000000000000000000000
222222222222222211d1120000000000000000007655555555555567763333333333336777777777777777770000000000000000000000000000000000000000
21111111111111121111200000000000000000007666666666666667766666666666666777777777777777770000000000000000000000000000000000000000
21111111111111121112000000000000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
21d1111111111d121120000000000000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
21dd11111111dd121200000000000000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
21111111111111122000000000000000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
02222222222222220000000000000000000000007777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
000000cccc00000000000000cc00000000000cccccc0000000000cccccc00000000000bbbb00000000000000bb00000000000bbbbbb0000000000bbbbbb00000
00000cccccc000000000000cccc00000000cccccccccc000000cccccccccc00000000bbbbbb000000000000bbbb00000000bbbbbbbbbb000000bbbbbbbbbb000
0000cccccccc00000000000ccccc000000cccccccccccc0000cccccccccccc000000bbbbbbbb00000000000bbbbb000000bbbbbbbbbbbb0000bbbbbbbbbbbb00
000cccccccccc0000000000cccccc0000cccccc66cccccc00cccc666666cccc0000bbbbbbbbbb0000000000bbbbbb0000bbbbbb33bbbbbb00bbbb333333bbbb0
00cccccccccccc00cccccccccccccc000cccccc66cccccc00ccc66666666ccc000bbbbbbbbbbbb00bbbbbbbbbbbbbb000bbbbbb33bbbbbb00bbb33333333bbb0
0cccccccccccccc0ccccccccccccccc0ccccccc66ccccccccccc66cccc66cccc0bbbbbbbbbbbbbb0bbbbbbbbbbbbbbb0bbbbbbb33bbbbbbbbbbb33bbbb33bbbb
ccccccccccccccccccccccccccccccccccccccc66ccccccccccccccc6666ccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbb3333bbbb
ccccccccccccccccccccccccccccccccccccccc66ccccccccccccc66666cccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbb33333bbbbb
0cccccccccccccc0ccccccccccccccccccccccc66cccccccccccc6666ccccccc0bbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbb3333bbbbbbb
00000cccccc00000ccccccccccccccccccccccc66ccccccccccc666ccccccccc00000bbbbbb00000bbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbb333bbbbbbbbb
00000cccccc00000ccccccccccccccc0ccccccc66ccccccccccc66666666cccc00000bbbbbb00000bbbbbbbbbbbbbbb0bbbbbbb33bbbbbbbbbbb33333333bbbb
00000cccccc000000000000ccccccc000cccccc66cccccc00ccc66666666ccc000000bbbbbb000000000000bbbbbbb000bbbbbb33bbbbbb00bbb33333333bbb0
00000cccccc000000000000cccccc0000cccccc66cccccc00cccccccccccccc000000bbbbbb000000000000bbbbbb0000bbbbbb33bbbbbb00bbbbbbbbbbbbbb0
00000cccccc000000000000ccccc000000cccccccccccc0000cccccccccccc0000000bbbbbb000000000000bbbbb000000bbbbbbbbbbbb0000bbbbbbbbbbbb00
00000cccccc000000000000cccc00000000cccccccccc000000cccccccccc00000000bbbbbb000000000000bbbb00000000bbbbbbbbbb000000bbbbbbbbbb000
00000cccccc0000000000000cc00000000000cccccc0000000000cccccc0000000000bbbbbb0000000000000bb00000000000bbbbbb0000000000bbbbbb00000
00000088880000000000000088000000000008888880000000000888888000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000888800000000888888888800000088888888880000000000000000000000000000000000000000000000000000000000000000000
00008888888800000000000888880000008888888888880000888888888888000000000000000000000000000000000000000000000000000000000000000000
00088888888880000000000888888000088888822888888008888222222888800000000000000000000000000000000000000000000000000000000000000000
00888888888888008888888888888800088888822888888008882222222288800000000000000000000000000000000000000000000000000000000000000000
08888888888888808888888888888880888888822888888888882288882288880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888822888888888888888222288880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888822888888888888822222888880000000000000000000000000000000000000000000000000000000000000000
08888888888888808888888888888888888888822888888888888222288888880000000000000000000000000000000000000000000000000000000000000000
00000888888000008888888888888888888888822888888888882228888888880000000000000000000000000000000000000000000000000000000000000000
00000888888000008888888888888880888888822888888888882222222288880000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000888888800088888822888888008882222222288800000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000888888000088888822888888008888888888888800000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000888880000008888888888880000888888888888000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000888800000000888888888800000088888888880000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000088000000000008888880000000000888888000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00002c2d2c2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b3c3d3c3d2a2b2a2b2a2b2a2b2a2b2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2c2d3a3b2c2d3a3b2c2d2c2d2c2d2c2d2c2d2c2d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3c3d2a2b3c3d2a2b3c3d3c3d3c3d3c3d3c3d3c3d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d3a3b3a3b3a3b2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d3c3d3c3d3c3d3c3d3c3d3c7d3c3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494c3c3d2c2d2c2d2c2d2c2d2c2d7d7d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2c2d3a3b3a3b2c2d2c2d2c2d2c2d2c2d2c2d5b5c5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3c3d2a2b2a2b3c3d3c3d3c3d3c3d3c3d3c6a6b3d3c3d3c3d2c2d3c3d3c3d7d7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3b2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d6a6b2c2d2c2d2c2d2c2d2c2d2c7d7d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c6a6b3d3c3d3c3d3c3d3c3d3c3d3c7d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d6a6b2c2d2c2d2c2d2c2d2c2d2c2d7d7d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c6a6b3d3c3d3c3d3c3d3c3d3c3d3c3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2c2d2c2d2c2d2c2d2c2d2c2d6a6b2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d3c3d3c3d3c3d3c3d3c3d3c6a6b3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d3c3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006a6b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7878787878787878787878797a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010700000017700005000000000000000000000000000000001770000000000000000000000000000000000000177000000000000000000000000000000000000017700000000000000000000000000000000000
010700000017700005000000000000000000000000000000001770000000000000000000000000000000000000177000000000000000011740000001174000000017700000000000000001174000000117400000
010700003000000000306000000000000000000000000000306250000000000000001034500002000000000000000000000000000000000000000000000000003062500000000000000000000000000000000000
0107000030000000003060000000000000000000000000003062500000000000000010335000020000000000000000000000000000000000000000000000000030625000001f3350000010335000000000000000
010700000c4210c4210c4210c4220c4220c4220c4220c4220c4220c4220c4220c4220c4220c425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001342113421134211342213422134221342213422134221342213422134221342213425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000b4000000000000000000c4000000000000000000f4000f4000f4000f4000f4000f400000000000000000000000000000000000000000000000000000b4500000000000000000c450000000000000000
010700001240000000000000000013400000000000000000154001540015400154001540015400000000000000000000000000000000000000000000000000001245000000000000000013450000000000000000
010700000f4220f4220f4220f4220f4220f4220f4220f4220f4220f4220f4220f4220f42500000000000000000000000000000000000000000000000000000000e4220e4220e4220000000000000000000000000
010700001442214422144221442214422144221442214422144221442214422144221442500000000000000000000000000000000000000000000000000000001342213422134220000000000000000000000000
010700001142111421114221142211422114221142211422114221142211422114221142500000000000000000000000000000000000000000000000000000001442214422144221442214422144221442500000
010700001642116421164221642216422164221642216422164221642216422164221642500000000000000000000000000000000000000000000000000000001942219422194221942219422194221942500000
010700000017700005000000000000000000000000000000001770000000000000000017700000001770000000177000000000000000000000000000177000000017700000000000000000000000000000000000
010700002d1150000000000000002d1150000000000000002d1250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700003000000000306000000028345000002734500000306250000000000000001034500002000000000000000000001f345000001a3450000000000000003062500000000000000000000000000000000000
01070000000000000000000000002a1112a11200000000000000000000000000000000000000000000000000000000000000000000002d1112d11200000000002a1112a112000000000000000000000000000000
0107000000000000002a112000002a112000000000000000000000000000000000002811200000000000000000000000000000000000281112811200000000002a1112a112000000000000000000000000000000
01070000000002a1120000000000000000000000000000000000000000000000000028111000000000000000000000000000000000002d111000002d112000002a111000002a112000002d112000000000000000
01070000000002811200000000002d1120000000000000002a112000002a112000002a112000000000000000000000000000000000002b1120000000000000002d112000002d112000002d112000000000000000
01070000001770000500000000003b6150000000000000000017700000000000000000000000000000000000001770000000000000003b6150000000000000000017700000000000000000000000000017700000
01070000001770000500177000003b6150000000000000000017700000000000000000000000000000000000001770000001177000003b6150000000000000000017700000000000000000000000000000000000
01070000001770000500177000003b615000000000000000001770000000000000003b61500000000000000000177000000000000000000000000000000000000017700000000000000000000000000000000000
010700003000000000283450000027345000000000000000306250000010345000000000000002000000000000000000001f345000001a345000000000000000306250000000000000001e345000001f34500000
010700000c4210c4210c4210c4220c4220c4220c4220c4220c4220c4220c4220c4220c4220c425000000000000000000000000000000000001f422000001f42200000000000000000000000001f4220000000000
010700001342113421134211342213422134221342213422134221342213422134221342213425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000b40000000000003441234412344123441234412334123341233412334123341200000000000000000000000000000000000000000000000000000000b4500000000000000000c450000000000000000
010700000b40000000000003941239412394123941239412384123841238412384123841200000000000000000000000000000000000000000000000000000001245000000000000000013450000000000000000
010700000f4220f4220f4220f4220f4220f4220f4220f4220f4220f4220f4220f4220f4250000000000000002c422000002c42200000000000000000000000000e4220e4220e4220000000000000000000000000
010700001442214422144221442214422144221442214422144221442214422144221442500000000000000000000000000000000000000000000000000000001342213422134220000000000000000000000000
01070000114211142111422114221142211422114221142211422114221142211422114250000000000000002a422000002a42200000000000000000000000001442214422144221442214422144221442500000
010700001642116421164221642216422164221642216422164221642216422164221642500000000000000000000000000000000000000000000000000000001942219422194221942219422194221942500000
010700003b0150000000000000003b015000000000000000306250000000000000003b0150000200000000003b0150000000000000003b015000000000000000306250000000000000003b015000000000000000
010700003b0150000000000000003b015000000000000000306250000000000000003b0150000200000000003b0150000000000000003b015000000000000000306250000000000000003b015000003b01500000
00020000100300f0300d0300b03009030070300503003030000300003002000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001d0201e0201f02023020270202e0203102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000270202402021020210202102023020280202c02029100231002310015100171001b1001f10024100000001c100000002010023100000002a1003f1000000000000000000000000000000000000000000
00010000320202e0202a02026020230201e0201a02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 02 43 44
02 01 03 0d 44
01 00 02 04 05
00 01 03 06 07
00 00 02 08 09
02 01 02 0a 0b
01 01 03 0f 44
00 0c 02 10 44
00 00 0e 11 0d
02 0c 03 12 0d
01 13 1f 17 18
00 14 20 19 1a
00 15 1f 1b 1c
02 13 20 1d 1e
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
