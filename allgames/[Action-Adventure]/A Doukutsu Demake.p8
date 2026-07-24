pico-8 cartridge // http://www.pico-8.com
version 5
__lua__
-- a doukutsu demake
-- by andrew + timothy miller

objects = {}
message = ''
cam = {x=0,y=0,dir=1,accel=0}
lvl_cam = {x=0,y=0}
char = {x=0,y=0}
weapon = {
	exp = 0,
	lvl = 1
}
crossfade={max=24}
music_on=true
pause_player=false
player_death=nil
text_object={}
t = 0
cartdata('doubt_douk')

collision_types = {
	l45  = {0,1,2,2,3,4,6,7},
	r45  = {6,5,4,4,2,2,1,0},
	r30b = {7,7,6,6,5,5,4,4},
	r30t = {3,3,2,2,1,1,0,0},
	l30b = {4,4,5,5,6,6,7,7},
	l30t = {0,0,1,1,2,2,3,3}
}

angle_tiles = {
	_65 = 'r30b',
	_66 = 'r30t',
	_67 = 'l30t',
	_68 = 'l30b',
	_69 = 'r45',
	_70 = 'l45',
	_97 = 'r30b',
	_98 = 'r30t',
	_99 = 'l30t',
	_100 = 'l30b'
}

scene = {
	active_door = nil,
	name_delay = 60,
	update = function()
		if (crossfade.max_t) then
			local dt = t - crossfade.max_t
			if crossfade.max - flr(dt / 2) > 0 then
				crossfade.size = crossfade.max - flr(dt / 2)
			else
				crossfade.max_t = nil
				crossfade.size = nil
			end
		end

		if (scene.name_t) then
			message = scene.name
			if (scene.name_t + scene.name_delay < t) then
				scene.name_t = nil
				message = nil
			end
		end
	end,
	one = {
		draw = function()
			camera(0,0)

			map(0,0,0,0,128,128)

			-- draw objects
			foreach(objects, function(o)
				draw_object(o)
			end)

			map(0,0,0,0,128,128,2)
		end,
		update = function()
			if (rnd(1) < 0.03) init_object(water_drops,41,48)

			if (rnd(1) < 0.03) init_object(water_drops,73,48)
		end,
		init = function()
			scene.name = "start point"
			scene.name_t = t
			objects = {}
			lvl_cam = {x=0,y=0}

			init_object(door,7*8,3*8)
			init_object(save_disk,12*8,7*8)
			init_object(health_station,11*8,7*8)
			
			if (scene.active_door) then
				init_object(player, 7*8, 3*8)
			else
				init_object(player, 64, 64)
			end

			pause_player = false
		end
	},
	two = {
		draw = function()
			physics_cam()

			map(20,2,-232,-40,96-31,46)
			scene.coords = {20,2,-232,-40,96-31,46}

			foreach(objects, function(o)
				draw_object(o)
			end)
		end,

		update = function()
			if (rnd(1) < 0.03) then
				local drops = {
					{52, 31},
					{47, 32},
					{59, 36},
					{62, 37}
				}
				for i=1,count(drops) do
					local co = get_lvl_coords(drops[i][1]*8, drops[i][2]*8)
					if (co) init_object(water_drops,co.x,co.y)
				end
			end
		end,

		init = function()
			scene.name = "first cave"
			scene.name_t = t
			objects = {}
			-- lvl cam is the tilemap offset. hacky, but functional
			lvl_cam = {x=392,y=56} -- 20*8+232  2*8+40

			local d1_pos = get_lvl_coords(56*8,10*8)
			local d2_pos = get_lvl_coords(72*8,35*8)
			local d3_pos = get_lvl_coords(74*8,8*8)

			init_object(door,d1_pos.x,d1_pos.y)
			init_object(door,d2_pos.x,d2_pos.y)

			init_object(evil_door,d3_pos.x,d3_pos.y)

			local hc = get_lvl_coords(24*8,23*8)
			init_object(heart_cont,hc.x,hc.y)

			local twobats = {
				{33,19},
				{28,22},
				{33,27},
				{43,31},
				{44,32},
				{53,33}
			}
			local twocritters = {
				{65,10},
				{52,39},
				{73,10},
				{72,10},
				{70,11}
			}

			for i=1,count(twobats) do
				local b = get_lvl_coords(twobats[i][1]*8, twobats[i][2]*8)
				init_object(bat, b.x, b.y)
			end

			for i=1,count(twocritters) do
				local c = get_lvl_coords(twocritters[i][1]*8,twocritters[i][2]*8)
				init_object(critter, c.x, c.y)
			end

			--init_object(player, 58, 24) -- 56, 10
			local ad = d1_pos
			if (scene.active_door == '_620') ad = d2_pos
			init_object(player,ad.x, ad.y)
			cam.x = ad.x-32
			cam.y = ad.y-32

			pause_player = false
		end
	},

	three = {
		draw = function()
			camera(0,0)

			map(1,12,0,0,128,128)

			-- draw objects
			foreach(objects, function(o)
				draw_object(o)
			end)

			map(1,12,0,0,128,128,2)
		end,
		update = function()

		end,
		init = function()
			scene.name = "hermit gunsmith"
			scene.name_t = t
			objects = {}
			lvl_cam = {x=8,y=96} -- 1*8, 12*8
			local d1_pos = get_lvl_coords(6*8,20*8)
			init_object(door,d1_pos.x,d1_pos.y)

			local snore_pos = get_lvl_coords(10*8,19*8)
			init_object(snore,snore_pos.x,snore_pos.y)

			local cpos = get_lvl_coords(13*8,20*8)
			init_object(chest,cpos.x,cpos.y)

			init_object(player, 5*8, 8*8)
			pause_player = false
		end
	}
}

function draw_circles(size)
	local maxsize = 8
	
	for x=1,(128 / maxsize) do
		--xsize = size * (x+16) / 16 - 16
		xsize = size
		for y=1,(128 / maxsize) do
			ysize = size * (y + 4) / 8 - 4
			circfill(x * maxsize - (maxsize / 2), y *  maxsize - (maxsize / 2), min(xsize, ysize), 0)
		end
	end
end

current_scene = {
	draw = scene.one.draw,
	update = scene.one.update,
	init = scene.one.init
}

function physics_cam()
	local moving = false

	if (btn(0) or btn(1)) then
		moving = true
		cam.dir = btn(1) and 1 or btn(0) and -1
	end

	if (moving and cam.accel < 2) cam.accel += 0.2
	if (not moving and cam.accel > 0.5) cam.accel -= 0.2

	if (cam.y + 94 < char.y) cam.y = char.y - 94
	if (cam.y + 32 > char.y) cam.y = char.y - 32
	if (cam.y + 64 > char.y) cam.y -= 0.5
	if (cam.y + 64 < char.y) cam.y += 0.5

	local offset = 88
	if (cam.dir == 1) offset = 32

	if (char.x > cam.x + offset) cam.x += cam.accel
	if (char.x < cam.x + offset) cam.x -= cam.accel

	if (scene.coords) then
		local xmax = scene.coords[5]*8 - lvl_cam.x + 32
		local ymax = scene.coords[6]*8 - lvl_cam.y + 32
		if (cam.x < scene.coords[3] + 16) cam.x = scene.coords[3] + 16
		if (cam.y < scene.coords[4]) cam.y = scene.coords[4]
		if (cam.x > xmax) cam.x = xmax
		if (cam.y > ymax) cam.y = ymax
	end

	camera(cam.x,cam.y)
end


