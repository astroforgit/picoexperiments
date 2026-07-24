pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- shooter of the death

function copy(o)
  local c
  if type(o) == 'table' then
    c = {}
    for k, v in pairs(o) do
    c[k] = copy(v)
  end
  else
    c = o
  end
  return c
end

-- buttons state
bns = {b1=false,b2=false,b3=false,b4=false,b5=false,b6=false}
bd = {b1=false,b2=false,b3=false,b4=false,b5=false,b6=false}
br = {b1=false,b2=false,b3=false,b4=false,b5=false,b6=false}
pbns = {}
pbns = bns

--debugcol = false

x_margin = 12

-- menu start
--[[
 mode values
 0 - menu start
 1 - game
 2 - win
 3 - game over
]]--
mode = 0

-- max score
-- 11 055
score = 0

-- objects
scrollsp = 0.5
timercloud = 0
allow_cloud = true

cloud = {x,y,w,h,t,s}
clouds = {}

ship = {
  hp=4,
  max_hp=4,
  -- pos
  x = 64,y = 90,
  -- speed
  vx = 0,vy = 0,
  speed_x = 2.5,speed_y = 2.5,
  speed_slow_x = 1.5,speed_slow_y = 1.5,
  -- shoot
  shooting = false,
  time_reload = 4,
  cur_timer = 0,
  max_power = 3,
  power = 1,
  max_bomb = 3,
  bomb_count = 2,
  invincible = 0,
  -- anim
  img_base = 4,
  frame_transition = 4,
  cur_speed_transition = 0,
  offset_img = 0,
  bxcol={-1,-4,0,-3},
  large_bxcol={-4,-4,3,3},
  coldebug=11
}

function ship:get_hit()
  self.hp -= 1
  self.invincible = 40
  self.power -= 1
  self.power = max(1,self.power)
  sfx(11)
  if self.hp <= 0 then
    mode = 3
  else
    local p = copy(power_up)
    p.x,p.y = ship.x-10,ship.y-15
    local b = copy(pick_up_bomb)
    b.x,b.y = ship.x+10,ship.y-15
    add(power_ups,p)
    add(power_ups,b)
  end
end

bullet = {dmg=1,x,y,vx,vy=6,img_min=7,cur_img=7,img_max=11,cur_time=0,speed=0.6,hit_sound=9,bxcol={-2,-3,1,2},coldebug=12}

bullet_enmy_low = copy(bullet)
bullet_enmy_low.cur_img,bullet_enmy_low.bxcol = 72,{-1,-1,0,0}

bullet_enmy_med = copy(bullet_enmy_low)
bullet_enmy_med.cur_img,bullet_enmy_med.bxcol = 73,{-2,-2,1,1}

bullet_enmy_high = copy(bullet_enmy_med)
bullet_enmy_high.cur_img,bullet_enmy_high.bxcol = 74,{-1,-3,0,2}

bullets = {}
bullet_enmies = {}


bomb = {dmg=100,x,y,vy=1,img_min=18,cur_img=18,img_max=29,cur_time=0,speed=0.4}
bombs = {}


text = {text,t=0,time_max=30,col=1,cols={7,15,14,8,2,1,3,11,12,6},x,y}
texts = {}


power_up = {x,y,vy=0.3,cur_img=112,img_min=112,img_max=127,speed=0.8,time_life=200,time_blink=80,sound=8,bxcol={-4,-4,3,4},coldebug=11}
function power_up:pick_up()
  ship.power += 1
  ship.power = min(ship.power,3)
  local st = "power"
  if ship.power == ship.max_power then
    st = "max"
  end
  create_text(st,ship.x+4,ship.y-4)
end

pick_up_bomb = copy(power_up)
pick_up_bomb.cur_img,pick_up_bomb.img_min,pick_up_bomb.img_max = 96,96,111
function pick_up_bomb:pick_up()
  ship.bomb_count += 1
  ship.bomb_count = min(ship.max_bomb,ship.bomb_count)
  local st = "+1"
  if ship.bomb_count == ship.max_bomb then
    st = "max"
  end
  create_text(st,ship.x+4,ship.y-4)
end

pick_up_heal = copy(power_up)
pick_up_heal.cur_img,pick_up_heal.img_min,pick_up_heal.img_max = 80,80,95
function pick_up_heal:pick_up()
  ship.hp += 1
  ship.hp = min(ship.max_hp,ship.hp)
  local st = "heal"
  if ship.hp == ship.max_hp then
    st = "max hp"
  end
  create_text(st,ship.x+4,ship.y-4)
end

power_ups = {}

-- follow pattern of points
-- shooting at player
enmy_low = {hp=2,score=20,droprate=0.2,x,y,index_pt=1,lerp_pt=0,pts={},speed_lerp,img=66,time_reload=45,force=1.5,cur_time=0,sound=9,bullet=bullet_enmy_low,bxcol={-4,-2,3,3},get_hit=false,coldebug=8}
function enmy_low:shoot()
  self.cur_time = 0
  local bul = copy(self.bullet)
  local vec = {x=ship.x-self.x, y=(ship.y-3)-self.y}
  local length = sqrt(vec.x*vec.x + vec.y*vec.y)
  bul.x,bul.y,bul.vx,bul.vy = self.x,self.y,vec.x*self.force/length,vec.y*self.force/length
  add(bullet_enmies,bul)
end

enmy_med = copy(enmy_low)
enmy_med.hp,enmy_med.score,enmy_med.droprate,enmy_med.img,enmy_med.time_reload,enmy_med.force,enmy_med.bullet,enmy_med.bxcol = 16,100,0.5,68,60,3,bullet_enmy_med,{-4,-3,3,3}

enmy_high = copy(enmy_low)
enmy_high.hp,enmy_high.score,enmy_high.droprate,enmy_high.img,enmy_high.time_reload,enmy_high.force,enmy_high.bullet,enmy_high.bxcol = 6,50,0.3,70,15,5.5,bullet_enmy_high,{-4,-4,3,3}
function enmy_high:shoot()
  if abs(self.x-ship.x) <= 1 then
    self.cur_time = 0
    local bul = copy(self.bullet)
    bul.x,bul.y,bul.vx,bul.vy = self.x,self.y,0,self.force
    add(bullet_enmies,bul)
  end
end


enmies = {}
spawner_enmies = {
  frames = 15,
  timer = 0
}

-- oscillation
l1={-10,15, 20,25, 50,15, 80,25, 110,15, 140,25}
l2={-10,35, 20,45, 50,35, 80,45, 110,35, 140,45}
l9={140,25, 110,15, 80,25, 50,15, 20,25, -10,15}
l10={140,45, 110,35, 80,45, 50,35, 20,45, -10,35}

-- curves on side
l3={2,10, 27,20, 42,35, 57,55, 42,75, 27,90, 2,100}
l4={125,10, 100,20, 85,35, 70,55, 85,75, 100,90, 125,100}
-- diagonals
l5={-10,5, 30,22, 64,40, 97,63, 137,90}
l6={137,5, 97,22, 64,40, 30,63, -10,90}
-- vertical line
l7={45,-10, 45,27, 45,64, 45,101, 45,137}
l8={83,-10, 83,27, 83,64, 83,101, 83,137}
-- zig zag

--    from side to middle screenm do a circle and go the other side
--    zig zag going down on screen
-- total : eleven

step = {cur_start_time=0,enmy=nil,nb=0,cur_nb=0,time_max=0,cur_time=0,speed_enmy=0,pattern=nil}
function step:start_step()
end
function step:update_step()
    if self.cur_time <= 0 and self.cur_nb < self.nb then
      local e = copy(self.enmy)
      e.speed_lerp = self.speed_enmy
      e.pts = self.pattern
      add(enmies,e)
      self.cur_time = self.time_max
      self.cur_nb += 1
    else
      self.cur_time -= 1
    end
end
function step:end_step()
  self.cur_nb = 0
  self.cur_time = 0
end
function step:isfinished_step()
  return self.cur_nb >= self.nb
end

step_multiple = {cur_start_time=100,step1=nil,step2=nil,delay_step_1=0,frames_step_1=0,delay_step_2=0,frames_step_2=0}
function step_multiple:start_step()
end
function step_multiple:update_step()
  if self.frames_step_1 >= self.delay_step_1 then
    self.step1:update_step()
  else
    self.frames_step_1 += 1
  end
  if self.frames_step_2 >= self.delay_step_2 then
    self.step2:update_step()
  else
    self.frames_step_2 += 1
  end
end
function step_multiple:end_step()
  self.step1:end_step()
  self.step2:end_step()
  frames_step_1 = 0
  frames_step_2 = 0
end
function step_multiple:isfinished_step()
  return self.step1:isfinished_step() and self.step2:isfinished_step()
end


step_tuto = copy(step)
step_tuto.cur_start_time = 50
step_tuto.enmy = enmy_low
step_tuto.nb = 3
step_tuto.time_max = 30
step_tuto.speed_enmy = 0.03
step_tuto.pattern = l9

step_1 = copy(step_tuto)
step_1.nb = 6
step_1.cur_start_time = 100
step_1.pattern = l1

step_2 = copy(step_multiple)
step_2.step1 = copy(step_1)
step_2.step1.pattern = l9
step_2.step2 = copy(step_1)
step_2.step2.pattern = l2


step_3 = copy(step_1)
step_3.enmy = enmy_high
step_3.nb = 4
step_3.pattern = l1

step_4 = copy(step_3)
step_4.pattern = l6

step_5 = copy(step_4)
step_5.pattern = l5

step_7 = copy(step_multiple)
step_7.step1 = copy(step_3)
step_7.step1.nb = 6
step_7.step2 = copy(step_1)
step_7.step2.nb = 4
step_7.step2.pattern = l7

step_6 = copy(step_7)
step_6.step2.pattern = l8
step_6.step2.delay_step_2 = 160

step_8 = copy(step_2)
step_8.step1.pattern = l3
step_8.step1.nb = 7
step_8.step2.pattern = l4
step_8.step2.nb = 7

