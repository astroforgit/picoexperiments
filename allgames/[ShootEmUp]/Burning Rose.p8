pico-8 cartridge // http://www.pico-8.com
version 7
__lua__

--grand train delta production 
--the burning rose v1.0
--artwork, sfx, code courtesy of grandtraindelta, @grandtraindelta
--music courtesy of gnarcade, @gnarcade_vgm 

--screen
screenwidth = 128
screenheight = 128
spriteradius = 8

--player
player = {}
player.id="player"
player.active = true
player.rotor = {}
player.rotor.anim = 0
player.rotor.dir = 1
player.x = 60
player.y = 100
player.bounds = 8
player.sprite = 0
player.speed = 2
player.bullets = 10
player.shootdelay = 0
player.shootdelaymax = 4
player.bombs = 3
player.bombtimer = 0
player.bombtimermax = 50
player.bombypos = 128
player.bombactive = false
player.animtimer = 0
player.spriteframe = 6
function player:init()
end
function player:collisionresolve(obj)
	if obj.id =="missile" then
		if(autobomb==true and self.bombs>0) then
			playerbomb()
		else
			if(player.bombactive == false) then
				self.active = false
				state_gameover.timer = 30
				state_gameover.active = 0
				state = state_gameover
				
				local amt = flr(rnd(8))+8
				for i=1,amt do
					local ex = getpoolobj(explosions)
					local b = 3+flr(rnd(5))
					local ang = flr(rnd(360))
					local spd = 2+flr(rnd(6))
					local v = getvelocity(ang,spd)
					ex:setup(self.x+rnd(4)-2, self.y+rnd(4)-2, b,0.5,v.x,v.y,180,200,8,2)
				end

				local ang = 0
				deathcirclepos.x = self.x
				deathcirclepos.y = self.y
				for p in all(deathcircles) do
					p:add(getvelocity(ang, p.speed))
					ang+=45
				end
				sfx(6)
				music(-1,200)
			end
		end
	end
end

--bullet
bullet = {}
bullet.id="pbullet"
bullet.x = 0
bullet.y = 0
bullet.bounds = 8
bullet.sprite = 1
bullet.speed = -7
bullet.active = false
function bullet:init()
end
function bullet:add(a)
	gameshots-=1
	self.active=true 
	self.x = player.x
	self.y = player.y
	sfx(0)
end
function bullet:draw()
	self.y+=self.speed
	if(self.y<0 or self.y>screenheight)then
		self.active = false
	end
	spr(self.sprite,self.x,self.y)
end
function bullet:collisionresolve(obj)
	if obj.id =="missile" then
		self.active = false
	end
end

--missile
missile = {}
missile.id="missile"
missile.x = 0
missile.y = 0
missile.bounds = 8
missile.sprite = 2
missile.speed = 2
missile.active = false
missile.animflame = 0
missile.spriteflame = 3
missile.turncircle = 0.5
missile.accel = 0
missile.maxaccel = 2
function missile:init()
	local x = spriteradius+flr(rnd(screenwidth-spriteradius*2))
	local y = spriteradius+flr(rnd((screenheight/2)-spriteradius*2))
	self.x = x
	self.y = y
	self.active = false
end
function missile:add(a)
	gamemissiles-=1
	self.turncircle = 0.01+rnd(1)
	self.maxaccel = 0.5+rnd(2)
	self.active=true 
	self.x = spriteradius+flr(rnd(screenheight-spriteradius*2))
	self.y = 0
	missilesactive += 1
end
function missile:draw()
	
	--missile
	self.y+=self.speed
	if(self.y>screenheight)then
		missilesactive -= 1
		self.active = false
		if(sessioncombo>=combo) then
			droppedcounter = 0
		end
		sessioncombo = 0
	end
	local dir = self.turncircle
	if player.x+5<self.x then
		dir = -self.turncircle
	end
	self.accel += dir
	if self.accel>self.maxaccel then self.accel = self.maxaccel end
	if self.accel<-self.maxaccel then self.accel = -self.maxaccel end
	self.x+=self.accel 
	spr(self.sprite,self.x,self.y)
	
	--flame
	self.animflame+=1
	if self.animflame>3 then
		self.animflame=0
		if self.spriteflame==3 then
			self.spriteflame = 4
		elseif self.spriteflame==4 then
		 self.spriteflame = 5
		elseif self.spriteflame==5 then
		 self.spriteflame = 3
		end
	end
	spr(self.spriteflame, self.x-1, self.y-5)
end
function missile:collisionresolve(obj)
	
	local explode = false

	if obj.id =="pbullet" then

		score += 1
		sessioncombo+=1
		if sessioncombo>combo then 
			combo = sessioncombo 
		end
		explode = true
	end
	if obj.id =="player" then
		explode = true
	end

	if explode == true then
		local amt = flr(rnd(3))+2
		for i=1,amt do
			local ex = getpoolobj(explosions)
			local b = 3+flr(rnd(5))
			local ang = flr(rnd(360))
			local spd = 2+flr(rnd(2))
			local v = getvelocity(ang,spd)
			ex:setup(self.x+rnd(4)-2, self.y+rnd(4)-2, b,0.5,v.x,v.y,100,200,5,4)
		end

		local ex = getpoolobj(explosions)
		local b = 3+flr(rnd(5))
		local ang = flr(rnd(360))
		local spd = 2+flr(rnd(2))
		local v = getvelocity(ang,spd)
		ex:setup(self.x+rnd(4)-2, self.y+rnd(4)-2, b,0.5,v.x,v.y,120,160,explosion.col1[1],explosion.col1[2])

		missilesactive -= 1
		sfx(1)
		self.active = false
	end

end

--explosion
explosion = {}
explosion.x = 0
explosion.y = 0
explosion.vx = 0
explosion.vy = 0
explosion.bounds = 8
explosion.speed = 0
explosion.colourouter = 4
explosion.colourinner = 9
explosion.col1 = {9,10}
explosion.active = false
explosion.life = 100
explosion.life2 = 100
explosion.decay = 20
explosion.decay2 = 15
function explosion:init()
end
function explosion:setup(x,y,bounds,speed,vx,vy,l1,l2,c1,c2)
	self.x = x
	self.y = y
	self.bounds = bounds
	self.speed = speed
	self.vx = vx
	self.vy = vy
	self.life = l1
	self.life2 = l2
	self.colourouter = c1
	self.colourinner = c2
end
function explosion:add()
	self.colourouter = 9
	self.colourinner = 10
	self.active = true
	self.life = 100
	self.life2 = 100
	self.bounds = 7+flr(rnd(3))
end
function explosion:position(p)
	self.x = p.x
	self.y = p.y
end
function explosion:draw()
	self.life-=self.decay
	self.life2-=self.decay2
	if self.life2<0 then self.active=false end
	local r = self.bounds*(self.life/100)
	local r2 = self.bounds*(self.life2/100)
	self.x+=self.vx*self.speed
	self.y+=self.vy*self.speed
	circfill(self.x, self.y, r2, self.colourouter)
	circfill(self.x, self.y, r-1, self.colourinner)
