pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- chicxulub
-- a game for ld47

-- notes
-- all positions are centres

play_music=true
debug=false
skip_title=false
preview_end=false

scene=nil

function _init()
 cls()
 print("loading...", 55, 64)
 load_patterns()
 load_stars()
 reset_finale()
 start_title_screen()
 if skip_title then
  move_to_game()
 end
 if preview_end then
  start_end()
 end
end

function _update60()
 if scene=="title" then
  update_title_screen()
 elseif scene=="game" then
  update_game()
 elseif scene=="end" then
  update_end()
 end
end

function _draw()
 if scene=="title" then
  draw_title_screen()
 elseif scene=="game" then
  draw_game()
 elseif scene=="end" then
  draw_end()
 end
 
 if debug then
  print(stat(1), 100, 120, 11)
  print(stat(0), 2, 120, 11)
 end
end
 
function move_to_game()
 scene="game"
 init_player()
 load_level(start)

 if play_music then
  music(0)
 end
end

function update_game()
 if wave_state=="spawning" then
 	spawn()
 end
 
 if in_finale then
  update_finale()
 end
 
 if not current_level.final then
  move_player()
 end
 move_enemies()
 if boss.active then
  move_boss()
 end
 move_bullets()
 move_pickups()
 update_player_state()
 do_player_collision()
 
 cleanup(enemies)
 cleanup(bullets)
 cleanup(lasers)
 cleanup(pickups)
 cleanup(particles)
 
 update_ui()
end

function draw_game()
 cls()
 
 draw_bg()
 
 draw_enemies()
 if boss.active then
  draw_boss()
 end
 
 draw_pickups()
 
 draw_player()
 
 draw_bullets()
 
 draw_ui()
end
-->8
--player

player={}
				    
particles={}				    

player_speed=1
player_radius=3
player_sprs={1,2,3,4,5,6,7,8,9,10,11,12}
player_anim_speed=5

function init_player()
	player={x=16,
					    y=64,
					    size=10000,
					    frame=1,
					    anim_counter=0,
					    inv=0,
					    scale=1
					    }
	particles={}
end

function move_player()
 if btn(”) then
  player.y -= player_speed
 elseif btn(ƒ) then
  player.y += player_speed
 end
 if btn(‹) then
  player.x -= player_speed
 elseif btn(‘) then
  player.x += player_speed
 end
 player.x = mid(player_radius,
 						         player.x,
 						         128-player_radius)
 player.y = mid(player_radius,
 						         player.y,
 						         128-player_radius)
end

function update_player_state()
 player.anim_counter+=1
 if player.anim_counter > player_anim_speed then
  player.frame+=1
  if player.frame>#player_sprs then
   player.frame=1
  end
  player.anim_counter=0
 end
 if player.inv > 0 then
  player.inv-=1
 end
 
 update_player_particles()
end

function damage_player(amount)
 if player.inv > 0 then
  return
 end
 sfx(34)
 local amount = amount or 55
 player.size -= amount
 screen_shake()
 player.inv=60
 for i=0,50 do
  local angle=rnd(1)
  local speed=rnd(0.3)+0.3
  local p = {
   x=player.x+rnd(4),
   y=player.y+rnd(6)-2,
   dx=cos(angle)*speed,
   dy=sin(angle)*speed,
   life=rnd(40)+20,
   to_remove=false,
   col=flr(rnd(3))+5
  }
  add(particles, p)
 end
end

function do_player_collision()
 if player.inv == 0 then
	 for b in all(bullets) do
	  --todo: check who's bullets?
	  if true then
	   if c_overlap(player, player_radius,
	                b, bullet_radius) then
	    b.to_remove=true
	    damage_player()
	   end
	  end
	 end
	 for l in all(lasers) do
	  if l.live and 
	     circ_rect(player.x, player.y, player_radius,
	               l.right-l.width, l.right, l.y-1, l.y) then
	   l.to_remove=true
	   damage_player()
	  end
	 end
	end
 for p in all(pickups) do
  if c_overlap(player, player_radius,
               p, p.radius) then
   if p.t == "dust" then
    player.size += 100
    sfx(33)
   end
   p.to_remove=true
  end
 end
 for e in all(enemies) do
  for x=0,e.sw-1 do
   for y=0,e.sh-1 do
    local ep = {x=e.x-e.sw*4+x*8+4,
                y=e.y-e.sh*4+y*8+4}
    if c_overlap(player, player_radius,
                 ep, 3) then
     damage_player()
    end
   end
  end
 end
 if boss.active then
  for hs in all(boss.hitboxes) do
   for h in all(hs) do
    if h.t=="circ" then
     local p = {x=h.x+boss.x, y=h.y+boss.y}
     if c_overlap(player, player_radius,
                  p, h.r) then
      damage_player()
      break
     end
    else
     if circ_rect(player.x, player.y, player_radius,
                  h.x0+boss.x, h.x1+boss.x, h.y0+boss.y, h.y1+boss.y) then
      damage_player()
      break
     end
    end   
   end
  end
 end
end

function draw_player()
 for p in all(particles) do
  pset(p.x, p.y, p.col)
 end
 if player.inv == 0 or
    player.inv % 4 != 1 then
  if player.scale==1 then
   spr(player.frame, player.x-4, player.y-4)
  else
   sspr(player.frame*8, 0, 8, 8, player.x-4*player.scale, player.y-4*player.scale, 8*player.scale, 8*player.scale)
  end
 end
 if debug then
  circfill(player.x, player.y, player_radius, 8)
 end
end

function update_player_particles()
 if rnd(2) <= 1 * player.scale then
  local p = {
   x=player.x-rnd(3),
   y=player.y+rnd(8)-4,
   dx=-1*rnd(1.5)-0.5,
   dy=rnd(1)-0.5,
   life=60,
   to_remove=false,
   col=flr(rnd(3))+5
  }
  add(particles, p)
 end
 for p in all(particles) do
  p.x+=p.dx
  p.y+=p.dy
  p.life-=1
  if p.life<=0 then
   p.to_remove=true
  end
 end
end

-->8
--enemies

enemy_types = {
	basic={s={17,17,17,18}, shoot_time=120, speed=0.5, shot="target", anim_speed=10},
	laser={s={21,20,21,21,20,20,20}, shoot_time=480, speed=0.25, shot="laser", laser_ttl=180, anim_speed=15},
	split={s={33,33,34,33}, shoot_time=90, speed=0.5, shot="split", anim_speed=25},
  homing={s={49,50,49,49}, shoot_time=120, speed=0.5, shot="homing", anim_speed=10},
  big_trex={s={40}, shoot_time=30, speed=0.4, shot="target", sh=2, sw=2, anim_speed=10},
  big_split={s={42}, shoot_time=45, speed=0.4, shot="triple", sh=2, sw=2, anim_speed=10},
  big_laser={s={14}, shoot_time=300, speed=0.3, shot="laser", laser_ttl=180, sh=4, sw=2, anim_speed=10},
  big_homing={s={44}, shoot_time=120, speed=0.4, shot="quad_homing", sh=2, sw=2, anim_speed=10},
}

-- format
-- rotations are 0-1 anti-clockwise (0 is right, 0.25 is up, 0.5 is left, -0.25 is down)
-- start_x start_y start_rot [command]...
-- x=0, y=0 is top left - x increases to the right, y increases down (128x128)
-- commands
-- move [dist]
-- curve [direction] [angle] [radius]
-- formation [x] [y] [w] [h] [wait_time] [leaving_rot] [sync]

raw_patterns = {
	snake1="60 140 0.125 move 80 curve l 0.5 20 move 40 curve r 0.5 10 move 100",
	down="80 -10 -0.25 move 140",
	up="110 138 0.25 move 20",
	formation="135 64 -0.5 move 10 formation 90 55 2 4 7 0 true move 80",
	loop_de_loop="75 130 0.25 move 76 curve r 2 25 move 76",
	loop_de_loop2="75 130 0.25 move 76 curve r 1.5 19 move 76",
	up_right="80 136 0.25 move 50 curve r 0.125 10",
	down_right="80 -8 -0.25 move 50 curve l 0.125 10",
	trio="80 -8 -0.25 formation 70 55 1 3 14 0.25 false",
	small_formation="135 64 -0.5 move 10 formation 90 64 1 2 7 0 true move 80",
	round_into_formation="105 -4 -0.375 move 60 curve l 0.625 25 formation 90 55 1 3 4 0.25 true",
  up_turn="60 132 0.25 move 85 curve r 0.5 30",
  high_formation="90 -4 -0.25 formation 90 42 2 1 9 0.25 false",
  guard1="132 30 0 formation 90 30 2 1 8 0 true",
  guard2="132 80 0 formation 90 80 2 1 8 0 true",
  semi_circle_down="132 16 0.5 move 4 curve l 0.5 48",
  semi_circle_up="132 100 0.5 move 4 curve r 0.5 36",
  centre="64 -8 0.75 move 72 formation 64 64 1 1 5 0.25 false move 72",
  above_formation="134 -4 0 formation 105 19 1 1 5 0.25 false",
  below_formation="134 132 0 formation 105 93 1 1 5 -0.25 false",
  close1="80 -4 0.75 formation 80 16 1 1 2 0.75 false move 60 curve l 0.25 1",
  close2="80 132 0.75 formation 80 112 1 1 2 0.25 false move 35 curve r 0.125 1",
  up_down_up="115 138 0.25 move 110 curve l 0.5 5 move 75 curve l 0.5 5",
  snake2="90 -4 0.75 move 70 curve r 0.5 10 move 30 curve l 0.5 10",
}