step_9 = copy(step_1)
step_9.enmy = enmy_med
step_9.nb = 4
step_9.speed_enmy = 0.02

step_10 = copy(step_1)
step_10.cur_start_time = 150
step_10.nb = 10
step_10.speed_enmy = 0.04
step_10.time_max = 15
step_10.enmy.time_reload = 15
step_10.pattern = l5

step_11 = copy(step_10)
step_11.cur_start_time = 50
step_11.pattern = l6

step_12 = copy(step_2)
step_12.step1 = copy(step_10)
step_12.step1.pattern = l3
step_12.step1.time_max = 30
step_12.step2 = copy(step_10)
step_12.step2.pattern = l4
step_12.step2.time_max = 30

step_13 = copy(step_2)
step_13.step1.enmy = enmy_high

step_14 = copy(step_2)
step_14.step1.pattern = l1
step_14.step1.enmy = enmy_med
step_14.step2.pattern = l10

step_15 = copy(step_2)
step_15.step1.pattern = l5
step_15.step1.enmy = enmy_high
step_15.step1.speed_enmy = 0.02
step_15.step2.pattern = l6
step_15.step2.enmy = enmy_high
step_15.step2.speed_enmy = 0.02

step_16 = copy(step_15)
step_16.step1.enmy = enmy_low
step_16.step1.nb = 25
step_16.step2.enmy = enmy_low
step_16.step2.nb = 25

step_17 = copy(step_1)
step_17.enmy = enmy_med
step_17.nb = 8
step_17.pattern = l7
step_17.speed_enmy = 0.02

step_18 = copy(step_17)
step_18.pattern = l8

step_19 = copy(step_1)
step_19.nb = 20
step_19.time_max = 10
step_19.enmy.time_reload = 10

step_20 = copy(step_14)
step_20.step2.enmy = enmy_high
step_20.step1.speed_enmy = 0.02
step_20.step2.speed_enmy = 0.02

step_21 = copy(step_8)
step_21.step1.enmy = enmy_med
step_21.step1.nb = 10
step_21.step1.speed_enmy = 0.02
step_21.step2.enmy = enmy_med
step_21.step2.nb = 10
step_21.step2.speed_enmy = 0.02

-- complete all steps
-- step_phase1 = copy(step_tuto)
-- step_phase1.cur_start_time = 100
-- step_phase1.nb = 5
-- step_phase1.speed_enmy = 0.04
-- step_phase1.pattern = l1

-- step_phase2 = copy(step_phase1)
-- step_phase2.cur_start_time = 80
-- step_phase2.pattern = l5

-- step_phase3 = copy(step_phase2)
-- step_phase3.pattern = l6
-- step_phase3.speed_enmy = 0.06

-- boss fight
boss = {
 hp=1,
 max_hp=2200,
 can_draw=false,
 draw_alert=false,
 alert_frames=0,
 invincible=true,
 get_hit=false,
 x=64,
 y=0,
 vx=1,
 vy=0.1,
 sx=48,
 sy=96,
 sw=40,
 sh=31,
 scale_factor=0,
 bullet_1=nil,
 angle_start=0,
 bxcol={{-37,-16,-10,16},{10,-16,37,16},{-40,-31,40,-6}}
}
boss_x_r,boss_y_r = 40,50
boss_x_l,boss_y_l = 90,50

boss.bullet_1 = copy(bullet_enmy_med)

function boss:shoot_pattern_2(speed,angle_step,x,y)
  if x == nil then x = self.x end
  if y == nil then y = self.y end
  if speed == nil then speed = 1 end
  if angle_step == nil then angle_step = 16 end
  
  for i=0,angle_step do
    local p = self.angle_start + (i/angle_step)
    local b = copy(self.bullet_1)
    b.x=x
    b.y=y
    b.vx = cos(p) * speed
    b.vy = sin(p) * speed
    add(bullet_enmies,b)
  end
end

function boss:shoot_pattern_3(speed,angle_step,x,y)
  if x == nil then x = self.x end
  if y == nil then y = self.y end
  if speed == nil then speed = 1 end
  if angle_step == nil then angle_step = 8 end
  
  for i=0,angle_step do
    for j=0,4 do
      
      local s = (j/4) * 0.05
      local p = s + self.angle_start + (i/angle_step)
      local b = copy(self.bullet_1)
      b.x=x
      b.y=y
      b.vx = cos(p) * speed
      b.vy = sin(p) * speed
      add(bullet_enmies,b)
    
    end
  end
end

function boss:shoot_pattern_4(speed)
  if speed == nil then speed = 0.8 end
  
  for i=0,1 do
    local b1 = copy(self.bullet_1)
    b1.x,b1.y=boss.x-27+i*5,boss.y+12+i*5
    b1.vx,b1.vy = 0,speed
    add(bullet_enmies,b1)
     
    local b2 = copy(self.bullet_1)
    b2.x,b2.y=boss.x+22+i*5,boss.y+12+(1-i)*5
    b2.vx,b2.vy = 0,speed
    add(bullet_enmies,b2)
  end
  
end

step_pre_boss = copy(step)
step_pre_boss.duration = 20
step_pre_boss.cur_start_time = 100
function step_pre_boss:start_step()
  music(-1,1000)
  local h1 = copy(pick_up_heal)
  h1.x,h1.y = 45,60
  local h2 = copy(pick_up_heal)
  h2.x,h2.y = 128-45,60
  
  add(power_ups,h1)
  add(power_ups,h2)
end
function step_pre_boss:update_step()
  self.duration -= 1
end
function step_pre_boss:end_step()
end
function step_pre_boss:isfinished_step()
  return self.duration <= 0
end

step_boss_intro = copy(step)
step_boss_intro.cur_start_time = 50
function step_boss_intro:start_step()
end
function step_boss_intro:update_step()
    boss.can_draw = true
    -- going down
    boss.y += boss.vy
    -- zoom in
    boss.scale_factor += 0.0057
    -- hp up
    boss.hp += 8
    
    boss.hp = min(boss.max_hp,boss.hp)
    
    if boss.alert_frames%60 <= 20 then
      boss.draw_alert = true
      if stat(16) != 48 then
        music(19,100,1)
      end
    else
      boss.draw_alert = false
      if stat(16) == 48 then
        music(-1,100,1)
      end
    end
    
    boss.alert_frames += 1
end
function step_boss_intro:end_step()
  boss.draw_alert = false
  music(-1,10)
  boss.invincible = false
  boss.scale_factor = 2
  boss.hp = boss.max_hp
  boss.invincible = false
  music(8,500,7)
  allow_cloud = false
end
function step_boss_intro:isfinished_step()
  -- end when boss is on position
  return boss.y >= 35
end

step_boss_1 = copy(step)
step_boss_1.cur_start_time = 60
step_boss_1.nb_patterns = 1
step_boss_1.init_nb_patterns = 7
step_boss_1.time_patterns = 10
step_boss_1.frames_counter = 0
function step_boss_1:action()
  boss:shoot_pattern_2()
end
function step_boss_1:start_step()
  self.frames_counter = 0
  self.nb_patterns = self.init_nb_patterns
  boss.angle_start = 0
end
function step_boss_1:update_step()
    -- do things
    if self.frames_counter >= self.time_patterns then
      self.frames_counter = 0
      self:action()
      self.nb_patterns -= 1
    end
    self.frames_counter += 1
end
function step_boss_1:end_step()
  self.nb_patterns = self.init_nb_patterns
end
function step_boss_1:isfinished_step()
  -- finish nb patterns
  return self.nb_patterns <= 0 or boss.hp <= 0
end

step_boss_multiple = copy(step_boss_1)
step_boss_multiple.p1 = copy(step_boss_1)
step_boss_multiple.p2 = copy(step_boss_1)
step_boss_multiple.cur_start_time = 30
function step_boss_multiple:action()
  self.p1:action()
  self.p2:action()
end
function step_boss_multiple:start_step()
  self.p1:start_step()
  self.p2:start_step()
end
function step_boss_multiple:update_step()
  self.p1:update_step()
  self.p2:update_step()
end
function step_boss_multiple:end_step()
  self.p1:end_step()
  self.p2:end_step()
end
function step_boss_multiple:isfinished_step()
  -- finish nb patterns
  return self.p1:isfinished_step() and self.p2:isfinished_step()
end

step_boss_2 = copy(step_boss_1)
step_boss_2.cur_start_time = 30
step_boss_2.init_nb_patterns = 7
function step_boss_2:action()
  boss:shoot_pattern_2(1,32)
end

step_boss_3 = copy(step_boss_multiple)
step_boss_3.p1.init_nb_patterns = 7
step_boss_3.p2.init_nb_patterns = 7
function step_boss_3.p1:action()
  boss:shoot_pattern_2(1,16,boss_x_r,boss_y_r)
end
function step_boss_3.p2:action()
  boss:shoot_pattern_2(1,16,boss_x_l,boss_y_l)
end

step_boss_4 = copy(step_boss_2)
step_boss_4.init_nb_patterns = 10
function step_boss_4:action()
  boss:shoot_pattern_2()
  boss.angle_start += 0.9
end

step_boss_5 = copy(step_boss_3)
function step_boss_5.p1:action()
  boss:shoot_pattern_2(1,16,boss_x_r,boss_y_r)
  boss.angle_start += 0.9
end
function step_boss_5.p2:action()
  boss:shoot_pattern_2(1,16,boss_x_l,boss_y_l)
  boss.angle_start += 0.9
end

step_boss_6 = copy(step_boss_2)
function step_boss_6:action()
  boss:shoot_pattern_2(1,32)
  boss.angle_start += 0.9
end

step_boss_7 = copy(step_boss_2)
step_boss_7.init_nb_patterns = 12
function step_boss_7:action()
  boss:shoot_pattern_2(1.5,16)
  boss.angle_start += 0.9
end

step_boss_8 = copy(step_boss_2)
step_boss_8.init_nb_patterns = 9
function step_boss_8:action()
  boss:shoot_pattern_3()
  boss.angle_start += 0.9
end

step_boss_9 = copy(step_boss_8)
function step_boss_9:action()
  boss:shoot_pattern_3()
  boss.angle_start -= 0.9