end

--prop
prop = {}
prop.x = 0
prop.y = 0
prop.animtrigger = 3
prop.animtimer = 0
prop.animframe = 1
prop.active = false
prop.bounds = 8
prop.sprite = 14
function prop:init()
end
function prop:add()
	self.x = proppos.x
	self.y = proppos.y
	self.active = true
	propwaters+=1
end
function prop:draw()
	self.animtimer+=1
	if self.animtimer>self.animtrigger then
		self.animtimer = 0
		self.animframe+=1
		if self.animframe>4 then
			self.animframe = 0
			self.active = false
			propwaters-=1
			return
		end
	end
	self.y+=gamespeed
	if(self.y<0 or self.y>screenheight)then
		self.active = false
		propwaters-=1
	end
	--spr(self.sprite, self.x, self.y)
	sspr(112,2*self.animframe,7,2, self.x, self.y)
end

--pdead
deathcircle = {}
deathcircle.x = 0
deathcircle.y = 0
deathcircle.vx = 0
deathcircle.vy = 0
deathcircle.speed = 1
deathcircle.decel = 1.02
deathcircle.life = 120
deathcircle.decay = 2
deathcircle.animtrigger = 2
deathcircle.animtimer = 0
deathcircle.animframe = 1
deathcircle.active = false
deathcircle.bounds = 8
function deathcircle:init()
end
function deathcircle:add(v)
	self.vx = v.x
	self.vy = v.y
	self.x = deathcirclepos.x
	self.y = deathcirclepos.y
	self.life = 100
	self.animtimer = 0
	self.animframe = 1
	self.active = true
end
function deathcircle:draw()
	self.animtimer+=1
	if self.animtimer>self.animtrigger then
		self.animtimer = 0
		self.animframe+=1
		if self.animframe>2 then
			self.animframe = 0
		end
	end
	self.life-=self.decay
	if self.life <=0 then
		self.active = false
	end
	self.vx *=self.decel
	self.vy *=self.decel
	self.x+=self.vx
	self.y+=self.vy
	if(self.y<0 or self.y>screenheight)then
		self.active = false
	end
	if(self.x<0 or self.x>screenwidth)then
		self.active = false
	end
	spr(15+self.animframe*16, self.x, self.y)
end

embers = {}
e = {}
e.x = 0
e.y = 0
e.vx = 0
e.vy = 0
e.svx = 5
e.svy = -1
e.colour1 = {9,4,2}
e.colour2 = {7,6,13}
e.anim = {0.5,0.7}
e.col = e.colour1
e.decay = 0.0001
e.active = false
e.t = 0

function getember(x,y,svx,svy,decay,col,anim)
	local ember = copy(e)
	ember.x = x
	ember.y = y
	ember.svx = svx
	ember.svy = svy
	ember.decay = decay
	ember.anim = anim
	ember.t = 0
	ember.col = col
	local still = flr(rnd(3))
	if still>1 then
		ember.active = true
	else
		ember.active = false
	end
	add(embers,ember)
end
function drawembers()
	local ecol = 0
	for e in all(embers) do
		e.t+=e.decay
		if e.t>1 then e.t = 1 end
		local percent = e.t/1*100
		local mi = e.anim[1]
		local ma = e.anim[2]
		if(percent>mi and e.active==true) then
			e.svx = -0.5+rnd(1)
			e.svy = -0.5+rnd(1)
		end
		if(percent>ma) then 
			ecol = e.col[3]
		elseif percent>mi then 
			ecol = e.col[2]
		else
			ecol = e.col[1]
		end
		e.vx += e.svx*(percent/100)
		e.vy += e.svy*(percent/100)
		e.x += e.vx
		e.y += e.vy
		circfill(e.x,e.y,0.5,ecol)
		if(e.x>screenwidth or e.x<0 or e.y>screenheight or percent>=1) then del(embers, e) end
	end
end

bombs = {}
bomb = {}
bomb.life = 100
bomb.decay = 5
bomb.radius = 30
bomb.x = 0
bomb.y = 0
function getbomb(x,y,life,r)
	local b = copy(bomb)
	b.x = x
	b.y = y
	b.life = life
	b.radius = r
	add(bombs,b)
end
function drawbombs()
	for b in all(bombs) do
		drawbomb(b.x, b.y, b.life/100, b.radius)
		b.life-=b.decay
		if b.life<=0 then del(bombs,b) end
	end
end
function drawbomb(x,y,p,rad)
	local r = rad*p
	local linedis = r*0.75
	circfill(x,y,r,9)
	circfill(x,y,r-1,10)
	circfill(x,y,r/2,9)
	line(x-linedis,y,x+linedis,y)
	line(x,y-linedis,x,y+linedis)
	line(x-linedis,y-linedis,x+linedis,y+linedis)
	line(x-linedis,y+linedis,x+linedis,y-linedis)
end

players = {}
playerstarty = 100

bullets = {}
bulletsmax = 9

missiles = {}
missilesmax = 8
missilesactive = 0

explosions = {}
explosionsmax = 40

props = {}
propsmax = 6
propwaters = 0
propwatersmax = propsmax
proppos = {}
proppos.x = 0
proppos.y = 0

deathcircles = {}
deathcirclesmax = 8
deathcirclepos = {}
deathcirclepos.x = 0
deathcirclepos.y = 0

--clouds
clouds = {}
cloud = {}
cloud.x = 0
cloud.y = 0
cloud.vx = 0
cloud.vy = 0
cloud.radius = 30
cloud.col = {7,6,7}
cloud.base = 0.6
cloud.index = 11

cdata = {}
for i=1,10 do
	add(cdata, {rnd(128), -rnd(500), 0, cloud.base+5+rnd(6), 2+rnd(5)})
end
add(cdata, {20,35,-0.2,cloud.base+0.55,30})
add(cdata, {100,50,0,cloud.base+0.5,30})
add(cdata, {30,60,0.1,cloud.base+0.45,30})
add(cdata, {120,30,0.2,cloud.base+0.5,27})
add(cdata, {70,70,0,cloud.base+0.4,30})
function initclouds()
	clouds = {}
	for obj in all(cdata) do
		local cl = copy(cloud)
		cl.x = obj[1]
		cl.y = obj[2]
		cl.vx = obj[3]
		cl.vy = obj[4]
		cl.radius = obj[5]
		add(clouds, cl)
	end
end

--camera
c = {}
c.x = 0 
c.y = 0
c.tx = 0
c.ty = 0
c.shakesize = 10

--combos
combolist = {}
combolife = 10

--system
score = 0
combo = 0
sessioncombo = 0
droppedcounter = 50
savednames = {"pilot", "pilot", "pilot", "pilot", "pilot", "pilot", "pilot", "pilot", "pilot"}
savedscores = {90, 80, 70, 60, 50, 40, 30, 20, 10}
savedcombo = {9, 8, 7, 6, 5, 4, 3, 2, 1}
savedbombs = {false, false, false, false, false, false, false, false, false}

