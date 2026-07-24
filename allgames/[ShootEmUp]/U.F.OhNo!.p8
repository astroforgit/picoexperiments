pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--ufohono
--by simon wilson

game = {}

function _init()

--title ufo animation
ufo_x=0
ufo_y=10
ufo_dx=1
logo={
letter_o=72}
first_o=true

smoke_t = 0
smoke_delay = 5
smoke_sp = 35

game_started=false

if not game_started then
sfx(9)	
end
 

title_timer = 0
menu_timer = 0

credits_timer = 0
unlock_timer = 0
unlock = true
b_col = 0 --variable for lauras bullets to be multicoloured!

--startup variables
startup_time=60
startup_message={
"blast those aliens!",
"shoot em up!",
"earth is closed today!",
"e.t. go home!",
"don't panic!"}
message=(rnd(startup_message))
message_col=8
title_col=0

--timing variables for some objects
t=0
pt=0
bt=0
delay=5
a_delay=10
m_delay=20
bullet_rate=2
game_over_timer=0

--for game clock
thirtyfps = 0
countdown = 180

f=true -- flips a sprite if used as last argumemt in spr function

--map and camera control
scrn_wdth=128
scrn_hght=128
map_start=0
map_end=scrn_wdth*2
cam_x=0

--player table
	player={
		x=60,
		y=104,
		w=8,
		h=8,
		sp=1,
		spd=2,
		feetspr=17,
		flp=false,
		health=5,
		points=0,
		highscore=0,
		hardmode_highscore=0,
		imm=false,
		t=0,
		box={x1=0,y1=0,x2=7,y2=7}}

--tables for all objects
	bullets = {}
	flp_bullets = {}	
	angle_bullets = {}
	flp_angle_bullets = {}	
	up_bullets = {}
	targets = {}
	aliens = {}
	diag_aliens = {}
	monsters = {}
	explosions = {}

--respawn variables for aliens
spawn=0
spawntime=100
diag_spawn=0
diag_spawntime=100
m_spawn=0
m_spawntime=100

--overheating bar variables
	charge = 0
	charge_increase = 0.2
	charge_decrease = 2
	charge_max = 75
	charge_col=11
	oh_timer=100
	overheat = false

--respawn rotating aliens
	function respawn_target()
		local n = flr(rnd(9))+2
		for i=1,n do
			local d = -1
			if rnd(1)<0.5 then d=1 end
	 add(targets,{
	 m_x=(i*13)+cam_x,
		m_y=0-i*5,
		d=d,
		x=32,
		y=128,
		r=12,
		w=7,
		h=7,
		sp=6,
		box = {x1=0,y1=0,x2=7,y2=7}})
		end
	end
		
respawn_target()
	
show_title()

--variable for scrolling background
background_x=64
background_spd=0.5

bullet_col=12

--below "end" is for init function
end

function _update()
	game.upd()
end

function _draw()
	game.drw()
end
-->8
--menu

function show_menu()
	game.upd = menu_update
	game.drw = menu_draw

end

function menu_update()

menu_timer += 1

reset_game()

title_col += 1
camera(0,0)
			 
if btn(5) and menu_timer >= 60 then
	show_game()
	menu_timer = 0
end

if btn(4) and menu_timer >=60 then
	show_credits()
end

end

function menu_draw()
cls()

map(32,0,skylight_x,0,32,16)
--map(32,0,128+skylight_x,0,32,16)

map(0,0,road_x,0,16,16)
--map(0,0,128+road_x,0,16,16)

print("shoot the aliens...",(scrn_wdth/2)-30,4,11)
print("...try to survive!",(scrn_wdth/2)-39,12,11)

--print high score
print("high score :",(scrn_wdth/2)-25,30,7)
print(player.highscore,(scrn_wdth/2)+25,30,7)
if not unlock then
print("hard mode score: ",(scrn_wdth/2)-41,38,8)
print(player.hardmode_highscore,(scrn_wdth/2)+25,38,8)
end


--controls display
print("controls",48,50,10)
print("z = move left",(scrn_wdth/2)-60,60,10)
print("x = move right",(scrn_wdth/2)+6,60,10)
print("arrow keys = fire gun",(scrn_wdth/2)-40,70,10)

if menu_timer >= 60 then
print("press x to start",(scrn_wdth/2)-32,85,title_col)
end

print("press z for credits",(scrn_wdth/2)-38,121,5)






end
-->8
--game

function show_game()
	game.upd = game_update
	game.drw = game_draw

game_started=true

	if game_started then
		sfx(-1)
		music(0,0)
	end
end

function game_update()

if not unlock then
	b_col += 1
	if b_col >=15 then
		b_col = 1
	end
end

startup_time -= 1
message_col += 1

if startup_time <=0 then

	if player.health <= 0 then
		show_game_over()
	end
		
	if #targets <= 0 then
		respawn_target()
	end

 if player.imm then
  player.t += 1
  if player.t >30 then
   player.imm = false
   player.t = 0
  end
 end

t+=1
pt+=1
bt+=1

--smoke over gun when overheated
smoke_t += 1
if smoke_t > smoke_delay then
				smoke_sp+=1
					if smoke_sp > 36 then
						smoke_sp = 35
					end
			smoke_t=0
end

camera_controls()


--move target
for e in all (targets) do
	e.m_y += 1.3
 e.x = e.r*sin(e.d*t/50) + e.m_x
 e.y = e.r*cos(t/50) + e.m_y
 
 if e.y >= 150 then
		del(targets,e)
	end
	
	if coll(player,e) and not player.imm then
		player.imm=true
		player.health -= 1
		sfx(11)
	end
	
