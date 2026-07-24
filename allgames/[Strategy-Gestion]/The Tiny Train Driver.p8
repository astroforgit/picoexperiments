pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the tiny train driver
-- by frozax

-- for toy box jam 2
-- Follow me on twitter: @frozax
-- More pico-8 games: https://frozax.itch.io
-- My mobile games: https://www.frozax.com

-- https://www.lexaloffle.com/bbs/?tid=37015

vec2mt={
    __add=function(v1,v2)
        return vec2(v1.x+v2.x,v1.y+v2.y)
    end,
    __sub=function(v1,v2)
        return vec2(v1.x-v2.x,v1.y-v2.y)
    end,
    __mul=function(s,v)
        return vec2(s*v.x,s*v.y)
    end,
    __len=function(self)
        return sqrt(self.x*self.x+self.y*self.y)
    end,
    __eq=function(v1,v2)
        return v1.x==v2.x and v1.y==v2.y
    end,
}
vec2mt.__index=vec2mt

function vec2(x,y)
    v = setmetatable({x=x,y=y},vec2mt)
    return v
end


function blink(speed, c0, c1)
    ti = flr(time() * speed)
    if ti % 2 == 0 then
        return c0
    end
    return c1
end

-- code from democart
function draw_rwin(_x,_y,_w,_h,_c1,_c2)
 -- would check screen bounds but may want to scroll window on?
 -- okay draw inside
 rectfill(_x+3,_y+1,_x+_w-3,_y+_h-1,_c1) -- x big middle bit
 line(_x+2,_y+3,_x+2,_y+_h-3,_c1) -- x left edge taller
 line(_x+1,_y+5,_x+1,_y+_h-5,_c1) -- x left edge shorter
 line(_x+_w-2,_y+3,_x+_w-2,_y+_h-3,_c1) -- x right edge taller
 line(_x+_w-1,_y+5,_x+_w-1,_y+_h-5,_c1) -- x right edge shorter
 --now the border left side
 line(_x,_y+5,_x,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+1,_y+3,_x+1,_y+4,_c2) -- x 2 left top
 line(_x+1,_y+_h-4,_x+1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+2,_y+2,_c2)  -- x 1 top dot
 pset(_x+2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+3,_y+1,_x+4,_y+1,_c2)  -- x 2 top curve
 line(_x+3,_y+_h-1,_x+4,_y+_h-1,_c2)  -- x 2 btm curve
 --now the border right side
 line(_x+_w,_y+5,_x+_w,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+_w-1,_y+3,_x+_w-1,_y+4,_c2) -- x 2 left top
 line(_x+_w-1,_y+_h-4,_x+_w-1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+_w-2,_y+2,_c2)  -- x 1 top dot
 pset(_x+_w-2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+_w-3,_y+1,_x+_w-4,_y+1,_c2)  -- x 2 top curve
 line(_x+_w-3,_y+_h-1,_x+_w-4,_y+_h-1,_c2)  -- x 2 btm curve
 -- top and bottom!
 line(_x+5,_y,_x+_w-5,_y,_c2) -- x top
 line(_x+5,_y+_h,_x+_w-5,_y+_h,_c2) -- x bottom
end

function draw_win(_x,_y,_w,_h,_c1,_c2)
 rectfill(_x,_y,_x+_w,_y+_h,_c1)
 rect(_x,_y,_x+_w,_y+_h,_c2)
end

-------------------------------
-- string width with glyphs
function strwidth(str)
 local px=0
 for i=1,#str do
  px+=(ord(str,i)<128 and 4 or 8)
 end
 --remove px after last char
 return px-1
end
-------------------------------
-- get centered on screen width
function center_x(str)
 return 64 - strwidth(str)/2
end

-------------------------------
-- centered and outlined
function printco(_str,_y,_c,_co)
 where=center_x(_str)
 if (where<0) where=0
 printo(_str,where,_y,_c,_co)
end

-------------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end

function array_contains(__l, __item)
    for __litem in all(__l) do
        if __litem == __item then
            return true
        end
    end
    return false

end

