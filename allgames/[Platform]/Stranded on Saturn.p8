pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- stranded on saturn
-- by janpaul bergeson

lvl_idx = 1

pogo_speed = -9
little_pogo_speed = -4
jump_speed = -5.5
std_friction = .2
gravity = .6
max_dx = 2.5
max_dy = -jump_speed

plr_sfx_start = -1
plr_sfx_frms = 4

monster_walk_spd = 1

game_over = false
game_over_frame_num = 0
game_over_ship_flying = false
game_over_ship_thrusters = nil
game_over_show_ui = false
ship_coords = {
  x=59*8,
  y=8*8
}
show_credits = nil

-- how many frames to display
-- each frame in the walk cycle
-- animation
anim_frames = 3

air_frm = -1
coyote_time = 2

jump_btn = 4
-- shoot_btn = 5
pogo_btn = 5

locked = false

background_colors_list = {
  {6, 10, 9},
  {10, 9, 8, 2},
  {8, 2, 1, 0},
  {8, 2, 14, 15},
}

ship_tiles = {
  12, 13, 28, 29, 44, 45, 46, 47, 60, 61, 62, 63
}

-- so we don't get button repeats
debncd_btns = {
 {}, {}, {},
 {
  pressed = false,
  rep_spd = 1000,
  last_press = 0,
 },
 {
  pressed = false,
  rep_spd = 1000,
  last_press = 0,
 }
}

coroutines = {}

-- in tiles, not pixels
level_width = 64
level_height = 32
function getLevelOffset()
  return {
    x = flr((lvl_idx - 1) % 2) * level_width,
    y = flr((lvl_idx - 1) / 2) * level_height,
  }
end
level_start_points = {}
monster_start_points = {}

stars = {}
star_count = 48
for i=1,star_count do
  local maxX = level_width * 3
  local maxY = level_height * 4
  add(stars,{
    x=flr(rnd(maxX)),
    y=flr(rnd(maxY)),
    sz=flr(rnd(3) / 2)
  })
end

crumbling_platform_tiles = {101, 102, 103}
crumbling_platforms = {}
crumbled_platforms = {}

function crumbling_platform_dust(x, y, count, color)
  local xWorld = (x - currMapOffset.x) * 8 + 4
  local yWorld = (y - currMapOffset.y) * 8 + 4

  for i=1,count do
    add_new_dust(
      xWorld+rnd(8)-4, --x
      yWorld+rnd(8)-4, --y
      .5*(rnd(2)-1), --dx
      -rnd(1)/3, --dy
      rnd(10)+5, -- lifetime
      rnd(2), --size
      0, --gravity
      color) -- color
  end
end

function actor_on_tile(x, y)
  local xWorld = (x - currMapOffset.x) * 8
  local yWorld = (y - currMapOffset.y) * 8
  if actor_in_bounds(player, xWorld, xWorld + 8, yWorld, yWorld + 8) then return true end
  for m in all(monsters) do
    if actor_in_bounds(m, xWorld, xWorld + 8, yWorld, yWorld + 8) then return true end
  end
  return false
end

function actor_in_bounds(actor, minX, maxX, minY, maxY)
  return point_in_bounds(actor.x, actor.y, minX, maxX, minY, maxY)
      or point_in_bounds(actor.x+actor.w, actor.y, minX, maxX, minY, maxY)
      or point_in_bounds(actor.x-actor.w, actor.y, minX, maxX, minY, maxY)
      or point_in_bounds(actor.x, actor.y+actor.h, minX, maxX, minY, maxY)
      or point_in_bounds(actor.x, actor.y-actor.h, minX, maxX, minY, maxY)
end

function point_in_bounds(x, y, minX, maxX, minY, maxY)
  return x >= minX and x <= maxX and y >= minY and y <= maxY
end

fading = nil
-- fadetable from http://kometbomb.net/pico8/fadegen.html
local fadetable={
 {0,0,0,0,0,0,0},
 {1,1,1,0,0,0,0},
 {2,2,2,1,0,0,0},
 {3,3,3,1,0,0,0},
 {4,2,2,2,1,0,0},
 {5,5,1,1,1,0,0},
 {6,13,13,5,5,1,0},
 {6,6,13,13,5,1,0},
 {8,8,2,2,2,0,0},
 {9,4,4,4,5,0,0},
 {10,9,4,4,5,5,0},
 {11,3,3,3,3,0,0},
 {12,12,3,1,1,1,0},
 {13,5,5,1,1,1,0},
 {14,13,4,2,2,1,0},
 {15,13,13,5,5,1,0}
}
function fade(i)
 for c=0,15 do
  if flr(i+1)>=8 then
   pal(c,0)
  else
   pal(c,fadetable[c+1][flr(i+1)])
  end
 end
end

dust = {}

-- particle system from https://www.lexaloffle.com/bbs/?pid=58222
-- credit: DocRobs
-- args: x, y, dx, dy, lifetime, size, gravity, color (color can be a table)
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
add(dust, {
fade=_f,x=_x,y=_y,dx=_dx,dy=_dy,life=_l,orig_life=_l,rad=_s,col=0,grav=_g,draw=function(self)
pal()palt()circfill(self.x,self.y,self.rad,self.col)
end,update=function(self)
self.x+=self.dx self.y+=self.dy
self.dy+=self.grav self.rad*=0.9 self.life-=1
if type(self.fade)=="table"then self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]else self.col=self.fade end
if self.life<0 then del(dust,self)end end})
end

-- for notes on Lua inheritance, see:
-- https://www.lua.org/pil/16.html
-- https://www.lua.org/pil/16.1.html
-- https://www.lua.org/pil/16.2.html

