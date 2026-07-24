pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--the lost beans
--by @dollarone
--made for the 2018 coffee jam
--https://itch.io/jam/coffee-jam
--code based on
--advanced micro platformer
--by @matthughson
--https://www.lexaloffle.com/bbs/?tid=28793

function update_state()
	if (state==1) then
	-- single espresso
		p1.max_dx=1--1,--max x speed
		p1.max_dy=2--max y speed
		p1.double_jump=false
		p1.jump_speed=-1.2---1.75,--jump veloclity
		p1.acc=0.05--acceleration
		p1.dcc=0.8--decceleration
		p1.air_dcc=0.7--1,--air decceleration
		p1.grav=0.15	

	elseif (state==2) then
		-- double espresso
		p1.max_dx=1.5--max x speed
		p1.max_dy=2.5--max y speed
		p1.double_jump=false
		p1.jump_speed=-1.5---1.75,--jump veloclity
		p1.acc=0.2--acceleration
		p1.dcc=0.8--decceleration
		p1.air_dcc=0.7--1,--air decceleration
		p1.grav=0.15
	elseif (state==3) then
		-- mocha
		p1.max_dx=1--1,--max x speed
		p1.max_dy=5--max y speed
		p1.double_jump=false
		p1.jump_speed=-3---1.75,--jump veloclity
		p1.acc=0.05--acceleration
		p1.dcc=0.8--decceleration
		p1.air_dcc=0.7--1,--air decceleration
		p1.grav=0.15
	elseif (state==4) then
		--americano
		p1.max_dx=1--1,--max x speed
		p1.max_dy=2--max y speed
		p1.double_jump=true
		p1.jump_speed=-1.2---1.75,--jump veloclity
		p1.acc=0.05--acceleration
		p1.dcc=0.8--decceleration
		p1.air_dcc=0.7--1,--air decceleration
		p1.grav=0.15		

	else
		p1.max_dx=1--max x speed
		p1.max_dy=2--max y speed
		p1.double_jump=false
		p1.jump_speed=-1.2---1.75,--jump veloclity
		p1.acc=0.05--acceleration
		p1.dcc=0.8--decceleration
		p1.air_dcc=0.7--1,--air decceleration
		p1.grav=0.03
	end	
	if (statechangecountdown==0) then
		if (state==2) then
			cam:shake(15,1)
		else
			cam:shake(15,4)
		end
	end

	statechangecountdown=100
end
    
--sfx
snd=
{
	jump=0,
}

--music tracks
mus=
{

}

--math
--------------------------------

--point to box intersection.
function intersects_point_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<=flr(x+w) and
				flr(py)>=flr(y) and flr(py)<=flr(y+h) then
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

	if(self.base_frame==-1) then
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
		elseif pget(flr(self.x+offset-cam.pos.x+64),flr(self.y+i-cam.pos.y+64))==2 then
			self.dx=-0.5
			self.x=(flr(((self.x+(offset))/8))*8)-(offset)
			return true
		end
	--elseif self.dx<0 then
		if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
			return true
		elseif pget(flr(self.x-offset-cam.pos.x+64),flr(self.y+i-cam.pos.y+64))==2 then
			self.dx=0.5
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
		elseif pget(flr(self.x+i-cam.pos.x+64),flr(self.y+(self.h/2))-cam.pos.y+64)==2 then
			self.dy=-0.5
			self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h)
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
		if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) or
			pget(flr(self.x+i-cam.pos.x+64),flr(self.y-(self.h/2)-cam.pos.y+64))==2 then
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
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=8,
		h=8,

		max_dx=1,--1,--max x speed
		max_dy=2,--max y speed
		double_jump=false,
		jump_speed=-1.2,---1.75,--jump veloclity
		acc=0.05,--acceleration
		dcc=0.8,--decceleration
		air_dcc=0.7,--1,--air decceleration
		grav=0.15, --0.15
		
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
		double_jump=false,
		double_jump_available=false,

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
			["idle"]=
			{
				ticks=5,
				frames={48,49,2,50,51,52},
			}
		},

		curanim="walk",--currently playing animation
		curframe=1,--curent frame of animation.
		animtick=0,--ticks until next frame should show.
		flipx=false,--show sprite be flipped.
		idletime=0,
		
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
			if(winnar)return
			tile=mget(self.x/8,self.y/8)
			if fget(tile,2) then
				mset(self.x/8,self.y/8,0)
				beans+=1
				beanschangecountdown=100
				sfx(8)
				if (beans==maxbeans) then
					winnar=true
					besttime=dget(0) -- get number at index
					yourtime=time
					if(yourtime<besttime) then
						dset(0, yourtime) -- set number at index to value
						sfx(4)
					else
						sfx(5)
					end
				else
					sfx(8)
				end
			end
			if fget(tile,3) then
				mset(self.x/8,self.y/8,0)
				special_bean=true
				beanschangecountdown=100
				sfx(20)
			end
			
			--track button presses
			local bl=btn(0) --left
			local br=btn(1) --right
			
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
				if (on_ground and self.double_jump)self.double_jump_available=true
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
				elseif (new_jump_btn and self.double_jump and self.double_jump_available) then
					self.double_jump_available=false
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
			
			if(has_moved==false and (self.jump_button.is_down or br or bl)) then
				has_moved=true
			end
			--move in y
			self.dy+=self.grav
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			self.y+=self.dy

			--floor
			if not collide_floor(self) then
				self.idletime=0
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
					self.idletime=0
					if self.dx<0 then
						--pressing right but still moving left.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				elseif bl then
					self.idletime=0
					if self.dx>0 then
						--pressing left but still moving right.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				else
					if (self.idletime==0) then
						self:set_anim("stand")
						self.idletime=1
					end
				end
			end

			if (self.idletime==500)self:set_anim("idle")
			if (self.idletime>0)self.idletime+=1


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

		end,

		--draw the player
		draw=function(self)
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			if (state==1) then
				pal(11,6)
				pal(3,6)
				pal(2,0)
			elseif (state==2) then
				pal(11,6)
				pal(3,0)
				pal(2,0)
			elseif (state==3) then
				pal(11,4)
				pal(3,4)
				pal(2,4)
			elseif (state==4) then
				pal(11,0)
				pal(3,0)
				pal(2,0)
			elseif (state==5) then
				pal(11,15)
				pal(3,15)
				pal(2,15)
			end
			--pset(flr(self.x),flr(self.y+(self.h/2)),14)
			spr(frame,
				self.x-(self.w/2),
				self.y-(self.h/2),
				self.w/8,self.h/8,
				self.flipx,
				false)
			pal(3,3)
			pal(11,11)
			pal(2,2)
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
		pos_max=m_vec(960,448),
		
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

--game flow
--------------------------------

--reset the game to its initial
--state. use this instead of
--_init()
function reset()
	time=0
	beans=0
	maxbeans=25
	special_bean=false
	ticks=1
	col=0
	introtimer=500
	has_moved=false
	winnar=false
	mvp=true
--	p1=m_player(58,86)
--	p1=m_player(58,486)
--	p1=m_player(908,486)
--	p1=m_player(908,256)
	p1=m_player(504,68)
	p1:set_anim("walk")
	cam=m_cam(p1)
	palt(14,true)
	palt(0,false)
	state=1
	states={}
	add(states,"espresso")
	add(states,"double espresso")
	add(states,"mocha")
	add(states,"americano")
	add(states,"cafe latte")
	debug=false
	statechangecountdown=0
	beanschangecountdown=0
	angle=0
	dark=false
	outer_circle_open=false
	mid_circle_open=false
	inner_circle_open=true

	pieces={}
	make_escalator(864,340,130,8)
	make_escalator(850,389,84,8)
	make_escalator(784,390,100,8)
	fountains={}
	add(fountains,make_fountain(100,496,440,4))
	buttons={}
	butt1=make_button(88,496)
	butt1:add_wall(72,488,79,503)
	add(buttons,butt1)
	butt2=make_button(112,496)
	butt2:add_wall(128,488,135,503)
	butt2.enabled=true
 
	add(buttons,butt2)
	butt3=make_button(36,416)
	butt3:add_wall(184,480,199,487)
	add(buttons,butt3)
	butt4=make_button(164,416)
	butt4:add_wall(72,424,79,455)
	butt4:add_wall(56,424,71,431)
	add(buttons,butt4)

	butt5=make_button(60,448)
	add(buttons,butt5)
	butt5:add_wall(128,424,135,455)
	butt5:add_wall(136,424,151,431)

	butt6=make_button(140,448)
	add(buttons,butt6)
	butt6:add_wall(96,488,111,503)

	butt1.opposite=butt5
	butt5.opposite=butt1

	butt4.opposite=butt2
	butt2.opposite=butt4

	butt7=make_button(962,496)
	add(buttons,butt7)
	butt7:add_wall(920,488,928,503)

	butt8=make_button(910,496)
	add(buttons,butt8)
	butt8:add_wall(944,488,952,503)

	butt9=make_button(870,248)
	add(buttons,butt9)
	butt9:add_wall(840,240,847,255)

	add(fountains,make_fountain(908,248,208,2))
	add(fountains,make_fountain(932,496,488,5))

	drip_sources={}
	drops={}


	triggers={}
	add(triggers,make_trigger(792,300,false,enable_dark))
	add(triggers,make_trigger(784,300,false,disable_dark))

	add(triggers,make_trigger(91,290,true,open_outer_circle))
	add(triggers,make_trigger(91,110,true,open_mid_circle))
