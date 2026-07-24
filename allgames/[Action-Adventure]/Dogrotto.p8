pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--dogrotto
--by zee
--version 1.1

function _init()
 -- pico8 info --
 width = 128
 height = 128
 wrap = (8 * 16) -- draw wrap
 -- screen effects
 effectfunc = progresswipe
 -- restart menu -- 
 menuitem(1, "restart level", restart)
 -- start cutscene --
 state = 1
 loadlevel(0)
end

function _update60()
 if state==0 then
  -- gameplay --
  gameloop()
  render()
 elseif state == 1 then
  -- cutscene --
  coresume(cocut)
  gameloop()
  rendercutscene()
  if costatus(cocut) == "dead" then
   cocut = nil
   levelswap()
  end
 else
  -- level transition --
  render()
  if transition() then
   if level.cutscene then
    state = 1
   else
    state = 0
   end
  end
 end
end

function gameloop()
  -- update player
 local input = processinput()
 for i=1, level.pcount do
  actors[i]:update(input)
 end
 -- update other actors
 for e in all (entities) do
  e:update()
 end
 -- check exit condition
 if canexit(actors) then
  levelswap()
 end
 -- check if restart was tapped
 if btntap("b",input) > 0 then 
  restart()
 end
end

-- level transition logic --

function levelswap()
 state = 2
 swap = true
 startwipe()
 -- i should use a coroutine instead
 -- but it's not worth rewriting.
end

function transition()
 local parta, partb = progresswipe()
 if parta and swap then
  loadlevel(levelid+1)
  swap = false
 end
 return partb
end

function restart()
 if state==0 then
  loadlevel(levelid)
 end
end

-->8
--animated sprite class--
sprite = {}
sprite.__index = sprite

function sprite:create(offset, total)
 local o = {}
 setmetatable(o, sprite) 
 o.fps = 6
 o.offset = offset
 o.total = total
 o.start = time()
 return o
end

function sprite:getframe()
 local frame = time() - self.start
 frame = frame * self.fps
 return self.offset + (frame % self.total)
end

function sprite:setsprite(id, frames)
 self.offset = id
 self.total = frames
 self.start = time()
end

function sprite:startframe(t)
 self.start += t/self.fps
end

function sprite:gettime()
 return self.total / self.fps
end

---------
--utils--
---------
clock = {}
clock.__index = clock

function clock:create()
 local c = {}
 setmetatable(c, clock)
 c.fin = time()
 return c
end

function clock:start(seconds)
 self.fin = time() + seconds
end

function clock:elapsed()
 return time() >= self.fin
end

--cutscene actor--
dummy = {}
dummy.__index = dummy

function dummy:create(x,y,frame,frames)
 local o = {}
 setmetatable(o, dummy)
 o.x = x
 o.y = y
 o.flip = false
 o.sprite = sprite:create(frame,frames)
 o.lerp = lerp:create()
 o.lerp.posa = {x=x,y=y}
 o.lerp.posb = {x=x,y=y}
 return o
end

function dummy:update()
 local pos = self.lerp:progress()
 self.x = pos.x
 self.y = pos.y
end

function dummy:moveto(x,y,t)
 --x *=8
 --y *=8
 self.lerp:commence(
  self.x,self.y,x,y,t
 )
end

--lerp--
lerp = {}
lerp.__index = lerp

function lerp:create()
 local c = {}
 setmetatable(c, lerp)
 c.posa = {x=0,y=0}
 c.posb = {x=0,y=0}
 c.start = 0
 c.lerptime = 0
 c.percent = 1.0
 c.fin = 1.0
 return c
end

function lerp:commence(x1,y1,x2,y2,t)
 self.start = time()
 self.posa = {x=x1,y=y1}
 self.posb = {x=x2,y=y2}
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
 local l = {}
 l.x = (1-t)*a.x+t*b.x
 l.y = (1-t)*a.y+t*b.y
 return l
end

-->8
--physics--
phy = {}
phy.wall = 0
phy.kill = 1
phy.push = 2
phy.butn = 3
phy.use  = 4
phy.spn  = 6
phy.exit = 7

function aabb(actor)
 --return aabb--
 local x1=actor.x/8
 local y1=actor.y/8
 local x2=(actor.x+7)/8
 local y2=(actor.y+7)/8
 return x1, y1, x2, y2
end

function collision(actor)
 --aabb
 local x1, y1, x2, y2=aabb(actor)
 local a=fget(mget(x1,y1),0)
 local b=fget(mget(x1,y2),0)
 local c=fget(mget(x2,y1),0)
 local d=fget(mget(x2,y2),0)
 return a or b or c or d
end

function snaptofloor(actor, goaly)
 local sign = sgn(actor.vely)
 if sign >= 0 then
  actor.y = flr(goaly/8) * 8
  actor.y += .975 -- buffer
 else
  actor.y = -flr(-goaly/8) * 8
  actor.y += .975
 end
 --  goally = goaly
 return sign
end

function snaptoactor(a, b)
 local sign = sgn(b.y - a.y)
 if sign >= 0 then
  a.y = b.y - (7.0128)
 end
 return sign
end

function trigger(actor)
 local x1, y1, x2, y2=aabb(actor)
 local a=fget(mget(x1,y1))
 local b=fget(mget(x1,y2))
 local c=fget(mget(x2,y1))
 local d=fget(mget(x2,y2))
 return bor(bor(bor(a,b),c),d)
end

function flagsolid(flag)
 return band(flag, 0x1) > 0
end

function flagkills(flag)
 return band(flag, 0x2) > 0
end

function flagisbutton(flag)
 return band(flag, 16) > 0
end

function flagisexit(flag)
 return band(flag, 128) > 0
end

function flagcanuse(flag)
 return band(flag, 25) > 0
end

function ispushable(ent)
 return fget(ent.sprite:getframe(),2)
end

function hashurtbox(ent)
 return fget(ent.sprite:getframe(),1)
end

function isbutton(ent)
 return fget(ent.sprite:getframe(),3)
end

function issolid(ent)
 return fget(ent.sprite:getframe(),0)
end

-- can be reused for entities too
function actorcollision(cmp, actors)
 for k,v in pairs(actors) do
  if v != cmp then
   if abbacollision(cmp, v) then
    if issolid(v) then
     return true, v
    end
   end
  end
 end
 return false
end

-- can be reused for entities too
function actortrigger(cmp, actors)
 local flags = 0
 for k,v in pairs(actors) do
  if v != cmp then
   if abbacollision(cmp, v) then
    sflag = fget(v.sprite:getframe())
    flags = bor(flags, sflag)
   end
  end
 end
 return flags
end

function abbacollision(a, b)
 local x1, y1, x2, y2=aabb(a)
 local u1, v1, u2, v2=aabb(b)
 -- todo (y might be swapped)
 return x1 <= u2 and x2 >= u1
  and y1 <= v2 and y2 >= v1
end

function pointcollision(p, a)
 local x1, y1, x2, y2=aabb(a)
 return p.x >= x1 and p.x <= x2
  and p.y >= y1 and p.y <= y2
end

function headclear(cmp, actors)
 -- replace with an aabb check?
 local skin = 2  --buffer
 local left = {}
 left.x = (cmp.x+0)/8
 left.y = (cmp.y-skin)/8
 local righ = {}
 righ.x = (cmp.x+7)/8
 righ.y = (cmp.y-skin)/8
 for k,v in pairs(actors) do
  if v != cmp then
   local l, r
   l = pointcollision(left, v)
   r = pointcollision(righ, v)
   if l or r then
    return false
   end
  end
 end
 return true
end

function stepup(goal)
 -- only for tiles (for now)
 local step = 1 -- one pixel
 local newpos = {}
 newpos.x = goal.x
 newpos.y = goal.y - step
 return not collision(newpos), newpos
end

function calcgrav(height, apex)
 local gravity =
  -(2 * height) / (apex ^ 2)
 local jmpvelocity = 
  abs(gravity * apex)
 return gravity, jmpvelocity
end

-->8
--input--
thisframe = {a=0, b=0, y=0}
lastframe = {a=0, b=0, y=0}

function processinput()
 local input = {
  x = 0,
  y = 0,
  a = 0,
  b = 0
 }
 
 if(btn(0)) input.x = -1
 if(btn(1)) input.x =  1 
 --if(btn(2)) input.y = -1
 if(btn(3)) input.y = 1
 if(btn(4)) input.a = 1
 if(btn(5)) input.b = 1
 
 lastframe.a = thisframe.a
 lastframe.b = thisframe.b
 lastframe.y = thisframe.y
 thisframe.a = input.a
 thisframe.b = input.b
 thisframe.y = input.y
 
 return input
end

function emptyinput()
 return {
  x = 0,
  y = 0,
  a = 0,
  b = 0
 }
end

function btntap(b, input)
 if input[b] >=1
   and lastframe[b] <= 0 then 
    return 1
  end
 return 0
end

