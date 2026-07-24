pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--armadillo
--by:	jalecko
--music: maahlie
--i swear this is the last update
cartdata("armadillo_jalecko_1_2")
function _init()
camera(0,0)
cls(0)
grav=0.3
sfx(7)
st=0
et=0
screen="startup"
itemenu=0
mt=20

quicktime=dget(0)--240
if quicktime==0 then quicktime=240 dset(0,240) end
ndone=dget(1)
sdone=dget(2)
hdone=dget(3)
--finished=dget(4)

end


function gamestart(_mode)
reload(0x1000, 0x1000, 0x2000)
camx=0
camy=0
init_objects()

set_doors()
back_spr=0
back_col=12
sback_spr=0
sback_col=12
camax1=8
camay1=0
camax2=255
camay2=127

scamax1=8
scamay1=0
scamax2=255
scamay2=127

lastt=time()
wt=true
sptime=0
mbossfight=false

add_player(32,88)
spawn_enemies()

xready=true
oready=true
dready=true

wind=false
bwind=false
wdir=-.25
wst =0


mode=_mode

screen="game"
end
-->8
function _update()
mt-=1

if screen=="startup" then
music(-1)
if st<=50 then
	st+=1
	else
	screen="menu"
end
if st==16 then
	sfx(8)
end
if st<=16 then
pal(7,st/2.2)
end
end

if screen=="menu" then
	musicloop(0,958) 
	if btn(—)then
	sfx(11)
 mswitch()
	--musicloop(0,30)
	if itemenu==0 then
		gamestart("normal")
	end
	if itemenu==1 then
		gamestart("speedrun")
	end
	if itemenu==2 then
		gamestart("hardcore")
	end
	end
	
	if ndone==1 then
		if btnp(ƒ) then
			itemenu+=1 sfx(0)
		end
		if btnp(”) then
			itemenu-=1 sfx(0)
		end
	end
	if itemenu>2 then itemenu=0 end
	if itemenu<0 then itemenu=2 end
end

if screen=="end" then
	musicloop(15,1240)
 if btn(—) then
		_init()
	end
end

if screen=="game" then

if not btn(Ž) then
oready=true
end

if not btn(—) then
xready=true
end

if not btn(ƒ) then
dready=true
end

--input()
storm()
--musicloop(5,30)
for p in all(player) do
p:update()

for f in all(fboss) do
	if hit(p.x,p.y,p.w,p.h,f.x,f.y,f.w,f.h) and not f.gone then
		if p.ball then
			if p.dropping then
				sfx(5)
				p.dy=-3
				p.dropping=false
				f.hp-=1
				if f.hp >0 then
					for i = 0,2 do
						add_mage(camax1+8+(flr(rnd(9))*8)+i*72,camy+8+rnd(40))
					end
				end
					for i = 0,12 do
						add_particle(f.x+rnd(10)-2,f.y+rnd(20),rnd(2),-rnd(1)+.5,53,3,.2,15)
					end
				p.tim=30
				p.inv=true
			 f.gone=true
				f.t=0
				wind=false
			end	
		else
			if not p.inv then
				p.hp-=1
				sfx(6)
				p.tim=60
				p.inv=true
				if p.flp then
					p.dx=4
				else
					p.dx=-4
				end
				p.dy=-2
			end
		end
	end
end

for tb in all(tboss) do
	if hit(p.x,p.y,p.w,p.h,tb.x,tb.y,tb.w,tb.h) then
		if p.dropping and tb.out then
			tb.hp-=1
			
			for i = 0,8 do
				add_particle(tb.x+6,tb.y+6,rnd(2)-1,-rnd(1)+.5,53,3)
			end
			p.dy=-2
			p.dropping=false
			sfx(6)
			
			if tb.hp<=4 then
			 tb.ag=40
			 tb.spm=1.5
			else
			 tb.ag=130
			 tb.spm=1
			end
			tb.t=tb.ag-1
		end
		if not p.inv then
			if not p.ball or tb.dropping then
				p.hp-=1
				sfx(6)
				p.tim=80
				p.inv=true
				
				if p.flp then
				p.dx=4
				else
					p.dx=-4
				end
				p.dy=-2
				
			end

			if tb.sliding then
				
				if tb.flp then
					p.dx=17
				else
					p.dx=-17
				end
				p.kt =20
				p.dy=-2				
			end

		end 
	end
end

for b in all(boss) do
	if hit(p.x,p.y,p.w,p.h,b.x,b.y,b.w,b.h) and not b.inv then
		if p.dropping then
			b.hp-=1
			b.t=96
			b.inv=true
			for i = 0,8 do
				add_particle(b.x+6,b.y+6,rnd(2)-1,-rnd(1)+.5,53,3)
			end
			p.dy=-2
			p.dropping=false
			sfx(6)
		end
		if p.ball then
   if b.t<=8 then
				if not p.jumping and p.landed then
					p.landed=false
					p.jumping=true
   		p.kt=10
					p.dy=-11
					sfx(9)
				end
   end
		else	
			if not p.inv then
				sfx(6)
				p.tim=40
				p.inv=true
				p.hp-=1	--player gets damaged by turtle
				if p.flp then
				p.dx=4
				else
					p.dx=-4
				end
				p.dy=-2
			end
		end
	end	
end

for h in all(heart) do
	if hit(p.x,p.y,p.w,p.h,h.x,h.y,7,7) then
		if p.hp<p.maxhp then
			p.hp+=1
			sfx(7)
			del(heart,h)
		end
	end
end

for h in all(aheart) do
	if hit(p.x,p.y,p.w,p.h,h.x,h.y,7,7) then
		if p.hp<6 then
			p.armor=true
			p.hp=6
			p.maxhp=6
			sfx(7)
			del(aheart,h)
		end
	end
end

for d in all(door) do
	if hit(p.x,p.y,p.w,p.h,d.x,d.y,8,16) then
		if btnp(”) then
			sfx(11)
			p.x=d.gx
			p.y=d.gy
			if d.check==true then
				p.sx=d.gx
				p.sy=d.gy
				scamax1=d.cx
				scamay1=d.cy
				scamax2=d.cmx
				scamay2=d.cmy
				sback_spr=d.bc
				sback_col=d.bcol
			end
				camax1=d.cx
				camay1=d.cy
				camax2=d.cmx
				camay2=d.cmy
				back_spr=d.bc
				back_col=d.bcol
				init_enemies()
				spawn_enemies()
		end
	end
end

	for b in all(ball) do
		if hit(p.x,p.y,p.w,p.h,b.x,b.y,b.w,b.h) and not p.inv then
			sfx(6)
			p.tim=30
			p.inv=true
			p.hp-=1	--player gets damaged by turtle
			if p.flp then
			p.dx=4
			else
				p.dx=-4
			end
			p.dy=-2
			del(ball,b)
		end
	end
	
 for r in all(rock) do
		if hit(p.x,p.y,p.w,p.h,r.x,r.y,r.w,r.h) and not p.inv and not r.bounced then
			sfx(6)
			p.tim=90
			p.inv=true
			p.hp-=1	--player gets damaged by turtle
			if p.flp then
			p.dx=4
			else
				p.dx=-4
			end
			p.dy=-2
			del(rock,r)
		end
	end



for m in all(mage) do

	if hit(p.x,p.y,p.w,p.h,m.x,m.y,m.w,m.h) then
		if p.dropping then
			p.dropping = false
			--add_particle(m.x,m.y,0,0,51,1)
		for i = 0,4 do
			add_particle(m.x+2,m.y+4,-2+rnd(4),rnd(4)/4,53,3)
		end
			sfx(5)--when the player lands a hit on a turtle
			del(mage,m)
			p.dy=-2
			elseif not p.ball and not p.inv then
				sfx(6)
				p.tim=30
				p.inv=true
				p.hp-=1	--player gets damaged by turtle
				if p.flp then
				p.dx=4
				else
					p.dx=-4
				end
					p.dy=-2
			end
				
	end
end


for t in all(turtle) do

	if hit(p.x,p.y,8,8,t.x,t.y,8,6) then
		if p.dropping then
			p.dropping = false
			add_particle(t.x,t.y,0,0,51,1)
		for i = 0,4 do
			add_particle(t.x+2,t.y+4,-2+rnd(4),rnd(1)/4,53,3)
		end
			sfx(5)--when the player lands a hit on a turtle
			del(turtle,t)
			p.dy=-2
		end
				
	end
	
	if not p.inv and hit(p.x,p.y,8,14,t.x,t.y,8,6) then
		if not p.ball and not p.dropping then
			sfx(6)
			p.tim=30
			p.inv=true
			p.hp-=1	--player gets damaged by turtle
			if p.flp then
				p.dx=4
			else
				p.dx=-4
			end
				p.dy=-2
		end

	end
	
	if p.ball and hit(p.x,p.y,8,8,t.x,t.y,8,6) and not p.running and not p.falling then
		p.dx=t.dx*2
		p.sliding=true --player gets pushed by turtle
	end
	end

	for m in all(mole) do
		if hit(p.x,p.y,8,10,m.x,m.y,8,8) and m.out then
			if p.ball then
				if not p.jumping and p.landed then
					p.landed=false
					p.jumping=true
   		p.kt=10
					p.dy=-7
					sfx(9)
				end
			else
			if not p.inv then
			sfx(6)
			p.tim=30 --player gets damaged by mole
			p.inv=true
			p.hp-=1
			if p.flp then
				p.dx=4
			else
				p.dx=-4
			end
				p.dy=-2
			end
			end
		end
		
		if hit(p.x,p.y,8,8,m.x,m.y,8,8) and p.dropping and m.t<=25 then
			del(mole,m)
			sfx(4)
			--sfx(5)
			for i = 0,4 do
				add_particle(m.x-2,m.y+4,-2+rnd(4),rnd(2)+0.5,4,1)
				add_particle(m.x+2,m.y+4,-2+rnd(4),rnd(1)/4,53,3)
			end
		end
		
	end

