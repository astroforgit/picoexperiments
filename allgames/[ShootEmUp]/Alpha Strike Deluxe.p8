pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- alpha strike deluxe
-- by adrian makes games

function _init()
declare_aliases()
declare_variables()
play_music(8)
end

function _update60()
if state == state_menu then
update_stars()
make_starfield()
update_menu()
end
if state == state_ending then
update_stars()
make_starfield()
update_explosions()
update_trails()
end
if state == state_credits then
update_stars()
make_starfield()
end
if state == state_gover then
update_stars()
make_starfield()
update_gover()
end
if state == state_game then
update_players()
update_bullets()
update_stars()
make_starfield()
update_enemies()
scroll_level()
check_collision()
update_explosions()
update_powerups()
fix_score()
update_trails()
update_babsorbs()
end
end

function _draw()
if state == state_menu then
clear_screen()
draw_stars()
draw_menu()
end
if state == state_ending then
clear_screen()
draw_stars()
draw_ending()
draw_explosions()
draw_trails()
end
if state == state_credits then
clear_screen()
draw_stars()
draw_credits()
end
if state == state_gover then
clear_screen()
draw_stars()
draw_gover()
end
if state == state_game then
clear_screen()
draw_stars()
draw_level()
draw_players()
draw_bullets()
draw_enemies()
draw_trails()
draw_explosions()
draw_powerups()
draw_gui()
draw_stagetext()
end
end

-- init stuff
function declare_aliases()
l = 0
r = 1
u = 2
d = 3
o = 4
x = 5
state_menu = 0
state_game = 1
state_ending = 2
state_credits = 3
state_gover = 4
end

function declare_variables()
buttonsheld={}
player = {}
bullet = {}
enemy = {}
star = {}
powerup = {}
explosion = {}
babsorb = {}
trails = {}
score100000 = 0
score10000 = 0
score1000 = 0
score100 = 0
score10 = 0
score1 = 0
scoretoaddp1 = 0
scoretoaddp2 = 0
lives = 3
level = 1
pos = 0
scroll = 0
scrolly = 0
loopx = 0
loopy = 0
stagetext = 0
sht = 0
shx = 0
shy = 0
state = state_menu
menusel = 0
endshipx = 0
endtime = 0
cry = 0
cont = 2
govertime = 0
players = 0
menuwait = 0
cheatcode = 0
fullpower = 0
invinciblity = 0
livesatstart = 3
end

-- update stuff
function make_player(x, y, l, s, pl)
local p = {}
p.x = x
p.y = y
p.ml = 0
p.pl = pl or 0
p.ps = 0
p.inv = 100
p.lifes = livesatstart
p.score100000 = 0
p.score10000 = 0
p.score1000 = 0
p.score100 = 0
p.score10 = 0
p.score1 = 0
add(player, p)
return p
end

function update_players()
for p in all(player) do
update_player(p)
end
end

function update_player(self)
make_trail(self.x+4,self.y+8, 10, 9, d, 1.5)
if fullpower == 1 then
self.ps = 2
end
if invinciblity == 1 then
self.lifes = 3
end
if self.inv > 0 then
self.inv -= 1
end
if self.ml > 2 then
if (btn(l, self.pl)) self.x -= 4
if (btn(r, self.pl)) self.x += 4
if (btn(u, self.pl)) self.y -= 4
if (btn(d, self.pl)) self.y += 4
self.ml = 0
end
if (btnp(x, self.pl)) then
sfx(0)
if (self.ps == 0) make_bullet(self.x, self.y, 0, 0, 0, 1, self.pl)
if (self.ps == 1) then
make_bullet(self.x, self.y, 0, 1, -1, 1, self.pl)
make_bullet(self.x, self.y, 0, 1, 1, 1, self.pl)
end
if (self.ps == 2) then
make_bullet(self.x, self.y, 0, 1, -1, 1, self.pl)
make_bullet(self.x, self.y, 0, 0, 0, 1, self.pl)
make_bullet(self.x, self.y, 0, 1, 1, 1, self.pl)
end
if (self.ps >= 2) then
self.ps = 2
end
end
if (self.x < 0) self.x = 0
if (self.x > 120) self.x = 120
if (self.y < 0) self.y = 0
if (self.y > 120) self.y = 120
self.ml += 1
end

function make_bullet(x, y, w, sp, sd, spd, pl)
local b = {}
b.x = x
b.y = y
b.ml = 0
b.w = w
b.sp = sp
b.sd = sd
b.sl = 0
b.spd = spd
b.t = 0
b.pl = pl or 0
add(bullet, b)
return b
end

function update_bullets()
for b in all(bullet) do
update_bullet(b)
end
end

function update_bullet(self)
if self.ml > self.spd then
self.ml = 0
if self.sp == 1 then
if self.sl > 2 then
self.x += self.sd*2
self.sl = 0
end
end
if self.w == 0 then
self.y -= 4
make_trail(self.x+4, self.y, 12, 1, d, 0.5, 15)
end
if (self.w ~= 0 and self.w ~= 3) then
self.y += 4
if self.w ~= 2 then
make_trail(self.x+4, self.y, 8, 2, d, 0.5, 15)
else
make_trail(self.x+4, self.y, 12, 13, d, 0.5, 15)
end
end
if self.w == 3 then
make_trail(self.x+4, self.y, 11, 3, -1, 0.5, 15)
if (self.x < shx) self.x += 4
if (self.x > shx) self.x -= 4
if (self.y < shy) self.y += 4
if (self.y > shy) self.y -= 4
for ba in all(babsorb) do
if (check_collisions(self, ba, 4)) then
del(babsorb, ba)
del(bullet, self)
end
end
end
end
self.ml += 1
self.sl += 1
if self.y < 0 then
del(bullet, self)
end
if self.y > 128 then
del(bullet, self)
end
end

function make_star()
local s = {}
s.x = rnd(128)
s.y = 0
s.s = -flr(-rnd(3))
s.c = flr(rnd(3))+5
add(star, s)
return s
end

function update_stars()
for s in all(star) do
update_star(s)
end
end

function update_star(self)
self.y += self.s/2
if self.y > 128 then
del(star, self)
end
end

function make_trail(x, y, c, lc, d, spd, dt)
local s = {}
s.x = x or 0
s.y = y or 0
s.c = c or 0
s.lc = lc or 0
s.t = 0
s.dt = dt or 50
s.d = d or 0
s.spd = spd or 1
add(trails, s)
return s
end

function update_trails()
for s in all(trails) do
update_trail(s)
end
end

function update_trail(self)
if self.d == -1 then
self.x -= (rnd(2)-1)*self.spd
self.y += (rnd(2)-1)*self.spd
end
if self.d == l then
self.x -= 0.5 * self.spd
self.y += (rnd(2)-1)*self.spd
end
if self.d == r then
self.x += 0.5 * self.spd
self.y += (rnd(2)-1)*self.spd
end
if self.d == u then
self.y -= 0.5 * self.spd
self.x += (rnd(2)-1)*self.spd
end
if self.d == d then
self.y += 0.5 * self.spd
self.x += (rnd(2)-1)*self.spd
end
self.t += 1
if self.t > self.dt then
del(trails, self)
end
end

function make_babsorb(x,y)
local s = {}
for p in all(player) do
s.x = p.x+4
s.y = p.y+4
s.t = 0
add(babsorb, s)
end
return s
end

function update_babsorbs()
for s in all(babsorbs) do
self.t += 1
if self.t > 600 then
del(babsorb, self)
end
end
end

function make_starfield()
if flr(rnd(1)) == 0 then
make_star()
end
end