player={
	init=function(this) 
		this.p_dash=false
		this.jbuffer=0
		this.grace=0
		this.hitbox = {x=2,y=2,w=4,h=6}
		this.health = 3
		this.maxhealth = 3
		this.polar = {
			lvl=1,
			exp=0,
			speed = 4.5,
			needed_exp={10,20,10},
			life = {5,12,18},
			sprs = {
				{24,25},
				{74,77},
				{122,125}
			}
		}
		this.spr_off=0
		this.was_on_ground=false
		this.maxjump = 4
		this.air = 100
		this.hithead = function(_)
			init_object(sparks,_.x,_.y)
			init_object(sparks,_.x-3,_.y)
			sfx(63,3)
		end
	end,
	update=function(this)
		if (pause_player) return
		
		local input = btn(1) and 1 or (btn(0) and -1 or 0)

		local on_ground=this.is_colliding(0,1)
		local in_water=this.in_water(0,0)
		local in_danger=(this.in_danger(0,0) or this.check_damage()) and not this.invincible

		if not in_water then
			air = 100
			message = ''
		else
			air -= 0.2
			message = 'air '..flr(air)

			if (air < 1) then
				this.spr = 34
				this.drowned = true
				kill_player(this, true)
			end
		end

		if (in_danger) then
			this.health -= 1
			this.invincible = 50
			pain_text('-1', this.x, this.y)
			sfx(63)

			if (this.health < 1) kill_player(this)
		end

		if (this.invincible and this.invincible > 0) then
			this.invincible -= 1
		else
			this.invincible = false
		end

		local jump = btnp(4)
		if (jump) then
			this.jbuffer=4
		elseif this.jbuffer>0 then
			this.jbuffer-=1
		end

		if (on_ground and not this.was_on_ground) sfx(62,3)

		if on_ground then
			this.grace=6
		elseif this.grace > 0 then
			this.grace-=1
		end

		-- move
		local maxrun=0.7
		local accel=0.3
		local deccel=0.1
		
		if not on_ground then
			accel=0.2
		end

		if in_water then
			maxrun=0.3
		end
	
		if abs(this.spd.x) > maxrun then
	 		this.spd.x=appr(this.spd.x,sign(this.spd.x)*maxrun,deccel)
		else
			this.spd.x=appr(this.spd.x,input*maxrun,accel)
		end
			
		--facing
		if this.spd.x!=0 then
			this.flip.x=(this.spd.x<0)
		end

		-- gravity
		local maxfall=1
		local gravity=0.08

		if abs(this.spd.y) <= 0.15 then
 			gravity*=0.5
		end
		if in_water then
			gravity*=0.5
		end

		if not on_ground then
			-- variable jump height
			if (btn(4)) then this.spd.y=appr(this.spd.y,maxfall,gravity)
			else this.spd.y=appr(this.spd.y,maxfall,gravity*2) end
		end

		-- jump
		if this.jbuffer>0 and this.grace>0 then
	  		this.jbuffer=0
	  		this.grace=0
	  		if not in_water then
				this.spd.y=-1.5
			else
				this.spd.y=-0.7
			end
		end

		if (in_danger) then
			this.jbuffer=0
			this.grace=0
			this.spd.y=-1.7
		end
		
		-- animation
		this.spr_off+=0.25
		if not on_ground then
			local air_addition = btn(2) and 16 or 0
			if this.is_colliding(input,0) then
				this.spr=5 + air_addition
			else
				this.spr=3 + air_addition
			end
		elseif btn(3) then -- down
			this.spr=36
			local d = this.interact()

			if d then
				d.type.interact(d)
				pause_player = true
			end
		elseif btn(2) then --up
			this.spr=17
		elseif (this.spd.x==0) or (not btn(0) and not btn(1)) then
			this.spr=1
		else
			this.spr=1+this.spr_off%4
		end

		if (btnp(5) and char.weapon) this.type.fire(this)

		if (char.health_increase) then
			this.health += char.health_increase
			this.maxhealth += char.health_increase
			char.health_increase = 0
		end

		if (this.collide(exp_triangle)) then
			weapon.exp += 1
			if (weapon.exp == this.polar.needed_exp[weapon.lvl]
				 and weapon.lvl < count(this.polar.needed_exp)) then
				weapon.lvl += 1
				weapon.exp = 0
			end
		end
		if (this.collide(health_heart)) then
			this.health = min(this.maxhealth, this.health + 2)
		end
		weapon.maxexp = this.polar.needed_exp[weapon.lvl]
		
		-- was on the ground
		this.was_on_ground=on_ground
		char.x = this.x
		char.y = this.y
		char.health = this.health
		char.maxhealth = this.maxhealth
		
	end, --<end update loop

	fire=function(this)
		local up = btn(2) and 1 or 0
		local po = this.polar

		weapon.spr = po.sprs[weapon.lvl][1+up]
		weapon.speed = po.speed
		weapon.life = po.life[weapon.lvl]
		weapon.dir = this.flip.x and -1 or 1
		weapon.dir_y = up
		
		init_object(polar_shot,this.x,this.y)
	end,
	
	draw=function(this)
		if (char.weapon) then
			if (this.spr>16 and this.spr<22) then --up
				spr(23,this.x,this.y-1,1,1,this.flip.x,this.flip.y)
			else
				spr(22,this.x,this.y,1,1,this.flip.x,this.flip.y)
			end
		end
		if (not this.invincible or this.invincible % 3 == 0) then
			spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)
		end
		if (this.drowned) spr(34,this.x,this.y,1,1,this.flip.x,this.flip.y)
	end
}

function kill_player(this, drowned)
	message = 'you died.'
	music(-1)
	if (drowned) then
		pause_player = true
	else
		create_smoke(this.x,this.y)
		create_smoke(this.x+4,this.y-4)
		create_smoke(this.x-4,this.y-4)
		destroy_object(this)
	end
	sfx(63)
	sfx(60)
	player_death=t
end

function draw_player_ui()
	local start = 4
	local bar_start = 16

	print('/',start+20,start+2,7)
	print('--',start+34,start,7)
	print('--',start+34,start+4,7)

	local exp_width = (weapon.exp / weapon.maxexp) * (25 / weapon.maxexp) * weapon.maxexp
	print('lv '..weapon.lvl, start+1, start+9, 5)
	print('lv '..weapon.lvl, start, start+8, 7)
	rectfill(start+bar_start,start+8,start+41,start+13,5) -- shadow
	rectfill(start+bar_start,start+8,start+40,start+12,7) -- white border
	rectfill(start+bar_start,start+9,start+40,start+11,2) -- dark purple
	rectfill(start+bar_start,start+9,start+bar_start+exp_width,start+11,4) -- brown experience

	local health_width = (char.health / char.maxhealth) * (25 / char.maxhealth) * char.maxhealth
	print(char.health, start+12, start+14, 7)
	rectfill(start+bar_start,start+14,start+41,start+19,5) -- shadow
	rectfill(start+bar_start,start+14,start+40,start+18,7) -- white border
	rectfill(start+bar_start,start+15,start+bar_start + 24,start+17,2) -- dark pink
	rectfill(start+bar_start,start+15,start+bar_start + flr(health_width),start+17,8) -- pink bar
end

function print_text()
	-- this needs to do lots of extra animation things, but it'll do for now
	rectfill(8,88,120,120,6)
	rectfill(9,89,119,119,1)
	print(text_object[1], 12, 94, 7)
	if (text_object[2]) print(text_object[2], 12, 108, 7)
end

