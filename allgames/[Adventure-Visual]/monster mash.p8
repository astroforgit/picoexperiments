pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- monster mash
-- BY CRYSS AND PANCE

function _init()
  pal({[0]=
    0x83,0x81,0x02,0x01,
    0x04,0x05,0x06,0x07,
    0x08,0x89,0x0a,0x84,
    0x8a,0x0d,0x82,0x00,
  },1)
  if dev_pal_persist then
    poke(0x5f2e,1)
  end

  poke(0x5f5c,255) -- no keyrepeat
  dtb_init()
  mode={}
  next_mode=m_menu
  if dev_skip_intro then
    next_mode=m_play
  end
end
function _update60()
  if next_mode then
    if (mode.die) mode:die()
    if (next_mode.init) next_mode:init()
    mode,next_mode=next_mode,nil
    mode.t=mode.t or 0
  end
  mode:update()
  mode.t+=1
end
function _draw()
  mode:draw()
end



function Actor(fields)
  -- fields.is_platform=fields.is_platform or nil
  fields.place=fields.place or PlaceWithContext{}
  fields.on_interact=fields.on_interact or OnInteract{}
  fields.on_update=fields.on_update or OnUpdate{}
  fields.draw=fields.draw or Draw{}
  fields.on_collide=fields.on_collide or OnCollide{}
  fields.prevpos=fields.prevpos or Prevpos{}

  next_actor_id=next_actor_id or 0
  fields.id=next_actor_id
  next_actor_id+=1

  m_play:add(fields)
  return fields
end

function ActorSimple(str)
  local fields={}
  for part in all(split(str,";")) do
    local code=sub(part,1,2)
    local val=sub(part,3)
    if code=="p " then
      fields.place=PlaceWithContext(val)
    elseif code=="d " then
      fields.draw=DrawSimple(val)
    else
      assert(false,"bad ActorSimple code: "..code)
    end
  end
  return Actor(fields)
end

function ActorGround(fields)
  fields=parse(fields or {})
  local x=fields.x or 0
  local w=fields.w or (64-x)
  local h=fields.h or 10
  local y=fields.y or (64-h)
  local color=fields.color or 14
  local extra_height=fields.extra_height or 3

  return Actor{
    is_platform=true,
    place=PlaceWithContext{
      x=x,y=y,
      w=w,h=h,
    },
    draw=DrawGround{
      extra_height=extra_height,
      color=color,
      filled=true,
    },
    on_collide=OnCollideFloor{},
  }
end

function ActorWallBorder(dir)
  assert(dir==0 or dir==1)
  return Actor{
    place=dir==0
      and PlaceWithContext"x=0,y=0,w=-1,h=64"
      or PlaceWithContext"x=64,y=0,w=1,h=64",
    on_collide=OnCollideWall{},
  }
end

function ActorStairs(fields)
  fields=parse(fields)
  local x=fields.x or 0
  local y=fields.y or 0
  local w=fields.w or 32
  local h=fields.h or 32
  local color=fields.color or 14
  local num_stairs=fields.num_stairs or 4
  local up=tobool(fields.up)
  for i=1,num_stairs do
    local i2=num_stairs-i+1
    i2=i
    Actor{
      is_platform=true,
      place=fields.up
        and PlaceWithContext{
          x=x+(i-1)*w,
          y=y-i*h,
          w=w*(num_stairs-i+1),
          h=h,
        } or PlaceWithContext{
          x=x,
          y=y+(i2-1)*h,
          w=w*i2,
          h=h,
        },
      draw=DrawGround{
        color=color+(dev_stair_colors and i or 0),
        filled=true,
      },
      on_collide=OnCollide{
        collide=function(self,actor,other)
          align_up_of(other,actor)
        end,
      },
    }
  end
end

function ActorRoomArea(ground_fields)
  if ground_fields then
    ActorGround(ground_fields)
  end

  -- pan hitbox
  return Actor{
    on_collide=OnCollidePan{},
    place=PlaceWithContext"x=4,y=0,w=56,h=64",
  }
end

place_context_room_n=0 --applied as an 64x scaled x-offset to every Place created
place_context_dim=0 --applied as `dim` to every Place created
function PlaceWithContext(fields)
  fields=parse(fields)
  local result=Place(fields)
  result.dim=place_context_dim
  result.x+=64*place_context_room_n
  return result
end

function Place(fields)
  fields=parse(fields)

  -- position
  fields.x=fields.x or 0
  fields.y=fields.y or 0
  fields.dim=fields.dim or 0 -- what "dimension" we're in (think minecraft nether)
  -- hitbox
  fields.dx=fields.dx or 0
  fields.dy=fields.dy or 0
  fields.w=fields.w or 0
  fields.h=fields.h or 0

  if fields.w<0 then
    fields.w*=-1
    fields.x-=fields.w
  end
  if fields.h<0 then
    fields.h*=-1
    fields.y-=fields.h
  end

  return fields
end

function Itemstats(fields)
  fields=parse(fields)
  fields.dx=fields.dx or 0
  fields.dy=fields.dy or 0
  -- fields.offset=fields.offset or function

  return fields
end

function OnInteract(fields)
  fields.hover=fields.hover or function(self,actor,other)-- what to do when the player (other) hovers over you
    if self.interact~=noop then
      hud.hud_color=true
    end
  end
  fields.interact=fields.interact or noop --args: self, actor, other

  return fields
end

function OnUpdate(fields)
  fields.update=fields.update or noop --args: self, actor

  return fields
end

-- note: different interface here
function OnUpdateScript(fxn)
  assert(fxn)
  return {
    script=make_script(fxn),
    update=function(self,actor)
      if not pause_scripts then
        self.script.update(self,actor)
      end
    end,
  }
end

function OnUpdateWalk(fields)
  fields=parse(fields)

  local left=true
  local result=OnUpdateScript(function(self,actor)
    while true do
      for i=0,self.num_steps do
        wait(self.wait_step)
        actor.place.x+=left and -1 or 1
      end
      wait(self.wait_end)
      actor.draw.flip_x=left
      left=not left
    end
  end)

  result.wait_step=fields.wait_step or 10
  result.wait_end=fields.wait_end or 10
  result.num_steps=fields.num_steps or 30

  return result
end

function xx(x)
  return x-pan_control.x0
end
function yy(y)
  return y-pan_control.y0
end
function xxp(x,depth)
  return x-(pan_control.x0\depth)
end
function yyp(y,depth)
  return y-(pan_control.y0\depth)
end

function Draw(fields)
  fields.z=fields.z or 0
  fields.update=fields.update or noop --args: self, actor. Update any state here
  fields.draw=fields.draw or noop --args: self, actor. Read state and draw it to screen

  return fields
end

function DrawGround(fields)
  fields=parse(fields)
  fields.z=fields.z or 900
  fields.color=fields.color or 14
  fields.extra_height=fields.extra_height or 3
  fields.update=fields.update or noop
  fields.draw=fields.draw or function(self,actor)
    if not in_current_dim(actor) then return end
    rectfillwh(xx(actor.place.x),yy(actor.place.y)-self.extra_height,
      actor.place.w,actor.place.h+self.extra_height,self.color)
  end

  return fields
end

function DrawSprite(fields)
  fields=parse(fields,function(k,v)
    if k=="frames" then
      return fmap(split(v,"/"),tonum)
    end
    return tonum(v)
  end)

  fields.frames=fields.frames or {0} -- tile ids
  fields.w=fields.w or 1 -- width in tiles
  fields.h=fields.h or 1
  fields.z=fields.z or 0 -- depth; only checked once (objects are sorted at start of game)
  fields.dx=fields.dx or 0 -- hitbox offset
  fields.dy=fields.dy or 0
  fields.dt=fields.dt or 30 -- how long each image is shown
  fields.parallax=fields.parallax or 1
  fields.flip_x=tobool(fields.flip_x)
  fields.flip_y=tobool(fields.flip_y)
  fields.frameIndex=fields.frameIndex or 0
  fields.frameTimer=fields.frameTimer or 0
  -- fields.pal= -- allowed; defaults to nil
  fields.palt=fields.palt or 0
  fields.update=fields.update or function(self,actor)
    if self.frameTimer<=0 and self.dt>0 then
      self.frameTimer=self.dt
      if self.frameIndex==#self.frames then
        self.frameIndex=1
      else
        self.frameIndex+=1
      end
    end
    self.frameTimer-=1
  end
  fields.draw=fields.draw or function(self,actor)
    if not in_current_dim(actor) then return end
    if self.palt>0 then
      palt()
      palt(0,false)
      palt(self.palt,true)
    end
    if self.pal then
      pal(self.pal)
    end

    local s=self.frames[self.frameIndex]
    local x=actor.place.x+self.dx
    local y=actor.place.y+self.dy
    if self.parallax then
      x=xxp(x,self.parallax)
      y=yyp(y,self.parallax)
    else
      x=xx(x)
      y=yy(y)
    end
    spr(s,x,y,self.w,self.h,self.flip_x,self.flip_y)
    if dev_actor_ids then
      print(actor.id,x,y,7)
    end
    if dev_position then
      pset(x,y,8)
    end

    if self.pal then
      unpal(self.pal)
    end
    if self.palt>0 then
      palt()
    end
  end

  return fields
end

function DrawSspr(fields)
  fields=parse(fields)
  -- nonsense defaults:
  fields.x0=fields.x0 or 0
  fields.y0=fields.y0 or 0
  fields.x1=fields.x1 or 9
  fields.y1=fields.y1 or 9
  fields.z=fields.z or 0
  -- fields.pal=fields.pal or nil
  fields.update=fields.update or noop --args: self, actor. Update any state here
  fields.draw=fields.draw or function(self,actor)
    if not in_current_dim(actor) then return end
    if self.pal then
      pal(self.pal)
    end

    local w=self.x1-self.x0+1
    local h=self.y1-self.y0+1
    sspr(self.x0,self.y0,w,h,xx(actor.place.x),yy(actor.place.y))

    if self.pal then
      unpal(self.pal)
    end
  end

  return fields
end

DrawSimple=DrawSprite

function OnCollide(fields)
  fields.collide=fields.collide or noop

  return fields
end

function OnCollidePan(fields)
  fields.speed=fields.speed or 0.16
  fields.collide=fields.collide or function(self,actor,other)
    local x=actor.place.x-4
    local y=actor.place.y
    if actor.place.dim~=other.prevpos.dim then
      pan_control:warp_to(x,y,actor)
    else
      pan_control:pan_to(x,y,self.speed,actor)
    end
  end

  return fields
end

function align_left_of(actor,rock)
  local x=rock.place.x+rock.place.dx
  actor.place.x=x-(actor.place.dx+actor.place.w)
end
function align_right_of(actor,rock)
  local x=rock.place.x+rock.place.dx+rock.place.w
  actor.place.x=x-actor.place.dx
end
function align_up_of(actor,rock)
  local y=rock.place.y+rock.place.dy
  actor.place.y=y-(actor.place.dy+actor.place.h)
end
function align_down_of(actor,rock)
  local y=rock.place.y+rock.place.dy+rock.place.h
  actor.place.y=y-actor.place.dy
end