function btnheld(b)
 return thisframe[b]>=1 and
  thisframe[b] == lastframe[b]
end

-----------------
--cutscene data--
-----------------
cocut = nil

function waitforclock(c)
 while(not c:elapsed()) do yield() end
end

function coendinga()
 ---------
 --setup--
 ---------
 music(16)
 state = 1
 local sceneclock = clock:create()
 local dog = dummy:create(15*8,11*8, 236,4)
 local ply = dummy:create(0*8,11*8, 192,6)
 -- add to level
 add(entities, dog)
 add(entities, ply)
 --------------------
 -- start cutscene --
 --------------------
 -- walk towards eachother
 dog.flip = true
 dog:moveto(7.9*8,11*8,2)
 ply:moveto(7*8,11*8,2)
 sceneclock:start(2)
 waitforclock(sceneclock)
 -- greet
 dog.flip = false
 dog.sprite:setsprite(254,2)
 ply.sprite:setsprite(252,2)
 sceneclock:start(4)
 waitforclock(sceneclock)
 -- move outside
 --levelswap()
 return
end

function coendingb()
 --setup
 state = 1
 local sceneclock = clock:create()
 local squirrel = dummy:create(16*8,11*8, 222,2)
 local dog = dummy:create(15*8,11*8, 236,4)
 local ply = dummy:create(0*8,11*8, 192,6)
 local doga = dummy:create(16*8,11*8, 210,4)
 local dogb = dummy:create(17*8,11*8, 214,4)
 local dogc = dummy:create(18*8,11*8, 218,4)
 -- add to level
 add(entities, dog)
 add(entities, ply)
 add(entities, doga)
 add(entities, dogb)
 add(entities, dogc)
 add(entities, squirrel)
 
 -- walk out of cave
 dog.x = 18*8
 ply.x = 17*8
 dog.flip = true
 ply.flip = true
 squirrel.flip = true
 dog.sprite:setsprite(236,4)
 ply.sprite:setsprite(192,6)
 dog:moveto(-1*8,11*8,4)
 ply:moveto(-2*8,11*8,4)
 sceneclock:start(4)
 waitforclock(sceneclock)
 
 -- wait a bit
 sceneclock:start(3)
 waitforclock(sceneclock)
 
 -- doggy woggies
 doga:moveto(-3*8,11*8,4)
 dogb:moveto(-2*8,11*8,4)
 dogc:moveto(-1*8,11*8,4)
 sceneclock:start(4)
 waitforclock(sceneclock)
 
 -- squirrel 
 sceneclock:start(2)
 waitforclock(sceneclock)
 squirrel:moveto(7*8, 11*8, 2)
 sceneclock:start(2)
 waitforclock(sceneclock)
 squirrel.sprite:setsprite(223,1)
 sceneclock:start(3)
 waitforclock(sceneclock)
 squirrel.sprite:setsprite(222,2)
 squirrel:moveto(-1*8, 11*8, 2)
 sceneclock:start(3)
 waitforclock(sceneclock)
 -- remove so they don't render
 entities = {}
 return
end

function coopening()
 --setup--
 state = 1
 local sceneclock = clock:create()
 local squirrel = dummy:create(-2*8,11*8, 222,2)
 local dog = dummy:create(-4*8,11*8, 236,4)
 local ply = dummy:create(-6*8,11*8, 192,6)
 local brk = dummy:create(-3*8,11*8, 242,8)
 -- add to level
 add(entities, squirrel)
 add(entities, dog)
 add(entities, brk)
 add(entities, ply)
 --start--
 squirrel:moveto(16*8,11*8,3)
 dog:moveto(16*8,11*8,4)
 ply:moveto(16*8,11*8,5)
 brk:moveto(17*8, 11*8,4)
 sfx(4)
 --playout--
 sceneclock:start(8)
 waitforclock(sceneclock)
 --start game/music--
 entities = {}
 music(0)
 return
end

-->8
--player class--
actor = {}
actor.__index = actor

function actor:create(x, y)
 local o = {}
 setmetatable(o, actor) 
 -- position
 o.x = x
 o.y = y
 o.velx = 0
 o.vely = 0
 o.oldx = x
 o.oldy = y
 -- collision
 o.wall = false
 o.grounded = false
 o.isalive = true
 o.jmpleeway = false
 o.use = false
 o.hint = false
 o.fin = false
 -- sprite and animation
 o.sprite = sprite:create(192, 1)
 o.face = 1
 o.flip = false
 o.clock = clock:create()
 return o
end

function actor:update(input)
 if (self.isalive) then
  self:move(input)
  self:trigger(input)
  self:animate()
  self:finish()
 else
  self:move(emptyinput())
  self:animatedead()
 end
end

function actor:move(input)
 --setup--
 local goal = {}
 local jmp = 0
 local collided = false
 if btntap("a",input)>0 and self.grounded then
  if headclear(self, actors) then
   jmp = -1.05  --1.5 in 30
  end
 end
 self.vely += jmp + .05 --.1 in 30
 self.vely = min(self.vely, 5)
 goal.x = self.x + (input.x/2)
 goal.y = self.y + self.vely
 --animation setup--
 if (input.x != 0) then
  self.face = input.x
 end
  self.flip = self.face < 0
 --move--
 -- x collision
 local xgoal = {x = goal.x, y = self.y}
 collided = collision(xgoal)
 -- check if you can "walk" up
 if collided and self.grounded then
  local step, pos = stepup(xgoal)
  collided = not step
  if (not collided) then
   goal.x = pos.x
   goal.y = pos.y
   xgoal.y = pos.y
  end
 end
 self.wall = collided
 -- x collision continue
 if (not collided) then
  self.x = goal.x
  if actorcollision(self, actors) then
   self.x = self.oldx
   self.wall = true
  end
  local hit,e=actorcollision(self, entities)
  if hit then
   local dirx = sgn(self.x-self.oldx)
   self.x = self.oldx
   self:push(e, dirx)
   self.wall = true
  end
 end
 -- y collision
 local ygoal = {x = self.x, y = goal.y}
 local rbody = false
 collided = collision(ygoal)
 if (not collided) then
  self.y = goal.y
  self.grounded = false
  collided, a = actorcollision(self, actors)
  if collided then
   rbody = a
   self.y = self.oldy
  end
  local hit,a=actorcollision(self, entities)
  if hit then
   rbody = a
   collided = true
   self.y = self.oldy
   if ispushable(a) then
    if a.y > self.y then
     a:parent(self)
    end
   end
  end
 end
 -- snap to tile if collided
 if collided then
  local sign 
  if rbody then
   -- hit an actor
   sign = snaptoactor(self, rbody)
  else
   -- hit a tile
   sign = snaptofloor(self, goal.y)
  end
  if (sign >= 0) then
   if rbody then
    -- boxes will force it to true
    self.grounded = rbody.grounded
   else
   self.grounded = true 
  end
  else
   self.grounded = false
   sfx(0)
  end
  self.vely = 0 
 end
end

function actor:push(ent, dirx)
 if ispushable(ent) and self.grounded then
  if ent:push(dirx) then
   self.x = self.oldx + (dirx*.5)
  end
 end
end

function actor:trigger(input)
 -- check tile flags first
 local flags = trigger(self)
 flags = bor(flags, actortrigger(self, entities))
 --debuggy = flags
 
 self.use = btntap("y",input) > 0
 self.hint = flagcanuse(flags)
 self.fin = flagisexit(flags) and self.grounded
 
 if flagkills(flags) then
  self:die()
 end
 
end

function actor:die()
 if (self.isalive) then
  --only die once!
  sfx(5)
  self.isalive = false
  self.use = false
  self.hint = false
  self.fin = false
  self.sprite:setsprite(199,3)
  local t = self.sprite:gettime()
  self.clock:start(t)
 end
end

-- animation funcs --

function actor:animate()
 -- quick fix
 if (not self.isalive) then
  return
 end

  -- update player sprite --
 if (self.wall == true) then
  --wall push
  self.sprite:setsprite(198, 1)
 elseif (self.x == self.oldx) then
  --idle
  self.sprite:setsprite(192, 1)
 elseif not self:iswalking()  then
  --walk
  self.sprite:setsprite(192, 6)
 end
end

function actor:iswalking()
 return 
  self.sprite.offset == 192
  and self.sprite.total == 6
end

function actor:animatedead()
 if (self.clock:elapsed()) then
  self.sprite:setsprite(201,1)
 end
end

-- cleanup --

function actor:finish()
  -- save old position
 self.oldx = self.x
 self.oldy = self.y
end

-->8
-- level --
levelid = 0
level = {}    -- current level
actors = {}   -- players
entities = {} -- boxes,etc...