polar_shot={
	init=function(this)
		this.speed = weapon.speed
		this.dir = weapon.dir
		this.dir_y = weapon.dir_y
		this.spr = weapon.spr
		this.start_t = t
		this.life = weapon.life
		this.hurt = 1
		this.finisher = {57,58,59}
		this.hitbox = { x=2,y=5,w=6,h=1 }
		sfx(36)
		if (this.dir_y > 0) then
			this.hitbox = { x=5,y=0,w=1,h=6 }
			this.x -= 3
			this.y -= 5
		end
		this.zaps = {
			{
				x=this.x+4*this.dir,
				y=this.y+2,
				step=9
			},
			{
				x=this.x,
				y=this.y,
				step=9
			}
		}
	end,
	update=function(this)
		local st = t - this.start_t

		local collide = this.collide(bat) or this.collide(critter) or this.collide(evil_door)
		if (collide and not this.collide_cool) then
			this.collide_cool = 10
			collide.type.hurt(collide)
			pain_text('-'..this.hurt, this.x, this.y)
		end
		local cc = this.collide_cool
		if (cc and cc > 0) this.collide_cool -= 1
		if (cc and cc < 1) this.collide_cool = nil

		if (st < 8) then
			this.zaps[1].spr = this.finisher[flr(st/1.5)]
			this.zaps[1].step = flr(st/1.5)
		end

		if (not this.done and this.dir_y < 1) this.x += this.dir * this.speed
		if (not this.done and this.dir_y > 0) then
			-- still need to be able to shoot down
			this.y -= this.speed
		end

		if (st > this.life) then
			this.type.destroy_shot(this)
		end
		if (this.is_colliding(0,0)) then
			local destructable = check_destructable(this.x+this.hitbox.x,this.y+this.hitbox.y,this.hitbox.w,this.hitbox.h)
			if count(destructable) > 0 then
				mset(destructable[1].x, destructable[1].y, 0)
				local sc = get_lvl_coords(destructable[1].x*8, destructable[1].y*8)
				create_smoke(sc.x,sc.y)
			end
			this.type.destroy_shot(this)
			this.final_finish = {196,197,198,199}
		end

		if (this.done and not this.end_time) then
			this.end_time = st
			this.zaps[2].x = this.x
			this.zaps[2].y = this.y+2
		end

		if (this.end_time and this.end_time + 8 > st) then
			local et = st - this.end_time
			local finish = this.final_finish or this.finisher
			this.zaps[2].spr = finish[flr(et/1.5)]
			this.zaps[2].step = flr(et/1.5)
		elseif (this.end_time and this.end_time + 8 < st) then
			sfx(37)
			destroy_object(this)
		end
	end,
	destroy_shot=function(this)
		this.done = true
	end,
	draw=function(this)
		if (not this.done) spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)
		if (this.zaps) then
			local z1 = this.zaps[1]
			local z2 = this.zaps[2]
			if (z1.step < 4) spr(z1.spr,z1.x,z1.y)
			if (z2.step < 4) spr(z2.spr,z2.x,z2.y)
		end
	end
}

sparks={
	init=function(this)
		this.spr=8
		this.spd.y=-0.1+rnd(0.3)
		this.spd.x=0.3+rnd(0.2)
		this.x+=-1+rnd(2)
		this.y+=-1+rnd(2)
		this.solids=false
		this.t = 0
	end,
	update=function(this)
		this.t += 1
		if this.t > 10 then
			destroy_object(this)
		end
	end
}
red_sparks={
	init=function(this)
		this.spr=62
		this.spd.x=-2+rnd(4)
		this.spd.y=-2+rnd(4)
		this.x+=-1+rnd(2)
		this.y+=-1+rnd(2)
		this.solids=false
		this.t = 0
	end,
	update=function(this)
		this.t += 1
		if (this.t > 3) this.spr = 61
		if (this.t > 8) this.spr = 60
		if this.t > 10 then
			destroy_object(this)
		end
	end
}
smoke={
	init=function(this)
		this.spr = 38
		this.anim = {38,39,40,53,54,55,56}
		this.ai = 1
		this.start_t = t
		this.spd.y=-0.1+rnd(0.3)
		this.spd.x=0.3+rnd(0.2)
		this.x+=rnd(1.5)
		this.y+=rnd(1.5)
	end,
	update=function(this)
		local ht = t - this.start_t + 1

		if (ht < 8) then
			this.spr = this.anim[ht]
		else
			destroy_object(this)
		end
	end
}

function create_smoke(ox,oy)
	init_object(smoke,ox,oy)
	init_object(smoke,ox,oy)
	init_object(smoke,ox,oy)
end

function pain_text(message,x,y,color)
	local obj={}
	obj.message = message
	obj.x = x
	obj.y = y
	obj.delay = 10
	obj.start_t = t
	obj.color = color or 8
	obj.spd = {x=0,y=0}
	obj.type = {}

	obj.type.update=function(this)
		if (t - obj.start_t > obj.delay) then
			del(objects, obj)
		end
	end

	obj.move = function() end

	obj.type.draw=function(this)
		print(obj.message,obj.x,obj.y,this.color)
	end

	add(objects,obj)
	return obj
end

water_drops={
	init=function(this)
		this.size = 1
		this.accel = 0
		this.gravity = 1.2
		this.hitbox.w = 2
		this.hitbox.h = 2
		this.x += flr(rnd(6))
	end,
	update=function(this)
		this.y += min(this.gravity, this.accel)
		this.accel += 0.1

		if this.size < 3 and maybe() then
			this.size += 1
		end
		if this.size > 0 and maybe() then
			this.size -= 1
		end

		if this.is_colliding(0,0) or this.in_water(0,0) then
			destroy_object(this)
		end
	end,
	draw=function(this)
		pset(this.x,this.y,1)
		if (this.size > 1) then
			pset(this.x,this.y,12)
		end
		if this.size > 2 then
			pset(this.x,this.y,7)
		end
	end
}

bat={
	tile = 47,
	init=function(this)
		this.start_t = t
		this.start_y = this.y
		this.range = 4*8
		this.dir_y = 1
		this.accel = 0.2
		this.rndspeed = rnd()*0.15
		this.damage = 1
	end,
	hurt=function(this)
		create_smoke(this.x,this.y)
		destroy_object(this)
		local drop = exp_triangle
		if (rnd(1) < 0.15) drop = health_heart
		init_object(drop,this.x,this.y)
		-- todo: show how much it hurt (same with all hurts)
	end,
	update=function(this)
		--animation
		local ht = t - this.start_t
		if ht % 4 > 2 then
			this.spr = 47
		else
			this.spr = 63
		end

		-- acceleration control
		if (this.dir_y < 0 and this.y - 12 < this.start_y and this.accel > .2) this.accel -= .04
		if (this.dir_y > 0 and this.y - 12 < this.start_y and this.accel < 1) this.accel += .04
		if (this.dir_y > 0 and this.y + 12 > this.start_y + this.range and this.accel > .2) this.accel -= .04
		if (this.dir_y < 0 and this.y + 12 > this.start_y + this.range and this.accel < 1) this.accel += .04
		
		-- direction control
		if (this.y > this.start_y + this.range) this.dir_y = -1
		if (this.y < this.start_y) this.dir_y = 1

		this.y += this.dir_y * this.accel + this.rndspeed
	end
}

critter={
	tile = 50,
	init=function(this)
		this.start_t = t
		this.damage = 1
		this.jbuffer=0
		this.grace=0
		this.health = 2
		this.maxjump = 4
	end,
	hurt=function(this)
		if (not this.invincible and this.health > 1) then
			this.invincible = 0
			sfx(39)
			init_object(red_sparks,this.x,this.y)
			init_object(red_sparks,this.x,this.y)
			init_object(red_sparks,this.x,this.y)
			this.health -= 1
		elseif (this.health == 1) then
			create_smoke(this.x, this.y)
			destroy_object(this)
			local drop = exp_triangle
			if (rnd(1) < 0.15) drop = health_heart
			init_object(drop,this.x,this.y)
		end
	end,
	update=function(this)
		local on_ground=this.is_colliding(0,1)

		if (this.invincible and this.invincible < 10) this.invincible += 1
		if (this.invincible and this.invincible > 9) this.invincible = nil

		this.spr = 50
		if char.x > this.x - 56 and char.x < this.x + 56 then
			this.spr = 51
			if (not on_ground and this.spd.y < 0) this.spr = 52
			if (not on_ground and this.spd.y > 0) this.spr = 50
		end

		if on_ground 
			and char.x > this.x - 28 
			and char.x < this.x + 28 
			and char.y < this.y + 28
			and char.y > this.y - 28 then
			this.spd.y=-1.4
			this.spd.x=-0.2*(this.flip.x and -1 or 1)
			this.spr = 50
			sfx(61)
		end

		this.flip.x = (char.x > this.x)

		local maxrun=0.7
		local accel=0
		local deccel=0.1
		
		if not on_ground then
			accel=0.17
		end
			
		--facing
		if this.spd.x!=0 then
			this.flip.x=(this.spd.x>0)
		end

		-- gravity
		local maxfall=0.8
		local gravity=0.05

		if abs(this.spd.y) <= 0.15 then
 			gravity*=0.3
		end

		this.spd.y=appr(this.spd.y,maxfall,gravity*2)
	end
}

