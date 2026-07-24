pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--super mario machine gun
--@dollarone
--made for ld41

--based on
--advanced micro platformer
--by @matthughson
--https://www.lexaloffle.com/bbs/?tid=28793

--music "demented mario"
--by @gruber_music
--https://gruber99.bandcamp.com/album/pico-8-tunes-vol-1


--point to box intersection.
function intersects_point_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<flr(x+w) and
				flr(py)>=flr(y) and flr(py)<flr(y+h) then
		return true
	else
		return false
	end
end

--box to box intersection
function intersects_box_box(
	x1,y1,
	w1,h1,
	x2,y2,
	w2,h2)

	local xd=x1-x2
	local xs=w1*0.5+w2*0.5
	if abs(xd)>=xs then return false end

	local yd=y1-y2
	local ys=h1*0.5+h2*0.5
	if abs(yd)>=ys then return false end
	
	return true
end

--check if pushing into side tile and resolve.
--requires self.dx,self.x,self.y, and 
--assumes tile flag 0 == solid
--assumes sprite size of 8x8
function collide_side(self)

	local offset=self.w/3
	for i=-(self.w/3),(self.w/3),2 do
		if self.dx>0 then
			if fget(mget((self.x+0+(offset))/8,(self.y+i)/8),0) then
				if (self.canbump) then
					self.dx=0
				else
					self.dx=0---self.dx
					self.going_right=false
				end
				self.x=(flr(((self.x+0+(offset))/8))*8)-(offset) 
				return true
			end
		elseif self.dx<0 then
			if fget(mget((self.x+0-(offset))/8,(self.y+i)/8),0) then
				if (self.canbump) then
					self.dx=0
				else
					self.dx=0--self.dx
					self.going_right=true
				end
				self.x=(flr((self.x+0-(offset))/8)*8)+8+(offset)
				return true
			end
		end
	end
	--didn't hit a solid tile.
	return false
end

--check if pushing into floor tile and resolve.
--requires self.dx,self.x,self.y,self.grounded,self.airtime and 
--assumes tile flag 0 or 1 == solid
function collide_floor(self)
	--only check for ground when falling.
	if self.dy<0 then
		return false
	end
	local landed=false
	--check for collision at multiple points along the bottom
	--of the sprite: left, center, and right.
	for i=-(self.w/3),(self.w/3),2 do
		local tile=mget((self.x+i)/8,(self.y+(self.h/2))/8)
		if (fget(tile,0) and self.dy>=0) then
			if not(not self.canbump and fget(tile,8)) then

				self.dy=0
				self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
				self.grounded=true
				self.airtime=0
				landed=true
			end
		end
	end
	return landed
end

--check if pushing into roof tile and resolve.
--requires self.dy,self.x,self.y, and 
--assumes tile flag 0 == solid
function collide_roof(self)
	--check for collision at multiple points along the top
	--of the sprite: left, center, and right.
	if(self.dy>=0)return
	local spawn_offset=0
	local offset_hit=1
	for i=-(self.w/3)+4,(self.w/3)-1,2 do
		if fget(mget(flr((self.x+i+offset_hit)/16*2),flr(self.y-(self.h/2))/8),0) or
			fget(mget(flr((self.x+i+offset_hit)/16*2),flr(self.y-(self.h/2))/8),1)
			then
			local hit=fget(mget(flr(self.x+i+offset_hit)/16*2,flr(self.y-(self.h/2))/8))
			local tile = mget(flr(self.x+i+offset_hit)/16*2,flr(self.y-(self.h/2))/8)
			if (self.canbump) then

				if (tile==90 or tile==104 or tile==71) then 
					mset(flr(self.x+i+offset_hit)/16*2,(self.y-(self.h/2))/8,30)
					mset(flr(self.x+i+offset_hit)/16*2+1,(self.y-(self.h/2))/8,31)
					mset(flr(self.x+i+offset_hit)/16*2,(self.y-(self.h/2))/8-1,14)
					mset(flr(self.x+i+offset_hit)/16*2+1,(self.y-(self.h/2))/8-1,15)
				elseif (tile==91 or tile==105 or tile==87) then 
					mset(flr(self.x+i+offset_hit)/16*2-1,(self.y-(self.h/2))/8,30)
					mset(flr(self.x+i+offset_hit)/16*2,(self.y-(self.h/2))/8,31)
					mset(flr(self.x+i+offset_hit)/16*2-1,(self.y-(self.h/2))/8-1,14)
					mset(flr(self.x+i+offset_hit)/16*2,(self.y-(self.h/2))/8-1,15)
					spawn_offset=-1
				elseif (tile==72) then 
					if (multihit>1) then
						multihit-=1
						sfx(7)
						spawn_coin(flr((self.x+offset_hit))/8,flr(self.y-(self.h/2))/8)
						self.coins+=1
					else
						multihit-=1
						sfx(7)
						spawn_coin(flr((self.x+offset_hit))/8,flr(self.y-(self.h/2))/8)
						mset((self.x+i+offset_hit)/8,(self.y-(self.h/2))/8,30)
						mset((self.x+i+offset_hit)/8+1,(self.y-(self.h/2))/8,31)
						mset((self.x+i+offset_hit)/8,(self.y-(self.h/2))/8-1,14)
						mset((self.x+i+offset_hit)/8+1,(self.y-(self.h/2))/8-1,15)
					end
				elseif (tile==73) then 
					spawn_offset=-1
					if (multihit>1) then
						multihit-=1
						sfx(7)
						spawn_coin(flr((self.x+i+offset_hit)/8)+spawn_offset,flr(self.y-(self.h/2))/8)
						self.coins+=1
					else
						multihit-=1
						sfx(7)
						spawn_coin(flr((self.x+offset_hit)/8)+spawn_offset,flr(self.y-(self.h/2))/8)
						mset((self.x+i+offset_hit)/8-1,(self.y-(self.h/2))/8,30)
						mset((self.x+i+offset_hit)/8,(self.y-(self.h/2))/8,31)
						mset((self.x+i+offset_hit)/8-1,(self.y-(self.h/2))/8-1,14)
						mset((self.x+i+offset_hit)/8,(self.y-(self.h/2))/8-1,15)
					end
				end

				if(hit==5) then
					sfx(9)
					spawn_weapon(flr((self.x+i+offset_hit)/8)+spawn_offset,flr(self.y-(self.h/2))/8)
				elseif(hit==2 or hit==3) then
					sfx(7)
					spawn_coin(flr((self.x+i+offset_hit)/8)+spawn_offset,flr(self.y-(self.h/2))/8)
					self.coins+=1
				elseif(hit==1) then
					--nothing
				end
				sfx(5)
				self.dy=0
				self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
				self.jump_hold_time=0
			end
		end
	end
	return 
end

function spawn_weapon(x,y)
	weapon.alive=true
	weapon.x=x*8
	weapon.y=y*8
	weapon.ytarget=weapon.y-8
end
function spawn_coin(x,y)
	coin.alive=true
	coin.x=x*8+4
	coin.y=y*8
	coin.ytarget=coin.y-36
end
--make 2d vector
function m_vec(x,y)
	local v=
	{
		x=x,
		y=y,
		
  --get the length of the vector
		get_length=function(self)
			return sqrt(self.x^2+self.y^2)
		end,
		
  --get the normal of the vector
		get_norm=function(self)
			local l = self:get_length()
			return m_vec(self.x / l, self.y / l),l;
		end,
	}
	return v
end

--square root.
function sqr(a) return a*a end

--round to the nearest whole number.
function round(a) return flr(a+0.5) end

--objects
--------------------------------

