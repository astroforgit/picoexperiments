pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- td + flowers + platformer
-- by sebastian lind

p_radius = 25
t = 0
c_t="camera shake:"
s_t="seed rnd:"
ca_t="cam follow:"
ac_t="auto cut:"
game_state = 0
show_message_c = 0
cpu = stat(1)

game_over = false
game_won = false

function _init()
	cartdata("elstiskalinjen_flanet")
	arcade_won = dget(0)
	waves_won = dget(1)

	menuitem(1, c_t..is_on(is_shake), function() toggle_camera_shake() end)
	menuitem(2, s_t..is_on(seed_rnd), function() toggle_seed_rnd() end)
	menuitem(3, ca_t..is_on(cam_follow), function() toggle_camera_follow() end)
	menuitem(4, ac_t..is_on(auto_cut), function() toggle_auto_cut() end)

	vgnt={
		pos= -140, -- open: -140
		size = 288, -- open: 288
		mode = "open"
	}
end

function toggle_seed_rnd() 
	seed_rnd = not seed_rnd
	menuitem(2, s_t..is_on(seed_rnd), function() toggle_seed_rnd() end)
	sfx(1)
end

function toggle_camera_shake()
	is_shake = not is_shake
	shake = 0
	menuitem(1, c_t..is_on(is_shake),function() toggle_camera_shake()  end)
	sfx(1)
end

function toggle_camera_follow()
	cam_follow = not cam_follow
	menuitem(3, ca_t..is_on(cam_follow),function() toggle_camera_follow()  end)
	sfx(1)
end

function toggle_auto_cut()
	auto_cut = not auto_cut
	menuitem(4, ac_t..is_on(auto_cut), function() toggle_auto_cut() end)
	sfx(1)
end

function is_on(state) 
	return state and "on" or "off"
end

function _update60()
	t += 0.007
	init_stars()
	foreach(particles, update_particle)
	if game_state == 0 then 
		update_start()
	elseif game_state == 1 and not game_over then
		spawn_enemies()

		foreach(effects, update_effect)
		foreach(seeds, update_seed)
		foreach(enemies, update_enemy)
		foreach(towers, update_tower)
		foreach(bullets, update_bullet)
		update_player()
		update_ui()
		camera_follow()

		if not game_over and health_t <= 0 then 
 			go_to_game_over(false)
		end
	end
	if game_over then 
		handle_game_over()
	end
	if (show_message_c > 0) show_message_c-=1
end

star_c = 0
function init_stars()
	if star_c < 4 then
		star_c += 1
	else
		star_c = 0
		init_particle(rnd(128),rnd(128),0,0,2+rnd(2),1)
	end
end

function handle_game_over()
	heart_s = lerp(heart_s, 32, 0.08)
	if btnp(4) then
		heart_s = 0
		sfx(33)
		game_over = false
		health = max_health
		health_t = max_health
		vgnt.mode = "open"
		new_record = false
		t = 0
		if planet_s == 0 then
			start_tutorial()
		elseif planet_s == 1 then
			start_arcade()
		elseif planet_s == 2 then 
			start_endless()
		end 
	elseif btnp(5) then
		go_to_menu()
	end
end

function spawn_enemies()
	if planet_s == 0 then
		tutorial_spawner()
	elseif planet_s == 1 then
		arcade_spawner()
	elseif planet_s == 2 then 
		enless_spawner()
	end
end

function _draw()
	cls(0)
	camera_shake()
	foreach(particles, draw_particle)

	if game_state == 0 then 
		draw_start_screen()
	elseif game_state == 1 then
		draw_atmosphere()
		if not game_over then
			circfill(64,64,p_radius-3,6)
			spr(16,40,40,6,6)
		end
		foreach(seeds, draw_seed)
		foreach(towers, draw_tower)
		draw_player()
		foreach(bullets, draw_bullet)
		foreach(enemies, draw_enemy)

		camera()
		draw_ui()
		foreach(effects, draw_effect)

		if planet_s == 0 then 
			draw_tutorial()
		elseif planet_s == 1 then 
			draw_arcade()
		elseif planet_s == 2 then
			draw_endless()
		end

		if show_message_c > 0 then 
			print(show_message_t, 48, 24, 1)
		end
	end
	draw_vignette(vgnt.mode)

	if game_over then
		for i=0,12 do
			fillp(Å) 
			line(64, 64, 64 + sin(t / 3 - (i / 12)) * heart_s * 2.5, 64+cos(t / 3 - (i / 12)) * heart_s * 2.5, game_won and 14 or 8)
		end
		fillp()
		if not game_won then
			rspr(64, 40, 24, 24, t, 64, 64, heart_s, heart_s)
		else 
			rspr(104, 32, 24, 24, t, 64, 64, heart_s, heart_s)
		end
		if(vgnt.size < -4)draw_game_over()
	end
	
	--print(cpu, 4, 4, 8)
	cpu = stat(1)
end

function draw_atmosphere()
	fillp(Å)
	circ(64, 64, 62-sin(t)*1.1, 1)
	fillp()
end

heart_s = 0
function draw_game_over()	
	spr(184, 24, 24 + sin(t)*1.1, 5, 1) --game
	spr(game_won and 168 or 172, 72, 24 + sin(t)*1.1, 4, 1) -- over

	if new_record then
		spr(11, 2, 112)
		local wave_s = wave == 1 and " wave" or " waves"
		print("new record! - " .. wave .. wave_s .. " won!", 12, 114, 9) 
	end

	rectfill(0,121,128,128,1)
	print("try again é", 2, 122, 12)
	print("go to menu ó", 74, 122, 12)
end

--- ugly code incomming, had no brain power to actually care here
function draw_start_screen()
	spr(112, planet_x - 32 - planet_st * 1.5, planet_y + 4 - 32, 8, 8)
	print("by sebastian lind", 2 - planet_st * 1.1, 122, 1)
	--line(0,64,128,64,2)
	--line(64,0,64,128,2)

	if planet_start and planet_s < 3 then 
		circfill(64,64,planet_st - 46,1)
		circ(64,64,planet_st - 8, 1)
	end
	
	fillp(Å)
	circ(32 - planet_st * 1.5, 64 + 4, 52, 1)
	fillp()
	local tele_x = planet_x + cos(planet_a) * 40
	local tele_y = planet_y + 4 + sin(planet_a) * 40
	rspr(56, 0, 8, 8, planet_a - 25, tele_x - planet_st * 1.5, tele_y, 8, 8)
	
	local tx = planet_x + cos(0.15) * 38 + (planet_s == 0 and 8 or 0)
	local ty = planet_y + sin(0.15) * 38
	if not planet_start or planet_s == 0 then  
		spr(200, tx + (planet_s == 0 and sin(t) * 1.1 or 0), ty, 7, 1)
	end

	local ax = planet_x + cos(0.05) * 38 + (planet_s == 1 and 8 or 0)
	local ay = planet_y + sin(0.05) * 38 - 1
	if not planet_start or planet_s == 1 then  
		spr(216, ax + (planet_s == 1 and sin(t) * 1.1 or 0), ay, 7, 1)
	end
	if planet_s == 1 and not planet_start then
		print("won", ax + (planet_s == 1 and sin(t) * 1.1 or 0), ay + 10, 13)
		spr(arcade_won == 0 and 30 or 31, ax + 13 + (planet_s == 1 and sin(t) * 1.1 or 0), ay + 9)
	end

	local ex = planet_x + cos(0.95) * 38 + (planet_s == 2 and 8 or 0)
	local ey = planet_y + sin(0.95) * 38 - 6
	if not planet_start or planet_s == 2 then  
		spr(232, ex + (planet_s == 2 and sin(t) * 1.1 or 0), ey, 6, 1)
	end
	if planet_s == 2 and not planet_start then
		print("medals", ex + (planet_s == 2 and sin(t) * 1.1 or 0), ey + 10, 13)
		-- no need to write fancy code here...
		if (waves_won < 10)spr(44, ex + 24 + (planet_s == 2 and sin(t) * 1.1 or 0), ey + 9)
		if (waves_won >= 10)spr(45, ex + 24 + (planet_s == 2 and sin(t) * 1.1 or 0), ey + 9)
		if (waves_won >= 20)spr(46, ex + 32 + (planet_s == 2 and sin(t) * 1.1 or 0), ey + 9)
		if (waves_won >= 30)spr(47, ex + 40 + (planet_s == 2 and sin(t) * 1.1 or 0), ey + 9)
	end

	local abx = planet_x + cos(0.85) * 38 + (planet_s == 3 and 8 or 0) + 2
	local aby = planet_y + sin(0.85) * 38 - 4
	if not planet_start then  
		spr(248, abx + (planet_s == 3 and sin(t) * 1.1 or 0), aby, 5, 1)
	end

	local targ_x = 0
	local targ_y = 0
	if planet_s == 0 then 
		targ_x = tx
		targ_y = ty
	elseif planet_s == 1 then 
		targ_x = ax
		targ_y = ay
	elseif planet_s == 2 then 
		targ_x = ex
		targ_y = ey
	elseif planet_s == 3 then 
		targ_x = abx
		targ_y = aby
	end
	if (not planet_start)circfill(targ_x - 6, targ_y + 4, 3-sin(t)*0.9, 7)

	spr(136, 4 - planet_st / 0.7, 4, 7, 2)

	if planet_start and planet_s == 3 then --and planet_st >= 71
		draw_about()
	end
