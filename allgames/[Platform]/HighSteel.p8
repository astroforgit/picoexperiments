pico-8 cartridge // http://www.pico-8.com
version 10
__lua__
-- highsteel
-- copyright 2016, chris dawson
-- all rights reserved
-- (www.chrisdawson.ca)
--
-- 2016/12/04
cartsave = false

gamestate = {
  mainmenu = 0,
  intro = 1,
  ingame = 2,
  outtro = 3,
  gameover = 4,
  fadetomain = 5,
}

items = {
  none = 0,
  resist_fire = 1,
  power_jump = 2,
  vine = 3,
  steal = 4,
  swap_players = 7,
  bat = 9,
  hellstones = 10,
  explosive_jump = 11,
  shield = 12,
  freeze = 15,
  stunned = 16,
}
max_item_num = 16

sounds = {
  quake = 0,
  wings_p2 = 1,
  explosion = 2,
  hellstones = 3,
  wings_p1 = 4,
  powerup = 5,
  pickup = 6,
  steal = 7,
  swap_players = 8,
  freeze = 9,
  power_jump = 10,
  vine = 11,
  hurt = 12,
  die = 13,
  bat_timeout = 14,
  item_failed = 15,
  quake2 = 16,
}

-- true == interruptable
channel = {1, 1, 1, 1}

duration = {
  shield = 20,
  explosive_jump = 20,
  power_jump = 20,
  bat = 5,
  resist_fire = 10,
  freeze = 4,
  stunned = 1.5,
}

ai_state_duration = {{2,4}, {2,5}, {1,3}} -- {min,max} idle, attack, avoid

game = {
  state = gamestate.mainmenu,
  players = 1,
  maps = {},
  map_index = 0,
--  debug_map = {7,2}, -- assign map to debug {col 0-7, row 0-1}, else nil
  map_cnt = 24, -- max 24
  score = 0,
  hscore = 0,
  fall_dead_zone = 10,
}

cam = {
  pos = {0,0},
  target = 0,
  buffer = 16,
  fade = 0,
  speed = 30,
}

spikes=false

shake = {
  tid = nil,
  drop_tid = nil,
  delay = 20, -- secs
  drop = 16, -- pixels
}

players = {}
player_start_pos = {}

fire_pal_swap = {
  delay=2,
  cnt=0,
  frame=1,
  maxframe=2,
  map={
    {0, {{15},{14}}},
    {8, {{14},{15}}},
  },
}

-- animation {hs,vs,a,delay}
--   a: frame sequence; use frame# -1 to stop playback
--   delay: #updates per frame (30 updates / sec)
animation = {
  stand={s=64},
  stand_right={s=75},
  reach={s=67},
  hold={s=91},
  fall_1={s=76,a={0,1},delay=4},
  fall_2={s=78},
  jump_up={s=64,a={0,1,2,3,3,3,3,3,3,3,4,4,4,4,4,4,4,-1},delay=1},
  jump={s=69,a={0,1,2,3,4,5,6,-1},delay=5},
  run={s=85,a={0,1,2,3,4,5},delay=4},
  climb_1={s=91,a={0,1},delay=4},
  climb_2={s=93,a={0,1,2,3},delay=4},
  resist_fire={s=49,a={0,1},delay=3},
  explosive_jump={s=54,a={0,1,2,3,4},delay=3},
  power_jump={s=41,a={0,1,2,3,4},delay=3},
  shield={s=33,a={0,1,2,3},delay=3},
  bat={s=59,a={0,1},delay=5},
  rip={s=105},
  vine={s=2},
  dead={s=97,a={0,1,2,3,4,5,6,7,-1},delay=3},
  freeze={s=37},
  stunned={s=79,a={0,1,2,3,4,5},delay=4},
  explosion={s=23,a={0,1,2,3,4,-1},delay=3},
  trip={s=95},
}

function reset_game()
  game.state = gamestate.mainmenu
  game.score = 0
  if (cartsave) then
    game.hscore = dget(0)
  end
  cam.pos = {0,0}
  cam.target = 0
  cam.speed = 30
  cam.autoscroll = nil
  spikes = false
  shake.tid = nil
  shake.drop_tid = nil
  shake.drop = 16
  player_start_pos = {}
  game.maps = shuffle_maps(1,game.map_cnt-1) -- exclude map 0
  game.map_index = 0
  game.map0 = load_map({0,0},0) -- the only map with ground
  game.map1 = load_next_map(-1)
  game.map2 = load_next_map(-2)
  players[1] = new_player(1, 10)
  players[1].pos = player_start_pos[1]
  players[1].optional.standing = 0
  players[2] = new_player(2, 7)
  players[2].pos = player_start_pos[2]
  players[2].optional.standing = 0
  music(2,0,3)
end

function _init()
  cartsave = cartdata("chrisdawson_highsteel")
  reset_game()
end

function sethscore()
  game.hscore = max(game.score, game.hscore)
  if (cartsave) then
    dset(0, game.hscore)
  end
end

function _update()
  update_timers()
  if (game.state == gamestate.mainmenu) then
    local b = btnp()
    if (band(b,3) > 0) or (band(shr(b,8),3) > 0) then
      game.players = (game.players % 2) + 1
    elseif (band(b,48) > 0) or (band(shr(b,8),48) > 0) then
      game.state = gamestate.intro
      add_timer_secs(1, function(tid) game.state = gamestate.ingame; end, 1)
      shake.tid = add_timer_secs(2, function(tid) if (shake.tid == tid) then shake_and_drop(8, true); end; end, 1)
      if (game.players < 2) then
        add_timer_secs(2, function(tid) players[2].ai = 1; bat(players[2], true); end, 1)
        add_timer_secs(5, function(tid) ai_state(players[2]); end, 1)
      end
    end
  else
    if (game.state == gamestate.gameover) then
      local b = btnp()
      if (band(b,48) > 0) or (band(shr(b,8),48) > 0) then
        game.state = gamestate.fadetomain
        game.fadetomainmenu_tid = add_timer(0, fade_to_mainmenu, 1)
        music(-1, 1000)
      end
    end

    if (game.state == gamestate.ingame) then
      process_btn()
    else
      players[1].optional.btn = 0
      players[2].optional.btn = 0
    end
    update_entities()
    if (game.state == gamestate.ingame) then
      local minpos = (game.players == 2) and min(players[1].pos[2], players[2].pos[2]) or players[1].pos[2] -- prevent ai from moving camera
--      local minpos = (game.players == 2) and ((cam.autoscroll) and cam.pos[2] or 100) or players[1].pos[2] -- prevent ai and 2-player games from moving camera
      update_camera(minpos)
    end
  end
end

function update_entities()
  foreach(players, update_player)
  foreach(game.map0.items, update_item)
  foreach(game.map1.items, update_item)
  foreach(game.map0.decals, update_item)
  foreach(game.map1.decals, update_item)
end

function update_item(e)
  if (e.update) e.update(e)
  if (e.anim) update_animation(e.anim)
end