Actor = {
  new = function(self, obj, x, y)
    obj = obj or {
      is_player = false,

      x = x,
      y = y,
      dx = 0,
      dy = 0,
      xRemainder = 0,
      yRemainder = 0,
      friction_x = std_friction,
      gravity = true,
      -- time since grounded
      grounded_time = 100,

      -- half the width/height (radius) in pixels
      w = 2,
      h = 3,

      animated = true,
      -- whether this character has
      -- an air frame
      air_frame = true,
      -- offset for first frame
      k = 1,
      -- offset for current frame (from k)
      frame = 0,

      facing_l = false,
      
      sfx_num = 0,
    }
    -- "self" here refers to the Actor prototype object
    self.__index = self
    setmetatable(obj, self)
    return obj
  end,

  grounded = function(self)
      -- 0: regular ground
    return solid(self.x + self.w, self.y + self.h + 1, 0)
        or solid(self.x - self.w, self.y + self.h + 1, 0)
        -- 4: crumbly platforms
        or solid(self.x + self.w, self.y + self.h + 1, 4)
        or solid(self.x - self.w, self.y + self.h + 1, 4)
        -- 3: jump-through platforms
        or (solid(self.x + self.w, self.y + self.h + 1, 3) and not solid(self.x + self.w, self.y + self.h, 3))
        or (solid(self.x - self.w, self.y + self.h + 1, 3) and not solid(self.x - self.w, self.y + self.h, 3))
  end,

  draw = function(self)
    local sx = self.x - 4
    local sy = self.y - 4

    -- 3-frame walking animations where
    -- 1st frame is used for 1st and
    -- 3rd frames of walking cycle
    local frame = 0
    local grounded = self:grounded()
    if game_over and self.is_player and grounded then
      frame = 20
    elseif self.is_player and self.dead then
      if grounded then
        frame = 4
      else
        frame = 5
      end
    elseif self.is_monster
        and self.life <= 0
        and grounded then
      frame = 4 -- dead
    elseif self.air_frame
        and self.frame == air_frm then
      frame = 3 -- airborne
    elseif self.frame >= anim_frames
        and self.frame < (anim_frames * 2) then
      frame = 1
    elseif self.frame >= (anim_frames * 3) then
      frame = 2
    end

    spr(self.k + frame, sx, sy, 1, 1, self.facing_l)

    -- pogo overlay if pogoing
    if self.pogoing then
      local xOffset = self.facing_l and -2 or 2
      spr(20, sx + xOffset, sy + 2)
    end
  end, -- end function draw

  update = function(self)
    if self.gravity then
      self.dy += gravity
    end

    -- friction
    if self.friction_x then
      if self.dx > 0 then
        self.dx -= self.friction_x
      elseif self.dx < 0 then
        self.dx += self.friction_x
      end
    end
    if abs(self.dx) < self.friction_x then self.dx = 0 end

    -- clamp dx/dy
    if self.dy > max_dy then self.dy = max_dy end
    if not self.pogoing and self.dy < -max_dy then self.dy = -max_dy end
    if self.dx > max_dx then self.dx = max_dx end
    if self.dx < -max_dx then self.dx = -max_dx end

    -- actually update physics
    self:moveX(self.dx)
    self:moveY(self.dy)

    -- update frame
    if self.animated and abs(self.dx) > .5 then
      self.frame += 1
      if self.frame > (anim_frames * 4) then self.frame = 0 end
    else
      self.frame = 0
    end
    -- airborne frame
    if self.air_frame then
      if not self:grounded() then
        self.frame = air_frm
      elseif self.frame == -1 then
        self.frame = 0
      end
    end
  end, -- end function update

  moveX = function(self, amount)
    self.xRemainder += amount
    move = flr(self.xRemainder * 1) / 1

    if move ~= 0 then
      self.xRemainder -= move
      local increment = move > 0 and 1 or -1

      while move ~= 0 do
        if not self:collideAt(self.x + increment, self.y, 0, 0) then
          self.x += increment
          move -= increment
        else
          -- hit a solid!
          self.dx = 0
          break
        end
      end -- end while
    end -- end if move ~= 0
  end, -- end function moveX

  moveY = function(self, amount)
    self.yRemainder += amount
    move = flr(self.yRemainder * 1) / 1

    if move ~= 0 then
      self.yRemainder -= move
      local increment = move > 0 and 1 or -1

      while move ~= 0 do
        if not self:collideAt(self.x, self.y + increment, 0, increment) then
          self.y += increment
          move -= increment
        else
          -- hit a solid!
          self.dy = 0
          break
        end
      end -- end while
    end -- end if move ~= 0
  end, -- end function moveY

  collideAt = function(self, x, y, dx, dy)
    return solid_area(x, y, self.w, self.h, 0) -- 0: regular ground
      or solid_area(x, y, self.w, self.h, 4) -- 4: crumbly platforms
      -- jump-through platforms, only collide on top
      or (dy > 0 and ((solid(self.x + self.w, self.y + self.h + 1, 3) and not solid(self.x + self.w, self.y + self.h, 3))
                  or  (solid(self.x - self.w, self.y + self.h + 1, 3) and not solid(self.x - self.w, self.y + self.h, 3))))
  end
}

lollipops = 0
bears = 0
item_disp_time = 0

time_frames = 0
time_sec = 0
time_minutes = 0
time_display_time = 0
time_paused = false

