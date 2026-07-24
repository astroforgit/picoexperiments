pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

gravity = 0.05

function chance(n)
  return flr(rnd(n)) == 0
end

function stall(n)
  for i=1,n do
    flip()
  end
end

function bigprint(s, x, y, c)
  scale = scale or 8
  s = tostr(s)
  pal()
  pal(7, c)
  for idx = 1,#s do
    local char = sub(s, idx, idx)
    local num = tonum(char)
    sspr(num * 8, 16, 8, 8, x, y)
    x += scale
  end
end

function printol_helper(pstring,px,py,pcol,fn)
  for printx = 0, 2 do
    for printy = 0, 2 do
      fn(pstring, px + printx, py + printy, 0)
    end
  end
  fn(pstring, px + 1, py + 1, pcol)
end

function printol(pstring,px,py,pcol)
  printol_helper(pstring, px, py, pcol, print)
end

function bigprintol(s, x, y, c)
  printol_helper(s, x, y, c, bigprint)
end

function pick(l)
  local i = flr(rnd(#l)) + 1
  return l[i]
end

area_split = 4
area_size = 128 / area_split

function area_idx(x, y)
  local i = flr(x / area_size)
  i += flr(y / area_size) * area_split
  return i
end

function init_areas()
  areas = {}
  for i = 0, area_split * area_split do
    areas[i] = {}
  end
end

function area_rm(mint)
  for i = 0, #areas do
    del(areas[i], mint)
  end
end

function area_update(mint)
          local w = max(mint.r, area_size)
      local y = max(0, mint.y)
  while y <= mint.y + w and y < 128 do
    local x = max(0, mint.x)
    while x <= mint.x + w and x < 128 do
      add(areas[area_idx(x, y)], mint)
      x = x + area_size
    end
    y = y + area_size
  end
end

function in_area(x, y)
  return areas[area_idx(x, y)]
end

function debug_areas()
  for x = 0, 127, area_size do
    for y = 0, 127, area_size do
      local c = 7
      local n = #areas[area_idx(x, y)]
      if n > 0 then
        c = 12
        print(n, x+3, y+2, 12)
      end
      rect(x, y, x + area_size, y + area_size, c)
    end
  end
end

function collide_mints(e, effect)
  local ex, ey = e.x + 3, e.y + 3
  ex = mid(0, ex, 127)
  ey = mid(0, ey, 127)
  for p in all(in_area(ex, ey)) do
            local px, py = p.x + p.r / 2, p.y + p.r / 2
        local dx, dy = ex - px, ey - py
    local dist2 = dx * dx + dy * dy
        local r = p.r / 2
                    if abs(dx) < r and abs(dy) < r and dist2 < r * r then
            mksparks(flr(rnd(3)+3), ex, ey, p.pal)
            local a = atan2(dx, dy)
      local spd = sqrt(e.dx * e.dx + e.dy * e.dy)
                        spd = max(spd, 1.5)
            e.dx = cos(a) * spd
      e.dy = sin(a) * spd
      sfx(pick{10, 15, 16})
            if effect == 'damage' then
                p.flash = 2
        p.life -= 1
      elseif effect == 'coin_damage' then
        p.flash = 2
        p.life -= 2
        stat_coin_damage += 2
      elseif effect == 'power' then
        p.flash = 2
        p.life -= 5
        mkexp(ex, ey, 4)
      elseif effect == 'hyper' then
        p.flash = 2
        p.life -= 20
      end
    end
  end
end

function mkgift(x, y)
  stat_gifts += 1
  local effect = 'damage'
  local pal = pick{
    {3,8},
    {12,7},
    {7,12},
    {8,3},
  }
  if have_upgrade(ug_hyper_gifts) and chance(6) then
    effect = 'hyper'
    pal = {14, 7}
  elseif have_upgrade(ug_power_gifts) and chance(4) then
    effect = 'power'
    pal = {10, 9}
  end
  return {
    x = x, y = y,
    dx = 0, dy = 0,
        a=rnd(),
        pal=pal,
                tail = {},
    effect = effect
  }
end

function upgift(g)
    g.a+=1/60
    g.x+=g.dx
  g.y+=g.dy
      g.dy+=gravity
  g.dy=min(g.dy,3)
    if g.x < 0 or g.x > 128 then
    g.dx = -g.dx
  end

  collide_mints(g, g.effect)

        add(g.tail, {x = g.x, y = g.y})
  local max_tail = 4
  if g.effect == 'power' then
    max_tail = 8
  elseif g.effect == 'hyper' then
    max_tail = 16
  end
  if #g.tail > max_tail then
    del(g.tail, g.tail[1])
  end
end

function killgifts()
  local alive = {}
  for g in all(gifts) do
    if g.y < 128 then
      add(alive, g)
    end
  end
  gifts = alive
end

function drawgift(g)
      pal()
  palt(0,false)
  palt(14,true)
    if t % 2 == 0 then
        fillp(bor(0b101111101011111.1))
    local c = 0
    if g.effect == 'hyper' then
      c = 7
    end
        for t in all(g.tail) do
      circfill(t.x+3, t.y+3, 3, c)
    end
    fillp()
  end

  if g.effect == 'power' then
    circfill(g.x + rnd(8) - 1, g.y + rnd(8) - 1, 4, 0)
    circfill(g.x + rnd(8) - 1, g.y + rnd(8) - 1, 4, 7)
  elseif g.effect == 'hyper' then
    circfill(g.x + rnd(8) - 1, g.y + rnd(8) - 1, 8, pick{0, 2})
    circfill(g.x + rnd(8) - 1, g.y + rnd(8) - 1, 8, pick{14, 7})
  end

    pal(3, g.pal[1])
  pal(8, g.pal[2])
      local i = flr((g.a%1)*8) + 1
      local sprs = {1,2,3,2,1,2,3,2}
  local fx = {false,false,false,false,true,true,true,true}
  local fy = {false,false,false,true,true,true,false,false}
    spr(sprs[i],g.x,g.y,1,1,fx[i],fy[i])
end

function mkexp(x, y, r)
  add(explosions, {
    x = x, y = y,
    r = r, t = 5
  })
end

function upexp()
  for e in all(explosions) do
    e.t -= 1
  end
end

function drexp()
  pal()
  for e in all(explosions) do
    if e.t > 2 then
      circfill(e.x, e.y, e.r, 7)
    elseif e.t > 0 then
      circfill(e.x, e.y, e.r, 0)
    end
  end
end

function killexp()
  local alive = {}
  for e in all(explosions) do
    if e.t >= 0 then
      add(alive, e)
    end
  end
  explosions = alive
end

function mkmint()
                local rs = {}
  for i = 1, 40 do add(rs, 16) end
  for i = 1, 60 do add(rs, 32) end
  for i = 1, 20 do add(rs, 48) end
  for i = 1, 5 do add(rs, 64) end
  for i = 1, 1 do add(rs, 128) end
  local r = pick(rs)

                    local x = rnd(96) + 16 - r / 2
    if rnd() < 0.1 then
    x = pick{0, 128} - r / 2
  end

    local life = flr(rnd(5) + 3)
    if r > 32 then
    life *= 2
  end
    if r == 128 then
    life = 40
  end

        local y = rnd(256) + 128
  if #mints < 6 then
    y = rnd(64) + 128
  end

    local pal = {7, 8, 2}
  local power = have_upgrade(ug_power_gifts) or have_upgrade(ug_fast_gifts)
  local hyper = have_upgrade(ug_hyper_gifts) or have_upgrade(ug_super_fast)
  if hyper and chance(10) then
    pal = {2, 13, 0}
    life *= 16
  elseif chance(30) then
    pal = {7, 12, 1}
    life *= 8
  elseif hyper and chance(4) then
    pal = {7, 12, 1}
    life *= 8
  elseif chance(30) then
    pal = {7, 11, 3}
    life *= 4
  elseif power and chance(5) then
    pal = {7, 11, 3}
    life *= 4
  elseif hyper and chance(2) then
    pal = {7, 11, 3}
    life *= 4
  end

  return {
        a = rnd(), da = pick{1 / 45, 1 / 60, 1 / 90},
    r = r,
    x = x,
        y = y,
        dy = rnd() * 0.1 + 0.1,
        life = life,
        pal = pal,
            flash = 0
  }
end

function reward_more_coins(x, y)
  if chance(500) then
        sfx(21)
    mkcoins(x, y, 40)
    for mint in all(mints) do
      mint.life = 0
    end
    for i = 1, 16 do
      mkmint()
    end
  elseif chance(8) then
    mkcoins(x, y, 8)
  elseif chance(4) then
    mkcoins(x, y, 4)
  elseif chance(2) then
    mkcoins(x, y, 2)
  else
    mkcoins(x, y, 1)
  end
end

function reward_coins(x, y)
  if chance(500) then
        mkcoins(x, y, 20)
  elseif chance(8) then
        mkcoins(x, y, 4)
  elseif timer <= 0 then
        mkcoin(x, y)
  elseif chance(4) then
        mkcoin(x, y)
  end
end

function upmint(p)
  local alive = {}
  for p in all(mints) do
    area_rm(p)

        p.y -= p.dy
        if timer <= 0 then
      p.dy += 0.02
      p.dy = min(p.dy, 0.4)
      if p.life > 0 then p.life = 1 end
    end
        p.a += p.da

        if p.life <= 0 then
            sfx(13)
      sfx(14)
            local colors = p.pal
      if timer <= 0 then
        colors = {8,12,7,13,14,11,10,9,7,11,12,14}
      end
      mksparks(5, p.x -  8, p.y -  8, colors)
      mksparks(5, p.x -  8, p.y + 16, colors)
      mksparks(5, p.x + 16, p.y -  8, colors)
      mksparks(5, p.x + 16, p.y + 16, colors)
            shake += 3
      freeze = 3
                              local max_mints = 20
      if have_upgrade(ug_fast_gifts) then
        max_mints = 30
      elseif have_upgrade(ug_super_fast) then
        max_mints = 40
      end
      if timer > 0 and #mints < 20 then
        add(mints, mkmint())
        add(mints, mkmint())
        add(mints, mkmint())
        if have_upgrade(ug_fast_gifts) then
          add(mints, mkmint())
          add(mints, mkmint())
        end
      end
            mkexp(p.x + p.r / 2, p.y + p.r / 2, p.r / 1.2)
            timer -= 1
            if have_upgrade(ug_more_coins) then
        reward_more_coins(p.x, p.y)
      else
        reward_coins(p.x, p.y)
      end
      stat_sweets += 1
    end

        if p.y < -(p.r) then
      p.life = -1
      stat_missed_mints += 1
      if timer > 0 then
        add(mints, mkmint())
      end
    end

    if p.life > 0 then
      add(alive, p)
      area_update(p)
    end
  end
  mints = alive
end

function sortmints()
  if #mints < 2 then
        return
  end
      for i = 1, #mints - 1 do
                if mints[i].r < mints[i + 1].r then
      mints[i], mints[i + 1] = mints[i + 1], mints[i]
    end
  end
end

function cacherot()
    for i = 0, 4 do
        local a = i / 16
        for x = 0, 15 do
      for y = 0, 15 do
                        local dx, dy = x - 8, y - 8
        local aa = atan2(dx, dy) + a
        local l = sqrt(dx * dx + dy * dy)
        local rx = 8 + l * cos(aa)
        local ry = 8 + l * sin(aa)

                local c
        if rx <= 0 or rx > 15 or ry < 0 or ry > 15 then
                              c = 14
        else
                    c = sget(32 + flr(rx + 0.5), flr(ry + 0.5))
                                                            if (c ~= 14) and (
            sget(32 + flr(rx), flr(ry)) == 2
            or sget(32 + flr(rx), ceil(ry)) == 2
            or sget(32 + ceil(rx), flr(ry)) == 2
            or sget(32 + ceil(rx), ceil(ry)) == 2
          ) then
            c = 2
          end
        end
                        sset(x+i*16, y+64, c)
      end
    end
  end
end

function drmint(p)
    local a = flr(p.a%1 * 4)
    pal()
  palt(0, false)
  palt(14, true)
      if p.flash > 0 then
    for i = 0, 16 do
      if p.life < 3 then
        pal(i, 9)
      else
        pal(i, 7)
      end
    end
    p.flash -= 1
  else
    pal(7, p.pal[1])
    pal(8, p.pal[2])
    pal(2, p.pal[3])
  end
    sspr(
    a * 16, 64, 16, 16,
    p.x, p.y, p.r, p.r
  )
end

function mksanta()
  return {
        x = 58, y = 24,
        dx = 0, dy = 0,
        hx = 8, hy = 5,
        gt = 120,
        tutgift = true,
    tutmove = true,
  }
end

function upsanta(s)
          if btn(0) then
    s.hx = 7
    s.dx -= 0.1
    s.tutmove = false
  elseif btn(1) then
    s.hx = 9
    s.dx += 0.1
    s.tutmove = false
  else
    s.dx *= 0.95
    s.hx = 8
  end

    if btn(2) then
    s.dy -= 0.1
    s.tutmove = false
  elseif btn(3) then
    s.dy += 0.1
    s.tutmove = false
  else
    s.dy *= 0.95
  end
  
      s.dx = mid(-2, s.dx, 2)
  s.dy = mid(-1, s.dy, 1)
    if btn(4) then
    s.dx = mid(-0.2, s.dx, 0.2)
    s.dy = mid(-0.2, s.dy, 0.2)
  end

    for p in all(mints) do
    local sx, sy = s.x + 3 + s.dx, s.y + 3 + s.dy
    local px, py = p.x + p.r / 2, p.y + p.r / 2
    local dx, dy = sx - px, sy - py
    local dist = sqrt(dx * dx + dy * dy)
    if abs(dx) < p.r / 2 and abs(dy) < p.r / 2 and dist < p.r / 2 then
            sfx(10)
                  mksparks(flr(rnd(3)+3), sx, sy, {7, 8})
            shake = 1
                  local a = atan2(dx, dy)
      s.dx = cos(a) * 2
      s.dy = sin(a) * 2
    end
  end

      if s.x + s.dx < -6 or s.x + s.dx > 124 then
    s.dx = -s.dx
    shake = 2
  end
  if s.y + s.dy < -10 or s.y + s.dy > 124 then
    s.dy = -s.dy
    shake = 2
  end

    s.x += s.dx
  s.y += s.dy

      s.y += sin(t / 120) * 0.08

      if s.gt > 0 then
    s.gt -= 1
  end

    if btn(4) and s.gt <= 0 and s.tutgift then
    s.tutgift = false
    mktimer()
    round_state = 'playing'
    local num_mints = round_number > 1 and 16 or 4
    for i = 1, num_mints do
      add(mints, mkmint())
    end
  end

      if btn(4) and s.gt <= 0 then
        if have_upgrade(ug_super_fast) then
      s.gt = 10
    elseif have_upgrade(ug_fast_gifts) then
      s.gt = 30
    else
      s.gt = 60
    end
        local g = mkgift(s.x + 3, s.y + 6)
    add(gifts, g)
    if g.effect == 'power' then
      sfx(19)
    elseif g.effect == 'hyper' then
      sfx(20)
    else
      sfx(12)
    end
  end

        s.x = mid(-6, s.x, 124)
  s.y = mid(-10, s.y, 124)
end

function drawsanta(s)
  pal()

    if have_upgrade(ug_golden) and #gifts + #mints + #coins > 10 then
    circ(s.x + 6, s.y + 6, 12, 10)
  end

    pal()
  palt(0, false)
  palt(11, true)
    sspr(
    64, 0, 4, 4,
    s.x + s.hx, s.y + s.hy
  )
  if have_upgrade(ug_golden) then
    pal(6, 10)
    pal(5, 9)
  end
    sspr(
    48, 0, 13, 13,
    s.x, s.y
  )
    if have_upgrade(ug_golden) then
    sspr(72, 0, 7, 2, s.x + 3, s.y + 4)
  end
      if s.gt <= 0 and s.tutgift then
    printol("\x8e gift", s.x - 9, s.y + 21, 7)
  end
  if s.tutmove then
    printol("+ move", s.x - 9, s.y + 14, 7)
  end
end

function mksparks(n, x, y, cs)
  for i = 1, n do
    add(sparks, mkspark(x, y, pick(cs)))
  end
end

function mkspark(x, y, c)
  return {
    x = x,
    y = y,
    c = c,
    dx = rnd(4) - 2,
    dy = rnd(4) - 2,
    life = 60,     tail = {}   }
end

function upsparks()
    local alive = {}
  for s in all(sparks) do
            s.life -= 1
    if s.life > 0 then
      add(alive, s)
    end
        s.x += s.dx
    s.y += s.dy
        s.dy += gravity
        add(s.tail, {x = s.x, y = s.y})
            if #s.tail > 4 then
      del(s.tail, s.tail[1])
    end
  end
  sparks = alive
end

function drspark(s)
  pal()
    for i = 1, #s.tail - 1 do
    local st = s.tail[i]
    local ed = s.tail[i + 1]
    line(st.x, st.y, ed.x, ed.y, s.c)
  end
end

function mksnow()
  snow = {}
  for i = 1, 200 do
    add(snow, {
      x = rnd(128), y = rnd(128),
      dx = rnd(2) - 1, dy = rnd(0.5) + 0.5,
    })
  end
end

function upsnow()
  for s in all(snow) do
        s.x += s.dx
    s.y += s.dy
        if s.x < 0 then s.x += 128 end
    if s.x > 128 then s.x -= 128 end
    if s.y > 128 then s.y = -rnd(16) end

        s.dx += (rnd(1) - 0.5) * 0.25
    s.dx = mid(-1, s.dx, 1)
    s.dy += 0.1
    s.dy = min(s.dy, 1)
  end
end

function drsnow()
  for s in all(snow) do
    pset(s.x, s.y, 7)
  end
end

function mkclouds()
  clouds = {}
  for i = 1,8 do
    c = {
            x = pick{-8, 120},
            y = rnd(256),
      bits = {}
    }
        for i = 1,16 do
      add(c.bits, {
                x = rnd(32), y = rnd(48),
                        r = rnd(6) + rnd(6) + 4
      })
    end
    add(clouds, c)
  end
end

function upclouds()
  for c in all(clouds) do
        c.y -= 0.4
        if c.y < -64 then
      c.y = rnd(128) + 128
      c.bits = {}
      for i = 1,16 do
        add(c.bits, {
          x = rnd(32),
          y = rnd(48),
          r = pick{4, 4, 4, 6, 6, 6, 8, 8, 8, 16}
        })
      end
    end
  end
end

function drclouds()
  pal()
  for c in all(clouds) do
    for b in all(c.bits) do
            fillp(0b101111101011111)
      circfill(c.x + b.x, c.y + b.y, b.r, 118)
      fillp()
                  local x
      if c.x == -8 then
        x = c.x + b.x - 3
      else
        x = c.x + b.x + 3
      end
      circfill(x, c.y + b.y - 3, b.r - 1, 7)
    end
  end
end

function ease(t)
  t = mid(0, t, 1)
  if t >= 0.5 then
    return (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
  else
    return 4 * t * t * t
  end
end

function lerp(a, b, t)
  return a + (b - a) * t
end

function mkbonus()
  bonus = {
    y = -64,
    t = 0
  }
end

function upbonus()
  if bonus == nil then
    return
  end

  if bonus.t < 30 then
    bonus.y = lerp(-64, 32, bonus.t / 30)
  elseif bonus.t == 30 then
    shake = 8
    for x = 32, 96 do
      mksparks(1, x, 64, {8,12,7,13,14,11,10,9,7,11,12,14})
    end
    sfx(22)
  elseif bonus.t < 60 then
  elseif bonus.t < 120 then
    local t = bonus.t - 120
    bonus.y = lerp(32, 160, ease(t / 30))
  end

  bonus.t += 1

  if bonus.t > 80 then
    bonus = nil
  end
end

function drbonus()
  if bonus == nil then
    return
  end
  pal()
  palt(0, false)
  palt(14, true)
  sspr(0, 24, 63, 29, 33, bonus.y)
end

function mktimer()
  timer = 90
  timerobj = {
    t = 0
  }
end

function uptimer()
  if timerobj then
    timerobj.t += 1
  end

  if timer > 0 and t % 60 == 0 then
    timer -= 1
  end

  if timer <= 0  and round_state == 'playing' then
    round_state = 'bonus'
    mkbonus()
  end
end

function drtimer()
  if timer > 0 then
    local y = lerp(-16, 4, ease(timerobj.t / 40))
    bigprintol(timer, 56, y, 7)
  end
end

function mkcoin(x, y)
  add(coins, {
    x = x, y = y,
    dx = rnd(2) - 1, dy = -rnd(3),
    tail = {},
    t = 60 * 7
  })
end

function mkcoins(x, y, n)
  for i=1,n do
    mkcoin(x, y)
  end
end

function upcoin()
  local alive = {}
  for c in all(coins) do
    add(alive, c)

        c.t -= 1
    if c.t <= 0 then
      stat_missed_coins += 1
      mkexp(c.x, c.y, 4)
      del(alive, c)
    end

    local magnet_dist = 20
    if have_upgrade(ug_magnet) then
      magnet_dist = 80
    end

        local dist = abs(c.x - santa.x) + abs(c.y - santa.y)
    if dist < 4 then
      cash += 1
      stat_coins += 1
      sfx(17)
      del(alive, c)
    elseif timer <= 0 and #mints == 0 then
            c.dx = mid(-2, santa.x - c.x, 2)
      c.dy = mid(-2, santa.y - c.y, 2)
    elseif dist < magnet_dist then
                  c.dx = mid(-2, santa.x - c.x, 2)
      c.dy = mid(-2, santa.y - c.y, 2)
    end

        c.x+=c.dx
    c.y+=c.dy

        c.dy += gravity / 2

            c.dx=mid(-1, c.dx, 1)
    c.dy=mid(-3, c.dy, 1)
    
        if c.x < 0 or c.x > 128 then
      c.dx = -c.dx
    end
        if c.y > 128 then
      c.dy = -c.dy * 2
    end

    local effect = 'none'
    if have_upgrade(ug_crusher_coins) then
      effect = 'coin_damage'
    end
    collide_mints(c, effect)

        c.x = mid(0, c.x, 128)
    c.y = min(c.y, 128)

        if t % 3 == 0 then
      add(c.tail, {
        x = c.x + rnd(8), y = c.y + 4,
        c = pick{7, 9, 9, 10, 10},
                        t = flr(rnd(16))
      })
    end
    if #c.tail > 4 then
      del(c.tail, c.tail[1])
    end
    for t in all(c.tail) do
      t.y -= 0.3
    end
  end
  coins = alive
end

function drcoin()
  for c in all(coins) do
    if chance(60) then
      circfill(c.x + 4, c.y + 4, 8, 7)
    end
    for t in all(c.tail) do
      if t.t == 0 then
        pal()
        pal(7, t.c)
        spr(19, t.x, t.y)
      else
        circ(t.x, t.y, 1, t.c)
      end
    end
    if c.t < 60 and c.t % 2 == 0 then
      goto next
    end
    pal()
    palt(0, false)
    palt(14, true)
    local sprs = {16, 17, 18, 17}
    local i = flr(t / 6) % #sprs
    local s = sprs[i + 1]
    spr(s, c.x, c.y)
    ::next::
  end
end

function mkcash()
  cash_particles = {}
end

function upcash()
  if t % 9 == 0 then
    add(cash_particles, {
      x = rnd(8), y = rnd(8),
      c = pick{7, 7, 9, 9},
                  t = flr(rnd(16))
    })
  end
  if #cash_particles > 4 then
    del(cash_particles, cash_particles[1])
  end
end

function drcash()
  if cash > 0 then
    pal()
    palt(0, false)
    palt(14, true)
    spr(16, 1, 1)

    pal()
    for t in all(cash_particles) do
      if t.t == 0 then
        pal()
        pal(7, t.c)
        spr(19, t.x, t.y)
      else
        circ(t.x, t.y, 1, t.c)
      end
    end

    printol(cash, 10, 2, 10)
  end
end

function fade()
  local t = 0
  local fade = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
  local darks = {
    0, 0, 0, 1,
    2, 0, 5, 6,
    4, 8, 9, 3,
    6, 6, 13, 14
  }

  while t < 60 do
    t += 1

    if t % 6 == 0 then
      all_black = true
      for i = 1,#fade do
        fade[i] = darks[fade[i]+1]
      end
    end

    for i = 0,15 do
      pal(i, fade[i+1], 1)
    end

    flip()
  end
end

function init_game()
  state = 'game'

    shake = 0
    freeze = 0
  
    gifts = {}
  mints = {}
  santa = mksanta()
  sparks = {}
  explosions = {}
  coins = {}

    timer = 0
  round_state = 'start'
  mkcash()

  music(0, 0, 3)
end

function update_game()
  if freeze > 0 then
    freeze -= 1
    return
  end

  t += 1 
    upsanta(santa)

  foreach(gifts, upgift)
  killgifts()

  upmint()
  sortmints()
  upsparks()
    upclouds()
  upexp()
  uptimer()
  upcoin()
  upcash()
  upbonus()

  if round_state == 'bonus' and #mints == 0 and #coins == 0 then
    fade()
    init_shop()
  end

    shake -= 0.4
  shake = mid(0, shake, 4)
end

function drround()
  local s = 'round ' .. tostr(round_number)
  pal()
  printol(s, 126 - 4 * #s, 3, 7)
end

function drbought()
  local y = 120
  for i = 1,#bought do
    local u = upgrades[bought[i]]
    printol(u[5], 1, y, 7)
    y -= 8
  end
end

function draw_game()
  cls(5)

    local a = rnd()
  local cx = cos(a) * shake
  local cy = sin(a) * shake
  camera(cx, cy)

      drclouds()

    foreach(mints, drmint)
  drtimer()
  drcash()
  drround()
  drbought()
  drexp()
  foreach(gifts, drawgift)
  drcoin()
  foreach(sparks, drspark)

  drawsanta(santa)

  drbonus()
end

function init_title()
  cls(5)
  sfx(22)
  palt(0,false)
  palt(14,true)
  spr(106,56,32,2,2)
  printol('pico-8 advent calendar 2019', 10, 56, 7)
  printol('minbytes.com', 40, 88, 7)
  printol('copyright 2019 tom wright', 14, 96, 7)
  printol('creative commons cc-by-sa', 14, 104, 7)
  stall(20)
  fade()

  t = 0

    mkclouds()
  
  title_x = -75
  title_timer = nil

  music(17)
end

function update_title()
  t += 1

    upclouds()

  title_x -= 0.5
  if title_x <= -300 then
    title_x = 0
  end

  if title_timer ~= nil then
    title_timer -= 1
  end

  if title_timer == nil and (btnp(4) or btnp(5)) then
    music(-1)
    title_timer = 60
    sfx(21)
  end

  if title_timer ~= nil and title_timer <= 0 then
    init_game()
  end
end

function draw_title()
  cls(5)
    drclouds()
  printol('ufo santa candy blaster', 16, 8, 7)
  palt(0, false)
  palt(11, true)
  spr(6, 58, 24, 1.75, 1.75)
  pal()
  printol('drop gifts', 42, 44, 7)
  printol('destroy sweets', 34, 54, 8)
  printol('collect coins', 36, 64, 10)

  if t % 60 < 30 then
    printol('press \x97 or \x8e to play', 22, 94, 7)
  end

  printol('a game by tom wright for advent calendar 2019 - twitter:@thetomster3', title_x, 120, 7)
  printol('a game by tom wright for advent calendar 2019 - twitter:@thetomster3', title_x + 300, 120, 7)
end

upgrades = {
  {14,  20, "power gifts",   "   random chance to throw          a super gift         ", "p"},
  {10,  50, "speed up",      "   santa drops gifts more             quickly           ", "s"},
  {46,  50, "coin up",       "   coins are more likely             to appear          ", "c+"},
  {44,  30, "coin magnet",   "    coins are attracted         from farther away       ", "m"},
  {74,  60, "crusher coins", "   coins can deal damage             to mints           ", "c"},
  {42,  90, "hyper gifts",   "   random chance to throw       a hyper super gift      ", "p+"},
  {12, 120, "super speed",   "santa drops gifts even more           quickly           ", "s+"},
  {78, 500, "golden ufo",    "                                                        ", "$"}
  }
ug_power_gifts = 1
ug_fast_gifts = 2
ug_more_coins = 3
ug_magnet = 4
ug_crusher_coins = 5
ug_hyper_gifts = 6
ug_super_fast = 7
ug_golden = 8
ug_nospike = 9

function unlock_all()
  for i=1,#upgrades do
    add(bought, i)
  end
end

function init_shop()
  t = 0

  round_state = 'done'
  state = 'shop'

      shop = {}
  for i = 1, #upgrades do
        if not have_upgrade(i) then
      add(shop, i)
    end
        if #shop >= 3 then
      break
    end
  end

  if #shop == 0 then
        init_game_over()
    return
  end

    selected = 1

  santa = {x = 32}

  music(12)
end

function update_shop()
  t += 1

  local target_x = 26 + (selected - 1) * 32
  santa.x = lerp(santa.x, target_x, 0.4)

  if btnp(0) then
    sfx(18)
    selected -= 1
  elseif btnp(1) then
    sfx(18)
    selected += 1
  end
  selected = mid(1, selected, #shop)

  local upgrade_idx = shop[selected]
  local price = upgrades[upgrade_idx][2]
  if btnp(4) and cash >= price then
            if upgrade_idx == ug_hyper_gifts and not have_upgrade(ug_power_gifts) then
      add(bought, ug_power_gifts)
    elseif upgrade_idx == ug_super_fast and not have_upgrade(ug_fast_gifts) then
      add(bought, ug_fast_gifts)
    end

    add(bought, upgrade_idx)
    cash -= price
    sfx(22)
    fade()
    round_number += 1
    init_game()
  elseif btnp(5) then
    sfx(23)
    fade()
    round_number += 1
    init_game()
  end
end

function have_upgrade(i)
  for j = 1, #bought do
    if bought[j] == i then
      return true
    end
  end
  return false
end

function draw_shop()
  cls(5)

  local s = 'upgrade time'
  local x = 40
  for i = 1, #s do
    local c = sub(s, i, i)
    local y = sin((t + x) / 30) * 1.5 + 5
    printol(c, x, y, 7)
    x += 4
  end

  printol('you have ', 36, 16, 10)
  pal()
  palt(0, false)
  palt(14, true)
  spr(16, 72, 15)

  printol(cash, 81, 16, 10)

  pal()
  local y = 32 + cos(t / 120) * 1.5
  palt(0, false)
  palt(11, true)
  sspr(
    64, 0, 4, 4,
    santa.x + 8, y + 5
  )
  spr(6, santa.x, y, 2, 2)

  pal()
  palt(0, false)
  x, y = 24, 50
  for i = 1, #shop do
    local u = upgrades[shop[i]]
    spr(u[1], x, y, 2, 2)
    local price = tostr(u[2])
    printol(price, x + 7 - #price * 2, 68, 10)
    x += 32
  end

  local sel = upgrades[shop[selected]]
  local name, desc = sel[3], sel[4]
  printol(name, 64 - #name * 2, 85, 7)

  local d1, d2 = sub(desc, 0, 28), sub(desc, 28, 999)
  printol(d1, 64 - #d1 * 2, 95, 6)
  printol(d2, 64 - #d2 * 2, 103, 6)

  if cash >= sel[2] and t % 60 < 30 then
    printol('press \x8e to purchase', 24, 112, 7)
  elseif cash < sel[2] then
    printol('you need more coins!', 24, 112, 6)
  end

  printol('press \x97 to skip', 30, 120, 6)
end

function init_game_over()
  state = 'game_over'
  game_over_t = 0
  mksnow()
  music(16)
end

function update_game_over()
  t += 1
  game_over_t += 1
  upsnow()
end

function draw_game_over()
  cls(5)
  pal()
  drsnow()
  printol('game over', 46, min(game_over_t / 2, 16), 7)
  if (game_over_t > 40) printol('gifts dropped: '.. stat_gifts, 16, 32, 7)
  if (game_over_t > 70) printol('sweets destroyed: '.. stat_sweets, 16, 40, 8)
  if (game_over_t > 100) printol('sweets missed: ' .. stat_missed_mints, 16, 48, 6)
  if (game_over_t > 130) printol('coins collected: '.. stat_coins, 16, 56, 10)
  if (game_over_t > 160) printol('coins missed: ' .. stat_missed_coins, 16, 64, 6)
  if (game_over_t > 190) printol('coin damage: ' .. stat_coin_damage, 16, 72, 7)
  if (game_over_t > 220) printol('ended on round ' .. round_number, 16, 80, 7)
  if (game_over_t > 250) printol('thanks for playing!', 26, 112, 7)
  if (game_over_t > 280) printol('tom wright - @thetomster3', 14, 120, 7)
end

function _init()
    cacherot()
    t=0

  round_number = 1
  cash = 0
  stat_gifts = 0
  stat_sweets = 0
  stat_coins = 0
  stat_missed_coins = 0
  stat_coin_damage = 0
  stat_missed_mints = 0

          bought = {}

    init_areas()
  
  state = 'title'
  init_title()
end

function _update60()
  if state == 'title' then
    update_title()
  elseif state == 'game' then
    update_game()
  elseif state == 'shop' then
    update_shop()
  elseif state == 'game_over' then
    update_game_over()
  end

  update_cpu = stat(1)
end

function _draw()
  if state == 'title' then
    draw_title()
  elseif state == 'game' then
    draw_game()
  elseif state == 'shop' then
    draw_shop()
  elseif state == 'game_over' then
    draw_game_over()
  end

  draw_cpu = stat(1) - update_cpu

  max_cpu = max(max_cpu, stat(1))
                end
__gfx__
00000000e08080eeeeee0eeee00000eeeeeee222222eeeeebbbb000bbbbbbbbbb00b00000000000b567777777777776556777777777777655677777777777765
000000000338330eee0030ee0338330eeee2288777722eeebbb08880bbbbbbbb0ff00000b00b00bb67055eee00ee05766602020505050506679a9a9a9a9a9a76
007007000338330ee038338e0338338eee288887777782eeb00288880bbbbbbb0ff00000bbbbbbbb705088828e288007703323305050505779a900099009a9a7
000770000888880e0338880e0888880ee28888887777882e0772efff0bbbbbbbb00b000000000000750553228822350770330202050505077a90eee00ee09a97
000770000338330ee088838e0338338ee27778887777882e0670e0f00bbbbbbb000000000000000070500bb3223bb057702033233050505779088828e28809a7
007007000338330ee033830e0338330e2777778887788882b000efff0bbbbbbb000000000000000075055bb3883bb50770303308080505077a02822882230a97
00000000e00000eeee0300eee00000ee2777777887888882bbb067770bbbbbbb000000000000000070500eeeeeeee057703020338330505779a0b33223bb09a7
00000000eeeeeeeeeee0eeeeeeeeeeee2777788888888772b00028880000bbbb0000000000000000750558888888850775003033080805077a90bb3883bb0a97
ee0000eeeee00eeeeee00eee0070000027788888888777720666666667770bbb0000000000000000705077732233305770503080bb8bb05779a0eeeeeeee09a7
e077770eee0a70eeee0970ee0777000028888878877777720555666666660bbb000000000000000075077fff883bb50775050030bb0808077a90888888880a97
0aaaa770e09a770eee0970ee070000002888877888777772b00555666600bbbb00000000000000007077ffff223330577057703080bb8bb779a03332233309a7
0aaaaa70e09aa70eee09a0ee07770000e28877778887772ebbb0555660bbbbbb00000000000000007fffffee55005507757fff00b0bb8bb77a90bbb883bb0a97
0aaaaa70e09aa70eee09a0ee00070000e28877778888882ebbbb00000bbbbbbb00000000000000007ffffeee005500577fffff50b088888779a03332233309a7
09aaaa90e09aa70eee09a0ee07770000ee287777788882eebbbbbbbbbbbbbbbb00000000000000007fffeee0550055077ffffe0500bb8bb77a9a000000009a97
e099990eee09a0eeee09a0ee00700000eee2277778822eeebbbbbbbbbbbbbbbb000000000000000067eee205005500766fffe05050bb8bb667a9a9a9a9a9a976
ee0000eeeee00eeeeee00eee00000000eeeee222222eeeeebbbbbbbbbbbbbbbb0000000000000000567777777777776556777777777777655677777777777765
00777700000770000777770007777700077000000777777000777770077777700077770000777700567777777777776556777777777777655677777777777765
7777777000777000777777707777770007700000077777707777777077777770777777707777777067e2e2e2e2e2e27660000a00000099766750505050505076
770007700777700000007770700007700770077077700000770000007000077077000770770007707e2e000e200e2e2770000000000977a77505050995050507
7700077000077000000777000000077077700770770000007700000000007770770007707700077072e077700770e2e77088888666797aa77050777777775057
770007700007700000777000000777007777777077777770777777700007770077777770777777707e077ee77ee70e2778888a886779aaa77507aa9999aa7507
77000770000770000777000000000770000007700000077077000770007770007700077000000770720eeee88eee02e7788888866779aaa7705aa902209aa057
777777700777777077777770077777700000077007777770777777700077000077777770007777707e20888778880e27788822220009aaa7750aa77770099507
0077770007777770777777700077770000000770077777000777777000770000077777000077770072e08ee77ee802e7788200000a09aaa77059aaaaa7705057
eeee8888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeee0eeeeeeeee7e20777777770e27788000000009aaa7750099999aa70507
eee888800000000088888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e000e070ee000eee72e07777777702e778800000a009aaa77050000229aa7057
ee88880777777777088888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e076006600670eee7e208ee77ee80e27788880000009aaa77507770990aaa507
ee88807777777777708888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e0666d66d6660eee72e08ee77ee802e7788888886779aaa7705aaa7777aa9057
eee880777777777777088eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ee0661111660eeee7e20888778880e27788888a86779aaa775099aaaaa990507
eeee8077766666777708eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ee0d111111d00eee72e200000000e2e77288888866799aa77050599999505057
eee880777000007777088eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e0661111116670ee672e2e2e2e2e2e7660222222200999a66705050225050576
ee88807770888077770888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00766111111660eee567777777777776556777777777777655677777777777765
ee88077770888077770888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e00d111111d0eeee567777777777776556777777777777655677777777777765
eee807777088807777088eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ee0661111660eeee67aaaaaaaaaaa97667000000000000766708888888800076
eee8077770888077770888eeeeeeee8888888888888888eeeeeeeeeeeeeeeee0e0666d66d6660eee7aaaaaaaaaa9a90770000006000000077088888888880007
ee880777708800777608888eeee888888888888888888888888888888888eee0e076006600670eee7aaaaa998a99900770088006600880077778888888888007
e888077770007777708888888888888008888888008888800888800008888ee0e000ee070e000eee7aaaaa7999799027700888d66d8880077660811511f11517
e8880777777777776088888008888807700008807708880770800777708888e0eeeeeee0eeeeeeee7aaa7a999999882770028881188820077000615511f15517
ee880777777777777088000770888077777770807770880777077777770888e0eeeeeeeeeeeeeeee7aa99997999987677000288888820007700866511fff5107
e888077777777777770077777708807777777700777080777707777777708ee0eeeeeeeeeeeeeeee7aaa97999989876770066288882666077008866fffeef007
88880777777666777707777777088077766777077760807776077666666088e00000000e0000000e7aaaa9999999876770666188881660077008886677770ff7
88880777666000677707777777700777600777077708807770777000000888800888880e0888880e7aaa8a98898888677000d888888d00077aa222666668fff7
e8880777000888077707666677700777080777077608807770677777708888800888880e0888880e799999888888886770008882288800077aaaa22222222ee7
e8880777088888077707000077700777080777077088077770067777770888e00888880e0888880e7008088888888867700888266288800779999aaaaaaaaaa7
e8880777088880777607088077707776080777077000777760006667777088e00888880e0888880e70000877888888277008820660288007799999aaaaaaaaa7
ee807777000007777077000777707770880776077777777707700007777088800888880e0888880e70008877766888277002200060022007799999999aaaaaa7
e8807777777777776077777777607770807770777777777607777777776088800888880e0888880e67002666666662766700000000000076679999999aaaaa76
88807777777777760777777776077770807770677777766067777777760888e00888880e0888880e567777777777776556777777777777655677777777777765
8880777777777760067777766006776080776006677760080667777660888ee00888880e0888880eeee0000ee0000eee00000000000000000000000000000000
888067666666660880666660088066088066088006660888800666600888eee00222220e0222220eeee0660ee0660eee00000000000000000000000000000000
888806000000008888000008888800888800888880008888888000088888eee00222220e0222220ee00066000066000e00000000000000000000000000000000
e8888088888888888888888888888888888888888888888888888888888eeee00000000e0000000ee08866888866880e00000000000000000000000000000000
ee88888888888888888888888888888888888888888888888888888888eeeee00888880e0888880ee08855888855880e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000888880e0888880ee07777777777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000222220e0222220ee07777700777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000e0000000ee07777000777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e07777700777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e07777700777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e07777700777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e07777000077770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e07777777777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e07777777777770e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e06666666666660e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000e00000000000000000000000000000000
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
010200000005000050000500005000050000500005000050000500005000050000500005000050000500005000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000001500c1610c1610c1610c1610c1410c1410c1410c1210c1210c1110c1110c1110c1110c1110c11100100001000010000100001000010000100001000010000100001000010000100001000010000100
000200001c6001c6001b6001b6001b6001a6001a6001a6001a6001a6001a600196001960019600186001860018600186000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001132011320113101131011310023000b3000a300083000730006300053000330002300013000030000300013000030000300003000030000300003000030000300003000030000300003000030000300
000100001e5101d5101c5101b5101951017510155101351011510105100f5100e5100d5100d5100d5100d50011500115001150011500115001150012500005000450003500005000050000500005000050000500
000200000c5200c5200b5200851000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001587015870158701187111871118711187111871118701187011870118701187011870118701187011870118701185011850118301183000800008000080000800008000080000800008000080000800
000200001f6501f6601f6701f6701e6501e6501e6501d6501d6301c6301b6201a61019610186101662015620146301263011620106200f6100e6100b6200b6300a62009620086200861008610000000000000000
010100001732017320173101731017310173100b3000a300083000730006300053000330002300013000030000300013000030000300003000030000300003000030000300003000030000300003000030000300
010100001833018330183201832018310023000b3000a300083000730006300053000330002300013000030000300013000030000300003000030000300003000030000300003000030000300003000030000300
010600002952030540305203052230512305123051500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010400002951029510295150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002475023741217311d7311d710007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0104000020750207501f7401d730117300f7200d7200a720097200872007720067200572005710057100070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010700001d5501f550215502355029560005002957000500295300050029520005002951000500295100050029510295012950000500295000050029500005000050000500005000050000500005000050000500
010400001d5501d550295502955029531295302953029511295122951229512295151150211502115021150200500005000050000500005000050000500005000050000500005000050000500005000050018500
010400000533005321053250430004300023000230005300053300532105325003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
01170020021351d7150513521715071351a71509135071351a71521715051351a715021351d7151f72521725021351a715217151d72505135217151d72505135001351d71502155217151d7151a7251a00500135
011700000e57524615115752461513575210051555513575246150e80511555246150e5750e8050c5450e8050e575246150e30024615115752460510005115750c575246150e5752461500000246050b5550c555
01170020021651d7150516521715071651a71509165071651a71521715051651a715021651d715001651d715021651a715217151d72505165217151d72505165001651d71502165217151d7151a7251a00500165
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0113000005a7005a700ca0011a7011a7011a000ea700ea0002a7002a7000a0009a7009a7005a0007a7002a0005a7005a7004a7005a7007a7009a7011a7011a7010a7010a7010a000ea700ea700ea000ca700ca70
011300000505300505295051d5351d515005051a535215150505300505005051d5351c515005051d5351d51505053005051d5351c5151d5051f5351f5151d5051f5351f515005051d5351d5151d5051c5351c515
011300000505300000000000000000000000000000000000050530000000000000000000000000000000000005053000000000000000000000000000000000000505300000000000505300000000000505300000
01130000050531d5051d5351f53521535215152150500500050531d5051d5351f53521535215152150500500050531d5051c5351f53523535235152150500500050531d5051d535215351f5351f5152150500500
0113000005a7005a700ca0011a7011a7011a000ea700ea0002a7002a7000a0009a7009a7005a0007a7002a0005a7005a7004a0005a4005a3009a0011a7011a700ca700ca7010a000aa400aa400ea0009a4009a40
0113000005a5005a500ca0005a5005a5011a0005a5005a5007a5007a5000a0007a5007a5000a0007a5007a5009a5009a5000a000ca500ca5000a0007a5007a500aa500aa5000a0002a5002a5000a0004a5004a50
01130000050002d000290352b0352d0352e0202b0102b0122b0122b0122b0212b0111f001240052400524005260002800028020290202b020280022d0352800228020280002902029021290221d0010000000000
0113000029035307153071529015307153060529015307152b03530715000002b0152d715000002b0152d7152d0352d715306052d01535715357152d01535715240352b7152b715240152d7152d7152601528715
0113000029705307153071529705307153070529705307152b70530715007002b7052d715007002b7052d7152d7052d715307052d70535715357152d70535715247052b7152b715247052d7152d7152670528715
011800000505300505295051d5351d515005051a535215150505300505005051d5351c515005051d5351d51505053005051d5351c5151d5051f5351f5151d5051f5351f515005051d5351d5151d5051c5351c515
011500001d5551d5050c505295752950511505265750e5051a5551a505005052157521505055051f5751a5051d5551d5051c5551d5551f55521565295752950528555285051050526575265050e5052454524505
0115000005155297152971505125297152b715051252b715001552b7152b715001252471524715001252671502155297152971502125297152971502125267150015524715247150012522715247150012526715
011500000505300000000030000000073000030000300000050530000000003000000007300000000030000005053000000000300000000730000000003000000505300003000030000000073000000000300000
01150000055051d5050c505295052950511505265050e5051a5051a505005052150521505055051f5051a5051d5051d5051c5051d5051d505215052950529505285051d5051d5051d50516575185751c5051a575
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 1e 20 26 44
00 1e 20 26 44
00 1e 1f 43 44
00 1e 1f 43 44
00 1e 21 43 44
00 1e 21 43 44
00 1e 1f 43 44
00 22 1f 43 44
00 23 25 43 44
00 23 25 43 44
00 23 24 26 44
02 23 24 26 44
01 1a 42 43 44
00 1a 42 43 44
00 18 19 43 44
02 18 19 43 44
03 27 42 43 44
01 28 29 2a 44
00 28 29 2a 44
00 41 29 2a 44
02 41 29 2a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
