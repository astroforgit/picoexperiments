pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--simple shooter vol2 1.2
--by eduardo szesz
--music:
-- boss: pico-8 tunes vol 1
-- by gruber


function _init()
 t=0
 shield_co=7
 blink=0
 dy=1
 e_dx=1
 pt_stage=500
 pt_final=2010
 mark_x=30
 mark_y=70
 difficulty="normal"
 players=0
 normal_co=7
 hard_co=5
 solo_co=7
 co_op_co=5
 mp_pt=1
 give_time = 0
 stage = false
	stage_time = 0
	stage_n = 1
 begin_game = false
 give = true
 giveb = true
 win = false
	music(0,100,0)
	boss_radius = 60
	n_enemies=0
	tt={	
 ms=0, s=0, m=0
	} -- time table for timer function
 create_entities()		 
 title_screen()
end

function title_screen()
_update = update_title
_draw = draw_title

end
function set_difficulty()
	if difficulty=="normal"
	and players==0 then
		pt_stage=500
		pt_final=2010
		boss.h=5
	end
	
	if difficulty=="normal"
	and players==1 then
		pt_stage=1000
		pt_final=4010
		boss.h=5
		boss2.h=5
	end
	
	if difficulty=="hard"
	and players==0 then
		pt_stage=1000
		pt_final=4010
		boss.h=8
	end
	
	if difficulty=="hard"
	and players==1 then
		pt_stage=2000
		pt_final=8010
		boss.h=8
		boss2.h=8
	end
	
end

function update_title()
set_blink()

	if btnp(3) then
		sfx(7)
		difficulty="hard"
		normal_co=5
		hard_co=7
		mark_y=100
	end
	if btnp(2) then
		sfx(7)
		difficulty="normal"
		normal_co=7
		hard_co=5
		mark_y=70
	end

if btnp(1) then
		sfx(7)
		players=1
		solo_co=5
		co_op_co=7
		mp_pt=2
		mark_x=100
	end
	if btnp(0) then
		sfx(7)
		players=0
		solo_co=7
		co_op_co=5
		mark_x=30
	end

set_difficulty()


	if btn(5) then
		sfx(6)
		begin_game = true 
	end
	if begin_game == true then start() end

end

function draw_title()
	cls()
	print("—",mark_x,mark_y,blink_co)
	print("apprentice",45,70,normal_co)
	print("master",50,100,hard_co)
	print("solo",10,83,solo_co)
	print("co-op",100,83,co_op_co)
	print("by eduardo szesz",40,120,11)	
	--print(pt_stage.." "..pt_final,40,90,blink_co)
	map()

end


function start()
 _update = update_game
 _draw = draw_game
end

function game_over()
 _update = update_over
 _draw = draw_over
end

function update_over()
	music(-1)
	set_stars()
	if btnp(5)	then
	 sfx(6)
	 keep_diffi=difficulty
	 keep_pl=players
	 _init()
	 difficulty=keep_diffi
	 players=keep_pl
	 set_difficulty()
	 begin_game = true
	 start()
 end 
end

function draw_over()
 cls()
 draw_stars()
 if win == false then
 print("game over",50,50,4)
 print("score "..tostr(ship.p),50, 60,6)
 print("your time:"..tt.m..":"..tt.s,50,70,6)
 print("press —",50,80,3)
 print("to play again", 50,90,3)
 else
 	print("congratulations!",50,50,4)
 	print("you win! ",50,60,7)
 	spr(42,85,60)
 
 	print("press —",50,70,3)
 	print("to play again", 50,80,3)
 end
end

function go_boss()
 boom.act=false
 _update = update_boss
 _draw = draw_boss
 
end
 
function update_boss()
 t=t+1

	give_life()

	change_music()
	
	boss_dead()

	for e in all(enemies) do
		del(enemies,e)
	end
 
 timer()
 
 set_shield(ship)
 
 off_bonus(ship)
 
 firerate_update(ship)
 
 warp_bar(ship)
 
 cooling_gun(ship,0)
 
 set_blink()
  
 f_stage()
 
 player_dead(ship)
 
 controls(ship,0)
  
 set_bullets(bb,b_bullets)
 
 fire_boss(boss)
 
 immortal(ship,90)
 
 immortal(boss,85)
 
 outscreen(ship)
 
	set_stars()
 
 set_warp(ship)
 
 set_explosions()
 
 anime_ship(ship,1,2)
 
 move_boss(boss)
 
 if not give then
	life.y+=life.m
end

	
	collisions_boss(ship,boss)
	 
 if players==1 then
 	set_shield(ship2)
 	off_bonus(ship)
 	collships()
 	set_warp(ship2)
 	anime_ship(ship2,49,50)
 	controls(ship2,1)
 	firerate_update(ship2)
 	outscreen(ship2)
 	cooling_gun(ship2,1)
		immortal(boss2,85) 	
 	immortal(ship2,90)
 	warp_bar(ship2)
 	fire_boss(boss2)
 	move_boss(boss2)
 	collisions_boss(ship2,boss2)
 	collisions_boss(ship,boss2)
 	collisions_boss(ship2,boss)
 	player_dead(ship2)

		 if ship.h <= 0 
			 and ship2.h<=0 then
     game_over()
 		end

 end
 
 if ship.h <= 0
 and players==0 then
     game_over()
 end
 

 
