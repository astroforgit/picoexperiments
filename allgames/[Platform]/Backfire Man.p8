pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- a puzzle platformer
-- by sebastian and simon

--objects

legs={}
enemies={}
levels = {}

deaths = 0

current_level = nil
current_level_index = 1
current_level_pickup = false
nr_pickups = 0

bomb = {}
-->8
-- main functions

function _init()
    reset()
    --music(0)
end

  function reset()
    reload()
    ticks=0
    self_explosion_time = 0
    legs = {}
     
    init_level( 0, 0, 32, 16)
	init_level( 32, 0, 16, 16)
    init_level( 48 , 0, 16, 16)
    init_level( 64 , 0, 16, 16)
    init_level( 80 , 0, 16, 16)

    init_level( 0 , 16, 16 , 16)
    init_level( 96 , 0, 32 , 16)
    init_level( 32 , 16, 32 , 16)
    init_level(64 , 16, 16 , 16)
    init_level( 16 , 16, 16 , 16)
    init_level(80, 16, 16 , 16)
    init_level(0, 32, 48 , 16)

    -- CREDITS
    init_level( 112 , 48 , 16, 16)
	current_level = levels[current_level_index]

    local playerx = current_level.x*8 + 12
    local playery = 60
    for y = current_level.y, current_level.y + current_level.height do
        if fget(mget(flr(playerx/8), y), 0) then
            playery = y*8-8
            break
        end
    end

    p1=m_player(playerx, playery)
    p1:set_anim("walk")
    p1.has_legs = true

    cam=m_cam(p1)
    cam.pos_min.x = current_level.x*8 + 64--current_level.x*16+64
    cam.pos_min.y = (current_level.y)*8 + 64

    cam.pos_max.x = current_level.x*8 + (current_level.width*8) -64 --current_level.width+8*6
    cam.pos_max.y = (current_level.y+16)*8 - 64
  
    init_enemies()
    init_pickups()
    init_lamps()
    init_bomb()

    for i=0,6 do
		initparticle(p1.x, p1.y, 1 + rnd(2), 12, rnd(2)-1,rnd(2)-1)
	end
    sfx(16)
    current_level_pickup = false
    resethelp()
 end

 function next_level() 
    sfx(6, -1, 5)
    legs = {}
    current_level_index += 1
    fadestate = 1
    if current_level_pickup then 
        nr_pickups+=1
    end
    reset()
 end

function init_level(x, y, width, height)
	local l={}
	l.x = x
	l.y = y
    l.sx = x * 8
    l.sy = y * 8
	l.width = width
	l.height = height

	add(levels, l)
end

function init_enemies() 
    enemies = {}
    for y = current_level.y, current_level.y + current_level.height do
        for x = current_level.x, current_level.x + current_level.width do
            local spr = mget(x, y)
            if (spr == 80 or spr == 82 or spr == 84) then
                init_enemy(x*8, y*8, spr)
            end
        end
    end
end

function init_pickups() 
    pickups = {}
    for y = current_level.y, current_level.y + current_level.height do
        for x = current_level.x, current_level.x + current_level.width do
            local spr = mget(x, y)
            if spr == 52 then
                init_pickup(x*8, y*8)
            end
        end
    end
end

function init_lamps() 
    lamps = {}
    for y = current_level.y, current_level.y + current_level.height do
        for x = current_level.x, current_level.x + current_level.width do
            local spr = mget(x, y)
            if spr == 56 then
                init_lamp(x*8, y*8)
            end
        end
    end
end

function init_enemy(x, y, spr)
    local l={}
	l.x = x
	l.y = y
    local direction = rnd(1) > 0.5 and 1 or -1
    l.dx = (0.32 + rnd( 0.13 )) * direction
	l.dy = 0
    l.w = 8
    l.h =8
	l.speed = 0
	l.spr = spr

    l.origin_x = x
    l.origin_y = y
    l.path_radius = 16 + rnd(8)

    -- animation
    l.t, l.f, l.s = 0, 1, 8 --tick, frame, step
    l.sp = {spr, spr + 1}

	add(enemies, l)
    mset(x/8, y/8, 16)
end

function init_bomb() 
    bomb.x = -1000
    bomb.y = -1000
    bomb.w = 4
    bomb.h = 4
    bomb.dx = 0
	bomb.dy = 0
    bomb.grounded = false
    bomb.exploded = false
    bomb.thrown = false
    bomb.dead = false
    -- animation
    bomb.t, bomb.f, bomb.s = 0, 1, 8 --tick, frame, step
    bomb.sp = {64, 65, 66}
end

function init_leg(x,y, dx, dy)
	local l={}
	l.x = x
	l.y = y
	l.dx = dx
	l.dy = dy
	l.speed = 0
	l.spr = 2
    l.bloodc = 0

    -- animation
    l.t, l.f, l.s = 0, 1, 2 --tick, frame, step
    l.sp = {67, 68, 69, 70, 71, 72, 73, 74}
    l.w = 8
    l.h = 8
	
	add(legs,l)
end

function _update60()
	ticks+=1
    p1:update()
    update_player()
    update_bomb()

    cam:update()

	foreach(legs, update_leg)
    foreach(enemies, update_enemy)
	foreach(particles, updateparticle)
    foreach(pickups, update_pick_up)
    foreach(floattexts, updatefloattext)
    foreach(bubbles, updatebubble)
    foreach(lamps, update_lamp)

    makebubbles()
	updatewater()
    screentransition()
    showhelpifneeded()
end

function _draw()
	cls(0)
    camera(cam:cam_pos())

    
    inittowers()
    backgroundwave()
    foreach(bubbles, drawbubble)
    map(0, 0, 0, 0, 128, 128)
    foreach(lamps, draw_lamp)
	foreach(pickups, draw_pick_up)
    foreach(legs, draw_leg)

    p1:draw()

	foreach(particles, drawparticle)
    foreach(enemies, draw_enemy)
    foreach(floattexts, drawfloattext)

    draw_bomb(bomb)

    drawtutorial()
    --hud
    camera(0,0)
    if current_level_index == 1 then 
        drawstartscreen()
    elseif current_level_index < 13 then
        printc("level " .. tostr(current_level_index - 1),64,4,7,0,0)
        if current_level_pickup then 
            circfill(86, 4, 3, 12)
            circ(86, 4, 3, 1)
        end
        --print(nr_pickups, 1, 1, 7)
    else
        printc("thank you for playing!",64,42,7,0,0)
        printc("you died " .. deaths .. " times.",64,52,8,0,0)
        printc("you got " .. nr_pickups .. " / 10 crystals!",64,62,12,0,0)
    end

	
	drawwater()
    glitchwhenexploding()
end

-- game functions

function update_leg(l)
    -- gravity
    l.dy += 0.1
   
    l.y += l.dy
    l.x += l.dx

    local oldx = l.x
    local oldy = l.y
    -- cam is centered on player
	if l.x >= cam.pos.x + 64 or l.x <= cam.pos.x - 64 then 
		l.x = oldx
        l.y = oldy
        l.dx *= -0.75
	end

	if l.y >= cam.pos.y + 64 or l.y <= cam.pos.y - 64 then
        l.x = oldx
        l.y = oldy
		l.dy *= -0.75
	end

    if l.y > cam.pos_max.y + 56 then 
        l.dx *= 0.1
        l.dy *= 0.3
    end

    if abs(l.dy) > 0.1 then
        if l.s < 6 then 
            l.s += 0.04
            animate(l)
            if l.bloodc < 3 then
                l.bloodc += 1
            else
                l.bloodc = 0
                initparticle(l.x + rnd(8), l.y + rnd(8), rnd(2), 8, 0, 0)
                if mget(l.x/8,l.y/8) == 16 then 
                    mset(l.x/8,l.y/8, 20+flr(rnd(2)))
                end
            end
        end
    end

    simple_collision(l, 0.1, 1)