--make the player
function m_player(x,y)

	--todo: refactor with m_vec.
	local p=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=16,
		h=16,
		
		max_dx=2,--max x speed
		max_dy=4,--max y speed

		jump_speed=-4,--jump veloclity
		acc=0.1,--acceleration
		dcc=0.8,--decceleration
		air_dcc=1,--air decceleration
		grav=0.3,
		machine_gun=false,
		bullets=0,
		coins=0,
		canbump=true,
		pause_out_of_ammo_sound=false,
		
		--helper for more complex
		--button press tracking.
		--todo: generalize button index.
		jump_button=
		{
			update=function(self)
				--start with assumption
				--that not a new press.
				self.is_pressed=false
				if btn(4) then
					if not self.is_down then
						self.is_pressed=true
					end
					self.is_down=true
					self.ticks_down+=1
				else
					self.is_down=false
					self.is_pressed=false
					self.ticks_down=0
				end
			end,
			--state
			is_pressed=false,--pressed this frame
			is_down=false,--currently down
			ticks_down=0,--how long down
		},

		jump_hold_time=0,--how long jump is held
		min_jump_press=5,--min time jump can be held
		max_jump_press=20,--max time jump can be held

		jump_btn_released=true,--can we jump again?
		grounded=false,--on ground
		bumped=false,
		alive=true,

		airtime=0,--time since grounded
		--animation definitions.
		--use with set_anim()
		anims=
		{
			["stand"]=
			{
				ticks=1,--how long is each frame shown.
				frames={10},--what frames are shown.
			},
			["walk"]=
			{
				ticks=7,
				frames={2,4,6,4},
			},
			["run"]=
			{
				ticks=3,
				frames={2,4,6,4},
			},
			["jump"]=
			{
				ticks=1,
				frames={0},
			},
			["death"]=
			{
				ticks=1,
				frames={12},
			},
			["slide"]=
			{
				ticks=1,
				frames={8},
			},
		},

		curanim="walk",--currently playing animation
		curframe=1,--curent frame of animation.
		animtick=0,--ticks until next frame should show.
		flipx=false,--show sprite be flipped.
		
		--request new animation to play.
		set_anim=function(self,anim)
			if(anim==self.curanim)return--early out.
			local a=self.anims[anim]
			self.animtick=a.ticks--ticks count down.
			self.curanim=anim
			self.curframe=1
		end,
		
		--call once per tick.
		update=function(self)

			if(pipeanim) then
				if self.y==29*8 then
					self.y+=108
					self.x=32
					cam.pos_min=m_vec(64,128+128+64)
					cam.pos_max=m_vec(64*16,64+128+128+128)
					poffset=-(128+64)
					pal(4,13)
					pal(15,6)				
					--pal(12,1)
					world="1-2"
					for k,v in pairs(monsters) do
						del(monsters,v)
					end
					add_monster(210,420,100,false)
					add_monster(240,420,100,false)					
					pipeanim=false

				elseif self.y<29*8 and ticks%4==0 then
					self.y+=1
				end
				return
			end
			if(endanim) then
				if endstep==1 then
					if self.y==264+27*8 then
						endstep=2
						endtimeout=ticks+60
					elseif self.y<264+27*8 and ticks%4==0 then
						self.y+=1
					end
				elseif endstep==2 then
					endtimeout-=1
					if (endtimeout==ticks) then
						endstep=3
						luigi=true
						police_level=1000 
						final_wanted_level=wanted_level
						wanted_level=0
						final_kills=kills
						kills=0
						pal(8,3)
						for i=1,#monsters do
							if (monsters[i].alive) then
								monsters[i].going_right = not monsters[i].going_right
							end
						end
						luigitimeout=120
					end
				elseif endstep==3 then
					if self.y==264+24*8 then
						endstep=4
						endtimeout=ticks+60
					elseif self.y>264+24*8 and ticks%4==0 then
						self.y-=1
					end
				elseif endstep==4 then
					endtimeout-=1

					if endtimeout==ticks then
						endstep=5
						endtimeout=ticks+300
					end
				elseif endstep==5 then
					endtimeout-=1

					if endtimeout==ticks then
						endstep=6
						endanim=false
					end
				end
				return
			end
	
			--todo: kill enemies.
			
			--track button presses
			local bl=btn(0) --left
			local br=btn(1) --right

			if (bl or br)endstep=0

			
				if self.alive then
				--move left/right
				if bl==true then
					self.dx-=self.acc
					br=false--handle double press
				elseif br==true then
					self.dx+=self.acc
				else
					if self.grounded then
						self.dx*=self.dcc
					else
						self.dx*=self.air_dcc
					end
				end
				
				local cur_max=self.max_dx*0.5
				if btn(5) then
					cur_max=self.max_dx
					local dir=1
					if (self.flipx)dir=-1
					if(self.machine_gun) then
						if(self.bullets>0) then
							shoot(self.x,self.y+2,self.dx,dir)
							self.bullets-=1
						else
							if not self.pause_out_of_ammo_sound then
								self.pause_out_of_ammo_sound=true
								sfx(6)
							end
						end
					end
				else
					self.pause_out_of_ammo_sound=false
				end

				--limit walk speed
				self.dx=mid(-cur_max,self.dx,cur_max)
				
				if self.x<8 and self.dx<0 then
					self.dx=0
				end

				--move in x
				self.x+=self.dx
				
				--hit walls
				collide_side(self)

				--jump buttons
				self.jump_button:update()
				
				--jump is complex.
				--we allow jump if:
				--	on ground
				--	recently on ground
				--	pressed btn right before landing
				--also, jump velocity is
				--not instant. it applies over
				--multiple frames.
				if self.jump_button.is_down or self.bumped then

					--is player on ground recently.
					--allow for jump right after 
					--walking off ledge.
					local on_ground=(self.grounded or self.airtime<5)
					--was btn presses recently?
					--allow for pressing right before
					--hitting ground.
					local new_jump_btn=self.jump_button.ticks_down<10
					--is player continuing a jump
					--or starting a new one?
					if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
						if(self.jump_hold_time==0) then
							sfx(8)--new jump snd
							self.bumped=false
						end

						self.jump_hold_time+=1
						--keep applying jump velocity
						--until max jump time.
						if self.jump_hold_time<self.max_jump_press then
							self.dy=self.jump_speed--keep going up while held
						end
					end
				else
					self.jump_hold_time=0
				end
			end
			--move in y
			self.dy+=self.grav
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			self.y+=self.dy

			if not self.alive then
				return 
			end

			--floor
			if not collide_floor(self) then
				self:set_anim("jump")
				self.grounded=false
				self.airtime+=1
			end

			--roof
			collide_roof(self)
			--handle playing correct animation when
			--on the ground.
			if self.grounded then
				if br then
					if self.dx<0 then
						--pressing right but still moving left.
						self:set_anim("slide")
					else
						if abs(self.dx) > (self.max_dx*0.5) then
							self:set_anim("run")
						else
							self:set_anim("walk")
						end
					end
				elseif bl then
					if self.dx>0 then
						--pressing left but still moving right.
						self:set_anim("slide")
					else
						if abs(self.dx) > (self.max_dx*0.5) then
							self:set_anim("run")
						else
							self:set_anim("walk")
						end
					end
				else
					self:set_anim("stand")
				end
			end

			--flip
			if br then
				self.flipx=false
			elseif bl then
				self.flipx=true
			end

			--anim tick
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				local a=self.anims[self.curanim]
				self.animtick=a.ticks--reset timer
				if self.curframe>#a.frames then
					self.curframe=1--loop
				end
			end

			if weapon.alive and intersects_point_box(weapon.x+12,weapon.y-8,self.x,self.y,12,16) then
				self.machine_gun=true
				self.bullets+=100
				weapon.alive=false
				anim_offset=32
				machine_guns+=1
				update_bullets=true
				sfx(10)
			end

			if self.y>27*8-1 and self.x>115*8 and self.x<117*8 and btnp(3) then
				pipeanim=true
				sfx(14)
			end
			if self.y>57*8-1 and self.x>123*8 and self.x<125*8 and btnp(3) then
				endanim=true
				endstep=1
				sfx(14)
				timefrozen=true
				finaltime=ticks
			end

			for i=1,#monsters do
				if monsters[i].alive then
					if self.alive and intersects_point_box(self.x,self.y,monsters[i].x-8,monsters[i].y-8,16,16) then
						self:set_anim("death")
						self.alive=false
						self.death_timeout=60
						self.dx=0
						self.dy=-5
						sfx(11)