Player = Actor:new({
  new = function(self, obj, x, y)
    ret = Actor.new(self, obj, x, y)
    ret.is_player = true
    ret.pogoing = false
    ret.sfx_num = 0
    return ret
  end,

  add_feet_dust = function(self, count)
    for i=1,count do
      -- args: x, y, dx, dy, lifetime, size, gravity, color (color can be a table)
      add_new_dust(
        self.x, --x
        self.y+self.h, --y
        .3*(rnd(2)-1) + .15*self.dx, --dx
        -rnd(1)/3, --dy
        rnd(10)+5, -- lifetime
        rnd(2), --size
        0, --gravity
        5) -- color
    end
  end,

  update = function(self)
    self:control()

    if self:grounded() and abs(self.dx) > 0 then
      self.sfx_num += 1
      self.sfx_num %= plr_sfx_frms * 2
      if self.sfx_num == 0 then sfx(1) end
      if self.sfx_num == plr_sfx_frms then sfx(2) end
    else
      self.sfx_num = plr_sfx_start
    end

    local was_grounded = self:grounded()
    Actor.update(self)
    local is_grounded = self:grounded()

    if is_grounded and not was_grounded then
      self:add_feet_dust(10)
    elseif is_grounded and abs(self.dx) > 0 and flr(rnd(3)) == 0 then
      self:add_feet_dust(1)
    end

    self:check_items()
    self:check_dead()
    self:check_crumbling_platforms()

    if item_disp_time > 0 then item_disp_time -= 1 end
    if time_display_time > 0 then time_display_time -= 1 end

    -- increment timer
    if not time_paused then
      time_frames += 1
      if time_frames > 30 then time_sec+=1 time_frames-=30 end
      if time_sec > 60 then time_minutes+=1 time_sec-=60 end
    end
  end,

  control = function(self)
    if locked then return end

    -- increase friction if necessary
    self.friction_x = std_friction
    if self:grounded() then
      self.grounded_time = 0
      if not btn(0) and not btn(1) then self.friction_x = 5 * std_friction end
    elseif self.grounded_time < 100 then
      self.grounded_time += 1
    end

    -- walk
    -- todo better accel curve
    accel = 0.6
    if btn(0) then
      self.dx -= accel
      self.facing_l = true
    elseif btn(1) then
      self.dx += accel
      self.facing_l = false
    end

    if debncd_btns[pogo_btn].pressed then
      self.pogoing = not self.pogoing
      if self:grounded() then
        self:moveY(-5)
      end
    end

    if self.pogoing then
      if self:grounded() then
        local pogospd = little_pogo_speed
        if btn(jump_btn) then
          pogospd = pogo_speed
          sfx(11)
        else sfx(10) end
        self.dy = pogospd
      end
    else
      local dbncd_jmp_btn = debncd_btns[jump_btn]
      if self.grounded_time <= coyote_time
          and (dbncd_jmp_btn.pressed
          or (dbncd_jmp_btn.last_press < 5
              and dbncd_jmp_btn.last_press ~= 0)) then
        self.grounded_time = coyote_time + 1
        self.dy = jump_speed
        sfx(9)
        self:add_feet_dust(10)
      end
    end

    if self:collide_ship() then
      game_over = true
      time_paused=true locked=true self.pogoing=false self.dx=0 self.dy=0 self.friction_x=0
      add(coroutines, cocreate(game_over_coroutine))
    elseif self:collide_exit() then
      locked=true self.pogoing=false self.dx=0 self.dy=0 self.friction_x=0
      add(coroutines, cocreate(exit_level_coroutine))
    end
  end,

  check_dead = function(self)
    if not self.dead and (
      -- dead by falling off the bottom of the screen
      self.y > (level_height * 8 + 4)
      -- dead by touching spikes (the -4 gives it a smaller hitbox, must be touching bottom half of spikes)
      or (solid(self.x + self.w, self.y + self.h, 1) and solid(self.x + self.w, self.y + self.h - 4, 1))
      or (solid(self.x - self.w, self.y + self.h, 1) and solid(self.x - self.w, self.y + self.h - 4, 1))
      -- dead by touching floating spikes
      or solid_area(self.x, self.y, self.w, self.h, 2)
      -- dead by touching an enemy
      or self:collide_with_enemy()
    ) then plr_dead() end
  end,

  collide_with_enemy = function(self)
    for m in all(monsters) do
      local dx = player.x - m.x
      local dy = player.y - m.y

      if abs(dx) < (player.w + m.w) and abs(dy) < (player.h + m.h) then
        return true
      end
    end
    return false
  end,

  check_items = function(self)
    if self.dead then return end

    self:check_item_pickup(self.x + self.w, self.y + self.h)
    self:check_item_pickup(self.x - self.w, self.y + self.h)
    self:check_item_pickup(self.x + self.w, self.y - self.h)
    self:check_item_pickup(self.x - self.w, self.y - self.h)
  end,

  check_item_pickup = function(self, x, y)
    local xCoord = currMapOffset.x + flr(x / 8)
    local yCoord = currMapOffset.y + flr(y / 8)
    val = mget(xCoord, yCoord)
    if fget(val, 6) then
      -- if we decide to have the soda cans replaced by an empty soda can you can still jump on
      -- local replace = val == 50 and 51 or 0

      -- got an item!
      if val == 48 or val == 50 then
        lollipops+=1
        sfx(12)
      else
        bears+=1
        sfx(13)
      end

      item_disp_time = 30

      -- clear the item tile
      mset(xCoord, yCoord, 0)
    elseif val == 16 then
      -- checkpoint!
      level_start_points[lvl_idx] = {
        x = x,
        y = y
      }
    end
  end,

  check_crumbling_platforms = function(self)
    self:check_crumbling_platform(self.x + self.w, self.y + self.h + 1)
    self:check_crumbling_platform(self.x - self.w, self.y + self.h + 1)
    self:check_crumbling_platform(self.x + self.w, self.y - self.h - 1)
    self:check_crumbling_platform(self.x - self.w, self.y - self.h - 1)
  end,

  check_crumbling_platform = function(self, x, y)
    if solid(x, y, 4) then
      local xCoord = currMapOffset.x + flr(x / 8)
      local yCoord = currMapOffset.y + flr(y / 8)

      local already_crumbling = false
      for cp in all(crumbling_platforms) do
        if cp.x == xCoord and cp.y == yCoord then
          already_crumbling = true
          break
        end
      end
      if not already_crumbling then
        add(crumbling_platforms, {
          x = xCoord,
          y = yCoord
        })
      end
    end
  end,

  collide_exit = function(self)
    return solid_area(self.x, self.y, self.w, self.h, 7)
  end,

  collide_ship = function(self)
    return self:collide_ship_tile(self.x-self.w,self.y-self.h) or
      self:collide_ship_tile(self.x+self.w,self.y-self.h) or
      self:collide_ship_tile(self.x-self.w,self.y+self.h) or
      self:collide_ship_tile(self.x+self.w,self.y+self.h)
  end,

  collide_ship_tile = function(self, x, y)
    val = mget(currMapOffset.x + flr(x / 8), currMapOffset.y + flr(y / 8))
    return solid(x, y, 7) and contains(ship_tiles, val)
  end
})

Enemy = Actor:new({
  new = function(self, obj, x, y, k, ai)
    ret = Actor.new(self, obj, x, y)
    ret.k = k
    ret.ai = ai
    ret.w = 3
    ret.h = 3
    ret.is_monster = true
    ret.life = 3
    ret.walking = monster_walk_spd
    ret.dont_walk_frames = 0
    return ret
  end,

  update = function(self)
    self:control()

    Actor.update(self)
  end,

  control = function(self)
    if not self.life or self.life <= 0 then return end

    -- grab camera position so we
    -- know to play enemy sfx only
    -- when they're on screen
    if not camX then camX = 0 end
    if not camY then camY = 0 end
    local camMinX = camX
    local camMaxX = camX + 128
    local camMinY = camY
    local camMaxY = camY + 128

    -- ai type 0: just walk left and right
    if self.ai == 0 then
      if self.dx == 0 and (solid(self.x + (2 * self.w), self.y, 0) or solid(self.x + (2 * self.w), self.y, 4)) then
        if self.x > camMinX and self.x < camMaxX and self.y > camMinY and self.y < camMaxY then sfx(4) end
        self.walking = -monster_walk_spd
        self.facing_l = true
      elseif self.dx == 0 and (solid(self.x - (2 * self.w), self.y, 0) or solid(self.x - (2 * self.w), self.y, 4)) then
        if self.x > camMinX and self.x < camMaxX and self.y > camMinY and self.y < camMaxY then sfx(4) end
        self.walking = monster_walk_spd
        self.facing_l = false
      end

      if self.dont_walk_frames > 0 then
        self.dont_walk_frames -= 1
      elseif self:grounded() then
        self.dx = self.walking
      end
    end
  end
})

function plr_exit_collision()
 local info = {
  l = 0,
  m = 0,
  r = 0
 }

 if solid(player.x - player.w, player.y, 7) then info.l = 1 end
 if solid(player.x, 0, 7) then info.m = 1 end
 if solid(player.x + player.w, player.y, 7) then info.r = 1 end

 return info
end

function exit_level_coroutine()
  time_paused = true
  time_display_time = 30

  col = plr_exit_collision()
  local plr_exit_walk = 1

  -- walk to the left side of the 
  if col.l == 1 then
    while col.l == 1 do
      player.facing_l = true
      player.dx = -plr_exit_walk
      yield()
      col = plr_exit_collision()
    end
  end

  exiting_r = {
    x = exit_loc.x * 8 - 8,
    y = exit_loc.y * 8,
  }

  sfx(0)

  while col.r == 1 do
    player.facing_l = false
    player.dx = plr_exit_walk
    yield()
    col = plr_exit_collision()
  end

  player.dx = 0

  for i=1,12 do
    fading = i
    for j=1,4 do yield() end
  end
  fading = nil

  lvl_idx += 1

  next_level()
end

