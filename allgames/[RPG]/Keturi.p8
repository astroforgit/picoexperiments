pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- keturi
-- game about a room
-- by Andrius Mitkus
-- http://amitk.us

function unp(t, from, to)
    from = from or 1
    to = to or #t
    if from > to then return end
    return t[from], unp(t, from+1, to)
end

function choosernd(t)
    return t[flr(rnd(#t))+1]
end

function rndint(interval)
    if not interval then
        return 0
    end
    local min, max = interval[1], interval[2]
    local r = flr(rnd(max - min + 1)) + min
    assert(r >= min and r <= max)
    return r
end

-- manhattan distance between game objects
function mdist(a, b)
    return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

dir = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}}
dirmask = {32, 16, 2, 1}

--- room generation ---

room = {}
room_w = 12
room_h = 12

doorblock = {false, false, false, false}
doors = {{1, 6}, {1, 7}, {6, 1}, {7, 1}, {12, 6}, {12, 7}, {6, 12}, {7, 12}}
dooroff = {{9, 0}, {9, 0}, {0, 9}, {0, 9}, {-9, 0}, {-9, 0}, {0, -9}, {0, -9}}
entrances = {{2, 6}, {7, 2}, {11, 7}, {6, 11}}

--  level progression
levels = {
    [1] = {hearts = {1, 1}},
    [2] = {hearts = {1, 1}, m = {1, 1}},
    [3] = {swords = {1, 1}, m = {1, 2}},
    [4] = {swords = {1, 1}, m = {2, 4}},
    [5] = {hearts = {1, 2}, charges = {1, 2}, m = {2, 4}, cm = {0, 1}},
    [6] = {crossbows = {0, 1}, swords = {0, 1}, hearts = {0, 1}, charges = {1, 3}, m = {2, 4}, cm = {1, 1}},
    [7] = {crossbows = {0, 1}, swords = {0, 1}, hearts = {0, 1}, charges = {1, 3}, m = {2, 4}, cm = {1, 2}},
    [8] = {crossbows = {0, 1}, swords = {0, 1}, hearts = {0, 2}, charges = {1, 3}, m = {2, 4}, cm = {1, 2}, qm = {0, 1}},
    [9] = {crossbows = {1, 1}, swords = {1, 1}, hearts = {0, 2}, charges = {1, 3}, m = {2, 4}, cm = {1, 3}, qm = {0, 1}},
    [10] = {crossbows = {0, 1}, wands = {0, 1}, hearts = {0, 1}, charges = {1, 4}, m = {2, 4}, cm = {1, 3}, qm = {1, 2}, cqm = {0, 1}},
    [11] = {crossbows = {0, 1}, wands = {0, 1}, hearts = {0, 1}, charges = {1, 4}, m = {2, 4}, cm = {1, 3}, qm = {1, 2}, cqm = {0, 1}},
    [12] = {crossbows = {0, 1}, wands = {0, 1}, hearts = {0, 2}, charges = {1, 4}, m = {2, 4}, cm = {1, 3}, qm = {1, 2}, cqm = {0, 1}},
    [13] = {crossbows = {0, 1}, wands = {0, 1}, hearts = {0, 1}, charges = {1, 4}, m = {2, 4}, cm = {1, 3}, qm = {1, 2}, cqm = {0, 1}},
    [14] = {crossbows = {0, 1}, wands = {0, 1}, hearts = {0, 1}, charges = {1, 4}, m = {2, 4}, cm = {1, 4}, qm = {1, 2}, cqm = {0, 1}},
    [15] = {crossbows = {0, 1}, wands = {0, 1}, hearts = {0, 2}, charges = {1, 4}, m = {2, 4}, cm = {1, 4}, qm = {1, 2}, cqm = {0, 1}},
    [16] = {crossbows = {1, 1}, wands = {2, 2}, hearts = {0, 2}, charges = {1, 4}, cm = {4, 6}, b = {1, 1}}
}

function is_door(x, y)
    for i, d in pairs(doors) do
        if d[1] == x and d[2] == y and not doorblock[flr(i/2 + 0.5)] then
            return true
        end
    end
    return false
end

function inside_room(x, y)
    return x >= 2 and x < room_w and y >= 2 and y < room_h
end

function wall_bitmask(x, y)
    local mask = 0x0
    for i, d in pairs(dir) do
        local xx, yy = x+d[1], y+d[2]
        if (inside_room(xx, yy) or is_door(xx, yy)) and room[xx][yy] ~= nil then 
            mask += dirmask[i]
        end
    end
    return mask
end

function make_room()
    -- initialize room, nil means wall
    local room = {}
    for i=1,room_w do
        room[i] = {}
    end

    local walls = {} 
    local addwall = function(x, y)
        local w = {x, y}
        for i in all(walls) do
            if x == i[1] and y == i[2] then
                return
            end
        end
        add(walls, w)
    end
    local addwalls = function(x, y)
        for d in all(dir) do
            local dx, dy = unp(d) 
            if inside_room(x+dx, y+dy) then
                addwall(x+dx, y+dy)
            end
        end
    end
    local cntneighbours = function(x, y)
        local cnt = 0
        for d in all(dir) do
            local dx, dy = unp(d)
            if (room[x+dx][y+dy] ~= nil) then cnt+=1 end
        end
        return cnt
    end
    local cx = flr(rnd(10))+2
    local cy = flr(rnd(10))+2
    room[cx][cy] = 0
    addwalls(cx, cy)

    local tries = 0
    while true do
        -- get random wall
        local wx, wy = unp(choosernd(walls))
        local c = cntneighbours(wx, wy)
        if c == 1 or c == 2 then
            -- remove it if there's one empty neighbour 
            room[wx][wy] = 0
            addwalls(wx, wy)
            for i, w in pairs(walls) do
                if wx == w[1] and wy == w[2] then
                    walls[i] = walls[#walls]
                    walls[#walls] = nil
                    break
                end
            end
        else
            tries += 1
        end

        if tries > 200 then
            break
        end
    end

    for door in all(entrances) do
        local x, y = unp(door)
        room[x][y] = 0
        for d in all(dir) do
            local dx, dy = unp(d)
            if inside_room(x+dx, y+dy) then
                room[x+dx][y+dy] = 0
            end
        end
    end

    for i, door in pairs(doors) do
        if not doorblock[flr(i/2 + 0.5)] then
            local x, y = unp(door)
            room[x][y] = 1
        end
    end

    -- make list of empty/solid cells
    local empty = {}
    local solid = {}
    for x=1,room_w do
        for y=1,room_h do
            if not is_door(x, y) then
                if room[x][y] ~= nil then
                    add(empty, {x, y})
                else
                    add(solid, {x, y})
                end
            end
        end
    end

    return room, empty, solid
end

function draw_room(offx, offy)
    for y=1,room_h do
        for x=1,room_w do
            if room[x][y] == nil then
                spr(1, offx+(x-1)*8, offy+(y-1)*8)
            end
        end
    end
end

--- objects ---
status_str = ""

player = nil
objs = {}
world_state = 0

-- lists of empty and solid room cells, not counting any objects 
empty = {}
solid = {}

_left = 0
_right = 1
_up = 2
_down = 3
_z = 4
_x = 5

-- distance to player from each cell
player_dist = {}

function gen_player_dist()
    local pd = player_dist
    for x=1,room_w do
        pd[x] = {}
        for y=1,room_h do
            pd[x][y] = -1
        end
    end

    local function bfs(x, y, dist)
        d = d or 0 
        local q = {{x, y}}
        pd[x][y] = 0
        local qi = 1
        while qi <= #q do
            local x, y = unp(q[qi])
            qi+=1
            local dist = pd[x][y]
            for d in all(dir) do
                local xx, yy = x+d[1], y+d[2]
                if is_empty(xx, yy) and pd[xx][yy] == -1 then
                    add(q, {xx, yy, dist})
                    pd[xx][yy] = dist+1
                end
            end
        end
    end

    bfs(player.x, player.y, 0)
end

function is_empty(x, y)
    if inside_room(x, y) then
        -- todo: sort by x to make this faster
        for o in all(objs) do
            if o.x == x and o.y == y and o.solid then
                return false
            end
        end
        return true
    end
    return false
end

function objs_at(x, y)
    local res = {}
    for o in all(objs) do
        if o.x == x and o.y == y then
            add(res, o)
        end
    end
    return res
end

--- player
function new_player(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 3
    o.solid = true
    o.lives = 2
    o.weapon = nil
    o.tick = function(self)
        assert(self == player)
        if player.dead then
            return false
        end
        local dx, dy = 0, 0
        if btnp(_left) then dx -= 1 end
        if btnp(_right) then dx += 1 end
        if btnp(_up) then dy -= 1 end
        if btnp(_down) then dy += 1 end

        if dx ~= 0 or dy ~= 0 then
            local xx, yy = self.x+dx, self.y+dy
            if self.weapon ~= nil and self.weapon.ranged and self.weapon.charges > 0 then
                -- attack with ranged weapon
                local hit = false
                local xx, yy = self.x+dx, self.y+dy
                local startx, starty = xx, yy
                local stop = false
                while true do
                    local in_front = objs_at(xx, yy)
                    foreach(in_front, function(o)
                        if o.enemy then
                            hit = true
                            stop = true
                            self.weapon.charges -= 1
                            o.hit(o, player)
                            if self.weapon.swap then
                                local monx, mony = o.x, o.y
                                o.x, o.y = self.x, self.y
                                self.x, self.y = monx, mony 
                                foreach(objs_at(monx, mony), function(o)
                                    if not o.monster and not o.solid and o.hit then
                                        o.hit(o, player)
                                    end
                                end)
                            end
                        end
                        if o.solid then
                            stop = true
                            return
                        end
                    end)
                    if not stop then
                        xx, yy = xx+dx,yy+dy
                        if not inside_room(xx, yy) then
                            break
                        end
                    else
                        break
                    end
                end
                if hit then
                    addline(startx, starty, xx, yy)
                    return true
                end
            end

            if is_empty(xx, yy) then
                -- move to empty square
                self.x = xx
                self.y = yy
                foreach(objs_at(xx, yy), function(o)
                    if o ~= player and o.hit ~= nil then
                        o.hit(o, self)
                    end
                end)
                gen_player_dist()
                return true
            elseif is_door(xx, yy) then
                -- move to next room
                if not boss_killed then
                    next_room(xx, yy)
                    sfx(5)
                    return false
                else
                    win = true
                    fadeout()
                    return false
                end
            else 
                -- attack with melee weapon
                local hit = false
                local in_front = objs_at(xx, yy)
                foreach(in_front, function(o)
                    if o.enemy then
                        hit = true
                        if self.weapon and self.weapon.charges > 0 then
                            self.weapon.charges -= 1
                            o.hit(o, player)
                        end
                    end
                end)
                if hit then
                    return true
                end
            end
        end

        return false 
    end
    o.draw = function(self)
        for i=1,self.lives do
            spr(5, 6 + (i-1)*8, 0)
        end

        if self.weapon then
            spr(self.weapon.spr, 8, 8)
            print(self.weapon.charges.."/"..self.weapon.maxcharges, 20, 10)
        end
        spr(32, 0, 8)
        spr(33, 16, 8)
    end
    o.hit = function(self)
        sfx(1)
        self.lives -= 1
        screenshake()
        if self.lives == 0 then
            player.dead = true
            fadeout()
        end
    end

    add(objs, o)
    player = o
    gen_player_dist()
    return o
end

function new_sword(x, y)
    local o = {}
    o.x, o.y = x, y
    o.spr = 16
    o.solid = false
    o.maxcharges = 4
    o.hit = function(self, hitter)
        if hitter == player then
            player.weapon = self
            self.destroy = true
            self.charges = self.maxcharges
            sfx(2)
        end
    end
    add(objs, o)
    return o
end

function new_crossbow(x, y)
    local o = {}
    o.x, o.y = x, y
    o.spr = 17
    o.solid = false
    o.maxcharges = 4
    o.ranged = true
    o.hit = function(self, hitter)
        if hitter == player then
            player.weapon = self
            self.destroy = true
            self.charges = self.maxcharges
            sfx(2)
        end
    end
    add(objs, o)
    return o
end

function new_wand(x, y)
    local o = {}
    o.x, o.y = x, y
    o.spr = 34
    o.solid = false
    o.maxcharges = 4
    o.ranged = true
    o.swap = true
    o.hit = function(self, hitter)
        if hitter == player then
            player.weapon = self
            self.destroy = true
            self.charges = self.maxcharges
            sfx(2)
        end
    end
    add(objs, o)
    return o
end

-- generic monster step function used by most monsters
function monster_step(self)
    if self.destroy then
        return
    end
    local mindist = 1000
    local newx, newy = nil, nil
    for d in all(dir) do
        local x, y = self.x+d[1], self.y+d[2]
        local pd = player_dist[x][y]
        if pd < mindist and pd > 0 and is_empty(x, y) then
            newx, newy = x, y
            mindist = pd
        end
        if pd == 0 then
            player.hit(player, self)
            newx, newy = nil, nil
            break
        end
    end

    if newx ~= nil then
        player_dist[self.x][self.y] = mindist+1

        -- if player is further than 5 squares, 20% chance to step in random direction
        if mindist > 5 and rnd(100) < 20 then
            local rx, ry = unp(dir[rndint({1, 4})])
            local xx, yy = self.x+rx, self.y+ry
            if is_empty(xx, yy) then
                self.x, self.y = xx, yy
                return
            end
        end
        self.x, self.y = newx, newy
    end
end

function player_visible_from(x, y)
    local raycast = function(x, y, dx, dy)
        while true do
            x, y = x+dx, y+dy
            if not inside_room(x, y) then
                return false
            end
            for o in all(objs_at(x, y)) do
                if o == player then
                    return true
                end
                if o.solid then
                    return false
                end
            end
        end
    end

    for d in all(dir) do
        if raycast(x, y, d[1], d[2]) then
            return true
        end
    end
    return false
end

-- boss step function
function boss_step(self)
    if self.destroy then
        return
    end

    -- skip turn when staggered
    if self.staggered > 0 then
        self.staggered -= 1
        return
    end

    -- if player visible, shoot
    if player_visible_from(self.x, self.y) then
        player.hit(player, self)
        addline(self.x, self.y, player.x, player.y)
        return
    end

    -- go to a cell which makes line of sight to player
    local foundcell = false
    for d in all(dir) do
        local xx, yy = self.x+d[1], self.y+d[2]
        if is_empty(xx, yy) and player_visible_from(xx, yy) then
            self.x, self.y = xx, yy
            return
        end
    end

    -- go towards player like normal monster
    monster_step(self)
end

--- monster
function new_monster(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 4
    o.solid = true
    o.enemy = true
    o.tick = monster_step 
    o.hit = function(self)
        -- todo: die animation
        o.destroy = true
        small_screenshake()
        sfx(0)
    end
    add(objs, o)
    return o
end

--- charge monster
function new_cmonster(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 19
    o.solid = true
    o.enemy = true
    o.tick = monster_step
    o.hit = function(self, h)
        -- todo: die animation
        if h == player then
            if h.weapon then
                h.weapon.charges += 2
                h.weapon.charges = min(h.weapon.charges, h.weapon.maxcharges)
            end
        end
        self.destroy = true
        sfx(0)
        small_screenshake()
    end
    add(objs, o)
    return o
end

-- quick monster
function new_quickmon(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 20
    o.solid = true
    o.enemy = true
    o.tick = function(self)
        -- simply do two ticks to make fast monster
        for i=1,2 do
            monster_step(self)
        end
    end
    o.hit = function(self)
        -- todo: die animation
        self.destroy = true
        sfx(0)
        small_screenshake()
    end
    add(objs, o)
    return o
end

-- charge quick monster
function new_cquickmon(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 35
    o.solid = true
    o.enemy = true
    o.tick = function(self)
        -- simply do two ticks to make fast monster
        for i=1,2 do
            monster_step(self)
        end
    end
    o.hit = function(self, h)
        -- todo: die animation
        if h == player then
            if h.weapon then
                h.weapon.charges += 2
                h.weapon.charges = min(h.weapon.charges, h.weapon.maxcharges)
            end
        end
        self.destroy = true
        sfx(0)
        small_screenshake()
    end

    add(objs, o)
    return o
end

function new_boss(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 36
    o.hp = 10
    o.solid = true
    o.enemy = true
    o.tick = boss_step 
    o.staggered = 0
    o.hit = function(self)
        -- todo: die animation
        self.hp -= 1
        if self.hp <= 0 then
            -- boss destroyed, do something exciting
            self.destroy = true
            boss_killed = true
            sfx(0)
            sfx(3)
            sfx(4)
        end

        self.staggered = 1
        small_screenshake()
    end
    add(objs, o)
    return o
end

--- heart
function new_heart(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 5
    o.solid = false
    o.hit = function(self, hitter)
        if hitter == player and player.lives < 10 then
            self.destroy = true
            player.lives += 1
            sfx(2)
        end
    end
    add(objs, o)
    return o
end

-- charge
function new_charge(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.spr = 18
    o.solid = false
    o.hit = function(self, hitter)
        local h = hitter
        if hitter == player and h.weapon ~= nil and h.weapon.charges < h.weapon.maxcharges then
            self.destroy = true
            h.weapon.charges += 1
            sfx(2)
        end
    end
    add(objs, o)
    return o
end

function objs_update()
    if player.tick(player) then
        world_state += 1
        foreach(objs, function(o)
            if o ~= player and o.tick ~= nil and not o.destroy then
                o.tick(o) 
            end
        end)
    end
end

function objs_draw(offx, offy)
    foreach(objs, function(o)
        spr(o.spr, offx+(o.x-1)*8, offy+(o.y-1)*8)
        if o.draw ~= nil then
            o.draw(o)
        end
    end)

    -- debug distance to player rendering
    --[[
    for x=1,room_w do
        for y=1,room_h do
            if player_dist[x][y] ~= -1 then
                print(player_dist[x][y], offx+(x-1)*8+1, offy+(y-1)*8+2)
            end
        end
    end
    ]]
end

--- effects ---
framenum = 0

shake_len = 15
shake_start = 0
function screenshake()
    shake_start = framenum
end

function small_screenshake()
    shake_start = framenum - 8 
end

fadeout_start = 0
fadeout_acc = 0
function fadeout()
    fadeout_start = framenum
    fadeout_acc = 0
end

lines = {}
function addline(_x0, _y0, _x1, _y1)
    add(lines, {
        x0 = (_x0-1)*8+4,
        y0 = (_y0-1)*8+4,
        x1 = (_x1-1)*8+4,
        y1 = (_y1-1)*8+4,
        t = framenum
    })
end

function do_effects(offx, offy)
    framenum += 1
    local shake = framenum - shake_start
    if shake_start > 0 and shake < shake_len then
        local mag = flr((15 - shake)/5)
        local hmag = mag/2
        local offx, offy = flr(rnd(mag+1)-hmag), flr(rnd(mag+1)-hmag)
        camera(offx, offy)
    end

    if fadeout_start > 0 then
        for i=1,128 do
            local x, y = flr(rnd(128)), flr(rnd(128))
            pset(x, y, 0)
        end
        fadeout_acc += 1
    end

    if fadeout_acc <= 16 then    
        cls()
    end

    for l in all(lines) do
        if framenum - l.t < 3 then
            local sx, sy = offx+l.x0,offy+l.y0
            local ex, ey = offx+l.x1,offy+l.y1
            line(sx, sy, ex, ey, 7)
        else
            del(lines, l)
        end
    end
end

function spawn(n, func, mindist)
    local ppos = nil
    if mindist then
        ppos = {player.x, player.y}
    end
    for i=1,n do
        assert(#empty > 1)
        local p = nil
        repeat
            p = choosernd(empty)
        until not mindist or mdist(p, ppos) > mindist
        func(p[1], p[2])
        local oldlen = #empty
        del(empty, p)
        local newlen = #empty
        assert(oldlen > newlen)
    end
end

current_room = 1
function prep_room(n, px, py)
    framenum = 0
    shake_start = 0
    fadeout_start = 0
    fadeout_acc = 0
    lines = {}
    objs = {}

    room, empty, solid = make_room()

    -- make ground
    for i=1,room_w do
        ground[i] = {}
    end
    foreach(empty, function(e)
        if rnd(100) > 87 then
            local x, y = unp(e)
            ground[x][y] = 14 + flr(rnd(5))*16 + flr(rnd(2))
        end
    end)

    if px == nil and py == nil then
        spawn(1, new_player)
    else
        add(objs, player)
        player.x = px
        player.y = py
    end

    local lvl = levels[n]
    if lvl == nil then
        lvl = levels[#levels]
    end

    spawn(rndint(lvl.m), new_monster, 5)
    spawn(rndint(lvl.cm), new_cmonster, 5)
    spawn(rndint(lvl.qm), new_quickmon, 5)
    spawn(rndint(lvl.cqm), new_cquickmon, 5)
    spawn(rndint(lvl.b), new_boss, 5)
    spawn(rndint(lvl.swords), new_sword, 2)
    spawn(rndint(lvl.crossbows), new_crossbow, 2)
    spawn(rndint(lvl.wands), new_wand, 2)
    spawn(rndint(lvl.hearts), new_heart, 2)
    spawn(rndint(lvl.charges), new_charge, 2)

     -- make wall objs
    foreach(solid, function(w)
        local wx, wy = unp(w)
        local bmask = wall_bitmask(wx, wy)
        local s = 6 + bmask
        if rnd(100) > 82 then
            s += 4
        end
        add(objs, {
            x = wx,
            y = wy,
            spr = s,
            solid = true
        })
    end)
end

goto_next = false
last_player_pos = nil
function next_room(xx, yy)
    goto_next = true
    last_player_pos = {xx, yy}
end

function _init()
    world_state = 0
    current_room = 1
    boss_killed = false
    win = false
    doorblock = {false, false, false, false}
    prep_room(current_room)
end

function draw_title()
    cls()
    spr(64, 44, 20, 4, 4)
    print("keturi", 48, 60, 5)
    print("find the room", 36, 70, 5)
    print("press x to start", 30, 100, 7)
end

win = false
title = true
ground = {}
function _draw()
    if title then
        draw_title()
    else
        local offx, offy = 2*8, 3*8-2
        do_effects(offx, offy)
        -- draw ground
        for x=1,room_w do
            for y=1,room_h do
                local s = ground[x][y]
                if s ~= nil then
                    spr(s, offx+(x-1)*8, offy+(y-1)*8)
                end
            end
        end
        if fadeout_acc <= 16 then
            objs_draw(offx, offy)
            print(status_str, 0, 8*15)
            local room_str = "the room"
            if current_room < #levels then
                room_str = "room "..current_room
            end
            print(room_str, 10*8, 10)
        elseif win == false then
            print("you died.", 6*8, 6*8, 7)
            print("press x to play again", 3*8, 9*8, 7)
            if btnp(_x) then
                cls()
                _init()
            end
        else
            print("you won!", 6*8, 6*8, 7)
            print("steps taken: "..world_state, 4*8, 8*8, 7)
        end
    end
end

function _update()
    if win then
        return
    end
    if title then
       if btn(_x) then
            title = false
       end
       return
    end

    objs_update()

    -- advance to next room
    if goto_next then
        goto_next = false
        local xx, yy = unp(last_player_pos)
        local off = nil
        doorblock = {false, false, false, false}
        for i, d in pairs(doors) do
            if d[1] == xx and d[2] == yy then
                off = dooroff[i]
                i += 4
                if i > 8 then
                    i -= 8
                end
                doorblock[flr(i/2 + 0.5)] = true
                break
            end
        end
        assert(off ~= nil)
        current_room += 1
        prep_room(current_room, player.x+off[1], player.y+off[2])
        gen_player_dist()
    else
        -- cleanup dead objs
        for o in all(objs) do
            if o.destroy then
                del(objs, o)
            end
        end
    end
end
__gfx__
00000000dddddddd11111111000000000000000000000000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddddddd10000000000000000
00000000dddddddd11111111000660000090090000000000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddddddd10500500000000000
00700700dddddddd11100111006006000099990000800800ddddddddddddddddddddddd1ddddddd1ddd666dddddddddd6666ddd1ddddddd10000000055005005
00077000dddddddd11000011000660000090090008888880ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddd666d10000000000000000
00077000dddddddd11000011066666600099990008888880ddddddddddddddddddddddd1ddddddd1dddddd6666ddddddddddddd1ddddddd10000050000005005
00700700dddddddd11000011006666000999999000888800ddddddddddddddddddddddd1ddddddd1dddddddddddddd666dddddd1ddddddd10000000000000000
00000000dddddddd11000011006006000090090000088000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddddddd10000050050500000
00000000dddddddd11000011006006000000000000000000dddddddd11111111ddddddd111111111dddddddd11111111ddddddd1111111110000000000000000
00000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111110000005000000000
00000770077700700000000000c00c000009900000000000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddddddd10000000000000500
00007770000077000000000000cccc000090090000000000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddd666ddd1dd66ddd10000000000000000
07077700000077000007700000c00c000990099000000000ddddddddddddddddddddddd1ddddddd1dd6dddd66666ddddddddd661ddddddd10000005000000500
00777000000700700007700000cccc000099990000000000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddddddd10000000000000000
0077000000700070000000000cccccc00099990000000000ddddddddddddddddddddddd1ddddddd1dddddd6ddddddd66666dddd1dd666dd10000000005500000
07007000070000700000000000c00c000009900000000000ddddddddddddddddddddddd1ddddddd1ddddddddddddddddddddddd1ddddddd10000000000000000
000000000000000000000000000000000000000000000000dddddddd11111111ddddddd111111111dddddddd11111111ddddddd1111111110500000000000000
0000006666000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11dd666dd1ddddddd1dd66dd11dddddd10000000000000000
000000600600000000000770000cc00000099000000000001ddddddd1ddddddd1dddddd11dddddd11ddddddd1ddd66dd1dddddd11d666dd10000000000500000
00000060060000000000077000c00c0000988900000000001ddddddd1ddddddd1dddddd11dddddd11ddddddd1d6ddddd1dddddd11dddddd10000000500000000
0000006006000000000070000cc00cc000099000000000001ddddddd1ddddddd1dddddd11dddddd11ddddddd1dd6666d1d66ddd11dddddd10000000000500000
00000060060000000007000000cccc0009999990000000001ddddddd1ddddddd1dddddd11dddddd11dddd6dd1ddddddd1dddddd11dddddd10000000000000000
00000060060000000070000000cccc0000999900000000001ddddddd1ddddddd1dddddd11dddddd11ddddddd1ddddddd1dddddd11dd666d10005000050000050
000000600600000007000000000cc00000900900000000001ddddddd1ddddddd1dddddd11dddddd11d6ddddd1ddddddd1dd666d11dddddd10000000000000000
0000006666000000000000000000000000900900000000001ddddddd111111111dddddd1111111111ddddddd111111111dddddd1111111110000000000000000
00000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111110000000000000000
0000000000000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11ddddddd1ddddddd1dddddd11dddddd10000000005005000
0000000000000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11d66dddd1dd666dd1dd666d11dddd6d10000000000000000
0000000000000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11ddd666d1ddddddd1dddddd11dddddd10000005050005000
0000000000000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11d6ddddd1dddd66d1dddddd11dddddd10000000000000000
0000000000000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11ddddddd1d6ddddd1d666dd11dddddd10000005005000000
0000000000000000000000000000000000000000000000001ddddddd1ddddddd1dddddd11dddddd11dd66ddd1ddddddd1dddddd11dddddd10000000000005005
0000000000000000000000000000000000000000000000001ddddddd111111111dddddd1111111111ddddddd111111111dddddd1111111110500000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011100000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001011111111101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000011111111101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010201010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000001000000380000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100010001000037010100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010001000400000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200030001010000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01002f0001010000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01002e0000000001010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100010101010100001e00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100001f00000004000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000f0000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101020101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000035370313702e3702c3702736024360213601f3701b370183601636013360113500f3500d3500b34009340083400533003320013100200001000013000130001300013000130001300013000230002300
000100001f0601f0601f0601f0501e0501c0501905018040160401404012040110400f0300e0300c0300a020080200602003010010100101001050120000f0000d0000b000090000700005000030000100001000
000200001953021530295302e5302f5302b530235301b5400e5300552001510015000150001500035000250002500025000250002500015000000000000000000000000000000000000000000000000000000000
000300001260012610126201263011630116401164011640116501165011650116601167011670106701067010660106501065010640116301162011620116101161011600116001160011600116001160011600
001000003355029550305503a5503655030550355503a5503d5503f550000003f550000003f540000003f52000000345000000027500000000000000000000000000024500000000000000000000001650000000
000400000763007620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
