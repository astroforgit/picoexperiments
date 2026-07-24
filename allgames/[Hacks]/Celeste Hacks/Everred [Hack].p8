pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ~everred~
-- celeste classic mod by taco360
-- original by matt thorson + noel berry

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
bg=0

screenshake=false
time_ticking=false
heart_dist=0
heart_touched=false
heart_x=0
heart_y=0
got_golden=false
score=0
calculated_score=false

k_left=0
k_right=1
k_up=2
k_down=3
k_jump=4
k_dash=5
k_screenshake=2

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
	music(0,0,7)
	
	load_room(7,3)
end

function begin_game()
	frames=0
	seconds=0
	minutes=0
	music_timer=0
	start_game=false
	music(29,0,7)
	load_room(0,0)
	bg=1
	time_ticking=true
	
	--oof
	--[[
	max_djump=3
	target_level=20
	for i=1,target_level-1 do
		next_room()
		--bg=4
	end
	--]]
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
		if this.y<-4 and level_index()<27 and level_index()~=19 then
		 next_room()
	 end
		
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
	pal(1,(djump==1 and 1 or djump==2 and (2+flr((frames/3)%2)*6) or djump==3 and flr((frames/2)%7)+8 or 12))
end

draw_hair=function(obj,facing)
	local last={x=obj.x+4-facing*2,y=obj.y+(btn(k_down) and 4 or 3)}
	foreach(obj.hair,function(h)
		h.x+=(last.x-h.x)/1.5
		h.y+=(last.y+0.5-h.y)/1.5
		circfill(h.x,h.y,h.size,1)
		last=h
	end)
end

unset_hair_color=function()
	pal(1,1)
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

--golden reddish code
golden={
	tile=69,
	if_not_fruit=true,
	init=function(this)
		if deaths~=0 then
			destroy_object(this)
		end
	 this.x-=4
		this.start=this.y
		this.off=0
	end,
	update=function(this)
	 local hit=this.collide(player,0,0)
		if hit~=nil then
		 hit.djump=max_djump
			sfx_timer=20
			sfx(51)
			got_fruit[1+level_index()] = true
			got_golden=true
			init_object(goldup,this.x,this.y)
			destroy_object(this)
		end
		this.off+=1
		this.y=this.start+sin(this.off/40)*2.5
	end
}
add(types,golden)

--moon reddish code
moon={
	tile=117,
	if_not_fruit=true,
	init=function(this)
		if deaths~=0 then
			destroy_object(this)
		end
	 this.x-=48
		this.start=this.y
		this.off=0
	end,
	update=function(this)
	 local hit=this.collide(player,0,0)
		if hit~=nil then
		 hit.djump=max_djump
			sfx_timer=20
			sfx(51)
			got_fruit[1+level_index()] = true
			got_golden=true
			init_object(moonup,this.x,this.y)
			destroy_object(this)
		end
		this.off+=1
		this.y=this.start+sin(this.off/40)*2.5
	end
}
add(types,moon)

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

--golden reddish effect code
goldup = {
	init=function(this)
		this.spd.y=-0.25
		this.duration=30
		this.x-=0
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
		print("1000",this.x-4,this.y,9+this.flash%2)
	end
}

--moon reddish effect code
moonup = {
	init=function(this)
		this.spd.y=-0.25
		this.duration=30
		this.x-=0
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

		print("wow",this.x-2,this.y,11+this.flash%4)
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
		if level_index()==6 then
			this.text="  -- mount everred -- #this memorial to those#  who skipped the gem "
		else
			this.text="  -- everred spire -- #turn back now lest you#fall like those before"
		end
		if this.check(player,4,0) then
			if this.index<#this.text then
			 this.index+=0.5
				if this.index>=this.last+1 then
				 this.last+=1
				 sfx(7)
				end
			end
			this.off={x=8,y=8}
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
				if max_djump==1 or (level_index()==12 and max_djump==2) then
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
			end
			if max_djump==1 or (level_index()==12 and max_djump==2) then
				spr(96,this.x,this.y)
				spr(97,this.x+8,this.y)
			end
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
				if level_index()==0 then
					bg=2
				elseif level_index()==12 then
					bg=4
				end
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
			if level_index()==12 then
				max_djump=3
				hit.djump=3
			else
				max_djump=2
				hit.djump=2
			end
		end
		
		spr(68,this.x,this.y)
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
		--[[
		for i=1,count(got_fruit) do
			if got_fruit[i] then
				this.score+=1
			end
		end
		--]]
	end,
	draw=function(this)
		this.spr=118+(frames/5)%3
		spr(this.spr,this.x,this.y)
		--[[
		if this.show then
			time_ticking=false
			rectfill(32,92,96,121,0)
			spr(26,55,96)
			print("x"..this.score,64,99,7)
			draw_time(49,106)
			print("deaths:"..deaths,48,114,7)
		elseif this.check(player,0,0) then
			sfx(55)
	  sfx_timer=30
			this.show=true
		end
		--]]
	end
}
add(types,flag)

--penguin object code
yadelie = {
	tile=101,
	draw=function(this)
		this.spr=101+(frames/8)%2
		spr(this.spr,this.x,this.y)
	end
}
add(types,yadelie)

--sad penguin object code
sadelie = {
	tile=100,
	init=function(this)
		this.y+=80
	end,
	draw=function(this)
		spr(this.spr,this.x,this.y)
	end
}
add(types,sadelie)

--baby penguin object code
babelie = {
	tile=116,
	init=function(this)
		this.y+=80
	end,
	draw=function(this)
		spr(this.spr,this.x,this.y)
	end
}
add(types,babelie)

