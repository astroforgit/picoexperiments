pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- mountains of demise 2
-- by adrian09_01

function _init()
reload(0x1000, 0x1000, 0x2000)
init_controls()
init_variables()
spawn_player()
spawn_mapstuff()
make_nighttime()
spawn_place()
music(1)
end

function _update60()
if gamestate == 0 then
update_players()
update_mapstuff()
update_collisions()
update_bullets()
update_enemies()
update_psystems()
end
end

function _draw()
if gamestate == 5 then
draw_pass()
end
if gamestate == 4 then
draw_menu()
end
if gamestate == 0 then
rectfill(0,0,128,128,skycolor)
setpal(0)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if gamestate == 1 then
if timecount < 35 then
update_mapstuff()
update_bullets()
update_enemies()
update_psystems()
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 35 then
setpal(1)
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 40 then
setpal(2)
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 45 then
setpal(3)
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 50 then
cls()
setpal(0)
end
draw_gover()
end
if gamestate == 2 then
if timecount < 35 then
update_mapstuff()
update_bullets()
update_enemies()
update_psystems()
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 35 then
setpal(1)
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 40 then
setpal(2)
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 45 then
setpal(3)
rectfill(0,0,128,128,skycolor)
draw_map(mapx, mapy)
draw_players()
prepare_draw(mapx, mapy)
draw_mapstuff()
draw_bullets()
draw_enemies()
for ps in all(particle_systems) do
		draw_ps(ps)
end
draw_gui()
end
if timecount >= 50 then
cls()
setpal(0)
end
draw_ending()
end
if gamestate == 3 then
draw_intro()
end
end

-- init section
function init_controls()
left = 0
right = 1
up = 2
down = 3
o = 4
x = 5
end

function init_variables()
players = {}
powerups = {}
bullets = {}
enemies = {}
particle_systems = {}
id = 1
mapx = 56
mapy = -428
pdrawx = 0
pdrawy = 0
lastx = 0
lasty = 484
lastmapx = 56
lastmapy = -428
deaths = 0
milliseconds = 0
seconds = 0
minutes = 0
hours = 0
ending = 0
endingframe = 0
gamemode = 0
fdrawx = 0
fdrawy = 0
state = 0
climb = 0
mercy = 30
skycolor = 12
jpress = 0
option = 0
gamestate = 3
password1 = 0
password2 = 0
password3 = 0
password4 = 0
password5	= 0
password6 = 0
spawnplace = 1
timecount = 0
timedeathcount = 0
currentdigit = 1
checksum = 0
end

-- update section
function spawn_place()
for p in all(players) do
if spawnplace == 1 then
p.x = 0
p.y = 484
mapx = 56 - p.x
mapy = p.y - p.y - p.y + 56
end
if spawnplace == 2 then
for pu in all(powerups) do
 if pu.t == 0 then
  p.x = pu.x
  p.y = pu.y
 end
end
mapx = 56 - p.x
mapy = p.y - p.y - p.y + 56
end
if spawnplace == 3 then
for pu in all(powerups) do
 if pu.t == 1 then
  p.x = pu.x
  p.y = pu.y
 end
end
mapx = 56 - p.x
mapy = p.y - p.y - p.y + 56
end
if spawnplace == 4 then
for pu in all(powerups) do
 if pu.t == 2 then
  p.x = pu.x
  p.y = pu.y
 end
end
mapx = 56 - p.x
mapy = p.y - p.y - p.y + 56
end
if spawnplace == 5 then
for pu in all(powerups) do
 if pu.t == 3 then
  p.x = pu.x
  p.y = pu.y
 end
end
mapx = 56 - p.x
mapy = p.y - p.y - p.y + 56
end
end
end

function update_psystems()
	local timenow = time()
	for ps in all(particle_systems) do
		update_ps(ps, timenow)
	end
end

function update_ps(ps, timenow)
	for et in all(ps.emittimers) do
		local keep = et.timerfunc(ps, et.params)
		if (keep==false) then
			del(ps.emittimers, et)
		end
	end

	for p in all(ps.particles) do
		p.phase = (timenow-p.starttime)/(p.deathtime-p.starttime)

		for a in all(ps.affectors) do
			a.affectfunc(p, a.params)
		end

		p.x += p.vx
		p.y += p.vy
		
		local dead = false
		if (p.x<0 or p.x>127 or p.y<0 or p.y>127) then
			dead = true
		end

		if (timenow>=p.deathtime) then
			dead = true
		end

		if (dead==true) then
			del(ps.particles, p)
		end
	end
	
	if (ps.autoremove==true and count(ps.particles)<=0) then
		del(particle_systems, ps)
	end
end

function update_enemy(self)
if self.t == 0 or self.t == 3 or self.t == 4 or self.t == 6 then
if self.d == 0 then
if fget(mget((self.x+3)/8,(self.y+3)/8)) != 2 then
self.x -= 0.5
end
if fget(mget((self.x+3)/8,(self.y+3)/8)) == 2 then
self.d = 1
end
end
if self.d == 1 then
if fget(mget((self.x+5)/8,(self.y+3)/8)) != 2 then 
self.x += 0.5
end
if fget(mget((self.x+5)/8,(self.y+3)/8)) == 2 then
self.d = 0
end
end
end
if self.t == 1 or self.t == 2 or self.t == 5 then
if self.d == 0 then
if fget(mget((self.x+4)/8,(self.y+5)/8)) != 2 then
self.y += 0.5
else
self.d = 1
end
end
if self.d == 1 then
if fget(mget((self.x+4)/8,(self.y+3)/8)) != 2 then 
self.y -= 0.5
else
self.d = 0
end
end
end
self.count += 1
if self.count >= 50 then
 if self.t == 0 then
  spawn_bullet(self.x, self.y + 4, 3, 1)
 end
 if self.t == 1 then
  spawn_bullet(self.x, self.y, 0, 1)
 end
 if self.t == 2 then
  spawn_bullet(self.x, self.y, 1, 1)
 end
 if self.t == 3 then
  spawn_bullet(self.x, self.y - 4, 2, 1)
 end
 if self.t == 6 then
  spawn_bullet(self.x, self.y, self.d, 1)
 end
 self.count = 0
end
if self.l <= 0 then
sfx(2)
del(enemies, self)
make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
end
end

function update_enemies()
for enemy in all(enemies) do
	update_enemy(enemy)
end
end

function spawn_enemy(x, y, t)
local e = {}
e.x = x
e.y = y
e.t = t
e.d = 0
e.count = 0
e.l = 5
add(enemies, e)
return e
end

function spawn_bullet(x, y, d, m)
local b = {}
b.x = x
b.y = y
b.d = d
b.m = m
add(bullets, b)
return b
end

function update_bullets()
for bullet in all(bullets) do
 update_bullet(bullet)
end
end

function update_bullet(self)
 if self.x < 0 then
  del(bullets, self)
 end
 if self.x > 1100 then
  del(bullets, self)
 end
 if self.y < 0 then
  del(bullets, self)
 end
 if self.y > 600 then
  del(bullets, self)
 end
	if self.d == 0 then
	if fget(mget((self.x+3)/8,(self.y+3)/8)) != 2 then
	self.x -= 2
	end
	if fget(mget((self.x+3)/8,(self.y+3)/8)) == 2 then
	if mget((self.x+3)/8,(self.y+3)/8) == 81 then
		make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
		mset((self.x+3)/8,(self.y+3)/8, 0)
	 sfx(0)
	end
	if mget((self.x+3)/8,(self.y+3)/8) == 86 then
		make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
		mset((self.x+3)/8,(self.y+3)/8, 15)
	 sfx(0)
	end
	if mget((self.x+3)/8,(self.y+3)/8) == 87 then
		make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
		mset((self.x+3)/8,(self.y+3)/8, 16)
	 sfx(0)
	end
	del(bullets, self)
	end
	end
	if self.d == 1 then
	if fget(mget((self.x+5)/8,(self.y+3)/8)) != 2 then
	self.x += 2
	end
	if fget(mget((self.x+5)/8,(self.y+3)/8)) == 2 then
	if mget((self.x+5)/8,(self.y+3)/8) == 81 then
		make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
		mset((self.x+5)/8,(self.y+3)/8, 0)
	 sfx(0)
	end
	if mget((self.x+5)/8,(self.y+3)/8) == 86 then
		make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
		mset((self.x+5)/8,(self.y+3)/8, 15)
	 sfx(0)
	end
	if mget((self.x+5)/8,(self.y+3)/8) == 87 then
		make_explosion_ps(fdrawx+self.x,fdrawy+self.y)
		mset((self.x+5)/8,(self.y+3)/8, 16)
	 sfx(0)
	end
	del(bullets, self)
	end
	end
	if self.d == 3 then
	if fget(mget((self.x+4)/8,(self.y+5)/8)) != 2 then
	self.y += 2
	end
	if fget(mget((self.x+4)/8,(self.y+5)/8)) == 2 then
	del(bullets, self)
	end
	end
	if self.d == 2 then
	if fget(mget((self.x+4)/8,(self.y+3)/8)) != 2 then
	self.y -= 2
	end
	if fget(mget((self.x+4)/8,(self.y+3)/8)) == 2 then
	del(bullets, self)
	end
	end
