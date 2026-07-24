pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- space cave hd 1.0
-- by fartenko


function _init()
	--poke(0x5f2c,3)
	t=0
	music(0,200)
	-- ” —

	--game_state="menu"
	mode="start"
	mode_t=0
	
	
	score=000000 --irnd(999999)
	-- menu
	-- play
	-- over	

	cox=0--32
	coy=0--32
	cx=0 -- camera x
	cy=0 -- camera y
	shx=0 -- shake x
	shy=0 -- shake y
	
	flash_pal={7,7,7,7,7,7,7,0,0,0,0,0,0,0,0,0}
	flash_t=0

	tut_flip=false
	tut_fall=false
	
	slow_t=-1
	slow_b=false
	slow_flp=false
	
	main_expl={}	
	sub_expl={}

	door_particles={}
	
	seg_top={
		s={},
		dx=-2,
	}
	
	seg_top.upd=function()
		for s in all(seg_top.s) do
			if s.x2<-1 then
				del(seg_top.s,s)
			end
			s.x1+=seg_top.dx
			s.x2+=seg_top.dx
			s.p3[1]=s.x1
			s.p4[1]=s.x2
		end
		
		if #seg_top.s<6 then add_seg_top() end
	end
	
	seg_top.drw=function()
		for s in all(seg_top.s) do
			fill_rect({s.x1,s.y1},{s.x2,s.y2},s.p3,s.p4,13)
			line(s.x1,s.y1,s.x2,s.y2,7)
		end
	end
	
	seg_bot={
		s={},
		dx=-2.2,
	}
	
	seg_bot.upd=function()
		for s in all(seg_bot.s) do
			if s.x2<-1 then
				del(seg_bot.s,s)
			end
			s.x1+=seg_bot.dx
			s.x2+=seg_bot.dx
			s.p3[1]=s.x1
			s.p4[1]=s.x2
		end
		
		if #seg_bot.s<6 then add_seg_bot() end
	end
	
	seg_bot.drw=function()
		for s in all(seg_bot.s) do
			fill_rect({s.x1,s.y1},{s.x2,s.y2},s.p3,s.p4,13)
			line(s.x1,s.y1,s.x2,s.y2,7)
		end
	end
	
	
	
	--hp_bonuses
	hp_pwr={
		x=0,
		y=0,
		dx=-0.5,
		sp=192,
		a_fr=4,
		fr=1,
		fr_d=10,
		fr_t=0,
		objects={
			h={}, -- bullets
		},
		-- collision
		coll={x=0,y=0,w=8,h=8,tag="hp_pwr"}
	}
	
	hp_pwr.spawn=function()
		local h={
			x=140,
			m_y=24+rnd(32),
			y=0,
			dx=hp_pwr.dx,
			sp=hp_pwr.sp,
			a_fr=hp_pwr.a_fr,
			fr=hp_pwr.fr,
			fr_d=hp_pwr.fr_d,
			fr_t=hp_pwr.fr_t,
			coll=hp_pwr.coll
		}
		
		add(hp_pwr.objects.h,h)
	end
	
	hp_pwr.upd=function()
		for h in all(hp_pwr.objects.h) do
			h.x+=h.dx
			h.y=h.m_y+sin(h.fr_t/60)*8
			h.fr=(h.fr_t%32)/8
			h.fr_t+=1
			
			if h.x<-8 then
				del(hp_pwr.objects.h,h)
			end
			
			if collide(p,h) and p.hp<3 then
				p.hp+=1
				del(hp_pwr.objects.h,h)
				sfx(9)
				--flash()
				flash_t=2
			end
		end
	end
	
	hp_pwr.drw=function()
		pal(3,false)
		pal(0,true)
		for h in all(hp_pwr.objects.h) do
			spr(h.sp+h.fr,h.x,h.y)
		end
		pal()
	end	
	--- player instance ---
	p={
		x=24,
		m_x=24,
		y=32,
		dy=0.18, -- dy step
		m_dy=1.5, -- max dy
		c_dy=0, -- cur dy
		prt={},
		hp=3,   -- health
		lf=3,		 -- life
		dead=false,
		dead_t=0,
		ready=false,
		firerate=0,
		firecost=8,
		bullets={
			b={}, -- bullets
			e={}, -- effects
		},
		r_num=2,
		rockets={
			r={},
			e={},
		},
		-- collision
		coll={x=-2,y=-2,w=4,h=4,tag="player"}
	}
	--- player update ---
	p.upd=function ()
		if not p.dead then
		 if p.ready then
		 	if btn(2) then p.c_dy-=p.dy else p.c_dy+=p.dy/1.75 end
			 
			 --local n=false
			 --if btn(2) then p.c_dy-=p.dy n=true end--else p.c_dy+=p.dy/1.75 end
			 --if btn(3) then p.c_dy+=p.dy n=true end--else p.c_dy+=p.dy/1.75 end
			 --if not n then 
			 --	if abs(p.c_dy)<p.dy then p.c_dy=0 end
			 --	if     p.c_dy<0 then p.c_dy+=p.dy
			 --	elseif p.c_dy>0 then p.c_dy-=p.dy end
			 --end
			 
			 p.c_dy=mid(p.c_dy,-p.m_dy,p.m_dy)
		 
		 	if btn(5) then p.shoot() end
		 	if btnp(4)then p.r_shoot() end
		 	  
		 	if p.hp<=0 then p.die() end  
		 			 	  
		 	for e in all(enemies.e) do 
		 		if collide(p,e) then
		 		 p.die()
		 		 score+=e.scr
		 		 del(enemies.e,e)
		 		end
		 	end
		 else
		 	p.c_dy=sin(t/80-0.25)*1.5
		 end
		 
		 p.y+=p.c_dy
		 p.firerate-=1
		 add_plr_prt(p.x-2,p.y-p.c_dy,-1.5,-p.c_dy/8)
		end
		
		if p.dead then p.dead_t+=1 end
		
		p.bullets.upd()
		p.rockets.upd()
		
		for _p in all(p.prt) do
	 	_p.x+=_p.dx
	 	_p.y+=_p.dy
	 	if _p.t>10 then del(p.prt,_p) end 
	 	_p.t+=rnd(0.66)+1
	 end
	end
	-- player shooting
	p.shoot=function()
		if p.firerate<=0 then
			p.fire()
			p.firerate=p.firecost
		end
	end
	-- player fire
	p.fire=function()
		local sq=sqrt((12*12)+(p.c_dy*p.c_dy))
	 local x=12/sq
	 local y=(p.c_dy*4)/sq
	 local b={
	 	x=p.x,
	 	y=p.y+p.c_dy*2,
	 	dx=x*6,
	 	dy=y*6,
	 	coll={x=-3,y=-3,w=6,h=6,tag="p_bullet"}
	 }
	 add(p.bullets.b,b)
	 
	 local e={
	 	x=p.x+4,
	 	y=p.y+p.c_dy*2,
	 	t=3,
	 }
	 if p.ready then
	 sfx(2) end
	 add(p.bullets.e,e)
	end
	
	p.r_shoot=function()
	 if p.r_num>0 then
	 	local sq=sqrt((12*12)+(p.c_dy*p.c_dy))
		 local x=12/sq
		 local y=(p.c_dy*4)/sq
		 local r={
		  x=p.x+2,
		  y=p.y+2+p.c_dy*2,
		  dx=x*3,
		  dy=y*3,
		  coll={x=-3,y=-3,w=6,h=6,tag="rocket"},
		 }
		 add(p.rockets.r,r)
	 	p.r_num-=1
	 	if p.ready then
	 	sfx(3) end
	 end
	end
	
	p.die=function(insta)
		insta=insta or false
 	if not p.dead then
 		if insta then
 			p.dead=true
 			music(-1)
 			slow_b=true
  		slow_t=120
 		else
  		if p.lf>0 then
  			p.lf-=1
  			for e in all(enemies.e) do
  				e.die()
  			end
  			p.hp=3
  			slow_b=true
  			slow_t=200
  			p.y=32
  		else
  			p.dead=true
  			slow_b=true
  			slow_t=120
  			music(-1)
 	 	end
	 	end
	 	flash_t=5
	 	super_explode(p.x,p.y,irnd(4)+5,1.9,-p.c_dy/4)
	 	shake(20,30)
	 	sfx(5)
	 	
	 end
	end
	
	-- player bullets
	p.bullets.upd=function()
		for b in all(p.bullets.b) do
			b.x+=b.dx
			b.y+=b.dy
			if b.x>160 or b.y>96 or b.y<-32 then
			 del(p.bullets.b,b)
			end
			for e in all(enemies.e) do
				if collide(b,e) then
				 local _e={
				 	x=b.x,
				 	y=b.y,
				 	t=4,
				 }
					add(p.bullets.e,_e)
				 
				 del(p.bullets.b,b)
		 	 e.hit_t=4
		 	 e.hp-=1
		 	end
			end
		end
		
		for e in all(p.bullets.e) do
		 if e.t==0 then del(p.bullets.e,e) end
		 e.t-=1
		end
	end
	
	p.bullets.drw=function()
		for b in all(p.bullets.b) do
			if pget(b.x,b.y)==13 then del(p.bullets.b,b) end
			for y=-2,2 do
				local x=abs(y)-2
				line(b.x,b.y+y,b.x-b.dx,b.y-b.dy+y,7)
		 	line(b.x-b.dx,b.y-b.dy+y,b.x-b.dx*2,b.y-b.dy*2+y,9)
		 	line(b.x-b.dx*2,b.y-b.dy*2+y,b.x-b.dx*3-x,b.y-b.dy*3+y,4)
			end
			circfill(b.x,b.y,2,7)
		end
		for e in all(p.bullets.e) do
		 circfill(e.x,e.y,8*(e.t/3),10)
		end
	end
	
	p.rockets.upd=function()
	 for r in all(p.rockets.r) do
	  r.x+=r.dx
	  r.y+=r.dy
	  if r.x>160 then
	   del(p.rockets.r,r)
	  end
	  
	  if pget(r.x,r.y)==13 then
	  	del(p.rockets.r,r)
	  	shake(5,5)
	  end
	  	  
	  for e in all(enemies.e) do
		  if collide(r,e) then
		  	--score+=e.scr
		   e.lhit=0
		   e.die()
		   shake(10,15)
		   del(enemies.e,e)
		   del(p.rockets.r,r)
		  end
	  end
	  
	  local e={
	  	x=r.x,
	  	y=r.y,
	  	dx=-1.5-rnd(0.5),
	  	dy=rnd(0.25)-0.125,
	  	t=8+irnd(4),
	  }
	  add(p.rockets.e,e)
	 end
	 for e in all(p.rockets.e) do
	  e.x+=e.dx
	  e.y+=e.dy
	  e.t-=1
	  if e.t==0 then
	   del(p.rockets.e,e)
	  end
	 end
	end
	
	p.rockets.drw=function()
		for e in all(p.rockets.e) do
		 --circfill(e.x,e.y,(e.t/12)*7,0)
		 circfill(e.x,e.y,(e.t/12)*6,9)
		end
	 for r in all(p.rockets.r) do
	  circfill(r.x,r.y,5,0)
	  circfill(r.x,r.y,4,10)
	 end
	end
	--- player draw ---
	p.drw=function ()
		p.bullets.drw()
		p.rockets.drw()
		-- rotation
		local a=p.c_dy*4
		local b=24
		local tg=a/b
		-- cave collision
		local p1=pget(p.x+5-abs(tg*2),p.y+tg*3,15)
		local p2=pget(p.x,p.y+2-tg,15)
		local p3=pget(p.x,p.y-3-tg,15)
		if p3==13 or p2==13 or p1==13 then
		 -- die instanlty
		 --p.die(true)
			p.die()
		end
		-- particles
		for _p in all(p.prt) do
			--circfill(_p.x,_p.y,1,9)
			local col=10
			if _p.t>2 then col=9 end
			if _p.t>4 then col=4 end
			if _p.t>6 then col=2 end
			if _p.t>8 then col=1 end
			line(_p.x,_p.y,_p.x+_p.dx,_p.y+_p.dy*4,col)
		end
		-- ship
		if not p.dead then
			rspr(64,0,8,p.x,p.y,-tg/4)
		end
		--	spr(8,p.x-4,p.y-4)
	 -- pset(p.x+39,p.y+p.c_dy*13,2,2)
	 -- circ(p.x+39,p.y+p.c_dy*13,2,2)
		
		if p.ready then
			palt(3,true)
			palt(0,false)
			sspr(0,8,16,8,52,86+cy)
			pal()
			for i=1,p.hp do
			 spr(18,52+(i-1)*4,86+cy)
			end
		end
	end
	
	-- enemies
	enemies={
		e={},
		b={},
		wave=0,
		can_spawn=true,
	}
	
	enemies.upd=function()
		if p.ready and #enemies.e<=0 and slow_t<=0 then
			enemies.spawn(3+irnd(2))
		end
		for e in all(enemies.e) do
		 e.upd()
		end
		for b in all(enemies.b) do
		 b.x+=b.dx
		 b.y+=b.dy
		 if collide(b,p) and not p.dead then
		  p.hp-=1
		  shake(20,20)
		  sfx(4)
		  del(enemies.b,b)
		 end
		 for pb in all(p.rockets.r) do
		 	if collide(b,pb) then
		 		sfx(4)
		 		shake(10,10)
		 		super_explode(b.x,b.y,1+irnd(1),1.1,1-rnd(2))  
		 		del(enemies.b,b)
		 		del(p.rockets.r,pb)
		 		--––
		 	end
		 end
		 b.t+=1
		end
	end
	
	enemies.drw=function()
	 for e in all(enemies.e) do
	  e.drw()
	 end
	 for b in all(enemies.b) do
	  local x=b.t%16 
	  if x>8 then
	   pal(7,3)
	   pal(8,7)
	   pal(3,8)
	  end
	  spr(b.sp,b.x,b.y)
	 	pal()
	 end
	end
	
	enemies.spawn=function(n)
	 for i=1,n do
	 	local e_type=1+irnd(3)
	 	local e=enemy_class(e_type)
	 	e.x=128+16*((i-1)/3)
	 	e.y=20+12*((i-1)%3)
	 	add(enemies.e,e)
	 end
	end
	--- background stars
	stars={
		s={},	-- stars table
	}
	--- background stars update
	stars.upd=function()
	 for s in all(stars.s) do 
	 	s.x+=s.dx	
	 	if s.x<-8 then del(stars.s,s) end
		end
	 if t%2==0 then
			add_star(140,irnd(96)-32,-1-irnd(5)-0.5)
 	end
	end
	--- background stars	draw
	stars.drw=function() 
	 for s in all(stars.s) do
	 	local col=1
	 	local adx=abs(s.dx)
	 	local pl_y=(p.y-64)*(adx/10)
	 	if adx>3 then col=5 end
	 	if adx>4 then col=6 end
	 	line(s.x,s.y-pl_y,s.x+s.dx-1,s.y-pl_y,col)
		end
	end
	