function OnCollideWall(fields)
  fields.collide=fields.collide or function(self,actor,other)
    if other.prevpos.x<actor.place.x then
      align_left_of(other,actor)
    else
      align_right_of(other,actor)
    end
  end

  return fields
end

function OnCollideFloor(fields)
  fields.collide=fields.collide or function(self,actor,other)
    if other.prevpos.y<actor.place.y then
      align_up_of(other,actor)
    else
      align_down_of(other,actor)
    end
  end

  return fields
end

function in_current_dim(actor)
  return actor.place.dim==player.place.dim
end

function Prevpos(fields)
  fields.x=fields.x or 0
  fields.y=fields.y or 0
  fields.dim=fields.dim or 0
  fields.preupdate=fields.preupdate or function(self,actor)
    self.temp_x=actor.place.x
    self.temp_y=actor.place.y
    self.temp_dim=actor.place.dim
  end
  fields.postupdate=fields.postupdate or function(self,actor)
    self.x=self.temp_x
    self.y=self.temp_y
    self.dim=self.temp_dim
  end

  return fields
end



dim_bkg={
  [0]=1,
  [4]=13,
}
function bkg()
  cls(dim_bkg[player.place.dim])
end

m_play={}
function m_play:init()
  poke(0x5f2c,3) --mini
  if not self.initd then
    self.actors={}
    load_actors()
    self.actors_draw=clone(self.actors)

    sort(self.actors_draw,function(actor)
      return -actor.draw.z or 0
    end)
    self.initd=true
  end
end
function m_play:update()
  -- things added last are updated first and drawn last
  for i=#self.actors,1,-1 do
    local actor=self.actors[i]
    actor.prevpos:preupdate(actor)
    actor.on_update:update(actor)
    actor.draw:update(actor)
    actor.prevpos:postupdate(actor)
  end
end
function m_play:draw()
  bkg()
  -- things added last are updated first and drawn last
  for actor in all(self.actors_draw) do
    actor.draw:draw(actor)
  end
end

function m_play:add(actor)
  add(self.actors,actor)
end
function m_play:test_collision(a1,a2)
  local p1=a1.place
  local p2=a2.place
  return p1.dim==p2.dim
  and rect_collide(p1.x+p1.dx,p1.y+p1.dy, p1.w,p1.h,
                  p2.x+p2.dx,p2.y+p2.dy, p2.w,p2.h)
end
-- a complicated stateful iterator;
-- finds a fresh new collision every time through the loop
-- (so you can collide with things, respond by moving, and then collide with things at your new location)
-- also, keeps track and only collies with any individual actor once
function m_play:iter_collisions(a1)
  local seen={}
  return function()
    for i,a2 in ipairs(self.actors) do
      if a1~=a2 and not seen[i] and self:test_collision(a1,a2) then
        seen[i]=true
        return a2
      end
    end
    return nil
  end
end

fade={
  0,
  0b0010010000011000.1,
  0b0010111000111100.1,
  0b1011111001111101.1,
  0b1111111111111111.1,
}

m_menu={}
function m_menu:init()
 self.stage=0
 self.script=make_script(function()
  cls(3)
  for i=1,5 do
   fillp()
   px9_decomp(0,0,0x2400,pget,pset)
   fillp(fade[i])
   rectfill(0,0,127,127,15)
   wait(4)
  end
  fillp(0)

  wait(40)
  wait_btnp(5)
  m_menu.stage=1

  cls(3)
  sfx(16)
  wait(5)
  px9_decomp(0,0,0x2000,pget,pset)
  wait(40)

  wait_btnp(5)

  for i=1,5 do
   fillp(fade[6-i])
   rectfill(0,0,127,127,15)
   wait(10)
  end

  wait(30)
  next_mode=m_play
 end)
end
function m_menu:update()
 self.script:update()
end
function m_menu:draw()
  if mode.t>=120 and self.stage==0 then
    pal(6,mode.t%120>=60 and 9 or 1)
    spr(102,60,111)
    pal(6,6)
  end
end



-->8
-- game stuff
-- lock:

--stops script-like stuff from running
--  while dialogue boxes are displayed
pause_scripts=false

--depth number guidelines: (draw.z)
--  moon/stars: 1000
--  ground: 900
--  buildings,inner doors: 800
--  trees,windows,cupboards: 500
--  other scenery: 400
--  items: 0
--  monsters/player: -50
--  hud: -1000

function load_actors()
  -- dim=-1: where actors go to die (do not use as an actual dimension)
  --dim=4: party
  load_party_0()
  -- dim=0: overworld
  load_overworld_background()
  load_overworld_3L()
  load_overworld_2L()
  load_overworld_1L()
  load_overworld_0()
  load_overworld_1R()
  load_overworld_2R()
  load_overworld_3R()
  load_overworld_4R()
  load_overworld_5R()
  load_overworld_6R()
  load_overworld_7R()
  -- dim=1: house
  load_house_0()
  -- dim=2: castle
  load_castle_1L()
  load_castle_0()
  load_castle_1R()
  --dim=3: witch house
  load_witchHouse_0()
  load_witchHouse_1R()

  load_player()
  load_actors_global()

  if dev_instaparty then
    skelehead.stage=3
    skelehead.draw.h=2
    skelehead.place.y=37
    witch.happy=true
    witch.draw.frames=split"44,45"
    vampire.happy=true
  end
end

function load_overworld_background()
  place_context_room_n=0
  place_context_dim=0

  moon=ActorSimple"p x=72,y=10;d frames=228,parallax=20,z=1000"
  stars=Actor{
    draw=Draw{
      z=1010,
      parallax=40,
      rng=rng_state(),
      draw=function(self,actor)
        if not in_current_dim(actor) then return end
        local state=rng_state()
        restore_rng(self.rng)
        for i=1,40 do
          -- local rng={self.rng[1],self.rng[2]^i}
          local x=rnd()*128-64
          local y=rnd()*42
          pset(xxp(x,self.parallax),yyp(y,self.parallax),6)
        end
        restore_rng(state)
      end
    },
  }
end

function load_actors_global()
  hud=Actor{
    -- hud_color=nil,
    ---
    on_update=OnUpdate{
      update=function(self,actor)
        pause_scripts=dtb_active()
        player.has_action=not pause_scripts and btnp(5)
        if dtb_update() then
          player.has_action=false
        end
      end,
    },
    draw=Draw{
      z=-1000,
      draw=function(self,actor)
        if actor.hud_color then
          dtb_col_fg=actor.hud_color
        end
        if partying then
          dtb_col_fg=(mode.t/20)%6+8
        end
        if actor.hud_color and not partying then
          printcj("—",32,64-6,actor.hud_color)
          cursor(0,0)
        end
        dtb_draw()
      end,
    },
  }

  pan_control=Actor{
    -- current camera pos
    x0=0,
    y0=0,
    -- goal camera pos
    x1=0,
    y1=0,
    speed=0.3, -- how much to lerp each frame; "speed" isnt the best name. always between 0 and 1
    pan_to=function(actor,x,y,speed,initiator)
      local same=x==actor.x1 and y==actor.y1 and speed==actor.speed
      if not same then
        actor.x1=x
        actor.y1=y
        actor.speed=speed
      end
    end,
    warp_to=function(actor,x,y,initiator)
      local same=x==actor.x1 and y==actor.y1
          and x==actor.x0 and y==actor.y0
      if not same then
        actor.x0=x
        actor.y0=y
        actor.x1=x
        actor.y1=y
      end
    end,
    ---
    on_update=OnUpdate{
      update=function(self,actor)
        -- move camera towards x1,y1
        actor.x0=lerp(actor.x0,actor.x1,actor.speed)
        actor.y0=lerp(actor.y0,actor.y1,actor.speed)
        if abs(actor.x1-actor.x0)<1 then
          actor.x0=actor.x1
        end
        if abs(actor.y1-actor.y0)<1 then
          actor.y0=actor.y1
        end
      end,
    },
  }
end

function load_overworld_0()
  place_context_room_n=0
  place_context_dim=0
  ActorRoomArea"h=12"

  -- tree
  ActorSimple"p x=16,y=18;d frames=203,w=2,h=4,z=500"

  BONE_COUNT=5
  skelehead=Actor{
    stage=0,
    bones=0,
    ---
    place=PlaceWithContext"x=50,y=48,dx=0,dy=1,w=8,h=7",
    draw=DrawSimple"frames=50/51,w=1,h=1,z=-55",
    on_interact=OnInteract{
      hover=function(self,actor,other)
        hud.hud_color=actor.stage==3 and (mode.t/20)%6+8 or 6
        return true
      end,
      interact=function(self,actor,other)
        if actor.stage==0 then
          actor.stage+=1
          dtb_disp("i've lost my body!")
          dtb_disp("if you could help me find my bones, we could go to the party together!")
        elseif actor.stage==1 then
          local collected=false
          local dx=0
          local dy=0
          if other.item==bone1 then
            actor.bones+=1
            collected=true
            dx=0 dy=8
            dtb_disp("oh! my leg!\nthank you.")
          elseif other.item==bone2 then
            actor.bones+=1
            collected=true
            dx=0 dy=8
            dtb_disp("are you digging these out of graves?!")
          elseif other.item==bone3 then
            actor.bones+=1
            collected=true
            dx=0 dy=8
            dtb_disp("well, it's not my arm, but i'll take it!")
          elseif other.item==bone4 then
            actor.bones+=1
            collected=true
            dx=0 dy=8
            dtb_disp("my arm!")
            dtb_disp("there's nothing humerus about it.")
          elseif other.item==bone5 then
            actor.bones+=1
            collected=true
            dx=0 dy=8
            dtb_disp("i'm no longer feeling spineless.")
          elseif other.item==nil then
            dtb_disp("my bones must be around here somewhere...")
            local n=BONE_COUNT-actor.bones
            dtb_disp("i'm pretty sure i'm supposed to have about "..n.." more bones")
          else
            dtb_disp("uh, that's not one of my bones.")
          end

          if collected then
            local item=other.item
            other.item=nil
            item.place.x=actor.place.x+dx
            item.place.y=actor.place.y+dy
          end

          if actor.bones==BONE_COUNT then
            actor.stage+=1
          end
        elseif actor.stage==2 then
          actor.stage+=1
          dtb_disp("you've collected all my bones!")
          dtb_disp("i am so grateful")
          dtb_disp("when you're ready, let's go to the party!")
          -- full sprite now!
          actor.draw.h=2
          actor.place.y=37
          bone1.place.dim=-1
          bone2.place.dim=-1
          bone3.place.dim=-1
          bone4.place.dim=-1
          bone5.place.dim=-1
        elseif actor.stage==3 then
          start_party()
        end
        return true
      end,
    },
    on_update=OnUpdateWalk"num_steps=20,wait_step=6,wait_end=30",
  }
end

function warp_to(actor,dest)
  actor.place.x=dest.x+dest.dx
  actor.place.y=dest.y+dest.dy
  actor.place.dim=dest.dim
end