function make_enemy(x, y, l, t, nd)
local e = {}
e.x = x
e.y = y
e.ml = 0
e.l = l
e.t = t
-- haruhiro stuff
e.tn = 0
e.nd = nd
e.nm = 6
e.m = 0
-- hideki stuff
e.rand = 0
-- shukishi stuff
e.d = 0
-- no stuff for sanzo
-- boss t-yoritoki stuff
e.bd = 0
e.ws = 0
add(enemy, e)
return e
end

function update_enemies()
for e in all(enemy) do
update_enemy(e)
end
end

function update_enemy(self)
-- haruhiro enemy
if self.t == 0 then
if self.ml > 2 then
if self.m == 0 then
self.y += 4
self.tn += 1
if self.tn > 5 then
self.m = 1
self.tn = 0
end
end
if self.m == 1 then
self.x += self.nd*4
self.y -= 4
self.tn += 1
if self.tn > 2 then
self.m = 0
self.tn = 0
end
end
self.ml = 0
end
self.ml += 1
if self.y > 128 then del(enemy, self) end
end
-- hideki enemy
if self.t == 1 then
if self.ml > 2 then
self.rand = flr(rnd(33))
if (self.rand == 0) self.x -= 4
if (self.rand == 1) self.x += 4
if (self.rand == 2) self.y -= 4
if (self.rand == 3) self.y += 4
if (self.rand == 4) self.x -= 4
if (self.rand == 5) self.x += 4
if (self.rand == 6) self.y -= 4
if (self.rand == 7) self.y += 4
if (self.rand == 8) self.x -= 4
if (self.rand == 9) self.x += 4
if (self.rand == 10) self.y -= 4
if (self.rand == 11) self.y += 4
if (self.rand == 12) self.x -= 4
if (self.rand == 13) self.x += 4
if (self.rand == 14) self.y -= 4
if (self.rand == 15) self.y += 4
if (self.rand == 16) self.x -= 4
if (self.rand == 17) self.x += 4
if (self.rand == 18) self.y -= 4
if (self.rand == 19) self.y += 4
if (self.rand == 20) self.x -= 4
if (self.rand == 21) self.x += 4
if (self.rand == 22) self.y -= 4
if (self.rand == 23) self.y += 4
if (self.rand == 24) self.x -= 4
if (self.rand == 25) self.x += 4
if (self.rand == 26) self.y -= 4
if (self.rand == 27) self.y += 4
if (self.rand == 28) self.x -= 4
if (self.rand == 29) self.x += 4
if (self.rand == 30) self.y -= 4
if (self.rand == 31) self.y += 4
if (self.rand == 32) make_bullet(self.x, self.y, 1, 5, 1, 1)
self.ml = 0
end
self.ml += 1
if (self.x < 0) self.x = 0
if (self.x > 120) self.x = 120
if (self.y < 0) self.y = 0
if (self.y > 120) self.y = 120
end
-- shukishi enemy
if self.t == 2 then
if self.ml > 1 then
self.ml = 0
if self.d == 0 then
self.x -= 4
self.tn += 1
end
if self.d == 1 then
self.x += 4
self.tn += 1
end
if self.tn > 5 then
self.y += 4
self.tn = 0
end
end
self.ml += 1
if self.x < 0 then self.d = 1 end
if self.x > 120 then self.d = 0 end
if self.y > 128 then del(enemy, self) end
end
-- sanzo enemy
if self.t == 3 then
if self.ml > 1 then
self.y += 4
self.ml = 0
end
if self.y > 120 then del(enemy, self) end
self.ml += 1
end
-- t-yoritoki - boss
if self.t == 4 then
if self.ml > 2 then
if self.d == 0 then
self.x -= 4
self.tn += 1
end
if self.d == 1 then
self.x += 4
self.tn += 1
end
self.ml = 0
end
self.ws += 0.5
if self.ws >= 33 then
make_bullet(self.x, self.y, 2, 2, 0, 1,1)
make_bullet(self.x, self.y+8, 2, 0, 1,1)
make_bullet(self.x, self.y+16, 2, 0, 1,1)
make_bullet(self.x, self.y+24, 2, 0, 1,1)
make_bullet(self.x, self.y+32, 2, 0, 1,1)
make_bullet(self.x, self.y, 1, 1, -0.5,1)
make_bullet(self.x, self.y, 1, 1, 0.5,1)
make_bullet(self.x, self.y, 1, 1, -1,1)
make_bullet(self.x, self.y, 1, 1, 1,1)
self.ws = 0
end
if self.l <= 0 then
sfx(3)
make_explosion(self.x, self.y, 64)
del(enemy, self)
level += 1
pos = 0
stagetext = 0
scoretoaddp1 += 5000
scoretoaddp2 += 5000
end
if self.x < 0 then self.d = 1 end
if self.x > 120 then self.d = 0 end
self.ml += 1
end
if self.l <= 0 then
sfx(3)
make_explosion(self.x, self.y, 16)
del(enemy, self)
end
end

function make_formation(f, x)
-- haruhiro left
x = x*8
if f == 0 then
make_enemy(x, 8, 1, 0, -1)
make_enemy(x, 0, 1, 0, -1)
make_enemy(x, -8, 1, 0, -1)
make_enemy(x, -16, 1, 0, -1)
make_enemy(x, -24, 1, 0, -1)
make_enemy(x, -32, 1, 0, -1)
make_enemy(x, -40, 1, 0, -1)
end
-- haruhiro right
if f == 1 then
make_enemy(x, 8, 1, 0, 1)
make_enemy(x, 0, 1, 0, 1)
make_enemy(x, -8, 1, 0, 1)
make_enemy(x, -16, 1, 0, 1)
make_enemy(x, -24, 1, 0, 1)
make_enemy(x, -32, 1, 0, 1)
make_enemy(x, -40, 1, 0, 1)
end
-- hideki 3
if f == 2 then
make_enemy(x, 8, 1, 1, 1)
make_enemy(x+1, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
end
-- hideki 5
if f == 3 then
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, -1, 1, 1)
make_enemy(x, 8, -1, 1, 1)
end
-- hideki 10
if f == 4 then
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, -1, 1, 1)
make_enemy(x, 8, -1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, 1, 1, 1)
make_enemy(x, 8, -1, 1, 1)
make_enemy(x, 8, -1, 1, 1)
end
-- shukishi
if f == 5 then
make_enemy(x, 0, 8, 2, 1)
make_enemy(x+8, 0, 1, 2, 1)
make_enemy(x+16, 0, 1, 2, 1)
end
-- sanzo
if f == 6 then
make_enemy(x, 8, 1, 3, 1)
make_enemy(x-8, 0, 1, 3, 1)
make_enemy(x+16, -16, 1, 3, 1)
end
-- boss
if f == 7 then
make_enemy(64, 24, 50, 4, 1)
end
end

function scroll_level()
scroll += 0.5
if scroll >= 8 then
scrolly += 1
scroll = 0
end
if scrolly > 8 then
pos += 1
scrolly = 0
end
for loopx = level*16, level*16+15, 1 do
for loopy = 64-pos, 64-pos+16, 1 do
if (mget(loopx, loopy) == 32) then
make_formation(0,loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 33) then
make_formation(1,loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 34) then
make_formation(2,loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 35) then
make_formation(3,loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 36) then
make_formation(4,loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 37) then
make_formation(5, loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 38) then
make_formation(6, loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 39) then
make_powerup(loopx - level*16, 0) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 40) then
make_formation(7, loopx - level*16) 
mset(loopx, loopy, 0)
end
if (mget(loopx, loopy) == 14) then
sht += 1
if sht > 50 then
for p in all(player) do
shx = p.x+4
shy = p.y+4
end
for b in all(bullet) do
if b.w == 3 then
del(bullet, b)
end
end
make_bullet((loopx - level*16)*8, (loopy-64+pos)*8, 3, 0, 0, 1)
make_babsorb((loopx - level*16)*8, (loopy-64+pos)*8, 3, 0, 0, 1)
sht = 0
end
end
if (mget(loopx, loopy) == 15) then
sht += 1
if sht > 50 then
for p in all(player) do
shx = p.x+4
shy = p.y+4
end
for b in all(bullet) do
if b.w == 3 then
del(bullet, b)
end
end
make_bullet((loopx - level*16)*8, (loopy-64+pos)*8, 3, 0, 0, 1)
make_babsorb((loopx - level*16)*8, (loopy-64+pos)*8, 3, 0, 0, 1)
sht = 0
end
end
end
end
end

