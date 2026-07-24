pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- return to celeste mountain
-- pikiktheyeet

-- globals --
-------------

room = { x=0, y=0 }
objects = {}
types = {}
freeze=0
shake=0
will_restart=false
delay_restart=0
got_fruit={}
has_dashed=false
sfx_timer=0
has_key=false
pause_player=false
flash_bg=false
music_timer=0

k_left=0
k_right=1
k_up=2
k_down=3
k_jump=4
k_dash=5

-- entry point --
-----------------

function _init()
	title_screen()
end

function title_screen()
	got_fruit = {}
	for i=0,29 do
		add(got_fruit,false) end
	frames=0
	deaths=0
	max_djump=1
	start_game=false
	start_game_flash=0
	music(40,0,7)
	
	load_room(7,3)
end

function begin_game()
	frames=0
	seconds=0
	minutes=0
	music_timer=0
	start_game=false
	music(0,0,7)
	load_room(0,0)
end

function level_index()
	return room.x%8+room.y*8
end

function is_title()
	return level_index()==31
end

-- effects --
-------------

clouds = {}
for i=0,16 do
	add(clouds,{
		x=rnd(128),
		y=rnd(128),
		spd=1+rnd(4),
		w=32+rnd(32)
	})
end

particles = {}
for i=0,24 do
	add(particles,{
		x=rnd(128),
		y=rnd(128),
		s=0+flr(rnd(5)/4),
		spd=0.25+rnd(5),
		off=rnd(1),
		c=6+flr(0.5+rnd(1))
	})
end

dead_particles = {}

-- player entity --
-------------------

player = 
{
	init=function(this) 
		this.p_jump=false
		this.p_dash=false
		this.grace=0
		this.jbuffer=0
		this.djump=max_djump
		this.dash_time=0
		this.dash_effect_time=0
		this.dash_target={x=0,y=0}
		this.dash_accel={x=0,y=0}
		this.hitbox = {x=1,y=3,w=6,h=5}
		this.spr_off=0
		this.was_on_ground=false
		create_hair(this)
	end,
	update=function(this)
		if (pause_player) return
		
		local input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)
		
		-- spikes collide
		if spikes_at(this.x+this.hitbox.x,this.y+this.hitbox.y,this.hitbox.w,this.hitbox.h,this.spd.x,this.spd.y) then
		 kill_player(this) end
		 
		-- bottom death
		if this.y>128 then
			kill_player(this) end

		local on_ground=this.is_solid(0,1)
		local on_ice=this.is_ice(0,1)
		
		-- smoke particles
		if on_ground and not this.was_on_ground then
		 init_object(smoke,this.x,this.y+4)
		end

		local jump = btn(k_jump) and not this.p_jump
		this.p_jump = btn(k_jump)
		if (jump) then
			this.jbuffer=4
		elseif this.jbuffer>0 then
		 this.jbuffer-=1
		end
		
		local dash = btn(k_dash) and not this.p_dash
		this.p_dash = btn(k_dash)
		
		if on_ground then
			this.grace=6
			if this.djump<max_djump then
			 psfx(54)
			 this.djump=max_djump
			end
		elseif this.grace > 0 then
		 this.grace-=1
		end

		this.dash_effect_time -=1
  if this.dash_time > 0 then
   init_object(smoke,this.x,this.y)
  	this.dash_time-=1
  	this.spd.x=appr(this.spd.x,this.dash_target.x,this.dash_accel.x)
  	this.spd.y=appr(this.spd.y,this.dash_target.y,this.dash_accel.y)  
  else

			-- move
			local maxrun=1
			local accel=0.6
			local deccel=0.15
			
			if not on_ground then
				accel=0.4
			elseif on_ice then
				accel=0.05
				if input==(this.flip.x and -1 or 1) then
					accel=0.05
				end
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
			local maxfall=2
			local gravity=0.21

  	if abs(this.spd.y) <= 0.15 then
   	gravity*=0.5
			end
		
			-- wall slide
			if input!=0 and this.is_solid(input,0) and not this.is_ice(input,0) then
		 	maxfall=0.4
		 	if rnd(10)<2 then
		 		init_object(smoke,this.x+input*6,this.y)
				end
			end

			if not on_ground then
				this.spd.y=appr(this.spd.y,maxfall,gravity)
			end

			-- jump
			if this.jbuffer>0 then
		 	if this.grace>0 then
		  	-- normal jump
		  	psfx(1)
		  	this.jbuffer=0
		  	this.grace=0
					this.spd.y=-2
					init_object(smoke,this.x,this.y+4)
				else
					-- wall jump
					local wall_dir=(this.is_solid(-3,0) and -1 or this.is_solid(3,0) and 1 or 0)
					if wall_dir!=0 then
			 		psfx(2)
			 		this.jbuffer=0
			 		this.spd.y=-2
			 		this.spd.x=-wall_dir*(maxrun+1)
			 		if not this.is_ice(wall_dir*3,0) then
		 				init_object(smoke,this.x+wall_dir*6,this.y)
						end
					end
				end
			end
		
			-- dash
			local d_full=5
			local d_half=d_full*0.70710678118
		
			if this.djump>0 and dash then
		 	init_object(smoke,this.x,this.y)
		 	this.djump-=1		
		 	this.dash_time=4
		 	has_dashed=true
		 	this.dash_effect_time=10
		 	local v_input=(btn(k_up) and -1 or (btn(k_down) and 1 or 0))
		 	if input!=0 then
		  	if v_input!=0 then
		   	this.spd.x=input*d_half
		   	this.spd.y=v_input*d_half
		  	else
		   	this.spd.x=input*d_full
		   	this.spd.y=0
		  	end
		 	elseif v_input!=0 then
		 		this.spd.x=0
		 		this.spd.y=v_input*d_full
		 	else
		 		this.spd.x=(this.flip.x and -1 or 1)
		  	this.spd.y=0
		 	end
		 	
		 	psfx(3)
		 	freeze=2
		 	shake=6
		 	this.dash_target.x=2*sign(this.spd.x)
		 	this.dash_target.y=2*sign(this.spd.y)
		 	this.dash_accel.x=1.5
		 	this.dash_accel.y=1.5
		 	
		 	if this.spd.y<0 then
		 	 this.dash_target.y*=.75
		 	end
		 	
		 	if this.spd.y!=0 then
		 	 this.dash_accel.x*=0.70710678118
		 	end
		 	if this.spd.x!=0 then
		 	 this.dash_accel.y*=0.70710678118
		 	end	 	 
			elseif dash and this.djump<=0 then
			 psfx(9)
			 init_object(smoke,this.x,this.y)
			end
		
		end
		
		-- animation
		this.spr_off+=0.25
		if not on_ground then
			if this.is_solid(input,0) then
				this.spr=5
			else
				this.spr=3
			end
		elseif btn(k_down) then
			this.spr=6
		elseif btn(k_up) then
			this.spr=7
		elseif (this.spd.x==0) or (not btn(k_left) and not btn(k_right)) then
			this.spr=1
		else
			this.spr=1+this.spr_off%4
		end
		
		-- next level
		if this.y<-4 and level_index()<30 then next_room() end
		
		-- was on the ground
		this.was_on_ground=on_ground
		
	end, --<end update loop
	
	draw=function(this)
	
		-- clamp in screen
		if this.x<-1 or this.x>121 then 
			this.x=clamp(this.x,-1,121)
			this.spd.x=0
		end
		
		set_hair_color(this.djump)
		draw_hair(this,this.flip.x and -1 or 1)
		spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)		
		unset_hair_color()
	end
}

psfx=function(num)
 if sfx_timer<=0 then
  sfx(num)
 end
end

create_hair=function(obj)
	obj.hair={}
	for i=0,4 do
		add(obj.hair,{x=obj.x,y=obj.y,size=max(1,min(2,3-i))})
	end
end

set_hair_color=function(djump)
	pal(8,(djump==1 and 8 or djump==2 and (7+flr((frames/3)%2)*4) or 12))
end

draw_hair=function(obj,facing)
	local last={x=obj.x+4-facing*2,y=obj.y+(btn(k_down) and 4 or 3)}
	foreach(obj.hair,function(h)
		h.x+=(last.x-h.x)/1.5
		h.y+=(last.y+0.5-h.y)/1.5
		circfill(h.x,h.y,h.size,8)
		last=h
	end)
end

unset_hair_color=function()
	pal(8,8)
end

