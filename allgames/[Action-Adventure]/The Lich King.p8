pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--the lich king
--by @dollarone 
--made for cgajam
--june 2017
--
--using a modified version of 
--advanced micro platformer
--by @matthughson
--https://www.lexaloffle.com/bbs/?tid=28793


--sfx
snd=
{
	jump=0,
	hit=1,
	attack=2,
	drink=3,
	damage=4,
	crash=5,
	pickup=6,
	open_lock=7,
	found_key=8,
	boss_attack=9,
	boss_hit=10,
	boss_death=11,
	locked=12,
	drink_full=13,
}

--music tracks
mus=
{
	new_game=0,
	boss=39,
	ending=29,	
}

function top_message(msg) 
	message = msg
	message_time=120
end

function found_item(consumable)
	local found = false
	for item in all(found_items) do
		if(item.frame == consumable.frame)found=true
	end
	if(not found) then
		add(found_items,consumable)
		score+=100
	end
end

--math
--------------------------------

--point to box intersection.
function intersects_point_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<=flr(x+w) and
				flr(py)>=flr(y) and flr(py)<=flr(y+h) then
	--if px>=x and px<=(x+w) and
	--			py>=y and py<=(y+h) then

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

	local offset=self.w/3+1.2

	if(self.base_frame==192) then
		offset = 20+self.flip_mod*4
	elseif self.flipx then
		offset+=1
	end

	for i=-(self.w/3),(self.w/3),2 do
	--if self.dx>0 then
		if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr(((self.x+(offset))/8))*8)-(offset)
			return true
		end
	--elseif self.dx<0 then
		if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
			return true
		end
--	end
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
		if fget(tile,0) or (fget(tile,1) and self.dy>=0) then
			self.dy=0
			self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
			self.grounded=true
			self.airtime=0
			landed=true
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
	for i=-(self.w/3),(self.w/3),2 do
		if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
			self.dy=0
			self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
			self.jump_hold_time=0
		end
	end
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


--utils
--------------------------------

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
function printc(
	str,x,y,
	col,col_bg,
	special_chars)

	local len=(#str*4)+(special_chars*3)
	local startx=x-(len/2)
	local starty=y-2
	printo(str,startx,starty,col,col_bg)
end

--objects
--------------------------------

--make the player
function m_player(x,y)

	--todo: refactor with m_vec.
	local p=
	{
		health=5,
		maxhealth=5,
		hurting=false,
		countdown=0,
		shake_ticks=15,
		shake_force=3,
		shake_ticks_damage=5,
		shake_force_damage=1,
		blood_color=2,
		blood_amount=20,
		blood_countdown=10,
		weapon_pickup_timeout=0,
		type="player",
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=8,
		h=8,
		
		max_dx=2,--1 --max x speed
		max_dy=3,--max y speed

		jump_speed=-1.95, --1.75,--jump veloclity
		acc=0.1, --0.05,--acceleration
		dcc=0.8, --0.8--decceleration
		air_dcc=0.7,--2 air decceleration
		grav=0.4, --0.15,
		
		--helper for more complex
		--button press tracking.
		--todo: generalize button index.
		jump_button=
		{
			update=function(self)
				--start with assumption
				--that not a new press.
				self.is_pressed=false
				if btn(5) then
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
		max_jump_press=15,--max time jump can be held

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
				frames={2},--what frames are shown.
			},
			["walk"]=
			{
				ticks=5,
				frames={3,4,5,6},
			},
			["jump"]=
			{
				ticks=1,
				frames={1},
			},
			["slide"]=
			{
				ticks=1,
				frames={7},
			},
			["death"]=
			{
				ticks=1,
				frames={32},
			},
			
		},

		weapons= 
		{
			[8]=
			{
				weapon_start=
				{
					x=0,
					y=-5,
				},
				weapon_end= 
				{
					x=7,
					y=0,
				},
			},
			[24]=
			{
				weapon_start=
				{
					x=0,
					y=-2,
				},
				weapon_end= 
				{
					x=2,
					y=0,
				},
			},
			[40]=
			{
				weapon_start=
				{
					x=0,
					y=-3,
				},
				weapon_end= 
				{
					x=3,
					y=0,
				},
			},
			[12]=
			{
				weapon_start=
				{
					x=1,
					y=-5,
				},
				weapon_end= 
				{
					x=6,
					y=1,
				},
			},
			[28]=
			{
				weapon_start=
				{
					x=2,
					y=-5,
				},
				weapon_end= 
				{
					x=6,
					y=2,
				},
			},
			[44]=
			{
				weapon_start=
				{
					x=3,
					y=-4,
				},
				weapon_end= 
				{
					x=9,
					y=1,
				},
			},
		},

		attack_anims= 
		{
			["rest"]=
			{
				ticks=1,
				frames={0},
			},
			["attack"]=
			{
				ticks=1,
				frames={0,1,2,3,2,1},--{25,26,27,28,27,26},
			},
		},
		curanim="walk",--currently playing animation
		curframe=1,--curent frame of animation.
		animtick=0,--ticks until next frame should show.
		attack_animtick=0,
		curattack_anim="rest",
		curattack_frame=1,
		flipx=false,--show sprite be flipped.
		curweapon=24,
		flip_mod=0, --just here to make collide_side compile
		
		weapon_length=10,
		weapon_offset=1,
		weapon_minus_offset=0,
		dead=false,

		reset_weapon_pickup_timeout=function(self)
			self.weapon_pickup_timeout=130
		end,
		--request new animation to play.
		set_anim=function(self,anim)
			if(anim==self.curanim)return--early out.
			local a=self.anims[anim]
			self.animtick=a.ticks--ticks count down.
			self.curanim=anim
			self.curframe=1
		end,
		set_attack_anim=function(self,attack_anim)
			if(attack_anim==self.curattack_anim)return--early out.
			local a=self.attack_anims[attack_anim]
			self.attack_animtick=a.ticks--ticks count down.
			self.curattack_anim=attack_anim
			self.curattack_frame=1
		end,

		take_damage=function(self)
			self.health-=1
			sfx(snd.damage)
			if self.health < 1 then
				self:die()
			else
				self.hurting=true
				self.countdown=hurtcountdown
			end
		end,
		die=function(self)
			self:set_anim("death")
			self.dead=true
			explode(self.blood_color,flr(rnd(20))+self.blood_amount,self.blood_countdown+flr(rnd(10)),self.x+4, self.y+4)
		end,

		--call once per tick.
		update=function(self)
			if(self.weapon_pickup_timeout>0) then
				self.weapon_pickup_timeout=self.weapon_pickup_timeout-1
			end
			if self.hurting then
				if self.countdown == 0 then
					self.hurting=false
				else
					self.countdown-=1
				end
			end
			
			--track button presses
			local bl=btn(0) --left
			local br=btn(1) --right

			if self.dead then
				if collide_floor(self) then
					self.grounded=true
				else
					self.dy+=self.grav
					self.dy=mid(-self.max_dy,self.dy,self.max_dy)
					self.y+=self.dy
				end
				return
			end
			
			
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

			--limit walk speed
			self.dx=mid(-self.max_dx,self.dx,self.max_dx)

			if abs(self.dx) < 0.1 then
				self.dx = 0
			end
			
			--move in x
			self.x+=self.dx
			
			--hit walls
			collide_side(self)


			if(btn(4) and self.curattack_anim=="rest") then
				self:set_attack_anim("attack")
				sfx(snd.attack)
			end

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
					if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
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
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				elseif bl then
					if self.dx>0 then
						--pressing left but still moving right.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				else
					self:set_anim("stand")
				end
			end

			--flip
			if br then
				self.flipx=false
				self.weapon_offset=1
				self.weapon_length=self.curweapon
				self.weapon_minus_offset=0
			elseif bl then
				self.flipx=true
				self.weapon_offset=-1
				self.weapon_length=-1-self.curweapon
				self.weapon_minus_offset=-1
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

			self.attack_animtick-=1
			if self.attack_animtick<=0 then
				self.curattack_frame+=1
				local a=self.attack_anims[self.curattack_anim]
				self.attack_animtick=a.ticks--reset timer
				if self.curattack_frame>#a.frames then
					self.curattack_frame=1--loop
					self:set_attack_anim("rest")
				end
			end

		end,

		--draw the player
		draw=function(self)
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			if(self.hurting and ticks%2==0)frame=16
			spr(frame,
				self.x-(self.w/2),
				self.y-(self.h/2),
				self.w/8,self.h/8,
				self.flipx,
				false)
			local a=self.attack_anims[self.curattack_anim]
			local attack_frame=a.frames[self.curattack_frame]
			local offset = 8
			if (self.flipx) then
				offset = -8
			end
			spr(attack_frame + self.curweapon,
				self.x+offset-(self.w/2),
				self.y-(self.h/2),
				self.w/8,self.h/8,
				self.flipx,
				false)
			if(attack_frame+self.curweapon==47) then 
				spr(63,
				self.x+offset+offset-(self.w/2),
				self.y-(self.h/2),
				self.w/8,self.h/8,
				self.flipx,
				false)
			end
		end,
	}

	return p
end