end

step_boss_10 = copy(step_boss_2)
step_boss_10.init_nb_patterns = 15
step_boss_10.time_patterns = 5
function step_boss_10:action()
  boss:shoot_pattern_4()
end

step_boss_11 = copy(step_boss_3)
step_boss_11.p1.time_patterns = 25
step_boss_11.p2.time_patterns = 25
step_boss_11.p1.init_nb_patterns = 6
step_boss_11.p2.init_nb_patterns = 6
function step_boss_11.p1:action()
  boss:shoot_pattern_3(0.85,8,boss_x_r,boss_y_r)
  boss.angle_start += 0.9
end
function step_boss_11.p2:action()
  boss:shoot_pattern_3(0.85,8,boss_x_l,boss_y_l)
  boss.angle_start += 0.9
end

step_boss_12 = copy(step_boss_3)
step_boss_12.p1.init_nb_patterns = 35
step_boss_12.p1.time_patterns = 5
function step_boss_12.p1:action()
  boss:shoot_pattern_4(1.5)
end
function step_boss_12.p2:action()
  boss:shoot_pattern_2(1,32)
end

step_boss_13 = copy(step_boss_12)
function step_boss_13.p2:action()
  boss:shoot_pattern_2()
  boss.angle_start += 0.9
end

step_boss_14 = copy(step_boss_13)
step_boss_14.p2.time_patterns = 17
function step_boss_14.p2:action()
  boss:shoot_pattern_3()
  boss.angle_start -= 0.9
end

step_boss_15 = copy(step_boss_3)
step_boss_15.p1.init_nb_patterns = 25
step_boss_15.p2.init_nb_patterns = 25
step_boss_15.p2.time_patterns = 15
function step_boss_15.p1:action()
  boss:shoot_pattern_2(1.5)
  boss.angle_start += 0.9
end
function step_boss_15.p2:action()
  local a = boss.angle_start
  boss.angle_start = 0
  boss:shoot_pattern_2(2.2)
  boss.angle_start = a
end

step_boss_16 = copy(step_boss_15)
step_boss_16.p1.time_patterns = 15
step_boss_16.p2.time_patterns = 20 
function step_boss_16.p1:action()
  boss:shoot_pattern_3(1.1)
  boss.angle_start += 0.9
end

step_index=1
step_frames=0
step_start_done=false
story = {steps={
step_tuto,
step_1,step_2,step_3,step_4,step_5,step_6,step_7,step_8,step_9,step_10,step_11,step_12,step_13,step_14,step_15,step_16,step_17,step_18,step_19,step_20,
step_21,
step_pre_boss,
step_boss_intro,
step_boss_1,
step_boss_2,
step_boss_3,
step_boss_4,
step_boss_5,
step_boss_6,
step_boss_7,
step_boss_8,
step_boss_9,
step_boss_10,
step_boss_11,
step_boss_15,
step_boss_16,
step_boss_12,
step_boss_13,
step_boss_14,
step_boss_1}} -- sequence of steps

function story:start()
  self.steps[step_index]:start_step()
  step_start_done = true
end
function story:update()
  if step_frames >= self.steps[step_index].cur_start_time then
    if self.steps[step_index]:isfinished_step() then
      if self.steps[step_index+1] != nil then
        self.steps[step_index]:end_step()
        step_index += 1
        step_frames = 0
        step_start_done = false
      else
        -- repeat boss pattern
        step_index = 5
        -- 25
      end
    else
      if not step_start_done then
        self.steps[step_index]:start_step()
        step_start_done=true
      else
        self.steps[step_index]:update_step()
      end
    end
  else
    step_frames += 1
  end
end

ps = {img,size,x,y,vx,vy,drag,cols,cole,col,tcol,ts,t}
particles = {}

shkcam = {}


-- menu vars
start_selection = 1
pos_y_new_game = 80
pos_y_settings = 90
pos_x_settings_box = 50
timer_menu = 0
menu_sel=9

y_band_up=0
y_band_down=127
ymax_band_up=24
ymax_band_down=103
--speed_band=0.19
speed_band=5.5

x_title_front=-120
x_title_middle=-240
x_title_back=-360
xmax_title_front=9
xmax_title_middle=8
xmax_title_back=7
--speed_title=2.8
speed_title=60

timer_clear_game_over = 0
wait_clear_game_over = 50

timer_game_over = 0
wait_game_over = 60

song_game_over_played = false

timer_end_game_1 = 0
wait_end_game_1 = 200
timer_end_game_2 = 0
wait_end_game_2 = 80

done_music_end = false

ghost_mode = false

last_time = 0
dt = 0

function _init()
  story:start()
  music(0,1000)
  last_time = time()
end

