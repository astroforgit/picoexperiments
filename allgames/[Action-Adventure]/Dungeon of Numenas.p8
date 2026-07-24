pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
titlescreen=true
transition=false
transition_t=0
menu_selection=0
menu_options={"normal","yolo","super yolo"}
menu_desc={"normal mode","no checkpoints","no checkpoints or hearts"}
lines={}
scroll=0
grass_deco={}
ground_deco={}

exposition=false
actual_text=1
dtext=""
texts={"your nemesis, numenas, has\ntrapped you in this dungeon",
							"to escape, you will have to\ndefeat him",
							"find the orbs scattered\nthrough the dungeon to gain\nthe power needed to defeat\nhim",
							"good luck"}
text_timer=0
text_finished=false

bossfight=false
boss_objs={}
boss_timer=0
boss_phase=-1
mage={}
boss_hits=0
win=false
win_timer=0

bg_color=0
txt_color=7

camx = 0
camy = 0

h_threshold=60
v_threshold=40

life=1
max_life=1

collided_side=false
collided_side2=false

smoke={}
enemies={}
objects={}
orbs={}
hearts={}
power_texts={}

walljump_unlocked=false
double_unlocked=false
glide_unlocked=false

checkpoint={}

pressed_t=false

org_x=0
org_y=0

deaths=0

ticks2=0

show_timer=false

function collide_side(self)
	if not bossfight then
 	local offset=self.w/3
 	for i=-(self.w/3),(self.w/3),2 do
 	if self.dx>0 then
 		if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
 			self.dx=0
 			self.x=(flr(((self.x+(offset))/8))*8)-(offset)
 			collided_side=false
 			return true
 		end
 	elseif self.dx<0 then
 		if fget(mget((self.x-(offset)-1)/8,(self.y+i)/8),0) then
 			self.dx=0
 			self.x=(flr((self.x-(offset)-1)/8)*8)+8+(offset)+1
 			collided_side=true
 			return true
 		end
 	end
 	end
 else
 	if self.x<=4 or self.x>=124 then
 		self.dx=0
 		self.x=mid(4,self.x,124)
 		collided_side=false
 		if self.x<=4 then
 			collided_side=true
 		end
 		return true
 	end
 end
	return false
end

function collide_side2(self)
	if not bossfight then
 	local offset=self.w/3
 	for i=-(self.w/3),(self.w/3),2 do
 	if not self.flipx then
 		if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
 			collided_side2=false
 			return true
 		end
 	else
 		if fget(mget((self.x-(offset)-2)/8,(self.y+i)/8),0) then
 			collided_side2=true
 			return true
 		end
 	end
 	end
 	return false
 else
 	if self.flipx then
  	if self.x<=6 then
  		collided_side2=true
  		return true
  	end
  else
  	if self.x>=124 then
  		collided_side2=false
  		return true
  	end
  end
 end
 return false
end

function collide_floor(self)
	if not bossfight then
 	if self.dy<0 then
 		return false
 	end
 	local landed=false
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
	else
		if self.y>=116 then
			self.y=116
			self.grounded=true
			self.airtime=0
 		return true
 	end
	end
end

function collide_roof(self)
	if not bossfight then
 	for i=-(self.w/3),(self.w/3),2 do
 		if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
 			self.dy=0
 			self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
 			self.jump_hold_time=0
 		end
 	end
 	if self.y<0 then
 		self.dy=0
 		self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
 		self.jump_hold_time=0
 	end
 else
 	return bossfight
 end
end

function die()
	deaths+=1
	if not bossfight then
 	p1.x=checkpoint.x
 	p1.y=checkpoint.y
 	p1.dx=0
 	p1.dy=0
 	p1.flipx=false
 	p1.dam_timer=0
 	camx=0
 	camy=0
 	checkpoint.collided=true
 	uncollide=false
 	for e in all(enemies) do
 		e.dead=false
 		e.x=e.ix
 		e.y=e.iy
 		e.dire=false
 		e.dx=0
 		e.dy=0
 	end
 else
 	boss_objs={}
 	p1.damaging=false
 	p1.inv=true
 	p1.x=64
 	p1.y=116
 	p1.dx=0
 	p1.dy=0
 	boss_timer=0
 	boss_phase=-1
 	boss_hits=0
 	mage.x=60
		mage.y=16
		mage.flipx=false
		dtext=""
		music(-1,200)
		music(4,200)
 end
 if menu_selection==1 or menu_selection==2 then
 	 walljump_unlocked=false
 		double_unlocked=false
 		glide_unlocked=false
 		life=1
 		max_life=1
 		bossfight=false
 		reset()
 		p1.x=org_x
 		p1.y=org_y
 	end
end

function general_collision(self)
	if not bossfight then
 	local x=self.x-self.w/2
 	local y=self.y-self.h/2
 	
 	local blocks={}
 	blocks[1]={flr((x+8)/8), flr((y+8)/8)}
 	blocks[2]={flr((x)/8), flr((y+8)/8)}
 	blocks[3]={flr((x+8)/8), flr((y)/8)}
 	blocks[4]={flr((x)/8), flr((y)/8)}
 		
 	local	uncollide=true
 	
 	foreach(blocks, function(b)
 		local tile=mget(b[1], b[2])
 		
 		if tile==83 and (y)/8%1>0.5 and p1.dy>0  then
 			die()
 			life=max(1,max_life-1)
 		elseif tile>83 and tile<87 then
 			uncollide=false
 			if not checkpoint.collided then
  			checkpoint.x=b[1]*8+4
  			checkpoint.y=b[2]*8+4
  			checkpoint.collided=true
  			mset(b[1],b[2],85)
  			if life<max_life-1 then
  				life=max_life-1
  			end
  			sfx(3)
 			end
 		end
 	end)
 	
 	if uncollide then
 		checkpoint.collided=false
 	end
	end
end

function toint(b)
	if b then
		return 1
	else
		return -1
	end
end

function sign(a)
	if a>0 then
		return 1
	elseif a<0 then
		return -1
	else
		return 0
	end
end

function create_text(t,x,y)
	local te={}
	te.timer=0
	te.t=t
	te.x=x
	te.y=y
	add(power_texts,te)
end

function update_text()
	for i=#power_texts,1,-1 do
		local t=power_texts[i]
		t.timer+=1
		if t.timer>120 then
			del(power_texts,t)
		end
	end
end

