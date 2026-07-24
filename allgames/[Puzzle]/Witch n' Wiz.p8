pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--witch n wiz
printh("--")
tsize=16
toff=tsize/8
st_intro=0
st_title=1
st_lvl_sel=2
st_gameplay=3
st_lvl_comp=4
move_delay=16
ml=14
cartdata("mbh_witchnwiz")
ver=4--save game version
function clr_save()
	for i=1,64 do
		dset(i,0)
	end
end
if dget(0)<ver then
	clr_save()
end
dset(0,ver)
--audio
snd=
{
	text=0,
	ok=1,
	cancel=2,
	walk=3,
	jump_on=4,
	beep=5,
	climb_up=6,
	climb_down=7,
	push=8,
	kill=9,
	fall=10,
	cobwebs=11,
	rewind=12,
	switch_char=13,
	portal=15,
	bang0=16,
	bang1=17,
	fin1=60,
	fin2=61,
}
mus=
{
	text=0,
	title=30,
	lvl_sel=47,
	p1a=3,
	p1b=18,
	p2=35,
	m_in=15,
	m_get=17,
	crd=48,
	fin3=53,
}
last_pat=-1
d,m,l=13,6,7
pal_map=
{
	{
		{0,0},
		{1,m},
		{2,d},
		{3,m},
		{4,d},
		{5,d},
		{6,d},
		{7,m},
		{8,m},
		{9,m},
		{10,l},
		{11,l},
		{12,l},
		{13,m},
		{14,l},
		{15,l},
	},
}
function n_lvl(
	min_x,min_y,
	max_x,max_y)
	return
	{
		min={ x=min_x, y=min_y },
		max={ x=max_x, y=max_y },
	}
end
levels=
{
 n_lvl(15,48,30,63),
 n_lvl(31,48,46,63),
 --1p
	n_lvl(30,0,45,15),--e
	n_lvl(118,0,127,15),
	n_lvl(0,0,15,17),--m
 n_lvl(38,16,55,31),
	n_lvl(0,16,15,31),
	n_lvl(54,16,71,31),
	n_lvl(14,30,33,49),
	n_lvl(110,28,127,43),
	n_lvl(66,0,89,19),--h
	n_lvl(88,0,119,23),
	n_lvl(34,30,63,47),
	--mp
	n_lvl(47,48,62,63),--in
	n_lvl(98,48,113,63),--e
 n_lvl(0,48,15,63),
	n_lvl(104,20,119,29),
	n_lvl(118,14,127,29),
	n_lvl(78,20,95,31),--m
	n_lvl(62,32,76,48),
 n_lvl(80,30,95,47),--h
	--2p
	n_lvl(61,48,76,63),--in
	n_lvl(96,22,105,31),--e
	n_lvl(15,0,30,15),
 n_lvl(14,14,39,31),--m
	n_lvl(44,0,67,17),
	n_lvl(0,30,15,49),
	n_lvl(96,30,111,49),
	n_lvl(112,42,127,63),--h
	--end
 n_lvl(77,48,92,63),
}
function is_obj_below(self)
	for v in all(objs) do
		if v!=self then
			if (v.x==self.x
				and v.y==self.y+toff)
				or (self.is_player and v.is_player
				and v.px==self.px
				and v.py==self.py+toff) then
				return true
			end
		end
	end
	return false
end
function is_obj_beside(self,d)
	for v in all(objs) do
		if v!=self then
			if v.x==self.x+d
				and v.y==self.y
				and not v.in_door then
				return true,v
			end
		end
	end
	return false
end
function is_obj_in_dir(self,dx,dy)
	for v in all(objs) do
		if v!=self then
			if v.x==self.x+dx
				and v.y==self.y+dy then
				return true
			end
		end
	end
	return false
end
function is_movable_side(self,d)
	for v in all(objs) do
		if v!=self and v.movable==true then
			if v.x==self.x+d and v.y==self.y then
				return true,v
			end
		end
	end
	return false,nil
end
function is_movable_above(self)
	for v in all(objs) do
		if v!=self and v.movable==true then
			if v.x==self.x and v.y==self.y-toff then
				return true,v
			end
		end
	end
	return false,nil
end
function fall_down(self,t,td)
	a,b,c,max_y=get_level_bounds()
	on_screen=
		self.y*8<max_y-16
	if not fget(t,1) then
		if not fget(td,0)
			and not fget(td,1)
			and not fget(td,2)
			and not is_obj_below(self)
			and on_screen==true then
			self.y+=toff
			self.time_since_move=0
			if not self.block_fall then
				sfx(snd.fall)
				self.block_fall=true
			end
			self:set_anim("fall")
			return true
		end
	end
	return false
end
function move_up(self,t,tu)
	if fget(t,1)
		and not fget(tu,0)
		and not is_obj_in_dir(self,0,-toff)
		then
		self.y-=toff
		self.time_since_move=0
		self:set_anim("climb_up")
		self.flip_x=false
		sfx(snd.climb_up)
		return true
	else
		return false
	end
end
function move_down(self,t,td)
	a,b,c,max_y=get_level_bounds()
	on_screen=
		self.y*8<max_y-tsize
	if on_screen
		and not fget(td,0)
		and not fget(td,2)
		and not is_obj_below(self) then
		self.y+=toff
		self.time_since_move=0
		self:set_anim("climb_down")
		sfx(snd.climb_down)
		self.flip_x=false
		return true
	else
		return false
	end
end
function move_horz(
	self,ht,flipx,dir_mod)
	can_move=not fget(ht,0)
	b,o=is_obj_beside(self,dir_mod*toff)
	if can_move and self.movable==true then
		if b then
			can_move=false
		end
		if fget(ht,1)==true then
			can_move=false
		end
	elseif b and self.is_player==true and o.is_player==true then
		can_move=false
	end
	min_x,max_x=get_level_bounds()
	can_move=can_move and
		self.x*8+dir_mod*tsize>=
		min_x and
		self.x*8+dir_mod*tsize<
		max_x
	if can_move==true then
		b,o=is_movable_side(self,dir_mod*toff)
		if b==true then
			nt=get_tile_in_horz_dir(o,dir_mod)
			if move_horz(o,nt,flipx,dir_mod) then
				self.time_since_move=0
				if fget(mget(self.x,self.y),1) then
					self:set_anim("push_climb")
					sfx(snd.push)
				else
					self:set_anim("push")
					sfx(snd.push)
				end
			end
			self.flip_x=flipx
		else
			if fget(ht,1) then
				self:set_anim("jump_ladder")
				sfx(snd.jump_on)
			elseif is_obj_beside(self,dir_mod*toff) then
				self:set_anim("punch")
				sfx(snd.kill)
			else
				self:set_anim("walk")
				sfx(snd.walk)
			end
			self.x+=dir_mod*toff
			self.time_since_move=0
			self.flip_x=flipx
		end
		return true
	end
	return false
end
function move_right(self,tr)
	return move_horz(self,tr,false,1)
end
function move_left(self,tl)
	return move_horz(self,tl,true,-1)
end
function get_tile_in_horz_dir(self,d)
	t,tl,tr=get_tiles_around(self)
	if(d<0)return tl
	if(d>0)return tr
end
function get_tiles_around(self)
	t=mget(self.x,self.y)
	tl=mget(self.x-toff,
		self.y)
	tr=mget(self.x+toff,
		self.y)
	tu=mget(self.x,
		self.y-toff)
	td=mget(self.x,
		self.y+toff)
	return t,tl,tr,tu,td
end
function clear_map_tile(x,y,id)
	for y2=0,toff-1 do
		for x2=0,toff-1 do
			mset(x+x2,y+y2,id)
		end
	end
end
function get_render_pos(self)
	lerp=self.time_since_move/move_delay
	dx=(self.x*8)-(self.px*8)
	fx=(self.px*8)+(dx*lerp)
	dy=(self.y*8)-(self.py*8)
	fy=(self.py*8)+(dy*lerp)
	return fx,fy
end
function backinquart(t,b,c,d)
	t/=d
	ts=(t)*t
	tc=ts*t
	return b+c*(-11.3475*tc*ts + 19.4475*ts*ts + -7.8*tc + 0.8*ts + -0.2*t)
end
function easeoutquint(t,b,c,d)
	t/=d;
	t-=1;
	return c*(t*t*t*t*t+1)+b;
end
function easeoutelastic(t,b,c,d)
	t/=d
	ts=(t)*t;
	tc=ts*t;
	return b+c*(33*tc*ts+-106*ts*ts+126*tc+-67*ts+15*t);