function loadlevel(id)
 -- setup the level
 levelid = id
 level = getleveldata(id)
 
 -- clear previous level
 actors = {}
 entities = {}
 
 --check if cutscene level
 if level.cutscene then
  cocut = cocreate(level.cutscene)
 end
 
 -- setup players
 actors = {} -- clear actors
 for i=1, level.pcount do
  local stripe = i*2
  actors[i] =
   actor:create(
    (level.spawns[stripe-1])*8, 
    (level.spawns[stripe])*8, 
    0)
 end
 
 -- setup actors/entities 
 if (level.doors) then
  for i=1, #(level.doors), 4 do
    add(entities, 
       door:create(
       level.doors[i]*8,
       level.doors[i+1]*8,
       level.doors[i+2] > 0,
       level.doors[i+3] > 0
     )
    )
  end
 end
 if (level.boxes) then
  for i=1, #(level.boxes), 2 do
    add(entities, 
       box:create(
       level.boxes[i]*8,
       level.boxes[i+1]*8
     )
    )
  end
 end
 local function initswitch(tbl, create)
  if tbl then
   for i=1, #(tbl), 3 do
     -- setup tables
     local doors = {}
     for d in all (tbl[i+2]) do
      add(doors, entities[d])
     end
    
     add(entities, 
        create(
        tbl[i]*8,
        tbl[i+1]*8,
        doors
      )
     )
   end
  end
 end
 initswitch(level.switches, switch.create)
 initswitch(level.buttons, button.create)
 if level.crawlers then
  for i=1, #(level.crawlers), 2 do
    add(entities, 
       crawler:create(
        level.crawlers[i]*8,
        level.crawlers[i+1]*8
     )
    )
    end
 end
 if level.adders then
  local p = add(entities,
   particle:create(
   level.adders[1]*8,
   (level.adders[2]-1)*8
   )
  )
  local function ckb()
   startflash(6)
   music(-1)
   sfx(3)
   --pcount before added player
   music(level.pcount * 4, 1500)
   del(entities, p)
  end
  add(entities,
   adder:create(
    level.adders[1]*8,
    level.adders[2]*8,
    ckb
   )
  )
 end
end

function gettileid(actor)
 -- returns a unique id for each tile
 local tilexscreen = 16
 local x = flr(actors[1].x/8)
 local y = flr(actors[1].y/8)
 return (x * tilexscreen) + y
end

function canexit()
 local ecount = 0
 local allexit = true
 for a in all (actors) do
  -- makesure a single actor
  -- isn't at two exits
  allexit = allexit and a.fin
 end
 if (level.exits) then
  for i=1, #(level.exits), 2 do
    local pos = {}
    pos.x = level.exits[i]*8
    pos.y = level.exits[i+1]*8
    if actorcollision(pos, actors) then
      ecount += 1
    end
  end
 end
 return allexit and ecount >= level.pcount
end

-- add a new actor while in play
function addactor(x, y)
 level.pcount += 1
 actors[level.pcount] = 
  actor:create(x, y)
end

----------
-- data --
----------
function getleveldata(id)
 -- could use mget to grab data
 -- insead...
 local levels = {}
 levels[0] = {
  u = 0,
  v = 0,
  pcount = 1,
  spawns = {0,14},
  water = {0, 13*8, 128, 24},
  sky = {0,1,2},
  cutscene = coopening
 }
 levels[1] = {
  u = 16,
  v = 0,
  pcount = 1,
  spawns = {17,14},
  doors = {26,05,0,0},
  switches = {23,6,{1}},
  exits = {30,4}
 }
 levels[2] = {
  u = 32,
  v = 0,
  pcount = 1,
  spawns = {33, 4},
  boxes = {43,7},
  doors = {36,10,0,0},
  buttons = {40,10,{1}},
  exits = {33,10}
 }
 levels[3] = {
  u = 48,
  v = 0,
  pcount = 1,
  spawns = {49,2},
  doors = {53,3,0,0, 53,9,0,0, 57,9,0,0},
  boxes = {60, 04},
  crawlers = {61,1},
  buttons = {57,04,{1}, 61,10,{2,3}},
  adders = {55,13},
  exits = {60,14,62,13}
 }
 levels[4] = {
  u = 64,
  v = 0,
  pcount = 2,
  spawns = {65,13, 67,13},
  doors = {73,05,0,1},
  switches = {77,12,{1}},
  boxes = {73,0},
  exits = {65,10, 76,12}
 }
 levels[5] = {
  u = 80,
  v = 0,
  pcount = 2,
  spawns = {81,10, 81,6},
  boxes = {85,14},
  doors = {93,6,1,0},
  switches = {93,12,{1}},
  crawlers = {81,13},
  exits = {94,12, 92,6},
 }
 levels[6] = {
  u = 96,
  v = 0,
  pcount = 2,
  spawns = {97,11, 98,12},
  doors = {101,12,0,0, 103,12,0,0, 105,12,0,0, 107,12,0,0},
  switches = {
   103,7,{1,3,4}, 
   105,7,{2,4}, 
   107,7,{1,2},
   109,7,{1,2,3},
   108,12,{1}
  },
  exits = {109,12, 110,12},
 }
 levels[7] = {
  u = 112,
  v = 0,
  pcount = 2,
  spawns = {113,9, 113,11},
  adders = {124,12},
  exits = {125,13, 126,13, 113,05},
  water = {0,14.75*8,width,16},
  --fall = {(6*8)+2,0,12,118}
 }
 levels[8] = {
  u = 0,
  v = 16,
  pcount = 3,
  --spawns = {0,16, 0,17, 0,18},
  spawns = {1,18, 2,18, 14,28},
  boxes = {9,21, 3,23},
  doors = {12,28,0,0, 5,20,0,1, 8,26,0,1},
  buttons = {13,21,{2}},
  switches = {11,28,{1}, 14,25,{3}},
  exits = {2,25, 6,26, 6,28}
 }
 levels[9] = {
  u = 16,
  v = 16,
  pcount = 3,
  spawns = {17,28, 30,27, 30,30},
  doors = {
   --section 1
    20,28,1,1,
    22,27,0,1,
    24,26,1,1,
   --section 2
    30,25,0,1,
    27,24,0,1,
    30,23,1,1,
    27,22,1,1,
   --section 3
    22,22,1,1,
    19,22,1,1,
   --actor doors
    26,27,0,0,
    26,30,0,0,
  },
  crawlers = {17,17, 26,17},
  buttons = {19,17,{1,2,3,8,9}, 28,17,{4,5,6,7}},
  switches = {17,21,{10,11}},
  exits = {16,24, 27,25, 28,25}
 }
 levels[10] = {
  u = 32,
  v = 16,
  pcount = 3,
  spawns = {33,29, 33,24, 33,19},
  exits = {45,18, 45,24, 45,29}
 }
 levels[11] = {
  u = 48,
  v = 16,
  pcount = 3,
  spawns = {49,18, 55,30, 61,18},
  doors = {
   51,18,0,0, 
   59,18,0,0, 
   55,21,1,1, 
   61,23,1,1, 
   59,24,0,0, 
   59,25,0,1
  },
  switches = {54,30,{1,4,6}, 57,30,{2,3,6}, 49,30,{5}},
  boxes = {58,27},
  adders = {51,24},
  exits = {60,30, 60,30, 60,30, 56,30}
 }
 levels[12] = {
  u = 64,
  v = 16,
  pcount = 4,
  spawns = {65,22, 65,26, 73,22, 78,30},
  boxes = {67,22},
  doors = {68,23,0,1, 75,30,1,1, 78,29,1,1, 75,28,1,1},
  buttons = {75,22,{2}, 76,22,{3}},
  switches = {70,20,{1}, 69,30,{4}},
  --water = {8, 14.5*8, 8*5, 4},
  exits = {73,30, 65,29, 70,22, 78,22}
 }
 levels[13] = {
  u = 80,
  v = 16,
  pcount = 4,
  spawns = {82,25, 81,25, 81,29,82,29},
  exits = {93,29, 94,29, 94,24, 90,17},
  water = {0,14.75*8,width,16},
  fall = {(7*8), 87, 15, 30}
 }
 levels[14] = {
  u = 96,
  v = 16,
  pcount = 4,
  spawns = {97,22, 97,24, 97,26, 97,28},
  --boxes = {108,25},
  doors = {103,29,1,1},
  switches = {110,22,{1}},
  exits = {103,25, 103,26, 103,27, 103,28}
 }
 levels[15] = {
  u = 112,
  v = 16,
  pcount = 1,
  spawns = {112,16},
  cutscene = coendinga
 }
 levels[16] = {
  u = 0,
  v = 0,
  pcount = 1,
  spawns = {0,14},
  water = {0, 13*8, 128, 24},
  sky = {12,9,13},
  cutscene = coendingb
 }
 levels[17] = {
  u = 112,
  v = 16,
  pcount = 8,
  spawns = {
   112,18, 114,18, 116,18, 118,18,
   120,18, 122,18, 124,18, 126,18,
   },
 }
 return levels[id]
end

-->8
-- renderer --
effectpos = 0
clrcolor = 0
lvlcolor = 0