end

function draw_about()
	print("hi!\n\nthis is a platform tower defence\ngame with a flower mechanic\nmixed in. defend the planet\nfrom alien forces by jumping on\nthem and creating towers.\ni would recommend you to start\nwith tutorial first!\n\nif you want to see more of\nmy games then follow\n@elastiskalinjen on\ntwitter or itch.io.\n\ngood luck and have fun!\n\n/ sebastian", 145-planet_st*2,4,12)
	print("press ó to back", 134-planet_st, 122, 1)
	spr(123, 246-planet_st*2, 7, 3, 1)
end

function draw_vignette(_mode)
	-- check modes
	if _mode=="open" then
		if vgnt.pos >- 140 then
			vgnt.pos-=4
			vgnt.size+=8
		end
	elseif _mode=="close" then
		if vgnt.pos < 8 then
			vgnt.pos+=2
			vgnt.size-=4
		end
	end

	-- draw vignette
	-- change palt to your needs
	-- change sspr to your needs
	-- x==player x   y==player y
	if vgnt.pos >= -128 or vgnt.mode == "close" then
		palt(0,false)
		palt(1,true)
		local factor,x,y=vgnt.pos+20,64,64
		sspr(88,32,16,16,x+vgnt.pos,y+vgnt.pos,vgnt.size,vgnt.size)
		rectfill(0,0,x-20+factor,512,0)
		rectfill(x-20+factor,0,x+27-factor,y-20+(vgnt.pos+20),0)
		rectfill(x+27-factor,0,1024,512,0)
		rectfill(x-20+factor,y+27-factor,x+27-factor,512,0)
		palt()
	end
	-- print("pos: " .. vgnt.pos .. ": size: " .. vgnt.size, 4,4,8)
end

function go_to_game_over(won)
	game_won = won
	sfx(not won and 31 or 32)
	game_over = true
	vgnt.mode="close"
	if planet_s == 2 and wave > waves_won then
		waves_won = wave
		dset(1, waves_won)
		new_record = false
	end

	for i=0,12 do 
		init_particle(64-rnd(32)+rnd(32),64-rnd(32)+rnd(32),(i / 12), 3, 3+rnd(2),14)
	end
	shake+=0.15
	clear_objects()
end

cam_follow = true
function camera_follow()
	if cam_follow then 
		if p1rad > 66 then 
			cam_x = lerp(cam_x, p1x -64, 0.05)
			cam_y = lerp(cam_y, p1y -64, 0.05)
		else
			cam_x = lerp(cam_x, 0, 0.06)
			cam_y = lerp(cam_y, 0, 0.06)
		end
	else
		cam_x = 0
		cam_y = 0
	end
end

-->8
--player
p1cx=64
p1cy=64
p1a=0.25
p1rad=p_radius
p1ground=true
p1jumping=0
p1jumpforce=0
p1gravity=1
p1speed=0
p1spr=1
p1sprcounter=0
p1dir=0
p1_slowed_counter = 0
p1_slowed = 1
p1x = p1cx + cos(p1a) * p1rad
p1y = p1cy + sin(p1a) * p1rad
auto_cut = false

function update_player() 
	player_movement()
	player_jump()
	
	if not btn(5) then
		player_plant()
	end

	if p1_slowed_counter > 0 then
		p1_slowed_counter-=1
		p1_slowed = lerp(p1_slowed, 0.3, 0.1)
	else 
		if p1_slowed < 0.99 then
			p1_slowed = lerp(p1_slowed, 1, 0.2)
		else 
			p1_slowed = 1
		end
	end

	p1x = p1cx + cos(p1a) * p1rad
	p1y = p1cy + sin(p1a) * p1rad
end

function player_plant()
	if btnp(4) and health_t > low_health then
		health_t -= 18
		init_seed(p1a, p1rad + 3, p1dir)
		sfx(7)
	end
end

function player_jump()
	if btn(î) and p1jumping < 2 then 
		if p1jumping == 0 then
			p1jumping = 1
			for i=0,2 do 
				init_particle(p1x,p1y,p1a+rnd(1)/10-rnd(1)/10,1+rnd(1),1+rnd(3),7)
			end
			sfx(6)
		end
		p1ground = false
		if p1jumpforce < 2.8 then
			p1jumpforce+=0.4
		else
			p1jumping = 2
		end
	elseif not p1ground then
		p1jumping = 2
	end

	p1jumpforce *= 0.97
	p1rad += p1jumpforce * slowmo * p1_slowed

	if p1jumping < 2 then -- wait until released or full hop
		return 
	end
	
	if not p1ground then
		local fastfall = 0
		if btn(É) then
			fastfall = 0.2
		end
	
		if p1rad > p_radius then 
			if p1gravity < 4 then
				p1gravity += 0.05 + fastfall
			end	
			p1rad-= p1gravity * slowmo
		else
			player_land(true)
		end
	end
end

function player_land(reset_grav)
	if reset_grav then 
		p1gravity = 1
		--p1rad = p_radius
		p1ground = true
	else
		p1jumpforce = 0.8
	end
	p1jumpforce = 0
	p1jumping = 0
	init_particle(p1x, p1y, p1a+rnd(1)/10-rnd(1)/10, rnd(1), 1+rnd(3), 13)
	shake+=0.04
	sfx(5)
end

function player_movement()
	local damp = p1ground and 1 or 0.8
	if btn(ë) then
		if (p1speed > -0.01)p1speed -= 0.0005
		if (p1dir == 1)p1spr = 1
		p1dir = 0
	elseif btn(ã) then 
		if (p1speed < 0.01)p1speed += 0.0005
		if (p1dir == 0)p1spr = 4
		p1dir = 1
	end
	
	p1a += p1speed * damp * slowmo * p1_slowed
	
	if not btn(ã) and not btn(ë) then
		p1speed *= 0.9
		if abs(p1speed) < 0.001 then 
			p1speed = 0
		end
	else
		if p1sprcounter < 6 then
			p1sprcounter+=1	
		else
			p1sprcounter=0
			if p1spr < 3 + p1dir * 3 then
				p1spr += 1
			else
				p1spr = 1 + p1dir * 3
			end
		end
	end
end

function draw_player()
	rspr(p1spr * 8, 0, 8, 8, p1a-0.25, p1x, p1y, 8, 8)
	if not p1ground then
		fillp(Å)
		circ(p1x, p1y, 5, 12)
		fillp()
	end
end

-->8
-- draw a rotated, scaled
-- sprite at dy,dy with dw,dh
-- as dimensions
--     sx,sy,sw,sh - pos,dimensions
--     in spritesheet
--     a - angle
--     dx,dy,dw,dh - pos,dimensions
--     on screen
-- serious performance issues
-- with large values of dw,dh
function rspr(sx,sy,sw,sh,a,dx,dy,dw,dh)
	sx,sy,sw,sh,a,dx,dy,dw,dh=
			sx or 0, sy or 0,
			sw or 8, sh or 8,
			a or 0,
			dx or 0, dy or 0,
			dw or 8, dh or 8
	
	local s1,c1 = sin(a+0.125),cos(a+0.125)
	local half_dw,half_dh = dw/2,dh/2
	local x1,y1 = half_dw*c1,half_dh*s1
	local x2,y2 = half_dw*s1,half_dh*-c1
	local x3,y3 = half_dw*-c1,half_dh*-s1
	local x4,y4 = half_dw*-s1,half_dh*c1

	local dx1,dy1=(x4-x1)/dh,(y4-y1)/dh
	local dx2,dy2=(x3-x2)/dh,(y3-y2)/dh
			
	local dtxx,dtxy=(x1-x2)/dw,(y1-y2)/dw

	local dsx,dsy=sw/dw,sh/dw
	for y=0,dh-1 do
		local ssx,px,py=sx,dx+x2,dy+y2
		for x=0,dw-1 do
				local col=sget(ssx,sy)
				if (col ~= 0)    pset(px,py,col)
				px+=dtxx
				py+=dtxy
				ssx+=dsx
		end
		sy+=dsy
		x2+=dx2
		y2+=dy2
	end