start=1
-- time count type pattern wait_time shot_start
raw_levels = {
	{
		start=0,
		finish=41,
		spawns={
			"0 2 basic down 1.5 0",
			"7 2 basic small_formation 1 0",
			"16 3 basic snake1 1 60",
			"30 1 big_trex small_formation 0 0"
		},
		dust_freq=2,
		dust_variation=1,
		messages={
			"dinosaur defences operational",
			"they have power for 8 orbits",
			"avoid damage",
			"collect debris"
		}
	},
	{
		start=0,
		spawns={
			"0.75 1 split down 0.75 60",
			"0 2 basic down 1.5 60",
			"6 3 split round_into_formation 0.75 0",
			"19 3 split up_turn 1 0",
			"19 2 basic high_formation 1 0",
			"32 1 big_split small_formation 1 0",
			"31 2 basic guard1 0.5 0",
			"31 2 basic guard2 0.5 0"
		},
		finish=45,
		dust_freq=2,
		dust_variation=1
	},
	{
		start=0,
		spawns={
			"0 2 homing down 1.5 60",
			"5 2 homing up 1.5 60",
			"5.75 1 basic up 1.5 60",
      "11 2 split loop_de_loop2 2 0",
      "12 2 homing loop_de_loop2 2 0",
      "26 5 basic semi_circle_down 1.5 0",
      "26 5 homing semi_circle_up 1.5 0",
			"38 1 big_homing centre 1.5 0",
			"40 1 split up 0.75 0",
			"42 1 split down 0.75 0",
		},
		finish=53,
		dust_freq=2,
		dust_variation=1
	},
	{
		start=0,
		boss=true,
		boss_type=1,
		spawns={
		},
		finish=nil,
		dust_freq=2,
		dust_variation=1
	},
	{
		start=0,
		spawns={
			"0 1 laser up 0.5 300",
			"4 1 laser down 0.5 380",
      "10 4 basic formation 0.75 0",
			"12 1 laser above_formation 0.5 300",
			"12 1 laser below_formation 0.5 300",
      "20 1 laser close1 0 340",
      "20 1 laser close2 0 340",
      "30 1 big_laser up_down_up 0 120",
      "35 3 split snake2 2 0",
		},
		finish=52,
		dust_freq=2,
		dust_variation=1,
		messages= {
			"dinosaur defences weakening",
			"4 more orbits required",
		}
	},
	{
		start=0,
		spawns={
			"0 4 basic down 0.75 60",
			"5 4 basic up 0.75 60",
			"12 4 basic up_right 0.75 60",
			"12.4 4 basic down_right 0.75 60",
			"20 8 basic formation 0.6 0",
			"28 7 basic loop_de_loop 0.75 0",
			"45 3 basic trio 0.5 0",
			"48 1 big_laser up 0.5 120"
		},
		finish=65,
		dust_freq=2,
		dust_variation=1
	},
	{
		start=0,
		spawns={
			"0 1 split up_right 0 60",
			"0.75 1 homing down_right 0 60",
			"6 1 laser snake1 2 120",
			"7 6 homing up 3 120",
			"28 1 big_split semi_circle_down 0 0",
			"36 1 big_trex guard1 0.75 0",
			"36 1 big_trex guard2 0.75 15",
		},
		finish=48,
		dust_freq=2,
		dust_variation=1
	},
	{
		start=0,
		boss=true,
		boss_type=2,
		spawns={
		},
		finish=nil,
		dust_freq=2,
		dust_variation=1
	},
	{
		start=0,
		final=true,
		spawns={
		},
		finish=nil,
		dust_freq=2,
		dust_variation=10000,
		messages={
			"dinosaurs defences offline",
			"it is time"
		}
	},
}




enemies = {}
patterns = {}

enemy_anim_speed=30
function add_enemy(e_t, p_t, i, t_offset, shot_start)
 local e_stats=enemy_types[e_t]
 local p = patterns[p_t]
 local enemy = {
  x=p.start_x,
  y=p.start_y,
  rot=p.start_rot,
  shoot_timer=shot_start,
  shoot_time=e_stats.shoot_time,
  shot_type=e_stats.shot,
  to_remove=false,
  pattern=p,
  pi = 1,
  pd = 0,
  psx = p.start_x,
  psy = p.start_y,
  psr = p.start_rot,
  speed=e_stats.speed,
  i=i,
  waiting=false,
  t_offset=t_offset,
  anim_counter=0,
  frame=1,
  frames=e_stats.s,
  laser_ttl=e_stats.laser_ttl,
  sh=e_stats.sh or 1,
  sw=e_stats.sw or 1,
  anim_speed=e_stats.anim_speed
 }
 add(enemies, enemy)
end

function move_enemies()
 for e in all(enemies) do
  e.shoot_timer+=1
  if e.shoot_timer > e.shoot_time then
   
   local bx, by = e.x-e.sw*4, e.y+(e.sh-1)*4+2
   if e.shot_type=="target" then
   	sfx(32)
   	add_target_bullet(bx, by, player)
   elseif e.shot_type=="laser" then
    sfx(35)
    add_laser(e, e.laser_ttl)
   elseif e.shot_type=="triple" then
    sfx(32)
    add_bullet(bx, by, -0.5)
    add_bullet(bx, by, -0.4)
    add_bullet(bx, by, -0.6)
   elseif e.shot_type=="split" then
    sfx(32)
    add_bullet(bx, by, -0.4)
    add_bullet(bx, by, -0.6)
   elseif e.shot_type=="homing" then
    sfx(32)
    add_homing_bullet(bx, by, player, 0.5)
   elseif e.shot_type=="quad_homing" then
    sfx(32)
    add_homing_bullet(e.x, e.y, player, 0.125)
    add_homing_bullet(e.x, e.y, player, 0.375)
    add_homing_bullet(e.x, e.y, player, 0.625)
    add_homing_bullet(e.x, e.y, player, 0.875)
   end
   e.shoot_timer = 0
  end
  local move_to_next=false
  local c=e.pattern.commands[e.pi]
  e.pd += e.speed
  if not c then
   e.x += cos(e.rot) * e.speed
   e.y += sin(e.rot) * e.speed
  elseif c.what=="move" then
   e.pd = min(e.pd, c.dist)
   e.x = cos(e.rot) * e.pd + e.psx
   e.y = sin(e.rot) * e.pd + e.psy
   move_to_next = e.pd == c.dist
  elseif c.what=="curve" then
   local cx = e.psx+cos(e.psr+0.25*c.d)*c.radius
   local cy = e.psy+sin(e.psr+0.25*c.d)*c.radius
   e.cx=cx
   e.cy=cy
   
   local circum=2*pi*abs(c.radius)
   local dist=circum*c.angle
   e.pd = min(e.pd, dist)
   e.rot=e.pd/circum*c.d+e.psr
   e.x=cx+cos(e.rot+c.d*0.25*-1)*c.radius
   e.y=cy+sin(e.rot+c.d*0.25*-1)*c.radius
   move_to_next = e.pd == dist
  elseif c.what=="formation" then
   if e.waiting then
    local wait_time = c.wait_time
    if c.sync then
     wait_time-=e.t_offset
    end
    move_to_next = wait_time*60*e.speed <= e.pd
    e.rot= c.leaving_rot
   else
    local i = e.i-1
	   local row=i%c.h
	   local column=flr(i/c.h)
	   local target_x=c.x - 16*(c.w-1)/2+column*16
	   local target_y=c.y - 16*(c.h-1)/2+row*16
	   local angle=atan2(target_x-e.psx, target_y-e.psy)
	   local dsq=dist_sq(target_x, target_y, e.psx, e.psy)
	   if e.pd*e.pd >= dsq then
	    e.x=target_x
	    e.y=target_y
	    e.waiting=true
	   else
	    e.x=e.pd*cos(angle)+e.psx
	    e.y=e.pd*sin(angle)+e.psy
	   end
	  end
  end
  if move_to_next then
   e.pd = 0
   e.pi += 1
   e.psx = e.x
   e.psy = e.y
   e.psr = e.rot
   e.waiting=false
  end
  if e.pi > #e.pattern.commands then
   if not enemy_on_screen(e) then
    e.to_remove=true
   end
  end
  e.anim_counter+=1
  if e.anim_counter > e.anim_speed*2 then
   e.anim_counter=0
   e.frame+=1
   if e.frame>#e.frames then
    e.frame=1
   end
  end
 end
end

function draw_enemies()
 for e in all(enemies) do
  spr(e.frames[e.frame], e.x-e.sw*4, e.y-e.sh*4, e.sw, e.sh)
  if debug then
   pset(e.cx, e.cy, 8)
   for x=0,e.sw-1 do
    for y=0,e.sh-1 do
     circfill(e.x-e.sw*4+x*8+4, e.y-e.sh*4+y*8+4, 3)
    end
   end
  end
 end