end


function enemy_class(i)
 local e={
  x=0,
  y=0,
  dx=0,
  dy=0,
  fr_t=0,
  fr_c=0,
  lhit=1,
  can_shoot=false,
  tx=0,
  ty=0,
  hit_t=0,
  hp=0,
  sp=0,
  scr=0,
  coll={x=0,y=0,w=7,h=7,tag="enemy"},
 }
 
 e.die=function()
  super_explode(e.x,e.y,2+irnd(2),1.1,1-rnd(2))
  score+=e.scr
	 shake(5,15)
	 
	 if p.r_num<4 and e.lhit==1 then
		 p.r_num+=1
		end
	 
	 del(enemies.e,e)
	 sfx(4)
 end
 
 -- strike craft
 if i==1 then 
 	e.dx=-0.6-rnd(0.6)
 	e.dy=rnd(0.4)-0.2
 	e.sp=36
  e.hp=1
  e.scr=5+irnd(5)
  e.upd=function()
   e.x+=e.dx
   e.hit_t-=1
   if e.x<128 then
   	e.y+=e.dy
   	if e.hp<=0 then
   	 e.die()
   	end 
   end
   if e.x<-12 then 
    del(enemies.e,e) 
   end
  end
  e.drw=function()
   if e.hit_t>0 then
	   for i=1,15 do
	    pal(i,7)
	   end
   end
   spr(e.sp,e.x,e.y)
  	pal()
  end
 end
 -- strike shooting craft
 if i==2 then
 	e.dx=-0.6-rnd(0.5)
 	e.dy=rnd(0.2)-0.1
 	e.sp=42
 	e.fr_c=100+irnd(20)
 	e.fr_t=e.fr_c/4
 	e.hp=2
 	e.scr=5+irnd(5)
  e.upd=function()
   e.x+=e.dx
   e.hit_t-=1
   if e.x<128 then
   	e.y+=e.dy
   	if e.hp<=0 then
   	 e.die()
   	end
   	if e.fr_t<=0 then
   	 local b={
   	 	x=e.x,
   	 	y=e.y+2,
   	 	dx=e.dx-0.6,
   	 	dy=0,
   	 	sp=5,
   	 	t=0,
   	 	coll={x=0,y=0,w=3,h=3,tag="e_bullet"}
   	 }
   	 add(enemies.b,b)
   	 e.fr_t=e.fr_c-irnd(20)
   	end
   	e.fr_t-=1
   end
   if e.x<-12 then 
    del(enemies.e,e) 
   end
  end
  e.drw=function()
   if e.hit_t>0 then
	   for i=1,15 do
	    pal(i,7)
	   end
   end
   spr(e.sp,e.x,e.y)
  	pal()
  end
 end
 -- spread shooter
 if i==3 then
  e.dx=-0.2-rnd(0.2)
 	e.dy=rnd(0.1)-0.05
 	e.sp=56 -- 40
  e.hp=3
  e.fr_c=120+irnd(30)
  e.fr_t=e.fr_c/6
  e.scr=10+irnd(10)
  e.upd=function()
   e.x+=e.dx
   e.hit_t-=1
   if e.x<128 then
   	e.y+=e.dy
   	if e.hp<=0 then
   	 e.die()
   	end
   	if e.fr_t<=0 then
   	 for i=-1,1,2 do
	   	 local b={
	   	 	x=e.x,
	   	 	y=e.y+2,
	   	 	dx=e.dx-0.6,
	   	 	dy=i*0.6,
	   	 	sp=5,
	   	 	t=0,
	   	 	coll={x=0,y=0,w=3,h=3,tag="e_bullet"}
	   	 }
	   	 add(enemies.b,b)
   	 end
   	 e.fr_t=e.fr_c-irnd(20)
   	end
   	e.fr_t-=1
   end
   if e.x<-12 then 
    del(enemies.e,e) 
   end
  end
  e.drw=function()
   if e.hit_t>0 then
	   for i=1,15 do
	    pal(i,7)
	   end
   end
   spr(e.sp,e.x,e.y)
  	pal()
  end
 end
 -- sniper shooter
 if i==4 then
  e.dx=-0.2-rnd(0.1)
 	e.dy=0.05-rnd(0.025)
 	e.sp=36
 	e.hp=4
 	e.scr=20+irnd(20)
 	e.fr_c=160+irnd(30)
 	e.fr_t=e.fr_c/7
 	e.coll={x=0,y=4,w=15,h=7,tag="enemy"}
  e.upd=function()
   e.x+=e.dx
   e.hit_t-=1
   if e.x<128 then
   	e.y+=e.dy
   	if e.hp<=0 then
   	 e.die()
   	end
   	if e.fr_t<=0 then
   	 local b={
   	 	x=e.x,
   	 	y=e.y+5,
   	 	dx=e.dx-0.6,
   	 	dy=0,
   	 	sp=28,
   	 	t=0,
   	 	coll={x=0,y=0,w=4,h=4,tag="e_bullet"}
   	 }
   	 add(enemies.b,b)
   	 e.fr_t=e.fr_c-irnd(20)
   	end
   	e.fr_t-=1
   end
   if e.x<-12 then 
    del(enemies.e,e) 
   end
  end
  e.drw=function()
   if e.hit_t>0 then
	   for i=1,15 do
	    pal(i,7)
	   end
   end
  	sspr(96,16,16,16,e.x,e.y)
  	pal()
  end
 end
 
 return e
