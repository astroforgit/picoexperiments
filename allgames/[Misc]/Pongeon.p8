pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- a dual adventure!
-- by sebastian lind

nr_balls=0
current_level=1
points=0
game_won=false
game_started=false
time_played=0
is_shake=true
is_multiplayer=false
show_intro=0-- -1 to disable

c_t="camera shake:"
c_r="multiplayer:"
function _init()
  load_level(current_level)
	menuitem(1,"reset ball †", function() reset_ball() end)
	menuitem(2,c_t..is_on(is_shake), function() toggle_camera_shake() end)
	menuitem(3,c_r..is_on(is_multiplayer), function() toggle_multiplayer() end)
	new_page(1)
end

function toggle_camera_shake()
	is_shake = not is_shake
	menuitem(2,c_t..is_on(is_shake),function() toggle_camera_shake()  end)
	sfx(2)
end

function toggle_multiplayer()
	is_multiplayer = not is_multiplayer
	menuitem(3,c_r..is_on(is_multiplayer),function() toggle_multiplayer()  end)
	sfx(2)
end

function reset_ball()
	if #balls > 0 then 
			destroy_ball(balls[1], true)
	end
	p1x=p1sx
	p1y=p1sy
	p1_sm_x=p1x*8
	p1_sm_y=p1y*8
	for m in all(monsters) do 
		m.x=m.sx
		m.y=m.sy
	end
end

function is_on(state) 
	return state and "on" or "off"
end

function _update60()
	t=time()

	if not game_won then
		if not next_level_transition then
			if (not pa_shoot)update_player()
			if (show_intro ~= 1)update_paddle()
			if (h_t > 0 and game_started)h_t-=1
			foreach(balls,update_ball)
			foreach(traps, update_trap)
			foreach(arrows, update_arrow)
			foreach(bouncies, update_bounce)
			foreach(poison, update_poison)
			foreach(monsters, update_monster)

			if game_started and s_b < 3 then 
				s_b=lerp(s_b,3,0.1)
			end
		end
		
		animate_tiles()
		foreach(particles, update_particle)
		handle_next_level_transition()
	else
		foreach(particles, update_particle)
		update_game_won()
	end

	update_game_started()
	if (show_intro == 1)handle_intro()
end

function _draw()
  cls()
  
  draw_grid()
	if show_intro ~= 1 then
		camera_shake()
		map(0,0,0,0,16,16)
		if (not game_won)foreach(monsters, draw_monster)
		if (not next_level_transition)draw_player()
		if game_won then 
			draw_game_won()
		end
		foreach(particles, draw_particle)
		if not game_won then
			foreach(bouncies, draw_bounce)
			foreach(poison, draw_poison)
			foreach(balls,draw_ball)
			foreach(arrows, draw_arrow)
			if (game_started)draw_paddle()
			camera()
			ui()
		end
	end

	draw_start_border()
	if show_intro < 1 then 
		if (not game_started)draw_start()
	else
		if (show_intro == 1)draw_intro()
	end
end

function update_game_started()
	if btnp(”) and (not game_started and show_intro <= 0) then 
		if show_intro == -1 then
			t=0
			game_started=true
			show_intro = 2
			sfx(4)
		else
			show_intro = 1
			sfx(18)
		end
	end
end

h_x=0
h_y=0
h_t=0
function draw_help()
	if h_t > 0 and game_started then
		print("exit!",h_x,h_y+sin(t)*2,9)
	end
	if current_level == 1 and game_started and pa_shoot and not next_level_transition then 
		rectfill(0,0,128,9,0)
		print("take the   and the   to the ", 1,2,7)
		spr(26,34,1)
		spr(33,75,1)
		spr(5,111,1)
	end
end

s_b=0
function draw_start_border()
	if s_b < 2.9 then 
		rect(0-s_b,0-s_b,127+s_b,127+s_b,1)
		rect(1-s_b,1-s_b,126+s_b,126+s_b,1)
	end
end

function draw_start()
	rectfill(0,40,128,60,1)
	spr(197,4,43.1,9,2)
	rectfill(0,62,128,68,2)
	print("press ” to begin",6+cos(t)*1.1,63,14)
	spr(76,84,36-sin(t/1.5)*0.9,4,7)
end

function draw_grid()
	for x=0,15 do
		for y=0,15 do
			fillp()

			rect(x*8,y*8,x*8+8,y*8+8,1)
			fillp()
		end
	end
end

ui_x=118
ui_x_s=118
function ui()
	if current_level > 1 then
		rectfill(ui_x,52,128,60,1)
		print(current_level,ui_x+1,54,9)
		spr(192,ui_x-8,52)
	end
	if nr_balls > 0 then
		rectfill(ui_x-4,64,128,72,1)
		print(nr_balls,ui_x-3,66,2)
		spr(193,ui_x-12,64)
	end
	if points > 0 then 
		rectfill(ui_x_s,76,128,84,1)
		print(points,ui_x_s+1,78,3)
		spr(194,ui_x_s-8,76)
	end

	draw_help()
	draw_next_level_transition()
end

function draw_game_won()
	rectfill(0,0,128,128,1)
	spr(229,36,12+sin(t),7,2)
	print("for saving kugel!",30,32+sin(t)*1.5,7)

	print("sebastian lind @elastiskalinjen",2,122,13)

	rectfill(0,63,128,85,0)
	spr(76,96,34-sin(t/1.5)*0.9,4,7)
	print("balls destroyed: " .. nr_balls, 4+cos(t)*1.1,64,12)
	print("trees destroyed: " .. points, 4+cos(t)*1.2,72,12)
	print("time played    : " .. flr(time_played) .." s", 4+cos(t)*1.3,80,12)
	if flr(t) % 2 == 0 then 
		print("press ” and ‘ to restart", 12,102, 7)
	end
end

function update_game_won()
	if btn(”) and btn(‘) then
		run()
	end
	init_particle(rnd(128),rnd(128),0.25,1,1+rnd(2),12)
end

-->8
--player
p1x=0
p1y=0
p1sx=0
p1sy=0
p1spr=18
p1cangrab=0
p1flip=false

p1_sm_x=0 -- smooth
p1_sm_y=0
p1_has_key=false
p1_is_grabbed=false

function update_player()
	move_player()
	player_grab()
	smooth_player_movement()

	if fget(mget(p1x,p1y),key_f_id) then 
		mset(p1x,p1y,0)
		p1_has_key=true
		sfx(13)
		shake+=0.01
	end
end

function player_grab()
	if p1cangrab > 0 then
		p1cangrab-=1
		if p1cangrab == 1 then
			init_particle(p1x*8+rnd(8),p1y*8,0.25,1,1+rnd(2),12)
		end
	end
end

function smooth_player_movement()
	p1_sm_x=lerp(p1_sm_x, p1x*8,0.4)
	if abs(p1_sm_x - p1x*8) < 0.5 then 
		p1_sm_x = p1x*8
	end
	p1_sm_y=lerp(p1_sm_y, p1y*8,0.4)
	if abs(p1_sm_y - p1y*8) < 0.5 then 
		p1_sm_y = p1y*8
	end
end

function show_indication(x,y)
	local m = mget(x,y)
	local f = fget(m)
	local indication = f == door_f_id or (m == lock_door_id and p1_has_key) or m == box_id

	if indication then 
		if flr(t) % 2 == 0 then 
			fillp()
		else
			fillp(„)
		end
		circ(x*8+4,y*8+4,2,14)
		fillp()
	end
end

function show_player_indication()
	show_indication(p1x-1,p1y)
	show_indication(p1x+1,p1y)
	show_indication(p1x,p1y-1)
	show_indication(p1x,p1y+1)
end

function move_player()
	local moved = false
	if (not is_multiplayer and btnp(”)) or (is_multiplayer and btnp(”,1)) then 
		if p1y > 0 and not is_tile_id(p1x,p1y-1,solid_id) then 
			p1y-=1
			moved=true
			simple_animate(1) 
		else 
			init_particle(p1x*8+rnd(8),p1y*8,0.75,1,1+rnd(2),1)
			check_player_collision(p1x,p1y-1)
		end
	elseif (not is_multiplayer and btnp(ƒ)) or (is_multiplayer and btnp(ƒ,1)) then 
		if p1y < 15  and not is_tile_id(p1x,p1y+1,solid_id) then
			p1y+=1
			simple_animate(2)
			moved=true
		else 
			init_particle(p1x*8+rnd(8),p1y*8,0.25,1,1+rnd(2),1)
			check_player_collision(p1x,p1y+1)
		end
	elseif (not is_multiplayer and btnp(‹)) or (is_multiplayer and btnp(‹,1)) then 
		p1flip = false
		if p1x > 0 and not is_tile_id(p1x-1,p1y,solid_id) then 
			p1x-=1
			simple_animate(0)
			moved=true
		else 
			init_particle(p1x*8,p1y*8+rnd(8),0,1,1+rnd(2),1)
			check_player_collision(p1x-1,p1y)
		end
	elseif (not is_multiplayer and btnp(‘)) or (is_multiplayer and btnp(‘,1)) then 
		p1flip = true
		if p1x < 15 and not is_tile_id(p1x+1,p1y,solid_id) then
			p1x+=1
			simple_animate(0)
			moved=true
		else 
			init_particle(p1x*8,p1y*8+rnd(8),0.5,1,1+rnd(2),1)
			check_player_collision(p1x+1,p1y)
		end
	end

	if moved then 
		move_monsters()
	end
