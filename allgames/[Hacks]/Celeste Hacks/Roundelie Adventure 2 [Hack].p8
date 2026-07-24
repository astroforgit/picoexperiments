pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--roundelie adventure 2
--made by the creators of roundelie adventure 2
--don't ask what happened to the first roundelie adventure
-------------
roundedash=0
globtimer = 0
firsttime = 0
cutscene = 0
incutscene = 0
fliparchive = 0
conk = 0
txtcolor=5
yarchive = 112
xarchive = 0 
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
maxrun=1

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
		if firstime==0 then
		 this.y=yarchive
		 firstime+=1
		 this.spd.x=xarchive
		elseif level_index()==7 then
		 this.y+=70
		end
		if firstime==3 or firstime==4 then
		 this.y=yarchive
		 if level_index()!=6 and firstime==3 then
		  this.spd.x=xarchive
		 end
		 this.x=118
		 if firstime==3 then
		  firstime+=1
		 end
		end
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
		--create_hair(this)
	end,
	update=function(this)
	conk-=1
	debug=this.spd.x
	roundedash-=1
	if roundedash==14 then
	 this.spd.x=0
 end--]]
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
	
	--roundemoves slidelie
	if conk<1 then
	if btn(k_dash) then
	 if btn(k_down) then
	  this.spd.y+=2
	  if (this.is_solid(1,0) or this.is_solid(-1,0)) and not on_ground then
	   conk=15
	  end
	 elseif btn(k_up) and not this.p_dash then
	  if on_ground then
	   this.spd.y=-2
	   this.gravity=.1
	  end
	 elseif btn(k_down) and not this.p_dash then
	  this.spd.y+=2
	 elseif btn(k_right) and not this.p_dash and roundedash<0 then
	  this.spd.x=15
	  roundedash=15
	 elseif btn(k_left) and not this.p_dash and roundedash<0 then
	  this.spd.x=-15
	  roundedash=15
	 elseif not this.p_dash and on_ground and roundedash<0 then
	  maxrun=3
	 end
	end
	end
		this.p_dash = btn(k_dash)
		
		if on_ground then
			this.grace=6
		--	if this.djump<max_djump then
			-- psfx(54)
			-- this.djump=max_djump
		--	end
		elseif this.grace > 0 then
		 this.grace-=1
		end
		
		if level_index()==11 and this.x>70 then
		 rectfill(32,2,96,31,0)
			spr(28,55,6)
			print("x"..0,64,9,7)
			draw_time(49,16)
			print("deaths:"..deaths,48,24,7)
		end

		--[[this.dash_effect_time -=1
  if this.dash_time > 0 then
   init_object(smoke,this.x,this.y)
  	this.dash_time-=1
  	if btn(k_right) and this.dash_effect_time == 0 then
  	 this.spd.x=10
   	this.spd.y=0
   elseif btn(k_left) and this.dash_effect_time == 0 then
    this.spd.x=-15
    this.spd.y=0 
   end
  else
  --]]

			-- move
			if maxrun>1.1 then
			 if not (abs(this.spd.x)==maxrun) then
			 maxrun-=.15
			 end
			elseif not abs(this.spd.x)==maxrun then
			 maxrun=1
			end
			if roundedash<0 and abs(this.spd.x)<.2 then
			 accel=0.6
			else
			 accel=.3
			end
			local deccel=0.15
			
			if not on_ground then
			 if roundedash<0 then
			 	accel=0.4
				else
				 accel=0.1
				end
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
			 if conk<1 then
				 this.flip.x=(this.spd.x<0)
				end
			end

			-- gravity
			local maxfall=2
			local gravity=0.315

  	if abs(this.spd.y) <= 0.15 then
   	gravity*=.5
			end
		
			-- wall slide
			--if input!=0 and this.is_solid(input,0) and not this.is_ice(input,0) then
		 --	maxfall=0.4
		 --	if rnd(10)<2 then this looks like round(10) xd
		 		--init_object(smoke,this.x+input*6,this.y)
			--	end
		--	end

			if not on_ground then
				this.spd.y=appr(this.spd.y,maxfall,gravity)
			end

			-- jump
			if conk<1 then
			if this.jbuffer>0 then
		 	if this.grace>0 and incutscene==0 then
		  	-- normal jump
		  	psfx(1)
		  	this.jbuffer=0
		  	if ability==1 and this.grace<=6 then
		  	 this.grace=20000
		  	else
		  	 this.grace=2
		  	end
					this.spd.y=-3
					this.spd.x*=.5
					init_object(smoke,this.x,this.y+4)
				else
					-- wall jump
				--	local wall_dir=(this.is_solid(-3,0) and -1 or this.is_solid(3,0) and 1 or 0)
				--	if wall_dir!=0 then
			 	--	psfx(2)
			 	--	this.jbuffer=0
			 	--	this.spd.y=-2
			 	--	this.spd.x=-wall_dir*(maxrun+1)
			 	--	if not this.is_ice(wall_dir*3,0) then
		 			--	init_object(smoke,this.x+wall_dir*6,this.y)
						--end
				--	end
				end
			end
		end
		
			--[[ dash
			local d_full=5
			local d_half=d_full*0.70710678118
		
			if this.djump>0 and dash then
		 	init_object(smoke,this.x,this.y)
		 	this.djump-=1		
		 	this.dash_time=0
		 	has_dashed=true
		 	this.dash_effect_time=2
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
		 		--this.spd.x=0
		 		this.spd.y=v_input*d_full
		 	else
		 		--this.spd.x=(this.flip.x and -1 or 1)
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
		 	--if this.spd.x!=0 then
		 	-- this.dash_accel.y*=0.70710678118
		 --	end	 	 
			elseif dash and this.djump<=0 then
			 psfx(9)
			 init_object(smoke,this.x,this.y)
			end
		
		end
		--]]
		-- animation
		if conk<1 then
		this.spr_off+=0.25
		if not on_ground then
			if this.is_solid(input,0) then
				if btn(0) then
				 this.spr=2
				else
				 this.spr=5
				end
			else
			 this.spr=5
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
		else
		 this.spr=16
		end
		   
		-- next level
		if this.x>120 and level_index()==11 then load_room(7,3) end
		
		if this.x>120 and (level_index()>0 or this.y<50) and level_index()!=7 and level_index()<11 then next_room() yarchive=this.y  xarchive=this.spd.x firstime=0 end
		if this.x<0 and (level_index()!=7 or this.y<30) and (level_index()!=6 or this.y>60) and level_index()>3 and level_index()<8 then prev_room() yarchive=this.y  xarchive=this.spd.x firstime=3 end
	 if this.y<-4 and this.x<50 and level_index()==3 then load_room(0,1) yarchive=80 firstime=1 end
		
		-- was on the ground
		this.was_on_ground=on_ground
		
		if conk>0 then
		 if conk==14 then
		  this.spd.y=-1.7
		 end
		 if conk==13 then this.spd.y=-.7 end
		 if this.flip.x==true then
		  this.spd.x=.5
		 else
		  this.spd.x=-.5
		 end
		end
		if incutscene==1 then
		 this.spd.x=0
		 this.spd.y=1
		 this.spr=1
		end
		
	end, --<end update loop
	
	draw=function(this)
	if btnp(k_jump) and incutscene==1 then
	 cutscene+=1
	 this.index=0
	 this.last=0
	end
	--if cutscene==1 then