function swappallet(id)
 -- player pallets
 local ppal = {   
  {8 , 12},
  {12,  3},
  {11,  2},
  {14,  6}
 }
 if id > #(ppal) then id = (id%(#ppal)+1) end
 for i=1, 2 do
  pal(ppal[1][i], ppal[id][i])
 end
end

function rendercutscene()
 --quick fix for opening/ending
 cls()
 rendersky()
 drawlevel()
 for e in all (entities) do
  spr(e.sprite:getframe(),e.x,e.y,1.0,1.0,e.flip,false)
 end
 renderwater()
 drawhud()
end

function render()
 cls(clrcolor)
 rendersky()
 drawlevel()
 drawentities()
 drawactors()
 renderwater()
 drawhud()
 clrcolor = lvlcolor
end

function drawlevel()
 map(level.u,level.v,0,0,16,16)
end

function drawactors()
 for i=1, level.pcount do
  swappallet(i)
  a = actors[i]
  spr(a.sprite:getframe(),
      a.x%wrap,  a.y%wrap,
      1.0, 1.0,
      a.flip, false
  )
  --drawtrigger(a)
  --drawheadcheck2(a)
  if a.hint then
   displayhint(a, "ƒ")
  end
  if a.fin then
   displayhint(a, "Š")
  end
 end
 pal() -- reset pallet
end

function drawentities()
 for e in all (entities) do
  spr(e.sprite:getframe(),e.x%wrap,e.y%wrap)
 end
end

function renderwater()
 if level.fall then
  local w = level.fall
  waterfall(w[1],w[2],w[3],w[4])
 end
 if level.water then
  local w = level.water
  drawwater(w[1],w[2],w[3],w[4])
 end
end

function rendersky()
 if level.sky then
  s = level.sky
  --drawsunset()
  drawsky(s[1],s[2],s[3])
 end
end

function drawhud()
 -- restart string --
 local failed = false
 for i=1, level.pcount do
  if not actors[i].isalive then
   failed = true
   break
  end
 end
 if failed then 
  rectfill((width/2)-11, height-9,(width/2)+17, height-9, 2)
  rectfill((width/2)-12, height-8,(width/2)+18, height-3, 2)
  rectfill((width/2)-11, height-2,(width/2)+17, height-2, 2)
  print("restart", (width/2)-9, height-7, 1)
  print("restart", (width/2)-10, height-8, 7)
 end
 -- title screen --
 if levelid == 0 then
  print("dogrotto", (width/2)-16, 12, 5)
  print("dogrotto", (width/2)-16, 11, 6)
  print("dogrotto", (width/2)-16, 10, 7)
 end
 -- end screen --
 if levelid == 17 then
  print("thanks for playing", (width/2)-35,(height/2)-1,1) 
  print("thanks for playing", (width/2)-36,(height/2)-2,7) 
  print("by zee",(width/2)-11,(height/2)+7,1) 
  print("by zee",(width/2)-12,(height/2)+6,7) 
  print("dedicated to my dogs",(width/2)-40,(height-8),6)  
 end
 -- debug strings --
 --print("fps: ", 5, 5, 3)
 --print(stat(7), 20, 5, 3)
 --print("cpu: ", 5, 15, 3)
 --print(stat(1), 20, 15, 3)
 --print(debuggy, 70, 100, 7)
end

function displayhint(a, msg)
 print(msg, a.x%wrap,(a.y%wrap)-5,1) 
 print(msg, a.x%wrap,(a.y%wrap)-6,7) 
end

-----------------
-- screen wipe --
-----------------

function startwipe()
 local sec = .5
 effectpos = time()
 effectfunc = progresswipe
end

function progresswipe()
 local progress = time() - effectpos
 progress *= 2
 screenwipe(min(progress,2))
 return 
  progress >= 1,
  progress >= 2
end

function screenwipe(percent)
 color(0)
 local x1 = (width * percent)-(width)
 local x2 = width * min(percent,1)
 rectfill(x1,0,x2,height)
end

------------------
-- screen flash --
------------------

function startflash(c)
 clrcolor = c
end

------------------
--water effects --
------------------
function setwaterpallet()
 pal(0,13)
 --pal(8, 13)
 --pal(12, 5)
end

function drawwater(x, y, w, h)
 setwaterpallet()
 -- init values
 local amp = 1.5
 local frac = time() / 5
 local wave = 0 --height of wave
 local shim = {}
 local waves = {}
 local c = 0    -- pixel to mirror
 local skip = 1 -- dither foam
 local waveamp = 3
 local bob = sin(frac)
 
 -- prebake values for speed
 for j=0, h+waveamp do
  shim[j] = cos(time()+(j/25))
 end
 
 -- start drawing the water
 for i=x, w+x do
  wave=sin((2*frac)+i/100) * amp
  wave += bob
  waves[i] = wave
  for j=2, h-wave do
   local xval = i+(shim[j])
   -- avoid offscreen values
   if xval < 0 then xval = 0 end
   c = pget(xval,(y-j))
   pset(i, y+j+wave, c)
  end
 end
 
 -- draw foam
 for i=x, x+w do
  -- a separate loop avoids
  -- duplication of foam
  pset(i, y+waves[i], 7)
  if skip%2 > 0 then
   pset(i, y+waves[i]+1, 7)
  end
  skip += 1
 end

 -- reset pallet
 pal() 
end

function getwaterheight(x)
 local amp = 1.5
 local bob = sin(time() / 5)
 return sin((2*frac)+x/100) * amp + bob
end

-------------
--waterfall--
-------------
function falldither()
 local dither = {}
 dither[0] = 0b0000000101010111.1
 dither[1] = 0b0000010001011101.1
 dither[2] = 0b0000000010101110.1
 return dither[flr((time()*8)%3)]
end

function waterfall(x,y,w,h)
 --transparency+water
 pal(0,12)
 local c
 local skip = 1
 for i=x, x+w do
  for j=y+1, y+1+h do
   if skip%2 > 0 then
    c = pget(i,j)
    pset(i,j,c)
   else
    pset(i,j,12)
   end
   skip += 1
  end
 end
 pal()
 
 -- draw top
 color(6)
 rectfill(x+1, y, x+w-1, y)
 
 -- draw top splashes
 local stamp = flr(8*time())
 skip = stamp
 for i=x, x+w do
  --top splash
  if stamp%2 <= 0 and skip%4 == 0 then
   pset(i,y-2,6)
   pset(i,y+h-3,6)
  end
  --bot splash
  if stamp%2 >= 1 and skip%4 > 1 then
   pset(i,y-1,6)
   pset(i,y+h-2,6)
  end
  skip +=1
 end

 -- animate top
 dither = falldither()
 fillp(dither)
 rectfill(x, y+1, x+w, y+3)
 
 -- fall lines
 local half = flr(h/2)
 local l = y+(50*time())%half
 rectfill(x, l+1, x+w, l+2)
 rectfill(x, l+half+1, x+w, l+half+2)
 
 -- reset dither, start bottom splash
 fillp()
 -- move splash up and down with water
 local bob = sin(time() / 5)
 rectfill(x, bob+y+h+1, x+w, bob+y+h+1)
 if stamp%3 > 0 then
  rectfill(x+1, bob+y+h, x+w-1, bob+y+h)
 end
 if stamp%3 == 1 then
  rectfill(x+2, bob+y+h-1, x+w-2, bob+y+h-1)
 end
end

------------------
--background--
------------------
function drawsky(a,b,c)
 -- draw fills
 color(a)
 rectfill(0,0, width, 22)
 color(b)
 rectfill(0,22, width, 64)
 color(c)
 rectfill(0,64, width, height)
 
 -- gradiant/ditther --
 color(a)
 drawgradient(20)
 color(b)
 drawgradient(62)
 
 --reset color settings
 color(0)
 fillp()
end

function drawgradient(height)
 local gradients = {
  0b1000000000100000.1, 
  0b1010010010100001.1,
  0b1010010110100101.1,
  0b1010010110100101.1,
  0b1110010110110101.1,
  0b1111110111110111.1
 }
 height -= 4
 for i=1, 6 do
  fillp(gradients[i])
  local y = (4*i) + height 
  rectfill(0, y+3, width, y)
 end
end

------------------
-- debug --
------------------

function drawhitbox(a)
 -- todo draw boxcast too?
 local x1, y1, x2, y2=aabb(a)
 x1 *=8
 y1 *=8
 x2 *=8
 y2 *=8
 color(7)
 line(x1,y1,x1,y2)
 line(x1,y1,x2,y1)
 line(x2,y2,x2,y1)
 line(x2,y2,x1,y2)
end

function drawtrigger(a)
 local x1, y1, x2, y2=aabb(a)
 x1 *=8
 y1 *=8
 x2 *=8
 y2 *=8
 color(3)
 circfill(x1, y1, 1)
 circfill(x1, y2, 1)
 circfill(x2, y1, 1)
 circfill(x2, y2, 1)
end

