pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--sydney's great rescue
--created by: michael k
--created date: sept 23 2018

--music credit: "8:00pm" from animal crossing
--written by kazumi totaka and kenta nagata


function _init()

music(-1)
t = 0 --time
current_track = 1
next_track = 1
change_music = false

pause_controls = true

game_init = false
game_start = false
game_start_t = 0
game_end = false
game_end_t = 0

start_block = {}
start_block.x = 1
start_block.y = 1
start_block.h = 64
start_block.w = 1

end_block = {}
end_block.x = 656
end_block.y = 424
end_block.w = 8
end_block.h = 32
end_text = false
end_text_1 = "sydney! you're alive!"
end_text_2 = "i can't believe it mel,#i made it back."
end_text_3 = "welcome home, syd."
end_flip = 0
end_flip1 = false
end_flip2 = false
end_flip3 = false
end_flip4 = false
end_flip5 = false
end_flip6 = false
end_flip7 = false
end_flip8 = false
end_flip9 = false
end_flip10 = false
end_flip11 = false
end_flip12 = false

player = {}
    player.x = 36
    player.dx = 0
    player.ddx = 0
    player.y = 64
    player.dy = 0
    player.sprite = 37
    player.moving = false
    player.flipx = false
    player.w = 8
    player.h = 8

cam = {}
    cam.x = 0
    cam.y = 0
col = 7

room = {x=1,y=1}
    room.hiker = 1
    room.journal = 1
    room.ice_block = 1
    room.lamp = 1	
    room.torch = 1
    room.wood = 1
    room.fire = 1

left_bound = {x=0,y=0,w=1,h=128}
right_bound = {x=128,y=0,w=1,h=128}
top_bound = {x=0,y=0,w=128,h=1}
bottom_bound = {x=0,y=128,w=128,h=1}

dust = {}
snow = {}
lamp = {}
flag = {}
jem = {}
hikers = {}
torch={}
fire = {}
wood = {}
ice_blocks = {}
ice_dust = {}

make_lamp()
make_torch()
make_fire()
make_wood()
make_flag()
make_jem()
make_hikers()
make_ice_blocks()

rescued = 0
bubble = false

message = {}
    message.text = ""
    message.index = 0
    message.last = 0
journal = {}
read = 0
make_journal()

left = 0
right = 1
up = 2
down = 3
actx = 4
actc = 5

end


function _draw()

    cls()
    map(0, 48, 0, 0, 16, 16, 0)
    foreach(snow,draw_snow)
    camera(cam.x,cam.y)
    rectfill(0,32*8,16*8-1,48*8-1,0)
    rectfill(65*8,9*8,79*8-1,16*8-1,0)
    map(0,0,0,0,128,128)
    foreach(lamp,draw_lamp)
    foreach(torch,draw_torch)
    foreach(flag,draw_flag)
    foreach(jem,draw_jem)
    foreach(ice_blocks,draw_ice_blocks)
    foreach(ice_dust,draw_dust)
    foreach(hikers,draw_hiker)
    foreach(journal, draw_journal)
    room_fire()
    draw_end_game()

--player
    spr(player.sprite,player.x,player.y,1,1,player.flipx,false)
    if bubble then spr(22,player.x,player.y-8) end
    foreach(dust, draw_dust)
    draw_sleep()

--invisible walls    
    rectfill(21*8,29*8,26*8-1,32*8-1,1)
    rectfill(61*8,8*8,63*8-1,10*8-1,1)
    rectfill(61*8,13*8,63*8-1,15*8-1,1)
    rectfill(110*8,20*8,112*8-1,22*8-1,1)
    rectfill(16*8,22*8,17*8-1,24*8-1,1)
    rectfill(65*8,41*8,67*8-1,42*8-1,1)
    rectfill(77*8,42*8,79*8-1,43*8-1,1)
    
--score and extras
    camera()
    if game_start then score() end
    draw_start_game()
    draw_message()
    the_end()

end

function _update()

    t += 1 --time
    col = 7 --for the score
    bubble = false
    player.moving = false
    player.ddx = 0
    if not pause_controls then
        buttons()
    end
    do_map_collisions()
    do_obj_collisions()
    update_speed()
    foreach(dust, move_dust)
    foreach(ice_dust,move_ice_dust)
    make_snow()
    foreach(snow,move_snow)
    save_hikers()
    fire_torch()
    break_ice_block()
    update_room_obj()
    update_music()
    start_game()
    end_game()
    
end


function update_room_obj()
--this directs the functions to the right part of the list
    if room.x==2 and room.y==1 then
        room.hiker = 1
        room.lamp = 2
        change_music = true
        next_track = 0
    elseif room.x==4 and room.y==1 then
        room.hiker = 2
    elseif room.x==4 and room.y==2 then
        room.ice_block = 1
        room.hiker = 3
    elseif room.x==3 and room.y==2 then
        room.ice_block = 2
        room.hiker = 4
    elseif room.x==2 and room.y==2 then
        room.ice_block = 3
        room.lamp = 3
    elseif room.x==2 and room.y==3 then
        change_music = true
        next_track = 0
    elseif room.x==1 and room.y==2 then
        room.hiker = 5
        room.lamp = 8
    elseif room.x==1 and room.y==3 then
        change_music = true
        next_track = 9
    elseif room.x==5 and room.y==2 then
        room.ice_block = 4
    elseif room.x==7 and room.y==2 then
        change_music = true
        next_track = 0
    elseif room.x==8 and room.y==2 then
        change_music = true
        next_track = 9
    elseif room.x==7 and room.y==3 then
        room.ice_block = 5
        room.torch = 2
        room.hiker = 7
    elseif room.x==6 and room.y==2 then
        room.hiker = 6
        room.fire = 2
        room.wood = 2
        room.lamp = 7
    elseif room.x==5 and room.y==3 then
        room.hiker = 8
    elseif room.x==4 and room.y==3 then
        room.hiker = 9
        room.ice_block = 6
    elseif room.x==6 and room.y==3 then
        room.hiker = 10
    elseif room.x==6 and room.y==4 then
        change_music = true
        next_track = 0
    elseif room.x==3 and room.y==4 then
        room.hiker = 11
        room.ice_block = 7
    elseif room.x==4 and room.y==4 then
        room.hiker = 12
    end
end

function update_music()
    if change_music == true then
        if next_track ~= current_track then
            current_track = next_track
            change_music = false
            music(current_track,0,3)
        else
            change_music = false
        end
    end
end

function start_game()

    if t<270 then
        start_block.x = player.x
    else
        start_block.x = 0
    end

    if btnp(actc) and t>275 and not game_init then
        game_init = true
        sfx(3)
    end

    if game_init then
        game_start_t += 1
    end

    if game_start_t == 45 then
        pause_controls = false
        game_start = true
    end
end

function draw_sleep()
    if game_start == false then
        if t%40 < 10 then
            spr(38,42,64)
        elseif t%40 < 20 then
            spr(38,44,62)
        elseif t%40 < 30 then
            spr(38,43,60)
        end
    end
end


function draw_start_game()

    local color
    if not game_init then
        color = 7
    else color = flr((game_start_t%4)/2)+6
    end

    if game_start == false then
        print("sydney's great rescue",23,15,14)
        print("sydney's great rescue",24,14,13)
        print("sydney's great rescue",23,14,color)
        
        rectfill(41,25,89,31,0)
        print("move: arrows",42,26,color)
        
        rectfill(41,33,69,39,0)
        print("jump: z",42,34,color)
        
        rectfill(41,41,77,47,0)
        print("action: x",42,42,color)
        
        rectfill(33,53,97,59,0)
        print("press x to start",34,54,color)

    if t < 270 then
        rectfill(0,0,128,128,0)
    end

    end
end

function score()
    rectfill(71,114,128,119,1)
    rectfill(71,121,128,126,1)
    print("rescued: "..rescued.."/12",72,122,col)
    print("journal: "..read.."/12",72,115,col)
end

function end_game()

    if collide(player,end_block) then
        pause_controls = true
        game_end = true
    end

    if game_end then
        game_end_t += 1
    end
    
    if game_end_t > 30 and game_end_t <145 then
        player.dx = 0.75
        player.moving = true
        player.sprite = flr((game_end_t%8/2))
    elseif game_end then player.dx = 0
    end

    if game_end_t > 140 and game_end_t <220 then
        end_text = true
        message.text = end_text_1
    elseif game_end_t > 230 and game_end_t <340 then
        end_text = true
        message.text = end_text_2
    elseif game_end_t > 350 and game_end_t <440 then
        end_text = true
        message.text = end_text_3
    else end_text = false
    end

end

