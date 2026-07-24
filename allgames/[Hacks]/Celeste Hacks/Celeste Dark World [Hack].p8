pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- ~celeste~
-- matt thorson + noel berry

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
screenshake=false

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
		this.text="-- celeste mountain --#this memorial to those# perished on the climb"
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
			spr(88,55,6)
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
 got_fruit[level_index()+1] = false
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
			pal(6,c)
			pal(8,c)
			pal(13,c)
			pal(14,c)
			pal(2,c)
			pal(5,c)
			pal(7,c)
		end
	end

	-- clear screen
	local bg_col = 0
	if flash_bg then
		bg_col = frames/5
	elseif not is_title() then
	 if new_bg~=nil then
		 bg_col=14
		else
		 bg_col=6
	 end
 end
	rectfill(0,0,128,128,bg_col)

	-- clouds
	if not is_title() then
		foreach(clouds, function(c)
			c.x += c.spd
			rectfill(c.x,c.y,c.x+c.w,c.y+4+(1-c.w/64)*12,new_bg~=nil and 15 or 7)
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
		print("matt thorson",40,94,5)
		print("noel berry",44,100,5)
		print("mod by crep",42,114,5)
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
0000000000000000000000000888888000000000000000000000000000000000004444400004440000004000000dd0ddd00ddd00000010000000100000010000
00000000088888800888888088888888088888800888880000000000088888800040004000040400000040000dddddd5ddddddd0000010000000100000010000
000000008888888888888888888ffff888888888888888800888888088f1ff18002404200004040000004000dd5555555dd5dddd000100000000100000010000
00000000888ffff8888ffff888f1ff18888ffff88ffff8808888888888fffff8000242000002420000004000d5ddd555d55555dd000100000000100000010000
0000000088f1ff1888f1ff1808fffff088f1ff1881ff1f80888ffff888fffff80000200000002000000040000000000000000000000100000001000000001000
0000000008fffff008fffff00033330008fffff00fffff8088fffff8083333800044200000042000000020000000000000000000000100000001000000001000
00000000003333000033330007000070073333000033337008f1ff10003333000002200000002000000020000000000000000000000010000001000000001000
00000000007007000070007000000000000007000000700007733370007007000044200000042000000020000000000000000000000010000001000000001000
dddddddd000000000000000000000000000000000000000000888800544444455444444554440445030030301111111103003030000000000000000070000000
dddddddd000000000000000000000000000000000000000008888880411111144111411441140414003353001510151000335300007700000770070007000007
dd0000dd0000000000000000000000000999999000000000087888804111111441144114544004140e8888e0155015500e8888e0007770700777000000000000
dd0000dd005000500244442000000000922222291111111108888880411111144444041400000045089888800500050058988885077777700770000000000000
dd0000dd005000500050050000000000922222291000000108888880411111144114044444000000088889800500050058888985077777700000700000000000
dd0000dd055105510005500000000000994a94991111111108888880411111144111411441400444088988800000000008898880077777700000077000000000
dddddddd0151015100500500000000009229922912222221008888004111111441141114414041140e8888e0000000000e8888e0070777000007077007000070
dddddddd11111111000550000244442092222229122222210000000054444445544444455400444500e88e000000000000e88e00000000007000000000000000
d555555dd5555555555555555555555d551111111111111111111155d555555ddddddddddddddddddddddddd1000000000000000000000000000000000000000
5555555555555555555555555555555555511111111111111111155555555555ddddddddddddddd00ddddddd1150000000033000000555550000000000000000
5551555555551111155555511111555555511111111111111111155555555555dddddddddddddd0000dddddd1555500000033000005511500000000000000000
5511115555511111111551111111155555551111111111111111555555511555ddddddddddddd000000ddddd1110000000d33d00051555000000000000000000
5511115555111111111111111111115555551111111111111111555555111155dddddddddddd00000000dddd100000000033b300055110000555550000000000
5551155555115511111111111115115555511111111111111111155555111155ddddddddddd0000000000ddd11500000003b3300055550000555515005500000
5555555555115511111111111111115555511111111111111111155555151155dddddddddd000000000000dd155550000d33b3d0000000000000005500555550
d555555d55111111111111111111115555111111111111111111115555111155ddddddddd00000000000000d111000000d3333d0000000000000000000055555
55111155551111111111111111111155d5555555555555555555555d55511155ddddddddd00000000000000d0000011103333330000000000000000000000000
5551115555111111111111111111115555555555555555555555555555511555d0dddddddd000000000000dd0005555103b33330000000000088088000000000
5551115555115111111111111551115555551115555555555111555555511555dddd00ddddd0000000000ddd00000511d333333d000000000088888000000030
5511155555111111111111111551115555511111515555111111155555111555dddd00dddddd00000000dddd0000000133333b33000000000008280000000030
5511155555511111111551111111155555511111115555151111155555111155ddddddddddddd000000ddddd0000011133333333000030000088888000000350
5551155555551111155555511111555555551115555555555111555555111155dd0ddddddddddd0000dddddd0005555100022000000300000088188003000300
5551155555555555555555555555555555555555555555555555555555511555ddddddddddddddd00ddddddd0000051100044000030300300000300000303500
55111155d5555555555555555555555dd5555555555555555555555dd555555ddddddddddddddddddddddddd0000000100444400050550500000300000505500
d5555dd555d5555d0777777777777777777777700777777000000000000000001111111100000000000000000000000000000000000000000000000000000000
55555555555555557dddd777dddd777ddddd77777ddd777700000000000000001551111100000000000000000000000000060000000000000000000000000000
55551155551155557dcc777cccc777ccccc777d77dc777d700000000000000001551151100000000000000000000000000606000000000000000000000000000
55511111111115557dc777cccc777ccccc777cd77d777cd70000000000000000111111110000000000000000000000000e000600000000000000000000000000
55111111111111557d777dddd777ddddd777ddd77777ddd70006dddddddd600011111111000000000000000000000000e00000e0000000000000000000000000
d51155111115115d7777dddd777ddddd777dddd7777dddd7006dddddddddd6001151111100000000000000000000000e00000080006000000000000000000000
d55155111111155d7ddddddddddddddddddcddd77ddddcd700dddddddddddd00111115110000000000000000000000e0000000080e0e00000000000000000000
55511111111115557dddddddddddddddddddddd77dddddd700d22222d2d22d001111111100000000000000000000008000000000000000000000000000000000
55511111111115557dddddddddddddddddddddd77dddddd700dddddddddddd000300b0b0066666006666660066000e0066666600066666006666660066666600
d5511111111115557ddddddcddddddddddddddd77dccddd700d22d2222d22d00003b530066666660666666606600800066666660666666606666666066666660
d51151111551115d7ddddddddddccdddddddddd77dccddd700dddddddddddd000288882066000660660000006608000066000000660000000066000066000000
55111111155111557dcddddddddccddddddddcd77ddddcd700ddd222d22ddd0008988880dd000000dddd0000dd000000dddd0000ddddddd000dd0000dddd0000
55511111111115557dddddddddddddddddddddd77dddddd700dddddddddddd0008888980dd000dd0dd000000dd0000d0dd000000000000d000dd0000dd000000
55551155551155557dddddddddddddddddddddd77dcdddd700dddddddddddd0008898880ddddddd0dddddd00ddddddd0dddddd00ddddddd000dd0000dddddd00
55555555555555557dddddddcdddddddddddddd77dddddd700dd55ddd5555d00028888200ddddd00ddddddd0ddddddd0ddddddd00ddddd0000dd0000ddddddd0
d5555d5555dd555d7dddddddddddddddddddddd77dddcdd705555555555555500028820000000000000000000000000000000000000000000000000000000000
00000000000000007dddddddddddddddddddddd77dddddd700777700d00000000000000d00000000000066666600066666006666660066000660000000000000
00999999999999007dddddddddddddddddddddd77ddcddd707000070dd000000000000dd00000000000066666660666666606666666066006660000000000000
09222222222222907dddddddddddcdddddddddd77dddddd770770007ddd0000000000ddd00000000008066000660660006606600066066066600800000000000
92244444444442297ddddddccdddddddddddddd77dddccd77077bb07dddd00000000dddd000000000800dd000dd0dd000dd0dd000dd0ddddd000080000000000
92444444444444297ddddddccddddddddddcddd77dddccd7700bbb07dddddddddddddddd000000088000dd000dd0ddddddd0dddddd00dddddd00008000000000
92222222222222297dcdddddddddddddddddddd77dcdddd7700bbb07dddddddddddddddd000000800000ddddddd0dd000dd0dd00ddd0dd00ddd0008000000000
92222222222222297dddddddddddddddddddddd77dddddd707000070dddddddddddddddd000008000000dddddd00dd000dd0dd000dd0dd000dd0008000000000
92222222222222290777777777777777777777700777777000777700dddddddddddddddd00002000000000000000000000000000000000000000000008000000
99999499994999990777777777777777777777700777777000488800004800000040088800080006600000660066666006666660066000000666666000800000
91111191191111197ddd777ddddd777ddddd77777ddd777700488888004880000048888800200006600600660666666606666666066000000666666600080000
91222191191222197dc777ccccc777ccccc777d77dc777d704200888042888880428880000200006600600660660006606600066066000000660006600020000
92444299992444297d777ccccc777ccccc777cd77d777cd70400000004008880040000000020000dd0ddd0dd0dd000dd0dd000dd0dd000000dd000dd00002000
92222299992222297777ddddd777ddddd777ddd77777ddd70400000004000000040000000000000ddddddddd0dd000dd0dddddd00dd0000d0dd000dd00000000
9244421111244429777ddddd777ddddd777dddd7777ddcd74200000042000000420000002000000dddd0dddd0ddddddd0dd00ddd0ddddddd0ddddddd00000020
92222222222222297dddddddddddddddddddddd77dddddd740000000400000004000000000000000dd000dd000ddddd00dd000dd0ddddddd0dddddd000000000
91222222222222190777777777777777777777700777777040000000400000004000000000000000000000000000000000000000000000000000000000000000
52525223232333828293425262253535b1000000b1422323232323232323232323232323232333a201132323232323525262b2a3828242525223232323232352
338293001323522323232323232323520000005542525252232352525262123252b1b1b152232323338283924252525262828392132323232323232323235252
528462b1b1b1b1a28282425233253535000011000003b1b1b1a2839292b1b1b1b1b1a38392b1b1008202920000a282425262b2828201428462b2a28392b1b113
8282820192b303b2a3920000b30382130000005513235262040013232333133362b200b303828282829200004252845262827600b1b1b1b1b1b1b1b1b1b14252
2352620000001186838242622435353600b302b26103000000001111000000000076827600000000a2020010000001135262009282b3425262b20000110000b1
a283920000b3738392100000b373a2820061005627471333000000a282828382620080b303920001827686414252525262019200000000000000000061004252
321333b200b3435353535262263646120000b1000003000000111263b200000000a28292000000b302435363930000b152620000a2b3132333b2001172110000
0092001111117282b302b20000b10082000000000000000000000000920000a2339300b373111100a28212225252525262820000111111111111111100004252
628382000000b1b1b1b11352222222520000000000730000b34333b10000610011008276000000000000b302019200115233b200000000a29200b3126202b261
0000b3720254039200b10000000000a2000000000000000011000000000000006302b2b3436302b200a213525284525262920000243434344443223200864284
33829200210000111100b142845252529300610000b10061b372b2000011000072938282000000610000b31232b2001262b20000000000000000b31323320000
00000003244573b2000000000011000000000000930000b302b200a30000000032b100b372b1b100000082132323235262110000263535353544426200824252
820100007100001232000013232352520100000000000000b303b261b302b20073828382110000000093b31333b2001333571111111111112737373747030076
000000032636470211111111110200000000a38282828600b10086829300000062b200b303b200000000a28282820142523211117226363636461333b2a24252
8200001111111142620000b1b1b113238293868282768600b373b20000b10000b100a28272110000a2828372b20000b13434344443535353535353536373b2a2
0072435353535353535353535332000086938282828201920000a201829200006286001103b2000000000092a2828242525222225232b1b1b1b1b1b100004252
8200b31222223213332111110000b1b18282828282838292b372b20000006100119361827372b2000000a273b20011113535354572b1b1b1b1b1b1b11232b200
0003b1b1b1b1b1b1b1b1b1b1b1030061828282a28382820000000000820616003392b34333b20000000000000082824252525252526283930000000061b34252
9200b3132352522222222232b2000000828392a282828200b31332111100000072828292b103b200000000b100b312223535354603b20000610000b34262b200
007382829300001100006100b30300008282920082829211000000a3820717d3b10000b1b1000000000000000082824252845252526292001111111111114252
000000828213235223232333b20000009282000000a2000000b3136372b20000738201001103b2000000001100b313233636461233b20011000000b34262b261
0002b2838282b302b28676868203b20083820000a282b302b2000082122222320000000000000000a300000000a28342525252528462b2b31222223243228452
000000828392b303b2b1b1b10000000000a200000000111100a382b303b20000b1a282837203b200c100b372b200b1b122222262b100b302b20000b313339300
00b10011a2018272a28283a28273b20082829300008200b1000000724252526200000000000000008200000000000013232323232333b2b34252525232135252
000000a28200b373b2000000a32100000000000000b34363b28283b373b261a300a382927303111111111173b276001152235262006100b100a30000b1b1a283
6100b302b286820386820000b302b200019200000082930000000003132323330000000000000000820000768600000083828292000000b34252528452321323
d3100000920000b1000000a28271000010000011117204000001a2829200008300828200b173435353535363b282931262101333000000a38292000000000082
007686b100a28303829200000000000082001000a30182920011114232243444007210f300000076820000a20100000082920000000093b34252525252522222
222232b20000008393210086838293007171001222620000a28261820000a382a382920000b1b1b1b1b1b1b10001821362710000000000828300a38201768682
868293006100a203828382936100000034343434448282837612225262253545004222536300008382930000820000008210d3e300a382b34252525252845252
525262b2000086828271a38201828276000000428452223200828692000082828382936100000061a3760061a38292b1628382930000a3828200828282839200
9200a28393000073a28201828693000035353535458282828242528462253545a34262243444a382828276868293000022222232018283b34252525252525252
5223232323621333b1b142232362b200628213232323232352522323232323235252522323232323235284522333b282528452232323232333b200b342525252
52845252525252848462828242525252522323232333828292425223232352520000000000000000000000000000000000000000000000000000000000000000
629200a20103b2b1000073b1b103b200628272b2000000824233b2a282018292525262b101828382b1135262b1b10083525262019261a283829300b342232323
2323232323232323236283821323232362b2a283920001820013338292b342840000000000000000000000000000000000000000000000000000000000000000
62100000a203b2000000b1000003b200338273b2001100a203b200a382110000525262b2829292a293b11333006100822323339200111111110041110382a2a2
b2b1b10000a2838282038292b1b1a2836200000000a3831232b2820161b34252000000000000a300000000000000000000000000000000000000000000000000
522232b2b373b200000011000003b200b10172b2b37200b373b2000083720000232333b2a2001100a200b3720000a38282828300b31222223243536303921000
b20000111100a2824333a2001100006162b200b34353535233b2a20000b342520000000000000100009300000000000000000000000000000000000000000000
845262b2b372b200a37672b22103b200a39203b2b303b200b10000a382030000222232b200b302110000b3030000001183829200b342845262a2828373007100
b200b34332000082b302b2b302b200a36200000000b1b173b100000000b3425200000000a30082000083000000000000000000000094a4b4c4d4e4f400000000
525262b2b303b221a28303b27103b20083b303b2b303b20000000000a203e310525262b20000b1021100b303b200b31282920000b342525262b292b302000000
b26100b17311009200b10000b10011a262b20000000000b10000000000b3138400000000827682000001009300000000000000000095a5b5c5d5e5f500000000
232333b2b303b271008203b20073b2a3821103b2b373b2111111111111422222525262b2000000b102b2b303b200b342821111111142528462b20000b1000000
b2000000b10211110000110000b302006211111111110061001111000076864200000000828382670082768200000000000000000096a6b6c6d6e6f600000000
b1b1b100b303111100a203b2a3010182824333b200b34353535353535352528452846211110000b372b2b303b200b313824353535323235262b2000011000000
b200000000b10272b2b372b20000b100522232122232b200b312320000a2834200000000a28282123282839200000000000000000097a7b7c7d7e7f700000000
9300111111423272b20013535353535392b17211a30192b1a2829200b34252522323235332b261b303b2b303000000a292b1b1b1b1b1b34262b200b372b2b312
111100000000b103b2b373b2000011612323331323331111114262b20000a242000000868382125252328293a300000000000000000000000000000000000000
92b3724353233303b200b1b1b1b1b1b300b3423282000011a383827612525252b1b1b1b173b200b303b2b30300000061000000000000b34262b280b303b2b342
6302b2110000b303b200b10000b302b2b1b1b1b1b1432222225262110000b342000000a282125284525232828386000000000000000000000000000000000000
00b303b261b31262b2d31111009300b300004262920000729200928242522323000000a3820000b303b2b37300000000000000009300b34262b200b303b2b342
b1b1b302b200b303b20000000000b100b210000000b3135284522363b200b3138676868292425252525262018282860000000000000000000000000000000000
00b373b200b3132353535363008392b31100426211111173b20000a21362040000000001839200b303a382820000000011111111828611425222222233b2b313
100000b10000b303b200006100768682b27100000000b3425233b1b1000000b182018283001323525284629200a2820000000000000000000000000000000000
9300b1000000b1b1b1b1b1b1868293b332001323535363b100000000b173000000000000820000b30382839200000000222222328283432323232333b200b312
329300000000b303b200000000a20182111111110000b31333b100000061000000a28293f3123242522333020000820000000000000000000000000000000000
82920000a3000000000000a2829282b36200b1b1b1b1b10000006100000000a300000086827600b30300a28276000000525252629200b1b1b1b1b1b100001142
628200000000b303b2000093a30000a222222232b20000b1b100a300000000000000122222526213331222328293827600000000000000000000000000000000
321111a28200111111110000822182b36293d300000082930000000000a301821000a38382920011731100839200000052845262000000869300000000b31252
62839321000011031100a3828286a1a252845262b2000011110082110000a3931000135252845222225252523201838200000000000000000000000000000000
522232b283931222223200a3017183b352222232b2a38382768600000083828232000182820011122232118201000000525252627171a3838282930000b34252
6282017293111252321182828382768652528462b200001232a383721100a2821222324252525252525284525222223200000000000000000000000000000000
__gff__
0000000000000000000000000000000004020000000000000000000200000000030303030303030304040402020000000303030303030303040404020202020200001313131302020302020202020002000013131313020200020202020202020000131313130004040202020202020200001313131300000002020202020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2331252548252532323232323300002425262425252631323232322628282824252533283829003132323233312525253328282831323232332425482526242525323232323300002831323232323225252532323232323232323226382824252548252525252628282425254825252525260000002425252525482526242525
252331323232332900002829000000242533313232332828002a28302a102824252628282800001b1b1b1b282831323228282828290000001b3132323233242533100000000000002a28282810282824252628282829001b002839302828242525254825323233282a3132322525482532330016002425253232323233312525
252523201028380000002a0000000024261028281b00002900002830003a3824482628002a0000000000002a282829002838290000000000001b1b2a103432322828390014003d003f002a2829002a2448262900000000113a28283028283132252532332838282900002a2831322525282900006824253338282828293b3148
3232332828282900000000003f003d24262828291100003f003a283700002a242525233d000000111111113a2828002c29001200000000110000000028294041293b343535353634353621232b003b24252600143d213536282810302828670048262b000000000000000000003b24252800003a282433290000112a00003b24
2321233828293a2839000034353522252628003b3435353523102829000000242525252311121121222223281029003c001717170000002711000068280050510000000000002a28282831332b003b31323321222337382829002a372838283925332b000000001111000000003b31252839000028302b000011201100003b24
26313328281028290000000000003125263800001b2a38283123290000003e24253232253621232425252629000034223900000068000031362b67282867682839000000000000002a3821232b00001b282831323328290000160020343628282639000b00003b21232b00000b002a242900000010302b003b2122232b003b31
252236282828280000000000003a2824262839003d0000292a30390000002125332a28372125263132323300000000242838282828003b21233a3828282828282800000000111111000024262b16000028281b1b1b001100000000002a20282933286768003b342525362b00000000310000160028372b003b3132332b000000
253338282829001111000000002838242522232027202b000030280000682448000028283125252222222367680000242828282a10393b24262829002a283828286800003b2034362b3b24262b00000038280000003b202b00000000000000080028102900003b31332b0000000000283900003a381b00000028282900120000
2629002a28003b21233a283a282828244825262125232b00003028676828313200002a28283132252525332828390024282900003a283b24262b000000002a2838290000002a2038393a31252300003a2828160000001b0000003a6768286700002a281111000028280000111100002a28282828290000006728380000170000
3300000028393b2426281028283422252525262425263900003028382828212200003a283828103132332a28382811242a00000038293b24262b00000000002829000000000027282828382426390028282900000000000000002a382828286700673b20202b671038393b34362b000038282900000000002828000000000000
0000003a28280031332828283828242532323324252628393b30112a283432250000002a2828281b1b1b002810282125000000002a393b24332b00000000002a0000000000003728292a29313328682828000000392839000000000028282900002a282829002a2828282838290000002a28282839003a282828676800000000
0000672838283b21232800002a28242528102831322629003b2423002a29282400000000002a281111113a28282824480000003a28283b371b000000001200003e000100000020280016001b1b2a283828003a28281028670000003a282800000000000c00000000000000000c00000000002a28282828382828282900000000
00012a2828293b31332900111111242529282829003700003b242611001c2a310000000000002821222328292a0024253e013a382829001b0011000017171700353535360000202900000011113a282829012828282828283900672838390000003a290000000000000000000000000000002a28282a2900002a100000000000
1717172828001121231111212222252501000000000000003b24252300003a2800013f0000002a312533280000002425222223290000000011270011000000112a282039003a2000003a003435353634222223290028292828282810282800003910000000000000670000000000003a2c000028380000000000000000000012
00003a2829002125252222252525482517170000001717001124252600003828222223000012002a3028290000122425252526000000000021261127111111270038202839282708002867682028282925482523002a002a282828282828393d2828013d0000006828390000000000283c016828280000171700000000001717
3a2838290011242525252525252525250000000000000000212548266768282825482600002700003028000000212525482526000000003a2425222523212225002a2028102837003a282828202900002525252600000000002a3828282122223821222300003a283828000000003a2822222223286700000000000000000000
2628282824252532322548252525252525252637282828242532323232254825323232323232322525332828000024252525260000000000000000000000005225253232323233313232323233282900261028283132323232331b1b1b3132323900242525253233312525482525254825254826283831323232322525252548
262829003132262123312525252548252548262738290031333828290031322500001b1b1b3a28313328382900002425482526000000000000000000000000522526282900000000002a1028283839002629000000003d2a38290000003a2828383b242525331b1b3b2425323232323232323233282828282828103132482525
262839001b20372425362525252525252525263028003b2028292a0000002a31163a1111110000002a28283900002425252526000000000000000000000000522526280016001111000000292a282900261111111111201111112122232b2a3b28672425331b00003b24262b002a2a381b1b1b1b2a29002a28002a1b1b312525
33281000001b343233203132322525252525263729003b20670000000000002868382122231100160029111100112425323233670000000000000000003a425325262800003a21230000160000111111252222232122232122232448262b003b162a31331b0000003b31332b00000028000000000000000029000000001b3132
2828280000001b1b1b1b1b1b1b313225252526272b0000202900000000003a28282924252523110000112123112731252223272800002c46472c00002a38626325262800002a24260000000000212222252548263132333132332425262b003b0000212300000067102829000000002839000011110012000000111100001b1b
283828000000160000003a39001b1b24482526372b000020000000002a672828283b24482533271111212525222523312526242367003c56573c3a676828751b3233290011112426111111111124252525482526201b2828101b2425262b003b393b2426013f3a28290000000000672810143b21230017000000272067680000
2828286700000000676828382828673132323320000000290000000000282828293b31323334323535323232322548232533242522232122222310282828451a2900003b203432323535353522254825252525262b00282829003132332b003b28002433343536111111111111002a3822222331331111111111372728290000
2828282810290000002a2828292a10283535353611111111111111111127283800002a10282829002a28281028313233262125252526242525252329002a5500000016001b1b2a282828292a31322525252525262b002a280000272a286700002839373435352222222222353667682832323327212222363536203028001600
282900002a000011110038291200002800002834362034362034353620302b2a00001100290011000000002a29002a29262425252533244825252600000065000000000000000028002a000000283132252548262b000038000037000028123a28281028293b24482525262b2a10282928293b37242526271b1b1b3029000000
283a000000001121232b280017003a28013a10292a001b271b0000001b302b16000027111111270b000000000000000b26313232332125252525263900001b001111000000000029001100002a382829252525262b000029000017003a38212228282900003b24252548262b0029001138003b27313233300008003000000000
38290000003b2125262b29000000283823202800000000300000160000302b00111124222222261100000000000000113338282828313232323233280000000022231111110000003b202b0068282800323232332b00000000003b343536312538280000003b31323225262b001111212a003b371b1b1b37000000370000003b
29000000003b2425332b0000003a28293329000000000030000000000037000035353232323225231100001600001134002a28290029000000002a28000000004825222223110000001b002a2010292c1b1b1b1b000000000000002a282810312829000000001b1b1b31332b3b2021250000001b00003a1b0000002000000017
013e0000003b3133272b000000002a00280000000000003700000000002000002828292a28103133202b0000393b2038000000000000006711113a28000000003232323233202b39000000002900003c000000000000000000000000282928282800000012000000001b1b00001b312500000011390038110000001b0039003b
22361100003b2122262b00001200000038673a000000001b00000000001b000029000000002a2828290000002a28291a003f0100003a282842442810673a3900013f0000002a3829001100000000002101000000000000003a67000000002a3828686768170000000000000000001b2401000020282928273900001600380000
33212311113b2448262b111120111111282828100000000000003a0000000000000100000000002800000000683800680021222342434343536428282838290022232b00000028393b27000000212225230000000068391228290000001c002828281028670000000017171717003a243536392710122837283a000000283900
2248252222232425262122222222222228283828290000003a283839000000000017170000003a386700003a28293b210024252652535353542828282828283925262b00003a28103b3000000024252526390000002a38272800000000003a282838282828390000000000003a2838242223383028172827102839003a282838
__sfx__
0002000036370234702f3701d4702a37017470273701347023370114701e3700e4701a3600c46016350084401233005420196001960019600196003f6003f6003f6003f6003f6003f6003f6003f6003f6003f600
0002000011070130701a0702407000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d07010070160702207000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000642008420094200b420224402a4503c6503b6503b6503965036650326502d6502865024640216401d6401a64016630116300e6300b62007620056100361010600106000060000600006000060000600
000400000f0701e070120702207017070260701b0602c060210503105027040360402b0303a030300203e02035010000000000000000000000000000000000000000000000000000000000000000000000000000
000300000977009770097600975008740077300672005715357003470034700347003470034700347003570035700357003570035700347003470034700337003370033700337000070000700007000070000700
00030000241700e1702d1701617034170201603b160281503f1402f120281101d1101011003110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000101101211014110161101a120201202613032140321403410000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000070700a0700e0701007016070220702f0702f0602c0602c0502f0502f0402c0402c0302f0202f0102c000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000005110071303f6403f6403f6303f6203f6103f6153f6003f6003f600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
011000200177500605017750170523655017750160500605017750060501705076052365500605017750060501775017050177500605236550177501605006050177500605256050160523655256050177523655
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
01 15 0a 43 44
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