-- not needed	add(triggers,make_trigger(91,230,true,open_inner_circle))
	add(fountains,make_fountain(91, 181,145,3))

	col=3
end

function make_button(x,y)
	local b=
	{
		x=x,
		y=y,
		enabled=false,
		opposite=null,
		walls = {},

		update=function(self)
			if (intersects_point_box(p1.x, p1.y, self.x+1,self.y+2, 6,6)) then
				if (self.enabled==false)sfx(19)
				self:enable(true)
				if (self.opposite!=null) then
					self.opposite:enable(false)
				end
			end
		end,
		add_wall=function(self, wall_x0, wall_y0, wall_x1, wall_y1) 
			wall = {}
			wall["x0"] = wall_x0
			wall["y0"] = wall_y0
			wall["x1"] = wall_x1
			wall["y1"] = wall_y1
			add(self.walls,wall)
		end,
		enable=function(self, bool) 
			self.enabled=bool
		end,	
		draw=function(self)
			if (self.enabled) then
				spr(25,self.x,self.y)
			else
				spr(24,self.x,self.y)
				for i=1,#self.walls do
 					rectfill(self.walls[i]["x0"],self.walls[i]["y0"],self.walls[i]["x1"],self.walls[i]["y1"],2)
 				end
			end
		end
	}
	return b
end

function make_fountain(x,y,y_drip,id)
	local v=
	{
		x=x,
		y=y,
		id=id,
		enabled=false,

		update=function(self)
			if (intersects_point_box(p1.x, p1.y, self.x,self.y, 8,8)) then
				self.enabled=true
				old_state=state
				state=self.id
				update_state()
				if (old_state!=state)sfx(9)
				mvp=false

			end
		end,

		draw=function(self)
			if (self.enabled) then
				colo=0
				if (self.id==3)colo=4
				if (self.id==5)colo=15
				pal(4,colo)
				spr(14,self.x,self.y)
				pal(4,4)
			else
				spr(13,self.x,self.y)
			end
		end
	}
	return v
end

function enable_dark()
	dark=true
	-- todo comment
end
function disable_dark()
	dark=false
end
function open_outer_circle()
	outer_circle_open=true
end
function open_mid_circle()
	mid_circle_open=true
end
function open_inner_circle()
	inner_circle_open=true
end


function make_trigger(x,y,visible,callback)
	local t=
	{
		x=x,
		y=y,
		callback=callback,
		enabled=false,
		visible=visible,

		update=function(self)
			if (intersects_point_box(p1.x, p1.y, self.x,self.y, 8,8)) then
				if (self.enabled==false and self.visible)sfx(19)
				self.callback()
				self.enabled=true
			end
		end,

		draw=function(self)
			if (self.enabled) then
				spr(27,self.x,self.y)
			else
				spr(26,self.x,self.y)
			end
		end
	}
	return t
end

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

--make the player
function m_piece(orgx,orgy,x,y,len,orgheight)

	local p=
	{
		x=x,
		y=y,
		orgx=orgx,
		orgy=orgy,
		len=len,
		height=1,
		orgheight=orgheight,
		dir=1,

		update=function(self)
			if self.x==self.orgx or self.x==(self.orgx+self.len) then
				if self.height==self.orgheight and self.dir==1 then
					self.dir=-1
					self.x+=self.dir
				elseif self.height<self.orgheight and self.dir==1 then
					self.y+=self.dir
					self.height+=1
				elseif self.height==0 and self.dir==-1 then
					self.dir=1
					self.x+=self.dir
				elseif self.height>0 and self.dir==-1 then
					self.y+=self.dir
					self.height-=1
				else
--					self.x+=self.dir
				end
			elseif self.x<self.orgx then
				self.dir=1
			else
				self.x+=self.dir
				self.y+=self.dir
			end				
		end,

		draw=function(self)	
			spr(10,self.x,self.y)
		end,
	}

	return p
end
function make_escalator(x0,y0,len,height)
	
	for i=0,len*2.5,4 do
		piece = m_piece(x0,y0,x0+4,y0+4,len,height)
		add(pieces,piece)
		for j=0,i do
			piece:update()
		end
	end	
end
--p8 functions
--------------------------------

function _init()
	cartdata("dollarone_the_lost_beans")
	intro_init()
	mainscreen=true
	_init_mainscreen()
	reset()
end

function _update60()
	if (intro) then
		intro_update() 
		return
	end
	if (mainscreen) then
		_update60_mainscreen()
		return
	end
	if (has_moved and winnar==false)ticks+=1
	p1:update()
	cam:update()

	if ticks%60==0 then
		time+=1
	end

	if ticks%4==0 then
		for i=1,#pieces do
			pieces[i]:update()
		end
	end
	for i=1,#fountains do
		fountains[i]:update()
	end
	for i=1,#buttons do
		buttons[i]:update()
	end
	for i=1,#triggers do
		triggers[i]:update()
	end
	
	if (statechangecountdown>0) statechangecountdown-=1
	if (beanschangecountdown>0) beanschangecountdown-=1
	if (introtimer>0) introtimer-=1
	angle+=0.002

end