player_spawn = {
	tile=1,
	init=function(this)
	 sfx(4)
		this.spr=3
		this.target= {x=this.x,y=this.y}
		this.y=128
		this.spd.y=-4
		this.state=0
		this.delay=0
		this.solids=false
		create_hair(this)
	end,
	update=function(this)
		-- jumping up
		if this.state==0 then
			if this.y < this.target.y+16 then
				this.state=1
				this.delay=3
			end
		-- falling
		elseif this.state==1 then
			this.spd.y+=0.5
			if this.spd.y>0 and this.delay>0 then
				this.spd.y=0
				this.delay-=1
			end
			if this.spd.y>0 and this.y > this.target.y then
				this.y=this.target.y
				this.spd = {x=0,y=0}
				this.state=2
				this.delay=5
				shake=5
				init_object(smoke,this.x,this.y+4)
				sfx(5)
			end
		-- landing
		elseif this.state==2 then
			this.delay-=1
			this.spr=6
			if this.delay<0 then
				destroy_object(this)
				init_object(player,this.x,this.y)
			end
		end
	end,
	draw=function(this)
		set_hair_color(max_djump)
		draw_hair(this,1)
		spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)
		unset_hair_color()
	end
}
add(types,player_spawn)

spring = {
	tile=18,
	init=function(this)
		this.hide_in=0
		this.hide_for=0
	end,
	update=function(this)
		if this.hide_for>0 then
			this.hide_for-=1
			if this.hide_for<=0 then
				this.spr=18
				this.delay=0
			end
		elseif this.spr==18 then
			local hit = this.collide(player,0,0)
			if hit ~=nil and hit.spd.y>=0 then
				this.spr=19
				hit.y=this.y-4
				hit.spd.x*=0.2
				hit.spd.y=-3
				hit.djump=max_djump
				this.delay=10
				init_object(smoke,this.x,this.y)
				
				-- breakable below us
				local below=this.collide(fall_floor,0,1)
				if below~=nil then
					break_fall_floor(below)
				end
				
				psfx(8)
			end
		elseif this.delay>0 then
			this.delay-=1
			if this.delay<=0 then 
				this.spr=18 
			end
		end
		-- begin hiding
		if this.hide_in>0 then
			this.hide_in-=1
			if this.hide_in<=0 then
				this.hide_for=60
				this.spr=0
			end
		end
	end
}
add(types,spring)

function break_spring(obj)
	obj.hide_in=15
end

balloon = {
	tile=22,
	init=function(this) 
		this.offset=rnd(1)
		this.start=this.y
		this.timer=0
		this.hitbox={x=-1,y=-1,w=10,h=10}
	end,
	update=function(this) 
		if this.spr==22 then
			this.offset+=0.01
			this.y=this.start+sin(this.offset)*2
			local hit = this.collide(player,0,0)
			if hit~=nil and hit.djump<max_djump then
				psfx(6)
				init_object(smoke,this.x,this.y)
				hit.djump=max_djump
				this.spr=0
				this.timer=60
			end
		elseif this.timer>0 then
			this.timer-=1
		else 
		 psfx(7)
		 init_object(smoke,this.x,this.y)
			this.spr=22 
		end
	end,
	draw=function(this)
		if this.spr==22 then
			spr(13+(this.offset*8)%3,this.x,this.y+6)
			spr(this.spr,this.x,this.y)
		end
	end
}
add(types,balloon)

fall_floor = {
	tile=23,
	init=function(this)
		this.state=0
		this.solid=true
	end,
	update=function(this)
		-- idling
		if this.state == 0 then
			if this.check(player,0,-1) or this.check(player,-1,0) or this.check(player,1,0) then
				break_fall_floor(this)
			end
		-- shaking
		elseif this.state==1 then
			this.delay-=1
			if this.delay<=0 then
				this.state=2
				this.delay=60--how long it hides for
				this.collideable=false
			end
		-- invisible, waiting to reset
		elseif this.state==2 then
			this.delay-=1
			if this.delay<=0 and not this.check(player,0,0) then
				psfx(7)
				this.state=0
				this.collideable=true
				init_object(smoke,this.x,this.y)
			end
		end
	end,
	draw=function(this)
		if this.state!=2 then
			if this.state!=1 then
				spr(23,this.x,this.y)
			else
				spr(23+(15-this.delay)/5,this.x,this.y)
			end
		end
	end
}
add(types,fall_floor)

function break_fall_floor(obj)
 if obj.state==0 then
 	psfx(15)
		obj.state=1
		obj.delay=15--how long until it falls
		init_object(smoke,obj.x,obj.y)
		local hit=obj.collide(spring,0,-1)
		if hit~=nil then
			break_spring(hit)
		end
	end
end

smoke={
	init=function(this)
		this.spr=29
		this.spd.y=-0.1
		this.spd.x=0.3+rnd(0.2)
		this.x+=-1+rnd(2)
		this.y+=-1+rnd(2)
		this.flip.x=maybe()
		this.flip.y=maybe()
		this.solids=false
	end,
	update=function(this)
		this.spr+=0.2
		if this.spr>=32 then
			destroy_object(this)
		end
	end
}

fruit={
	tile=26,
	if_not_fruit=true,
	init=function(this) 
		this.start=this.y
		this.off=0
	end,
	update=function(this)
	 local hit=this.collide(player,0,0)
		if hit~=nil then
		 hit.djump=max_djump
			sfx_timer=20
			sfx(13)
			got_fruit[1+level_index()] = true
			init_object(lifeup,this.x,this.y)
			destroy_object(this)
		end
		this.off+=1
		this.y=this.start+sin(this.off/40)*2.5
	end
}
add(types,fruit)

fly_fruit={
	tile=28,
	if_not_fruit=true,
	init=function(this) 
		this.start=this.y
		this.fly=false
		this.step=0.5
		this.solids=false
		this.sfx_delay=8
	end,
	update=function(this)
		--fly away
		if this.fly then
		 if this.sfx_delay>0 then
		  this.sfx_delay-=1
		  if this.sfx_delay<=0 then
		   sfx_timer=20
		   sfx(14)
		  end
		 end
			this.spd.y=appr(this.spd.y,-3.5,0.25)
			if this.y<-16 then
				destroy_object(this)
			end
		-- wait
		else
			if has_dashed then
				this.fly=true
			end
			this.step+=0.05
			this.spd.y=sin(this.step)*0.5
		end
		-- collect
		local hit=this.collide(player,0,0)
		if hit~=nil then
		 hit.djump=max_djump
			sfx_timer=20
			sfx(13)
			got_fruit[1+level_index()] = true
			init_object(lifeup,this.x,this.y)
			destroy_object(this)
		end
	end,
	draw=function(this)
		local off=0
		if not this.fly then
			local dir=sin(this.step)
			if dir<0 then
				off=1+max(0,sign(this.y-this.start))
			end
		else
			off=(off+0.25)%3
		end
		spr(45+off,this.x-6,this.y-2,1,1,true,false)
		spr(this.spr,this.x,this.y)
		spr(45+off,this.x+6,this.y-2)
	end
}
add(types,fly_fruit)

lifeup = {
	init=function(this)
		this.spd.y=-0.25
		this.duration=30
		this.x-=2
		this.y-=4
		this.flash=0
		this.solids=false
	end,
	update=function(this)
		this.duration-=1
		if this.duration<= 0 then
			destroy_object(this)
		end
	end,
	draw=function(this)
		this.flash+=0.5

		print("1000",this.x-2,this.y,7+this.flash%2)
	end
}

fake_wall = {
	tile=64,
	if_not_fruit=true,
	update=function(this)
		this.hitbox={x=-1,y=-1,w=18,h=18}
		local hit = this.collide(player,0,0)
		if hit~=nil and hit.dash_effect_time>0 then
			hit.spd.x=-sign(hit.spd.x)*1.5
			hit.spd.y=-1.5
			hit.dash_time=-1
			sfx_timer=20
			sfx(16)
			destroy_object(this)
			init_object(smoke,this.x,this.y)
			init_object(smoke,this.x+8,this.y)
			init_object(smoke,this.x,this.y+8)
			init_object(smoke,this.x+8,this.y+8)
			init_object(fruit,this.x+4,this.y+4)
		end
		this.hitbox={x=0,y=0,w=16,h=16}
	end,
	draw=function(this)
		spr(64,this.x,this.y)
		spr(65,this.x+8,this.y)
		spr(80,this.x,this.y+8)
		spr(81,this.x+8,this.y+8)
	end
}
add(types,fake_wall)

key={
	tile=8,
	if_not_fruit=true,
	update=function(this)
		local was=flr(this.spr)
		this.spr=9+(sin(frames/30)+0.5)*1
		local is=flr(this.spr)
		if is==10 and is!=was then
			this.flip.x=not this.flip.x
		end
		if this.check(player,0,0) then
			sfx(23)
			sfx_timer=10
			destroy_object(this)
			has_key=true
		end
	end
}
add(types,key)