function draw_end_game()

    end_flip = flr(rnd(45))

    if end_flip==1 then end_flip1=true elseif end_flip==2 then end_flip1=false end
    if end_flip==3 then end_flip2=true elseif end_flip==4 then end_flip2=false end
    if end_flip==5 then end_flip3=true elseif end_flip==6 then end_flip3=false end
    if end_flip==7 then end_flip4=true elseif end_flip==8 then end_flip4=false end
    if end_flip==9 then end_flip5=true elseif end_flip==10 then end_flip5=false end
    if end_flip==11 then end_flip6=true elseif end_flip==12 then end_flip6=false end
    if end_flip==13 then end_flip7=true elseif end_flip==14 then end_flip7=false end
    if end_flip==15 then end_flip8=true elseif end_flip==16 then end_flip8=false end
    if end_flip==17 then end_flip9=true elseif end_flip==18 then end_flip9=false end
    if end_flip==19 then end_flip10=true elseif end_flip==20 then end_flip10=false end
    if end_flip==21 then end_flip11=true elseif end_flip==22 then end_flip11=false end
    if end_flip==23 then end_flip12=true elseif end_flip==24 then end_flip12=false end
    
    if rescued > 0 then
        spr(20,88*8,58*8,1,1,end_flip1,false)
    end
    if rescued > 1 then
        spr(20,87*8,58*8,1,1,end_flip2,false)
    end
    if rescued > 2 then
        spr(20,86*8,58*8,1,1,end_flip3,false)
    end
    if rescued > 3 then
        spr(20,84*8,58*8,1,1,end_flip4,false)
    end
    if rescued > 4 then
        spr(20,83*8,57*8,1,1,end_flip5,false)
    end
    if rescued > 5 then
        spr(20,82*8,57*8,1,1,end_flip6,false)
    end
    if rescued > 6 then
        spr(20,88*8,55*8,1,1,end_flip7,false)
    end
    if rescued > 7 then
        spr(20,87*8,55*8,1,1,end_flip8,false)
    end
    if rescued > 8 then
        spr(20,86*8,55*8,1,1,end_flip9,false)
    end
    if rescued > 9 then
        spr(20,85*8,52*8,1,1,end_flip10,false)
    end
    if rescued > 10 then
        spr(20,84*8,52*8,1,1,end_flip11,false)
    end
    if rescued > 11 then
        spr(20,83*8,52*8,1,1,end_flip12,false)
    end
end

function the_end()
    if game_end_t > 440 then
        print("the end",52,45,14)
        print("the end",53,44,13)
        print("the end",52,44,7)
    end
end

--torches and fire

function make_torch()
 --this function only at init
    local t = {}
    t.tile_x=27
    t.tile_y=22
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=24
    t.h=24
    t.held=false
    t.lit=false
    add(torch,t)

    local t = {}
    t.tile_x=101
    t.tile_y=44
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=24
    t.h=24
    t.held=false
    t.lit=false
    add(torch,t)

end

function make_fire()
    local f = {}
    f.on_fire=false
    f.t=0
    add(fire,f)

    local f = {}
    f.on_fire=false
    f.t=0
    add(fire,f)

end

function make_wood()
    local w = {}
    w.tile_x=36
    w.tile_y=22
    w.x=w.tile_x*8
    w.y=w.tile_y*8
    w.w=8
    w.h=72
    add(wood,w)

    local w = {}
    w.tile_x=89
    w.tile_y=19
    w.x=w.tile_x*8
    w.y=w.tile_y*8
    w.w=8
    w.h=72
    add(wood,w)
end

function draw_torch(a)

    local var
    if t%20 > 10 then
        var = false
    else
        var = true
    end
    
    spr(34,a.x+8,a.y+8)
    if torch[room.torch].lit == true then
        spr(32,a.x+8,a.y+1,1,1,var,false)
    end
end

function fire_torch()

    if collide(player, torch[room.torch]) then
        if torch[room.torch].held == false then
            bubble = true
        end
        if btnp(actc) then
            torch[room.torch].held=true
        end
    end

    if torch[room.torch].held == true then
        if player.flipx == false then
            torch[room.torch].x=player.x-13
        else torch[room.torch].x=player.x-3
        end
        torch[room.torch].y=player.y-7
    end

    if collide(lamp[room.lamp], torch[room.torch]) then
        torch[room.torch].lit=true
    end

    if collide(wood[room.wood], torch[room.torch]) and torch[room.torch].lit == true then
        torch[room.torch].held=false
        torch[room.torch].lit=false
        torch[room.torch].x=0
        torch[room.torch].y=0
        fire[room.fire].on_fire=true
    end
end

function room_fire()

    local var = false
    if fire[room.fire].t%20 > 10 then
        var = true
    else var = false
    end

    if fire[1].on_fire == true then

        fire[1].t += 1

        if fire[1].t < 90 then
            sfx(1)
        end

        if fire[1].t > 10 then
            spr(32,37*8,28*8,1,1,var,false)
        end

        if fire[1].t > 15 then
            spr(32,39*8,27*8,1,1,var,false)
        end

        if fire[1].t > 25 then
            spr(32,38*8,25*8,1,1,var,false)
        end

        if fire[1].t > 35 then
            spr(32,37*8,24*8,1,1,var,false)
        end

        if fire[1].t > 50 then
            spr(32,39*8,23*8,1,1,var,false)
        end

        if fire[1].t == 90 then
            fire[1].on_fire = false
            mset(37,22,62)
            mset(38,22,62)
            mset(39,22,62)
            for i=36,41 do
            mset(i,23,62) end
            for i=34,41 do
            mset(i,24,62) end
            for i=35,40 do
            mset(i,25,62) end
            for i=36,40 do
            mset(i,26,62) end
            for i=36,40 do
            mset(i,27,62) end
            mset(35,28,62)
            mset(36,28,62)
            mset(40,28,62)
            mset(34,29,62)
            mset(35,29,62)
            mset(36,29,62)
            mset(36,30,62)
        end
    end

    if fire[2].on_fire == true then

        fire[2].t += 1

        if fire[2].t < 90 then
            sfx(1)
        end

        if fire[2].t > 10 then
            spr(32,37*8,28*8,1,1,var,false)
        end

        if fire[2].t > 15 then
            spr(32,87*8,21*8,1,1,var,false)
        end

        if fire[2].t > 25 then
            spr(32,84*8,23*8,1,1,var,false)
        end

        if fire[2].t > 35 then
            spr(32,87*8,24*8,1,1,var,false)
        end

        if fire[2].t > 50 then
            spr(32,83*8,25*8,1,1,var,false)
        end

        if fire[2].t == 90 then
            fire[2].on_fire = false
            mset(88,18,59)
            mset(89,18,59)
            mset(87,19,59)
            mset(88,19,59)            
            for i=86,88 do
            mset(i,20,62) end
            for i=84,88 do
            mset(i,21,62) end
            for i=84,90 do
            mset(i,22,62) end
            for i=84,90 do
            mset(i,23,62) end
            for i=83,92 do
            mset(i,24,62) end
            for i=82,91 do
            mset(i,25,62) end
            for i=82,92 do
            mset(i,26,62) end
            for i=83,92 do
            mset(i,27,62) end
            for i=83,90 do
            mset(i,28,62) end
        end
    end
end


--ice blocks

function make_ice_blocks()
 --this function only at init
 --ice block 1
    local i = {}
    i.tile_x=50
    i.tile_y=26
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)
 --ice block 2
    local i = {}
    i.tile_x=38
    i.tile_y=16
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)
 --ice block 3
    local i = {}
    i.tile_x=21
    i.tile_y=24
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)

 --ice block 4
    local i = {}
    i.tile_x=65
    i.tile_y=18
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)

 --ice block 5
    local i = {}
    i.tile_x=99
    i.tile_y=42
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)

 --ice block 6
    local i = {}
    i.tile_x=54
    i.tile_y=39
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)
 --ice block 6
    local i = {}
    i.tile_x=46
    i.tile_y=56
    i.x=i.tile_x*8
    i.y=i.tile_y*8
    i.w=28
    i.h=28
    i.t=0
    i.x1=mget(i.tile_x+1,i.tile_y+1)
    i.x2=mget(i.tile_x+1,i.tile_y+2)
    i.x3=mget(i.tile_x+2,i.tile_y+1)
    i.x4=mget(i.tile_x+2,i.tile_y+2)
    mset(i.tile_x+1,i.tile_y+1,63)
    mset(i.tile_x+1,i.tile_y+2,63)
    mset(i.tile_x+2,i.tile_y+1,63)
    mset(i.tile_x+2,i.tile_y+2,63)
    add(ice_blocks,i)

end

function draw_ice_blocks(i)

    if i.t < 3 then
        spr(68, (i.tile_x+1)*8, (i.tile_y+1)*8, 2, 2, false, false)
    end

    if i.t == 1 or i.t == 2 then
        spr(99, (i.tile_x+1)*8, (i.tile_y+2)*8, 1, 1, false, false)
    end

    if i.t == 2 then
        spr(99, (i.tile_x+1)*8, (i.tile_y+2)*8, 1, 1, false, false)
        spr(99, (i.tile_x+2)*8, (i.tile_y+1)*8, 1, 1, false, false)
    end
end


