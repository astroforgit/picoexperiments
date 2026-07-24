pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- cathack
-- by jessicatz

entities = {}
scenes = {}

fc = 1
fade_scr_val = 0

k_left = 0
k_right = 1
k_up = 2
k_down = 3
k_o = 4
k_x = 5

function debug(obj, lvl)
 local level = lvl or ""
 if type(obj) == "table" then
  for k, v in pairs(obj) do
   local key = level..k
   if type(v) == "table" then
    printh(key..": ", "log", false)
    debug(v, level.." ")
   elseif type(v) == "number" or type(v) == "string" then
    printh(key..": "..v, "log", false)
   elseif type(v) == "boolean" then
    printh(key..": "..(v and "true" or "false"), "log", false)
   else
    printh(key..": ["..type(v).."]", "log", false)
   end
  end
 end
end

function fade_scr(fa)
 fa=max(min(1,fa),0)
 local fades={
  {1,1,1,1,0,0,0,0},
  {2,2,2,1,1,0,0,0},
  {3,3,4,5,2,1,1,0},
  {4,4,2,2,1,1,1,0},
  {5,5,2,2,1,1,1,0},
  {6,6,13,5,2,1,1,0},
  {7,7,6,13,5,2,1,0},
  {8,8,9,4,5,2,1,0},
  {9,9,4,5,2,1,1,0},
  {10,15,9,4,5,2,1,0},
  {11,11,3,4,5,2,1,0},
  {12,12,13,5,5,2,1,0},
  {13,13,5,5,2,1,1,0},
  {14,9,9,4,5,2,1,0},
  {15,14,9,4,5,2,1,0}
 }

 for n=1,15 do
  pal(n,fades[n][flr(fa/(1/8))+1],1)
 end
end

function wait(frames)
 for i=0,frames do
  yield()
 end
end

function outcubic(t, b, c, d)
 return c * (((t / d - 1) ^ 3) + 1) + b
end

function lerp(a, b, t)
 return a + (b - a) * t
end

function collide(a, b)
 return a.x1 < b.x2 and
        b.x1 < a.x2 and
        a.y1 < b.y2 and
        b.y1 < a.y2
end

function solid(x, y)
 if (x < 0 or x >= 128 or y < 8 or y >= 128) return -1
 local sprite = mget(x / 8, y / 8)
 if (fget(sprite, 0)) return sprite
end

function merge(a, b)
 for k, v in pairs(b) do
  a[k] = v
 end
end

function bbox(entity)
 local x1 = entity.x + entity.bbox.x
 local y1 = entity.y + entity.bbox.y
 return {
  x1 = x1,
  y1 = y1,
  x2 = x1 + entity.bbox.w,
  y2 = y1 + entity.bbox.h,
  center_x = x1 + entity.bbox.w / 2,
  center_y = y1 + entity.bbox.h / 2
 }
end

function add_scene(scene)
 add(scenes, scene)
 entities = scene.entities
end