end

function draw_boss()

cls()
	
	--print(boss.h,50,50,8)
	--print(boss2.h,50,60,8)
	
	pr_stage()
	
	draw_stars()
	
	draw_bar(ship,0,1,6)
	
		draw_health(ship,0)
		
		draw_shield(ship)
	
  if not give then
 	spr(33,life.x,life.y)
 	end
  

 if not ship.imm or t%8 < 4 then
  spr(ship.sp,ship.x,ship.y)
 end
 
 draw_warp(ship)
 
 if players==1 then
 if not ship2.imm or t%8 < 4 then
  spr(ship2.sp,ship2.x,ship2.y)
 end
 draw_warp(ship2)
	draw_health(ship2,120) 
 draw_bar(ship2,120,121,126)
 d_boss(boss2,66)
 draw_shield(ship)
 
 end
 
 for ex in all(explosions) do
  circ(ex.x,ex.y,ex.t/2,8+ex.t%3)
 end
  
 for b in all(bullets) do 
  spr(b.sp,b.x,b.y)
 end
 
 for bb in all(b_bullets) do
 	spr(bb.sp,bb.x,bb.y)
 end
 
 d_boss(boss,64) 
 

end

function create_entities()
	ship = {
  sp=1,
  x=20,
  y=100,
  px=20,
  py=100,
  h=4,
  p=0,
  t=0,
  f=false,
  dirx=true,
  diry=true,
  shield=false,
  warp_l=45,
  imm=false,
  heat=50,
  fire_rate_d=5,
  fire_rate_t=0,
  fire_t=0,
  dfire=false,
  warp={},
  fshield={
 	x=32,
 	y=-10,
 	t=0,
 	box = {x1=-7,y1=-7,x2=7;y2=7},
 	},
  box = {x1=0,y1=0,x2=7,y2=7}}
  
  ship2 = {
  sp=49,
  x=100,
  y=100,
  px=100,
  py=100,
  h=4,
  p=0,
  t=0,
  f=false,
  dirx=true,
  diry=true,
  shield=false,
  warp_l=45,
  imm=false,
  heat=50,
  fire_rate_d=5,
  fire_rate_t=0,
  fire_t=0,
  dfire=false,
  warp={},
  fshield={
 	x=32,
 	y=-10,
 	t=0,
 	box = {x1=0,y1=0,x2=15;y2=15},
 	},
  box = {x1=0,y1=0,x2=7,y2=7}}
  
 flag="none"
 change_m=false
 bullets = {}
 enemies = {}
 explosions = {}
 stars = {}
 e_bullets = {}
 b_bullets = {}
 r_edge={x=132,
 	y=-100,
 	box = {x1=0,y1=0,x2=7;y2=300}}
 
 l_edge={x=-7,
 	y=-100,
 	box = {x1=0,y1=0,x2=7;y2=300}}

 bonus={sp=43,
 	x=32,
 	y=-10,
 	m=0,
 	t=0,
 	imm=false,
 	box = {x1=1,y1=0,x2=6,y2=6},
 	}
 	
 	boom={sp=55,
 	x=64,
 	y=130,
 	r=1,
 	t=0,
 	exe=false,
 	act=false,
 	box = {x1=-64,y1=-64,x2=64,y2=64},
 	}
 	
 life={sp=33,
 	x=32,
 	y=-10,
 	m=0,
 	box = {x1=1,y1=0,x2=6,y2=6},
 	}
 	
 boss = {
 	sp = 13,
 	x=60,
 	y=-20,
 	h=5,
 	d=1,
 	t=0,
 	dy=1,
 	boss_radius=10,
 	imm=false,
 	dead=false,
 	mx=0,
 	box = {x1=7,y1=5,x2=11,y2=9}}
 
 boss2 = {
 	sp = 45,
 	x=100,
 	y=-20,
 	h=5,
 	d=1,
 	t=0,
 	dy=1,
 	boss_radius=10,
 	imm=false,
 	dead=false,
 	mx=0,
 	box = {x1=7,y1=5,x2=11,y2=9}}
 
 
 for i=1,128 do
  add(stars,{
   x=rnd(128),
   y=rnd(128),
   s=rnd(2)+2
  })
 end 
end

function change_music()
	if change_m then
		music(-1)
	
		
		if stage_n==3 then
			music(5,0,5)
		end
		
	
		if stage_n==5 then
			music(1,0,1)
		end
		change_m=false
	end
end


function firerate_update(a)
	a.fire_rate_t-=1 
	a.fire_rate_d=0.25*a.heat-7.5
end


function warp_bar(a)
	if a.warp_l<45 then
		if t%30==0 and a.warp_l <=45 then
			a.warp_l+=5
		end	
	end
end

function draw_bar(a,y1,y2,y3)
rectfill(20,y1,45,y3,1)
rectfill(20,y1,a.warp_l,y3,12)
print("warp", 25,y2,12)