end

function update_collisions()
mercy -= 1
for p in all(players) do
for b in all(bullets) do
	if abs(p.x - b.x) <= 4 and abs(p.y-b.y) <= 5 then
  if b.m == 1 then
 deaths += 1
 sfx(2)
 music(0)
 make_blood_ps(fdrawx+p.x, fdrawy+p.y)
 gamestate = 1
  end
 end
end
end
for p in all(players) do
for e in all(enemies) do
	if abs(p.x - e.x) <= 4 and abs(p.y-e.y) <= 5 then
 deaths += 1
 sfx(2)
 music(0)
 gamestate = 1
 make_blood_ps(fdrawx+p.x, fdrawy+p.y)
 end
end
end
for e in all(enemies) do
for b in all(bullets) do
 if abs(e.x - b.x) <= 4 and abs(e.y-b.y) <= 5 then
  if b.m == 0 then
   e.l -= 1
   sfx(0)
   del(bullets, b)
  end
 end
end
end
for p in all(players) do
for pu in all(powerups) do
if p.jb >= 1 then
 if pu.t == 0 then
  del(powerups, pu)
 end
end
if p.gl == 1 then
 if pu.t == 1 then
  del(powerups, pu)
 end
end
if p.sh == 1 then
 if pu.t == 2 then
  del(powerups, pu)
 end
end
if p.jb >= 2 then
 if pu.t == 3 then
  del(powerups, pu)
 end
end
if abs(p.x - pu.x) <= 4 and abs(p.y-pu.y) <= 5 then
	lastx = p.x
 lasty = p.y
 lastmapx = mapx
 lastmapy = mapy
	if (pu.t == 0) then
 sfx(4)
 p.jb = 1
 make_daytime()
 del(powerups, pu)
 spawnplace = 2
 end
 if (pu.t == 1) then
 sfx(4)
 p.gl = 1
 make_nighttime()
 destroy_gloveblocks()
 del(powerups, pu)
 spawnplace = 3
 end
 if (pu.t == 2) then
 sfx(4)
 p.sh = 1
 make_daytime()
 del(powerups, pu)
 spawnplace = 4
 end
 if (pu.t == 3) then
 sfx(4)
 p.jb = 2
 make_nighttime()
 del(powerups, pu)
 spawnplace = 5
 end
 if (pu.t == 4) then
 make_nighttime()
 del(powerups, pu)
 gamestate = 2
 music(3)
 end
end
end
end
end

function spawn_player()
local p = {}
p.x = 0
p.y = 484
p.d = 0
p.jb = 0
p.gl = 0
p.sh = 0
p.jc = 0
p.jump = 0
add(players, p)
return p
end

function spawn_mapstuff()
for mapx = 0, 128, 1 do
for mapy = 0, 64, 1 do
if (mget(mapx, mapy) == 73) then
	spawn_shit(mapx * 8, mapy * 8, 0)
 mset(mapx, mapy, 16)
end
if (mget(mapx, mapy) == 74) then
	spawn_shit(mapx * 8, mapy * 8, 1)
 mset(mapx, mapy, 15)
end
if (mget(mapx, mapy) == 75) then
	spawn_shit(mapx * 8, mapy * 8, 2)
 mset(mapx, mapy, 16)
end
if (mget(mapx, mapy) == 88) then
	spawn_shit(mapx * 8, mapy * 8, 3)
 mset(mapx, mapy, 16)
end
if (mget(mapx, mapy) == 92) then
	spawn_enemy(mapx * 8, mapy * 8, 0)
 mset(mapx, mapy, mget(mapx, mapy+1))
end
if (mget(mapx, mapy) == 93) then
	spawn_enemy(mapx * 8, mapy * 8, 1)
 mset(mapx, mapy, mget(mapx, mapy+1))
end
if (mget(mapx, mapy) == 94) then
	spawn_enemy(mapx * 8, mapy * 8, 2)
 mset(mapx, mapy, mget(mapx, mapy+1))
end
if (mget(mapx, mapy) == 95) then
	spawn_enemy(mapx * 8, mapy * 8, 3)
 mset(mapx, mapy, mget(mapx, mapy-1))
end
if (mget(mapx, mapy) == 96) then
	spawn_enemy(mapx * 8, mapy * 8, 4)
 mset(mapx, mapy, mget(mapx-1, mapy))
end
if (mget(mapx, mapy) == 97) then
	spawn_enemy(mapx * 8, mapy * 8, 5)
 mset(mapx, mapy, mget(mapx, mapy+1))
end 
if (mget(mapx, mapy) == 98) then
	spawn_enemy(mapx * 8, mapy * 8, 6)
 mset(mapx, mapy, mget(mapx-1, mapy))
end
if (mget(mapx, mapy) == 90) then
	spawn_shit(mapx * 8, mapy * 8, 4)
end
end
end
end

function spawn_shit(x, y, t)
local pu = {}
pu.x = x
pu.y = y
pu.t = t
pu.j = 0
pu.d = 0
pu.ti = 0
add(powerups, pu)
return pu
end

function update_players()
for p in all(players) do
update_player(p)
end
end

function update_player(self)
if (self.jb > 2) self.jb = 2
if (self.sh > 1) self.sh = 1
if (self.gl > 1) self.gl = 1
milliseconds += 1
if milliseconds >= 60 then
seconds += 1
milliseconds = 0
end
if seconds >= 60 then
minutes += 1
seconds = 0
end
if minutes >= 60 then
hours += 1
minutes = 0
end
if self.jb >= 1 then
 if fget(mget(flr((self.x + 4) / 8), flr((self.y + 4) / 8))) != 1 then
 		self.jc = self.jb
 end
 if fget(mget(flr((self.x + 4) / 8), flr((self.y + 4) / 8))) == 1 then
 	if self.jc > self.jb - 1	then
 		self.jc = self.jb - 1
 	end
 end
 if btnp(x) then
  if self.jc > 0 then
   if self.jump <= 0 then
   if jpress == 0 then
 		self.jump = 24
 		self.jc -= 1
 		sfx(10)
 		end
 		end
 	end
	end
	if btn(x) then
 jpress = 1
 end
 if not btn(x) then
 jpress = 0
 end
end
if self.sh == 1 then
 if btnp(o) then
 		spawn_bullet(self.x, self.y - 4, self.d, 0)
 end
end
if self.jump > 0 then
 if fget(mget(flr((self.x + 4) / 8), flr((self.y + 4) / 8))) != 4 then
		self.y -= 2
  mapy += 2
	end
	self.jump -= 1
end
if self.y > 512 then
 deaths += 1
 sfx(1)
 music(0)
 gamestate = 1
end
if fget(mget(flr((self.x + 4) / 8), flr((self.y) / 8))) == 2 or fget(mget(flr((self.x + 4) / 8), flr((self.y) / 8))) > 4 then
self.y += 2
mapy -= 2
self.jump = 0
end
if fget(mget(flr((self.x + 4) / 8), flr((self.y + 4) / 8))) == 1 then
self.y += 1
mapy -= 1
if fget(mget(flr((self.x + 4) / 8), flr((self.y + 4) / 8))) == 2 then
climb = 29
end
end
if fget(mget(flr((self.x + 4) / 8), flr((self.y + 4) / 8))) == 8 then
deaths += 1
sfx(0)
music(0)
gamestate = 1
make_blood_ps(fdrawx+self.x, fdrawy+self.y)
end
if btn(left) then
	if fget(mget((self.x+3)/8,(self.y+3)/8)) == 2 or fget(mget((self.x+3)/8,(self.y+3)/8)) == 8 then
 self.y -= 1
 mapy += 1
 self.jump = 0
 end
	if btn(up) then
 if fget(mget((self.x+3)/8,(self.y+3)/8)) == 2 or fget(mget((self.x+3)/8,(self.y+3)/8)) == 8 then
 self.y -= 0.5
 mapy += 0.5
 climb += 1
 if self.gl == 1 then
 self.y -= 0.5
 mapy += 0.5
 end
 end
 end
 if btn(down) then
 if fget(mget((self.x+3)/8,(self.y+3)/8)) == 2 or fget(mget((self.x+3)/8,(self.y+3)/8)) == 8 then
 self.y += 0.5
 mapy -= 0.5
 climb += 1
 if self.gl == 1 then
 self.y += 0.5
 mapy -= 0.5
 end
 end
 end
 if fget(mget((self.x+3)/8,(self.y+3)/8)) != 2 then
 self.x -= 1
 mapx += 1
 self.d = 0
 end
end
if btn(right) then
	if fget(mget((self.x+5)/8,(self.y+3)/8)) == 2 or fget(mget((self.x+5)/8,(self.y+3)/8)) == 8 then
 self.y -= 1
 mapy += 1
 self.jump = 0
 end
	if btn(up) then
 if fget(mget((self.x+5)/8,(self.y+3)/8)) == 2 or fget(mget((self.x+5)/8,(self.y+3)/8)) == 8 then
 self.y -= 0.5
 mapy += 0.5
 climb += 1
 if self.gl == 1 then
 self.y -= 0.5
 mapy += 0.5
 end
 end
 end
 if btn(down) then
 if fget(mget((self.x+5)/8,(self.y+3)/8)) == 2 or fget(mget((self.x+5)/8,(self.y+3)/8)) == 8 then
 self.y += 0.5
 mapy -= 0.5
 climb += 1
 if self.gl == 1 then
 self.y += 0.5
 mapy -= 0.5
 end
 end
 end
 if fget(mget((self.x+5)/8,(self.y+3)/8)) != 2 then
 self.x += 1
 mapx -= 1
 self.d = 1
 end
