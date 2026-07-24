pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- acceler-8
-- – bright moth games

-- –„‘“˜”ˆŽ
-- €’ƒ…†‡‰Š‹
-- ™—‚•Œ

-- todos:
-- race results

need_init = true
pi = 3.14159
showperf = false
roadsettings = {
	max_height = 150,
	max_curve = 120,
	zonecount = 56,
	zone_size = 256,
	seg_size = 4,
	segspercolour = 4,
	roadwidth = 128,
	roadwidth_h = 64
}
cartdata("bmg_acceler_8")
sspos_m = 0x000f.ffff
ssflip_m = 0x4000.0000
ssid_m = 0x0ff0.0000
ssshift_m = 0x2000

options = {"start", "bike", "region"}
optidx = 1

optdetails = {}

selectedzone = nil

finished = false
ontitle = true
startup = false
dof = 88
camh = 64
camd = 64
roadoffset = 256

titleframe = 0
fliplight = false
renderheight = camh
lastdelta = 0
absidx = 1
lastsegidx = 1 + dof
playerseg = {}
lastproj_h = 0
last_o = false
last_x = false
lastspeed = 0
last_accrate = 0
skidding = false

endidx = 0

sprites = {} -- table of sprite data
roadsprites = {} -- sprite positions
regions = {}
road = {}
cars = {}
racers = {}
carmeta = {}
racermeta = {}
racemeta = {}
speedstring = "000"
spritebuffer = {}
zonemeta = {}

roadbuffer = {}

curve_grades = {16, 32, 64, 96, 128}
hill_grades = {16, 32, 64, 128}
currentzone = nil
carframe = 0

tree_id = 1
cactus_id = 2
rock_id = 3
sign1_id = 4
sign2_id = 5
dangerturn_id = 6
car_id = 7
sign3_id = 8
step = 1 / 60

enginefx = nil
nextenginefx = nil

maxspeed = (roadsettings.seg_size * 2.5) / step --600
accel1 = maxspeed / 4 -- 150
accel2 = maxspeed / 8 -- 75
accel3 = maxspeed / 12 -- 50
accel4 = maxspeed / 16 -- 37.5
lastx = 0

player = {
	speed = 0,
	scaledspeed = 0,
	x = 0,
	pos = 0,
	poshi = 0,
	maxspeed = maxspeed,
	accel = maxspeed / 12,
	decel = -maxspeed / 10,
	brake = -maxspeed /4,
	ordecel = -maxspeed / 2,
	ormax = maxspeed / 4,
	z = 2,

	-- rendering members
	hittime = 0,
	bikey = 113,
	bikex = 60,
	scale = 1,
	braking = false,
	left = false,
	turn = false,
	turntime = 0,
	frm = 0,
	wheelfrm = 0,
	frmtime = 0,
	frmrate = 9999,
	onhill = false,
	frmmax = 2,
	wheeloffset = 0,
	skidding = false,
	pole = 8
}

racercoloridx = 6

playercolors = {0xa912.db3a, 0xed16.b82e, 0xd29a.9229, 0xb3dc.da9b, 0x6dec.e6de, 0xf91d.2cdf}
pctext = {"green machine", "crimson flash", "the hornet", "yellow devil", "tiburon", "sky chaser"}

--sfx
--8 accel
--9 decel
--10 light brake
--11 heavy brake
--12 crunch
--13 tires

-- bike classes
-- motogp 1000cc 224mph (361kph)
-- moto2 600cc 174mph (280kph)
-- moto3 250cc 152mph (244kph)

function _init()
	pcolidx = dget(8) + 1
	local tree, cactus, rock, sign1, sign2, dangerturn, car, sign3 = {
		x = 16,
		y = 32,
		dw = 16,
		dh = 32,
	}, {
		x = 32,
		y = 32,
		dw = 16,
		dh = 16,
	} , {
		x = 48,
		y = 32,
		dw = 8,
		dh = 8,
	} , {
		x = 0,
		y = 32,
		dw = 8,
		dh = 16,
	} , {
		x = 8,
		y = 32,
		dw = 8,
		dh = 16,
	} , {
		x = 64,
		y = 32,
		dw = 8,
		dh = 8,
	} , {
		x = 104,
		y = 8,
		dw = 24,
		dh = 24,
	} , {
		x = 0,
		y = 48,
		dw = 8,
		dh = 16,
	}

	menuitem(5, "show performance", function() showperf = not showperf end)

	add(sprites, tree)		-- 1
	add(sprites, cactus)	-- 2
	add(sprites, rock)		-- 3
	add(sprites, sign1)		-- 4
	add(sprites, sign2)		-- 5
	add(sprites, dangerturn)-- 6
	add(sprites, car)		-- 7

	local desert, hills, woods = {
		name = "desert",
		sprite_id = cactus_id,
		rock_id = rock_id,
		field = 0xf9,
		alt = 0x9f,
		duskfield = 0x00,
		duskalt = 0x00,
		nightfield = 0x00,
		nightalt = 0x00,
		edge = 10,
		edgealt = 0xA9,
		mask = 0b0101101001011010,
		altmask = 0,
		curvechance = .80,
		hillchance = .80,
		windchance = .25,
		rollchance = .45
	}, {
		name = "hills",
		hillchance = .90,
		curvechance = .65,
		windchance =.15,
		rollchance = .25,
		sprite_id = tree_id,
		rock_id = rock_id,
		field = 0x3b,
		alt = 0xbb,
		duskfield = 0x00,
		duskalt = 0x00,
		nightfield = 0x00,
		nightalt = 0x00,
		edge = 4,
		edgealt = 0x43,
		mask = 0b0101101001011010,
		altmask = 0
	}, {
		name = "woods",
		sprite_id = tree_id,
		rock_id = tree_id,
		curvechance = .75,
		hillchance = .65,
		windchance = .40,
		rollchance = .10,
		field = 0x34,
		alt = 0x35,
		duskfield = 0x00,
		duskalt = 0x00,
		nightfield = 0x00,
		nightalt = 0x00,
		edge = 4,
		edgealt = 0x43,
		mask = 0b1010010110100101,
		altmask = 0b1010010110100101
	}

	add(regions, woods)
	add(regions, hills)
	add(regions, desert)
	music(15)
	setuprace()
end

