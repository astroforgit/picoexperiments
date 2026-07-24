pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- bicycle race
-- super trump 2017 series

music(0)
carcol = {{1,13,12},{1,3,11},{8,14,15}}
frame = 0
md=1
mdx=0
mdy=17
level={
	{horzx=1,horzy=0,
		skyx=1,skyy=3,
		landx=0,landy=8,
		road=0, rubble=13,
		rbank=4,rwater=12, 
		tree=86, trunk=89},
	{horzx=17,horzy=0,
		skyx=17,skyy=3,
		landx=1, landy=8,
		road=3, rubble=14,
		rbank=12,rwater=1,
		tree=13, trunk=106},
	{horzx=33,horzy=0,
		skyx=17,skyy=3,
		landx=2, landy=8,
		road=0, rubble=15,
		rbank=4,rwater=12,
		tree=13, trunk=106}
}

fadepal = {
	{1,1,1,1,0,0,0,0,0},
	{2,2,2,1,1,1,0,0,0},
	{3,3,3,5,5,1,1,0,0},
	{4,4,2,2,2,1,0,0,0},
	{5,5,5,1,1,1,0,0,0},
	{6,6,6,5,5,1,1,0,0},
	{7,7,6,6,5,2,1,0,0},
	{8,8,8,4,4,2,1,0,0},
	{9,9,4,2,2,1,0,0,0},
	{10,10,10,14,14,8,2,0,0},
	{11,11,3,3,3,1,1,0,0},
	{12,12,13,2,2,1,0,0,0},
	{13,13,13,2,2,1,1,0,0},
	{14,14,8,8,2,1,1,0,0},
	{15,15,14,8,8,2,1,1,0}
}

groundpal = {
	nil,
	nil,
	nil,
	{9,9,9,4,4,2,2,1,0},
	nil,
	nil,
	nil,
	nil,
	{9, 9, 4, 4, 2,1,1,0,0},
	nil,
	nil,
	nil,
	nil,
	nil,
	{15,9, 4, 2,1,0,0,0,0}
}

horzpal = {
	nil,
	nil,
	nil,
	{ 4, 2, 2, 1, 1, 0, 0, 0,0},
	nil,
	nil,
	{7,7,15,15,15,6,6,6,6},
	nil,
	{ 9, 4, 4, 2, 2, 1, 0, 0,0},
	{10, 9, 9, 4, 4, 2, 1, 0,0},
}

sprpal = {
	nil,
	nil,
	nil,
	{ 4, 2, 2, 1, 1, 0, 0, 0,0},
	nil,
	nil,
	{7,7,6,6,5,2,1,0,0},
	nil,
	{ 9, 4, 4, 2, 2, 1, 0, 0,0},
	{10, 9, 9, 4, 4, 2, 1, 0,0},
}

function curve()
cls()
local x=10
local y=64

local a=0
for s in all(trackq) do
	for l=0,s.len,32 do
		line(x,y,x,y)
		x += cos(a)
		y -= sin(a)
		a += s.curve	
		end
end

stop()

end

function addscore(sc)
	score += sc
	while score >= 10000 do
		score -= 10000
		score2 += 1
	end
end

function updatebestscore()
	if score2 > bestscore2 or 
		(score2 == bestscore2 and
			score >= bestscore) then
			bestscore = score
			bestscore2 = score2
			
			dset(0, bestscore)
			dset(1, bestscore2)
	end
end

function setfade(x,gr)
 if x < 1 then
 	pal()
 	return
 end
 for p=1,15 do
 	if gr == 1 and groundpal[p] != nil then
 		pal(p,groundpal[p][flr(x)])
 	elseif gr == 2 and horzpal[p] != nil then
 		pal(p,horzpal[p][flr(x)])
 	elseif gr == 3 and sprpal[p] != nil then
 		pal(p,sprpal[p][flr(x)])
 	else
 		pal(p,fadepal[p][flr(x)])
		end 	
 end
end

function sqr(x)
	return x * x
end

function getroadz(y)
	return 2048/(y+1)
end

function drawcar(ox,y,z,turn,col,isplr)
 local x = ox + px
 local xb = x / 12 - turn / 2
 local s = flr(abs(xb))
 local f = false
 
 if xb < 0 then
  f = true
 end
 
 
 if s < 0 then
  s = 0
 end
 
 if s > 2 then
  s = 2
 end
 
 local zscl1 = 1 * 32 / (z + 32)
 local zscl2 = 1 * 32 / (z + 1 + 32)
 local zscl3 = 1 * 32 / (z + 2 + 32)
 local dy = 32 * 32 / (z + 32)
 local ody = flr(dy)
 if ody < 2 then
  ody = 2 
 elseif ody > 63 then
  ody = 63
 end
 local xoff = xoffs[ody]
 
 local sw = 24 * 24 / (z + 32)
 local sh = 8 * 24 / (z + 32)
 local sl = sh
 
 if sl < 4 then
	 sl = 4
 end


 if isplr and fade > 6 then
 	setfade(6,3)
 else
 setfade(fade,3)
 end 

 if col == 0 then
 	--mypal()
 else
 	local p = carcol[col]
 	if flr(fade) > 0 then
 	pal(4,fadepal[p[1]][flr(fade)])
 	pal(9,fadepal[p[2]][flr(fade)])
 	pal(10,fadepal[p[3]][flr(fade)])
 	else
 	pal(4,p[1])
 	pal(9,p[2])
 	pal(10,p[3])
 	end
 end
 
 local t = 0
 if isplr then
 	t = jump * 2
 end
 
 if sw < 24 then
 sspr(24, 32 + s*8, 24, 8, xoff+x*zscl3-sw/2+64+turn*zscl3, (y)*zscl3+64-sh-t, sw, sh, f, false)
	--sspr(24, 32 + s*8, 24, 8, xoff+x*zscl3-12+64+turn*zscl3, (y)*zscl3+64-8-t/2, 24*zscl3, 8*zscl3, f, false)
 sspr(0, 32 + s*8, 24, 8, xoff+x*zscl1-sw/2+64, (y)*zscl1+64-sh, sw, sh, f, false)
 pal()
 if fade > 7 then
 sspr(32, 32 + 3*8, 8, 8, xoff+x*zscl1+sh/3+64, (y)*zscl1+64-sh, sl, sl, f, false)
 sspr(32, 32 + 3*8, 8, 8, xoff+x*zscl1-sh+64, (y)*zscl1+64-sh, sl, sl, f, false)
 end
 
 else
	spr(64 + s*16 + 3, xoff+x*zscl3-12+64+turn*zscl3, (y)*zscl3+64-8-t, 3, 1, f, false)
	spr(70, xoff+x*zscl2-4+64+turn*zscl2*0.5, (y-2)*zscl2+64-8-t/2, 1, 1, f, false)
	spr(64 + s*16, xoff+x*zscl1-12+64, y*zscl1+64-8, 3, 1, f, false)
	pal()
 if fade > 7 then

	spr(116, xoff+x*zscl1+2+64, y*zscl1+64-8, 1, 1, f, false)
	spr(116, xoff+x*zscl1-8+64, y*zscl1+64-8, 1, 1, f, false)
	end
	
 end
 --pal()
end

function drawseg(y,curve,xm)
	local z=getroadz(y)
	local mip=0
	if z > 320 then
		mip=2
	elseif z > 160 then
		mip=1+y%2
	elseif z > 112 then
		mip=1
	elseif z > 64 then
		mip=0+y%2
	end
	
	if mip == 0 then
		mip = level[clev].road
	end
	
	
	local x=xm*64/(z+1)+curve/2
	local rw=80*64/(z+1)
	local w=8*64/(z+1)
	
	sspr(0+mip*16+8,(z/2+py)%8,8,1,64+x-rw/2-1,y+64,rw/2+2,1)
	sspr(0+mip*16+8,(z/2+py)%8,8,1,64+x,y+64,rw/2+1,1,true)
	
	sspr(0+mip*16,(z/2+py)%8,8,1,64+x-rw/2-w,y+64,w,1)
	sspr(0+mip*16,(z/2+py)%8,8,1,64+x+rw/2,y+64,w,1)
end