--						add_blood(self.x,self.y)
					end
				end
			end		

		end,

		--draw the player
		draw=function(self)
			local gun_offset=0
			if (self.machine_gun)gun_offset=32
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			spr(frame+gun_offset,
				self.x-(self.w/2),
				self.y-(self.h/2),
				(self.w/8),self.h/8,
				self.flipx,
				false)
			if luigi then
				local off=0
				local offx=0
				if (self.flipx) then
					offx-=1
				end
				if frame==6 or frame==0 then
					off=1
					if (self.flipx) then
						offx-=1
					else

						offx=1
					end
				end

				pset(self.x+offx,self.y-6+off,0)
				pset(self.x-1+offx,self.y-6+off,0)
				pset(self.x-2+offx,self.y-6+off,0)
				pset(self.x-3+offx,self.y-6+off,0)
				pset(self.x-4+offx,self.y-6+off,0)
				pset(self.x+1+offx,self.y-6+off,0)
				pset(self.x+2+offx,self.y-6+off,0)
				pset(self.x+3+offx,self.y-6+off,0)
				pset(self.x+4+offx,self.y-6+off,0)
				if (not self.flipx) then
					pset(self.x+1+offx,self.y-5+off,0)
					pset(self.x+2+offx,self.y-5+off,0)
					pset(self.x+3+offx,self.y-5+off,0)
					pset(self.x+4+offx,self.y-5+off,0)
				else
					pset(self.x-1+offx,self.y-5+off,0)
					pset(self.x-2+offx,self.y-5+off,0)
					pset(self.x-3+offx,self.y-5+off,0)
					pset(self.x-4+offx,self.y-5+off,0)
				end

			end

		end,
	}

	return p
end

--------

--make the player
function m_enemy(x,y,type,going_right)

	--todo: refactor with m_vec.
	local p=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=16,
		h=16,
		type=type,
		max_dx=1.2,--max x speed
		max_dy=4,--max y speed

		jump_speed=-0,--jump veloclity
		acc=0.1,--acceleration
		dcc=0.8,--decceleration
		air_dcc=1,--air decceleration
		grav=0.3,
		canbump=false,
		going_right=going_right,

		alive=true,
		
		--helper for more complex
		--button press tracking.
		--todo: generalize button index.
		jump_button=
		{
			update=function(self)
				--start with assumption
				--that not a new press.
				self.is_pressed=false
				if flr(rnd(20))==0 then
					if not self.is_down then
						self.is_pressed=true
					end
					self.is_down=true
					self.ticks_down+=1
				else
					self.is_down=false
					self.is_pressed=false
					self.ticks_down=0
				end
			end,
			--state
			is_pressed=false,--pressed this frame
			is_down=false,--currently down
			ticks_down=0,--how long down
		},

		jump_hold_time=0,--how long jump is held
		min_jump_press=5,--min time jump can be held
		max_jump_press=20,--max time jump can be held

		jump_btn_released=true,--can we jump again?
		grounded=false,--on ground

		airtime=0,--time since grounded
		
		--animation definitions.
		--use with set_anim()
		anims=
		{
			["stand"]=
			{
				ticks=1,--how long is each frame shown.
				frames={type},--what frames are shown.
			},
			["walk"]=
			{
				ticks=5,
				frames={flr(type), flr(type+2)},
			},
			["run"]=
			{
				ticks=2,
				frames={flr(type), flr(type+2)},
			},
			["jump"]=
			{
				ticks=1,
				frames={type,type+2},
			},
			["slide"]=
			{
				ticks=1,
				frames={type},
			},
			["death"]=
			{
				ticks=3,
				frames={type+4,type+4,type+4,type+4,type+4,type+4,0},
			},
		},

		curanim="walk",--currently playing animation
		curframe=1,--curent frame of animation.
		animtick=0,--ticks until next frame should show.
		flipx=false,--show sprite be flipped.
		
		--request new animation to play.
		set_anim=function(self,anim)
			if(anim==self.curanim or self.curanim=="death")return--early out.
			local a=self.anims[anim]
			self.animtick=a.ticks--ticks count down.
			self.curanim=anim
			self.curframe=1
		end,
		
		--call once per tick.
		update=function(self)
			local delete=false
	
			--todo: kill enemies.
			if (self.alive and p1.alive)check_if_bumped_by_player(self)
			
			--track button presses
			local bl=not self.going_right--left
			local br=self.going_right--right
			
			--move left/right
			if bl==true then
				self.dx-=self.acc
				br=false--handle double press
			elseif br==true then
				self.dx+=self.acc
			else
				if self.grounded then
					self.dx*=self.dcc
				else
					self.dx*=self.air_dcc
				end
			end
			
			local cur_max=self.max_dx*0.5
			--limit walk speed
			self.dx=mid(-cur_max,self.dx,cur_max)

			--move in x
			self.x+=self.dx
			
			--hit walls
			collide_side(self)

			--jump buttons
			self.jump_button:update()
			
			--jump is complex.
			--we allow jump if:
			--	on ground
			--	recently on ground
			--	pressed btn right before landing
			--also, jump velocity is
			--not instant. it applies over
			--multiple frames.
			if self.jump_button.is_down then
				--is player on ground recently.
				--allow for jump right after 
				--walking off ledge.
				local on_ground=(self.grounded or self.airtime<5)
				--was btn presses recently?
				--allow for pressing right before
				--hitting ground.
				local new_jump_btn=self.jump_button.ticks_down<10
				--is player continuing a jump
				--or starting a new one?
				if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
					--if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
					self.jump_hold_time+=1
					--keep applying jump velocity
					--until max jump time.
					if self.jump_hold_time<self.max_jump_press then
						self.dy=self.jump_speed--keep going up while held
					end
				end
			else
				self.jump_hold_time=0
			end
			
			--move in y
			self.dy+=self.grav
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			self.y+=self.dy

			--floor
			if not collide_floor(self) then
				self:set_anim("jump")
				self.grounded=false
				self.airtime+=1
			end

			--roof
			collide_roof(self)

			--handle playing correct animation when
			--on the ground.
			if self.grounded then
				if br then
					if self.dx<0 then
						--pressing right but still moving left.
						self:set_anim("walk")
					else
						if abs(self.dx) > (self.max_dx*0.5) then
							self:set_anim("walk")
						else
							self:set_anim("walk")
						end
					end
				elseif bl then
					if self.dx>0 then
						--pressing left but still moving right.
						self:set_anim("walk")
					else
						if abs(self.dx) > (self.max_dx*0.5) then
							self:set_anim("walk")
						else
							self:set_anim("walk")
						end
					end
				else
					self:set_anim("stand")
				end
			end
			--flip
			if br then
				self.flipx=false
			elseif bl then
				self.flipx=true
			end

			--anim tick
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				local a=self.anims[self.curanim]
				self.animtick=a.ticks--reset timer
				if self.curframe>#a.frames then
					self.curframe=1--loop
				end
							
				framedebug=a.frames[self.curframe]

				if framedebug==0 then
					return true
				end
				if framedebug==self.type+4 and ticks%2==0 then
					add_blood(self.x,self.y)
				end
			end
			return delete
		end,

		--draw the player
		draw=function(self)
			local offset_death=0
			local height=self.h/8
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			if (frame==104) then
				height=1
				frame=120
				offset_death=8
			end
			spr(frame,
				self.x-(self.w/2),
				self.y-(self.h/2)+offset_death,
				(self.w/8),height,
				self.flipx,
				false)
			if (luigitimeout>0) then
				print("?",self.x-1,self.y-16,7)
			end
		end,
	}

	return p