end

for c in all(part) do
c:update()
end

for m in all(mage) do
m:update()
	for p in all(player) do
		if p.x>m.x then
			m.flp=true
			m.dirc=1
			else
			m.flp=false
			m.dirc=-1
		end
	end
end 

for tb in all(tboss) do
tb:update()
	for p in all(player) do
		if not tb.sliding and tb.out then
			if p.x>tb.x+4 then
				tb.flp=true
			else
				tb.flp=false
			end
		end
	end
end

for f in all(fboss) do
f:update()
	for p in all(player) do
		if p.x>f.x+5 then
			f.flp=true
			f.dirc=1
			else
			f.flp=false
			f.dirc=-1
		end
	end
end

for b in all(ball) do
b:update()
end

for e in all(explo) do
e:update()
end

for r in all(rock) do
r:update()
end

for t in all(turtle) do
t:update()
end

for o in all(mole) do
o:update()
end

for h in all(heart) do
h:update()
end

for h in all(aheart) do
h:update()
end

for b in all(boss) do
	b:update()

	for p in all(player) do
	
	if b.t==0 then
		if p.x<b.x then
			b.flp=true
			else
			b.flp=false
		end
	end
	end
end
if mbossfight then
musicloop(9,520)
else
musicloop(6,494)
end

end


end

function _draw()

if screen=="startup" then
cls(0)
map(0,48,8,4,st,st)
end

if screen=="end" then
et+=0.2
camera(0,0)
cls(2)
circfill(63,120,96,8)
circfill(63,112,64,9)
circfill(63,104,40,10)
circfill(63,104,24,7)
circfill(-52,96,64,0)
rectfill(8+et,93,9+et,96)
rectfill(0,96,127,127,0)
print("the king of the great mountain",4,104,7)
print("has been defeated",24,110,7)
if mode=="speedrun" then print("your time is: ".. flr(sptime/60).."."..flr(sptime*100)/100%60,20,116,7) end
if mode=="hardcore" then print("you are an absolute madman",10,116,7) end
end

if screen=="menu" then
cls(12)
map(16,48,0,0,16,16)
--menu
if ndone==1 then
spr(30,30,58+itemenu*14)
printp("best time: "..flr(quicktime/60).."."..flr(quicktime*100)/100%60 .. " min",28,44,11,3)
printp("normal mode",40,60,10,3)
printp("speedrun mode",40,74,10,9)
printp("hardcore mode",40,88,8,2)
if ndone==1 then spr(31,86,58)end
if sdone==1 then spr(31,94,72)end
if hdone==1 then spr(31,94,86)end
else
printp("press — to play",33,80,10,3)
end
--credits
printp("made by jalecko",64,112,4,9)
printp("music by maahlie",60,120,4,9)
--print(mt,8,8)
end



if screen=="game" then
cls(back_col)
draw_back()

--pal(9,13)

for c in all(part) do
c:bdraw()
end

for b in all(boss) do
b:draw()
end

map(0,0,0,0,128,64)
--pal(9,9)


for o in all(mole) do
o:draw()
end

for m in all(mage) do
m:draw()
end

for tb in all(tboss) do
tb:draw()
end

for f in all(fboss) do
f:draw()
end

for p in all(player) do
p:draw()
end

for b in all(ball) do
b:draw()
end

for r in all(rock) do
r:draw()
end

for t in all(turtle) do
t:draw()
end

for h in all(heart) do
h:draw()
end

for h in all(aheart) do
h:draw()
end

for c in all(part) do
c:draw()
end

for b in all(boss) do
b:drawbar()
end

for b in all(tboss) do
b:drawbar()
end

for f in all(fboss) do
f:drawbar()
end

for p in all(player) do
p:drawbar()
end

for e in all(explo) do
e:draw()
end

if wt then
sptime=time()-lastt
end
if mode=="speedrun" then
printp(flr(sptime/60).."."..flr(sptime*100)/100%60,camx+58,camy+7,10,3)
end
--print(mode,camx+58,camy+16)
end
--pal(15,135,1)
--print("project armadillo alpha",12,2,0)

end



-->8
--declare objects
function init_objects()
	--declare player
	player={}
	--declare particles
	part={}
	--declare door
	door={}
	--declare explosion
	explo={}
	
init_enemies()
end

function init_enemies() 
	--declare turtles
	turtle={}
	--declare mole
	mole={}
	--declare mage
	mage={}
	--declare mage ball
	ball={}
	--declare rock
	rock={}
	--declare mole boss
	boss={}
	--declare turtle boss
	tboss={}
	--declare heart
	heart={}
	--declare armor heart
	aheart={}
	--declare final boss
	fboss={}
end

function add_player(_x,_y)
add(player,{
sp=1,
x=_x,
y=_y,
dx=0,
dy=0,
w=8,
h=14,
flp=false,
sx=_x,
sy=_y,
maxdx=3,
maxdy=3,
acc=0.7,
boost=4.4,
anim=0,
fric=0.8,
hp=3,
maxhp=3,
inv=false,--invisible?
tim=0,--invisible timer
ready=false,--ready to pound
running=false,
jumping=false,
falling=false,
sliding=false,
landed=false,
dropping=false,
bounce=0,
ball=false,
touch=false,
armor=false,--has armor?
kt=0,--kb timer
visible,
update=function(self)

--update player
player_update(self)
switch(self)
breakblock(self)

if self.hp<=3 and self.armor then
	self.armor=false
	for i=0,7 do
		add_particle(self.x+2,self.y-2,rnd(6)-3,rnd(2)-1,53,3)
	end
end 

if self.hp>self.maxhp then self.hp=self.maxhp end



if not self.ball then
player_animate(self)
self.h=14
self.boost=4.4
self.fric=0.8
else
ball_animate(self)
self.h=8
self.boost=4.1
self.fric=0.7
end


if not self.dropping then
self.maxdy=3
else
self.maxdy=8
end

knockback(self)


if self.inv then
self.tim-=1
end
if self.tim ==0then
self.inv=false
end

if self.inv then
	if flr(time()*10)%2==0 then
		self.visible=true
		else
		self.visible=false
	end
else
 self.visible=true
end

if self.hp==0 then
	del(player,self)
	sfx(10)
	add_player(self.sx,self.sy)
	wind=false
	reload(0x1000, 0x1000, 0x2000)
	camax1=scamax1
	camay1=scamay1
	camax2=scamax2
	camay2=scamay2
	back_col=sback_col
	back_spr=sback_spr
	init_enemies()
	spawn_enemies()
	mbossfight=false
end

if not self.armor then
self.maxhp=3
end

if mode=="hardcore" then
	self.maxhp=1
end

if not self.inv and 
(collide_map(self,"down",2) 
or collide_map(self,"up",2) 
or self.dy==0 
and	(collide_map(self,"right",3) 
or  collide_map(self,"left",3))
) then
	self.hp-=1
	self.inv=true
	self.tim=30
	sfx(6)
end

camra(self,camax1,camay1,camax2,camay2)
end,
draw=function(self)

if self.visible then
	if not self.ball  then
	spr(self.sp,self.x,self.y-2,1,2,self.flp)
	else
	spr(self.sp,self.x,self.y,1,1,self.flp)
	end

	if self.armor and not self.ball then
		if self.dy==0 then
			spr(28,self.x-4,self.y-5+self.sp,2,1,self.flp)
		else
			spr(28,self.x-4,self.y-4,2,1,self.flp)
		end 	
	end	
end
end,
drawbar=function(self)
for i=0,self.maxhp-1 do
spr(44,camx+i*8+6,camy+6)
end
for i=0,self.hp-1 do
spr(20,camx+i*8+6,camy+6)
end
--print(abs(self.dy),camx+16,camy+16)
--pal(3,3)
end})
end

function add_particle(_x,_y,_dx,_dy,_spr,_tmax,_spd,_col,_back)
add(part,{
sp=_spr,
x=_x,
y=_y,
dx=_dx,
dy=_dy,
tmax=_tmax,
spd=_spd,
col=_col,
back=_back,
t=0,
update=function(self)
	if self.spd==nil then
	self.spd=.2
	end
	if self.col==nil then
	self.col=7
	end
	if self.back==nil then
	self.back=false
	end
	self.t+=self.spd
	self.x+=self.dx
	self.y+=self.dy
	if self.t>self.tmax then
		del(part,self)
 end
end,
draw=function(self)
if not self.back then
pal(7,self.col)
spr(self.t+self.sp,self.x,self.y)
pal(7,7)
end
end,
bdraw=function(self)
if self.back then
pal(7,self.col)
spr(self.t+self.sp,self.x,self.y)
pal(7,7)
end
end})
end