end


function add_plr_prt(x,y,dx,dy)
	local _p={
		x=x,
		y=y,
		dx=dx,
		dy=dy,
		t=0,
	}
	add(p.prt,_p)
end


-- adding background star
function add_star(x,y,dx)
	local _s={
		x=x,
		y=y,
		dx=dx,
	}
	add(stars.s,_s)
end


function add_seg_top()
 local x1=128
 local y1=-20
 if #seg_top.s!=0 then 
 	x1=seg_top.s[#seg_top.s].x2
 	y1=seg_top.s[#seg_top.s].y2
 end
 
 local add_y=0
 if not p.ready then add_y=-20 end
 
 local seg={
 	x1=x1,
 	y1=y1,
 	x2=x1+20+irnd(20),
 	y2=-20+irnd(32+add_y),
 }
 
 local v=rnd(1)
 if seg.y2==seg.y1 then 
  if v>0.5 then seg.y2+=1 else seg.y2-=1 end
 end
 
 seg.p3={seg.x1,-24}
 seg.p4={seg.x2,-24}
 
 add(seg_top.s,seg)
end


function add_seg_bot()
 local x1=128
 local y1=96
 if #seg_bot.s!=0 then 
 	x1=seg_bot.s[#seg_bot.s].x2
 	y1=seg_bot.s[#seg_bot.s].y2
 end
 
 local add_y=0
 if not p.ready then add_y=-20 end
 
 local seg={
 	x1=x1,
 	y1=y1,
 	x2=x1+20+irnd(20),
 	y2=86-irnd(32+add_y)
 }

 local v=rnd(1)
 if seg.y2==seg.y1 then 
  if v>0.5 then seg.y2+=1 else seg.y2-=1 end
 end
 
 seg.p3={seg.x1,88}
 seg.p4={seg.x2,88}
 
 add(seg_bot.s,seg)
end


function spawn_door_particles()
	for i=1,128 do
		local c={}
		c.y=32
		c.x=rnd(128)
		c.dy=rnd(3)-2.125
		c.dx=rnd(4)-2
		c.t=24+rnd(32)
		add(door_particles,c)
	end
end

function upd_door_particles()
	for i=#door_particles,1,-1 do
		local c=door_particles[i]
		c.x+=c.dx
		c.y+=c.dy
		c.t-=1
		c.dy+=0.07
		c.dx-=c.dx/16
		if c.t<=0 then 
			del(door_particles,c)
		end
	end
end

function drw_door_particles()
	for i=1,#door_particles do
		local c=door_particles[i]
		--line(c.x+1,cy+c.y,c.x-c.dx+1,cy+c.y-c.dy,0)
		--line(c.x-1,cy+c.y,c.x-c.dx-1,cy+c.y-c.dy,0)
		--line(c.x,cy+c.y+1,c.x-c.dx,cy+c.y-c.dy+1,0)
		--line(c.x,cy+c.y-1,c.x-c.dx,cy+c.y-c.dy-1,0)
		
		line(c.x-c.dx*2,cy+c.y-c.dy*2,c.x-c.dx,cy+c.y-c.dy,9)
		line(c.x,cy+c.y,c.x-c.dx,cy+c.y-c.dy,10)
		pset(c.x,cy+c.y,7) 
	end
end




function _update60()

	if t<0 then t=0 end

	if mode=="start" then
		mode_t+=1
		if mode_t>96 then
			mode="game"
		end
	end
	
	if mode=="over" then
		mode_t-=1
		if mode_t==64 then
			spawn_door_particles()
			shake(8,24)
			sfx(8)
		end
		if mode_t<0 then
			_init()
		end
	end
	
	if slow_b then
		slow_t-=1
		slow_flp=not(slow_flp)
		
		p.x=p.m_x-slow_t/4
		if p.y>42 then
			p.c_dy-=p.dy
		else end
		
		if slow_t<=-1 then
			slow_b=false
			p.x=p.m_x
		end
	end
	
	if slow_flp and slow_b then return end

	cy=p.y/1.7-32/1.7
	cy=mid(cy,-20,20)
 camera(cx+shx+cox,cy+shy+coy-32)

	p.upd()
	enemies.upd()
	stars.upd()
	seg_top.upd()
	seg_bot.upd()
	hp_pwr.upd()
	
	if rnd(30)>29.95 and p.hp<3 then hp_pwr.spawn() end
	
	upd_explosions()
 upd_shake()
 upd_door_particles()
 
 if not p.ready then 
 	if btnp(2) or btnp(5) then p.ready=true end
 end
-- if btnp(4) then enemies.spawn(3) end
 
 t+=1
 flash_t-=1
 
 if t%10==0 and p.dead==false and p.ready then
 score+=1 end
end


function _draw()
 pal()
 cls()
	
	--line_dot(0,32,64,1,3)
	stars.drw()
	hp_pwr.drw()
	enemies.drw()
	rectfill(-20,-20,148,-70,13)
	seg_top.drw()
	rectfill(-20,88,148,158,13)
	seg_bot.drw()
	p.drw()
	
	
	drw_explosions()
	
	local up_sp=48
	local sh_sp=32
	local rc_sp=34
	if p.ready==false then
	 --print("achievements:",4,cy-28,7)
	 --local s1=97
		--local sx,sy=s1%16*8,flr(s1/16)*8
		--sspr(sx,sy,16,16,0 ,cy)
		--sspr(sx+16,sy,16,16,18,cy)
		--sspr(sx+32,sy,16,16,36,cy)
	
	 
	 -- tutorial
	 if p.c_dy<0 then tut_fall=false up_sp+=1 else
	 	if tut_fall==false then
	 		tut_flip=not(tut_flip)
	 	end
	 	tut_fall=true
	 	if tut_flip==false then
	 		sh_sp+=1
	 		p.shoot()
	 	else
	 		rc_sp+=1
	 		if t%10==0 then
	 			p.r_num+=1
	 			p.r_shoot()
	 		end
	 	end
	 end
	 
	 local oy=20
	 rect(0,48+cy+oy,128,57+cy+oy,1)
	 rectfill(0,49+cy+oy,128,56+cy+oy,0)
	 --print("tutorial",16,51+cy,7)
	 sspr(32,80,32,8,16+32,49+cy+oy)
	 sspr(32,88,64,8,4+32,40+cy+oy)
	 spr(up_sp,52+32,48+cy+oy)
	 spr(sh_sp,4+32,48+cy+oy)
	 spr(rc_sp,4+24,48+cy+oy)
	 
	 local ox=-16
	 -- title
	 palt(3,true)
	 palt(0,false)
	 for i=146,150 do
	 	spr(i,ox+32+6+7*(i-146),16+8+cy+oy+flr(2*sin((t+i*6)/60)+0.5))	 	
	 end
		for i=152,155 do
	 	spr(i,ox+27+32+7*(i-152),16+14+cy+oy+flr(2*sin((t+(i-4)*6)/60)+0.5))
	 end
	 for i=156,160 do
	 	spr(i,ox+32+32+7*(i-152),16+12+cy+oy+flr(2*sin((t+(i-2)*6)/60)+0.5))
	 end	
	 pal() 
	end
	
	-- score
	if p.ready then
		local str=""..score
	 
	 for i=1,6-#str do
	 	str="0"..str
	 end
			
		palt(3,true)
		palt(0,false)
		for i=1,6 do
			local st=sub(str,i,i)
			local sp=str_to_spr(st)
			spr(sp,64+i*7,85+cy)
		end
		pal()
		
		local oy=85
		local ox=42
		for i=1,4 do
	  line(ox+2*i+1,oy+2+cy,ox+2*i+1,oy+6+cy,0)
	  line(ox+2*i-1,oy+2+cy,ox+2*i-1,oy+6+cy,0)
	  line(ox+2*i,oy+3+cy,ox+2*i,oy+7+cy,0)
	  line(ox+2*i,oy+1+cy,ox+2*i,oy+5+cy,0)
			
			line(ox+2*i,oy+2+cy,ox+2*i,oy+6+cy,1)
		end
		
		for i=1,p.r_num do
			line(ox+2*i,oy+2+cy,ox+2*i,oy+6+cy,9)
			pset(ox+2*i,oy+2+cy,7)
			pset(ox+2*i,oy+3+cy,10)
		end
		
		palt(3,true)
		palt(0,false)
		spr(161,6,oy+cy)
		spr(162,15,oy+cy)
		local s=81+p.lf-1
		if p.lf<=0 then s=90 end
		spr(s,22,oy+cy)
	
	end
	
	
	if p.dead and p.dead_t>60 then
	 oprint(" game over ",40,24+cy,7)
	 oprint("press —/Ž",40,32+cy,7)
	
		if btnp(4) or btnp(5) then
		 mode="over"
		 mode_t=128
		 --_init()
		end
	end
	
	-- flash
	if flash_t>0 then
		for a=0,15 do
		 poke(a+0x5f10,flash_pal[a+1])
		end
	end
	
	--local cpu=stat(1)
	--print(cpu,1,4+cy,7)
	--line(1,1+cy,9,1+cy,1)
	--line(1,1+cy,1+8*cpu,1+cy,8)
	
	palt(3,true)
	palt(0,false)
	 	
	local oy=0
	
	if mode=="start" then
		oy=-max(mode_t-32,0)
		shake(2,1)
		sfx(7)
	elseif mode=="game" then
		return
	elseif mode=="over" then
		oy=-max(mode_t-64,0)
		if mode_t>68 then
			shake(2,1)
			sfx(7)
		end
	end
	--if oy<0 and oy>-64 then 
	--	shake(3,10) 
	--end
	--if oy<-64 then 
	-- return 
	--end
	
	local s=107
	local sx,sy=s%16*8,flr(s/16)*8
	sspr(sx,sy+8,8,8,0,24+cy+oy)
	for i=1,14 do
		sspr(sx+8,sy+8,8,8,i*8,24+cy+oy)
	end
	sspr(sx+16,sy+8,8,8,120,24+cy+oy)
	for i=1,7 do
		sspr(sx,sy,8,8,0,16-(i-1)*8+cy+oy)
		sspr(sx+16,sy,8,8,120,16-(i-1)*8+cy+oy)
		for j=1,14 do
			sspr(sx+8,sy,8,8,j*8,24-i*8+cy+oy)			
		end
	end
	
	oy=-oy
	
	local s=107
	local sx,sy=s%16*8,flr(s/16)*8
	sspr(sx,sy-8,8,8,0,32+cy+oy)
	for i=1,14 do
		sspr(sx+8,sy-8,8,8,i*8,32+cy+oy)
	end
	sspr(sx+16,sy-8,8,8,120,32+cy+oy)
	for i=1,7 do
		sspr(sx,sy,8,8,0,40+(i-1)*8+cy+oy)
		sspr(sx+16,sy,8,8,120,40+(i-1)*8+cy+oy)
		for j=1,14 do
			sspr(sx+8,sy,8,8,j*8,32+i*8+cy+oy)			
		end
	end

	pal()
	drw_door_particles()

end



------------------------
------------------------
--       tools        --
------------------------
------------------------


------------------------
--   rotated sprite   --
------------------------

function rspr(sx,sy,size,px,py,rot)
 local r=flr(rot*60)/60
 local s=sin(r)
 local c=cos(r)
 local b=s*s+c*c
 size = size/2
 local w = sqrt(size^2*2)
 for y=-w,w do
   for x=-w,w do
     local ox=( s*y+c*x)/b+size
     local oy=(-s*x+c*y)/b+size
     local col=sget(ox+sx,oy+sy)
     if col>0 then 
       pset(px+x,py+y,col)
     end
   end 
 end
end

---------------------
--    int random   --
---------------------

function irnd(n)
	return round(rnd(n))
end


---------------------
--    round        --
---------------------

function round(n)
 return flr(n+0.5)
end


---------------------
--   dotted line   --
---------------------

function line_dot(x1,y,x2,col,step)
	for x=x1,x2,step do
	 pset(x,y,col)
	end
end


---------------------
--   poly fill     --
---------------------

function fill_rect(p1,p2,p3,p4,col)
 -- p -> {x,y}
 local col=col or 1
 local p={p1,p2,p3,p4}
 
 -- fill rect
 -- triangles table
 local tr={
 	-- we define two triangles
 	{p[1],p[2],p[4]},
 	{p[1],p[4],p[3]},
 }
 
 -- for each triangle, sort it
 for tri in all(tr) do
  -- bubble sort
  -- sorting each triangles points
  -- from highest to lowest
  for x=1,#tri do
   for y=1,#tri-1 do
   	if tri[y][2]>tri[y+1][2] then 
   		local tmp=tri[y+1]
   		tri[y+1]=tri[y]
   		tri[y]=tmp
   	end
   end
  end
 end
 -- after sorting points of triangles
 -- we need to draw lines
 -- 1. from highest to middle
 -- 2. from lowest  to middle
 
 for tri in all(tr) do
  -- 1. highest
  for y=tri[1][2],tri[2][2],1 do
  	-- x distance to each point
  	distx1=tri[2][1]-tri[1][1]
  	distx2=tri[3][1]-tri[1][1]
  	-- y distance to eaach point
  	disty1=tri[2][2]-tri[1][2]
  	disty2=tri[3][2]-tri[1][2]
  	-- find relative y to mid point
  	rel_y=y-tri[1][2]
  	-- calculating x1 and x2 of line
  	x1=tri[1][1]+(distx1*(rel_y/disty1))
  	x2=tri[1][1]+(distx2*(rel_y/disty2))
  	line(x1,y,x2,y,col)
  end
  -- 2. lowest
  -- drawing from lowest to middle
  for y=tri[3][2],tri[2][2],-1 do
  	distx1=tri[2][1]-tri[3][1]
  	distx2=tri[1][1]-tri[3][1]
  	
  	disty1=tri[2][2]-tri[3][2]
  	disty2=tri[1][2]-tri[3][2]
  	
  	rel_y=y-tri[3][2]
  	
  	x1=tri[3][1]+(distx1*(rel_y/disty1))
  	x2=tri[3][1]+(distx2*(rel_y/disty2))
  	line(x1,y,x2,y,col)
  end
 end
end


------------------
--  collision   --
------------------

function collide(a,b)
 return (
 	a.x+a.coll.x<b.x+b.coll.x+b.coll.w and
 	b.x+b.coll.x<a.x+a.coll.x+a.coll.w and
 	a.y+a.coll.y<b.y+b.coll.y+b.coll.h and
 	b.y+b.coll.y<a.y+a.coll.y+a.coll.h
 )
end

function collide_n(x1,y1,w1,h1,x2,y2,w2,h2)
 return (
  x1<x2+w2 and
  x2<x1+w1 and
  y1<y2+h2 and
  y2<y1+h1
 )
end



------------------
--  explosions  -- 
------------------

function create_expl(x,y,dx,dy,c,par,t)
	mult=1
	local e={
		x=x,
		y=y,
		dx=dx*mult,
		dy=dy*mult,
		grav=0.05,
		c=c,
		st=t,
		t=t+rnd(t),
	}
	add(par,e)
end

function super_explode(x,y,n,dx,dy)
	for i=1,n do
		local dx=dx+rnd(4)-2 or rnd(2)-1
		local dy=dy+rnd(4)-2 or rnd(2)-1
		create_expl(x,y,dx,dy,10,main_expl,30)
	end
end

function drw_explosions()
	--super_explosions
	--sub
	for e in all(sub_expl) do
		local c=e.c
		if e.t/e.st < 0.9 then e.c=5 end
		circfill(e.x,e.y,2*e.t/e.st,c)
	end
	--main
	for e in all(main_expl) do
		circfill(e.x,e.y,3*e.t/e.st,e.c)
	end
end

function upd_explosions()
	for e in all(main_expl) do
		e.x+=e.dx
		e.y+=e.dy
		e.dy+=e.grav
		e.t-=1
		create_expl(e.x,e.y,-rnd(0.5)-2,0,4,sub_expl,10)
		if e.t <= 0 then del(main_expl,e) end
	end
	
	for e in all(sub_expl) do
		e.t-=1
		e.x+=e.dx
		if e.t <= 0 then del(sub_expl,e) end
	end
end


-----------------
--  shake      --
-----------------

shake_amt=0
shake_set_a=0
shake_dur=0
shake_set_t=0

function shake(amt,dur)
 shake_amt=amt
 shake_set_a=amt
 shake_dur=dur
 shake_set_t=dur
end

function upd_shake()
	if shake_dur>0 then
		local a=shake_amt
		shx,shy=irnd(a)-a/2,irnd(a)-a/2
		shake_dur-=1
		shake_amt-=(1/shake_set_t)*shake_set_a
	else
		shx,shy=0,0
	end
end


function bw()
	local bw_pal={
		0,0,0,0,0,0,7,7,7,7,7,7,7,7,7,7
	}
 for a=0,15 do
  poke(a+0x5f10,bw_pal[a+1])
 end
end


------------------------
--  string to sprite  --
------------------------

function str_to_spr(s)
 if s=="0" then return 90 end
 if s=="1" then return 81 end
 if s=="2" then return 82 end
 if s=="3" then return 83 end
 if s=="4" then return 84 end
 if s=="5" then return 85 end
 if s=="6" then return 86 end
 if s=="7" then return 87 end
 if s=="8" then return 88 end
 if s=="9" then return 89 end
 return 00
end

--------------------------
-- outlined print --
---------------------------

function oprint(s,x,y,c)
 print(s,x+1,y,0)
 print(s,x,y+1,0)
 print(s,x-1,y,0)
 print(s,x,y-1,0)
 
 print(s,x,y,c)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000000
0070070008880000011100000000000000000000000880000000000000000000888cc70000000000000000000000000000000000000000000000000000000000
000770000888cc000111110000000000000780000087880000000000000000008888888800000000000000000000000000000000000000000000000000000000
00077000008888800011111000000000000880000088880000000000000000000222288000000000000000000000000000000000000000000000000000000000
00700700022222000111110000000000000000000008800000000000000000002222000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33300000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33066666666666030000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000
3070007000700070000eee0000000000000000000000000000000000000000000000000000000000000000000000000000788700000000000000000000000000
30d000d000d000d00008880000000000000000000000000000000000000000000000000000000000000778210000000007878870000000000000000000000000
30d000d000d000d00008880000000000000000000000000000000000000000000000000000000000000778210000000007888870000000000000000000000000
33011111111111030000000000000000000000000000000000000000000000000000000000000000000000000000000000788700000000000000000000000000
33300000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000
33333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000000000000000000000000000000000000000
0777770000000000077777000000000000007806000000000eeffee000000000000788bb00000000000000aa0000000000000000000000000000000000000000
77d7d7700ccccc00777d77700ccccc0006666666000000000022278e0000000000888bbb0000000000788aaa0000000000000000000000000000000000000000
777d7770cc7c7cc077d7d770ccc7ccc0006dddd0000000000000088e00000000bbbbbbbb00000000aaaa99a00000000000cccc00000000000000000000000000
77d7d770ccc7ccc0777d7770cc7c7cc00000dddd000000000eeffee0000000000bb33330000000000009999900000000000cccc0000000000000000000000000
d77777d0cc7c7cc0d77777d0ccc7ccc00000000000000000002222000000000000333300000000000000000000000000007dd5cc088700000000000000000000
0ddddd000ccccc000ddddd000ccccc0000000000000000000000000000000000000000000000000000000000000000000607dd5558887c000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606dd1cccccccc00000000000000000
0000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000006dd1c111111c000000000000000000
0777770000000000000000000000000000000000000000000000000000000000bb887000000000000000000000000000000ccc11111100000000000000000000
777d77700ccccc00000000000000000000000000000000000000000000000000bbb8870000000000000000000000000000000111111000000000000000000000
77ddd770ccc7ccc0000000000000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000
77ddd770cc777cc000000000000000000000000000000000000000000000000003333bb000000000000000000000000000000000000000000000000000000000
d77777d0cc777cc00000000000000000000000000000000000000000000000000033330000000000000000000000000000000000000000000000000000000000
0ddddd000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333333333333333333333333333333333333333333333000000000000000000000030000000000000000
000000003333333333333333333333333333333333333333333333333333333333300333333333333333333307aa77aa77aa77aa77aa77a00000000000000000
00000000333003333000033330000003300330033000000333300003300000033007700333300333333003330996699669966996699669900000000000000000
00000000300770330777700307777770077007700777777030077770077777700770077030077003300770030966996699669966996699600000000000000000
00000000066660333000066030066660066006600666600006666003300006603006600306600660066006600dd44dd44dd44dd44dd44dd00000000000000000
00000000300dd003300dd00330000dd0300dddd030000dd00dd00dd0300dd0030dd00dd0300dddd00dd00dd03000000000000000000000030000000000000000
00000000055555500555555005555003333005500555500330055003055003333005500305555003300550030dd555dd0dd555dd0dd555d00000000000000000
00000000300000033000000330000333333330033000033333300333300333333330033330000333333003333000000000000000000000030000000000000000
00000000333333333333333333333333333333333333333333333333330000000000003333333333333333330dd555dd0dd555dd0dd555d00000000000000000
0000000033333333333333333333333333333333333333333333333330cccccccccddd0333333333333333330d76d7650d76d7650d76d7600000000000000000
000000003333333333333333333333333333333333000000000000330c0c777c7ccdd0d033333300000333330dd555d50dd555d50dd555d00000000000000000
000000003333333333333333333000000000033330aaaaaaaaa999030c0ccccccccdd0d033330077888033330d76d7650d76d7650d76d7600000000000000000
00000000333333333333333333077777776660330a0a77a7aaa990900c0ccccccccdd0d033307888888803330dd555d50dd555d50dd555d00000000000000000
00000000333333333333333330706777776706030a0aaaaaaaa9909030cccdddcdcddd0333308800008803330d76d7650d76d7650d76d7600000000000000000
000000003333000000003333330777777766603330aaaa99a9a99903330ccccccccdd03333308000008803330dd555dd0dd555dd0dd555d00000000000000000
0000000033309aa9a44403333330776676660333330aaaaaaaa99033330ccccccccdd03333330008888803333000000000000000000000030000000000000000
0000000033090999944040333333077777603333330aaaaaaa999033330cccccccddd03333333088888033330dd555dd0dd555dd0dd555d00000000000000000
00000000333099944944033333330777766033333330aaaaaa990333330cccccccddd03333330888000333330d76d7650d76d7650d76d7600000000000000000
000000003333099994403333333307777660333333330aaaa99033333330cccccddd033333330880333333333000000000000000000000030000000000000000
00000000333309999440333333333077660333333333300a900333333333000cd0003333333330033333333307aa77aa77aa77aa77aa77a00000000000000000
0000000033333099440333333333330760333333333330aa99033333333330ccdd03333333330880333333330996699669966996699669900000000000000000
000000003333330940333333333330776603333333300aa99990033333300ccdddd0033333330880333333330966996699669966996699600000000000000000
0000000033333099440333333333077666603333300aaaaaaaa99003300ccccccccdd00333333003333333330dd44dd44dd44dd44dd44dd00000000000000000
00000000333300000000333333300000000003330000000000000000000000000000000033333333333333333000000000000000000000030000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000333333000033000000000033333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777000000777700777777777703333
00000000000000003333333333333333333333333333333333333333333333333333333333333333333333333333333307777000000777700777777777700003
00000000000000003333333333333333333333333333333333333333333333333333333333333333333333333333333306666000000666600666600000066660
00000000000000003330000330000333333003333330000330000003333333333330000333300333300330033000000306666666666666600666600000066660
0000000000000000300777700777700330077003300777700777777033333333300777703007700307700770077777700dddddddddddddd00dddd000000dddd0
0000000000000000066000030660066006600660066000030666600333333333066000030660066006600660066660030dddd000000dddd00dddd000000dddd0
0000000000000000300dddd00dddd0030dddddd00dd000030dd00003333333330dd000030dddddd00dd00dd00dd0000305555000000555500555555555500003
00000000000000000555500305500333055005503005555005555550333333333005555005500550300550030555555005555000000555500555555555503333
00000000000000003000033330033333300330033330000330000003333333333330000330033003333003333000000330000333333000033000000000033333
00000000333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000300033333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088800333003300300000000777070707770777007707770770070000000000000000000000000000000000000000000000000000000000000000000
000000000888cc030770077000000000060060600600606060000600606060000000000000000000000000000000000000000000000000000000000000000000
000000003088888030066003000000000d000dd00d00ddd0d000ddd0ddd0ddd00000000000000000000000000000000000000000000000000000000000000000
00000000022222030dd00dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000300000333003300300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000222002202220022002200000022022002020222020202220220002200000000000000000000000000000000000000000
00000000000000000000000000000000202020002200220022000000202020202020020020200200202020000000000000000000000000000000000000000000
00000000000000000000000000000000111010001000011001100000111010100110010011100100101010100000000000000000000000000000000000000000
00000000000000000000000000000000100010001110110011001110101010101100010010101110101011100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33300333333003333330033333300333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
330ee033330ee033330ee033330ee033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
300ee003330ee033330ee033330ee033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeee0302eef033307f03330fee203000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeee0302eef03330f703330fee203000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
300ee003330ee033330ee033330ee033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
330ee033330ee033330ee033330ee033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33300333333003333330033333300333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000000000000000000000000000001010000010100000000000000000000010100000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3232323232323232123215080813323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1232323222322232323215303013323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232242424242424242425303013323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3216343434343434343435303013323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1526303030303030303030301b32323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530030404040404040404043232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530131634343434341732321232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530142603040405302713323232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530143023323215303013322212323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530131a33341715303013123232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530233204052714303013323232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530332324253014303023242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1530303334353014303033343434343400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
321a303030301b321a3030303030300900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232040404043232320404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323232323232323232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000c0030c0030c0030c0030c0030c0030c0030c0030c0030000000000000000c0030000000000000000c0030000000000000000c0030000000000000000c0030000000000000000c0030c0030000000000
010200003362233622336220f0320e0320e0370c0370c0370a0370903708027070270602706027050270502704017040170301702017010170000700007000070000000000000000000000000000000000000000
010400000c6320c6120c6020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002465329053290322803228022260222401224012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000466302633046220561207612006020060200602006020060200602000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000006430062300613210321f0221d0121c0321a022180121803218022180120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002903324012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000e62011610136101161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000136700e3530c3430c3330c3230c3230c3130c3130c3130c3120c3120c3120c31200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000c3540c3420c3320c3220c312173541734217332173221731217300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0030c0030c0530c0530c0530c053
011000200c0331b3030c0430c033246150f3030c0430f3030c0430f3030c0330f303246150f3030c0230c0430c0430f3030c0330f303246150c0430f3030c0330c0230c0430f3030c04324615000000c0430c023
011000200204002125020100214002025021100204002125020100214002025021100204002110020450211002040021200201502140020200211002045021200201002145020200211002045021100204502110
011000200200002105020400212002015021400202002115020400212002015021400202002110020450211002040021100204502120020100214002025021100204002125020100214002015021400201502110
011000000c033000350c0030c6350c033000350c00300033000350c033000350c0330c6350c003000350c0030c033000050c033000050c635000350c00300035000350c033000050c0330c6350c635006350c635
0110000002040021250201002140020250211002000021050c0030e00302040021250201002140020250211002000021050200002140020250211002000021050204002125020100214002025021100204002115
011000000c0000c0110c0110c0110c0110c0110e0320e0320e0320e0320e0110e0110e0110c0110c0110c01110032110321103211011110111101113032130321301113011110111101110011130331303313033
011000000c0230c033000000c6050c6350c013000000c0330c6050c0330c023000000c635000000c033000000c033000000c0330c0230c6350c0330c033000000c6050c0130c0330c0330c635000000c03300000
011000000c0330c0230c013000000c6350c0330c0230c013000000c0330c033000000c6350c0330c0230c0130c033000000c033000000c6350c0330c0230c013000000c033000000c0330c6350c0330c0230c013
011000000204002125020100214002025021100200002105020400212502010021400202502110020400211502040021150201002140020250211002000021050204002125020100214002025021100204002115
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 0d 43 44
00 0b 0d 43 44
01 0c 0d 43 44
00 0c 0d 43 44
00 0c 0e 43 44
00 0c 0e 43 44
00 0f 10 11 44
00 12 0e 43 44
00 13 14 43 44
02 0c 14 43 44
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
00 41 42 43 44
00 41 42 43 44