function break_ice_block()

    if collide(player, ice_blocks[room.ice_block]) then
        bubble = true
        if btnp(actc) then
            ice_blocks[room.ice_block].t += 1
            make_ice_dust(ice_blocks[room.ice_block].x+6,ice_blocks[room.ice_block].y+14)
            make_ice_dust(ice_blocks[room.ice_block].x+18,ice_blocks[room.ice_block].y+8)
            sfx(1)
        end
    end

    if ice_blocks[room.ice_block].t == 3 then
        mset(ice_blocks[room.ice_block].tile_x+1,ice_blocks[room.ice_block].tile_y+1,ice_blocks[room.ice_block].x1)
        mset(ice_blocks[room.ice_block].tile_x+1,ice_blocks[room.ice_block].tile_y+2,ice_blocks[room.ice_block].x2)
        mset(ice_blocks[room.ice_block].tile_x+2,ice_blocks[room.ice_block].tile_y+1,ice_blocks[room.ice_block].x3)
        mset(ice_blocks[room.ice_block].tile_x+2,ice_blocks[room.ice_block].tile_y+2,ice_blocks[room.ice_block].x4)
        ice_blocks[room.ice_block].x=0
        ice_blocks[room.ice_block].y=0
    end
end


function make_ice_dust(x,y)

    local i = {}
    i.x=x
    i.y=y
    i.dy = rnd(1)
    i.t = 0
    add(ice_dust,i)

end

function move_ice_dust(i)

    i.y = i.y + i.dy
    i.t = i.t + 1

    if (i.t > 10) then
        del(ice_dust,i)
    end
end



--journal--

function draw_message()

--journal #1--
    
    if collide(player, start_block) then
        message.text = "sydney knew the clouds#were too dark, she#knew she shouldn't#have led those men#up the mountain..."
        write_text()
        
    elseif collide(player, journal[1]) then
        if journal[1].read == false then
            journal[1].read = true
            read += 1
        end
        message.text = "what happened?#a storm?#is anyone else#out there?"
        write_text()

--journal #2--    
    elseif collide(player, journal[2]) then
        if journal[2].read == false then
            journal[2].read = true
            read += 1
        end
        message.text = "okay, sydney. you can#do this! you've been#a sherpa for, like,#seven years!"
        write_text()

--journal #3--    
    elseif collide(player, journal[3]) then
        if journal[3].read == false then
            journal[3].read = true
            read += 1
        end
        message.text = "oh, my. i've never#been here before.#it's beautiful."
        write_text()

--journal #4--    
    elseif collide(player, journal[4]) then
        if journal[4].read == false then
            journal[4].read = true
            read += 1
        end
        message.text = "...i hope my#husband isn't hurt..."
        write_text()

--journal #5--    
    elseif collide(player, journal[5]) then
        if journal[5].read == false then
            journal[5].read = true
            read += 1
        end
        message.text = "the stars are so#clear tonight.#such a difference#from yesterday."
        write_text()

--journal #6--    
    elseif collide(player, journal[6]) then
        if journal[6].read == false then
            journal[6].read = true
            read += 1
        end
        message.text = "i guess those repairs#at our summit station#will have to wait."
        write_text()

--journal #7--    
    elseif collide(player, journal[7]) then
        if journal[7].read == false then
            journal[7].read = true
            read += 1
        end
        message.text = "huh. i think my#husband proposed#to me around here."
        write_text()

--journal #8--    
    elseif collide(player, journal[8]) then
        if journal[8].read == false then
            journal[8].read = true
            read += 1
        end
        message.text = "god, if i make it,#i swear i'll#memorize ten books#on field medicine."
        write_text()
--journal #9--    
    elseif collide(player, journal[9]) then
        if journal[9].read == false then
            journal[9].read = true
            read += 1
        end
        message.text = "keep going, sydney.#you swore no hiker#would die on your#watch."
        write_text()

--journal #10--    
    elseif collide(player, journal[10]) then
        if journal[10].read == false then
            journal[10].read = true
            read += 1
        end
        message.text = "this tunnel is so cold.#what i wouldn't#give for some hot#barley tea."
        write_text()

--journal #11--    
    elseif collide(player, journal[11]) then
        if journal[11].read == false then
            journal[11].read = true
            read += 1
        end
        message.text = "the storm destroyed#the path back to#the summit. i hope#i found everyone..."
        write_text()
--journal #12--    
    elseif collide(player, journal[12]) then
        if journal[12].read == false then
            journal[12].read = true
            read += 1
        end
        message.text = "this is it, i've#almost made it!#don't cry yet, sydney."
        write_text()
    elseif end_text then
        write_text()
--reset journal        
    else
        message.index=0
        message.last=0
    end  
end

function write_text()

    if message.index<#message.text then
        message.index+=0.5
        if message.index>=message.last+1 then
            message.last+=1
            sfx(0)
        end
    end
    message.off = {x=8,y=90}
    for i=1,message.index do
        if sub(message.text,i,i)~="#" then
            rectfill(message.off.x-2,message.off.y-2,message.off.x+7,message.off.y+6 ,7)
            print(sub(message.text,i,i),message.off.x,message.off.y,0)
            message.off.x+=5
        else
            message.off.x=8
            message.off.y+=7
        end
    end
end


function make_journal()

    local j = {}
    j.tile_x=10
    j.tile_y=9
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=46
    j.tile_y=6
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=12
    j.tile_y=36
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=61
    j.tile_y=29
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=89
    j.tile_y=8
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=68
    j.tile_y=20
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=116
    j.tile_y=21
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=44
    j.tile_y=28
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=72
    j.tile_y=42
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=45
    j.tile_y=39
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=38
    j.tile_y=54
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

    local j = {}
    j.tile_x=67
    j.tile_y=52
    j.x=j.tile_x*8
    j.y=j.tile_y*8
    j.w=8
    j.h=8
    j.read = false
    add(journal,j)

end

function draw_journal(j)
    spr(23,j.x,j.y)
end


--lamp--

function draw_lamp(l)
    if t%20 > 10 then
        l.flipx = true
    else
        l.flipx = false
    end

    spr(32, l.tile_x*8, l.tile_y*8, 1, 1, l.flipx, false)
end

function make_lamp()
 --this function only at init
    local t = {}
    t.tile_x=1
    t.tile_y=3
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)
    
    local t = {}
    t.tile_x=28
    t.tile_y=2
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=25
    t.tile_y=26
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=108
    t.tile_y=3
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=109
    t.tile_y=11
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=108
    t.tile_y=42
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=93
    t.tile_y=21
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=9
    t.tile_y=22
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=83
    t.tile_y=42
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=86
    t.tile_y=41
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=53
    t.tile_y=43
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=33
    t.tile_y=57
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=62
    t.tile_y=59
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)

    local t = {}
    t.tile_x=53
    t.tile_y=51
    t.x=t.tile_x*8
    t.y=t.tile_y*8
    t.w=8
    t.h=8
    t.flipx=false
    add(lamp,t)
end

--flags--

function draw_flag(f)
    if t%20 > 10 then
        f.flip1y = true
    else
        f.flip1y = false
    end

    if t%30 > 10 then
        f.flip2y = true
    else
        f.flip2y = false
    end

    spr(49, f.tile_x*8, f.tile_y*8, 1, 1, false, f.flip1y)
    spr(50, (f.tile_x+1)*8, f.tile_y*8, 1, 1, false, f.flip2y)
end

function make_flag()
 --this function only at init

    local f = {}
    f.tile_x=82
    f.tile_y=4
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=83
    f.tile_y=5
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=89
    f.tile_y=6
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=92
    f.tile_y=5
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=102
    f.tile_y=18
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=112
    f.tile_y=20
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=38
    f.tile_y=38
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=42
    f.tile_y=38
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=73
    f.tile_y=51
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

    local f = {}
    f.tile_x=78
    f.tile_y=52
    f.flip1y=false
    f.flip2y=false
    add(flag,f)

end

function draw_jem(j)
    if t%60 < 20 then
        spr(24, j.tile_x*8, j.tile_y*8)
    elseif t%60 < 40 then
        spr(25, j.tile_x*8, j.tile_y*8)
    else
        spr(26, j.tile_x*8, j.tile_y*8)
    end
end

function make_jem()
 --this function only at init

    local j = {}
    j.tile_x=6
    j.tile_y=34
    add(jem,j)

    local j = {}
    j.tile_x=10
    j.tile_y=33
    add(jem,j)

    local j = {}
    j.tile_x=2
    j.tile_y=41
    add(jem,j)

    local j = {}
    j.tile_x=4
    j.tile_y=39
    add(jem,j)
end


--hiker--

