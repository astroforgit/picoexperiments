pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--domain conflict
--by 16 shades of pico

local state = "credits"
local fade_in = -1
local fade_out = -1
local win_timer = -1
local game_timer = 0
local game_time = 3*60
local threshold = 0.55
local music_on = true

local stars={}
local l1,l2,l3

local screen_shake = 0;


local musics = {}
musics[0] = 4
musics[1] = 20
musics[2] = 25
local music_index = 0

function update_music(delay)
	delay = delay or 0
	if (music_on and music_index>=0) then music(musics[music_index],delay)
	else music(-1) end
end
function sound(ind)
	if (music_on) then sfx(ind,2) end
end

local mapw=16
local maph=16

local t = 0
local fov = 60/360
local screenox = 0
local screenoy = 0
local screenh = 62
local screenw = 128
local zbuffer={}

local v_camera = {}
v_camera.x = mapw/2 + 0.5
v_camera.y = maph/2 + 0.5
v_camera.z=0.5
v_camera.dir = 0
v_camera.dirx = -1
v_camera.diry = 0
v_camera.planex = 0
v_camera.planey = planewidth
v_camera.drawfloor = true
v_camera.wallstate = 0
v_camera.fov = 45
v_camera.update = function()	
	v_camera.planewidth = -2*sin(v_camera.fov/720)/cos(v_camera.fov/720)
	v_camera.planeheight = 128/v_camera.planewidth/2

	v_camera.planex = v_camera.planewidth*v_camera.diry
	v_camera.planey = -v_camera.planewidth*v_camera.dirx	
end
local game_t = 0

local floordist = {}

local colors = {
	map_wall = 1,
	map_floor = 0,
	map_player1 = 8,
	map_player2 = 11
}


local entities = {}
local player1, player2
local capture = {}
local points = {
	empty = 0,
	player1 = 0,
	player2 = 0,
	total = 0
}

local wall_spr = {}
wall_spr[0] = {x=3*8,y=0*8}
wall_spr[1] = {x=4*8,y=2*8}
wall_spr[2] = {x=5*8,y=2*8}

--entity
local entity, player, powerup, particle, boom, switch

entity = {
	x=8, y=8, z=0.5,
	px=8,py=8,
	sprx = 10*8,
	spry = 4*8,
	sprh = 8,
	sprw = 8,
	w=8,
	h=8,
	remove = false,
	dist = -1,
	visible = true,
	dolevelcollisions = false,
	radius = 0.25,
	wallocclusion = false
}

function entity:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function entity:preupdate()
	self.px = self.x
	self.py = self.y
end
function entity:update() 
end
function entity:levelcollisions()
	if (not self.dolevelcollisions) then return end

	local nx,ny = 0,0

	self.x = stepto(self.px,self.x,self.radius-0.01)
	self.y = stepto(self.py,self.y,self.radius-0.01)

	local xc = flr(self.x)
	local yc = flr(self.y)

	if (tileissolid(getmap(xc,yc))) then
		self.x = self.px
		xc = flr(self.x)
	end

	local xr = self.x - xc
	local yr = self.y - yc

	if (tileissolid(getmap(xc-1,yc)) and xr < self.radius) then
		xr = self.radius
		nx = 1
		ny = 0
	end
	if (tileissolid(getmap(xc+1,yc)) and xr >= 1 - self.radius) then
		xr = 1-self.radius
		nx = -1
		ny = 0
	end

	self.x = xc + xr
	xc = flr(self.x)

	if (tileissolid(getmap(xc,yc-1)) and yr < self.radius) then
		yr = self.radius
		nx = 0
		ny = 1
	end
	if (tileissolid(getmap(xc,yc+1)) and yr >= 1 - self.radius) then
		yr = 1-self.radius
		nx = 0
		ny = -1
	end

	self.y = yc + yr
end

function entity:tint() end
function entity:setpos(x,y) 
	self.x = x; self.y = y
	self.px = x; self.py = y
end

function entity:place()
	for i=0,100 do
		self.x,self.y = flr(rnd(mapw)),flr(rnd(maph))
		
		if (not tileissolid(getmap(self.x,self.y))) then
			self.x += 0.5
			self.y += 0.5
			self.px = self.x
			self.py = self.y
			break 
		end
	end	
end

-- particle
particle = entity:new({
	t = 0,
	type="particle",
	lifetime = 1
})

function particle:update()
	self.t += 1/30
	self.remove = self.t > self.lifetime
	local s = 8 * (1 - self.t/self.lifetime)
	self.w = s
	self.h = s
end


--player
player = entity:new({
	ind = 0,
	dir = 0,
	dirx = 0, diry = 0,
	sprx = 9*8, spry = 0,
	sprw = 8, sprh = 16,
	w=8, h=16,
	powerup = false,
	dolevelcollisions = true,
	walk_anim = 0,
	fov = 45,
	wallocclusion=true
})

function player:update()
	if (win_timer<0) then
		if(btn(0, self.ind)) do self.dir -= 0.01 end
		if(btn(1, self.ind)) do self.dir += 0.01 end

		self.dirx = cos(self.dir)
		self.diry = sin(self.dir)	

		if(btn(2,self.ind)) do 
			self.x += self.dirx/8
			self.y += self.diry/8
			self.walk_anim += 1/30
		end
		if(btn(3,self.ind)) do 
			self.x -= self.dirx/8
			self.y -= self.diry/8
			self.walk_anim += 1/30
		end

		if (self.walk_anim % 0.25 < 0.125) then
			self.sprx = (9+self.ind)*8
		else
			self.sprx = (11+self.ind)*8
		end
	end

	if (self.powerup) then
		local i = flr(self.x)+flr(self.y)*mapw
		if (capture[i] != self.ind+1) then	
			capture[i] = self.ind+1
			
		end
		local p = particle:new({
			x = self.x + rnd(1)-0.5, 
			y = self.y + rnd(1)-0.5,
			z = rnd(0.15),
			sprx = (7+self.ind)*8, spry = 0*8
		})
		add(entities,p)
	end

	--if (btn(4,self.ind)) then self.z += 0.05 end
	--if (btn(5,self.ind)) then self.z -= 0.05 end

	--[[if (btn(4, self.ind)) then
		
	end]]--
	self.z = 0.5 + 0.05*sin(2*self.walk_anim)
	self.z = max(0,min(self.z,1))

	if (self.powerup) then
		self.fov = 60*2
	else
		self.fov = 60
	end
