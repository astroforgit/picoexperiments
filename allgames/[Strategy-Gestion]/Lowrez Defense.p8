pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- lowrez defense
-- by wombart

local mode,game_objects,part,shkx, shky,whiteframe,spawner,camera_offset,
do_once ,left_click_once_timer, modx, mody, button_line, enemies, allies =  'start',{},{},
 0 ,0, false,nil,0, false,0,0,0,0,{},{}

local main_camera,mouse,turret,enemy_tower


function _init()
 poke(0x5f2c,3)
 poke(0x5f2d, 1)

 -- start_game()

end

function _update()

 if mode == 'start' then
  update_start()
 elseif mode=='game' then
  update_game()
 elseif mode=='gameover' then
  update_gameover()
 elseif mode=='victory' then
  update_victory()
 end

end


function _draw()
 if mode == 'start' then
  draw_start()
 elseif mode=='game' then
  draw_game()
 elseif mode=='gameover' then
  draw_gameover()
 elseif mode=='victory' then
  draw_victory()
 end


end

function init_decors()
 -- layer2
 for i=-1 , 17 do
  add_decors_sspr(0, 64, 31, 95-64, -12+(i*18+rnd(3)), -rnd(4)+3, 32, 32, 2)
 end
 
 -- layer0
 for i=-1 , 16 do
  add_decors(flr(rnd(6))+70, -12+(i*18+rnd(3)), 29+rnd(1), 1)
 end


end
-- ##init
function init_all_gameobject()
 
 init_decors()

-- buttons.
-- line 0
 make_button(-30, 23, 3, {86}, 15,'button_unit1', 0)
 make_button(-20, 23, 5,{87}, 20,'button_unit2', 0)
 make_button(-9, 23, 12,{88}, 35,'button_unit3', 0)
 make_button(2, 23, 16,{89}, 50,'button_unit4', 0)
 make_button(13, 23, 20,{90}, 70,'button_unit5', 0)
-- line 1
 make_button(-30, 23, 3, {91}, 100,'button_unit6', 1)
 make_button(-10, 23, 3, {92}, 150,'button_unit7', 1)
 make_button(10, 23, 3,{93}, 175,'button_unit8', 1)
 make_button(-30, 23, 3, {94, 78}, 50,'button_manaregen', 2)
 make_button(-13, 23, 3,{95, 79}, 50,'button_manamax', 2)
 make_button(5, 23, 3, {85, 69}, 100,'button_lesscooldown', 2)
 make_button(20, -30, 60, {77}, 0,'button_meteor', 666)
 -- make_button(10, 23, 3, 93, 100,'button_manamax', 1)
 -- make_button(-20, 23, 5,87, 20,'button_unit2', 1)
 -- make_button(-9, 23, 12,88, 35,'button_unit3', 1)
 -- make_button(2, 23, 16,89, 50,'button_unit4', 1)
 -- make_button(13, 23, 20,90, 70,'button_unit5', 1)
 make_change_button_line(23, 15, 115, -1)
 make_change_button_line(23, 22, 116, 1)

 make_gameobject(32, 32, 'camera', {newposition = {x=0, y=0}})
 make_gameobject(0, 32, 'mouse', {newposition = {x=0, y=0}})
 make_tower(270, 8, 'enemy_tower', 250, {x0=96, y0=0, x1=112-96, y1=32-0})
 make_turret(2, 8, 'ally_turret', {{x0=0, y0=0, x1=16, y1=32}, {x0=0, y0=32, x1=16, y1=32}})

 spawner = make_gameobject(0, 0, 'spawner', {
  timer=0,
  time_between_spawn=10,
  alivee=0
  })

end

function make_change_button_line(x, y, n, value)
 return make_gameobject(x, y, 'button_change_line',{
  sprite=n,
  -- used to fix bug
  max_cooldown=0,
  current_cooldown=0,
  value=value,
  is_mouse_over=function(self)
   if mouse.x >= main_camera.x+self.x and mouse.x < main_camera.x+self.x+8
    and mouse.y >= main_camera.y+self.y and
    mouse.y < main_camera.y+self.y+7 then
    return true
   else return false end
  end,
  update=function(self)
   if self:is_mouse_over() and is_mouse_left_click_once() then
    sfx(18)
    if self.value == -1 and button_line > 0 then button_line -= 1 sfx(3)
    elseif self.value == 1 and button_line <= 1 then button_line += 1 sfx(3)end
   end
  end,
  draw=function(self)
   if self:is_mouse_over() then pal(11, 10) pal(3, 9) end
   if button_line == 0 and self.value == -1 then pal(11, 6) pal(3, 5) 
   elseif button_line == 2 and self.value == 1 then pal(11, 6) pal(3, 5) end
   spr(self.sprite, main_camera.x+self.x,main_camera.y+self.y)
   pal()
   -- circfill(self.x,self.y,5,7)
  end

  })
end

function whiteframe_update()
 if whiteframe == true then
  rectfill(-100,-100, 200, 200, 7)
  whiteframe = false
 end
end

function start_game()
 sfx(0)
 music(0, 0, 3)
 init_all_gameobject()
 turret = search_gameobject('ally_turret')
 main_camera = search_gameobject('camera')
 mouse = search_gameobject('mouse')
 enemy_tower = search_gameobject('enemy_tower')
 mode = 'game'
end

function draw_map()
 -- for i=0, 64 do
 --  local x, y= rnd(64, 64), rnd(64, 64)
 --  rectfill(x,y, x+4,y+4, flr(rnd(2)))
 -- end
 -- rectfill(-20+shkx, -20+shky, 84+shkx, 12+shky, 5)
 -- rectfill(-20+shkx, 34+shky, 84+hkx, 42+shky, 7)
 -- rectfill(-20+shkx, 42+shky, 84+shkx, 84+shky, 1)
 -- for i=0, rnd(4) do
 -- end
 map(0, 0, -86+shkx, 0+shky, 60, 8)
 -- for i=0, 5 do
 --  sspr(0, 32, 31, 31, rnd(64), 3)
 -- end
end
function draw_start()
 cls(12)
 -- sspr(0, 64, 96, 55, 15, 2*cos(time()/4))
 -- main_camera = search_gameobject('camera')
 --  init_all_gameobject()
 rectfill(0, 28, 128, 32, 4)
  pal(13, 6) pal(14, 8)
 if time()*4%1 > 0.5 then
  sspr(32, 64, 16, 16, 20, 15, 16, 16, true)
 else
  sspr(48, 64, 16, 16, 20, 15, 16, 16, true)
 end
 pal()
 -- draw_map()
 spe_print("lowrez defense", 5, 5+cos(time())*2, 12, 1)
 spe_print("by wombart", 2, 56, 9, 4, true)
 -- draw_all_gameobjects()
  -- draw_part()
 if time()*1%2 > 0.5 then spe_print('press —', 14, 40, 11, 3) end

 -- draw_mouse_cursor()
end