end

function load_patterns()
 for name, rp in pairs(raw_patterns) do
  patterns[name]=parse_pattern(rp)
 end
end

function parse_pattern(raw)
 local parts = split(raw, " ")
 local p = {
  start_x=parts[1],
  start_y=parts[2],
  start_rot=parts[3]
 }
 local commands = {}
 local i = 4
 while i <= #parts do
  local cstr = parts[i]
  local command = {}
  if cstr=="move" then
   command={
    what="move",
    dist=parts[i+1]
   }
   i += 2
  elseif cstr=="curve" then
   command={
    what="curve",
    angle=parts[i+2],
    radius=parts[i+3],
    d=parts[i+1] == "r" and -1 or 1
   }
   i+=4
  elseif cstr=="formation" then
   command={
    what="formation",
    x=parts[i+1],
    y=parts[i+2],
    w=parts[i+3],
    h=parts[i+4],
    wait_time=parts[i+5],
    leaving_rot=parts[i+6],
    sync=parts[i+7]=="true"
   }
   i+=8
  elseif cstr=="point" then
   command={
    what="point",
    x=parts[i+1],
    y=parts[i+2],
    leaving_rot=parts[i+3]
   }
   i+=4
  else
   assert(false, cstr.." is not a command")
  end
  add(commands, command)
 end
 p.commands = commands
 return p
end

function enemy_on_screen(e)
 local w=e.sw*8
 local h=e.sh*8
 return not(e.x+w/2 < 0 or
            e.x-w/2 > 128 or
            e.y+h/2 < 0 or
            e.y-h/2 > 128)
end
-->8
-- bullets

bullets = {}
lasers = {}

bullet_speed = 1
bullet_radius = 1.5
function add_target_bullet(x, y, target)
 angle=atan2(target.x-x, target.y-y)
 local b = {
  x=x,
  y=y,
  dx=cos(angle)*bullet_speed,
  dy=sin(angle)*bullet_speed,
  to_remove=false,
  s=13
 }
 add(bullets, b)
end

function add_bullet(x, y, angle)
 local b = {
  x=x,
  y=y,
  dx=cos(angle)*bullet_speed,
  dy=sin(angle)*bullet_speed,
  to_remove=false,
  s=240
 }
 add(bullets, b)
end

laser_speed=4
function add_laser(owner, ttl, x_offset, y_offset)
 local l = {
 	owner=owner,
 	t=0,
 	width=0,
 	right=owner.x,
 	y=owner.y,
 	ttl=ttl,
 	live=false,
 	x_offset=x_offset or -(owner.sw)*4,
 	y_offset=y_offset or (owner.sh-1)*4
 }
 add(lasers, l)
end

homing_bullet_speed=1
homing_turn_rate=0.005
homing_ttl=140
function add_homing_bullet(x, y, target, angle)
 local b = {
  x=x,
  y=y,
  target=target,
  to_remove=false,
  s={26,27,28,29},
  angle=angle,
  age=0
 }
 add(bullets, b)
end

function move_bullets()
 for b in all(bullets) do
  if b.target then
   local x,y=b.target.x, b.target.y
   local bx,by=b.x, b.y
   local dx=cos(b.angle)*homing_bullet_speed
   local dy=sin(b.angle)*homing_bullet_speed
   local turn=(
    (x-bx)*dy-(y-by)*dx)
   turn=sgn(turn)
   b.angle+=turn*homing_turn_rate
   
   local factor=b.age/homing_ttl
   factor = 1-(factor*factor)
   local speed=homing_bullet_speed*factor
   b.x+=cos(b.angle)*speed
   b.y+=sin(b.angle)*speed
   b.age+=1
   if b.age>=homing_ttl then
    b.to_remove=true
   end
  else
	  b.x += b.dx
	  b.y += b.dy
	  if b.x < 0 or b.x > 128 or b.y < 0 or b.y > 128 then
	   b.to_remove=true
	  end
	 end
 end
 for l in all(lasers) do
  local e = l.owner
  l.y=l.owner.y+l.y_offset
  l.right=e.x+l.x_offset
  l.width=l.right
  l.t += 1
  if l.t > 45 and not l.live then
   l.live=true
   sfx(40)
  end
  if l.t >= l.ttl or e.to_remove then
   l.to_remove=true
  end
 end
 if #lasers == 0 then
  sfx(40, -2)
 end
end 


function draw_bullets()
 for b in all(bullets) do
  if b.target then
   spr(b.s[flr(b.age/10)%3+1], b.x-4, b.y-4)
  else
  	spr(b.s, b.x-4, b.y-4)
  end
  if debug then
   circfill(b.x, b.y, bullet_radius, 8)
  end
 end
 for l in all(lasers) do
  if not l.live then
   fillp(0x5f5f)
  end
  rectfill(l.right-l.width, l.y-1, l.right, l.y, 8)
  fillp(0)
 end
end
-->8
-- ui