end
function printo(str,startx,
															 starty,col,
															 col_bg)
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
function printc(
	str,x,y,
	col,col_bg,
	special_chars)
	len=(#str*4)+(special_chars*3)
	startx=x-(len/2)
	starty=y-2
	printo(str,startx,starty,col,col_bg)
end
function find_players()
	p={}
	for o in all(objs) do
		if o.is_player then
			add(p,o)
		end
	end
	return p
end
function restore_copy(o)
	c=o.create(-1,-1)
	for k,v in pairs(o) do
		--don't add the create function
		if type(o)!="function" then
			c[k]=v
		end
	end
	return c
end
function new_fx_spawn_mirror_player(np)
	for i=0,8 do
		add(objs,
			new_fx_push(
				np.x*8+rnd(16),np.y*8+rnd(16)))
		add(objs,
			new_fx_kill_stars(
				np.x*8+8,np.y*8+8))
	end
end
function new_fx_char_switch(_par)
	o=new_fx(_par.x,_par.y)
	o.ticks=move_delay*3
	o.frames={0}
	o.grav=0
	o.par=_par
	o.draw=function(self)
		lerp=self.cur_tick/self.ticks
		w=toff*8*
			sin(lerp)
		rx,ry=get_render_pos(self.par)
		sspr(
			self.par.port_x*8,
			0,
			toff*8,
			toff*8,
			rx+8-(w/2),ry-18,
			w,
			toff*8,true)
	end
	return o
end
function new_fx_push(_x,_y)
	return new_fx(_x,_y)
end
function new_fx_kill(_x,_y)
	o=new_fx(_x,_y)
	o.w,o.h=8,8
	o.frames={10}
	o.ticks=move_delay/2
	o.grav=0
	o.draw=function(self)
		for y=0,1 do
			for x=0,1 do
				spr(self.frames[1],
				self.x+x*8,self.y+y*8,
				self.w/8,self.h/8,
				x>0,y>0)
			end
		end
	end
	return o
end
function new_fx_body(_x,_y,_frames,_dir)	o=new_fx(_x,_y)
	o.w,o.h=16,16
	o.frames=_frames
	o.ticks=move_delay*10
	o.dx=(rnd(1))*_dir
	o.dy=-2
	return o
end
function new_fx_kill_stars(_x,_y)
	o=new_fx(_x,_y)
	o.w,o.h=8,8
	o.frames={26,109}
	o.ticks=move_delay*(rnd(1)+0.5)
	o.dx=(rnd(2)-1)
	o.dy=(rnd(2)*-1)
	return o
end
function new_fx(_x,_y,_dx,_dy)
	if(_dx==nil)_dx=0
	if(_dy==nil)_dy=0
	return
	{
		x=_x,
		y=_y,
		dx=_dx,
		dy=_dy,
		grav=0.05,
		w=8,
		h=8,
		ticks=5,
		frames={124,125},
		cur_frame=1,
		cur_tick=0,
		flip_x=false,
		flip_y=false,
		update=function(self)
			self.cur_tick+=1
			self.x+=self.dx
			self.dy+=self.grav
			self.y+=self.dy
			if self.cur_tick>self.ticks then
				self.cur_frame+=1
				self.cur_tick=0
				if self.cur_frame>#self.frames then
					del(objs,self)
					del(hud_objs,self)
					return
				end
			end
		end,
		draw=function(self)
			spr(self.frames[self.cur_frame],
				self.x-(self.w/2),
				self.y-(self.h/2),
				self.w/8,
				self.h/8,
				self.flip_x,self.flip_y)
		end,
	}
end
function new_player(_x,_y)
	return
	{
		x=_x,
		y=_y,
		px=_x,
		py=_y,
		time_since_move=move_delay-1,
		is_player=true,
		is_clone=false,
		is_cur=false,
		in_door=false,
		block_fall=false,
		anims=
		{
			["idle"]=
			{
				ticks=0,
				frames={2},
			},
			["idle_climb"]=
			{
				ticks=0,
				frames={68},
			},
			["walk"]=
			{
				ticks=move_delay/4,
				frames={2,6,32,6},
			},
			["push"]=
			{
				ticks=0,
				frames={36},
			},
			["push_climb"]=
			{
				ticks=0,
				frames={64},
			},
			["punch"]=
			{
				ticks=move_delay/2,
				frames={96,36},
			},
			["jump_ladder"]=
			{
				ticks=move_delay/2,
				frames={32,36},
			},
			["climb_up"]=
			{
				ticks=5,
				frames={68},
			},
			["climb_down"]=
			{
				ticks=5,
				frames={68},
			},
			["fall"]=
			{
				ticks=0,
				frames={100},
			},
		},
		curanim="idle",
		curframe=1,
		animtick=0,
		flip_x=false,
		port_x=14,
		set_anim=function(self,anim)
			if(anim==self.curanim)return
			a=self.anims[anim]
			self.animtick=a.ticks
			self.curanim=anim
			self.curframe=1
		end,
		update_anim=function(self)
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				a=self.anims[self.curanim]
				self.animtick=a.ticks
				if self.curframe>#a.frames then
					self.curframe=1
				end
			end
		end,
		copy=function(self)
			return{
			create=new_player,
			x=self.x,
			y=self.y,
			px=self.px,
			py=self.py,
			is_cur=self.is_cur,
			anims=self.anims,
			curanim=self.curanim,
			curframe=self.curframe,
			animtick=self.animtick,
			flipx=self.flip_x,
			port_x=self.port_x,
			in_door=self.in_door,
			is_clone=self.is_clone,
			}
		end,
		update=function(self)
			bl,br,bu,bd=btn(0),btn(1),btn(2),btn(3)
			self.time_since_move+=1
			if self.time_since_move<move_delay then
				rx,ry=get_render_pos(self)
				if fget(mget(self.x,self.y),2) then
					o=tsize
					if(self.x<self.px)o=0
					add(objs,new_fx_push(rx+o,ry+rnd(tsize)))
					sfx(snd.cobwebs)
				end
				self:update_anim()
				return
			end
			if fget(mget(self.x,self.y),1) then
				self:set_anim("idle_climb")
			else
				self:set_anim("idle")
			end
			self.px=self.x
			self.py=self.y
			t,tl,tr,tu,td=get_tiles_around(self)
			moved=fall_down(self,t,td)
			if not moved then
				self.block_fall=false
			end
			if self.is_cur
				and not moved
				and self.time_since_move==move_delay then
				request_level_save()
			end
			if state!=st_gameplay
				or not self.is_cur
				or self.in_door then
				moved=true
			end
			if bl and not moved then
				moved=move_left(self,tl)
				self.flip_x=true
			end
			if br and not moved then
				moved=move_right(self,tr)
				self.flip_x=false
			end
			if bu and not moved then
				moved=move_up(self,t,tu)
			end
			if bd and not moved then
				moved=move_down(self,t,td)
			end
			--enemy
			for v in all(objs) do
				if v.must_kill == true and
					v.px==self.px and
					v.py==self.py then
					del(objs,v)
					cam:shake(5,2)
					for i=0,5 do
						add(objs,
							new_fx_kill_stars(
								v.x*8+tsize/2,
							 v.y*8+tsize/2))
					end
					add(objs,
						new_fx_kill(
							v.x*8,
						 v.y*8))
					add(objs,
						new_fx_body(
							v.x*8+tsize/2,
						 v.y*8+tsize/2,
						 v.anims["idle"].frames,
						 self.flip_x==true and -1 or 1))
				end
			end
			--sand
			if fget(mget(self.px,self.py),2) then
				clear_map_tile(self.px,self.py,0)
			end
			self:update_anim()
		end,
		draw=function(self)
			if self.in_door then
				return
			end
			if not self.is_cur then
				for c in all(pal_map[1]) do
					pal(c[1],c[2])
				end
			end
			if self.is_clone then
				for c=0,15 do
					nc=0
					if(c==3)nc=10
					pal(c,nc)
				end
			end
			lerp=self.time_since_move/move_delay
			dx=(self.x*8)-(self.px*8)
			fx=(self.px*8)+(dx*lerp)
			dy=(self.y*8)-(self.py*8)
			fy=(self.py*8)+(dy*lerp)
			if self.curanim=="punch" then
					fx=backinquart(
					min(lerp,1),
					self.px*8,dx,
					1)
			elseif self.curanim=="jump_ladder"then
				fx=backinquart(
					min(lerp,1),
					self.px*8,dx,
					1)
				if lerp>0.5 then
					fy-=(lerp-0.5)*6
				end
			end
			if self.curanim=="climb_up"
				or self.curanim=="climb_down"
				or self.curanim=="idle_climb" then
				fy-=2
				if self.curanim!="idle_climb" then
					fy+=sin(tick*0.1)*-1
				end
			elseif fget(mget(self.px,self.py),1) then
				fy-=2
			end
			a=self.anims[self.curanim]
			frame=a.frames[self.curframe]
			flpx=self.flip_x
			if frame<0 then
				flpx=not flpx
				frame*=-1
			end
			if self.curanim=="climb_up"
				or self.curanim=="climb_down" then
				sspr((frame%16)*8,flr((frame/16))*8,
					16,15+((tick*0.2)%2),
					fx,fy,
					16,15,
					flpx)
			else
			spr(frame,fx,fy,
				toff,toff,
				flpx,false)
			end
			if not self.is_cur
				or self.is_clone  then
				for i=0,15 do
					pal(i,i)
				end
			end
		end,
	}
end
function new_enemy(_x,_y)
	return
	{
		x=_x,
		y=_y,
		px=_x,
		py=_y,
		must_kill=true,
		floats=true,
		movable=false,
		squish=
		{
			active=false,
			frames=nil,
			ticks=0,
			cur_frame=1,
			dx=4,
			dy=4,
			update=function(self,owner)
				if self.frames!=nil then
					self.ticks+=1
					if self.ticks>30 then
						self.cur_frame=((self.cur_frame)%#(self.frames))+1
						self.ticks=0
					end
				end
			end,
			draw=function(self,fx,fy)
				frame=self:get_frame()
				if frame!=nil then
					spr(frame,fx+self.dx,fy+self.dy)
				end
			end,
			get_frame=function(self)
				if self.frames!=nil then
					return self.frames[self.cur_frame]
				else
					return nil
				end
			end,
		},
		time_since_move=move_delay-1,
		anims=
		{
			["idle"]=
			{
				ticks=30,
				frames={44,46},
			},
			["walk"]=
			{
				ticks=5,
				frames={44,46},
			},
			--todo
			["fall"]=
			{
				ticks=30,
				frames={44,46},
			},
		},
		curanim="idle",
		curframe=1,
		animtick=0,
		flip_x=false,
		set_anim=function(self,anim)
			if(anim==self.curanim)return
			a=self.anims[anim]
			self.animtick=a.ticks
			self.curanim=anim
			self.curframe=1
		end,
		update_anim=function(self)
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				a=self.anims[self.curanim]
				self.animtick=a.ticks
				if self.curframe>#a.frames then
					self.curframe=1
				end
			end
		end,
		--6k
		copy=function(self)
			return {
			create=new_enemy,
			x=self.x,
			y=self.y,
			px=self.px,
			py=self.py,
			must_kill=self.must_kill,
			floats=self.floats,
			movable=self.movable,
			anims=self.anims,
			curanim=self.curanim,
			curframe=self.curframe,
			animtick=self.animtick,
			flip_x=self.flip_x,
			squish=self.squish,
			}
		end,
		update=function(self)
			self.squish:update(self)
			self.time_since_move+=1
			if self.time_since_move<move_delay then
				self:update_anim()
				if self.time_since_move%4==0 and
					self.movable and
					self.x!=self.px then
					rx,ry=get_render_pos(self)
					add(objs,
						new_fx_push(rx+tsize,
							ry+tsize))
					add(objs,
						new_fx_push(rx,
							ry+tsize))
				end
				return
			end
			self.px=self.x
			self.py=self.y
			t,tl,tr,tu,td=get_tiles_around(self)
			if not self.floats then
				moved=fall_down(self,t,td)
			end
			if is_obj_in_dir(self,0,-toff) then
				self.squished=true
			else
				self.squished=false
			end
			self:update_anim()
		end,
		draw=function(self)
			fx,fy=get_render_pos(self)
			a=self.anims[self.curanim]
			frame=a.frames[self.curframe]
			if self.curanim=="walk"
				and self.movable==true then
				lerp=self.time_since_move/move_delay
				fx=easeoutquint(
					min(lerp,1),
					self.px*8,dx,
					1)
			end
			spr(frame,fx,fy,toff,toff)
			if self.squished==true then
				self.squish:draw(fx,fy)
			end
		end,
	}
end
function new_mirror(_x,_y)
	return
	{
		x=_x,
		y=_y,
		copy=function(self)
			return {
			create=new_mirror,
			x=self.x,
			y=self.y,
			}
		end,
		update=function(self)
			players=find_players()
			for p in all(players) do
				if p.px==self.x
					and p.py==self.y
					and p.in_door==false then
					for i=0,5 do
						add(objs,
							new_fx_kill_stars(self.x*8+8,self.y*8+8))
					end
					o=p:copy()
					np=restore_copy(o)
					np.x=np.px
					np.y=np.py
					np.y-=8
					np.py=np.y
					np.is_clone=true
					add(objs,np)
					new_fx_spawn_mirror_player(np)
					music(mus.m_get)
					sfx(-1,3)
					del(objs,self)
				end
			end
		end,
		draw=function(self)
			lerp=sin(tick*0.005)
			spr(27,
			self.x*8,
			self.y*8+lerp*4-3)
			dx=rnd(8)
			dy=rnd(8)
			c={7,12}
			line(self.x*8+dx,self.y*8+15,
				self.x*8+dx,self.y*8+8-dy,
				c[flr(rnd(#c))+1])
			draw_beam(self,1)
		end,
	}
end
function new_portal(_x,_y)
	return
	{
		x=_x,
		y=_y,
		is_door=true,
		copy=function(self)
			return {
			create=new_portal,
			x=self.x,
			y=self.y,
			}
		end,
		update=function(self)
			players=find_players()
			for p in all(players) do
				if p.px==self.x
					and p.py==self.y
					and p.in_door==false then
					p.in_door=true
					for i=0,5 do
						add(objs,
							new_fx_kill_stars(self.x*8+8,self.y*8+8))
					end
					sfx(snd.portal)
				end
			end
		end,
		draw=function(self)
			r=8
			x=self.x*8+7
			y=self.y*8+7
			circfill(
				x,
				y,
				r,0)
			circ(x,y,
				r-(tick%r),
				1)
			circ(x,y,
				r-((tick+1)%r),
				12)
			circ(x,y,
				r-((tick+2)%r),
				7)
		end,
	}
end
function new_sprite(_x,_y,_frame)
	return
	{
		x=_x,
		y=_y,
		frame=_frame,
		copy=function(self)
			return {
			create=new_sprite,
			x=self.x,
			y=self.y,
			frame=self.frame,
			}
		end,
		draw=function(self)
			spr(self.frame,self.x*8,self.y*8)
		end,
	}
end
--make 2d vector
function new_vec(x,y)
	v=
	{
		x=x,
		y=y,
		get_length=function(self)
			return sqrt(self.x^2+self.y^2)
		end,
		get_norm=function(self)
			l = self:get_length()
			return new_vec(self.x / l, self.y / l),l;
		end,
	}
	return v
end
function new_cam(target)
	c=
	{
		tar=target,
		pos=new_vec(target.x*8,target.y*8),
		pull_threshold=16,
		pos_min=new_vec(64,64),
		pos_max=new_vec(64+128,64),
		shake_remaining=0,
		shake_force=0,
		tar_off=new_vec(0,0),
		b_tick=0,
		update=function(self)
			self.b_tick+=1
			if(btn(0,1))then self.tar_off.x=max(self.tar_off.x-1,-32) self.b_tick=0
			elseif(btn(1,1))then self.tar_off.x=min(self.tar_off.x+1,32) self.b_tick=0 end
			if(btn(2,1))then self.tar_off.y=max(self.tar_off.y-1,-32) self.b_tick=0
			elseif(btn(3,1))then self.tar_off.y=min(self.tar_off.y+1,32) self.b_tick=0 end
			if self.b_tick>30 then self.tar_off.y*=0.9 self.tar_off.x*=0.9 end
			self.shake_remaining=max(0,self.shake_remaining-1)
			d=self.pos_max.x-self.pos_min.x
			if d<0 then
				d2=abs(d)*0.5
				self.pos_max.x+=d2
				self.pos_min.x-=d2
			end
			d=self.pos_max.y-self.pos_min.y
			if d<0 then
				d2=abs(d)*0.5
				self.pos_max.y+=d2
				self.pos_min.y-=d2
			end			
			px,py=get_render_pos(self.tar)
			if self:pull_max_x()<px then
				self.pos.x+=min(px-self:pull_max_x(),4)
			end
			if self:pull_min_x()>px then
				self.pos.x+=max((px-self:pull_min_x()),-4)
			end
			if self:pull_max_y()<py then
				self.pos.y+=min(py-self:pull_max_y(),4)
			end
			if self:pull_min_y()>py then
				self.pos.y+=max((py-self:pull_min_y()),-4)
			end
			--lock to edge
			if(self.pos.x<self.pos_min.x)self.pos.x=self.pos_min.x
			if(self.pos.x>self.pos_max.x)self.pos.x=self.pos_max.x
			if(self.pos.y<self.pos_min.y)self.pos.y=self.pos_min.y
			if(self.pos.y>self.pos_max.y)self.pos.y=self.pos_max.y
		end,
		draw=function() end,
		cam_pos=function(self)
			shk=new_vec(0,0)
			if self.shake_remaining>0 then
				shk.x=rnd(self.shake_force)-(self.shake_force/2)
				shk.y=rnd(self.shake_force)-(self.shake_force/2)
			end
			return self.pos.x-64+shk.x+self.tar_off.x,
				self.pos.y-64+shk.y+self.tar_off.y
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
function set_state(new_state)
	skip_lvl_sel=false
	old_state=state
	if state==st_title then
		clear_title_gfx()
		if lvl==1 then
			skip_lvl_sel=true
		end
	elseif state==st_lvl_sel then
	elseif state==st_lvl_comp then
		cam=nil
	 objs={}
	 hist={}
	 hud_objs={}
 	--reload map data
		reload(0x2000,0x2000,0x1000)
	end
 state=new_state
 tick=0
 if state==st_intro then
 	music(mus.text)
	elseif state==st_title then
		music(mus.title)
		load_title_gfx()
	elseif state==st_lvl_sel then
		if old_state!=st_title then
			music(mus.lvl_sel)
		end
		mus_played=false
		if skip_lvl_sel then
			set_state(st_gameplay)
		end
 elseif state==st_gameplay then
	 if lvl==ml then
	 	music(mus.m_in)
	 	mus_played=false
	 elseif lvl==1 then
	 	music(mus.p1a)
	 	mus_played=true
		elseif lvl==#levels then
			music(mus.crd)
			mus_played=true
	 elseif not mus_played then
	 	if lvl>11 then
	 		music(mus.p1b)
	 	else
		 	music(mus.p1a)
		 end
			mus_played=true
		end
 	srand(0)
 	lvl_tick=0
 	tick_since_rewind=99
 	p1,p2=nil,nil
 	multi=false
 	best=dget(lvl)
 	tfin=0
		for y=levels[lvl].min.y,levels[lvl].max.y  do
			for x=levels[lvl].min.x,levels[lvl].max.x do
				tile=mget(x,y)
				if tile==44 then
					e=new_enemy(x,y)
					e.squish.frames={127}
					add(objs,e)
					clear_map_tile(x,y,0)
				elseif tile==40 then
					e=new_enemy(x,y)
					e.anims["idle"].frames={40,42}
					e.anims["fall"].frames={40,42}
					e.floats=false
					e.squish.frames={126}
					e.squish.dy=0
					add(objs,e)
					clear_map_tile(x,y,0)
				elseif tile==78 then
					e=new_enemy(x,y)
					e.anims["idle"].frames={tile}
					e.anims["fall"].frames={tile}
					e.anims["walk"].frames={tile}
					e.floats=false
					e.movable=true
					e.must_kill=false
					add(objs,e)
					clear_map_tile(x,y,0)
				elseif tile==2
					or tile==4 then
					p=new_player(x,y)
					add(objs,p)
					clear_map_tile(x,y,0)
					if tile==2 then
						if(p1!=nil)p.is_clone=true
						p1=p
						p1.is_cur=true
					else
						p2=p
						for k,v in pairs(p2.anims) do
							for k2,v2 in pairs(v.frames) do
								p2.anims[k].frames[k2]+=toff
							end
						end
						p2.port_x=12
						multi=true
					end
				elseif tile==27 then
					add(objs,new_mirror(x,y))
					mset(x,y,0)
				elseif tile==10 then
					add(objs,new_portal(x,y))
					mset(x,y,0)
				elseif tile==11 then
					add(objs,new_sprite(x,y,tile))
					mset(x,y,0)
				end
			end
		end
		cam=new_cam(p1)
		cam.pos_min=new_vec(
			levels[lvl].min.x*8+64,
			levels[lvl].min.y*8+64)
		cam.pos_max=new_vec(
			(levels[lvl].max.x+1)*8-64,
			(levels[lvl].max.y+1)*8-64)
		save_level_state()
 elseif state==st_lvl_comp then
		if lvl==#levels then
			music(mus.fin3)
			tfin=0
		elseif is_new_best() then
	 	dset(lvl,lvl_tick)
	 	sfx(snd.fin2,3)
	 else
	 	sfx(snd.fin1,3)
		end
 end
end
function restart_puzzle()
	objs={}
	hud_objs={}
	hist={}
	--reload map data
	reload(0x1000, 0x1000, 0x2000)
	set_state(st_gameplay)
end
function goto_level_select()
	cam=nil
	objs={}
	hud_objs={}
	hist={}
	--reload map data
	reload(0x1000, 0x1000, 0x2000)
	set_state(st_lvl_sel)
end
function calc_time(t)
	if t==0 then
		return "--.--"
	end
	r=t%60
	if(r<10)r="0"..r
	h=flr(t/60)
	if(h<10)h="0"..h
	return h.."."..r
end
function draw_time(t)
	str="best:"..calc_time(best)
	printo(str,128-#str*4-2,2,
		7,0)
	str=calc_time(lvl_tick)
	printo("time:"..str,2,2,
		7,0)
end
function draw_scroll_text(intro,d)
	for i=1,#intro do
		s=intro[i]
		t=d*(i-1)
		if lvl_tick>t then
			t_speed=(lvl_tick-t)*0.5
			b=1
			if lvl_tick>t+d*4 then
				b=(lvl_tick*0.5)-(t+d*4)*0.5
			end
			printo(
				sub(s,b,t_speed+1),
				16,64-t_speed*0.2,
				7,0,0)
			last=sub(s,t_speed+1,t_speed+1)
		end
	end
	if last!="" then
		sfx(snd.text)
	end
end
function draw_beam(self,w)
	for c in all(pal_map[1]) do
		pal(c[1],c[2])
	end
	sspr(10*8,0,8,8,
		self.x*8,self.y*8+8,
		8*w,8,
		tick%2<1)
	for c=0,15 do
		pal(c,c)
	end
end
function request_level_save()
	request_save_count+=1
end
function store_level_save()
	t=
	{
		objs=pos_objs,
		mdata=pos_mdata,
	}
	add(hist,t)
	if #hist>100 then
		del(hist,hist[1])
	end
end
pos_objs={}
pos_mdata={}
function save_level_state()
	pos_objs={}
	for o in all(objs) do
		if o.copy!=nil then
			add(pos_objs,o:copy())
		end
	end
	pos_mdata={}
	for y=levels[lvl].min.y,levels[lvl].max.y  do
		for x=levels[lvl].min.x,levels[lvl].max.x do
			tile=mget(x,y)
			if fget(tile,2) then --sand
				add(pos_mdata,{x,y,tile})
			end
		end
	end
end
function restore_mdata(data)
	for t in all(data) do
		mset(t[1],t[2],t[3])
	end
end
function is_new_best()
	return lvl_tick<best or best==0
end
function get_level_bounds()
	l=levels[lvl]
	return l.min.x*8,
		(l.max.x+1)*8,
		l.min.y*8,
		(l.max.y+1)*8
end
function get_cur_pattern()
	for i=1,#pat_map do
		o=pat_map[i]
		p=o[1]
		match=true
		for j=2,#o do
			t=stat(14+j)
			if o[j][2]==-1 then
				if t!=-1 then
					match=false
				end
			elseif o[j][1]!=t then
				match=false
			end
		end
		if(match)return p
	end
	return -1
end
function build_pattern_map()
	pat_map={}
	for p=0,64 do
		new={p}
		found=false
		for c=0,3 do
			data=peek(0x3100+p*4+c)
	 	add(new,{band(data,63),band(data,64)!=0 and -1 or 0})
	 	found=found or band(data,64)==0
	 end
	 if found then
	 	add(pat_map,new)
	 end
	end
end
function _init()
	palt(0,false)
	palt(11,true)
	menuitem(1,
		"restart puzzle",
		restart_puzzle)
	menuitem(2,
		"select level",
		goto_level_select)
	menuitem(3,
		"!clear save data!",
		clr_save)
	build_pattern_map()
	reset()
end
function reset()
	--reload map data
	reload(0x2000, 0x2000, 0x1000)
	objs={}
	hist={}
	hud_objs={}
	tick=0
	lvl=1
	for i=1,64 do
		lvl=min(i,#levels)
		if dget(i)==0 then
			break
		end
	end
	best=0
	lvl_tick=0
	tick_since_rewind=99
	got_best=false
	mus_played=false
	tfin=0
	set_state(st_intro)
end
function _update60()
	tick+=1
	if state==st_intro then
		lvl_tick+=1
		if btnp(5) or tick>1500 then
			set_state(st_title)
			if(btnp(5))sfx(snd.ok)
		end
	elseif state==st_title then
		if btnp(5) then
			set_state(st_lvl_sel)
			sfx(snd.ok)
		end
	elseif state==st_lvl_sel then
		if btnp(0) then
			lvl=lvl-1
			if(lvl<=0)lvl=#levels
			sfx(snd.cancel)
		elseif btnp(1) then
			lvl+=1
			if(lvl>#levels)lvl=1
			sfx(snd.ok)
		elseif btnp(5) then
			set_state(st_gameplay)
			sfx(snd.ok)
		elseif btnp(4) then
			set_state(st_title)
			sfx(snd.cancel)
		end
	elseif state==st_lvl_comp then
		tfin+=1/14
		if tick%60==0 and is_new_best() then
			x,y=rnd(128),rnd(128)
			for i=0,5 do
				add(hud_objs,
					new_fx_kill_stars(x,y))
			end
			sfx(snd["bang"..flr(rnd(2))])
		end
		if (lvl==#levels and tfin>=16)
			or (lvl!=#levels and btnp(5)) then
			if lvl>=#levels then
				set_state(st_title)
			else
				lvl+=1
				set_state(st_gameplay)
				sfx(snd.ok)
			end			
		end
	elseif state==st_gameplay then
		lvl_tick+=1
		tick_since_rewind+=1
		restored=false
		if btnp(4) and #hist>=2 then
			restored=true
			--skip current pos
			del(hist,hist[#hist])
			objs={}
			for o in all(hist[#hist].objs) do
				add(objs,restore_copy(o))
			end
			restore_mdata(hist[#hist].mdata)
			--will get re-added this update
			del(hist,hist[#hist])
			tick_since_rewind=0
			sfx(snd.rewind)
		end
		--do this after restoring
		--so that we resave this frame
		save_level_state()
		players=find_players()
		if (btnp(5) and multi)
			or restored then
			for o in all(players) do
				if o.is_player then
					if not restored then
						o.is_cur=not o.is_cur
					end
					if o.is_cur then
						cam.tar=o
						if not restored then
							add(objs,
								new_fx_char_switch(o))
							sfx(snd.switch_char)
							if lvl!=#levels then
								if last_pat>=mus.p2 then
									music(last_pat-17)
								else
									music(last_pat+17)
								end
							end
						end
					end
				end
			end
		end
		lvl_com=true
		all_in_door=true
		for p in all(players) do
			all_in_door=all_in_door and p.in_door
		end
		for v in all(objs) do
			if v.must_kill==true
				or (v.is_door==true and not all_in_door) then
				lvl_com=false
				break
			end
		end
		if lvl_com then
			set_state(st_lvl_comp)
		end
	end
	request_save_count=0
	for obj in all(objs) do
		if obj.update!=nil then
			obj:update()
		end
	end
	for obj in all(hud_objs) do
		if obj.update!=nil then
			obj:update()
		end
	end
	if cam then
		cam:update()
	end

	--do all players want to save?
	players=find_players()
	if #players>0
			and request_save_count>0 then
		store_level_save()
	end
	t=get_cur_pattern()
	if t!=-1 then
		last_pat=t
	end
end
function _draw()
	cls(5)
	if lvl==2 or lvl==#levels then
		cs={[2]={0,1},[#levels]={12,7}}
		c=cs[lvl]
		pal(5,c[1])
		cls(c[1])
		d_c=function(x,y)
			circfill(x+4,y+4,4,6)
			circfill(x-4,y+2,5,6)
			circfill(x,y,6,7)
			circfill(x+6,y+2,6,7)
		end
		d_w=function(y,l,to)
			nx=128-(((tick*(l/64))+to)%(128+l))
			line(nx,y,nx+l,y,c[2])
		end
		d_c(32-lvl_tick*0.02,32)
		d_c(96-lvl_tick*0.03,64)
		d_c(128-lvl_tick*0.04,20)
		d_w(32,32,10)
		d_w(64,80,32)
		d_w(72,16,64)
		if lvl==#levels and
			state!=st_lvl_comp then
			str={"the end","art:"," nebelstern","audio:"," @gruber_music","code:"," @matthughson"}
			draw_scroll_text(str,120)
		end
	end
	if cam then
		camera(cam:cam_pos())
		map(0,0,0,0,128,128)
	else
		camera(0,0)
	end
	for v in all(objs) do
		v:draw()
	end

	--letter box for small level
	min_x,max_x,min_y,max_y=get_level_bounds()
	rectfill(min_x,min_y-64,min_x-64,max_y+64,0)
	rectfill(max_x,min_y-64,max_x+64,max_y+64,0)
	rectfill(min_x-64,min_y,max_x+64,min_y-64,0)
	rectfill(min_x-64,max_y,max_x+64,max_y+64,0)
	--------------
	--hud
	--------------
	camera(0,0)
	for obj in all(hud_objs) do
		obj:draw()
	end
	if state==st_intro then
		cls(8)
		d=120
		intro={"help...","please help me...","i am a prisoner","in the castle.","the others...     they...","...","only i remain.","","please help me...",}
		draw_scroll_text(intro,d)
	elseif state==st_title then
		--assumes title gfx loaded
		spr(0,0,0,128,128)
		fy=easeoutelastic(
					min(tick-40,60),
					128,-118,
					60)
		if tick<40 then
			fy=-118
		end
		rectfill(0,33-fy,127,33+fy,0)
		fy=easeoutelastic(
					min(tick-40,60),
					128,-118,
					60)
		if tick<40 then
			fy=-118
		end
		rectfill(0,32-fy,127,32+fy,8)
		fx=easeoutquint(
					min(tick,60),
					-64,128,
					60)
		printc("witch n' wiz",fx,32,
			7,0,0)
		if tick%120>60 then
			if tick%120==61 then
				sfx(snd.beep)
			end
			printc("press —",128-fx,96,
				7,0,1)
		end
	elseif state==st_lvl_sel then
		xd=levels[lvl].max.x-levels[lvl].min.x
		xd+=1--extra tile
		xd*=8--tile->px
		max_swing=(xd+(32))*0.5
		lerp=(sin(tick*0.001)+1)*0.5
		map(
			levels[lvl].min.x,
			levels[lvl].min.y,
			16-((lerp)*(max_swing)),
			0,
			128,128)
		fx=easeoutelastic(
					min(tick-30,30),
					0,1,
					30)
		l=40-(24*fx)
		r=40+(24*fx)
		rectfill(0,0,l,127,0)
		rectfill(r,0,127,127,0)
		for i=0,127,16 do
			rectfill(l,i,l+8,i+8,0)
			rectfill(r-8,i+8,r,i+16,0)
		end
		fy=easeoutelastic(
					min(tick,60),
					33,31,
					60)
		h=easeoutquint(
					min(tick,60),
					10,5,
					60)
		rectfill(0,fy-h+1,127,fy+h+1,0)
		rectfill(0,fy-h,127,fy+h,8)
		fx=easeoutquint(
					min(tick,60),
					-64,128,
					60)
		printc("witch n' wiz",128+fx,32,
			7,0,0)
		printc("select level",fx,60,
			7,0,0)
		printc("‹ "..lvl.." ‘",128-fx,68,
			10,0,2)
		rectfill(0,fx+32-4,127,fx+32+4,8)
		str="best: "..calc_time(dget(lvl))
		printc(str,64,fx+32,
			7,0,0)
	elseif state==st_gameplay then
		draw_time()
		fy=easeoutquint(
					min(tick,60),
					130,-10,
					60)
		if multi then
		c=btn(5) and 10 or 7
		cb=btn(5) and 9 or 0
		str="— switch"
			printo(str,
				128-(#str*4+3)-2,fy,
				c,cb)
		end
		c=btn(4) and 10 or 7
		cb=btn(4) and 9 or 0
		str="Ž undo"
		printo(str,
			2,fy,
			c,cb)
	elseif state==st_lvl_comp then
		fy=easeoutelastic(
					min(tick,60),
					0,54,
					60)
		if lvl!=#levels then
		draw_time()
		rectfill(0,fy,127,127-fy,8)
		fx=easeoutquint(
					min(tick,60),
					-64,128,
					60)
		printc("level complete!",fx,60,
			7,0,0)
		printc("press —",128-fx,68,
			7,0,1)
		rectfill(0,fx+32-4,127,fx+32+4,8)
		if is_new_best() then
			c={10,9,7}
			str="new best: "..calc_time(lvl_tick)
			printc(str,64,fx+32,
			c[(flr(tick*0.5)%#c)+1],0,0)
		else
			str="time: "..calc_time(lvl_tick)
			printc(str,64,fx+32,
			7,0,0)
		end
		else
			rectfill(0,0,127,fy*2.5,8)
			printc("thanks for playing!",64,fy,7,0,0)
		end
	end
	if tick_since_rewind<10 then
		min_y=(tick%96)
		max_y=min_y+32
		for y=min_y,max_y do
			d=sin(
				((y*cos(tick*0.1))
				+tick*2)*0.01)
				*128
			for x=abs(d),0,-1 do
				x_samp=x-cos(tick*0.1)
				pset(x,y,pget(x_samp,y))
			end
		end
	end
	if lvl==2 or lvl==#levels then
		pal(5,5)
	end
end
title=
"f51d151d151d151d151d151d151d151d15fdfd7d111e1d1e1d1e1d1e1d1e1d1e1dfefefe2ee51d151d151d151d151d151d151d151d15fdfd3d151d25211d1e1d1e1d1e1d1e1d1e1dfefefe3ed51d151d151d151d151d151d151d151d15fdfd9d111e1d1e1d1e1d1e1d1e1dfefe5e678ec51d151d151d151d151d151d151d15fdfdcd111d1e1d1e1d1e1d1e1dfefe5e175d178eb51d151d151d151d151d151d151d15fdfddd111e1d1e1d1e1d1e1dfefe5e173d379ea51d151d151d151d151d151d151d15fdfded111d1e1d1e1d1e1dfefe6e173d379e951d151d151d151d151d151d151d15fdfdfd151e1d1e1d1e1d1e1dfefe6e172d162d178e851d151d151d151d151d151d151d15fdfdfd1d111d1e1d1e1d1e1dfefe8e27262d177e751d151d151d151d151d151d151d15fdfdfd2d111e1d1e1d1e1dfefe7e171d462d177e651d151d151d151d151d151d151d15fdfdfd3d151d1e1d1e1dfefe5e371d463d177e551d151d151d151d151d151d151d15fdfdfd4d111e1d1e1dfefe3e372d251d261d25178e451d151d151d151d151d151d15fdfdfd7d151d1e1dfefe2e27151d963d276e351d151d151d151d151d151d15fdfdfd8d151e1dfefe2e171df61d15175e251d151d151d151d151d151d15fdfdfd9d151d1e1dfefe17f6461d174e151d151d151d151d151d151d15fdfdfdad151e1dfefe17f6661d173e1d151d151d151d151d151d15fdfdfdbd151dfefe17f696172e151d151d151d151d151d15fdfdfdddfefe171df6961d171e1d151d151d151d151d15fdfdfddd15fefe17f6b61517151d151d151d151d15fdfdfdfdfeee171df6b61d171d151d151d15fdfdfd6d1511257d15feee17f6c61d17151d151d15fdfdfdbd1521153d11feee17f6c61d151d151d15fdfdfddd112d2521151d1e1dfe9e171d362df6761d251d15fdfdfded115d11fede171d362df6761d151d15fdfdfdfd155d15fede171d162d2a2da62d861d25fdfdfdfd1d155d11fede1715162d2a2da62d8625fdfdfdfd2d155d15fede17151d262da62d2a2d561d25fdfdfdfd8d15fede1725262da62d2a2d5635fdfdfdfd9dfeee17151df62d6645fdfdfdfd8d15feee17251d3627962d461d4517fdfdfdfd8d15fefe17351d1687761d6517fdfdfdfd9dfefe17652d57462d7517fdfdf"..
"dfdadfefe1d17358d178d5517fdfdfdfdadfefe2d17258d168d5517fdfdfdfd9d15fefe3d17257d167d6517fdfdfdfdadfefe4d1735bd454d1517fdfdfdfd9dfefe5d27b53d254d1517fdfdfdfd9dfefe156d176597153d1517fdfdfdfd9dfefe8d1755178d273517fdfdfdfd9dfefe158d273517ad37fdfdfdfdadfeee1d11ad37fdfdfdfdfd9dfede1d1e11fdfdfdfdfdfd7dfece1d1e1d15fdfdfdfdfdfd7dfebe1d1e1d1efdfdfdfdfdfd8dfeae1d1e1d1e1d15fdfdfd5d464726fdfd7dfe9e1d1e1d1e1d1efdfdfd4d1647265726fdfd5dfe8e1d1e1d1e1d1efdfdfd4d1677166716fdfd4dfe7e1d1e1d1e1d1e1d1efdfdfd3d271667265716fdfd3dfe6e1d1e1d1e1d1e1d1e1d15fdfdfd1d16271667365716fdfd2dfe5e1d1e1d1e1d1e1d1e151e15fdfdfd1d37266716171657167d87fd1dfe4e1d1e1d1e1d1e151e151e15fdfdfd2d37266716271657166d173a57fd3e37ce1d1e1d1e1d1e151e151e151e15fdfdfd1d271629166716272647166d173a371917ed3731279e1d1e1d1e1d1e151e151e151e15fdfdfd2d161716192f671637568d173a173917bd2781177e1d1e1d1e151e151e151e151e151efded1efd3d17161e2f1667163736ad172a59178d27b1175e1d1e1d1e151e151e151e151e151e15fded3efd1d2614221f1667163726bd17191811575d27e1173e1d1e1d1e151e151e151e151e151e151efded5efd161f12142f863716bd1740176d27f121171e1d1e1d1e151e151e151e151e1547fded7edd191f12142f192e2d76bd1740175d17f151171e1d1e151e151e151e151e15173117fded161d151d1531cd8f1e1d86bd172031172d27f16114171e151e151e151e151e274117fded7510cd8f1966fd17104127f161142914171e151e151e376117fded1a1955106d323d146f1966fd1d17104120711d481d6114195a171e379117fded12152935101d14191f191244221012192f291446fd4d17c1191a1948141024198a1417b11715fded451925111d244f1d54227012fd5d17b1193a1948249a1924a11725fded75112d5f1d642250121412fd5d17911d5a58128a499117352d37fd9d3a192a252d293f942220122422fd5d17711018193a1958146a392a198117452d172227fd7d20121519551d391d12f41412fd5d1751301418191a19"..
"784a393a19147117552d17321017fd6d351945114e2012f41412fd6d177014481a193428396a198117652d1732101217fd5d251955114e10225422842d18fd6d174027582954196a198127753d175217fd4d251955104e1264121012444d2912fd7d774864125a198127953d175217fd4d151965104e101224222d10125d191a1932fd7d473148643914912017a52d27103217fd5d1975101d158d152218193a192d4412fd4d277110385410a110321017a51d17223017fd6d197511ae2442301274fd1d27b11d28241d711d3e623765374227fd7d151965119e5442a4ed17f1611032194f2e42172217152715177217fd8d1519759ef44412cd1710f11120724f2011221415202217221742103217fd8d2519658e12f43422cd174011103147308211201e2f211f22191f41922017fd9d351955117e12f43422ddb7321082111e213f211f1e4f4132203227fdad451945117d222d64122012442d10fd7d174210721e111f213f2d1f194f4130173017fdcd1a19251a45118e126d14122e12245d10fd6d2732215214191f1e1f2d6f194f5110171537fddd1012192a1935109e145d144e24fdbd17221012512014296f283f2e811745fded2530222510be22109e10223efd3d1732205120142e5f2e182f1910a11735fded9510ae429d325efd2742177110141e5f3e1f1920a11735fded9510159e2012bd207ecd172210322720611024193e291430b11725fded60211011151d9eedae9d173230171d174061c0a11725fded2e2d151d153d152d351d15fd9d151d257d2742272d17c1401930c11725fded3e1d152d152d152d111dfefe4e3d17221032172d17a13051193120911725fded4e153d151d152d152dfefe5e173230172d17b15031192130911725fded5e3d352d153dfefe4e1752172d17c1901950711735fded6e2d152d151d155dfefe2e1752172d17c1901a5061101735fded7e1d153d254d151dfefe1e174210171d17d190196041101745fded8e5d154d152dfefe1e1730271e17d1a019802755fded9e4d253d153dfefe17202237d1a01a602775fdfd6d254d151d152d155dfede176210c1b01a601785fdfd7d154d152d151d116dfece176210c1b019601785fdfd7d154d152d25116d451d251d15fd3d172210221710d1b01950111775fdfd7d114d1"..
"52d111d156d151dfeae172210271e1710a11031901a50111775fdfd7d114d152d152d254d153dfe8e1722173e171da12051601a30311775fdfd3d151d15214d152d154d153d114dfe7e375e171d814091101a1051101765fdfd7d154d158d152d155dfeee172f1e5170811951201765fdfdcd152d155d251d154d151dfece1714191e2f1ed0511941401765fdfd1db78d151d254d153dfeae17342ff05019803725fdfd27159015276d152d154d154dfe9e4724f05019a01735fddd1715d015475d11153d155dfece17f0601aa01735fddd15f0301527152d111d152d116dfeae171df0601aa01725fd8d254df06015172d152d151d118dfe8e17f0701aa01735fd9d252df07015171d153d259dfe6e171df0701aa0172511fdbd25f0801517155d159dfe5e17f0801a90151735fdcd11d03d8017156d157d151dfe4e17f0801a801d173511fdcd15503d403d9015177d156d153dfe2e17f0801970272d2511fdcd15603df010178d155d154dfe1e17f080196011173e2d15ed25bd15f0a015177d11154d154d451d154d353d171df0c041171d35fd2d259d11f030211021102115176d111d153d154d111dfe171df0701d4731176efd2d257d1510fe2e91176d152d152d114d113dee171df0201d473e1741177efd2d255d1110fe3e211e211e211e6d113d151d114d154dee271dc01d378e1731179efd1d1511153d1110fede5d154d254d155dfe2731601d27be17211017beed112d251d15101dfede4d156d153d156dfe173177de172017eecd154d25101dfeee3d157d152d158dde173117fe4e37fe2ead116d102dfeeebd151d159dce173117fefebe8d116d102dfefe1d159d25adbe171031176efdfe6e6d116d103dfefe1ead259d15be173117fd6dfe8e4d156d103dfefe2e9d151d158d152d8e1d173017fd4dfece2d156d104dfefe2e8d112d157d153d6e3d47fd1dfefe2e7d10153dfefe3e7d153d156d154d5efd3dfefe9e5d105dfefe3e6d114d254d115d6ebdfefefe1e3d10154dfefe4e5d115d253d157dfefefefe3e1d10155dfefe5e3d155d111d152d118dfefefefe3e10115dfefe6e2d155d112d151d119dfefefefe2e10156dfefe6e7d153d25adfefefefe1e10116dfefe7e155d154d15cdfefefeee1011156dfefe6e6d155d15cd351d15fdfdfd"
function hex2num(str)
	return ("0x"..str)+0
end
function load_title_gfx()
	index=0
	for i=1,#title,2 do
		count=hex2num(sub(title,i,i))
		col=hex2num(sub(title,i+1,i+1))
		for j=1,count do
		sset((index)%128,flr((index)/128),col)
		index+=1
		end
	end
end
function clear_title_gfx()
	reload(0x0,0x0,0x2000)
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end
__gfx__
0000000055dddd55bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111111bbbbbbbbbbb6677766bbbbb9bbbbbbbbbbd1bbb9aaaaaaaaaaaaa999aaaaaaaaaaaaa99
000000005d5cc5d5bbb111111bbbbbbbbbbb6677766bbbbbbb110011111bbbbbbbb677777776bbbbb99bbbbbbbd221bba666777777777769a9aa980000128999
00700700dc5cc5cdbb110011111bbbbbbbb677777776bbbbba4bbaa11111bbbbbb67777777776bbbb9a99bbbbd00201ba667777777777769a9aa889aaaa99989
000770006c5c7576ba4bbaa11111bbbbbb67777777776bbbb94b9aa81111bbbbbb77777996777bbbbb9a9bb922220222a677777776777779a998889aaaa98209
000770006c577576b94b9aa81111bbbbbb77777996777bbbbbbb9988aaaa4bbbb67777ffff6976bbbb9aa99a22221222a677767764677779a888812222110009
007007006c577576bbbb9988aaaa4bbbb67777ffff6976bbbbb048849aaa9bbbbb67794fff496bbbbb9a9aa900020222a7777d7644467769a889000000000009
000000006c5cc5c6bbb048849aaa9bbbbb67794fff496bbbbb0111111111111bbbb66f4fff49bbbbbbb9aaaa22010111a777646444446669a210000000000129
0000000056d66d65bb0111111111111bbbb66f4fff49bbbbbbbb220044402bbbbbbb99ffff9bbbbbbb9aa9aa22022222a676421114442d69a222821118881829
3b33b33bbbbbbbbbbbbb220044402bbbbbbb99ffff9bbbbbbbb20223fff32bbbbbbbb200000bbbbbbbb99bbbbbbb8eeea66de273199e34d9a128e87d1eee1819
3333333bbbbbbbbbbbb20223fff32bbbbbbbb220000bbbbbbb22004ffff4bbbbbbbb24200020bbbbbbbaabbbbbb8e7c8a664997b3ffeb9d9a129fe7d1f9f1e19
33333b3bbbbbbbbbbb22004ffff4bbbbbbbbb442002bbbbbbb22bb10000bbbbbbbbb44444942bbbb9aaaaaa9bbbecc78ad689fffffffffd9a34effffffffff19
3333b33b3bbb3bbbbb22bb10000bbbbbbbbb44444490bbbbb20bb1111410bbbbbbb244444444fbbbb9aaaa9bbbbecce8a0dd9ffffffff909a229ffff88fff939
b33b333b33b33bbbb20bb0111410bbbbbbb2244f4422bbbbb22b491111910bbbbbb44f49aa942bbbbbaaaabbbbb88882a00d49f9eeff9009a2249fffeeff9339
b3bb333bb3333bb3b22bb1490091bbbbbbb222299a942bbbbb001f1000914bbbbbb2224444422bbbbaa99aabbb82222ba000148eff941009a113349ee9413339
bbbb33bbb3333b33bb00011f0041bbbbbbb2224444422bbbbb02b0100040bbbbbbbb22222222bbbbba9bb9abb82bbbbb90022111000122099133022100001339
bbbb3bbbbb33bb3bbb0200100040bbbbbbbb00bbbb00bbbbbbbbbb0bbb0bbbbbbbbbbb0bb0bbbbbbbbbbbbbb82bbbbbb99999999999999999999999999999999
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111111bbbbbbbbb6677766bbbbbbbbbbb000000bbbbbbbbbb000000bbbbbbbbbd6bbbbbbbbbbbbbbbbbbbbbbbbbb
bbb111111bbbbbbbbbbb6677766bbbbbbbb110011111bbbbbb677777776bbbbbbbb0000000000bbbbbb0000000000bbbbbbbbdd666bbbbbbbbbdddd666bbbbbb
bb110011111bbbbbbbb677777776bbbbbba4bbaa11111bbbb67777777776bbbbbb000000000000bbbb000000000000bbbbbbbbb25d6bbbbbbbbbbb25d66bbbbb
ba4bbaa11111bbbbbb67777777776bbbbb94b9aa81111bbbb77777996777bbbbb00001a11a10000bb00000000000000bbbbbb255d66bbbbbbbbb255d6666bbbb
b94b9aa81111bbbbbb77777996777bbbbbbbb9988aaaa4bbb7777ffff6976bbbb01100000000110bb01101a11a10110bbbb6ddd666666bbbbb6ddd66666666bb
bbbb9988aaaa4bbbb67777ffff6976bbbbbb0488aaaaa9bbb67794fff496bbbb011b00000000b110011b00000000b110bb666666666666bbb66666666666666b
bbb048849aaa9bbbbb67794fff496bbbbbb0111111111111bb66f4fff49bbbbb01100010010001101110000000000111bb666666666666bbb66666666666666b
bb0111111111111bbbb66f4fff49bbbbbbbbb220444422bbbbb49ffff9bbbbbb11100110011001111100111001110011b5d66d6666d66d5b5d66d666666d66d5
bbbb220044402bbbbbbb99ffff9bbbbbbbbb20223fff32bbbbbb200000bbbbbb11101100001101111100110000110011bdd6dad66dad6ddbdd6dad6666dad6dd
bbb20223fff32bbbbbbb2000000bbbbbbbb22004ffff4bbbbbb2420002ffbbbb1d10d100001d01d11d10d100001d01d1b5d662d77d266d5b5d662dd66dd266d5
bb22004ffff4bbbbbbb2420000220fbbbbb22bb100000bbbbbb44444944fbbbbdd0bdd1111ddb0dddddcdd1111ddcdddb2d66dd77dd66d2b2d66dd7777dd66d2
bb220010000bbbbbbb2f4444944449bbbb20bb11194110bbbb2ff4444442bbbbcd1dccccccccd1dccddccccddccccddcbb5d55555555d5bbb5dd55555555dd5b
b2049111141049bbbb29444444444bbbbb22b411119010bbbb4f449aa922bbbbccbbddccccddbbccbccbdccccccdbccbbb25b225522b52bbb55b22555522b55b
b221f110009104bbbbb4449aaa942bbbbbb0090100400bbbbb2244422222bbbbbbb111dccd111bbbbbb11dccccd11bbbbbb2bbbbbbbb2bbbb2bbbbbbbbbbbb2b
bb00011000911bbbbbb2244422442bbbbbb02b010b00bbbbbbb2222bb00bbbbbbbbbddccccddbbbbbbbbdccccccdbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb02000000400bbbbbbb202bb202bbbbbbbbbbbb0bbbbbbbbbbbb0bbbbbbbbbbbbbbb1dccd1bbbbbbbbbb1dccd1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb11bbbbbbbbbbb66777766bbbbbbbbbbb11bbbbbbbbbbb66777766bbbbddddb677776bdddd5555555555555555bccccccccccccccbbdcdccccccccccdb
bbbbb011110bbbbbbbb6777777776bbbbbbbb011110bbbbbbbb6777777776bbbbbbb7bbbbbb7bbbb5ddd9dd5555d555565ddddddddddddd6ddddd9aaaa9ddddd
bb9800111100bbbbbb677777777776bbbb9800111100bbbbbb677777777776bbbbbb7bbbbbb7bbbbddd99dddddddd5d36bbbbbbbbbbbbbb63dda9ddaadd9addd
b998000a9000bbbbbb677777777776bbb998000a9000bbbbbb677777777776bbbbb6bdbbbbdb6bbbdd9a99dd5d5555556bbbbbbbbbbbbbb63d9dddd99dddd9d3
b884999a4aa94bbbbb777777777777bbb884999a4aa94bbbbb777777777777bb776dbdd66ddbd677ddaff9dd5d55555566666666666666c6d9dddda11adddd93
bb0449a99aa940bbbb676777777676bbbb0449a99aa940bbbb676777777676bbbbbb7bbbbbb7bbbbddaff9ddddddd35565ddddddddddddd63ddddd9dd9dddddd
b00011100111111bbb26676676766bbbb00011100111111bbb266767667662bbbbbb7bbbbbb7bbbbd4d99d4d555d55556bbbbbbbbbbbbbb6d9aaaaaaaaaaaa9c
bbb2111001002bbbbb4266666666bbbbbbb2111001112bbbbb426666666624bb66ddb677776bdd6654444445555d55556bbbbbbbbbbbbbb6cea2292112922aed
bbb2022222212bbbbb4000000242bbbbbbb2022222202bbbbb442000000244bbddddb677776bdddd55122155555ddddd66666666666666c6d21aaddddddaa123
bb220122221122bbbb220000229fbbbbbb220122221022bbbb242200002242bbbbbb7bbbbbb7bbbb552442555555d55565ddddddddddddd6ddd19aaddaa91ddd
bb210000000012bbbb02222224ffbbbbbb210000000012bbbb024422224420bbbbbb7bbbbbb7bbbb555445555555d5556bbbbbbbbbbbbbb6ddda12daad21add3
b20b11000011b02bbbb222224420bbbbb20b11000011b02bbbb2244224422bbb776dbdd66ddbd6775552255555553ddd6bbbbbbbbbbbbbb6dddadaa11aadadd3
b221111119f1020bbbb049aa9922b0bbb22111111111122bbbb049aaaa940bbbbbb6bdbbbbdb6bbb55555555555555d566666666666666c63daaa12dd21aaadd
bb0011111100000bbbb04422242000bbbb001111111100bbbbb0442222440bbbbbbb7bbbbbb7bbbb555555555555553565ddddddddddddd63d912dddddd219dd
bb02011100bb20bbbbbb2444bbbbbbbbbb020111111020bbbbbb24444442bbbbbbbb7bbbbbb7bbbb55555555555555556bbbbbbbbbbbbbb6dd1dddddddddd1d3
bbbbb0bbbbbbbbbbbbbbbb00bbbbbbbbbbbbb0bbbb0bbbbbbbbbbb0bb0bbbbbb66ddb677776bdd6655555555555555556bbbbbbbbbbbbbb6b21111111111112b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba411111111bbbbbbbbbb6677766bbbbb4444444422122221444444444444444420211000bbbbbbbb555d555555555555
bbb111111bbbbbbbbbbb6677766bbbbb94bb0aa1111bbbbbbbb777777777bbbb2222222200100011422222222222222221222212bbbbabbb555d555533253325
bb110011111bbbbbbbb677777776bbbbbbbb9aa81111bbbbbb77777777777bbb2222222202222022422222222222222211000011bbaaaaab553dd555dd25dd25
ba4bbaa11111bbbbbb67777777776bbbbbbb99881111bbbbb6777779967776bb000000001dddd0dd422000000000022222220222bbbaaabb55d5d55533253325
b94b9aa81111bbbbbb77777996777bbbbbbb4889aaaa4bbbb67777ffff6976bb0110011100000000422001100001042222221222bbbababb55d5d55533253325
bbbb9988aaaa4bbbb67777ffff6976bbbbb0449aaaaa9bbbbb67794fff496bbb222022224444444442201202202d042210020222bbbbbbbb55dd355533253325
bbb048849aaa9bbbbb67794fff496bbbbb0111111111111bbbbff94fff49fbbb222122222222222242201202202d042222000110bbbbbbbb555d5555dddddddd
bb0111111111111bbbb66f4fff49bbbbbbbb99004ee04bbbbbbf99ffff922bbb0001222222222222422000112110042222022220bbbbbbbb555d555522222222
bbbb220044402bbbbbb249ffff90bbbbbb22ff23fff39bbbbbb4440000022bbb422012221121042242201222222d0422bbbbbbbbbbbbbbbbb000000bddd66666
bbb20223fff32bbbbb02242000200bbb2022004efff4bbbbbbb224200922bbbb42201222222004224220011011000422bbbbbbbbbbbbbbbb0000000066666666
bb22004ffff4bbbbbbff444229229fbb22bbb1100000bbbbbbbb24444442bbbb42201000000004224220122222200422bb6776bbbbbbbbbb0000000066666666
bb2200100000bbbbbb9f4444444449bbb00bb1111411bbbbbbb24449aa942bbb42201202202d042242201dddddd10422b677777bbbb677bb0aa11aa0dd6666dd
b2049111119110bbbbb22249aa942bbbb02b011111910bbbbbb2444422442bbb42201212212d04224220000000000422b677777bbb6777bb0aa00aa0aa6666aa
b221f110009149bbbbb2224444422bbbbbbb011000900bbbbbb2222222222bbb42200011202d04224222444444444422b677766bbb677bbb000000006dd66dd6
bb00b0000000bbbbbbbb20222202bbbbbbbbb0000040bbbbbbbb222bb222bbbb42200222000104224222222222222222bbb7766bbbb66bbb001001006dd66dd6
bb02bb0bbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bbbbb0bbbbbbbbb0bbbb0bbbbb42201222222d04224222222222222222bbb66bbbbbbbbbbb0110011055555555
a6b6e60020300000e600e600e6008797e601c4d4c4d4c4d4c4d4c4d4c2d2a6868797c69782920000000000000000e4f40000c4d4c4d4c4d4c4d4c4d4c4d48797
a6b6c6c6c6c6c6c6c6c6c6c6a6b6a6b6c4d4c4d4c4d401e6a6b6c4d4c4d4e60187972030e601e4f4e600e4f440508797c4d4c4d4e4f4c4d4e4f4c4d4e4f487c6
a7b7e600213100000000e600e6008797e600c5d5c5d5c5d5c5d5c5d5c3d387c68797c6978393b5a4000000000000e5f50000c5d5c5d5c5d5c5d5c5d5c5d58797
a7b79696969696969696969687978797c5d5c5d5c5d500e6a7b7c5d5c5d50000879721310000e5f5e6b4e5f541518797c5d5c5d5e5f5c5d5e5f5c5d5e5f587c6
86b6e600e4f4c2d20000e60000008797e600c4d4000000000000b400000087c68797c697c2d200a50000000020308494000000000000000000000000c4d48797
01001000c2d2a6b68292100087978797c4d400000000e4f42030c4d4e4f4c4d48797c4d4c2d2a6b6b4b5a6b6c4d4879701e6e4f48292e6018292e601829287c6
c697e600e5f5c3d30000000000008797e600c5d5b500b5b400000000b40087c68797c697c3d300000000000021318595000000000000000000000000c5d58797
00000000c3d3a7b783930000a7b7a7b7c5d500000000e5f52131c5d5e5f5c5d58797c5d5c3d3a7b7b500a7b7c5d58797a4e6e5f58393e6a48393e6a4839387c6
c697000082928292a6b6a6b600008797e600c4d40000e4f4a4b4e4f4b50087c68797c69700b5a6b6c4d48494a6b6a6b6a6b6b400a6b6829200b5a4b4c4d48797
2030c4d4000082928494829287978797c4d4a4b48494a68686b6c4d48494c4d48797c4d40000000100b5a4b4c4d48797a5b4c2d2e4f4e6a5e4f4e6a5e4f487c6
c697000083938393a7b7a7b7000087970000c5d50000e5f5a5b5e5f5000087c68797c6970000a7b7c5d58595a7b7a7b7a7b70000879783930000a5b5c5d58797
2131c5d5000083938595839387978797c5d5a5b58595a79696b7c5d58595c5d58797c5d5b40010000000a510c5d5879711b5c3d3e5f5e6b4e5f500b4e5f587c6
96b7a6b6849484940000b400829287972030c4d400b5e4f4b4a4e4f4000087c68797c6970000000000000000e4f400b5b40000008797829200008292c4d48797
a68686b684948494c4d4a6b687978797c4d4b410c2d2a68686b6a6b610f6f6f68797c4d4a4b40000e4f400b5c4d48797c4d4b400829200b58292b4b5829287c6
c6c687978595859500000000839387972131c5d500b4e5f5b5a5e5f500b4a7968797c6970000b5a400000000e5f5000000000000a7b7839300008393c5d58797
a79696b785958595c5d5a7b787978797c5d5b500c3d3a79696b7a7b70000f6f68797c5d5a5b50011e5f51100c5d58797c5d5b500839300008393b500839387c6
c6c68797849484944050c4d4c4d4a68686b6c4d400008292a4b4829200b5e6018797c697000000a50000a6b68494c4d40000e4f4000082920000a6b6c4d48797
c2d200b5c2d2e4f4000000a686b686b6c4d4a4b50000e4f401e6e4f4c2d200f68797c4d4b400c4d4e4f4c4d4c4d48797c4d484948494849484948494849487c6
86b6a7b7859585954151c5d5c5d5a79696b7c5d5b5008393a5b583930000e6008797c697000000000000a7b78595c5d50000e5f5000083930000a7b7c5d58797
c3d30000c3d3e5f500000087c697c697c5d5a5b40000e5f50000e5f5c3d300008797c5d50000c5d5e5f5c5d5c5d58797c5d585958595859585958595859587c6
c697c2d2c2d200b5a6b6a6b6c4d4879700e6e4f40000a6b6c4d4a6b6000082928797c697c2d2849400008494c4d4c4d4a68686b60000849400000000c4d48797
2030c4d40000829200000087c697c697a6b6b500c2d2c4d4c4d4c4d40000c4d48797c4d4849482928292e600c2d2a686868686868686868686868686868686b6
c697c3d3c3d30000a7b7a7b7c5d58797b4e6e5f50000a7b7c5d5a7b7000083938797c697c3d3859500008595c5d5c5d5a79696b70000859500000000c5d58797
2131c5d50000839300001187c697c6978797b400c3d3c5d5c5d5c5d50000c5d58797c5d5859583938393e6b4c3d3a796969696969696969696969696969696b7
c697a4b48494000000e6e600c4d48797829282920000b5a4c4d4a4e6000082928797c69700000000c4d484940000000084948494000000008292c4d4a68686b6
a6b6a6b6c2d2c2d20000a6b6c697c6978797a4b420300000000000000000c4d48797c4d4b4f6a68686b6e6a4b4f687c6c697203001e6e6a4a4b4e6e6405087c6
c697a500859500000000e600c5d587978393839300b4b4a5c5d5a5e6000083938797c69700000000c5d585950000000085958595000000008393c5d5a79696b7
a7b7a7b7c3d3c3d300008797c697c6978797a5b521311100000011000011c5d58797c5d5f6f687c6c697e6a5f6f687c6c697213100e6e6a5a5b5e600415187c6
a6b600000000a6b68292829200b4a6868686868686b600b5829200e60000a686b697a6868686868686868686868686b6a68686868686868686868686868686b6
a6b6a6b60000829200008797c697c6978797b500a68686868686868686868686879701a400f687c6c697e6f6f6f687c6c697c4d400e6e6b4b500e600c4d487c6
a7b7110000b5a7b783938393000087c6c6c6c6c6c697001183931100000087c69797a7969696969696969696969696b7a79696969696969696969696969696b7
a7b7a7b7111183930000a7b796b796b7a7b71111a79696969696969696969696879700a5001187c6c6970000110087c6c697c5d5b5e6e6b50000e6b4c5d587c6
8686868686868686868686868686a7969696969696b78686868686868686a796b797000000000000000000a6868686c6c6c6c6c6c697e6e6e687c6c6c6879786
868686868686868686868687c600000000000000000000000000000000000000a686868686868686868686868686868686b6c4d4a4b4e600f6f6b4a4c4d4a686
969696969696969696969696969696969696969696969696969696969696969696b7000000000000000000a7969696969696969696b7e6e6e6a7969696879796
969696969696969696969687c600000000000000000000000000000000000000a796969696969696969696969696969696b7c5d5a5b5e6000000b5a5c5d5a796
c697c4d4b400a40000a4b501c2d287c697f6f68797e4f4879700f6f6f687c6000000000000000000000000e60187c6c697c6c6c697a4e6e6e6a487c6c6879701
00e601e601b4e600e6b40187c6000000000000000000000000000000000000000000c697010000e6e60000e6000001e68797c4d4b400e6f6f60000b5c4d487c6
c697c5d50011a5b400a50000c3d387c6970000a7b7e5f5a7b70000000087c6000000000000000000000000e60087c6c697c6c6c697a5e6e6e6a587c6c6879700
00e611e6b511e600e6b50087c6000000000000000000000000000000000000000000c697000000e6e600b4e6000000008797c5d5f60000000000f6f6c5d587c6
c697c4d4a6868686868686b6000087c697f6f600a79696b7e60000f6f687c6000000000000000000000000e60087c6c69786868686b6e6e6e6a6868686879700
00a6868686868686b6000087c6000000000000000000000000000000000000000000c69700a4b400e6a4b5e600a400008797c4d400a482920000a400c4d487c6
c697c5d5a7969696969696b7000087c697000000e60000e6000000000087c6000000000000000000001100000087c6c69796969696b7e6e6e6a7969696879700
00a6b696969696a6b6000087c6000000000000000000000000000000000000000000c69700a5b500e6a500e600a500008797c5d500a583930000a500c5d587c6
c697c4d4c4d4c4d4c4d4e600000087c697f6f6a4e6a40000a400a4f6f687c600000000000000000000e4f4000087c6c697c6c6c697a4e6e6e6a487c6c68797a4
b4879701104050879700a487c6000000000000000000000000000000000000000000c69720308292e610829210b482928797c4d400f6e4f4e4f400f6c4d487c6
c697c5d5c5d5c5d5c5d5e600f6f687c6970000a500a50000a500a5000087c600000000000000000000e5f5110087c6c697c6c6c697a5e6e6e6a587c6c68797a5
b58797b51141518797b4a587c6000000000000000000000000000000000000000000c69721318393e611839311b583938797c5d50000e5f5e5f50000c5d587c6
c69701e600b40000c4d4e600203087c697f6f60000a00000000000f6f687c600000000000000000000a68686868686c69786868686b6e600e6a6868686879700
00a7b786b6e4f48797b50087c6000000000000000000000000000000000000000000868686868686868686868686868686b6c4d4e4f48292e4f4e4f4c4d4a686
c69700e600b510b5c5d50000213187c69700000000000000000000000087c600000000000000000000a79696969696c69796969696b7e600e6a7969696879700
00a79696b7e5f5a7b7000087c6000000000000000000000000000000000000000000969696969696969696969696969696b7c5d5e5f58393e5f5e5f5c5d5a796
c69700a4c2d201a4c4d4a400a68687c697f6f6c4d4e4f4c4d40000f6f687c60000000000000000000001e601e687c6c6970000e6e601e600e601e600b5879700
0001e6c4d48494e600000087c60000000020300000405000000000a0000000000000c69701e600a4e601b4a400e601a48797c4d48292e4f4c2d28292c4d487c6
c69700a5c3d3b4a5c5d5a51187c687c6970000c5d5e5f5c5d500000000a7960000000000000000000000e600e6a796c69700b500e6a40000e6a4e60000879700
0000e6c5d58595e600000087c61100b0b02131b0b04151b0b01111b0b00000000000c69700e6b4a51000b5a5100000a58797c5d58393e5f5c3d38393c5d587c6
c69720300000b500c4d4a686868687c697c4d4a686868686b6c4d400002030203000000000e4f4000000e60000a000c697203000e6a500b1b4a500a000879720
3000e6c4d4c4d4e600a00087c6a6b6c6c6a6b6c6c6a6b6c6c6a6b6c6c60000000000c6972030b50082920000829200b48797c4d4e4f4829284948494c4d487c6
c697213111000000c5d587c6c6c687c697c5d587c6c6c6c697c5d500002131213111110011e5f50000000000000000c697213100000011001100b50000879721
3111e6c5d5c5d5e6b4000087c68797c6c68797c6c68797c6c68797c6c60000000000c6972131110083930011839311b58797c5d5e5f5839385958595c5d587c6
8686868686868686868686868686868686868686868686868686868686868686868686868686b60000a686868686868686868686868686868686868686869786
868686868686b6e6b5a68687c6868686868686868686868686868686860000000000868686868686868686868686868686868686868686868686868686868686
86c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c697000087c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c697c6
c6c6c6c6c6c697111187c687c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c60000000000c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000080800000808000000000000000000000808000008080000000000000000000000404000002020808000000000000000004040000020208080000000000000000010101010100000000000000000000000101010100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
6c796c6c6c6c6c6c6c6c6c6c6c6c78796c6c6c6c6c6c6c6c786c6c6c6c6c78796c6c6c6c6c6c6c6c6c6c6c6c786c6a6b6c6c6c6c6c6c6c6c6c6c6c6c786c6c6c6c6c6c6c786c6c796c6c6c6c6c6c786c6c6c6c6c6c6c6c6c78796c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c7879686868686868786c
6c7969696969696969696969696978796969696969696969786c6c6c6c6c7879696969696969696969696969786c7a7b696969696969696969696969786c6c6c6c6c6c6c786c6c79696969696969786c6c6c6c6c6c6c6c6c7879696969696969696969696969696969696969696969696969696969697879696969696969786c
6c7900102c2d02034849004a001078794b1000106e006e4b786c6c6c6c6c78794b10006e00000010006e00106a6b04054c4d4a004e4f000000000000786c6c6c6c6c6c6c786c6c7900002c2d0000786c6c6c6c6c6c6c6c6c7879000000002c2d4e4f6a6b000000002c2d00000000000000002c2d00007879106e4a106e4a786c
6c7900003c3d12135859005a000078795b0000006e006e007a696969696978790000006e00000000006e00007a7b14155c5d5a005e5f00005b4b5b00786c6c6c6c6c6c6c7a69697b00003c3d6f007a6969696969696969697879000000003c3d5e5f7a7b000000003c3d00000000000000003c3d00007879006e5a00005a786a
6c7900006a6868686868686b4c4d787900004a006e006e4a000000004a10787900004a6e00004a00006e4a00786c6a6b00004e4f6a6b0000005b6a68686868686868686b000000004c4d00006f00786c6c6c6c7900005b4b78794c4d6a6b4c4d282900004a00000000006a68686b4c4d6a6b0000004a78794b6e28292829787a
6c7900007a6969696969697b5c5d787900005a0000006e5a004b00005a4b78796f6f5a0000005a4b106e5a00786c7a7b4a005e5f787900000000786c6c6c6c6c6c6c6c79000000005c5d000000007a696969697b0000000078795c5d7a7b5c5d383900005a00000000007a69697b5c5d7a7b0000005a78795b1138393839786c
6c794b0010004e4f005b4b004c4d78795b4b000000006e0028290000005b7879000000004e4f005b006e5b00786c78795a002829787900000000786c6c6c6c6c6c6c6c794c4d2829000000002c2d6f6f4e4f005b4a4b000078794c4d005b4b0028290000000000000000000000004c4d28290000000078794c4d6a6b4e4f786c
6c795b0000005e5f11004b005c5d7879005b00004b006e5b3839000000007879000000115e5f5b014b6e6f6f786c7879000038397879000000007a69696969696969697b5c5d3839000000003c3d00005e5f00005a00000078795c5d0000000038390000000000000000000000005c5d38390000000078795c5d7a7b5e5f786a
6c7900002c2d4c4d6a68686b4c4d78792c2d4e4f5b006e0048490000040578794c4d6a68686b004b5b6e0000786c78794c4d6a6b78794b0000002c2d0000786c6c6c6c794c4d6a6b00006a6b000000004e4f00000000282978796a6b4c4d6a6868686868686b4c4d6a68686b4b5b005b6a68686b4c4d78794c4d4e4f4e4f787a
6c7900003c3d5c5d7a69697b5c5d78793c3d5e5f0000000058590000141578795c5d7a69697b005b00004b5b786c78795c5d78797a7b5b0000003c3d00007a696969697b5c5d7a7b00007a7b000000005e5f00000000383978797a7b5c5d7a6969696969697b5c5d7a69697b000000007a69697b5c5d78795c5d5e5f5e5f786c
6c79282948494c4d4a0010004e4f7879020348494c4d0000000028296a6b78794c4d1000020300002829004b786c78794c4d78795b6e00004c4d2c2d00004e4f006e78794c4d0000000000002829000028294c4d4e4f6a68686b00004c4d6a6b4a4b000000004c4d0000004a00000000000000004c4d78794c4d02032829786c
6c79383958595c5d5a0000005e5f7879121358595c5d1100000038397a7b78795c5d000012134b0038391100786c78795c5d7879006e005b5c5d3c3d00005e5f000078795c5d0000000000003839000038395c5d5e5f786c6c7900005c5d7a7b5a00000000005c5d0000005a00000000000000005c5d78795c5d12133839786a
6c792c2d4a004c4d4e4f00002c2d78796868686868686a6b4b006a6b6868787968686868686b5b006a686868786c6a6b4c4d6a6b0000484900000000000028292829787900004c4d4e4f00006a6b4c4d6a6b00004e4f786c6c794c4d6a6b0000000000004e4f02034e4f0000000000004e4f4c4d6a68686b4c4d28294849787a
6c793c3d5a005c5d5e5f11003c3d78796c6c6c6c6c6c7a7b115b7a7b6c6c78796c6c6c6c6c791100786c6c6c786c7a7b5c5d7a7b00005859000000005b0038393839787900005c5d5e5f00007a7b5c5d7a7b00005e5f786c6c795c5d7a7b0000000000005e5f12135e5f0000000000005e5f5c5d786c6c795c5d38395859786c
6c79686b00004c4d6a686868686878796c6c6c6c6c6c6c6c6a6b6c6c6c6c6a686868686868686868686868686a6b02034c4d00004c4d6a6b00006a6b00006a6b6868686b4c4d4849484900006e004c4d006e00002829786c6c794c4d000000006a686868686b4c4d48496a68686b00006a6b4c4d786c6c79686868686868786c
6c796c7911005c5d786c6c6c6c6c787969696969696969697a7b69696969786c6c6c6c6c6c6c6c6c6c6c6c6c7a7b12135c5d00005c5d7a7b00007a7b00007a7b6c6c6c795c5d5859585900006e005c5d000000003839786c6c795c5d000000007a696969697b5c5d58597a69697b00007a7b5c5d786c6c79696969696969786c
6c79686868686868686868686868787928296a6b04056a686868686b2829786c6c6c6c6c6c6c6c6c6c6c6c6c6c796a6b6868686868686a6868686868686868686868686868686868686b4c4d0000020300004c4d6a686868686b4c4d282900005b4b5b4b000000000000005b4b00282900004c4d786c697b78794b6e78797a69
6c79696969696969696969696969787938397a7b14157a696969697b38397a69696969696969696969696969697b7a7b6969696969697a6969696969696969696969696969696969697b5c5d0000121300005c5d7a696969697b5c5d383900000000000000000000000000000000383900005c5d786c796978795b6e78796969
6c792c2d005b282910004e4f4b10787948496e004e4f005b6a6b2c2d4849005b4a4b0000282978794a4b2c2d02034e4f6e004e4f004b786c6c6c6c6c6c794e4f2829786c6c6c6c6c6c6c6a68686868686868686b6c6c6c6c6c794c4d282900000000000000006a68686b00006a6868686868686868686b4a78794e4f78794a78
6c793c3d0000383900005e5f005b7879585900005e5f00007a7b3c3d585900005a000000383978795a003c3d12135e5f00005e5f5b007a6969696969697b5e5f38397a696969696969697a69696969696969697b69696969697b5c5d38390000000000000000786c6c790000786c6c6c6c6c6c6c6c6c795a78795e5f7a7b5a78
6c794c4d4c4d4e4f48492c2d4c4d787900006a6b4e4f6a68686b282948494c4d6a6b28296a686868686b00004c4d4c4d4c4d2c2d4c4d78796e002c2d6e0048490203006e2c2d787928290000282978794e4f4e4f4e4f104a6a686868686b4a00282900002829786c6c796a6b786c6c6c6c6c6c6c6c6c796b78794e4f4e4f6a68
6c795c5d5c5d5e5f58593c3d5c5d78794a4b7a7b5e5f7a69697b383958595c5d7a7b38397a696969697b00005c5d5c5d5c5d3c3d5c5d787900003c3d6e0058591213006e3c3d787938394b00383978795e5f5e5f5e5f4b5a786c6c6c6c795a003839000038397a69697b7a7b7a6969696969696969697b7978795e5f5e5f7a69
6c794c4d00002829005b4e4f4c4d78795a000000484900005b4b6a6b28294c4d00004849005b78792c2d4849005b4b004c4d00004c4d78794c4d28296e006a68686b4c4d005b78794e4f5b004e4f78794e4f02034e4f5b6f6a686868686868686b6b68686868686878786c794e4f786c6c6c6c6c6c6c79797879282948490203
6c795c5d0000383900005e5f5c5d7879000000005859000000007a7b38395c5d00005859000078793c3d5859000000005c5d00005c5d78795c5d383900007a696c795c5d000078795e5f00005e5f78795e5f12135e5f6f6f7a696969696969697b79696969696969787a697b5e5f7a696969696969697b797a7b383958591213
6c794c4d4e4f4c4d4c4d4e4f000078794c4d4e4f6a68686b00006e006a68686b4c4d4a004c4d78794b5b4b004c4d6a6b000048494c4d787900006a6b00004e4f78794c4d6a68686b4e4f6a6b4e4f78796868686b2c2d4b00106e2c2d6e1078796c79104a4e4f0405787902034e4f4b104b4a5b102c2d787928294e4f6a6b4c4d
6c795c5d5e5f5c5d5c5d5e5f000078795c5d5e5f7a69697b00006e007a69697b5c5d5a005c5d7879000000005c5d7a7b000058595c5d78794a4b7a7b5b4a5e5f7a7b5c5d7a69697b5e5f7a7b5e5f78796969697b3c3d0000006e3c3d6e4b7879697b5b5a5e5f1415787912135e5f5b5b015a4b5b3c3d787938395e5f7a7b5c5d
6c794c4d48494b00020348494c4d78794c4d2c2d5b4b006e000000006e002c2d2c2d2c2d4c4d78796a6b484900006e004e4f0000282978795a002c2d005a28296e004c4d6e0078792829006e2829787910006e104b00004b00002c2d6e5b787928294b4b02032c2d78792c2d2829282928292829020378794849282902034c4d
6c795c5d58590000121358595c5d78795c5d3c3d4a000000005b4b006e003c3d3c3d3c3d5c5d78797a7b5859000000005e5f00003839787900003c3d000038396e005c5d006f787938390000383978796f4a6e0000004a5b00003c3d6e6f787938394a5b12133c3d78793c3d3839383938393839121378795859383912135c5d
6c794c4d00006a68686b00004c4d78794c4d02035a004c4d6a6b00006e00004b5b4b00004c4d7879282900006a686868686b005b6a6878796a6b6f004c4d484948496a6b006f78792829000028297879005a5b004c4d5a0002034b00282978796a6b5a5b6a6b4b5b786a6868686868686868686868686b79004a6a6868686868
6c795c5d115b7a69697b11005c5d78795c5d121300005c5d7a7b000000000000000000005c5d7879383900007a696969697b0000786c78797a7b00005c5d585958597a7b000078793839000038397879110011005c5d110012135b11383978797879111178795b117a786c6c6c6c6c6c6c6c6c6c6c6c797b4b5a7a6969696969
6c796a6b6a68686b6a68686b6a6b7879686868686868686868686868686868686a6b686b68686868686868686868686868686868686868686868686868686a6b6868686868686868686868686868686b686868686868686868686868686878797879686868686868686868686868786c6c796f6f6f1002035b006f6f6f6f786c
6c797a7b7a69697b7a69697b7a7b78796c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c78796c79696969696969696969696969696969696969696969696969696978796c6c6c6c6c6c6c6c6c6c6c6c6c6c6c7969696969696969696969696969697a7b78796969696969696969696969697a69697b110000001213000010110000786c
__sfx__
01010000352103751534100371003f10039100331001f1001f1001f1001f100231002a10034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000260452b035300253000500703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
01040000240451f0351a125150050070300703007030070330006300062b005260050070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
010400000c143161050c1050c10309133180001800037000160001b000230002b000320003b0002b0001800020000000002c00032000390003800014000050000a000120001e000250002d000030000000000000
010300000c7500f041130311312500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000360143651536710367150f0010d7010b00109701070010570103001017010100109701030010070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010400002612527515271000000027105271252851528100281002710100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002651525125271000000027105255152412528100281002710100000000000000026105270050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000161004611066110a6110c61113621176211d6201d6201d61500600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010300000c343236450933520621063311b6210432116611023210f611013110a6110361104601036010260101601016000460103601026010160101600016010160004601036010260101601016000160101600
010500001403012731100310e7310c021097210301100000007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
01020000106240f7240e6240d7240c6240b7240a62409724096040870407604067040560405704046040370400604006040060400604006040060400604006040060400604006040060400604006040060400604
0103000024566000002555600000245462550624537255270c7340c7340c7340c7340c7440c7440c7540c7540c0640c0640c0640c0540c0540c0540c0440c0440c0340c7340c7340c7240c7240c7240c7140c715
010200003201432514350143551439014395143c0143c5140c7000c7000c7000c7000c7000c7000c7000c7000c0000c0000c0000c0000c0000c0000c0000c0000c0000c7000c7000c7000c7000c7000c7000c700
0103000029633266352372325615227232461520713216151c7131f615197131b61515713146150f7130e6150c7130a6150871306615047130361502713016150171308703066050470303605027030160501703
010300002d630266311f6311862115621116210d6210a6110861105611026151b60515703146050f7030e6050c7030a6050870306605047030360502703016050170308703066050470303605027030160501703
000300002d6300f3131f6310c31115621083110d62105311086110231102610026100261002615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002b6300c3131e6310a31114621073110b62104311066110231102610016100161500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011c00000552505025051150572524714050250551505025055350502505725051151851605025055150502505525050250511505725207160502505515050250553505025057250511518516050250551505025
011c000000533000230f7100f7200f7100f715005231871600533000230c7100c7200c71000523115140051300533000230f7100f7200f7100f71500523187160053300023117101172011710005231151400513
010e00000212002525095451552502120025251552515725021200e525095451552502120025251552509545021201a52509545155250212002525155160954502120025250954515525021200e516155452d715
010e00000e1151a0150e7150e1151a0150e7151a1150e0150e7150e1151a0150e7151a1150e0151a7151a1150e0151a7150e1150e0151a7150e1151a0150e7150e1150e0151a7150e1151a0150e7151a1151a015
010e00002052523525205202c0152052523525205202051220512205122c0151e5252052523525205202c015205252352520520205102c712205122c01528515275252851527515285252752525516235151e525
010e00000212002525095451552502120025251552515725021200e5250954515525021200252515526095450612006525015450d52506120065250d5260d5450612012525015450d52506120125260d54501715
010e0000205252352525520317102551231015205002c5252a5252c5152a5152c5162a5252851527515255252052523525205202c0152052523525255202551025510310151e715121151e015127151e1151e015
010e00002552523515255252351525525235152552523515205251e515205251e515205251e515205252351528525275152852527515285252751528525275152c5252a5152c5252a5152c5252a5152c5252f515
010e00002c5252a5152c5152f5252c5252a5152c5152f5252852527515285152c5252852527515285152c525255252351525515285252552523515255152852527525255152351521515205251e5151c5161b515
010e000007120075250e5450e52507120075250e5250e72504120045250b5450b525041200b525105351754504130041220411502130021300212202122021151053010522105150e5300e5300e5220e5220e515
010e000025520255222551523525255252852525525235252052020510205102c5151b51520525275252c5251f51020521205251e5201e5201e716277162c71637010380113801536010360102a7163371638716
010e000009125041250b5250d5150b125061250d5250f51509125041250b12506125000000b1150b1250b135091250412517525195150b12506125195251b51509125041250b1250612533711061150612506135
010e00000d5300d5250d5250f5350f5300f5250f525115150d5300d5250f5250f5300f5200f515337113c50019530195250d5250f5351b5301b5250f5251151519530195251b5251d5251f525215252352524525
010e00003151031510315152f5153151536516315152f51531510315103151536510365103651531515365153a515315152f5153151536515315162f51531515365153151536516315152f51531515365153a515
010e0000091250412517525195150b12506125195251b51509125041250d5250b125061250f5250d12508125115250f1250a12513525111201112011122111120511105110051100511005112051120511205115
010e00002553519525195251b535275351b5251b5251d51531010195251b525330101b5251d525350101d5251f525370101f525215252f5202f5102f5122f5123b721397173b717397173b717397173b71639716
010e00002041421414224142142421410214102141021410214122141221412214150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000008015090150a0150912009110091100911009110095100911209512091150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000000000c04300023000130002300013000230001300023000130072600726007260173601726017260172600726007260072600726017360172601726017260072600726007260072601736
010500003c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0153e5143c0053e5043c0053e5043c0053e5043c0053e5043c0053e504
010500003e5443c0353a5243553432035305342e035295242602524524220251d5141a0151851416015115140e0150c5140a01505514020150051424504220051d5041a0051850416005115040e0050c50416005
0110000000120005250c5451352500120005251352513725001200c52507545135250012000525135250754500120185250754513525001200052513516075450012000525075451352500120135161854524715
011000000c115180150c7150c115180150c715181150c0150c7150c115180150c715181150c01518715181150c015187150c1150c015187150c115180150c7150c1150c035187250c115180150c7151811518015
011000000c0230000000000000001861500000000000c0230c023000000000000000186150c023000000c0230c0230000000000000001861500000000000c0230c023000000c0230c003186150c0230000000000
011000001f525225251f5202b0151f525225251f5201f5121f5121f5122b0151d5251f525225251f5202b0151f525225251f5201f5101f5121f5122b01527515265252751526515275252652524516225151f525
0110000000120005250c5451352500120005251352513725001200c525075451352500120005251352507545031201b5250a545165250312003525165160a54503120035250a5451652503120165160f54527715
011000001f5252252524520247102451224015245002b525295252b5152951527516265252751526515245251f525225251f5201f0151f5252252524520245102451024015247152411524015307152411524015
0110000024525225152452522515245252251524525225151f5251d5151f5251d5151f5251d5151f5252251527525265152752526515275252651527525265152b525295152b525295152b525295152b5252e515
011000002b525295152b5152e5252b525295152b5152e5252752526515275152b5252752526515275152b5252452522515245152752524525225151851527525265252452522525205251f5251d5261b52524525
0110000024520245222451522525245252752524525225251f5201f5101f5122b5151a5151f525265252b5251e5101f5211f5251d5201d51022725247152971536010370113701535010350102e7153071535715
011000000812008010081150f0251002508135130251802503120030100f125031250e025130251702503135031300302203115011300113016025180151d0150353003022035150153001530220152401529015
0110000008125011250f525115150a12503125115251351508125011250a12503125000000a1150a1250a13508125011250f525115150a12503125115251351508125011250a12503125337110a1150a1250a135
011000001153011525115251353513530135251352511515115301152513525135301352013515377113c500115301152511525135351353013525135251d5151d5301d5251f5252252527525295252b52527525
0110000008125011250f525115150a1250312511525135150812501125115250a12503125135250c12505125155250e1250712517525151201511015112151120911109110091100911009112091120911201111
01100000295201d515295151f5252b5201f5151f51529525350101d5251f525370101f525215253901021525235253b0102352525525275202751027512275123351127517335172751733517275173351627516
010e00200172601726017260072600726007260072601736017260172601726007260072600726007260173601726017260172600726007260072600726017360172601726017260072600726007260072601736
010e00001d5101d5101d5101d5101d5101e5111e5101e5101e5101e51024510255112551025510255102551025510255102551025510255102551025510255102551025515235002350023500235002350023500
010e00002e0102e0102e0102e0122e0122f0112f0102f0102f0102f01235010360113601036010360103601036010360103601036010360103601236012360123601236015340023400234002340023400234002
010e00000611006110061100611006110071110711007110071100711002121021200212002525095451552502120025251552515725021200e52509545155250212002525155250954502120025250954515525
010e001f0c0230000000000000001861500000000000c0230c023000000000000000186150c023000000c0230c0230000000000000001861500000000000c0230c023000000c0230c003186150c0230000000000
00200000050251871518615050250002518615000000c0251871509025000000002509025000250202504025050251871518615050250002518615000000c0251871509025000000002509025000250202504025
01200000175251a52517525187051c715175251a5051a5251750517515186150000024711246051c7161551528714175251a525175251c71517525187151a5252101417515186151551524711307141861515515
0108000015065175651c055205552104523545280352c535285343453528534345352852434525285143451500505005050050500505005050050500505005050050500505005050050500505005050050500505
0107000021565207651c0651756515765170651c565205652105523555280552c5552d0452f54534045385452d0352f53534035385352d0252f52534025385252d7142f51534714385152d7142f5143471438514
010e0000310102c71031010380103f7103a0103f0103a710310102c010317103f0103a01033710350103001035710370103201037710325103251032512325122f7112c711297112671123711207111d7111a711
010e00002a7102a0102a710280142a7142f0142a716280142a7102a0102a7102f0142f7102f0152a7142f0142e7142a015287142a0152f7142a015287162a0142f7142a016287142a015287142a0142f71436016
__music__
00 12 42 43 44
03 12 13 43 44
00 41 42 43 44
01 14 15 43 44
00 17 16 43 44
00 17 18 43 44
00 17 19 43 44
00 17 1a 43 44
00 17 16 43 44
00 17 18 43 44
00 1b 1c 43 44
00 1d 1e 43 44
00 1b 1c 43 44
00 1d 1e 43 44
02 20 21 43 44
00 22 23 24 44
03 35 42 43 44
04 25 26 0e 44
01 27 28 29 44
00 2b 2a 29 44
00 2b 2c 29 44
00 2b 2d 29 44
00 2b 2e 29 44
00 2b 2a 29 44
00 2b 2c 29 44
00 30 2f 29 44
00 31 32 29 44
00 30 2f 29 44
00 31 32 29 44
02 33 34 29 44
00 36 37 38 44
03 14 42 43 44
00 22 23 24 44
03 35 42 43 44
00 41 42 43 44
01 14 15 39 44
00 17 16 39 44
00 17 18 39 44
00 17 19 39 44
00 17 1a 39 44
00 17 16 39 44
00 17 18 39 44
00 1b 1c 39 44
00 1d 1e 39 44
00 1b 1c 39 44
00 1d 1e 39 44
02 20 21 39 44
03 3a 3b 43 44
00 41 42 43 39
01 17 1f 43 39
00 17 1f 3f 39
00 1b 3f 43 39
02 1b 3f 1f 39
00 20 21 3e 39
00 36 37 38 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