end

function simple_animate(state)
	local w_b = 0
	if is_tile_id(p1x,p1y,water_f_id) then --water
		w_b=8
	elseif p1_is_grabbed then
		w_b=6
	elseif state == 1 then -- up 
		w_b=4
	elseif state == 2 then -- down
		w_b=2
	end
	if p1spr == 16 + w_b then
		p1spr = 17 + w_b
	else
		p1spr = 16 + w_b
	end
end

function check_player_collision(x,y)
	local tile=mget(x,y)
	local f_tile=fget(tile)
	if f_tile == door_f_id then 
		mset(x,y,0)
		shake+=0.03
		init_particle(x*8,y*8,rnd(1),1,1+rnd(1),4)
		sfx(10)
	elseif tile == button_id then
		mset(x,y,button_id+1)
		remove_bars()
	elseif tile == box_id then
		sfx(9)
		local px_diff=(x-p1x)
		local py_diff=(y-p1y)
		-- thanks for playtesters!
		if mget(x+px_diff,y+py_diff) ~= goal_id and not fget(mget(x+px_diff,y+py_diff),key_f_id) then
			if is_tile_id(x+px_diff,y+py_diff,water_f_id) then
				mset(x,y,0)
				mset(x+px_diff,y+py_diff,42+flr(rnd(2)))
				sfx(14)
				for i=0, 3 do 
					init_particle(x*8+rnd(8),y*8+rnd(8),0.25,1,2+rnd(1),15)
				end
			elseif not is_tile_id(x+px_diff,y+py_diff,solid_id) then
				p1_sm_x += px_diff*4
				p1_sm_y += py_diff*4
				mset(x,y,0)
				mset(x+px_diff,y+py_diff,box_id)
			end
		end
	elseif tile == lock_door_id and p1_has_key then 
		p1_has_key = false
		mset(x,y,0)
		shake+=0.03
		init_particle(x*8,y*8,rnd(1),1,1+rnd(1),9)
		sfx(15)
	end
end

function remove_bars()
	shake+=0.02
	sfx(24)
	for x=0,15 do
		for y=0,15 do
			if mget(x,y) == bars_id then 
				mset(x,y,0)
				init_particle(x*8,y*8,rnd(1),2,1+rnd(2),7)
			end
		end
	end
end

function draw_player()
	if p1_has_key then 
		draw_player_key()
	end
	spr(p1spr,p1_sm_x,p1_sm_y,1,1,p1flip)
	--print(mget(p1x,p1y),p1x*8,p1y*8,3)

	if pa_shoot and not next_level_transition and current_level == 1 and game_started and nr_balls < 2 then 
		print("‹”ƒ‘", p1x*8-10,p1y*8-8,2)
	end
	show_player_indication()
end

function draw_player_key()
	spr(53,p1_sm_x-4,p1_sm_y + 3 - (p1spr % 2 == 0 and 0 or 2),1,1,p1flip)
end

-->8
--particles
particles={}
function init_particle(x,y,angle,speed,rad,col)
	local p={
		x = x,
		y = y,
		angle = angle,
		speed = speed,
		rad = rad,
		col = col
	}
	add(particles,p)
end

function update_particle(p)
	p.speed*=0.9
	p.x+=p.speed*cos(p.angle)
	p.y+=p.speed*sin(p.angle)
	local speed = p.rad > 5 and 0.4 or 0.09
	p.rad -= speed
	if(p.rad <=0)del(particles,p)
end

function draw_particle(p)
	circfill(p.x,p.y,p.rad,p.col)
end

-->8
-- help functions

shake=0
function camera_shake()
	if is_shake then
		local shakex=16-rnd(32)
		local shakey=16-rnd(32)
	
		shakex*=shake
		shakey*=shake
		camera(shakex,shakey)
		shake=shake*0.95
		if(shake < 0.05)shake=0
	end
end

b_shake=0
function ball_shake(b)
	local shakex=4-rnd(2)
	local shakey=4-rnd(2)
	shakex*=b_shake
	shakey*=b_shake
	b.x+=shakex
	b.y+=shakey

	--b_shake*=1.1
	if(b_shake < 0.05)b_shake=0
end