function draw_game()
 cls()
 draw_map()
 -- outline_sspr(0, 0, 16, 16, 0, 18) sspr(0, 0, 16, 16, 0, 18) 
 -- if time()*4%2 >= 1 then outline_sspr(16, 0, 16, 16, x, 18) sspr(16, 0, 16, 16, x, 18) 
 --  else outline_sspr(32, 0, 16, 16, x, 18) sspr(32, 0, 16, 16, x, 18)  end
  draw_part()
 

 draw_all_gameobject()
 
 for obj in all(game_objects) do
  if obj:is_active() and (obj:get_tag()=='enemy_tower' or
   obj:get_tag() == 'ally_turret') then obj:draw()
  end
 end

 for obj in all(game_objects) do
  if obj:is_active() and (sub(obj:get_tag(), 1, 6)) == 'button' then
   obj:draw() 
  end
 end

 draw_camera_button()

 whiteframe_update()

 draw_mouse_cursor()
 -- print(#part, 20, 20, 8)

-- print(stat(7)..'/'..#allies+#enemies, mouse.x, mouse.y-8, 0)

end
function update_game()
 update_part()
 do_camera_shake()
 random_enemy_spawning()
 update_all_gameobject()
 camera_follow()

 is_mouse_left_click_once()
 -- modx=shkx+main_camera.x
 -- mody=shky+main_camera.y

-- if btnp(0) then main_camera.x -= 1 turret.mana_max = 10000 end
-- if btn(1) then main_camera.x += 1 end
-- if btnp(5) then mana_part(120, 30,  main_camera.x-24, main_camera.y-30, 1,{12}) end
end

function update_gameover()
 if btn(5) then run() end
 -- if game_over == false then sfx(15) end
 -- game_over = true
 mode='gameover'
 -- camera_update()
end

function draw_gameover()
 cls(12)
 draw_map()
 -- camx, camy = 64, 64
 -- local modx, mody= camx + shkx, camy+shky
 -- camx, camy = player.x, player.y
 if do_once == false then 
  do_once=true
  sfx(19)
 -- show_message('you died !!!', main_camera.x-20, main_camera.y-20-4*(cos(time())), 8, 2, 15, 2, 'gameover1', true, false, false , 7)
 -- show_message('your score is '..flr(player.score), main_camera.x -32, main_camera.y+15, 10, 9, 10, 2, 'gameover2', true)
 -- show_message('press — button \n\n  to restart', main_camera.x-29, main_camera.y + 10, 11, 3, 2, 2, 'gameover3', true, false, false , 7)
 
 end

 draw_part()
 for obj in all(game_objects) do
  if(obj:is_active() == true) then
   obj:draw()
  end
 end
  spe_print('the undead has won...', main_camera.x-20, main_camera.y-20-4*(cos(time())), 8, 2)
 draw_mouse_cursor()
end

function update_victory()
 if btn(5) then run() end
 -- if game_over == false then sfx(15) end
 -- game_over = true
 mode='victory'
 -- camera_update()
end

function draw_victory()
 cls(12)
 draw_map()
 -- camx, camy = 64, 64
 -- local modx, mody= camx + shkx, camy+shky
 -- camx, camy = player.x, player.y
 if do_once == false then 
  do_once=true


 -- show_message('you defeated \n\n the army \n\nof death !!!', main_camera.x-22, main_camera.y-27-4*(cos(time())), 11, 3, 3, 2, 'gameover1', true, true, false)
 -- show_message('your score is '..flr(player.score), main_camera.x -32, main_camera.y+15, 10, 9, 10, 2, 'gameover2', true)
 -- show_message('press — button \n\n  to restart', main_camera.x-29, main_camera.y + 10, 11, 3, 2, 2, 'gameover3', true, false, false , 7)
 
 end

 draw_part()
 for obj in all(game_objects) do
  if(obj:is_active() == true) then
   obj:draw()
  end
 end
 draw_mouse_cursor()
 spe_print('the kingdom\n\nis saved !!!', main_camera.x-22, main_camera.y-27-2*(cos(time())), 11, 3)
 spe_print('— to restart', main_camera.x-25, main_camera.y + 10, 10, 9)

end

function update_start()
 if btn(5) then start_game() end
end


function draw_camera_button()

-- left
 outline_spr(99+flr(time()/2%2), main_camera.x-32, 26)
 spr(99+flr(time()/2%2), main_camera.x-32, 26)
-- right
 outline_spr(99+flr(time()/2%2), main_camera.x+24, 26, true)
 spr(99+flr(time()/2%2), main_camera.x+24, 26, 1, 1, true)

 -- pset(main_camera.x-28, 27, 8)
 -- pset(main_camera.x-28, 33, 8)
 -- pset(main_camera.x+30, 30, 8)
 -- pset(main_camera.x-31, 30, 8)
end

function camera_follow()
 
 if (pget(main_camera.x+30, 30) != 10 or pget(main_camera.x+27, 27) != 10
  or pget(main_camera.x+27, 33) != 9) and main_camera.x < 270 then main_camera.x += 2 
 elseif (pget(main_camera.x-31, 30)!=10 or pget(main_camera.x-28, 27) != 10 or pget(main_camera.x-28, 33) != 9
  or pget(main_camera.x-29, 29) != 10 or pget(main_camera.x-29, 30) != 10) and main_camera.x > 15 then main_camera.x -= 2 end

 -- if main_camera.x -stat(32) >= 32 then 
 --  main_camera.x -= 1
 -- elseif main_camera.x -stat(32) <= -26 then
 --  main_camera.x += 1
 -- end
 
 
 camera(main_camera.x-32 ,main_camera.y-32)
end

function draw_mouse_cursor()
 local posx= main_camera.x-mouse.x
 local posy= main_camera.y-mouse.y
 mouse.x = stat(32) +main_camera.x-32
 mouse.y = stat(33) + main_camera.y-32

-- block mouse x pos
 if posx > 32 then
  pal(7, 8)
  if posy > 32 then
   spr(46,main_camera.x-32, main_camera.y-32)
  else
   spr(46,main_camera.x-32, mouse.y)
  end
 elseif posx < -26 then
  pal(7, 8)
  if posy > 32 then
   spr(46,main_camera.x+26, main_camera.y-32)
  else
   spr(46,main_camera.x+26, mouse.y)
  end
 end
 -- block mouse y pos.
 if posy > 32 then
  pal(7, 8)
  spr(46,mouse.x, main_camera.y-32)
 elseif posy < -25 then
  pal(7, 8)

  if posx > 32 then
   spr(46,main_camera.x-32, main_camera.y+25)
  elseif posx < -26 then
   spr(46,main_camera.x+26, main_camera.y+25)
  else
   spr(46,mouse.x, main_camera.y+25)
  end
 end

 if posx <= 32 and posx >= -26 and posy <= 32 and posy >= -25 then
  spr(46,mouse.x, mouse.y)
 end
 pal()
end

-- ##tower
function make_tower(x, y, tag, health, sprite)

 local new_tower = make_gameobject(x, y, tag,{
  current_health=health,
  max_health=health,
  sprite=sprite,
  show_health=function(self)
   spe_rect(self.x-2+shkx,self.y+35+shky, self.x+17+shkx,self.y+37+shky, self.current_health/self.max_health, 5, 11, 0)
   -- spe_rect(main_camera.x-self.x-270,main_camera.y-self.y-0,main_camera.x- self.x,main_camera.y-self.y+23, self.current_health/self.max_health, 8, 11, 0)
   spe_rect(main_camera.x-self.x+270,self.y-8, main_camera.x-self.x+270+31,self.y-8, self.current_health/self.max_health, 8, 11, 12)

  end,
  is_alive=function (self)
   if self.current_health <= 0 then
    self:disable()
    return false
   else
    return true
   end
  end,
  take_damage=function(self, damage)
   -- whiteframe=true
   self.current_health-= damage
   -- shake_camera(0.25)
   if rnd() > 0.5 then make_enemy(flr(rnd(4))) end

   return true
  end,
  draw_sprite=function(self)
    -- draw shadow
    change_all_pal(2)
    -- sspr(self.sprite.x0, self.sprite.y0, self.sprite.x1, self.sprite.y1, x+shkx, y+shky+16, 16, 16, false, true) 
    -- outline_sspr(self.sprite.x0, self.sprite.y0, self.sprite.x1, self.sprite.y1, x+shkx, y+shky+16, 16, 16, false, true,2) 

    pal()

   outline_sspr(self.sprite.x0, self.sprite.y0, self.sprite.x1, self.sprite.y1, x+shkx, y+shky,16, 32) 
   sspr(self.sprite.x0, self.sprite.y0, self.sprite.x1, self.sprite.y1, x+shkx, y+shky) 
  end,
  draw=function(self)
   self:draw_sprite()
   self:show_health()
  end,
  update=function(self)
   self:is_alive()
  end
  })
  add(enemies, new_tower)
  return new_tower

end


-- ##random_enemy_spawning
function random_enemy_spawning()
 local spawner = search_gameobject('spawner')
 if(spawner == nil) then return end
 if spawner.timer <= time() then
  if spawner.time_between_spawn > 3 then spawner.time_between_spawn *= 0.95 end
  sfx(21)

  spawner.timer = time() + spawner.time_between_spawn


  -- local rand, randmax= 0, 3
  -- if time() > 15 then randmax = 4 else randmax = 3 end

  -- for i=0, 1 do
  rand=flr(rnd(18))
  if rand <= 8 then
   make_enemy(1)
  elseif rand <= 13 then
   make_enemy(2)
   elseif rand <= 15 then
   make_enemy(3)
   elseif rand <= 16 then
   make_enemy(4)
   elseif rand <= 17 then
   make_enemy(5)
   end
 end

end

-- ##unit
function make_unit(x, y, tag, health, move_speed, atk_info, sounds, sprite)
 spawner.alivee += 1
 local new_unit = make_gameobject(x, y, tag,{
  sprite=sprite,
  max_health=health,
  current_health=health,
  sounds=sounds,
  move_speed=move_speed,
  attack_info=atk_info,
  side=1,
  take_damage=function(self, damage)
   self.current_health-= damage
   if self.attack_info.tab == enemies then self.side = -1 end
   blood_explosion(self:center('x'), self:center('y'), damage, self.side, {8})

   -- shake_camera(1)
   return true
  end,
  find_target=function(self)
   -- if self:get_target() == nil or self:get_target():is_alive() == false then self.attack_info.target=nil end
   if self:get_target() and self:get_target():is_alive() == false then self.attack_info.target = nil end
   -- if self:can_attack() then return end 
   local shortest = 10000
   for obj in all(self.attack_info.tab) do
    if obj:is_alive() then
     local dist = distance(self, obj, true)
     if dist < shortest then
      if (self.attack_info.tab == enemies and self.x < obj.x) or
       (self.attack_info.tab == allies and self.x > obj.x) then

       shortest = dist
       self.attack_info.target = obj
      end
     end
    end
   end
  end,
  kill=function(self)
    self.current_health = 0
    spawner.alivee -=1
     blood_explosion(self:center('x'), self:center('y'), 50, self.side, {8})
     if self.attack_info.tab == allies then
      local points = self.max_health+self.attack_info.damage + rnd(15)
      mana_part(self.x, self.y,  main_camera.x-24, main_camera.y-30, flr(points),{12}) 
     end
     sfx(self.sounds.death +flr(rnd(2)))

     if self.attack_info.tab == enemies then del(allie, self) else del(enemies, self) end
     self:disable()
  end,
  is_alive=function(self)
   if self.current_health <= 0 then
     return false
   else
    return true
   end
  end,
  get_target=function(self)
   return self.attack_info.target
  end,
  can_attack=function(self)
   if self:get_target() != nil and distance(self, self:get_target()) < self.attack_info.range then return true
   else return false end
  end,
  move=function(self)
   if self:can_attack() == false and self:get_target() != nil then
    move_toward(self, {x=self:get_target().x, y=self.y}, self.move_speed)
   end
  end,
  attack=function(self)
   if self.attack_info.timer < time() and self:get_target() != nil and
     distance(self, self:get_target()) < self.attack_info.range then
     
    self.attack_info.timer = time() + self.attack_info.attack_speed
    if self.attack_info.class == 'melee' then
     sfx(self.sounds.hit)
     self:get_target():take_damage(self.attack_info.damage)
    elseif self.attack_info.class =='distance' then
     sfx(self.sounds.hit)

     local atk_offset = -10
     if self:get_target() != nil and self.x < self:get_target().x then atk_offset=10 end

     if  self.attack_info.effect != nil and self.attack_info.effect.state == true then 
      hit_part(self.x+atk_offset/2,self.y+12,{11, 3})
     end

     local bullet = make_bullet(self.x+atk_offset, self.y, self.attack_info.bullet_info.damage, self.attack_info.bullet_info.backoff, 
      self.attack_info.bullet_info.move_speed, self.attack_info.bullet_info.sprite, self.attack_info.target, self.attack_info.bullet_info.tag, self.sprite.powered)

     if bullet != nil then
      bullet:set_target(self:get_target())
     end
    end
   end
  end,
  reset=function(self)
   self.current_health = self.max_health
   self:enable()
  end,
  show_health=function(self)
   if self.current_health >= self.max_health then return end
   spe_rect(self.x+shkx+5,self.y+shky-2, self.x+shkx+10,self.y+shky-2, self.current_health/self.max_health, 5, 11, 0)
  end,
  draw_sprite=function(self)
    local is_flip_x, atk_offset = false, -8
    if self:get_target() != nil and self.x < self:get_target().x then is_flip_x = true
      atk_offset=8 end


   if self:can_attack() == false then
    local speed = self.move_speed
    if speed >= 32 then speed = 20 end
    local n = flr(time()*speed/3 % #self.sprite.move)+1
    -- draw shadow
    change_all_pal(2)
    outline_sspr(self.sprite.move[n].sx, self.sprite.move[n].sy, self.sprite.move[n].sw,
     self.sprite.move[n].sh, self.x+shkx, self.y+shky+16, 16, 16, is_flip_x, true, 2)
    pal()

    outline_sspr(self.sprite.move[n].sx, self.sprite.move[n].sy, self.sprite.move[n].sw,
     self.sprite.move[n].sh, self.x+shkx, self.y+shky, 16, 16, is_flip_x, false)
    pal(14, self.sprite.col1)
    pal(13, self.sprite.col2)
    sspr(self.sprite.move[n].sx, self.sprite.move[n].sy, self.sprite.move[n].sw,
     self.sprite.move[n].sh, self.x+shkx, self.y+shky, 16, 16, is_flip_x, false)
    pal()
    if self.sprite.powered then power_effect(self.x+abs(atk_offset)+shkx, self.y+shky+6, 1, {7, self.sprite.col1, self.sprite.col2}) end
   else
    local n = flr(time()/(self.attack_info.attack_speed/2) % #self.sprite.attack)+1
    if n == 1 then atk_offset = 0 end

    -- draw shadow
    change_all_pal(2)
    outline_sspr(self.sprite.attack[n].sx, self.sprite.attack[n].sy, self.sprite.attack[n].sw,
     self.sprite.attack[n].sh, self.x+atk_offset+shkx, self.y+shky+16, 16, 16, is_flip_x, true, 2)
    pal()

    outline_sspr(self.sprite.attack[n].sx, self.sprite.attack[n].sy, self.sprite.attack[n].sw,
     self.sprite.attack[n].sh, self.x+atk_offset+shkx, self.y+shky, 16, 16, is_flip_x, false)
    pal(14, self.sprite.col1)
    pal(13, self.sprite.col2)
    sspr(self.sprite.attack[n].sx, self.sprite.attack[n].sy, self.sprite.attack[n].sw,
     self.sprite.attack[n].sh, self.x+atk_offset+shkx, self.y+shky, 16, 16, is_flip_x, false)
    pal()

    if self.sprite.powered then power_effect(self.x+abs(atk_offset)+shkx, self.y+shky+6, 1, {7, self.sprite.col1, self.sprite.col2}) end
   end

  end,
  update=function(self)
   if self:is_alive() == false then self:kill() end
   self:find_target()
   self:move()
   self:attack()

  end,
  draw=function(self)
   self:draw_sprite()
   self:show_health()

  end
  })

 if new_unit.attack_info.tab == enemies then add(allies, new_unit) else add(enemies, new_unit) end 
end

function make_enemy(n)
 -- if spawner.alivee > 20 then return end
 local spawn_posx, spawn_posy = 280, 24+rnd(3)-rnd(3)
 hit_part(spawn_posx+8, spawn_posy+8, {11, 3, 2})
 -- spawner.alivee += 1
 if n == 1 then
 make_unit(spawn_posx, spawn_posy, 'enemy_unit1', 4, 24,
  {class='melee', tab=allies, target=turret, damage=1, range=16, timer=0, attack_speed=0.5}, {hit=4, death=8},{move={{sx=16, sy=0, sw=16, sh=16},{sx=32, sy=0, sw=16, sh=16}},
  attack={{sx=46, sy=0, sw=16, sh=16}, {sx=64, sy=0, sw=16, sh=16}}, col1=3, col2=1})
 elseif n == 2 then
  make_unit(spawn_posx, spawn_posy, 'enemy_unit2', 12, 18,
   {class='melee', tab=allies, target=turret, damage=0.25, range=16, timer=0, attack_speed=1}, {hit=4, death=8},{move={{sx=16, sy=16, sw=16, sh=16},{sx=32, sy=16, sw=16, sh=16}},
   attack={{sx=46, sy=16, sw=16, sh=16}, {sx=64, sy=16, sw=16, sh=16}}, col1=3, col2=1})
 elseif n == 3 then
    make_unit(spawn_posx, spawn_posy, 'enemy_unit3', 2, 26, 
     {class='distance', bullet_info={damage=1, sprite=207, move_speed=600, backoff=0, tag='bullet2'},
      tab=allies, target=nil, damage=1, range=45, timer=0, attack_speed=1, effect={state=true, col={11, 3}}},
      {hit=13, death=6},{move={{sx=56, sy=96, sw=16, sh=16},{sx=72, sy=96, sw=15, sh=15}},
       attack={{sx=88, sy=96, sw=16, sh=16}, {sx=104, sy=96, sw=16, sh=16}}, col1=3, col2=2})
 elseif n==4 then
 make_unit(spawn_posx, spawn_posy, 'enemy_unit4', 7, 44,
  {class='melee', tab=allies, target=turret, damage=5, range=16, timer=0, attack_speed=0.25}, {hit=4, death=8},{move={{sx=16, sy=0, sw=16, sh=16},{sx=32, sy=0, sw=16, sh=16}},
  attack={{sx=46, sy=0, sw=16, sh=16}, {sx=64, sy=0, sw=16, sh=16}}, col1=1, col2=8, powered=true})
 elseif n==5 then
    make_unit(spawn_posx, spawn_posy, 'enemy_unit5', 3, 30, 
     {class='distance', bullet_info={damage=1, sprite=207, move_speed=600, backoff=0, tag='bullet2'},
      tab=allies, target=nil, damage=1, range=45, timer=0, attack_speed=0.25, effect={state=true, col={7, 1}}},
      {hit=13, death=6},{move={{sx=56, sy=96, sw=16, sh=16},{sx=72, sy=96, sw=15, sh=15}},
       attack={{sx=88, sy=96, sw=16, sh=16}, {sx=104, sy=96, sw=16, sh=16}}, col1=10, col2=1, powered=true})
 end
end

function enemy_repost(n)
 local rand = rnd()
 if rand <=0.5 then
  if n==1 then n = 2 elseif n==2 then n = 1 elseif n==3 then n = 2 elseif n==4 then n = 5 elseif n==5 then n = 4 end
  make_enemy(n)
 elseif rand <=0.65 then
  make_enemy(n)
 else return
 end
end

function meteor_ability()
 for i=-2, 10 do

  make_gameobject(i*20+rnd(5), -rnd(30)-10, 'meteor', {
   speed=20+rnd(15),
   damage=5,
   size=rnd()+2,
   kill=function(self)
    self:disable() 
    hit_part(self.x, self.y, {10, 9, 2})
    sfx(-1, 0)
   end,
   update=function(self)
    shake_camera(0.05)
    sfx(22, 0)
    if self.y > 38 then self:kill() end
    self.x += self.speed/25
    self.y += self.speed/25
    local shortest = 10000
    for obj in all(enemies) do

     if obj:is_alive() then
      local dist = distance(self, obj, true)
       if dist < 10 then 
        obj:take_damage(self.damage)
        sfx(23)
        self:kill()
       end
     end
    end

   end,
   draw=function(self)
    local ry = rnd()-rnd()
    circ(self.x+shkx,self.y+shky+ry, self.size+2, 2)
    circfill(self.x+shkx,self.y+shky+ry, self.size+1, 4)
    add_part(self.x+shkx+rnd(4)-rnd(4), self.y+shky, 5, rnd(3)+1, rnd(10)+5, 0, 0, {8, 9, 10})
    -- add_part(x, y ,tpe, size, mage, dx, dy, colarr)
   end
   })


 end
end

-- ##button
function make_button(x, y, cooldown, sprite, price, tag, button_l)
 return make_gameobject(x, y, tag, {
  c_sprite=1,
  sprite=sprite,
  price=price,
  button_l=button_l,
  current_cooldown=0,
  max_cooldown=cooldown,
  button_info={timer=0, reload_time=1},
  action=function(self)
   
   self.current_cooldown = self.max_cooldown
   local pr, posx, posy= rnd(3)-rnd(3), -10, 24
   hit_part(posx+4, posy+8, {7, 6, 5, 1})
   if sub(self.tag, 8, 13) == 'unit1' then
    sfx(12)
    make_unit(posx, posy+pr, 'ally_unit1', 4, 24, 
     {class='melee', tab=enemies, target=nil, damage=1, range=16, timer=0, attack_speed=0.5},
      {hit=5, death=6},{move={{sx=32, sy=64, sw=16, sh=16},{sx=48, sy=64, sw=16, sh=16}},
       attack={{sx=64, sy=64, sw=16, sh=16}, {sx=80, sy=64, sw=16, sh=16}}, col1=8, col2=6})
    enemy_repost(1)
   elseif sub(self.tag, 8, 13) == 'unit2' then
    sfx(12)
    make_unit(posx, posy+pr, 'ally_unit2', 2, 24, 
     {class='distance', bullet_info={damage=2, sprite=47, move_speed=300, backoff=0, tag='bullet3'},
      tab=enemies, target=nil, damage=1, range=45, timer=0, attack_speed=1},
      {hit=5, death=6},{move={{sx=32, sy=80, sw=16, sh=16},{sx=48, sy=80, sw=16, sh=16}},
       attack={{sx=64, sy=80, sw=16, sh=16}, {sx=80, sy=80, sw=16, sh=16}}, col1=11, col2=3})
    enemy_repost(2)
   elseif sub(self.tag, 8, 13) == 'unit3' then
    sfx(12)
    make_unit(posx, posy+pr, 'ally_unit3', 20, 18, 
     {class='melee', tab=enemies, target=nil, damage=3, range=16, timer=0, attack_speed=1},
      {hit=5, death=6},{move={{sx=48, sy=48, sw=16, sh=16},{sx=64, sy=48, sw=16, sh=16}},
       attack={{sx=80, sy=48, sw=16, sh=16}, {sx=96, sy=48, sw=16, sh=16}}, col1=1, col2=6})
    enemy_repost(3)
   elseif sub(self.tag, 8, 13) == 'unit4' then
    sfx(20)
    make_unit(posx, posy+pr, 'ally_unit4', 16, 32, 
     {class='melee', tab=enemies, target=nil, damage=2, range=16, timer=0, attack_speed=0.25 },
      {hit=5, death=6},{move={{sx=32, sy=64, sw=16, sh=16},{sx=48, sy=64, sw=16, sh=16}},
       attack={{sx=64, sy=64, sw=16, sh=16}, {sx=80, sy=64, sw=16, sh=16}}, col1=12, col2=1, powered=true})
    enemy_repost(4)
   elseif sub(self.tag, 8, 13) == 'unit5' then
   sfx(20)
    make_unit(posx, posy+pr, 'ally_unit5', 6, 24, 
     {class='distance', bullet_info={damage=1, sprite=63, move_speed=600, backoff=0, tag='bullet4', powered=true},
      tab=enemies, target=nil, damage=1, range=45, timer=0, attack_speed=0.25},
      {hit=5, death=6},{move={{sx=32, sy=80, sw=16, sh=16},{sx=48, sy=80, sw=16, sh=16}},
       attack={{sx=64, sy=80, sw=16, sh=16}, {sx=80, sy=80, sw=16, sh=16}}, col1=9, col2=2, powered=true})
    enemy_repost(5)
   elseif sub(self.tag, 8, 13) == 'unit6' then
   sfx(20)
    make_unit(posx, posy+pr, 'ally_unit6', 48, 18, 
     {class='melee', tab=enemies, target=nil, damage=6, range=16, timer=0, attack_speed=0.5},
      {hit=5, death=6},{move={{sx=48, sy=48, sw=16, sh=16},{sx=64, sy=48, sw=16, sh=16}},
       attack={{sx=80, sy=48, sw=16, sh=16}, {sx=96, sy=48, sw=16, sh=16}}, col1=10,col2=1, powered=true})
    enemy_repost(4)
    enemy_repost(5)
   elseif sub(self.tag, 8, 13) == 'unit7' then
   sfx(20)
    make_unit(posx, posy+pr, 'ally_unit7', 32, 24, 
     {class='distance', bullet_info={damage=6, sprite=223, move_speed=200, backoff=0, tag='bullet5', powered=true},
      tab=enemies, target=nil, damage=1, range=75, timer=0, attack_speed=2},
      {hit=5, death=6},{move={{sx=56, sy=112, sw=16, sh=16},{sx=72, sy=112, sw=16, sh=16}},
       attack={{sx=88, sy=112, sw=16, sh=16}, {sx=104, sy=112, sw=16, sh=16}}, col1=7, col2=6, powered=true})
    enemy_repost(4)
    enemy_repost(5)
   elseif sub(self.tag, 8, 13) == 'unit8' then
   sfx(20)
    make_unit(posx, posy+pr, 'ally_unit8', 8, 128, 
     {class='melee', tab=enemies, target=nil, damage=6, range=16, timer=0, attack_speed=0.125 },
      {hit=5, death=6},{move={{sx=32, sy=64, sw=16, sh=16},{sx=48, sy=64, sw=16, sh=16}},
       attack={{sx=64, sy=64, sw=16, sh=16}, {sx=80, sy=64, sw=16, sh=16}}, col1=10, col2=8, powered=true})
    enemy_repost(4)
   elseif sub(self.tag, 8, 16) == 'manaregen' then
    sfx(11)
    turret.mana_gain *= 1.5
    self.price *= 2
   elseif sub(self.tag, 8, 15) == 'manamax' then
    sfx(11)
    turret.mana_max += 50
    self.price = turret.mana_max 
   elseif sub(self.tag, 8, 20) == 'lesscooldown' then
    sfx(11)
    for obj in all(game_objects) do
     if sub(obj:get_tag(), 0, 6) == 'button' and obj:get_tag() != 'button_meteor' and obj.max_cooldown > 0.5 then obj.current_cooldown *=0.5 obj.max_cooldown *= 0.5  end
     -- if obj:get_tag()== 'button_lesscooldown' then obj.current_cooldown *=0.5 obj.max_cooldown *= 0.5  end
    end
    self.price += 50
   elseif sub(self.tag, 8, 14) == 'meteor' then
    -- sfx(11)
    meteor_ability()
   end

  end,

  is_mouse_over=function(self)
   if mouse.x >= main_camera.x+self.x and mouse.x < main_camera.x+self.x+8
    and mouse.y >= main_camera.y+self.y and
    mouse.y < main_camera.y+self.y+7 then
    return true
   else return false end
  end,
  update=function(self)
   if self.button_l != 666 and (self.button_l != button_line or (self.tag =='button_lesscooldown' and self.price >= 250)) then return end

   if self.current_cooldown <= 0 then self.current_cooldown = 0 else self.current_cooldown -= 1/30 end

   if self.current_cooldown <= 0 and turret.mana >= self.price and self:is_mouse_over() and is_mouse_left_click_once() then
    turret.mana -= self.price
    self:action()
   end
  end,
  draw=function(self)
   if self.button_l != 666 and (self.button_l != button_line or (self.tag =='button_lesscooldown' and self.price >= 250)) then return end


   local pc = self.current_cooldown/self.max_cooldown
   self.c_sprite = flr(time()%#self.sprite)+1
    -- local n = flr(time()*speed/3 % #self.sprite.move)+1

   -- if pc > 1 then pc = 1 elseif pc < 0 then pc = 0 end 
   if self.price > turret.mana  then
    pal(12, 8)
    pal(1, 2)
   end
    spe_print(self.price, main_camera.x+self.x,main_camera.y+self.y-8, 12, 1, 16)
    -- print(self.price, main_camera.x+self.x,main_camera.y+self.y-8, 11)

    pal()


   if self.current_cooldown > 0 then 
    if self.price > turret.mana then
     pal(11, 2)
    else
     pal(11, 3) 
    end

   elseif self.price > turret.mana  then 
    pal(11, 8)
   elseif self:is_mouse_over() then
      pal(11, 10) 
   end
   rect(main_camera.x+self.x,(main_camera.y+self.y)+7*pc,main_camera.x+self.x+7,main_camera.y+self.y+7, 11)
   -- if self:is_mouse_over() == true then pal(1, 10)  end
   spr(self.sprite[self.c_sprite], main_camera.x+self.x,main_camera.y+self.y)
   pal()
  end
  })
end

function fade(x, y, range)
 dpal={0,1,1, 2,1,13,6,
          4,4,9,3, 13,1,13,14}
 for i=x, range do
  for y=y, range do
    pset(x+4, x+4, dpal[pget(y, x)]) 
  end
 end
end



function is_mouse_left_click_once()
 left_click_once_timer+=1
 if(stat(34) == 0) then left_click_once_timer =0 end
 if(left_click_once_timer <= 2 and left_click_once_timer > 0) then return true else return false end
end

-- ##turret
function make_turret(x, y, tag,sprite)
 local new_turret= make_gameobject(x, y, tag, {
  sprite=sprite,
  max_health=250,
  current_health=250,
  mana=15,
  mana_tcol=12,
  mana_max=50,
  mana_gain=1,
  level=1,
  attack_info={target=nil,  range=70, attack_speed=2, timer=0},
  bullet_info={damage=1, sprite=47, move_speed=300, backoff=100, tag='bullet1'},
  show_health=function(self)
   -- local in_col,out_col, rate = 11, 3, self.current_health/self.max_health
   -- if rate >= 0.75 then in_col = 11 out_col =3  elseif rate >= 0.5 then in_col = 10 out_col = 9 elseif rate>= 0.25 then in_col = 9 out_col = 4 else in_col = 8 out_col = 2 end
   -- spe_print(self.current_health,self.x+4, self.y-10, in_col, out_col)
   spe_rect(self.x-3,self.y+35, self.x+16,self.y+36, self.current_health/self.max_health, 8, 11, 0)

   spe_rect(main_camera.x-self.x-30,main_camera.y-self.y-24,main_camera.x- self.x,main_camera.y-self.y-24, self.current_health/self.max_health, 8, 11, 12)

  end,

  take_damage=function(self, damage)
   -- whiteframe=true
   self.current_health-= damage
   -- shake_camera(0.01)
   return true
  end,
  find_target=function(self)
    if self:get_target() and self:get_target():is_alive() == false then self.attack_info.target = nil end

   local shortest = 10000
   for obj in all(enemies) do

    if obj:is_alive() then
     local dist = distance(self, obj)
     if dist < shortest then
      shortest = dist
      if shortest < self.attack_info.range then 
       self.attack_info.target = obj
      end
     end
    end
   end
  end,
  is_winning=function(self)
   if enemy_tower:is_alive() == false then
    sfx(10)
    mode = 'victory'
   end
  end,
  is_alive=function (self)
   if self.current_health <= 0 then
    mode='gameover'
    return false
   else
    return true
   end
  end,
  can_attack=function(self)
   if self:get_target() != nil and distance(self, self:get_target()) < self.attack_info.range and time() >= self.attack_info.timer then return true
   else return false end
  end,
  get_target=function(self)
   return self.attack_info.target
  end,
  attack=function(self)
   if self:can_attack()==false then return end

   if self.attack_info.timer < time() and self:get_target() != nil and
    distance(self, self:get_target()) < self.attack_info.range then
    -- shake_h(2)
    circ_part(self.x+16, self.y+25, rnd(3)+3, 5, {7})
    sfx(flr(rnd(2)+1))
    local bullet = make_bullet(self.x+8, self.y+17, self.bullet_info.damage, self.bullet_info.backoff, 
     self.bullet_info.move_speed, self.bullet_info.sprite, self.attack_info.target, self.bullet_info.tag)
    if bullet != nil then
     bullet:set_target(self:get_target())
    
    end
    self.attack_info.timer = time() + self.attack_info.attack_speed

   end
  end,
  show_mana=function(self)
   if self.mana >= self.mana_max and time()*2%2 >= 1 then pal(12, 1)  end
   spe_print(flr(self.mana)..'/'..flr(self.mana_max)..'†', main_camera.x-30, main_camera.y-29, self.mana_tcol, 1)
   pal()
   -- if self.mana_tcol == 7 then self.mana_tcol = 12 end
  end,
  draw_sprite=function(self)
    local n = flr(time() % #self.sprite)+1

    -- local n = flr(time()*self.move_speed/3 % #self.sprite.move)+1Ã¹
    -- -- draw shadow
    -- change_all_pal(2)
    -- outline_sspr(self.sprite.move[n].sx, self.sprite.move[n].sy, self.sprite.move[n].sw,
    --  self.sprite.move[n].sh, self.x+shkx, self.y+shky+16, 16, 16, is_flip_x, true, 2)

    -- draw shadow
    change_all_pal(2)
    sspr(self.sprite[n].x0, self.sprite[n].y0, self.sprite[n].x1, self.sprite[n].y1, x+shkx, y+shky+16, 16, 40, false, true) 
    outline_sspr(self.sprite[n].x0, self.sprite[n].y0, self.sprite[n].x1, self.sprite[n].y1, x+shkx, y+shky+16, 16, 40, false, true,2) 

    pal()

   outline_sspr(self.sprite[n].x0, self.sprite[n].y0, self.sprite[n].x1, self.sprite[n].y1, x+shkx, y+shky, 16, 32)
   sspr(self.sprite[n].x0, self.sprite[n].y0, self.sprite[n].x1, self.sprite[n].y1, x+shkx, y+shky)
  end,
  show_range=function(self)
   for i=0, 10 do
     if i%2 == 1 then
      pset(self.x +self.attack_info.range, self.y+22+i, 8)
     end
   end
  end,
  mana_management=function(self)
   self.mana_tcol = 12
   if self.mana < self.mana_max then
    self.mana += (self.mana_gain+self.mana_max*0.005)/30
   else
    self.mana = self.mana_max
   end
  end,
  add_mana=function(self, amount)
   self.mana_tcol=7
   self.mana += amount
   -- self.mana_tcol=12

  end,
  draw=function(self)
   self:draw_sprite()
   self:show_health()
   self:show_mana()
   self:show_range()
  end,
  update=function(self)
   self:mana_management()
   self.is_winning()
   self:is_alive()
   self:find_target()
   self:attack()

  end

  })
  
  add(allies, new_turret)
  return new_turret

end

-- draw a rect with a border color, a bg color and a fill color.
-- pc = pourcentage to fill
function spe_rect(x0,y0,x1,y1, pc, back_col, font_col, bordercol)
 local length = x1 - x0
 rectfill(x0-1,y0-1,x1+1,y1+1,bordercol)
 rectfill(x0,y0,x1,y1,back_col)
 if pc > 0.001 then
  rectfill(x0,y0, x0 + length*pc,y1,font_col)
 end
end
-- ##bullet
function make_bullet(x, y, damage, backoff, move_speed, sprite, target, tag, powered)
 return make_gameobject (x, y, tag, {
  damage=damage,
  move_speed=move_speed,
  sprite=sprite,
  powered=powered,
  target=target,
  direction={x=target.x, y=target.y},
  update=function(self)
   if self.target:is_active() == false then self:disable() end
   -- self.move_speed *= 0.98
   self:move_straight()
   if(distance(self, self.target) <= 5 and self.target:is_active() == true and self.target:is_alive()) then
    -- backoff the target
    -- move_toward(self.target, self, -backoff)

    self.target:take_damage(damage)

    self:explode()
    self:disable()
   elseif self.target:is_active() == false then
    self:disable()
   end
  end,
  explode=function(self)
    hit_part(self:center('x'),self:center(' y'),{7, 6, 5})
    sfx(0) 
  end,
  set_target=function(self, target)
   self.target = target
   self.direction={x=target.x, y=target.y}
  end,
  move_straight=function(self)
   move_toward(self, {x=self.direction.x, y=self.y}, self.move_speed)
   if(distance(self, self.target) >= 80) then self:explode() self:disable() end
  end,
  draw=function(self)
    -- if time()*6%2 >= 1 then
    --  pal(9, 2)
    -- end
    if self.powered != nil then power_effect(self.x, self.y+8, 4, {7, 6, 5}) end
    outline_spr(self.sprite, self:center('x')+shkx, self:center('y')+shky)
    spr(self.sprite, self:center('x')+shkx, self:center('y')+shky)
    pal()
  end,
  reset=function(self)
   self:enable()
   
  end
  })
end

function sortbyy(a)
   for i=1,#a do
       local j = i
       while j > 1 and a[j-1].y > a[j].y do
           a[j],a[j-1] = a[j-1],a[j]
           j = j - 1
       end
   end
end

function change_all_pal(col)
 for i=0, 15 do
  pal(i, col)
 end
end

-- the y axis has a default value, 
function distance(current, target, yaxis)
 if current == nil or target == nil then return nil end
 local x0, y0, x1, y1 = current.x/100, current.y/100, target.x/100, current.y/100
 if yaxis != nil and yaxis == true then y1 = target.y/100 end
 return sqrt((x1 - x0)^2+(y1 - y0)^2)*100
end

function move_toward(current, target, move_speed)
 if(move_speed == 0) then move_speed = 1 end
 
 local dist= distance(current, target)
 if dist < 1 then return end
 local direction_x = (target.x - current.x) / 60 * move_speed
 local direction_y = (target.y - current.y) / 60 * move_speed
 
 if dist < 1 then dist = 0.25 end
 current.x += direction_x / dist
 current.y += direction_y / dist
 return current.x, current.y
end

function update_all_gameobject()
 for obj in all(game_objects) do
  if obj:is_active() then obj:update() end
 end
end

function draw_all_gameobject()
 sortbyy(game_objects)
 for obj in all(game_objects) do

  if obj:is_active()  then obj:draw() end
 end
end

-- ##make_gameobject
function make_gameobject(x, y, tag, properties)

 for obj in all(game_objects) do
  if obj:get_tag() == tag and obj:is_active() == false then
   obj:set_value(x, y, tag)
   obj:reset()
   return obj
  end
 end 

 local obj = {
  x=x,
  y=y,
  tag=tag,
  active=true,
  enable=function(self)
   self.active=true
  end,
  set_value=function(self, x, y, tag)
   self.x=x
   self.y=y
   self.tag=tag
  end,
  disable=function(self)
   self.active =false
  end,
  get_tag=function(self)
   return self.tag
  end,
  is_active=function(self)
   return self.active
  end,
  reset=function(self)
   self:enable()
  end,
  center=function(self, value)
   if value == 'x' then return self.x+4
   else return self.y + 4
   end
  end,
  update=function()
  end,
  draw=function()
  end
 }
 if properties != nil then
    for k, v in pairs(properties) do
     obj[k] = v
    end
 end

 add(game_objects, obj)
 return obj
end

-- ##part
function add_part(x, y ,tpe, size, mage, dx, dy, colarr)

 for obj in all(game_objects) do
  if(obj:is_active() == false and obj:get_tag() == tag) then
   obj:set_value(x,y,tag)
   obj:reset()
   return obj
  end
 end


 local p = {
  x=x,
  y=y,
  tpe=tpe,
  dx=dx,
  dy=dy,
  move_speed=0,
  size=size,
  age=0,
  mage=mage,
  col=col,
  colarr=colarr,
  active=true,
  layer=0

 }

 add(part, p)
 return p
end
function update_part()
 for p in all(part) do
  p.age+=1
  if p.mage != 0 and p.age >= p.mage or (p.size <= 0 and p.mage!=0) then
   del(part, p)
  end
  
  -- if p.colarr == nil then return end
  if #p.colarr == 1 then
   p.col=p.colarr[1]
  else
   local ci=p.age/p.mage
   ci=1+flr(ci*#p.colarr)
   p.col=p.colarr[ci]
  end
  p.x+=p.dx
  p.y+=p.dy
 end
end
function hit_part(x,y,colarr)
  for i=0, rnd(6)+4 do
  local p add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 1, rnd(4)+3, rnd(5)+35, (rnd(10)-rnd(10))/30, (rnd(10)-rnd(10))/30, colarr)
 end
end
function add_decors(n,x,y, layer)
 local p = add_part(x, y, 10, n, 0, 0, 0, {0})
 p.layer=layer
end

function mana_part(x0, y0, x1, y1, quantity, colarr)
 for i=1, quantity do
  local p = add_part(rnd(15)-rnd(15)+x0, rnd(15)-rnd(15)+y0, 14, flr(rnd(3))+1, 150, 0, 0, colarr)
  p.col = 7
  p.x1, p.y1 = x1, y1
  p.speed=rnd(30)
 end
end

function circ_part(x, y, size, mage, colarr)
  local p = add_part(x, y, 12, size, mage, 0, 0, colarr)
end

function power_effect(x, y, quantity, colarr, mage, range)
 local _x, _y, r = x, y, range or 9

 if mage == nil then mage=0.5 end
 for i=1,quantity do
  add_part(rnd(r)-rnd(r)+_x, rnd(6)-rnd(6)+_y, 0, 1, rnd(mage)+30, 0, -rnd(0.25), colarr)
 end  
end

function blood_part(x, y, quantity, colarr)
 for i=0, quantity do
  add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 5, rnd(2)+2, 500, 0, 0, colarr)
  -- add_part(x, y ,tpe, size, mage, dx, dy, colarr)
 end
end

function blood_explosion(x, y, quantity, direction, colarr)
  for i=0, quantity do
  add_part(rnd(2)-rnd(2)+x, rnd(2)-rnd(2)+y, 13, 1, 100, ((rnd(8)+2)*direction)/2, -rnd(1.5), colarr)
  -- add_part(x, y ,tpe, size, mage, dx, dy, colarr)
 end
end

function add_decors_sspr(sx,sy,sw,sh,dx,dy,dw,dh,layer)
 local p = add_part(dx,dy, 11, 0, 0, 0, 0, {0})
 p.sx = sx
 p.sy = sy
 p.sw = sw
 p.sh = sh
 p.dw = dw
 p.dh = dh
 p.layer=layer
end

function layer_convert(layer)
 if layer == 0 or layer == -1 then return 1000
 elseif layer == 1 then return 30
 elseif layer == 2 then return 15
 elseif layer == 3 then return 1
 else return 30000
 end
end
function draw_part()

 for p in all(part) do
  if p.tpe==0 then
   pset(p.x+shkx, p.y+shky, p.col)
  elseif p.tpe==1 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
   p.size -= 0.1
   -- blood part
  elseif p.tpe==5 then
   circfill(p.x+shkx,p.y+shky,p.size, p.col)
  elseif p.tpe==10 then
   local newlayer = layer_convert(p.layer)
   local offset = modx/((newlayer)*10)
    spr(p.size,p.x+offset, p.y+shky)
  elseif p.tpe==11 then
   local newlayer = layer_convert(p.layer)

   local offset = modx/(newlayer)

   -- print(modx, 32, 10, 0)
   sspr(p.sx, p.sy,p.sw,p.sh,p.x+offset,p.y+shky,p.dw,p.dh)
  elseif p.tpe == 12 then
   circfill(p.x,p.y,p.size,p.col)
  elseif p.tpe == 13 then
   pset(p.x+shkx, p.y+shky, p.col)

   -- rectfill(p.x,p.y,p.x+p.size,p.y+p.size,p.col)
   if p.y >= 38  then 
    p.dx, p.dy = 0, 0 
   else
    p.dy+=0.2
   end
  elseif p.tpe==14 then
   -- pset(p.x+shkx, p.y+shky, p.col)
   -- circfill(x,y,r,col)
   circfill(p.x+shkx, p.y+shky, p.size,p.col)
   local dist = distance(p, {x=p.x1, y=p.y1}, true)
   -- print(dist, p.x, p.y+3, 0)
   move_toward(p, {x=p.x1, y=p.y1}, dist*4+p.speed)
   if dist < 5 then turret:add_mana(1) del(part, p) sfx(15+flr(rnd(3)))  
   end
  end
 end
end


function search_gameobject(tag)
 for obj in all(game_objects) do
  if obj:get_tag() == tag then return obj end
 end
 return nil
end

function outline_spr(n, x, y, _flip_x, _flip_y)
 local out_col = 0
 local flip_x, flip_y = false, false
 if _flip_x then flip_x = _flip_x end
 if _flip_y then flip_y = _flip_y end

 for i=0, 15 do pal(i, out_col) end
 spr(n, x+1, y, 1, 1, flip_x, flip_y)
 spr(n, x-1, y, 1, 1, flip_x, flip_y)
 spr(n, x, y+1, 1, 1, flip_x, flip_y)
 spr(n, x, y-1, 1, 1, flip_x, flip_y)
 pal()
end
function outline_sspr(sx,sy,sw,sh,dx,dy, dw, dh, flip_x, flip_y, outline_col)
 local out_col = 0
 if outline_col != nil then out_col=outline_col end
 for i=0, 15 do pal(i, out_col) end
 sspr(sx,sy,sw,sh,dx+1,dy, dw, dh, flip_x, flip_y)
 sspr(sx,sy,sw,sh,dx-1,dy, dw, dh, flip_x, flip_y)
 sspr(sx,sy,sw,sh,dx,dy+1, dw, dh, flip_x, flip_y)
 sspr(sx,sy,sw,sh,dx,dy-1, dw, dh, flip_x, flip_y)
 pal()
end

-- ##spe_print
function spe_print(text, x, y, col_in, col_out, bordercol)
 local outlinecol = 0
 if bordercol != nil then outlinecol = bordercol end
 if bordercol != 16 then
  -- draw outline color.
  print(text, x-1+shkx, y+shky, outlinecol) 
  print(text, x+1+shkx, y+shky, outlinecol)
  print(text, x+1+shkx, y-1+shky, outlinecol)
  print(text, x-1+shkx, y-1+shky, outlinecol)
  print(text, x+shkx, y-1+shky, outlinecol)
  print(text, x+1+shkx, y+1+shky, outlinecol)
  print(text, x-1+shkx, y+1+shky, outlinecol)
  print(text, x+1+shkx, y+2+shky, outlinecol)
  print(text, x-1+shkx, y+2+shky, outlinecol)
  print(text, x+shkx, y+2+shky, outlinecol)
 end
-- draw col_out.
 print(text, shkx+x, shky+y+1, col_out)
 -- draw text.
 print(text, shkx+x, shky+y, col_in)
end

function shake_camera(power)
 local shka=rnd(1)
 shkx+=power*cos(shka)
 shky+=power*sin(shka)
end
function shake_h(power)
 local shka=rnd(1)
 shkx+=power*cos(shka)
end
function shake_v(power)
 local shka=rnd(1)
 shky+=power*sin(shka)
end

function do_camera_shake()
if abs(shkx)<0.1 then
 shkx=0
else
 shkx*=-0.7-rnd(0.2)
end

if abs(shky)<0.1 then
  shky=0
 else
  shky*=-0.7-rnd(0.2)
 end

end

__gfx__
00000000000000000000000000000000000000000000000000000000eff00e0e00000000000000000000000a0a0a0000000000000000000000ccaa9988bb0000
0000000a0a0a0000000000eff0000000000000000000000000000000eef00e0e000000000000000000000000aaa0f000008208820882082000ccaa9988bb0000
01000000aaa00000000000eef000000000000eff0000000000000000eee0e00e0000000000000000010000009990f0000022288b3888882000ccaa9988bb0000
01c0000099900000000000eee000000000000eef00000000000000000000e0e00000eff00000000001c00000f4f0f0000088bb38b3b3882000ccaa9988bb0000
01100000f4f0f00000ee00000000000000000eee00000000000000000ee000e00000eef00000000001100000f440f00000888bb3b38b322000ccaa9988bb0000
01100000f440f000000eee00ee0000000ee000000000000000000000eeee0e0000e0eee0000000000110000888af0000002228b3b38b322000ccaa9988bb0000
01c0000888af01000000000eee00000000eee00ee00000000000000002eee000000eee0ee000000001c0008888a00100002b38bbbbbb3b2000ccaa9988bb0000
01c0008888a1110000000ee02ee000000000000eee000000000000000eeee000000000eeee00000001c0088889a01100002bb3bbbbb3b3200011994422bb0000
0110088889a1cc0000eee000eee0000000000002ee00000000000000002e000000000002eee00000011008888aa0cc000088bbbb3bbb32200011994422bb0000
011008888aa1cc000000000002e000000000ee0eee0000000000000000ee000000000e0eeee00000011000000000cc0000888bb3bbbb32200011994422bb0000
01c01cc89cc11100000000000ee000000eee00002e00000000000000deeee00000eee0002e00000001c01cc00cc01100002228b3bbb388200011994422bb0000
01c1111cccc1110000000000ddd0000000000000ee0000000000000e000dd000000000e0ee0dd00001c1111cccc11100002228bbbb3388200011994422bb0000
011cccc1111ccc00000000ed00e0000000000000e00000000000000d0000e000000000d00000e000011cccc1111ccc00008882bbbbb382200011994422bb0000
0117ccc1111c7c00000000d0000d000000000000dd0000000000000d0000d000000000d00000d0000117ccc1111c7c00008882bbbbb382200000000000000000
01c7771ccc777100000000d0000d000000000000dd00000000000000e000e0000000000e0000e00001c7771ccc777100002228bbbbb388200000000000000000
01c688777722610000000ee000ee00000000000eee00000000000000e000e0000000000e0000e00001c6887777226100002228bbbbb388200000000000000000
0116888822226c000000000000000000000000000000000000000000000000e000000000000000000000000000220000008882bb33b382200100000000000000
0116888822226c00000000000eff00000000000000000000000000000eff00e000000000000000000000000002222000008882b3333382201710000000000000
01c6888822226100000000000eef000000000eff00000000000000000eef0e000000000000000000aaa0002222222220002228b3822328201771000000000777
01c6888822226100000000000eee000000000eef00000000000000000eee0e000000000000000000aaa0000003330000002228b3822228201777100000111777
0116888822226c00000ee000000000000ee00eee00000000000000000000e00e00000eff00000000aaa000000333000000888232288882201777710000000777
0116888822226c000000eee0eee0000000eee0000000000000000000eeeee00e00000eef00000000040000000222220000888222288882201771100000000000
01c6888822226100000000082ee000000000000eee000000000000082ee000e0eee00eee0eee0000040000022222220000222bbbbbb228200117100000000000
01c1688822261150000000082eee000000000082ee000000000000082eeeee00000ee00082ee00000333222222222220002bb737777bb8200000000000000000
011c68882226cc570000ee882eee000000000082eee00000000000882eee00000000000082eee000040022220002222000b7733377777b200000000000700000
011cc688226ccc570eee0022eee00000000e0882eee0000000000022eee0000000000e0882eee000040022200002222000b7733377777b200000000000777000
01c116882261115000000eeeeee00000eee0022eee00000000000eeeeee0000000eee0022eee00000400000000222220002bb737777bb8200000000011777770
01c1116826c1110000000dddddd0000000000eeeee00000000000dddddd000000000000eeeee0000040000000222222000222bbbbbb228200000000011777777
011cccc6611ccc0000000eed0ee0000000000eeee000000000000eed0ee000000000000eeee00000040000002222222200888222288882200000000011777770
011cccc1111ccc0000000dd00ddd0000000000dddd00000000000dd00ddd000000000000dddd0000040000022222222200888222288882200000000000777000
1cc1111cccc1111000000dd000dd0000000000dddd00000000000dd000dd000000000000dddd0000040000022222222202222888822228820000000000700000
ccc1111cccc1111c0000eee00eee000000000eeeee0000000000eee00eee00000000000eeeee0000040000003300033082222888822228880000000000000000
0000000a0a0a00004444444422222222cccccccc0000000000000000000000000000000000000000000000000000000000b00000000000000000000000000000
00000000aaa00f004444444422222222cccccccc0111111000000000000b00b0000000000000000000000000000000b000b000000aaaccc001111a1001111a10
0100000099900f004444444422222222cccccccc01668880000b0000000b0b0000000000000000000000000000000b0000bb00b00aa99cc001c1aaa00111aaa0
01c00000f4f0f0004444444422222222cccccccc06752220000b00000b03030000666600000000000000000000b0030000bb0b000a9998c001119a9004449a90
01100000f440f0004442444422222222cccccccc0675761000030000003330000666555000066000000bbb00000b000bb0bb33000c9822200616191006c61910
0110000888af00002222222222222222cccccccc06757610000300000033300006555550006655000bbbb330b00300b00bb333030cc8222006c6111006c61110
01c0008888a001002422224222222222cccccccc0166611000000000000000000000000000000000bbb333330b00003000b333300ccc22200666111006661110
01c0088889a111002222222422222222cccccccc0000000000000000000000000000000000000000b33333330300000000333330000000000000000000000000
011008888aa1cc000000000000000000444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011088889aa1cc0000000000000000004444444401111110011761100175941001117610011761100175821001117610011881100111111001c11a1004441a10
01c01cc8acc111000000000000000000444444440166888001176110017519400176661001176110017518200176661001882210011711100111aaa006c6aaa0
01c1111cccc1110000000000000000004444444406752220011761100175119001766610011761100175118001766610018222100117611001c19a9006c69a90
011cccc1111ccc000000000000000000444444440655761001176110017511900194761001176110017511800182761001122110011761100616191006c61910
0117ccc1111c7c00000000000000000044444444067776100194441001751940019411100182221001751820018211100114411001a9991006c6111006c61110
01c7771ccc7771000000000000000000444444440166611001194110017594100194111001182110017582100182111001194110011a91100666111006661110
01c68877772261000000000000000000444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116888822226c00422222220000000000000000000000000000000dd0000000000000000000000000000dd00000770000000000007dd7700000000000000000
0116888822226c00242222420000a0000000a00000000000000000dddd000000000000dd000000000000dddd000777000000000777dddd770000000000000000
01c688882222610022222222000aa000000aa0000cccc000000000dfdd00000000000dddd00000000000dfdd000777700000077777dfdd770000000000000000
01c68888222261002242222200aaa00000aaa0000ccccc007000000ffd00000000000dfdd000000000000ffd0000077000077777777ffd770000000000000000
0116888822226c00444442440aaaa0000aaaa000011110007770000000000000000000ffd0000000000000000000040000077777477777770000000000000000
0116888822226c00444444440099a0000099a0000000000077700eedee00000070000000000000000000edee50000400007777444eedee770000000000000000
01c6888822226100444444440009900000099000000000007770eedddee000007770eedeee0000000000dddeed00400000777744eedddee70000000000000000
01c168882226115044444444000090000000900000000000704000dd5dd00000777eedddee0000000000ddddd0f400000777444444dd5dd00000000000000000
011c68882226cc570000000000000000000000000000000000400505ddd0000077700dd5d0000000000000ddd5df0000077744444575ddd00000000000000000
011cc688226ccc57000000000000000000000000000000000004d0d0ddd000007040505dd0000000000000ddd040000007774444d4d0ddd00000000000000000
01c116882261115000000000000b3000bbbbbbb3000000000004ff00555000000040ddddd000000000000055500000000777744df00055500000000000000000
01c1116826c111000000000000bbb3000bbbbb3000000000000d400dddd00000000400d550000000000000ddd000000000777440d000ddd00000000000000000
011cccc6611ccc00000000000bbbbb3000bbb30000000000000040dd0dd00000000f005ddd00000000000d00d000000000777000000d00d00000000000000000
011cccc1111ccc0000000000bbbbbbb3000b3000000000000000005000d5d7000000400055000000000050000500000000000000005000050000000000000000
1cc1111cccc111100000000000000000000000000000000000070d000000070000004000dd0000000000d0000d0000000000000000d0000d0000000000000000
ccc1111cccc1111c0000000000000000000000000000000000007000000000000000000777000000000770007700000000000000077000770000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000007000000000777777000000000077777700000000000000000
000000000000000000000000000000000000000ddd000000000000000000000000000ddd0000000700000077777ddd7700000077777ddd770000000000000000
000000000000000000000000000000007000000fdd000000000000ddd000000000000fdd0000007000007777777fdd7700007777777fdd770000000000000000
000000000000000000000000000000007000000ffd000000000000fdd000000000000ffd0000007000077777777ffd7700077777777ffd770000000000000000
000000000000000000000000000000007700000000000000000000ffd00000000000000000000700007777777777777700777777777777770000000000000000
0000000000aaaaaaaaaa00000000000007000eedee00000000000000000000000000edee50000700077777777eedee77077777777eedee770000000000000000
00000000aaaaaaaaabbbb000000000000700ee5d5ee000007000eedeee00000000005d5eed00700007777777ee5d5ee707777777ee5d5ee70000000000000000
0000000aaaaaabbbbbbbbb0000000000007000ddd5500000700ee5d5ee0000000000ddd550fe70007777777777dd55507777777777dd55500000000000000000
000000aaaaaabbbbbbbbbbb30000000000700505ddd0000077000ddd50000000000000ddd5df0000777777777575ddd0777777777575ddd00000000000000000
00000aaaaaabbbbbbbbbbbb3300000000007d0d0ddd000000700505dd0000000000000ddd0e0000077777777ded0ddd077777777ded0ddd00000000000000000
0000aaaaaabbbbbbbbbbbb3333000000000dff00555000000700ddddd000000000000055500000007777777df00055507777777df00055500000000000000000
0000aaaaabbbbbbbbbbbbb33330000000000e000ddd00000007dd0d550000000000000ddd000000077777777d000ddd077777777d000ddd00000000000000000
0000aaaabbbbbbbbbbbbbb333300000000000e0d00d00000007ff05ddd00000000000d00d000000077777770000d00d077777770000d00d00000000000000000
000aaaabbbbbbbbbbbbbb33333300000000000500005d700000de000550000000000500005000000777777000050000577777700005000050000000000000000
000aaabbbbbbbbbbbbbbb3333330000000070d000000070000000e00dd0000000000d0000d0000007777700000d0000d7777700000d0000d0000000000000000
000aaabbbbbbbbbbbbbb333333330000000070000000000000000007770000000007700077000000777700000770007777770000077000770000000000000000
000aaabbbbbbbbbbbb33333333330000000000044400000000000000000000000000000000444000000000000000000000000000000000000000000000000000
000aabbbbbbbbbbbbb33333333330000000004444444000000000004440000000000000004444440000000000044400000000006660000000000000000000000
0000abbbbbbbbb3333333333333000000000000fff00000000000444444400000000047700fff00000000000044444407000000f660000000000006660000000
0000bbbbbbbb333333333333333000000040000fff0000000000000fff0000000000040700fff0070000047000fff0007000000ff6000000000000f660000000
0000bbbbbbb33333333333333300000000400000000040000040000fff00000000004000700000740000047000fff0077700000000000000000000ff60000000
0000003333333333333333330000000004000eedee04400000400000000040000000400ee7dee044000040700000007407000ee6ee0000000000000000000000
000000333333333333333330000000000400ee5d5ee4400004000eedee04400000040dd007d5ee440000407deedee0440700ee666ee000007000ee6eee000000
00000012333333333333300000000000004070dd755440000400ee5d5ee4400007444444447755440004dd7000d5ee440070006656600000700ee666ee000000
00000012333333333333100000000000004f0d77ddd44000004070dd7554400000040000070ddd44000f0070000d554400700505666000007700066566000000
000000122213333213221000000000000004f000ddd44000004f0d77ddd4400000004000070ddd4400040070000ddd4400076060666000000700505660000000
0000001222121222122210000000000000404000777000000004f000ddd44000000040007007770000004070000dfd440006ff00555000000700666660000000
0000001222121222122210000000000007000444ddd0000000400444ddd0000000000407000ddd00000040700007f7000000e000666000000076006550000000
000000122212122212221000000000000000000d00d00000070000000dd000000000047700d00d0000000470000dfd0000000e0600600000007ff05666000000
00000012221212221222100000000000000000f0000f4400000000000ff00000000000000f0000f0000004700fd00df000000050000567000006e00055000000
000000122212122212221000000000000004040000000400000000000440000000000000040000400000000004000040000706000000070000000e0066000000
00000012221212221222100000000000000040000000000000000000444000000000000044000440000000004400044000007000000000000000000777000000
000000044400000000000000000000000000000000000000000000000000000000dd00000000000000000000aaa00000000dd000a000000000dd000000000000
000004444444000000000006660000000000000a0a0a000000000000000000000dddd0000000000000dd0000aaa0000000dddd000a0000000dddd00000333300
0000000fff0000000000000f6600000001000000aaa0000000000000000000ddddddddd0000000000dddd000aaa0000ddddddddda00000bbbdddddd0033bb330
0040000fff0000007000000ff600000001c00000aaa000000000000000000d000eee0000000000ddddddddd0040000d000eee00000a00b000bee000003bbbb30
0040000000004000700000000000000001100000fff00f0000000000aaa000000eee000000000d000eee00000400000000eee0000a00b0b00bee000003bbbb30
04000bbdbb044000770008868800000001100000fff0f00000000000aaa000000ddddd00aaa000000eee00000eeedd000ddddd00a99000000ddddd00033bb330
0400bbdddbb44000070088666880000001c00008889f010000000000aa40000ddddddd00aaa000000ddddd000400dddddddddd0099a0b00bbddddd0000333300
004070dd7dd44000070000665660000001c00088889011000000000000eedddd0d0dddd0aa40000ddddddd000400d0dd0dddddd09990b0bbbdddddd000000000
004f0d77ddd440000070050566600000011008888990cc00000000000040d0dd000dddd000eedddd0d0dddd00400d00000ddddd009000bbb000dddd00aaaaaa0
0004f000ddd440000070606066600000011008888990cc00000000000040d0d0000dddd00040d0dd000dddd00400000000ddddd009000bb0000dddd0aa9999aa
00404000777000000007ff005550000001c01cc89cc01100000000000004000000ddddd00040d0d0000dddd004000000ddddddd00bbbbb0000bdddd0a999999a
07000444ddd000000006c0006660000001c1111cccc111000000000000040000ddddddd000040000000ddd000400000dddddddd0090bbb00bbbdddd0a997799a
0000000d00d0000000000c0600600000011cccc1111ccc00000000000000400ddddddddd0004000000ddddd0040000dddddddddd090bb000bbbbdddda997799a
000000f0000f00000000005000050000011cccc1111ccc00000000000000400ddd0ddddd0000400000ddddd004000dddd0ddddddb900000bbbbbbddda999999a
0000004000040000000000600006000001c1111cccc11100000000000000040ddd0d0ddd0000400000deded000000dddd0dd0dddbbb00b0bbb0b0dddaa9999aa
0000044000440000000007700077000001c1111cccc11100000000000000040ee0000ee00000040000eeee00000000ee00000ee0bbb00000bb000ee00aaaaaa0
00000000000000000000000000000000011cccc1111ccc00b000000000000000000e00000000000000000000777000000000e000a0000000000e000000000000
00000000000000000000000000000000011cccc1111ccc00b00000000000e0000eeee00000000000000e00007770e00000eeee000a0a00000eeee00000000000
0000000000000000000000000000000001c1111cccc111000000000000000eeeeeeeeee00000e0000eeee00077700eeeeeeeeeeea000aaaaaeeeeee000000000
0000000000000000000000000000000001c1111cccc1110001100000000000000ff6000000000eeeeeeeeee00400000000ff600000a000000af6000000000000
00000000000000000000000000000000011cccc1111ccc000030000077700000666f0000000000000ff60000040000000666f0000a00a0a0aa6f000000000000
00000000000000000000000000000000011cccc1111ccc00001000007770000666eeee0077700000666f00000fffee00666eee00a220000aaaeeee0000000000
0000000000000000000000000000000001c1111cccc1110000300000774000666eeede007770000666eeee000400eee666eeed0022a0a0aaaeeedd0000000000
0000000000000000000000000000000001c1111cccc111000030000000ffeeeeeeedeee0774000666eeede000400eeeeeeeddee02220a0aaaeedeee000000000
0000000000000000000000000000000001ccccc1111ccc00000000000040eeed000eeee000ffeeeeeeedeee00400ed0000deeee002000aaa000eedd000000000
0000000000000000000000000000000001ccccc1111ccc00000000000040eed0000eeed00040eeee000eeee00400000000eeeed002000aa0000ddee000000000
0000000000000000000000000000000001c1111cccc11100000000000004000000deede00040eee0000eeee004000000ddeedde00aaaaa0000aeeee000000000
0000000000000000000000000000000001c1111cccc111000000000000040000deeddee000040000000eee000400000dedddeee0020aaa00aaaeedd000000000
00000000000000000000000000000000011cccc1111ccc00000000000000400deddeeede0004000000deede0040000dddeeeedee020aa000aaaadeee00000000
00000000000000000000000000000000011cccc1111ccc00000000000000400eeeeeedee0000400000eddee004000eeeeedddeeea200000aaaaaeeee00000000
000000000000000000000000000000001cc1111cccc11110000000000000040eeddddeee00004000deeeede000000eddddeeeeeeaaa00a0aaaaaaaee00000000
00000000000000000000000000000000ccc1111cccc1111c00000000000004eeeeeeeeee00000400eedddeee000eeeeeeeeeeeeeaaa00aaaaaaaaaee00000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0101000000300003000030000300003001d3101931016310123100b3100831001310203001d3001a300173001530015300123000f3000e3000c3000a300083000530003300023000030000300003000030000300
010200001832318033186131861018610186101861018610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003461334613276131c61018610006100761007610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000151002510035100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005001050000500005000050000500005000050000500005000050000500
01020000021200d1200c210182101e210192101c6231d2001f20022200222001d2001b20016200162000f2000c2000c2000c2000c2000f2000320005200082000520003200022000020000200002000000000000
00050000286102861024411245111e611194110c1011b0011b0011d0011f00122001220011d0011b00116001160010f0010c0010c0010c0010c0010f001030010500108001050010300102001000010000100001
010200002462024627236101d1102e1102e1102e1102e1102b110271102401322013200131d0131b0131b0131b0131b0131801313013110130e0130e0130d0130b01307013060130101307003000000000000000
010200000c6130c6130c6130c613272112b2112e2112e2112e2112e2112b211272112401722017200171d0171b0171b0171b0171b0171801713017110170e0170e0170d0170b0170701706017010170000000000
0001000003010050100a0100a0100c0100c0100f0100f01011010110101301013010160101601018010180101b0101b0101d0101d0101f0101f0101f0102201024010240102701027010290102b0102e01033010
01010000090160a0160b0160d0160e0161001611016130161501617016190161b0161e016217162171625716287162c7162e7163071632716337063500637006390063a0063c0063d0063d0063d0063d00616006
010600001b0121f02222012220222401224022240122402224012220222201222022220122202227012270222701227022290122b0222b0122e0222e012300223301235022370123a0223a0123c0223c0123f022
010400001b0131f02022013220202401324020240132402024013220202201322020220132202027013270202701327020290132b0202b0132e0202e013300203301335020370133a0203a0133c0203c0133f020
010200000a0130c0130c0130f0130f0101101013010160101b0101f01024010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000016113241231b113331231b11311123221131f1231811311123111131d62320613216231060313603146031260314603176031b60323603276032c6033260338603000030000300003000030000300003
0101000017613176131161300000000000a0230a03300043006030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003b01300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002f01300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002301300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000700017200f7000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000600003c0123c0223a0123a0223a012370223701233022300122e0222e0122e0222e0122e0222e0122e0222b012270222701227022270122402224012240221f0121b0221b0121b0221b012180221801218022
010200000d6330d6230d6130a0100c0200f0100f0200f0100f02013010160201b0101d020220102402027010290202b0102b0202e0142e0262e01400026000050000000000000000000000000000000000000000
0001000000000000000d0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000010161007600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010300003f6103361027610216101e610166101442311413114230f4130f4230c4130c4232460020600206000d600206001f6000d6000d600096000d60037600336002b600206000d6000d6000d6000d60000000
010a00001f0501705014050120501005010050120500000015050000001c050000002105000000260502805025050210501d05015050140501405016050000001905000000000001e05000000230502705029050
0114002025013310130000000000310130000000000260130d0130d01300000000000000000000000000000025013310130000000000310130000000000260130d0130d013000000000000000000000000000000
011a00000c1111011210513116130c1110e6121011110113101120c111101130e111111120e1131011213111101121061310111101130e6110e113101110e11211111106120e1131011110113106130e1120d111
011a000000000000000c1121011210512116120c1120e6121011210112101120c112101120e112111120e1121011213112101121061210112101120e6120e112101120e11211112106120e112101121011210612
011a00200501509015010150000504015090150201500005020150901504015090150701509015020150401505015090150101500005040150901502015000050201509015040150901507015090150201504015
011a00000511509115011150010504115091150211500105021150911504115091150711509115021150411505115091150111500105041150911502115001050211509115041150911507115091150211504115
011a00000541509415014150040504415094150241500405024150941504415094150741509415024150441505415094150141500405044150941502415004050241509415044150941507415094150241504415
011a00000213302113001000010002113000000211300100021130211300100001000211302113021230213302133021130010000100021130000002113001000211302113001000010002113021130212300000
011a00000012300103001330010300123001030013300103001230010300133001030012300103001330010300123001030013300103001230010300133001030012300103001330010300123001030013300103
011a00200541409410014140141004414094100241402410024140941004414094100741409410024140441005414094100141401410044140941002414024100241409410044140941007414094100241404410
011a00201d4142141019424194201c414214101a4241a4201a414214101c424214201f414214101a4241c4201d4142141019424194201c414214101a4241a4201a414214101c424214201f414214101a4241c420
011a0020180151a0151c0251a0251d0151a0151c0251c0251a015180151a025180251a0151d0151a0251d0251a015180151a025180251a015180151a025180251a0151a015180251a025180151a015180251d025
011a00000011300103001130010300113001030011300103001130010300113001030011300103001130010300113001030011300103001130010300113001030011300103001130010300113001030011300103
011a002011414154100d4240d42010414154100e4240e4200e41415410104241542013414154100e4241042011414154100d4240d42010414154100e4240e4200e41415410104241542013414154100e42410420
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 1c 42 43 44
00 41 1d 43 44
00 1c 24 43 44
00 1d 42 24 44
00 1d 42 20 44
00 1e 20 43 44
00 1e 21 43 44
00 20 21 43 44
00 20 21 1e 44
00 20 21 1e 22
00 20 21 1e 22
00 1e 25 22 44
00 1e 25 43 44
00 1c 1e 43 44
00 1c 24 43 44
02 1c 42 20 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