function _update()

  dt = time() - last_time
  last_time = time()
  
  -- get button state
		for i=0,5 do
		  if btn(i) != bns[i] then
		    bns[i] = btn(i)
		    if bns[i] then
		      bd[i],br[i] = true,false
		    else
		      bd[i],br[i] = false,true
		    end
    else
      bd[i],br[i] = false,false
    end
  end
  
  if mode == 0 then
  -- update menu
    
    speed_color = sin(timer_menu)*0.3
    timer_menu += 0.01
    if timer_menu >= 1 then
      timer_menu -= 1
    end
    
    -- update band menu
    if y_band_up < ymax_band_up then
      y_band_up += speed_band * dt
    else
      y_band_up = ymax_band_up
    end

    if y_band_down > ymax_band_down then
      y_band_down -= speed_band * dt
    else
      y_band_down = ymax_band_down
    end

    if y_band_up == ymax_band_up and y_band_down == ymax_band_down then
      -- update title menu
      if x_title_front < xmax_title_front then
        x_title_front += speed_title * dt
      else
        x_title_front = xmax_title_front
      end

      if x_title_back < xmax_title_back then
        x_title_back += speed_title * dt
      else
        x_title_back = xmax_title_back
      end

      if x_title_middle < xmax_title_middle then
        x_title_middle += speed_title * dt
      else
        x_title_middle = xmax_title_middle
      end
    end
    
    -- when last title arrives
    if x_title_back == xmax_title_back then
      local cp = 12
		    if start_selection == 2 then
		      pstart(nil,1,1,4,12,41,pos_y_settings-1, -1,-0.5, 0.1,0.8, 1.05,menu_sel,menu_sel,1)
		      pstart(nil,1,1,4,12,41,pos_y_settings+6, -1,-0.5, -0.8,-0.1, 1.05,menu_sel,menu_sel,1)
		      pstart(nil,1,1,4,12,86,pos_y_settings-1, 0.5,1, 0.1,0.8, 1.05,menu_sel,menu_sel,1)
		      pstart(nil,1,1,4,12,86,pos_y_settings+6, 0.5,1, -0.8,-0.1, 1.05,menu_sel,menu_sel,1)
		      --pstart(nil,0,4,4,6,40,pos_y_settings+5, -1,-0.5, 0,-0.5,   1.05,0,0,1)
		    elseif start_selection == 1 then
		      pstart(nil,1,1,4,12,41,pos_y_new_game-1, -1,-0.5, 0.1,0.8, 1.05,menu_sel,menu_sel,1)
		      pstart(nil,1,1,4,12,41,pos_y_new_game+6, -1,-0.5, -0.8,-0.1, 1.05,menu_sel,menu_sel,1)
		      pstart(nil,1,1,4,12,86,pos_y_new_game-1, 0.5,1, 0.1,0.8, 1.05,menu_sel,menu_sel,1)
		      pstart(nil,1,1,4,12,86,pos_y_new_game+6, 0.5,1, -0.8,-0.1, 1.05,menu_sel,menu_sel,1)
		    end
      
      pstart(nil,rnd(8),6,8,12,rnd(127),20 + rnd(107),-rnd(8),rnd(8),-rnd(3),rnd(3),1.05,rnd(15),rnd(15),0.5)   
    
		    if bd[2] then
		      start_selection = 1
		      sfx(18)
		    end
		    if bd[3] then
		      start_selection = 2
		      sfx(18)
		    end
		
		    if bd[4] then
		      if start_selection == 1 then
		        mode = 1
		        particles = {}
		        sfx(17)
          music(13, 100)
		      elseif start_selection == 2 then
		        ghost_mode = not ghost_mode
		        sfx(17)
		      end
		    end
    else
      if bd[4] then
        y_band_up = ymax_band_up
        y_band_down = ymax_band_down
        x_title_front = xmax_title_front
        x_title_back = xmax_title_back
        x_title_middle = xmax_title_middle
      end
    end


  elseif mode == 1 then
    -- update game logic

    story:update()
    
    -- generate new cloud
    timercloud-=1
  		if timercloud<=0 and allow_cloud then
  		  local c=copy(cloud)
  		  generatecloud(c)
  		  add(clouds,c)
  		  timercloud= 4 * #clouds + rnd"64"
  		end

    -- move ship
    ship.invincible -= 1
    if ship.invincible < 0 then
      ship.invincible = 0
    end
    
    local sx = ship.shooting and ship.speed_slow_x or ship.speed_x
    local sy = ship.shooting and ship.speed_slow_y or ship.speed_y

    ship.vy = btn(3) and sy or 0
    ship.vy = btn(2) and -sy or ship.vy
    ship.vx = btn(0) and -sx or 0
    ship.vx = btn(1) and sx or ship.vx
    
    ship.y += ship.vy
    ship.x += ship.vx
    
    ship.x=clmp(ship.x,x_margin+4,128-x_margin-4)
    ship.y=clmp(ship.y,0,128)
   
    animship()

    -- smoke ship
    local offset_x = 4 - abs(ship.offset_img)
    if ship.invincible == 0 then
      pstart(nil,0,1,3,5,ship.x+offset_x,ship.y-1,-0.1,0.5,0.3,0.8,1.05,6,7,0.5)
      pstart(nil,0,1,3,5,ship.x-offset_x,ship.y-1,-0.5,0.1,0.3,0.8,1.05,6,7,0.5)
    else
      pstart(nil,0,1,3,5,ship.x+offset_x,ship.y-1,-0.1,0.5,0.3,0.8,1.05,9,8,0.5)
      pstart(nil,0,1,3,5,ship.x-offset_x,ship.y-1,-0.5,0.1,0.3,0.8,1.05,9,8,0.5)
    end
    
    -- update boos
    boss.get_hit = false
    
    -- move enmies
    for e in all(enmies) do
      if e.hp <= 0 then
        pstart(nil,3,8,4,6,e.x,e.y,-3,3,-6,-2,1.2,6,5,0.4)
        pstart(nil,5,3,3,5,e.x,e.y,-2,2,-4,-2,1.2,7,6,0.7)
        sfx(e.sound)
        
        if rnd(1) < e.droprate/ship.power then
          local drop = nil
          if ship.hp < ship.max_hp then
            drop = copy(pick_up_heal)
          elseif ship.bomb_count/ship.max_bomb < ship.power/ship.max_power then
            drop = copy(pick_up_bomb)
          else
            drop = copy(power_up)
          end
          drop.x,drop.y = e.x,e.y
          add(power_ups,drop)
        end
        
        score += e.score
        
        del(enmies,e)
      else
        e.get_hit = false
        if e.index_pt+2 < #e.pts then
          e.x=lerp(e.lerp_pt,e.pts[e.index_pt],e.pts[e.index_pt+2])
          e.y=lerp(e.lerp_pt,e.pts[e.index_pt+1],e.pts[e.index_pt+3])
          e.lerp_pt += e.speed_lerp
          if e.lerp_pt >= 1 then
            e.lerp_pt=0
            e.index_pt+=2
          end
        else
          del(enmies,e)
        end
      end
      e.cur_time+=1
      if e.cur_time > e.time_reload and e.x > 4+x_margin and e.x < 124-x_margin and e.y > 4 and e.y < 124 then
        e:shoot()
      end
    end

    -- update bullets
    for v in all(bullets) do
      v.y -= v.vy
      v.cur_img += v.speed 
      if v.cur_img>v.img_max then v.cur_img=v.img_min end
      if v.y < -8 then del(bullets,v) end
    end

    -- update bullet enmies
    for v in all(bullet_enmies) do
      v.x += v.vx
      v.y += v.vy
      if v.y < -8 or v.y > 136 or v.x < -8+x_margin or v.x > 136-x_margin then del(bullet_enmies,v) end
    end
    
    -- update bombs
    for b in all(bombs) do
      b.y -= b.vy
      b.vy /= 1.05
      b.cur_img += b.speed
      if b.cur_img>b.img_max then
        b.cur_img=b.img_max-1
        pstart(nil,1,70,12,18,b.x,b.y+5,-6,6,-6,6,1.05,7,6,0.5)
        pstart(nil,8,40,10,18,b.x,b.y+5,-6,6,-6,6,1.1,9,4,0.2)
        pstart(nil,10,15,8,15,b.x,b.y+5,-4,4,-4,4,1.1,8,2,0.2)
        local c = cocreate(shake)
        add(shkcam, {c,8,8,0.9})
        del(bombs,b)  
        for e in all(enmies) do
          e.hp -= b.dmg
        end
        if not boss.invincible then
          boss.hp -= b.dmg
        end
        for b in all(bullet_enmies) do
          del(bullet_enmies,b)
        end
      end
    end
    
    -- shoot bullets ship
    ship.cur_timer -= 1
    ship.shooting = btn(4)
    if ship.shooting then
      if ship.cur_timer <= 0 then
        local offset_y = ship.y-8
        local b1,b2,b3,b4 = copy(bullet),copy(bullet),copy(bullet),copy(bullet)
        if ship.power == 1 then
          b1.x,b1.y = ship.x,offset_y
          add(bullets,b1)
        elseif ship.power == 2 then
          b1.x,b1.y,b2.x,b2.y = ship.x-3,offset_y,ship.x+3,offset_y
          add(bullets,b1)
          add(bullets,b2)
        else
          b1.x,b1.y,b2.x,b2.y,b3.x,b3.y,b4.x,b4.y = ship.x-3,offset_y,ship.x+3,offset_y,ship.x-8,offset_y+4,ship.x+8,offset_y+4
          add(bullets,b1)
          add(bullets,b2)
          add(bullets,b3)
          add(bullets,b4)
        end
        
        ship.cur_timer = ship.time_reload
        --local c = cocreate(shake)
        --add(shkcam, c)
        pstart(nil,0,20,5,10,ship.x,ship.y-4,-0.8+ship.vx,0.8+ship.vx,-2+ship.vy,-1+ship.vy,1.1,9,4,0.2)
        sfx(1)  
      end
    end
    
    -- shoot bombs ship
    if bd[5] and ship.bomb_count > 0 then
      sfx(3)
      ship.bomb_count -= 1
      local b = copy(bomb)
      b.x,b.y = ship.x,ship.y-12
      add(bombs, b)
    end
    
    -- move pick-ups
  		for p in all(power_ups) do
  		  p.time_life -= 1
  		  if p.time_life <= 0 then
  		    del(power_ups,p)
  		  else
  		    if p.y < 110 then
  		      p.y += p.vy
  		    end
  		    if p.x < 15 then
  		      p.x += 0.5
  		    elseif p.x > 115 then
  		      p.x -= 0.5
  		    end
  		    p.cur_img += p.speed 
        if p.cur_img>p.img_max then p.cur_img=p.img_min end
  		  end
  		end
  		
  		-- update text power
  		for p in all(texts) do
      p.col += 0.5
      if p.col > #p.cols+1 then p.col = 0 end
      p.t += 1
      if p.t > p.time_max then
        del(texts,p)
      end
  		end
    
    -- coroutines shake cam
    for c in all(shkcam) do
      if costatus(c[1]) then
        coresume(c[1], c[2], c[3], c[4])
      else
        del(shkcam, c)
      end
    end
    
    
    -- -- collisions -- --
    
    -- detect collisions
    -- bullet player on enmies
    for b in all(bullets) do
      for e in all(enmies) do
        if iscolinsides(b.x,b.y,b.bxcol,e.x,e.y,e.bxcol) then
          e.hp -= b.dmg
          del(bullets,b)
          e.get_hit = true
          sfx(b.hit_sound)
          pstart(nil,0,4,3,6,b.x,b.y,-1.5,1.5,-1.5,1.5,1.1,7,6,0.5)
        end
      end
      if not boss.invincible then
        for bx in all(boss.bxcol) do
          if iscolinsides(b.x,b.y,b.bxcol,boss.x,boss.y,bx) then
            boss.hp -= b.dmg
            del(bullets,b)
            boss.get_hit = true
            -- check if not too much noise
            --sfx(b.hit_sound)
            pstart(nil,0,4,3,6,b.x,b.y,-1.5,1.5,-1.5,1.5,1.1,7,6,0.5)
          end
        end
      end
    end
    
    -- bullet enmies on player
    for b in all(bullet_enmies) do
      if ship.invincible == 0 and iscolinsides(b.x,b.y,b.bxcol,ship.x,ship.y,ship.bxcol) then
        ship:get_hit()
        pstart(nil,1,8,4,8,b.x,b.y,b.vx-0.5,b.vx+0.5,b.vy,b.vy+1,1.05,9,10,0.3)
        del(bullet_enmies,b)
      end
    end
    
    -- enmies on player
    for e in all(enmies) do
      if ship.invincible == 0 and iscolinsides(e.x,e.y,e.bxcol,ship.x,ship.y,ship.bxcol) then
        ship:get_hit()
      end
    end
    
    -- boss on player
    if ship.invincible == 0 and not boss.invincible then
      for b in all(boss.bxcol) do
        if iscolinsides(boss.x,boss.y,b,ship.x,ship.y,ship.bxcol) then
          ship:get_hit()
        end
      end
    end
    
    -- pick up with player
    for p in all(power_ups) do
      if iscolinsides(p.x,p.y,p.bxcol,ship.x,ship.y,ship.large_bxcol) then
        p.pick_up()
        pstart(nil,1,8,3,6,p.x,p.y,-1,1,-1,1,1.05,11,7,0.2)
        sfx(p.sound)
        score += 5
        del(power_ups,p)
      end
    end
  
    if boss.hp <= 0 then
      bullet_enmies = {}
      music(-1,200)
      boss.hp = 0
      boss.invincible = true
      
      if timer_end_game_1 % 3 == 0 and timer_end_game_1 != wait_end_game_1 then
        local sz,nb=2+rnd(12),5+rnd(15)
        local tmi=4+rnd(5)
        local tma=tmi+3+rnd(5)
        local x,y=35+rnd(58),10+rnd(40)
        local cols,cole=6,5

        local i = rnd(1)
        if i <= 0.35 then
          cols = 8
          cole = 2
        elseif i <= 0.7 then
          cols = 9
          cole = 4
        end
        pstart(nil,sz,nb,tmi,tma,x,y,-2,2,-2,2,1.1,cols,cole,0.5)
      end
      if timer_end_game_1 % 6 == 0 and timer_end_game_1 != wait_end_game_1 then
        if rnd(1) < 0.3 then
          sfx(4)
        else
          sfx(2)
        end
        local c = cocreate(shake)
        add(shkcam, {c,2,2,0.9})
      end
      -- particles explosion
      -- sounds eplode
      
      -- score + anim
      
      timer_end_game_1 += 1
      
      if timer_end_game_1 >= wait_end_game_1 then
        timer_end_game_1 = wait_end_game_1
        
        -- destroyed boss going down
        boss.scale_factor = 2-(2*timer_end_game_2/wait_end_game_2)
        
        timer_end_game_2 += 1
        if timer_end_game_2 > wait_end_game_2 then
          mode = 2
          timer_end_game_2 = wait_end_game_2
        end
      end
    end
  
  elseif mode == 2 then
  
    if not done_music_end then
      music(3,1000)
      done_music_end = true
    end
  
    -- win screen
      
    -- thx screen + score
      
    -- restart
    scrollsp = 0.3
    
    timercloud-=1
  		if timercloud<=0 and allow_cloud then
  		  local c=copy(cloud)
  		  generatecloud(c)
  		  add(clouds,c)
  		  timercloud= 4 * #clouds + rnd"64"
  		end
  		
    ship.x = 50 + sin(time()/15) * 30
    ship.y = 100 + sin(time()/6) * 8
    
    local offset_x = 4 - abs(ship.offset_img)
    pstart(nil,0,1,3,5,ship.x+offset_x,ship.y-1,-0.1,0.5,0.3,0.8,1.05,6,7,0.5)
    pstart(nil,0,1,3,5,ship.x-offset_x,ship.y-1,-0.5,0.1,0.3,0.8,1.05,6,7,0.5)
    
    -- preotection for misclick
    if bd[5] or bd[4] then
      load("shooter.p8")
    end
    
  elseif mode == 3 then
    
    step_index = 1
    music(-1, 100)
    
    timer_clear_game_over += 1
    if timer_clear_game_over >= wait_clear_game_over then
      if not song_game_over_played then
        sfx(15)
        song_game_over_played = true
      end
      timer_game_over += 1
    end
   
    
    if timer_game_over >= wait_game_over then
      timer_game_over = wait_game_over
      pstart(nil,3,8,15,18,64,64, -4,4, -2,2, 1.1,13,1,0.2)
      if bd[5] or bd[4] then
        load("shooter.p8")
      end
    end
    
  end

  for p in all(particles) do
    if p.t > 0 then
      updateps(p)
    else
      del(particles, p)
    end
  end

  pbns = bns