end

function update_enemy(e)
     if e.spr == 82 or e.spr == 80 then
        if e.x < e.origin_x - e.path_radius then
            e.dx = abs(e.dx)
        elseif e.x > e.origin_x + e.path_radius then
            e.dx = -abs(e.dx)
        end
    elseif e.spr == 84 then
        local deltaX = p1.x - e.x
        if abs(deltaX > 4) then
            local dir = sgn(deltaX)
            e.dx = dir * 0.4
        end
    end

    if e.spr == 80 or e.spr == 84 then
        e.dy += 0.1
    end

    e.y += e.dy
    e.x += e.dx

    animate(e)

  -- killed by player
   if rectcollision(e, p1)   then
    if e.y > p1.y + 2 or p1.dy >  1 then
        p1.dy = -3.2
        del(enemies, e)
        for i=0, 2 do 
            initparticle(p1.x, p1.y + p1.h/2, 1 + rnd(2), 7, rnd(2)-1, - rnd(3)-1)
        end
        
        sfx(p1.combo % 3)
        p1.combo+=1
        --initfloattext(text, x, y, dir, sp, c1, c2, timer)
        initfloattext(p1.combo .. "X", p1.x, p1.y, 1,-0.3, 12, 13, 40)
    else
        if not p1.has_legs then
            for i=0, 6 do 
                initparticle(p1.x, p1.y + p1.h/2, 2 + rnd(2), 8, rnd(4) - 2, -rnd(4)-2)
            end
            reset()
            sfx(3)
            deaths+=1
            fadestate = 1
            return
        end
        del(enemies, e)
        p1.jump_speed = -0.5
        bomb_jump()
    end
 end

    if not bomb.exploded and rectcollision(e, bomb)  then
        del(enemies, e)
        initparticle(bomb.x, bomb.y + bomb.h/2, 2 + rnd(2), 6 + flr(rnd(2)), rnd(4) - 2, - rnd(3)-1)
        if (bomb.y > e.y - 1) then
            bomb.exploded = true
            cam:shake(20, 3)
            sfx(4)
            for i=0, 6 do 
                initparticle(bomb.x, bomb.y + bomb.h/2, 2 + rnd(2), 6 + flr(rnd(2)), rnd(4) - 2, - rnd(3)-1)
            end

        else
            sfx(5)
        end
    end

    simple_collision(e, 0.0, 0)

end

function draw_leg(l)
	spr(l.sp[l.f], l.x - 4, l.y - 4)
end

function draw_enemy(l)
	spr(l.sp[l.f], l.x - 4, l.y - 4, 1, 1, l.dx < 0, false)
end

self_explosion_time = 0
function update_player()
    local throw=btn(5) 
    if throw and not bomb.thrown and current_level_index > 1 then
        throw_bomb()
        if p1.has_legs then 
            p1:set_anim("throw")
            sfx(12)
            p1.bomb_throw_counter = 16
        end
    end

    local playeroverlap = mget(p1.x /8, p1.y/8)
    if playeroverlap == 86 or playeroverlap == 87 or playeroverlap == 88 or playeroverlap == 89 then
        next_level()
    end

    if (bomb.thrown or not p1.has_legs) and p1.grounded and btn(4) then
        self_explosion_time += 1
        cam:shake(10, self_explosion_time / 20)
        if self_explosion_time%2 ==0 then
            sfx(8)
        else
            sfx(18)
        end

        if self_explosion_time >= 60 * 0.7 then
            reset()
            sfx(5)
            deaths+=1
        elseif self_explosion_time > 60 * 0.2 then
            initparticle(p1.x, p1.y + p1.h/2, 2 + rnd(2), 8 + flr(rnd(2)), rnd(4) - 2, - rnd(3)-1)
        end
    else
        self_explosion_time = 0
    end

    if p1.y > cam.pos_max.y + 58 then
        for i=0, 6 do 
            initparticle(p1.x, p1.y + p1.h/2, 2 + rnd(2), 12, rnd(4) - 2, -rnd(4)-2)
        end
        reset()
        sfx(3)
        deaths += 1
    end
end

function update_bomb()
    if bomb.thrown and not bomb.grounded and not   bomb.dead  then
        bomb.dy += 0.1
    end

    if  bomb.grounded and not bomb.exploded and rectcollision(bomb, p1) then
          bomb_jump() 
    end

  if bomb.y > cam.pos_max.y + 52 and not bomb.dead then
    sfx(7)
    bomb.dead = true
    for i=0, 6 do 
        initparticle(bomb.x, bomb.y + bomb.h/2, 2 + rnd(2), 12, rnd(4) - 2, -rnd(4)-2)
    end
         
  end

    simple_collision(bomb, 0.2, 0)
    animate(bomb)

    bomb.x += bomb.dx
 	bomb.y += bomb.dy

    bomb.x = mid(cam.pos_min.x - 60, bomb.x, cam.pos_max.x + 60)
 
end

function throw_bomb()
    bomb.x = p1.flipx and p1.x - 2 or p1.x + 2
    bomb.y = p1.y - 4 
    bomb.dx =  p1.flipx and -0.5 or 0.5
    bomb.dy = -1.5
    bomb.thrown = true
end

function bomb_jump()
    p1.has_legs = false
    bomb.exploded = true
    p1.jump_button:jump()
    init_leg(p1.x, p1.y, rnd(6) - 3, rnd(4) - 4)
    init_leg(p1.x, p1.y, rnd(6) - 3, rnd(4) - 4)
    cam:shake(20, 3)
    sfx(4)
    for i=0, 6 do 
        initparticle(p1.x, p1.y + p1.h/2, 2 + rnd(2), 6 + flr(rnd(2)), rnd(4) - 2, - rnd(3)-1)
    end
end

function draw_bomb(b)
    if not bomb.exploded then  
        spr(b.sp[b.f], b.x - 4, b.y - 4, 1,1, false, false)  
    end
end
-->8
-- help functions

function distance(a, b)
	return sqrt(((b.x-a.x)/10)^2+((b.y-a.y)/10)^2)*10
end

function circcoll(a, b)
	if calcdist(a,b) < a.rad+b.rad then 
		return true 
	else 
		return false 
	end
end

function rectcollision(a, b)
--a left side is past b right
	if (a.x > b.x+b.w) or
--a right side is past b left
	(a.x+a.w < b.x) or
--a top side is past b bottom
	(a.y > b.y+b.h) or 
--a bottom side is past b top
	(a.y+a.h < b.y) then
		return false
	else
		return true
	end
end

function lerp(var, target, pow)
	return var+pow*(target-var)
end

function calcangle(a, b) 	
 return atan2(a.x-b.x,a.y-b.y)
end

function movetowards(a,b,speed)
	local newangle=calcangle(a,b)
	b.x+=speed*cos(newangle)
	b.y+=speed*sin(newangle)
	return b.x,b.y
end
-->8
-- particles