rectfill(50,y1,85,y3,11)
rectfill(50,y1,a.heat,y3,8)
local txtcolor=11
if a.heat>80 then
	txtcolor=blink_co
end
print("overheat", 52,y2,txtcolor)

end

function pr_stage1()
	if t<60 then
	print("stage 1",50,40,blink_co)
	end
end

function pr_stage()
	
	if stage then
	stage_n = flr((ship.p/pt_stage))+1
	if ship.p>=pt_final then
	print("final stage",50,40,blink_co)
	else
	print("stage "..tostr(stage_n),50,40,blink_co)
	end
	end
end



function set_stars()
 for st in all(stars) do
 st.s=rnd(stage_n)+2
  st.y += st.s
  if st.y >= 128 then
   st.y = 0
   st.x=rnd(128)
  end
 end
end

function draw_stars()
	for st in all(stars) do
  pset(st.x,st.y,6)
 end
end

function set_blink()
	blink +=1
	if blink > 10 then
		blink=0
	
	if blink_sp == 17 then
		blink_sp = 34
	else
		blink_sp = 17
	end
	if blink_co == 7 then
		blink_co = 5
	else
		blink_co = 7
	end
	
	
end
end

function respawn()
	move=1
	rndmove=rnd(1)
	
	if rndmove<0.2then
		move=2
	end
	
	if rndmove>=0.2 and
	rndmove<0.3 then
		move=3
	end
	
	if rndmove>=0.3 and
	rndmove<0.4 then
		move=4
	end
	if rndmove>=0.4 and
	rndmove<0.5 then
		move=5
	end
	
	
 local n = flr(rnd(3+flr(stage_n)))+5
 local sprite = flr(rnd(6))+7 
 local coef_y = rnd(4)+4
 local coef_x = flr(rnd(10))+8
 local radius = flr(rnd(flr(stage_n)))+14
 local health=1
 local trocar=true
 
 if move==2 then
 	coef_y=8
 	coef_x=16
 	radius=14
 end
 
 if move==3 then
 	coef_y=-(rnd(30)+7)
 	coef_x=16
 end
 

 if move>=4 then
 	coef_y=rnd(80)+10
 	coef_x=16
 end
 
 if difficulty=="hard" then
 	if sprite==11 or sprite ==12
 	or sprite ==10 then
			health=2
		end 
 end
 
 n_enemies=n
 for i=1,n do
  local d = -1
  if rnd(1)<0.5
  and move==1 then d=1 end
 add(enemies, {
  sp=sprite,
  m_x=i*(coef_x),
  m_y=-80-d*i*coef_y,
  d=d,
  dx=1,
  dy=0,
  ddx=0,
  dirx=true,
  imm=false,
  t=0,
  h=health,
  x=-32,
  y=-20,
  r=radius,
  dead="no",
  box = {x1=0,y1=0,x2=7,y2=7}
 })
 end

 
 if move==2 then
 if #enemies>9 then
 	for e in all(enemies)do
 		del(enemies,e)
 	end
 end
 
 end
 
 if move==3 then
 if #enemies>6then
 	for e in all(enemies)do
 		del(enemies,e)
 	end
 end
 	for e in all(enemies)do
 		e.x=2
 		e.y=coef_y
 		e.dy=coef_y	
 	end	
 end
 
 if move==4 then
 	for e in all(enemies)do
 		e.x=-200
 		e.ddx=-200
 		if trocar then
 		e.y=coef_y
 		e.dy=coef_y
 		trocar=false
 		else
 			e.y=coef_y+10
 			e.dy=coef_y+10
 			trocar=true
 		end
 	end
 end
 
 if move==5 then
 	for e in all(enemies)do
 		e.x=300
 		e.ddx=300
 		if trocar then
 		e.y=coef_y
 		e.dy=coef_y
 		trocar=false
 		else
 			e.y=coef_y+10
 			e.dy=coef_y+10
 			trocar=true
 		end
 	end
 end
 
 
if move>1 and move<5 then
for e in all	(enemies)do
	e.x+=e.m_x
	e.ddx+=e.m_x
end
end

if move==5 then
for e in all	(enemies)do
	e.x-=e.m_x
	e.ddx-=e.m_x
end
end



end


function abs_box(s)
 local box = {}
 box.x1 = s.box.x1 + s.x
 box.y1 = s.box.y1 + s.y
 box.x2 = s.box.x2 + s.x
 box.y2 = s.box.y2 + s.y
 return box

end

function coll(a,b)
 
 local box_a = abs_box(a)
 local box_b = abs_box(b)
 
 if box_a.x1 > box_b.x2 or
    box_a.y1 > box_b.y2 or
    box_b.x1 > box_a.x2 or
    box_b.y1 > box_a.y2 then
    return false
 end
 
 
 return true 
 
 
end

function set_bullets(a,b)
	
	for a in all(b) do
		a.x+=a.dx
		a.y+=a.dy
		if a.x < 0 or a.x > 128 or
		 a.y > 128 then
			del(b,a)
		end	
	
end
end