--make a monster
function m_monster(x,y,base_frame,color)

	local p=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=8,
		h=8,

		type="monster",
		
		max_dx=0.5,--max x speed
		max_dy=1,--max y speed

		jump_speed=-1.65,--jump veloclity
		acc=0.02,--acceleration
		dcc=0.8,--decceleration
		air_dcc=1,--air decceleration
		grav=0.3,

		shake_ticks=10,
		shake_force=2,
		blood_color=color,
		blood_amount=10,
		blood_countdown=10,
		
		jump_hold_time=0,--how long jump is held
		min_jump_press=5,--min time jump can be held
		max_jump_press=15,--max time jump can be held

		jump_btn_released=true,--can we jump again?
		grounded=false,--on ground

		airtime=0,--time since grounded
		base_frame=base_frame,
		last_frame=0,
		--animation definitions.
		--use with set_anim()
		anims=
		{
			["stand"]=
			{
				ticks=1,--how long is each frame shown.
				frames={2},--what frames are shown.
			},
			["walk"]=
			{
				ticks=5,
				frames={3,4,5,6},--{self.base_frame+2, self.base_frame+3, self.base_frame+4, self.base_frame+5},--{19,20,21,22},
			},
			["jump"]=
			{
				ticks=1,
				frames={1},--17
			},
			["slide"]=
			{
				ticks=1,
				frames={7},--23
			},
		},

		curanim="stand",--currently playing animation
		curframe=1,--curent frame of animation.
		animtick=0,--ticks until next frame should show.
		attack_animtick=0,
		flipx=false,--show sprite be flipped.
		flip_mod=1,
		hurting=false,
		countdown=-1,
		health=3,
		--request new animation to play.
		set_anim=function(self,anim)
			if(anim==self.curanim)return--early out.
			local a=self.anims[anim]
			self.animtick=a.ticks--ticks count down.
			self.curanim=anim
			self.curframe=1
		end,
		
		set_jump_speed=function(self,speed)
			self.jump_speed=speed
		end,
		set_acc=function(self,acc)
			self.acc=acc
		end,
		set_max_dx=function(self,speed)
			self.max_dx=speed			
		end,
		set_max_dy=function(self,speed)
			self.max_dy=speed
		end,

		take_damage=function(self)
			self.health-=1
			
			if self.health == 0 then
				self.y-=16				
				self.base_frame=240
				sfx(snd.boss_death)
				return true
			else
				sfx(snd.boss_hit)
				self.hurting=true
				self.countdown=hurtcountdown
			end
			return false
		end,

		kill=function(self)
		end,

		--call once per tick.
		update=function(self)
			if self.hurting then
				if self.countdown == 0 then
					self.hurting=false
				else
					self.countdown-=1
				end
			end
	

			local br=false
			local bl=false

			if(abs(p1.x - self.x) < 16*8) then
				if(p1.dead) then
					if(self.base_frame!=192) then
						bl=true
					end
				elseif(p1.x > self.x) and (flr(rnd(30)) > 2) then
					br=true
				elseif (p1.x < self.x) and (flr(rnd(30)) > 2) then
					bl=true
				end
			end

			
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

			--limit walk speed
			self.dx=mid(-self.max_dx,self.dx,self.max_dx)
			
			--move in x
			if(self.base_frame!=-1) self.x+=self.dx
			
			--hit walls
			collide_side(self)

			if (self.health>0 and not p1.dead and flr(rnd(30)) == 1) then
				local on_ground=(self.grounded or self.airtime<5)
				--was btn presses recently?
				--allow for pressing right before
				--hitting ground.
				
				--is player continuing a jump
				--or starting a new one?
				if self.jump_hold_time>0 or (on_ground) then
					if(abs(p1.x-self.x)<10*8 and abs(p1.y-self.y)<8*8 and self.base_frame>0) then
						sfx(snd.jump) --new jump snd
					end
					if(self.jump_hold_time==0) then
						self:set_anim("jump")
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
			
			--move in y
			self.dy+=self.grav
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			if(self.base_frame!=-1)self.y+=self.dy

			--floor
			if not collide_floor(self) then
				self.grounded=false
				self.airtime+=1
			end

			--roof
			collide_roof(self)

			--handle playing correct animation when
			--on the ground.
			if self.health>0 and self.grounded and self.curanim!="jump" then
				if br then
					if self.dx<0 then
						--pressing right but still moving left.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				elseif bl then
					if self.dx>0 then
						--pressing left but still moving right.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				else
					self:set_anim("stand")
				end
			end

			--flip
			if br then
				self.flipx=false
				self.flip_mod=1
			elseif bl then
				if(self.base_frame!=-1) then 
					self.flipx=true
					self.flip_mod=-1
				end
			end

			--anim tick
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				local a=self.anims[self.curanim]
				self.animtick=a.ticks--reset timer
				if self.curframe>#a.frames then
					self.curframe=1--loop
					self:set_anim("stand")
				end
			end
		end,

		--draw the monster
		draw=function(self)
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			if(self.base_frame==-1) then
				frame=49
				flipx=false
			end
			if(self.base_frame==240)frame=0
			if(self.base_frame==192) then
				spr(self.base_frame+frame,	 self.x-8*self.flip_mod, self.y-20,1,1,self.flipx)
				spr(self.base_frame+frame+1, self.x,				 self.y-20,1,1,self.flipx)
				spr(self.base_frame+frame+2, self.x+8*self.flip_mod, self.y-20,1,1,self.flipx)
				spr(self.base_frame+frame+3, self.x+16*self.flip_mod,self.y-20,1,1,self.flipx)
				spr(self.base_frame+frame+16,self.x-8*self.flip_mod, self.y-12,1,1, self.flipx)
				spr(self.base_frame+frame+17,self.x,				 self.y-12,1,1, self.flipx)
				spr(self.base_frame+frame+18,self.x+8*self.flip_mod, self.y-12,1,1, self.flipx)
				spr(self.base_frame+frame+19,self.x+16*self.flip_mod,self.y-12,1,1, self.flipx)
				spr(self.base_frame+frame+32,self.x-8*self.flip_mod, self.y-4,1,1,   self.flipx)
				spr(self.base_frame+frame+33,self.x,				 self.y-4,1,1,   self.flipx)
				spr(self.base_frame+frame+34,self.x+8*self.flip_mod, self.y-4,1,1,   self.flipx)
				spr(self.base_frame+frame+35,self.x+16*self.flip_mod,self.y-4,1,1,   self.flipx)
			else
			spr(self.base_frame+frame,
				self.x-(self.w/2),
				self.y-(self.h/2),
				self.w/8,self.h/8,
				self.flipx,
				false)
			end
			self.last_frame = frame
		end,
	}

	return p
end


--make a monster
function m_breakable(x,y,frame)

	--todo: refactor with m_vec.
	local p=
	{
		x=x,
		y=y,

		type="breakable",
		shake_ticks=4,
		shake_force=1,
		blood_color=6,
		blood_amount=10,
		blood_countdown=5,

		dead=false,
		base_frame=frame,

		update=function(self)
		end,

		kill=function(self)
			self.dead=true
		end,
		draw=function(self)
			if not self.dead then
				spr(self.base_frame,x-4,y-4)
			end
		end,
	}
	return p
end