function add_turtle(_x,_y)
add(turtle,{
sp=49,
x=_x,
y=_y,
w=8,
h=6,
dx=0,
dy=0,
t=0,
tmax=2,
flp=true,
wsp=.7,
update=function(self)

turtle_move(self)
	
end,
draw=function(self)
spr(self.sp+self.t,self.x,self.y-2,1,1,self.flp)
end})
end

function add_mole(_x,_y)
add(mole,{
x=_x,
y=_y,
w=8,
h=8,
t=50,
tmax=2,
flp=true,
wsp=.7,
out=false,
update=function(self)
	self.t-=1
	if self.t<=0 then
		self.t=50+rnd(1)
	end
end,
draw=function(self)
	spr(34,self.x,self.y,1,1)
	if self.t<=25 and self.t>=24 then
		spr(35,self.x,self.y,1,1)
	end
	if self.t<=24 and self.t>=3 then
		spr(36,self.x,self.y,1,1)
		self.out=true
	end
	if self.t<=3 then
		spr(35,self.x,self.y,1,1)
		self.out=false
	end
	
	
end})
end

function add_door(_x,_y,_gx,_gy,_cx,_cy,_cmx,_cmy,_bc,_bcol,_check)
add(door,{
x=_x,
y=_y,
gx=_gx,
gy=_gy,
cx=_cx,
cy=_cy,
cmx=_cmx,
cmy=_cmy,
bc=_bc,
bcol=_bcol,
check=_check,
update=function(self)

end})
end

function add_heart(_x,_y,_dy)
add(heart,{
x=_x,
y=_y,
w=7,
h=7,
dy=_dy,
update=function(self)
	self.dy+=.1
	self.y+=self.dy
	if collide_map(self,"down",0) then
		self.dy=-1
	end
	if mode=="hardcore" then
	del(heart,self)
	end
end,
draw=function(self)
spr(20,self.x,self.y)
end})
end

function add_armor(_x,_y,_dy)
add(aheart,{
x=_x,
y=_y,
w=7,
h=7,
dy=_dy,
update=function(self)
	self.dy+=.1
	self.y+=self.dy
	if collide_map(self,"down",0) then
		self.dy=-1
	end
	if mode=="hardcore" then
	del(aheart,self)
	end
end,
draw=function(self)
spr(111,self.x,self.y)
end})
end

function add_mage(_x,_y)
add(mage,{
x=_x,
y=_y,
w=8,
h=14,
dy=0,
t=0,
flp=false,
dirc=-1,
update=function(self)
	self.dy+=.1
	self.y+=self.dy
	self.dy+=grav
	
	if collide_map(self,"down",0) then
		self.t+=1
		self.dy=0
		self.y-=(self.y+self.h)%8
	end
	
 if self.t>=80 then
 	self.dy=-4
 	self.t=0
		for i = 0,3 do
			add_particle(self.x+2,self.y+8,rnd(3)-1.5,-rnd(1)+.5,53,3,.2,7)
		end
 end
 
 if self.t==8 then
 	add_ball(self.x+1,self.y+6,self.dirc,-1)
 end
	
end,
draw=function(self)
spr(71,self.x+self.dirc*6,self.y,1,1,self.flp)
spr(72,self.x,self.y,1,1,self.flp)

if self.dy<0 then
spr(89,self.x,self.y+8,1,1,self.flp)
else
spr(88,self.x,self.y+8,1,1,self.flp)
end

end})
end

function add_ball(_x,_y,_dx,_dy)
add(ball,{
x=_x,
y=_y,
w=6,
h=6,
dx=_dx,
dy=_dy,
t=0,
lif=100,
update=function(self)
	self.y+=self.dy
	self.x+=self.dx
	
	self.lif-=1
	
	if collide_map(self,"right",0) or collide_map(self,"left",0) then
	 self.dx*=-1
	end

	if collide_map(self,"up",0) or collide_map(self,"down",0) then
	self.dy*=-1
	end
	
	if self.lif <= 0 then
	 del(ball,self)
	end
	
	self.t+=0.25
	if self.t>=2 then
		self.t=0
	end
end,
draw=function(self)
spr(73+self.t,self.x,self.y)

end})
end

function add_boss()
add(boss,{
x=992,
y=96,
w=16,
h=16,
t=0,
hp=8,
inv=false,
flp=true,
update=function(self)
self.t+=1

if self.t==1 then
	self.inv=false
end

if self.t<=4 then
	self.y-=4
else
	self.y=79
end

if self.t>=96 then
 self.y+=3*(self.t-96)
end

if self.t==136 then
	add_rock(904+rnd(104),12)
end

if self.t==164 then
	add_rock(904+rnd(104),12)
end

if self.t==192 then
	add_rock(904+rnd(104),12)
end

if self.t==224 then
	add_rock(904+rnd(104),12)
end

if self.t>=128 then
self.x=912+flr(rnd(3))*40
self.y=96
if not self.inv then
	self.t=0
	else
		if self.t>=256 then
			self.t=0
			self.inv=false
		end
	end
end

if self.hp<=0 then
	mbossfight=false
	mswitch()
	sfx(10)
	mset(122,10,27)
	mset(122,11,43)
	add_door(976,80,444,144,384,128,511,383,57,0,true)
	del(boss,self)
end

end,
draw=function(self)

	spr(66,self.x,self.y,2,2,self.flp)
	--for i=0,2 do
	--	spr(80,912+i*40,88,2,1)
	--end
	for i=0,2 do
		spr(80,912+i*40,88,2,1)
	end

 
end,
drawbar=function(self)
	if self.t<96 then
		for i=0,1 do
			spr(65,self.x+i*8,88,1,1,self.flp)
		end
 end
	
	for i=0,self.hp-1 do
		spr(56,928+(i*8),32)
	end
	

	
end})
end
--gone for 2 minutes lol
--me brother is blasting his 
--speaker next to me

function add_rock(_x,_y)
add(rock,{
x=_x,
y=_y,
w=8,
h=8,
dy=0,
bounced=false,
sfx(12),
update=function(self)
	if self.dy<2 then
	self.dy+=.2
	end
	
	self.y+=self.dy
	
	if collide_map(self,"down",0) and not self.bounced then
		self.dy=-2
		self.bounced=true
		sfx(4)
		for i = 0,4 do
			add_particle(self.x+2,self.y+2,-2+rnd(4),rnd(1)/4,4,1)
		end
	end
	
end,
draw=function(self)
spr(52,self.x,self.y)
end})
end

function add_explo(_x,_y,_let)
add(explo,{
x=_x-12,
y=_y-12,
w=24,
h=24,
t=0,
sfx(13),
update=function(self)
	
	for j=0,2 do 
		for i=0,2 do
			if fget(mget((self.x+i*8)/8,(self.y+j*8)/8),1) then
				
				if self.t==2 then
				if fget(mget((self.x+i*8)/8,(self.y+j*8)/8),6) then
					add_explo(flr((self.x)/8+i)*8+4,flr((self.y)/8+j)*8+4)
				end
				
				if fget(mget((self.x+i*8)/8,(self.y+j*8)/8),7) then
					add_heart(flr((self.x)/8+i)*8+1,flr((self.y+8)/8+j)*8+1,-1)
			 end
			 end
				
				if self.t==4 then
				mset((self.x+i*8)/8,(self.y+j*8)/8,0)
				sfx(4)
				
				for i = 0,2 do
					add_particle(self.x+16,self.y+16,-2+rnd(4),rnd(2)+0.5,4,1)
				end
				end
			end
		end
	end
	
 if self.t==1 then
 	for i=0,4 do
			add_particle(self.x+10,self.y+10,rnd(3)-1.5,rnd(3)-1.5,53,3)		
		end
 end
	self.t+=.5

	if self.t>=8 then
		del(explo,self)
	end

end,
draw=function(self)
--rect(self.x,self.y,self.x+24,self.y+24)
circfill(self.x+12,self.y+12,12-2*self.t,7)
end})
end

function add_tboss(_x,_y)
add(tboss,{
x=_x,
y=_y,
dx=0,
dy=0,
w=16,
h=12,
out=true,
t=0,
flp=false,
sliding=false,
float=false,
droppin=false,
hp=8,
ag=130,
update=function(self)
turtle_boss(self)

end,
draw=function(self)
if self.out then

	if self.hp<=4 then
		pal(8,2)
		pal(14,8)
	end

	if not self.flp then
		spr(70,self.x-4,self.y-4)--head
		spr(86,self.x-2,self.y+8)--leg1
		spr(87,self.x+10,self.y+8)--leg1
	else
		spr(70,self.x+12,self.y-4,1,1,true)--head
		spr(86,self.x+10,self.y+8,1,1,true)--leg1
		spr(87,self.x-2,self.y+8,1,1,true)--leg1
	end
	--print(self.t,camx+16,camy+16)
	pal(8,8)
	pal(14,14)

end

spr(68,self.x,self.y,2,2,self.flp)
--print(self.st,camx+24,camy+16)
end,
drawbar=function(self)
	for i=0,self.hp-1 do
		spr(56,camx+32+(i*8),camy+32)
	end
end
})
end

function add_fboss(_x,_y)
add(fboss,{
x=_x,
y=_y,
dx=0,
dy=0,
w=10,
h=24,
t=0,
flp=false,
dirc=-1,
hp=8,
gone=false,
dead=false,
update=function(self)
final_boss(self)

end,
draw=function(self)
	if not self.gone and not self.dead then
	spr(75,self.x-3,self.y,2,2,self.flp)
	
	if self.dy==0 then
		spr(107,self.x-3,self.y+16,2,1,self.flp)
	else
		spr(109,self.x-3,self.y+16,2,1,self.flp)
	end
	
	spr(90,self.x+(12*self.dirc)+1,self.y+7,1,1,self.flp)
	end
end,
drawbar=function(self)
	for i=0,self.hp-1 do
		spr(56,camx+32+(i*8),camy+32)
	end
	
end
})
end
-->8
--physics