function go_stage()

	if ship.p%(pt_stage) == 0 
	and stage == false  
	and ship.p~=0 then
		stage_n = flr((ship.p/pt_stage))+1
		if stage_n==3 
		or stage_==5 then
			change_m=true
		end
		stage = true
		if stage_n<5then
		sfx(-1,3)
		sfx(15,3)
		end
	end	
	
	if stage == true then
		stage_time +=1
	end
	if stage_time == 90 then
		stage = false
		stage_time = 0
	end	

end

function f_stage()
	if stage == true then
		stage_time +=1
	end
	if stage_time == 90 then
		stage = false
		stage_time = 0
	end	
end

function give_bonus()

	
	if ship.p%(130) == 0
	and giveb
	and ship.p~=0 then
	
	bonus.m=1
	bonus.x=rnd(110)+7
	giveb = false
	give_points()
	end	
end

function off_bonus(a)
	if giveb == false then
	a.fshield.t+=1
	end
	if a.fshield.t==900 then
		giveb = true
		a.fshield.t = 0
		bonus.m=0
		bonus.y=-10
		a.shield=false	
		
	end	
	
end

function set_shield(a)
	if a.shield then
	a.fshield.x=a.x+3
	a.fshield.y=a.y+3
	end
	if a.fshield.t==900
	or not a.shield then
	a.fshield.x=-32
	a.fshield.y=-10
	
	end
	
end

function draw_shield(a)


if a.fshield.t>750 then
	shield_co=blink_co
else
	shield_co=7	
end

if a.shield then
	circ(a.fshield.x,a.fshield.y,9,shield_co)
end

end

function give_life()

	if (ship.h < 4 or ship2.h<4)
	and ship.p%(pt_stage) == 0
	and give
	and ship.p~=0 then
	
	life.m=1
	life.x=rnd(110)+7
	give = false
	give_points()
	end	
	
	if (ship.h==4 and ship2.h==4)
	and ship.p%(pt_stage) == 0
	and give
	and ship.p~=0
 then
		give_points()
	end
	
	if give == false then
	give_time +=1
	end
	if give_time == 300 then
		give = true
		give_time = 0
		life.m=0
		life.y=-10
		
	end	
	

end

function fire_enemy()

for e in all(enemies) do
if rnd(1)< (0.15*flr(stage_n)-0.1)
 and t%30 == 0
and e.y>0 and e.y <50 
and e.x>0 and e.x<120 then
sfx(1)
local eb = {
	sp=4,
	x=e.x,
	y=e.y,
	dx=0,
	dy=3,
	box = {x1=3,y1=0,x2=4,y2=3}
 }
 add(e_bullets,eb)
end
end
end


function d_boss(a,i)
if not a.imm or t%8 < 4 then
  spr(a.sp,a.x,a.y,2,2)
 else
  spr(i,a.x,a.y,2,2)
 end
 
end

function move_boss(a)

if a.y < 10 then
 a.dy = rnd(1)+1
	a.boss_radius = rnd(60)
	if rnd(1) <0.5 then
		a.d = -1
	else
		a.d=1	
	end
	
end
if a.y > 110 then
 a.dy = -(rnd(1)+2)
	a.boss_radius = rnd(60)
	a.mx = rnd(110)
end

if not a.dead
and not stage then
  a.x =a.boss_radius*cos(t/45)+a.mx
  a.y = a.y+a.dy
end


end

function collisions_boss(a,c)
	
 for bb in all(b_bullets) do
 if coll(a, bb)
 and not a.shield
 and not a.imm then
    a.imm = true
    a.h -= 1
    sfx(3)
    a.dfire=false
    
  end
  if coll(a.fshield,bb)then
  	explode(bb.x,bb.y)
  	del(b_bullets,b)
  	sfx(2)
  end
  
 end
 	 
  if coll(a,c)
  	and not a.shield
   and not a.imm then
    a.imm = true
    a.h -= 1
    sfx(3)
    a.dfire=false
				  
  end 
 
 for b in all(bullets) do
  b.x+=b.dx
  b.y+=b.dy
  if b.x < 0 or b.x > 128 or
   b.y < 0 or b.y > 128 then
   del(bullets,b)
  end
	 
   if coll(b,c)
   and not c.imm and
    c.h>0 then
  		
  		c.imm = true
    c.h-= 1
   
    sfx(2)
   end
end

if coll(a,bonus) then
	bonus.imm=true
	bonus.m=0
	bonus.y=-10
	a.f=true
	
	local chance=rnd(1)
	if chance<=0.3 then
	a.dfire=true
	flag="double"
	end
	
	if chance<0.6 then
	boom.act=true
	flag="none"
	
	end
	if chance>0.3
	and chance<0.6 then
	a.shield=true
	flag="shield"
	end
	
	sfx(6)
end


if coll(a,life) then
	life.m=0
	life.y=-10
	if a.h<4 then
	a.h+=1
	end
	sfx(6)
end

end



function fire_boss(a)


if rnd(1)< 0.85
 and t%15 == 0
 and a.y<60
 and not a.dead
 then
sfx(1)
local bb = {
	sp=4,
	x=a.x,
	y=a.y,
	dx=0,
	dy=3,
	box = {x1=0,y1=0,x2=3,y2=3}
 }
 add(b_bullets,bb)

end
end