end

-->8
-- help

shake=0
is_shake=true
cam_x = 0
cam_y = 0
function camera_shake()
	if is_shake then
		local shakex=16-rnd(32)
		local shakey=16-rnd(32)
	
		shakex*=shake
		shakey*=shake
		camera(cam_x + shakex, cam_y + shakey)
		shake=shake*0.95
		if(shake > 0.2)shake=0.18
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
	if (p.rad < 2)fillp(Å)
	circfill(p.x,p.y,p.rad,p.col)
	fillp()
end

effects={}
function init_effect(x,y,ex,ey,spr,col)
	local e={
		x = x,
		y = y,
		ex = ex, 
		ey = ey,
		lx = x + 4,
		ly = y + 4,
		spr = spr,
		col = col,
		speed = 0.05 + (flr(rnd(10)) / 100)
	}
	add(effects,e)
end

function update_effect(e)
	e.x = lerp(e.x, e.ex, e.speed)
	e.y = lerp(e.y, e.ey, e.speed)

	e.lx = lerp(e.lx, e.x+4, 0.12)
	e.ly = lerp(e.ly, e.y+4, 0.12)	
	
	if(distance(e.x, e.y, e.ex, e.ey) < 4)del(effects,e)
end

function draw_effect(e)
	if cpu < 0.8 then
		fillp(Å)
		line(e.lx, e.ly, e.x+4, e.y+4, e.col)
		fillp()
	end
	spr(e.spr, e.x, e.y)
end

-->8
--seeds

seed_rnd = false
seed_t=1
seeds={}
function init_seed(angle, rad, dir)
	local s={
		x = 64 + cos(angle) * rad, 
		y = 64 + sin(angle) * rad,
		sx = 0,
		sy = 0,
		rad=rad,
		angle=angle,
		dir=dir,
		grav=0,
		state=0,
		growth_rad=0,
		grooth_speed = 0.1 + rnd(1) / 10,
		growth_h = 32 + flr(rnd(29)),
		shootspeed = 0.005 + rnd(3) / 1000,
		g_bounce = 150 + flr(rnd(50)),
		growth_b = 0,
		g_spr = not seed_rnd and 21 + seed_t or 22 + flr(rnd(3))
	}
	add(seeds,s)

	if (not seed_rnd)seed_t = seed_t < 4 and seed_t + 1 or 1
end

function update_seed(s)
	if s.state == 0 then 
		if s.rad > p_radius then 
			if s.grav < 4 then
				s.grav += 0.05
			end	
			s.rad -= s.grav

			if s.dir == 1 then 
				s.angle+=s.shootspeed
			else
				s.angle-=s.shootspeed
			end
		else
			if s.state == 0 then
				s.growth_rad = s.rad
				s.sx = s.x
				s.sy = s.y
				s.state = 1
			end
		end

		s.x = 64 + cos(s.angle) * s.rad
		s.y = 64 + sin(s.angle) * s.rad
	elseif s.state == 1 then
		s.growth_rad += s.grooth_speed
		s.sx = 64 + cos(s.angle) * s.growth_rad
		s.sy = 64 + sin(s.angle) * s.growth_rad
		if s.growth_rad > s.growth_h then 
			s.state = 2
			if (s.growth_rad > 45) then sfx(8) else sfx(9) end
		end
	elseif s.state == 2 then
		s.growth_b = sin(t) / s.g_bounce

		s.sx = 64 + cos(s.angle + s.growth_b) * s.growth_rad
		s.sy = 64 + sin(s.angle + s.growth_b) * s.growth_rad

		if p1ground and (btn(É) or auto_cut) then
			if circ_collision(p1x,p1y, 4, s.x, s.y, 3) then 
				cut_seed(s)
			end
		end
	elseif s.state == 3 then
		if s.growth_rad > p_radius then 
			if s.grav < 4 then
				s.grav += 0.05
			end	
			s.growth_rad -= s.grav
		else
			s.state = 4
			shake+=0.03
			sfx(11)
		end

		s.sx = 64 + cos(s.angle + s.growth_b) * s.growth_rad
		s.sy = 64 + sin(s.angle + s.growth_b) * s.growth_rad
	elseif s.state == 4 then
		if circ_collision(p1x,p1y, 4, s.sx, s.sy, 3) then 
			collect_seed(s)
		end 
	end
end

function cut_seed(s)
	s.state = 3
	s.grav = 0
	sfx(10)
	init_particle(s.x, s.y, s.angle + rnd(1)/10-rnd(1)/10,0.5 + rnd(1),1+rnd(3),3)
end

function collect_seed(s) 
	local resource = s.g_spr-21
	del(seeds, s)
	p1resources[resource] += 1
	init_effect(p1x, p1y, resource * 24 - 6, 0, 39 + resource, resource_colors[resource])
	--add health back
	add_health(15)
	sfx(12)
end

function draw_seed(s)
	circfill(s.x, s.y, 1, 3)
	if s.state >= 1 and s.state < 3 then 
		line(s.x, s.y, s.sx, s.sy, 11)
	end
	if s.state >= 2 then
		local onGround = s.state >= 4 and 4 or 0 
		spr(s.g_spr + onGround, s.sx-4, s.sy-4)
	end
end

-->8
--ui
ui_y=0
slowmo = 1
shield_up = false
resource_colors = {12,4,13,15}
max_health = 126
low_health = 30
health = max_health
health_t = max_health
cu_i = 1
impl_towers = 4
shopping=false

function update_ui()
	if btn(5) then
		if not shopping then 
			sfx(13)
			shopping = true
		end
		ui_y = lerp(ui_y, 24, 0.1)
		slowmo = lerp(slowmo, 0.1, 0.05)

		if btnp(ë) then
			cu_i = cu_i < impl_towers and cu_i+1 or 1
			sfx(27)
		elseif btnp(ã)  then 
			cu_i = cu_i > 1 and cu_i-1 or impl_towers
			sfx(27)
		end

		if btnp(4) then
			shop(cu_i)
		end
	else
		if shopping then 
			sfx(14)
			shopping = false
		end
		ui_y = lerp(ui_y, 0, 0.1)
		slowmo = lerp(slowmo, 1.01, 0.2)
		if (ui_y < 0.5)ui_y = 0
	end

	health = lerp(health, health_t, 0.05)

	if (cant_buy_counter > 0)cant_buy_counter-=1
end

cant_buy_counter = 0
cant_buy_reason = ""
function shop(type)
	local preResources = {0,0,0,0}
	
	-- stupid lua
	for i=1,#p1resources do 
		preResources[i] = p1resources[i]
	end
	local canBuy = true

	-- check prize
	for i=1, #p1resources do
		if p1resources[i] >= towers_type[type][1][i] then 
			p1resources[i] -= towers_type[type][1][i]
		else
			canBuy = false
			cant_buy_counter = 40
			cant_buy_reason = "missing resources!"
			break
		end
	end
	
	--check location 
	if canBuy then
		for t in all(towers) do
			if type == 4 and t.type == 4 then 
				canBuy = false
				cant_buy_counter = 40
				cant_buy_reason = "only have 1 of this tower!"
				break
			elseif circ_collision(t.x, t.y, 3, p1x, p1y, 3) then
				canBuy = false
				cant_buy_counter = 40
				cant_buy_reason = "collides with tower!"
				break
			end
		end
	end
	
	if not canBuy then 
		p1resources = preResources
		shake+=0.07
		sfx(16)
	else
		init_tower(p1a, p1rad, type)
		sfx(15)
	end
end