function _draw()
	if (intro) then
		intro_draw()
		return
	end
	if (mainscreen) then
		_draw_mainscreen()
		return
	end
	if(winnar) then
		cls(3)
		for x=0,128 do
			for y=1,110 do
				pset(x,y+7,convertfromhex(sub(image,x+y*128, x+y*128)))
			end
		end

		printc("thank you!",64,28,7,0,0)
		printc("that was amazing!",64,36,7,0,0)
		printc("you found all the beans in",64,44,7,0,0)
		printc("" .. time .. " seonds!",64,52,7,0,0)
		if (yourtime<besttime)printc("it's a record!",64,60,9,0,0)
		if (special_bean)printc("and you found the special bean!",64,68,7,0,0)
		if (mvp)printc("without upgrades! impressive!",64,76,6,0,0)
		printc("made by dollarone",64,84,7,0,0)
		printc("for the 2018 coffee jam",64,92,7,0,0)
		printc("thanks for playing!",64,108,7,0,0)
		return
	end


	cls(col)
	if(dark) then
		cls(0)
		clip(flr(p1.x-cam.pos.x+32),flr(p1.y-cam.pos.y+32),64,64)
		rectfill(flr(p1.x-cam.pos.x),flr(p1.y-cam.pos.y+32)+64,
			flr(p1.x-cam.pos.x),flr(p1.y-cam.pos.y+32)+64,col)
		rectfill(0,0,128,128,col)
	end


	circ(160-cam.pos.x, 250-cam.pos.y, 30, 2) 
	circ(160-cam.pos.x, 250-cam.pos.y, 29, 2) 
	circ(160-cam.pos.x, 250-cam.pos.y, 28, 2) 
	if(inner_circle_open)circfill(160-cam.pos.x-(sin(angle)*25), 250-cam.pos.y-(cos(angle)*25), 20, col) 
	line(160-cam.pos.x-(sin(angle+0.12)*28), 250-cam.pos.y-(cos(angle+0.12)*28), 160-cam.pos.x-(sin(angle-0.01)*40), 250-cam.pos.y-(cos(angle-0.01)*40), 2)
	line(160-cam.pos.x-(sin(angle+0.12)*29), 250-cam.pos.y-(cos(angle+0.12)*29), 160-cam.pos.x-(sin(angle-0.01)*41), 250-cam.pos.y-(cos(angle-0.01)*41), 2)
	line(160-cam.pos.x-(sin(angle+0.12)*30), 250-cam.pos.y-(cos(angle+0.12)*30), 160-cam.pos.x-(sin(angle-0.01)*42), 250-cam.pos.y-(cos(angle-0.01)*42), 2)


	line(160-cam.pos.x-(sin(angle+0.1)*4), 250-cam.pos.y-(cos(angle+0.1)*4), 160-cam.pos.x-(sin(angle-0.11)*30), 250-cam.pos.y-(cos(angle-0.11)*30), 2)
	line(160-cam.pos.x-(sin(angle+0.15)*4), 250-cam.pos.y-(cos(angle+0.15)*4), 160-cam.pos.x-(sin(angle-0.115)*30), 250-cam.pos.y-(cos(angle-0.115)*30), 2)
	line(160-cam.pos.x-(sin(angle+0.2)*4), 250-cam.pos.y-(cos(angle+0.2)*4), 160-cam.pos.x-(sin(angle-0.12)*30), 250-cam.pos.y-(cos(angle-0.12)*30), 2)

	circ(160-cam.pos.x, 250-cam.pos.y, 60, 2) 
	circ(160-cam.pos.x, 250-cam.pos.y, 59, 2) 
	circ(160-cam.pos.x, 250-cam.pos.y, 58, 2) 
	if(mid_circle_open)circfill(160-cam.pos.x+(sin(angle)*50), 250-cam.pos.y+(cos(angle)*50), 15, col) 

	circ(160-cam.pos.x, 250-cam.pos.y, 90, 2) 
	circ(160-cam.pos.x, 250-cam.pos.y, 89, 2) 
	circ(160-cam.pos.x, 250-cam.pos.y, 88, 2) 
	if(outer_circle_open)circfill(160-cam.pos.x+(cos(angle/2)*93), 250-cam.pos.y+(sin(angle/2)*93), 30, col) 

	line(160-cam.pos.x+(cos(angle/2-0.942)*61), 250-cam.pos.y+(sin(angle/2-0.942)*61), 160-cam.pos.x+(cos(angle/2-0.943)*88), 250-cam.pos.y+(sin(angle/2-0.943)*88), 2)
	line(160-cam.pos.x+(cos(angle/2-0.945)*61), 250-cam.pos.y+(sin(angle/2-0.945)*61), 160-cam.pos.x+(cos(angle/2-0.945)*88), 250-cam.pos.y+(sin(angle/2-0.945)*88), 2)
	line(160-cam.pos.x+(cos(angle/2-0.948)*61), 250-cam.pos.y+(sin(angle/2-0.948)*61), 160-cam.pos.x+(cos(angle/2-0.947)*88), 250-cam.pos.y+(sin(angle/2-0.947)*88), 2)
	camera(cam:cam_pos())

	for i=1,#pieces do
		pieces[i]:draw()
	end
	for i=1,#fountains do
		fountains[i]:draw()
	end
	for i=1,#buttons do
		buttons[i]:draw()
	end
	for i=1,#triggers do
		if (triggers[i].visible)triggers[i]:draw()
	end

	map(0,0,0,0,128,128)

	p1:draw()


	if(dark) then
		--flr(p1.x-cam.pos.x+32),p1.y-cam.pos.y+32,64,64
		spr(29,p1.x-34,p1.y-34,3,3)
		spr(29,p1.x+10,p1.y-34,3,3,true)
		spr(29,p1.x+10,p1.y+9,3,3,true,true)
		spr(29,p1.x-34,p1.y+9,3,3,false,true)

	end
	--hud
	camera(0,0)

	if(debug) then
		printc("under: " .. pget(flr(p1.x-cam.pos.x+64),flr(p1.y+(p1.h))-cam.pos.y+64), 64,44,7,0,0)
		printc("adv. micro platformer",64,4,7,0,0)
		if (p1.double_jump)printc("double_jump",64,20,7,0,0)
		if (p1.double_jump_available)printc("double_jump_available",64,28,7,0,0)
		printc(flr(p1.x) .. "/" .. flr(p1.y) .. " test: " .. flr(p1.x-cam.pos.x+64) .. "/" .. flr(p1.y+(p1.h))-cam.pos.y+64, 64, 36, 7,0,0) 
	end
	clip()
	if (statechangecountdown>0) then
		printc(states[state],64,50,7,0,0)
	end
	--if (beanschangecountdown>0) then
	if (special_bean) then
		printc("beans: " .. beans .. "/" .. maxbeans .. " +1 special bean",64,123,7,0,0)
	else
		printc("beans: " .. beans .. "/" .. maxbeans,64,123,7,0,0)
	end
	printc("time spent: " .. time,64,4,7,0,0)

	if(false==has_moved) then
		printc("hello! i'm rich and i",64,28,7,0,0)
		printc("maintain this coffee dimension.",64,36,7,0,0)
		printc("i need to find the "..maxbeans .. " beans",64,44,7,0,0)
		printc("that have been lost.",64,52,7,0,0)
		printc("please help me!",64,60,7,0,0)
	end

end
function _init_mainscreen()
	step=0
	image = 