function load_overworld_1L()
  place_context_room_n=-1
  place_context_dim=0
  ActorRoomArea"h=12"

  -- woodfence
  ActorSimple"p x=0,y=43;d frames=214,z=400"

  house=ActorSimple"p x=7,y=19,dx=18,dy=14,w=10,h=18;d frames=192,w=4,h=4,z=800"
  house.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor,other)
      warp_to(other,house_inner_door.place)
      return true
    end,
  }
end

function load_overworld_2L()
  place_context_room_n=-2
  place_context_dim=0
  ActorRoomArea"h=12"
  
  -- woodfence
  ActorSimple"p x=32,y=43;d frames=213,w=1,h=1,z=400"
  ActorSimple"p x=40,y=43;d frames=213,w=2,h=1,z=400"
  ActorSimple"p x=56,y=43;d frames=213,z=400"
  
  -- tree
  local tree=ActorSimple"p x=42,y=18;d frames=203,w=2,h=4,z=500"
  tree.draw.pal=parse"2=9,9=10"
  local tree2=ActorSimple"p x=-5,y=40;d frames=203,w=2,h=4,z=-160"
  tree2.draw.pal=parse"2=9,9=10"

  bone1=ActorSimple"p x=14,y=43,dx=3,dy=2,w=3,h=6;d frames=6,z=0"
  bone1.itemstats=Itemstats"dx=8"
  bone1.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      dtb_disp("hey, a bone!")
      player:pickup(actor)
      return true
    end,
  }
end

function load_overworld_3L()
  place_context_room_n=-3
  place_context_dim=0
  ActorRoomArea"h=12"
  ActorWallBorder(0)

  witch=Actor{
    stage=0,
    ---
    place=PlaceWithContext"x=30,y=37,dx=2,dy=3,w=5,h=12",
    draw=DrawSimple"frames=41/42,w=1,h=2,z=-40",
    on_update=OnUpdateWalk"num_steps=20,wait_step=3,wait_end=15",
    on_interact=OnInteract{
      hover=function()
        hud.hud_color=12
        return true
      end,
      interact=function(self,actor)
        if player.item==garlic then
          dtb_disp("hey, this looks just like my head of garlic")
          return true
        end

        if witch_hat.collected and actor.stage<1 then
          actor.stage=1
        end
        if actor.stage==0 then
          dtb_disp("i've lost my hat!")
          dtb_disp("how will everyone know i'm a witch if i don't have my hat?")
        elseif actor.stage==1 then
          actor.stage+=1
          actor.happy=true
          temp_witch_hat.stage+=1
          temp_witch_hat.place.dim=-1
          dtb_disp("oh! my hat!!")
          dtb_disp("thank you!")
          actor.on_update.wait_step*=4
          actor.on_update.wait_end*=4
          actor.draw.frames=split"44,45"
        elseif actor.stage==2 then
          dtb_disp("now i can go to the party tonight!")
        end
        return true
      end,
    },
  }

  witchHouse=ActorSimple"p x=15,y=19,dx=17,dy=14,w=10,h=18;d frames=199,w=4,h=4,z=800"
  witchHouse.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor,other)
      warp_to(other,witchHouse_inner_door.place)
      return true
    end,
  }
  --ironfence
  ActorSimple"p x=0,y=35;d frames=239,w=1,h=2,z=400"
  ActorSimple"p x=8,y=35;d frames=239,w=1,h=2,z=400"
  --cauldron
  ActorSimple"p x=40,y=46;d frames=68,w=2,h=2,z=-150"
  --bubbles
  ActorSimple"p x=41,y=41;d frames=143/159/175,w=1,h=1,z=-400"
end

function load_overworld_1R()
  place_context_room_n=1
  place_context_dim=0
  ActorRoomArea"h=12"
  ActorStairs"x=40,y=52,w=6,h=3,num_stairs=4,up=1,z=900"

  --bush
  ActorSimple"p x=13,y=34;d frames=237,w=2,h=2,z=400"
end

function load_overworld_2R()
  place_context_room_n=2
  place_context_dim=0
  ActorRoomArea"h=24"

  pumpkin=Actor{
    stage=0,
    ---
    place=PlaceWithContext"x=32,y=35,dx=0,dy=2,w=8,h=6",
    draw=DrawSimple"frames=5/21,z=-50",
    on_interact=OnInteract{
      hover=function(self,actor)
        if actor.stage<=2 then
          hud.hud_color=9
          return true
        end
      end,
      interact=function(self,actor)
        if actor.stage==1 and (player.item==candle1 or player.item==candle2) then
          -- skip stage 1
          actor.stage=2
        end

        if actor.stage==0 then
          dtb_disp("my candle went out\nhow embarassing..")
          candle1.can_collect=true
          candle2.can_collect=true
          actor.stage+=1
        elseif actor.stage==1 then
          dtb_disp("i'm a fraud of a jack o'lantern..")
        elseif actor.stage==2 then
          dtb_disp("oh! a candle!")
          dtb_disp("i feel like myself again")
          dtb_disp("well,\nmy people need me")
          player:banish_item()
          actor.draw.pal=nil
          actor.stage+=1
        end
        return true
      end,
    },
    on_update=OnUpdateScript(function(self,actor)
      while true do
        if actor.stage<=2 then

          -- idle walking
          for i=1,20 do
            actor.place.x+=1
            wait(3)
          end
          wait(30)
          actor.draw.flip_x=true
          for i=1,20 do
            actor.place.x-=1
            wait(1)
          end
          wait(30)
          actor.draw.flip_x=false

        elseif actor.stage==3 then

          -- a s c e n d after talking
          actor.draw.dt=0
          wait(60)
          actor.draw.frameIndex=2
          warp_to(fire,actor.place)
          sfx(7)
          align_down_of(fire,actor)

          while true do
            actor.place.y-=1
            fire.place.y-=1
            wait(rnd({1,1,3}))
            if actor.place.y<-32 then
              wait(20)
              dtb_disp("bye")
              return
            end
          end

        else
          assert(nil)
        end
      end
    end),
  }
  pumpkin.draw.pal=parse"10=15"
  fire=ActorSimple"d frames=34/35/36,dt=6"
  fire.place.dim=-1
  --pumpkin patch
  ActorSimple"p x=45,y=44;d frames=15"
  ActorSimple"p x=10,y=40;d frames=31"
  ActorSimple"p x=30,y=49;d frames=15"
end

function load_overworld_3R()
  place_context_room_n=3
  place_context_dim=0
  ActorRoomArea"h=24"
  ActorStairs"x=40,y=42,w=6,h=3,num_stairs=4,up=1,z=900"
  --pumpkin patch
  ActorSimple"p x=16,y=37;d frames=15,z=-150"
  ActorSimple"p x=30,y=52;d frames=31"
  ActorSimple"p x=45,y=40;d frames=31,flip_x=1"
  ActorSimple"p x=5,y=51;d frames=31,flip_x=1"
end

function load_overworld_4R()
  place_context_room_n=4
  place_context_dim=0
  ActorGround"h=34"
  -- custom ActorRoomArea:
  Actor{
    on_collide=OnCollidePan{},
    place=PlaceWithContext"x=4,y=-32,w=56,h=96",
  }

  --bush
  ActorSimple"p x=8,y=13;d frames=237,w=2,h=2,z=400"

  -- castleTowerL
  ActorSimple"p x=16,y=-12;d frames=112,w=2,h=5,z=800"

  castle=ActorSimple"p x=31,y=-19,dx=9,dy=28,w=13,h=20;d frames=98,w=4,h=6,z=800"
  castle.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor,other)
      warp_to(other,castle_interior.place)
      music(63)
      return true
    end,
  }
end

function load_overworld_5R()
  place_context_room_n=5
  place_context_dim=0
  Actor{
    on_collide=OnCollidePan{},
    place=PlaceWithContext"x=4,y=-32,w=56,h=96",
  }
  ActorGround"h=34,w=50"
  ActorGround"h=20,w=64"
  ActorStairs"x=50,y=30,w=5,h=3,num_stairs=7,z=800"
  -- castleTowerR
  ActorSimple"p x=-1,y=-12;d frames=112,w=2,h=5,flip_x=1,z=800"
  --bush
  ActorSimple"p x=7,y=13;d frames=237,w=2,h=2,flip_x=1,z=400"
end

function load_overworld_6R()
  place_context_room_n=6
  place_context_dim=0
  ActorRoomArea"h=12,extra_height=10"
  -- trees
  local tree=ActorSimple"p x=34,y=15;d frames=203,w=2,h=4,z=500"
  local tree=ActorSimple"p x=10,y=20;d frames=203,w=2,h=4,z=-160"
  tree.draw.pal=parse"2=9,9=10"
  --iron fence
  ActorSimple"p x=40,y=42;d frames=239,w=1,h=2,z=-150"
  ActorSimple"p x=48,y=42;d frames=239,w=1,h=2,z=-150"
  ActorSimple"p x=56,y=42;d frames=239,w=1,h=2,z=-150"
end

function load_overworld_7R()
  place_context_room_n=7
  place_context_dim=0
  ActorRoomArea"h=12,extra_height=10"
  ActorWallBorder(1)

  --iron fence
  for x=0,56,8 do
    ActorSimple("p x="..x..",y=42;d frames=239,w=1,h=2,z=-150")
  end

  -- trees
  ActorSimple"p x=24,y=12;d frames=203,w=2,h=4,z=500"
  local tree=ActorSimple"p x=2,y=29;d frames=203,w=2,h=4,z=-160"
  tree.draw.pal=parse"2=9,9=10"

  ghost=Actor{
    stage=0,
    place=PlaceWithContext"x=46,y=16,dx=1,dy=1,w=7,h=13",
    draw=DrawSimple"frames=13/14,w=1,h=2,palt=15,z=-50",
    on_interact=OnInteract{
      hover=function(self,actor)
        if actor.stage==0 then
          hud.hud_color=7
          return true
        end
      end,
      interact=function(self,actor)
        if player.item==bone2 then
          dtb_disp("hey, that's my leg!")
          return true
        end
        if actor.stage==0 then
          dtb_disp("that's my grave \nover there.")
          dtb_disp("watch your step please.")
          return true
        end
      end,
    },
  }
  ghost.place.dim=-1

  graveA=ActorSimple"p x=19,y=37,dx=1,w=6,h=10;d frames=229,w=1,h=2,z=400"
  graveA.on_interact=OnInteract{
    hover=function()
      hud.hud_color=13
      return true
    end,
    interact=function()
      dtb_disp("dearly beloved")
      return true
    end,
  }
  graveB=ActorSimple"p x=35,y=36,dx=1,w=6,h=10;d frames=230,w=1,h=2,z=400"
  graveB.on_interact=OnInteract{
    hover=function()
      hud.hud_color=13
      return true
    end,
    interact=function()
      dtb_disp("almost no regrets")
      return true
    end,
  }
  graveC=ActorSimple"p x=52,y=38,dx=1,w=6,h=10;d frames=229,w=1,h=2,z=400"
  graveC.stage=0
  graveC.on_interact=OnInteract{
    hover=function(self,actor)
      hud.hud_color=13
      return true
    end,
    interact=function(self,actor)
      if actor.stage==0 then
        hud.hud_color=7
        dtb_disp("ooOOOooOOOo")
        dtb_disp("i am here to HAUNT you !")
        actor.stage+=1
        ghost.place.dim=0
        return true
      elseif actor.stage==1 then
        dtb_disp("rest in peace")
        return true
      end 
    end,
  }

  bone2=ActorSimple"p x=43,y=40,dx=1,dy=5,w=6,h=3;d frames=22,z=0"
  bone2.itemstats=Itemstats"dx=8"
  bone2.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      dtb_disp("is that a leg bone?")
      player:pickup(actor)
      return true
    end,
  }