function game_over_coroutine()
  while not player:grounded() do yield() end
  player.frame = 20
  for i = 1, 49 do
    game_over_frame_num += 1
    yield()
  end
  game_over_frame_num = 0

  -- clear ship from map -- horrible that these coords are hard-coded but w/e
  for x=123,126 do
    for y=39,41 do
      mset(x,y,0)
    end
  end

  game_over_ship_flying = true
  for i=1,20 do yield() end
  game_over_ship_thrusters = 0
  for i=1,20 do yield() end

  for i=1,80 do
    ship_coords.x -= 1
    ship_coords.y -= 1
    yield()
  end

  for i=1,12 do
    fading = i
    for j=1,4 do yield() end
  end

  for i=1,20 do yield() end

  game_over_show_ui = true

  for i=128,76,-1 do
    show_credits = i
    yield() yield()
  end

  while true do yield() end
end

function plr_dead()
  for i=1,40 do
    -- args: x, y, dx, dy, lifetime, size, gravity, color (color can be a table)
    add_new_dust(player.x,player.y,rnd(4)-2,rnd(7)-4,25,rnd(2)+1,0.05,{5,6,6,6,6,6,7,7,7,7,13,13,13,13,13,12,12,12,12,12,1,1,1,1})
  end

  player.pogoing = false

  sfx(3)
  add(coroutines, cocreate(plr_dead_coroutine))

  locked = true
  player.dead = true
  player.dy += 2*jump_speed
end

function plr_dead_coroutine()
  for i=1,30 do
    yield()
  end

  load_level()
end

function contains(tbl, val)
  for _, i in pairs(tbl) do
    if val == i then return true end
  end
  return false
end

local maxXCoord = level_width * 8
function solid(x, y, mask)
  if x < 0 or x > maxXCoord or y < 0 then return true end

  -- grab the cel value
  val = mget(currMapOffset.x + flr(x / 8), currMapOffset.y + flr(y / 8))
  
  -- check if the flag
  return fget(val, mask)
end

-- check if a rectangle overlaps
-- with any walls
function solid_area(x,y,w,h, mask)
 return 
  solid(x-w,y-h,mask) or
  solid(x+w,y-h,mask) or
  solid(x-w,y+h,mask) or
  solid(x+w,y+h,mask)
end

function _init()
  next_level()
end

function next_level()
  monsters = {}
  crumbling_platforms = {}
  crumbled_platforms = {}
  load_level()
end

function load_level()
  dust = {}

  player = Player:new(nil, 8, 8)
  if lvl_idx == 4 then player.facing_l = true end

  currMapOffset = getLevelOffset()
  minCamX = 0
  maxCamX = 0 + level_width * 8 - 128
  minCamY = 0
  maxCamY = 0 + level_height * 8 - 128

  local savedStartPoint = level_start_points[lvl_idx]
  if savedStartPoint then
    player.x = savedStartPoint.x
    player.y = savedStartPoint.y
  end

  for x=0,level_width-1 do
    for y=0,level_height-1 do
      local tile = mget(currMapOffset.x + x, currMapOffset.y + y)
      if not savedStartPoint and tile == 1 then
        -- player tile. Clear the tile, then set player position
        mset(currMapOffset.x + x, currMapOffset.y + y, 0)
        player.x = x*8 - 4
        player.y = y*8 - 4

        level_start_points[lvl_idx] = {
          x = player.x,
          y = player.y
        }
      elseif tile == 98 then
        -- found level exit
        exit_loc = {x = x, y = y}
      elseif tile == 7 then
        -- monster type 0
        mset(currMapOffset.x + x, currMapOffset.y + y, 0)
        local xPos = x*8+4
        local yPos = y*8+4
        local monster = Enemy:new(nil, xPos, yPos, 7, 0)
        add(monsters, monster)
      end
    end
  end

  locked = false
  locked_cam = nil
  exiting_r = nil
  time_paused = false

  time_display_time = 30
end

function _update()
  for k,v in pairs(debncd_btns) do
    if not v.last_press then
      goto skip
    end

    v.pressed = false
    if btn(k) then
      if v.last_press == 0
          or v.last_press >= v.rep_spd then
        v.pressed = true
        v.last_press = 0
      end

      v.last_press += 1
    else
      v.last_press = 0
    end

    ::skip::
  end

  for d in all(dust) do
    d:update()
  end

  -- crumble platforms that have been stepped on
  for cp in all(crumbling_platforms) do
    local frame = cp.frame or 0
    frame += 1
    cp.frame = frame
    if frame == 1 then crumbling_platform_dust(cp.x, cp.y, 8, 5) end
    if frame == 15 then crumbling_platform_dust(cp.x, cp.y, 8, 5) end
    if frame < 15 then
      mset(cp.x, cp.y, crumbling_platform_tiles[2])
    elseif frame < 30 then
      mset(cp.x, cp.y, crumbling_platform_tiles[3])
    else
      crumbling_platform_dust(cp.x, cp.y, 15, {6,6,6,6,6,6,6,5,5,5,5,5,5,5,5})
      mset(cp.x, cp.y, 0)
      cp.frame = 0
      del(crumbling_platforms, cp)
      add(crumbled_platforms, cp)
    end
  end
  -- restore crumbled platforms after a count
  for cp in all(crumbled_platforms) do
    cp.frame += 1
    if cp.frame > 90 and not actor_on_tile(cp.x, cp.y) then
      mset(cp.x, cp.y, crumbling_platform_tiles[1])
      del(crumbled_platforms, cp)
      crumbling_platform_dust(cp.x, cp.y, 15, 6)
    end
  end

  for c in all(coroutines) do
    if costatus(c) ~= 'dead' then
      local status, err = coresume(c)
      if not status then printh('error resuming coroutine: ' .. err) end
    else
      del(coroutines,c)
    end
  end

  for m in all(monsters) do
    m:update()
  end

  player:update()

  if game_over_ship_thrusters then
    game_over_ship_thrusters += 1
    if game_over_ship_thrusters > 20 then game_over_ship_thrusters = 1 end
  end
end

-- y0 must be lower (bigger number) than y1
function ditherstripe(y0, y1, color, level)
  local height = y0 - y1

  -- ... ... ... ...
  -- . ... ... ... .
  if level == 1 then
    for y = y1,y0 do
      startx = y%2==0 and 0 or -2
      for x = startx,127,4 do
        line(x,y,x+2,y,color)
      end
    end

  --  ... ... ... ..
  -- . . . . . . . .
  elseif level == 2 then
    for y = y1,y0 do
      if y%2==0 then
        for x=-1,127,2 do
          pset(x,y,color)
        end
      else
        for x = -2,127,4 do
          line(x,y,x+2,y,color)
        end
      end
    end

  -- full checkerboard
  elseif level == 3 then
    for offset=-height-1,128,2 do
      line(offset,y0,offset+height,y1,color)
    end

  -- .   .   .   .  
  -- . . . . . . . 
  elseif level == 4 then
    for y = y1,y0 do
      if y%2==0 then
        for x=-1,127,2 do
          pset(x,y,color)
        end
      else
        for x = -2,127,4 do
          pset(x,y,color)
        end
      end
    end

  -- .   .   .   .
  --   .   .   .   .
  elseif level == 5 then
    for y = y1,y0 do
      startx = y%2==0 and 0 or -2
      for x = startx,127,4 do
        pset(x,y,color)
      end
    end

  end
