pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- the climbing of asiic
-- by risike
-- version 1.1 beta

-- pico 8 functions

-- ‰ j hero
-- Š k current room
-- ‚ c monster

score = 0
lasttime=time()
speedrun=false

-- init cart data
cartdata('risike_tcoa_1_1_b')
-- 0: high score
-- 1: mount unlock
-- 2: peak unlock
-- 3: best time

-- init time
if dget(3)==0 then dset(3,3600) end

function _init()
	--srand(time())
 loadmenu()
-- ‚ = monster:new(44, 32, 16)
 --lvl = level:new(1)
 --lvl:generate()
 --Š = lvl.rooms[1]
 --add(Š.monsters,‚)
	--add(Š.items,item:new(120,38,64))
end

function _update60()
 Š:update()
	‰:update()
	anim.update()
	bullets.update()
 updatepart()
end

function _draw()
	cls(0)
 Š:draw()
	‰:draw()
	if not lvl.menu then
		-- draw bullets
		bullets.draw()
	end
	--draw particules
	drawpart()
	-- draw mouse
	local mx, my = mouse()
	spr(16, mx-3, my-3)
end

-->8
-- items management

item = {}

-- hp = 18
-- hp_half = 19
-- hpmax = 17
-- shot_behind = 71
-- shot_side = 72
-- shot_all = 73
-- shot_double = 74
-- shot_triple = 75
-- elem_ghost = 70.1
-- elem_frag = 70.2
-- elem_poison = 70.3
-- elem_glue = 70.4
-- invincible = 76
-- boot = 88
-- dmgup = 89
-- shotssizeup = 90
-- rateup = 91
-- shotsspdup = 92
-- distup = 93
-- stairs = 120
-- lock = 32

-- special items
speitems = {}
-- trident
speitems[77] = {75,89,91}
-- cherry
speitems[78] = {74,70.4,93}
-- shuriken
speitems[79] = {73,91}
-- grenade
speitems[94] = {70.2,90}
-- triangle
speitems[95] = {72,92,89}
-- bazooka
speitems[105] = {90,90,93,93,89}
-- ace of hearts
speitems[106] = {17,17}
-- ace of spades
speitems[107] = {72,89,93}
-- ace of diamonds
speitems[108] = {88,88}
-- ace of clubs
speitems[109] = {88,91,92}

-- lootable items
itemlist = {18,19,17,71,72,73,74,75,70.1,70.2,70.3,70.4,76,88,89,90,91,92,93,77,78,79,94,95,105,106,107,108,109}

-- create an item
function item:new(id,x,y)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.id = id
		o.x = x
		o.y = y
		o.speedrun=false -- used to manage speed run mode
	return o
end

-- draw item
function item:draw()
	if flr(self.id)==70.1 then
		spr(self.id,self.x+4,self.y+8)
	else
		spr(flr(self.id),self.x+4,self.y+8)
		local c=self.id-flr(self.id)
		if c==0.1 then
			rectfill(self.x+5,self.y+9,self.x+10,self.y+14,0)
		end
		if c==0.2 then
			rectfill(self.x+5,self.y+9,self.x+10,self.y+14,9)
		end
		if c==0.3 then
			rectfill(self.x+5,self.y+9,self.x+10,self.y+14,3)
		end
		if c==0.4 then
			rectfill(self.x+5,self.y+9,self.x+10,self.y+14,14)
		end
	end
end

-- use item
function item:use(silence)
	local it,i
	if not silence and not lvl.menu then
		sfx(5)
	end
	if speitems[self.id] then
		for i=1,#speitems[self.id] do
			it=item:new(speitems[self.id][i],0,0)
			it:use(true)
			it=nil
		end
		return
	end
	score=score+10
	-- hp
	if self.id==18 then
		‰.hp=‰.hp+1
	end
	-- hp half
	if self.id==19 then
		‰.hp=‰.hp+0.5
	end
	-- hpmax
	if self.id==17 then
		‰.hpmax=‰.hpmax+1
		‰.hp=‰.hp+1
	end
	if ‰.hp>‰.hpmax then
		‰.hp=‰.hpmax
		score=score+20
	end
	-- shot behind
	if self.id==71 then
		‰.shots.type=shot_behind
	end
	-- shot side
	if self.id==72 then
		‰.shots.type=shot_side
	end
	-- shot all
	if self.id==73 then
		‰.shots.type=shot_all
	end
	-- shot double
	if self.id==74 then
		‰.shots.type=shot_double
	end
	-- shot triple
	if self.id==75 then
		‰.shots.type=shot_triple
	end
	-- elem ghost
	if self.id==70.1 then
		‰.shots.elem=elem_ghost
	end
	-- elem frag
	if self.id==70.2 then
		‰.shots.elem=elem_frag
	end
	-- elem poison
	if self.id==70.3 then
		‰.shots.elem=elem_poison
	end
	-- elem glue
	if self.id==70.4 then
		‰.shots.elem=elem_glue
	end
	-- invicible
	if self.id==76 then
		‰.touch=30*60
	end
	-- boot
	if self.id==88 then
  ‰.spd=‰.spd+0.2
  if ‰.spd>1 then ‰.spd=1 end
	end
	-- dmgup
	if self.id==89 then
  ‰.shots.pow=‰.shots.pow+0.5
	end
	-- shotssizeup
	if self.id==90 then
		‰.shots.size=‰.shots.size+1
		if ‰.shots.size>8 then ‰.shots.size=8 end	
	end
	-- rateup
	if self.id==91 then
		‰.shots.rate=‰.shots.rate-10
		if ‰.shots.rate<10 then ‰.shots.rate=10 end
	end
	-- shotsspdup
	if self.id==92 then
		‰.shots.spd=‰.shots.spd+0.3
		if ‰.shots.spd>2 then ‰.shots.spd=2 end
	end
	-- distup
	if self.id==93 then
		‰.shots.dist=‰.shots.dist+10
		if ‰.shots.dist>300 then ‰.shots.dist=300 end
	end
	-- stairs
	if self.id==120 then
		if not lvl.menu then
			score=score+100*lvl.nb
			lvl.nb=lvl.nb+1
			local maxl=lvl.maxlvl
			if lvl.nb>lvl.maxlvl then
				if lvl.nb>=6 then
					dset(1,1)
				end
				if lvl.nb>=11 then
					dset(2,1)
				end
				loadmenu(true,true)
				return
			end
			lvl=level:new(lvl.nb)
		 lvl:generate()
		 lvl.maxlvl=maxl
	 	Š = lvl.rooms[1]
	 	if ‰.hp==‰.hpmax then
	 		score=score+50
	 	end
	 else
	  startgame()
	  sfx(6)
	  lvl.maxlvl=self.maxlvl
	  speedrun=self.speedrun
	 end
	end
end
-->8
-- level management

level = {}

-- create a new level
function level:new(nb)
 o = {}
 setmetatable(o, self)
 self.__index = self
 o.nb = nb -- level numer
 o.rooms = {} -- room list
 o.menu = false -- is a menu level
	return o
end

-- generate level
function level:generate()
	local nbr = 8+self.nb-1 -- nb rooms
	local connected=false
	local k,r,i,dr,good
	local lim
 while not connected do
		-- del all rooms
		for k,r in pairs(self.rooms) do
			del(self.rooms,r)
			r=nil
		end
		local gridx,gridy,model=0,0,1
		-- list rooms
		for i=1,nbr do
			if i>1 then
				model=flr(rnd(28))+2
			end
			if i==nbr then model=32 end
			rm = room:new(i,model,gridx,gridy)
			rm:populate()
			if i>1 then
				good=false
				lim=0
				while not good do
					dr=flr(rnd(4))
					if dr==0 and self.rooms[i-1].up==nil and self:checkpath(gridx,gridy-1)==nil then
						self.rooms[i-1].up=rm
						rm.down=self.rooms[i-1]
						good=true
						gridy=gridy-1
					elseif dr==1 and self.rooms[i-1].down==nil and self:checkpath(gridx,gridy+1)==nil then
						self.rooms[i-1].down=rm
						rm.up=self.rooms[i-1]
						good=true
						gridy=gridy+1
					elseif dr==2 and self.rooms[i-1].left==nil and self:checkpath(gridx-1,gridy)==nil then
						self.rooms[i-1].left=rm
						rm.right=self.rooms[i-1]
						good=true
						gridx=gridx-1
					elseif dr==3 and self.rooms[i-1].right==nil and self:checkpath(gridx+1,gridy)==nil then
						self.rooms[i-1].right=rm
						rm.left=self.rooms[i-1]
						good=true
						gridx=gridx+1
					else
						lim=lim+1
						if lim>10 then	good=true end
					end
					if good then
						rm.gridx=gridx
						rm.gridy=gridy
						self.rooms[i]=rm
					end
				end
			else
				rm.gridx=gridx
				rm.gridy=gridy
				self.rooms[i]=rm
			end
			if i==nbr then connected=true end
		end
	end
	self:addmorerooms()