--	 cutscene+=1
--	end
	if btnp(k_jump) and cutscene==6 then
	 cutscene=7
	end
	if cutscene==5 then
	 incutscene=0
	end
	if cutscene==9 then
	incutscene=0
	end
	--cutscenes
	if cutscene==0 then
	 this.text="i'm still working out#the controls, how can# i get through those # weird white spikes?"
 elseif cutscene==1 then
  this.text="you can hold right and#x to teleport sideways# a bit, but you can't # do that very often. "
 txtcolor=1
 elseif cutscene==2 then
  this.text="i wonder what happens#if you hold a diffe-"
 txtcolor=5
 elseif cutscene==3 then
  this.text="is that a roundelie?!!"
 txtcolor=1
 elseif cutscene==4 then
  this.text="roundelie means bruh!Œ"
 txtcolor=5
 elseif cutscene==6 then
  this.text="hey you there! have you# tried all your moves? #roundelie can do lots! #try holding directions # and then pressing x. "
 txtcolor=12
 elseif cutscene==7 then
  this.text="that way's a dead end#so once you get what # you want you have to#go back to progress."
 elseif cutscene==8 then
  this.text=" by the way, it would #be nice if you didn't #tell anybody i'm here.#it'd end badly for us"
 elseif cutscene==10 and frames+(seconds*30)+(minutes*3600) >1199 then
  this.text=" have you seen anybody # with sub 40? i have a #message for them.also, #congrats on beating ra2!"
 elseif cutscene==11 and frames+(seconds*30)+(minutes*3600) >1199 then
  load_room(7,3)
  music(-1)
 elseif cutscene==10 then
  this.text="it has been a long time #since i have seen such a# fast roundelie. there #are things i now need to# tell you about me, and# the world around us. "
 elseif cutscene==11 then
  this.text="the adelie and the trees#lived in peace.the trees#guarded a powerful orb,#and the adelie created#massive tunnels held up# by blocks of gray stone."
 elseif cutscene==12 then
  this.text="but the madeline invaded#our mountain.they turned#our constructions into #  farmland and cities.  #now they hold platforms# with magic, not blocks."
 elseif cutscene==13 then
  this.text="the roundelie are unable#to live their peaceful #lives anymore. any time# a madeline sees one,  # they say it means bruh.# i am a wanted criminal#just because i said that# roundelie isn't funny."
 elseif cutscene==14 then
  this.text="i am not a roundeline. i#am a roundelie, and the# leader of a resistance#movement for our freedom.#if you join us, we can # take back the mountain.#join us fellow roundelie."
 elseif cutscene==15 then
  this.text="join us."
 elseif cutscene==16 then
  load_room(7,3)
  music(-1)
 else
  this.text="debug xd"
 end
 if this.x>30 and level_index()==1 and cutscene<5 then
  incutscene=1
 end
 if this.x>85 and level_index()==5 and cutscene<9 and incutscene==0 then
  incutscene=1
  cutscene=6
 end
 if this.x>100 and level_index()==11 and incutscene==0 then
  incutscene=1
  cutscene=10
 end 
		if (this.x>30 and level_index()==1 and incutscene==1) or (this.x>85 and level_index()==5 and incutscene==1) or (level_index()==11 and incutscene==1) then
			if this.index<#this.text then
			 if cutscene<15 then
			  this.index+=2
			 else
			  this.index+=.3
			 end
				if this.index>=this.last+1 then
				 this.last+=1
				 sfx(35)
				end
			end
			this.off={x=8,y=20}
			for i=1,this.index do
				if sub(this.text,i,i)~="#" then
					rectfill(this.off.x-2,this.off.y-2,this.off.x+7,this.off.y+6 ,7)
					print(sub(this.text,i,i),this.off.x,this.off.y,txtcolor)
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
		-- clamp in screen
		if this.x<-1 or this.x>121 then 
			this.x=clamp(this.x,-1,121)
			this.spd.x=0
		end
		
		--set_hair_color(this.djump)
		--draw_hair(this,this.flip.x and -1 or 1)
	 spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)		
	end
}