evil_door={
	init=function(this)
		this.frames = {
			{7,16},
			{225,6},
			{226,6},
			{227,243}
		}
		this.hitbox = { h=16, w=8, x=0, y=-8 }
		this.frame = 1
		this.damage = 1
		this.health = 5
		this.maxjump = 4
		this.start_x = this.x
	end,
	hurt=function(this)
		if (not this.invincible and this.health > 1) then
			this.invincible = 0
			sfx(38)
			init_object(red_sparks,this.x,this.y)
			init_object(red_sparks,this.x,this.y)
			init_object(red_sparks,this.x,this.y)
			this.health -= 1
		elseif (this.health == 1) then
			create_smoke(this.x, this.y)
			destroy_object(this)
			init_object(exp_triangle,this.x,this.y)
			init_object(exp_triangle,this.x,this.y)
		end
	end,
	update=function(this)
		local on_ground=this.is_colliding(0,1)
		this.frame = 1

		if char.x > this.x - 56 then
			this.frame = 2
		end

		local it = this.invincible
		if (it and it < 10) then
			this.frame = 4
			this.invincible += 1
		end
		if (it and it == 4 or it == 7) then
			this.frame = 3
			this.x -= 1
		else
			this.x = this.start_x
		end
		if (it and it > 9) this.invincible = nil
	end,
	draw=function(this)
		spr(this.frames[this.frame][1],this.x,this.y-8,1,1)
		spr(this.frames[this.frame][2],this.x,this.y,1,1)
	end
}

door={
	doors = {
		_73 = 'two',
		_5610 = 'one',
		_7235 = 'three',
		_620 = 'two'
	},
	id=function(this)
		local co = get_global_coords(this.x,this.y)
		return '_'.. co.x/8 .. co.y/8
	end,
	init=function(this)
		this.interactable=true
		this.solids=false

		if (door.id(this) == '_7235') then
			this.tiles = {194,210}
		else
			this.tiles = {7,16}
		end
	end,
	interact=function(this)
		this.start_t = t
		if (door.id(this) != '_7235') this.tiles={9,37}
		scene.active_door = door.id(this)
	end,
	update=function(this)
		if (this.start_t) then
			local dt = t - this.start_t

			-- fade out
			crossfade.size = flr(dt / 2)
			if (crossfade.size > crossfade.max) then
				crossfade.max_t = t
				-- go to next level
				local lvl_name = this.type.doors[door.id(this)]
				current_scene.draw = scene[lvl_name].draw
				current_scene.update = scene[lvl_name].update
				current_scene.init = scene[lvl_name].init
				this.start_t = nil
			end
		end
	end,
	draw=function(this)
		rectfill(this.x,this.y-8,this.x+7,this.y+7,0)
		spr(this.tiles[1],this.x,this.y-8,1,1)
		spr(this.tiles[2],this.x,this.y,1,1)
	end
}

heart_cont={
	tile = 13,
	init=function(this)
		this.interactable=true
		this.solids=false
		this.start_t=t
	end,
	interact=function(this)
		this.step = 1
		char.health_increase = 3
	end,
	update=function(this)
		local ht = t - this.start_t
		if ht % 6 > 3 then
			this.spr = 13
		else
			this.spr = 14
		end

		if (this.step) then
			if (this.step == 1) text_object = {'obtained a life capsule'}
			if (this.step == 2) text_object = {'max health increased by 3'}
			this.spr = 0
			if (btnp(4) or btnp(5) and this.step < 3) then
				this.step+=1
			elseif this.step > 2 then
				pause_player = false
				text_object = {}
				destroy_object(this)
			end
		end
	end
}

chest={
	tile = 48,
	init=function(this)
		this.interactable=true
		this.solids=false
		this.start_t=t
		this.animating = -1
		this.empty = false
	end,
	interact=function(this)
		--get the polar star!
		this.empty = true
		this.step = 1
	end,
	update=function(this)
		local ht = t - this.start_t
		if (not this.empty) then
			this.spr = 48

			if (this.animating < 0 and rnd(1) < 0.03) then
				this.animating = ht
			elseif this.animating > 0 then
				this.spr = 33
				if (ht > this.animating + 6) this.spr = 49
				if (ht > this.animating + 16) then
					this.animating = -1
					this.spr = 49
				end
			end
		else
			this.spr = 32

			if (this.step == 1) text_object = {'opened the chest'}
			if (this.step == 2) text_object = {'obtained the polar star.'}
			if (this.step == 3) then
				text_object = {}
				pause_player = false
				char.weapon = 'star'
			end
			if (btnp(4) or btnp(5) and this.step < 4) then
				this.step+=1
			end
		end
	end
}

save_disk={
	animation = {26,27,28,29,30,29,28,27,26},
	init=function(this)
		this.interactable=true
		this.solids=false
		this.start_t = t
		this.frame = 1
		this.step = 0
	end,
	interact=function(this)
		this.step = 1
	end,
	update=function(this)
		local t1 = t - this.start_t
		local delay = 2

		if t1 / delay < count(this.type.animation) - 1 then
			this.frame = flr(t1 / delay) + 1
		else
			this.start_t = t
		end

		if (this.step == 1) text_object = {'game saved'}
		if (this.step == 1 and btnp(4) or btnp(5)) then
			text_object = {}
			this.step+=1
			pause_player = false
		end
	end,
	draw=function(this)
		spr(this.type.animation[this.frame],this.x,this.y,1,1)
	end
}

health_station={
	animation = {10,11,11,12,11,12,11,10},
	init=function(this)
		this.interactable=true
		this.solids=false
		this.start_t = t
		this.frame = 1
		this.step = 0
	end,
	interact=function(this)
		this.step = 1
	end,
	update=function(this)
		if (this.a_time) then
			local t1 = t - this.start_t
			local delay = 3

			if t1 / delay < count(this.type.animation) then
				this.frame = flr(t1 / delay) + 1
				printh(this.frame)
			else
				this.start_t = t
				this.a_time = false
			end
		else
			if (rnd(15) < 1) then
				this.a_time = true
			end
		end

		if (this.step == 1) text_object = {'health refilled'}
		if (this.step == 1 and btnp(4) or btnp(5)) then
			text_object = {}
			this.step+=1
			pause_player = false
		end
	end,
	draw=function(this)
		spr(this.type.animation[this.frame],this.x,this.y,1,1)
	end
}

