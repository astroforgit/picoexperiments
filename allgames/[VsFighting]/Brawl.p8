pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- sprites
local c_player = {
    {{56},{0}},                    -- idle
    {{56,64,72,80},{0,0,0,0}},     -- run
    {{112,120},{0,0}},             -- jump
    {{64},{8}},                    -- dead
    {{56},{8}}                     -- head
}
local sprplayeridle    = {{56},{8}}
local sprplayerrun     = {{56,56,56,56},{8,0,8,16}}
local sprplayerjump    = {{56,56},{24,24}}
local sprplayerdead    = {{64},{48}}

local sprweaponsaber   = {{32},{96}}
local sprweaponaxe     = {{48},{96}}
local sprweaponspear   = {{16},{96}}
local sprweaponsword   = {{00},{96}}
local sprweaponmace    = {{64},{96}}

local sprfxslash       = {{0},{112}}
local sprbird01        = {{32,40,48},{0,0,0}}

local scoreleft        = 0
local scoreright       = 0
local scorer           = -1
local scorertime       = -1
local scorercolor      = 0
local pregamedelay     = 180
local gamerounds       = 5
local gamerounds_played= 0
local enddelay         = 0
local cam_yoffset      = 0
local cam_yoffset2     = 0
local initdelay        = -1

local room             = 0
local winner           = 0
local winnercolor      = 1

-- constants
local con_gravity = .075
local con_player_colors = {12,8,10,11}
local con_weapons = {sprweaponsaber,sprweaponaxe,sprweaponmace,sprweaponspear,sprweaponmace,sprweaponsword,{{80},{96}},{{96},{96}},{{112},{96}}}
local con_characters = {
    c_player
}

-- data
local objects = {}
local players = {}
local weapons = {}
local spikes  = {}