end

function load_house_0()
  place_context_room_n=0
  place_context_dim=1
  ActorRoomArea"h=24,color=1"
  ActorWallBorder(0)
  ActorWallBorder(1)

  house_inner_door=Actor{
    place=PlaceWithContext"x=12,y=19,dx=1,dy=1,w=10,h=17",
    draw=DrawSspr"x0=17,y0=109,x1=28,y1=126,z=800",
    on_interact=OnInteract{
      hover=function(self,actor,other)
        hud.hud_color=7
        return true
      end,
      interact=function(self,actor,other)
        warp_to(other,house.place)
        return true
      end,
    },
  }
  house_inner_door.draw.pal=parse"13=0"

  local window=ActorSimple"p x=36,y=20;d frames=224,w=2,h=2,z=500"
  window.draw.pal=parse"9=3,13=0"

   -- flower
  ActorSimple"p x=3,y=24;d frames=168,w=1,h=2"
    -- spiderweb
  ActorSimple"p x=56,y=0;d frames=63"  

  bone3=ActorSimple"p x=27,y=12,dx=1,dy=5,w=6,h=3;d frames=22,z=0"
  bone3.itemstats=Itemstats"dx=8"
  bone3.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      dtb_disp("my spare arm!")
      dtb_disp("this could")
      dtb_disp("come in HANDY!")
      player:pickup(actor)
      return true
    end,
  }
  --shelf
  ActorSimple"p x=27,y=16,dx=3,dy=2;d frames=54,z=0"
end

function load_castle_0()
  place_context_room_n=0
  place_context_dim=2
  ActorRoomArea"h=15,color=3"

  castle_interior=Actor{
    place=PlaceWithContext"x=25,y=26,dx=1,dy=1,w=13,h=19",
    draw=DrawSspr"x0=24,y0=76,x1=38,y1=95,z=800",
    on_interact=OnInteract{
      hover=function(self,actor,other)
        hud.hud_color=7
        return true
      end,
      interact=function(self,actor,other)
        warp_to(other,castle.place)
        return true
      end,
    },
  }
  castle_interior.draw.pal=parse"3=0"

  --candle
  candle1=Actor{
    itemstats=Itemstats"dx=8",
    can_collect=false,
    ---
    place=PlaceWithContext"x=8,y=30,dx=0,dy=2,w=8,h=6",
    draw=DrawSimple"frames=37/53,z=10",
    on_interact=OnInteract{
      hover=function(self,actor)
        if actor.can_collect then
          hud.hud_color=7
          return true
        end
      end,
      interact=function(self,actor)
        if actor.can_collect then
          dtb_disp("this could be useful")
          player:pickup(actor)
          candle2.can_collect=false
          return true
        end
      end,
    },
  }

  candle2=Actor{
    itemstats=Itemstats"dx=8",
    can_collect=false,
    ---
    place=PlaceWithContext"x=48,y=30,dx=0,dy=2,w=8,h=6",
    draw=DrawSimple"frames=37/53,flip_x=1,z=10",
    on_interact=OnInteract{
      hover=function(self,actor)
        if actor.can_collect then
          hud.hud_color=7
          return true
        end
      end,
      interact=function(self,actor)
        if actor.can_collect then
          dtb_disp("this could come in handy")
          player:pickup(actor)
          candle1.can_collect=false
          return true
        end
      end,
    },
  }

  -- cracked brick
  ActorSimple"p x=10,y=10;d frames=173,z=400"
  ActorSimple"p x=30,y=15;d frames=189,z=400"
  ActorSimple"p x=50,y=20;d frames=173,z=400"
end

function load_castle_1R()
  place_context_room_n=1
  place_context_dim=2
  ActorRoomArea"h=15,color=3"
  ActorWallBorder(1)

  -- cracked brick
  ActorSimple"p x=20,y=18;d frames=173,z=400"
  ActorSimple"p x=48,y=9;d frames=189,z=400"
  ActorSimple"p x=9,y=30;d frames=189,z=400"
  ActorSimple"p x=44,y=34;d frames=173,z=400"

  vampire=Actor{
    stage=0,
    ---
    place=PlaceWithContext"x=48,y=37,dx=1,dy=2,w=6,h=14",
    draw=DrawSimple"frames=11/12,w=1,h=2,z=-50",
    on_update=OnUpdateWalk"num_steps=30,wait_step=10,wait_end=30",
    on_interact=OnInteract{
      hover=function(self,actor,other)
        hud.hud_color=13
        return true
      end,
      interact=function(self,actor,other)
        if actor.stage==1 and player.item==garlic then
          -- skip stage 1
          actor.stage=2
        end

        if actor.stage==0 then
          dtb_disp("i need garlic for a recipe")
          actor.stage+=1
        elseif actor.stage==1 then
          dtb_disp("i can't be seen buying garlic")
          dtb_disp("it's bad for my image")
        elseif actor.stage==2 then
          actor.stage+=1
          dtb_disp("wow thank you for the garlic!")
          actor.happy=true
          player:banish_item()
        elseif actor.stage==3 then
          dtb_disp("i'm making garlic bread")
        end
        return true
      end,
    },
  }
  -- chandelier
  ActorSimple"p x=16,y=0;d frames=139/141,w=2,h=2,z=400"
  ActorSimple"p x=32,y=0;d frames=139/141,w=2,h=2,flip_x=1,z=400"
end

function load_castle_1L()
  place_context_room_n=-1
  place_context_dim=2
  ActorRoomArea"h=15,color=3"
  ActorWallBorder(0)

  -- cracked brick
  ActorSimple"p x=22,y=9;d frames=173,z=400"
  ActorSimple"p x=33,y=20;d frames=189,z=400"
  ActorSimple"p x=9,y=30;d frames=189,z=400"
  ActorSimple"p x=8,y=10;d frames=205,w=2,h=2,z=400"
  ActorSimple"p x=41,y=10;d frames=205,w=2,h=2,flip_x=1,z=400"
  --table
  ActorSimple"p x=40,y=40;d frames=96,w=2,h=1,z=400"  
  --armor
  ActorSimple"p x=20,y=31;d frames=46,w=1,h=2,z=400"
  -- witch hat is sorta an inventory item, but we avoid that system b/c you can
  -- hold something in your hand and on your head at the same time. gross code
  -- but fun result :)
  witch_hat=ActorSimple"p x=20,y=27,dx=1,dy=0,w=7,h=5;d frames=244,z=0"
  witch_hat.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      dtb_disp("wow, what a cool hat!")
      actor.collected=true
      actor.place.dim=-1
      temp_witch_hat.stage=1
      return true
    end,
  }
  temp_witch_hat=ActorSimple"p x=0,y=0,dx=1,dy=1,w=7,h=5;d frames=244,z=-101"
  temp_witch_hat.stage=0
  temp_witch_hat.place.dim=-1
  temp_witch_hat.on_update=OnUpdate{
    update=function(self,actor)
      if actor.stage==1 then
        actor.place.x=player.place.x
        actor.place.y=player.place.y-4
        actor.place.dim=player.place.dim
      end
    end,
  }
  bone5=ActorSimple"p x=44,y=34,dx=1,dy=5,w=6,h=3;d frames=38,z=0"
  bone5.itemstats=Itemstats"dx=8"
  bone5.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      dtb_disp("some spare ribs!")
      player:pickup(actor)
      return true
    end,
  }
end

function load_witchHouse_0()
  place_context_room_n=0
  place_context_dim=3
  ActorRoomArea"h=24,color=1"
  ActorWallBorder(0)

  witchHouse_inner_door=Actor{
    place=PlaceWithContext"x=11,y=19,dx=1,dy=1,w=10,h=16",
    draw=DrawSspr"x0=17,y0=109,x1=28,y1=126,z=800",
    on_interact=OnInteract{
      hover=function(self,actor,other)
        hud.hud_color=7
        return true
      end,
      interact=function(self,actor)
        warp_to(player,witchHouse.place)
        return true
      end,
    },
  }
  witchHouse_inner_door.draw.pal=parse"13=0"

  local window=ActorSimple"p x=35,y=21;d frames=231,w=2,h=2,z=500"
  window.draw.pal=parse"9=3,13=0,14=2"
  --plant
  ActorSimple"p x=30,y=24;d frames=174,w=1,h=2,flip_x=1,z=400"  
end

function load_witchHouse_1R()
  place_context_room_n=1
  place_context_dim=3
  ActorRoomArea"h=24,color=1"
  ActorWallBorder(1)

  fridge=ActorSimple"p x=47,y=24,dx=0,dy=0,w=10,h=16;d frames=169,w=2,h=2,z=400"
  fridge.stage=0
  fridge.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      if actor.stage==0 then
        actor.draw.frames={137}
        actor.stage=1
        sfx(10)
      elseif actor.stage==1 then
        actor.draw.frames={169}
        actor.stage=0
        sfx(9)
      end
      return true
    end,
  }
  -- plant
  ActorSimple"p x=19,y=25;d frames=168,w=1,h=1,flip_x=1,z=600"
  --cupboards
  ActorSimple"p x=38,y=32;d frames=187,w=1,h=1,flip_x=1,z=500"
  ActorSimple"p x=22,y=32;d frames=187,w=1,h=1,flip_x=1,z=500"
  ActorSimple"p x=14,y=32;d frames=187,w=1,h=1,flip_x=0,z=500"

  --cupboardG back
  ActorSimple"p x=30,y=32;d frames=172,w=1,h=1,z=500"

  cupboardG=ActorSimple"p x=30,y=32,dx=0,dy=0,w=8,h=8;d frames=171,w=1,h=1,flip_x=0,z=10"
  cupboardG.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      bone4.can_interact=true
      actor.place.dim=-1
      sfx(10)
      return true
    end,
  }
  
  --wall cupboards
  cupboardR=ActorSimple"p x=30,y=14,w=15,h=10;d frames=64,w=2,h=2,z=500"
  cupboardR.stage=0
  cupboardR.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      if actor.stage==0 then
        actor.draw.frames={134}
        actor.stage=1
        sfx(10)
      elseif actor.stage==1 then
        actor.draw.frames={64}
        actor.stage=0
        sfx(9)
      end
      return true
    end,
  }

  -- cupboardLBack
  ActorSimple"p x=13,y=14;d frames=134,w=2,h=2,z=500"

  -- interactable front
  cupboardL=ActorSimple"p x=13,y=14,w=15,h=10;d frames=166,w=2,h=2,z=10"
  cupboardL.on_interact=OnInteract{
    hover=function()
      hud.hud_color=7
      return true
    end,
    interact=function(self,actor)
      garlic.can_interact=true
      actor.place.dim=-1
      sfx(10)
      return true 
    end,
  }

  bone4=ActorSimple"p x=30,y=32,dx=1,dy=5,w=6,h=3;d frames=22,z=11"
  bone4.itemstats=Itemstats"dx=8"  
  bone4.can_interact=false
  bone4.on_interact=OnInteract{
    hover=function(self,actor)
      if actor.can_interact then
        hud.hud_color=7
        return true
      end
    end,
    interact=function(self,actor)
      if actor.can_interact then
        dtb_disp("what's this bone doing in here?")
        player:pickup(actor)
        return true
      end
    end,
  }
  garlic=ActorSimple"p x=13,y=15,dx=2,dy=3,w=5,h=5;d frames=188,z=11"
  garlic.itemstats=Itemstats"dx=8"
  garlic.can_interact=false
  garlic.on_interact=OnInteract{
    hover=function(self,actor)
      if self.can_interact then
        hud.hud_color=7
        return true
      end
    end,
    interact=function(self,actor)
      if actor.can_interact then
        dtb_disp("yum, garlic!")
        player:pickup(actor)
        return true
      end
    end,
  }