intro_timer=nil
message_timer=nil
function draw_ui()
 local pp = flr(player.size)
 print("mass: "..pp.."kg", 2, 2, 7)
 if wave_state=="intro" then
  if current_level.boss then
   local t="! boss approaching !"
   print(t, 64-#t/2*4, 31, 5)
   print(t, 64-#t/2*4, 30, 10)
  elseif not current_level.final then
   print("orbit "..level_id, 52, 30+1, 5)
   print("orbit "..level_id, 52, 30, 7)
  end
 elseif wave_state=="messages" then
  local ms = current_level.messages
  for i=1,#ms do
   if message_timer/120>=(i-1) then
    local m=ms[i]
    print(m, 64-#m/2*4, 30+10*(i-1)+1, 1)
    print(m, 64-#m/2*4, 30+10*(i-1), 6)
   end
  end
 end
 if boss.active then
  local y=119
  local c=0
  if boss.boss_type==2 then
   y=10
   c=1
  end
  rectfill(4,y,124,y+6,c)
  rectfill(22,y+1,123,y+5,5)
  if boss.energy > 0 then
  	rectfill(22,y+1,22+(101)*boss.energy,y+5,3)
  end
  print("boss", 5, y+1, 6)
 end
end

function screen_shake(len)
 screen_shake_timer = len or 20
end

screen_shake_timer=0
function update_ui()
 if screen_shake_timer > 0 then
  camera(flr(rnd(3))-1,
         flr(rnd(3))-1)
  screen_shake_timer -= 1
  if screen_shake_timer <= 0 then
   camera()
   screen_shake_timer=0
  end
 end
 if wave_state=="intro" then
  intro_timer+=1
  if intro_timer > 240 then
   intro_timer=nil
   start_spawning()
  end
 end
 if wave_state=="messages" then
  message_timer+=1
  if message_timer > (#current_level.messages+1)*120 then
   message_timer=nil
   intro_timer=0
   wave_state="intro"
  end
 end
end

function start_title_screen()
 scene="title"
 init_player()
 player.x=64
 player.y=64
 if play_music then
  music(26)
 end
end

title_timer=0
function update_title_screen()
 update_player_state()
 if btnp(—) then
  move_to_game()
 end
 title_timer+=1
 player.y=72+sin(title_timer/180)*4
end

function draw_title_screen()
 cls()
 draw_bg()
 local x=(244*8)%128
 local y=flr(244*8/128)*8
 
 sspr(x, y, 6*8, 8, 64-24*2, 15, 6*16, 16)
 
 
 local x=(250*8)%128
 local y=flr(250*8/128)*8
 sspr(x, y, 6*8, 8, 64-24*2, 15+16, 6*16, 16)
 
 printc("cheek-sha-loob", 46, 8)
 
 draw_player()
 
 local text_y=95
 local t="press — to start"
 for x=-1,1 do
  for y=-1,1 do
   print(t, 30+x, text_y+y, 5)
  end
 end
 print(t,
       30,
       text_y,
       6+flr(title_timer/45)%2)
end
-->8
--tools
pi=3.141596

function printc(t, y, c, oc)
 local x=64-#t*2
 if oc then
  printo(t,x,y,c,oc)
 else
  print(t, x, y, c)
 end
end

function printo(t, x, y, c, oc)
 for dx=-1,1 do
  for dy=-1,1 do
			print(t, x+dx, y+dy, oc)
  end
 end
 print(t, x, y, c)
end

function choose(l)
 return l[flr(rnd(#l))+1]
end

function dist(x1, y1, x2, y2)
 return sqrt(dist_sq(x1, y1, x2, y2))
end

function dist_sq(x1, y1, x2, y2)
 local dx = x1 - x2
 local dy = y1 - y2
 return dx * dx + dy * dy
end

function c_overlap(c1, r1, c2, r2)
 local dx = c1.x - c2.x
 local dy = c1.y - c2.y
 if (dx + dy) > (r1 + r2)*2 then
  return false
 end
 local dsq = dist_sq(c1.x, c1.y, c2.x, c2.y)
 local rsq=  (r1+r2) * (r1+r2)
 return dsq <= rsq
end

function point_in_circ(px, py, cx, cy, r)
 return dist_sq(px, py, cx, cy) <= r*r
end

function point_in_rect(px, py, left, right, top, bottom)
 return (px >= left and px <= right and
         py <= bottom and py >= top) 
end

function circ_rect(cx, cy, cr, left, right, top, bottom)
 return (point_in_circ(cx, cy, left, top, cr) or
         point_in_circ(cx, cy, right, top, cr) or
         point_in_circ(cx, cy, left, bottom, cr) or
         point_in_circ(cx, cy, right, bottom, cr) or
         point_in_rect(cx, cy, left-cr, right+cr, top, bottom) or
         point_in_rect(cx, cy, left, right, top-cr, bottom+cr))
end

function cleanup(l)
 for i=#l,1,-1 do
  if l[i].to_remove then
   deli(l, i)
  end
 end
end

function tbl2str(t)
 return "\n".._tbl2str(t, "")
end

function _tbl2str(t, prefix)
 str = "{\n"
 for k, v in pairs(t) do
  if type(v) == "table" then
   str=str..prefix.." "..tostr(k)..": ".._tbl2str(v, prefix.." ")
  else
   str=str..prefix.." "..tostr(k)..": "..tostr(v)..",\n"
  end
 end
 str=str..prefix.."},\n"
 return str
end

-- common comparators
function  ascending(a,b) return a<b end
function descending(a,b) return a>b end

-- a: array to be sorted in-place
-- c: comparator (optional, defaults to ascending)
-- l: first index to be sorted (optional, defaults to 1)
-- r: last index to be sorted (optional, defaults to #a)
function qsort(a,c,l,r)
    c,l,r=c or ascending,l or 1,r or #a
    if l<r then
        if c(a[r],a[l]) then
            a[l],a[r]=a[r],a[l]
        end
        local lp,rp,k,p,q=l+1,r-1,l+1,a[l],a[r]
        while k<=rp do
            if c(a[k],p) then
                a[k],a[lp]=a[lp],a[k]
                lp+=1
            elseif not c(a[k],q) then
                while c(q,a[rp]) and k<rp do
                    rp-=1
                end
                a[k],a[rp]=a[rp],a[k]
                rp-=1
                if c(a[k],p) then
                    a[k],a[lp]=a[lp],a[k]
                    lp+=1
                end
            end
            k+=1
        end
        lp-=1
        rp+=1
        a[l],a[lp]=a[lp],a[l]
        a[r],a[rp]=a[rp],a[r]
        qsort(a,c,l,lp-1       )
        qsort(a,c,  lp+1,rp-1  )
        qsort(a,c,       rp+1,r)
    end
end
-->8
-- waves
wave_state=nil
level_id=nil
current_level=nil
enemy_spawns=nil
next_dust=nil
spawn_timer=nil

boss_music_playing=false

function load_enemy_spawns()
 local raw_spawns=current_level.spawns
 enemy_spawns={}
 for raw_wave in all(raw_spawns) do
  local parts = split(raw_wave, " ")
  for i=1,parts[2] do
   local spawn={
    t=parts[1] + (i-1) * parts[5],
    e_t=parts[3],
    p_t=parts[4],
    i=i,
    t_offset=parts[5]*(i-1),
    shot_start=parts[6]
   }
   add(enemy_spawns, spawn)
  end
 end
 qsort(enemy_spawns, function(a,b) return a.t < b.t end)
end

function load_level(id)
 level_id=id
 current_level=raw_levels[id]
 load_enemy_spawns()
 next_dust=get_time_to_dust()
 spawn_timer=0
 if current_level.boss then
  boss_music_playing=true
  if (play_music) then music(35) end
 elseif boss_music_playing then
  if (play_music) then music(0) end
  boss_music_playing=false
 end
 if current_level.final then
  start_finale()
 end
 if current_level.start == 0 then
  if current_level.messages then
   wave_state="messages"
   message_timer=0
  else
   wave_state="intro"
   intro_timer=0
  end
 else
  start_spawning()
	 local frames = current_level.start*60
	 while frames > 0 do
	  spawn()
	  move_enemies()
	  move_bullets()
	  move_pickups()
	  if boss.active then
	   move_boss()
	  end
	  cleanup(enemies)
	  cleanup(bullets)
	  cleanup(lasers)
	  cleanup(pickups)
	  frames-=1
	 end
	end
end

function start_spawning()
 wave_state="spawning"
 if current_level.boss then
  if current_level.boss_type==1 then
   init_boss1()
  else
   init_boss2()
  end
 end
end

function spawn()
 spawn_enemies()
 spawn_pickups()
 
 spawn_timer+=1/60
 
 if current_level.finish and spawn_timer >= current_level.finish then
  next_level()
 end
end

function spawn_enemies()
 while #enemy_spawns>0 and enemy_spawns[1].t <= spawn_timer do
  local s=enemy_spawns[1]
  add_enemy(s.e_t, s.p_t, s.i, s.t_offset, s.shot_start)
  deli(enemy_spawns, 1)
 end
end

function get_time_to_dust()
 return rnd(current_level.dust_variation) + current_level.dust_freq
end

function spawn_pickups()
 if spawn_timer >= next_dust then
  add_dust()
  next_dust = spawn_timer + get_time_to_dust()
 end
end

function next_level()
 level_id+=1
 if level_id > #raw_levels then
  level_id=1
 end
 load_level(level_id)
end
-->8
-- gfx

stars={}

star_count=600
function load_stars()
 for i=1,star_count do
  add(stars, {r=rnd(350), theta=rnd(1),
              c=choose({5, 6, 7})})
 end
end

star_rot=0
function draw_bg()
 draw_stars()
 draw_finale_explosion()
 draw_planet()
end

function draw_stars()
 star_rot+=1/200*1/100
 for s in all(stars) do
  pset(cos(s.theta+star_rot)*s.r+64, sin(s.theta+star_rot)*s.r+256-24, s.c)
 end
end

fade_to_black={7,6,6,6,6,13,13,13,5,5,5,1,1,0,0}
function draw_finale_explosion()
 
 if finale_state=="explode" then
  circfill(64, 128-12, min(finale_timer*4, 50), 7)
 end
 if finale_state=="fade_out" then
  circfill(64, 128-12, 50+finale_timer*6, 7)
 end
 if finale_state=="wait2" then
  circfill(64, 128-12, 256, 7)
 end
 if finale_state=="fade_in" then
  
  local c=fade_to_black[
    flr(#fade_to_black*finale_timer/30)+1]
  circfill(64, 128-12, 256, c)
 end
end

planet = {
 x=64,
 y=370,
 r=256
}
planet_rot=0
planet_fade={1,1,5,5,13,13,13,13,13,6,6,6,6,6,7}
function draw_planet()
 planet_rot+=1/16 * 1/60
 local c=1
 if finale_state=="fade_out" then
  c=planet_fade[min(#planet_fade, flr(finale_timer/2)+1)]
 end
 if finale_state=="fade_in" then
  c=planet_fade[#planet_fade-flr(#planet_fade*finale_timer/30)]
 end
 if finale_state!="wait2" then
  circfill(planet.x, planet.y, planet.r, c)
 end
end
-->8
-- pickups

pickups={}

function add_dust()
 local y=rnd(128)
 local d={
  x=140,
  y=y,
  dx=-1*(rnd(0.3)+0.1),
  dy=rnd(0.1)+(0.1 * -y/128),
  s=choose({51,52,53}),
  radius=5,
  to_remove=false,
  t="dust"
 }
 add(pickups, d)
end

function move_pickups()
 for p in all(pickups) do
  p.x += p.dx
  p.y += p.dy
 end
end

function draw_pickups()
 for p in all(pickups) do
  spr(p.s, p.x-3, p.y-3)
 end
end
-->8
-- boss
boss={active=false}
function init_boss1()
 sfx(45)
 boss={
	 x=128+32,
	 y=56,
	 active=true,
	 frame=1,
	 anim=0,
	 phase="intro",
	 d=-1,
	 energy=1,
	 hitboxes={},
	 laser_timer=0,
	 spiral_timer=0,
	 fire_timer=0,
	 homing_timer=0,
	 boss_type=1
	}
end

function init_boss2()
 sfx(47)
 boss={
	 x=64,
	 y=128+3.5*8,
	 active=true,
	 head_frame=1,
	 tail_frame=1,
	 head_anim=0,
	 tail_anim=0,
	 phase="intro",
	 d=-1,
	 energy=1,
	 hitboxes={boss2_hitboxes},
	 bob_timer=0,
	 homing_timer=0,
	 spiral_timer=0,
	 fire_timer=0,
	 boss_type=2,
	 sfx_timer=0,
	}
end

function move_boss()
 if boss.boss_type==1 then
  move_boss1()
 else
  move_boss2()
 end
end

function move_boss1()
 if boss.phase=="intro" then
  boss.x-=0.2
  if boss.x<=96 then
   boss.x=96
   boss.phase="bob"
   sfx(45)
  end
 elseif boss.phase=="outro" then
  boss.x+=0.2
  if boss.x>=128+36 then
   boss.x=128+32
   boss.active=false
   next_level()
  end
 elseif boss.phase=="bob" then
  boss.y+=boss.d*0.05
  if boss.y < 42 then
   sfx(45)
   boss.y=42
   boss.d=1
  elseif boss.y > 68 then
   boss.y=68
   boss.d=-1
  end
  boss.laser_timer+=1
  if boss.laser_timer==60 then
   add_laser(boss, 180, -22, -20)
   sfx(35)
  end
  if boss.laser_timer>=360 then
   boss.laser_timer=0
  end
  local gx, gy= boss.x-14, boss.y+16
  boss.spiral_timer+=1
  if boss.spiral_timer >= 0 and boss.spiral_timer < 120 then
   if boss.spiral_timer%10==0 then
    local angle=0.75 - 0.5*(boss.spiral_timer/120)
    add_bullet(gx, gy, angle)
    sfx(32)
   end
  end
  if boss.spiral_timer >= 420 then
   boss.spiral_timer=0
  end
  boss.fire_timer+=1
  if boss.fire_timer >= 30 then
   boss.fire_timer =0
   add_target_bullet(gx, gy, player)
   sfx(32)
  end
 end
 if boss.phase != "intro" then
  boss.energy -= 1/60 * 1/30
  if boss.energy <= 0 then
   boss.phase="outro"
   boss.energy=0
  end
 end
 boss.anim+=1
 if boss.anim > 20 then
  boss.anim=0
  boss.frame=3-boss.frame
  if boss.frame==1 then
   boss.y-=2
   boss.hitboxes={body_hitboxes,
                  wing_down_hitboxes}
  else
   boss.y+=2
   boss.hitboxes={body_hitboxes,
                  wing_up_hitboxes} 
  end
 end
end

function move_boss2()
 if boss.phase=="intro" then
  boss.y-=0.2
  if boss.y<=100 then
   boss.y=100
   boss.phase="bob"
   sfx(47)
  end
 elseif boss.phase=="outro" then
  boss.y+=0.2
  if boss.y>=128+3.5*8 then
   boss.y=128+3.5*8
   boss.active=false
   next_level()
  end
 elseif boss.phase=="bob" then
  boss.bob_timer+=1
  if boss.bob_timer == 45 then
   boss.y+=1
  elseif boss.bob_timer >= 90 then
   boss.bob_timer=0
   boss.y-=1
  end
  
  local gx, gy= boss.x-8, boss.y-10
  boss.spiral_timer+=1
  if boss.spiral_timer >= 0 and boss.spiral_timer < 120 then
   if boss.spiral_timer%10==0 then
    local angle=0.5 - 0.5*(boss.spiral_timer/120)
    add_bullet(gx, gy, angle)
    sfx(32)
   end
  end
  if boss.spiral_timer >= 360 then
   boss.spiral_timer=0
  end
  local gx, gy= boss.x+13, boss.y-18
  boss.fire_timer+=1
  if boss.fire_timer >= 25 then
   boss.fire_timer =0
   add_target_bullet(gx, gy, player)
   sfx(32)
  end
  local gx, gy= boss.x+37, boss.y-10
  boss.homing_timer+=1
  if boss.homing_timer >= 120 then
   if boss.homing_timer%30==0 then
    add_homing_bullet(gx, gy, player, 0.25)
    sfx(32)
   end
   if boss.homing_timer >=180 then
    boss.homing_timer=0
   end
  end
  boss.sfx_timer+=1
  if boss.sfx_timer >= 240 then
   sfx(47)
   boss.sfx_timer=0
  end
 end
 if boss.phase == "bob" then
  boss.energy -= 1/60 * 1/40
  if boss.energy <= 0 then
   boss.phase="outro"
   boss.energy=0
   sfx(47)
  end
 end

 boss.head_anim+=1
 if boss.head_anim > 16 then
  boss.head_anim=0
  boss.head_frame+=1
  if boss.head_frame>#boss_head_frames then
   boss.head_frame=1
  end
 end
 boss.tail_anim+=1
 if boss.tail_anim > 32 then
  boss.tail_anim=0
  boss.tail_frame+=1
  if boss.tail_frame>#boss_tail_frames then
   boss.tail_frame=1
  end
 end
end

boss_gfx={
 {w=2,h=2,x=0,y=8,g=64,f=96},
 {w=2,h=2,x=16,y=8,g=66,f=66},
 {w=1,h=1,x=24,y=16,g=83,f=114},
 {w=4,h=4,x=32,y=8,g=68,f=72},
 {w=4,h=3,x=24,y=40,g=192,f=128},
 {w=1,h=1,x=16,y=24,g=-1,f=98},
 {w=1,h=2,x=24,y=24,g=-1,f=99},
 {w=2,h=1,x=48,y=0,g=242,f=-1},
 {w=1,h=1,x=48,y=64,g=-1,f=179},
 {w=1,h=1,x=16,y=40,g=176,f=176},
 {w=1,h=1,x=16,y=48,g=177,f=177},
}

--note - need to take 72 off y
boss2_gfx={
 {x=64, y=88, w=8, h=5,
  speed=8, frames={168}},
  
 {x=64, y=72, w=4, h=2,
  speed=8, frames={136}},
  
 {x=48, y=88, w=2, h=2,
  speed=8, frames={166}},
  
 {x=32, y=104, w=4, h=3,
  speed=8, frames={196}},
  
 {x=16, y=104, w=2, h=2,
  speed=8, frames={134}},
}

boss_head_frames={140,140,140,
  076,108,108,076,108}
  
boss_tail_frames={132,164}

function draw_boss()
 if boss.boss_type==1 then
  draw_boss1()
 else
  draw_boss2()
 end
 if debug then
  for hs in all(boss.hitboxes) do
	  for h in all(hs) do
	   if h.t=="circ" then
	    circfill(boss.x+h.x, boss.y+h.y, h.r, 8)
	   elseif h.t=="rect" then 
	    rectfill(boss.x+h.x0, boss.y+h.y0,
	             boss.x+h.x1, boss.y+h.y1, 8)
	   end
	  end
  end
 end
end

function draw_boss1()
 for gfx in all(boss_gfx) do
  local s
  if boss.frame==2 then
   s=gfx.g
  else
   s=gfx.f
  end
  spr(s,boss.x-4*8+gfx.x,
        boss.y-4*8+gfx.y,
        gfx.w, gfx.h)
 end
end

boss2_w=16
boss2_h=7
function draw_boss2()
 local bx=boss.x-4*boss2_w
 local by=boss.y-4*boss2_h
 for gfx in all(boss2_gfx) do
  spr(gfx.frames[1],
      bx+gfx.x,
      by+gfx.y-72,
      gfx.w, gfx.h)
 end
 spr(boss_head_frames[boss.head_frame],
     bx+96, by+0, 4, 2)
 spr(boss_tail_frames[boss.tail_frame],
     bx+0, by+32, 2, 2)
end


body_hitboxes={
 {t="circ", x=-27, y=-14, r=2},
 {t="circ", x=-23, y=-17, r=2},
 {t="circ", x=-19, y=-20, r=3},
 {t="rect", x0=-16, y0=-21, x1=-3, y1=-17},
 {t="circ", x=-1, y=-20, r=3},
 {t="circ", x=7, y=-21, r=3},
 {t="circ", x=4, y=-16, r=5},
 {t="circ", x=9, y=-11, r=5},
 {t="circ", x=12, y=-6, r=5},
 {t="circ", x=13, y=0, r=6},
 {t="circ", x=14, y=11, r=8},
 {t="rect", x0=-3, y0=13, x1=3, y1=22},
 {t="rect", x0=3, y0=19, x1=14, y1=22},
}

wing_down_hitboxes={
 {t="circ", x=7, y=-2, r=13},
 {t="circ", x=19, y=21, r=5},
}

wing_up_hitboxes={
 {t="circ", x=23, y=-16, r=11}
}

boss2_hitboxes={
 {t="circ", x=14, y=7, r=26},
 {t="rect", x0=32, y0=-24, x1=64, y1=20},
 {t="rect", x0=-64, y0=8, x1=64, y1=19},
}
-->8
--finale

function reset_finale()
 in_finale=false
 finale_timer=0
 finale_state=nil
end

function start_finale()
 finale_timer=0
 in_finale=true
 finale_state="reset_player"
 if (play_music) then music(53) end
end

function update_finale()
 local ex,ey=16,64
 if finale_state=="reset_player" then
  finale_timer+=1
  local angle=atan2(ex-player.x,ey-player.y)
  if dist(ex, ey, player.x, player.y) <= player_speed/2 then
   player.x=ex
   player.y=ey
   finale_state="wait1"
  else
   player.x+=cos(angle)*player_speed/2
   player.y+=sin(angle)*player_speed/2
  end
 elseif finale_state=="wait1" then
  finale_timer+=1
  if finale_timer >= 360 then
   finale_timer=0
   finale_state="crash"
  end
 elseif finale_state=="crash" then
  finale_timer+=1
  player.scale=sqrt(1-finale_timer/180)
  player.x=ex+finale_timer*(48/180)
  player.y=ey+(1-cos(finale_timer/720))*52
  if finale_timer >= 180 then
   finale_state="explode"
   screen_shake(120)
   finale_timer=0
   sfx(41)
  end
 elseif finale_state=="explode" then
  finale_timer+=1
  if finale_timer==100 then
   sfx(42)
  end
  if finale_timer>=120 then
   finale_state="fade_out"
   finale_timer=0
  end
 elseif finale_state=="fade_out" then
  finale_timer+=1
  if finale_timer>=120 then
   finale_state="wait2"
   finale_timer=1
  end
 elseif finale_state=="wait2" then
  finale_timer+=1
  if finale_timer >= 60 then
   finale_timer=0
   finale_state="fade_in"
  end
 elseif finale_state=="fade_in" then
  finale_timer+=1
  if finale_timer>=30 then
   reset_finale()
   start_end()
  end
 end
end

function draw_end()
 cls()
 draw_bg()
 printc("upon collision, your mass was:",
        16, 6)
 if text_idx>=1 then
  printc(player.size.." kg", 28, 6, 5)
 end
 if text_idx>=2 then
  printc("which wiped out",
        48, 6)
 end
 local perc=mid(0, 100, flr((player.size-10000)/150))
 if text_idx>=3 then
  printc(perc.."%",60,6,5)
  printc("of the dinosaurs",
        72, 6)
 end
 if text_idx>=4 then
  printc("thanks for playing!",
         98, 6)
  printo("press —", 94, 120, 6, 5)
 end
end

function start_end()
 end_timer=0
 end_state="start"
 scene="end"
 text_idx=0
end

function update_end()
 end_timer+=1
 text_idx=flr(end_timer/90)
 if btnp(—) then
  if end_timer < 4*90 then
   end_timer=5*90
  else
   start_title_screen()
  end
 end
end
__gfx__
00888800000000000000000000666000006666000006660000000000000000000000000000666000006666000006660000000000000000000000000000000000
08000080065666600665660006666500065566600065566000665560065666600665660006665500066565600066566000665660000000000000000000000000
80000808666656666666656006556660065566500665566006565566656665566656666006566660065566500665565005665566000990000000000000000000
80008008666655656556655506556660066666600666665065666665666665556666655505566650066666600666665066666665009889000000000000000000
80080008655666656556666506666550066655500566665066666665665566656556655506665550066666500566665066666655009889000000cccccccc0000
8080000865566655066665550666655005665650056556506655655066656655065666550666555005665550066556506655655000099000000cccccccccc000
0800008006665550006655500055655006566550066565000665550006665550006655500056655006665550066555000655550000000000000cccccccccc000
0088880000000000000000000005550000655500006550000000000000000000000000000006550000655500006550000000000000000000000ccccc11ccc000
00ccc00000000000000000000cc0000000cccc0000cccc00000ff00000000000000000000000000000000000000000000000000000999000000cccc1111cc000
0cc03c0000cccc0000cccc00c01c00000cc01cc00cccccc000f7ff00000ff000000ff000000ff0000000000000000000009990000900090000cccc111111cc00
0c333c000cc03cc00cccccc0c11c00000cc11cc00c01ccc000f7ff000fffff0000ffff0000ff7ff00000000000990000090779000000009000cccc111111cc00
00c656030c333cc00cc03cc00c1c00000ccc1cc00c11ccc00f7ffff0fffffff00ffffff00ffff77f0008800009778000907879000008809000cccc1111111c00
055566330ccb36c00c333cc00c1c00110ccc16c00cc116c00ffffff0f77ffff00ffff7f00fffffff0007800009788000907880000008000000cc1011cc111c00
0006633055cb335555cb36550066611055cc115555cc115500ffff000ff7ff0000ff7f0000fffff00000000009000000007000700000000700cc1011cc111c00
000050005555555555555555006666005555555555555555000ff000000ff00000ff7f00000ff0000000000000000000000777000700007000c11111cc111c00
0005500005555550055555500050050005555550055555500000000000000000000ff000000000000000000000000000000000000070000000c11111cc111c00
00caaa000000000000000000000cc0000000000000000000000cc8cc000cc8cc00000000000000000000000000000000000000000000000000c6161ccc111c00
0cc09c0000cccc0000cccc0000cc8c0000cccc0000cc8c0000cc778c00cc778c0000000000000000000000000000000000000000000000000ccccccccc111cc0
0ca99c000ccaaac00caaacc00cc778c00ccc8cc00cc778c000c9708c00c9708c0000cccccccc00000000cccccccc00000000cccccccc00000cccccccccc111c0
00c656000cc09cc00cc90cc00c9708c00cc778c00c9708c0555c7765a55c7765000ccc3333ccc000000ccccaaaacc000000cccccccccc0000cccccccccc111c0
055566000ca996c00cc99ac000c77c000c9708c00cc77cc055555555a5555555000c333033ccc000000cccca99cac000000cccccccccc0000cccccccc11111c0
0006699955cc995555cc99550776677055c77c5555c77c55005555550055555500cc333333cccc0000cccc9099cccc0000ccccc22ccccc000cccc611111111c0
00005000555555555555555500766700555555555555555500d1d1d1001d1d1d00cccbb333cccc0000ccaa9999cccc0000c2222022cccc000ccc0611111111c0
000550000555555005555550000990000555555005555550006d6d6d00d6d6d60cccccb3333cc3c00ccc449999ccccc00cc76762222cccc00cc00cc1111111c0
0000000000000000000000005000000030000000d0000000000cc8cc000cc8cc0cccc33b333c33c00cccccc9999cc9c00ccc2222222cc2c00cc0cccc111111c0
000cc00000cccc0000cccc00000506400000b0f000000e2000cc778c00cc778c0cc00ccb333c33c00cc0099a999c99c00ccccccc622cc2c00550ccccc1111550
00c02c000cccccc00cc2ccc0064005400b3003000e200d2000c9778c00c9708c0550cccb333335500550ccca999c9550055ccc02622c255005555cccc1111550
0c222c000cc02cc00c220cc0045050000f30300002d0d000655c7765555c77657555555555555558755555555555555875555555555555587555555555555558
00c656000c2226c00cc226c000000005000000030000000d655555555555555575d66dddddd66d5875d66dddddd66d5875d66dddddd66d5875d66dddddd66d58
0555660055cc225555cc2255050065000300b3000d00ed00005555550055555555dddd6666dddd5555dddd6666dddd5555dddd6666dddd5555dddd6666dddd55
00005220555555555555555506605400fbb03f000ee0d20000d6d6d6006d6d6d0555555555555550055555555555555005555555555555500555555555555550
000550020555555005555550600000050000000000d00000001d1d1d00d1d1d10055550000555500005555000055550000555500005555000055550000555500
00000000000000000000000000000600000600ddd0000ddddddd1111111111110006000ddd000000000000000000000000000000000000000000000000000000
00000000000ddddd00000000000060dddd600ddddd00dd66dd11111111111111dd6000ddddd00000000000000000000000000000000000000000000000000000
0000000000dddddd000060000060ddddddd00ddddddd666dd111111111111111ddd000ddddd66600000000000000000000000000000000000000000000000000
0000000000dddddddd06000006ddddddddd00ddddd6666ddd111111111111111ddd000dddddd6000000000000000000044400000000000000000000000000000
0000000000d117dddddd00600ddddddddddddddddd66dddd1111111111111111ddddddddddddd000000000000000000044444000000000044444440000000000
00000000ddddddddddddd600dddddddddddddddddddddd111111111111111111ddddddddddddddd6660000000000000044444444000000444444444400000000
0000000ddddddddd22dddd0dddd222ddddddddddddddd1111111111111111111dddddddddddddddd600000000000000077444444440044447144444440000000
000000dddddddd20002dddddddd20222ddddddddddddd1111111111111111111dddddddddddddddd000000000000000070676444444444444111444444000000
00000ddddd22d2200002ddddd220002222dddddddddd111111111111111111112dddddddddddddddd00000000000000000070767444444444444444444000000
0000dddd222222200000222220000002222dddddddddd11111111111111111112ddddddddddddddddd6660000000000000000707674444444444444444000000
000ddd22200000000000022200000000022222222ddddd111111111111111111ddddd66dddddddddddd6000000000000007070000767444444444444444f0000
00dd22200000000000000000000000000022222222dddd111111111111111111dddd66ddddddddddddd0000000000000007070707070706044444444444ffee0
0dd22000000000000000000000000000000222222222ddd11111111111111111ddd66dddddddddddddd00000000000000676767676767676444444444444ffee
d2200000000000000000000000000000000022222222dddd1111111111111111dd666ddddddddddddddd66000000000004444444444444444444444444444ffe
000000000000000000000000000000000000222222222ddd1111111111111122d666dddddddddddddddd600000000000e444444444444444444444499944444f
000000000000000000000000000000000000022222222ddd1111111111112222666dddddddddddddddddd00000000000ee444444444444444444499999944444
0000000000000000000000000000dddd00000222222222dddd11111112222222666dddddddddddddddddd0000000000000444400000000000000000000000000
00000000000ddddd00000d00000dddd600000022222222dddd1111112222222266ddddddddddddddddddd6660000000000444440000000000000000000000000
0000000000dddddd0000d0dd00dddd6600000022222222ddddd11122222222006dddddddddddddddddddd6600000000000744444400000000000000000000000
0000000000dddddd0000000dd0ddd666000000022222222dddd11222222220006dddddddddddddddddddd6000000000007007444444000044444400000000000
0000000000d887dd00000dddddddd666000000022222222ddddd222222220000ddddddddddddddddddddd0000000000000070644444404444444444000000000
00000000dddddddd0000d000dddd666d000000022222222ddddd222222000000ddddddddddddddddddddd0000000000000000076444444447144444400000000
0000000ddddddddd00000000dddd666d000000022222222ddddd222220000000ddddddddddddddddddddd6660000000000000700744444444114444440000000
000000dddddddd200000000000dd66dd000000022222222ddddd222000000000ddddddddddddddddddd226600000000000000007067444444411444444000000
00000ddddd00d2200000000000ddd6dd0000000022222222dddd222000000000dddddddddddddddddd2226000000000000000000070674444444444444000000
0000dddd000022200000000000dddddd0000000022222222dddd220000000000ddddddddddddddddd22220000000000000000000000706744444444444000000
000ddd00000200000000000000dddddd0000000022222222dddd220000000000ddddddddddddddddd22222000000000000707000000000074444444444440000
00dd0000002000000000000d000ddddd0000000022222222dddddd6600000000ddddddddddddddddd2222266000000000070707070707000044444444444fee0
0dd00000220000000000000d000ddddd0000000022222222ddddd66000000000dddddddddddddddddd2222600000000006767676767676764444444444444fee
d000002200000000000000dd000ddddd0000000022222222ddddd60000000000dddddddddddddddddd22220000000000044444444444444444444444444444fe
0000220000000000000000dd0000dddd000000022e222222ddddd00000000000dddddddddddddddddd22220000000000e444444444444444444444499944444f
000000000000000000000ddd000000dd0000002ee2222222ddddd00000000000dddddddddddddddddd22220000000000ee444444444444444444499999944444
00000000dddddddddddddddddd222266000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddddddddddddddd22260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddddddddd22200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ddddddddddddddd22220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dddddddddddddd2222000eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55000000000002ddddddddddddd22220eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000444444444400000000
555500111100002dddddddddddd22220eeffff4eeee00000000000000000000e0000000000000000000000000000000000000000000044444444444440000000
5855555000110022ddddddddddd22220f44444444eeee0000000eeeeeeeeeeee0000000000000000000000000000000000000000004444471114444444000000
a5a555ddd01111022dddddddddd2222000000444444eeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000004444444444444444444444444000000
58555d55ddd1110022ddddddddd22220000000044444444eeeeee4444444444400000000008888800eeeeee00000000044444444444444444444444444000000
5555d5555dd01110112dddddddd2222200000000444444444444444444444444000000011888888811eeeeeeeee000004444444444444444444444444fff0000
666d555dddddd111112ddddddddd222200000000044444444444444444444444000000065188888155eedeeeeeeee00067676767676767644444444444fffee0
666d65d55dddd11111d2dddddddd222200000000000444444444444444444444000000065511111551eedeeeeedeeee00676767676767676444444444444ffee
550d6d655ddddddddddd2ddddddd2222000000000000ee444444444444444444000000e65555555111eedeeeeedeeeee04444444444444444444444444444ffe
55000d66d555ddddddddd2dddddd222200000000000000eeeeeee44444444444000eeeee655551111eeedeeeedeeeeeee44444444444444444444449994444ff
5550006d655500dddddddd2ddddd222200000000000000000000eeeeeeeeeeee0eeeeeed655551111eeedeeeedeeeeeeee444444444444444444499999944444
6550000d6555000dddd00002dddd222200000000000000000000000000000000eeedeeed655551111eeedeeeedeeeedeeee00000000000000044999999999444
6555000005550000000000002ddd222200000000000000000000000000000eeeeeedeeed655551111eeedeeedeeeedeeeee00000000000000000444999999944
0655500002222220000000002dddd2220000000000000000000000000881eeeeeeedeeee655551111eedeeeedeeeedeee5180000000000000000004499999994
006555002dddddd22000000022ddd2220000000000000000000000088811eeedeeeedeee655551111eedeeeedeeedeee5511800000000000000000e449999999
00065500d55500ddd22000022d2dd22200000000000000000000008881511eedeeeedeee655551111eedeeedeeeedee6555118000000000000000ee444999999
0000555005550000dd222222dd02d22200000000000000000000001115511eeedeeedee65555551111edeeedeeedee655555110000000000eeeeeee444499999
00000555550d00000ddddddd00002222000000000000000000000e65555111eedeeedee655555511111deedeeedee655555555e0000000eeeeeeeee444499999
0000000000000000000000000000022200000000eeeee000000eee65555111eeedeeed6555555511111deedeeede655555511ee00000eeeeeeeeeef444499999
00000000000005550000000000000022000000eeeeeeeeee000eeee6555111eeedeeed6555555511111deedeede6555555511ee0000eeeeeeeeeeff444999999
000000000000055800000000000000220000eeeeef44444e000edee65555111eedeeed65555555511111edeeed6555555511ede00eeeeeeeeeffff4449999999
0000000000555555000000000000000200eeeeeff444444400eedee65555111eeedee6555555555111111deed65555555511ed8008eeeeeffffff44499999990
00000000000566660000000000000002eeeeef444444444400eeed6555551111eedee6555555555111115555555555555111de808eeeeeffff44444499999990
00000000055555660000000000000002eef444440004444400eeed6555555111eee66655555555555555555555555555111ed8558eefffff4444444999999990
05555555000000550000000000000000444400000000ee440088ee65555551111e655555555555555555555555555551111de55584ff44444444449999999900
0005555500000005000000000000000000000000000000ee0008ee65555511111555555555555555555548855555555511115558444444444444449999999000
00555558000000000000000000000000000000000000000000668e65555511155555588555555555558844448555555555555584444444444444499999999000
000000000000002e22222222dddddd66000000000000eee000556655555115555588444555555555888444444855555555558844444444444444999999990000
00000000000002ee22222222dddddd6000000000000eeeee88655555555555558444444485555844444444444448555555444444444444444449999999900000
00000000000002e2222222ddddddddd0000000000eeeeeeeee865555555558444444444448884444444444444444485555444444444444444999999999000000
00000000000002e2222dddd66dddddd00000000eeeeeeeeeffff55555558844444444444444444444444444444444455554444444fff44449999999990000000
000000001100022222dd66666dddddd0000000eeeeeeeeffff44455555844444444444444444444444444444444444855554444444fff4499999999900000000
550000000110022222dd666dddddddd0000eeeeeeeeefff444444555584444444444444444444444444444444444444555554f44444ff9999999999000000000
555500110010002222d6666dddddddd0eeeeeeeeefffff4444444455544444444444ffffff444444444444444444444455555f44444449999999995500000000
585555501011002222d666ddddddddddeeeeeeeefffff444444444555444444444ffffffff444444444444444444444445555f44444449999999955550000000
b5b555ddd011110222ddddddddd2ddddeeefffffff4444444444445554444444fffffff444444444444444444444444445555444444449999999555555550000
58555d55ddd1110022ddddddddd222dd4ffff4444444444444444455544444fffffff44444444444444444444444444448555544444444449900000055555500
5555d5555dd0111011dddddddd0222dd44444444444444444444455544444ffffff4444444444444444444444444444444855554444444444444440005555550
666d555dddddd11111ddddddd00022dd4444444444444444444445554444ffffff44444444444444444444444444444444495551144444444444444445555555
666d65d55dddd11111ddddd0000022dd4444444444444444444455554444fffff444444444444444444444444444444444499555511144444444444444055550
550d6d655dddddddddddddd0000022dd444444444444444444555555444fffff4444444444444444444444444444444444999955551110044400944444005005
55000d66d555dddddddddd00000022dd444444eeeeeeeeeee4555558444ffff44444444444444444444444444444444499999995555100000000099444665005
5550006d655500ddddddd000000022d0eeeeeeeeeeeeeee000005584444fff444444444444444444444444444444444499999999500000000000009946066050
6550000d6555000dddd0000000022dd000000000000000000000004444fff4444444444444444444444444444444449999999990000000000000006606606000
6555000075550000000000000022dd0000000000000000000000000444fff4444444444444444444444444444449999999999900000000000000006000606000
065550002222220000000000022dd00000000000000000000000000044fff4444444444444444444444444449999999999990000000000000000066000600000
00655502dddddd2200000000222d000000000000000000000000000004ff44444444444444444444444444999999999999000000000000000000660000600000
0006550d75550ddd220000222dd00000000000000000000000000000000f44444444444444444444444499999999999900000000000000000000000000000000
00005550d555000dd222222ddd000000000000000000000000000000000444444444444444444444499999999999999900000000000000000000000000000000
0000055555d00000ddddddd000000000000000000000000000000000000444444444444444444449999999999999990000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000444444444444444444999999999999990000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000020000222200020002000000200020020200002002022220
0000000008899880000000000000dddd088888888888888888888888888888888888888888888888020000200200020002000002220020020200002002020002
00500500889aa988000000000ddddddd088888888888888888888888888888888888888888888888020000200200020002000002020020020200002002020002
00c65c0089a77a980000000dddddddd1002220200202222200222022022020020200002002022220002220200202222200222022022022220222202222022220
0cc56cc089a77a9800000ddddddd1111002220200202222200222022022020020200002002022220002220200202222200222022022002200222200220022220
00c65c00889aa988000dddddd1111111020000200200020002000002020020020200002002020002088888888888888888888888888888888888888888888888
00500500088998800ddddd1111111111020000200200020002000002220020020200002002020002088888888888888888888888888888888888888888888888
0000000000888800ddddd11111111111020000222200020002000000200020020200002002022220000000000000000000000000000000000000000000000000
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
011400000743204432094320543209432054320743204432074320443205432024320543202432074320443207432044320943205432094320543207432044320743204432054320243205432024320000000000
011400000433104331043310433105331053310533105331043310433104331043310233102331023310233104331043310433104331053310533105331053310433104331043310433109331073310533104331
011400001862000600006200060018620006000062018600186201860000620186001862000600006200060018620186000062018600186201860000620186001862018600006201860018620186000062018600
011400000433504335043350433505335053350533505335043350433504335043350233502335023350233504335043350433504335053350533505335053350433504335043350433509335073350533504335
01140000387323870239702397323173231732397023170238732387023970239732317323173239702007023873238702397023973231732317323970200702387323870239702397323e7323e7323e7323e732
01140000384353840539405394353143531435314353143538435384053940539435314353143531435314353843538405394053943531435314353143531435384353840539405394353e4353e4353e4353e435
01140000205321e552205521e532225321b5321e7321b732205321e552205521e532225321b532227321b732205321e552205521e532225321b5321e7321b732205321e552205521e532225321b532227321b732
011400001003210032100321003211032110321103211032100321003210032100320e0320e0320e0320e03210032100321003210032110321103211032110321003210032100321003215032130321103210032
011400001b7321b73227700207001b7321b7321370023700277322773227700207002773227732137001270033732337322770020700337323373213700127003f7323f73227700207003f7323f7321370012700
011400000c32215322103221732215322133220e322153220c32215322103221732215322133220e322153000c32215322103221732215322133220e322153220c32215322103221732215322133220e32215300
0114000010330113311033015331103301133110330153312833029331283302d3312833029331283302d33110330113311033015331103301133110330153312833029331283302d3312833029331283302d331
011400000c22215222102221722215222132220e222152220c22215222102221722215222132220e222152020c22215222102221722215222132220e222152220c22215222102221722215222132220e22215202
011400000c22215222102221722215222132220e222152220c22215222102221722215222132220e222152020c22215222102221722215222132220e222152220c22215222102221722215222132220e22215202
011400000413204132041320413205132051320513205132041320413204132041320213202132021320213204132041320413204132051320513205132051320413204132041320413209132071320513204132
011400000433404334043340433405334053340533405334043340433404334043340233402334023340233404334043340433404334053340533405334053340433404334043340433409334073340533404334
01140000130321003213032100321503211032150321103213032100321303210032110320e032110320e032130321003213032100321503211032150321103213032100321303210032110320e032110320e032
011400001073410734107341073411734117341173411734107341073410734107340e7340e7340e7340e73410734107341073410734117341173411734117341073410734107341073415734137341173410734
011400000c22215222102221722215222132220e222152220c22215222102221722215222132220e222152020c22215222102221722215222132220e222152220c22215222102221722215222132220e22200000
011400001843000400004300040018430004000043018400184301840000430184001843000400004300040018430184000043018400184301840000430184001843018400004301840018430184000043018400
01140000184300c4300043000400184300c43000430184001843018430004301843018430004300043000400184300c4300043018400184300c4300043018400184300c430004301843018430184300043018400
011400000c3301533011330003000c330113301333018300183300c3301833000300183300c33018330183000c3301533011330003000c330113301333018300183300c3301833000300183300c3301833018300
01140000006140060000614186000c6240c6000c62430604186341860418634246042464424604246443060410230107301023010730152301373011230107301023010730102301773015230137301123010730
011400001023110731102311073115231137311123110731102301073010230177301523013730112301073010231107311023110731152311373111231107311023010730102301773015230137301123010730
011400001033410333103341033315334133331133410333103341033310334173331533413333113341033310334103331033410333153341333311334103331033410333103341733315334133331133410333
01140000103341033310334103331533413333113341033310334103331033417333153341333311334103331033410333003042a3342a3340030415334133331033410333003042a3342a334003041533413333
011400000433104431043310443105331054310533105431043310443104331044310233102431023310243104331044310433104431053310543105331054310433104431043310443109331074310533104431
011800000b0320b0320b0320903209032090320703207032070320903209032090320203202032020320203202032020320e0320e0320e0320e0320e0320e0320003200032000320003200032000320003200032
011800002301223012230122101221012210121f0121f0121f0122101221012210121a0121a0121a0121a0121a0121a0122601226012260122601226012260121801218012180121801218012180121801218012
011800002f0122f0122f0122d0122d0122d0122b0122b0122b0122d0122d0122d0122601226012260122601226012260123201232012320123201232012320122401224012240122401224012240122401224012
011800000b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b6110b611
010a000028111281112811128111101012810128101281012912129121291212912113101161011a1011d1012813128131281312813116101181011c101241012913129131291312913100101001010010100101
010a000010514105141051410514105042850428504285041152411524115241152413504165041a5041d5041053410534105341053416504185041c504245041153411534115341153400504005040050400504
010300001c7311c7311c7311c73110700287010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
0107000026731267312673128731287312873126700287001f7001e7002070022700347003470034700347000e7001070011700107000e7001070010700117001170000700007000070100701007010070100000
010300000e1330f13310133141330c13314133101330e1330e1330e1331213315133141330c133121330f1330e1330c13314133121331213317133131330d1330e1030e1030e1030e1030e1030e1030e1030e103
010a00000e0321003211032130321503217032180321a0321c0321d03230000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000
010a00000261103611026110861102611036110261108611026210362102621086210262103621026210862102621036210262108621026210362102621086210262103621026210862102621036210262108621
010a00003475332700307532f7002d7532b7002b7332b700297332770026753247002375322700207531f7001c7531a700187531570014753117000f7530d7000c7530a700097530870007753067000575302700
010a000002516035160251608516025160351602516085160e5160f5160e516145160e5160f5160e516145161a5161b5161a516205161a5161b5161a516205162651627516265162c5162651627516265162c516
010a00001a4301b4301a430204301a4001b4001a400204001a4301b4301a430204301a4001b4001a400204001a4001b4001a400204001a4001b4001a400204002640027400264002c4002640027400264002c400
010a00003002230022300223002230022300223002230022300223002230022300223002230022300223002230022300223002230022300223002230022300223002230022300223002230022300223002230022
000a0000106321463238660326602f6602c6522965227642266422463221632206321f6321d6321c6321a63218632186321663214632136321363211632106320e6320b6320a6220862206622056220362201622
000a00000661006610056100561005610056100561005610056100561005610056100561005610056100661005610056100561004610046100461003610036100260002600016000060000600006000060000600
011800000b0320b0320b0320903209032090320703207032070320903209032090320203202032020320203202032020320e0320e0320e0320e0320e0320e0320003200032000320003200032000320c0320c032
011000000c0320c0320c0320c0320c032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000006450083500d4500f350134501435017450193501c4501d3501e4501e3501f4501f3501f4501e3501f4501e3501e4501c3501a45015350114500e3500d4500b3500d45011350164501b3502245024350
0003003f1e62021630246402564025640256402464022630206201e6201b6201862016620156201561015610156101661017620196201d62021630266302a6402c6402d6402d6402e6402c640296302562020610
0002000005150057500515006150071500a7500d15010150154501b3501e450223501f450223501b4501f35015450121500f7501115012150107500f1500d7500b5500a55009750095500a550097500875009750
0002000013450125501055012450124500e5500e55012450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 01 02 44
00 41 01 02 04
01 41 03 02 04
00 41 03 02 05
00 41 03 02 04
00 41 03 02 44
00 41 03 02 06
00 41 07 02 08
00 41 42 03 44
00 09 02 03 44
00 41 03 02 04
00 09 02 03 44
00 41 03 02 44
00 41 03 02 06
00 41 03 02 05
00 02 03 09 44
00 41 42 03 44
00 0b 0c 03 44
00 0b 0c 03 44
02 41 03 0d 0e
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 07 10 43 44
01 0f 42 13 44
00 0f 42 13 44
00 41 10 43 44
00 41 10 14 44
02 41 42 14 02
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 15 1e 1f 44
00 03 17 43 44
01 18 03 43 44
00 18 03 02 44
00 18 03 02 44
00 19 42 43 44
00 18 03 43 44
00 18 03 02 44
02 41 0a 03 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
04 41 20 43 44
04 41 21 43 44
04 41 22 43 44
04 41 23 43 44
00 1b 1a 1c 44
04 41 24 25 26
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