function draw_texts()
	for t in all(power_texts) do
		print(t.t,t.x-2*#t.t,t.y,7)
	end
end

function update_smoke()
	for i=#smoke,1,-1 do
		local s=smoke[i]
		s.x+=s.spd.x
		s.y-=s.spd.y
		s.sprite+=0.25
		if flr(s.sprite)==19 then
			del(smoke,s)
		end
	end
end

function draw_smoke()
	for s in all(smoke) do
		pal(7,s.c)
		spr(s.sprite, s.x, s.y)
		pal(7,7)
	end
end

function on_screen(x,y,w,h,t)
	if y<=56*8 and p1.y>=57*8 and t==1 then
		return false
	end
	if camx<x+w and camx+128>x then
		if camy<y+h and camy+128>y then
			return true
		end
	end
end

function update_enemies()
	for e in all(enemies) do
		local addy=0
		if e.typ==1 then
			addy=8
		end
		if on_screen(e.x,e.y+addy,8,8-addy,e.typ) and not e.dead then
 		if p1.y<e.y and p1.y>e.y-4 and p1.x-4>=e.x-8 and p1.x-4<=e.x+8 then
 			e.dead=true
 			p1.dy=p1.djump_speed
 			p1.jumping=false
 			p1.gliding=false
 			create_smoke(e.x,e.y-4,2,7)
 			sfx(1)
 		end
 		if p1.x-4>=e.x-5 and p1.x-4<=e.x+5 then
 			if p1.y-4>=e.y-5 and p1.y-4<=e.y+5 then
 				if not p1.inv and not p1.damaging then
  				life-=1
  				p1.damaging=true
 				end
 			end
 		end
 		
 		if e.typ==0 then
  		e.x+=0.2*toint(e.dire)
  		local tile_ux=mget(flr((e.x+4+toint(e.dire)*4)/8),flr(e.y+8)/8)
  		if tile_ux<=64 or (tile_ux>=72 and tile_ux<=83) then
  			e.dire = not e.dire
  		end
  	elseif e.typ==1 then
  		e.dx+=(p1.x-e.x-4)*0.0008
  		e.dy+=(p1.y-e.y-4)*0.001
  		if abs(e.dx)>0.8 then
  			e.dx=sgn(e.dx)*0.8
  		end
  		if abs(e.dy)>1 then
  			e.dy=sgn(e.dy)*1
  		end
  		e.x+=e.dx
  		e.y+=e.dy
  	elseif e.typ==2 then
  		e.t+=0.01
  		e.y=e.basey+8*sin(e.t)
  	end
		end
	end
end

function draw_enemies()
	for e in all(enemies) do
		local addy=0
		if e.typ==1 then
			addy=8
		end
		if on_screen(e.x,e.y+addy,8,8,e.typ) and not e.dead then
			if e.typ==2 then
				palt(12,true)
				palt(0,false)
				rectfill(e.x+4,e.y,e.x+4,e.y-(e.space+(e.y-e.basey)),7)
			end
			spr(19+e.typ,e.x,e.y,1,1,not e.dire)
			palt(12,false)
			palt(0,true)
		end
	end
end

function create_smoke(x,y,n,c)
	for i=1,n do
 	local s={}
 	s.x=x-5+rnd(2)
 	s.y=y-1+rnd(2)
 	s.spd={}
 	s.spd.x=-0.4+rnd(0.8)
 	s.spd.y=-0.1
 	s.sprite=16
 	s.c=c
 	add(smoke,s)
	end
end

function m_player(x,y)

	local p=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=8,
		h=8,
		
		spdx=1.2,
		max_fall_spd=2,

		jump_speed=-2.5,
		acc=0.05,
		turn_acc=0.06,
		dcc=0.2,
		air_dcc=0.05,
		grav=0.1,
		fall_grav=0.2,
		jumping=false,
		double_jump=true,
		can_double=true,
		djump_speed=-3.5,
		
		wall_slide_start=false,
		wall_sliding=false,
		wall_dcc=0.1,
		wall_grav=0.01,
		wall_spdx=1.2,
		wall_spdy=-4,
		wall_time=0,
		can_wall_time=10,
		max_wall_fall=1,
		
		gliding=false,
		glide_grav=0.05,
		glide_max_fall=0.45,
		
		inv=false,
		inv_timer=0,
		inv_time=60,
		blink_time=20,
		
		damaging=false,
		dam_timer=0,
		dam_time=10,
		
		jump_button=
		{
			update=function(self)
				if boss_phase~=9 then
 				self.pressed=false
 				if btn(4) and not pressed_t then
 					if self.ticks_down<5 then
 						self.pressed=true
 					end
 					self.is_down=true
 					self.ticks_down+=1
 				else
 					self.is_down=false
 					self.pressed=false
 					self.ticks_down=0
 				end
 			end
			end,
			stop_pressing=function(self)
				self.pressed=false
				self.ticks_down=5
			end,
			
			is_pressed=false,
			is_down=false,
			ticks_down=0,
		},

		jump_btn_released=true,
		grounded=true,

		airtime=0,
		
		anims=
		{
			["stand"]=
			{
				ticks=1,
				frames={2},
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
			["wall"]=
			{
				ticks=1,
				frames={8},
			},
			["glide"]=
			{
				ticks=1,
				frames={9},
			},
		},

		curanim="walk",
		curframe=1,
		animtick=0,
		flipx=false,
		
		set_anim=function(self,anim)
			if(anim==self.curanim)return
			local a=self.anims[anim]
			self.animtick=a.ticks
			self.curanim=anim
			self.curframe=1
		end,
		
		update=function(self)
	
			
			general_collision(self)
			
			local bl=btn(0)
			local br=btn(1)
			
			local desired = 0
			
			if boss_phase~=9 then
 			if bl then
 				desired = -1
 				br=false
 			elseif br then
 			 desired = 1
 			 bl=false
 			end
 		end
			
			local can_slide=true
			
			desired *= self.spdx
			
			if desired ~= 0 then
				if not self.wall_sliding then
   		if sgn(self.dx) ~= sgn(desired) then
   			self.dx += (desired-self.dx)*self.turn_acc
   		else
   			self.dx += (desired-self.dx)*self.acc
   		end
   	elseif sgn(desired)==toint(self.flipx) then
   		self.wall_time+=1
   		if self.wall_time>=self.can_wall_time then
   			self.wall_time=0
   			can_slide=false
   			self.wall_sliding=false
   		end
   	else
   		self.wall_time=0
   	end
 		else
 				if self.wall_sliding then
 					self.wall_time+=1
   			if self.wall_time>=self.can_wall_time then
   				self.wall_time=0
   				can_slide=false
   				self.wall_sliding=false
   			end
 				else
   			if self.grounded then
  					self.dx += (desired-self.dx)*self.dcc
  				else
  					self.dx += (desired-self.dx)*self.air_dcc
  				end
 				end
 		end

			self.x+=self.dx
			
			self.x=mid(4,self.x,1024-4)
			
			collide_side(self)
			
 		if collide_side2(self) and can_slide then
 			if -sign(desired) == toint(collided_side2) then
 				self.collide_wall_start=true
 			else
 				self.collide_wall_start=false
 			end
 		else
 			self.collide_wall_start=false
 			self.wall_sliding=false
 		end
			
			self.jump_button:update()
			
			if self.jump_button.pressed then
				local on_ground=(self.grounded or self.airtime<5)
				if on_ground then
					self.dy=self.jump_speed
					self.jumping = true
					self.jump_button:stop_pressing()
					sfx(0)
					create_smoke(self.x,self.y,1,7)
				else
					if self.wall_sliding and walljump_unlocked then
						self.dx=-self.wall_spdx
						if self.flipx then
							self.dx+=2*self.wall_spdx
						end
						self.dy=self.wall_spdy
						self.jump_button:stop_pressing()
						self.wall_sliding=false
						sfx(0)
						create_smoke(self.x-2*toint(self.flipx),self.y-4,1,7)
					elseif self.double_jump and self.can_double and double_unlocked then
						self.dy = self.djump_speed
						self.can_double=false
						self.jump_button:stop_pressing()
						sfx(0)
					end
				end
			end
			if not self.jump_button.is_down then
				self.jumping = false
				self.gliding = false
			end
			if not self.wall_sliding then
				if self.dy > 0 then
					if self.jump_button.is_down and glide_unlocked then
						self.gliding=true
					end
					if not self.gliding then
 					self.dy+=self.fall_grav
 				end
 				self.jumping=false
 			elseif not self.jumping then
 				if not self.gliding then
 					self.dy+=self.fall_grav
 				end
 				self.jumping=false
 			end
			end
			
			if not self.wall_sliding then
 			if self.gliding then
 				self.dy+=self.glide_grav
 			else
 				self.dy+=self.grav
 			end
 		else
 			if self.dy < -0.05 then
 				self.dy += (-self.dy)*self.wall_dcc
 			else
 				self.dy+=self.wall_grav
 			end
			end
			if not self.gliding then
				if self.wall_sliding then
					if self.dy > self.max_wall_fall then
   			self.dy = self.max_wall_fall
   		end
				else
  			if self.dy > self.max_fall_spd then
   			self.dy = self.max_fall_spd
   		end
   	end
  	else
  		if self.dy > self.glide_max_fall then
  			self.dy = self.glide_max_fall
  		end
 		end
			self.y+=self.dy
			
			if not collide_floor(self) then
				if self.collide_wall_start or self.wall_sliding then
					self:set_anim("wall")
					self.wall_sliding=true
					self.gliding=false
					self.flipx=collided_side
				elseif self.gliding then
					self:set_anim("glide")
				else
					self:set_anim("jump")
				end
				self.grounded=false
				self.airtime+=1
			end

			collide_roof(self)
			
			self.y=mid(0,self.y,64*8-4)
			
			if self.grounded then
				self.can_double=true
				self.gliding=false
				self.can_glide=true
				if boss_phase~=9 then
 				if br then
 					if self.dx<0 then
 						self:set_anim("slide")
 					else
 						self:set_anim("walk")
 					end
 				elseif bl then
 					if self.dx>0 then
 						self:set_anim("slide")
 					else
 						self:set_anim("walk")
 					end
 				else
 					self:set_anim("stand")
 				end
 			else
 				self:set_anim("stand")
 			end
			end
			
			if not self.wall_sliding and boss_phase~=9 then
 			if br then
 				self.flipx=false
 			elseif bl then
 				self.flipx=true
 			end
			end
			
			if self.inv then
				self.inv_timer+=1
				if self.inv_timer>=self.inv_time then
					self.inv=false
				end
			end
			
			if self.damaging then
				self.dam_timer+=1
				if self.dam_timer==1 then
					self.dy=-2
					self.dx=toint(self.flipx)*self.spdx
				end
				if self.dam_timer>self.dam_time then
					self.damaging=false
					self.dam_timer=0
					self.inv=true
					self.inv_timer=0
				end
			end
			
			if life<=0 then
				die()
				self.inv=false
				self.inv_timer=0
				life=max(1,max_life-1)
				if bossfight then
					life=max_life
				end
				self.damaging=false
			end
			
			if self.x>=102*8 and self.y>=57*8 then
				music(-1,500)
			end
			
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				local a=self.anims[self.curanim]
				self.animtick=a.ticks
				if self.curframe>#a.frames then
					self.curframe=1
				end
			end

		end,

		draw=function(self)
			palt(8,true)
			palt(0,false)
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			if self.inv then
				if flr(self.inv_timer/self.blink_time)%2~=0 then
  			spr(frame,
  				self.x-(self.w/2),
  				self.y-(self.h/2),
  				self.w/8,self.h/8,
  				self.flipx,
  				false)
 			end
 		else
 			local d=frame
 			if self.damaging then
 				d=10
 			end
 			spr(d,
 				self.x-(self.w/2),
 				self.y-(self.h/2),
 				self.w/8,self.h/8,
 				self.flipx,
 				false)
			end
			palt(8,false)
			palt(0,true)
			
			--draw life
			for i=1,max_life do
				if life>=i then
					spr(14,camx-8+10*i,camy+2)
				else
					spr(15,camx-8+10*i,camy+2)
				end
			end
		end,
	}

	return p
end

function update_cam()
	if p1.x > camx+128-h_threshold then
		camx = p1.x+h_threshold-128
	end
	if p1.x < camx+h_threshold then
		camx = p1.x-h_threshold
	end
	
	camx=max(camx,0)
	camx=min(camx,112*8+4)
	
	if p1.y > camy+128-v_threshold then
		camy = p1.y+v_threshold-128
	end
	if p1.y < camy+v_threshold then
		camy = p1.y-v_threshold
	end
	
	camy=max(camy,0)
	camy=min(camy,48*8)
end

function update_checkpoint()
	local x=(checkpoint.x-4)/8
	local y=(checkpoint.y-4)/8
	
	if mget(x,y)==85 or mget(x,y)==86 then
		checkpoint.t+=1
		if checkpoint.t>5 then
			checkpoint.t=0
			if mget(x,y)<86 then
				mset(x,y,mget(x,y)+1)
			else
				mset(x,y,84)
			end
		end
	end
end

function reset()
	win_timer=0
	deaths=0
	ticks=0
	ticks2=0
	pal()
	bg_color=0
	life=1
	max_life=1
	for i in all(orbs) do
		i.dead=false
	end
	for i in all(hearts) do
		i.dead=false
	end
end

function init()
	reset()
	for x=1,128 do
		for y=1,64 do
			if mget(x,y)==2 then
				p1=m_player((x*8)+4,(y*8)+4)
				mset(x,y,0)
				checkpoint.x=x*8+4
				checkpoint.y=y*8+4
				checkpoint.t=0
				checkpoint.collided=false
				org_x=x*8
				org_y=y*8
			elseif fget(mget(x,y),2) then
				local e={}
				if mget(x,y)==19 then
					e.typ=0
				elseif mget(x,y)==20 then
					e.typ=1
				elseif mget(x,y)==21 then
					e.typ=2
					e.basey=y*8
					for ny=y,y-10,-1 do
						if fget(mget(x,ny),0) then
							e.space=(y-ny-1)*8
							break
						end
					end
				end
				mset(x,y,0)
				e.x=x*8
				e.y=y*8
				e.ix=e.x
				e.iy=e.y
				e.dead=false
				e.dx=0
				e.dy=0
				e.t=0
				add(enemies,e)
			elseif fget(mget(x,y),4) then
				local o={}
				o.tile=mget(x,y)
				o.x=x
				o.y=y
				mset(x,y,0)
				add(objects,o)
			elseif mget(x,y)==84 then
				if menu_selection==1 or menu_selection==2 then
					mset(x,y,0)
				end
			elseif fget(mget(x,y),5) then
				local h={}
				h.x=x
				h.y=y
				h.tile=mget(x,y)
				if menu_selection<2 then
					add(hearts,h)
				end
				mset(x,y,0)
			elseif fget(mget(x,y),7) then
				local o={}
				o.x=x
				o.y=y
				o.tile=mget(x,y)
				add(orbs,o)
				mset(x,y,0)
			end
		end
	end
	p1:set_anim("walk")
end

function _init()
	for i=1,11 do
		lines[i]=flr(rnd(1)+0.5)
	end
	for i=1,22 do
		grass_deco[i]=flr(rnd(1)+0.2)
		local gd={}
		gd.x=flr(rnd(1)+0.2)
		gd.y=flr(rnd(1)+0.5)
		gd.tile=flr(rnd(1)+0.5)
		ground_deco[i]=gd
	end
end

function update_objects()
	for o in all(objects) do
		local x=o.x*8
		local y=o.y*8
		if p1.x-4>=x-8 and p1.x-4<=x+8 then
			if p1.y-4>=y-8 and p1.y-4<=y+8 then
				if o.tile>=44 and o.tile<=47 then
					p1.x=92*8
					p1.y=41*8
					sfx(2)
				elseif o.tile>=60 and o.tile<=63 then
					p1.x=30*8
					p1.y=14*8
					sfx(2)
				elseif o.tile>=56 and o.tile<=59 then
					bossfight=true
					camera(0,0)
					p1.x-=camx
					p1.y-=camy
					camx=0
					camy=0
					life=max_life
					mage.x=60
					mage.y=16
					mage.flipx=false
					mage.tile=32
					mage.dx=0
					mage.dy=0
					dtext=""
					music(4,200)
				end
			end
		end
	end
	for o in all(orbs) do
		if not o.dead then
 		local x=o.x*8
 		local y=o.y*8
 		if p1.x-4>=x-8 and p1.x-4<=x+8 then
 			if p1.y-4>=y-8 and p1.y-4<=y+8 then
 				if o.tile==94 then
 					walljump_unlocked=true
 					o.dead=true
 					create_smoke(o.x*8+4,o.y*8,2,3)
 					sfx(2)
 					music(1,100)
 					create_text("walljump unlocked",x+4,y-8)
 				elseif o.tile==78 then
 					double_unlocked=true
 					o.dead=true
 					create_smoke(o.x*8+4,o.y*8,2,8)
 					sfx(2)
 					music(2,100)
 					create_text("double jump unlocked",x+4,y-8)
 				elseif o.tile==77 then
 					glide_unlocked=true
 					o.dead=true
 					create_smoke(o.x*8+4,o.y*8,2,9)
 					sfx(2)
 					music(3,100)
 					create_text("glide unlocked",x+4,y-8)
 				end
 			end
 		end
 	end
	end
	for h in all(hearts) do
		if not h.dead then
 		local x=h.x*8
 		local y=h.y*8
 		if p1.x-4>=x-8 and p1.x-4<=x+8 then
 			if p1.y-4>=y-8 and p1.y-4<=y+8 then
 				if h.tile==14 then
 					life+=1
 					life=min(life,max_life)
 					h.dead=true
 					sfx(2)
 					create_smoke(x+4,y,1,8)
 				elseif h.tile==31 then
 					max_life+=1
 					h.dead=true
 					sfx(2)
 					create_smoke(x+4,y,1,10)
 				end
 			end
 		end
 	end
	end
end

function aim_projectile(x,y,x2,y2,spd)
	local i={}
	i.tile=49
	i.x=x
	i.y=y
	local diffx=x2-i.x-4
 local diffy=y2-i.y-4
 local len=sqrt(diffx^2+diffy^2)
	diffx/=len
 diffy/=len
 i.dx=diffx*spd
 i.dy=diffy*spd
 add(boss_objs,i)
end

function bossfight_update()
	p1:update()
	boss_timer+=1
	
	if boss_phase==9 then
		mage.x+=mage.dx
		mage.dx*=0.9
		
		mage.dy+=p1.grav+p1.fall_grav
		mage.y+=mage.dy
		
		if mage.y>112 then
			mage.y=112
		end
	end
	
	for i in all(boss_objs) do
		i.x+=i.dx
		i.y+=i.dy
		if p1.x+4>=i.x+2 and p1.x-4<=i.x+6 then
			if p1.y+4>=i.y+2 and p1.y-4<=i.y+6 then
				if not p1.inv and not p1.damaging then
 				if boss_phase~=9 then
  				life-=1
  				p1.damaging=true
  				p1.dy=p1.djump_speed
  			end
				end
			end
		end
	end
	
	if p1.x+4>=mage.x and p1.x-4<=mage.x+8 then
		if p1.y<=mage.y and p1.y>=mage.y-5 then
			if boss_hits<3 then
 			boss_hits+=1
 			p1.dy=p1.djump_speed
 			p1.jumping=false
 			p1.gliding=false
 			sfx(1)
 			if boss_hits==1 then
 				boss_phase=3
 				mage.x=-8
 				mage.y=-8
 				boss_timer=0
 			elseif boss_hits==2 then
 				boss_phase=6
 				mage.x=60
 				mage.y=16
 				boss_timer=0
 			elseif boss_hits==3 then
 				boss_phase=9
 				boss_timer=0
 				mage.tile=33
 				mage.dx=toint(mage.flipx)
 				mage.dy=p1.djump_speed
 				music(-1,500)
 			end
 		end
		end
	end
	
	if boss_phase==-1 then
		if boss_timer%5==0 and boss_timer>=30 and boss_timer<130 then
			dtext=sub("you've come...",0,(boss_timer-30)/5)
		end
		if boss_timer>=130 and boss_timer%5==0 then
			dtext=sub("bad for you",0,(boss_timer-130)/5)
		end
		if boss_timer==130 then
			dtext=""
		end
	elseif boss_phase<3 then
		local t=30
		if boss_phase==2 then
			t=40
			if p1.x>mage.x then
				mage.flipx=false
			else
				mage.flipx=true
			end
		end
 	if boss_timer%t==0 then
 		local x_=10
 		local y_=10
 		local spd=2
 		if boss_phase==1 then
 			x_=110
 		elseif boss_phase==2 then
 			x_=60
 			y_=112
 			spd=1
 		end
 		aim_projectile(x_,y_,p1.x,p1.y,spd)
 	end
 elseif boss_phase==3 then
 	if boss_timer%40==0 then
 		aim_projectile(0,boss_timer/40*8,p1.x,p1.y,1.75)
 		aim_projectile(124,boss_timer/40*8,p1.x,p1.y,1.75)
 	end
 elseif boss_phase==4 then
 	mage.x=60+50*sin(boss_timer/120%1)
 	if boss_timer%20==0 then
 		aim_projectile(mage.x,mage.y,p1.x,p1.y,1)
 	end
 	if p1.x>mage.x then
 		mage.flipx=false
 	else
 		mage.flipx=true
 	end
 elseif boss_phase==5 then
 	mage.x=60+50*sin(boss_timer/120%1)
 	if boss_timer%50==0 and boss_timer>60 then
 		aim_projectile(mage.x,mage.y,p1.x,p1.y,1)
 	end
 	if p1.x>mage.x then
 		mage.flipx=false
 	else
 		mage.flipx=true
 	end
 elseif boss_phase==6 then
 	if boss_timer%8==0 and boss_timer>30 then
 		local shoot_pos=boss_timer/8*8-64
 		if boss_timer>222 then
 			shoot_pos=128-(boss_timer-222)/8*8
 		end
 		aim_projectile(mage.x,mage.y,shoot_pos,128,2)
 	end
 elseif boss_phase==7 then
 	if boss_timer%160==0 then
 		mage.x=8
 		mage.flipx=false
 	elseif boss_timer%160==80 then
 		mage.x=112
 		mage.flipx=true
 	end
 	
 	if boss_timer%40==0 then
 		aim_projectile(mage.x,mage.y,p1.x,p1.y,2)
 	end
 elseif boss_phase==8 then
 	if p1.x>mage.x then
 		mage.flipx=false
 	else
 		mage.flipx=true
 	end
 	if boss_timer>=40 then
 		if boss_timer%40==0 then
 			aim_projectile(mage.x,mage.y,p1.x,p1.y,1.5)
 		end
 	end
 elseif boss_phase==9 then
 	if boss_timer==60 then
 		for i=1,16 do
 			pal(i,4)
 		end
 	elseif boss_timer==70 then
 		for i=1,16 do
 			pal(i,2)
 		end
 	elseif boss_timer==80 then
 		for i=1,16 do
 			pal(i,5)
 		end
 	elseif boss_timer==90 then
 		for i=1,16 do
 			pal(i,0)
 		end
 	elseif boss_timer==120 then
 		win=true
 		bossfight=false
 		pal()
 		txt_color=5
 		sfx(2)
 		gold_hearts=0
 		red_hearts=0
 		total_gold=0
 		total_red=0
 		for i in all(hearts) do
 			if i.tile==14 then
 				total_red+=1
 				if i.dead then
 					red_hearts+=1
 				end
 			else
 				total_gold+=1
 				if i.dead then
 					gold_hearts+=1
 				end
 			end
 		end
 	end
 end
	
	if boss_phase==-1 then
		if boss_timer==230 then
			boss_phase=0
			mage.x=8
			mage.y=8
			boss_timer=0
		end
	elseif boss_phase==0 then
		if boss_timer==150 then
			boss_phase=1
			mage.x=110
			mage.flipx=true
			boss_timer=0
		end
	elseif boss_phase==1 then
		if boss_timer==150 then
			boss_phase=2
			mage.x=60
			mage.y=112
			boss_timer=0
		end
	elseif boss_phase==3 then
		if boss_timer==40*16 then
			mage.x=60
			mage.y=8
			boss_phase=4
			boss_timer=0
		end
	elseif boss_phase==4 then
		if boss_timer==480 then
			mage.y=92
			boss_phase=5
			boss_timer=0
		end
	elseif boss_phase==6 then
		if boss_timer==400 then
			boss_phase=7
			boss_timer=0
			mage.x=8
 		mage.flipx=false
 		mage.y=92
		end
	elseif boss_phase==7 then
		if boss_timer==440 then
			boss_phase=8
			boss_timer=0
			mage.flipx=false
			mage.x=60
			mage.y=112
		end
	end
end

function bossfight_draw()
	for i=1,16 do
		spr(69,(i-1)*8,120)
	end
	p1:draw()
	for i in all(boss_objs) do
		spr(i.tile,i.x,i.y)
	end
	palt(0,false)
	palt(8,true)
	spr(mage.tile,mage.x,mage.y,1,1,mage.flipx)
	palt(0,true)
	palt(8,false)
	
	if boss_phase==-1 then
		print(dtext,64-2*#dtext,10,7)
	end
end

function _update60()
	if not titlescreen then
		if not exposition and not bossfight and not win then
  	ticks2+=1
  	if ticks2==60 then
  		ticks+=1
  		ticks2=0
  	end
  	p1:update()
  	update_smoke()
  	update_enemies()
  	update_cam()
  	update_checkpoint()
  	update_objects()
  	update_text()
  elseif bossfight then
  	ticks2+=1
  	if ticks2==60 then
  		ticks+=1
  		ticks2=0
  	end
  	bossfight_update()
  elseif exposition then
  	text_timer+=1
  	if text_timer%4==0 and not text_finished then
  		dtext=sub(texts[actual_text],1,text_timer/4)
  		if text_timer/4==#texts[actual_text] then
  			text_finished=true
  		end
  	end
  	if btnp(4) then
  		if text_finished then
  			if actual_text==#texts then
  				exposition=false
  				pressed_t=true
  				music(0,500)
  			end
  			actual_text+=1
  			dtext=""
  			text_timer=0
  			text_finished=false
  		else
  			dtext=texts[actual_text]
   		text_finished=true
  		end
  	end
  else
  	win_timer+=1
  	if win_timer==10 then
  		txt_color=6
  	elseif win_timer==20 then
  		txt_color=7
  	end
 	end
 else
 	scroll+=0.5
 	if scroll==16 then
 		scroll=0
 		del(lines,lines[1])
 		local l=flr(rnd(1)+0.5)
 		add(lines,l)
 		
 		del(grass_deco,grass_deco[1])
 		del(grass_deco,grass_deco[1])
 		local g1=flr(rnd(1)+0.3)
 		local g2=flr(rnd(1)+0.3)
 		add(grass_deco,g1)
 		add(grass_deco,g2)
 		
 		del(ground_deco,ground_deco[1])
 		del(ground_deco,ground_deco[1])
 		local gd1={}
			gd1.x=flr(rnd(1)+0.3)
			gd1.y=flr(rnd(1)+0.5)
			gd1.tile=flr(rnd(1)+0.5)
			local gd2={}
			gd2.x=flr(rnd(1)+0.3)
			gd2.y=flr(rnd(1)+0.5)
			gd2.tile=flr(rnd(1)+0.5)
			add(ground_deco,gd1)
			add(ground_deco,gd2)
 	end
		
		if not transition then
			if btn(4) then
 			transition=true
 			sfx(2)
 		end
 		
  	if btnp(2) then
  		menu_selection-=1
  	elseif btnp(3) then
  		menu_selection+=1
  	end
  end
 	
 	if menu_selection<0 then
 		menu_selection=#menu_options-1
 	elseif menu_selection>2 then
 		menu_selection=0
 	end
 	
 	if transition then
 		if transition_t<=60 then
  		if transition_t%7==0 then
  			if transition_t%14==0 then
  				pal(5,4)
  				bg_color=5
  				txt_color=13
  			else
  				pal(5,5)
  				bg_color=0
  				txt_color=7
  			end
  		end
  	else
  		if transition_t==65 then
  			bg_color=0
  			pal(5,7)
  			txt_color=0
  		elseif transition_t==70 then
  			pal(5,2)
  		elseif transition_t==75 then
  			pal(5,5)
  		elseif transition_t==80 then
  			pal(5,0)
  		end
  	end
 		if transition_t>90 then
 			titlescreen=false
 			init()
 			exposition=true
 		end
 		transition_t+=1
 	end
 	
 	if btnp(5) and not transition then
			show_timer = not show_timer
		end
	end
	
	if not btn(4) and pressed_t then
			pressed_t=false
	end
end

function draw_objects()
	for o in all(objects) do
		spr(o.tile-flr((ticks*60+ticks2)%20/5),o.x*8,o.y*8)
	end
	for o in all(orbs) do
		if not o.dead then
			spr(o.tile,o.x*8,o.y*8)
		end
	end
	for h in all(hearts) do
		if not h.dead then
			spr(h.tile,h.x*8,h.y*8)
		end
	end
end

function _draw()

	cls(bg_color)
	
	if not titlescreen then
		if not bossfight and not exposition and not win then
  	camera(camx, camy)
  	
  	map(0,0,0,0,128,128)
  	
  	p1:draw()
  	draw_smoke()
  	draw_enemies()
  	draw_objects()
  	draw_texts()
  	
  	if show_timer then
  		local minutes=tostr(flr(ticks/60))
 			local seconds=ticks%60
 			if seconds<10 then
 				seconds="0"..tostr(seconds)
 			else
 				seconds=tostr(seconds)
 			end
 			local t=minutes..":"..seconds
 			rect(camx+103,camy,camx+104+4*#t+3,camy+8,7)
 			rectfill(camx+104,camy+1,camx+104+4*#t+2,camy+7,0)
 			print(t,camx+106,camy+2,7)
  	end
  elseif bossfight then
  	bossfight_draw()
  	
  	if show_timer then
  		local minutes=tostr(flr(ticks/60))
 			local seconds=ticks%60
 			if seconds<10 then
 				seconds="0"..tostr(seconds)
 			else
 				seconds=tostr(seconds)
 			end
 			local t=minutes..":"..seconds
 			rect(camx+103,camy,camx+104+4*#t+3,camy+8,7)
 			rectfill(camx+104,camy+1,camx+104+4*#t+2,camy+7,0)
 			print(t,camx+106,camy+2,7)
  	end
  elseif exposition then
  	print(dtext,10,10,7)
  elseif win then
  	print("you win",64-7*2,10,txt_color)
 		local minutes=tostr(flr(ticks/60))
 		local seconds=ticks%60
 		local tenths=flr(ticks2/60*100)
 		if seconds<10 then
 			seconds="0"..tostr(seconds)
 		else
 			seconds=tostr(seconds)
 		end
 		if tenths<10 then
 			tenths="0"..tostr(tenths)
 		else
 			tenths=tostr(tenths)
 		end
 		print("time: "..minutes..":"..seconds.."."..tenths,10,18,txt_color)
 		print("deaths: "..tostr(deaths),10,26,txt_color)
 		print("got "..tostr(red_hearts).." red hearts out of "..tostr(total_red),10,34,txt_color)
 		print("got "..tostr(gold_hearts).." golden hearts out of "..tostr(total_gold),10,42,txt_color)
 	end
 else
		for i=2,10 do
			spr(71,16*(i-2)-scroll,16)
			spr(71,16*(i-2)-scroll+8,16)
			local l=lines[i]
			local spr1=69
			local spr2=69
			if lines[i-1]<lines[i] then
				spr1=65
				spr(72,16*(i-2)-scroll, 16*(1-l)+96)
				spr(75,16*(i-2)-scroll, 16*(1-l)+104)
			end
			if lines[i]>lines[i+1] then
				spr2=66
				spr(70,16*(i-2)-scroll+8, 16*(1-l)+96)
				spr(74,16*(i-2)-scroll+8, 16*(1-l)+104)
			end
			spr(spr1, 16*(i-2)-scroll, 16*(1-l)+88)
			spr(spr2, 16*(i-2)-scroll+8, 16*(1-l)+88)
			
			if grass_deco[i*2]==1 then
				spr(116,16*(i-2)-scroll,16*(1-l)+80)
			end
			if grass_deco[i*2+1]==1 then
				spr(116,16*(i-2)-scroll+8,16*(1-l)+80)
			end
			
			if ground_deco[i*2].x==1 then
				spr(81+ground_deco[i*2].tile,16*(i-2)-scroll,112+8*ground_deco[i*2].y)
			end
			if ground_deco[i*2+1].x==1 then
				spr(81+ground_deco[i*2+1].tile,16*(i-2)-scroll+8,112+8*ground_deco[i*2+1].y)
			end
		end
		
		if txt_color~=0 then
			spr(48,38,30+menu_selection*8)
		end
		
		print("dungeon of numenas",64-18*2,8)
		
		for i=1,#menu_options do
			local t=menu_options[i]
			local addx=0
			if menu_selection+1==i then
				addx=4
				print(menu_desc[i],64-2*#menu_desc[i],72,txt_color)
			end
 		print(t,44+addx,24+8*i)
		end
		
		print("press c or z to play",64-20*2,100,txt_color)
 	local text="enable"
 	if show_timer then
 		text="disable"
 	end
 	text="press x to "..text.." the timer"
 	print(text,64-#text*2,108,txt_color)
 	
 	print("by amegpo", 64-2*9,120)
 end
end
__gfx__
01234567884444888888888888888888888888888888888888888888888888888844488888444488888888880000000000000000000000000070070000700700
89abcdef844f4f8888444488888444488884444888844448888444488444488884f4f488844f4f48888888880000000000000000000000000787787007077070
00700700f4f0f0f8844f4f488844f4f48844f4f48844f4f48844f4f444f4f488880f04f884f0f088844448880000000000000000000000007888888770000007
000770008cffff8884f0f088884f0f08884f0f08884f0f08884f0f084f0f088888fff88888ffff8844f4f4880000000000000000000000007888888770000007
0007700088ccc88888ffff88888ffff8888ffff8888ffff8888ffff888fff888888ccc8891cccc884f0f08880000000000000000000000007888888770000007
007007008899188888ccc8888fcccc888fcccc888fcccc888fcccc888fcc888888811c98881cccf888fff8880000000000000000000000000788887007000070
00000000888118888f111f8889111888881998888811188888111888991188888888118881188c8888ccc9980000000000000000000000000078870000700700
000000008888998889989988889899888899888889989988889988888998888888888898988888f888f111980000000000000000000000000007700000077000
0000000000000000700000000008888800000000c888888c00000000000000000000000000000000000000000000000000000000000000000000000000700700
0070000007700700070000070088aaa800888800c808808c00000000000000000000000000000000000000000000000000000000000000000000000007977970
007770000777000000000000008a0a08888228888800008800000000000000000000000000000000000000000000000000000000000000000000000079999997
077777700770000000000000008aaaa8828228288000000800000000000000000000000000000000000000000000000000000000000000000000000079999997
077777700000700000000000008aaaa8822222288800008800000000000000000000000000000000000000000000000000000000000000000000000079999997
0077770000000770000000000888aa88882222888000000800000000000000000000000000000000000000000000000000000000000000000000000007999970
00007700000707700700007008aaa880088228808880088800000000000000000000000000000000000000000000000000000000000000000000000000799700
0000000000000000000000000888880000888800cc8888cc00000000000000000000000000000000000000000000000000000000000000000000000000077000
88111888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000770000007700000077000
88aaaa888111888800000000000000000000000000000000000000000000000000000000000000000000000000000000067cc760067cc760067cc760067cc760
811111188aaaa8880000000000000000000000000000000000000000000000000000000000000000000000000000000007cccc7007cccc7007ccc7700777cc70
86f0f08811111188000000000000000000000000000000000000000000000000000000000000000000000000000000007cc7ccc77ccc7cc77cc777c77cc77cc7
88f666886f0f0888000000000000000000000000000000000000000000000000000000000000000000000000000000007c777cc77cc77cc77ccc7cc77cc7ccc7
881166888f66688800000000000000000000000000000000000000000000000000000000000000000000000000000000077ccc7007cc777007cccc7007cccc70
81111f888816618800000000000000000000000000000000000000000000000000000000000000000000000000000000067cc760067cc760067cc760067cc760
1111118888f111180000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000770000007700000077000
00000000000000000000000000000000000000000000000000000000000000000007700000077000000770000007700000077000000770000007700000077000
0000700000000000000000000000000000000000000000000000000000000000067bb760067bb760067bb760067bb76006799760067997600679976006799760
000077000088880000000000000000000000000000000000000000000000000007bbbb7007bbbb7007bbb7700777bb7007999970079999700799977007779970
00007770008888000000000000000000000000000000000000000000000000007bb7bbb77bbb7bb77bb777b77bb77bb779979997799979977997779779977997
00007770008888000000000000000000000000000000000000000000000000007b777bb77bb77bb77bbb7bb77bb7bbb779777997799779977999799779979997
0000770000888800000000000000000000000000000000000000000000000000077bbb7007bb777007bbbb7007bbbb7007799970079977700799997007999970
0000700000000000000000000000000000000000000000000000000000000000067bb760067bb760067bb760067bb76006799760067997600679976006799760
00000000000000000000000000000000000000000000000000000000000000000007700000077000000770000007700000077000000770000007700000077000
40404040055555555555555000005555555500005555555500055555000000005555000000000000000555555555500000000000000000000000000000000000
40404040555555555555555500055555555550005555555500555555000000005555500000000000000005555550000000000000000770000007700000000000
04040404555555555555555500005555555500005555555500055555000050505555000000000000000055555555000000000000007997000078870000000000
00000000555555555555555505055555555550505055055500555555050555505555500000000005000005055050000050000000079999700788887000000000
00000000555550500505555555555555555555555005055000055555555555555555550000000505000000000000000050500000079999700788887000000000
00000000555500000000555555555555555555550000000000005555555555555555500000005555000000000000000055550000007997000078870000000000
00000000555550000005555555555555555555550000000000055555555555555555550000000555000000000000000055500000000770000007700000000000
00000000555500000000555555555550055555550000000000005555555555555555000000005555000000000000000055550000000000000000000000000000
000000000000000000000000000000000000c000000000000000000c444444444444444444444444444444440000555555550000555555550000000000000000
000000000550000000000500000000000ddcc0c00ddc0c000ddc00cc444004444440044444444044440444440000666666660000666666660007700000000000
000000000550000000000000000000000ddcccc00ddccc000ddccccc444004444400004440000004400000040000555555550000555555550073370000000000
000000000000000000000000000000000ddc1cc00ddcccc00ddcccc1440000444440044440000004400000040000666666660000666666660733337000000000
000000000000050000000000000000000dd10c100dd1c1c00dd1cc10444004444440044444444044440444445555555555555555555555550733337000000000
000000000000000000000000070707070dd001000dd010c00dd01100444444444444444444444444444444446666666666666666666666660073370000000000
000000000050000000000050575757570dd000000dd000100dd00000000440000004400000044000000440005555555555555555555555550007700000000000
000000000000000000000000777777770dd000000dd000000dd00000000440000004400000044000000440006666666666666666666666660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000500500500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000550600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000605500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000600500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a45454545454243535353535353535353535145424000000000084006477000000000077000000000000770000000000000000770000000000000000770000
000000000000770000000000008464000000007700840000000000000000006400000000000000000000000000443400000084001500000000000094747474c4
00001500000025a45454545454545454545454b40064000000000084006400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000014240000443400000000000084000000000000000000640000000000000000000000000000770000008400000000250000006400007784
25000000000000000000250000001500000000002564000000000084156400000000004100000000000000000041000000410000000000000000000000000000
00000000000000000084640000000000000000000084000000000000000000640000000000000000000000000000000000008400000000000000006400e00084
94747474747474747474747474747474747474747434000000000084006400000000000000410000000000000000000000000000000000000000000000000000
00000000000000000084640000000000000000000084000000002525000000640000000000000000000000e50000000000008400000000000000006400f10084
64770000000000770000000000000077000000000077000000000084006400f30000000000000000000000000000000000000000000000000000000000000000
00000000000000000084640000000000000000000084000000000000000000640000000000000000000000d50000000000008400250000001500006400000084
64000000000000000000000000000000000000000000000000000084006400000000000000000000000000000000000000000000000000000000000000000000
000000000000000000846400000000000000000000840015000000000000006400000047000047000000b5d5c500000047008400000000000000006400000084
640000000000000000000000000000000000000000000000d4000084006447004700000031470047003100000000000000000047310000000000000000004700
e00000474500000047846400000000a5000000000084000000000015000025a4545454545454545454545454545454545454b400000000000000006400000084
640000000000000000000000000000000000000000000000d500008425a454545424351454243514542435353535353535351454243535353535353535145454
545454545454545454b4a45454545454240000000084009474747474747474747474747474747474747474747474747474747474747474747474743400000084
6400000000004700000000000000000000000000454700b5d5c547840000000025a454b400a454b400a45454545454545454b400a45454545454545454b42500
00001500000000250000001500000025640047000084006400007700000000000077000000000000007700000000000077000000000000000077000000000084
640000000014243535353535353535353535351454545454545454b4009474747474747474747474747474747474747474747474747474747474747474747474
747474747474747474747474747474c4a45424000084256400000000000000000000000000000000000000000000000000000000000000000000000000000084
640000000084a4545454545454545454545454b42500001500000025006477000000000000770000000000000000007700000000000000000000007700000000
00000077000000000000007700000044747434000044743400000000000000000000000000000000000000000000000000000000000000000000a50000000084
64000000004474747474747474747474747474747474747474747474c46400000000000000000000000000004100000000000000000000000000004100000000
00000000000000000000000000000000007700000077000000000000000000000000000000000000000000004100000000000000000000000014542400000084
64000000000000770000000000770000000000000077000000000077846400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084006400000084
64000000000000000000000000000000000000000000000000000000846400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084156400000084
64000000000000005100000000000000000000000000000000000000846400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084006400000084
64000000000000000000000000000000000000000000000000000000846400000000314700000000004700000000000000310047000000000000004700000000
00470000000000470000e000470000004547f1008500004700a50000004700000000000047000000000000000047004700000000000047003184006400000084
64000000000000000000000000000000005100000000000000000000846400000000142435353535351454243535353535145454243535353535145454545454
542435353535351454545454545454545454545454545454545454545424353535353535145424353535353514545424353535353514545454b4376437373784
64470000e0470000000000410000000000000000000000000047000084640000000084a45454545454b425a45454545454b41500a45454545454b41500000000
15a45454545454b4002500000015000025000000002500150000001500a4545454545454b415a45454545454b42500a45454545454b437373725376437373784
a4545454542435353535353535353535353535353535353514240000846400000000447474747474747474747474747474747474747474747474747474747474
74747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474743437373744
0015000025a4545454545454545454545454545454545454b4640000846400000000000000007700000000000000000077000000000000000000000000770000
00000000007700000000000000000000770000000000000000000000007700000000000077000000000000000000770037370037373737773737377700000077
94747474747474747474747474747474747474747474747474340000846400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037373737373737373737373737373700
64770000000077000000000000770000000000007700000000770000846400000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000373737373737373737e4373737373700
64000000000000000000000000000000000000000000000000000000846400000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000003535000000000000000000000000000000000000000000353500000000000000373737370037373737d5373737373700
640000000000005100000041000000000000005100000000000000008464004500950047e0004700000000003100470000000041470000473100004100004700
3100000000000000470000003100474114240031004700470000000000004700000047000000001424000047000047003700374500473737b5d5c53700854700
6400000031004700000000000047003100000000000000004700004784a454545454545454542435353535351454243535353535145454542435353514545454
24353535353535145454545454545454b464351454545424353535353535145454545454545454b4a45454243514545454545454545454545454545454545454
64000000145454243535353535145424353535353535145454545454b49474747474747474c4a45454545454b400a45454545454b49474c4a4545454b49474c4
a4545454545454b4000000000000000000a454b4000000a4545454545454b49474747474747474747474c4a454b4947474747474747474747474747474747474
64000000841500a45454545454b425a4545454545454b49474747474743477000000000077447474747474747474747474747474743400447474747474347744
74747474747474747474747474747474747474747474747474747474747474340000770000000077000044747474347737373737373737373777373737773737
64000000447474747474747474747474747474747474743400770000000000000000510000000000007700000000000077000000007700007700000000000000
00770000000077000000000077000000000077000000007700000000007700000000000000000000000077000000000037000000000000000000000000000000
64000000007700000000000000000077000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3000000000000
64000000000000000000000000000000000000000051000000000000000000410051000000000051000041000051000041000000000000000000000000000000
000000000000000000000000510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d5000000000000
6447f100450000470000000000000000004700470000310047003147004700470000410047004700314700004700310047000000000000000051000000004745
0047e047000000000000000000000000000000510000000000005100000000005100000047000047000000004700000000f1000000000000b5d5c50000000000
a4545454545454545454243535353535351454542435145424351454542435145454545454542435145454542435145424353535353535353535353535145454
54545454542435353535353535353535353535353535353535353535353535353535353514545454545454545454545454545454545454545454545454545454
__gff__
000000000000000000000000000020000000000c0c0c00000000000000002020000000000000000000000000000000100000000000000000000000100000001002010101010101010101010101808000000101000000000000000000000080000000000000000000000000000000000001010000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
494747474747474747474747474747474747474747474747474747474747474347474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474c460000000000000000000000000000000000000000000000000000000000484648
4600770000007700000000000077000000000000000077000000000000000077000000000000007700000000000000000000000000770000000000000000000077000000000000000000000000007700000000000000007700000000000048460000000000000000000000000000000000000000000000000000000000484648
46000000000000001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048460000000000000000000000000000000000000000000000000000000000484648
4600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048460000000000000000000000000000000000000000000000000000000000484648
4600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048460e0000137400000000000074000000000074130000000000000074001f484648
46000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000484a45425341454253535353534142004000414545425353535353414253414b4648
460000000000000000000000000000000000000000000000745900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004800524a454b514a45454545454b460000004851004a45454545454b4a454b524648
4600000000000000000000000000000000000000000000004142000000000000000000001f0074000000007400000000000013000000000000000000130000740000740000000000007454005a000000000074000000000000007400000044474747474747474747474747474300000044474747474747474747474747474348
4600000000000000740000000000000000000000000000744846000000000000000000414545454545454545420000000000414545425353535353534145454545454542000000000041454542000000414545454253535353534142000077000000000000000000007700000000000000000077000000000000000077000048
4600000000000041420000000000000000000000000000414b460000000000000000004800510000000000004653535353534800004a4545454545454b00000000005146535353535348005146000000480051004a45454545454b46000000000000000000000000000000000000400000000000000000000000000000000048
46000200007400484600007400000000000000007400004800460000000000000000004800000000000000004a45454545454b005200000000000000000000520000004a45454545454b000046000000444747474747474747474c46000000000000000000000000000000000000000000000000000000000000000000000048
4a4545454545454b4a45454545454545454545454545454b0046000000000000000000480000000000000000000000000000000000000000000052000000000000000000000000000000000046000000000000770000000077004846000000000000000000000000000000000000000000000000000000000000535300000048
0000000000000000000000000000000000000000000000000046000000000000000000480000520000000000005100000000000000000000000000000000000000000000000000000000000046000000000000000000000000004846000000000054007400000000740000000000740000000000000000740013414200000048
000051000000000052000000000000005100000000000000004600000000000000000048000000000000000000000000005100000000000051000000000000000000004947474747474747474300000000000000000000000000484a4545454545454545454545454545454545454545425353535353414545454b4600000048
000000000000000000000000000000000000000000005100004600000000000000000048000051000000520000000000000000000000000000000000520000000051004600000000007700000000000000000000000000000000480000000051000000000000520000000000000051004a45454545454b005100004600000048
0000005200000000000051000000000000005100000000000046000000000000000000480000000000000000000000000000520000000000000000000000000000000046000000000000000000005800000000000000000000004800514947474747474747474747474747474747474747474747474c000000000046002f0048
0049474747474747474747474747474747474747474747474743000000000000000000444747474747474747474747474747474747474747474747474747474747474743000000000000000000004000000000000000000000004800004600000077000000000000000077000000000000007700004800520000004600007448
5246007700000000000014770000000000770000000000007700000000000000000000007700000000770000007700000000000000770000000000000077000000007700000000000000000000000000000000000000000000004800514600000000000000000000000000000000000000000000004800000000004a4545454b
00460000000000000000000000000000000000745400745a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000480000460000000000000000000000000000007400005a740000004800000051000000005200
004600000000000000000000000000000041454545454545420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000590000000000000000000000480000460000000000000000000000000000004145454542000000444747474747474747474c
0046000000001400000000000000000000485100000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000040404000004852004600000000000000000000000000000048000051460000000000770000000077000048
0046000000000000000000000000000000480000000052004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004447474300000000000000005a00000000000048520000460000000000000000000000000048
5146000000000000001400000000000000480000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000000000000004040404000000048000000460000000000000000000000000048
0046000000005700740000000000740000480000005200004600740000000074000000007400000000000000000074000000005400000000007400000000740000000000007400000000000000740000000000000000000000000000000000000000000000000000000000000048000000460000000000000000000000000048
00460000000041454545454545454545454b5200000000004a45454545454545454545454545454545454545454545454545454545454545454545454545420000000041454545420000000000414200000000000000000000740000007457000000000000000000000000000048510000460000000000740000547400000048
0046000000004447474747474747474747474747474747474747474c00510000000000510000000000000000000000000000000000000000000000005100465353535348005200465353535353484600000000000000000041454545454545420000000000000000000000000048000052465353535341454545454200000048
00460000000077000000007700000000000000770000000000007748000000000000000000000000000000520000000051000000000000000052000000004a454545454b0000004a45454545454b46000000000000000000480000005100004600000000000000000000000000480000004a454545454b000000004600000048
5146000000000000000000000000000000000000000000000000004800000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004653535353535353535348000000000000460000000000000000000000000048494747474747474747474747474300000048
0046000000000000000000000000000000000000000000000000004852000000000000005200000000510000000052000000000000510000000000005200000000000000005100000000000000004a4545454545454545454b000000000000460000000000000000000000000048460000007700000000000077000000000048
00460000000000000000000000000000000000000000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000494747474747474c0000000051000000000000000000000000460000000000000000000000000048460000000000000000000000000000000048
0046000000000000000000000000000015000000000000000000004800000000510000000000510000000000000000000000510000000052000000000000000000000051000046000000000000480000000000000052000000510052000000460000000000000000000000000048460000000074000000740000580000000048
004600740000007400000000000000000000007400000000000000480049474747474747474747474747474747474747474747474747474747474747474747474747474747474300000000000048494747474747474c00000000000000000046000000000000000000000000004846000000414545454545454545454545454b
__sfx__
0102000025751277412a7312d73131721377113370135701377010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000024651287412b7312f73133721366113370135701377010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002415528155241552815524155281550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002a7552f75534755225001f5001f5003150024500375003b500285003e50027500235001f5003f500185003c500365002d500175000150000000000000000000000000000000000000000000000000000
0110000018030180301803018031180311802018022180221a0301a0301a0301a0311a0211a0201a0221a02217030170301703017031170211702017022170221803018030180301803217030170301703017032
011000001b0301b0301b0301b0311b0211b0201b0221b0221d0301d0301d0301d0311d0211d0201d0221d0221a0301a0301a0301a0311a0211a0201a0221a0221b0301b0301b0301b0321a0301a0301a0301a032
011000001f0301f0301f0301f03020000200002000020000210302103021030210302200022000220002200023030230302303023030000000000000000000001f0301f0301f0301f03000000000000000000000
011000002403024030240302403027030270302703027030290302903029030290302603026030260302603027030270302703027030260302603026030260302403024030240302403026030260302603026030
011000000c0500c055130501305511050110550f0500f05511050110550f0500f0550e0500e0500e0500e0550c0500c055130501305511050110550f0500f05511050110550f0500f0550e0500e0500e0500e055
01100000180301803018030180351d0301d0301d0301d0351d0301d0301d0301d0351a0301a0301a0301a035180301803018030180351d0301d0301d0301d0351d0301d0301d0301d0351a0301a0301a0301a035
0110000024030240352b0302b03529030290352703027035290302903527030270352603026030260302603524030240352b0302b035290302903527030270352903029035270302703526030260302603026035
011000000c0530c0000c05300000246550000000000000000c053000000c05300000246550000000000000000c053000000c05300000246550000000000000000c053000000c0530000024655000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 04 42 43 44
03 04 05 43 44
03 04 05 06 44
03 04 05 07 44
01 08 42 43 44
00 08 09 43 44
00 08 09 0b 44
03 08 09 0a 0b
00 41 42 43 44
00 41 42 43 44
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