function del_scene(scene)
 del(scenes, scene)
 entities = scenes[#scenes].entities
end

function particle(x, y, type, args)
 local self = {
  type = type,
  x = x, y = y,
  w = 0, h = 0,
  t = 1, t_end = 1,
  flip_x = false, flip_y = false,
  frames = {},
  frame = 1
 }

 merge(self, args or {})

 function self:draw()
  spr(self.frames[self.frame], self.x, self.y,
   self.w / 8, self.h / 8, self.flip_x, self.flip_y)
 end

 function self:update() end

 function self:updater()
  while true do
   if self.t >= self.t_end then
    del(entities, self)
    return
   end

   self.frame = 1 + min(
     #self.frames - 1,
     flr(self.t / (self.t_end / #self.frames)))

   self:update()

   self.t += 1
   yield()
  end
 end

 local types = {
  dust = {
   x = x + 1 - rnd(2),
   y = y + 1 - rnd(3),
   r = 1,
   r_end = rnd(1) + 1,
   t_end = 4 + rnd(5),
   frames = {7, 7, 7, 6},
   draw = function ()
    circfill(self.x, self.y, self.r,
     self.frames[self.frame])
   end,
   update = function ()
    self.r = min(self.r + self.r_end / self.t_end, self.r_end)
   end
  },
  dash_blink = {
   x = x - 3,
   y = y - 3,
   w = 8,
   h = 8,
   frames = {78, 77, 76, 76, 77, 78},
   t_end = 6
  },
  whack_sprite_lr = {
   w = 8,
   h = 16,
   frames = {108, 109},
   t_end = 4
  },
  whack_sprite_ud = {
   w = 16,
   h = 8,
   frames = {110, 126},
   t_end = 4
  },
  explosion_puff = {
   r = 1,
   r_end = rnd(2) + 1,
   t_end = 7,
   frames = {4, 8, 9, 10, 9, 8, 4},
   draw = function ()
    circfill(self.x, self.y, self.r,
     self.frames[1 + flr(rnd(#self.frames - 1))])
   end,
   update = function ()
    self.r = min(self.r + self.r_end / self.t_end, self.r_end)
   end
  },
  explosion = {
   t_end = 2,
   update = function ()
    for i = 0, 20 do
     add(entities, particle(x - 7 + rnd(14),
      y - 7 + rnd(14), "explosion_puff"))
    end
   end
  },
  wave_splash = {
   t_end = 60,
   draw = function ()
    local h = 16

    if self.t <= 10 then
     h = outcubic(self.t, 0, 16, 10)
    elseif self.t >= 50 then
     h = outcubic(self.t - 50, 16, -16, 10)
    end

    sspr(0, 16, 8, 16, 0, self.y + 8 - h / 2, 128, h)
    color(12)
    cursor(self.x, self.y + 5)
    print("wave "..self.wave)
   end,
   update = function ()
    self.x = outcubic(self.t, 0, 48, self.t_end / 3)
   end
  },
  gun_flame_lr = {
    w = 8,
    h = 8,
    frames = {130, 131},
    t_end = 2
  },
  gun_flame_ud = {
    w = 8,
    h = 8,
    frames = {128, 129},
    t_end = 2
  },
  tron = {
   t_end = 60,
   dy = 0,
   turn_t = 0,
   update = function ()
    self.x = lerp(0, 128, self.t / self.t_end)
    if self.turn_t <= 0 and rnd(10) < 1 then
     self.dy = 1.5
     if (rnd(1) < 0.5) self.dy = -1.5
     self.turn_t = 1 + rnd(10)
    end

    if self.turn_t > 0 then
     self.y += self.dy
     self.turn_t -= 1
    end
   end,
   draw = function ()
    pset(self.x, self.y, 8)
   end
  }
 }

 merge(self, types[type])

 self.threads = {
  cocreate(self.updater)
 }

 return self
end

function title_scene(init)
 local scene = {entities = init}

 function title(buttons)
  local self = {
   buttons = buttons,
   cursor = {1, 1}
  }

  function self:draw()
   rectfill(0, 0, 128, 128, 1)
   spr(192, 16, 16, 12, 2)
  end

  function self:tron()
   while true do
    add(scene.entities, particle(0, 32, "tron"))
    wait(30)
   end
  end

  function self:input()
   while true do
    local dx = 0
    local dy = 0
    local cur = self.cursor

    if (btnp(k_left)) dx = -1 sfx(6)
    if (btnp(k_right)) dx = 1 sfx(6)
    if (btnp(k_up)) dy = -1 sfx(6)
    if (btnp(k_down)) dy = 1 sfx(6)

    local new_x = cur[1] + dx
    local new_y = cur[2] + dy

    if (new_x < 1) new_x = 3
    if (new_x > 3) new_x = 1
    if (new_y < 1) new_y = 2
    if (new_y > 2) new_y = 1

    if self.buttons[new_y][new_x] == 0 then
     new_x -= dx
     new_y -= dy
    end

    cur[1] = new_x
    cur[2] = new_y

    for y = 1, #self.buttons do
     for x = 1, #self.buttons[y] do
      if self.buttons[y][x] != 0 then
       self.buttons[y][x].active =
        x == cur[1] and y == cur[2]
      end
     end
    end

    if btnp(k_x) then
     sfx(7)
     for i = 0, 12 do
      self.buttons[cur[2]][cur[1]].active = i % 2 == 0
      wait(1)
     end
     local btn_value = self.buttons[cur[2]][cur[1]].value

     if btn_value != "config" then
      for i = 1, 8 do
       fade_scr_val = i / 8
       wait(1)
      end
      fade_scr_val = 0
      add_scene(game_scene({players = btn_value}))
     else
      keyconfig()
     end
    end

    yield()
   end
  end

  self.threads = {
   cocreate(self.input),
   --cocreate(self.tron)
  }

  return self
 end

 function button(init)
  local self = {
   active = false,
   frames = {0, -8, 0, 8},
   frame = 1
  }

  function self:draw()
   self.frame = 1 + flr(fc / 4) % #self.frames

   pal()
   if (self.sprite) self:sprite()

   color(12)
   if (self.active) pal(12, 8) color(8)

   if self.texts[1] then
    spr(204, self.x, self.y)
    spr(205, self.x + 8, self.y)
    spr(205, self.x + 16, self.y)
    spr(205, self.x + 24, self.y)
    print(self.texts[1],
     self.x + 32/2 - #self.texts[1] * 4 / 2 + 1, self.y + 3)
   end

   if self.texts[2] then
    spr(204, self.x, self.y + 10)
    spr(205, self.x + 8, self.y + 10)
    spr(205, self.x + 16, self.y + 10)
    spr(205, self.x + 24, self.y + 10)
    spr(220, self.x, self.y + 8 + 10)
    print(self.texts[2], self.x + 5, self.y + 13)
    color(13)
    print(self.texts[3], self.x + 5, self.y + 13 + 6)
   end
  end

  merge(self, init)

  return self
 end

 local btn_foxeh = button({
  x = 12, y = 80,
  texts = {"1p", "foxeh", "melee"},
  value = {"foxeh"},
  sprite = function (self)
   local offset = self.frames[self.frame]
   if (not self.active) offset = 0
   sspr(32 + offset, 32, 8, 16, 18, 40, 16, 32)
  end
 })
 local btn_wolfie = button({
  x = 48, y = 80,
  texts = {"1p", "wolfie", "ranged"},
  value = {"wolfie"},
  sprite = function (self)
   local offset = self.frames[self.frame]
   if (not self.active) offset = 0
   sspr(32 + offset, 48, 8, 16, 54, 40, 16, 32)
  end
 })
 local btn_foxeh_wolfie = button({
  x = 84, y = 80,
  texts = {"2p", "foxeh+\nwolfie", ""},
  value = {"foxeh", "wolfie"},
  sprite = function (self)
   local offset = self.frames[self.frame]
   if (not self.active) offset = 0
   sspr(32 + offset, 32, 8, 16, 84, 40, 16, 32)
   sspr(32 + offset, 48, 8, 16, 94, 43, 16, 32)
  end
 })
 local btn_config = button({
  x = 48, y = 112,
  texts = {"config", nil, nil},
  value = "config"
 })

 add(scene.entities, title({
  {btn_foxeh, btn_wolfie, btn_foxeh_wolfie},
  {0, btn_config, 0}
 }))
 add(scene.entities, btn_foxeh)
 add(scene.entities, btn_wolfie)
 add(scene.entities, btn_foxeh_wolfie)
 --add(scene.entities, btn_config)

 return scene
end

function game_scene(init)
 local scene = {
  entities = {}
 }

 function bump(entity)
  local bbox = bbox(entity)
  return solid(bbox.x1, bbox.y1) or solid(bbox.x2, bbox.y1) or
   solid(bbox.x1, bbox.y2) or solid(bbox.x2, bbox.y2)
 end

 function bg()
  local self = {threads = {}}

  function self:draw()
   map(0, 0, 0, 0, 16, 16)
  end

  return self
 end

 function kitty()
  local self = {
   x = 49, y = 59,
   frames = {7, 10},
   frame = 1
  }

  function self:draw()
   palt(0, false)
   palt(12, true)
   spr(self.frames[self.frame], self.x, self.y, 3, 2)
   spr(39, self.x + 9, self.y + 2, 2, 2)
   palt()
  end

  function self:anim()
   while true do
    self.frame = 1 + flr(fc / 6) % #self.frames
    yield()
   end
  end

  self.threads = {
   cocreate(self.anim)
  }

  return self
 end

 function candy(x, y, for_player)
  local self = {
   player = for_player,
   x = x, y = y,
   x_start = x, y_start = y,
   x_end = flr(rnd(15)),
   y_end = flr(rnd(15)),
   dx = 1 - flr(rnd(3)),
   dy = 1 - flr(rnd(3))
  }

  function self:draw()
   rectfill(self.x, self.y, self.x + 1, self.y + 1,9  + flr(rnd(2)))
  end

  function self:update()
   for i = 0, 15 do
    self.x = self.x_start + self.dx * outcubic(i, 0, self.x_end, 15)
    self.y = self.y_start + self.dy * outcubic(i, 0, self.y_end, 15)
    yield()
   end

   self.x_start = self.x
   self.y_start = self.y

   for i = 0, 20 do
    self.x_end = bbox(self.player).center_x
    self.y_end = bbox(self.player).center_y
    self.x = outcubic(i, self.x_start, self.x_end - self.x_start, 20)
    self.y = outcubic(i, self.y_start, self.y_end - self.y_start, 20)
    yield()
   end

   sfx(8)
   scene.score:add(1)
   del(scene.entities, self)
  end

  self.threads = {
   cocreate(self.update)
  }

  return self
 end

 function enemy(x, y)
  local self = {
   x = x, y = y,
   bbox = {
    x = 1, y = 1,
    w = 4, h = 6
   },
   speed = 0.25,
   frames = {92, 93},
   frame = 1,
   flip = false,
   target_x = 60,
   target_y = 68
  }

  function self:move()
   while true do
    local x = self.target_x
    local y = self.target_y
    local distance = sqrt((x - flr(self.x)) ^ 2 + (y - flr(self.y)) ^ 2)
    local step_x = self.speed * (x - self.x) / distance
    local step_y = self.speed * (y - self.y) / distance

    self.flip = step_x < 0

    local bumped = false
    local hit_kitty = false
    for i = 0, distance / self.speed do
     self.x += step_x
     bumped = bump(self)
     if (bumped) self.x -= step_x
     if (bumped and fget(bumped, 2)) hit_kitty = true break

     self.y += step_y
     bumped = bump(self)
     if (bumped) self.y -= step_y
     if (bumped and fget(bumped, 2)) hit_kitty = true break
     yield()
    end

    if hit_kitty then
     scene.enemy_controller:destroy(self)
     scene.score:hurt_kitty()
    end

    yield()
   end
  end

  function self:anim()
   local i = 1
   while true do
    self.frame = 1 + flr(i / 6) % #self.frames
    if (i % 12 == 0) sfx(2)
    i += 1
    yield()
   end
  end

  function self:draw()
   palt(0, false)
   palt(3, true)
   self.frame = min(self.frame, #self.frames)
   spr(self.frames[self.frame],
    self.x, self.y, 1, 1, self.flip)
   palt()
  end

  function self:destroy(by_player)
   add(entities, particle(self.x + 4, self.y + 4, "explosion"))
   sfx(4)

   if by_player then
    for i = 1, 10 do
     add(entities, candy(self.x + 4, self.y + 4, by_player))
    end
   end
  end

  self.threads = {
   cocreate(self.move),
   cocreate(self.anim)
  }

  return self
 end

 function bullet(x, y, dir_x, dir_y, by_player, from_turret)
  local self = {
   player = by_player,
   x = x, y = y,
   bbox = {
    x = 0, y = 4,
    w = 3, h = 3
   },
   dir_x = dx, dir_y = dy,
   dx = 0, dy = 0,
   sprite = 0,
   flip_x = false,
   flip_y = false,
   from_turret = from_turret or false,
   speed = 12
  }

  function self:draw()
   if self.from_turret then
    pal(12, 10)
    pal(13, 9)
   end
   spr(self.sprite, self.x, self.y, 1, 1,
    self.flip_x, self.flip_y)
   pal()
  end

  function self:update()
   while true do
    for i = 1, self.speed do
     self.x += self.dx
     self.y += self.dy

     if (bump(self)) del(scene.entities, self)

     local hits = scene.enemy_controller:enemies_at(bbox(self))

     for enemy in all(hits) do
      scene.enemy_controller:destroy(enemy, self.player)
      scene.score:add(1)
     end
    end

    yield()
   end
  end

  local dx = dir_x
  local dy = dir_y
  local s = 0
  local fx = false
  local fy = false

  self.x += 3 - rnd(6)
  self.y += 3 - rnd(6)

  if dir_x == -1 then
   s = 144
   if (dir_y == -1) dx = -0.7071 dy = -0.7071 s = 145
   if (dir_y == 1) dx = -0.7071 dy = 0.7071 s = 145 fy = true

  elseif dir_x == 1 then
   s = 144
   fx = true
   if (dir_y == -1) dx = 0.7071 dy = -0.7071 s = 145 fx = true
   if (dir_y == 1) dx = 0.7071 dy = 0.7071 s = 145 fx = true fy = true

  elseif dir_y == -1 then
   s = 146
   dy = -1

  elseif dir_y == 1 then
   s = 146
   fy = true
   dy = 1
  end

  self.dx = dx
  self.dy = dy
  self.sprite = s
  self.flip_x = fx
  self.flip_y = fy

  self.threads = {
   cocreate(self.update)
  }

  return self
 end

 function turret(x, y, by_player)
  local self = {
   x = x, y = y,
   bbox = {
    x = 0, y = 1,
    w = 8, h = 7
   },
   player = by_player,
   facing = "up",
   t_end = 300,
   t = 1
  }

  function self:draw()
   if self.t_end - self.t <= 60 and self.t % 2 == 0 then
    for i = 0, 15 do
     pal(i, 0)
    end
   end

   spr(132, self.x, self.y)
   if (self.facing == "up") spr(133, self.x, self.y - 2)
   if (self.facing == "down") spr(133, self.x, self.y + 2, 1, 1, true, true)
   if (self.facing == "left") spr(134, self.x - 2, self.y, 1, 1, true)
   if (self.facing == "right") spr(134, self.x + 2, self.y)

   pal()
  end

  function self:shoot()
   while true do
    if btn(k_x, self.player.keys) then
     local x = bbox(self).x1
     local y = bbox(self).y1
     local dx = 0
     local dy = 0
     local flip_x = false
     local flip_y = false
     local sprite = "gun_flame_lr"

     if btn(k_left, self.keys) or self.facing == "left" then
      x -= 8
      dx = -1
     elseif btn(k_right, self.keys) or self.facing == "right" then
      x += 4
      flip_x = true
      dx = 1
     elseif btn(k_up, self.keys) or self.facing == "up" then
      y -= 10
      dy = -1
      sprite = "gun_flame_ud"
      flip_y = true
     elseif btn(k_down, self.keys) or self.facing == "down" then
      y += 6
      dy = 1
      sprite = "gun_flame_ud"
     end

     add(scene.entities, particle(x, y,
      sprite, {flip_x = flip_x, flip_y = flip_y}))
     add(scene.entities, bullet(x, y, dx, dy, self.player, true))
     wait(2)
    end
    yield()
   end
  end

  function self:update()
   while true do
    if (self.t == self.t_end) del(scene.entities, self)
    self.facing = self.player.facing
    self.t += 1
    yield()
   end
  end

  sfx(10)

  self.threads = {
   cocreate(self.update),
   cocreate(self.shoot)
  }

  return self
 end

 function player(keys, char)
  local self = {
   keys = keys,
   char = char,
   x = 16, y = 16,
   w = 8, h = 16,
   bbox = {
    x = 2, y = 10,
    w = 4, h = 5
   },
   speed = 2,
   walk_speed = 2,
   walk_speed_shooting = 0.3,
   dash_speed = 6,
   dash_time = 12,
   dash_cooldown = 60,
   special_charge = 0,
   whacking = false,
   shooting = false,
   state = "standing",
   facing = "right",
   dx = 0, dy = 0,
   frames = {},
   frames_foxeh = {
    standing = {
     right = {65},
     left = {68},
     up = {74},
     down = {71}
    },
    walking = {
     right = {65, 64, 65, 66},
     left = {68, 67, 68, 69},
     up = {74, 73, 74, 75},
     down = {71, 70, 71, 72}
    },
    dashing = {
     right = {65},
     left = {68},
     up = {74},
     down = {71}
    }
   },
   frames_wolfie = {
    standing = {
     right = {97},
     left = {100},
     up = {106},
     down = {102}
    },
    walking = {
     right = {97, 96, 97, 98},
     left = {100, 99, 100, 101},
     up = {106, 105, 106, 107},
     down = {103, 102, 103, 104}
    }
   },
   frame = 1
  }

  function self:draw()
   self.frame = min(self.frame,
    #self.frames[self.state][self.facing])
   spr(self.frames[self.state][self.facing][self.frame],
    self.x, self.y, 1, 2)
  end

  function self:anim()
   local i = 1
   while true do
    self.frame = 1 + flr(i / 2) %
     #self.frames[self.state][self.facing]

    if self.state == "walking" then
     if i % flr(2 + rnd(4)) == 0 then
      add(scene.entities, particle(
       self.x + self.w / 2, self.y + self.h - 1, "dust"))
     end

     if (i % 4 == 0) sfx(0)
    end

    i += 1
    yield()
   end
  end

  function self:dash()
   while true do
    if btn(k_o, self.keys) and self.state == "walking" then
     self.state = "dashing"
     sfx(1)
     add(scene.entities, particle(
      bbox(self).x2,
      bbox(self).center_y, "dash_blink"))
     self.speed = self.dash_speed
     wait(self.dash_time)
     self.speed = self.walk_speed
     self.state = "standing"
     wait(self.dash_cooldown)
    end

    yield()
   end
  end

  function self:do_whack()
   self.whacking = true
   sfx(3)
   local x = self.x
   local y = self.y + 3
   local flip_x = false
   local flip_y = false
   local sprite = "whack_sprite_lr"
   local hitbox = {8, 16}

   if (self.facing == "left") x -= 3
   if (self.facing == "right") x += self.bbox.w flip_x = true
   if self.facing == "up" then
    x -= 4
    sprite = "whack_sprite_ud"
    hitbox = {16, 8}
   elseif self.facing == "down" then
    x -= 4
    y += self.bbox.h + 4
    flip_y = true
    sprite = "whack_sprite_ud"
   end

   add(scene.entities, particle(
    x, y, sprite, {flip_x = flip_x, flip_y = flip_y}))

   local hits = scene.enemy_controller:enemies_at({
    x1 = x, y1 = y,
    x2 = x + hitbox[1], y2 = y + hitbox[2]
   })

   for enemy in all(hits) do
    scene.enemy_controller:destroy(enemy, self)
    scene.score:add(1)
   end

   if #hits >= 3 or (#hits > 0 and self.state == "dashing") then
    camera(1, 0)
    wait(1)
    camera(-1, 0)
    wait(1)
    camera()
   end

   self.whacking = false
  end

  function self:whack()
   while true do
    if btn(k_x, self.keys) then
     if self.state == "dashing" then
      while self.state == "dashing" do
       self:do_whack()
       wait(1)
      end
     else
      self:do_whack()
      wait(6)
     end
    end
    yield()
   end
  end

  function self:shoot()
   while true do
    if btn(k_x, self.keys) then
     sfx(9)
     self.shooting = true

     local x = bbox(self).x1
     local y = bbox(self).y1
     local dx = 0
     local dy = 0
     local flip_x = false
     local flip_y = false
     local sprite = "gun_flame_lr"

     if (btn(k_left, self.keys) or self.facing == "left") x -= 8 dx = -1
     if (btn(k_right, self.keys) or self.facing == "right") x += 4 flip_x = true dx = 1
     if btn(k_up, self.keys) or self.facing == "up" then
      y -= 10
      dy = -1
      sprite = "gun_flame_ud"
      flip_y = true
     elseif btn(k_down, self.keys) or self.facing == "down" then
      y += 6
      dy = 1
      sprite = "gun_flame_ud"
     end

     add(scene.entities, particle(x, y,
      sprite, {flip_x = flip_x, flip_y = flip_y}))
     add(scene.entities, bullet(x, y, dx, dy, self))
     wait(2)
     self.shooting = false
    end
    yield()
   end
  end

  function self:drop_turret()
   while true do
    if btn(k_o, self.keys) then
     local turret = turret(self.x , self.y, self)
     add(scene.entities, turret)
     wait(turret.t_end)
    end
    yield()
   end
  end

  function self:walk()
   while true do
    local dx = 0
    local dy = 0
    local btn_left = btn(k_left, self.keys)
    local btn_right = btn(k_right, self.keys)
    local btn_up = btn(k_up, self.keys)
    local btn_down = btn(k_down, self.keys)

    if btn_left then
     self.facing = "left"
     dx = -1
     if (btn_up) dx = -0.7071 dy = -0.7071
     if (btn_down) dx = -0.7071 dy = 0.7071

    elseif btn_right then
     self.facing = "right"
     dx = 1
     if (btn_up) dx = 0.7071 dy = -0.7071
     if (btn_down) dx = 0.7071 dy = 0.7071

    elseif btn_up then
     self.facing = "up"
     dy = -1

    elseif btn_down then
     self.facing = "down"
     dy = 1
    end

    self.dx = dx
    self.dy = dy
    yield()
   end

  end

  function self:move()
   while true do
    if self.dx != 0 or self.dy != 0 then
     if (self.state != "dashing") self.state = "walking"
    else
     if (self.state != "dashing") self.state = "standing"
    end

    for i = 1, self.speed * (self.shooting and self.walk_speed_shooting or 1) do
     self.x += self.dx
     if (bump(self)) self.x -= self.dx

     self.y += self.dy
     if (bump(self)) self.y -= self.dy
    end

    yield()
   end
  end

  self.frames = self["frames_"..self.char]
  self.key_o = self.char == "foxeh" and self.dash or self.drop_turret
  self.key_x = self.char == "foxeh" and self.whack or self.shoot

  self.threads = {
   cocreate(self.walk),
   cocreate(self.key_o),
   cocreate(self.key_x),
   cocreate(self.move),
   cocreate(self.anim)
  }

  return self
 end

 function enemy_controller()
  local self = {
   spawn_points = {},
   enemies = {},
   wave = 0,
   countdown = 0
  }

  function self:draw()
   print("wave: "..self.wave.." ("..self.countdown..")", 48, 1)
  end

  function self:update()
   while true do
    if self.countdown == 0 then
     self.wave += 1
     self.countdown = self.wave * 10

     add(scene.entities, particle(
      0, 32, "wave_splash", {wave = self.wave}))
     wait(60)

     local delay = 200 / self.countdown
     for i = 1, self.countdown do
      local spawn = self.spawn_points[1 + flr(rnd(#self.spawn_points))]
      local enemy = enemy(spawn[1], spawn[2])
      add(entities, enemy)
      add(self.enemies, enemy)
      wait(delay)
     end
    end

    yield()
   end
  end

  function self:destroy(enemy, by_player)
   enemy:destroy(by_player)
   del(entities, enemy)
   del(self.enemies, enemy)
   self.countdown -= 1
  end

  function self:enemies_at(target_bbox)
   local hits = {}
   for enemy in all(self.enemies) do
    if collide(bbox(enemy), target_bbox) then
     add(hits, enemy)
    end
   end
   return hits
  end

  for x = 0, 15 do
   for y = 0, 15 do
    if (fget(mget(x, y), 1)) add(self.spawn_points, {x * 8, y * 8})
   end
  end

  self.threads = {
   cocreate(self.update)
  }

  return self
 end

 function score()
  local self = {
   score = 0,
   kitty_hp = 3
  }

  function self:add(points)
   self.score += points
  end

  function self:hurt_kitty()
   self.kitty_hp -= 1
  end

  function self:draw()
   print("score: "..self.score, 2, 1, 9)

   for i = 1, self.kitty_hp do
    spr(41, 92 + i * 8, 0)
   end
  end

  function self:update()
   while true do
    if self.kitty_hp <= 0 then
     for i = 1, 15 do
      fade_scr_val = i / 15
      wait(1)
     end
     fade_scr_val = 0
     add_scene(game_over_scene({
      score = self.score,
      wave = scene.enemy_controller.wave}))
    end
    yield()
   end
  end

  self.threads = {
   cocreate(self.update)
  }

  return self
 end

 scene.score = score()
 scene.enemy_controller = enemy_controller()

 add(scene.entities, bg())
 add(scene.entities, scene.score)
 add(scene.entities, scene.enemy_controller)
 add(scene.entities, kitty())

 scene.players = {}
 for keys, character in pairs(init.players) do
  local player = player(keys - 1, character)
  add(scene.players, player)
  add(scene.entities, player)
 end

 return scene
end

function game_over_scene(init)
 local scene = {entities = {}}
 merge(scene, init)

 function score_display()
  local self = {threads = {}}

  function self:draw()
   print("game over!\n\nwave: "..scene.wave..
    "\nscore: "..scene.score, 44, 48, 9)
  end

  return self
 end

 add(scene.entities, score_display())

 return scene
end

function _init()
 add_scene(title_scene({}))
end

function _update()
 fc = max(0, fc + 1)

 if (fade_scr_val > 0 and fc % 2 == 0) return

 for entity in all(entities) do
  for thread in all(entity.threads) do
   coresume(thread, entity)
  end
 end
end

function _draw()
 color() cls() pal() palt()
 for _, entity in pairs(entities) do
  if (entity.draw) entity:draw()
 end
 fade_scr(fade_scr_val)
end
__gfx__
000000008e018e009a019a0001010100006666666666666666666600ccccccc777c777ccccccccccccccccc777c777cccccccccc000000000000000000000000
00000000e0088008a00990091000000006dddddddddddddddddddd60ccccccc757c7577cccccccccccccccc757c7577ccccccccc000000000000000000000000
000000000088008800990099000000006dd111111111111111111dd0ccccc777057755777cccccccccccc777057755777ccccccc000000000000000000000000
000000001880088019900990100000006d1111111111111111111150cccc77580057505877cccccccccc77580057505877cccccc000000000000000000000000
000000008800880099009900000000006d1111666666666666111150cccc75008000008057cccccccccc75008000008057cccccc000000000000000000000000
00000000e0088008a0099009100000006d1116dddddddddddd611150cccc75075000000007cccccccccc75075000000007cccccc000000000000000000000000
000000000088008800990099000000006d116dd1111111111dd01150cccc770750effe0707cccccccccc770750effe0707cccccc000000000000000000000000
000000000880088009900990000000006d116d111111111111501150ccccc7775f8ff80777ccccccccccc7775f8ff80777cccccc000000000000000000000000
000000000e010e0000000000000000006d116d111111111111501150ccccccc770ffff77ccccccccccccccc770ffff77cccccccc000000000000000000000000
00000000e000800000000000000000006d116d111111111111501150ccccccc744000f7cccccccccccccccc7440f057ccccccccc000000000000000000000000
000000000008000800000000000000006d116d111111111111501150cccccc77440f0577cccccccccccccc7744000f77cccccccc000000000000000000000000
000000001080008000000000000000006d116d111111111111501150cccccc7054f4f057cccccccccccccc7054f4f057cccccccc000000000000000000000000
000000000800080000000000000000006d116d111111111111501150cccccc7705555577cccccccccccccc7705555577cccccccc000000000000000000000000
00000000e000800000000000000000006d116d111111111111501150ccccccc77705777cccccccccccccccc77705777ccccccccc000000000000000000000000
000000000008000800000000000000006d116d111111111111501150ccccccccc7057cccccccccccccccccccc7057ccccccccccc000000000000000000000000
000000000080008099999999000000006d116d111111111111501150ccccccccc7777cccccccccccccccccccc7777ccccccccccc000000000000000000000000
dddddddd0000000000000000000000006d116d111111111111501150ccccccc7777777cc06000600000000000000000000000000000000000000000000000000
cccccccc0000000000000000000000006d1105111111111115501150cccccccbbbbbb77c0e606e00000000000000000000000000000000000000000000000000
777777770000000000000000000000006d1110555555555555011150ccccccb333333b770e666e00000000000000000000000000000000000000000000000000
777777770000000000000000000000006d1111000000000000111150cccccb3b355555b756e6e650000000000000000000000000000000000000000000000000
777777770000000000000000000000006d1111111111111111111150cccccb33b339335756868650000000000000000000000000000000000000000000000000
777777770000000000000000000000000d5111111111111111111550cccccb335339335705626500000000000000000000000000000000000000000000000000
77777777000000000000000000000000005555555555555555555500cccccb335390935700555000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000cccccb330390930700000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000cccccb335999995700000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000ccccb3330990990700000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000cccb33335333335700000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000cccb93930939390700000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000cccb39390393930700000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000cccb93930939390700000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000ccc755005000007700000000000000000000000000000000000000000000000000000000
dddddddd000000000000000000000000000000000000000000000000ccc777777777777c00000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c000000c00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c77c0000c7c000000c000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c77777c0c777c0000ccc00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c77777c000c7c000000c000000000000
40004000000000004000400000040004000000000004000440000004000000004000000440000004000000004000000400c77c00000c00000000000000000000
540044004000400054004400004400450004000400440045540000454000000454000045440000444000000444000044000c7000000000000000000000000000
5544440054004400554444000044445500440045004444555540045554000045554004554550055444000044455005540000c000000000000000000000000000
54444440554444005444444004444445004444550444444554444445554444555444444554444445455445545444444583333333e33333330000000000000000
44eff6405444444044eff64004eff6440444444504eff64444eff6445444444544eff64444444444544444454444444457777633577776330000000000000000
4f2ff54044eff6404f2ff540042ff5f404eff644042ff5f44f2ff5f444eff6444f2ff5f444444444444444444444444470060063700600630000000000000000
44ffff004f2ff54044ffff0000ffff44042ff5f400ffff4444ffff444f2ff5f444ffff440444444044444444044444406686686366e66e630000000000000000
0feeef0044ffff000feeef0000feeef000ffff4400feeef00feeeef044ffff440feeeef00f4444f0044444400f4444f036666633366666330000000000000000
9422f00000eee00044f22000000f2249000eee0000022f4400222f4400eeee0044f2220044442200004444000022444433555633336553330000000000000000
44f000000f222f009440f00000000f4400f222f0000f044900f044490f2222f094440f0094440f000f2442f000f0444933655333335556330000000000000000
0000000094f4f0000000000000000000000f4f49000000000000000000f44f90000000000440000000f99f000000000036333633336363330000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000ccccc006000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c776676c0000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000006700007c007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060c00000000000000000000000000700
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c700000000000000000000000000000
70007000000000007000700000070007000000000007000770000007000000007000000770000007000000007000000706000000060000000000000000000000
e700770070007000e70077000077007e000700070077007ee700007e70000007e700007e770000777000000777000077c7000000000000000000000000000000
ee777700e7007700ee777700007777ee0077007e007777eeee7777eee700007eee7777ee766776677700007776677667c6000000700000000000000000000000
77777770ee7777007777777007777777007777ee0777777777777777ee7777ee77777777677777767667766767777776c6000000060000000700cc7070000000
77effe707777777077effe7007effe770777777707effe7777effe777777777777effe77777777776777777677777777c77000007600000000cc776600600000
7f8ff87077effe707f8ff870078ff8f707effe77078ff8f77f8ff8f777effe777f8ff8f7777777777777777777777777c7600000c70000000c76600000000000
77ffff707f8ff87077ffff7007ffff77078ff8f707ffff7777ffff777f8ff8f777ffff777777777777777777777777770c000000c7606000c770000000000000
7fcccf0077ffff707fcccf0000fcccf707ffff7700fcccf77fccccf777ffff777fccccf7077777707777777707777770000000000c600000c760600000000000
06ddf00077ccc70006fdd000000fdd60007ccc77000ddf6007dddf7077cccc7707fddd7000d67d000777777000d76d00000000000c7760007600000000000000
66f000006fdddf006660f00000000f6600fdddf0000f066600f066600fddddf006660f0006660f000fd75df000f066600000000070c776006000000000000000
7600000076f0f0007600000000000067000f0f67000000670000066700f55f60766000007660000000f66f000000066700000000000cc7600000000000000000
00c6c0000c6dc00000070c0000c00060000000000a900a9000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c777c006d76dc00000cd6c000000cdc077777700a900a900cccccaa000000000000000000000000000000000000000000000000000000000000000000000000
c6776dc00c7760006d77777c00667776776666550cd00cd007dddd90000000000000000000000000000000000000000000000000000000000000000000000000
0d77d0000076d00000d77776000c676d766666650cd00cd077650000000000000000000000000000000000000000000000000000000000000000000000000000
7c77c0c0006c0d00070cd67c0000d6dc766666650cd77cd07cccccaa000000000000000000000000000000000000000000000000000000000000000000000000
007d0000c060000000000dc0060d00c0766666650cc76cc005dddd90000000000000000000000000000000000000000000000000000000000000000000000000
00d0700000000600000c0c0000000000556666550076550000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000000000000000000000000055555500005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d7d0000000cdc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c77c000000d7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cdcdd700d77d0000077c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cd777777000c7d0000c7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cd7c000000007000007d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccdd00dd0000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000d00dd00d00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000088800888000c00000000000000000dd00dd00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000088820888200c0000000000000000dd00dd000000000
088888888000008888888808888888888009990000999000009999999900099999999009990000999900888228882200c000000000000000dd00dd0000000000
888888888200088888888828888888888209994000999400099999999940999999999409994009994440888208882000c000000000000000d00dd00d00000000
882222222200888222288820222888222209994000999400999444499940994444444409994099944000888208882000c00000000000000000dd00dd00000000
882000000000888200088820000888200009994000999400999400099940994000000009994999440000888208882000c0000000000000000dd00dd000000000
882000000000882200088820000888200009999999999400994400099940994000000009999994400000888208882000c0000000000000000000000000000000
882000000000888888888820000888200009994444999400999999999940994000000009994999000000882208822000c0000000000000000000000000000000
882000000000888888888820000888200009994000999400999999999940994000000009994099900000022000220000c0000000000000000000000000000000
888888888000882222288820000888200009994000999400994444499940999999999009994009990008880088800000c0000000000000000000000000000000
088888888200882000088820000888200009994000999400994000099940099999999409994000999908882088820000c0000000000000000000000000000000
002222222200022000002220000022200000444000044400044000004440004444444400444000044440222002220000c0000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000
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
0005000001010100000000000000000000020000010101000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2525252525261111242525252611111400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1103030303030303030303030303031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1103030303030303030303030303031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0603030303030303030303030303031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1603030303030303030303030303032400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1603030303030303030303030303031100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1603030303030202020203030303031100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2603030303030201010203030303030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1103030303030202020203030303031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1103030303030303030303030303031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0603030303030303030303030303031400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1603030303030303030303030303032400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1603030303030303030303030303031100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1603030303030303030303030303031100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1611110405050506111104050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00030000167400f700127000f700127000d7000d7000f7000e7001070011700137000c7000c7000c7000e7001070011700137000d7000f700187001a7001c7000e7000e700107000e70000700007000070000700
000200000561009630116501b66027670336703c67037670316602c6502864025640216301d6301763014620126200e6100c6100a610096100761005610046100361002610016100161000610006000060000600
000100001c02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000004670176302b6403d6702a6003e6000b60005600026000160001600026000160001600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200001a430204602a470384701967039650296502f66028640146102f64023660186600a67015650126400a6300f6200d630056500b6600a64009620056100762006630066200561002610046000460001000
000200000c630106301b6302a640326503d66037670306602c66028650226401f6401c64019640176301663013630106200e6200c6200b6200a6200a6200a6200962008620086200861008610086100961009610
000400002c57000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400001547009470194700e4701e47014470224701b47028470224702e470294703247030460364503644036420364102600015400154000c4000c400324001e4001e400244002540037400274003e4001e400
000200002a540325603f5703f5603f5403f5203f51000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200000b650377700b6702c360253501c3400a62005510007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000500000b570127700d7700475004730047100070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c4000e400104000f4000d4000f4000f400104000e4000c4000e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