psfx=function(num)
 if sfx_timer<=0 then
  sfx(num)
 end
end

---create_hair=function(obj)
	--obj.hair={}
--	for i=0,4 do
	--	add(obj.hair,{x=obj.x,y=obj.y,size=max(1,min(2,3-i))})
--	end
---end

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



--[[player_spawn = {
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
--		create_hair(this)

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
--]]

player_spawn = {
 tile=1,
	init=function(this)
	end,
	update=function(this)
	 sfx(4)
 	destroy_object(this)
		init_object(player,this.x,this.y)
 end,
 draw=function(this)
 end
}
add(types,player_spawn)

exposition_roundelie = {
 tile=73,
 init=function(this)
 end,
 update=function(this)
 end,
 draw=function(this)
 if cutscene>5 and cutscene<9 then
  spr(119,this.x,this.y+8)
 else
  spr(73,this.x,this.y)
 end
end
}
add(types,exposition_roundelie)


maddy = {
 tile=109,
 init=function(this)
 end,
 update=function(this)
 end,
 draw=function(this)
 if cutscene>2 then
  spr(125,this.x,this.y)
 else
  spr(109,this.x+2,this.y)
 end
end
}
add(types,maddy)

maddie = {
 tile=108,
 init=function(this)
 end,
 update=function(this)
 end,
 draw=function(this)
 if cutscene>3 then
  spr(125,this.x,this.y)
 else
  spr(108,this.x-2,this.y)
 end
end
}
add(types,maddie)
 
 
 
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

roundespin = {
 tile=2,
 init=function(this)
 end,
 update=function(this)
 end,
 draw=function(this)
 spr(flr(globtimer/2)%4+1,this.x,this.y)
 end
}
add(types,roundespin)

ground = {
 tile=34,
 init=function(this)
 this.start=this.x
 end,
 update=function(this)
 end,
 draw=function(this)
 if level_index()==31 then
  spr(34,-(globtimer+this.start)%128,this.y)
 else
  spr(34,this.x,this.y)
 end
 end
}
add(types,ground)

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
			--got_fruit[1+level_index()] = true
			--told you taco!
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
		this.duration=90
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
  ability=1
		print("double jump unlocked",this.x-60,this.y,7+this.flash%2)
	end
}

