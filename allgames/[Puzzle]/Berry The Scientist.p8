pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- berry the scientist
-- by ahmed khalifa

function _init()
 frame=0
 current_state="menu"
 check_point=0
 enemy_ticks=0
end

function start_game()
 width=9
 height=8
 tile_size = 12
 health=3
 enable_dash=false
 shift_x,shift_y=tile_size - (128-tile_size*width)/2,tile_size-4
 lvls={8,9,10,11,12,-1,1,-2,-2,4,5,-3,-3,7,-4,-4,-4,3,-5,-5,-5,6,-6,-6,-6}
 current=check_point
 difficulty=0
 current_state="anim"
 world=new_world()
 animworld=new_animworld()
 world:next_level()
end

function _update()
 if current_state == "menu" then
  frame+=1
  if (btnp(—) or btnp(Ž)) sfx(1) start_game()
 elseif current_state == "anim" then
  animworld:update()
 elseif current_state == "game" then
  world:update()
 end
end

function _draw()
 cls()
 if current_state == "menu" then
  spr(233,43,40,5,2)
  printc("the scientist",64,60)
  local color=7
  if (frame % 10 < 5) color=5
  printc("press — or Ž to start",60,82,color)
  printc("game by ahmed khalifa",64,112)
  printc("suggestion by @mtrc and @dw817",64,120)

 elseif current_state == "anim" then
  animworld:draw()
 elseif current_state == "game" then
  world:draw()
 end
end

function lerp(v1,v2,t)
  return (v2 - v1)*t+v1
end