end

partying=false
function start_party()
  player.draw.z=-40
  partying=true
  dtb_disp("it's party time")
  music(0)

  warp_to(player,party_door.place)
  if witch.happy then
    warp_to(witch,Place"x=20,dx=0,y=31,dy=0,dim=4")
  end
  if vampire.happy then
    warp_to(vampire,Place"x=35,dx=0,y=40,dy=0,dim=4")
  end
  warp_to(skelehead,Place"x=39,dx=0,y=44,dy=0,dim=4")
  skelehead.on_update.wait_step/=2
  skelehead.on_update.wait_end/=2
end

function load_party_0()
  place_context_room_n=0
  place_context_dim=4
  ActorRoomArea"h=13,color=1,extra_height=14"
  ActorWallBorder(0)
  ActorWallBorder(1)

  party_door=Actor{
    place=PlaceWithContext"x=25,y=19,dx=1,dy=1,w=10,h=16",
    draw=DrawSspr"x0=17,y0=109,x1=28,y1=126,z=800",
  }
  -- table
  ActorSimple"p x=3,y=50;d frames=96,w=2,h=1,z=-60"
  -- punch + candy
  ActorSimple"p x=11,y=44;d frames=59,z=-65"
  ActorSimple"p x=4,y=44;d frames=83,z=-65"
  Actor{
    draw=Draw{
      z=-65,
      draw=function(self,actor)
        if not in_current_dim(actor) then return end
        local f=mode.t\40%3
        if f==0 then
          pset(14,40,12)
        elseif f==1 then
          pset(13,43,12)
        else
          pset(15,42,12)
        end
      end,
    },
  }
  -- windows
  ActorSimple"p x=5,y=13;d frames=207,w=1,h=2,z=400"
  ActorSimple"p x=49,y=13;d frames=207,w=1,h=2,flip_x=1,z=400"
  -- balloons
  ActorSimple"p x=16,y=14;d frames=32/70,w=1,h=2,z=400"
  ActorSimple"p x=38,y=16;d frames=71/33,w=1,h=2,z=400"
  --decorations
  for x=0,56,8 do
    local y=6+(x\8%2)
    ActorSimple("p x="..x..",y="..y..";d frames=82")
  end
end

-- ground state enum
GS_GROUNDED=1
GS_JUMPING=2
GS_FALLING=3

-- movement constants
-- horizontal movement
H_FRICTION=0.56
H_ACCEL=0.40
-- veritcal
V_FRICTION=0.8
GRAVITY=0.3
LIFTOFF_ACCELS={-1.7,-1.7,-1,-1,-0.5}
-- how many frames of coyote time
COYOTE_T=4
-- how long to wait between autojumping
JUMP_WAIT=4

function load_player()
  place_context_room_n=0
  place_context_dim=1

 --no z here
  local player_stand=DrawSimple"frames=8,w=1,h=2"
  local player_walk=DrawSimple"frames=9/8/10/8,w=1,h=2,dt=10"
  local player_jump=DrawSimple"frames=1/2,w=1,h=2,dt=10"
  local player_fall=DrawSimple"frames=3/4,w=1,h=2,dt=10"
  player=Actor{
    has_action=true,
    item=nil,
    banish_item=function(actor)
      if actor.item then
        actor.item.place.dim=-1
        actor.item=nil
      end
    end,
    pickup=function(actor,newitem)
      local olditem=actor.item
      if olditem then
        local dest=newitem.place
        olditem.place.x=dest.x
        olditem.place.y=dest.y
        olditem.place.dim=dest.dim
      end
      actor.item=newitem
    end,
    ---
    place=PlaceWithContext"x=44,y=37,dx=1,dy=0,w=6,h=16",
    draw=Draw{
      spr=player_stand,
      z=-45,
      update=function(self,actor)
        if pause_scripts then
          self.spr=player_stand
          return
        end

        if btnp(0) then
          player_stand.flip_x=true
          player_walk.flip_x=true
          player_jump.flip_x=true
          player_fall.flip_x=true
        end
        if btnp(1) then
          player_stand.flip_x=false
          player_walk.flip_x=false
          player_jump.flip_x=false
          player_fall.flip_x=false
        end

        if actor.on_update.dy<-0.05 then
          self.spr=player_jump
        elseif actor.on_update.dy>0.05 then
          self.spr=player_fall
        elseif abs(actor.on_update.dx)>=0.05 then
          self.spr=player_walk
        else
          self.spr=player_stand
        end
        self.spr:update(actor)
      end,
      draw=function(self,actor)
        self.spr:draw(actor)
      end,
    },
    on_update=OnUpdate{
      dx=0,
      dy=0,
      update=function(self,actor)
        self:update_inventory(actor) -- creates a bit of position lag b/c physics comes later
        self:update_physics(actor)
        self:update_collisions(actor)
      end,
      update_inventory=function(self,actor)
        if actor.item then
          local flip_x=actor.draw.spr.flip_x -- grosss
          actor.item.draw.flip_x=flip_x
          -- TODO handle flip_x. calc using item.draw.w?
          local dest=actor.place
          local stats=actor.item.itemstats
          local dx=stats.dx
          local dy=stats.dy
          actor.item.place.x=dest.x+dx
          actor.item.place.y=dest.y+dy
          actor.item.place.dim=dest.dim
        end
      end,
      update_collisions=function(self,actor)
        -- interact
        if not partying then
          local already_hovered=false
          hud.hud_color=nil
          for a2 in m_play:iter_collisions(actor) do
            if a2~=actor.item then
              if not pause_scripts and not already_hovered then
                if a2.on_interact:hover(a2,actor) then
                  already_hovered=true
                end
              end
              if actor.has_action then
                if a2.on_interact:interact(a2,actor) then
                  actor.has_action=false
                  break
                end
              end
            end
          end
        end

        if not pause_scripts then
          local found_platform=false
          for a2 in m_play:iter_collisions(actor) do
            a2.on_collide:collide(a2,actor)
            found_platform=found_platform or a2.is_platform
          end

          -- collide with platform
          if found_platform then
            self.dy=0
            if self.ground_state~=GS_GROUNDED then
              self.ground_state=GS_GROUNDED
              self.jump_wait=JUMP_WAIT
            end
          elseif self.ground_state==GS_GROUNDED then
            -- walked off a ledge?
            self.ground_state=GS_FALLING
            self.coyote_t=COYOTE_T
          end
        end
      end,
      update_physics=function(self,actor)
        if pause_scripts then return end

        local ddx=0
        local ddy=0
        local begin_jump=false
        if self.ground_state==GS_GROUNDED then
          if self.jump_wait>0 then
            self.jump_wait-=1
          else
            if btn(4) then begin_jump=true end
          end
          if btnp(4) then begin_jump=true end
        elseif self.ground_state==GS_JUMPING then
          if btn(4) and self.liftoff_t<#LIFTOFF_ACCELS then
            self.liftoff_t+=1
            ddy+=LIFTOFF_ACCELS[self.liftoff_t]
          else
            self.ground_state=GS_FALLING
            self.coyote_t=0
          end
        elseif self.ground_state==GS_FALLING then
          if self.coyote_t>0 then
            self.coyote_t-=1
            if btnp(4) then begin_jump=true end
          end
        end

        if begin_jump then
          self.ground_state=GS_JUMPING
          self.liftoff_t=1
          self.dy=LIFTOFF_ACCELS[1]
        end

        ddx=nil
          or btn(0) and -H_ACCEL
          or btn(1) and H_ACCEL
          or 0

        -- update position for real
        ddy+=GRAVITY
        self.dy+=ddy
        self.dx+=ddx
        actor.place.x+=self.dx
        actor.place.y+=self.dy
        self.dx*=H_FRICTION
        self.dy*=V_FRICTION
      end,
    },
  }
  Actor{
    on_update=OnUpdateScript(function()
      if dev_skip_intro then
        return
      end
      wait(90)
      dtb_disp("oh my bones!")
      dtb_disp("the party is tonight.")
      dtb_disp("i need to \nfind")
      dtb_disp("some BODY to go with!")
    end),
  }
end



-->8
function tobool(x)
  return x and not (x==0 or x=="0")
end

-- might have off-by-1 errors? but works well
function rect_collide(x0,y0,w0,h0,x2,y2,w2,h2)
  local x1=x0+w0
  if x1<x0 then x0,x1=x1,x0 end
  local x3=x2+w2
  if x3<x2 then x2,x3=x3,x2 end

  local y1=y0+h0
  if y1<y0 then y0,y1=y1,y0 end
  local y3=y2+h2
  if y3<y2 then y2,y3=y3,y2 end

  return _rect_collide_1D(x0,x1,x2,x3)
  and _rect_collide_1D(y0,y1,y2,y3)
end
function _rect_collide_1D(x0,x1,x2,x3)
  if x1<=x2 then return false end
  if x3<=x0 then return false end
  return true
end

function rng_state()
  return {$0x5f44,$0x5f48}
end
function restore_rng(state)
  poke4(0x5f44,state[1])
  poke4(0x5f48,state[2])
end

--
-- scripting
--
function make_script(f)
  local s={
    proc=cocreate(f),
    done=false,
  }
  function s.update(...)
    local status=costatus(s.proc)
    if status=="dead" then
      -- s.update=noop --idk
      s.done=true
    elseif status=="suspended" then
      local ok,msg=coresume(s.proc,...)
      if not ok then
        cls()
        cursor(0,0)
        color(14)
        stop(trace(msg))
        assert(false,"coroutine error")
      end
    else
      --todo: this _can_ happen when
      -- a coroutine goes too long
      -- in one frame
      assert(false,"coroutine took too long on last frame")
    end
  end
  return s
end
function wait(n)
  for i=1,n do
    yield()
  end
end
function wait_btnp(b)
  while not btnp(b) do
    yield()
  end
end



-->8
-- helper/dev stuff
-- lock:

function parse(str,mapper)
  if type(str)=="table" then return str end
  mapper=mapper or function(k,v) return tonum(v) end

  local res={}
  for str2 in all(split(str)) do
    local parts=split(str2,"=")
    assert(#parts==2)
    local k,v=unpack(parts)
    res[k]=mapper(k,v)
  end
  return res
end

--
-- overrides / pico-8 things
--

function rectwh(x,y,w,h,col)
 assert(w>=0 and h>=0)
 rect(x,y,x+w-1,y+h-1,col or color())
end

function rectfillwh(x,y,w,h,col)
 assert(w>=0 and h>=0)
 rectfill(x,y,x+w-1,y+h-1,col or color())
end

function strwidth(s)
 local l=0
 for i=1,#s do
  l+=(ord(s,i)<128
   and 1
   or 2)
 end
 return l*4
end

-- print center justified
function printcj(text,x,y,col)
 text=tostr(text)
 local w=strwidth(text)
 print(text,x-w\2,y,col or color())
end

normpalette=split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15"
normpalette[0]="0"
altpalette=split"0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f"
altpalette[0]="0x80"

hex=split"1,2,3,4,5,6,7,8,9,a,b,c,d,e,f"
hex[0]="0"

f_id=function(x) return x end
noop=function() end

function lerp(a,b,t)
 return a+(b-a)*t
end

function ilerp(a,b,x)
 -- returns t such that x=lerp(a,b,t)
 return (x-a)/(b-a)
end

function fmap(table,f)
 local res={}
 for i,v in pairs(table) do
  res[i]=f(v)
 end
 return res
end

-- arr could be a general table here
function filter(arr,f)
 local res={}
 for i,v in pairs(arr) do
  if (f(v)) add(res,v)
 end
 return res
end

function fany(table,f)
 f=_func_or_elem_finder(f)
 for v in all(table) do
  if (f(v)) return true
 end
 return false
end

function fall(table,f)
 f=_func_or_elem_finder(f)
 for v in all(table) do
  if (not f(v)) return false
 end
 return true
end

--
-- table/array utils
--

includes=fany

-- concat two arrays together
function concat(...)
 local t={}
 local args={...}
 for table in all(args) do
  for val in all(table) do
   add(t,val)
  end
 end
 return t
end

function merge(...)
 -- careful that both inputs
 -- are either shallow or
 -- single-use!
 local tables={...}
 local res={}
 for t in all(tables) do
   for k,v in pairs(t) do
    res[k]=v
   end
 end
 return res
end

clone=merge

function _func_or_elem_finder(f)
 return type(f)=="function"
  and f
  or function(x) return f==x end
end

function indexof(arr,f)
 f=_func_or_elem_finder(f)
 for i,v in ipairs(arr) do
  if (f(v)) return i
 end
 return nil
end

function find(arr,f)
 f=_func_or_elem_finder(f)
 for v in all(arr) do
  local x=f(v)
  if (x) return v
 end
 return nil
end

function sort(arr,f)
 f=f or f_id
 for i=1,#arr do
  for j=i+1,#arr do
   if f(arr[j])<f(arr[i]) then
    arr[i],arr[j]=arr[j],arr[i]
   end
  end
 end
 return arr --also modifies in-place
end

-- todo can this run faster? probably
function clear_table(table)
 for v in all(table) do
  del(table,v)
 end
end

function unpal(p)
 for k,v in pairs(p) do
  pal(k,k)
 end
end

--
--dialogue boxes, orignal:
-- adapted from code by oli414
-- original code here:
-- https://www.lexaloffle.com/bbs/?uid=20042
--

function dtb_init()
 dtb_numlines=2
 dtb_col_bg=15
 dtb_col_fg=7
 dtb_sfx_char=61
 dtb_ltimes={
  ["."]=6,
  ["?"]=6,
  ["!"]=6,
  [","]=8,
  ["\n"]=12,
 }
 dtb_clear()
end

function dtb_clear()
 dtb_queu={}
 dtb_queuf={}
 _dtb_clean()
end

-- is there any dialogue onscreen?
function dtb_active()
 return #dtb_queu>0
end

-- enqueue some dialogue
function dtb_disp(txt,callback)
 local lines={}
 local curline=""
 local curword=""
 local curchar=""
 local addline=function(l)
  add(lines,l)
  if #lines==dtb_numlines then
   add(dtb_queu,lines)
   add(dtb_queuf,0)
   lines={}
  end
 end
 local upt=function()
  if #curword+#curline>14 then
   addline(curline)
   curline=""
  end
  curline=curline..curword
  curword=""
 end
 for i=1,#txt do
  curchar=sub(txt,i,i)
  if curchar=="\n" then
   curline=curline..curword
   curword=""
   addline(curline)
   curline=""
  else
   curword=curword..curchar
   if curchar==" " then
    upt()
   elseif #curword>13 then
    curword=curword.."-"
    upt()
   end
  end
 end
 upt()
 if curline~="" then
  add(lines,curline)
 end
 if #lines>0 then
  add(dtb_queu,lines)
  add(dtb_queuf,callback or 0)
 else
  assert(not callback,"bug detected!")
 end
end

-- returns whether input
-- has been consumed
function dtb_update()
 dtb_flash_t=(dtb_flash_t or 0)+1
 if dtb_active() then
  if dtb_curline==0 then
   dtb_curline=1
  end
  local dislineslength=#dtb_dislines
  local curlines=dtb_queu[1]
  local curlinelength=#dtb_dislines[dislineslength]
  local complete=curlinelength>=#curlines[dtb_curline]
  if complete and dtb_curline>=#curlines then
   if btnp(5) then
    _dtb_nexttext()
    return true
   end
  elseif dtb_curline>0 then
   dtb_ltime-=1
   if complete then
    _dtb_nextline()
   else
    if dtb_ltime<=0 then
     local curchari=curlinelength+1
     local curchar=sub(curlines[dtb_curline],curchari,curchari)
     if curchar~=" " then
      if (dtb_sfx_char) sfx(dtb_sfx_char)
     end
     dtb_ltime=
      dtb_ltimes[curchar] or 1
     dtb_dislines[dislineslength]=dtb_dislines[dislineslength]..curchar
    end
   end
  end
 end
 return false
end

function dtb_draw()
 if dtb_active() then
  local dislineslength=#dtb_dislines
  local offset=0
  if dtb_curline<dislineslength then
   offset=dislineslength-dtb_curline
  end
  local x=3
  local h=dtb_numlines*8
  local y=3
  rectfill(x,y-1,60,y+h,3)
  rectfill(x-1,y,61,y+h-1,3)
  rectfill(x,y,60,y+h-1,dtb_col_bg)
  pset(x,y,3)
  pset(x,y+h-1,3)
  pset(60,y,3)
  pset(60,y+h-1,3)
  for i=1,dislineslength do
   print(dtb_dislines[i],5,12-(dislineslength+offset-i)*7,dtb_col_fg)
  end
 end
end

function _dtb_clean()
 dtb_dislines={}
 for i=1,dtb_numlines do
  add(dtb_dislines,"")
 end
 dtb_curline=0
 dtb_ltime=0
 dtb_flash_t=nil
end

function _dtb_nextline()
 dtb_curline+=1
 for i=1,#dtb_dislines-1 do
  dtb_dislines[i]=dtb_dislines[i+1]
 end
 dtb_dislines[#dtb_dislines]=""
end

function _dtb_nexttext()
 if dtb_queuf[1]~=0 then
  dtb_queuf[1]()
 end
 deli(dtb_queuf,1)
 deli(dtb_queu,1)
 _dtb_clean()
end



-- px9 decompress

-- x0,y0 where to draw to
-- src   compressed data address
-- vget  read function (x,y)
-- vset  write function (x,y,v)

function
	px9_decomp(x0,y0,src,vget,vset)

	local function vlist_val(l, val)
		-- find position
		for i=1,#l do
			if l[i]==val then
				for j=i,2,-1 do
					l[j]=l[j-1]
				end
				l[1] = val
				return i
			end
		end
	end

	-- bit cache is between 16 and 
	-- 31 bits long with the next
	-- bit always aligned to the
	-- lsb of the fractional part
	local cache,cache_bits=0,0
	function getval(bits)
		if cache_bits<16 then
			-- cache next 16 bits
			cache+=%src>>>16-cache_bits
			cache_bits+=16
			src+=2
		end
		-- clip out the bits we want
		-- and shift to integer bits
		local val=cache<<32-bits>>>16-bits
		-- now shift those bits out
		-- of the cache
		cache=cache>>>bits
		cache_bits-=bits
		return val
	end

	-- get number plus n
	function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header

	local 
		w,h_1,      -- w,h-1
		eb,el,pr,
		x,y,
		splen,
		predict
		=
		gnp"1",gnp"0",
		gnp"1",{},{},
		0,0,
		0
		--,nil

	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w-1 do
			splen-=1

			if(splen<1) then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a]
			if not l then
				l={}
				for e in all(el) do
					add(l,e)
				end
				pr[a]=l
			end

			-- grab index from stream
			-- iff predicted, always 1

			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)

			-- advance
			x+=1
			y+=x\w
			x%=w
		end
	end
end

-->8
-- quotes and returns its
--  arguments
-- usage:
--  ?q("p.x=", x, "p.y=", y)
function q(...)
 local parts={...}
 local s=""
 -- using #parts is necessary
 --  to properly handle nils
 --  in the varags.
 -- this will drop any trailing
 --  nils, idk how to stop that
 for i=1,#parts do
  s..=tostr(parts[i]).." "
 end
 return s
end

-- sorta like sprintf (from c)
-- usage:
--  ?qf("p={x=%,y=%}", p.x, p.y)
function qf(...)
 local parts={...}
 local fstr=parts[1]
 local argi=2
 local s=""
 for i=1,#fstr do
  local c=sub(fstr,i,i)
  if c=="%" then
   s..=tostr(parts[argi])
   argi+=1
  else
   s..=c
  end
 end
 return s
end

-- quotes a table
function qt(t)
 local s="{"
 for k,v in pairs(t) do
  s..=tostr(k).."="..tostr(v)..","
 end
 s..="}"
 return s
end

-- quotes an array
function qa(t)
 local s="{"
 for v in all(t) do
  s..=tostr(v)..","
 end
 s..="}"
 return s
end