fake_wall = {
	tile=64,
	if_not_fruit=true,
	update=function(this)
		this.hitbox={x=-1,y=-1,w=18,h=18}
		local hit = this.collide(player,0,0)
		if hit~=nil and btn(k_down) and btn(k_dash) then
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
	 if incutscene==0 then
		 this.spr=118+(frames/5)%3
		end
		if incutscene==1 then
		 this.spr=119
		end
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
				print("old tunnels",48,62,7)
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

function prev_room()

 load_room(room.x-1,room.y)
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
 globtimer+=1
	frames=((frames+1)%30)
	if frames==0 and level_index()<11 then
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
		 if cutscene==0 then
		 	music(-1)
		 	start_game_flash=50
			 start_game=true
			 sfx(38)
			end
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
	if is_title() and cutscene==0 then
		print("roundelie adventure 2:",27,30,9)
		print("electric boogaloo",36,46,9)
	--print("noel berry",46,102,5) (enable for funny xd)
	end
	if cutscene>0 and level_index()==31 then
	 print("roundelie adventure 3:",27,30,9)
	 print("coming soon...",38,46,9)
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
-->8
--[[notes
i can't remember stuff ok :sroundelie:


states:
0-can't move or change states at all; cutscene state
1-standard state, just chilling on the ground and can do anything, except ‹+— if the action timer for that is still >0.
2-airborne. 
i thought i would need like 10 more but i think handling things via action timer and banning ”+— in midar probably means this is it. i'll update if i need to.	
i don't think i actually need states actually
--]]
__gfx__
000000000011110000111100006666000011110000111100000000000011110000aaaaa0000aaa000000a0000007707770077700000060000000600000060000
000000000111111006111110067777600111116001711710000000000171171000a000a0000a0a000000a0000777777677777770000060000000600000060000
000000001117117167711711117777111171177611111111001111001119911100a909a0000a0a000000a0007766666667767777000600000000600000060000
0000000011119911677191111111111111191776111991110111111011111111009aaa900009a9000000a0007677766676666677000600000000600000060000
00000000111111116771911111199111111917761111111111711711117777110000a0000000a0000000a0000000000000000000000600000006000000006000
00000000117777116771171111711711117117760677777011199111167777610099a0000009a0000000a0000000000000000000000600000006000000006000
00000000067777600611111001111110011111600077770011111111067777600009a0000000a0000000a0000000000000000000000060000006000000006000
000000000066660000111100001111000011110000000000017777100066660000aaa0000009a0000000a0000000000000000000000060000006000000006000
00111100000000000000000000000000000000000000000000888800499999944999999449990994000333006665666500000000000000000000000070000000
01111110000000000000000000000000000000000000000008888880911111199111411991140919003300306765676500060000007700000770070007000007
111991110000000000000000000000000aaaaaa00000000008788880911111199111911949400419003000036770677000066000007770700777000000000000
11711711007000700499994000000000a998888a1111111108888880911111199494041900000044000000300700070060ddd5d0077777700770000000000000
11111111007000700050050000000000a988888a100000010888888091111119911409499400000000000300070007006ddd5d5d077777700000700000000000
11666611067706770005500000000000aaaaaaaa111111110888888091111119911191199140049900000300000000006ddd5ddd077777700000077000000000
07666670567656760050050000000000a980088a1444444100888800911111199114111991404119000000000000000060ddddd0070777000007077007000070
00777700566656660005500004999940a988888a1444444100000000499999944999999444004994000003000000000000060600000000007000000000000000
5b3b3b3553b3b3b3b3b3bb3b3b3b3b35b3444444444444444444443b53b3b3b55555555555555555555555555500000007777770000000000000000000000000
b3b3b3b33b3b3b3b3b3b33b3b3b3b3b33b44444444444444444444b33b3b3b3b5555555555555550055555556670000077777777000777770000000000000000
3b343b3bb3b44444c344443c34444b3bb3b444444444444444444b3bb34444b35555555555555500005555556777700077777777007766700000000000000000
b34444b33b44444444444444444444b33b34444444444444444443b33b44443b5555555555555000000555556660000077773377076777000000000000000000
3b44443bb3444444444444444444443bb3b444444444444444444b3bb34444b35555555555550000000055555500000077773377077660000777770000000000
b3b443b33b44744444444444444744b33b34444444444444444443b33b44443b5555555555500000000005556670000073773337077770000777767007700000
3b3b3b3bb3444444444444444444443bb3444444444444444444443bb34444b3555555555500000000000055677770007333bb37000000000000007700777770
53b3b3b53b44444444444444444444b33b44444444444444444444b33b44443b555555555000000000000005666000000333bb30000000000000000000077777
3b44443bbb44444444444444444444bb53b3b3b3bbbbbbbb3b3b3b353b44443b5555555550000000000000050000000003333330000000000000000000000000
b3b444b3b3444444444444444444443b3b3b3b3bbbbbbbbbb3b3b3b3b37444b35055555555000000000000550000070703b333300000000000ee0ee000000000
3b34443bb344444444444444444444b3b3444444bbbbbbbb4444443b3b44473b55550055555000000000055500070000033333300000000000eeeee000000030
b34443b33b447444444444444447443b3b444444b4bbbb44444444b3b34444b3555500555555000000005555000007070333b33000000000000e8e00000000b0
3b444b3bb34444444444444444444433b344442444bbbb4b4244443b3b44443b55555555555550000005555500000000003333000000b00000eeeee000000b30
b3b443b33bb444443b44443b444443b33b444444bbbbbbbb444444b3b34444b35505555555555500005555550000070700044000000b000000ee3ee003000b00
3b344b3bb33b3b3bb3b3b3b3b3b33b3bb3b3b3b3bbbbbbbb3b3b3b3b3b3b3b3b5555555555555550055555550007000000044000030b00300000b00000b0b300
b34444b35b33b3b33b3b3b3b3b3b33b55b3b3b3bbbbbbbbbb3b3b3b553b3b3b55555555555555555555555550000070700999900030330300000b00000303300
53b3b553b353b3b50777777777777777777777700777777000000000000000004444444400000000000000000000000000000000000000000000000000000000
3b3b3b3b3b3b3b3b7000077700007770000077777000777700000000000000004bb4444400000000000000000000000000000000000000000000000000000000
b3b3b3b3b7b3b3b370cc777cccc777ccccc7770770c7770700000000000000004bb44b4400000000000000000000000000000000000000000000000000000000
3b3b3b3b3b3b3b3b70c777cccc777ccccc777c0770777c0700000000000000004444444400000000000000000000000000006000000000000000000000000000
b3b3b3b3b3b3b3b3707770000777000007770007777700070002eeeeeeee20004444444400000000000000000000000000060600000000000000000000000000
5b3b3b3b3b3b3b3577770000777000007770000777700007002eeeeeeeeee20044b4444400000000000000000000000000d00060000000000000000000000000
53b3b3b3b3b3b3b57000000000000000000c000770000c0700eeeeeeeeeeee0044444b440000000000000000000000000d00000c000000000000000000000000
3b3b3b3b3b3b3b3b7000000000000000000000077000000700e22222e2e22e0044444444000000000000000000000000d000000c000000000000000000000000
b3b3b3b3b3b3b3b37000000000000000000000077000000700eeeeeeeeeeee000000000000000000000000000000000c0000000c000600000000000000000000
5b3b3b3b3b3b3b3b7000000c000000000000000770cc000700e22e2222e22e00000000000000000000000000000000d000000000c060d0000000000000000000
53b3b3b3b3b3b3b570000000000cc0000000000770cc000700eeeeeeeeeeee0000000000000000000000000000000c00000000000d000d000000000000000000
3b3b3b3b3b3b3b3b70c00000000cc00000000c0770000c0700eee222e22eee0000000000000000000000000000000c0000000000000000000000000000000000
b3b3b3b3b3b3b3b37000000000000000000000077000000700eeeeeeeeeeee005555555506666600666666006600c00066666600066666006666660066666600
3b3b3b3b3b3b3b3b70000000000000000000000770c0000700eeeeeeeeeeee00555555556666666066666660660c000066666660666666606666666066666660
b3b3b3b3b3b3b3b370000000c0000000000000077000000700ee77eee7777e005555555566000660660000006600000066000000660000000066000066000000
5b3b353b3b553b357000000000000000000000077000c007077777777777777055555555dd000000dddd0000dd000000dddd0000ddddddd000dd0000dddd0000
000000000000000070000000000000000000000770000007007777005000000000000005dd000dd0dd000000dd0000d0000000000000000000dd0000dd000000
00aaaaaaaaaaaa00700000000000000000000007700c0007070000705500000000000055ddddddd0dddddd00ddddddd0088888800888888000dd0000dddddd00
0a999999999999a0700000000000c00000000007700000077077000755500000000005550ddddd00ddddddd0ddddddd0888888888888888800dd0000ddddddd0
a99aaaaaaaaaa99a7000000cc0000000000000077000cc077077bb075555000000005555000000000000000000000000888ffff88ffff8880000000000000000
a9aaaaaaaaaaaa9a7000000cc0000000000c00077000cc07700bbb0755555555555555550000000000000c000000000088f0ff0880ff0f880000c00000000000
a99999999999999a70c00000000000000000000770c00007700bbb075555555555555555000000000000c0000000000008fffff00fffff8000000c0000000000
a99999999999999a700000000000000000000007700000070700007055555555555555550000000000cc0000000000000033330000333300000000c000000000
a99999999999999a07777777777777777777777007777770007777005555555555555555000000000c000000000000000070070000700700000000c000000000
aaaaaaaaaaaaaaaa0777777777777777777777700777777000888800008888000088880000000000c0000000000000000000000000000000000000c000000000
a49494a11a49494a7000777000007770000077777000777708ffff8008ffff8008ffff800000000100000000000000000000000008888880000000c00c000000
a494a4a11a4a494a70c777ccccc777ccccc7770770c777078ffff0f88f0ff0f88f0ff0f8000000c0000000000000000000000000888888880000001010c00000
a49444aaaa44494a70777ccccc777ccccc777c0770777c078f0ffff88ffffff88ffffff8000001000000000000000000000000008ffff88800000001000c0000
a49999aaaa99994a777700000777000007770007777700078ffffff88ffffff88ffffff80000010000000000000000000000000080ff0f880000000000010000
a49444999944494a77700000777000007770000777700c0703ffff3003ffff3003ffff30000001000000000000000000000000000f00ff800000000000001000
a494a444444a494a7000000000000000000000077000000703333330033333300333333000000000000000000000000000000000000033000000000000000000
a49499999999494a0777777777777777777777700777777077000077770000777700007700010000000000000000000000000000007007000000000000000010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222
__gff__
0000000000000000000000000000000004020000000000000000000200000000030303030303030304040402020000000303030303030303040404020202020200001313131302020302020202020002000013131313020204020202020202020000131313130004040202020101020200001313131300000002020202010202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002425254825262448252532252526003b0001000000244825260000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000243232323233313232332024482600002122222300242548330000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000202122230000202123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000027000000241b1b1b1b1b1b1b1b000031323300002448253300313233270000000000000000
000000000000000000000000000000000000000000000000000000000000000000002122254825222222252523200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212600000031000000000000000000001b1b3b00002432260000202122260000000000000000
0000002123000000000000000000000000000000000000000000000000000000000031252525252532322525252300000000212300000000000000000000000000000000000000000000000000000000000000000000000000203133000000210000000000001100000000003b00002423370000212525260000000000000000
0000003133000000000000000011111100000000000000000000000000212320000000244825323300002425482522220000313300000000000000000000000000000000000000000000000000000000490000000000000021222223000000242223342300002700000000003b21232448222300244825330000000000000000
0000000000000000000000000027202100000000000000000000000000312522000000242526000000003125252525480000000000000000000000000000000001000000000000000000000000000000010000000021222225482526000000313233203300003011000021222331332425482600313233200000000000000000
2300000000000000000021222225222500000000000000000000000000202425000000244833000000000024252525250000000000000000000000000000202122222223212222222222232122222222222222222324252525252526000000001b1b1b1b000024230034252526212225323226001b1b1b1b3b00212223404121
2600000000000000003432254825252500000000000000000000000000212532000000313300000000000031254825320000000000000000000000000000212525254826244825252525263148252525252525482624482525253233000000000000000000003133000024253324254800003700000000003b00244826505124
2600000000000000001b1b3125254825000000000000000000000000003133000000003b0000000000000020313233000000000000000000000000000000244848252533242525254825252324254825252548253324252525262021230000000100202122222223000031332125252500000000000000003b00242525222232
25222300000000000000001b2425323201000000000000006c6d0000003b00000100003b000000000000003b000000000000000000000021230000000000242525323321252525252525252624252525482532332125252548262125252222222222222525482533000021222525482522222223202123000000242525482621
48253300000000000000000031332122222222222321222222222321232122222223003b000000000000003b000000000000000000000031260000000000244826212225252548252525252631482525323321222548252525332425252548252525482525253300000031482525252548252525233133000000244825253324
32330000000000000000000021222525482525482624482525482631332448254833003b000000000000003b000000000100000000000020300000000000312533242525253232322525482523242525222225252525252526212548252525252525252548260000000000242548253232253232330000000000312548332148
00000000002021230000000024252548252525253324252525254822232425252620003b0000000000000000272021222222230000000021260000000000002422252548262122233125252526242548254825252525254826242525252525252548253232330000000000242525332120370000000000000000003133212525
0000010000214826000000202425252525483233212525482525252526312548330000002123000000000000242225482548330000000024260000000000002425252525262425252324252526242525252525252525482526244825254825252525332122230000000000314826212500000000000000000000002122254825
2222232122252525222223212548252525262122252525252525254825232425000000002426000000000000244825254826000000000024260000000000002425482525262425252624254826244825252525482525252526242525252525252526212548260000000000002426242500000000000000000000002448252525
0100000000000000000000000000000000244825252525252624482525252525111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000242532254832323331323225252548222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000031332024261b1b1b1b1b1b24252525000000000000003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000242600000000000024482525000000000000003b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001000000243300000011110024252525000000000000001121232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000212222230000370000000020200024324825000000000000003432482300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002448252600003b000021222223003720313200000000000000001b242600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000003132482600003b0000244825330000000000000000000000000000243300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002125261111110000313233000000000000000000000000000000372700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002425482222230000000000000000000000000000000000000021222600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2320212321230000000000000000003132322548260000000000000000000000000000000000000024482600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4822252631330000000000000000002022233132330000000000000000000000000000000000000031252600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2525254822230000000000000000002125252223000000000000000000000000000000000000000020313300000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
254825323233000000000000000000242548253300000000000000000000000000000000000000001b1b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2532332136000000000000000000002425252600000000000000001111111111010000000000000000000000000000000000000000000000760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3321222600000000000000000000002425252600000000000000002021222222222222232122230000000000000000000021222223212222222222232122222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0003000036050310502d05026050210501d0501a050140400a03005020040100e4001a3000c40016300084001230005400196001960019600196003f6003f6003f6003f6003f6003f6003f6003f6003f6003f600
000200001a0701707015070190701c550205500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d07010070160702207000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000642008420094200b420224402a4503c6503b6503b6503965036650326502d6502865024640216401d6401a64016630116300e6300b62007620056100361010600106000060000600006000060000600
00040000215000f25013250162501a2502024025230282202b21031500315003150031500315003150022200315003e5003e50000000000000000000000000000000000000000000000000000000000000000000
000300000977009770097600975008740077300672005715357003470034700347003470034700347003570035700357003570035700347003470034700337003370033700337000070000700007000070000700
00030000241700e1702d1701617034170201603b160281503f1402f120281101d1101011003110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000101101211014110161101a120201202613032140321403410000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000070700a0700e0701007016070220702f0702f0602c0602c0502f0502f0402c0402c0302f0202f0102c000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000005110071303f6403f6403f6303f6203f6103f6153f6003f6003f600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0116012001700196231960019623236001962301600196230c033196230c033196230c033196230c0331962301700196231960019623236001962301600196230c0331962319623196230c033196230c03319623
011600000c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c033196230c03319623
01160000070000700007000110000700007000030000f0000a0000a0000a0000a0000a0000a0000500005000030000300003000030000c0000c0001100016000160000f000050000a00005000211102411026110
000400000c5501c5601057023570195702c5702157037570285703b5702c5703e560315503e540315303e530315203f520315203f520315103f510315103f510315103f510315103f50000500005000050000500
000400002f7402b760267701d7701577015770197701c750177300170015700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000096450e655066550a6550d6550565511655076550c655046550965511645086350d615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000001f37518375273752730027300243001d300263002a3001c30019300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
01160000157600973009740097400c7500c7501076010760157620973209742097420c7520c7521076210762157600973009740097400c7500c7501076010760157600973009740097400c7500c7501076010760
01160020097600b7600f000097600b7600a000097600b7600700005760097601100007760097600000007760047600a00002760047600a0000276004760130000276004760067600776009760077600676007760
0116000023120231202312023120231202112023120241201f1202112021120211201f1202112021120211201a1201c1201f1201c1201a1201c1201f1201a1201c1201a1201c1201a1201c120211202412026120
011600200c033196233f6000c033196233b6000c03319623236000c03319623000000c03319623017000c03319623017000c033196233f6000c03319623000000c03319623000000c03319623196230c03319623
011600201c750107201073010730137401374017750177501c750107201073010730137401374017750177501c752107221073210732137421374217752177521c75010720107301073013740137401775017750
011600202812026120281202812028120281202812026120281202612028120281202812028120281202812026120281202612023120231202312023120231212412126121241212312123120231202312023120
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
011600001075004720047300473007740077400b7500b7501075004720047300473007740077400b7500b7501076204732047420474207752077520b7620b7621076004730047400474007750077500b7600b760
00100020326103261032610326103161031610306102e6102a610256101b610136100f6100d6100c6100c6100c6100c6100c6100f610146101d610246102a6102e61030610316103361033610346103461034610
00400000302453020530235332252b23530205302253020530205302253020530205302153020530205302152b2452b2052b23527225292352b2052b2252b2052b2052b2252b2052b2052b2152b2052b2052b215
0116000023120231202312023120231202112023120241201f1202112021120211201f120211202112021120231201f1201c1201f1201f1201c1201f1201f1201c1201e1201f1202312024120231201f1201e120
__music__
00 15 0a 0c 44
01 0b 3c 43 16
00 0b 16 43 11
00 14 3f 12 44
02 14 13 12 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
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