function printc(string,x,y,c)
  c=c or 7
  print(string,x-#string*2,y-2,c)
end

function sign(value)
  if (value > 0) return 1
  if (value < 0) return -1
  return 0
end
--
-- function array_cmp(a1, a2)
--   return a1 - a2
-- end

function tile_cmp(t1,t2)
  local dist1=abs(world.player.tile.x-t1.x)+abs(world.player.tile.y-t1.y)
  local dist2=abs(world.player.tile.x-t2.x)+abs(world.player.tile.y-t2.y)
  return dist1-dist2 + 1*rnd()
end

-- function close_monster_cmp(t1,t2)
--   local dist1=abs(3-t1.x)+abs(2-t1.y)
--   local dist2=abs(3-t2.x)+abs(2-t2.y)
--   return dist1-dist2 + 2*rnd()
-- end
--
-- function far_monster_cmp(t1,t2)
--   local dist1=abs(3-t1.x)+abs(2-t1.y)
--   local dist2=abs(3-t2.x)+abs(2-t2.y)
--   return dist2-dist2 + 2*rnd()
-- end

-- function get_empty_number(x,y)
--   local t=world:get_tile(x,y)
--   if (t==nil or t:is_solid() or t.entity != nil) return -1
--   local result=0
--   for dx=-1,1 do
--     for dy=-1,1 do
--       t=world:get_tile(x+dx,y+dy)
--       if (t!=nil and not t:is_solid() and t.entity == nil) result+=1
--     end
--   end
--   return result
-- end

-- function king_cmp(t1,t2)
--   local loc1=get_empty_number(t1.x,t1.y)
--   local loc2=get_empty_number(t2.x,t2.y)
--   local dist1=abs(world.player.tile.x-t1.x)+abs(world.player.tile.y-t1.y)
--   local dist2=abs(world.player.tile.x-t2.x)+abs(world.player.tile.y-t2.y)
--   return 10*(loc1-loc2) + dist1-dist2
-- end

function trap_cmp(t1,t2)
  -- local bottle1=0
  -- local up,down,left,right=world:get_tile(t1.x,t1.y-1),world:get_tile(t1.x,t1.y+1),world:get_tile(t1.x-1,t1.y),world:get_tile(t1.x+1,t1.y)
  -- if (up == nil or up:is_solid()) and (down == nil or down:is_solid()) then
  --   bottle1 = 1
  -- elseif (left == nil or left:is_solid()) and (right == nil or right:is_solid()) then
  --   bottle1 = 1
  -- end
  -- local bottle2=0
  -- up,down,left,right=world:get_tile(t2.x,t2.y-1),world:get_tile(t2.x,t2.y+1),world:get_tile(t2.x-1,t2.y),world:get_tile(t2.x+1,t2.y)
  -- if (up == nil or up:is_solid()) and (down == nil or down:is_solid()) then
  --   bottle2 = 1
  -- elseif (left == nil or left:is_solid()) and (right == nil or right:is_solid()) then
  --   bottle2 = 1
  -- end
  local dist1=abs(world.player.tile.x-t1.x)+abs(world.player.tile.y-t1.y)
  local dist2=abs(world.player.tile.x-t2.x)+abs(world.player.tile.y-t2.y)
  local trap1=t1.cursed
  local trap2=t2.cursed
  return 10*(trap2-trap1) + (dist1-dist2)
end

function sort(a,fn)
  -- fn = fn or array_cmp
  for i=1,#a do
    local j = i
    while j > 1 and fn(a[j-1],a[j]) > 0 do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end

-- function calc_dikjstra(entity,x,y)
--   local dirs={{-1,0},{1,0},{0,-1},{0,1}}
--   local dikjstra = {}
--   for x=1,width do
--     for y=1,height do
--       dikjstra[x..","..y]=-1
--     end
--   end
--   local visited = {}
--   local queue = {{x,y,0}}
--   while #queue > 0 do
--     local current = queue[1]
--     local cx,cy,cd=current[1],current[2],current[3]
--     del(queue,queue[1])
--     if not visited[cx..","..cy] or dikjstra[cx..","..cy] > cd then
--       visited[cx..","..cy] = true
--       dikjstra[cx..","..cy] = cd
--       for d in all(dirs) do
--         local nx,ny,nd=cx+d[1],cy+d[2],cd+1
--         local tile = world:get_tile(nx,ny)
--         if not world:check_outside(nx,ny) and not tile:is_solid() and (tile.entity == nil or tile.entity == entity) then
--           add(queue,{nx,ny,nd})
--         end
--       end
--     end
--   end
--   return dikjstra
-- end

function get_human_map(lvl)
  local shift_x=(lvl-1)*8
  local map={}
  for x=1,width-2 do
    for y=1,height-2 do
      map[x..","..y] = mget(shift_x+x-1,y-1)
    end
  end
  return map
end

function transform_monster_tiles(map)
  local tiles={}
  for x=1,width-2 do
    for y=1,height-2 do
      tiles[x..","..y] = 0
      local value=map[x..","..y]
      if(value < 8) tiles[x..","..y]=value map[x..","..y]=10
      if (current < 12 and map[x..","..y]==12) map[x..","..y]=10
    end
  end
  return tiles
end

function is_monster(value,monster)
  return value == 3 or (value == 1 and monster !=3)
end

-- function get_monster_tiles(tiles,monster)
--   local results={}
--   for x=1,width-2 do
--     for y=1,height-2 do
--       if(is_monster(tiles[x..","..y],monster)) add(results,{x=x,y=y})
--     end
--   end
--   sort(results, far_monster_cmp)
--   if (monster == 3) sort(results, close_monster_cmp)
--   return results
-- end

-- function get_nice_locations(tiles,monster)
--   local list=get_monster_tiles(tiles,monster)
--
--   local v=rnd()
--   local t=list[flr(rnd()*#list) + 1]
--   if v < 0.5 then
--     t=list[flr(rnd()*#list/4) + 1]
--   elseif v<0.75 then
--     t=list[flr(rnd()*#list/2) + 1]
--   end
--   del(list,t)
--
--   local results={}
--   if(is_monster(tiles[7-t.x..","..t.y],monster)) add(results,{x=7-t.x,y=t.y})
--   if(is_monster(tiles[t.x..","..6-t.y],monster)) add(results,{x=t.x,y=6-t.y})
--   if(is_monster(tiles[7-t.x..","..6-t.y],monster)) add(results,{x=7-t.x,y=6-t.y})
--   if (#results > 0) return{t,results[1+flr(rnd()*#results)]}
--   return {t,list[1+flr(rnd()*#list)]}
-- end

function check_cmp(c1, c2)
  return c1.c - c2.c
end

function get_tile_corners(tiles,corners,x,y,monster)
  local corners={{x=x,y=y,m=is_monster(tiles[x..","..y],monster),c=corners[1],i=1},
          {x=8-x,y=y,m=is_monster(tiles[(8-x)..","..y],monster),c=corners[2],i=2},
          {x=x,y=7-y,m=is_monster(tiles[x..","..(7-y)],monster),c=corners[3],i=3},
          {x=8-x,y=7-y,m=is_monster(tiles[(8-x)..","..(7-y)],monster),c=corners[4],i=4}}
  if x==4 then
    return {corners[1],corners[3]}
  end
  return corners
end

function pick_tiles(tiles,corners,monster)
  local possibles={}
  for x=1,4 do
    for y=1,3 do
      local check=get_tile_corners(tiles,corners,x,y,monster)
      for c in all(check) do
        if (not c.m) del(check,c)
      end
      if (#check >= 2) then
        sort(check,check_cmp)
        add(possibles,{t1x=check[1].x,t1y=check[1].y,t1i=check[1].i,
                      t2x=check[2].x,t2y=check[2].y,t2i=check[2].i,
                      c=check[1].c+check[2].c+rnd()})
      end
    end
  end
  sort(possibles,check_cmp)
  return possibles[1]
end

function pick_center_tile(tiles,monster)
  local result={}
  for y=1,6 do
    if (is_monster(tiles["4"..","..y],monster)) add(result,{x=4,y=y})
  end
  return result[flr(rnd()*#result)+1]
end

function add_monsters(map,lvl)
  local monsters={}
  local row=flr(rnd()*5)+3
  if (difficulty <= 1) row=flr(rnd()*2)
  if (difficulty <= 2) row=flr(rnd()*4)+2
  local row=min(flr(difficulty/2 + rnd()*difficulty/2),7)
  for i=0,7 do
    local m=mget((lvl-1)*8+i,8+row)
    if (monsters[m] == nil) monsters[m]=0
    if (m != 0) monsters[m]+=1
  end

  local tiles=transform_monster_tiles(map)

  for m,amount in pairs(monsters) do
    if amount%2 == 1 then
      monsters[m]-=1
      local t=pick_center_tile(tiles,m)
      if(t!=nil) tiles[t.x..","..t.y]=0 map[t.x..","..t.y]=m
    end
  end

  local corners={0,0,0,0}

  for m,amount in pairs(monsters) do
    for i=1,amount/2 do
      local p=pick_tiles(tiles,corners,m)
      if p!=nil then
        corners[p.t1i] += 1
        corners[p.t2i] += 1
        tiles[p.t1x..","..p.t1y]=0
        map[p.t1x..","..p.t1y]=m
        tiles[p.t2x..","..p.t2y]=0
        map[p.t2x..","..p.t2y]=m
      end
    end
  end
end

function modify_corner_layout(map)
  local start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(x+1)..","..(y+1)] = mget(start_x+x,y+24)
      map[(x+1)..","..(6-y)] = mget(start_x+x,y+24)
      map[(7-x)..","..(y+1)] = mget(start_x+x,y+24)
      map[(7-x)..","..(6-y)] = mget(start_x+x,y+24)
    end
  end
end

function modify_corner_vert_layout(map)
  local start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(x+1)..","..(y+1)] = mget(start_x+x,y+24)

      map[(7-x)..","..(y+1)] = mget(start_x+x,y+24)

    end
  end
  start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(x+1)..","..(6-y)] = mget(start_x+x,y+24)
      map[(7-x)..","..(6-y)] = mget(start_x+x,y+24)
    end
  end
end

function modify_corner_horz_layout(map)
  local start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(x+1)..","..(y+1)] = mget(start_x+x,y+24)
      map[(x+1)..","..(6-y)] = mget(start_x+x,y+24)
    end
  end
  start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(7-x)..","..(y+1)] = mget(start_x+x,y+24)
      map[(7-x)..","..(6-y)] = mget(start_x+x,y+24)
    end
  end
end

function modify_corner_diag_layout(map)
  local start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(x+1)..","..(y+1)] = mget(start_x+x,y+24)
      map[(7-x)..","..(6-y)] = mget(start_x+x,y+24)
    end
  end
  start_x=flr(rnd()*6)*8
  for x=0,3 do
    for y=0,2 do
      map[(x+1)..","..(6-y)] = mget(start_x+x,y+24)
      map[(7-x)..","..(y+1)] = mget(start_x+x,y+24)
    end
  end
end

function modify_horz_layout(map)
  local start_x=48+flr(rnd()*5)*8
  for x=0,6 do
    for y=0,2 do
      map[(x+1)..","..(y+1)] = mget(start_x+x,y+24)
      map[(x+1)..","..(6-y)] = mget(start_x+x,y+24)
    end
  end
end

function modify_vert_layout(map)
  local start_x=88+flr(rnd()*5)*8
  for x=0,3 do
    for y=0,5 do
      map[(x+1)..","..(y+1)] = mget(start_x+x,y+24)
      map[(7-x)..","..(y+1)] = mget(start_x+x,y+24)
    end
  end
end

function modify_layout(map)
  local v=rnd()
  if v<0.11 then
    modify_horz_layout(map)
  elseif v<0.22 then
    modify_vert_layout(map)
  elseif v<0.34 then
    modify_corner_layout(map)
  elseif v<0.56 then
    modify_corner_horz_layout(map)
  elseif v<0.78 then
    modify_corner_vert_layout(map)
  else
    modify_corner_diag_layout(map)
  end
end

function get_generated_map(lvl)
  local map={}
  for x=1,width-2 do
    for y=1,height-2 do
      map[x..","..y] = 10
    end
  end
  modify_layout(map,lvl)
  add_monsters(map,lvl)
  return map
end

function new_tile(x, y, type)
  local sprite = 16+max(min(4,type),0)*2
  return {
    x=x,
    y=y,
    sprite=sprite,
    entity=nil,
    player_highlight=nil,
    highlight=nil,
    cursed=0,
    frame=0,
    is_solid=function(self)
      return (self.sprite-16)/2 > 2
    end,
    is_hole=function(self)
      return (self.sprite-16)/2==2
    end,
    draw_tile=function(self)
      self.frame += 0.25
      if (self.frame >= 3) self.frame = 0

      spr(self.sprite, self.x*tile_size, self.y*tile_size, 2, 2)
      if self.highlight != nil then
        spr(128+flr(self.frame)*2,self.x*tile_size, self.y*tile_size, 2, 2)
      end
      if self.cursed > 0 then
        spr(32-2*self.cursed,self.x*tile_size, self.y*tile_size, 2, 2)
      end
      if self.player_highlight != nil then
        pal(7,self.player_highlight)
        spr(106+flr(self.frame)*2,self.x*tile_size, self.y*tile_size, 2, 2)
        pal()
      end
    end
  }
end

function new_world()
  return {
    shake_time=0,
    flash_time=0,
    flash_color=8,
    current_turn="start",
    anim_time = 0,
    init=function(self,map)
      self.current_turn="start"
      self.tiles = {}
      self.entrance,self.exit = nil,nil
      local x,y
      for x=1,width do
        self.tiles[x..",".."1"]=new_tile(x,1,3)
        self.tiles[x..","..height]=new_tile(x,height,3)
      end
      for y=1,height do
        self.tiles["1"..","..y]=new_tile(1,y,3)
        self.tiles[width..","..y]=new_tile(width,y,3)
      end
      local middle=flr((width+1)/2)
      self.tiles[middle..",".."1"]=new_tile(middle,1,1)
      self.entrance = self.tiles["5"..",".."1"]
      self.tiles[middle..","..height]=new_tile(middle,height,1)
      self.exit=self.tiles[middle..","..height]
      self.exit.entity = new_door(self.exit)
      self.exit.entity.frame=3
      for x=1,width-2 do
        for y=1,height-2 do
          if (map[x..","..y]<=8 or map[x..","..y]==10) self.tiles[(x+1)..","..(y+1)]=new_tile(x+1,y+1,0)
          if (map[x..","..y]==9) self.tiles[(x+1)..","..(y+1)]=new_tile(x+1,y+1,2)
          if (map[x..","..y]==11) self.tiles[(x+1)..","..(y+1)]=new_tile(x+1,y+1,3)
          if (map[x..","..y]==12) self.tiles[(x+1)..","..(y+1)]=new_tile(x+1,y+1,0) self.tiles[(x+1)..","..(y+1)].cursed=3
        end
      end
      self.player=new_player(self.entrance)

      self.monsters = {}
      for x=1,width-2 do
        for y=1,height-2 do
          if (map[x..","..y] == 2) add(self.monsters,new_archer(self.tiles[(x+1)..","..(y+1)]))
          if (map[x..","..y] == 3) add(self.monsters,new_knight(self.tiles[(x+1)..","..(y+1)]))
          if (map[x..","..y] == 4) add(self.monsters,new_trapper(self.tiles[(x+1)..","..(y+1)]))
          if (map[x..","..y] == 5) add(self.monsters,new_ninja(self.tiles[(x+1)..","..(y+1)]))
          if (map[x..","..y] == 6) add(self.monsters,new_king(self.tiles[(x+1)..","..(y+1)]))
          if (map[x..","..y] == 7) add(self.monsters,new_wizard(self.tiles[(x+1)..","..(y+1)]))
          if (map[x..","..y] == 8) add(self.monsters,new_urn(self.tiles[(x+1)..","..(y+1)]))
        end
      end

      self.particles = {}
    end,
    next_level=function(self)
      if (self.player != nil) health = min(self.player.health+1, 3) enable_dash = self.player.enable_dash
        current += 1
        if (is_anim_time()) check_point=current-1 current_state = "anim" animworld:init()
        if current <= #lvls then
          if lvls[current] > 0 then
            difficulty = 0
            world:init(get_human_map(lvls[current]))
          else
            difficulty += 1
            world:init(get_generated_map(abs(lvls[current])))
          end
        end
    end,
    check_outside=function(self,x,y)
      return x<1 or y<1 or x>width or y>height
    end,
    get_tile=function(self,x,y)
      if (self:check_outside(x,y)) return nil
      return self.tiles[x..","..y]
    end,
    check_movable=function(self,x,y)
      local tile=self:get_tile(x,y)
      if (tile == nil) return false
      return not tile:is_solid() and not tile:is_hole() and tile.entity == nil
    end,
    check_dashable=function(self,x,y)
      local tile=self:get_tile(x,y)
      if (tile == nil) return false
      return not tile:is_solid() and tile.entity == nil
    end,
    get_empty_tiles=function(self)
      local tiles={}
      for x=1,width do
        for y=1,height do
          local t=self:get_tile(x,y)
          if (t != nil and not t:is_solid() and t.entity == nil) add(tiles,t)
        end
      end
      return tiles
    end,
    is_entrance_exit=function(self,tile)
      return tile == self.entrance or tile == self.exit
    end,
    get_random_tiles=function(self,max)
      local tiles={}
      for i=1,max do
        local x,y = flr(rnd()*width)+1,flr(rnd()*height)+1
        local t=self:get_tile(x,y)
        if (self:check_movable(x,y)) add(tiles,t)
      end
      return tiles
    end,
    update=function(self)
      if self.current_turn == "start" then
        if btnp(ƒ) then
          self.player:try_update(0,1)
          self.current_turn = "player"
          self.entrance.entity = new_door(self.entrance)
        elseif (btnp(—) or btnp(Ž)) and self.player.dash > 0 then
          sfx(5)
          self.player.enable_dash=not self.player.enable_dash
        end
      elseif self.current_turn == "player" then
        if(self.player.health > 0) self.player:update()
        if(self.player.tile == self.exit) self.anim_time=4 self.current_turn = "next_level"
      elseif self.current_turn == "attack" then
        local new_add={}
        for m in all(self.monsters) do
          if m.health > 0 then
            local temp = m:attack()
            if temp != nil then
              for m in all(temp) do
                add(new_add,m)
              end
            end
          end
        end
        if #new_add > 0 then
          sfx(4)
        end
        if self.player.invurnable then
          sfx(3)
        else
          sfx(2)
        end
        for m in all(new_add) do
          add(self.monsters, m)
        end
        self.anim_time = 6
        self.current_turn = "attack_anim"
      elseif self.current_turn == "attack_anim" then
        self.anim_time -= 1
        if (self.anim_time <= 0) self.current_turn = "move"
      elseif self.current_turn == "move" then
        for m in all(self.monsters) do
          if m.health > 0 then
            m:update()
          end
        end
        self.anim_time = 0
        self.current_turn = "player"
        self.player:charge()
        self.player.timer = self.player.max_timer
      elseif self.current_turn == "move_anim" then
        self.anim_time -= 1
        if self.anim_time <= 0 then
          self.current_turn = "player"
          self.player:charge()
          self.player.timer = self.player.max_timer
        end
      elseif self.current_turn == "next_level" then
        self.anim_time -= 1
        if self.anim_time <= 0 then
          self:next_level()
          return
        end
      end

      for m in all(self.monsters) do
        if m.health <= 0 then
          spawn_particles(m.tile.x,m.tile.y,55,7)
          self.player:charge(3)
          m.tile.entity = nil
          del(self.monsters,m)
        end
      end

      if (self.exit.entity != nil and self.exit.entity.done) self.exit.entity = nil

      for _,t in pairs(self.tiles) do
        t.player_highlight = nil
        t.highlight = nil
      end

      for m in all(self.monsters) do
        m:highlight_attack()
      end

      if self.current_turn == "player" or self.current_turn == "start" then
        local tiles=self.player:get_move_tile()
        for t in all(tiles) do
          t.player_highlight=self.player.color
        end
      end

      for p in all(self.particles) do
        p:update()
      end

      if (self.player.health <=0) then
        if (btnp(—) or btnp(Ž)) camera(0,0) start_game() current_state="game"
      end
    end,
    shake=function(self,time)
      self.shake_time = time
    end,
    flash=function(self,time,color)
      color=color or 8
      self.flash_color=color
      self.flash_time = time
    end,
    draw_ui=function(self)
      local y=123
      for i=0,self.player.max_health-1 do
        spr(52,12+shift_x+(i)*12,y-11)
      end
      for i=0,self.player.health-1 do
        spr(53,12+shift_x+(i)*12,y-11)
      end
      local color = 7
      if self.player.health/self.player.max_health < 0.5 then
        color = 11
      end
      pal(7,color)
      for i=0,self.player.max_timer-1 do
        spr(48,72+shift_x+(self.player.max_timer-i)*12,y-11)
      end
      pal()
      color = 7
      if self.player.timer/self.player.max_timer < 0.5 then
        color = 11
      end
      pal(7,color)
      for i=0,self.player.timer-1 do
        spr(49,72+shift_x+(self.player.max_timer-i)*12,y-11)
      end
      pal()
      printc("room "..current.."/25",shift_x+64,y+2)
    end,
    draw=function(self)
      self.shake_time = max(self.shake_time-1,0)
      local shake_x,shake_y=0,0
      if (self.shake_time > 0) shake_x,shake_y = 2*rnd()-1, 2*rnd()-1
      camera(shift_x+shake_x,shift_y+shake_y)
      local t
      for _,t in pairs(self.tiles) do
        t:draw_tile()
      end
      if(self.entrance.entity != nil) self.entrance.entity:draw()
      if(self.exit.entity != nil) self.exit.entity:draw()
      for m in all(self.monsters) do
        m:draw()
      end
      if self.player.health > 0 then
        self.player:draw()
      end
      for p in all(self.particles) do
        p:draw()
      end
      self:draw_ui()
      self.flash_time=max(self.flash_time-1,0)
      if(self.flash_time > 0) rectfill(-20,-20,150,150,self.flash_color)
      if self.player.health <=0 then
        rectfill(-20,36,148,83,0)
        spr(224,40,50,6,2)
        printc("press — or Ž to restart",60,70)
      end
    end
  }
end

function new_particle(x,y,idx,c,v,dir)
  return {
    x=x,
    y=y,
    velocity=v,
    color=c,
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
      pal(7,self.color)
      local adj=0
      if(self.velocity < 0.3) adj=1
      spr(self.sprite+adj,self.x-4,self.y-4)
      pal()
    end
  };
end

function spawn_particles(x,y,particle,color)
  x,y=x*tile_size,y*tile_size
  local dir=rnd()*15
  while dir < 360 do
    add(world.particles,new_particle(x+tile_size/2,y+tile_size/2,particle,color,1.5+1.5*rnd(),dir/360))
    dir += rnd()*30+45
  end
end

function new_entity(tile, sprite)
  local entity = {
    tile=tile,
    sprite=sprite,
    offset_x=0,
    offset_y=0,
    attack_x=0,
    attack_y=0,
    health=1,
    color=7,
    take_damage=function(self,value)
      value = value or 1
      self.health = max(self.health - value, 0)
    end,
    move=function(self,tile)
      self.offset_x = -(tile.x-self.tile.x)*tile_size
      self.offset_y = -(tile.y-self.tile.y)*tile_size
      self.tile.entity=nil
      self.tile = tile
      self.tile.entity = self
    end,
    display_x=function(self)
      return self.tile.x * tile_size + 2 + self.offset_x + self.attack_x
    end,
    display_y=function(self)
      return self.tile.y * tile_size + 2 + self.offset_y + self.attack_y
    end,
    update=function(self)
    end,
    draw=function(self)
      if abs(self.offset_x) > 1 then
        self.offset_x = lerp(self.offset_x, 0, 0.5)
      else
        self.offset_x = 0
        if abs(self.attack_x) > 1 then
          self.attack_x = lerp(self.attack_x, 0, 0.5)
        else
          self.attack_x = 0
        end
      end
      if abs(self.offset_y) > 1 then
        self.offset_y = lerp(self.offset_y, 0, 0.5)
      else
        self.offset_y = 0
        if abs(self.attack_y) > 1 then
          self.attack_y = lerp(self.attack_y, 0, 0.5)
        else
          self.attack_y = 0
        end
      end

      palt(0,false)
      palt(1,true)
      pal(7,self.color)
      spr(self.sprite, self:display_x(), self:display_y())
      pal()
      palt()
    end
  }
  entity.tile.entity = entity
  return entity
end

function new_player(tile)
  local player = new_entity(tile,1)
  player.max_health=3
  player.health=health
  player.max_dash=3
  player.dash=player.max_dash
  player.enable_dash=enable_dash
  player.max_timer = 3
  player.timer = player.max_timer
  player.old_tile = nil
  player.invurnable=false

  player.take_damage=function(self,value)
    if(self.invurnable) return
    value = value or 1
    self.health = max(self.health - value, 0)
    self.invurnable=true
    world:shake(6)
    world:flash(2)
  end

  player.get_move_tile = function(self)
    local tiles={}
    if self.enable_dash then
      local t=self:get_jump_tile(-1,0)
      if (t != self.tile) add(tiles,t)
      t=self:get_jump_tile(1,0)
      if (t != self.tile) add(tiles,t)
      t=self:get_jump_tile(0,-1)
      if (t != self.tile) add(tiles,t)
      t=self:get_jump_tile(0,1)
      if (t != self.tile) add(tiles,t)
    else
      local t=world:get_tile(self.tile.x-1,self.tile.y+0)
      if (t!=nil and not t:is_solid() and not t:is_hole()) add(tiles,t)
      t=world:get_tile(self.tile.x+1,self.tile.y+0)
      if (t!=nil and not t:is_solid() and not t:is_hole()) add(tiles,t)
      t=world:get_tile(self.tile.x+0,self.tile.y-1)
      if (t!=nil and not t:is_solid() and not t:is_hole()) add(tiles,t)
      t=world:get_tile(self.tile.x+0,self.tile.y+1)
      if (t!=nil and not t:is_solid() and not t:is_hole()) add(tiles,t)
    end
    return tiles
  end

  player.get_jump_tile = function(self,dir_x,dir_y)
    local nx,ny=self.tile.x,self.tile.y
    local last_tile,current_tile=world:get_tile(nx,ny),world:get_tile(nx,ny)
    while world:check_dashable(nx+dir_x,ny+dir_y) do
      nx,ny=nx+dir_x,ny+dir_y
      current_tile=world:get_tile(nx,ny)
      if world:check_movable(nx,ny) then
        last_tile = current_tile
      end
      if (current_tile.cursed > 0) then
        return current_tile
      end
    end
    return last_tile
  end

  player.try_update = function(self,dir_x,dir_y)
    local nx,ny=self.tile.x,self.tile.y
    if self.enable_dash then
      local t = self:get_jump_tile(dir_x,dir_y)
      nx,ny=t.x,t.y
    else
      if world:check_movable(nx+dir_x,ny+dir_y) then
        nx,ny=nx+dir_x,ny+dir_y
      end
    end
    local tile = world:get_tile(nx,ny)
    local adj_tile = world:get_tile(nx+dir_x,ny+dir_y)
    if tile != nil then
      if tile != self.tile then
        self.timer -= 1
        self.old_tile = self.tile
        self:move(tile)
        if self.enable_dash then
          -- self.enable_dash = false
          -- self.dash -= 1
          if adj_tile != nil and not world:is_entrance_exit(adj_tile) and adj_tile.entity != nil and tile.cursed == 0 then
            sfx(1)
            adj_tile.entity:take_damage()
            self.attack_x = dir_x*tile_size/2
            self.attack_y = dir_y*tile_size/2
          else
            sfx(0)
          end
        else
          sfx(0)
        end
        if tile.cursed > 0 then
          self.timer = 0
          tile.cursed = 0
          return
        end
      elseif adj_tile != nil and not world:is_entrance_exit(adj_tile) and adj_tile.entity != nil and tile.cursed == 0 then
        self.timer -= 1
        sfx(1)
        --self.enable_dash = false
        self.attack_x = dir_x*tile_size/2
        self.attack_y = dir_y*tile_size/2
        adj_tile.entity:take_damage()
      end
    end
  end

  player.update = function(self)
    self.invurnable=false
    -- self.timer -= 3
    self.color=7
    -- if self.timer/self.max_timer < 0.4 then
    --   if (self.timer % 20 < 10) self.color = 8
    -- end

    local no_monster = true
    for m in all(world.monsters) do
      if m.sprite != 8 then
        no_monster = false
        break
      end
    end
    if not no_monster then
      if self.timer <= 0 then
        self.timer = 0
        self.color = 7
        enemy_ticks += 1
        world.current_turn = "attack"
      end
    else
      for _,t in pairs(world.tiles) do
        if(t.cursed > 0) spawn_particles(t.x,t.y,55,7)
        t.cursed = 0
      end
      if self.timer <= 0 then
        self:charge()
        self.timer = self.max_timer
      end
      if (world.exit.entity != nil and world.exit.entity != self) world.exit.entity:open()
    end

    if btnp(ƒ) then
      self:try_update(0,1)
    elseif btnp(”) then
      self:try_update(0,-1)
    elseif btnp(‘) then
      self:try_update(1,0)
    elseif btnp(‹) then
      self:try_update(-1,0)
    elseif (btnp(—) or btnp(Ž)) and self.dash > 0 then
      sfx(5)
      self.enable_dash=not self.enable_dash
    end
  end

  player.heal = function(self,value)
    value = value or 1
    self.health += value
    if (self.health > self.max_health) self.health = self.max_health
  end

  player.charge = function(self, value)
    value = value or 1
    self.dash += value
    if (self.dash > self.max_dash) self.dash = self.max_dash
  end

  player.p_draw = player.draw
  player.draw = function(self)
    if (self.enable_dash) pal(0,11)
    self:p_draw()
  end

  return player
end

function new_monster(tile,sprite,color)
  local monster = new_entity(tile, sprite)
  monster.color=color

  monster.get_attack_tiles=function(self)
  end

  monster.highlight_attack=function(self)
    local tiles = self:get_attack_tiles()
    for t in all(tiles) do
      t.highlight = self.color
    end
  end

  monster.attack=function(self)
    local tiles = self:get_attack_tiles()
    for t in all(tiles) do
      spawn_particles(t.x,t.y,55,self.color)
      if t.entity == world.player then
        t.entity:take_damage()
      end
    end
  end

  return monster
end

function new_knight(tile)
  local knight = new_monster(tile,3,8)

  knight.get_attack_tiles=function(self)
    local tiles={}
    local dirs={{-1,0},{1,0},{0,-1},{0,1},{-1,-1},{1,1},{-1,1},{1,-1}}
    for d in all(dirs) do
      nx,ny=self.tile.x+d[1],self.tile.y+d[2]
      t=world:get_tile(nx,ny)
      if (t!=nil and not t:is_solid()) add(tiles,t)
    end
    return tiles
  end

  knight.update = function(self)
    if (world.player.health <= 0) return

    if (abs(world.player.tile.x-self.tile.x) + abs(world.player.tile.y - self.tile.y) == 1) return

    if world.player.old_tile != nil and world.player.old_tile.entity == nil and (abs(world.player.old_tile.x-self.tile.x) + abs(world.player.old_tile.y - self.tile.y) == 1) then
      self:move(world.player.old_tile)
    else
      local dirs={{0,0},{-1,0},{1,0},{0,-1},{0,1}}
      local tiles={}
      for d in all(dirs) do
        local nx,ny=self.tile.x+d[1],self.tile.y+d[2]
        local t = world:get_tile(nx,ny)
        if (world:check_movable(nx,ny)) add(tiles,t)
      end
      sort(tiles,tile_cmp)
      if (#tiles > 0) self:move(tiles[1])
    end
  end
  return knight
end

function new_archer(tile)
  local archer = new_monster(tile,2,11)

  archer.get_attack_tiles=function(self)
    local tiles={}
    local dirs={{-1,0},{1,0},{0,-1},{0,1}}
    for d in all(dirs) do
      local nx,ny=self.tile.x+d[1],self.tile.y+d[2]
      local t=world:get_tile(nx,ny)
      while t != nil and not t:is_solid() do
        add(tiles,t)
        nx,ny=nx+d[1],ny+d[2]
        t=world:get_tile(nx,ny)
      end
    end
    return tiles
  end

  archer.update = function(self)
    if (world.player.health <= 0) return

    local delta_x,delta_y=sign(world.player.tile.x-self.tile.x),sign(world.player.tile.y-self.tile.y)
    if abs(delta_x) < abs(delta_y) then
      if delta_x == 0 or world:check_movable(self.tile.x+delta_x, self.tile.y) then
        delta_y = 0
      else
        delta_x = 0
      end
    else
      if delta_y == 0 or world:check_movable(self.tile.x, self.tile.y+delta_y) then
        delta_x = 0
      else
        delta_y = 0
      end
    end

    if world:check_movable(self.tile.x+delta_x, self.tile.y+delta_y) then
      self:move(world:get_tile(self.tile.x+delta_x, self.tile.y+delta_y))
    end
  end

  return archer
end

function new_wizard(tile)
  local wizard = new_monster(tile,7,9)

  wizard.update_target=function(self)
    local tiles={}
    for x=-2,2 do
      for y=-2,2 do
        local nx,ny=world.player.tile.x+x,world.player.tile.y+y
        local t=world:get_tile(nx,ny)
        if t != nil and not t:is_solid() then
          add(tiles,t)
        end
      end
    end
    local t=tiles[flr(rnd()*#tiles) + 1]
    self.target_x=t.x
    self.target_y=t.y
  end

  wizard:update_target()

  wizard.get_attack_tiles=function(self)
    local tiles={}
    for x=-1,1 do
      for y=-1,1 do
        local nx,ny=self.target_x+x,self.target_y+y
        local t=world:get_tile(nx,ny)
        if t != nil and not t:is_solid() then
          add(tiles,t)
        end
      end
    end
    return tiles
  end

  wizard.update = function(self)
    if (world.player.health <= 0) return

    -- local tiles = world:get_empty_tiles()
    -- sort(tiles,tile_cmp)
    -- local rand_indx = flr(#tiles - rnd()*#tiles/4)
    -- self:move(tiles[rand_indx])

    local dirs={{-1,0},{1,0},{0,-1},{0,1}}
    local tiles={}
    for d in all(dirs) do
      local nx,ny=self.tile.x+d[1],self.tile.y+d[2]
      local t = world:get_tile(nx,ny)
      if (world:check_movable(nx,ny)) add(tiles,t)
    end
    sort(tiles,tile_cmp)
    if (#tiles > 0) self:move(tiles[#tiles])

    self:update_target()
  end

  return wizard
end

function new_trapper(tile)
  local trapper = new_monster(tile,4,12)

  trapper.get_attack_tiles=function(self)
    local tiles={}
    local t=world:get_tile(self.tile.x,self.tile.y)
    add(tiles,t)
    return tiles
  end

  trapper.attack=function(self)
    local tiles = self:get_attack_tiles()
    local t
    for t in all(tiles) do
      t.cursed = 3
    end
    spawn_particles(self.tile.x,self.tile.y,55,self.color)
  end

  trapper.update = function(self)
    if (world.player.health <= 0) return

    local tiles = world:get_random_tiles(20)
    sort(tiles,trap_cmp)
    local rand_indx = max(flr(#tiles - rnd()*#tiles/4),1)
    if(#tiles>0) self:move(tiles[rand_indx])
  end

  return trapper
end

function new_king(tile)
  local king = new_monster(tile,6,10)

  king.switch=false

  king.get_attack_tiles=function(self)
    local tiles={}
    local dirs={{-1,0},{1,0}}
    if self.switch then
      dirs={{0,-1},{0,1}}
    end
    for d in all(dirs) do
      nx,ny=self.tile.x+d[1],self.tile.y+d[2]
      local t=world:get_tile(nx,ny)
      if (world:check_movable(nx,ny)) add(tiles,t)
    end
    return tiles
  end

  king.attack=function(self)
    local knights={}
    local tiles = self:get_attack_tiles()
    local t
    for t in all(tiles) do
      if t.entity == nil then
        spawn_particles(t.x,t.y,55,self.color)
        add(knights, new_knight(t))
      end
    end
    self.switch = not self.switch
    return knights
  end

  king.update = function(self)

  end

  return king
end

function new_ninja(tile)
  local ninja = new_monster(tile,5,14)

  ninja.dirs={{-1,0},{0,-1},{1,0},{0,1}}
  ninja.index=flr(rnd()*#ninja.dirs)+1

  ninja.get_attack_tiles=function(self)
    local tiles={}
    local dirs={{-1,-1},{1,-1},{-1,1},{1,1}}
    for d in all(dirs) do
      local nx,ny=self.tile.x+d[1],self.tile.y+d[2]
      local t=world:get_tile(nx,ny)
      while t != nil and not t:is_solid() do
        add(tiles,t)
        nx,ny=nx+d[1],ny+d[2]
        t=world:get_tile(nx,ny)
      end
    end
    return tiles
  end

  ninja.change_dir = function(self)
    local i
    for i=1,#self.dirs-1 do
      local index=self.index+i
      if (index > #self.dirs) index -= #self.dirs
      local nx,ny=self.tile.x+self.dirs[index][1],self.tile.y+self.dirs[index][2]
      if world:check_movable(nx,ny) then
        self.index=index
        break
      end
    end
  end

  ninja.update = function(self)
    if (world.player.health <= 0) return
    local nx,ny=self.tile.x+self.dirs[self.index][1],self.tile.y+self.dirs[self.index][2]
    if world:check_movable(nx,ny) then
      self:move(world:get_tile(nx,ny))
    else
      self:change_dir()
      nx,ny=self.tile.x+self.dirs[self.index][1],self.tile.y+self.dirs[self.index][2]
      if (world:check_movable(nx,ny)) self:move(world:get_tile(nx,ny))
    end
  end

  return ninja
end

function new_urn(tile)
  local urn = new_monster(tile,8,4)

  urn.get_attack_tiles=function(self)
    return {}
  end

  return urn
end

function new_door(tile)
  return {
    tile=tile,
    frame=0,
    current_status="close",
    done=false,
    open=function(self)
      self.current_status="open"
    end,
    close=function(self)
      self.current_status="close"
    end,
    draw=function(self)
      palt(1,true)
      palt(0,false)
      spr(64+flr(self.frame)*2,self.tile.x*tile_size,self.tile.y*tile_size,2,2)
      palt()
      if self.current_status == "close" then
        self.frame += 0.25
        if (self.frame > 3) self.frame = 3
      elseif self.current_status == "open" then
        self.frame -= 0.25
        if (self.frame < 0) then
          self.frame = 0
          self.done = true
        end
      end
    end
  }
end

function new_anim_dialog(x,y,text,color)
  color=color or 7
  return {
    x=x,
    y=y,
    index=0,
    text=text,
    color=color,
    the_end=false,
    is_done=function(self)
      return self.index >= #self.text
    end,
    skip=function(self)
      self.index=#self.text
    end,
    update=function(self)
      -- self.index = min(self.index+1,#self.text)
      if self.index < #self.text then
        self.index += 1
        sfx(0)
      end
    end,
    draw=function(self)
      local lines={}
      local old_index=0
      local old_line=""
      local render_text=""
      local i=1
      while i<=flr(self.index) do
        if sub(self.text,i,i) == " " then
          old_index=i
          old_line=render_text
        end
        render_text=render_text..""..sub(self.text,i,i)
        if #render_text*4 > 124 then
          render_text = ""
          add(lines,old_line)
          i=old_index
        end
        i+=1
      end
      add(lines,render_text)
      for i=0,#lines-1 do
        render_text=lines[i+1]
        print(render_text,self.x,self.y+i*8,self.color)
      end
    end
  }
end

function is_anim_time()
  return current == 1 or current == 7 or current == 10 or current == 14 or current == 18 or current == 22 or current == 26
end

function new_anim_sprite(x,y,sprite,color,size_x,size_y)
  size_x,size_y,color=size_x or 1,size_y or 1,color or 7
  return {
    x=x,
    y=y,
    sprite=sprite,
    color=color,
    size_x=size_x,
    size_y=size_y,
    update=function(self)
    end,
    draw=function(self)
      pal(7,self.color)
      spr(self.sprite,self.x-self.size_x*tile_size/2,self.y-self.size_y*tile_size/2,self.size_x,self.size_y)
      pal()
    end
  }
end

function new_animworld()
  return {
    sprites=nil,
    dialog=nil,
    index=0,
    frame=0,
    init=function(self)
      self.index=1
      self.sprites={}
      self.dialog={}
      if current==1 then
        add(self.sprites,{new_anim_sprite(70,45,161,13,2,2)})
        add(self.dialog,new_anim_dialog(2,80,"this is the real story. unlike the story of terry that assume necromancers are real and summoning skeletons."))
        add(self.sprites,{new_anim_sprite(70,45,194,15,2,2)})
        add(self.dialog,new_anim_dialog(2,80,"the church loved the idea of having the supreme rule over all the subjects with no objections."))
        add(self.sprites,{new_anim_sprite(45,45,163,15,2,2),
                          new_anim_sprite(80,30,136,7,1,1),
                          new_anim_sprite(72,50,136,15,1,1),
                          new_anim_sprite(88,50,136,6,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"they hated that some humans called themselves scientist can have more knowledge than themselves and forbide science."))
        add(self.sprites,{new_anim_sprite(40,42,136,7,1,1),
                          new_anim_sprite(80,40,153,11,1,1),
                          new_anim_sprite(72,45,153,11,1,1),
                          new_anim_sprite(88,45,153,11,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"one day, a young scientist named berry, discovered a new potion that can make him faster than any human."))
        add(self.sprites,{new_anim_sprite(70,44,167,11,2,2),
                          new_anim_sprite(68,44,136,7,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"he drank the potion, now he feels that which allow him to move fast and perform multiple moves in fraction of a step."))
        add(self.sprites,{new_anim_sprite(64,20,163,15,2,2),
                          new_anim_sprite(48,48,206,11,1,4),
                          new_anim_sprite(76,48,207,11,1,4),
                          new_anim_sprite(62,64,140,7,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"berry decided that it is time to stand against the church so more children can start studying science."))
      elseif current==7 then
        add(self.sprites,{new_anim_sprite(45,45,163,15,2,2),
                          new_anim_sprite(85,30,141,11,1,1),
                          new_anim_sprite(75,50,141,11,1,1),
                          new_anim_sprite(95,50,141,11,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"the church didn't expect young berry to reach that far so they decided to send the archers to end him once and for all."))
      elseif current==10 then
        add(self.sprites,{new_anim_sprite(45,45,163,15,2,2),
                          new_anim_sprite(85,30,169,12,2,2),
                          new_anim_sprite(75,50,169,12,2,2),
                          new_anim_sprite(95,50,169,12,2,2)})
        add(self.dialog,new_anim_dialog(2,80,"the church needed a way to interrupt berry fractional moves so they decided to trap the floor."))
        add(self.sprites,{new_anim_sprite(45,45,163,15,2,2),
                          new_anim_sprite(85,30,142,12,1,1),
                          new_anim_sprite(75,50,142,12,1,1),
                          new_anim_sprite(95,50,142,12,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"the church thought it is an easy task so they will send the interns to do that job."))
      elseif current==14 then
        add(self.sprites,{new_anim_sprite(64,50,171,15,2,2)})
        add(self.dialog,new_anim_dialog(2,80,"berry is getting closer which made the church afraid and need any fast solution."))
        add(self.sprites,{new_anim_sprite(45,45,163,15,2,2),
                          new_anim_sprite(85,30,143,9,1,1),
                          new_anim_sprite(75,50,143,9,1,1),
                          new_anim_sprite(95,50,143,9,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"the church decided to free all the wizards and witches if they can help defeat berry."))
      elseif current==18 then
        add(self.sprites,{new_anim_sprite(45,45,192,15,2,2),
                          new_anim_sprite(85,30,157,15,1,1),
                          new_anim_sprite(75,50,157,15,1,1),
                          new_anim_sprite(95,50,157,15,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"the church didn't know who else to summon to arms."))
          add(self.sprites,{new_anim_sprite(45,45,194,15,2,2),
                            new_anim_sprite(85,30,158,14,1,1),
                            new_anim_sprite(75,50,158,14,1,1),
                            new_anim_sprite(95,50,158,14,1,1)})
          add(self.dialog,new_anim_dialog(2,80,"mysterious pink mercenaries appeared out of no where to help the church which made the church confident again."))
      elseif current==22 then
        add(self.sprites,{new_anim_sprite(45,45,173,15,2,2),
                          new_anim_sprite(85,30,159,10,1,1),
                          new_anim_sprite(75,50,159,10,1,1),
                          new_anim_sprite(95,50,159,10,1,1)})
        add(self.dialog,new_anim_dialog(2,80,"the church called all the kings to join in arms because if the church fall, they will fall too."))
      elseif current==26 then
        add(self.sprites,{new_anim_sprite(45,45,140,7,1,1),
                          new_anim_sprite(83,45,171,15,2,2)})
        add(self.dialog,new_anim_dialog(2,80,"berry approached the church but instead of destroying it, he pulled a picture."))
        add(self.sprites,{new_anim_sprite(64,45,196,7,2,2)})
        add(self.dialog,new_anim_dialog(2,80,"the church looked at the picture of group of children that aspire to be scientists."))
        add(self.sprites,{new_anim_sprite(45,45,136,7,1,1),
                          new_anim_sprite(83,45,198,15,2,2)})
          add(self.dialog,new_anim_dialog(2,80,"the church felt ashamed of its actions and promissed berry that they will think before they act next time."))
      end
    end,
    update=function(self)
      self.dialog[self.index]:update()
      for s in all(self.sprites[self.index]) do
        s:update()
      end

      if btnp(—) or btnp(Ž) then
        if not self.dialog[self.index]:is_done() then
          self.dialog[self.index]:skip()
        else
          self.index += 1
          if self.index > #self.sprites then
            if current == 26 then
              self.the_end=true
              self.index -= 1
            else
              current_state = "game"
            end
          end
        end
      end
    end,
    draw=function(self)
      camera(0,0)
      if self.the_end then
        spr(200,42,42,5,2)
        printc("enemy ticks: "..enemy_ticks,64,76)
        return
      end
      self.dialog[self.index]:draw()
      for s in all(self.sprites[self.index]) do
        s:draw()
      end

      self.frame += 1
      local color=7
      if (self.frame % 10 < 5) color=5
      printc("press — or Ž to continue",60,118,color)
    end
  }
end

__gfx__
000000001177771111117771177777711777777117777771711771171117711117777771555555555555555506666660cccccccc000000000000000000000000
000000001777777111777717777777777007700710000001777777771177771111777711500000055000000560666606c00000cc000000000000000000000000
007007001770077117777711777777777077770717777771777777777777777717777771500000055055550566000066c0555c0c000000000000000000000000
000770007007700711777711700770077007700717077071177777711770077170700707500000055055550566066066c055c50c000000000000000000000000
000770007007700717077071700000071777777117777771700770077007700777077077500000055055550566066066c05c550c000000000000000000000000
007007001770077111777711777007771707707110000001177777717007700770700707500000055055550566000066c0c5550c000000000000000000000000
000000001777777111777711777007771777777117777771177777711770077117777771500000055000000560666606cc00000c000000000000000000000000
000000001177771111177111177117711177771111777711117777111177771111777711555555555555555506666660cccccccc000000000000000000000000
55555555555500005555555555550000555555555555000006666666666000000666666666600000000000000000000000000000000000000000000000000000
500000000005000050000000000500005000000000050000606666666606000060666666660600000cccccccccc000000cccccccccc000000cccccccccc00000
505555555505000050555555550500005000000000050000660000000066000066000000006600000c00c0000cc000000c0000000cc000000c0000000cc00000
505555555505000050555555550500005000000000050000660666666066000066066666606600000c0ccc00c0c000000c000c00c0c000000c000000c0c00000
505555555505000050500000050500005000000000050000660666666066000066060000606600000ccccc0c00c000000c00cc0c00c000000c000c0c00c00000
505555555505000050500000050500005000000000050000660666666066000066060000606600000c0cccc000c000000c0cccc000c000000c00ccc000c00000
505555555505000050550000550500005000000000050000660666666066000066066006606600000c000cccc0c000000c000cccc0c000000c000ccc00c00000
505555555505000050555005550500005000000000050000660666666066000066066006606600000c00c0ccccc000000c00c0cc00c000000c00c0c000c00000
505555555505000050555555550500005000000000050000660666666066000066066666606600000c0c00ccc0c000000c0c00c000c000000c0c000000c00000
505555555505000050555555550500005000000000050000660000000066000066000000006600000cc0000c00c000000cc0000000c000000cc0000000c00000
500000000005000050000000000500005000000000050000606666666606000060666666660600000cccccccccc000000cccccccccc000000cccccccccc00000
55555555555500005555555555550000555555555555000006666666666000000666666666600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
00550550007707700055550000777700005005000070070077700000000000000000000000000000000000000000000000000000000000000000000000000000
00550000007700000550555007707770055555500777777007000000000770000000000000800800000000000000000000000000000000000000000000000000
05555050077770700550555007707770055555500777777000000000007777000007700008800880000000000000000000000000000000000000000000000000
00550000007700000555005007770070055555500777777000000000007777000007700000000000000000000000000000000000000000000000000000000000
05555050077770700555555007777770005555000077770000000000000770000000000000000000000000000000000000000000000000000000000000000000
05000000070000000055550000777700000550000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111116666666611111106666666666011111111111771111111111111700711111111111117711111111111111771111111
11111111111111111111111111111111111111111111111160666666660611111111117007111111111117000071111111111170071111111111117007111111
11111111111111111111111111111111611111111116111166000000006611111111170000711111111177700777111111111700007111111111170000711111
11111111111111111116666661111111611666666116111166066666606611111111777007771111111777700777711111117770077711111111777007771111
11111111111111111116000061111111611600006116111166060000606611111117777007777111111777777777711111177770077771111117777007777111
11111111111111111116000061111111611600006116111166060000606611111117777777777111111777777777711111177777777771111117777777777111
11111111111111111116600661111111611660066116111166066006606611111117777777777111111700000000711111177777777771111117777777777111
11111111111111111111600611111111611660066116111166066006606611111117000000007111111077777777011111170000000071111117000000007111
11111111111111111111666611111111611666666116111166066666606611111110777777770111111770777707711111107777777701111110777777770111
11111111111111111111111111111111611111111116111166000000006611111117707777077111111770077007711111177077770771111117700770077111
11111111111111111111111111111111111111111111111160666666660611111117700770077111111770077007711111177007700771111117700770077111
11111111111111111111111111111111116666666611111106666666666011111117700770077111111777777777711111177007700771111117700770077111
11111111111111111111111111111111111111111111111111111111111111111117777777777111111770777707711111177777777771111117777777777111
11111111111111111111111111111111111111111111111111111111111111111111707777071111111177000077111111117700007711111111700000071111
11111111111111111111111111111111111111111111111111111111111111111111770000771111111177000077111111117077770711111111777777771111
11111111111111111111111111111111111111111111111111111111111111111111177777711111111117777771111111111777777111111111177777711111
70007000700000000700070007000000007000700070000000070007000700001111111111111111000000000000000000000000000000000000000000000000
00000000000700000000000000000000000000000000000070000000000000001115555555555111000000000000000000000000000000000000000000000000
00000000000000000000000000070000700000000000000000000000000000001115555555555111000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000000007000000000000000000001115555555555111000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000700001110555555550111000070070000000000000700000000000000007000000000
00000000000700000000000000000000000000000000000070000000000000001110555555550111000007700000000000000777000000000000777000000000
00000000000000000000000000070000700000000000000000000000000000001111055555501111000007700000000000007770000000000000077700000000
00000000000000007000000000000000000000000007000000000000000000001111105555011111000070070000000000000070000000000000070000000000
70000000000000000000000000000000000000000000000000000000000700001111105555011111000000000000000000000000000000000000000000000000
00000000000700000000000000000000000000000000000070000000000000001111055555501111000000000000000000000000000000000000000000000000
00000000000000000000000000070000700000000000000000000000000000001110555555550111000000000000000000000000000000000000000000000000
07000700070000007000700070000000000700070007000000700070007000001110555555550111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001115555555555111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001115555555555111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001115555555555111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077770007770770000700077000700000777700000077700777777000077000
00000000000000000000000000000000000000000000000000000000000000000777777070777077007000777700070007777770007777077007700700777700
002222222200000000222222220000000022222222000000002222222200000007700770770770770700070770700070077bb770077777007077770777777777
0020000002000000002000000200000000200000020000000020000002000000700770077007700770007007700700077bb77bb7007777007007700707700770
0020000002000000002000000200000000200000020000000020000002000000700770077770077700070007700070007bb77bb7070770700777777070077007
002000000200000000200000020000000020000002000000002000000200000007700770777070070070007777000700077bb770007777000707707070077007
00200000020000000020000002000000002000000200000000200000020000000777777007077770070007077070007007777770007777000777777007700770
00200000020000000020000002000000002000000200000000200000020000000077770007077070700070077007000700777700000770000077770000777700
00200000020000000020000002000000002000000200000000200000020000000077770077000077000000000000000000000000007777700777777070077007
00222222220000000022222222000000002222222200000000222222220000000777777007077070000000000000000077777000007777700000000077777777
00000000000000000000000000000000000000000000000000000000000000000770077007077070000000000000000070707000000007700777777077777777
00000000000000000000000000000000000000000000000000000000000000007007700707077070000000000000000077777000000777700707707007777770
00000000000000000000000000000000000000000000000000000000000000007007700707077070000000000000000000700000000777700777777070077007
00000000000000000000000000000000000000000000000000000000000000000770077007077070000000000000000000000000000770000000000007777770
00000000000000000000000000000000000000000000000000000000000000000777777007000070000000000000000000000000000000000777777007777770
00000000000000000000000000000000000000000000000000000000000000000077770000777700000000000000000000000000000770000077770000777700
00000000000000000000000000000007700000000000000000000000000000077000000000000000000000000000000770000000000000077000000000000000
00777700000007777770000000000070070000000000077777700000007000777700070000000000000000000000007007000000000000700700000000000000
07000070000077777777000000000700007000000000777777770000077707777770777000000000000000000000070000700000000007000070000000000000
700770070007777777777000000077700777000000077777777770000777707777077770000cccccccccc0000000777007770000000077700777000000000000
700707070077777777777700000777700777700000777777777777000777770770777770000c00c0000cc0000007777007777000000777700777700000000000
770707070077077777777700000777777777700000770777777777007077777777777707000c0ccc00c0c0000007777777777000000777777777700000000000
777777070077000777777700000777777777700000770007777777007707770770777077000ccccc0c00c0000007777777777000000777777777700000000000
777777070077070000077700000700000000700000770700000777007777777007777777000c0cccc000c0000007000000007000000700000000700000000000
777777070077077777007700000077777777000000770777770077007777777777777777000c000cccc0c0000000777777770000000077777777000000000000
777777070077070770707700000770777707700000770707707077000770777777770770000c00c0ccccc0000007700770077000000770077007700000000000
777777070707000770007070000770077007700007070770077070707077077777707707000c0c00ccc0c0000007700770077000000770077007700000000000
777777777007077007707007000770077007700070070770077070077777777777777777000cc0000c00c0000007700770077000000777777777700000000000
777777000700070770700070000777777777700007000707707000707777777777777777000cccccccccc0000007777777777000000777000077700000000000
07777700007007777770070000007700007700000070077777700700777777777777777700000000000000000000707070770000000077000077000000000000
00777000000000000000000000007077770700000000000000000000077777777777777000000000000000000000770707070000000077000077000000000000
00000000000000000000000000000777777000000000000000000000007777777777770000000000000000000000077777700000000007777770000000000000
00000007700000000000000770000000777777777777777700000007700000000000000000000000000000000000000000000000000000000007000770007000
00000070070000000000007007000000700000000000000700000070070000000000000000000000000000000000000000000000000000000070007777000700
00000700007000000000070000700000700000000000000700000700007000000007777777707077777000007700077777777700000000000700070770700070
00007770077700000000777007770000707777700000000700007770077700000770007000007070000000000070700000700070000000007000700770070007
00077770077770000007777007777000707070700000000700077770077770007000007007007077770000777700707070700007000000000007000770007000
00077777777770000007777777777000707070700fffff0700077777777770007077007007007070000000700000077070700007000000000070007777000700
00077777777770000007777777777000707777700f0f0f0700077777777770007007007007777077770000700000000070700007000000000700070770700070
00070000000070000007000000007000707777700fffff0700070000000070000770007007007000007000777700770070700007000000007000700770070007
000077777777000000007777777700007000000000fff00700007777777700000000007000007007700700700000707070700007000000000007000770007000
00077007700770000007707777077000700000666600000700077707707770000000007007007070700700777700700770700007000000000070007777000700
00077007700770000007700770077000700006066060000700077707707770000000000700707070007000000700700000700007000000000700070770700070
00077777777770000007700770077000700000600600000700077007700770000000000077007007770000070070700777777770000000007000700770070007
00077777777770000007777777777000700000666600000700077777777770000000000000000000000000070070007000000000000000000007000770007000
00007000000700000000707777070000700000000000000700007700007700000000000000000000000000007700007000000000000000000070007777000700
00007777777700000000770000770000777777777777777700007077770700000000000000000000000000000000000770000000000000000700070770700070
00000777777000000000077777700000777777777777777700000777777000000000000000000000000000000000000000000000000000007000700770070007
00000000000000070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000770007000
00077777777700707007070777007700007777777777000000000000000000000000000077777770077777777777777770077777007700770070007777000700
00770000000070700770070700070070070007000000700000000000000000000000000077777777007777777777777777077777707700770700070770700070
00700000000070700770070700700707070007000070700000000000000000000000000000770077700000000000770077077007707700777000700770070007
00700000007070700770070077777007070707000700700000000000000000000000000000770007700777777700770077077007707700770007000770007000
00700777707700700770070000700007007707770077000000000000000000000000000000770007707777777770777777077777707700770070007777000700
00700700700000070770700000700007000007770000000000000000000000000000000000770077707700000000777770077777007777770700070770700070
00700000708888070770708880700007080807000088800000000000000000000000000000777777007777777770777700077770000777777000700770070007
00700000708008070770708000700007080807000080800000000000000000000000000000777777007777777770777770077777000000770007000770007000
00770000708888070770708800070070080807000088000000000000000000000000000000770077707700000000770777077077700000770070007777000700
00077777708008070770708880007700008007777080800000000000000000000000000000770007707777777770770077077007700000770700070770700070
00000000000000000000000000000000000000000000000000000000000000000000000000770007700777777700770077077007700000777000700770070007
00000000000000000000000000000000000000000000000000000000000000000000000000770077700000000000000000000000000007770007000770007000
00000000000000000000000000000000000000000000000000000000000000000000000077777777007777777777777777777777777777770070007777000700
00000000000000000000000000000000000000000000000000000000000000000000000077777770077777777777777777777777777777700700070770700070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000700770070007
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0a090a0a0a0902000a0a0a0a010a0a000a0a0a0a0a0a0a0009090a0a0a0909000a0a0a0a0a0a0a000a0a0a0a0a0a0a000a0a0a0a0a0a0a0009090a0a0a0909000b0a0a0a0a0a0b000a0a0a0a0a0a0a0009090a0a0a090900090a0a0a0a0a09000a0a090c090a0a00000000000000000000000000000000000000000000000000
0a090a0a0a090a000a0a0b0b0b0a0a000a0a0b0b0b0a0a0009090a0a0a0909000a0b0b0b0b0b0a000a0a0a0a0a0a0a000a09090909090a0009090a0a0a0909000b0a0b0b0b0a0b000a080b0b0b080a0009090a0a0a090900090a0a0a0a0a09000a0a090a090a0a00000000000000000000000000000000000000000000000000
0a090a0b0a090a000a0a0a030a0a0a000a0b050a0a0b0a0009090c0c0c0909000a0a090909040a000a0b0808080b0a00090b0808080b090009090a0b0a090900090909090909090009090909090909000b0b0a0a0a0b0b0009090909090909000a0a080a080a0a00000000000000000000000000000000000000000000000000
0a090a0b0a090a000a0b0b0a0b0b0a000a0b0a0a050b0a0009090a0a0a0909000a040909090a0a000a0a0a0a0a0a0a00090a0a070a0a090009090a0b0a090900090909090909090009090909090909000b0b0a0a0a0b0b0009090909090909000a0a080a080a0a00000000000000000000000000000000000000000000000000
0a090a0a0a090a000a030b0a0b030a000a0a0b090b0a0a000909030a030909000a0b0b0b0b0b0a000a060a0a0a060a000a080a0a0a080a0009090a0a0a0909000b0a0b0b0b0a0b00080a0b0b0b0a080009090a0a0a090900090a030a030a09000a0a090a090a0a00000000000000000000000000000000000000000000000000
02090a0a0a090a000a0a0a0a0a0a0a000a0a0a0a0a0a0a0009090a030a0909000a0a0a0a0a0a0a000a0a0b0a0b0a0a000a090a080a090a0009090a0a0a0909000b0a0a0a0a0a0b000a0a0a0a0a0a0a0009090a030a090900090a0a0a0a0a09000a0a090a090a0a00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030300000000020203030300000004040202030000000707070202000000050502020200000006060202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303000000020202030300000004040202020300000707020203030000050502020707000006020207070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030000020203030303000004040202020200000707020202040000050504040202000006060607070200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030000020202030303000004040402020300000707020202020000050505070202000006060505020707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030000020203030303030004040202020303000707020203030300050507070303030006060704040202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030000020202030303030004040202020203000707070404020200050505020204040006060202050507070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030000020202020303030004040402020303000707020202040400050502020203030006060505040202070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030000020202020303030004040202030303000707070202030300050502020707070006060602020507070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03090a0a00000000010b0a0a00000000030c0a0a00000000030a030a0000000001010b0a000000000b030a0a00000000030a0a0a0a0a03000b030a0a0a030b00030a0a0a0a0a03000b030a0a0a030b00030a030a030a03000a0a0a0a000000000a030a0a0000000001080a0a00000000010b0a0a00000000030a0a0a00000000
01090a0300000000010b03030000000001090a03000000000a0b0b08000000000a03010300000000010c0908000000000a03080108030a00010b0303030b01000909080308090900010a0c030c0a01000a08090a09080a000a03090300000000030b0b09000000000a090a0b000000000a080a0a000000000a0b0a0300000000
0108030b0000000001080a03000000000109030b00000000030a0103000000000809090300000000030a01030000000001080903090801000a010a0c0a010a000b010a030a010b000b01030903010b000109010301090100090b010a000000000a010a030000000001090c03000000000a09030300000000030c0a0900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090b0103000000000a0a03030000000001090c03000000000109010b00000000010c0a0900000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a090a000000000109090b000000000a090a0b000000000a080a01000000000a0b0a0100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010a010a000000000a01010a0000000001080a0a000000000a0b0a0a00000000010b0a0100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000191300f130071300113000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003363025630166300c63005630006300060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000036620356203462033620306202d620266201d6201a6201662014620116200f6200c6100a6100861006610046100261001606006060060600606006060060600606006060060600606006060060601606
00030000366203562034620316202f6202c62023620166200f6201f01019010130100e01009010050100301002010010100101000100001000060000600006000060000600006000060000600006000060000600
000200000112002120061200a1200f1201612022120211201c1201412009120041200012000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000a1200e120141201e1202510001100061000210000100001000110024100301002f1003710005100001000e1000010000100001000010000100001000010000100001000010000100001000010000100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