function check_collision()
for pl in all(player) do
for e in all(enemy) do
if (check_collisions(pl,e,8)) then
if pl.inv < 1 then
if pl.lifes <= 0 then
sfx(3)
del(player, pl)
end
if pl.lifes > 0 then
pl.ps = 0
pl.x = 8*8
pl.y = 14*8
pl.inv = 100
pl.lifes-=1
sfx(3)
make_explosion(e.x, e.y,24)
end
end
end
end
end
for pl in all(player) do
for b in all(bullet) do
if (check_collisions(pl,b,8)) then
if (b.w ~= 0) then
if pl.lifes <= 0 then
if pl.inv < 1 then
sfx(3)
del(player, pl)
del(bullet, b)
end
end
if pl.lifes > 0 then
if pl.inv < 1 then
pl.ps = 0
pl.inv = 100
pl.x = 8*8
pl.y = 14*8
pl.lifes-=1
sfx(3)
make_explosion(b.x, b.y,24)
end
end
end
end
end
end
for pl in all(player) do
for pu in all(powerup) do
if (check_collisions(pl,pu,8)) then
pl.ps += 1
sfx(2)
if pl.pl == 0 then
scoretoaddp1 += 250
else
scoretoaddp2 += 250
end
del(powerup, pu)
end
end
end
for b in all(bullet) do
for e in all(enemy) do
if (check_collisions(b,e,8)) then
if (b.w == 0) then
e.l -= 1
sfx(1)
del(bullet, b)
make_explosion(b.x, b.y,8)
if b.pl == 0 then
scoretoaddp1 += 50
else
scoretoaddp2 += 50
end
end
end
end
end
end

function make_explosion(x, y, s)
local e = {}
e.x = x
e.y = y
e.t = 0
e.s = s or 0
add(explosion, e)
return e
end

function update_explosions()
for e in all(explosion) do
update_explosion(e)
end
end

function update_explosion(self)
self.t += 4
if self.t > self.s then
del(explosion, self)
end
end

function make_powerup(x, y)
local pu = {}
pu.x = x*8
pu.y = y
pu.ml = 0
add(powerup, pu)
return pu
end

function update_powerups()
for pu in all(powerup) do
update_powerup(pu)
end
end

function update_powerup(self)
if self.ml > 1 then
self.y += 4
self.ml = 0
end
self.ml += 1
if self.y > 128 then
del(powerup, self)
end
end

function fix_score()
for p in all(player) do
if scoretoaddp1 > 0 then
if p.pl == 0 then
p.score1 += 10
scoretoaddp1 -= 10
end
end
if scoretoaddp2 > 0 then
if p.pl == 1 then
p.score1 += 10
scoretoaddp2 -= 10
end
end
if p.score1 >= 10 then
p.score10 += 1
p.score1 -= 10
end
if p.score10 >= 10 then
p.score100 += 1
p.score10 -= 10
end
if p.score100 >= 10 then
p.score1000 += 1
p.score100 -= 10
end
if p.score1000 >= 10 then
p.score10000 += 1
p.score1000 -= 10
p.lifes += 1
sfx(31)
end
if p.score10000 >= 10 then
p.score100000 += 1
p.score10000 -= 10
end
end
end

function update_menu()

if (btnp(u)) cheatcode = cheatcode * 8 + 1 -- u
if (btnp(d)) cheatcode = cheatcode * 8 + 2 -- d
if (btnp(l)) cheatcode = cheatcode * 8 + 3 -- l
if (btnp(r)) cheatcode = cheatcode * 8 + 4 -- r
if (btnp(o)) cheatcode = 0

if (cheatcode == 786) then
  cheatcode = 0
  invinciblity = 1
  sfx(2)
elseif (cheatcode == 660) then
  cheatcode = 0
  fullpower = 1
  sfx(2)
elseif (cheatcode == 12948) then
  cheatcode = 0
  livesatstart = 10
  sfx(2)
elseif (cheatcode == 2329) then
  cheatcode = 0
  cont = 99
  sfx(2)
elseif (cheatcode == 89) then
  cheatcode = 0
  level = 2
  sfx(2)
elseif (cheatcode == 91) then
  cheatcode = 0
  level = 3
  sfx(2)
elseif (cheatcode == 90) then
  cheatcode = 0
  level = 4
  sfx(2)
elseif (cheatcode == 92) then
  cheatcode = 0
  level = 5
  sfx(2)
end

menuwait += 1
if btnp(u) then menusel = 0
sfx(4)
end
if btnp(d) then menusel = 1
sfx(4)
end
if menuwait > 20 then
if btnp(x) then
if menusel == 0 then
make_player(8*8, 14*8, 3, 0, 0)
state = state_game
end
if menusel == 1 then
make_player(7*8, 14*8, 3, 0, 0)
make_player(9*8, 14*8, 3, 0, 1)
state = state_game
end
end
end
end

function update_gover()
govertime += 1
if govertime > 150 then
if btnp(u) then menusel = 0
sfx(4)
end
if btnp(d) then menusel = 1
sfx(4)
end
if btnp(x) then
if menusel == 0 then
if cont > 0 then
cont -= 1
if players == 0 then
make_player(8, 14, 3, 0, 0)
end
if players == 1 then
make_player(8, 14, 3, 0, 0)
make_player(8, 14, 3, 0, 1)
end
pos = 0
enemy = {}
bullet = {}
powerup = {}
for p in all(player) do
p.ps = 0
p.x = 8*8
p.y = 14*8
end
menusel = 0
govertime = 0
score100000 = 0
score10000 = 0
score1000 = 0
score100 = 0
score10 = 0
score1 = 0
scoretoaddp1 = 0
scoretoaddp2 = 0
stagetext = 0
livesatstart = 3
reload(0x1000, 0x1000, 0x2000)
state = state_game
end
end
if menusel == 1 then
reload(0x1000, 0x1000, 0x2000)
play_music(8)
declare_variables()
end
end
end
end

-- draw stuff
function clear_screen()
rectfill(0, 0, 128, 128, 0)
end

function draw_stars()
for s in all(star) do
draw_star(s)
end
end

function draw_star(self)
pset(self.x, self.y, self.c)
end

function draw_trails()
for s in all(trails) do
draw_trail(s)
end
end

function draw_trail(self)
if self.t < self.dt/2 then
pset(self.x, self.y, self.c)
else
pset(self.x, self.y, self.lc)
end
end

function draw_players()
for p in all(player) do
draw_player(p)
end
end

function draw_player(self)
if self.pl >= 0 then
spr(1, self.x, self.y)
end
if self.pl == 1 then
spr(19, self.x, self.y)
end
spr(2, self.x, self.y+8)
palt(0, false)
if (self.inv > 0 and self.inv < 10) then
spr(20, self.x, self.y)
end
if (self.inv > 30 and self.inv < 40) then
spr(20, self.x, self.y)
end
if (self.inv > 60 and self.inv < 70) then
spr(20, self.x, self.y)
end
if (self.inv > 90 and self.inv < 100) then
spr(20, self.x * 8, self.y * 8)
end
palt(0, true)
end

function draw_bullets()
for b in all(bullet) do
draw_bullet(b)
end
end