end

-- initial 32
-- fade1 6
-- fade2 6
-- fade3 6
-- bkg 8 + 12 (to cover next dither)

ring_colors = {15, 9, 4}

function draw_background(bk_level)
  cls(bk_level>=3 and 6 or 0)

  camera(camX / 8, 0)

  -- draw stars
  for i,star in pairs(stars) do
    circ(star.x, star.y, star.sz, 7)
  end

  camera(camX / 4, 0)

  -- draw rings
  tilt = 16
  for i,color in pairs(ring_colors) do
    offset = 56 + i*8
    for j=1,12 do
      line(offset+i+(j/2),127,offset+tilt+(i*6)+j,0,color)
    end
  end

  camera(0, camY / 4)

  local background_colors = background_colors_list[bk_level]

  for i, color in pairs(background_colors) do
    local offset = 162 - (#background_colors - i) * 28

    -- full-color stripe
    rectfill(0,offset+14,127,offset-16,color)

    -- blend with color above
    ditherstripe(offset-17,offset-18,color,1)
    ditherstripe(offset-19,offset-22,color,2)
    ditherstripe(offset-23,offset-26,color,3)
    ditherstripe(offset-27,offset-28,color,4)
    ditherstripe(offset-29,offset-31,color,5)
  end
end

function _draw()
  if fading then fade(fading) else pal() end

  calc_cam()

  draw_background(lvl_idx)

  camera(camX, camY)
  map(currMapOffset.x, currMapOffset.y)
  for m in all(monsters) do m:draw() end

  if not game_over_ship_flying then
    player:draw()
    if game_over and game_over_frame_num > 0 then
      -- draw player waving
      if flr(game_over_frame_num / 10) % 2 == 0 then
        spr(22, player.x - 6, player.y-2)
      else
        spr(22, player.x - 4, player.y-4)
      end
    end
  else
    draw_ship()
  end

  -- draw exit over player if exiting
  if exiting_r ~= nil then
    spr(112, exiting_r.x, exiting_r.y)
    spr(83, exiting_r.x, (exiting_r.y - 8))
    spr(84, (exiting_r.x + 8), (exiting_r.y - 8))
    spr(100, (exiting_r.x + 8), exiting_r.y)
  end

  for d in all(dust) do
    d:draw()
  end

  -- ui
  pal()
  camera()
  if game_over then
    if game_over_show_ui then
      rectfill(0, 0, 34, 24, 0)
      print(fmt_num(time_minutes) .. ':' .. fmt_num(time_sec) .. '.' .. (flr(time_frames / 3)), 2, 2, 7)
      spr(49, 0, 8) -- bear icon
      print(bears, 9, 10, 7)
      local candy_icon = lvl_idx <= 2 and 48 or 50
      spr(candy_icon, 0, 17) -- lollipop icon
      print(lollipops, 9, 18, 7)
    end
    if show_credits then
      print('stranded on saturn', 24, show_credits, 7)
      print('by janpaul bergeson', 22, show_credits + 10, 7)
      print('thanks for playing!', 22, show_credits + 30, 7)
    end
  elseif fading or time_display_time > 0 then
    rectfill(0, 0, 34, 8, 0)
    print(fmt_num(time_minutes) .. ':' .. fmt_num(time_sec) .. '.' .. (flr(time_frames / 3)), 2, 2, 7)
  elseif item_disp_time > 0 then
    rectfill(0, 0, 22, 16, 0)
    spr(49, 0, 0) -- bear icon
    print(bears, 9, 2, 7)
    local candy_icon = lvl_idx <= 2 and 48 or 50
    spr(candy_icon, 0, 9) -- lollipop icon
    print(lollipops, 9, 10, 7)
  end
end

function fmt_num(num)
  if num < 10 then return '0' .. tostr(num) end
  return tostr(num)
end

function calc_cam()
	camX = player.x - 64
  camY = player.y - 64

  if camX < minCamX then camX = minCamX end
  if camX > maxCamX then camX = maxCamX end
  if camY < minCamY then camY = minCamY end
  if camY > maxCamY then camY = maxCamY end

  if locked_cam ~= nil then
    camX = locked_cam.x
    camY = locked_cam.y
  elseif locked then
    locked_cam = {
      x = camX,
      y = camY
    }
  end
end

function draw_ship()
  for s=44,47 do
    spr(s,ship_coords.x + ((s-44)*8),ship_coords.y)
    spr(s+16,ship_coords.x + ((s-44)*8),ship_coords.y+8)
  end
  spr(30,ship_coords.x+16,ship_coords.y-8)
  spr(31,ship_coords.x+24,ship_coords.y-8)

  if game_over_ship_thrusters then
    local thrusters_spr = game_over_ship_thrusters % 4 < 2 and 14 or 15
    spr(thrusters_spr,ship_coords.x+30,ship_coords.y+4)
    spr(thrusters_spr,ship_coords.x+28,ship_coords.y+5)
  end
end
__gfx__
0000000000000000001b7100001b7100001b710000000000001100000001cc100001cc100001cc100001cc100000000000000000110000000009900000000000
00000000001b710001b3b71001b3b71001b3b7100000000001b71000001c71c1001c71c1001c71c1001c71c10000000000000001cc1000000889aaa00089a000
0000000001b3b710013ff100013ff100013ff100000000001b3b71100011cc100011cc100011cc100011cc100000000000000001ccc10000089aaa00089aaa00
00000000013ff1000013771000137710001377100011111013ff112101cc110001cc110001cc110001cc11000000000000000001c7cc100089aaa77789aa7770
00000000001377100012d1100012d1100122d2211122b321013772101c1100001c1110001c1100001c1110000000000000000001cc7c100089aaa77789aa7770
000000000012d100012d2271012dd271017dd7107ddb3b3612ddd17101cc100001ccc11011cc10001cccc10000110cc000000001ccc7c100089aaa00089aaa00
0000000000172710167dd7611772d7610167767167d3ff65217dd76111c1c1101cc11cc1ccc1c1001c11cc10ccc0117c00000001ccc7c1010889aaa00089a000
000000000176767101671710016716100171111071dd377617671171cc101cc11c1001101111cc1001c11100c11c011000000001ccc7c1170009900000000000
00000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000001ccc7c1770000000000000000
00000000000000000000000000000000001001000017b1001ff100000000000000000000000000000000000000000000000000001cc7c1770000000000000000
0000000000099000000909000090900001d6671001b37b101ff1000000000000000000000000000000000000000000000000000001c7c1770000000000000000
00000000009aa900009a9a9009a9a900001d7100013ffb1001100000000000000000000000000000000000000000000000000000001116660000000000000000
0000000009aaaa9009aaaa9009aaaa90000d70000017710000000000000000000000000000000000000000000000000000000000015517770000000000000000
00000000009aa90009a9a900009a9a90000d70000012d10000000000000000000000000000000000000000000000000000000000155517770000000000000000
0000000000099000009090000009090001d667100172d71000000000000000000000000000000000000000000000000000111111555177660000000111100000
50000000000000000000000000000000001d71000767767100000000000000000000000000000000000000000000000071555555551176880000001777710000
99090090080808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000017777100000
0a9aa9a98a8a8aa80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177771000000
888a9888eeeaeaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111677761000000
9a8a8a80eaeaaaee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011cccccc166661111100
a8a8a889eeaaeaee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001cc777777177776666610
8aa8a880eaeaeae80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001cc733cccc177776788d61
888a8a80eee8a8a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111cc73333cc1776666666dd6
009a090908008080000000000000000000000000000000000000000000000000000000000000000000000000000000000111777771cccc663c1176887788d6d5
001111000003300000151100001511000013110000000000000000000000000000000000000000000000000000000000177777777711111111776227722ddd61
012288100037730001566710015006100136671000000000000000000000000000000000000000000000000000000006777777777777777777775227722ddd51
12288781003db300011dd61001500610013bbb10000000000000000000000000000000000000000000000000000000006677777777777777777775116611d510
12288881030330300156671001500610013667100000000000000000000000000000000000000000000000000000000011666677776666666677775555555100
012288103d3db3b301288e100150061001133b100000000000000000000000000000000000000000000000000000000000111165666777777766776611111000
0016710003db7b300156671001566710013667100000000000000000000000000000000000000000000000000000000000001651111667777761561100000000
001671003d3db3b30011110000111100001111000000000000000000000000000000000000000000000000000000000000116510000116666661156110000000
00011000030330300000000000000000000000000000000000000000000000000000000000000000000000000000000001666661000001111111666661000000
0dddddd0dddddddd0001500025d0026d00000000dddddddd0111111000015000000000000dddddd0dddddddd21d0021ddddddddd21d0021d0000000000000000
2555555d666666660001500025d0026d000000006666666612499ef100015000000000002111111d1111111121d0021d1111111121d0021d0000000000000000
2555555d222222220001500025d0026d000000002222222212499ef100015000000000002111111d22211d2221dddd1d2222222221d0021d0000000000000000
2555555d000000000001500025d0026d111111111111111112499ef111111111000000002111111d00211d002111111d0000000021d0021d0000000000000000
2555555d000000000001500025d0026d555555551111111112499ef155515555000000002111111d00211d002111111d0000000021d0021d0000000000000000
2555555ddddddddd0001500025d0026d00000000dddddddd0111111000015000000000002111111ddd211ddd2122221ddddddddd21d0021d0000000000000000
2555555d555555550001500025d0026d00000000555555550000000000015000000000002111111d1111111121d0021d1111111121d0021d0000000000000000
02222220222222220001500025d0026d0000000022222222000000000001500000000000022222202222222221d0021d2222222221d0021d0000000000000000
00077777777000077777700077700007777770000000000000c00c0000000000000000000999999099999999249002a921d00d1221d0021d0000000000000000
00766666666700766666670066670076666667000000000001c11c10000000000000000024444449aaaaaaaa249002a921d0d120021d021d0000000000000000
06733b33bbb6766555555670bbb676655555567000000000ccc00ccc000000000000000024444a4922222222249002a921dd12000021d21d0000000000000000
673b33b33bbb6758885855673bbb675bbb5b556700c000c00101001000000000000000002444444900029000249902a921d120000002121d0000000000000000
67333b33bbb3675855558567bbb3675b5555b56700c000c00100101000000000000000002444444900290000249292a9211200000000211d0000000000000000
673b33b33bbb6758585855673bbb675b5b5b55670dcc0dccccc00ccc00000000000000002444444999999999249022a9212000000000021d0000000000000000
67333b33bbb3675855558567bbb3675b5555b5670dcd0dcd01c11c1000000000000000002444444944444444249002a912000000000000210000000000000000
673b33b33bbb6758885885673bbb675bbb5bb56701d101d100c00c0000000000000000000222222022222222249002a920000000000000020000000000000000
67333b33bbb3675585558567bbb36755b555b5670999999009999990099909900000000099999990099999992999999900000000000000000000000000000000
673b33b33bbb6755555555673bbb675555555567d8888889d8882889d882028900000000a9444449244444942444444900000000000000000000000000000000
67333b33bbb36758a7a82567bbb3675ba7ab3567d8888889d8889889d9200989000000002a922220022229422442244900000000000000000000000000000000
673b33b33bbb6755555555673bbb675555555567d8888889d2920289000000220000000002a90000000094202490024900000000000000000000000000000000
67333b33bbb36758a7a82567bbb3675ba7ab3567d8888889d88209292900000000000000002a9000000942002900002900000000000000000000000000000000
673b33b33bbb6755555555673bbb675555555567d8888889d8889889d8900299000000000002a900009420002900002900000000000000000000000000000000
67333b33bbb3675555555567bbb3675555555567d8888889d8828889d82028890000000000002a90094200002000000900000000000000000000000000000000
673b33b33bbb6755555555673bbb6755555555670dddddd00dddddd00dd02dd000000000000002a9942000000000000000000000000000000000000000000000
000067550000000000000000000000000000000000000000000000000000000000000000249002a9a49002a90000000000000000000000000000000000000000
000067550000000000000000000000000000000000000000000000000000000000000000249002944a9002a91000000000000001000000000000000000000000
0000675b00000000000000000000000000000000000000000000000000000000000000002490094224a002a95100000000000015000000000000000000000000
00006755000000000000000000000000000000000000000000000000000000000000000024909420024a02a90510000000000150000000000000000000000000
0000675b0000000000000000000000000000000000000000000000000000000000000000249942000024a2a90051000000001500000000000000000000000000
0000675500000000000000000000000000000000000000000000000000000000000000002494200000024aa90005100000015000000000000000000000000000
00006755000000000000000000000000000000000000000000000000000000000000000029420000000024a90000510000150000000000000000000000000000
000067550000000000000000000000000000000000000000000000000000000000000000942000000000024a0000051001500000000000000000000000000000
00000000000024000000000000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000013
13000000000023230000000000000000000000000013130000000000000000000000000000000013000000000000000000000000000000000000000000000000
00000000000024000000000000000000000000000000000000000000000000000000000000000000000024000000000023232323232300000000000000000000
00000000000023230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000024000000000000000000000013000000000000000000130000000000000000001300000024000000000000000000000000000000000000000000
00000094000023230000000000000000000000000064640000000000000023230000000000000000000000000000000000000000000000000000000000000000
00000000000024000000000000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000
00000065000023230000000000000000000000000065650000000000000023230000002323000000000000000000000000000000000000000000000000000000
00000000000056000000007000700070000000000000000000007000700070000000000000000000000056000000000023232323232300000000000000000000
00000065000023230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000095a5a5a5a5a5a5a5a5a59556565695a5a5a5a5a59556565695a5a5a5a5a59556565695a595000000000000000000000000000000000000000000
00000024000000000000000000000000000000000000000000000000000000000000002323000000002323230000000000000000000000000000000000000000
000000000000b51300246565656565650000130000006565650000000000000065656500000000000013b5000000000000000000000000000000000000232300
00000074444494940000000000000000000000000000000000000000000000000000002323000000000000000000000000000000000000000000000000000000
000000000000b50000240000000000000000000000000000000000000000000000000000000000000000b5000000000000000000000000000000000000000000
232300000000000000000000000000000000000000000000000000000000000000000000000000940023232300000000000000000000000000000000c0d0f100
000000000000b50000240000000000000000000000000000000000000000000000000000000000000000b5000000000000000000000000000000000000000000
2323000000000000000000000000000094232323232323232323239400000000000000232300009400000000000000000000000000000000000000c2c1d1f200
000000001300b50000240000000000000000000000000000000000000000000000000000000000000000954444444444a6a6a696969600000000000000000000
0000000000000000000000232300000094232323436464432323239400000000000000000000009400555555000000000000000000000000000000c3d3e3f313
000000000000b500002400000000000000000000000000000000000000000000000000000000000000005600000000a6b6b6b6b6b6b696000000000000000000
9494b700002323000000002323000000940000000000000000000094000000000000005555000094949494949494949494949494949494949494949494949494
000000000000b5000024000000000000002323230000006565000023232300000000000000232323000056000000a69595959595959595b70000700000000000
24d59400002323000065000000000000746494555555555555946474000000009494949494949494000000000000000000000000000000000000000000000000
000000000000b50101240000000000000000000000000000000000000000000000000000000000000000560000a6959523232323232395569664646464646464
240000000000000000240000000000000000d5949494949494c50000000000009413000000000000000000000000000000002323000000000000002323230000
00000000000095a5a59500000001010000000000000000000000000000000000000000010100000000002300a695950000000000000000239596130000000000
24000000009494444474000000000000000000000000000000000000000000009494940000000000010000000023232300002323000000000000002323230000
000000000000000013b500000064640000000000000000000000000000000000000000a696000000000095009595000000000000000000239595960000000000
2400000000000000000000000000000000640000000000000000640000000094c565650000000000010000000000000000000000000000940000000055000000
000000000000000000b5000000000000006565000000000000000000000000000000a6b6b69600000000b5000000000000000000000000239595959600000000
24000000000000000000002323000000000000000000000000000000000094c50024000000000000010000000000000000000000000000d40000009494940000
000000000000000000b50000000000000000000000232300232300000000000000a6b60000b6b7000000b5000101000000000000000000002400959596000000
240000000000000000000000000000000000000000000000000000000094c5000024000000000000010000000094c49400000000000064b46400000065000064
000000002323000000b500000101000000000000002323002323000000000000a6b60023230056960000b5646464000023232300000000002400009595000000
7444446565000000000001010101000000000000000000000000000094c565000024000000000001010100000000000000000000000000d40000000000000000
000000000000000000b50000a6960000000000000000000000000000000000a6b6000023230000b69600b5230000000000000000000001019500000000000000
240000000000000000c794949494b700000023232323000000000094c56500000024000000000094949400000000000000000000000055d45500000000000000
000000000000232300b500a6b6b696000000000000565600565600000000a6b60000000000000000b696b5230000000000000000000064649523000000000000
2400000000000101c7946565656594b70000232323230000000094c56500000000240064640000d4656500000000000000000000000094b49400000000000000
000000000000232300b5a6b62323b69600000000000000000000000000a6b600000000000000000000b6a7230000000000000000000000009523000000232300
2400000000006464940000000000009400000000000000000094c5650000000000240000000000d4131300000000000000000000000000d40094000000000000
00000000232300000097b600000000b6000000000000000000000000a6b6130000010101010101000000b6960000000064646400000000009523000000000000
2400000000000000d4232323232323d4007000700000000094c500000000000000240000000000d400000000000000000000000055000094c4a4c49400000000
0000000023230000a6b6000000000000000101000000000000000000b6b6b6950064646464646400000000b60000000000000000002323009523000000000000
940101000000000094232323232323949494949494949494c50000000000000000240000000000b4000000000000000000000094c4940000002323d464000000
00100000000000a6b60000700000000000b696000000000000000000000000950000000000000095950000000000000000000000002323009523000000000000
946464000000000000000000000000000000000000002400000000000000000000240064640000d400000000000000000000000000000000002323d400000055
000000000000a6b6b6b6b6b66464b6b6b6b6b6960000000000000000000000950000000000000000950000000000000000000000000000009523000000232300
000000000000000000000000000000000000000000002400000000000055000000240000000000d400000000005500000000000000000000002323d494000094
000000000000b6009500000000000000009500b60000000000000000000000950000000000000000950095000000232300000064646400009500000000000000
565656565656565656565656565656565656565656569400000000006464640000240000000000b40000000094c4940000000000000000000000239494000000
000000000000000095000000000000000095000000000000000000000000009595000000000000959500b5000000232300000000000000009500000000000000
13000000000000000000000000000070007000700000d400000000000000000000240000000000d4000000000000000000000000550000000055946565000000
000000000000000095000000000000000095000000000000232300000000000095000023230000951300b5000000000000000000000000009500000000000000
56565656565656565656565656565656565656565656b400646464000000000000240064640000d4000000000000000000000000949400000094232323000000
000000000000000095000000000000000095000000000000000000000000000095000000000000950000b5000064646400002323000000009500232300232300
13000000000000007000700070000000000000000000d400000000002323230000240000000000b4000000000000000000000000000000000094232323000000
232323230000000023000000000000000023000000000000000000000000000024000000000000956400b5000000000000002323000013009500232300051525
56565656565656565656565656565656565656565656b400232323002343230000240023230000d4232300000000000023232300000000009400000000000000
000000000000000023000000007000000023000000000095000095000000700024000000000000955555b5000070007000000000000000009500000000061626
13700070007000000000000000000000000000000000d400000000005555550000240055550000d4000000000055550070007000700000009455000000001000
95959595959595959595959595959595959595959595959500009595959595959595959595959595959595959595959595959595959595959595959595959595
94949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494949494
__gff__
0000000000000000000000008080000000000000000000000000000080800000000000000000000000000000808080804040480848000000000000008080808001010001000108000001010101010000808000800002040000010101010100008080008000101010000101010000000080000000000000000001010000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000003000000000433100000000000000000000000000000000000000000000000000004200420000000000000000000000000000000000000000000042000000000000004000000000000000310000000000000000003030300030303000303030000000000000000000000000000000000000000000420000003000
0000000000003000000000434600000000003030000000000000000000000000000000000000004031400000000000000000000000000000000000000000003142000000000000004000000000000030303000000000000000000000000000000000000000000000000000000000000000000000000000100000420000003000
0000000000003000000000430000000000003030000000000000000000000000000000000000000040000000000000000000000000000000000000000000000042010000000000004000000000000046464600000000000000000000000000000000000000000000000000000000000000000000000000100000420000003000
0000000000000000000000430000000000000000000000000000000000000000000030303000000000000000000000003030000000003030000000000000000040404040000000004000000000000000000000000000000000006565650065656500656565000000000000000000000000000000000000100000420000003000
0000000000004000000000430000000000000000000000303000000000000000000000000000005656560000000000000000000000000000000000000000000042000000000000004000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000100000420000000000
0000000000004300000000430000000000000000000030000030000000000000004646464000000000000000000000004040000000004040000000000000000042000000000000004030303040070007000700070000000040400000070007000000000000400000000000000000000000000000000000100000420000000000
0000303000004300000000400000000000000000000000000000000000003030000000004300000000000000000000000000000000000000000000000000000042004040404040404030303040656565656565656565656540404040404040404040404040404040406565654040404040404040404040404044474444444000
0000303000004300000000000000000000000000000000000000464646000000000000004346464646460000000000000000000000000000000000000046000042000040303030000000101040310000000000000000003140303030303000000000000000000000400000004031000000000000003156563000420000000000
0000303000004300000000000000000040414141414000000000000000404545400000004300000000000000003030000000003030000000003030000010000042003040303000000000000040404040404040404040404040303030303000000000000030303000403030304000000000003030000000003000420000000000
0000000000004300000000000000000000000000000000000000000000000000420000004300005656560000000000000000000000000000000000000010000042003040300000000000101040310056000000000000310000000000000000000000000030303000403030304000000000000000000040403000400000000000
0000505152004355000000005500000055550000003000000000000000003030420000004300000000000000004040000000004040000000004040000010000042003040656565306565404040000000000000000000000000464646464665656565650030303000404040404000000000006565000000403000000000000000
3100606162004340464646464041414141400000003000000000000000003030420000004300000000000000004242000000004242000000004242000010003042003040653065653065403000000000000000303030000000000000000055555555550030303010000000000000000000000000000000400000000000003030
4040404040404040000000000000000000430000000000000000000000000000420000004040404646460000004242000000004242000000004242000010003042003040656530656565403000000000000000303030000000000000003040404040400010101010003030000000000000000000000000400000000000003030
0000000000005656000000560000000000435555555500000000000000000000420000004200425555550000004242555555554242555555554242400010003042000040656565653065403000000065000000000000000000000000003040000000404040404040000000000030300000000030300000404646000040000000
0000000000000000000000000000000000404141414141414000003100004041414141414141414141414141414141414141414141414141414140404040003042000040653065656565403000650030000000000000000030303000003040000000000000000040006565000000000000000000000000404444444440404040
0000000000000000000000000000000000420000000000004200000000000000000000000000420000000000000000000000000000000000003143000042003042000040310700653030403000000030000065000000656530303065653040000000000000000040000000000065650000000065650000400000000000000000
0000000000000000000000000031000000420000000000004055405555000056000000003030420000000000003030300000000000000000000043000042000042000040656565656565406500006530000000000000000000000000003040000000005051520040000000000000000000000000000000400000000000000000
0000000000000000000000000040444444400000000000004041414140565600000000000000420000000000000000000000000000000000000043000040404042000040653107006530400000000000000000000000000000000000003040000000006061620040000000000000000000000000101010400000000000000000
0000000000004646000000000000000000000000000000000000000000000000000000000000420000000000000000000000000000000000000043460000423042300040306565656565400065000000650000650000300000650000003040464646404040404040464646000000000000000000404040404646464600000000
0031000000005656000000000000000000000000000000000000000000303000000000000000420000000000004646460000000000000000000043000000423042300040656531070065400000000000000000000000300000000000003040000000000000000000000000656500000065650000403000300000000000000000
4041400000000000000000000000000000000000000000303030000000000000000000000040400000000000555555555500000000004040000040000000420042300040653065656530400000000000000000000000300000000000003040000000000000000000000000000000000000000000403000300000000000000000
4230420000000000000000000000000000000000000030000000300000000000000000000040404545454545454545454545454545454040000000000000420042300040000000000000400010101010101010100000000000000000003040000700070007000700070000000000000000000031403000300000303000000000
4230420000003030000000000000000000000000000000000000000000000000000000004040400000000000000000000000300000004040000000000000420042300040003030300000400046464646004046466565464665654646656540656565656565656565404040404040404040404040403000300000303000000000
4200420000000000000000000000000000000000000000000000004000000000400000004230420000003030000000000000000000000030000000000000420042000040000000000000000000000000004000000007070700000000555540310000000000000000400031005631000000303030400000000000000000000000
4200420000000000000000000000000000000000000000000000000000000000000000004230420000000000000000000000000000000000000000000000420042000040404040404040404040404040404040404040404040404040404040404040404040404040400046465600000000464646403107070000404000000000
4200420000005555000000000000303000000000004040000000000000000030000000004230420000000000000000000046464600000000000000004646420042000042000000000000300000000042000000000000000000000000003030300030303000303030000000000000000000000000404040404040404000000000
4040404040404040404000000000303000000040400000000000000000003000300000004200420000000000000000000000000000000000000000000000420042000042000000000000300000000042000000303000303000000000100000000000000000000000000000000000000000000000000000000000004200464600
0000004200000042000000000000000000000000000000303000000000000000000000004200420000404040400000000000000000000040404040000000404042303042000000000000300000000042000000303000303000000000100000000000000000000000000000000000000000004646464646001000004200000000
0000004200000042000000000000404000000000000000000000000000000000000000004200420000423030420000000030303000000042303042000000420042303042000000000000000000000042000000000000000000000000100000000000000000000000000000000000404040400000000000001030304200303000
0000004200000042000000000040404040000000000000000000000000004040400000004200420000420000420000000000000000000042000042000040420042000042000000000046464600000042000000464600464600000000100040464646004646460046464600000000000000000000000000001030304200303000
0001004200000042000000004040404040400000000000555500000000004040400000004200420000420000420000000000000000000042000042000000423142000042004000000700000000000040000000000000000000000000404031000700300007003000070030004007075555555555070740401000004200000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404040400000404040404040004040404040000040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
__sfx__
000300001e330003001e3300030015370153501c3001b3001c3601c35000300003000e30021350213500030000300003003135031350003000030000300393403934039340003000030000300003000030000300
000100000671000630006300060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000371000630006300060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200003d3503b3503835035350303502d3502a350273502535023350203501e3501b350183501535012350103500e3500b35009350036500365003650036500365003650046500365003650036500265003650
00050000103200d6100b1000d60014600146000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400000725005640022300860008600086000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000763007630076300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000b2700b2700c2600e25011240132301621000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000300001d2701a27016260112500b240052300121000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
0002000017061180411b0212001026000270010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000200001a0601b0401b0301c0201e010270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d0601e040200302302026010270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002c55034550345503455034530345102150021500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400002f5502f550385503855038530385102150021500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
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