function make_hikers()
 --this function only at init
 --hiker 1
    local h = {}
    h.tile_x=25
    h.tile_y=2
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
 --hiker 2   
    local h = {}
    h.tile_x=58
    h.tile_y=5
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 3   
    local h = {}
    h.tile_x=48
    h.tile_y=27
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 4
    local h = {}
    h.tile_x=41
    h.tile_y=28
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 5
    local h = {}
    h.tile_x=10
    h.tile_y=22
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 6
    local h = {}
    h.tile_x=85
    h.tile_y=28
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 7
    local h = {}
    h.tile_x=102
    h.tile_y=45
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 8
    local h = {}
    h.tile_x=69
    h.tile_y=41
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 9
    local h = {}
    h.tile_x=59
    h.tile_y=33
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 10
    local h = {}
    h.tile_x=91
    h.tile_y=38
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 11
    local h = {}
    h.tile_x=40
    h.tile_y=56
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
--hiker 12
    local h = {}
    h.tile_x=59
    h.tile_y=59
    h.x=h.tile_x*8
    h.y=h.tile_y*8
    h.w=24
    h.h=24
    h.t=0
    h.move=false
    add(hikers,h)
end

function draw_hiker(h)
    if h.t<10 then
        spr(16, (h.tile_x+1)*8, (h.tile_y+1)*8, 1, 1, false, false)
    elseif h.t<20 then
        spr(17, (h.tile_x+1)*8, (h.tile_y+1)*8, 1, 1, false, false)
    elseif h.t<30 then
        spr(18, (h.tile_x+1)*8, (h.tile_y+1)*8, 1, 1, false, false)
    elseif h.t<40 then
        spr(19, (h.tile_x+1)*8, (h.tile_y+1)*8, 1, 1, false, false)
    else
        spr(20, (h.tile_x+1)*8, (h.tile_y+1)*8, 1, 1, false, false)
        spr(21, (h.tile_x+1.5)*8+4, (h.tile_y+.5)*8, 1, 1, false, false)
    end
end


function save_hikers()

    if collide(player, hikers[room.hiker]) and hikers[room.hiker].t == 0 then
        bubble = true
        if btnp(actc) then
            hikers[room.hiker].move = true
            rescued += 1
            col=10
            sfx(2)
        end
    end

    if hikers[room.hiker].move == true then
        hikers[room.hiker].t += 1
    end
    if hikers[room.hiker].t > 50 then
        hikers[room.hiker].move = false
    end
end


--dust while jumping--

function make_dust(x,y)

    local s = {}
    s.x=x
    s.y=y
    s.t=0
    s.max_t = 10+rnd(10)
    s.dx = -.5-rnd(.5)
    s.dy = -rnd(.05)
    add(dust,s)
    return s

end

function move_dust(s)

    s.x = s.x + s.dx
    s.y = s.y + s.dy
    s.t = s.t + 1

    if (s.t > s.max_t) then
        del(dust,s)
    end
end

function draw_dust(s)

    if s.t < 5 then
        spr(8,s.x,s.y)
    elseif s.t < 10 then
        spr(9,s.x,s.y)
    else
        spr(10,s.x,s.y)
    end

end


--background snow--

function make_snow()

    local var = rnd(30)

    if var > 26 then
        local s = {}
        s.x=rnd(256)
        s.y=0
        s.dx = -3+rnd(.5)
        s.dy = -s.dx
        add(snow,s)
        return s
    end
end

function move_snow(s)

    s.x = s.x + s.dx
    s.y = s.y + s.dy

    if (s.y > 128) then
        del(snow,s)
    end
end

function draw_snow(s)
    line(s.x,s.y,s.x+5,s.y-5,7)
end




--map collision checks--


function grounded()
    local v1 = mget(flr(player.x)/8, flr(player.y/8)+1)
    local v2 = mget(flr(player.x+7)/8, flr(player.y/8)+1)
    if (fget(v1, 0) or fget(v2,0)) then return true end
end

function right_collide()
    local x1 = player.x + min(player.dx, sgn(player.dx))
    local v1 = mget((x1+7)/8, player.y/8)
    local v2 = mget((x1+7)/8, (player.y+7)/8)
    if (fget(v1, 0) or fget(v2,0)) then return true end
end

function left_collide()
    local x1 = player.x + min(player.dx, sgn(player.dx))
    local v1 = mget((x1)/8, player.y/8)
    local v2 = mget((x1)/8, (player.y+7)/8)
    if (fget(v1, 0) or fget(v2,0)) then return true end
end

function top_collide()
    local y1 = player.y + min(player.dy, sgn(player.dy)*.1)
    local v1 = mget((player.x)/8, y1/8)
    local v2 = mget((player.x+7)/8, y1/8)
    if (fget(v1, 0) or fget(v2,0)) then return true end
end

function bottom_ladder()
    local v1 = mget(flr(player.x)/8, flr(player.y+7)/8)
    local v2 = mget(flr(player.x+7)/8, flr(player.y+7)/8)
    if (fget(v1, 1) or fget(v2,1)) then return true end
end

function top_ladder()
    local v1 = mget(flr(player.x)/8, flr(player.y/8)+1)
    local v2 = mget(flr(player.x+7)/8, flr(player.y/8)+1)
    if (fget(v1, 1) or fget(v2,1)) then return true end
end


--doing collisions--


function do_obj_collisions()

    function collide(obj, other)
        if
            other.x+other.w > obj.x and 
            other.y+other.h > obj.y and
            other.x < obj.x+obj.w and
            other.y < obj.y+obj.h 
        then
            return true
        end
    end

    if collide(player,right_bound) then
        player.x += 4
        room.x += 1
        cam.x += 128
        right_bound.x += 128
        left_bound.x += 128
        top_bound.x += 128
        bottom_bound.x += 128
    end

    if collide(player,left_bound) then
        player.x -= 4
        room.x -= 1
        cam.x -= 128
        right_bound.x -= 128
        left_bound.x -= 128
        top_bound.x -= 128
        bottom_bound.x -= 128
    end

    if collide(player,top_bound) then
        player.y -= 4
        room.y -= 1
        cam.y -= 128
        right_bound.y -= 128
        left_bound.y -= 128
        top_bound.y -= 128
        bottom_bound.y -= 128
    end

    if collide(player,bottom_bound) then
        player.y += 4
        room.y += 1
        cam.y += 128
        right_bound.y += 128
        left_bound.y += 128
        top_bound.y += 128
        bottom_bound.y += 128
    end
end



function do_map_collisions()

    if grounded() and not bottom_ladder() then
        player.dy = 0
        player.y = flr(flr(player.y/8)*8)
        if not pause_controls and (btnp(actx)) then
           player.dy = -4.5
           make_dust(player.x,player.y)
           sfx(4)
        end
    elseif bottom_ladder() then
        player.dy = 0
        player.moving = true
        if btn(up) then
            if not top_collide() then player.y -= 1.5 end
            climbanim()
        end
        if btn(down) then
            if not grounded() then player.y += 1.5 end
            climbanim()
        end
    else player.dy += 0.7
    end

    if top_ladder() and not bottom_ladder() then
        player.dy = 0
        player.y = flr(flr(player.y/8)*8)
        if not pause_controls and (btnp(actx)) then
           player.dy = -4.5
           make_dust(player.x,player.y)
           sfx(4)
        end
        if btn(down) then
            if not grounded() then player.y += 1.5 end
            climbanim()
        end
    end

    if right_collide() then
        player.dx = 0
        player.x = flr(flr(player.x)/8)*8
    end

    if left_collide() then
        player.dx = 0
        player.x = flr(flr(player.x)/8)*8
    end

    if top_collide() then
        player.dy = 0
    end
    
    if top_collide() and right_collide() and left_collide() then
        player.y += 1
    end
end


--moving--

function moveanim()

    player.moving = true
    player.sprite += 0.4
    if player.sprite > 4 then 
        player.sprite = 0
    end
end

function climbanim()

    player.moving = true
    player.sprite = 36
    
end

function buttons()

    if (btn(left)) then
        if left_collide() then
        else
            player.ddx = -.2
            if(player.dx>0) then player.dx -= .5
            end
        end
        if grounded() or top_ladder() then
            moveanim()
        end
        player.flipx = true
    end

    if (btn(right)) then
        if right_collide() then
        else
            player.ddx = .2
          	 if(player.dx<0) then player.dx += .5
            end
        end
        if grounded() or top_ladder() then
            moveanim()
        end
        player.flipx = false
    end

    if (btn(down)) then
        player.moving = true
        player.sprite = 4
    end

    if (btn(up)) then
        player.moving = true
        player.sprite = 5
    end
end

--speed checks--

function update_speed()

    player.x += player.dx
    player.y += player.dy
    player.dx += player.ddx
 
    if player.dx > 1.5 then
        player.dx = 1.5
    elseif player.dx < -1.5 then
        player.dx = -1.5
    end

    if player.dy > 4 then
        player.dy = 4
    end

    if player.ddx == 0 then
        player.dx *= 0.1
    end

    if not player.moving and game_start then
        player.sprite = 0
    end

end

