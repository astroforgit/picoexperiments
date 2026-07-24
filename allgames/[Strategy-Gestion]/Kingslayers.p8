pico-8 cartridge // http://www.pico-8.com
version 1
__lua__
-- kingslayers
-- by justin jaffray
function animation(args)
  local a = {
    frames = args.frames,
    delay = args.delay,
    curframe = 0
  }
  function a:tick()
    self.curframe += 1
    if self.curframe >= #a.frames * a.delay then self.curframe = 0 end
  end
  function a:curval()
    return self.frames[flr(self.curframe / self.delay) + 1]
  end
  function a:restart()
    self.curframe = 0
  end
  return a
end

function vec(x, y)
  return {x = x, y = y}
end

mapx = 0
mapy = 0

k_l = 0
k_d = 3
k_r = 1
k_u = 2

k_a = 4
k_b = 5

function queue_new()
  return {}
  -- return { f = nil, b = nil }
end

function queue_push(q, e)
  local new = { p = nil, v = e }
  if q.f then
    q.f.p = new
  end
  q.f = new
  if not q.b then
    q.b = new
  end
end

function queue_pop(q)
  if not q.b then return nil end
  local b = q.b
  local v = b.v
  q.b = q.b.p
  if q.f == b then q.f = nil end
  return v
end

function queue_is_empty(q)
  return not q.b
end

cardinal_dirs = {
  vec(1, 0),
  vec(-1, 0),
  vec(0, 1),
  vec(0, -1)
  }

function grid_dists(x, y, context)
  local result = {}
  for x = context.bounds.x[1] - 1, context.bounds.x[2] do
    result[x] = {}
    for y = context.bounds.y[1] - 1, context.bounds.y[2] do
      result[x][y] = 1000
    end
  end
  local q = queue_new()
  queue_push(q, {x = x, y = y, d = 0})
  while not queue_is_empty(q) do
    local next = queue_pop(q)
    local x = next.x
    local y = next.y
    local d = next.d
    if not result[x][y] or result[x][y] > d then
      result[x][y] = d
      for dir in all(cardinal_dirs) do
        local xx = x + dir.x
        local yy = y + dir.y
        if xx >= context.bounds.x[1] and xx < context.bounds.x[2] then
          if yy >= context.bounds.y[1] and yy < context.bounds.y[2] then
            if not context:solid_at(xx, yy) then
              queue_push(q, {x = xx, y = yy, d = d + 1})
            end
          end
        end
      end
    end
  end
  return result
end

function mk_action(text, action)
return { text = text, action = action }
end

