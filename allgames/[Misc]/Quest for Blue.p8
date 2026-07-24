pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--quest for blue 
--by rotar
--[[
    version:2.1,
       * fix: rolled powerup is now turned of at the and of level

    version:2.0,
       * minor bugs fixed
	   * some visual effects added
	          
	version:1.3,
       * start screen music changed
       * gameover screen background music added 
	   * fireworks error fixed
	   * fade out effect between levels
	   * credits scroll fixed

     development roadmap: 	
        * music for game stage
    	* music for intro
        * shooter minigame between levels
				      			
	version:1.2,
        * particle system improvement
        * cpu heavy load intro code turned off
        * end of level fireworks added
         
    version:1.1,
        * improved ricochet angles
        * small ui improvements
        * ball vs player collision improvements 
        * extra live powerup added
        * energy initialization fixed

    version:1.0,
        * added 30fps support for better compatibility with all devices
     	 (it requires gamespeed variable modification directly in code)
        * times changes for rolled powerups,
        * rolled power ups no longer lasts cross levels  
        * fire shot no longer is rolled,
        * player movement is slowed down for improved difficulty
        * mr spot electric simulation improvement
        * multiball is triggered only by primary ball
        * secondary balls collision issue fixed
        * aiming works after sticky hands release the ball
        * missing fadeout effect in instruction screen fixed
   
    version:0.2,
        * new gane init fixed,
        * added "take me to" functionality

]]
gamespeed = 1 --1 for 60fps, 2 for 30fps mode, other for your own risk ;) 
version="2.1"

--[[ ideas
	latajacy dywan
	wstep ze startreka
	uklon do komiksu
	szyderka z blue
	splashe pomiedzy levelmi
	nazwy planet
	smieszne irracjonalne plansze
	kody do poziomow
]]