end


 if btn(4) then
	 player.x -= player.spd
			if pt > delay then
				player.feetspr+=1
					if player.feetspr > 18 then
						player.feetspr = 17
					end
			pt=0
			end
	end
			
	if btn(5) then
		player.x += player.spd
			if pt > delay then
					player.feetspr+=1
					 if player.feetspr > 18 then
							player.feetspr = 17
						end
			pt=0		
		 end		
		end
	
--make bullets in each direction

if charge < charge_max then

	if btn(2) and btn(1) and not btn(0) then
	 if bt > bullet_rate then
	 make_angle_bullet()
		sfx(0)
		bt=0
		end
	end
	
 if btn(2) and not btn(1) and not btn(0) then
		if bt > bullet_rate then
		make_up_bullet()
		sfx(0)
		bt=0
		end
	end
	
 if btn(1) and not btn(2) and not btn(0) then
		if bt > bullet_rate then
		make_bullet()
		sfx(0)
		bt=0
		end
	end
	
	if btn(0) and not btn(2) and not btn(1) then
		if bt > bullet_rate then
		make_flp_bullet()
		sfx(0)
		bt=0
		end
	end
	
	if btn(0) and btn(2) then
		if bt > bullet_rate then
		make_flp_angle_bullet()
		sfx(0)
		bt=0
		end
	end
	
end
--make bullets move and disappear
	
	for b in all (bullets) do
	b.x += b.dx
	b.y += b.dy
		if b.x < cam_x or b.x > cam_x+scrn_wdth or
			 b.y < 0 or b.y >128 then
		del(bullets,b)
		end
		for e in all(targets) do
			if coll(b,e) then
			del(targets,e)
			del(bullets,b)
			player.points += 1
			sfx(1)
			explode(e.x+4,e.y+4)
			end
		end
		for a in all(aliens) do
			if coll(b,a) then
			del(aliens,a)
			del(bullets,b)
			player.points += 1
			sfx(1)
			explode(a.x+4,a.y+4)
			end
		end
		for m in all(monsters) do
				if coll(b,m) then
					m.health -= 1
					del(bullets,b)
				end
				if m.health <= 0 then
					del(monsters,m)
					player.points += 10
					sfx(1)
					explode(m.x+8,m.y+8)
				end
		end	
for diag_a in all(diag_aliens) do
			if coll(b,diag_a) then
			del(diag_aliens,diag_a)
			del(up_bullets,b)
			player.points += 1
			sfx(1)
			explode(diag_a.x+4,diag_a.y+4)
			end
		end
	end
	
	for b in all (flp_bullets) do
	b.x += b.dx
	b.y += b.dy
		if b.x < cam_x or b.x > cam_x+scrn_wdth or
			 b.y < 0 or b.y >128 then
		del(flp_bullets,b)
		end
			for e in all(targets) do
				if coll(b,e) then
				del(targets,e)
				del(flp_bullets,b)
				player.points += 1
				sfx(1)
				explode(e.x+4,e.y+4)
				end
			end
		for a in all(aliens) do
			if coll(b,a) then
			del(aliens,a)
			del(flp_bullets,b)
			player.points += 1
			sfx(1)
			explode(a.x+4,a.y+4)
			end
		end	
for m in all(monsters) do
				if coll(b,m) then
					m.health -= 1
					del(flp_bullets,b)
				end
				if m.health <= 0 then
					del(monsters,m)
					player.points += 10
					sfx(1)
					explode(m.x+8,m.y+8)
				end
		end	
for diag_a in all(diag_aliens) do
			if coll(b,diag_a) then
			del(diag_aliens,diag_a)
			del(flp_bullets,b)
			player.points += 1
			sfx(1)
			explode(diag_a.x+4,diag_a.y+4)
			end
		end
	end

	for b in all (angle_bullets) do
	b.x += b.dx
	b.y += b.dy
		if b.x < cam_x or b.x > cam_x+scrn_wdth or
			 b.y < 0 or b.y >128 then
				del(angle_bullets,b)
		end
		for e in all(targets) do
			if coll(b,e) then
			del(targets,e)
			del(angle_bullets,b)
			player.points += 1
			sfx(1)
			explode(e.x+4,e.y+4)
			end
		end
	for a in all(aliens) do
			if coll(b,a) then
			del(aliens,a)
			del(angle_bullets,b)
			player.points += 1
			sfx(1)
			explode(a.x+4,a.y+4)
			end
		end
for m in all(monsters) do
				if coll(b,m) then
					m.health -= 1
					del(angle_bullets,b)
				end
				if m.health <= 0 then
					del(monsters,m)
					player.points += 10
					sfx(1)
					explode(m.x+8,m.y+8)
				end
		end	
for diag_a in all(diag_aliens) do
			if coll(b,diag_a) then
			del(diag_aliens,diag_a)
			del(angle_bullets,b)
			player.points += 1
			sfx(1)
			explode(diag_a.x+4,diag_a.y+4)
			end
		end
end
	
	for b in all (flp_angle_bullets) do
	b.x += b.dx
	b.y += b.dy
		if b.x < cam_x or b.x > cam_x+scrn_wdth or
			 b.y < 0 or b.y >128 then
				del(flp_angle_bullets,b)
		end
			for e in all(targets) do
				if coll(b,e) then
				del(targets,e)
				del(flp_angle_bullets,b)
				player.points += 1
				sfx(1)
				explode(e.x+4,e.y+4)
				end
			end
		for a in all(aliens) do
			if coll(b,a) then
			del(aliens,a)
			del(flp_angle_bullets,b)
			player.points += 1
			sfx(1)
			explode(a.x+4,a.y+4)
			end
		end