end

function add_blood(x,y)
	for b=-4,4 do
		add_particle(x-rnd(1),y,b/2-rnd(5)+2.5,-3,2)
		add_particle(x-rnd(1.2),y,b/2-rnd(2)+1,-2.5,2)
		add_particle(x-rnd(1.4),y,b/3-rnd(0.5)+0.25,-2,2)	
	end
end
function shoot(x,y,dx,direction)
	add_particle(x+bullet_offset,y,dx+5*direction,0,0)
	sfx(5)
	cam:shake(2,2)
	bullet_offset+=1
	if (bullet_offset>4)bullet_offset=0
	update_bullets=true
end

function add_particle(x,y,dx,dy,col)
	for i=1,#particles do
		if (not particles[i].alive) then
			particles[i].x=x
			particles[i].y=y
			particles[i].dx=dx
			particles[i].dy=dy
			particles[i].col=col
			particles[i].alive=true
			return true
		end
	end
	add(particles,m_particle(x,y,dx,dy,col))
end

function add_monster(x,y,type,going_right)
	for i=1,#monsters do
		if (not monsters[i].alive) then
			monsters[i].x=x
			monsters[i].y=y
			monsters[i].type=type
			monsters[i].going_right=going_right
			monsters[i].alive=true
			return monsters[i]
		end
	end
	add(monsters,m_enemy(x,y,type,going_right))
	return monsters[#monsters]
end

--make the player
function m_particle(x,y,dx,dy,col)

	--todo: refactor with m_vec.
	local p=
	{
		x=x,
		y=y,

		dx=dx,
		dy=dy,
		col=col,

		w=1,
		h=1,
		
		max_dx=1,--max x speed
		max_dy=4,--max y speed

		jump_speed=-0,--jump veloclity
		acc=0.2,--acceleration
		dcc=0.8,--decceleration
		air_dcc=1,--air decceleration
		grav=0.3,

		alive=true,
		
		--helper for more complex
		--button press tracking.
		--todo: generalize button index.

		jump_hold_time=0,--how long jump is held
		min_jump_press=5,--min time jump can be held
		max_jump_press=20,--max time jump can be held

		going_right=false,
		canbump=false,
		jump_btn_released=true,--can we jump again?
		grounded=false,--on ground

		airtime=0,--time since grounded
		
		--call once per tick.
		update=function(self)

			if self.col==0 then
				self.grav=0
			end
			if self.dx==0 then
				self.grav=0.3
			end

			--track button presses
			local bl=self.alive --left
			local br=false--right
			
			--move in x
			self.x+=self.dx
			if self.grounded then
				self.dx*=self.dcc
			end
			
			--hit walls
			collide_side(self)

			--move in y
			self.dy+=self.grav
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			self.y+=self.dy

			--floor
			if not collide_floor(self) then
				self.grounded=false
				self.airtime+=1
			end

			--handle playing correct animation when
			--on the ground.
			if self.grounded then
				self.dy=0
			end

			if (abs(self.dx) < 0.1 and self.grounded) or abs(self.x-p1.x) > 160 then
				self.alive=false
			end

			if self.col==0 then
				for i=1,#monsters do
					if monsters[i].alive then
						if intersects_point_box(self.x,self.y,monsters[i].x-8,monsters[i].y-8,16,16) then
							monsters[i]:set_anim("death")
							monsters[i].alive=false
							monsters[i].dx=0
							add_blood(self.x,self.y)
							kills+=1
							updatewarning()
							sfx(13)
						end
					end
				end
			end
		end,

		--draw the particle
		draw=function(self)
			pset(self.x,self.y,self.col)
		end,
	}

	return p
end


--make the camera.
function m_cam(target)
	local c=
	{
		tar=target,--target to follow.
		pos=m_vec(target.x,target.y),
		
		--how far from center of screen target must
		--be before camera starts following.
		--allows for movement in center without camera
		--constantly moving.
		pull_threshold=16,

		--min and max positions of camera.
		--the edges of the level.
		pos_min=m_vec(64,64),
		pos_max=m_vec(64*16,64+128),
		
		shake_remaining=0,
		shake_force=0,

		update=function(self)

			self.shake_remaining=max(0,self.shake_remaining-1)
			
			--follow target outside of
			--pull range.
			if self:pull_max_x()<self.tar.x then
				--self.pos.x+=1
				self.pos.x+=min(self.tar.x-self:pull_max_x(),4)
			end
			if self:pull_min_x()>self.tar.x then
				self.pos.x+=min((self.tar.x-self:pull_min_x()),4)
			end
			if self:pull_max_y()<self.tar.y then
				self.pos.y+=min(self.tar.y-self:pull_max_y(),4)
			end
			if self:pull_min_y()>self.tar.y then
				self.pos.y+=min((self.tar.y-self:pull_min_y()),4)
			end

			--lock to edge
			if(self.pos.x<self.pos_min.x)self.pos.x=self.pos_min.x
			if(self.pos.x>self.pos_max.x)self.pos.x=self.pos_max.x
			if(self.pos.y<self.pos_min.y)self.pos.y=self.pos_min.y
			if(self.pos.y>self.pos_max.y)self.pos.y=self.pos_max.y
		end,

		cam_pos=function(self)
			--calculate camera shake.
			local shk=m_vec(0,0)
			if self.shake_remaining>0 then
				shk.x=rnd(self.shake_force)-(self.shake_force/2)
				shk.y=rnd(self.shake_force)-(self.shake_force/2)
			end
			return self.pos.x-64+shk.x,self.pos.y-64+shk.y
		end,

		pull_max_x=function(self)
			return self.pos.x+self.pull_threshold
		end,

		pull_min_x=function(self)
			return self.pos.x-self.pull_threshold
		end,

		pull_max_y=function(self)
			return self.pos.y+self.pull_threshold
		end,

		pull_min_y=function(self)
			return self.pos.y-self.pull_threshold
		end,
		
		shake=function(self,ticks,force)
			self.shake_remaining=ticks
			self.shake_force=force
		end
	}

	return c
end

--game flow
--------------------------------

--reset the game to its initial
--state. use this instead of
--_init()
function reset()
	pal()

	palt(14, true) -- beige color as transparency is true
    palt(0, false) -- black color as transparency is false
	ticks=0
	
	p1=m_player(64,230)
	monsters={}
	add_monster(200,230,100,false)
	add_monster(600,230,100,false)
	add_monster(700,230,100,false)
	add_monster(730,230,100,false)
	add_monster(840,230,100,false)
	add_monster(980,230,100,false)

	add_monster(460,320,100,false)
	add_monster(560,320,100,false)
	add_monster(660,320,100,false)

	add_monster(760,420,100,false) --?
	add_monster(1160,520,100,false) --?

	add_monster(352+74*8,264+27*8,100,false)
	
	p1:set_anim("walk")
	cam=m_cam(p1)

	particles={}
	bullet_offset=0
	poffset=0

	weapon={}
	weapon.alive=false
	weapon.x=-34*8
	weapon.y=22*8
	weapon.ytarget=weapon.y

	coin={}
	coin.alive=false
	coin.x=-30
	coin.y=0
	coin.ytarget=coin.y
	coin.frame=0
	police_level=1000 
	wanted_level=0
	luigi=false
	luigitimeout=0
	score=0 --"035350"
	intro=true
	world="1-1"
	kills=0
	recent_kills=0
	last_kill=0
	p1.death_timeout=0
	multihit=11
	pipeanim=false
	endanim=false
	endstep=0
	timefrozen=false
	finaltime=0
	--reset map!
	update_bullets=false
	bul="  0"
	tim="  0"
	machine_guns=0
	di=true

	reload(0x1000, 0x1000, 0x2000)
	-- thank you http://pico-8.wikia.com/wiki/Reload !
end

--p8 functions
--------------------------------

function _init()
  	cartdata("dollarone_super_mario_machine_gun")
	reset()
	intro_init()
end

function _update60()
	if (intro) then
		intro_update()
		return
	end
	if (p1.death_timeout>0)p1.death_timeout-=1
	if (not p1.alive and p1.death_timeout==0 and (btnp(4) or btnp(5))) then
		reset()
		intro=false
	end

	if luigitimeout>0 then
		luigitimeout-=1
	end

	ticks+=1
	p1:update()
	cam:update()
	test="false"
	for k,v in pairs(monsters) do
		if(v:update()) then
			del(monsters,v)
		end
	end
	for k,v in pairs(particles) do
		if(v.alive)v:update()
	end

	if(weapon.alive) then
		if weapon.y > weapon.ytarget then
			weapon.y-=1
		end
	end
	if(coin.alive) then
		if coin.y > coin.ytarget then
			coin.y-=2
		end
		if (ticks%10==0) then
			coin.frame+=1
			if (coin.frame==4) then
				coin.alive=false
				coin.frame=0
			end
		end
	end	

	if (ticks%police_level==0) then 
		if (world=="1-1") then
			add_monster(1,230,100,true)
			local m=add_monster(411,219,100,false)
			m.dy=-4
			di=true
			if (flr(rnd(2))==0)di=false
			m=add_monster(354+51*8,219-5*8,100,di)
			m.dy=-4
		else
			add_monster(343,296,100,di)
			di=true
			if (flr(rnd(2))==0)di=false
			add_monster(350+46*8,296,100,di)
		
			add_monster(343+73*8,296-16,100,true)
			m=add_monster(343+38*8,53*8,100,di)
			m.dy=-4
		end
	end

	if ticks-last_kill>90 then
		recent_kills=0
	end

	if(ticks%60==0 and not timefrozen) then
		tim=flr(ticks/60)
		if (tim<10) then
			tim="  "..tim
		elseif (tim<100) then
			tim=" "..tim
		end
	end

	if (update_bullets) then
		bul=p1.bullets
		if (bul<10) then
			bul="  "..bul
		elseif (bul<100) then
			bul=" "..bul
		end
		update_bullets=false
	end

	
end

function _draw()
	if (intro) then
		intro_draw()
		return
	end
	if world=="1-2" then
		cls(1)
	else
		cls(12)
	end
	

	camera(cam:cam_pos())

	if(weapon.alive)spr(62,weapon.x,weapon.y-16,2,1)
	if(coin.alive)spr(64+coin.frame,coin.x,coin.y-16,1,2)
	map(0,0,0,0,128,128)
	
	p1:draw()
	for k,v in pairs(particles) do
		if(v.alive)v:draw()
	end
	for k,v in pairs(monsters) do
		v:draw()
	end
	for i=0,20 do
		spr(108,16,416-8*i,4,1)	
	end
	spr(76,16,416,4,2,false,true)

	spr(76,328,272,4,2,false,true)
	spr(76,352+44*8,272,4,2,false,true)
	spr(76,343+71*8,296-32,4,2,false,true)

	spr(76,352+70*8,28*8,4,3)
	spr(76,352+78*8,264+25*8,4,3)


	--hud

	spr(76,400-8,208,4,3)
	camera(0,0)


	print("bullets         world   time", 9, 1, 7)
	print(bul, 25, 8, 7)
	spr(107,43,6)
	print("x ", 52, 8, 7)
	print(p1.coins, 57, 8, 7)
	print(world, 77, 8, 7)
	print(tim, 109, 8, 7)
--	print("player: " .. p1.x/8 .. "/" .. p1.y/8,0,14)
--	print("weapon" .. weapon.x/8 .. "/" .. weapon.y/8, 0,22)
--	print("y pos: " .. p1.y, 0,102)
--	print(stat(7),0,110)
--	if (#particles>1)	print(particles[1].y,0,118)

	if (wanted_level>0) then
		for i=1,5 do
			spr(47,89-i*9,20)
		end
		for i=1,wanted_level do
			spr(46,89-i*9,20)
		end
	end

	if (not p1.alive and p1.death_timeout<20) then
		outline("w a s t e d", 40,54,0,2)
	end
	if (recent_kills>4) then
		outline("  k i l l\nf r e n z y !", 40,50,0,10)
	end
	if (endstep>3) then
		outline("  m i s s i o n\nc o m p l e t e !", 30,50,0,10)
	end
	if (endstep>4) then
		local col=10
		local buf="unlocked"
		if(not p1.machine_gun) then
			dset(1,1)
		else
			col=5
			if(dget(1)==1) then
				col=6
			else
				buf="  locked"
			end
		end
		outline("achievement ".. buf .. ": authentic",2,80,0,col)
		col=10
		buf="unlocked"
		if(final_kills==0) then
			dset(2,1)
		else
			col=5
			if(dget(2)==1) then
				col=6
			else
				buf="  locked"
			end
		end
		outline("achievement ".. buf .. ": pacifist",2,90,0,col)
		col=10
		buf="unlocked"
		if(p1.coins==35 and machine_guns==6) then
			dset(3,1)
		else
			col=5
			if(dget(3)==1) then
				col=6
			else
				buf="  locked"
			end
		end
		outline("achievement ".. buf .. ": collector",2,100,0,col)
		col=10
		buf="unlocked"
		if(final_wanted_level==5) then
			dset(4,1)
		else
			col=5
			if(dget(4)==1) then
				col=6
			else
				buf="  locked"
			end
		end
		outline("achievement ".. buf .. ": criminal",2,110,0,col)
		col=10
		buf="unlocked"
		if(finaltime<1500) then
			dset(5,1)
		else
			col=5
			if(dget(5)==1) then
				col=6
			else
				buf="  locked"
			end
		end
		outline("achievement ".. buf .. ": speedrun",2,120,0,col)
	end
	
end
function check_if_bumped_by_player(self)
	--check for collision at multiple points along the top
	--of the sprite: left, center, and right

	if (p1.dy<0) return false
	for i=-(self.w/3),(self.w/3),2 do
		--if intersects_point_box(self.x-8+i,self.y-8,p1.x-8,p1.y+6,16,2) then
--			x1,y1,
	--w1,h1,
	--x2-,y2,
	--w2,h2)

		if intersects_box_box(self.x-8,self.y-8,16,2,p1.x-8,p1.y+6,16,2) then
			self.alive=false
			self:set_anim("death")
			self.dx=0
			p1.bumped=true
			p1.jump_button.ticks_down=0
			add_blood(self.x,self.y)
			kills+=1
			sfx(12)
			updatewarning()
			return true
		end
	end
	return false
end

function updatewarning()
	if ticks-last_kill<=90 then
		recent_kills+=1
	else
		recent_kills=1
	end
	last_kill=ticks

	if kills==1 then
		wanted_level=1
		police_level=800
	elseif kills>19 then
		wanted_level=5
		police_level=180
	elseif kills>12 then
		wanted_level=4
		police_level=300
	elseif kills>6 then
		wanted_level=3
		police_level=440
	elseif kills>2 then
		wanted_level=2
		police_level=600
	end
end

function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

function intro_init()
  map_x = 130
  map_y_org = 24
  offs=121
  music(10,50)
end

function intro_update()
	map_x -= 1
	if (btnp(4) or btnp(5) or map_x < -320) then
		intro=false
		music(-1,20)
		music(1)
	end
end

function intro_draw()
	cls(0)
	map_y = map_y_org 
	spr(offs+1, map_x+48, map_y)
	spr(offs+1, map_x+80, map_y)
	spr(offs+1, map_x+96, map_y)

	map_y += 8
	spr(offs+5, map_x+32, map_y)
	spr(offs-15, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+5, map_x+56, map_y)
	spr(offs-15, map_x+64, map_y)
	spr(offs+3, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+5, map_x+112, map_y)
	spr(offs-15, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+5, map_x+152, map_y)
	spr(offs-15, map_x+160, map_y)
	spr(offs+3, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs-15, map_x+184, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+5, map_x+200, map_y)
	spr(offs-15, map_x+208, map_y)
	spr(offs+3, map_x+216, map_y)

	map_y += 8
	spr(offs+1, map_x+32, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+1, map_x+56, map_y)
	spr(offs+1, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+1, map_x+112, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+1, map_x+152, map_y)
	spr(offs+1, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y += 8
	spr(offs+2, map_x+32, map_y)
	spr(offs-15, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+56, map_y)
	spr(offs-15, map_x+64, map_y)
	spr(offs+6, map_x+72, map_y)

	spr(offs+2, map_x+80, map_y)
	spr(offs+1, map_x+88, map_y)

	spr(offs+2, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs-15, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs-15, map_x+160, map_y)
	spr(offs+6, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+2, map_x+200, map_y)
	spr(offs-15, map_x+208, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y += 16
	spr(offs+1, map_x+104, map_y)
	spr(offs+1, map_x+152, map_y)
	spr(offs+4, map_x+168, map_y)

	map_y += 8

	spr(offs-15, map_x+24, map_y)
	spr(offs-15, map_x+32, map_y)
	spr(offs+3, map_x+40, map_y)

	spr(offs+5, map_x+48, map_y)
	spr(offs+1, map_x+56, map_y)

	spr(offs+5, map_x+64, map_y)
	spr(offs-15, map_x+72, map_y)
	spr(offs+3, map_x+80, map_y)
	
	spr(offs+5, map_x+88, map_y)
	spr(offs-15, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+1, map_x+112, map_y)
	
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs-15, map_x+152, map_y)
	spr(offs+1, map_x+160, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs-15, map_x+184, map_y)
	spr(offs+3, map_x+192, map_y)

	spr(offs-15, map_x+200, map_y)
	spr(offs-15, map_x+208, map_y)
	spr(offs+3, map_x+216, map_y)

	spr(offs+5, map_x+224, map_y)
	spr(offs+1, map_x+232, map_y)

	map_y += 8

	spr(offs+1, map_x+24, map_y)
	spr(offs+1, map_x+40, map_y)

	spr(offs+1, map_x+48, map_y)

	spr(offs+1, map_x+64, map_y)
	spr(offs+1, map_x+80, map_y)
	
	spr(offs+1, map_x+88, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+1, map_x+112, map_y)
	
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+1, map_x+152, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+1, map_x+216, map_y)

	spr(offs+2, map_x+224, map_y)
	spr(offs+3, map_x+232, map_y)

	map_y += 8

	spr(offs-15, map_x+24, map_y)
	spr(offs-15, map_x+32, map_y)
	spr(offs+6, map_x+40, map_y)

	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+64, map_y)
	spr(offs-15, map_x+72, map_y)
	spr(offs+6, map_x+80, map_y)
	
	spr(offs+2, map_x+88, map_y)
	spr(offs-15, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs-15, map_x+120, map_y)
	spr(offs+6, map_x+128, map_y)

	spr(offs+2, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs+1, map_x+160, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+2, map_x+176, map_y)
	spr(offs-15, map_x+184, map_y)
	spr(offs+6, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+1, map_x+216, map_y)

	spr(offs-15, map_x+224, map_y)
	spr(offs+6, map_x+232, map_y)

	map_y += 8

	spr(offs+1, map_x+24, map_y)