end

function player:setv_camera(cam)
	screenoy = (screenh+1)*self.ind
	cam.x = self.x
	cam.y = self.y
	cam.z = self.z
	cam.dir = self.dir
	cam.dirx = self.dirx
	cam.diry = self.diry
	cam.fov = self.fov

	cam.update()
	if (self.powerup) then
		cam.wallstate = self.ind+1
		
		--[[if (screen_shake > 0) then
			local v = 0.1
			local dx = v-rnd(2*v)
			local dy = v-rnd(2*v)

			cam.x += dx*cam.diry
			cam.y += -dx*cam.dirx
			cam.z += dy
		end]]--
	else
		cam.wallstate = 0
	end
	switch.visible = not self.powerup
	cam.drawfloor = self.powerup
	cam.z = max(min(cam.z,1),0)
end

-- powerup
powerup = entity:new({
	sprx = 13*8,
	spry = 0*8
})

function powerup:pickup() end

function powerup:update()
	self.w = 8*abs(sin(1.33*game_t))
	self.z = 0.5 + 0.1*sin(game_t)

	local cx = flr(self.x)
	local cy = flr(self.y)
	local pick = false
	if(flr(player1.x) == cx and flr(player1.y) == cy) then
		self:pickup(player1,player2)
	end
	if(flr(player2.x) == cx and flr(player2.y) == cy) then
		self:pickup(player2,player1)
	end
end

--switch
switch = powerup:new()

function switch:tint()
	local c = flr(30*game_t)%15 + 1
	pal(3,c)
	pal(12,c)
end

function switch:pickup(player,oplayer)
	if (player.powerup) then return end
	if (music_index == 1) then music_index = 2
	else music_index = 1 end
	update_music(2000)
	sound(19)

	player.powerup = true
	oplayer.powerup = false
	self:place()

	screen_shake += 30;
end

--bomb
bomb = powerup:new({
	type="bomb",
	sprx=10*8,
	spry=2*8
})

function bomb:pickup(player,oplayer)
	if (not player.powerup) then return end
	
	local cx = flr(self.x)
	local cy = flr(self.y)
	for x=cx-1,cx+1 do
	for y=cy-1,cy+1 do
		if(x>0 and x<mapw and y>0 and y<maph and not tileissolid(getmap(x,y))) then
			capture[x+y*mapw] = 1+player.ind
		end
	end
	end
	self:place()
	sound(7)
	
	screen_shake += 30;
end

function bomb:tint()
	local c = flr(30*game_t)%15 + 1
	pal(11,c)
end

-- logic

function updatepoints()
	points.total = 0
	points.player1 = 0
	points.player2 = 0
	points.empty = 0
	for i=0,mapw*maph-1 do
		if (capture[i] >= 0) then points.total += 1 end
		if (capture[i] == 0) then points.empty += 1 end
		if (capture[i] == 1) then points.player1 += 1 end
		if (capture[i] == 2) then points.player2 += 1 end
	end
end


function _init()
	cls(0)

	--stars
	for i=1,64 do
		add(stars,{
			x=rnd(128),
			y=rnd(128)
		})
	end

	--fancy anim
	l1 = 130
	l2 = 0
	l3 = 130

	-- entities
	player1 = player:new({ind=0, dir=rnd(1)})
	player2 = player:new({ind=1, dir=rnd(1)})
	player1:place()
	player2:place()
	add(entities,player1)
	add(entities,player2)

	for i=1,1 do
		local b = bomb:new{}
		b:place()
		add(entities,b)
	end

	switch:place()
	add(entities,switch)

	-- capture array
	for x=0,mapw-1 do
	for y=0,maph-1 do
		local ind = x + mapw*y
		if (tileissolid(getmap(x,y))) then
			capture[ind] = -1
		else
			capture[ind] = 0
		end
	end
	end

	game_timer = game_time

	music_index = 0
	fade_in = -1
end

function _update()
	game_t += 1/30

	screen_shake = stepto(screen_shake,0,1);

	if (btnp(5,0)) then 
		music_on = not music_on 
		update_music()
	end

	if (state == "credits") then
		if (fade_in == -1 and fade_out < 0 and (game_t > 5 or btnp(4, 0) or btnp(4, 1)))  then 
			fade_out = 0
		end
		if (fade_out > 128) then
			state = "menu"
			fade_in = 0
			fade_out = -1
			update_music()
		end

		--fancy anim
		if (fade_out<0) then
			if l1>40 then l1=lerp(40,l1,0.9) end
			
			if abs(game_t-2)<(1/30) then sound(15) end

			if game_t>2 then
				if l2<26 then l2=lerp(26,l2,0.7) end
				if l3>82 then l3=lerp(82,l3,0.7) end
			end
		end

	elseif (state == "menu") then
		if (fade_in == -1 and fade_out < 0 and (btn(4,0) or btn(4,1))) then 
			fade_out = 0
			sound(12)
		end
		if (fade_out >= 128) then 
			state = "game"
			fade_out = -1
			fade_in = 0
		end

		--update stars
		for st in all(stars) do
			st.y+=(st.y-64)/10
			st.x+=(st.x-64)/10
			
			if (st.y>=128 or st.x>=128 or st.y<0 or st.x<0) then  -- out of bounds
				st.y=rnd(128)
				st.x=rnd(128)
			end
		end

	elseif (state == "game") then
		
		if (win_timer>=0) then 
			win_timer+=1/30
		else
			game_timer = stepto(game_timer,0,1/30)
		end

		for e in all(entities) do
			e:preupdate()
		end
		for e in all(entities) do
			e:update()
		end
		for e in all(entities) do
			e:levelcollisions()
		end

		local newentities = {}
		for e in all(entities) do
			if (not e.remove) add(newentities,e)
		end
		entities = newentities
		
		updatepoints()

		if (win_timer<0) then
			if (points.player1/points.total > threshold or points.player2/points.total > threshold) then 
				music_index = -1
				update_music()
				sound(8)
				win_timer=0 
			end
		end
	end
end

local menu_bck = {}
menu_bck.t = 0