end
if btn(up) then
if fget(mget((self.x+5)/8,(self.y+3)/8)) == 4 then
 self.y -= 0.5
 mapy += 0.5
 climb += 1
end
end
if btn(down) then
if fget(mget((self.x+5)/8,(self.y+4)/8)) == 4 then
 self.y += 0.5
 mapy -= 0.5
 climb += 1
end
end
if fget(mget((self.x+5)/8,(self.y+4)/8)) == 4 then
 self.jump -= 1
end
if fget(mget((self.x+5)/8,(self.y+3)/8)) == 16 then
 deaths += 1
 sfx(0)
 music(0)
 gamestate = 1
 make_blood_ps(fdrawx+self.x, fdrawy+self.y)
end
if fget(mget((self.x+3)/8,(self.y+3)/8)) == 32 then
 deaths += 1
 sfx(0)
 music(0)
 gamestate = 1
 make_blood_ps(fdrawx+self.x, fdrawy+self.y)
end
if climb >= 30 then
sfx(3, 3)
climb = 0
if self.d == 0 then
make_dirt_ps(fdrawx+self.x,fdrawy+self.y, 1)
end
if self.d == 1 then
make_dirt_reverse_ps(fdrawx+5+self.x,fdrawy+self.y, -1)
end
end
end

function make_daytime()
for mapx = 0, 128, 1 do
for mapy = 0, 64, 1 do
if mget(mapx, mapy) == 76 then
mset(mapx, mapy, 61)
end
if mget(mapx, mapy) == 77 then
mset(mapx, mapy, 58)
end
if mget(mapx, mapy) == 78 then
mset(mapx, mapy, 59)
end
if mget(mapx, mapy) == 79 then
mset(mapx, mapy, 60)
end
end
end
skycolor = 12
end

function make_nighttime()
for mapx = 0, 128, 1 do
for mapy = 0, 64, 1 do
if mget(mapx, mapy) == 61 then
mset(mapx, mapy, 76)
end
if mget(mapx, mapy) == 58 then
mset(mapx, mapy, 77) 
end
if mget(mapx, mapy) == 59 then
mset(mapx, mapy, 78)
end
if mget(mapx, mapy) == 60 then
mset(mapx, mapy, 79)
end
end
end
skycolor = 1
end

function destroy_gloveblocks()
for mapx = 0, 128, 1 do
for mapy = 0, 64, 1 do
if mget(mapx, mapy) == 83 then
mset(mapx, mapy, 15)
end
end
end
end

function update_mapstuff()
for powerup in all(powerups) do
update_shit(powerup)
end
end

function update_shit(self)
if self.t < 4 then
if self.ti >= 10 then
if self.j < 2 then
 if self.d == 0 then
  self.y -= 1
  self.j += 1
 end
end
if self.j > 0 then
 if self.d == 1 then
  self.y += 1
  self.j -= 1
 end
end
if self.j == 0 then
 if self.d == 1 then
  self.d = 0
 end
end
if self.j == 2 then
 if self.d == 0 then
  self.d = 1
 end
end
self.ti = 0
end
self.ti += 1
end
end

-- draw section
function draw_pass()
cls()
timecount += 1
if (currentdigit == 1) and (btnp(up)) then
password1 -= 1
end
if (currentdigit == 1) and (btnp(down)) then
password1 += 1
end
if (currentdigit == 2) and (btnp(up)) then
password2 -= 1
end
if (currentdigit == 2) and (btnp(down)) then
password2 += 1
end
if (currentdigit == 3) and (btnp(up)) then
password3 -= 1
end
if (currentdigit == 3) and (btnp(down)) then
password3 += 1
end
if (currentdigit == 4) and (btnp(up)) then
password4 -= 1
end
if (currentdigit == 4) and (btnp(down)) then
password4 += 1
end
if (currentdigit == 5) and (btnp(up)) then
password5 -= 1
end
if (currentdigit == 5) and (btnp(down)) then
password5 += 1
end
if (currentdigit == 6) and (btnp(up)) then
password6 -= 1
end
if (currentdigit == 6) and (btnp(down)) then
password6 += 1
end
checksum = password1+password2+password3+password4+password5-1
if checksum > 9 then
checksum = 9
end
if checksum < 0 then
checksum = 0
end
if (password1 < 0) password1 = 0
if (password1 > 9) password1 = 9
if (password2 < 0) password2 = 0
if (password2 > 9) password2 = 9
if (password3 < 0) password3 = 0
if (password3 > 9) password3 = 9
if (password4 < 0) password4 = 0
if (password4 > 9) password4 = 9
if (password5 < 0) password5 = 0
if (password5 > 9) password5 = 9
if (password6 < 0) password6 = 0
if (password6 > 9) password6 = 9
if (btnp(left)) currentdigit -= 1
if (btnp(right)) currentdigit += 1
if (currentdigit <= 0) currentdigit = 1
if (currentdigit >= 7) currentdigit = 6
if timecount >= 50 then
if btn(x) then
 if password1 == 9 then
 if password6 == 1 then
  music(password5)
 end
 end
 if checksum == password6 then
  for self in all(players) do
   self.jb = password1
   self.gl = password2
   self.sh = password3
   self.jb = password4
  end
   spawnplace=password5
   spawn_place()
   music(3)
   option = 0
   timecount = 0
   gamestate = 0
 else
  sfx(11)
  timecount = 0
 end
end
end
map(113,2,44,32,16,2)
rect(36, 52, 90, 72, 7)
rect(36, 78, 90, 102, 7)
print(password1..password2..password3..password4..password5..password6, 48, 56, 7)
spr(64, 42+4*currentdigit, 63)
print("(cc) 2016", 42, 80, 7)
print("adrian makes", 42, 88, 7)
print("   games   ", 42, 96, 7)
end

function draw_menu()
cls()
timecount += 1
if (btn(up)) and (option == 1) then sfx(8) end
if (btn(down)) and (option == 0) then sfx(8) end
if (btn(up)) option = 0
if (btn(down)) option = 1
if timecount >= 50 then
if btn(x) then
if option == 0 then
 timecount = 0
 music(3)
 gamestate = 0
 deleteallps()
 for p in all(players) do
 p.x = lastx
 p.y = lasty
 end
 mapx = lastmapx
 mapy = lastmapy
 sfx(9)
end
if option == 1 then
 timecount = 0
 gamestate = 5
 sfx(9)
end
end
map(113,2,44,32,16,2)
rect(36, 52, 90, 72, 7)
rect(36, 78, 90, 102, 7)
print("start", 48, 56, 7)
print("password", 48, 64, 7)
print("(cc) 2016", 42, 80, 7)
print("adrian makes", 42, 88, 7)
print("   games   ", 42, 96, 7)
if option == 0 then
spr(70, 38, 54)
end
if option == 1 then
spr(70, 38, 63)
end
end
end

function draw_ps(ps, params)
	for df in all(ps.drawfuncs) do
		df.drawfunc(ps, df.params)
	end
end

function draw_gover()
timecount += 1
if (btn(up)) and (option == 1) then sfx(8) end
if (btn(down)) and (option == 0) then sfx(8) end
if (btn(up)) option = 0
if (btn(down)) option = 1
if timecount >= 50 then
if btn(x) then
if option == 0 then
 music(3)
 gamestate = 0
 timecount = 0
 deleteallps()
 for p in all(players) do
 p.x = lastx
 p.y = lasty
 end
 mapx = lastmapx
 mapy = lastmapy
 sfx(9)
end
if option == 1 then
 _init()
 sfx(9)
end
end
for self in all(players) do
password1 = self.jb
password2 = self.gl
password3 = self.sh
password4 = self.jb
end
password5 = spawnplace
password6 = password1+password2+password3+password4+password5-1
if password6 >= 10 then
password6 = 9
end
if password6 < 0 then
password6 = 0
end
map(112,0,40,32,16,2)
rect(36, 52, 90, 72, 7)
rect(36, 78, 90, 94, 7)
print("continue", 48, 56, 7)
print("end", 48, 64, 7)
print("pass:"..password1..password2..password3..password4..password5..password6, 42, 80, 7)
print("deaths:"..deaths, 42, 88, 7)
if option == 0 then
spr(70, 38, 54)
end
if option == 1 then
spr(70, 38, 63)
end
end
end