function drawheadcheck(a)
 color(7)
 local skin = 2  --buffer
 local height = 8 --actor height
 pnt = {x=a.x+4,y=a.y-skin}
 circfill(pnt.x, pnt.y, 1)
end

function drawheadcheck2(a)
 local skin = 2  --buffer
 x1 = a.x/8
 y1 = a.y/8
 x2 = (a.x+7)/8
 y2 = (a.y-skin)/8
 x1 *=8
 y1 *=8
 x2 *=8
 y2 *=8
 color(7)
 line(x1,y1,x1,y2)
 line(x1,y1,x2,y1)
 line(x2,y2,x2,y1)
 line(x2,y2,x1,y2)
end

-->8
-- entities and monsters --

--------
--door--
--------
door = {}
door.__index = door

function door:create(x, y, opn, trap)
 local o = {}
 setmetatable(o, door)
 o.x = x
 o.y = y
 o.grounded = true
 o.timer = clock:create()
 o.opened = opn
 o.off = 0
 if trap then o.off = 4 end
  o.sprite = sprite:create(114+o.off, 1)
 if opn then
  o.sprite:setsprite(116+o.off, 1)
 end
 return o
end

function door:update()
 if self.timer:elapsed() then
  if self.opened then
   self.sprite:setsprite(116+self.off, 1)
  else
   self.sprite:setsprite(114+self.off, 1)
  end
 end
end

function door:open()
 if not self.opened then
  self.opened = true
  self.sprite:setsprite(114+self.off,2)
  local sec = self.sprite:gettime()
  self.timer:start(sec)
  sfx(1)
 end
end

function door:close()
 if self.opened then
  self.opened = false
  self.sprite:setsprite(116+self.off,2)
  local sec = self.sprite:gettime()
  self.timer:start(sec) 
  sfx(2)
 end
end

function door:toggle()
 if self.opened then
  self:close()
 else
  self:open()
 end
end

----------
--switch--
----------
switch = {}
switch.__index = switch

function switch.create(x, y, ids)
 -- doorid, openonswitch
 local s = {}
 setmetatable(s, switch)
 s.doors = ids
 s.sprite = sprite:create(130, 1)
 s.x = x
 s.y = y
 return s
end

function switch:update()
 self:checktrigger()
end

function switch:toggle()
 self.sprite.offset += sgn(130 - self.sprite.offset)
 for d in all (self.doors) do
  d:toggle()
 end
end

function switch:checktrigger()
 local hit, a = actorcollision(self, actors)
 if hit then
  if a.use then self:toggle() end
 end
end

----------
--button--
----------
-- todo: create a generic trigger class
-- and inhert for switch and button?
button = {}
button.__index = button

function button.create(x, y, ids)
 local b = {}
 setmetatable(b, button)
 b.doors = ids
 b.sprite = sprite:create(146, 1)
 b.x = x
 b.y = y
 b.pressed = false
 return b
end

function button:update()
 if self:ispressed() != self.pressed then
  self.pressed = not self.pressed
  self:toggle()
 end
end

function button:ispressed()
 local hit = actorcollision(self, actors)
 if not hit then
  local flag = actortrigger(self, entities)
  hit = flagsolid(flag) or flagkills(flag)
 end
 return hit
end

function button:toggle()
 local id = 146
 if self.pressed then id+=1 end 
 self.sprite.offset = id
 for d in all (self.doors) do
  d:toggle()
 end
end

-------
--box--
-------
box = {}
box.__index = box

function box:create(x, y)
 local o = {}
 setmetatable(o, box) 
 o.x = x
 o.y = y
 o.oldx = x
 o.oldy = y
 o.vely = 0
 o.grounded = false
 o.sprite = sprite:create(144, 1)
 o.riders = {}
 return o
end

function box:update()
 self:fall()
 self:ride()
 self.oldx = self.x
 self.oldy = self.y
end

function box:fall()
 local oldy = self.y
 self.vely += .025/2
 self.vely = min(self.vely, 1.0)
 local goal = {
  x = self.x,
  y = self.y + self.vely
  --y = self.y + .2
 }
 if not collision(goal) then
  self.y = goal.y
  self.grounded = false
 else
  snaptofloor(self, goal.y)
  self.grounded = true
  self.vely = 0
 end
 if actorcollision(self, actors) then
  self.y = oldy
  self.grounded = true
  self.vely = 0
 end
 if actorcollision(self, entities) then
  self.y = oldy
  self.grounded = true
  self.vely = 0
 end
end

function box:push(dirx)
 -- ignore air pushes
 if not self.grounded then
  return false
 end
 -- else
 local flag = 0
 local oldx = self.x
 local oldy = self.y
 local goal = {
  x = self.x + (dirx * .5),
  y = self.y
 }
 local collided = collision(goal)
 if collided then
  local step, pos = stepup(goal)
  if step then 
   goal = pos 
   collided = false
  end
 end
 if not collided then
  self.x = goal.x
  self.y = goal.y
 end
 if actorcollision(self, actors) then
  self.x = oldx
  self.y = oldy
 end
 flag = actortrigger(self, entities)
 if flagsolid(flag) or flagkills(flag) then
  self.x = oldx
  self.y = oldy
 end
 -- return if pushed
 return self.x == goal.x
end

function box:parent(actor)
 add(self.riders, actor)
end

function box:ride()
 local deltay = self.y - self.oldy
 for k,v in pairs(self.riders) do
  v.y += deltay
  v.grounded = true
 end
 -- kick them off
 self.riders = {}
end

-----------
--crawler--
-----------
crawler = {}
crawler.__index = crawler

function crawler:create(x, y)
 local o = {}
 setmetatable(o, crawler) 
 o.x = x
 o.y = y
 o.dirx = 1
 o.vely = 0
 o.isgrounded = true
 o.sprite = sprite:create(176,2)
 return o
end

function crawler:update()
 if self.grounded then 
  self:movex()
 end
 self:movey()
end

function crawler:movex()
 local speed = .3
 local oldx = self.x
 goal = {
  x = self.x+(self.dirx*speed),
  y = self.y
 }
 local hit = collision(goal)
 if hit then
  local step, pos = stepup(goal)
  if step then 
   goal = pos
   hit = false
  end
 end 
 hit = hit or actorcollision(goal, entities)
 if not hit then
  self.x = goal.x
  self.y = goal.y
 else
  self.x = oldx
  self.dirx = -sgn(self.dirx)
 end
end

function crawler:movey()
 local vel = .025/2
 local oldy = self.y
 self.vely += vel
 self.vely = min(self.vely, 1.0)
 goal = {
  x = self.x,
  y = self.y + self.vely
 }
 if not collision(goal) then
  self.y = goal.y
  self.grounded = false
 else
  snaptofloor(self, goal.y)
  self.grounded = true
  self.vely = 0
 end
 local hit,a=actorcollision(self, entities)
 if hit then
  snaptoactor(self, a)
  self.grounded = true
  self.vely = 0
 end
end

-----------
---adder---
-----------
adder = {}
adder.__index = adder

function adder:create(x,y,event)
 local o = {}
 setmetatable(o, adder) 
 o.x = x
 o.y = y
 o.sprite = sprite:create(24,2)
 o.event = event
 o.touched = false
 return o
end

function adder:update()
 if not self.touched then
  self:checktrigger()
 end
end

function adder:checktrigger()
 local hit,a = actorcollision(self, actors)
 if hit then 
  if self.event then self.event() end 
   addactor(self.x-(a.face*8),self.y)
   a.x = (self.x+(a.face*8))
   self.touched = true -- lol
   self.sprite:setsprite(92,1)
 end
end

------------
--particle--
------------
particle = {}
particle.__index = particle

function particle:create(x,y)
 local o = {}
 setmetatable(o, particle) 
 o.x = x
 o.y = y
 o.sprite = sprite:create(24,2)
 o.sprite:startframe(1)
 return o
end