function _update60()
	nextenginefx = nil
	local nextoffset = 0
	local accel_rate = 0
	if (ontitle) then
		if(btnp(4) or btnp(5)) then
			if(optidx != 1) then 
				optidx = 1 
				return
			end
			sfx(39)
			titleframe = 10
			startup = true
			if(finished or (selectedzone and currentzone != selectedzone)) resetgame()
			racercoloridx = pcolidx + flr(1 + rnd(#playercolors))
			if(racercoloridx > #playercolors) racercoloridx -= #playercolors
			music(-1, 1000)
			roadoffset = 256
		else
			titleframe += 1
			if(startup and titleframe > 48) titleframe = 0 ontitle = false return
			if(btnp(0)) optidx -= 1 sfx(40)
			if(btnp(1)) optidx += 1 sfx(40)
			if(optidx > #options) optidx = 1
			if(optidx < 1) optidx = #options
			
			if(optidx == 2) then
				if(btnp(2)) pcolidx -= 1 sfx(40)
				if(btnp(3)) pcolidx += 1 sfx(40)
				if(pcolidx > #playercolors) pcolidx = 1
				if(pcolidx < 1) pcolidx = #playercolors
				dset(8, pcolidx - 1)
			elseif(optidx == 3) then
				if(selectedzone == nil) selectedzone = currentzone
				if(btnp(2)) selectedzone -= 1 sfx(40)
				if(btnp(3)) selectedzone += 1 sfx(40)
				if(selectedzone > #regions) selectedzone = 1
				if(selectedzone < 1) selectedzone = #regions
			end
			
			return
		end
	end	
	
	if (startup) then
		updatestart()
		updateplayerposition()
		updateracers()
		updateroad()
		return
	end

	carframe += 1
	if (carframe > 2) carframe = 0

	lastspeed = player.speed
	player.braking = false
	player.skidding = false
	player.onhill = false
	player.uphill = false
	
	local nextsegidx = (absidx + 1)
	if (nextsegidx > #road) nextsegidx = 1
	
	if (abs(lastdelta) >= 64) then
		if (player.speed > player.ormax) accel_rate = player.ordecel --accelerate(player, player.ordecel)
		nextenginefx = 15
	end
	
	local turnrate = step * 96 * (.5 + -sin((player.speed / maxspeed) * .5))
	if(absidx < endidx and btn(0) and player.speed > 0) then
		if(not player.turn or (player.turn and not player.left)) player.turntime = 0
		turnrate *= 0xffff
		player.turn = true
		player.left = true
		player.turntime += 1
	elseif(absidx < endidx and btn(1) and player.speed > 0) then
		if(not player.turn or (player.turn and player.left)) player.turntime = 0
		player.turn = true
		player.left = false
		player.turntime += 1
	else
		turnrate = 0
		resetturn(player)
	end
	
	local zidx = 1 + flr(absidx / roadsettings.zone_size)
	if(zidx > #zonemeta) zidx -= #zonemeta
	local z = zonemeta[zidx]
	local gstart = false
	if(z.isbarrier) then
		if(lastx <= 72 and lastdelta > 72) then
			gstart = true
			turnrate = min(turnrate, 72 - lastdelta)
			lastdelta = 72 
			resetturn(player)
		elseif(lastx >= -66 and lastdelta < -66) then
			gstart = true
			turnrate = max(turnrate, -66 - lastdelta)
			lastdelta = -66 
			resetturn(player) 
		end
	end

	if(not grinding and gstart) then
		grinding = true 
		sfx(16, 2)
		if(abs(lastdelta) - abs(lastx) >= 2) sfx(12, 1)
	elseif(grinding and not gstart) then 
		grinding = false
		sfx(-2, 2) 
	end
	
	player.x += turnrate

	local curvemag = z.curve / roadsettings.zone_size * (4 * player.speed / player.maxspeed)
	
	if (absidx >= endidx ) player.x += curvemag
	if (player.turn and player.turntime > 36 and turnrate <= abs(curvemag)) then
		nextenginefx = 13
		accelerate(player, -.06)
		player.skidding = true
	end
	
	local cur_o, cur_x = btn(4), btn(5)
	
	if(cur_x) then
		player.braking = true
		accel_rate += player.brake	--accelerate(player, player.brake)
	end
	
	if(cur_o or absidx >= endidx) then
		local accrate = 0
		if(player.speed <= accel4) then accrate = accel1
		elseif(player.speed <= accel2) then accrate = lerp(accel2, accel3, (accel2 - player.speed) / accel2)
		elseif(player.speed < accel1) then accrate = lerp(accel3, accel4, (accel1 - player.speed) / accel1)
		else accrate = accel4 end
		accel_rate += accrate--accelerate(player, accrate)
	else
		accel_rate += player.decel--accelerate(player, player.decel)
	end
	
	accelerate(player, accel_rate)

	local moving = player.speed > 0
	-- tick 1/128 = .00781
	-- step 1/60 =  .01667
	if(accel_rate > 0) then nextenginefx = 8
	else nextenginefx = 9 end

	if(player.speed == 0) then
		if(lastspeed != 0) enginefx = nil
		nextenginefx = 9
		nextoffset = 16
	elseif(accel_rate > 0 and accel_rate != last_accrate) then
		local rate = convertspeedtosfxtick(accel_rate)
		setspeed(rate)
		nextoffset = flr(16 * (player.speed / player.maxspeed))
		enginefx = nil
		printh("accrate increase " .. accel_rate .. " sfx speed " .. rate .. " offset " .. nextoffset)
	elseif(accel_rate < 0 and accel_rate != last_accrate) then
		local rate = convertspeedtosfxtick(accel_rate)
		setspeed(rate, 1)
		nextoffset = flr(16 - (16 * (player.speed / player.maxspeed)))
		nextenginefx = 9
		enginefx = nil
		printh("accrate increase " .. accel_rate .. " sfx speed " .. rate .. " offset " .. nextoffset)
	end

	local lastidx, lso = absidx, playersegoffset

	updatebike(player)
	addvel(player.speed, player)
	
	--player.pos += player.speed
	updateplayerposition()
	--if(player.pos < 0) player.pos += #road
	--if(absidx != lastidx or playersegoffset != lso or lastdelta != lastx) updateroad()
	updateroad()
	
	
	local sidx = absidx + 1;
	--if(flr(playersegoffset) > 0) sidx += 1
	if(absidx < endidx) then
		if(roadsprites[sidx]) then
			local sp, scale, left, right, seg = unstuffsprite(roadsprites[sidx]), 1.5 * roadbuffer_at(sidx).currscale, player.bikex,  player.bikex + 8, road[sidx]
			local s, sleft = sprites[sp.sid], projectposition(sp.pos, scale) + getsegoffset(seg.curve, scale)
			local sright = sleft + scale * s.dw
			local misses = (left > sright or right < sleft)
			if(not misses) then
				-- hit!
				sfx(12)
				player.speed = 0
				player.hittime = 12
				addvel(-roadsettings.seg_size / step, player) -- bump back a segment
			end
		end
	end

	speedstring = flr(player.scaledspeed * .62137)
	if(speedstring < 10) then speedstring = "00"..speedstring
	elseif(speedstring < 100) then speedstring="0"..speedstring end
	
	updatecars()
	updateracers()
	
	last_o = cur_o
	last_x = cur_x
	last_accrate = accel_rate
	if(nextenginefx != enginefx) then
		sfx(-1, 3)
		if(not nextenginefx) then
			enginefx = nil
			return
		end
		
		enginefx = nextenginefx
		sfx(enginefx, 3, nextoffset)
		printh("playing " .. enginefx .. " at offset " .. nextoffset)
	end
end

function resetturn(obj)
	obj.turn = false
	obj.left = false
	obj.turntime = 0
end

function resetgame()
	player.pos = 0
	player.poshi = 0
	player.x = 0
	lastdelta = 0
	player.speed = 0
	player.pole = 8
	speedstring = "000"
	absidx = 0
	roadoffset = 256
	finished = false
	player.scale = 1
	racers = {}
	road = {}
	cars = {}
	roadsprites = {}
	zonemeta = {}
	roadbuffer = {
		start = 0,
		fin = 0
	}
	carmeta = {}
	racermeta = {}
	setuprace()
end

function setuprace()
	roadspritecnt = 0
	if(selectedzone == nil) then currentzone = flr(1 + rnd(3))
	else currentzone = selectedzone end
	selectedzone = nil
	generateroad()
	local carcount = 15 + flr((roadsettings.zonecount * .85) + rnd(roadsettings.zonecount * .5))
	for i = 1, carcount, 1 do
		addcar(32 + flr(rnd((roadsettings.zonecount * roadsettings.zone_size) - 31)))
	end
	
	endidx = #road - 4 - dof
	initracers()
	playerseg = road[1]
	updateplayerposition()
	updateroad()
	
	printh("spawned " .. #cars .. " cars")
	printh("generated " .. #road .. " road segments")
	printh("sprites: " .. #sprites)
	printh("regions: " .. #regions)
	printh("road sprites: " .. roadspritecnt)
	printh("post generation memory: " .. stat(0))
end

function updatebike(biker)
	if(biker.hittime > 0) biker.hittime -= 1
	biker.frmtime += 1
	biker.speed = mid(0, biker.speed, biker.maxspeed)
	biker.scaledspeed = flr(biker.speed / 2)
	local speedmag = abs(biker.scaledspeed)
	
	if(biker.frmtime > biker.frmrate and biker.speed < 0) then biker.wheelfrm -= 1 biker.frmtime = 0
	elseif(biker.frmtime > biker.frmrate) then biker.wheelfrm += 1 biker.frmtime = 0 end
	
	if(speedmag <= 0) then biker.frmrate = 9999
	elseif(speedmag <= 25) then biker.frmrate = 10
	elseif(speedmag <= 45) then biker.frmrate = 8
	elseif(speedmag <= 95) then biker.frmrate = 6
	elseif(speedmag <= 105) then biker.frmrate = 4
	else biker.frmrate = 2 end
	
	if(biker.speed > 220) then biker.wheeloffset = 5 biker.frmmax = 1
	elseif(biker.speed >= 160) then biker.wheeloffset = 3 biker.frmmax = 1
	else biker.wheeloffset = 0 biker.frmmax = 2 end
	
	if(biker.wheelfrm > biker.frmmax) biker.wheelfrm = 0
	if(biker.wheelfrm < 0) biker.wheelfrm = biker.frmmax
end

function updatestart()
	titleframe += 1
	if(titleframe <= 72) then roadoffset = 256 - (256 * (titleframe / 72))
	else roadoffset = 0 end
end

function drawstart()
	local offs = 0
	if(titleframe < 72) return
	if(titleframe <= 88) offs = 75 * ((88 - titleframe) / 16)
	if(titleframe == 104) sfx(17)
	drawsignal(offs)
	
	if(titleframe >= 248) then
		startup = false
		roadoffset = 0
		music(0)
	end
end

function drawsignal(offs)
	rectfill(62, -1, 64, 29 - offs, 5)
	rectfill(65, -1, 66, 29 - offs, 6)
	pal(15, 0)
	map(7, 25, 52, 29 - offs, 3, 6)
	pal()
	
	if(titleframe > 104)pal(5, 8) pal(6, 14)
	spr(143, 60, 34 - offs, 1, 1)
	pal()
	
	if(titleframe >= 152) pal(5, 8) pal(6, 14)
	spr(159, 60, 44 - offs, 1, 1)
	pal()
	
	if(titleframe >= 200) pal(5, 9) pal(6, 10)
	spr(159, 60, 54 - offs, 1, 1)
	pal()
	
	if(titleframe >= 248) pal(5, 11) pal(6, 7)
	spr(175, 60, 64 - offs, 1, 1)
	pal()
end

function drawspeednum(number, x, y)
	local top, bottom
	
	-- top
	if(number == 0 or number == 7) then top = 160
	elseif(number == 2 or number == 3) then top = 162
	elseif(number == 5 or number == 6) then top = 163
	elseif(number == 8 or number == 9) then top = 165
	else top = 161 end -- 1, four is a total exception 
	
	-- bottom
	if(number == 1 or number == 7) then bottom = 177
	elseif(number == 2) then bottom = 178
	elseif(number == 3 or number == 5 or number == 9) then bottom = 179
	elseif(number == 6 or number == 8) then bottom = 181
	else bottom = 176 end -- 0, four is the exception
	
	if(number == 4) then
		top = 164
		bottom = 180
	end
	
	spr(top, x, y, 1, 1, tfliph)
	spr(bottom, x, y + 8, 1, 1, bfliph)
end

function _draw()
	cls(12)
	local cloudoffset = (playerseg.curve * -.025) % 8
	local cloudtop = 40
	map(0, 19, -8 + cloudoffset, cloudtop, 17, 2)
	rectfill(0, cloudtop + 16, 128, cloudtop + 29, 7)

	if(nextzone != nil and nextzone != currentzone) then
		currentzone = nextzone
		nextzone = nil
	end
	
	if(regions[currentzone].name == "woods") then
		pal(11, 4)
		pal(3, 5)
	elseif(regions[currentzone].name == "desert") then
		pal(11, 15)
		pal(3, 9)
	end
	
	mapheight = 30
	local mapoffset = playerseg.curve * -.15
	if(currentzone == 2) then map(0, 13, -98 + (mapoffset * 2), mapheight + 24, 38, 2)
	else map(0, 0,  -36 + mapoffset, mapheight, 25, 5) end
	pal()
	fillp(regions[currentzone].mask)
	rectfill(0, mapheight + 40,  128, 94, regions[currentzone].field)
	fillp()
	drawroad()
	
	if(ontitle) then
		drawtitle()
		return
	end
	
	drawbike(player, playercolors[pcolidx])
	
	drawhud()
	if(startup) then
		drawstart()
		return
	end
	
	if(absidx < 20) drawsignal(player.pos * 2)
	--setnightpal()
	drawperf()
end

function drawhud()
	local offs = 0
	if(startup) then
		if(titleframe < 72) return
		if(titleframe <= 104) offs = 64 * ((104 - titleframe) / 32)
	end
	-- speedometer
	map(0, 27, 0 - offs, -3, 7, 4)
	print("speed", 9 - offs, 2, 7)
	print("pos", 37 - offs, 2, 7)
	drawspeednum(tonum(sub(speedstring,1,1)), 8 - offs, 9)
	drawspeednum(tonum(sub(speedstring,2,2)), 16 - offs, 9)
	drawspeednum(tonum(sub(speedstring,3,3)), 24 - offs, 9)
	pal(3, 4)
	pal(11, 9)
	drawspeednum(player.pole, 39 - offs, 9)
	pal()

	-- position tracker
	map(0, 25, 74, 5, 6, 2)
	local pos = renderidx / endidx * 43
	spr(208, 74 + pos, 5, 1, 1)
end

function drawbike(obj, colset)
	local offset, hitoffset = 0, 0
	setbikepal(colset)
	setbikerpal(colset)

	if(obj.turntime >= 30) then
		if(obj.hittime > 4 or obj.onhill) then hitoffset = 1 end
		--elseif (obj.uphill) then hitoffset = -1 end
		
		-- hard turn frames
		offset = (4 * obj.scale) -- hitoffset
		local woffset = 1 + hitoffset
		if(obj.left) offset *= 0xffff woffset *= 0xffff
		zspr(hitoffset == 1 and 55 or 32, 1, 1, obj.bikex + offset, obj.bikey + (3 * obj.scale) + hitoffset, obj.scale, obj.left)
		zspr(2 + obj.wheelfrm + obj.wheeloffset + 16, 1, 1, obj.bikex + woffset, obj.bikey + (6 * obj.scale), obj.scale, obj.left)
		pal()

		if(obj.braking) zspr(36, 1, 1, obj.bikex + woffset, obj.bikey  + (6 * obj.scale) + hitoffset, obj.scale, obj.left)
	else
		-- rider sprite
		obj.frm = 0
		if(obj.hittime > 0 or (obj.onhill and obj.speed != 0)) obj.frm = 1
		if(obj.turn) offset = 16
		zspr(obj.frm + offset, 1, 1, obj.bikex, obj.bikey, obj.scale, obj.left)
		
		-- wheel sprite
		offset = 0
		hitoffset = 0
		if(obj.hittime > 4 or obj.onhill) then hitoffset = -1
		elseif (obj.uphill) then hitoffset = 1 end

		-- stopped.
		local wf = 2 + obj.wheelfrm + obj.wheeloffset
		if (obj.speed == 0) then wf = 33
		elseif (obj.turn) then offset += 7 end

		zspr(wf + offset, 1, 1, obj.bikex, obj.bikey + hitoffset + (7 * obj.scale), obj.scale, obj.left)
		pal()

		if(obj.braking and obj.speed < 0) then
			zspr(35, 1, 1, obj.bikex, obj.bikey + hitoffset + (5 * obj.scale), obj.scale)
		elseif(obj.braking) then
			zspr(34, 1, 1, obj.bikex, obj.bikey + hitoffset + (5 * obj.scale), obj.scale)
		end
	end
	if(obj.skidding) then
		local x = obj.bikex - (1 * obj.scale)
		if(obj.left) x = obj.bikex + (1 * obj.scale)
		zspr(48 + (obj.wheelfrm % 2), 1, 1, x, obj.bikey  + (6 * obj.scale), obj.scale)
	end
	pal()
end

-- randomly generate the road
function generateroad()
	local current_state_h, transitions, current_state_c, current_height, current_curve, zones, chance = 0, {{0,1,2},{0,2,2},{0,1,1}}, 0, 0, 0, 0
	region = regions[currentzone]
	local bumpy, deep, windy = false, false, false

	
	while(zones < roadsettings.zonecount) do
		if(zones == flr(roadsettings.zonecount * .5)) then
			currentzone += 1 + flr(rnd(#regions - 1))
			if(currentzone > #regions) currentzone -= #regions
		end
		
		local zoneheight, hillmax = 0, 4  
		if(bumpy) hillmax = 3
		if(current_state_h == 1) then
			zoneheight = hill_grades[1 + flr(rnd(hillmax))]
		elseif(current_state_h == 2) then
			zoneheight = -hill_grades[1 + flr(rnd(hillmax))]
		end
		
		local zonecurve, curvemin, curvemax = 0, 3, 5
		if(windy) curvemax = 3 curvemin = 2
		if(current_state_c == 1) then
			zonecurve = curve_grades[curvemin + flr(rnd(1 + curvemax - curvemin))]
		elseif(current_state_c == 2) then
			zonecurve = -curve_grades[curvemin + flr(rnd(1 + curvemax - curvemin))]
		end
		
		local curvemag, z = abs(zonecurve), {
			region = currentzone,
			hill = zoneheight,
			curve = zonecurve,
			scurve =  windy,
			startx = current_curve,
			starty = current_height,
			endx = current_curve + zonecurve,
			endy = current_height + zoneheight,
		}
		if(curvemag >= 128) z.isbarrier = true
		add(zonemeta, z)
		
		for i = 1, roadsettings.zone_size, 1 do
			local pct = (i / roadsettings.zone_size)

			local seg = {
				height = current_height,
				curve = current_curve + zonecurve * easeinoutsine(pct),
				region = currentzone
			}
			
			if(zoneheight != 0) then
				if(deep) then
					seg.height = current_height + zoneheight * easeinoutsine(pct)
				elseif(bumpy) then 
					seg.height = easeinout(current_height, current_height + zoneheight, pct * 3)
				else
					seg.height = easeinout(current_height, current_height + zoneheight, pct)
				end
			end

			if(windy) then 
				seg.curve = easeinout(current_curve, current_curve + zonecurve, pct) 
			end
			
			if(curvemag >= 128) then
				seg.isbarrier = true
			end
			if(rnd(1) < .10) then
				local sid, pos, flip, shift = regions[currentzone].sprite_id, .6 + 4 * rnd(1), false, false

				if(rnd(1) < .80) sid = regions[currentzone].rock_id
				if(rnd(1) < .5) shift = true
				if(rnd(1) < .5) flip = true

				roadsprites[(zones * roadsettings.zone_size) + i] = stuffsprite(pos, sid, flip, shift)
				roadspritecnt += 1
			end
			
			add(road, seg)
		end

		if(not windy) current_curve += zonecurve
		if(deep) current_height += zoneheight
		bumpy = false
		windy = false
		deep = false
		
		-- determine the next hill/curve
		local cstate = transitions[current_state_h + 1]
		
		if(rnd(1) <= region.hillchance) then
			current_state_h = 1
			if(rnd(1) >= .5) current_state_h = 2
			if(rnd(1) < region.rollchance) then bumpy = true
			elseif(rnd(1) < .5) then deep = true end
		else
			current_state_h = cstate[1]
		end
		
		state = transitions[current_state_c + 1]
		if(rnd(1) <= region.curvechance) then
			current_state_c = 1
			if(rnd(1) >= .5) current_state_c = 2
			local chance = rnd(1)
			if(chance < region.windchance) windy = true
		else
			current_state_c = cstate[1]
		end
		
		-- go back and place road sign
		local mag = abs(zonecurve)
		if(zones > 0 and (zonemeta[zones].windy or curvemag >= 32)) then
			local idx = roadsettings.zone_size * (zones-1) + flr(roadsettings.zone_size * .75) + 1
			local zidx = (idx)
			local seg = road[idx]
			local pos, id, shift, flip = .64, sign1_id, true, false

			if(zonemeta[zones].windy) then id = sign3_id
			elseif(curvemag > 64) then id = sign2_id end

			if(zonecurve < 0) flip = true shift = false
			if(not roadsprites[zidx]) roadspritecnt += 1
			
			roadsprites[zidx] = stuffsprite(pos, id, flip, shift)
		end
		
		zones+=1
	end
	for i=0, dof, 1 do
		add(roadbuffer, {})
	end
end

function stuffsprite(pos, id, flip, shift)
	--pos = 0x800f.ffff; shift = 0x8000.0000; flip = 0x4000.0000; id = 0x0ff0.0000
	local sp = pos
	sp = bor(shl(id, 4), sp)
	if(flip) sp = bor(sp, ssflip_m)
	if(shift) sp = bor(sp, ssshift_m)
	return sp
end

function unstuffsprite(segsprd)
	local sp = {
		pos = band(segsprd, sspos_m),
		sid = shr(band(segsprd, ssid_m), 4),
		flip = false
	}
	if(band(segsprd, ssflip_m) == ssflip_m) sp.flip = true
	if(band(segsprd, ssshift_m) == ssshift_m) sp.pos *= 0xffff
	return sp
end

function initracers()
	local halfmax, absmax, posoffset, row = maxspeed * .5, maxspeed * .9, 16, 0
	for i=0, 6, 1 do
		local racer = {
			offset = -.33333,
			pos = row * posoffset,
			poshi = 0,
			maxspeed = min(halfmax + (i + 2) / 9 * halfmax, absmax),
			speed = 0,
			scaledspeed = 0,
			bikey = 113,
			bikex = 60,
			scale = 1,
			braking = false,
			left = false,
			turn = false,
			turntime = 0,
			frm = 0,
			wheelfrm = 0,
			frmtime = 0,
			frmrate = 9999,
			onhill = false,
			frmmax = 2,
			wheeloffset = 0,
			skidding = false,
			hittime = 0,
			pole = 8
		}

		if(i % 2 == 1) row += 1 racer.offset = .33333
		add(racers, racer)
	end
end

function getsegindex(obj)
	local res,ss = {}, roadsettings.seg_size
	if(obj.pos == 32767.99999) then
		local poshi,poslo = obj.poshi / ss, obj.pos / ss + 1
		
		local offshi, offslo = obj.poshi % ss, obj.pos % ss
		res.segoffset = (offshi + offslo) % ss
		res.index = flr(poslo + poshi)
	else
		res.segoffset = obj.pos % ss
		res.index = flr(obj.pos / ss) + 1
	end
	
	return res
end

function updateplayerposition()
	absidx = 0
	playersegoffset = 0
	local result = getsegindex(player)
	absidx = result.index
	playersegoffset = result.segoffset
	playerseg = road[absidx]
	
	if(absidx >= endidx) then
		if(absidx >= roadbuffer.fin) then
			--race over!
			titleframe = 0
			ontitle = true
			finished = true
			sfx(-1, 3)
			music(15, 250)
		else
			music(-1, 250)
			renderidx = endidx
			seg = roadbuffer_at(result.index)
			local pct = playersegoffset / roadsettings.seg_size
			
			player.scale = 1.5 * lerp(seg.currscale, seg.endscale, pct)
			player.bikey = 64 + lerp(seg.stproj_h, seg.endproj_h, pct) - 16 * player.scale
			player.bikex = projectposition(lastdelta / 128, player.scale, 4) + getsegoffset(road[result.index].curve, player.scale)
		end
	else
		renderidx = absidx + flr((roadoffset / roadsettings.seg_size))
		player.bikey = 113 + roadoffset
		player.bikex = 60
	end
	
	if(renderidx > #road) renderidx -= #road
	if(renderidx < 1) renderidx += #road
end

function updatecars()
	carmeta = {}
	for i=#cars, 1, -1 do
		local car = cars[i]
		addvel(car.speed, car)
		local res = getsegindex(car)
		if (res.index > #road) then
			-- loop the cars around
			local pos = res.index - #road
			car.poshi = 0
			car.pos = (pos * roadsettings.seg_size + res.segoffset)
			res = getsegindex(car)
		end
		
		
		if(res.index >= roadbuffer.start and res.index <= roadbuffer.fin) then
			if(carmeta[res.index] == nil) carmeta[res.index] = {}
			local segmeta = roadbuffer_at(res.index)
			car.scale = lerp(segmeta.currscale, segmeta.endscale, (res.segoffset / roadsettings.seg_size))
			local s = sprites[car_id] 
			local  w, sh = s.dw * car.scale, s.dh
			local y, ymax = 64 + lerp(segmeta.stproj_h, segmeta.endproj_h, (res.segoffset / roadsettings.seg_size)), 64 + segmeta.lastproj_h
			car.pole = roadbuffer.fin - res.index
			car.x = projectposition(car.offset, car.scale) + getsegoffset(road[res.index].curve, car.scale) - w / 2
			car.desty = y - sh * car.scale

			local h = sh
			if(ymax < y) h = min(sh * (ymax - car.desty) / (sh *(1 * car.scale)), sh)
			if(h > 0 and car.x < 128 and car.x + w > 0) add(carmeta[res.index], i)

			if(absidx < endidx and (res.index == absidx or res.index == absidx + 1)) then
				local left = player.bikex + 1
				local right, seg, s, sleft = left + 6, road[sidx], sprites[car_id], car.x + 4
				local sright = sleft + car.scale * (s.dw) - 4
				local misses = (left > sright or right < sleft)
				if(not misses and player.speed >= car.speed) then
					-- hit!
					sfx(12)
					player.speed = car.speed * .75
					player.hittime = 12
					addvel(-roadsettings.seg_size / step, player)
				end
			end
		end
		
		if(carframe == 0) car.frame = not car.frame
	end
end

function updateracers()
	racermeta = {}
	if(absidx < endidx) player.pole = 1
		
	for i = #racers, 1, -1 do
		local racer, res = racers[i]
		racer.skidding = false
		racer.braking = false
		if(not startup) then
			accelerate(racer, player.accel)
			racer.speed = min(racer.speed, racer.maxspeed)
			addvel(racer.speed, racer)
			res = getsegindex(racer)
			if(res.index > endidx) then
				racer.finished = true
				if (res.index > #road) then
					local pos = res.index - #road
					racer.poshi = 0
					racer.pos = (pos * roadsettings.seg_size + res.segoffset)
					res = getsegindex(racer)
				end
			end
		else res = getsegindex(racer) end
		-- update bike frames
		updatebike(racer)

		-- update player pole position
		if(absidx < endidx and (racer.finished or res.index > absidx or (res.index == absidx and res.segoffset > playersegoffset))) player.pole += 1 racer.speed = min(racer.speed, maxspeed * .75)

		if(res.index >= roadbuffer.start and res.index <= roadbuffer.fin) then
			-- racer is on screen
			if(racermeta[res.index] == nil) racermeta[res.index] = {}
			local segmeta = roadbuffer_at(res.index)
			local y, scale, ymax, h = 64 + lerp(segmeta.stproj_h, segmeta.endproj_h, (res.segoffset / roadsettings.seg_size)), lerp(segmeta.currscale, segmeta.endscale, (res.segoffset / roadsettings.seg_size)), 64 + segmeta.lastproj_h, 16
			racer.bikex = projectposition(racer.offset, scale, 4) + getsegoffset(road[res.index].curve, scale)
			racer.bikey = y - 16 * scale
			
			if(ymax < y) then
				h = min(16 * (ymax - racer.bikey) / (sh * scale), 16) + 1
			end
			if(h > 0) then
				racer.scale = 1.25 * scale
				add(racermeta[res.index], i)
			end
			
			-- handle turns
			local seg = road[res.index]
			if(seg != nil) then
				local z, nextidx = zonemeta[1 + flr(res.index / roadsettings.zone_size)], res.index + 1
				if(nextidx > #road) nextidx = 1
				if(z != nil and (abs(z.curve) > 0 or seg.scurve)) then
					if(abs(z.curve) > 128) then racer.braking = true end
					racer.turn = true
					racer.turntime += 1
					if(seg.curve > road[nextidx].curve) then 
						if(not racer.left) racer.turntime = 0
						racer.left = true					
					else
						if(racer.left) racer.turntime = 0
						racer.left = false 
					end
				else
					resetturn(racer)
				end
				
				if(racer.turn and (racer.turntime > 64)) racer.skidding = true
			end

			-- check for collisions
			if(res.index == absidx + 1) then
				local left = lastdelta
				local right = lastdelta + 8
				local seg = road[sidx]
				local sleft = racer.offset * 128
				local w = 8
				if(racer.turn and racer.turntime > 36) w = 12
				local sright = sleft + racer.scale * w
				local misses = (left > sright or right < sleft)
				if(not misses and player.speed >= racer.speed) then
					-- hit!
					sfx(12)
					player.speed = racer.speed * .75
					player.hittime = 12
					addvel(-roadsettings.seg_size / step, player)
				end
			end			
		end
	end
end

function updateroad()
	lastseg = nil
	local currsegidx = renderidx
	local currsegpos = -playersegoffset
	local currentseg = road[currsegidx]
	local nextsegidx = (currsegidx + 1)
	if(nextsegidx > #road) nextsegidx = 1
	local rs,rd,rb = roadsettings,road,roadbuffer
	local nextseg = road[nextsegidx]
	
	rb.start = currsegidx
	
	local playerposrelative = playersegoffset / rs.seg_size
	renderheight = camh + currentseg.height
	if(absidx < endidx) renderheight += (nextseg.height - currentseg.height) * playerposrelative
	if(absidx > endidx) renderheight += ((absidx - endidx) * rs.seg_size + playersegoffset) * .08
	baseoffset = currentseg.curve + (road[nextsegidx].curve - currentseg.curve) * playerposrelative
	local diff = playerseg.height - nextseg.height
	if(diff >= .25) then 
		player.onhill = true
	elseif(diff <= -.25) then 
		player.uphill = true
	end
	lastx = lastdelta
	lastdelta = player.x - baseoffset * 2
	
	local stproj_h = flr((renderheight - currentseg.height) * camd / (camd + currsegpos))
	lastproj_h = stproj_h
	local minproj_h, lastmin_h = 32767--track the highest point on the road in screen coords
	local minprojidx = dof
	local iter = 0
	while (iter <= dof) do
		lastmin_h = minproj_h

		-- next segment:
		if(currentseg.region != currentzone) nextzone = currentseg.region
			
		local nextsegidx = (currsegidx + 1)
		if(nextsegidx > #rd) nextsegidx = 1
		
		local nextseg = rd[nextsegidx]
		
		stproj_h = flr((renderheight - currentseg.height) * camd / (camd + currsegpos))
		local stscale = camd / (camd + currsegpos)
		minproj_h = min(stproj_h, minproj_h)
		if(minproj_h < lastmin_h) minprojidx = iter

		local endproj_h = flr((renderheight - nextseg.height) * camd / (camd + currsegpos + rs.seg_size))
		local endscale = camd / (camd + currsegpos + rs.seg_size)

		local currheight = stproj_h
		local currscale = stscale
		
		local flags = 0
		if((currsegidx >= 17 and currsegidx <= 19) or (currsegidx >= endidx and currsegidx <= #road - dof)) flags = bor(flags, 0x01)
		if(currsegidx % (2 * rs.segspercolour) < rs.segspercolour) flags = bor(flags, 0x02)
		if(currsegidx % (6 * rs.segspercolour) < 3 * rs.segspercolour) flags = bor(flags, 0x04)
		local offset2 = getsegoffset(nextseg.curve, endscale)
		local offset1 = getsegoffset(currentseg.curve, currscale)

		local segbuf = {	
			currheight = currheight,
			nearoffset = offset1,
			faroffset = offset2,
			stproj_h = stproj_h,
			lastproj_h = lastproj_h,
			endproj_h = endproj_h,
			currscale = currscale,
			endscale = endscale,
			flags = flags
		}

		rb[iter + 1] = segbuf

		lastproj_h = currheight
		lastseg = currentseg
		lastsegidx = currsegidx
		currsegidx = nextsegidx
		currentseg = nextseg
		currsegpos += rs.seg_size
		
		iter += 1
	end
	rb.minprojidx = minprojidx
	rb.minproj_h = minproj_h
	rb.fin = currsegidx - 1
end

-- render the road and fields
function drawroad()
	local drawn,rb,l_sprites,rf,rs,l_cm,l_rm = 0,roadbuffer,sprites,rectfill,roadsprites,carmeta,racermeta
	for i = dof, 0, -1 do
		local sm = rb[i + 1]
		local sidx = i + rb.start
		local zm = zonemeta[1 + flr(sidx / roadsettings.zone_size)]
		sm.nearpos = 64 + sm.currheight
		sm.farpos = 64 + sm.endproj_h

		if(sm.currheight > sm.endproj_h) then
			drawsegment(zm.region, sm.nearpos, sm.currscale, sm.nearoffset, sm.farpos, sm.endscale, sm.faroffset, sm.flags)
			drawn += 1
		end
		local offset = getsegoffset(road[sidx].curve, sm.currscale)
		if(rs[sidx]) then
			local sp = unstuffsprite(rs[sidx])
			local sprite = l_sprites[sp.sid]
			local s = {
				sx = sprite.x,
				sy = sprite.y,
				w = sprite.dw,
				h = sprite.dh,
				scale = 1.5 * sm.currscale,
				x = projectposition(sp.pos, sm.currscale) + offset,
				y = 64 + sm.stproj_h,
				flip = sp.flip,
				ymax = 64 + sm.lastproj_h
			}
			drawroadsprite(s)
		end
		if(sidx == 18 or sidx == endidx) then
			fillp(0b0111011101110111)
			local t = 96 * sm.currscale
			local h = 32 * sm.currscale
			rf(64 + (-81 * sm.currscale) + offset, 64 + sm.stproj_h -t, 64 + (-84 * sm.currscale) + offset, 64 + sm.stproj_h, 0x56)
			rf(64 + (81 * sm.currscale) + offset, 64 + sm.stproj_h -t, 64 + (84 * sm.currscale) + offset, 64 + sm.stproj_h, 0x56)
			fillp()
			local col = 3
			if(sidx == endidx) col = 0x07 fillp(0b1100001111000011) 
			rf(64 + (-81 * sm.currscale) + offset, 64 + sm.stproj_h -t, 64 + (81 * sm.currscale) + offset, 64 + sm.stproj_h - t + h, col)
			fillp() 
		end
		
		if(zm.isbarrier and sidx % 2 == 0) then
			local sprite = l_sprites[dangerturn_id]
			local pos,flip = -.6,false
			if(zm.curve < 0) flip = true pos *= 0xffff
			local s = {
				sx = sprite.x,
				sy = sprite.y,
				w = sprite.dw,
				h = sprite.dh,
				scale = 1.5 * sm.currscale,
				x = projectposition(pos, sm.currscale) + offset,
				y = 64 + sm.stproj_h,
				flip = flip,
				ymax = 64 + sm.lastproj_h
			}
			drawroadsprite(s)
		end
		if(l_cm[sidx]) then
			for cm in all(l_cm[sidx]) do
				local c = cars[cm]
				if(c.color > 0) then
					pal(13, c.color)
					pal(2, flr(shr(c.color, 4)))
				end

				if(c.frame) then pal(4, 1)
				else pal(4, 13) end
				local car = l_sprites[car_id]
				--sspr(104, 8, 24, 24, cm.x, cm.y, 24 * c.scale, 24 * c.scale)
				-- sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y] )
				local w = flr(c.scale * 24)
				--sspr(sx, sy, sw, sh, dx, dy, dw, dh, fx, fy)
				sspr(104, 8, 24, 24, c.x, c.desty, w, w, false, false)
				--zspr(car.id, car.w, car.h, cm.x, cm.desty, c.scale)
				pal()	
			end
		end
		if(l_rm[sidx]) then
			for rm in all(l_rm[sidx]) do
				drawbike(racers[rm], playercolors[racercoloridx])
			end
		end
	end
	--printh("drew " .. drawn .. " road segments")
end

function drawroadsprite(sp)
	local sh = sp.h
	local desty = sp.y - sh * sp.scale
	local h = sh
	if(sp.ymax < sp.y) then
		h = min(sh * (sp.ymax - desty) / (sh * sp.scale), sh)
	end
	if(h > 0 and sp.x < 128 and sp.x + (sp.w * sp.scale) > 0) then
		sspr(sp.sx, sp.sy, sp.w, sh, sp.x, desty, sp.scale * sp.w, sp.scale * sp.h, sp.flip)	
	end
end

function drawsegment(region_id, nearpos, nearscale, nearoffset, farpos, farscale, faroffset, flags)
	local region = regions[region_id]
	local grass, alt, paving, stripe, edge, edgemask = region.field, region.alt, 5, 7, region.edge, 0

	local grassfill = region.mask
	
	if(flr((player.x) % 2) == 0) then
		rotr(region.mask, (player.x -lastdelta) % 1)
	end
	if(band(flags, 0x01) == 1)then
		paving = 0x07
		stripe = 0x07
		edge = 0x07
	elseif(band(flags, 0x02) == 2) then
		stripe = 5
	end
	if(band(flags, 0x04) == 4) then
		grassfill = region.altmask
		grass = region.alt
		edge = region.edgealt
		edgemask = region.mask
	end
	
	if(farpos < 78) then
		paving = 6
		if(band(flags, 0x02) == 2) stripe = 6
	end
	
	fillp(grassfill)
	rectfill(0, nearpos, 128, farpos, color(grass))
	fillp(0b0000000000000000)
	
	--draw the road border
	fillp(edgemask)
	renderstrip(nearpos, nearscale, nearoffset, farpos, farscale, faroffset, -.50, .50, edge);
	fillp(0)

	-- draw the road
	renderstrip(nearpos, nearscale, nearoffset, farpos, farscale, faroffset, -.45, .45, paving)
	if(farpos == 79 or farpos == 81 or farpos == 84 or farpos == 88) then
		rectfill(projectposition(-.45, nearscale) + nearoffset, farpos, projectposition(.45, nearscale) + nearoffset, farpos, color(6))
	end
	fillp()
	
	-- draw the stripes
	if(stripe == paving) return
	renderstrip(nearpos, nearscale, nearoffset, farpos, farscale, faroffset, -.17, -.15, stripe);
	renderstrip(nearpos, nearscale, nearoffset, farpos, farscale, faroffset,  .15,  .17, stripe);
end

function drawtitle()
	circfill(66, 51, 20, 1)
	circfill(66, 51, 18, 0)
	fillp(0b1100110000110011)
	circfill(66, 51, 16, 2)
	fillp()

	zspr(129, 2, 2, 8, 4, 2)
	zspr(130, 3, 2, 40, 4, 2)
	zspr(131, 1, 2, 88, 4, 2)
	zspr(128, 1, 2, 104, 4, 2)
	
	if(titleframe == 14 or titleframe == 16) pal(9, 15)
	if(titleframe == 16 or titleframe == 18) pal(10, 7)
	zspr(133, 1, 1, 52, 35, 2)
	zspr(149, 1, 1, 52, 51, 2)
	pal()
	if(titleframe == 18 or titleframe == 20) pal(9, 15)
	if(titleframe == 20 or titleframe == 22) pal(10, 7) 
	zspr(150, 1, 1, 68, 51, 2)
	zspr(134, 1, 1, 68, 35, 2)
	pal()

    if(startup) return
    pal(15,0)
	pal(7,0)
	if(optidx == 2) then map(10, 24, 4, 68, 15, 8)
	else
		map(10, 24, 4, 68, 15, 6)
		map(10, 31, 4, 116, 15, 1)
	end
	pal()
	local arrowcol = 13
	if(titleframe % 32 <= 16) arrowcol = 7
	if(titleframe >= 256) titleframe = 0
	print("‹", 15, 76, arrowcol)
	print("‘", 106, 76, arrowcol)
	if(optidx > 1) then
		print("”", 24, 88, arrowcol)
		print("ƒ", 96, 88, arrowcol)
	end
	print(options[optidx], 64 - (#options[optidx] * 2), 76, 7)

	if(optidx == 1) then
		print("controls", 48, 90, 7)
		print("‹ and ‘ to steer", 32, 98, 7)
		print("Ž to acceler8 — to brake", 12, 105, 7)
	elseif(optidx == 2) then
		local s = pctext[pcolidx]
		print(s, 64 - (#s * 2), 88, 7)
		local pc = playercolors[pcolidx]
		if(pcolidx == 5) then pal(10, 12)
		else s = lshr(pc, 12) pal(10, s) end
		setbikepal(pc)
		spr(25, 48, 101, 4, 3)
		setbikerpal(pc)
		spr(50, 73, 117, 1, 1)
		spr(50, 81, 117, 1, 1, true)
		spr(51, 73, 109, 2, 1)
		spr(53, 73, 101, 2, 1)
		spr(39, 77, 95, 1, 1)
		pal()
	elseif(optidx == 3) then
		local s = regions[selectedzone].name
		print("select a region", 34, 88, 7)
		print(s, 64 - (#s * 2), 102, 7)
	end
end

function setnightpal()
	pal(7, 13, 1)
	pal(12, 1, 1)
	pal(6,5,1)
	pal(9,4,1)
	pal(15,9,1)
	pal(3,5,1)
	pal(11,3,1)
end

function setbikerpal(cset)
	pal(15, lshr(cset, 12))
	pal(9, lshr(cset, 8))
	pal(12, lshr(cset, 4))
	pal(2, cset)
	pal(13, shl(cset, 4))
end

function setbikepal(cset)
	pal(4, 13)
	-- helmet, helmet shade, upper, lower, boots, bike, bike shade, bike stripe
	-- 15,9,12,2 - 13, 11, 3
	-- 0xf9c2.db30
	
	pal(11, shl(cset, 8))
	pal(3, shl(cset, 12))
	pal(8, shl(cset, 16))
end

function renderstrip(nearpos, nearscale, nearoffset, farpos, farscale, faroffset, deltal, deltar, col)
	local height, nearleft, farleft = flr(abs(nearpos - farpos)), projectposition(deltal, nearscale) + nearoffset, projectposition(deltal, farscale) + faroffset
	local nearright, farright = projectposition(deltar, nearscale) + nearoffset, projectposition(deltar, farscale) + faroffset	
	local ldifffactor, rdfactor, rf = abs(farleft - nearleft), abs(nearright - farright), rectfill

	for i=0, height, 1 do
		local x1 = nearleft + ((i * ldifffactor) / height)
		if(farleft < nearleft) x1 = farleft - ((i * ldifffactor) / height)
		
		x2 = nearright - (i * rdfactor) / height
		if(farright > nearright) x2 = farright + (i * rdfactor) / height
		rf(x1, nearpos - i, x2, nearpos - i, col)
	end
end

function addcar(segidx)
	--todo car == carid
	local c = {
		offset = -.33333,
		scale = 1,
		frame = true,
		speed = maxspeed / 4 + rnd(1) * maxspeed / 2,
		color = 0
	}
	
	if(segidx * roadsettings.seg_size < 0) then
		c.pos = 32767.99999
		rem = segidx - 8192 -- seg size 4 * 32768
		c.poshi = rem
	else
		c.pos = segidx * roadsettings.seg_size
		c.poshi = 0
	end
	
	local chance = rnd(1)
	if(chance < .33333) then 
		c.offset = 0
	elseif(chance < .66666) then 
		c.offset = .33333
	end

	if(rnd(1) < .5) c.frame = false

	chance = flr(rnd(9))
	if(chance == 1) then c.color = 0x3b
	elseif (chance == 2) then c.color = 0x28
	elseif (chance == 3) then c.color = 0xd1
	elseif (chance == 4) then c.color = 0x9a
	elseif (chance == 5) then c.color = 0xd7
	elseif (chance == 6) then c.color = 0xdf
	elseif (chance == 7) then c.color = 0xd2
	elseif (chance == 8) then c.color = 0xde
	end
	
	add(cars, c)
end

function accelerate(obj, rate)
	obj.speed += (rate * step)
end

function convertspeedtosfxtick(accrate)
	-- tick 1/128 = .00781
	-- step 1/60 =  .01667
	return ceil((player.maxspeed / abs(accrate)) * 128 / 16)
end

function roadbuffer_at(index)
	return roadbuffer[1 + index - roadbuffer.start]
end

function projectposition(position, scale, offset)
	return roadsettings.roadwidth_h - ((offset or 0) * scale) + position * 128 * scale
end

function getsegoffset(curve, scale)
	return curve - baseoffset - (player.x - baseoffset * 2) * scale
end

function addvel(v, obj)
	local vel, pos = v * step, obj.pos
	if (pos == 32767.99999) then
		--at the max
		if(vel > 0) then 
			obj.poshi += vel
		elseif(obj.poshi > 0) then
			if(abs(vel) > obj.poshi) then
				vel += obj.poshi
				obj.poshi = 0
				obj.pos += vel
			else
				obj.poshi += vel
			end
		else 
			obj.pos += vel
		end
	else
		if(vel > 0) then
			local res = pos + vel
			if(res < 0) res = max(res, 32767.99999) -- overflowed.
			obj.pos = res
			if(obj.pos == 32767.99999) then
				local remain = pos - (obj.pos - vel)
				obj.poshi += remain
			end
		else
			obj.pos += vel
		end
	end
end

function drawperf()
	if(not showperf) return
	local cpu, fps = flr(stat(1)*100), -60/flr(-stat(1))
	local perf =
	cpu .. "% cpu @ " ..
	fps ..  " fps"
	print(perf, 63, 1, 0)
	print(perf, 63, 0, fps == 60 and 7 or 8)
end

function easeinout(a, b, percent)
	return a + (b - a) * ((-cos(percent) / 2) + .5)
end

function easeout(a, b, percent)
	local pct = 1 - percent
	return a + (b - a) * (1 - (pct * pct))
end

function easein(a, b, percent)
	return a + (b - a) * (percent * percent)
end

function easeinoutsine(t)
	if( t < .5) return  .5 * esine(t * 2)
	return .5 * (2 - esine(2 * (1 - t)))
end

function esine(p)
	return 1 - cos(p / 4)
end

function lerp(a, b, percent)
	return (1 - percent) * a + percent * b;
end

function round(a)
	return flr(a + .5)
end

function setspeed(speed, idx)
	poke(0x3200 + shl(68, 3) + (idx or 0) * 68 + 65, speed)
end

function zspr(sid, w, h, dx, dy, scale, fx, fy)
	sx = shl(band(sid, 0x0f), 3)
	sy = shr(band(sid, 0xf0), 1)
	sw = shl(w,3)
	sh = shl(h,3)
	dw = sw * scale
	dh = sh * scale
	sspr(sx, sy, sw, sh, dx, dy, dw, dh, fx, fy)
end
__gfx__
000ff00000000000022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220022bb220
00ffff00000ff00002beeb2002beeb2002beeb2002beeb2002beeb2002beeb2002beeb200dbeeb200dbeeb200dbeeb200dbeeb200dbeeb200dbeeb200dbeeb20
00ffff0000ffff000db11bd00db11bd00db11bd00db11bd00db44bd00db44bd00db11bd00d011b200d011b200d011b200d011b200d014b200d014b200d011b20
0cccccc00cccccc00d1111d00d1111d00d1441d00d1441d00d1111d00d1111d00d1111d0001110d0001110d0001140d0001110d0001440d0001440d0001110d0
7cccccc7ccc22ccc0011110000144100001111000011110000111100001441000011110000411d0000141d0000111d0000141d0000141d0000111d0000111d00
0bc22cb00bc22cb00014410000111100001111000011110000144100001111000011110000141000001110000011100000441000001110000044100000111000
00222200002222000001100000011000000110000004400000011000000440000001100000110000001100000011000000410000001100000041000000110000
02222220022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ffff00000ff00003220000032200000322000003220000032200000322000003220000000000000c00000000000000000000000000dddddddddddddd00000
00cffff00009fff0002beb00002beb00002beb00002beb00002beb00002beb00002beb00000000000cc000000000000000000000000dddddddddddddddddd000
7ccccc900ccc2c900d31beb00d31beb00d31beb00d31beb00d31beb00d31beb00d31beb000000000ccc000000000000000000000000dddddccccccccddd6d000
0bcc2cc07bc22cc001111b2001111b2001141b2001111b2001141b2001141b2001111b200000000bcc000000000000000000000000dddccccccccccccc666d00
0b222cc70b2222cc01113230014132300111323001413230011132300141323001113230000000bbbb000000000000000000000000ddccccccccccccccc6dd00
00222200002222001411d0001111d0001111d0001111d0001411d0001411d0001111d00000000677bddbbbb000000000000000000dddccccccccccc6676cddd0
0222222002222220111000001110000011100000411000001110000011100000111000000000067b366dbbbb0000000000bbbe000ddccccccccccc66766ccdd0
00000f00022bb22000000000000000000000000000ffff00022bb22000ffff0000000000000067b35aabb6b1110000011bbbe0000ddcdddddddddddddddccdd0
070cfff002beeb2000000000000000000000e0000cc22cc002beeb200ffffff000000000000bbbb3a5aabbbb11111111bb3000000dd5ddddddddddddddddddd0
bcccc9f90d011b20000e7000000f7000000e8700cc2222cc0d011b2099ffff99000000000000bbb3a5aabb5bbb111bbb33d000000dd55dddd988889ddddd5dd0
322ccc900d11102000e88e0000f77f000000e8e0c052250c0d1110205559955500000000000000003aa58bb5bbbbbbb5dd000000dddddddd55555555dddddddd
0222ccc000111020000ee000000ff00000000e00c0d22d0c00111020955555590000000000000bb063a588bb5bbb555d00000000dddddddddddddddddddddddd
22222c00001110d0000000000000000000000000d02dd20d001110d0f955559f00000000000bbbb36638585bbbb355d111110000ddfeddd5dddddddd5dddefdd
22222c70001100d000000000000000000000000000200200001100d00f9999f00000000000bbb3336603885abbb55111111110002f98eeddddddddddddee89f2
22203b0000000000000000000000000000000000002002000000000000ffff000000000001115536630038a5ab355ddd55511100229888ed66666666de888922
0000000000000000000022200cc005222250cc000000000000000000000000000000000011150366633033baaa355666dd551110298882226565656622288892
0000000000000000000022000cc02255552cc0000000cccccccc0000070cff00000000001150b3665110033bbb55666666d55110222222226655565622222222
00000000000000000000220005c022222225c000000cccccccccc000bbccc9f0000000001150b76051100033335dddd667d05110222222226666666622222222
00000000000700000000dd00055222222222500000cccccccccccc003222cc900000000011550660511000000000115ddd505110222222222222222222222222
00060000000000000000dd00000222200222200000cc0cccccc0cc0002222cc00000000011155505111000000000111555051110141422222222222222224141
06000600700000700000dd00000222200222200000cc02cccc200cc022222c000000000001115551110000000000011155511100114141100000000001141411
0070700000060600000ddd00000222200222200000cc002222000cc022222b700000000000111111100000000000001111111000141414100000000001414141
000707000060600000dddd0000022220022220000cc000222200cc0022203b000000000000011111000000000000000111110000014141000000000000141410
0aaaaaa00aaaaaa0000000020000000000000003b30000000000000000044066000466600000000000000000000000003000000b300000030000000330000000
a775555aa777d77a00000003000000000000003bba30030000000000000466660006665d000000000000000000000000330000b3bb0000330000003333000000
a7aa555aa7aa5d7a000000030000000000000033fb3033a00000000000666655006665d600000000000000000000000033300b3b33b003330000033333300000
a7a55d5aa75555da000000d3b300000000300043bba09bb0006660006666556606665d66000000b3bb000000b00000033333b3b3bb333333bb003333333300b3
a755dadaad55557a0000036d363d000003330033bbb03bf006667600665566666665d66000003b3b33bb000033b0033b333b3b3b33bb333333bb333333333b3b
a75daa7aad5a5a7a0000b6bb0000000003bb3039bb333bb06666676055666600665d660000b3b3b3bb33bb00bb33b33333b3b3b3bb33bb33bb33bb3333b3b3b3
a75d777aa5d7777a0003033d3200000009ba3033bfb39fb0566666506666400065d664000b3b3b3b33bb33b033bb333b3b3b3b3b33bb33b333bb33b33b3b3b3b
0aaaaaa00aaaaaa000000363d333000003bb3343bb3bbbb005666500660440000d664400b3b3b3b3bb33bb33bb33b333b3b3b3b3bb33bb33bb33bb33b3b3b3b3
000550000005500000036b3bb600000004fbab33bbfbbf3033bb333b33333b3b0000000b3b3b3b3b300000003000000033bb33bb33333b3b33bb33333b3b3b3b
000560000005600000bb00bd33b3000003bbbb39bbb33000bb3333b3bb3333b3000000b3b3b3b3b3bb000000bb000000bb33bb333333b3b3bb33b333b3b3b3b3
00056000000560000000023b4036bb00003bbb33bb30000033333b3b33b3333b00000b3b3b3b3b3b33b0000033b0000033bb33bb333b3b3b33bb33333b3b3b3b
000570000005700033300db63d00000000000043fba00000b333b3b3bb3333330000b3b3b3b3b3b3bb330000bb330000bb33bb333333b3b3bb33b333b3b3b3b3
00057000000570000003bb3bb3333000000000393bb00000333b3b3b33bb3333000b3b3b3b3b3b3b33bb300033bb300033bb33bb333b3b3b33bb33333b3b3b3b
000670000006700000003d0426320000000000333a40000033b3b3b3bb33bb3300b3b3b3b3b3b3b3bb33bb00bb33bb00bb33bb3333b3b3b3bb33bb3333b3b3b3
00066000000660000033300433b633330000003333300000333b3b3b33bb33b30b3b3b3b3b3b3b3b33bb33b033bb33b033bb33bb333b3b3b33bb3333333b3b3b
00366300003663000000062bbb00bd00000044439a4a90003333b3b3bb33bb33b3b3b3b3b3b3b3b3bb33bb33bb33bb33bb33bb333333b3b3bb33bb333333b3b3
0aa555a0000000000bbb633b323b3000000000000000000033bb33bb000000000000000000000000000000000000000002000000000000000000000002552220
a7555d7a0000000000333bb2b3d3bbb30b303b003b0b303bbb33bb33000000000000000000000000000000000000000002000000000000000000000025655222
a755aa7a00000000000dd0d246b003d0b3b3b3b0b3b3b3b333bb33bb000000005550000000000000000000000000000002000000000055500222000005555550
a7d55d7a0000000033333642333bdbdd3b3b3b303b3b3b3bbb33bb33b3b3b3b356500000000000000000d0000000000022200000000056500222000002556220
a7ad555a00000000003bb33bbb300d33b3b3b3b0b3b3b3b333bb33bb3b3b3b3b5550222000000002000ddd00000002002620020000005550222222002d252dd2
a7aaa55a00000000030330b3336b33d3343b3430343b343b3333bb33b3b3b3b35a52222200000002000d6d0055555202262202000000565022222200ddd5dddd
a777557a0000000000006b3423d06b3b5453540054535453333b33bb3b3b3b3b555211111110000200ddddd05afa5222222222200000555021111110d6d0d6dd
0aa55da00000000000d333b4243333000404040004040404b333bb33b3b3b3b356521f6f6610002220d6dfd055511122a2a22620000056501a16a611ddd0dddd
000660000000000033333d4bbbdd0300000000003b3b33bb0000000000000000555ddd11111000222ddddddd56111112a2a22622000d555511d1111100000000
0005600000000000003d0044243dd000003b0b30b3b3bb33000000000000000065d666da6a1000222da6d6fd51111111222222d200dd05651ddda16100000000
000560000000000003003d3333003d0003b3b3b33b3b33bb000000000000000055ddddd1111000222ddddddd51a6a66122d22dd20ddd05551d6d111100002000
000570000000000000d30045233000330b3b3b3bb3b3bb33bb33bb33b3b3bb33a5df6dd6661555552d66a66d511111112dd2ddd2dddd05651ddd6a1100222000
0005700000000000000000452400000003b3b3b33b3b33bb33bb33bb3b3b33bb55ddddd111156d652ddddddd5166f6f1ddddddddddddd5551d6d11d102ddd200
0006700000000000000000452500000000343b34b3b3bb33bb33bb33b3b3bb3365d6d6d66f1555552dfd666d51111111d6dadaddd6d6d5651ddddddd0ddddd00
00066000000000000000004542500000000453543b3b33bb33bb33bb3b3b33bb55ddddd111156da52ddddddd51f666f1dddddddddddddd551d666d6d0d6d6d00
0036630000000000000004544425000000040404b3b3bb33bb33bb33b3b3bb3355ddddd1111555552ddddddd51111111dddddddddddddd551ddddddd0ddddd00
02222200000222000022220000222220002000000000009999990000dddddddd0000000077ff77ff000000000000000000000000000000000000000001111110
28888e2000288e2002888e20028888e202e00000000009aaaaaa9000dddddddd03b003b077ff77ff000000000000000000000000000000000000000011155111
288888e2028888e2288888e82888888e2880000000009aa000aa9000dddddddd3b3b3b3bff77ff77000000000000000000000000000000000000000011556511
00002888000028820000028800000028000000000009aa00009aa000dddddd55b3b3b3b3ff77ff77000000555555555555555555555555555555000015555651
28202888282002882820002828200000282000000009aa0009aa9000ddddd5553b3b3b3b77ff77ff000055dddddddddddddddddddddddddddddd000015555551
28e2288228e0028828e0000028e2220028e0000000009aa99aa90000dddd55550343b3b077ff77ff0005dddddddddddddddddddddddddddddddd500011555511
2888882028822288288000002888882028800000000009aaaa900000dddd555500400300ff77ff77005ddddddddddddddddddddddddddddddddd500001155110
288888e228888888288000002888820028800000000009aaa0000000dddd555500400400ff77ff7705ddddddddddddddddddddddddddddddddddd00001111110
28822882288888882880002e288000002880000000009aaaaa000000dddd5555000055555555000005ddddddddddddddddddddddddddddddddddd50001111110
28802882288002882882028828822222288222220009aaaaaa900000dddd555500055555555550005dddddddddddddddddddddddddddddddddddd50011dddd11
2880288228800288288e22882888888e2888888e009aa0009aa90000dddd555500555ffffff555005dddddddddddddddddddddddddddddddddddd50011556511
282028200280028202888882028888820288888209a9000009aa0000dddd55550055ff77ffff5500ddddddddd5555555555555555555555ddddddd0015555651
02000200002000200022222000222220002222209aa0000009a90000ddddd5550055f7ff77ff5500dddddddd555555555555555555555555dddddd0015555551
00000000000000000000000000000000000000009aa900009aa00000dddddd550055f7ff77ff5500666667755555555555555555555555555776660011555511
000000000000000000000000000000000000000009aa999aaa000000dddddddd0055ff77ff7f5500ddddddd55555555555555555555555555ddddd0001155110
0000000000000000000000000000000000000000009aaaaa90000000dddddddd0055ff77ff7f5500666667755555555555555555555555555776660001111110
000000000000000000000000000000000000000000000000dddd5555dddddddd0055f7ff77ff5500ddddddd55555555555555555555555555ddddd0001111110
0bbb6b00000000303bbb6b000bbb6b30300000300bbb6b00dddd5555dddddddd0055f7ff77ff5500666677755555555555555555555555555777660011dddd11
b33333b0000003b0033333b0b3333300b30003b0b33333b0dddd5555dddddddd0055ff77ff7f5500ddddddd55555555555555555555555555ddddd0011556511
630003600000036000000360630000006300036063000360dddd5555555555dd0055ff77ff7f5500666777755555555555555555555555555777760015555651
b30003b0000003b0000003b0b3000000b30003b0b30003b0dddd55555555555d0055f7ff77ff5500ddddddd55555555555555555555555555ddddd0015555551
b30003b0000003b0000003b0b3000000b30003b0b30003b0dddd55555555555d0055f7ff77ff5500666677755555555555555555555555555777660011555511
b30003b0000003b0000003b0b3000000b30003b0b30003b0dddd55555555555d0055ff77ff7f5500ddddddd55555555555555555555555555ddddd0001155110
b30003b0000003b0033333b0b3333300b33333b0b33333b0dddd55555555555d0055ff77ff7f5500666667755555555555555555555555555776660000111100
30000030000000300bbb6b303bbb6b003bbb6b000bbb6b005555555d5555555d0055f7ff77ff55005dddddd55555555555555555555555555dddd50055555555
b30003b0000003b0b3333300033333b0033333b0b33333b05555555d5555555d0055f7ff77ff5500566667755555555555555555555555555776650055555555
6300036000000360630000000000036000000360630003605555555d5555555d0055ff77ff7f550005ddddd55555555555555555555555555dddd500ffffffff
b30003b0000003b0b3000000000003b0000003b0b30003b05555555d5555555d0055ff77ffff550005ddddd55555555555555555555555555dddd000ff77ff77
b30003b0000003b0b3000000000003b0000003b0b30003b05555555d5555555d00555ffffff55500005ddddd555555555555555555555555dddd500077ff77ff
b30003b0000003b0b3000000000003b0000003b0b30003b0555555dd5555555d00055555555550000005ddddd5555555555555555555555ddddd500077ff77ff
b33333b0000003b0b3333300033333b0000003b0b33333b0dddddddd5555555d0000555555550000000055dddddddddddddddddddddddddddddd0000ff77ff77
0bbb6b00000000300bbb6b303bbb6b00000000300bbb6b00dddddddd5555555d000000000000000000000055dddddddddddddddddddddddd55550000ff77ff77
77ff77ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77ff77ff006000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff77ff77057555555555555555555750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff77ff77dd7dddddddddddddddddd7dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff056555555555555555555650111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555006000000000000000000600ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555000000000000000000000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600001fffffff00000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06760000071100001fffffff00007110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60a06000067600001fffffff00007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7aaa7000011700001fffffff00007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60a06000066100001fffffff00006660001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06760000011000001fffffff00001110011fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001fffffff0000000011ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001fffffff000000001fffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007000001111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700070011ffffffffffffffffff110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070711ffffffffffffffffffff11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707070701ffffffffffffffffffffff1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077707771ffffffffffffffffffffff1111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
770777071ffffffffffffffffffffff1fffff1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777771ffffffffffffffffffffff1ffffff110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001ffffffffffffffffffffff1fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011ffffffffffffffffffff11fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777011ffffffffffffffffff110fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001111111111111111111100fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707000000000000000000000000fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000fffffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000494a00494a00000000000049674b764a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000058595c4d5d5e4f4b4b4a00585959755c5c5b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005859595c5c5756595c5c5c4d5d5959755c5c5c5b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00585959595c5c5c575f5c5c5c5c575f59755c5c5c5c5b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
58595959595c5c5c5c57665c5c5c5c575f755c5c5c5c5c5b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000006b6c6d68696a6b6c6d68696e0000000000000000000000000000000000006b6c6e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6f7f6f7b7c7d78797a7b7c7d78797e6f74656488887f6f7f8874656565656400007b7c7e6f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000d4c4c4c4c4c4c4c4c4c4c4c4e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c1c2c2c2c2c30098bf9900d28989898989898989898989f40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d100000000d300a889a9e1e2e2e2e2e2e2e2e2e2e2e2e2e2e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8a8b8b8b8b8d8ea889a9d289898989898989898989898989f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a9b9c9d879d9ea889a9d289898989898989898989898989f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaabababa6abaea889a9d289898989898989898989898989f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
babbbcbd97bdbeb8c0b9d289898989898989898989898989f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000f1f2f2f2f2f2f2f2f2f2f2f2f2f2f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300021824018210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030004234202141023420214100b7000b7000d7000d7000d7000d70008700087000b7000b70008700087000d7000d7050d7000d7000b7000b7000d7000d7000d7000d70008700087000b7000b7001070010700
011000000c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c1500c150
01020000187201a7211c7211d7211f7212172123721247210b7000b7000670006700097000970006700067000b7000b7050b7000b70009700097000b7000b7000b7000b7050b7000b70009700097000970009700
0108000204123001130b1000b10009100091000b1000b1000b1000b1000610006100091000910006100061000b1000b1050b1000b10009100091000b1000b1000b1000b1050b1000b1050c1000c1000c1000c100
010c00000062500625216102161519502195021950219502195021950219502195021950219502175021750219502195021950219502195021950219502195021950219502195021950219502195021c5021c502
010e000019502195021950219502195021950219502195021950219502195021950219502195021750217502195021950219502195021950219502195021950219502195021c5021c505195021c5021c5021c502
010e00001750217502175021750217502175021750217502175021750217502175021750217502155021550217502175021750217502175021750217502175021750217502175021750217502175021a5021a502
014b0f100181002811038110481105811068110781108811098110a8110b8110c8110d8110e8110f8111081100000000000000000000000000000000000000000000000000000000000000000000000000000000
017c0f100f8100e8110d8110c8110b8110a8110981108811078110681105811048110381102811018110081100000000000000000000000000000000000000000000000000000000000000000000000000000000
015d00000f8100e8110d8110c8110b8110a8110981108811078110681105811048110381102811018110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011f00000f8100e8110d8110c8110b8110a8110981108811078110681105811048110381102811018110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001363311620106230e61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800021b9101b910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000095000950009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900
010900030412300613041230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080102346243c6113d6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
013200001355000000135500000013550000001f5501f550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001c53018530135301d5301d5301a5301f5301f5301f5321f5321f5321f53500500005001f530215301f5301f5301f5321f5321f5321f5321f5221f5321d5301d5301d5321d5321d5321d5321d5321d532
011000200ba550ba500ba150ba550ba550ba150ba550ba550ba150ba550ba550ba550ba500ba5009a5009a550ba550ba550ba150ba550ba550ba150ba5506a5506a1506a5506a5506a5507a5007a5509a5009a55
011000200ba550ba500ba150ba550ba550ba150ba550ba550ba150ba550ba550ba550ba500ba5009a5009a550ba550ba550ba150ba550ba550ba150ba550ba550ba150ba550ba550ba150ba550ba550ea550ea55
01100020130230000000612186050c6250c605006120c605130230000000612186050c6250c605006120c605130230000000612186050c6250c605006120c60513023000000061224d0000625006151561015615
011000001e7301e7301e7301e73500000000001e7301e7301e7301e7301e7301e7321e7321e7221e7121e7122a7050000000000000002370023700177301c7311c7301c7301c7301d7311d7301d7301a7301a730
011000001a7301a7301a7301a7321a7321a7321a7321a7321a7321a7321a7321a7321a7321a7321a7321a7221a7121a7121a70500500005000050000500005000050000500005000050000500005000000000000
011000001e7301e7301e7301e73500000000001e7301e7301e7301e7301e7301e7321e7321e7221e7121e7122a7050000000000000002370023700177301c7311c7301c7301c7301573115730157301773017730
011000001773217732177321773217732177321773217732177321773217732177321773217732177221771500000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001e5351e5321e5151e5351e5321e5151e5351e5321e5151e5351e5321e5151e5351e5131e5351e5131c5351c5321c5151c5351c5321c5151c5351c5321c5151c5351c5321c5151c5351c5131c5351c513
011000001a5351a5321a5151a5351a5321a5151a5351a5321a5151a5351a5321a5151a5351c515195351a5151c5351c5321c5151c5351c5321c5151c5351c5321c5151c5351c5321c5151a5321c5221a53219532
011000001f5351f5321f5151f5351f5321f5151f5351f5321f5151f5351f5321f5151f5351f5131f5351f5131e5351e5321e5151e5351e5321e5151e5351e5321e5151e5351e5321e5151c5351c5131d5351d513
011000001753217522175321752217532175221753217522175150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000ca300ca300c0300ca300ca350ca300c0300c0300ca300ca300c0300ca300ca350ca300c0300c0300fa300fa300f0300fa300fa350fa300f0300f0300aa300aa300a0300aa300aa350aa300ba300ba30
01140000107361c726107361c726107361c726107361c726107361c726107361c726107361c726107361c726137361f726137361f726137361f726137361f726117361d726117361d7260a736167260a73616726
011400200e0330e7330c6350e733216250e7330e733216250e0332160524624186050c6350e7030e733156250e7330000000632156250c6250e7330e7330e7030e733000000c63224d000c6350c6351562015625
011400001c53018530135301d5301d5301a5301f5301f5301f5321f5321f5321f53500500005001f5302153022530225302253222532225322153021530215301d5301d5301d5321d5321d5321f5301f5301d530
011400001c53018530135301d5301d5301a5301f5301f5301f5321f5321f5321f53500500005001f530215301f5301f5301f5321f5321f5321f5321f5221f5321d5301d5301d5321d5321d5321d5321d5321d532
011400001c5301c5321c5321d5301d5321d5321a5301a5301c5301c5321c5321c5321c5321c5351f500215001b5301b5301b5321b5321b5321b5321b5321b5321a5301a5301a5321a5321a532165321653216532
010e00001853018532185321853218532185321853218532185321853218522185150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001c5301c5321c5321d5301d5321d5321a5301a5301c5301c5321c5321c5321c5321c5351f500215001b5301b5301b5321b5321b5321b5321b5321b5321a5301a5301a5321a5321a532165321653216532
0104000024a4029a402ba4030a4024a3029a302ba3030a3024a2029a202ba2030a2024a1029a102ba1030a1030a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a00
0108000024a2000000000000000000000360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 14 15 43 44
01 13 15 43 44
00 14 15 16 44
00 13 15 17 44
00 14 15 18 44
00 13 15 19 44
00 14 15 1a 44
00 14 15 1c 44
00 14 15 1a 44
00 14 15 1b 44
02 14 15 1d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 1e 1f 20 44
01 1e 1f 20 44
00 1e 1f 20 21
00 1e 1f 20 22
00 1e 1f 20 23
02 1e 1f 20 24
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 14 15 1a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