exp_triangle={
	tile=46,
	init=function(this)
		this.animation={43,44,45}
		this.start_t = t
		this.at = t
		this.spd.y=-0.1+rnd(0.2)
		this.spd.x=-0.3+rnd(0.6)
		this.hitbox = { h=4, w=4, x=2, y=3 }
	end,
	update=function(this)
		local t1 = t - this.start_t
		local ta = t - this.at

		local delay = 2

		if ta / delay < count(this.animation) - 1 then
			this.spr = this.animation[flr(ta / delay) + 1]
		else
			this.at = t
		end

		local maxfall=0.8
		local gravity=0.05

		if abs(this.spd.y) <= 0.15 then
			gravity*=0.3
		end

		this.spd.y=appr(this.spd.y,maxfall,gravity*2)
		if (this.is_colliding(0,1)) then
			this.spd.y -= 0.5
			sfx(35)
		end

		if (t1 > 116) this.spr = this.type.tile
		if (t1 > 120 or this.collide(player)) destroy_object(this)
	end
} 
health_heart={
	tile=15,
	init=function(this)
		this.animation={15,31,15,31}
		this.start_t = t
		this.at = t
	end,
	update=function(this)
		local t1 = t - this.start_t
		local ta = t - this.at

		local delay = 1
		if (t1 > 124) delay = 2

		if ta / delay < count(this.animation) - 1 then
			this.spr = this.animation[flr(ta / delay) + 1]
		else
			this.at = t
		end

		if (t1 > 147) this.spr = 38
		if (t1 > 150 or this.collide(player)) destroy_object(this)
	end
}

snore={
	tile=200,
	init=function(this)
		this.animation={200,201,202}
		this.start_t = t
	end,
	update=function(this)
		local t1 = t - this.start_t

		local delay = 5
		local loop = 10

		if t1 / delay < count(this.animation) then
			this.spr = this.animation[flr(t1 / delay) + 1]
		elseif t1 / delay < count(this.animation) + loop then
			this.spr = 0
		else
			this.start_t = t
		end
	end
}