function particle:update() end
__gfx__
00000000bbbbbbbb4444444444444444bbbbbbbbbbbbbbbb44444444bbbbbbbb7696686544454454588888850111111100008888888888855888888888888888
00000000bb33bbb30444444444444444b33bbb33bb33bbb34464444433bbb33b7666666555555555556555550000010000555655556555555555565555555655
00700700b3443b35044444444444444435533344b3443b3446666444443335531766665166656666665666661111101100666566665666666666656666666566
00077000344443550044444444444444000554443444434444664444444550001176651155565555665666661111101106666566665666666666656666666566
00077000444444550044444444444444000005444444444444444464445000000076650066666566555565550001000005565555555565555556555555565555
00700700444444550000000000000000000000544444444444444664450000001176651166666566666656661110111106656666666656666665666666656666
00000000444444550000000000000000000000054444444444444464500000001176651155555655666656661110111100056666666656666665666666656666
00000000444444550000000000000000000000004444444444444444000000000007500056666666555565550001000000005555555565555556555555565555
333333334444444444444444aaaaaaaabbbbbbbb5444444444444445bbbbbb0000a9000000099a00551111118888800066655444444556660000000000000000
333333333434344344444444aaaaaaaa3b33bbb30544444444444450bb33bbb000a999000999aa00500001005555560055654444444456550555555005555550
333333333333333344444444aaaaaaaa43443b340544444444444450b3443b3b00aa0900090aa000511110116666656066554444444455660511115005666650
333333333333333344444444aaaaaaaa44444344005444444444450034444343000aa90009aa9000551110116666656066555444444555660511115005666650
333333333333333344444444aaaaaaaa444444440054444444444500444444440009aa0000a09900500100005556555555554444444455555555555555555555
333333333333333344444444aaaaaaaa4444444405444444444444504444444400990aa000a00900511011116665666666654444444456661115111166656666
333333333333333344444444aaaaaaaa4444444405444444444444504444444400990aa000aa9900551011116665666666655444444556661115111166656666
333333333333333344444444aaaaaaaa4444444454444444444444454444444400099a00000aa000500100005556555555554444444455555551555555565555
444444444444444444445500bbbbbbbb000000004444444444444444000000001117511101111111550000004444444444444444444555555111111156666666
44444444554444444455000033b3bbb3000000004464444444444444000000000076650000000100500000004444444444444444444456555555515555555655
44444444055444444500000005343b34000000004666444444444444000000001176651111111011500000004444444444444444444455661111151166666566
44444444000554444500000000544344000000004466644747444444000000001176651111111011550000005555444444445555444555661111151166666566
44444444000005445000000000544444000000044444447777744444400000000076650040010000500000005555444444445555444455555551555555565555
44444444000000540000000005444444000000b444444747474747444b000000176666514b101111500000006665444444445666444456661115111166656666
4444444400000005000000000544444400000b34444474474744777743b000007666666544b01111550000006665544444455666444556661115111166656666
04444440000000000000000054444444000bb3444447444444744777443bb00076b66965444bb000500000005555444444445555444455555551555555565555
444444440bbbbbb0bbbbbbbbbbbbbbbb44444455444774444447444400bbbbbb01511511444444440000005556666666bbbb56666665bbbb5555555555555555
44544444b333bb3bbb33bbb33bbb3b334444445544744744447474440bbb33bb005005004444444000000005555556553b335655556533b35555565555555655
4555544434443b43b3443b3543b34350444444554744747444444444b3b3443b1151151144444011000000056666656643445566665544346666656566666566
44554444444443443444435544344500444444557447444744444464343444431151151144441011000000556666656644455566665554446666656566666566
44444454444444444444445544444500444444554447447474444664444444440051050044410000000000055556555544445555555544445556555555565555
44444554444444444444445544444450444444554474744444446664444444441150151144101111000000056665666644445666666544446665666566656666
44444454444444444444445544444450444444554444444444444444444444441150151141101111000000555555555544455666666554446665666566656666
44444444444444444444445544444445444444554444444444444444444444440051050040010000000000054445445444445555555544445556555555565555
00070000077000000077000000700070000007000000070000000000000000000000000000000000000000000000000000077000000000000000000000000000
07770000000770000000770007000770007777000007770007777770007777700777700007000700070007000707700007007700070700700700000007000770
07070000000070000000770007000770007000000077000000000770077000700700700077007770070007000700700007007700070777700700777007000700
00070000000070000077770007777700007777000070000000007700070007700700700070007070070007000700700007077700070000700700700007007000
00070000000070000000770000000700000007000077770000077000077777000777700070070070070007000707700007000770070000700700777007007770
00070000000770000000700000000770000007000070070000770000007007700000700070070070070007000707777007000770070000700700007007077070
07777700077777700077700000000070007777000007700000700000007007700000700070077700070007000700000007077700070000700700777007007770
00000000000000000000000000000000000000000000000000700000007777000000700000000000000000000000000000000000000000000000000000000000
00010000000aa0000000000000008080000000000000000000000000000444444444400000055000000000000000000000000000000000000000000044444444
00010000001991000444444000000b00000000000000000000000000004400000000440000555500100000010000000000000000000000000000000044444444
111010d101188110046538400000aaa0000000000000000000066000001100000000110005999950111111110005500000000000000000000000000004444444
00000d0001144110044444404000aaa0000000000000000006666600019910000001991005999950101001010555550000000000400000044000000400044444
0000010000144100046ced4040000a000000000000e0e00066666600019910000001991005999950101001015555550000000000900000099000000400000444
110d111100044000044444404004444400000000000a000066666660011110000001111000555500101001015555551000000000490000944900000400000044
00d000000004400004812940444004003003000300ebe00066666666000000000000000000055000111111115555511000000000409999044090000400000004
00100000000440000444444040404440030030300000b00006666666000000000000000000055000100000010555110000000000400000044009990400000000
000000006666666600000000000000000000000001100000000000005555500000044000000550000000000040000004dddddddd444444440000000000000000
066666666333733666666660000000000000000011011000000110000000550000044000100550011000000140000004dddddddd999999990000000000000000
663373366333373663373366000000000000000010111100001111000000110000044000111551111111111140000004dddddddd000000000000000000000000
067373766777777667373760000000000000000001111000011110000001991000111100101551011010010140000004dddddddd000000000000000440000000
063777366333373663777360000000000000000001111011011110000001991001999910101551011010010140000004dddddddd000000000000000990000000
663373366333733663373366000000000000000000110111001100000001111001999910101551011010010140000004dddddddd000000000000000440000000
066666666666666666666660000000000000000000000111000000000000000001999910115555113113111340000004dddddddd000000000000000440000000
000000000006600000000000000000000000000000001110000000000000000001111110155555511300303140000004dddddddd000000000000000440000000
00666600006666000466664004666640046666400466664066666666666600006000000066660000000000004444444444444444000000040000000000000000
06100060061111600466664004666640044444400466664077777770777000000000000077700000000000004444999999994444000000090000000000000000
61100006611111160466664004666640000000000466664000000000000000000000000000000000000000004444400000044444000000090000000000000000
61100006611111160466664004444440000000000444444000000000000000000000000000000000000000004444440000444444000000094000000400000000
61900006611111960466664000000000000000000000000000000000000000000000000000000000000000004444440000444444000000099000000900000000
61100006611111160466664000000000000000000000000000000000000000000000000000000000000000004444444004444444000000094900009400000000
61100006611111160466664000000000000000000000000007777777000007770000000000000777000000004444444004444444000000094900009400000000
61100006611111160444444000000000000000000000000066666666000066660000000600006666000000004444444444444444000000094900000488888888
00000000670670670000000000000000000000006706706700666666777770000088666677788000000000060000000030000000000000000444444088888888
000000006706706700000000000000000000000067067067000777776666660000088777666688000000000600300000333000000000000000d00d0055555655
600600606706706700000000000000008006008067067067000000000000000000000000000000000000000603300000333300000000000000d00d0066666555
670670676706706700800000000008008806708868067068006666667777700000666666777770000000000633300003333333300000000000d00d0066666555
670670676706706700050000000050006806706888067088000777776666660000077777666666000000000633300033333337770000000000d00d0055565555
67067067600600600000500000050000670670678006008000000000000000000000000000000000000000063330033b333377770000000000d00d0066656655
67067067000000000004400000044000670670670000000000666666777770000088666677788000000000060330333bb33377700000000000d00d0066656655
67067067000000000044440000444400670670670000000000077777666666000008877766668800000000060033333bbb3377770000000000d00d0055565555
99999999000000000000000000000000333333333333333300699600333337330000000066666666600000000033333bbb337777000000007777777756666655
99444499000000000000000000000000373337333333333306199960333373330000000000000000600000003333333bb3333773000000007777777755555655
94944949000000000000000000000000337373333777777361188116373777730000000000000000600000003333333b33333887000000007777777766666555
94499449000000000000000000000000333733333333333361198116733373370000000000000000600000003330033333333337000000007777766666666555
94499449000000000000000000000000337373333333333361198196733337370000000000000000600000003330000333333337000000007776660055565555
949449490111111008888880000000003733373337777773611cc116733333370000000000000000600000000330770077707707000000007666000066656655
994444995111111508888880000000003333333333333333611cc116373333370000000000000000600000000030707070707707000000006600000066656655
99999999055555505555555555555555333333333333333361111116337777736666666600000000600000000000770077707000000000000000000055565555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555655
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666566
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666566
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055565555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066656666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066656666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055565555
00000000000000000000000000000000000000000000000000000000000000000000000000777700000000000000000000000000007787000077770044454454
00800800008008000080800000808000008080000000000000000000000000000077770007778700000770000000700000000000078777000777770055555555
00700700007007000070700000707000007070000080800000000000000000000777870007877700007787000077870000008000077777000777870066656666
00b3330000b333000033300000333000003330000070700000000000000000000787770007777700078777000787770000800000077777000787770055565555
0b1331300b1331300333330303333303033333030033300000707000000000000777770007777700077777000070000000000000077777000777770066666566
bb333333bb3333333333333333333333333333330333330300333000000000000777770007070700077770000000000000000000070707000707070066666566
00300300003003000030030000300300003003003333333303333303003330000707070000000000000700000000000000000000000000000000000055555655
00300000000003000030000000000300003003000030030033333333033333030000000000000000000000000000000000000000000000000000000056666666
00099000000990000009900000099000000990000009900000099000000000000000000000000000000000000009900000000000000000000000000000099000
00099900000999000009990000099900000999000009990000099900009900000000000000000000000000000009900000000000000000000000000000099900
00488000004880000048800000488000004880000048800000488090009990000000000000000000000000000088880000000000000000000000000000488090
04498000044980000449800004498000044990000449800004489990008800000090000000000000000000000098890009099090000000000000000004489990
04498000049880000449800004489000044880000448900004488000009980000990000000000000000000000098890009099090000000000000000004488000
000cc000000cc010000cc000000cc000000cc000000cc000000cc00000088c01098890010900000100000000000cc000008888000099990000000000000cc000
000cc00000c00c10000c0c00000cc00001c00c00000c0c0000c0c0000000ccc100898cc199898cc100000000000cc000000880000909909000000000000cc000
000111000011000000010110000111000100001100010110011011000000000000000cc199898cc1000000000001100000088000008888000099990000011100
00099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099900000000000440004004400040044000040440004004400040044000400440000404400040044000400440004004400004044000400000000000000000
000cc000000000000040000400400040004000400040004000400004004000400040004000400040004000040040004000400040004000400000000000000000
0009c000000000000440000404400040044000400440004004400004044000400440004004400040044000040440004004400040044000400600000060000000
0009c00000000000444c4440444c4440444c4440444c4440444b4440444b4440444b4440444b4440444e4440444e4440444e4440444e44406000000060000000
00033000000000000004444000044440000444400004444000044440000444400004444000044440000444400004444000044440000444400600055006000550
00033000000000000004004000440044000400400044004400040040004400440004004000440044000400400044004400040040004400440055550000555500
00011100000000000044044000000000004404400000000000440440000000000044044000000000004404400000000000440440000000000500005000500500
00099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000440040004404000044004000440
000bb000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000040000400040004000400040004000400
0009b000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000040000440040004400400044004000440
0009b000000000000770000007000000000000000000000000000000000000000000000000000000000000000000000004448444044484440444844404448444
00022000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000004444000044440000444400004444000
00022000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000004004000440044000400400044004400
00011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004404400000000000440440000000000
00099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000990000009900440000004400000
00099900000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000448999004489990040000000400000
000ee000000000000700000007000000000000000000000000000000000000000000000000000000000000000000000004489800044898000440000004400000
0009e000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000004488900044889904448000444480040
0009e000000000000777000007700000000000000000000000000000000000000000000000000000000000000000000000088090000880008004404080044004
000660000000000070000000700000000000000000000000000000000000000000000000000000000000000000000000000cc000000cc0000004404000044040
000660000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000000cc000000cc0000004440000044400
00011100000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000011100000111000044440000444400
__gff__
0001010101010101010101000101010100010101010101010000000101010101010100010000000001000001010100010101010101000001010000010101010100000000000000000000000000000000000000000000000000000000000000000000000101000000000000000101000080000101000303010000000101000002
0202101002020202020200010100000105000000000000000000000101000001000000000000000000000000000000010202020202020202020202020202020101010101010101000000010101010101010000000000000000000000000000000100000000000000000000000000000001000000000000000000000001010000
__map__
00000000000000000000000000000000050700000000000000001200000000123000000000000000002112121212121212121212121212121212121212121212121212121212121d2f002f1c12121212121212121212121212121212121212121212121212121212121212121212121212000000000000000000000000000012
00000000000000000000000000000000160000000000000000001500002437121256000000000098989800211212121212220000211222000000212200005512121212121212121d2f002f1c12121212121222000000212200000000002112121212121212121212121212121212121212000000000000000000000000000012
00000000000000000000000000000000060000000000000056243000000460121207000066658a9495979a002112121212710000572000000000000000040512121212121212121d2f002f1c12121212121600006500000000000000000015121212121212121212121212121212121212000000000000000000000000000012
00000000000000000000000000000000160000000000006205051600000000061200000000000099999900000022211212051754000000000000000000000012121212121212121d2f002f1c12121212122200000000000000000000000021121222000000002122000000000000211212000000000000000000000000000012
00000000000000000000000000000024160000000000000000002000000070121271000000000065006600000000001212050505051217000000000000000012121212121212121d2f002f1c12121212120000000000000000000000000086121207000000000000000000000000001212000000000000000000000000000012
00000000000000000000000000000405300000000000000000000055000405121205050700000000000000000000001212220000211205050505050507000012121212121212121d2f002f1c121212121200000000000000000000000000861212580000000000000000000000005712727000006e5d5d5e5d5d5d6f00000072
0000000000000000000000005556240612000000000000002437050527541506050507000000000000000000000000121200000000120612121222000000001212220021220000000000000000002112127100005400550000540000706b8812120000000000000000000000000000120f0f1b0f0f6d6d6d6d6d6d1b0000000c
0000000000000000000000000405050512000000542305050505050505050505121600000000000000000000000000121200000057120b0b0b3000000000001212600000000000000000000000005b1212050505050505050505053c0f0f0f122c1f000000001f000000000000001f2b12121203220000000000000000002312
0000000000000000000000000021061212000000232200000660000000000015060505050517000000000405170000121200000000200b0b0b2000000417541212000000000000000000000000000412121212121212121212121212121212121d1b5050500c2f0f0f0f0f0f0f0f2f1c2d3e2200000000000000000024051212
00000000000000000000000000001512160000042200000020000000000000121222002120220000000000000000011212000000000b0b530b0b00000021051212000017000000000000000000005712122200211212160021121212160021121d0b0b0b0a2f2f2f2f2f2f2f2f2f2f1c1d710000000000000000371212121212
0000590000000000000059000000020306070000000000000000000000000006167000000000000000000000000134121200000037121405051214270000241212700015170000000000000000000006127100000000000000212200000000121d0b0b0a2f2f2f2f2f2f2f2f0b0b0b1c1d0d0000000000000405390b080b0b12
5a5a695a6a5a5a5a6a5a695a5a5a5a6a1200040507000004050505070000001512050505121405050505015401343412120000001d0b0b080b0b1c050505050512050512120700000000000000005515120700000000000000000000000050121d710b0b0b2f2f2f2f2f2f2f0b0b0b1c1d7100000000000000001a0b0b0b0b12
111111111111111111111111111111111200000000000000000000000024051212121212120612121212340134343412120000001d0b0b0b0b0b1c220000001512220000000000000000373370002312125800000000006600000000000070121d0d710b0b0b0b0b0b0b0b0b0b70701c1d0e3d050507000000001a0b0b0b0b12
101010101010101010101010101010100507000000000000540000000023252612301212121212061212121212121212120000001d0b0b0b0b0b1c000000700612710071005431540024121205051212160000000000000000000000000e0f121d2f0e0f0f0f0f0f0f0f0f0f0f0f0f1c12120322000000000405290b28707012
101010101010101010101010101010101671005561000023053300240512353612121212121212121212121212121212125500000b0b0b280b0b0b007037050512050505050505050505121212121212121700000000000000000000002f2f121d2f2f2f2f2f2f2f2f2f2f2f2f2f2f1c12160000000000000015050505050512
1212121212121212121212121212121212050505050505123012050505050512121212121212121212121212121212121205053c0f0f0f0f0f0f0f3d0505050512121212121212121212121212121212121205050505050505050505051212121212121212121212121212121212121212128080808080808012121212121212
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2b1212120b12122c2f2f2f2f2f2f2f2f121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
2f0b0b0b0b0b0b0b0b0b0b0b0b0b0b2f2f0b0b0b0b0b2f0b0b2f0b0b0b0b0b2f2f000000000000883e0000000000862f2f81859f0b0b0b0b2f2f2f2f8185812f1c0612220021121d2f0b0b0b0b0b0b2f122200000000000000007012121212121222000000000000000000000000211200000000000000000000000000000000
2f71710b0b0b0b0b0b0b0b0b0b0b532f2f0f0f0f0f0f2f0f0f2f0f0f0f0f0f2f2f670000000000000000000f0070882f2f710b0b0b0b0b0b2f00000b0b710b2f1c1222000000211d2f0b0b2f2f0b0b2f125b00000000000000040512121212122c1f1f1f1f1f1f1f1f1f1f1f1f1f1f2b00000000000000000000000000000000
2f0f0f0f0f0b0f0f0f0f0f8f0b0b2f2f2f00000000000000000000000000002f2f7100000000000000000f00000f0f2f2f0f0f8f0b0b0b0b2f000f0f0f0f0f2f1c2200000000001d2f0b2f2f2f2f0b2f12070000000100010000000000005f121d3f3f3f3f3f3f3f3f3f3f3f3f3f3f1c00000000000000000000000000000000
2f0b0b0b0b0b9f0b0b0b0b0b0b0b2f2f6000000000000000000000000000002f2f0f0f0f0f0f0f0f0f0f0f0f0f2f2f2f2f2f2f9f520b1f0b2f000000002f812f1c0000000000001d2f2f2f2f2f2f2f2f120000010000000000000000000000121d2f000000000000000000000000001c00000000000000000000000000000000
2f0b0b0b8f0b0b0b0b0b0b0b0b0b2f2f1a00000000000000000000000000002f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f0b2f000f0f0081002f1c5800000000041d2f0000000000002f1200000001000000005e005e000000121d3e000000000000000000000000001c00000000000000000000000000000000
2f0b0b0b9f0b0e0f0f0f0f0f0f0f2f2f1a8f006b00006b00008f006b0000002f2f2f670081000000000000850000002f2f2f2f080b0b2f0b2f0f2f2f0000002f1c7100000000701d2f7100000000702f120000000005050505017d01000000121d71000000000000000000000000001c00000000000000000000000000000000
2f0b0b0b0b0b0b0b0b0b0b0b0b0b0b2f1a9f0000000000000000000000006b2f2f81000000000000000000000000002f2f00000b0b0b2f0b2f87002f0f000f2f1c05051d0b1c141d2f0f0f0f0f0f0f2f120000000000000000000000000100121d0a0000000000000000000000000f1c00000000000000000000000000000000
2f0e0f0f0f0b0e0f1b0b0b0b0b0b0b2f709f0000000000000000006b0000002f2f71000000000000000f00000070002f2f00000b0b0b0b0b2f8700000000002f2f09092f0b2f092f2f3b3b3b3b3b3b2f120000000000000000000000000070121d710000000000000000000f0000001c00000000000000000000000000000000
2f0b700b0b0f2f2f0b0b0b0f52520b2f9f000000000000000000007070006b2f2f0f0f0f0f0f800f0f2f840f0f0f0f2f2f0000280b530f0f2f0f8f000f0f0f2f2f00000000002f2f1c2200212200211d1271710000005d5e5d5d0054540005121d0a000000000070000000000000001c00000000000000000000000000000000
2f0b0f0b0b0b702f0b0f0f2f0f0f0f2f9f000000000000006b000f0f0f0f0f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000f0f0f000000009f000000862f2f71000000002f2f1c0000000000001d1205050700047b6d6d7c0505050512121d710000000000700000000f0f00001c00000000000000000000000000000000
2f0f2f0b0b0b2f0b0b0b0b2f8185852f9f00000000006b0000001a0b0b0b712f2f00000000000000818100000000002f2f00000000000000000000000000862f2f1b0000000c2f2f1c0000000000001d12220000000000000000000000005f121d0a000000000070000000000000001c00000000000000000000000000000000
2f2f2f0b0b0b700b0b0b0b0b6b00002f9f7100006b00000000000f0f0f0f0f2f2f67000000000000000000000000003a2f0000001f00000000000f0f000f0f2f2f00000000000b380b00316b0000001d120000000000000000000000000000121d710000000000700000000f0f0f0f1c05050505050505050505050505050505
2f2f2f0f0f0f0f0f1b0b0c0f0f0f0f2f2f0f8f000000000000002f2f2f2f2f2f2f71000000000000000000000070003a2f00000f2f0f0f0f0f0f2f2f002f2f2f2f700d0000000c2f1c00150000006b1d1271710055005e00005e0000007070121d0a00000000006b000000000000001c12121212121212121212121212121212
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f8f5253000000001a0b0b0b712f2f0f0f800f0f800f0f0f80800f0f0f2f2f000f2f2f520b71700b522f7070702f2f0f2f0000002f2f1c70166b0000711d120505050505057f7f050505050505121d2f0f0f0f0f840f0f0f0f0f0f0f0f1c12121212121212121212121212121212
3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b2f2f2f2f0f0f0f0f0f0f0f0f0f0f0f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f0f2f2f2f0f0f0f0f0f0f2f0f0f0f2f2f2f2f0f0f0f2f2f2f0909090909092f121212121212126c6c121212121212121d2f2f2f2f2f2f2f2f2f2f2f2f2f2f1c12121212121212121212121212121212
__sfx__
010400001e7501c60005500005001d6003200035000360003700038000390003b0003c0003c0003d0003d0003e0003e0003e0003e0003d0003d0003c0003b0003a000390003800035000320002f0001c50026000
000900000525001230062000420005250012300070000200176501763000200007000660000600002001860018600006001a600146000e6000760003600016002210022100221002210023100231002410001000
010400000000022250222502225022250212501f2501d250172500f25000250000000000002200000001165012650116500d65007650146001f60015600146001460000000000000000000000000000000000000
010d00002851024511285110250100500045000050002500045000360001600066000250004500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001c1031c1001c10300000000000000000000000001c1531c1001c1530c000000000000000000000001c1531c1001c153104001c4001c40028400284001c1001c1001c1002850028500285002850028500
010500001c1511c1401c13028020280101c1511c1401c130280202801004150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000505005000050500200005050000000505002050050500500005050000000505004000050500205005050050000505007000050500700005050020500405004050050500705009050000000000000000
011000000005000000050500000010050090500505000000000500000000000100501805000000070500000000050000000505000000100500905005050000000005000000000001005018050000000705000000
01100000045000000000000000000c653045000450004500056000560000000056000c653056000560005600056000560005600000000c653056000450004500045000450000000045000c653000000000000000
011000000005000000050500000010050090500505000000000500000000000100521006210052070500000000050000000505000000100500905005050000000005000000000001005410064100540705000000
011000000005000000050500000010050090500505000000000500000000000100501805000000070500000000050000000505000000100500905005050000000005000000000001005210062100520705000000
011000000005000000050500000010050090500505000000000500000000000100511805500000070500000000050000000505000000100500905005050000000005000000000001005410064100540705000000
011000000005000000050500000010055090650507500000000500000000000100551805500000070500000000050000000505000000100550905505055000000005000000000001005210062100520705100000
011000000005000000050500000010055090650507500000000500000000000100511805500000070500000000050000000505000000100550905505055000000005000000000001005410064100540705100000
011000000052000540005300052010550105401053010520005500054000530105501054010530075500753000550005400053000520105501054010530105200055000540005301055210542105320755007530
011000000052000540005300052010550105401053010520005500054000530105501054010530075500753000550005400053000520105501054010530105200055000540005301055410544105340755107531
011000000012500125001150011510125101251011510115001250012500115101251012510115071150711500125001250011500115101251012510115101150012500115001151012510125101150711507115
01100000045000000000000000000c0530c0430450004500056000560000000056000c0530c0430560005600056000560005600000000c0530c0430450004500045000450000000045000c0530c0430000000000
01100000277150000000000000003f700000000000000000277153f70000000000003f700000000000000000277153f70000000000003f700000000000000000277153f700000000000000000000000000000000
011000000c0530000000000000000c0530c04304500045000c0530560000000056000c0530c04305600056000c0530560005600000000c0530c04304500045000c0530450000000045000c0530c0430000000000
01100000001000110002100031000410005100061000710008100091000a1000b1000c1000d1000e1000f10010100111001210013100141001510016100171001710017100151001110010100131000e10000000
01100000001000310005100071000a1000b1000c1000d1000e1000f100101001110012100131001410015100171001710017100151001110010100131000e1000000000000000000000000000000000000000000
01100000001000310005100071000a1000b1000c1000d1000e1000f100101001110012100131001410015100171001710017100151001110010100131000e1000000000000000000000000000000000000000000
011000000010000100001000310003100031001f1001f1001f1001f1001f1001f1001f1001f1001f1001f10024100241002410027100271002710037100371003710037100371003710037100371003710037100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000001500115002150031500415005150061500715008150091500a1500b1500c1500d1500e1500f15010150111501215013150141501515016150171501710017100151001110010100131000e10000000
01100000001500315005150071500a1500b1000c1000d1000e1000f100101001110012100131001410015100171001710017100151001110010100131000e1000000000000000000000000000000000000000000
011000000015000140001300315003140031301f1511f1421f1321f1221f1121f1121f1101f1101f1101f11024150241402413027150271402713037151371423713237122371123711237110371103711037110
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
01 0a 42 43 44
00 0b 42 43 44
00 0c 42 43 44
02 0d 42 43 44
01 0a 11 43 44
00 0b 11 43 44
00 0c 11 43 44
02 0d 11 43 44
01 0a 11 10 44
00 0b 11 10 44
00 0c 11 10 44
02 0d 11 10 44
01 0a 13 10 44
00 0b 13 10 44
00 0c 13 10 44
02 0d 13 10 44
04 0e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