function boss_dead()
	if players ==1 then
		if boss.h==0 then
		boss.dead = true
		boss.sp=64
		boss.t +=1
	if boss.t<90 then	
		explode(boss.x+rnd(10)+5,
		boss.y+rnd(10)+5)
		sfx(2)
		
	end
	
	if boss.t>90 then
			boss.y=-20
		end
	end	
	
	if boss2.h==0 then
		boss2.dead = true
		boss2.sp=66
		boss2.t +=1
		if boss2.t<90then
		explode(boss2.x+rnd(10)+5,
		boss2.y+rnd(10)+5)
		sfx(2)
		end
		if boss2.t>90 then
			boss2.y=-20
		end
		
	end
	
	if boss.dead and boss2.dead
	and (boss.t>90 and boss2.t>90) then
		
		ship.imm=true
		ship2.imm=true
		boss.t=0
		boss2.t=0
		win=true
		game_over()
	end	
	
	
	end
	
	
	
	if players==0 then
	if boss.h==0 then
		boss.dead = true
		boss.sp=64
		boss.t +=1
		explode(boss.x+rnd(10)+5,
		boss.y+rnd(10)+5)
		sfx(2)
		ship.imm=true
	end
	if boss.t == 90 then
		
		boss.t=0
		win=true
		game_over()
	end	
	end
end

function go_warp(a,x,y)
 add(a.warp,{x=x,y=y,t=0})
 sfx(5)
 
end


function explode(x,y)
 add(explosions,{x=x,y=y,t=0})
 sfx(2)
end

function outscreen(a)
	if a.x<0 and a.x>-400 then a.x=0 end
	if a.x>120 then a.x=120 end
	if a.y>112 then a.y=112 end
	if a.y<10 then a.y=10 end


end

function double_fire(a,i)
	
		local b = {
  sp=28,
  x=a.x,
  y=a.y,
  dx=0,
  dy=-3,
  box = {x1=0,y1=0,x2=7,y2=7}
 }
  add(bullets,b)
 sfx(0)
 a.heat+=0.6
	
end

function fire(a,i)
		local b = {
  sp=3,
  x=a.x,
  y=a.y,
  dx=0,
  dy=-3,
  box = {x1=0,y1=0,x2=1,y2=3}
 }
  add(bullets,b)
 sfx(0)
 a.heat+=0.6
	
end

function cooling_gun(a,i)
	if not btn(4,i) and a.heat>50.1 then
	a.heat-=0.1
	end
end

function immortal(a,i)
	if a.imm then
  a.t += 1
  if a.t >i then
   a.imm = false
   a.t = 0
  end
 end
end

function set_warp(a)
	for w in all(a.warp) do
  w.t+=1
  if w.t == 13 then
   del(a.warp, w)
  end
 end
end

function set_explosions()
	for ex in all(explosions) do
  ex.t+=1
  if ex.t == 13 then
   del(explosions, ex)
  end
 end
end

function anime_ship(a,i,j)
if(t%8<4) then
  a.sp=i
 else
  a.sp=j
 end
end

function controls(a,i )
	if a.h>0 then
	
	if boom.act and
	btn(5,i)
	and a.f then
	sfx(14)
		boom.exe=true
		a.f=false
		
	end
	
	
	
	local speed = 0
  if btnp(5,i) 
  and a.warp_l == 45
  and (btn(0,i)
   or btn(1,i)or btn(2,i) or btn(3,i))
  then
 	speed = 23.5
 	a.imm = true
 	go_warp(a,a.x,a.y)
 	a.warp_l = 20
 	end
 if btn(0,i) then
 	a.px=a.x
  a.x-=(1.5+speed)
  a.dirx=false
 end
 if btn(1,i) then
 	a.px=a.x
  a.x+=(1.5+speed)
  a.dirx=true
 end
 if btn(2,i) then
 	a.py=a.y
  a.y-=(1.5+speed)
  a.diry=true
 end
 if btn(3,i) then
  a.py=a.y
  a.y+=(1.5+speed)
  a.diry=false
 end
 if btn(4,i) and a.heat<85 and
 a.fire_rate_t<=0 then
 	if not a.dfire then
 	fire(a,i)
 	end
 	if a.dfire then
 		double_fire(a,i)
 	end 	 
 	local firerate = a.fire_rate_d
		 a.fire_rate_t=firerate
	end
end
end

function player_dead(a)
	if a.h<1 then
		
		a.x=-500
		if  a.t<30 and a.imm then
			explode(a.px,a.py)
		end
	end
end


function timer()
 if(tt.ms <= 60) tt.ms+=2
 if(tt.ms >= 60) then
  tt.ms=0
  tt.s+=1
 end
 if(tt.s >= 60) then
  tt.m+=1
  tt.s=0
 end
end

function draw_warp(a)
	for w in all(a.warp) do
  rect(w.x,w.y,a.x+7,a.y+7,w.t/2,8+w.t%3)
 end
end

function draw_health(a,y)
if give == false then
		for i=1,4 do
  if i<=a.h then 
  spr(blink_sp,80+10*i,y)
  else
  spr(18,80+10*i,y)
  end
 end
	else
			for i=1,4 do
  if i<=a.h then 
  spr(17,80+10*i,y)
  else
  spr(18,80+10*i,y)
  end
 end
	end
