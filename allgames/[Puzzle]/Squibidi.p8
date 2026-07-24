pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- squibidi
-- by ahmed khalifa

local world


function _init()
 world=make_gameplay_world()
 world:init()
end

function _update()
 world:update()
end

function _draw()
 world:draw()
 -- for i=0,127 do
 --  local sx=4*sin(time()+i/100)
 --  if sx > 0 then
 --   memcpy(0x6000+i*64+sx,0x6000+i*64,64-sx)
 --   memset(0x6000+i*64, 0x11, sx)
 --  elseif sx < 0 then
 --   memcpy(0x6000+i*64,0x6000+i*64-sx,64-abs(sx))
 --   memset(0x6000+(i+1)*64+sx, 0x11, abs(sx)+1)
 --  end
 -- end
end

function make_gameplay_world()
  return {
    init=function(self)
      self.tile_size=16
      self.width=8
      self.height=7
      self.room_num=0
      self.game_name=make_game_name(12,10)

      self:advance_level()
    end,

    set_map=function(self,idx)
      local start_x,start_y=(((idx-2)%2)*8+flr(rnd()*5))*8,flr((idx-2)/2)*8
      if self.room_num < 6 then
        start_x,start_y=(self.room_num-1)*8,24
      end
      local temp_fish={}
      local temp_horse={}
      local temp_shell={}
      for y=1,self.height do
        for x=1,self.width do
          local tile=mget(start_x+x-1,start_y+y-1)
          local type=0
          if fget(tile,0) then
            type=1
          end
          self.tiles[y][x]=make_tile(x,y,type)
          if fget(tile,1) then
            add(self.entities, make_entrance(1, self.entrance))
          end
          if fget(tile,2) then
            if x==self.width then
              self.exit=y
              add(self.entities, make_exit(self.width,self.exit))
            else
              add(self.entities, make_barncle(x,y))
            end
          end
          if fget(tile,3) then
            add(self.entities, make_water_wall(x,y))
          end
          if fget(tile,4) then
            local c=sget((tile%16)*8,flr(tile/16)*8)
            if c==8 then
              add(temp_fish,{x=x,y=y})
            elseif c==12 then
              add(temp_horse,{x=x,y=y})
            elseif c==9 then
              add(temp_shell,{x=x,y=y})
            end
          end
        end
      end

      shuffle(temp_fish)
      shuffle(temp_horse)
      shuffle(temp_shell)
      local enemy_num=min(2,flr((self.room_num-6)/6))+2+flr(rnd(2))
      local two_health=rnd(0.1)+0.5*min(1,(self.room_num-6)/10)
      if self.room_num < 6 then
        enemy_num = 2
        two_health = 0
      end
      printh(two_health)
      enemy_num=min(enemy_num,#temp_fish + #temp_horse + #temp_shell)
      for i=1,enemy_num do
        local current_health=1
        if rnd()<two_health then
          current_health=2
        end
        local total_enemy=#temp_fish + #temp_horse + #temp_shell
        local rad=rnd()
        if rad < #temp_fish/total_enemy then
          local p=temp_fish[1]
          del(temp_fish,p)
          add(self.entities,make_fish(p.x,p.y,current_health))
        elseif rad < (#temp_fish+#temp_horse)/total_enemy then
          local p=temp_horse[1]
          del(temp_horse,p)
          add(self.entities,make_horse(p.x,p.y,current_health))
        else
          local p=temp_shell[1]
          del(temp_shell,p)
          add(self.entities,make_shell(p.x,p.y,current_health))
        end
      end
    end,

    advance_level=function(self)
      self.room_num+=1
      if self.room_num > 25 then
        self.room_num=25
        return
      end

      self.plan_pos={}
      self.entities={}
      self.tiles={}
      for y=1,self.height do
        add(self.tiles,{})
        for x=1,self.width do
          add(self.tiles[y],nil)
        end
      end
      self.particles={}

      local health,ink=nil,nil
      if self.room_num > 1 then
        health=self.player.health
        ink=self.player.ink
        self.entrance=self.exit
      else
        self.entrance=4
      end
      self:set_map(self.entrance)

      self.player=make_player(1,self.entrance,0.25,health,ink)
      self.player:health_inc()
      add(self.entities,self.player)
    end,

    update=function(self)
      -- if btnp(4) then
      --   self:advance_level()
      --   return
      -- end
      if self.player.health <= 0 or (self.room_num >= 25 and self.player.x >= 128) then
        if btnp(4) or btnp(5) then
          world:init()
        end
      end

      for e in all(self.entities) do
        e:update()
      end

      for p in all(self.particles) do
        p:update()
      end
    end,

    draw=function(self)
      cls(1)
      rpal()
      for y=1,self.height do
        for x=1,self.width do
          self.tiles[y][x]:draw()
        end
      end

      local i=0
      sort(self.entities)
      for e in all(self.entities) do
        i+=1
        e:draw()
      end

      for p in all(self.particles) do
        p:draw()
      end

      local x=6
      for i=0,2 do
        spr(122,x,116)
        x+=10
      end
      x=6
      local h=self.player.health
      while h>0 do
        if h > 1 then
          spr(124,x,116)
        else
          spr(123,x,116)
        end
        h-=2
        x+=10
      end

      x=116
      for i=0,2 do
        spr(125,x,116)
        x-=10
      end
      h=self.player.ink
      x=116
      while h>0 do
        if h > 1 then
          spr(127,x,116)
        else
          spr(126,x,116)
        end
        h-=2
        x-=10
      end
      cprint("room "..self.room_num,66,120,7)
      if self.player.start then
        cprint("— to start",61,57,7)
      end
      self.game_name:draw()
      if self.player.health <= 0 then
        cprint("gameover",64,52,7)
        cprint("— to restart",61,62,7)
      end
      if self.player.x >= 128 and self.room_num >= 25 then
        cprint("congratulations",64,52,7)
        cprint("— to play again",62,62,7)
      end
    end,

    is_anim=function(self)
      for e in all(self.entities) do
        if e:is_anim() then
          return true
        end
      end
      return false
    end,

    get_entity=function(self,name)
      for e in all(self.entities) do
        if (e.name == name) return e
      end
      return nil
    end,

    check_collision=function(self,obj,x,y)
      for e in all(self.entities) do
        nx,ny=self:get_tile(e.x,e.y)
        if e != obj and nx==x and ny==y then
          return e
        end
      end
      return nil
    end,

    check_next_collision=function(self,tx,ty)
      return self.plan_pos[hash_pos(tx,ty)]
    end,

    check_outside=function(self,x,y)
      return x < 1 or y < 1 or x > self.width or y > self.height
    end,

    get_tile=function(self,x,y)
      return flr(x/self.tile_size)+1,flr(y/self.tile_size)+1
    end,

    get_screen=function(self,x,y)
      return (x-1)*self.tile_size,(y-1)*self.tile_size
    end,

    prepare_mov=function(self)
      self.plan_pos={}
      for e in all(self.entities) do
        self.plan_pos[hash_pos(self:get_tile(e.x,e.y))]=e
      end
    end,

    change_pos=function(self,e,tx,ty)
      local cx,cy=self:get_tile(e.x,e.y)
      self.plan_pos[hash_pos(cx,cy)]=nil
      self.plan_pos[hash_pos(tx,ty)]=e
    end,

    calculate_dikjstra=function(self)
      local sx,sy=self.player.tx,self.player.ty
      local solid={}
      local map={}
      local x,y
      for y=1,self.height do
        add(map,{})
        add(solid,{})
        for x=1,self.width do
          local e = self.plan_pos[hash_pos(x,y)]
          if (e != nil and e.name != "player" and e.name != "bullet" and e.name != "water") or self.tiles[y][x].type==1 then
            add(solid[y],1)
          else
            add(solid[y],0)
          end
          add(map[y],-1)
        end
      end

      local queue={{sx,sy,0}}
      while #queue > 0 do
        local cx,cy,cd = queue[1][1],queue[1][2],queue[1][3]
        del(queue, queue[1])
        if not(self:check_outside(cx,cy) or solid[cy][cx] == 1 or map[cy][cx] != -1) then
          map[cy][cx]=cd
          for y=-1,1 do
            for x=-1,1 do
              if abs(x+y) == 1 then
                add(queue,{cx+x,cy+y,cd+1})
              end
            end
          end
        end
      end
      printh(map[sy][sx].." "..solid[sy][sx])
      return map
    end
  }
end

function rpal()
  palt(0, false)
  palt(1, true)
end

function get_vec(dir)
  return cos(dir+0.75),-sin(dir+0.75)
end

function get_dir(dx,dy)
  if (dy==-1) return 0
  if (dx==1) return 0.25
  if (dy==1) return 0.5
  if (dx==-1) return 0.75
end

function lerp(v1, v2, p)
  return v1 + p * (v2 - v1)
end

function move_obj(obj, x, y, call_back)
  while abs(obj.x - x) > 1 or abs(obj.y - y) > 1 do
    obj.x, obj.y = lerp(obj.x, x, 0.4), lerp(obj.y,y,0.4)
    yield()
  end
  obj.x, obj.y = x, y
  if call_back then
    call_back()
  end
end

function bounce_obj(obj, x, y, call_back)
  local sx,sy=obj.x,obj.y
  while abs(obj.x - x) > 1 or abs(obj.y - y) > 1 do
    obj.x, obj.y = lerp(obj.x, x, 0.4), lerp(obj.y,y,0.4)
    yield()
  end
  obj.x, obj.y = x, y
  if call_back then
    call_back()
  end
  while abs(obj.x - sx) > 1 or abs(obj.y - sy) > 1 do
    obj.x, obj.y = lerp(obj.x, sx, 0.4), lerp(obj.y,sy,0.4)
    yield()
  end
  obj.x, obj.y = sx, sy
end

function cprint(string,x,y,c)
  print(string,x-2*#string,y-3,c)
end

function show_window(table,x,y,c1,c2)
  local w,h=0,#table*6
  for l in all(table) do
    if (#l > w) w=#l*4
  end
  rectfill(x-w/2-2,y-h/2-2,x+w/2,y+h/2,c1)
  rect(x-w/2-2,y-h/2-2,x+w/2,y+h/2,c2)
  local i=-#table/2
  for l in all(table) do
    print(l,x-#l*2,y+i*6,c2)
    i+=1
  end
end

function sort(a,index)
  index=index or "layer"
  for i=1,#a do
    local j = i
    while j > 1 and a[j-1][index] > a[j][index] do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end

function shuffle(a)
  for i=1,#a do
    local j=flr(rnd()*#a) + 1
    a[i],a[j] = a[j],a[i]
  end
end

function hash_pos(x,y)
  return x.." "..y
end

function sgn(v,th)
  th=th or 0
  if (v>abs(th)) return 1
  if (v<-abs(th)) return -1
  return 0
end

function check_solid(e)
  if (e == nil) return false
  if (e.name == "player") return false
  if (e.name == "bullet") return false
  if (e.name == "water") return false
  return true
end

function make_tile(x,y,type)
  local tile=make_entity(world:get_screen(x,y))
  tile["type"]=type
  tile["is_solid"]=function(self)
    return self.type==1
  end
  tile["draw"]=function(self)
    spr(64+self.type*2,self.x,self.y,2,2)
  end
  return tile
end

function make_particle(x,y,idx,v,dir)
  return {
    x=x,
    y=y,
    velocity=v,
    dir=dir,
    sprite=idx,
    update=function(self)
      self.velocity *= (0.7 + 0.1*rnd())
      self.x+=self.velocity*cos(dir)
      self.y+=self.velocity*sin(dir)
      if self.velocity < 0.1 then
        del(world.particles,self)
      end
    end,
    draw=function(self)
      local adj=0
      if(self.velocity < 0.3) adj=1
      spr(self.sprite+adj,self.x,self.y)
    end
  };
end

function spawn_particles(x,y,particle)
  x,y=world:get_screen(x,y)
  local dir=rnd()*15
  while dir < 360 do
    add(world.particles,make_particle(x+4,y+4,particle,1+2*rnd(),dir/360))
    dir += rnd()*30+15
  end
end

function make_bullet(x,y,dir)
  local bullet=make_entity(world:get_screen(x,y))
  bullet.name="bullet"
  bullet.dir=dir
  bullet.frame=0
  bullet.created=true
  bullet.step_order=1

  bullet["check_solid"]=function(self,e)
    if (e==nil) return false
    if (e.name=="player") return false
    if (e.name=="water") return false
    if (e.name=="bullet") return false
    return true
  end

  bullet["step"]=function(self)
    if self.created then
      self.created=false
      return
    end
    local tx,ty=self:get_next_tile()

    local call_back=nil
    if world:check_outside(tx,ty) or world.tiles[ty][tx]:is_solid() then
      call_back=function() self:destroy() end
    end

    local e=world:check_next_collision(tx,ty)
    if self:check_solid(e) then
      e.freeze=2
      call_back=function() self:destroy() e:hurt() end
    end

    world:change_pos(self,tx,ty)
    local x,y=world:get_screen(tx,ty)
    self.anim=cocreate(move_obj)
    coresume(self.anim,self,x,y,call_back)
  end

  bullet["destroy"]=function(self)
    if self.x > 0 and self.x < 128 then
      sfx(4)
    end
    local x,y=world:get_tile(self.x,self.y)
    del(world.entities,self)
    spawn_particles(x,y,96)
  end

  bullet["draw"]=function(self)
    self.frame=(self.frame+1)%6
    local frame=0
    if (self.frame > 3) frame=1
    spr(self.dir*8+104+frame,self.x+world.tile_size/4,self.y+world.tile_size/4)
  end

  return bullet
end

function make_entity(x,y)
  return {
    name="",
    x=x,
    y=y,
    layer=1,
    step_order=0,
    dir=0,
    health=2,
    anim=nil,
    shake=0,
    is_anim=function(self)
      return self.anim != nil and costatus(self.anim) != "dead"
    end,
    get_next_tile=function(self)
      dx,dy=get_vec(self.dir)
      x,y=world:get_tile(self.x,self.y)
      return x+dx,y+dy
    end,
    get_half_tile=function(self)
      dx,dy=get_vec(self.dir)
      x,y=world:get_tile(self.x,self.y)
      return x+dx/2,y+dy/2
    end,
    hurt=function(self,dmg)
      dmg=1 or dmg
      self.health-=dmg
      if self.health<=0 then
        del(world.entities, self)
        local tx,ty=world:get_tile(self.x,self.y)
        spawn_particles(tx,ty,98)
        spawn_particles(tx,ty,100)
        if self.name != "player" then
          world.player:ink_inc(6)
        end
        sfx(1)
      else
        self.shake=6
        sfx(4)
      end
    end,
    update_anim=function(self)
      if self:is_anim() then
        coresume(self.anim)
      else
        self.anim=nil
      end
      if self.shake > 0 then
        self.shake -= 1
      else
        self.shake=0
      end
    end,
    step=function(self)
    end,
    update=function(self)
      self:update_anim()
    end,
    draw=function(self)
    end
  }
end

function make_player(x,y,dir,health,ink)
  health=health or 6
  ink=ink or 6
  dir=dir or 0
  local player=make_entity(world:get_screen(x,y))
  player.name="player"
  player.dir=dir
  player.frame=0
  player.fire=false
  player.health=health
  player.ink=ink
  player.start=true
  player.tx=x
  player.ty=y
  player.nx=x
  player.ny=y
  player.step_order=0

  player["health_inc"]=function(self,amount)
    amount=amount or 1
    self.health+=amount
    if (self.health > 6) self.health=6
  end

  player["ink_inc"]=function(self,amount)
    amount=amount or 1
    self.ink+=amount
    if (self.ink > 6) self.ink=6
  end

  player["check_solid"]=function(self,e)
    if (e==nil) return false
    if (e.name=="enemy") return true
    if (e.name=="barncle") return true
    if (e.name=="entrance") return true
    return false
  end

  player["step"]=function(self)
    local tx,ty=self:get_next_tile()
    if tx>world.width then
      local x,y=world:get_screen(tx,ty)
      self.anim=cocreate(move_obj)
      coresume(self.anim,self,x,y)
      return
    end
    local e=world:check_next_collision(tx,ty)
    local anim_fun=move_obj
    if world.tiles[ty][tx]:is_solid() or self:check_solid(e) then
      self:hurt()
      if e!=nil and e["hurt"]!=nil then
        e:hurt()
      end
      anim_fun=bounce_obj
      tx,ty=self:get_half_tile()
      self:ink_inc()
    else
      world:change_pos(self,tx,ty)
      self.nx,self.ny=tx,ty
      if self.fire then
        self.ink -= 2
        local bx,by=world:get_tile(self.x,self.y)
        local bullet=make_bullet(bx,by,(self.dir+0.5)%1)
        world:change_pos(bullet,bx,by)
        add(world.entities,bullet)
        sfx(0)
      else
        self:ink_inc()
        sfx(2)
      end
    end
    local x,y=world:get_screen(tx,ty)
    self.anim=cocreate(anim_fun)
    coresume(self.anim,self,x,y)
  end

  player["update"]=function(self)
    self:update_anim()
    if world:is_anim() then
      return
    end

    if self.start then
      if btnp(4) or btnp(5) then
        sfx(2)
        self.start=false
        local x,y=world:get_tile(self.x,self.y)
        world.game_name.go_out=true
        local e=world:get_entity("entrance")
        e:start()
        self:ink_inc()
        x,y=world:get_screen(self:get_next_tile())
        self.anim=cocreate(move_obj)
        coresume(self.anim,self,x,y)
      end
      return
    end

    if self.x >= 128 then
      if world.room_num < 25 then
        sfx(2)
        world:advance_level()
      end
      return
    end

    self.fire=false
    local pressed=false
    if self.ink > 1 then
      if btnp(0) then
        self.dir=0.75
        pressed=true
        self.fire=true
      end
      if btnp(1) then
        self.dir=0.25
        pressed=true
        self.fire=true
      end
      if btnp(2) then
        self.dir=0
        pressed=true
        self.fire=true
      end
      if btnp(3) then
        self.dir=0.5
        pressed=true
        self.fire=true
      end
    end
    if btnp(4) or btnp(5) then
      pressed=true
    end

    if pressed then
      world:prepare_mov()
      self.tx,self.ty=world:get_tile(self.x,self.y)

      sort(world.entities,"step_order")
      for e in all(world.entities) do
        e:step()
      end
    end
  end

  player["draw"]=function(self)
    if self:is_anim() and self.fire then
      self.frame=lerp(self.frame,1,0.25)
      if self.frame > 1 then
        self.frame=1
      end
    else
      self.frame=0
    end
    local start=128
    local shift=self.dir*4*6
    local frames={0,2,2,4,4,4,2,2,0}
    if self.dir*4>1 then
      start=160
      shift=(self.dir*4-2)*6
    end
    local shake_x,shake_y=0,0
    if self.shake > 0 then
      shake_x=2*flr(rnd()*2)-1
      shake_y=2*flr(rnd()*2)-1
    end
    spr(shift+start+frames[flr(self.frame*(#frames-1))+1],self.x+shake_x,self.y+shake_y,2,2)
  end
  return player
end

function make_barncle(x,y)
  local b=make_entity(world:get_screen(x,y))
  b.name="barncle"
  b.health=2
  b["draw"]=function(self)
    if (b.health == 2) spr(9, self.x, self.y, 2, 2)
    if (b.health == 1) spr(11, self.x, self.y, 2, 2)
  end
  return b
end

function make_exit(x,y)
  local b=make_entity(world:get_screen(x,y))
  b.name="barncle"
  b.health=3
  b["update"]=function(self)
    local barncle=nil
    for e in all(world.entities) do
      local tx,ty=world:get_tile(e.x,e.y)
      if e.name == "enemy" then
        return
      end
      if e.name == "barncle" and tx==world.width then
        barncle=e
      end
    end
    if (barncle != nil) barncle:hurt(3)
  end
  b["draw"]=function(self)
    if (b.health == 3) spr(9, self.x, self.y, 2, 2)
    if (b.health == 2) spr(11, self.x, self.y, 2, 2)
    if (b.health == 1) spr(13, self.x, self.y, 2, 2)
  end
  return b
end

function make_entrance(x,y)
  local e=make_entity(world:get_screen(x,y))
  e.name="entrance"
  e.frame=0
  e["hurt"]=function(self)
  end
  e["start"]=function(self)
    self.frame=0.01
  end
  e["draw"]=function(self)
    if self.frame > 0 then
      if self.frame > 0.8 then
        self.frame=1
      else
        self.frame=lerp(self.frame,1,0.3)
      end
    end
    local frames={72,70,68,66}
    spr(frames[flr(self.frame*(#frames-1))+1], self.x, self.y, 2, 2)
  end
  return e
end

function make_water_wall(x,y)
  local wall=make_entity(world:get_screen(x,y))
  wall.name="water"
  wall.layer=0
  wall.state=3
  wall.fire=false
  wall.step_order=3
  wall["hurt"]=function(self)
  end
  wall["step"]=function(self)
    wall.state-=1
    if wall.state == 0 then
      self.fire=true
    elseif wall.state < 0 then
      wall.state=3
    end
  end
  wall["update"]=function(self)
    if world:is_anim() then
      return
    end
    local e=world:check_collision(self,world:get_tile(self.x,self.y))
    if self.fire then
      sfx(3)
      if e!=nil then
        e:hurt()
        if e.name == "bullet" then
          e:destroy()
        end
      end
      local x,y=world:get_tile(self.x,self.y)
      spawn_particles(x,y,74)
      spawn_particles(x,y,76)
      spawn_particles(x,y,78)
      self.fire=false
    end
  end
  wall["draw"]=function(self)
    spr(224+min(3,(3-self.state))*2,self.x,self.y,2,2)
  end
  return wall
end

function make_shell(x,y)
  local shell=make_entity(world:get_screen(x,y))
  local dirs={0,0.25,0.5,0.75}
  local md,mv=0,0
  for d in all(dirs) do
    local dx,dy=get_vec(d)
    local tx,ty=x,y
    if not((y==world.entrance or y==world.exit) and abs(dx) > 0) then
      local v=0
      while not (world:check_outside(tx,ty) or world.tiles[ty][tx].type == 1) do
        v+=1
        tx,ty = tx+dx,ty+dy
      end
      if v > mv then
        md=d
        mv=v
      end
    end
  end

  shell.dir=md
  shell.name="enemy"
  shell.health=1
  shell.step_order=2
  shell.freeze=0

  shell["check_block"]=function(self)
    local tx,ty = self:get_next_tile()
    return check_solid(world:check_next_collision(tx,ty)) or world:check_outside(tx,ty) or world.tiles[ty][tx].type == 1
  end

  shell["step"]=function(self)
    if (self.freeze>0) self.freeze-=1 return
    if self:check_block() then
      self.dir=(self.dir+0.5)%1
    end
    if not self:check_block() then
      local tx,ty=self:get_next_tile()
      local anim_fun=move_obj
      local e=world:check_next_collision(tx,ty)
      local bullet_callback=nil
      if e!=nil and e.name == "player" then
        e:hurt()
        tx,ty=self:get_half_tile()
        anim_fun=bounce_obj
      else
        world:change_pos(self,tx,ty)
        if e!=nil and e.name == "bullet" then
          bullet_callback=function()
            self:hurt()
            self.freeze=1
            e:destroy()
          end
        end
      end
      x,y=world:get_screen(tx,ty)
      self.anim=cocreate(anim_fun)
      coresume(self.anim,self,x,y,bullet_callback)
    end
  end
  shell["draw"]=function(self)
    local start=192
    if self.health==1 then
      start=40
    end
    local shift=self.dir*4*2
    local shake_x,shake_y=0,0
    if self.shake > 0 then
      shake_x=2*flr(rnd()*2)-1
      shake_y=2*flr(rnd()*2)-1
    end
    spr(shift+start,self.x+shake_x,self.y+shake_y,2,2)
    if (self.freeze>0) spr(140,self.x,self.y,2,2)
  end
  return shell
end

function make_fish(x,y,health)
  health=health or 2
  local fish=make_entity(world:get_screen(x,y))
  local dirs={0,0.25,0.5,0.75}
  fish.dir=dirs[flr(rnd()*#dirs)+1]
  fish.name="enemy"
  fish.health=health
  fish.step_order=2
  fish.freeze=0

  fish["get_next_tile"]=function(self)
    local map=world:calculate_dikjstra()
    local tx,ty=world:get_tile(self.x,self.y)
    local sx,sy
    local mx,my=0,0
    local minval = 32000
    for sy=-1,1 do
      for sx=-1,1 do
        if abs(sx+sy) == 1 and map[ty+sy][tx+sx] != -1 and map[ty+sy][tx+sx] < minval then
          mx,my=sx,sy
          minval=map[ty+sy][tx+sx]
        end
      end
    end
    local dir=get_dir(mx,my)
    if (dir != nil) self.dir=dir
    return tx+mx,ty+my
  end

  fish["step"]=function(self)
    if (self.freeze>0) self.freeze-=1 return
    local tx,ty=self:get_next_tile()
    local anim_fun=move_obj
    local e=world:check_next_collision(tx,ty)
    local bullet_callback=nil
    if e!=nil and e.name == "player" then
      e:hurt()
      tx,ty=self:get_half_tile()
      anim_fun=bounce_obj
    else
      world:change_pos(self,tx,ty)
      if e!=nil and e.name == "bullet" then
        bullet_callback=function()
          self:hurt()
          self.freeze=1
          e:destroy()
        end
      end
    end
    x,y=world:get_screen(tx,ty)
    self.anim=cocreate(anim_fun)
    coresume(self.anim,self,x,y,bullet_callback)
  end

  fish["draw"]=function(self)
    local start=1
    local shift=self.dir*4*2
    local shake_x,shake_y=0,0
    if self.shake > 0 then
      shake_x=2*flr(rnd()*2)-1
      shake_y=2*flr(rnd()*2)-1
    end
    if self.health == 2 then
      pal(2,8)
    end
    spr(shift+start,self.x+shake_x,self.y+shake_y,2,2)
    pal()
    rpal()
    if (self.freeze>0) spr(140,self.x,self.y,2,2)
  end
  return fish
end

function make_horse(x,y)
  local horse=make_entity(world:get_screen(x,y))
  local dirs={0,0.25,0.5,0.75}
  horse.dir=dirs[flr(rnd()*#dirs)+1]
  horse.name="enemy"
  horse.health=1
  horse.move=false
  horse.step_order=2
  horse.freeze=0

  horse["check_solid"]=function(self,e)
    if (e==nil) return false
    if (e.name=="enemy") return true
    if (e.name=="barncle") return true
    if (e.name=="entrance") return true
    return false
  end

  horse["change_dir"]=function(self)
    local tx,ty=world:get_tile(self.x,self.y)
    local dx,dy=1,1
    if world.player != nil then
      dx,dy=sgn(world.player.nx-tx,0.1),sgn(world.player.ny-ty,0.1)
    end
    if dx == 0 or dy == 0 then
      self.move=true
      self.dir=get_dir(dx,dy)
    else
      local dirs={}
      local d=self.dir
      for i=1,4 do
        d=(d+0.25)%1
        add(dirs,d)
      end
      for d in all(dirs) do
        dx,dy=get_vec(d)
        local e=world:check_next_collision(tx+dx,ty+dy)
        if not(world.tiles[ty+dy][tx+dx]:is_solid() or self:check_solid(e)) then
          self.move=true
          self.dir=d
          break
        end
      end
    end
  end

  horse["step"]=function(self)
    if (self.freeze>0) self.freeze-=1 return
    if not self.move then
      self:change_dir()
    else
      local tx,ty=self:get_next_tile()
      if world.tiles[ty][tx]:is_solid() then
        self.move=false
        return
      end

      local e=world:check_next_collision(tx,ty)
      if e!=nil and (e.name=="entrance" or e.name=="barncle" or e.name=="enemy") then
        self.move=false
        return
      end

      local bullet_callback=nil
      local anim_fun=move_obj
      if e!=nil and e.name=="player" then
          e:hurt()
          tx,ty=self:get_half_tile()
          anim_fun=bounce_obj
      else
        world:change_pos(self,tx,ty)
        if e!=nil and e.name == "bullet" then
          bullet_callback=function()
            self:hurt()
            self.freeze=1
            e:destroy()
          end
        end
      end
      x,y=world:get_screen(tx,ty)
      self.anim=cocreate(anim_fun)
      coresume(self.anim,self,x,y,bullet_callback)
    end
  end
  horse["draw"]=function(self)
    local start=32
    local shift=self.dir*4*2
    local shake_x,shake_y=0,0
    if self.shake > 0 then
      shake_x=2*flr(rnd()*2)-1
      shake_y=2*flr(rnd()*2)-1
    end
    spr(shift+start,self.x+shake_x,self.y+shake_y,2,2)
    if (self.freeze>0) spr(140,self.x,self.y,2,2)
  end
  horse:change_dir()
  return horse
end

function make_game_name(x,y)
  return {
    x=x,
    y=y,
    sy=0,
    go_out=false,
    draw=function(self)
      if self.go_out then
        self.y=lerp(self.y,-40,0.2)
      else
        self.sy=4*sin(time()/2)
      end
      sspr(64,96,52,16,self.x,self.y+self.sy,52*2,16*2)
    end
  }
end

__gfx__
00000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000111111111111111111111111111111111111111111111111111111111111111111e1111e11e11ee11111111111111111111111111111111111111111
0070070011111111119911111111111991111111111119999111111111111119911111111e1ee1ee1e11ee211111111e11111111111111111111111111111111
000770001111111278997111111111999111111111111999111111111111111999111111111112e11e11e211111112e11e111111111111111111111111111111
00077000111112227799711111111992222111111119222111111111111112222991111111ee1121e21e2121111e1121e21e211111111111e111111111111111
0070070011112222789977111111192222221111119992222999111111112222229111111e11e12e21e211111111e12e21e211111111111e21e1111111111111
00000000111122227799771111111922222211111179992222299111111122222291111111112ee111eee1e111112ee111eee11111111ee111e2111111111111
0000000011992222222277111191122222222111117722222222991111122222222119111122112eeee12ee11122112eeee121111111112eee21111111111111
1111111111992222222277111199122227777111117722222222991111177772222199111e1111222e112e11111111222e111111111111222e11111111111111
111111111119922222999711119922222787811111779977222211111118787222229911111e1ee21ee112e1111e1ee21ee11111111111e21e11111111111111
11111111111199922229991111992292299999111177998722221111119999922922991111e2ee211e1ee12e1112ee211e1ee11111111e211111111111111111
1111111111111111122291111111299229999911111799772221111111999992299211111e21e1211e1111111111e1211e111111111111111111111111111111
111111111111111199911111111199977777711111179987211111111117777779991111111e2111ee22e11111112111ee221111111111111111111111111111
11111111111111199991111111111977777111111111991111111111111117777791111111e21e111e112e111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111112111e1e21112111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111199111111111111111111111111111111111199111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111119ccc11111111111111111111111111111111ccc911111111111111111111111111119991111111111122221111111111199911111111
11111111111911111119ccc7c111111111199991111111111111111c7ccc91111111999999991111111111999999111111111112211111111111999999111111
1111ccc1119911111119ccc8c11c1111119cccc1111111111111c11c8ccc91111119292992929111111119992222911111111199991111111119222299911111
11111c111111cc111119cccccccc111119ccccccc99cdd111111cccccccc91111199292992929911111119229999911111119999999911111119999922911111
11111c1116611cc11119ccccc11c111119cccccc99ccccd11111c11ccccc91111199292992929911112199992222911111199292292991111119222299991211
111cccc1666611c111111cc61111111111c78cc6ccc61cc1111111116cc111111199292992929911112299229999911111199292292991111119999922992211
11c78cc6ccc61cc111111c9c61111111111cccc1666611c111111116c9c111111119929229299111112299229999911111992929929299111119999922992211
19cccccc99ccccd11111199c6611111111111c1116611cc111111166c99111111119929229299111112199992222911111992929929299111119222299991211
19ccccccc99cdd11111119cc6619111111111c111111cc1111119166cc9111111111999999991111111119229999911111992929929299111119999922911111
119cccc11111111111111cc6611991111111ccc111991111111991166cc111111111119999111111111119992222911111192929929291111119222299911111
111999911111111111111dc111c11111111111111119111111111c111cd111111111111221111111111111999999111111119999999911111111999999111111
111111111111111111111dcc1cc11111111111111111111111111cc1ccd111111111112222111111111111119991111111111111111111111111199911111111
1111111111111111111111dccc1111111111111111111111111111cccd1111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111bb3511bbb33111111b35111bb1111111b32111111111111111111111111111111111111111111111111111111111111111111111111111
11133333333331111b33352b3333521111b35211b3331111113332111b351111111111111111111111199111111111111114411111111111111aa11111111111
11331111111133111355522333352b311135221b335211b11115211123511b1111111111111111111197191111179111114714111117411111a71a111117a111
11311111111113111122222235523351111112123522b311111111111112135111111111111111111191191111199111114114111114411111a11a11111aa111
113111111111131111bb22b222222511111b1111222225111111111121111211111111111111111111199111111111111114411111111111111aa11111111111
11311111111113111b3332bb332b221111b3511b3311111111b32111b21111111111111111111111111111111111111111111111111111111111111111111111
11311111111113111b3352b3352bbb311b3521b33521bb311135211b351211111111111111111111111111111111111111111111111111111111111111111111
113111111111131113552233352b335113521233521b351111151113511b35111111111111111111111111111111111111111111111111111111111111111111
11311111111113111122322552233511111111252123521111111111111151111111111111111111111111111111111111111111111111111111111111111111
113111111111131111b3332222222211111b331111212111111b3211121111111111111111111111111111111111111111111111111111111111111111111111
11311111111113111b33352bbbb322b11bb352111bb3111111133512bb3111111111111111111111111111111111111111111111111111111111111111111111
11331111111133111b3552222b352b31113522211b352b311111121113512b111111111111111111111111111111111111111111111111111111111111111111
11133333333331111122223323352351111122b31352135111112111151113511111111111111111111111111111111111111111111111111111111111111111
1111111111111111111b335513513511111b3355111111111111b351111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111116611111166111111111111111111111015111111510111111111111111111
11111111111111111111111111111111111111111111111111111111111111111166561111665611111111111111111111151011110151111111111111111111
1116611111111111111ee111111111111117711111111111111cc111111111111165551111655511101156610101566111015111111510111655101016551101
116555111116511111e88811111e8111117666111117611111c71c111117c1111155051111550511515555661515556611155111111551116550515165505515
11555511111551111188881111188111116666111116611111c11c11111cc1111115511111155111151505565155055611505511115055116655551566555151
111551111111111111188111111111111116611111111111111cc111111111111115101111015111010155611011556111555611115556111665110116651010
11111111111111111111111111111111111111111111111111111111111111111101511111151011111111111111111111656611116566111111111111111111
11111111111111111111111111111111111111111111111111111111111111111115101111015111111111111111111111166111111661111111111111111111
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111110110111111111111111111111101111111111111111111
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111100000011111111111811811111000111111111111115111
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111000000001118811118e88881110000011111111111155511
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd111111111111111100000000118e881118888881110000011111511111155511
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111000000001188881118888881100000011116551111565511
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111100000011118811111888811100000011111511111555511
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111110000111111111111188111110000011111111111155111
3333333366666666eeeeeeee8888888811111111cccccccc99999999dddddddd1111111111111111111001111111111111111111111001111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111117711111111111111771111111111111177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111176771111111111117677111111111111767711111111111771111111111111711111111111111111111111111111111111111111111111111111111111
11111767767111111111176776711111111117677671111111117111111111111111711111111111111111111111111111111111111111111111111111111111
1111767777671111111176777767111111117677776711111111177111171111111117711117111111777771111711111111111d511111111111111111111111
111117777771111111111777777111111111177777711111177711775776711117111177577671111111117757767111111111d5501111111111111111111111
11111755557111111111175555711111111117555571111111117777657767111177777765776711177777776577671111111115011111111111111111111111
11111565565111111111156556511111111115655651111111111177557776711111117755777671111111775577767111111111111111111111111111111111
11111777777111111111177777711111111117777771111111111177557777711111117755777771111111775577777111111d5111d111111111111111111111
1171777777771711111177777777111111117777777711111111777765776711117777776577671117777777657767111111d5501d5511111111111111111111
11717171171717111111717117171111111171711717111117771177577671111711117757767111111111775776711111111501155011111111111111111111
11171171171171111177117117117711111171711717111111111771111711111111177111171111117777711117111111111111110111111111111111111111
11111711117111111111117117111111111171711717111111117111111111111111711111111111111111111111111111111111111111111111111111111111
11111711117111111111117117111111111171711717111111111771111111111111711111111111111111111111111111111111111111111111111111111111
11111711117111111111171111711111111111711711111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111711117111111111171111711111111111711711111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111711117111111111117117111111111171711717111111111111177111111111111111171111111111111111111111111111111111111111111111111111
11111711117111111111117117111111111171711717111111111111111711111111111111171111111111111111111111111111111111111111111111111111
11171171171171111177117117117711111171711717111111117111177111111111711117711111111171111777771111111111111111111111111111111111
11717171171717111111717117171111111171711717111111176775771177711117677577111171111767757711111111111111111111111111111111111111
11717777777717111111777777771111111177777777111111767756777711111176775677777711117677567777777111111111111111111111111111111111
11111777777111111111177777711111111117777771111117777755771111111777775577111111177777557711111111111111111111111111111111111111
11111565565111111111156556511111111115655651111117677755771111111767775577111111176777557711111111111111111111111111111111111111
11111755557111111111175555711111111117555571111111767756777711111176775677777711117677567777777111111111111111111111111111111111
11111777777111111111177777711111111117777771111111176775771177711117677577111171111767757711111111111111111111111111111111111111
11117677776711111111767777671111111176777767111111117111177111111111711117711111111171111777771111111111111111111111111111111111
11111767767111111111176776711111111117677671111111111111111711111111111111171111111111111111111111111111111111111111111111111111
11111177671111111111117767111111111111776711111111111111177111111111111111171111111111111111111111111111111111111111111111111111
11111117711111111111111771111111111111177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111177711111771111171171111771117771111771177777111771111111111111
11111111111111111111111111111111111111111111111111111111111111111777771117777111771177117777177777117777177777717777111111111111
11111111111111111111111119911111111111222211111111111199111111117717771177777717771177717777177117717777177117717777111111111111
11119919911911111111119919991111111111122111111111119119911111117711111177117717771177717777177117717777177117717777111111111111
11192911919291111111199112229111111111999911111111192211919111111777771177117717771177717777177777117777177117717777111111111111
11992921929211111111192199999111111199999999111111119999229111111111177177177717771177717777177117717777177117717777111111111111
11992929929119111121999922211111111112922929911111111222999912111777177177777717771177717777177117717777177117717777111111111111
11111929929199111122992299119111111992922911911111199999229922111777771117777117777777717777177777117777177777717777111111111111
11191192292991111122992299999111119919299291111111191199229922111177711111771711777777111771117771111771177777111771111111111111
11199292292111111121999922211111119119299292991111111222999912111111111111111111565565111111111111111111111111111111111111111111
11119999999911111111192299991111111129291292991111199999129111111111111111111111755557111111111111111111111111111111111111111111
11111199991111111111191911229111111929191192911111192221199111111111111111111111777777111111111111111111111111111111111111111111
11111112211111111111111991191111111191199199111111119991991111111111111111111117677776711111111111111111111111111111111111111111
11111122221111111111111199111111111111111111111111111991111111111111111111111111767767111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111177671111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111117711111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111133111133111111113311113311111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111b31111b311111113b33113b3311111130031130031111111111111111111111111111111111111111111111111111111111111111111
11111311113111111111331111331111111333311333311111130031130031111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111133133133111111113313313311111111111111111111111111111111111111111111111111111111111111111111
11111113311111111111111b311111111111113b3311111111111130031111111111111111111111111111111111111111111111111111111111111111111111
11111113311111111111111331111111111111333311111111111130031111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111133133133111111113313313311111111111111111111111111111111111111111111111111111111111111111111
11111311113111111111b31111b311111113b33113b3311111130031130031111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111331111331111111333311333311111130031130031111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111133111133111111113311113311111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020410001010080000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000070707070707070707070707070707070707070707070707070707070707070707070707070707070000000000000000000000000000000000000000000000000
7100007770007670710076707073007071000000007300707100000000000070710000707300767200000000000000000000000000000000000000000000000070000000737300727000007700730070700000000000767070000000000076707000000000000070000000000000000000000000000000000000000000000000
7000000073000070700000000000007070000000757000707000767500770072700000770075007000000000000000000000000000000000000000000000000071000070000000707100007775000072710077007573007071000070730000707100007777000070000000000000000000000000000000000000000000000000
7000000073000070700000737300007070007773737700727073007070007370700000000000007000000000000000000000000000000000000000000000000070007600777700707000007070730070700077000077007270007700007500707000000000000070000000000000000000000000000000000000000000000000
7000000073000070700000000000007270007075000000707000770075760070700075007700007000000000000000000000000000000000000000000000000070000070000000707000007577000070700073750077007070000070730000727000737070730070000000000000000000000000000000000000000000000000
7076007077000072700073707076007070007300000000707000000000000070707600737000007000000000000000000000000000000000000000000000000070000000737300707000730077000070707600000000007070000000000076707076007373007672000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000070707070707070707070707070707070707070707070707070707070707070707070707070707070000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000070707070707070707070707070707070707070707070707070707070707070707070707070707070000000000000000000000000000000000000000000000000
7000000073000070700000757300007070000000760000707000000000000070707076737300007200000000000000000000000000000000000000000000000070007300000000727076007370000070700000757300007070000000000000707076730000000070000000000000000000000000000000000000000000000000
7000707777700070700070000000007070000000707300707000707673700072700077000000007000000000000000000000000000000000000000000000000070007300750000707000000077000072700075707073007070007377750000707000757070000070000000000000000000000000000000000000000000000000
7100007575730070710000767677007071007077777300727100750000730070710077000077007000000000000000000000000000000000000000000000000070777077777077707000000000007370700000757300007270007670707600707000770000770070000000000000000000000000000000000000000000000000
7000707777700070700070000000007270000000707300707000707673700070700000000077007000000000000000000000000000000000000000000000000071000075007300707100007700000070710000707000007071000075777300727100007070750070000000000000000000000000000000000000000000000000
7000000073000072700000757300007070000000760000707000000000000070700000767373707000000000000000000000000000000000000000000000000070000000007300707000007073007670700000000000007070000000000000707000000000737672000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000070707070707070707070707070707070707070707070707070707070707070707070707070707070000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000730000730070707600000000007070000073000000707000000075000070707070730000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000777373770070700073000070007070000070770000707000007300760072707675777700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000757070750070700070737370007070007673737600727077777070777770700000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000770000770070700070000073007270000077700000707000760073000070700000777775767000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7100000000000072710000000000767071000000730000707100007500000070710000007370707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707370707070707070707070707070707076707070700070707070750070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070700070707070707070707070707070707000707070707770707070700070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7100000000000072710070707070007271000000770000727100000000000072710000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070700070707070007070707070707070707077707070700070707070007070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070700000000000007070707070707070707000707070707670707070007570707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200002a21422214172240e2240a224052330523305233052330523300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
000200002d6202c6202a620286202562023620206101d61019613146130e613086130561314600116000e6000a600066000360000600006000060000600006000060000600006000060000600006000060000600
000100001f13019130121300d13007130021300013000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000800001d63017630106300962004620016100061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002265019650146500f65009650076500060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