--pico8 game loop
	function _init()
		cartdata("qfb")
		emiters:init()
		stage:load(stage.intro)
		menuitem( 1, "intro", function()
			stage:fadestageto(stage.intro)
		end )
		menuitem( 2, "start", function()
			stage:fadestageto(stage.start)
		end )
	end
	function _update60()
	--if not freezed then
		if not stage.fade and not game.fade  then 
			if(stage:is(stage.intro)) intro:update()
			if(stage:is(stage.credits)) credits:update()
			if(stage:is(stage.start)) startscreen:update()
			if(stage:is(stage.game)) game:logic()
			if(stage:is(stage.gameover)) gameover:logic()
			if(stage:is(stage.instructions)) instructions:logic()
			emiters:logic()
		end
		-- else
		-- if btnp(5) then
		-- 	freezed = false	
		-- 	sfreezedtext = ""
		-- end
		-- end
	end
	function _draw()
			 if stage.fade then 
			 	stage:fadestage()
			 end
			 if game.fade then 
			 	game:fadescreen()
			 end
			 if(stage:is(stage.intro)) intro:draw()
			 if(stage:is(stage.credits)) credits:draw()
			 if(stage:is(stage.start)) startscreen:draw()
			 if(stage:is(stage.game)) game:draw()
			 if(stage:is(stage.gend)) gend:draw()
			 if(stage:is(stage.gameover)) gameover:draw()
			 if(stage:is(stage.instructions)) instructions:draw()
			 emiters:draw()
			-- if freezed then 
			-- 	print(sfreezedtext,16,13*8,7) 
			-- end
			if btn(4,1) then 
				--rectfill(0,0,64,127,0)
				powerups:energy(128)
				--debug()
			end
		end
	-- function clone(obj)
	-- 	local tcopy = {}
	-- 	for orig_key, orig_value in pairs(obj) do
	-- 		tcopy[orig_key] = orig_value
	-- 	end
	-- 	return tcopy 
	-- end
	function copyparams(dest,src)
		for orig_key, orig_value in pairs(src) do
			local vtype=type(orig_value)
			dest[orig_key] = orig_value
		end
	end
	debugboj = nil
	-- function printparams()
	-- 	if (debugboj == nil) return false
	-- 	cls()
	-- 	for orig_key, orig_value in pairs(debugboj) do
	-- 		if (type(orig_value) != "table" and type(orig_value) != "boolean" and type(orig_value) != "function") then
	-- 			print(orig_key .. "=" .. orig_value)
	-- 		end
	-- 	end
	-- end
	function deepclone(obj)
  		if type(obj) ~= 'table' then return obj end
  		local res = setmetatable({}, getmetatable(obj))
  		for k, v in pairs(obj) do res[deepclone(k)] = deepclone(v) end
  		return res
  	end
	function debug()
		print("mem:" .. stat(0))
		print("cpu:" .. stat(1))
		--print("emiters:" .. #emiters)
		-- printparams(obj)
	end
	function sign(x)
		return x/abs(x)
	end
--stage instructions-                                                                                                                                                                                                           
	instructions = {
		toplvl = 0,
		toplvlname = "",
		isplayed = false,
		startlevel=0;
	}
	function instructions:init()
		self.toplvl = dget(1)
		self.isplayed = dget(0) == 1
		if self.isplayed then
		self.toplvlname = lvlnames[self.toplvl+1][1]
		else  
			self.toplvlname = "???"
		end
	end
	function instructions:logic()
		if (btnp(5)) stage:fadestageto(stage.game)
		if (btnp(4)) then
			self.startlevel = rollbetween(self.startlevel+1,0,self.toplvl)
		end
	end
	function drawcenteredtext(ctext,ty,colors)
		local sx = 64-flr((#ctext*4)/2)
		rectfill(0,ty,127,ty+6,0)
		for i=1,#ctext do
			local printtxt = sub(ctext,i,i+1)
			print(printtxt,sx+(i)*4,ty,colors[1+i%#colors])
		end
	end
	function instructions:draw()
		rectfill(0,0,127,50,0)
		map(48,18,4,8,2,12)
		color(7)
		cursor(20, 9)
		print("aiming, Ž:place marker")
		cursor(20, 17)
		print("fire shot, ball activated")
		cursor(20, 25)
		print("multiball, ball activated")
		cursor(20, 33)
		print("sticky hand")
		cursor(20, 41)
		print("ink shot, up:fire")
		cursor(20, 49)
		print("Ž:release the ball")
		cursor(20, 57)
		print("‹‘ move mr.spot")
		drawcenteredtext("last level "..(self.toplvl+1) .. " of 16" ,67,{7})
		drawcenteredtext((self.toplvl+1).."."..self.toplvlname,75,{11})
		rectfill(0,112,127,127,0)
		print("— ready!",2,120,6)
		if self.isplayed then
			drawcenteredtext("take me to",88,{7})
			drawcenteredtext((self.startlevel+1).."."..lvlnames[self.startlevel+1][1],96,{10})
			print("Ž next level",9*8,120,6)
		end
	end
--module particles
	emiters = {}
	function emiters:init()
		--emiters:fireworks(64,64,0)
	end
	function emiters:logic()
		for e in all(self) do
			if not (time()-e.creationtime>e.lastfor and e.lastfor!=0) then
				e:logic()
			end
		end
	end
	function emiters:draw()
		--cls(0)
		for e in all(self) do
			e:draw()
		end
	end
	function emiters:smallexplosion(x,y)
		sexpemiter = deepclone(emiter)
		self:register(sexpemiter) 
		sexpemiter.g=40
		sexpemiter.gcx=100
		sexpemiter.gcy=100
		sexpemiter.speed=0
		sexpemiter.gvx=0
		sexpemiter.gvy=1
		sexpemiter.maxage=4
		sexpemiter.epower=3
		sexpemiter.ssize=1
		sexpemiter.esize=2
		sexpemiter.endless=false
		sexpemiter.x=x
		sexpemiter.y=y
		sexpemiter.counter=8
		sexpemiter.cumulate=8
		sexpemiter.logiccallback = changegravitycenter
		local colorbase = flr(6+rnd(5))
		sexpemiter.basecolor = colorbase
	end
	function emiters:fireworks(x,y, ltime)
		local expemiter = deepclone(emiter)
		expemiter.x=x
		expemiter.y=y
		expemiter.g=2
		expemiter.speed=2
		expemiter.gvx=0
		expemiter.gvy=1
		expemiter.maxage=2
		expemiter.hdist=20
		expemiter.vdist=20
		expemiter.epower=1.3
		expemiter.ssize=0
		expemiter.esize=2
		expemiter.endless=true
		expemiter.cumulate=20
		expemiter.callback = rolllocation
		expemiter.lastfor = ltime
		local colorbase = 7+rnd(2)
		expemiter.basecolor = colorbase
		self:register(expemiter) 
	end
	function emiters:register(emit)
		emit.starttime = time()
		emit.creationtime = time()
		emit:init()
		add(self,emit) 
	end
	function emiters:reset()
		for e in all(self) do
			e:reset()
			del(self,e)
			e = nil
		end
		sexpemiter = nil
	end	
	function rolllocation(emi)
		if emi.chx == nil then 
			emi.chx = emi.x
			emi.chy = emi.y
		end
		emi.x = emi.chx+(30-rnd(60))
		emi.y = emi.chy+(10-rnd(20))
		emi.speed = 1+rnd(2)
		emi.cumulate = 10+rnd(20)
		emi.basecolor = flr(7+rnd(5))
		sfx(0)
	end
	function changegravitycenter(emi)
		for p in all(emi.particles) do
			p.gcx = player.x + 12
			p.gcy = player.y
			p.gvx = (p.gcx - p.x)/100
			p.gvy = (p.gcy - p.y)/100
			local gvlen = sqrt(p.gvy*p.gvy + p.gvx*p.gvx)
			p.gx = (p.g*p.gvx)/gvlen
			p.gy = (p.g*p.gvy)/gvlen
		end
	end
-- emiter 
	emiter = {
		limit = 390,
		x = 100,
		y = 100,
		counter=0,
		endless=false,
		speed = 0,
		starttime = 0,
		current = 0,
		cumulate=2,
		particles = {},
		lastfor=0
	}
	function emiter:init()
		self.first = true
		self.active = true
	end
	function emiter:generate()
		if(self.current-self.starttime<self.speed and not self.first) then
			return false
		else
			self.first = false
			if self.callback != nil then self:callback(self) end
			self.starttime = time() 
		end
		for i=1, self.cumulate do
			if(#self.particles > self.limit) del(self.particles,self.particles[1])
			if self.counter>0 or self.endless then
				add(self.particles, self:createparticle())
				self.counter-=1
			end
		end
	end
	function emiter:logic()
		self.current = time()
		if self.active then self:generate() end
		if self.logiccallback != nil then self:logiccallback(emi) end
		for p in all(self.particles) do
			p.age = (time()-p.birthtime)
			if(p.maxage<p.age) then
				del(self.particles,p)
			elseif p.y>120 or p.y<16 or p.x>128 or p.x<8  then 
				del(self.particles,p) 
			else
				p:logic()
			end
		end
	end
	function emiter:draw()
		for p in all(self.particles) do
			p:draw()
		end
	end
	function emiter:reset()
		for p in all(self.particles) do
			del(self.particles,p)
		end
	end
	function emiter:createparticle()
		local part = setmetatable(deepclone(basicparticle),{__index = basicparticle})
		part.x=self.x
		part.y=self.y 
		part.g=self.g
		part.gvx=self.gvx
		part.gvy=self.gvy
		part.ltime = self.ltime
		part.epower = self.epower
		part.ssize = self.ssize
		part.esize = self.esize
		part.basecolor = self.basecolor
		part.maxage = self.maxage
		part.birthtime = time()
		part.gcx = self.gcx
		part.gcy = self.gcy
		if(self.gcy and self.gcy) then 
			 self.gvx = (self.gcx - self.x)/100
			 self.gvy = (self.gcy - self.y)/100
		end
		local gvlen = sqrt(part.gvy*part.gvy + part.gvx*part.gvx)
		part.gx = (part.g*part.gvx)/gvlen
		part.gy = (part.g*part.gvy)/gvlen
		local angle = rnd(1)
		local len = rnd(1)
		part.evx = len*sin(angle)
		part.evy = len*cos(angle)
		return part
	end
-- besic particle
	basicparticle = {
		x = 64,
		y = 64,
		vx = 0, 
		vy = 0,
		evx = 0,
		evy = 0,
		gvx = 0,
		gvy = 0,
		g = 0,
		gx = 0,
		gy = 0,
		birthtime = 0,
		ltime=0,
		age = 0,
		maxage = 1,
		color = 7,
		hdist = 0,
		vdist = 0,
		colors={1},
		sprites={},
		ssize = 1,
		esize = 1,
		size = 1
	}
	function basicparticle:draw()
		if self.size>1 then
			circfill(self.x,self.y,self.size,self.color) 
		else
			pset(self.x,self.y,self.color)
		end
	end
	function basicparticle:logic()  
			efactor = keepbetween(self.maxage-self.age,0,self.maxage)/self.maxage
			
			gfactor = self.gy*(self.age*self.age)/25
			self.gvy=gfactor
			gfactor = self.gx*(self.age*self.age)/25
			self.gvx=gfactor
			self.vx=self.evx*efactor*self.epower + self.gvx 
			self.vy=self.evy*efactor*self.epower + self.gvy
			self.x+=self.vx
			self.y+=self.vy
			local tfactor = self.age/self.maxage
			cindex = keepbetween(-12+18*tfactor,0,6)
			addr = 0x0000+(self.basecolor+64)*64+13 + flr(cindex/2)
			local memp = peek(addr)
			local pix1 = band(memp,0x0f)
			local pix2 = band(memp,0xf0)/16
			self.color = pix1
			--if flr(cindex)%2==0 then self.color = pix1 end
			--if flr(cindex)%2==1 then self.color = pix2 end
			local sfactor = self.ssize+(self.esize-self.ssize)*tfactor
			self.size = sfactor 
	end 

--module stages helper
	stage = {
		intro = 0,
		start = 1,
		game = 2,
		gend = 3,
		credits = 4,
		gameover = 5,
		instructions = 6,
		current=0,
		lastload = 0,
		newstage = -1,
		fade=false
	}
	
	function stage:fadestageto(newstage)
		music(-1,1500)
		self.newstage = newstage
		c=0
		self.fade = true
	end
	c=0
	function stage:fadestage()
		c+=0.2
		for y=0,15 do
			addr = 0x0000+(y+64)*64+9+flr(c)
			local memp = peek(addr)
			local pix1 = band(memp,0x0f)
			local pix2 = band(memp,0xf0)/16
			if flr(c)%2==0 then pal(y,pix1,true) end
			if flr(c)%2==1 then pal(y,pix2,true) end
		end
		if (c>=3) then
			pal()
			self.fade = false
			self:load(self.newstage) 
			return true
		end
	end
	function stage:load(stageid)
	    music(-1,0)
		--if (self.lastload + 0.5 > time()) return false 
		self.lastload = time()
		self.current = stageid
		if(stageid==self.game) game:init()
		if(stageid==self.intro) intro:init()
		if(stageid==self.credits) credits:init()
		if(stageid==self.start) startscreen:init()
		if(stageid==self.gameover) gameover:init()
		if(stageid==self.instructions) instructions:init()
	end
	function stage:is(stageid)
		return (stageid==self.current)
	end
--stage gameover
	gameover = {
	}
	function gameover:init()
	    music(7,1500)
		board:clear()
	end
	function gameover:logic()
		if btn(5) then
			stage:fadestageto(stage.start)
		end
	end
	function gameover:draw()
		palt(0,false)
		board:draw()
		palt(0,true)
		self:showendgame()
	end
	function gameover:showendgame()
		palt(0, false)
		map(32,18,0*8,2*8,16,9)
		player:drawstats()
		rectfill(1*8-3,120,4*8+4,120+6,0)
		print("— again",1*8,120,6)
		palt(0, true)
	end
--stage intro
	intro = {
		tlines = {
		"space: the final frontier.",
		"these are the voyages",
		"of the starship supprise",
		"and its capitan mr. spot.",
		"his brave mission is...",
		"to explore strange new worlds,",
		"to seek out new life",
		"and new civilizations,",
		"to boldly go where no man", 
		"has gone before",
		"to make galaxy ... more blue"
		}
	}
	function intro:init()
		shift = 0
		--emiter:start(64,110,0.16,18.81,2,{6,6,12,12,12,12,12,13,13,13,13,1,1,1,1,1})
	end
	function intro:update()
		stars:logic()
		if btnp(5) then
			stage:fadestageto(stage.start)
		end
	end
	shift = 0
	slowmo = 0	
	function intro:drawfgr()
		pal()
		slowmo+=1
		local cy = 5
		clip(0,5,127,90)
		foreach(self.tlines, function(txt)
			print(txt,5,max(5,100-shift/5)+cy,7)
			cy+=7
		end)
		clip()
		shift = keepbetween(shift+2,0,4192)
		--highlight(7,5,100,6)
		print("— next",2,120,6)

	end
	function intro:draw()
		cls(0)
		stars:draw()
		self:drawfgr()
	end
--stage credits
	creditsmetatable = {__index = intro}
	credits = {
		tlines = {
		{"design and programming",13},
		{"zygmunt wychowaniec",6},
		{"",6},
		{"mr. spot design",13},
		{"szarlota pawel",6},
		{"",6},
		{"mr. spot real name is kleks. ",9},
		{"he is fictional comic book",9},
		{"character created in 1973.",9},
		{"",6},
		{"music",13},
		{"zygmunt wychowaniec",6},
		{"",6},
		{"",6},
		{"level designers",13},
		{"",6},
	}}
	function credits:init()
			shift = 0
			music(0,1500)
	end
	function credits:drawfgr()
		slowmo+=1
		local cy = 5
		clip(0,5,127,90)
		local color = 12
		foreach(self.tlines, function(obj)
			print(obj[1],65-4*#obj[1]/2,100-shift/5+cy,obj[2])
			cy+=6
			color+=1
		end)
		foreach(lvlnames, function(obj)
			print(obj[1],65-4*#obj[1]/2,100-shift/5+cy,9)
			cy+=6
			if #obj[2] != 0 then
				print("by",64-4*1,100-shift/5+cy,12)
				cy+=6
				print(obj[2],65-4*#obj[2]/2,100-shift/5+cy,12)
				cy+=6
				print("",64-4*0,100-shift/5+cy,12)
				cy+=6
				
			end
		end)
		if 100-shift/5+cy<0 then 
			shift = 0
		else
		 	shift+=1
		end 
		clip()
		print("— back",1*8,120,6)
	end
	credits = setmetatable(credits, creditsmetatable)
--module stars
	stars = {
		frame = 0,
		density = 3
	}

	star = {
		x = 0,
		y = 0,
		dx = -1,
		dy = 0,
		sn = 134,
		size=1
	}

	function stars:logic()
		self.frame+=1
		star.dy = 0
		star.x = 128
		local layer = 0
		if self.frame%self.density == 0 then
			star.y = 10+rnd(22)*6
			layer = flr(rnd(5))
			star.dx = -0.5-layer*layer*0.5
			star.sn = 134 + (4-layer)*16
			star.size = 1
			add(self,deepclone(star))
		end
		if self.frame%(self.density*60) == 0 then
			star.y = 80+rnd(10)*4
			layer = flr(rnd(4))
			star.dx = -0.4 - 0.2*layer*layer
			star.sn = 136+layer*2
			star.size = 2
			add(self,deepclone(star))
		end
		foreach(self, function(s)
			s.x+=s.dx
			s.y+=s.dy
			if(s.x<-128) del(self,s)
		end)
	end
	function stars:draw()
		foreach(self, function(s)
			spr(s.sn,s.x,s.y,s.size,s.size)
		end)
	end
	function stars:reset()
		foreach(self, function(s)
			del(stars,s)
		end)
	end
--stage startscreen
	startscreen = {
	}
	function startscreen:update()
		stars.frame+=1
		star.dy = 0
		star.x = 128
		local layer = 0
		stars.density = 10
		if stars.frame%stars.density == 0 then
			star.y = 100+rnd(3)*8
			layer = 2+flr(rnd(3))
			star.dx = -0.5-layer*layer*0.5
			star.sn = 134 + (4-layer)*16
			star.size = 1
			add(stars,deepclone(star))
		end
		foreach(stars, function(s)
			s.x+=s.dx
			s.y+=s.dy
			if(s.x<-128) del(stars,s)
		end)

		if (btn(5)) stage:fadestageto(stage.instructions)
		if (btn(4)) stage:fadestageto(stage.credits)
	end
	function startscreen:draw()
		cls(0)
		--map(16,18)
		map(16,18,0,0,17,14)
		foreach(stars, function(s)
			spr(s.sn,s.x,s.y,s.size,s.size)
		end)
		color(6)
		print("— start",2,120,6)
		print("Ž credits,v."..version.." 2018",5*8+4,120,13)
		--highlight(6,0,50,12)
	end
	function startscreen:init()
		stars:reset()
		music(3,1500)
	end
--module aiming
	aiming = {
		ax = 0,
		ay = 0,
		on = false,
		ylim = 90,
		active = false
	}
	function aiming:reset()
		self.ax = 0
		self.ay = 0
		self.on = false
		self.active = false
	end
	function aiming:activate()
		self.ax = 0
		self.ay = 0
		self.on = false
		self.active = true
	end
	function aiming:place(px,py)
			self.ax = px
			self.ay = py
			self.on = true
	end
	function aiming:logic()
		if self.active and btnp(4) then 
			if ball.y<self.ylim then
					self:place(ball.x,ball.y)
					sfx(4)
				else
			end
		end
	end
	function aiming:draw(px,py)
		if self.active then
 			if self.on then 
			spr(17,self.ax,self.ay) 
			end
		end
	end
--module powerups
	powerups = {
		aiming = true,
		aimenergy = 1.5*8,
		inkshot = true,
		inkshotenergy = 14.5*8,
		fireshot = true,
		fireshotenergy = 3.5*8, --43,
		multiball = true,
		multiballenergy = 7.5*8, -- 28,
		glue = false,
		glueenergy = 11.5*8,
		energylevel = 0,
		poweruptime=10000,
		starttime=0,
		rolledstarttime=time(),
		rolledpowerup = "",
		isrolled = true,
		rolledpowercolor = 7
	}
	function powerups:drawstate()
		local sx=7*8+1
		local ic=112
		rectfill(sx-1,4,sx+5*8,11,0)
		spr(ic,sx,5,5,1)  
		ic=96
		if (self.aiming) then spr(ic,sx,5,1,1)  end
		if (self.fireshot) then spr(ic+1,sx+8,5,1,1)  end
		if (self.multiball) then spr(ic+2,sx+16,5,1,1)  end
		if (self.glue) then spr(ic+3,sx+24,5,1,1) end
		if (self.inkshot) then spr(ic+4,sx+32,5,1,1)  end  
		--powerups:energy(128)
		rectfill(0,120+7,self:escale(self.energylevel,128, 128),120+8,12)
		local sy = keepbetween(124-self:escale(self.energylevel,128,109),0,124   )
		--rectfill(126,sy,127,124,self:powercolor())
		drawprogress(125,127,(127-sy)/4,self:powercolor(),0,-1)
		--rectfill(126,sy,127,sy+2,7)
		--rectfill(126,124,127,126,7)
			
		if self.isrolled then
			local sy = keepbetween(3*8+self:escale((time()-self.rolledstarttime),self.poweruptime/1000,100),0,122)
			--rectfill(0,sy,1,124,self.rolledpowercolor)
			drawprogress(0,127,(127-sy)/4,self.rolledpowercolor,0,-1)
			--rectfill(0,sy,1,sy+2,7)
			--rectfill(0,124,1,126,7)
		end
	end
	function drawprogress(x,y,boxes,color,dx,dy)
		for i=1,boxes do
			local px = x+i*4*dx+abs(dx)
			local py = y+i*4*dy+abs(dy) 
			rect(px,py,px+2,py+2,color)
		end
	end
	function powerups:init()
		powerups:deactivateall()
		powerups:energy(0)
	end	
	function powerups:logic()
		if self.energylevel>self.glueenergy-10 then self:charge(-0.00) end
		if self.isrolled then
			if time()-self.rolledstarttime>self.poweruptime/1000 then
				self:deactivate(self.rolledpowerup)
				self.isrolled  = false
			end
		else
			self.aiming = self.energylevel>self.aimenergy
			self.inkshot = self.energylevel>self.inkshotenergy
			self.fireshot = self.energylevel>self.fireshotenergy
			self.multiball = self.energylevel>self.multiballenergy
			self.glue = self.energylevel>self.glueenergy

			if (self.aiming) then self:activate("aiming") else self:deactivate("aiming") end 
			if (self.inkshot) self:activate("inkshot")
			if (self.fireshot) self:activate("fireshot")
			if (self.multiball) self:activate("multiball")
		end
	end	
	function powerups:powercolor()
		local pcolor = 7
		if(self.fireshot) pcolor = 10
		if(self.multiball) pcolor = 8
		if(self.glue) pcolor = 11
		if(self.inkshot) pcolor = 12
		return pcolor
	end
	function powerups:escale(elevel,maxlvl,towhat)
		return elevel*towhat/maxlvl
	end
	function powerups:activate(spower)
		self[spower] = true
		if (spower == "aiming" and not aiming.active) aiming:activate()
		if (spower == "inkshot" and not shots.active) shots:activate()
		if (spower == "fireshot" and not fshots.active) fshots:activate()
		if (spower == "multiball" and not mballs.active) mballs:activate()
	end
	function powerups:activatefor(spower, itime)
		self[spower] = true
		if (spower == "aiming" and not aiming.active) aiming:activate()
		if (spower == "inkshot" and not shots.active) shots:activate()
		if (spower == "fireshot" and not fshots.active) fshots:activate()
		if (spower == "multiball" and not mballs.active) mballs:activate()
		self.poweruptime = itime
	    self.rolledstarttime = time()
		self.rolledpowerup = spower
		self.isrolled = true
	end
	function powerups:turnrolledof()
		self.poweruptime = 0
		self.poweruptime = 0
	    self.rolledstarttime = time()
		self.rolledpowerup = ""
		self.isrolled = false
	end
	function powerups:deactivate(spower)
		self[spower] = false
		if (spower == "aiming") aiming:reset()
		if (spower == "inkshot") shots:deactivate()
		if (spower == "fireshot") fshots:deactivate()
		if (spower == "multiball") mballs:deactivate()
	end
	function powerups:deactivateall()
		for key,value in pairs(powerups) do
			if type(value) == "boolean" then 
				self:deactivate(key)
			end
		end
	end
	function powerups:roll()
		local rollvalue = flr(rnd(10))
		self.rolledpowercolor = 7
		if(rollvalue>=9)then 
			if player.lives == player.maxlive then
				game:showtext(2000,"energy drain")
				self.energylevel=self.fireshotenergy*0.6 
			else
				player.lives+=1
				game:showtext(2000,"extra live")
			end
		elseif(rollvalue>=6)then 
			game:showtext(2000,"multiball fiesta")
			self:activatefor("multiball",15000) 
			self.rolledpowercolor = 8
		elseif(rollvalue>=4)then 
			game:showtext(2000,"sticky hands")
			self:activatefor("glue",15000) 
			self.rolledpowercolor = 11
		else 
			game:showtext(2000,"ink burst")
			self:activatefor("inkshot",10000)
			self.rolledpowercolor = 12
		end
	end
	function powerups:energy(elevel)
		self.energylevel = elevel
	end
	function powerups:charge(ene)
		self.energylevel = keepbetween(self.energylevel+ene,0,128)
	end
	function powerups:oneacttive()
			for key,value in pairs(powerups) do
				if type(value) == "boolean" then 
					if value then return true end
				end
			end
			return false
	end
--stage game
	game={
		level=0,
		textshowtime = 0,
		textstarttime = 0,
		stext = "",
		toplvl = 0
	}
	lvlnames={
		{"monkey business planet",""},
		{"blueberry addiction",""},
		{"hunting nemo",""},
		{"lost fireman",""},
		{"tribute",""},
		{"the best friend",""},
		{"it likes blue too",""},
		{"golden axe",""},
		{"ink can be only blue",""},
		{"home sweet home",""},
		{"no idea for the name",""},
		{"yin and yang","zygmunt wychowaniec"},
		{"fancy bronx",""},
		{"flying sunset",""},
		{"mr. spot rgb nightmare",""},
		{"someone lost the head",""},
		{"design support","lilianna wychowaniec"},
	}
	function game:init()
		self.level = instructions.startlevel
		powerups:init()
		powerups:deactivateall()
		player:init()
		game:load(self.level)
		self.toplvl = dget(1)
		self.toplvl = self.toplvl or 0
	end
	function setallcolor(newcolor)
		for col=1,15 do
			pal(col,newcolor)
		end
	end
	function game:draw()
		cls(0)
		board:draw()
		powerups:drawstate()
		game:drawlevelname()
		game:drawtext()
		shots:draw()
		fshots:draw()
		mballs:draw()
		aiming:draw()
		ball:draw()
		player:draw()
		-- debug()
	end
	function colorall(sy,ey,color,trans)
		local addr = 0x6000+sy*64
		for y = sy,ey do
			for x = 0,63 do 
				--local cin = 1+flr((shift+x+y*0.2)/2)%20
				local memp = peek(addr)
				local pix1 = band(memp,0x0f)
				local pix2 = band(memp,0xf0)/16
				if(pix1!=trans) pix1=color  
				if(pix2!=trans) pix2=color
				poke(addr,bor(pix1,pix2*16))
				addr+=1
			end	
		end 
	end
	
	function game:fadelevelto(ilevel)
		game.level = ilevel
		self.fade = true
		self.lockgame = false
		c=0
	end	

	function game:fadescreen()
		c+=0.2
		for y=0,15 do
			addr = 0x0000+(y+64)*64+9+flr(c)
			local memp = peek(addr)
			local pix1 = band(memp,0x0f)
			local pix2 = band(memp,0xf0)/16
			if flr(c)%2==0 then pal(y,pix1,true) end
			if flr(c)%2==1 then pal(y,pix2,true) end
		end
		if (c>=3) then
			pal()
			self.fade = false
			self:load(game.level) 
			return true
		end
	end
	function game:load(ilevel)
		game.level = ilevel
		aiming:reset()
		ball:reset()
		player:reset()
		shots:reset()
		fshots:reset()
		mballs:reset()
		board:prepare(ilevel)
		game:showlevelname(5000)
		powerups:turnrolledof()
		dset(0, 1)
	end	
	function game:showtext(itimer,stext)
		self.stext = stext
		self.textstarttime = time()
		self.textshowtime = itimer
	end
	function game:hidetext()
		self.textshowtime = 0
	end
	function game:showlevelname(itimer)
		self.starttime = time()
		self.levelnameshowtime = itimer
	end
	local slidex=64
	function game:drawtext()
		if time()-self.textstarttime<self.textshowtime/1000 and #self.stext>0 then
		   	color(7)
			local slevelname = self.stext 
			rectfill(64-(#slevelname*4)/2-5,100-5,64+(#slevelname*4)/2+5,100+5+4,0)
			--rect(64-(#slevelname*4)/2-5,100-5,64+(#slevelname*4)/2+5,100+5+4,1)
			color(7)
			for i=1,#slevelname do
				local printtxt = sub(slevelname,i,i+1)
				local cols = {6,7,15}
				print(printtxt,64-(#slevelname*4)/2 + (i-1)*4,100,cols[1+i%3])
			end
			slidex = rollbetween(slidex-1,-64,64)
		end
	end
	function game:drawlevelname()
		if time()-self.starttime<self.levelnameshowtime/1000 then
		   	color(7)
			local slevelname = lvlnames[self.level+1][1] 
			rectfill(64-(#slevelname*4)/2-5,100-5,64+(#slevelname*4)/2+5,100+5+4,0)
			--rect(64-(#slevelname*4)/2-5,100-5,64+(#slevelname*4)/2+5,100+5+4,1)
			color(7)
			for i=1,#slevelname do
				local printtxt = sub(slevelname,i,i+1)
				local cols = {12,12,6,6}
				print(printtxt,64-(#slevelname*4)/2 + (i-1)*4,100,cols[1+i%4])
			end
			slidex = rollbetween(slidex-1,-64,64)
		else
		--self.levelnameshowtime
		end
	end
	function game:checklevel()
		if board.tiles <= 0 and not game.lockgame and not game.fade  then
			emiters:fireworks(64,32,0)
			powerups:turnrolledof()
			game:showtext(15000,"well done, —  to continue")
			game.level = min(self.level+1,14)
			game.lockgame = true
			game.toplvl = max(game.level, game.toplvl)
			dset(1, game.toplvl)
		end
	end
	function game:logic()																																								
		 if game.lockgame then 
		 	if btnp(5) then
				emiters:reset()
				game:hidetext()
		 		game.lockgame = false
				debugboj = game
		 		self:fadelevelto(game.level)
		 	end
		 end
	
		tno+=1
		if not btn(‹) and not btn(‘) then  
			hanim = 0
			mtime = 0
		end

		if btnp(5,1) then
			self.level = rollbetween(self.level+1,0,self.toplvl)
			game:fadelevelto(game.level)
		end
		if not game.showgameover then
			powerups:logic()
			aiming:logic()
			if (not game.lockgame) then 
				player:logic()
				ball:logic()
				mballs:logic()
				shots:logic()
				fshots:logic()
				game:checklevel()
			end
		end
	end
	zam = false
	mtime = 0
	hflip = false
	tno = 0
--module ball
	ball = {
		primary=true,
		x=0,
		y=0,
		mx=0,
		my=0,
		cmx=0,
		cmy=0,
		dx=1,
		dy=-1,
		adx=0,
		ady=0,
		size = 5,
		active=true,
		bcol = false,
		xchange = false,
		ychange = false,
		sprn = 4,
		angle = 2,
		angles = {
			{dx=1.5,dy=0.75}, -- decr
			{dx=1,dy=1}, -- normal
			{dx=0.75,dy=1.25} -- incre
		}
	}
	function ball:moveto(px,py)
		self.x = px
		self.y = py
		self.mx = flr(px/8)
		self.my = flr(py/8)
	end
	function ball:move()
			self.x += self.dx*gamespeed
			self.y += self.dy*gamespeed
			self.mx = flr(self.x/8)
			self.my = 16+flr(self.y/8)
	end
	function ball:reset()
		self.x=0
		self.y=0
		self.mx=0
		self.my=0
		self.angle = 2
		self.dx=self.angles[2].dx*gamespeed
		self.dy=-self.angles[2].dy*gamespeed
		self.active = true
	end
	function ball:logic()
		if self.active then
			if player.sticky then
				if(player.bdirect!=mtime and mtime!=0) player.bdirect=mtime
				self:moveto(flr(player.x+13-self.size/2+player.bdirect*3),player.y-6)
			else
				board:collision(ball)
				if self.bcol then 
					if self.ychange then
						self.dy*=-1
					end
					if self.xchange then 
						self.dx*=-1
					end
					self.xchange = false
					self.ychange = false
					self.bcol = false
					board:removecolidedtiles()
				end
					self:move()					
			end
		end
	end
	function keepbetween(val, min, max)
		local ret = val
		if (val<=min) val = min
		if (val>=max) val = max
		return val
	end
	function rollbetween(val, min, max)
		local ret = val
		if (val<min) val = max
		if (val>max) val = min
		return val
	end
	function ball:changeangle(sdirection)
			self.angle = keepbetween(self.angle+sdirection,1,3)
			self.dx = self.angles[self.angle].dx*sign(self.dx)*gamespeed
			self.dy = self.angles[self.angle].dy*sign(self.dy)*gamespeed
	end
	function ball:resetangle()
			self.angle = 2
			self.dx = self.angles[self.angle].dx*sign(self.dx)*gamespeed
			self.dy = self.angles[self.angle].dy*sign(self.dy)*gamespeed
	end	
	function ball:draw()
		if (self.y>aiming.ylim or not aiming.active) then 
			self.sprn=1
		else 
			self.sprn=4 
		end
		spr(self.sprn,self.x,self.y) 
		--ball:drawcollisionmarkers(self)
	end
--module player
	player={
		x=48,
		y=120,
		dx=2,  
		mx=0,
		my=0,
		lives=5,
		maxlives=5,
		sticky=true,
		score=0,
		bdirect=1
	}
	hanim = 0
	function player:reset()
		self.x=48
		self.y=120
		self.sticky=true
	end
	function player:init()
		self.x=48
		self.y=120
		self.dx = self.dx*gamespeed
		self.mx=0
		self.my=0
		self.lives=5
		self.maxlives=5
		self.sticky=true
		self.score=0
		self.bdirect=1
	end
	function player:moveto(px,py)
		self.x = px
		self.y = py
		self.mx = flr(px/8)
		self.my = flr(py/8)
	end
	function player:move(ldx,ldy)
		self.x += ldx
		self.y += ldy
		self.mx = flr(self.x/8)
		self.my = flr(self.y/8)
		self:calculateamingvector(ball) 
	end
	function player:draw()
		player:drawplayer()
		player:drawstats()
	end
	function player:drawstats()
		-- draw lives
		rectfill(2,4,5*8+2,11,0)
		for i=0,player.maxlives-1 do
			if (i+1>player.lives) spr(6,i*8+3,5) else spr(3,i*8+3,5)
		end
		-- draw score
		local lx = 128-6*4
		local stxt = sub("000000" .. self.score,-6)
		print(stxt,lx+1,6,13)
			print(stxt,lx,5,6)
	end
	function player:drawplayer()
		if(self.x<1*8) self.x=1*8
		if(self.x>12*8) self.x=12*8
		local shift = {0,1,1,1,1,1,1,2,2,2,3,3,3,3,2,2,2,1,1,1,1,1,1,0}
		local strum = {}
		local starty = self.y
		local toy
		for g=1,24,1 do
			local oy = 0
			local dist = self.y-ball.y-ball.size
			if (not powerups.glue and ball.x>self.x and ball.x<self.x+24 and not ball.sticky and not ball.isover) oy = shift[g]-dist 
			if powerups:oneacttive() then
				toy = self.y + (0.6-rnd(1.2))*shift[g]
				if (g)%4==0 then
					strum[g]=toy
					line(self.x+g-3, starty,self.x+g,strum[g]+max(0,oyr),powerups:powercolor())
					starty = strum[g]
				end
			else
				pset(self.x+g,self.y+max(0,oy),powerups:powercolor())
			end
		end
		spr(80,self.x-4,self.y,4,2)
		if mtime == 0 then
			spr(64+hanim%8,self.x-1,self.y-1,1,1,false)	
			spr(64+hanim%8,self.x+20,self.y-1,1,1,false)
		elseif mtime==1 then
			if(hanim<=7) then
				spr(64+hanim%8,self.x+20,self.y-1,1,1,hflip)
				spr(64,self.x-3,self.y-1,1,1,hflip)	
			else
				spr(64+hanim%8,self.x-3,self.y-1,1,1,hflip)
				spr(64,self.x+20,self.y-1,1,1,hflip)
			end
		elseif mtime==-1 then
			if(hanim<=7) then
				spr(64+hanim%8,self.x-4,self.y-1,1,1,hflip)
				spr(64,self.x+20,self.y-1,1,1,hflip)
			else
				spr(64+hanim%8,self.x+20,self.y-1,1,1,hflip)
				spr(64,self.x-4,self.y-1,1,1,hflip)	
			end
		end
	end
	function player:logic()
		if btnp(4) then 
			if	self.sticky then
				ball.active = true
				self.sticky = false 
				if not aiming.on then
					ball.dx=self.bdirect*gamespeed
					ball.dy=-gamespeed
				else
					ball.dx=ball.adx
					ball.dy=ball.ady
					aiming.on = false
				end
			end
		end
		if btn(0) then 
			mtime=-1
			hanim+=1
			hflip = true
			if(hanim>=16) hanim=0
			if (self.x>5) self:move(-self.dx,0) 
		end
		if btn(1) then 
			mtime=1
			hanim+=1
			hflip = false
			if(hanim>=16) hanim=0
			if(self.x<102) self:move(self.dx,0)
		end
		if btnp(2) then 
			if (powerups.inkshot and not self.sticky) then
					shots:addball(self.x,self.y,144)
					--powerups:charge(-4)
				end 
		end
		if not player:collision(ball) then
			self.lives-=1
			--powerups:energy(0)
			--powerups:deactivateall()
			if self.lives!=0 then
				player.sticky = true
				ball:reset();
			else
				stage:fadestageto(stage.gameover)
			end
		else
		end
	end
	sqrt2 = sqrt(2)
	function player:collision(obj)
		if obj.y+obj.size>=self.y and obj.dy>0 then
			if obj.x>=self.x-obj.size and obj.x<=self.x+obj.size+24 and not obj.isover then
				obj.cside=3
				obj.bcol = x
				if(powerups.fireshot and obj.primary)then
					fshots:addball(player.x+0,self.y,128)
				end
				if (powerups.multiball and obj.primary)	then
					local mdx = sgn(1-rnd(2))*obj.angles[1+flr(rnd(10))%3].dx*gamespeed
					local mdy = -1*obj.angles[1+flr(rnd(10))%3].dy*gamespeed
					mballs:addball(self.x+10,self.y,mdx,mdy,5)
				end
				if powerups.glue and obj.primary then 
					self.sticky = true
				elseif aiming.on and obj.primary then
					powerups:charge(1)
					self:calculateamingvector(obj) 
					obj.dx = obj.adx
					obj.dy = obj.ady
					aiming.on = false
				else
					powerups:charge(1)
					if mtime!=0 and obj.angle==2  then
						obj:changeangle(-mtime*sgn(obj.dx))
					else
						obj:resetangle()
					end
					obj.dy*=-1
				end
				obj:moveto(obj.x,player.y-4)
				return true
			else
				obj.isover = true
				if obj.y+obj.size<=128 and obj.dy>0 then
					return true
				else 
					sfx(2)
					obj.isover = false
					return false
				end
			end
		end
		return true
	end
	function player:calculateamingvector(obj)
		local vx = aiming.ax - obj.x 			
		local vy = aiming.ay - obj.y
		vfactor = vx/vy
		vfactor=vfactor/abs(vfactor)*max(abs(vfactor),0.1*gamespeed)
		obj.adx = -vfactor*gamespeed
		obj.ady = -1*gamespeed
	end
--module board
	board = {
		maxx = 13,
		maxy = 8,
		tiles = 0,
		colidedtileslist = {}
	}
	function board:draw()
		map(0,0)
		map(0,16)
	--		board:completetiles(game.level)
		rect(0,127,127,127,2)
	end
	function board:clear()
		for i=1,14 do
			for j=0,12 do
				mset(i,j+18,159)
			end
		end
	end
	-- function board:completetiles(ilvl)
	-- 	-- local lx = 16+(ilvl%8)*14 
	-- 	-- local ly = flr(ilvl/8)*9

	-- 	-- for i=0,board.maxx do
	-- 	-- 	for j=0,board.maxy do
	-- 	-- 		ls = mget(lx+i, ly+j)
	-- 	-- 		lsf = fget(ls,2)
	-- 	-- 		if lsf then
	-- 	-- 			local top = (i+1)*8
	-- 	-- 			local left = (j+18)*8

	-- 	-- 			if mget(i+1,j+18) != ls then	
	-- 	-- 				if (fget(ls,7)) line(left+8,top,left+8,top+7,7)
	-- 	-- 				if (fget(ls,6)) line(left+8,top,left+8,top+7,7)
	-- 	-- 				if (fget(ls,5)) line(left+8,top,left+8,top+7,7)
	-- 	-- 				if (fget(ls,4)) line(left+8,top,left+8,top+7,7)
	-- 	-- 			else

	-- 	-- 			end
	-- 	-- 		end
	-- 	-- 	end
	-- 	-- end
	-- end
	function board:prepare(ilvl)
		self.tiles = 0
		local lx = 16+(ilvl%8)*14 
		local ly = flr(ilvl/8)*9
		for i=0,board.maxx do
			for j=0,board.maxy do
				ls = mget(lx+i, ly+j)
				lsf = fget(ls,0)
				mset(i+1,j+18,0)
				if lsf then 
					mset(i+1,j+18,ls)
					mset(i+1,j+2,0) 
					self.tiles+=1 
				else
					mset(i+1,j+2,ls)
				end
			end
		end
	end
	function ball:drawcollisionmarkers(obj)
		local x,y
		if obj.dy<0 then
			x = obj.x+obj.size/2
			y = obj.y+obj.dy
			pset(x,y,7)
		end
		if obj.dy>0 then
			x = obj.x+obj.size/2
			y = obj.y+obj.size+obj.dy-1
			pset(x,y,7)
		end
		
		if obj.dx<0 then
			x = obj.x+obj.dx
			y = obj.y+obj.size/2
			pset(x,y,7)
		end

		if obj.dx>0 then
			x = obj.x+obj.size+obj.dx-1
			y = obj.y+obj.size/2
			pset(x,y,7)
		end
	end
	function board:collision(obj)
		obj.bcol=false
		obj.cside=0
		local cmx = -1
		local cmy = -1
		if obj.dy<0 then
			cmx = flr((obj.x+obj.size/2)/8)
			cmy = 16+flr((obj.y+obj.dy)/8)
			local sn = mget(cmx,cmy)
			local fn = fget(sn,0)
			if (fn and (sn!=0)) then
				obj.bcol = true
				add(self.colidedtileslist,{mx=cmx,my=cmy})
				obj.ychange=true
			end
		end
		if obj.dy>0 then
			cmx = flr((obj.x+obj.size/2)/8)
			cmy = 16+flr((obj.y+obj.size+obj.dy)/8)
			sn = mget(cmx,cmy)
			fn = fget(sn,0)
			if (fn and (sn!=0)) and cmy<=30  then
				add(self.colidedtileslist,{mx=cmx,my=cmy})
				obj.bcol = true
				obj.ychange=true
			end
		end
		
		if obj.dx<0 then
			cmx = flr((obj.x+obj.dx)/8)
			cmy = 16+flr((obj.y+obj.size/2)/8)
			local sn = mget(cmx,cmy)
			local fn = fget(sn,0)
			if (fn and (sn!=0)) then
				obj.bcol = true
				add(self.colidedtileslist,{mx=cmx,my=cmy})
				obj.xchange=true
			end
		end

		if obj.dx>0 then
			cmx = flr((obj.x+obj.size+obj.dx)/8)
			cmy = 16+flr((obj.y+obj.size/2)/8)
			sn = mget(cmx,cmy)
			fn = fget(sn,0)
			if (fn and (sn!=0)) then
				obj.bcol = true
				add(self.colidedtileslist,{mx=cmx,my=cmy})
				obj.xchange=true
			end
		end
		return obj.bcol
	end
	function board:lastpoweruptile(mx,my,allf)
		local ptileind = band(allf,48)
		local xf = 0
		local xt = 1
		local yf = 0
		local yt = 1

		local islast = true
		if ptileind == 32 or ptileind == 48 then
			xf = -1
		    xt = 0
		end
		if ptileind == 16 or ptileind == 48 then
			yf = -1
		    yt = 0
		end

		for lmx = mx+xf,mx+xt do
			for lmy = my+yf,my+yt do
			 	islast = islast and not fget(mget(lmx,lmy),2)
			end
		end
		return islast
	end
	function board:removetile(mx,my)
		sno = mget(mx,my)
		sf0 = fget(sno,0)
		sf1 = fget(sno,1)
		
		sf6 = fget(sno,6)
		sf7 = fget(sno,7)
		sf2 = fget(sno,2)
		local allf = fget(sno)
		if sf0 and my<=30 then
			sfx(5)
			if sf2 then
				emiters:smallexplosion(mx*8+4,my*8-128+4)
				player.score+=30
				local cor=sno-72
				cor=102+cor%2+16*(flr(cor/16)%2)
				mset(mx,my,cor)
				if board:lastpoweruptile(mx,my,allf) then
					powerups:roll()
				end				
				board.tiles-=1	
			else
				player.score+=30  
				if sf6 then 
					board.tiles-=2
					player.score-=15  
					mset(mx,my,38)
					mset(mx+1,my,39)
				end
				if sf7 then 
					mset(mx-1,my,38)
					mset(mx,my,39)
					board.tiles-=2
					player.score-=15  
				end
				if sf1 then 
					player.score+=15
					mset(mx,my,55)
					board.tiles-=1
				end
			end
		end
	end
	function board:checkscore(ilvl)
		local tiles = 0
		for i=0,board.maxx do
			for j=0,board.maxy do
				ls = mget(i+1,j+18)
				lsf = fget(ls,0)
				if lsf then 
					tiles+=1 
				end
			end
		end
		return tiles
	end
	function board:removecolidedtiles()
		foreach(self.colidedtileslist, function(mt)
			self:removetile(mt.mx,mt.my)
			del(self.colidedtileslist,mt)	
		end)
		-- if board:checkscore(game.level) != self.tiles then
		-- 	print("tiles!"..self.tiles..":"..board:checkscore(game.level))
		-- end 
	end
--module shots
	shots = {
		lside = false,
		active = false,
		mode = 1,
		ix = 8*8
	}
	local metatable = {__index = shots}
	fshots = {mode=2}
	fshots = setmetatable(fshots, metatable)
	shot = {
		x=0,
		y=0,
		mx=0,
		my=0,
		dx=0,
		dy=-2,
		sprn = 144,
		active = false,
		size = 6,
		cmx = 0,
		cmy = 0,
		bcol = false,
		cside = 0
	}
	function shots:init()
		self.dy*=gamespeed
		self:deactivate()
		foreach(self, function(b)
			del(self,b)
		end)
	end
	function shots:activate()
		self.active = true
	end
	function shots:deactivate()
		self.active = false
	end
	function shots:addball(px,py,sn)
		if(not self.active) return false
		shot.x=px+2
		shot.y=py
		shot.sprn = sn
		if self.mode==1 then
			lside = not lside
			if lside then
				add(self,deepclone(shot))
			else
				shot.x=px+20
				add(self,deepclone(shot))
			end
			elseif(self.mode==2)then 
				add(self,deepclone(shot))
				shot.x=px+20
				add(self,deepclone(shot))
			else
				add(self,deepclone(shot))
			end
		sfx(6)
	end
	function shots:draw()
		foreach(self, function(sh)
				spr(sh.sprn,sh.x,sh.y,1,1)
		end)
	end
	function shots:reset()
		foreach(self,function(s) del(self,s) end)
	end
	function shots:logic()
		foreach(self, function(sh)
			sh.y+=sh.dy
			sh.x+=sh.dx
			if sh.y+16<0 or sh.y-16>128 or sh.x+16<0 or sh.x-16>128 then
				del(self,sh)
			else
				board:collision(sh) 
				if sh.bcol then
					board:removecolidedtiles()
					del(self,sh)
				end
			end
		end)
	end
--module multiball
	mballs = {
		limit = 2,
		active = true,
		count = 10
	}
	mball = {
		primary=false,
		sprn = 5,
		x=0,
		y=0,
		mx=0,
		my=0,
		cmx=0,
		cmy=0,
		dx=2,
		dy=-2,
		size = 4,
		active=true,
		bcol = false,
		cside = 0
	}
	local mballmetatable = {__index = ball}
	mball = setmetatable(mball, mballmetatable)
	function mballs:reset()
		foreach(self, function(b)
			del(self,b)
		end)
		self.count = 10
	end
	function mballs:activate()
		self.active = true
	end
	function mballs:deactivate()
		self.active = false
	end
	function mballs:addball(px,py,pdx,pdy,sn)
		if(not self.active) return false
		if #self <= self.limit then
			mball.x=px
			mball.y=py-5
			mball.dx = pdx/1
			mball.dy = pdy/1
			mball.sprn = sn
			add(self,deepclone(mball))
		end
	end
	function mballs:logic()
		foreach(self, function(b)
			board:collision(b)
			if b.bcol then 
				if b.ychange then
					b.dy*=-1
				end
				if b.xchange then 
					b.dx*=-1
				end
				b.xchange = false
				b.ychange = false
				b.bcol = false
				board:removecolidedtiles()

			end
			if not player:collision(b) then
				del(self,b)
			end 
			b:move()
		end)
	end
	function mballs:draw()
			foreach(self, function(b)
				spr(b.sprn,b.x,b.y,1,1)
			end)
	end
__gfx__
00000000007770000fff000000707000000000000eee0000002020000000000000fffffffffff000ddddddddddddd220ddddd220aaaaaaaaaaaaa990aaaaa990
000000000777cd00f7fab0000797960000fff000e7e8500002121200000000000ffaaaaaaaaa9900ddd2222222222220dd222220aaa9999999999990aa999990
00000000077ccd00ffaab000798989600fafab00ee8850002101012000000000ffaaffaaaaaaa990dd22d22222222210d2222210aa99a99999999980a9999980
0000000007cccd00faaab000788888600ffaab00e88850002000002000000000faafaaaaaaa9aa90d22d222222212210d2222210a99a999999989980a9999980
0000000000ddd0000bbb0000078886000faaab00022500000200020000000000ffaaaaaaa99aa990d222222222122110d2222210a999999999899880a9999980
0000000000000000000000000068600000bbb0000000000000202000101000c00ffaaaaaaaaa9900222222222222111022222110999999999999888099999880
00000000000000000000000000060000000000000000000000020000c000d0010099999999999000221111111111111022111110998888888888888099888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a0000000100000000000000000000077777777777776607777766000666666666660006666666666666cc066666cc0eeeeeeeeeeeee880eeeee880
0000100000000000000000100000660000000000777666666666666077666660066cccccccccdd00666cccccccccccc066ccccc0eee8888888888880ee888880
00000000a0a0a00000000000000617d00010000077667666666666d0766666d066cc66cccccccdd066cc6cccccccccd06cccccd0ee88e88888888820e8888820
100000000000000010001000000611d00000000076676666666d66d0766666d06cc6cccccccdccd06cc6cccccccdccd06cccccd0e88e888888828820e8888820
0000000000a00000000000000000dd00000000007666666666d66dd0766666d066cccccccddccdd06cccccccccdccdd06cccccd0e888888888288220e8888820
0000100000000000000100100000000000000100666666666666ddd066666dd0066cccccccccdd00ccccccccccccddd0cccccdd0888888888888222088888220
000000000000000000000000000000000000000066ddddddddddddd066ddddd000ddddddddddd000ccddddddddddddd0ccddddd0882222222222222088222220
00000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010001000100000000300000001000001110100000666000111111111111111000eeeeeeeeeee000fffffffffffff330fffff330fffffffffffffaa0fffffaa0
0000d000000001000000003000000010101c00000611760010000000000000100ee8888888882200fff3333333333330ff333330fffaaaaaaaaaaaa0ffaaaaa0
10000010000d0000003000000010000011110000611717d01011111111111010ee88ee8888888220ff33f33333333320f3333320ffaafaaaaaaaaa90faaaaa90
00100d0000d00d0130003000100010000000c000611171d01011111111111010e88e888888828820f33f333333333320f3333320faafaaaaaaa9aa90faaaaa90
0000000000000d00000000300000001011100000611111d01011111111111010ee88888882288220f333333333333220f3333320faaaaaaaaa9aa990faaaaa90
000d1000001d00000003000000110000101c00000d111d0010000000000000100ee8888888882200333333333333222033333220aaaaaaaaaaaa9990aaaaa990
001000010000000000000000000001001110000000ddd00011111111111111100022222222222000332222222222222033222220aa99999999999990aa999990
10001d000000001003000003000000010001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010c00d0000000cc0cc001d0d100000b000b00000000000c11111111111000fffffffffff000fffffffffffffbb0fffffbb07777777777777ff077777ff0
c000c0010d00001000c171c00dc7cd000b000b000000000000000101100000100ffbbbbbbbbb3300fffbbbbbbbbbbbb0ffbbbbb0777ffffffffffff077fffff0
101000c00000d0d0000777000071700000000000000000000001011110111010ffbbffbbbbbbb330ffbbfbbbbbbbbb30fbbbbb3077ff7fffffffffb07fffffb0
000000000000000000c171c00dc7cd0000000000000000000000c00010111010fbbfbbbbbbb3bb30fbbfbbbbbbb3bb30fbbbbb307ff7fffffffbffb07fffffb0
000000000000000000cc0cc001d0d10000000000000000000000011110111010ffbbbbbbb33bb330fbbbbbbbbb3bb330fbbbbb307fffffffffbffbb07fffffb0
000000000000000000000100001000000000000000000000000c0101100000100ffbbbbbbbbb3300bbbbbbbbbbbb3330bbbbb330ffffffffffffbbb0fffffbb0
0000000000000000000010000001000000000000000b000b00000111111111100033333333333000bb33333333333330bb333330ffbbbbbbbbbbbbb0ffbbbbb0
00000000000000000001000000001000000000000b000b000000c000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000dddddddddddd22207777777777777770aaaaaaaaaaaaaaa0fffffffffffffff0
0000000000000000000000000000000000000000000000000000000000000000ddd2222222222220777ffffffffffff0aaa9999999999990fffbbbbbbbbbbbb0
0000000000000000000000000000000000000000000000000000000000000000dd22d2222222222077ff7ffffffffff0aa99a99999999990ffbbfbbbbbbbbbb0
0000000000000000000000000000000000000000000000000000000000000000d22d2200022222107ff7ff000fffffb0a99a990009999980fbbfbb000bbbbb30
0000000000000000000c0c000000000000000000000000000000000000000000d2222000002222107ffff00000ffffb0a999900000999980fbbbb00000bbbb30
0000000000c0c00000c6c6c00000c0c000000000000000000000000000000000d2220022000222107fff00ff000fffb0a999009900099980fbbb00bb000bbb30
0c0c00000c6c6c0000c6c6c0000c6c6c0000c0c0000c0c0000c0c0000c0c0000d2220222000222107fff0fff000fffb0a999099900099980fbbb0bbb000bbb30
c6c6c0000c6c6c0000c6c6c0000c6c6c000c6c6c00c6c6c00c6c6c00c6c6c000d2222220002222107ffffff000ffffb0a999999000999980fbbbbbb000bbbb30
0006776000000000000000000067760000000000000000000000000000000000d2222200022222107fffff000fffffb0a999990009999980fbbbbb000bbbbb30
000cccc0000000000000c00000cccc0000000000000000000000000000000000d2222200222222107fffff00ffffffb0a999990099999980fbbbbb00bbbbbb30
0000ccc0000c000000cc000000ccc00000000000000000000000000000000000d2222222222222107fffffffffffffb0a999999999999980fbbbbbbbbbbbbb30
000000ddc000cc000c000000cdd0000000000000000000000000000000000000d2222200222122107fffff00fffbffb0a999990099989980fbbbbb00bbb3bb30
00000000dcc000c0007770ccd00000000000000000000000000000000000000022222200221221107fffff00ffbffbb0a999990099899880fbbbbb00bb3bb330
000000000007770007117700000000000000000000000000000000000000000022222222222211107fffffffffffbbb0a999999999998880fbbbbbbbbbbb3330
00000000007711700711170000000000000000000000000000000000000000002221111111111110ffbbbbbbbbbbbbb09988888888888880bb33333333333330
00000000007111700711170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cac000000a000000cc000000707000006cc000006ccc0011111111111111107777777777776660eeeeeeeeeeee8880ffffffffffffaaa0666666666666ccc0
0c1a1c0000a9a0000c71d0000cc088000676dc000676d1d010000000000000107776666666666660eee8888888888880fffaaaaaaaaaaaa0666cccccccccccc0
c11111d00a979a000c11d0000cc088000c6d1c000c6d11d010000000000000107766766666666660ee88e88888888880ffaffaaaaaaaaaa066cc6cccccccccc0
aa1a1aa00a979a0000ddcc000cc088000cd11c000cd111d0100000000000001076676600066666d0e88e880008888820faaaaa000aaaaa906cc6cc000cccccd0
c11111d000a9a000000c71d00ccd880000c1c00000c11d00100000000000001076666000006666d0e888800000888820faaaa00000aaaa906cccc00000ccccd0
0c1a1d0000a9a000000c11d000cd800000c1c00000c11d00100001111100001076660066000666d0e888008800088820faaa00aa000aaa906ccc00cc000cccd0
00dad000000900000000dd00000d0000000d0000000dd000100001111100001076660666000666d0e888088800088820faaa0aaa000aaa906ccc0ccc000cccd0
000000000000000000000000000000000000000000000000100001111100001076666660006666d0e888888000888820faaaaaa000aaaa906cccccc000ccccd0
001110000001000000110000001010000011100000111100100001111100001076666600066666d0e888880008888820faaaaa000aaaaa906ccccc000cccccd0
010101000010100001001000011011000100010001000010100001111100001076666600666666d0e888880088888820faaaaa00aaaaaa906ccccc00ccccccd0
100000100100010001001000011011000100010001000010100000000000001076666666666666d0e888888888888820faaaaaaaaaaaaa906cccccccccccccd0
110101100100010000111100011011000100010001000010100000000000001076666600666d66d0e888880088828820faaaaa00aaa9aa906ccccc00cccdccd0
10000010001010000001001001111100001010000010010010000000000000106666660066d66dd08888880088288220aaaaaa00aa9aa990cccccc00ccdccdd0
0101010000101000000100100011100000101000001001001000000000000010666666666666ddd08888888888882220aaaaaaaaaaaa9990ccccccccccccddd0
0011100000010000000011000001000000010000000110001111111111111110666dddddddddddd08882222222222220aaa9999999999990cccdddddddddddd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a000000006000000000000000000000000000000000000070000000a0000000000100100000000000000000000000000110000000000000000000000000000
079a0000006c60001111111111111111000000000000000076700000a70000000101611d10000000000000000000000007710000000077000000000000000000
a8a9a0000ccc76002100000022211111000000000000000007000000777000001d0110101010000000000000100000000dd000000000dd000000000000000000
a998a0000dcccd003310000033333111000000000000000000000000a7a00000010011d161d1000000000001d1000000000d0077600d00000000111000000000
0a89000000ddd00044220000444222220000000000000000000000007a0000000011d010101610000000111d1d100000000d0776660d000000011d1110000000
00900000000c000055111000555555110000000000000000000000000000000001601010111100000001d1d11110000000dd7766666dd0000011dddd11100010
000000000000000066dd5000666dddd500000000000000000000000000000000011101d6d1d10100001d11dddd110000066d66d6d66d6600011dd77d7dd101d1
00900000000c000077776d50777776d5011111110000000000000000000000001d001d6a6d101d100001d1d7d1d1000000d6aa6a6aa6d0000011dddd11100010
06cc0000000000008884210088844421117777711000000006000000000000000101d1d6d100110000001dddd11d1000000d66d6d66d000000011d1100000000
676dc00000000000999421009994442117711177100000006d60000000000000000110000011d10000001111d1d10000000000d0d00000000000110000000000
c6d1c00000000000aa994200aa99942117710177100000000600000000000000001610101161000000001d1d1110000000000d000d0000000000000000000000
cd11c00000000000bbb33100bbbbb331177101771000000000000000000000000001d1d1d1101000000001d10000000000006600066000000000000000000000
0c1c000000000000ccdd5100cccddd5117710177100000000000000000000000000010101101d100000000100000000000000000000000000000000000000000
0c1c000000000000dd511000dd5551111771117710000000000000000000000000001d1016101000000000000000000000000000000000000000000000000000
00d0000000000000ee444210ee444421117777711000000000000000000000000000010001000000000000000000000000000000000000000000000000000000
0000000000000000fff94210fff99421011111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000a000000000000000000000d0000000000d0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a9a0000000000000000000d1d00000000000000001d10000000000000000000000000001111111111101111111111111111110
0111000001000000001000000a979a0010100000011000000d00000000d00000001d111000000000000d00000000000011ccccc11aa101aa11bbbbb113313310
1010100011100000011100000a979a0010100000111100000000000000000000011dddd10000000000d1d000000000001cc111cc1aa101aa1bb111bb13331110
11111000010100000111000000a9a000101000001111000000000000000000000d1d7d1d00000000000d0000000000001cc101cc1aa111aa1bbbbbbb13311000
10101000001110000010000000a9a0001010000001100000000000000000d00001dddd110000000000000000000000001cc111cc11aa1aa11bb1111113310000
011100000001000000100000000900000100000001100000000000000000000000111d1000000000000000000000000011ccccc1111aaa1111bbbbb113310000
0000000000000000000000000000000000000000000000000000000000d000000001d10001111111000000000000000001111111001111100111111111110000
0000000000000000000000000000000000ddd000000ccc00010000000000c000000d000011fffff1100000000000000000000000000000000000000000000000
000000000000000000000000000000000c111d00666ccc0010100000000cd00000dc00001ff111ff100000000000000001111111111111110111111100000000
00000000000011111111111000000000c1c111d066d7dc000100000000dcd00000dcd0001ff11111100000000000000001ccccc11999199111bbbbb110000000
0000000000111cccccccccc100000000dc1111d066777660000000000dcccd000dccdd001ff11fff1000000000000000011111cc199191991bb111bb10000000
00000000016cccc1111111cc10000000d11111d00cd76660000000000dcccdd00dc7cd001ff111ff100000000000000011cccccc199191991bbbbbbb10000000
0000000001d67cc10000001cc10000000d111d000ccc6660000000000cc7cd000d77cd001ff111ff10000000000000001cc111cc199191991bb1111110000000
000000001d6767c100000001cc10000000ddd0000ccc1000000000000dc7cd000dc7cd0011fffff1100000000000000011cccccc1991919911bbbbb100000000
0000000016d67610000000001cc1000000000000000001000000000000dcd00000dcd00001111111000000000000000001111111111111111111111100000000
00000000016d11000000000001cc10000000000000000000000000000000000000c7700060000000000000000000000000000000000000000000000000000000
000000000011000000111111111c10000000000000000000000000000600000000cc700000000000070000000000000000080000000000600000000000000000
000000000000000011cccccccccc10000000000000000000000000006d600c7700c00000000000007670000000000000000000000000000000000001d1000000
0000000000111111cccccc1cccccc10000000000000000000000000006000cc700c0000000000000070000000000000000000000000000000000001d11100000
0000000001ccccccccccc171ccccc10000000000000000000000000000000c00000c000000000000000000000000000000000000060000000000011dddd10000
000000001cc111c1cccc17771ccccc10000000000000000000000000000000c0000c0000000000000000000000060000000000000000000000000d1d7d1d0000
00000001cc1001171ccc17771cccccc1000000000000000000000000000000c0000c00000900000000000000000000000000000000000000000001dddd110000
0000001cc100017771cc17771cccccc1000000000000000000000000000000ccccccc0000000000000000000000000cccc00000000000000000000111d100000
000001cc1000017771cc17171ccccccc11000000000000000000000000000cc11111cc000000000000000000000000c11c000000000000d000000001d1000000
00001cc10000017171cc171711cccccccc100000000000000000000000000c11ccc11cccc0ccccccccccc0ccccccccc11cc0000000000d1d0000000000000000
0001cc100000017171ccc171ccccccccccc10000000000000000000000000c11c0c11c11c0c11cc11111ccc11111cc1111c00000000000d00000000000000000
001cc100000001171111111cccccc11ccccc1000000000000000000000000c11c0c11c11c0c11c11ccc11c11ccccccc11cc00000000000000000000000000000
01cc100000000011cccccccccccccc11ccccc100000000000000000000000c11ccc11c11c0c11c1111111cc11111ccc11c000000000000000000060000000000
01cc1100000001cccccccccccccccc1cccccc100000000000000000070000c11cc11cc11ccc11c11ccccccccccc11cc11ccc0000000000000000000000000000
1d6ccc10000001cccccccccc1ccccc1ccccc1000000000000000000067000cc111c11cc111111cc11111c0c11111cccc111c0007000060000000000000000000
16d67cc1000001ccccccccc1ccccc11ccccc10000000000000000000700000ccccccccccccccccccccccc0ccccccc00ccccc0000000000000000000000000000
1d6767c10000001ccccccc1ccccc171cccc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16d67671000000111cccc1ccccc1771ccc1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000
016d6dd1000001ccc1111cccc117771cc1ccc10000000000000000000000000000000000000000000000000000900000000000000000c7700000000000000000
0016d610000001ccccccc111177771cc1cccccc100000000000000000000000000000000000000000000000000000000000000000000cc700000000000000000
00011100000001ccc111117777771ccc1ccccccccc1100000000000000000006000000090000000000000000000000000000000c7700c0000000000900000000
000000000000001ccccccc117771ccccccccccccccccc1100000000000000000000000000000000006000000000000000000000cc700c0000000000000000600
0000000000000011cccccccc111cccccccccccccccccccc11000000000000000000000000000000000000000000000000000000c00000c000000000000000000
0000000000000000111cccccccccc11cccccccccccccccccc110000000000ccccc000000000000000000000cccccccccccc00000c0000c000000000000000000
00000000000000000001111111111cccccccccccccccccccccc100000000cc111c000000000000000000000c111111cc11c00000c0000c000000000000000000
00000000000000000000000001ccccccccccc11111cccccccccc1000000cc11ccccccccccccccccc0000000c11ccc11c11cccc0ccccccccccc00000000000000
00000000000000000000000001cccccccccc1cc100111cccccccc100000c1111ccc11111cc11c11c0000000c11ccc11c11c11c0c11cc11111cc0007000000000
000000000001110000000000001cccccccccccc1000011ccccccc100000cc11ccc11ccc11c111ccc0000000c111111cc11c11c0c11c11ccc11c0000000000000
00000000111ccc1100000000001cccccccccccc10011cccccccc11000000c11c0c11c0c11c11cc000000000c11ccc11c11c11c0c11c1111111c0000000000000
00000001cccccccc11000000001cccccccccccc101ccccccccc110000000c11c0c11ccc11c11c0000006000c11ccc11c11c11ccc11c11cccccc0000000700006
0000001ccc1ccccccc10000001ccccccccccccc11cccccccc11000000000c11c0cc11111cc11c0000000000c111111cc11cc111111cc11111c00000000000000
000000011111ccccccc1000001cccccccccccc1ccccccc11100000000000cccc00ccccccccccc0000000000ccccccccccccccccccccccccccc00000000000000
__gff__
00000000000000004181418103418103000000000041810341814181034181030100000001000000418141810341810301010000010101004181418103418103000000000000000005250525052505250000000000ffff0015351535153515350000000000000000052505250525052500000000000000001535153515351535
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000002f08092f00000c0c00001c3d3e1c002f2f000000000000001c18191c000000000d0e0d0e0000000000250000000000001d1e000000000000001700001c000000170f0f00170000001700000000001c000000000000002d2e2f000000001c1a1b00000000000018190000000000000000
00000000000000000000000000000000002d2e10000c1c1c0c00003d3e002f08092f00001c3a3b001c18191c0d0e001300000f170f0000002500001f1d1e001f08091f001d1e1f00001700001c1c000017000f0f1700000000170000001c000000000000002d2e2d2e2f00001a1b1c1a1b000038392d2e2f2d2e3f3f3d3e3d3e
000000000000000000000000000000000010000010002a2b0000000010002f08092f003a3b4e4f1c001a1b00000d0e000d0e170d0e68690000250000001d1e1d1e1d1e1d1e000000001700001c00000017000000170000001700001c0c1c00000000003f6c6d2d2e2f00001c28291c28291c0038392d2e2f2d2e3f3f3d3e3d3e
0000000000000000000000000000000010000000001c2d2e1c0000100000002f2f00003c1c5e5f3c0000000000000d0e0f170d0e0f78790f1300000000001f4a4b4a4b1f000000000017000000004c4d17000000170000000017001a1b1c000000001c007c7d2d2e0000001c28291c28291c0000000017171700000000000000
0000000000000000000000000000000000003d3e1c002d2e001c3d3e001000003cb500003a3b1c00001c000000000d0e174c4d0f170d0e0f00000000a7a70c5a5b5a5b0ca7a7000000173c00003f5c5d17000000170000001d1e0000001c48490c1c00002d2e2f000000001a1b1c1a1b1a1b1f17151615161516171f00000000
000000000000000000000000000000000000001d1e000f0f001d1e001000001c3c1c0000001f32003a3b1c00000d0e000f5c5d170d0e0f0000000000b8b70a0b18190a0bb7b8000000173c6e6f3f3f1f170000001700001f1d1e1f00001c58591a1b00002d2e6c6d0000001c001c001c001c001f1516151615161f006e6f6e6f
000000000000000000000000000000004a4b00001d1e0f001d1e00003d3e003a3b3c1c331d1e1f333a3b3c320d0e00000015160d0e0f0000001300002a2b000c00000c002a2b000000173c7e7f2f3f1f1700000017002d2e6c6d2d2e001c0000001c00002d2e7c7d2f00001a1b001c001a1b1f001d1e1d1e1d1e00007e7f7e7f
000000000000000000000000000000005a5b0010001f2f1d1e0010003d3e2a2b2a2b2a2b2a2b2a2b2a2b2a2b000000130000000000000000000000002a2b00000a0b00002a2b000000173c2f2f2f1f1f170000001700002f7c7d2f001a1b00001a1b0000002d2e2d2e2f001a1b1a1b1c1a1b0000000000000000000000000000
000000000000000000000000000000001d1e100000000000000010001d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000151615161516171516171516002a2b2a2b2a2b2a2b2a2b2a2b2a2b00002d2e2f00001c001c001c001c001f000000000000000000000000
0000000000000000000000000000000000001a1b0000000000001d1e00000000001c15161c0000000000000000000000000c0c0c0c0c000000000000000c0a0b0a0b00000000000000000017ee1000b4c9c900000000003f3f00000c00000c00003f3f00002a2b2a2b000000002a2b2a2b000c0a0b0a0b3d3e3d3e0a0b0a0b0c
00000000000000000000000000000000000a0b0a0b000000000a0b0a0b0000001c2c1c2c3c2c000000000000000000000c17151615160c00000000000c0a0b4a4b0a0b00000000003c001700c900b400ee00cd104e4f3f4c4d3f00001f1f00003f4c4d3f2c3a3b3a3b2a2b2a2b3a3b3a3b2c0a0b0a0b3d3e4a4b3d3e0a0b0a0b
00000000000000000000000000000000000c4a4b0c000000000c4a4b0c00001a1b2c2c4c4d2c3c00004a4b000000000c1d1e15161d1e170c0000000a0b0a0b5a5b0a0b3f000000003c000017ee00a600c91000005e5f3f5c5d1f3f000c0c003f1f5c5d3f2c3c4e4f4e4f2a2b4e4f4e4f3c2c4a4b0c3f003f5a5b003d3e0c4a4b
0000000000000000000000000000000000005a5b0000000000005a5b0000001c2c1c1c5c5d2c3c00005a5b000000000c1d1e15161d1e170c0000000c0a0b0a0b0a0b3d3e000000003c3c000000001f000000003c4e4f3f0d0e0d0e3f1f1f3f0d0e0d0e3f2c3c5e5f5e5f2a2b5e5f5e5f3c2c5a5b0c3f00003f00003d3e0c5a5b
0000000000000000000000000000000000171a1b1700000000171d1e1700001c0d0e0f1c3c2c1c0000000000000000000c0c0c0c0c0c0c000000000a0b0a0b3f3d3e3d3e000000004e4f0000001f1f1f1f00003c5e5f3f3f0d0e1f3f1f1f3f1f0d0e3f3f002a2b2a2b2a2b2a2b2a2b2a2b140a0b0a0b3d3e004a4b3f0a0b0a0b
00000000000000000000000000000000176e6f1a1b170000171d1e6a6b17001a1b6c6d1a1b1a1b000000000000000000000c0000170c00000000000a0b3d3e3d3e3d3e3f004849005e5f3c001f3f3f3f3f1f00003c2c00006e6f1f3f1f1f3f1f6e6f00002c3a3b3a3b3a3b3a3b3a3b3a3b2c0a0b0a0b3d3e3f5a5b3f0a0b0a0b
00a000a2000000a1000000a40000a500177e7f1a1b170000171d1e7a7b1700001c7c7d1a1b1c0000000000006a6b6a6b000c0000170c006a6b00000c3d3e48493d3e3d3e005859002c00001f3f003f004a4b1f00002c003f7e7f3f001f1f003f7e7f3f002c3c2c142c142a2b142c142c3c2c4a4b0a0b000000003f0a0b0c4a4b
3434343434343434343434343434343400151615160000000015161516000000001c15161c000000000000007a7b7a7b00000c0c0c00007a7b0000003d3e58593d3e3f00004a4b002c3233003f3f3f005a5b3332332c003f1c1c3f001f1f003f1c1c3f002c3a3b3a3b3a3b3a3b3a3b3a3b2c5a5b0c0a0b3f3d3e0a0b0a0b5a5b
353535353535353535353535353535350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3d3e3d3e0000005a5b002c2c2c2c2c2c2c2c2c2c2c2c2c2c00003f3f0000000000003f3f0000002a2b2a2b2a2b2a2b2a2b2a2b000a0b0a0b0a0b0a0b0a0b0a0b0a0b
2400000000000000000000000000003610de000000c9960000000096000000100000000000000000000000000000000060aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
2400000000000000000000000000003610c7c8c90000cce70000eaebecedee140000000000000000000000000000000061aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
2400000000000000000000000000003610d7d8d9dadbdcf7f8f9fafbfcfdfe000000000000000000000000000000000062aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c900c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9cd10c9c9
24000000000000000000000000000036108a8bde00e99600e9c9000000cecf100000009f9f969f9f9f9f9f9f9600000063aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c91000c9c9c9
24000000000000000000000000000036109a9b0000c9008e8f00009600dedf1000000096849f009f84969f9f9f00000064aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9000000c9c9c9
240000000000000000000000000000361014140096eede9e9fde000000109f100000009fb9bcbdbe94adaeaf9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
240000000000000000000000000000361014129f109f14109f10149f109f10100000009f9f00009f9f9f9f9f9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
24000000000000000000000000000036101010122110101010101210121021100000009f9f00009f969f9f9fa80000000000000000000000000000000000000000000000000000000000000000003100000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
24000000000000000000000000000036121212121020b0b1b2b3001212201212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003100000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9
24000000000000000000000000000036101212122120c0c1c2c30012122021120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c9c9c9c9c9c9c9c9c9c9c9c9c9
24000000000000000000000000000036101212121220d0d1d2d3d40000201212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24000000000000000000000000000036121212122120e0e1e2e3e4e512202112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24000000000000000000000000000036121212121220f0f1f2f3f4f5f6201212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000003612122112213131313131313131312112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010501001c1231c60300613186030c6131860300603186030c6030c603006030c6030c6030c603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300600
00020000280302a0002c0002f0003200036000380000e0000e0000f000300000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f000130001b00022000270002b000
000400000861005600036000260004600036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000a0200702004020050200802005100071000a1000d1000d00027000200001c00018000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001154104501015010150101501015010150101501015010150100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
010200001a0201c0201d0201e02002000210002500027000180001900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000008e2008e2008e2008e2008e2008e3008e4004e0004e0004e0025300283002830027300273002730022000220002200022000000000000000000000000000000000000000000000000000000000000000
0003000027010290102a0101000011000066000360011600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013200182072525725287252072525725287252072525725287252072525725287252172525725287252172525725287252172526725287252172526725287250000000000000000000000000000000000000000
019600080d0200d025170201702515025120250e0251c005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0196000819020190252302023025210251e0251a02500700007000070000700007000070000700007000070000700007000070000700007000070000700007000000000000000000000000000000000000000000
001000001167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001367100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600080c0730000000000000000c073000000c32324323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180020135351353513535135350c5350c5350c5350c53510535105351053510535105351053510535105350e5350e5350e5350e5350e5350e5350e5350e5351053510535105351053510535105351053510535
011800200c1451053510535105350c1450c14510535105350c1451453514535145350c1450c14514535145350c1451153511535115350c1450c14511535115350c1451453514535145350c1450c1451453514535
011800201353513535136251353513535135351362513525175351753517625175351753517535176251762515535155351562515535155351553515625155351753517535176351753517535175351762517625
0118002018545185451c5451a5451a5051854518505185451c5451c505205452354523505235452350523545215451d5451a5451c5051c5451a5451a5051a54518545185451a5051a5451c5451c5051c5451c505
0118022018535185351c5351a5351a5051853518505185351c5351c505205352353523505235352350523535215351d5351a5351c5051c5351a5351a5051a53518535185351a5051a535185351a5351853500505
011800001c5351c5351f53518535265051a535185351c5351c5352450524505265051c5351c5352353532505325052f5052353526535235352353534505245051c5351c53518535185351c53523505235351c535
011800200952515525185251c52505525115251552518525005250c52510525135250752513525175251a5250952515525185251c52505525115251552518525005250c52510525135250752513525175251a525
0118002021522215252d5030c5051f5221850518505185051852218525245030c5051d5222450018505185051f5222152521522005051f5222d505005050050518522185251d522245051f522005050050500505
011800201f5222152521522005051f5222450224502245021f5221d5221c5221a5221d5222450224502245021c5221d5221f5221a5221a5222d502245022450218522185221d522245021a522005020050200502
01180d000c0431a003180031c0030c0430c0431d003180030c0431c0031d0031a0030c0430c0430c6251c0030c0431a003180031c0030c0430c0431d003180030c0431c0031d0031a0030c0430c0430c6251a003
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
01 10 11 12 13
00 10 11 12 15
02 10 11 12 14
00 16 42 43 44
00 16 42 19 44
01 16 19 17 44
02 16 18 19 44
03 08 09 0a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