end
__gfx__
eeeeeeeeeeeee999eeeeee88888eeeeeeeeeee88888eeeeeeeeeeeeeeeeeeeeeeeeeee88888eeeeeeeeee88888eeeeeeeeeeeeeeeeeeeeee1555555555555551
eeeeee88888ee999eeeee888888888eeeeeee888888888eeeeeeeee88888eeeeeeee588888888eeeeeee888888888eeeeeeeeeeeeeeeeeee5444444444444445
eeeee88888888899eeeee5559959eeeeeeeee5559959eeeeeeeeee888888888eeee555555959eeeeeeee5559959eeeeeeeeee8888eeeeeee5454444444444545
eeeee5559959e555eeee5959995999eeeeee5959995999eeeeeeee5559959eeeee995995999999eeeee5959995999eeeee9988888899eeee5444444444444445
eeee595999599555eeee59559995999eeeee59559995999eeeeee5959995999eee9959955995599eeee59559995999ee999595995959999e5444444444444445
eeee595599959995eeee5599995555eeeeee5599995555eeeeeee59559995999eee99599999955eeeee5599995555eee995595995955999e5444444444444445
eeee55999955555eeeeeee9999999eeeeeeeee9999999eeeeeeee5599995555eeeee888555899eeeeeeee9999999eeee995559999555999e5444444444444445
eeeeee99999995eeeee55558855eeeeeeeeee558555eeeeeeeeeeee9999999eeeee88999588555eeeeee558555eeeeeeeee5559955555eee5444444444444445
ee55555855585eeee995555888555999eeee55558855eeeeeeeeee555585e9eeeee85999555555eeeee5558558555eeeeee595555955eeee5444444444444445
e555555585558ee5e999e55898885599eeee555889889eeeeeeee9555555999eeee88899555555eeee555588885555eeeee599999955eeee5444444444444445
9955555588888ee5e99ee8888888ee5eeeee555588888eeeeeee9985555599eeeeee888885555eeeee995898898599eeee88899998888eee5444444444444445
999e885889889855eeee88888888855eeeee855999888eeeeeee558888888eeeeeee85558888eeeeee999888888999eee5588555588555ee5444444444444445
e9e5888888888855eee888888888855eeeeee8599888eeeeeeee588888888eeeeeeee5555888eeeeee998888888899eee5558855885555ee5444444444444445
ee55588888888855ee55888eee88855eeeeeee888555eeeeeee55888e888eeeeee5e5885558eeeeeeeee888ee888eeeee5558988985555ee5454444444444545
e5558888888eeeeeee555eeeeeeeeeeeeeeeee5555555eeeeee5eeee555eeeeeee555558eeeeeeeeeee555eeee555eeee5558888885555ee5444444444444445
e5ee8888eeeeeeeeeee555eeeeeeeeeeeeeeee5555eeeeeeeeeeeeee5555eeeeeee5555eeeeeeeeeee5555eeee5555eeee55888888555eee1555555555555551
eeeeeeeeeeeee999eeeeee88888eeeeeeeeeee88888eeeeeeeeeeeeeeeeeeeeeee00ee88888eeeeeeeeee88888eeeeeeeeeeeeeeeeeee00eeee44eeeeee00eee
eeeeee88888ee999eeeee888888888eeeeeee888888888eeeeeeeee88888eeeeee00588888888eeeeeee888888888eeeeeeeeeeeeeeee00eee4444eeee0000ee
eeeee88888888899eeeee5559959eeeeeeeee5559959eeeeeeeeee888888888eee0055555959eeeeeeee5559959eeeeeeeeee8888eeee00ee004400ee000000e
eeeee5559959e555eeee5959995999eeeeee5959995999eeeeeeee5559959eeeee995995999999eeeee5959995999eeeee9e888888eee00e4f0000f400000000
eeee595999599555eeee59559995999eeeee59559995999eeeeee5959995999eee9950055995599eeee59559995999ee99959599595ee99e4f0ff0f400000000
eeee595599959995eeee5599995555eeeeee5599995555eeeeeee59559995999ee000009999955eeeee5599995555eee995595995955999e4444444400000000
eeee55999955555eeeeeee9999999eeeeeeeee9999999eeeeeeee5599995555eee00008555899eeeeeeee9999999eeee995559999555999eeffffffee000000e
eee55599999995eeeeee5558855eeeeeeeeee558555eeeeeeeeeeee9999999eeee000999588555eeeeee558555eeeeeeeee555995555500ee00ee00ee00ee00e
ee9900000000000eeee5555888555eeeeeee55558855eeeeeeeeee555585e9eeee000999555555eeeee5558558555eeeeee595555955000eeeeeeeeeeeeeeeee
ee99900000000005eee9900000009900eee9900000009900eeeee90000009900ee000099555555eeee5000000000000eeee599999955000eeeeeeeeeeeeeeeee
e009900000008ee5eee9990000009900eee9990000009900eee0990000009900eee0008885555eeeee9900000000000eee888999988880eeeee000000000000e
0000885800089855ee0099000000055eee00990000000eeeee00990000000eeeeeee00558888eeeee0999000000999eee5588555588555eeee0000000000000e
00e5888880008855e00008888000855ee00008888000eeeee000088880008eeeeeeee5555888eeee00998880008899eee5558855885555eee0000000000eeeee
ee55588888008855e005888eee00055ee00eee8885000eeee0055888e8000eeeee5e5885558eeeee00ee888e0008eeeee5558988985555ee0000eee000eeeeee
e5558888888eeeeeee555eeeeee00eeeeeeeee5555500eeeeee5eeee55500eeeee555558eeeeeeeeeee555eee0055eeee5558888885555ee00eeeeee000eeeee
e5ee8888eeeeeeeeeee555eeeeeeeeeeeeeeee5555eeeeeeeeeeeeee5555eeeeeee5555eeeeeeeeeee5555eeee5555eeee55888888555eeeeeeeeeeee00eeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ffffffff14ffff4ffffffff11111111ddddddd1ddddddd1144444444444444100000000000000000000000000000000
eee94eeeee9999eeeee74eeeeeee9eeef444444441f444414444444111111111ddddddd1ddddddd149999999999999950bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0
eee94eeee999999eeee74eeeeeee9eeef444444441f444414444444111111111ddddddd1ddddddd14919999999999195033333bbbbbb33333333333333333330
ee9444eee997799eee7774eeeeee9eeef444444441f444411111111111111111111111111111111149999444449999950bbb33bbbbbb3bb3333333333b3b3bb0
ee9444ee99799499ee7774eeeeee9eeef444444441f144414441444411111111ddd1ddddddd1dddd49994411144999950bbb33bbbbbb3bb33333333333b3bbb0
ee9444ee99799499ee7774eeeeee9eeef4444444414111144441444411111111ddd1ddddddd1dddd49994419944199950bbb33bbbbbb3bb3333333333b3b3bb0
ee9444ee99799499ee7774eeeeee9eeef444444441fffff14441444411111111ddd1ddddddd1dddd49994419944199950bbb33bbbbbb3bb33333333333b3bbb0
ee7444ee99799499ee7774eeeeee7eeef444444441f444411111111111111111111111111111111149999119444199950bbb33bbbbbb3bb3333333333b3b3bb0
ee7444ee99799499ee7774eeeeee7eeef444444441f444414444444111111111ddddddd1ddddddd149999994411199950bbb33bbbbbb3bb33333333333b3bbb0
ee9444ee99799499ee7774eeeeee9eeef444444441f444414444444111111111ddddddd1dd8dd88149999994419999950bbb33bbbbbb3bb3333333333b3b3bb0
ee9444ee99799499ee7774eeeeee9eee114444441f4444414444444111111111ddddddd1ddd8d8d149999999119999950bbb33bbbbbb3bb33333333333b3bbb0
ee9444ee99799499ee7774eeeeee9eeeff1144441f4444411111111111111111111111111111811149999994499999950bbb33bbbbbb3bb3333333333b3b3bb0
ee9444eee997799eee7774eeeeee9eeef4ff1111f44444414441444411111111ddd1ddddddd18ddd49999994419999950bbb33bbbbbb3bb33333333333b3bbb0
eee94eeee999999eeee74eeeeeee9eeef444fff1f44444414441444411111111ddd1ddddddd8d8dd49199999119991950bbb33bbbbbb3bb3333333333b3b3bb0
eee94eeeee9999eeeee74eeeeeee9eeef4444441f44444114441444411111111ddd1dddddd81d8dd499999999999999500000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee41111114f1111114111111111111111111111111111118111555555555555551ee0000000000000000000000000000ee
d666666661d6666dd66666666666666deeeeee4444eeeeeeeeeeee4444eeeeee499999944111999511111111eee990eeee0bbb33bbbbb3bb33333333b3bbb0ee
6dddddddd16dddd16d666666666666d5eeeee444444eeeeeeeeee444444eeeee499999944199999511111111ee99990eee0bbb33bbbbb3bb333333333b3bb0ee
6dddddddd16dddd166d6666666666d55eeee44444444eeeeeeee44444444eeee499999991199999511111111ee99990eee0bbb33bbbbb3bb33333333b3bbb0ee
6dddddddd16dddd1666d66666666d555eee4444444444eeeeee4444444444eee499999944999999511111111ee99990eee0bbb33bbbbb3bb333333333b3bb0ee
6dddddddd161ddd16666dddddddd5555ee400444444004eeee400444444004ee499999944199999511111111ee99990eee0bbb33bbbbb3bb33333333b3bbb0ee
6dddddddd1d1111d6666dddddddd5555e444f044440f444ee444f044440f444e491999991199919511111111ee99990eee0bbb33bbbbb3bb333333333b3bb0ee
6dddddddd16666616666dddddddd5555e444f000000f444ee444f000000f444e499999999999999511111111ee09904eee0bbb33bbbbb3bb33333333b3bbb0ee
6dddddddd16dddd16666dddddddd55554444f0f44f0f44444444f0f44f0f4444155555551555555100000000eee004eeee0bbb33bbbbb3bb333333333b3bb0ee
6dddddddd16dddd16666dddddddd55554444fff44fff44444444fff44fff4444eeeeeee444eeeeee111111101111111111000000111111100000011111111110
6dddddddd16dddd16666dddddddd555544444444444444444444444444444444eeee444444444eee111111101111111111110000111111100001111111111110
11dddddd16ddddd16666dddddddd5555e4444ffffff4444ee4444ffffff4444eee4400044400044e111111100111111111111000111111100011111111111100
6611dddd16ddddd16666dddddddd5555eeeeffffffffeeeeeeeeffffffffeeeee44ffff000ffff44111111100111111111111100111111100111111111111100
6d6611116dddddd1666d55555555d555eeeeffffffff00eeee00ffffffffeeeee444444444444444111111100011111111111100111111100111111111111000
6ddd66616dddddd166d5555555555d55eee00fffff00000ee00000fffff00eeeeeeefffffffffeee111111100001111111111110000000001111111111110000
6dddddd16ddddd116d555555555555d5eee000fff000000ee000000fff000eeeeeeeefffffffeeee111111100000011111111110000000001111111111000000
d111111d6111111dd55555555555555deeee000ee00000eeee00000ee000eeeeee00000eee00000e000000000000000000000000000000000000000000000000
8585c60000f68585858585858585858585858585858585858585858585858585858585858585858585c6d6e6f685858585858585858585858585858585858585
858585858585858585858585858585858585858585858585c6d6e6f685858585858585858585858585858585858585858585c6d6e6f6858585858585a4b48585
8585c60000f68585858585858585858585858585858585858585858585858585858585858585858585c6d6e6f685858585858585858585858585858585858585
858585858585858585858585858585858585858585858585c6d6e6f685858585858585858585858585858585858585858585c40000f4858585858585a5b58585
8585c60000f60000000000000000000000000000000000000000000000000000000000000000000000c40000f400000000000000000000000000000000000000
000000000000000000000000000000000000000000000000c40000f400000000000000000000000000000000000000000000c50000f500000000000000008585
8585c60000f60000000000000000000000000000000000000000000000000000000000000000000000c50000f500000000000000000000000000000000000000
000000000000000000000000000000000000000000000000c50000f5000000000000000000000000000000000000000000000000000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008585
8585c60000f6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a4b40000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008585858585858585858585858585858585858585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086960000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008585858585858585858585858585858585858585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008585000000000000000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008585000000000000000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000007475000000008585000000000000000000000000000000008585
8585c60000f674750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000007475000000008585000000000000000000000000000000008585
8585c60000f674750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000263600000000000000000000000000000000008585000000000000000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074750000000000000000000000
00000000000000000000000000000000000000000000000000273700000000000000000000000000000000008585000000008585858585858585000000008585
8585c60000f600000000000000000000000000747500000000000000000000000000000000000000000000000000000000000074750000000000000000000000
00000000000000000000000000000000002636000000000000263600000000002636000000000000000000008585000000008585858585858585000000008585
8585c60000f600000000000000000000000000747500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000002737000000000000273700000000002737000000000000000000008585000000008585000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a4b485858585858585858585a4b48585858585858585858585858585858585000000008585000000008585000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a5b585858585858585858585a5b58585858585858585858585858585858585000000008585000000008585000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000858585000000008585a4b400008585000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000858585000000008585a5b500008585000000000000000000008585
8585c60000f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000858585000000008585000000008585000000008585858585858585
8585c40000f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000085850000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000858585000000008585000000008585000000008585858585858585
8585c50000f500000000000000a4b4a4b4a4b4a4b4a4b40000000000000000000000000000000000000000000000000000000084940000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000858585000000000000000000008585000000000000000000008585
858500000000000000000000008696a5b5a5b5a5b5a5b50000000000000000000000000000000026360000263600000000000000000000000000000000000000
0000008585858585858585a4b48585c4d4e4f48585a4b48585858585858585858574750000858585000000000000000000008585000000000000000000008585
85850000000000000000000000000000000000000000000000000000000000000000000000000027370000273700000000000000000000000000000000000000
0000008585858585858585a5b58585c5d5e5f5858586968585858585858585858574750000858585000000000000000000008585000000000000000000008585
85850000000000000000000000000000000000000000000000000000000000000000002636000026360000263600002636000000000000263600000000000000
000000000000000000000000000000c6d6e6f6000000000000000000000000000000000000858585000000000000000000008585000000000000000000008485
85850000000000000000000000000000000000000000000000000000000000000000002737000027370000273700002737000000000000273700000000000000
000000000000000000000000000000c6d6e6f6000000000000000000000000000000000000858585000000000000000000008585000000000000000000008585
85850000000000000000000000000000000000000000000000000000000000263600002636000026360000263600002636000000000000263600002636000000
000000000000000000000000000000c6d6e6f60000000000000000000000000000000000008585858585000000008585858585858585a4b48585c4d4e4f48485
85850000000000000000000000000000000000000000000000000000000000273700002737000027370000273700002737000000000000273700002737000000
000000000000000000000000000000c6d6e6f60000000000000000000000000000000000008585858585000000008585858585858585a5b58585c5d5e5f58585
85850000000000000000000000000000000000000000000000000026360000263600002636000026360000263600002636000000000000263600002636000000
000000000000000000000000000000c6d6e6f6000000000000000000000000000000000000858585000000000000000000000000000000000000c6d6e6f68485
85850000000000000000000000000000000000000000000000000027370000273700002737000027370000273700002737000000000000273700002737000000
000000000000000000000000000000c6d6e6f6000000000000000000000000000000000000858585000000000000000000000000000000000000c6d6e6f68585
06160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616
06160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616061606160616c6d6e6f60616
07170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717
07170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717071707170717c6d6e6f60717
__gff__
0000000000000000000000000000010300000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000001010101010101020101030301090901000000000101010201010303010101010101010100000000050500000101010101010101000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004a4b000000000000000000000000000000004a4b4a4b4a4b4a4b000000000000000000000000000000000000004a4b00000000000000000000000000000000000000005656
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006869000000000000000000000000000000005a5b5a5b5a5b5a5b000000000000000000000000000000000000005a5b00000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000464646460000000000000000000000000000464646464646464646460000000000000000000000000046464646464646460000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000565656560000000000000000000000000000565656565656565656560000000000000000000000000056565656565656560000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000004a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000005a5b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004a4b00000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000686900000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005656
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004a4b5656
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a5b5656
0000000000000000000000000000000000000000000000004a4b00000000000046464a4b46464a4b4646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046464a4b4646000000000000000000000000000000005656
0000000000000000000000000000000000000000000000005a5b0000000000005656686956565a5b5656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056565a5b5656000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c4d4e4f00000000000000000000004c4d4e4f00000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c5d5e5f00000000000000000000005c5d5e5f00000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c4d4e4f00000000000000006c6d6e6f00000000000000000000006c6d6e6f00000000000000000000000000000000000000000000000000000000005656
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c5d5e5f00000000000000006c6d6e6f00000000000000000000006c6d6e6f00000000000000000000000000000000000000000000000000000000005656
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c4d4e4f000000000000000000000000006c6d6e6f00000000000000006c6d6e6f00000000000000000000006c6d6e6f00000000000000000000000000000000000000000000000000000000005656
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c5d5e5f000000000000000000000000006c6d6e6f00000000000000006c6d6e6f00000000000000000000006c6d6e6f00000000000000000000000000000000000000000000000000000000005656
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006c6d6e6f000000000000000000000000006c6d6e6f00000000000000006c6d6e6f00000000000000000000006c6d6e6f00000000000000000000000000000000004c4d4e4f00000000000000005656
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006c6d6e6f000000000000000000000000006c6d6e6f00000000000000006c6d6e6f00000000000000000000006c6d6e6f00000000000000000000000000000000005c5d5e5f00000000000000005656
4445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544456c6d6e6f44454445444544454445
5455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554555455545554556c6d6e6f54555455545554555455
__sfx__
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
01060000250512b051330513d05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000265300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000255100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002404030540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180301c031260313503100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001a0400e0401c040100401d040110401f04013040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01050000265401a540285401c540295401d5402b5401f540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001555321553155532155315553095110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c2320c2330c2330023300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018632242330c2330023300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001c1300e130001301c1300e130001301c1300e130001300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f015300152d01528015300152d01529015280152d0152b0152d015290152d015280152b0152d0152f015300152d015340152f015320152d015300152b0152d015280152901526015280152401526015
011000002301524015210151c01524015210151d0151c0151f0151c015210151d015230151c0151f0152301524012240122401224015210051d00523005210052400523005260052400528005260052b00528005
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
00 00 01 43 44
00 00 01 43 44
01 00 01 43 44
00 00 01 43 44
00 02 03 43 44
02 02 03 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 18 42 43 44
04 19 42 43 44
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
