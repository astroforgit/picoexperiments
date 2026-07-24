pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- yarn
-- by @kevinthompson

-- game
cartdata("yarn")

-- palette
poke(0x5f2e,1)

-- globals
scene=nil
level=nil
state=nil
entities={}
gravity=0.05
input_enabled=true
stars=0
score=0
points=0
points_y=24
high_score=0
shake_offset=0
seed=flr(rnd(999999999))
cam={x=0,y=0}
debug=false
frame=1
show_transparent=true
win_screen_y=-160
win_screen_target_y=-160
star_sounds={28,29,30}
transparency_enabled=dget(62) or 0

-- lifecycle
function _init()
  music(0)
  set_menu_items()
  load_cart_data()
  load_scene(title)
  transition:init()
end

function _update60()
  scene:update()

  show_transparent=not show_transparent
  frame=frame >= 60 and 1 or frame + 1

  for timer in all(timers) do
    timer[1]-=1
    if timer[1]<=0 then
      timer[2]()
      del(timers,timer)
    end
  end

  transition:update()
end

function _draw()
  screen_shake()
  camera(cam.x,cam.y)
  scene:draw()
  transition:draw()

  if debug then
    each_entity(function(entity)
      rect(
        entity.x + entity.hitbox.x,
        entity.y + entity.hitbox.y,
        entity.x + entity.hitbox.x + entity.hitbox.width - 1,
        entity.y + entity.hitbox.y + entity.hitbox.height - 1,
        8
      )
    end)
  end
end

function reset_cart_data()
  for i=0,#levels do
    dset(i,0)
  end

  dset(63,0)
end