for m in all(monsters) do
				if coll(b,m) then
					m.health -= 1
					del(flp_angle_bullets,b)
				end
				if m.health <= 0 then
					del(monsters,m)
					player.points += 10
					sfx(1)
					explode(m.x+8,m.y+8)
				end
		end	
for diag_a in all(diag_aliens) do
			if coll(b,diag_a) then
			del(diag_aliens,diag_a)
			del(flp_angle_bullets,b)
			player.points += 1
			sfx(1)
			explode(diag_a.x+4,diag_a.y+4)
			end
		end
	end

	for b in all (up_bullets) do
	b.x += b.dx
	b.y += b.dy
		if b.x < cam_x or b.x > cam_x+scrn_wdth or
			 b.y < 0 or b.y >128 then
				del(up_bullets,b)
		end
			for e in all(targets) do
				if coll(b,e) then
				del(targets,e)
				del(up_bullets,b)
				player.points += 1
				sfx(1)
				explode(e.x+4,e.y+4)--added 4 to centre the explosion on the 8x8 sprite
				end
			end
		for a in all(aliens) do
			if coll(b,a) then
			del(aliens,a)
			del(up_bullets,b)
			player.points += 1
			sfx(1)
			explode(a.x+4,a.y+4)
			end
		end
for m in all(monsters) do
				if coll(b,m) then
					m.health -= 1
					del(up_bullets,b)
				end
				if m.health <= 0 then
					del(monsters,m)
					player.points += 10
					sfx(1)
					explode(m.x+8,m.y+8)
				end
		end	
for diag_a in all(diag_aliens) do
			if coll(b,diag_a) then
			del(diag_aliens,diag_a)
			del(up_bullets,b)
			player.points += 1
			sfx(1)
			explode(diag_a.x+4,diag_a.y+4)
			end
		end
	end

	for ex in all (explosions) do
		ex.t += 1
		if ex.t == 13 then
		del(explosions,ex)
		end
	end

 if not unlock then	
	spawn+=1
	diag_spawn+=1
	end
	
	if unlock then
	spawn+=0.5
	diag_spawn+=0.5
	end
	
	if not unlock then
	m_spawn+=0.5
	end


	if spawn >= spawntime then
		make_alien()
		spawn=0
		spawntime -= 5
			if spawntime <= 10 then
				spawntime = 10
			end
	end
	
	if m_spawn >= m_spawntime then
		make_monster()
		m_spawn=0
		m_spawntime -= 2.5
			if m_spawntime <= 20 then
				m_spawntime = 20
			end
	end
	
	if diag_spawn >= diag_spawntime then
		make_diag_alien()
		diag_spawn=0
		diag_spawntime -= 5
			if diag_spawntime <= 10 then
				diag_spawntime = 10
			end
	end
	
	for a in all (aliens) do
	a.x += a.dx
	a.at += 1
		if a.x <= map_start-20 or a.x >= map_end+20 then
		del(aliens,a)
		end
		if coll(player,a) and not player.imm then
			player.imm=true
			player.health -= 1
			sfx(11)
		end
	end
	
	for m in all (monsters) do
	m.x += m.dx
	m.mt += 1
		if m.x <= map_start-40 or m.x >= map_end+40 then
		del(monsters,m)
		end
		if coll(player,m) and not player.imm then
			player.imm=true
			player.health -= 2
			sfx(11)
		end
	end
	
	for diag_a in all (diag_aliens) do
	diag_a.x += diag_a.dx
	diag_a.y += diag_a.dy
	diag_a.at += 1
		if diag_a.x <= cam_x-20 or diag_a.x >= cam_x+140
		or diag_a.y >= 128 then
		del(diag_aliens,diag_a)
		end
		if coll(player,diag_a) and not player.imm then
			player.imm=true
			player.health -= 1
			sfx(11)
		end
	end

charge_gun()

if overheat then
	overheat_timer()
end




end -- for startup time

--below end is for game_update()
end



function game_draw()

	cls(0)

if startup_time > 0 then
print(message,30,64,message_col)
	if message_col >= 15 then
		message_col = 8
	end
end

--building
--	map(64,0,0,0,64,16)

--sky light
	map(32,0,0,0,32,16)
	
--foreground road and lampposts
	map(0,0,0,0,32,16)
	
	--draw player
		if not player.imm or t%8 < 4 then
			spr(player.sp,player.x,player.y)
			spr(player.feetspr,player.x,player.y)
			if not unlock and player.sp == 1 then
				pset(player.x+1,player.y+4,14)
		 	pset(player.x+1,player.y+5,14)
		 end
			if not unlock and player.sp == 2 then
				pset(player.x+1,player.y+4,14)
		 	pset(player.x+1,player.y+5,14)
		 end
			if not unlock and player.sp == 3 then
				pset(player.x+1,player.y+4,14)
		 	pset(player.x+1,player.y+5,14)
		 end
	 	if not unlock and player.sp == 4 then
	 	 pset(player.x+6,player.y+4,14)
	 		pset(player.x+6,player.y+5,14)
	 	end
	 	if not unlock and player.sp == 5 then
	 	 pset(player.x+6,player.y+4,14)
	 		pset(player.x+6,player.y+5,14)
	 	end
	 	
				if player.health <= 0 then
					player.sp =19
				end
		end
	
	for ex in all (explosions) do
	circ(ex.x,ex.y,ex.t/2,8+ex.t%3)
	end


	