end

function move_enemies()
	 
	local rate=(0.5*stage_n+0.5)
 local dy = ((0.5)*flr(stage_n))
 for e in all(enemies) do
		 
  e.m_y += dy
  if move==1 then
 	e.x = e.r*sin(e.d*t/45) + e.m_x
 	end
 	if move>1 and move<4 then
 	e.x+=e.dx*1*rate
 	end
 	
 	if move==4 then
 		e.ddx+=e.dx*1*rate
 		e.x=e.r*sin(t/45)+e.ddx
 	end
 	
 	
 	if move==5 then
 		e.ddx-=e.dx*1*rate
 		e.x=e.r*sin(-t/45)+e.ddx
 	end
 	
 	
  if move<=2 then
  e.y = e.r*cos(t/45) + e.m_y
		end
		
		if move==3 then
			e.y=e.r*cos(t/45)+e.dy
		end
		
		if move==4 and e.x>-10 then
			e.y=e.r*cos(t/45)+e.dy
		end
		
		if move==5 then
			e.y=e.r*cos(t/45)+e.dy
		end
		
		
		if coll(e,l_edge)
		and move>1 and move<4then
			e.dx=1
			if move==3 then
				e.dy+=20
			end
		end
		
	if coll(e,r_edge)
	and move>1 and move<4 then
			e.dx=-1
			if move==3 then
				e.dy+=20
			end
		end

  if e.y > 128 then
  	del(enemies,e)
  end
  if e.x > 132 and move!=5 then
  	del(enemies,e)
  end
  if move==5 and e.x<-10 then
  	del(enemies,e)
  end
 end

end

function collisions(a)
	
 for eb in all(e_bullets) do
 if coll(a, eb)
 and not a.shield
 and not a.imm then
    a.imm = true
    a.h -= 1
    sfx(3)
   a.dfire=false
   
  end
  if coll(a.fshield,eb)then
  	explode(eb.x,eb.y)
  	del(e_bullets,e)
  	sfx(2)
  end
  
 end
 	
 	for e in all(enemies) do 
  if coll(a,e)
  and not a.shield
   and not a.imm then
    a.imm = true
    a.h -= 1
    sfx(3)
   a.dfire=false
   
   
  end
  if coll(a.fshield,e) then
  	explode(e.x,e.y)
  	del(enemies,e)
  	sfx(2)
  	give_points()
  end
  end
  
 
 for b in all(bullets) do
  b.x+=b.dx
  b.y+=b.dy
  if b.x < 0 or b.x > 128 or
   b.y < 5 or b.y > 128 then
   del(bullets,b)
  end
  
  
  for e in all(enemies) do
   if coll(b,e) and 
   	e.y>10 and not e.imm then
   	e.imm=true
   	if b.sp==28 then
   	e.h-=2
   	else
   	e.h-=1
   	end
   	sfx(8)
   	if e.h<1 then
    del(enemies,e)
    give_points()
    explode(e.x,e.y)
    sfx(2)
    end
   end
  end
 
end

if coll(a,bonus) then
	bonus.imm=true
	bonus.m=0
	bonus.y=-10
	a.f=true
	
	local chance=rnd(1)

	if chance<=0.3 then
	a.dfire=true
	flag="double"
	end
	
	if chance>=0.6 then
	
	boom.act=true
	flag="killall"
	end
	
	
	if chance>0.3
	and chance<0.6 then
	a.shield=true
	flag="shield"
	end
	
	
		sfx(6)
end


if coll(a,life) then
	life.m=0
	life.y=-10
	if a.h<4 then
	a.h+=1
	end
	sfx(6)
end

end

function killall()

	if boom.exe then
	if boom.y>64 then
		boom.y-=2
	end
	
	if boom.t<=60 then
		boom.t+=1
		boom.r=(boom.t*3-90)
		if boom.y<=64 then
		boom.act=false
	
		end
	end
	if boom.r>60then
	for e in all(enemies) do
		if coll(e,boom)
		and e.y>10 then
			explode(e.x,e.y)
			del(enemies,e)
			give_points()
			
 
			
			
		end
	end
	end
	if boom.t>=60 then
		
		boom.y=130		
		boom.t=0
		boom.exe=false
	end
	
	
end
end


function collships()
	if coll(ship,ship2) then
	
	ship.x=ship.px
	ship2.x=ship2.px
	ship.y=ship.py
	ship2.y=ship2.py
			
		end
end

function pr_bonus()
	if bonus.imm then
		if flag=="shield" then
			print("shield on",50,50,blink_co)
		end
		
		if flag=="double" then
			print("double fire",50,50,blink_co)
		end
		
		if flag=="killall" then
			print("— nuclear strike",30,60,blink_co)
		end
			
	end
	
	if boom.act then
		print("—",0,120,blink_co)
	end
	
	
end

function give_points()
	
		ship.p+=10
		go_stage()
		give_life()
			
			if ship.p == (pt_final) then
 			change_m=true
 			go_boss()
 		end
	
end