function drawnames(y)
	center_text("by 16 shades of pico:",y,7); y+=10
	center_text("catarina vieira",y,7); y+=7
	center_text("francisco murias",y,7); y+=7
	center_text("luis reis",y,7); y+=7
	center_text("nina bellini",y,7)
end

function _draw()
	if(screen_shake > 0) then
		local v = 5 * (screen_shake/30)
		camera(flr(v-rnd(2*v)+0.5),flr(v-rnd(2*v)+0.5))
	else
		camera(0,0)
	end


	if (state == "credits") then
		if (fade_out<0) then
			clsd(0,0,900)

			local s = sin(game_t)
			if game_t<2 then
				sspr(96,64,32,32,l1-16*s,42,32*s,32)
			else
				if game_t<2.5 then

					sspr(96,64,32,32,40-16*s,42,32*s,32)
					sspr(72,32,56,32,40,l2)
					drawnames(l3)
				else
					sspr(96,64,32,32,40-16*s,42,32*s,32) 		
					sspr(72,32,56,32,40,26)
					drawnames(82)
				end
			end
			
		else
			clsd(0,0,900)				
		end
	elseif (state == "menu") then
		if (fade_out<0) then
			cls(1)	

			local color = 7
			if (true) then
				if (flr(5*game_t)%2==0) then color = colors.map_player1
				else color = colors.map_player2 end
			end

			--stars			
			for st in all(stars) do
  				pset(st.x, st.y, color)
 			end

			-- lines
			local n,w,c = 16,127,60
			local cy = cos(game_t/3)
			local cfy = sin(game_t/3)		

			
			for i=0,n-1 do
				local z = i*n+(0*game_t)%n
				local y = 16*w/z-7
				--if (y < 0) then y = 1000 end
				y = min(y,128-c)*cy + c
				--print(flr(y),1,9+7*i,7)
				line(0,y,w,y,color)
				
				local v=i-(50*game_t)%n/n-n/2
				line(-v*9+64,c,-v*60+64,(128-c)*cy+c, color)
			end
			line(0,c,w,c,color)
			
			--title
			pal(11,7)
			pal(8,7)
			local ds = 0.1
			local s = 1+ds/2+ds*sin(game_t)
			sspr(0*8,8*8, 12*8,4*8, (64-6*8*s),20,(12*8)*s,4*8*s)
			pal()
			--text	
			if (game_t%0.5<0.25) then	
				center_text("press \142 to start",90,7)
			end
			print("\151 toggle \141",128-48,128-6,music_on and 7 or 5)			
		end
		
	elseif (state == "game") then
		cls(0)
		local i

		if (player1.powerup) then
			pal(2,8)
			pal(13,14)
		end		
		i = flr(-64/player1.fov*player1.dir*360)%128
		sspr(0,96, 128-i,32,	i,0, 	128-i,32)
		sspr(128-i,96, i,32,	0,0, 		i,32)
		pal()
		if (player2.powerup) then
			pal(2,3)
			pal(13,11)
		end
		i = flr(-64/player2.fov*player2.dir*360)%128
		sspr(0,96, 128-i,32,	i,64, 	128-i,32)
		sspr(128-i,96, i,32,	0,64, 		i,32)
		pal()

		player1:setv_camera(v_camera)	
		draw3d()

		player2:setv_camera(v_camera)
		draw3d()

		rect(0,62,127,63,colors.map_player1)
		rect(0,64,127,65,colors.map_player2)
		rectfill(31, 56, 31+16, 56+5, colors.map_player1)
		rectfill(80, 66, 80+16, 66+5, colors.map_player2)
		
		local points1 = min(flr(100 * (points.player1 / points.total / threshold)),100)
		local points2 = min(flr(100 * (points.player2 / points.total / threshold)),100)
		center_text(points1..'%', 57, 7,  40)
		center_text(points2..'%', 66, 7,  89)
		cursor(0,0)

		drawmap()

		local t = game_timer>0 and flr(game_timer+1) or 0
		local s = (t%60)
		if (s < 10) then s = '0'..s end
		center_text(flr(t/60)..':'..s, 1, 7)

		pal(9,7)
		if (win_timer>0.5) then
			local d = min(win_timer-0.5,0.5)/0.5
			rectfill(0,33-d*9,127,33+d*9,colors.map_player1)
			rectfill(0,97-d*9,127,97+d*9,colors.map_player2)
		end
		if (win_timer>1) then
			local d = 1-min(win_timer-1,0.25)/0.25
			if (points1<points2) then
				sspr(0,32,9*8,16, 64-9*4 + 128*d,32-8+1)
				sspr(0,48,9*8,16, 64-9*4 - 128*d,96-8+1)
			else
				sspr(0,48,9*8,16, 64-9*4 + 128*d,32-8+1)
				sspr(0,32,9*8,16, 64-9*4 - 128*d,96-8+1)
			end
		end
		pal()		
	end

	if (fade_out>=0) then
		local i = flr(fade_out/2)
		rectfill(0,i,127,i+5,0)
		rectfill(0,127-i,127,127-i-5,0)
		fade_out+=6
	end
	
	if (fade_in>=0) then
		local i = flr(fade_in/2)
		rectfill(0,0,127,64-i,0)
		rectfill(127,64+i,0,127,0)
		
		fade_in+=10
		if (fade_in>=128) then fade_in=-1 end
	end

	--print(stat(1),1,1,7)
end


function drawmap()
	local d = win_timer>0 and (min(win_timer,0.5)/0.5) or 0
	if (d == 1) then return end
	local size = (1-d)*(mapw * 2)
	local csize = size / mapw
	local size = mapw * csize
	local ox,oy = 64-size/2,64-size/2
	local p1x = flr(size-player1.x*csize) + ox
	local p1y = flr(player1.y*csize) + oy
	local p2x = flr(size-player2.x*csize) + ox
	local p2y = flr(player2.y*csize) + oy
	for ix=0,mapw-1 do
		for iy=0,maph-1 do
			local c,i = 0, capture[(mapw-1-ix)+iy*mapw]
			if (i < 0) then
			 	c = colors.map_wall
			elseif (i == 0) then
				c = colors.map_floor
			elseif (i == 1)  then
				c = colors.map_player1
			elseif (i == 2)  then
				c = colors.map_player2
			end
			--if ((ix+iy)%2 == 0) then c = 1 else c = 2 end

			local x = ix*csize + ox
			local y = iy*csize + oy
			rectfill(x,y,x+csize-1,y+csize-1,c)
		end
	end
	--line(p1x,p1y,p1x-4*player1.dirx,p1y+4*player1.diry,12)
	--line(p2x,p2y,p2x-4*player2.dirx,p2y+4*player2.diry,12)
	if (csize>0.5) then
	circfill(p1x,p1y,1,7)
	pset(p1x,p1y,colors.map_player1)
	circfill(p2x,p2y,1,7)
	pset(p2x,p2y,colors.map_player2)

	local c = flr(30*game_t)%15 + 1
	local pux = size-flr(switch.x+1)*csize + ox
	local puy = flr(switch.y)*csize + oy
	rectfill(pux,puy,pux+1,puy+1,c)
	end