function showpct(c)
    pct = flr(stat(1)*100)
    if not c then
        c = 0
    end

    pct = tostr(pct)
    if #pct == 1 then pct = "0"..pct end
    palt(0, false)
    --y = 121
    y = 1
    rectfill(0, y, 4*#pct, 6+y, 1)
    palt(0, true)
    print(pct, 1, y+1, c)
end

buttons = {
  up = 2,
  down = 3,
  left = 0,
  right = 1,
  b1 = 4,
  b2 = 5,
}


-- converts anything to string, even nested tables
-- https://www.lexaloffle.com/bbs/?pid=43636

function tostring(any)
  if (type(any)~="table") return tostr(any)
  local str = "{"
  for k,v in pairs(any) do
    if (str~="{") str=str..","
    str=str..tostring(k).."="..tostring(v)
  end
  return str.."}"
end


anims = {}

anims.twoframe=0 --two frame anims
anims.threeframe=0
anims.fourframe=0
anims.fiveframe=0
anims.sixframe=0
anims.sevenframe=0
anims.eightframe=0
anims.maxdelay=4
anims.framedelay=anims.maxdelay-1

function anims:update()
    -- update state, check input
    self.framedelay-=1
    if (self.framedelay==0) then
        self.twoframe = (self.twoframe+1) % 2 --two frame anims
        self.threeframe = (self.threeframe+1) % 3 --two frame anims
        self.fourframe = (self.fourframe+1) % 4 -- four frame anims
        self.fiveframe = (self.fiveframe+1) % 5 -- five frame anims
        self.sixframe = (self.sixframe+1) % 6 -- six frame anims
        self.sevenframe = (self.sevenframe+1) % 7
        self.eightframe = (self.eightframe+1) % 8
        self.framedelay=self.maxdelay
    end
end

function create_anim(frames, flips_x, flips_y)
    if flips_x == nil then
        flips_x = {}
        for i=1,#frames do add(flips_x, false) end
    end
    if flips_y == nil then
        flips_y = {}
        for i=1,#frames do add(flips_y, false) end
    end
    if type(frames[1]) == "number" then
        -- if frame numbers, convert to rects
        new_frames = {}
        for i=1,#frames do
            x = (frames[i] % 16) * 8
            y = (frames[i] \ 16) * 8
            add(new_frames, {x=x, y=y, w=8, h=8})
        end
        frames = new_frames
    end

    anim = {frames=frames, flips_x=flips_x, flips_y=flips_y}

    function anim:update()
        mod = 1
        if #self.frames == 1 then
            mod = 0
        elseif #self.frames == 2 then
            mod = anims.twoframe
        elseif #self.frames == 3 then
            mod = anims.threeframe
        elseif #self.frames == 4 then
            mod = anims.fourframe
        elseif #self.frames == 5 then
            mod = anims.fiveframe
        elseif #self.frames == 6 then
            mod = anims.sixframe
        elseif #self.frames == 7 then
            mod = anims.sevenframe
        elseif #self.frames == 8 then
            mod = anims.eightframe
        else
            assert(false, "unhandled nb frames")
        end
        self.frame = self.frames[mod + 1]
        self.flip_x = self.flips_x[mod + 1]
        self.flip_y = self.flips_y[mod + 1]
    end

    function anim:draw(p)
        --printh(tostring(self))
        sspr(self.frame.x, self.frame.y, self.frame.w, self.frame.h, p.x, p.y, self.frame.w, self.frame.h, self.flip_x, self.flip_y)
    end

    return anim
end

function array_of_bool_to_array_of_bytes(bools)
    bytes = {}
    assert(#bools % 8 == 0, "must be modulo 8")
    for i=0,(#bools/8)-1 do
        byte = 0
        for b=0,7 do
            if bools[i*8+b+1] then
                byte += (1<<(7-b))
            end
        end
        add(bytes, byte)
    end
    assert (8*#bytes == #bools, "incoherent result"..#bytes.." "..#bools)
    return bytes
end

function array_of_bytes_to_array_of_bools(bytes)
    bools = {}
    for i=0,#bytes-1 do
        for b=7,0,-1 do
            if bytes[i+1] & (1<<b) == (1<<b) then
                add(bools, true)
            else
                add(bools, false)
            end
        end
    end
    assert (8*#bytes == #bools, "incoherent result"..#bytes.." "..#bools)
    return bools
end

-- test
-- printh(tostring(array_of_bool_to_array_of_bytes({
--     true,false,false,true,true,true,true,true,
--     false,false,false,false,false,true,true,false})))
-- printh(tostring(array_of_bytes_to_array_of_bools({159,6})))



----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|ÄÄÅÇÉÑÖÜáàâäãéåçéèêëíìîïñóòô~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end

-------------------------------
-- sprite print centered on x
function sprintc(_str,_y,_c,_c2,_c3)
 local i, num
 _x=63-(flr(#_str*8)/2)
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+64+32
  spr(num,_x+(i-1)*8,_y*8)
 end
 pal(7,7)
 pal(6,6)
 pal(5,5)
end


train = {}

-- design: le joueur rentre dans la loco qu'il veut.
-- il appuye sur le bouton pour avancer
-- position du train est d√©fini par la case de la loco principale et le
-- decalage (en 1D)
-- la direction depend de la loco active (state)

function train:init()
    train.city=""
    train.state = "stop"    -- stop, drive_start, drive_end
    self.wagons=1
    --self.pos=first_city
    --self.pos.x+=2
    -- much easier: pos is the pix pos from start
    -- pp for pixxel pos
    self.pp = 8*7
    self.speed=0
    -- shift from cell center
    self.incell = 0
end

function train:update()
    self.speed *= 0.9
    if abs(self.speed) <= 0.01 then
        self.speed = 0
        sfx_train_stop()
    else
        -- advance!
        self.pp += self.speed
        self.pp=max(self.pp,(self.wagons+2)*8)
        if self.pp > self.max_pp then self.pp = self.max_pp end
    end

    c = world:get_rail_start_cell()
    pp = self.pp
    while(true) do
        if pp >= 8 then
            pp -= 8
            if c.next_rail == nil then
                break
            end
            c = c.next_rail
        else
            break
        end
    end
    self.start_loco_cell = c
    self.inner_pp = pp

    if c.city != nil then
        cur_city = c.city.name
        if cur_city != self.city then
            if self.city != "" then
                -- yay! travel!
                c.city:spawn_coins()
            end
            self.city = cur_city
        end
    end

    c = self:get_start_loco_cell()
    addx,addy = self:compute_addxy(c)
    self.start_loco_pos = vec2(c.x*8+addx,c.y*8+addy)
    c = self:get_end_loco_cell()
    addx,addy = self:compute_addxy(c)
    self.end_loco_pos = vec2(c.x*8+addx,c.y*8+addy)

    if self:is_player_in_loco() then
        p = self.start_loco_pos
        if self.state == "drive_end" then p=self.end_loco_pos end
        player.p = vec2(p.x+player.hsize, p.y+player.hsize)
    end
end

function train:compute_addxy(_cell)
    addx,addy=0,0
    if _cell.next_rail == _cell:top() then addy-=self.inner_pp
    elseif _cell.next_rail == _cell:bottom() then addy+=self.inner_pp
    elseif _cell.next_rail == _cell:left() then addx-=self.inner_pp
    elseif _cell.next_rail == _cell:right() then addx+=self.inner_pp end
    return addx,addy
end

function train:draw()
    cell = self:get_start_loco_cell()
    for i=1,self.wagons+2 do
        --printh(tostring(self.pos))
        flipx,flipy=false,false
        if cell:left():is_rail() or cell:right():is_rail() then
            if i ==1 or i == self.wagons + 2 then
                if i != 1 then flipx=true end
                if cell.next_rail != cell:right() or cell:left().next_rail != cell then
                    flipx = not flipx
                end
                s = spr_loco_h
            else
                s = spr_wagon_h
            end
        else
            flipx=true
            if i ==1 or i == self.wagons + 2 then
                if i==1 then flipy=true end
                if cell.next_rail != cell:bottom() or cell:top().next_rail != cell then
                    flipy = not flipy
                end
                s = spr_loco_v
            else
                s = spr_wagon_v
            end
        end
        addx,addy=self:compute_addxy(cell)
        spr(s, cell.x*8-world.origin.x+addx, cell.y*8-world.origin.y+addy,1,1,flipx,flipy)
        --printh(cell.prev_rail)
        if not cell.prev_rail then
            break
        end
        cell = cell.prev_rail
    end
end

function train:get_start_loco_cell()
    return self.start_loco_cell
end

function train:get_end_loco_cell()
    c = self:get_start_loco_cell()
    for i=1,2+self.wagons-1 do
        c = c.prev_rail
    end
    return c
end

loco_enter_dist=7
function train:can_enter_loco(pos)
    if self:is_player_in_loco() then
        return false
    end
    local pos = pos - vec2(player.hsize, player.hsize)
    -- can't compute large numbers, so ignore them beforehand
    if abs(pos.x-self.start_loco_pos.x) > 100 then
        return false
    end
    if abs(pos.y-self.start_loco_pos.y) > 100 then
        return false
    end
    start_d = #(pos-self.start_loco_pos)
    end_d = #(pos-self.end_loco_pos)
    if start_d < loco_enter_dist or
        end_d < loco_enter_dist then
        return true
    end
    return false
end

function train:can_leave_loco(cell)
    return self:is_player_in_loco()
end

function train:leave_loco()
    self.state = "stop"
end

function train:enter_loco(pos)
    local pos = pos - vec2(player.hsize, player.hsize)
    if #(pos-self.start_loco_pos) < loco_enter_dist then
        self.state = "drive_start"
    elseif #(pos-self.end_loco_pos) < loco_enter_dist then
        self.state = "drive_end"
    end
end

function train:advance()
    if self.speed == 0 then
        sfx_train_advance()
    end
    if self.state == "drive_start" then
        self.speed += 1
    else
        self.speed -= 1
    end
end

function train:is_player_in_loco()
    return self.state != "stop"
end


cur_city = 0
city_w, city_h=4,4
city_names = {"paris", "tokyo", "dallas", "london", "berlin", "roma"}--, "madrid", "sydney"}
city_rewards = {50, 60, 100, 150, 200, 250, 250}--, "madrid", "sydney"}
first_city = vec2(3, 7)
cities_pos = {{first_city.x, first_city.y}, {14, 16}, {31, 24}, {50, 9}, {80, 18}, {110,22}}


function create_city(position)
    city = {}
    city.x = position.x
    city.y = position.y
    city.name=city_names[cur_city + 1]
    city.reward=city_rewards[cur_city+1]
    city.flip1 = rnd({true,false})
    city.flip2 = rnd({true,false})
    city.gare_x = rnd({0, 1, 2})
    cur_city = (cur_city + 1) % #city_names

    function city:draw()

        x = self.x*8 - world.origin.x
        y = self.y*8 - world.origin.y

        spr(spr_clock, x+self.gare_x*8+4, y-16)

        -- name
        rectfill(x+3, y-15-8, x + 31-4, y - 9-8, 1)
        print(self.name, x + 16 - #self.name*4/2, y - 14-8, 7)
    end

    function city:gen_item(local_coords)
        x = local_coords.x + self.x
        y = local_coords.y + self.y
        if local_coords.y == -1 then
            if local_coords.x < self.gare_x or local_coords.x > self.gare_x + 1 then
                return create_item({type="house", city=self, x=x,y=y})
            else
                return create_item({type="gare_col", city=self, x=x,y=y})
            end
        elseif local_coords.y == -2 then
            if local_coords.x == self.gare_x then
                return create_item({type="gare_left", city=self, x=x,y=y})
            elseif local_coords.x == self.gare_x+1 then
                return create_item({type="gare_right", city=self, x=x,y=y})
            end
        elseif local_coords.y == 0 then
            return create_item({type="rail", city=self, x=x,y=y})
        end
        return create_item({x=x,y=y,city=self})
    end

    function city:spawn_coins()
        sfx_spawn_coins()
        for x=self.x,self.x+3 do
            i = world.items[x][self.y-2]
            if i.type == nil or i.type == "" then
                world.items[x][self.y-2] = create_item({x=x,y=self.y-2,type="coins",amount=self.reward\2})
            end
        end
    end

    return city
end


spr_tree = 32
spr_stone = 63
spr_coins = 192
spr_coins2 = 193
spr_stone_dmg = 204
spr_rail_h = 37
spr_rail_v = 36
spr_entrepot = 196
spr_hammer = 28
spr_rail_corner = 39
spr_clock = 197
spr_house = 22
spr_column = 55
spr_gare_left = 119
spr_gare_right = 121
spr_loco_h = 40
spr_loco_v = 41
spr_wagon_h = 42
spr_wagon_v = 43
spr_limit = 88

function create_item(infos)
    item = infos

    if item.type != nil then
        item.dmg = 0
        function item:damage()
            self.dmg += 2
            if self.dmg >= 100 then
                self.dmg = 100
                -- remove from world
                world.items[self.x][self.y] = create_item({x=self.x, y=self.y})
            end
        end
        function item:get_damage_state()
            return self.dmg \ 20
        end
    end

    function item:is_collidable()
        return self.type == "stone" or self.type == "tree" or
            self.type == "citypart" or self.type == "house" or
            self.type == "gare_left" or self.type == "gare_right" or self.type == "gare_col" or
            self.type == "entrepot" or self.limit
    end

    function item:is_breakable()
        return self.type == "stone" or self.type == "tree"
    end

    function item:draw(debug)
        --, xc * 8 - self.origin.x, yc * 8 - self.origin.y)
        dx = self.x * 8 - world.origin.x
        dy = self.y * 8 - world.origin.y
        if self.limit and not title_screen then
            palt(0,false)
            spr(spr_limit, dx, dy)
            palt(0,true)
        elseif self.type == "stone" then
            spr(spr_stone, dx, dy)
            palt(6, true)
            dmg = self:get_damage_state()
            if dmg == 0 then
            else
                x = (spr_stone_dmg % 16) * 8
                y = (spr_stone_dmg \ 16) * 8
                w, h = 8, 8
                if dmg == 1 then
                    x+=2
                    y+=2
                    w-=4
                    h-=6
                    dx+=2
                    dy+=2
                elseif dmg == 2 then
                    x+=2
                    y+=2
                    w-=4
                    h-=4
                    dx+=2
                    dy+=2
                elseif dmg == 3 then
                    x+=1
                    y+=1
                    w-=2
                    h-=3
                    dx+=1
                    dy+=1
                elseif dmg == 4 then
                    x+=1
                    y+=1
                    w-=2
                    h-=2
                    dx+=1
                    dy+=1
                end
                sspr(x, y, w, h, dx, dy)
            end
            palt(6, false)
        elseif self.type == "tree" then
            dmg = self:get_damage_state()

            -- v1
            x = (spr_tree % 16) * 8
            y = (spr_tree \ 16) * 8
            sspr(x, y+dmg, 8, 8-dmg, dx, dy+dmg)

            -- v2
            --spr(spr_tree, dx, dy)
            --if dmg != 0 then
            --    if dy % 2 == 0 then
            --        if dmg == 1 then fillp(0b0111110111111101.1) end
            --        if dmg == 2 then fillp(0b0101011011101101.1) end
            --        if dmg == 3 then fillp(0b1010010110100101.1) end
            --        if dmg == 4 then fillp(0b1000010010100101.1) end
            --    else
            --        if dmg == 1 then fillp(0b0111110111111101.1) end
            --        if dmg == 2 then fillp(0b0101011011101101.1) end
            --        if dmg == 3 then fillp(0b1010010110100101.1) end
            --        if dmg == 4 then fillp(0b1000010010100101.1) end
            --    rectfill(dx, dy, dx+7, dy+7, 0, 0)
            --    fillp()
            --end
        elseif self.type == "rail" then
            flipx, flipy=false
            s = spr_rail_h
            if self:top():is_rail() then
                if self:left():is_rail() then
                    s = spr_rail_corner
                    flipx, flipy = true, true
                elseif self:right():is_rail() then
                    s = spr_rail_corner
                    flipx, flipy = false, true
                else
                    s = spr_rail_v
                end
            elseif self:bottom():is_rail() then
                if self:left():is_rail() then
                    s = spr_rail_corner
                    flipx, flipy = true, false
                elseif self:right():is_rail() then
                    s = spr_rail_corner
                    flipx, flipy = false, false
                else
                    s = spr_rail_v
                end
            else
                s = spr_rail_h
            end
            spr(s, dx, dy, 1, 1, flipx, flipy)
        elseif self.type == "entrepot_hammer" then
            spr(spr_hammer, dx, dy)
        elseif self.type == "entrepot" then
            spr(spr_rail_v, dx, dy)
            spr(spr_entrepot, dx, dy)
        elseif self.type == "house" then
            spr(spr_house, dx, dy)
        elseif self.type == "gare_col" then
            spr(spr_column, dx, dy)
        elseif self.type == "gare_left" then
            spr(spr_gare_left, dx, dy)
        elseif self.type == "gare_right" then
            spr(spr_gare_right, dx, dy)
        elseif self.type == "coins" then
            s = flr(time()*8) % 2 + spr_coins
            flipx = flr(time()*8)%4 < 2
            spr(s, dx, dy, 1, 1, flipx)
        end
        if debug then
            spr(196, dx, dy)
            print(self.x..self.y, dx+1, dy+2, 1)
        end
    end

    function item:valid(x,y)
        return x >= 0 and y >= 0 and x < world.w and y < world.h
    end

    function item:right()
        if self:valid(self.x+1, self.y) then
            return world.items[self.x+1][self.y]
        else
            return create_item({x=self.x+1,y=self.y})
        end
    end

    function item:left()
        if self:valid(self.x-1,self.y) then
            return world.items[self.x-1][self.y]
        else
            return create_item({x=self.x-1,y=self.y})
        end
    end

    function item:top()
        if self:valid(self.x, self.y-1) then
            return world.items[self.x][self.y-1]
        else
            return create_item({x=self.x,y=self.y-1})
        end
    end

    function item:bottom()
        if self:valid(self.x, self.y+1) then
            return world.items[self.x][self.y+1]
        else
            return create_item({x=self.x,y=self.y+1})
        end
    end

    -- or_entrepot mens wealso returns trop for entrpot
    function item:is_rail(or_entrepot)
        return self.type == "rail" or (self.type == "entrepot" and or_entrepot)
    end
    
    function item:nb_rails_nb()
        _nb = 0
        if self:left():is_rail(true) then _nb+=1 end
        if self:right():is_rail(true) then _nb+=1 end
        if self:bottom():is_rail(true) then _nb+=1 end
        if self:top():is_rail(true) then _nb+=1 end
        return _nb
    end

    -- returns true/false,true/false
    -- 1st one is true if we are on a proper cell to build
    -- 2nd one is true if we have enough resources
    function item:can_build_rail()
        if not self:is_rail() and not self:is_collidable() then
            -- rail is possible if after placing it, nobody will have 3 nb with rails
            il = self:left():is_rail()
            it = self:top():is_rail()
            ib = self:bottom():is_rail()
            ir = self:right():is_rail()
            l = self:left():nb_rails_nb()
            t = self:top():nb_rails_nb()
            b = self:bottom():nb_rails_nb()
            r = self:right():nb_rails_nb()
            --printh("l"..l.."r"..r.."t"..t.."b"..b)
            --printh("il"..tostr(il).."ir"..tostr(ir).."it"..tostr(it).."ib"..tostr(ib))
            --printh("l"..tostr(l).."r"..tostr(r).."t"..tostr(t).."b"..tostr(b))
            --" il"..il.." ir"..ir.." it"..tostr(it).." ib"..tostr(ib))
            if (l < 2 and t < 2 and b < 2 and r < 2) and
            (ir or il or it or ib) then
                return true, ui.stone >= rail_cost_stone and ui.tree >= rail_cost_tree
            end
        end
        return false, false
    end

    function item:set_rail()
        self.type = "rail"
    end

    return item
end

-- after world_item for sprites
ui = {}
ui.tree = 0
ui.stone = 0
ui.coins = 0

obj_count = 15
coins_count=100
o1={icon=spr_tree,t1="gather "..obj_count,t2="trees"}
o2={icon=spr_stone,t1="gather "..obj_count,t2="stones"}
o3={icon=spr_rail_h,t1="connect paris",t2="to tokyo"}
o4={icon=spr_loco_h,t1="drive the",t2="train to tokyo"}
o5={icon=spr_coins,t1="earn "..coins_count.. " coins",t2="(back to paris)"}
o6={icon=spr_coins,t1="unlock a new",t2="area"}
function o1:completed()
    return ui.tree >= obj_count
end
function o2:completed()
    return ui.stone >= obj_count
end
function o3:completed()
    return array_contains(world.connected_cities, "tokyo")
end
function o4:completed()
    return train.city == "tokyo"
end
function o5:completed()
    return ui.coins >= coins_count
end
function o6:completed()
    return world.areas_unlocked > 1
end
ui.objectives = {o1, o2, o3, o4, o5, o6}

rail_cost_stone = 2
rail_cost_tree = 3

function getspr(spr)
    __x = (spr % 16) * 8
    __y = (spr \ 16) * 8
    return __x, __y
end

function ui:update()
    self.objective = nil
    for i=1,#self.objectives do
        if not self.objectives[i].done then
            if self.objectives[i].completed() then
                self.objectives[i].done = true
            else
                self.objective = self.objectives[i]
                break
            end
        end
    end
end

ui_col1 = 13
ui_col2 = 1
ui_text_col=7
ui_text_col2=13

function draw_small_icon(__icon, __dx, __dy)
    _x, _y = getspr(__icon)
    sspr(_x, _y, 8, 8, __dx, __dy, scale, scale)
end

function ui:draw()
    -- inventory
    scale = 5
    draw_win(-1, -1, 58, 8, ui_col1, ui_col2)

    dx = 1
    dy = 1
    draw_small_icon(spr_tree, dx, dy)
    print(self.tree, dx + scale + 1, dy, ui_text_col)

    dx += scale + 2 + 3*4
    draw_small_icon(spr_stone, dx, dy)
    print(self.stone, dx + scale + 1, dy, ui_text_col)

    dx += scale + 2 + 3*4
    draw_small_icon(spr_coins, dx, dy)
    print(self.coins, dx + scale + 1, dy, ui_text_col)

    -- objective
    if self.objective then
        xo = 60
        ho = 14
        if #self.objective.t2 == 0 then
            ho = 8
        end
        draw_win(xo, -1, 128-xo, ho, ui_col1, ui_col2)
        draw_small_icon(self.objective.icon, xo+2, 1)
        print(self.objective.t1, xo+2+6, 1, ui_text_col)
        print(self.objective.t2, xo+2, 7, ui_text_col)
    end

    cba, has_coins = world:can_buy_area(player.below_item)
    cbr, has_rsc = player.below_item:can_build_rail()
    cel = train:can_enter_loco(player.p)
    cll = train:can_leave_loco(player.below_item)
    if cba then
        self:draw_buy_area(has_coins)
    elseif cbr then
        self:draw_build_rail(has_rsc)
    elseif cel then
        self:draw_enter_loco()
    elseif cll then
        self:draw_use_loco()
    end
end

enough_col = ui_text_col
not_enough_col = 8
function ui:draw_build_rail(has_rsc)
    y = 7
    draw_win(-1, y, 36, 14, ui_col1, ui_col2)
    print("\x8ebuild", 1, y+2, ui_text_col)
    draw_small_icon(spr_rail_h, 1, y+8)
    draw_small_icon(spr_rail_h, 5, y+8)
    print(":", 10, y+8)
    x=14
    draw_small_icon(spr_tree, x, y+8)
    if rail_cost_tree <= self.tree then c = enough_col else c = not_enough_col end
    print(rail_cost_tree, x+6, y+8, c)
    x+=11
    draw_small_icon(spr_stone, x, y+8)
    if rail_cost_stone <= self.stone then c = enough_col else c = not_enough_col end
    print(rail_cost_stone, x+6, y+8, c)
end

function ui:draw_buy_area(has_coins)
    y = 7
    draw_win(-1, y, 41, 14, ui_col1, ui_col2)
    print("\x8ebuy area", 1, y+2, ui_text_col)
    x=1
    draw_small_icon(spr_coins, x, y+8)
    if world:next_area_cost() <= self.coins then c = enough_col else c = not_enough_col end
    print(world:next_area_cost(), x+6, y+8, c)
end

function ui:draw_enter_loco()
    y = 7
    draw_win(-1, y, 30, 14, ui_col1, ui_col2)
    print("\x8eenter", 1, y+2, ui_text_col)
    draw_small_icon(spr_loco_h, 21, y+8)
    print("train", 1, y+8)
end

function ui:draw_use_loco()
    y = 7
    draw_win(-1, y, 42, 14, ui_col1, ui_col2)
    print("\x8espeed up", 1, y+2, ui_text_col)
    print("\x97leave", 1, y+8, ui_text_col)
    --draw_small_icon(spr_loco_h, 21, y+8)
end

function ui:add_resource(type, count)
    if type == "tree" then self.tree += count
    elseif type == "stone" then self.stone += count
    elseif type == "coins" then self.coins += count
    --else
    --    assert(false, "unknown resource "..type)
    end
end

function ui:spend_resource(type, count)
    if type == "tree" then self.tree -= count
    elseif type == "stone" then self.stone -= count
    elseif type == "coins" then self.coins -= count
    --else
    --    assert(false, "unknown resource "..type)
    end
end

function ui:draw_title()

    c1=nil
    c2=nil
    c3=8
    y=4
    draw_rwin(32, 40-30, 128-64-4, 4*8+26, 1, 7)
    palt(5,true) -- remove backgnd
    palt(6,true) -- remove lines
    palt(0,false) -- shadow draws
    pal(0,13)
    sprintc("the", y, c1, c2, c3)
    sprintc("tiny", y+1, c1, c2, c3)
    sprintc("train", y+2, c1, c2, c3)
    sprintc("driver", y+3, c1, c2, c3)
    palt(5,false)
    palt(6,false)
    pal(0,0)
    palt(0,true)

    --draw_rwin(32, 80, 128-64-4, 4*8+28, 1, 7)
    y = 104
    print("toyboxjam 2020", 64-7*4+2, y+6, 7)
    print("@frozax", 64-4*4+4, y+12, 7)

    if flr(time()*4) % 10 < 7 then
        sx, sy = 112,112
    else
        sx, sy = 40,120
    end
    sspr(sx, sy, 8, 8, 32+16+8-1, 14, 16, 16)

    if flr(time()*8) % 4 > 0 then
        printco("press \x8e to start", 80, ui_col2, ui_text_col)
    end
end

world = {}

-- always same city for now
srand(14)

-- sprites stuff
spr_grass = {10, 11, 12}
spr_scenery = {194, 195, 220, 10, 11, 12}

-- colors stuff
bg_green = 1 -- slot where we put the new green
old_green = 3
hidden_pal_green = 128+11 -- 128+10,128+11

-- we replace the green, change it for the sprites with a new one
pal(new_green, old_green, 1)
pal(old_green, hidden_pal_green, 1)

-- gen world
world.area_size = 30
world.nb_area_w = 4
world.nb_area_h = 1
world.areas_unlocked = 1
world.w = world.area_size * world.nb_area_w
world.h = world.area_size * world.nb_area_h
world.origin = vec2(0, 0) -- origin for draw
world.min_origin = vec2(0, 0)
world.max_origin = vec2(world.w * 8 - 128, world.h * 8 - 128)
world.border = 40

function world:init()
    -- items on specific cells with collisions
    world.items = {}        
    for x=0,world.w-1 do
        col = {}
        for y=0,world.h-1 do
            r = flr(rnd(100))
            col[y]=create_item({x=x,y=y})
        end
        world.items[x]=col
    end

    -- create quarry and forests
    nbs = 16
    for i=1,nbs*2 do
        if i % 2 == 0 then t = "tree" else t = "stone" end
        rshape = (i \ 2) % nbs
        if rshape == 0 then
            shape = {{1, 1, 1},{1,1,1}}
        elseif rshape == 1 then
            shape = {{1, 0, 1, 1},{1, 1, 1, 0}, {0, 1, 1, 0}}
        elseif rshape == 2 then
            shape = {{0, 1, 1, 1, 0}, {1, 1, 1, 1, 0}, {1, 1, 1, 1, 1}, {0, 1, 1, 1, 1}, {1, 1, 1, 0, 0}}
        elseif rshape == 3 then
            shape = {{0, 1, 1}, {1, 1, 1}, {0, 1, 1}}
        elseif rshape == 4 then
            shape = {{0, 1, 1, 0}, {0, 1, 1, 1}, {1, 1, 1, 1}, {1, 1, 0, 0}}
        end
        xw = flr(rnd(world.w))
        yw = flr(rnd(world.h))
        for y=1,#shape do
            for x=1,#shape[y] do
                ix = x+xw-1
                iy = y+yw-1
                if ix >= 0 and ix < world.w and iy >= 0 and iy < world.h and
                    shape[y][x] == 1 then
                    world.items[ix][iy] = create_item({type=t,x=ix,y=iy})
                end
            end
        end
    end

    -- scenery, can be placed anywhere, no collision
    world.scenery = {}
    for s=1,(world.w*world.h)/10 do
        add(world.scenery, {spr=rnd(spr_scenery), x=rnd(world.w*8), y=rnd(world.h*8)})
    end

    world.cities = {}
    fc = cities_pos[1]
    for c=1,6 do
        city = create_city({x=cities_pos[c][1], y=cities_pos[c][2]})
        add(world.cities, city)
        for x=0,city_w-1 do
            for y=0,-(city_h-1),-1 do
                item = city:gen_item(vec2(x,y))
                world.items[item.x][item.y] = item
            end
        end
    end

    -- place rails
    world.items[fc[1]-1][fc[2]]:set_rail()
    world.items[fc[1]-2][fc[2]]:set_rail()
    world.items[fc[1]-2][fc[2]-1]:set_rail()
    world.items[fc[1]-2][fc[2]-2]:set_rail()
    world.items[fc[1]-2][fc[2]-3]:set_rail()
    world.items[fc[1]-2][fc[2]-3].type = "entrepot"
    self.rail_start=vec2(fc[1]-2, fc[2]-3)
    --world.items[fc[1]-2][fc[2]-4].type = "entrepot_hammer"
    world:refresh_connections()
end

function world:update()
    if title_screen then
        -- animated origin
        self.origin.x = sin(time()/60) * self.w*8*0.95/2 + self.w*8/2
        self.origin.y = sin(time()/18.3) * self.h*8*0.3/2 + self.h*8/2-64
    else
        -- if player is outside center square, shift the origin
        pp = player.p - vec2(player.hsize, player.hsize)
        cur_pos = pp - self.origin 
        if cur_pos.x < self.border then
            self.origin.x = pp.x - self.border
        end
        if cur_pos.x > 128 - self.border then
            self.origin.x = pp.x - (128 - self.border)
        end
        if cur_pos.y < self.border then
            self.origin.y = pp.y - self.border
        end
        if cur_pos.y > 128 - self.border then
            self.origin.y = pp.y - (128 - self.border)
        end
    end

    if self.origin.x < self.min_origin.x then self.origin.x = self.min_origin.x end
    if self.origin.x > self.max_origin.x then self.origin.x = self.max_origin.x end
    if self.origin.y < self.min_origin.y then self.origin.y = self.min_origin.y end
    if self.origin.y > self.max_origin.y then self.origin.y = self.max_origin.y end
    self.origin.x = flr(self.origin.x)
    self.origin.y = flr(self.origin.y)

    -- refresh area limit
    area_x_limit = self.areas_unlocked * self.area_size
    for x=0,self.w-1 do
        for y=0,self.h-1 do
            self.items[x][y].limit = x == area_x_limit
        end
    end
end

function world:draw()
    --pal()

    cls(new_green)

    start_x = flr(self.origin.x/8)
    start_y = flr(self.origin.y/8)

    self:draw_scenery()
    self:draw_items()
    self:draw_cities()
    --draw_test()
end

function world:debug()
    color(1)
    for i=0,world.w-1 do
        line(-self.origin.x + i*8, 0, -self.origin.x + i*8, 127)
        line(-self.origin.x + i*8+7, 0, -self.origin.x + i*8+7, 127)
        line(0, -self.origin.y + i*8, 127, -self.origin.y + i*8)
        line(0, -self.origin.y + i*8+7, 127, -self.origin.y + i*8+7)
    end

end

function world:draw_scenery()
    for scenery in all(self.scenery) do
        spr(scenery.spr, scenery.x-self.origin.x, scenery.y - self.origin.y)
    end
end

function world:draw_items()
    for xc=start_x,start_x+128/8 do
        if xc < self.w then
            for yc=start_y,start_y+128/8 do
                if yc < self.h then
                    item = self.items[xc][yc]
                    item:draw()
                end
            end
        end
    end
end

function world:draw_cities()
    for city in all(self.cities)do
        city:draw()
    end
end

function world:get_rail_start_cell()
    return self.items[self.rail_start.x][self.rail_start.y]
end

function world:refresh_connections()
    self.connected_cities = {}
    c = self:get_rail_start_cell()
    nbcells = 0
    last_c = {}
    while(true) do
        if c:top():is_rail() and c:top() != last_c then
            last_c = c
            c = c:top()
        elseif c:bottom():is_rail() and c:bottom() != last_c then
            last_c = c
            c = c:bottom()
        elseif c:left():is_rail() and c:left() != last_c then
            last_c = c
            c = c:left()
        elseif c:right():is_rail() and c:right() != last_c then
            last_c = c
            c = c:right()
        else
            break
        end
        -- write linked list
        c.prev_rail = last_c
        last_c.next_rail = c
        nbcells += 1
        if c.city then
            -- add if not inside
            if not array_contains(self.connected_cities, c.city.name) then
                add(self.connected_cities, c.city.name)
            end
        end
    end
    train.max_pp = 8*nbcells
end

function world:next_area_cost()
    costs = {100, 250, 500, 1000, 2000, 5000, 5000}
    return costs[self.areas_unlocked]
end

-- returns two bools:
-- 1st returns true if proper cell
-- 2nd return true if enough moneu
function world:can_buy_area(cur_cell)
    if cur_cell:right().limit then
        return true, ui.coins >= self:next_area_cost()
    else
        return false, false
    end
end

function world:buy_area()
    self.areas_unlocked+=1
end

player = {}

player.p = vec2(74, 64) -- p is center of perso
player.speed = 2.0    -- pix / frame
player.hsize = 4
player.minp = vec2(player.hsize, player.hsize)
player.maxp = vec2(world.w * 8 - player.hsize, world.h * 8 - player.hsize)
player.idle_down = create_anim({238, 238, 238, 239})
player.idle_up = create_anim({253, 253, 253, 254})
player.idle_left = create_anim({246, 246, 246, 247}, {true, true, true, true})
player.idle_right = create_anim({246, 246, 246, 247})
player.walk_down = create_anim({240, 238, 240, 238}, {true, false, false, false})
player.walk_up = create_anim({255, 253, 255, 253}, {true, false, false, false})
player.walk_left = create_anim({248, 249}, {true, true})
player.walk_right = create_anim({248, 249})
player.destroy_down = create_anim({241, 242})
player.destroy_left = create_anim({250, 251}, {true, true})
player.destroy_right = create_anim({250, 251})
player.destroy_up = create_anim({253, 254})
player.destroy = player.destroy_down
player.idle = player.idle_down

function player:update()
    dir = vec2(0, 0)
    if not train:is_player_in_loco() then
        if not title_screen then
            dir = self:check_movement()
        end
        if #dir == 0 then
            self.anim = self.idle
        else
            dir = (self.speed / #dir) * dir
            self.coll_item = nil
            dirx = self:collide(self.p, vec2(dir.x, 0))
            diry = self:collide(self.p, vec2(0, dir.y))
            dir.x = dirx.x
            dir.y = diry.y
            self:move(dir)

            if self.coll_item != nil then
                self.anim = self.destroy
                old_ds = self.coll_item:get_damage_state()
                self.coll_item:damage()
                new_ds = self.coll_item:get_damage_state()
                if old_ds != new_ds then
                    ui:add_resource(self.coll_item.type, 2)
                    if self.coll_item.type == "stone" then sfx_gather_stone() end
                    if self.coll_item.type == "tree" then sfx_gather_tree() end
                end
                save:save()
            end
        end
    end

    -- check if on a buildable cell
    self.below_item = world.items[self.p.x\8][self.p.y\8]

    if btnp(buttons.b1) and not title_screen then
        cbr, has_rsc = self.below_item:can_build_rail()
        cel = train:can_enter_loco(self.p)
        iil = train:is_player_in_loco()
        cba, has_coins = world:can_buy_area(self.below_item)
        if cba and has_coins then
            ui:spend_resource("coins", world:next_area_cost())
            world:buy_area()
        elseif cbr and has_rsc then
            ui:spend_resource("tree", rail_cost_tree)
            ui:spend_resource("stone", rail_cost_stone)
            self.below_item:set_rail()
            sfx_build_rail()
            world:refresh_connections()
        elseif cel then
            train:enter_loco(self.p)
        elseif iil then
            train:advance()
        else
            sfx_error()
        end
        save:save()
    end
    if btnp(buttons.b2) then
        cll = train:can_leave_loco()
        if cll then
            train:leave_loco()
            save:save()
        else
            -- show help
            help_on = true
        end
    end
    if self.below_item.type == "coins" then
        sfx_gather_coins()
        ui:add_resource("coins", self.below_item.amount)
        self.below_item.type = ""
        save:save()
    end
end

function player:check_movement()
    dir=vec2(0,0)
    if btn(buttons.left) then
        dir.x = -1
        self.anim = self.walk_left
        self.idle = self.idle_left
        self.destroy = self.destroy_left
    end
    if btn(buttons.right) then
        dir.x = 1
        self.anim = self.walk_right
        self.idle = self.idle_right
        self.destroy = self.destroy_right
    end
    if btn(buttons.up) then
        dir.y = -1
        self.anim = self.walk_up
        self.idle = self.idle_up
        self.destroy = self.destroy_up
    end
    if btn(buttons.down) then
        dir.y = 1
        self.anim = self.walk_down
        self.idle = self.idle_down
        self.destroy = self.destroy_down
    end
    return dir
end

function player:move(dir)
    self.p = self.p + dir

    -- check borders
    if self.p.x < self.minp.x then self.p.x = self.minp.x end
    if self.p.x > self.maxp.x then self.p.x = self.maxp.x end
    if self.p.y < self.minp.y then self.p.y = self.minp.y end
    if self.p.y > self.maxp.y then self.p.y = self.maxp.y end
end

function player:get_bounds_cells(p)
    minx = flr(p.x - self.hsize)\8
    miny = flr(p.y - self.hsize)\8
    maxx = flr(p.x + self.hsize-1)\8
    maxy = flr(p.y + self.hsize-1)\8
    return minx, miny, maxx, maxy
end

function player:get_bounds(p)
    minx = flr(p.x - self.hsize)
    miny = flr(p.y - self.hsize)
    maxx = flr(p.x + self.hsize-1)
    maxy = flr(p.y + self.hsize-1)
    return minx, miny, maxx, maxy
end

function player:get_items_to_check(p, dir)
    minx, miny, maxx, maxy = self:get_bounds_cells(p)
    items = {}
    if dir.x != 0 then
        if dir.x < 0 then xidx = minx else xidx = maxx end
        if xidx >= 0 and xidx < world.w then
            add(items, world.items[xidx][miny])
            if miny != maxy then
                add(items, world.items[xidx][maxy])
                if self.p.y\8 == items[2].y then
                    -- swap to do it in order
                    tmp = items[2]
                    items[2] = items[1]
                    items[1] = tmp
                end
            end
        end
    end
    if dir.y != 0 then
        if dir.y < 0 then yidx = miny else yidx = maxy end
        if yidx >= 0 and yidx < world.h then
            add(items, world.items[minx][yidx])
            if minx != maxx then
                add(items, world.items[maxx][yidx])
                if self.p.x\8 == items[2].x then
                    -- swap to do it in order
                    tmp = items[2]
                    items[2] = items[1]
                    items[1] = tmp
                end
            end
        end
    end
    return items
end

-- returns a new dir that prevents collision
function player:collide(old, dir)
    -- check if any of the four corner is in an item
    new = old + dir
    items = self:get_items_to_check(new, dir)
    minx, miny, maxx, maxy = self:get_bounds(new)
    for item in all(items)do
        if item:is_collidable() then
            if item:is_breakable() then
                if self.coll_item == nil then
                    self.coll_item = item
                end
            end
            if dir.x > 0 and maxx >= item.x*8 then
                maxnewx = (item.x * 8 - self.hsize)
                dir.x = max(maxnewx - old.x, 0)
                new = old + dir
            elseif dir.x < 0 and minx <= (item.x+1)*8 then
                minnewx = (item.x + 1) * 8 + self.hsize
                dir.x = min(minnewx - old.x, 0)
                new = old + dir
            end
            if dir.y > 0 and maxy >= item.y*8 then
                maxnewy = (item.y * 8 - self.hsize)
                dir.y = max(maxnewy - old.y, 0)
                new = old + dir
            elseif dir.y < 0 and miny <= (item.y+1)*8 then
                minnewy = (item.y + 1) * 8 + self.hsize
                dir.y = min(minnewy - old.y, 0)
                new = old + dir
            end
        end
    end
    return dir
end

function player:draw()
    --for item in all(self:get_items_to_check(self.p, vec2(-1,-1))) do
    --    world:draw_item({type="debug",x=item.x, y=item.y})
    --end
    --self.below_item:draw(true)

    -- DEBUG
    --self.anim = create_anim({218})
    self.anim:update()
    --pal(2, 12)
    --pal(14, 1)
    if not train:is_player_in_loco() then
        self.anim:draw(self.p - world.origin - vec2(self.hsize, self.hsize))
    end
    --print(tostring(self.p), 1, 10, 7)
    --print(flr((self.p.x-self.hsize)/8).." "..flr((self.p.y-self.hsize)/8), 1, 20, 7)
    --if self.coll_item != nil then
    --    item = create_item({type="debug",x=self.coll_item.x, y=self.coll_item.y})
    --    item:draw()
    --end

    --minx, miny, maxx, maxy = self:get_bounds(self.p)
    --rect(minx, miny, maxx, maxy, 7)
    --printh(minx..miny..maxx..maxy)
end

function sfx_error()
    sfx(36)
end

function sfx_build_rail()
    sfx(45)
end

function sfx_gather_stone()
    sfx(22)
end

function sfx_gather_tree()
    sfx(7)
end

function sfx_spawn_coins()
    sfx_gather_coins()
end

function sfx_gather_coins()
    sfx(33)
end

function sfx_train_advance()
    sfx(40)
end

function sfx_train_stop()
    sfx(40, -2)
end

function sfx_menu_valid()
    sfx(37)
end

-- to save:
-- coins, tree, stone
-- player and train pos
-- rails placed, stone/tree removed

-- coords: 
-- 120*30 => 12b

-- x: 0..127: 7b
-- y: 0..31: 5b

save = {}

MAX_ITEMS = 512

function save:init()
    cartdata("frozax_tbj2020")
    self.items = {}
    for x=0,world.w-1 do
        for y=0,world.h-1 do
            it = world.items[x][y].type
            if it == "stone" or it == "tree" then
                add(self.items, {x,y})
            end
        end
    end
    assert (#self.items < MAX_ITEMS, "too many brekable items")
    self:load()
end

-- data is 16b
SAVE_VERSION_CONTROL=0
SAVE_PLAYER_X=2
SAVE_PLAYER_Y=4
-- 16b
SAVE_COINS=6
SAVE_STONES=8
SAVE_TREES=10
SAVE_TRAIN_POS=12
SAVE_AREA_UNLOCKED=14
SAVE_OBJ_DONE=16
-- 512b
SAVE_ITEMS_START=18
-- 
SAVE_RAILS_START=SAVE_ITEMS_START + 512/8
SIZE_PER_RAIL_SAVED = 16 -- 16b
MAX_RAILS_SAVED = (256-SAVE_RAILS_START) * 8 \ SIZE_PER_RAIL_SAVED

DATA_START = 0x5e00
VERSION=8

function save:save()
    poke2(DATA_START+SAVE_VERSION_CONTROL, VERSION)
    poke2(DATA_START+SAVE_PLAYER_X, player.p.x)
    poke2(DATA_START+SAVE_PLAYER_Y, player.p.y)

    poke2(DATA_START+SAVE_COINS, ui.coins)
    poke2(DATA_START+SAVE_STONES, ui.stone)
    poke2(DATA_START+SAVE_TREES, ui.tree)
    poke2(DATA_START+SAVE_TRAIN_POS, train.pp)
    poke2(DATA_START+SAVE_AREA_UNLOCKED, world.areas_unlocked)
    done = 0
    for i=1,#ui.objectives do
        if ui.objectives[i].done then
            done += 1
        end
    end
    poke2(DATA_START+SAVE_OBJ_DONE, done)

    bool_items = {}
    for i = 1, #self.items do
        x,y=self.items[i][1], self.items[i][2]
        it = world.items[x][y].type
        -- true means item removed
        add(bool_items, it != "tree" and it != "stone")
    end
    while #bool_items < 512 do
        add(bool_items, false)
    end
    aob = array_of_bool_to_array_of_bytes(bool_items)
    for b = 1,#aob do
        poke(DATA_START+SAVE_ITEMS_START+b-1, aob[b])
    end

    -- save rails
    ir, failed = 0, 0
    for x=0,world.w-1 do
        for y=0,world.h-1 do
            it = world.items[x][y]
            if it:is_rail() and not it.city then
                if ir < MAX_RAILS_SAVED then
                    poke(DATA_START+SAVE_RAILS_START + ir*2 + 0, x+1)
                    poke(DATA_START+SAVE_RAILS_START + ir*2 + 1, y+1)
                    ir += 1
                else
                    failed += 1
                end
            end
        end
    end
    if (failed > 0) printh("Saved "..ir.."/"..(failed+ir).." rails")
end

function save:load()
    version = peek2(DATA_START+SAVE_VERSION_CONTROL)
    if version == VERSION then
        player.p.x = peek2(DATA_START+SAVE_PLAYER_X)
        player.p.y = peek2(DATA_START+SAVE_PLAYER_Y)

        ui.coins = peek2(DATA_START+SAVE_COINS)
        ui.stone = peek2(DATA_START+SAVE_STONES)
        ui.tree = peek2(DATA_START+SAVE_TREES)

        player.p.x = peek2(DATA_START+SAVE_PLAYER_X)
        player.p.y = peek2(DATA_START+SAVE_PLAYER_Y)
        train.pp = peek2(DATA_START+SAVE_TRAIN_POS)
        world.areas_unlocked = peek2(DATA_START+SAVE_AREA_UNLOCKED)
        done = peek2(DATA_START+SAVE_OBJ_DONE)
        for i=1,#ui.objectives do
            if i <= done then
                ui.objectives[i].done = true
            end
        end

        bytes_items = {}
        for b = 1,(512/8) do
            byte = peek(DATA_START+SAVE_ITEMS_START+b-1)
            add(bytes_items, byte)
        end
        aob = array_of_bytes_to_array_of_bools(bytes_items)
        for i=1,#self.items do
            if aob[i] then
                x,y=self.items[i][1], self.items[i][2]
                world.items[x][y] = create_item({x=x,y=y})
            end
        end

        -- load rails
        ir = 0
        for x=0,world.w-1 do
            for y=0,world.h-1 do
                if ir < MAX_RAILS_SAVED then
                    x = peek(DATA_START+SAVE_RAILS_START + ir*2 + 0) - 1
                    y = peek(DATA_START+SAVE_RAILS_START + ir*2 + 1) - 1
                    if x >= 0 and y >= 0 then
                        world.items[x][y]:set_rail()
                    end
                    ir += 1
                end
            end
        end
        world:refresh_connections()
    end
end

help_on = false

function enable_help()
    help_on = true
end

function show_help()
    draw_rwin(8, 18, 128-16, 100, 1, 7)
    printco("help", 25, 1, 7)
    t = {"walk toward the trees or",
         "stones to gather them.",
         "",
         "enter the train from the",
         "start or end locomotive",
         "to choose the direction of",
         "travel.",
         "",
         "",
         "have fun!",
         "",
         "@frozax"}
    y=38
    for s in all(t) do
        printco(s, y, 7, 1)
        y += 6
    end
end

menuitem(3, "help", function() enable_help() end)



debug = {}

function debug:init()
    --ui.tree = 67
    --ui.stone = 78
    --ui.coins = 15000

    --ptt = {
    --    {6,8}, {6,9}, {6,10},
    --    {6,11}, {6,12}, {6,13},
    --    {6,14}, {6,15}, {6,16},
    --    {7,16}, {8,16},{9,16}
    --}
    --for c in all(ptt) do
    --    world.items[c[1]][c[2]]:set_rail()
    --end
    --world:refresh_connections()
    --train:update()
    --train.state="drive_start"
end


function _update()
    if help_on then
        if btnp(buttons.b1) or btnp(buttons.b2) then
            help_on = false
        end
    else
        anims:update()
        train:update()
        -- draw player before to center the world properly
        player:update()
        if title_screen then
            if btnp(buttons.b1) then
                title_screen = false
                sfx_menu_valid()
            end
        end
        world:update()
        ui:update()
    end
end

function _draw()
    world:draw()
    train:draw()
    --world:debug()
    if not title_screen then
        ui:draw()
    end
    player:draw()
    if title_screen then
        ui:draw_title()
    end
    if help_on then
        show_help()
    end
    --showpct(7)
end

function _init()
    setup_asciitables()
    title_screen = true
    world:init()
    train:init()
    debug:init()
    save:init()
    --music(0)
end
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
007aaa00000a000000000000000009005666666500777700994499444444444499999999555555555555555566666666666d6666dd5555ddcccccccc00088000
0a999aa0000790000000000000009a9066666666076566d0944494444444444499444499555d55ddd55dd55d6d6666d66dd666d6d566665dcccccccc00800800
0a9aaa90000a90000000000000000900600000067665666d444444444444444444444444dddddddddddddddd6666666666dd6d6656666665cccccccc08099080
0a9aaaa0000990000000090000e00b00600000067665556d1414141499449944991111995d55d555dd555d55666666666d66666656666665cccccccc80900908
0a9aaa90000a900000909a900eae0300600000067666666d414141419444944494111149dddddddddddddddd6666666666666dd656666665cccccccc80900908
0a9aaa900009900009a9090000e0030060000006076666d011111111444444449911119955dd5d55d555d55d666666666666d6665d6666d5cccccccc08099080
09aaaa900009900000900b0000b003006000000600dddd00000000004444444444111144dddddddddddddddd6d6666d66dd666ddd5dddd5d1cc11cc100800800
009999000000900000b00300003003000000000000000000000000004444444499111199555555555555555566666666d666666ddd5555dd1111111100088000
00000000002222200777000000044000000aa000007000000777700000bbbbbbbbbbbbbbbbbbbb002222222222222222000000000000000000000bbb00990000
2222222202944442067770000049940000a7aa0000700000070070000b333b333b333b3333b333b042244224422442240000000000000000000b3b3b00049000
44444444029999420677770000444200007aa90000700000070070000b34333433343334433343b04444444444444444000000000000000000bbb3bb09094090
44444444022222220677777000494200007aa9007770000077077000b3444444444444444444443b44444444444444220b00000000000000003b3b3094994949
222222220294949206777700004992000a7aaa907770000077077000b3344444444444444444433b4444444444444422b0b0bb00000000000bb3bbb099494490
222222220294949206777000004942000aaa99900000000000000000bb34444444444444444443bb444444444222444400b0b0b0000000000b3b3b0009949900
2442442402949492066600000049920000666d000000000000000000b3344224422442244224433b4224422442224224000b0000077707703bbb000000949000
22422424002222200000000000042200000000000000000000000000b3222222222222222222223b2222222222222222000b0000777777773300000000040000
00aaa900000ee0000000000000800000008000000000000000000000008008000000000000808000000000000fffff000fffff000fffff00002ee20000000000
00666d000eeaaee0000ee0000877000008770000008000000007000000088000000000000008800000000800f44444f0f44444f0f44444f002222220002ee200
067176d00eeaaee00eeaaee0a7170007a7170f0708770007000770700088e800080880800088e80008088000f4fff4f0f4fff4f0f4fff4f0047ff74002222220
6771766db0beeb0b0eeaaee0087777770877ff77a71777770004007708888e800088e80008888e800088e800f4f4f4f0f4f4f4f0f4f4f4f0471ff17404ffff40
6771116db3bbbb3b0bbeebb0077fff77077fff77087fff77009994400818818008888e800818888008888e80f4f444f0f4f444f0f4f444f00ffffff0471ff174
6777766d3bb1b1bb33bb1b1b077ff7700777f770077ff7700949994002888e8001888e100288888001888e80f4ff22f0f4ff1e10f4fff1e1002222000ffffff0
067766d03bbbbbbb33bbbbbb0077770000a7770000777a00099494400288888002888880022288800222888044422220444feee0444feeee00eeee0000eeee00
00666d000333333003333330000a0a0000000a00000a000009944400002228000022280000222200002222000422220004eeeee004eeeeee0040040000400400
0002ee20002ee200002ee2000000000000000000002ee2000022ee00000000000022ee000022ee000022ee00022ee00000000000002222000000000002222000
002222220222222002222220002ee2000000000002222220022222200022ee00022222200222222002222220222222000022ee00022222200022220022222200
0447ff74047ff760014ff4100222222000000000071ff170044447f002222220044447f0044447f0044447604441ff0002222220044444400222222044444440
0471ff17471ff1644f1ff1f401ffff1000000000477ff774044f71f004444ff0044f71f0044f71f0044f716044ff1d0004441ff04f4444f404444440f4444f40
00ffffff0ffffd6d0fffffd04f1ff1f4002ee2000ffffff000fffff0044f71f000fffff000fffff000fffd6d0ff4d666044ff1f00ffffff04f4444f4ffffff00
00222200002222d000222d6d0ffffff002222220002222000022220000fffff00022220000222200002222d002222d0000fffff0002222000ffffff000222200
00eee40000eeee4000eeee6000eeee00011ff11000eeee0000eeee0000eeee0000eee400004eee0000eeee400eeee00000eeee0000eeee0000eeee0004eeee00
004000000040040000400460004004004ffffff40040040000400400004004000040000000000400004004000400400000400400004004000040040000000400
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
010f00000004400011000001c7141c7151c51510001237040704007011000001c7141c715000001c515237040504405011000001c7141c7152351510001240150204002011000001c7141c715000001c51523714
010f00000c04300000000001871418715185151c0001c700246150000000000187141871500000185151f7040c04300000000001f7141f7151f715100001f015246150000000000187141871500000245151f714
010f00000304403011000001b7141b7151b51510001237040704007011000001b7141b715000001b5152370405044050110000020714207152451510001240150a0400a011000001a51526515225151d51522714
010f00000c043287102b7101871418715185152471024702246152f7102b71018714187152b710185152b7100c0432d710307101f7141f7151f715247101f01524615347102b715187141871500000245151f714
010f00000c04324510275101871418715185151b51033700246152c5102b510187141871527510185151f7040c04327510245101f7141f7151f715245101f015246152451022510187141871522510245151f714
010f00000804408011000001b7141b7151b51510001237040804008011000001b7141b715000001b5152370407044070110000022714227152751513001270150704007011000001a51526515225151d51522714
010f00000c04330700337001871430710307152e7102e715246152e7102e71518714187152e700185151f7040c04333700307001b5142c5102c5152b5102b515246152751027515337051a71526715227151d715
000700000c6241c6252b6002f60024600286002b6002f6003060034600376001360415604176040c6040e60410604116041360400000000000000000000000000000000000000000000000000000000000000000
000100002c2502b6202a2502962028250276202625025620242502362022250216202025000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a3502a5102a515245653005030510305152a565361503651036515365053450029500295002f5003f500335003450029500295002f5003f500335003450029500295002f5003f500005000050000500
000200001021304611102230462110223046311023304631102430464110253046511026304661102630465110253046511024304641102430463110233046211022304621102130461110213046111021304611
000100000c1500e0511105114051170511705014051120510f0510c15100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200003f6142646525361242512345122341212413f6041f3050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b3501b2501c1511d1411f141211312313127121371213b1101b3301b2301c1311d1311f131211312312127121371113b1101b3101b2101c1111d1111f111211112311127111371113b1100000000000
000100000905009040090400903009031090310902109021090210a0210b0210b0210c0210d0200e0210f02111011120111c0011a0011700116001140011200111001100010d0010d00100001000010000100001
000300000c7500f041130311312500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000296632866528604276532765426605256432564524604236432264421603206351e6351c6031b6341762314604106230c625086030661503613026040c0040740400604083040c004172041160400404
0002000000373016732b3730167300473233731c26301663053631a26301663016530d253024531e3530164300343054431c2430163325333016330033325423016230162309323016231d313016131021300413
000100000f12500000000000710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0005000011574160741357418074155641a064165641b054185541d0541a7541f5441b044217441d544220441f744245342103426734220242772424014297140070400704007040070400704007040070400704
000600000b07012741127350c07013741137350d07014741147350f0701674116735182001840018300185021800512200122050a2000a4000a3000a0050a70500000000000d0001400014005000000000000000
000300000c343236450933520621063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002d27321363164530c3430733303323013130d50309503075031550300003000030000300003000031d303123031b0030000300003000030000300003153030b3031a7031f5031b003217031d50322003
00010000352103751534100371003f10039100331001f1001f1001f1001f100231002a10034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0150c0050c005110350c0050c0050c00516055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00020000071540f163163730b22332643216331c6231861315613136130e6130a61304600000000000000000000000b1010710105101031010110100000000000000000000000000000000000000000000000000
000100001b5611e06125061010001a0511d0512405100000197411c7412374100700187301b731227310050000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002336311000103330400010705107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
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
01 00 01 43 44
00 00 01 43 44
00 02 01 43 44
00 02 01 43 44
00 00 03 43 44
00 00 03 43 44
00 02 04 43 44
00 02 04 43 44
00 05 06 43 44
02 02 06 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