chest={
	tile=20,
	if_not_fruit=true,
	init=function(this)
		this.x-=4
		this.start=this.x
		this.timer=20
	end,
	update=function(this)
		if has_key then
			this.timer-=1
			this.x=this.start-1+rnd(3)
			if this.timer<=0 then
			 sfx_timer=20
			 sfx(16)
				init_object(fruit,this.x,this.y-4)
				destroy_object(this)
			end
		end
	end
}
add(types,chest)

platform={
	init=function(this)
		this.x-=4
		this.solids=false
		this.hitbox.w=16
		this.last=this.x
	end,
	update=function(this)
		this.spd.x=this.dir*0.65
		if this.x<-16 then this.x=128
		elseif this.x>128 then this.x=-16 end
		if not this.check(player,0,0) then
			local hit=this.collide(player,0,-1)
			if hit~=nil then
				hit.move_x(this.x-this.last,1)
			end
		end
		this.last=this.x
	end,
	draw=function(this)
		spr(11,this.x,this.y-1)
		spr(12,this.x+8,this.y-1)
	end
}

message={
	tile=86,
	last=0,
	draw=function(this)
		this.text="nothing but pain and#suffering past here#proceed with caution"
		if this.check(player,4,0) then
			if this.index<#this.text then
			 this.index+=0.5
				if this.index>=this.last+1 then
				 this.last+=1
				 sfx(35)
				end
			end
			this.off={x=8,y=96}
			for i=1,this.index do
				if sub(this.text,i,i)~="#" then
					rectfill(this.off.x-2,this.off.y-2,this.off.x+7,this.off.y+6 ,7)
					print(sub(this.text,i,i),this.off.x,this.off.y,0)
					this.off.x+=5
				else
					this.off.x=8
					this.off.y+=7
				end
			end
		else
			this.index=0
			this.last=0
		end
	end
}
add(types,message)

big_chest={
	tile=96,
	init=function(this)
		this.state=0
		this.hitbox.w=16
	end,
	draw=function(this)
		if this.state==0 then
			local hit=this.collide(player,0,8)
			if hit~=nil and hit.is_solid(0,1) then
				music(-1,500,7)
				sfx(37)
				pause_player=true
				hit.spd.x=0
				hit.spd.y=0
				this.state=1
				init_object(smoke,this.x,this.y)
				init_object(smoke,this.x+8,this.y)
				this.timer=60
				this.particles={}
			end
			spr(96,this.x,this.y)
			spr(97,this.x+8,this.y)
		elseif this.state==1 then
			this.timer-=1
		 shake=5
		 flash_bg=true
			if this.timer<=45 and count(this.particles)<50 then
				add(this.particles,{
					x=1+rnd(14),
					y=0,
					h=32+rnd(32),
					spd=8+rnd(8)
				})
			end
			if this.timer<0 then
				this.state=2
				this.particles={}
				flash_bg=false
				new_bg=true
				init_object(orb,this.x+4,this.y+4)
				pause_player=false
			end
			foreach(this.particles,function(p)
				p.y+=p.spd
				line(this.x+p.x,this.y+8-p.y,this.x+p.x,min(this.y+8-p.y+p.h,this.y+8),7)
			end)
		end
		spr(112,this.x,this.y+8)
		spr(113,this.x+8,this.y+8)
	end
}
add(types,big_chest)

orb={
	init=function(this)
		this.spd.y=-4
		this.solids=false
		this.particles={}
	end,
	draw=function(this)
		this.spd.y=appr(this.spd.y,0,0.5)
		local hit=this.collide(player,0,0)
		if this.spd.y==0 and hit~=nil then
		 music_timer=45
			sfx(51)
			freeze=10
			shake=10
			destroy_object(this)
			max_djump=2
			hit.djump=2
		end
		
		spr(102,this.x,this.y)
		local off=frames/30
		for i=0,7 do
			circfill(this.x+4+cos(off+i/8)*8,this.y+4+sin(off+i/8)*8,1,7)
		end
	end
}

flag = {
	tile=118,
	init=function(this)
		this.x+=5
		this.score=0
		this.show=false
		for i=1,count(got_fruit) do
			if got_fruit[i] then
				this.score+=1
			end
		end
	end,
	draw=function(this)
		this.spr=118+(frames/5)%3
		spr(this.spr,this.x,this.y)
		if this.show then
			rectfill(32,2,96,31,0)
			spr(26,55,6)
			print("x"..this.score,64,9,7)
			draw_time(49,16)
			print("deaths:"..deaths,48,24,7)
		elseif this.check(player,0,0) then
			sfx(55)
	  sfx_timer=30
			this.show=true
		end
	end
}
add(types,flag)

room_title = {
	init=function(this)
		this.delay=5
 end,
	draw=function(this)
		this.delay-=1
		if this.delay<-30 then
			destroy_object(this)
		elseif this.delay<0 then
			
			rectfill(24,58,104,70,0)
			--rect(26,64-10,102,64+10,7)
			--print("---",31,64-2,13)
			if room.x==3 and room.y==1 then
				print("old site",48,62,7)
			elseif level_index()==30 then
				print("summit",52,62,7)
			else
				local level=(1+level_index())*100
				print(level.." m",52+(level<1000 and 2 or 0),62,7)
			end
			--print("---",86,64-2,13)
			
			draw_time(4,4)
		end
	end
}

-- object functions --
-----------------------