function collide_map(obj,aim,flag)
	--obj = table x y w h
 --sets up hitbox
	local x=obj.x	local y=obj.y
	local w=obj.w	local h=obj.h
 
	local x1=0	local y1=0
	local x2=0	local y2=0

	if aim=="left" then
		x1=x-1	y1=y
		x2=x	y2=y+h-1
	elseif aim=="right" then
		x1=x+w-1	y1=y
		x2=x+w	y2=y+h-1
	elseif aim=="up" then
		x1=x+2	y1=y-1
		x2=x+w-3	y2=y
	elseif aim=="down" then
		x1=x+2	y1=y+h
		x2=x+w-3	y2=y+h
	end
	
	--pix to tiles
	x1/=8 y1/=8
	x2/=8	y2/=8
	
if fget(mget(x1,y1), flag)
or fget(mget(x1,y2), flag)
or fget(mget(x2,y1), flag)
or fget(mget(x2,y2), flag)	then
		return true
	else
		return false
	end

end

function hit(x,y,w,h,enx,eny,enw,enh)
	if (x+w>enx and x<enx+enw) and
		(y+h>eny and y<eny+enh) then
		-- there was a colision
		return true
	end
 return false
end


-->8
--player stuff
function player_update(obj)
	
	--if obj.kt==0 then
	obj.dy+=grav
	--end
	obj.dx*=obj.fric
	
	
	if btn(‹) and not obj.dropping then
		obj.dx-=obj.acc
		obj.flp=true
		obj.running=true
	end
	if btn(‘) and not obj.dropping then
		obj.dx+=obj.acc
		obj.flp=false
		obj.running=true
	end
	if btn(‹) and btn(‘) then
	obj.running=false
	end
	
	if obj.kt == 0 then
	if obj.running
	and not btn(‘)
	and not btn(‹)
	and not obj.jumping then
		obj.running=false
		obj.sliding=true
	end
	
	if btnp(ƒ) and dready==true and obj.ball and not obj.dropping and not collide_map(obj,"down",0) and obj.ready==true then
		obj.dropping=true
		obj.ready=false
		dready=false
		sfx(3)
	end
	
	if obj.dropping==true then
		obj.dy=8
	end

	if btn(—) and xready
	and obj.landed then
		sfx(0)
		xready=false
		obj.ready=true
		obj.dy-=obj.boost
		obj.landed=false
		if not obj.ball then
			for i = 0,3 do
				add_particle(obj.x+2,obj.y+8,rnd(3)-1.5,-rnd(1)+.5,53,3)
			end
		end
	end
	
if obj.dy<0 and not btn(—) then
		obj.dy = max(obj.dy,-obj.boost/3) 
	end
	end
	--check collision
	if obj.dy>0 then
		obj.landed=false
		obj.jumping=false
		obj.falling=true
		if kt==0 then
		obj.dy=limit_speed(obj.dy,obj.maxdy)
		end
		
	if collide_map(obj,"down",0) then
		obj.falling=false
		obj.landed=true
		
		obj.y-=(obj.y+obj.h)%8
		
		if obj.dropping then
			for i = 0,8 do
				add_particle(obj.x,obj.y,-1+rnd(2),rnd(1)/4,53,3)
			end
			obj.dropping=false
		end	
		
		if obj.ball then
			obj.dy=-abs(obj.dy*.2)
		else
			obj.dy=0
		end
	end
	elseif obj.dy<0 then 	
	obj.jumping=true
	if collide_map(obj,"up",0) then
		obj.dy=0
	end	
	end
	-- l r colision
	if obj.dx<0 then
		
		obj.dx=limit_speed(obj.dx,obj.maxdx)
	
		if collide_map(obj,"left",0) then
			obj.dx=0
		end
	elseif obj.dx>0 then
	
	obj.dx=limit_speed(obj.dx,obj.maxdx)
		
		if collide_map(obj,"right",0) then
		--	obj.x-=(obj.x+obj.w)%8
			obj.dx=0
		end	
	end
	
	--stop sliding
	if obj.sliding then
		if abs(obj.dx)<.2
		or obj.running then
			obj.dx=0
			obj.sliding=false
		end
	end
	
		--stop bouncing
	if obj.ball then
		if abs(obj.dy)<.21 then
			obj.dy=0
		end
	end

	
	obj.x+=obj.dx
		if wind then
	obj.dx+=wdir
	end
	obj.y+=obj.dy
	
end
	
	--limitspeed
function limit_speed(num,maximum) 
 return	mid(-maximum,num,maximum)
end

function knockback(obj,_dx,_dy)

	if obj.kt > 0 then
		obj.kt-=1
	end

end

function player_animate(obj)
	if obj.jumping or obj.falling then
		obj.sp=3
	elseif obj.running or obj.sliding then
		if time()-obj.anim>.1 then
			obj.anim = time()
			obj.sp+=1
			add_particle(obj.x+2,obj.y+8,rnd(1)-.5,rnd(1)-.5,53,3)
			--add_explo(obj.x+4,obj.y+7,false)
				if obj.sp>2 then
					sfx(2)
					--add_particle(obj.x+4,obj.y+14,1,1,53,3)
					obj.sp=1
				end
			end
		else --playr idle
			obj.sp = 1
		end
	end
	
function ball_animate(obj)
 if obj.dropping then
 	obj.sp=48
		elseif abs(obj.dx)>0 or abs(obj.dy)>.2 then
			if time()-obj.anim>.1 then
				obj.anim = time()
				obj.sp+=1
				if obj.sp>33 then
						--sfx(2)
					obj.sp=32
				end
			end
			else --playr idle
				obj.sp = 32
		--end
	end
end
-->8
--extra player functions
function switch(obj)
	if btnp(Ž) and oready and obj.dy>-3 then
		if obj.ball==false then	
			obj.ball=true
			obj.sp=32
			obj.y+=6
			oready=false
		else
		 if not collide_map(obj,"up",0) and not obj.dropping then
				obj.ball=false
				obj.sp=1
				obj.y-=6
				oready=false
			end
		end
		sfx(1)
	end
end

--groundpounding 
function breakblock(obj)

	if obj.dropping and collide_map(obj,"down",1) then
		if btn(—) then
			obj.dy=-obj.boost
		else
			obj.dy=-abs(obj.dy/2)
		end
		
		obj.dropping=false
		obj.ready = true
		
		breaking(obj,2,8)
		breaking(obj,6,8)
	end	
	
	if obj.jumping and collide_map(obj,"up",1) and not obj.ball then
		obj.jumping=false
		obj.dy=3	

		breaking(obj,2,-4)
		breaking(obj,6,-4)

	end
end

-- a very complicated function for breaking blocks and making objects spawn
function breaking(obj,_xt,_yt)
	if fget(mget((obj.x+_xt)/8,(obj.y+_yt)/8),1) then
		if fget(mget((obj.x+_xt)/8,(obj.y+_yt)/8),7) then
			add_heart(flr((obj.x+_xt)/8)*8+1,flr((obj.y+8)/8)*8-8,-1)
		end
		if fget(mget((obj.x+_xt)/8,(obj.y+_yt)/8),5) then
			add_armor(flr((obj.x+_xt)/8)*8+1,flr((obj.y+8)/8)*8-8,-1)
		end
		if fget(mget((obj.x+_xt)/8,(obj.y+_yt)/8),6) then
			add_explo(flr((obj.x+_xt)/8)*8+4,flr((obj.y+_yt)/8)*8+4)
		end
		mset((obj.x+_xt)/8,(obj.y+_yt)/8,0)
		sfx(4) --jump
		for i = 0,4 do
			add_particle(obj.x-2,obj.y-6,-2+rnd(4),rnd(2)+0.5,4,1,.15)
		end
	end
end


--camera function
function camra(obj,_x,_y,_xm,_ym)
camx=flr(obj.x)-60
camy=flr(obj.y)-64

if not obj.ball then 
camy+=6
end

if camx<=_x then
camx=_x
end

if camy<=_y then
camy=_y
end

if camx+127>=_xm then
camx=_xm-127
end

if camy+127>=_ym then
camy=_ym-127
end

camera(camx,camy)

end
-->8
--enemy stuff
function spawn_enemies()
	
--spawn enemies
	for i=camax1,camax2 do
	 for j=camay1,camay2 do
   if mget(i/8, j/8) == 49 then
    add_turtle(i,j)
    mset(i/8, j/8, 0)
	  end
	  if mget(i/8, j/8) == 34 then
    add_mole(i,j)
    mset(i/8, j/8, 0)
	  end
	  if mget(i/8, j/8) == 71 then
    add_mage(i,j)
    mset(i/8, j/8, 0)
	  end
	  if mget(i/8, j/8) == 66 then
    add_boss(i,j)
    mset(i/8, j/8, 0)
    mswitch()
    mbossfight=true
	  end
	  if mget(i/8, j/8) == 70 then
    add_tboss(i,j)
    mset(i/8, j/8, 0)
    mswitch()
    mbossfight=true
	  end
	  if mget(i/8, j/8) == 90 then
    add_fboss(i,j)
    mset(i/8, j/8, 0)
    mswitch()
    mbossfight=true
	  end
	 end
	end