"33333333333333333333333333333333333333533333333333333533333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333335333333333333335333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333353333333333333353333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333533333333333333533333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333335533333333333333533333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333533333333333335333353333333333333333333333333333888888333883333388333388888888333333333333333333333333333333333333333333333333335533333333333353333533333333333333333333333388882222228382283338228338222222228333333333333333333333333333333333333333355333333335333333333333533333533333333333333333333338222222222283822833382283382222222283333333333333333333333333333333333333333335333333353333335533335333335533333333333333333333382222222288338228333382833822228888333333333333333333333333333333333333333333355333333533333533333353333353333333333333333333333388882228333382283333822833822833333333333333333333333333333333333333333333333353333335333335333333533333533333333333333333333333333382283333822833338228338228333333333333333333333333333333333333333333333333533333353333353333335333353333333333333333333333333333822833338222888822283382228883333333333333333333333333333333333333333333335333333353333553333353333533333333333333333333333333338228333382222222222833822222283333333333333333333333333333333333333333333353333333533333353333333355333333333333333333333333333382283333822222222228338222222833333333333333333333333333333333333333333333533333335333333533333333533333333333333333333333333333822833333822288822283382222883333333333333333333333333333333333333333333335336666656666655666666665333333333333333333333333333338228333338228333822833822283333333333333333333333333333333333333333333333355677777777777577777777756666333333333333333333333333382283333382283338222833822833388333333333333333333333333333333333333333366757777777777757777777777577776633333333333333333333333822833333822833382228338222888228333333333333333333333333333333333333366777557777777775777777777775777777663333333333333333333338228333338228333382283382222222283333333333333333333333333333333333336777777577777777577777777777577777777763333333333333333333382283333382283333822833822222222833333333333333333333333333333333333367777775777777775777777777775777777777663333333333333333333388333333388333333883333888888883333333333333333333333333333333333336777777757777777757777777777777777777776633333333333333333333333333333333333333333333333333333333333333333333333333333333333333367777777577777777577777777777777777777667633333333333333333333333333333333333333333333333333333333333333333333333333333333333333667777777777777775777777777777777777666776333333333333333333333333333333333333333333333333333333333333333333333333333333333333336667777777777777777777777777777766666777763333333333333333333333333333333333333333333333333333333333333333333333333333333333333367766666666777777777777777776666777777777763333333333333333333333333333333333333333333333333333333333333333333333333333333333333677777777766666666666666666677777777777777633333333388833333333333333333333333333888833333333888833333333333333333333333333333336777777777777777777777775555555555555777776333333338828333333333333338833333333882222883333882222888833333333333333333333333333367777777775555555555555500000000000005555563333333382283333333333338822883333338228882833338822222222883333333333333333333333333677777755500000000000000000000000000000005553333333822833333333333822882283333382833388333333888222222283333333333333333333333336777755000000000000000000000000000000000000533333338228333333333382283382833333822883333333333338222822283333333333333333333333365555000000000000000000000000000000000000555533333382283333333333828333382833333822283333333333382283822833333333333333333333333555000000000000000000000000000000000000555005333333822283333333338283333828333333882283333333338228333883333333333333333555555555555555000000000000000000000000000055555000053333333822833333333382833338283333333382283333333382283333333333333333355555ddddddd50000055555500000000000000000055555500000000533333338228333333333822833822833338833382283333333828333333333333333355dddddddddddd5000000000055555555555555555555000000000000053333333822283333883338228822283338228338228333333822833333333333333355ddddddddddddd500000000000000000000000000000000000000000005333333338228388822833382222283333882288228333333382833333333333333335dddddddddddddd500000000000000000000000000000000000000000005333333338222822222833338888833333338822283333333822833333333333333355dddddddddddddd50000000000000000000000000000000000000000000533333333822222222283333333333333333338883333333382283333333333333335ddddddddddddddd50000000000000000000000000000000000000000000533333333882222888833333333333333333333333333333338833333333333333335dddddddd555555550000000000000000000000000000000000000000000533333333338888333333333333333333333333333333333333333333333333333335dddddd55533333350000000000000111100000000000000000000000000533333333333333333333333333333333333333333333333333333333333333333335ddddd5533333333500000000000011cc110000000000001111100000000533333333333333333333333333333333333333333333333333333333333333333335ddddd533333333350000000000011cccc11000000000011ccc110000000533333333333333333333333333333333333333333333333333333333333333333355ddddd53333333335000000000001cccccc100000000001ccccc1000000005333333333333333333333333333333333333333333333333333333333333333335dddddd53333333335000000000001cc11cc100000000011ccccc1000000005333333333333333333333333333333333333333333333333333333333333333335ddddd5533333333350000000000011c11cc10000000001cccccc1000000005333333388833333333888833333338883333388333338833333388888333333335ddddd5333333333350000000000001cccc110000000001cc11cc1000000005333388822288333388222283333882228333822833382283338822222883333335ddddd53333333333500000000000011111100000000001cc11cc1000000005333822228822833822888833338228228333822283382283338222882228333335ddddd53333333333500000000000000000000000000001cccccc1000000005333822283382833828333333382883828333822228382833382228338883333335ddddd533333333335000000000000000000000000000011cccc10000000005333382833382838283333333828333382833822822822833382283333333333335ddddd533333333335000000000000000000000000000001111110000000005333382833828338228833333828333382833828382228333338228833333333335ddddd533333333335000000000000000000000000000000000000000000005333382288283338222283333828338822833828338228333333882288333333335ddddd533333333335000000000000000000000000000000000000000000005333338222228338228833333822882222833822838228333333338822833333335ddddd533333333335000000000000000000000000000000000000000000005333338228822838283333333822228882833382833822838883333382833333335ddddd533333333335000011110000000000000000000000000000000000005333338283382838283338833822883382283382283822838228888822833333335ddddd55333333335000001cc11000000000000000000000000000000000005333338283382833828882283828333382283382283382833822222288333333335dddddd5553333335000001ccc1000000000000000000000000000000000005333338228822833822228833828333338283338833388333388888833333333335dddddddd55555555000001cccc110000000000000000000000000000000005333333822228333388883333388333338833333333333333333333333333333335ddddddddddddddd5000001cccccc11100000000000000000000000000000053333333888833333333333333333333333333333333333333333333333333333355dddddddddddddd5000001ccccccccc11100000000000000000000000000053333333333333333333333333333333333333333333333333333333333333333335dddddddddddddd50000011ccccccccccc1111111111111111000000000005333333333333333333333333333333333333333333333333333333333333333333555dddddddddddd500000011cccccccccccccccccccccccccc11100000000533333333333333333333333333333333333333333333333333333333333333333333555dddddddddd500000001111ccccccccccccccccccccccccc110000000533333333333333333333333333333333333333333333333333333333333333333333335555555555550000000000111cccccccccccccccccccccccc10000000533333333333333333333333333333333333333333333333333333333333333333333333333333333350000000000001111ccccccccccccccccccccc1000000053333333333333333333333333333333333333333333333333333333333333333333333333333333350000000000000000111cccccccccccccccccc11000000053333333333333333333333333333333333333333333333333333333333333333333333333333333350000000000000000000111111cccccccc11111000000005333333333333333333333333333333333333333333333333333333333333333333333333333333335000000000000000000000000011111111000000000000053333333333333333333333333333333333333333333333333333333333333333333333333333333350000000000000000000000000000000000000000000000533333333333333333333300000000333333333333333333333333333333333333333333333333333500000000000000000000000000000000000000000000053333333333333333333330044004400333333333333333333333333333333333333333333333333350000000000000000000000000000000000000000000000533333333333333333333304440044403333333333333333333333333333333333333333333333333500000000000000000000000000000000000000000000005333333333333333333333044400444003333333333333333333333333333333333333333333333335000000000000000000000000000000000000000000000053333333333333333333300444000444033333333333333333333333333333333333333333333333350000000000000000000000000000000000000000000000533333333333333333333044440004440333333333333333333333333333333333333333333333333500000000000000000000000000000000000000000000005333333333333333333330444440044403333333333333333333333333333333333333333333333335000000000000000000000000000000000000000000000533333333333333333333304444400444033333333333333333333333333333333333333333333333355000000000000000000000000000000000000000000005333333333333333333333044444004440333333333333333333333333333333333333333333333333350000000000000000000000000000000000000000000053333333333333333333330544440044403333333333333333000003333333333333333333333333333355000000000000000000000000000000000000000000533333333333333333333305444440044403333333333333300444400333333333333333333333333333350000000000000000000000000000000000000000053333333333333333333333054444400444033333333333300444444440333333333333333333333333333355000000000000000000000000000000000000005333333333333333333333330054444000440333333333330044444400403333333333333333333333333333355000000000000000000000000000000000000533333333333333333333333330544440000033333333333044444400044033333333333333333333333333333335500000000000000000000000000000000053333333333333333333333333330044440003333333333304444400044440333333333333333333333333333333333550000000000000000000000000000005333333333333333333333333333330004400333333333330044440044444403333333333333333333333333333333333350000000000000000000000000005533333333333333333333333333333333000033333333333304444404444444033333333333333333333333333333333333d5500000000000000000000000553333333333333333333333333333333333333333333333333004444004444440333333333333333333333333333333333333d1155500000000000000000555d33333333333333333333333333333333333333333333333333044440044444400333333333333333333333333333333333333d1111155000000000000055111d33333333333333333333333333333333333333333333333333044440444445503333333333333333333333333333333333333d11111d35555500000055d11111d333333333333333333333333333333333333333333333333304400444445003333333333333333333333333333333333333d111111d33333555555533d11111d333333333333333333333333333333333333333333333333304004444550333333333333333333333333333333333333333d111111d33333333333333d11111d333333333333333333333333333333333333333333000003330444455003333333333333333333333333333333333333333d111111d33333333333333d11111d333333333333333333333333000033333333333330044000033000000033333333333333333333333333333333333333333d111111d33333333333333d11111d333333333333333333333300044000003333333330444004003333333333333333333333333333333333333333333333333d111111d33333333333333d11111d333333333333333333330044444444000333333300440004403333333333333333333333333333333333333333333333333d111111d33333333333333d11111dd3333333333333333333044440000000403333300444004440333333333330000003333333333333333333333333333333d1111111d33333333333333d111111d333333333333333333044400000004440333330444400444033333333000444444033333333333333333333333333333d11111111d33333333333333d111111d33333333333333333004000000444440333333044440044403333333304444444403333333333333333333333333333d111111111d33333333333333d111111dd333333333333333304000044444445033333044444044440333333304444444000333333333333333333333333333d1111111111d33333333333333d1111111dd3333333333333330444444444445003333304444004444033333330444440000333333333333333333333333333d11111111111d33333333333333d11111111dd33333333333333044444444455503333330444400444403333333000000044033333333333333333333333333dd1111111111d333333333333333d111111111ddd33333333333300555555555500333333044440044450333333305000444403333333333333333333333333dd11111111111d333333333333333d11111111111dd333333333333000000555000333333330444004450333333330544444400333333333333333333333333dd11111111111dd333333333333333dd11111111111dd33333333333333330000033333333330444004450333333330555444003333333333333333333333333d111111111111d33333333333333333dd11111111111dd333333333333333333333333333333004000550033333333300000033333333333333333333333333d111111111111dd333333333333333333dd11111111111d333333333333333333333333333333300000003333333333333333333333333333333333333333333d111111111111d33333333333333333333dd1111111111d3333333333333333333333333333333300003333333333333333333333333333333333333333333333d1111111111dd333333333333333333333dd111111111d3333333333333333333333333333333333333333333333333333333333333333333333333333333333d1111111111d33333333333333333333333dd1111111dd3333333333333333333333333333333333333333333333333333333333333333333333333333333333dddd11111ddd333333333333333333333333ddd1111dd33333333333333333333333333333333333333333333333333333333333333333333333333333333333333ddddddd3333333333333333333333333333dddddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333"
	animcounter=0
	coscounter=-0.8

end

function convertfromhex(hex)
	if (hex=='a')return 10
	if (hex=='b')return 11
	if (hex=='c')return 12
	if (hex=='d')return 13
	if (hex=='e')return 14
	if (hex=='f')return 15
	return flr(hex)
end

function _update60_mainscreen() 
	step+=1
	animcounter+=24
	coscounter+=0.1
	if(coscounter>1) coscounter=-1
	if (btnp(5) or btnp(4) or animcounter>1500) mainscreen=false

end