function draw_bullet(self)
if self.w == 0 then
spr(3, self.x, self.y)
end
if self.w == 1 then
spr(6, self.x, self.y)
end
if self.w == 2 then
spr(17, self.x, self.y)
end
if self.w == 3 then
spr(16, self.x, self.y)
end
end

function draw_enemies()
for e in all(enemy) do
draw_enemy(e)
end
end

function draw_enemy(self)
if (self.t == 0) spr(4, self.x, self.y)
if (self.t == 1) spr(5, self.x, self.y)
if (self.t == 2) then
 if (self.d == 0) spr(8, self.x, self.y)
 if (self.d == 1) spr(7, self.x, self.y)
end
if (self.t == 3) spr(9, self.x, self.y)
if (self.t == 4) then
spr(50, (self.x-8), (self.y-8) )
spr(51, (self.x), (self.y-8) )
spr(52, (self.x+8), (self.y-8) )
spr(53, (self.x+8), (self.y) )
spr(54, (self.x+8), (self.y+8) )
spr(55, (self.x), (self.y+8) )
spr(56, (self.x-8), (self.y+8) )
spr(57, (self.x-8), (self.y) )
spr(58, (self.x), (self.y) )
end
end

function draw_level()
map(16 * level, 64 - pos, 0, -8+scrolly, 16, 17)
end

function draw_explosions()
for e in all(explosion) do
draw_explosion(e)
end
end

function draw_explosion(self)
circfill(self.x, self.y, self.t+8, 8)
circfill(self.x, self.y, self.t+4, 9)
circfill(self.x, self.y, self.t, 10)
end

function draw_powerups()
for pu in all(powerup) do
draw_powerup(pu)
end
end

function draw_powerup(self)
spr(18, self.x, self.y)
end

function draw_gui()
for p in all(player) do
if p.pl == 1 then
pal(8,12)
pal(2,13)
end
for i = 0, p.lifes-1, 1 do
spr(48, 4 + i * 8, 8 + p.pl * 24) 
end
end
pal()
if #player == 0 then state = state_gover
music(18)
end
for p in all(player) do
if p.pl == 0 then
print(p.score100000..p.score10000..p.score1000..p.score100..p.score10..p.score1, 6, 19+p.pl*24, 2)
print(p.score100000..p.score10000..p.score1000..p.score100..p.score10..p.score1, 5, 18+p.pl*24, 8)
else
print(p.score100000..p.score10000..p.score1000..p.score100..p.score10..p.score1, 6, 19+p.pl*24, 1)
print(p.score100000..p.score10000..p.score1000..p.score100..p.score10..p.score1, 5, 18+p.pl*24, 12)
end
end
end

function draw_stagetext()
if stagetext < 50 then
print("stage "..level, 49, 65, 1)
print("stage "..level, 48, 64, 12)
end
if level == 5 then
if stagetext <= 1 then
play_music(0)
end
end
if level == 4 then
if stagetext <= 1 then
play_music(9)
end
end
if level == 3 then
if stagetext <= 1 then
play_music(14)
end
end
if level == 2 then
if stagetext <= 1 then
play_music(25)
end
end
if level == 1 then
if stagetext <= 1 then
play_music(19)
end
end
if level >= 6 then
music(-1)
state = state_ending
end
stagetext += 1
end

function draw_menu()
map(0, 0, 0, 0, 16, 16)
print("1 player",51, 95, 2)
print("1 player",50, 94, 8)
print("2 players",51, 105, 2)
print("2 players",50, 104, 8)
print("(cc) 2019 by adrian makes games",5, 121, 2)
print("(cc) 2019 by adrian makes games",4, 120, 8)
if menusel == 0 then
spr(126, 40, 94)
end
if menusel == 1 then
spr(126, 40, 104)
end
end

function draw_ending()
endshipx += 1
endtime += 1
if endtime < 100 then
make_trail(endshipx, 68, 10, 9, l, 1)
spr(23, endshipx, 64)
spr(21, endshipx-8, 64)
map(0, 16, 0, 0, 16, 16)
end
if endtime > 100 then
trails = {}
map(0, 32, 0, 0, 16, 16)
end
if endtime == 120 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,24)
sfx(3)
end
if endtime == 130 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,24)
sfx(3)
end
if endtime == 140 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,24)
sfx(3)
end
if endtime == 150 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,24)
sfx(3)
end
if endtime == 160 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,24)
sfx(3)
end
if endtime == 170 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,24)
sfx(3)
end
if endtime == 180 then
make_explosion((flr(rnd(10))+2)*8, (flr(rnd(10)+4))*8,64)
sfx(3)
end
if endtime > 180 then
palt(0, false)
spr(22, 2*8, 7*8)
spr(22, 5*8, 11*8)
spr(22, 10*8, 9*8)
spr(22, 10*8, 5*8)
spr(22, 5*8, 3*8)
spr(22, 6*8, 7*8)
palt(0, true)
end
if endtime > 230 then
print("the end", 49, 60, 5)
print("the end", 48, 59, 7)
end
if endtime > 300 then
state = state_credits
play_music(30)
end
end

function draw_credits()
cry -= 0.5
draw_credit(cry)
if cry < -1442 then
cry = -1442
end
end

function draw_credit(y)
print("staff", 53, y+164, 2)
print("staff", 52, y+163, 8)
print("programmer", 43, y+304, 2)
print("programmer", 42, y+303, 8)
print("@adrian09_01", 39, y+314, 1)
print("@adrian09_01", 38, y+313, 12)
print("graphics designer", 28, y+344, 2)
print("graphics designer", 27, y+343, 8)
print("@adrian09_01", 39, y+354, 1)
print("@adrian09_01", 38, y+353, 12)
print("level designer", 35, y+384, 2)
print("level designer", 34, y+383, 8)
print("@adrian09_01", 39, y+394, 1)
print("@adrian09_01", 38, y+393, 12)
print("object designer", 35, y+424, 2)
print("object designer", 34, y+423, 8)
print("@adrian09_01", 39, y+434, 1)
print("@adrian09_01", 38, y+433, 12)
print("engine designer", 35, y+464, 2)
print("engine designer", 34, y+463, 8)
print("@adrian09_01", 39, y+474, 1)
print("@adrian09_01", 38, y+473, 12)
print("music composer", 35, y+504, 2)
print("music composer", 34, y+503, 8)
print("@gruber_music", 39, y+514, 1)
print("@gruber_music", 38, y+513, 12)
print("@adrian09_01", 35, y+524, 1)
print("@adrian09_01", 34, y+523, 12)
print("@synth_dfr", 35, y+534, 1)
print("@synth_dfr", 34, y+533, 12)
print("@viggles", 39, y+544, 1)
print("@viggles", 38, y+543, 12)
print("@robby_duguay", 39, y+554, 1)
print("@robby_duguay", 38, y+553, 12)
print("special thanks", 35, y+584, 2)
print("special thanks", 34, y+583, 8)
print("tecmo", 55, y+594, 1)
print("tecmo", 54, y+593, 12)
print("hudson soft", 41, y+604, 1)
print("hudson soft", 40, y+603, 12)
print("konami", 53, y+614, 1)
print("konami", 52, y+613, 12)
print("cast", 53, y+744, 2)
print("cast", 52, y+743, 8)
spr(4, 53, y+864)
print("haruhiro", 43, y+874, 3)
print("haruhiro", 42, y+873, 11)
spr(5, 53, y+984)
print("hideki", 47, y+994, 9)
print("hideki", 46, y+993, 10)
spr(7, 53, y+1104)
print("shukishi", 43, y+1114, 5)
print("shukishi", 42, y+1113, 7)
spr(9, 53, y+1224)
print("sanzo", 49, y+1234, 2)
print("sanzo", 48, y+1233, 8)
spr(58, 53, y+1344)
print("t-yoritoki", 41, y+1354, 4)
print("t-yoritoki", 40, y+1353, 9)
print("thanks for playing", 29, y+1504, 2)
print("thanks for playing", 28, y+1503, 8)
print("(cc) 2019 adrian makes games", 5, y+1514, 1)
print("(cc) 2019 adrian makes games", 4, y+1513, 12)
end