--draw bullets
	for b in all (bullets) do
		if unlock then
		pset(b.x,b.y,bullet_col)
		end
		if not unlock then
		pset(b.x,b.y,b_col)
		end
	end

	for b in all (flp_bullets) do
	 if unlock then
		pset(b.x,b.y,bullet_col)
		end
		if not unlock then
		pset(b.x,b.y,b_col)
		end
	end	
	
	for b in all (angle_bullets) do
		if unlock then
		pset(b.x,b.y,bullet_col)
		end
		if not unlock then
		pset(b.x,b.y,b_col)
		end
	end
	
	for b in all (flp_angle_bullets) do
		if unlock then
		pset(b.x,b.y,bullet_col)
		end
		if not unlock then
		pset(b.x,b.y,b_col)
		end
	end
	
	for b in all (up_bullets) do
		if unlock then
		pset(b.x,b.y,bullet_col)
		end
		if not unlock then
		pset(b.x,b.y,b_col)
		end
	end
	
--change player sprite

	if btn(2) and not btn(1) and not btn(0) then
		player.sp=3
	elseif btn(2) and btn(1) and not btn(0) then
		player.sp=2
	elseif btn(2) and btn(0) and not btn(1) then
		player.sp=4
	elseif btn(0) and not btn(2) and not btn(1) then
	 player.sp=5
	else
		player.sp=1
	end
	
	for e in all (targets) do
	spr(e.sp,e.x,e.y)	
	end
	
--debugging
--	rect(player.box.x1,player.box.y1,player.box.x2,player.box.y2,10)
--	rect(target.x,target.y,target.x+target.w,target.y+target.h,10)
	