--crystal heart code
heart = {
	tile=82,
	init=function(this)
		heart_anim = {
			82,
			83,
			84,
			85,
			85,
			84,
			83,
			82
		}
		this.x+=4
		this.y+=4
		heart_touched=false
		this.offset=0
		this.start=this.y
	end,
	update=function(this) 
		this.offset+=0.01
		this.y=this.start+sin(this.offset)*2
		if heart_dist>=164 then
			time_ticking=false
			bg=6
			music(0,5000,7)
			load_room(6,3)
		end
	end,
	draw=function(this)
		index=1+flr((frames/4)%#heart_anim)
		this.spr=heart_anim[index]
		spr(this.spr,this.x,this.y)
		--print("frames: "..frames,30,5,0)
		--print("index:"..index,30,12,0)
		if this.check(player,0,0) and heart_touched==false then
			sfx(55)
	  sfx_timer=30
			heart_touched=true
			heart_x=this.x
			heart_y=this.y
			music(-1,500)
		end
	end
}
add(types,heart)

room_title = {
	init=function(this)
		this.delay=5
 end,
	draw=function(this)
		this.delay-=1
		if this.delay<-30 then
			destroy_object(this)
		elseif this.delay<0 then
			
			rectfill(24,20,104,40,0)
			--rect(26,64-10,102,64+10,7)
			--print("---",31,64-2,13)
			if level_index()==0 then
				print("beginnings",46,28,7)
			elseif level_index()==6 then
				print("forgotten cliffside",27,28,7)
			elseif level_index()==12 then
				print("everred peaks",39,28,7)
			elseif level_index()==18 then
				print("summit approach",36,28,7)
			elseif level_index()==20 then
				print("everred spire",39,28,14)
			elseif level_index()==21 then
				print("aspiration",45,28,14)
			elseif level_index()==22 then
				print("contemplation",39,28,14)
			elseif level_index()==23 then
				print("determination",39,28,14)
			elseif level_index()==26 then
				print("final approach",37,28,14)
			elseif level_index()==27 then
				print("true summit",44,28,flr((frames/2)%7)+8)
			elseif level_index()==19 then
				print("summit",52,28,7)
			else
				local level=(level_index())*100
				if level_index()>=13 then
					print(-200+level.." m",52+(level<1000 and 2 or 0),25,7)
				elseif level_index()>=7 then
					print(-100+level.." m",52+(level<1000 and 2 or 0),25,7)
				else
					print(level.." m",52+(level<1000 and 2 or 0),25,7)
				end
				if (max_djump==1) then
					print("trueskip mode",41,32,14)
				else
					if max_djump==2 and level_index()>12 then
						print("gemskip mode",41,32,11)
					else
						print("normal mode",43,32,12)
					end
				end
			end
			--print("---",86,64-2,13)
			
			draw_time(4,4,7)
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
	if level_index()==0 then
		if max_djump==1 then
			music(33,500,7)
			bg=2
		end
 elseif level_index()==5 then
  music(29,500,7)
  bg=3
 elseif level_index()==6 then
  if max_djump==1 then
  	music(12,500,7)
  else
  	music(44,500,7)
  end
 elseif level_index()==11 then
 	if max_djump==1 then
 		bg=4
 	end
  music(29,500,7)
 elseif level_index()==12 then
  if max_djump==2 then
			music(56,500,7)
			bg=4
		end
 elseif level_index()==17 then
  music(29,500,7)
  bg=2
 elseif level_index()==18 then
  bg=1
 elseif level_index()==20 then
  music(21,500,7)
 elseif level_index()==23 then
  music(-1)
  bg=2
 elseif level_index()==26 then
  music(29,500,7)
  bg=5
 end

	if level_index()==11 and max_djump==1 then
		load_room(4,2)
	elseif level_index()==23 then
		load_room(2,3)
	elseif room.x==7 then
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
	
	if not is_title() and level_index()~=30 then
		init_object(room_title,0,0)
	end
end

-- update function --
-----------------------

function _update()
	frames=((frames+1)%30)
	if frames==0 and time_ticking then
		seconds=((seconds+1)%60)
		if seconds==0 then
			minutes+=1
		end
	end
	
	if music_timer>0 then
	 music_timer-=1
	 if music_timer<=0 then
	  if level_index()==0 then
	  	music(33,0,7)
	  elseif level_index()==12 then
	  	music(56,0,7)
	  end
	 end
	end
	
	if sfx_timer>0 then
	 sfx_timer-=1
	end
	
	-- cancel if freeze
	if freeze>0 then freeze-=1 return end

	-- screenshake
	if btnp(k_screenshake,1) then
		screenshake=not screenshake
	end
	if shake>0 then
		shake-=1
		if screenshake then
 		camera()
 		if shake>0 then
 			camera(-2+rnd(5),-2+rnd(5))
 		end
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
			pal(15,c)
			pal(14,c)
			pal(13,c)
			pal(12,c)
			pal(11,c)
			pal(10,c)
			pal(9,c)
			pal(8,c)
			pal(7,c)
			pal(6,c)
			pal(5,c)
			pal(4,c)
			pal(3,c)
			pal(2,c)
			pal(1,c)
		end
	end

	-- clear screen
	local bg_col = 0
	if flash_bg then
			if level_index()==12 then
				bg_col=flr((frames/8)%7)+8
			else
				bg_col=frames/8
			end
	elseif bg==1 then
			bg_col=12
	elseif bg==2 then
			bg_col=13
	elseif bg==3 then
			bg_col=0
	elseif bg==4 then
			bg_col=9
	elseif bg==5 then
			bg_col=6
	elseif bg==6 then
			bg_col=7
	end
	rectfill(0,0,128,128,bg_col)

	-- clouds
	if not is_title() and bg~=6 then
		foreach(clouds, function(c)
			c.x += c.spd
			rectfill(c.x,c.y,c.x+c.w,c.y+4+(1-c.w/64)*12,flash_bg and 7 or bg==1 and 6 or bg==2 and 14 or bg==3 and 2 or bg==4 and 10 or bg==5 and 7 or 1)
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
			if level_index()==12 then
				pal(10,7)
				pal(9,6)
				pal(4,5)
				pal(1,flr((frames/2)%7)+8)
			end
			draw_object(o)
			pal()
		end
	end)
	
	--crystal hearts
	foreach(objects, function(o)
		if o.type==heart then
			if max_djump==1 then
				pal(1,9)
				pal(12,10)
			elseif max_djump==2 then
					pal(1,2)
					pal(12,8)
			end
			draw_object(o)
			pal()
		end
	end)

	-- draw terrain + summit code
	if level_index()==26 or level_index()==27 then
		pal(13,14)
		pal(15,7)
		local off=is_title() and -4 or 0
		map(room.x*16,room.y * 16,off,0,16,16,2)
		pal()
	else
		local off=is_title() and -4 or 0
		map(room.x*16,room.y * 16,off,0,16,16,2)
	end
	
	-- draw objects
	if(level_index()==0) then
		pal(9,8)
	elseif (level_index()==12) then
		pal(9,flr((frames/2)%7)+8)
	end
	foreach(objects, function(o)
		if o.type~=platform and o.type~=big_chest and o.type~=heart and o.type~=yadelie and o.type~=sadelie and o.type~=babelie then
			draw_object(o)
		end
	end)
	
	-- yadelie, sadelie, and babelie
	foreach(objects, function(o)
		if o.type==yadelie or o.type==sadelie or o.type==babelie then
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
		print("z/x",59,110,6)
		print("original game by",33,50,12)
		print("matt thorson",41,60,6)
		print("noel berry",45,66,6)
		print("mod by",53,81,12)
		print("taco360",51,91,6)
		--print("-demo version-",37,40,3)
	end
	
	if level_index()==19 then
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
	
	--draw heart transition
	if heart_touched and heart_dist<=164 then
		circfill(heart_x,heart_y,heart_dist,7)
		heart_dist+=16
	end
	
	--winscreen
	if level_index()==30 then
		--rectfill(32,32,96,96,0)
		
		if max_djump==1 then
			print("route:trueskip",36,20,0)
			print("wow, amazing work!",30,100,0)
		elseif max_djump==2 then
			print("route:gemskip",40,20,0)
			print("gemskip gang!",40,100,0)
		else
			print("route:normal",41,20,0)
			print("you won!",50,100,0)
		end
		
		if calculated_score==false then
			for i=1,count(got_fruit) do
				if got_fruit[i] then
					score+=1
				end
			end
			calculated_score=true
		end
		
		if got_golden then
			if max_djump==1 then
				spr(117,40,80)
			else
				spr(69,40,80)
			end	
		else
			spr(26,40,80)
		end
		
		print("reddish:"..score,55,81,0)
		
		if minutes<5 then
			spr(99,40,40)
		else
			spr(98,40,40)
		end
		
		draw_time(55,41,0)
		
		if deaths<10 then
			spr(115,40,60)
		else
			spr(114,40,60)
		end
		
		print("deaths:"..deaths,55,61,0)
 end
 
end

function draw_object(obj)

	if obj.type.draw ~=nil then
		obj.type.draw(obj)
	elseif obj.spr > 0 then
		spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
	end

end

function draw_time(x,y,c)

	local s=seconds
	local m=minutes%60
	local h=flr(minutes/60)
	
	if c~=0 then
		rectfill(x,y,x+32,y+6,0)
	end
	print((h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s),x+1,y+1,c)

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
000000000000000000000000011111100000000000000000000000000000000000aaaaa0000aaa000000a0000007707770077700000070000000700000070000
000000000111111001111110111b111101111110011111100000000001b1111000a000a0000a0a000000a0000777777677777770000070000000700000070000
00000000111b1111111b111111bfff11111b11111111b111011111101bfdff1100a909a0000a0a000000a0007766666667767777000700000000700000070000
0000000011bfff1111bfff111bfdffd111bfff1111fffb11111b1111b1fffff1009aaa900009a9000000a0007677766676666677000700000000700000070000
000000001bfdffd11bfdffd111fffff01bfdffd11dffdfb111bfff1111fffff10000a0000000a0000000a0000000000000000000000700000007000000007000
0000000011fffff011fffff001bbbb0011fffff00fffff111bfffff111bbbb100099a0000009a0000000a0000000000000000000000700000007000000007000
0000000001bbbb0001bbbb000700007007bbbb0000bbbb7011fdffd101bbbb000009a0000000a0000000a0000000000000000000000070000007000000007000
000000000070070000700070000000000000070000007000077bbb700070070000aaa0000009a0000000a0000000000000000000000070000007000000007000
555555550000000000000000000000000000000000000000008888004999999449999994499909940b00b0b0666566650b00b0b0000000000000000070000000
5555555500000000000000000000000000000000000000000888888091111119911141199114091900b333006765676500b33300007700000770070007000007
550000550000000000000000000000000aaaaaa00000000008788880911111199111911949400419008228006770677000822800007770700777000000000000
55000055007000700499994000000000a998888a1111111108888880911111199494041900000044082222800700070078222287077777700770000000000000
55000055007000700050050000000000a988888a1000000108888880911111199114094994000000022222200700070072222227077777700000700000000000
55000055067706770005500000000000aaaaaaaa1111111108888880911111199111911991400499082222800000000008222280077777700000077000000000
55555555567656760050050000000000a980088a1444444100888800911111199114111991405119006776000000000000677600070777000007077007000070
55555555566656660005500004999940a988888a1444444100000000499999955999999555005995000660000000000000066000000000007000000000000000
57777775577777777777777777777775773333333333333333333377577777755555555555555555555555555500000000077000000000000000000000000000
77777777777777777777777777777777777333333333333333333777777777775555555555555550055555556670000000777700000777770000000000000000
77737777777733333777777333337777777333333333333333333777777777775555555555555500005555556777700000777700007766700000000000000000
77333377777333333337733333333777777733333333333333337777777337775555555555555000000555556660000007737770076777000000000000000000
77333377773333333333333333333377777733333333333333337777773333775555555555550000000055555500000007737770077660000777770000000000
777337777733bb3333333333333b3377777333333333333333333777773333775555555555500000000005556670000007733770077770000777767007700000
777777777733bb333333333333333377777333333333333333333777773b3377555555555500000000000055677770000773b770000000000000007700777770
5777777577333333333333333333337777333333333333333333337777333377555555555000000000000005666000000733bb77000000000000000000077777
77333377773333333333333333333377577777777777777777777775777333775555555550000000000000050000066677333377000000000000000000000000
77733377773333333333333333333377777777777777777777777777777337775055555555000000000000550007777673b333370000000000aa0aa000000000
777333777733b333333333333bb333777777333777777777733377777773377755550055555000000000055500000766733333370000000000aaaaa000000030
7733377777333333333333333bb3337777733333737777333333377777333777555500555555000000005555000000553333b33300000000000a9a00000000b0
773337777773333333377333333337777773333333777737333337777733337755555555555550000005555500000666033333300000b00000aaaaa000000b30
77733777777733333777777333337777777733377777777773337777773333775505555555555500005555550007777600044000000b000000aa3aa003000b00
77733777777777777777777777777777777777777777777777777777777337775555555555555550055555550000076600044000030b00300000b00000b0b300
77333377577777777777777777777775577777777777777777777775577777755555555555555555555555550000005500999900030330300000b00000303300
577775577757777507777777777777700077770009099090000000000000000033333333dddddddd222222220000000000000000000000000222222007777770
77777777777777777000077700007777070000700999999000000000000000003bb33333dffddddd2ee2222200000bbb0000000000e000000282222077777777
777733777733777770cc777cccc77707707700070099990000000000000000003bb33b33dffddfdd2ee22e22bb00b3330000000000e000000222222077777777
777333333333377770c777cccc777c077077990709aaaa90000007777770000033333333dddddddd2222222203b33330000000000e0e00000222822077772277
77333333333333777077700007770007700999070aaaaaa0000775555557700033333333dddddddd2222222200333000000000000e0200000022220077772277
5733bb33333b337577770000777000077009990709aaaa90007555555555570033b33333ddfddddd22e222220003300000800000800200000004400072772227
5773bb333333377570000000000c00070700007000677600005555555555550033333b33dddddfdd22222e2200033b0008080000800080000004400072228827
777333333333377770000000000000070077770000066000075666665656657033333333dddddddd222222220b3333b020008008000080000099990002228820
77733333333337770110011000100100001001000001100005555555555555500000000000000000000000000000000800002008000020000000000000000000
57733333333337771cc11cc101c11c10001111000001100005566566665665500000000000000000000000000000002000000202000008000000000000000000
5733b3333bb333751cccc6c101ccc610001111000001100005555555555555500000000000000000000000000000080000000020000002000000000000000000
773333333bb333771ccccc6101ccc610001111000001100005555666566555500000000000000000000000000000000000000000000000000000000000000000
77733333333337771cccccc101cccc1000111100000110000555555555555550555555550eeeeee00ee000e00eeeeee00eeeeee0088888800888888008888880
777733777733777701cccc10001cc10000011000000110000055555555555500555555550eeeeeee0ee000ee0eeeeeee0eeeeeee088888880888888808888888
7777777777777777001cc100001cc10000011000000110000055775557777500555555550ee000000ee000ee0ee000000ee000ee088000880880000008800088
5777757777557775000110000001100000011000000110000777777777777770555555550dddd0000ddd0dd00dddd0000ddddddd022222220222200002200022
0000000000000000005555000099990000000000000000000000000050000000000000050dd0000000ddddd00dd000000dddddd0022222200220000002200022
00aaaaaaaaaaaa000561665009a5aa9000000000001111001011110155000000000000550dddddd0000ddd000dddddd00dd00dd0022002200222222002222222
0a999999999999a0566166659aa5aa5900111100011717101117171155500000000005550ddddddd0000d0000ddddddd0dd00ddd022002220222222202222220
a99aaaaaaaaaa99a566166659aa5a5a9011717100111991011119911555500000000555500000000000000000000000000000000000000000000000000000000
a9aaaaaaaaaaaa9a566111159aa55aa901119910111777110117771055555555555555550000000000000000e0000000000000000000000000e0000000000000
a99999999999999a566666659aaaaaa911177711111777110117771055555555555555550000000000000000e0000000000000000000000000e0000000000000
a99999999999999a0566665009aaaa9011197791011777100117771055555555555555550000000000000000e00000000000000000000000000e000000000000
a99999999999999a00555500009999000119559011995990119959905555555555555555000000000000000e000000000000000000000000000e000000000000
aaaaaaaaaaaaaaaa5566665599aaaa990000000000c00c00004888000048000000400888000000000000000d0000000000000000000000000000d00000000000
a49494a11a49494a566666659aaaaaa90000000000cccc0000488888004880000048888800000000000000e0000000000000000000cc0cc000000d0000000000
a494a4a11a4a494a61166116a5aaaa5a000000000b3333b00420088804288888042888000000000000000e00008000000008000000ccccc000000d0000000000
a49444aaaa44494a61166116aa5aa5aa00001110b333333b040000000400888004000000000000000000d0000008000000880200000c1c000000003000000000
a49999aaaa99994a066666600aaaaaa000017171003333000400000004000000040000000000000000330000080808000080008000ccccc000000003b0000000
a49444999944494a0566665009aaaa90000199110b3333b04200000042000000420000000000000bbb000000080802800220008000cc2cc0000000000bbb0000
a494a444444a494a55500555999009990001111100deed0040000000400000004000000000003bb000000000020820200020028000008000000000000000b000
a49499999999494a550000559900009900096696000dd00040000000400000004000000000030000000000002202202000202220000080000000000000000300
00004c5c2d2d2d2d2d2da45c2d2d2d2d6cb200b34c2d2d2d2d2d2d2d2d2d2d5c00b31d5ca45c5c5c5c5c5ca45c5c5c5c00000000000000250000000000000000
5c5c5c5c5ca45c2d2d2d3d82838282822d2d2d2d2d5c2d2d2d2d2d2d6cb200b35c5c2d2d2d2d5c5c5c2d2d6c8292b34c5c5c5c5c2d2d2d2d2d2d2d5c3db2b31d
00004c6cb1b1b1b1b1b14c6cb1b1b1b16cb200b30db2b1b1b1b1b1b1b1b1b34c0000b34c5c5c5c5ca45c5c5c5c5c5c5c00000000000000000000000000000000
5c5ca45c5c2d3db1b1b1b100a2828382b1b1b1b1b10db1b1b1b1b1b17db200b35c3db1b1b1b14c5c6c10000d8200b31d5c5c5c6cb2b1b1b1b1b1b30db20000b3
00004c6c0000000000004c6c000000006cb261b30db20000000000000061b34c0000b31d5ca45c5c5c5c5c5c5c5c5ca400000000000000000000000000000000
5ca45c5c3db1b100000000000000a29210000000b30db26100000000b10061006cb2000061004c2d2d6d000d839300b15c5c5c6cb20000000000b30db20000b3
00001d3d0000000000001d3d006100006cb200b37db20000111111110000b34c000000b34c2d5c5c5c5c5c2d2d2d5c5cb00000000000b00000000000b0000000
5c5c5c6cb200000000000000000000003c111100b30db20000000000111111116cb2000000000db20000000da29200005c5c5c3db20000000000b30db20000b3
0000b1b1000011110000b1b1000000006cb20000b10000b31c5d5d6db200b34c000000b37d011da42d2d6ca283821d5c00000000000000000000000000000000
5c5c5c3db2000000000000000000b4002d5d6db2b30d1100000000b34d5d5d5d6c00000011110db20011110d111100005c5c3db2000000000000b30db20000b3
0000000000001c3c00000000000000006cb20000000061b30db2b1b10000b34c0000a393b1a2820d82937d00a282827d00000000000000000000000000000000
a45c6cb200000000c200647400d3c3f3b1b1b100b34c6d0000000000b1b1b1b16c0000b31c5d3db2b34d5d2d5d3cb2005c3d0193000000000000b30db20000b3
0000000000004c6c00000000000000006cb21111111111b30db261000000b34c000082827686827d8292b100a3828300000000c00000000000c00000000000c0
5c5ca46d00000000c3f36575d31e2e2e00000000b30db10000000000000000006cb200b30db2b10000b1b1b1b30db2006cb2a283000011111100b30d11000011
1111111111114c6c11111111111100006c5d5d5d5d5d5d5d6cb200001111b34c00a3828392a28382a20000938282820000000000000000000000000000000000
5c5c3db2000011111e2e2e2e2e5e5e5e00001100b30db20000000000110000006cb200b30db2111111111161b30db2006cb2008293b31c2c3cb2b34c3cb2b31c
2c2c2c2c2c2ca45c2c2c2c2c2c3c00006cb2b1b1b1b1b1b30db200b34d5d5d4c00a38282930092920000a3828282920000000000000000670000000000000000
a46cb20000b34f5f2f2f2f2f945e5e5e00b37cb2b30db200000000b37c7685866c8693b34c5d5d5d5d5d6db2b30db2006cb2a38201b34c5c6cb2b34c6cb2b34c
2d2d2d2d2d2d5ca42d2d2d2d2d3d00006cb20000000000b30db20000b1b1b34c0082828282930000a300a2838201b7c7000000000000b71c3c00000000000000
5c3db2000000b1b1b1b1b1b11f5e5e9400b30d11110d1111111111110db1b1b16ca282b30db2b1b1b1b1b100b30db2006c82838292b34c5c6cb2b34c6cb2b34c
b1b1b1b1b1b14c6cb1b1b1b1b1b100006cb20000110000b30db200000000b34ca3828382829200a3829300a2821c2c6d0000000000001c5c6cc7000000000000
6cb200000000000000000000b14e5e5e00b31d5d5d2d5d5d5d5d5d5d3d0000006cb283b30db2110000111111b30d61006c11a28200b34c5c6cb2b31d3db2b31d
0000000000004c6c00000000000000006cb200b37cb200b30db211110000b34c82828282a20093018282931c2c5c3d000000000000004c5c5c3c000000540000
5c6d00000000000000000000004e5e5e0000b1b1b1b1b1b1b1b1b1b1b10000006cb282b31d5d6db2b34d5d5d5d3d76865c6db28300b31d2d6cb200b1b10000b1
0000000000001d3d00001111000000006cb200b30db200b31d5d5d6db200b34c8282a29200a3828283821c5c5c3d0000000000f400c74c5c5c6c000000000000
6cb200000011000000b40000f34e945e000000000000000000000000000061006c008293a283920000b1b1b1b1b1a2823db10082768682b30db2001111000000
c710b7000000b1b100001c3c930000003db200b30db20000b1b1b1b10000b34c829200f4008382831c2c5ca46c000000000010e4001c5c5c5c6cb700b7c70000
6cb20000b37eb20000c310d31e5e5e5e110000001100000011000000110000006ca383920082a3000011000000610083b10000a2828283b30db2b31c3cb221a3
2c2c3cb20000000000a34c6c83768693839310b30db20000000000000061b34c820000e410a21c2c5c5c5c5c6cd7560000b71c3c004c5c5c5c5c3c001c3cb700
6cb20000b30fb200001e2e2e5e945e5e3c1111117c1111117c1111117c1111116c82920011a20193b37cb2000000a38210000000838292b30db2b34c6cb27183
5c5c6cb200000000a3834c6c828201822c2c2c2c6cb20000000000000000b34c8200b31c2c2c5c5ca45c5c5ca42c3c00001c5c6c004c5c5c5c5c6c004c5c3c00
6cb20000b30fb200004e945e5e5e5e5e5c2c2c2c5c2c2c2c5c2c2c2c5c2c2c2c6c8393b37c00a383b30db20000a301823cb20000820100b30db2b34c6cb2a382
57777775577777777777777777777775772222222222222222222277577777755ca45c5c6cb20000000000004e5e5e5e00000000000000250000000000000000
77777777777777777777777777777777777222222222222222222777777777770000000000000000000000000000000000000000000000000000000000000000
77727777777722222777777222227777777222222222222222222777777777775c5c5ca46cb2a300000000e34e5e945e00000000000046000000470000000000
7722227777722222222772222222277777772222222222222222777777722777000000000000000000000000000000000000000000000000c4d4000000000000
77222277772222222222222222222277777722222222222222227777772222775c5c5c2d3db282920011110e4e5e5e5e000000000000e31e3ed7000000000000
777227777722ee2222222222222e22777772222222222222222227777722227700000000000000000000000000000000000000000095a5b5c5d5e5f500000000
777777777722ee222222222222222277777222222222222222222777772e22775c5c3d8282828201b34f5f2e5e945e5e0000000000001e5e5e3ed70000000000
577777757722222222222222222222777722222222222222222222777722227700000000000000000000000000000000000000000096a6b6c6d6e6f600000000
7722227777222222222222222222227757777777777777777777777577722277a46c82828283828293b1b11f5e5e5e5e0000000000114e5e5e5e3e0000000000
777222777722222222222222222222777777777777777777777777777772277700000000000000000000000000000000000000000097a7000000e7f700000000
777222777722e222222222222ee22277777722277777777772227777777227775c6c828201a200a2829300b31f5e5e9400000000001e5e5e5e5e6ee300000000
7722277777222222222222222ee22277777222227277772222222777772227770000000000000000000000000000000000000000000000000000000000000000
77222777777222222227722222222777777222222277772722222777772222775c6c838292000000a2839300b34e5e5e00000000004e5e5e5e5e5e3e00000000
77722777777722222777777222227777777722277777777772227777772222770000000000000000000000000000000000000000000000000000000000000000
77722777777777777777777777777777777777777777777777777777777227775c6c82829300000000920000b31f5e5e00000000114e5e5e5e5e5e3f00000000
77222277577777777777777777777775577777777777777777777775577777750000000000000000000000000000000000000000000000000000000000000000
5777777557777777777777777777777577dddddddddddddddddddd77577777755c6c8292a28293000000000000b34e5e000000004f2f2f2f2f2f3f0100000000
77777777777777777777777777777777777dddddddddddddddddd777777777770000000000000000000000000000000000000000000000000000000000000000
777d77777777ddddd777777ddddd7777777dddddddddddddddddd77777777777a46c0000009282760000000000b31f5e00000000a28283828282829200000000
77dddd77777dddddddd77dddddddd7777777dddddddddddddddd7777777dd7770000000000000000000000000000000000000000000000000000000000000000
77dddd7777dddddddddddddddddddd777777dddddddddddddddd777777dddd775c6c00000000a282938600000000b34e000000e300018282828382e3d7005700
777dd77777ddffdddddddddddddfdd77777dddddddddddddddddd77777dddd770000000000000000000000000000000000000000000000000000000000f40000
7777777777ddffdddddddddddddddd77777dddddddddddddddddd77777dfdd772d3d000000000092829200000000b34e0000001e2e3e82838282821e3ee30000
5777777577dddddddddddddddddddd7777dddddddddddddddddddd7777dddd7700000000000000000000000000000000000000c2000000000000000000e40000
77dddd7777dddddddddddddddddddd77577777777777777777777775777ddd77b1b1000000000000820000000000b34e0000e34e5e5e2e2e2e2e2e5e5e3e1100
777ddd7777dddddddddddddddddddd77777777777777777777777777777dd777000000000000000000000000000000000000f3c300000000000000b4007cd700
777ddd7777ddfddddddddddddffddd777777ddd7777777777ddd7777777dd777000000d7100000a3820000000000b34e10d71e5e5e5e5e5e5e5e5e5e5e5e3e00
77ddd77777dddddddddddddddffddd77777ddddd7d7777ddddddd77777ddd7770000000000000000000000000000000000e31232d3b41100000011c3b74c3c00
77ddd777777dddddddd77dddddddd777777ddddddd7777d7ddddd77777dddd770000001c6d000083829300000000b34e2e2e5e5e5e5e5e5e5e5e5e5e5e5e6e11
777dd7777777ddddd777777ddddd77777777ddd7777777777ddd777777dddd770000000000000000000000000000000000128452322e3e0000001e2e1c5c6cc7
777dd777777777777777777777777777777777777777777777777777777dd7770000000d24340082828200000000b34e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e2e
77dddd7757777777777777777777777557777777777777777777777557777775000000000000000000000000000000000042525252325e2e2e2e941c5c5c5c3c
__gff__
0000000000000000000000000000000004020000000000000000000200000000030303030303030304040402020000000303030303030303040404020202020200001313030002020303030202020202000000000000020204020202020202020000000000000004040202020202020200000000000000000002020202020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030303030000000000000000030303030303030300000000000000000303030303030303000000000000000003030303030303030000000000000000
__map__
25252525252532323225253338282425003b242525323232323232323232252532252525252525253300003125252525003a312548252525252548253232322525254825252532323232323232260000253232323232323232332b0000003b24004b0000000000000000000000000000e5f2f2f2f2f2e5e5e62b000000003be4
2525252532331b2a2931332a28103125003b3125331b000000000000001b312528313225252532331b00001b3132322528293b2432323225252525331b1b1b2425252525482628283828282828300000261b1b1b1b1b1b1b1b1b000000003b243f3c3d3f2c0000000000000000000000e60000000000e4e5e62b000000003be4
252525261b1b0000001b1b002a292a2400003b371b0000111100000000001b243810283125261b1b000000001b1b1b242a003b37382828314825261b001a0024252525252526382828292a382a30000026000000000000000000000000003b24e2e2e2e33c00002c0000000000000000e600144b0000e4e5f32b000000003be4
252525330000002c000000000011112400000000000011213600000000000024282838293126000000000000000000240000001b2a2838292425263900001124252525482526282829110029003000002600001c000000000000000000003b2449e5e5e5e33d4b3c0000000000000000e5e2e2e32b3be4f31b00000000003be4
2525262b0000003c3f1111111121222500000000001121262b00000000212225292a29003b3011000000111100000024111100000038293d24252638003b212531252525252638293b272b003b30000026000000000000000000000000001724e5e5e549e5e2f5f6000000000000000049e5e5f32b3bf71b0000000000003be4
252525232b003b21222222222225252500001111112125332b00003b21252525000000003b242311111121362b00002435362b000029002125253328393b24251b31322525262a003b302b003b30000026111111111111111127000000003b24e5e5f2f2f2f300000000000000000000e5e5f31b00001b000000000000003be4
2525253300003b312525252525252525222222222225262b0000003b312525320000013e3b24252235353328393a67241b1b00001111112448262b2a283b2448001b1b24252600003b302b003b30000025353535353522222226000000003b24f2f3000000000000000000004647003de5f31b00000000000000000000003be4
25252628675868283132252525252525322548252532332b000000001b31261b00002122222532332829002a281038240000003b3435352425262b00383b312500000031323300003b302b003b370000262b1b1b1b3b31323233000000003b2400000000000000000000003d56573fe1e62b0000000b000000000000000b3be4
2525332828382828281031252525252500312525331b1b0000000000001b3700393a24252533282829002c0028282125000000001b1b1b2425332b3a28393b240000001b1b1b00003b30000000000000262b000000001b1b1b1b000000003b24000000000000000000003de1e2e2e2e5e62b00000000000011111111111111e4
2526382900002a38282838313232252500002433000000000000000000001b0028283125261b2a2a00003c3f2a2125250000000000000031262b3a2828283b3100000000000000003b30000000000000262b000000000000000000000000172400000000000000000000e1e5e5e549e5e62b00000000003be1e2e2f5e2e2e2e5
253328006000002a292a2828382824250000370000000000000000000000000038282824330000000034352222252525000000000000001b372b28292a28391b00000011111100003b3000000000000026170000000000000000000000003b240000000000000000003fe4e549e5e5e5e62b00000000003be4e5f31bf1e5e5e5
2628293e00003f000000002a2838242500000000000000010027000000000000282938301b0000003a293b312525252500000000000000001b003800002a106700003b2122232b003b30000000001111262b0000000011111111000000003b243d013f3e0000000000e1e5e5e5e5e549e62b00000000003be4f31b001bf149e5
25222222222222233d3e00002a2824250000000000212222222523000000000038392a370000003a2900003b312525256768390000123d2c000038003e3d282800003b2425262b003b30000000112122262b0000001721222223170000003b24222222233d3e3f3d3ee449e5e5e5e5e5e62b00000000003bf71b0011001bf1e5
252525252525252522233f013d21252500000000212525252532323600000000282a000000003a29000000003b242525283829001121233c01002a39212223382c003b2448262b123b30001111212525262b2c00003b244825262b0000003b24482525252222222222e4e5e5e549e5e5e5e3013d000000001b0011e711001be4
252525252525252525252222222525250000000024254825264000000000000029000000003a2900000000003b3125252829001121252522233f0010312525223c013b2425262b173b30112122252548262b3c013d3b242525262b0000003b242548252525252525e1e5e549e5e5e5e5e549e2e300000000003be1e5e31108e4
2525252525252525252525252525252500002122222325252600000000000000000000003a29000000000000003b242538390021252525252523002a382425252222222525262b003b24222525482525252222222222252548262b0000003b242525252548252525e4e5e5e5e5e5e549e5e549e600000000003be4e549e2e2e5
0000003bf1e5e549f2f2e5e5e5f2f2f2e62b003bf1f2f2f2f2f2f2f2f2f2f2e500003be4e5e549e5e5e5e5e5e5e5e5e5e5e5f2e549e5e62b000000003be4e5490000000000000000003bd1d2c5c5c5c5c5c5c5c5c5d2d2d3000000000000c4c5000000c4c5c5c5c5c5c5c5c5c54ac5c5000000d1d2d2c54ac5c5c5c54ac5c5c5
000000003bf1e5e62900f1f2f31b1b1be62b00001b1b1b1b1b1b1b1b1b1b1be400003bf1f2f2f2f2f2f2f2f2f2f2f249e5f31bf1e5e5e62b000000003be449e5000000000000000000001b1bd1c54ac5c5c5d2d2d31b1b1b00000000007cc4c5000011c4c5d2c54ac5c5c5c5c5c5c5c50000001b1b1bd1d2d2d2d2d2d2d2d2d2
00000000003be4e600143a291b00004be62b00000000000000000000000000e40000001b1b1b1b1b1b1b1b1b1b1b1be4e62b003be449e62b000000003bf1e5e50000000000000000000000001bd1c5c5d2d31b1b1b000000000000007dc1c5c5003bc1c5d31bd1d2d2c5c5c5c5c5c5c50016000000001b1b1b1b1b1b1b1b1b1b
00000000003bf1e5e2e2f6000000013ce62b00000000110000000011000000e400000000000000000000000000003be4e62b1c3be4e5e5f600000000003be449000000000000000000000000001bc4c51b1b000000000000004f0000c1c5c54a003bc4d31b001b1b1bd1d2d2c5c54ac500000000110000000000111111000011
0000000000003be4e5f31b000000f4e2e62b0000003be70000003be7000000e400000000000000000000001600003be4e62b003be4e5e62b00000000003bf1e50000000000000000000000000000d1c50000000000000000004e7c7bc4c5c5c5003bd71b00000000001b1b1bd1c5c5c500000000c70000001111c1c2c32b3bc1
0000000000003be4e61b000000001bf1e62b0000003bf00000003bf0001600e400001100001100001100001100003be4e62b003bf1f2f32b0000000000003bf100000000000000000000000000001bc4000000000000111111c1c2c24ac5c5c500001b0000000000000000001bd1c5c511111111d0111111c1c2d2d2d32b3bd1
0000000000003be4e60000000000001be62b0000003bf00000003bf0000000e41111e71111e71111e71111e72b003be4e62b00001b1b1b00000000000000001b000000000000000000000000000000c4000000001111c1c2c2c5c5c5c5c5c5c50000000011111111000000000000c4c5c2d5d5d5c5d5d5d54ac62b0000000000
0000000c00003be4f30c00000000000ce62b0000003bf70000003bf0111111e4e2e2e5e2e2e5e2e249e2e2e62b003be4e62b0000000000000000000000000000000000000000000000000000000000c438391111c1c2c5d2d2d2c5c5c5c5c5c511111111c1c2c2c3110000000000c4c5c62b003bd72b003bc4c62b0000004f00
0000001600003bf01b00000000000000e62b000000001b0000003be4e2e2e2e5e549e5e5e5e5f2f2f2f2f2e62b003be4e62b0000000000000000000000000000000000000000000000000000000000c42828d4c2c5c5c61b1b1bd1d2c5c54ac5c2c2c2c2c5c54ac5c31100003bc1c5c5c62b00001b00003bc4c62b00007d4e7b
0000000000003bf00000000000000000e62b00000000000000003be449e5e5e5f2f2f2f2f2e61b1b1b1b1bf02b163be4e62b000c00000000000c00000000000c000000000000000000000000000000c429003bc44ac5d30000001b1bd1d2c5c5d2d2d24ac5c5c5c5c5c32b003bc44ac5c62b00001100003bc4c62b003bc1c2c2
0000000000003bf70000000000000000e62b00000000000000003be4e5e5e5491b1b1b1b1bf02b0000003bf02b003be4e62b0000000000000000000000000000000000000000000000000060000011c400003bd1c5c61b00000000001b1bd1c51b1b1bd1c5c5c5d2d2c62b003bc4c5c5c62b003bc700003bc4c62b003bc4c5c5
000000000000001b0000000000000000e62b00000000000000003be4e549e5e5000000003bf02b0016003bf02b003be4e62b0000000000000000000000000000000000000000000000007c00007bc1c50000003bc4d300000000000000001bc40000001bd14ad31b1bd72b003bc4c5c5c62b003bd039003bd1d32b003bc4c54a
00000000000000000000000000080000e62b003d4b00000000003be4e5e5e5492c0000003bf02b0000003bf02b003be4e62b00000000002c0000004b00001200002c000000004f007d7bc1c2c2c2c5c50000003bd71b000000000000004f7bc44f0000001bd71b00001b000011c4c54ac62b003bd02800001b1b00003bc4c5c5
00000000000000000000000000000000e62b01e1e300000000003be4e5e549e53c0100003bf72b0000003bf72b163be4e62b00000000003c3d013f3c000017003f3c013d4b7c4e7bc1c2c54ac5c5c5c5000000001b00000000007d7c014ec1c54e017b00001b00000000003bc1c5c5c5c62b013bd0283900000000003bc4c5c5
00000000000000000000000000000000e5e2e2e5f300000000003be449e5e5e5e2e30000001b00000000001b00003be4e62b000000004be1e2e2e2e33f000000e2e2e2e2e3c2c2c2c5c5c5c5c5c54ac500000000000000000000d4c2c2c2c54ac2c2c37c000000000000003bc4c5c5c5c5c2c2c2c6382800111100003bc4c5c5
00000000000000000000000000000000e5e5e5e60000000000003be4e549e5e549e60000000000000000000000003be4e62b00000000e1e5e549e5e5e3000000e549e5e5e5e3c5c54ac5c5c5c5c5c5c50000000000000000000000c4c54ac5c5c5c5c5c32b0000000000003bc44ac5c5c5c5c5c5c628103bc1c32b003bc44ac5
__sfx__
0002000036370234702f3701d4702a37017470273701347023370114701e3700e4701a3600c46016350084401233005420194001940019400193003f6003f6003f6003f6003f6003f6003f6003f6003f6003f600
0002000011570135701a5702457000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d57010570165702257000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000642008420094200b420224402a4503c6503b6503b6503965036650326502d6502865024640216401d6401a64016630116300e6300b62007620056100361010600106000060000600001000060000600
000400000f5701e570125702257017570265701b5602c560215503155027540365402b5303a530305203e52035510004000040000400004000070000000000000000000000000000000000000000000000000000
000300000977009770097600975008740077300672005715357003470034700347003470034700347003570035700357003570035700347003470034700337003370033700337000070000700007000070000700
00030000240700e0702d0701607034070200603b060280503f0402f020280101d0101001003010001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000105101251014510165101a520205202653032540325403440000400002000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000075700a5700e5701057016570225702f5702f5602c5602c5502f5502f5402c5402c5302f5202f5102c500005000060000600000000000000000000000000000000000000000000000000000000000000
0003000005110071303f6403f6403f6303f6203f6103f6153f6003f6003f600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001000200177500605017750170523655017750160500605017750060501705076052365500605017750060501775017050177500605236550177501605006050177500605256050160523655256050177523655
002000001d0401d0401d0301d020180401804018030180201b0301b02022040220461f0351f03016040160401d0401d0401d002130611803018030180021f061240502202016040130201d0401b0221804018040
00100000070700706007050110000707007060030510f0700a0700a0600a0500a0000a0700a0600505005040030700306003000030500c0700c0601105016070160600f071050500a07005050030510a0700a060
000400000c0501c0601007023070190702c0702107037070280703b0702c0703e060310503f040310303f030310203f020310203f020310103f010310103f010310103f010310103f00000000001000050000500
000400002f7402b760267701d7701577015770197701c750177300170015700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000096450e655066550a6550d6550565511655076550c655046550965511645086350d615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000001f77518775277752730027300243001d300263002a3001c30019300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001000002953429554295741d540225702256018570185701856018500185701856000500165701657216562275142753427554275741f5701f5601f500135201b55135530305602454029570295602257022560
001000200a0700a0500f0710f0500a0600a040110701105007000070001107011050070600704000000000000a0700a0500f0700f0500a0600a0401307113050000000000013070130500f0700f0500000000000
002000002204022030220201b0112404024030270501f0202b0402202027050220202904029030290201601022040220302b0401b030240422403227040180301d0401d0301f0521f0421f0301d0211d0401d030
0008002001770017753f6253b6003c6003b6003f6253160023650236553c600000003f62500000017750170001770017753f6003f6003f625000003f62500000236502365500000000003f625000000000000000
002000200a1400a1300a1201113011120111101b1401b13018152181421813213140131401313013120131100f1400f1300f12011130111201111016142161321315013140131301312013110131101311013100
001000202e750377502e730377302e720377202e71037710227502b750227302b7301d750247501d730247301f750277501f730277301f7202772029750307502973030730297203072029710307102971030710
000600001857035570355703556035550355403553035520355103570000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001800202945035710294403571029430377102942037710224503571022440274503c710274403c710274202e450357102e440357102e430377102e420377102e410244402b45035710294503c710294403c710
0018002005570055700557005570055700000005570075700a5700a5700a570000000a570000000a5700357005570055700557000000055700557005570000000a570075700c5700c5700f570000000a57007570
000c00103b6352e6003b625000003b61500000000003360033640336303362033610336103f6003f6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c002024450307102b4503071024440307002b44037700244203a7102b4203a71024410357102b410357101d45033710244503c7101d4403771024440337001d42035700244202e7101d4102e7102441037700
001800200c5700c5600c550000001157011560115500c5000c5700c5600f5710f56013570135600a5700a5600c5700c5600c550000000f5700f5600f550000000a5700a5600a5500f50011570115600a5700a560
001800200c5700c5600c55000000115701156011550000000c5700c5600f5710f56013570135600f5700f5600c5700c5700c5600c5600c5500c5300c5000c5000c5000a5000a5000a50011500115000a5000a500
000c0020247712477024762247523a0103a010187523a0103501035010187523501018750370003700037000227712277222762227001f7711f7721f762247002277122772227620070027771277722776200700
000c0020247712477024762247523a0103a010187503a01035010350101875035010187501870018700007001f7711f7701f7621f7521870000700187511b7002277122770227622275237012370123701237002
000c0000247712477024772247722476224752247422473224722247120070000700007000070000700007002e0002e0002e0102e010350103501033011330102b0102b0102b0102b00030010300123001230012
000c00200c3320c3320c3220c3220c3120c3120c3120c3020c3320c3320c3220c3220c3120c3120c3120c30207332073320732207322073120731207312073020a3320a3320a3220a3220a3120a3120a3120a302
000c00000c3300c3300c3200c3200c3100c3100c3103a0000c3300c3300c3200c3200c3100c3100c3103f0000a3300a3201333013320073300732007310113000a3300a3200a3103c0000f3300f3200f3103a000
010b00002955500500295453057030560305551330524300243050030013305243002430500300003002430024305003000030000300003000030000300003000030000300003000030000300003000030000300
000c00000c3300c3300c3300c3200c3200c3200c3100c3100c3100c31000000000000000000000000000000000000000000000000000000000000000000000000a3000a3000a3000a3000a3310a3300332103320
001000000c2500c2400c2300c2200f2500f2400f2300f220182501824013250132401825013250162401d26022270222702226022250222402222022210222002220018300133001330016300163001d3001d300
000c0000243752b37530375243652b36530365243552b35530355243452b34530345243352b33530335243252b32530325243152b31530315242052b20530205242052b205302053a2052e205002050020500205
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
000500000363005631076410c641136511b6612437030371274702e4712437030371274702e4712436030361274602e4612435030351274502e4512434030341274402e4412433030331274202e4212431030311
002000200c2750c2650c2550c2450c2350a2650a2550a2450f2750f2650f2550f2450f2350c2650c2550c2450c2750c2650c2550c2450c2350a2650a2550a2450f2750f2650f2550f2450f235112651125511245
002000001327513265132551324513235112651125511245162751626516255162451623513265132551324513275132651325513245132350f2650f2550f2450c25011231162650f24516272162520c2700c255
000300001f1302b13022030290301f1202b12022020290201f1102b11022010290101f3002b300225002950000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000010510205104041070710b061110511a051230512b05130051360513d0513f0523f0523f0523f0523f0523f0523f0523f0523f0523f0523f0523f0523f0423f0423f0323f0323f0223f0223f0123f015
001000003c7753c7453c7353c7253c7153c7153c7153c7153a7753a7553a7453a7353a7253a7253a7153a71537775377553774537745377353773537725377253771537715337753375533745337353372533715
001000003577535755357453573535725357253077530765377553773533775337553374533735337253372529775297452973529725297152971524775247552474524745247352473524725247252471524715
001000200c0600c0300c0500c0300c0500c0300c0100c0000a0600a0300a0500a0300a0500a0300a0100f00011060110301102011000110000a0000a0600a040000000a0000a0600a0400e0600e0400e0200e010
001000000506005030050500503005010050000706007030070500703007010000000f0600f0300f010000000c0600c0300c0500c0300c0500c0300c0500c0300c0500c0300c010000000c0600c0300c0100c000
0010000003625246150060503615246251b61522625036150060503615116253361522625006051d6250a61537625186152e6251d615006053761537625186152e6251d61511625036150060503615246251d615
00100020326103261032610326103161031610306102e6102a610256101b610136100f6100d6100c6100c6100c6100c6100c6100f610146101d610246102a6102e61030610316103361033610346103461034610
005000000c1300c130131301312013110101001013011130131301c1301d1301f1301f1201f1102e0052d0051d1301c1301d1301313011130111301013010120101101c0000e1300e1200e1100c1300c1200c110
001000003c7753c7453c7353c7253c7153c7153c7153c7153a7753a7553a7453a7353a7253a7253a7153a71537775377553774537745377353773537725377253771537715337753375533745337353372533715
__music__
01 38 42 43 44
00 39 42 43 44
01 38 3a 3c 44
02 39 3b 3c 44
01 15 0a 43 44
00 0a 16 0c 44
00 0a 16 0c 44
00 0a 0b 0c 44
00 14 13 12 44
00 0a 16 0c 44
00 0a 16 0c 44
02 0a 11 12 44
01 2a 27 29 44
00 2a 27 29 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2e 2d 30 44
00 34 31 27 44
02 35 32 27 44
01 18 19 1a 44
00 18 19 1a 44
00 1c 1b 1a 44
00 1d 1b 1a 44
00 1f 21 1a 44
00 1f 1a 21 44
00 1e 1a 22 44
02 20 1a 24 44
01 3d 42 43 44
00 3d 42 43 44
00 3d 42 43 44
02 3d 3e 43 44
01 15 42 43 44
00 15 0a 43 44
00 0a 16 0c 44
00 0a 16 0c 44
00 0a 0b 0c 44
00 14 13 12 44
00 41 0b 0c 44
00 41 16 0c 44
00 0a 16 0c 44
00 0a 11 12 44
02 41 11 12 44
01 2a 42 29 44
00 41 2b 29 44
00 41 2b 2c 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2e 2d 30 44
00 41 2d 30 44
00 35 32 27 44
00 34 31 27 44
00 41 2d 30 44
00 41 42 30 44
02 41 2b 30 44
01 18 42 43 44
00 18 19 1a 44
00 1c 1b 1a 44
00 1d 1b 43 44
00 1f 21 1a 44
00 1f 1a 21 44
00 1e 42 22 44
02 20 42 24 44