particles={}
function initparticle(x, y, rad, col, dx, dy)
	local p={}
	p.x=x
	p.y=y
	p.dx=dx
	p.dy=dy
	-- default parameters
	if(dx == 0)p.dx = rnd(2)-1
	if(dy == 0)p.dy = rnd(2)-1
	p.rad=rad
	p.col=col
	
	add(particles,p)
end

function updateparticle(p)
	p.dx*=0.9
	p.dy*=0.9
 	p.x+=p.dx
 	p.y+=p.dy
    
    --fake gravity
    p.dy += 0.05
 
	p.rad -= 0.09
	if(p.rad <=0)del(particles,p)
end

function drawparticle(p)
	circfill(p.x,p.y,p.rad,p.col)
end

pickups={}
function init_pickup(x, y)
	local p={}
	p.x=x
	p.y=y
	p.w=8
	p.h=8

    -- animation
    p.t, p.f, p.s = 0, 1, 12 --tick, frame, step
    p.sp = {52, 53}
    mset(x/8, y/8, 16)
	
	add(pickups, p)
end

function update_pick_up(p)
	animate(p)
    if rectcollision(p, p1) then
        for i=0, 6 do 
            initparticle(p.x - rnd(4) + rnd(4), p.y + rnd(4), 2 + rnd(2), 12 + flr(rnd(2)), rnd(4) - 2, - rnd(3)-1)
        end
        current_level_pickup = true
        sfx(17)
        del(pickups, p)
    end
end

function draw_pick_up(p)
	spr(p.sp[p.f], p.x - 4, p.y - 4)
end

lamps={}
function init_lamp(x, y)
	local p={}
	p.x=x
	p.y=y
    p.sp = 120
	mset(x/8, y/8, 16)
    p.timer = 0
    p.offset = rnd(4)
	
    add(lamps, p)
end

function update_lamp(l)
    if l.timer < 60 then 
        l.timer+=1
        if l.timer < 8 + l.offset then 
            l.sp = 120
        else 
            l.sp = 56
        end 
    else
        l.offset = rnd(4)
        l.timer = 0
    end
end

function draw_lamp(p)
	spr(p.sp, p.x, p.y)
end

showhelp = false
showhelpcounter = 0
function showhelpifneeded()
    if current_level_index <= 5 then 
        if p1.has_legs == false and p1.grounded and p1.dy == 0 then
            if showhelpcounter < 120 then 
                showhelpcounter+=1 
            else 
                showhelp = true
            end
        else
            showhelpcounter = 0
        end
    end
end

function resethelp()
    if current_level_index <= 5 then
        showhelp = false 
        showhelpcounter = 0
    end
end

floattexts={}
function initfloattext(text, x, y, dir, sp, c1, c2, timer)
	local t={}
	t.x = x
	t.y = y
	t.text = text
	t.dir = dir
	t.speed = sp
	t.c1 = c1
	t.c2 = c2
	t.timer = timer
	t.changecolor = timer/2
	add(floattexts, t)
end
function updatefloattext(t)
	if(t.dir == 1)then t.y+=t.speed else t.x+=t.speed end
	if(t.timer <= t.changecolor)t.c1 = t.c2
	if(t.timer > 0)then t.timer-=1 else del(floattexts,t) end
end
function drawfloattext(t)
	print(t.text,t.x,t.y,t.c1)
end