__gfx__
0000000000667700006677000066770000667700000cc00000000000000000000000000000000000000000000000000000000000ffffffffffffffff00cc0000
00000000066777700667777006677770066777700000400000000000002288000066770000066770066770000000000000fff000fff777ffffffffff00004000
00700700067e7e70067e7e70067e7e70067e7e7000999990000707000228888006677770006677776677770000fff0000fffff00ff77777ffff777ff09b99990
00077000067e7e70067e7e70767e7e76767e7e760999b9a900007000028e8e80067e7e700067e7e767e7e7000fffff0006f66f00f7777777ff77777f0b99bb99
0007700000670770006707706067077660670776b99ab99b00007000028e8e80067e7e700067e7e767e7e70006f66f0008686600f7f77f77f7777777b99b9999
00700700060677000706770070067706700677069a9bb9ab000070000028088000670770000670770670770008686600066666e0f7f77f77f7f77f7799b9999b
000000000e7000000e700000067000700670007099aaaa9b0000700000028800000677000000677000677000066666e007f76fe0f7777777f7f77f7799b9b9bb
0000000070e7007070e7007000e7000000e70000099b99b0000707000800000006000000006000006000000007f76fe000666ee0f77f7777f77777770999b9b0
eeeeeeee707e7070707e7070007e7000007e700000cc0000000000000e82e8000e76e7000e76e7000e76e70000ff6ee000eeeee0f7777777f77f77770000cc00
eeeee9ee70060070700600700006000000060000000040000000000080e8008070e7007007e7000770e7007000eeeee000dddee0f7777777f777777700040000
ee9eeeee007070000070700000707000007070000099b99000000000808e8080707e7070067e7007707e707000dddee000ddd6e0f7777777f777777709b99990
eeeeeeee006760000667660006676600006760000b9ab9a9000000008002008070060070070600077006007000dddee000dddee0f7777777f77777779b999990
eeeeee9e06000600070007000700070006000600b99bb999000000000080800000707000007070000070700000ddd6e000dddee0f7f7f7f7f7777777b99b99b9
eeeeeeee070007000000000006000600070007009aabaaab070000700028200000676000006760000067600000dddee000dddee0fffffffff7f7f7f799b99b99
9eeeeeee0600060000000000000000000600060099aaaabb007777000200020000707000007006000006600000dddeee00dddeeeffffffffffffffff99b99b99
eeeeeeee00000000000000000000000000000000099b99b007000070080008000070700000700700000770000000000000000000ffffffffffffffff0b99b990
0088800000088800000900000009000000090000000a00000000000000000000000000000000000000000000000000000000ff00000000000000330000000000
08688800008688800000a0000009a00000009000000aa000000000000000000000fffff0000000000000000000000000000ff0f00000ff0000066030000cc000
866888000866888800003000000090000000000000a9a0000000000000fffff000fffff000000000000000000001110000ffff00000ff0f00066660000040000
868888800868888800090300000303000030a000000a00000007000000fffff000fcfcf00044440000000000000010000ffffff000ffff000666666004999400
88888880088888880003a000000a000000090000000600000770770000fcfcf000ccccf004ccc440004444000001c10004ccc4400ffffff0065656509f99f900
08888800008888800003a00000003a00000a0030000600000007000000ccccc0008c8ccf002c2c4004ccc440001acc10002c2c4004ccc4400656565049999f90
008880000008880000a00a0000a009090a000000ee0eeee007707700008c8ccf00ccccff00cccc40002c2c40001cca1000cccc40002c2c40066666609ffff940
0000880000880000090030a00000a00000a0300a0eeeee000007000000ccccff000ccccf004cc44000cccc4000011100004cc44000cccc400066660004999400
00006000000600000000000000000000eeeeeeee000a0000000000000c2ccccf0002222000fcff40004cc4400000000000fcff40004cc4400656656070670607
00066000000660000077776000777760eeeeeeee00aa000000000000000222200c2222c000ffff4000fcff4009cac90000ffff4000fcff406665566606007060
00060000000060000777776607e7e766e9eeee9e00a9a0000000000000022c200002222000ffff0000ffff4009acc90000ffff0000ffff406066660600760700
006000000000060007e7e76607e7e776eeeeeeee000a000000000000000222200002222000fffc0000ffff00099a990000fffc0000ffff006066660607007066
006000000000060007e7e77607777766eeeeeeee00060000eeeeeeee000222200001111000ffff0000fffc000099900000ffff0000fffc000066660006070070
00060000000060000777776007767660eee9ee9e000600000e0000e0000111100001001000fffff000ffff000009000000ffff0000ffff000066660000706700
00060000000060000076760000767600eeeeeeeeee0eeee000000000000100100001001000ffffff00fffff00009000000fffff000fffff00060060000060070
00000000000000000000000000000000eeeeeeee0eeeee0000000000000000000000000000000000000000000099900000000000000000000066066000000006
bbbbbbbbbbbbbbb0007e67e0007e67e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b999999b999999b007007e0707007e07000000000000000000888000000888000000000000000000000000000000000000000000000000000000000000000000
b999999b999999b00707e7070707e707000000000000000008688800008688800000000000000000000000000000000000000000000000000000000000000000
b999999b999999b00700600707006007000000000000000086688800086688880000000000000000000000000000000000000000000000000000000000000000
b999999b999999b000070700000707000ffffffff000000086888880086888880000000000000000000000000000000000000000000000000000000000000000
b9999b9b9b9999b00006760000067600fcaccacacf00000088888880088888880000000000000000000000000000000000000000000000000000000000000000
b999999b999999b00007070000600060ffffffffff00000008888800008888800000000000000000000000000000000000000000000000000000000000000000
b999999b999999b000070700007000700ffffffff000000000888000000888000000000000000000000000000000000000000000000000000000000000000000
b999999b999999b00090000f00000000ffffffffff00000000008800008800000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbb00f0f009000000000ffffffffff00000000006000000600000000000000000000000000000000000000000000000000000000000000000000
000000000000000090009f0000000000ffffffffff00000000066000000660000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ffffffffff00000000060000000060000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000090009000ffffffff000000000600000000006000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009a900000ffffff0000000000600000000006000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009a9000f0f0000f0f00000000060000000060000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000090009000f000000f000000000060000000060000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb0000000000000000000000000000000006666660000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb0000000000000000000000000000000066066066000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb0000000000000000000000000000000066600666000000000000000000000000000000000000000000000000000000000000000000000000
beeeeeeeeeeeeeeb0000000000000000000000000000000066066066000000000000000000000000000000000000000000000000000000000000000000000000
b00000000000000b666000f66000f6600f66000f66000f6606666660000000000000000000000000000000000000000000000000000000000000000000000000
b00000000000000b666000f66000f6600f66000f66000f6600000000000000000000000000000000000000000000000000000000000000000000000000000000
b00000000000000b6666666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
b00000000000000b6666666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ddd66666666666666666666666666ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000333dddddddddddddddddddddddddd33300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
0066600f66600666133d33d333333333333333333333333100000000000000000000000000000000000000000000000000000000000000000000000000000000
0066600f6660066613dddddd33333333333333333333333100000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666661333d33333333333333333333333333100000000000000000000000000000000000000000000000000000000000000000000000000000000
00ddd66666666ddd1333d33333333333333333333333333100000000000000000000000000000000000000000000000000000000000000000000000000000000
00333dddddddd33313ddddddd3eeeeeeeeeee333d33d3331bbbbbbbbbbbbbbb0000000000677777760000000000000000000000e000000000000000e00000000
0033333333333333133d333d33e9e99e99e9e33dddddd331beeeeeebeeeeeeb00bbbb0006777777766666660000000000000000200000000000000020000cc00
0033d33d33333333133d333d33e9e99e99e9e3333d333331beeeeeebeeeeeeb0bb44b0006557775567e77760000000000000000e000000000000000e000cc7c0
003dddddd333333313333dddd3e9e99e99e9e3333d333331beeeeeebeeeeeeb0b444b0006755555767e7e76000000000000000020000000000000002000cccc0
00333d33333333331333333333e9e99e99e9e33ddddddd31beeeeeebeeeeeeb0b444b0006777777766666660000000000000000e000000000000000e0000cc00
00333d33333333331333333333eeeeeeeeeee333d333d331beeeeeebeeeeeeb0b444b00066777777666666600000a0000a0000e20000a0000a0000e200c00000
003ddddddd333333133333333333333333333333d333d331beeeeeebeeeeeeb0b444b0005666666666666660000aa0000aa000020000aa00aa0000020ccc0000
0033d333d333333313333333333333333333333333dddd31beeeeeebeeeeeeb0b444b0006666666665000000000a9a00a9a0000e000a9a00a9a0000e00c00000
0033d333d333333313333333333333333333333333333331beeeeeebeeeeeeb0b444b00065555555560000000000a0000a00002e0000a0000a00002e00000c00
003333dddd33333313333333333333333333333333333331bbbbbbbbbbbbbbb0b444b0006666666666666660000060000600002000006000060000200000ccc0
0033333333333333133333333333333333333333333333310000000000000000be44b000677777776777776000002000020000e000002000020000e000000c00
0033333333333333133333333333333333333333333333310000000000000000bbeeb0006779777767e77e6000002000020002e000002000020002e000000000
003333333333333313333333333bb4bbb4bb33333333333100000000000000000bbbb000679979e76eee7e600000e0000e002e000000e0000e002e0000cc0000
003333333333333313333333334bb4bbb4bb43333333333100000000000000000000000067e979976666666000002e002e0ee00000002e002e0ee0000c7cc000
0033333333333333133333333b4bb4bbb4bb4b3333333331000000000000000000000000679979976666666000000eeeeeee000000000eeeeeee00000cccc000
003333333333333313333333bb4bb4bbb4bb4bb33333333100000000000000000000000066666666666666600000000000000000000000000000000000cc0000
003333333333333313333333bb4bb4bbb4bb4bb333333331bbbbbbbbbbbbbbb0000002000666666660000000bbbbbbbbbbbbbbbb0001000100acca0c00000000
003333333333333313333333bb4bb4bbb4bb4bb333333331b9999b0b999999b000002a206666666666000000b999999bb999999b000100010ccc0cc00000c000
003333333333333313333333bb4bb4bbb4bb4bb333333331b9999b0b999999b00000c2006666666666000000b9bbbb9bb9bbbb9b111111110ac4acc000000000
0033333333d33d33133d3333bb4bb4bbb4bb4bb333333331b9999b0b999999b000cc00006566666666000000b999999bb999999b10000010ccc4cc0000c00c00
003333333dddddd313ddddd3bb4bb4bbb4bb4bb333333331b9999b0b999999b0000c00005666666666000000bbbbbb0bbeeeeeeb10000010ccccc00000000000
003333333333d33313333d33bb4bb4bbb4bb4bb333333331b99b9b0b9b9999b0011111105666666666000000bbbb9b0bbeeeeeeb111111110ac4cc00000c0000
003333333333d33313333d33bb4bb4bbb4bb4bb333333331b9999b0b999999b0001111006566666666000000bbbb9b0bbeeeeeeb0100010000c44c0000000000
00333333ddddddd3133dddd3bb4bb4bbb4bb4bb333333331b9999b0b999999b0001111005666666665000000bbbbbb0bbeeeeeeb01000100000c400000000000
003333333d333d3313333333bb4bb4bbb4bb4bb33d333d31b9999b0b999999b0000110006555555556000000bbbbbbbb00000000010010000000400000000000
003333333d333d3313333333bb4bb4bbb4bb4bb33dddddd1bbbbbbbbbbbbbbb00bbbbbb06666666666000000b999999b00000000111111100004400000000000
00333333dddd333313333333bb4bb4bbb4bb4bb3333d333100000000000000000b9999b06566666666000000b9bbbb9b0000000000100000bbeeeebb00000000
003333333333333313333333bb4bb4bbb4bb4bb3333d333100000000000000000b9bb9b05666666666000000b999999b00000600001000000bbbbbb000000000
003333333333333313333333bb4bb4bbb4bb4bb333ddd33100000000000000000b9999b05666666666000000bbbbbbbb00006000111111100bbbbbb000000000
003333333333333313333333bb4bb4bbb4bb4bb33333333100000000000000000bbbbbb06566666666000000bbbbbb9b00066d00010001000bbbbbb000000000
003333333333333313333333bb4bb4bbb4bb4bb33333333100000000000000000bbbbbb06666666666000000bbbbbb9b006d66d0010001000bbbbbe000000000
003333333333333313333333bb4bb4bbb4bb4bb33333333100000000000000000bbbbbb06666666666000000bbbbbbbb00066d000001111000bbbe0000000000
0000000888888888888888888800000000000000000000000000000000000000e0000000000000e0000000000002202222022000242222222242000000022000
000000888888888888888888880000000000000000000000000000000000000e2e00000000000e2e000000000022222222222200eeeeeeeeeeee000000223200
000000888888888888888888888000000000000000000000000000000000222e2e22222222222e2e222200000222292922292200242222222242000002323320
00000888888888888888888888880000000000000000000000000000000022e222e222222222e222e22200000229222292222200242222222242000002323320
00008888888888888888888888880000000000000000000000000000000222e2e2e222222222e2e2e22220000292922222222220242222222242000002323320
00008888888888888888888888888000000000000000000000000000000222e2e2e222222222e2e2e22220002929222222292220242222222242000002323320
0008888888888888888888888888800000000000000000000000000000222e2e2e2e2222222e2e2e2e2222002992229222222222242222222242000002323320
0088888888888888888888888888880000000000000000000000000000222e2e2e2e2222222e2e2e2e22220022922222292b2222242222222242000002222220
08888888888888888888888888888800000000004b0004b00004b0000222e2e222e2e22222e2e222e2e222202029222222b22922242222222242000002323320
088888888888888888888888888888800000000044444444444444440222e2e222e2e22222e2e222e2e222202292292224222222242222222242000002323320
88888888888888888888888888888888000000004b0004b00004b000222e2e22222e2e222e2e22222e2e22222222b22b42220222224222222422000002323320
88888888888888888888888888888888000000004b0004b00004b00022e22222222222e2e22222222222e22202222bb444922929022422224220000002222220
022222222222222222222222222222220f0ff0f044444444444444440dddddddddddddddddddddddddddddd0022922b444220222002242242200000000000000
0dddddddddddddddddddddddddddddd0f0f9f90f4b0004b00004b0000dddddddddddddddddddddddddddddd0022222b444202200000224422000000000000000
0ddddddddddddddddddd222222ddddd00ffffff04b0004b00004b0000ddddddddddddddddddeeeeeedddddd0092222b444222200000022220000000000000000
0dddddddddddddddddd22222222dddd0f00ff00f4b0004b00004b0000dddededddededddddeeeeeeeeddddd0002092b444222000000002200000000000000000
0ddd222222222ddddd2222222222ddd00077770000dddd00000dd0000dddeeeeeeeeeddddeeeeeeeeeedddd0000020b440040000000000000000000000000000
0ddd299929992dddd222222222222dd0077766700dddddd0000dd0000ddde999e999edddeeeeeeeeeeeeddd0000022b444440000000000000000000000000000
0ddd299929992dddd222222222222dd0776777770d6666d00dd00dd00ddde999e999edddeeeeeeeeeeeeddd0000000b444400000000000000000000000000000
0ddd299929992dddd222222222222dd0777777670d6666d00dd00dd00ddde999e999edddeeeeeeeeeeeeddd0000b00b440000000000000000000000000000000
0ddd222222222dddd222222222222dd0777777770dddddd0000dd0000dddeeeeeeeeedddeeeeeeeeeeeeddd0000bb0b440000000000000099000000000000000
0ddd299929992dddd222222222222dd0766767770dddddd0000dd0000ddde999e999edddeeeeeeeeeeeeddd00000bbb440000000000990999900000000000000
0ddd299929992dddd222222222222dd0077767700dddddd0000dd0000ddde999e999edddeeeeeeeeeeeeddd0000000b4400000000099999999999000f0000000
0ddd299929992dddd222222229922dd0007777000d4444d000dddd000ddde999e999edddeeeeeeee99eeddd0000000b44000000009999a9a999a9000f0000000
0ddd222222222dddd222222229922dd00000ff004444b4400d44bdd00dddeeeeeeeeedddeeeeeeee99eeddd0000000b44000000009909999a9999000ffffffff
0dddddddddddddddd222222222222dd0000ff0f04bb44bb44bb444b00dddddddddddddddeeeeeeeeeeeeddd0000000b44000000009a9b99999999000f0f0f0f0
0dddddddddddddddd222222222222dd000ffff0000000000000000000dddddddddddddddeeeeeeeeeeeeddd0000000b4400000009a9a999b99ba9900ff0fff0f
0dddddddddddddddd222222222222dd000ffff0000000000000000000dddddddddddddddeeeeeeeeeeeeddd0000000b4400000009aa9b9b9a9b99900ff0fff0f
0dddddddddddddddd222222222222dd00ffffff000000000000000000dddddddddddddddeeeeeeeeeeeeddd0000000b44000000099a99bb99ab90900f0f0f0f0
0dddddddddddddddd222222222222dd0ffffffff00000000000000000dddddddddddddddeeeeeeeeeeeeddd0000000b444000000009a99b9b9999900ffffffff
0dddddddddddddddd222222222222dd00000000000000000000000000dddddddddddddddeeeeeeeeeeeeddd000000bb44400000009a99bbb99099000f0000000
0dddddddddddddddd222222222222dd00000000000000000000000000dddddddddddddddeeeeeeeeeeeeddd00000bbb4444400000999999b99090000f0000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
fffffff0ffff0fed7cc6ffffffffffd780ff7fc9ff84ffffff5f94ff7fc7ffac410affffa590a136fe2f6408ff7f860c61f67f2a8cffbfc30affbb0bf0ff6ff000ffbfa0f0ff7706c3ff2e08e1ffff0c09ffb790c2ffbf0942c2ff6df8ff63c3ff8dffffc6ffffffff432dc0011a0084ffff5bb8820bf03fe1ffef801f8007f8
ffb3e08f9003fc4ff8ff377800c30fe0ffbff23fe7ffffff9dc313842b7c41b8c2ff9f01090947f8893b40f8ff432121212804e1286480130082e1ffef8003f800fe29bc38c0ffdf09ff80ffc045f8ff3b21405810120c82e11b7004007ff07fe77fc1f83ff1ffd7c2ffff2f04fccff8ff6ffceff8ffffff62b0709080900708
4718f8ff5b21201c83904140380818bff1ff170621fc17c20320e037feff03631c64184fc0c1f895ffffc1ff7fe0ffffff83410186d080812b1ca1fcffa510120e84201cfc19feffd230021a1ec2825050f0ff670e70f2861b0c2c5c0ff0ff2f2842c23de4002384200007fff0ff1706fc107a80f28592f00fffff81f04768e1
0fc6ff3f2edc1418feff68f8ffdf8c937213feff6118b8c2286ff8ff5f3c2420a124e0e00bff7f8cdfc3131a4618ffff95ff1fffffffdf040a30c21016feff69080947381080ffbf3a8c8012feffea014e7e7c80ff7f471112cec2c1c2effcff9d01653800feff31e12e0cfcff6b7014feff3f20fcff7f03e5ffff03c2c0ffdf
e5218c04248cff3fca6fe17fc5ffdfe3ffc5ffffffff6be7e0ffef2308f8ffff8010f0ffff0121e0ffdf0f0dff2ffeff17ff4bfeffffff5f66f8ff67e0ff5630fcff9b4110fe6f21c3ff1f1a12fe6f01c0ffbf2140f8df05e0ffff8084ffdf05f8ff3b17e07f4718ffff8612fe6f4308ffff8561f8dff1ffe7f89ff1ffffffff
04a4f6ffffffff08ecffffffe501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff0ffff0f3dc73bc3eef9ffffffffffffff7f0ee2ff5ff23fe1ffffff8924fcff130bff6719af040040f8bf25022074f83fc9c299e427a6e37fb21081a080ff15bfc05862470ea48eff93858127fc8f64e1615d8e8e251afe67f2bf0db1186e2589271c1e5cfcffad88b09187a099b14a13ffff8fb0c4c1936d3c6c4bfe
8f830710f01104200396ec94700492c4c1fff6c88022346c103c80e1229cd267528f5e3065e5e27fb444812084301ce008c293f5927138fee1ffc885206c58f840c2c7c14193fdc4ffb782804939e9f0ff1ff933fc9fe2fb8353fe4740f89737fcaef319fec7180c21080100f2004f00803fe21b3ff03f44238006830fc00170
0417e017feff034208580000c0109ec211fe0200f03f4508c042f8677828e11ffeff0bc8f017ff0cbff0ffffffffd6c3ff273ca1e17fcfc145c09f9403fcff1f12ce60f813e121e197f0ff1fc8f0bf47f8ff0724a000ff1bf047f8ff0f0886627841c01fe00103ff7f832f8c040708020efe1842080204fcff99209471845f0e
10c25030fcff099e1700e04110460e00410002feff083f10feff7f60f8ffff8480ffffffff376bd5ffffffff4760ffffffffffffffffdb07ffdf2f08f8ffff8010f0ffff0121e0ffdf0f0dffffffffffbf4800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000c0433f0003f6153f6150c0330300303003030030c0433f6003f6153f6150c0330c03300003000030c0433f0003f6153f6150c0330000300003000030c0430c0003f6153f6150c033000030c03300003
011000001a5521a5521a5521a551215512655126552265522155121551215512155221552215522155221555225522255522555245522455224551225522255521552215551e5521e55121551215522155221555
011000001a5521a5521a5521a551215512655126552265522155121551215512155221552215522155221555245522455222552225552155221555205522055521552215551e5521e55121551215522155221555
011000000255202552035520355209552095520955209552035520355205552055520555205552035520355202552025520355203552095520955209552095520355204552035520255203552045520355202552
01100000215321f532215322153221532215322153221535000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e5520e5520e5520e551155511a5511a5521a552155511555115551155521555215552155521555516552165551655518552185521855116552165551555215555125521255115551155521555215555
0110000009532075320953209532095320953209532095350a7000a70007700077000570005700057000570003700037000370003700007000370003700037000370003700037000370003700037000370003700
01080000030510a0510f051160511b0512205129051300513a0513f05100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
011000000e5520e5520e5520e551155511a5511a5521a552155511555115551155521555215552155521555518552185521655216555155521555514552145551555215555125521255115551155521555215555
010200000355003550025500255001550005500050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200000055001550025500255003550035500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000116240e620166202462000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000a6500f66007650056500f600086000060003600026000160001600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01040000006052e6752b665276551f64518625116150a60503605226051f6051f6052260522605226050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000000a055110551a0551f05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000000024020240202402000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001b0501d050220502405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000a05005050110501a05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000b04109041070410504103041010410004103001030010300103001030010300103001030010300103001030010300103001000010000100001000010000100001000010000100001000010000100001
010700001153300503075030c5030f503085030050303503025030150301503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300000
000400000c61311613076230060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
000500002460300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006000060000000
__music__
01 00 42 43 44
00 00 01 05 44
00 00 08 02 44
00 00 42 43 44
00 00 03 43 44
02 00 03 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
04 04 06 43 44