function draw_ending()
timecount += 1
if timecount >= 50 then
cls()
rect(6, 94, 122, 122,7)
spr(1, 56, 56)
print("voice in your head:",8,96,7)
print("good job, boy.",8,104,7)
end
if timecount >= 100 then
cls()
rect(6, 94, 122, 122,7)
spr(1, 48, 56)
spr(2, 64, 56)
spr(105, 56, 40)
print("voice in your head:",8,96,7)
print("you rescued the world.",8,104,7)
end
if timecount >= 150 then
cls()
rect(6, 94, 122, 122,7)
spr(1, 48, 56)
spr(112, 56, 48)
spr(1, 64, 56)
spr(112, 72, 48)
print("voice in your head:",8,96,7)
print("as you can see, everyone is\nsinging hymns about you.",8,104,7)
end
if timecount >= 200 then
cls()
rect(6, 94, 122, 122,7)
spr(2, 40, 56)
spr(54, 56, 56)
spr(55, 64, 56)
print("voice in your head:",8,96,7)
print("now, go home...\n and be a family boy",8,104,7)
end
if timecount >= 250 then
cls()
rect(6, 94, 122, 122,7)
print("~stats~",8,96,7)
print("time: "..hours..":"..minutes..":"..seconds.."\ndeaths: "..deaths.."\ngood job!",8,104,7)
end
if timecount >= 300 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("programmer\n adrian makes games",8,104,7)
end
if timecount >= 350 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("character designer\n adrian makes games",8,104,7)
end
if timecount >= 400 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("graphic designer\n adrian makes games",8,104,7)
end
if timecount >= 450 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("music composer\n mitsuyasu t., sivak, amg",8,104,7)
end
if timecount >= 500 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("music arranger\n adrian makes games",8,104,7)
end
if timecount >= 550 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("level designer\n adrian makes games",8,104,7)
end
if timecount >= 600 then
cls()
rect(6, 94, 122, 122,7)
print("~staff~",8,96,7)
print("game designer\n adrian makes games",8,104,7)
end
if timecount >= 650 then
cls()
rect(6, 94, 122, 122,7)
print(" ",8,96,7)
print("          the end          ",8,104,7)
end
end

function draw_intro()
timecount += 1
if (btnp(x)) then
setpal(0)
gamestate = 4
timecount = 0
music(2)
end
if timecount >= 0 then
cls()
rect(6, 94, 122, 122,7)
print("2 years later...",8,96,7)
print("",8,104,7)
end
if timecount >= 100 then
cls()
rect(6, 94, 122, 122,7)
spr(113, 48, 56)
spr(113, 64, 56)
spr(105, 56, 56)
spr(105, 72, 56)
print("a wave of cyberdemons",8,96,7)
print("has enslaved the world.",8,104,7)
end
if timecount >= 200 then
cls()
rect(6, 94, 122, 122,7)
spr(1, 56, 56)
spr(114, 56, 48)
print("there's only one boy",8,96,7)
print("that can save the world.",8,104,7)
end
if timecount >= 300 then
cls()
rect(6, 94, 122, 122,7)
spr(2, 56, 56)
spr(113, 48, 56)
spr(113, 64, 56)
print("voice in your head:",8,96,7)
print("go, the chosen one!!!\nyou must save the world\nfrom danger of cyberdemons!",8,104,7)
end
if timecount >= 400 then
cls()
rect(6, 94, 122, 122,7)
spr(3, 52, 48)
spr(4, 52, 56)
spr(2, 56, 52)
print("voice in your head:",8,96,7)
print("you will save the world...\nclimbing mountains!",8,104,7)
end
if timecount >= 500 then
cls()
rect(6, 94, 122, 122,7)
spr(3, 52, 48)
spr(4, 52, 56)
spr(2, 56, 52)
print("the chosen one:",8,96,7)
print("so, this time i won't save\na princess? but why?\nnevermind, i'll do it!",8,104,7)
end
if timecount >= 600 then
setpal(1)
end
if timecount >= 610 then
setpal(2)
end
if timecount >= 620 then
setpal(3)
end
if timecount >= 630 then
setpal(0)
timecount = 0
music(2)
gamestate = 4
end
end


function draw_map(x, y)
pdrawx = 0
pdrawy = 0
drawx = x
drawy = y
if x > 0 then 
drawx = 0 
pdrawx = x
end
if y < -384 then
drawy = -384
pdrawy = -384 - y
end
if x < -768 then
drawx = -768
pdrawx = -768 - x
end
if y > 0 then
drawy = 0
pdrawy = y
end
map(112,48,0,0,16,16)
map(0,0,drawx,drawy,128,128)
end
function draw_players()
for player in all(players) do
	draw_player(player)
end
end

function draw_player(self)
if gamestate == 0 then
if mapy < 0 then
if mapx > 0 then
if (self.d == 0) spr(2, 56-pdrawx, 56-4+pdrawy)
if (self.d == 1) spr(1, 56-pdrawx, 56-4+pdrawy)
end
if mapx <= 0 then
if (self.d == 0) spr(2, 56+pdrawx, 56-4+pdrawy)
if (self.d == 1) spr(1, 56+pdrawx, 56-4+pdrawy)
end
end
if mapy > 0 then
if mapx > 0 then
if (self.d == 0) spr(2, 56-pdrawx, 56-4-pdrawy)
if (self.d == 1) spr(1, 56-pdrawx, 56-4-pdrawy)
end
if mapx <= 0 then
if (self.d == 0) spr(2, 56+pdrawx, 56-4-pdrawy)
if (self.d == 1) spr(1, 56+pdrawx, 56-4-pdrawy)
end
end
end
if gamestate == 1 then
if mapy < 0 then
if mapx > 0 then
if (self.d == 0) spr(106, 56-pdrawx, 56-4+pdrawy)
if (self.d == 1) spr(105, 56-pdrawx, 56-4+pdrawy)
end
if mapx <= 0 then
if (self.d == 0) spr(106, 56+pdrawx, 56-4+pdrawy)
if (self.d == 1) spr(105, 56+pdrawx, 56-4+pdrawy)
end
end
if mapy > 0 then
if mapx > 0 then
if (self.d == 0) spr(106, 56-pdrawx, 56-4-pdrawy)
if (self.d == 1) spr(105, 56-pdrawx, 56-4-pdrawy)
end
if mapx <= 0 then
if (self.d == 0) spr(106, 56+pdrawx, 56-4-pdrawy)
if (self.d == 1) spr(105, 56+pdrawx, 56-4-pdrawy)
end
end
end
end

function prepare_draw(x, y)
fdrawx = x
fdrawy = y
if x > 0 then 
fdrawx = 0 
end
if y < -384 then
fdrawy = -384
end
if x < -768 then
fdrawx = -768
end
if y > 0 then
fdrawy = 0
end
end

function draw_mapstuff()
for powerup in all(powerups) do
draw_shit(powerup)
end
end

function draw_shit(self)
 if self.t == 0 then
  spr(73, fdrawx + self.x, fdrawy + self.y)
 end
 if self.t == 1 then
  spr(74, fdrawx + self.x, fdrawy + self.y)
 end
 if self.t == 2 then
  spr(75, fdrawx + self.x, fdrawy + self.y)
 end
 if self.t == 3 then
  spr(88, fdrawx + self.x, fdrawy + self.y)
 end
end

function draw_bullets()
for bullet in all(bullets) do
 draw_bullet(bullet)
end
end

function draw_bullet(self)
spr(85, fdrawx + self.x, fdrawy + self.y)
end

function draw_enemies()
for enemy in all(enemies) do
 draw_enemy(enemy)
end
end

function draw_enemy(self)
spr(92+self.t, fdrawx + self.x, fdrawy + self.y)
end

function setpal(y)
 if y==0 then
  for z=0,15 do
   pal(z,z)
  end
 elseif y==1 then
  pal(1,0)
  pal(2,1)
  pal(3,2)
  pal(4,2)
  pal(5,1)
  pal(6,5)
  pal(7,6)
  pal(8,2)
  pal(9,4)
  pal(10,9)
  pal(11,3)
  pal(12,13)
  pal(13,1)
  pal(14,8)
  pal(15,9)
 elseif y==2 then
  pal(1,0) //0
  pal(2,0) //1
  pal(3,1) //2
  pal(4,1) //2
  pal(5,0) //1
  pal(6,1) //5
  pal(7,5) //6
  pal(8,1) //2
  pal(9,2) //4
  pal(10,4) //9
  pal(11,2) //3
  pal(12,1) //13
  pal(13,0) //1
  pal(14,2) //8
  pal(15,4) //9
 elseif y==3 then
  pal(1,0) //0
  pal(2,0) //1
  pal(3,0) //2
  pal(4,0) //2
  pal(5,0) //1
  pal(6,0) //5
  pal(7,2) //6
  pal(8,0) //2
  pal(9,1) //4
  pal(10,1) //9
  pal(11,1) //3
  pal(12,0) //13
  pal(13,0) //1
  pal(14,1) //8
  pal(15,2) //9
 end
end

function draw_gui()
spr(121,8,12)
spr(121,16,12)
spr(121,24,12)
spr(121,32,12)
for p in all(players) do
 if p.jb == 1 then
  spr(73,8,12)
 end
 if p.gl == 1 then
  spr(74,16,12)
 end
 if p.sh == 1 then
  spr(75,24,12)
 end
 if p.jb == 2 then
  spr(73,8,12)
  spr(88,32,12)
 end