bgposy = 0
waterpos = 0
jety = 0
traildamp = 30
trailacc = 0.2
messagetimer = 0

gamespeed = 1
gamemissiles = 100
gameshots = 1000
autobomb = false

--music
track = {}
track.title = 23
track.bgm = 1
track.gameover = 20
track.gameclear = 17

-- states
state_title = {}
state_title.logoy = 0
state_title.blinkmax = 45
state_title.autobombtimer = 0
state_title.keypressed = false
state_title.shinetimer = 0
state_title.blink = state_title.blinkmax
state_title.menuopen = false
state_title.nav = {}
state_title.nav.state = 1
state_title.nav.posy = 115
state_title.nav.posx = 128
state_title.nav.startcol = 10
state_title.nav.scorecol = 7

state_scores = {}
state_scores.newscoreindex = -1
state_scores.newname = ""
state_scores.newnameundescore = ""
state_scores.newnameletter = ""
state_scores.newnameindex = 0
state_scores.newnameindexmax = 4
state_scores.newnameblink = 0
state_scores.nameentry = false
state_scores.namekeyrepeat = 60
state_scores.namekeyaccel = 1
state_scores.namex = 0
state_scores.highlighttimer = 0
state_scores.nav = {}
state_scores.nav.state = 2
state_scores.nav.posy = 121
state_scores.nav.posx = 128
state_scores.nav.backcol = 10
state_scores.nav.clearcol = 7

state_game = {}
state_game.isstarting = true
state_game.isfinished = false
state_game.iscomplete = false
state_game.completedelay = 100
state_game.starttimer = 0
state_game.poshold = false
state_game.playeraccel = 1
state_game.playeraccelmax = 5

state_gameover = {}
state_gameover.active = 0
state_gameover.timer = 30

state_restart = {}

function state_title:init()
	embers = {}
	shootdelay = shootdelaymax
	state = state_title
	music(track.title,0)
end
function state_title:update()
	if btnp(4) then
		if self.menuopen == false then
			self.logoy = 0
			self.menuopen = true
		else
			if self.nav.state == 1 then
				state = state_restart
			else
				state = state_scores
			end
		end
		sfx(3)
	end
	

	if btnp(1) or btnp(0) then
		self.keypressed = false
	end

	if btn(1) or btn(0) then
		if(self.keypressed == false) then
			if (autobomb == true) then 
				autobomb = false 
			else 
				autobomb = true 
			end
			self.autobombtimer = 32
			self.keypressed = true
		end
	end

	if self.menuopen == true then
		if btn(2) and self.nav.state!=1 then
			self.nav.state = 1
			self.nav.posy = 115
			self.nav.startcol = 10
			self.nav.scorecol = 7
			self.nav.posx = 128
			sfx(2)
		elseif btn(3) and self.nav.state!=2 then
			self.nav.state = 2
			self.nav.posy = 121
			self.nav.startcol = 7
			self.nav.scorecol = 10
			self.nav.posx = 128
			sfx(2)
		end
	end
end 
function state_title:draw()
	local menuy = -6
	cls()
	rectfill(0,0,127,127,8)

	local ang = 0
	local amt = 5
	local step = 360/amt

	for i=1,amt do
		local v = getvelocity(ang,10)
		local cx = (screenwidth/2) + v.x
		local cy = (screenheight/2)+self.logoy + v.y
		circ(cx, cy, 38, 14)
		ang+=step
	end

	local holeradius = 35
	circfill((screenwidth/2),(screenheight/2)+self.logoy,holeradius,4)
	circfill((screenwidth/2),(screenheight/2)+self.logoy,holeradius-0.5,0)

	drawembers()

	local hv = getvelocity(flr(rnd(360)),holeradius)
	local hx = (screenwidth/2) + hv.x
	local hy = (screenheight/2)+self.logoy + hv.y

	getember(hx, hy, 5, -1, 0.0001, e.colour1, e.anim)

	--rose
	local roseposx = 37
	local roseposy = 55
	zspr(16,1,1,roseposx,	roseposy+self.logoy,2)
	zspr(17,1,1,roseposx+16	,roseposy+8+self.logoy,2)
	zspr(18,1,1,roseposx+27,roseposy+2+self.logoy,2)
	zspr(19,1,1,roseposx+43,roseposy+2+self.logoy,2)
	
	zspr(32,1,1,roseposx,roseposy+16+self.logoy,2)
	zspr(34,1,1,roseposx+25,roseposy+18+self.logoy,2)

	-- burning
	local burning = "burning"
	local bx = 42
	local col = 8
	self.shinetimer+=1
	if(self.shinetimer>100) then self.shinetimer=0-flr(rnd(300)) end
	for j=1,7 do
		if(j==self.shinetimer) then col = 7 end
		print(sub(burning,j,j), bx, roseposy-7+self.logoy, col)
		bx+=7
	end

	--autobomb
	local offstr = "off"
	if autobomb==true then offstr = "on" end
	if self.autobombtimer>0 then 
		self.autobombtimer-=1
		if self.autobombtimer%4<=2 then 
			printf("autobomb:"..offstr, 126, 2, 0, "right", 7)
		end
	end

	-- menu
	if self.menuopen == false then
		self.blink-=1
		if self.blink>self.blinkmax/2  then
			print("press <z> to start", 28, 118, 15)
		elseif self.blink<=0 then
			self.blink = self.blinkmax
		end
	else

		if self.logoy>-10 then
			self.logoy-=3
			if self.logoy<-10 then
				self.logoy = -10
			end
		else
			if self.nav.posx>20 then
				self.nav.posx-=20
				if self.nav.posx<20 then
					self.nav.posx = 20
				end
			end

			rectfill(self.nav.posx,self.nav.posy+menuy, 128, self.nav.posy+menuy+6, 0)
			spr(20, self.nav.posx-4, self.nav.posy+menuy)

			print("start game", 44, 116+menuy, self.nav.startcol)
			print("highscores", 44, 122+menuy, self.nav.scorecol)

		end

	end

end