function _draw_mainscreen()
	cls(3)
	for x=0,128 do
		for y=1,110 do
			if(256-animcounter-y<1 and animcounter<500) then
				pset(min(x,x+10*cos(coscounter)),7+y,convertfromhex(sub(image,x+y*128, x+y*128)))
			else
				pset(max(x,x+256-animcounter-y),7+y,convertfromhex(sub(image,x+y*128, x+y*128)))
			end
		end
	end
end


function intro_init()
  map_x = 130
  map_y_org = 24
  offs=16
  music(0)
  intro=true
end

function intro_update()
	map_x -= 1
	if btnp(5) or btnp(4) or map_x < -320 then
		intro=false
		music(25)
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
	spr(offs+7, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+5, map_x+56, map_y)
	spr(offs+7, map_x+64, map_y)
	spr(offs+3, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+5, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+5, map_x+152, map_y)
	spr(offs+7, map_x+160, map_y)
	spr(offs+3, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+5, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
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
	spr(offs+7, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+56, map_y)
	spr(offs+7, map_x+64, map_y)
	spr(offs+6, map_x+72, map_y)

	spr(offs+2, map_x+80, map_y)
	spr(offs+1, map_x+88, map_y)

	spr(offs+2, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs+7, map_x+160, map_y)
	spr(offs+6, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+2, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y += 16
	spr(offs+1, map_x+104, map_y)
	spr(offs+1, map_x+152, map_y)
	spr(offs+4, map_x+168, map_y)

	map_y += 8

	spr(offs+7, map_x+24, map_y)
	spr(offs+7, map_x+32, map_y)
	spr(offs+3, map_x+40, map_y)

	spr(offs+5, map_x+48, map_y)
	spr(offs+1, map_x+56, map_y)

	spr(offs+5, map_x+64, map_y)
	spr(offs+7, map_x+72, map_y)
	spr(offs+3, map_x+80, map_y)
	
	spr(offs+5, map_x+88, map_y)
	spr(offs+7, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+1, map_x+112, map_y)
	
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+7, map_x+152, map_y)
	spr(offs+1, map_x+160, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+3, map_x+192, map_y)

	spr(offs+7, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
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

	spr(offs+7, map_x+24, map_y)
	spr(offs+7, map_x+32, map_y)
	spr(offs+6, map_x+40, map_y)

	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+64, map_y)
	spr(offs+7, map_x+72, map_y)
	spr(offs+6, map_x+80, map_y)
	
	spr(offs+2, map_x+88, map_y)
	spr(offs+7, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+6, map_x+128, map_y)

	spr(offs+2, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs+1, map_x+160, map_y)

	spr(offs+1, map_x+168, map_y)

	spr(offs+2, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+6, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+1, map_x+216, map_y)

	spr(offs+7, map_x+224, map_y)
	spr(offs+6, map_x+232, map_y)

	map_y += 8

	spr(offs+1, map_x+24, map_y)

end
__gfx__
01234567ee5bbb5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddde555555e22222222ee444444ee4444eeeddddddeeeeeeeeeeeeeeeee
89abcdef555c3c5eee5bbb5eeee5bbb5ee5bbb5eee5bbb5eeee5bbb5ee5bbb5edddddddd556666552222222244499999eeeeeeee5555555555666655eeeeeeee
007007005e53335e555c3c5ee555c3c5555c3c5e555c3c5ee555c3c5555c3c5edddddddd566dd6652222222244999444eeeeeeeee555555ee544445eeeeeeeee
000770005552cc5e5e53335ee5e533355e53335e5e53335ee5e533355e53335edddddddd56dddd652222222294449994eeeeeeeee555555ee544445eeeee44ee
00077000ee52225e5552cc5ee552cc5e5552cc5e5552cc5ee552cc5e552cc25edddddddd56dddd652222222299944499eeeeeeeee555555ee544445eeee4404e
00700700eee555eeee52225eee52225eee52225eee52225eee52225ee52225eedddddddd566dd6652222222299999444eeeeeeeee555555ee544445eee44044e
00000000ee11e11eeee555eeee1555eeeee511eeeee555eeeee555ee11555eeedddddddd556666552222222244999999eeeeeeeee555555ee554455eee4044ee
00000000eeeeeeeeee11e11eeee1e11eee11eeeeee11e11eeee11eeeee11eeeedddddddde555555e22222222e4444444eeeeeeeeee5555eeee5555eeeee44eee
eeeeeeee1111111e1111111111eeeeee1111111eeeeee1111111111e11111111eeeeeeeeeeeeeeeeeee55eeeeee55eee05555000000000000000000000000000
eeeeeeee1111111e111111111111eeee1111111eeee111111111111e11111111eeeeeeeeeeeeeeeeee5115eeee5cc5ee155551110000000000000000000eeeee
eeeeeeee1111111ee111111111111eee1111111eee111111111111ee11111111eee55eeeeee55eeee511115ee5cccc5e55015555000000000000000eeeeeeeee
eeee00ee1111111ee1111111111111ee1111111ee1111111111111ee11111111ee5115eeee5cc5ee511111155cccccc555015555000000000000eeeeeeeeeeee
eee0040e1111111eee111111111111ee1111111ee111111111111eee11111111e511115ee5cccc5e511111155cccccc5115555110000000000eeeeeeeeeeeeee
ee00400e1111111eeee111111111111e0000000e111111111111eeee11111111511111155cccccc5e511115ee5cccc5e00555500000000000eeeeeeeeeeeeeee
ee0400ee1111111eeeeee1111111111eeeeeeeee1111111111eeeeee11111111511111155cccccc5ee5115eeee5cc5ee5551055500000000eeeeeeeeeeeeeeee
eee00eee0000000eeeeeeeee0000000eeeeeeeee00000000eeeeeeee00000000e511115ee5cccc5eeee55eeeeee55eee155105110000000eeeeeeeeeeeeeeeee
5dd66dd5eee5555555555eee5dd66dd55dd66dd5555555555dd66dd5e000000e449999944eeeeeeeeee44eeebaa8aabeeebbbbbe000000eeeeeeeeeeeeeeeeee
5dd66dd5e555dddddddd555eddd66dd55dd66ddddddddddd5dd66ddd00588500e4449444944eee44ee4994eebaa8aabeebbaaabb00000eeeeeeeeeeeeeeeeeee
5dd66dd5e5dddddddddddd5edd666dd55dd666dddddddddd5dd66ddd058855d0eee444ee994eee49eee44eeebba88abbebaaaaab0000eeeeeeeeeeeeeeeeeeee
5dd66dd555dd66666666dd5566666dd55dd66666666666665dd6666608855dd0eeee4eee994eee49eeeeeeeeebaa8aabebaa8aab0000eeeeeeeeeeeeeeeeeeee
5dd66dd55dd6666666666dd56666dd5555dd6666666666665dd666660855dd50eee44eee994eeee4eeeeeeeeebaa8aabbbaa8aab000eeeeeeeeeeeeeeeeeeeee
5dd66dd55dd666dddd666dd5dddddd5ee5dddddddddddddd5dd66ddd055dd550eee4eeee994eeee4eeeeeeeeebaa8abbbaa88aab000eeeeeeeeeeeeeeeeeeeee
5dd66dd55dd66dddddd66dd5dddd555ee555dddddddddddd5dd66ddd00dd5500eeeeeeee444eeee4eeeeeeeebba88abebaa8aabb000eeeeeeeeeeeeeeeeeeeee
5dd66dd55dd66dd55dd66dd555555eeeeee55555555555555dd66dd5e000000e444444ee44eeeeeeeeeeeeeebaa8aabebaa8aabe00eeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555555e555555e5dd66dd55555555e55555555aa8aabbe5dd66dd5baa8aabe00eeeeeeeeeeeeeeeeeeeeee
eee5bbb5e5bbbb5ee5bbbb5ee5bbb5eee5bbb5eedddddddd550000555dd66dd5dddddd555dddddd5aa8aabbe5dd6655ebaa8aabb00eeeeeeeeeeeeeeeeeeeeee
e555c3c5553c3c5ee5c3c355e5c3c555e5c3c555dddddddd5d5555d55dd66dd5ddddd5055d5665d5ba88aabe5dd555eebaa8aaab00eeeeeeeeeeeeeeeeeeeeee
e5e533355e53335ee53335e5e53335e5e53335e5666666665dd66dd55dd66dd5666665055d6666d5baa8aabbe555eeeebaa88aab0eeeeeeeeeeeeeeeeeeeeeee
e552cc5e5552cc2552cc2555ee5cc255e5cc2555666666665dd66dd55dd66dd5666665055d6666d5bba88aabeeeeeeeebaaa8aab0eeeeeeeeeeeeeeeeeeeeeee
ee52225eee522225522225eeee52225ee52225eeddd66ddd5dd66dd55d5555d5ddddd5055d5665d5ebaa8abbeeeeeeeebaaaaaab0eeeeeeeeeeeeeeeeeeeeeee
eee555eeeee5555ee55555eeeee555eeee5555eeddd66ddd5dd66dd555000055dddddd555dddddd5ebaa8abeeeee555ebbaaaabb0eeeeeeeeeeeeeeeeeeeeeee
ee11e11eee11e11eee11e11eee11e11eee11e11e5dd66dd55dd66dd5e555555e5555555e55555555bba88abee5555d55ebbbbbbe0eeeeeeeeeeeeeeeeeeeeeee
11111111ebbbbbbeebbbbbbbbbbbbbee11111111baa8aabeddddddd1eeeeeeeee4499494e444eee444444444444444444e4444ee4eee444499999449ee4444ee
99999999bbaaaabbbbaaaaaaaaaaabbe11111111baa8aabe000000ddeeeeeeeee49944944494ee4499999999999999944444944e44e4999944499944e4499444
44444444baaaaaabbaaaaaaaaaaaaabb11111111baa8aabb0000000deeeeeeee4494f494444444f4449444444444449999949944944444999944499944499494
e00ee00ebaa88aabbaaa8888888aaaab11111111bba88aab0000000deeeeeeee4994499449449449944499949999944444999494999999949999449949449944
eeeeeeeebaaaaaabbaa88aaaaa88aaab11111111ebaa8aab0000000deeeeeee44944999449499499999944999999999994494494444444449999944949944994
eeeeeeeebbaaaabbbaaaaaaaaaa8aaab11111111ebba88aa0000000deeeeee4449449944494949949994ff499444449949444994999999999444994449494494
eeeeeeeeebbbbbbebbaaabbbbaa8aaab11111111eebaa8aa000000ddeeeeee494449944e444949444444f44444eee444499999444444444444f4999944499494
eeeeeeeeeeeeeeeeebbbbbeebaa8aabb11111111eebba88adddddddeeeeee449449944eee4994944eee444eeeeeeeeee4444944eeeeeeeeee4444444e444444e
5555555555555555ddddddd555555555ddddddddeeebaa88aabbeeeeeeee449944994eee4994994e4994994eeee44444e494994e111888811111111118888111
5dddddddddddddd5ddddd6d55dddddd500000000eeebbaa8aaabeeeeeeee499949944eee4994994e4499994eee449999e494994e188888888111111888888881
5d6dddddddddd6d5ddddddd55d6dd6d500000000eeeebaa88aabbeeeeee449944994eeee44949944e449444ee4499999e4949444188888888811118888888888
5dddddddddddddd5ddddddd55dddddd500000000eeeebbaa88aabeeeeee499449944eeeee494499444444944e4499444e4949944888888888881188888888888
5dddddddddddddd5ddddddd55dddddd500000000eeeeebaaa8aabeeeeee44449994eeeeee499499449999994ee494499e4999444888888888888888888888888
5dddddddddddddd5ddddddd55dddddd500000000eeeeebbaa8aabeeeeee49999944eeeeee449449444999494ee494994e4444494888888866666666888888888
5dddddddddddddd5ddddd6d55dddddd500000000eeeeeebaa88abbeeee44999944eeeeeeee499499e4449449ee494944e4999994888888600000000688888888
5dddddddddddddd5ddddddd55dddddd5ddddddddeeeeeebbaa8aabeeee4994444eeeeeeeee449449eee49949ee49994ee4994994888888660000006666888888
5dddddddddddddd55ddddddd5dddddd555555555eeeeeeebaa8aabbeeeeeeeee55555555eee499449944eeeee49994e4e4994994888888676666667777688888
5dddddddddddddd55d6ddddd5d6dd6d5ddddddddeeeeeeebba8aaabeeeeeeeee55555555eee449949994eeeee494444444944994888888677777777607688881
5dddddddddddddd55ddddddd5dddddd5d6dddd6deeeeeeeeba88aabbeeeeeeeeddddddddeeee499449944eee4494f44949949944188888677777777606688881
5dddddddddddddd55ddddddd5dddddd5ddddddddeeeeeeeebaa8aaabeeeeeeeee111111eeeee449944994eee4944ff49499494f4188888677777777776888811
5dddddddddddddd55ddddddd5dddddd5ddddddddeeeeeeeebaa88aabbeeeeeeeee0000eeeeeee49994444eee4944444944949944118888867777777668888811
5d6dddddddddd6d55ddddddd5dddddd5ddddddddeeeeeeeebbaa88aabbeeeeeeeeeeeeeeeeeee44999994eee49999449e4944994118886667777776dd8888111
5dddddddddddddd55d6ddddd5d6dd6d5ddddddddeeeeeeeeebbaa88aabeeeeeeeeeeeeeeeeeeee44999944ee44499999e49949941118677d666666d776888111
55555555555555555ddddddd5dddddd5ddddddddeeeeeeeeeebbaa8aabbeeeeeeeeeeeeeeeeeeee4444994eeee444444e499499411188677dddddd7768881111
5555555555555555555555555dddddd5ddddddddd000000dd000000d1dddddddee444499ddddddd54949944eeeeeeeee4e49994e111188667777776688811111
5dddddddddddddddddddddd55d6dd6d5ddddddddd000000dd000000ddd000000ee499999ddddddd54949994eeeeeeeee4449994e111118886666668888111111
5d6dddddd6dddd6dddddd6d55dddddd5ddddddddd000000dd000000dd0000000e4494494e555555549444944eeeeeeee99999944111111888888888881111111
5dddddddddddddddddddddd55dddddd5ddddddddd000000dd000000dd0000000e4994994eeeeeeee4994f494eeeeeeee99994994111111188888888811111111
5dddddddddddddddddddddd55dddddd5ddddddddd000000dd000000dd0000000e4944994ddddddde499944944eeeeeee99444994111111118888888111111111
5d6dddddd6dddd6dddddd6d55d6dd6d5d6dddd6dd000000dd000000dd000000044949944ddddddd54499449444eeeeee94499994111111111888881111111111
5dddddddddddddddddddddd55dddddd5ddddddddd000000ddd0000dddd0000004994944ee5555555e449944494eeeeee44999444111111111188811111111111
5555555555555555555555555555555555555555d000000d0dddddd0eddddddd499444eeeeeeeeeeee449944944eeeeee444444e111111111118111111111111
90000000000000000000000000000000000000000000000000979797979797979797000000000000000000000000000000000000000000000000000000000021
71717171610000217161000000000000000000000000000071000000000071000000261500003504040517171717171717171716000000000036000007174780
90f00000000000000000000000000000000000000000979797970000000000000000000000000000000074b7007494b4b4d4a4b0c40000000000000000000000
00000000000000004100000000517171310000000000000071000000517171040404262500003600003600000000000000000000000000000036000000000026
9097970000000000000000000000000000000000009797000000000000000000000000b5d4c40000007487b4a4d48500000000c09694f4000000000000000000
00000000000000000000000000110021717131000000000071000000710071000000262500003604043600000000000000000000000000000026150000000026
9000979700000000000000000000000000000000979700000000000000000000007494c700c5000074f4850000000000000000000096e4c40000000000000000
00000000000000000000000000213100002171713100000071000000710071000000262500003600003600000000000000000000000000000026250000000026
9000009797970000000000000000000097979797970000000000000074f4d4b0b4a4850000b6b4c475850000000000000000000000000096f400000000000000
00000000000000000000000000002171717171717171717161000000217161040404061600003704040617171717171717171717171717171747471727000026
90000000009797970000000000009797970000000000000000000000758500c000000000000000f4c000000000000074f4c4000000000000b6c4000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026
9000000000000097979797979797970000000000000000000000007484000000000000000000008200f0000000f49484a4e4b0c4000000000096f40000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000000000000000000580
90000000000000000000000000000000000000000000000000000075c400000000f4b0a4b0b4d4e4b4c4000000c0b6a7b70000a7f4c4b700000096a600000000
243400000000000000c2051717171717171717172704040546464646464646464646464646464646464646461717171717171717171717171717171717174780
900000000000000000000000000000000000000000000000000000c6840000000000c000000000c000b6f40000000096a6f400c0c5b4a600000000a7b7000000
00b200000014000000b236000000000000000000000000268080808080808080808080808080808080808025a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
9000000000000000000000000000000000000000000000000000f4e4f4b4c40000000000000000000000c5c400000000c0b6b4a4c60095f400000096a6000000
005476000000000000b236000000000000000000000000268080808080808080808080808080808080808025a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
9000000000000000000000000000000000000000000000000000c000b6a4e4b4f4b0b4a4b0c400000000c5a4c400000000000000b6b4a4c7f000000096f40000
005565000000000000b236000000000005464646464646808080808080808080808080808080808080808025a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
90f0000000000000000000000000000000000000000000f4c400000000000074840000000000000094c4c700c5000000000000000000b6e4f400000000a7b700
005666760000000000b23604043504042680808080808080808080808080808080804747474747474747471600a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
72727272727272727272727272727272727272727272727272720000000000758500000000000000c5c7d4a4c7f400000000000000000000c00000000096c400
000055650000000000b2360000360000268080808080808080808080808080808025000000000000000000000000a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
72000000000000000000000000000000000000000000000000720000007494f400000000b5d4a4b4c700000075e4c4b0c40000000000000000000000000095b7
000056667600000000b236040436040406474747474747474747474747474747471600000000000000000000000000a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
7200000000000000000000000000000000000000000000000072000000758500000000f4c500000000000000c000c57484b4f4000000000000000000000096a6
000000556500000000b23600003600000000000000000000000000000000000000000000000000000000000000000000a0a0a0a0a0a0a0a0a0a0a0a0a0a0a026
7200000000000000000000000000000000000000000000000072000074840000000074b6c700f000000000000000f487c700b6a494b7000000000000000000f4
b70000566676000000b2360404360000000000000000000000000000000000000000000000000000000000000000000000a0a0a0a0a0a0a0a0a0a0a0a0a0a026
7272727272727272727272727272727272727272727272727272000075850000000075e4b4b0b4f400000000000000c50000000075b4c4000000000000000096
a60000005565000000b236000026464615000005464617171717171717171717171500000000868600000000000000000000a0a0a0a0a0a0a0a0a0a0a0a0a026
72000000000000000000000000000000000000000000000000720094f4000000007484000000000000000000a20000c600000000c00096f40000000000000000
95b700005666760000b23604042680802504042680250000000000000000000000360000000000000000000000000000000000a0a0a0a0a0a0a0a0a0a0a0a026
720000000000000000000000000000000000000000000000007200c600000000007585000000000000000000000000c5c4000000000074840000000000000000
96a600000055650000b236000026808025000026802500000000f000000000000036a00000000000000000000000000000000000a0a0a0a0a0a0a0a0a0a0a026
720000000000000000000000000000000000000000000000007200c50000000094850000000000000000000000000095c50000000000758500000094c4b70000
94a5b70000566676f0b2360404268080250404268025040405464615000035000036a0a00000000000000000000000000000000000a0a0a0a0a0a0a0a0a0a026
720000000000000000000000000000000000000000000000007200c6000000f4e4a6000000000000000000000000b5b4c7000000007487000074f4b0e4a60000
c6d4c40000005565c2b2360000268080250000268025000026808025000036040436a0a0a00000000000000000000000000000000000a0a0a0a0a0a0a0a0a026
72000072727272000000000000000000000000727272720000720095b7000000c096b4c4000000000094b4a4b4d4c700c000000000758500007585c000a500f0
c500c500000056a3b2b2360404064747160404064725040406474716000036000036a0a0a0a00000000000000000000000000000000000a0a0a0a0a0a0a0a026
720404720000720000000000000000000000007200007204047200f4a6000000000000c5000000000095b7000000000000000000748700007487000000f4a4c4
959484f4000000c3b2b2360000000000000000000036000000000000000036040436a0a0a0a0a00000000000000000000000000000000000a0a0a0a0a0a0a026
72000072000072000000000000000000000000720000720000720096e4c400000000f0f4c40000000096a6000000000000000000758500007585000000c00000
96e4b6c4b7000000c3b2360000000000000000000036000000000000000036000036a0a0a0a0a0a00000000000000000000000000000000000a0a0a0a0a0a026
720404720000720000000000000000000000f0720000720404720000b6b0b492f4d4b4e4c70000000000a7b70000000000000074870000748700000000000000
00c096e4c400000000c3360404054646464615040436040405464615000036040436a0a0a0a0a0a0a00000000000000000000000000000000000a0a0a0a0a026
7200007200007272727200000000000072727272000072000072000000c0000000000000c0a20000000096c4b774b700000094b4850000758500000000000000
00000096a70000000000360000268080808025000036000026808025000036000036a0a0a0a0a0a0a0a00000000000000000000000000000000000a0a0a0a026
7204047200000000007200000000000072000000000072040472000000000000000000000000000000000096b0a4b4d4a4b4c700000074840000000000000000
000074b7c6f400000000360404268080808025040436040426808025000036040436a0a0a0a0a0a0a0a0a00000000000000000000000000000000000a0a0a026
72000072000000000072000000000000720000000000720000720000000000000000000000000000a2000000c000000000000000007487b4a4c4b70000000000
7494b4a4c7c000000000360000268080808025000036000026808025000036000036a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000a0a026
720404727272727272720000000000007272727272727204047200000000000000000000000000000000000000000000000000000075850000b6a4d4b0b4a4b4
d4850000000000930000370404064747474716040437040406474716000037040436a0a0a0a0a0a0a0a0a0a0a000000000000000a0a0000000000000a0a0a026
7200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000c0000000
00000000000093930000000000000000000000000000000000000000000000000036a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000a0a0a026
72000000000000000000000000000000000000000000000000000000000000000000000000000000000000939393939393939300000000000000000000000000
00000000009393939300000000000000000000000000000000000000000000000036a0a0a0a0a0a0a0a0a0a0a0a0a0000000000000000000000000f0a0a0a026
72727272727272727272727272727272727272727272727272729090909090909090909090909090909090909090909090909090909090909090909090909090
90909090909090909090054646464646464646464646464646464646464646464680464646464646464646464646464646464646464646464646464646464680
__gff__
0000000000000000010100010000000408010101010101010000000001000000010101010101010100000201010000000000000000010101010101000100000002010101000101000101010101010101010101010101010101010101010000000101010101000100010101010100000001010101010101010101010001000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
090909090909090909090909090909090909090909090909090909090909201c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c755454545454545454545454545454751c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c627474747474747474747474747474747474747474747474747408
0900000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000075444444444444444444444444444475000000000000000000000000000000000000000000000000000000000000630000000000000000000000000000000000000000000000000062
0900000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000075444444444444444444444444444475000000000000000000000000000000000000000000000000000000000000630000000000000000000000000000000000000000000f00000062
090000000000000000000000000000000000000000000000000000000000204040360000000000000000000000000000000000000000007544444444444444444444444444447500001c40401c121300000000000000000000000000000000000000000000630000000000000000000000000000506464646464646451000062
0900000000000000000000000000000000000000000000000000000000002000002000000000000000000f0000000000000000000000007544444444444444444444444444447500001c00001c001213000000000000000000000000000000000000000000630000005064646464646464510000620808080808080852000062
090000000000000000000000000000000000000000000000000000000000204040262525220000002125252200000000001c1c1c000000754444444444445d5e5f44444444447500001c40401c000011000000000000000000000000000000000000000000634040406208080808080808520000607474747474747461000062
090000000000000000000000000000000000000000000000000000000000200000200000200000002000002000000000001c0000000000754444444444446d6e6f44444444447500001c00001c000012130000000015171716000000121717130000154040630000006274747474747474610000000000000000000000000062
090000000000000000000000000000000000000000000000000000000000204040262525230000002425252300000000001c000000001c754444444444447d7e7f44444444447500001c40401c000000121300001516000000000000000000121717170000634040406300000000000000000000000000000000000000000062
090000000000000000000000000000000000000000000000000000000000200000200000000000000000000000000000001c0000001c1c7644444444444444444444444444447600001c00001c000000001217171600000000000000000000000000174040630000006300000000000000000000707171717171717171717108
090000000000000000000000000000000000000000000000000000000000204040200000000000000000000000000000001c00000000004444444444444444444444444444444400000040401c000000000000000000000000000000000000000000170000634040406300000000000000000000000000000000000000000062
09000000000000000000000000000000000000000000000000000000000020000020000f000000000000000000000000001c1c00000000444444444444444444444444444444440f000000001c0f0000000000000000000000000000000000000000174040630000006300005064646464510000000000000000000000000062
09000000000000000000000000000000000000000000000000000000000020404026252522000000212525221c1c1c1c1c1c1c1c1c1c1c775454545454545454545454545454461c1c1c1c1c1c121600000000000000000000000000000000000000170000634040406300006074747474747171717171717171717151000062
0900000000000000000000000000000000000000000000000000000000002000002000002000000020000020000000151600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000174040630000006300000000000000000000000000000000000063000062
0900000000000000000000000000000000000000000000000000000000002040402625252300000024252523000015160000000000000000000000000000000000000000000000000000000000000000140000000000000000000000000000000000000000634040406300000000000000000000000000000000000063000062
0900100000000000000000000000000000000000000000000000000000002000002000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000015171713000000000000000000000000630000006300000000000000000000000000000000000063000062
0979797900000000000000000000000000000000000000000000000000002040402000000000000000000000000012130f00000000000000000000000000000000000000000000000000000000000000000000001516000012160000000000151717174040634040406264646464646464510000506464646464646452000062
0900000000000000000000000000000000000000000000000000000000002000002000000000000000000000000000121717171600000000001216000000000000000000140000000012171300000000000000151600000000000000001217160000000000630000006274747474747474610000607474747474747452000062
0900000000000000000000000000000000000000000000000000000000002040402625252200000021252522000000000012130000000000000000000000140000000000000000000000001217171717171717160000000000000000000017000000004040634040406300000000000000000000000000000000000063000062
0900000000000000000000000000000000000000000000000000000000002000003b000f20000000200000200000000000001100000000000000000000000000000000000000000000000000000000000000000000000000151300000000170000000f0000630000006300000000000000000000000000000000000063000062
0900000000000000000000000000000000000000000000000000000000002040402625252300000024252523000000000015160000000000000000000000000000000000000000000000000000000000000000000000151716110000000017404040507171614040406300007071717171717171717171717172000063000062
0900000000000000000000000000000000000000000000000000000000002000002000000000000000000000000000000f11000000000000000000000000000000000000000000000000000000000000000000000015160000121300000017000000630000000000006300000000000000000000000000000000000063000062
0900000000000000000000000000000000000000000000000000000000002040402000000000000000000000000000151716000000000000000000000000000000000000000000000000000000000000000000151716000000001100000017404040630000000000505200000000000000000000000000000000000063000062
09000000000000000000000000000000000000000000000000000000000020000020000f0000000000000000000000110000000000000000000000000000000000000000000000151713000000000015171717160000000000001100000017000000634040405071747471717171000050717171717171717171717161000062
0900000000000000000000000000000000000000000000000000000000002040402625252200000021252522000000110f00000000000000000000000000000000000000000015160012130000000011000000000000000000001100000017404040630000006300000000000000000063000000000000000000000000000062
0900000000000000000000000000000000000000000000000000000000002000002000002000000020000020000000121717160000000000000000000000000000000000000011000000110000001516000000000000151300001100000017000000634040406300000000000000000063000000000000000000000000000062
09000000000000000000000000000000000000000000000000000000000020404026252523000000242525230000000000110000000000000000000000000000000000000015160000001213000011000000000000001111000f1100000017404040630000006300005071717171717161000050717171717164717171717108
0900000000000000000000000000000000000000000000000000000000002000002000000000000000000000000000151716000000000000000000000000000000000000001100000000001100001100000000121717161217171600000017000000634040406300006300000000000000000063000000000063000000000062
0900000000000000000000000000000000000000000000000000000000002040402000000000000000000000000000110000000000000000000000000000000000000000121100000000001100001217130000000000000000000000000017404040630000006300006300000000000000000063000000000063000000000062
0900000000000000000000000000000000000000000000000000000000002000002000000000000000000000000000110000000000000015171717171300000000140000001213000000151600000000110000000000000000000000000017000000634040407300006300000000000000707152000000000063000f00000062
0900000000000000000000000000000000000000000000000000000000003740402425252525252525252538000000121300000000151716000000001213000000000000000011000000110000000000121713000000000000000000000017404040630000000000007300000000000000000063000000000062717200000062
0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001217171717160000000000000012130000000000000012130000110000000000000012171600000015171716000017000000634000000000000000000000000000000063000000000063000000000062
090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012130000000000000011001516000000000000000000000000001700000000001740404063000000000000000000000000000f000063000000000063000000005008
__sfx__
010600001c01128011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f015300152d01528015300152d01529015280152d0152b0152d015290152d015280152b0152d0152f015300152d015340152f015320152d015300152b0152d015280152901526015280152401526015
011000002301524015210151c01524015210151d0151c0151f0151c015210151d015230151c0151f0152301524012240122401224015210051d00523005210052400523005260052400528005260052b00528005
011000000e150000000e150000000c1500000009150000000e150000000e150000000c1500000009150000000b150000000c1500000010150000000e150000000c150000000b1500000009150000000b15000000
00100000290402b0402e04031040340403504037040390403a0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000290402b040290403504029000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000404304053000000000007613040530405304053040530000000000040530761300000000000405304053000000000000000076130405300000040530405300000000000000007613076130404304053
011000001002304053000000000007613040530405304053040530000000000040530761300000000000400304053000000000000000076130405300000040530405307613040530000007613076130761307613
00100000290402b040290402200029000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000010040160401c0402204029040020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000005000000000000c04000000000000005000000000000000000050000000c0450c04000000000000005000000000000c050000000000000050000000000000050030500505007050050500305007050
011000000305000000000000005000000000000305000000000000000000050000000305503050000000000003050000000000000050000000000003050000000000003050050500305002050000500205003050
011000001b1321d132000001b1321a13200000181321a13200000181321a13200000181321a1321b132000001a1321813200000131321613200000131321513216132000001b1320000000000000001613218132
011000000405304053000000000007613040530405304053040530000000000040530761300000000000405304053000000000000000076130405304053040530405300000000000000007613076030000000000
011000001b1321d132110321b1321a13202132181321a13200000181321a13200000181321a1321b132000001a1321813200000131321613200000131321513216132000001b1320000000000000001613218132
01100000271261b126271261b126271201b120271201b120271201b120271201b120291201d1202a1201e1202b1201f1202b1201f1202b1201f1202b1201f1202b1201f1202b1201f1202b1201f1202b1201f120
011000001b1501b1521b15218150181551815518152181521b1511b15200000000001810018105181551815000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b1201b1221b12218120181251812518122181221b1211b1211312113122161201612218120181221811013100131111311016111161101811118110000001b1201d1201b1201a12018120161201b120
011000001b1201b1221b1221d1201d1251d1251e1221e1221f1211f12122121221222412024122241202412218110000001311113110161111611018111181101d1111d1101b1111b11018111181100000000000
011000002602000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000290402e040290402d00029000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018122181221812213120131251312518122181221b1211b12113121131221612016122181201812218110131001311113110161111611018111181100000000000000000000000000000000000000000
0110000022120241222212222122221121f1051f1251f12522122221211f1211d1211b1251f1251b1211b12118121181211812018120181201810118111181101d1111d1101b1111b11018111181101811000000
011000001002304053000000000007613040530405304053040530000000000040530761300000000000400304053000000000000000076130405300000040530405307613040030405307613076030405307613
0110000016120181221b1221b1222210217000181201b1221d1221d1221f1001f1001f1202212224122241221d121181211812118111000001810118111181101d1111d1101b1111b11018111181101811000000
011000001612016122161221612213122131220c1200c1220f1220f1220f12211122111201112211122111220c1210c1210c1210c1210c1210c1210c1210c1110000000000000000000000000000000000000000
011000001000304003000000000007603040030400304003040030000000000040030760300000000000400304003000000000000000076030400300000040030761304053040530761307613040530761307613
011000000c1200c1220c1220c1220f1220f1220f1200f122111221112211122131221312013122161221612218121181211812118121181211812118121181110000000000000000000000000000000000000000
011000000405304053000000000007613040530405304053040530000000000040530761307613000000405304053000000000000000076130405304053040530405300000000000000007613076030000000000
0110000018110181121611116111131101311211110111120f1100f11211112111121811118112181121811218110181111811118111000000000000000000000000000000000000000000000000000000000000
011000000012000122001210012100120001220012000122031200312203122031220a1200a1220a1220a12200121001220012200122001220012200122001220000000000000000000000000000000000000000
011000000405304053000000000007613040030405304053040530000000000040530761300000000000405304053000000000000000076130400304053040530761304053076130761307613040530761307613
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
01 01 42 43 44
04 02 42 43 44
00 03 42 43 06
02 04 42 43 06
01 0a 0d 43 44
00 0b 17 43 44
00 0a 1c 43 44
00 0b 06 43 44
00 0a 06 11 44
00 0b 0d 15 44
00 0a 06 11 44
00 0b 0d 15 44
00 0a 06 12 44
00 0b 0d 16 44
00 0a 06 12 44
00 0b 07 18 44
00 0a 06 11 44
00 0b 17 15 44
00 0a 06 11 44
00 0b 0d 15 44
00 0a 1c 12 44
00 0b 06 16 44
00 0a 06 12 44
02 0b 1f 18 44
02 41 19 1a 44
02 1b 42 1a 1e
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