--check bullets delete themselves
--print(#bullets,10,10,10)
--print(#angle_bullets,10,20,10)
--print(#up_bullets,10,30,10)
--print(#flp_bullets,10,40,10)
--print(#flp_angle_bullets,10,50,10)

for a in all (aliens) do
	
 if (a.dx == 1) then	
	spr(a.sp,a.x,a.y,1,1)
	end
	
	if (a.dx == -1) then
	spr(a.sp,a.x,a.y,1,1,f)
	end
	
	if a.at > a_delay then
				a.sp+=1
					if a.sp > 34 then
						a.sp = 33
					end
				a.at=0
			end
--	print(#aliens,10,20,10)
end

for m in all (monsters) do
	
 if (m.dx == 1) then	
	spr(m.sp,m.x,m.y,2,2)
	end
	
	if (m.dx == -1) then
	spr(m.sp,m.x,m.y,2,2,f)
	end
	
	if m.mt > m_delay then
				m.sp+=2
					if m.sp > 40 then
						m.sp = 38
					end
				m.mt=0
			end
			
	--	if coll(b,m) then
	--	if m.mt > m_delay then
	--			m.sp+=2
	--				if m.sp > 44 then
		--				m.sp = 42
	--				end
	--			m.mt=0
	--		end
--		end
--	print(#monsters,64,64,10)
end


for diag_a in all (diag_aliens) do
	
 if (diag_a.dx == 1) then	
	spr(diag_a.sp,diag_a.x,diag_a.y,1,1)
	end
	
	if (diag_a.dx == -1) then
	spr(diag_a.sp,diag_a.x,diag_a.y,1,1,f)
	end
	
	if diag_a.at > a_delay then
				diag_a.sp+=1
					if diag_a.sp > 49 then
						diag_a.sp = 49
					end
				diag_a.at=0
			end
			
end

--print(#diag_aliens,cam_x+10,20,10)

	--points
	print("score: ",cam_x+45,10,7)
 print(player.points,cam_x+75,10,7)

	--health bar
	if player.health >= 1 then
	spr(144,(cam_x),120,1,1)
	else
	spr(145,(cam_x),120,1,1)
		end
	
	if player.health >= 2 then
	spr(144,(cam_x)+9,120,1,1)
	else
	spr(145,(cam_x)+9,120,1,1)
		end
	
	if player.health >= 3 then
	spr(144,(cam_x)+18,120,1,1)
	else
	spr(145,(cam_x)+18,120,1,1)
		end
	
	if player.health >= 4 then
	spr(144,(cam_x)+27,120,1,1)
		else
	spr(145,(cam_x)+27,120,1,1)
		end
	
		if player.health == 5 then
	spr(144,(cam_x)+36,120,1,1)
		else
	spr(145,(cam_x)+36,120,1,1)
		end

rectfill(cam_x+48,122,cam_x+50+charge,126,10)

--overheat bar
if overheat then
 rectfill(cam_x+48,122,cam_x+50+charge,126,8)
 print("gun overheated!",cam_x+57,122,7)
 spr(smoke_sp,player.x,player.y-8)
end

--print(countdown,10,50,9)

--debug charge and overheat values
--print(charge,cam_x+50,10,10)
--print(oh_timer,cam_x+50,20,14)
end
-->8
--game over

function show_game_over()
	game.upd = game_over_update
	game.drw = game_over_draw
end

function game_over_update()

 if unlock then
 if player.points > player.highscore
 then player.highscore = player.points
 end
 end
 
 if not unlock then
	 if player.points > player.hardmode_highscore
	 then player.hardmode_highscore = player.points
  end
 end


	game_over_timer += 1
	
	if game_over_timer >= 100 then
		if player.points >= 200 and unlock then
		show_unlock() 
		else
		show_menu()
	end
	end
	
end

function game_over_draw()

rectfill(cam_x,50,cam_x+128,70,0)
print("game over!",cam_x+20,50,7)
print("your score: ",cam_x+20,70,7)
print(player.points,cam_x+64,70,7)


end
-->8
--functions for game

function camera_controls()

	cam_x = player.x-64+(player.w/2)
	if cam_x<map_start then
		cam_x=map_start
	end

	if cam_x>(map_end-scrn_wdth) then
		cam_x=(map_end-scrn_wdth)
	end
	camera(cam_x,0)

	--limit player to map
	if player.x<map_start then
		player.x=map_start
	end

	if player.x>(map_end-player.w) then
		player.x=(map_end-player.w)
	end

end

function make_bullet()
	local b = {x=player.x+3,y=player.y+5,
	dx=5,dy=rnd(0.5)-0.5,
	box={x1=2,y1=0,x2=5,y2=4}}-- box = {x1=}
	add(bullets,b)
end
--original values dx=5, dy=0

function make_flp_bullet()
	local b = {x=player.x+3,y=player.y+5,
	dx=-5,dy=rnd(0.5)-0.5,
	box={x1=2,y1=0,x2=5,y2=4}}-- box = {x1=}
	add(flp_bullets,b)
end
--original values dx= -5, dy=0

function make_angle_bullet()
	local b = {x=player.x+4,y=player.y+3,
	dx=rnd(2)+5,dy=-5,
	box={x1=2,y1=0,x2=5,y2=4}}
	add(angle_bullets,b)
end
--original values dx = 5, dy=-5

function make_flp_angle_bullet()
	local b = {x=player.x+4,y=player.y+3,
	dx=rnd(2)-7,dy=-5,
	box={x1=2,y1=0,x2=5,y2=4}}
	add(flp_angle_bullets,b)
end
--original values dx= -5, dy= -5

function make_up_bullet()
	local b = {x=player.x+6,y=player.y+3,
	dx=rnd(0.5)-0.5,dy=-5,
	box={x1=2,y1=0,x2=5,y2=4}}
	add(up_bullets,b)
end
--original values dx=0, dy=-5

function explode(x,y)
	add(explosions, {x=x,y=y,t=0})
end

function make_alien()
	local a = {
	x=flr(rnd(2))+1,
	y=104,
	dx=flr(rnd(2))+1,
	sp=33,
	at=0,
	box={x1=0,y1=0,x2=7,y2=7}
	}
	if a.x == 1 then
		a.x =map_start-8
	else
	 a.x =map_end+8
	end
	if a.dx == 1 then
		a.dx = -1
	else
		a.dx = 1
	end
	add(aliens,a)
end

function make_monster()
	local m = {
	x=flr(rnd(2))+1,
	y=96,
	dx=flr(rnd(2))+1,
	sp=38,
	health=10,
	mt=0,
	box={x1=0,y1=0,x2=15,y2=15}
	}
	if m.x == 1 then
		m.x =map_start-16
	else
	 m.x =map_end+16
	end
	if m.dx == 1 then
		m.dx = -1
	else
		m.dx = 1
	end
	add(monsters,m)
end

function make_diag_alien()
	local diag_a = {
	x=flr(rnd(2))+1,
	y=0,
	dx=flr(rnd(2))+1,
	dy=1.5,
	sp=49,
	at=0,
	box={x1=0,y1=0,x2=7,y2=7}
	}
	if diag_a.x == 1 then
		diag_a.x =cam_x-8
		--diag_a.dy = -diag_a.dy
	else
	 diag_a.x =cam_x+128
	end
	if diag_a.dx == 1 then
		diag_a.dx = -1
	else
		diag_a.dx = 1
	end
	add(diag_aliens,diag_a)
end


function charge_gun()
	if btn(”) or btn(‹) or btn(‘) then
	charge += charge_increase
	 else charge -= charge_decrease
	 	if charge <= 0 then
	 	 charge = 0
	 	end
	end
	
	if charge >= charge_max then
	 charge = charge_max
	 overheat = true
	end
	
end

function overheat_timer()
--while overheat = true
--make player wait to return to
--reusable gun state
--by setting a timer
--that counts down to overheat
--becoming false again
 
 oh_timer -= 1
  if oh_timer <= 0 then
  overheat = false
  oh_timer = 100
  end
end

function reset_game()

--delete all enemies and bullets from last game
for e in all (targets) do
	del(targets,e)
end

for a in all (aliens) do
	del(aliens,a)
end

for diag_a in all(diag_aliens) do
	del(diag_aliens,diag_a)
end

for m in all (monsters) do
	del(monsters,m)
end

for b in all(bullets) do
	del(bullets,b)
end

for b in all(flp_bullets) do
	del(flp_bullets,b)
end

for e in all(explosions) do
	del(explosions,e)
end

for b in all(angle_bullets) do
	del(angle_bullets,b)
end

for b in all(flp_angle_bullets) do
	del(flp_angle_bullets,b)
end


--reset startup sequence
startup_time=60
startup_message={
"blast those aliens!",
"shoot em up!",
"earth is closed today!",
"e.t. go home!",
"get ready!"}
message=(rnd(startup_message))
message_col=8

--reset timing variables
t=0
pt=0
bt=0
game_over_timer=0

--reset camera position
cam_x=0

--reset player
player.x=60
player.y=104
player.flp=false
player.sp=1
player.health=5
player.points=0
player.imm=false
player.t=0

--reinitialise respawn code		
respawn_target()
spawn=0
spawntime=100
diag_spawn=0
diag_spawntime=100
m_spawn=0
m_spawntime=100

--reset overheat bar
	charge = 0
	charge_increase = 0.2
	charge_decrease = 2
	charge_max = 75
	charge_col=11
	oh_timer=100
	overheat = false

end--function to reset whole game





-->8
--collision function
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
-->8
--credits

function show_credits()
	game.upd = credits_update
	game.drw = credits_draw

end

function credits_update()


credits_timer += 1
if credits_timer >= 230 then
	show_menu()
	credits_timer = 0
end



title_col += 1
camera(0,0)
			 
end

function credits_draw()
cls()
map(32,0,skylight_x,0,32,16)
map(0,0,road_x,0,16,16)


print("a tiny game made by simon wilson",0,5,11)
print("with thanks to @ztiromoritz for",0,20,7)
print("a pico-8 spaceshooter in 16 gifs",0,28,7)
print("also to doc_robs on youtube, for",0,44,7)
print("the awesome pico-8 tutorials.",0,52,7)
print("and @gruber for",0,68,7)
print("the amazing background music!",0,76,7)
end
-->8
--character unlock

function show_unlock()
	game.upd = unlock_update
	game.drw = unlock_draw
	sfx(12)
end

function unlock_update()

 if player.points > player.highscore
 then player.highscore = player.points
 end

unlock = false
unlock_timer += 1
if unlock_timer >= 150 then
	show_menu()
 unlock_timer = 0
end

camera(0,0)
			 
end

function unlock_draw()
cls()
print("unlocked laura!",33,50,11)
pal(4,14)
pal(9,13)
spr(1,63-5,63)
spr(17,63-5,63)
pset(64-5,67,14)
pset(64-5,68,14)


end
-->8
--title

function show_title()
	game.upd = title_update
	game.drw = title_draw
end

function title_update()

title_col += 1
title_timer += 1
reset_game()
camera(0,0)
			 

			 
if title_timer > 300 then
	if btn(0) or btn(1) or btn(2) or btn(3) or btn(4) or btn(5) then
		show_menu()
		title_timer = 0
	end
end

--ufo animation
ufo_x += ufo_dx

if ufo_x >= 130 or ufo_x <= -8 then
	ufo_dx = -ufo_dx
	ufo_y += 10
		if ufo_y >= 30 then
		ufo_y = 10
		end
end



end

function title_draw()
cls(0)
--print(title_timer,10,10,10)

map(32,0,skylight_x,0,32,16)
--map(32,0,128+skylight_x,0,32,16)

map(0,0,road_x,0,16,16)
--map(0,0,128+road_x,0,16,16)

spr(12,ufo_x,ufo_y)

if title_timer > 25 then
spr(64,0+1,30,4,4) -- u
end

if title_timer > 75 then
spr(68,30+1,30,4,4) -- f
end

if title_timer > 125 then
spr(72,60+1,30,4,4) --0

end


if title_timer > 200 then
spr(138,60+1,30,4,4) -- orange o
spr(76,88+1,30,2,2) -- oh
spr(108,88+1,50,2,2) -- n
spr(110,103+1,45,2,2) -- 0
spr(78,114+1,38,2,2) -- !
end

if title_timer > 350 then
print("press any button",(scrn_wdth/2)-32,85,title_col)
end
end
__gfx__
00000000000444400004444000044540044440000444400000bbbb00333333330000000666600000000000000000000000000000000000000000000000000000
00000000004ffff0004f1f15004f151051f1f4000ffff40000b77b006336633600000060aaa00000000000000000000000000000000000000000000000000000
00700700044f1f10044fff50044ff5f005fff44001f1f44006b70b60666666660000060000000000000000000000000000000000000000000000000000000000
0007700004fffff004fff5f004fff5500f5fff400fffff4066bbbb66dddddddd0000600000000000aaaa000000000000000b0000000000000000000000000000
000770000099555500995f50009995f005f599005555990066bbbb66dddddddd0000600000000000aaaaa0000000000000666000000000000000000000000000
007007000095f5f00099950000999500005999000f5f59006b5555b6dddddddd0000600000000000aaaaaa000000000000000000000000000000000000000000
00000000006666500066660000666600006666000566660006655660dddddddd0000600000000000aaaaaaa00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000666600dddddddd0000600000000000aaaaaaaa0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000600000000000aaaaaaaaa000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000600000000000aaaaaaaaaa00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000600000000000aaaaaaaaaaa0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000600000000000aaaaaaaaaaaa000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000006650000000000aaaaaaaaaaaaa00000000000000000000000000000000000
0000000000000000000000004f1f9960000000000000000000000000000000000006650000000000aaaaaaaaaaaaaa0000000000000000000000000000000000
0000000000000000000000004fff9960000000000000000000000000000000000006650000000000aaaaaaaaaaaaaaa000000000000000000000000000000000
0000000000600600000660004444f966000000000000000000000000000000000006550000000000aaaaaaaaaaaaaaaa00000000000000000000000000000000
00000000000bbbb00000000000000666000006600000000000000000088880000000000000000000000000000777700000000000000000000000000000000000
0000000000bb7770000bbbb000006000000000060000000000000000888888000000000008888000000000007777770000000000077770000000000000000000
0000000000bb771000bb777000060000000000660000000000000008887778000000000088888800000000077777770000000000777777000000000000000000
0000000000bbbbb000bb771000006600000006000000000000000088877707000000000888777800000000777777770000000007777777000000000000000000
0000000000bb111000bbbbb000000060000060000000000000000088877707000000008887770700000000777777770000000077777777000000000000000000
0000000000b1188000bb111000000060000060000000000000000888887777000000008887770700000007777777770000000077777777000000000000000000
000000000bbb111000b1188000000600000006000000000000008888888888000000088888777700000077777777770000000777777777000000000000000000
00000000bbbbbbb00bbb111000000000000000000000000000088888877117000000888888888800000777777777770000007777777777000000000000000000
0000000000bbbb000000000000000000000000000000000000888888877117000008888888888800007777777777770000077777777777000000000000000000
0000000000b77b000000000000000000000000000000000000888888817111000088888887711700007777777777770000777777777777000000000000000000
0000000006b70b600000000000000000000000000000000000888888811111000088888881711100007777777777770000777777777777000000000000000000
0000000066bbbb660000000000000000000000000000000008888888811111000088888881111100077777777777770000777777777777000000000000000000
0000000066bbbb660000000000000000000000000000000008888888817117000888888881711700077777777777770007777777777777000000000000000000
000000006b5555b60000000000000000000000000000000008888888877117000888888881711700077777777777770007777777777777000000000000000000
00000000066556600000000000000000000000000000000088888888888888000888888888888800777777777777770007777777777777000000000000000000
00000000006666000000000000000000000000000000000088888888888888008888888888888800777777777777770077777777777777000000000000000000
0bbbbbb0000000000000bbbbbb0000000bbbbbbbbbbbbbbbbbbbbbbbbb000000000bbbbbbbbbbbbbbbbbbbbb00000000000000000aaaa0000000000000000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000bbbbbbbbbbbbbbbbbbbbbbbbb0000000aaaa0000a9990000000aaaa90000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000bbbbbbbbbbbbbbbbbbbbbbbbb0000000a999900099990000000a99990000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000a999900009999000000999990000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb3333333333333333333000000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000a9999000099990000000a9990000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb0000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000a9999999999990000000a9990000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb0000000000000000000000000bbbbbbbbb000000000bbbbbbbb30000000a999999999990000000a9990000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb0000000000000000000000000bbbbbbbb00000000000bbbbbbb30000000a9999999999940000000a999000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb0000000000000000000000000bbbbbbbb00000000000bbbbbbb30000000a9999999999940000000a999000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb0000000000000000000000000bbbbbbbb00000000000bbbbbbb30000000a99999999999400000000994000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb0000000000000000000000000bbbbbbbb00000000000bbbbbbb30000000a99990000999400000000944000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbb00000000000bbbbbbb300000000a9990000999400000000000000000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbbbb00000000000bbbbbbb300000000a999000099940000000000a900000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbbbb00000000000bbbbbbb300000000a99900009994000000000a9990000
bbbbbbbb00000000000bbbbbbb300000bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbbbb00000000000bbbbbbb3000000000a9900000940000000000a9940000
bbbbbbbb00000000000bbbbbbb300000bbbbbbb3333333333333333333000000bbbbbbbb00000000000bbbbbbb30000000000940000000000000000009400000
bbbbbbbb00000000000bbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbb00000000000bbbbbbb30000000000000000000000000000000000000
bbbbbbbb00000000000bbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbb00000000000bbbbbbb30000000aa0000000aa90000000aaaaaaa0000
bbbbbbbb00000000000bbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbb00000000000bbbbbbb3000000a99a00000a999000000a99999999000
bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbbb000000000bbbbbbbb3000000a999a0000a9990000aa999999999900
bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000a9999a0000999000a99999000099990
bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000a99999a000999000a99990000009990
bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb3000000a999999a00999000a99900000009999
bbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb30000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb30000000a99099990999900a99900000009999
0bbbbbbbbbbbbbbbbbbbbbbbb3000000bbbbbb300000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb300000000a99009999999400a99900000009994
0bbbbbbbbbbbbbbbbbbbbbbb33000000bbbbbb300000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbb3300000000a99000999999400a99990000099994
00033333333333333333333330000000033333000000000000000000000000000003333333333333333333333000000000a99000099999400099999999999940
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a99900009999400009999999999940
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099900000999400000999999994400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099400000044000000099999440000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400000000000000000994000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010110011001111111101000100101010100010001000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaa000000000000000000000000
010101011100110011111111101010100000000000000000000000000000000000000000000000000aa999999999999999999999990000000000000000000000
101010100011001111111111000100011010101010001000100000000000001000000000000000000a9999999999999999999999990000000000000000000000
01010101001100111111111110101010000000000000000000000000000000000000000000000000a99999999999999999999999994000000000000000000000
10101010110011001111111101000101101010100010001000000000000000000000000000000000a99999999999999999999999994000000000000000000000
01010101110011001111111110101010000000000000000000000000000000000000000000000000a99999999999999999999999994000000000000000000000
10101010001100111111111100010001101010101000100000001000000100000000000000000000a99999999000000000999999994000000000000000000000
01010101001100111111111110101010000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
08800880055005500000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
88888888555555550000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
88888888555555550000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
88888888555555550000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
08888880055555500000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
00888800005555000000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
00088000000550000000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000a99999990000000000099999994000000000000000000000
00555555555555555555555555555555555555555555555555555555555555555555555555555500a99999990000000000099999994000000000000000000000
0585885885885885445445445995995995aa5aa5aa5775775775cc5cc5cc5bb5bb5bb53353353350a99999990000000000099999994000000000000000000000
0588558885885885445445445995995995aa5aa5aa5775775775cc5cc5cc5bb5bb5bb53353353350a99999999000000000999999994000000000000000000000
0588558885885885445445445995995995aa5aa5aa5775775775cc5cc5cc5bb5bb5bb53353353350a99999999999999999999999994000000000000000000000
0585885885885885445445445995995995aa5aa5aa5775775775cc5cc5cc5bb5bb5bb53353353350a99999999999999999999999994000000000000000000000
00555555555555555555555555555555555555555555555555555555555555555555555555555500a99999999999999999999999994000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000a99999999999999999999999994000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000099999999999999999999999940000000000000000000000
00555555555555555555555555555555555555555555555555555555555555555555555555555500099999999999999999999999440000000000000000000000
05656656656656656656656656656656656656656656656656656656656656656656656656656650000444444444444444444444400000000000000000000000
05665566656656656656656656656656656656656656656656656656656656656656656656656650000000000000000000000000000000000000000000000000
05665566656656656656656656656656656656656656656656656656656656656656656656656650000000000000000000000000000000000000000000000000
05656656656656656656656656656656656656656656656656656656656656656656656656656650000000000000000000000000000000000000000000000000
00555555555555555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111111111111111111111111111111111111111000000000000000000111100000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000aaaa0000aaaa0000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999000099990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999000099990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999000099990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999999999990000000000
0001000000000000000000000000000000000000000100000000000011111111111111110000000000000000000000000000000000a999999999990000000000
0001000000000000000000000000000000000000000100001111111111111111111111110000000000000000000000000000000000a999999999990000000000
0001000000000000000000000000000000000000000100001111111111111111111111110000000000000000000000000000000000a999999999990000000000
0001000000000000000000000000000000000000000100000000000011111111111111110000000000000000000000000000000000a999999999990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999999999990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999000099990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999000099990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a999000099990000000000
0001000000000000000000000000000000000000000100000000000000000011110000000000000000000000000000000000000000a994000099940000000000
00010000000000000000000000000000000000000001000000000000000000111100000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111111111111111111111111111111111111100000000000000001111111111111111111111111111111111111000000000000000000000000000
00000000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000000000000000000000000
00000000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000000000000000000000000
00000000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000000000000000000000000
00000000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000000000000000000000000
00000001111111111111111111111111111111111111111100000000000000001111111111111111111111111111111111111111100000000000000000000000
00000001000000010000000100000001000000010000000100000000000000001000000010000000100000001000000010000000100000000000000000000000
00000001000000010000000100000001000000010000000100000000000000001000000010000000100000001000000010000000100000000000000000000000
00000001000000010000000100000001000000010000000100000000000000001000000010000000100000001000000010000000100000000000000000000000
00000001000000010000000100000001000000010000000100000000000000001000000010000000100000001000000010000000100000000000000000000000
00011111111111111111111111111111111111111111111100000000000000001111111111111111111111111111111111111111111110000000000000000000
00010000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000010000000000000000000
00010000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000010000000000000000000
00010000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000010000000000000000000
00010000000100000001000000010000000100000001000100000000000000001000100000001000000010000000100000001000000010000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008f8f000000000000000000000000000000000000000000000000000000008f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f00000000ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000000dfdfdfdfdfdfdfdf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0000ffff0000000000dfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf00000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffff0000000000dfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf00df0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffff000000000000dfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf0000000000000000000000000000000000000000000000000000000000000000
0000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffff000000000000ffcfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf000000000000000000000000000000000000000000000000000000000000000000
00000000000000001010101010101000000000000000000000000000000000008f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f00ffffff00000000000000efefdfdfdfcfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000010101000000000000000000000000000000000000000868686868686868686868686868686868686868686868686868686868686868600ffffff00000000000000efdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ffff00000000008f85858585858585858585858585858585858585858585858585858585858585850000ffff00000000000000dfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf00000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff84848484848484848484848484848484848484848484848484848484848484848f0000ffffffffffffffffdfdfdfdfdfdfdfdf00dfdf00dfdfdf00df00dfdf000000000000000000000000000000000000000000000000000000000000000000
ffffffff0809ffffffffffff0809ffffffffffff0809ffffffffffff0809ffff80808080808080808080808080808080808080808080808080808080808080808f8f00ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff18ffffffffffffff18ffffffffffffff18ffffffffffffff18ffffff82828282828282828282828282828282828282828282828282828282828282828f8f000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000efef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000310502f0502d0502c0502a050280502705025050240502205021050200501f0501d0501c0501a0501a050180501705015050130501305011050100500f0500e0500d0500d0500c0500b0500905008050
000100000a0700c0600d0600e060100501205014050160501a050190401b0401d0401f04021040230300e0302503027030280202a0202b020070102d010060102f01030010310103405034050030000300002000
00010000380503505034050330503205031050300502f0502e0502d0502c0502b0502a050290502805027050270502605025050240502305023050220502105020050200501f0501e0501d0501d0501c05019050
000100002e0502d0502c0502a0502905028050270502705026050250502405023050220502205021050200501f0501f0501e0501d0501c0501c0501b0501a0501905018050170501605015050130501105011050
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200722007200072000720007220072000720007200072200722007200072000712007100071200712
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
00010000130401204011040100500f0500e0500d0500d0500c0600b0600a0600a0600906009060080600805007050070500604005040050400403004030030300302003020030200201002010010100101001000
0004000022050220502205022050160001600022050220502205022050220002200016050180501b0501b0501d0501f0502205022050240502405027050270502705027050270502705027050270502705027050
000400000245003450034100442005430054300644006450064500746007460074700747007470074700747007470084700747007470064700646005460044600345003440024300142000420014100040000400
00010000165201453012550105500f5600d5600c5700b5700a5700957008560075600655006550055500555004550045500355003550035500355003550035500255002550025500255002550025500255002550
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
00 04 42 43 44
01 05 06 43 44
00 05 06 43 44
02 07 08 43 44
01 09 0a 43 44
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