function addseg(len, curve,trigger)
	local seg = {curve=curve, len=len, trigger=trigger}
	add(track,seg)
end

function _init()
	cartdata("kb_picoracer")
	gamemode = 3
	bestscore = dget(0)
	bestscore2 = dget(1)
	initgame()
end

function initgame()
	md=1
	mdx=0
	mdy=17
	maptravel=0
	disttrav=0
	gotime = 0
	
	resetpos = false
	starttimer = 3 * 30
	clev = 1
	seg = 1
	score = 0
	score2 = 0
 pt = 0
 px = 0
	py = 0
	carsscr = 0
	horzmove = 0
 tzbase = 0
 tpos = 1
 horzx = 0
 track = {}

	rveryshort=64
	rshort=128
 rlong=256
 rverylong=512
 tight=0.02
 loose=0.01
 verytight=0.03
 
 -- egypt leg 1
 addseg(rshort,0)
 addseg(rshort,loose,{flags=3,flagdir=0})
 addseg(rshort,0)
 addseg(rlong,-loose,{flags=4,flagdir=1,cars=1})
 addseg(rshort,-tight,{cars=1})
 addseg(rshort,-loose,{cars=1})
 addseg(rlong,0,{flags=4,flagdir=-1})
 addseg(rshort,loose,{cars=3})
 addseg(rshort,0)
 addseg(rshort,-loose)
 addseg(rshort,0,{cars=3})
 addseg(rlong,tight)
 addseg(rshort,0,{ball=-32})
 addseg(rlong,-tight,{cars=5})
 addseg(rshort,0)
 addseg(rshort,0)
 addseg(rlong,-loose,{goal=1})
 
 -- egypt leg 2
 addseg(rlong,-tight,{cars=3})
 addseg(rshort,-tight)
 addseg(rshort,-loose,{cars=3})
 addseg(rshort,0,{flags=4,flagdir=0})
 addseg(rshort,tight)
 addseg(rshort,verytight,{flags=1,flagdir=1})
 addseg(rshort,tight)
 addseg(rshort,0,{flags=1,flagdir=-1})
 addseg(rshort,-tight)
 addseg(rlong,-verytight,{cars=4})
 addseg(rshort,0)
 addseg(rshort,0,{jump={-32,0,32},river=1})
	addseg(rshort,loose)
	addseg(rshort,0,{jump={-32,0,32},river=1})
	addseg(rshort,0,{ball=32})
	addseg(rshort,0,{jump={-32},river=1})
 addseg(rshort,0,{flags=4,flagdir=1})
	addseg(rshort,0,{jump={32},river=1,cars=10})
	addseg(rshort,0,{goal=1})
	
	-- egypt leg 3 night
	addseg(rlong,loose,{cars=10,fade=1})
 addseg(rlong,0,{cars=4})
 addseg(rshort,-loose,{cars=2})
 addseg(rlong,loose,{cars=4})
 addseg(rshort,0,{cars=5})
 addseg(rshort,-loose,{cars=10})
 addseg(rlong,-tight,{cars=10})
 addseg(rlong,0,{cars=10,lev=2})
 addseg(rshort,0,{cars=2})
 addseg(rlong,tight)
 addseg(rlong,loose,{cars=10})
	addseg(rshort,0,{fade=-1})
	addseg(rshort,0,{goal=1})
	
	-- north pole leg 1

 addseg(rlong,tight)
 addseg(rshort,0)
	addseg(rshort+32,0,{jump={-32},river=1})
	addseg(rshort+32,0,{jump={-32},river=1})
 addseg(rshort+32,0,{jump={32},river=1})
	addseg(rshort+32,0,{jump={32},river=1})
 addseg(rshort+32,0,{flags=3,flagdir=0})
	addseg(rshort,0,{jump={0},river=1})
 addseg(rshort+64,0,{jump={32},river=1})
 addseg(rshort,0,{jump={-32},river=1,cars=5})
 addseg(rshort,verytight)
 addseg(rshort,0,{cars=5})
 addseg(rshort,-verytight)
 addseg(rshort,0,{ball=-32})
 addseg(rlong,-tight,{goal=1})
 
 -- north pole leg 2
  
 addseg(rlong,-tight,{cars=3})
 addseg(rshort,-tight)
 addseg(rshort,-loose,{cars=2})
 addseg(rshort,0,{flags=2,flagdir=0})
 addseg(rlong,tight)
 addseg(rshort,0,{flags=2,flagdir=-1})
 addseg(rshort,-verytight)
 addseg(rlong,-tight,{cars=4})
 addseg(rshort,0,{flags=2,flagdir=1})
 addseg(rshort+16,0,{jump={0,0,32},river=1})
	addseg(rshort,tight,{ball=0})
	addseg(rshort,0,{jump={-32,0,32},river=1})
	addseg(rshort,0)
	addseg(rshort,0,{jump={32},river=1})
 addseg(rshort,0,{flags=2,flagdir=1})
	addseg(rshort,0,{jump={-32},river=1,cars=10,fade=1})
	addseg(rshort,0,{goal=1})

	
		-- north pole leg 3 night
	addseg(rlong,loose,{cars=10, carspeed=1.75})
 addseg(rlong,0,{cars=4})
 addseg(rshort,tight,{cars=2})
 addseg(rlong,loose,{cars=4})
 addseg(rshort,0,{cars=5})
 addseg(rshort,-loose,{cars=10})
 addseg(rlong,-tight,{cars=10})
 addseg(rlong,0,{cars=10,lev=3})
 addseg(rshort,0,{cars=2})
 addseg(rshort,tight)
 addseg(rlong,verytight,{cars=10})
	addseg(rshort,0,{fade=-1})
	addseg(rshort,0,{goal=1})
	
	--	mountains leg 1
	
 addseg(rlong,-loose,{cars=3})
 addseg(rshort,-tight,{flags=3,flagdir=0})
 addseg(rshort,-loose,{cars=3})
 addseg(rshort,0,{flags=4,flagdir=0})
 addseg(rlong,tight)
 addseg(rshort,verytight,{flags=1,flagdir=1})
 addseg(rlong,tight)
 addseg(rshort,0,{flags=1,flagdir=-1})
 addseg(rlong,-tight)
 addseg(rlong,-verytight,{cars=4})
 addseg(rshort,0)
 addseg(rshort,0,{jump={-32,0,32},river=1})
	addseg(rlong,loose)
	addseg(rshort,-loose,{jump={-32,0,32},river=1})
	addseg(rshort,0,{ball=-32})
	addseg(rshort,0,{jump={-32},river=1})
 addseg(rshort,0,{flags=4,flagdir=1})
	addseg(rshort,0,{jump={32},river=1,cars=10})
	addseg(rshort,0,{goal=1})

	-- mountains leg 2
	addseg(rlong,loose,{cars=10})
 addseg(rlong,0,{cars=4})
 addseg(rshort,-loose,{cars=2})
 addseg(rlong,loose,{cars=4})
 addseg(rshort,0,{cars=5})
 addseg(rshort,-loose,{cars=10})
 addseg(rlong,-tight,{cars=10})
 addseg(rlong,0,{cars=10})
 addseg(rshort,0,{cars=2})
 addseg(rlong,tight)
 addseg(rlong,loose,{cars=10, carspeed=2})
	addseg(rshort,0,{fade=1})
	addseg(rshort,0,{goal=1, ball=0})
	
	--night
	
	addseg(rlong,-loose,{cars=10})
 addseg(rlong,0,{cars=4})
 addseg(rlong,loose,{cars=2})
 addseg(rlong,-loose,{cars=4})
 addseg(rshort,0,{cars=5})
 addseg(rshort,-loose,{cars=10})
 addseg(rlong,tight,{cars=10})
 addseg(rlong,0,{cars=10,lev=3})
 addseg(rshort,0,{cars=2})
 addseg(rshort,-tight)
 addseg(rshort,verytight,{cars=10})
	addseg(rlong,tight,{fade=-1})
	addseg(rshort,0,{river=1,jump={-32}})
	addseg(rlong,0,{finish=1})
	-- finished
	addseg(rlong,0)
	
	
 trackq = track
 goals = 0
 cheatlev = 0
 if cheatlev > 0 then
	for t=1,#trackq do 
		if trackq[t].trigger != nil and
  	trackq[t].trigger.goal != nil then
			goals += 1
			
			if goals == cheatlev then
				tpos = t - 3
				break
			end
 	end
 end
 end
 
 plrht = 0
 jump = 0
 
	--curve()
 
 carspeed = 1.4
 speed = 0
 fade = 0
 clock = 45*30+29
 fadedir = 0
 
 passedcars = 0
 
 smokeq = {}
 drawq = {}
 objq = {}
 
 if gamemode == 4 then
	 sfx(2,1)
 end
 
 trigseg(trackq[1],32,trackq[1].len+32)