end
print("inventory", 8, 4, 5)
print("inventory", 8, 3, 7)
print("deaths: "..deaths, 8, 32, 5)
print("deaths: "..deaths, 8, 31, 7)
print(pad(hours,2)..":"..pad(minutes,2)..":"..pad(seconds,2), 8, 24, 5)
print(pad(hours,2)..":"..pad(minutes,2)..":"..pad(seconds,2), 8, 23, 7)
end

-- utility shit
function emittimer_burst(ps, params)
	for i=1,params.num do
		emit_particle(ps)
	end
	return false
end

function emittimer_constant(ps, params)
	if (params.nextemittime<=time()) then
		emit_particle(ps)
		params.nextemittime += params.speed
	end
	return true
end

function emit_particle(psystem)
	local p = {}

	local e = psystem.emitters[flr(rnd(#(psystem.emitters)))+1]
	e.emitfunc(p, e.params)	

	p.phase = 0
	p.starttime = time()
	p.deathtime = time()+rnd(psystem.maxlife-psystem.minlife)+psystem.minlife

	p.startsize = rnd(psystem.maxstartsize-psystem.minstartsize)+psystem.minstartsize
	p.endsize = rnd(psystem.maxendsize-psystem.minendsize)+psystem.minendsize

	add(psystem.particles, p)
end

function emitter_point(p, params)
	p.x = params.x
	p.y = params.y

	p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
	p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function emitter_box(p, params)
	p.x = rnd(params.maxx-params.minx)+params.minx
	p.y = rnd(params.maxy-params.miny)+params.miny

	p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
	p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function affect_force(p, params)
	p.vx += params.fx
	p.vy += params.fy
end

function affect_forcezone(p, params)
	if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
		p.vx += params.fx
		p.vy += params.fy
	end
end

function affect_stopzone(p, params)
	if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
		p.vx = 0
		p.vy = 0
	end
end

function affect_bouncezone(p, params)
	if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
		p.vx = -p.vx*params.damping
		p.vy = -p.vy*params.damping
	end
end

function affect_attract(p, params)
	if (abs(p.x-params.x)+abs(p.y-params.y)<params.mradius) then
		p.vx += (p.x-params.x)*params.strength
		p.vy += (p.y-params.y)*params.strength
	end
end

function affect_orbit(p, params)
	params.phase += params.speed
	p.x += sin(params.phase)*params.xstrength
	p.y += cos(params.phase)*params.ystrength
end

function draw_ps_fillcirc(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		r = (1-p.phase)*p.startsize+p.phase*p.endsize
		circfill(p.x,p.y,r,params.colors[c])
	end
end

function draw_ps_pixel(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		pset(p.x,p.y,params.colors[c])
	end	
end

function draw_ps_streak(ps, params)
	for p in all(ps.particles) do
		c = flr(p.phase*count(params.colors))+1
		line(p.x,p.y,p.x-p.vx,p.y-p.vy,params.colors[c])
	end	
end

function draw_ps_animspr(ps, params)
	params.currframe += params.speed
	if (params.currframe>count(params.frames)) then
		params.currframe = 1
	end
	for p in all(ps.particles) do
		pal(7,params.colors[flr(p.endsize)])
		spr(params.frames[flr(params.currframe+p.startsize)%count(params.frames)],p.x,p.y)
	end
	pal()
end

function draw_ps_agespr(ps, params)
	for p in all(ps.particles) do
		local f = flr(p.phase*count(params.frames))+1
		spr(params.frames[f],p.x,p.y)
	end	
end

function draw_ps_rndspr(ps, params)
	for p in all(ps.particles) do
		pal(7,params.colors[flr(p.endsize)])
		spr(params.frames[flr(p.startsize)],p.x,p.y)
	end	
	pal()
end

function make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)
	local ps = {}
	-- global particle system params
	ps.autoremove = true

	ps.minlife = minlife
	ps.maxlife = maxlife
	
	ps.minstartsize = minstartsize
	ps.maxstartsize = maxstartsize
	ps.minendsize = minendsize
	ps.maxendsize = maxendsize
	
	-- container for the particles
	ps.particles = {}

	-- emittimers dictate when a particle should start
	-- they called every frame, and call emit_particle when they see fit
	-- they should return false if no longer need to be updated
	ps.emittimers = {}

	-- emitters must initialize p.x, p.y, p.vx, p.vy
	ps.emitters = {}

	-- every ps needs a drawfunc
	ps.drawfuncs = {}

	-- affectors affect the movement of the particles
	ps.affectors = {}

	add(particle_systems, ps)

	return ps
end

function make_dirt_ps(ex,ey)
	local ps = make_psystem(2,3, 1,2,0.5,0.5)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 30}
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_point,
			params = { x = ex, y = ey, minstartvx = 0.5, maxstartvx = 1, minstartvy = -2, maxstartvy=-1 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_pixel,
			params = { colors = {2} }
		}
	)
	add(ps.affectors,
		{ 
			affectfunc = affect_force,
			params = { fx = 0, fy = 0.3 }
		}
	)
end

function make_dirt_reverse_ps(ex,ey)
	local ps = make_psystem(2,3, 1,2,0.5,0.5)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 30}
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_point,
			params = { x = ex, y = ey, minstartvx = -1, maxstartvx = -0.5, minstartvy = -2, maxstartvy=-1 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_pixel,
			params = { colors = {2} }
		}
	)
	add(ps.affectors,
		{ 
			affectfunc = affect_force,
			params = { fx = 0, fy = 0.3 }
		}
	)
end


function deleteallps()
	for ps in all(particle_systems) do
		del(particle_systems, ps)
	end
end

function make_blood_ps(ex,ey)
	local ps = make_psystem(2,3, 1,2,0.5,0.5)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 30}
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_point,
			params = { x = ex, y = ey, minstartvx = -1, maxstartvx = 1, minstartvy = -3, maxstartvy=-2 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_pixel,
			params = { colors = {8} }
		}
	)
	add(ps.affectors,
		{ 
			affectfunc = affect_force,
			params = { fx = 0, fy = 0.3 }
		}
	)
end