function recalculate_path(path, context, maxdist)
  local s = path[1]
  -- local e = vec(context.manager.curs.x/8,context.manager.curs.y/8)-- path[#path]
  local e = path[#path]
  local p = {s}
  local dists = grid_dists(e.x, e.y, context)
  -- debugtxt = dists[s.x][s.y]
  -- if dists[s.x][s.y] > maxdist then return {} end
  --while p[#p].x ~= e.x or p[#p].y ~= e.y do
  while #p <= maxdist do
    local curdist = dists[p[#p].x][p[#p].y]
    local possible_dirs = {}
    for d in all(cardinal_dirs) do
      local newdist = dists[p[#p].x + d.x][p[#p].y + d.y]
      if newdist and newdist < curdist then
        add(possible_dirs, d)
      end
    end
    local dir
    for d in all(possible_dirs) do
      if path_has_pt(path, vec(p[#p].x + d.x, p[#p].y + d.y)) then
        dir = d
      end
    end
    if not dir then
      dir = possible_dirs[flr(rnd() * #possible_dirs) + 1]
    end
    if not dir then
      break
    end
    add(p, {
      x = p[#p].x + dir.x,
      y = p[#p].y + dir.y
    })
  end
  return p
end

function path_has_overlap(path)
  visited_pts = {}
  for p in all(path) do
    if not visited_pts[p.x] then
      visited_pts[p.x] = {}
    end
    if visited_pts[p.x][p.y] then
      return true
    end
    visited_pts[p.x][p.y] = true
  end
  return false
end

function path_has_pt(path, pt)
  for p in all(path) do
    if p.x == pt.x and p.y == pt.y then return true end
  end
  return false
end

function move_unit(which, path, manager)
  local m = {
    curpoint = 1,
    dleft = 1,
    done = false
  }
  function m:active_update(context)
    if self.done then return end
    local last = min(which.range + 1, #path)
    if self.curpoint >= last then
      which.x = path[last].x
      which.y = path[last].y
      manager:popstate()
      local beginposn = path[1]
      if manager.context.current_turn == 0 then
        manager:pushstate(make_menu(which:options(),
        function()
          which.x = beginposn.x
          which.y = beginposn.y 
          manager.curs.x = beginposn.x * 8
          manager.curs.y = beginposn.y * 8
        end, manager))
      end
      m.done = true
      which:endmovement()
    else
      which:animtick()
      which.x = path[self.curpoint].x * self.dleft + path[self.curpoint + 1].x * (1 - self.dleft)
      which.y = path[self.curpoint].y * self.dleft + path[self.curpoint + 1].y * (1 - self.dleft)
      self.dleft -= 0.2
      if self.dleft < 0 then
        if self.curpoint % 2 == 1 then
          sfx(3)
        end
        self.dleft += 1
        self.curpoint += 1
      end
    end
  end
  return m
end

-- ai

function sample(s)
  local n = {}
  for i in all(s) do
    add(n, i)
  end
  return n[1 + flr(rnd() * #n)]
end

function make_ai_attack(unit, turn, mgr)
  local m = {}
  local ctx = mgr.context
  local spots = unit:attackable_spots()
  local candidates = {}
  for s in all(spots) do
    local c = ctx:unit_at(s.x, s.y)
    if c and c.team ~= unit.team then
      add(candidates, s)
    end
  end
  function m:done()
    mgr:popstate()
  end
  local target = sample(candidates)
  function m:control_render()
  end
  local t = 0
  function m:active_update()
    if t == 0 then
      if target then
        mgr:pushstate(make_attack_pos(unit, target, mgr.context, mgr, m.done, unit.power))
      else
        m:done()
      end
      t = 1
    end
  end
  return m
end


local path_delay = 4

function make_ai_move_unit(unit, turn, mgr)
  local m = {}
  local t = 0
  local dists = grid_dists(unit.x, unit.y, mgr.context)
  local path_tick = 0
  local alive_enemies = {}
  for enem in all(turn.enemy_units) do
    if enem:alive() then
    add(alive_enemies, enem)
    end
  end
  local choices = {}
  local dist = 1000
  for e in all(alive_enemies) do
    for d in all(cardinal_dirs) do
      local xx = e.x + d.x
      local yy = e.y + d.y
      local u = mgr.context:unit_at(xx, yy)
      if not mgr.context:solid_at(xx, yy) and (not u or u == unit) then
        if dists[xx][yy] <= unit.range then
          add(choices, vec(xx,yy))
        end
      end
    end
  end
  local target
  while not target and #choices > 0 do
    local c = sample(choices)
    if not mgr.context:unit_at(c.x, c.y) then
      target = c
    end
    del(choices, c)
  end
  if not target then
    local u = sample(alive_enemies)
    target = vec(u.x, u.y)
  end

  local target_dists = grid_dists(target.x, target.y, mgr.context)
  local curdist = target_dists[unit.x][unit.y]
  local cx = unit.x
  local cy = unit.y
  local path = {vec(cx, cy)}
  -- token reduction candidate
  for i = 1, unit.range do
    if target_dists[cx][cy] == 0 then
      break
    end
    for d in all(cardinal_dirs) do
      if target_dists[cx + d.x][cy + d.y] < curdist then
        cx += d.x
        cy += d.y
        break
      end
    end
    add(path, vec(cx, cy))
    curdist -= 1
  end
  while #path > 1 and mgr.context:unit_at(path[#path].x, path[#path].y) do
    path[#path] = nil
    for d in all(cardinal_dirs) do
      local p = path[#path]
      local pp = path[#path - 1]
      local xx = p.x + d.x
      local yy = p.y + d.y
      if pp and (pp.x ~= xx or pp.y ~= yy) then
        if not mgr.context:solid_at(xx, yy) and not mgr.context:unit_at(xx,yy) then
          path[#path + 1] = vec(xx, yy)
        end
      end
    end
  end
  local moves = 1
  function m:active_update()
    if t == 0 then
      mgr.curs.x = unit.x * 8
      mgr.curs.y = unit.y * 8
      t = 1
    elseif t < 10 then
      t += 1
    elseif t == 11 then
      mgr.context.curunit = unit
      t = 12
    elseif t <= 20 then
      t += 1
    elseif t == 21 then
      if moves <= min(#path, unit.range + 1) then
        if path_tick >= path_delay then
          sfx(4)
          path_tick = 0
          mgr.curs.x = path[moves].x * 8
          mgr.curs.y = path[moves].y * 8
          mgr.curs:update_path(mgr.context)
          moves += 1
        else
          path_tick += 1
        end
      else
        t += 1
      end
    elseif t < 30 then
      t += 1
    elseif t == 30 then
      mgr:pushstate(move_unit(unit, path, mgr))
      mgr.context.curunit = nil
      t += 1
    elseif t == 31 then
      mgr:popstate()
    end
  end
  function m:control_render()
  end
  return m
end

function make_ai_turn(mgr)
  local a = {}
  local ctx = mgr.context
  local my_team = ctx.current_turn
  local done = false
  local curstate = 0 -- whether we're issuing a move command or action command
  a.my_units = {}
  a.enemy_units = {}
  for u in all(ctx.units) do
    if u:alive() and ctx.current_turn == u.team then
      add(a.my_units, u)
    else
      add(a.enemy_units, u)
    end
  end
  function a:active_update()
    local u = a.my_units[#a.my_units]
    if #a.my_units > 0 then
      if curstate == 0 then
        mgr:pushstate(make_ai_move_unit(u, a, mgr))
        curstate = 1
      elseif curstate == 1 then
        mgr:pushstate(make_ai_attack(u, a, mgr))
        -- stupid fleetfoot
        if not (kill_happened and u.type.abilities and u.type.abilities.fleetfoot) then
          u.active = false
          a.my_units[#a.my_units] = nil
        end
        kill_happened = false
        curstate = 0
      end
    elseif not done then
      done = true
      mgr:popstate()
      next_turn(ctx)
    end
  end
  function a:control_render()
  end
  return a 
end

function make_heal_pos(pos, ctx, cb)
  local h = {}
  local done = false
  local t = 0
  function h:active_update(ctx)
    if not done then
      local u = ctx:unit_at(pos.x, pos.y)
      if u then
        u.hp += 3
      end
      done = true
    end
    t += 1
    if t >= 30 then
      ctx.manager:popstate()
      cb()
    end
  end
  return h
end
function mktype(frames, range, hp, power, desc, abil, shootpow)
  return {
  frames = frames,
  range = range,
  hp = hp,
  power = power,
  desc =desc,
  abilities = (abil or {}),
  shoot_power = shootpow
  }
end

units = {
o = mktype({16,17}, 5, 10, 4, "orc - strong, slow"),
k = mktype({70, 71}, 3, 15, 4, "idk how ur seeing this"),
g = mktype({32, 33}, 7, 9, 3, "goblin - can act again on kill", { fleetfoot = true }),
t = mktype({38, 39}, 4, 20, 1, "tank - can take a beating"),
s = mktype({34, 35}, 7, 4, 2, "how are you seeing this?"),
h = mktype({36, 37}, 3, 7, 1, "healer - can heal other units", { heal = true }),
a = mktype({40, 41}, 4, 8, 1, "archer - can shoot at a distance", { shoot = true }, 4),
b = mktype({74, 75}, 6, 6, 1, "grenadier - lobs law bombs", { bomb = true })
}

function make_context(manager)
  -- ew, sorry everyone
  kill_happened = false
  local c = {
    mission = next_mission,
    bounds = vec({0, 16}, {0, 16}),
    current_turn = 0,
    teams = {0, 1},
    team_names = {"player", "enemy"},
    manager = manager
  }
  mapx = c.mission.x

  c.units = {}
  local i = 1
  local enemies = c.mission:get_enemies()
  local starts = select(#enemies, c.mission.estarts)
  for t in all(enemies) do
    add(c.units, make_unit({
      x = starts[i][1],
      y = starts[i][2],
      manager = manager,
      type = t,
      team = 1
    }))
    i += 1
  end

  i = 1
  starts = select(#player_team, c.mission.pstarts)
  for t in all(player_team) do
    add(c.units, make_unit({
      x = starts[i][1],
      y = starts[i][2],
      manager = manager,
      type = t,
      team = 0
    }))
    i += 1
  end

  function c:advance_turn()
    self.current_turn += 1
    if self.current_turn >= #self.teams then
      self.current_turn = 0
    end
    manager:pushstate(make_next_turn(self.team_names[self.current_turn + 1], manager))
  end

  function c:solid_at(x, y)
    local u = c:unit_at(x, y)
    return is_solid(mget(mapx + x, mapy + y)) or (u and u.team ~= c.current_turn)
  end

  function c:current_unit()
    return c.curunit
  end

  function c:unit_at(x, y)
    for u in all(self.units) do
      if u.x == x and u.y == y and u:alive() then
        return u
      end 
    end
    return nil
  end
  
  function c:select_at(x, y)
    if not c.curunit then
      c.curunit = c:unit_at(x, y)
      if c.curunit then
        if not c.curunit.active or c.curunit.team != c.current_turn then
          c.curunit = nil
        end
      end
      if not c.curunit then
        c.manager:pushstate(make_menu({
          {text = "end turn", action = function()
            next_turn(c)
          end }
        },
        function() end,
        c.manager))
      end
    else
      local u = c:unit_at(x, y)
      if not u or u == c.curunit then
        c.manager:pushstate(move_unit(c.curunit, path, c.manager))
        c.curunit = nil
      end
    end
  end

  function c:update()
    c.mission:update(c)
  end

  function c:render()
    for u in all(self.units) do
      if not u:alive() then
        u:render()
      end
    end
    for u in all(self.units) do
      if u:alive() then
        u:render()
      end
    end
    for u in all(self.units) do
      if u:alive() then
        u:draw_hp_bar()
      end
    end
  end
  return c
end

function next_turn(context)
  for u in all(context.units) do
    u.active = true
    if not u:alive() then u.active = false end
  end
  context:advance_turn()
end

function is_solid(t)
  return fget(t, 0)
end

-- token reduction candidate - if super desperate can change the bounds to be property accesses, maybe
function in_bounds(x, y, ctx)
  return x >= ctx.bounds.x[1] and x < ctx.bounds.x[2] and y >= ctx.bounds.y[1] and y < ctx.bounds.y[2]
end

-- cursor
function make_cursor()
  local curs = {
    x = 48,
    y = 48,
    anim = animation({
      frames = {0, 1},
      delay = 5
    })
  }
  path = {vec(curs.x / 8, curs.y / 8)}
  current_unit = nil
  function curs:update(context)
    if current_unit ~= context:current_unit() then
      current_unit = context:current_unit()
      if current_unit then
        self.x = current_unit.x * 8
        self.y = current_unit.y * 8
        path = {vec(self.x / 8, self.y / 8)}
      else
        path = {}
      end
    end
    if not current_unit then
      path = {}
    end
    self.anim:tick()
  end

  function curs:try_move(context, xx, yy)
    self.moved = true
    local x = self.x / 8 + xx
    local y = self.y / 8 + yy

    local is_solid = false --context:solid_at(x, y)
    if not is_solid and in_bounds(x, y, context) then
      if context.curunit then sfx(4) else sfx(7) end
      self.x = x * 8
      self.y = y * 8
    end
  end

  wasonsolid = false

  function curs:active_update(context)
    local px = self.x
    local py = self.y
    self.moved = false
    if context:solid_at(px/8, py/8) then
      wasonsolid = true
    end
    if not gameover then
      if btnp(k_l) then
        self:try_move(context, -1, 0)
      elseif btnp(k_r) then
        self:try_move(context, 1, 0)
      elseif btnp(k_u) then
        self:try_move(context, 0, -1)
      elseif btnp(k_d) then
        self:try_move(context, 0, 1)
      elseif btnp(k_a) then
        sfx(2)
        context:select_at(self.x / 8, self.y / 8)
      elseif btnp(k_b) then
        context.curunit = nil
      end
    end
    if self.moved and context.curunit then
      if px ~= self.x or py ~= self.y or wasonsolid then
        self:update_path(context)
        if wasonsolid then
          path = recalculate_path(path, context, context.curunit.range)
        end
      end
    end
    wasonsolid = false
  end

  function curs:update_path(context)
    local maxdist = context.curunit.range
    local newpt = vec(self.x / 8, self.y / 8)
    if not context:solid_at(newpt.x, newpt.y) then
      add(path, newpt)
    end
    if #path > maxdist or path_has_overlap(path) or path[#path] and abs(newpt.x - path[#path].x) + abs(newpt.y - path[#path].y) ~= 1 then
      path = recalculate_path(path, context, maxdist)
    end
  end

  function curs:control_render(context)
    if context.curunit then
      draw_path(path, context.curunit.range)
    end
  end

  function curs:render()
  draw_cursor(self.x, self.y, self.anim:curval())
  end

  return curs
end

function draw_cursor(x, y, t)
    if btn(k_a) then t = 2 end
    spr(1, x - 3 + t, y - 3 + t)
    spr(1, x + 3 - t, y - 3 + t, 1, 1, true)
    spr(1, x + 3 - t, y + 3 - t, 1, 1, true, true)
    spr(1, x - 3 + t, y + 3 - t, 1, 1, false, true)
end

function make_banner(words, mgr, cb)
  local m = {
  }

  local x = 128
  local t = 0
  local y = 56
  local words_w = #words * 4
  local w = flr(#words / 2) + 1
  local width = (2 + w) * 8
  function m:draw_scroll(x, y)
    spr(6, x, y, 1, 2)
    for i = 1, w do
      spr(7, x + i * 8, y, 1, 2)
    end
    spr(8, x + 8 + w * 8, y, 1, 2)
  end
  function m:control_render()
    set_whole_palette(4)
    m:draw_scroll(x + 2, y + 2)
    reset_palette()
    m:draw_scroll(x, y)
    print(words, x + width / 2 - words_w / 2, y + 5, 0)
  end
  function m:active_update()
    t += 1
    x -= (t - 32)^2 / 100
    if x < -width then
      mgr:popstate()
      cb()
    end
  end
  return m
end

function make_next_turn(team_name, mgr)
  return make_banner(team_name.." turn", mgr, function()
    if mgr.context.current_turn == 1 then
      mgr:pushstate(make_ai_turn(mgr))
    end
  end)
end

function make_arrow_spr(s, h, v)
  return { s = s, h = h, v = v }
end
arrow_sprs = {}
arrow_sprs[0] = {}
arrow_sprs[0][0.25] = make_arrow_spr(3, false, true)
arrow_sprs[0][0.5] = make_arrow_spr(20, false, false)
arrow_sprs[0][0.75] = make_arrow_spr(3, false, false)
arrow_sprs[0.25] = {}
arrow_sprs[0.25][0.5] = make_arrow_spr(3, true, true)
arrow_sprs[0.25][0.75] = make_arrow_spr(19, false, false)
arrow_sprs[0.5] = {}
arrow_sprs[0.5][0.75] = make_arrow_spr(3, true, false)

head_sprs = {}
head_sprs[0] = make_arrow_spr(4, false, false)
head_sprs[0.25] = make_arrow_spr(5, false, false)
head_sprs[0.5] = make_arrow_spr(4, true, false)
head_sprs[0.75] = make_arrow_spr(5, false, true)

function draw_path(pts, maxdist)
  local last = min(maxdist + 1, #pts)
  for i = 2, last - 1 do
    local x = pts[i].x
    local y = pts[i].y
    local prev = atan2(pts[i - 1].x - x, pts[i - 1].y - y)
    local next = atan2(pts[i + 1].x - x, pts[i + 1].y - y)
    local a = min(prev, next)
    local b = max(prev, next)
    if not arrow_sprs[a] then return end
    local s = arrow_sprs[a][b]
    if not s then return end
    spr(s.s, x * 8, y * 8, 1, 1, s.h, s.v)
    spr(s.s, x * 8, y * 8 - 1, 1, 1, s.h, s.v)
  end
  if last >= 2 then
    local p = pts[last]
    local s = head_sprs[atan2(p.x - pts[last - 1].x, p.y - pts[last - 1].y)]
    spr(s.s, p.x * 8, p.y * 8, 1, 1, s.h, s.v)
    spr(s.s, p.x * 8, p.y * 8 - 1, 1, 1, s.h, s.v)
  end
end

function make_unit(args)
  local x = args.x
  local y = args.y
  local mgr = args.manager
  local type = args.type
  local team = args.team
  local u = {
    x = x, y = y,
    anim = animation({frames = type.frames, delay = 10}),
    hp = type.hp, visible_hp = type.hp, max_hp = type.hp,
    active = true, team = team,
    range = type.range,
    power = type.power,
    type = type
  }
  local recoil = 0
  local hitdir = vec(1, 0)
  local hitcb = nil
  local died = false

  local vis_hp_tick = 0

  function u:animtick()
    self.anim:tick()
  end

  function u:endmovement()
    self.anim:restart()
  end

  function u:play_hit_anim(dir, dmg, cb)
    sfx(5)
    hitdir = dir
    recoil = 0.01
    hitcb = cb
    self.hp -= dmg
    kill_happened = self.hp <= 0
    vis_hp_tick = 30
  end

  function u:attackable_spots()
    local res = {}
    for d in all(cardinal_dirs) do
      add(res, vec(self.x + d.x, self.y + d.y))
    end
    return res
  end

  function u:cancel()
    mgr:popstate()
    mgr:pushstate(last_menu)
  end
  local opts = {}
  add(opts, mk_action("bash", function()
    mgr:pushstate(make_pos_selector(u.x, u.y, mgr, u.attack_dir, u.cancel, 1))
  end ))

  function u.heal_pos(pos)
    mgr:pushstate(make_heal_pos(pos, mgr.context, function()
      u.active = false
    end))
  end

  if type.abilities.heal then
    add(opts, mk_action("heal", function()
      mgr:pushstate(make_pos_selector(u.x, u.y, mgr, u.heal_pos, u.cancel, 1))
    end))
  end

  if type.abilities.shoot then
    add(opts, mk_action("shoot", function()
      mgr:pushstate(make_pos_selector(u.x, u.y, mgr, u.shoot_dir, u.cancel, 2))
    end ))
  end

  if type.abilities.bomb then
    add(opts, mk_action("bomb", function()
      mgr:pushstate(make_pos_selector(u.x, u.y, mgr, u.bomb_pos, u.cancel, 3, true))
    end ))
  end

  add(opts, mk_action("rest", function()
  u.hp = min(u.hp + 2, u.max_hp)
  u.active = false
  end))

  function u:options()
    return opts
  end

  function u.attack_dir(pos)
    mgr:pushstate(make_attack_pos(vec(u.x, u.y), pos, mgr.context, mgr, u.finish_attacking, type.power))
  end

  function u.shoot_dir(pos)
    mgr:pushstate(make_attack_pos(vec(u.x, u.y), pos, mgr.context, mgr, u.finish_attacking, type.shoot_power))
  end

  function u.bomb_pos(pos)
    ds = {-1, 0, 1}
    for y in all(ds) do
      for x in all(ds) do
        if mgr.context:unit_at(pos.x + x, pos.y + y) then
          mgr:pushstate(make_attack_pos(pos, vec(pos.x + x, pos.y + y), mgr.context, mgr, u.finish_attacking, 6 - abs(x) - abs(y)))
        end
      end
    end
    u.active = false
  end

  function u.finish_attacking()
    u.active = false
    -- get an extra turn if you killed!
    if kill_happened and type.abilities.fleetfoot then
      u.active = true
    end
    kill_happened = false
  end

  function u:alive()
    return self.visible_hp > 0
  end

  function u:draw_hp_bar()
  if self.visible_hp ~= self.hp or vis_hp_tick > 0 or mgr.curs.x / 8 == self.x and mgr.curs.y / 8 == self.y then
    if vis_hp_tick == 0 then vis_hp_tick = 10 end
     rectfill(self.x * 8 - 1, self.y * 8 + 9, self.x * 8 + 8, self.y * 8 + 12, 2)
     if self.visible_hp > 0 then
       rectfill(self.x * 8, self.y * 8 + 10, self.x * 8 + 7 * self.visible_hp / self.max_hp, self.y * 8 + 11, 8)
     end
   end
  end

  function u:render()
      palt(11, true)
      palt(0, false)
    if recoil > 0 then
      recoil += 0.07
      if recoil >= 0.5 then
        hitcb()
        recoil = 0
      end
    end
    if not self:alive() then
      if not died then
        sfx(6)
        died = true
        if self.team == 0 then
          del(player_team, self.type)
        end
      end
      -- token reduction candidate
      spr(18, self.x * 8, self.y * 8)
      return
    end
    self.anim:tick()
    if not self.active then set_whole_palette(0) end
    spr(self.anim:curval(), self.x * 8 - hitdir.x * sin(recoil) * 6, self.y * 8 - hitdir.y * sin(recoil) * 6, 1, 1, self.team == 1)
    reset_palette()
    self.hp = min(self.hp, self.max_hp)
    if self.visible_hp ~= self.hp then
      self.visible_hp -= 0.1 * sgn(self.visible_hp - self.hp)
      if abs(self.visible_hp - self.hp) < 0.15 then
        self.visible_hp = self.hp
      end
    elseif vis_hp_tick > 0 then
      vis_hp_tick -= 1
    end
    palt(0, true)
    palt(11, false)
  end
  return u
end

function reset_palette()
  for i = 0, 15 do
    pal(i, i)
  end
end
function set_whole_palette(col)
  for i = 0, 15 do
    pal(i, col)
  end
end


-- menu

-- these could be inlined to save some tokens :<
menu_x = 10
menu_y = 10
-- could be dynamic
menu_w = 80
menu = {}

function menu.active_update(self, context)
  if btnp(k_d) then
    self.cursel += 1
    sfx(4)
  elseif btnp(k_u) then
    self.cursel -= 1
    sfx(4)
  elseif btnp(k_a) then
    self.mgr:popstate()
    self.options[self.cursel].action()
    sfx(4)
  elseif btnp(k_b) then
    self.mgr:popstate()
    self.on_cancel()
  end
  self.cursel = mid(1, #self.options, self.cursel)
end

function menu.control_render(self)
  rectfill(menu_x, menu_y, menu_w, #self.options * 12 + 10, 1)
  for i = 1, #self.options do
    print(self.options[i].text, menu_x + 10, menu_y + 4 + (i - 1) * 12, 7)
  end
  spr(2, menu_x, menu_y + (self.cursel - 1) * 12 + 2)
end
last_menu = nil

function make_menu(args, on_cancel, mgr)
  local m = {
    options = args,
    cursel = 1,
    mgr = mgr,
    on_cancel = on_cancel
  }
  last_menu = m
  m.active_update = menu.active_update
  m.control_render = menu.control_render
  return m
end

-- end menu

function pressed_angle()
  if btnp(k_l) then
    return 0.5
  elseif btnp(k_r) then
    return 0
  elseif btnp(k_u) then
    return 0.25
  elseif btnp(k_d) then
    return 0.75
  end
  return nil
end

-- sgn(0) = 1 :/
function sign(x)
  if x == 0 then return 0 else return sgn(x) end 
end

function make_attack_pos(from, to, ctx, mgr, cb, dmg)
  local a = {}
  local attacker = ctx:unit_at(from.x, from.y)
  local attackee = ctx:unit_at(to.x, to.y)
  local t = 0
  function a:active_update()
    if t < 10 then
      t += 1
    elseif t == 10 then
      t = 11
      if attackee then
        attackee:play_hit_anim(vec(sign(to.x - from.x), sign(to.y - from.y)), dmg, function() t = 12 end)
      else
        t = 12
      end
    elseif t >= 18 then
      mgr:popstate()
      cb()
    elseif t > 11 then
      t += 1
    end
  end
  return a
end

-- dir selector
function make_pos_selector(x, y, mgr, cb, on_cancel, dist, sq)
  local d = {}
  local dir = 0
  function d:active_update()
    if btnp(k_l) or btnp(k_r) or btnp(k_u) or btnp(k_d) then
      sfx(4)
      dir = pressed_angle()
    elseif btnp(k_a) then
      mgr:popstate()
      -- dir
      cb(vec(x + cos(dir) * dist, y + sin(dir) * dist))
    elseif btnp(k_b) then
      on_cancel()
    end
  end
  function d:control_render()
    local dx = cos(dir) * 8 * dist
    local dy = sin(dir) * 8 * dist
    mgr.curs.x = x * 8 + dx
    mgr.curs.y = y * 8 + dy
    spr(21, x * 8 + dx, y * 8 + dy)
    if sq then
      for u in all({-8, 0, 8}) do
        for a in all({-8, 0, 8}) do
          spr(21, x * 8 + dx + a, y * 8 + dy + u)
        end
      end
    end
  end
  return d
end
-- end dir selector

path = vec(0, 0)

-- select out n things from c, mutates c
function select(n, c)
  c = cpy(c)
  local res = {}
  while #res < n do
    local e = sample(c)
    add(res, e)
    del(c, e)
  end
  return res
end

function cpy(c)
  local r = {}
  for e in all(c) do add(r,e) end
  return r
end

function noop()
end

gameover = false

function make_mission(m)
  local ended = false
  local started = false
  function m:get_enemies()
    return select(m.numunits, m.unit_pool)
  end

  function m:update(ctx)
    if not started then
      ctx.manager:pushstate(make_banner("defeat the enemy", ctx.manager, noop))
      started = true
    end
    if all_team_dead(ctx, 1) and not ended then
      ended = true
      end_level(m.reward_pool, m.followup, ctx.manager)
    end
    if all_team_dead(ctx, 0) and not ended then
      ended = true
      gameover = true
      ctx.manager.control_stack = {}
      ctx.manager:pushstate(make_banner("game over", ctx.manager, noop))
    end
  end

  return m
end

function rectpts(x1, x2, y1, y2)
  local res = {}
  for i = x1, x2 do
    for j = y1, y2 do
      add(res, {i, j})
    end
  end
  return res
end

function make_unit_list(s)
  res = {}
  for i = 1, #s do
    add(res, units[sub(s,i,i)])
  end
  return res
end

player_team = select(2, make_unit_list("oga"))

m5 = make_mission({
  x = 64,
  pstarts = rectpts(5, 10, 7, 9),
  estarts = {{0,14},{1,14},{2,14},{15,14},{14,14},{13,14}},
  numunits = 6, -- 6
  unit_pool = make_unit_list("kkkkkoo"),
  followup = nil
})

m4 = make_mission({
  x = 48,
  pstarts = rectpts(6, 9, 6, 8),
  estarts = {{7, 0}, {8,0}, {4,8}, {12,8},{7,15},{8,15}},
  numunits = 5, -- 5
  unit_pool = make_unit_list("kkkooo"),
  reward_pool = make_unit_list("tbh"),
  followup = m5
})

m3 = make_mission({
  x = 32,
  pstarts = rectpts(7, 9, 9, 10),
  estarts = rectpts(7, 9, 2, 3),
  numunits = 4, -- 5
  unit_pool = make_unit_list("kkoog"),
  reward_pool = make_unit_list("bao"),
  followup = m4
})

m2 = make_mission({
  x = 16,
  pstarts = rectpts(7, 9, 9, 10),
  estarts = rectpts(7, 9, 2, 3),
  numunits = 4, -- 4
  unit_pool = make_unit_list("ssoogg"),
  reward_pool = make_unit_list("bah"),
  followup = m3
})

m1 = make_mission({
  x = 0,
  pstarts = rectpts(6, 10, 1, 1),
  estarts = rectpts(12, 13, 2, 4),
  numunits = 3, -- 3
  unit_pool = make_unit_list("ssgg"),
  reward_pool = make_unit_list("ogt"),
  followup = m2 -- m2
})

function end_level(units, next, mgr)
  next_mission = next
  mgr:pushstate(make_banner("mission complete", mgr, function()
    if not next then
      active_gm = make_ending_screen()
      return
    end
    local new_units = select(2, units)
    active_gm = make_unit_picker(new_units, make_game_manager)
  end))
end

function all_team_dead(ctx, team)
  for u in all(ctx.units) do
    if u:alive() and u.team == team then
       return false
    end
  end
  return true
end

debugtxt = ""
function make_game_manager()
  local m = {
    curs = make_cursor(),
    control_stack = {}
  }
  add(m.control_stack, m.curs)
  -- are circular references ok in p8?
  -- its probably fine
  m.context = make_context(m)

  function m:update()
    self.curs:update(self.context)
    local active_thing = self.control_stack[#self.control_stack]
    if active_thing then
      active_thing:active_update(self.context)
    end
    self.context:update()
  end

  function m:pushstate(state)
    self.control_stack[#self.control_stack + 1] = state
  end

  function m:popstate()
    self.control_stack[#self.control_stack] = nil
  end

  function m:render()
    map(mapx, mapy, 0, 0, 16, 16)
    self.context:render()
    m.curs:render()
    for control in all(self.control_stack) do
      if control.control_render then
        control:control_render(self.context)
      end
    end
    -- hah, goteem
    -- print(debugtxt, 10, 18, 7)
  end
  return m
end


function make_unit_picker(units, next_mission)
  local u = {}

  local j = 0
  local tick = 1
  function u:update()
    if (btnp(k_l)) j -= 1
    if (btnp(k_r)) j += 1
    j = mid(0, j, #units - 1)
    tick += 0.2
    if (tick > 3) tick = 1
    if btnp(k_a) then
      add(player_team, units[j + 1])
      active_gm = make_game_manager()
    end
  end

  function u:render()
    -- gon' get ugly here boys
    print("pick a recruit", 38, 10, 6)
    local i = 0
    palt(11, true)
    palt(0, false)
    for u in all(units) do
      local t = 1
      if i == j then t = flr(tick) end
      spr(u.frames[t], 60 + 20 * i - 20 * j, 60)
      i += 1
    end
    palt(11, false)
    palt(0, true)
    draw_cursor(60, 60, -1)
    t = units[j+1].desc
    print(t, 64 - #t*2, 100)
  end
  return u
end

function make_title_screen()
  local s = {}
  local t = 0
  local f = 100
  function s:update()
    t += 1
    f += 0.6

    if t <= 180 and t % 60 ==0 then
      f = 0
      sfx(9)
    end
    if t > 380 then t = 280 end
    if btnp(4) or btnp(5) then
      sfx(9)
      f = -20
      t = f
    end
    if t == -1 then
      active_gm = make_game_manager()
    end
  end
  function s:render()
    local y = t/100
    if t >= 180 then
      print("by justin jaffray", 30, 90 + sin(y))
      print("press button to begin", 18, 100 + cos(y))
    end
    if t > 120 then
      map(16, 16, 48, 25 + 3 * cos(y), 3, 8)
    end
    if t > 60 then
      map(19, 16, 39, 39 + 3 * sin(y), 6, 3)
    end
    for x = 0, 15 do
      for y = 0, 15 do
        spr(176 + mid(0, flr(f), 6), x * 8, y * 8)
      end
    end
  end
  return s
end

function make_ending_screen()
  u = {}
  y = 128
  function u:update()
    y -= 0.25
  end
  function u:render()
    color(6)
    print("and so the group took the", 10, y)
    print("castle and ruled the land.", 10, y + 20)
    print("that is...", 10, y + 40)
    print("until the next usurpers rose.", 10, y + 60)
    print("congratulations!", 10, max(y + 80, 52))
    print("play again?", 10, max(y + 100, 62))
  end
  return u
end

-- icky globals but we're down to the wire here
next_mission = m1
active_gm = make_title_screen()

function _update()
  active_gm:update()
end

function _draw()
  cls()
  active_gm:render()
end
__gfx__
000000000aa90000000000000000000000220000000000000044444000000000000000005555555555555555776666658a8888a877ddddd52288888888888825
00000000a22290000000000000000000002820000002200004999994000000000000000051559aaaaaa95155766666655a8888a87dddddd52288888888888825
00000000a2a90000000700000000022222288200002882004949994944444444444440005559a949949a9555666666659a8888a8ddddddd55288889999888822
000000009290000000077000000028888888882002888820449999949999999999999400559a94888849a9556666666588888888ddddddd55288999999998822
00000000090000000007770000028888888888202888888249999999999999999999494015a9488488849a15666666658a8888a8ddddddd52288889999888825
00000000000000000007700000288882222882002228822249999999999999999999949455a4888884884a55666666d58a8888a5dddddd552288888888888825
00000000000000000007000000288820002820000028820049999999999999999999999451a8884888888a51dddddd558a8888a9555555555288888888888822
00000000000000000000000000288200002200000028820049999999999999999999999415a8888848888a155555555588888888555555555288888888888822
bbbbbbbbbbb5655bbbbbbbbb0028820000000000000000004999999999999999999999447959848484849595555555558a8888a85c7ccc1577777777cccc77cc
bbb5655bbb65353bbbbbbbbb0028820000000000080808004999999499999999999999949a945222222549a9515551555a8888a85c7ccc15777777771111cc11
bb65353bbb63050bbbbbb777002882002222222200202080044499499999999999999494aaa5222222225aaa555555559a8888a85c7ccc157777777710101010
bb63050bbb53333b7777b6bb002882008888888808020200449444949999999999994944aa552222222255aa55555555888888885c7ccc157777777711111111
b653333bb655535b707067b6002882008888888800202080494400494999999999949494aa95522222255aa51515151588a88a885c7ccc157777777701010101
b3355353b355555377776b76002882002222222208020200044000044444444444444444444a55555555a44455555555988888895c7ccc157777777700000000
bb335553b355553bb767b7b6002882000000000000808080000000000000000000004944644aaa9999aaa44551515151598888955c7ccc1577777777ccc000cc
bbbbbb3bbb33bbbbbbbbbbbb002882000000000000000000000000000000000000000440555a55555555a55515151515555995555c7ccc1577777777777ccc77
bbbbbbbbbbe88bbbbb000bbbbbbbbbbbbbbbbbbbb7beeebbb6d4444bbbbbbbbbbbbbbbbbbb3333bb022e2222066666d0005655051c7ccc1177777777ccc944cc
bbe88bbbbe8020bbb50505bbbb000bbbb7beeebb77ae0e0e6dd41f16bdd4444bbb3333bbbf3fffbb0222e2226666666d055565501c7ccc117c77777711999911
be8020bbb88888880000005bb00500bb77ae0e0ebabeeee2dddf999d6dd41f1dbf3fffbbbf9090bb222e222066677666505655001c7ccc1177777c7710409990
b8888888444525bb0500055b0000005bbabeeee2b4be26bbdd21f1dddddf999dbf9090bbb3ffffbb2222e2206675576605556550117ccc117777777711444041
4444242b844454bb0000500b0050550bb4be26bbbe22dd2bdd2d1ddddd21f1ddb3ffffbbbb34f4bb022e22226670076600565505111111117777777701994401
844545bb2444448b6505080855050202be22dd2bb4e2552b2fdddd2f2d2d1d2d966694bbb96669bb0222e22266677d6605556550cccccccc7777777709999900
244454bbb44444bb06550000b6550000e4e2552bb4e252bb222222222f22222f4b3343bbb43334bb222e2220d666666d50565500dddddd55777c7777c40499cc
b82bbbbbbbbbb2bbb06b6055bb066005e4bbb2bbeeb2bbbbb55bbbbb22bbb552b494b3bbbb4943bb2222e2200d6666d005556550555555557777777777440777
bbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbfbfbfbfbb9cccccfbbbbfbfbbc4444cfffffffffffffffffff4444ffffffffff01010101c10000ccc100001c
bbbbbbbbbbbbbbbbbbbbbbbbbb3355bbbbbbbbbbc9c9c9c9fccccc9bbbf9c9c9f444444bffffffffffff4ffff4ff994fffffffff10101010c100001cc110101c
bbbbbbbbb33bbb3bbbebbbbbbb3333bbbb65bbbbccccccccb9cccccfb9cccccc44599544ffffffffffffffff4ff9f994ffffffff01010101c0000011c10000c7
bbbbbbbbbb33b3bbbeaebbbbb333355bbb55bb5bccccccccfccccc9bfccccccc49599594ffffffffffffffff44f99944ffffffff101010107c0000017c0000c7
bbbbbbbbbb33b3bbbbebbbbbb333333bbbbbbbbbccccccccb9cccccfb9cccccc59444495fffffffffffff4ff4f444494ffffffff010101017c0000017c00001c
bbbbbbbbbbb3bbbbb33bbbbbb535555bbbbbbbbbccccccccfccccc9bfccccccc54444445ffffffffff4fffff4f9f9f94ffffffff101010107c0000007c01011c
bbbbbbbbbbbbbbbbbb3bbbbbbbb45bbbbbbb5bbb9c9c9c9cb9cccccfb9cccccc44cccc44fffffffffffffffff4f9f945ffffffff0101010177ccc000c100001c
bbbbbbbbbbbbbbbbbbbbbbbbbb4445bbbbbbbbbbbfbfbfbffccccc9bfcccccc94cccccf4fffffffffffffffff5444456ffffffff1010101077777cccc100001c
d7dddd11d7dddd16166dd66161dddd11f455554bfbfbfbfbbbbbbbbbbbb5585bd11101000010111dbbbbbbbbbbbcc0cb00000000000000000000000000000000
7dddddd17ddddd161666666161ddddd1c4999949c9c9c9c9bbb5585bbb55fffbd10111000011101dbbcc0cbbbbc0ccbb00000000000000000000000000000000
dddddd11dddddd1d1666ddd1d1dddd11c455554ccc56ccccbb55fffbbb5f090bd88801000010888dbc0ccbdbbdccc1bb00000000000000000000000000000000
ddddddd1dddddd011111111110ddddd1c499994ccc5577c7bb5f090bbb5ffffb889a44400444a988bccc14bbbeeee4ed00000000000000000000000000000000
dddddd11dddddd551515151555dddd11c455554cccccccccb55ffffbb5558f8bd88801400410888dbeee4ebbbbeeeeeb00000000000000000000000000000000
ddddd1d1ddddd1555555555555ddd1d1c499994cccccccccbf558f85b555585fd10111000011101ddeeeee44b4eeeeeb00000000000000000000000000000000
1d1d1d101d1d1d5551515151551d1d119499994c9c9c9c9cbb66585fbf55556bd11101000010111dbbeebbbbbbbbbeeb00000000000000000000000000000000
11111100111111151550155051111111b455554fbfbfbfbfbbbbbb6bbb66bbbbd11111000011111dbb4bbbbbbbbbbb4b00000000000000000000000000000000
166dd661bbdddd1bbdd7bb1111101110d1110100000000000010111d00000000dddddddd000000000011111dd1110100ddddddddd11111000011111ddddddddd
166666617dddddd1bdddbbd111011101d1011100000000000011101d0000000011111111000000000010111111111100d0111111d11111000011111d1111110d
1666ddd1dddddd0bbb1ddb1110111011d1110100111111000010111d1111111110101011001111110011101111010100d1011111d11110111101111d1111101d
11111111dddd0bbbbb0d0dd101110111d1011100010111000011101d1010101011111111001101010010111111111100d1101111d11101111110111d1111011d
166dd661ddddd0bb101dddd111101110d1110100111101000010111d1111111101010101001111110011101010101100d1110111d11011111111011d1110111d
16666661ddddddddddddddd111011101d1011100110111000011101d1101010111111111001010110011111111111100d1111011d10111111111101d1101111d
1666ddd11d1d1d1d1d0b011010111011d1110100111101000010111d1111111100000000001111110000000000000000d1111100d01111111111110d0011111d
11111111b111111b1bbb110001110111d1111100d11111000011111ddddddddd00000000001011110000000000000000d1111100dddddddddddddddd0011111d
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
00079994000000000000000000077650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007aaaa9000000000000000000007500000aaaaa0aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
009a99a90000779999999400000000000000a89a0a88a00000000000000000000000000000000000000000000000000000000000000000000000000000000000
009a99a900007977aaaa9900000000000000a89a0a89a00000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aaaa900009999aa999400000000000000a89aa89a000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000999940000099999994000000000000000a89989a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009aa900000000000000000000000000000a8888a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000994400000000000000000000000000000a8888a00000aaaaaa0aa00aaa000aaaaa00000000000000000000000000000000000000000000000000000000000
0009aa900067766600677666000000000000a8888a000000a89a00a8a0a9a00a8889a00000000000000000000000000000000000000000000000000000000000
000994400067766600677666000000000000a8888a000000a89a00a88aa9a0a889aa000000000000000000000000000000000000000000000000000000000000
9999aa990067766600677666000000000000a89989a00000a89a00a88899a0a89a00000000000000000000000000000000000000000000000000000000000000
7aaaaaaa0067766600677666000000000000a89aa89a0000a89a00a89889a0a890aaaaa000000000000000000000000000000000000000000000000000000000
aaa9aa990067766600677666000000000000a89a0a89a000a89a00a89a89a0a89a0a8a0000000000000000000000000000000000000000000000000000000000
999999990067766600677665000000000000a89a0a89a000a89a00a8a0a9a00a8889a00000000000000000000000000000000000000000000000000000000000
00677766006776660067766600000000000aaaaa0aaaaa0aaaaaa0aaa00aa000aaaa000000000000000000000000000000000000000000000000000000000000
00677666006776660067766500000000999999999900099999999099999999999999999999900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000988888898900998889989098988888988888988888900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000989999998900989998989998989999989998989999900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000988888898900988888988888988880988888988888900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999898999989998999899989999989889999998900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000988888898888989098909890988888989998988888900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999999999999099909990999999999999999999900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777077707770707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777770707070707070707000700000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777770707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777770707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777077707770707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777770707070707070707000700000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777770707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777770707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000101000100000000000000000000000001010101010001000000000000000000000100010100000000000100010101000000010001010100000100000100000101000000000000010000010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
333333333330303030303036303030303333333333333333333333333333333350505040404040404040404040505050535353535354404040405653535353530c1b1d1b1b0c1b0c0c1b0c1b1b1d1b0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333330303030313036303130303333303030323030303333333333333342505040404040404040404040505042535353535354404040405653535353530c1b1d1b1b0c1b0c0c1b0c1b1b1d1b0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333431303030303436303030303333303030303030303133333333333330425040404040404040404040504230535353535354404040405653535353530c1b1d1b1b0c1b1c1c1b0c1b1b1d1b0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333030303030303036303030303330303130303032303033333333333330305040404040404040404040503030535353535348404040404953535353530c1b1d1b1b0c1b1b1b1b0c1b1b1d1b0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333303030303030313036303030303334303030303030303333333333333330304242424243404041424242423030535353535354404040405653535353531c1b1d1b1b0c1b1b1b1b0c1b1b1d1b1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333130303130303030303630303430333333333333333230333333333333333030303034344040404034303430313053535c58585b404040405a58585f53531b1b1d1b1b1c1b090a1b1c1b1b1d1b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333330303030303030313036303030303535354535353544443535354535353530303130523440404040345130303030535354404040404040404040405653530b0b2d0b0b0d0b191a0d0b0b0d2d0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333313030303030303036303130303333333333333330303333333333333330323031303030343034303030303030535348404040404040404040404953530b0b0b0d0b0b0d0e0f0b0d0b0b0b0d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333030323030303036303030303333333333333330303333333333333330303030302b5130305230302b303030535354404040404040404040405653530b0d0b0b0b0d0b0e0f0d0b0b0d0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333030303031303036303430303333333333333030303033333330303330303052302c3030303030302c30303053535d575755404040405957575e53530b0b0b0d0b0b0d0e0f0b0d0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333330303030303036303030303333333333343030313030303030303330302b30302c3030305230302c323030535353535354404040405653535353530b0b0b0b0b0d0b0e0f0d0b0b0d0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333330303030303038303030303333333333333030303034303130333330302c3130303030303030302c303030535353535354404040405653535353530b0b0b0d0b0b0d0e0f0b0d0b0b0b0d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333313030303036303030303333333333333330303030303030333330322c30303030303030303030303030535353535348404040404953535353530b0d0b0b0b0d0b0e0f0d0b0b0d0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333303030313036303030303333333333333333333333333333333330302c30303030303132303031303030535353535354404040405653535353530b0b0b0d0b0b0d0e0f0b0d0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333323034303036303030303333333333333333333333333333333330302c31303030303030303030303034535353535354404040405653535353530b0b0b0b0b0d0b0e0f0d0b0b0d0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333303030303036303030303333333333333333333333333333333330303030303030303030303030303030535353535354404040405653535353531b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300800084858687880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434381908294959697989900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43434343434340414141414243434343009100a4a5a6a7a8a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434340415151516363514243434300910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434051515151535151515142434300910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343435051515151536363635162434300910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343436051636351515151515243434300920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434350515153515151516243434300830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434350515151516363524343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434051515151515351524343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343405151536363515151514243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343605151515151515151516243434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343436061616161616161624343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001400000f270192001b200192000f270192001b200192000f2700f200102000c2000f2700e20010270102000f270132000f200142000f2701b200192001b2000f2701b200192000f2000f270192001327019200
0014000000700107701077000700007001c7701c770007000070028770287700070000700287702777026770257702477023770237702377023770237702377000700007001c7001c7001b770237001f77010700
000100002317021170211702217026170271701c100211002d10032100311002a1002610000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000e5700e5700e5700f57010570125701257012570005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100002107021070210702307024070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001c670236702767028670286702767022670196700000000000200000000000000000002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000340700e070310700e0702d0700e070280700e070220700e0701d070170701507012070100700f0700d0700d0700d0700d0700f0000f0000f0000f0000000000000000000000000000000000000000000
000200001d07020070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000031070320703207033070330703307033070310702c070280702007017070100700907002070220700307007070090700e07011070170701a0701c0701d070170701b0701f07022070280702f07030070
000300003e6703f6703f6703e6703d6703a670346702e670266701c670136700e6700c67009670086700767006670056700567004670046700467003670036700267001670016500164001630016100160001600
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
03 00 01 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
