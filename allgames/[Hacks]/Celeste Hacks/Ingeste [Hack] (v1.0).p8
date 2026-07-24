pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- * ingeste: a celeste mod *
-- by ex.ult videotainment
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

k_left=0
k_right=1
k_up=2
k_down=3
k_jump=4
k_dash=5
k_breath=5

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
 -- music(40,0,7)
	music(20,500,7)
	
	load_room(7,3)
end

function begin_game()
	frames=0
	seconds=0
	minutes=0
	music_timer=0
	start_game=false
	music(1,0,7)
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
for i=0,4 do
	add(clouds,{
		x=rnd(128),
		y=rnd(128),
		spd=1+rnd(3),
		w=32+rnd(32)
	})
end

particles = {}
for i=0,24 do
	add(particles,{
		x=rnd(256),
		y=rnd(128),
		s=0+flr(rnd(5)/4),
		spd=0.25+rnd(2),
		off=rnd(1),
		c=8+(flr(0.5+rnd(1)) * 6)
	})
end

hitground_particles = {}
dead_particles = {}

-- player entity --
-------------------

player = 
{
	init=function(this) 
		this.p_jump=false
  this.p_dash=false
  this.p_fly=false
  this.was_flying=false
  this.lskip=false
		this.grace=0
  this.jbuffer=0
		this.flybuffer=1
  this.flaptimer=0
  this.flaprepeat=9
  this.flapanim=0
  this.flapmult=0
  this.mouthopentimer=0
		this.djump=max_djump
		this.dash_time=0
		this.dash_effect_time=0
		this.dash_target={x=0,y=0}
  this.dash_accel={x=0,y=0}
  this.hitbox = {x=1,y=3,w=6,h=5}
  this.center = {x=0,y=0}
  this.spr_off=0
  this.can_inhale=true
  this.inhaling=false
  this.inhale_timer=0
  this.glomp_timer=0
  this.was_glomping=false
		-- this.flip={x=false,y=false}
  this.was_on_ground=false
  this.landing_timer=0
		create_hair(this)
	end,
	update=function(this)
		if (pause_player) return
		
  local input
  if this.inhaling then
   input = 0
  else
 		input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)
  end

		-- spikes collide
		if spikes_at(this.x+this.hitbox.x,this.y+this.hitbox.y,this.hitbox.w,this.hitbox.h,this.spd.x,this.spd.y) then
		 kill_player(this) end
		 
		-- bottom death
		if this.y>128 then
			kill_player(this) end

  local on_ground=this.is_solid(0,1)
  -- local on_ground
  -- if this.p_fly then
  --  on_ground=false
  -- else
		--  on_ground=this.is_solid(0,1)
  -- end
		local on_ice=this.is_ice(0,1)
		
		-- smoke particles
  -- landing
		if on_ground and not this.was_on_ground then
    if not this.inhaling then
     psfx(9)
    end
    this.landing_timer=3
    hit_ground_star(this)
		--  -- init_object(jump_cloud,this.x,this.y+4)
  --  this.can_inhale=true
  --  -- this.p_fly = false
		end

  if this.landing_timer>0 then
   this.landing_timer-=1
  end

  -- if on_ground then
  --  this.can_inhale=true
  -- end

  this.center.x = this.x + 4
  this.center.y = this.y + 4

  local breath = btn(k_breath)
  local btnup = btn(k_up)
  local btndown = btn(k_down)
  local jump 

  if btnup and not this.inhaling and not (this.mouthopentimer>0) then 
   this.p_fly=true
   on_ground=false
   this.flybuffer=0
   this.grace=0
   this.jbuffer=4
  end

  if (this.p_fly) then
   jump = btn(k_jump)
  else
   jump = btn(k_jump) and not this.p_jump
  end

  this.p_jump = btn(k_jump)
  if jump and not this.inhaling and not (this.mouthopentimer>0) then
   this.jbuffer=4
   if this.flybuffer<1 then
    this.p_fly = true
   end
  elseif this.jbuffer>0 then
   this.jbuffer-=1
  end

  -- flying
  if this.p_fly then
   this.was_flying=true
   this.can_inhale=false
   if jump or btnup then
    this.flaptimer+=1
    if this.flapmult <= 50 then
     this.flapmult+=0.75
    end
   else
    this.flaptimer=0
    if this.flapmult>0 then
    this.flapmult*=0.9
    elseif this.flapmult<0 then
     this.flapmult=0
    end
   end
   if breath or btndown then
    this.p_fly = false
   end
   -- if btn(k_jump) and not this.p_jump then
   --  this.flapanim=0
   -- end
  else
   this.flaptimer=0
    this.flapmult=0
  end

  if not this.p_fly and this.was_flying then
   has_dashed=true
   this.was_flying=false
   init_object(puff,this.x,this.y,this.flip.x)
   psfx(2)
   this.mouthopentimer=6
  end

  if this.mouthopentimer>0 then
   this.mouthopentimer-=1
  end

  -- local dash = btn(k_dash) and not this.p_dash
  -- this.p_dash = btn(k_dash)

  -- this.lskip = btn(k_breath) and btndown

  -- if this.lskip then next_room() end
		
		if on_ground and not (this.glomp_timer>0) then
			this.grace=6
   this.p_fly = false
   this.flybuffer=1
   this.can_inhale=true
			if this.djump<max_djump then
			 psfx(54)
			 this.djump=max_djump
			end
		elseif not this.p_fly and this.grace > 0 then
		 this.grace-=1
  elseif this.flybuffer > 0 then
   this.flybuffer-=1
		end

  if breath and this.can_inhale and not this.was_glomping and not (this.mouthopentimer>0) then
   if not this.inhaling then
    this.inhaling=true
    create_inhales(this)
    sfx(3,3)
    init_object(mouthvoid,this.x,this.y,this.flip.x)
   end
   this.grace=0
   this.inhale_timer=4
  elseif this.inhaling and not breath then
   this.inhale_timer-=1
   if this.inhale_timer<=0 then
    sfx(-1,3)
    this.inhaling=false
   end
  else
   this.inhale_timer=0
   this.inhaling=false
  end

  if this.inhaling then
   update_inhales(this,this.flip.x and -1 or 1)
  end

  if not breath and this.was_glomping then
   this.was_glomping=false
  end

  if this.glomp_timer > 0 then
   this.glomp_timer-=1
   this.flybuffer=this.glomp_timer
   this.can_inhale=false
   this.was_glomping=true
  else
   this.can_inhale=true
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
			local maxfall
   local gravity
   if this.p_fly then
    gravity=0.15
    maxfall=0.5
    if abs(this.spd.y) <= 0.5 then
     if abs(this.spd.y) <= 0.25 then
      gravity*=0.25
     else
      gravity*=0.35
     end
    end
   elseif this.mouthopentimer>=1 then
    gravity=0.15
    maxfall=0
   else
    gravity=0.21
    maxfall=2
    if abs(this.spd.y) <= 0.5 then
     gravity*=0.35
    end
   end

		
			-- wall slide
			-- if input!=0 and this.is_solid(input,0) and not this.is_ice(input,0) then
		 -- 	maxfall=0.4
		 -- 	if rnd(10)<2 then
		 -- 		init_object(smoke,this.x+input*6,this.y)
			-- 	end
			-- end

			if not on_ground then
				this.spd.y=appr(this.spd.y,maxfall,gravity)
			end

			-- jump
			if this.jbuffer>0 then
		 	if this.grace>0 then
		  	-- normal jump
		  	psfx(1)
		  	this.jbuffer=0
     -- if (this.p_fly) then
     --  this.grace= -6
     -- else
     this.grace=0
     init_object(jump_cloud,this.x,this.y+4,this.flip.x)
     -- end
     this.spd.y=-2
    elseif this.p_fly and this.flaptimer==1 or this.flaptimer%this.flaprepeat == 1  then
     psfx(1)
     init_object(smoke_small,this.x,this.y+4,this.flip.x)
     this.spd.y = -0.8 - (0.01 * this.flapmult)
     this.flapanim=6
				else
					-- wall jump
					-- local wall_dir=(this.is_solid(-3,0) and -1 or this.is_solid(3,0) and 1 or 0)
					-- if wall_dir!=0 then
			 	-- 	psfx(2)
			 	-- 	this.jbuffer=0
			 	-- 	this.spd.y=-2
			 	-- 	this.spd.x=-wall_dir*(maxrun+1)
			 	-- 	if not this.is_ice(wall_dir*3,0) then
		 		-- 		init_object(smoke,this.x+wall_dir*6,this.y)
					-- 	end
					-- end
				end
			end
		
			-- dash
			local d_full=5
			local d_half=d_full*0.70710678118
		
			-- if this.djump>0 and dash then
		 -- 	init_object(smoke,this.x,this.y)
		 -- 	this.djump-=1		
		 -- 	this.dash_time=4
		 -- 	has_dashed=true
		 -- 	this.dash_effect_time=10
		 -- 	local v_input=(btn(k_up) and -1 or (btn(k_down) and 1 or 0))
		 -- 	if input!=0 then
		 --  	if v_input!=0 then
		 --   	this.spd.x=input*d_half
		 --   	this.spd.y=v_input*d_half
		 --  	else
		 --   	this.spd.x=input*d_full
		 --   	this.spd.y=0
		 --  	end
		 -- 	elseif v_input!=0 then
		 -- 		this.spd.x=0
		 -- 		this.spd.y=v_input*d_full
		 -- 	else
		 -- 		this.spd.x=(this.flip.x and -1 or 1)
		 --  	this.spd.y=0
		 -- 	end
		 	
		 -- 	psfx(3)
		 -- 	freeze=2
		 -- 	shake=6
		 -- 	this.dash_target.x=2*sign(this.spd.x)
		 -- 	this.dash_target.y=2*sign(this.spd.y)
		 -- 	this.dash_accel.x=1.5
		 -- 	this.dash_accel.y=1.5
		 	
		 -- 	if this.spd.y<0 then
		 -- 	 this.dash_target.y*=.75
		 -- 	end
		 	
		 -- 	if this.spd.y!=0 then
		 -- 	 this.dash_accel.x*=0.70710678118
		 -- 	end
		 -- 	if this.spd.x!=0 then
		 -- 	 this.dash_accel.y*=0.70710678118
		 -- 	end	 	 
			-- elseif dash and this.djump<=0 then
			--  psfx(9)
			--  init_object(smoke,this.x,this.y)
			-- end
		
		end

		-- animation
		this.spr_off+=0.25
  if this.flapanim>0 then this.flapanim-=1 end
		if not on_ground then
			-- if this.is_solid(input,0) then
			-- 	this.spr=5
			-- else
   if this.p_fly then
    if this.flapanim>0 then
     if this.flapanim>=5 then
   			this.spr=7
     else
      this.spr=5
     end
    else
     this.spr=7
    end
   elseif this.mouthopentimer>0 or this.inhaling then
    this.spr=14
   else
    if this.spd.y>=0.75 and not (this.glomp_timer>0) then
     -- falling frame
     this.spr=120
    else
     -- jump frame
     this.spr=15
    end
   end
  elseif this.mouthopentimer>0 or this.inhaling then
   this.spr=14
  elseif this.glomp_timer>0 then
   if this.glomp_timer>3 then
    this.spr=7
   else
    this.spr=6
    end
  elseif this.landing_timer>0 then
   this.spr=6
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
		-- draw_hair(this,this.flip.x and -1 or 1)
  spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)  
  if this.inhaling then
   draw_inhales(this)
  end
  unset_hair_color()
  -- print(this.glomp_timer,this.x-4,this.y,7)
  -- print(this.center.y,this.x-4,this.y-6,7)
  -- print(this.grace,this.x-4,this.y-12,7)
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