--the end! thanks for playing!
__gfx__
007755000077550000775500007755000000000000775500ffffffffffffffff0000070000000070000000707c77c6c722222222777777777776777777766777
055555500555555005555550055555500077550005555550244224420440044007700000007000070070000006c7076022222220c77c77c777c6666c76cc67c7
0ddffddd0ddffddd0ddffddd0ddffddd055555500ddf1f1d244224420440044007007700070007000700000007770070222222001111c7cc766ccc66cc1c6677
0ddf1f1d0ddf1f1d0ddf1f1d0ddf1f1d0dddddd00ddf1f1dffffffffffffffff00007700000007000000700000770000222220001171111176c11ccc111cc666
edff1f1dedff1f1dedff1f1dedff1f1d0ddfffddeddffffd244224420440044000000000000000000000000000700000222200001111111176c111111111ccc6
44dffff044dffff044dffff044dffff0edff1f1d44ddfff0244224420440044077700700077007000070070000000000222000001111111166c11c11111111c7
54feee0004feee7004f7ee0004f7ee0044df1f1004feee00ffffffffffffffff77700770077007000000000000000000220000001111cc1177c111111c1111c7
0007070000070000000000700000070004feee000007070024422442044004407770000000000000000000000000000020000000111111117c6c1111111111c6
000000000000000000077000007700000077000000000000066666600000000000000a0000000000000000007c77c6c700000002111117c776c1111111111c77
00000000000000770cc77c000c77cc000c77cc000000000061111116000004400e00a9a000000a000000000026c7276200000022111111c776c111c111111c67
0000000000ccccc7ccccccc0ccccccc0ccccccc0777070706171171600044220e8e00a000e00000000000000277722720000022211711c7776cc11111c11c777
00000c000ccffcc0c1f1ffc0cff1f1c0cff1f1c07070770061177116044277220e000000000070000000000022772222000022221771c7777c6c1c111111cc66
000ffcc000ffffc001f1ff000ff1f1000ff1f100707070706171171642727272000000000001310000007000227222220002222211111c77776111c11cc111c6
070ffcc7008fff000ffff44044ffff0044ffff0f7770707061111116622772260000c0000073c3700007c70022222222002222221c1111c777c11c6cc77ccc67
088ffcc7078880000088844044888000448888f00000000006611660062226600000000000013100000070002222222202222222111111c7667cc66666777777
78888cc000070000007070000070700000707000000000000006600000660000000000000000700000000000222222222222222211111c777776777777767766
000000002224422200444400222222220055750000000000000000000002277000000000000000000000000000000000200000007c1111117111111111111111
00aa000022444422004444002222222205577550000000000000000000222222000000000000000000000000000000002200000077c111111c11111111111111
000aa0002244442200044000222222220d5555d00000dd0000077700099999220000000000000000000000000000000022200000777111111111771111111111
00aaaa002224422200044000222222220ddeeed0000ffd5000057500091f1f22000000000000000000000000000000002222000077c1111111117c7111111111
0aa9aaa02224422200000000666226660dd444d07eefff5700077700001f1ff0000000000000000000000000000000002222200077c111111111171111111111
00a99a0022444422000000005446644500d444f00eefff570000000000ffff44000000000000000000000000000000002222220077c1c1111c71111111111111
0049940022444422000000002511115200fee7007eddfd550000000000dddd4400000000000000000000000000000000222222207c1111111711111111111111
0004400022244222000000002544445200070000044edd550000000000070700000000000000000000000000000000002222222277c111111111111111111111
00044000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000022222222111111112222222211111111
0044440000000000ccccc70000000000000000000000000000000000000000000000000000000000000000000000000002222222111111112222222211111111
0044440000000cccccccc70000000000000000000000000000000000000000000000000000000000000000000000000000222222117111112222222211111111
00044000000cc777ccccc70000000000000000000000000000000000000000000000000000000000000000000000000000022222111117112222222211111111
000440000c77cccc7777c70000000000000000000000000000000000000000000000000000000000000000000000000000002222111117712222222211111111
0044440000ccc000ccccc70000000000000000000000000000000000000000000000000000000000000000000000000000000222111cc1112222222211111111
004444000000000000ccc700000000000000000000000000000000000000000000000000000000000000000000000000000000227cc77cc72222222211111111
00044000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000002777777772222222211111111
03000000030000000000000000000000777677777777677765000000000000000000000000000000000000000000000000000000000000000000000000000000
3330000033300000300000000000700077cc66cc7667676756500000000000000000000000000000000000000000000000000000000000000000000000000000
331003003113000333003000000000007cc777c666c66c7705650000000000000000000000000000000000000000000000000000000000000000000000000000
111033011011001113033300000000007677c666ccc777c600565000000000000000000000000000000000000000000000000000000000000000000000000000
11033330030111101101330007000000c77ccccccccc677700056500000000000000000000000000000000000000000000000000000000000000000000000000
10003110333011030101131000000000c77cc6cccccccc6700005650000000000000000000000000000000000000000000000000000000000000000000000000
003011003311003300111111000000707c6cccccc6cccc6700000565000000000000000000000000000000000000000000000000000000000000000000000000
033000301110103330010031000000007c76cccccccccc6600000056000000000000000000000000000000000000000000000000000000000000000000000000
33550333110301115500033000000000c66cccccccccc67700044000000000000000000000000000000000000000000000000000000000000000000000000000
15110331003330011110333300000000766ccc6cccccc67700054000000000000000000000000000000000000000000000000000000000000000000000000000
111101110155110111003311070000007c76ccccc6cc677700044000000000000000000000000000000000000000000000000000000000000000000000000000
011100110111100010011110000000007c77c6cccccccc7700054000000000000000000000000000000000000000000000000000000000000000000000000000
0000110000000011000000010000000077777c6cc6ccc77600044000000000000000000000000000000000000000000000000000000000000000000000000000
001111110001111111001111000070007767777667ccc66700054000000000000000000000000000000000000000000000000000000000000000000000000000
11155511111115555111115500077700777666676676677700044000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555500007000777677777776777700054000000000000000000000000000000000000000000000000000000000000000000000000000
555111555111555555511555000010002ff1fff2f11ff1ff02ffffff266666660000000000000000000000000000000000000000000000000000000000000000
55555550551115555555555500011001f41f44412f1411440f444444544444440000000000000000000000000000000000000000000000000000000000000000
55055503055555555550555500110010f141f44122f144110f449544545f445f0000000000000000000000000000000000000000000000000000000000000000
50300503300505505503055500100000ff41f4f12222f1440f49995454ff44ff0000000000000000000000000000000000000000000000000000000000000000
03331033330030030033305100011100f444441122222f440f499954544444440000000000000000000000000000000000000000000000000000000000000000
03111011310333033133300111010111f4411f41222222f10f499954545f445f0000000000000000000000000000000000000000000000000000000000000000
00011131100155013115551110010001f41ff441222222220f44444454ff44ff0000000000000000000000000000000000000000000000000000000000000000
030003330011111011111101001000002111111f222222220f499954255555550000000000000000000000000000000000000000000000000000000000000000
3300133100030000300000000000000044144144222442220f499954ffffffff0000000000000000000000000000000000000000000000000000000000000000
331011110033310333000300000000004f4444f422f11f220f4444440f5555550000000000000000000000000000000000000000000000000000000000000000
11103001030111033310033000000000411421f22f1441f20f49995400f444440000000000000000000000000000000000000000000000000000000000000000
111333003330005551103331000000004f422112225995220f499954000ff4440000000000000000000000000000000000000000000000000000000000000000
000331001155001111005511000000002f122412225995220f44444400000f440000000000000000000000000000000000000000000000000000000000000000
30011110111113110001111100000000214224f2224554220f444444000000f40000000000000000000000000000000000000000000000000000000000000000
330000030000033000300001000000002f4224f2211111120f444444000000000000000000000000000000000000000000000000000000000000000000000000
33100033310013300333110000000000141221412222222202111111000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000c3e3e3e3e3f3f3f3f1b1e3e3e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d3d3d3d3d3d3d3d3d3d3d3d3d3f3f3f3e2f3f3d3d3d3d3d34756
f3f3f3f3f3f3d1e3d2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f147464646e346e346f3f3f3f3f3d1e3e3e360e3e3d2f3e2f300000000000000000000000000000000
000000910000000000350000c3e3e3e3f3d3f1b1e3e3e3d0f3f3f3f3e2f3f3f3f3f3f3e2f3d1b0c3b1e360606060606060e3e3e1d3d3f3f3f1b1b1e3e3e3e346
f3f3e2f3f3f3d1e3d2f3f3e2f3f3e2f3f3f3f3f3f3f3f1b146b3c35646b35646f3f3d3d3d3d3f0e3e360e3e3e1d3f3f300000000000000000000000000000000
00000000000000000000b20000e3e3e3f1b1b1e3e3e0d0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1b3b3b3c3e3e3e36060606060e3e3c0b0e1f1b1e3e3e3e3e34646
f3f3f3f3f3f3d1c3d2f3f3f3f3f3f3f3f3f3f3d3d3f1c0b34647464647b3c346f3f1b1e3e3e3d2d0f060e3e3b1e3e1f300000000000000000000000000000000
000000800000a1000000b20000e3e3e3b1e3e3e3e0f3f3f3f3f3f3e2f3f3e2f3f3d3f3f3d1b1c2b3b3b3b3c3e3e3e360606070b3b3b3b0c1e3e360e0d0d0d0f3
f3e2f3f3f3f3d1b346f3f3f3f3e2f3f3f3f3f1e3b146b346b35646b3474647e3d1b1c0b3c3e3d2f3f3f0e3e3e3e3b1d200000000000000000000000000000000
00a10000003500000000b2b3b3c3e3e3e3e3d0d0f3f3f3f3f3f3f3f3f3f3f3f3d1b1e1f3f1e3e3e3c2b3b3b3b3c3e3e3c070707070c1e3e3e3e360b1e1d3f3f3
f3f3e2f3f3f346b3b0d2f3f3f3f3f3f3f3f1b1e346564647e3e357e347564746d1e3b3b3e0d0d3d3d3d3f0e3e3e3e3d200000000000000000000000000000000
0000a0000000000000b3b3d0d0d0d0d0d0d0f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1e3b1d1b1e3e3e3e3e3c2b3b3b3b3e0f0b370707060e3e3e3e3e3e3e3b1e1f3
f3f3f3f3f3d346c2b3d2f346f3f3f3f3f1b14646e3e357e3e3e3e3e3e3e34646d1e3e0d0f1b0c3b1e360b1d0e3e3e0f300000000000000000000000000000000
00a1000000000000a000b3b0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1e3d0f1e3e3e3e3e3e3e3c2b3b3d0f3d1b3b3c16060606060e3e3e3e3e3e3d2
f3f3f3f3f34646e346e146f3f3f3f3f34746e357e3e3e3e3e3e3e3e3e3e3e3d2f3d0f3f1b0b3b3e3e360e3b1e3e0d3f300000000000000000000000000000000
000000008100008100900000b3b0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d0b1e3e3e3e312e3e3e312e3e3e3d2d1e3e3e3e3606060e0d0d0f0e3e3e3d2
f3f3f3f3d346e3e357b15646f3f3f3f347e3e3e3e3e3e3e3e3e3e3e3e3e3e3d2f3f3f1e3c2b3c1e3e360e0d0d0f1b1d200000000000000000000000000000000
0000000000000000000000810000b3b0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1b1d0e3e3e3d0d0e3e3e3d0d0d0d0f3f3f0e3e3e3b1606060e1f160e3e3e3e1
d3f3f3f1e3b1e3e3e3e3e3e3e1f3f3f3d1e3e3e3e3e3e3e3e3e3e0d0d0d0d0f3f3f1b1e3e3e3e0d0d0d0f1b1b1e3e3d200000000000000000000000000000000
000091000000008000a1000000000000f3f3e2f3f3f3f3f3f3f3f3f3f3f3f3f3d1e3f3f0e3e3e3b1e3e3e3b1f3f3f3f3f3f3f0e3e3e3b160606060e3e3e3e3e3
b1e3e3b1e3e3e3e3e3e3e3e3b1f3f3d3f1e3e3e3e3e3e3e3e3e0f3f3f3f3f3f3d1b1e3e3d0d0d3d1e360e3e3e3e3e3d200000000000000000000000000000000
000081359100000000a0000000910000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1e3d2f3d0f0e3e3e3e3e3e3d2f3f3f3f3f3f3f0e3e3e3e360606060e3e3e0d0
d0f3f3d0d046e3e3e346f0e3e3e3e3b1e3e3e3e3e3e312e3e0f3f3f3e2f3f3e2d1e3e3e3b1d3b1e1f060e3e3e3e3e3d200000000000000000000000000000000
b3b3b391b300009100000000a1000000f3e2f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1e3e1f3f1b1e3e3e3e3e3e3e1f3f3f3f3f3f3d1e3e3e3e3e360606060e3d2f3
f3f3f3f3f346464646f3f3d0d0f3f3d0d0f0e312e3e3e0d0f3f3f3f3f3f3f3f3f3d0f0e3e3e3e3b1e1d0f0e312e3e3d2000000000000000000000000000000b3
b381b3b3b3b381b30000b30000008000f3f3f3f3e2f3f3f3f3f3f3f3f3f3f3f3f3f0b1d1b1e3e3e3e3e3e3e3b1d2f3f3f3f3f3d1e312e3e3e3b1606060474646
f3f3f3f346d0d0e24746f3f3f3f3f3f3f3f3d0d0d0d0f3f3f3f3f3f3f3f3f3f3f3f3f3f0e3e3e3e3b1e1d3d0d0f0e3d2000000000000000000000000000000b3
90b3b3b30000b300b3b3b3b3b3b3b3b3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d3f0b1d0e3e3e3e3e3e3e3e3d2f3f3f3f3f34647f0e3e3e3e3e360604746f3
f3f3f3f3f3f3f346474646f3e2f3f3f3f3e2f3f3f3f3f3f3e2f3f3f3f3f3f3e2f3f3f3f3f0e332e3e360e3b1e1f3d0f300000000000000000000000000000000
b3b3b3b3009000b3b381b3b3b3b3b3b3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1e3d2d0e3e3e3e3e3e3e3e3e3d2f3f3f3f3f3f046f3d0f0e3e36060e0d046d2
f3f3e2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e2f3f3f3f3f3f3f3f3d0f0e3e360e3e3e3d2f3f300000000000000000000000000000000
b3b3b3b381000000b3b3b3b3b3b3b3b3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d0d1e3e3e3e3e3e3e3e3e3e0f3f3f3f3f346f3f3f3f3f346d0464646f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d0d0d0d0d0d0f3f3f300000000000000000000000000000000
34b3b300b3b3b30000b3b3b337b3b3b337000000000000000000000000000000f3f3d1e3e3e3e3e3e3e3e3e3d2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3e2f3f3f3f3f3f3f3f1640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b300b335b334b3b3b3b3340000b300000000000000000000000000000000f3f3d154e3e3e3e3e3e3e3e3d2f3f3f3f3f3f3d3d3d3d3d3f3f3d3d3f3f3d3f3
d3d3d3d3f3d3f3d3d3d3f3d3d3f3f1b3646400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b335a0b3b3b3b3b3b334b3b3b3b30000000000000000000000000000000000f3f3d15454e3e3e3e3e3e3e3d2f3f3f3f3f3f146464646464646464646464646
46464646464646464646464646f1b3b3464646b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3400b3b3b3b334b3b33400b3b3b3b334b3b30000000000000000000000000000f3f3f3f054e3e3e3e3e3e3e3e1f3f3f3f3f14646e3e3e3e3e3e3e3e3e3e3e3e3
e3e3e3e3e3e3e3e3e3e3e3e3c0b3b3b3b3656464b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000035b3b3b3b30000000035b3b3b3b30000000000000000000000000000f3d3f3f3f0e3e3e3e3e3e3e3e3d2f3f3d1464746e312e3e3e3e3e3e3e3e3e3e3
e3e3e3e3e3e3e3e3e3e312e3b3b3b3b3b365b3646400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00350034003435003400350034003435b3b30000000000000000000000000000d1b145d2d154e3e3e3e3e3e3e3d2f3f3d1464747464646e36046464646464646
4646464646464646464646464646b303b365b3464646000000000000000000760000000000000000000000000000000000000000000000000000000000000000
3400000035b300a0003400000035b300b3b30000000000000000000000000000d1e3b1e1f3f0e3e3e3e3e3e3e3e1f3f3d1464747464646e360464746d047d046
e0d0d0d0f3d0d0f3d0d0d0f3f0464646b365b3b3656464b3b3000000007776760000000000000000000000000000000000000000000000000000000000000000
00b335b3003400340000b335b3003400b3b30000000000000000000000000000d1e3e345d2d154e3e3e3e3e3e3e3d2f346464746e3e3e3e3604647d0f347f3d0
f3f3f3f3f3f3f3f3f3f3f3f3f3d0d0f3f065b3b365b364640000000000b376460000000000000000000000000000000000000000000000000000000000000000
3400003400003400343400003400003400b3000000000000000000000000000046e3e3b1e1f3f054e3e3e3e3e356464646465646e360464646464746f347f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0b3b365b3464646000000000003760000000000000000000000000000000000000000000000000000000000000000
04142404142404142404142404142404b3b30000000000000000000000000000e3e3e3e344d2f3f054e3e3e3e3e3e3e3e3e3e3e3e36056464646464646464646
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d1b3b365b3b3656464b3b3b3b36566b3b3000000000000000000000000000000000000000000000000000000000000
05152505152505152505152505152505b3b30000000000000000000000000000e312e344e0f3f3f3f05454e3e3e3e3e3e3e3e3e3e360e3e3e3e3e3e3e3e3e346
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d0f065b3b365b36464b3b3726567b300000000000000000000000000000000000000000000000000000000000000
06162606162606162606162606162606b3b300000000000000000000000000004646464446e1f146f0464646464646464646464646464646464660e3e3e3e346
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000
07172707172707170717270717270707b3b3000000000000000000000000000046f3e0d0f3d0d0f3f3f0f0f34646464647464746474646e0f04660e3e3e31246
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f30000000000000000000000000000000000000000000000000000000000000000
05152505152505152505152505152505b3b30000000000000000000000000000f3f3f3e0f3f3f3f3f0d0f3f3f3f3f3f346464646e0d0d0f3f346464646464646
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f30000000000000000000000000000000000000000000000000000000000000000
06162606162606162606162606162606b3b30000000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d0d0d0f3f3f3f3f3f3d0d0f3f3d0d0d0
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f30000000000000000000000000000000000000000000000000000000000000000
07172707172707172707172707172707b3b30000000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f30000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000202000000000001010100000000000000000000000000010101000000000000000000000001000101010000000000000000000000000001000100000000010100000000000000000000000000000101000000000000000000000000000001010101000000000000000000000000010101010000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3b3b3b3b3b3b3b3b3b0000003b3b3b3b3b000000000000000000001e3d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2e3f3f3f3d3d3f3d1d0b1e1d0b1e0f00000000000000003b000000000000000000003b1e3f3f3f3f3f3f3f3f3d3d3d3f3f3f00000000000000000000000000000000
3b3b003b3b003b3b003b3b3b3b3b003b00000000000000000000000000001e3f3f3f3f3f2e3f3f3f3d2e3f3f3f3f3f3f2e3f3f3f3f3f3f3f3f3f2e3f3f3f3f3f3f1f0b001d0b1d3b3b3f0f0b3f0f000000000000000000000000000000000000000b1e3d3f3f3f3f3f1f0b00001e3d3f00000000000000000000000000000000
3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b00000000000000000000003b00002d3f3f2e3f3f3f3d1f3b3d3f3f3f3d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3d3d3f3f1d3b003b3f0d3d0d3f3f3d3d3f3f0f0000003b0000000000000000000000000000003b3b2d3f3f3d1f0b000000000b2d00000000000000000000000000000000
3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b0000000000000000003b003000002d3f3f3f3f3d1f0b3b3b3b3f3d1f3e3e1e3d3d3d3f2e3f3f3f3f3f3d1f3e0c2d3f3f0d0d3f3f1d0b3f3d1f0b3b2d1f000000000000000000000000000000000000000000001e3f1d0b00000000003b002d00000000000000000000000000000000
0f303b3b3b3b3b3b3b3b3b3b3b3b3b3b000000000000000000000e0d0f00002d2e3f3f1f3e2c3b3b3b0d3d1b3e3e3e3e3e3e1b1e3f3f3f3f3f1f3e0c00001e3f3f3d3d3d3f3d0d1f0b0b001e1f0b000000000030000000000000000000000000000000000b1e1d0000000000303b002d00000000000000000000000000000000
3f0d0f3b3b3b3b3b3b3b3b3b3b3b3b3b000000000e0000000d0d2e3f1d00002d3f3f1f3c3e3e3e2c0d1f3e3e3e3e3e3e3e3e3e3e1e3f3f3f1d3e0c000000002d1d0b0b3b1d0b0000000d000b00000000000000303000000000000000003000000000000000003d000000000e0d0d0d3f00000000000000000000000000000000
3f3f1d3b3b3b3b3b3b3b3b3b3b3b3b3b000000002d0f0700003b1e3d1f00002d3f1f0b3b3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e1b2d3f3f3f0f2c000000002d3f0d0d3f3d0d0f00000b00000000000e0d0d3b30300000000000303b003000000000000000000000001c0e3f3f3f3f3f00000000000000000000000000000000
3f3f1d2828283b3b3b3b3b3b3b3b3b28000000001e1f07000000003b0b00001e1f3b3b3b003c3e3e3e3e3e3e3e060d0d0d0d3e3e3e2d3f3f3f3f0d0d0f07002d2e3f3d1f3b0b0b3b0000000000000e3f3f3f0f3030003b3b3b3b303b3b300e0d0d0f0000003b00001c3e1e3f3d3f3f3f00000000000000000000000000000000
3f3f3f0f3b3b3b3b3b3b3b3b3b0e0d0d0d0f00000b00070000000000000000000000000000003c3e3e3e3e3e3e063e3f3f3f3e3e3e1e3f3f2e3f3f3f3f073b2d3f1f1b3e2c3b3b3b3b003b0f3b3b2d3f3f3f3f0f303b3b3b3b3b300e0d0d3f3f3f3f0d0f001c3e3e3e0c0b3f0b1e3f3f00000000000000000000000000000000
3f3f3f3f0d0f3b3b3b3b3b3b0e3f2e3f3f1d0000000007000000000000000000000000000000003e3e3e3e3e3e063e2d3f3f3e3e3e3e1e3f3f3f3f3d3d073b2d1d1b3e3e3e3e3e2c3b0f3b0b3b432d3f3f2e3f3f0d0d0d0d0d0d0d3f3f3f3f3f3f2e3f3f0d3e3e3e3e2c3b3d000b2d3f00000000000000000000000000000000
3f3f2e3f3f3f0f3b0e0d0d0d3f3f3f3f3f1d000000000700000000000e0d0d0d0f0000000000003e0d0d3e3e3e063e2d3f3f0d3e3e3e1b1e3f3f1d3e3e073b2d1d3e3e0f3e3e0f3e530b0a3b3b3b2d3f3f3f2e3f3f3f3f3f3f3f3f3f3f3f2e3f3f3f3f3f3f0f3e3e3e3e2c0b3b3b1e3f00000000000000000000000000000000
3f3f3f3f3f3f3f0d3f3f3f3f3d3d3d3d3f3f0d0d0d0d0d0d0f0000002d3f3f3f3f0d07003b0d3b3c3e1b3e3e3e063e2d3f3f3f0d3e3e3e3e2d3f1d3e0c073b2d3f0f3e3e3e3e1b3e2c3b3b0d3b0e3f3f3f3f3f3f3f3d3d3d3d3d3d3d2f3f3f3f3f3f3f2e3f3f0f3e3e3e3e2c3b3b0b2d00000000000000000000000000000000
3f3f3f3f3f2e3f3f3f3f3d1f3b3b3b3b1e3f3f3f2e3f3f3f3f0d0d0d3f3f2e3f3f3f0700000000003e3e3e0d0d0d3e2d3f3f3f3f3e3e3e3e1e3f2e0f3b073b2d3f3d0f063e3e3e3e0f2c432d0d3f3f3f3f2e3f3d1f000000000000001e3d3f3f3f3f3f3f2e3f1f3e3e3e3e3e3b303b2d00000000000000000000000000000000
3f3f3f3f3f3f3f3d3d1f3b3b3b000000001e3d3f3f3f3f3f3f2e3f3f3f3f3f3f3f3f0d000000001c3e3e3e3e3e3e3e2d3f3f3f3f3e3e3e3e3e2d3f3d3f073b2d1d1b3e063e0d3e3e1b3e0e3f3f2e3f3f3f3f1f3b3b00000000003b3b3b3b1e3f3f3f3f3f3f1d1b3e3e3e3e3e0e0d0d3f00000000000000000000000000000000
3f3f3f3f3f3f1d3b3b3b3b3b3b0000000000002d3f3f2e3f3f3f3f3f3f3f3f3f3f2e3f0f00001c3e3e3e3e3e3e3e3e2d3f3f2e3f0d3e3e3e3e2d1d3e2d063b2d1d3e3e063e2d0f3e3e0d3f3f3f3f3f3f3f1f3b3b3b3b0000003b3b3b3b00001e3f3f3f3f3f1f3e3e3e3e3e0e3f3f3f3f00000000000000000000000000000000
3f3f3f3f3f3f3f0f3b3b3b3b3b3b00000000002d3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0d0d0d0d0d0d0d0d0d0d0d3f3f3f3f3f3f0d3e3e3e2d3f0d3f063b2d1d3e3e060d3f2e0d0d3f3f3f3f3f3f3f1d3b3b3b3b3b3b3b003b3b3b000000003f3f3f3f1d1b3e3e3e3e0e3f3f2e3f3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3f3f3d3f3f3f3f3f3f1d3e3e3e2d3e3e3e063e2d3d3d3e063e2d3f3f3f3f3f3f3f3f3f3f1d0000000000000000000000000000003f2e3f3f1f3e3e3e3e3e1e3d3d3f3f3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2e3f3f3f3e1b1b1b3e1b1b1b1b3e1b1b1b3e1b3e1b1b1b3e1b1b1b1e1f1b2d2e3f3f3f3f1d3e3e0e3e3e3e3e063e2d3e1b0d063e2d3f3f3f2e3f3f3f3f2e3f1d00000000000000000000000000001c3f3f3f1d3e3e3e3e3e3e3e3e1b1e3f3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d3f0d0f3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e2d3f3d3d3f3f1f3e3e2d3e3e3e3e0e0d3f0d3e1b3e3e2d3f3f3f3f3f3f3f3f3f3f1f3e2c000000000064640000001c3e3e3f3f3f1f3e3e3e213e3e3e3e3e1b2d2e00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1f3e1b1b0c3c3e3e3e3e3e0d0d0d0d0d0d0d0d0d0d0d0d0d0f3e3e3e0d3f1f0c0b2d1f3e3e3e2d0d0d3e3e3e1e3d3d0f3e3e0e3f3f3f3f3f3f3f2e3f3f3f1b643e3e2c0000646400001c3e3e0e0d3f3f1f1b3e3e3e213e3e3e3e3e0e3f3f3b0000000000002b0000000000000000
3f3f3f3f3f3f3f3f3f3d3d3d3d3f3f3f3f1d1b3e3e0c3b3b3e3e0d3e3e1b3f2e3f3f3d3d3d3f3f3f2e3f3f0d3e3e3e3e3e2c3b1e1b3e3e3e1e1f3e3e3e3e0c003c1b3e3e3e3e2d3f3f3f3f3f3f3f3f3f646464643e3e6464743e3e3e3e3e1e3f3f1f3e3e3e0d0d0f3e3e3e3e3e3e3e3e003000000000002b0000000000000000
3f3f3f3f3f3f3f3f1f3e3e1b1b1e3d3d3f3f0d3e3b3b1c060d0d1b3e3e3e3e3e3d1f1b1b3e1e3d3d3d3d3f3f0d3e3e3e3e3e3e3e3e3e3e0c3b3c3e3e0d3e2c3b1c3e3e0e0d0d3f3f3f3f3f3f3f3f3f3f647565646564643e643e3e3e3e3e3e1e1f3e3e3e3e1b3d1f3e3e3e3e3e3e3e3e003000000000002b0000000000000000
3f3f3f3f3f3f3f1d3e3e3e3e3e1b3e3e3e1b3e3e2c0d0d061b3e3e3e3e3e3e3e3e1b3e3e3e6564643e1b1e3d3f0d0d0d0d0f3e3e3e3e3e2c3b3b3c3e3e3e3e3e3e3e0e3f3f3f3f3f3f3f3f3f3f3f3f3f0f3e3e64643e64646464643e3e213e3e1b3e3e3e3e3e3e3e3e3e3e3e0d0d3f3f0d0d0d0d0d0d0d000000000000000000
3f3f3f3f3f3f3f1d3e213e3e3e3e3e3e3e3e3e3e3e1b3e063e3e3e3e233e3e3e3e3e3e3e7464647464643e1b1e3d3f3f3f3f0f3e3e3e0d3e2c3b0d3c3e3e0e0d0d0d3f3f3f3f3f3f3f3f3f3f3f3f3f3f1d646464746465643e643e3e0d0d0d0d0d0f3e3e3e3e3e3e3e3e0e0d3f2e3f3f3f3f3f3f3d1f0b000000000000000000
3f3f3f3f3f3f3f3f0d0d0d0d0d0d0d0d3f0f3e0d3e3e3e063e3e3e0d0d0d3e3e3e3e6564643e65743e753e3e3e3e1e3f2e3f3f0f3e3e1b3e0e0d3f0d0d0d3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1d64646474643e6464646474641e3f3f3f3f0f3e3e3e3e3e3e0e3f3f3f3f3f3f3f3f3d1f0b0000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0d3f0f3e3e063e3e3e3e3e1b3e3e3e3e3e75656464643e3e3e3e3e3e1b2d3f3d3d3f0f3e3e3e3e3e2d3f3d3d3f3f3f3f2e3f3f3f3f3f3f3f3f3f3f3f3d3d1d646474643e64643e753e643e1b1e3f3f3f3f0f3e3e0d3e3e1b3e1e3f3f3f2e3d1f0b00000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1d3e3e063e3e3e3e3e3e3e3e3e3e3e3e74646464643e3e3e3e0d0d3f1d1b3e1e3d0d3e3e3e3e2d1f1b3e1e3f3f3f3f3f3f2e3f3f3f3d3d3f3f1f3e3e1f3e6474646464643e3e7464643e3e2d3f3d3d3f0f3e1b3e3e3e3e1b1e3f3f3f000b0000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2e3f3f3f0d0f063e213e3e3e3e3e3e3e3e3e3e6464743e743e3e3e3e1b1e3f1d3e3e3e3e3e3e0d3e3e2d3e3e3e1b2d3f3f3f2e3f3f3f3f1f1b3e1e1f1b3e3e3e3e3e646464746464647464643e3e2d1d1b3e1e3f0d0d0d0f063e3e3e1e3f3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0d0d0d0d3e3e3e0e0d0f3e3e64643e0d0d743e3e3e3e3e1b2d1d3e3e3e3e3e3e3e3e3e1b3e3e3e3e2d3f3f3f3f3f3f3f1f1b3e3e1b3e3e3e0e0d0f3e64743e3e646564743e6464642d1d3e3e1b1e3f3f2e1d063e3e3e1b2d3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2e3f3e3e3e3e3e3e3e0d3f3f3f0f6464740d3f3f0f3e3e3e0e0d0d3f3f0d0d0d0d0d0d0d0d0d0d0f3e3e0e3f3f3f3f3f3f3f1d1b3e3e0e0d0d0d0d3f3f1d3e0e0f3e3e3e64643e646474641e3f0f3e3e1b1e3f3f1d063e0d3e3e2d3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e3e3e3e3e3e0d3f3f3f3f3f0d0f743e2d3f3f0d0d0d3f3f3f3f3f3f2e3f3f3f3f3f3f2e3f3f0d0d3f3f3f3f3f3f3f3f1d3e3e0e3f3f3f3f3f3f3f3f0d3f3f0d0f3e3e64646464743e3e3f3f0f3e3e3e2d3f1d063e1b3e3e2d3f00000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2e3f3f3f3e3e3e3f3f3f0d3f3f3f3f2e3f3f3f0d0d3f3f3f3f3f3f3f3f2e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f1d3e0e3f3f3f3f2e3f3f3f3f3f3f3f3f3f0f643e643e65643e3e3f2e3f0d0d0d3f3f1d063e3e3e0e3f3f00000000000000000000000000000000
__sfx__
011e00000c57603600046000560002600016000160001600016000360004600066000660004600036000360002600026000360006600076000760007600066000460003600016000260003600056000260001600
01100000006430c0000c0000c000186000c000000000c0000c000000000c0000c0000c0000c0000c000000000c0000c0000c0000000018600000000c000000000c0000c000000000c0000c0000c000000000c000
011000000c5310e53110535110001b0001b0001b0001b00024000240001100011000100001100018000180002d000210001d0001d000270000f0000f0001a0001000011000110001100011000110000000000000
010c0000185361a5361c5361d536185361a5361c5361d536185361a5361c5361d5361c5001d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c1330c605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0112000022122221121f1221f1122012220112221222211222112221122412224112271222711226122261122e1002b10022122221122e100301002412224112241122412222122201221f1221f1121f1121f112
011200000000000000000000000000000000002b1252b1152c1252c1152e1252e115221000000022125221252c1252c1112c1152c1152c1152c1152c1152c1152c1002c1002c1002c1002c1002c1002c1002c100
011200000f1200f110130201301013020130100f1200f110130201301013020130100f1200f11013020130100f1200f110130201301013020130100f1200f110130201301013020130100f1200f1101302013010
01120000000001100000000000000000000000271252711529125291252b1252b1252210000000221252212529125291112911529115291152911529115291150000000000000000000000000000000000000000
011200002e1252e1152b1252b1152c1252c1152e1252e1152e1152e1112e1152e11522125221252b1252b1112b1152b1152b1152b1152b1152b1152b1152b1150000000000000000000000000000000000000000
011200002b1252b115271252711529125291152b1252b1152b1152b1112b1152b1152212522125291252911129115291152911529115291152911529115291150000500000000000000000000000000000000000
011200000d1200d110130201301013020130100e1200e110130201301013020130100e1200e11013020130100d1200d110130201301013020130100e1200e110130201301013020130100e1200e1101302013010
011200002e1252e1152b1252b1152c1252c1152e1252e1152e1152e1152e1152e1152e1152e1152e1152e1152b1002b1002b1002b1002b1002b1002b1002b1000000000000000000000000000000000000000000
011200002c1252c11529125291152b1252b1152c1252c1152c1152c1152c1152c1152c1152c1152c1152c11500000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000c1200c1100f1200f1100f1200f1100c1200c1100f1200f1100f1200f1100c1200c1100f1200f1100c1200c1100f1200f1100f1200f1100c1200c1100f1200f1100f1200f1100c1200c1100f1200f110
012400202c1002c1002c1152e1142c1152c1002c1152c1142c1152c1002c1152e1142c1152c1002c1152c114271152e1002711529114271152e1002711527114271152e1002711529114271152b1002711527100
010c00003b6352e6003b625000003b6151b6003b6153b6153b6152e6003b600000003b6352e6003b625000003b6153b6153b615000003b6003760037600186003b6352e6003b625000003b615036003b6153b615
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 41 07 43 44
00 05 07 43 44
00 06 07 43 44
00 05 07 43 44
00 08 07 43 44
00 09 07 43 44
00 0a 0b 43 44
00 0c 0b 43 44
02 0d 0e 43 44
03 0f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