function init_object(type,x,y)
	local obj = {}
	obj.type = type
	obj.collideable=true
	obj.solids=true

	obj.spr = type.tile
	obj.flip = {x=false,y=false}

	obj.x = x
	obj.y = y
	obj.hitbox = { x=0,y=0,w=8,h=8 }
	obj.health = 1

	obj.spd = {x=0,y=0}
	obj.rem = {x=0,y=0}

	obj.is_colliding=function(ox,oy)
		local c = check_collision(
			obj.x+obj.hitbox.x+ox,
			obj.y+obj.hitbox.y+oy,
			obj.hitbox.w,
			obj.hitbox.h
		)
		if (not c or count(c) > 0) return false
		return true
	end

	obj.check_collision=function(ox,oy)
		return check_collision(
			obj.x+obj.hitbox.x+ox,
			obj.y+obj.hitbox.y+oy,
			obj.hitbox.w,
			obj.hitbox.h
		)
	end

	obj.in_water=function(ox,oy)
		return check_water(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
	end

	obj.in_danger=function(ox,oy)
		local map_danger = check_danger(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
		--local enemy_danger = obj.
		return map_danger
	end
	
	obj.collide=function(type,ox,oy)
		local other
		if ox==nil then ox=0 oy=0 end
		for i=1,count(objects) do
			other=objects[i]
			if other ~=nil and other.type.init == type.init and other != obj and other.collideable and obj.check_coords(other,ox,oy) then
				return other
			end
		end
		return nil
	end

	obj.interact=function(ox,oy)
		local other
		if ox==nil then ox=0 oy=0 end
		for i=1,count(objects) do
			other=objects[i]
			if other ~=nil and other != obj and other.interactable and obj.check_coords(other,ox,oy) then
				return other
			end
		end
		return nil
	end
	
	obj.check_damage=function(ox,oy)
		local other
		if ox==nil then ox=0 oy=0 end
		for i=1,count(objects) do
			other=objects[i]
			if other ~=nil and other != obj and other.damage and obj.check_coords(other,ox,oy) then
				return other.damage
			end
		end
		return nil
	end

	obj.check_coords=function(other,ox,oy)
		return other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x+ox and 
				other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y+oy and
				other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w+ox and 
				other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h+oy
	end
	
	obj.move=function(ox,oy,rep)
		local amount
		-- [x] get move amount
 		obj.rem.x += ox
		amount = flr(obj.rem.x + 0.5)
		obj.rem.x -= amount
		local movedx = obj.move_x(amount,0)
		
		-- [y] get move amount
		obj.rem.y += oy
		amount = flr(obj.rem.y + 0.5)
		obj.rem.y -= amount
		local movedy = obj.move_y(amount)
	end
	
	obj.move_x=function(amount,start)
		if obj.solids then
			local step = sign(amount)
			for i=start,abs(amount) do
				local col = obj.check_collision(step,0)
				if not col then
					obj.x += step
				elseif col.problem then
					local problem = col.points[col.problem]
					local solution = col.points[col.problem-step]

					if (solution) then
						-- checking for walls
						local col = obj.is_colliding(step,-4)
						if (not col) then
							obj.x += step
							obj.y += problem - solution
						end
					else
						local stepy = -3
						local col = obj.is_colliding(step,stepy)
						if (not col) then
							obj.x += step
							obj.y += stepy
						end
					end
				else
					obj.spd.x = 0
					obj.rem.x = 0
					return false
				end
			end
			if (step != 0) return true
			return false
		else
			obj.x += amount
			return true
		end
	end
	
	obj.move_y=function(amount)
		if obj.solids then
			local step = sign(amount)
			for i=0,abs(amount) do
				local col = obj.check_collision(0,step)
	 			if not col or count(col) < 0 then
					obj.y += step
				else
					if (obj.hithead and obj.spd.y < 0) obj.hithead(obj)
					obj.spd.y = 0
					obj.rem.y = 0
					return false
				end
			end
			if (step != 0) return true
			return false
		else
			obj.y += amount
			return true
		end
	end

	add(objects,obj)
	if obj.type.init~=nil then
		obj.type.init(obj)
	end
	return obj
end

function draw_object(obj)
	if obj.type.draw ~=nil then
		obj.type.draw(obj)
	elseif obj.spr > 0 then
		spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
	end
end

function destroy_object(obj)
	del(objects,obj)
end

function _init()
	if (music_on) music(2)
end

function _update()
	t += 1
	if current_scene.init then
		current_scene.init()
		current_scene.init=nil
	end

	foreach(objects,function(obj)
		obj.move(obj.spd.x,obj.spd.y)
		if obj.type.update~=nil then
			obj.type.update(obj)
		end
	end)

	current_scene.update()
	scene.update()

	if player_death and t - player_death > 10 then
		if (music_on) music(16,1+2)
		player_death = nil
	end
end

function _draw()
	-- draw dark background
	camera()
	rectfill(0,0,128,128,0)

	current_scene.draw()

	camera()

	draw_player_ui()

	if (count(text_object) > 0) then
		print_text()
	end

	if (crossfade.size) then
		draw_circles(crossfade.size)
	end

	if (message) then
		local center = 64 - #message * 2
		print(message, center, 60, 7)
	end
end


-- helper functions --

function appr(val,target,amount)
 return val > target 
 	and max(val - amount, target) 
 	or min(val + amount, target)
end

function sign(v)
	return v>0 and 1 or v<0 and -1 or 0
end

function clamp(n, min, max)
	if n < min then return min end
	if n > max then return max end
	return n
end

function check_water(x,y,w,h)
	local t = check_tile_flag(x+lvl_cam.x,y+lvl_cam.y,w,h,4)
	if (count(t) > 0) return true
	return false
end

function check_danger(x,y,w,h)
	local t = check_tile_flag(x+lvl_cam.x,y+lvl_cam.y,w,h,7)
	if (count(t) > 0) return true
	return false
end

function check_destructable(x,y,w,h)
	local t = check_tile_flag(x+lvl_cam.x,y+lvl_cam.y,w,h,6)
	return t
end

function check_collision(x,y,w,h)
	x = x + lvl_cam.x
	y = y + lvl_cam.y
	local col_tiles = check_tile_flag(x,y,w,h,0)

	local angle
	if count(col_tiles) > 0 then
		-- checking if custom collision exists for this tile
		angle = check_for_angle(col_tiles)
	end
	if col_tiles and angle then
		-- coordinates are all screwwy
		local px = col_tiles[1].x*8
		local py = col_tiles[1].y*8
		local c = false
		c = c or check_point({x=x+w,y=y}, collision_types[angle], px, py)
		c = c or check_point({x=x,y=y}, collision_types[angle], px, py)
		c = c or check_point({x=x,y=y+h}, collision_types[angle], px, py)
		c = c or check_point({x=x+w,y=y+h}, collision_types[angle], px, py)
		return c
	end
	return col_tiles[1]
end

function check_point(s,points,px,py,edge)
	local collision = false
	for i=1,count(points) do
		local px1 = px + i
		local py1 = py + points[i]

		if px1 == s.x and py1 < s.y then
			collision = {points=points,problem=i}
		end
	end

	return collision
end

function get_lvl_coords(ox, oy)
	if (scene.coords) then
		local new_co = {x=0, y=0}
		new_co.x = ox - lvl_cam.x
		new_co.y = oy - lvl_cam.y
		return new_co
	end
	return {x=ox,y=oy}
end

function get_global_coords(ox, oy)
	if (scene.coords) then
		local new_co = {x=0, y=0}
		new_co.x = ox + lvl_cam.x
		new_co.y = oy + lvl_cam.y
		return new_co
	end
	return {x=ox, y=oy}
end

function check_for_angle(tiles)
	for i=1,count(tiles) do
		if angle_tiles['_'..tiles[i].tile_id] then
			return angle_tiles['_'..tiles[i].tile_id]
		end
	end
	return false
end

function check_tile_flag(x,y,w,h,flag)
	-- checking each point in the next tile length
	local tiles = {}
	for i=max(0,flr(x/8)), (x+w-1) / 8 do
		for j=max(0,flr(y/8)), (y+h-1) / 8 do
			local tile_id = tile_at(i,j)
			if fget(tile_id,flag) then
				add(tiles, {x=i, y=j, tile_id=tile_id})
			end
		end
	end
	return tiles or false
end

function tile_at(x,y)
  return mget(x, y)
end

function maybe()
	return rnd(1)<0.5
end

	
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
__gfx__
000000000000000000000000000000000000000000000000208877d2000000000000007000000000666666506666665066666650000000000000000000000000
00000000088777000887770008877700088777000887770020ddddd2000000000000077700000000688888606222226060000060000000000000000000220220
00000000888888888888888888888888888888888888888820000072000000000000007000000000680808606202026060000060000000000000000002782882
00000000b1616160b1616160b1616160b1616160b161616020222202000000000000000000000000680008506200025060000050065555560655555602888882
0000000003777600037776000377760003777600037776002022222200000000000000000000000068808850622022506000005006780806067e0e0602888882
000000000005000000050000000500000065000000650000202222d200222200000000000066660018888810122222101000001006088806060eee0600288820
0000000000680000006800000068100000180000001800002dddddd2020000200000000006000160555555505555555055555550050080050500e00500028200
00000000001100000010100000100000000010000000100022222222202222220000000060000016656555506565555065655550052552250525522500002000
202222d200000000000000000000000000000000000000000000000000000c000000000000000d00000000000000000000000000000000000000000000000000
20ddddd208888888088888880888888808888888088888880000000000000c000000000000000700000800000008000000080000000800000008000000880880
2000007288616160886161608861616088616160886161600000000000000cc00000000000000700008580000085200000020000002580000055800008778778
20222202b1666660b1666660b1666660b1666660b16666600000000000000c000000000000000700088858000082500000020000005580000555880008777778
20222222037776000377760003777600037776000377760000000000000000000000000000000700887885800882220000020000025288008558888008777778
202222d200056000000560000005600000056000000560000000cccc0000000000d7777d00000d00277788200262210000050000012282002888885000877780
2dddddd2000800000008000000081000001800000018000000000c00000000000000000000000000027882000007100000060000002280000288850000087800
22222222001100000010100000100000000010000000100000000000000000000000000000000000002820000002000000070000001220000028500000008000
00000000000000000000000008877700000000006000001600666600005555000556550000000000000000000000000000000000000000000000000001010000
00000000079999910ddddd0088888888088888006000001607777760055555505665555000000000000000000000000000000000000000000000000001111000
0000000079944455ddddddddb1666600888888886000001667777776555555555555555500000000000000000000000000000000000000000009f90017171000
7665dd5576766655d161616003717100b111b160600000166777777655555555555555570000000000000000000090000090000000009000009777900111d000
74654422747644220d66660000050000031113006000001667777776555555556555557600000000000000000009f000009ff900009f900000f777f00d11ddd0
744444227444442200050000007810000005000060000016677777765555555d7777776d0000000000000000009fff00000f900009ff9000009777900dd1ddd0
7444442274444422005d0000001000000008600060000016067777600d5555d0067666d0000000000000000000000000000f0000000090000009f90000d00dd0
7ddddd5577766655001100000000000000110000600000160066660000dddd0000dddd0000000000000000000000000000000000000000000000000000d00d00
000000000000000000000000000600600111110006770000067000000600000005000000000000000000000000060000000000000000000000000000d101000d
079999910d44444100060060011111110011001007705550070055505000066500000050000000000000000000575000008888000000000000000000d11110dd
79999955d44444660111111110111011110111160055556600005566000000060000000500007000000070000007000008000020000888000000000017171ddd
77766655ddd55566100110011011101111111111555556665550566656660000066500000007760000767550750000578000000200800080000080000111ddd0
79769922d4d544991111111111101111111111116666677766750066056660000066500000007000000777005700067080000002008000200008020000111d00
79999944d44444991110111111111111111111116667777067677060000000600000000000000000000705000000000080000002008000200000200000011100
79999944d44444991111111111111111011011110067770000677700000006500000005000000000000000000070070002000020000222000000000000000000
766ddd55dddddd660111111001100110000001100000000000000000000000000000000000000000000000000750057000222200000000000000000000000000
6ddddddd0000000000000011110000000000000000000005100000005555555bdd6ddddd000000000000000000000000000000000000d0d00011101000151111
d555555100000000000011d55d1100000000000000000055110000005d1111d37dd5dd6d00080000000000000000000000000000000070700005000000015110
d5555551000000000011dd5005dd11000000000000001d111551000051d666d3d75656d600080080000000000000000000000000000070701000000000000000
d5555151000000006151550555551516000000000000dd115155100051d16d137dd75d6d80020280000000000000000000000000000070701100000000000000
d55555550000006dd51550505555515dd60000000066d0d115555100544d1713dd67dddd0822d850d777777d0000000000000000000070701100000000000001
dd5555d100001ddd5d110105501111d0ddd1000006dd0d0d055151005411777376d6765d02dddd02000000000000000000000000000070701100000000000051
d5155551001155d0d51010111101010d0d5511001dd010d05015511051111713d76775d5dd55115dd777777d06d06d0006000d50000070701000000000000005
51d1111d11055ddd1111111550101011ddd550111d01051501511551b3333333677ddd5d1111111100000000011ddd506111d5500000d0d05000000000000000
0d0000d01155051555dd50055005dd5551505511155551501010115177777777d0088000d5115111000000000111dd5110115051000000000000000000000000
0d0000d0001111d155ddd500555ddd501d111100015555150101111078585527dd2200002dd5ddd20000000d101655105d550515000000001500000000000061
0d0000d0000011111151dd0555ddd501111100000115515110101110785555875dd000008202d008000000d10d010106d6ddddd1500000001100000000000051
07000070000000111d101050050101d11100000000015515010110007888888715dd20000208208000000015d510106d6ddddddd500000001000000000000011
07000070000000001111050550501111000000000001555150110000788888871ddd28800800800000000005510106d6ddddddddd00000000000000000000001
0d0000d00000000000115015510511000000000000000551111000007866668715d0000000008000000000d55110dddddddddddd100000000000000000000000
0d0000d0000000000000111111110000000000000000001151000000786666871522000000000000000000001100d5ddddd1d1ddd00000001000600106000100
07000070000000000000001111000000000000000000000110000000777777771008800000000000000000006dd0565d51111d1d100000001061101101100510
051111110000000000000d6d11000000000000000000000000000000dd5000000dddddd00000800d00000006d6d51055511011d1100000000111501111105111
0055111000000000006666d55d111000000000000000000000000000d5500000d4444d00000008dd0000000d5d51010511010101100000000015000015005111
000111000000000006616d5055dd5100000000000000000000000000d050000011411dd00088d2d10000000dd51110100000001d000000001000000000000510
0000100000000000665dd55d55051515000000000000000000000000d550000024444d0000022dd50000000d151101010056d501000000001500000000000005
000501000000006dd5ddd0d550d5555d000000000000000000000000d05000002444400000000dd1000000d11010101056d55151100000005000000000000051
00051100000016dddd11000555501555d00000000066ddddddd55000d550000000111d0000002d51000000110100005dd5551501500000000000000000000061
00006000001655ddd51010011101015d0d50000000000555550000ddd0500000041141d000822dd100000001505005dd51515015100000001000000000000005
0000500011055ddd1111111051111111ddd5501100005510055000d0d0500000221221d0000002510000000d05005dd555150101000000005000000000000000
000010001155051555dd50550150d15151505511c0011001c0011001c0011001010110010000000000000000110ddd5111501010000505000000000000000000
00050100001111d155ddd500100ddd05001111000110011001100110011001100110011000000000000000001105d5005501510000d666d05000000000000005
00051100000011111151dd0550dd5050001100000000000d100d000d000d000150000006000000000d7777d00000000000000000007777701500000000000005
000060000000001115101050550101051100000001000000500000000c0000011500060000000000567777650000000000000000007777701100000000000061
000050000000000011111505505010510000000000000010d00000c00000000dd155000000000000067777600000000000000000007777701000000000000011
000501000000000000115115510511000000000000d0000050000000001000051d11550000000000567777650000000000000000007777700000000000000001
000511000000000000001111111100000000000000000000150000000000005115d11150000000000d7777d0000000000000000000d666d01006500006500000
00006000000000000000001111000000000000005606056111500001110005111115111500000000000000000000000000000000000505001061111061110510
0000500000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6040000553545000000000000c70000000400c70000a6b6c6b6c6b6c6b6
c6b6c6b6c604000000000004c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000006000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c504d500000000000000000000000000000500000000a5b5c5b5c5b5c5b5
c5b5c5b5c504000000000004c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b63646c40000000000000000000000000500000000a6b6c6b6c6b6c6b6
c6b6c6e4c700001c2c3c00f4c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c504c5b5c53444c4000000000000000000050000000000f6c5b5c5b5c5b5
c53545000000001d2d3d00f7c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b63644c400000000000004000000000000c7b7c7f4c635
450000c45404000404040004c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b50487575757575704000000000000000000000000
b41626b5c504000000000004c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c604000000000467575757575777
c6b6c6b6c6046757575777b6c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c504575777b504b5c5b5c5b5c5b5
c5b5c5b5c5b5c5b5c5b50404c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c604c6b6c6b604b6c6b6c6b6c6b6
c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b504b5c5b5c5b5c5b5
c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6
c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5
c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6
c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5
c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6
c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000776ddddddd500000000000000000000000000070700000707000000000000000000000000000000000000000000000000000000000000000000
000000000007766dd5d55555555000000000000000007000007d7d70007d0d700000000000000000000000000000000000000000000000000000000000000000
00000000076165115ddd555111155000000070000007770007d777d707d000d70000000000777000000060000000000000000000000000000000000000000000
00000000711dd11ddddddd5d11115000000777000077777000777770000000000000000077076000000760700000000000000000000000000000000000000000
0000000071d6ddddd15d51d5d1501500000070000007770007d777d707d000d77760000000760000007067000000000000000000000000000000000000000000
00000000616ddddddd151ddd555001000000000000007000007d7d70007d0d700600000000707600000060000000000000000000000000000000000000000000
0000000061ddddddd551ddddd5511000000000000000000000070700000707006770000007760000000000000000000000000000000000000000000000000000
00000000066d5dd55555515555110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006d6d555666d5515111010000000000000000000000ddd00000ddd000000000000000000000000000000000000000000000000000000000000000000
00000000066ddd516610165151010000000000000000d0000066766000d000d00000000000000000000000000000000000000000000000000000000000000000
0000000006d6d511060006011000000000007000000777000d67776d0d00000d0000000000000000000000000000000000000000000000000000000000000000
00000000066dd51000000000110000000007770000d777d00d77777d0d00000d0000000000000000000000000000000000000000000000000000000000000000
0000000006d65510000000001510010000007000000777000d67776d0d00000d0000000000000000000000000000000000000000000000000000000000000000
00000000056dd5106000006051000000000000000000d0000066766000d000d00000000000000000000000000000000000000000000000000000000000000000
000000005ddd5d51dd000d51511001000000000000000000000ddd00000ddd000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222000022220000222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000020000200266662002688620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000208866222688776226788762000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000207777d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020ddddd2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020000072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020222202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000020222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000202222d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000002dddddd2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003010101010101014180000202000200000101010100000080800201010200000001010101000000008002010102020000000000001010101000000202000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c6b6c6b53406c6b6c6b6c6b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b5c4e00074f5b5c53525b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c53540000105a6b6c43426b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c405c5b5c5b4040405b5c405c5b40405c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c6d004142405f5b5c5b5c5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c406c6b6c6b406b535471726c6b6c406c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c40405d5a4040404040735240406c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c405c5b5c5b404e000000007b4f5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c5b6d007b7c00000000004f5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c406c7c5152405d00000000000040406c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6c6b4344000000000000005f6b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5354000000400000000000000009405c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c5b5c5b5d4c4b00004540405b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c535471747b7c0000000000480000000000000025406c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6c406c406d4040405d406b6c6b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c73740009570000004000000000480000000000000040405c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b5c5d007b7c4c5f5b5c5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b56556b6c53545900000025004546004800004b4c4800000000004b616c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c6b6c767575775b5c6b6c6b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5d007b7c000000007f4040405c5b5c4044415c5b4063644b4c455c5b5c405c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b735400000000004b4c5f6c6b6c6b6c6b6c406c6b6c6b4040406b406b404040406c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6c6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c405c5b5c5b5c5b5c59000000000000495b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c5354000000004c61626c6b6c6b6c6b6c6b6c6b6c406c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c405b5c5b5c4e0000000041425b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b5c5b5c5b5c405c5b5c5b5c5b5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b564051527374000000005f6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c6b6c6b407374607b7c55406c6b6c5b5c5b5c5b5c5b5c5b5c5b5c5354715c540050000000000000007f5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b40404e00007000000060405b5c6b6c6b6c6b6c6b6c6b6c6b6e0000007c000050000000000049416b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c6b40000900000000000070406b6c5b5c5b5c5b5c5b5c5b5c5b5d0000000000004000000041425b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b407e254c4b6865666700405b5c6b6c6b6c6b6c6b6c6b6c6b6d0000000000004000005a6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c406c404040406b40404040404040406c5b5c5b5c5b5c5b405b73740000000000000000004b7f5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5b5c5b405b5c5b5c5b5c5b5c5b405b5c6b6c6b6c6b6c6b40405800000000400000004c616b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6b6c6b406b6c6b6c6b6c6b6c6b6c6b6c5b5c5b5c5b5c400000000000000050004b615b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5b5c6b6c6b6c6b6c6b4000000000000050416b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6b6c5b5c5b5c5b5c5b4000000000005a5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006b6c6b6c6b6c6b7e4b4c000000005071726c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005b5c5b405b40404040404000000040000040404040405b405b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006b6c6b6c6b6c6b406b6c6b5d000000000069406c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005b5c5b5c5b5c5b405b5c5b43644c00000000407b4f5c5b5c5b5c5b5c5b5c5b5c5b5c405c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006b6c6b6c6b6c6b6c6b6c6b6c6b6c444b000050005a6c6b6c6b6c6b6c6b6c6b6c6b6c406c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b404040406c6b6c6b6c6b6c6b6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5e4c50006a5c5b5c567b7c7b51525b53747c40595b53545a5b5c5b5c5b5c5b5c5b5c5b5c404e00717240405c5b5c5b5c5b5c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
012600102b0602b0602b0602b0602b0602a0602b0602d060320503205032050320502a0602a0602a0602a06000000000000000000000000000000000000000000000000000000000000000000000000000000000
012600102b0002f060300602f0602d0602b0602d0602f0602b0602b0602b0602b0652b0602a0602806026060320002f000300002f0002d0002b0002d0002f0002b0002b0002b0002b0052b0002a0002800026000
01260010320602b000320602b00034060320602f0603206037040370403605036050340503405032060320603200032000320003200034000320002f000320003700037000360003600034000340003200032000
0126000009170101701317010170091001017013170101700b170121701517012170000001217015170121700b1000e100121000e100000000e100121000e1001310010100131001010000000171051a10517105
012600100b1700e170121700e170000000e170121700e1701317010170131701017000000171751a1751717500000000000000000000000000000000000000000000000000000000000000000000000000000000
011300003563035635136151361535640356451361513615356303563513615136153564035645136151361535630356351361513615356303563513615136153563035635136151361535640356451361513615
011300201c3301c3301e3301f33009320093001e3501f3501c3501c3501e3501f35009320153001c3501f3501e3501e3501f350213500b320173001f350213501e3501e3501f350213500b320173001f35021350
011300001c3501c3501e3501f350093501c3001e3501f3501c3501c3501e3501f35009350000001e3501f3501a3501a3501c3501d35005350000001c3501d3501a3501a3501c3501d35005350000001c3501d350
011300101305318005130530c7001305313053000050c0530c0030c05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
011300003060330605306453060530605306053064530605306033060530645000003060330605306433064330643306033064330603306030000030645000000000000000306450000030645306053064530645
0113000018340183401c3401f34018340183401c3401f34018340183401c3401f34018340183401c3401f3401a3401a3401e340213401a3401a3401e340213401a3401a3401e340213401a3401a3401e34021340
011300001a3401a3401e340213401a3401a3401e340213401a3401a3401e340213401a3401a3401e340213401c3401c3401e3401f3401c3401c3401e3401f3401a3401a3401e3401f3401a3401a3401e3401f340
011300001c3001c3001e3001f3001c3001c3001e3001f3001c3001c3001e3001f3001c3001c3001e3001f3001c3101c3101e3101f3101c3201c3201e3201f3201c3301c3301e3301f3301c3401c3401e3401f340
012600101f5501f5501f5501f5501f5501f5501f5501f5501e5501e5501e5501e5501e5551e5501f5501f550231002310023100231001f1001f1001f1001f1001d1001d1001d1001d10000000000000000000000
01260010235402354023540235401f5401f5401f5401f5401d5401d5401d5401d5401d5401d545000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012600101f3301f3301f3301f3301f3301f3301f3301f3301e3301e3301e3301e3301e3301e3301e3301e330231002310023100231001f1001f1001f1001f1001d1001d1001d1001d10000000000000000000000
012600101c2401c2401c2401c2401c2401c2401c2401c2401a2401a2401a2401a2401a2401a245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012600101c2401c2401c2401c2401c2401c2401c2401c2401e2401e2401e2401e2401e2401e2401e2401e2401f2001f2001f2001f2001f2001f2001f2001f2001e2001e2001e2001e2001e2001e2001e2001e200
012600101f2401f2401f2401f2401f2401f2401f2401f2401e2401e2401e2401e2401e2401e2401e2401e24000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001f3501f35021350223500a3501c30021350223501f3501f35021350223500a3500000021350223501e3501e3501f3502135009350000001f350213501e3501e3501f3502135009350000001f35021350
01260008346051c6251c6051c645136051c625346051c6451a6021c625246041c645216061c625246001c645000001c6050000000000000000000000000000000000000000000000000000000000000000000000
011300001300313323133231000313123000000c1230c006000000c0030c0330000000000000000000000000130231322313023000001312300000131230000000000000000c0330000000000000000000000000
0113000021270212701e2001f20024270242701e2001f20021270212701e2001f20024270242701e2001f20026270262701e2001f20024270242701e2001f20021270212701e2001f2001e2701e2701e2001f200
011300001e2701e27000000000001f2701f27000000000001e2701e27000000000001f2701f2700000000000212702127000000000001d2701d27000000000001a2701a27000000000001e2001e2000000000000
0113000022270222700000000000242702427000000000002227022270000000000024270242700000000000212702127000000000001e2701e27000000000000000000000000000000000000000000000000000
011300003060330605306453060530605306053064530605306033060530645000003060330605306433064330643306033064330603306030000030645000000000000000306450000030645306553067530675
010c00203564534605356053460535645346053560535605356453460534600356453564535605346053564535645346053460534605356453460534605346053564534605346053564535645356053560535605
010d00003560535605346053564534605346053560535605356053560535605356453560535605346053560535605356053460535645346053460535605356053560535605356453564535605356053564535645
0118000020260202602026020260202602026020260202601f2601f2601f2601f2601f2601f2601f2651f2051f2601f2601f2601f2601f2601f2601f2601f2601d2601d2601d2601d2601d2601d2601d2651d205
010e1000182001d2001d2001f2002020000000000000000000000000000000000000182001d2001d2001f200000000000000000000000000000000000000000000000000000000000000182701d2701d2701f270
011800001d2601d2601d2601d2601d2601d2601d2601d2601c2601c2601c2601c2601c2651a2601c2601c2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d2601d260
011000001c2001c2001c2001c2001c2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d2001d200
010f00000000000000000003060530605306053060530645000003060530605306053060530645306053060530605306053060530645000003060530605306053060530645306453060530645306453060530605
011800001124011240142401424018240182401d2401d2401024010240132401324018240182401c2401c2400f2400f240132401324016240162401b2401b2400e2400e240112401124016240162401a2401a240
011800000d2400d2401124011240142401424019240192400c2400c24010240102401324013240182401824011240112401124011240112401124011240112400522005220052200522005220052200522005220
010200003427034575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001566016660176601a6601c6602065021640256302a6200000000000000001063013630196301d62022620006000000000000000000000000000000000000000000000000000000000000000000000000
0003000011220112200f2200b23008240052600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001727017270172701727017270182701a2701c2701f2702227022270212701f2701c2701927017270122700e2700020000000000000000000000000000000000000000000000000000000000000000000
010300002717027170281702b170301702f1702b1702817024170201701c170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010300002a3402a3402a3402a34029340293402834024340233401f3401c3401a3401734015340133401034008340053400434003340033400334000000000000000000000000000000000000000000000000000
01040000162301723018230192301c2301d2302023022230262202a2202f210362102f10034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000240330c004240031e7001a700177001070007700047000170000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600003062232622306223062300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002
__music__
00 08 09 43 44
01 14 15 43 44
01 14 15 43 44
01 14 15 0c 44
01 0d 09 06 44
00 0e 09 07 44
00 11 09 06 44
00 12 09 13 44
00 16 09 06 44
00 17 09 07 44
00 16 09 06 44
00 18 19 13 44
00 00 05 03 44
00 01 04 0b 44
00 00 05 03 44
02 02 04 05 0b
01 1d 1b 43 44
00 1c 21 1a 44
04 1e 22 1a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