function draw_ui()
	spr(38,0,ui_y)
	if ui_y > 0 then 
		rectfill(0,0,128,ui_y,1)
	end
	rectfill(8,ui_y,120,ui_y+6,1)
	spr(39,120,ui_y)

	for i=1,4 do 
		spr(39+i, -6 + i*24, ui_y)
		print(p1resources[i], 4 + i*24, ui_y+1, 12)
	end

	if ui_y > 1 then
		for i=0,3 do
			spr(12+i, 8 + i*10, ui_y-12)
		end

		print(":", 70, ui_y-10, 7)
		spr(238, 63, ui_y-12, 1, 2)
		spr(239 + cu_i, 2, ui_y - 22)
		print(towers_type[cu_i][2], 12, ui_y - 20, 12)

		for i=1, #towers_type[cu_i][1] do 
			print(towers_type[cu_i][1][i], 67 + i * 12, ui_y - 10, 7)
			spr(39 + i, 61 + i * 12, ui_y-11)
		end

		fillp(Å)
		rect(-3 + cu_i*10,ui_y-13,-2 + cu_i*10 + 8, ui_y-3,7)
		fillp()

		if cant_buy_counter > 0 then 
			print(cant_buy_reason, 54 - #cant_buy_reason*1.5, ui_y+10, 7)
		end
	end
	
	rectfill(0,124, 128,128, 1)
	rectfill(1, 125, health, 126, health > low_health and 3 or 8)
end

-->8
--enemies
--speed, bounce, damage, health
enemies_types = {
	{0.15, 0, 40, 1},
	{0.2, 40, 35, 1},
	{0.17, 90, 30, 2},
	{0.1, 0, 35, 1},
	{0.1, 0, 45, 3},
	{0.06, 0, 35, 1},
	{0.05, 80, 20, 1},
	{0.02, 100, 25, 2},
	{0.4, 0, 30, 1},
	{0.09, 180, 75, 5}
}

enemies={}
function init_enemy(a, rad, type)
	local m={
		x = 64 + cos(a) * rad,
		y = 64 + sin(a) * rad,
		rad = rad,
		grav = 0,
		a = a,
		type = type,
		b = 0,
		counter = 0,
		speed = enemies_types[type][1],
		bounce = enemies_types[type][2] + (enemies_types[type][2] > 0 and rnd(1) / 100 or 0),
		damage = enemies_types[type][3],
		start_health = enemies_types[type][4],
		health = enemies_types[type][4],
		hurt_c = 0,
		knockback = 0,
	}
	if m.type == 6 or m.type == 4 then 
		m.a = p1a
	end

	add(enemies, m)
end

function update_enemy(s)
	if s.rad >= p_radius then
		local slow_down_enemy = (shield_up and s.rad < 62) and 0.7 or 1
		if (s.knockback <= 0)s.rad -= s.speed * slowmo * slow_down_enemy
	else
		del(enemies, s)
		shake+=0.08
		health_t-=s.damage
		init_particle(s.x+rnd(4)-rnd(4), s.y+rnd(4)-rnd(4),s.a+rnd(1)/100,1,2+rnd(2), 8)
		if(s.damage >= 30)then sfx(24) else sfx(23) end
	end

	if s.bounce > 0 then
		local damp = s.knockback > 0 and 0.5 or 1
		s.b = sin(t) / s.bounce * damp
	end

	if abs(s.knockback) > 0.25 then 
		s.knockback = lerp(s.knockback, 0, 0.1)
		s.rad += s.knockback / 4
	else 
		s.knockback = 0
	end

	-- enemy specific abilites
	if s.type == 4 then
		s.a = lerp(s.a, p1a-0.5, 0.002)
	elseif s.type == 6 then
		s.a = lerp(s.a, p1a, 0.01)
	elseif s.type == 7 and s.rad < 64 then 
		if s.counter < 50 then 
			s.counter+=1 * slowmo
		else 
			s.counter = 0
			init_bullet(s.a + s.b, s.rad-1, 2, 2)
		end
	elseif s.type == 8 and s.rad < 64 then
		if s.counter < 160 then 
			s.counter += 1 * slowmo
		else 
			s.counter = 0
			init_bullet(s.a + s.b, s.rad - 4, 5, 3)
		end
	end

	s.x = 64 + cos(s.a + s.b) * s.rad
	s.y = 64 + sin(s.a + s.b) * s.rad

	if not p1ground and s.hurt_c <= 0 and s.health > 0 and circ_collision(p1x, p1y, 4, s.x, s.y, 3) then
		-- only towers can shoot it down
		if s.type ~= 6 then
			s.hurt_c = 24
			shake+=0.05
			s.health-=1
			if (p1rad < s.rad)s.knockback = p1jumpforce + 1
			sfx(18)
		end
		if s.type ~= 6 and s.health >= 0 then
			player_land(false)
		end
	end

	if s.hurt_c > 0 then 
		s.hurt_c-=1
	end

	if s.health <= 0 and s.knockback <= 0 then
		enemies_destroyed+=1 
		del(enemies, s)
		add_health(3)
		if cpu < 0.8 then
			for i=0,2 do
				local c = i == 0 and 8 or 12
				init_particle(p1x+rnd(4)-rnd(4), p1y+rnd(4)-rnd(4),p1a+rnd(1)/100,1,2+rnd(2), c)
			end
		end
	end
end

function draw_enemy(m)
	if sin(m.hurt_c / 10) == 0 then 
		rspr((5 + m.type) * 8, 24, 8, 8, m.a-0.25, m.x, m.y, 8, 8)
	end
end

function add_health(amount)
	health_t+=amount
	if health_t > max_health then 
		health_t = max_health
	end
end

-->8
-- towers

-- cost, description, delay until effect
towers_type = {
	{{2,2,2,2},"generates health", 180},
	{{1,2,3,3},"shoots down enemies", 120},
	{{3,3,3,2},"harvest and collects flowers", 240},
	{{7,2,3,2},"slow down enemies", -1},
}

towers={}
function init_tower(a, rad, type)
	local x = 64 + cos(a) * rad
	local y = 64 + sin(a) * rad

	if cpu < 0.6 then
		for i=0,2 do
			local c = i == 0 and 4 or 15
			init_particle(x+rnd(4)-rnd(4), y+rnd(4)-rnd(4),p1a+rnd(1)/100,1,2+rnd(2), c)
		end
	end
	if type == 4 then 
		shield_up = true
	end

	local t={
			x = x,
			y = y,
			rad = rad,
			a = a,
			type = type,
			counter = type <= 2 and towers_type[type][3] or 0,
			threshold = towers_type[type][3]
		}
		add(towers, t)
end

function update_tower(t)
	if t.rad > 26 then 
		t.rad -= 0.3 * slowmo
	end

	t.x = 64 + cos(t.a) * t.rad
	t.y = 64 + sin(t.a) * t.rad

	if t.counter < t.threshold then 
		t.counter += 1 * slowmo
	else
		t.counter = 0
		if t.type == 1 then
			add_health(3.5)
			init_effect(t.x, t.y, health, 120, 71, 3)
			sfx(17)
		elseif t.type == 2 then
			if cpu < 0.8 then 
				init_bullet(t.a, t.rad, 5, 1)
				sfx(19)
			else --delay
				t.counter = 10 + flr(rnd(30))
			end
		elseif t.type == 3 then
			init_particle(t.x+rnd(4)-rnd(4), t.y+rnd(4)-rnd(4),t.a + rnd(1)/100,1,2+rnd(2), 11)
			for s in all(seeds) do
				if s.state == 2 then 
					cut_seed(s)
				elseif s.state == 4 then 
					collect_seed(s)
				end
			end
		end
	end
end

function draw_tower(to)
	rspr(88 + 8 * to.type, 0, 8, 8, to.a - 0.25, to.x, to.y, 8, 8)
	if to.type == 3 and to.counter >= towers_type[to.type][3] - 6 then 
		fillp(Å)
		circ(64, 64, 30 - sin(t) * 0.9, 11)
		fillp()
	elseif to.type == 4 then 
		fillp(Å)
		circ(64, 64, 55 - sin(t) * 0.9, 12)
		fillp()
	end
end

bullet_colors={9, 8, 2}
bullets={}
function init_bullet(a, rad, size, type)
	local t={
		x = 64 + cos(a) * rad,
		y = 64 + sin(a) * rad,
		rad = rad,
		size = 0,
		tar_size = size,
		a = a,
		type=type,
		col = bullet_colors[type]
	}
	add(bullets, t)
end

function update_bullet(t)
	if t.size < t.tar_size then 
		t.size += 0.2
	end
	if t.type == 1 then
		if t.rad < 82 then 
			t.rad += 0.8 * slowmo
		else
			del(bullets, t)
		end

		for m in all(enemies) do 
			if circ_collision(t.x, t.y, t.size, m.x, m.y, 3) then
				del(bullets, t)
				m.health=-1
				m.hurt_c=24
				m.knockback = 8
				init_particle(m.x+rnd(4)-rnd(4), m.y+rnd(4)-rnd(4),m.a+rnd(1)/100,1,2+rnd(2), 8)
				sfx(20)
			end
		end
	elseif t.type == 2 then 
		if t.rad > p_radius then 
			t.rad -= 1.1 * slowmo
		else
			health_t -= 8
			if (cpu < 0.8)init_particle(t.x + rnd(4)-rnd(4), t.y + rnd(4)-rnd(4), t.a + rnd(1)/100, 1, 1+rnd(2), 8)
			del(bullets, t)
			sfx(21)
		end
		if not p1ground and circ_collision(t.x, t.y, t.size, p1x, p1y, 3) then
			del(bullets, t)
			init_particle(t.x+rnd(4)-rnd(4), t.y+rnd(4)-rnd(4),rnd(1), 1, 2+rnd(2), 8)
			sfx(22)
		end
	elseif t.type == 3 then
		if circ_collision(t.x, t.y, t.size, p1x, p1y, 3) then
			del(bullets, t)
			p1_slowed_counter = 90
			sfx(28)
		end

		if t.rad > p_radius then 
			t.rad -= 1 * slowmo
		else
			del(bullets, t)
			sfx(29)
		end
	end

	t.x = 64 + cos(t.a) * t.rad
	t.y = 64 + sin(t.a) * t.rad
end

function draw_bullet(b)
	fillp(Å)
	circfill(b.x, b.y, b.size, b.col)
	fillp()
end

-->8
-- start

planet_x = 32
planet_y = 64
planet_a = 0.21
planet_s = 0

planet_st = 0
planet_t = 0
planet_start = false

enemies_destroyed = 0
back_menu_delay = 0

function update_start()
	planet_x = lerp(planet_x, 32, 0.1)
	planet_y = lerp(planet_y, 64 , 0.1)
	planet_st = lerp(planet_st, planet_t, 0.1)

	planet_a -=0.001
	if not planet_start then 
		if btn(î) then 
			planet_y-=0.12
		end
		if btn(É) then 
			planet_y+=0.12
		end
		if btn(ë) then 
			planet_x+=0.12
			planet_a -=0.004
		end
		if btn(ã) then 
			planet_x-=0.12
		end

		if btnp(É) then
			planet_s = planet_s < 3 and planet_s + 1 or 0
			sfx(0)
		elseif btnp(î) then 
			planet_s = planet_s > 0 and planet_s - 1 or 3
			sfx(0)
		end
	end

	if back_menu_delay > 0 then 
		back_menu_delay-=1
	end

	if back_menu_delay <= 0 and btnp(4) then 
		planet_start = true
		planet_t = 72
		for i=0,12 do 
			init_particle(rnd(128),rnd(128),rnd(1), 2+rnd(1), 2+rnd(3), 1)
		end
		if (planet_s == 3) then sfx(1) else sfx(3) end
	end
	if planet_start and planet_s == 3 and btnp(5) then
		planet_start = false
		planet_t = 0
		sfx(2)
	end

	if planet_start and planet_s < 3 and planet_st > 71 then 
		game_state = 1
		enemies_destroyed = 0
		p1a = 0.25
		show_message_c = 30
		t = 0
		if planet_s == 0 then 
			start_tutorial()
		elseif planet_s == 1 then 
			start_arcade()
		elseif planet_s == 2 then
			start_endless()
		end
	end
end

 --print string with outline.
 function printo(str,startx,starty,col,col_bg)
     print(str,startx+1,starty,col_bg)
     print(str,startx-1,starty,col_bg)
     print(str,startx,starty+1,col_bg)
     print(str,startx,starty-1,col_bg)
     print(str,startx+1,starty-1,col_bg)
     print(str,startx-1,starty-1,col_bg)
     print(str,startx-1,starty+1,col_bg)
     print(str,startx+1,starty+1,col_bg)
     print(str,startx,starty,col)
 end
 
 --print string centered with 
 --outline.
 function printc(str,x,y,col,col_bg,special_chars)
     local len=(#str*4)+(special_chars*3)
     local startx=x-(len/2)
     local starty=y-2
     printo(str,startx,starty,col,col_bg)
 end

-->8
--tutorial,endless,arcade

--for endless, all enemies have different chances to be spawned

function enemy_picker(span)
	local dice=rnd(span)

	if dice < 15 then-- 15
		index = 1
	elseif dice >= 15 and dice < 30 then--15
		index = 2
	elseif dice >= 30 and dice < 45 then--15
		index = 3
	elseif dice >= 40 and dice < 50 then--10
		index = 4
	elseif dice >= 50 and dice < 60 then--10
		index = 5
	elseif dice >= 60 and dice < 65 then--5
		index = 6
	elseif dice >= 65 and dice < 75 then--10
		index = 7
	elseif dice >= 75 and dice < 85 then--10
		index = 8
	elseif dice >= 85 and dice < 99 then--14
		index = 9
	elseif dice >= 99 and dice < 100 then--1
		index = 10
	end

	return index
end

function enemy_count()
	local dice = flr(rnd(100))
	local v = 0
	if dice < 85 then 
		v = 1
	elseif dice < 95 then
		v = 2
	else
		v = 3
	end
	return v
end

function start_endless()
	p1resources={0,0,0,0}

	enemy_span = 15
	e_spawn_rate = 140
	e_rate = e_spawn_rate + rnd(100)
	e_counter=0

	--todo
	current_e_in_wave = 1
	wave_e_rate = 5
	wave_wait_delay = 240
	wave_counter = wave_wait_delay
	
	wave = 1

	init_tower(rnd(1), p1rad, 1)
	show_message_t = "good luck"
end

function enless_spawner()
	if wave_counter > 0 then
		wave_counter-= 1 * slowmo
	else
		if e_counter < e_rate then 
			e_counter+=1
		else 
			e_counter = 0
			local count = enemy_count()
			for i=1, count do 
				local enemy = enemy_picker(enemy_span)
				init_enemy(rnd(1), 78, enemy)
			end
			if (enemy_span < 100)enemy_span+=1

			-- lower spawn rate
			if (e_spawn_rate > 60)e_spawn_rate-=1
			e_rate = e_spawn_rate + rnd(100)

			current_e_in_wave += 1
			if current_e_in_wave > wave_e_rate then -- new wave 
				current_e_in_wave = 1
				wave_counter = wave_wait_delay
				wave+=1
				sfx(30)
			end
		end
	end
end

function draw_endless()
	if wave_counter > 0 then
		spr(72, 10, 6 + ui_y)
		print("wave " .. wave, 21 + sin(t)*1.1, 8 + ui_y, 12)
	end
end

function start_arcade()
	level = 1
	level_counter = 0
	level_wait_delay = 360
	set_level(level)
	p1resources={0,0,0,0}
	show_message_t="hello you!"
end

function set_level(level)
	level_rate = levels[level][1]
	level_enemies = #levels[level][2]
	current_enemy = 0 
	level_wait_counter = level_wait_delay
end

function arcade_spawner()
	if level_wait_counter > 0 then
		level_wait_counter -= 1 * slowmo
	else
		if level_counter < level_rate then 
			level_counter+=1
		else 
			level_counter = 0
			current_enemy+=1

			if current_enemy <= level_enemies then 
				init_enemy(rnd(1), 78, levels[level][2][current_enemy])
			else 
				-- new level
				if level < #levels then 
					level+=1
					set_level(level)
					sfx(26)
				elseif level >= #levels and #enemies <= 0 then
					arcade_won = 1
					dset(0, arcade_won)
					go_to_game_over(true)
				end 
			end
		end
	end
end

levels = {
	{120, {1,1,1,1}},
	{140, {1,2,2,1}},
	{110, {2,1,2,3}},
	{130, {3,1,2,3}},
	{80, {1,1,1,1,1,1,1,1,1}},
	{180, {4,4,4}},
	{130, {1,2,3,4,5}},
	{120, {1,6,1,6,1,6}},
	{160, {1,1,2,6,1,1,6}},
	{130, {5,2,3,2,2,2,2,7}},
	{150, {7,2,7,2,7,2,7}},
	{70, {4,2,4,2,4,2,4}},
	{80, {3,2,8,7,1,2,3}},
	{100, {7,7,8,7,7,8,7,7}},
	{90, {1,2,3,4,5,6,7,8}},
	{50, {2,2,1,2,2,2,1,2}},
	{60, {1,9,9,9,9,9,9,9,9,1,9,9,9,9,1}},
	{70, {3,4,2,3,2,4,3,2,4}},
	{80, {3,3,3,3,5,3,3,3,5}},
	{90, {6,2,2,2,6,6,2,2,2}},
	{90, {1,2,3,4,5,6,7,8,9}},
	{100, {8,7,7,7,8,2,3,2,3}},
	{60, {7,7,8,8,1,2,2,3,3,4,4,5,5,6,6,9,9,9}},
	{90, {7,7,7,10,1,2,3,10}}
}

function draw_arcade()
	if level_wait_counter > 0 then
		spr(73, 10, 6 + ui_y)
		print("level " .. level .. "/" .. #levels, 19 + sin(t)*0.6, 8 + ui_y, 12)
	end
end

--ha look at me now, even a tutorial!

function start_tutorial()
	p1resources={1,1,1,1}
	tutorial_state = 0
	next_tutorial()
	show_message_t = "welcome!"
end

function tutorial_spawner()
	if tutorial_wait > 0 then
		tutorial_wait-=1
	else
		if tutorial_state == 1 then 
			if btn(ë) then 
				tutorial_t += 1
			elseif btn(ã) then 
				tutorial_t += 1
			end
			if tutorial_t > 120 then 
				next_tutorial()
			end
		elseif tutorial_state == 2 then 
			if btn(î) and p1jumping == 0 then 
				tutorial_t+=1
			end
			if tutorial_t >= 3 then 
				next_tutorial()
			end
		elseif tutorial_state == 3 then 
			if btnp(4) then 
				tutorial_t+=1
			end
			if tutorial_t >= 4 then 
				next_tutorial()
			end
		elseif tutorial_state == 4 then 
			for s in all(seeds) do 
				if btn(É) and s.state == 3 then
					tutorial_t+=1
				end
			end
			if tutorial_t >= 2 then 
				next_tutorial()
			end
		elseif tutorial_state == 5 then 
			if #towers > 0 then 
				next_tutorial()
			end
		elseif tutorial_state == 6 then 
			if tutorial_t < 240 then 
				tutorial_t+=1
			else 
				tutorial_t = 0
				init_enemy(rnd(1), 78, 1)
			end
			if enemies_destroyed >= 2 then 
				next_tutorial()
			end
		elseif tutorial_state == 7 then 
			if tutorial_t < 360 then 
				tutorial_t+=1
			else 
				next_tutorial()
			end 
		elseif tutorial_state == 8 then 
			if tutorial_t < 360 then 
				tutorial_t+=1
			else
				sfx(25)
				go_to_menu()
			end 
		end
	end
end

function go_to_menu()
	game_over = false
	new_record = false
	health = max_health
	health_t = max_health
	vgnt.mode = "open"
	vgnt.pos = -140
	vgnt.size = 288
	heart_s = 0
	game_state = 0
	planet_start = false
	planet_t = 0
	clear_objects()
	back_menu_delay = 40
	t = 0
	sfx(34)
end

function clear_objects()
	for k,v in pairs(towers) do towers[k]=nil end
	for k,v in pairs(enemies) do enemies[k]=nil end
	for k,v in pairs(bullets) do bullets[k]=nil end
	for k,v in pairs(seeds) do seeds[k]=nil end
	for k,v in pairs(effects) do effects[k]=nil end
end

function next_tutorial()
	tutorial_wait = 50
	tutorial_state+=1
	tutorial_t = 0
	tutorial_desc, tutorial_lines = get_tutorial_description(tutorial_state)
	health_t = max_health
	if(tutorial_state > 1)sfx(4)
end

function get_tutorial_description(state)
	local tutorial_t = ""
	local tutorial_l = 0
	if state == 1 then 
		tutorial_t = "move by holding ã or ë."
		tutorial_l = 1
	elseif state == 2 then 
		tutorial_t = "jump with î.\ntry holding the button\nlong and short."
		tutorial_l = 3
	elseif state == 3 then 
		tutorial_t = "press é to throw a seed."
		tutorial_l = 1
	elseif state == 4 then 
		tutorial_t = "when bloomed, move to a\nflower and harvest with É."
		tutorial_l = 2
	elseif state == 5 then 
		tutorial_t = "hold ó and press é to buy a\ntower.select a tower with ã/ë.\nfufill the cost to buy a tower."
		tutorial_l = 3
	elseif state == 6 then
		tutorial_t = "defend the planet from enemies\nby jumping on them.\n(some enemies will need you to\nshoot them with towers)"
		tutorial_l = 4
	elseif state == 7 then
		tutorial_t = "don't let your health\n(green bar) fall to zero.\nplanting seeds also take\nhealth so be careful."
		tutorial_l = 4
	elseif state == 8 then
		tutorial_t = "great job! tutorial is finished.\nyou are now ready for either\narcade or endless. good luck!"
		tutorial_l = 3
	end

	return tutorial_t, tutorial_l
end

function draw_tutorial()
	if tutorial_wait <= 0 then 
		print(tutorial_desc, 2, 124 - tutorial_lines * 6, 12)
	end
end
__gfx__
0000000000222200000002000022220000222200002000000022220000000000000000000000000000000000000aa0000000000090000009007bbb000aaaaaa0
000000000222222000222200022222200222222000222200022222200d0000d000000000000000000000000000a7aa0000022000900000090bbbbbb099999999
007007002eee22e2022222202ee222222e22eee20222222022222ee2dd0550dd0000000000000000000000000a7aaaa000222200999009990bb33bb0d5d5d5d5
000770002ee7ee722eee22e22eee22e227ee7ee22e22eee22e22eee2dd5665dd000000000000000000000000aaaaaaaa02222220049ff9400b3223b001111110
00077000eeee88e02ee7ee720ee7ee7e0e88eeee27ee7ee2e7ee7ee0dd1551dd0000000000000000000000009aaaaaa901111110064dd460032bb23001cccc10
0070070000eeee0e0eee88e0e0ee88e0e0eeee000e88eee00e88ee0edd0110dd00000000000000000000000009aaaa9044499444066446600a99999000cddc00
0000000000d00d00e0eeee0e00d00d0000d00d00e0eeee0e00d00d000d0000d0000000000000000000000000009aa900449229440566665000a9990000cccc00
0000000000000d0000d00d0000d0000000d0000000d00d0000000d000000000000000000000000000000000000099000449229440055550000099000000dd000
00000000000000000ddddddddddd666000000000000000000cc00cc004400440011001100ff00ff00000000000000000000000000000000022222200a7aaaa00
00000000000000611555555dd555ddd66600000000000000cccddccc44499444111dd111fff77fff00cddc0000499400001dd10000f77f00200002007aaaaa00
0000000000005115555dd5d55d55555ddddd000000000000ccd22dcc4492294411d11d11ff7dd7ff0cd22dc00492294001d11d100f7dd7f020000200aaaaaa00
0000000000111111155d1555511d5d5555ddd500000000000d2cc2d0092442900d1cc1d007dffd700d2cc2d0092442900d1cc1d007dffd70200002009aaaa900
0000000005111111d5511111151515dd5555ddd0000000000d2cc2d0092442900d1cc1d007dffd700d2cc2d0092442900d1cc1d007dffd700200200009aa9000
000000001111111151111111111115dddd5555dd00000000ccd22dcc4492294411d11d11ff7dd7ff0cd22dc00492294001d11d100f7dd7f00022000000990000
0000000111111151111111111151555ddd5d555dd0000000cccddccc44499444111dd111fff77fff00cddc0000499400001dd10000f77f000000000000000000
00000051111151111111111115111555ddd5d55dd50000000cc00cc004400440011001100ff00ff0000000000000000000000000000000000000000000000000
00000111111d55111111111111115555d65d5555ddd000001111111111111111000000000000000000000000000000000022220000f4440000766600007aaa00
0000511111515111111111511111d5d5d5155d565d5d00001111111111111111000c000000040000000d0000000f0000022002200f466440076dd66007addaa0
00061111111111155511111551555555511155555dd56000111111111111111100c2c0000049400000d1d00000fdf000020000200467764006d77d600ad77da0
000511111111111111511515515d5555111115155dddd000011111111111111000ccc0000044400000ddd00000fff000020000200467764006d77d600ad77da0
0055111111111111555115511115d5551511111655dddd000111111111111110000c000000040000000d0000000f000002200220022552200551155009922990
0051111115115515d5d555555151ddd51111111555dddd00001111111111110000b3b00000b3b00000b3b00000b3b00000222200002222000055550000999900
055d11111115551555555555555dd55111151515ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000
055d11111115551555dd55555155115111111115ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000
0555111111511115555555555115111511111115dd6dddd008888880800000080000000000888800011111100c0c0cc000888800022222200085d58080000008
d55111115111151151155551155511115151111155d55dd60082280088000088008888000888888011888811c0ee220c082e2280880000880000500088222288
5515115111111151555155111555511555d1111115d5dd5600288200880dd08808ee228008e22280188e2881c8e22280088228808007c0080000800082211228
151511511111111551111151155d5555d115111151d6d51d0082280088d22d888822228808222280d8e2228d0822228c0088880000cccc000000800008255280
5555111111111111115551155555ddddd511111111ddd11d002882008812218888e22288d882288dd822228dc0822800000d500000dccd000000800000211200
5555111111111d1515515d555515ddd65511111111d5d11100822800880110888882288850888805588228850088880c0005d000800dd0080008880082222228
555d551511111d11555156ddd5d5dd6ddd5111111115d111002882008200002882088028d500005dd588885dc008800c005d5d00880000880088188088822888
d55555515d11511115555dddddd5ddddd51111155151d1150008800020000002200000020d0000d0055555500cc0c0c005d5d5d0022222200000800000888800
d55555515d11511115555dddddd5ddddd51111155151d11500000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555115111151115115dddddddddd565111111155dd550000000000300300000000000000000000000000000110000011100000000ee000000000eee00000
5d55555dd5111d5111d15555555ddddddddd5155115515550000000003333330000000000c0cc0c00000000000111100011111000000eeee0000000eeeee0000
55dd55d511155551111551d55ddddddd6dd5115d555115d1000000000333333000c000c000cccc00000000000111111011111110000eeeeee00000eeeeeee000
55d5d5d11115555511111dddd5dddddddd555d555111111500000000003333000ccc0ccc0cccccc000000000011111111111111000eeeeeeee000eeeeeeeee00
55555d11111115555151d5d555ddddddddd55d55555115150000000000033000cc0ccc0c00cccc000000000011111111111111110eeeeeeeeee0eeeeeeeeeee0
5555557d1115515111115ddddddd7dddd6ddddddd111115500000000000000000000c0000c0cc0c00000000011111111111111110eeeeeeeeeeeeeeeeeeeeee0
0555d5d5d15551511111d55ddddddd5dd6d555dd51151d5000000000000000000000000000000000000000001111111111111111eeeeeeeeeeeeeeeeeeeeeeee
0555d555155115551551d5dddd5ddddddd6d5555d115d55000000000000000000000000000000000000000001111111111111111eeeeeeeeeeeeeeeeeeeeeeee
055555551d1155dd55d56dddddd6ddddddd551ddd555d51000000000000000000000088000000000888000000111111111111110eeeeeeeeeeeeeeeeeeeeeeee
0055d5d556dd555ddd6d566ddd66ddddddd511555d15dd0000000000000000000000888800000008888800000011111111111100eeeeeeeeeeeeeeeeeeeeeeee
005d5515d55d5655ddd66d6665d5dddd6dd6dd551155510000000000000000000008888880000088888880000001111111111000eeeeeeeeeeeeeeeeeeeeeeee
000155155555dd5ddd6666dddddddd5d66ddd5555dd5d000000000000000000000888888880008888888880000001111111100000eeeeeeeeeeeeeeeeeeeeee0
00015555155d15ddddd6dd6dd6d6d66dd6d55d5ddd555000000000000000000008888888888088888888888000000111111000000eeeeeeeeeeeeeeeeeeeeee0
0000155555ddd55dd6dd6dd66556dddddddd5ddddd5100000000000000000000088888888800008888888880000000111100000000eeeeeeeeeeeeeeeeeeee00
00000155115555dddd6dd6dddd6dd5d55ddddd6dd510000000000000000000008888888888800888888888880000000110000000000eeeeeeeeeeeeeeeeee000
0000001555555ddddd66666dddddddddddddd6ddd5000000000000000000000088888888880008888888888800000000000000000000eeeeeeeeeeeeeeee0000
000000055dd55dddddd666d5555ddd5ddddddd55100000000000000000000000888888888000888888888888000000000000000000000eeeeeeeeeeeeee00000
0000000055d5d5dd6dddddddddddddddddd5d55d0000000000000000000000008888888888800888888888880000000000000000000000eeeeeeeeeeee000000
00000000056d5ddd6dddddddddddddddddd5d51000000000000000000000000088888888888000888888888800000000000000000000000eeeeeeeeee0000000
00000000001dd5dddddddddddddddddd555d5100000000000000000000000000088888888800888888888880000000000000000000000000eeeeeeee00000000
0000000000001dddddddddddd5dddd55555100000000000000000000000000000888888880008888888888800000000000000000000000000eeeeee000000000
000000000000001ddddddddddd5565d51100000000000000000000000000000000888888888008888888880000000000000000000000000000eeee0000000000
00000000000000000dd6d5d55dd5551000000000000000000000000000000000000888888880008888888000000000000000000000000000000ee00000000000
000000000000000000000000000001111111100000000000000000000000000000008888880088888888000000eeee00000cc000000000000000000000000000
00000000000000000000000011131111111111111000000000000000000000000000088888008888888000000eeeeee000c22c00070660500000000000000000
0000000000000000000000113333333333111311111100000000000000000000000000888880088888000000eeeeeeee0c2cc2c00f6d6d500000000000000000
0000000000000000000111333333333333333111111111000000000000000000000000088880008880000000e2eeee2e0c2cc2c007d6d5100000000000000000
0000000000000000011133366666666333333333131111110000000000000000000000008880088800000000eee22eee00c22c000f6d61500000000000000000
0000000000000001113333666666666666663333333311111100000000000000000000000800088000000000e288882e000cc000076445100000000000000000
0000000000000011336666366666666666633333333311111110000000000000000000000080880000000000ee2222ee0000bb000f4442500000000000000000
0000000000001336363666666366363676666666113333111111100000000000000000000000000000000000eeeeeeee0000b000074442100000000000000000
00000000000116666666666666661366676666363313331111111100000000000000000000000000000000000000000000000000000000000ff00ff000000000
0000000000136636767666666666636666666111111133311111111000000000000000000000000000000000000000000000000000000000fff77fff00000000
0000000001366636666677666663666366666613333111311111111100000000000000000000000000000000000000000000000000000000ff7dd7ff00000000
000000001666636666366667776677663666663131131333311111111000000000000000000000000000000000000000000000000000000007dffd7000000000
000000013666663663336776767376633336363633313363333111111100000000000000000000000000000000000000000000000000000007dffd7000000000
00000003666666663667767663376367633113313333333333111111110000000bbbbbbbbb00000bbbbb00bbbbb0bbbbbbbbbbbbbbbb0000ff7dd7ff00000000
0000001361667633767766776336777777373136113333336311111111100000b33333b33b0000bb333bb0b333bbb33b33333b333333b0004ff77ff400000000
0000013331763666777773776366777777313331313333133111111111110000b33333b33b0000b33333b0b3333bb33b33333b333333b0000440b44000000000
0000013336663373777666376777777717311333666633333111111111110000b33bbbb33b0000b33b33b0b3333bb33b33bbbbbb33bbb0000000b00000000000
00001133633113667663163d6677777311133331666333311111111111111000b33bbbb33b000bb33b33bbb33333b33b33333b0b33b000000000b00000000000
0000133611131366766336136667766333113333366361331111113111111000b33333b33b000b333b333bb33333333b33333b0b33b00000000bb00000000000
0001137311113617766663776377636333716333777336333111111111111100b33333b33b000b3333333bb33b33333b33bbbb0b33b000b000bb000000000000
0001313111136667777636773666676333733716667633311111111111111100b33bbbb33bbbbb3333333bb33bb3333b33bbbb0b33b0bbbb0bb0000000000000
00131133316377336d76767777dd336633731377363336111111111311111110b33b00b33333b333bbb333b33bbb333b33333b0b33bbb0bbb000000000000000
0013311316136771776677777636333333333336331133331116113111111110b33b00b33333b333b0b333b33b0b333b33333b0b33b0b0000000000000000000
0013111366166777367776766663336633333336661677311116113111111110bbbb00bbbbbbbbbbb0bbbbbbbb0bbbbbbbbbbb0bbbb000000000000000000000
0133336361377776366673136667366663333313337777766311166111111111eee000e000eee000eeee000ee0000ee000888800088800888088888088888000
0131333333667777777761316666363633333333377777776666361111111111eee00eee00eee00eeeeee00eee000ee008888880088800888088888088888800
01313663636777776666313666667333636331636767777773661131111111110ee0eeeee0ee00eee77eee0eeee00ee088877888008800880088000088008800
033136336366737667763163667666363333336677d7776613133111111111110ee0eeeee0ee00ee7227ee0eeeee0ee088722788008800880088888088888800
03316333666677677776136377636663663366677776661666361111111111110eeeee0ee0ee00ee7227ee0ee0eeeee088722788000888800088000088888000
1333331366767763d767667d376666666666766776363177763311111111111100eeee0eeee000eee77eee0ee00eeee088877888000888800088000088088000
1311133633777677667766777dddd7666666333776663111311111111111111100eee000eee0000eeeeee00ee000eee008888880000888800088888088088800
1333113133367777777773777d77767676333367d3113111111111111111111100eee000eee00000eeee000ee0000ee000888800000088000088888088088800
1373133313166766677667733d3d6376663633165111331111111111111111110077777000007770000777700777700777770000000000000000000000000000
1673311316333777d77677d667d33336636661111111131111111111111111110777777000077777000777700777700777770000000000000000000000000000
136311313633337d7766776736667366766611111111111511111111111111117770007000077077000777700777700770000000000000000000000000000000
033313313111177d763637ddd6666636763611111111111111111117311111117700000000077077000777700777700777770000000000000000000000000000
06736333113137663133667676666336763311111111331331163663311111117707777700777777700770777707700770000000000000000000000000000000
03766331161316331113366676666633377611111371111111111366331111117770007700777777700770777707700770000000000000000000000000000000
01377666331311167113176666666333333611116631111111113136311111110777777707770007770770777707700777770000000000000000000000000000
01367d63313331111111116676666333333311116dd7611111111116311111110077777007770007770770077007700777770000000000000000000000000000
00337d73313131311111131376336331113377737d3673111111136361131110cccccc0cc000cc0cccccc000cccc000ccccc00cc0000ccc0000cc00000000000
00336676773111131111631333333311111336137767b6611113663311313110cccccc0cc000cc0cccccc00cccccc00cccccc0cc000ccccc000cc00000000000
001361661161317376636b3113133611111133113337d111116666661333111000cc000cc000cc000cc000ccc00ccc0cc00cc0cc000cc0cc000cc00000000000
001633361113631633711176113111366111111111167666666666633333111000cc000cc000cc000cc000cc0000cc0cc00cc0cc000cc0cc000cc00000000000
000133336333161663611166311111111111113113116761663766633311110000cc000cc000cc000cc000cc0000cc0ccccc00cc00ccccccc00cc00000000000
000163331611113377763361111111617113111317113111336667636311110000cc000cc000cc000cc000ccc00ccc0cc0cc00cc00ccccccc00cc00000000000
00003613363131136637771b336711111763111111111133333666666111100000cc0000ccccc0000cc0000cccccc00cc0ccc0cc0ccc000ccc0ccccc00000000
000016333313161316366366d73361716776111731676163766766666111100000cc0000ccccc0000cc00000cccc000cc0ccc0cc0ccc000ccc0ccccc00000000
0000037331333331113167611111666667776766666666666676666611110000000ccc0000ccccc0000ccccc0000ccc0000ccccc000cccccc000000000000000
000001363333311333111111317333177611667336633736767766611110000000ccccc000cccccc00cccccc000ccccc000cccccc00cccccc000000000000000
000000163313113633331166666137667176111116111377736611111110000000cc0cc000cc00cc0ccc000c000cc0cc000cc00ccc0ccc000000000000000000
000000037333311311761716631116333176663666777677663313111100000000cc0cc000cc00cc0cc00000000cc0cc000cc000cc0cccccc000000000000000
00000000373731131633331616161316666633376376637766331311100000000ccccccc00ccccc00cc0000000ccccccc00cc000cc0ccc000000000000000000
00000000137613333313113116611131633363677777673666333311100000000ccccccc00cc0cc00ccc000c00ccccccc00cc00ccc0ccc000000000000000000
0000000001373333361133111133331673363677677777663333331100000000ccc000ccc0cc0ccc00cccccc0ccc000ccc0cccccc00cccccc000000000000000
0000000000137333337333163111333667767666677777663666311000000000ccc000ccc0cc0ccc000ccccc0ccc000ccc0ccccc000cccccc000000000000000
0000000000013761363363336663366377666376766666666636100000000000ccccc0ccc000cc0ccccc000cc0000ccccc00ccccc00ccccc0000700000000000
0000000000000377663333336663667777776636676666666631000000000000ccccc0cccc00cc0cccccc00cc0000ccccc0cccccc0cccccc0007700000000000
0000000000000013776333333336677663677763666666666110000000000000cc0000cccc00cc0cc00ccc0cc0000cc0000cc000c0cc000c0070070000000000
0000000000000001167663366666666666663336666663111100000000000000ccccc0ccccc0cc0cc000cc0cc0000ccccc0ccc0000ccc0000070000000000000
0000000000000000011636333633613333333676666631310000000000000000cc0000cc0ccccc0cc000cc0cc0000cc0000000ccc0000ccc0007700000000000
0000000000000000000116333336733333333336366311000000000000000000cc0000cc00cccc0cc00ccc0cc0000cc0000c000cc0c000cc0000070000000000
0000000000000000000000116666667663333333611000000000000000000000ccccc0cc000ccc0cccccc00ccccc0ccccc0cccccc0cccccc0070070000000000
0000000000000000000000000111366666663111000000000000000000000000ccccc0cc000ccc0ccccc000ccccc0ccccc0ccccc00ccccc00007700000000000
0000000000000000000000000000000000000000000000000000000000000000000ccc0000ccccc0000cccc000cc000cc00cccccc00000000000700000000000
00000000000cc0000cc00cc0000cc0000000000000000000000000000000000000ccccc000cccccc00cccccc00cc000cc00cccccc00000000000000000000000
00c00c0000cccc000cccccc000c00c000000000000000000000000000000000000cc0cc000cc00cc0ccc00ccc0cc000cc0000cc0000000000000000000000000
0cccccc00cccccc000cccc000c0000c00000000000000000000000000000000000cc0cc000ccccc00cc0000cc0cc000cc0000cc0000000000000000000000000
0cccccc00cccccc000cccc000c0000c0000000000000000000000000000000000ccccccc00cc00cc0cc0000cc0cc000cc0000cc0000000000000000000000000
00cccc0000cccc000cccccc000c00c00000000000000000000000000000000000ccccccc00cc00cc0ccc00ccc0cc000cc0000cc0000000000000000000000000
000cc000000cc0000cc00cc0000cc00000000000000000000000000000000000ccc000ccc0cccccc00cccccc000ccccc00000cc0000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ccc000ccc0ccccc0000cccc0000ccccc00000cc0000000000000000000000000
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
00020000240400d030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000007050100500b0000000000000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000a05013050130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000003025030250502507025070250a02500005000051d04522045000050000524045290450000500005000051a0050000500005000050000500005000050000500005000050000500005000050000500005
000800001104418054000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
0004000006c6111c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c01
000300000603210042000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000400000594013950189600090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900
000100001452000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100000f52000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200000752000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200000202001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000065250e555005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
00080000040140b034130040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000800000a03405024130040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000f00000302518035220452405500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000f00000302518035130450c03500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00020000045250f525005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000100001a0420a032000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000300000101107521061310b50108501055010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
000400000601318123001031d04308503055030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000100000501002030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000354005530005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000010210c651085410060106601027012570100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
00040000050210c651040410565101051000512570107421006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
001000000f04516035110250c03511045160551b0551f05522055270552e0553005535055000053a045050052e0353a02525005290051f005160050f0050d0050a0052e0052b0052700522005270052b00533005
000c00000a024110341604416044160441b04422044220441b0440c0441b0341d03401004010041f5442d75408704090041d0041d0041f0041f0041f0041f0040000400004000040000400004000040000400004
000500000b73400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704
000200000953704517065270255702557005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
000200000403702037065270252700517005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
00050000000520a552000520f5520005213552000521b5521f552000222b5520a00205002000021d5021d50200502005020050200502005020050200502005020050200502005020050200502005020050200502
0005000003021076310a6410f651166511d6512265101051010210003115051170511905100641000010000112031100510d0510b0510904108041050310202100011280011d00123001000010b0011d75116731
0005000003021076310a6410f641166411d64122641010510102100031150511705119051006410000100001077110a7110a7110c7110c7110c7110f7210f721117211373113731167311b7411f7512475137051
010c0000020550305505055060550c0550c0050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00060000070550c05513055190051f05500005000052b055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
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