create_inhales=function(obj)
 obj.inhales={}
 for i=0,4 do
  add(obj.inhales,{x=obj.x,y=obj.y,dx=0,dy=0})
 end
end

update_inhales=function(obj,facing)
 -- local char={x=obj.x,y=obj.y}
 -- local facing=facing
 foreach(obj.inhales,function(h)
  -- if h.x >= char.x+3 and h.x <= char.x+5 then
  -- local xdst =  (char.x+4) - (h.x*facing)
  local dist = dst(h,obj.center)
  if dist <= 2 or dist >= 18 then 
   h.x=(obj.center.x)+((10+rnd(5))*facing)
   h.y=obj.center.y+6-rnd(12)
  end
  calc_path(h,obj.center)
  h.x-=(abs(h.dx))*facing
  if h.y > obj.center.y then
   h.y-=(abs(h.dy))
  elseif h.y<=obj.center.y then
   h.y+=(abs(h.dy))
  end
  -- h.x+=(last.x-h.x)/1.5
  -- h.y+=(last.y+0.5-h.y)/1.5
  -- circfill(h.x,h.y,h.size,8)
 end)
end

draw_inhales=function(obj)
 foreach(obj.inhales,function(h)
  pset(h.x,h.y,7)
 end)
end

function dst(o1,o2)
 return sqrt(sqr(o1.x-o2.x)+sqr(o1.y-o2.y))
end

function sqr(x) return x*x end

function calc_path(ent,tar)
 local prun = ent.x - tar.x
 local prise = ent.y - tar.y
 local length = sqrt( (prise*prise) + (prun*prun) )
 ent.dx = abs(prun / length)
 ent.dy = abs(prise / length)
end