--make a monster
function m_consumable(x,y,frame)

	--todo: refactor with m_vec.
	local p=
	{
		x=x,
		y=y,

		frame=frame,
		
		draw=function(self)
			if self.x==32*8 then
				spr(self.frame,self.x,self.y)
			elseif(self.frame==125 or self.frame==126 or self.frame==127) then
				spr(self.frame,self.x-12,self.y)
			else
				spr(self.frame,self.x-4,self.y)
			end
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
		pull_threshold=8,

		--min and max positions of camera.
		--the edges of the level.
		pos_min=m_vec(64,64),
		pos_max=m_vec(128*8,8*25),
		
		shake_remaining=0,
		shake_force=0,

		update=function(self)

			self.shake_remaining=max(0,self.shake_remaining-1)
			
			--follow target outside of
			--pull range.
			if self:pull_max_x()<self.tar.x then
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


--make a particle
function m_particle()

	local p=
	{
		x=-128,
		y=-128,
		color=13,
		direction_x=0,
		direction_y=0,
		speed=0,
		dead=true,
		countdown=0,

		--call once per tick.
		update=function(self)
			if not self.dead then
				if self.countdown==0 then
					self.dead=true
				else
					self.countdown -= 1
				end
				self.x+=self.direction_x/2
				self.y+=self.direction_y/2
			end
		end,

		--draw the player
		draw=function(self)
			if not self.dead then
				circfill(self.x, self.y, 0, self.color)
			end
		end,

		set_color=function(self, col)
			self.color = col
		end,

		set_direction=function(self, xdir, ydir)
			self.direction_x = xdir
			self.direction_y = ydir
		end,

		set_countdown=function(self, count)
			self.countdown = count
			if(count>0)self.dead=false
		end,
		set_pos=function(self, x1, y1)
			self.x=x1
			self.y=y1
		end,
	}
	return p
end

--game flow
--------------------------------

--reset the game to its initial
--state. use this instead of
--_init()
function reset()
	ex=0
	ey=0
	ticks=0
	hurtcountdown=30
	p1=m_player(15*8,5*8)
	cam=m_cam(p1)
	palt(0,false) 
	palt(7, true)
	monsters = {}

	add(monsters, m_breakable(126*8+4,84, 98))
	add(monsters, m_breakable(580,188, 98))
	add(monsters, m_breakable(855, 116, 96))
	add(monsters, m_breakable(125*8+4,17*8+4, 96))
	add(monsters, m_breakable(121*8+2,21*8+4, 96))

	add(monsters, m_breakable(29*8+5,23*8+4, 98))
	add(monsters, m_breakable(220,30*8+4,96))
	add(monsters, m_breakable(852, 140, 98))
	add(monsters, m_breakable(629, 244, 97))
	add(monsters, m_breakable(20, 100, 97))
	add(monsters, m_breakable(88*8+2,15*8+4, 98))

	add(monsters, m_monster(81*8,8*6,32,0))
	add(monsters, m_monster(116*8,10*8,32,0))	
	add(monsters, m_monster(125*8,10*8,32,0))
	add(monsters,m_monster(88*8,7*8,32,0))

	add(monsters, m_monster(42*8,8*9,16,6))
	add(monsters, m_monster(52*8,8*9,16,6))
	add(monsters, m_monster(60*8,8*9,16,6))

	--katana room
	local monster=m_monster(32,8*18,48,13)
	monster:set_jump_speed(-2.4)
	monster:set_acc(0.03)
	monster:set_max_dx(1.1)
	monster:set_max_dy(3.2)
	add(monsters, monster)

	local monster=m_monster(8,8*17,48,13)
	monster:set_jump_speed(-2.7)
	monster:set_max_dx(1.2)
	monster:set_max_dy(3.5)
	add(monsters, monster)


	local monster=m_monster(8,8*19,48,13)
	monster:set_jump_speed(-2.2)
	monster:set_acc(0.001)
	monster:set_max_dx(1.1)
	monster:set_max_dy(3)
	add(monsters, monster)

	local monster=m_monster(48*8,31*8-4,192,2)

	monster.anims=
		{
			
			["stand"]=
			{
				ticks=1,
				frames={4},
			},
			["walk"]=
			{
				ticks=6,
				frames={4,0},
			},
			["jump"]=
			{
				ticks=6,
				frames={4,0,4,8,12,12,8,4,0},
			},
			["slide"]=
			{
				ticks=5,
				frames={0},
			},
		}


	monster:set_jump_speed(-2.4)
	monster:set_acc(0.1)
	monster:set_max_dx(1.3)
	monster:set_max_dy(4)
	add(monsters, monster)

	consumables = {}

	--roamers
	local monster=m_monster(33*8,19*8+4,55,2)
	monster:set_jump_speed(-2.85)
	monster:set_max_dy(3)
	add(monsters, monster)

	local monster=m_monster(45*8,19*8+4,55,2)
	monster:set_jump_speed(-2.85)
	monster:set_max_dy(3)
	add(monsters, monster)

    --lock room
	local monster=m_monster(73*8+4,28*8+4,55,2)
	monster:set_jump_speed(-2.85)
	monster:set_max_dy(3)
	add(monsters, monster)

	local monster=m_monster(73*8+4,8*28+4,48,13)
	monster:set_jump_speed(-2.4)
	monster:set_acc(0.03)
	monster:set_max_dx(1.1)
	monster:set_max_dy(3.2)
	add(monsters, monster)

	add(monsters, m_monster(75*8,30*8+4,0,2))

	--key guardian
	local monster=m_monster(21*8,25*8,0,2)
	monster:set_acc(0.13)
	monster:set_max_dx(1.1)
	monster:set_max_dy(1.1)
	add(monsters, monster)

	local monster=m_monster(7*8,26*8,0,2)
	monster:set_acc(0.13)
	add(monsters, monster)

	local monster=m_monster(14*8,30*8,0,2)
	monster:set_acc(0.13)
	add(monsters, monster)

	local monster=m_monster(23*8,29*8,0,2)
	monster:set_acc(0.0001)
	add(monsters, monster)

	-- bottom layer
	local monster=m_monster(88*8,30*8,55,2)
	monster:set_jump_speed(-2.85)
	monster:set_max_dy(3)
	add(monsters, monster)

	local monster=m_monster(95*8,29*8,55,2)
	monster:set_jump_speed(-2.85)
	monster:set_max_dy(3)
	add(monsters, monster)

	--top level
	add(consumables,m_consumable(93*8+4,9*8, 48))
	add(consumables,m_consumable(94*8+4,9*8, 255))
	
	add(monsters, m_monster(8*100+4,8*16+4,-1,6))

	for i=40,41 do
		add(monsters, m_monster(8*i+4,8*19+4,-1,6))
		add(monsters, m_monster(8*(i+20)+4,8*19+4,-1,6))
	end

	local spike_y=92
	for i=77,103 do
		if not((i>84 and i<89) or i==81 or i==82 or (i>90 and i<97) or (i>98 and i<102)) then
			if(i==89) spike_y=76
			add(monsters, m_monster(8*i+4,spike_y,-1,6))
		end
	end
	

	-- skeleton lair
	for i=0,1 do
		add(monsters, m_monster((107+(i*19))*8+4,14*8+4,16,6))
		add(monsters, m_monster((114+(i*5))*8,21*8+4,16,6))
	end


	--mid level
	for i=18,20 do
		add(monsters, m_monster(8*i+4,8*20+4,-1,6))
		if (i!=18)add(monsters, m_monster(8*(i+62)+4,8*20+4,-1,6))
	end
	for i=26,27 do
		add(monsters, m_monster(8*i+4,8*21+4,-1,6))
	end
	
	for i=0,2 do
		add(monsters, m_monster(8*(119+i)+4,8*10+4,-1,6))
	end
	add(monsters, m_monster(8*106+4,8*10+4,-1,6))
	add(monsters, m_monster(8*107+4,8*10+4,-1,6))

	add(monsters, m_monster(8*17+4,8*30+4,-1,6))
	add(monsters, m_monster(8*20+4,8*30+4,-1,6))
	add(monsters, m_monster(8*25+4,8*30+4,-1,6))
	add(monsters, m_monster(8*26+4,8*30+4,-1,6))


	add(monsters, m_monster(740,196,-1,6))
	add(monsters, m_monster(764,196,-1,6))


	for i=106,119 do
		if not((i>109 and i <113)  or (i>115 and i<118)) then
			add(monsters, m_monster(8*i+4,8*30+4,-1,6))
		end
	end


	particles = {}
	
	for i=0,100 do
		add(particles, m_particle())
	end

	inventory = {}
	
	item_names = {
	 [8]="katana",
	[12]="machete",
	[24]="turbo butterfly knife",
	[28]="woodsman's axe",
	[40]="short sword",
	[44]="flail",
	[112]="silver key",
	[113]="indigo key",
	[114]="blood key",
	[116]="health potion"
	}


	--top right
	add(consumables, m_consumable(780,16,116))

	-- visible
	add(consumables, m_consumable(670,112,116))
	
	-- hidden elixir
	add(consumables, m_consumable(24,224,116))

	-- hidden elixir2
	add(consumables, m_consumable(804,192,116))

	-- hidden elixir3? nah too easy
	--add(consumables, m_consumable(73*8+5,8*28,116))

	add(consumables, m_consumable(964,40,113))
	add(consumables, m_consumable(35*8+4,30*8+1,44))
	add(consumables, m_consumable(7*8+4,19*8,125))
	add(consumables, m_consumable(33*8+4,23*8,127))
	add(consumables, m_consumable(32*8,23*8,127))

	add(consumables, m_consumable(35,18*8+1,8))
	add(consumables, m_consumable(160,8*25+2,114))

	add(consumables, m_consumable(8*20+1,8*15+2,112))

	add(consumables, m_consumable(87*8+4,30*8,126))

	--final locks
	for i=0,2 do
		add(consumables, m_consumable((71+i+i)*8+4,30*8,125+i))
	end

	door_countdown=-11
	door_interval=30
	message_time=0
	message = ""
	score = 0
	found_items = {}

	ticks_per_tick=1
	ending_countdown=-1
	doors = { {6,19}, {32,23}, {70,30}, {72,30}, {74,30}, {86,30}, {74,28} }
	music(mus.new_game)
	introduce_lich = true

	for door in all(doors) do
		mset(door[1],door[2],119)
	end

	intro_text = { 
		"       the lich king\n   is rumoured to dwell\n      in castle klamm\n             ",
		"after searching far and wide,\n you finally find yourself\n  in front of the castle",
		"   can you rid the world\n    of the evil that is\n      the lich king?\n          ",
		"", 
	}
	ending_text = {
		"       you have done it!\n                                                         ",
		"     the evil that was\n       the lich king\nexplodes in a cloud of blood\n       ",
		"all that remains is his crown\n                                                    ",
		"     you breathe deeply\n   as you slowly realise\n    there is no way out\n       ",
		"     you are stuck here\n with the lich king's crown\n                             ",
		"         time goes by\n                                                            ",
		"      you sit in silence\n     staring at the crown\n                              ",
		"      what would happen\n      if you put it on?\n                                 ",
		"",
		"    the lich king is dead\n                                                        ",
		"   long live the lich king!\n                                                      ",
		"",
		"          game over\n                                                              ",
		"     thanks for playing!\n                                                         ",
		"   thanks for playing!\n\n    made by dollarone\n\n        june 2017\n             ",
		""
	}
	end_slide_number=0
end

--p8 functions
--------------------------------

function _init()
  	cartdata("dollarone_the_lich_king")
	-- only display intro once
	slide_number=1
	reset()
end

function _update60()
	if(ticks>100 and ticks<2000) and (ticks%200==0) and slide_number<4 then
		slide_number+=1
	end

	if(ending_countdown==0 and (ticks%200==0) and end_slide_number<15) then
		end_slide_number+=1
	end


	ticks+=1
	if((p1.dead or end_slide_number>12) and btnp(3))reset()

	if ending_countdown==0 then
		return
	elseif ending_countdown>0 then
		ending_countdown -= 1
	end

	if(ticks%ticks_per_tick!=0) then
		return
	end
	
	p1:update()
	
	local unlocked_door=false
	local need_key="nope"

	for consumable in all(consumables) do
		if (abs(consumable.x - p1.x) < 11*8) and (abs(consumable.y - p1.y) < 12*8) and intersects_point_box(p1.x,p1.y,consumable.x-5, consumable.y,7,7) then
			if consumable.frame==116 then
				top_message("found " .. item_names[consumable.frame])
				if (p1.health<p1.maxhealth) then
					p1.health+=1
					sfx(snd.drink)
					score+=10
				else
					score+=20
					sfx(snd.drink_full)
				end
				del(consumables, consumable)
			elseif consumable.frame==112 or consumable.frame==113 or consumable.frame==114 then
				top_message("found " .. item_names[consumable.frame])
				add(inventory, consumable)
				found_item(consumable)
				del(consumables, consumable)				
				sfx(snd.found_key)				
			elseif consumable.frame==48 or consumable.frame==255 then
				sfx(snd.crash)
				explode(6,flr(rnd(20))+10,5+flr(rnd(10)), consumable.x,consumable.y)
				del(consumables,consumable)
				for c2 in all(consumables) do
					if c2.frame==48 or c2.frame==255 then
						add(consumables,m_consumable(c2.x+3,c2.y+1,28))						
						explode(6,flr(rnd(20))+10,5+flr(rnd(10)),c2.x,c2.y)
						del(consumables,c2)
					end
				end

			elseif consumable.frame==126 then
				need_key="silver"
				for inv in all(inventory) do
					if inv.frame==112 then
						if (consumable.x==87*8+4) then
							mset(74,28,120)
						end
						mset(consumable.x/8-1, consumable.y/8,120)
						del(consumables, consumable)
						unlocked_door = true
					end
				end
			elseif consumable.frame==125 then
				need_key="indigo"
				for inv in all(inventory) do
					if inv.frame==113 then
						mset(consumable.x/8-1, consumable.y/8,120)
						del(consumables, consumable)
						unlocked_door = true
					end
				end
			elseif consumable.frame==127 then
				need_key="blood"
				for inv in all(inventory) do
					if inv.frame==114 then
						local t=-1
						if(consumable.x==32*8)t=0
						mset(flr(consumable.x/8) + t, consumable.y/8,120)
						unlocked_door = true
						for c in all(consumables) do
							if(c.frame==127 and c.y==consumable.y)del(consumables,c)
						end
						del(consumables, consumable)
					end
				end
			elseif p1.weapon_pickup_timeout==0 and (
				consumable.frame==40 or
				consumable.frame==12 or
				consumable.frame==8 or
				consumable.frame==24 or
				consumable.frame==28 or
				consumable.frame==44) then
					top_message("found " .. item_names[consumable.frame])
					found_item(consumable)
					--local temp = p1.curweapon
					p1.curweapon, consumable.frame = consumable.frame,p1.curweapon
					--consumable.frame=temp
					p1:reset_weapon_pickup_timeout()
					sfx(snd.pickup)
			end
			
		end
	end

	if need_key != "nope" then
		if unlocked_door then
			top_message("door unlocked!")
			score+=50
			door_countdown=door_interval
			sfx(snd.open_lock)
		else
			if(message_time==0)sfx(snd.locked)
			top_message("locked! need " .. need_key .. " key...")
		end
	end

	for monster in all(monsters) do		
		if (abs(monster.x - p1.x) < 11*8) and (abs(monster.y - p1.y) < 12*8)then
			if not(monster.base_frame==192 and (abs(monster.y - p1.y) > 5*8))then
				monster:update()
				if(monster.base_frame==192 and introduce_lich) then
					music(mus.boss)
					introduce_lich = false
				end
			end

			local a=p1.weapons[p1.curweapon]	

			-- >hack due to crown at the end
			if (monster.base_frame>193) then
			elseif (monster.base_frame==192) then
				if(not p1.dead and not p1.hurting and monster.curanim=="jump") then -- and monster.dy>0) then
					if( monster.dy>0 and intersects_point_box(p1.x,p1.y,monster.x,monster.y+3,8,4)) or
					  ( monster.last_frame==0  and intersects_point_box(p1.x+4,p1.y+4,monster.x+8*monster.flip_mod,monster.y-20,9,9)) or
					  ( monster.last_frame==4  and intersects_point_box(p1.x+4,p1.y+4,monster.x+12*monster.flip_mod,monster.y-18,9,9)) or
					  ( monster.last_frame==8  and intersects_point_box(p1.x+4,p1.y+4,monster.x+16*monster.flip_mod,monster.y-9,9,9)) or
					  ( monster.last_frame==12 and intersects_point_box(p1.x+4,p1.y+4,monster.x+16*monster.flip_mod,monster.y-4,9,9)) then

						sfx(snd.boss_attack)
						p1:take_damage()
						cam:shake(20,4)
					end

				end
	
				if( p1.curattack_anim == "attack" and
					intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_start"].x), p1.y + 1 + a["weapon_start"].y, monster.x,monster.y-16,6,3) or
				    intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_end"].x),  p1.y + 1 + a["weapon_end"].y, monster.x,monster.y-16,6,3) )
				    and not monster.hurting then
					cam:shake(15,3)
					-- if monster is ded
					if (monster:take_damage()) then
						for i=1,10 do
							explode(monster.blood_color,10,30,
								p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_start"].x + flr(rnd(24))-12), 
								p1.y + 1 + a["weapon_start"].y + flr(rnd(10))-5)
						end
						music(mus.ending)
						ticks_per_tick=12
						ending_countdown=180
						score+=1000
						for i=1,p1.health do
							score+=100
						end
						if (dget(0) < score) then
							dset(0, score)
						end

					end
				end

			elseif(not p1.dead and not p1.hurting and monster.type == "monster" and intersects_point_box(p1.x,p1.y,monster.x-4,monster.y-4,7,6)) then
				p1:take_damage()
				cam:shake(p1.shake_ticks_damage,p1.shake_force_damage)
			elseif monster.base_frame == -1 then
				for m in all(monsters) do		
					if  m.base_frame != -1 and intersects_point_box(monster.x + 4, monster.y+4, m.x,m.y,7,7) then
						sfx(snd.hit)
						cam:shake(m.shake_ticks,m.shake_force)
						explode(m.blood_color,flr(rnd(20))+m.blood_amount,m.blood_countdown+flr(rnd(10)),monster.x+4,monster.y+4)
						del(monsters, m)
					end
				end
				
			elseif p1.curattack_anim == "attack" then
				
				if intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_start"].x), p1.y + 1 + a["weapon_start"].y, monster.x-4,monster.y-4,7,7) 
					or intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_end"].x),  p1.y + 1 + a["weapon_end"].y, monster.x-4,monster.y-4,7,7) then

				    if(monster.x==852 and monster.y==140) then
				   		add(consumables, m_consumable(853,137,12))
				    elseif(monster.x==580 and monster.y==188) then
				   		add(consumables, m_consumable(584,185,40))
				   	elseif (monster.x==20 and monster.y==100) then
				   		add(consumables, m_consumable(23,96,40))
				    elseif(monster.base_frame==97 or monster.base_frame==98) then
				   		add(consumables, m_consumable(monster.x+1,monster.y-4,116))
				    end
					sfx(snd.hit)
					cam:shake(monster.shake_ticks, monster.shake_force)
					explode(monster.blood_color,flr(rnd(20))+monster.blood_amount,monster.blood_countdown+flr(rnd(10)),monster.x,monster.y)
					if (monster.base_frame==16) then
						add(monsters, m_breakable(monster.x + p1.weapon_minus_offset +  p1.weapon_offset*4,monster.y, 96))
					end
					if(monster.type=="breakable") then
						score+=1
					else
						score+=10
						if(monster.base_frame>40)score+=5
					end
					del(monsters, monster)
					monster:kill()
				end
			end
		end
	end

	for party in all(particles) do
		party:update()
	end

	cam:update()

	if(door_countdown>=0) then
		door_countdown-=1
	end
	if door_countdown==0 then
		for i=122,120,-1 do
			for door in all(doors) do
				if(mget(door[1],door[2])==i) then
					mset(door[1],door[2],i+1)
					door_countdown=door_interval
				end
			end
		end
	end

	if (message_time>0) then
		message_time-=1
	end

end

function explode(color,amount,countdown,x,y)
	local i=0
	local directions = {-1,0,1,-1,0,1,-1,0,1}

	for party in all(particles) do
		if party.dead then
			party:set_color(color)
			party:set_pos(x + directions[flr(i/3%3)+1]*3, y + directions[i%3+1]*3)
			party:set_countdown(countdown)
			party:set_direction(directions[flr(i/3)%3+1]*(flr(rnd(3))+1),directions[i%3+1]*(flr(rnd(3))+1))

			i+=1
		end
		if i==amount then
			return
		end
	end
end

function _draw()

	cls(0)
	camera(cam:cam_pos())

	map(0,0,0,0,128,128)
	spr(157, 0, 8*8)
	spr(173, 0, 9*8)
	for i=0,40,8 do
		spr(128, i, 10*8)
	end

	spr(161, 53*8, 9*8)


	if (ticks%8<4) then
		spr(145, 53*8, 8*8)
		for i=1,2 do
			spr(145, 80*i, 8*8)
		end
		spr(145, 31*8, 8*8)
		spr(145, 43*8, 8*8)

		spr(145, 47*8, 18*8)
		spr(145, 54*8+1, 18*8)

		spr(80, 19*8+5, 16*8-2)
		spr(145, 17*8, 18*8)
		spr(145, 22*8, 18*8)

		spr(80, 6*8, 25*8+1)
		spr(80, 34*8, 30*8)
		for i=0,3 do
			spr(80, (63+2*i)*8, (22+2*i)*8)
		end
		spr(80, 23*8, 22*8+2)
	else
		spr(146, 53*8, 8*8)
		for i=1,2 do
			spr(146, 80*i, 8*8)
		end
		spr(146, 31*8, 8*8)
		spr(146, 43*8, 8*8)

		spr(146, 47*8, 18*8)
		spr(146, 54*8+1, 18*8)

		spr(81, 19*8+5, 16*8-2)
		spr(146, 17*8, 18*8)
		spr(146, 22*8, 18*8)

		spr(81, 6*8, 25*8+1)
		spr(81, 34*8, 30*8)
		for i=0,3 do
			spr(81, (63+2*i)*8, (22+2*i)*8)
		end
		spr(81, 23*8, 22*8+2)
	end

	for consumable in all(consumables) do
		consumable:draw()
	end


	for monster in all(monsters) do
		if (abs(monster.x - p1.x) < 10*8 and abs(monster.y - p1.y) < 14*8) then
			if monster.base_frame == 0 then
				pal(13,2)
				pal(6,13)
				pal(0,2)
			end
			monster:draw()
			if monster.base_frame == 0 then
				pal(13,13)
				pal(0,0)
				pal(6,6)
			end
		end
	end

	for i=0,1 do
	-- statue w katana
	-- and lock room statue
		spr(150, (77-74*i)*8, (28-11*i)*8+i, 1, 1, true)
		spr(166, (77-74*i)*8, (29-11*i)*8+i, 1, 1, true)
		spr(136-i, (57+i)*8, 22*8, 1, 1, true)
		spr(167+i*16, 58*8, (27+i)*8, 1, 1, true)
	end

	--boss room
	spr(152, 57*8, 23*8, 1, 1, true)

	for i=23,26 do
		spr(151, 58*8, i*8, 1, 1, true)
	end

	p1:draw()

	-- hidden elixir
	spr(0, 2*8, 224)
	spr(70, 2*8, 224)

	-- hidden elixir2
	spr(0, 100*8+5, 192)
	spr(72, 100*8, 192)

	--lock room secret
	spr(0, 74*8, 224)
	spr(0, 72*8, 224)
	spr(0, 73*8, 224)
	spr(70, 74*8, 224)


	-- castle	
	spr(190, 60*8, 72)
	spr(130, 62*8, 64)
	spr(188, 63*8, 56)

	for i=0,1 do
		spr(147, (60+i*4)*8, 7*8)
		spr(149, (60+i*4)*8, 8*8)
		spr(149, (61+i*4)*8,  9*8)
		spr(147, (61+i*4)*8, 8*8)
		spr(130+i, (61+i*5)*8, 7*8)
		spr(147+(i*2), (62+i*3)*8, 7*8)
		spr(148-i, (63+i)*8,  9*8)
		spr(149-i, (60+3*i)*8, 6*8)
		spr(133-i-i, (62+4*i)*8, 6*8)
		spr(133, (62+i)*8,  (9-i)*8)
		spr(131, 66*8,  (9-i)*8)	
		spr(104, (26+i)*8, 22*8)
		spr(77-i, (28-4*i)*8, 21*8)
    	spr(82+i, (25+3*i)*8, 22*8)
		spr(77+6*i, (21+3*i)*8, (21+2*i)*8)
		spr(72, 28*8, (29+i)*8)
		spr(70+i+i, (28-4*i)*8, 22*8)	
	    -- well escape
		spr(109-5*i, 23*8+3, (21+i+i)*8)
	end

	for i=0,1 do
		spr(148+i, (64+i)*8, 6*8)
	end

	for i=0,2 do
		spr(175-i, (62+i)*8, 9*8, 1, 1, true)
		spr(159-i, (62+i)*8, 8*8, 1, 1, true)
	end

	spr(142, 63*8, 7*8, 1, 1, true)


    spr(83, 592, 192)

	--hidden flail
	spr(83, 224, 248)

	local a=p1.weapons[p1.curweapon]	

	for party in all(particles) do
		party:draw()
	end

	spr(109, 23*8+3, 21*8)
	camera(0,0)

	
	if(message_time>0) then
		printc(message,64,8,6,0,0)
	end

	if (p1.dead) then
		printc("oh no, you have died!\npress down to restart",106,30,6,0,0)
	elseif (ending_countdown==0 and end_slide_number>0) then
		--printc("oh bro\nbrobrobrobrobrobrobro\nreally long text\nbecause you are aweomse\n\ngame over",180,64-8,6,0,0)
		printc(ending_text[end_slide_number],170,50,6,0,0)
		if (end_slide_number>12) then
			if (dget(0) == score and flr(ticks/50)%2==0) then
				printc("highscore: " .. dget(0),64,88,2,0,0)
			else
				printc("highscore: " .. dget(0),64,88,6,0,0)
			end
		end
		--      
	elseif (slide_number<5) then
		printc(intro_text[slide_number],170,30,6,0,0)
	end


	for i=0,16 do
		spr(118, i*8, 112)
	end

	local tst = 0

	while tst < p1.health do
		spr(176, tst*8, 120)
		tst+=1
	end
	while tst < 5 do
		spr(177, tst*8, 120)
		tst+=1
	end
	while tst < 16 do
		spr(0, tst*8, 120)
		tst+=1
	end
	tst = 6
	for i in all(inventory) do
		spr(i.frame, tst*8, 120)
		tst+=1
	end

	printo("score: " .. score, 80, 122, 2, 13)

end
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
00000000777677677776776777767767777677677776776777767767776776776777777777677777777777777777777766777777777667777777777777777777
00000000777666677776666777766667777666677776666777766667776666776777777777677777777777777777777766777777776667777777777777777777
000000007776060776d6060777760607777606077776060777760607776060776777777777677777777777777777777766777777776677777777777777777777
0000000066d6666776d6666776d6666776d6666776d6666776d66667776666776777777776777777777776667777777766777777766777777777666777777777
0000000067dddd7776dddd7767dddd7776dddd7776dddd7767dddd7776dddd776777777776777777770667777777777767777777766777777766666777777777
000000007766dd6677dddd6667dddd6676dddd6676dddd6667dddd6676dddd660777777707777777007777770006666627777777277777772266777722666667
000000007777dd7777dddd77776ddd7777dd667777dddd7777dddd777766dd770777777707777777777777777777777727777777277777777777777777666667
00000000777776677766766777767667777667777766766777766777777667770777777707777777777777777777777777777777777777777777777777777777
777d77d7766677d776667d7776667d7776667d77766677d7766677d7766677d77777777777777777777777777777777766677777777667777777777777777777
777dddd762626ddd6262ddd76262ddd76262ddd762626ddd62626ddd62626ddd7777777777777777777777777777777766677777776666777777777777777777
7d2d2d2766666ddd6666ddd76666ddd76666ddd766666ddd66666ddd66666ddd7777777777777777777777777777777727777777772767777777777777777777
7d2dddd7760677d776067d7776067d7776067d77760677d7760677d7760677d76777777776777777777777777777777727777777727777777777766777777777
7d222277666666d766666d7766666d7766666d7766666d7766666d7766666d776777777776777777776777777777777727777777727777777722266777777777
772222dd66667767666676776666767766667677666676776666767766667677d7777777d7777777d6777777d667777727777777277777772277766722222667
77222277766777d767767d7767767d7776667d776776d7777667d7776677d7777777777777777777777777777777777727777777277777777777777777777667
77dd7dd7776677776676677776766777766777776676677776677777766777777777777777777777777777777777777777777777777777777777777777777667
77777777777707077777777777770707777777777777777777777070777070777777777777777777777777777777777777677777777d77777777777777777777
7777777777770007777707077777000777770707777770707777700077700007777777777777777777777777777777777676777777ddd777777777d777777777
777777777070d0d0777700077770d0d0777700077777700077770d0d777d0d0067777777767777777777777777777777767d7777777d767777777ddd77777777
77677677000000077770d0d0070700077770d0d07777060670707000070000076777777776777777777767777777777767ddd77777777667777777d777777777
776666777000000007070007700006000707000770707000770000067000000067777777767777777766777777777777677d7777776667777777767777777777
7762627707070007700006000000000770000600770000607000000000000007d7777777d7777777dd777777dd66677727777777227777772266666722666677
7726662777777077000000077070707700000007700000007707070770707077d7777777d7777777777777777777777727777777777777777777777777777766
72222222777777777070707777777777707070777707070777777777777777777777777777777777777777777777777777777777777777777777777777777777
77677677767777767777777776777776777777777677777676777776777777777777777777777777777777777772777777777777777777777777777777777777
77677676766777667677777676677766767777767667776676677766767777767772777777777777777277777722272277727722777777777772777777777777
7767767677ddddd77667776677ddddd77667776677ddddd777ddddd7766777667722277777727777772227777220222277222222777277777722277777777777
776776767dd2dd2d77ddddd77dd2dd2d77ddddd77dd2dd2d7dd2dd2d77ddddd77220272277222777722027227222276772202267772227777202272277777777
766776767ddddddd7dd2dd2d7ddddddd7dd2dd2d7ddddddd77ddddd77d2dd2dd72222222722d2722722222227222677772222777722027227222222277777777
766766767ddd0ddd7ddddddd7dd000dd7ddddddd7d60006d7ddddddd7ddddddd222267677222222272226767722276767222677772222222722267677d777777
7666666677ddddd77dd000dd77ddddd77d60006d7d00000d7d66666d7ddd00dd72222676722267672222767672222222722276762222676722227676ddd77777
666666667777777777ddddd77777777777ddddd777ddddd777ddddd777ddddd7777722222222222222222222222777772222222222222222222222227d777777
76666667666666666666666677777dd66d2777776666666677777dd6777777776d2277777777777d77777777777777777777777777777777d77d77d722227222
6dddddd66dddddddddddddd6772772d66ddd7277dddddddd777d22d6777727776dd777777277777777777d77777722777772777777772777dd72777722227222
222222226d2d2d2dd2d2d2d677777dd66d2777772d2d2d2d77777dd67d7777776d2277277777777777777777777722777777777777d7777d27dd777722227222
7dd77dd76dd22d277d2dddd6777722d66ddd777772d27d27777772d677772d776dd777777777777777777777777777777777777777777777277d777777777777
777777776d2d7d777727d2d67272ddd66d22272772d277777277ddd6777d2d726d27777777777777777777777777777727777777777777727772777777772222
777777776d27777777772dd6d2d2d2d66dd2d2d27777777d777222d6d2d2d2d26ddd77777d7777777777772777777722d27777d77777772d7772777777772222
777777776d2777777777d2d6ddddddd66ddddddd777777777777ddd6dddddddd6d2227d7777772777d7777777277722ddd277777727772dd7777777777772222
777777776ddd72777d7d2dd666666666666666667277d77777d722d6666666666ddd7777777777777777777777777dd66dd2277777772dd67777777777777777
777777777777277777772dd66d27777777777777ddd777777777777ddd77777722222722227222222222722222272227666766677777ddd7dddd7ddddddd7777
77772777777222777d7772dddd27d7777777ddd7dddd7777777dd77777ddd777222227222272222222227222222722272227222777ddddd7dddd7ddddddd7d77
77722277777262777777772d22777777777dddd7dddd7d7777d77d7dd7777d77222227222272222222227222222722272227222777ddddd7dddd7ddddddd7dd7
77726277777222777777777277777777777777777777777777d7d7777ddd7d777777777777777777777777777777777777777777777777777777777777777777
777222777777277777777d777777777777ddd7777777ddd77777d76667d777772227222277777722227222272222722222227222dddd7ddd7ddddd7dddd7ddd7
777767777777677777777777777777d77dddd7777777ddd7d7dd7666667ddd772227222272772722227222272222722222227222dddd7ddd7ddddd7dddd7ddd7
777767777777677772777777777277777dddd7777777ddddd77767666767d7d72227222277777722227222272222722222227222dddd7ddd7ddddd7dddd7dddd
7777d7777777d77777777777777777777777777777777777d7d76667666777d77777777777777777777777777777777777777777777777777777777777777777
77777777776666777dddddd76d2277777dddd7dddd7ddddd77d77666667dd77766666666222722222222722266666667666666677777777dd7ddddd7dddd7ddd
77777777777dd777dd2222ddd27777777dddd7dddd7ddddd7d7d7767677dd77ddddddddd2227222222227222222222272222222772777777d7ddddd7dddd7ddd
7777777777766777d222222dd777777777ddd7dddd7dddd77777d76767d77d7d2d2d2d2d2227222222227222222222272222222777777777d7ddddd7dddd7dd7
7766667777666677d266622d777777d7777777777777777777d7d76667d7d7d772777d2777777777777777777777777777777777777727777777777777777777
7676766776666667dd606ddd7777777777777dddd7ddd77777d7777777d7777772777727277dddd722777777227222222227222272d727d27ddd7dddd7dddd77
7666666776666667d266622dd777777777777dddd7ddd777777dddd7dd7dd7777772777727d0d0d7227777772272222222272222d2d2d2d27ddd7dddd7ddd777
7767667776666667d222222d777277777777777dd7d7777777777dd777d77777d7777777277ddd77227777772272222222272222dddddddd7ddd7dddd7777777
7766677777dddd77d222222d7777777777777777777777777777777ddd7777777777777277777777777777777777777777777777666666667777777777777777
777777777777777777777777666677dd7777777777777777777777777ddddddd7ddddddd7ddddddd7ddddddd7ddddddd77777777777777777777777777777777
777777777777777777777777676767dd777777777777777777777777dd67676ddd67676ddd67676ddd67676ddd77777dd7777777777777777777777777777777
767777777d77777772777777766677dd777777777777777777777777d6666666d6666666d6666666d6666666d7777777d7777777777dd777777dd777777dd777
67666677d7dddd77272222777777777777d777777777777777777777d7676767d7676767d7676767d7676767d7777777d777777777d77d7777d77d7777d77d77
67677677d7d77d7727277277ddd7dddd776777777777777700000000d6666666d6666666d6666666d7777777d7777777d777777777dddd7777dddd7777dddd77
767777777d77777772777777ddd7dddd7666777777777777ddddddddd7676767d7676767d7676767d7777777d7777777d777777777dddd7777d66d7777d22d77
777777777777777777777777ddd7dddd722277777777777722222222d6666666d6666666d7777777d7777777d7777777d777777777dddd7777dddd7777dddd77
77777777777777777777777777777777722277777777777700000000d7676767d7676767d7777777d7777777d7777777d7777777777777777777777777777777
66d66666066666600d0220dd022220dd0000000000dddd02002220dd2d2222d22d22d2d0ddd7dd72227dd7d7d77777777777777d002d2002700d007722dd00d2
d00dd00dd0000006000000dd000000dd00000000000000000000000022dd22d22d22d2d022dd7dd777dd7dd7d77777777777777d02d20d0270d2d007dd00200d
0dd00dddd0000006002220dd020220dd000000000dd0ddd002220dddd222d2d22d22d2d0722dd7ddddd2dd77d77777777777777d2d202d0070d02d070022d200
d0d0d0d00dddddd00022200002022000000000000dd0ddd0000000002d222d222d22d2d07222dd22dd22d777d77777777777777dd20002d000d02d0022dddddd
777777770666666000000000000000dd22002200000000000dd0222022dd2222d22d22d077222dd22222d7777777777777777777d202002d0d2002d0dd222200
77777777d000000602202220022220dd22d022d00ddddd02ddd0222222d2d222d22d22d07722227d222d777777777777777777772022202d0d2022d000222207
77777777d000000602202220022220dd22d022d00ddddd02dd00002222d22d2d222d22d077722777d2277777777777777777777722d2d20dd202d02d70222207
777777770dddddd0000000000000000000000000000000000000000022d222dd22d22d0077722777777777777777777777777777dd202d22d202d02d70222207
7777777777777777777772770222002202220222022220dd7776dd7722d222d7d2d22d77d2d22d2d22d2d22d2d22d22d222222227777700d20022002d0777777
d7d7d7d777277277777727770000000002220222000000007762dd7722d222d7d2d22d77d2d22d2d22d2d22d2d22d22d22222227777770d2002d0020d0077777
d2d2d2d27777227777277777022202200000000002202220776ddd7722d222d7d222d777d22d2d22d2d2d22d2d22d22d22222277777700d202d202d02d077777
d7d7d7d72222727772222227022202202220222002202220777dd77722d222d77d22d7770d2d2dd2d22d222d2d22d2dd2222277777770d202d202d2d2d007777
d7d7d7d7222222272222222700000000000000000000000077600dd722d222d777d2d7770d2d22d2d22d22d22d2d22d02222777777770d20d202d0022dd07777
d7d7d7d722262227222222270220ddd0220220d00220202276ddddd722d222d7777d77770d2d22d22d2d22d2d22d22d02227777777700d2020d2002002d00777
d7d7d7d772262227222622770220ddd0220220d00220202276dd00d722d222d7777777770d2dd2d22d2d22d2d22d2dd0227777777700d2020d20d20d02dd0777
d7d7d7d7722662777266227700000000000000000000000076ddd0d722d222d77777777700d2d2d22d2d22d2d2d22d0027777777770d202dd20020d2002d0777
222222220dddddd0dd7d7777dd7d2777d772d77d2d2d2222776dd0d722d22d7777d22d2d77d2d2d22d2d2d22d2d22d772000022270d20000220000d2dd02d077
222222220d0000d07d77d7772d27d277d77dd77d2d22d222776dd0d722d22d7777d22d2d77d2d2222d2d2d22d2d2dd772200002270d202220002200d0002d007
2222222270dddd077d77dd777d777d77d72d772d2d222d22776dd0d722d22d77777d2d22777d2d2d2d2d2d2d22d2d777220000020d222ddd202dd20022002d07
222222227022220777d77d7772d77d27d72d722d22d22d227776d66722d22d77777d2dd2777d2d2d2d22d22d2d22d77722200002ddddd00d22dddd22dd222d07
22222222702dd207d7d777d7d7d277d777d777ddd2d222d27776dd7722d22d77777d22d2777d2d2d22d2d22d2d2dd7772220000200000000dd2220dd00dddd07
22222222702dd207d77d77d7d77d27d222d722d7d22d22d27776dd7722d22d77777d22d27777d2d2d2d2d2d22d2d777722000002777777700022200000000007
22222222702222077d7d777ddd77d77dd7777d7d2d22d22d777ddd7722d22d77777dd2d27777d2d2d2d2d2d22d2d777720000022777777777022207777777777
222222220dddddd07d77d7777dd7d7777777d77d2d22d22d766d667722d22d777777d2d277777dd2d2d2d2d22d2d777700000222777777777022207777777777
00000000000000007777d77d7dd7dd77777d77d72222d22d2222222222d2dd777777d2d2777777d2d2d2d2d2d2d7777702222222222222222222222077d77d77
0022022000dd0dd0777dd77d772d7dd777d77dd7222dd22ddd0000dd22d2d7777777d222777777d2d2ddd2d2d2d7777700000000000000000000000077d77777
022222220ddddddd777d777d772dd77d7d77dd27222d222dddd00ddd2dd2d77777777d2d7777777d22d77d2d22d7777720000000ddddddddddd0000277777777
022222220ddddddd777d777d72272d77d277d72222d222dd222222222d22d77777777d2d7777777d2d777d2d2d7777772000ddddddddddddddddd00277777777
0022222000ddddd077d777dd22272dd72772d72222d222d2222222222d22d77777777d2d7777777d2d7777d22d777777200ddddddddddddddddddd0277777777
00022200000ddd0077d77dd72227227d772d77772d222d220dddddd0dd22d777777777d77777777d2d7777d22d77777720dddddddddddddddddddd0277777777
000020000000d0007d777d7772772227d72227772d222d22dddddddd7ddd7777777777d777777777d777777dd777777720dddddddddddddddddddd0277777777
0000000000000000d777d7777777722777722777d222d222dddddddd777777777777777777777777d77777777777777720dddddddddddddddddddd0277777777
7777777777d777777dd777777777777777777777777d777777777777777777777777777777d77d77777777777777777777777777777777777777777777777777
7777777777dd7d777dd767dd77777777777777777d7d7d77777777777777777777777777777d7dd7777777777777777777777777777777777777777777777777
77777777d77d7dd77ddd67ddd777777777777777dd7d7dd7777777ddd7777777777777777d7d77d777777777777777777777777777d77d777777777777777777
77777777d77d77d7dddd6dddd777777777777777d77d77d777777ddd77777777777777777d7d766777777777777777777777777777dd7dd77777777777777777
77777777d6666667ddd6dddd7777777777777777666666677777dddd677d7777777777777d666607777777777777777777777777d77d77d77777777777777777
7777777766202d77dd767ddd77777777777777777d202d77777dddd6d7dd77777777777776d02027777777777777777777777777dd7d66677777777777777777
77777777dd000d77dd767dd777777777777777777d000d77777d776ddddd7777777777777dd00007777777777777777777777777766660077777777777777777
777777777dddd777777677d7777777777777777777ddd77777777677ddd7777777777772222ddd777777777777777777777777777dd020277777777777777777
777777722dd22227776777777777777777777772222222227777677ddd777777777772222222dd777777777777777777777777777dd000077777777777777777
7777772dd22ddddd776777777777777777777722ddddddddd7d677ddd777777777772222ddd2227777777777777777777777722222dddd777777777777777777
7777772dd0d666ddd6d77777777777777777722dd666666ddd6d7777777777777777222ddd66d2777777777777dddd7777722222d222dd777777777777777777
7777722ddd6666d0d6d7777777777777777772dd0666666d06d77777777777777772222ddd666dd7777777777dddddd77722222dddd222777777777777777777
77777222ddd666d06d77777777777777777722ddd6666660ddd777777777777777222220ddd666dd77777777ddddd7777722222ddd6622777777777777777777
777722220ddd66d767777777777777777777222ddd666606dd777777777777777722222d0ddd66ddd7777777d7ddd6677222222ddd666dd77777777777777777
77772222d0dddd0767777777777777777777222dddd660607777777777777777722222ddd0ddd07ddd77777777666777222222dddd6666d77777777777777777
777722226d00dddd7777777777777777777222220dddd607777777777777777722222266dd0ddd77ddd77776667ddd7d272222d0ddd66dd77777777777777777
77772222d66660dd777777777777777777722222d0ddd0777777777777777777272222dd66d0ddd77ddd6667777ddddd72222ddd0ddd0ddd7777777777777777
777222220dddd777777777777777777777722222666666777777777777777777722222ddd0660dd666dd77777dddddd772722666d0ddd0ddd777777777ddddd7
7772222dddddd777777777777777777777722222dddddd777777777777777777727222ddddddd7777777777777ddd77777727ddd660ddd7ddd7777777ddddddd
7772222666ddd777777777777777777777222222dddddd7777777777777777777772777ddd7dd777777777777777777777777dddd0d0ddd7dddd7777777ddd77
7722222677dd777777777777777777777722222ddd77ddd777777777777777777777777d677d67777777777777777777777777dddd000dd666dd666666666667
7722222277d6777777777777777777777727272d6777dd6777777777777777777777777d677d677777777777777777777777777dd60dd67777777777777ddd77
7727272777d6777777777777777777777777777d67777d677777777777777777777777d667d667777777777777777777777777dd60dd6777777777777ddddddd
7777777777d6677777777777777777777777777d66777d667777777777777777777777d666d66677777777777777777777777dd666d666777777777777ddddd7
777d77777777ddd6777777776d2277772777ddd6777277777777777766666666dddddddddddddddd6666666677772dd666666666666666666d27777777777777
7d7d7d777d7772dd772777776d227d77777772d6777777777777d7776dd6ddd6d0000d0dd0d0000dddddddd677d772dd6dddddddddddddddd277727777677777
dd7d7dd777777722777777776dd7777777772dd6777777777777777766666666dddddddddddddddd2d272dd6777777226dd2d2d2d2d2d2d22777777777677767
d77d77d727777777727777776d227777277772d67777dd77777777776dddd6d6d00d000dd000d00d777d72d6777777276d2d777d77277772777d777777677767
6666666777777727227777776d7777777777ddd67777dd77777777776dddd6d6d00d000ddddddddd72777dd67777d7776dd772777d777d772777777777677767
7d000d7777777777dd27777d6dd77777777d22d6777777777777777766666666ddddddddd00d000dd2d2d2d6777777226d2d2dd22d2d2d27d277772777667767
7d000d7777777777ddd277776d2277727d77ddd677777777727777776dd6ddd6d000d00dd00d000dddddddd6727772dd6ddddddddddddddddd27777776667667
77ddd777772777776dd277776ddd2777777772d677777777777777776dd6ddd6d000d00ddddddddd66666666777772d666666666666666666d27777766666666
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010101010100000101010000010100010000000000000000020000000000000100000000010000020201000000000002000100010101010000000000
0101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000010000010001010000
__map__
a59aaa9a87a5a0a5b5a5aab5a5a59aa5b5aaa0a0a0a0a0a0a59a9ab5b5b5a0a0a0a0a5b5b59ab5a5a0a0aab5a0a0a0a0a0a0a0a0a0a09c00008484848484848484848400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075
a5aa9a87a0a5a0a0b5b587b5a59aa59a879aa0a0aca0a0a0a5aa87b59aa0a0a0a0a087a09aaa87b5a5b59ab5a0a0a0a0a0a0a0a0a09c0000009594959394959495858200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075
a5a5a5a5a0b5a5b5b587b587a5aaaaaaa5a5a0a0a0a0a0a0a09aa5879aa0a0a0a0a0a5a5aaaab587b5b5aaa0a0a0a0a0a0a0a0a09c000000849300939300939482939400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075
a2b2a2a2a2a4b2a2a3b2b2a3b2a2b3b4b2bf8b00000000008ca28db34e0000000000b2a2b2a3a4b3b44ea20000000000000000000000000093949386959593859495835a5a585a5a5a585a585a5858585a5b58585a58585a585a5b5a585a5a585a6c585a5a5a585a5a5a5a5a585a5a5a5a5a585a585a5a585a58585858585841
a2b2a2a34e008bb2a2b2a2a400bf0000000000000000000000bf4e0000000000000000bf8bbf8c000000bf0000000000000000000000000095008200930095949595835a5b5b5a58585b5a585b5a58595a5b58585a585a585a58585a59585b5b5b585a5b5b5b5b5b5b5b5b5b5b5b5b5b5b6a585b585b58585a5a4f4f5b5b5af3
bfa4a2bf00000000b3b4a44e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000095948300958593949594835a5b69585a58586a4f5b585b5b5a5a5a585a5b5a58585b5a585a5b5b5b5b5b5b5b5b5b5b5b6c5c5b695b5b58585b5b5b5b5b5b5a4f005b5b5b585b5bf3
750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000095008300000000000000005a5b5b585a5b5b5a585b585b6a5a5b5a5a5a4f5a5a58585a6a58585b58585b5b4f5b5b5b5b5a5b585b58585b5b6c6c5b586a4f5a6c6b5b5b5b585b5b48
758e000000009600000000008e00000000008e00000000000000009600000000008e00008e0000000000000000008e00000000009600000095948200000000000000005a5b6a4f5a585b58585b5b5b6b6c5c6b6c6b6c5c5a5b5a5a5b5a5b585b58585b5b5b585b585b585b585b585b585858585b585b585b5b5b586a4f585b48
759e9f000000a6000000919d8d9f0000009d8d9f91000000008e00a6000000009d9e9f9d9e9f0000008e0000009d8d9f00000000a6000000939585000000000000000058585b58585b6a5b5b585b5b5a58585b585b41684542585a4142585841425b5b4145425b585b5b5a5b58585b5b5b5b5b585b5b5b5b5b585b5858585bf3
75aeaf000000b68e9090a1ad8faf000000adaeafa19090908c8f8bb6909090a1adaeafad8faf90908c8f8ba190adaeaf8e8cb6b6b6b6b68bbcbdbe00000000000000005a5b5b5858585b5b5b58585a5a6a4f5b585af3f64946000048f40000f3f40000484a460000414258585b5a5b585a5b5858585b585b5b5b5b5b5b585848
818181810081808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080806b6c585b6b5c6b5c41425b5a5b58585b5b5848490052454563f1684553f145685300f1684553465a5a41425a5a5a5a5a5a5a41425a5a5a41425a5a5af3
810000000081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000484600000000000000004800f600490000f600000049000000f60000000052684563f145456845456868635268684553f145456863
8100000000810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040400000004852454545420000414563f54af6004a0000004af50049004900004900f64b476d474747474747476d6d476d6d6d476d6d6d476d4c
818181818181000000000000000000000000000000000000000000000000000000000000000000404000000000000000004040400000000000000000000000000000000000000000000000484d47474743000044f24d6d4747476d474747476d6d6d6d6d6d6d6d6df246000000000000000000000000000000000000000000f3
750000000000000000000000000000000000000000000000004040400000000000404000000000000000000040400000000000000000000000404000000000404000000000000040400000484600000000000000484600000000000000000000000000000000000048460000000000000000005d5e6e5e5f0000000000000048
818181818181810000000000000000000000005455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000484600414568456845534600000000000000000000000000000000000048f14200005657000000005e005e005e000000565700fcfe
81a0a0a0a0a081000000000000000000000000646f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040000000484600484b6d4747474c52684542000000416845456845454200000000484d430000666700000000646e6e6e6f0000006667000048
81a0a0a0a0a081000000000000000000545e5500005d5e5f00000000000000000000000000000000000000000000546e5500000000545e5500000000000000000000000000000000000000444300444300000000446d476d4300000044476d4747476d6d430000416346000000000000000000005e6e6e0000000000000000f3
81a0a0a0a0a0810000007b7c00000000646e6f0000645e6500000000000000000000000000004142000041420000645e6500000000646e6f0000414200004142000000000000004040000000000000000000000000000000000000000000000000000000000000444c5245420000000000000000645e6f00000000fcfdfdfdfe
81a0b6b6b6a0777c00f7f8f70000000000a100000000a100000000000000000000000000004163f400004852420000a1000000000000a10000415346000048524200000000000000000000000000000000000000000000000000000000000000000000000000000044476d4300000000005d5f00000000005d5f0000000000f3
45684568456845454542f84145684545684200000041456845420000416845454542400041534af14568534a5268454568456845684545456853495245685349f16845454200404041454568684545684200004168454568454545456845684545456845684200000000000000000000006e735e6e5e5e6e5e6e000000000048
75f6000000f5004949f4f8484a004a494a524545455347474cf400004847476d4c460040f300f60000004d6d6d47476d476d476d6d476d6d6d6d47476d6d6d474c4af500524200004447f24a004900f5526845634a49f64d6d6d6d6d6d476d6d476d6d47f2460000000000000000000000646f0000000000646f0041420000f3
7500004900004a00f5f4f8484b4747474747474747430000000040400000000044434000480000000000f4878800000000000000000000000000005b5a5a5b0044f200494a460000009648004a004af6004a000049000046000000000000000000000000485245684568454568454568454545684545456868454553fbfa0048
75004b6d6d6d6d476d43f848f4000000000000000000004175757575f4000000777c0040480000000000f4979800000000000000000000000000005a5b5b5b5a69444cf54af4000000a6f3000049000075f64a00000049f4000000000000000000000000484949f6494b474747476d6d476d47476d476d476d6d476d43000048
75494600000000000000f84846000000000000000000004849000000526868454545454553000000000046970000000000000000000000000000004145424f5a5b00444c4af1454545454d476d476d4747476d476d474cf4000000000041420000000000004d476d6d43000000000000000000000000000000000000000000f3
4975f400000000000000f8f3f400000041420000000000f34a0049004900000000000000000000000000f49700000000000000000000000000000048f5f1425a5b5b5b444c004a004a49468788999a9a9a9ba9ab999af35242000000444c4d430000004153460000000000000000000000000000414545420000000000004163
754a46000000a1004142f9f346000000485245454545455349f5004900490000000000000000000000004697000000000000000000000000000000f34af652425b6a5800444c00007575f49798a9aaaaaaabb9bba9aaf34af142000000f346000000415349460041420000000000fcfdfa000000444cf6f14200000000415349
4a75f4000041454563f16853f14200004447474747474747474747474c7575757575757575000000000046a700000000000000000000000000000048000049f1425b5b5b5a444c00f67546a700b9baaababb0000b9aa48f6005242000048f400004153f600f4004443000000000000000000000000446d474300000041634a00
4a750000004447474747474747430000000000000000000000000000f34900000000000075000000000046b700000000000000000000000000000048004a000052425b5b5b004849750077a7000000980000000000a8f34b476d430000f346000044476d6d430000000000000000000000000000000000000000004163494a00
757546000000000000000000000000000000000000000000000000000000000000000000750000000000f400000000000000000000000000000000f3f60000490052424f5b5a44476d4743b7000000000000000000b84443000000000048f40000000000000000000000000000000000000000000000000000004153004a004a
4a75f400000000000000000000000041420041420041454542000000004a49000000000075000000000046000000000000000000000000000000004849004a000049f1425a5a777c777c777c8cb68b00000000000000777c0000000041535242000000000000000041420000000041684200000041420000414553f6004a004a
75495245456845454545684545454553f14553524563494a52454545537575757575757575000000004a52684545454568454545456845454568685375757575757575f14545454568454545454545686845456845684545684568455349f552456845454568684553524568454553755245456853526845534af5494a494900
__sfx__
01060000250112b001330013d00100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
011000000063500400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000106141a005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001042028211282100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001802318003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002855330623186150c61530300347032870324703297032b703306053070530704307033050230402305033b5033950329503245032850328503346073450734407344073430734207341073010632106
01100000185471a504000000000000000000000000024701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012c00000c52418524245243052400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600002d7353972523104232042330423404235042350428204285022450215502215022d502211032100321002214062110221206212022130221402215022160221702214052150421604217042140421304
011000000064300636000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000182360c4320943007431054320043300433182060c40209400074010540200403002030c2030c2030c2020c2010c2030c2060c2070020700203002060020500206242030c20300203000000000000000
01060000182360c4420944007441054420043300433004330c4330c4330c4330c4330c4330c4330c4330c4330c4330c4330c4330c4330c4330c4230c4230c6550020500206242030c20300203000000000000000
010c00000f220002250030428103101031c103281032810524005180050c0051000510105102050c2050020500000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001042018211182100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000265021a501265021a501265022650226502295022950200000000000000000000000000000024502265021a501265021a501265022650226502245022450200000000000000000000000000000024502
0110000011023110030c0000010311023306001850500023110230020511003002051102300000185050002311023002051100300205110230000018505000231102300205110030020511023110033561500003
010400000721605212042120321603212022120221200212002220022200226002220022600222002260022300226002230022600223002220022600222002220021200212002120021200210002100021000215
0104000011023110030c0000010311023306001850500000110230020511003002051102300000185050010311023002051100300205110230000018505000001102300205110030020511023110033560535605
010400000041300403004130040300412004030041300403004130040300413004030042300403004230040300423004030042300403004230040300423006250020500423242030042300203004230000000423
010400001873524735247352473516735227352273522735187352473524735247351673522735227352273518735247352473524735167352273522735227350703007030060300603005030050300403004030
0110000011023110030c0000010311023306001850500023110230020511003000231102300000185050002311023002051100300205110230000018505000231102300205110030002311023110033561535615
0110000028151000001c151241511c1511c15130151301511c1511c1511c1511c1510000000000261512815124151000000000029151291510000000000291510000029151241512615100000261510000026151
0110000000130001250013000125110030000005003000000013000125001300012523712247122471200000001300012500130001250a100000000c100000000712007115050030512005115000000312003115
011000000313003125031300312511003000000500300000031300312503130031251a7121b7121b71200000031300312503130031250a100000000c100000000313003125031300312507030060300503004030
011000000321503215032250323535615306010352500000032150321503225032353561500000035250010303215032150322503235356150000003525000000321503215032250323535615000000352500103
0110000003130031250313003125110030f0000f00000000031300312503130031251e7121f7121f71200000031300312503130031250a100000000c100000000313003125001000513005125030000313003125
0110000000130001250013000125110030f0000f00000000001300012500130001251f712217122171200000001300012500130001250a100000000c100000000713007125001000513005125030000313003125
0110000011023050030c0000020511023306001100300023110230020511003002051102300000185050002311023002051100300205110230000011003000231102300205110030020511023110031850500023
011000000021500215002250023535615306010052500000002150021500225002353561500000005250010300215002150022500235356150000000525000000021500215002250023535615000000052500103
0110000000130001250013000125110030000005003000000013000125001300012523712247122471200000001300012500130001250a100000000c100000000013000125001300012505030030300203001030
011000000c1200c1150c1200c1150a1200a11507120071150f1200f115000000e1200e115000000a1200a1150c1200c11507120071150a1200a1150c1200c1150712007115000000512005115000000312003115
01100000110231821518215182253561530601185150000011023242152421524225356150000018515000131102300215002150022535615000001851500000110230c2150c2150c22535615000001851500103
011000002421518215182151820500000182151b2151d2151f2151d2151b2151f2051e2151f2150000018215000001f2150000018215000001e2151f21520215182151f215202152221518215222152321518215
01100000212152d3151521513215152152131515215132151c2151a2051a215182151c2051a2151c215000001c215000001a21518215000001a2151c215000001f215000001c2151f215000001f2152121500000
011000001102321215212151f22535615056151551500013110232d2152d2152d2253561500000155150010311023092153561509225356153561515515000131102315215152151522535615000001551500103
0110000009120091150412004115071200711509120091150c1200c115000000b1200b11500000071200711509120091150412004115071200711509120091150412004115031200412004115071200912009115
0110000009130001000413000000071300000009130000000c13000000000000b1300210000000071300000009130000000413000000071300000009130000000413002205031300413004100071300913000000
01100000110231821518225182353561530601185150000011023242152422524235356150000018515001231102300215002250023535615000001851500000110230c2150c2250c23535615000001851500103
01100000110231821518225182353562530601185150000011023242152422524235356250000018515001231102300215002250023535625000001851500000110230c2150c2250c23535625000001851500103
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c0420704204042000421102324320283201102318040005401a040025401b040035401d040055401f040075401d040055401b04003540230400b5402404000540174040050035615356053561511023
011800001d1141d1101d1101d115111141111011110111151a1141a1101a1101a1150e1041d1141d1101d115181141811018110181150c1140c1100c1100c115181050000000000000000c1140c1100c1100c115
01180000110130040300403004031101300403004030000011013000000040300000110130000000000000001101300000004030000011013000000000000000110130000000403000001101300000000001c105
0118000011014110101101500000050140501005015000000e0140e0100e01500000020140201002015110050c0140c0100c01500000000140001000015000000c0140c0100c0150000000014000101001410015
011800001d725000001c725000001d725000001f7250000021725000001f725000001d7250000021725000001f7250000021705000001d725000001d7051d7051f7251f705000000000024725000002470500000
0118000029215292041d2151a2051a2151d2051d215294052d2152920521215000001d2151120521215000002b215000001f215000001c215000001f215000003021518205242151020521215111052421511305
011000000512005115001200011503120031150512005115081200811500000071200711500000031200311508120081150312003115051200511508120081150a1200a115081000812008115071000312003115
011000000212002115021200211502120021150212002115041200411504120041150412004115041200411505120051150512005115051200511505120051150712007115071200711508120081150812008115
01100000110231a2151a2151a22535615056050e515000131102328215282152822535615000001051535615110231d2151d2151d22535615356051151500013110231f2151f2151f22535615000001451535615
01100000110231a2151a2151a22535615056150e515110131102328215282152822535615000001051500103110231d2151d2151d22535615356151151511013110231f2151f2151f22535615000001051500103
011000000212002115021200211502120021150212002115041200411504120041150412004115041200411505120051150512005115051200511505120051150712007115071200711505120051150412004115
011000002421518215182151820500000182151b2151d2151f2151d2151b2151f2051e2151f2150000018215000001f2150000018215000001e2151f21520215182151f215202152221518215222152321518215
01100000212151531509215132151521521315152151321523215173150b215152151721523315172151521524215183150c2152321518215243151821523215262151a3150e2151821518215243151721517215
01100000212151531509215132151521521315152151321523215173150b215152151721523315172151521524215183150c2152321518215243151821523215262151a3150e21518215272151b3150f2151a215
01100000041200411504120041150412004115041200411505120051150512005115051200511505120051150712007115071200711507120071150712007115091200911509120091150b1200b1150b1200b115
011000001102304215042150422535615056151051500013110230521505215052253561500000115150010311023072150721507225356153561513515000131102309215092150922535615000001751500103
011000002421518215182151820500000182151b2151d2151f2151d2151b2151f2051e2151f2150000018215000001f2150000018215000001e2151f21520215182151f215202152221518215222152321518215
0110000023215173150b215152151721523315172151521524215183150c2152321518215243151821523215262151a3150e215182151a2151a3151a21518215282151c315102151a215262151a3150e21518215
0110000023215173150b215152151721523315172151521524215183150c2152321518215243151821523215262151a3150e215182151a2151a3151a21518215282151c315102151a215292151d315112151c315
011000000412004115041200411504120041150412004115051200511505120051150512005115051200511507120071150712007115071200711507120071150912009115091200911507120071150512005115
01100000110231821518215182253561500000185150000011023242152421524225356150000018515000131102300215002150022535615356151851500000110230c2150c2150c22535615000001851500013
011000001102321215212151f22535615056051551500013110232d2152d2152d2253561500000155150010311023092150921509225356153560515515000131102315215152151522535615000001551535615
01100000110231a2151a2151a22535615056150e515000131102328215282152822535615000001051500103110231d2151d2151d22535615356151151500013110231f2151f2151f22535615000001451500103
011000001102304215042150422535615356151051511013110230521505215052253561500000115150010311023072150721507225356153560513515110131102309215092150922535615000001751535615
__music__
01 28 42 43 44
01 1e 1f 43 44
00 1e 3c 43 44
01 1e 1f 20 44
00 1e 3c 20 44
00 23 3d 21 44
00 23 22 21 44
00 1e 3c 20 44
00 1e 1f 20 44
00 3b 37 39 44
00 36 3f 3a 44
00 1e 1f 20 44
00 1e 1f 20 44
00 23 3d 21 44
00 23 22 21 44
00 32 3e 34 44
00 2f 30 35 44
00 23 22 21 44
00 23 22 21 44
00 32 30 34 44
00 2f 3e 35 44
00 1e 1f 20 44
00 1e 3c 20 44
00 23 22 21 44
00 23 3d 21 44
00 32 30 34 44
00 2f 30 35 44
00 3b 3f 39 44
02 36 37 39 44
00 0e 42 43 44
01 29 42 2b 44
00 29 42 2b 44
00 29 2c 2b 44
00 29 2c 2b 44
00 29 2c 2b 2d
00 29 2c 2b 2d
00 29 42 2b 2d
02 29 42 2b 2d
03 41 42 43 44
00 13 11 10 44
01 16 1c 1b 44
00 19 18 1b 44
00 16 1c 0f 44
02 17 18 14 44
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
