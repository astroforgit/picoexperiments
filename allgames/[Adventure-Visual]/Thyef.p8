pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--thyef
--by zee

------------
-- matrix --
------------

function matidentity()
    return {
        {1, 0, 0, 0},
        {0, 1, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1},
    }
end

function mattranslation(x,y,z)
    return {
        {1, 0, 0, x},
        {0, 1, 0, y},
        {0, 0, 1, z},
        {0, 0, 0, 1}
    }
end

function matrotate(x, y, z)    
    -- prebake tri functions for speed
    local sinx = sin(x)
    local siny = sin(y)
    local sinz = sin(z)
    local cosx = cos(x)
    local cosy = cos(y)
    local cosz = cos(z)
    -- create the mats
    local rotz = {
        {cosz, -sinz, 0, 0},
        {sinz, cosz, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
    local rotx = {
        {1, 0, 0, 0},
        {0, cosx, -sinx, 0},
        {0, sinx, cosx, 0},
        {0, 0, 0, 1}
    }
    local roty = {
        {cosy, 0, -siny, 0},
        {0, 1, 0, 0},
        {siny, 0, cosy, 0},
        {0, 0, 0, 1}
    }
    return matmul(rotz, matmul(roty, rotx))
end

function matscale(x, y, z)
    return {
        {x, 0, 0, 0},
        {0, y, 0, 0},
        {0, 0, z, 0},
        {0, 0, 0, 1}
    }
end

function matlookat(eye, target, up)
    local z = vecnormalized(vecsub(target, eye))
    local x = vecnormalized(veccross(up, z))
    local y = veccross(z, x)
    return {
        {x.x, x.y, x.z, -vecdot(x, eye)},
        {y.x, y.y, y.z, -vecdot(y, eye)},
        {z.x, z.y, z.z, -vecdot(z, eye)},
        {0, 0, 0, 1}
    }
end

function matperspective(fov, znear, zfar)
    local aspect = 1
    local halffov = 1
    local zrange = znear - zfar
    return {
        {1/(halffov * aspect), 0, 0, 0},
        {0, 1/halffov, 0, 0},
        {0, 0, (-znear - zfar) / zrange, 2 * zfar * znear / zrange},
        {0, 0, 1, 0}
    }
end

function matscreenspace()
    local halfres = 128/2
    return {
        {halfres, 0, 0, halfres - .5},
        {0, -halfres, 0, halfres - .5},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
end

function mattransform(m, v)
    return {
        x = m[1][1] * v.x + m[1][2] * v.y + m[1][3] * v.z + m[1][4] * v.w,
        y = m[2][1] * v.x + m[2][2] * v.y + m[2][3] * v.z + m[2][4] * v.w,
        z = m[3][1] * v.x + m[3][2] * v.y + m[3][3] * v.z + m[3][4] * v.w,
        w = m[4][1] * v.x + m[4][2] * v.y + m[4][3] * v.z + m[4][4] * v.w
    }
end

function matmul(lhs, rhs)
    local result = matidentity()
    for i = 1, 4 do
        for j = 1, 4 do
            result[i][j] =
                        lhs[i][1] * rhs[1][j]
                    +   lhs[i][2] * rhs[2][j] 
                    +   lhs[i][3] * rhs[3][j] 
                    +   lhs[i][4] * rhs[4][j]
        end
    end
    return result
end

------------
-- vector --
------------

function vec(x,y,z,w)
    return {x=x, y=y, z=z, w=w or 1}
end

function vecadd(v,u)
    return {x=v.x+u.x, y=v.y+u.y, z=v.z+u.z, w=v.w}
end

function vecsub(v,u)
    return {x=v.x-u.x, y=v.y-u.y, z=v.z-u.z, w=v.w}
end

function veclength(v)
    return sqrt(v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w)
end

function vecdot(v, u)
    return v.x*u.x + v.y*u.y + v.z*u.z + v.w*u.w
end

function vecscalar(v, s)
    return {x=v.x*s, y=v.y*s, z=v.z*s, w=v.w*s}
end

function veccross(v, u)
    return {
        x=v.y * u.z - v.z * u.y,
        y=v.z * u.x - v.x * u.z,
        z=v.z * u.y - v.y * u.x,
        w=0
    }
end

function vecnormalized(v)
    local length = veclength(v)
    return {x=v.x/length, y=v.y/length, z=v.z/length, w=v.w/length}
end

function vecperspective(v)
    return {x=v.x/v.w, y=v.y/v.w, z=v.z/v.w, w=v.w}
end

function veceulernormal(v)
    -- assuming yaw, pitch, roll | x, y, z
    -- since pico 8 uses 0.0 to 1.0 to represent angles, so shall this function
    return {
        x = cos(v.x)*cos(v.y),
        y = sin(v.x)*cos(v.y),
        z = sin(v.y),
        w = 0
    }
end

------------------
-- triangle code --
------------------

function edge(miny, maxy)
    local edge = {}
    edge.ystart = ceil(miny.y)
    edge.yend = ceil(maxy.y)

    local ydist = maxy.y - miny.y
    local xdist = maxy.x - miny.x
    local yprestep = edge.ystart - miny.y

    edge.xstep = xdist / ydist
    edge.x = miny.x + yprestep * edge.xstep -- init x value | aka point (x0, y0)

    return edge
end

function tridoublearea(a, b, c)
    local x1 = b.x - a.x
    local y1 = b.y - a.y
    local x2 = c.x - a.x
    local y2 = c.y - a.y
    -- using the cross product to calculate the area doubled
    return (x1 * y2 - x2 * y1)
end

function calctrinormal(a, b, c)
    -- expects model space!
    local u = vecsub(b,a)
    local v = vecsub(c,a)
    return {
        x = (u.y * v.z) - (u.z * v.y),
        y = (u.z * v.x) - (u.x * v.z),
        z = (u.x * v.y) - (u.y * v.x),
        w = 1
    }
end

function islit(a,b,c,sundir)
    local normal = calctrinormal(a,b,c)
    local ndotl = vecdot(normal, sundir)
    return ndotl <= 0
end

function ghettoclipxz(a, b, c)
    local x1 = (a.x < 0 and b.x < 0 and c.x < 0)
    local x2 = (a.x > 128 and b.x > 128 and c.x > 128)
    local z = (a.z < .1 or b.z < .1 or c.z < .1) or (a.z > 1 or b.z > 1 or c.z > 1)
    --return ((x1 or x2) and not (x1 and x2)) or z    -- x1 xor x2 or z
    return x1 or x2 or z    -- x1 or x2 or z
end

function ghettoclipy(v)
    v.y = max(0, min(129, v.y))
end

-----------------
--drawing code--
-----------------

function rendertri(a,b,c,mvp)
    local screen = matscreenspace()
    miny = vecperspective(mattransform(screen, mattransform(mvp, a)))
    midy = vecperspective(mattransform(screen, mattransform(mvp, b)))
    maxy = vecperspective(mattransform(screen, mattransform(mvp, c)))
    drawtri(miny, midy, maxy)
end

function drawoutline(verts, indices, mvp)
    local converts = {}
	local screen = matscreenspace()
	for v in all(verts) do
        add(converts, vecperspective(mattransform(screen, mattransform(mvp, v))))
        ghettoclipy(converts[#converts])
    end
    color(0)
    for j=1, #indices, 2 do
        local index = indices[j + 1]
        for i=1, #index, 3 do
            local a = converts[index[i]]
            local b = converts[index[i+1]]
            local c = converts[index[i+2]]
            --drawtri(converts[index[i]], converts[index[i+1]], converts[index[i+2]])
            if(not ghettoclipxz(a,b,c)) then  
                if tridoublearea(a,b,c) >= 0 then
                    drawtri(a,b,c)
                end
            end
        end
    end
end

function drawmesh(verts, indices, mvp)
    --local viewspace = {}
    local converts = {}
	local screen = matscreenspace()
	for v in all(verts) do
        --add(viewspace, mattransform(mvp, v))
        --add(converts, vecperspective(mattransform(screen, viewspace[#viewspace])))
        add(converts, vecperspective(mattransform(screen, mattransform(mvp, v))))
        --ghettoclipy(converts[#converts])
	end
    for j=1, #indices, 2 do
        color(indices[j])
        local index = indices[j + 1]
        for i=1, #index, 3 do
            local a = converts[index[i]]
            local b = converts[index[i+1]]
            local c = converts[index[i+2]]
            --drawtri(converts[index[i]], converts[index[i+1]], converts[index[i+2]])
            --if(not ghettoclipxz(a,b,c)) then  
            if tridoublearea(a,b,c) >= 0 then
                --if islit(viewspace[index[i]], viewspace[index[i+1]], viewspace[index[i+2]], sunview) then
                if not islit(verts[index[i]], verts[index[i+1]], verts[index[i+2]], sunview) then
                    fillp(0b1010010110100101)
                else
                    fillp()
                end
                drawtri(a,b,c)
            end
            --end
        end
    end
end

function drawtri(miny, midy, maxy)
    -- sort based on screen height
    local temp = nil
    if (maxy.y < midy.y) then
        temp = maxy;
        maxy = midy;
        midy = temp;
    end
    if (midy.y < miny.y) then
        temp = midy;
        midy = miny;
        miny = temp;
    end
    if (maxy.y < midy.y) then
        temp = maxy;
        maxy = midy;
        midy = temp;
    end
    scantri(miny, midy, maxy)
end

function scantri(miny, midy, maxy)
    local toptobot = edge(miny, maxy)
    local toptomid = edge(miny, midy)
    local midtobot = edge(midy, maxy)

    scanedge(toptobot, toptomid)
    scanedge(toptobot, midtobot)
end

function scanedge(a, b)
    local ystart = b.ystart
    local yend = b.yend

    -- draw line!
    for y = ystart, yend - 1 do
        rectfill(a.x, y, b.x, y)
        a.x += a.xstep
        b.x += b.xstep
    end
end

-------------------------------------------
-- various game entities and interactables
-------------------------------------------

-- mesh data and transform
mesh = {}
mesh.__index = mesh

function mesh:new(vert, index, pos, rot)
    local m = {}
    setmetatable(m, mesh)
    m.vert = vert
    m.index = index
    m.pos = pos
    m.rot = rot
    return m
end

function mesh:getmodelmat()
    local translation = mattranslation(self.pos.x, self.pos.y, self.pos.z)
    local rotation = matrotate(self.rot.x, self.rot.y, self.rot.z)
    --local transform = matmul(translation, rotation)
    return matmul(translation, rotation)
end

-- pickup items to add to inventory
pickup = {}
pickup.__index = pickup

function pickup:new(itemid, vert, index, pos, rot)
    -- don't generate an already picked up object!
    -- if getmemflag(itemid) then return nil end
    local p = {}
    setmetatable(p, pickup)
    p.id = itemid
    p.mesh = mesh:new(vert, index, pos, rot)
    return p
end

function pickup:onpickup()
    local function grab()
        zoommesh(self.mesh, self.mesh.pos, vec(0,-2,2,0), self.mesh.rot, self.mesh.rot)
        setmemflag(self.id)
        self.mesh = nil
        uitext = "\n\n\n\n\n\n\n\n\n\n\n\t" .. "you've picked up a chess piece"
        sfx(3)
        while not mouseclicked() do 
            yield() 
        end
        uitext = nil
        yield() -- stops accidental clicks
    end

    return function(caller)
        caller.enabled = false
        coevent = cocreate(grab)
    end
end

-- fancy word for letters to read
missive = {}
missive.__index = missive

function missive:new(vert, index, pos, rot, text)
    local m = {}
    setmetatable(m, missive)
    m.text = text
    m.mesh = mesh:new(vert, index, pos, rot)
    return m
end

function missive:read()
    local mdl = self.mesh
    local posa = self.mesh.pos
    local posb = vec(0,0,2,0)
    local rota = self.mesh.rot
    local rotb = vec(-.75, 0, 0, 0)
    local text = self.text

    local function cofunc()
        zoommesh(mdl, posa, posb, rota, rotb)

        uitext = text
        local cancel = false
        while not cancel do
            uipointer = "click"
            if mouseclicked() then 
                cancel = true
            end
            yield()
        end
        uitext = nil

        zoommesh(mdl, posb, posa, mdl.rot, rota)
    end

    return function()
        coevent = cocreate(cofunc)
    end
end

-- objects you can zoom in and interact with.
inspectable = {}
inspectable.__index = inspectable

function inspectable:new(vert, index, pos, rot)
    local i = {}
    setmetatable(i, inspectable)
    i.mesh = mesh:new(vert, index, pos, rot)
    return i
    --todo:
    --  add extra custom code for inspectables that can be opened / closed
    --  and not just rotated!
end

function inspectable:lookat()
    local mdl = self.mesh
    local posa = self.mesh.pos
    local posb = vec(0,0,2,0)
    local rota = self.mesh.rot
    local rotb = self.mesh.rot

    local function cofunc()
        -- zoom in
        zoommesh(mdl, posa, posb, rota, rotb)

        --------------------------------------------------------
        -- test for coroutene handling logic itself!
        --      idea:
        --          - plug custom logic for more advanced inspectables?
        --------------------------------------------------------
        local cancel = false
        local xbutton = initbutton(2, 2, 8, function() cancel = true; uicancel = false; end )
        uicancel = true

        local oldx, oldy = getmousepos()
        while not cancel do
            uipointer = "grab"
            local clicked = mouseclicked()
            local newx, newy = getmousepos()
            -- cancel logic
            if checkhover(newx, newy, xbutton) then
                uipointer = "click"
                if clicked then 
                    xbutton.action()
                    -- don't callback, just change the values here?
                end
            end
            -- rotate logic
            if clicked then
                local deltax = (oldx - newx) / 180
                local deltay = (oldy - newy) / 180
                mdl.rot = vecadd(mdl.rot, vec(deltay, deltax, 0, 0))
            end
            oldx = newx
            oldy = newy
            yield()
        end

        -- go back / zoom out
        zoommesh(mdl, posb, posa, mdl.rot, rota)
    end

    return function()
        coevent = cocreate(cofunc)
    end
end

function zoommesh(mdl, posa, posb, rota, rotb)
    local poslerp = lerp:new()
    local rotlerp = lerp:new()  -- should use slerp, but saving tokens!
    poslerp:commence(posa, posb, 1)
    rotlerp:commence(rota, rotb, 1)
    while not poslerp:isfinished() do
        mdl.pos = poslerp:progress()
        mdl.rot = rotlerp:progress()
        yield()
    end
end

--lerp--
lerp = {}
lerp.__index = lerp

function lerp:new()
    local c = {}
    setmetatable(c, lerp)
    c.posa = vec(0,0,0,0)
    c.posb = vec(0,0,0,0)
    c.start = 0
    c.lerptime = 0
    c.percent = 1.0
    c.fin = 1.0
    return c
end

function lerp:commence(posa, posb, t)
    self.start = time()
    self.posa = posa    -- {x=posa.x, y=posa.y, z=posa.z, w=posa.w}
    self.posb = posb
    self.lerptime = t
    self.percent = 0.0
end

function lerp:progress()
    if (self.percent < self.fin) then
        local tpassed = time()-self.start
        self.percent = tpassed / self.lerptime
        self.percent = min(self.percent, self.fin)
        return self:lerp(self.posa, self.posb, self.percent)
    end
    return self.posb
end

function lerp:isfinished()
    return self.percent >= self.fin
end

function lerp:lerp(a, b, t)
    --return (1-t)*a+t*b
    lx = (1-t)*a.x+t*b.x
    ly = (1-t)*a.y+t*b.y
    lz = (1-t)*a.z+t*b.z
    return {x=lx, y=ly, z=lz, w=0}
end

-- button "class"

function initbutton(x,y,size,onclick)
	local b = {
		x0=x,
		x1=x+size,
		y0=y,
		y1=y+size,
		enabled = true,
		action = onclick
	}
	return b
end

function initbuttoncenter(x,y,size,onclick)
	return {
		x0=x - size/2,
		x1=x + size/2,
		y0=y - size/2,
		y1=y + size/2,
		enabled = true,
		action = onclick
	}
end

function checkhover(x,y,b)
	return x <= b.x1 and x >= b.x0
		and y <= b.y1 and y >= b.y0
end

-- Mouse wrappers

function enablemouse()
	poke(0x5f2d, 1)
end

function getmousepos()
	return stat(32)-1, stat(33)-1
end

function mouseclicked()
	return stat(34) > 0
end

-- Debug functions

function debugbutton(b)
	rect(b.x0,b.y0,b.x1,b.y1)
end

function mouseposition(x,y)
	print(stat(32)-1 .. " " .. stat(33)-1, x, y, 7)
end

-- idea for a later date
--		moving mouse with the keyboard / gamepad?

-- draw icons in code, save on sprite space

function drawmouse(id, x, y)
	if     id == "point" then drawpointer(x, y)
	elseif id == "click" then drawhand(x,y)
	elseif id == "grab"  then drawgrip(x,y)
	elseif id == "exit"  then drawwalk(x,y)
	end
end

function drawpointer(x,y)
	rect(x+1,y+5,x+4,y+6, 1)
	rect(x+1,y+1,x+2,y+5, 7)
	rect(x+3,y+3,x+4,y+4, 7)
	rect(x,y+1,x,y+5, 1)
	line(x+1,y,x+5,y+4, 1)
	pset(x+3,y+6, 7)
end

function drawwalk(x,y)
	color(1)
	rect(x+3,y,x+4,y+5)
	rect(x+1,y+3,x+6,y+3)
	pset(x+1,y+4)
	pset(x+7,y+2)
	pset(x+5,y+1)
	rect(x+1,y+6,x+2,y+6)
	rect(x+6,y+7,x+7,y+7)
	pset(x+1,y+7)
	pset(x+5,y+6)
end

function drawhand(x,y)
	drawgrip(x,y)
	color(1)
	rect(x+1,y+1,x+3,y+3)
	pset(x+2,y)
	color(7)
	rect(x+2,y+1,x+2,y+3)
end

function drawgrip(x,y)
	color(1)
	rectfill(x+0,y+3,x+7,y+5)
	rect(x+1,y+6,x+7,y+6)
	rect(x+2,y+7,x+6,y+7)
	pset(x+2,y+2)
	pset(x+4,y+2)
	pset(x+6,y+2)
	color(7)
	rectfill(x+2,y+4,x+6,y+5)
	rect(x+3,y+6,x+6,y+6)
	rect(x+3,y+7,x+5,y+7)
	pset(x,y+4)
	pset(x+1,y+5)
	pset(x+2,y+3)
	pset(x+4,y+3)
	pset(x+6,y+3)
end

function drawclose(x,y)
	rect(x,y,x+7,y+7, 7)
	rectfill(x+1,y+1,x+6,y+6, 8)
	line(x+2,y+2,x+5,y+5, 7)
	line(x+2,y+5,x+5,y+2, 7)
end

-----------------
-- screen wipe --
-----------------

function startwipe(seconds, reverse, callback)
    local starttime = time()
    local endtime = time() + seconds
    local flip = reverse and 1 or 0
    return function()
        while (time() <= endtime) do
            local percent = (time() - starttime) / seconds
            screenwipe(percent + flip)
            yield()
        end
        if callback then
            callback()
        end
    end
end

function screenwipe(percent)
    color(0)
    local resolution = 128
    local x1 = (resolution * percent)-(resolution)
    local x2 = resolution * min(percent,1)
    rectfill(x1,0,x2,resolution)
end

function forceidle(seconds)
    local endtime = time() + seconds
    return function()
        while (time() <= endtime) do
            -- spin to win
            yield()
        end
    end
end

function fadeinroom()
    coevent = cocreate(forceidle(.5))
    codraw = cocreate(startwipe(.5, true, nil))
end

function fadeinqueueold()
    -- keep the existing event and play it after the fade-in
    oldevent = coevent
    coevent = cocreate(forceidle(.5))
    codraw = cocreate(startwipe(.5, true, function() coevent = oldevent end))
end

function enterroom(roomid)
    coevent = cocreate(forceidle(.5))
    codraw = cocreate(startwipe(.5, false, function() loadroom(roomid) end))
end

function scenechange(callback)
    codraw = cocreate(startwipe(.5, false, callback))
end

function _draw()
    -- acts as a "late update" for screen / post processing effects
    -- main drawing code is inside the update loop
    if codraw then
        coresume(codraw)
        if costatus(codraw) == "dead" then
            codraw = nil
        end
    end
end

-- Memory management : work ram 0x4300 to 0x5dff [inclusive]
-- 6,912 bytes of data, just using each byte for individual flags
-- If extra space is needed, I can use each individual bit instead.

function setmemflag(id)
    -- 0x4300 = 17152
    poke(17152 + id, 1)
end

function getmemflag(id)
    -- 0x4300 = 17152
    return peek(17152 + id) > 0
end

function clearmem()
    -- only use when the opening cart starts up!
    memset(0x4300, 0, 0x1b00)
end

function loadroom(roomid)
    -- if on bbs, add the hashtag
    if (stat(101) != nil) or (stat(102) != 0) then
        cls() -- fixes a bug where the screen flashes on the bbs version
        roomid = "#" .. roomid  -- bbs version
    end
    load(roomid, "previous room")
end

function restart()
    loadroom(rooms.title)
end

function addtitlemenu()
    menuitem(1, "back to title", restart)
end

-- flags to keep track of
-- wrap this into a function to stop editing?
flags = {
    clock   = 0,
    keypada = 1,
    keypadb = 2,
    lamp    = 3,
    chess   = 4,
    queen   = 10,
    knight  = 11,
    bishop  = 12,
    pawn    = 13
}

-- room cart ids
rooms = {
    title   = "thyef_title",
    foyer   = "thyef_foyer",
    lobby   = "thyef_lobby",
    study   = "thyef_study",
    hallway = "thyef_hallway",
    bedroom = "thyef_bedroom",
    keypad  = "thyef_keypad",
    chess   = "thyef_chess",
}


------------------------------------
-- the title cart (or room) has the 
-- important job of resetting 
-- memory so the game can reliably 
-- swap from cart to cart.
-- it doesn't follow the game's
-- logic / render loop, since it 
-- was easier to setup each scene's
-- special logic this way.
------------------------------------

function _init()
    -- setup game
    clearmem()
    -- setup 3d
    projection = matperspective(90, .1, 100)
    sunview = vec(0.6, -.5, -.65, 0)
    -- enable mouse
    poke(0x5f2d, 1)
    -- setup title
    lockout = false
    currentscene = nil
    inittitle()
end

function _update()
    -- i should be using coroutenes ("coevent" variable) 
    -- for consistency sake, (as used in the main gameplay logic)
    -- but this quicker to implement for a single cart, and I can
    -- reuse logic for the fades.
    currentscene()
end

---------------
--title scene--
---------------

function inittitle()
    -- setup menu background
    palt(14, true)
    palt(0, false)
    mesh = mesh:new(diamondverts, diamondindices, vec(0,-.5,3,0), vec(0,0,0,0))
    currentscene = titlescene
    music(0)
end

function titlescene()
    -- logic for clicking the start button --
    local uipointer = "point"
    -- custom init for a rectangular button
    local startbtn = {
        x0=54,
        x1=74,
        y0=119,
        y1=125,
        enabled = true,
        action = (function() enterinput("0") end)
    }
    -- exit condition
    if checkhover(stat(32)-1,stat(33)-1, startbtn) then
        uipointer = "click"
        if mouseclicked() and not lockout then
            lockout = true
            scenechange(function() initdoorscene() end)
        end
    end
    ------------------
    -- render title --
    ------------------
    cls(7)
    -- draw logo
    spr(0, 8, 8, 14, 3)
    print("a pico8 adventure", 34, 8+26, 6)
    print("a pico8 adventure", 33, 8+26, 0)
    -- draw diamond / 3d objects
    mesh.rot.y = .5 + time() / 6
    local mvp = matmul(projection, mesh:getmodelmat())
    local outmvp = getoutlinemodelmat(mesh, 1.05)
    -- since i removed the actual triangle clipping for preformance reasons,
    -- (and it isn't needed for static screens), i hard coded it for the menu.
    local clip = mesh.rot.y % 1
    if clip > .4 and clip < .9165 then
        sunview = vec(1, 1, 1, 0)   -- force shadows
        drawmesh(stand_shadowverts, stand_shadowindices, mvp)
        sunview = vec(0.6, -.5, -.65, 0)    -- turn lights back on
    end
    drawmesh(standverts, standindices, mvp)
    drawoutline(mesh.vert, mesh.index, outmvp)
    drawmesh(mesh.vert, mesh.index, mvp)
    -- draw start button
    rect(54, 119, 74, 125, 7)
    rect(53, 120, 75, 124, 7)
    rectfill(54, 120, 74, 124, 6)
    print("start", 55, 120, 0)
    -- render mouse
    drawmouse(uipointer, getmousepos())
end

function getoutlinemodelmat(m, scale)
    -- outline mvp
    local translation = mattranslation(m.pos.x, m.pos.y, m.pos.z)
    local rotation = matrotate(m.rot.x, m.rot.y, m.rot.z)
    local scale = matscale(scale, scale, scale)
    local transform = matmul(translation, rotation)
    transform = matmul(transform, scale)
    return matmul(projection, transform)
end

--------------
--door scene--
--------------

function initdoorscene()
    -- stop music
    music(-1, 300)
    -- setup letter, reuse mesh object
    mesh.pos = vec(.5,30,3,0)
    mesh.rot = vec(.25,0,.2,0)
    -- remove font transparency
    palt()
    -- setup door pallet
    pal()
    pal( 2, 128, 1)
    pal( 3, 129, 1)
    pal( 8, 130, 1)
    pal( 9, 132, 1)
    pal( 10, 133, 1)
    pal( 11, 134, 1)
    pal( 12, 135, 1)
    pal( 14, 141, 1)
    -- play foot step sfx
    sfx(0)
    cls()
    fadeinroom()
    lockout = false
    currentscene = doorscene
end

function doorscene()
    -- exit condition
    if mesh.pos.y <= -12 and not lockout then
        lockout = true
        scenechange(function() inittextscene(drawexposition1) end)
    end
    -----------------
    -- render scene
    -----------------
    cls()
    -- draw bottom half of door (rows 5 to 13)
    spr(112, 0, 44, 16, 9)
    -- draw letter
    mesh.pos.y -= .25
    local mvp = matmul(projection, mesh:getmodelmat())
    drawmesh(letterverts, letterindices, mvp)
    -- draw top half of door    (rows 1 to 4)
    rectfill(0,0,128,32,0)
    spr(48, 0, 12, 16, 4)
    rectfill(0,12+104,128,128,0)
end

----------------------
-- exposition scene --
----------------------

function inittextscene(scene)
    cls()
    fadeinroom()
    lockout = false
    currentscene = scene
end

function drawexposition1()
    cls(0)
    print(introtexta, 0, 0, 7)
    drawmouse("click", getmousepos())

    coresume(coevent)
    if costatus(coevent) == "dead" and mouseclicked() and not lockout then
        -- fade finished and player clicked to continue
        lockout = true
        scenechange(function() inittextscene(drawexposition2) end)
    end
end

function drawexposition2()
    -- quick fix / copy paste to render second page...
    cls(0)
    print(introtextb, 0, 0, 7)
    drawmouse("click", getmousepos())

    coresume(coevent)
    if costatus(coevent) == "dead" and mouseclicked() and not lockout then
        -- fade finished and player clicked to continue
        lockout = true
        scenechange(function() startgame() end)
    end
end

function startgame()
    pal()
    cls()
    loadroom(rooms.foyer)
end

--8>
--data

diamondverts = {vec(0.000000,-0.697250,0.000000),vec(-0.679974,0.038286,-0.523643),vec(0.320011,0.038286,-0.848563),vec(0.938051,0.038286,0.002077),vec(0.320011,0.038286,0.852717),vec(-0.679974,0.038286,0.527797),vec(-0.224578,0.447215,-0.691194),vec(0.587967,0.447215,-0.427178),vec(0.587967,0.447215,0.427178),vec(-0.224578,0.447215,0.691194),vec(-0.726771,0.447215,0.000000),vec(0.000000,0.750824,0.000000)}
diamondindices = {1,{1,2,3,1,4,5,2,6,11,3,2,7,4,3,8,5,4,9,6,5,10},14,{2,1,6,1,3,4,1,5,6,2,11,7,3,7,8,4,8,9,5,9,10,6,10,11,7,11,12,8,7,12,9,8,12,10,9,12,11,10,12}}

standverts = {vec(-1.000000,-3.102322,1.000000),vec(-0.879311,-0.756051,0.879311),vec(-1.000000,-3.102322,-1.000000),vec(-0.879311,-0.756051,-0.879311),vec(1.000000,-3.102322,1.000000),vec(0.879311,-0.756051,0.879311),vec(1.000000,-3.102322,-1.000000),vec(0.879311,-0.756051,-0.879311),vec(-1.000000,-0.756051,1.000000),vec(-1.000000,-0.756051,-1.000000),vec(1.000000,-0.756051,-1.000000),vec(1.000000,-0.756051,1.000000)}
standindices = {15,{6,4,2,6,8,4},5,{12,9,1,11,12,5,11,5,7,12,1,5},6,{10,11,7,9,10,3,9,3,1,10,7,3},9,{4,9,2,8,10,4,6,11,8,2,12,6,4,10,9,8,11,10,6,12,11,2,9,12}}

testverts = {vec(-17.000000,-3.102322,1.000000),vec(-17.000000,7.243949,1.000000),vec(-17.000000,-3.102322,-1.000000),vec(-17.000000,7.243949,-1.000000),vec(-15.000000,-3.102322,1.000000),vec(-15.000000,7.243949,1.000000),vec(-15.000000,-3.102322,-1.000000),vec(-15.000000,7.243949,-1.000000)}
testindices = {5,{6,2,1,8,6,5,8,5,7,6,1,5},6,{4,2,6,4,8,7,2,4,3,2,3,1,4,7,3,4,6,8}}

stand_shadowverts = {vec(-1.000000,-3.102322,-1.000000),vec(1.000000,-3.102322,1.000000),vec(1.000000,-3.102322,-1.000000),vec(3.000000,-3.102322,-4.000000),vec(5.000000,-3.102320,-2.000000),vec(5.000000,-3.102320,-4.000000),vec(5.031185,-3.153605,-4.019624),vec(7.638683,-3.094958,-3.481203),vec(6.528873,-3.094958,-4.848554),vec(5.196313,-3.094958,-6.530750),vec(7.822358,-3.094958,-4.759907),vec(6.595841,-3.094958,-6.291339),vec(7.652802,-3.126959,-6.114635)}
stand_shadowindices = {7,{3,6,4,3,2,5,3,5,6,3,4,1,7,8,9,7,9,10,9,8,11,10,9,12,9,11,12,12,11,13}}

letterverts = {{x=1.187039,y=-0.004535,z=0.562117,w=1},{x=1.187039,y=-0.004535,z=-0.811961,w=1},{x=-1.187039,y=-0.004535,z=0.562117,w=1},{x=-1.187039,y=-0.004535,z=-0.811961,w=1},{x=-0.125000,y=-0.007548,z=-0.119853,w=1},{x=-0.088388,y=-0.007548,z=-0.031464,w=1},{x=0.000000,y=-0.007548,z=0.005147,w=1},{x=0.088388,y=-0.007548,z=-0.031464,w=1},{x=0.125000,y=-0.007548,z=-0.119853,w=1},{x=0.088388,y=-0.007548,z=-0.208241,w=1},{x=0.000000,y=-0.007548,z=-0.244853,w=1},{x=-0.088388,y=-0.007548,z=-0.208241,w=1},{x=-0.088388,y=0.013905,z=-0.031464,w=1},{x=-0.125000,y=0.013905,z=-0.119853,w=1},{x=0.000000,y=0.013905,z=0.005147,w=1},{x=0.088388,y=0.013905,z=-0.031464,w=1},{x=0.125000,y=0.013905,z=-0.119853,w=1},{x=0.088388,y=0.013905,z=-0.208241,w=1},{x=0.000000,y=0.013905,z=-0.244853,w=1},{x=-0.088388,y=0.013905,z=-0.208241,w=1},{x=-1.187039,y=-0.004535,z=0.527811,w=1},{x=1.187039,y=-0.004535,z=0.527811,w=1},{x=0.000000,y=-0.004535,z=-0.124922,w=1},{x=-1.187039,y=0.009297,z=0.562117,w=1},{x=0.000000,y=0.009297,z=-0.095269,w=1},{x=1.187039,y=0.009297,z=0.562117,w=1},{x=1.187039,y=-0.016398,z=0.527811,w=1},{x=1.187039,y=-0.016398,z=-0.811961,w=1},{x=-1.187039,y=-0.016398,z=-0.811961,w=1},{x=-1.187039,y=-0.016398,z=0.527811,w=1},{x=-1.187039,y=0.009297,z=0.527811,w=1},{x=0.000000,y=0.009297,z=-0.124922,w=1},{x=1.187039,y=0.009297,z=0.527811,w=1}}
letterindices = {6,{4,21,23,25,24,26,23,22,2,2,4,23},7,{22,26,1,22,33,26},9,{19,20,14,7,13,6,12,19,11,10,17,9,8,15,7,6,14,5,5,20,12,11,18,10,9,16,8,14,13,17,13,15,17,15,16,17,17,18,14,18,19,14,7,15,13,12,20,19,10,18,17,8,16,15,6,13,14,5,14,20,11,19,18,9,17,16},5,{21,32,23,1,24,3,23,33,22,3,31,21,28,4,2,29,21,4,27,2,22,31,25,32,25,33,32,21,31,32,1,26,24,23,32,33,3,24,31,28,29,4,29,30,21,27,28,2,31,24,25,25,26,33}}


introtexta = [[
an old fence requested us to
break into a private residence.
ordinarily, we'd pass on such a 
trivial matter to an apprentice, 
or decline it altogether, but, 
this fence is a cherished one. 
plus, the house holds quite the
secret. the mansion seems to
be accommodating the missing 
ashberg diamond!
we have no idea how, or why, but
this is a rare opportunity, and 
it must be seized. the 
proprietor has gone for the 
week, along with most of his 
staff. the few who remain have 
been bribed to stay home for the 
night, and for information, 
reporting that the ashberg is 
unabashedly on display in the 
study.                      1/2
]]

introtextb = [[
the owner, (rightfully so)
doesn't seem to trust his 
employees. the house is fitted 
with odd security measures. 
they've unlocked the door to the
foyer, but getting around is up 
to you solve.
                    - the guild












                            2/2
]]
__gfx__
7000000000000055555556e000060006000065055556e600055000e000050005555e000000000000060555556e000000000000055555556e0000000000000000
60000000000000d005d656e00006500500006050d556e600050050e000050505165e00000000000006015d656e0000000000000d005d656e0000000000000000
7000000000000060555565e00006005d00006055555de6000500056000050050556e000000000000055505565e000000000000060555565e0000000000000000
6000000000000065155556e000060005000070051565e600050500e000055005055e000000000000055555d56e000000000000065155556e0000000000000000
eeeee5000556556566eeeee000060055000060555556e6000050056000050105555e000065656666eeeeeeeeee000065556656eeeeeeeeee0000000000000000
eeeee5000600555556eeeee000060006000065015555e600007005500056565d66ee000050050555eeeeeeeeee000050105555eeeeeeeeee0000000000000000
eeeee5000505105556eeeee0000600050000605055d6ee00005006000070055555ee000050055056eeeeeeeeee000060505156eeeeeeeeee0000000000000000
eeeee5000600551656eeeee000067777000060505555ee600006050000d0555d56ee0000776777776e66e6e6ee00006767777766e6e6e6ee0000000000000000
eeeee5000550505556eeeee000000000000060550555eee0000660000605150656ee0000000000000555555d6e000000000000065555d56e0000000000000000
eeeee5000605051556eeeee000000000000060015d55eee600005000060050555eee000000000000150156556e000000000000060155556e0000000000000000
eeeee5000505055556eeeee000000000000065053065eee600000000500505556eee000000000000555055565e000000000000060555655e0000000000000000
eeeee5000610515556eeeee000000000000060005156eeee50000000650505d5eeee000001000500555555656e000000000000055155d65e0000000000000000
eeeee50005005555d6eeeee000065516000060515555eeee6000000550505136eeee000065565d56eeeeee6eee0000555d5566eeeeeeeeee0000000000000000
eeeee5000650050556eeeee000060005000060051555eeeee000000700505556eeee000050055555eeeeeeeeee0000d0505055eeeeeeeeee0000000000000000
eeeee5000500051556eeeee000060506000065050555eeeee60000051000155eeeee000051050556eeeeeeeeee000050005155eeeeeeeeee0000000000000000
eeeee5000605055556eeeee000060505000060050155eeeeee00006556555d6eeeee0000677676666e66e6e6ee000050500055eeeeeeeeee0000000000000000
eeeee5000500005056eeeee000060006000060505555eeeeee0000700005056eeeee000000000000065055566e000050005055eeeeeeeeee0000000000000000
eeeee5000610501556eeeee000060005000060000515eeeeee500070005000eeeeee00000000000005015d556e000055000155eeeeeeeeee0000000000000000
eeeee5000505050556eeeee000060056000060501555eeeeee000060000050eeeeee0000000000005555555d6e000050050005eeeeeeeeee0000000000000000
eeeeed000655d3d556eeeee000065556000061555555eeeeee5050755551556eeeee000000000000555565566e0105d55555d5eeeeeeeeee0000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb55bbbb5bbbb525522bb5bbbbbbbb5b5b5555b5bbb5bbb5b5555bbbbbbb5bbbbbbbbbbbabbbbbbb5559555555555b52a2555555555555555522202922999999
5b5bbbbbbbbb5525522bb5b5b55b55555bb55bb55bb555b5b55b5bbbbbbbbbbbbbbbbb525bbbbbbbb555555555595b2dab555b55595555555222222922999999
5b5552bbbb5bb52a5a15b5bbbbbbbb5bbbbbbb5555bbb5b5b5555b5bbbb5bbbbbbbbbbba5b5bbbbb5b555555555a5b2d555b5555555555595222222922999949
b555555bbb5b55215a5555bb5bbb555bbbbbbb5555bbbb55bb5b55b555b5bbbbb5bbbb5a5bbbbbbb555555555555ab22555b55555595595222a2222922999999
bbbbb5b5bb555531525b52b5bb5b5bbbbbbbbb55bbbbbb55b5555b55555555bbbb5bbb5abbbbbbbb55555555555a2b25955b555555555555a5a2222922999499
55bb5b5555bb55235225b2b55bbbb5bbbbbb5b5b55bb55b5b5b55555b555555b5555555a555b55555555555555525b2a555b55559955555552a2222922999999
55b55555555bb5aab22bb25bb55b5bb55bbbb5555b55b55555555bb5bb55bb5bbbb5b555ab5bbb555bb55b555555552a555b555552555555555a222922999999
55aa255555555525525bb5b55bbbbb55bbbbb5555b555555555555a55a111111111111111111111111111130aaa5552a555b55555555555552a2222922999999
1131111111111bb0555b55b5bbb5bb55bb5b55555b5b555b5555555555523002222222200002200222a3303055555aa55a5b5b55555552225222202922999999
0a2aaa3022aa555b2aabb5b5bb5bb55bb555b5555b5b55b555bbbbbbbb5a55555555a55a5555555b5553111a55bbbbaa55555555555555952222222922999999
33330a5555522a55aa2bb2bbbbbb5b595bb5555555bb55b55b5bb5bbbb5555555555555555a1d11edadeaaa222522a2225555bbbb55555552522222922999999
111aa222222a55aa5a55b5bbbbb5bbbb5bbb5b5b5bbbb5b222a222202222222202022222222220200202222222022a2aa5555b5b555555552222202922999999
a000020000000200200055bbbbbbbbbb5b55bbbbbbbbb5b52000222222200000000000202222222a522555aa5bbbb555225bb555555555222522222922999999
55555555555555b55555555555555555555555555555555555bbbbbbbbbbbbbbbbbb5bbbbbbbbbbbbbbbbbbbbbbb5555b55bb5555b5555252222222992999999
555555555555555555555bbbbbb5b5555b55bb5555595555bb5b55bbbbbbbbbbbb6b6bb55bbbbbbbbbbbbbbbbbb55555555b5555b55555522225222922999999
55555555555555555bbbbb5bbbbb5bbbbbbbbbb5bb5555b55b55555b5bbbbbbbbbb6b6666bbbbbbbbbbbbbbbbbbbb5bb555b55555b5555552a22222992999999
5b5555bb5b55555b5bb55bbbbbbbbbbb5bbbb5bbb555555b5bbbbbbbbbbbbbbbbb5bbb665bbbbbbbbbbbbbbbbbbb55bb5555b5555555b5525522222992999999
55555b55b5555555b5b55b555b5bbbbbbbbbbbbbbb55bbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5555b55b555555525522222992999999
bb5bb555555b5bb5b5555bbbb5b55bbbbbb5bbbbbb5bbb55bb5bbbb5b55bbb555bbbbbb55555b555bbbbb5bbbbb5555555aa5555555555552522222992999999
55955b555bbb5b5555555bbb5bb55bbbba555555b5b5b55555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba5555555552522222992999999
555555bb5bbb5bbb5555bb555bbbbbbbba2cccccbcbccbbbccbbbcccbcccbbbcbbccbcccbcccccccbbccbbccccccccccccccccab55b555552522222992299949
5555555bb55bbb5bbb5bbbbbbb55555bba5c5bccbbbcbbbbbbbbbbbbbbbbb5bb55b55555b55bb55555555555bbbbbbbbbcc2bcab555555552222222992299949
5555bb555bbbb5b5bb55bbbb5b555b5bba5c5cc0020200200022222222222222002222522222225222522222555525525bcccca55555555a2222222992299999
5555555555bbb5b5b5bbbbbbbbb555555a5cccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccca55555555a22aa222992999999
55bb5b55bbb5b55b5b5bbbbbbbb55b55b55cccbbbbbbcccbbbbbbfbbbbbbbbbbbbcccccccccccccbbbbbbbbbbbbbbbbbb5bccca555a525552222222992999999
5555b55555bbb5b555bbbbbbbb5b5555555ccbbbccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbccab552555552a22222992299999
bb55555b5bbbbbbbbb5bbbb5bb555b5b5a5ccbbbccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbccab5552555a522a202992999999
555bb5bbbbb5bbbb5bbb5b5b555b55b5555ccbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbccab5555552a2222222992299949
555b55bbb55555bbb5bbb5555bbb555b555ccbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbccab55555a552522222992999999
b5bb555b55aaa55bb5595555b55555555a5ccbbccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbcca5555225552222202992299999
bb55555555b5b5bb55555b555555b5b55a5cbbfcccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbcca5555555552222202992299949
5555555555555bbb55b55b5b555bbbb55a5cbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccfbbbccab555555552522222992899949
5b5bb5bbbbb5bbbb555b5555bb5b5bb5ba5cbbbbccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbccab55552a522222222992299999
b55bbb555bbb5bbb555bbb5bbbb55555525cbbbbbbbbbbbbbbbbbbbbbfbbbbbbbbbbbbbbbbbbbffbbbbbbbbbbbbbbbbbbbbbccab525522552a22222992899949
55b5b55555555bbb55555b55b5b5bbb5b2bc55022222222222222222222222222202200222222000222000000222020000b55ca55525229a2222222992299999
55555555555555b5555555bbbb55b5bbb2bc2b22525555555bbbbbb5b5bbbbbbbbbbb55555555555555555bbbbbb5b55bbbbbca5559255a25222222992999999
55595299555555555555555bb5bbbbb552bcccbbbbbbbbb55bbbbb55bb5bb555555555555555555555555555555555555555bba5555555522222222992299999
55555559555555555a55555555552595522222222220000020000000000000000000000000000000000000000000000000000025552229222222222992299949
2252255555b55555255555555555555995a55555555555555555bbb55b555555555555555555555555555555555555b555255555555aa252a222222992299999
5555555555bb5555555555bb5555555bb5b55b55555555bbb5bbbbbbb5b55555bb55555555b5b55555b555555555bb55bba55555b59555523122222992299949
5b55b5bb5bbbb5bbbb5bbbbbbbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbb5b55bb55b5555bbbbbbbbbbbbbbbb255555b55555aaaa22222992299949
5bb55b5bb5b5bbb5bbb5b5555bb5bbbbb5bbbbbbbbbb5b5bbbbbbbbbbbbbbbbbbbbbbb5bbbbb55b55bbbbbbbbbbbbbbbbb5b55555555552a2222222992299999
555b555555555555bbbbbbbbbbbbb5bbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbbbbbbb5bbbb5b5b55555b55555a2222222992299999
bb5bbbbbbbbbbbbb5bbbbbb555bbbb5b5bb5bbbbbbbb5bb55bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5b55555555555552a2222992299999
bbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5555555555bbbbbbbbbb5bbbbbbbbbbbbb5bbbbbbbbbbbbbbbbbbbbb5bb555bb5555555252522992299999
bbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5b5555bbb5555552a5522992299999
bbbbbbbbbbbbbbbb5bbbbbbbbbbbb5220225bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbb55b5bbb5bb55555b599559a5aa22992299999
bbbbbbbbbbbbbbbbbbbbb52830020333333025002bbbbbbbbbb5bbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbb55bbbb5b55bb55555555555555aa22992299999
5555555a555aa222222aa2025aaaaaa2aa2252aa25a52550000000000000000002222222220000020a20022002222002525b5b55b5555555255aa22992299994
20000000000000025bb2555925255555225555555555b5055555555555555555555a5aa2255555aa5a25555555bb555555bb555bb5555555555a522992999999
bbbbbbbbbbbbbbbbb55555555555b5555555b5555555552bbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbb5bb55bbbb5555555555555222992299999
22555522255a2222255ba5555b55555bbbbbb5bbbb5b552555555252225202222222a222225a5a55555525555225522bbb5b5b5555555555555aa22992299949
a220000000000025055b555b555b5b5bbbbb55bbbb5bbb25b2000000000000000000000000000000000000000000002bb55bbb55555555555252a22992299999
0000000000000220255b5bb5b5555b55b5b55b5b5b55bb5bbb00000000000000020000000000000000000000000020a5bb5bbb555555b5555522222992299949
55555555bbbbbb22255b25b5bb5b5b5b5bb55bbbb55bbb5bbbb52a2225525255a555552555a52522222225552222bba5b55bb55555b555552522222992299999
222225552552225525b52b5b5bb55bbb5bbbbbbbbbbbbbbbbbbb222222222222225a22222aa55555525552a22aaabb555b5bbb55555b55552522222992299999
000000050000025b255b5bbbbbbbbbbbbbbbbbbb5bbbbbbb5bbb500000000000000000000000000000000000000555a5bb5b5b5b555555952522222992299949
000000022200005b25bb5bbbbb5bbbbbbbbbbbbbbbbbbbb5b5bb5bbbbbbbb55b52555b55555555b55b555b555555bb55bbbbbbbb555555522522222992299944
225555555b5222bb25bb5bbbbb5bbbbbbbbbbbbbbbbbbb2b5bbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bb55b55bbbbbbb5555559aa2222992299994
5bbb2b5bbbbba25b25bb55bbbbbbbbbbbbbbbbbbbbbbbbb5b5bb5b55bb5ba5b5555bb55b555555bba555bbbbbb555ba5b55b555b55b555555522222992299999
5bb5555bbbbb52bb25bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5b5b5b555555555b555b55b55b5555b55b55bb5b5b5b5555abb55b555555522522222992299994
55555555bbbb52bb25bb5bbbbbbbbbb55bbbbbbbbbbbbbbbb55b5b55bbbbbbbbb5b5b5b55bbbbbb5bbbb225b5b555b55b55bbb5b555555552222222992299999
5bbbabbbbbbb52bb255bbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbb5bbbbb200000000000000000000055bb5bbbb55b55bb5bbb55555555525a25222992299999
5bb5abbbbbbb52bb25bbbbbbbbbbbbbbbb5bbbbbbbbbb5bbb5bb5b5b555a0000002202202022020000ab5b5bbb555b55bb5b5b55555555555522a22992299994
bbbb2bbbbbbb52bb25bbb5bbbbbbbbbbbbbbbbbbbbb55b5bbbbb5b5bb5ba025aa5a55555a555555520a55bbbbb555b55bb5b5bbbb5b555555522222992299999
5bbba5bbbb5b52b5255bb55bbbbbbbbbbbbb5bbbbb5555bb5bbb5b5bbbbb22b555a55555255555ba2abb55bbb5b5bba55b5b55b555b555522222222992299999
55b55b5bbbbb52b525bbb55bbbbbbbbbbbbb5bbbb5555b5bbbbb5bbbbb5bb52aa22aa5aaa25a5a255bb5bb5bb5b5bb555b5b5b55b55555522522252992299999
bb555bbbbb5b52b525bb55bbbbbbbb555bbbb5bb55b55555bbbbbbbb5bbbb5b5b5b5bb555b55bbbb55bb5bbbb5b55b555b5b555b55555522252a222992299999
bbb5bbbbbbbb52bb25bb555bbbbbbb55bbbbb55bbbbb55bbb5b5bb55055555b555bb55bbb55b5bbbbbbbbbb5bbb5bb555bbb555b555555555522220992299999
bb55bb55bbbb52b525bb55bbbbbbbbbb5bbb55555b555b55555bbbb5bbbbbbbbbb5bbbb55bb5b55b5555555bbbb5bb5bbb5b5555555555525a2a222992299999
b552bbb5552b52b525bb555bbbbbbbbb5bbb555555b5555555555bba222a2552222222202222525552222255bb25bb55b5555555b55555552252220992299999
bb525bb5555b52b525bb5555bbbb5bbb5bbbb55b55b55555555bbbb5bbbbbbbbb5555555bb55bb5bbbbbbbb5bb55bb555ba55b5bbb5555522522222992299999
bbba55b5555b52b525bb55bbbbb55bbbbbbbbb55b5b55b5555bb5bbbbbbbbbbbb5bbbbbbbbb5bb5bbbb5bbbbbb555b5555a5555555555552252a222992299994
bb555bbb5b5b52b525b55bbbbbbbbb5bbb5bbb5b5b5b5b5555555bbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbbbbb55ba55b55b5b55b5555525925222992299994
b5525b55bbb552b525bb5bbbbbbbbb5bb5bbbbbb55bbbb55555b5bbbbbbbbbbbbb5bbbbb5bbbbbbbbbbbbbbbbb555b555555b55555555552522a220992299999
55555555bbb552b525b55bbbbbb5bbbbbbbbbb5b55bb5555555b5bbb5bbbbbbbbbbbbbbbbbb5bbbbbbbbbbb5bbb5bba55b55555555555552522a220292299999
b55abb55bbb552b525b5b5b5bb55bbbbbbbbbb55bbbbbb55b5bb5b5bbbbbbbbbbb5bbbbb5bb5bbbb5bbbb5bb5b555ba55b5b55555b5555525222222292299999
b5555555bbb555b525bb55bbbb555b55bbbbbb55bbbbbb55b55b5bbbbbbbbbbbbb5bbbbbbbbbbbbb5bb55bbbbb555ba55b5bb555555559225522222292229999
55555bbbbbb552b525bbbb5bbbb55bb5bbbbbb5bbbbb5b55555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bb55ba55b5bb555b55555a22522222292299999
bb525555bbbb52b5a5b55bbbb5b55555bbbbbbb5b5bbbb5555bb5bbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbbb555b55b52bb555555555552222522292299994
5bb55555bb5b55b5255bbb5b55555b5bbbbbbbb5bbbbb5555bbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bb5555ab55555555555252a2a22292229999
b552bbb5bbbb55b525bbbbb55bb5bb5b5bb5bbb55bb5bb5555bb5bb5bbbbbbbbbbbbbbbbbb5bbbbb5bbbb5bbbb555b555b5555555555555555a22a2292299999
5552bbb5bbb555b52bb5b555b555bb5bbbbbbbb5b5b5b55555bb5bbbbbbbbbbbb5bbbbbbbbbbbbbbbbbb5bb5bbb55b555b555555555555555522aa0292229999
bb525bbbbb5555b5abb555b5bbb55b5b5b5bb5b555bb5b5555bb5b5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbb5555b555b5b55555555555555222a2292229999
bb55bbbbbb5555b55bb5555bbb555bb5bbb55bb5b5bbbb5555bb5bbbbbbbbbbbbbbbbbbbbbbbbbb5bbb555b5bb555ba55b555555555555555225522292229999
bb55bbbbbbb555b55bb555b5bbb55b55b5555bb555b5b55555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5555bbb555ba55b55555555555555522a222299229994
bb5bbbbbbbb555b5a5b5b5b5b5b5b555b555bbb555555b55555b5b5bbbbbbbbbbbbb5bbbbbbbbbb5bbbb5bbbbb555ba55b5b5555555555555522a22299299994
b555bbbbbbb555b55bbb5b55b5bb5b55b555bb555555b5555b525bbbbbbbbbbbbbbbbbb5bbbbbb55bbbb55b5bb555ba55b5b5b555555555aaa2aa22299229999
bb5bbb5b5b5555b55bb55b5bbbbb5bb5b555bb5555b55b555b555bbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbb5555555b5b555b5555555aa22aa22299229999
5b5bbbb55bb555b55bb5bb5bbb5bbb555555bb5b55b55b555b5b5bb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba5b555b5bb555b55555555222a22299229999
5b5bbbbbbbb555b55bb5bb5b5555b5555b55b5555bb55b555b5b5bb5bbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbbb55ba55b5b55555b5555255aaa222299229999
5b2bbbbbbb55555a55bbbb5bb5b555555b55b55b55b55ba555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbba5ba5555bb55555555555255a2a2299229999
b52bbb5bbbb5555a5bb5bbb5555555555555555b5bb5bba55b5b5bbb5bbbbbbbbbbbbbbb5b5bbbbbbbbbb5bbbbba5b555555b5b5555552525552222292229999
bb5bbbbbbbb5a5b55bb5bbbb555555555555555b5b555b555b5b5bbbbbbbbbbbbbbbbbbbbbbbb5b5bbbbbbbbbbba5ba555abbbb5555555222552222299229999
bb55bb5b5b552bb55bb5bbb5555555555bb55b555b5b5b555b5b5b5bbbbbb5bbbbbbbbbbbb5bbbbbbbb55bbbbbba5b555babbb5555555a2522a22a2299229999
b55bbbbbbbb5a5ba5bb5bbb5b555bb55bb55555b5b555b55555b5bbbbbbbbbbbb5bb5bbbbbbbbbbbbbbbbbbbbbb25b5555a5bbb5555555255a2aa22299229999
b55b5bbbbbb5a5b25bb5bbbbb555bb55555555555b5b5b5555555bbbbbb55bbbb5bbbbbbbb5bbbbbbbbbbbbbbbba5b555555bb55525555225522522299229999
b55bbbbbbbb5ab5255b5bbbbbb55bb555bb555525b555555555b5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555b5a5b25b5b5555552225aaa522299229999
5555bb555bb52b525bb5bbbbbb55bb555b55555555555b25555b5bbbbbbbb5bbbbbbbbbbbb5bbbbbbb5bbbbbbbb55b5a55a5bbb5555525255252522299229999
5555bb555bb52bb25bbbbbbbb55b5b555555955555555555555b5bbbbbbbb5bbbbbbbbbbbb5bbbbbbbbbbbbbbb555b525555bbb55555522552aaaa2299229999
b552bb55b5b5abb25bb5bbbbbbbbbb555555955555555525555b5bbbbbbbbbbbbbbbbbbbbb5bbbbbbbbbbb5bbbba5b225555bb55555552255a2a522299229999
5555bb55bb55abb25bb5bbbbbb55b55555599555525525255b5b5bbbbbbbbbbbbbbbbbbbbbbbbbbb55b5bbbb5b555b2a55555555555559555222522299229999
5555bbb5bb552bb25bb5bbbbbb5bb5555559955555525b25555b5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bb55b525bb5555b255555525252222299229999
b552b5bbb5b525525bb5bbb5555bb555555555b555555b2555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55ba25b5bbb5b555525222222222299229999
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
011000000011300000000000000002113000000000000000001330000000000000000213300000000000000000153000000000000000021530000000000000000010000000000000000002100000000000000000
011000000e5540e5440e5340e5240e515000000000010504000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000052000540005300052010550105401053010524105241051410514105150000000000105040000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000052000540005300052010550105401053010520005500054000530105501054010530075500753000550005400053000520105501054010530105200055000540005301055210542105320755007530
011e00002655500000000000000024555245002450024500265552450024500245002455524500245002450026555245002450024500245552450024500245002655524500245002450024555245002450024000
011000000c7550c755157550c7550c755137550c7550c755157550c7550c755137521375213752137521375200700007000000000000000000000000000000000000000000000000000000000000000000000000
011000001053010524105241051410514105150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200001155500000000001055500000000000e555000000000013555000051355511555000051055500005000050e5551350011500000000000000000000000000000000000000000000000000000000000000
011200001155500000000001055500000000000e555000000000013555000051355513555000051055500005000000e5550000500000000000000000000000000000000000000000000000000000000000000000
011000001a5541a5551850018500185001850021500215001855418555215002150021500215002140018500185001850018500185003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c500
011000000052000540005300052010550105401053010520005500054000530105501054010535075250751500500005000050000500105001050010500105000050000500005001050010500105000750007500
0110000013a5013a5013a5013a5013a5013a5013a5013a500ea500ea500ea500ea500ea500ea500ea500ea5013a5013a5013a5013a5013a5013a5013a5013a500ea500ea500ea500ea500ea500ea500ea500ea50
011000001fa501fa501fa501fa501fa501fa501fa501fa501aa501aa501aa501aa501aa501aa501aa501aa501fa501fa501fa501fa501fa501fa501fa501fa501aa501aa501aa501aa501aa501aa501aa501aa50
0110000013a5313a5313a5313a5313a5313a5313a5313a530ea530ea530ea530ea530ea530ea530ea530ea5313a5313a5313a5313a5313a5313a5313a5313a530ea530ea530ea530ea530ea530ea530ea530ea53
011000000ca000ca000ca000ca000ca000ca000ca000ca0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a0013a000ea000ea000ea000ea000ea000ea000ea000ea00
011000001fe501fe501fe501fe501fe501fe501fe501fe501de501de501de501de501de501de501de501de501fe501fe501fe501fe501fe501fe501fe501fe501de501de501de501de501de501de501de501de50
011000001ae501ae501ae501ae501ae501ae501ae501ae5018e5018e5018e5018e5018e5018e5018e5018e501ae501ae501ae501ae501ae501ae501ae501ae5018e5018e5018e5018e5018e5018e5018e5018e50
011000000052000540005300052004500045000450004500005200054000530005200450004500045000450000520005400053000520045000450004500045000052000540005300052004500045000450004500
011000000ee500ee500ee500ee500ee500ee500ee500ee500ce500ce500ce500ce500ce500ce500ce500ce500ee500ee500ee500ee500ee500ee500ee500ee500ce500ce500ce500ce500ce500ce500ce500ce50
011000001da551ca5500000000000000000000000001ca5500000000001da55000001fa5500000000001ca551aa5510a000ea0005a001da001ca001aa001da001ca001aa00000000000000000000000000000000
011000000006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f9501f9501f9501f950219502195021950219501a9501a9501a9501a9501a9501a9501a9501a9501f9501f9501f9501f950219502195021950219501a9501a9501a9501a9501a9501a9501a9501a950
011000001fe501fe501fe501fe501fe501fe501fe501fe501de501de501de501de501de501de501de501de501fe501fe501fe501fe501fe501fe501fe501fe501de501de501de501de501de501de501de501de50
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
01 0b 0d 43 44
00 0b 0d 43 44
00 0b 0d 0f 44
00 0b 0d 10 44
00 0b 0d 0f 44
00 0b 0d 10 44
00 0c 0d 0f 44
00 0c 0d 15 44
00 0c 0d 0f 44
02 0c 0d 15 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
01 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