end



function turtle_move(obj) 
	obj.t+=.2
	obj.x+=obj.dx
	obj.y+=obj.dy
	obj.dy+=grav
	
	if collide_map(obj,"down",0) then
		if obj.flp then
			obj.dx=obj.wsp
		else
			obj.dx=-obj.wsp
		end
		
		if collide_map(obj,"right",0) then
		obj.flp=false
		end
		
		if collide_map(obj,"left",0) then
		obj.flp=true
		end		
		
		obj.dy=0
		obj.y-=(obj.y+obj.h)%8
	end
--animation
	if obj.t>obj.tmax then
		obj.t=0
 end
end

function draw_back()
	for i=flr(camax1/8),flr(camax2/8) do
	 for j=flr(camay1/8),flr(camay2/8) do
	 	spr(back_spr,i*8,j*8)
	 end
	end
end

function set_doors()
--add_door( x,  y, gx, gy, cx, cy,cmx,cmy,back_spr,back_col,checkpoint?)

 add_door(216, 88,288, 88,256,  0, 895,127,     57,0,true)
--add_door(216, 88,288, 88,256,  0,1023,127,     10)
	add_door(856, 72,224,328,  0,128, 255,383,     57,0,true)
 add_door(352,208,956, 48,896,  0,1023,127,     57,0,false)
--	add_door(216, 88,400,472,384,384,511,511,0,12,true) --secret door
 --add_door(240, 80,280,336,256,256,	383,383,					57,0,true) --secret door
	add_door(144,160,280,200,256,128, 383,255,     57,0,true)
--	add_door(976,	80,444,144,384,128,	511,383,					57,0,true) --secret door
	add_door(448,336,528,336,512,128,	767,383,					57,0,true)
	add_door(552,160,280,336,256,256,	383,383,					57,0,true)
	add_door(352,336,288,456,256,384,	383,511,					59,0,false)
	add_door(824,152,400,472,384,384,	511,511,						0,12,true)
	add_door(488,456,568,456,520,384,	759,511,						0,12,false)
end
-->8
--complicated stuff
function final_boss(self)
	
	self.x+=self.dx
	self.y+=self.dy
	self.dy+=grav
	self.t+=1
	
	self.dx*=0.9
	self.dy*=0.9
	
	if collide_map(self,"down",0) then
		self.dy=0
		self.y-=(self.y+self.h)%8
	end
	
	if collide_map(self,"left",0) or collide_map(self,"right",0) then
			self.dx=0
		end
	
	if abs(self.dx)<.2 then
		self.dx=0
	end
	
	if self.t==100 and not self.gone then
		self.dy=-8
		if self.x<=camax1+127 then
			self.dx=6+rnd(3)
		else
			self.dx=-(6+rnd(3))
		end
		self.t=0
	end
	
	if self.t>=40 and self.dead then
		del(tboss,self)
		mswitch()
		musicloop(15,1240)
		if mode=="normal"   then ndone=1 dset(1,1) end
		if mode=="speedrun" then sdone=1 dset(2,1) if sptime<quicktime then quicktime=sptime dset(0,quicktime) end end		
		if mode=="hardcore" then hdone=1 dset(3,1) end		
		finished=true
		screen="end"
		
		--_init()
	end
	
	if self.hp>0 and #mage<=0 and self.gone then
		self.t=0
		if camx+60>=camax1+120 then
			self.x=528
			wind=true
			wdir=.35
		else
			self.x=736
			wind=true
			wdir=-.35
		end
		self.gone=false
	end
	
	if self.hp<=0 and not self.dead then
		
  sfx(10)
		wt=false
		self.dead=true
		self.t=0
	end
	
end

function storm()
--local 
local tran=0

if camax1>=384 and camax1<=760 and camay1>=384 then
bwind=true
else
bwind=false
end
if wind or bwind then

if wst==0 then
if wind then
sfx(14)
end
end
wst+=1
if wst>16 then
wst=0
end
--wst+=1

if wdir<0 then
tran=camx+128
else
tran=camy-8
end
if wind then
	for i=0,2 do
	add_particle(tran,camy-8+rnd(128),13*wdir+rnd(1)-.5,rnd(2)-1,15,1,.01,15)
	end 
end
if bwind then
	for i=0,1 do
	add_particle(tran,camy-8+rnd(128),12*wdir+rnd(1)-.5,rnd(1)-.5,15,1,.01,13,true)
	end
end
end



end

function turtle_boss(self)
 local svar=1--for bounce variable
 --local ag=130--attackspeed
 
	self.x+=self.dx
	self.y+=self.dy
	
	self.t+=1
	if not self.sliding and not self.float and not self.dropping then
	self.dy+=grav
	end
	
	if self.float then
	 self.dx*=0.9
	 self.dy*=0.9
	 
	 if abs(self.dx)<.05 and abs(self.dx)<.05 then
			self.float=false
			self.dropping=true
			sfx(3)
	 end
	end
	
	if collide_map(self,"down",0) then
		self.dy=0
		self.y-=(self.y+self.h)%8
	end
	

	
	if self.t==self.ag then
		self.out=false
		sfx(1)
	end
	
	if self.t==self.ag+20 then
		self.sliding=true
		sfx(3)
	end
	
	
	if self.sliding then
		if collide_map(self,"right",0) then
		 self.flp=false 
		 --self.dx=-5
		end
		if collide_map(self,"left",0) then
			self.flp=true
			--self.dx=5
		end
		if collide_map(self,"left",0) or collide_map(self,"right",0) then
			self.dy=-7
			self.sliding=false
			self.float=true
			svar=.4+rnd(1)
			sfx(4)
		end
		add_particle(self.x+6+rnd(4),self.y+8+rnd(4),rnd(1)-.5,rnd(1)-.5,53,3,.2,7)

		if self.flp then
			self.dx=5*svar
		else
			self.dx=-5*svar
		end
	end
	
	if self.dropping then
		self.dy=7
		self.dx=0
		
		if collide_map(self,"down",0) then
			sfx(4)
			self.dy=0
			self.dropping = false
			self.out=true
			for i=0,2 do
				add_rock(camx+24+rnd(80),camy+10)
			end
		
			for i=0,10 do
				add_particle(self.x+6+rnd(4),self.y+12,rnd(4)-2,rnd(3)-2,53,3,.2,7)
			end
			self.t=0
		end
	end	
	
	if self.out then
	 self.h=16
	else
		self.h=12
	end

	if self.hp<=0 then
	 mbossfight=false
	 mswitch()
		sfx(10)
		mset(41,57,27)
		mset(41,58,43)
		add_door(328,456,792,472,768,120,895,511,57,0,true)
		del(tboss,self)
	end
	
		pal(8,8)
		pal(14,14)
	
end

function printp(_t,_x,_y,_c,_s)
for ix=0,2 do
for jy=0,2 do
print(_t,_x-1+ix,_y-1+jy,_s)
end end
print(_t,_x,_y,_c)
end

function musicloop(_b,_dt)
	if mt<=0 then
		music(_b,12)
		mt=_dt
	end
end

function mswitch()
	music(-1)
	mt=0
end