end

function draw3d()
	local stop = screenoy
	local svmid = screenoy+ flr(screenh/2)
	local sbottom = screenoy+screenh
	local sleft = screenox
	local sright = screenox+screenw

	for i=0,flr(screenh/2)-1 do
		floordist[i] = abs((1-v_camera.z) / ((i - flr(screenh/2))/v_camera.planeheight))
	end
	for i=flr(screenh/2),screenh-1 do
		floordist[i] = abs(v_camera.z / ((i - flr(screenh/2))/v_camera.planeheight))
	end

	clip(sleft,stop,sright,sbottom)

	-- level render
	for x=0,127 do
		-- raycasting
		local v_camerax = 2*x/128 -1
		local rayposx = v_camera.x
		local rayposy = v_camera.y
		local raydirx = v_camera.dirx + v_camera.planex * v_camerax;
		local raydiry = v_camera.diry + v_camera.planey * v_camerax;
		
		local mapx = flr(rayposx)
		local mapy = flr(rayposy)

		local sidedistx = nil
		local sidedisty = nil		
		local deltadistx = sqrt(1 + (raydiry * raydiry) / (raydirx * raydirx))
		local deltadisty = sqrt(1 + (raydirx * raydirx) / (raydiry * raydiry))
		if (deltadistx < 0) then deltadistx = 1000 end
		if (deltadisty < 0) then deltadisty = 1000 end
	
		local stepx=nil
		local stepy=nil
		local hit= false
		local side=nil

		if (raydirx < 0) then
			stepx = -1
			sidedistx = (rayposx - mapx) * deltadistx
		else
			stepx = 1
			sidedistx = (mapx + 1.0 - rayposx) * deltadistx
		end
		if (raydiry < 0) then
			stepy = -1
			sidedisty = (rayposy - mapy) * deltadisty
		else
			stepy = 1
			sidedisty = (mapy + 1.0 - rayposy) * deltadisty
		end
		
		while(not hit) do
			if (sidedistx < sidedisty) then
				sidedistx += deltadistx
				mapx += stepx
				side = false
			else
				sidedisty += deltadisty
				mapy += stepy
				side = true
			end

			if (mapx<0 or mapx>=mapw or mapy<0 or mapy>=maph) then break end
			if (getmap(mapx,mapy)==2) then hit = true end
		end

		if (hit) then		
			-- calculate distance
			if (not side) then
				zbuffer[x] = (mapx - rayposx + (1 - stepx) / 2) / raydirx
				wallx = rayposy + zbuffer[x] * raydiry
			else           
				zbuffer[x] = (mapy - rayposy + (1 - stepy) / 2) / raydiry 
				wallx = rayposx + zbuffer[x] * raydirx
			end
			if (zbuffer[x] < 0) then zbuffer[x] = 10000 end


			-- wall render
			local d = zbuffer[x]
			local h = flr(v_camera.planeheight / d)
			local l = flr(h * v_camera.z)
			local bottom = svmid + l
			local top = bottom - h
			wallx -= flr(wallx)
			
			if (dither(d,x)) then		
				--if (v_camera.wallstate > 0) then
					local sprx = wall_spr[v_camera.wallstate].x
					local spry = wall_spr[v_camera.wallstate].y
					if(v_camera.wallstate > 0) then
						if ((mapx+mapy)%2==0) then
							if (game_t % 0.5 < 0.25) spry += 8
						else
							if (game_t % 0.5 > 0.25) spry += 8
						end		
					end

					texx = flr(wallx * 8)
					if (not side and raydirx > 0) then texx = 8-texx-1 end
					if (side and raydiry < 0) then texx = 8-texx-1 end					
					
					if (h>8) then
						local ya = top
						local inc = (h+1)*0.125
						local yb = ya+inc
						local color
						for yi=0,7 do
							if (ya >= sbottom) then break end
							if (max(ya,stop) < max(yb,stop)) then
								color = sget(sprx+flr(texx),spry+yi)
								line(x,max(ya,stop),x,min(yb-1,sbottom),color)
							end
							ya = yb
							yb += inc
						end
					else
						for y=top,top+h-1 do
							local color = sget(sprx+flr(texx),spry+y-top)
							pset(x,y,color)
						end
					end
				--[[else
					local color = 0
					if (side) then color = 5 else color = 6 end
					line(x,max(top,stop),x,min(bottom,sbottom),color)
				end]]--
			else
				line(x,max(top,stop),x,min(bottom,sbottom),0)
			end

			--floor render
			local startf = min(bottom+1,sbottom-1)
			local endf = sbottom-1
			if (v_camera.drawfloor and startf<sbottom) then
				for y=startf,endf do
					if ((x + 2*y) % 6 == 0) then
						local d = floordist[y-screenoy]		
						local fx = v_camera.x + raydirx * d
						local fy = v_camera.y + raydiry * d
						local i, color
						if (fx < 0 or fx >= mapw or fy < 0 or fy >= maph) then
							i = 0
						else
							i = capture[flr(fx)+flr(fy)*mapw]
						end
						
						fx -= flr(fx)
						fy -= flr(fy)				
						
						if (i == 1) then color = colors.map_player1 else color = colors.map_player2 end

						if (i > 0) then -- and (fx < 0.05 or fx > 0.95 or fy < 0.05 or fy > 0.95)) then
							pset(x,y,color)
						end
					end	
				end
			end

			--floor and sky
			--if (max(top,stop)>stop+1) then line(x,stop,x,top-1,12) end
			--if (min(bottom,sbottom)<sbottom-1) then line(x,bottom,x,sbottom-1,4) end
		end
	end

	-- beacon
	if(v_camera.wallstate == 0) then
		local sprx = switch.x - v_camera.x
		local spry = switch.y - v_camera.y
		local invdet = 1 / (v_camera.planex*v_camera.diry - v_camera.dirx*v_camera.planey)
		local transx = invdet * (v_camera.diry*sprx - v_camera.dirx*spry)
		local transy = invdet * (-v_camera.planey*sprx + v_camera.planex*spry)
		local dscreenx = flr(64 * (1 + transx/transy))-1

		local c = 1+flr(rnd(30*game_t))%15
		if (transy > 0.2 and dscreenx>=0 and dscreenx<128) then
			local w = max(1,abs(flr(v_camera.planeheight / transy)) * 2 / 16)
			for i=flr(-w/2),flr(w/2) do
				local x = dscreenx-i
				if (x>=0 and x<128) then
					local d = zbuffer[x]
					local bbottom
					if (d > transy) then 
						local h = flr(v_camera.planeheight / transy)
						bbottom = svmid + flr(h * v_camera.z)
					else
						local h = flr(v_camera.planeheight / d)
						bbottom = svmid + flr(h * v_camera.z) - h - 1 
					end	
					if (bbottom >= stop) then line(x,stop,x,min(bbottom,sbottom),c) end
				end
			end

			pal(7,c)
			if (stop == 0) then	spr(38,dscreenx-3,stop)
			else spr(41,dscreenx-3,sbottom-7) end
			pal()
		elseif (angledifference(v_camera.dir,atan2(sprx,spry)) > 0) then
			pal(7,c)
			spr(40,sleft-3,svmid)
			pal()
		else
			pal(7,c)
			spr(39,sright-5,svmid)
			pal()
		end
	end

	--sprite render
	
	for e in all(entities) do 
		if (not e.visible or (e.type=="bomb" and v_camera.wallstate==0) or (e.type=="particle" and v_camera.wallstate!=0)) then
			e.dist = -1
		else
			e.dist = sqrdist(e.x,e.y,v_camera.x,v_camera.y) 
		end
	end
	
	qsort(entities, function(a,b) return a.dist > b.dist end)
	
	
	for e in all(entities) do
		if (e.dist > 0 and e.dist < 25) then
			local sprx = e.x - v_camera.x
			local spry = e.y - v_camera.y
			local invdet = 1 / (v_camera.planex*v_camera.diry - v_camera.dirx*v_camera.planey)
			local transx = invdet * (v_camera.diry*sprx - v_camera.dirx*spry)
			local transy = invdet * (-v_camera.planey*sprx + v_camera.planex*spry)
			--local vmovescreen = flr(e.z / transy)

			local l = flr(screenoy+screenh/2+(v_camera.planeheight / transy / 2 * v_camera.z))
			local sprscreenx = flr(64 * (1 + transx/transy))
			local sprsize = abs(flr(v_camera.planeheight / transy))
			local sprwidth = sprsize * e.w / 16
			local sprheight = sprsize * e.h / 16
			local xstart = flr(-sprwidth/2 + sprscreenx)
			local xend = flr(sprwidth/2 + sprscreenx)
			local ystart = flr(-sprheight/2 + svmid+sprsize*(v_camera.z-e.z))
			local yend = flr(sprheight/2 + svmid+sprsize*(v_camera.z-e.z))

			e:tint()
			
			if (e.wallocclusion) then
				for stripe=max(xstart,sleft),min(xend-1,sright-1) do
					if (transy > 0.2 and transy < zbuffer[stripe] and dither(transy/2, stripe)) then
						local texx = flr((stripe - xstart) * e.sprw / sprwidth)
						local ya = ystart
						local inc = (yend-ystart)/e.sprh
						local yb = ya+inc


						--line(stripe,max(ystart,stop),stripe,min(yend,sbottom),12)				
						for yi=0,e.sprh-1 do
							if (ya >= sbottom) then break end
							if (max(ya,0) < yb) then
								local color = sget(e.sprx+texx,e.spry+yi)
								if (color != 0) then line(stripe,max(flr(ya),stop),stripe,min(flr(yb),sbottom),color) end
							end
							ya = yb
							yb += inc
						end
						
						
					end
				end
			elseif(transy>0.2 and sprscreenx>=0 and sprscreenx<sright and transy<zbuffer[sprscreenx]) then
				--line(xstart,ystart,xend,yend,12)
				sspr(e.sprx,e.spry,e.sprw,e.sprh, xstart,ystart,sprwidth,sprheight)				
			end
			pal()			
		end
	end

	clip()