function update_player(p)
  if (not p.optional.dead and (game.state == gamestate.ingame)) then
    if (not p.active_items[items.freeze]) then
      if (p.anim[1] == animation.bat) then
        update_bat_state(p)
      else
        update_player_state(p)
      end

      p2 = opponent(p)
      if (is_colliding(p, p2)) then
        if (not p.active_items[items.stunned] and not p2.active_items[items.stunned] and not p2.optional.defend and not p2.active_items[items.shield] and not p2.optional.falling) then
          if (p.optional.trip) then
            p2.optional.hurt = (p2.optional.standing and (p2.vel[1] != 0) and (p2.vel[2] == 0))
          elseif (p.optional.attack) then
            if (p.ai) then
              ai_state(p) -- stop attacking
              local steal_chance = (ai_can_use_item(p2.item)) and 50 or 35
              if (p2.item and (rnd(100) < steal_chance)) then
                steal(p)
              else
                p2.optional.hurt = true
              end
            else
              p2.optional.hurt = true
            end
          end
        else
          if (p.ai) then
            ai_state(p) -- stop attacking (so bat won't hover over stunned player until he can hurt him)
          end
        end
      end

      if (item_collision(p, game.map0.items, nil)) beep()
      if (item_collision(p, game.map1.items, nil)) beep()
    else
      play_sound(p, nil)
    end

    apply_player_limits(p)
  else
    play_sound(p, nil)
  end

  if (p.anim) then
    if (p.optional.flashing) then
      p.optional.flashing[1] -= 1
      if (p.optional.flashing[1] <= 0) then
        p.optional.flashing = nil
        p.optional.hidden = nil
      else
        p.optional.flashing[3] -= 1
        if (p.optional.flashing[3] <= 0) then
          p.optional.flashing[3] = p.optional.flashing[2]
          p.optional.hidden = not p.optional.hidden
        end
      end
    end

    if (not p.active_items[items.freeze]) then
      update_animation(p.anim)
      for i=1,max_item_num do
        if (p.active_items[i]) update_animation(p.active_items[i])
      end
    end
  end
end

function update_bat_state(p)
  if (p.optional.hurt) then
    p.optional.hurt = nil
    activate_item(p, "stunned", duration.stunned)
    play_sound(p, sounds.hurt, 2)
  end

  if (not p.active_items[items.stunned]) then
    p.vel[1] = 0; p.vel[2] = 0

    local sound = nil
    if (band(p.optional.btn,15) > 0) then
      sound = (p == players[1]) and sounds.wings_p1 or sounds.wings_p2
      p.optional.dir = p.optional.btn
      if (band(p.optional.btn,3) > 0) then
        p.vel[1] = (band(p.optional.btn, 1) == 1) and -p.speed or p.speed
      end
      if (band(p.optional.btn,12) > 0) then
        p.vel[2] = (band(p.optional.btn, 4) == 4) and -p.speed or p.speed
      end
    end
    play_sound(p, sound, 0)

    -- apply velocity
    p.pos[1] += p.vel[1] * 0.033
    p.pos[2] += p.vel[2] * 0.033

    if (band(p.optional.btn,32) == 32) and p.item and p.item.activate then
      p.item.activate(p)
    end
  end
end

function update_player_state(p)
  p.optional.jump_delay = (p.optional.jump_delay and (p.optional.jump_delay > 0)) and p.optional.jump_delay-1 or nil

  if (p.optional.hurt and not p.optional.falling) then
    p.optional.hurt = nil
    p.tid.jump_tid = nil
    p.vel[1] = 0; p.vel[2] = -20
    set_animation(p, animation.fall_1)
    p.optional.falling = p.pos[2]
    play_sound(p, sounds.hurt, 2)
  end

  if (p.optional.falling) then
    if (p.optional.standing or p.optional.grabbing) and (p.pos[2] - p.optional.falling > game.fall_dead_zone) then
      p.optional.falling = nil
      if (p.optional.standing) then
        p.pos[2] += p.optional.standing
        set_animation(p, animation.fall_2)
        activate_item(p, "stunned", duration.stunned)
      end
    else
      p.vel[1] = 0
      p.vel[2] = min(60, p.vel[2] + 2) -- gravity per frame
      p.pos[2] += p.vel[2] * 0.033
    end
  elseif (p.active_items[items.stunned]) then
  elseif (p.optional.jumping) then
    -- jumping: h(t) = vt + (gt**2) / 2
    local grabit = (band(p.optional.btn,15) == 4) -- press up to grab
    if (p.optional.standing and (p.vel[2] >= -10)) or (p.optional.grabbing and (grabit or (p.vel[2] >= -10))) then
      p.optional.jumping = nil
      set_animation(p, animation.stand) -- just to reset the jumping animation
    else
      p.vel[1] = max(abs(p.vel[1]) - 0.5, 0) * sign(p.vel[1])
      p.vel[2] += 2 -- gravity per frame
      p.pos[1] += p.vel[1] * 0.033
      p.pos[2] += p.vel[2] * 0.033
    end
  else -- not falling nor jumping nor stunned
    if not p.optional.standing and not p.optional.grabbing then
      set_animation(p, animation.fall_1)
      p.optional.falling = p.pos[2] - game.fall_dead_zone
      p.vel[1] = 0; p.vel[2] = 30
      return
    end

    -- velocity/position/direction
    p.vel[1] = 0; p.vel[2] = 0
    if (band(p.optional.btn,4) == 4) then
      p.optional.dir = p.optional.btn
      if p.optional.grabbing then
        if not is_down_color(p.optional.grabbing) then
          p.vel[2] = -(p.speed * 0.7)
        end
      end
    end
    if (band(p.optional.btn,8) == 8) then
      p.optional.dir = p.optional.btn
      if p.optional.grabbing then
        if not is_down_color(p.optional.grabbing) then
          if not p.optional.standing then
            p.vel[2] = p.speed
          else
            p.pos[2] += p.optional.standing
          end
        end
      end
    end
    if (band(p.optional.btn,3) > 0) then
      p.optional.dir_change = ((band(p.optional.dir,3) > 0) and (band(p.optional.dir,3) != band(p.optional.btn,3))) and 5 or p.optional.dir_change
      p.optional.dir = p.optional.btn
      local s = (p.optional.grabbing and not p.optional.standing) and (p.speed / 2) or p.speed
      p.vel[1] = (band(p.optional.btn, 1) == 1) and -s or s
    end
    if ((band(p.optional.btn,16) == 16) and not p.optional.jump_delay) then
      p.optional.jump_delay = 15
      speed_multiplier = (p.active_items[items.power_jump]) and 2 or 1
      p.vel[1] = (band(p.optional.dir, 1) == 1) and -p.speed*speed_multiplier or ((band(p.optional.dir, 2) == 2) and p.speed*speed_multiplier or 0)
      p.vel[2] = -30*speed_multiplier
      if (p.optional.grabbing and (p.vel[1] == 0)) then
        if (is_down_color(p.optional.grabbing)) then
          p.vel[2] = 0 -- no pole climbing allowed
        else
          p.vel[2] = p.vel[2] * 0.8 -- slow jump climbing for everything else
        end
      end
      p.optional.jumping = true
      p.tid.jump_tid = add_timer(40*speed_multiplier, function(tid) if ((p.tid.jump_tid == tid) and p.optional.jumping) then p.optional.jumping = nil; p.optional.falling = p.pos[2] - game.fall_dead_zone; set_animation(p, animation.fall_1);  end; end, 1)
      if (p.active_items[items.explosive_jump] and p.optional.standing) do_explosive_jump(p)
      if (p.active_items[items.power_jump]) play_sound(p, sounds.power_jump)
    end

    -- animation and sfx
    local anim = nil
    if (band(p.optional.btn,16) == 16) then
      anim = (band(p.optional.dir, 3) > 0) and animation.jump or animation.jump_up
      set_animation(p, anim)
    elseif (band(p.optional.btn,3) > 0) then
      anim = (p.optional.grabbing) and animation.climb_1 or animation.run
      set_animation(p, anim)
    elseif (band(p.optional.btn,4) == 4) then
      if p.optional.grabbing then
        if not is_down_color(p.optional.grabbing) then
          set_animation(p, animation.climb_1)
        else
          anim = (p.optional.standing) and animation.reach or animation.hold
          set_animation(p, anim)
        end
      else
        set_animation(p, animation.reach)
      end
    elseif (band(p.optional.btn,8) == 8) then
      if p.optional.grabbing then
        if not is_down_color(p.optional.grabbing) then
          if not p.optional.standing then
            set_animation(p, animation.climb_1)
          end
        else
          anim = (p.optional.standing) and animation.reach or animation.hold
          set_animation(p, anim)
        end
      else
        set_animation(p, animation.stand)
      end
    else -- no button press
      if (not p.item and p.optional.standing and band(p.optional.btn,63) == 32) then
        set_animation(p, animation.trip)
      else
        if p.optional.grabbing then
          anim = (p.optional.standing) and animation.reach or animation.hold
          set_animation(p, anim)
        else
          anim = (band(p.optional.dir, 3) > 0) and animation.stand_right or animation.stand
          set_animation(p, anim)
        end
      end
    end

    -- apply velocity (if left/right dir did not just change)
    if (p.optional.dir_change and (p.optional.dir_change > 0)) then
      p.optional.dir_change -= 1
    end
    if (not p.optional.dir_change or (p.optional.dir_change <= 0)) then
      p.pos[1] += p.vel[1] * 0.033
      p.pos[2] += p.vel[2] * 0.033
    end

    -- auto
    if not p.optional.grabbing then
      if p.optional.standing then
        p.pos[2] += p.optional.standing
      end
    else
      if is_down_color(p.optional.grabbing) then
        if not p.optional.standing then
          p.pos[2] += 1
        else
          p.pos[2] += p.optional.standing
        end
      end
    end
  end

  p.optional.trip = (not p.item and p.optional.standing and (band(p.optional.btn,63) == 32))
  p.optional.activate_delay = (p.optional.activate_delay and (p.optional.activate_delay > 0)) and p.optional.activate_delay-1 or nil
  if ((band(p.optional.btn,32) == 32) and not p.optional.activate_delay) then
    if (p.item and p.item.activate) then
      p.optional.activate_delay = 15
      p.item.activate(p)
    end
  end
end

function apply_player_limits(p)
  p.pos[1] = min(max(p.pos[1], 0), 120)
  p.pos[2] = max(cam.pos[2], p.pos[2])
  if ((p.pos[2] - cam.pos[2]) >= 119) then
    p.pos[2] = cam.pos[2] + 119
    if (game.state == gamestate.ingame) and not p.ai then
      if (not p.optional.dead) then
        reset_player(p)
        p.optional.dead = true
        p.item = {anim={animation.rip,0,0}}
        set_animation(p, animation.dead)
        play_sound(opponent(p), nil)
        play_sound(nil, sounds.die, 2)

        shake.tid = nil
        shake.drop_tid = nil

        if (game.players == 1) then
          sethscore()
        end

        game.state = gamestate.outtro
        music(-1, 500)
        add_timer_secs(2, function(tid) game.state = gamestate.gameover; music(0, 0, 15); end, 1)
        game.fadetomainmenu_tid = add_timer_secs(8, function(tid) if (tid == game.fadetomainmenu_tid) then game.state = gamestate.fadetomain; fade_to_mainmenu(); end; end, 1)
      end
    end
  end
end

function update_animation(anim)
  if (anim[1] and anim[1].a) then
    if (anim[1].a[anim[2]] != -1) then
      anim[3] -= 1
      if (anim[3] <= 0) then
        anim[3] = anim[1].delay
        anim[2] = (anim[2] < #anim[1].a) and (anim[2]+1) or 1
      end
    end
  end
end

function update_camera(pos, buffer)
  buffer = buffer or cam.buffer
  d = flr(cam.pos[2] + buffer - pos)
  cam.target = min(cam.target, cam.pos[2] - d)

  local speed = 0
  local d = flr(cam.pos[2] - cam.target)
  if (d > 0) then
    speed = (cam.speed * 0.033)
--    speed = sign(d) * (1 + flr(abs(d) / 10))
  end
  cam.pos[2] -= speed
  game.score = abs(flr((cam.pos[2]) / 10))

  local offset = calc_offset(cam.pos[2])
  if (offset < game.map1.offset) then
    scale_difficulty(abs(offset))
    game.map0 = game.map1
    game.map1 = game.map2
    game.map2 = load_next_map(offset-1)
--    shake.tid = add_timer_secs(shake.delay, function(tid) if (shake.tid == tid) then shake_and_drop(shake.drop); end; end, 1)
--    printh("stat mem: " .. flr(stat(0)) .. "k, cpu: " .. flr(stat(1) * 100) .. "%")
  end
end

function scale_difficulty(v)
  if (game.players < 2) then
    shake.delay = max(10, 20 - (v / 2))
    shake.drop = min(32, 16 + v)
    ai_state_duration[1][1] = max(1, (2 - v / 10)) -- idle state duration (default 2)
    ai_state_duration[1][2] = min(2, (4 - v / 10)) -- idle state duration (default 4)
    ai_state_duration[2][1] = min(4, (2 + v / 10)) -- attack state duration (default 2)
    ai_state_duration[2][2] = min(7, (5 + v / 10)) -- attack state duration (default 5)
  end
end

function calc_offset(pos)
  return flr(pos / 128)
end

function palette_swap()
  fire_pal_swap.cnt -= 1
  if (fire_pal_swap.cnt < 0) then
    fire_pal_swap.cnt = fire_pal_swap.delay
    fire_pal_swap.frame = (fire_pal_swap.frame < fire_pal_swap.maxframe) and (fire_pal_swap.frame + 1) or 1
  end

  for i=1,#fire_pal_swap.map do
    for c=1,#fire_pal_swap.map[i][2][fire_pal_swap.frame] do
      pal(fire_pal_swap.map[i][2][fire_pal_swap.frame][c], fire_pal_swap.map[i][1])
    end
  end
end

function get_state_color(p)
  return p.clr
end

function draw_btn(x,y,char,n,fx,fy)
  draw_sprite(28,x,y)
  if (char) then
    print(char,x+2,y+2,1)
  else
    draw_sprite(n,x,y,1,1,fx,fy)
  end
end

function _draw()
  fade(cam.fade)
  if (game.state == gamestate.mainmenu) then
    camera()
    rectfill(0,0,127,127,0)
    spr(192,20,8,11,4)
    pal(6,10) -- todo redraw player all white
    pal(7,10)
    sspr(40,40,8,8,110,8,16,16)
    pal(7,6)
    pal(6,6) -- todo redraw player all white
    if (game.players == 1) then
      sspr(96,24,8,8,12,38,16,16)
      print_center("high score: " .. game.hscore, 40, 1)
    else
      sspr(104,40,8,8,12,38,16,16)
    end
    pal()
    if (game.players == 1) then
      print_center("< 1 player >", 48, 7)
    else
      print_center("< 2 players >", 48, 7)
    end
    x=79; y=64
    draw_btn(x,y,"b")
    print("use item", x+15, y+2, 7)
    x-=10; y+=10
    draw_btn(x,y,"a")
    print("jump", x+15, y+2, 7)
    x-=38; y-=7
    draw_btn(x,y,null,14)
    draw_btn(x+14,y,null,14,true,false)
    draw_btn(x+7,y-8,null,15)
    draw_btn(x+7,y+8,null,15,false,true)
    print("move", x-23, y+2, 7)
    for x=0,7 do
      sspr(48, 8, 8, 8, x*16, 96, 16, 16)
    end
    local y=81
    print_center("press    to start", y+10, 7)
    draw_btn(54,y+8,"a")
    print_center("(c) 2016, chris dawson", 115, 5)
    print_center("music by gruber_music", 123, 5)
  else
    palette_swap()

    camera()
    rectfill(0,0,127,127,0)
    camera(cam.pos[1],cam.pos[2]-(game.map1.offset*128))
    draw_map(game.map1)
    camera(cam.pos[1],cam.pos[2]-(game.map0.offset*128))
    draw_map(game.map0)

    foreach(game.map1.decals, draw_entity)
    foreach(game.map0.decals, draw_entity)

    if (spikes) then
      palt(0,false)
      rectfill(0, cam.pos[2]-(game.map0.offset*128)+124, 127, cam.pos[2]-(game.map0.offset*128)+127, 0)
      palt(0,true)
    end

    if (not players[1].optional.dead) player_pget(players[1])
    if (not players[2].optional.dead) player_pget(players[2])

    for i=1,#game.map0.items do
      if game.map0.items[i].pget then
        game.map0.items[i].pget(game.map0.items[i])
      end
    end
    for i=1,#game.map1.items do
      if game.map1.items[i].pget then
        game.map1.items[i].pget(game.map1.items[i])
      end
    end

    draw_entities()

    draw_hud()
  end
end

function draw_sprite(n,x,y,cx,cy,fx,fy)
  cx = cx or 1
  cy = cy or 1
  local swap = fget(n,7)
  if (swap) then
    palt(0,false)
    palt(7,true)
  end
  spr(n, x, y, cx, cy, fx, fy)
  if (swap) then
    palt(0,true)
    palt(7,false)
  end
end

function draw_map(m)
  map(m.pos[1],m.pos[2],0,0,16,16,1)
end

function draw_spikes()
  for x=0,15 do
    draw_sprite(22,x*8, cam.pos[2] - (game.map0.offset*128) + 120, 1, 1)
  end
end

function draw_entities()
  foreach(game.map1.items, draw_entity)
  foreach(game.map0.items, draw_entity)

  if (game.state != gamestate.intro) then
    pal(6, players[1].clr) -- todo redraw sprites all white
    draw_entity(players[1])
    pal(6, players[2].clr) -- todo redraw sprites all white
    draw_entity(players[2])
    pal(6,6)
  end
end

function draw_entity(e)
  if (e and e.pos and e.anim[1] and (not e.optional or not e.optional.hidden)) then
    if (e.clr) pal(7, e.clr)
    draw_animation(e, e.anim)
    pal(7,7)

    if (e.active_items and not e.optional.dead) then
      for i=1,max_item_num do
        if (e.active_items[i]) draw_animation(e, e.active_items[i])
      end
    end
  end
end

function draw_animation(e, anim)
  local s = anim[1].s
  local s_offset = 0
  if (anim[1].a) then
    if (anim[1].a[anim[2]] == -1) then
      s_offset = anim[1].a[anim[2]-1]
    else
      s_offset = anim[1].a[anim[2]]
    end
  end
  local flipx = (e.optional) and (band(e.optional.dir, 1) == 1)
  draw_sprite(s+s_offset,e.pos[1],e.pos[2]-(game.map0.offset*128),1,1,flipx,flipy)
end

function draw_hud()
  rectfill(cam.pos[1]+1, cam.pos[2]-(game.map0.offset*128)+0, cam.pos[1]+10, cam.pos[2]-(game.map0.offset*128)+9, 0)
  rect(cam.pos[1]+1, cam.pos[2]-(game.map0.offset*128)+0, cam.pos[1]+10, cam.pos[2]-(game.map0.offset*128)+9, players[2].clr)
  if (players[2].item) then
    draw_sprite(players[2].item.anim[1].s, cam.pos[1]+2, cam.pos[2]-(game.map0.offset*128)+1)
  end
  rectfill(cam.pos[1]+117, cam.pos[2]-(game.map0.offset*128)+0, cam.pos[1]+126, cam.pos[2]-(game.map0.offset*128)+9, 0)
  rect(cam.pos[1]+117, cam.pos[2]-(game.map0.offset*128)+0, cam.pos[1]+126, cam.pos[2]-(game.map0.offset*128)+9, players[1].clr)
  if (players[1].item) then
    draw_sprite(players[1].item.anim[1].s, cam.pos[1]+118, cam.pos[2]-(game.map0.offset*128)+1)
  end
  if (game.players == 1) then
    print_center("" .. game.score, 0, players[1].clr)
  end

  if (spikes) draw_spikes()

  rect(cam.pos[1]+0, cam.pos[2]-(game.map0.offset*128)+0, cam.pos[1]+0, cam.pos[2]-(game.map0.offset*128)+127, 1)
  rect(cam.pos[1]+127, cam.pos[2]-(game.map0.offset*128)+0, cam.pos[1]+127, cam.pos[2]-(game.map0.offset*128)+127, 1)

  if (game.state == gamestate.gameover) then
    if (game.players == 1) then
      rectfill(cam.pos[1]+29,cam.pos[2]-(game.map0.offset*128)+49,cam.pos[1]+98,cam.pos[2]-(game.map0.offset*128)+76,0)
      print_center("game over", 52, 8)
      print_center("score: " .. game.score, 60, players[1].clr)
      print_center("high score: " .. game.hscore, 68, players[1].clr)
    else
      rectfill(cam.pos[1]+42,cam.pos[2]-(game.map0.offset*128)+57,cam.pos[1]+85,cam.pos[2]-(game.map0.offset*128)+68,0)
      print_center("game over", 60, 8)
    end
  end

  -- debug
--  local p = players[1]
--  print_center("timers: " .. #timers, 0, 7)
--  print_center("cam pos " .. cam.pos[2] .. ", screen num " .. cam.screen_num, 0, 7)
--  if (players[1].optional.hurt) print_center("ouch!", 10, players[1].clr)
--  if (players[2].optional.hurt) print_center("ouch!", 20, players[2].clr)
--  if (p.optional.grabbing) print_center("grabbing " .. p.optional.grabbing, 20, 8)
--  if (p.optional.standing) print_center("standing", 30, 8)
--  print_center("p1 pos " .. players[1].pos[2], 40, 7)
end

-- max 8 maps wide by 4 high
function shuffle_maps(min, max)
  local result = {}
  local row, col, num
  local cnt = max - min + 1

  -- create array
  for i=1,cnt do
    num = min + i - 1
    col = (num % 8)
    row = flr(num / 8)
    result[i] = {col,row}
  end

  -- shuffle
  local tmp, i2
  for i=1,cnt do
    i2 = flr(rnd(cnt))+1
    tmp = result[i]
    result[i] = result[i2]
    result[i2] = tmp
  end

--  for i=1,cnt do
--    printh("shuffled: " .. result[i][1] .. "," .. result[i][2])
--  end

  return result;
end

function load_next_map(offset)
  if (game.debug_map) return load_map(game.debug_map, offset)

  game.map_index += 1
  if (game.map_index > #game.maps) then
    game.maps = shuffle_maps(1,game.map_cnt-1)
    game.map_index = 1
  end
  return load_map(game.maps[game.map_index], offset)
end

function load_map(pos, offset)
  local map = {pos={pos[1]*16, pos[2]*16}, offset=offset, decals={}, items={}}
  local index = 0
  for x=0,15 do
    for y=0,15 do
      index = mget(map.pos[1]+x,map.pos[2]+y)
      if (not fget(index,0)) then -- it is not a map tile
        if (fget(index,6)) then
          local num = (fget(index,7)) and 2 or 1
          player_start_pos[num] = {x*8, y*8 + (offset*128)}
        else
          local item_num = get_item_number(index)
          if (item_num > 0) then -- valid items are numbered 1+
            local item = new_item(item_num, {{s=index},0,0})
            item.pos[1] = x*8
            item.pos[2] = y*8 + (offset*128)
            map.items[#map.items+1] = item
  --          printh("added item num " .. item.number .. " : " .. item.pos[1] .. "," .. item.pos[2])
          end
        end
      end
    end
  end
  return map
end

function new_item(num, anim)
  local item = {
    number = num,
    pos = {0,0},
    vel = {0,0},
    anim = anim or {nil,0,0},
    remove_on_collide = function(c) return true; end,
    collide = generic_collide,
  }
  if num == 1 then
    item.activate = function(p) p.item = nil; activate_item(p, "resist_fire", duration.resist_fire); play_sound(p, sounds.powerup); end
  elseif num == 2 then
    item.activate = function(p) p.item = nil; activate_item(p, "power_jump", duration.power_jump); play_sound(p, sounds.powerup); end
  elseif num == 3 then
    item.activate = function(p) p.item = nil; grow_vine(p); play_sound(p, sounds.vine); end
  elseif num == 4 then
    item.activate = function(p) p.item = nil; steal(p); end
  elseif num == 7 then
    item.activate = function(p) p.item = nil; begin_swap_players(p); end
  elseif num == 9 then
    item.activate = function(p) p.item = nil; bat(p, true, duration.bat); play_sound(p, sounds.powerup); end
    item.clr = 13
  elseif num == 10 then
    item.activate = function(p) p.item = nil; hellstones(p); play_sound(p, sounds.powerup); end
  elseif num == 11 then
    item.activate = function(p) p.item = nil; activate_item(p, "explosive_jump", duration.explosive_jump); play_sound(p, sounds.powerup); end
  elseif num == 12 then
    item.activate = function(p) p.item = nil; activate_item(p, "shield", duration.shield); play_sound(p, sounds.powerup); end
  elseif num == 15 then
    item.activate = function(p) p.item = nil; freeze(p); end
  end
  return item
end

function generic_collide(c)
  local collision = (not c[1].ai and not has_item(c[1], c[2]))
  if collision then
    play_sound(c[1], sounds.pickup, 0)
    c[1].item = c[2]
  end
  return collision
end

function has_item(p, item)
  return p and item and p.item and p.item.number == item.number
end

-- activate duration-effect item, duration == secs (deactivate if secs is nil or 0)
function activate_item(p, name, secs)
  secs = secs or 0
  if (secs > 0) then
    p.active_items[items[name]] = {animation[name],1,animation[name].delay}
    p.tid[name] = add_timer_secs(secs, function(tid) if (p.tid[name] == tid) then activate_item(p, name); end; end, 1)
  else
    p.active_items[items[name]] = nil
    p.tid[name] = nil
  end
end

function freeze(p)
  local p2 = opponent(p)
  if (not p2.active_items[items.shield]) then
    activate_item(p2, "freeze", duration.freeze)
    play_sound(p2, sounds.freeze)
  else
    play_sound(p, sounds.item_failed)
  end
end

-- if secs != nil, automatically call bat(p, false) after secs delay (player will flash for last 3 secs)
function bat(p, to_bat, secs)
  if (not to_bat) then
    set_animation(p, animation.stand)
    p.diameter = 7
    p.tid.bat_tid = nil -- the timer may not have expired
    p.vel[1] = 0; p.vel[2] = 0
  else
    set_animation(p, animation.bat)
    p.diameter = 5
    p.tid.jump_tid = nil -- in case player was jumping (prevent jump timer)
    p.optional.falling = nil -- in case player was falling as he transformed into a bat
  end
  p.optional.attack = to_bat
  p.optional.defend = to_bat

  if (secs) then
    p.tid.bat_tid = add_timer_secs(secs-3, function(tid) if (p.tid.bat_tid == tid) then p.optional.flashing = {90, 2, 0}; play_sound(p, sounds.bat_timeout, 2); p.tid.bat_tid = add_timer_secs(3, function(tid) if (p.tid.bat_tid == tid) then bat(p, false); end; end, 1); end; end, 1)
  end
end

function new_player(number, clr)
  return {
    number = number,
    clr = clr,
    pos = {0,0},
    vel = {0,0},
    speed = 30,
    diameter = 6,
    anim = {animation.stand,0,0},
    optional = {},
    tid = {},
    active_items = {},
  }
end

function reset_player(p)
  p.vel = {0,0}
  p.anim = {animation.stand,0,0}
  p.item = nil
  p.optional = {}
  p.tid = {}
  p.active_items = {}
end

function opponent(p)
  return (p == players[1]) and players[2] or players[1]
end

function get_item_number(sprite)
  return ((fget(sprite,1)) and 16 or 0) + ((fget(sprite,2)) and 8 or 0) + ((fget(sprite,3)) and 4 or 0) + ((fget(sprite,4)) and 2 or 0) + ((fget(sprite,5)) and 1 or 0)
end

-- entity.anim = {animation, frame, delay}
function set_animation(entity, animation)
  local result = false
  if (entity.anim[1] ~= animation) then
    entity.anim[1] = animation
    entity.anim[2] = 1
    entity.anim[3] = animation.delay
    result = true
  end
  return result
end

-- return all targets colliding with p
-- exclude eg. {[players[1]]=true}
function item_collision(p, items, exclude)
  local result = {}
  local i = 1
  local c = nil
  local colliding = nil
  while i <= #items do
    local obj = items[i]
    if (obj and (not exclude or not exclude[obj])) then
      colliding = is_colliding(p, obj)
      if colliding then
        c = {p,obj}
        colliding = (not c[2].collide or c[2].collide(c))
        if colliding then
          result[#result+1] = c
          if (obj.remove_on_collide and obj.remove_on_collide(result[#result])) then
            items[i] = items[#items]
            items[#items] = nil
            i -= 1
          end
        end
      end
    end
    i += 1
  end

--  for i=1,#result do
--    if (result[i][2].collide) then
--      result[i][2].collide(result[i])
--    end
--  end

  return (#result > 0) and result or nil
end

function is_colliding(e1, e2)
  local d1 = e1.diameter or 7
  local d2 = e2.diameter or 7
  local b = 8 - (((8 - d1) / 2) + ((8 - d2) / 2))
  return (abs(e1.pos[1] - e2.pos[1]) <= b) and (abs(e1.pos[2] - e2.pos[2]) <= b)
end

function grow_vine(p)
  for y=0,7 do
    local x_pos = p.pos[1]
    local y_pos = p.pos[2]-(y*8)
    local offset = calc_offset(y_pos)
    local m = map_for_offset(offset)
    add_timer(y, function(tid) m.decals[#m.decals+1] = {pos={x_pos, y_pos}, anim={animation.vine,0,0}}; end, 1)
--    printh("decal added to map " .. m.offset)unused
  end
end

function steal(p)
  local p2 = opponent(p)
  if (p2.item and not p2.active_items[items.shield]) then
    play_sound(p, sounds.steal)
    local item = p2.item
    p2.item = nil
    add_timer(15, function(tid) p.item = item; end, 1)
  else
    play_sound(p, sounds.item_failed)
  end
end

function begin_swap_players(p)
  local p2 = opponent(p)
  if (not p2.active_items[items.shield]) then
    play_sound(p, sounds.swap_players)
    activate_item(p, "freeze", 1)
    activate_item(p2, "freeze", 1)
    if (p.optional.jumping) delay_timer_secs(p.tid.jump_tid, 1) -- frozen for 1s
    if (p2.optional.jumping) delay_timer_secs(p2.tid.jump_tid, 1) -- frozen for 1s
    p.active_items[items.stunned] = nil
    p.optional.flashing = {30, 4, 4}
    p2.optional.flashing = {30, 4, 0}
    add_timer_secs(1, function(tid) swap_player_positions(); end, 1)
  else
    play_sound(p, sounds.item_failed)
  end
end

function swap_player_positions()
  if (not players[1].optional.dead and not players[2].optional.dead) then
    local tmp = players[1].pos
    players[1].pos = players[2].pos
    players[2].pos = tmp
    players[1].optional.falling = nil
    players[2].optional.falling = nil
--    players[1].optional.jumping = nil
--    players[2].optional.jumping = nil
  end
end

function do_explosive_jump(p)
  play_sound(p, sounds.explosion)
  local offset = calc_offset(p.pos[2])
  local m = map_for_offset(offset)
  m.decals[#m.decals+1] = {pos={p.pos[1],p.pos[2]+5}, anim={animation.explosion,1,animation.explosion.delay}}
end

function get_loop_start(sfx)
  return peek(0x3200 + 68*sfx + 66)
end

function get_loop_end(sfx)
  return peek(0x3200 + 68*sfx + 67)
end

function get_channel(ch, priority)
  return ((stat(16+ch) < 0) or (channel[ch+1] < priority)) and ch or nil
end

function play_sound(p, sound, priority)
  if (not sound) then
    if (p) then
      p.optional.loop = nil
      sfx(-2, p.number + 1)
    end
  else
    priority = priority or 1
    local ch = p and (get_channel(p.number + 1, priority)) or (get_channel(2, priority) or get_channel(3, priority))
    if (ch) then
      p = p or players[ch - 1]
      if (sound != p.optional.loop) then
        if (game.state != gamestate.gameover and game.state != gamestate.fadetomain) then
          local loop = get_loop_end(sound) - get_loop_start(sound) > 0
          p.optional.loop = (loop) and sound
          channel[ch+1] = priority
          sfx(sound, ch)
        end
      end
    end
  end
  return p
end

function place_bomb(p)
  local offset = calc_offset(p.pos[2])
  local m = map_for_offset(offset)
  m.items[#m.items+1] = {pos=p.pos, anim={animation.bomb,1,animation.bomb.delay}}
end

function hellstones(p)
  p2 = opponent(p)
  local offset = calc_offset(p2.pos[2])
  local m = map_for_offset(offset)
  for i=0,5 do
    local stone = new_item(0, {{s=3},0,0})
    stone.clr = p2.clr
    stone.diameter = 3
    stone.pos[1] = flr(rnd(121))
    stone.pos[2] = cam.pos[2] - 8
    stone.remove_on_collide = nil
    stone.collide = hellstone_collision
    stone.update = hellstone_update
    stone.pget = hellstone_pget
    m.items[#m.items+1] = stone
  end
end

function hellstone_collision(c)
  local collision = ((c[1].clr == c[2].clr) and not c[1].active_items[items.shield] and not c[1].optional.falling and not c[1].active_items[items.stunned])
  c[1].optional.hurt = c[1].optional.hurt or collision
  return collision
end

function hellstone_update(e)
  if (e.pos[2] - cam.pos[2] > 128) return

  if (e.standing and (e.vel[2] >= 5)) then
    if (rnd(100) < 50) then
      e.pos[2] += e.standing
      e.vel[1] = (rnd(100) < 50) and -30 or 30
      e.vel[2] = -30
      play_sound(nil, sounds.hellstones) -- bounce sound
    end
  end

  e.vel[1] = max(abs(e.vel[1]) - 0.5, 0) * sign(e.vel[1])
  e.vel[2] += 2 -- gravity per frame
  e.pos[1] += e.vel[1] * 0.033
  e.pos[2] += e.vel[2] * 0.033
  e.pos[1] = max(0, min(123, e.pos[1]))
end

function hellstone_pget(e)
  local clr = 0
  e.standing = nil
  for x=3,4 do
    clr = pget(e.pos[1]+x, e.pos[2]+5-(game.map0.offset*128))
    if is_floor_color(clr) then
      e.standing = 0
      return
    end
  end
end

function map_for_offset(offset)
  return (game.map0.offset == offset) and game.map0 or ((game.map1.offset == offset) and game.map1 or game.map2)
end

function beep()
end

function shake_and_drop(drop, again)
  local p = play_sound(nil, sounds.quake, 2)
  for i=0,7 do
    add_timer(i*4, function(tid) cam.pos[1] = -1; end, 1)
    add_timer(i*4+2, function(tid) cam.pos[1] = 0; end, 1)
  end
  shake.drop_tid = add_timer(25, function(tid) if (shake.drop_tid == tid) then spikes=true; update_camera(cam.pos[2]+cam.buffer-drop); play_sound(p, sounds.quake2, 3); end; end, 1)

  if (again) then
    shake.tid = add_timer_secs(shake.delay, function(tid) if (shake.tid == tid) then shake_and_drop(shake.drop, true); end; end, 1)
  end
end

function sign(n)
  return (n < 0) and -1 or 1
end

function print_center(s, y, colr)
  local x = #s / 2 * 4
  print(s,64-x,cam.pos[2]-(game.map0.offset*128)+y,colr)
end

function print_right(s, x, y, colr)
  print(s,x-(#s * 4),cam.pos[2]-(game.map0.offset*128)+y,colr)
end

function can_grab_color(clr)
  return clr ~= 0 and clr ~= 8
end

function is_down_color(clr)
  return clr == 7 or clr == 13
end

function is_floor_color(clr)
  return clr == 1 or clr == 3 or clr == 4 or clr == 5
end

function is_fire_color(clr)
  return clr == 8
end

function hurts(p, clr)
  return (not p.optional.falling and is_fire_color(clr) and not p.active_items[items.resist_fire] and p.anim[1] != animation.bat)
end

function player_pget(p)
  local clr = 0

  p.optional.standing = nil
  for y=-2,2 do
    local floor = nil
    local nonfloor = nil
    for x=0,3 do
      clr = pget(p.pos[1]+2+x, p.pos[2]+8+y-(game.map0.offset*128))
      p.optional.hurt = p.optional.hurt or hurts(p, clr)
      floor = floor or is_floor_color(clr)
      nonfloor = nonfloor or (can_grab_color(clr) and not is_floor_color(clr))
    end
    p.optional.standing = p.optional.standing or ((floor and not nonfloor) and y or nil)
  end

  p.optional.grabbing = nil
  for y=1,5 do
    for x=0,3 do
      clr = pget(p.pos[1]+2+x, p.pos[2]+y-(game.map0.offset*128))
      p.optional.hurt = p.optional.hurt or hurts(p, clr)
      p.optional.grabbing = p.optional.grabbing or ((can_grab_color(clr)) and clr or nil)
    end
  end
end

function process_btn()
  local b = btn()
  players[1].optional.btn = b
  players[2].optional.btn = (game.players == 2) and shr(b,8) or ai_navigate(players[2])
end

function equals(v1, v2, d)
  return ((abs(v1[1] - v2[1]) < d) and (abs(v1[2] - v2[2]) < d))
end

-- ai {1 = idle, 2 = attack, 3 = avoid}
function ai_navigate(p)
  if (not p.ai or p.dead or p.active_items[items.stunned]) then
    return 0
  elseif (p.ai == 1) then
    if (not p.optional.ai_idle or (equals(p.pos, p.optional.ai_idle, 1))) then
      p.optional.ai_idle = {flr(rnd(120)), cam.pos[2]+flr(rnd(96))}
    end
    return dir2target(p.pos, p.optional.ai_idle)
  else
    return dir2target(p.pos, players[1].pos, (p.ai != 2))
  end
end

-- ai {1 = idle, 2 = attack, 3 = avoid}
function ai_state(p)
  if not p.dead then
    p.ai = (p.ai % 3) + 1
    if ((p.ai == 2) and (players[1].active_items[items.stunned] or players[1].optional.falling)) then
      p.ai = (p.ai % 3) + 1 -- don't attack
    end
    if (p.ai == 1) then
      p.optional.ai_idle = {flr(rnd(120)), cam.pos[2]+flr(rnd(96))}
    elseif ((p.ai == 2) and ai_can_use_item(p.item) and (rnd(100 < 25))) then
      p.item.activate(p)
      p.ai = (p.ai % 3) + 1 -- stop attack
    end
    p.optional.attack = (p.ai == 2)
    local t = flr(rnd(ai_state_duration[p.ai][2] - ai_state_duration[p.ai][1] + 1)) + ai_state_duration[p.ai][1]
    p.tid.ai_state = add_timer_secs(t, function(tid) if (p.tid.ai_state == tid) then ai_state(p); end; end, 1)
  end
end

function ai_can_use_item(i)
  return (i and ((i.number == items.freeze) or (i.number == items.hellstones) or (i.number == items.swap_players)))
end

-- get btn dir from source pos to target pos
-- when reverse==true, avoid getting to close to spikes
function dir2target(source, target, reverse)
  local sign = (reverse) and -1 or 1
  local dx = (source[1] - target[1]) * sign
  local dy = (source[2] - target[2]) * sign
  local bnt_y = (dy > 0 or reverse) and 4 or 8 -- never move (down) toward spikes when reversing
  local bnt_x = (dx > 0) and 1 or 2
  return (reverse) and ((abs(dx) < abs(dy)) and bnt_x or btn_y) or ((abs(dy) > abs(dx)) and bnt_y or bnt_x)
end

function fade_to_mainmenu()
  fade_out(function() add_timer_secs(1, function(tid) reset_game(); fade_in(); end, 1) end)
end

function fade_out(clbk)
  cam.fade = min(cam.fade + 0.1, 1)
  if (cam.fade < 1) then
    add_timer(3, function(tid) fade_out(clbk); end, 1)
  else
    if (clbk) then
      clbk()
    end
  end
end

function fade_in(clbk)
  cam.fade = max(cam.fade - 0.1, 0)
  if (cam.fade > 0) then
    add_timer(3, function(tid) fade_in(clbk); end, 1)
  else
    if (clbk) then
      clbk()
    end
  end
end

-- "fa" is a number ranging from 0 to 1
-- 1 = 100% faded out
-- 0 = 0% faded out
-- 0.5 = 50% faded out, etc.
function fade(fa)
	fa=max(min(1,fa),0)
	local fn=8
	local pn=15
	local fc=1/fn
	local fi=flr(fa/fc)+1
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

	for n=1,pn do
		pal(n,fades[n][fi],1)
	end
end

-- timers
next_timer_id = 1
timers = {}
processing_timers = false
function clear_timers()
  if (processing_timers) then assert() end
  timers = {}
end
function add_timer_secs(secs, clbk, times)
  return add_timer(secs*30, clbk, times)
end
function add_timer(cnt, clbk, times) -- times == nil to repeat forever
  timers[#timers+1] = {cnt, cnt, clbk, times, next_timer_id}
  next_timer_id += 1
  return next_timer_id - 1
end
function delay_timer_secs(id, secs)
  delay_timer(id, secs*30)
end
function delay_timer(id, cnt)
  local i = 1
  while (i < #timers) do
    if (timers[i][5] == id) then
      timers[i][2] += cnt
      break
    end
    i += 1
  end
end
function update_timers()
  processing_timers = true
  local i = 1
  while (i <= #timers) do
    if (timers[i]) then
      timers[i][2] -= 1
      if (timers[i][2] <= 0) then
        timers[i][3](timers[i][5])
        if (timers[i][4]) then timers[i][4] -= 1 end
        if (timers[i][4]) and (timers[i][4] <= 0) then
          timers[i] = timers[#timers]
          timers[#timers] = nil
          i -= 1
          --printh("timers remaining: " .. #timers)
        else
          timers[i][2] = timers[i][1] -- reset the timer
        end
      end
    end
    i += 1
  end
  processing_timers = false
end
__gfx__
7000000733333333000b000000000000111111110000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
07000070333354540000b20000000000000110000000000000000000000000000000000000000000000000000000000000aaa000007770000000000000000000
0070070044344544000b220000000000111111111111111100000000000000000000000000000000000000000000000000a00a00007007000000100000010000
00077000544444540000200000077000000000000001100000000000000000000000000000000000000000000000000000a00a00007007000001000000111000
0007700044444544000b000000077000000000001111111111111111000000000000000000000000000000000000000000aaa000007770000011110001010100
00700700444444440020b0000000000000000000000000000001100000000000000000000fe00ef0000000000000000000a00000007000000001000000010000
070000704454444400220000000000000000000000000000111111111111111100000000e0f0feef000000000000000000a00000007000000000100000000000
70000007444454440002b00000000000000000000000000000000000000110000000000088888888000000000000000000000000000000000000000000000000
0009000000090000111111110007d0000007d0001111111100000000000000000000000000000000000000007700007700ddd500000000000000000000000000
0000900000009000000110000007d0000007d000000110000000000000000000000000009090000990900009700000070ddddd50000000000000000000000000
0009000000090000111111110007d0000007d000111111110006000000000000009000000a9009900a00009000000000ddddddd5000000000000000000000000
0000900000009000000090000007d0000007d0000007d00000060000009000000009090000a9aa000000000000000000ddddddd5000000000000000000000000
0009000000090000000900000007d0000007d0000007d000000600000009909000aaa90099aaa9a99000000900000000ddddddd5000000000000000000000000
000000000000900000009000000000000007d0000007d0000066d0000007a9000977a9900977aa990000009900000000ddddddd5000000000000000000000000
000000000009000000090000000000000007d0000007d0000066d00000909000000700000097a90000000000700000070ddddd50000000000000000000000000
000000000000900000009000000000000007d0000007d0008666dd88000000000090000009a99a9009a00a907700007700ddd500000000000000000000000000
0000000000000000000700000050600000000000c00cc00c0000000000f00f000000dd0000000000000000000000000000000000000000000000000000000000
06600dd0000000000700000000000070000000000c0000c0000000000e8dd8e000c0dd0000000000000000000000000000000000000000000000000000000000
0666ddd00000000000000000000000000000000500000000000ddd660f8dd8f00c00d00000000000000000000000000000000000000000000000000000000000
06dd66d000000000600000000000000700000000c000000c00dddd6608dddd80c0ddddd000000000000000000000000000000000000000000000000000000000
0666ddd070000000000000000000000000000006c000000c0d00dd660d0dd0d00000d0000c00000c000000000000000000000000c00000c00000000000000000
0066dd0000000000500000000000000000000000000000000da0d06600edde0000c0ddd0c00000000c0c0000000000000000c0c00000000c0000000000000000
0066dd00070000000000000000000000000000700c0000c00a0d00000fdf8df00c0d00000000000000c00000000c0c0000000c00000000000000000000000000
0006d00000060500000000000000000000007000c00cc00c0000000008d88d80c0d00c0000000000000000000000c00000000000000000000000000000000000
066660000000000000000000000000000000a0000000dd0000000000000000000000000000000000000000000000000000000000007777000070000000000000
60086000000000000000000000000020000a00000000dd00fe000000000000000000000000000000e000000f000000000000000007777770066700000d0dd0d0
0088850000000000000000000000b2200055d0000000d0008000000000fe00000000fe0000000fe000000008000000000000000077dd777d666707000d0dd0d0
009995000000000000000000000b2200055ddd0000dddd00080000080080000000008000000008008000008077000077007007007ddd777d0670667007dddd70
008885000000000000000000020bb00055ddddd08080d000800000000808000000080800000080800000000800700700070770707ddd777d00066677007dd700
0088850000c00c000c0000c00222b00055ddddd00980dd00000000000080000000008000000008000000000000077000700000077ddd77dd00006770007dd700
00888600c0000cc000c0c00c002bb220055ddd0000dd00d0000000000000000000000000000000000000000000000000000000000dddddd00000070007d77d70
008880000cccccc00cccccc0000b22000055d000889a90000000000000000000000000000000000000000000000000000000000000dddd000000000077d77d77
00000000000000000000000000000000070770700000000000000000000770000000770000000000000000000000000000000000000000000000000000000000
00077000000000000000000000077000070770700007700000077000000770000000770000007700000000000000770000077000000770000000000000700000
00077000000770000007700007077070006666000007700000077000000600000000600000007700000077000000770000077000000770000000000000000000
00666600000770000707707000666600000660000006070000060000076667000076670000706000000077000000600007000070000000000007700000000000
07066070076666700066660000066000000660000066600007666700000600000000600000066700000060000006660000666600076666700007700000000000
00066000000660000006600000066000007007000706000000060000000677000000660000006000000067000070607000066000000660000000000000000000
00700700007667000076670000700700007007000006000000067000007000000077007000770700000760000000600000700700007007000706607000000000
00700700007007000070070000700700000000000070700000700000070000000000000000000070000007000007070000700700007007000776677000000000
00000000000000000000000000007000000700000007700000007700000000000000770000077000000770000000000000000000000000000000000000000000
00070000000070000000070000000000000000000007700000007700000077000000770000077000000770000007700000077000000770700007700007077000
00000000000000000000000000000000000000000006007000006000000077000000600000060000000600700007700000077000000770600007700006077000
00000000000000000000000000000000000000000066660000766670000060000000600000060000006666000000070000700000006666000766667000666600
00000000000000000000000000000000000000000706000000006000000766700000670000067000070600000076600000066700070660000006600000066070
00000000000000000000000000000000000000000006700000006700000060000007600000060000000600000006600000066000000660000006600000066000
00000000000000000000000000000000000000000070070000770070000767000000070000070000000670000000700000070000007007000070070000700700
00000000000000000000000000000000000000000700000000000000000000700000070000070000007000000007000000007000000007000000000000700000
00077000000770700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770600007700000000000000000000000080080000000000000000000000000777500000000000000000000000000000000000000000000000000
07666670006666000007700007077000000000008000800000008000000000000000000007757750000000000000000000000000000000000000000000000000
00066000070660000766667006077000070770800000000000000800800000000000000007555750000000000000000000000000000000000000000000000000
00066000000660000006600080666800068778000708708000800000000080000000000007757750000000000000000000000000000000000000000000000000
00700700007007000006608008068070806888008887780008788080080888800000870007757750000000000000000000000000000000000000000000000000
00000000000008000088080008888800088880800888888088888808887888888878888807757750000000000000000000000000000000000000000000000000
00000000000088800888888088888888888888888888888888888888888888888888887807777750000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000620000909000000000000090900000e30000000000000000000000000000000000000090000000000000000090000000
00000000000090909090909090909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404000000000000000000000404040404040402100000000000021404040400000004051405060605040514000000000000021000021404021000021000000
40400000000051404040404040404040000000000000000000007060504040404050600000405060605040000060504040404040000000212100000040404040
0000000000000000d300000000000000000000001100000000000011000000000000000041000000000000410000000000000011000011000011000011000000
00000000000041000000000000000000005300000000706050408000000000000000200000000000200000000020000000000000000000111100000000000000
40404000000000000000000000404040000000000000004040000000000000004050607041706050506070417060504000000011000090000090000011000000
4040404040404000000000000000002151405140514080000000000041c341000000200000002000200000000020000000514051000000111100000051405100
330000000000000000000000000000330000000000b300000000d30000000000b30000804180000000008041800000c3020000110000210000210000010000f3
0000000000000000000000000000000100004100410041000000410041004100820000006070200000000000002000f3024100410000001111000000410041d3
40404051000000000000000051404040000000000000004040000000000000000000000041700000000070410000000040000001000001000011000000000040
00000000000000000000000000002140000000004100410041004100410041000000000020804000000000404040404000410041002100000000210041004100
00000041005300000000530041000000000000000090900000909000000000000000000041804050504080410000000000000090000000000011000090000000
00000021405100000040404000000100000000000000410041004100410000000000000020000000000000000000c30000410041000000000000000041004100
e30000410021400000402100410000f3000000000021404040402100000000004050607041000000000000417060504000000021000011000011000021000000
0200001100410000000000000000000000000000000000004100410041000000e300000000006000000000000000000040400041000000000000000041004040
00000041000100000000010041000000000090900011000000001100909000006200008041000000000000418000006290000011000001000001000011000090
400000110041000000000000000000020000d30000000000000041004100f3006000000000002000000000000000000000000000706050404050607000000000
21000041000000000000000041000021000040400011000000001100404000000000000041706050506070410000000040000011000000000000000011000040
00000000004100004040404000000021000000000000000000005140514051402000000000002000330000000000000000000040800000000000008040000000
1100004100001100001100004100001100000000000000000000000000000000007060504180f30000e380415060700000000001000000000000000001000000
00000000004100000000000000000011000000000000000041004100410031002000000000002000200000000000000000000000000000000000000000000000
11000041000011000011000041000011404000000000000000000000000040404080000041000000000000410000804021000000000040404040000000000021
00002100004100000000000000000001000000000000410041004100310000000000000000000000200000000000000040405140510000909000005140514040
00000000000000000000000000000000000000000070606060607000000000005060700041000000000000410070605000000000000000000000000000000000
00001100000000004040404040404040000000004100410041003102000000000000003300000000200000000000000000004100410000404000004100410000
00000000404000000000404000000000000000404080000200008040400000005300804041000000000000414080005321000000000000000000000000000021
210000000000000000000000e3000000000041004100410031000000000000000000002000000000200000000000003300004100410000000000004100410000
000000000000000000000000000000000000000000009090909000000000000000706050410000000000004150607000000000d30000000000000000d3000000
01000000000000000000000000000000020041004100310000000000000000000000002000000000200000000000002003004100410000404000004100410000
40404000000000404000000000404040000040400000404040400000404000004080000040404000004040400000804040400000004040404040400000004040
40404040404040404040404040404040404040404040404040404040404040404000004040000040400000404000004040404040400000000000004040404040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000ddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddd000ddd0000000000000000000000000000000d11111d00d000000d0000000000000000000000000000000000000000000000000000000000000000000000
00d1d000d1d0ddd00000dddd0000ddd000ddd000d1111111d0dddddddd100dddddd000dddddd00ddd00000000000000000000000000000000000000000000000
00d11000d1100d1d000d1111dd000d1d000d1d00d110000110d11d111d10d111111d0d111111d00d1d0000000000000000000000000000000000000000000000
00d11000d1100d1100d1111111100d11000d1100d1100000000d1d1111d0d11111110d111111100d110000000000000000000000000000000000000000000000
00d11000d1100d1100d1100011100d11000d1100d111dddd00000d110000d11000110d110001100d110000000000000000000000000000000000000000000000
00ddddddd1100d1100d1100000000d11000d11000d111111d0000d110000d1100d110d1100d1100d110000000000000000000000000000000000000000000000
00d11111d1100d1100d1100ddd000ddddddd110000d1111110000d110000d110d1110d110d11100d110000000000000000000000000000000000000000000000
00d11111d1100d1100d1100d11100d11111d1100000000d110000d110000d11000000d110000000d110000000000000000000000000000000000000000000000
00d11000d1100d1100d11000d1100d11111d1100dd0000d110000d110000d11000dd0d11000dd00d11000d000000000000000000000000000000000000000000
00d11000d1100d1100d11ddd11100d11000d1100d1dddd1110000d110000d11ddd110d11ddd1100ddddddd100000000000000000000000000000000000000000
0ddd100ddd10ddd100d111111100ddd100ddd100d11111111000ddd10000d11111110d11111110ddd1111d100000000000000000000000000000000000000000
0011d00011d0011d000d11111000011d00011d000d1111110000011d00000d11111000d1111100011d1111d00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000
d111111111111111111111111111111111111111111111111111111111111111111111111111111111111d000000000000000000000000000000000000000000
0d111111111111111111111111111111111111111111111111111111111111111111111111111111111111d00000000000000000000000000000000000000000
00d555555555555555555555555555555555555555555555555555555555555555555555555555555555511d0000000000000000000000000000000000000000
00055555555555555555555555555555555555555555555555555555555555555555555555555555555551110000000000000000000000000000000000000000
00055555555555555555555555555555555555555555555555555555555555555555555555555555555551000000000000000000000000000000000000000000
00055555555555555555555555555555555555555555555555555555555555555555555555555555555551000000000000000000000000000000000000000000
00055555555555555555555555555555555555555555555555555555555555555555555555555555555551000000000000000000000000000000000000000000
00055555555555555555555555555555555555555555555555555555555555555555555555555555555551000000000000000000000000000000000000000000
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1000000000000000000000000000000000000000000
d111111111111111111111111111111111111111111111111111111111111111111111111111111111111d000000000000000000000000000000000000000000
0d111111111111111111111111111111111111111111111111111111111111111111111111111111111111d00000000000000000000000000000000000000000
00d111111111111111111111111111111111111111111111111111111111111111111111111111111111111d0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
01010100010101010101000040c00000010101010101000000000080000000000c0000000000082c10000000000000002000003028340000000000242438143c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000003f00
0404040404041200001204040404040404040000000000000000000000000404000000000000000000000004120000000000000000000000000404040000001404040404040404040404040404040404000015000000000404000000001500000404040000000004040000000004040400040412040000000000000404041200
000000000028111414112800000000003f000000000000000000000000000000000000000000000000003d0010000000000000000000000000000000003f0014000000000000000000000000000000000000143f00000000000000003f1400000000000000000000000000000000000000000011000000000000000000001100
1204000000001114141100000000041204040404150000000000000404040404000000000000000000120404040000000000000000000000000404040000001400000000000000000000000012040404000014000000040404040000001400002000000000000004040000000000002000000011000000000000000000001100
110000000000001414000000000000110000000014000000000000000000000000000000000000000011000000000000000000000000000000000000000000140000000000000000000000001100003e000014000000000000000000001400000000000004040000000004040000000000000011000000003e00000000001100
11000000000000040400000000000011000000000000000000000000000000000000000000000000001100000000000000000000000000000004040400000014120404040000003c0000000011000000000404040000000404000000040404000000040400000000000000000404000000000011000000040404040000001100
100000000000000000000000000000103000000000000000000000000000000000000000000000000011000000000000000000003500000000000000000000141100000000000000000000001000001400003e000000000000000000003e00000404000000000000000000000000040400000011000000000000000606000000
0412000000003e00003e000000001204040404040400001400000000000000000000330000000000000000003e0000001204000004000000000004040400001411000000000000000000000004040404000000000000000000000000000000000000000404000004120000040400000000000000000000000000000000000000
0011000000000000000000000000110030000000000000140000090900333300000004041200000000000000000000001100000020000000000000000000001400090909000000000000000000000000000000000000150404150000000000003d00000000000000110000000000003c00000000000000000000000000040400
0011000000001400001400000000110004040412040000140000040404040400000000001100000000000000000000001100000000000000000000040404001400040404000000000000040404040404040404120000140000140000120404040000090014000000300000140009000000000000000000000000000606000000
0010000000001400001400000000100000000011000000140000000000000000000000001100000000000000000000001000001414000000000000000000001400000000000000000000090909003030002000110000140028140000110020000000120014000004040000140012000000002809000000000000000000000000
0404040404041400001404040404040400260011000000140000000000000000000000001100000000000000000000000404040404050607000000000404041404040404040404040404040404040404000000110000140000140000110000000000100014040000000004140010000000000404120000000000000000040400
000d0000002014000014200000000c000000001000000013000000000000000000000000100000000000000000000000003d000000000008040506070000001400003500000000000000000000000000000000000033140000143300000000000000000014000026000000140000000000000000100009000000000000000000
0404000000001400001400000000040404040404040404040404040404040404260000000000000000000000000000000000000000000000000000080412041400040404000000000000000000000026000000000004140000140400000000000000000014040400000404140000000000000000000004000000000706050404
0000000000001400001400000000000000000000000000000000000000002000000000000000000000000000003333000000000000000000000000000010001400000000000000000000000000000000330000000000140000140000000000330000000014000000000000140000000035000000000000070605040800000030
0101010101010101010101010101010104040404040404040404040404040404040404040404040000040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404140000140404040404040000040404040400000404040404000004000004040404040404040404040404
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000200000002000000000001500000000000026
0404041204000000000000000000000000040404040404040412000009000000000004040404040404041500000000040000001404040000000000000004040400000000000006040406000000000000001204040000000000000000040412000012041500000000000000001504120015120404000000001400000000350015
0000001100000000000000003d000000000000000000000000110000120000000000000000000000000014000000000000000014000000000000000000003d0000002000001200000000120000200000001100000000000000000000000011000011001400000000000000001400110014100000000000001400000000000014
20000011000000000000000000000000000000000000090000110000110000000000000000000000000014000000003b000000040412000000000000000404040000000000000000000000000000000000112000000000000000000000201100000000000015150000151500000000003e040404040404001500040404041214
000000100000000000000000000000000000000000001200001000001100003f0000000000000000000014000000000000003f0000110000000000000000000000350000070605040405060700003500001100000000000000000000000011003e00000000041504041504000000003e14003500000000001400000000001114
1400000400000000000000000412040000003e00000011000009000011000004000000000000000000000000000000000000140000110000000033000000000000121404080000000000000804141200000000000000000000000000000000001200000000001400001400000000001214000000000000001400000000001014
140000000000000000000000001100000000000000001100001200001100000000003f000404000000000000000000000000140000110009090004000000000000111400000000003d0000000014110000000000000000000000000000000000000000000000140000140000000000001412040404040400140004040404043d
04040404000000000000000000110000001204040000110000110000110000000000000000000000150415000000000026000000000000040400000000000000001100000000003e0000000000001100000000001204000000000412000000000607000000001400001400000000070614110000000000001400000000350014
26000000000000003e00000000110000001100000000100000100000100000000033000000000000143d1400000000000000000000000000000000140000000000100000000000000000000000001000000000001100000000000011000000000008040506071433331407060504080014100000000000001400000000000014
04040404000000000000000000000000001100000000000000000000000000000004040000000000040404000000000012040004041204040404041400000000000000120000000404000000120000000000003e11000000000000113e000000000000002608141212140826000000003e040404040404001500040404041214
0000000000000000000000000000000000100000000000000000000000000000000033000000000000000000000020001100000000110000000000140000000012000000000009003509000000000012000000000000000000000000000000000000000000001411111400000000000014003500000000001400000000001114
1204040400000000000000000404041200040404040404000000040404040400000004150000000000000000000000001100000000100000303000140000000010120000000004040404000000001210002800000000000000000000000028000000000000001410101400000000000014000000000000001400000000001014
1100000000000000000000000000001000000035000000000000003f002000000000001400000000000000000000000011000000000404040404040400000000001012000000003b000000000012100000120400000000000000000000041200000000120404140000140404120000001412040404040400140004040404043d
1100000000000000000000000000000000040404000000000000000000000000260000000000000000000000000000001100000000000000000000000000000000001100000000000000000000110000001100000000000026000000000011000000001100001400001400001100000014110000000000001400000000350014
100028000000000000000000002800000000000000000000000000140014000000003300000000000000000000330000100000000000000000000000000000003000100000000000000000000010003000100000000000000000000000001000000000100000143f001400001000000014100000000000001400000000000014
0000040404040400000404040404000004040404040404040404040404040404040404040000040404040000040404040404040404040404040404040404040404040404040400000000040404040404000404040404040404040404040404000404040000001404041400000004040414040404040404000400040404040414
__sfx__
010400000061000614186200062400620006241862000624006200062418620006240062000624186200062400620006241862000624006200062418620006240062000624186200062400620006241861000614
011b00080061400604006140060400614006040061400604186011860100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000066500652006420064200632006220061200612000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002464124625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011b00080061400604006140060400614006040061400604000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011c00000c7400c7300c7200c71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001804530045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c7430e74328743297431d7431c7330e7230c713000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800003054330543305433054330543305333052330513000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000240343c0313c0323c0223c0123c0123c2023c205301003010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001c0531c0531c0531c0531c0431c0331c0231c013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000065500655006550065500645006350062500615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c45100451000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000024453184530c4530045300443004330042300413000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400003005530055300553005530055300553005530055300553005530055300553005530055300553005500000000000000000000000000000000000000000000000000000000000000000000000000000000
011c00000015000700247002470024500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000000654016500165000650006400063000620006100c0000c6000c6000c6000c6000c6000c6000c60000000046000160001600026000360000000056000860009600096000760005600056000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c14500140001350010000140001353f20524715001400013500140001350c10500105001350c14503145031400313523700031400313503105031400313503100217000f1350f145031400313500135
011000000c0431a7002471524705306150c043187150c0430c043247150c043247153061524715306150c0430c0431f7151f71518615306150c0431f7150c0430c0431f7150c0431f715306151f7152461524615
011000001f7003f205227153f2053f205237002271522715237002271500700227152470022715237002370000700247152471521700007000070022715007000070022715007002471500700227150070000700
010c00000011000110001100011000110001100011000110031200312003120031200312003120031200312008130081300813008130081300813008130081300d1400d1400d1400d1400d1400d1400d1400d140
010c00002451024510245102451024510245102451024510245202452024520245202452024520245202452024530245302453024530245302453024530245302454024540245402454024540245402454024540
010c00000f0100f0100f0100f0100f0100f0100f0100f010130201302013020130201301013010130101301018020180201802018020180101801018010180101f0201f0201f0201f0200c610186112461130611
010c00003071637716307163771630716377163071637716307163771630716377163071637716307163771630716377163071637716307163771630716377163071637716307163771630716377163071637716
010d00000014000140001400014000140001400014000140001300013000130001300013000130001300013000120001200012000120001200012000120001200011000110001100011000110001100011000115
010d00003c6103061124611186110c61100611006100061507717137171f71707717137171f71707717137171f71707717137171f71707717137171f71707717137171f71707717137171f71707717137171f717
010d000030716377163071637716307163771630716377160f1200f1200f1200f1200f1200f1200f1200f1200f1100f1100f1100f1100f1100f1100f1100f1100f1100f1100f1100f1100f1100f1100f1100f115
010d00003054030540305403054030530305303052024511185111851018510185101851018510185101851018510185101851018510185101851018510185101851018510185101851018510185101851018515
011000001114505140051350010005140051353f20524715051400513505140051350c10500105051351114508145081450813508140081350310507145071451313507140071350f10507145071050714507145
011000000c0431a7002471524705306150c043247150c0430c043247150c043247153061524715306150c0430c0431f7151f71518615306150c0431f7150c0430c0431f7150c0431f715306151f7152461524615
011000000c0431a7002471524705306150c043187150c0430c043247150c043247153061524715306150c0430c043277152771518615306150c043277150c0430c043297150c04329715306152b7152771524615
01100000081350813508135081352b7052b715307152b71507135071350713507135000002b715307152b70505135051350513505135000002b715307152b7150313503135001350013505135051350713507135
011000000c0430c043246150c04324705247152b71524715246150c0430c0430c04300000247152b715247050c0430c0430c0430c04300000247152b715247150c043187350f7250f72524615147251672516725
01100000081350813508135081352b7052b715307152b71507135071350713507135000002b715307152b705051350513503135031350c1350c1350f1350f1350e1350e135081350813507135071351313513135
011000000c0430c043246150c04324705247152b71524715246150c0430c0430c04300000247152b715247050c0430c0430c0430c04300000247152b715247150c043187350f7250f72524615147251772517725
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 17 18 19 1a
04 1b 1c 1d 1e
01 14 15 43 44
00 1f 21 43 44
00 14 15 43 44
00 1f 21 43 44
00 22 23 43 44
00 22 23 43 44
02 24 25 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