--ey hello player dont mind me 
--im just finishing up my code
__gfx__
0000000000000000000000000000000000044000ffffffff99999999ffffffffffffffffffffffff444244420060006022222222222550000005522200000000
00000000003333000000000000333300004994009999999994444442f9999999999999999999999f244424440675067528688868282776600667728200000000
00000000033333300033330003333330004494004444444494222942f9444444444444444444449f424442440675067522222222262667766776626200770000
00000000033a1a1003333330033a1a10049940009499949994244942f9499499949994999499949f442444245766576657665766282665500556628200000000
0000000003aa1a10033a1a100a3a1a1a044940004999499994244942f9494999499949994999449f444244425766576657665766282550000005528200000000
0000000000aaaaa903aa1a100a3aaaa9044400004444444494999942f9449994999499949994949f244424442222222205755575282776600667728200000000
0000000003aaaaa000aaaaa93aaaaaaa000000009999999994444442f9499949994999499949949f424442442868886805750575262667766776626200000000
000000003aa9999a03aaaaa03aa9999a00000000ffffffff92222222f9499499949994999499949f442444242222222200500050282665500556628200000000
13a900003aaaaaaa3aa9999a3aaaaaaa03303300fffffffffffffffff9494999499949994999449faaaaaaaa0000000000000044440000000011110000000033
249f00003aa9999a3aaaaaaa33a9999037737a309999999f99999999f9449994999499949994949fa949949400777700000004292940000001313310000003b3
128efd001a3aaaaa3aa9999a13aaaaa037aaaa304444449f44444444f9499949994999499949949fa49449a407111170004444444444444013313311000003b3
1def0000133aa9931a3aaaaa01aaa9903aaaa9309499949f94999494f9499499949994999499949fa49999a471111117004f99f99f99f9401131113100003b30
0000000001aaa990013aaa9300aaa99003aa93004999449f49994994f9494999499949994999449fa49999a47111111700044444444444001311133133003b30
0000000000aa990003aa099133aa9990003930004444449f99949994f9449994999499949994949fa9a99a94711111170000000000000000133313313b33b300
00000000003311003330011133a00911000300009999999f99499944f9499949994999499949949fa99aa9947111111700000000000000000131331003bb3000
0000000000333110033301103000011000000000ffffffff44444444f9499499949994999499949fa44444447111111700000000000000000011110000330000
0033310000313300000000000000000000dddd00ffffffff49994994f9494999499949994999449fee82ee827111111703303300000000000000000000000000
013331300331333000000000000000000dd1d1d0f999999999949994f9449994999499949994949fe82188217111111731131130000000000000000000000000
331331333331333300000000000000000dddeddef944444499499944f9499949994999499949949fe82188217111111731111130000000000000000000000000
33311333111111110000000000dddd000ddddee0f949949994999494f9499499949994999499949f7ffefffe7111111731111130000000000000000000000000
3331133333311333000000000dd1d1d00dddeddef949499949994994f9494999499949994999449f7ffefffe7111111703111300000000000000000000000000
1113313333331333000000000dddedde0dddddd0f944444499949994f9444444444444444444449fe82188217111111700313000000000000000000000000000
0333331003331330055555500000000000000000f999999999499944f9999999999999999999999fe82188217111111700030000000000000000000000000000
00333300003313005d5d5dd50000000000000000ffffffff44444444ffffffffffffffffffffffff222122217111111700000000000000000000000000000000
000330000eee00000000000000000000000990000077000000000000000000000110110011101110777777770001000100000000000000000000000000000000
00133300ee1e00000eee000000000000099999900777700000770000000000001ee1e81001110111765665651010101000000000000000000000000000000000
03133110eeee0000ee1e000000000000094444207777770007777000007700001e88881010111011756556750100010000000000000000000000000000000000
033113300ee22200eeee220000022000994294227777770007777000007700001888821011011101756666750010001000000000000000000000000000000000
0331133000e828200ee8282000228200942449420777700000770000000000000188210011101110756666750001000100000000000000000000000000000000
01131330002282820022828202282820994494220077000000000000000000000012100001110111767667651010101000000000000000000000000000000000
00333100002222220022222202828220092222200000000000000000000000000001000010111011766776650100010000000000000000000000000000000000
00033000005000500005050000222200000220000000000000000000000000000000000011011101755555550010001000000000000000000000000000000000
000000000000000000002222222000000000001111100000008888000888000000000eff00ee0000008800000000000ee00ff000000000000000000000000000
000000000000000000028288828200000000112212211000011111808eee8000000fffef0e88e00008ee8000000000fffffef000000000000000000000000000
0000000000000000002888222888200000012221212221008e1e1ee88e8e800000ff1ff0e8ee8e008e88e80000000f1111fef000000000000000000000000000
0000000000000000002888888888822000121212221212108eeeeee88eee8000dff1fff0e8ee8e008e88e8000000ff1f1ffef000000000000000000000000000
00000000000222000022222222222220012221222221221081111ee808884000fffffff00e88e00008ee80000000ff1f1fff0000000000000000000000000000
0000000000244420002441114111200001222122221212110888eee8000024000fffff0000ee0000008800000ddfffffffff0000000000000000000000000000
0000000000024420002444111118428012121212212221210008eee800000240000ff20000000000000000000dffffffffff0000000000000000000000000000
00000000000022000244444144148800112122211222121100008ee80000002400ff2a20000000000000000000ffffffffff0000000000000000000000000000
0000000000000000024444444488ee881d111212212111d10008eee88eeee800dffff222dffff22255500000000fffffffff0000000000000000000000000000
0000000000000000024444444444880011ddd111111ddd11008eeee88eeeee800dffff2a0dffff2a5675200000000111111a1000000000000000000000000000
0000000000000000024444444448428000111dddddd1110008eeeee808eeeee800ffff2200ffff2256665222dd000ffff1111100000000000000000000000000
00000000000000000244444444444200000001111110000008eeee8008eeeee800ff0ff20fff0ff257652444ddfffffffa111a00000000000000000000000000
0000000000000000024444444444420000000000000000008eeeee80008eeee800ff0ff04ff000f455500222dffffffff1111110000000000000000000000000
0055005505505500024444444444420000000000000000008eeee800008eeee80440440044000044000000000fffffffff1a1110000000000000000000000000
05dd55dd5dd5dd50024444444444420000000000000000008e8ee800008e8ee8000000000000000000000000000fffffff1111a0000000000000000000000000
5ddd5ddd55d5ddd502444444444442000000000000000000888888000088888800000000000000000000000000000eeefff11110000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000ffffff1a11000000ffffff1a11005505500
000000000000000000000000000000000000000000000000000333333300333300000011111000000700000000000fffffff11100000ffffffff111057757650
0000333330000000000000000000000000000000000000033333aa33a33033a330001111111110000070000000000ffffffff000000fffffffffff0057666650
00033aaa3330000000000000000000000003333330000033a333aa3aaa303aaa30011133333111000007000000000ffff0fff000040fffff00fffff056666d50
0033aaaaaa33333333300333333333300033aaaa3300003aaa33333aaa303aaa30111333333311100000700000000fff00fff00004fffff0000fffff0566d500
003aaaaaaaa33aaaaa3333aaa3aaaa33003aaaaaa300003aaa33a33aaa303aaa30111333333313110000070000000fff00fff00004ffff000000fff4005d5000
003aaa3aaaa33aaaaaa333aaaaaaaaa3033aaaaaa300003aaa3aaa3aaa303aaa31131133333113110000007000000fff00fff000004ff00000000f4000050000
033aa333aaa3aaaaaaa33aaaaaaaaaa333aaa33aa333333aaa3aaa3aaa303aaa3113311111113311000000070000444404444000000400000000440000000000
03aaa333aaa3aaa3aaa33aaaaaaaaaa333aa333aa333aaaaaa3aaa3aaa303aaa3113333111133311000000077000000000000000700000000011110000222200
33aaaaaaaaa3aa33aaa3aaa3aaaa3aaa3aaaaaaaaa3aaaaaaa3aaa3aaa303aaa311333311111331100000070700000000000000070000000001fff00002fff00
3aaaaaaaaaa3aaaaaa33aaa3aaaa3aaa3aaaaaaaaa3aaa3aaa3aaa3aaa333aaa31133111331133110000070070000000000000007000000000f1f10000f1f100
3aaa33aaaaa3aaaaaaa3aaa33aa33aaa3aaa33aaaa3aa33aaa3aaa3aaa333aaa33111113333133110000700070000000000000007000000000ffff0000ffff00
3aaa33333aa3aaa3aaa33aa33aa33aaa3aaa3333aa3aa33aaa3aaaa3aaaa33aaaa1133333331311000070000700000000000000070000000077777700ddd5dd0
3aaa3003aaa3aaa33aaa3aa33aa33aaa3aaa3003aa3aaaaaa333aaa3aaaa33aaaaa1133333111100007000007000000000000000700000000f7777f00ddd5dd0
3aaa3003aaa3aaa333a33aa33aa33aaa3aaa3003aa33aaaa33333a333aaaa33aaaa3111111111000070000007000000000000000700000000fccccf00f1111f0
333330033333333303333333333333333333300333033333300333303333333333333011111000007000000077777777777777777000000000c00c0000100100
91000000000000000000600000000000000000708090000000000000000000718181818181818181818181818181818191000000000000000000000000000071
910013000000000062a2000000000000000000000000000000728281818181719100000000000000000000000000e07100008181810000000000000000000000
91000000000000000052505080808080808080808080808080808080808080818182828282828282828282828282828191000000000000000000000000000071
910000a10000a10062a200000000000000000000000000000000007282828271910000002222000000a2a2000000e07100000000000000000000000000000000
910000000000000000000000728282828282828282818181818181818181818191a2a2a2a2a2a2a2a2a2a2a2a2a2a27191000000000000000000000000000071
910000000000000062a2000000000000000000000000000000000000000000719100000052510000000000000000e0710000f700e70000000000000000000000
910000000000000000000000000000000000000000728281818181818181818191a26060a160a16060a160a16060a27191000013000000007400000013000071
910000000000000062a2a200000000000000a25251a2000000000000000000719100000000000000000000000000e07100000000000000000000000000000000
818080510000000000000000000000000000000000000072818181818181818191a2600000000000000000000060a27191000000000000000000000000000071
81808080808080808080808080808090000000a2a200000000000074000000719100000000000000000000000000528100000000000000000000000000000000
818292000000000000000000000000000000000000000000728181818181818191a2600000000000000000000060a27191606060605280808080516060606071
81818181818181818181818181818192000000000000000000000000000000719100130000001300000000000000007100000000000000000000000000000000
910000000000220000000000000000000000000000000000007282828282828191a2600000000000000000000060a2719160a260a1607281819260a260a16071
81818181818181818181818181819200000000000000000000a25251a20000719100000000000000000060000000007100000000000000000000000000000000
910000000052505051000000002200000000000000000000000000000000007191a2600000000000000000000060607191606060606060729260606060606071
8182828282828282828181818292000000000000000000000000a2a2000000719180808080808080808090000000007100000000000000000000000000000000
91000000000000000000000052505051000000000000000000000000000000719100000000000000000000000000007191000000000000000000000000000071
91000000000000000071819100000000000000000000000000000000000000719182828282828282828292000000007100000000000000000000000000000000
91000000000000000000000000000000000000220000000000000000000000719100000000000000000000000000007191000000000000000000000000000071
910000000000000000718191000000000000000000222200000000000000007191c0c0c0c0c0c0c0c0c060000000007100000000000000000000000000000000
91a1000000000000000000000000000000007080900000000000000000000071910000000000000000000000b10000719174001300000000b100000013000071
91000000000000000072829200000000000000a2a25251a2a2000000000000719100000000000000000000000000007100000000000000000000000000000000
8180808090000000000000000000000000007181910000007080808080808081910000000000000000000000b20000719100000000000000b200000000000071
9100000000000000a2a2a2a20000000000000000a2a2a2a200000000000000719100000000000000000000525100007100000000000000000000000000000000
8181818191b0b0b0b0b0b0b0b0b0b0b0b0b0718191b0b0b071818181818181818180808080808080808080808080808181808080808080808080808080808081
81808080808080808080808080808080809000000000000000000000000000719100000000000000000000000000007100000000000000000000000000000000
81818181818080808080808080808080808081818180808081818181818181818181818181818181818181818181818181818181818181818181818181818181
818181818181818181818181818181818191b0b0b0b0b0b0b0b0b0b0b0b0b0719100000000000000000000000000007100000000000000000000000000000000
81818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181
81818181818181818181818181818181818180808080808080808080808080819100000000000000000000000000007100000000000000000000000000000000
81818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181
81818181818181818181818181818181818181818181818181818181818181819100000000000000000000006161708181818181818181818181818181818181
0000000000000000000000a7a6000000000000000000000000000000000000008182828282828282828282828282828100000000000000000000000000000000
040000000000000000000000000000000000000000000000000000000000000491000000000022222222006162a1718100000000000000000000000000000000
0000000000000000000000a600a60000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000000000
04000000000000000000000000000000000000000000000000000000000000048190000000007080808080808080818100000000000000000000000000000000
00000000000000000000d700a6a70000000000061626364656667686960000009100000000000000000000000000007100000000000000000000000000000000
04000000000000000000000000000000000000000000000000000000000000048192000000528282828282828282828100000000000000000000000000000000
000000000000000000a6b7c700000000000000071727374757677787970000009100000000000000000000000000007100000000000000000000000000000000
04000000000000000000000000000000000000000000000000000000000000049100000000000000000000000000007100000000000000000000000000000000
00000000000000a70000a60000000000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000000000
04000000000000000000000000000000000000000000000000000000000000049100130000000000000000000000007100000000000000000000000000000000
00000000000000a60000000000000000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000000000
04000000000000000000000000000000000000000000000000000000000000049100000000000000000000001300007100000000000000000000000000000000
0000000000a70000a6a7000000000000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000000000
04000000000000000000000000000000000000000000000000000000000000049100000000000000000000000000007100000000000000000000000000000000
0000000000a6a7000000000000000000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000000000
040000000000000000000000000000000000a5000000000000000000000000048180805100002222000000000000007100000000000000000000000000000000
000000000000a6a70000000000000000000000000000000000000000000000009100000000000000000064000000007100000000000000a30000000000000000
0400000000000000000000000000000000000000000000000000000000000004818192a16060525160a160605280808100000000000000000000000000000000
000000a6000000000000000000000000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000b10000
040000000000000000000000000000000000000000000000000000000000000481926060a26060606060a2606072828100000000000000000000000000000000
00a7a600a6a700000000000000000000000000000000000000000000000000009100000000000000000000000000007100000000000000000000000000b20000
04000000000000000000e070808080808080808090d0000000000000000000049100000000000000000000000000007100000000000000000000000000000000
00a6a7a6000000000000000000000000000010000000000000000000006000009100005250505050505050505100007100000000000000000000708080808080
0400000000e07080808080818181818181818181818080808090d000000000049100000000000000000000000000007100000000000000000000000000000000
a600a600000000000000000000000000000011000000000000000000606060009100000000000000000000000000007100000000007080808080818181818181
04708080808081818181818181818181818181818181818181818080808090049100000000000000000000000000007100000000000000000000000000000000
00a60000000000000000000000000000808080808080808080808080808080809100000000000000000000000000007180808080808181818181818181818181
04718181818181818181818181818181818181818181818181818181818191048180808080808080808080808080808100000000000000000000000000000000
a6a700000000000000000000000000008181818181818181818181818181818191b0b0b0b0b0b0b0b0b0b0b0b0b0b07181818181818181818181818181818181
04718181818181818181818181818181818181818181818181818181818191048181818181818181818181818181818100000000000000000000000000000000
00000000000000000000000000000000818181818181818181818181818181818180808080808080808080808080808181818181818181818181818181818181
04718181818181818181818181818181818181818181818181818181818191048181818181818181818181818181818100000000000000000000000000000000
__gff__
0000000000010301010100050509090000000000000103010101830000000000000000000001030101014300000000000000000000000000000023000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1940404040404040404040404017194040404040404040404040404040404040181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818282828282828282828282828282818
19000000000000000000000000171900000000000000000000000000000000001818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818182828282828281818181818181818181818181818181818181818181818190c0c0c0c0c0c0c0c0c0c0c0c0c0c17
1900000000000000000000000017190000000000000000000000000000000000181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181829000000000000171818181818181818181818181818181818181818181819000000000000000000000000000017
1900000000000000000000000017190000000000000000000000000000000000182828282828282828282828282828282828282828282828181818181818181818182828282828282828282828181818182900000000000000171818282828282828282828282828282828282828281819000000000000000000000000000017
1900000000000000000000000017190000000000000000000000000000000000190000000000000000000000000000000000000000000606272828282828282828290000000000000000000000272828290000000000000000171819000000000000000000000000000000000000001719000000000000000000000000000017
1900000000000000000000000017190000000000000000000000000000000000190000310000310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000171819000000000000000000000000000000000000001719000000000000000000000000000017
1900000000000000000000000017190000000000000000000000000000000000190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000171819000000000000000000000000000000000000001719000000000000000000000000000017
1900000000000000000000000027290000000000000000000000000000000000180808080808080808080900000000000000000000000606000000000000000000000000000000000000000000001a00000000000709060606171819000000000000000000000000000000000000001719000000000000000000000000000017
190000000000000000000000000a0a0000000000000000000000000000000000181828282828282828282815060606070900000000000606000025050505080809000000000000000000000000000000000000071819000000171819000000000000000000000000000000000000001719000000000000000000000000000017
19000000000000000000000007080809000000000000000000000000000000001819000000000000000000000000001718090000000006060000000000001718180900000000000000000000000000000000071818190000001718190000000600220000002200000000001b0000001719000000000000000000000000000017
19000000000000000000000617181819060606060000000000060606060600001819000000000000000000000000001718180900000006062505051500001718181808090000250515000000000708080808181818190000001718190000070808080816080809002200002b0022001719000000000000000000000042000017
1900000000000000000006061718181906060606060000000006061b06060000181900000000000000000000000000171818180900000000003100000031171818181819000000000000000000171818181818181819000000272829000017181818182618181808080808080808081819005051000000505100000050510017
1808080808080808080808080808080808080808080808080906062b06060708181808080808080808080808080808181818181808080808080808080808181818181819000000000000000000171818181818181819222222000000000017181818182618181818181818181818181818080808080808080808080808080818
18181818181818181818181818181818181818181818181818080808080818181818181818181818181818181818181818181818181818181818181818181818181818190b0b0b0b0b0b0b0b0b171818181818181818080808080808080818181818181a18181818181818181818181818181818181818181818181818181818
1818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818080808080808080808181818181818181818181818181818181818181818181a18181818181818181818181818181818181818181818181818181818
1818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818
1818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181828282828282828282828282828281818282828282828282828282828282828282828282828282828282828282828181828282828282828282828282828281800000000000000000000000000000000
182828282828282828282828282828282828282828282828282828282828281818181818181818181818181818181818190000000000000000000000000000171900000000000000002a0000000000000000000000000000000000000000001719000000000000000000000000000e1700000000000000000000000000000000
190000000000000000000000000000000000000000000000000000000000001718282828282828282828282828282818190000000000000000000000000000171900000000000000002a000000000000000000000000000000000000003a001719000000000000000000000000000e1700000000000000000000000000000000
190000000000000000000000000000000000000000000000000000000000001719000000000000000000000000000017190000000000000000000000000000171900000000004700002a00000000000000000000000000000000000047000017190000000000001b0047000000000e1700000000000000000000000000000000
1900000000000000000000000000004700001b00004700000000000000000017190000000000000000000000000000171900000000000000000000000000001719000000001b0000002a00000000000000000000000000000000000000000017191a00000000002b0000000000000e1700000000000000000000000000000000
1900000000000000000000000000000000002b0000000000000000000000001719000000000000000000000000000017192a0606062508080808150606062a1719000000002b0000002a0000000000000000000000000000000000250808081719000000002508080815000000000e1700000000000000000000000000000000
1900000022000000000000000000250808080808080815000000000000000017190000000000000000000000000000171906061a06062718182906061a0606171900002508080815002a25150000222200000000000000002a2a00002728281719000000000027282900000000000e1700001800180018180018181800180000
190000250505150000000000000000272828282828290000000000000000001719000000000000000000000000000017192a0606062a062729062a0606062a171900000027282900002a0000002a25152a00000000000000000000000000001719000000000000000000000000000e1700001800180018000018001800180000
19000000000000000000000000000000000000000000000000000000000000171900000000001a00001a000000000017190000000000000000000000000000171900000000000000002a000000002a2a0000000000000000000000000000001718051500000000000000000000000e1700001818180018180018001800180000
190000000000000000000000000000000000000000000000000000000000001719000000000000000000000000000017190000000000000000000000000000171900000000000000002a0000000000000000000000000000000000000000001719000000000000000000002515000e1700001800180018000018001800180000
19000022000000000000000000000000000000000000000000000022000000171900000000000000000000001b00001719000000000000000000000000000017190b0b0b0b0b0b0b0b2a0b0b0b0b0b0b0b00002515000000000000000000001719000000000000000000000000000e1700001800180018180018001800181800
19080808080505051500000000000000000000000000002508080808150000171900000000000000000000002b000017192200002200000000000022000022171808080808080808092a0708080808080900000000000000000000000000001719000000000025051500000000000e1700000000000000000000000000000000
19282828290000000000000025080808081500000000000027282829000000171808080808080808080808080808081819080808092a060606062a07080808171818181818181818192a1718181818181900000000000000000000000047001719002222000000000000004700000e1700001818180000000000000000000000
19000000000000000000000000272828290000000000000000000000000000171818181818181818181818181818181819181818290606062a060627181818171818181818181818192a1718181818182900000000000000000000000000001719002515000000000000000000000e1700001800180000000000000000000000
190000000000000000000000000000000000000000000000000000000000001718181818181818181818181818181818191818290606062a06060606271818171828282828282828292a2728282828290000000000000000070808080808081719000000000000000000002515000e1700001800180000000000000000000000
19000000000000000000000000000031000000000000000000003100000000171818181818181818181818181818181819282906062a060606062a06062728171900000000000000262a0000000000000000000000000000271818181818181719000000000000000047000000000e1700001800180000000000000000000000
__sfx__
010100001a1301a1301a1301f1302013024130201301a1302010024100201001a100250002300024000250002200023000230002a0002a0000000000000000000000000000000000000000000000000000000000
00010000160501c0502105021050210502105022050230502a0502d0502c050260501d0501c050190501905018050160501505018000160001500000000000000000000000000000000000000000000000000000
00010000241201d1201d1201800014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000196502e6502f0503405034050340502f0502d050290501d0501d0501115010150101500d1500a1500a150091500815007150071500000000000000000000000000000000000000000000000000000000
000200002e6602d6602866026650236501e6501c650196501664014640106400e6400a630086300462002620026200161000610086000460002600016000060000600045003d5000000000000000000000000000
000100000f0201503017040180501a0501c0501e060240702f070320702d070220601c05017050110500d0400b040090300603007030060300603005020040200202002020020200202002020020200202002010
0001000000000251602716025160231601915019150161501415012140101400f1400e1400c1400b1400a140091300f1000610006100021000010005100031000310002100001000010000100000000000000000
00010000103501035010350113501135011350123501435015350153500000016350183501b3501c3501d3502135024350273502935029350000002b3502c3502d35000000000000000000000000000000000000
00010000183501c3501f3502135025350273502c3502e350313500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000001907015070120701407017060190601b0601e060210502305026050280502a0502c0502d0502f040300403104031040300403004031040340403503037030390303a0303b0203c0203d0203e010
0003000022160201701e1701a1701917019170171701617015170151601216011160101500e1500d1500c1400b1400a1400913008130071300612006120051200412004120031200311003110031200215002150
000100001857019560195601a560225001150025570235602356023560215601c56017500115600e5600b5500a550125000d5000a50011500065000450002500005000e5000c5000b50009500085000750005500
000200002c0502a0502905027050260502505024050230502305022050210502105020050200501f0501e0501d0501b0501b05019050180501705016050150501305012050100500f0500d0500c0500b05009050
000200001d05023050270502a0503707034070320703157023670226701f6701c6701a67018660166601566013660116500f6500e6500c6400a64009640086300762006610056100461003610016100161000600
00030000126300f6500f650106501265013650146501565016650176501765016650156501565013650136501264012640106400f6400f6300e6300d6300d6300d6400d6400d6400d6500e6500f6501165012650
0102000000000180001b0001f0002000022000350002400026000290002b0002d0002f0003300036000380003c000110001100011000120001200028100130001300014000150001600018000190001900000000
010f0000180001a0001c0001d0001f000210002300024000000002a00000000000000f000000001a00000000000001200000000000001d0000000000000000002000000000000000000000000000000000000000
01180020185500d5021d5521d55221550165022355000502185501d5001d5552953521550165022355000502175500d5021c5521c5521f550165022155000502175500d5021c555285351f550165022155221552
0118002018133006050000018133246353c1350000000605181330060500605006051864500000321000060518133006050060518133246353c13530625186151813300605006050060518645000003413500605
011800200c2450c2250020500205092000920000205002050c2450c2250020500205092450922500205002050b2450b2250020500205002050020500205002050b2450b225002050020507245072250020500205
01180000185500d5021d5501d50021550165022355000502185501d5001d5502950021550165022355000502175500d5021c5501c5001f550165022155000502175500d5021c550285001f550165022155021500
011800000000000000247451875524700187003b7253b7352472518735247001870024700187003b7253b73500000000002372517735237001770039725397352372517735237001770023700177003970039700
0118000018100006050000018100246353c1350000000605181000060500605006051864500000321000060518100006050060518100246353c13530625186151810000605006050060518645000003413500605
011f00000c0531d5031c535186233c615305000c0530000318535000000c053000033c615246130c003000030c0531d5031c525186233c615185030c05300003185251c5250c053000003c615186130c00300003
000c00000c05011050000000c600000000c60000000000000d050120500000000000000000000000000000000c050110500000000000000000000000000000000d05012050000000000000000000001205000000
011f00001a5001d5001c5000000021500000002100029000000001a5201d5201c52000000000001c5221c52221000290001c500000001d500000001f500000002100000000290001c520215201c5221d5221d522
011f00000c0501b0000c0500a050000000c0501b0000c0500a050000000c050000000c050000000c0501f0000c0501b0000c0500a050160000c0501b0000c0500a0501c000070500000007050000000705000000
001f000000500110400050000500000000000011040005000050011500005000050000500005001150000500005000f050005000050000500005000f050005000050000500005000050000500005000050000500
001f00000c0501b0000c0500a050000000c0501b0000c0500a050000000c050000000c050000000c0501f0000c0501b0000c0500a050160000c0501b0000c0500a0501c0000b050000000b050000000b05000000
001f00000000000000000000000000000000000000000000000001a5201d5201c52000000000001c5221c52200000000000000000000000000000000000000000000000000000001c5201d5201c5002152221522
010d0020103551c34513355133450f355003050e3551a305103551c34513355133450f355003050e3551a30510355003050e3551a3450f3550f3450e3551a3051a3551a34511355113451335500305153551a305
010d00201714300000171430000017143000001714300000171430000017143000001714300000171430000017143000001714300000171430000017143000001714300000171430000017143000001714300000
010d00200060500605306350060500605006053063500605006050060530635006050060500605306350060500605006053063500605006050060530635006050060500605306350060530635006003063518635
010d000010431104311343113431134311043117431174311c4311c4311f4311f4311f4311c43123431234310e4310e4311143111431114310e43115431154311a4311a4311d4311d4311d4311a4312143121431
000d00001f3201f320230001f3201f320000001f3201f32000000000000000000000000000000000000000001d3201d320230001d3201d320000001d3201d3200000000000000000000000000000000000000000
010d00002827528265282552824528235282252821528205002050020500205002050020500205002050020526275262652625526245262352622526215262050020500205002050020500205002050020500205
000d00001f3201f320230001f3201f320000001f3201f320000000000000000000000000000000000000000021320213202300021320213200000021320213200000000000000000000000000000000000000000
011f000029055290522100021001290552d052300550000029055290522100021001290552d05230055000002e0552e0522100000001240552e0522d055000002b0552b052210000000124055290522d05500000
011f00003c6003c60000000375353c6003c60000000246003c6003c60000000375353c6003c60000000246003c6003c6003c0003e535306003c60000000246003c6003c60000000355353c6003c6000000024600
011f0000291352911529135291152d1352d1152d1352d115291352911529135291152d1352d1152d1352d1152e1352e1152e1352e115241352413524135241152b1352b1152b1352b1152d1352d1152d1352d115
001f0000050650506500000000000500009000000000000005065050650000005000090000906500061000000a0650a06500000000000c000080000900000000070650706500000000000c000050650906100000
011f0000006050060500605006053c615006050060500605006050060500605006053c615006050060500605006050060500605006053c615006050060500605006050060500605006053c615006050060500605
011f000021122211221d100211221d1221d122000001d12221122211221d100211221f1221f1220000022122181221810018122181221d122161001d1221d122211220000021122211221f122000001f1221f122
001f000029000290002100021000290002d000300000000029000290002100021000290002d00030000000002e0552e0522100000001240552e0522d055000002b0552b052210000000124055290522d05500000
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
00 14 42 43 44
00 11 12 13 44
00 14 42 13 15
00 11 16 13 15
00 11 12 13 15
00 41 42 43 44
00 1a 1b 17 1d
00 1a 1b 17 19
00 41 42 43 44
00 1e 20 43 44
00 22 21 1f 20
00 22 21 1f 20
00 1e 1f 20 23
00 1e 1f 20 23
00 41 42 43 44
00 2b 26 27 28
00 25 26 27 28
00 41 29 27 28
00 2a 29 27 28
00 2a 29 27 28
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