function update_game()
	
 t=t+1
 
 timer()
 
 killall()
 
 change_music()
 
 immortal(bonus,45)
 
 give_bonus()
 
 off_bonus(ship)
 
 set_shield(ship)
 
 player_dead(ship)
 
 firerate_update(ship)
 
 warp_bar(ship)
 
 cooling_gun(ship,0)
 
 if ship.p == (pt_final-10) then
 	change_m=true
 	go_boss()
 	
 end
 
 set_blink()
 
 controls(ship,0)
 
 go_stage()
 
 give_life()
 
 set_bullets(eb,e_bullets)
 
 fire_enemy()
 
 immortal(ship,90)
 
 move_enemies()
 
 collisions(ship)
 
 for e in all(enemies) do
 	immortal(e,20)
 end
 
 outscreen(ship)
 
	set_stars()
 
 set_warp(ship)
 
 set_explosions()
 
 anime_ship(ship,1,2)
 
 anime_ship(boom,55,56)
 
 if ship.h <= 0
 and players==0 then
     game_over()
 end
 
 if players==1 then
 	collships()
 	off_bonus(ship2)
 	set_shield(ship2)
 	set_warp(ship2)
 	anime_ship(ship2,49,50)
 	controls(ship2,1)
 	firerate_update(ship2)
 	outscreen(ship2)
 	cooling_gun(ship2,1)
 	collisions(ship2)
 	immortal(ship2,90)
 	warp_bar(ship2)
 	player_dead(ship2)	
 	 if ship.h <= 0 
			 and ship2.h<=0 then
     game_over()
 		end

 end
 
 
 if #enemies <=0 then
  respawn()
 end
 

if not give then
	life.y+=life.m
end

if not giveb then
	bonus.y+=bonus.m
end
	
end


function draw_game()
 cls()
  
	pr_stage()
	
	draw_stars()
	
	pr_stage1()
	
	pr_bonus()
		
	draw_shield(ship)
	
	draw_health(ship,0) 
 if not give then
 	spr(33,life.x,life.y)
 end
 
 if not giveb then
 	spr(43,bonus.x,bonus.y)
 end
 
 print(ship.p,0,0,7)
	if ship.h>0 then 
 if not ship.imm or t%8 < 4 then
  spr(ship.sp,ship.x,ship.y)
 end
 end
 
 if players==1 then
 if ship2.h>0 then
 if not ship2.imm or t%8 < 4 then
  spr(ship2.sp,ship2.x,ship2.y)
 end
 end
 draw_warp(ship2)
	draw_health(ship2,120) 
 draw_bar(ship2,120,121,126)
 draw_shield(ship2)
 end
 
 draw_warp(ship)
 
 
 for ex in all(explosions) do
  circ(ex.x,ex.y,ex.t/2,8+ex.t%3)
 end
  
 for b in all(bullets) do 
  spr(b.sp,b.x,b.y)
 end
 
 for eb in all(e_bullets) do
 	spr(eb.sp,eb.x,eb.y)
 end
 
 for e in all(enemies) do
  if not e.imm or t%8 < 4 then
  spr(e.sp,e.x,e.y)
  else
		spr(27,e.x,e.y)
	 end
 end

draw_bar(ship,0,1,6) 

if boom.exe and boom.y>64 then
	spr(boom.sp,boom.x,boom.y)
end

if boom.exe and boom.y<=64 then

	circ(64,64,boom.r,8) 
	circ(64,64,boom.r-2,10) 
	circ(64,64,boom.r-3,9) 
end