function distance(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

function circ_collision(x1,y1,rad1,x2,y2,rad2)
	return distance(x1,y1,x2,y2) < rad1+rad2
end

function rect_colllision(ax,ay,aw,ah,bx,by,bw,bh)
	return not ((ax > bx+bw) or (ax+aw < bx) or (ay > by+bh) or (ay+ah < by))
end

function angle(x1,y1,x2,y2)
 	return atan2(x1-x2,y1-y2)
end

function a_angle(a,b)
  return angle(a.x,a.y,b.x,b.y)
end

function lerp(var,target,pow)
	return var+pow*(target-var)
end

function collide_map(o)
	local x1=o.x/8
	local y1=o.y/8
	local x2=(o.x+7)/8
	local y2=(o.y+7)/8
	local a=fget(mget(x1,y1),0)
	local b=fget(mget(x1,y2),0)
	local c=fget(mget(x2,y2),0)
	local d=fget(mget(x2,y1),0)
	if a then 
		return true, round(x1),round(y1)
	elseif b then 
		return true, round(x1),round(y2)
	elseif c then 
		return true, round(x2),round(y2)
	elseif d then 
		return true, round(x2),round(y1)
	end

  return false
end

function round(x) return flr(x+.5) end

function is_tile_id(x,y,id)
 	return fget(mget(x,y),id)
end

--e.t, e.f, e.s = 0, 1, 12
--e.sp = {spr, spr + 1, spr + 2, spr + 3}
function animate(o)
 o.t = (o.t + 1) % flr(o.s)
 if (o.t == 0) o.f = o.f %#o.sp + 1
end

function load_room(room_str)
	local room=split(room_str)
	local m_x=0
	local m_y=0
	for i=1,#room do
		mset(m_x,m_y,room[i])
		if m_x < 15 then
			m_x+=1
		else
			m_x=0
			m_y+=1
		end
	end
end

-->8
--levels

wall_id=1
player_id=2
tree_id=3
door_id=4
goal_id=5
box_id=7
trap_id=10
key_id=11
lock_door_id=12
poison_id=13
monster_id=15
button_id=101
b_button_id=104
bars_id=103

--flags
water_f_id=4
key_f_id=3
solid_id=0
auto_tile_id=7
door_f_id=65

levels={
"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,2,0,0,0,0,0,0,0,0,0,5,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,6,1,4,4,4,1,6,1,1,1,1,1,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,1,0,0,3,9,9,9,3,0,0,0,1,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,3,0,0,9,9,9,0,0,3,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0",
"1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,1,0,2,1,0,0,1,0,5,0,0,0,0,0,0,0,7,0,0,1,0,0,1,0,0,0,0,1,6,1,1,1,1,1,1,1,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,3,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,3,0,1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,4,9,9,9,9,9,0,0,0,1,0,0,0,0,0,0,4,9,9,9,9,9,0,0,0,1,6,1,1,1,1,6,1,0,0,0,9,9,0,0,0,0,0,0,0,0,3,0,0,0,0,0,9,9,0,0,0,0,0,3,0,0,0,0,0,0,0,0,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,0,0,0",
"0,0,0,0,0,1,1,1,1,1,1,1,6,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,7,0,2,0,0,1,1,0,5,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,6,1,1,4,4,4,1,1,6,1,1,1,1,0,0,0,0,8,8,9,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,1,0,0,0,9,9,9,0,0,0,0,1,0,0,0,0,0,0,0,0,9,9,9,0,0,3,0,0,0,0,0,0,0,0,3,0,9,9,9,0,0,0,0,0,0,0,3,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,3,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,0,0,0,0,0,0,0",
"1,1,6,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,8,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,8,4,0,0,0,0,0,0,0,7,0,1,1,0,2,0,8,4,0,5,0,0,0,7,0,0,0,1,1,0,0,0,8,1,0,0,0,0,0,0,0,0,0,1,1,1,6,1,1,1,1,1,1,6,1,8,8,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,9,0,0,0,0,0,0,0,0,0,9,9,9,9,9,0,9,0,0,0,0,0,3,0,0,9,0,3,0,0,9,0,9,0,0,0,0,0,0,0,0,9,0,0,0,0,9,3,9,0,0,0,9,9,9,9,9,9,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"1,1,1,1,10,1,1,1,1,1,10,1,1,6,1,1,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,5,1,0,0,0,0,2,0,1,0,0,0,1,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,4,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,9,9,0,0,0,0,1,1,6,1,1,1,1,6,1,1,0,9,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,3,9,9,9,9,0,0,0,0,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,6,1,1,0,0,1,1,6,1,1,0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,1,0,0,0,1,0,5,0,0,1,0,9,4,0,2,0,1,0,0,0,1,0,0,0,0,1,0,9,1,0,0,0,1,0,0,0,1,1,1,12,1,1,0,9,1,1,1,1,1,0,0,0,0,0,0,9,0,0,0,9,0,8,8,8,8,0,0,0,0,0,3,9,0,0,0,9,0,1,1,1,1,0,0,0,0,0,0,9,9,9,9,9,0,0,0,11,0,0,0,0,1,0,0,9,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,9,3,0,0,0,0,0,0,9,0,1,0,0,0,0,0,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0",
"1,1,1,6,1,1,10,1,1,6,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,7,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,7,0,0,0,0,0,0,9,4,0,11,0,1,0,0,0,0,0,0,0,0,0,9,0,1,1,1,1,1,0,0,1,1,1,0,0,0,0,9,0,0,0,0,0,0,0,0,1,5,1,0,0,0,3,9,0,0,0,3,0,0,0,0,1,12,1,0,0,0,0,9,0,0,1,1,1,0,0,0,0,9,9,9,9,9,9,9,0,0,0,2,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,9,3,0,0,0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"1,1,6,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0,0,0,13,0,0,0,0,0,0,1,1,0,5,0,1,0,11,0,13,0,0,0,0,2,0,1,1,0,0,0,1,1,1,1,0,3,13,0,0,0,0,1,1,1,12,1,1,13,13,0,0,0,0,0,1,1,1,1,13,13,13,13,13,0,0,0,13,0,0,0,1,0,0,0,0,0,9,0,0,13,0,0,0,0,0,0,1,0,3,0,9,9,9,0,0,0,0,0,0,0,13,0,0,0,0,0,0,0,9,0,0,13,0,0,13,0,0,0,0,0,0,0,0,0,9,0,13,0,0,0,0,13,0,0,0,0,0,0,0,0,9,0,0,0,13,0,0,0,3,13,0,0,0,0,0,0,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"1,1,6,1,1,1,1,1,10,1,1,1,1,1,1,1,1,0,0,0,5,4,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,4,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,10,1,1,1,10,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,13,13,13,0,0,0,13,13,13,0,0,0,0,0,0,1,13,13,13,13,1,1,1,10,1,1,1,1,6,1,1,1,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,9,9,9,9,0,3,0,0,0,0,0,0,3,0,0,0,0,0,0,9,0,0,0,0,2,0,0,0,0,0,0,0,0,3,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0",
"1,1,6,1,1,0,0,1,1,1,0,0,0,1,6,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,11,0,1,0,0,0,0,0,0,0,2,0,0,1,1,4,4,1,1,0,0,1,9,9,9,9,9,0,0,0,0,0,9,0,0,0,0,3,9,0,0,1,1,1,0,0,0,3,9,9,9,9,9,9,9,0,0,1,5,1,0,0,1,0,0,0,0,0,1,0,9,0,0,1,12,1,0,0,1,0,0,0,15,0,0,0,9,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,9,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0",
"1,1,1,1,1,1,1,10,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,0,1,1,15,0,0,0,0,0,0,0,0,0,7,0,0,0,1,1,1,1,0,0,1,0,0,1,4,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,9,0,13,0,0,0,1,0,15,1,0,0,0,0,9,9,9,0,13,0,0,0,1,0,0,1,0,0,0,0,9,3,0,0,13,0,5,0,1,0,0,0,0,0,0,0,9,0,0,0,13,0,9,0,1,0,0,0,0,0,0,3,9,0,0,0,0,13,9,0,0,0,0,3,0,0,0,0,9,0,0,0,0,0,9,0,0,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,1,16,0,1,0,0,1,0,11,1,0,0,1,0,5,1,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,1,4,4,1,0,0,1,17,17,1,0,0,1,12,1,1,13,13,13,13,0,0,13,13,13,0,0,0,0,13,0,0,0,13,13,0,0,0,0,9,9,9,9,9,9,9,13,0,0,0,0,0,0,0,0,13,0,0,0,0,13,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,9,0,0,0,0,0,0,0,0,0,3,0,0,2,0,0,9,0,0,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,9,0,0,0,3,0,0,0,0,0,3,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"1,1,1,1,1,6,1,1,1,1,8,8,1,1,1,1,8,8,0,0,0,0,0,0,0,0,0,0,1,0,5,1,8,8,2,9,9,9,9,9,9,9,18,0,1,0,0,1,1,1,1,1,1,1,1,0,0,9,0,0,1,17,17,1,0,0,0,0,0,16,1,0,0,9,0,0,0,13,13,0,0,3,0,0,0,0,1,0,0,9,0,0,3,0,0,13,0,0,0,1,4,4,1,0,0,9,0,0,18,0,0,0,13,13,1,1,0,13,0,0,3,9,0,0,0,0,1,1,13,0,1,0,13,0,0,0,0,9,0,0,0,0,1,1,0,0,13,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,13,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,11,0,0,0,0,1,0,5,0,1,0,0,0,0,0,1,0,9,0,0,0,17,17,17,17,17,0,0,0,9,0,1,0,9,9,9,9,0,0,15,0,0,9,9,9,9,0,1,0,0,3,0,9,9,1,1,1,9,9,0,3,0,0,1,0,0,0,18,0,1,0,16,0,1,0,18,0,0,0,0,0,0,0,0,0,9,1,12,1,9,0,0,0,0,0,0,0,0,0,0,0,9,0,9,0,9,0,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,0,0,0,0,0,0,0,0,18,0,0,0,3,9,3,0,0,0,18,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0", 
"1,1,1,1,1,1,0,0,0,1,8,8,8,8,8,8,1,0,0,0,0,1,0,5,0,1,0,0,0,0,0,0,1,0,11,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,1,1,12,1,1,10,1,0,0,0,1,4,4,4,1,10,13,13,13,13,13,0,1,0,0,0,0,0,13,13,0,13,0,13,9,0,0,0,0,0,0,0,13,13,0,13,13,0,13,0,9,0,0,0,0,7,0,0,0,0,13,13,0,0,0,0,9,3,0,0,0,0,0,0,13,13,9,0,0,0,0,9,9,0,0,0,1,1,0,0,0,0,9,0,0,1,7,9,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,9,0,0,0,0,9,2,0,0,0,0,0,3,0,0,0,9,3,0,0,0,9,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
"0,0,0,1,8,8,8,8,0,0,0,0,0,0,0,0,0,2,0,1,0,0,0,0,0,0,0,19,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,17,17,17,1,0,0,0,18,0,0,0,0,1,1,1,1,0,9,0,0,0,0,0,0,0,0,9,9,4,0,0,1,0,9,0,0,0,0,13,1,13,0,0,9,4,0,5,1,0,9,9,9,9,0,0,13,0,0,0,9,1,1,1,1,0,9,0,0,0,18,0,0,0,18,0,9,0,0,0,0,17,17,17,1,0,0,0,9,0,0,0,9,3,0,0,0,0,0,0,1,0,0,0,9,9,9,9,9,0,0,0,0,0,15,0,1,0,0,0,9,0,3,0,0,0,0,0,0,1,1,1,1,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
 "8,8,1,10,1,6,1,10,1,6,1,10,1,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,13,1,13,13,1,13,1,5,1,13,18,13,18,13,18,13,0,0,0,0,0,0,1,12,1,0,0,0,0,0,0,0,0,0,0,0,0,0,13,0,13,0,0,0,0,0,0,0,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,3,0,0,0,0,9,0,0,0,0,3,0,0,0,0,0,0,0,7,0,0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0",
"1,1,6,1,1,1,1,1,1,1,1,1,1,6,1,1,0,0,1,0,0,1,14,1,14,1,0,0,1,0,1,0,3,3,1,0,0,1,0,5,0,1,0,0,1,0,1,0,8,8,1,0,0,1,0,9,0,1,0,0,1,1,1,0,1,1,1,0,0,1,0,9,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,9,0,1,0,0,3,11,3,0,0,3,0,0,0,1,0,9,0,1,0,0,0,0,0,0,0,0,0,3,0,1,0,9,0,1,0,0,3,0,3,0,0,3,0,0,0,1,1,12,1,1,0,0,0,0,0,0,0,0,0,3,0,0,0,9,0,0,0,0,3,0,3,0,0,3,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
}

function load_level(level)
	load_room(levels[level])
	for x=0,15 do
		for y=0,15 do
			local c_t=mget(x,y)
			if c_t == player_id then 
				mset(x,y,0)
				p1x=x
				p1sx=x
				p1y=y
				p1sy=y
				p1spr=26
				p1_sm_y = y*8
				p1_sm_x = x*8
			elseif c_t == wall_id then 
				auto_tiling(x,y,auto_tile_id)
			elseif c_t == door_id then
				auto_tiling_door(x,y)
			elseif c_t == goal_id then
				h_x = x*8 - 4
				h_y = y*8 - 7
				h_t = 120
			elseif c_t == trap_id then
				init_trap(x*8,y*8)
			elseif c_t == poison_id then
				mset(x,y,0)
				init_poison(x*8,y*8)
			elseif c_t == tree_id then 
				mset(x,y,54+rnd(2))
			elseif c_t == monster_id then 
				mset(x,y,0)
				init_monster(x,y)
			elseif c_t == 16 then 
				mset(x,y,button_id)
			elseif c_t == 17 then 
				mset(x,y,bars_id)
			elseif c_t == 18 then 
				mset(x,y,0)
				init_bounce(x*8+4,y*8+4)
			elseif c_t == 19 then 
				mset(x,y,b_button_id)
			end
		end
	end
end

function auto_tiling_door(x,y)
	local up=fget(mget(x,y-1)) == door_f_id
	local down=fget(mget(x,y+1)) == door_f_id
	local right=fget(mget(x+1,y)) == door_f_id
	local left=fget(mget(x-1,y)) == door_f_id
	
	local d_id=4
	if up or down then 
		d_id=72
	elseif left and not right then 
		d_id=75
	elseif not left and right then
		d_id=73
	elseif left and right then 
		d_id=74
	end
	mset(x,y,d_id)
end

-- simple auto tiling
function auto_tiling(x,y,id)
	-- check where other tiles are
	local up=fget(mget(x,y-1),id)
	local down=fget(mget(x,y+1),id)
	local right=fget(mget(x+1,y),id)
	local left=fget(mget(x-1,y),id)

	local t_id=81
	if up and down and not right and not left then -- up and down
		t_id=80
	elseif up and not down and right and not left then -- up and right
		t_id=96
	elseif up and not down and not right and left then -- up and left
		t_id=98	
	elseif not up and down and right and not left then --down and right
		t_id=64
	elseif not up and down and not right and left then -- down and left
		t_id=66
	elseif not up and not down and right and left then -- right and left
		t_id=65
	elseif not up and down and right and left then -- down,left and right
		t_id=114
	elseif up and not down and right and left then -- up,left and right
		t_id=67
	elseif not up and not down and right and not left then -- right
		t_id=82
	elseif not up and not down and not right and left then -- left
		t_id=113
	elseif up and not down and not right and not left then -- up
		t_id=97
	elseif not up and down and not right and not left then -- down
		t_id=112
	else -- nothing
		t_id=81
	end
	mset(x,y,t_id)
end

n_level_l=0
n_level_r=128
next_level_transition=false
function next_level(b)
	if not next_level_transition then
		if (current_level ~= #levels)sfx(4)
		next_level_transition=true
		destroy_ball(b, false)
		for k,v in pairs(traps) do traps[k]=nil end
		for k,v in pairs(arrows) do arrows[k]=nil end
		for k,v in pairs(poison) do poison[k]=nil end
		for k,v in pairs(monsters) do monsters[k]=nil end
		for k,v in pairs(bouncies) do bouncies[k]=nil end
	end
end

function destroy_ball(b, died)
	del(balls,b)
	pa_shoot = true
	p1cangrab=0
	if died then
		shake+=0.05
		nr_balls+=1
		sfx(7)
		sfx(6)
	end
	p1_is_grabbed=false
end

function handle_next_level_transition()
	if next_level_transition then
		if n_level_l < 64 then
			n_level_l=lerp(n_level_l,65,0.1)
			n_level_r=lerp(n_level_r,63,0.1)
		else
			next_level_transition=false
			current_level+=1
			if current_level > #levels then 
				game_won=true
				time_played=t
				sfx(17)
			else
				load_level(current_level)
			end
		end
	end

	if not next_level_transition then
		n_level_l=lerp(n_level_l,0,0.1)
		n_level_r=lerp(n_level_r,128,0.1)
	end
end

function draw_next_level_transition()
	if n_level_l > 1 then
		rectfill(0, 0, n_level_l, 128, 1)
		rectfill(n_level_r, 0, 128, 128, 1)
		print(current_level == 18 and "last" or "next", n_level_l-24,48,13)
		print("level", n_level_r+12,48,13)
	end
end
animate_t_c=0
function animate_tiles()
	if animate_t_c < 60 then 
		animate_t_c+=1
	else 
		animate_t_c=0
		for x=0,15 do
			for y=0,15 do
				local m = mget(x,y)
				if fget(m,water_f_id) then 
					mset(x,y,m == 69 and 70 or 69)
				elseif fget(m,5) then 
					mset(x,y,m == 85 and 86 or 85)
				elseif fget(m,3) then 
					mset(x,y,m == 38 and 39 or 38)
				elseif fget(m,2) then 
					mset(x,y,m == 54 and 55 or 54)
				end
			end
		end
	end
end

-->8
 --splash 
 
function show_splash()
  local i=0
  while (i < 90) do
    cls(0)
    local w=sin(i/50)
    line(64+i,0,64-i,128,14)
    line(0,64-i,128,64+i,14)
    fillp(„)
    circfill(64,64+w,40-w*8,14)
    circfill(64,64+w,32-w,2)
    print("this game was made during",14,13+w,14)
		print("this game was made during",14,12+w,7)    
    
		print("sebastian lind @elastiskalinjen",2,122,7)    
		spr(208,46,52+w*2,5,3)
    i+=1
    if i > 74 then
    	fillp()
    	rectfill(0,0,(i-74)*12,128,0)
    end
    flip()
  end
end
 -- uncomment to remove splash
show_splash()

-->8
-- ball and pong

b_x=0
b_y=0
max_speed=2.5
b_hold_time=80

balls={}
function init_ball(x,y,dx,dy)
	local b={
		x=x,
		ox=x,
		oy=y,
		y=y,
		dx=dx,
		dy=dy,
		speed=0.5,
		c_c_dir=0,
		grabbed=false,
		grabbed_c=0,
		t_c=0,
		spr=32,
		spr_speed=7,
		t_spr=0,
	}
	add(balls,b)
end

function update_ball(b)
	b.ox = b.x
	b.oy = b.y

	ball_trail(b)

	if not b.grabbed then
		b.x+=b.dx
		b.y+=b.dy
		ball_collision(b)
		animate_ball(b) 
	else
		ball_grabbed(b)
	end
end

function animate_ball(b) 
	if b.t_spr < (b.spr_speed - b.t_spr) then 
		b.t_spr+=1
	else
		b.t_spr =0
		if b.spr < 37 then 
			b.spr+=1
		else
			b.spr=32
		end
	end
end

function ball_trail(b)
	if b.t_c < 3 then
		b.t_c+=1
	else
		b.t_c=0
		init_particle(b.x+4,b.y+4,0,0,2,2)
	end
end

function ball_grabbed(b)
	if b_shake < 0.5 then 
		b_shake+=0.05
	end

	b.x=p1_sm_x + b_shake - 1
	b.y=p1_sm_y + 3 + b_shake

	ball_shake(b)

	if mget(p1x,p1y) == goal_id then 
		next_level(b)
	end

	if b.grabbed_c < b_hold_time then
		b.grabbed_c+=1
	else

		b.x=p1x*8
		b.y=p1y*8+drop_ball_loc()
		b.grabbed_c=0
		b.grabbed=false
		b_shake=0
		p1_is_grabbed=false
		p1cangrab = 100
		sfx(3)
	end
end

-- fix glitch in wall
function drop_ball_loc()
	local top = fget(mget(p1x,p1y-1),0)
	local bot = fget(mget(p1x,p1y+1),0)
	local bo = 0
	if top and not bot then 
		bo=1 
	elseif not top and bot then 
		bo=-1
	end
	return bo
end

function ball_collision(b)
	local tx=flr(flr(b.x+4)/8)
	local ty=flr(flr(b.y+4)/8)
	local tile = mget(tx, ty)
	if fget(tile,2) then
		mset(tx,ty,0)
		init_particle(b.x+rnd(8),b.y,rnd(1), 1+rnd(2), 1+rnd(2),3)
		points+=1
		sfx(8)
		ui_x_s=118
	elseif fget(tile,4) then
		destroy_ball(b, true)
		shake+=0.05
		for i=0,3 do
			init_particle(b.x+rnd(4),b.y,0.25, 1+rnd(2), 1+rnd(2),7)
		end
	elseif tile == b_button_id then 
		mset(tx,ty,b_button_id+1)
		remove_bars()
	end

	if p1cangrab == 0 and not p1_has_key and rect_colllision(b.x,b.y,8,8,p1_sm_x,p1_sm_y,8,8) then 
		b.grabbed=true
		p1_is_grabbed=true
		sfx(2)
		p1spr=22
		shake+=0.05
		if (b.spr == 37)b.spr=32
		local angle = angle(p1_sm_x+4,p1_sm_y+4,b.x+4,b.y+4)
		p1_sm_x+=cos(angle)*3
		p1_sm_y+=sin(angle)*3

		for i=0,3 do 
			init_particle(p1x*8+rnd(8),p1y*8+rnd(8),angle+rnd(2)/20, 1+rnd(2), 2+rnd(3), 1+rnd(2))
		end
	end
	local collided,tx,ty = collide_map(b)
	if not collided then 
		b.c_c = 0
	else
		b.c_c += 1
	end
	if collided then
		if b.c_c > 2 then 
			magic_unstuckifier(b)
		else
			local b_c_x = round((b.ox+4)/8)
			local b_c_y = round((b.oy+4)/8)
			--stop(tx.."," .. b_c_x .. " | " .. ty .. "," .. b_c_y,32,24,8)
			if b_c_y ~= ty then 
				b.dy*=-1
				b.c_c_dir=-1
				init_particle(b.x+2+rnd(6),b.y+2+rnd(6),0,0,2,13)
				sfx(0)
			elseif b_c_x ~= tx then 
				b.dx*=-1
				b.c_c_dir=1
				init_particle(b.x+2+rnd(6),b.y+2+rnd(6),0,0,2,13)
				sfx(0)
			else
				magic_unstuckifier(b)
				sfx(0)
			end
		end
		reset_pos(b)
	elseif rect_colllision(b.x,b.y,8,8,pa_x,pa_y,pa_w,pa_h) then --paddle
		local ox=b.x
		local oy=b.y
		reset_pos(b)
		if abs(b.dy) < 1 then -- fix for bouncies
			b.dy = 1
		end
		if abs(b.dy) < max_speed then
			b.dy*=-1.05
		else 
			b.dy*=-1
		end
		b.t_spr= flr(abs(b.dy*1.7))
		local y_diff = (b.y+8) - pa_y
		sfx(1)
		pa_y = 124
		b.y += y_diff
		local dist = ((b.x + 4) - (pa_x + pa_w / 2)) / 8
		b.dx = dist / 4
  	shake=0.01
		for i=0,3 do 
			init_particle(b.x+rnd(8),pa_y,angle(b.x,b.y,ox,oy), 1+rnd(2), 2+rnd(3), 7)
		end
	elseif b.x < 0 or b.x > 120 then
		reset_pos(b)
		b.dx*=-1
		sfx(21)
	elseif b.y < 0 then
		reset_pos(b)
		b.dy*=-1
		sfx(21)
	elseif b.y > 128 then
		destroy_ball(b, true)
		for i=0,24 do 
			init_particle(rnd(128),128,0.25-rnd(0.05)+rnd(0.05), 1+rnd(2), 2+rnd(3), 1)
		end
		init_particle(b.x+4,b.y+4,0.25,2,3,2)
	else
		b.c_c=0
	end
end

-- this is terrible
function magic_unstuckifier(b)
	b.c_c = 0
	if b.c_c_dir == 1 then 
		b.dy*=-1
	elseif b.c_c_dir == -1 then
		b.dx*=-1
	else
		local dir = rnd(1)
		local small_r_1=rnd(1)/5
		local small_r_2=rnd(1)/5
		if dir < 0.5 then 
			b.dy*=-1 + small_r_1 - small_r_2
		else 
			b.dx*=-1 + small_r_1 - small_r_2
		end
	end
	b.c_c_dir=0
end

function reset_pos(b)
	b.x=b.ox
	b.y=b.oy
end

function draw_ball(b)
	spr(b.spr,b.x,b.y)
	local x_c_diff = (b.x + 4) - (pa_x + pa_w / 2)

	if b.grabbed then 
		fillp()
		circ(h_x+8, h_y+10,6+sin(t)*1.1,2)
		circ(h_x+8, h_y+10,7+sin(t)*1.1,2)
		fillp()
	end
	--print(b.dy,b.x,b.y,7)
end

-- paddle
pa_x=64
pa_dx=0
pa_a=0

pa_y=122
pa_w=32
pa_h=6

pa_acc = 0.3
pa_speed = 1
pa_shoot=true

function update_paddle()
	pa_dx *= 0.85
	pa_dx=min(pa_dx, pa_speed)
	pa_dx=max(pa_dx,-pa_speed)

	pa_x+=pa_dx

	if btn(‘) then
		pa_dx+=pa_acc
	elseif btn(‹) then 
		pa_dx-=pa_acc
	end

	if pa_x < 0 then 
		pa_x=0
	elseif pa_x + pa_w > 128 then
		pa_x=128-pa_w
	end

	if #balls > 0 then 
		pa_a=angle(balls[1].x,balls[1].y,pa_x,pa_y)
	else
		pa_a=angle(64,64,pa_x,pa_y)
	end

	if pa_shoot and btnp(”) and game_started then --shoot
		sfx(5)
		pa_shoot = false
		shake+=0.02
		local x_dx = (pa_x+16-64) / -100
		init_particle(pa_x+16,pa_y,0.25, 1+rnd(2), 2+rnd(3), 13)
		init_ball(pa_x+12,pa_y-8,x_dx,-1)
	end

	if pa_y > 122 then 
		pa_y = lerp(pa_y,122,0.1)
	end

	if pa_shoot then 
		ui_x=lerp(ui_x,118,0.1)
		ui_x_s=lerp(ui_x_s,118,0.1)
	else
		ui_x=lerp(ui_x,140,0.1)
		ui_x_s=lerp(ui_x_s,140,0.04)
	end
end

function draw_paddle()
	spr(49,pa_x, pa_y,4,1)
	spr(48,pa_x+4+cos(pa_a)*3,pa_y+1+sin(pa_a)*3)
	spr(48,pa_x+pa_w-12+cos(pa_a)*3,pa_y+1+sin(pa_a)*3)
	if pa_shoot and not next_level_transition and game_started then
		--line(64,64,pa_x+16,pa_y,1)	
		print("shoot ”", pa_x, pa_y-12+sin(t/2)*1.2,13)
		if current_level == 1 and nr_balls < 2 then
			print("‹         ‘", pa_x-9, pa_y,13)
		end
	end
end
-->8
--traps & arrow & poison

traps={}
function init_trap(x,y)
	local t={
		x=x,
		y=y,
		t=0
	}
	add(traps,t)
end

function update_trap(t)
	if t.t < 100 then 
		t.t+=1
	else
		t.t=0
		--shoot arrow
		init_particle(t.x+3,t.y,0.75, 1+rnd(2), 1+rnd(2), 9)
		init_arrow(t.x,t.y+1)
	end
end

arrows={}
function init_arrow(x,y) -- only downwards for now
	local a={
		x=x,
		y=y,
		t=0,
		spr=40,
		invis=3,
		speed=2,
		cm=true,
		flip=false,
	}
	add(arrows,a)
end

function update_arrow(a)
	a.y+=a.speed
	if a.t < 8 then
		a.t+=1
	else
		a.t=0
		a.spr = a.spr == 40 and 41 or 40
	end

	if a.invis > 0 then 
		a.invis-=1
	else 
		if collide_map(a) then
			del(arrows,a)
			sfx(11)
			init_particle(a.x+3,a.y+7,0.25, 0.75, 1+rnd(2), 7)
		elseif rect_colllision(a.x+4,a.y,2,8,p1x*8,p1y*8,8,8) then 
			del(arrows,a)
			hurt_player()
		elseif rect_colllision(a.x+4,a.y,2,8,pa_x,pa_y,pa_w,pa_h) then
			a.speed = -2
			a.flip = true
			pa_y = 124
			sfx(12)
		end
	end
end

function draw_arrow(a)
	spr(a.spr,a.x,a.y,1,1,false,a.flip)
end

function hurt_player()
	for i=0, 4 do 
		init_particle(p1x*8+rnd(8),p1y*8+rnd(8),1+rnd(2), rnd(1), 2+rnd(2), 2)
	end
	p1x=p1sx
	p1y=p1sy
	p1_sm_x = p1x*8
	p1_sm_y = p1y*8
	shake+=0.05
	if #balls > 0 then 
			destroy_ball(balls[1], true)
	end
end

poison={}
function init_poison(x,y)
	local p={
		x=x,
		y=y,
		t=flr(rnd(12)),
		spr=44
	}
	add(poison,p)
end

function update_poison(p)
	if p.t < 8 then 
		p.t+=1
	else
		p.t=0
		if p.spr < 47 then 
			p.spr+=1
		else
			p.spr=44
		end
	end
	for b in all(balls) do 
		if circ_collision(b.x+4,b.y+4,4, p.x+4,p.y+4,4) then 
			sfx(16)
			for i=0, 4 do 
				init_particle(b.x+rnd(8),b.y+rnd(8),1+rnd(2), rnd(1), 2+rnd(2), 2)
			end
			del(poison,p)
		end
	end

	if circ_collision(p1_sm_x+4,p1_sm_y+4,4, p.x+4,p.y+4,3) then 
		hurt_player()
	end
end

function draw_poison(p)
	spr(p.spr,p.x,p.y-sin(t/2)*1.1)
end

monsters={}
function init_monster(x,y)
	local m={
		sx=x,
		x=x,
		sm_x=x*8,
		sy=y,
		sm_y=y*8,
		y=y,
		spr=56+flr(rnd(2)),
		stun=0,
		stun_spr=59,
	}
	add(monsters, m)
end

function move_monsters()
	for m in all(monsters) do
		if m.stun == 0 then -- dont move when stun
			local random_step=rnd(100)
			if random_step < 20 then -- take a random step
				local random_dir = rnd(100)
				if random_dir < 25 then 
					take_step(m,1)
				elseif random_dir >= 25 and random_dir < 50 then 
					take_step(m,2)
				elseif random_dir >= 50 and random_dir < 75 then 
					take_step(m,3)
				else
					take_step(m,4)
				end
			else -- take step closer to player
				take_step(m, 0)
			end
		end
	end
end

function update_monster(m)
	for b in all(balls) do 
		if not p1_is_grabbed and circ_collision(m.sm_x+4,m.sm_y+4,4,b.x+4,b.y+4,4) then 
			reset_pos(b)
			b.dy*=-1
			b.dx*=-1
			stun_monster(m)
		end
	end
	for a in all(arrows) do
		if m.stun == 0 and rect_colllision(m.sm_x,m.sm_y,8,8,a.x+4,a.y,2,8) then 
			stun_monster(m)
			del(arrows, a)
		end
	end

	for p in all(poison) do 
		if circ_collision(m.sm_x+4,m.sm_y+4,4,p.x+4,p.y+4,4) then
			del(monsters, m)
			init_particle(m.sm_x+rnd(8),m.sm_y+rnd(8),rnd(1),1+rnd(1), 2+rnd(2), 13)
			sfx(23)
		end 
	end

	if m.stun > 0 then 
		m.stun -=1
		if m.stun % 4 == 0 then 
			if m.stun_spr < 62 then 
				m.stun_spr+=1
			else
				m.stun_spr = 59
			end
		end
	else
		m.sm_x=lerp(m.sm_x,m.x*8,0.2)
		m.sm_y=lerp(m.sm_y,m.y*8,0.2)
	end
end

function stun_monster(m)
	if m.stun == 0 then 
		init_particle(m.sm_x+rnd(8),m.sm_y+rnd(8),rnd(1),1+rnd(1), 2+rnd(2), 13)
		shake+=0.02
		sfx(22)
	else
		sfx(11)
	end 
	m.stun = 120
	m.spr=58
end

function take_step(m,force_dir)
	if (m.x > p1x or force_dir == 1) and not is_tile_id(m.x-1, m.y, solid_id) then 
		m.x-=1
	elseif (m.x < p1x or force_dir == 2) and not is_tile_id(m.x+1, m.y, solid_id) then 
		m.x+=1
	elseif (m.y > p1y or force_dir == 3)  and not is_tile_id(m.x, m.y-1, solid_id) then 
		m.y-=1
	elseif (m.y < p1y or force_dir == 4)  and not is_tile_id(m.x, m.y+1, solid_id) then 
		m.y+=1
	end
	m.spr = m.spr == 56 and 57 or 56

	local diffx=abs(m.x - p1x)
	local diffy=abs(m.y - p1y)
	if (diffx == 0 and diffy == 0) then --attack
		m.x=m.sx
		m.y=m.sy
		hurt_player()
	end
end

function draw_monster(m)
	spr(m.spr,m.sm_x,m.sm_y)
	if (m.stun > 0)spr(m.stun_spr,m.sm_x,m.sm_y-8)
end

bouncies={}
function init_bounce(x,y)
	local b={
		x=x,
		y=y,
		size=4,
		c=0,
		hp=6,
	}
	add(bouncies, b)
end

function update_bounce(b)
	for ba in all(balls) do 
		if b.c <= 0 and not p1_is_grabbed and circ_collision(b.x,b.y,b.size,ba.x+4,ba.y+4,4) then 
			sfx(25)
			b.hp-=1
			shake+=0.01
			--weird bounce ...
			local rnd_val = (rnd(2)/40) - (rnd(2)/40)
			local angle = angle(b.x, b.y,ba.x+4, ba.y+4) + rnd_val
			local dx = ba.x - (ba.x + cos(angle)*1.5)
			local dy = ba.y - (ba.y + sin(angle)*abs(ba.dy*1.5))
			if abs(dy) < max_speed and abs(dx) < max_speed then
				ba.y = ba.oy
				ba.dy = dy
			else
				del(bouncies,b)
				init_particle(b.x,b.y,0,0,4,8)
			end	
			ba.x = ba.ox
			ba.dx = dx
			b.c = 8
		end
	end
	if (b.c > 0)b.c-=1

	if b.hp < 0 then 
		del(bouncies,b)
		init_particle(b.x,b.y,0,0,4,8)
	end

	if circ_collision(p1_sm_x+4,p1_sm_y+4,3,b.x,b.y,b.size) then 
		hurt_player()
	end
end

function draw_bounce(b)
	circfill(b.x,b.y,b.size+b.c/2,8)
	spr(117,b.x-4,b.y-4)
end

-->8
--intro

intro_pages={
  "the beetle volk and his trusty old friend kugel were wandering around the forest when they saw a weird looking castle in the middle of nowhere. curious as they were, the two friends entered the building not knowing they have made a grave mistake...",
  "because as soon as they entered the building the door closed behind them! confused and a little bit scared, volk desperately tried to open the door. something even worse was about to happen as two shifty eyes emerged from the shadows.",
  "as the creature moved closer and closer, volk sees that this long paddle-like thing has his friend! ~ let him go, screamed volk! ~ no, i need you and your round friend to help me find the exit, then i will let him go. and call be allein, said the paddle.",
  "as volk knows he has no way to beat allein, especially without his friend, he agrees with his terms, hoping that he will collaborate and hold his terms of agreement..."
}

function new_page(page)
  intro_page = page
  current_page = intro_pages[page]
  intro_index = 1
  intro_step = 1
  intro_counter = 0
  intro_cut = 1
  intro_y=0
	intro_start_game=false
end

function handle_intro()
  if intro_index > 4 and btnp(‘) then 
    sfx(18)
		if intro_page < #intro_pages then
      new_page(intro_page+1)
    else
			intro_start_game=true
		end
  end

  if not intro_start_game then
    intro_y=lerp(intro_y,129,0.1)
  else
    intro_y=lerp(intro_y,-3,0.1)
  end
	if intro_y < -2 then
		game_started=true
		show_intro=2
		t=0
		sfx(4)
		for i=0,24 do 
			init_particle(rnd(128),rnd(128),0.75, -(1+rnd(2)), 3+rnd(3), 1)
		end
	end 

  if intro_y > 127 then
    if intro_counter < 1 then 
      intro_counter+=1
    else
			
      intro_counter=0
      if intro_index < #current_page then
        intro_index+=1
        intro_step+=1

				if intro_index % 2 == 0 then 
					sfx(current_char == "." and 20 or 19)
				end
        local current_char = sub(current_page, intro_index, intro_index)
        if (intro_step > 22 and (current_char == "." or current_char == " " or current_char == "!")) or intro_step > 32 then 
          new_line()
        end
      end
    end
  end
end

function new_line()
  intro_step = 0
  local printed = sub(current_page, 1, intro_index)
  --add new line
  printed = printed .. "\n"

  local new_line_index = intro_index+1
  local new_line_char = sub(current_page, new_line_index, new_line_index)
  if new_line_char == " " then 
    new_line_index+=1
  end

  local not_printed = sub(current_page, new_line_index, #current_page)
  current_page = printed .. not_printed
  intro_cut = intro_index
end

function draw_intro()
  rectfill(0,-1,128,intro_y,1)
  print(sub(current_page, 1, intro_index), 3, intro_y-125, 7)
  local help_string =  "next" 
  if intro_index < #current_page then 
    help_string = "skip"
  elseif intro_page == #intro_pages then 
    help_string = "start"
  end

  local bounce = 0
  if help_string == "start" or help_string == "next" then 
    bounce = sin(t)*1.1
  end
  if (intro_index > 4 and not intro_start_game)print(help_string .. " ‘", 95+bounce, 122, 12)

  zspr(128+(intro_page-1)*3,3,3,64,intro_y-64,2)
end

function zspr(n,w,h,dx,dy,dz)
	local sx = shl(band(n,0x0f),3)
	local sy = shr(band(n,0xf0),1)
	local sw = shl(w,3)
	local sh = shl(h,3)
	local dw = sw*dz
	local dh = sh*dz
	sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end
__gfx__
000000005555555500000000000000000000000011111111555955550ffffff00cccccc010101010555555550007a00000000000200000204888888400000000
00000000111111110002200000000000094994901111111611198111f111111fcc7ccccc010101011144441100a009000949949000020e200187288000000000
00700700dd1dd1d1002222000033330094242429111116561dd89d1df155551fc7c7cccc10101010d4aaaa410090090094244249022e000208e2218008888880
00077000111111110222222003333330422422421116565611155111f555555fcccccccc01010101149119410009900022000022002222000822118081888818
00077000d1dd1ddd20222202033333302422422416565656dd1421dd2ffffff2cccccc7c10101010d491194d00020000440000242000e2e00881188088888888
0070070011111111002222000333333022422422565656561114211142222222ccccc7c701010101122222210009000024900942002002220888881027222272
000000001dd1dd1d00222200003323004224224256565656d1d42dd144444422cccccccc101010101dd1dd1d000990002249924202e200200888888022222222
00000000555555550020020000044000242242245656565655511555044422200cccccc001010101555555550009990042244224000020000e2e2e2088888888
02222000022220000022220000222200002222000022220000222200000000000022220000222200002222000000000000000000000000000000000000000000
00220000002200000002200000022000000220000002200000022000002222000002200000022000000220000000000000000000000000000000000000000000
07227002272270000072270220722700202222000022220200722700000220000072270220722700007227000000000000000000000000000000000000000000
00881010018810100018811001188110011111100111111001188110017227100018811001188110011881100000000000000000000000000000000000000000
01111100001111020111110000111102001111022011110010111101101881012711117000111102201111020000000000000000000000000000000000000000
20111100001111002011110000111100001111000011110002111120021111200077770007111170001111000000000000000000000000000000000000000000
00dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd00000000000077770000dddd000000000000000000000000000000000000000000
00d0000000000d0000d0000000000d0000000d0000d0000000d0000000000d00000000000000000000d00d000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000aa00000607000000700000ffffff00ffffff020000020200020002022000000220000
00ee7e0000222200001111000011110000111100002222000007a000007009000074600000060000fdf666fff666fdff00020220000220000000020000000220
0ee22e7002ee7e200222222001222210012222100222222000a00900009009000004000000040000ff66ffdff6dff6ff02220002220200222202000222022000
022222200e2222700eeee7e002222220022222200222222000900900000990000004000000040000f6fff6ffffff7fff00222200220222202002220220220002
0222222002222220022222200e2222e0022222200222222000099000000200000004000000040000ff7676fff76f6dff20002220200002002200220020202200
01222210012222100222222002eee7200ee22e700222222000020000000900000004000000040000f666f6ffffd66d6f00200222002200000220222000022200
0011110000111100001111000022220000ee7e000022220000099000000990000064d00000040000fff6fd6ffff6ffff02220020000200220220002002002220
0000000000000000000000000000000000000000000000000009990000099900000d0000000d00000ffffff00ffffff000002000220002200000200000200020
00000000077677777777777777777777777767700000000000000000000000000088880000888800000000000ddddd0000ddddd00d00000000ddddd000000000
000000007cc76666666666666666666666667cc70007000000000000003333000d8888d00d8888d000000000dd0000d00d00000dd00dddd00dd000dd00000000
00077000c1dddddddddddddddddddddddddddd1c00a090000033330003333330088888800888888000888800d0ddd00dd00ddd00d0d000dd0d00dd0d00000000
007e2700c11dddddddddddddddddddddddddd11c00090000033333300313313008888880027227200d8888d0d0d00d0dd0d000d0d0d0d00d0d0d0d0d00000000
0272272001122222222222222222222222222110000200000313313003333330027227200222222008888880d00d0d0dd0d0d0d0d0d00d0d0d000d0d00000000
0227722000000000000000000000000000000000000990000333333000322300088888800888888008888880dd000d0dd0dd00d0d00ddd0d00ddd00d00000000
00222200000000000000000000000000000000000000000000322300000440000080020000200800027227200dddd00ddd000dd00d0000ddd00000d000000000
0000000000000000000000000000000000000000000000000004400000044000008000000000080008888880000000d00ddddd0000ddddd00ddddd0000000000
00055555555555555555500051111115000000000cccccc00cccccc0000000000042240000000000000000000000000000000000000000000000000000000000
005dd1dd11111111111115001d111d1d00000000cccccc7ccc7ccccc000000000042290009499444494499444449949000000002200000000000000000200000
051111111dd1dd1ddd1d11501111111100000000ccccc7c7c7c7cccc000000000092240094244222222222222224424900000222000000000000000000020000
511d1dd1111111111111d1d5dd1dd1dd00000000cccccccccccccccc000000000042240092224222222242222224222900000220000000000000000000220000
51d11111dd1dd1dd11d111d51111111100000000cc7ccccccccccc7c000000000094290044224224442242244224224400000222222222222222222022222000
5111d1dd11111111d111d115d1dd1dd100000000c7c7ccccccccc7c7000000000092290024422242244222422422244200000222222222222222222222220000
51d11111d1dd1dd111d1d1d51111111100000000cccccccccccccccc000000000092240022422242224222422422242200000002222222222222222222200000
51d11d115555555511d111d555555555000000000cccccc00cccccc0000000000042240042244224422442244224422400000000000022220000000022000000
51d1d1157666666d0555555500000000000000005555955555595555000000000000000000000000000000000000000000000000000022200000000000000000
5111d1d5676666d15111111100099000000000001118911111198111000000000000000000000000000000000000000000000000000022200000000000000000
51d111d566dddd115dd1dd1d00942900000000001dd98d1d1dd89d1d000000000000000000000000000000000000000000000000000022200000000000000000
51d1d11566d11d115111111100242400000000001115511111155111000000000000000000000000000000000000000000000000000222200000000000000000
5111d1d566d15d115d1dd1dd0024220000000000dd1421dddd1421dd000000000000000000000000000000000000000000000000000222200000000000000000
51d111d566dddd115111111100422400000000001114211111142111000000000000000000000000000000000000000000000000202222000200000000000000
51d1d1156d5555d151dd1dd10024240000000000d1d42dd1d1d42dd1000000000000000000000000000000000000000000000002002222000020000000000000
5111d1d5d555555d0555555500242200000000005551155555511555000000000000000000000000000000000000000000000002202222200220000000000000
5d111d1151d1d11511d11d1500000000000000000000000000000000666666660000000000000000000000000000000000000000222222222200000000000000
5d1d1d115111d1d511111d15000000000000000000000000000000000d0d0d0d0000000000000000000000000000000000000000022222222000000000000000
511d111d51d111d5dd1d1115000000000000000000000000000000000d0d0d0d0000000000000000000000000000000000000000222222222220000000000000
5d111d1151d1d11511111d150000000000000000033333300000000006060606022222200000000000000000000000002200000022e2222e2222000002220000
5d1d11115111d1d51dd1d1150000000000000000333bb3330bbbbbb006060606222ee2220eeeeee00000000000000000202000022ee2222ee222200020222000
0511d1dd51d111d511111150000000000000000013333331bbb33bbb0606060612222221eee22eee0000000000000000200000022ee2222ee222200000022000
0051111151d1d115dd1dd5000000000000000000411111141bbbbbb106060606411111141eeeeee1000000000000000020000002e22222222e22200000022000
00055555055555505555500000000000000000000444444001111110111111110444444001111110000000000000000020000002222111122222200000022000
05555550555555505555555500000000000000000000000001111110000000000000000000000000000000000000000022000002222211222222200000220000
511d1d15111111151111111100000000000000000000000000000000000000000000000000000000000000000000000022000002222222222222200000110000
5d111d15d1dd1dd51dd1dd1d00000000000000000007700000000000000000000000000000000000000000000000000002200000222222222222000001110000
5d1d1115111111151111111100000000000000000070070000000000000000000000000000000000000000000000000002211000222222222222000001100000
511d1d15dd1dd1d5dd1dd1dd00000000000000000070070000000000000000000000000000000000000000000000000000111111112222222211100111100000
5d111d15111111151111111100000000000000000007700000000000000000000000000000000000000000000000000000001111111222221111111111000000
5d1d11151dd1dd15d1d111d100000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111100000000
511d1d15555555505111111500000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111100000000
0111111111111111111111100dddddddddddd2ddddddddd00dddddddddddddddddddddd001111111111111111111111000000111111111111111111110000000
111111111111111122111111dddddddddd99922dd2dddddddddddddddddddddddddddddd11111111111111111111111100001111111eeeeee111111111000000
111112e22111111122111111ddd9ddddd94444222ddd9ddddd2ddddddddddddddddddddd1111111111111111111111110001111111eee77eee11111111100000
122e222211111111e2211111ddd2dddd94442229dddd2dddd222d2ddddd22ddddddddddd111111111111111111111111001111111ee7e7eeeee1111111110000
122222221112211122211111ddd41ddd44422244dddd41ddd22222222d2222d22ddddddd15111111111151151111111101111111eeeeeeeeeeee111100111000
1122e221111e2111e2221111ddd41ddd42422242dddd41dd222222222222222222dddddd1511111115155155115111150111011ee7eeeeeeeeeee11100011000
11222221111e211122222111dddddddd42111114dddddddd2222222222222222222d222d55155115551555551551511511100111eeeeeeeeeeee111100022200
11d222111112222122222111dddddddd44411142dddddddd222122222222211222222222551551555515525555515155210001111eeeeeeeeee1111000002200
116d222111e22221222d111188888888821111188888888822111212222221112212212255555155555555222555515522000d111111eeeee2111dd000002200
117ddd11112222111dddd11166666655555ddd555666666621111112111221112112112255555555555555552255555522000ddd111112ee2221ddd000002200
11666d11112ddd111161d16166666665555d5d555566666621111111111221111111111155555555555554222255555522020ddddeee22e22eedddd002002200
11716d11111d6d111161d16166666665555d5d555566666611111111111121111111111155552254444444222555555502200dddddeeeeeeeeddddd000222000
11616d11111616d11166761166666666555111155556666611111111111111111111111155555222444455555555555500000ddddddeeeeeedddddd000000000
11766d11111666d1667666616666666655551111555666661111117111111117111111115525522444555555555555550000ddddddddddddddddddd000000000
11167d111111676666667661666666666555511115556666076772e27777772e27771670552522224255555555555555000dddddddddddddddd00ddd00000000
117666d116766667676666116666666665511111111556667c7622722666622722661717555111111245555555555555000dddd0000dddddd00000ddd0000000
111767667667667666766111661166666655151111555661c1ddd222dddddd222ddd1d11521111144444444445555555000ddd0000000000000000dd00000000
33666676666666667766663b61116116665515111155556111ddddd11ddddd111ddd11115551111124444444445555550000dd0000000000000000dd00000000
356676676694967666676633111111166165551515555561112211111222221111221111555dddd544444444445555550000dd0000000000000000dd00000000
35676666649494676676665b11111111116555555555551111111111111111111111111155dd54d444444444455555550000d00000000000000000d000000000
33b666766944496676666533111111111111555555555511111111111111111111111111444444d444444555555555550000d00000000000000000d000000000
33357666649494666766533311111111111111155551111111111111111111111111111144444444445555555555555500000000000000000000000000000000
3b333b333222223333333b3b11111111111111111511111111111111111111111111111144444445555555555555555500000000000000000000000000000000
0333333332222233333b333001111111111111111111111001111111111111111111111004455555555555555555555000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009999000000000003330000000000000000000077777777777777777777777777777777777777777777777777777777777777777770000000000000000000
00099999000002000033333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000999000022220033333300000000000000000077777700007777700007770007770000077770007777770007777700007770007770000000000000000000
00009999002222200033333300000000000000000077777770077777770007770007770007777777007777770077777770007770007770000000000000000000
00000999002222200033333000000000000000000077000770077000777007777000770007700007007700000077000777007777000770000000000000000000
00099999000022220003330000000000000000000077020770770000077007777700770077000000007700000770000077007777700770000000000000000000
000099990000020000000000000000000000000000770007707707e20770077077007700770077770077777707707e2077007707700770000000000000000000
00000000000000000777770777770000000000000077777700770e22077007700770770077007777007777770770e22077007700770770000000000000000000
00000000077007770700070707070000000000000077777000770211077007700777770077000077007700000770211077007700777770000000000000000000
00000000700007770770770707070000000000000077000000777000770007700077770077700077007700000777000770007700077770000000000000000000
00000000700007070770770700770000000000000077000000077777770007770007770007777777007777770077777770007770007770000000000000000000
00000000707007070770770707070000000000000077000000007777700007770000770000777770007777770007777700007770000770000000000000000000
00000000777007070770770707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777770777770000000000000077777777777777777777777777777777777777777777777777777777777777777770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000007000007700000077007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000077700007770000777007777700007777777777777777777777777777777777777777777777777777777700000000000000000000000000000000
77700070000770770007777007777007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000000770770007777707777007777000007777777707700000770000770000777000077007700077700777700000000000000000000000000000000000
770eeee0007700077007707777077007777000007777777707700000770007777000777000077007700777007777770000000000000000000000000000000000
770eeee0007777777007707777077007700000000007700007700000770007777000777700077007707770007700070000000000000000000000000000000000
77000ee000eee7777ee770777ee77007700000000007700007700000770077007700777770077007707700007700000000000000000000000000000000000000
07700ee00eeeee077eee7077eee77007777700000007700007777777770077007700770770077007777000007777000000000000000000000000000000000000
0077eee00ee7ee077eeee00eeee77007777700000007700007777777770070000700770077077007777700000077770000000000000000000000000000000000
0077ee000ee0ee000eeeee0eeee00000000000000007700007700000770777777770770077777007707700000000770000000000000000000000000000000000
0000ee00ee000ee00eeeeeee77707770777077700007700007700000770777777770770007777007700770007000770000000000000000000000000000000000
ee00ee00eeeeeee00ee0eeeeee707070007070700007700007700000770770000770770000777007700777007777770000000000000000000000000000000000
ee00ee00eeeeeee00ee0eeee77707070777070700007700007700000770770000770770000077007700077700777700000000000000000000000000000000000
eeeee00eee000eee0ee0eeee7ee07070700070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeee00eee000eee0ee00ee077707770777077707777777777777777777777777777777777777777777777777777777700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
008100044102a1011000810801000100000000000000000000000000000000000000000000000808000000000000000000000000000804040000000000000000818181810010100041414141000000008181810100a1a10000004100000000008181810000010001000000000000000081818100000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000300000e05003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000107105061000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000b000004055130550e005060050e005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010800000405508055110550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00100000050550a0550f0551d05524055010051b055020052e0550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0108000000075160550f0550705500035000050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
00100000270651f055220551805511055010150c0550f055090550205500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0009000006651096410d6310c6210b611036110061100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
00060000030351f545325550050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000a000004046000160a0060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
000a00000206305073080030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
001000000003500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000000203504055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0010000003545075550f565165751b505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
0009000000021096410d6310301100011036010061100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
000c00001803409044130442205400064320040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000043200400004000040000400004000040000400004
0006000001d6100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d01
0110000013025130351604518055270552905522055240552705527055270552e0552b0552e05530055330553300531005370453a045160051b00524005240051d0051800513005160051b005240053000500005
00090000000400305005050070500a0500f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000051000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000700000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000304500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000a00000303105041100010001115001010010250120001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000700000e03106d7102d710ad7102d7100d71020010000100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d0100d01
000d000017054070540b054100541a004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000a0000030310c041100010000115001010010250120001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
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