function init_object(type,x,y)
	if type.if_not_fruit~=nil and got_fruit[1+level_index()] then
		return
	end
	local obj = {}
	obj.type = type
	obj.collideable=true
	obj.solids=true

	obj.spr = type.tile
	obj.flip = {x=false,y=false}

	obj.x = x
	obj.y = y
	obj.hitbox = { x=0,y=0,w=8,h=8 }

	obj.spd = {x=0,y=0}
	obj.rem = {x=0,y=0}

	obj.is_solid=function(ox,oy)
		if oy>0 and not obj.check(platform,ox,0) and obj.check(platform,ox,oy) then
			return true
		end
		return solid_at(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
		 or obj.check(fall_floor,ox,oy)
		 or obj.check(fake_wall,ox,oy)
	end
	
	obj.is_ice=function(ox,oy)
		return ice_at(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
	end
	
	obj.collide=function(type,ox,oy)
		local other
		for i=1,count(objects) do
			other=objects[i]
			if other ~=nil and other.type == type and other != obj and other.collideable and
				other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x+ox and 
				other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y+oy and
				other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w+ox and 
				other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h+oy then
				return other
			end
		end
		return nil
	end
	
	obj.check=function(type,ox,oy)
		return obj.collide(type,ox,oy) ~=nil
	end
	
	obj.move=function(ox,oy)
		local amount
		-- [x] get move amount
 	obj.rem.x += ox
		amount = flr(obj.rem.x + 0.5)
		obj.rem.x -= amount
		obj.move_x(amount,0)
		
		-- [y] get move amount
		obj.rem.y += oy
		amount = flr(obj.rem.y + 0.5)
		obj.rem.y -= amount
		obj.move_y(amount)
	end
	
	obj.move_x=function(amount,start)
		if obj.solids then
			local step = sign(amount)
			for i=start,abs(amount) do
				if not obj.is_solid(step,0) then
					obj.x += step
				else
					obj.spd.x = 0
					obj.rem.x = 0
					break
				end
			end
		else
			obj.x += amount
		end
	end
	
	obj.move_y=function(amount)
		if obj.solids then
			local step = sign(amount)
			for i=0,abs(amount) do
	 		if not obj.is_solid(0,step) then
					obj.y += step
				else
					obj.spd.y = 0
					obj.rem.y = 0
					break
				end
			end
		else
			obj.y += amount
		end
	end

	add(objects,obj)
	if obj.type.init~=nil then
		obj.type.init(obj)
	end
	return obj
end

function destroy_object(obj)
	del(objects,obj)
end

function kill_player(obj)
	sfx_timer=12
	sfx(0)
	deaths+=1
	shake=10
	destroy_object(obj)
	dead_particles={}
	for dir=0,7 do
		local angle=(dir/8)
		add(dead_particles,{
			x=obj.x+4,
			y=obj.y+4,
			t=10,
			spd={
				x=sin(angle)*3,
				y=cos(angle)*3
			}
		})
		restart_room()
	end
end

-- room functions --
--------------------

function restart_room()
	will_restart=true
	delay_restart=15
end

function next_room()
 if room.x==2 and room.y==1 then
  music(30,500,7)
 elseif room.x==3 and room.y==1 then
  music(20,500,7)
 elseif room.x==4 and room.y==2 then
  music(30,500,7)
 elseif room.x==5 and room.y==3 then
  music(30,500,7)
 end

	if room.x==7 then
		load_room(0,room.y+1)
	else
		load_room(room.x+1,room.y)
	end
end

function load_room(x,y)
	has_dashed=false
	has_key=false

	--remove existing objects
	foreach(objects,destroy_object)

	--current room
	room.x = x
	room.y = y

	-- entities
	for tx=0,15 do
		for ty=0,15 do
			local tile = mget(room.x*16+tx,room.y*16+ty);
			if tile==11 then
				init_object(platform,tx*8,ty*8).dir=-1
			elseif tile==12 then
				init_object(platform,tx*8,ty*8).dir=1
			else
				foreach(types, 
				function(type) 
					if type.tile == tile then
						init_object(type,tx*8,ty*8) 
					end 
				end)
			end
		end
	end
	
	if not is_title() then
		init_object(room_title,0,0)
	end
end

-- update function --
-----------------------

function _update()
	frames=((frames+1)%30)
	if frames==0 and level_index()<30 then
		seconds=((seconds+1)%60)
		if seconds==0 then
			minutes+=1
		end
	end
	
	if music_timer>0 then
	 music_timer-=1
	 if music_timer<=0 then
	  music(10,0,7)
	 end
	end
	
	if sfx_timer>0 then
	 sfx_timer-=1
	end
	
	-- cancel if freeze
	if freeze>0 then freeze-=1 return end

	-- screenshake
	if shake>0 then
		shake-=1
		camera()
		if shake>0 then
			camera(-2+rnd(5),-2+rnd(5))
		end
	end
	
	-- restart (soon)
	if will_restart and delay_restart>0 then
		delay_restart-=1
		if delay_restart<=0 then
			will_restart=false
			load_room(room.x,room.y)
		end
	end

	-- update each object
	foreach(objects,function(obj)
		obj.move(obj.spd.x,obj.spd.y)
		if obj.type.update~=nil then
			obj.type.update(obj) 
		end
	end)
	
	-- start game
	if is_title() then
		if not start_game and (btn(k_jump) or btn(k_dash)) then
			music(-1)
			start_game_flash=50
			start_game=true
			sfx(38)
		end
		if start_game then
			start_game_flash-=1
			if start_game_flash<=-30 then
				begin_game()
			end
		end
	end
end

-- drawing functions --
-----------------------
function _draw()
	if freeze>0 then return end
	
	-- reset all palette values
	pal()
	
	-- start game flash
	if start_game then
		local c=10
		if start_game_flash>10 then
			if frames%10<5 then
				c=7
			end
		elseif start_game_flash>5 then
			c=2
		elseif start_game_flash>0 then
			c=1
		else 
			c=0
		end
		if c<10 then
			pal(6,c)
			pal(12,c)
			pal(13,c)
			pal(5,c)
			pal(1,c)
			pal(7,c)
		end
	end

	-- clear screen
	local bg_col = 0
	if flash_bg then
		bg_col = frames/5
	elseif new_bg~=nil then
		bg_col=2
	end
	rectfill(0,0,128,128,bg_col)

	-- clouds
	if not is_title() then
		foreach(clouds, function(c)
			c.x += c.spd
			rectfill(c.x,c.y,c.x+c.w,c.y+4+(1-c.w/64)*12,new_bg~=nil and 14 or 1)
			if c.x > 128 then
				c.x = -c.w
				c.y=rnd(128-8)
			end
		end)
	end

	-- draw bg terrain
	map(room.x * 16,room.y * 16,0,0,16,16,4)

	-- platforms/big chest
	foreach(objects, function(o)
		if o.type==platform or o.type==big_chest then
			draw_object(o)
		end
	end)

	-- draw terrain
	local off=is_title() and -4 or 0
	map(room.x*16,room.y * 16,off,0,16,16,2)
	
	-- draw objects
	foreach(objects, function(o)
		if o.type~=platform and o.type~=big_chest then
			draw_object(o)
		end
	end)
	
	-- draw fg terrain
	map(room.x * 16,room.y * 16,0,0,16,16,8)
	
	-- particles
	foreach(particles, function(p)
		p.x += p.spd
		p.y += sin(p.off)
		p.off+= min(0.05,p.spd/32)
		rectfill(p.x,p.y,p.x+p.s,p.y+p.s,p.c)
		if p.x>128+4 then 
			p.x=-4
			p.y=rnd(128)
		end
	end)
	
	-- dead particles
	foreach(dead_particles, function(p)
		p.x += p.spd.x
		p.y += p.spd.y
		p.t -=1
		if p.t <= 0 then del(dead_particles,p) end
		rectfill(p.x-p.t/5,p.y-p.t/5,p.x+p.t/5,p.y+p.t/5,14+p.t%2)
	end)
	
	-- draw outside of the screen for screenshake
	rectfill(-5,-5,-1,133,0)
	rectfill(-5,-5,133,-1,0)
	rectfill(-5,128,133,133,0)
	rectfill(128,-5,133,133,0)
	
	-- credits
	if is_title() then
		print("x+c",58,80,5)
		print("matt thorson",42,96,5)
		print("noel berry",46,102,5)
		print("mod by pikiktheyeet", 29, 114, 5)
	end
	
	if level_index()==30 then
		local p
		for i=1,count(objects) do
			if objects[i].type==player then
				p = objects[i]
				break
			end
		end
		if p~=nil then
			local diff=min(24,40-abs(p.x+4-64))
			rectfill(0,0,diff,128,0)
			rectfill(128-diff,0,128,128,0)
		end
	end

end

function draw_object(obj)

	if obj.type.draw ~=nil then
		obj.type.draw(obj)
	elseif obj.spr > 0 then
		spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
	end

end

function draw_time(x,y)

	local s=seconds
	local m=minutes%60
	local h=flr(minutes/60)
	
	rectfill(x,y,x+32,y+6,0)
	print((h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s),x+1,y+1,7)

end

-- helper functions --
----------------------

function clamp(val,a,b)
	return max(a, min(b, val))
end

function appr(val,target,amount)
 return val > target 
 	and max(val - amount, target) 
 	or min(val + amount, target)
end

function sign(v)
	return v>0 and 1 or
								v<0 and -1 or 0
end

function maybe()
	return rnd(1)<0.5
end

function solid_at(x,y,w,h)
 return tile_flag_at(x,y,w,h,0)
end

function ice_at(x,y,w,h)
 return tile_flag_at(x,y,w,h,4)
end

function tile_flag_at(x,y,w,h,flag)
 for i=max(0,flr(x/8)),min(15,(x+w-1)/8) do
 	for j=max(0,flr(y/8)),min(15,(y+h-1)/8) do
 		if fget(tile_at(i,j),flag) then
 			return true
 		end
 	end
 end
	return false
end

function tile_at(x,y)
 return mget(room.x * 16 + x, room.y * 16 + y)
end

function spikes_at(x,y,w,h,xspd,yspd)
 for i=max(0,flr(x/8)),min(15,(x+w-1)/8) do
 	for j=max(0,flr(y/8)),min(15,(y+h-1)/8) do
 	 local tile=tile_at(i,j)
 	 if tile==17 and ((y+h-1)%8>=6 or y+h==j*8+8) and yspd>=0 then
 	  return true
 	 elseif tile==27 and y%8<=2 and yspd<=0 then
 	  return true
 		elseif tile==43 and x%8<=2 and xspd<=0 then
 		 return true
 		elseif tile==59 and ((x+w-1)%8>=6 or x+w==i*8+8) and xspd>=0 then
 		 return true
 		end
 	end
 end
	return false
end
__gfx__
000000000000000000000000088888800000000000000000000000000000000000aaaaa0000aaa000000a0000007707770077700000060000000600000060000
000000000888888008888880888888880888888008888800000000000888888000a000a0000a0a000000a0000777777677777770000060000000600000060000
000000008888888888888888888ffff888888888888888800888888088f1ff1800a909a0000a0a000000a0007766666667767777000600000000600000060000
00000000888ffff8888ffff888f1ff18888ffff88ffff8808888888888fffff8009aaa900009a9000000a0007677766676666677000600000000600000060000
0000000088f1ff1888f1ff1808fffff088f1ff1881ff1f80888ffff888fffff80000a0000000a0000000a0000000000000000000000600000006000000006000
0000000008fffff008fffff00033330008fffff00fffff8088fffff8083333800099a0000009a0000000a0000000000000000000000600000006000000006000
00000000003333000033330007000070073333000033337008f1ff10003333000009a0000000a0000000a0000000000000000000000060000006000000006000
000000000070070000700070000000000000070000007000077333700070070000aaa0000009a0000000a0000000000000000000000060000006000000006000
555555550000000000000000000000000000000000000000008888004999999449999994499909940300b0b0666566650300b0b0000000000000000070000000
55555555000000000000000000000000000000000000000008888880911111199111411991140919003b330067656765003b3300007700000770070007000007
550000550000000000000000000000000aaaaaa00000000008788880911111199111911949400419028888206770677002888820007770700777000000000000
55000055007000700499994000000000a998888a1111111108888880911111199494041900000044089888800700070078988887077777700770000000000000
55000055007000700050050000000000a988888a1000000108888880911111199114094994000000088889800700070078888987077777700000700000000000
55000055067706770005500000000000aaaaaaaa1111111108888880911111199111911991400499088988800000000008898880077777700000077000000000
55555555567656760050050000000000a980088a1444444100888800911111199114111991404119028888200000000002888820070777000007077007000070
55555555566656660005500004999940a988888a1444444100000000499999944999999444004994002882000000000000288200000000007000000000000000
5777777557777777777777777777777577cccccccccccccccccccc775777777555555555555555555555555555000000aaaaaaaa000000000000000000000000
77777777777777777777777777777777777cccccccccccccccccc7777777777755555555555555500555555566700000a49494a1000777770000000000000000
777c77777777ccccc777777ccccc7777777cccccccccccccccccc7777777777755555555555555000055555567777000a494a4a1007766700000000000000000
77cccc77777cccccccc77cccccccc7777777cccccccccccccccc7777777cc77755555555555550000005555566600000a49444aa076777000000000000000000
77cccc7777cccccccccccccccccccc777777cccccccccccccccc777777cccc7755555555555500000000555555000000a49999aa077660000777770000000000
777cc77777cc77ccccccccccccc7cc77777cccccccccccccccccc77777cccc7755555555555000000000055566700000a4944499077770000777767007700000
7777777777cc77cccccccccccccccc77777cccccccccccccccccc77777c7cc7755555555550000000000005567777000a494a444000000000000007700777770
5777777577cccccccccccccccccccc7777cccccccccccccccccccc7777cccc7755555555500000000000000566600000a4949999000000000000000000077777
77cccc7777cccccccccccccccccccc77577777777777777777777775777ccc7755555555500000000000000500000666aaaaaaaa000000000000000000000000
777ccc7777cccccccccccccccccccc77777777777777777777777777777cc777505555555500000000000055000777761a44949a0000000000ee0ee000000000
777ccc7777cc7cccccccccccc77ccc777777ccc7777777777ccc7777777cc777555500555550000000000555000007661a44a49a0000000000eeeee000000030
77ccc77777ccccccccccccccc77ccc77777ccccc7c7777ccccccc77777ccc77755550055555500000000555500000055aa44449a00000000000e8e00000000b0
77ccc777777cccccccc77cccccccc777777ccccccc7777c7ccccc77777cccc7755555555555550000005555500000666aa99999a0000b00000eeeee000000b30
777cc7777777ccccc777777ccccc77777777ccc7777777777ccc777777cccc77550555555555550000555555000777769944449a000b000000ee3ee003000b00
777cc777777777777777777777777777777777777777777777777777777cc777555555555555555005555555000007664444a49a030b00300000b00000b0b300
77cccc7757777777777777777777777557777777777777777777777557777775555555555555555555555555000000559999949a030330300000b00000303300
5777777777777775077777777777777777777770077777700000000000000000cccccccc00000000000000000000000000000000000000000000000000000000
7777777777777777700007770000777000007777700077770000000000000000c77ccccc00000000000000000000000000000000000000000000000000000000
7777cccccccc777770cc777cccc777ccccc7770770c777070000000000000000c77cc7cc00000000000000000000000000000000000000000000000000000000
777cccccccccc77770c777cccc777ccccc777c0770777c070000000000000000cccccccc00000000000000000000000000006000000000000000000000000000
77cccccccccccc77707770000777000007770007777700070002eeeeeeee2000cccccccc00000000000000000000000000060600000000000000000000000000
77cc77ccccc7cc7777770000777000007770000777700007002eeeeeeeeee200cc7ccccc00000000000000000000000000000000000000000000000000000000
77cc77cccccccc777000000000000000000c000770000c0700eeeeeeeeeeee00ccccc7cc06600666066606060660066000666006000000000000000000000000
77cccccccccccc777000000000000000000000077000000700e22222e2e22e00cccccccc06060600006006060606060600060060600000000000000000000000
77cccccccccccc777000000000000000000000077000000700eeeeeeeeeeee000000000006600666006006060660060600060060600600000000000000000000
77cccccccccccc777000000c000000000000000770cc000700e22e2222e22e0000000000060606000060060606060606000600606060d0000000000000000000
77cc7cccc77ccc7770000000000cc0000000000770cc000700eeeeeeeeeeee0000000000060606660060006006060606000600060d000d000000000000000000
77ccccccc77ccc7770c00000000cc00000000c0770000c0700eee222e22eee0000000000000000000000000000000c0000000000000000000000000000000000
777cccccccccc7777000000000000000000000077000000700eeeeeeeeeeee005555555506666600666666006600c00066666600066666006666660066666600
7777cccccccc777770000000000000000000000770c0000700eeeeeeeeeeee00555555556666666066666660660c000066666660666666606666666066666660
777777777777777770000000c0000000000000077000000700ee77eee7777e005555555566000660660000006600000066000000660000000066000066000000
57777777777777757000000000000000000000077000c007077777777777777055555555dd000000dddd0000dd000000dddd0000ddddddd000dd0000dddd0000
000000000000000070000000000000000000000770000007007777005000000000000005dd000dd0dd000000dd0000d0dd000000000000d000dd0000dd000000
00aaaaaaaaaaaa00700000000000000000000007700c0007070000705500000000000055ddddddd0dddddd00ddddddd0dddddd00ddddddd000dd0000dddddd00
0a999999999999a0700000000000c00000000007700000077077000755500000000005550ddddd00ddddddd0ddddddd0ddddddd00ddddd0000dd0000ddddddd0
a99aaaaaaaaaa99a7000000cc0000000000000077000cc077077bb07555500000000555500000000000000000000000000000000000000000000000000000000
a9aaaaaaaaaaaa9a7000000cc0000000000c00077000cc07700bbb0755555555555555550000000000000c000000000000000000000000000000c00000000000
a99999999999999a70c00000000000000000000770c00007700bbb075555555555555555000000000000c00000000000000000000000000000000c0000000000
a99999999999999a700000000000000000000007700000070700007055555555555555550000000000cc0000000000000000000000000000000000c000000000
a99999999999999a07777777777777777777777007777770007777005555555555555555000000000c000000000000000000000000000000000000c000000000
aaaaaaaaaaaaaaaa0777777777777777777777700777777000488800004800000040088800000000c0000000000000000000000000000000000000c000000000
a49494a11a49494a700077700000777000007777700077770048888800488000004888880000000100000000000000000000000000000000000000c00c000000
a494a4a11a4a494a70c777ccccc777ccccc7770770c77707042008880428888804288800000000c0000000000000000000000000000000000000001010c00000
a49444aaaa44494a70777ccccc777ccccc777c0770777c07040000000400888004000000000001000000000000000000000000000000000000000001000c0000
a49999aaaa99994a7777000007770000077700077777000704000000040000000400000000000100000000000000000000000000000000000000000000010000
a49444999944494a77700000777000007770000777700c0742000000420000004200000000000100000000000000000000000000000000000000000000001000
a494a444444a494a7000000000000000000000077000000740000000400000004000000000000000000000000000000000000000000000000000000000000000
a49499999999494a0777777777777777777777700777777040000000400000004000000000010000000000000000000000000000000000000000000000000010
b1b1b1b100b1b1b1b142525252528452339200001323232352232323232352230000000000000000b30200001323235252622444b2b313525223232323232323
11110011000000a20182920013232352363636462535353545550000b35525355284525262b20000000000004252525252525262000042525252845252525252
00000000000000000042845252525252b1006100b1b1b1b103b1b1b1b1b103b10000000000000011110200000000b3425233264611a2b1133300009200008392
4363b302b200110000a2000000000042b1b1b1b12636363646550000b35525355252528462b20000000000004252845252232333000013232323232352528452
000000000000a201821323525284525200000000000000007300000000007300000000000000b343536311410000b3136227373747b20000000000000000a200
b1b100b172b302b20021b3435363a24200000000b1b1b1b1b156b200b35526365252522333b211111111110242525252620400720000b1b1b100a28213525252
0000000000000000a282b342525252840000000000001100b10000001100b1000000000000000000b3435363000000b162273737373737373737374711000000
0000001173b2b111b302b2b1b1b16142000000000000000000b10000b356b1b1525233b1b1b1b1b1b11222225252525262000003b20011111100008283425252
0000000000000093a382b3425252525200006100001102b20000001102b200001100000000000000000000020000001152222222222222222222222232b20000
0000b302b2000002b2b100001111111300000000000000009300000000b100008462b20000000000b21323235284525262000003b211243444b200a282425284
00000000000000a28283b3428452525200000000b302b2000000b302b20061007293a30000000000000000b10082931252845252525252232323232362b20000
000000b100000011000000b3435363b20000000093000086820000a3000000005262b200000000b372b200b313232323620000731124353545b200b312525252
000000000000000082c1b3132323232311111111111111111111111172b20000738283931100000000000011a382821323232323528462b1b1b1b1b173b20061
000000000000b302b2000061b1b1b1000000a3858282868282828282930000005262b200000000b303b200b372b2b1b1621111123226363646b211b342525252
11111111111111a3828200b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b103b20000b100a282721100000000b372828283b122222232132333000000869200000000
00100000000000b1000000000000000086938282828201920000a20182a376865262b200000000b303b200b303b2000062b1b1425232b2b1b1b1b1b342845252
12223212222232b2838200000000000011111111111111111111111103b261001100a382737200000000b373a282921152528462b1b1b1000000a20000000000
00021111111111111111111111110061828282a28382820000000000828282825262b200000000b303b2001173b20000626161425262b200000000b342525252
13233313235252225353536300000000b1b1b1b1b1b1b1b1b1b1b1b173b2000072828292b1030000000000b100a2821252235262b2000000000000a300000000
00435363b1435353535353535363b2008282920082829200647400a3828382a28462b200000000b303b21102b1000000620000425262b2000000000042525252
b1b1b1b1b1132362b1b1b100000000009200000000a28282828293b372b200007382010011030000000000110082821362101333610000000000008293000000
0002123280123202123200417272b20083820000a282111165751111829200005262b20000000011731102b1000000006200004252620000b312223213528452
0000000000b1b303b2000000002100000000000000000082828282b303b20000b1a28283720311110000b372b28292b162710000000000009300008382000000
00b11333b11333b1133311117373b200828293000011122232122232821111112333b2000000b3435363b10011000000331111132333b200b342525232135252
000000000000b373b2000000b372b2000010000000111111118283b373b200a30000828273034363b283b3731111111162930000000000008200008282920000
000000006100000000006100000061000192000000021323334284621124343400000000000000b1b1b1001172b20000b2b1b1b1b1b10000b342528452321323
0000100000000082000000a2b303b2002222321111125353630182829200008300009200b1036172b282b3435353631262829200000000a38292008282000000
11111111111111111111111111111100111110000004b3122252525232253535000000f3100000111111110203b20000b200000000009300b342525252522222
123212223200008393210086b303b200528452220400c000a28282820000a38210000000a3738073b28293b1b1b1b11362b20000000000828300a38201000000
1222222222222222222222222222320034343434441111425252525262253535000000126300b343535363b103b2c1001110111100a38200b342525252845252
1333425262008682b372b282b303b20052525252000000000082829200008282320000008382930000a28201820000b162b293000000008282008282829300c1
425252525252525252525252525262003535353545122252525252846225353500000003244400b1b1b1b1b303b200002222223201828393b342525252525252
52525252525252525252525252526200845223232323232352522323233300005252525252525252525284522333b282232323232352525262b200b342525252
52845252525252848452525262b28242528452525233000000425223232352520000000000000000000000000000000000000000000000000000000000000000
5252528452522323232323232352620023338276000000824233b20000000000525252845252232323235262b1b10083921000a38242525262b200b342232323
23232323232323232323235262b282135252525262b1001111133383828242840000000000000000000000000000000000000000000000000000000000000000
525252525262b2b1b1b1b1b1b142627682828392000011a273b20000b3720000525252525233b1b1b1b1133300000082535353638242525262b200b30382a2a2
c1729200a28283828201824262b2a2835252525262b2b31232b2000000014252000000000000a300000000000000000000000000000000000000000000000000
528452232333b20000001100824262928201a20000b3720092000000b30300002323525262b200000000b3720000a382828283828242525262b200b373928000
b30300110092a2829211a21333b2a3825252525262b2b31333b20000868242520000000000000100009300000000000000000000000000000000000000000000
525262122232b20000b372b2a24262838292000000b3030000000000b30300002232132333b200000000b303829300a2838292019242845262b2000000b1b100
b303b302b2116100b302b200110000005252525262b200b1b10000a283a2425200000000a30082000083000000000000000000000094a4b4c4d4e4f400000000
525262428462b20000b303b2214262928300000000b3030000000000b303004152523204020000000000b30392000000829200000042525262b2000000000000
b30300b11232b20000b100b302b211615252525262b200000000000092b3428400000000827682000001009300000000000000000095a5b5c5d5e5f500000000
232333132362b22100b303b2711333008293001100b30311111111111103111152526200b3b2000011000003b2000000001111111142528462b2000000000000
b30300b31333110000001100b1b3020084525252621100000000000000b3135200000000828382670082768200000000000000000096a6b6c6d6e6f600000000
43631100a203117200b303b2410000118282b3435353235353536312225222225252522232b2000072000003b2000000114353535323235262b2000011000000
b3030000b1b3021100b372b26100b100525252525232b20000000000b304b34200000000a28282123282839200000000000000000097a7b7c7d7e7f700000000
b1b172b200135362b2b313535353535392000000000000000000b3425252525223232323620061000300000300000000b1b1b1b1b1b1b34262b200b372b20000
b30300000000b172b2b373b200000000232323232333b20000111161b311b342000000868382125252328293a300000000000000000000000000000000000000
00b303b200a28303b200b1b1b1b1b1b3000000000000000000b3125252525252b1b1b1b1730000000300000361000000000000000000b31333b271b303b20000
b373b2110000b373b200b100000000a3b1b1b1b1b1b102111112321100b1b342000000a282125284525232828386000000000000000000000000000000000000
80b303b20000820311111111008283b3111111111100000000b3425252528452000000b3021111110300b30300000000000000000000b3b24111111103b20000
00b1b302b200b372b200000000000082b21000000000b31222525232b200b3138585868292425252525262018282860000000000000000000000000000000000
00b373b20000a21353535363008292b32222222232111172b2b3132323235252000000b343535363030000030000000011111111930011122222222233b20000
100000b10000b303b200000000858682b27100000000b31323232333b20000b182018283001323525284629200a2820000000000000000000000000000000000
b1b1b100000000b1b1b1b1b100a200b32323232323537273b200b1b1b1b1425200000000b1b1b1b103b2007300000000222222328283432323232333b2000000
329300000000b373b200000000a2018211111111000000b1b1b1b1b16100000000a28293f3123242522333020000820000000000000000000000000000000000
829200001000000000000000000000b3b110d30000b373b2000000000000425200000086827600b303000082760000005252526200828200a30182a2006100a3
62820000000000b100000093a382838222225363b211111111111111000000860000122222526213331222328293827600000000000000000000000000000000
017685a31222321111111111002100b3222232b20000b1000000000080a342521000a383829200b373000083920000005284526200a282828283920000000082
62839321000000000000a382828282015262a1b3b212222222222232111111111000135252845222225252523201838200000000000000000000000000000000
828382824252522222222232007100b3525262b2000000000000000000831323320001828200000083000082010000005252526271718283820000000000a382
628201729300000000a282828382828252522232b242525252525262122222321222324252525252525284525222223200000000000000000000000000000000
__gff__
0000000000000000000000000000000004020000000000000000000200000000030303030303030304040402020000000303030303030303040404020202020200001313131302020302020202020002000013131313020204020202020202020000131313130004040202020202020200001313131300000002020202020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2331252548252532323232323300002425262425252631323232252628282824252525252525323328382828312525253232323233000000313232323232323232330000002432323233313232322525252525482526403b242525262b3b24252548252525262828282824254825252526282828283132323225482525252525
252331323232332900002829000000242526313232332828002824262a102824253225252526002a282829281b244825282828290000000027282900000000002827000000371b1b1b1b1b1b1b1b31482525252525262b3b313232332b3b242525254825323338282a283132252548252628382828112a2a2831323232322525
252523201028380000002a0000003b24252523201028292900282426003a382433083148252600002900002a0031252528382900003a676830280000000000003830393e003a28000000000000003b242525323232332b3b212222232b3b2425252532332828282900002a283132252526282828282011002a282828383b2448
323233282828290000000000001111244825262828290000002a242600002a242b003b313233000000000000001b3125290000000034353637280000000000002a373435353629000000000000003b242526212223202b3b313232332b3b242548262b000000000000000000003b242526282800001b201111112828283b2425
2321233828293a2839000000002021252548262900000000000024262b00002436002000143b3f000000000000001b310000000000003b2b282839000000000000102828282900000000111100003b313233242526201111202828282838242525262b000000000000000000003b2425262a282811001b3435362838283b2425
263133282810282900000000000024252525260000000011000024262b003e24001b002021222300000000000000001b0000001c0000272828290000000000002a28282900000000000021232b3828292828313233282829002a002a2828242525332b0c00000011110000000c3b3148261111112011001b1b1b2828283b2425
252320282828280000000000003a24252525262b3a3900272b3b24262b3b21250000000024252611111111000000000011111111111131362800000000170000002a000000001111000024262b28290028281b1b1b282800000000002a2125482611111111113b34362b1c1111111124252222232b2011111111281100113132
2533382828290000000000000028242525252620102900302b3b31332b3b24480000003a313232353535366758001111343535353536212300000000000000000000000000003436003a2426112800003828390000002a290000000000313232261b1b1b1b1b1b1b1b1b1b1b1b1b1b24253232332b1b343535363b2700272b00
2600002a28000000003a283a282824252525252328393b372b001b1b003b3132000000282828281b27271b28283921221b1b1b1b1b1b24262b00000000000000000000000000202b0028312523000000282828290000000000003a67682828003339000b0000003a383900000b000031331b1b1b28281b1b1b1b3b3000302b00
330000002867586061281028282824252525482628283b2b00000000003b212200003a283828103b31332b2838282425000000003a3824262b00000017000000000000000000272b002a283133390000282900000000000000002a28282829002a2839000000002a2829000000000000282828382828282828283b3000302b00
0000003a28283870712828283828242548252526002a28272b001111113432320000002a282828001b1b002810282425000000002a2824260000000000000000000000000000372b0000002a28283900280000003928390000000000282800000028290000002a2828000000000000002a2828282810282828283b3000302b00
0000002838282821232838212223242532322526003a28302b3b21222222222200000000002a281111111128282824480000003a282831332b0000000000000000013f0000002011111100003828000028013a28281028580000003a28290000002a28000000003a380000000000000000002a282828282829283b3000302b1a
00013a21232123313340003132332425002831263a383b302b3b2425252525250000000000002834222236292a0024253e013a3828292a000000000000000000353535361111203435362b3d2a28671422222328282828283900582838390000003a290000000028280b00000000000000002a28282a290000583b3712372b28
22222225262426212300002122222525002a383728293b30111131323232323200013f0000002a282426290000002425222222232900000000000000171700002a28202b1134361b1b1b0034353535352525252223002a2828282810282839000b10000000000b28100000000b0000000000002838000000002a281b001b0028
2548252526313324252222252525482500012a2828673f242222231c21222223222223000012002a2426000000122425252525260000000017170000000000000038202b3b3b3b0800003b2720282828254825252600002a28282828382828393a28013d000000682839000000000000000168282800170000003a2800003a28
25252525252222252525252525252525222222222222222525482667242525262548260000270000242600000021252525254826171700000000000000000000002a202b0000273435363b37202828282525252526000000002a2828282828282821222300000028282800000000000022222223286700000000282839002838
262b003132324832323232323232252525252525262b3b24253232323225482525323232323232322526282828244825252525332b0000000000000000000052252532323232333132323232332b00002628292867000000000000003132323225252532332b003b312525482525254825254826283828313232323232322548
262b001b00003021232828282828242525482525262b3b313338282900313225262800001608282831332828382425254825262b00000000000000000000005225262b1b1b1b1b1b1b1b1b1b1b00000026281a382039110000000000000000002525262b1b0000003b2425323232323232323233282828282828102828203125
262b001100003731332a3828002a242525252525262b003b3b292a0000002a313328111111282828000028002a3125252525262b00000000000000000000115225262b0016001111000000000011111126283a282011201111112122232b00002525262b000000003b24262b002a2a38282828282829002a2800282838282831
3311112700000000000028283900244825252532332b003b3b00000000000000381021222311111111111111002a24253232332b00000000000000000011420025262b00003b21232b0000003b212222252222232122232122232448262b00003232332b000000003b31332b00000028102829000000000029002a2828282900
3435363700000000162a28282800242525252627272b3b3436000000000000002834252533343535353535361111242522232b000000003a390011111142535325262b00003b24262b0016003b242525252548263132333132332425262b00002222232b000000000028290000000000283800111100001200000028292a1600
1b1b1b1b0000000000003a282900242548252637372b3b343536270000001100293b2426283900000000003b2122252525262b0000003e28283e42434353636332332b39003b2426111111111124252525482526201b1b1b1b1b2425262b00002525262b00000014112900000000000028293b401b0000170000112867000000
2828286758000000586828380000313232323320272b16000000300000271b27003b2426290000000000003b3125482525330000003b212222235253536400001b1b2a28383b3132353535352225482525252525232b0000003b3132332b00004825261111113435361111111100000000003b1111111111111127282900003b
2828282810290000002a28286700002835353536371111110000371111300030003b3133000000000000002a28313225262b0000003b242525266263640000000016002828282900000000003132252525252525262b0000003b202b1b0000002525323535352222222222353600000000003b3435353535353630380000003b
282900002a0000000000382a29003a2828282834362034360000343620301a3000002a160000111100000000282828312600000000002448252523000000000039003a2829000000000000000028313225254825262b0000003b172b0000000032331b1b1b3b24482525261b1b00000000003b201b1b1b1b1b1b30280000003b
283a0000000000000000280000002828283810292a000000000000002a3711371111111111112136000000002a283800262b000000212525252526001c0000002828281000000000001100002a38282925252525262b0000003b172b003b21221b1b0008003b24252548262b000012000000001b00000000000030290000003b
3829000000000000003a102900002838282828000000000000000000002a1b0022353535353533000000000000282839330000003b313225252533000000000028382829000000003b202b006828280032323232332b000000001b00003b312511110011113b31323225262b0000170000000000000000110000370000000000
290000000000000000002a000000282928292a0000000000000000000000282a332838282829000000000000001028280000000042434424252628390000000028002a11111111111111002a201029001b1b1b1b1b00000000000000000010311b1b161b1b001b1b1b31332b106700000000001100003b272b001b0000000000
00000100000011111100000000002a3a2a0000000000000000000000002a2800282829002a000000000000000028282800000000525354244826282800000000293b2b1b1b20343535362b0029000000000000000000000000000000000028282800000000000000001b1b2a2829000001003b272b003b302b00000000000000
1111201111112122230000001212002a00010000000000000000000000002900290000000000001400002a6768282900001101115253542425262810673a3900013b2b00002a38293b202b000000002101000000000000003a67000000002a382867586800000100000000682800000021233b372b003b300000000000000000
22222222222324482611111140001111002739000017170000001717000000000001000000001717000000282838393a0021222352535424253328282838290022232b00000828393b272b0000001424232b00001200000028290000000000282828102867001717171717282839000031333b272b123b370000000000000000
254825252526242526212222222222223a303800000000000000000000000000001717000000000000003a28282828280024252652535424262828282828283925262b00003a28103b302b0000212225262b003b272b003a28000000000000282838282828390000005868283828000022233b302b173b270000000000000000
__sfx__
0102000036370234702f3701d4702a37017470273701347023370114701e3700e4701a3600c46016350084401233005420196001960019600196003f6003f6003f6003f6003f6003f6003f6003f6003f6003f600
0002000011070130701a0702407000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d07010070160702207000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000642008420094200b420224402a4503c6503b6503b6503965036650326502d6502865024640216401d6401a64016630116300e6300b62007620056100361010600106000060000600006000060000600
000400000f0701e070120702207017070260701b0602c060210503105027040360402b0303a030300203e02035010000000000000000000000000000000000000000000000000000000000000000000000000000
000300000977009770097600975008740077300672005715357003470034700347003470034700347003570035700357003570035700347003470034700337003370033700337000070000700007000070000700
00030000241700e1702d1701617034170201603b160281503f1402f120281101d1101011003110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000101101211014110161101a120201202613032140321403410000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000070700a0700e0701007016070220702f0702f0602c0602c0502f0502f0402c0402c0302f0202f0102c000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000005110071303f6403f6403f6303f6203f6103f6153f6003f6003f600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
031000200177500605017750170523655017750160500605017750060501705076052365500605017750060501775017050177500605236550177501605006050177500605256050160523655256050177523655
002000001d0401d0401d0301d020180401804018030180201b0301b02022040220461f0351f03016040160401d0401d0401d002130611803018030180021f061240502202016040130201d0401b0221804018040
00100000070700706007050110000707007060030510f0700a0700a0600a0500a0000a0700a0600505005040030700306003000030500c0700c0601105016070160600f071050500a07005050030510a0700a060
000400000c5501c5601057023570195702c5702157037570285703b5702c5703e560315503e540315303e530315203f520315203f520315103f510315103f510315103f510315103f50000500005000050000500
000400002f7402b760267701d7701577015770197701c750177300170015700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000096450e655066550a6550d6550565511655076550c655046550965511645086350d615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000001f37518375273752730027300243001d300263002a3001c30019300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011000002953429554295741d540225702256018570185701856018500185701856000500165701657216562275142753427554275741f5701f5601f500135201b55135530305602454029570295602257022560
011000200a0700a0500f0710f0500a0600a040110701105007000070001107011050070600704000000000000a0700a0500f0700f0500a0600a0401307113050000000000013070130500f0700f0500000000000
002000002204022030220201b0112404024030270501f0202b0402202027050220202904029030290201601022040220302b0401b030240422403227040180301d0401d0301f0521f0421f0301d0211d0401d030
0108002001770017753f6253b6003c6003b6003f6253160023650236553c600000003f62500000017750170001770017753f6003f6003f625000003f62500000236502365500000000003f625000000000000000
002000200a1400a1300a1201113011120111101b1401b13018152181421813213140131401313013120131100f1400f1300f12011130111201111016142161321315013140131301312013110131101311013100
001000202e750377502e730377302e720377202e71037710227502b750227302b7301d750247501d730247301f750277501f730277301f7202772029750307502973030730297203072029710307102971030710
000600001877035770357703576035750357403573035720357103570000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001800202945035710294403571029430377102942037710224503571022440274503c710274403c710274202e450357102e440357102e430377102e420377102e410244402b45035710294503c710294403c710
0018002005570055700557005570055700000005570075700a5700a5700a570000000a570000000a5700357005570055700557000000055700557005570000000a570075700c5700c5700f570000000a57007570
010c00103b6352e6003b625000003b61500000000003360033640336303362033610336103f6003f6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c002024450307102b4503071024440307002b44037700244203a7102b4203a71024410357102b410357101d45033710244503c7101d4403771024440337001d42035700244202e7101d4102e7102441037700
011800200c5700c5600c550000001157011560115500c5000c5700c5600f5710f56013570135600a5700a5600c5700c5600c550000000f5700f5600f550000000a5700a5600a5500f50011570115600a5700a560
001800200c5700c5600c55000000115701156011550000000c5700c5600f5710f56013570135600f5700f5600c5700c5700c5600c5600c5500c5300c5000c5000c5000a5000a5000a50011500115000a5000a500
000c0020247712477024762247523a0103a010187523a0103501035010187523501018750370003700037000227712277222762227001f7711f7721f762247002277122772227620070027771277722776200700
000c0020247712477024762247523a0103a010187503a01035010350101875035010187501870018700007001f7711f7701f7621f7521870000700187511b7002277122770227622275237012370123701237002
000c0000247712477024772247722476224752247422473224722247120070000700007000070000700007002e0002e0002e0102e010350103501033011330102b0102b0102b0102b00030010300123001230012
000c00200c3320c3320c3220c3220c3120c3120c3120c3020c3320c3320c3220c3220c3120c3120c3120c30207332073320732207322073120731207312073020a3320a3320a3220a3220a3120a3120a3120a302
000c00000c3300c3300c3200c3200c3100c3100c3103a0000c3300c3300c3200c3200c3100c3100c3103f0000a3300a3201333013320073300732007310113000a3300a3200a3103c0000f3300f3200f3103a000
00040000336251a605000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000c00000c3300c3300c3300c3200c3200c3200c3100c3100c3100c31000000000000000000000000000000000000000000000000000000000000000000000000a3000a3000a3000a3000a3310a3300332103320
001000000c3500c3400c3300c3200f3500f3400f3300f320183501834013350133401835013350163401d36022370223702236022350223402232013300133001830018300133001330016300163001d3001d300
000c0000242752b27530275242652b26530265242552b25530255242452b24530245242352b23530235242252b22530225242152b21530215242052b20530205242052b205302053a2052e205002050020500205
001000102f65501075010753f615010753f6152f65501075010753f615010753f6152f6553f615010753f61500005000050000500005000050000500005000050000500005000050000500005000050000500005
0010000016270162701f2711f2701f2701f270182711827013271132701d2711d270162711627016270162701b2711b2701b2701b270000001b200000001b2000000000000000000000000000000000000000000
00080020245753057524545305451b565275651f5752b5751f5452b5451f5352b5351f5252b5251f5152b5151b575275751b545275451b535275351d575295751d545295451d535295351f5752b5751f5452b545
002000200c2650c2650c2550c2550c2450c2450c2350a2310f2650f2650f2550f2550f2450f2450f2351623113265132651325513255132451324513235132351322507240162701326113250132420f2600f250
00100000072750726507255072450f2650f2550c2750c2650c2550c2450c2350c22507275072650725507245072750726507255072450c2650c25511275112651125511245132651325516275162651625516245
000800201f5702b5701f5402b54018550245501b570275701b540275401857024570185402454018530245301b570275701b540275401d530295301d520295201f5702b5701f5402b5401f5302b5301b55027550
00100020112751126511255112451326513255182751826518255182451d2651d2550f2651824513275162550f2750f2650f2550f2451126511255162751626516255162451b2651b255222751f2451826513235
00100010010752f655010753f6152f6553f615010753f615010753f6152f655010752f6553f615010753f61500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000100107501075010753f6152f6553f6153f61501075010753f615010753f6152f6553f6152f6553f61500005000050000500005000050000500005000050000500005000050000500005000050000500005
002000002904029040290302b031290242b021290142b01133044300412e0442e03030044300302b0412b0302e0442e0402e030300312e024300212e024300212b0442e0412b0342e0212b0442b0402903129022
000800202451524515245252452524535245352454524545245552455524565245652457500505245750050524565005052456500505245550050524555005052454500505245350050524525005052451500505
000800201f5151f5151f5251f5251f5351f5351f5451f5451f5551f5551f5651f5651f575000051f575000051f565000051f565000051f555000051f555000051f545000051f535000051f525000051f51500005
000500000373005731077410c741137511b7612437030371275702e5712437030371275702e5712436030361275602e5612435030351275502e5512434030341275402e5412433030331275202e5212431030311
002000200c2750c2650c2550c2450c2350a2650a2550a2450f2750f2650f2550f2450f2350c2650c2550c2450c2750c2650c2550c2450c2350a2650a2550a2450f2750f2650f2550f2450f235112651125511245
002000001327513265132551324513235112651125511245162751626516255162451623513265132551324513275132651325513245132350f2650f2550f2450c25011231162650f24516272162520c2700c255
000300001f3302b33022530295301f3202b32022520295201f3102b31022510295101f3002b300225002950000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00002935500300293453037030360303551330524300243050030013305243002430500300003002430024305003000030000300003000030000300003000030000300003000030000300003000030000300
001000003c5753c5453c5353c5253c5153c51537555375453a5753a5553a5453a5353a5253a5253a5153a51535575355553554535545355353553535525355253551535515335753355533545335353352533515
00100000355753555535545355353552535525355153551537555375353357533555335453353533525335253a5753a5453a5353a5253a5153a51533575335553354533545335353353533525335253351533515
001000200c0600c0300c0500c0300c0500c0300c0100c0000c0600c0300c0500c0300c0500c0300c0100f0001106011030110501103011010110000a0600a0300a0500a0300a0500a0300a0500a0300a01000000
001000000506005030050500503005010050000706007030070500703007010000000f0600f0300f010000000c0600c0300c0500c0300c0500c0300c0500c0300c0500c0300c010000000c0600c0300c0100c000
0010000003625246150060503615246251b61522625036150060503615116253361522625006051d6250a61537625186152e6251d615006053761537625186152e6251d61511625036150060503615246251d615
00100020326103261032610326103161031610306102e6102a610256101b610136100f6100d6100c6100c6100c6100c6100c6100f610146101d610246102a6102e61030610316103361033610346103461034610
00400000302453020530235332252b23530205302253020530205302253020530205302153020530205302152b2452b2052b23527225292352b2052b2252b2052b2052b2252b2052b2052b2152b2052b2052b215
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 15 0a 43 44
00 0a 16 0c 44
00 0a 16 0c 44
00 0a 0b 0c 44
00 14 13 12 44
00 0a 16 0c 44
00 0a 16 0c 44
02 0a 11 12 44
00 41 42 43 44
00 41 42 43 44
01 18 19 1a 44
00 18 19 1a 44
00 1c 1b 1a 44
00 1d 1b 1a 44
00 1f 21 1a 44
00 1f 1a 21 44
00 1e 1a 22 44
02 20 1a 24 44
00 41 42 43 44
00 41 42 43 44
01 2a 27 29 44
00 2a 27 29 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2e 2d 30 44
00 34 31 27 44
02 35 32 27 44
00 41 42 43 44
01 3d 42 43 44
00 3d 42 43 44
00 3d 42 43 44
02 3d 3e 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 38 3a 3c 44
02 39 3b 3c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
