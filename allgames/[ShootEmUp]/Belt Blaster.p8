pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
function _init()
	music(00)
	start=false
	game_over=false
	has_power=false
	fired_power=false
	level=1
	ast_int=0
	game_time=0
	tur_pos=16
	cp_score=0
	cp_time=0
	make_ship()
	lasers={}
	spec_lsr={}
	enm_lsr={}
	boosters={}
	xtra_lives={}
	walls={}
	stars={}
	lg_ast={}
	med_ast={}
	sm_ast={}
	turrets={}
	hits={}
	sparks={}
	for i=1,200 do
		add(sparks,{
		x=0,y=0,velx=0,vely=0,
		r=0,mass=0,alive=false,kind=false
		})
	end
	build_walls()
	make_stars()
	make_lg_ast()
end

function _update()

	for st in all(stars) do
		st.y+=st.spd
		if (st.y>128) then
			st.y=0
		end
	end
	
	if (start==true) then
	game_time+=1
	
	if (game_time%1800==0)then
		level+=1
	end
	
	if (game_time%450==0)then
		cp_time=game_time
		cp_score=ship.score
	end
	
	if (game_time%450-((level-1)*20)==0)then
		make_turret(tur_pos)
		
		tur_pos+=40
	
		if (tur_pos >= 136) then
			tur_pos=16
		end
	
	end

	ast_int+=1
	
	if ast_int >= 170-(20*level) then
		make_lg_ast()
		ast_int = 0
	end
	
	for tile in all(walls) do
		tile.y+=1
		if tile.y >=128 then
			tile.y=-8
		end
	end
	
	for l_as in all(lg_ast) do
		if (l_as.rando==1) then
			l_as.x+=l_as.x_sp
			if (l_as.x>96) then
				l_as.rando=2
			end
		else
			l_as.x-=l_as.x_sp
			if (l_as.x<0) then
				l_as.rando=1
			end
		end
		l_as.y+=l_as.y_sp
		l_as.box=update_box(l_as,4,28)
		if (l_as.y > 128) then
			del (lg_ast, l_as)
		end
	end
	
	for m_as in all(med_ast) do
		if (m_as.rando==1) then
			m_as.x+=m_as.x_sp
			if (m_as.x>112) then
				m_as.rando=2
			end
		else
			m_as.x-=l_as.x_sp
			if (m_as.x<0) then
				m_as.rando=1
			end
		end
		m_as.y+=m_as.y_sp
		m_as.box=update_box(m_as,2,14)
		if (m_as.y > 128) then
			del (med_ast, m_as)
		end
	end
	
	for s_as in all(sm_ast) do
		if (s_as.rando==1) then
			s_as.x+=s_as.x_sp
			if (s_as.x>120) then
				s_as.rando=2
			end
		else
			s_as.x-=l_as.x_sp
			if (s_as.x<0) then
				s_as.rando=1
			end
		end
		s_as.y+=m_as.y_sp
		s_as.box=update_box(s_as,1,7)
		if (s_as.y > 128) then
			del (sm_ast, s_as)
		end
	end
	
	for t in all(turrets) do
		t.shot_count+=1
		if (t.shot_count == 30) then
			enm_fire(false,t)
		elseif (t.shot_count == 60) then
			enm_fire(true,t)
		end
		if (t.shot_count == 61) then
			t.shot_count = 1
		end
		t.y+=t.dy
		t.box=update_box(t,2,14)
		if (t.y > 128) then
			del (turrets, t)
		end
	end
	
	ship.box=update_box(ship,1,7)
	
	if (ship_is_hit()) then
		ship.lives-=1
		sfx(3)
		explode(ship.x+3,ship.y+3,7,60,2)
		
		for l_as in all(lg_ast) do
			del(lg_ast, l_as)
			explode((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2,5,50,1)
		end
		
		for m_as in all(med_ast) do
			del(med_ast, m_as)
			explode((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2,3.5,40,1)
		end
		
		for s_as in all(sm_ast) do
			del(sm_ast, s_as)
			explode((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2,2,30,1)
		end	
		
		for t in all(turrets) do
			del(turrets, t)
			explode((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2,3.5,40,1)
		end
		
		for i=1,5 do
			ship.power[i]=3
		end
		
		for l in all(lasers) do
			del(lasers,l)
		end
		
		for s_l in all(spec_lsr) do
			del(spec_lsr,s_l)
		end
		
		for e_l in all(enm_lsr) do
			del(enm_lsr,e_l)
		end
		
		for b in all(boosters) do
			del(boosters,b)
		end
		
		for life in all(xtra_lives) do
			del(xtra_lives,life)
		end
		if (ship.lives > 0) then
			game_time=cp_time
			ship.score=cp_score
			ship.x=60
			ship.y=110
		else
			game_over=true
			music(00)
		end
	end
	
	build_hits(lasers, lg_ast, med_ast, sm_ast)
	spec_hit()
	
	move_ship()
	
	for l in all(lasers) do
		l.x += l.dx
		l.y += l.dy
		
		if l.y < 0 then
			del(lasers,l)
		end
	end
	
	for s_l in all(spec_lsr) do
		if (s_l.offset==0) then
			s_l.x += s_l.dx
			s_l.y += s_l.dy
		end
		if (fired_power==true) then
			if (s_l.offset > 0) then
				s_l.offset-=1
			end
		end
		if s_l.y < 0 then
		 del(spec_lsr,s_l)
		end
	end
	
	for e_l in all(enm_lsr) do
		e_l.x+=e_l.dx
		e_l.y+=e_l.dy
		if (e_l.y < 0 or e_l.y > 128) then
			del(enm_lsr,e_l)
		end
		if (e_l.x < 0 or e_l.x > 128) then
			del(enm_lsr,e_l)
		end
	end
	
	if (#spec_lsr>0 and spec_lsr[#spec_lsr].offset==0) then
		fired_power=false
	end
	
	if (btnp(4) and game_over==false) then
	 fire()
	 sfx(0)
 end
 
 if (btnp(5) and game_over==false) then
 	spec_fire()
 	fired_power=true
 end
 
 for i=1,#sparks do
  if sparks[i].alive then
  	sparks[i].x += sparks[i].velx/sparks[i].mass
  	sparks[i].y += sparks[i].vely/sparks[i].mass
  	sparks[i].r -= 0.1
  	if sparks[i].r < 0.1 then
  		sparks[i].alive = false
  	end
  end
 end
 
 for b in all(boosters) do
 	if (#boosters>=1) then
 		b.y+=b.yvel
 		if (b.y > 128) then
 			del(boosters,b)
 		end
 		b.sprite+=1
 		if (b.sprite==40) then
 			b.sprite=35
 		end
 		if (b.y+6 >= ship.box.y1 and b.y <= ship.box.y2) then
 			if (b.x+7 >= ship.box.x1 and b.x+1 <= ship.box.x2) then
					del(boosters,b)
					sfx(4)
					has_power=true
					for i=1, 5 do
						if (ship.power[i]==3) then
							ship.power[i]=4 
							break
						end
					end
				end
			end			
 	end
 end
 
 for life in all(xtra_lives) do
 	if (#xtra_lives>=1) then
 		life.y+=life.yvel
 		if (life.y > 128) then
 			del(xtra_lives,life)
 		end
 		life.sprite+=1
 		if (life.sprite==56) then
 			life.sprite=51
 		end
 		if (life.y+6 >= ship.box.y1 and life.y <= ship.box.y2) then
 			if (life.x+7 >= ship.box.x1 and life.x+1 <= ship.box.x2) then
					del(xtra_lives,life)
					sfx(5)
					ship.lives+=1
				end
			end			
 	end
 end
 
 if (game_over==true) then
 	if btnp(5) then 
 		_init()
 		music(-1) 
 	end
	end
	
	else
		if btnp(5) then
		 sfx(6)
			start=true
			music(-1)
		end
	end
end

function _draw()
	cls()
	for st in all(stars) do
		pset(st.x, st.y, (flr(rnd(2))+6))
	end
	
	if (start==true) then
	
	for i=1,#sparks do
  if sparks[i].alive then
  	if sparks[i].kind==1 then
  	circfill(
  		sparks[i].x,
  		sparks[i].y,
  		sparks[i].r,
  		8+flr(rnd(3))
  	)
  	elseif sparks[i].kind==2 then
  	circfill(
  		sparks[i].x,
  		sparks[i].y,
  		sparks[i].r,
  		13+flr(rnd(3))
  	)
  	end
  end
 end
	
	for b in all(boosters) do
		if (#boosters>=1) then
			spr(b.sprite,b.x,b.y)
		end
	end
	
	for life in all(xtra_lives) do
		if (#xtra_lives>=1) then
			spr(life.sprite,life.x,life.y)
		end
	end
	
	for l in all(lasers) do
		spr(l.sprite, l.x, l.y)
	end
	
	for s_l in all(spec_lsr) do
		if (s_l.offset==0) then
			spr(17, s_l.x, s_l.y)
		end
	end
	
	for e_l in all(enm_lsr) do
		spr(34, e_l.x, e_l.y)
	end
	
	for t in all(turrets) do
		if (t.count<=5) then
			spr(96,t.x,t.y,2,2)
		else
			spr(32,t.x,t.y,2,2)
		end
		t.count+=1
		if (t.count == 11) then
			t.count=1
		end
	end
	
	for l_as in all(lg_ast) do
		if (l_as.count<=5) then
			spr(67, l_as.x, l_as.y,4,4)
		elseif (l_as.count<=10) then
			spr(75, l_as.x, l_as.y,4,4)
		elseif (l_as.count<=15) then
			spr(12, l_as.x, l_as.y,4,4)
		else
			spr(8, l_as.x, l_as.y,4,4)
		end
		l_as.count+=1
		if (l_as.count==21) then
			l_as.count=1
		end 
	end
	
	for m_as in all(med_ast) do
		if (m_as.count<=4) then
			spr(71, m_as.x, m_as.y,2,2)
		elseif (m_as.count<=8) then
			spr(73, m_as.x, m_as.y,2,2)
		elseif (m_as.count<=12) then
			spr(103, m_as.x, m_as.y,2,2)
		else
			spr(105, m_as.x, m_as.y,2,2)
		end
		m_as.count+=1
		if (m_as.count==17) then
			m_as.count=1
		end 
	end
	
	for s_as in all(sm_ast) do
		if (s_as.count<=2) then
			spr(79, s_as.x, s_as.y)
		elseif (s_as.count<=4) then
			spr(95, s_as.x, s_as.y)
		elseif (s_as.count<=6) then
			spr(111, s_as.x, s_as.y)
		else
			spr(127, s_as.x, s_as.y)
		end
		s_as.count+=1
		if (s_as.count==9) then
			s_as.count=1
		end 
	end
	
	for h in all(hits) do
		spr(h.sprite,h.x,h.y)
		if h.sprite then
			h.sprite+=1
			if (h.sprite>=22) then
				del(hits,h)
			end
		end
	end
	
	for tile in all(walls) do
		spr(tile.sprite, tile.x, tile.y)
	end
	
	if (game_over==false) then
		for i=1, 5 do
			spr(ship.power[i], (i*8), 120)
		end
	end
	
	for i=0, ship.lives-1 do
		spr(5, 111-(i*8), 120)
	end
	
	if (game_over==false) then
		draw_ship()
		print("score: "..ship.score,6,2,11)
		print("level: "..level,90,2,11)
	else
		print("final score: "..ship.score,30,54,11)
		print("press — to play again!", 20,74,11)
	end
	
	else
		spr(128,32,32,8,4)
		spr(136,32,64,8,1)
		print("press — to play!",32,90,11)
	end
	
end
-->8
--player functions
function make_ship()
	ship={}
	ship.x=60
	ship.y=110
	ship.dy=0
	ship.dx=0
	ship.laser=1
	ship.sprite=1
	ship.lives=3
	ship.power={3,3,3,3,3}
	ship.score=0
	ship.box={x1=61,y1=111,x2=67,y2=117}
end

function draw_ship()
	spr(ship.sprite,ship.x,ship.y)
end

function stay_on_screen()
	if (ship.x < 5) then
		ship.x=5
	end
	if (ship.x > 114) then
		ship.x=114
	end
	if (ship.y < 0) then
		ship.y=0
	end
	if (ship.y > 111) then
		ship.y=111
	end
end

function move_ship()
	if (btn(0)) ship.x-=1.5
	if (btn(1)) ship.x+=1.5
	if (btn(3)) ship.y+=1.5
	if (btn(2)) ship.y-=1.5
	
	stay_on_screen()
end

-->8
--constructor functions

function build_walls()
	for i=0, 16 do
		tile={
			x=0,
			y=8*i-8
		}
		if (i%2==0) then
			tile.sprite=64
		else
			tile.sprite=80
		end
		
		add(walls, tile)
		
		tile={
			x=120,
			y=8*i-8
		}
		if (i%2==0) then
			tile.sprite=65
		else
			tile.sprite=81
		end
			
		add(walls, tile)
		
	end
end

function make_stars()
	for i=0, 100 do
		st={
			x=flr(rnd(128)),
			y=flr(rnd(128)),
			spd=(rnd(3))/6
		}
		add(stars, st)
	end
end

function fire()
	local l = {
		x = ship.x,
		y = ship.y,
		dx = 0,
		dy = -4,
		}
		if (ship.laser==1) then
		 l.sprite = 2
		 ship.laser = 2
		elseif (ship.laser==2) then
			l.sprite = 18
			ship.laser = 1
		end
		add(lasers, l)
end

function spec_fire()
	power_count=0
	reset=-2
	for i=1,5 do
		if (ship.power[i]==4) then
			power_count+=1
			ship.power[i]=3
		end
	end
	if (power_count>0) then
		for i=0,(power_count*5)-1 do
			s_l={
				x=ship.x,
				y=ship.y,
				dx=reset/2,
				dy=-1.5,
				offset=flr(i/5)*4
			}
			reset+=1
			if (reset==3) then
				reset=-2
			end
			add(spec_lsr, s_l)
		end
	end
end

function enm_fire(angle,en)
	local coords = {
	 {-1,0},{0,-1},{1,0},{0,1}
	}
	local coords_ang = {
	 {-.75,-.75},{.75,-.75},{.75,.75},{-.75,.75}
	}
	if not angle then
		for i=1,4 do
			e_l={
				x=en.x+4,
				y=en.y+8,
				dx=coords[i][1],
				dy=coords[i][2]
			}
			add(enm_lsr, e_l)
		end
	elseif angle then
		for i=1,4 do
			e_l={
				x=en.x+6,
				y=en.y+6,
				dx=coords_ang[i][1],
				dy=coords_ang[i][2]
			}
			add(enm_lsr, e_l)
		end
	end
end

function make_turret(pos)
	t={
		x=pos,
		y=-16,
		dy=.25,
		count=1,
		shot_count=0,
		health=30,
		xtra_life=ceil(rnd(8))
	}
	t.box={x1=t.x+2,y1=t.y+2,x2=t.x+14,y2=t.y+14}
	add(turrets,t)
end

function make_lg_ast()
 l_as={
 	x=rnd(128),
 	y=-32,
 	x_sp=rnd(2)/4,
 	y_sp=(rnd(2)/4)+.175,
 	count=1,
 	rando=flr(rnd(2)),
 	health=10,
 	booster=ceil(rnd(10))
 }
 l_as.box={x1=l_as.x+4,y1=l_as.y+4,x2=l_as.x+28,y2=l_as.y+28}
 add(lg_ast, l_as)
end

function make_med_ast(prev_x,prev_y)
 for i=1,3 do
 m_as={
 	x=prev_x+10+rnd(10),
 	y=prev_y+10+rnd(10),
 	x_sp=rnd(2)/2.5,
 	y_sp=(rnd(2)/2.5)+.25,
 	count=1,
 	rando=flr(rnd(2)),
 	health=3,
 	booster=ceil(rnd(15))
 }
 m_as.box={x1=m_as.x+2,y1=m_as.y+2,x2=m_as.x+14,y2=m_as.y+14}
 add(med_ast, m_as)
 end
end

function make_sm_ast(prev_x,prev_y)
 for i=1,4 do
 s_as={
 	x=prev_x+6+rnd(6),
 	y=prev_y+6+rnd(6),
 	x_sp=rnd(2)/1.5,
 	y_sp=rnd(2)/1.5+.5,
 	count=1,
 	rando=flr(rnd(2)),
 	health=1,
 	booster=ceil(rnd(20))
 }
 s_as.box={x1=s_as.x+1,y1=s_as.y+1,x2=s_as.x+7,y2=s_as.y+7}
 add(sm_ast, s_as)
 end
end

function make_booster(x,y)
	b={
		x=x,
		y=y,
		yvel=.5,
		sprite=35
	}
	add(boosters,b)
end

function make_life(x,y)
	life={
		x=x,
		y=y,
		yvel=.75,
		sprite=51
	}
	add(xtra_lives,life)
end
	

		
-->8
--collision detection
function update_box(as,x,y)
	return {x1=as.x+x, y1=as.y+x, x2=as.x+y,y2=as.y+y}
end

function build_hits(lsr,lg,med,sm)
 local h={sprite=19}
 for l in all(lsr) do
 	 for l_as in all(lg) do
 	 	if (l.x+2 >= l_as.box.x1 and l.x+2 <= l_as.box.x2) then
 	 		if (l.y+2 <= l_as.box.y2 and ship.y > l_as.box.y2) then
 	 		 h.x=l.x+2
 	 		 h.y=l.y+2
 	 		 add (hits,h)
 	 		 sfx (1)
 	 		 del (lsr, l)
 	 		 l_as.health-=1
 	 		 if (l_as.health<=0) then
 	 		 	make_med_ast(l_as.x,l_as.y)
 	 		 	sfx(2)
 	 		 	if l_as.booster==1 then
 	 		 		make_booster((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2)
 	 		 	end
 	 		 	del (lg, l_as)
 	 		 	explode((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2,5,50,1)
 	 		 	ship.score+=10
 	 		 end
 	 		end
 	 	end
 	 end
 	
 
 	 for m_as in all(med) do
 	 	if (l.x+2 >= m_as.box.x1 and l.x+2 <= m_as.box.x2) then
 	 		if (l.y+2 <= m_as.box.y2 and ship.y > m_as.box.y2) then
 			 	h.x=l.x+2
  		 	h.y=l.y+2
	 		 	add (hits,h)
	 		 	sfx (1)
	 		 	del (lsr, l)
	 		 	m_as.health-=1
	 		 	if (m_as.health<=0) then
	 		 		make_sm_ast(m_as.x, m_as.y)
	 		 		sfx(2)
	 		 		if m_as.booster==1 then
 	 		 		make_booster((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2)
 	 		 	end
	 		 		del (med, m_as)
	 		 		explode((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2,3.5,40,1)
	 		 		ship.score+=3
	 		 	end
	 			end
	 		end
		 end
			
				
			for s_as in all(sm) do
 	 	if (l.x+2 >= s_as.box.x1 and l.x+2 <= s_as.box.x2) then
 	 		if (l.y+2 <= s_as.box.y2 and ship.y > s_as.box.y2) then
 	 		 h.x=l.x+2
 	 		 h.y=l.y+2
 	 		 add (hits,h)
 	 		 sfx (1)
	 		 	del (lsr, l)
	 		 	s_as.health-=1
	 		 	if (s_as.health<=0) then
	 		 		sfx(2)
	 		 		if s_as.booster==1 then
 	 		 		make_booster((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2)
 	 		 	end
	 		 		del (sm, s_as)
	 		 		explode((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2,2,30,1)
	 		 		ship.score+=1
	 		 	end
 	 		end
 	 	end
 	 end
 	 
 	 
 	 for t in all(turrets) do
 	 	if (l.x+2 >= t.box.x1 and l.x+2 <= t.box.x2) then
 	 		if (l.y+2 <= t.box.y2 and ship.y > t.box.y2) then
 			 	h.x=l.x+2
  		 	h.y=l.y+2
	 		 	add (hits,h)
	 		 	sfx (1)
	 		 	del (lsr, l)
	 		 	t.health-=1
	 		 	if (t.health<=0) then
	 		 		sfx(2)
	 		 		if t.xtra_life==1 then
 	 		 		make_life((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2)
 	 		 	end
	 		 		del (turrets, t)
	 		 		explode((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2,3.5,40,1)
	 		 		ship.score+=25
	 		 	end
	 			end
	 		end
		 end
			
	end
end

function spec_hit()
	for s_l in all(spec_lsr) do
		for l_as in all(lg_ast) do
			if (s_l.x+6 >= l_as.box.x1 and s_l.x+2 <= l_as.box.x2) then
				if (s_l.y <= l_as.box.y2 and s_l.y+4 > l_as.box.y2) then
			 	sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					l_as.health-=3
					if (l_as.health<=0) then
 	 	 	make_med_ast(l_as.x,l_as.y)
 	 	 	sfx(2)
 	 	 	if l_as.booster==1 then
 	 	 		make_booster((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2)
 	 	 	end
 	 	 	del (lg_ast, l_as)
 	 	 	explode((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2,5,50,1)
 	 			ship.score+=10
 	 		end
				end
			
				if (s_l.y+4 >= l_as.box.y1 and s_l.y < l_as.box.y1) then
					sfx(1)
					del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					l_as.health-=3
					if (l_as.health<=0) then
 	 	 	make_med_ast(l_as.x,l_as.y)
 	 	 	sfx(2)
 	 	 	if l_as.booster==1 then
 	 	 		make_booster((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2)
 	 	 	end
 	 	 	del (lg_ast, l_as)
 	 	 	explode((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2,5,50,1)
 	 			ship.score+=10
 	 		end
				end
			end
			if (s_l.y+4 >= l_as.box.y1 and s_l.y <= l_as.box.y2) then
				if (s_l.x+2 <= l_as.box.x2 and s_l.x+6 > l_as.box.x2) then
					sfx(1)
					del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					l_as.health-=3
					if (l_as.health<=0) then
 		 		make_med_ast(l_as.x,l_as.y)
 		 		sfx(2)
 		 		if l_as.booster==1 then
 		 			make_booster((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2)
 		 		end
 		 		del (lg_ast, l_as)
 		 		explode((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2,5,50,1)
 					ship.score+=10
 				end
				end
				if (s_l.x+6 >= l_as.box.x1 and s_l.x+2 < l_as.box.x1) then
					sfx(1)
					del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					l_as.health-=3
					if (l_as.health<=0) then
 	  		make_med_ast(l_as.x,l_as.y)
 	  		sfx(2)
 	  		if l_as.booster==1 then
 	  			make_booster((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2)
 	  		end
 	 			del (lg_ast, l_as)
 	 			explode((l_as.box.x1+l_as.box.x2)/2,(l_as.box.y1+l_as.box.y2)/2,5,50,1)
 	 			ship.score+=10
 	 		end
				end
			end
		end
			
		for m_as in all(med_ast) do
			if (s_l.x+6 >= m_as.box.x1 and s_l.x+2 <= m_as.box.x2) then
				if (s_l.y <= m_as.box.y2 and s_l.y+4 > m_as.box.y2) then
			 	sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					m_as.health-=3
					if (m_as.health<=0) then
 	 	 	make_sm_ast(m_as.x,m_as.y)
 	 	 	sfx(2)
 	 	 	if m_as.booster==1 then
 	 	 		make_booster((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2)
 	 	 	end
 	 	 	del (med_ast, m_as)
 	 	 	explode((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2,3.5,40,1)
 	 			ship.score+=3
 	 		end
				end
				if (s_l.y+4 >= m_as.box.y1 and s_l.y < m_as.box.y1) then
					sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					m_as.health-=3
					if (m_as.health<=0) then
 	 	 	make_sm_ast(m_as.x,m_as.y)
 	 	 	sfx(2)
 	 	 	if m_as.booster==1 then
 	 	 		make_booster((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2)
 	 	 	end
 	 	 	del (med_ast, m_as)
 	 	 	explode((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2,3.5,40,1)
 	 			ship.score+=3
 	 		end
				end
			end
	
			if (s_l.y+4 >= m_as.box.y1 and s_l.y <= m_as.box.y2) then
				if (s_l.x+2 <= m_as.box.x2 and s_l.x+6 > m_as.box.x2) then
			 	sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					m_as.health-=3
					if (m_as.health<=0) then
 	 	 	make_sm_ast(m_as.x,m_as.y)
 	 	 	sfx(2)
 	 	 	if m_as.booster==1 then
 	 	 		make_booster((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2)
 	 	 	end
 	 	 	del (med_ast, m_as)
 	 	 	explode((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2,3.5,40,1)
 	 			ship.score+=3
 	 		end
				end
				if (s_l.x+6 >= m_as.box.x1 and s_l.x+2 < m_as.box.x1) then
					sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					m_as.health-=3
					if (m_as.health<=0) then
 	 	 	make_sm_ast(m_as.x,m_as.y)
 	 	 	sfx(2)
 	 	 	if m_as.booster==1 then
 	 	 		make_booster((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2)
 	 	 	end
 	 	 	del (med_ast, m_as)
 	 	 	explode((m_as.box.x1+m_as.box.x2)/2,(m_as.box.y1+m_as.box.y2)/2,3.5,40,1)
 	 			ship.score+=3
 	 		end
				end
			end
		end
	
		for s_as in all(sm_ast) do
			if (s_l.x+6 >= s_as.box.x1 and s_l.x+2 <= s_as.box.x2) then
				if (s_l.y <= s_as.box.y2 and s_l.y+4 > s_as.box.y2) then
			 	sfx(1)
					explode(s_l.x+4,s_l.y,1,20,2)
					s_as.health-=3
					if (s_as.health<=0) then
 	 	 	sfx(2)
 	 	 	if s_as.booster==1 then
 	 	 		make_booster((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2)
 	 	 	end
 	 	 	del (sm_ast, s_as)
 	 	 	explode((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2,2,30,1)
 	 			ship.score+=1
 	 		end
				end
				if (s_l.y+4 >= m_as.box.y1 and s_l.y < m_as.box.y1) then
					sfx(1)
					explode(s_l.x+4,s_l.y,1,20,2)
					s_as.health-=3
					if (s_as.health<=0) then
 	 	 	sfx(2)
 	 	 	if s_as.booster==1 then
 	 	 		make_booster((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2)
 	 	 	end
 	 	 	del (sm_ast, s_as)
 	 	 	explode((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2,2,30,1)
 	 			ship.score+=1
 	 		end
				end
			end
	
			if (s_l.y+4 >= m_as.box.y1 and s_l.y <= m_as.box.y2) then
				if (s_l.x+2 <= m_as.box.x2 and s_l.x+6 > m_as.box.x2) then
			 	sfx(1)
					explode(s_l.x+4,s_l.y,1,20,2)
					s_as.health-=3
					if (s_as.health<=0) then
 	 	 	sfx(2)
 	 	 	if s_as.booster==1 then
 	 	 		make_booster((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2)
 	 	 	end
 	 	 	del (sm_ast, s_as)
 	 	 	explode((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2,2,30,1)
 	 			ship.score+=1
 	 		end
				end
				if (s_l.x+6 >= m_as.box.x1 and s_l.x+2 < m_as.box.x1) then
					sfx(1)
					explode(s_l.x+4,s_l.y,1,20,2)
					s_as.health-=3
					if (s_as.health<=0) then
 	 	 	sfx(2)
 	 	 	if s_as.booster==1 then
 	 	 		make_booster((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2)
 	 	 	end
 	 	 	del (sm_ast, s_as)
 	 	 	explode((s_as.box.x1+s_as.box.x2)/2,(s_as.box.y1+s_as.box.y2)/2,2,30,1)
 	 			ship.score+=1
 	 		end
				end
			end 	
		end
		
		for t in all(turrets) do
			if (s_l.x+6 >= t.box.x1 and s_l.x+2 <= t.box.x2) then
				if (s_l.y <= t.box.y2 and s_l.y+4 > t.box.y2) then
			 	sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					t.health-=3
					if (t.health<=0) then
 	 	 	sfx(2)
 	 	 	if t.xtra_life==1 then
 	 	 		make_life((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2)
 	 	 	end
 	 	 	del (turrets, t)
 	 	 	explode((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2,3.5,40,1)
 	 			ship.score+=25
 	 		end
				end
				if (s_l.y+4 >= t.box.y1 and s_l.y < t.box.y1) then
					sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					t.health-=3
					if (t.health<=0) then
 	 	 	sfx(2)
 	 	 	if t.xtra_life==1 then
 	 	 		make_life((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2)
 	 	 	end
 	 	 	del (turrets, t)
 	 	 	explode((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2,3.5,40,1)
 	 			ship.score+=25
 	 		end
				end
			end
	
			if (s_l.y+4 >= t.box.y1 and s_l.y <= t.box.y2) then
				if (s_l.x+2 <= t.box.x2 and s_l.x+6 > t.box.x2) then
			 	sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					t.health-=3
					if (t.health<=0) then
 	 	 	sfx(2)
 	 	 	if t.xtra_life==1 then
 	 	 		make_life((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2)
 	 	 	end
 	 	 	del (turrets, t)
 	 	 	explode((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2,3.5,40,1)
 	 			ship.score+=25
 	 		end
				end
				if (s_l.x+6 >= t.box.x1 and s_l.x+2 < t.box.x1) then
					sfx(1)
			 	del(spec_lsr,s_l)
					explode(s_l.x+4,s_l.y,1,20,2)
					t.health-=3
					if (t.health<=0) then
 	 	 	sfx(2)
 	 	 	if t.xtra_life==1 then
 	 	 		make_life((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2)
 	 	 	end
 	 	 	del (turrets, t)
 	 	 	explode((t.box.x1+t.box.x2)/2,(t.box.y1+t.box.y2)/2,3.5,40,1)
 	 			ship.score+=25
 	 		end
				end
			end
		end

	end
end

function ship_is_hit()
	for l_as in all(lg_ast) do
		if (ship.box.x2 >= l_as.box.x1 and ship.box.x1 <= l_as.box.x2) then
			if (ship.box.y1 <= l_as.box.y2 and ship.box.y2 > l_as.box.y2) then
			 return true
			end
			if (ship.box.y2 >= l_as.box.y1 and ship.box.y1 < l_as.box.y1) then
				return true
			end
		end
	
		if (ship.box.y2 >= l_as.box.y1 and ship.box.y1 <= l_as.box.y2) then
			if (ship.box.x1 <= l_as.box.x2 and ship.box.x2 > l_as.box.x2) then
			 return true
			end
			if (ship.box.x2 >= l_as.box.x1 and ship.box.x1 < l_as.box.x1) then
				return true
			end
		end
	end
	
	for m_as in all(med_ast) do
		if (ship.box.x2 >= m_as.box.x1 and ship.box.x1 <= m_as.box.x2) then
			if (ship.box.y1 <= m_as.box.y2 and ship.box.y2 > m_as.box.y2) then
			 return true
			end
			if (ship.box.y2 >= m_as.box.y1 and ship.box.y1 < m_as.box.y1) then
				return true
			end
		end
	
		if (ship.box.y2 >= m_as.box.y1 and ship.box.y1 <= m_as.box.y2) then
			if (ship.box.x1 <= m_as.box.x2 and ship.box.x2 > m_as.box.x2) then
			 return true
			end
			if (ship.box.x2 >= m_as.box.x1 and ship.box.x1 < m_as.box.x1) then
				return true
			end
		end
	end
	
	for s_as in all(sm_ast) do
		if (ship.box.x2 >= s_as.box.x1 and ship.box.x1 <= s_as.box.x2) then
			if (ship.box.y1 <= s_as.box.y2 and ship.box.y2 > s_as.box.y2) then
			 return true
			end
			if (ship.box.y2 >= s_as.box.y1 and ship.box.y1 < s_as.box.y1) then
				return true
			end
		end
	
		if (ship.box.y2 >= s_as.box.y1 and ship.box.y1 <= s_as.box.y2) then
			if (ship.box.x1 <= s_as.box.x2 and ship.box.x2 > s_as.box.x2) then
			 return true
			end
			if (ship.box.x2 >= s_as.box.x1 and ship.box.x1 < s_as.box.x1) then
				return true
			end
		end
	end
	
	for t in all(turrets) do
		if (ship.box.x2 >= t.box.x1 and ship.box.x1 <= t.box.x2) then
			if (ship.box.y1 <= t.box.y2 and ship.box.y2 > t.box.y2) then
			 return true
			end
			if (ship.box.y2 >= t.box.y1 and ship.box.y1 < t.box.y1) then
				return true
			end
		end
	
		if (ship.box.y2 >= t.box.y1 and ship.box.y1 <= t.box.y2) then
			if (ship.box.x1 <= t.box.x2 and ship.box.x2 > t.box.x2) then
			 return true
			end
			if (ship.box.x2 >= t.box.x1 and ship.box.x1 < t.box.x1) then
				return true
			end
		end
	end
	
	for s_as in all(sm_ast) do
		if (ship.box.x2 >= s_as.box.x1 and ship.box.x1 <= s_as.box.x2) then
			if (ship.box.y1 <= s_as.box.y2 and ship.box.y2 > s_as.box.y2) then
			 return true
			end
			if (ship.box.y2 >= s_as.box.y1 and ship.box.y1 < s_as.box.y1) then
				return true
			end
		end
	
		if (ship.box.y2 >= s_as.box.y1 and ship.box.y1 <= s_as.box.y2) then
			if (ship.box.x1 <= s_as.box.x2 and ship.box.x2 > s_as.box.x2) then
			 return true
			end
			if (ship.box.x2 >= s_as.box.x1 and ship.box.x1 < s_as.box.x1) then
				return true
			end
		end
	end
	
	for e_l in all(enm_lsr) do
		if (ship.box.x2 >= e_l.x+2 and ship.box.x1 <= e_l.x+6) then
			if (ship.box.y1 <= e_l.y+4 and ship.box.y2 > e_l.y+4) then
			 return true
			end
			if (ship.box.y2 >= e_l.y and ship.box.y1 < e_l.y) then
				return true
			end
		end
	
		if (ship.box.y2 >= e_l.y and ship.box.y1 <= e_l.y+4) then
			if (ship.box.x1 <= e_l.x+6 and ship.box.x2 > e_l.x+6) then
			 return true
			end
			if (ship.box.x2 >= e_l.x+2 and ship.box.x1 < e_l.x+2) then
				return true
			end
		end
	end
end		


-->8
--explosions
function explode(x,y,r,particles,kind)
	local selected = 0
	for i=1,#sparks do
		if not sparks[i].alive then
			sparks[i].x=x
			sparks[i].y=y
			sparks[i].vely = -1+rnd(2)
			sparks[i].velx = -1+rnd(2)
			sparks[i].mass = 0.5+rnd(2)
			sparks[i].r = 0.5 + rnd(r)
			sparks[i].alive = true
			sparks[i].kind = kind
			selected+=1
			if selected == particles then
				break
			end
		end
	end
end

__gfx__
00000000000880000000000000000000000000000000000000000000000000000000000000005555555000000000000000000000000000000000000000000000
00000000000550000000000000000000000000000000000000000000000000000000000005555616111155000000000000000000000000000000000000000000
00700700006556000000c00000000000000000000000000000000000000000000000000555666166661115500000000000000000000000055555550000000000
00077000065cc5600000c00000066600000666000000600000000000000000000000005566666666116611150000000000000000000055555111555500000000
000770000651c5600000900000611d6000699a600005660000000000000000000000055566666666666161150000000000000000005556111111111550000000
007007006551c5560000a00000511160005999600005c60000000000000000000000565666666666666661155000000000000000055566666666111155000000
000000005522dd550000000000511160005999600056c66000000000000000000005566666666666666661115000000000000005555666666616661115500000
000000000062d600000000000005560000055600005ddd6000000000000000000055556666666666666666115500000000000555666666666666666611150000
00022000000cc0000000000000080000000800000008000000000000000000000055666666666666666666666500000000055556566666666666666611155000
0088820000c3bc000000000000808000008980000089800000000000000000000556665666666666666666661550000000556566666666666666666661115000
088a982000133c00000c000000000000009090000a909a0000000000000000000556566666666666666666666155000005566666666666666666666666611500
088998200001c000000c000000000000000000000a000a0000000000000000000565566666666666666666666615000005665656666666666666666661661500
88e88e22000000000009000000000000000000000000000000000000000000005565666666666666666666666661500005565666666666666666666666161550
080ee02000000000000a000000000000000000000000000000000000000000005555666566666666666666666666500056566666666666666666666666661150
0a0000a0000000000000000000000000000000000000000000000000000000005666566666666666666666666666500055656656666666666666666666666650
00000000000000000000000000000000000000000000000000000000000000005556556666666666666666666666550056665666666666666666666666666650
000005555550000000099000000ee000000ee000000ee000000ee000000ee0005556666666666666666666666666550055556666666666666666666666666650
00005661111500000098a90000e11e0000e11e0000ec1e0000ecce0000e1ce005555565666566666666666666666650056566656666666666666666666666650
00009616611900000048890002111ce002c11ce002cc11e0021cc1e00211cce05556666666666666666666666666650056555666666666666666666666666650
00008666661800000004900002111ce002c11ce002cc11e0021cc1e00211cce00565565566666666666666666666650055655656666666666666666666666550
05986666661189500000000000211e0000211e00002c1e00002cce000021ce000555556665666666666666666666550005565565566666666666666566665500
566666dddd6111150000000000022000000220000002200000022000000220000555556556666666666566665666550005656566665666666666666666665500
56666d8899d666650000000000000000000000000000000000000000000000000055555656656565666666656655500005555555655666666666655666555500
56566289a8d666650000000000000000000000000000000000000000000000000000005566555666666655566655500000565666656666666666656655550000
5566629aaad666650000000000000000000000000000000000000000000000000000005555666556556566555555000000555555666665666656665550000000
555662aaaad666650000000000000800000008000000080000000800000008000000000056665666666665555550000000055655565655666665565550000000
555556222d6666650000000000068800000588000005880000058800000688000000000055556565665565555500000000005555566566666665655000000000
05985666666689500000000000566800005568000055580000655800006658000000000055656566555555555000000000000555655666565565655000000000
000085656668000000000000005c680000516800005c580000615800006c58000000000005555665555555550000000000000055565555555556555000000000
000095566569000000000000055c888005518880065c888006618880066c88800000000005555555555555000000000000000005555555565556555000000000
00005555565500000000000005ada60005ddd60006ada60006ddd50006ada5000000000000005555555500000000000000000000055555555555550000000000
00000555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555550000000000000
66655000000566650000000000000000000005555555000000000000000000000000000000000000000000000000000000000000000000000000000000550000
56550000000566650000000000000000005555111155555000000000000000555500000000000555550000000000000000000555555500000000000005615000
56500000000055660000000000000000055566661111155550000000000055561550000000055661115500000000000000555611155555500000000055661150
66500000000005660000000000000000055566666661111555000000000556616150000000556666611550000000000055556666111115500000000056666150
55500000000005660000000000000000055666666166611115500000005566611115000000566666161155000000000555666666661111550000000056566665
65550000000056560000000000000000055666666616616611150000005666666111550005556666661115000000005566666666611111550000000005665665
66655000000566660000000000000005556666666666661611155000055665666661115005566666666615500000055666666666666661150000000005555565
56666500005665660000000000000005566666666666666611115500056565666666666505556666666611500000556666666666666161155500000000005550
66566500005666650000000000005555656666666666666661111500056656666666661555666666666666500005556666666666666666111500000000055500
66665000000556660000000000555565666666666666666666661550055666566666666555655665665665500005566666666666666666661155550005561150
65650000000055560000000000556566566666666666666666666650056556566666666556566656665655000055566666666666666666666115555005666115
66500000000005550000000000566566566666666666666666666650005665556565665005655665666500000055665666666666666666666611555005666615
66500000000005660000000005566666566666666666666666666655005565656565555005555666655000000055655566666666666666666161115055566650
66550000000005650000000005565565666666666666666666665565000555556656550000556655665000000055566666666666666666666661115555656500
56665000000055650000000005566666666666666666666666666665000005555565500000055656650000000055556666666666666666666666616556565500
56555000000556660000000005566566655666666666666666666565000000005550000000000555500000000055566565666666666666666666666505550000
00000500005000000000000005565665666666666666666666666665000000055550000000000055500000000055565566666666666666666666666505550000
00005690091500000000000005556665666655666666666666666655000000566115500000005561555500000005565666666666666666666666666556615550
00056668811150000000000005556566666656666666666666666665000005666611550000055661111555000005566665666666666666666666665556661150
00566666116115000000000005555665665666666666666666656650000005666661155000556666161115500005556566666666666666666666665555666615
05666666666611500000000000555666565666566555666655656650000056666666115000566666666111500000555566565666666666666666665005566665
565566dddd6161150000000000555566566556666566656666666550005565666616115505666666661661150000555565666666666666666666655005556555
09656d9988d666900000000000055555556666656566656656565500055666666666661505565666666666650000055566665656666666666665655000055650
0086528a98d668000000000000055555665556566656566665555000056656666666665505666565666665650000005665556666666666666556550000005500
008662aaa9d668000000000000005565556556555666555655500000055566566666665005555666666666650000005565566665566656666665550000005550
095662aaaad666900000000000000555565556655566555550000000055656666666665000566565665566550000000556655656556665665565500000551155
555566222d6666650000000000000055565556566565555000000000005565556665655000055565656565500000000555665666566566656665000000566115
05556666666666500000000000000005555665555555550000000000005565665656650000000566556665500000000055555656556656555550000005566615
00555656566665000000000000000000555555555555000000000000000556656656550000000056565555000000000055555555565665565500000055665650
00056568856550000000000000000000005555555000000000000000000055566565500000000055655550000000000005565555565556555000000055656650
00005590095500000000000000000000000000000000000000000000000000555550000000000005555000000000000000555555555555500000000005565550
00000500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555500000000000000555000
00000000000000000000000000000000000000000000000000000000000000000888880008000000088888800888888000888880088888800888880000088000
00000000000000000000000005500000000000000000000000000000000000000800008008000000080000800800000000008000080000000800008000088000
00000000000000000000005555500000000000000055555555000000000000000800008008000000080000800800000000008000080000000800008000088000
00000000000000000005555111500005555555555551111115000000000000000888880008000000088888800888888000008000088880000888880000088000
00000000000000000555111111550005111111111111111115000000000000000800008008000000080000800000008000008000080000000800080000088000
00000055555555550511111111555555151111111111111115000000000000000800008008000000080000800000008000008000080000000800008000000000
00005555566666655515111111566655555111111111111115000000000000000800008008000000080000800000008000008000080000000800008000088000
00555666666666665111111111566666651111111111111115000000000000000888880008888880080000800888888000008000088888800800008000088000
22556566666666666551111555566666551511111111111155222222222222220000000000000000000000000000000000000000000000000000000000000000
88855556666555666555115885666666511151111111555558888888888888880000000000000000000000000000000000000000000000000000000000000000
99995666665595566651115995656666555555511115599999999999999999990000000000000000000000000000000000000000000000000000000000000000
99995556665595566651115995566666599999511115999999999999999999990000000000000000000000000000000000000000000000000000000000000000
aaaaa556666555666655115aa56666655aaaaa511115aaaaaaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000
aaaaaa56666666666651115555556665aaaaaa551115aaaaaaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000
99999956666666666551111111156665999999511115999999999999999999990000000000000000000000000000000000000000000000000000000000000000
99999955666666665511511111156665999999511115995555555555599999990000000000000000000000000000000000000000000000000000000000000000
99999995666665555151111111556665999999511155995666666666599999990000000000000000000000000000000000000000000000000000000000000000
99999995656666665551111555566655999999511159995566666666599999990000000000000000000000000000000000000000000000000000000000000000
99999995666666666665511156666659999995511159955656666666599999990000000000000000000000000000000000000000000000000000000000000000
aaaaaaa556566666666655115566665aaaaaa511115aa56565665665aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000
99999995665666666666655115666659999995111159955555555555999999990000000000000000000000000000000000000000000000000000000000000000
99999995666655555566665115555559999995111159999999999999999999990000000000000000000000000000000000000000000000000000000000000000
99999995666659999556665511111559999951111159999999999999999999990000000000000000000000000000000000000000000000000000000000000000
99999995666659999956666511111559999955111155999999999999999999990000000000000000000000000000000000000000000000000000000000000000
88888855656655888556666511111555888851511115888888888888888888880000000000000000000000000000000000000000000000000000000000000000
88888856566666555566666511111565555515155115888888888888888888880000000000000000000000000000000000000000000000000000000000000000
00000556556666666666666555555566666555555515500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000565666666666666665555566665666666666511500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555655566566666655005655666666666665555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005556656565566550005555556566566565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555555555500000000055555556655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000008080020080800200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808002030503050080800200000001000000000000000000000000000000000000000003050000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
000400002b31025410213101c41019310144100f6100a610000001e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000057700c660137500e65007730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002b6422764324632206331e6341b62419624166231462412623116220f6220e6230c6240a6230861207613066130461403612026120161000000000000000000000000000000000000000000000000000
0104000035476316662c65625646216461e6361a436176361363612626114260f4260f6260f6260e6260e6260d6260d6260d6260d6260e4261260014600164001a6001e600236002a400314003a6000000000000
0005000016570195601b5501f54022530265202d55036550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000003420060200c420100300e430100401344018040144500f0500e45010060154601a0601e4602606032410000000000000000000000000000000000000000000000000000000000000000000000000000
00070000015500155007150071500155001550171501715001550015502515025150015502315023150015502e1502e1501030011300123001330015300173001a3001f30023300273002a3002c3002d30000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c0530000000000000000c6550000000000000000c0530000000000000000c6550000000000000000c0530000000000000000c6550000000000000000c0530000000000000000c6550c6550000000000
011000200241402410034140241002410034100241003410024100241003410024100241003410024100341002410024100321002410024100241002210024100241002310022100211002410023100221002110
011000230000000000000000520000000000002851000000000000000000000000000000000000285101c51000000000000000000000000000000028510000000000000000000000000000000000002851034510
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 0a 0b 0c 0d
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