end
__gfx__
00000000000330000003300000090000b0b00000001110000000000000000000000000000000000b000000000000000000600600000000000000000000000000
00000000000330000003300000090000b0b000000055500000000000000ee00000000000b00000b00b000b000000000000066000000000000000000000000000
0070070000033000000330000009000008000000006660000000000000ecce00003333000bbbbb0000bbb0000808808000666600b000b000000b000b00000000
00077000030cc030030cc03000000000b0b00000006660000000000007eeee7003c33c300b707b000bbbbb00008888000665cb600b000b0000b000b000000000
00077000030cc030030cc03000000000b0b0000000666000000070000eeeeee0333333330bb66b0007667b0008b88b8006bcbc6000b000bbbb000b0000000000
0070070003333330033333300000000000000000066666000000000000cccc008333333800bbbbb00b66bb0088888888006bc600000b0b3777b0b00000000000
0000000000388300003aa30000000000000000000688860000000000000ee000009999000b00000bbbaaaab080aaaa08065656600000b337003b000000000000
00000000003aa30000388300000000000000000060aaa060000000000000000000000000b0000000b00000b000000000068aa860000b3b3700b3b00000000000
000000000080080007700770ccc00000cccc000cccc00c00ccc0000cccc0ccccccc000cccccccccc00000000000880009000000900b333b777733b0000000000
000000000888888077777777ccc0ccccccccc0ccccc0c0c0ccc0cc0cccc0ccccccc0cccccccccccc0000000000800800900000090bbcbcbcbcbcbbb000000000
000000000888888007777770ccc0000cccccc0ccccc0ccc0ccc000ccccc0ccccccc000cccccccccc0000000008099080900000090bbbcbcbcbcbcbb000000000
000000000088880000777700cccccc0ccccc000cccc0ccc0ccc0ccccccc0ccccccc0cccccccccccc00000000809009080000000000b3333333333b0000000000
000000000008800000077000ccc0000cccccccccccccccccccccccccccc000ccccc000cccccccccccccccccc8090090800000000000b33bbbb33b00000000000
000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc08099080000000000000bbbbbbbb000000000000
000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0080080000000000000b00000000b00000000000
000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000880000000000000b0000000000b0000000000
000000000080080000c00c00ccc00000cc0000cccc0000ccc00000cccc0cc0ccccc000cccc0000cc000000000099990000000000000000000000000000000000
00000000088878800ccc7cc0ccc0cccccc0cc0cccc0cc0ccccc0cccccc0cc0ccccc0cccccc0cc0cc0aaaaaa00990099000000000000000000000000000000000
00000000088887800cccc7c0ccc0000ccc0cc0cccc0cc0ccccc0cccccc0000ccccc000cccc000cccaa0aa0aa9909909900000000c000c000000c000c00000000
000000000088880000cccc00cccccc0ccc0000cccc0000ccccc0cccccc0cc0ccccc0cccccc00ccccaaaaaaaa99990999000000000c000c0000c000c000000000
0000000000088000000cc000ccc0000ccccccccccccccccccccccccccc0cc0ccccc000cccc0c0ccca0aaaa0a999909990000000000c000cccc000c0000000000
000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccc0cc0ccaa0000aa9999999900000000000c0c1777c0c00000000000
000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc0aaaaaa009990990000000000000c117001c000000000000
000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000099990000000000000c1c1700c1c00000000000
000000000006600000066000c0cc0ccccc0ccccccccccccc0000000000111000001110000000000000000000000000000000000000c111c777711c0000000000
000000000006600000066000c0cc0ccccc0cccccccc00ccc000000000055500000555000000000000000000000000000000000000cc9c9c9c9c9ccc000000000
000000000006600000066000c0cc0ccccc0ccccccc0cc0cc000000000066600000666000000000000000000000000000000000000ccc9c9c9c9c9cc000000000
00000000060cc060060cc060cc00cccccc000ccccccc0ccc0000000000666000006660000000000000000000000000000000000000c1111111111c0000000000
00000000060cc060060cc060ccccc000ccccccccccc0cccc00000000006660000066600000000000000000000000000000000000000c11cccc11c00000000000
000000000666666006666660ccccc0c0cccccccccc0ccccc000000000666660006666600000000000000000000000000000000000000cccccccc000000000000
0000000000688600006aa600ccccc0c0cccccccccc0000cc000000000688860006aaa60000000000000000000000000000000000000c00000000c00000000000
00000000006aa60000688600ccccc000cccccccccccccccc0000000060aaa060608880600000000000000000000000000000000000c0000000000c0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b000b000000b000bc000c000000c000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000b0000b000b00c000c0000c000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b000bbbb000b0000c000cccc000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b0b3888b0b000000c0c1888c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b338003b00000000c118001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b3b3888b3b000000c1c1888c1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b333b888833b0000c111c888811c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb888b8b8b888b00cc888c8c8c888c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbb8b8b8b8b8bb00ccc8c8c8c8c8cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b3333333333b0000c1111111111c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b33bbbb33b000000c11cccc11c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbb00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000000b000000c00000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b0000000000b0000c0000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000b00000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a1a1a1a1a1a1a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000023141516171819333400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000023272425262829193500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000000002c5702807024070220001d0001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000022065250501f0501a0551605010050090550710500000001001a1050710500000000001a1050010000000071050710500000001001a1050710500000000001a105001000000007105071050000000100
00090000056550a6600865003640016000a000000001a000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000147001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000183132440518413394033c61539403185132b513184133940318413394033c615306053940339403184133940318413394033c615394031841321413184133940318413394033c615394033940339403
00090000380502d050290502105016050110500905004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000a050150501a0502b05023050180500705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000380702603001000160000f0000c000090000400002000010000c6000b6000b6000a6000960008600066000660005600036000260002600016000160001600016000160008600136001d600020000c000
00020000000002f610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
0006000031660216601d650196301764013650116500f6500d6500d6500c6500b6500b6500a6500965008650066500665005650036500265002650016500165001650016500160008650136501d650236502f650
000600002d750387502d7503035036750307502a3503075034350317502b750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0000183132440518413394033c61539403185132b513184133940318413394033c615306053940339403184133940318413394033c615394031841321413184133940318413394033c615394033940339403
000e0000183132440518413394033c61539403185132b513184133940318413394033c615306053940339403184133940318413394033c615394031841321413184133940318413394033c615394033940339403
000e0000183132440518413394033c61539403185132b513184133940318413394033c615306053940339403184133940318413394033c615394031841321413184133940318413394033c615394033940339403
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
03 04 42 43 44
00 09 42 43 44
01 0a 0b 43 44
00 0a 0b 43 44
02 0c 0d 43 44
03 10 42 43 44
03 11 42 43 44
03 12 42 43 44
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