inhale_object=function(obj)
 -- if being inhaled
 if obj.incount <= 0 then
  obj.cx=obj.x
  obj.cy=obj.y
 end
 obj.incount+=1
 if obj.incount>=6 then
  -- if going into the mouth
  local dist = dst(obj.center,obj.player.center)
  if dist <= 6 then
   obj.got=true
   obj.inhaled=true
  end

  if obj.type==fake_wall and obj.sprite_offset>0 then
   obj.sprite_offset-=1
  end


  calc_path(obj.center,obj.player.center)
  obj.x-=(abs(obj.center.dx))*(obj.player.flip.x and -1 or 1)
  if obj.center.y > obj.player.center.y then
   obj.y-=(abs(obj.center.dy))
  elseif obj.center.y<=obj.player.center.y then
   obj.y+=(abs(obj.center.dy))
  end
 else
  -- if beginning to inhale, shake
  local offsets=obj.offsets
  obj.oxi=rand_int_between(1,#offsets)
  obj.oyi=rand_int_between(1,#offsets)
  obj.ox=offsets[obj.oxi]
  obj.oy=offsets[obj.oyi]
  obj.x=obj.cx+obj.ox
  obj.y=obj.cy+obj.oy
 end
end

player_spawn = {
	tile=1,
	init=function(this)
	 sfx(4)
		this.spr=102
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
		-- draw_hair(this,1)
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
				hit.spd.y=-2
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

smoke_small={
 init=function(this)
  local p_flipx= this.flip.x and -1 or 1
  this.spr=30
  this.spd.y=0.1
  this.spd.x=0
  this.x+=-1*p_flipx
  this.y-=1
  -- this.flip.x=maybe()
  -- this.flip.y=maybe()
  this.solids=false
 end,
 update=function(this)
  this.spr+=0.3
  if this.spr>=32 then
   destroy_object(this)
  end
 end,
 -- draw=function(this)
 --  spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)
 -- end
}

jump_cloud={
 init=function(this)
  local p_flipx= this.flip.x and -1 or 1
  this.spr=30
  this.spd.y=-0.25
  this.spd.x=-0.25*p_flipx
  this.x+=2
  this.x-=(5*p_flipx)
  this.y+=0
  -- this.flip.x=maybe()
  this.flip.y=1
  this.solids=false
 end,
 update=function(this)
  this.spr+=0.2
  if this.spr>=31 then
   destroy_object(this)
  end
 end,
 draw=function(this)
  spr(this.spr,this.x,this.y,0.6,0.6,this.flip.x,this.flip.y)
  -- sspr(this.spr,this.x,this.y,8,8,this.flip.x,this.flip.y)
 end
}

puff={
	init=function(this)
  local p_flipx= this.flip.x and -1 or 1
  this.spr=13
  this.spd.y=0
  this.spd.x=2*p_flipx
  this.x+=3*p_flipx
  -- this.x+=-1+rnd(2)
  -- this.y+=-1+rnd(2)
		-- this.flip.x=p_flip.x
		-- this.flip.y=maybe()
		this.solids=false
  this.hitbox={x=0,y=0,w=8,h=10}
	end,
	update=function(this)
		this.spd.x*=0.95
  this.spr+=0.15
		if this.spr>=14 then
			destroy_object(this)
		end
	end
}

mouthvoid={
 init=function(this)
  this.p_flipx= this.flip.x and -1 or 1
  this.player=getobjoftype(player)
  this.spr=0
  this.spd.y=0
  this.spd.x=0*this.p_flipx
  this.oy=0
  this.ox=10
  this.x+=this.ox*this.p_flipx
  -- this.x+=-1+rnd(2)
  -- this.y+=-1+rnd(2)
  -- this.flip.x=p_flip.x
  -- this.flip.y=maybe()
  this.solids=false
  this.hitbox={x=0,y=-2,w=10,h=12}
 end,
 update=function(this)
  -- this.spd.x*=0.95
  -- this.spr+=0.15
  if this.player ~= nil then
   -- this.player=getobjoftype(player)
   this.y=this.player.y-2
   this.x=this.player.x+(this.ox*this.p_flipx)
   this.x+=(this.flip.x and -1 or -2)
   if not this.player.inhaling then
    destroy_object(this)
   end
  end
 end,
 -- draw=function(this)
 --  rectfill(this.x,this.y,this.x+this.hitbox.w,this.y+this.hitbox.h ,7)
 -- end
}


fruit={
	tile=26,
	if_not_fruit=true,
	init=function(this) 
		this.start=this.y
  this.cx=this.x
  this.cy=this.y
  this.ox=0
		this.oy=0
  this.oxi=2
  this.oyi=2
  this.center={x=0,y=0,dx=0,dy=0}
  this.offsets={-1,0,1}
  this.player=getobjoftype(player)
  this.incount=0
	end,
	update=function(this)
  this.player=getobjoftype(player)
  if this.player~=nil then
   this.center.x = this.x + 4
   this.center.y = this.y + 4
 	 local hit=this.collide(player,0,0)
   local inhaled = this.collide(mouthvoid,0,0)
   if inhaled~=nil then
    inhale_object(this)
   else
    -- if not/stop inhaling
    if this.incount>= 1 then
     this.x=this.cx
     this.y=this.cy
    end
    this.incount=0
  		this.oy+=1
  		this.y=this.start+sin(this.oy/40)*2.5
    if hit~=nil then
     this.got=true
    end
   end
   if this.got then
    sfx_timer=20
    got_fruit[1+level_index()] = true
    if this.inhaled then
     init_object(glomp,this.x,this.y)
     glomp_object()
     sfx(6)
    else
     init_object(lifeup,this.x,this.y)
     sfx(13)
    end
    destroy_object(this)
   end
  end -- end if player~=nil
	end,
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
  this.cx=this.x
  this.cy=this.y
  this.ox=0
  this.oy=0
  this.oxi=2
  this.oyi=2
  this.center={x=0,y=0,dx=0,dy=0}
  this.offsets={-1,0,1}
  this.player=getobjoftype(player)
  this.incount=0
	end,
	update=function(this)
  this.player=getobjoftype(player)
  if this.player~=nil then
   this.center.x = this.x + 4
   this.center.y = this.y + 4
   local hit=this.collide(player,0,0)
   this.inhaled = this.collide(mouthvoid,0,0)
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
    if this.inhaled==nil then
     this.step+=0.05
     this.spd.y=sin(this.step)*0.5
    end
   end
   -- collect
   if this.inhaled~=nil then
    inhale_object(this)
   else
    -- if not/stop inhaling
    if this.incount>= 1 then
     this.x=this.cx
     this.y=this.cy
    end
    this.incount=0
   end
 		if hit~=nil then
    this.got=true
   end
   if this.got then
 		 hit.djump=max_djump
 			sfx_timer=20
    got_fruit[1+level_index()] = true
    if this.inhaled then
     init_object(glomp,this.x,this.y)
     sfx(6)
     glomp_object()
    else
  			sfx(13)
     init_object(lifeup,this.x,this.y)
    end
 			destroy_object(this)
 		end
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
  this.x-=4
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
  print("hiii",this.x-2,this.y,7+this.flash%2)
 end
}

glomp = {
	init=function(this)
		this.spd.y=-0.25
		this.duration=30
		this.x-=6
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
		print("glomp",this.x-2,this.y,7+this.flash%2)
	end
}

fake_wall = {
	tile=64,
	if_not_fruit=true,
 init=function(this)
  this.cx=this.x
  this.cy=this.y
  this.ox=0
  this.oy=0
  this.oxi=2
  this.oyi=2
  this.center={x=0,y=0,dx=0,dy=0}
  this.offsets={-1,0,1}
  this.player=getobjoftype(player)
  this.incount=0
  this.sprite_offset=8
 end,
	update=function(this)
  this.player=getobjoftype(player)
  if this.player~=nil then
   this.center.x = this.x + 4
   this.center.y = this.y + 4
 		this.hitbox={x=-1,y=-1,w=18,h=18}
   -- local hit = this.collide(player,0,0)
 		-- if hit~=nil and hit.dash_effect_time>0 then
   local hit = this.collide(puff,0,0)
   local inhaled = this.collide(mouthvoid,0,0)
   if inhaled~=nil then
    inhale_object(this)
   else
    -- if not/stop inhaling
    if this.incount>= 1 then
     this.x=this.cx
     this.y=this.cy
    end
    this.incount=0
    this.sprite_offset=8
    if hit~=nil then
     this.got=true
    end
   end
   if this.got then
    if this.inhaled then
     sfx_timer=20
     sfx(6)
     init_object(glomp,this.x,this.y)
     glomp_object()
    else
     sfx_timer=20
     sfx(16)
    end
    destroy_object(this)
    init_object(smoke,this.cx,this.cy)
    init_object(smoke,this.cx+8,this.cy)
    init_object(smoke,this.cx,this.cy+8)
    init_object(smoke,this.cx+8,this.cy+8)
    init_object(fruit,this.cx+4,this.cy+4)
 		end
 		this.hitbox={x=0,y=0,w=16,h=16}
  end
	end,
	draw=function(this)
		spr(64,this.x,this.y)
		spr(65,this.x+this.sprite_offset,this.y)
		spr(80,this.x,this.y+this.sprite_offset)
		spr(81,this.x+this.sprite_offset,this.y+this.sprite_offset)
	end
}
add(types,fake_wall)

key={
	tile=8,
	if_not_fruit=true,
 init=function(this) 
  this.cx=this.x
  this.cy=this.y
  this.ox=0
  this.oy=0
  this.oxi=2
  this.oyi=2
  this.center={x=0,y=0,dx=0,dy=0}
  this.offsets={-1,0,1}
  this.player=getobjoftype(player)
  this.incount=0
 end,
	update=function(this)
		local was=flr(this.spr)
		this.spr=9+(sin(frames/30)+0.5)*1
		local is=flr(this.spr)
		if is==10 and is!=was then
			this.flip.x=not this.flip.x
		end
  this.player=getobjoftype(player)
  if this.player~=nil then
   this.center.x = this.x + 4
   this.center.y = this.y + 4
   local hit=this.collide(player,0,0)
   local inhaled = this.collide(mouthvoid,0,0)
   if inhaled~=nil then
    inhale_object(this)
   else
    -- if not/stop inhaling
    if this.incount>= 1 then
     this.x=this.cx
     this.y=this.cy
    end
    this.incount=0
    if hit~=nil then
     this.got=true
    end
   end
 		if this.got then
    if this.inhaled then
     init_object(glomp,this.x,this.y)
     glomp_object()
  			sfx_timer=20
     sfx(6)
    else
     -- else code
     sfx_timer=10
     sfx(23)
    end
    destroy_object(this)
    has_key=true
 		end
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
				music(17,500,7)
				-- sfx(37)
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
		
		spr(22,this.x,this.y)
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
		this.spr=118+(frames/5)%2
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

function init_object(type,x,y,flipx)
	if type.if_not_fruit~=nil and got_fruit[1+level_index()] then
		return
	end
 local flipx = flipx or false
	local obj = {}
	obj.type = type
	obj.collideable=true
	obj.solids=true

	obj.spr = type.tile
	obj.flip = {x=flipx,y=false}

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

function hit_ground_star(obj)
 local xoffsets,yoffsets={-1,0,1},{-1,0,1}
 local oxi,oyi=rand_int_between(1,#xoffsets),rand_int_between(1,#yoffsets)
 local sx,sy=xoffsets[oxi],yoffsets[oyi]
 if sx == 0 and sy == 0 then sx=1 end
 add(hitground_particles,{
  x=obj.x+4,
  y=obj.y+4,
  t=rand_int_between(5,7),
  spd={
   x=sx,
   y=sy
  }
 })
end

function kill_player(obj)
	sfx_timer=12
	sfx(0)
 -- music(-1)
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
  music(14,1500,7)
 elseif room.x==3 and room.y==1 then
  music(3,1500,7)
 elseif room.x==4 and room.y==2 then
  music(14,1500,7)
 elseif room.x==5 and room.y==3 then
  music(14,1500,7)
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
 player.p_fly=false

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
   -- music(2,0,7)
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
			pal(14,c)
			pal(8,c)
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
   bg_col=1
  else
   bg_col=1
  end
	end
	rectfill(0,0,128,128,bg_col)

	-- clouds
	if not is_title() then
		foreach(clouds, function(c)
			c.x += c.spd
			rectfill(c.x,c.y,c.x+c.w,c.y+4+(1-c.w/64)*12,new_bg~=nil and 10 or 2)
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
		p.y += p.spd
		p.x -= p.spd + sin(p.off)
		p.off+= min(0.05,p.spd/32)
		rectfill(p.x,p.y,p.x+p.s,p.y+p.s,p.c)
		if p.y>128+4 then 
			p.y=-4
			p.x=rnd(256)
		end
	end)
	
 -- hit ground particles
 foreach(hitground_particles, function(p)
  p.x += p.spd.x
  p.y += p.spd.y
  p.t -=1
  if p.t <= 0 then del(hitground_particles,p) end
  -- rectfill(p.x-p.t/5,p.y-p.t/5,p.x+p.t/5,p.y+p.t/5,14+p.t%2)
  circfill(p.x,p.y,1,10)
 end)

	-- dead particles
	foreach(dead_particles, function(p)
		p.x += p.spd.x
		p.y += p.spd.y
		p.t -=1
		if p.t <= 0 then del(dead_particles,p) end
		-- rectfill(p.x-p.t/5,p.y-p.t/5,p.x+p.t/5,p.y+p.t/5,14+p.t%2)
  spr(102,p.x-p.t/5,p.y-p.t/5,1,1)
	end)
	
	-- draw outside of the screen for screenshake
	rectfill(-5,-5,-1,133,0)
	rectfill(-5,-5,133,-1,0)
	rectfill(-5,128,133,133,0)
	rectfill(128,-5,133,133,0)
	
	-- credits
	if is_title() then
  print("an ex.ult videotainment mod",10,4,5)
  print("dev/design: @nosplendorr",16,10,5)
  print("art/anim: @resplendorr",20,16,5)
  print("z+x / arrow keys",32,78,5)
  print("arrangements: jacob regus",14,94,5)
  print("green greens based on @trianull",3,100,5)
  print("thanks: caleb, lucy, tony,",12,106,5)
  print("c.a.f.e., celeste team, + hal",6,112,5)
		print("listen to @youretooshow ep 46",6,118,5)
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

function getobjoftype(type)
 local obj
 local pos={}
 for i=1,count(objects) do
  obj=objects[i]
  if obj ~=nil and obj.type == type then
   -- pos.x,pos.y=other.x,other.y
   return obj
  end
 end
end

function glomp_object()
 local obj
 for i=1,count(objects) do
  obj=objects[i]
  if obj ~=nil and obj.type == player then
   obj.glomp_timer=10
   obj.inhale_timer=0
  end
 end
end

function rand_int_between(l,h) --inclusive
 return flr(rnd(h+1-l))+l
end

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
000000000000000000000000000000000000000000eeee000000000000eeee0000aaaaa0000aaa000000a000000770777007770000006600ee0eeee000000000
0000000000000000000000000000000000eeee000eeeeee000000000eeeeeeee00a000a0000a0a000000a000077777767777777000067770eeee1e1e00000000
0000000000eeee0000eeee0000eeee000eeeeee00ee1e1e000000000eee1e1ee00a909a0000a0a000000a0007766666667767777006777770eeeeeeee0eeee0e
000000000ee1e1e00eeee1e00eee1ee00ee1e1e00ee1e1e0000000000ee1e1e0009aaa900009a9000000a0007677766676666677076776770eee222e0ee1e1e0
000000000ee1e1e00eeee1e00eee1ee0eee1e1eeeeeeeeee00eeee000eeeeee00000a0000000a0000000a0000000000000000000077667770eee222e0ee1e1e0
000000000eeeeee00eeeeee0eeeeeeee0eeeeee0eeeeeeee0eeeeee00eeeeee00099a0000009a0000000a0000000000000000000667777760eee222e0eeeeee0
0000000000eeee0080eeee0800eeee0000eeee0000eeee000ee1e1e000eeee000009a0000000a0000000a00000000000000000000066776008eeeee008eeee00
000000000880088088000088088008800088800000808000088eee800080800000aaa0000009a0000000a0000000000000000000000066000880000080080000
5555555500000000000000000000000000000000000000000000a0004999999449999994499909940b0b30b0677577500b0b30b0000000000000000070000000
555555550000000000000000000000000000000000000000007aaa0091111119911141199114091900bbb30007c5c75600bbb300007700000770070007000007
550000550000000000000000000000000aaaaaa00000000007aa9990911111199111911949400419028bb82000555500028bb820007770700777000000000000
55000055000600000499994000000000a998888a111111110aa90090911111199494041900000044287887820605506028788782077777700770000000000000
55000055060550600050050000000000a988888a100000010aa9a000911111199114094994000000878778780000600087877878077777700000700000000000
55000055005555000005500000000000aaaaaaaa111111110a99a000911111199111911991400499878888780000000087888878077777700000077000000000
55555555657c5c700050050000000000a980088a1444444100949000911111199114111991404119288888820000000028888882070777000007077007000070
55555555057757760005500004999940a988888a1444444100040000499999944999999444004994028888200000000002888820000000007000000000000000
5bbbbbb55bbbbbbbbbbbbbbbbbbbbbb5bb33333333333333333333bb5bbbbbb55555555555555555555555550600000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333bbbbbbbbbbb5555555555555550055555555506000000bbbb00000777770000000000000000
bbb3bbbbbbbb33333bbbbbb33333bbbbbbb333333333333333333bbbbbbbbbbb555555555555550000555555775000000b3333b0007766700000000000000000
bb3333bbbbb33333333bb33333333bbbbbbb3333333333333333bbbbbbb33bbb5555555555555000000555557c55600003333830076777000000000000000000
bb3333bbbb33333333333333333333bbbbbb3333333333333333bbbbbb3333bb5555555555550000000055555555000003e33330077660000777770000000000
bbb33bbbbb33bb3333333333333b33bbbbb333333333333333333bbbbb3333bb5555555555500000000005557c50000003333330077770000777767007700000
bbbbbbbbbb33bb3333333333333333bbbbb333333333333333333bbbbb3b33bb555555555500000000000055770600000333ee30000000000000007700777770
5bbbbbb5bb33333333333333333333bbbb33333333333333333333bbbb3333bb5555555550000000000000056000000003338e30000000000000000000077777
bb3333bbbb33333333333333333333bb5bbbbbbbbbbbbbbbbbbbbbb5bbb333bb5555555550000000000000050000000603333330000000000000000000000000
bbb333bbbb33333333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbb50555555550000000000005500006077038333300000000000aa0aa000000000
bbb333bbbb33b333333333333bb333bbbbbb333bbbbbbbbbb333bbbbbbb33bbb555500555550000000000555000005c7033333300000000000aaaaa000000030
bb333bbbbb333333333333333bb333bbbbb33333b3bbbb3333333bbbbb333bbb555500555555000000005555000055550333e33000000000000a9a00000000b0
bb333bbbbbb33333333bb33333333bbbbbb3333333bbbb3b33333bbbbb3333bb555555555555500000055555000655c7003333000000b00000aaaaa000000b30
bbb33bbbbbbb33333bbbbbb33333bbbbbbbb333bbbbbbbbbb333bbbbbb3333bb5505555555555500005555550000057700044000000b000000aa3aa003000b00
bbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbb5555555555555550055555550000605500044000030b00300000b00000b0b300
bb3333bb5bbbbbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbbbb55bbbbbb55555555555555555555555550000006000999900030330300000b00000303300
07777777777777700777777777777777777777700777777000000000000000003333333300000000000000000000000000000000000000000000000000000000
77744997799447777000077700007770000077777000777700000000000000003bb3333300000000000000000000000000000000000000000000000000000000
774999977999947770cc777cccc777ccccc7770770c7770700000000000000003bb33b3300000000000000eee0000000eee7777eee0000000eee000000000000
749999777799994770c777cccc777ccccc777c0770777c070000000000000000333333330000000000000e000e0007ee0000000000ee7000e000e00000000000
7499777777779947707770000777000007770007777700070002dddddddd2000333333330000000000007000000ee0000000000000000ee00000070000000000
777777777777777777770000777000007770000777700007002dddddddddd20033b33333000000000000e00000700000000000000000000700000e0000000000
79777777777777977000000000000000000c000770000c0700dddddddddddd0033333b3300000000000700000e0000000000000000000000e000007000000000
79977777777779977000000000000000000000077000000700d22222d2d22d003333333300000000000e0000e000000000000000000000000e0000e000000000
79997777777799977000000000000000000000077000000700dddddddddddd000000000000000000000e000e00000000000000000000000000e000e000000000
79997777777799977000000c000000000000000770cc000700d22d2222d22d000000000000000000000020070000000000000000000000000070020000000000
799777777777799770000000000cc0000000000770cc000700dddddddddddd000000000000000000000000000000000000000000000000000000000000000000
749777799777794770c00000000cc00000000c0770000c0700ddd222d22ddd000000000000000000000000000000000000000000000000000000000000000000
74777999999777477000000000000000000000077000000700dddddddddddd005555555577777700070007000777770077777700077777007777770077777700
777999999999977770000000000000000000000770c0000700dddddddddddd005555555577777770777007707777777077777770777777707777777077777770
777449999994477770000000c0000000000000077000000700dd77ddd7777d005555555500770000777707707700000077000000770000000077000077000000
07777777777777707000000000000000000000077000c00707777777777777705555555500ee0000eeeeeee0ee0eee00eeee0000eeeeeee000ee0000eeee0000
00000000000000007000000000000000000000077000000700099000500000000000000500ee0000ee0eeee0ee000ee0ee000000000000e000ee0000ee000000
00aaaaaaaaaaaa00700000000000000000000007700c0007999aa9005500000000000055eeeeee00ee00eee0eeeeeee0eeeeee00eeeeeee000ee0000eeeeee00
0a999999999999a0700000000000c00000000007700000079aa779905550000000000555eeeeeee0ee00ee000eeeee00eeeeeee00eeeee0000ee0000eeeeeee0
a99aaaaaaaaaa99a7000000cc0000000000000077000cc07097777a9555500000000555500000000000000000000000000000000000000000000000000000000
a9aaaaaaaaaaaa9a7000000cc0000000000c00077000cc0709a77a90555555555555555500000000000000000000000000000000000000000000000000000000
a99999999999999a70c00000000000000000000770c000079a7a7900555555555555555500000000000000e0000000000000000000000000000e000000000000
a99999999999999a700000000000000000000007700000079999a900555555555555555500000000000000e0000000000000000000000000000e000000000000
a99999999999999a0777777777777777777777700777777000009900555555555555555500000000000000020000000000000000000000000020000000000000
aaaaaaaaaaaaaaaa07777777777777777777777007777770004bbb00004b000000000000000000000000000e00000000000000000000000000e0000000000000
a49494a11a49494a70007770000077700000777770007777004bbbbb004bb00080080000000000000000e80020000000000000000000000002008e0000000000
a494a4a11a4a494a70c777ccccc777ccccc7770770c7770704200bbb042bbbbb08eeee000000000000080080e000000000000000000000000e08008000000000
a49444aaaa44494a70777ccccc777ccccc777c0770777c07040000000400bbb00eeeeee00000000000e000000e0000000000000000000000e000000e00000000
a49999aaaa99994a7777000007770000077700077777000704000000040000000eeeeee00000000000800000002e000000000000000000e20000000800000000
a49444999944494a77700000777000007770000777700c0742000000420000000eeeeee0000000000080000000002e20000000000002e2000000000800000000
a494a444444a494a70000000000000000000000770000007400000004000000000eeee0e00000000000800002000000222222222222000000200008000000000
a49499999999494a0777777777777777777777700777777040000000400000000e00000000000000000022220000000000000000000000000022220000000000
00000000000000008242525252528452339200001323232352232323232352230000000000000000b302000013232352526200a2828342525223232323232323
00000000000000a20182920013232352363636462535353545550000005525355284525262b20000000000004252525262828282425284525252845252525252
00000000000085868242845252525252b1000000b1b1b1b103b1b1b1b1b103b100000000000000111102000000a282425233000000a213233300009200008392
000000000000110000a2000000a28213000000002636363646550000005525355252528462b2a300000000004252845262828382132323232323232352528452
000000000000a201821323525284525200000000000000007300000000007300000000000000b343536300410000011362b2000000000000000000000000a200
0000000000b302b2002100000000a282000000000000000000560000005526365252522333b28292001111024252525262019200829200000000a28213525252
0000000000000000a2828242525252840000000000000000b10000000000b1000000000000000000b3435363930000b162273737373737373737374711000000
000000110000b100b302b20000000082000000000000000000000000005600005252338282828201a31222225252525262820000a20011111100008283425252
0000000000000093a382824252525252000000000011000000000011000000001100000000000000000000020182001152222222222222222222222232b20000
0000b302b200000000b10000000000a200000000000000009300000000000000846282828283828282132323528452526292000000112434440000a282425284
00000000000000a2828382428452525200000000b302b2930000b302b20000007293a30000000000000000b1a282931252845252525252232323232362b20000
000000b10000001100000000000000000000000093000086820000a3000000005262828201a200a282829200132323236211111111243535450000b312525252
00000000000000008282821323232323820000a300b1a382930000b100000000738283931100000000000011a382821323232323528462829200a20173b20000
000000000000b302b2000000000000000000a385828286828282828293000000526283829200000000a20000000000005222222232263636460000b342525252
00000011111111a3828201b1b1b1b1b182938282930082820000000000000000b100a282721100000000b372828283b122222232132333000000869200000000
00100000000000b1000000000000000086938282828201920000a20182a37686526282829300000000000000000000005252845252328283920000b342845252
00008612222232828382829300000000828282828283829200000000000000001100a382737200000000b373a2829211525284628382a2000000a20000000000
00021111111111111111111111110000828282a28382820000000000828282825262829200000000000000000000000052525252526201a2000000b342525252
00000113235252225353536300000000828300a282828201939300001100000072828292b1039300000000b100a282125223526292000000000000a300000000
0043535353535353535353535363b2008282920082829200061600a3828382a28462000000000000000000000000000052845252526292000011111142525252
0000a28282132362b1b1b1b1000000009200000000a28282828293b372b2000073820100110382a3000000110082821362101333000000000000008293000000
0002828382828202828282828272b20083820000a282d3000717f38282920000526200000000000093000000000000005252525284620000b312223213528452
000000828392b30300000000002100000000000000000082828282b303b20000b1a282837203820193000072a38292b162710000000000009300008382000000
00b1a282820182b1a28283a28273b200828293000082122232122232820000a3233300000000000082920000000000002323232323330000b342525232135252
000000a28200b37300000000a37200000010000000111111118283b373b200a30000828273039200828300738283001162930000000000008200008282920000
0000009200a28200008200008282000001920000000213233342846282243434000000000000000082000085860000008382829200000000b342528452321323
0000100082000082000000a2820300002222321111125353630182829200008300009200b1030000a28200008282001262829200000000a38292008282000000
00858600008282a3828293008292000082001000001222222252525232253535000000f3100000a3820000a2010000008292000000009300b342525252522222
0400122232b200839321008683039300528452222262c000a28282820000a38210000000a3738000008293008292001362820000000000828300a38201000000
00a282828292a2828283828282000000343434344442528452525252622535350000001263000083829300008200c1008210d3e300a38200b342525252845252
1232425262b28682827282820103820052525252846200000082829200008282320000008382930000a28201820000b162839300000000828200828282930000
0000008382000000a28201820000000035353535454252525252528462253535000000032444008282820000829300002222223201828393b342525252525252
525252525262b2b1b1b1132323526200845223232323232352522323233382825252525252525252525284522333b2822323232323526282820000b342525252
52845252525252848452525262838242528452522333828292425223232352520000000000000000000000000000000000000000000000000000000000000000
525252845262b2000000b1b1b142620023338276000000824233b2a282018283525252845252232323235262b1b10083921000a382426283920000b342232323
2323232323232323232323526201821352522333b1b1018241133383828242840000000000000000000000000000000000000000000000000000000000000000
525252525262b20000000000a242627682828392000011a273b200a382729200525252525233b1b1b1b11333000000825353536382426282410000b30382a2a2
a1829200a2828382820182426200a2835262b1b10000831232b2000080014252000000000000a300000000000000000000000000000000000000000000000000
528452232333b20000001100824262928201a20000b3720092000000830300002323525262b200000000b3720000a382828283828242522232b200b373928000
000100110092a2829211a2133300a3825262b2000000a21333b20000868242520000000000000100009300000000000000000000000000000000000000000000
525262122232b200a37672b2a24262838292000000b30300000000a3820300002232132333b200000000b303829300a2838292019242845262b2000000000000
00a2b302b2a30082b302b200110000825262b200000000b1b10000a283a2425200000000a3008200008300000000000000000000000000000000000000000000
525262428462b200a28303b2214262928300000000b3030000000000a203e3415252222232b200000000b30392000000829200000042525262b2000000000000
000000b100a2828200b100b302b211a25262b200000000000000000092b3428400000000827682000001009300000000000000000094a4b4c4d4e4f400000000
232333132362b221008203b2711333008293858693b3031111111111114222225252845262b200001100b303b2000000821111111142528462b2000000000000
000000000000110176851100b1b3020084621111111100000000000000b3135200000000828382670082768200000000000000000095a5b5c5d5e5f500000000
82000000a203117200a203b200010193828283824353235353535353535252845252525262b200b37200b303b2000000824353535323235262b2000011000000
0000000000b30282828372b20000b100525232122232b200000000000000b14200000000a28282123282839200000000000000000096a6b6c6d6e6f600000000
9200110000135362b2001353535353539200a2000001828282829200b34252522323232362b200b30300b3030000000092b1b1b1b1b1b34262b200b372b20000
001100000000b1a2828273b200000000232333132333b200001111000000b342000000868382125252328293a3000000000000000097a7b7c7d7e7f700000000
00b372b200a28303b2000000a28293b3000000000000a2828382827612525252b1b1b1b173b200b30393b30300000000000000000000b34262b271b303b20000
b302b211000000110092b100000000a3b1b1b1b1b1b10011111232110000b342000000a282125284525232828386000000000000000000000000000000000000
80b303b20000820311111111008283b311111111110000829200928242528452000000a3820000b30382b37300000000000000000000b3426211111103b20000
00b1b302b200b372b200000000000082b21000000000b31222522363b200b3138585868292425252525262018282860000000000000000000000000000000000
00b373b20000a21353535363008292b32222222232111102b20000a21323525200000001839200b3038282820000000011111111930011425222222233b20000
100000b10000b303b200000000858682b27100000000b3425233b1b1000000b182018283001323525284629200a2820000000000000000000000000000000000
9300b100000000b1b1b1b1b100a200b323232323235363b100000000b1b1135200000000820000b30382839200000000222222328283432323232333b2000000
329300000000b373b200000000a20182111111110000b31333b100a30000000000a28293f3123242522333020000820000000000000000000000000000000000
829200001000410000000000000000b39310d30000a28200000000000000824200000086827600b30300a282760000005252526200828200a30182a2000000a3
62820000000000b100000093a382838222222232b20000b1b1000083000000860000122222526213331222328293827600000000000000000000000000000000
017685a31222321111111111002100b322223293000182930000000080a301131000a383829200b373000083920000005284526200a282828283920000000082
62839321000000000000a3828282820152845262b200000093000082a300a3821000135252845222225252523201838200000000000000000000000000000000
828382824252522222222232007100b352526282a38283820000000000838282320001828200000083000082010000005252526271718283820000000000a382
628201729300000000a282828382828252528462b20000a38300a382018283821222324252525252525284525222223200000000000000000000000000000000
__gff__
0000000000000000000000000000000004020000000000000000000200000000030303030303030304040402020000000303030303030303040404020202020200001313131302020302020202020202000013131313020204020202020202020000131313130004040202020202020200001313131300000002020202020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2331252548252532323232323300002425262425252631323232252628282824252525252525323328382828312525253232323233000000313232323232323232330000002432323233313232322525252525482525252525252526282824252548252525262828282824254825252526282828283132323225482525252525
252331323232332900002829000000242526313232332828002824262a102824254825252526002a2828292810244825282828290000000028282900000000002810000000372829000000002a2831482525252525482525323232332828242525254825323338282a283132252548252628382828282a2a2831323232322525
252523201028380000002a00003e3d24252523201028292900282426003a382425252548253300002900002a0031252528382900003a676838280000000000003828393e003a2800000000000028002425253232323232332122222328282425252532332828282900002a283132252526282828282900002a28282838282448
3232332828282900000000003f2020244825262828290000002a243300002a2425322525260000000000000000003125290000000021222328280000000000002a2828343536290000000000002839242526212223202123313232332828242548262b000000000000001c00003b242526282828000000000028282828282425
2340283828293a2839000000343522252548262900000000000030000000002433003125333d3f00000000000000003100001c3a3a31252620283900000000000010282828290000000011113a2828313233242526103133202828282838242525262b000000000000000000003b2425262a2828670000002a28283828282425
263a3e3d3e102829000000000000312525323300000000110000370000003e2400000037212223000000000000000000395868282828242628290000000000002a2828290000000000002123283828292828313233282829002a002a2828242525332b0c00000011110000000c3b314826112810000000006828282828282425
252235353628280000000000003a282426003d003a3900270000000000002125001a000024252611111111000000002c28382828283831332800000017170000002a000000001111000024261028290028281b1b1b282800000000002a2125482628390000003b34362b000000002824252328283a67003a28282829002a3132
25333828282900000000000000283824252320201029003039000000005824480000003a31323235353536675800003c282828281028212329000000000000000000000000003436003a2426282800003828390000002a29000000000031323226101000000000282839000000002a2425332828283800282828390000001700
2600002a28000000003a283a283e3e2425252223283900372858390068283132000000282828282820202828283921222829002a28282426000000000000000000000000000020382828312523000000282828290000000000003a67682828003338280b00000010382800000b00003133282828282868282828280000001700
330000002867580000281028283422252525482628286720282828382828212200003a283828102900002a28382824252a0000002838242600000017170000000000000000002728282a283133390000282900000000000000002a28282829002a2839000000002a282900000000000028282838282828282828290000000000
0000003a2828383e3f2828283828242548252526002a282729002a28283432250000002a282828000000002810282425000000002a282426000000000000000000000000000037280000002a28283900280000003928390000000000282800000028290000002a2828000000000000002a282828281028282828675800000000
000000283e282821232800002a28242532322526003a2830000000002a28282400000000002a281111111128282824480000003a28283133000000000000171700013f0000002029000000003828000028013a28281028580000003a28290000002a280c0000003a380c00000000000c00002a2828282828292828290000003a
3d013f2123282a313329001111112425002831263a3829300000000000002a310000000000002834222236292a0024253e013a3828292a00000000000000000035353536000020000000003d2a28671422222328282828283900582838283d00003a290000000028280000000000000000002a28282a29000058100012002a28
22222225262900212311112122222525002a3837282900301111110000003a2800013f0000002a282426290000002425222222232900000000000000171700002a282039003a2000003a003435353535252525222222232828282810282821220b10000000000b28100000000b0000002c00002838000000002a283917000028
2548252526111124252222252525482500012a2828673f242222230000003828222223000012002a24260000001224252525252600000000171700000000000000382028392827080028676820282828254825252525262a28282122222225253a28013d0000006828390000000000003c0168282800171717003a2800003a28
25252525252222252525252525252525222222222222222525482667586828282548260000270000242600000021252525254826171700000000000000000000002a2028102830003a282828202828282525252548252600002a2425252548252821222300000028282800000000000022222223286700000000282839002838
2532330000002432323232323232252525252628282828242532323232254825253232323232323225262828282448252525253300000000000000000000005225253232323233313232323233282900262829286700000000002828313232322525253233282800312525482525254825254826283828313232323232322548
26282800000030402a282828282824252548262838282831333828290031322526280000003a28283133282838242525482526000000000000000000000000522526000000000000002a10282838390026281a3820393d000000002a3828282825252628282829003b2425323232323232323233282828282828102828203125
3328390000003700002a3828002a2425252526282828282028292a0000002a313328111111282828000028002a312525252526000000000000000000000000522526000000001111000000292a28290026283a2820102011111121222328281025252628382800003b24262b002a2a38282828282829002a2800282838282831
28281029000000000000282839002448252526282900282067000000000000003810212223283829003a1029002a242532323367000000000000000000004200252639000000212300000000002122222522222321222321222324482628282832323328282800003b31332b00000028102829000000000029002a2828282900
2828280000000000002a2828280024252525262700002a2029000000000000002834252533292a0000002a00111124252223282800002c46472c00000042535325262800003a242600000000002425252525482631323331323324252620283822222328292867000028290000000000283800111100001200000028292a0000
283828000000000000003a28290024254825263700000029000000000000003a293b2426283900000000003b212225252526382867003c56573c4243435363633233283900282426111111111124252525482526201b1b1b1b1b24252628282825252600002a28143a2900000000000028293b21230000170000112867000000
2828286758000000586828380000313232323320000000000000000000272828003b2426290000000000003b312548252533282828392122222352535364000029002a28382831323535353522254825252525252300000000003132332810284825261111113435361111111100000000003b3133111111111127282900003b
2828282810290000002a28286700002835353536111100000000000011302838003b3133000000000000002a28313225262a282810282425252662636400000000000028282829000000000031322525252525252667580000002000002a28282525323535352222222222353639000000003b34353535353536303800000017
282900002a0000000000382a29003a282828283436200000000000002030282800002a29000011110000000028282831260029002a282448252523000000000039003a282900000000000000002831322525482526382900000017000058682832331028293b2448252526282828000000003b201b1b1b1b1b1b302800000017
283a0000000000000000280000002828283810292a000000000000002a3710281111111111112136000000002a28380b2600000000212525252526001c0000002828281000000000001100002a382829252525252628000000001700002a212228282908003b242525482628282912000000001b00000000000030290000003b
3829000000000000003a102900002838282828000000000000000000002a2828223535353535330000000000002828393300000000313225252533000000000028382829000000003b202b00682828003232323233290000000000000000312528280000003b3132322526382800170000000000000000110000370000000000
290000000000000000002a000000282928292a0000000000000000000000282a332838282829000000000000001028280000000042434424252628390000000028002a0000110000001b002a2010292c1b1b1b1b0000000000000000000010312829000000001b1b1b313328106700000000001100003a2700001b0000000000
00000100000011111100000000002a3a2a0000000000000000000000002a2800282829002a000000000000000028282800000000525354244826282800000000290000003b202b39000000002900003c000000000000000000000000000028282800000000000000001b1b2a2829000001000027390038300000000000000000
1111201111112122230000001212002a00010000000000000000000000002900290000000000000000002a6768282900003f01005253542425262810673a3900013f0000002a3829001100000000002101000000000000003a67000000002a382867586800000100000000682800000021230037282928300000000000000000
22222222222324482611111120201111002739000017170000001717000000000001000000001717000000282838393a0021222352535424253328282838290022232b00000828393b27000000001424230000001200000028290000000000282828102867001717171717282839000031333927101228370000000000000000
254825252526242526212222222222223a303800000000000000000000000000001717000000000000003a28282828280024252652535424262828282828283925262b00003a28103b30000000212225260000002700003a28000000000000282838282828390000005868283828000022233830281728270000000000000000
__sfx__
01080000063620a662086630050000500005000050000500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000011070130701a0702407000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000307103071031720317303274034740367403675035750317502e750137500c7400773005720057100e700000000000000000000000000000000000000000000000000000000000000000000000000000
00040e1625520255202552025520255302653027530285402a5402c5502e55032560375503a5503a5403c7403a5303c7303a5403c7403a5403d7503a5003b500395003b5003a5003b50000000000000000000000
000400000f0701e070120702207017070260701b0602c060210503105027040360402b0303a030300203e02035010000000000000000000000000000000000000000000000000000000000000000000000000000
000300000977009770097600975008740077300672005715357003470034700347003470034700347003570035700357003570035700347003470034700337003370033700337000070000700007000070000700
010300002815225152251522715226153000000000000000000000645107451074510445102441014410142300000382333a2533f253034001010003100001000010000100001000010000000000000000000000
00020000101101211014110161101a120201202613032140321403410000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000070700a0700e0701007016070220702f0702f0602c0602c0502f0502f0402c0402c0302f0202f0102c000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000154471344716447234003f6003f6003f6003f6003f6003f6003f600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000607
01050000073571c057183571c0570000000000073500000007350000000000000000073500000000000000002b0742b0542b0542b054000000000000000071000710009100091000000000000000000000000000
0105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b350000002b350000002b35000000000000000000000000000000000000
010f00001c5241c520000001c5401c540000001c5401c5401c5401c5401c54500000000001c5441c540000001c5401c540000001c540000001c5401c54000000000001c5401c5401c5401c5401c5450000000000
000400000c5501c5601057023570195702c5702157037570285703b5702c5703e560315503e540315303e530315203f520315203f520315103f510315103f510315103f510315103f50000500005000050000500
000400002f7402b760267701d7701577015770197701c750177300170015700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000096450e655066550a6550d6550565511655076550c655046550965511645086350d615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000001f37518375273752730027300243001d300263002a3001c30019300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011400000000000000183250000018325000001832500005183250000518325000051832500005183101800018000000001832518000183251800518325180051832518005183251800518325180051831000000
010200001f0601f0601f0601f0601f0601f0601f0601f0601f0601f0601f0601f0601f06009000130021300213702137021370213702137021370213702137021370213702137021f0601f0601f0601f06013702
010f00001074310400000001c743174001c40010743104001c743000000000000000104001074300000104001c743174001c40010743104001c74300000000001c40010743104000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c6253c0003c625000003c625000003c62500000000000000000000000000000000000
01100000240602406024060240602406024060240602406024060240652470000700240602406024060280602b0600070030060000002f060000002d060000002b0602b0602b060130602806028060280602b060
0110000013320133201c325000001c325000001c325000001c325000001c325000001c325000001c3200000013320133201c325000001c325000001c325000001c325000001c325000001c325000001c32000000
000600001877035770357703576035750357403573035720357103570000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011000000000000000326153c615326153c000326153c6153261500000326153c615326153c615326153c6150000000000326153c6153261500000326153c6153261500000326153c615326153c615326153c615
01100000290602906029060004002606026060260602806026060260602606000400280602806000400260602406024060240602406024060240602406024060240602406024060004001f06000400004001f060
011000001532015320183200000018325000001832500000133201332017320000001732500000173200000013320133201c320000001c325000001c325000001c325000001c325000051c325000001c32000000
011000002906029060290600070026060260602606028060260602606026060007002806028060280602606024060240602406024060240602406024060240602406024060240602406000700004000000000000
01100000153201532018325000001832500000183200000013320133201c325000001c325000001c3200000015420184251c425184251c425184251c4251842513420184251c425184251c425184251c42518425
010800002406024060240600070000700007002406024060260602606000400004002806028060280602806000400280602806000400004002406024060004000040026060260600040000700240602406000000
0108000029750297502975029750297500000029750297502975000000000000000000000000002b0002b0002b7502b75000000000002b7502b75000000000000000000000000000000000000000000000000000
0108000032615000000000000000326150000032615000003c61500000000000000032615000003c61500000326150000000000000003c6150000000000000000000000000000000000000000000000000000000
01100000275642756027560275602656426560265602756429564295602956029560275642756027560295642b5642b5602b5602b5602956429560295602b5642456424560245602456024564245602456026564
011000001114018120201201813020130181302012018110161401b120221201b130221301b130221201b1100f1402212027120221301f130221302712022110141401b120201201b130201301b130201201b110
01100000275642756027560275602656426560265602756429564295602956029560275642756027560295642b5642b5602b5602b5602b5602b5602b5602b5603056430571000000000024564245602456026564
00040000336251a605000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0110000011140241202c1202413020130181302c1201811016140271202e12027130221301b130221201b1100f1402212027120221301f130161301b12016110141401b1202412020130141301b130201201b110
010f00002d55029545245452f5502b5452654530550305402b5452b5502b540375303555035550345403255032550345403055230552245502455030540305402453024530305303053024510245103051030515
010c000019551195511a551315513555135551355513155131551315513155131551315513155017500175001650016500165002b20030200242002b20030200242002b200302003a2002e200002000000000000
011000002756427560275602756026564265602656027564295642956029560295602756427560275602956426554265602656026570265722657226572265722b5752b50000000000001f7601f765000001f760
0010000016270162701f2711f2701f2701f270182711827013271132701d2711d270162711627016270162701b2711b2701b2701b270000001b200000001b2000000000000000000000000000000000000000000
011000001114018120201201813020130181302012018110161401b120221201b130221301b130221201b1101314500000131401a1421314500000131401a1421314500000000000000000000000000000000000
011000000000000000326153c6153261500000326153c6153261500000326153c615326153c615326153c6153261500000326153c6153261500000326153c6153261500000000000000000000000000000000000
0110000013332133321c331003001c335003001c335003001c335003001c335003001c335003001c3300030013332133321c331003001c335003001c335003001c335003001c335003001c335003001c33000000
010f00200c6100e610106101061011610116101361013610136101561015610176101761018610186101a6101a6101c6101c6101a6101a61018610176101561013610116101061011610106100e6100c6100c610
0108011938500385203852034520345203652036520385203852034520345203652036520315203152034520345202f5202f520315203152034520345202f5202f52000500005000050000500005000050000500
01080018387173871734727347173673736727387473872734757347373675736747317573173734747347372f7472f727317373172734737347172f7272f7170070700707007070030700307003070030700307
010800181d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6151d6141d6150060500605006050060500605006050060500605
010600000c6100e610106101061011610116101361013610136101561015610176101761018610186101a6101a6101c6101c6101a6101a61018610176101561013610116101061011610106100e6100c6100c610
010f0000216151d61518615236151f6151a62524622306251f6151f6151f6052b6152962529625286152662526605286152462530600306013060530605136001860018600136001360016600166001d60000600
010f00001d53024525215251f53026525235251c5301c5301c5251c5201c520305202d5202d5202b52029520295202852028520285201c5201c52028020280201c0101c0102801028010165001d5000000000000
010500000373005731077410c741137511b7612437030371275702e5712437030371275702e5712436030361275602e5612435030351275502e5512434030341275402e5412433030331275202e5212431030311
010f00001ff501ff001ff501cf001cf501cf501ff501ff501cf001ef001ef001cf001ef001bf000cf000cf000cf000cf000cf000cf000cf000af000af000af000ff000ff000ff000ff000ff0011f0011f0011f00
010f00001b5241b520000001b5401b540000001b5401b5401b5401b5401b54500000000001b5441b540000001b5401b540000001b540000001b5401b54000000000001b5401b5401b5401b5401b5450000000000
000300001f3302b33022530295301f3202b32022520295201f3102b31022510295101f3002b300225002950000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00002935500300293453037030360303551330524300243050030013305243002430500300003002430024305003000030000300003000030000300003000030000300003000030000300003000030000300
010f00001f5241f520000001f5401f540000001f5401f5401f5401f5401f54500000000001d5441d540000001d5401d540000001d540000001d5401d54000000000001d5401d5401d5401d5401d5450000000000
011000000050000500005000050000500005000050000500005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000200c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000f0001100011000110001100011000110000a0000a0000a0000a0000a0000a0000a0000a0000a00000000
001000000500005000050000500005000050000700007000070000700007000000000f0000f0000f000000000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000c0000c0000c0000c000
0010000003605246050060503605246051b60522605036050060503605116053360522605006051d6050a60537605186052e6051d605006053760537605186052e6051d60511605036050060503605246051d605
00100020326003260032600326003160031600306002e6002a600256001b600136000f6000d6000c6000c6000c6000c6000c6000f600146001d600246002a6002e60030600316003360033600346003460034600
00400000302053020530205332052b20530205302053020530205302053020530205302053020530205302052b2052b2052b20527205292052b2052b2052b2052b2052b2052b2052b2052b2052b2052b2052b205
001000000000000000000000000000000000000000000000000001d75200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 0a 0b 43 44
00 12 18 43 44
01 15 16 18 44
00 19 1a 18 44
00 15 16 18 44
00 1b 1c 18 44
00 1d 1e 1f 44
00 41 2b 18 44
00 20 21 18 44
00 22 24 18 44
00 20 21 18 44
02 27 29 2a 44
00 41 42 43 44
00 41 42 30 44
03 2e 42 30 44
00 41 42 43 44
00 25 31 32 44
00 41 42 43 44
00 41 42 43 44
01 41 42 2c 44
00 0c 13 2c 44
00 35 13 2c 44
00 0c 13 2c 44
02 38 13 2c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
01 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