function make_explosion_ps(ex,ey)
	local ps = make_psystem(0.1,0.5, 9,14,1,3)
	
	add(ps.emittimers,
		{
			timerfunc = emittimer_burst,
			params = { num = 4 }
		}
	)
	add(ps.emitters, 
		{
			emitfunc = emitter_box,
			params = { minx = ex-4, maxx = ex+4, miny = ey-4, maxy= ey+4, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
		}
	)
	add(ps.drawfuncs,
		{
			drawfunc = draw_ps_fillcirc,
			params = { colors = {7,0,10,9,9,4} }
		}
	)
end

function pad(n, length)
    result = ''..n
    while #result < length do
      result = '0'..result
    end
    return result
endif(_update60)_update=function()_update60()_update60()end
__gfx__
0000000000888e0000e8880033333333444444444444444444444424242424242444444444444444444444442424242444242424242424245555555511111111
000000000088888008888800b33b33b3444244424442444244424442424242424242444244424442444244424242424244424242424242426656656655155155
0000000000ff7c0000c7ff0022222222444444444444444444444424444444442444444444444424244444442424244444442424242424245555555511111111
0000000000ffff0000ffff0042444244424442444244424442444242424442444244424442444242424442444242424442444242424242426666566655551555
0000000000bbbbf00fbbbb0044444444444444444444444444444424444444442444444444442424242444442424444444444424242424246666566655551555
00000000003333000033330044424442444244424242424244424442444244424242444244424242424244424242444244424442424242425555555511111111
00000000001111000011110044444444444444442424242444444424444444442444444444242424242424442444444444444444242424246656656655155155
00000000002202200220220042444244424442444242424242444242424442444244424442424242424242444244424442444244424242426656656655155155
12121212000bb000111bb111121bb21277777777cccccccc7cccccc77cccccccccccccc7cccccccc07777777777777777777777012bbbbbbbbbbbbbbbbbbbb12
21212121000bb330551bb335212bb331cccccccccccccccc7c7cc7c77c7cc7cccc7cc7c7cc7cc7cc7777777777777777777777772bbbbbbbbbbbbbbbbbbbbbb1
12121212000bb333111bb333121bb333cccccccccccccccc7c7cc7c77c7cc7cccc7cc7c7cc7cc7cc777777777777777777777777bb333333b333b333333333bb
21212121000bb000555bb555212bb121cccccccccccccccc7cccccc77cccccccccccccc7cccccccc077777777777777777777770b3b333333bb33bb33b33333b
12121212033bb000555bb555133bb212cccccccccccccccc7cc7ccc77cc7ccccccc7ccc7ccc7cccc077777777777777777777770b33bb3333333333333bb333b
21212121333bb000133bb111333bb121cccccccccccccccc7cc7ccc77cc7ccccccc7ccc7ccc7cccc776777777777777777777777b333333333b333333333333b
12121212000bb000333bb155121bb212cccccccccccccccc7cccccc77cccccccccccccc7cccccccc776666666666666666666777b3333b33333bb333333b333b
21212121000bb000551bb155212bb121cccccccccccccccc7cccccc77cccccccccccccc7cccccccc077666666666666666666670b33333bb333333333333bb3b
b3333333333333333333333bb3333333333333333333333b14244442142444420000000000000000333333331212121212121212121212121213321233333333
b3b33333b3333b333333333bb33b3333b3333b333b33333b24244241242442410000000000000000333333332121212121212121212121212133332133333333
b33bb3333bb333bb3b33333bb333bb333bb333bb33bb333b14244242142442420000000000000000333333331212121212121212121212121333333233e83333
b33333333333333333bb333bb3333333333333333333333b244442412444424100088800000aaa00333333333333333321333333333333213333333333883333
b333b333333333333333333bb3333b3333b3333333b3333b1444444214444442008eee8000a999a0333333333333333313333333333333323333333333333333
b3333bb333b33333333b333bb33333bb333bb333333bb33b242444412424444100088800000aaa00333333333333333333333333333333333333333333333e83
b3333333333bb3333333bb3b1b33333333333333333333b214244242442442440000b0000000b000333333333333333333333333333333333333333333333883
b3333333333333333333333b21bbbbbbbbbbbbbbbbbbbb2124244241442442440000b0000000b000333333333333333333333333333333333333333333333333
0000000d50000000ddddddddd55555555555555d555555550000000510000000511111115111111d0666666666666666666666600099990077777775333bb333
000000dd55000000dddddddddd555555555555dd55555555000000551100000055111111551111dd66666666666666666666666609aaaa9076666665333bbb13
00000dd555500000ddddddddddd5555555555dd55555555500000551111000005551111155511dd56666666666666666666666669aa77aa907666650333bb1b1
0000ddd555550000dddddddddddd55555555ddd5555555550000555111110000555511115555ddd50666666666666666666666609a7777a900766500333bb333
000dddd555555000ddddddddddddd555555dddd555555555000555511111100055555111555dddd50666666666666666666666609a7777a900075000333bb333
00dddd5555555500dddddddddddddd5555dddd555555555500555511111111005555551155dddd5566d6666666666666666666669aa77aa90007500031bbb333
0dd5d55555555550ddddddddddddddd55dd5d555555555550551511111111110555555515dd5d55566ddddddddddddddddddd66609aaaa90000750001b1bb333
dd5dd55555555555dddddddddddddddddd5dd55555555555551551111111111155555555dd5dd555066ddddddddddddddddddd600099990005555550333bb333
000d5000111d5111121d5212000000dd111111dd121212dddd000000dd111111dd12121200000000000000000000000000777700000000000000000000000000
000d5000551d5155212d51210000dd665515dd662121dd6666dd000066dd515566dd2121000000000000e8000000000007767770000000000007000000000000
00d6d50011d6d51112d6d51200dd666611dd666612dd66666666dd006666dd116666dd120700000000e8e8000054666077677777000000000000000000000000
00d6d50055d6d55521d6d521dd666666dd666666dd666666666666dd666666dd666666dd06744200008e88000094500076777777000000000000000000070000
0d66dd505d66dd551d66dd5255dddddd55dddddd55dddddddddddd55dddddd55dddddd5500644440000888000044000077777777000000000000000000000000
0d66dd501d66dd512d66dd510055dddd1155dddd2155dddddddd5500dddd5511dddd552100000000000888000044000077777777000000000000000000000000
dd66ddd5dd66ddd5dd66ddd5000055dd551555dd121255dddd550000dd555155dd55121200000000000000000000000007777770000007000000000000000000
d666ddd5d666ddd5d666ddd500000055551551552121215555000000551551555521212100000000000000000000000000777700000000000000000000000000
777777756651666677777777222222227cccccc700000000665166666651666600000000142d5442222222227cccccc707666650000777777777700000075000
7666666566516665766666658eeee8e27c7cc7c700000000665166656651666500000000242d5241944442427c7cc7c707666650000666666666600000075000
1766665255516651176666158ee8e8e27c7cc7c70000000055516651555166510700000014d6d542922222227c7cc7c707666650000666666666600000075000
2176652166555516557665558e8e88e27cccccc7000770006655551666555516067ee20024d6d541944442427cccccc707666650555666666666655500075000
1217521266665166555755558ee888e27cc7ccc7000770006666516666665166006eeee01d66dd52999922227cc7ccc700075000777666666666677707666650
2127512166665516111751118ee888e27cc7ccc7000000006666551666665516000000002d66dd51000920007cc7ccc700075000000666666666600007666650
1217521266651651551751558eeeeee27cccccc700000000666516516665165100000000d666ddd5000920007cccccc700075000000666666666600007666650
255555516651666555555555888888827cccccc700000000665166656651666500000000d666ddd5000920007cccccc700075000000555555555500007666650
000aa00000088000000220000880000880008008088800000000088008000808880888000000000000000000808000000000000d580000008000000099999999
00aa9a000088e800002ee200800800800800888808000000000080080800080800080080000000000000000088800800808088dd888008000088000899999999
0a9a99a008e8ee8002e77e2080080080080080080800000000008008080008080008008000000000000000008080808080808d85585080808080808009900990
a99aaaaa8ee8888802e7ce208000008008008008080000000000800808000808000800800800f002200f00808080808080808d85585580808080800809900990
aaaaa99a88888ee8002ee200800000800800800808000000000080080800080800080080e8cfb312213bfc8e80808080808d8d85585580808080800809900990
0a99a9a008ee8e8000022000800000800800800808000000000080080800080800080080887fb310013bf7888080080008dd8d85585558808080808009900990
00a9aa00008e88000020020080000080080080080800000000008008080008080008008088ffb312213bff88000000000dd5d555555555500000000009900990
000aa000000880000020020080000080080080080800000000008008080008080008008088ffb312213bff8800000000dd5dd555555555550000000009900990
00007000088888800000000080880088880080080888000000008008080008088808880050505050042444400000000ddddddddd555555555000000009900990
0000770088888888000000008008008008008008080000000000800808000808000800800505050504244240000000dddddddddd555585555500000009900990
000070708877778800000000800800800800800808000000000080080800080800080080505050500424424000000dd5dddddddd555555555550000009900990
0077700088722788000000008008008008008008080000000000800808000808000800800505050504444240080088d588dd888d858585585888000009900990
07777000887227880aaaaaa08008008008008008080000000000800808000808000800805050505004444440808d8dd58d8d8ddd888585855855500009900990
0777700088777788a000000a8008008008008008080000000000800808000808000800800505050504244440808d88558d8d888d858585585888550009900990
00770000888888880aaaaaa080080080080080080800000000008008008080080008008050505050442442448d8585558d8d8ddd858585585855555099999999
0000000008888880000000000880008008008008088800000000088000080008880800800505050544244244d85d855588dd888d858585855888555599999999
00000000000000000000000000404040404040d0d001010101013101d0e0f0f0f0f065f0f0f0e040324252016201010102122201010131014000000000000000
000000000000003440404040404040404040404040404040e0f006f0e0d001240124d00101310106166131610131d0d000000000000000000000000000000000
00000000000000000000000000404040404040d0d001010101013101d0e0e0e0e0e0e0e0e0e0e040249524249524242432425201010131014000000000000000
000000000000003440404040404040404040404040e0e0e0e0f0f0f0e0d001400140d00101310101016101610131d0d000000000000000000000000000000000
00000000000000000000000000404040404040d0d001019401013101d0d0d0d0d0d0d0d040404040404040404040404040404040400131014030000000000000
000000000000003440404040404040400000000000f0f0f0f0f0f0f0e0d001010601d0414141414141414141d031d0d000000000000000000000000000000000
00000000000000000000000082404040404040d0d001010501013101d0d0d0d0d0d0840101010101010101400101010101c50161010131010140000000000000
000000000000003440404040404040000000000000f0f0f0f0f0f0f0e0d001242424d0d0d0d0d0d0d0d0d0d0d031d0d000000000000000000000000000000000
00000000000000000000003030404040404040d0d0d0d0d0d0013101d0d0d0d0d0d0840101010101010101400101010101010161010131010140000000000000
000000000000003440404040404000000000000000f0f0f0f0f0f0f0e0d001404040d0d03161c50131718131013101d000000000000000000000000000000000
00000000000000000000004040404040404040d0d001310131013101d0d0d0d0d0d0840101010101010101400101014001010161160131010140000000000000
000000000000003440404040400000000000000000f0f0f0f0f0f0f0e0d001010101d0d03161010131718131013101d000000000000000000000000000000000
00000000000000000000004040404040404040d0d001310131013101d0d0d0d0d0d0840101404040010601400101544001010161010131010140820000000000
000000000000003440404040000000000000160000f0f0f0f0f0f0f0e0d024012401d0013161010131718131013101d000000000000000000000000000000000
00000000000000000000004040404040404040d0d001310101010101d0d0d0d0d0b0840101544040240101400101544001010161010101010140300000000000
000000000000003440404040000000000000000000f0f0f0f0f0f0f0e0d040014001d0013161010131718131010101d000000000000000000000000000000000
00000000000000000000004040404040404040d0d001312424242424d0d0d0d0b040844001544040400101400101014041414141414141414140403030640000
000000000000003440404040000000008200009200f0f0f0f0f0f0f0e0d00101010101010161010131718101242424d000000000000000000000000000000000
00000000000000000000004040404040404040d0d00131d0d0d0d0d0d0d0d0d04040840101544040010101408401014051515151515151515140404040640000
000000000000003440404040000000303030303030e03535e0f0f0f0e0d00101010101010161010101718101d0d0d0d000000000000000000000000000000000
00000000000000000000004040404040404040d0d00131d0d0d0d0d0d0d0d0d04040840101544040240124408401014040404040404040404040404040640000
000000000000003440404040000000004040404040e0f0f0e014f0f0e0d0d0d0d0d0d0d0414141d016718101d0d0d0d000000000000000000000000000000000
00000000000000000000304040404040404040d0d0013131313101d0d0d0d0d04040010140014040400140400185010101010101010101010101014000000000
000000000000003440404040000000000040404040e0f0f0e0e0f0f0e0d0d0d0d0d0d0d0d0d0d0d001718116d0d0d0d000000000000000000000000000000000
00000000000000008230404040404040404040c0d0240101013101d0d0d0d0b0404001010101404001010140010501010116010101164001e201017500000000
000000000000003440404040000000000040404040e0f0f0e0f0f0f0e0e0e0e0e0e0e0e0e0e0e0d001718101d0d0d0d000000000000000000000000000000000
0000000000000082304040404040404040404040c0d02424014001d0d0d0b04040400140010140400101014001d1e1f101010106010140c2f2d2017500000000
000000000000000075757575000000000040404040e0f0f0e0f0f014e0f021f0f0f0f0f0f0f0e0d001718101d0d0d0d000000000000000000000000000000000
000000000000003040404040404040404040404040c0d0d0013101d0d0b040404040013101014040012401400102122201010101010140404040404030000000
000000000000000075757575000600000040404040e0f0f0e0f0f0e0e0f021f0f0f0f0f0f0f0e0d041414141d0d0d0d000000000000000000000000000000000
00000000000030404040404040404040404040404040c0d0013101d0b0404040404001310101404001400140013242520101d1e1f10140404040404040000000
000000000000003030303030303000000040404090e0f0f0e0f0f0f0e0f021f0f0f0f0a4f0f0e0d051515151d0d0d0d000000000000000000000000000000000
0000000034304040404040404040404040404040404040c0013101b0404040404040013101014040010101400101620101010212220140404040404040300000
0000000000000040404040404000000000404040d0e0f0f0e014f014e0f021f0f0f0f025f0f0e0d0d0d0d0d0d0d0d0d000000000000000000000000000000000
00000000344040404040404040404040404040404040404001310140404040404040013101014040010101400101620101013242520140404040404040403082
0000000000000040404040400000000000404040d0e0f0f0e0e0f0e0e0f021f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d000d300000000a3b3c300000000000000
00000000344040404040404040404040404040404040404001310140404040404040013101014040240124400101d1e1f1010162010140404040404040404030
0082009200303040404040400000000000404040d0e0e5f0e0f0f0f0e0f021f0f021f021f0f0f021f0f0f021f0e0d0d00000a3b3c30000000000a3b3c3000000
00000000000000404001010101c5010101c501010101404001310101010101010101013101544040400140400101021222010162010140000000110000404040
3030303030404040404040400000000000404040d0e0f0f0e0f014f0e0f021f0f0211621f0f0f021f016f021f0e0d0d000000000000000000000000000000000
00000000000000004001010101010101010101010101014001310101010101010101013101544040010101400101324252010162010140000000110000004040
4040404040404040404040400000000000404040d0e0f0f0e0f0e0f0e0f021f0f021f021f016f021f0f0f021f0e0d0d0000000000000a3b3c300000000000000
000000000000000000010101010101010101010101010101013101010101010101010131015440400124244001016262c2c2d262010140000000110000000000
4040404040404040404040400000000000404040d0e0f0f0e0f0f0f0e0f0f0f0f0f0f0f0f0f0f0f0f0f0f021f0e0d0d00000000000000000000000a3b3c30000
000000000000000000010101010101010101010101010101013101010101010101010101015440400140404001017272f2a2f272f50140000000110000000000
0000404040404040404040400000000000404040d0e0f0f0e01414f0e014141414141414141414141414f021f0e0d0d00000a3b3c30000000000000000000000
00000000000092820001010101010101010101010101010101310101010101010101010101544040010101404040404040404040404040000000110000000000
0000000116010101011601000000000000404040d0e0f0f0e0e0e0f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f021f0e0d0d00000000000000000a3b3c30000000000
00000000003030303040404040404040404040404040404040404040404040404040404040404040000000110000000011000000000011000000000000000000
0000000101010101010101000000000000404040d0e0f0f0e0f0f0f0e0f0f021f0f0f021f0f0f0f021f0f021f0e0d0d000000063730000000000000000637300
00000000004040404040404040404040404040404040404040404040404040404040404040404040000000110000000011000000000011000000000000000000
0000000101010101010101000000000000404040d0e0f0f0e0f0f0f0e0f0f021f016f021f0f016f02116f021f0e0d0d000006353837300000313000063538373
00000000004040404040404040404040404090d0d0d0d0d0d0d0d0d0d0d0d0d0a040404040404040000000110000000011000000000011000000000000000000
0000000101010101010101000000000000404040d0e0f0f0e014f014e0f0f021f0f0f021f0f0f0f021f0f021f0e0d0d000635353538373032333136353535383
0000000000404040404040404090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0a0404040404040000000110000000011000000000011000000000000000000
0000000101010101010101000000000000404040d0e0f0f0e0e0f0e0e0f0f021f0f0f021f0f0f0f0f0f0f021f0e0d0d063535353535393232323335353535353
000000000040404040404090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0a04040404040000000000000000011000000000000000000000000000000
0000820101010101010101000000000000404040d0e0f0f035f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0d0d053433353534323232323233353535353
3030303030404040404090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0a040404040000082820000000000000000000000000000000000000000
0000300101010126010101300000000000404040d0e0f0f035f0f0f0f0f0f0e014141414141414141414141414e0d0d043232333432323232323232333535353
40404040404040404090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0a0404040003030300000000000000000000000000000000000000000
0000403030303030303030400000000000404040d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d023232323232323232323232323335353
404040404040404090d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0a04040004040400000000000000000000000000000000000000000
0000404040404040404040400000000000404040d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d023232323232323232323232323233353
__gff__
0100000202020202020202020202020101040404080801010101020202020202020202020202010101010101010101010000000000000000000000000000020408080810101020202000000000000000020202020200020200080008000000000000000000000000000000000000000001010100000000000000010000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000063646566676800000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000073747576777800000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a6b6c6d6e6f00000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a7b7c7d7e7f00000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a000000000000000000000000000000
0000000000000000000000000000000000000000000000000000282800000029290000002828280000000000000000000000110011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d1e1f005a000000000000000000000000000000
00000000000000000000000000000000000000000f0f0e03030303030303030303030303030303030303000000000000000011001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202122005a000000000000000000000000000000
00000000000000000000000000000000000000000f0f0e040404040404040404040404040404040404040000000000001a1b1c001a1b1c0000005f0000001a1b1c0000005f0000001a1b1c00000000005f00000000001a1b1c00000000000000000000000000000000000000232425005a000000000000000000000000000000
00000000000000000000000000000000000000000f440e040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000282800002900005a0000007a29285a000000000000000000000000000000
00000000000000000000000000000000000000000f440e04040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040404040400303030303030303030303030303035a000000000000000000000000000000
00000000000000000000000000000000000000000f440e040404040404040404040404040404040404040029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000430303030303030304040404040404040404040404040400000000000000000000000000000000
00000000000000000000000000000000000000000f0f0e040404040404040404040404040404040404040303030000000000000000000000000000000000000000000000000000000000000000000000000000000040404040400404040404040404040404040404040404040404040400000000000000000000000000000000
00000000000000000000000000000000000000000e0e0e0e0e0e0e0e0e0e0404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000004303030303030404101013101613171918131010105710101010040400000000000000000000000000000000
00000000000000000000000000000000000e0f0f0f440e0f0f160f160f571013101719191810131010101010040000000000000000000000000000000000000000000000000000000000000000000000000000004304040404101057101013101613171918131010105710101010040400000000000000000000000000000000
00000000000000000000000000000000000e410f0f440e0f0f160f160f571013101719191810131010101010040000000000000000000000000000000000000000000000000000000000000000000000000000004304040404101057101013611613171918131060105710101010040400000000000000000000000000000000
00000000000000000000000000000000000e0e0f0f440e0f0f160f160f571013101719191810131010106010040000000000000000000000000000000000000000000000000000000000000000000000404040404004040404101004101010101610171918101010105710101010040400000000000000000000000000000000
00000000000000000000000000000000000e470f0f440e0f0f160f160f0e1013101719191810101010101010040029000000000000000000000000000000000000000000000000000000000000000043030303030304040404101004141414141414141414140404040404041010040400000000000000000000000000000000
00000000000000000000000000000000000e470e61440e0f415b415b410e1010101719191810100410101010040303000000000000000000000000000000000000000000000000000000000000000043040404040404040404101004151515151515151515150404040404041010040400000000000000000000000000000000
00000000000000000000000000000000000e47120f440e610e540e540e0e141414141414141414041d1e1f10101004000000000000000000000000000000000000000000000000000000000000404043040404040404040404101004040404040404040404040404040404041010040400000000000000000000000000000000
00000000000000000000000000000000000e47120f440e0f12161216120e0e0e0e0e0e0e0e0e0e042021221010100400000000000000000000000000000000000000000000000000000000004303030304040404040404090d10100d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d10100d0d00000000000000000000000000000000
00000000000000000000000000000003030e471241440e0f12161216120f0f0f0f0f560f0f0f0e0423242510101004030300000000000000000000000000000000000000000000000000000043040404040404040404090d0d10100d0d0d0d0d0d0d0d10101310101016101610100d0d00000000000000000000000000000000
00000000000000000000000000000004040e47120e0e0e0f0f160f160f0f0f0f0f0f560f0f0f0e04102610101010040404002800290000000000000000000000000000000000000000000043030404040404040404090d0d0d1010101010101010100d10101310101016101610100d0d00000000000000000000000000000000
00000000000000000000000000000004040e47120f0f0e1414141414140e0e0e0e0e0e0f0f0f0e041026101d1e1f0404040303030303030000000000000000000000000000000000000000430404040404040404090d0d0d0d1010101061101010100d101013101010164b1610100d0d00000000000000000000000000000000
00000000000000000000000000000004040e0f120f0f0e0e0e0e0e0e0e0e0f0f120f0e410f410e0410261020212204040404040404040400000000000000000000000000000000000000004304040404040404040c0d0d0d0d1010101010101010100d10101310101016501610100d0d00000000000000000000000000000000
00000000000000000000000000002904040e0f120f600f0f0f0f0f0f0f560f0f120f0e0e0f0e0e04102610232425105c1010105c1004040000000000000000000000000000000000000043030404040404040404040c0d0d0e0f0f0f0e0d101010100d101013100d0d540d540d0d0d0d00000000000000000000000000000000
00000000000000000000000000000304040e0f0f0f0f0f620f600f0f0f0e0f0f120f0e0f600f0e04102610102610101010101010100404000000000000000000000000000000000000430304040404040404040404040c0d0e0f600f0e0d421042100d101013100d0d540d540d0d0d0d00000000000000000000000000000000
00000000000000000000000000030404040e0e0e0e0e0e0e0e0e0e0e0e0e0f0f120f0e0f410f0e041d1e1f10261010101d1e1f1010040403280000000000000000000000000000004303040404040404040404040404040c0e0f600f0e0d041004100d10101310101016131610130d0d00000000000000000000000000000000
000000000000000000000000000404040404040d0d0d0d0d0d0d0d0d0d0e0f0f120f0e0f0e0f0e042021221026106110202122101010130403000000000000000000000000000043030404040404040404040404040404040e0f600f0e0d101010100d10101310101016131610130d0d00000000000000000000000000000000
__sfx__
00010000236702a670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003a07033070290702307018070110700907002070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002867030670286703067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002707022000240702200027070000002407000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003707036070330702d0702c070280702c07030070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e0000214722147221472214721d20223272212721f2721c272182021a272182021827218202152721820215202212021525200202000000000015232000000000000000000000000000000000000000000000
000e00001577000700157701570000700177700070017770007000070017770157701077017000157701570015700007001575000700007000070015730000000000000000000000000000000000000000000700
000e0000116550060511655116050060510655006050c65500605006050c655006050c655006050c655006050c605000020c6350060500605006050c615006000000000000000000000000000000000000000000
000400002207027070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700002407035070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001e07023170282002d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002727024270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000000c675006000c675006000c675006000c6750c675006000c675006000c675006000c675006000c6750c675006000c675006000c675006000c675006000c6750c675006050c675006050c675006050c675
001000000c4720c4721047210472134721347211472104720e4020e4720e4720e4720e47200402004020c47200402104720040213472004021147200402104720040213472104021147211472114721147200402
001000000c770007000c7700070010770007000e7700c770007000e7700e7700e7700e77000700007001077000700107700070010770007000e77000700107700070010770007000e7700e7700e7700070000700
001000000c6550c000000000000000000000000c65500000000000c67500000000000000000000000000c6750000000000000000c6750000000000000000c6750000000000000000c67500000000000c60500000
000800001c4721c472184021840218402184001840018400184001840018400184001840018400184001840018400184001c4721c472184021d4721d472184021f4721f472184022147221472184021c4721c472
000800001545000400104001045000400004000c45000400004001545000400004001045000400004000c45000400004001545000400004001045000400004000c45000400004001045000400004001445000400
000800001577000700007000070000700007000070000700007001c77000700007000070000700007000070000700007002177000700007000070000700007001077000700007000070000700007002077018700
000800001067500000000000000000000000000000000000000001067500000000000000000000000001060500000000001067500000000000000000000000001367500000000000000000000000001067500000
00080000180001800018000180001800018000180001800018000180001800018000180001800018000180001c4721c472180021a4721a472184021847218472184021a4721a472184021c4721c4721800218002
00080000004001045000400000000c45000400004001445000400004001045000400004000c45000400004001445000400004001045000400004000c450004000040010450004000040013450004000040010450
00080000007000070000700007000070000700007001c77000700007000070000700007000070000700007001477000700007001070000700007001c770007000070000700007000070013770007000070000700
000800000000500005000050000500005000050000510675000050000500005000051060510675000050000510675000050000500005000050000510675006050060500605006050060510675000050000500005
0008000018402184021840218402184021840218402184021840218402184021840218402184021c4721c472184021d4721d472184021f4721f472184022147221472184021e4721e47218402184021840218402
0008000000400004000c45000400004001345000400004001045000400004000c45000400004001345000400004001045000400004000c45000400004001045000400004001245000400004000e4500040000400
0008000000700007000070000700007001c77000700007000070000700007000070000700007001377000700007000070000700007001c7700070000700007000070000700127700c70000700007000070000700
000800000060500605006050060500605106750060500605006050060500605106750060500605106750060500605006050060500605106750060500605006050060500605106750060500605006050060500605
0008000018000180001800018000180001800018000180001800018000180000c0001547215472180001800018000180001a4721a472180001800018000180001d4721d472180001800018000180001800018000
000800000945015400004001245000400004000e45000400004000945000400004001245000400004000e45000400004000945000400004000e45000400004001145000400004000e45000400004000945000400
000800000000000000000000e77000000000000000000000000000000000000000001277000000000000000000000000000e77000000000000000000000000001177000000000000000000000000000000000000
000800000060000600006001767500600006000060000600006001767500600006001767500600006000060000600006001767500600006000060000600006001767500600006000060000600006000060000600
00080000004020040218402184021d4721d472184021c4721c472184021d4721d472184021f4721f472184021d4721d472184021c4721c472184021f4721f472184021840218402184021840218402184021d472
00080000004001145000400004000e45000400004000945000400004001145000400004000e45000400004000945000400004000e45000400004001045000400004000c450004000040007450004000040010450
00080000007000e77000700007000070000700007001170000700007001177000700007000e70000700007000e770007000070013700007000070013770007000070000700007000070000700007000070011770
000800000060510675006050060500605006050060510675006050060510675006050060500605006050060510675006050060500605006050060510675006050060500605006050060500605006050060510675
000800001d472180001800018000180001800018000180001c4721c472180001d4721d472180001c4721c472180001a4721a47218002184721847218000180001800018000180001800018000180001800018000
0008000000400004000c45000400004000745000400004001045000400004000c45000400004000745000400004000c45000400004000f45000400004000c45000400004000945000400004000f4500040000400
0008000000700007000070000700007000070000700007001077000700007001177000700007001077000700007000e77000700007000f7700070000700007000070000700007000070000700157700070000700
000800000060500605006050060500605106750060500605106750060500605006050060500605106750060500605006050060500605106750060500605006050060500605006050060500605106750060500605
000800000000000000000000000000000000001547215472000000000000000000000000000000000000000000000000001c4721c472000000000000000000000000000000000000000000000000000000000000
000800000c45000400004000945000400004000f45000400004000c45000400004000945000400004000c45000400004001045000400004000b45000400004000845000400004001045000400004000b45000400
000800000070000700007000070000700007000c77000700007000070000700007000977000700007000070000700007000877000700007000070000700007000070000700007000b77000700007000070000700
000800000060500605006051067500605006051067500605006050060500605006051067500605006050060500605006051067500605006050060500605006050060500605006051067500605006050060500605
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000004000845000400004001045000400004000b45000400004000845000400004000b45000400004000745000400004001045000400004000b45000400004000845000400004000b450004000040000400
00080000007000070000700007001077000700007000070000700007000b77000700007000070000700007000070000700007001077000700007000070000700007000b770007000070000700007000070000700
000800000060510675006050060510675006050060500605006050060510675000050000500005000050060510675006050060510675006050060500605006050060510675006050060500605006050060500605
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 05 06 07 44
03 0c 42 43 44
03 0d 0e 0f 44
01 10 11 12 13
00 14 15 16 17
00 18 19 1a 1b
00 1c 1d 1e 1f
00 20 21 22 23
00 24 25 26 27
00 28 29 2a 2b
02 2c 2d 2e 2f
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