end

-- check if path is ok
function level:checkpath(x, y)
	local k,v
	for k,v in pairs(self.rooms) do
		if v.gridx==x and v.gridy==y then
			return v
		end
	end
	return nil
end

-- add more rooms
function level:addmorerooms()
	local i,rm,dr,newr
	local model
	for i=1,8+self.nb do
		model=flr(rnd(28))+2
		rm=self.rooms[flr(rnd(#self.rooms)+1)]
  dr=flr(rnd(3))
		-- up
  if dr==0 then
  	newr=self:checkpath(rm.gridx,rm.gridy-1)
  	if newr==nil then
  	 newr=room:new(#self.rooms+1,model,rm.gridx,rm.gridy-1)
				newr:populate()
	   add(self.rooms,newr)
  	end
  	newr.down=rm
  	rm.up=newr
  end
		-- down
  if dr==1 then
  	newr=self:checkpath(rm.gridx,rm.gridy+1)
  	if newr==nil then
  	 newr=room:new(#self.rooms+1,model,rm.gridx,rm.gridy+1)
				newr:populate()
	   add(self.rooms,newr)    
			end
  	newr.up=rm
  	rm.down=newr
  end
		-- left
  if dr==2 then
  	newr=self:checkpath(rm.gridx-1,rm.gridy)
  	if newr==nil then
  	 newr=room:new(#self.rooms+1,model,rm.gridx-1,rm.gridy)
  	 newr:populate()
	   add(self.rooms,newr)
			end
  	newr.right=rm
  	rm.left=newr
  end
		-- right
  if dr==3 then
  	newr=self:checkpath(rm.gridx+1,rm.gridy)
  	if newr==nil then
  	 newr=room:new(#self.rooms+1,model,rm.gridx+1,rm.gridy)
  	 newr:populate()
	   add(self.rooms,newr)
  	end
  	newr.left=rm
  	rm.right=newr
  end
	end
	-- add an item
 local i=flr(rnd(#lvl.rooms)+1)
 local it=flr(rnd(#itemlist-1))+2
	add(lvl.rooms[i].items,item:new(itemlist[it],7*8,2*8))
end

-- print a menu text
function printmenu(text,x,y)
	print(text,4+x*8+1,8+y*8+1,5)
	print(text,4+x*8,8+y*8,7)
end


-- load menu
function loadmenu(gameover,win)
	--void()
	sfx(9,1)
 ‰ = hero:new()
	lvl = level:new(0)
	lvl.menu = true
	-- start room
	Š = room:new(-1,31,0,0)
 Š:addtext('1.1 beta',2,3)
	Š:addtext('by risike',2,4)
	Š:addtext('‹ how to play',2,6)
	Š:addtext('start ‘',8,8)
	--Š:addtext('start',10,4)
	Š:addtext('high score:'..dget(0),4,11)
	Š:addtext('best time:'..formattime(dget(3)),4,12)
	--local stairs = item:new(it_stairs,11*8,5*8)
	--add(Š.items,stairs)
	--‰.x = 7*8
	--‰.y = 7*8
	-- play room
	local play = room:new(0,31,1,0)
 add(lvl.rooms,play)
 Š.right=play
 play.left=Š
 play:addtext('hill',2,2)
	local hill = item:new(120,20,24)
	hill.maxlvl=5
	add(play.items,hill)
 play:addtext('mount',6,2)
 local mount
 if dget(1)==1 then
		mount = item:new(120,54,24)
		mount.maxlvl=8
	else
 	mount = item:new(32,54,24)
	end
	add(play.items,mount)
 play:addtext('peak',10,2)
	local peak
	if dget(2)==1 then
  peak = item:new(120,88,24)
  peak.maxlvl=10
 else
  peak = item:new(32,88,24)
 end
	add(play.items,peak)
	-- speedrun
	local timat = item:new(120,54,96)
	timat.speedrun=true
	timat.maxlvl=5
	play:addtext('speed run',5,11)
	add(play.items,timat)
	-- how to play room
	local how = room:new(0,31,-1,0)
	add(lvl.rooms,how)
	how.right=Š
	Š.left=how
 how:addtext('how to play?',4,2)
 how:addtext('”ƒ‹‘ to move',3,4)
 how:addtext('move mouse to aim',3,5)
 how:addtext('left click to shot',3,9)
 how:addtext('right click to show map',2,10)
 -- game over
	local over = room:new(0,31,0,-2)
	add(lvl.rooms,over)
	over.up=Š
	if not win then
		over:addtext('game over',5,2)
		if gameover then sfx(7) end
	else
		if win then
			over:addtext('congratulations!!',3,2)
			score = score+3000
			sfx(8)
		end
	end
	if gameover then
		Š=over
		‰:hit(0)
		‰.hp=‰.hpmax
 	local i,j,p,x,y
 	if not win then
	 	for j=1,10 do
		 	x=flr(rnd(13)+1)*8
		 	y=flr(rnd(13)+1)*8
	 		add(Š.blood,{x,y})
				for i=0,rnd(50)+30 do
					p = {flr(rnd(13)+1)*8+4,flr(rnd(13+1))*8+8,8,rnd(0.5)+0.1,rnd(2*3.14),rnd(120)+10}
				 add(particles,p)
				end
			end
		end
		--highscore
		if not speedrun then
			over:addtext('score:'..score,5,11)
			if score>dget(0) then
			  dset(0,score)
    	over:addtext('new high score!',4,12)
			end
		end
		-- best time
		local tt=flr(time()-lasttime)
		if speedrun then
   over:addtext('time:'..formattime(tt),5,11)
   if tt<dget(3) and win then
				dset(3,tt)
				over:addtext('new best time!',4,12)
			end
		end
	end
end

-- start game
function startgame()
	void()
	sfx(10,1)
 ‰ = hero:new()
	lvl = level:new(1)
	lvl:generate()
	Š = lvl.rooms[1]
	score=0
	lasttime=time()
end
-- draw map
function level:drawmap()
	local minx,miny,maxx,maxy=0,0,0,0
	local k,v
 -- find minx and miny
	for k,v in pairs(self.rooms) do
		if v.gridx<minx then minx=v.gridx end
		if v.gridy<miny then miny=v.gridy end
		if v.gridx>maxx then maxx=v.gridx end
		if v.gridy>maxy then maxy=v.gridy end
	end
	-- draw rooms
	local col,x,y
 x=64-(maxx-minx)*3-1
 y=64-(maxy-miny)*3-1
	rectfill(x,y,x+(maxx-minx+1)*6,y+(maxy-miny+1)*6,9)
	rect(x-1,y-1,x+(maxx-minx+1)*6+1,y+(maxy-miny+1)*6+1,4)
	for k,v in pairs(self.rooms) do
	 if v.view then
		 col=0
		 if v.id==1 then col=12 end
		 if Š==v then col=11 end
		 x=(v.gridx-minx)*6+(64-(maxx-minx)*3)
		 y=(v.gridy-miny)*6+(64-(maxy-miny)*3)
			rectfill(x,y,x+4,y+4,col)
			rect(x,y,x+4,y+4,7)
			if v.up then
			 line(x+2,y,x+2,y-1,7)
			end
			if v.down then
			 line(x+2,y+4,x+2,y+5,7)
			end
			if v.left then
				line(x,y+2,x-1,y+2,7)
			end
			if v.right then
				line(x+4,y+2,x+5,y+2,7)
			end
			if #v.items>0 then
				pset(x+2,y+2,8)
			end
		end
	end
 rectfill(0,120,44,126,0)
 if not speedrun then
		print('score:'..score,1,121,7)
	else
 	print('time:'..formattime(flr(time()-lasttime)),1,121,7)
	end
end

-->8
-- libs

-- collision rect rect
function colliderr(x1, y1, w1, h1, x2, y2, w2, h2)
	if x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and h1 + y1 > y2 then
		return true
	else
		return false
	end	
end

-- found
function round(num) 
	if num >= 0 then return flr(num+.5) 
	else return ceil(num-.5) end
end

-- mouse stats
function mouse()
  poke(0x5f2d, 1)
  local x, y, b1, b2, b3 = stat(32), stat(33), stat(34) == 1, stat(34) == 2, stat(34) == 4
  return x, y, b1, b2, b3
end

-- sprite management
anim = {}
anim.frame = 0
anim.counter = 0
anim.max = 15


-- update anims
function anim.update()
	anim.counter = (anim.counter + 1) % (anim.max * 2)
	anim.frame = anim.counter / anim.max
end

-- anim sprite function
function aspr(nb, x, y)
	spr(nb + anim.frame, x, y)
end

-- format time in m:s
function formattime(t)
 local m=tostr(flr(t/60))
 if #m==1 then m='0'..m end
 local s=tostr(flr(t%60))
 if #s==1 then s='0'..s end 	
 return m..':'..s
end
-->8
-- rooms
room = {}

-- create a new room
function room:new(id, model, gridx, gridy)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.id = id
  o.model = model
  o.mapx = (model-1)%8*15
  o.mapy = flr((model-1)/8)*15
  o.monsters = {}
  o.blood = {}
  o.items = {}
  o.up = nil
  o.down = nil
  o.left = nil
  o.right = nil
  o.gridx = gridx
  o.gridy = gridy
  o.view = false
  o.text = {} -- text used in menu
  return o
end

-- update a room
function room:update()
	self.view=true
	-- monsters
	for k, m in pairs(self.monsters) do
		m:update()
		-- kill a monster
		if m.hp <= 0 then
			m:kill()
			del(self.monsters,m)
			m = nil
		end
	end
	-- items
	for k,m in pairs(self.items) do
		if colliderr(m.x+1,m.y+1,6,6,‰.x+1,‰.y+1,6,6) and m.id ~= 32 then
			m:use()
			del(self.items,m)
			m = nil
		end
	end
end

-- draw a room
function room:draw()
	map(self.mapx, self.mapy, 4, 8, 15, 15)
	-- doors
	if self.left == nil then
		spr(81,4,64)
	else
		if #self.monsters>0 then
			spr(84,4,64)
		else
			if not lvl.menu then
				spr(85,4,64)	
			end
		end
	end
	if self.right == nil then
		spr(83,116,64)
	else
		if #self.monsters>0 then
			spr(84,116,64,1,1,true)
		else
			if not lvl.menu then
 			spr(85,116,64,1,1,true)
 		end
		end
	end
	if self.up == nil then
		spr(66,60,8)
	else
		if #self.monsters>0 then
			spr(68,60,8)
		else
			if not lvl.menu then
 			spr(69,60,8)
 		end
		end
	end
	if self.down == nil then
		spr(98,60,120)
	else
		if #self.monsters>0 then
			spr(68,60,120,1,1,false,true)
		else
			if not lvl.menu then
 			spr(69,60,120,1,1,false,true)
 		end
		end
	end
	local k,m
	-- monsters
	for k, m in pairs(self.monsters) do
		m:draw()
	end
	-- blood
	for k,m in pairs(self.blood) do
		spr(101,m[1]+4,m[2]+8)
	end
	-- items
	for k,m in pairs(self.items) do
		m:draw()
	end
	-- level number
	if lvl.nb>0 then
		print('level:'..lvl.nb,96,0,7)
	end
	-- menu
	if lvl.menu then
		self:drawtext()
		-- title
		if self.id==-1 then
			pal(5,8)
			pal(1,7)
			spr(48,16,20,13,1)
			pal()
		end
	end
end

-- populate room
function room:populate()
 local i,x,y,ok,mstr,msid,tmp,b,isboss
	-- nothing in fist room
	if self.id==1 then return end
	-- boss
	isboss=false
	if self.id==8+lvl.nb-1 then
		local b=boss[lvl.nb][flr(rnd(#boss[lvl.nb]))+1]
  mstr=monster:new(b,6*8,7*8)
  mstr.col=0
  mstr.hp=mstr.hp*4
  mstr.pow=mstr.pow*2
		mstr.rate=flr(mstr.rate*0.5)
		mstr.bulsize=mstr.bulsize*1.5
		mstr.bulspd=mstr.bulspd*1.5
		mstr.buldist=300
		add(self.monsters,mstr)
		isboss=true
	end	
	-- other rooms
	local nbmonster = 0
	nbmonster = flr(rnd(lvl.nb+1))
	if nbmonster==0 then nbmonster=1 end
	if nbmonster>5 then nbmonster=5 end
	if isboss then nbmonster=2 end
 for i=1,nbmonster do
  ok=false
 	while not ok do
 	 x=flr(rnd(13))+1
	  y=flr(rnd(13))+1
	  -- find good spawn
	  if mget(self.mapx+x,self.mapy+y)==64 then
	  	ok=true
	  end
	 end
  -- find monster id
  msid=1+flr(rnd(lvl.nb*2))%(#monsterlist)
  -- create monster
		mstr=monster:new(monsterlist[msid],x*8,y*8)
  -- manage monster color
  tmp=flr(rnd(4))
  -- red
  if tmp==0 and lvl.nb>2 then
  		mstr.col=8
  		mstr.spd = mstr.spd*1.4
  		if mstr.spd>1 then mstr.spd=1 end
  		mstr.hp=mstr.hp*2
  end
  -- gold
  if tmp==1 and lvl.nb>4 then
  		mstr.col=10
  		mstr.rate=flr(mstr.rate*0.5)
  		mstr.pow=mstr.pow*1.5
  		mstr.hp=flr(mstr.hp*2)
  		mstr.hp=mstr.hp*3
  end
		-- add monster
		add(self.monsters,mstr)
 end
end

-- draw text
function room:drawtext()
	for k,v in pairs(self.text) do
		printmenu(v[1],v[2],v[3])
	end
end

-- add text
function room:addtext(txt,x,y)
	add(self.text,{txt,x,y})
end
-->8
-- hero management
hero = {}

-- constants
shot_simple = 0
shot_behind = 1
shot_side = 2
shot_all = 3
shot_double = 4
shot_triple = 5
elem_normal = 12
elem_ghost = 0
elem_frag = 9
elem_poison = 3
elem_glue = 14
elem_monster = 8
elem_random = 2

-- create a new hero
function hero:new()
	o = {}
	setmetatable(o, self)
 self.__index = self
	o.hpmax = 3 -- hp max
	o.hp = o.hpmax -- hero hp
	o.spd = 0.5 -- hero speed
	o.x = 7*8 -- hero x
	o.y = 7*8 -- hero y
	o.touch = 0 -- hero touched
	o.shots = {} -- hero shot
	o.shots.pow = 1 -- power
	o.shots.type = shot_simple -- type
	o.shots.elem = elem_normal -- element
	o.shots.size = 2 -- size
	o.shots.rate = 60 -- rate
	o.shots.spd = 0.6 -- speed
	o.shots.dist = 40 -- distance
	o.shots.ratecnt = 0
	return o
end

-- hit the hero
function hero:hit(dmg)
	sfx(3)
	self.touch = 120
	self.hp = self.hp-dmg
	-- gameover
	if self.hp<=0 then
		loadmenu(true)
	end
end

-- check if hero can move
function hero:canmove(x, y)
	-- check edges
	if x<7 or x>13*8+1 or y<7 or y>13*8+1 then
	 if #Š.monsters>0 then
	 	return false
	 else
	 	if x<7 and Š.left==nil then return false end
	 	if x>13*8+1 and Š.right==nil then return false end
	 	if y<7 and Š.up==nil then return false end
	 	if y>13*8+1 and Š.down==nil then return false end
	 end
	end
	local i, j, t
	for j=flr(y/8)-1,flr(y/8)+1 do
		for i=flr(x/8)-1,flr(x/8)+1 do
			t = mget(Š.mapx+i, Š.mapy+j)
			-- blocks
			if not fget(t,1) and not fget(t,7) and colliderr(x+1,y+1,6,6,i*8+1,j*8+1,6,6) then
				return false				
			end
			-- spikes
			if self.touch <=0 and fget(t,1) and colliderr(x+1,y+1,6,6,i*8+1,j*8+1,6,6) then
				self:hit(0.5)
			end
		end
	end
	return true
end

-- shot
function hero:shot()
	local bul
	-- can shot
	if self.shots.ratecnt == 0 then
		sfx(0)
		local mx, my = mouse()
		-- random
		local isrnd = false
		if self.shots.elem==elem_random then
			local r = flr(rnd(5))
			isrnd = true
			if r==0 then self.shots.elem=elem_normal end
			if r==1 then self.shots.elem=elem_ghost end
			if r==2 then self.shots.elem=elem_frag end
			if r==3 then self.shots.elem=elem_poison end
			if r==4 then self.shots.elem=elem_glue end
		end
		local angle = atan2(mx-(self.x+7), my-(self.y+12))
		-- normal
		if self.shots.type == shot_simple or self.shots.type == shot_behind or self.shots.type == shot_side or self.shots.type == shot_all or self.shots.type == shot_triple then
			bul = bullet:new(0, self.x+3+cos(angle)*self.shots.size*2, self.y+4+sin(angle)*self.shots.size*2, self.shots.size, self.shots.elem, angle, self.shots.spd, self.shots.dist,self.shots.pow)
			add(bullets.list, bul)
		end
		-- behind
		if self.shots.type == shot_behind or self.shots.type == shot_all then
			bul = bullet:new(0, self.x+3+cos(angle+3.5)*self.shots.size*2, self.y+4+sin(angle+3.5)*self.shots.size*2, self.shots.size, self.shots.elem, angle+3.5, self.shots.spd, self.shots.dist,self.shots.pow)
			add(bullets.list, bul)
		end
		-- side
		if self.shots.type == shot_side or self.shots.type == shot_all then
			bul = bullet:new(0, self.x+3+cos(angle+1.75)*self.shots.size*2, self.y+4+sin(angle+1.75)*self.shots.size*2, self.shots.size, self.shots.elem, angle+1.75, self.shots.spd, self.shots.dist,self.shots.pow)
			add(bullets.list, bul)
			bul = bullet:new(0, self.x+3+cos(angle+5.25)*self.shots.size*2, self.y+4+sin(angle+5.25)*self.shots.size*2, self.shots.size, self.shots.elem, angle+5.25, self.shots.spd, self.shots.dist,self.shots.pow)
			add(bullets.list, bul)
		end
		-- double
		if self.shots.type == shot_double or self.shots.type == shot_triple then
			bul = bullet:new(0, self.x+3+cos(angle-1.05)*self.shots.size*2, self.y+4+sin(angle+-1.05)*self.shots.size*2, self.shots.size, self.shots.elem, angle-1.05, self.shots.spd, self.shots.dist,self.shots.pow)
			add(bullets.list, bul)
			bul = bullet:new(0, self.x+3+cos(angle+1.05)*self.shots.size*2, self.y+4+sin(angle+1.05)*self.shots.size*2, self.shots.size, self.shots.elem, angle+1.05, self.shots.spd, self.shots.dist,self.shots.pow)
			add(bullets.list, bul)
		end
		self.shots.ratecnt = self.shots.rate
		if isrnd then self.shots.elem=elem_random end
	end
end

-- update the hero
function hero:update()
 -- touch management
	if self.touch > 0 then self.touch = self.touch-2 end	
	local mx, my, b1, b2, b3 = mouse()
	if btn(0) and self:canmove(self.x - self.spd, self.y) then self.x = self.x - self.spd end
	if btn(1) then 
	 if self:canmove(self.x + self.spd, self.y) then
	 	self.x = self.x + self.spd 
	 else
	 	self.x = ceil(self.x)
	 end
 end
	if btn(2) and self:canmove(self.x, self.y - self.spd) then self.y = self.y - self.spd end
	if btn(3) and self:canmove(self.x, self.y + self.spd) then self.y = self.y + self.spd end
	if b1 then self:shot() end
 -- manage shot rate
	if self.shots.ratecnt > 0 then
		self.shots.ratecnt = self.shots.ratecnt - 1
	end
	-- check monsters
	self:touchmonsters()
	-- check rooms
	if self.x<=0 then
		Š=Š.left
		self.x=13*8
		void()
	end
	if self.x>=14*8 then
		Š=Š.right
		self.x=8
		void()
	end
	if self.y<=0 then
		Š=Š.up
		self.y=13*8
		void()
	end
	if self.y>=14*8 then
		Š=Š.down
		self.y=8
		void()
	end
end

-- touch monsters
function hero:touchmonsters()
	local k,m
	for k,m in pairs(Š.monsters) do
	 if self.touch<=0 and colliderr(self.x,self.y,8,8,m.x,m.y,8,8) then
			self:hit(m.pow)
	 end
	end
end

-- draw the hero
function hero:draw()
	if flr(self.touch / 10) % 2 == 0 then
		pal(12,self.shots.elem)
		aspr(1, self.x + 4, self.y + 8)
		pal()
	end
	local i
	for i=0,self.hpmax-1 do
		spr(17,i*6,0)
		if self.hp >= i+1 then
			spr(18,i*6,0)
		else
			if self.hp == i+0.5 then
			 spr(19,i*6,0)
			end
		end
	end
	-- draw map
	local mx, my, b1, b2 = mouse()	
	if b2 and not lvl.menu then
		lvl:drawmap()
	end
end

-->8
-- monsters data
monsters = {}

-- constants
--[[
move_rand1 = 0
move_rand2 = 1
move_rand3 = 2
move_follow1 = 3
move_follow2 = 4
move_stand = 5
move_bound = 6
bul_none = 0
bul_rand1 = 1
bul_rand2 = 2
bul_follow1 = 3
bul_follow2 = 4
bul_follow3 = 5
bul_updown = 6
bul_leftright = 7
bul_udlr = 8
bul_cross1 = 9
bul_cross2 = 10
bul_cross3 = 11
bul_star = 12
col_none = 7
col_red = 8
col_gold = 10
col_dark = 0
--]]


-- 1:hp,2:speed,3:movetype,4:power,5:bullettype,6:rate,7:bulletsize,8:bulletspeed,9:bulletdistance,color
monsters[3] = {3, 0.2, 0,0.5,0,0,3,0.5,64,7}
monsters[5] = {3, 0.3, 2,0.5,3,180,2,0.5,32,7}
monsters[7] = {4, 0.35, 6,0.5,8,150,2,0.7,26,7}
monsters[9] = {4, 0.05, 1,0.5,12,90,2,0.5,64,7}
monsters[11] = {4, 0.5, 4,1,0,90,2,0.5,64,7}
monsters[13] = {4, 0.2, 3,1,4,100,2,0.6,64,7}
monsters[20] = {5, 0.3, 2,1,8,60,2,0.5,64,7}
monsters[22] = {5, 0.2, 4,1.5,3,180,3,0.4,120,7}
monsters[24] = {5, 0.3, 6,1,3,30,1,0.4,120,7}
monsters[26] = {5, 0.6, 2,1,0,30,1,0.4,120,7}
monsters[28] = {5, 0.3, 3,1,8,60,2,0.5,100,7}
monsters[36] = {6, 0, move_none,1.5,6,30,2,0.6,300,7}
monsters[38] = {6, 0, move_none,1.5,7,30,2,0.6,300,7}
monsters[40] = {6, 0.5, 1,1.5,11,50,2,0.6,300,7}
monsters[42] = {6, 0.2, 2,1.5,5,80,2,0.6,300,7}
monsters[44] = {7, 0.5, 6,2,12,90,2,0.8,300,7}

monsterlist = {3,5,7,9,11,13,20,22,24,26,28,36,38,40,42,44}
boss = {}
boss[1] = {5}
boss[2] = {7,11}
boss[3] = {11,13}
boss[4] = {13,20}
boss[5] = {20,22}
boss[6] = {22,24}
boss[7] = {24}
boss[8] = {28,40}
boss[9] = {40,42}
boss[10] = {42,44}

-- monster class
monster = {}

-- create a new monster
function monster:new(nb, x, y)
	o = {}
	setmetatable(o, self)
 self.__index = self
	o.nb = nb
	o.x = x 
 o.y = y
 o.hp = monsters[nb][1]
 o.hpmax = o.hp
 o.spd = monsters[nb][2]
 o.move = monsters[nb][3]
 o.pow = monsters[nb][4]
 o.bul = monsters[nb][5]
 o.rate = 0
 o.bulsize = monsters[nb][7]
 o.bulspd = monsters[nb][8]
 o.buldist = monsters[nb][9]
 o.col = monsters[nb][10]
 o.destx = x
 o.desty = y
 -- random bound
 if o.move==6 then
  o.destx = -1+flr(rnd(2))*2
  o.desty = -1+flr(rnd(2))*2
 end
 o.touch = 0
 o.dash = 0
 o.poison = 0
 o.udlr = false
-- self:newdest()
	return o
end

-- can monster move
function monster:canmove(x,y,limit)
	-- compute movable
	local i, j, t
	for j=flr(y/8)-1,flr(y/8)+1 do
		for i=flr(x/8)-1,flr(x/8)+1 do
			t = mget(Š.mapx + i, Š.mapy+j)
			if not fget(t, 7) and colliderr(x+1,y+1,6,6,i*8,j*8,8,8) then
			 if x<7 then self.destx=1 end
			 if x>13*8 then self.destx=-1 end
			 if y<7 then self.desty=1 end
 		 if y>13*8 then self.desty=-1 end
				-- bound
				if self.move == 6 then
				 if limit==nil then
					 if self:canmove(x-1,y,1) then
					 	self.destx=-1
						end
					 if self:canmove(x+1,y,1) then
					 	self.destx=1
					 end
					 if self:canmove(x,y-1,1) then
					 	self.desty=-1
					 end
					 if self:canmove(x,y+1,1) then
					 	self.desty=1
					 end
					end
				end
				return false				
			end
		end
	end
	return true
end

-- new monster destination
function monster:newdest()
	-- rand1
 if self.move == 0 then
 	local r = flr(rnd(4))
 	self.destx = flr(self.x)
 	self.desty = flr(self.y)
 	if r == 0 then self.destx = flr(self.x) + 8 end
 	if r == 1 then self.destx = flr(self.x) - 8 end
 	if r == 2 then self.desty = flr(self.y) + 8 end
 	if r == 3 then self.desty = flr(self.y) - 8 end
 end
	-- rand2
 if self.move == 1 then
 	local r = flr(rnd(8))
 	self.destx = flr(self.x)
 	self.desty = flr(self.y)
 	if r == 0 then self.destx = flr(self.x) + 8 end
 	if r == 1 then self.destx = flr(self.x) - 8 end
 	if r == 2 then self.desty = flr(self.y) + 8 end
 	if r == 3 then self.desty = flr(self.y) - 8 end
 	if r == 4 then
 	 self.destx = flr(self.x) + 8
 	 self.desty = flr(self.y) + 8
 	end
 	if r == 5 then
 	 self.destx = flr(self.x) + 8
 	 self.desty = flr(self.y) - 8
 	end
 	if r == 6 then
 	 self.destx = flr(self.x) - 8
 	 self.desty = flr(self.y) - 8
 	end
 	if r == 7 then
 	 self.destx = flr(self.x) - 8
 	 self.desty = flr(self.y) + 8
 	end
 end
	-- rand3
 if self.move == 2 then
		local ok = false
		while not ok do
	  local dx = flr(rnd(12))+1
	  local dy = flr(rnd(12))+1
	  if fget(mget(Š.mapx+dx,Š.mapy+dy),7) then
	   self.destx = dx*8
	   self.desty = dy*8
	   ok = true
	  end
	 end
 end
 -- follow1 & follow2
 if self.move == 3 or self.move == 4 then
  self.destx = ‰.x
  self.desty = ‰.y
 end
end

-- update a monster
function monster:update()
	-- hit management
	if self.touch > 0 then self.touch = self.touch-2 end
 -- check dash move
 if self.move ~= move_none and self.touch > 40 and self.move ~= 5 then
 	local dx = self.x + cos(self.dash)*0.5
 	local dy = self.y + sin(self.dash)*0.5
		if self:canmove(dx, dy) then
		 self.x = dx
		 self.y = dy
		end
 	return
 end
	-- follow2
	if self.move == 4 then
		self:newdest()
	end
	-- check normal move
	if self.move == 6 then
		local dx = self.x + self.destx * self.spd
		local dy = self.y + self.desty * self.spd
		if self:canmove(dx,dy) then
			self.x = dx
			self.y = dy
		end
	else
		local angle = atan2(self.destx-self.x, self.desty-self.y)
		local dx = self.x + cos(angle) * self.spd
		local dy = self.y + sin(angle) * self.spd
		if round(self.x) == round(self.destx) and round(self.y) == round(self.desty) then
			self:newdest()
		else
			if self:canmove(dx, dy) then
				self.x = dx
				self.y = dy
			else
				self:newdest()
			end
		end
	end
	-- poison
	if self.poison > 0 then
		self.poison = self.poison-1
		if self.poison % 60 == 0 then
			self.hp = self.hp-0.5
		end
	end
	-- bullets
	if self.rate<monsters[self.nb][6] then
		self.rate=self.rate+1
	else
		self.rate=0
		self:shot()
	end
end

-- shot
function monster:shot()
	local angle,b
	-- rand1
 if self.bul==1 or self.bul==2 then
		angle=rnd(1)
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
		-- rand2
		if self.bul==2 then
			angle=rnd(1)
 		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
			add(bullets.list,b)
		end
 end
 -- follow1 & 3
 if self.bul==3 or self.bul==5 then
 	angle=atan2(‰.x-self.x,‰.y-self.y)
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
 end
 -- follow2 & 3
 if self.bul==4 or self.bul==5 then
 	angle=atan2(‰.x-self.x,‰.y-self.y)
		angle = angle-0.05
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
		angle = angle+0.1
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
 end
 -- updown & cross1 & star & udlr false & cross3
 if self.bul==6 or self.bul==9 or self.bul==12 or (self.bul==8 and not self.udlr) or (self.bul==11 and self.udlr) then
 	angle = 0.25
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
 	angle = 0.75
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
 end
 -- leftright & cross1 & star & udlr true & cross3
 if self.bul==7 or self.bul==9 or self.bul==12 or (self.bul==8 and self.udlr) or (self.bul==11 and self.udlr) then
 	angle = 0
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
 	angle = 0.50
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
 end
 -- cross2 & star & cross3
 if self.bul==10 or self.bul==12 or (self.bul==11 and not self.udlr) then
 	angle = 0.125
		b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
		add(bullets.list,b)
		local i
		for i=1,3 do
	 	angle = angle+0.25
			b = bullet:new(1,self.x+3+cos(angle)*self.bulsize*2,self.y+3+sin(angle)*self.bulsize*2,self.bulsize, elem_monster, angle, self.bulspd, self.buldist, self.pow)
			add(bullets.list,b)
		end
 end
 if self.bul~=0 then
	 sfx(4)
		self.udlr = not self.udlr
	end
end

-- kill a monster
function monster:kill()
	score=score+self.hpmax
	local t = mget(round(self.x/8), round(self.y/8))
	sfx(1)
 local i,p
	for i=0,rnd(50)+30 do
		p = {self.x+4,self.y+8,8,rnd(1)+0.3,rnd(2*3.14),rnd(40)+10}
	 add(particles,p)
	end
	-- blood
	add(Š.blood,{self.x,self.y})
	-- loot
	local rate=6
	if self.col==8 then rate=5 end
	if self.col==10 then rate=4 end
	local r=flr(rnd(5))
	local l=0
	if r==0 then l=1 end
	if r==1 then l=2 end
	if r==3 then
		l=flr(rnd(#itemlist-1))+2
	end
	if self.col ~= 0 then
		if l>0 then
			add(Š.items,item:new(itemlist[l],self.x,self.y))
		end
	else
   add(Š.items,item:new(120,7*8,7*8))
	end	
end

-- hit a monster
function monster:hit(dmg)
	if self.touch <= 0 then
  sfx(2)
		self.hp = self.hp - dmg
		self.touch = 80
		self.dash = atan2(self.x-‰.x,self.y-‰.y)
 	local i,p
		for i=0,rnd(20)+10 do
			p = {self.x+4,self.y+4,8,rnd(1)+0.3,rnd(2*3.14),rnd(40)+10}
		 add(particles,p)
		end
	end
end

-- draw a monster
function monster:draw()
	-- check touch
	if flr(self.touch / 10) % 2 == 0 then
		-- color
		local i
		for i=0,15 do
			pal(i,self.col)
		end
		aspr(self.nb, self.x+4-1, self.y+8)
		aspr(self.nb, self.x+4+1, self.y+8)
		aspr(self.nb, self.x+4, self.y+8-1)
		aspr(self.nb, self.x+4, self.y+8+1)
		pal()
		aspr(self.nb, self.x + 4, self.y + 8)
		-- draw poison
		if self.poison > 0 then
			rectfill(self.x+7+4, self.y+8,self.x+7+4+1,self.y+8+1,3)
		end
	end
end
-->8
-- bullet management
bullets = {}
bullets.list = {}

-- update bullets
function bullets.update()
	local k, b, mov
	for k, b in pairs(bullets.list) do
		mv=b:update()
		if b.distcnt >= b.dist or not mv then
			if b.col == elem_frag and b.size > 1 then
				b:frag()
			end
			if b.col~=elem_glue or (b.col==elem_glue and b.distcnt>=b.dist) then
				del(bullets.list, b)
				b = nil
			end
		end
	end
end

-- draw bullets
function bullets.draw()
	local k, b
	for k, b in pairs(bullets.list) do
		b:draw()
	end
end


-- bullet class
bullet = {}

-- create a new bullet
function bullet:new(owner, x, y, size, col, angle, spd, dist, pow)
	o = {}
	setmetatable(o, self)
 self.__index = self
	o.owner = owner -- 0: player, 1: monster
	o.x = x
	o.y = y
	o.size = size
	o.col = col
	o.angle = angle
	o.spd = spd
	o.dist = dist
	o.pow = pow
	o.distcnt = 0
	return o
end

-- draw the bullet
function bullet:draw()
	local col=7
	if self.col==elem_ghost then col=5 end
	circfill(self.x+4, self.y+8, self.size, self.col)
	circ(self.x+4, self.y+8, self.size, col)
end

-- frag the bullet
function bullet:frag()
	local b
	b = bullet:new(self.owner, self.x,self.y,1,elem_frag, 0.875, self.spd, self.dist/2,self.pow/2)
	add(bullets.list,b)
	b = bullet:new(self.owner, self.x,self.y,1,elem_frag, 0.875*3, self.spd, self.dist/2,self.pow/2)
	add(bullets.list,b)
	b = bullet:new(self.owner, self.x,self.y,1,elem_frag, -0.875, self.spd, self.dist/2,self.pow/2)
	add(bullets.list,b)
	b = bullet:new(self.owner, self.x,self.y,1,elem_frag, -0.875*3, self.spd, self.dist/2,self.pow/2)
	add(bullets.list,b)
end

-- check if bullet can move
function bullet:canmove(x, y)
	local i,j,t
	-- ghost
	if self.col == elem_ghost then return true end
 -- normal collision
	for j=flr(y/8)-1,flr(y/8)-1+1 do
		for i=flr(x/8)-1,flr(x/8)+1 do
			t = mget(Š.mapx+i, Š.mapy+j)
			if fget(t, 0) and colliderr(x, y, self.size*2, self.size*2, i*8+1, j*8+1, 6, 6) then
				return false
			end
		end
	end
	return true
end

-- update the bullet
function bullet:update()
	-- check monsters 
	if self.owner == 0 then
		self:checkmonsters()
	end
	-- check hero
	if self.owner == 1 then
		self:checkhero()
	end
	local x = self.x + cos(self.angle) * self.spd
	local y = self.y + sin(self.angle) * self.spd
	self.distcnt = self.distcnt + self.spd
	if self:canmove(x, y) then	
		self.x = x
		self.y = y
		return true
	else
		return false
	end
end

-- check hero collision
function bullet:checkhero()
 if ‰.touch<=0 and colliderr(self.x-(self.size),self.y-(self.size),self.size*2,self.size*2,‰.x+1,‰.y+1,6,6) then
	 ‰:hit(self.pow)
	  self.distcnt=self.dist
 end
end

-- check monsters collision
function bullet:checkmonsters()
	local k, m
	for k,m in pairs(Š.monsters) do
		if colliderr(self.x-self.size,self.y-self.size,self.size*2,self.size*2,m.x+1,m.y+1,6,6) then
			m:hit(self.pow)
			if self.col==elem_poison then
				m.poison = 180
			end
			if self.col~=elem_ghost then
			 self.distcnt=self.dist
			end
		end
 end
end

-- particles management
-- x,y,col,spd,angle,life
particles = {}

-- update particles
function updatepart()
	local k, p
	for k,p in pairs(particles) do
		p[1] = p[1]+cos(p[5])*p[4]
		p[2] = p[2]+sin(p[5])*p[4]
		p[6] = p[6] - 1
		if p[6] <= 0 then
			del(particles, p)
			p = nil
		end
	end
end

-- draw particles
function drawpart()
	local k, p
	for k,p in pairs(particles) do
		pset(p[1],p[2],p[3])
	end
end

-- void particles & bullets
function void()
	local k,v
	for k,v in pairs(bullets.list) do
	 del(bullets.list,v)
	 v=nil
	end
	for k,v in pairs(particles) do
	 del(particles,v)
	 v=nil
	end	
end
__gfx__
00000000011111000111110000000000000000000666666006666660000000000040040000022200000222000ff00ff00ff00ff0002dd000002dd00000000000
000000001111111011111110000c00000000c00006866860068668600240042002744720002eee20002eee20008ff800008ff80002dddd0002dddd0000000000
007007001ccf1c101ccf1c1000cc00000000cc000666666006666660227447220204402002e22ee202e22ee2000ff000000ff0002d0d0dd02d0d0dd000000000
000770001ccfcc101ccfcc1000ccc000000ccc0006666660066666602d2442d20224422002e2e2e202e2e2e2004ff400004ff4002d0d0dd02d0d0dd000000000
00077000166f6610166f66100c7c7cc00cc7c7c000066000000660002dd22dd202d33d2007eee2e207eee2e2040450400044540002ddddd002ddddd000000000
007007001fffff101fffff10cc7c7cccccc7c7cc00655600006556002dddddd2022dd220cc222ee2cc222ee20005400000054000002ddd00002ddd0000000000
000000001044401010444010cccccccccccccccc00066000060660602d2222d202222220cceeee20cceeee20004444000044440000002d0d00002d0000000000
0000000004000400004040000cccccc00cccccc0006006000006600002000020020000200222220002222200004004000400004000000dd000000ddd00000000
0033000000000000000000000000000000000000000000000005555500055555400a00a0400a00a0000000000000000000099900000999000000000000000000
0300300000c0c00000c0c00000c0c00008800eee00000000000033350000333504ae0a0004ae0a00000000003000000300993300009933000000000000000000
303303000c7c7c000c8c8c000c8c7c000080088008800eee0005a5a50005a5a5088eee000eeeee00000000000330033000933730009337350000000000000000
303303000c777c000c888c000c887c0000808800008088000000333500003335888eee00eeeeee00333003330003300000444305004443050000000000000000
0300300000c7c00000c8c00000c8c000000e0000000e000003444b9000344b90778eeee0888eeee0000330000334433044444405444444540000000000000000
00330000000c0000000c0000000c00000a8eee000a8eee0000004990000049905778eee07778eee0033443303039930355444554554445000000000000000000
000000000000000000000000000000000888e0000888e0000000449000004490578eee00578eee00303993030300003000555000005550000000000000000000
0000000000000000000000000000000000000e0000000e00000440900000440988eee00088eee000030000300300003000202200020220000000000000000000
00555000000000000000000000000000000999000009990000011100000111000090000000900040900990099009900900919190001919100000000000000000
050005000000000000000000000000000098a8900098a8900018c8100018c8100449004004490040099aa990099aa99019191910919191900000000000000000
05000500000000000000000000000000009aaa90009aaa90001ccc10001ccc104444994044449940097aa790097aa79091111191191111190000000000000000
055555000000000000000000000000000008880000088800000888000008880005cfc04005cfc0409a8aa8a99a7aa7a919717119917171910000000000000000
05606500000000000000000000000000000808003308080000080800330808000577704005777f409aaaaaa99aaaaaa991878791198787190000000000000000
056065000000000000000000000000003303003303030000330300330303000001771f400177104009a88a9009a88a9019878719918787910000000000000000
0555550000000000000000000000000003303330003033300330333000303330f171104001711040099aa990099aa99001919191091919190000000000000000
00000000000000000000000000000000000330000003300300033000000330031111104011111000900990099009900909191900019191000000000000000000
00001110000000000001111001001000000000000000000000000000000011100000000000011100000000010001000000000000000000000000000000000000
01115551000000000015555114114100100000001000100000001100000155510001000000155510110000151015111000000000000000000000000000000000
15551111000010000151111001444410511101115101511110015510001511151015100001511511551000110011155100000000000000000000000000000000
01151015100151000151000001411410105515515100115551051151001510151151510001511511515101510151511510000000000000000000000000000000
00151015511555100015100101444411515151515511515115115551001510151151100011555101511511511511510100000000000000000000000000000000
00015115151511000015111501411411515111515151515115111551001511511555100015115115111515101515111000000000000000000000000000000000
00015115151155100001555100144441151511515511515115155110000155101511000015115101155115115101555100000000000000000000000000000000
00001001010011000000111000141141010100101100101001011000000011000100000001001000011001001000111000000000000000000000000000000000
666666665555555555555555555555555555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00444400070007000003333000cc0000
666666665577757777777577777757555444444550000005baaaaaabbaaaacabbacaacabbacaacabbacaacabbacacacb04aaaa40717771700003303300c1c000
666666665756656666666566666655755444444556000065baaaaaabbaaacccbbccccccbbccccccbbccccccbbccccccb02444420717171700030030000c11ccc
666666665555656666666566666656755494444556666665baaaaaabbaaa1cabbaca1cabbac11cabbacaacabbacacacb2aaaaaa271717170003003000c1cc11c
666666665766555555555555555566755494444556666665baaaaaabbac1aaabba11acabbac11cabba1aa1abba1a1a1b2a9aa9a2071117000ee00ee0c11cc1c0
666666665766556666656666665555555444444556666665baaaaaabbcccaaabba11cccbbccccccbba1aa1abba1a1a1b2aaaaaa200717000e88ee88eccc11c00
666666665766565666656666656566755444444556666665baaaaaabbacaaaabbaaaacabbacaacabba1aa1abba1a1a1b2a2222a200717000e88ee88e000c1c00
666666665766566555555555566566755444444556666665bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb02000020007770000ee00ee00000cc00
5555555557665665655555565665667555555555555555556666b666066666600000000004040400000000000011100000070000033333300005555000050000
7777757757665665566655655665667554444444506666666bb6666605666650444400004f4f4f4000ccc0000001000000777000337337330055333000575000
66669566555556655556565556656675544444445006666666666bbb60000006499400004f4f4f400c000c00444ddddd00777000337377730053535305757500
66699566576656655566665555556675544444445006666666bbbbb666800866499954504f444444c00700c0444d0dd002727200337337330503353305757500
559aa9555766555556665555566566755444444450066666bbbbbb6666000066499595944fff4ff4c07c70c04404000022727220337333330503535357555750
6664466657665665565555555665555554499444500666666bbbb66666000066499999944ffff4f4c00700c04004000022727220337773330003353357775400
666566665766566556655665566566755444444450666666666bbbb6665005664999999404ffff400c000c000000000000a0a000333773330003535305550040
5555555557665665655555565665667555555555555555556b66666666555566444444440044440000ccc000000000000090900003333330000033300000000a
57665665576656655555555556656675666966660000000066656666665555660000000000000000787877707757777077877770755577700000000000000000
57665665576656566656666665656675666996660000000056656555665595660000000000000000888887707555777078887770575757700000000000000000
55559665555555666656666666556675669999660000000065565666665995660000000001000010888887705555577088888770555557700000000000000000
5799a465576655555555555555556675669aa9660000088066656566669aa9660000000015111111788877707757777078887770575757700000000000000000
5769a455576566666666566666665555449aa9440000000065566656665445660000000015111111778771707555717077877170755571700000000000000000
57669665575566666666566666665575664aa4660880000056656665655555560000000001055010777717107777171077771710777717100000000000000000
57665665557577777777577777775755664444660000888066665666655555560000000000005000777711107777111077771110777711100000000000000000
57665665555555555555555555555555446666440008880066656666655555560000000000000000777717107777171077771710777717100000000000000000
55555555566566756656666666666666666666660000000000000000666666665550000066666666000000000000000000000000000000000000000000000000
66566666566566756656666666777766666666660000000000000000666646665995000066866666000000000000000000000000000000000000000000000000
66544666566966756656666667077076666766660000000000000000646666665559500068888666000000000000000000000000000000000000000000000000
559aa955554a96756656665667077076677777660000000000000000666666465a55950066888866000000000000000000000000000000000000000000000000
66699666564a99756585665667777776766786760000000000000000666666665aa5595068666666000000000000000000000000000000000000000000000000
66695666566955556886668866677866678777660000000000000000646666665aaa559566666668000000000000000000000000000000000000000000000000
77775777566566758888665888877886786766760000000000000000666666665aaaa59566668866000000000000000000000000000000000000000000000000
55555555566566756666655568888666688778860000000000000000666664665555555566666666000000000000000000000000000000000000000000000000
15040404257777777777043737043515650404047777777777040404653515040406047777777777041704043515040404047777777777040404043515040404
27777777777727040404351566040404777777777704046604351504040404777777777704040404351504040404777777777704040404350000000000000000
15040404040477777704040404043515040404040477777704040404043515040415040477777704043504043515040404040477777704040404043515370404
04277777772704040404351504040437047777770404040404351504040404047777770404040404351504040404257777772504040404350000000000000000
15750404040404040475040404043515040404040404040404040404043515040425040404040404042504043515040404140525042505340404043515272704
04040404040404042727351547040404040404040404040404351504040404040404040404040404350604040404042525250404040404350000000000000000
14242424250404041424242424243414242424242425042524242424243415777704040404040404040477773515777704060404040404170477773515777727
04040404040404277777351577770404040404040404047777351577770404040404040404047777351577772504040404040404257777350000000000000000
15777777040404041504047777773515777777040404040404047777773515777777040404040404047777773515777777250404040404257777773515777777
04040404040404777777351577777704040404040404777777351577777704750404047504777777351577777725040404040425777777350000000000000000
04777777040404271504047777770404777777040404650404047777770404777777040404040404047777770404777777040404460404047777770404777777
04040404040404777777040477777704040404040404777777040477777704760404047604777777040477777725040404040425777777040000000000000000
15777777040427271504047777773515777777040404040404047777773515777777040404040404047777773515777777250404040404257777773515777777
04040404040404777777351577777704040447660404777777351577777704040404040404777777351577777725040404040425777777350000000000000000
15777504040404271504040477773516262626262625042526262626263615777704040404040404040477773515777704060404040404170477773515777727
04040404040404277777351577770404040404660404047777351577770404040404040404047777351577772504040404040404257777350000000000000000
14242434040404041504040404043515040404040404040404040404043515040425040404040404042504043515040404160725042507360404043515272704
04040404040404042727351504040404040404040404040404351504040404040404040404040404351504040404042525250404040404350000000000000000
15040435040477772504040404043515040404040477777704040404043515040415040477777704043504043515040404040477777704040404043515040404
04277777772704040404351504040404047777770404040404351504040404047777770404040404351504040404257777772504040404350000000000000000
15040425047777777777040437753515650404047777777777040404653515040406047777777777041704043515040404047777777777040404043515040404
27777777777727040404351547660404777777777704040404351504040404777777777704040404351504040404777777777704040404170000000000000000
15040404047777777777040404763515656504047777777777040465653515040415047777777777043537473515460404047777777777040404463515040404
27777777777727370404351547040404777777777704040437351504040404777777777704040404351504040404777777777704040404350000000000000000
16262626262626042626262626263616262626262626042626262626263616262616262626042626263626263616262626262626042626262626263616262626
26262604262626262626361626262626262604262626262626361626262626262604262626262626361626262626260704262626262626360000000000000000
14242424242424042424242424243414242424052424042424052424243414242424242424042424242424243414242424242424042424242424243414242424
24242404242424242424341424240524242404242424052424341424242424242486242424242424341424242405242404242405242424340000000000000000
15370404049777777777040404473515040404049797979797040404043515040404047797777777040404473515252525047777777777042525253515272747
04777777777704042727351504046504777777777704650404351586868686868686868686868686351566042504777777777704040466350000000000000000
15040404979777777777040404043515049704049797979797040497043515040465047777777797040404043515252525047777777777042525253515270404
04777777777704040427351504046504777777777704650404351586868686868686868686868686351504042504777777777704040404350000000000000000
15040404970477777704040497043515040404040497979704040404043515040404046577779704040465043515252525040477777704042525253515040497
04047777770404040447350665650404047777770404046565171586868686868686868686868686351504042504777777777704252525350000000000000000
15040404040404040404040404043506040404049704040404040404041715370404040404040404040404043515040404040404040404040404043515040404
97040404049797040404351504040404040404040404040404351586868686868686868686868686350604040404040404040404040404170000000000000000
15777704040404040404040477773515979704040404040404040497973515779704040404040404040477773515777704040404040404040477773515777704
04040404049704047777351577770404656565656504047777351586868686868686868686868686351577777704040404040404777777350000000000000000
15777777040404040404377777773515979797040404040404979797973515777797040404650404047777773515777777040404040404047777773515777777
04040427040404777777351577777704650404046504777777351586868686868686868686868686351577777704040404040404777777350000000000000000
04777777040497970404047777770404979797979704040404049797970404779777040404040404047797970404777777040404040404047777770404777777
04042727270404777777040477777704650404046504777777048686868686868686868686868686860477777704040404040404777777040000000000000000
15777777040404979704047777773515979797040404049797049797973515977777040404040404047797773515777777040404040404047777773515777777
04040427040404777777351577777704650404046504777777351586868686868686868686868686351577777704040404040404777777350000000000000000
15777704040404040404040477773515979704040404049704040497973515779704046504040404040477773515777704040404040404040477773515777704
04040404040404047777351577770404656565656504047777351586868686868686868686868686351577777704040404040404777777350000000000000000
15040404040404044704040404043506040404040497040404040404041715040404040404040465040404043515040404040404040404040404043515049704
04040404040404040497351504040404040404040404040404351586868686868686868686868686350604040404040404040404040404170000000000000000
15979704040477777704040404043515040404040497979704049704043515046504040497777704040465043515252525040477777704042525253515040404
04047777770404979797350665650404047777770404046565171586868686868686868686868686351525252504777777777704250404350000000000000000
15040404047777777777040404043515049704049797979797040404043515040404049777977797040404043515252525047777777777042525253515270404
97777777777704979727351504046504777777777704650404351586868686868686868686868686351504040404777777777704250404350000000000000000
15470404047777777777049797973515040404049797979797040404043515043704047777777797040404043515252525047777777777042525253515272704
04777777777797972727351504046504777777777704650404351586868686868686868686868686351566040404777777777704250466350000000000000000
16262626262626042626262626263616262626072626042626072626263616262626262626042626262626263616262626262626042626262626263616262626
26260704072626262626361626260726262604262626072626361626262626262686262626262626361626262607262604262607262626360000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080010101018000000000000000000000010101010080020100000000000000000101010102808001800000000000000001010201010000808080000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4142424242504240425042424242434142424242424240424242424242434142425042424240424242425042434142424242424240424242424242434142424242424240424242424242434142424242424240424242424242434142424242424240424242424242434142424242424240424242424242430000000000000000
5140404040407740774040404040535140404077777777777777404040535173404040777777777740407373535164404040666640666640404064535140404040405277524040404040535179797974777777777779797979535140404040777777777740404040535164644040777777777740406464530000000000000000
5140404040404040404040404040535173404040777777777740404040535140404040777777777740404079535140404040666640666640404040535140404040405277524040404040535179567940407777774040795679535140404040777777777740404040535164644040777777777740406464530000000000000000
5140404057404040404057404040535140407940407777774040404040535140404040777777777740404040535140404040404040404040404040535140405640404077404040564040535140405640404057404040564040535140404040407777774040404040535140404040407777774040404040530000000000000000
5140404067404040404067404040535177404040404040404040404077535140404040404040404040404040535140404040404040404040404040535140404040405277524040404040535140404040404067404040404077535140404040404040404040404040535140404040404040404040404040530000000000000000
6040404040404077404040404040715177774040404040404079407777535177777740404040404040777777535166664040404040404040406666535140404040405277524040404040535177404040404040404040407777535177774040404040404040407777535177774040404040404040407777530000000000000000
5177404040407777774040404077535177777740404066404040777777535177777740404057404040777777535166664040404040404040406666535152524052524077405252405252535177774079404040404040407777535177777740404040404040777777535177777740404040404040777777530000000000000000
4040404040777777777740404040404077777740406666664040777777404077777740404067404040777777404040404040404064404040404040404077777777777777777777777777404077774040405656564040407777404077777740404040404040777777404077777740404064404040777777400000000000000000
5177404040407777774040404077535177777740404066404040777777535177777740404040404040777777535166664040404040404040406666535152524052524077405252405252535177774040404040404040407777535177777740404040404040777777535177777740404040404040777777530000000000000000
6040404040404077404040404040715177774040404040404040407777535177777740404040404040777777535166664040404040404040406666535140404040405277524040404040535177404040404040404040404077535177774040404040404040407777535177774040404040404040407777530000000000000000
5140404057404040404057404040535177404040404040404040404077535140404040404040404040404040535140404040404040404040404040535140404040405277524040404040535140404040404057407940404074535140404040404040404040404040535140404040404040404040404040530000000000000000
5140404067404040404067404040535140407940407777774040404040535140404040777777777740407379535140404040404040404040404040535140405640404077404040564040535140405640404067404040567979535140404040407777774040404040535140404040407777774040404040530000000000000000
5140404040404040404040404040535140404040777777777740404040535140404040777777777740407479535140404040666640666640404040535140404040405277524040404040535140567940407777777979795679535140404040777777777740404040535164644040777777777740406464530000000000000000
5140404040407740774040404040535140404077777777777777407340535179744040777777777740797979535164404040666640666640404064535140404040405277524040404040535179797379777777777779797979535140404040777777777740404040535164644040777777777740406464530000000000000000
6162626262706240627062626262636162626262626240626262626262636162627062626240626262706262636162626262626240626262626262636162626262626240626262626262636162626262626240626262626262636162626262626240626262626262636162626262626240626262626262630000000000000000
4142424242424240424242424242434142425042424240424242504242434142424242424240424242424242434150505050505040505050505050434142424242424240424242424242434142424242424240424242424242434142424242424240424242424242434142424250424240424242425042430000000000000000
5179794040777777777740734040535140404052777777777752404040535140404040567777775640404040536064404040776477647740404064715173404072777777777772404040535140404040405240524040404040535140404040777777777740404040535173794040777777777740407379530000000000000000
6079794040777777777740404040535140404040777777777740404040535140404040777777777740404040536040404040776477647740404040715140404072777777777772404040535140404040405240524040404040535140406640777777777740406640536079797440777777777740407479530000000000000000
6040404040407777774040404040535140404040407777774040404040535140405240407777774040524040536040404040777777777740404040715140404040407777774040404040535140405240405240524040405240535179724040407777777440404040535140404040407777774040404040530000000000000000
5174404052404040404052404040535152525240404040404040525252535140404040734040404040404040536040404040777777777740404040715172724040404040404040407272535140404040405240524040404040535140404040404040404040407279535140404040404040404040404040530000000000000000
5177774040527979795240407777535177774040404040404040407777535156774040565656565640407756536077777777404040404077777777715177774040724040407240407777535140404040404040404040404040535177774040405640404040407777535177774040404040404040407777530000000000000000
5177777740795279527940777777535177777740404040404040777777535177777740404040404040777777536064647777404040404077776464716077777740404040404040777777715152525252404040404052525252535177777740404066664040777777535177777740404057404040777777530000000000000000
4077777740797979797940777777404077777740406657664040777777404077777740404040404040777777404077777777404040404077777777404077777740404072404040777777404040404040404040404040404040404077777740404066664040777777404077777740406467644040777777400000000000000000
5177777740795279527940777777535177777740404067404040777777535177777740404040404040777777536064647777404040404077776464716077777740404040404040777777715152525252404040404052525252535177777740407240404040777777535177777740404064404040777777530000000000000000
5177774040527979795240407777535177774040406640664040407777535156774040565656565640407756536077777777404040404077777777715177774040724040407240407777535140404040404040404040404040535177774040404040405640407777535177774040404040404040407777530000000000000000
5140404052404040404052404040535152525240404040404040525252535140404040404040407340404040536040404040777777777740404040715172724040404040404040407272535140404040405240524040404040535140405640404040404079406679535140404040404040407940404040530000000000000000
5140404040407777774040404040715140404040407777774040404040535140405240407777774040524040536040404040777777777740404040715140404040407777774040404040535140405240405240524040524040535140404040747777774040404040535140794040407777774040404040530000000000000000
5173404040777777777740404074715140404040777777777740404040535140404040777777777740404040536040404040776477647740404040715140404072777777777772404040535140404040405240524040404040535140644040777777777740406440535140404040777777777740404040710000000000000000
5173734040777777777740407474535140404052777777777752404040535140404040567777775640404040536064404040776477647740404064715140404072777777777772404074535140404040405240524040404040535166797979777777777740404040535140564040777777777740405640530000000000000000
6162626262626240626262626262636162627062626240626262706262636162626262626240626262626262636170707070707040707070707070636162626262626240626262626262636162626262626240626262626262636162626270626240626270626262636162626262627040706262626262630000000000000000
4142424243424240424242424242434142424242424240424242424242434142424142424240424242434242434142424242424240424242424242434142424242424240424242424242434142424250424240424250424242434142424242424240424242424242434150424242424240424242424242430000000000000000
5174404053777777777740404040535156564040777777777740405656535173735140777777777740534040535164404040777777777740404064535140404072777777777772404040535166664040777777777774404040535140404040777777777740404040535140404040777777777740404040530000000000000000
__sfx__
000100002a05028050270502505023050210501f050221001a10001100011000110000100001001d1001c10004100021000010000100001000010000100001000010000100001000010001100011000110001100
000100002755020650235501a65020550146501b5500f650155500965011550046500c55002650085500065004550016500155000550000000000000000000000000000000000000000000000000000000000000
000100001a65016550145500e6500e5500a5500c5500b500095000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000002a1502a1502a6502b1502c1502c6502f15031150316503515037150396503e1503f15000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001d5501f5502155025550241002f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001b2501f250232501d200202002320024200263002c3002c3002f300323002d20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001e3501e350000002135000000243502435024350243500000000000213502135021350000000000024350243500000000000000000000000000000000000000000000000000000000000000000000000
011000002b3502a350283502635024350223502235022350223500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900002635000000263500000026350000002635026350263502635000000000002b3502b3502b3502b35000000000002235022350223502235000000000002635026350263502635000000000000000000000
014000201e5201e5201f5201f5201b5201b5201e5201e5201e1201e1201f1201f1201b1201b1201e1201e1201e5201e5201f5201f52021520215201f5201f5201e1201e1201f1201f1201b1201b1201e1201e120
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
010900101015010150000000000010150101500010000000121501215012150121500010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