local game_map = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000000000000001100000000002000000002000001110000001110000000000000000000000000000000000000600000000600011111111111111111111111111111111"
local tile_map = {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
local all_game_maps = {
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000000000000001100000000002000000002000001110000001110000000000000000000000000000000000000600000000600011111111111111111111111111111111",
    "0000000000000000000000000000000002000000000000201110000000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000000001111000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000060000006000000011100001110000000000000000000000000000000000000000000000000000000200000020000000111000011100000000000000000000000000000000000033000033000033011111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000600600002011000110011000111100011001100011",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000011000000001100001100000000110000110000026011333311062011111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000020110000000000001111000000000000111110000000000111111100000000111111111000000111111111110000111111111111166111111111111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000011000000000000000000000000000000200000000000006611111111111111111111111111111111",
    "0000000000000000001111111111111000100100000100100010210010616010001011011011101000100100100100100010000010000010001111101111011000100000100000100016010000010010001111111011111000100100100000100016000000012010001111111111111000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000020000000000002001100110011001100000000000000000000000000000000000000000000000000600060000600060011001100110011000000000000000000000000000000000033003300330033011111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000266200000000000011110000000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000006201110000000000111111000000000011111100000000001111110000000000111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200060000600020010001000010001001000100001000100100010000100010010001000010001001000100001000100100010000100010",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060002200060000001111111111000000111111111100000011111111110000001111111111000000111111111100000011111111110000001111111111000",
    "0000000000000000000000000000000000000000000000000000000000000000000011111111000000001002200100000000101111010000000010111101000000001011110100000000101111010000000010111101000000001006600100000000111111110000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000000000010010000000002061001602000000111133111100000011111111110000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000060000000000600001000000000010000100000000001000000000000000000000000100100000000000010010000000020000000000200001000000000010000100000000001000000000000000000333333333333333311111111111111111111111111111111",
    "1111111111111111111111111111111111000000000000111100000000000011110000000000001111000000000000111100000000000011110002000020001111001110011100111100060000600011110001000010001111000000000000111100000000000011113000033000031111111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000001111000000000001111110000000000000000000000000011111100000000001111110000000000111111000000062011111102600001111111111110000111111111111000111111111111110011111111111111000111111111111000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000000001111000000000001111110000000001111111100000001111111111000201111111111110211111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000200006600002000111010111011110010101010001001001110101000100100100010100010010010001011101111000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    "0000011111000000000010000011100000001000001000000001000000011000000100000000010000011600006010000000010000110000000010000100000000010000001110000010000000000100001000000000010000100000000011000011020110201100000011100111000000011100001110000011110000111100",
    "1111111111111111100200000000200110111110011111011011111001111101100011100111000111101110011101111000111001110001101111100111110110001110011100011110111001110111100011100111000110111110011111011000000660000001111111111111111111111111111111111111111111111111",
    "0000000000000000000000000020000000000000001000000000000000100000010000000010000001000000001000000100000000111000012000000000000001110100100000000000010010100010000001001001610000000160100010000000011110001000000000000000100000000000000000000000000000000000",
    "0000000000000000000000111110000000001100000110000001000000000100000100000060110000100000601100000010000011000000001000010000000000100001000000000010000011000000001000000011000000010000000011000001000000000100000011002201100000000011111000000000000000000000",
    "0000000000000000000000000000000001111111111111100010000000000100000100000000100000010000000010000000100000010000000016000061000000000100001000000000010000100000000000122100000000000001100000000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000220000000000001111110000000001111111100000000110000110000000111011011100000000000000000000001110110111000000011600611000000001111111100000000011111100000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111110000001000220001000000101111110100000010006600010000001111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000111111100000000111111111000000110000001110000110000000011100011000000000110001100001000011000116661100011100011111100001110000111100000111000000000000111000000000000111000000000000111100022000001111111011111111111111111111111111111111",
    "1100000000000011110000000000001111120010010021111111011001101111011111000011111000011000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000601100000000000011111100333300111111111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000620000000000260111111111111111110000000000000011000000000000001100000000000000110000000000000011000000000000001",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000006001010100000010101111110000001111101110000000011100111000000001110011100000000111001110200002011100111111111111110011111111111111001111111111111100111111111111110",
    "1111111111111111100000000000066110111111111111111000000000000001111111111111110110000000000000011011111111111111100000000000000111111111111111011000000000000001101111111111111110000000000000011111111111111101122000000000000111111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000600600006006000010010000100100000000000000000000000000000000000102001001002010001111000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000160000000002200011600000001111111110000000000000110000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000006000000000000000100000000000000010000000000002000002000000000110001100000000000060000000000000001000000000000000100000000000000000000000000000000000000000000000000000000000000000000000",
    "0000000000000000000000000000006600000000000000110000330033003311000011111111111100111111111111110000000000000000000000000000000033000330003300001111111111110000111111111111110000000000000000000000000000000000220033000033000011111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200000000000001111000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000660000020010001111110001001000111111000100100011111100010010001111110001001000111111000100100011111100010",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022000000010000011110000011100011001100011111611100111611111111110011111111111111001111111",
    "0000000000000000000000000000000000000000000000000000011111111110000111111111110000111111000000000011110000000000011110000000000001111000000000000111120000000000001111200000000000111111000066000001111111111100000001111111111000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000000011000000000000001100000000000000110000000026000011000062011111111111111111111111111111111",
    "0000000000000000000000000000000000020000000002000001100000001100001111000001111000111100000111100001100000001100000000000000000000000000100000000000000000000000000000000000000000000000000000000010600666006010000111111111110000000000000000000000000000000000",
    "1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111600000000000061110011111111001116000000000000611100111111110011160000022000006111111111111111111111111111111111",
    "0000000000000000000011111111000000001006600100000000101111010000000010000001000000001000000100000000110000110000000010000001000000001100001100000000100000010000000011000011000000001000000100000000100220010000000011111111000000000000000000000000000000000000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000600060000021100110001100011",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111100000000001600610000000000110011000002000000000000002110000111100001100000000000000000000000000000000",
    "0011011111000000010010000011000010010020200010001000001010000100100000101000010010000010100000101000110001100001100000010000000101000001000000010100000000001110010000000001000100100000001000010011000000100001010011666100001010000011111001000111111000111000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100011000000000011000110000000006110061102211111111111111111111111111111111",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600006200000001110000111000001110000001110001110000000011101110000000000111",
    "0000060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000020000000000100001000000000010000100000",
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111000000011111111100060001111111110001000111111111000000011110000000000000000020000033300002011111111111111111111111111111111"
}

--local all_game_maps = {"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111000000011111111100060001111111110001000111111111000000011110000000000000000020000033300002011111111111111111111111111111111"}

-- etc
local t
local bird_timer = 1
local camera_lock = 1
local cam_x = 0
local cam_y = 0
local cam_shake_x = 0
local cam_shake_y = 0
local water_level = 150

-- common functions
function gamemap_decompress(s2)
    if(choose(0,1)==1) s2 = reverse(s2)
    new_map = {}
    for j=0,16 do
        new_line = {}
        for i=0,16 do
            idx = 1+(i+j*16)
            new_line[i+1] = tonum(sub(s2,idx,idx))
        end
        new_map[j+1] = new_line
    end
    return new_map
end

function solid(x,y)
    if(y<0)   return 1
    if(y>128) return 1
    if(x<0)   return 1
    if(x>122) return 1
    if(y>4) and (y<126) then
        if((game_map[flr(y/8)+1][flr((x+5)/8)+1]==1) or (game_map[flr(y/8)+1][flr((x-1)/8)+1]==1) or (game_map[flr((y+4)/8)][flr((x-1)/8)+1]==1)) return 1
    end
    return 0
end

function rectangle_collision(x,y,x1,y1,x2,y2)
    if((x > x1) and (x < x2) and (y > y1) and (y < y2)) return true
    return false
end

function draw_water(water_level)
    for x=cam_x,cam_x+127 do
        local x2 = cos(t*.3+x*.05)+sin(t*.5)*.5
        line(x,water_level+2+x2,x,cam_y+128,1)
        line(x,water_level+x2,x,water_level+1+x2,12)
        pset(x,water_level+x2,7)
        rectfill(0,128+cam_yoffset,128,128,1)
    end
end

function palf(col)
    for n=0,16 do
        pal(n,col)
    end
end

function reverse(s)
    a=""
    b=""
    c=""
    d=""
    for i=0,16 do
        b = sub(s,1+(i*16),1+(i*16)+15)
        c = ""
        for j=0,16 do
            c = sub(b,j,j)..c
        end
        d = d..c
    end
    return d
end

function tilemap_from_gamemap()
local cell
local x,y
local l,r,u,d
local n
    for y=1,16 do
        for x=1,16 do

            cell = game_map[y][x]

            l = false
            r = false
            u = false
            d = false
            if(x>1)  l = (game_map[y][x-1]==1)
            if(x<16) r = (game_map[y][x+1]==1)
            if(y>1)  u = (game_map[y-1][x]==1)
            if(y<16) d = (game_map[y+1][x]==1)

            if(cell==1)                                          tile_map[y][x]=1
            if(cell==1 and d==false)                             tile_map[y][x]=2
            if(cell==1 and u==false and d==false and l==false)   tile_map[y][x-1]=18
            if(cell==1 and u==false and d==false and r==false)   tile_map[y][x+1]=19
            if(cell==1 and u==true)                              tile_map[y][x]=17

            if(cell==3) then
                objspike(x*8-8,y*8-8)
            end

            if(cell==0 and d==true and u==false) then
                n = rnd(30)
                if(n < 6) tile_map[y][x]=3
                if(n < 5) tile_map[y][x]=33
                if(n < 4) tile_map[y][x]=34
                if(n < 3) tile_map[y][x]=35
                if(n < 2) tile_map[y][x]=36
            end

        end
    end

    for y=1,16 do
        for x=1,16 do
            if(tile_map[y][x]==17) then
                n = flr(rnd(50))
                if(n < 11) tile_map[y][x] = 48 
                if(n < 10) tile_map[y][x] = 49 
                if(n < 9)  tile_map[y][x] = 50
                if(n < 6)  tile_map[y][x] = 51
                if(n < 3)  tile_map[y][x] = 52
            end
        end
    end

    for n=0,32 do
        if(rnd(1)>.5) and (tile_map[15][flr(n/2)]==1) and (game_map[14][flr(n/2)]!=3) and (game_map[14][flr(n/2)+1]!=3) then
            objgrass(n*.5-.5,14,2+rnd(3))
        end
    end

end

function draw_map()
    for y=1,16 do
        for x=1,16 do
            if(tile_map[y][x]>0) then
                spr(tile_map[y][x],(x-1)*8,(y-1)*8)
            end
        end
    end
end

function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end
 
function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end

function map_get(x,y)
    if(y<0)   return 1
    if(y>126) return 1
    if(x<0)   return 1
    if(x>126) return 1
    return (game_map[flr(y/8)+1][flr(x/8)+1]==1)
end

function map_set(x,y,value)
    if(y<0)   return 0
    if(y>126) return 0
    if(x<0)   return 0
    if(x>126) return 0
    game_map[flr(y/8)+1][flr(x/8)+1] = value
    return 1
end

function angdis(x1,y1,x2,y2)
    return atan2(x2-x1,y2-y1)
end

function shake(x,y)
    cam_shake_x = x
    cam_shake_y = y
end

function round(x)
    if(x-flr(x))>.5 then
        return ceil(x)
    else
        return flr(x)
    end
end

function table_find(t,x)
    for _, value in pairs(t) do
        if value == x then
            return true
        end
    end
    return false
end

function outline(s,x,y,c1,c2)
    for i=0,2 do
        for j=0,2 do
                if not(i==1 and j==1) then
                 print(s,x+i,y+j,c1)
                end
            end
        end
    print(s,x+1,y+1,c2)
end

function wrap(x,mn,mx)
    v = flr(x)
    m = flr(min(mn,mx))
    x = flr(max(mn,mx))
    r = x-m+1
    return (((v-m)%r)+r)%r+m
end

function coordsin(x,y,x1,y1,x2,y2)
    if(x>x1 and x<x2 and y>y1 and y<y2) then
        return true
    else
        return false
    end
end

function out_of_screen(x,y)
    return (x<-40 or y<-40 or x>168 or y>168)
end

function lerp(tar,pos,perc)
    return (1-perc)*tar + perc*pos;
end

function sprite_x(sprite,index)
    return sprite[1][flr(index)]
end

function sprite_y(sprite,index)
    return sprite[2][flr(index)]
end

function sign(x)
    if(x>0)  return 1
    if(x==0) return 0
    if(x<0)  return -1
end

function clamp(x,mn,mx)
    return max(mn,min(mx,x));
end

function sort(a)
   for i=1,#a do
       local j = i
       while j > 1 and a[j-1].y > a[j].y do
           a[j],a[j-1] = a[j-1],a[j]
           j = j - 1
       end
   end
end

function choose(a,b)
    if(rnd(10)>5) then
        return a
    else
        return b         
    end
end

function distance(x,y)
    return abs(x-y)
end

function distance2p(x1,y1,x2,y2)
    return abs(x1-x2)+abs(y1-y2)
end

function chance(x)
    return rnd(1)<=x
end

local rspr_clear_col=0
function rspr(sx,sy,x,y,a,w)
    local ca,sa=cos(a),sin(a)
    local srcx,srcy,addr,pixel_pair
    local ddx0,ddy0=ca,sa
    local mask=shl(0xfff8,(w-1))
    w*=4
    ca*=w-0.5
    sa*=w-0.5
    local dx0,dy0=sa-ca+w,-ca-sa+w
    w=2*w-1
    for ix=0,w do
        srcx,srcy=dx0,dy0
        for iy=0,w do
            if band(bor(srcx,srcy),mask)==0 then
                local c=sget(sx+srcx,sy+srcy)
                if(c!=0) pset(x+ix,y+iy,c)
            end
            srcx-=ddy0
            srcy+=ddx0
        end
        dx0+=ddx0
        dy0+=ddy0
    end
end

function _init()

    function objplayer(x,y,id,character)
        local player = {}
        add(objects,player)
        add(players,player)

        -- input
        player.id = id

        -- sprites
        player.character = character
        player.idle = con_characters[player.character][1]
        player.run  = con_characters[player.character][2]
        player.jump = con_characters[player.character][3]
        player.head = con_characters[player.character][4]
        player.dead = con_characters[player.character][5]
        player.color= con_player_colors[id+1]

        -- combat
        player.health = 0
        player.target = player
        player.attack_delay = -1
        player.weapon = 0
        player.weaponid = 0
        player.weapon_sprite = sprweaponsword
        player.jump_attacks = 0
        player.jump_attacks_max = 1
        player.attack_angle = 0
        player.smash_timer = -1
        player.smash = 0
        player.jump_request = 0
        player.smash_charge = 0

        -- image
        player.width = 8
        player.height = 8
        player.xscale = 1
        player.yscale = 1
        player.xoff = -2
        player.yoff = -15+8
        player.index = 1
        player.sprite = player.run
        player.anim_speed = .2
        player.facing = 0
        player.attack_position = 1
        player.attack_position_e = 1
        player.attack_position_e2 = 1
        player.rotation = 0

        -- physics
        player.x = x
        player.y = y
        player.hsp = 0
        player.vsp = 0
        player.ehsp = 0 -- external hsp
        player.evsp = 0 -- external vsp
        player.acceleration = .7
        player.max_speed = 3
        player.jump_force = 7
        player.friction = .5
        player.jumps = 0
        player.jumps_max = 2

        -- states
        player.state = 0
        player.onfloor = 0
        player.onmove = 0
        player.onattack = 0
        player.isdead = false

        -- buttons
        player.b0down    = 0
        player.b1down    = 0
        player.b2down    = 0
        player.b3down    = 0
        player.b0pressed = 0
        player.b1pressed = 0
        player.b2pressed = 0
        player.b3pressed = 0
        player.b4pressed = 0
        player.bdown = 0
        player.brelease = 0

        -- jump
        player.jumpf = function()
            player.jump_request = 0
            sfx(3)
            player.jumps+=1
            player.vsp=-player.jump_force/player.jumps
            local fx = fxcircle(player.x,player.y,4,.25,7)
            fx.speed = -.35
            local fx = fxcircle(player.x,player.y,4,.25,7)
            fx.speed = .35
        end

        -- death
        player.death = function()
            if(player.isdead==false) and (scorertime < 0) then
                if(id==1) then
                    scoreleft  += 1
                    scorercolor = con_player_colors[(1-id)+1]
                end
                if(id==0) then
                    scoreright += 1
                    scorercolor = con_player_colors[(1-id)+1]
                end
                scorer = 1-id
                scorertime = 180
                player.isdead = true
                sfx(1)
                music(17)

                if(player.weapon>0) then
                    weapon = objweapon(player.x,player.y,player.weaponid)
                    weapon.hsp =  choose(.5,-.5)
                    weapon.vsp = -12
                    player.weapon = 0
                    player.weaponid = 0
                end
            end
        end

        -- step
        player.step = function()
            if(pregamedelay>0) return 1
            if(room==2) return 1

            -- states
            local canattack = 1
                if(player.state==1) canattack = 0
            local canmove = 1
                if(player.state==1) canmove = 0
                if(player.smash==1) canmove = 0
            player.onfloor = 0
                if(solid(player.x,player.y+1)==1) player.onfloor = 1
            player.onmove = 0
                if(abs(player.hsp)>0.1) player.onmove = 1
            player.onattack = 0
                if(distance(player.attack_position,player.attack_position_e)>.1) player.onattack = 1

            -- timers
            if(player.attack_delay>-1) player.attack_delay-=1
            if(player.smash_timer>-1) and not (btn(4,player.id)) then
                player.smash_timer-=1
                if(player.smash_timer==0) then
                    if(player.jump_request==1) then
                        player.jumpf()
                    end
                end
            end

            -- angle
            --if(player.onattack==0) then
            player.attack_angle = player.facing*.5
            --    if(btn(0,player.id)) player.attack_angle = .5
            --    if(btn(1,player.id)) player.attack_angle = .0
            --    if(btn(2,player.id)) player.attack_angle = .75
            --    if(btn(3,player.id)) player.attack_angle = .25
            --end

            -- button checkers
            player.b0pressed = 0
            if(btn(0,player.id)) then
                if(player.b0down==0) player.b0pressed = 1
                player.b0down = 1
            else
                player.b0down = 0
            end
            player.b1pressed = 0
            if(btn(1,player.id)) then
                if(player.b1down==0) player.b1pressed = 1
                player.b1down = 1
            else
                player.b1down = 0
            end
            player.b2pressed = 0
            if(btn(5,player.id)) then
                if(player.b2down==0) player.b2pressed = 1
                player.b2down = 1
            else
                player.b2down = 0
            end
            player.b3pressed = 0
            if(btn(3,player.id)) then
                if(player.b3down==0) player.b3pressed = 1
                player.b3down = 1
            else
                player.b3down = 0
            end
            player.b4pressed = 0
            if(btn(4,player.id)) then
                if(player.bdown==0) then
                    player.b4pressed = 1
                    player.bdown = 1
                end
            else
                player.brelease = 0
                if(player.bdown == 1) player.brelease = 1
                player.bdown = 0
            end

            -- input
            if(player.b2pressed==1 and (canmove==1) and (player.onattack==0) and (player.onfloor==1 or player.jumps==1) and player.jumps<player.jumps_max) then
                player.jumpf()
            end
            if(btn(0,player.id) and (player.onattack==0) and (canmove==1)) player.hsp-=player.acceleration
            if(btn(1,player.id) and (player.onattack==0) and (canmove==1)) player.hsp+=player.acceleration

            -- attacks/actions
            if(player.onattack==0) and (canattack==1) then 

                -- charge
                if(player.b4pressed==1 and (player.onattack==0) and (player.onfloor==1) and player.smash_timer>0) then
                    player.smash = 1
                    player.jump_request = 0
                end 

                if(btn(4,player.id)) and (player.smash==1) then
                    player.smash_charge += .01
                    local fx = fxcircle(player.x+1,player.y-1,4,.25,choose(player.color,7))
                    if(player.facing==-1) fx.x += 1
                    fx.speed = 1
                    fx.dir -= .22+rnd(6)/100
                    if(player.smash_charge>1) player.smash_charge = 1
                end

                -- attack
                if(not btn(3,player.id)) then
                    if(player.smash==1 and player.brelease==1) or (player.smash == 0 and player.b4pressed==1) then
                        if(player.weapon>0) and (player.jump_attacks<player.jump_attacks_max) and (player.attack_delay<0) then
                            player.attack_position = abs(player.attack_position-1)

                            -- angle
                            if(btn(0,player.id)) player.attack_angle = .5
                            if(btn(1,player.id)) player.attack_angle = .0
                            if(btn(2,player.id)) player.attack_angle = .75
                            if(btn(3,player.id)) player.attack_angle = .25
                            ang = player.attack_angle

                            sfx(0)

                            if(player.onfloor==0) then
                                player.hsp =  cos(ang)
                                player.vsp = -sin(ang)
                                player.jump_attacks += 1
                                if(player.jumps<2) player.jumps = 2
                            end

                            player.attack_delay = 30
                            local fx = fxcircle(player.x,player.y,4,.25,7)
                            fx.speed = -.35
                            local fx = fxcircle(player.x,player.y,4,.25,7)
                            fx.speed = .35

                            local size = 12
                            if(player.attack_angle==.25 or player.attack_angle==.75) size += 3
                            local collision = objcollision(player.x,player.y,size,10,player,player.attack_angle-.1+rnd(1)/10,flr(25*player.smash_charge+rnd(10)))
                            collision.attach = player
                            collision.attach_x =  cos(ang)*6+1
                            collision.attach_y = -sin(ang)*6-4
                            if(player.attack_angle == .25) collision.attach_y = -2

                            player.smash = 0
                            player.smash_charge = 0

                        end
                    end
                end


                -- grab weapon
                if(player.weapon==0) and (player.b4pressed==1) and (player.onfloor==1) then
                    for weapon in all(weapons) do
                        if(distance2p(weapon.x,weapon.y,player.x,player.y)<16) then
                            player.weapon = 1
                            player.weaponid = weapon.id
                            player.weapon_sprite = con_weapons[weapon.id]
                            player.bdown = -1
                            weapon.die()
                            player.smash = 0
                            player.smash_timer = -1
                            break
                        end
                    end
                end

                -- throw weapon
                if(btn(3,player.id)) and (player.b4pressed==1) and (player.weapon==1) then
                    weapon = objweapon(player.x,player.y,player.weaponid)
                    player.attack_angle = player.facing*.5
                    weapon.hsp =  cos(player.attack_angle-.05+rnd(5)/100)*3
                    weapon.vsp = -2 - sin(player.attack_angle)*3
                    player.weapon = 0
                    player.weaponid = 0
                    player.jump_request = 0
                    sfx(6)
                    if(player.onfloor==0) player.vsp = -1

                    local collision = objcollision(player.x,player.y,10,25,player,player.facing*.5,flr(25+rnd(5)),weapon.angle)
                    collision.attach = weapon
                    collision.attach_x = 1
                    collision.attach_y = -3
                end

            end

            -- out of bounds death
            if(player.y > water_level+7) and (player.state==0) then

                -- drop weapon
                if(player.weapon>0) then
                    weapon = objweapon(player.x,player.y,player.weaponid)
                    weapon.hsp =  choose(.5,-.5)
                    weapon.vsp = -12
                    player.weapon = 0
                    player.weaponid = 0
                end

                sfx(1)

                -- throw player
                player.ehsp = choose(-4,4)
                player.vsp = -3*(1-player.state*.5)
                player.state = 1
                shake(5,5)

                player.death()
                player.die()

            end

            -- physics
            local sum_hsp = player.hsp+player.ehsp
            local sum_vsp = player.vsp+player.evsp
            if(solid(player.x,player.y+sum_vsp)==0) then
                player.y   += sum_vsp
                if(player.onattack==0) player.vsp += con_gravity*distance(sum_vsp,0)+0.1
                if(player.onfloor==0 and player.jumps==0) then
                    player.jumps=1
                    player.jump_attacks = 0
                end
            else
                for i=0,10 do
                    if(solid(player.x,player.y+sign(sum_vsp))==0) then
                        player.y+=sign(sum_vsp)
                    else
                        break
                    end
                end
                if(sum_vsp>=0) then
                    player.jumps = 0
                    player.jump_attacks = 0
                end
                
                if(sum_vsp>.5) then
                    local fx = fxcircle(player.x,player.y,4,.25,7)
                    fx.speed = -.35
                    local fx = fxcircle(player.x,player.y,4,.25,7)
                    fx.speed = .35
                    sfx(2)
                end

                player.vsp = 0
                player.evsp = 0
            end

            if(solid(player.x+sum_hsp,player.y)==0) then
                player.x += sum_hsp
            else
                if(abs(player.ehsp)>5) then
                    player.hsp  = -player.hsp
                    player.ehsp = -(player.ehsp/2)
                else
                    player.hsp = 0
                end
            end
            player.vsp = clamp(player.vsp,-player.max_speed,player.max_speed)
            player.hsp = clamp(player.hsp,-player.max_speed,player.max_speed)
            if(player.onattack==0) then
                player.hsp  *= player.friction
                player.ehsp *= .9
            end

            -- sprites
            if(player.onfloor==1) then -- floor
                if(player.onmove==1) then
                    player.sprite = player.run
                    player.anim_speed = .2
                else
                    player.sprite = player.idle
                    player.anim_speed = 0
                    player.index = 1
                end
            else -- air
                player.sprite = player.jump
                player.anim_speed = 0
                if(sum_vsp<0) player.index = 1
                if(sum_vsp>0) player.index = 2
            end
            if(player.state==1) and (player.onfloor==1) then
                player.sprite = player.dead
            end

            -- eye candy
            if(player.onattack==1) or (player.state==1 and player.onfloor==0) or (abs(player.ehsp)>1) then
                fxcircle(player.x,player.y-3,3,.2,player.color)
                player.rotation += .05
            end
            if(player.onattack==1) then
                local _f = (1-player.facing*2)*-1
                if(player.attack_position_e2 > player.attack_position_e) then
                    fxcircle(player.x+cos(player.attack_position_e2+.25-player.attack_angle)*10,player.y-3+sin(player.attack_position_e2+.25-player.attack_angle)*10,4,.15,7)
                else
                    fxcircle(player.x+cos(player.attack_position_e2-.25-player.attack_angle)*10,player.y-3+sin(player.attack_position_e2-.25-player.attack_angle)*10,4,.15,7)
                end
            end
            if(player.onmove==1)and(chance(.5)) then
                local fx = fxcircle(player.x+2,player.y,2,.25,7)
                fx.speed = .2+rnd(1)*.5
                fx.dir = .75
            end

            -- image
            player.index += player.anim_speed
            if(player.index>#player.sprite[1]+1) player.index = 1
            if(player.hsp> 0.1) player.facing = 0
            if(player.hsp<-0.1) player.facing = 1

            player.attack_position_e  = lerp(player.attack_position_e, player.attack_position,.2)
            player.attack_position_e2 = lerp(player.attack_position_e2,player.attack_position_e,.1)

        end

        player.die = function()
            del(objects,player)
            del(players,player)
        end

        -- draw
        player.draw = function()

            -- draw player
            pal(12,player.color)
            if(abs(player.ehsp)<1) then
                sspr(sprite_x(player.sprite,player.index),sprite_y(player.sprite,player.index),8,8,player.x+player.xoff,player.y+player.yoff,player.width*player.xscale,player.height*player.yscale,player.facing==1)
                pal()
            else
                rspr(sprite_x(player.sprite,player.index),sprite_y(player.sprite,player.index),player.x+player.xoff,player.y+player.yoff,player.rotation,1)
                pal()
            end

            -- draw weapon
            if(player.weapon>0) then
                ang = 0+.35+.25*(1-player.facing)-.75*player.attack_position_e;
                --ang += player.facing*.5
                ang += player.attack_angle
                if(player.facing==0) ang -= .25
                ang += player.smash_charge * .1
                rspr(sprite_x(player.weapon_sprite,1),sprite_y(player.weapon_sprite,1),player.x-5+cos(ang+player.facing)*5,player.y-sin(ang+player.facing)*5-11,ang,2)
            end

        end

        return player
    end

    function objweapon(x,y,weaponid)
        local weapon = {}
        add(weapons,weapon)
        weapon.x = x
        weapon.y = y
        weapon.hsp = 0
        weapon.vsp = -rnd(2)
        weapon.friction = .8
        weapon.max_speed = 8
        weapon.angle = 0
        weapon.id = weaponid
        weapon.sprite = con_weapons[weaponid]

        weapon.step = function()

            -- die
            --if(y>=127) die()

            -- physics
            if(solid(weapon.x,weapon.y+weapon.vsp)==0) then
                weapon.y   += weapon.vsp
                weapon.vsp += con_gravity*distance(weapon.vsp,0)+0.1
            else
                for i=0,10 do
                    if(solid(weapon.x,weapon.y+sign(weapon.vsp))==0) then
                        weapon.y+=sign(weapon.vsp)
                    else
                        break
                    end
                end
                
                if(weapon.vsp>.5) then
                    local fx = fxcircle(weapon.x+4,weapon.y,4,.25,7)
                    fx.speed = -.35
                    local fx = fxcircle(weapon.x+4,weapon.y,4,.25,7)
                    fx.speed = .35
                end
                if(weapon.vsp>1) then
                    shake(3,3)
                end
                weapon.vsp = 0
                weapon.hsp = 0
                if(weapon.angle != .125) sfx(2)
                weapon.angle = .125
            end

            if(solid(weapon.x+weapon.hsp,weapon.y)==0) then
                weapon.x += weapon.hsp
            else
                weapon.hsp = 0
            end
            weapon.vsp = clamp(weapon.vsp,-weapon.max_speed,weapon.max_speed)
            weapon.hsp = clamp(weapon.hsp,-weapon.max_speed,weapon.max_speed)
            if(solid(weapon.x,weapon.y+1)==1) weapon.hsp *= weapon.friction

            -- eye candy
            local move_speed = abs(weapon.hsp)*5+abs(weapon.vsp)
            if(move_speed>1) then
                weapon.angle += move_speed*.005
                fxcircle(weapon.x+cos(weapon.angle)*0,weapon.y-3+sin(weapon.angle-.25)*0,2,.15,6)
            end

        end

        weapon.draw = function()
            rspr(sprite_x(weapon.sprite,1),sprite_y(weapon.sprite,1),weapon.x-6,weapon.y-12,weapon.angle,2)

            if(solid(weapon.x,weapon.y+1)==1) then
                spr(25,weapon.x+2,weapon.y-15+sin(time()))
            end
        end

        weapon.die = function()
            del(weapons,weapon)
        end

        return weapon
    end

    function objcollision(x,y,size,life,player,direction,damage)
        local collision = {}
        add(objects,collision)
        collision.x = x
        collision.y = y
        collision.attach = -1
        collision.attach_x = 0
        collision.attach_y = 0
        collision.size = size
        collision.life = life
        collision.parent = player
        collision.dir = direction
        collision.damage = damage
        collision.targets = {}
        collision.step = function()

            -- player collision
            for player in all(players) do
                if(collision.parent != player) then
                    if(distance2p(collision.x,collision.y,player.x+3,player.y-5)<collision.size) then
                        if(table_find(collision.targets,player.id)==false) then
                            -- hit player
                            ang = angdis(collision.x,collision.y,player.x,player.y)
                            player.health += collision.damage
                            player.ehsp = ((10-player.state*7)*cos(collision.dir)*(1-player.state*.5))
                            player.vsp  = -2+player.state*.5
                            shake(5,5)
                            player.state = 1
                            player.death()
                            add(collision.targets,player.id)
                        end
                    end
                end
            end

            -- follow attached to object
            if not(collision.attach==-1) then
                collision.x = collision.attach.x+collision.attach_x
                collision.y = collision.attach.y+collision.attach_y
            end

            -- death
            collision.life -= 1
            if(collision.life<=0) collision.die()

        end

        collision.draw = function()
            --circ(collision.x,collision.y,collision.size,9)
        end

        collision.die = function()
            del(objects,collision)
        end

        return collision
    end

    function fxcircle(x,y,size,t,col)
        local fx = {}
        add(objects,fx)
        fx.x = x
        fx.y = y
        fx.speed = 0
        fx.dir = 0
        fx.friction = 1
        fx.size = size
        fx.time = t
        fx.color = col
        fx.spd = size/60/t

        fx.step = function()
            fx.x+=fx.speed*cos(fx.dir)
            fx.y-=fx.speed*sin(fx.dir)
            fx.speed*=fx.friction
            fx.size -= fx.spd
            if(fx.size<=0) fx.die()
        end

        fx.draw = function()
            circfill(fx.x,fx.y,fx.size,fx.color)
        end

        fx.die = function()
            del(objects,fx)
        end

        return fx
    end

    function fxsanim(x,y,sprite,anim_speed,life,rotated)
        local fx = {}
        add(objects,fx)
        fx.x = x
        fx.y = y
        fx.sprite = sprite
        fx.anim_speed = anim_speed
        fx.index = 1
        fx.rotated = rotated
        fx.angle = 0
        fx.width = 2
        fx.height = 2
        fx.life = life
        fx.step = function()

            -- death
            fx.life -= 1
            if(fx.life<=0) fx.die()

            -- anim
            fx.index += fx.anim_speed
            if(fx.index>#fx.sprite[1]+1) fx.index = 1

        end

        fx.draw = function()

            if(fx.rotated==1) then
                rspr(sprite_x(fx.sprite,fx.index),sprite_y(fx.sprite,fx.index),fx.x,fx.y,fx.angle,fx.width)
            else 
                sspr(sprite_x(fx.sprite,fx.index),sprite_y(fx.sprite,fx.index),fx.width*8,fx.height*8,fx.x,fx.y)
            end

        end

        fx.die = function()
            del(objects,fx)
        end

        return fx
    end

    function objspike(x,y)
        local spike = {}
        add(objects,spike)

        spike.x = x
        spike.y = y


        spike.step = function()

            -- player collision
            for player in all(players) do
                if(rectangle_collision(player.x,player.y,spike.x,spike.y+4,spike.x+8,spike.y+8)) then
                    if(player.state != 1) then
                        ang = angdis(spike.x,spike.y,player.x,player.y)
                        player.health-=1
                        player.ehsp = ((10-player.state*7)*cos(choose(1,-1))*(1-player.state*.5))
                        player.vsp  = -2+player.state*.5
                        shake(5,5)
                        player.state = 1
                        player.death()
                        sfx(32)
                    end
                end
            end

        end

        spike.draw = function()
            spr(20,spike.x,spike.y)
        end

        spike.die = function()
            del(objects,spike)
        end

    end

    function objbird(x,y)
        local bird = {}
        add(objects,bird)

        -- physics
        bird.x = x
        bird.y = y
        bird.spd = .5+rnd(1)
        bird.dir = 0
        bird.dir_speed = 0.0001+rnd(1)/2000
        bird.dir_orientation = choose(1,-1)

        -- image
        bird.idle = sprbird01
        bird.sprite = bird.idle
        bird.index = 1
        bird.anim_speed = .15

        bird.step = function()

            -- move
            bird.x += bird.spd*cos(bird.dir)
            bird.y -= bird.spd*sin(bird.dir)
            bird.dir -= bird.dir_speed*bird.dir_orientation

            -- anim
            bird.index += bird.anim_speed*bird.spd
            if(bird.index>#bird.sprite[1]+1) bird.index = 1

            -- die
            if(out_of_screen(bird.x,bird.y)) then
                del(objects,bird)
            end

        end

        bird.draw = function()
            rspr(sprite_x(bird.sprite,bird.index),sprite_y(bird.sprite,bird.index),bird.x,bird.y,bird.dir,1)
            --sspr(sprite_x(bird.sprite,bird.index),sprite_y(bird.sprite,bird.index),16,16,bird.x,bird.y)
        end

        return bird
    end

    function objgrass(x,y,length)
        local grass = {}
        add(objects,grass)
        grass.x = x*8
        grass.y = y*8
        grass.length = length
        grass.color = {3,11,11}
        grass.idx = 1
        grass.offset = rnd(1)

        grass.step = function()
            grass.idx = 1
        end

        grass.draw = function()
            for i=0,grass.length do
                pset(
                    grass.x+(i/grass.length)*sin(grass.offset+t*.33)*2,
                    grass.y-i,
                    grass.color[grass.idx]
                )
            end
        end

        return grass
    end

    function reset()
        tile_map = {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}

        game_map = gamemap_decompress(all_game_maps[flr(rnd(#all_game_maps))+1])

        for player in all(players) do   
            player.die()
        end

        for weapon in all(weapons) do
            weapon.die()
        end

        for spike in all(spikes) do
            spike.die()
        end

        for obj in all(objects) do
            del(objects,obj)
        end

        water_level = 126

        music(18)

    end

    --
    -- init game
    --
    -- load map
    function initgame() 

        reset()

        water_level = 126

        pregamedelay = 180

        music(0,200)

        for x=1,16 do
            for y=1,16 do
                cell = game_map[y][x]
                _x = -3
                if(x > 8) _x = -2
                if(cell==2) then
                    if(#players==3) p4 = objplayer(-4+_x+x*8,-1+y*8,3,1)
                    if(#players==2) p3 = objplayer(-4+_x+x*8,-1+y*8,2,1)
                    if(#players==1) p2 = objplayer(-4+_x+x*8,-1+y*8,1,1)
                    if(#players==0) p1 = objplayer(-4+_x+x*8,-1+y*8,0,1)
                end
                if(cell==6) objweapon(((x-1)*8)+1,((y-1)*8)+6,1+flr(rnd(9)))
            end
        end
        tilemap_from_gamemap()

        room = 1 -- go to game room

        gamerounds_played += 1

    end


        game_map = gamemap_decompress("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000000000000001100000000002000000002000001110000001110000000000000000000000000000000000000600000000600011111111111111111111111111111111")
        tilemap_from_gamemap()
        reset()
    --initgame()

end

function _update60()

    if(room==1) then
        water_level -= .025
    end

    -- cam yoffset
    cam_yoffset = lerp(cam_yoffset,cam_yoffset2,.1)

    -- scorer delay
    if(scorertime > -1) then
        scorertime-=1
        if(scorertime==0) then
            if(cam_yoffset2!=0) sfx(43)
            cam_yoffset2 = 0
            scorer = -1
            if(gamerounds_played >= gamerounds) then
                room = 2
                if(scoreleft>scoreright) then
                    winnercolor = con_player_colors[1]
                    winner = 0
                end
                if(scoreleft<scoreright) then
                    winnercolor = con_player_colors[2]
                    winner = 1
                end
            else
                initgame()
            end
        end
    end

    -- update end delay
    if(room==2) then
        enddelay+=1
        if(enddelay>180) then
            reset()
            room=0
            enddelay=0
            scoreleft  = 0
            scoreright = 0
            gamerounds_played = 0
        end
    end

    -- change rounds
    if(room == 0) then
        if(btnp(0)) then 
            gamerounds-=2
            sfx(33)
        end
        if(btnp(1)) then 
            gamerounds+=2
            sfx(33)
        end
        if(gamerounds<1) gamerounds=1
        if(gamerounds>19)gamerounds=19
    end

    -- pregame delay
    if(room == 1) then
        if(pregamedelay > -1) then
            if((pregamedelay%60==0)and(pregamedelay>1)) sfx(4)
            if((pregamedelay%60==0)and(pregamedelay<2)) sfx(5)
            pregamedelay-=1
        end
    end

    -- start game
    if(btn(Ž)) and (room==0) then
        if(cam_yoffset2 != 130) sfx(42)
        cam_yoffset2 = 130
        initdelay = 60
    end

    -- init delay
    if(initdelay > -1) then 
        initdelay-=1
        if(initdelay==0) then
            if(cam_yoffset2!=0) sfx(43)
            cam_yoffset2 = 0
            initgame()
        end
    end

    -- time
    t = time()

    -- alarms
    if(room == 1) then
        if(bird_timer>-1) then
            bird_timer-=1
            if(bird_timer==0) then
                bird_timer = 60
                if(chance(.25)) objbird(-30,rnd(100))
            end
        end
    end

    -- camera
    if(camera_lock==0) then
        local mid_x = 64
        local mid_y = 64
        for p in all(players) do
            mid_x += p.x
            mid_y += p.y
        end
        cam_x = lerp(cam_x,(mid_x/(#players+1))-64,.1)
        cam_y = lerp(cam_y,(mid_y/(#players+1))-64,.1)
    end
    if(abs(cam_shake_x)>0) cam_shake_x = (abs(cam_shake_x)-1)*choose(-1,1)
    if(abs(cam_shake_y)>0) cam_shake_y = (abs(cam_shake_y)-1)*choose(-1,1)
    camera(cam_x+cam_shake_x,cam_y+cam_shake_y+cam_yoffset)

    -- objects
    for x in all(objects) do
        x.step();
    end

    -- weapons
    for x in all(weapons) do
        x.step();
    end

    pal()

end

function _draw()
    cls()

    -- menu
    if(room==0) then

        --rectfill(0,0,128,128)

        -- logo
        spr(96,0,10+3*sin(time()*.25),16,6)
        --sspr(0,64,64,32,0,0+3*sin(time()*.25),128,64)

        -- menu

        local tt = "press ".."—/Ž".." to play"
        print(tt,hcenter(tt)-2,60,7)
        local tt = "[‹] "..gamerounds.." rounds [‘]"
        print(tt,hcenter(tt)-2,68,9)

        local tt = "how to play"
        print(tt,hcenter(tt)-2,84,7)
        local tt = "[— attack/pick weapon]"
        print(tt,hcenter(tt)-2,92,5)
        local tt = "[ƒ— to throw weapon]"
        print(tt,hcenter(tt)-2,100,5)

    end

    -- draw weapons
    for x in all(weapons) do
        x.draw();
    end

    -- draw maps
    draw_map()

    -- draw objects
    sort(objects)
    for x in all(objects) do
        x.draw();
    end

    -- endgame fill
    if(room==2) then
        rectfill(0,0,128,128,0)
    end

    -- draw water
    draw_water(water_level)

    -- draw score
    if(room==1) then
        --outline("score",56,2,0,7)
        --outline(tostr(scoreleft).."-"..tostr(scoreright),60,8,0,7)
    end

    -- winner
    if(scorertime > 0) then
        local tt = "player "..tostr((scorer)+1).." wins!!"
        outline(tt,hcenter(tt),vcenter(tt),0,choose(scorercolor,7))
        if(scorertime < 45) then
            if(cam_yoffset2 != 130) sfx(42)
            cam_yoffset2 = 130
        end
    end

    -- pregame time
    if(room==1) then
        if(pregamedelay > 0) then
            local tt = "game starts in"
            outline(tt,hcenter(tt),vcenter(tt)-4,0,7)
            tt = tostr(1+flr(pregamedelay/60))
            outline(tt,hcenter(tt),vcenter(tt)+4,0,7)
        end
    end

    -- endgame
    if(room==2) then
        local tt = "player "..tostr(winner+1).." wins!!"
        print(tt,hcenter(tt)-2,vcenter(tt),winnercolor)
        local tt = tostr(scoreleft).."-"..tostr(scoreright)
        print(tt,hcenter(tt)-2,vcenter(tt)+8)
    end

    -- debug
    -- pal()
    -- pc = 11
    -- if(stat(1)>.33) pc = 9
    -- if(stat(1)>.66) pc = 8
    -- if(stat(1)>.99) pc = 2
    -- pm = 11
    -- if(stat(0)/512>.33) pm = 9
    -- if(stat(0)/512>.66) pm = 8
    -- if(stat(0)/512>.99) pm = 2
    -- print("cpu:"..tostr(flr(stat(1)*100)).."%",cam_x+2,cam_y+2,pc)
    -- print("mem:"..tostr(flr(stat(0)/512*100)).."%",cam_x+2,cam_y+8,pm)


end
__gfx__
00000000bbb3bbb3bbb3bbb300000000000000000000000000000000000cccc0000cccc0000cccc000000000000cccc0000cccc0000000000011ccc0000cccc0
000000003331333133313331000000000666000000000000000000000011c1c10011c1c10011c1c1000cccc00011c1c10011c1c1000cccc0011cc1c10011c1c1
0000000033313331333133310000000000666000000000000000077000cc77c700c177c700c177c70011c1c100c177c700c177c70011c1c1011c77c701c177c7
00000000d551555121222122000e0000000667700066677007777759001c7717011c7717001c771700c177c7001c7717001c771700c177c701cc77c701c17717
000000006dddddd54244424400eae00007777759076667590076660001cc11c11ccc77c701cc11c1001c7717001c77c7001c11c1001c771701cc771701cc11c1
000000006dddddd500000000000e000000776600007766000066600001c1cccc1c1111c101c1cccc001c11c1001cc1c1001cc1cc001c11c101cc11c1001ccccc
000000006dddddd50000000000b3b0000000000000000000066600000011cc1101ccc1110011cc11001c1ccc0011cc1100011c11001c1ccc0011cc110001cc11
00000000d55555510000000000030000000000000000000000000000000c0010000000010000c01000011c1100000c000000c01000011c1100000c0000000c00
00000000d666666d0000003bb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006dddddd500000023320000000000000000000000000000000000000000cccc0000000000000000000000000000000000000000000000000000000000
000000006dddddd5000000044000000000000000000000000000000000000000011c1c1000000000000000000000000000000000000000000000000000000000
000000006dddddd50000000000000000000000000000000000000000017700000cc77c7000000000000000000000000000000000000000000000000000000000
000000006dddddd50000000000000000110011000000000000000000ccc1ccc001c7717000777000000000000000000000000000000000000000000000000000
000000006dddddd50000000000000000171017101100110000000000c1771ccc00c11c0000070000000000000000000000000000000000000000000000000000
000000006dddddd50000000000000000167116711710171000000000c1771cc10000000000000000000000000000000000000000000000000000000000000000
00000000d555555100000000000000001671167116711671000000000cc1cccc0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003bb3bb3b00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000023b23b2300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000004424424400000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000009000000030000000c0000000200004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009a9000003a300000cac000002a20004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000009000000030000000c0000000200004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000b3b00000b3b00000b3b00000b3b0004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000300000003000000030000000300004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
d666666dd666666dd666666dd666666dd666656d4444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddd56dddddd56dddd5d56ddd5dd56dd500054444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
6d7666d56dddddd56dddd0556dd505d56d5000054444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6dd5d56dd56dd56d6dd0056d5005d5650000654444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6dd5d56ddd56d56d56d6656d500055600066d54444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6551d56dddddd56dd5ddd5650000556006ddd54444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddd56dddddd56dddddd56d566655666dddd54444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
d5555551d5555551d5555550d5555551d55555514444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000001000000000000000000000000000000000000001000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001100000000000000000000000000000000000011000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001610000000000000000000000000000000000161000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001661000000000000000000000000000000001661000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001666100000000000000000000000000000016661000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001775610000000000000000000000000000165771000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001665561000000000000000000000000001655661000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001665556100000000000000000000000016555661000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001766555610000000000000000000000165556671000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000176655561000000000000000000001655566710000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000117665556100000000000000000016555667110000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000011766555610000000000000000165556671100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001176655561000000000000001655566711000000000000000000000000000000000000000000000000
00000000000000000001111111110000000111111111110117665556100111000000011155667110111000000001100000110000000000000000000000000000
00000000000000000017777777771100001777777777771011766555611777100000117716671101777100000017710001771000000000000000000000000000
00000000000000000017777777777710001777777777777101176655561777100001617716711001777100000017710001771000000000000000000000000000
00000000000000000017711111117771001771111111177710117665517717710016511771110017717710000177110001771000000000000000000000000000
00000000000000000017711111111771001771111111117710011766517717710165511771100017717710000177110001771000000000000000000000000000
00000000000000000017711111111771001771111111117710001176177717771655561771000017717710000177100001771000000000000000000000000000
00000000cccccccccc1771cccccc1771cc1771ccccccc1771cccc117177111771555661771888177111771888177188881771888888888888888880000000000
0000000ccccccccccc17711111117711cc177111111117771ccccc11177111771556671177188177111771881771188881771888888888888888888000000000
000000cccccccccccc17777777777711cc177777777777711cccccc1771151177166711177188177181771881771188881771888888888888888888800000000
000000cccccccccccc1777777777771ccc177777777771111cccccc1771161177167118177181777181177181771888881771888888888888888888800000000
000000cccccccccccc17711111117771cc17711117771111ccccccc1771111177111188177181771181177181771888881771888888888888888888800000000
000000cccccccccccc177111111117771c1771111177711ccccccc17777777777711888177711771188177117771888881771888888888888888888800000000
000000cccccccccccc1cc111111111771c1cc111111ccc1ccccccc1cccccc8888816188118818881888188818811888881881888888888888888888800000000
000000cccccccccccc1cc1cccccc11cc1c1cc1ccc11ccc1cccccc1ccc11111118881618118818811888118818811888881881888888888888888888800000000
000000cccccccccccc1771ccccccc1771c1771cccc117771ccccc177111111111771561817717711888117717718888881771888888888888888888800000000
000000cccccccccccc1cc11111111cc11c1cc1cccc111cc1ccccc1cc111111111881556118818818888818818818888881881111111188888888888800000000
0000000ccccccccccc177777777777711c1771ccccc117771ccc1771156671111177155611777118888811777118888881777777777718888888888000000000
00000000cccccccccc17777777777111cc1771cccccc117771cc1771166711881177155511777118888811777118888881777777777718888888880000000000
00000000000000000011111111111111001111000000111111011111667110000111166661111100000001111100000001111111111110000000000000000000
00000000000000000011111111111110001111000000011111191111661100000111166611111100000001111100000001111111111110000000000000000000
00000000000000000001111111111000000110000000001111941116611000000011166111111000000000111000000000111111111100000000000000000000
00000000000000000000000000000000000000000000000019411001110000000000111001149100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000194110000000000000000000000114910000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001941100000000000000000000000011491000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000014211000000000000000000000000001124100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000012110000000000000000000000000000112100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000100000000000000000000000000000010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000066600000000000000000000000000000000000000000000111110000000000000000
00000000000000000000000000000000000000000000000000000000000655560000000000044440000000660000028000000000000111110000000000000000
00000000955555560000000009666666000000009000000000000000000059500000000004499994000005500002888800000000000151510000000000000000
00000042a5555556000000a42555555600000044a55555560000002444442a240000002444444444000008800288805500000024444425240000002444442a24
0000000096666660000000000966666000000090a666666000000000000059500000000004444444000000882880006600000000000151510000000000005950
00000000000000000000000000000000000000aa9000000000000000000655560000000000044440000000088000000000000000000111110000000000065556
00000000000000000000000000000000000000000000000000000000000066600000000000000000000000000000000000000000000111110000000000006660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000016610216102c6203163031630306202561008600016000000000000000000000000000015000a50000000245002450025500000000000000000000000000000000000000000000000000000000000000
00010000306702f6602f6502d6502d6402b6302965022650206501e6501c6501b6501a65018640176401664014640126400e6400a600076000000000000000000000000000000000000000000000000000000000
0001000015050110500d0500605002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000d05013050180501a0501305022000290002b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002745000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003345033450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000025600286002a6002a1102e120301301a1401d150221502415000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000180401804000000180401a040000001b040000001c0401c040000001c0401d040000001e040000001f040000002104000000220402204022040220402204022040220402204000000000000000000000
010c00001813018130181301813018130181301813018135181301813018130181301813018130181301813518130181300000000000181301813018130181301813018130181301813018130181301813018130
010c00000c2100c2100c2100c2100c2100c2100c2100c2150c2100c2100c2100c2100c2100c2100c2100c2150c2100c21000000000000c2100c2100c2100c2100c2100c2100c2100c21000000000000000000000
010c0000240402404024040240452404024040240402404524040000002604000000240400000021040000001d0401d0401d0401d0401a0401a0401a0401a0401d0401d0401d0401d04000000000000000000000
010c00001113000000181301d1302113000000181301d1302113000000181301d1302113000000181301d13022130000001a1301d13022130000001a1301d13022130000001a1301d13022130000001a1301d130
010c0000112101121011210112100c2100c2100c2100c210112101121011210112100c2100c2100c2100c21016210162101621016210112101121011210112101621016210162101621011210112101121011215
010c0000240402404024040240452404024040240402404524040000002604000000240400000021040000001f0401f0401f0401f0401f0401f0401f0401f0401f0401f0401f0401f04000000000000000000000
010c00002113000000181301d1302113000000181301d1302113000000181301d1302113000000181301d1301f130000001a1301c1301f130000001a1301c1301f130000001a1301c1301f13000000181301c130
000c0000112101121011210112100c2100c2100c2100c210112101121011210112100c2100c2100c2100c210132101321013210132100c2100c2100c2100c21010210102100c2100c2100e2100e2101021010210
010c00002113000000181301d1302113000000181301d1302113000000181301d1302113000000181301d13022130000001a1301d13022130000001a1301d13022130000001a1301d13022130000001a1301d130
010c000021040210402104021045210402104021040210401f0401f04021040000001f040000001a040000001d0401d0401d0401d0401d0401d0401d0401d0400000000000000000000000000000000000000000
010c00002113000000181301d1302113000000181301d1301f130000001a1301c1301f13000000181301c1302113000000181301d1302113000000181301c1302113000000181301d1302113000000181301c130
010c0000112101121011210112100c2100c2100c2100c210132101321013210132100c2100c2100c2100c210112101121011210112100c2100c2100c2100c21011210112100c2100c2100e2100e2101021010210
010c000021040210402104021045210402104021040210401f0401f04021040000001f040000001a040000001d0401d0401d0401d0401d0401d0401d0401d040000001f040210400000024040000002604000000
010c00002904029040290402904029040290402904029045290402904029040290402904029040290402904529040290400000000000260402604026040260402604026040260402604000000000000000000000
010c0000112101121011210112100c2100c2100c2100c210112101121011210112100c2100c2100c2100c210112101121011210112100a2100a2100a2100a210112101121011210112100a2100a2100a2100a210
010c000024040240402404024040240402404024040240452404024040240402404024040240402404024040210402104000000000001f0401f0401f0401f0401f0401f0401f0401f04000000000000000000000
010c00002404000000260400000024040000002604000000240400000026040000002404000000260400000029040000002b0400000029040000002b0400000029040000002b0400000029040000002b04000000
010c00002d0402d0402b0400000029040000002604000000240400000021040200401f0401d0401a0401a0401d0401d0401d0401d0401d0401d0401d0401d0400000000000000000000000000000000000000000
010c000021040210402104021045210402104021040210401f0401f0401f0401f0451f0401f0401f0401f04021040210402104021040210402104021040210400000000000000000000021040210400000000000
010c00002113000000181301d1302113000000181301d1301f130000001a1301c1301f13000000181301c1302113000000181301d1302113000000181301c1302113000000181301d1300513000000181301c130
010c0000112101121011210112100c2100c2100c2100c210132101321013210132100c2100c2100c2100c21011210112100c2100c2100e2100e21010210102101121011210112101121005210052100000000000
00130000180501800018050180001d050000001d05000000210502105021050210502105021040210302102000000000000000000000000000000000000000000000000000000000000000000000000000000000
001300001d050000001d0500000021050000002105000000240502405024050240502405024040240302402000000000000000000000000000000000000000000000000000000000000000000000000000000000
001300002105200002210520000224052000022405200002290522905229052290522905229042290322902205000050000000000000000000000000000000000000000000000000000000000000000000000000
000200001c3501b650313503065016650106400b64008630056200261001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003045038450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000a0300a0300d0300d03005030050300d0300d0300a0300a0300d0300d030050300503008030080300a0300a0300d0300d03005030050300d0300d0300a0300a0300d0300d03005035050300903509030
010e00000003000030161300003019130000301d13000030221300003000030000301d13000030000301c1301b130000301e130000301d13000030000301c1301b130000301e130000301d130000300003000030
010e00000000000000112300000000000000001123000000000000000011230000000000000000112300000000000000001123000000000000000011230000000000000000112300000000000000001023000000
010e00000a0300a0300d0300d03005030050300d0300d0300a0300a0300d0300d0300503005030060300603003030030300a0300a03006030060300a0300a03005030050300c0300c03009030090300c0300c030
010e00000000000000161300000019130000001d13000000221300000000000000001e13000000000001c1301b1300000000000000001e1300000000000000001d13000000000000000021130000000000000000
010e00000000000000112300000000000000001123000000000000000011230000000000000000112300000000000000000d2300000000000000000d230000000000000000102300000000000000001023000000
010e00000a0300a0300d0300d03005030050300d0300d0300a0300a0300d0300d030050300503008030080300a0300a0300d0300d03005030050300d0300d0300a0300a0300d0300d03005035050300903509030
010e00000000000000161300000019130000001d13000000221300000000000000001d13000000000001c1301b130000001e130000001d13000000000001c1301b130000001e130000001d130000000000000000
0001000004640076400e6401964022640276402964029630296302a6302a6302a6302b6302c6302c6302d6302d6202e6202f6202f61030610306102d6102a61026610206101a610126100e6100a6100761004610
000100000604007040070400804008040090300a0300b0300b0300c0300d0300e0200f0200f02011020110201202013020150101601017010190101b000186101a6201c6202063024640276402b6503165039660
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
01 07 08 09 44
00 0a 0b 0c 44
00 0d 0e 0f 44
00 0a 10 0c 44
00 11 12 13 44
00 0a 0b 0c 44
00 0d 0e 0f 44
00 0a 10 0c 44
00 14 12 13 44
00 15 0b 16 44
00 17 0e 0f 44
00 18 10 16 44
00 19 12 13 44
00 0a 0b 16 44
00 0d 0e 0f 44
00 0a 10 16 44
02 1a 1b 1c 44
04 1d 1e 1f 44
01 28 29 24 44
02 25 26 27 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