end


--util

function dither(d,x)
	if (d < 2) return true;
	if (d < 3) return x % 2 == 0;
	if (d < 4) return x % 3 == 0;
	if (d < 5) return x % 4 == 0;
	return false;
end

function sqrdist(x1,y1,x2,y2)
	return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end

function qsort(t, cmp, i, j)
	i = i or 1
	j = j or #t
	if i < j then
		local p = i
		for k = i, j - 1 do
			if cmp(t[k], t[j]) then
				t[p], t[k] = t[k], t[p]
				p = p + 1
			end
		end
		t[p], t[j] = t[j], t[p]
		qsort(t, cmp, i, p - 1)
		qsort(t, cmp, p + 1, j)  
	end
end

function stepto(a,b,x)
	local d = abs(b-a)
	if (d<x) then return b end
	return a + x*sgn(b-a)
end

function tileissolid(t)
	if (t==2) then return true end
	return false
end

function getmap(x,y)
	return mget(mapw-1-x,y)
end

function center_text(s,y,c,x) print(s,(x or 64)-(#s*2),y,c) end

function angledifference(a,b)
	a %= 1; b %= 1
    local phi = abs(b - a) % 1;
    local diff = phi > 0.5 and 1 - phi or phi;
        
    if ((a - b >= 0 and a - b <= 0.5) or (a - b <=-0.5 and a- b>= -1)) then return diff
	else return -diff end 
end

function lerp(tgt,pos,rate)
 return (1-rate)*tgt + rate*pos
end

function clsd(a,b,v)
	for i=1,v do
		circfill(rnd(128),rnd(128),1,a)
		circ(rnd(128),rnd(128),1,b)
	end
end
__gfx__
0000000066666666555555557666666100667700006677000002200020022002300330030e00002000ffb3000e00002000ffb3003c3c3c700888888000777700
0000000066666666555555556dddddd5066777700667777000e822000288882003bbbb300e2008200fbbbb300e2008200fbbbb30c3c3c3c78888888807777770
0070070066666666555555556d5555d502288820033bbb300e888220082222800b3333b0e88888820bb33b30e88888820bb33b303c773c372222222203333330
0007700066666666555555556d5dd5d502288820033bbb3087770662282e82823b3fb3b3e58888520b5bb530e58888520b5bb530c37073c72e822e8206b336b0
0007700066666666555555556d5dd5d502288820033bbb3087700662282882823b3bb3b3e8588582bbbb3b3be8588582bbbb3b3b3c707c37288228820bb33bb0
0070070066666666555555556d5555d502288820033bbb3008776620082222800b3333b0e8888882b0bbbb0be8888882b0bbbb0bc377c3c72222222203333330
0000000066666666555555556dddddd502288820033bbb30008662000288882003bbbb300888882000bb0b000888882000bb0b003c3c3c370888888007777770
0000000066666666555555551555555002288820033bbb300002200020022002300330030080080000b00b000080080000b00b00c3c3c3700088880000777700
0e00002000ffb30000000000bbbbbbbb02288820033bbb300008200000022000000000000200200003000300020002000300300003c3c7000888888007777770
0e2008200fbbbb3000000000bb0000bb0222222003333330008002000088880002000020080008000b000b00080008000b000b000c3c3c708088880870777707
e88888820bb33b3000000000b000000b0667777006677770080000200822228000022000080008000b0000b0080000800b000b0003c7c3708088880870777707
e08888020b0bb03000000000b000000b066777700667777080088002282e8282002e8200800000800b0000b008000080b00000b00c703c708022220870333307
e8088082bbbb3b3b00000000b000000b00667700006677008008800228288282002882008000000800b000b000800080b000000b0370c3700888888000777700
e8888882b0bbbb0b00000000b000000b00067000000670000800002008222280000220008000000800b00b0000800800b000000b0c373c700080080000700700
0888882000bb0b0000000000bb0000bb00088000000bb00000800200008888000200002080080008b0b00b0b80800808b00b000b03c3c3700080080000700700
0080080000b00b0000000000bbbbbbbb00088000000bb000000220000002200000000000088008800b0000b0080000800bb00bb00c3c37000080080077700777
00d00d000d00d00000000000888888887ffffff17ffffff177777777770000000000007700000000000098000000000000000000000770000000000000000000
00d00d000d000d000000000088000088f8888882fbbbbbb377777777777000000000077700000000000900000000000000000000000770000000000000000000
00d000d00d000d000000000080000008f8222282fb3333b307777770777700000000777700000000007bb7000000000000000000000770000000000000000000
0d0000d000d000d00000000080000008f8288282fb3bb3b3007777007777700000077777000770000bbbbb700000000000000000000770000000000000000000
00d000d000d0000d0000000080000008f8288282fb3bb3b300077000777770000007777700777700b7bbbbb70000000000000000000770000000000000000000
00d00d000d00000d0000000080000008f8222282fb3333b300000000777700000000777707777770bbbbbbb70000000000000000000770000000000000000000
d0d00d0dd00d000d0000000088000088f8888882fbbbbbb300000000777000000000077777777777bbbbbbb70000000000000000000770000000000000000000
0d0000d00dd00dd000000000888888881222222113333331000000007700000000000077777777760bbbbb700000000000000000000dd0000000000000000000
000000000000000000000000000000007ffffff17ffffff100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f8888882fbbbbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f8222282fb3333b300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f8277282fb3773b300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f8277282fb3773b300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f8222282fb3333b300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f8888882fbbbbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000122222211333333100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000007777777700777777777077777777777077777777000077777700000
00000077777700000777777700777777770077777770077777777077777777700077700007777777770777777777177777777777177777777700777777770000
00000077777770000777777700777777770077777770077777777077777777700077700007777777770777777777177777777777177777777700777777770000
00000077666770007776666607776666660777666660777666777066677766600777600007771117771777111111101117771111177711177717777117777000
00000777000770007770000007770000000777000000777000776000077700000777000007771007771777100000000007771000077700077717771111777000
00000776007770077760000077760000007776000007776007770000777600007776000007777777771777777770000007771000077777777717771100777100
00007770007770077777700077777700007777770007770007770000777000007770000007777777711777777771000007771000077777777117771000777100
00007770077760777777700777777700077777770077777777760007776000077760000007777777711777111111000007771000077777777117771000777100
00007760077700777666600777666600077766660077777777700007770000077700000007771117770777100000000007771000077711177707777007777100
00077700777607777000007776000000777700000777766777600077760000066600000007771007770777777777000007771000077710077700777777771100
00077600777007776000007770000000777600000777700777000077700000000000000007771007771777777777000007771000077710077710777777771100
00077777776007777777007760000000777777700777607776000077600007770000000007771007771777777777100007771000077710077710077777711000
00077777760007777777007700000000777777700777007770000077000007770000000000111000111011111111100000111000001110001110011111111000
00066666600006666666006600000000666666600666006660000066000006660000000000111000111011111111100000111000001110001110001111110000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000777700000777000000777000
07700007770077000777777707777777770077777777000777777700007770007770077700000000000000000000000077710007777770000777700007777100
07700007770077000777777707777777770077777777000777777770007770007770077700000000000000000000000077710007777770000777770077777100
07700077760777007776666606667776660777666777007776667770077760077760777600000000000000000000000077710077711777000777777777777100
07700077700777007770000000007770000777000777007770007770077700077700777000000000000000000000000077710077711777000777777777777100
07700777607776077760000000077760007776007776077760077760777600777607776000000000000000000000000077710777110077700777177771777100
07700777007770077700000000077700007770007770077700077700777000777007770000000000000000007770000077710777110077700777107711777100
07707776077760777600000000777600077760077760777777777607777777776077760000000000000000007770000077710777777777700777100111777100
07707770077700777000000000777000077700077700777777777007777777770077700000000000000000000777000777717777777777770777100110777100
07777760777607776000000007776000777600777607776667766006666667760066600000000000000000000777777777117771111117771777100000777100
07777700777007770000000007770000777000777007770007770000000077700000000000000000000000000077777771117771111117771777100000777100
07777600776007777777000007760000777777776007760006770077777777607770000000000000000000000017777711107771000007771777100000777100
07777000770007777777000007700000777777770007700000770077777777007770000000000000000000000001111111000111000000111001100000011100
06666000660006666666000006600000666666660006600000660066666666006660000000000000000000000000111110000111000000111001100000011100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777700000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777000000000000
00088888888880000088888888880008888000000008888000000008888888000000008888800088880000008888800000000000007777777777770000000000
00088888888888000888888888888008888800000088888000000008888888000000008888800088888000008888800000000000777777777777777700000000
00088888888888800888888888888008888880000888888000000088888888800000008888800088888800008888800000000077777777111177777777000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777777711000011777777770000
00088888000888800888800008888008888880000888888000000888888888880000008888800088888880008888800000777777771100000000117777777700
00088888000888800888800008888008888888008888888000000888888888880000008888800088888888008888800007777777110000000000001177777770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777711000000088000000011777770
000888880008888008888000088880088888008800888880000088888888888880000088888000888888888888888000077711000000008e8800000000117770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007770000000000888800000000007770
00088888000888800888800008888008888800000088888000088888800088888800008888800088888000888888800007770000000000088000000000007770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007770000000000055000000000007770
00088888888888800888888888888008888800000088888000888888000008888880008888800088888000008888800007770000000008855880000000007770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007770000000888855888800000007770
00088888888888000088888888880008888800000088888008888880000000888888008888800088888000008888800007770000088888855888888000007770
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000bb8888888888cc000007770
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000bbbb888888cccc000007770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007770000011bbbb88cccc11000007770
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777000000011bbbccc1100000007770
000000000000000007770000077770000077007700007777700007700000077000000077700077770000000000000000077700000000011bc110000000007770
00000000000000077777000007777000007770770000777770000770000007700000777770007777000000000000000007770000000000011000000000007770
00000000000000077000000070000700007077770000700000000770000007700000770000000770000000000000000007777700000000000000000000777770
00000000000000077000000070000700007007770000777000000770000007700000770000000770000000000000000007777777000000000000000077777770
00000000000000007777000007777000007000770000700000000777700007700000077770000770000000000000000001777777770000000000007777777710
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000117777777700000000777777771100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001177777777000077777777110000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011777777777777777711000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000117777777777771100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001177777777110000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011777711000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111100000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
02000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
20020002000200022222220200020002222222020002000220020002000200022222220200020002222222020002000220020002000200022222220200020002
22222222202020202222222220202020222222222020202022222222202020202222222220202020222222222020202022222222202020202222222220202020
20202222220002222222222222222222222222222222222220202222220002222222222222222222222222222222222220202222220002222222222222222222
22000222222022222222222222222222222222222222222222000222222022222222222222222222222222222222222222000222222022222222222222222222
22202222222222222222222222222222222222222222220222202222222222222222222222222222222222222222220222202222222222222222222222222222
2d2d2d2d222222222d2d2d2d222222222d2d2d2d222222222d2d2d2d222222222d2d2d2d222222222d2d2d2d222222222d2d2d2d222222222d2d2d2d22222222
d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2
2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d
d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2ddddd2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010201010101010201010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202010202020202020101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010101010201010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010101010202010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202010201010101010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010201010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010201010102020201020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202010202020201010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010102020102020101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010102010101020101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010f00000a0540a0500a0500a0500a0500a0550002400020000200003000030000300003000030000300003000030000300003000020000200002000010000500005000050000500005000050000500005000050
010f00002d0242d0202d0202d0202d0202d025000000000000000000002a0342a0302a0302a0302a0302a0302a0302a0302a0350000000000000000000028024280202a0242a0202a7302a7302a7302a73400000
012e00002d0142d0102d0102d0102d0102d0102d0102d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001872018720187201872518714000000000000000000000000000000280242a0222a0202a0202a0202a0202a0250000000000000000000000000047100971028714287102871028715000001b7501b750
010f00003b7503b7503b7503b7503b7503b75000000000000000000000257212572534722367223b7243b7253b7243b7223b7223b725000000000000000000000000000000000000000000000000000000000000
011000001b7501b7501b7501b7501b7501b7501b75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000050080400c0401004015040160451b044170401d050110501c0501b0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003b67036670316702d6702a6702667022570090701c6701a67018670156701367011570160700d6700b6700967008670075701c0700667004670045702307002670026700257026070016700257000070
0008000024070240702407022070220701f0701f0701f07022070220701f0701f0701f07022070220701f0701f0701f0702407024070240700007018070180701807000070000700007000070000700007000070
011900000007500071000750007100075000710007500071000750007500075000750007500075000750007500075000710007500071000750007100075000710007500075000750007500075000750007500075
011600000000000000000000000000000000000000000000000000000000050080400c0401004015040160451b050170501d050110501c0501b05000000000000000000000000000000000000000000000000000
011600000000000000000000000000000000000000000000000000000000000130500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000107004070070700a0700a2700f0701207015270180701a0601f0601e270252602c060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001900000c0650c0610c0650c0610c0650c0610c0650c0610c0650c0650c0650c0650c0650c0650c0650c0650c0650c0610c0650c0610c0650c0610c0650c0610c0650c0650c0650c0650c0650c0650c0650c065
001900001806518061180651806118065180611806518061180651806518065180651806518065180651806518065180611806518061180651806118065180611806518065180651806518065180651806518065
010700001a07021160260702616026060261502605026140260402613026020261202601026110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c3301333017340193401a3401d350203501f3501c340163300f33009320223201f3501c3501b34025330213501e3501b35023440254302745029450294502745025440224301e4301a4201642000000
010900000c1320c1320c1320c1320c13218352183521835218352183520c1320c1320c1320c1320c13218352183521835218352183520a1320a1320a1320a1320a13216352163521635216352163520a1320a132
010900000c073000000000000000000000c073000002460000000246000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c07300000
010900003c2150000000000000003c2153c2353c2153c2150000000000000003c2153c2353c2150000000000000003c2153c2353c215000000000000000000003c2153c2353c2153c2150000000000000003c215
010900002415024150000000000000000241702417000100001000000024150241500000000000000002417024170000000000000000221502215000000000000000022170221700000000000000002413024130
000900000a1320a1320a13216352163521635216352163520c1320c1320c1320c1320c13218352183521835218352183520c1320c1320c1320c1320c13218352183521835218352183520f1320f1320f1320f132
010900000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000
000900000000000000000003c215000000000000000000003c2150000000000000003c2153c2353c2153c2150000000000000003c2153c2353c2150000000000000003c2153c2353c21500000000000000000000
010900002413027140271402915029150291602b1602b130000000000000000241502415000000000000000000000000002417024170001000010000000241502415000000000000000027170271700000000000
000900000f1321b3521b3521b3521113211132111321113212142121421215212162121621113211132111320c1320c1320c1320c1320c13218352183521835218352183520c1320c1320c1320c1320c13218352
01090000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073
000900003c2153c2353c2153c2150000000000000003c2150000000000000003c215000000000000000000003c2150000000000000003c2153c2353c2153c2150000000000000003c2153c2353c2150000000000
0009000000000271702717000000291322913229132291322a1422a1422a1522a1622a16229132291322913224150241500000000000000002417024170001000010000000241502415000000000000000024170
00090000183521835218352183520a1320a1320a1320a1320a13216352163521635216352163520a1520a1320a1320a1320a13216352163521635216352163520c1320c1320c1320c1320c132183521835218352
00090000000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c0730000000000
00090000000003c2153c2353c2153c2150000000000000003c2153c2353c2153c2150000000000000003c2153c2353c2150000000000000003c2153c2353c215000000000000000000003c2153c2353c2153c215
00090000241700000000000000002215022150000000000000000221702217000000000000000024130241302413027140271402915029150291602b1602b1300000000000000002417024170000000000000000
0009000018352183520c1320c1320c1320c1320c13218352183521835218352183520f1320f1320f1320f1320f1321b3521b3521b352121321213212132121321114211142111521116211162121321213212132
0009000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c073000000000000000000000c07300000000000000000000
010900000000000000000003c2150000000000000003c215000000000000000000003c2150000000000000003c2153c2353c2153c2150000000000000003c2153c2353c2150000000000000003c2153c2353c215
0009000000000000002417024170001000010000000241702417000000000000000027170271700000000000000002717027170000002a1322a1322a1322a13229142291422915229162291622a1322a1322a132
0109000016132161321613216132161322235222352223522235222352161321613216132161321613222352223522235222352223520e1320e1320e1320e1320e1321a3521a3521a3521a3521a3520e1320e132
000900001607300000000000000000000160730000024600000002460016073000000000000000000001607300000000000000000000160730000000000000000000016073000000000000000000001607300000
010900000a045000000a041000000a045000000a041000000a045000000a0440a0400a045000000a000000000a000000000a00000000020450000002041000000204500000020410000002045000000204402040
000900002e1502e1500000000000000002e1702e1700010000100000002e1502e1500000000000000002e1702e170000000000024000261502615000000000002400026170261700000000000000002e1302e130
000900000e1320e1320e1321a3521a3521a3521a3521a352161321613216132161321613222352223522235222352223521613216132161321613216132223522235222352223522235215132151321513215132
000900000000000000000001607300000000000000000000160730000000000000000000016073000000000000000000001607300000000000000000000160730000000000000000000016073000000000000000
0009000002045000000000000000000000000000000000000a045000000a041000000a045000000a041000000a045000000a0440a0400a045000000a000000000a000000000a0000000009045000000904100000
000900002e1302d1402d14027150271502716029160291300000000000000002e1502e15000000000000000000000000002e1702e1700010000100000002e1502e1500000000000000002d1702d1700000000000
00090000151322135221352213520f1320f1320f1320f1320c1420c1420c1520c1620c1620f1320f1320f13216132161321613216132161322235222352223522235222352161321613216132161321613222352
000900000000016073000000000016003000000000000000160730000000000000000000016073000000000016003000000000000000000001607300000000000000000000160730000000000000000000016073
0009000009045000000904500000030440304003045000000a045000000a041000000a045000000a041000000a045000000a041000000a045000000a041000000a045000000a0440a0400a045000000a00000000
00090000000002d1502d150000002713227132271322713224142241422415224162241622713227132271322e1402e1400000000000000002e1602e1600010000100000002e1302e1300000000000000002e160
00090000223522235222352223520e1320e1320e1320e1320e1321a3521a3521a3521a3521a3520e1520e1320e1320e1320e1321a3521a3521a3521a3521a3521613216132161321613216132223522235222352
000900000000000000000000000016073000000000000000000001607300000000000000000000160730000000000000000000016073000000000000000000001607300000000000000000000160730000000000
000900000000000000000000000002045000000204100000020450000002041000000204500000020440204002045000000000000000000000000000000000000a045000000a041000000a045000000a04100000
000900002e170000000000000000261502615000000000002400026170261700000000000000002e1302e1302e1302d1402d14027150271502716029160290500000000000000002e1502e150000000000000000
0009000022352223521613216132161321613216132223522235222352223522235215132151321513215132151322135221352213520c1320c1320c1320c1320f1420f1420f1520f1620f1620c1320c1320c132
0109000000000000000a073000000000000000000000a073000000000000000000000a073000000000000000000000a0730000000000000000000016073000000000000000000001607300000000000000000000
000900000000000000000000000000000000000000000000000000000000000000000904500000090410000009045000000904500000030440304003045000000a045000000a041000000a045000000a04100000
0009000000000000002e1702e1700010000100000002e1502e1500000000000000002d1702d1700000000000000002d1702d17000000241322413224132241322714227142271522716227162241322413224132
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00 01 03 04
00 01 02 05 44
00 41 42 43 44
00 41 42 43 44
03 09 0d 0e 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 06 07 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 13 42 43 44
01 14 15 16 17
00 18 19 1a 1b
00 1c 1d 1e 1f
00 20 21 22 23
02 24 25 26 27
01 28 29 2a 2b
00 2c 2d 2e 2f
00 30 31 32 33
00 34 35 36 37
02 38 39 3a 3b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