function state_scores:update()

	--backspace letter
	if self.nameentry == true then
		if btnp(5) then
			if self.newnameindex>0 then
				self.newnameindex-=1
				self.newname = sub(self.newname, 0, #self.newname-1)
			end
		end

		--end name entry
		if btnp(4) then
			if self.newnameindex > self.newnameindexmax then
				savednames[self.newscoreindex] = self.newname
				self.newnameundescore = ""
				self.newscoreindex = -1
				self.nameentry = false
			else
				self.newnameindex+=1
				if self.newnameletter == "*" then self.newnameletter = " " end
				self.newname = self.newname..self.newnameletter
			end
			sfx(5)
		end

		--letter select
		local pressed = false
		if btn(0) then
			
			if self.namekeyrepeat<= 0 or self.namekeyaccel ==1 then
				self.namex += 8
				sfx(2)
			end
			
			self.namekeyrepeat-=self.namekeyaccel
			if self.namekeyaccel<=5 then
				self.namekeyaccel*=1.2
			else
				self.namekeyaccel = 5
			end
			
			pressed = true

		elseif btn(1) then

			if self.namekeyrepeat<= 0 or self.namekeyaccel ==1 then
				self.namex -= 8
				sfx(2)
			end

			self.namekeyrepeat-=self.namekeyaccel
			if self.namekeyaccel<=5 then
				self.namekeyaccel*=1.2
			else
				self.namekeyaccel = 5
			end

			pressed = true

		end
		if pressed==false and self.namekeyaccel !=1 then
			self.namekeyrepeat = 60
			self.namekeyaccel = 1
		end
	else
		if btnp(5) then
			state_title:init()
			sfx(3)
		end
		if btnp(4) then
			if self.nav.state == 2 then
				state_title:init()
				sfx(3)
			else
				local sc = 90
				for i=1, 9 do
					savedscores[i] = sc
					savednames[i] = "pilot"
					savedcombo[i] = sc/10
					savedbombs[i] = false
					sc-=10
				end
				sfx(5)
			end
		end
		if btn(2) and self.nav.state!=1 then
			self.nav.state = 1
			self.nav.posy = 115
			self.nav.backcol = 7
			self.nav.clearcol = 10
			self.nav.posx = 128
			sfx(2)
		elseif btn(3) and self.nav.state!=2 then
			self.nav.state = 2
			self.nav.posy = 121
			self.nav.backcol = 10
			self.nav.clearcol = 7
			self.nav.posx = 128
			sfx(2)
		end
	end
end
function state_scores:draw()
	rectfill(0,0,127,127,8)

	print("r a n k i n g", 40, 12, 15)
	local menuy = -6
	local ystep = 8
	local ystart = 20
	rect(4, ystart+2, 124, ystart+82, 0)

	for i=1,9 do
		rectfill(15, ystart+(ystep*i)-1, 122, ystart+(ystep*i)+5, 0)
		spr(20, 11, ystart+(ystep*i)-1)
		--rank
		printf(i..".", 16, ystart+(ystep*i), 0, "right", 15)
		--names
		local col = 12
		if i==1 then col = 7 end
		if self.newscoreindex==i then
			local finalname = self.newname..self.newnameundescore
			print(finalname, 22, ystart+(ystep*i), col)
		else
			print(savednames[i], 22, ystart+(ystep*i), col)
		end
		-- combo
		col = 8
		if i==1 then col = 8 end
		color(col)
		--chain
		drawchain(47, ystart+(ystep*i), savedcombo[i])
		--scores
		col = 8
		if i==1 then col = 7 end
		local units = savedscores[i]..""
		local len = #units
		local mil = "0000000"
		local strscore = sub(mil,0,7-len)..units
		printf(strscore, 115, ystart+(ystep*i), 0, "right", col)
		--bombs
		local bombspr = 25
		if savedbombs[i]==true then bombspr = 26 end
		spr(bombspr, 114, ystart+(ystep*i)-1)
	end

	if self.nameentry == true then 
		
		self.newnameblink-=1
		if self.newnameblink<=0 then
			self.newnameblink = 15
			if self.newnameundescore=="_" then
				self.newnameundescore = ""
			else
				self.newnameundescore = "_"
			end
		end

		--letters plus numbers
		local charactersmax = 26 + 10 + 10
		--character width
		local charwidth = 3
		--space width
		local spacewidth = 4
		local maxpos = (charactersmax*8)-5 --(charactersmax*charwidth)+((charactersmax-1)*spacewidth)

		local endleft = 64
		local endright = 64-(8*(charactersmax-1))
		if self.namex>endleft then self.namex = endleft end
		if self.namex<endright then self.namex = endright end

		local str = "a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 - < > _ [ ] / = + *"
		local index = flr(abs(self.namex-64)/8)
		
		--pulsing animation
		self.highlighttimer+=0.035
		if self.highlighttimer>1 then self.highlighttimer-=1 end
		local r = 5+((sin(self.highlighttimer)+1)*1.2)

		self.newnameletter = sub(str, (index*2)+1, (index*2)+1)

		circ(65, 112, r+1, 14)
		rectfill(0,109,128,115, 0)
		rectfill(self.namex-64,110,self.namex-4,114,8)
		rectfill(self.namex+maxpos+4,110,self.namex+maxpos+4+64,114,8)
		print(str, self.namex, 110, 7)
		circfill(65, 112, r, 0)
		circ(65, 112, r-1, 8)
		print(self.newnameletter, 64, 110, 10)

	else
		if self.nav.posx>20 then
			self.nav.posx-=20
			if self.nav.posx<20 then
				self.nav.posx = 20
			end
		end	

		rectfill(self.nav.posx,self.nav.posy+menuy, 128, self.nav.posy+menuy+6, 0)
		spr(20, self.nav.posx-4, self.nav.posy+menuy)
		print("clear scores", 44, 116+menuy, self.nav.clearcol)
		print("back", 44, 122+menuy, self.nav.backcol)
	end
end 

function state_game:update()
	
	updatebomb()

	if player.bombactive == false and self.isstarting == false then
		if gamemissiles>0 then
			getpoolobj(missiles)
		elseif gamemissiles ==0 and missilesactive<=0 then
			if self.isfinished == false then
				self.isfinished = true
				traildamp = 50
				trailacc = 1.2
				embers = {}
				jety = player.y
			end
		end
	end

	if self.isfinished == true then

		if player.y>-100 then
			player.y-=self.playeraccel
			self.playeraccel = self.playeraccel*1.1
			if self.playeraccel >= self.playeraccelmax then
				self.playeraccel = self.playeraccelmax
			end
			-- end here
			if player.y <= -100 and self.iscomplete==false then
				messagetimer = 0
				self.iscomplete = true
				self.completedelay = 120
				music(track.gameclear,0)
			end
		end

		if self.iscomplete == true then
			self.completedelay = self.completedelay - 1
			if self.completedelay<=0 then

				local ishighscore = false
				local highscoreindex = 0
				local adjustedscore = score
				
				--bomb adjusted score
				if autobomb==true then
					local rankdown = flr(adjustedscore/10)
					adjustedscore -= rankdown
					if(adjustedscore<0) adjustedscore = 0
				end

				--final score
				local finalscore = flr(adjustedscore * (combo/10))

				for i=1,9,1 do
					if finalscore>savedscores[i] then
						highscoreindex = i
						ishighscore = true					
						break
					end
				end

				if ishighscore then
					for i=9,highscoreindex,-1 do
						savedscores[i] = savedscores[i-1] 
						savedcombo[i] = savedcombo[i-1] 
						savednames[i] = savednames[i-1]
						savedbombs[i] = savedbombs[i-1]
					end
					savedcombo[highscoreindex] = combo
					savedscores[highscoreindex] = finalscore
					savedbombs[highscoreindex] = autobomb
					state_scores.newname = ""
					state_scores.newnameindex = 0
					state_scores.newscoreindex = highscoreindex
					state_scores.nameentry = true
					state = state_scores
				else
					state_title:init()
				end
			end
		end
	elseif self.isstarting == true then

			self.starttimer += 1
			local y = 128-(76*sin(self.starttimer/100))

			self.playeraccel = self.playeraccel*0.991
			gamespeed = max(1,self.playeraccel/2)

			if self.starttimer > 110 then
				--start free movement
				moveplayer()
				-- start gameplay
				if self.starttimer>=160 then
					self.isstarting = false
					gamespeed = 1
				end
			else
				-- burst out of clouds
				if self.starttimer>45 and self.starttimer<65 then
					for i=1,1 do
						local ex = getpoolobj(explosions)
						local b = 2+flr(rnd(3))
						local ang = 315+flr(rnd(90))
						local spd = 0.5+(1/flr(rnd(5)))
						local v = getvelocity(ang,spd)
						ex:setup(player.x+rnd(6)-2, 98+(self.starttimer/30), b,-1,v.x,v.y,220,300,7,7)
					end
				end
				--hold position
				if self.starttimer>80 and y>playerstarty then self.poshold = true end
				if self.poshold == true then
					y = playerstarty
				end
				player.y = y
			end
			
	else
		moveplayer()
		playershoot()
		checkcollisions(bullets, missiles)
		checkcollisions(missiles, players) 
	end

	if propwaters<propwatersmax then 
		proppos.x = 16+flr(rnd(screenwidth-32))
		proppos.y = flr(rnd(screenheight))
		getpoolobj(props)
	end
end
function state_game:draw()
	cls()
	drawbackground()
	drawpool(props)
	drawpool(explosions)
	drawpool(missiles)
	if(player.bombactive) then
		animsuperbomb()
	end
	drawplayer()
	if self.isfinished == true then 
		animshiptrails(false, true)
	elseif self.isstarting ==true then
		local spawnembers = self.starttimer<110
		animshiptrails(true, spawnembers)
	end
	if(self.isstarting) then
		drawpool(explosions)
	end
	drawpool(bullets)
	drawpool(deathcircles)
	if self.isstarting==true then
		animclouds()
	end
	--hud
	drawhud()
	--combo
	if sessioncombo>=3 then
		drawchain(6, 12, sessioncombo)
	end

	if self.iscomplete then
		drawmessage("s t a g e  c l e a r e d")
	end
end

function state_gameover:update()

	if btnp(4) and self.active==2 then
		state_title:init()
	end

	if missilesactive<=0 and self.active==0 then
		messagetimer = 0
		self.active = 1
		music(track.gameover,0)
	end

	if self.active == 1 then
		self.timer -= 1
		if self.timer <= 0 then
			self.timer = 0
			self.active = 2
		end
	end

	if propwaters<propwatersmax then 
		proppos.x = 16+flr(rnd(screenwidth-32))
		proppos.y = flr(rnd(screenheight))
		getpoolobj(props)
	end

	checkcollisions(bullets, missiles)
end 
function state_gameover:draw()
	cls()
	drawbackground()
	drawpool(props)
	drawpool(missiles)
	drawpool(explosions)
	drawpool(bullets)

	--local p = self.timer/30
	--local w = 128*p
	--rectfill(player.x-(w/2), player.y, w, 8*p, 8)
	drawpool(deathcircles)

	--hud
	rectfill(0,0,127,8,0)
	if self.active ==2 then
		printf("restart", 64, 2, 0, "center",10)
	else
		drawhud()
	end
	if self.active >= 1 then
		drawmessage("g a m e  o v e r")
	end
end
function state_restart:update()
	embers = {}
	player.active = true
	gameshots = 500
	gamemissiles = 500
	player.bombs = 3
	player.x = 64
	player.y = 200
	player.bombactive = false
	player.bombtimer = 0
	jety = 200
	score = 0
	combo = 0
	sessioncombo = 0
	droppedcounter = 50
	traildamp = 30
	trailacc = 0.25
	state_game.playeraccel = 8
	state_game.isfinished = false
	state_game.isstarting = true
	state_game.starttimer = 0
	state_game.iscomplete = false
	state_game.poshold = false
	state_scores.nameentry = false
	initclouds()
	music(track.bgm,0)
	state = state_game
end 
function state_restart:draw()
end

function _init()
	add(players, player)
	initpool(deathcircles, deathcircle, deathcirclesmax)
	initpool(props, prop, propsmax)
	initpool(bullets, bullet, bulletsmax)
	initpool(missiles, missile, missilesmax)
	initpool(explosions, explosion, explosionsmax)
	initclouds()
	state_title:init()
end

function _update()
	state:update()
end

function _draw()
	state:draw()
end

function checkcollisions(group1, group2)

	for g1 in all(group1) do
		for g2 in all(group2) do
			if(g1.active and g2.active) then
				local coll = iscolliding(g1,g2)
				if coll then
					g1:collisionresolve(g2)
					g2:collisionresolve(g1)
				end
			end
		end
	end

end

function moveplayer()
	
	x = player.x
	y = player.y

	if btn(0) then 
		x = x - player.speed
		if x<0 then x = 0 end
	end

	if btn(1) then
		x = x + player.speed
		if x>screenwidth-player.bounds then x = screenwidth-player.bounds end
	end

	if btn(2) then
		y = y - player.speed
		if y<0 then y = 0 end
	end

	if btn(3) then
		y = y + player.speed
		if y>screenheight-player.bounds then y = screenheight-player.bounds end
	end

	player.x = x
	player.y = y

end

function updatebomb()

	if player.bombtimer>0 then
		
		local steps = 15

		local modtimer = player.bombtimer%3
		if(modtimer==0) then
			local r = 20+rnd(10)
			local percent = 128-player.bombypos
			getbomb(0+percent,player.bombypos,50,r)
			getbomb(128-percent,player.bombypos,50,r)

			local minbound = 64
			local maxbound = 128
			if percent>minbound and percent<maxbound then
				local count = flr((percent-minbound)/14)+1
				local space = 1
				for i=1,count do
					local maxwidth = (count*(r+space))
					local x = i * (maxwidth/count) - (maxwidth/2)
					getbomb(x+48,player.bombypos,50,r)
				end
			end

			player.bombypos-=steps

			local shakesize = c.shakesize*max(0, ((100-percent)/100))
			c.tx = -shakesize+rnd(shakesize*2)
			c.ty = -shakesize+rnd(shakesize*2)

			if player.bombtimer>30 then sfx(6) end
		end

		c.x = (c.tx-c.x)/3
		c.y = (c.ty-c.y)/3
		camera(c.x,c.y)

		player.bombtimer-=1
		if player.bombtimer==0 then
			player.bombactive = false
		end

	end

end

function playerbomb()
	if(player.bombs>0 and player.bombtimer==0) then
		player.bombactive = true
		player.bombtimer = player.bombtimermax
		player.bombypos = 128
		player.bombs-=1
	end
end

function playershoot()

	if btn(4) and player.bombactive==false then
		if player.shootdelay<=0 then
			if gameshots>0 then
				getpoolobj(bullets)
			end
			player.shootdelay = player.shootdelaymax
		end
		player.shootdelay-=1
	end

	if(btn(5)) then
		playerbomb()
	end
	
end

--pool methods
function initpool(pool, obj, count)
	
	for i=1,count do
		p = copy(obj)
		p:init()
		add(pool, p)
	end

end

function getpoolobj(pool)

	local obj = {}
	for p in all(pool) do
		if (p.active==false) then
			p:add()
			obj = p
			break
		end
	end
	return obj

end

function drawpool(pool)

	for p in all(pool) do
		if (p.active==true) then
			p:draw()
		end
	end

end

--draw methods
function drawmessage(str)
	messagetimer+=0.1
	if messagetimer>1 then messagetimer = 1 end
	local halfheight = 3*(1+sin(messagetimer))
	rectfill(0,64-halfheight,128, 64+halfheight, 8)
	if messagetimer==1 then
		printf(str, 64, 62, 0, "center",15)
	end
end

function drawhud()
	rectfill(0,-10,127,8,0)
	spr(22,3,0)
	printf(""..gameshots, 12, 2, 0, "left",9)
	spr(23,117,0)
	printf(""..gamemissiles, 115, 2, 0, "right",12) 
	printf("["..score.."]", 66, 2, 0, "left",7) 

	if(droppedcounter < 50) then
		droppedcounter+=1
		local blop = droppedcounter%5
		if(blop<3) then 
			printf("x"..combo, 62, 2, 0, "right",8) 
		end
	else
		printf("x"..combo, 62, 2, 0, "right",8) 
	end

	local bombspr = 25
	if autobomb==true then bombspr = 26 end
	for i=1,player.bombs do
		local x = 128 - (i*7) - 5
		spr(bombspr,x,screenheight-9)
	end
end
function drawchain(x, y, chainval)

	local chainstr = chainval..""
	local len = #chainstr
	len = len*(3+1)

	local fg = 10
	local bg = fg
	local chainstrcol = 15
	local valuecol = 8

	rectfill(x+len, y, x+(4*5)+4+len, y+5, valuecol)
	line(x+(4*5)+5+len, y+1, x+(4*5)+5+len, y+5, valuecol)
	rectfill(x, y-1, x+len, y+5, bg)
	circfill(x, y+2, 2, bg)
	circfill(x+len, y+2, 2, bg)

	rectfill(x, y, x+len, y+4, fg)
	circfill(x, y+2, 2, fg)
	circfill(x+len, y+2, 2, fg)
	local chn = "CHAIN"
	printf(chn, x+5+len, y, 0, "left", chainstrcol)
	printf(chainstr, x+1, y, 0, "left",valuecol)
end
function drawcombos()

	for c in all(combolist) do
		c.life-=1
		if (c.life<=0) then
			del(combolist,c)
		end
		drawchain(c.x, c.y, c.combo)
	end

end
function drawbackground()
	local col = 12
	if player.bombactive then
		local modb = player.bombtimer%3
		if modb==0 then
			col = 8
		else
			col = 2
		end
		if player.bombtimer<3 then
			col = 6
		elseif player.bombtimer<6 then
			col = 15
		elseif player.bombtimer<9 then
			col = 14
		end
	end

	rectfill(0,0,screenwidth,screenheight,col)
	bgposy+=gamespeed
	if(bgposy>8) bgposy-=8
	map(0,0,0,bgposy-8,2,32)
	map(5,0,112,bgposy-8,2,32)
	waterpos+=gamespeed
	if(waterpos>8*32) waterpos-=8*32
end

function animsuperbomb()

	drawbombs()
	local percent = screenwidth - (screenwidth*(player.bombtimer/player.bombtimermax))
	percent*=2
	local invperecent = 128-percent
	spr(24,percent,invperecent, 1, 1, true)
	spr(24,invperecent,invperecent, 1, 1, false)

	for m in all(missiles) do
		if m.active == true then
			local range = 30
			if m.y>invperecent-range and m.y<invperecent+range then
				local obj = {}
				obj.id = "pbullet"
				m:collisionresolve(obj)
			end
		end
	end

end

function animshiptrails(always, spawn)

	local py = player.y 	
	local render = true

	if always == false then
		local diff = abs(jety-py)
		if diff<2 then
			render = false
		end
	end

	if render==true then
		if(traildamp>1) traildamp-=trailacc
		if(traildamp<1) traildamp = 1
		jety += (py-jety)/traildamp
		local wingoffset = 3
		local smokey = py+wingoffset
		local l = player.x-6
		local r = player.x+12
		if spawn then
			local xsway = 0
			local ysway = 0
			--getember(l, smokey, xsway, ysway, 0.0006, e.colour2, e.anim)
			--getember(r, smokey, xsway, ysway, 0.0006, e.colour2, e.anim)
			line(l, jety+wingoffset, l, smokey, 7)
			line(r, jety+wingoffset, r, smokey, 7)
		else
			local ex1 = getpoolobj(explosions)
			local ex2 = getpoolobj(explosions)
			local b = 1+flr(rnd(2))
			local ang = 170+flr(rnd(20))
			local spd = 2+(1/flr(rnd(5)))
			local v = getvelocity(ang,spd)
			ex1:setup(l, smokey, b, -1,v.x,v.y,220,200,7,13)
			ex2:setup(r, smokey, b, -1,v.x,v.y,220,200,7,13)
		end
		--drawembers()
	end

end

function animclouds()
	local cc = clouds[cloud.index]
	for cl in all(clouds) do
		cl.x += cl.vx
		cl.y += cl.vy
		if(cl.radius>10) then
			circfill(cl.x, cl.y, cl.radius+4, cl.col[3])
			circfill(cl.x, cl.y+2, cl.radius+2, cl.col[2])
			circfill(cl.x, cl.y+4, cl.radius, cl.col[1])
		else
			circfill(cl.x, cl.y+4, cl.radius, cl.col[1])
			circfill(cl.x, cl.y-2, cl.radius-2, cl.col[1])
		end
	end
	rectfill(0, cc.y+30, 128, cc.y+100, cc.col[1])
	circfill(64, cc.y+70, 60, cc.col[1])
end

function drawplayer()
	
	rectfill(player.x+2, player.y, player.x+4, player.y+10, 8)
	spr(player.spriteframe,player.x-5,player.y,1,1,false)
	spr(player.spriteframe,player.x+4,player.y,1,1,true)
	--tail
	sspr(59,4,5,5,player.x+1,player.y+11)
	--middle
	sspr(56,5,3,3,player.x+2,player.y+6)
	--rotor
	player.rotor = drawrotor(player.x+2, player.y-1, 5,player.rotor)
	--spike
	sspr(63,0,1,3,player.x+3,player.y-1)
	
end

--util methods
function drawrotor(x, y, len, obj)
	obj.anim+=obj.dir
	if obj.anim>len then 
		obj.anim=len
		obj.dir=-1 	
	end
	if obj.anim<0 then 
		obj.anim=0
		obj.dir=1 
	end
	line(x-(obj.anim/2), y, x+obj.anim, y, 7)
	return obj	
end


function iscolliding(obj1, obj2)

	local cleft = obj1.x < obj2.x + obj2.bounds
	local cright = obj1.x + obj1.bounds > obj2.x
	local ctop = obj1.y < obj2.y + obj2.bounds
	local cbot = obj1.y + obj1.bounds > obj2.y

	if cleft and cright and ctop and cbot then
		return true
	else
		return false
	end

end

function copy(o)
  local c
  if type(o) == 'table' then
    c = {}
    for k, v in pairs(o) do
      c[k] = copy(v)
    end
  else
    c = o
  end
  return c
end

function printf(string,x,y,width,alignment,col)
  color(col)
  if alignment == "center" then
    print(string,x+(width-4*#string)/2,y)
  elseif alignment == "left" then
    print(string,x,y)
  elseif alignment == "right" then
    print(string,x+width-4*#string,y)
  else
    printh("invalid alignment")
  end
end

function zspr(n,w,h,dx,dy,dz) --sprite number, width, height, x, y, scale
  sx = 8 * (n % 16)
  sy = 8 * flr(n / 16)
  sw = 8 * w
  sh = 8 * h
  dw = sw * dz
  dh = sh * dz
  sspr(sx,sy,sw,sh, dx,dy,dw,dh)
end

function getvelocity(angle, speed)
	if angle < 90 then 
		angle=270+angle 
	else
		angle = angle-90
	end
	local a = angle/360
	v = {}
	v.x = speed*cos(a)
	v.y = speed*sin(a)
	return v
end
__gfx__
000000000000000067d6d76000000000000000000000000000000001bbb99995ddddddd55ddddddd700000000000000770000000000000070007000000088000
00000000e9e00e9e073d3700000090000000f0000000000000000008bbb99991d67777755777776d7000000000000007700000000000000700707000008ee800
0000000097900979003d300000097900000faf000000900000000004bbb99998d66666655666666d770000000000000770000000000000770077700008effe80
000000009790097900ddd0000097779000faaaf000097900eeeffee8bbb00000d66666655666666d77000000000000077000000000000077070007008effffe8
000000009a9009a900d6d0000097779000faaaf00009790088877888bbb08e80d66666655666666d77000000000000077000000000000077000700008effffe8
000000009a9009a9006760000000000000000000000000002227788811108e80d66666655666666d770000000000007777000000000000777770777008effe80
0000000099900999000600000000000000000000000000000887722819182828dddd6dd55ddd6ddd7000000000000077770000000000000700000000008ee800
0000000009000090000000000000000000000000000000000006688824200800d55555555555555d700000000000007777000000000000070077700000088000
007777700777700000007700077700000000800000000000000000000000000000700a9000000000000000000000000000000000000000000000000000088000
77727777777777000007720077777000000080000000000099999990ccccccc00700f9a900099920000eee2000000000000000000000000000000000008ee800
77202777772227700077200077227000000088000000000090000090c00000c0709f99900094449200e444e20000000000000000000000000000000008e88e80
770007727720077000770000772070000000880000000000909a9090c06560c000f999000094f49200e4f4e2000000000000000000000000000000008e8888e8
770077707720072000277700777720000000888000000000909a9090c00300c00f9990000094549200e454e2000000000000000000000000000000008e8888e8
770777202777720000027770772207000000888000090900900a0090c00600c0a999090900299920002eee200000000000000000000000000000000008e88e80
77777200022220000000277027777200000088880000900090000090c00000c09a900090000222000002220000000000000000000000000000000000008ee800
77772000000000000000772002222000000000000009090099999990ccccccc00900090900000000000000000000000000000000000000000000000000088000
77277000000000000007772000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77077700000000000002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77027700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77002770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
27000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090c0000000b0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0000000d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0101000000000000003802035020310202e0202b03023030200301b0301702013020100100d010080100600000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000186752e6440a6120a6120a6120b6020b6010b6052300012000100000c0000d000252001c7001f7002170023700010001b000000000000000000000000000000000000000000000000000000000000000
010700002f7352a7352d000310002d000320000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070000180351d0321f7351f70518506185061850618703306030000000000187030000000000000001870300000000000000018703000000000000000187031870300000000001870318703187030000018703
011000001f2451f2261f2451f226212452122621245212261a2451a2261a2451a226187451a7451d7451f7441f7471f7471f7471f747000000000000000000000c0000c0000c1000c10100000000000000000000
0104000032626266120f61133611336110f6110f6110f6110c0001b60000000000001b6001b600000001b6001b6001a6001a60000000000000000000000000000000000000000000000000000000000000000000
00080000256731b6731e66323675206761b6701767018670166502563026620216001a60016600116000960004600026000160001600000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00000e7700e7700e770180040e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e770000000e7700d0050e770000000e77000000
010b000035640356350e7031d6050e77335603356632960535663356010e7731d6450e77335605356632960535640356350e7031d6050e7733560335663296050e77335601217431f7431a7430e7733563535645
010b00003564035631356250e7030e7733560335645356010e7733560135645356010e7733560535655356050e7733560135655356050e77335601356551a7030e773356013565535635356550e7333565535635
010b00003565035631356250e703356453560535645356010e773356013564535601356453560535605356053565035631356250e7033564535605356451a7030e773356013564535601356450e7033560535605
010b0000356452170321703217431f7431a74335645356050e7733561535645356050e7733561535645356050e7733561535645356050e77335615356451a7050e77335615356453560535625356453563535655
010b00000e3400e3400e340183040e340183000e340183000e340003001034000300113400030013340183000e34000300153401533215322153121334013332133221331211340113400c3400c3320c3220c312
010b00000e7700e7700e770180040e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7700e7000e7000c7700c7700c7000c700157701577011770117701170011700
010b0000326011a6010e6010e7030e7030000000000000000e7030000000000000000e7030000000000000000e703000001d6750000000000000001d6750000000000000001d675000001d675000003c63118611
010b00003e640336402d640276401c63017630106200c610086100461000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00000e7700e7700e770180040e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e770000000e7700d0050c770000000c77000000
010b00000e7700e7700e7700e7000e770000000e770000000e770000000e770000000e7700000011770000000c7700c7700c770000000c770000000c770000000c770000000c7700000011770000001077000000
010b00000a7700a7700a7700a7000a770000000a770000000a770000000a770000000a770000000a7700000013770137701377000000137701370013770000001377000000137700000013770000001177000000
010b00001677016770167700a70016770000001677000000167700000016770000001677000000167700000013770137701377000000137701370013770000001377000000137700000013770000001177000000
010b00001677016770167700e700167700000016770000000e7000000016770000001677000000117000000013770137701377000000137700000013770000000c70000000137700000013770000001070000000
010b00000e7700e7700e7700e7000e770000000e770000000e074000000e770000000e770000000e770000000e770137000c0700c0040c070000000c070000000c070000000c070000000c070000000c07000000
010b0000263502634226342263002935028350243502630326350283002e350283002d35026300293502d3002b3502b3522b35200300243502635028350293502e350293002b3502b3002d350003002835000300
010b0000243502434024342243322433224322243222431226300283002e300283002d30026300293002d30026300263002630226302263022630226302263022e300293002b3002b30026316283262632628336
010b0000293502934029342293322933229322293222931226300283002e300283002d30026300293002d30026300263002630226302263022630226302263022e300293002b3002b30026316283262632628336
010b00000e7700e7700e7700e7000e770000000e770000000e074000000e770000000e770000000e770000000e770137000c0700c0040c070000000c070000000c070000000c070000000c070000000c00000000
010f00000a7700a7000a7750a7750a770347000a7750a7750a770347000a7750a7750a7700a7000a7750a7750c770347000c7750c7750c770347000c7750c7750c770347000c7750c7750c770347000c7750c775
010b00002e404004042d404004042e4542e4552d4542d45529454294552b4542b455244542445526454264552445424455224542245524454244552b4542b4552845428455264542645528454284552945429455
011000002645426442264422643226432264222642226415000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00002e404004042d404004042e4542e455304543045529454294552b4542b455244542445526454264552445424455224542245524454244552b4542b4552845428455264542645528454284552945429455
010b00002935029342293422630029351293502d3502630326350283002e350283003035026300323002d300323503235232352003002635128350293502b3502e35029300293502b30024350003002830000300
010b00002e3502e3522e3520000030352303523235232352283522835229352293522b3522b3522d3522d35224352243522635226352283522835229352293522b3522b3522d3522d3522b3522b3522835228352
010b000026415264152641500405284152841529415294152b4152b4152d4152d4152e4152e4152441524415284152841529415294152b4152b4152d4152d4152e4152e41524415244152e4152e4152b4152b415
010b00002e3502e3522e352000002d3522d3522b3522b35229352293522b3522b3522d3522d352293522935228352283522635028350293502b3502d3502b350293522b35224352293522835226352243521f352
010b00003242532425324250040530425304253a4253a42539425394253a4253a4253c4253c425394253942537425374253542537425394253a4253c4253a425394253a42534425394253742535425344252e425
010b00002e3502e3522e352000002d3522d3522b3522b35229352293522b3522b3522d3522d352293522935228352283522635028350293502b3502d3502b350293522b35229352293422835228342283021f302
010b00003242532425324250040530425304253a4253a42539425394253a4253a4253c4253c425394253942537425374253542537425394253a4253c4253a425394253a42539422394123742237412344052e405
010b00000e7000e7000e7000e7000e700000000e700000000e700000000e700000000e700000000e700000000e7000e700293602d360293602636029360000002836000000303603033224360243522433224312
010b00000e3400e3400e340183040e340183000e340183000e340003001034000300113400030013340183000e34000300153401533215322153121334013332133221331211340113400c3400c3320c3220c312
010b00000e7700e7700e770180040e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7050e7700e7700e7000e7000c7700c7700c7000c700157701577011770117701170011700
010b00001070010700107000e70010700000001070000000107000000010700000001070000000107000000013700137001d6750e70013700000001d6750000013700000001d6451d6351d6551d6351d6651d675
010b00001a405000001c405000001d405000001f4050000021405000002240500000244050000026405000001a300000002e3502d3502b350293502d3502b35029350283502b3502935028350263502435021350
010f00000e7730e7033e6253e6153e6552d70235640356350e7730e7033e6253e6153e6552d702356453e6350e7730e7033e6253e6153e6552d70235640356350e7733e6253e6153e6253e6552d702356453e635
010f00002647026460264502644026432264222641226412004000040000400004000040000400004000040029470294602945029440294322942229412294122b4702b4602b4502b4402b4322b4222b4122b412
010f0000244702446024450244402443224422244122441200400004000040000400004000040000400004002d4702d4602d4502d4402d4322d4222d4122d4122847028460284502844028432284222841228412
010f00000e770347000e7750e7750e770347000e7750e7750e770347000e7750e7750e770347000e7750e7750e770347000e7750e7750e770347000e7750e7750e770347000e7750e7750e770347000e7750e775
010f00001177034700117751177511770347001177511775117703470011775117751177034700117751177511770347001177511775117703470011775117751177034700117751177511770347001177511775
010b000028305293052b3052d305293052b3052d3052e3052b3052d3052e305303052b30526305283052930528305293052b3052d30528355293552b3552d355293552b3552d3553730534355353053035018351
01070000353750030030375003002b37534305283750030037375343052d375003002b37500300303703036030350303403033230322303120030000300003002b3702b3402b3222b3122d3702d3402d3222d312
0107000032475000003747500000344753440530475000003447534405354750000034475000002d4702d4602d4502d4402d4322d4222d4120000000000000003447034440344223441230470304403042230412
010700001a0701a0701a0501a0401a0321a0221a0121a012180701805018042180321507015070150501504015032150221501215012000000000000000000001a0751a0751a0751a0751f0751f0751f0751f075
010e0000294701d4611145105441294601d4511144105431294501d4411143105421294401d4311142105411294301d4211141105411294201d4211141105411294101d4111141105411294101d4111141105411
010e0000264701a4610e45102441264601a4510e44102431264501a4410e43102421264401a4310e42102411264301a4210e41102411264201a4210e41102411264101a4110e41102411264101a4110e41102411
010a00002236022345263602634529360293452d3602d3402d3302d3202d3152d30524360243402736027345303603035030340303352b3602b3502b3402b3352236026360293602d36026360293602d36030360
010a00003235032350323503234232342323423233232332323323232232322323223231232312323122630000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000262602624529260292452d2602d24530260302403023030220302152d20527260272402b2602b245332603325033240332352e2602e2502e2402e23526260292602d26030260292602d2603026033260
010a00003535035350353503534235342353423533235332353323532235322353223531235312353122630000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000f7500f7500f7400f7300f7300f7201175011750117401174011730117200c7500c7300a7500a7300f7500f7400f7300f720137501374013730137201a7501a7401a7301a72018750187301675016730
010a00001875018750187501874018740187401873018730187321872218722187221871218712187120000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000356550e7030e773296020e773016023565035631356113560135640356053565535625356553563535645356050e7730e703356550e7730e7730e7033565135641356153567535675356053565535605
010a00003565235642356323563235622356223562235612356123560200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 13 42 43 44
00 0f 10 11 28
01 0b 14 19 44
00 0c 15 1a 1e
00 0b 14 19 1f
00 0c 16 1b 1e
00 0b 14 19 44
00 0c 15 1a 1e
00 0b 14 19 1f
00 0c 16 1b 1e
00 0d 17 21 44
00 0e 18 22 23
00 0d 17 21 44
00 0e 18 24 25
00 13 12 43 44
02 29 2a 2b 2c
00 41 42 43 44
00 38 3a 3c 3e
04 39 3b 3d 3f
00 41 42 43 44
00 35 34 33 44
04 37 12 36 44
00 41 42 43 44
01 2d 2e 30 44
00 2d 2f 31 44
00 2d 2e 30 44
02 2d 2f 1d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