end

function drawobj(t,x,y,z,turn,col,isplr)
 add(drawq, {t=t, x=x, y=y, z=z,turn=turn,col=col,isplr=isplr})
end

function addobj(t,x,y,z,c)
	add(objq, {t=t,x=x,y=y,z=z,col=c,pass=false})
end

function addsmoke(x,y,z)
	add(smokeq, {x=x,y=y,z=z,f=0})
end

function trigseg(seg,z1,z2)

	if seg.curve < -tight then
		addobj(10, 48, 19, tzbase + track[tpos].len-32)
		addobj(8, 48, 32, tzbase + track[tpos].len-32)
	elseif seg.curve > tight then
		addobj(9, -48, 19, tzbase + track[tpos].len-32)
		addobj(8, -48, 32, tzbase + track[tpos].len-32)
	end

	local tr = seg.trigger
	if tr == nil then
		return
	end
	
	if tr.carspeed != nil then
		carspeed = tr.carspeed
	end
	
	
	if tr.fade != nil then
		fadedir = tr.fade
	end
	
	if tr.lev != nil then
		clev = tr.lev
	end
	
	if tr.ball != nil then
		addobj(11, tr.ball, 32, z1)
	end
	
	if tr.river != nil then
		addobj(6, 0, 32, z1+20)
	end

	if tr.jump != nil then
		for j in all(tr.jump) do
			addobj(12, j, 32, z1)
		end
	end
	
	if tr.goal != nil then
		addobj(16, 0, 32, z1)
	end
	
	if tr.finish != nil then
		--stop()
		addobj(17, 0, 32, z1)
	end
	
	if tr.flags != nil then
		local x=-tr.flagdir*32
		for i=1,tr.flags do
			addobj(4, x, 32, z1+i*48)
			x += 16*tr.flagdir
		end
	end
	
	if tr.cars != nil then
		local c = 0
		for z=z1,z2,32 do
			if carsscr < 10 then
				carsscr += 1
				addobj(3, rnd() * 64 - 32, 32, z, flr(rnd(2) + 0.5) + 1)
			end
			c += 1
			if c >= tr.cars then
				break
			end
		end
	end
end