function draw_gover()
print("game over", 43, 35, 2)
print("game over", 42, 34, 8)
if govertime > 150 then
print("continue "..cont, 43, 55, 2)
print("continue "..cont, 42, 54, 8)
print("end ", 43, 65, 2)
print("end ", 42, 64, 8)
if menusel == 0 then
spr(126, 32, 54)
end
if menusel == 1 then
spr(126, 32, 64)
end
end
end

-- universal function
function play_music(mus)
music(mus)
end

function btn1(i,p)

local res = 0
for bi=0,15 do
  if (buttonsheld[bi] == 1) then
    res = bor(res, shl(1,bi))
  end
end

if ((i) and (p)) then
  return (band(shr(res,p*8+i),1) > 0)
elseif (i) then
  return (band(shr(res,i),1) > 0)
else
  return res
end -- if i and p

end
-->8
function round(num, numdecimalplaces)
  local mult = 10^(numdecimalplaces or 0)
  return flr(num * mult + 0.5) / mult
end

function ab_distance(ax, ay, bx, by)
return sqrt((bx-ax)^2+(by-ay)^2)
end

function check_collisions(a, b, hitboxsize)
if ab_distance(a.x,a.y,b.x,b.y) < hitboxsize then
if ab_distance(a.x,a.y,b.x,b.y) >= 0 then
return true
else
return false
end
else
return false
end
end
__gfx__
0000000000066000000000000000c000000000000000000000008000560000000000006590000009004444444444444444444000333333334444444433333333
000000000068260000000000000c7c00000bb0000909909000087800576600000000667599666699044224444224444444444400333333334226664433366633
000000000068260000000000000c7c0000a33a0000988900000878005757660000667575999769994444444444444444422444403b3b3333446111543b611153
0007000006776650000000000000c0000b300130098772400000800057558866668855754448244442244444444422444444444433b333334461115433611153
000000000657615000000000000000000b3001300987724000000000561122666622116500682500444444444444444444444444333333334461115433611153
000000006757616500000000000000000091190000922400000000005616550000556165006765004444224444444444444442243333b3b344466544333665b3
0000000065776615000000000000000000033000090440400000000056550000000055650065150044444444422444444224444433333b334224544433335b33
00000000655555550000000000000000000000000000000000000000550000000000005500055000422444444444444444444444333333334446454433363533
0000b0001dc77cd100cccc0000066000000000000000000000000000666000000000000000000000444444447777777744444444777777777777777700000000
000b7b001dc77cd10cddddc0006cd600000000000000000000000000557660000000000000000000044444447666666142244440766666666666666100000000
000b7b001dc77cd1cdd77dd1006cd6000000000000000000000000005755766000000000000000000422444476dddd514444440076dddddddddddd5100000000
0000b0001dc77cd1cdd7d7d1067766500000000000000000000000005777788600000000000000004444444476dddd514442244076d5dddddddd5d5100000000
000000001dc77cd1cdd77dd1065761500000000000000000000000005666622600000000000000000444224476dddd514444444476d5dddddddd5d5100000000
000000001dc77cd1cdd7ddd1675761650000000000000000000000005611666000000000000000000044444476dddd514224444476dddddddddddd5100000000
000000001dc77cd10cdddd1065776615000000000000000000000000516550000000000000000000042244447555555144444440765555555555555100000000
000000001dc77cd10011110065555555000000000000000000000000555000000000000000000000444444447111111144444444711111111111111100000000
000bb000000bb000090990900909909009099090660000009000000900cccc008808808800000000444444444444444444444444777777777777777777777777
00a33a0000a33a0000988900009889000c9ccc006766cc009966cc990cddddc00888888000000000442224444224444442244444766666617666666666666651
0b3003b00b3003b0098ccc90098ccc900c8c7c90675c6600999c89991dd888dc88aaaa880000000044444444444444444444444476dddd5176dddddddddddd51
0b3003b00b3003b009877c90098c78900c8c7c90675c8866999c89991dd8d7dc8aa77aa80000000044444444444422444444224476d55d5176d5dddddddd5d51
00a33a0000a33a00009ccc00009ccc000c9c8c006755cc660068cc001dd888dc8aa77a880000000044442244444444444224444476dddd5176dddddddddddd51
008bb000000bb80009099c9009099c900c0ccc9067576c0000677c001dd7d8dc08a77a800000000014444444244444424444444276dddd5176dddddddddddd51
0888888008888880000ccc00000ccc0000000000676cc000006cc60001d888c088aaaa880000000021212212214221222121241276dddd5176dddddddddddd51
0080000000000800000000000000000000000000660000000006600000111100808880880000000002121121121112111212112076dddd5176dddddddddddd51
0006600000000000006666666666666666666600777777655777776577757777677777756777777755555555000000000000000076dddd5176dddddddddddd51
006825007777700006777777777577777777776077777765757777657775777767777757677777775aaaaaa5000000000000000076dddd5176dddddddddddd51
006825007700770067577777777577777777756577777765775777657775777767777577677777775a979945000000000000000076dddd5176dddddddddddd51
067766507700770067757777777577777777576555555555777577657775777767775777655555555a799945000000000000000076dddd5176dddddddddddd51
065761507777700067775777777577777775776577777765777757657775777767757777677777775a999945000000000000000076d55d5176d5dddddddd5d51
065761507700000067777577777577777757776577777765777775657775777767577777677777775a999945000000000000000076dddd5176dddddddddddd51
055555507700000067777757777577777577776577777765666666506665666605666666677777775a4444450000000000000000765555517555555555555551
00000000000000006777777577757777577777657777776555555500555555550055555567777777555555550000000000000000711111117111111111111111
00333333000033333333300000fffffffffffffffffff00000777777777777777777700044444444444444444444444400000008800000008888888800000000
03333333300333333b3b33000ff99ffff99fffffffffff0007766777766777777777770042222222222222222222222400000088880000008888888800000000
333333333333333333b33330fffffffffffffffff99ffff077777777777777777667777042224444444444444444442400000888888000008888888800000000
33b3b3333b3b333333333333f99fffffffff99ffffffffff76677777777766777777777742222244444444444444422400008888888800008888888800000000
333b333333b3333333333333ffffffffffffffffffffffff77777777777777777777777742222244444444444444292400088888888880008888888800000000
333333333333b3b3333b3b33ffff99fffffffffffffff99f77776677777777777777766742222222444444444442942400888888888888008888888800000000
3333b3b333333b333333b333fffffffff99ffffff99fffff77777777766777777667777742222222444444444429492408888888888888808888888800000000
33333b333333333333333333f99fffffffffffffffffffff76677777777777777777777742222222444444442294942488888888888888888888888800000000
333333333333333333333333ffffffffffffffffffffffff77777777777777777777777742222222222222224949492488888888888888880000000000000000
03b3b3333337333333b3b3300ffffffff99f3ffff99ffff00777777776633777766777704222222229aaaa829494942408888888888888800000000000000000
033b3333337a7333333b33000f99fffffff636ffffffff00076677777773377777777700422222222a8aa9a24949492400888888888888000000000000000000
333333333337333333333330fffffffff3f333f3fff99ff07777777777333377777667704222222228a8aa829494942400088888888880000000000000000000
0333333333bbb3333b3b33330fff99fff6363636ffffffff077766777733337777777777422222222aa9a8924949492400008888888800000000000000000000
0033b3b3333b333333b3333300fffffffff333fff99fffff0077777777333377766777774222222228aa8a829494942400000888888000000000000000000000
03333b3333333333333333300f99fffff99636fffffffff007667777766227777777777042222222298aaaa24949492400000088880000000000000000000000
333333333333333333333333ffffffffffffffffffffffff77777777777777777777777742222222222222229494942400000008800000000000000000000000
333333333333333333333b3bffffffffffffffffffffffff77777777777777777777777742222222999999992949492408888880888888800088888800088000
3b3b333333b3b3333b3b33b3ff999ffff99ffffff99fffff77666777766777777667777742222229999999992494942488888888888888880888888800088000
33b33333333b333333b33333ffffffffffffffffffffffff77777777777777777777777742222229999999999249492400000000000000000000000000000000
33333b3b33333b3b33333333ffffffffffff99ffffff99ff77777777777766777777667742222299999999999924942488888880000088880888000000088000
333333b3333333b33333b3b3ffff99fffffffffff99fffff77776677777777777667777742222999999999999992492408888888000088880888000000088000
133333332333333233333b321fffffff2ffffff2fffffff217777777277777727777777242229999999999999999242400000000000000000000000000000000
2121221221322122212123122121221221f2212221212f1221212212217221222121271242299999999999999999922408888880000088880888000000088000
02121121121112111212112002121121121112111212112002121121121112111212112042222222222222222222222488888800000088880888000000088000
00cccc000044440000b3b30000ffff00007777000044440000999900888888808800000088000088880000880000000088800888088888880000000000000000
0ccc3330044444400b3b3b300ffffff0077777700442844009aaaa90888888888800000088000088888008880000000088808888888888880008800000000000
3ccc333344224444b3b3b3b3ff99ffff77667777442228849aaaaaa9000000000000000000000000000000000000000000000000000000000080080000000000
333cc333444444443b3b3b3bffffffff77777777444444449aaaaaa988000088880000008800008800888800000000008880000088888888008ee80000000000
3333cccc44442244b3b3b3b3ffff99ff77776677444488449aaaaaa9880000888800000088000088008888000000000088800000888888880008800000000000
cccccccc444444443b3b3b3bffffffff77777777448822449aaaaaa9000000000000000000000000000000000000000000000000000000000000000000000000
0c3333c00422444003b3b3b00f99fff0076677700444444009aaaa90888888888888888888888888888008880000000088808888888888880000000000000000
00c3330000444400003b3b0000ffff00007777000044440000999900888888800888888008888880880000880000000088800888088888880000000000000000
00000000000000000000000000000000b2b2b2b2a2b2c2b2b2b2b2b2b2a2b2b21414d0d0d0141414f02400000000000000344444444452000052444444444444
74747474747474747474747574747474b0b0d1e1b0b0b0d1e1b0b0b2d1e1b0b00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000012000000000000000002000000d0d0d0d0d0d0d01616d014d0d0d0141400354646445512320000354646444544
74747574747474747474747474747474b2b2b2b2b2b2b2b2b2b2c23232a2b2b20000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000d0d0d1e1d0d025423205d0d0d1e1d0d044444444444400006202444444444444
74747474747574747475747475747474000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000270000000000000000000000a0b0b0c0620062000000a0a0b0c000d0d2e2f2d2d025620005d0d2e2f2d2d044464646444444444444444444464644
74767676767674747474767676767674000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000a1d1e1c1005200000000a1d1e1c100d0d3e3f3d3d0d0d014d0d0d3e3f3d3d055b0b0b0354644464646444655b0b035
76767676767676767676767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000047000000000000a2b2c2c2000000000000a2a2b2c200d0d0d1e1d01616d0d0d0d016d1e1d0d055b0e0b035223544d244557255b0b035
00000000000000000000000000000000000000000052a0b0e0b0c052000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000d016161625620005161625525205d0d055b0b0b035223544d344555255b0b035
00000000000000000000000000000000000000000000a194a4b4b000000000000000000000000000000000000000000000000000000000000000000000000000
000037000000670000000000000000000000000000a0b0c00000000000000000d0d0d0d025001205d0d025027205d0d055b0b0b0354444444444444455b0b035
00000000000000000000000000000000000000000000b095a5b5c100000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000005200a1b1c10052000000000000161616161616161616161616161615d044444445444446464646464444454444
74747474747474748400000000000000000000000000a196a6b6b000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000005700000000000000000000a2b2c200000000000000000000000000000000000000000000061644444444444444444544444444444444
74747474747474748562620000000000000000000052a2b2b2b2c252000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046464646464646464444444446464646
74747574747475747452005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000170000000000000000000000000000a0b0b0b0b0b0c000000000000000001204141414141424000002000000000000000000003646465600000000
74747474747474747400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000b0d2b1b1b1b1c10000000000000000220515d015d0d0d0000022000000000000000000000000000000000000
747474747475747474420000000000000052a0b0b0b0c00000a0b0b0b0b0c0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a1d3b1d1e1b1d0b0c000000000000052d0d0161616d015142452000000000000000000000000000000000000
747474747474747485000000000000000000a194a4b4b0b0b0b0b094a4b4b0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a2b0b1b1b1b1d0b1c10000000000520006161616161616162600000000000000003234445422000000000000
767676767676767686000000000000000052b095a5b5b094a4b4b095a5b5c1000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000a2d0d0f0d0d0b1c10000000000000000000052520000000000000000000000003445464554000000000000
000000000000000000000000000000000000a196a6b6b095a5b5b096a6b6b0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000220000a2b0b1b1b1b1c10000000000000000000000000000000000000000000062344444454444546200000000
000000000000000000000000000000000052a2b2b2b2b096a6b6b0b2b2b2c2000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000a2b2b2b2b2c2000000000000620414d0d014d0256200000000000000523545e2d2f244555200000000
00001264747474747474840200000000000000000000a2b2b2b2c200000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000012020000000000000000000000520515e2d2f2d0255200000000000000124444e3d3f345440200000000
003264747574d1e17475748432000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000012d0d0e3d3f31525020000000000000000364646464646560000000000
000066767676767676767686000000000000120052a0b0b0b0c05200020000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000a0b0b0b0b0b0c0000000000000000000000006161616161626000000000000000000003200000032000000000000
000000000000000000000000000000000000000052a194a4b4b05200000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000b0d2b1b1b1b1c1000000000000000000000000320000003200000000000000000000003444444444540000000000
000000006475747475840000000000000000220052b095a5b5c15200220000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000a1d3b1d1e1b1c10000000000000000000000000004d0240000000000000000000000003544464644550000000000
000000626576767676856200000000000000000052a196a6b6b05200000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000a2b0b1b1b1b1c1000000000000000000000000000515250000000000000000000000003544444445550000000000
000000526575747475855200000000000000620052a2b2b2b2c25200620000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000a2b2b2b2b2c2000000000000000000000000000616260000000000000000000000003646464646560000000000
00000000667676767686000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000052000000000000000000000000000000000052000000000000000000000000000000520000000000000000
00000000000000520000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000052000000000000000000000000000000000052000000000000000000000000000000520000000000000000
00000000000000520000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000052000000000000000000000000000000000052000000000000000000000000000000520000000000000000
00000000000000520000000000000000000000000000005200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000002800000000000000000000000000002800000000000000000000000000000000280000000000000000000000000000002800000000000000000000000000002800000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004c00000000000000004d00000000000000000021000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004c4e00004e4e4e004e004e4d000000000000000a0b0b0b0b0b0c000000000000002640410d0d410d5226000000000000000000000000250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004c5d4e00004e005d004e4e4e5c4d0000000025000b2d1b1b1b1b1c000025000000002550512e2d2f0d52250000000000000000000025002600250000000000000000004647474800004647474800000000000a0b0b0c00000a0b0b0c0000000000000000000000000000000000000000000000000000000000000000000000
4c5d004e4e004e0000004e004e005c4d00000000001a3d1b1d1e1b1c00000000000000210d0d3e3d3f515220000000000000000025000000000000002500000000000023561b1b582525561b1b5823000000231a1b1b1c25251a1b1b1c2300000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000252a0b1b1b1b1b1c25000000000000006061616161616200000000000000000043544500000043544500000000000026561b1b472626561b1b4726000000261a2b2b1c26261a2b2b1c2600000000000000000000000000000000000000000000000000000000000000000000
00006c006d006e006f007c007d0000000000000000002a2b2b2b2b2c000000000000000000230000002300000000000000000000536455240024536455000000000000216667676800006667676820000000212a2b2b2c00002a2b2b2c2000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002500000000000000000000000000400d42000000000000000000000063646500000063646500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077007d00780079007a007d00000000002600000000000000260000000000000000005051520000000000000000000000000000000000000000000000000000000000004647474800000000000000000000000a0b0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000a0b0b2b0b0b0c00000000000000000000606162000000000000000000000000000000000000000000000000000000000021561b1b5820000000000000000000211a2b2b1c2000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001a0d1c261a0d1c000000000000000000000025000000000000000000000000000023434445220000000000000000000000206667676821000000000000000000202a2b2b2c2100000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001a0d1c251a0d1c00000000000000000000000000000000000000000000000000004364646445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000002a2b2b2b2b2b2c00000000000000000000000000000000000000000000000026434444544444452600000000000000000023464748220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000004041414141414200000000000000000000002553542e2d2f44552500000000000000000046676767480000000000000000000025002626002500000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000002250510d5161610d00002200000000000000002144443e3d3f54442000000000000000264647475747474826000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000240000000000002400000000000d0d61610d0d514142000000000000000000006364646464646500000000000000002557572e2d2f475825000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000606161616161616162002500000000000000000023000000230000000000000000002147473e3d3f574720000000000000000023000000230000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000260000000000000000000000002525000000000000000000000000000000434444444445000000000000000000666767676767680000000000000000000a0b0b0b0b0c00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000214041414141414200002000000000000000534454444455000000000000000000002300000023000000000000000000250a494a4a4b0c25000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000050510d5161610d00000000000000000000531d1e445455000000000000000000000000000000000000000000000000001a595a5a5b1c00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000250d0d61610d0d5141422500000000000000636464646465000000000000000000000000000000000000000000000021001a696a6a6b1c00200000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000006061616161616161620000000000000000000000000000000000000000000000000000000000000000000000000000002a2b2b2b2b2c00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000a0b0b2b2b2b2b0b0b0b0c0000000000000000000025250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b2b0b0b0d1c260000261a0d0d0b00000000000000000000000000000000000000000000000000230000230000000000474757474747474747474747474747470b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000007000000d0d0d0b0d1c002021001a0d0d1c0000000000000040410d0d410d0d410d410000000000000000000000000000000000472e2f474747574747474747474747470b2b0b0b0b0b0b1b1b1b0b0b0b0b2b0b0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000d0d0d0b2b0b2b0b2b2b2b0b2b2b0c00000000002550516161610d1d1e510d0000000000000000000000000000000000473e3f574767474747476747574747471c251a2e2f0b0b1b271b0b2e2f1c251a0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a0b0b1c0d1a0d1c0d0d0d1a270d1c0000000000250d0d0d0d0d0d0d0d0d520000000000434444444444444444444444474747475821471d1e572056472e2f471c251a3e3f0b0b1b1b1b0b3e3f1c251a0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001a2e2f2d2e2f2d2e2f2d2e2f2d2e2f0c00000000250d0d0d1d1e0d510d0d0d0000002643444444544444444444444444474747474747474747676767473e3f470b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b3e3f3d3e3f3d3e3f3d3e3f3d3e3f1c0000000021500d0d0d0d0d616161520000004344444444444444444454444444474757676767674758252725564747470b0b494a4b25494a4a4b25494a4b0b0b0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b1d1e231d1e211d1e201d1e231d1e0b0000000000606161616161616161620000235344442e2f442d1d1e2d442e2f44474747582356574747582556574747470b0b595a5b26595a5a5b26595a5b0b0b0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b2e2f2d2e2f2d2e2f2d2e2f2d2e2f1c0000000000000000000000000000000000005344443e3f441d1d1e1e443e3f44472e2f582356474747474747474747470b0b696a6b21696a6a6b20696a6b0b0b0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b3e3f3d3e3f3d3e3f3d3e3f3d3e3f0b0000000000000000000000000000000000005354444464646464444444444444473e3f474747574747676767676747470b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000
__sfx__
010200002a1301a130000000000000000000000000000000000002800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000f64014630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000240301d030240302b03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001a6301a62017610126100661026600226001e600156001060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b03030030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600000b44009455094550c44009455094550e4400945509455104400945509455114400945509455114401044009455094550e44009455094550c44009455094550b44009455094550c4401c2402124023240
011600002424024240242422624023240232402324224240212402124021240212402124220240212402324028240000002824000000282400000028240000002824028240282402824028242282422624028240
0116000029240292402924029242232402324224240262402824028240282402824221240212402124223240242402424024242262402324023240232422424021240212402124221232212221c2402124023240
01160000094350c4351043515435094350e4351143514435094350c4351043515435094350c4351043515435094351543509435154350b435174350b435174350c435184350c435184350c435184350c43518435
011600000243505435094350e43504435084350b43510435094351043515435184350243506435094350e4350343506435094350c43504435084350b4350e4350943510435154351843509435104351543518435
0116000029240292402924029242232402324224240262402824028240282402824221240212402124223240242402424024242262402324023240232422424021240212402124221232212222d3402c3402d340
011600002f3402834027340283402f34028340343403235532340303402f3402d3552d3402f340303402d3402f3402b3402a3402b3402f3402b34037340353553534034340323403035530340323403434030340
01160000313402d34031340343403935539340373403934035340343403234031340323402d3402b3402d340333402f34033340363403c340323403b3403935539355393402f3403934038340393403b34034340
01160000044350b435104350b435084350b4350e4350b435094351043518435154350c435154351843515435074350e4351743513435074350e43517435134350043507435104350c4350443507435104350c435
01160000094350d43515435104350143515435104350d4350243509435114350e4350043509435114350e4350b435124350f4350b435034350b435124350f435044350b435104350b435044351c4402144023435
010e000001155011551c415011550b15501155001050115501155001000b1551c415287041c415011550115501155011551c4151c4150b15528705011550115501155001000b155091051c4151c4153f0153f015
010e00000c0433f015174152a7050c0432a7053061530615306153f0153f015174150c043174152a7043f0150c0433f01517415174150c0432a70530615306150c0433f015306153f01517415174150c0430c043
0114000002140071400e1400014000140101400e14013140131301514002140101400e14009140071400014013140151401814013130151301813013120151201812013010150101801013015150151801500000
0114000012050120401203510050100402a2322b2323223232232322322f2322b2322a2322b23223232262322b2422a242262422b2322a232262322b2222a222262222b2122a212262122b2152a2152621500300
001400003d61039611326112d61127611236111f6111b6111961115611126110f6110c6110a611086110661105611046110361102611016110161101611016110161101611016110161101615016150161501600
010e000011240112251824018225182401822516240162251424014225132401322511240112250f2400f22511240112251324013225142401422516240162251824018230182201822018222182251124011245
010e000019240192251624016225182401822519240192251b2401b2251d2401d2251824018225162401622514240142251124011225132401322514240142251624016230162221622514240142251624016225
010e00001824018230182221822519240192251824018225182401822516240162251424014225132401322511240112301123211225142401324011240112251624016230162221622514240142251624016225
010e00000c043000003c2150000030610186153c2150c0430c043000003c2153c21530610186153c2150c0430c0433c2153c2150c04330610186153c2150c0430c0433c2153c2153c21530610186153c2153c215
010e0000182401822519240192251b2401b2251d2401d225182401822516240162251424014225132401322511240112401124011240112401124011240112401123011230112301123011232112221122211225
010e000000155001551c415001550b15500155001050015500155001000b1551c415287041c415001550015500155001551c4151c4150b15528705001550015500155001000b155091051c4151c4153f0153f015
010e00000c043000003c2150000030610186153c2150c0430c043000003c2153c21530610186153c2150c0430c0433c2153c2150c04330610186153c2150c0430c0430c0433c2150c04330610186152461524615
010e00000c0433f015174152a7050c0432a7053061530615306153f0153f015174150c043174152a7043f015174153f01517405174150c0432a70530615306151c4153f015306151c4150c043306153061530615
010e000000155001551c415001550b15500155001050015500155001000b1551c415287041c41500155001551c41500155001551c4150b1552870500155001550b15500155001550b1550b155001550b1550b155
001000001a250182001a2521e2001e0001e2001e2000c2000e200102000e2000c2000c2000c20000200002001d2501d252002021c250002021a2520020000200002001a2320020000200002001a2120020000200
0010000015140111001514209100091000c1000c1000c10000100001000010000100000000000000000000001a1401a1420010018140001001514200100001000010015122001000010000100151120010000100
010f00000c25210252132551825500205132551825218252002000020000200002000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000001663500000000000000516635000000000000000000000000000000000001663500000000000000016635000000000000000166350000000000
01100000071550000007055000001325500000130550000007155070550000007055132550000011055131550715500000070550000013255000001305500000051550505500000071550a25500000070550a155
011000001307311124111251112513073111201112511120130731112511120111201307311124111201112513073131241312513125130731312013125131201307300000131200000013073131200000000000
011000001307311124111251112513073111201112511120130731112511120111201307311124111201112513073131241312513125131251312013125131200000000000131201307300000131201307300000
011000001a1201a1201a1251a125246651a1201a1251a1201a1251a1251a1201a120246651a1201a1201a1251a1201a1201a1251a125246651a1201a1251a12000000000001d12000000246651d1200000000000
011000001a1201a1201a1251a125246651a1201a1251a1201a1251a1251a1201a120246651a1201a1201a1251a1201a1201a1251a1251a1251a1201a1251a12000000000001d12000000246651d1202463524665
011000001612016120161251612516125161201612516120161251612516120161201612516120161201612518120181201812518125181251812018125181200000000000181200000000000181200000000000
0110000016120161201612516125323551612032315161203035516125303152b355161252b3152935516125293151812018125181252d355181202d315181202e355000002e3153035500000303152635500000
0110000026315000000000000000303550000030315000002e355000002e3152b355000002b3152935500000293150000000000000002b355000002b315000002d355000002d3152935500000293152235500000
011000001a3201a31022320223152432022315213202431522320213151f32022315213201f3151d320213151a3201f315223201a3152432022315213202431522320213151f32022315213201f3151d32021315
0110000026555000002e55526515305552e5152d555305152e5552d5152b5552e5152d5552b515295552d51526555295152e55526515305552e5152d555305152e5552d5152b5552e5152d5552b515295552d515
011000001307300000000000000013073000000000000000130730000000000000001307300000000000000013073000000000000000130730000000000000001307300000000000000013073000000000000000
011000001307300000000000000013073000000000000000130730000000000000001307300000000001303313073000000000000000000000000000000000000000000000000001307318000130231307300000
011000000000000000000000000024665000000000000000000000000000000300002466500000000000000000000000000000000000246650000000000000000000000000000000000024665000000000000000
01100000000003f615000003f61524665000003f6150000000000300003f6153000024665000000000000000000003f615000003f61524665000003f6150000000000000003f6153f61524665000000000000000
01100000000003f615000003f61524665000003f6150000000000300003f615300002466500000000000000000000000000000000000000000000000000000000000000000000000000024665000002463524665
011e00200c505155351853517535135051553518535175350050015535185351a5350050515535185351a53500505155351c5351a53500505155351c5351a53500505155351a5351853500505155351a53518535
010f0020001630020000143002000f655002000020000163001630010000163002000f655001000010000163001630010000163002000f655002000010000163001630f65500163002000f655002000f60300163
013c002000000090750b0750c075090750c0750b0750b0050b0050c0750e075100750e0750c0750b0750000000000090750b0750c0750e0750c0751007510005000000e0751007511075100750c0751007510005
013c00200921409214092140921409214092140421404214022140221402214022140221402214042140421409214092140921409214092140921404214042140221402214022140221402214022140421404214
013c00200521405214052140521404214042140721407214092140921409214092140b2140b214072140721405214052140521405214042140421407214072140921409214092140921409214092140921409214
0130000000000000000000035500295102951129511295001f5101f50021510215002351023511235000000000000000000000000000225202251122511225002152021511215112150000000000000000000000
01300000260542605226042260212d0342d0422d0522d03130034300322f0302f0322b0402b0522b0422b0312e0542e0422d0502d0422c0502c0422c041290542b0502b042280542804229040290522902128054
0130000002435094350e435104351143511400024250e400074350e435134351543517435174001d4051c400024350a4350e4351043514435154050a4250e400094350c435104351343516425094251542509425
0130000007405094050e4100e4110e4110e4000c40509405074050940507410074110741007411074002840004405054050740509405044100440004405284000040000400004000040010412104111042510415
01300000000000000000000000002951029511295112950000000000001f5201f5112b5102b5112b5112b50026510265112651126500215102151121511215001a5201a5211a5111a50000000000000000000000
01300000260542605226042260212d0342d0422d0522d03130034300322f0302f0322b0402b0522b0422b031290342d0322b04229052280422803126036240522805228031260542605526054260522604226031
0130000002435094350e435104351143511400024250e400074350e43513435154351643517400074251c40002435094350e4350943515435094350e4350c4350243509435104350943511435054000540008400
013000000e4220e4110e4000c40511410114110c4050940507405094050a4050c4050e4200e4112940528400044050540507405094051041210411044052840000400004000c4220c41102422024110240000400
013000001d7341d7411d7511d7211d7441a73215734157111f7341f7411f7511f7411f7311f7211f7111a7341d7341d7411d7511d741207342073120721207111f7341f7411f7511f7111f7441f7511f7311f711
013000001d7341d7411d7511d7211d7441a73215734157111f7341f7411f7511f7311f7211f7111a7341a7311d7441d731157241a7441c7341c73215724187241d7541d7311c7241c7111d7441d7311d7211d711
011c00001d1321d11121132211111f1321f1111d1321d1111c1321c1211c1111d1561a1321a11118132181211c1421c1321c1211c1111a1521a1421a1211a1111a1111a1521a1421a1321a1211a1111a1111a112
__music__
00 05 42 43 44
01 06 08 43 44
00 07 09 43 44
00 06 08 43 44
00 0a 09 43 44
00 0b 0d 43 44
02 0c 0e 43 44
00 41 42 43 44
04 11 12 13 44
01 14 17 43 44
00 14 17 43 44
00 15 17 43 44
00 16 17 43 44
02 18 1a 43 44
01 0f 10 43 44
00 0f 10 43 44
00 19 10 43 44
02 1c 1b 43 44
04 1d 1e 43 20
01 21 42 2b 2d
00 21 26 22 24
00 21 27 22 24
00 28 26 23 25
00 21 2a 2b 2e
02 21 2a 2c 2f
01 32 42 43 31
00 32 30 43 31
00 32 30 33 31
00 34 42 43 31
02 33 32 43 31
00 35 36 37 38
00 39 3a 3b 3c
00 3d 36 37 38
00 3e 3a 3b 3c
04 41 3f 00 00
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