end

xclr,yclr=0,0
color_sw = {4,9,10}
speed_color = -0.15
index_color1 = 1
index_color2 = 2
index_color3 = 3

tpoi = {}

function _draw()

  local color_clear = mode == 1 and 13 or 0
  if mode != 3 then
    if ghost_mode then
      for i=0,1500 do
        circ(xclr,yclr,1,color_clear)
        xclr = rnd(127)
        yclr = rnd(127)
      end
    else
      cls(color_clear)
    end
  end
    
  if mode == 0 then

    -- particles
    for p in all(particles) do
      if p.img != nil then
        spr(p.img,p.x,p.y)
      else
        circfill(p.x,p.y,p.size,p.col)
      end
    end   
      
    -- butons with slections
    if x_title_back == xmax_title_back then
		    if start_selection == 1 then
		      rectfill(40,pos_y_new_game-2,86,pos_y_new_game+6,menu_sel)
		      print("new game", 48,pos_y_new_game,3)
		    else
		      print("new game",48,pos_y_new_game,8)
		    end
		    if start_selection == 2 then
		      rectfill(40,pos_y_settings-2,86,pos_y_settings+6,menu_sel)
		      if ghost_mode then
		        circfill(39,pos_y_settings+2,2,3)
		      end
		      print("trail mode",44,pos_y_settings,3)
		    else
		      if ghost_mode then
		        circfill(39,pos_y_settings+2,2,8)
		      end
		      print("trail mode",44,pos_y_settings,8)
		    end
    end


    -- title menu
    pal(6,color_sw[flr(index_color1)],0)
    sspr(64,64,64,24,x_title_back,37,64*1.8,24*1.8)  
    pal(6,color_sw[flr(index_color2)],0)
    sspr(64,64,64,24,x_title_middle,36,64*1.8,24*1.8)  
    pal(6,color_sw[flr(index_color3)],0)
    sspr(64,64,64,24,x_title_front,35,64*1.8,24*1.8)  
    pal()

    index_color1 += speed_color
    index_color2 += speed_color
    index_color3 += speed_color
    if index_color1 <= 1 then index_color1 += #color_sw end
    if index_color2 <= 1 then index_color2 += #color_sw end
    if index_color3 <= 1 then index_color3 += #color_sw end
   
    if index_color1 > #color_sw+1 then index_color1 -= #color_sw end
    if index_color2 > #color_sw+1 then index_color2 -= #color_sw end
    if index_color3 > #color_sw+1 then index_color3 -= #color_sw end
   
    -- bands up & down
    rectfill(0,0,127,y_band_up,1)
    rectfill(0,y_band_up+1,127,y_band_up+3,5)
    rectfill(0,y_band_down,127,127,1)
    rectfill(0,y_band_down-1,127,y_band_down-3,5)

    
    for i=0,127,2 do
      pset(i+1,y_band_up+2,color_clear)
      pset(i+1,y_band_down-2,color_clear)
      pset(i,y_band_up+3,color_clear)
      pset(i,y_band_down-3,color_clear)
    end
    
    -- credit
    local ycredit = y_band_down + 10
    print("made by", 64-13,ycredit,0)
    print("made by", 64-12,ycredit+1,13)
    print("matthias dubray", 64-29,ycredit+8,0)
    print("matthias dubray", 64-28,ycredit+9,13)
  
  elseif mode == 1 then
  -- draw gane

    -- clouds
    for cl in all(clouds) do
      if cl.y - cl.h > 128 then
        del(clouds,cl)
      else
        cl.y += scrollsp * cl.s
        drawcloud(cl)
      end
    end

    -- search mario maker transition
    
    -- water effect
    
    -- reflect ship
    
    -- shade clouds on water
    
    -- rocks on side
    
    -- enemies
    --print(#enmies,100, 20)
    for e in all(enmies) do
      if e.get_hit then
        spr(e.img+1,e.x-4,e.y-4)
      else
        spr(e.img,e.x-4,e.y-4)
      end
      --if debugcol then
      --  rect(e.x+e.bxcol[1],e.y+e.bxcol[2],e.x+e.bxcol[3],e.y+e.bxcol[4],e.coldebug)
      --end
    end
    
    -- boss
    if boss.can_draw then
      local sc = boss.scale_factor
      local w = boss.sw * sc
      local h = boss.sh * sc
      
      if not boss.get_hit then
        sspr(boss.sx,boss.sy,boss.sw,boss.sh,boss.x-w/2,boss.y-h/2,w,h)
      else
        sspr(boss.sx+40,boss.sy,boss.sw,boss.sh,boss.x-w/2,boss.y-h/2,w,h)
      end
      --[[if debugcol then
        col_de = 8
        --print("bx col boss : " .. #boss.bxcol)
        for b in all(boss.bxcol) do
          rect(boss.x+b[1],boss.y+b[2],boss.x+b[3],boss.y+b[4],col_de)
          col_de += 1
        end
      end]]--
    end

    -- pick ups
    for p in all(power_ups) do
      if p.time_life <= p.time_blink then
        if p.time_life % 6 <= 3 then
          spr(p.cur_img,p.x-4,p.y-4)
        end
      else
        spr(p.cur_img,p.x-4,p.y-4)
      end
      
      --spr(p.cur_img+16,p.x-4,p.y+4)
      --if debugcol then
      --  rect(p.x+p.bxcol[1],p.y+p.bxcol[2],p.x+p.bxcol[3],p.y+p.bxcol[4],p.coldebug)
      --end
    end
    
    -- shooting
    for b in all(bombs) do
      spr(b.cur_img, b.x-4, b.y)
    end
    for b in all(bullets) do
      spr(b.cur_img, b.x-4, b.y-4)
      --if debugcol then
      --  rect(b.x+b.bxcol[1],b.y+b.bxcol[2],b.x+b.bxcol[3],b.y+b.bxcol[4],b.coldebug)
      --end
    end
    for b in all(bullet_enmies) do
      -- actual
      spr(b.cur_img, b.x-4, b.y-4)
      --if debugcol then
      --  rect(b.x+b.bxcol[1],b.y+b.bxcol[2],b.x+b.bxcol[3],b.y+b.bxcol[4],b.coldebug)
      --end
    end

    -- ship
    if ship.invincible % 10 <= 5 then
      spr(ship.img_base+ship.offset_img,ship.x-4,ship.y-4)
    end
    --if debugcol then
    --  rect(ship.x+ship.bxcol[1],ship.y+ship.bxcol[2],ship.x+ship.bxcol[3],ship.y+ship.bxcol[4],ship.coldebug)
    --  rect(ship.x+ship.large_bxcol[1],ship.y+ship.large_bxcol[2],ship.x+ship.large_bxcol[3],ship.y+ship.large_bxcol[4],ship.coldebug)
    --end

    for p in all(particles) do
      if p.img != nil then
        spr(p.img,p.x,p.y)
      else
        circfill(p.x,p.y,p.size,p.col)
      end
    end
    
    -- ui
    rectfill(-10,-10,x_margin-1,138,1)
    rectfill(128-x_margin+1,-10,138,138,1)
    for y=0,128,2 do
      pset(x_margin,y,1)
      pset(128-x_margin,y,1)
    end
    
    for ptext in all(texts) do
      print(ptext.text,ptext.x-1,ptext.y+1,0)
      print(ptext.text,ptext.x,ptext.y,ptext.cols[flr(ptext.col)])
    end
    
    spr(bomb.cur_img,119,110)
    for i=1,ship.max_bomb do
      if ship.bomb_count >= i then
        rect(116+i*3,121,117+i*3,122,7)
        --pset(116+i*3,125,7)
      else
        rect(116+i*3,121,117+i*3,122,5)
        --pset(116+i*3,125,5)
      end
    end
    
    print("score: " .. score,x_margin+4,1,5)
    print("score: " .. score,x_margin+5,2,7)
    
    --print("x" .. ship.bomb_count,118,118,7)
    --[[for i=0,ship.bomb_count-1 do
      spr(bomb.cur_img,i*10,118)
    end]]--

    for i=1,ship.hp do
      spr(10+i,118,100-i*8)
    end
    
    if boss.can_draw then
      print("hp",2,8,7)
      
      local p = boss.hp/boss.max_hp
      local height = p * 100
      local col_hp
      if p >= 0.6 then
        col_hp = 9
      elseif p >= 0.3 then
        col_hp = 8
      else
        col_hp = 2
      end 
      rectfill(3,116,8,116-height,col_hp)
      
      spr(79,2,15)
      for i=0,10 do
        spr(95,2,23+i*8)
      end
      spr(111,2,111)
      
    end

    if boss.draw_alert then
      -- draw alert
      sspr(0,68,57,22,24,50,80,22)
    end

  elseif mode == 2 then
    cls(13)
    
    
    -- generated screen with sun & reflects
    -- & ship traveling
    --print("yeah",64,64,7)
    local pos_sun_y = sin(time()/10) * 20
    col_lizeret_1=pos_sun_y < 10 and 10 or 9 
    col_lizeret_2=pos_sun_y < 3 and 10 or 9   
    
    for x=0,128 do
    for y=0,-pos_sun_y,-1 do
      if ((x*2-50)-100)%(y-2) == 0 then
        if sqrt((x-64)*(x-64) + (y+82-220)*(y+82-220)) < 170 then
          pset(x,y+82,9)
        end
      end
    end
    end
   
    
    --circfill(80,75+pos_sun_y,85,13)
    
    circfill(80,75+pos_sun_y,35,9)
    circfill(80,75+pos_sun_y,33,10)
    circfill(64,340,265,12)
    circfill(64,340,264,13)
    circfill(68,276+pos_sun_y*1.2,200+pos_sun_y*1.2,col_lizeret_1)
    circfill(68,276+pos_sun_y*1.2,199+pos_sun_y*1.2,col_lizeret_2)
    circfill(64,340,262,1)
    
    
    spr(ship.img_base+ship.offset_img,ship.x-4,ship.y-4)
    
    pal(2,5,0)
    pal(10,5,0)
    pal(8,5,0)
    spr(ship.img_base+ship.offset_img,ship.x-8,ship.y+12)
    pal()
    
    for p in all(particles) do
      if p.img != nil then
        spr(p.img,p.x,p.y)
      else
        circfill(p.x,p.y,p.size,p.col)
      end
    end
    
    for cl in all(clouds) do
      if cl.y - cl.h > 128 then
        del(clouds,cl)
      else
        cl.y += scrollsp * cl.s
        drawcloud(cl)
      end
    end 
    --rectfill(0,85,128,128,1)
    
    print("tank you for",10,20,0)
    print("tank you for",11,21,7)
    
    print("playing !!",10,28,0)
    print("playing !!",11,29,7)
    
    print("score : " .. score, 10,48,0)
    print("score : " .. score, 11,49,7)
    
  elseif mode == 3 then
    
    -- first clear screen with pixels
    if timer_clear_game_over < wait_clear_game_over then
      for i=0,250 do
        circ(xclr,yclr,1,color_clear)
        xclr = rnd(127)
        yclr = rnd(127)
      end
    else
      cls(color_clear)
      
      -- once done send the gameover logo
      local maxf = 20
      local f = 2 + (maxf-(timer_game_over/wait_game_over)*maxf)
      local w,h = 19,15
      local wf,hf = w*f,h*f
    
      local maxr = 250
      local r = maxr-(timer_game_over/wait_game_over)*maxr
      local pr = maxr-((timer_game_over-1)/wait_game_over)*maxr
    
      -- particles
      for p in all(particles) do
        if p.img != nil then
          spr(p.img,p.x,p.y)
        else
          circfill(p.x,p.y,p.size,p.col)
        end
      end   
    
      pal(1,2,0)
      sspr(0,16,w,h,63-wf/2,63-hf/2,wf,hf)
      pal(1,8,0)
      sspr(0,16,w,h,64-wf/2,64-hf/2,wf,hf)
      pal(1,14,0)
      sspr(0,16,w,h,65-wf/2,65-hf/2,wf,hf)
      pal()
    end
    
  end

  --[[if debugcol then
  		color(7)
    print(stat(1),100,112)
    show_performance()
  end]]--
end



function animship()

  if ship.vx != 0 then
    local it = ship.vx > 0 and 1 or -1
    ship.cur_speed_transition += it
  else
    if ship.offset_img>0 then
      ship.cur_speed_transition-=1
    elseif ship.offset_img<0 then
      ship.cur_speed_transition+=1
    else
      ship.cur_speed_transition=0
    end
  end

  if ship.cur_speed_transition >= ship.frame_transition then
    ship.cur_speed_transition = 0
    ship.offset_img += 1
  elseif ship.cur_speed_transition <= -ship.frame_transition then  
    ship.cur_speed_transition = 0
    ship.offset_img -= 1
  end

  ship.offset_img = clmp(ship.offset_img,-2,2)

end

function pstart(img,size,nb,tmin,tmax,x,y,vxmin,vxmax,vymin,vymax,dr,cols,cole,tcol)
  for i=0,nb do
    local _p = copy(ps)
    _p.img = img
    _p.size = size
    _p.x = x
    _p.y = y
    _p.vx = vxmin + rnd(vxmax-vxmin)
    _p.vy = vymin + rnd(vymax-vymin)
    _p.ts = tmin + rnd(tmax-tmin)
    _p.t = _p.ts
    _p.drag = dr
    _p.cols = cols
    _p.cole = cole
    _p.col = cols
    _p.tcol = tcol
    add(particles, _p)
  end
end

function create_text(tx,x,y)
  local txt = copy(text)
  txt.text,txt.x,txt.y=tx,x,y
  add(texts,txt)
end

function updateps(p)
  p.x += p.vx
  p.y += p.vy
  p.vx /= p.drag
  p.vy /= p.drag
  p.col = p.t/p.ts>p.tcol and p.cols or p.cole
  p.t -= 1
end

function shake(fx, fy, s)
  local x,y = fx,fy
  while flr(x) != 0 or flr(y) != 0 do
    camera(x, y)
    yield()
    x *= -s
    y *= -s
  end
  camera(0,0)
end

function iscolinsides(xa,ya,ba,xb,yb,bb)
  local x1,y1,x2,y2 = xa+ba[1],ya+ba[2],xa+ba[3],ya+ba[4]
  local x3,y3,x4,y4 = xb+bb[1],yb+bb[2],xb+bb[3],yb+bb[4]

  if x3 > x2 or x1 > x4 or y1 > y4 or y3 > y2 then
    return false
  else
    return true
  end
end

function lerp( t, a, b )
  return a + t * (b - a)
end

function clmp(val, mi, ma)
  return max(min(val,ma),mi)
end

function generatecloud(c)
  local x,y = -28 + rnd(110),-10
  local w = 6+rnd(40)
  local h = 1+min(5,rnd(w/5))
  c.x,c.y,c.w,c.h,c.t,c.s = flr(x),flr(y),flr(w),flr(h),flr(rnd(4)),1+rnd(1)
end

function drawcloud(c)
  if c.t == 0 then
    local oxu=flr(c.w*0.6)
    local oxd=flr(c.w*0.2)
    local hd=flr(-c.h/4)-2
    local hu=flr(c.h*1.5)
    cld(c.x,c.y,c.w,c.h,0.15,15)
    cld(c.x+oxu,c.y,c.w-flr(0.75*oxu),hu,0.35,15)  
    cld(c.x,c.y,oxu,hd,0.4,9)
    cld(c.x+oxd,c.y,c.w-2,hd*2,0.4,9)
  elseif c.t == 1 then
    local wd=flr(c.w*0.25)
    local hd=flr(-c.h*1.5)
    local oxd=flr(wd/2)
    cld(c.x,c.y,c.w,c.h,0.15,15)
    cld(c.x,c.y,wd*2,-c.h,0.3,9)
    cld(c.x+oxd,c.y,c.w-oxd,hd,0.3,9)   
  elseif c.t == 3 then
    local wu = flr(c.w/8)
    local hu = flr(c.h*1.5)
    cld(c.x,c.y,c.w,c.h,0.15,15)
    cld(c.x+2*wu,c.y,wu*6,hu,0.15,15)
    cld(c.x,c.y,c.w,-c.h,0.3,9)
  end
end

function cld(x,y,w,h,p,c)
  local ys,xs,ymult,xmult = y,x,h,1/(2*w)
  
  -- do all integers one 1 demi period of sin
  local endx = flr(((1/xmult)/2)+xs)
  for xp=xs,endx do
    y = ymult*sin(-xmult*xs+(xp*xmult))+ys
    local step = y > ys and -1 or 1
    local inty = flr(y)
    for yp=inty,ys,step do
      if (xp%2==0 and yp%2!=0) or (xp%2!=0 and yp%2==0) then
        local col = 7
        local sty = abs(yp-inty)
        local eny = abs(ys-inty)
        local perc = sty>eny and eny/sty or sty/eny
        col = perc < p and c or col
        pset(xp,yp,col)
      end
    end   
  end
end

function show_performance()
 clip()
 local cpu=flr(stat(1)*100)
 local fps=-60/flr(-stat(1))
 local perf=
  cpu .. "% cpu @ " ..
  fps ..  " fps"
 print(perf,100,120,0)
 print(perf,100,121,fps==60 and 7 or 8)
end
__gfx__
000000005d6776d500002000000aa000000aa000000aa0000002000000000000000000000000000000000000000059a500058985005828250055555000000000
0000000049a77a94000a20000002200000022000000220000002a0000009900000099000000990000009900000005a9500059895005282850522222500000000
007007007fe825100000000000000880888008880880000000000000009a99000099a900009a99000099a90000005aa500059995005888850522222508800880
0007700028e77e8200088000000882002888888200288000000880000099a900009a99000099a900009a990000005aa500059995005888850522222588888888
000770001d6776d10088200000882000022882200002880000028800009a99000099a900009a99000099a900000005a500005995005888850522222588888888
0070070049f77f940028200008282000000880000002828000028200000aa000000aa0000009a000000a9000000005a500005995000588850052222508888880
0000000053b77b350008200002082000000880000002802000028000000aa000000aa000000aa000000aa000000005a500005995000588850052222500888800
000000001c6776c10008200000082000000220000002800000028000000000000000000000000000000000000000005000005a95000598950052828500088000
000000003b6776b300e822000088220000e822000088220000000000000000000000000000000000000000000000000000000000000000000000000000055550
000a90003b6776b30e88822008e888200e88822008e888200088820000e888000088820000000000000000000000000000000000000000000000000000588885
00a999003b6776b308e888200e88822008e888200e88822008e888200e88822008e888200e888220008882000000000000000000000000000000000000588885
00a999003b6776b30e88822008e888200e88822008e888200e88822008e888200e88822008e8882008e8882000e8880000444400000000000000000000588885
00a999003b6776b308e888200e88822008e888200e88822008e888200e88822008e888200e8882200e8882200e44442004444440000000000000000000588885
00aa9a003b6776b30e88822008e888200e88822008e888200e88822008e888200e88822008e88820084444200444444004544540000000000000000000058885
009999003b6776b30058850000588500005885000058850000588500005885000044ff0000444f00045445400454454004444440000000000000000000058885
004444003b6776b30fff44400ffff4400fffff400ffffff004fffff0044ffff00444444004444440004444000044440000444400000000000000000000059895
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110111101111011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000100101011010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10100110101001011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010101101001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110100101001011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110100101111011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010100101000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010010101110010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010010101000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110001101111010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000090099009a00aa00a00000000000000000008800028e77e8200082000000000000000000011111111
0616616007c77c700000000000000000015151500c6c6c6099967999aaa77aaa00000000000ee0000008800028e77e82028888200000000000000000ffff1111
666776667777777700666600007777005555555566666666496667949a7777a9000ee00000e28e0000ee820028e7ee82288e78820000000000000000f000ffff
f6f66f6ff7f77f7f66655666777667775556755566677666496667949a7777a900e28e000e2888e000e8820028e7e88288e77e8800000000000000006070000f
0566665006777760666006667770077715666751c677776c0496694009a77a9000e88e000e8888e000ee820028e7788228e77e820000000000000000f0070006
0011110000cccc006666666677777777015665100c6776c004499440099aa990000ee00000e88e0000e8820028e77e2288e7ee8200000000000000006070000f
000000000000000056655665677667760015510000c66c00004444000099990000000000000ee00000ee8200288e7e822887ee820000000000000000f0700006
0000000000000000055005500660066000011000000cc0000004400000099000000000000000000000088000228e7e8228ee788200000000000000006000000f
bb0000bb0bb000bb0bb00bb000b00bb0000b0b00000bb000000b00000000b000000bb000000b0b0000b00bb00bb00bb00bb000bbbb0000bbbb0000bb60000006
b377763b0b37763b0b3776b000b776b0007b7600007b7600007b76000077b6000077b60000777b00007773b00b7773b00b77763bb377763bb377763b60700006
37787763037e7763037e7760073e7760077377600773776007737760077837600778376007787360077877300778773007787763377877633778776360700006
0788876007e8876007e8876007ee876007ee8760078ee760078ee7600788e7600788e76007888760078887600788876007888760078887600788876060000006
0778776007787760077877600778776007787760077e7760077e7760077e7760077e776007787760077877600778776007787760077877600778776060700006
b777776b0b77776b0b77776007b77760077b7760077b7760077b77600777b7600777b76007777b60077777b0077777b00777776bb777776bb777776b60700006
bb55551b0bb5551b0bb5551005b55510055b5510055b5510055b55100555b5100555b51005555b1005555bb005555bb0055555bbb55555bbb55555bb60700006
33000033033000330330033000300330000303000003300000030000000030000003300000030300003003300330033003300033330000333300003360700006
bb0000bb0bb000bb0bb00bb000b00bb0000b0b00000bb000000b00000000b000000bb000000b0b0000b00bb00bb00bb00bb000bbbb0000bbbb0000bbf0000006
b308203b0b38203b0b3883b000b883b0000b2b00000b2000000b80000008b0000008b00000082b0000b883b00b3883b00b38203bb308203bb308203b6070000f
30e8820303e88203038828300038283000e3820000e38200008328000088380000e8320000e88200008828300388283003e8820330e8820330e88203f0700006
008828000088280000e8820000e88200008828000088280000e8820000e88200008828000088280000e8820000e882000088280000882800008828006007000f
00e8820000e88200008828000088280000e8820000e88200008828000088280000e8820000e88200008828000088280000e8820000e8820000e88200f0000006
b005500b0b05500b0b0550b000b550b0000b5b00000b5000000b50000005b0000005b00000055b0000b550b00b0550b00b05500bb005500bb005500bffff000f
bb4444bb0bb444bb0bb444b000b444b0004b4400004b4400004b44000044b4000044b40000444b0000444bb00b444bb00b4444bbbb4444bbbb4444bb1111ffff
33000033033000330330033000300330000303000003300000030000000030000003300000030300003003300330033003300033330000333300003311111111
bb0000bb0bb000bb0bb00bb000b00bb0000b0b00000bb000000b00000000b000000bb000000b0b0000b00bb00bb00bb00bb000bbbb0000bbbb0000bb00000000
b30a903b0b3a903b0b3a93b000ba93b0000bab00000ba000000ba0000009b0000009b00000099b0000b993b00b3993b00b39903bb309903bb30a903b00000000
30a9990303a99903039a9930003a99300093a9000093a90000939a0000993a0000993900009993000099993003999930039999033099990330a9990300000000
00a9990000a99900009a9900009a99000099a9000099a90000999a0000999a0000999900009999000099990000999900009999000099990000a9990000000000
00a9990000a99900009a9900009a99000099a9000099a90000999a0000999a0000999900009999000099990000999900009999000099990000a9990000000000
b0aa9a0b0baa9a0b0baa9ab000ba9ab000abaa0000abaa0000abaa0000a9ba0000a9ba0000a9ab00009aaab00b9aaab00baaaa0bb0aaaa0bb0aa9a0b00000000
bb4444bb0bb444bb0bb444b000b444b0004b4400004b4400004b44000044b4000044b40000444b0000444bb00b444bb00b4444bbbb4444bbbb4444bb00000000
33000033033000330330033000300330000303000003300000030000000030000003300000030300003003300330033003300033330000333300003300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000006666666600066666666600666660006666600666666666006666666660
00000000000000000000000000000000000000000000000000000000000000000000060000000060060000000600600060006000600600000006006000000060
00000000000000000000000000000000000000000000000000000000000000000000060000000060600000006006000600060006006000000060060000000600
08888888888888888888888888888888888888888888888888800000000000000000600000000600600000006006000600060006006000666660060006000600
02222222222222222222222222222222222222222222222222200000000000000000600000000606000066660060006000600060060006000000600060006000
00000000000000000000000000000000000000000000000000000000000000000006000000006006000006000060006666600060060006000000600060006000
08888888888888888888888888888888888888888888888888800000000000000006000666660060000060000600060006000600600060000006000600060000
08888222288888882228888222222822222228822222222888800000000000000060006000000060000060000600060006000600600060000006000600060000
02888000028888880008888000000800000002800000000088880000000000000060006000000600006666006000000000006006000666660060006000600000
00888800002888888002888800088880008800280000000028880000000000000600060000000600000006006000000000006006000000060060000000600000
00288800000288888000888800088880008880028880008888888000000000000600060000006000000060060000000000060060000000600600000006000000
00088880000028888800288880028888002888008888002888888000000000000066600000006666666660066666666666660066666666600666666666000000
00028880000002888800088880002228000882008888000888888800000000000000000000000000000000000000000000000000000000000000000000000000
00008888000000288880028888000002800220088888800288888800000000006666666666666666666666666666666666666666666666666666666666600000
00002888000880028880008888000888800000028888800088888880000000000600000000000000000000000000000000000000000000000000000000060000
00000888800288002888002888800288880088002888880028888880000000000060000000000000000000000000000000000000000000000000000000006000
00000288800088800288000222800088880008800288880008888888000000000006666666666666666666666666666666666666666666666666666666666600
00000088880028880028800000280022228002880028888002888888000000000000000000000000000000000000000000000000000000000000000000000000
00000028880008888008800000080000008000888008888000888888800000000000000000000000000000000000000000000000000000000000000000000000
00000008888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000
00000002222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000
00000002222222222222222222222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000666666660000000000000000
00000000000005555555555555500000000000000000000000000000000005555555555555500000000000000000000000000666666666666660000000000000
00000000055555555656565655555550000000000000000000000000055555565656565665555550000000000000000006666667676767676666666000000000
00000005555656555555555555656555500000000000000000000005555656555555555555656555500000000000000666676766666666666676766660000000
00000565656565555dd55ff5555656565650000000000000000005556565655557755775555656565550000000000676767676666ff66ff66667676767600000
000066666656555dddddfffff555656666660000000000000000555656565557766667677555656565550000000077676767666ff7777f7ff666767676770000
0006666665655dddddddfffffff5565666666000000000000005545565655657666666667565565655455000000779777676676f77777777f676676777977000
00666665666dddddddddfffffffff666566666000000000000554545665665655665566556566566545455000077979677677676677667766767767769797700
006666666666ddddddddffffffff6666666666000000000000545446656656666555555666656656644545000079799776776777766666677776776779979700
0666666666666dddddddfffffff6666666666660000000000555444666666666665ee56666666666644455500777999777777777776ff6777777777779997770
0666666666666dddddddfffffff6666666666660000000000554446666466466658e8e566646646666444550077999777797797776efef677797797777999770
666e666e666e66ddddddffffff66e666e666e666000000005545446666646646658888566466466666445455779799777779779776eeee677779779777997977
6666e6e6e6e6e6edd000000ffe6e6e6e6e6e66660000000054544467666646661128281166646666764445457979997777779777cc8e8ecc7777977977999797
666e6e6e6e6e6e2d20050502f2e6e6e6e6e6e666000000005544466764666661001221001666664676644455779997777977777c00c88c00c777777777799977
6766eeeeeeeeeee2220050222eeeeeeeeeee667600000000545446766646661000011000016664666764454579799777779777c0000cc0000c77777777799797
677eeeeeeeeee22222200222222eeeeeeeeee776000000005544467666646641100000011466466667644455779997777779779cc000000cc977777977799977
67766eeeeeeeee222222222222eeeeeeeee6677600000000545446766666644441000014444666666764454579799777777779999c0000c99997777797799797
6677eeeeeeee2222225555222222eeeeeeee776600000000554446676666444641000014644466667664445577999777777799979c0000c97999777777799977
666766eeeeeee22225000052222eeeeeee6676660000000054544467666644644000000446446666764445457979997777779979900000099799777777999797
56676eeeeee222665000000566222eeeeee676650000000055454466666446460000000064644666664454555797997777799797000000007979977777997975
0666766eeeee2650000000000562eeeee66766600000000005544466666444600000000006444666664445500779997777799970000000000799977777999770
056676ee6e22650000000000005622e6ee6766500000000005554446664446600000000006644466644455500777999777999770000000000779997779997770
00566666611625000000000000526116666665000000000000545446664464600000000006464466644545000079799777997970000000000797997779979700
005567661d1d6600000000000066d1d1667655000000000000554541111646000000000000646111145455000077979cccc797000000000000797cccc9797700
00055661d1d1d50000000000005d1d1d16655000000000000005541555516600000000000066155551455000000779c6666c7700000000000077c6666c977000
0005556ddd1dd60000000000006dd1ddd655500000000000000051555555160000000000006155555515000000007c666666c70000000000007c666666c70000
000055561ddd6000000000000006ddd1655500000000000000000005555000000000000000000555500000000000000666600000000000000000066660000000
00000556dddd6000000000000006dddd655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000556dd600000000000000006dd6550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000055566500000000000000005665550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005555000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000550000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000002b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100002a6202832025320223202132025620323202f320186202832026320086201f32007620153201131008610086100c3100a3100761007310056100361005310016100860009600096000a6000b6000c600
01010000286102961016120111200e1200c1200a1100a110136100f6100d61006110066100361001610016100b5100a520085200451001510015101d50008100081000810008100081000710007100071001f500
000100001b140131400e1400c14021630206301b630156300d6300a63007630046300363001630016301f0001b5001c5001f50020500231002310022100201001f1001f1001f1001f10020100211002210022100
010a000015310153101600004200153101531016000160001531015310160001600003650086500c6500f6400d6300b6200661001610016100111001600036000160001600016000960005600026000160001600
0004000003650086500c6500f6400d6300b620066100161001610011100f103141031410314103141030f103121031410314103141030f10312103021031410314103011031410311103111030e1031010311103
0006000003520085200c540195301b5201f530245302554029540395003950008500015001a5001c5001d50000500005001850018500175001550014500005000050012500115000f5000e500005001450015500
000200001c62022620266201662015620126200f6200d6100961005610016100f4001040011400036000260001600016000160021600206001f6001c6001960015600126000f6000a60007600046000160000400
00010000066300463003630023300232003620026200262001320013100361003610036100361002310023100760008600096000d6000230002300196001f60027600336003c6000130001300293002830028300
00020000085400c5402031016310224202242035430190001b0001d00020000253002d3002d300363003230032300323003e300222002e2000b10008100180001800018000180001800018000180001800018000
000100001b120131200e1200c12021610206101b610156100d6100a6100761004610036100161001610011000f10039300150003930034500393002b50039300235003930039300383000b300103001430025300
0003000006510095200a630091300c1301862019620176101661001600066000c6000f600106000f10011600071000e600096000210001200014001c40001600016000560002600016002340023400234001d400
00020000115401c5502d6502f6502f6502c6402b630114200b4200742004430014300522006200092000c2000f2001520019200142000d200082000420001200012000e400084000640005400014000340003400
000300001b540300302e0301d03001030070300f700167000b7000970008700097000b7000d7000e700157000c7000b700137000870008700097000c7000e70005700027000e7000b7000a70009700097000a700
001400201205014050140501405014050120500f0500d0500f0500f0500f0500d0500d050120500d050120500d0501205012050120500f0500d0500d050120500d05012050120500f0500f0500f050120500f050
0010000012350123500f3500f35012350123500f350123500f350123001230012300143000f3500f350123501235014350143500030000300003001435014350123500f350123501235014350003000030000300
000800002155221552215521c5522455224552245521f5521d5521d5521d552185521455214552145520f552165521655216552125521f5521f5521f5521a5522355223552235521d5521d502245021005205052
011500201c2201d2201a2201d2201c2201d2201f2201f220226201c2201d2201a2201d2201c2201d2201f2201f220226201a2201d22015220182201022014220102201322017220142201c220182201c2201d220
0002000019030190302a0302d03021030060201e00000000000000000000000000000000000000000000000000000011000610008100161000e10008100011000c50001500000000000000000000000000000000
000200000777015770287202c7202a750317002b70024700187000c70002700017000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0019002021730217301d7301f7301c7301070021730217301d7301f7301c7301c7001c7301f7302273025730237301f730227301f730217301f7301c7301e7301b7301b7301e7301b7301f7301f730217301f730
001000201f0441f0451f0451f0411c0411c0451c0451c0411d0411d0451d0451d0411a0411a0451a0451a0411f0411f0451f0451f0411d0411d0451d0451d0411c0411c0451c0451c04121041210452104521045
011000200607503005060750600508075060050807508005010750200501075030050e0750e0050e0750e0050a075100050a075110050c075100050c07513005070750e005070751000502075110050207504005
001000201523513235152351323500205002050020500205112351123515235112350020500205002050020510235102350e23510235002050020500205002051823517235182351723500205002050020500205
001000201775215752157521875215752007020070200702057521875200702007021875200702137520070210752007021775010702137501370210750087021875004702177500270210750007061375000706
0114001f211521d1521f1521c15221152241522415223152211521d1521f1521c1521f1521d152211521c152211521d1521f1521c1521f152241522415223152211521f1521c152211521c1521f1521d15221152
01140000130251301513025130151502515015150251501510025100151002510015110251101511025110150e0250e0150e0250e02514015140151402514015160251601516025160150f0250f0150f0250f015
011400000d4350d4350f4350f435124350d435124350d4352b4050c4050c4050c405134050c4051840501405164351643514435124351243514435124350f4350040500405004050040500405004050040500405
011400001f61510005126051b005216151100511005126051a61515005216051f6051c6151300500605006051f6151000513605106051e6150e00500605006051c6151300514605166051d615150050060500605
011400001c7521c7021d7521f702217521c7021a7521a7021a752237021d752217022175218702247521a702247521470223752127021f75216702217521470224752137021d752107021f7521c7021c75218702
01140000132301d200102301a200112301d2000e230002001323011200112300e2000c230002000e2300020017230152001523013200102300f20013230002000c23012200112301020010230002000e23000200
011400001375513755137551375510755107551075510755127551275512755127550e7550e7550e7550e755137551375513755137550f7550f7550f7550f7551675516755167551675512755127551275512755
0110002021255212551f2551f2551d2551d2551c2551c25523255232551f2551f2551a2551a25521255212551d2551d2551c2551c25518255182551f2521f2521d2521c2521d2521f25221252232522425224252
010e0000214551d455214551d455214551d455214551d4551f4551c4551f4551c4551f4551c4551f4551c455214551a455214551a455214551a455214551a455234551d455234551d455234551d455234551d455
010e000015412114121541211412154121141215412114121341210412134121041213412104121341210412154120e412154120e412154120e412154120e4121741211412174121141217412114121741211412
010e0000156250c605296250c6050e62524605286250c60515625246052b6250c6051162524605266250c60511625246052b6250c6050e62524605296250c6050c62524605296250c6051562524605286250c605
000e000013455134551045515455114551345510455114550e455134551045515455114551345515455154551345510455114550e455114550e45513455104551545511455134551145511455104550e4550e455
000e00002445523455214551f4551d4551c4551a4551845517455154551345511455104550e4550c4550d455234551d455214551c4551f4551a4551d45518455174551345515455114551345510455114550e455
00140000231522314123131231251f1521f1411f1311f1251d1521d1411d1311d1251c1521c1411c1311c125241522414124131241251f1521f1411f1311f1252115221141211312112523152231412313123125
001400000d1550d1450d1350d125141551414514135141250f1551215512141121311415516155161411613116155161451613516125141551414514135141250f1551215512141121310f1550d1550d1410d131
00140000071250412204122041250012502122021220212509125071220712207125081250a1220a1220a1250e125101221012210125111250c1220c1220c125131251112211122111250a125081220812208125
011600000f345163350f325163150f345163350f3251631512345163351232516315123451633512325163150d345143350d325143150d345143350d325143150f345123350f325123150f345123350f32512315
0116000016335143221234512345123350f3220d3450d3450f3351432216345163450d3350f322123451234516335143221234512345123350f3220d3450d3450f33512322143451434512335143221634516345
011600000d3350d3250f3350f325123351232514335143251633516325143351432512335123250f3350f3250d3350d3250f3320f322123321232214332143221633216322143321432114311143121633516325
0116000003615006050060500605066150060500605006050261500605006050060509615006050060500605056150060500605006050961500605006050060502615006050060500605076150c6050060500605
011600001561500605136150060510615006051361500605116150060510615006050e6150060513615006050e61500605106150060511615006051361500605106150060511615006050e615006051361500605
010b00200506300003000030000307063000030000300003040630000300003000030906300003000030000306063000030000300003030630000300003000030a06300003000030000302063000030000300003
000b0020216150060513605006051c6050060513605006051f6150060510605006051d6050060513605006051d6150060510605006051c6050060513605006051c6150060511605006051d605006051360500605
010c00202113121141211512116121161211512114121131211010010100101001011d10100101001010010121131211412115121161211612115121141211311d1010010100101001011d101001010010100101
001000202112121121211212112121121211212112121121211212112121121211212112121121211212112121121211212112121121211212112121121211212112121121211212112121121211212112121121
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 41 15 43 44
00 14 15 43 44
03 14 15 16 44
01 41 19 43 44
00 19 42 1c 44
01 19 1b 1c 44
00 19 1b 1c 44
02 19 1b 1e 44
01 41 21 43 44
00 41 21 22 44
01 24 21 22 44
00 23 21 22 44
02 20 21 22 44
01 28 42 43 44
01 28 2e 43 44
00 28 2e 43 44
00 2a 2d 43 44
02 29 2d 43 44
03 2f 42 43 44
03 30 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