function updateobjs()
--	print(#objq)
--	stop()
	for o in all(objq) do
	 if o.t != 3 then
 		o.z -= speed
 		
 		if o.t == 11 and o.passed then
 			o.z += 10
 			o.y -= 2
 		end
 	else
 		o.z -= speed - carspeed
 	end
 	
 	if o.t == 6 and plrht <= 0 and o.z <= -12 then
 		sfx(0,0)
 		jump = 2
 		
 		speed /= 4
 	elseif o.t == 16 and not o.passed and o.z <= -12 then
			clock += 32*30
			seg += 1 	
			o.passed = true
			disttrav = seg * 4
			sfx(6,2)
		elseif o.t == 17 and not o.passed and o.z <= -12 then
			--stop()
			gamemode = 2
			deinitgame()
			o.passed = true
 		-- goal!!!
 		-- goal!!!
 	elseif plrht < 10 and o.z <= -12 and o.z >= -15
 		and abs(-o.x - px*2) < 12
 	then
 		if o.t != 6 and o.t != 16 then
 		if o.t == 3 then
 			if -px < o.x then 
 				pt = -speed
	 		else
 				pt = speed
 			end
 			speed *= 3/4
 			sfx(3,0)
 		elseif o.t == 4 then
 			--addscore(100)
 			--sfx(1,0)
 			del(objq, o)
 		elseif o.t == 11 and not o.passed then
 			addscore(1000)
				o.passed = true
				sfx(0,0)
			elseif o.t == 12 and not o.passed then
				jump = 3
				sfx(0,0)
			elseif not resetpos then
 		 if -px < o.x then 
 				pt = -speed
	 		else
 				pt = speed
 			end
 			speed /= 2
			end
			end
 	end
 	
 	if o.z < -18 then
 		if o.t == 3 and not o.passed then
	 		passedcars += 1
	 		sfx(5,0)
	 		o.passed = true
	 	end
 	end
-- 	stop()
 	if o.z <= -32 or o.z > 1024 then
 		if o.t == 3 then
 			carsscr -= 1
 		end
 	 del(objq, o)
 	end
 end
 
	for o in all(smokeq) do
 	o.z -= speed
 	o.y -= 0.25
 	o.f += 0.334
-- 	stop()
 	if o.z <= -32 or o.f >= 4 then
 	 del(smokeq, o)
 	end
 end

end

function deinitgame()
	sfx(-1,0)
	sfx(-1,1)
	sfx(-1,2)
	frame = 0
end

function updategame()
 drawq = {}
 
 if gotime < 30 then
 gotime += 1
 end
 
 
	local accl = 0
	local turn = 0

	frame +=1
	
	local tach = (speed * 20) % 25 + speed * 3
	
	if tach == 0 then
		tach += frame % 3
	end
	
	if tach > 31 then
		tach = 31
	end

	--poke(0x3200+68*2,tach)
	--poke(0x3200+68*2+1,3+0x60)
	--poke(0x3200+68*2+2,tach/1.5)
	--poke(0x3200+68*2+3,1+0x60)

	if btn(0) then
		turn = -1
	elseif btn(1) then
	 turn = 1
	end
	
	if btn(3) or btn(4) then
		accl = -1
		--fade = fade - 0.25
	elseif btn(2) or btn(5) then
		accl = 1
	 --fade = fade + 0.25
	end
	
	if clock <= 0 then
		accl = 0
	end
	
	if gamemode != 0 then
		accl = 0
		turn = 0
	end
	
	if gamemode == 4 then
		starttimer -= 1
		
		if starttimer <= 0 then
			gamemode = 0
			sfx(8,0)
		elseif starttimer % 30 == 0 then
			sfx(7,0)
		end
	end
	
	if not resetpos and plrht <= 0 then
	 if accl > 0 then
		 if speed > 2.5 then
			 speed += 0.003	
 		elseif speed > 2 then
	 		speed += 0.005	
		 elseif speed > 1.25 then
			 speed += 0.007	
 		else
		 	speed += 0.03
	 	end
	 elseif accl < 0 then
		 speed -= 0.05
	 else
		 speed -= 0.03
	 end
	end
	
	if not resetpos and plrht <= 0 and abs(px) >= 20 then
		if speed > 0.5 then
		speed -= 0.25
		end
		
		if speed > 1 then
		jump = 0.5
		end
		
		if speed < 0.1 and abs(px) >= 32 then
			resetpos = true
		end
	end 
	
	if speed < 0 then
	 speed = 0
	end
	
	if speed > 3.19 then
	 speed = 3.19
	end
	
	if not resetpos and speed <= 0 and plrht > 0 then
		speed = 0.5
	end
	
	xpush = trackq[tpos].curve * 32 * speed

	if plrht <= 0 then
		px -= pt
	end
	
	px += xpush
	
	if not resetpos then
	 if (accl < 0 and speed > 2) 
		 or (accl > 0 and speed < 0.75) or
		 jump > 0 or abs(-pt - xpush) >= 3.5 then
		 if fade < 6 then
		  addsmoke(-px*2+4, 32-plrht, -14 + speed/2)
		  addsmoke(-px*2-4, 32-plrht, -14 + speed/2)
		
		  --addsmoke(-px*2+4+pt, 32-plrht, -10)
		  --addsmoke(-px*2-4+pt, 32-plrht, -10)
		 end
		 
		 if frame % 3 == 0 and plrht <= 0 then 
		 	sfx(10,3)
		 end
	 end
	end
	
	if turn < 0 then
		pt -= 0.6
	elseif turn > 0 then
		pt += 0.6
	else
		if pt > 0 then
			pt -= 0.4
		elseif pt < 0 then
		 pt += 0.4
	end
	
	if pt > -0.4 and pt < 0.4 then
	 pt = 0
	end
	end
	
	if pt < -2 then
	 pt = -2
	end
	
	if pt > 2 then
	 pt = 2
	end
	
	if resetpos then
		pt = 0
		local s = 1
		
		if abs(px) > 20 then
			s = 2
		end
	
		if px > 0 then
			px -= s
		elseif px < 0 then
			px += s
		end
		
		if px >= -3 and px <= 3 then
			resetpos = false
		end
	
	end
	
	horzmove = (horzmove * 2 + trackq[tpos].curve * 60 * speed) / 3
 horzx -= horzmove
	
	plrht += jump
	
	if plrht < 0 and jump != 0 then
		jump /= -3
		plrht = 0
		sfx(9,0)
		if abs(jump) < 0.5 then
			jump = 0
		end
	elseif plrht > 0 then
		jump -= 0.2
	end
	
	py = py + 1 * speed
	tzbase += 1 * speed
	
	if trackq[tpos].len <= tzbase then
		tzbase = trackq[tpos].len - tzbase
		tpos += 1
		if tpos > #trackq then
			tpos = 1
		end
		
		local ntpos = tpos + 1
		
		if ntpos > #trackq then
			ntpos = 1
		end
		
		trigseg(trackq[ntpos],
			tzbase + trackq[tpos].len,
			tzbase + trackq[tpos].len + trackq[ntpos].len)
		
		
		--spawn objects for segment
		
		if fade < 2 then
		--addobj(4, rnd() * 64 - 32, 32, tzbase + track[tpos].len)
		end
		
		for c=0,80,32 do
			--addobj(2, c + 80, 32, tzbase + track[tpos].len)
			--addobj(2, -c - 80, 32, tzbase + track[tpos].len)

		end
		
		for c=0,track[tpos].len,32 do
			addobj(level[clev].rubble, rnd() * -40 - 64, 32, tzbase + c + track[tpos].len)
			addobj(level[clev].rubble, rnd() * 40 + 64, 32, tzbase + c + track[tpos].len)
		end
	
	
	 --[[
	 if not trackq[tpos].tunnel and
	 	track[ntpos].tunnel then
	 	addobj(6, 0, 0, tzbase + track[tpos].len)
	 end
	 
	 if trackq[tpos].tunnel and
	 	not track[ntpos].tunnel then
	 	addobj(7, 0, 0, tzbase + track[tpos].len)
	 end
	 --]]
		
		if fade < 3 then
		for c =0,trackq[ntpos].len,140 do
		addobj(1, -64, 19, tzbase + track[tpos].len+8+c)
		addobj(1, 64, 19, tzbase + track[tpos].len+8+c)
		addobj(2, -64, 32, tzbase + track[tpos].len+8+c)
		addobj(2, 64, 32, tzbase + track[tpos].len+8+c)
		end
		end
		
		--addobj(10, -48, 19, tzbase + track[tpos].len)
		--addobj(8, -48, 32, tzbase + track[tpos].len)

		--addobj(11, 0, 32, tzbase + track[tpos].len)


		--addobj(12, rnd()*40-40, 32, tzbase + track[tpos].len)

		
	end
	
	
	--if rnd() < 0.1 then
	-- addsmoke(-px*2, 32, -14)
	--end
	
	--print(#objq)
	--stop()
	updateobjs()

 for o in all(objq) do
	 drawobj(o.t,o.x,o.y,o.z,0,o.col)
 end
 
 for o in all(smokeq) do
	 drawobj(5,o.x,o.y,o.z,0,o.f)
 end

	--drawobj(0,16,32,10)
	drawobj(0,-px*2,32-plrht,-14,pt*2,0,true)
 --drawcar(px*2, 50,40,trackq[tpos].curve*100)
	--drawcar(-px / 2,50,1,pt*2)	
	
	if gamemode == 0 then
	
	addscore(speed/2)

	if clock > 0 then
		clock -= 1
	end
	
	if clock <= 0 and speed <= 0 then
		gamemode = 1
		deinitgame()
	end
	end
	
	if fadedir < 0 then
		fade -= 0.075
		
		if fade < 0 then
			fade = 0
		end
	elseif fadedir > 0 then
		fade += 0.075
		
		if fade > 9 then
			fade = 9
		end
	end
end

function drawtree(x,y,z,bspr,w,h,f)

	setfade(fade,3)

 local dy = 32*32 / (z + 32)
 local ody = flr(dy)
 if ody < 2 then
  ody = 2
 elseif ody > 63 then
  ody = 63
 end
	local sw = w * 8 * 32 / (z + 32)
	local sh = h * 8 * 32 / (z + 32)
	dy = y*32 / (z + 32)
	if sw < w * 8 then 
		local srcx = (bspr % 16) * 8
 	local srcy = flr(bspr/16) * 8
  
 	sspr(srcx,srcy,w*8, h*8, (x+px)*32/(z+32)+64-sw/2+xoffs[ody],dy+64-sh,sw,sh, f, false)
 else
 spr(bspr,(x+px)*32/(z+32)+64+xoffs[ody]-w*4,dy+64-h*8, w, h, f, false)
 end
end

function drawsmoke(x,y,z)
 local dy = 32*32 / (z + 32)
 local ody = flr(dy)
 if ody < 2 then
  ody = 2
 elseif ody > 63 then
  ody = 63
 end
	local s = 8 * 32 / (z + 32)
	dy = y*32 / (z + 32)
	if s < 8 then 
  sspr(0,56+32,8,8,(x+px)*32/(z+32)+64-s/2+xoffs[ody],dy+64-s,s,s)
 else
  spr(112,(x+px)*32/(z+32)+64+xoffs[ody]-4,dy+64-16, 1, 1)
 end
end


function drawwall(z,c)


	dy1 = 32 * 32 / (z + 32 + 20)
	dy2 = (32 + 8) * 32 / (z + 32 + 20)
	dy3 = 32 * 32 / (z + 32)
	
	if z <= -32 then
		return
	end

	color(level[clev].rbank)

	rectfill(0, dy1+64, 127, dy2+64)
	color(level[clev].rwater)

	rectfill(0, dy2+64, 127, dy3+64)

	color()
end


function drawgoal(z,c)

	dy1 = -6 * 32 / (z + 32)
	dy2 = (-1) * 32 / (z + 32)
	dy3 = 32 * 32 / (z + 32)
	
	local dy = 32*32 / (z + 32)
 local ody = flr(dy)
 if ody < 2 then
  ody = 2
 elseif ody > 63 then
  ody = 63
 end

	local x1 = (-54 + px) * 32 / (z + 32) + xoffs[ody]
	local x2 = (54 + px) * 32 / (z + 32) + xoffs[ody]  

	
	local w = 8*32/(z+32)

	sspr(96,16,8,16,x1+64-w/2,dy2+64,w,dy3-dy2)
	sspr(96,16,8,16,x2+64-w/2,dy2+64,w,dy3-dy2)


	color(7)

	rectfill(x1 + 64, dy1+64, x2 + 64, dy2+64)

	--rectfill(0, dy2+64, 127, dy3+64)

	color()
end

function drawstart()
	drawgame()
	local z = 1 - (starttimer % 30 / 30)
	if starttimer < 3 * 30 then
	sspr(flr((starttimer)/30+1)*8,64+8,8,16,64-8*z,64-16*z,16*z,32*z)
	gotime =0
	end
end


function _draw()
	if gamemode == 0 then 
		drawgame()
	elseif gamemode == 4 then
		drawstart()
	elseif gamemode == 5 then
		drawgameovermap()
	elseif gamemode == 1 then
		drawgameover()
	elseif gamemode == 2 then
		drawgamecompleted()
	elseif gamemode == 3 then
		drawgametitle()
	end
	
end

function updategametitle()
	frame += 1
	
	if btnp(2) or btnp(4) or btnp(5) then
		gamemode = 4
		initgame()
	end
end

function initmap()
	perc=0
	for y=16,16+6 do
		for x=0,15 do
			if mget(x,y) >= 224 then
				mset(x,y,mget(x,y)-16)
			end 
		end
	end
	
	local i = tpos
	while i > 1 do
		if trackq[i].trigger != nil and trackq[i].trigger.goal != nil then
			break
		end
		i-=1
	end
	local j = i+1
	while j < #trackq do
		if trackq[j].trigger != nil and trackq[j].trigger.goal != nil
		then
			break
		end
		j+=1
	end
	
	local len = j-i
	disttrav=(seg-1)*4*6+flr((tpos-i+1)*4*6/len)
	--[[color(7)
	cls()
	print(tpos-i+1)
	print(len)
	print(seg)
	print(disttrav)
	stop()--]]
	
	if disttrav == nil or disttrav < 0 then
		disttrav = 0
	end
	--cls()
	--print(i)
	--print(j)
	--print(len)
	--stop()
end

function updategameover()
	frame += 1
	
	if frame > 3 * 30 then
		gamemode = 5
		frame = 0
		initmap()
	end
end

function updategameovermap()
	if frame == 0 then
		initmap()
		perc=0
	end

	frame += 1
	
	if disttrav > 0 then
		perc = min(99,min(frame,disttrav)*100/(3*3*4*6))
	else
		perc = 0
	end
	
	if frame % 6 == 0 and md >= 0 then
	
		if mget(mdx,mdy) >= 211 then
			mset(mdx,mdy,mget(mdx,mdy)+16)
		end
		
		if md == 0 then
			mdx+=1
		elseif md == 1 then
			mdy+=1
		elseif md == 2 then
			mdx-=1
		elseif md == 3 then
			mdy-=1
		end
		
		local t = mget(mdx,mdy)
	
		if t == 213 then
			if md == 3 then
				md = (md + 1) % 4
			else
				md = (md + 3) % 4 
			end
		elseif t == 214 then
			if md == 3 then
				md = (md + 3) % 4
			else
				md = (md + 1) % 4 
			end
		elseif t == 215 then
			if md == 2 then
				md = (md + 1) % 4
			else
				md = (md + 3) % 4 
			end
		elseif t == 216 then
			if md == 0 then
				md = (md + 3) % 4
			else
				md = (md + 1) % 4 
			end
		elseif t < 211 then
			md = -1
		end
		
		maptravel += 6
		
		if maptravel >= disttrav then
			md = -1
		end

	end
	
	if btnp(2) or btnp(4) or btnp(5) then
		gamemode = 3
		updatebestscore()
		deinitgame()
	end
end

function updategamecompleted()
	updategame()

	if passedcars > 0 then
		addscore(20)
		passedcars -= 1
	elseif clock >= 0.1*30 then
		addscore(10)
		clock -= 0.1*30
	end
	if clock < 0.1*30 and passedcars <= 0 and btnp(2) then
		gamemode = 3
		updatebestscore()
		deinitgame()
	end
end

function _update()
	if gamemode == 0 or gamemode == 4 then
		updategame()
	elseif gamemode == 1 then
		updategameover()
	elseif gamemode == 2 then
		updategamecompleted()
	elseif gamemode == 3 then
		updategametitle()
	elseif gamemode == 5 then
		updategameovermap()
	end
	
end



function drawgame()
 cls()
 
 local	ntpos = tpos + 1
		
		if ntpos > #trackq then
			ntpos = 1
		end

	setfade(fade,0)
 
 for x=0,15 do
 	map(0,0,x*8,0,1,8)
 end
 
 curlev = level[clev]
 
 setfade(fade,1)
 
 for x=0,15 do
 	map(curlev.landx,curlev.landy,x*8,64,1,8)
 end
		
 map(curlev.skyx,curlev.skyy,(horzx / 2) % 128,64-32,16,4)
 map(curlev.skyx,curlev.skyy,(horzx / 2) % 128 - 128,64-32,16,4)
 map(curlev.skyx,curlev.skyy,(horzx / 2) % 128 + 128,64-32,16,4)

	setfade(fade,1)

 map(curlev.horzx,curlev.horzy,horzx % 128,64-24,16,3)
 map(curlev.horzx,curlev.horzy,horzx % 128 - 128,64-24,16,3)
 map(curlev.horzx,curlev.horzy,horzx % 128 + 128,64-24,16,3)
 
 setfade(fade,2)

 local x = 0
 local xs = 0.0
 local xs2 = 0
 local tp = tpos
 local lz = getroadz(63) - tzbase
 xoffs={}
	for y=63,2,-1 do
	 local rz = getroadz(y)
	 if rz - lz > trackq[tp].len then
	  tp += 1
	  lz = rz
	  if tp > #trackq then
	  	tp = 1
	  end
	  
	 end
	 xs2 = trackq[tp].curve
	 xs = xs + xs2 
	 x = x + xs * rz / 32  
	 xoffs[y]=x/2
	 drawseg(y,x,px,false)
	end
	
	sort(drawq)
	
	for o in all(drawq) do
		if o.z > -34 and o.z < 320 then
	 if o.t == 0 then 
	 	drawcar(o.x, o.y, o.z, o.turn, 0, true)
	 elseif o.t == 1 then
	 	drawtree(o.x,o.y,o.z,level[clev].tree,3,3)
 	elseif o.t == 2 then
	 	drawtree(o.x,o.y,o.z,level[clev].trunk,1,2)
	 elseif o.t == 3 then
	 	drawcar(o.x,o.y,o.z,0, o.col)
	 elseif o.t == 4 then
	 	drawtree(o.x,o.y,o.z,74,2,2)
	 elseif o.t == 5 then
	 	drawtree(o.x,o.y,o.z,112 + flr(o.col),1,1)	
	 elseif o.t == 6 then
	 	drawwall(o.z, 7)	
 	elseif o.t == 7 then
	 	drawwall(o.z, 0)	
		elseif o.t == 8 then
	 	drawtree(o.x,o.y,o.z,44,1,2)	
	 elseif o.t == 9 then
	 	drawtree(o.x,o.y,o.z,36,2,2)	
	 elseif o.t == 10 then
	 	drawtree(o.x,o.y,o.z,36,2,2,true)	
	 elseif o.t == 11 then
	 	drawtree(o.x,o.y,o.z,78,2,2)	
	 elseif o.t == 12 then
	 	drawtree(o.x,o.y,o.z,125,3,1)	
	 elseif o.t == 13 then
	 	drawtree(o.x,o.y,o.z,71,1,1)	
	 elseif o.t == 14 then
	 	drawtree(o.x,o.y,o.z,72,1,1)	
	 elseif o.t == 15 then
	 	drawtree(o.x,o.y,o.z,121,1,1)	
 	elseif o.t == 16 or o.t == 17 then
	 	drawgoal(o.z,1)	
	 end
	 end
	end
	
	pal()
	
	--spr(62,0,128-8,2,1)
	--prnum(passedcars,3,13,128-7,false)

	--spr(143,128-4*8+2,128-8+1)
	--prnum(flr((seg-1)/3+1),1,128-3*8+1,128-7,false)
	--spr(142,128-2*8+1,128-8+1)
	--prnum(flr((seg-1)%3+1),1,128-1*8,128-7,false)
	
	prnum(score,4,8*2,8,false)
	prnum(score2,2,0,8,false)
	prnum(clock/30,2,112,8,true)
	
	--prnum(speed*100,3,128-8*5+3,8,false)
	
	spr(138,116-13,0,4,1)
 spr(154,0,0,4,1)
	--spr(170,127-8*4+2,0,4,1)
	--spr(158,127-2*8+4,8,2,1)
	
	if gotime < 15 and gamemode == 0 then
		local z = gotime/15 + 0.5
		sspr(0,96+16,24,16,64-z*12,64-z*8,z*24,z*16)
	end
	
	

	--drawlogo()

 --line(64,0,64,127)
 --pal(7,0,1)
 --pal()
	
	--cursor(0,0)
	--color(7)
	--print(stat(1)*100)
	--print(clock/30)
	--print(passedcars)
	--print(tpos.."/"..#trackq)
end



	
function sort(a)
  for i=1,#a do
    local j = i
    while j > 1 and 
   		(a[j-1].t != 6 and a[j].t == 6 or a[j-1].z < a[j].z) do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end


function drawlogo()
	for x=64-6*8,64+5*8,8 do
		local f = flr(sin(x/60+frame/30)*1.5+1.5)
		if f < 0 then
			f = 0
		elseif f > 2 then
			f = 2
		end
		spr(208+f,x,64-20-4+sin(x/80+frame/30)*2)
		spr(208+f,x,64-20-4+8+sin(x/80+frame/30)*2)
	end
	
	nicetext(56-5*8,64-24,"bicycle race")

end


function drawgametitle()
	cls()
	--drawgame()
	
	
	cursor(64-5*4,64-13+14)
	color(1)
	--print("best score:")
	--cursor(64-5*4-1,64-13-1+14)
	--color(7)
	--print("best score:")

	--prnum(bestscore,4,64-3*8+8*2,64+8,false)
	--prnum(bestscore2,2,64-3*8,64+8,false)

 rect(9, 17, 121, 121, 2)
 rect(8, 16, 120, 120, 9)
	cursor(64-4*9.5,64+25)
	color(1)
	print("push the — button!")

	cursor(64-4*9.5-1,64+25-1)
	color(12)
	print("push the — button!")
	
	cursor(34,100)
	color(7)
	print("(c)2017sr21923")
	drawlogo()
	
end

function drawgameover()
	drawgame()

	nicetext(64-5*8+4, 64-8, "game over")

	
	--rectfill(4,40,124,40+8*7+4)
	
	--map(0,16,0,44,16,7)

end

function drawgameovermap()
	drawgame()
	nicetext(64-6*6-4, 64-36, "course map")

	cursor(64-11*4,64+45)
	
	color(1)
	

	print("press fire to continue")
	color(7)
	cursor(64-11*4-1,64+45-1)

	print("press fire to continue")
	
	color(0)
	--rectfill(4,40,124,40+8*7+4)
	
	map(0,16,4,44,16,7)
	
	prnum(perc,3,6*8,44+8*2,true)
end


function drawgamecompleted()
	drawgame()
	
	nicetext(64-15*4,64-15, "congratulations")
	cursor(64-6*4,64-13+14)
	color(1)
	print("final score:")

	cursor(64-6*4-1,64-13-1+14)

	color(7)
	print("final score:")

	prnum(score,4,64-3*8+8*2,64+8,false)
	prnum(score2,2,64-3*8,64+8,false)

	cursor(64-11*4,64+25)
	color(1)
	print("press fire to continue")
	color(7)
	cursor(64-11*4-1,64+25-1)

	print("press fire to continue")

end


function prnum(num,digits,x,y,big)
	local tmp = num
	local h = 1
	local base = 128
	if big then
		h = 2
		base = 144
	end
	for i=digits-1,0,-1 do
		local digit = flr(tmp) % 10
		spr(base+digit,0+i*8+x,y,1,h)
		tmp /= 10
	end
end

chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
-- '
s2c={}
c2s={}
for i=1,95 do
c=i+31
s=sub(chars,i,i)
c2s[c]=s
s2c[s]=c
end

function ord(s,i)
return s2c[sub(s,i or 1,i or 1)]
end

function nicetext(x,y,text)
	local b = ord("a")
	for i=1,#text do
		local c = ord(sub(text,i,i))-b+176
		spr(c,x,y,1,1)
		x+=8
	end
end
__gfx__
e888888244444444eeeeeee2ddddddddaaaaaaaf66666666e8888882cccccccceeeeeee200000000000006777760000077777777000000000007760000000000
e888888244444444eeeeeee2ddddddddaaaaaaaf66666666e8888882cccccccceeeeeee200000000000677777777600077777777000000000007760000000000
e888888244444444eeeeeee2ddddddddaaaaaaaf66666666e8888882cccccccceeeeeee200000000007777777777770077777777000000000077776000000000
e888888244444444eeeeeee2ddddddddaaaaaaaf66666666e8888882cccccccceeeeeee200000000067777777777776077777777000000000777776000000000
677777764444744477777776dddd6ddd7777777f6666f66667777776cccc7ccc7777777600000000077777777777777077777777000000000777366600000000
677777764444744477777776dddd6ddd7777777f6666f66667777776cccc7ccc7777777600000000677777777777777677777777000000007763b66600000000
677777764444744477777776dddd6ddd7777777f6666f66667777776cccc7ccc777777760000000077777777777777777777777700000003763b335660000000
677777764444744477777776dddd6ddd7777777f6666f66667777776cccc7ccc77777776000000007777777777777777777777770000003b63b3313510000000
cccccccceeeeeeee666666663333333366666666cccccccc0bbbbbb00bbbbbb00bbbbbb000000007660000000000000067676767000000331133113310000000
cccccccceeeeeeeebbbbbbbb3333333366666666cccccccc03333330033333300333333000000076cccc00000000000076767676000000111111311350000000
cccccccceeeeeeee666666663333333366666666cccccccc0bbbbbb00bbbbbb00bbbbbb000000767666666000000000067676767000000077117311100000000
cccccccceeeeeeeebbbbbbbb3333333366666666cccccccc00044000000440000004400000007676cccccccc0000000076767676000007777577577760000000
cccccccceeeeeeee666666663333333366666666ccccccc700044000000440000004400000076767666666666600000067676767000077666577577760000000
cccccccceeeeeeeebbbbbbbb3333333366666666ccccccc700044000000440000004400000767676cccccccccccc000076767676000063b55b665bb776000000
cccccccceeeeeeee666666663333333366666666ccccccc70004400000044000000440000767676766666666666666006767676700003b35bb365b3565100000
cccccccceeeeeeeebbbbbbbb3333333366666666ccccccc700044000000440000004400076767676cccccccccccccccc767676760033bb3577735b3535510000
eeeeeeeeaaaaaaaabbbbbbbb777777770666666666666660000000060000000000000000dddddddd666666666666666600555500000333557633533555111000
ccccccccffffffffbbbbbbbb7777777767777777777777760000006d000bb000000bb000ddddddddcccccccc7ccccccc00d6d500000003336633233335110000
eeeeeeeeaaaaaaaabbbbbbbb777777776799999999999976000006d60003300000033000dddddddd666666666766666600676d00000007bb3337713301000000
ccccccccffffffffbbbbbbbb77777777679999999199997600006d6d00bbbb0000bbbb00ddddddddcccccccc767ccccc00676d00000077633376631377770000
eeeeeeeeaaaaaaaabbbbbbbb7777777767999999911999760006d6d60033330000333300dddddddd666666666767666600676d0000b766333bb6613333667000
ccccccccaaaaaaaabbbbbbbb777777776799994111119976006d6d6d0bbbbbb00bbbbbb0ddddddddcccccccc76767ccc00676d00333330000433321000333300
eeeeeeee77777777bbbbbbbb77777777679991111111197606d6d6d60333333003333330dddddddd666666666767676600676d0000000000044f421000000000
cccccccc77777777bbbbbbbb7777777767994111111199766d6d6d6d0bbbbbb00bbbbbb0ddddddddcccccccc7676767600676d000000000004f2222000000000
ffffffff66666666bbbbbbbb7777777767991114911999765000000000000000000000005d5d5d5dd6d6d6d63333333300676d00dddddddd0000011110000000
eeeeeeee6666666633333333666666666799111991999976d50000006000000000000067d5d5d5d56d6d6d6d3333333300676d00333333330000177771000000
ffffffff66666666bbbbbbbb7777777767991119999999765d50000076c00000000007765d5d5d5dd6d6d6d63333333300676d00dddddddd0111711717100000
eeeeeeee6666666633333333666666666799111999999976d5d50000676c000000007777d5d5d5d56d6d6d6d3333333300676d00333333331777777777710000
ffffffff66666666bbbbbbbb7777777767991119999999765d5d500076c6c000000777775d5d5d5dd6d6d6d63333333300676d00dddddddd1711777711710000
ffffffff6666666633333333666666666799999999999976d5d5d500676c6c00006d7777d5d5d5d56d6d6d6d3333333300676d00333333330177177177100000
ffffffff66666666bbbbbbbb7777777767777777777777765d5d5d507656cd5006d6d7d75d5d5d5dd6d6d6d63333333300676d00dddddddd0177111177100000
ffffffff6666666633333333666666660666666666666660d5d5d5d5d5d6d5c56d6d6d6dd5d5d5d56d6d6d6d3333333300676d00333333330011000011000000
00000000005555000000000000000000000000000000000000999900000999000006660000000000000000000000000000000000000000000000000000000000
0000000000555500000000000000000000000000000000000999999000aa944000776cc0c000dcc0000000000000000000000000000000000000000000000000
000000000055550000000000000000000000000000000000099999900aaa49900777c660ccd0cccc000000000000000000000008800000000000000000000000
0000000052555525000000000000000052000025000000000999999009a94a400676c7c0dcccccc0000000000000000000000088880000000000000000000000
000000005255552500000000000000005200002500000000099999900994aa94066c776c0cccccd000000000000000000000088aa88000000000000000000000
0000000000522500000000000000000000522500000000000f9ff9000044944400cc6ccc00cccc000000000000000000000008aaaa8000000000000000000000
0000000000055000000000000000000000055000000000000fffff000111144001111cc0cccccd00000000000000000000008841148800000000000000000000
0000000000000000000000000000000000000000000000000000000000111110001111100dcd0000000000000000000000088a1111a880000000000000000000
00000000005555000000000000000000000000000000000000000000000bb300000000000000000000000000000000000008aa1111aa80000000000000000000
00000000005555000000000000000000000000000000000000000000000bb30000000000000000000000000000000000008aaa4114aaa8000000000000000000
0000000000555500000000000000000000000000000000000000000000bbbb3000000000000000000000000000000000088aaaa11aaaa8800000000000000000
000000005255552500000000000000005200002500000000000000000bbbbb300000000000000000000000000000000008aaaaaaaaaaaa800000000000000000
000000005255552500000000000000005200002500000000000000000bbb33330000000000000000000000000000000088aaaaa11aaaaa880000000000000000
00000000005225000000000000000000005225000000000000000000bb33b333000000000000000000000000000000008aaaaaa11aaaaaa80000000000000000
00000000000550000000000000000000000550000000000000000003b33b3353300000000000000000000000000000008aaaaaaaaaaaaaa80000000000000000
0000000000000000000000000000000000000000000000000000003b33b331351000000000000000000000000000000008888888888888800000000000000000
0000000000555500000000000000000000000000000000000000003311331133100000000000000000ff42200000006777760000000000000000000000000000
0000000000555500000000000000000000000000000000000000001111113113500000000000000000f442200007777777777000000000000000000000000000
0000000000555500000000000000000000000000000000000000000bb11b3111000000000000000000ff42200067777777777000000000000000000000000000
00000000525555250000000000000000520000250000000000000bbbb5bb5bbb300000000000000000f442200077777777777700000000000000000000000000
0000000052555525000000000000000052000025000000000000bb3335bb5bbb300000000000000000ff42200677777777777760000000000000000000000000
000000000052250000000000000000000052250000000000000033b55b335bbbb30000000000000000ff42200777777777777760000000000000000000000000
00000000000550000000000000000000000550000000000000003b35bb335b35351000000000000000f444200777777777777760000000000000000000000000
0000000000000000000000000000000000000000000000000033bb35bbb35b35355100000000000000f444200777777777766660000000000000000000000000
00000000000000000000000000000000000000000000000000033355b3335335551110000000b00000ff42200777777777666660009999999999999999999900
000000000000000000000000000000000000000000000000000003333333233335110000b006300b00ff422006777777776666d009ffffffffffffffffff9440
0000000000000000000000000000000000e780000000000000000bbb333bb13301000000b30b30bb00ff42200067777776666dd09ffffffffffffffffff949f4
00000000000000000000000000000000008e8000000000000000bb3333b33313bbbb000033b350b300f4422000666777766dddd09fffffffffffffffff949ff4
00000000000000000000000000000000008880000000000000bb33333bb331333333b00053631b3500f4442000066666666ddd00999999999999999999949ff4
000000000000000000000000000000000000000000000000333330000433321000333300053333500f442420000166666dddd10044999999999999999999f9f4
00000000000000000000000000000000000000000000000000000000044b42100000000011333511f44f42440011166ddd11111004444444444444444444ff40
0000000000000000000000000000000000000000000000000000000004f222200000000001111110400440040000111111110000002222222222222222222400
01111100001111000111110011111100111100001111110001111100111111100111110001111100111111111111110111111111100000000000000000111110
11777110011771001177711017777110177111101777710011777100177777101177711011777110177777717717711177177777100000000000000001177710
17717710017771001771771011117710177177101771110017711100111177101771771017717710111771117717771777177111100000000111110001771110
16616610011661001116611001666610166666101666611016666110011661101166611011666610001771017717717177177771000000000166610001177110
16616610001661001166111011116610111166101111661016616610016611001661661001116610001771017717711177177111100000000111110001117710
11ddd110001dd1001ddddd101dddd1100001dd101dddd11011ddd11001dd100011ddd11001ddd110001771017717710177177777100000000000000001777110
01111100001111001111111011111100000111101111110001111100011110000111110001111100001111011111110111111111100000000000000001111100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000111000011110000111100111111111111111000011110111111110011110000111100011111111111111111111111111111100000000011100000
0177771000177100017777100177771017711771177777100014a710177777710177771001777710117777117771177771117771177777101110000017100000
19aaaa91017aa10019aaaa9119aaaa911aa11aa11aaaaa10019aaa101aaaaaa119aaaa9119aaaa91177111177177177177177177177111101711111117111000
17a11aa117aaa10017a11aa117a11aa11aa11aa11aa1111014a911101aa11aa117a11a7117a11a71177777177111177771177177177771001717177717771000
1aa11aa1199aa1001aa11aa111111aa11aa11aa11aa1111019a1110011119a911aa11aa11aa11aa1111177177177177177177177177111101771171717171000
1aa11aa1111aa10011111aa1001aaa911aa77aa11aa77a411aa779100014a91019aaaa9119aaaaa1177771117771177177117771177777101717177717171000
19911991001991000001994100199941149999911499999119999941001991001499994114999991111111011111111111111111111111101111171111111000
19911991001991000019941011111991111119911111199119911991001991001991199111111991000000000000000000000000000000000000111000000000
19911991001991000199411119911991000019911991199119911991001991001991199101114941011111111111111111111111111111000000000000000000
14999941001991001999999114999941000019911499994114999941001991001499994101999911117777177771177777177777177771100000000000000000
01499410001991001999999101499410000019910149941001499410001991000149941001994110177111177177177111177111177177100000000000000000
00111100001111001111111100111100000011110011110000111100001111000011110001111100177777177177177771177771177177100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000111177177771177111177111177177100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000177771177111177777177777177771100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000111111111100111111111111111111000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111100111111000111110011111100111111101111111001111100111111100111100000011110111111101111000011101110111111000111110011111100
11aaa1101aaaa11011aaa1101aaaa1101aaaaa101aaaaa1011aaa1001aa1aa1001aa10000001aa101aa1aa101aa100001a111a101aaaa11011aaa1101aaaa110
1aa1aa101aa1aa101aa1aa101aa1aa101aa111101aa111101aa111101aa1aa1001aa10000001aa101aa1aa101aa100001aa1aa101aa1aa101aa1aa101aa1aa10
17777710177771101771111017717710177771001777710017717710177777100177100011117710177771101771000017777710177177101771771017777110
19919910199199101991991019919910199111101991110019919910199199100199100019919910199199101991111019919910199199101991991019911100
19919910199991101199911019999110199999101991000011999910199199100199100011999110199199101999991019919910199199101199911019910000
11111110111111000111110011111100111111101111000001111110111111100111100001111100111111101111111011111110111111100111110011110000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111100111111000111110011111111111111101111111011111110111111101111111011111110000000000000000000000000000000000000000000001111
11aaa1101aaaa11011aaa1001aaaaaa11aa1aa101aa1aa101aa1aa101aa1aa101aa1aa101aaaaa10000000000007000000000000000000000000000011111771
1aa1aa101aa1aa101aa11110111aa1111aa1aa101aa1aa101aa1aa101aa1aa101aa1aa101111aa10000000000073b00000000000000000000000000017711aa1
177177101777711017777710001771001771771017717710177777101177711017777710011771100000000000b330000000000000000000000000001aa14a41
19999910199199101111991000199100199199101191911019919910199199101111991011991110000940000b3333000000000000000000000000001111aa10
11999910199199100199911000199100119999100119110019111910199199100199911019999910009a440003b333000000000000000000000000000014a410
0111111011111110011111000011110001111110001110001110111011111110011111001111111009a944400094400000000000000000000000000000199100
000000000000000000000000000000000000000000000000000000000000000000000000000000009a9a44440000000000000000000000000000000001494111
00000000000000000000000000000000000771000000000000000000000771000007710000077100000000000000000000000000000000000000000001991991
00000000000000000000000000000000000771000000000000000000000771000007710000777700022222200077700000000000000000000000000014941991
00000000000000000000000000000000000771000000000000000000000771000007710007777770022222210777770000000000000000000000000019911111
00000000000000000000000077777777000771000000777777770000000777777777710007777771022222217777777700000000000000000000000011110000
00000000000000000000000077777777000771000007777777777000000077777777100007777771071111717777777700000000000000000000000000000000
00000000000000000000000011111111000771000007711111177100000001111111000000777710071000711777771100000000000000000000000000000000
00000000000000000000000000000000000771000007710000077100000000000000000000077100071000710077710000000000000000000000000000000000
00000000000000000000000000000000000771000007710000077100000000000000000000077100001000010001100000000000000000000000000000000000
00111100001111000111111000000000000881000000000000000000000881000008810000088100000000000000000000000000000000000000000000000000
01777710017777100177771000000000000881000000000000000000000881000008810000888800033333300088800000000000000000000000000000000000
19aaaa9119aaaa9101aaaa1000000000000881000000000000000000000881000008810008888880033333310888880000000000000000000000000000000000
17a11aa117a11aa101aaaa1088888888000881000000888888880000000888888888810008888881033333318888888800000000000000000000000000000000
1aa111111aa11aa1019aa91088888888000881000008888888888000000088888888100008888881071111718888888800000000000000000000000000000000
1aa111111aa11aa1019aa91011111111000881000008811111188100000001111111000000888810071000711888881100000000000000000000000000000000
19919991199119910149941000000000000881000008810000088100000000000000000000088100071000710088810000000000000000000000000000000000
19919991199119910019910000000000000881000008810000088100000000000000000000088100001000010001100000000000000000000000000000000000
19911991199119910011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14999941149999410019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01499410014994100019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100001111000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1000000000000000000000000000000000000000000000000000000000000000000000383700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000272827280000000000000027280000000000000000191a1b0000000000000000263a3936263600003837000026360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1027161816172800002728002716172800191a1b0000191c2b2a1a1b192b1a1b00263a3a39393a3936263a3936263a393600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000a0b0a0b0000000000000000000000000a0c0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
200a0c0c0c0c0b000000000a0b000000000a0c0c0c0b00000a0b0a0c0c0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110c0c0c0c0c0c0b00000a0c0c0b0a0c0b0000000000000a0c0c0c0c0c0c0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
300c0c0c0c0c0c0c0b0a0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3114290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12333d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22333b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32233b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32233b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13233b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13233b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13233b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d5d3d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c20000000000000000000000b600da0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d40000000000000000cf00000000d40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d7d600000000000000df000000d5d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00da0000000000d5d600d5d3d6da000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d7d600d5d3dbd8da00da00d9d4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d7dad8000000d7d3d800d7d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010200000c3100c3300c3400c3500c3600c3600c3600c3600c3600c3740c3700c3700c330133000b3000430002300280002600023000210001f0001c0001a000180001600014000110000e0000b0000800006000
00070000300750c30530055243003002524300300150d100240000030024000243002400000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
010200080c67514000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d6700f0700a0700507004070010700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003337324373371033710537103371033710337105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001a4101a420194301744013430114301043010430104301042010420104201042010420104201042010420104201042010420104101041010410104101041010410104101041010410104101041000000
000a0000184401d44021440184301d43021430184201d42021420184101d410214100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002207022010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002b0702b0702b0702b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c77009750077400673004720047200601008010090100a03007040040200102000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002433031430243103141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c37010300103700e370113020e3700e3051137011304103700e370103000c370103000e3700c300103700c300113700c30010370103000e370103001037011300103700e3700e3000c3700c3000c370
010c00001f1301f13529130291352b1302b1351f1301f1352b1302b135221302213529130291352b1302b1351f1301f13529130291352b1302b135221302213521130211351d1301d1351a1301a1351d1301d135
001000000000000000000003067500600000000c60524605000000000030675000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c5531f735137551f7250c5531f700137551f7000c5530c303137551f7050c5530070213755007020c5530070213755007020c5530070213755007020c5530070213755007020c553007021375500702
010c00000c5531370513755137050c5531f700137551f7000c5530c303137551f7050c553007021375500702183530c50318353001020c55300702183530070218353007020c5530070218353185031835318353
010c00000c553137550c6151375518353137550c615137550c553137550c6151375518353137553c615137550c553137550c6151375518353137550c615137550c553137550c6151375518353137553c61513755
010c00000745507405074550740513452134520745513405074550740513452134521345213402074553c60513452134520745524605074550000013452134520745507405074550740513452134521345213452
010c00000c5530f7550c6150f755183530f7550c6150f7550c5530f7550c6150f755183530f7553c6150f7550c553117550c6151175518353117550c615117550c553117550c6151175518353117553c61511755
010c0000034550740503455074050f4520f452034551340503455074050f4520f4520f45213402034553c6050545507405054550740511452114520545513405054550740511452114521145213402054553c605
010c00000c2021f2021f2501f25526250262551f2501f25524250242551f2501f25522250222551f2501f255212502125522250212501f2501f25521250212551f202002021d2501d2551f2501f2552125021255
010c00000c5530f7050c6150f705183530f7050c6150f7050c5530f7050c6150f705183530f7053c6150f7050c5530f7050c6150f705183530f7050c6150f7050c5530f7050c6150f705183530f7053c6150f705
010c00000f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f755
010c00002425024250242502425522250222552125021255000000000021250212552225022255242502425524250242502425024255262502625526250262502625026250262502625526250262502625026255
010c00000e7500e7550e7500e7550e7500e7550e7500e7550e7500e7550e7500e7550e7500e7550e7500e75513750137551375013755137501375513750137551375013755137501375513750137551375013755
010c00002725027250272502725522250222552225022250222502225022250222552725027250272502725529250292502925029255242502425524250242502425024250242502425529250292502925029255
010c00000f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f7550f7500f75511750117551175011755117501175511750117551175011755117501175511750117551175011755
010c00002a2502a2502a2502a25525250252552525025250252502525025250252552a2502a2502a2502a2552b2502b25526250262552b2502b2552c2502c25527250272552c2502c2552d2502d2552825028255
010c00001275012755127501275512750127551275012755127501275512750127551275012755127501275513750137551375013755137501375514750147551475014755147501475515750157551575015755
010600002d2502d2502d2502d2552e2502e2502e2502e255292502925029250292552e2502e2502e2502e25532250322553325033255352503525536250362553725037255382503824038230382203821038205
010c00000c5530f7050c6150f705183530f7050c6150f7050c5530f7050c6150f70518353183531835318353183030000000000000000c605000001830300000183030c503183030000018303000001830300000
010c000015750157551675016755167501675516750167550e7400e7400e7300e7300e7200e7200e7100e7150e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e700
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
00 0c 0e 43 44
00 0c 0f 43 44
01 0c 10 11 44
00 0c 12 13 44
00 0c 10 11 44
00 0c 12 13 44
00 14 15 16 44
00 17 15 18 44
00 19 15 1a 44
00 1b 15 1c 44
02 1d 1e 1f 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