--advanced micro platformer
 --@matthughson
 
 --if you make a game with this
 --starter kit, please consider
 --linking back to the bbs post
 --for this cart, so that others
 --can learn from it too!
 --enjoy! 
 --@matthughson
                 
 --log
 printh("\n\n-------\n-start-\n-------")
 
 --config
 --------------------------------
 
 --sfx
 snd=
 {
     jump=0,
 }
 
 --music tracks
 mus=
 {
 
 }
 
 --math
 --------------------------------
 
 --point to box intersection.
 function intersects_point_box(px,py,x,y,w,h)
     if flr(px)>=flr(x) and flr(px)<flr(x+w) and
                 flr(py)>=flr(y) and flr(py)<flr(y+h) then
         return true
     else
         return false
     end
 end
 
 --box to box intersection
 function intersects_box_box(
     x1,y1,
     w1,h1,
     x2,y2,
     w2,h2)
 
     local xd=x1-x2
     local xs=w1*0.5+w2*0.5
     if abs(xd)>=xs then return false end
 
     local yd=y1-y2
     local ys=h1*0.5+h2*0.5
     if abs(yd)>=ys then return false end
     
     return true
 end
 
 --check if pushing into side tile and resolve.
 --requires self.dx,self.x,self.y, and 
 --assumes tile flag 0 == solid
 --assumes sprite size of 8x8
 function collide_side(self)
 
     local offset=self.w/3
     for i=-(self.w/3),(self.w/3),2 do
     --if self.dx>0 then
         if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
             self.dx=0
             self.x=(flr(((self.x+(offset))/8))*8)-(offset)
             return true
         end
     --elseif self.dx<0 then
         if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
             self.dx=0
             self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
             return true
         end
 --    end
     end
     --didn't hit a solid tile.
     return false
 end
 
 --check if pushing into floor tile and resolve.
 --requires self.dx,self.x,self.y,self.grounded,self.airtime and 
 --assumes tile flag 0 or 1 == solid
 function collide_floor(self)
     --only check for ground when falling.
     if self.dy<0 then
         return false
     end
     local landed=false
     --check for collision at multiple points along the bottom
     --of the sprite: left, center, and right.
     for i=-(self.w/3),(self.w/3),2 do
         local tile=mget((self.x+i)/8,(self.y+(self.h/2))/8)
         if fget(tile,0) or (fget(tile,1) and self.dy>=0) then
             self.dy=0
             self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
             if self.grounded == false then 
                self.grounded=true
                sfx(13)
                initparticle(p1.x, p1.y + p1.h/2, 1 + rnd(2), 7, rnd(2)-1, - rnd(2)-1)
             end
             self.airtime=0
             landed=true
         end
     end
     return landed
 end
 
 --check if pushing into roof tile and resolve.
 --requires self.dy,self.x,self.y, and 
 --assumes tile flag 0 == solid
 function collide_roof(self)
     --check for collision at multiple points along the top
     --of the sprite: left, center, and right.
     for i=-(self.w/3),(self.w/3),2 do
         if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
             self.dy=0
             self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
             --self.jump_hold_time=0
         end
     end
 end
 
 --make 2d vector
 function m_vec(x,y)
     local v=
     {
         x=x,
         y=y,
         
   --get the length of the vector
         get_length=function(self)
             return sqrt(self.x^2+self.y^2)
         end,
         
   --get the normal of the vector
         get_norm=function(self)
             local l = self:get_length()
             return m_vec(self.x / l, self.y / l),l;
         end,
     }
     return v
 end
 
 --square root.
 function sqr(a) return a*a end
 
 --round to the nearest whole number.
 function round(a) return flr(a+0.5) end
 
 
 --utils
 --------------------------------
 
 --print string with outline.
 function printo(str,startx,starty,col,col_bg)
     print(str,startx+1,starty,col_bg)
     print(str,startx-1,starty,col_bg)
     print(str,startx,starty+1,col_bg)
     print(str,startx,starty-1,col_bg)
     print(str,startx+1,starty-1,col_bg)
     print(str,startx-1,starty-1,col_bg)
     print(str,startx-1,starty+1,col_bg)
     print(str,startx+1,starty+1,col_bg)
     print(str,startx,starty,col)
 end
 
 --print string centered with 
 --outline.
 function printc(str,x,y,col,col_bg,special_chars)
     local len=(#str*4)+(special_chars*3)
     local startx=x-(len/2)
     local starty=y-2
     printo(str,startx,starty,col,col_bg)
 end
 
 --objects
 --------------------------------
 
 --make the player
 function m_player(x,y)
 
     --todo: refactor with m_vec.
     local p=
     {
         x=x,
         y=y,
 
         dx=0,
         dy=0,
 
         w=8,
         h=8,
         
         max_dx=1.01,--max x speed
         max_dy=3.5,--max y speed
 
         jump_speed=-1.85,--jump veloclity
         acc=0.25,--acceleration
         dcc=0.8,--decceleration
         air_dcc=0.995,--air decceleration
         grav=0.1,
         combo = 0,
         
         --helper for more complex
         --button press tracking.
         --todo: generalize button index.
         jump_button=
         {
             update=function(self)
                 --start with assumption
                 --that not a new press.
                 self.is_pressed=false
                 if btn(5) and 1==0 then
                     if not self.is_down then
                         self.is_pressed=true
                     end
                     self.is_down=true
                     self.ticks_down+=1
                 else
                     self.is_down=false
                     self.is_pressed=false
                     self.ticks_down=0
                 end
             end,
             jump=function(self)
                    self.jump_hold_time=4
                self.is_down=true
                self.ticks_down=9
             end,
             --state
             is_pressed=false,--pressed this frame
             is_down=false,--currently down
             ticks_down=0,--how long down
         },
 
         jump_hold_time=0,--how long jump is held
         min_jump_press=5,--min time jump can be held
         max_jump_press=15,--max time jump can be held
 
         jump_btn_released=true,--can we jump again?
         grounded=false,--on ground
         bomb_throw_counter = 0,
 
         airtime=0,--time since grounded
         
         --animation definitions.
         --use with set_anim()
         anims=
         {
             ["stand"]=
             {
                 ticks=20,--how long is each frame shown.
                 frames={100, 107},--what frames are shown.
             },
             ["walk"]=
             {
                 ticks=5,
                 frames={101,102,103,104},
             },
             ["jump"]=
             {
                 ticks=6,
                 frames={98,106},
             },
             ["jump_legs"]=
             {
                 ticks=8,
                 frames={109,110},
             },
             ["slide"]=
             {
                 ticks=1,
                 frames={105},
             },
             ["throw"]=
             {
                 ticks=4,
                 frames={108, 108, 111, 111, 111},
             },
         },
 
         curanim="walk",--currently playing animation
         curframe=1,--curent frame of animation.
         animtick=0,--ticks until next frame should show.
         flipx=false,--show sprite be flipped.
         
         --request new animation to play.
         set_anim=function(self,anim)
             if(anim==self.curanim)return--early out.
             local a=self.anims[anim]
             self.animtick=a.ticks--ticks count down.
             self.curanim=anim
             self.curframe=1
         end,
         
         --call once per tick.
         update=function(self)
     
             --todo: kill enemies.
             
             --track button presses
             local bl=btn(0) --left
             local br=btn(1) --right
             
             --move left/right
             if bl==true then
                if self.has_legs or not self.grounded then
                 self.dx-=self.acc
                 br=false--handle double press
                  else
                     self.dx*=self.dcc
                 end
             elseif br==true then
                if self.has_legs or not self.grounded then
                 self.dx+=self.acc
                  else
                     self.dx*=self.dcc
                 end
             else
                 if self.grounded then
                     self.dx*=self.dcc          
                 else
                     self.dx*=self.air_dcc
                 end
             end
 
             --limit walk speed
             self.dx=mid(-self.max_dx,self.dx,self.max_dx)
             
             --move in x
             self.x+=self.dx
             
             --hit walls
             collide_side(self)
 
             --jump buttons
             --self.jump_button:update()
             
             --jump is complex.
             --we allow jump if:
             --    on ground
             --    recently on ground
             --    pressed btn right before landing
             --also, jump velocity is
             --not instant. it applies over
             --multiple frames.
             if self.jump_button.is_down then
                 --is player on ground recently.
                 --allow for jump right after 
                 --walking off ledge.
                 local on_ground=(self.grounded or self.airtime<5)
                 --was btn presses recently?
                 --allow for pressing right before
                 --hitting ground.
                 local new_jump_btn=self.jump_button.ticks_down<10
                 --is player continuing a jump
                 --or starting a new one?
                 if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
                     if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
                     self.jump_hold_time+=1
                     --keep applying jump velocity
                     --until max jump time.
                     if self.jump_hold_time<self.max_jump_press then
                         self.dy=self.jump_speed--keep going up while held
                     end
                 end
             else
                 self.jump_hold_time=0
             end
             
             --move in y
             self.dy+=self.grav
             self.dy=mid(-self.max_dy,self.dy,self.max_dy)
             self.y+=self.dy

             self.x = mid(cam.pos_min.x - 60, self.x, cam.pos_max.x + 60)
 
             --floor
             if not collide_floor(self) then
                if self.has_legs then
                    self:set_anim("jump_legs")
                 else
                    self:set_anim("jump")
                 end
                 self.grounded=false
                 self.airtime+=1
             else
                self.combo=0
             end
 
             --roof
             collide_roof(self)
 
             --handle playing correct animation when
             --on the ground.
             if self.grounded and self.has_legs then
                 if br then
                     if self.dx < 0 then
                         --pressing right but still moving left.
                         self:set_anim("slide")
                     else
                         self:set_anim("walk")
                     end
                 elseif bl then
                     if self.dx > 0 then
                         --pressing left but still moving right.
                         self:set_anim("slide")
                     else
                         self:set_anim("walk")
                     end
                 else
                     if self.bomb_throw_counter == 0 then 
                        self:set_anim("stand")
                     end
                 end
             end
 
             --flip
             if br then
                 self.flipx=false
             elseif bl then
                 self.flipx=true
             end

             if self.bomb_throw_counter > 0 then 
                self.bomb_throw_counter -= 1
             end 
 
             --anim tick
             self.animtick-=1
             if self.animtick<=0 then
                 self.curframe+=1
                 local a=self.anims[self.curanim]
                 self.animtick=a.ticks--reset timer
                 if self.curframe>#a.frames then
                     self.curframe=1--loop
                 end
             end
 
         end,
 
         --draw the player
         draw=function(self)
             local a=self.anims[self.curanim]
             local frame=a.frames[self.curframe]
             spr(frame,
                 self.x-(self.w/2),
                 self.y-(self.h/2),
                 self.w/8,self.h/8,
                 self.flipx,
                 false)
         end,
     }
 
     return p
 end

function simple_collision(a, friction, bounce_factor)
    a.grounded = false
    
    local bounce = -0.9 *  bounce_factor
    local startx = a.x
    --check for walls in the
    --direction we are moving.
    local xoffset = -4
    if a.dx > 0 then xoffset = 4 end
    --look for a wall
    local h=mget((a.x + xoffset) / 8,(a.y + 1) / 8)
    if fget(h, 0) then
        a.x = startx
        a.dx *= -1
        a.dy *= bounce
    end

    --hit floor
    local v=mget((a.x)/8,(a.y+4)/8)
    if a.dy>=0 then
        if fget(v,0) then
            if abs(a.dy) < 0.9 then
                a.grounded = true
            end
            a.y = flr((a.y)/8)*8+4
            a.dy *= bounce
            a.dx *= 1-friction
        end
    end

    --hit ceiling
    v=mget((a.x) / 8,(a.y-4) / 8)
    if a.dy<=0 then
        if fget(v,0) then
            a.y = flr((a.y+4)/8)*8+4
            a.dy *= bounce
        end
    end
end
 
 --make the camera.
 function m_cam(target)
     local c=
     {
         tar=target,--target to follow.
         pos=m_vec(target.x,target.y),
         
         --how far from center of screen target must
         --be before camera starts following.
         --allows for movement in center without camera
         --constantly moving.
         pull_threshold=16,
 
         --min and max positions of camera.
         --the edges of the level.
         pos_min=m_vec(64,64),
         pos_max=m_vec(320,64),
         
         shake_remaining=0,
         shake_force=0,
 
         update=function(self)
 
             self.shake_remaining=max(0,self.shake_remaining-1)
             
             --follow target outside of
             --pull range.
             if self:pull_max_x()<self.tar.x then
                 self.pos.x+=min(self.tar.x-self:pull_max_x(),4)
             end
             if self:pull_min_x()>self.tar.x then
                 self.pos.x+=min((self.tar.x-self:pull_min_x()),4)
             end
             if self:pull_max_y()<self.tar.y then
                 self.pos.y+=min(self.tar.y-self:pull_max_y(),4)
             end
             if self:pull_min_y()>self.tar.y then
                 self.pos.y+=min((self.tar.y-self:pull_min_y()),4)
             end
 
             --lock to edge
             if(self.pos.x<self.pos_min.x)self.pos.x=self.pos_min.x
             if(self.pos.x>self.pos_max.x)self.pos.x=self.pos_max.x
             if(self.pos.y<self.pos_min.y)self.pos.y=self.pos_min.y
             if(self.pos.y>self.pos_max.y)self.pos.y=self.pos_max.y
         end,
 
         cam_pos=function(self)
             --calculate camera shake.
             local shk=m_vec(0,0)
             if self.shake_remaining>0 then
                 shk.x=rnd(self.shake_force)-(self.shake_force/2)
                 shk.y=rnd(self.shake_force)-(self.shake_force/2)
             end
             return self.pos.x-64+shk.x,self.pos.y-64+shk.y
         end,
 
         pull_max_x=function(self)
             return self.pos.x+self.pull_threshold
         end,
 
         pull_min_x=function(self)
             return self.pos.x-self.pull_threshold
         end,
 
         pull_max_y=function(self)
             return self.pos.y+self.pull_threshold
         end,
 
         pull_min_y=function(self)
             return self.pos.y-self.pull_threshold
         end,
         
         shake=function(self,ticks,force)
             self.shake_remaining=ticks
             self.shake_force=force
         end
     }
 
     return c
 end
 
 
 
-->8
--misc

watery = 120
waterstarty = 120
t = 0
cmx = 0
tide = 2
function updatewater()
 t += 1
 watery += (waterstarty - watery) * 0.1
end

function get_tide(x)
 return cos(t/300)*tide
end

function gwy(x)
 local n=cos((cmx*1.5+x)/48)*cos(t/80)*2.5
 local wy=watery+get_tide(x-cmx)+n

 return wy
end

function drawwater()
 for x=0,127 do

  first=2
  by=gwy(x + cam.pos.x)
  for y=by,128 do
   pix=pget(x,y)
   if first > 0 then
    for i=1,first do
     pix=sget(48+pix,1)
    end
    first-=1
   end
   pset(x,y,sget(48+pix,2))
  end
 end
end

function animate(o)
 o.t = (o.t + 1) % flr(o.s) --tick fwd
 if (o.t == 0) o.f = o.f %#o.sp + 1
end

fadestate = 0
fadecounter = 0
fadespeed = 1
function screentransition()
	if fadestate == 1 then 
		fadecounter += fadespeed
		if fadecounter >= 14 then 
			fadestate = 2
			fadecounter = 14
		end
	else 
		fadecounter-=fadespeed
		if (fadecounter <= 0) then 
			fadestate = 3
			fadecounter = 0
		end
	end
	fade(fadecounter)
end

local fadetable={
 {0,0,0,0,0,0,0,0,1,1,1,1,1,1,1},
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
 {2,2,2,2,2,2,2,1,1,1,1,1,1,1,1},
 {3,3,3,3,3,3,3,1,1,1,1,1,1,1,1},
 {4,4,4,4,2,5,5,5,5,5,5,1,1,1,1},
 {5,5,5,5,5,5,5,1,1,1,1,1,1,1,1},
 {6,6,6,13,13,13,13,13,13,5,5,5,5,1,1},
 {7,6,6,6,6,6,13,13,13,13,13,5,5,1,1},
 {8,8,8,8,2,2,2,2,2,2,2,2,1,1,1},
 {9,9,9,4,4,4,4,4,4,5,5,5,5,1,1},
 {10,10,10,10,9,4,4,4,5,5,5,5,5,1,1},
 {11,11,11,11,3,3,3,3,3,3,3,1,1,1,1},
 {12,12,12,12,12,12,12,13,3,1,1,1,1,1,1},
 {13,13,13,13,13,5,5,5,5,5,1,1,1,1,1},
 {14,14,14,14,13,13,13,13,5,5,5,5,5,1,1},
 {15,15,6,6,13,13,13,13,13,5,5,5,5,1,1}
}

-- by comet bomb
function fade(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c, 1)
  else
   pal(c,fadetable[c+1][flr(i+1)])
  end
 end
end

menuitem(1, "restart level", function() restartlevel() end)
function restartlevel()
	reset()
end

function glitchwhenexploding()
    if self_explosion_time > 0 then 
        drawglitch()
    end
end

function drawglitch()
	o1 = flr(rnd(0x1f00)) + 0x6040
	o2 = o1 + flr(rnd(0x4)-0x2)
	len = flr(rnd(0x40))
	memcpy(o1,o2,len)
end

wt=2
wr=4
ws=22
function backgroundwave()
  	fillp(0b0011001111001100.1)
  	for x=0,128,1 do
  		tidey = 80 + ws *- sin((x+wt) / 1080)
  		rectfill(cam.pos.x - 64 + x, current_level.sy + 128, cam.pos.x + x - 64, current_level.sy +  tidey, 1)
  	end
  	wt+=wr
  	fillp() 
end

bcounter=0
function makebubbles()
	if bcounter < 30 then 
		bcounter+=1
	else
		bcounter = 0 
		initbubble(cam.pos.x + rnd(128), cam.pos.y+128)
	end
end

bubbles={}
function initbubble(x,y)
	local p={}
	p.x=x
	p.y=y
	p.dx=rnd(2)-1
	p.dy=-0.5-rnd(1)
	p.size= 1+rnd(2)
	p.col1=1
	p.col2=12
	add(bubbles, p)
end

function updatebubble(p)
	p.dx*=0.9
 	p.x+=p.dx
 	p.y+=p.dy
	
	if p.y <= current_level.sy + tidey + 12 then 
		del(bubbles, p)
	end	
end

function drawbubble(p)
	circfill(p.x,p.y,p.size, p.col1)
end

function inittowers()
	for i=0, 2 do 
		--sspr(sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
		sspr(112, 0, 16, 32, current_level.sx + i * 72 + (cam.pos.x - current_level.sx) * 0.7, current_level.sy + 0, 32, 128) 
	end
end

gamename="backfire"
gamename2="man"
ts=0
rs=6
wp=8
poffset  = 0
poffset = 0
pow = false
function drawstartscreen()
    local poffset = p1.x - 150
    if poffset >= 0 then 
        poffset = 0
        if not pow then 
            pow = true
            sfx(14)
        end
    end 

	rectfill(32, 32+poffset, 98, 90+poffset, 0)
	sspr(64, 0, 16, 16, 48, poffset + 42 + (wp*-sin((ts)/1080)) / 2, 32, 32)	
	
	for i=0, #gamename do 
  		print(sub(gamename,i,i),28+i*8,poffset+56+wp*-sin(((i*8)+ts)/720),7)
 	end
	for i=0, #gamename2 do 
  		print(sub(gamename2,i,i),48+i*8,poffset+70+wp*-sin(((i*6)+ts)/720),7)
 	end 
	ts+=rs
	rect(32, 32+poffset, 98, 90+poffset, 2)

	rectfill(0, 115, 128, 128, 1)
	spr(79, 2, 118)
	print("made by: simon bothen and \nsebastian lind", 12, 116, 7)
end

function drawtutorial()
    if current_level_index == 2 and showhelp == false then
        spr(126, current_level.x*8 + 32, current_level.y + 52)
        spr(121, current_level.x*8+ 44, current_level.y + 52)
        spr(125, current_level.x*8 + 56, current_level.y + 52)
        spr(64, current_level.x*8 + 68, current_level.y + 52)
    end

    if current_level_index <= 5 and showhelp then
        print("hold", current_level.x*8 + 24, current_level.y + 52, 7)
        spr(127, current_level.x*8 + 46,current_level.y + 51)
        print("to reset",current_level.x*8 + 60, current_level.y + 52, 7)
    end
end
__gfx__
0000000045555554444444445dddddd5444444441a9a9a9177ffccdd55555555000000000000000011119aa99999111111111111111111110000022222200000
000000005444444244444444d555555122222222900000091d8c9677ea7a66b7000000000000000011a900000000991118818818818818810000022222200000
007007005444444242222224d55555516dddddd69000000911ccccc7cc7cc1c70000000000000000199000000000099148848848848848840000022222200000
00077000544444426dddddd1d55555511dddddd190000009000051df2893d5de00000eee88888000190000000000009158858858858858850000222222220000
00077000544444426dddddd1d555555111111111900000092222889a89a9989a000e888888888800900007000060000908828828828828800000222222220000
00700700544444426dddddd1d55555511111111190000009222222892898828900888888888888d0900060000700000908828828828828800000222222220000
00000000544444426dddddd1d5555551111111119000000922222228228222280d8888888888825d900600006000000908828828828828800000222222220000
0000000042222224d111111d5111111511111111900000090000000000000000d52888888888825d900000000000000908828828828828800002229922222000
1111111100000000199999911111111111111111111111111111111111111111d52228888822255d900000000000000908828828828828800022229922222200
1111111100700000900000091111111111111111111111811111111111111111d5552222222555d2900060000070000908828828828828800022222222222200
11111111060000009006000911111111118111111111811199999999111111112d5555555555ddd2900700000600000908828828828828800022229922222200
111111110000060090000009111111111111181111111811909009091dddddd122ddddddddddd222900000000000000908828828828828800022222222222200
11111111000000009000600911111111188181111111111190900909d999999d2222222222222222990000000000009908828828828828800022222222222200
111111110006000090000009111111111181111111111111909009091dddddd102222d2222262220990000000000009908828828828828800022222222222200
111111110000000099999999111111111111111111111111999999991111111100222dd222662200299999999999999208828828828828800222229922222220
1111111100000000222222221111111111111111111111112222222211111111000000ddd6600000122222222222222108828828828828800222229922222220
111111d5ddddddd1dddddddd1dddddddd5111111d111111111111111111111d51677676111111115111111115111111108828828888288200222222222222220
111111d55555555d55555555d5555555d5111111d511111111111111111111d51155555511111115111111115111111108828828888288200222222222222220
111111d5111111d511111111d5111111d5111111d511111111111111111111d51111112211111115111111115111111118828828888288200222222222222220
111111d5111111d511111111d5111111d5111111d511111111111111111111d51111112d11111115111111115111111111828811888188110222222222222220
111111d5111111d511111111d5111111d5111111d511111111111111111111d5111111d511111115111111115111111111118111881111110222992299222220
11111d5511111d5511111111d5111111d5511111d551111111111111111111d5111111d511111115111111115111111111111111111111110222992299222220
111111d5111111d511111111d5111111d5111111ddddddddddddddddddddddd5ddddddd511111115111111115111111111111111111111110222222222222220
111111d5111111d511111111d5111111d51111111555555555555555555555515555555111111115555555555111111111111111111111110222992299222220
122444d1d599a911119999d5111111110077cc000007c000111111115dddddd5dddddddd55555555d555555ddddddddd1dddddd1dddddddd2222222222222222
22444464d51911a1191911d511111111077ddcc000cccc0011199111d5555551dddddddd111111115dddddd15555555511dddd11d55555552222222222222222
22444464d5191119a11911d51111111107dccdc000cccc0011999911d5555551dddddddd111111115dddddd1911d511911111111d51111112222222222222222
ddd6666dddddd999911dddd51111111107dccdc000cccc0012999921d5555551dddddddd111111115dddddd1911d599911111111d51111112222222222299222
224444d4d5555119a99555d5111111110cdccdc000cccc0029999992d5555551dddddddd111111115dddddd1999d511911111111d51111112222222222222222
224444d4d5119119911191d5111111110cdccdc000cccc009aaaaaa9d5555551dddddddd111111115dddddd19111911911111111d51111112222222222299222
dd66ddddd5119191191191d51d111111011dd110001cc100aaaaaaaad5555551dddddddd111111115dddddd11911919111111111d51111112222222222299222
22644444d5999911119999d5ddd1dd1100111100000110001aaaaaa151111115dddddddd11111111d111111d11a9a91111111111d51111112222222222222222
0000000000000000000000000000000000000000000000000000f000000fff0000000000000000000000000011111111111111111111aa999999111108800880
00000000000000000000000000000000000000000000000000006f0000006d0000fd00000000000000000000111111b3bb33111111a900090000991188788882
00000000000000000000000000d000000dd0000000000000000006f000000d000f6d00000000000000000d001111b13333bbb11119900009000709918e888888
00000000000000000000000000d0000000dd00000000000f0000ddd000000d00060dd00000000000000dd00011bbb33bbbbbbb1119000009007000918e888880
09988880088998800888899000d00000000dd06f0000006f000dd00000000d000000dd0066dddd00006d00001b3b1bbbbb1bb111900700090000000988888820
09888880088988800888999000d000000000dff0000ddddf00dd00000000000000000dd06f000000006d000013b441bb1133b311907000090000700908888200
55555555555555555555555500d600000000df0000000000000000000000000000000000f000000000fd00001bb141bb133bb311900000090007000908888000
22222222222222222222222200fff000000000000000000000000000000000000000000000000000000f000011b33bbb33bb3311900000999000000900880000
0077ee00007eee00000e200000002e0000e7e2000d0000d0119a9aa99aa9a91193333333333333391111111111bbbbbbbbb33111999999a999000099cccccccc
07e222e00ee222e076222e67002e2e0602222220d07ee20d199bbbbbbbbbb9919333333333333339111111111111b33b333331119000000a99999999cccccccc
0e2222200722222066722277760222670e9229200e22222099b3333333333b9993333333333333391111111111111b33333111119000070090000009cccccccc
02222220022922900722929667222276022222200e92292099b3333333333b9993333333333333391111111111111222211141119000000090070009cccccccc
0229229002222220222222206222922701222220022222209b333333333333b993333333333333391111111111111112444411111900000090700091cccccccc
02122210021212100221112222222292001222100120202093333333333333399333333333333339111b111111111414411111111990000090000991cccccccc
020111000001112002221110222112220d01110d0010201093333333333333399333333333333339b1bb1bb111111144411111111199000090009911cccccccc
02000000000000200022220002221120d0d000d00d01110d93333333333333399b333333333333b9bbbbbbbb11111144444111111111999999991111cccccccc
bbbbbbbb000000000000000000000000000fc00000000fc000000fc000000fc000000fc000000fc00000000000000000f00fc00ff00fc00f000000000000fc00
3333333300000000000000000000000000c7c7000000f7c70000f7c70000f7c70000f7c70000f7c700000000000fc00090c7c70990c7c709000fc000000c7c70
5444444200000000600fc0060000000009cc8c900000cc8c0000cc8c0000cc8c0000cc8c0000cc8c000fc00000c7c70009cc8c9009cc8c9000c7c700009cc8c0
544444420000000090f7c709000fc00090cccc09000c99cc000cc9cc000c99cc000c99cc000c99cc00f7c70009cc8c9000cccc0000cccc0009cc8c9000c9cc90
544444420000007009cc8c9000c7c700f0cccc0f00dc9cc000cc9cc000cc9cc000cc9cc000cc9cc009cc8c9090cccc0900cccc0000cccc0000fccf0600ccfc0f
544444420000077700cccc0009cc8c9000dccc000ddcfc0000dc9c0600dcfd0000dcfc0000dcfd0090cccc090fccccf000dccc0000dc6c0600dcccd600dccc00
544444420000007000cccc0090cccc0900d00d0060000dd00dddfdd60d000d00000dd0006dddd00060cccc0600d00d0000d00d00000d60d600d0600000d00d00
4222222400000000000ccc00f00ccc0f006606600600002202200000660002200022000060022000000ccc00006606600066066000000000000d600000660660
00066000000760000007600000000000002222000022220000222200455555540000000070077007000000000000000000077000000000000077770000777700
0077760000777600006776000077770009dd9dd009d9ddd00dddddd05444444200000000707777070000000000700000007777000000070007bbbb7007999970
00677700007776000077760007d22d70077766600777766007777660544444420000000007777770000000000770000006677660000007707b7337b779777797
0776666006777770067777700222222006777760066777700667777054444442000000000077770000000000777777770007700077777777bb3763b799887897
06777760077776600777766002222220077666600777776007777660544444420000000000777700000000006776666600077000666667766336633668878886
07776660067777700667777007d22d70006777000067760000677700544444420000000000777700000000000670000000077000000007606363363668777786
09dd9dd00ddd9d900dddddd000777700007776000067770000677600544444420000000000700700000000000060000000077000000006000633336006888860
00222200002222000022220000000000000660000006700000067000422222240000000000770770000000000000000000077000000000000066660001010101
c0d0303001a2a2a2015230303001a2a2a201010101527301a2a2a2a2010101010101010101010101c0d030c0d030c0d001010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
c1d1010192111111b20130213092111111b201010101739211111111b20101010101010101010101c1d101c1d101c1d101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
c2d2010192111111b20130303092111111b201010101739211111111b20101430101010101010101c2d201c2d201c2d201010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010192111111b20130213092111111b201010101739211111111b22020200101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
2020200192111111b20130303092111111b20101010101019393939301a3a3a30101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3030300192111111b20130213092111111b20101010101010101010101a3a3a32001010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3021300192111111b20130303092111111b201010101010101010101013030a33020010101010101010101010101657501010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3030300192111111b20130303092111111b201010101010101010101013063303063300101012001010101010101859501010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3030300192111111b20101010192111111b22501012520200125010101018301018301010101a301010101010101404001010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3021300192111111b20101010192111111b20101010130c30101010101018301018301010101a301010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3030300192111111b20101010192111111b20101010130010101010101202020202020010101a301010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3021300192111111b20101010192111111b22001010130010101010101303030303030010101a301200101010125010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
3030300101939393010101250101939393011001010130010101010101301010103030010101a301302001010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
30213001010101010101202020010101010110012501300105012001013010211030010101010101303001010102221201010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
30303001010125010101101010010125013030300101302020203022523010101030010101202020303012010123010301010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
30303022120101010101303030010101013030300101303030303001013030303030d3b322303030303002010102202001010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010130c0d0c0d0c0d0c0d0c0d0c0d0c0d030
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010130c1d1c1d1c1d1c1d1c1d1c1d1c1d130
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101c2d2c2d2c2d2c2d2c2d2c2d2c2d201
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010163010101010101010101016301
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101018301010101010101b4c4018301
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101a5018301a501010101a5b5c5a583a5
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010106060606060601010101060606060606
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101101010101010b3120101101010101010
__gff__
0001010102000000000000000000000040000000000000000000000000000000000000000000000080000000000000000000000000004001400001004000000000000000000000000001000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000004000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0c0d0c0d0c0d03030c0d0c0d0c0d0c0d0c0d03030c0d0c0d03030c0d0c0d0303101010101010101010101010100101013a103a3a3a0c0d0c0d3a3a3a3a103a3a201010101010101010101010101010100c0d22220c0d22220c0d22220c0d22210d0a0b0c0d0a0b0c0d0a0b0c0d0a0b0c0d0a0b0c0d0a0b0c0d0a77770d0a0b0c
1c1d1c1d1c1d10101c1d1c1d1c1d1c1d1c1d10101c1d1c1d10101c1d1c1d0303102a2a2a2a2a2a2a2a2a2a2a2a1001013a223a3a101c1d1c1d10201010103a3a20223b22222222223b222126260202021c1d10101c1d10101c1d10101c1d10201d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c
2c2d2c2d2c2d10102c2d2c2d2c2d2c2d2c2d10102c2d2c2d10102c2d2c2d1003291111111111111111111111112b01013a101010102c2d2c2d10321010103a3a20101010100a0b101010201010253a3a2c2d10102c2d10102c2d10102c2d10202d10102c2d10102c2d10102c2d10102c2d10102c2d10102c2d10102c2d10102c
1010101010101010101010101010101010101010101010101010101010101003291111111111111111111111112b01013a222110101010101010201010103a3a20101010101a1b10101020101010253a2a2a1010101010102a2a2a2a2a1010202a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a342a
1010100a0b101010101010101010101010101010101010101010101023222203291111111111111111111111112b01013a102028101010101010102222223a3a201010101010101010103210102a2a2a11112b100210102911111111112b10321111111111111111111111111111111111111111111111111111111111111111
1010101a1b101010161616101010101010101010101010101010101024101003291111111111111111111111112b10013a222210101010101010101010103a3a2022222222222222211020102911111111112b100356572911111111112b10201111111111111111111111111111111111111111111111111111111111111111
1010102a2a1010102a2a2a1010101210121010101010100a0b101010241010031039393939393939393939393910103a2010101010101010101010101010100120101010100a0b10201020342911111111112b100358592911111111112b34201111111111111111111111111111111111111111111111111111111111111111
10102911112b10291111112b10102a2a2a1010101010101a1b13101031101003102a2a2a2a2a2a2a2a2a2a2a2a10103a2010100a0b101010100a0b101010100132101010101a1b102010201029111111111110100302022911111111112b10201111111111111111111111111111111111111111111111111111111111111111
10102911112b36291111112b10291111112b10101010102a2a10101024101003291111111111111111111111112b103a2010101a1b101010101a1b101010100120101010101010101022221010393939111110103c3c3c1039393939021050023939393939393939393939393939393939393939393939393939393939393939
10102911112b38291111112b10291111112b101010102911112b101325262603291111111111111111111111112b103a20101010361010101010101010565701201010101010101010101010101056573939101010101010101010100303030310101010101010101010521010101010101010105210101010103d2222222452
33102911112b38291111112b10291111112b101036102911112b101010101003291111111111111111111111112b103a3210101038101010101034100258590130101010101010101010101010105859101010101010101010101010101010032110101036101010101010101010105210101010101010101052241036102526
02020202020202020202020210291111112b101038102911112b1010565710031039393939393939393939565710233a2010101038101010101010103a02020302020210100202101002021010020202333333331010101033101010521003032010101038101010101010101010101010101010101010101010241038565710
030303030303030303030303020202020202021038102911112b1033585933031010101010101010101010585910303a0202020202021010021010103a03030303373a33333a3a33503a3a33503a3a3a020202021010101002101010101010032010333338101050331010105010103310501010101033105010301038585933
77030303030303030303030337373737373703020202020202020202020202010202020202020210101002020202020303030303030321103a3350333a03033a3a373a02023a3a02023a3a02023a373737373737331050103a222222211010010202020202020202020202020202020202020202020202020202020202020202
77777777777777777777777701010101010103030337373737373737373703010303030303030321101003030303030303010101030322103a0202023a3a3a3a3a37373703121203031212030303373701013a3a020202023a101010321010010303030312030303031203030303120303030312030303120303030312030303
7777777777777777777777777777010101010101010101010177770101010101010101010101102010101001010101010301010101032626010101010101013a3a3a3a3a3a3a3a3a3a3a3a3a3a12123a010101013737373a10101010201010010101010101010101010101010101010101010101010101010101010101010101
111111111111111111111111111111111010101010101010101010101010201010252637373737373737373737373737373737373737373737373737373737370128100303030303252627030303030377770101010c0d03030c0d03030c0d031010101010101010101010101010101010101010101010101010101010101010
111010101010103d3a211010101010113d22222222223b2222223b22222527100c0d0c0d030337370c0d37370c0d0d030310200c0d0c0d0c0d0c0d0c0d0c0d0c3c10103a03030310101010100303030377770101011c1d20101c1d10101c1d251010101010101010101010101010101010101010101010101010101010101010
1110101010103a3a123a3a1010101011241010333310101010101010101010101c1d1c1d101010101c1d37371c1d1d10223b221c1d1c1d1c1d1c1d1c1d1c1d1c1710103a3a03223b222222222503030177770a0b012c2d32102c2d10102c2d101010101010101010101010101010101010101010101010101010101010101010
1110101010013a253a273a0110101011241010020210101010103610021010102c2d2c2d101010102c2d10102c2d2d101010102c2d2c2d2c2d2c2d2c2d2c2d2c3310103a3a101010101034101010010177771a1b0126262710101010101010101010101010101010101010101010101010101010101010101010101010101010
11101010103a10100110103a101010113110103c3a101010101038103a101010101010101010342a2a2a2a2a2a2a2a2a2a2a2a101010104d4e1002223b2222220202103a1010101010101010101001017777010101102a2a10101010101010101010101010101010101010101010101010101010101010101010101010101010
11101010101010340110101010101011241010103a101010103338333a101010211010101010291111111111111111111111112b1010105d5e10022626262810013a52100210101010101010101010100c0d0c0d012911112b101010101010101010101010101010101010101010101010101010101010101010101010101010
1110101010101010011010101010101124101010101010101002020210105002321010101010291111111111111111111111112b101010101010101010101010013a10103a10101010102a2a10102a2a1c1d1c1d012911112b101010101056571010101010101010101010101010101010101010101010101010101010101010
11101010101010100110101010101011303310101010101010103a101010023a271010101010291111111111111111111111112b101010101010101010101010123a100210101010102911112b2911112c2d2c2d012911112b100202101058591010101010101010101010101010101010101010101010101010101010101010
02020210101010100110101010101011020210100210101010103a1010503a10101010101010291111111111111111111111112b101010101010101010025657013a103a10500210102911112b291111101010100110393910103a3a101004041010101010101010101010101010101010101010101010101010101010101010
11030302101010100110101010101011030310103a10101010103a1010025657101010521010291111111111111111111111112b100210101010101010105859013a521002021010102911112b291111020210101010101010260303101010101010101010101010101010101010101010101010101010101010101010101010
11030301101010300110101010101011031010103a10105210103a10101058591010361002101039393939393939393939393910103a10101010101010100404123a10333a10101010103939101039393a101010102a101020100303211010101010101010101010101010101010101010101010101010101010101010101010
11102501101002020102021010105657101010103c10101010103a10102a0404101038103a101010101010101010100210101010103a10101010101010101010013a1002101010101010101010101010101010101002101020101010201010101010101010101010101010101010101010101010101010101010101010101010
11101001335033503333101010105859101010101010103410103a100a110b10331038103a101010101010101010103a22211010100326281010101010101010013a521010101002101010101056570210101010103a101032101010203410101010101010101010101010101010101010101010101010101010101010101010
111001010202020202020210101002021010101010101010101001291111112b020202023a222110101010101010103a26271010100310101010333310523310123a10101010103a105010105058593a2a332a2a103a105220101010325210281010101010101010101010101010101010101010101010101010101010101010
110301011201011201010133332301011010521002102a52102a0110393939020112011201102052100210105210100310521010100310521010020202020202013a10020202023a020202020202023a11021111023a101020101010201010241010101010101010101010101010101010101010101010101010101010101010
11100303030303030303030202020101105210103a29112b29110102020202020303030303102010103a211010103d03101010103d031010103d011201011201013a230101010101010101010101010111111111113a232222222222211010240202101010101010101010101010101010101010101010101010101010101010
__sfx__
00030000045501d5502b55022550095502a5501355005550045501000000000111001c10037000010000f0000a1000970028100201000a5000b500030002c5002150011500030000300003000030000300007000
00030000000002855037550325502f550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000002b5503e5503e55019550195501b5501d550265503255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000202500f2502025028250222501d6503665035650086500a6500a6501f250162501f6501c65000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000000000000000000076501b6503c6500465005650316502d65029650216501a650196501765007650026500000000000000000000000000000000000000000000000000000000000000000000000
000400000000000000191502b7500000000000000002710000000000001110000000000001b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000017750187501a75021750277502e72033740367503875038740357302f7202b7202c7302f730347403a7503f7500000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000196500845021650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000572009110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000301000100051100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0000000000355004550335500255025550015502d550005500a05005050005500405001050005500175002050077500b050027500a050015502c75028750277501e7501a750025500b55009550245502d550
000e01010000000000000000000002750000000075000000000000175000000017000000000000017500005000000057000170001750000000000000000007000275000000000000000000000027500003004750
000c0000040300c5000c5000b5000f500053000c700121000b10007100073000410021700000000b300000000d3000e3000d30000000000000000000000000000000000000000000000000000000000000000000
001000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000117500b750067500275000750007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f000000050140500f0500c05015050020500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000501005020190301c03009020070200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001b7202c12031020270203602020000136002f0000b7000970008700037000270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000003008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