function load_cart_data()
  max_level_id=mid(1,dget(63),#levels)
  level_id=max_level_id
end

function load_scene(new_scene)
  if scene~=new_scene then
    timers={}
    scene=new_scene
    scene:init()
  end
end

function set_menu_items(items)
  items = items or {}

  for i=1,5 do
    menuitem(i)
  end

  for item in all(items) do
    menuitem(item[1], item[2], item[3])
  end

  menuitem(4, transparency_enabled == 1 and "transparency off" or "transparency on", function()
    transparency_enabled = transparency_enabled == 1 and 0 or 1
    dset(62, transparency_enabled)
    set_menu_items(items)
  end)

  menuitem(5, debug and "debug off" or "debug on", function()
    debug = not debug
    set_menu_items(items)
  end)
end



-- scenes
title={
  init=function(self)
    cam={x=0,y=0}

    pal()
    pal(3,129,1)
    pal(10,135,1)
    pal(11,138,1)
    pal(12,133,1)
    pal(13,137,1)
    pal(14,136,1)
    pal(15,132,1)

    set_menu_items({
      {
        1, "reset progress", function()
          reset_cart_data()
          load_cart_data()
        end
      }
    })

    clouds = {}
    for i=1,8 do
      create_cloud()
    end

    initialize_eyes()
    update_eye_position()
  end,

  update=function(self)
    if action() then
      transition:animate(function()
        load_scene(world)
      end)
    end

    for cloud in all(clouds) do
      cloud.x+=cloud.speed.x

      if cloud.x < -24 then
        cloud.x=136
      end
    end
  end,

  draw=function(self)
    srand(seed)
    cls(1)

    -- moon
    circfill(16,56,32,10)

    draw_clouds()
    draw_buildings()

    -- cats
    spr(196,6,54,2,2)
    spr(196,100,58,2,2,true)

    -- logo
    spr(151,28,6,9,7)

    -- character
    draw_character()

    -- prompt
    draw_x_button(58, 106)
    print("press",30,104,3)
    print("press",30,103,7)
    print("to start",68,104,3)
    print("to start",68,103,7)

    draw_score_ui()

    palt()
  end
}


world={
  init=function(self)
    self:reset_palette()

    clouds = {}
    homes = {}
    world_width = ((#levels-1) * 32) + 48

    for i=1,#levels/2 do
      homes[i] = {flr(rnd(255)), flr(rnd(255))}
    end

    set_menu_items({
      {
        1, "return to title", function()
          transition:animate(function()
            load_scene(title)
          end)
        end
      }
    })

    for i=1,32 do
      create_cloud(rnd(world_width), rnd(16) + -4, -1* (rnd()/10), rnd({-2,-1.5,-1,1,1.5,2,3}))
    end

    for i=1,32 do
      create_cloud(rnd(world_width), rnd(16) + 120, -1* (rnd()/10), rnd({-2,-1.5,-1,1,1.5,2,3}))
    end

    move_world_camera(0)
  end,

  update=function(self)
    move_world_camera()

    if btnp(‹) then
      if level_id > 1 then
        sfx(33)
        level_id-=1
      else
        invalid()
      end
    elseif btnp(‘) then
      if level_id < #levels then
        sfx(33)
        level_id+=1
      else
        invalid()
      end
    elseif action() then
      if level_id <= max_level_id then
        transition:animate(function()
          load_scene(game)
        end)
      else
        invalid()
      end
    end

    for cloud in all(clouds) do
      cloud.x += cloud.speed.x

      if cloud.x < - (24 * cloud.scale) then
        cloud.x = world_width
      end
    end
  end,

  draw=function(self)
    cls(1)
    local bits = {16,4,2,32,8,1,128,64}
    local offsets = {{0,-6},{8,2},{-8,2},{16,10},{0,10},{-16,10},{8,18},{-8,18}}

    for x=flr(cam.x)-48,flr(cam.x)+176 do
      local y=48+(triangle(x/128)*96)
      circfill(x,y,12,0)
    end

    -- houses
    for id=1, #homes do
      local x = 24+((id*2)-1)*32
      local y = 8+((triangle((x+64)/128)*128) * 1.25)
      local house = homes[id]
      local display = house[1]
      local style = house[2]

      for i=1,#bits do
        spr(
          style & bits[i] == bits[i] and 128 or 160,
          x + offsets[i][1],
          y + offsets[i][2] + 4,
          2,
          2
        )
      end

      spr(162,x - 2,y + 26,2,2)

      for i=1,#bits do
        local tall = style & bits[i] == bits[i]

        if (display & bits[i] == bits[i]) then
          spr(
            tall and 132 or 130,
            x + offsets[i][1],
            y + offsets[i][2] + (tall and -8 or 0),
            2,
            tall and 3 or 2
          )
        end
      end
    end

    for i=max(level_id-3,1),min(level_id+3,#levels) do
      draw_level_icon(i)
    end

    draw_clouds()
  end,

  reset_palette = function(self)
    pal()
    pal(1,129,1)
    pal(2,136,1)
    pal(3,130,1)
    pal(5,141,1)
    pal(9,9,1)
    pal(11,138,1)
    pal(15,13,1)
    pal(13,137,1)
  end
}

function move_world_camera(speed)
  speed=speed or .75
  local x=mid(0, ((level_id-1)*32)-40, world_width - 128)
  x=max(0,x)
  cam.x=lerp(cam.x,x,speed)
  cam.y=0
end

function draw_level_icon(id)
  local data=tostr(dget(id))
  local star_count=tonum(sub(data,1,1))
  local x=24+(id-1)*32
  local y=47+(triangle(x/128)*96)

  draw_button(x, y, id, level_id == id, id > max_level_id)

  for i=1,star_count do
    spr(68,x+((i-1)*7)-9,y+cos((i+1)*.5)-15)
  end

  for i=star_count+1,3 do
    spr(67,x+((i-1)*7)-9,y+cos((i+1)*.5)-15)
  end
end

function draw_button(x, y, text, selected, disabled)
  if disabled then
    draw_disabled_button(x, y, selected)
  else
    draw_enabled_button(x, y, selected)
  end

  if type(text) == "function" then
    text(x-3,y-3)
  else
    local half_text = (#tostr(text) * 4) / 2
    print(text, x - half_text + 1, 1 + y - 2, disabled and 15 or 4)
    print(text, x - half_text + 1, y - 2, 7)
  end
end

function draw_enabled_button(x,y,selected)
  local r=7

  if selected then
    circfill(x, y, r + 2, 7)
    circfill(x, y + 2, r + 2, 7)
  end

  circfill(x, y + 2, r, 13)
  circfill(x, y, r, 9)
end

function draw_disabled_button(x,y,selected)
  local r=7

  if selected then
    circfill(x, y, r + 2, 15)
    circfill(x, y + 2, r + 2, 15)
  end

  circfill(x, y + 2, r, 3)
  circfill(x, y, r, 5)

  pset(x+r,y,11)
  pset(x+r-1,y,11)
  pset(x+r-1,y+1,11)
  pset(x+r,y+1,11)
  pset(x+r,y+2,11)

  pset(x-5,y+5,11)
  pset(x-6,y+4,11)
  pset(x-6,y+5,11)
  pset(x-6,y+6,11)

  pset(x,y+r,11)
  pset(x,y+r+1,11)
end

function triangle(x)
  x=band(x, 0x.ffff)
  if (x>=0.5) x=1-x
  return x
end

function invalid()
  sfx(24)
  shake(.075)
end


game={
  winning=false,

  init=function(self)
    self:reset_palette()
    self.win_word=""
    particles = {}

    set_menu_items({
      {
        1, "restart level", function()
          self:init()
        end
      },
      {
        1, "return to world", function()
          transition:animate(function()
            load_scene(world)
          end)
        end
      }
    })

    load_level(level_id)
    state=states.ready
    cam={x=0,y=0}
    new_high_score = false

    self.winning=false
  end,

  update=function(self)
    local target=self.player or {x=cam.x, y=cam.y, speed={ x=0 }}

    state.update(self)

    each_entity(function(entity)
      entity:update()
      animate(entity)
    end)

    for particle in all(particles) do
      particle:update()
    end

    points_y=lerp(points_y, 32, .98)

    cam={
      x=lerp(cam.x,mid(0,flr(target.x-64+(sgn(target.speed.x)*32)),(level_width*8)-128),.95),
      y=lerp(cam.y,mid(0,flr(target.y-64),(level_height*8)-128),.95)
    }
  end,

  draw=function(self)
    cls(1)
    rectfill(8,8,(level_width * 8) - 8, (level_height * 8) - 8, 12)

    for x=8, (level_width * 8) - 8, 8 do
      for y=8, (level_height * 8) - 8, 8 do
        spr(73,x,y)
      end
    end

    map(0,0,0,0,level_width,level_height)

    for particle in all(particles) do
      particle:draw()
    end

    each_entity(function(entity)
      entity:draw()
    end)

    state.draw(self)
  end,

  draw_interface=function(self)
    self:draw_top_interface()
    self:draw_bottom_interface()
  end,

  draw_top_interface=function(self)
    local y=4

    for star in all(ui_stars) do
      star:draw()
    end

    transparent(function()
      if points > 0 and points_y < 26 then
        local point_str="+"..tostr(points)
        print(point_str,cam.x+121-(#tostr(point_str)*4),cam.y+points_y,6)
      end
    end)

    print("score",cam.x+101,cam.y+y+5,3)
    print("score",cam.x+101,cam.y+y+4,6)
    print(score,cam.x+121-(#tostr(score)*4),cam.y+y+13,3)
    print(score,cam.x+121-(#tostr(score)*4),cam.y+y+12,7)
  end,

  draw_bottom_interface=function(self)
    local y=107

    if high_score > 0 and not new_high_score then
      print("high score",cam.x+8,cam.y+y+1,3)
      print("high score",cam.x+8,cam.y+y,6)
      print(high_score,cam.x+8,cam.y+y+9,3)
      print(high_score,cam.x+8,cam.y+y+8,7)
    end
  end,

  draw_prompt=function(self)
    local prompt = prompts[level_id] or "press — to start"
    rectfill(cam.x,cam.y+88,cam.x+128,cam.y+101,0)
    print(prompt,cam.x+8,cam.y+93,5)
    print(prompt,cam.x+8,cam.y+92,7)
  end,

  reset_palette=function(self)
    pal()
    pal(0,129,1)
    pal(1,141,1)
    pal(2,136,1)
    pal(3,130,1)
    pal(11,138,1)
    pal(14,140,1)
    pal(5,13,1)
    pal(13,137,1)
    pal(15,143,1)
  end
}

states={
  ready={
    update=function(self)
      if action() then
        state=states.playing
        game.player.speed.x=.65
      end
    end,

    draw=function(self)
      self:draw_interface()
      self:draw_prompt()
    end
  },

  playing={
    update=function(self)
      local player=game.player
      score=max(0, score-1)

      if action() and player.jump_available then
        player:jump()
      elseif not btn(—) then
        player.jump_available=true
      end

      each_entity(function(entity,layer)
        if entity~=game.player and collide(game.player,entity) then
          if entity.type=="star" then
            del(entities[layer], entity)
              stars+=1
            sfx(star_sounds[stars])
            sfx(32)
            sfx(34)
            add_points(100)
            ui_stars[stars]:animate("collected")
            create_dust({
              x = entity.x + 3,
              y = entity.y + 3,
              dy = -1,
              d = 3,
              c = 10
            })
          elseif entity.type=="cat" then
            state=states.win
            create_dust({
              x = entity.x + 8,
              y = entity.y + 8,
              d = 4
            })
            shake(.15)
            entity:die()
            del(entities[layer], entity)
          elseif fget(entity.sprite,2) then
            state=states.lose
            shake()
            sfx(26)
            score = 0
            player:destroy()

            create_dust({
              x = entity.x + 3,
              y = entity.y + 3,
              dy = -1,
              d = 4,
            })

            set_timer(30, function()
              game:init()
            end)
          end
        end
      end)
    end,

    draw=function(self)
      self:draw_interface()
    end
  },

  lose={
    update=function(self)

    end,

    draw=function(self)
      self:draw_interface()
    end
  },

  win={
    update=function(self)
      if not self.winning then
        local words={"oh yeah", "fantastic", "brilliant", "wonderful", "woot", "swell", "nice", "awesome", "super", "great", "wow", "pawsome"}

        self.win_word=rnd(words)
        self.winning=true

        input_enabled = false
        set_timer(30, function()
          transition:animate(function()
            win_screen_target_y=0
          end, -128)
        end)

        if score>high_score then
          high_score = score
          new_high_score = true
        end

        dset(level_id, tonum(min(3, max(stars, prev_stars))..score))

        if level_id>=max_level_id then
          max_level_id=level_id+1
          dset(63,max_level_id)
        end
      end

      win_screen_y=lerp(win_screen_y, win_screen_target_y, .90)

      if win_screen_y >= 0 then
        input_enabled = true
      end

      game.player.speed.x *= .95

      if input_enabled then
        if btnp(0) then
          menu_id = max(1, menu_id - 1)
        end

        if btnp(1) then
          menu_id = min(3, menu_id + 1)
        end

        if action() then
          transition:animate(function()
            if menu_id == 3 then
              if level_id < #levels then
                level_id+=1
                self:init()
              else
                load_scene(ending)
              end
            elseif menu_id == 2 then
              self:init()
            elseif menu_id == 1 then
              if level_id < #levels then
                level_id+=1
              end

              load_scene(world)
            end
          end, 192, false)
        end
      end
    end,

    draw=function(self)
      local x = cam.x
      local y = cam.y + win_screen_y

      self:draw_interface()

      rectfill(x + 4, y , x + 123, y + 116, 0)
      rectfill(x + 12, y + 101, x + 115, y + 123, 0)

      palt(0, false)
      palt(11, true)
      spr(1,x + 4, y + 116, 1, 1, false, true)
      spr(1,x + 116, y + 116, 1, 1, true, true)
      palt()

      pal(11, 0)
      for i=stars + 1,3 do
        spr(74, x + 22 + ((i - 1) * 30), y + 50, 3, 3)
      end

      pal(11, 10)
      pal(6, 10)
      for i=1,stars do
        spr(74, x + 22 + ((i - 1) * 30), y + 50, 3, 3)
      end
      self:reset_palette()

      local high_score_text= new_high_score and "new high score!" or "high score: " .. high_score
      sprint(self.win_word, x + 64 - ((#self.win_word/2) * 8), y + 35, 5, 2)
      sprint(self.win_word, x + 64 - ((#self.win_word/2) * 8), y + 34, 7, 2)
      print(score, x + 64 - ((#tostr(score)/2) * 4), y + 81, 5)
      print(score, x + 64 - ((#tostr(score)/2) * 4), y + 80, 7)
      print(high_score_text, x + 64 - ((#high_score_text/2) * 4), y + 89, 6)

      draw_button(x + 40, y + 107, function(x,y) spr(135,x,y) end, menu_id == 1)
      draw_button(x + 64, y + 107, function(x,y) spr(136,x,y) end, menu_id == 2)
      draw_button(x + 88, y + 107, function(x,y) spr(137,x,y) end, menu_id == 3)
    end
  }
}


ending={
  init=function(self)
    cam={x=0,y=0}

    pal()
    pal(3,129,1)
    pal(10,135,1)
    pal(11,13,1)
    pal(12,133,1)
    pal(13,137,1)
    pal(14,136,1)
    pal(15,132,1)

    clouds = {}
    for i=1,8 do
      create_cloud(nil, rnd(2) * 16)
    end

    initialize_eyes()
    update_eye_position()
  end,

  update=function(self)
    if action() then
      transition:animate(function()
        load_scene(world)
      end)
    end

    for cloud in all(clouds) do
      cloud.x+=cloud.speed.x

      if cloud.x < -24 then
        cloud.x=136
      end
    end
  end,

  draw=function(self)
    srand(seed)
    cls(1)

    -- moon
    circfill(16,56,32,10)

    draw_clouds()
    draw_buildings()

    -- cats
    spr(77,4,54,2,2)
    spr(77,100,58,2,2,true)

    draw_character(68)

    -- prompt
    draw_x_button(52, 108)
    print("press",24,106,3)
    print("press",24,105,7)
    print("to continue",62,106,3)
    print("to continue",62,105,7)

    for i=1,3 do
      local x = 8 + sin((time() - (i * .75))/2) * 3
      local y = 60 + cos((time() - (i * .75))/2)
      pset(x, y, 10)
    end

    for i=1,3 do
      local x = 112 + sin((time() - (i * .75))/2) * 3
      local y = 64 + cos((time() - (i * .75))/2)
      pset(x, y, 10)
    end

    rectfill(16,12,111,45,3)

    for i=16,104,8 do
      spr(121,i,6)
      spr(121,i,44,1,1,false,true)
    end

    for i=12,40,8 do
      spr(122,8,i)
      spr(122,112,i,1,1,true,false)
    end

    spr(123,112,40)
    spr(123,9,42,1,1,true)
    spr(123,9,10,1,1,true,true)
    spr(123,112,10,1,1,false,true)

    printc("you've won... for now.", 16, 7, 11)
    printc("play more on ios at:", 28, 6, 1)
    printc("https://is.gd/yarngame", 36, 7, 1)

    draw_score_ui()

    palt()
  end
}



-- entities
player={
  new=function(self,x,y)
    local prev_pos={}
    for i=1,6 do
      prev_pos[i]={x=x, y=y}
    end

    return create_entity(1,{
      type="player",

      x=x,
      y=y,
      width=8,
      height=8,
      ground=true,
      wall=true,
      flip=false,

      prev_pos=prev_pos,

      speed={
        x=0,
        y=0
      },

      hitbox = {
        x=1,
        y=1,
        width=6,
        heght=7
      },

      animations={
        idle={
          fps=1,
          frames={48},
        },
        jump={
          fps=6,
          frames={16,32,48},
        }
      },

      sprite=48,

      init=function(self)
        self:animate("idle")
      end,

      update=function(self)
        if frame%2==0 then
          for i=1,#self.prev_pos-1 do
            self.prev_pos[i]=self.prev_pos[i+1]
          end

          self.prev_pos[#self.prev_pos]={ x=self.x, y=self.y }
        end

        if (self.wall and self.speed.y>0) then
          self.speed.y=.33
        else
          self.speed.y+=gravity
        end

        if self.speed.x<0 then
          self.flip=true
        else
          self.flip=false
        end

        self:resolve_map_collision()
        self:detect_ground()
        self:detect_wall()
      end,

      draw=function(self)
        transparent(function()
          for i=1, #self.prev_pos do
            local pos=self.prev_pos[i]
            local r=ceil(((i-1)/#self.prev_pos)*2)
            circfill(pos.x+4, pos.y+7-r, r, 7)
          end
        end)

        palt(0, false)
        palt(11, true)
        spr(self.sprite,self.x,self.y,1,1,self.flip)
        palt()
      end,

      jump=function(self)
        local sounds={21,22,23}
        local jump_sound=rnd(sounds)

        if self.ground and self.wall then
          self:animate("jump")
          self.speed.y=-1.125
          self.jump_available=false
          sfx(jump_sound)
        elseif self.ground then
          self:animate("jump")
          self.speed.y=-1.35
          self.jump_available=false
          sfx(jump_sound)
        elseif self.wall then
          self.speed.y=-1.35
          self.speed.x*=-1
          self.jump_available=false
          sfx(jump_sound)
        end
      end,

      resolve_map_collision=function(self)
        local speed=self.speed
        local max_speed=max(abs(speed.x),abs(speed.y))
        local steps=ceil(max_speed/8)

        for step=1,steps do
          if speed.x~=0 then
            self.x+=speed.x/steps
            self:on_map_collision(function(tile)
              self.x=tile.x-(8*sgn(speed.x))
            end)
          end

          if speed.y~=0 then
            self.y+=speed.y/steps
            self:on_map_collision(function(tile)
              self.y=tile.y-(8*sgn(speed.y))
              self.speed.y=0
            end, self.speed.y > 0)
          end
        end
      end,

      on_map_collision=function(self,callback,include_semi_solid)
        local x,y,width,height=self.x,self.y,self.width,self.height

        for tile in all(tiles(x,y,x+width-1,y+height-1)) do
          local solid = fget(tile.sprite,0)
          local semi_solid = include_semi_solid and flr(self.prev_pos[#self.prev_pos].y + self.height) <= tile.y and fget(tile.sprite,2)
          local collision = solid or semi_solid

          if collision then
            callback(tile)
            break
          end
        end
      end,

      detect_ground=function(self)
        local was_ground=self.ground
        self.ground=false

        for tile in all(tiles(self.x,self.y+8,self.x+7,self.y+8)) do
          if fget(tile.sprite,0) or fget(tile.sprite,2) then
            if (not was_ground) self:impact({ x = self.x + 3 })
            self.ground=true
            self:animate("idle")
            break
          end
        end
      end,

      detect_wall=function(self)
        local was_wall=self.wall
        self.wall=false
        local offset=self.speed.x>0 and 8 or -1

        for tile in all(tiles(self.x+offset,self.y,self.x+offset,self.y+7)) do
          if fget(tile.sprite,0) then
            if (not was_wall) then
              self:impact({
                x = (self.flip and self.x or (self.x + self.width)),
                y = self.y + 6,
              })
            end

            self.wall=true
            break
          end
        end
      end,

      impact = function(self, opts)
        opts = opts or {}

        local x = opts.x or (self.x + (self.flip and self.width or 0))
        local y = opts.y or self.y + self.height
        local dx = opts.dx
        local dy = opts.dy

        create_dust({
          x = x,
          y = y,
          dx = dx,
          dy = dy,
          life = 30
        })

        sfx(25)
      end
    })
  end
}


cat={
  new=function(self,x,y)
   create_entity(2,{
    type="cat",

    x=x,
    y=y-8,
    z=1,
    width=16,
    height=16,

    hitbox = {
      x = 0,
      y = 0,
      width = 16,
      height = 16
    },

    animations={
      idle={
        frames={2},
      }
    },

    init=function(self)
      self:animate("idle")
    end,

    draw=function(self)
      spr(self.sprite,self.x,self.y,2,2)
    end,

    die=function(self)
      sfx(27)
      sfx(26)
      --dust:new(self.x,self.y)
      pow:new(self.x+2, self.y+2)
      self:destroy()
    end
   })
  end
 }


pow={
  new=function(self,x,y)
   create_entity(0,{
    type="pow",

    x=x,
    y=y,
    width=16,
    height=16,

    init=function(self)
      self.frame=0
    end,

    update=function(self)
      self.frame+=1
    end,

    draw=function(self)
      palt(0, false)
      palt(11, true)

      if self.frame < 4 then
        if frame%2==0 then
          spr(69,self.x+4,self.y+4)
        end
      elseif self.frame < 8 then
        if frame%2==0 then
          spr(70,self.x+4,self.y+4)
        end
      else
        spr(71,self.x,self.y,2,2)
      end

      palt()
    end,
   })
  end
 }



saw={
  new=function(self,x,y,d)
    d = d or 'up'

    local hitbox = {}
    local frames = {}
    local flipx = false
    local flipy = false

    if d == 'right' then
      hitbox = { x = 0, y = 1, width = 5, height = 6 }
      frames = { 104, 105, 120 }
    elseif d == 'down' then
      hitbox = { x = 1, y = 0, width = 6, height = 5 }
      frames = { 99, 100, 115 }
      flipy = true
    elseif d == 'left' then
      hitbox = { x = 3, y = 1, width = 5, height = 6 }
      frames = { 104, 105, 120 }
      flipx = true
    else
      hitbox = { x = 1, y = 3, width = 6, height = 5 }
      frames = { 99, 100, 115 }
    end

    create_entity(0,{
      type="saw",

      x=x,
      y=y,
      z=1,
      width=8,
      height=8,
      sprite=99,
      hitbox = hitbox,

      animations={
        idle={
          fps=30,
          frames=frames,
          loop=true
        }
      },

      init=function(self)
        self:animate("idle")
      end,

      draw=function(self)
        palt(0,false)
        palt(11,true)
        spr(self.sprite, self.x, self.y, 1, 1, flipx, flipy)
        palt()
      end
    })
  end
}



spike={
  new=function(self,x,y,sprite)
    sprite = sprite or 83
    
    create_entity(0,{
      type="spike",

      x=x,
      y=y,
      width=8,
      height=8,
      sprite=sprite,

      hitbox = {
        x = 0,
        y = 2,
        width = 8,
        height = 6
      },

      init=function(self)
        if self.sprite == 82 then
          self.hitbox = { x = 4, y = 3, width = 8, height = 5 }
        elseif self.sprite == 84 then
          self.hitbox = { x = 0, y = 3, width = 5, height = 5 }
        end
      end,

      draw=function(self)
        spr(self.sprite,self.x,self.y)
      end
    })
  end
}



star={
  new=function(self,x,y)
    create_entity(2,{
      type="star",

      x=x,
      y=y,
      width=8,
      height=8,
      animations={
        idle={
          fps=6,
          frames={17,33,49,49,33},
          loop=true,
        }
      },

      init=function(self)
        self:animate("idle")
      end,

      update=function(self)

      end,

      draw=function(self)
        local offset=self.frame>3 and -1 or 0
        spr(self.sprite,self.x+offset,self.y,1,1,self.frame>3)
      end
    })
  end
}


ui_star={
  new=function(self,x,y)
    return create_entity(0,{
      type="ui_star",

      x=x,
      y=y,
      width=16,
      height=16,

      animations={
        idle={
          frames={4},
        },
        collected={
          frames={4,6,34,36,38},
          loop=false,
        }
      },

      init=function(self)
        self:animate("idle")
      end,

      update=function(self)

      end,

      draw=function(self)
        spr(self.sprite,cam.x+self.x,cam.y+self.y,2,2)
      end
    })
  end
}



-- effects
transition={
  y=-192,
  color=11,
  speed=.92,
  running=false,
  executed=false,
  target=192,

  init=function(self)
    self.drips={}

    for i=15,0,-1 do
      add(self.drips, {
        x=i*8,
        y=flr(rnd(24))
      })
    end
  end,

  animate=function(self, callback, target, reset)
    if (reset == true or reset == nil) then
      self.y = -192
    end

    self.running=true
    self.executed=false
    self.callback=callback
    self.target=target or 192

    input_enabled = false

    if self.target == 192 then
      sfx(31)
    end
  end,

  update=function(self)
    if self.running then
      if abs(self.target-self.y) <= 1 then
        self.y=self.target
      elseif (self.executed or self.y<self.target/2) then
        self.y=lerp(self.y,self.target,self.speed)
      end

      if self.y >= -192+((self.target+192)/2) and not self.executed then
        self.executed=true

        if (self.callback) then
          self.callback()
        end
      end

      if self.y >= self.target then
        self.running=false
        input_enabled = true
      end
    end
  end,

  draw=function(self)
    for drip in all(self.drips) do
      circfill(cam.x+drip.x+4,cam.y+self.y-drip.y,4,self.color)
      circfill(cam.x+drip.x+4,cam.y+self.y+128+drip.y,4,self.color)
      rectfill(cam.x+drip.x,cam.y+self.y-drip.y,cam.x+drip.x+8,cam.y+self.y+128+drip.y,self.color)
    end
  end
}




-- utilities
function autotile(map_x,map_y,map_w,map_h,flag,rules)
  for x=map_x,map_x+map_w-1 do
    for y=map_y,map_y+map_h-1 do
      if fget(mget(x,y),flag) then
        local bitmask=0

        for dy = -1, 1 do
          for dx = -1, 1, dy==0 and 2 or 1 do
            local bit = (1 - dy) * 3 + 1 - dx
            bit = shl(1, bit < 4 and bit or bit - 1)
            if fget(mget(x+dx, y+dy),flag) or
            x+dx<map_x or x+dx>=map_x+map_w or
            y+dy<map_y or y+dy>=map_y+map_h then
              bitmask = bor(bitmask, bit)
            end
          end
        end

        for rule in all(rules) do
          local rulemask=rule[1]
          local sprite=rule[2]

          if type(sprite)=="table" then
            sprite=rnd(sprite)
          end

          if (band(bitmask,rulemask)==rulemask) then
            mset(x,y,sprite)
          end
        end
      end
    end
  end
end

function tiles(x1,y1,x2,y2)
  local tiles={}

  for x=flr(x1/8),flr(x2/8) do
    for y=flr(y1/8),flr(y2/8) do
      add(tiles, tget(x,y))
    end
  end

  return tiles
end

function tget(mx,my)
  return {
    x=mx*8,
    y=my*8,
    mx=mx,
    my=my,
    sprite=mget(mx,my)
  }
end

function log(obj)
  printh(tostring(obj))
end

function tostring(obj)
  if type(obj)=="table" then
    local str="{"
    local add_comma=false

    for k,v in pairs(obj) do
      str=str..(add_comma and ", " or " ")
      str=str..k.."="..tostring(v)
      add_comma=true
    end

    return str.." }"
  else
    return tostr(obj)
  end
end

function load_level(id)
  data=tostr(dget(id))
  stars=0
  prev_stars=tonum(sub(data,1,1))
  high_score=tonum(sub(data,2)) or 0
  score=1000
  level_id=id
  level=levels[id]

  win_screen_y=-160
  win_screen_target_y=-160
  points_y=32
  menu_id=3

  clear_map_data()
  load_map_data()
  autotile(0,0,level_width,level_height,tilemap["w"],tilesets[1])

  ui_stars={}
  for i=1,3 do
    add(ui_stars, ui_star:new(4+((i-1)*16), 4))
  end
end

function clear_map_data()
  entities={}
  memset(0x2000,0,0x2fff-0x2000)
end

function load_map_data()
  local data=""
  local count=""

  level_width = 0

  for c=1,#level do
    local char = tostr(sub(level,c,c))

    if tilemap[char] then
      level_width += 1
    elseif char == "\n" and level_width > 0 then
      break
    end
  end

  for i=1,5 do
    for j=1,level_width do
      data=data.."w"
    end
  end

  for i=1,#level do
    local char = sub(level,i,i)

    if tonum(char) then
      count = count..char
    elseif tilemap[char] then
      for j=1,max(1,tonum(count)) do
        data = data..char
      end

      count=""
    end
  end

  for i=1,6 do
    for j=1,level_width do
      data=data.."w"
    end
  end

  level_height = #data/level_width

  for y=0,level_height-1 do
    for x=0,level_width-1 do
      local i=(y*level_width)+x+1
      local char=sub(data,i,i)
      local value=tilemap[char]

      if value then
        if type(value) == "function" then
          value(x,y)
        elseif type(value) == "table" then
          mset(x,y,rnd(value))
        else
          mset(x,y,value)
        end
      end
    end
  end
end

function create_entity(layer, table)
  entities[layer]=entities[layer] or {}
  local entity=merge({{
    animations={},
    animation=nil,
    frame=1,

    hitbox = {
      x = 0,
      y = 0,
      width = 8,
      height = 8
    },

    init=function(self)
      -- noop
    end,

    update=function(self)
      -- noop
    end,

    draw=function(self)
      -- noop
    end,

    destroy=function(self)
      del(entities[layer], self)
    end,

    animate=function(self, name)
      self.animation=self.animations[name]
      self.frame=1
    end
  }, table})

  entity:init()

  add(entities[layer], entity)
  return entity
end

function each_entity(callback)
  for layer,group in pairs(entities) do
    for entity in all(group) do
      callback(entity, layer)
    end
  end
end

function collide(obj,other)
  return other.x + other.hitbox.x < obj.x + obj.hitbox.x + obj.hitbox.width - 1
  and other.x + other.hitbox.x+other.hitbox.width - 1 > obj.x + obj.hitbox.x
  and other.y + other.hitbox.y < obj.y + obj.hitbox.y + obj.hitbox.height - 1
  and other.y + other.hitbox.y + other.hitbox.height > obj.y + obj.hitbox.y
end

function screen_shake()
  local fade = 0.95
  local offset_x=16-rnd(32)
  local offset_y=16-rnd(32)
  offset_x*=shake_offset
  offset_y*=shake_offset

  cam.x=cam.x+offset_x
  cam.y=cam.y+offset_y

  shake_offset*=fade
  if shake_offset<0.05 then
    shake_offset=0
  end
end

function shake(amount)
  shake_offset=amount or .1
end

function lerp(pos,tar,perc)
  return (1-perc)*tar + perc*pos
end

function set_timer(frames,func)
  timers=timers or {}
  add(timers, {frames,func})
end

function animate(entity)
  local animation = entity.animation

  if animation then
    local fps = animation.fps ~= nil and animation.fps or 15

    if frame%(60/fps)==0 then
      if (entity.frame<#animation.frames) then
        entity.frame+=1
      elseif animation.loop then
        entity.frame=1
      end
    end

    entity.sprite=animation.frames[entity.frame]
  end
end

function merge(tables)
  local result={}

  for t in all(tables) do
    for k,v in pairs(t) do
      if (type(result[k])=="table" and type(v)=="table") then
        result[k]=merge({result[k],v})
      else
        result[k]=v
      end
    end
  end

  return result
end

function add_points(pts)
  points=pts
  points_y=16
  score+=points
end

function transparent(callback)
  if transparency_enabled == 0 or show_transparent then
    callback()
  end
end

function mcpy(dest,src)
  for i=0,319,4 do
    poke4(dest+i,peek4(src+i))
  end
end

function sprint(text,x,y,col,factor)
  poke(0x4580,peek(0x5f00+col))
  poke2(0x4581,peek2(0x5f00))
  poke4(0x4583,peek4(0x5f28))
  poke2(0x4587,peek2(0x5f31))
  poke(0x4589,peek(0x5f33))
  poke(0x5f00+col,col)
  poke2(0x5f00,col==0 and 0x1100 or 0x0110)
  mcpy(0x4440,0x0)
  mcpy(0x0,0x6000)
  camera()
  fillp(0)
  rectfill(0,0,127,4,(16-peek(0x5f00))*0x0.1)
  print(text,0,0,col)
  mcpy(0x4300,0x6000)
  mcpy(0x6000,0x0)
  mcpy(0x0,0x4300)
  camera(peek2(0x4583),peek2(0x4585))
  sspr(0,0,128,5,x,y,128*factor,5*factor)
  mcpy(0x0,0x4440)
  poke(0x5f00+col,peek(0x4580))
  poke2(0x5f00,peek2(0x4581))
  fillp(peek2(0x4587)+peek(0x4589)*0x.8)
end

function action()
  return btnp(Ž) or btnp(—)
end

function create_dust(opts)
  opts = opts or {}

  local x = opts.x
  local y = opts.y
  local dx = opts.dx or 0
  local dy = opts.dy or 0
  local life = opts.life or 15
  local count = opts.count or 10
  local d = opts.d or 2

  for i=1,10 do
    local pdx = (dx + (rnd(0.5) - 0.25) * max(1,d)) or (rnd() - 1)
    local pdy = (dy + (rnd(0.5) - 0.25) * max(1,d)) or (rnd() - 1)

    add(particles, create_particle({
      x = x,
      y = y,
      vx = pdx,
      vy = pdy,
      d = rnd(d),
      life = life + rnd(30) - 15,
      c = opts.c
    }))
  end
end

function create_particle(opts)
  opts = opts or {}

  local x = opts.x
  local y = opts.y
  local vx = opts.vx or 0
  local vy = opts.vy or -1
  local d = opts.d or 1
  local c = opts.c or 7
  local life = opts.life or 15

  return {
    life = life,
    x = x,
    y = y,
    vx = vx,
    vy = vy,
    d = d,

    update = function(self)
      self.x += self.vx
      self.y += self.vy
      self.life -= 1
      self.vy += .025
      self.vx *= .95
      self.vy *= .95
      self.d *= .95

      if self.life <= 0 then
        del(particles, self)
      end
    end,

    draw = function(self)
      transparent(function()
        circfill(self.x, self.y, self.d, c)
      end)
    end
  }
end

function draw_bg_building(x,y)
  local windows=0

  rectfill(x,y,x+12,128,3)

  for wx=x+1,x+7,6 do
    for wy=y,y+24,8 do
      if rnd()>.8 then
        rectfill(wx+1,wy+2,wx+3,wy+6,6)
        rectfill(wx+2,wy+3,wx+2,wy+5,7)
      end
    end
  end
end

function draw_x_button(x,y)
  x = x or 58
  y = y or 106

  circfill(x,y,5,13)
  circfill(x,y-1,5,9)
  line(x-2,y-3,x+2,y+1,13)
  line(x+2,y-3,x-2,y+1,13)
  line(x-2,y-2,x+2,y+2,7)
  line(x+2,y-2,x-2,y+2,7)
end

function initialize_eyes()
  eye_pos=0
  eye_speed=.85
  eye_frames={
    {{58,74},{54,74},{58,74}}, -- white
    {{67,83},{58,80},{67,81}}, -- left eye
    {{73,83},{68,81},{76,81}}, -- right eye
  }
  eyes={
    {eye_frames[1][1][1], eye_frames[1][1][2]},
    {eye_frames[2][1][1], eye_frames[2][1][2]},
    {eye_frames[3][1][1], eye_frames[3][1][2]},
  }
end

function update_eye_position()
  eye_pos+=1

  if eye_pos>#eye_frames then
    eye_pos=1
  end

  set_timer(120, update_eye_position)
end

function draw_character(y)
  y = y or 62


  local offset=flr(sin(time()*.8)*1.5)
  sspr(0,96,32,32,48,y+offset,32,32-offset)

  eyes={
    {
      lerp(eyes[1][1],eye_frames[1][eye_pos][1],eye_speed),
      lerp(eyes[1][2],eye_frames[1][eye_pos][2],eye_speed)
    },
    {
      lerp(eyes[2][1],eye_frames[2][eye_pos][1],eye_speed),
      lerp(eyes[2][2],eye_frames[2][eye_pos][2],eye_speed)
    },
    {
      lerp(eyes[3][1],eye_frames[3][eye_pos][1],eye_speed),
      lerp(eyes[3][2],eye_frames[3][eye_pos][2],eye_speed)
    },
  }

  local eye_offset=flr(offset/2)
  spr(228,eyes[1][1],eyes[1][2]+eye_offset,3,2)
  circfill(eyes[2][1],eyes[2][2]+eye_offset,2,0)
  pset(eyes[2][1]+1,eyes[2][2]-1+eye_offset,7)
  circfill(eyes[3][1],eyes[3][2]+eye_offset,2,0)
  pset(eyes[3][1]+1,eyes[3][2]-1+eye_offset,7)
end

function create_cloud(x,y,speed,scale)
  clouds = clouds or {}

  add(clouds, {
    x=x or flr(rnd(8))*16,
    y=y or 8+(rnd(3)*16),
    speed={
      x=speed or -1*(rnd()/10)
    },
    scale=scale or 1
  })
end

function draw_clouds()
  for cloud in all(clouds) do
    if abs(cloud.scale) >= 2 then
      transparent(function()
        draw_cloud(cloud, 6)
      end)
    else
      draw_cloud(cloud, 6, 0, 1)
      draw_cloud(cloud)
    end
  end
end

function draw_cloud(cloud, color, offset_x, offset_y)
  color = color or 7
  offset_x = offset_x or 0
  offset_y = offset_y or 0

  local x,y,scale = cloud.x, cloud.y, cloud.scale

  circfill(x + (offset_x * scale), y + (offset_y * scale), 3 * scale, color)
  circfill(x + (6 * scale) + (offset_x * scale), y + (offset_y * scale), 4 * scale, color)
  circfill(x + (8 * scale) + (offset_x * scale), y - 4 + (offset_y * scale), 4 * scale, color)
  circfill(x + (10 * scale) + (offset_x * scale), y + (offset_y * scale), 5 * scale, color)
  circfill(x + (13 * scale) + (offset_x * scale), y + (offset_y * scale), 2 * scale, color)
  circfill(x + (16 * scale) + (offset_x * scale), y + (offset_y * scale), 3 * scale, color)
end

function draw_buildings()
  -- bg buildings
  local offsets={0,18,24,36,24,42,16,40,24,0,10}
  for i=1,10 do
    local x=(i-1)*13
    local y=48+offsets[i]
    draw_bg_building(x,y)
  end

  -- fg buildings
  rectfill(0,70,28,76,5)
  rectfill(0,77,26,78,15)
  rectfill(0,79,26,128,4)

  rectfill(98,74,128,80,5)
  rectfill(100,81,128,82,15)
  rectfill(100,83,128,128,4)

  spr(198,4,82,1,2)
  spr(198,16,82,1,2)
  spr(198,4,104,1,2)
  spr(198,16,104,1,2)

  spr(198,104,86,1,2)
  spr(198,116,86,1,2)
  spr(198,116,108,1,2)

  -- close building
  for w=48,112,2 do
    local x=64-(w/2)
    local y=84+((w-48)/2)
    rectfill(x,y,x+w,y,5)
  end

  rectfill(8,117,120,125,12)
  rectfill(12,126,116,128,15)

  palt(0,false)
  palt(15,true)
end

function printc(str,y,c,c2)
  y = y or 64
  c = c or 7
  c2 = c2 or 6
  local x = 64-flr((#str * 4) / 2)

  print(str, x, y+1, c2)
  print(str, x, y, c)
end

function draw_score_ui()
  if max_level_id >= #levels then
    local total_stars = 0
    local total_score = 0

    for i=1,#levels do
      local data = tostr(dget(i))
      total_stars += tonum(sub(data,1,1))
      total_score += tonum(sub(data,2)) or 0
      exit()
    end

    local score_string = tostr(total_score)

    print("stars: ", 11, 119, 7)
    print(total_stars .."/" .. #levels * 3, 36, 119, 6)
    print(score_string, 119 - #score_string * 4, 119, 6)
    print("score: ", 119 - (#score_string + #"score: ") * 4, 119, 7)
  end
end



-- data
levels={
  [[
    wwwwwwwwwwwwwwwwwwww
    w......l...l.......w
    w..h.........#.....w
    w.p...s.ms..s...c..w
  ]],

  [[
    wwwwwwwwwwwwwwww
    wwwww.l......www
    wwwww....#...www
    wwwwwh....c..www
    wwwwws..wwwwwwww
    wwwww...wwwwwwww
    wwwww..swwwwwwww
    wwwww...wwwwwwww
    wwwwws..wwwwwwww
    wwwww........www
    wwwww........www
    wwwww..m...p.www
    wwwwwwwwwwwwwwww
  ]],

  [[
    wwwwwwwwwwwwwwwwwwwwwww
    ww.....l.......l.....ww
    ww.........h....#.h..ww
    wwmp.s.....s.....s.c.ww
    wwwwww...wwwww...wwwwww
    wwwwww...wwwww...wwwwww
    wwwwww<^>wwwww<^>wwwwww
  ]],

  [[
    ww.l.......l.........wwww
    ww.....h.............wwww
    ww.............t...p.wwww
    ww...wwwwwwwwwwwwwwwwwwww
    ww...wwwwwwwwwwwwwwwwwwww
    ww...wwwwwwwwwwwwwwwwwwww
    ww.......l.....l.....l.ww
    ww.h.............h.....ww
    ww....s.....s.....s....ww
    ww...www...www...www...ww
    ww...www...www...www.#.ww
    ww<^>www<^>www<^>www.c.ww
  ]],

  [[
    ww.......l.....l...#..www
    ww....h..........h....www
    ww.................c..www
    ww...www...www...wwwwwwww
    ww...www...www..swwwwwwww
    ww...www..swww...wwwwwwww
    ww...www...www...wwwwwwww
    ww...www<^>www...wwwwwwww
    ww...wwwwwwwwws..wwwwwwww
    ww...wwwwwwwww...wwwwwwww
    ww.p.wwwwwwwww<^>wwwwwwww
  ]],

  [[
    ww.....l.....l.....l....www
    ww...................#..www
    ww..h......s.....h....c.www
    ww.......wwwww.......wwwwww
    ww...s...wwwww...s...wwwwww
    ww..===..wwwww..===..wwwwww
    ww.......wwwww.......wwwwww
    ww.t.p...wwwww..mz...wwwwww
  ]],

  [[
    ww........wwwwwwwwwwwwwwwww
    ww........wwwwwwwwwwwwwwwww
    ww...c....wwwwwwwwwwwwwwwww
    ww..====..wwwwwwwwwwwwwwwww
    ww..........l.....l......ww
    ww#......................ww
    ww..........z..s..z......ww
    wwwwwwwwwwwwwwwwwwwwww...ww
    wwwwwwwwwwwwwwwwwwwwww...ww
    wwwwwwwwwwwwwwwwwwwwwws..ww
    ww..........l.....l......ww
    ww.............#.........ww
    ww.tp.......z..s..z......ww
  ]],

  [[
    ww....l.....l......l...ww
    ww.............#.....s.ww
    wwc....................ww
    wwwwwwww...www...wwwwwwww
    wwwwwwww...www...wwwwwwww
    wwwwwwww...www...wwwwwwww
    ww...www...www...wwwwwwww
    wwhs.www...www...wwwwwwww
    ww...www...www...wwwwwwww
    ww.........www.........ww
    ww...h.....www.......s.ww
    ww.t.....<^www^>..p.m..ww
  ]],

  [[
    wwwwwwwwwwwwwwwww...w
    wwwwwwwwwwwwwwwww.c.w
    wwwwwwwwwwwwwwwww===w
    wwwwwwwwwwwwwwwww...w
    wwwwwwwwwwwwwwwww...w
    wwwww....l.........sw
    wwwww...............w
    wwwww...........zm..w
    wwwww...www...wwwwwww
    wwwww.h.www...wwwwwww
    wwwwws..www...wwwwwww
    ww.v....www...wwwwwww
    ww/.....www..swwwwwww
    ww..p...www...wwwwwww
  ]],

  [[
    ww......l.....wwwwwww...ww
    ww........h...wwwwwww.c.ww
    ww.s..m.....p.wwwwwww=+=ww
    ww..\wwwwwwwwwwwwwwww.l.ww
    ww...wwwwwwwwwwwwwwww...ww
    ww..\wwwwwwwwwwwwwwwws..ww
    ww.........l............ww
    ww.h...........#........ww
    ww......................ww
    ww......wwwwww...s...wwwww
    ww.====.wwwwww..===..wwwww
    ww<^^^^>wwwwww<^^^^^>wwwww
  ]],
}


prompts = {
  "press — to start moving",
  "press — twice to wall jump",
  "watch out for pointy things"
}


tilemap={
  ["."]=function(x,y)
    -- noop
  end,
  ["w"]=1,
  ["="]=85,
  ["+"]=89,
  ["t"]=66,
  ["l"]=86,
  ["p"]=function(x,y)
    game.player=player:new(x*8,y*8)
  end,
  ["c"]=function(x,y)
    cat:new(x*8,y*8)
  end,
  ["s"]=function(x,y)
    star:new(x*8,y*8)
  end,
  ["^"]=function(x,y)
    spike:new(x*8,y*8)
  end,
  ["<"]=function(x,y)
    spike:new(x*8,y*8,82)
  end,
  [">"]=function(x,y)
    spike:new(x*8,y*8,84)
  end,
  ["z"]=function(x,y)
    saw:new(x*8,y*8)
  end,
  ["/"]=function(x,y)
    saw:new(x*8,y*8,'right')
  end,
  ["\\"]=function(x,y)
    saw:new(x*8,y*8,'left')
  end,
  ["v"]=function(x,y)
    saw:new(x*8,y*8,'down')
  end,
  ["#"]=function(x,y)
    mset(x,y,rnd({64,80}))
    mset(x+1,y,rnd({65,81}))
  end,
  ["m"]=function(x,y)
    mset(x,y-1,101)
    mset(x+1,y-1,102)
    mset(x+2,y-1,103)
    mset(x,y,117)
    mset(x+1,y,118)
    mset(x+2,y,119)
  end,
  ["h"]=function(x,y)
    mset(x,y,96)
    mset(x+1,y,97)
    mset(x,y+1,112)
    mset(x+1,y+1,113)
  end
}


tilesets={
  {
    {0b00000000,8},
    
    {0b01000000,56},
    {0b00010000,59},
    {0b00001000,57},
    {0b00000010,24},
    
    {0b01010000,43},
    {0b01001000,41},
    {0b01000010,40},
    {0b00011000,{58,60,61,62}},
    {0b00010010,11},
    {0b00001010,9},
    
    {0b01011000,{42,42,42,42,42,42,42,44,45,46}},
    {0b01010010,27},
    {0b01001010,25},
    {0b00011010,{10,12,13,14}},
    
    {0b01011010,{26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,29,28,30}},
  }
}


__gfx__
00000000bbbb00000000000000000000000000000000000000000000000000000555555005555555555555555555555055555555555555555555555500000000
00000000bb0000000000000000000000000000000000000000000000000000005111111551111111111111111111111511333311111111111111111100000000
00700700b00000000000000000000000000000063000000000000000000000005111111551111111111111111111111511133311111111111111111100000000
00077000b000000000000ff000000000000000636300000000000066630000005111111551111111111111111111111511133311111111111111111100000000
000770000000000000bbffffbb000000000000636300000000000063630000005111111551111111111111111111111511133311111111111111111100000000
007007000000000000b66fb5bb000000006666330666630000066633366630005111111551111111111111111111111511113311111111111111111100000000
000000000000000000bbbb577b000000006333300000630000063336333630005111111551111111111111111111111511113311111111111111111100000000
000000000000000050b77b777b050000000630000006330000036366636330000555555051111111111111111111111511111311111111111111111100000000
bbbbbbbb0007000005b27b277b5f0000000063000063300000006366636300000555555051111111111111111111111511111111111111111111111100000000
bbbbbbbb007a600000bbb5bbbb6ff000000633000006300000006333336300005111111551111111111111111111111513333311111111111111111100000000
bb8828bb7aaaaa6005000666665bf000000630063006300000006366636300005111111551111111111111111111111513333311111111111111111100000000
b882828b07aaa600500bbbbbbbb5b00b006336636630630000063633363630005111111551111111111111111111111511113333111111111111111100000000
2827782807aaa60000000bbbbbbbb0b0006663333366630000066300036630005111111551111111111111111111111511113333111111111111111100000000
827777787a000a60000000bbbbbbb0b0003333000033330000033300003330005111111551111111111111111111111511111111111111111111111100000000
b877070700000000000000b666bbbbb0000000000000000000000000000000005111111551111111111111111111111511111111111111111111111100000000
bb87727b000000000000bb6bbbbbb000000000000000000000000000000000005111111551111111111111111111111511111111111111111111111100000000
bbbbbbbb000700000000000000000000000000000000000000000000000000005111111551111111111111111111111511111111111111111111111100000000
bb8828bb007a60000000000000000000000000000000000000000000000000005111111551111111111111111111111511111111111111111111111100000000
b282882b07aaa6000000000000000000000000000000000000000006300000005111111551111111111111111111111511111111111111111111111100000000
88277288007a60000000000000000000000000666300000000000066630000005111111551111111111111111111111511111111111111111111111100000000
28777778007a60000000000000000000000000666300000000000066630000005111111551111111111111111111111511111111111111111111111100000000
8277070707a0a6000000000000000000000666666666300000666666666663005111111551111111111111111111111511111111111111111111111100000000
b827787b000000000000000630000000000666666666300000666666666663005111111551111111111111111111111511111111111111111111111100000000
bb8282bb000000000000066666300000000366666663300000066666666630005111111505555555555555555555555055555555555555555555555500000000
bb8828bb000700000000036663300000000066666663000000006666666300005111111505555555555555555555555055555555555555555555555500000000
b282882b007a60000000006663000000000066666663000000066666666630005111111551111111111111111111111511111111111111111111111100000000
88277288007a60000000063336300000000066666663000000066666666630005111111551111111111111111111111511111111111111111111111100000000
28777778007a60000000033003300000000666333666300000666663666663005111111551111111111111111111111511111111111111111111111100000000
82770707007a60000000000000000000000663000366300000666330336663005111111551111111111111111111111511111111111111111111111100000000
88877878007a60000000000000000000000333000033300000333000003333005111111551111111111111111111111511111111111111111111111100000000
b828282b000000000000000000000000000000000000000000000000000000005111111551111111111111111111111511111111111111111111111100000000
bb8288bb000000000000000000000000000000000000000000000000000000000555555005555555555555555555555055555555555555555555555500000000
0000000000000000060000600060000000a00000bbbbbbbbbbdbbdbbbbbbbbbbbbbbbbbb000000ee000000000000000000000000ffffffffffffffff00000000
00ff0000000f00000060060066666000aaaaa000bbbdbbbbbd9dd9dbbbbbddbbbdbbbbbb000000ee000000000000600000000000ffffffffffffffff00000000
01fff10000fff10055555550060600000aaa0000bbd9dbbbd9a99a9dbbbdd9dbd9dbbddb000000ee000000000006660000000000ffffffffffffffff00000000
01fff1fff1fff10053333350066600000aaa0000bd9a9dbbbd9aa9dbbbbd9a9dd99dd9db000000ee000000000006b60000000000ffffffffffffffff00000000
01fff1fff1fff1f05333335060006000a000a000bbd9dbbbbd9aa9dbbdd9aaaaaaa999db000000ee000000000006b60000000000ffffffffffffffff00000000
0066f1fff1fff1f0533333500000000000000000bbbdbbbbd9a99a9dd994443443a439db000000ee000000000066b66000000000ffffffff00ff00ff00000000
000061f666fff1f0555555500000000000000000bbbbbbbbbd9dd9dbbd94a43a43a439db000000ee00000000006bbb6000000000fffffffff00ff00f00000000
0000066000666600100000100000000000000000bbbbbbbbbbdbbdbbbd94443a43a43a9d000000ee00666666666bbb6666666660ffffffffff00000f00000000
00000000000000000000000000000000000000004444444400005000d9a4aa4a4344a9db444444440066bbbbbbbbbbbbbbbbb660fffffffff00000ff00000000
000000000000ffff0000007000700070007000003333333300005000bd94aa44434439db3333333300566bbbbbbbbbbbbbbb6650fffffffff000000f00000000
0000fff0fff1ffff0000006000600060006000000000000000005000bd9a99aa9aa9999d00005000000566bbbbbbbbbbbbb66500f0000000ff00000f00000000
0ff1fff1fff1ffff0000076607660766076600000000000000005000bbd9dd99d99ddddb000050000000566bbbbbbbbbbb6650000070000000f0000f00000000
0ff1fff1fff1f6600000066606660666066600000000000000005000bbddbd9dbd99dbbb0000500000000566bbbbbbbbb6650000f0700770f0f0000f00000000
0ff1fff1fff660000000766676667666766670000000000000111110bbdbbbdbbbddbbbb0000500000000056bbbbbbbbb6500000f0000000f00000ff00000000
0061fff1fff000000000666666666666666660000000000001111111bbbbbbbbbbbbbbbb0000500000000066bbbbbbbbb6600000f00fff000000000f00000000
00066666666000000005555555555555555555000000000001556551bbbbbbbbbbbbbbbb000050000000006bbbbbbbbbbb600000f0fffff00000ffff00000000
006666666666600000000000bbbbbbbbbbbbbbbb0000000000000000000000006bbbbbbbbbb7bbbb0000066bbbbbbbbbbb660000000000000000000000000000
000666666666000000000000bbbbbbbbbbbbbbbb00000000000000000000000066bbbbbbbb66bbbb000006bbbbb666bbbbb60000000000000000000000000000
000611161116000000000000bbbbbbbbbbbbbbbb00000000000000000000000066bb7bbb6666bbbb000066bbb6665666bbb66000000000000000000000000000
000655565556000000000000bb76bbbbbbbbbb7b00000000000000000000000057666bbb756bbbbb00006bb66655055666bb6000000000000000000000000000
000655565556000000000000bbb66bbb766bb66b0000000555555555500000000566bbbb506bbbbb000666665500000556666600000000000000000000000000
000666666666000000000000bbb66bb7b666666b00000555555555555550000066bbbbbb6666bbbb000666550000000005566600000000000000000000000000
000611161116000000000000b6675666bb6506bb00005555555555555555000066bbbbbbbb667bbb000555000000000000055500000000000000000000000000
0006555655560000000000006665066bbb6756bb000055555555555555550000b67bbbbbbbbbbbbb000000000000000000000000000000000000000000000000
0006555655560000a000000abbbbbbbb0000000005505555555555555555055076bbbbbbfffffffffff2e333332e2fffffffffff000000000000000000000000
0006666666660000aa0000aabbbbbbbb00000000555566666666666666665555b66bbbbbfffffffffff22233333e2fffffffffff000000000000000000000000
0066666666666000aaaaaaaabbbbbbbb00000000555655555555555555556555666bbbbbfffffffffff2e23333e2ffffffffffff000000000000000000000000
0001111111110000aaaaaaaabbb76bbb00000000055655555555555555556550506b7bbb22ff2222fff2eee333222fff22f2e22f000000000000000000000000
0000000000000000aaaaaaaabbbb66bb0000000005565555555555555555655075666bbbee22ee2effff22e3333eefffee22eee2000000000000000000000000
0000000000000000aaaaaaaab66666bb000000000055611111111111111655006666bbbb23e2e223ffff2e33322e2fff23e232e2000000000000000000000000
0000000000000000aaaaaaaa666056b7000000000055155555555555555155006bbbbbbb333ee333fff2e333e2ee2fff33333222000000000000000000000000
0000000000000000aaaaaaaa7b6576660000000000555555555555555555550067bbbbbb33333333fff2e2332222ffff333333e2000000000000000000000000
00000000000000000000000000500000000000050000000000000000000000000077707000000000000000000000000000000000000000000000000000000000
0000000bbbb000000000000335550000000000515500000000000000777777700744477070007000000000000000000000000000000000000000000000000000
0000bbbbbbbbb0000000003355355000000005111155000000000000444444407400777077007700000000000000000000000000000000000000000000000000
000bbbbbabbbbb000000033553135500000051111111550000000000777777704000444077707770000000000000000000000000000000000000000000000000
00bbbbbbbbbbbbb0000033555f365550000511111111150000000000444444407770007077407740000000000000000000000000000000000000000000000000
00bbbbbbbbbbbbb0000335555ff655000033111111115f0000000000777777707740074074007400000000000000000000000000000000000000000000000000
0bbbbbbbbbbbbbbb0033555555f5560000ff33111115660000000000444444407477740040004000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb033f335555556f0000ffff33115f6f0000000000000000004044400000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbabbbb00f3ff335556660000f3ffff3366660000000000fffffffffffffffffff7777fffffffffffffffffffffffffffffffffffffffffffffffff
bbbbbbabbbbbbbb000fa3fff336f6f0000fa3f3fff6f6f0000000000ff77777fffffffffff700007ffffffffffffffffffffffffffffffffffffffffffffffff
bbbbbbbbbbbbbbb000faaffff666660000faafa3f666660000000000f7000007fffffffff700bb007fffffffffffffffffffffff7777ffffffffffffffffffff
0bbbbbbbbbbbbbb000f3af3fff6f600000f3afaaff6f6f0000000000700bbb007fffffff700bbba07ffffffffffffffffffffff770007fffffffffffffffffff
00bbbbbbbbbbbb0000ff3f43f666000000ff3f3af66666500000000070bbbbb007fffff770bbbba07ffffffffffffffffffffff700a007ffffffffffffffffff
000bbbbbbbbbb0000000ff44ff60000003fffff3ff6f65000000000070bbbbba07ffff7000bbba007ffffffffffffffffffffff70bba007fffffffffffffffff
00000bbbbbbb000000000044f60000000333fffff66656000000000070bbbbba07fff700bbbba0077ffffffffffffffffffffff70bbba007fffffff777ffffff
0000000bbb00000000000004f000000000ff33ffff656f000000000070bbbbba007ff70bbbbba077777777ffff7777777777fff70bbbba007fffff70007fffff
000000bbb00000000000b0bbb00bb00000ffff33f656660000000000f70bbbbba07f700bbbbba0770000007ff7000000000077f70bbbbba007fff700a007ffff
0000bbbbbbb000000bbbbbbbbbbbbbb000ffffff336f6f0000000000f70bbbbba07f70bbbbbba0700bbbb007700bbbbbbba0007700bbbbba007ff70bba007fff
000bbbbbbbbbb000bbbbbbbbbbbbbbbb00ff3ffff666660000000000f70bbbbba07f70bbbbba0070bbbbba0700bbbbbbbbbba00770bbbbbba007f70bbba07fff
00bbbbbbbbbbbb00bbbbbbbbbbbbbbbb00ff43ffff6f600000000000ff70bbbba07700bbbbba0770bbbbba070bbbbbbbbbbbba0770bbbbbbba00770bbba07fff
0bbbbbbbbbbbbbb00bbbbbbbbbbbbbb000ff44fff666000000000000ff70bbbba0770bbbbba00700bbbbba070bbbba0bbbbba00770bbba0bbba0770bbba007ff
0bbbbbbbbbbbbbbb0bbbbbbbbbbbbbbb000044ffff60000000000000ff70bbbba0770bbbbba0770bbbbbba070bbbba00bbba007f700bba0bbba00700bbba07ff
0bbbbbbbbabbbbbb0bbbbbbbbabbbbbb000004fff600000000000000ff70bbbba0700bbbbba0770bbbbbba0700bbba000bbba07ff70bba0bbbba0770bbba07ff
bbbbabbbbbbbbbbbbbbbabbbbbbbbbbb0000000ff000000000000000ff70bbbba000bbbbba00700bbbbbba070bbbba0700bba07ff70bbba0bbba0070bbba07ff
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000ff70bbbba00bbbbbba0770bbbbbba0070bbbba0770bba07ff70bbba0bbbba070bbba07ff
bbbbbbbbbbbbbbb0bbbbbbbbbbbbbbb0000000000000000000000000ff70bbbbbb0bbbbbba0770bbbbbba0770bbbba0770bba07ff70bbba0bbbba007bbba07ff
bbbbbbbbbbbbbbb00bbbbbbbbbbbbb00000000000000000000000000ff70bbbbbbbbbbbba00700bbbbbba0770bbbba0770bba07ff70bbba00bbbba00bbba07ff
bbbbbbbbbbbbbbb00bbbbbbbbbbbbb00000000000000000000000000ff70bbbbbbbbbbba00770bbbbbbba0770bbba00770bba07ff70bbba00bbbbba0bbba07ff
0bbbbbbabbbbbb0000bbbbbabbbbb000000000000000000000000000fff70bbbbbbbbbba07070bbbbbbba0770bbba07770bba07ff70bbbba00bbbba0bbba07ff
00bbbbbbbbbbbb00000bbbbbbbbb0000000000000000000000000000fff70bbbbbbbbba007070bbbbbbba0770bbba07700bba07ff70bbbba00bbbbbbbbba07ff
000bbbbbbbbbb00000000bbbbbb00000000000000000000000000000fff70bbbbbbbba007f700bbbbbbba0770bbba0000bbba07ff70bbbba000bbbbbbbba07ff
00000bbbbbb00000000000bbbb000000000000000000000000000000fff70bbbbbbbba07ff70bbbbbbbba0770bbbbba00bbba07ff70bbbba070bbbbbbbba07ff
ffffffffffff22222222ffffffffffffffffffffffffffff00000000fff70bbbbbbba007ff70bbbbbbbba0770bbbbbbbbbba007ff70bbbba070bbbbbbbba07ff
fffffffff22288888888222fffffffffffffffffffffffff00000000fff70bbbbbba007ff700bbba0bbba0770bbbbbbbbba007fff70bbbba070bbbbbbbba07ff
ffffffff2e88888822222222ffffffffffffffff0fffff0ffffffff0fff70bbbba0007fff70bbba00bbba0770bbbbbbbbba007fff70bbbba0700bbbbbbba07ff
ffffff22ee8882222888888822ffffffffffffff00fff00ff33f33f0fff70bbbba077ffff70bbba00bbba0770bbbbbbbbbba07fff70bbbba0770bbbbbbba07ff
fffff2222222228888888822222ffffffff00fff0000000ff33f3cf0fff70bbbba07fffff70bba000bbba0770bbbba00bbba07fff70bbba007700bbbbbba07ff
ffff2eeee8822228888888888282ffffffff00000770000ff33fccf0fff70bbbba07ffff700bba070bbba0770bbba000bbba007ff70bbbba07f700bbbbba07ff
fff2eeee888888822288822222882ffff000000007700700f3cfccf0fff70bbbba07ffff70bbba070bbba0770bbba070bbbba07ff70bbbba07ff70bbbba007ff
fff2eeee888888882222288822822fffff00000f0000000ffccfccf0fff70bbbba07ffff70bbba00bbba00770bbba0700bbba07ff70bbbba07ff70bbbba007ff
ff2eeeee8888888888228888288282fff0000f0fff0ffffffffffff0ff700bbbba07fff700bbba00bbba00770bbba0770bbba007f70bbbba07ff700bbbba07ff
f222222222288888888822822822882ff0000f000f000ffffccfccf0ff70bbbbba07fff70bbbbbbbbbbba0770bbba0770bbbba00770bbbba007ff70bbbba007f
f2eeeeee88222228888882228828822ff00000ff0fff0ffffccfccf0ff70bbbbba07fff70bbbbbbbbbbba0770bbba0770bbbbba0770bbbbba07ff70bbbbba07f
f2eeeeee88888822288888228828822ff000000ffffffffffccfccf0ff70bbbbba07fff70bbbbbbbbbbba0770bbba07700bbbba0770bbbbba07ff700bbbba07f
2eeeeeee888888882288882882888282ff00000ffffffffffccfccf0f700bbbba007fff70bbba0000bbba0770bbba07f700bbba0770bbbbba07fff70bbbba07f
2eeeeeee888888888228822888882282f00000fffffffffffccfccf0f70bbbbba07ffff70bbba0000bbba0770bbba07ff70bbba0770bbbbba07fff700bba007f
22222222288888888822828888882882f00ff00fffffffff55555550f70bbbbba07ffff70bbba0770bbba0770bbba07ff70bbba0770bbbbba07ffff7000a007f
2ee2eee2222222888882228888822882ff00ff00ffffffff55555550f70bbbbba07fff700bbba0770bbba0070bbba07ff700bba0770bbbbba07fffff70bba07f
2ee2eeeeee888222288228888822828ffffffffffffffffffffffffff70bbbbba07fff70bbbba0770bbbba070bbba07fff70bbba070bbbbba07fffff70bba07f
2ee2eeeeee888888222288888828822ffffff77777fffffffffffffff70bbbbba07fff70bbbba0770bbbba070bbba07fff70bbba070bbbba007fffff700a007f
2ee22eeeee888888822288888288882fffff7777777ffffffffffffff70bbbbba07fff70bbba007700bbba070bbba07fff70bbba0700bba007fffffff70007ff
2eee2eeeeee88888228888882228888ffff777777777ff77777ffffff70bbbbba07fff700ba007ff70bbba0700ba007fff700ba007700a007fffffffff777fff
f2ee22eeeeeee822288888822822882fff7777777777f7777777fffff70bbbbba07ffff700007fff70bbba0770ba07fffff700007ff70a07ffffffffffffffff
f2eee22eeeeee22e888888228882882fff7777777777777777777ffff700bbba007fffff7777ffff700ba00770ba07ffffff7777fff70a07ffffffffffffffff
f2eee22eeee222ee888882288882282ff77777777777777777777fffff700ba007fffffffffffffff700007f700a07fffffffffffff70a007fffffffffffffff
ff2eee222222eeeee8822288888822fff777777777777777777777fffff70a007fffffffffffffffff7777fff70007ffffffffffff700ba007ffffffffffffff
fff2222eeeeeeeeeee22888888882ffff777777777777777777777fffff70a077fffffffffffffffffffffffff777fffffffffffff70bbba07ffffffffffffff
fff2eeeeeee2eeee222eeee888882ffff777777777777777777777ffff700a07ffffffffffffffffffffffffffffffffffffffffff70bbba07ffffffffffffff
ffff2e22222eee222e2222eeeee2fffff777777777777777777777fff700ba007fffffffffffffffffffffffffffffffffffffffff700ba007ffffffffffffff
fffff22eeeee222eeeeee222222ffffff677777777776777777776fff70bbba07ffffffffffffffffffffffffffffffffffffffffff700007fffffffffffffff
ffffff22e2222e22eeeeeeee22fffffff667777777766677777766fff70bbba07fffffffffffffffffffffffffffffffffffffffffff7777ffffffffffffffff
ffffffff22eeeee222eeeee2ffffffffff6677777766f66777766ffff700ba007fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffff222eeeee222222ffffffffffff66666666fff666666ffffff700007ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffff22222222ffffffffffffffff666666fffff6666ffffffff7777fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
__gff__
0003000000000000030303030303030100000000000000000303030303030301000000000000000003030303030303010000000000000000030303030303030100000000000000000000000000000000000004040404000000040000000000000000000404000000040400000004040000000004000000000400000000040000
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
011000000276002765007050070000760007650070500705027600276500705007050076000765007050070502760027650070500705007600076500705007050276002765007050070500760007650070500705
011000000c5250c5150e5250e5150f5250f515115251151515525155151352513515115251151510525105150f5250f51500505005050f5250f51500505005050f5250f515005050050500505005050050500505
010f00001801118011180111c011240112401124011240112401124011240112401123011230112301123011220112201122011220111c0111c0111c0111c0111c0111c0111c0111c0111c0111c0111c0011c005
011000000276002765186131c60300760007651861300705027600276518613007050076000765186130070502760027651861300705007600076518613007050276002765186130070500760007651861300705
011000000c5250c5150e5250e5150f5250f515115251151515525155151352513515115251151510525105150c5250c5150050500505105251051500505005050f5250f515005050050500505005050050500505
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000700017000170001700007000070000700007000170001700007000070001706017060170601706017073570701707337070170701707017070170731701357013670137701397013d7013f7013f701
0001000006750067500675006750097500e750137500b7000f70011700157000e7000970000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100000575005750057500575007750097500a7500d7500b7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000575004750047500475005750077500a7500c750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000001041010410104101041010410104102041020010000100001000010000128201282012920129201292012920128201272010a70107701067010670106701077010b7010e70110701177011e70126701
000100000a73109731067310361102611016010060100600007000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100001f651236512565125651226511c65117651136510f6510965105651046510465104651046510465103651036510165100651006510000000000000000000000000000000000000000000000000000000
000200000d151111511315114151161511615113151101510e1510b1510815105151031510215100151001510c1010c1010d1000e1000e1000e1000e1000e1000d1000c1000b1000910007100061000510002100
000200000f0210f0410f0510f0511005712067150770b007000070a00707007150071800721007010072800626002200002200024000260000000000000000000000000000000000000000000000000000000000
0001000011731117411176111761117611176112761137611576617776197761d7761e70021706017062870626702207002270024700267000070000700007000070000700007000070000700007000070000700
00010000127111373114751157511675117751197511a7511c7561e75620756227762477625776015062850626502205002250024500265000050000500005000050000500005000050000500005000050000500
000100000d5400854006540085400d54011540125401554012540105401840014400114000e4000d4000c3000f3001330017300183000a1000d1000b1000a0000b0000c1000f00013000171001a0001d0001f000
000100001d3112331125311233111b3111a3111a31117311133131030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100000411104111041110111111101001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00010000153111b3111e3111e3111031111311153111a311143110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 00 04 02 44
00 03 01 43 44
02 03 04 02 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
