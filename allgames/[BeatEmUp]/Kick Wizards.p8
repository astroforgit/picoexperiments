pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- kick wizards
-- by ryan forsythe

-- monster states
asleep = 0
waiting = 1
melee = 2
throwing = 3
-- goat states
sliding = 4
-- boss states
castingpunch = 5
castingkick = 6
summoncreatures = 7
moving = 8
escaping = 9

mapoffset = 0
actorindex = 1

function frnd(x) return flr(rnd(x)) end
function tupdate(a, t)
	if t then
		for k,v in pairs(t) do
			a[k] = v
		end
	end
	return a
end

function newactor(attributes)
	local a = {
		index = actorindex,
		x = 0,
		y = 0,
		z = 0,
		h = 0,
		w = 0,
		vx = 0,
		vy = 0,
		vz = 0,
		dv = 0,
		mass = 1,
		layer = 1,
		friction = 0.56,
		solid = true,
		flipsprite = false,
		spritebase = 127,
		--moveframe = nil, 
		palshift = {},
		draw = function(self) end,
		update = function(self) end,
	}
	tupdate(a, attributes)
	actorindex += 1
	return a
end

function copyactor(a, nospeed)
	local b = newactor({x = a.x,
						y = a.y,
						z = a.z,
						h = a.h,
						w = a.w,
						mass = a.mass,
						layer = a.layer,
						friction = a.friction,
						solid = a.solid,
						flipsprite = a.flipsprite,
						spritebase = a.spritebase,
						moveframe = a.moveframe,
						palshift = a.palshift})
	if (nospeed != true) tupdate(b, {vx = a.vx, vy = a.vy, vz = a.vz, dv = a.dv})	
	return b
end

function newcreature(attributes)
	return tupdate(newactor({kind = 1, -- monster
							 hp = 1,
							 maxhp = 1,
							 stuntime = 0,
							 attacking = false,
							 moveframe = -1,
							 draw = draw1sprite,
							 setstun = stun,
							 damage = basicdamage,
							 statefns = {}}),
				   attributes)
end

function _init()
	gamestate = 0 
	music "0"

	players = {}
	deadplayers = {}
	monstertargets = {}
	actors = {}
	staticactors = {}
	waterfalllocs = {}
	passable = {}
	mapw = 640
	master_spawnpositions = {}
	spawnpositions = {}
	spawning = {}
	
	spritetospawnfn = {
		[16] = spawnkobold;
		[17] = spawnthrowkobold;
		[30] = spawnogre;
		[46] = spawnredogre;
		[7] = spawnsoldier;
		[32] = spawngoat;
		[23] = spawndrake;
		[39] = spawnskel;
		[63] = spawnhealer;
		[4] = spawnevilwzrd;
	}

	l2chargepxs = {}
	l3chargepxs = {}
	for x=0,7 do
		for y=0,7 do
			local c = coloratsprite(61, x, y)
			if (c == 8) add(l2chargepxs, {x, y})
			if (c == 9) add(l3chargepxs, {x, y})
		end
	end
	
	waterfallrows = {}
	for y=1,128 do
		waterfallrows[y] = {}
		for x=1,128 do
			waterfallrows[y][x] = (frnd"2" == 0)
		end
	end

	for mapcol=0,mapw do
		local mapx = mapcol % 128
		local mapy = flr(mapcol / 128) * 8
			
		if (not master_spawnpositions[mapx]) master_spawnpositions[mapx] = {}
			
		for y=mapy,mapy+7 do
			local s = mget(mapx,y)

			if s == 117 then
				waterfalllocs[mapcol] = true
				mset(mapx,y, 0)
			end

			if spritetospawnfn[s] then
				master_spawnpositions[mapx][y] = s
				mset(mapx, y, 67)
			end

			if fget(s, 0) then
				passable[s] = function(px,py)
					local mx,my = mapposfrompx(px,py)
					local spr = mget(mx, my)
					return coloratsprite(spr, px % 8, py % 8) == 4
				end
			end

			if (fget(s, 1)) passable[s] = function(mapx,y) end -- golfed, returns falsy
		end
	end
end

function tocell(px)
	return flr(px / 8)
end

function mapposfrompx(x,y)
	local row = flr(x/1024)
	return tocell(x) - (128 * row),
			row*8 + tocell(y - 40) -- bad, but saves tokens
end

function pxfrommappos(mapx, mapy)
	local row = tocell(mapy) -- bad, but saves tokens
	return 8 * (mapx + 128 * row), 40 + (8 * (mapy - row * 8))
end

function coloratsprite(spr, sprx, spry)
	--local ssx = topx(spr % 16)
	--local ssy = topx(flr(spr / 16))
	return sget(spr % 16 * 8 + sprx, flr(spr / 16) * 8 + spry)
end


movetimeout = 0
function _update()
	local f = ({updateintroscreen, updategame, updategameover, updategameover})[gamestate+1]
	f()
end

function checkaddplayer()
	for p=0,3 do
		if btnp(4, p) and btnp(5, p) then
			for po in all(players) do
				if (po.playerindex == p) goto noplayercreate
			end
			for sp in all(spawning) do
				if (sp == p) goto noplayercreate
			end
			add(spawning, p)
			local x = mapoffset + 32
			for y=58+(p*4), 104 do
				if checkpassable(x, y) then
					newsummon(x, y, 40, 0, function(a)
								  spawnplayer(p, a.x, a.y)
					end)
					added = true
					if (gamestate != 1) music "3"
					gamestate = 1
					return true
				end
			end
			::noplayercreate::
		end
	end
	return false
end

function updateintroscreen()
	local precheckmo = mapoffset + 1
	if (precheckmo >= mapw*8 - 128) precheckmo = 0
	mapoffset = 0
	if checkaddplayer() then
		gamestate = 1
		players = {}
		deadplayers = {}
		actors = {}
		mapoffset = 0
		spawnpositions = {}
		for x,ys in pairs(master_spawnpositions) do
			spawnpositions[x] = {}
			for y,v in pairs(ys) do
				spawnpositions[x][y] = v
			end
		end
	else
		mapoffset = precheckmo
	end
end

function runallupdates()
	foreach(actors, updateactor)
	foreach(staticactors, updateactor)
	foreach(actors, applyvelocity)
	foreach(actors, checklife)
	foreach(staticactors, checkstaticlife)
	foreach(actors, updatesprite)
end

function updategame()
	checkaddplayer()

	if movetimeout == 0 then
		for rawx=mapoffset, mapoffset+152,8 do
			local mapx,mapy = mapposfrompx(rawx, 56)
			for y,s in pairs(spawnpositions[mapx] or {}) do
				if y < mapy+8 then
					spritetospawnfn[s](mapx,y)
					spawnpositions[mapx][y] = nil
				end
			end
		end

		runallupdates()
	else
		movetimeout -= 1
	end

	for p in all(deadplayers) do
		if (p.x < mapoffset - 32) del(deadplayers, p)
	end

	if #players == 0 then
		if (#deadplayers == 0) return
		gamestate = 2
	end

	while #staticactors > 75 do
		del(staticactors, staticactors[1])
	end
end

function updategameover()
	for i=0,1 do
		if btnp(4,i) and btnp(5,i) then
			run()
		end
	end
	runallupdates()
end

function newcreatureat(x,y, attributes)
	local px,py = pxfrommappos(x, y)
	return tupdate(newcreature({x=px+4, y=py+7}), attributes)
end

function sstopalshift(sprite, offset, shiftcount)
	local shift = {}
	for colorpos=offset,offset+((shiftcount-1) * 2),2 do
		shift[coloratsprite(sprite, colorpos % 8, flr(colorpos / 8))] = coloratsprite(sprite, (colorpos+1) % 8, flr((colorpos+1) / 8))
	end
	return shift
end

function newsummon(x, y, life, sprite, completionfn)
	local s = newactor({x = x,
						y = y,
						kind = 3,
						update = updatesummon,
						draw = drawsummon,
						spritebase = sprite,
						lifetime = life,
						completion = completionfn
	})
	add(staticactors, s)
end

function spawnplayer(pidx, x, y)
	for p in all(players) do
		if (p.playerindex == pidx) return
	end
	local p = newcreature({
			x = x,
			y = y,
			kind = 0, -- player
			dv = 0.6,
			hp = 100,
			maxhp = 100,
			spritebase = 0,
			playerindex = pidx,
			palshift =  sstopalshift(196, pidx * 6, 3),
			update = updateplayer,
			damage = function(actor, dhp)
				actor.hp -= dhp
				addhplossscreenshake(dhp)
				if actor.hp <= 0 then
					add(actors,
						newactor({x = actor.x,
								  y = actor.y,
								  kind = 9,
								  palshift = actor.palshift,
								  draw = draw1sprite,
								  spritebase = 31,
								  update = updategravestone,
								  playerindex = actor.playerindex
					}))
					del(players, actor)
					add(deadplayers, actor)
					monstertargets[actor] = nil
					del(actors, actor)
					return
				end

				addhiteffects(actor)
			end,
			score = 0
	})
	add(actors, p)
	add(players, p)
	del(spawning, p)
	return p
end

function spawncreature(x, y, spritebase, hp, dv, pointvalue, statefns, updatefn)
	local adjustedhp = flr(hp * sqrt(max(#players, 1))) 
	local c = newcreatureat(x, y, {
								spritebase = spritebase,
								hp = adjustedhp,
								maxhp = adjustedhp,
								dv = dv,
								statefns = statefns,
								update = function(a) runactorstate(a) end,
								state = asleep,
								w = 8,
								h = 8,
								pointvalue = pointvalue
	})
	add(actors, c)
	return c
end

function newkoboldbase(x,y)
	return spawncreature(x, y, 16, 8, 0.6, 1, {
		[asleep] = koboldsleepstate,
		[waiting] = koboldwaitstate,
		[melee] = koboldmeleestate,
	})
end

function spawnkobold(x, y)
	return newkoboldbase(x, y)
end

function spawnthrowkobold(x, y)
	local k = newkoboldbase(x, y)
	k.palshift = sstopalshift(196, 24, 2)
	k.pointvalue = 2
	k.statefns[waiting] = function(a)
		if (#players == 0) return
		local closestp, closestd = closestplayer(a)
		local dx,dy,distp = dists(a, closestp)
		if distp <= 40 and (abs(dx) > 8 or abs(dy) > 6) then
			a.state = throwing
		elseif abs(dx) <= 8 and abs(dy) <= 6 then
			koboldwaitstate(a)
		else
			movetowards(a, closestp)
		end
	end
	k.statefns[melee] = function(a)
		local meleerangep = nil
		foreach(players, function(p)
			local dx,dy,distp = dists(a, p)
			if abs(dx) <= 8 and abs(dy) <= 6 then
				meleerangep = p
				return
			end
		end)

		if a.windup and a.windup >= 0 or meleerangep then
			koboldmeleestate(a)
		else
			a.state = waiting
		end
	end
	k.statefns[throwing] = function(a)
		if (#players == 0) return
		local closestp, closestd = closestplayer(a)
		if closestd > 40 then
			movetowards(a, closestp)
			return
		end
		
		if a.windup then
			if a.windup > 0 then
				a.windup -= 1
			else
				throwitem(a, closestp, 4, function(s)
							  for p in all(players) do
								  if (not intersects(p,s)) goto continue
								  if checkhits(s, p) then
									  del(actors, s)
									  return
								  end
								  
								  p:damage(2)
								  p:setstun(7)
								  screenshake += 1
								  add(s.hits, p)
								  sfx(4)
								  ::continue::
							  end
											  end, drawstick, 45)
				sfx(5)
			end
		elseif not a.attacktimeout or a.attacktimeout == 0 then
			monsterattacks(a, 30, 15)
		end
	end
	return k
end

function spawnogre(x,y)
	local o = spawncreature(x,y, 48, 100, 0.2, 5, {
		[asleep] = koboldsleepstate,
		[waiting] = function(a) a.state = melee end,
		[melee] = function(a)
			if (#players == 0) return
			local targetp = closestplayer(a)
							
			local dx,dy,distp = dists(a, targetp)
			if a.windup then
				if a.windup >0 then
					a.windup -= 1
				else
					if a.z == 0 then
						foreach(actors, function(other)
							if other != a and other.kind == 1 then
								other.vz += 2
							end
							if other.kind == 0 then
								other.vz += 2
								local odx,ody,disto = dists(a, other)
								if not a.flipsprite then
									odx *= -1
								end
								
								if odx > 0 and odx <= 12 and abs(ody) <= 4 then
									other:setstun(15)
									other:damage(a.damageamt)
								end
							end
						end)
						sfx"7"
						movetimeout = 2
						screenshake += 2
					end
					
					a.windup = nil
				end
			elseif not a.attacktimeout or a.attacktimeout == 0 then
				if abs(dx) <= 12 and abs(dy) <= 4 then
					monsterattacks(a, 45, 5)
					sfx"6"
				else
					movetowards(a, targetp)
				end
			end
		end
	})
	return tupdate(o, {h = 16,
					  mass = 2,
					  maxhp = 75,
					  draw = drawogre,
					  setstun = ogrestun,
					  damageamt = 15
	})
end

function spawnredogre(x, y)
	return(tupdate(spawnogre(x, y), {
					   pointvalue = 15,
					   maxhp = 160,
					   damageamt = 30,
					   palshift = sstopalshift(196, 28, 4)
	}))
end

function spawnsoldier(x,y)
	local s = spawncreature(x, y, 7, 8, 0.4, 3, {
		[asleep] = koboldsleepstate,
		[waiting] = function(a)
			if (#players == 0) return
			local vx, vy, vz = a.vx, a.vy, a.vz
			koboldwaitstate(a)
			
			if a.state == waiting then
				a.vx, a.vy, a.vz = vx, vy, vz
				
				local targetp = closestplayer(a)			
				local dest = a.index % 4 -- map to n/s/e/w
				local destx, desty = targetp.x, targetp.y
				if (dest == 0) desty -= 20 -- north
				if (dest == 1) desty += 20 -- south
				if (dest == 2) destx -= 20 -- east
				if (dest == 3) destx += 20 -- west
				movetowardspoint(a, destx, desty)
			end
		end,
		[melee] = koboldmeleestate,
	})
	s.setstun = function(actor, time)
		if actor.vz > 0 or actor.stuntime > 0 then
			actor.stuntime += time
			sfx"9"
			goto finally
		end
		if not actor.hitcount or actor.lasthitframe - frame > 15 then
			actor.hitcount = 0
		end
		actor.hitcount += 1
		
		if actor.hitcount >= 3 or time > 15 then
			tupdate(actor,
					{stuntime = 40,
					 hitcount = 0,
					 windup = nil,
					 attack = nil})
			sfx"9"
		end

		::finally::
		actor.lasthitframe = frame
		actor.state = waiting	
	end
	s.damage = function(actor, dhp)
		if not actor.stuntime or actor.stuntime == 0 then
			dhp = max(dhp - 7, 0)
		end
		if dhp > 0 then
			basicdamage(actor, dhp)
		end
	end

	return s
end

function shouldnthit(a, b)
	return checkhits(a, b) or not intersects(a, b)
end

function spawngoat(x, y)
	local i = spawncreature(x, y, 32, 4, 0.5, 3, {
		[asleep] = koboldsleepstate,
		[waiting] = function(a)
			a.friction = 0.3
			if a.dest then
				a.friction = 0.9
			elseif a.vx < 0.1 and a.vy < 0.1 then
				local targetp = players[frnd(#players) + 1]
				if (not targetp) return
				local x = mapoffset + ((a.x > mapoffset+64) and 10 or 118)
				local o = atan2(a.x - targetp.x, a.y - (targetp.y + 2))		
				a.dest = {x, (targetp.y + 2) + (-1 * sin(o) * (cos(o) / (a.x - x)))}
			else
				return
			end
			
			local hittableplayer = false
			if abs(a.vx) + abs(a.vy) >= 3 then
				local p = closestplayer(a)
				if p then
					local dx = p.x - a.x
					hittableplayer = (abs(a.y - p.y) < 4 and sgn(dx) == sgn(a.vx) and abs(dx) <= 10)
				end
			end
						
			if hittableplayer or (abs(a.x - a.dest[1]) <= 20) then
				tupdate(a, {state = throwing,
						   attacking = true,
						   windup = 0,
						   vz = a.vz + 2
				})
				a.dest = nil
				return
			end

			movetowardspoint(a, a.dest[1], a.dest[2])

			local nextx = a.x + 1
			local nexty = a.y + 1
			if (a.vx < 0) nextx -= 2
			if (a.vy < 0) nexty -= 2
			if (not checkpassable(nextx, nexty)) a.dest = nil
		end,
		[throwing] = function(a)
			if a.z == 0 then
				a.state = sliding
				a.attacking = false
				a.hits = nil
				sfx(12)
				return
			end
			foreach(players, function(p)
				if (shouldnthit(a, p)) return
				
				p:damage((a.vx+a.vy)^2)
				add(a.hits, p)
				sfx"13"
			end)
		end,
		[sliding] = function(a)
			a.friction = 0.8
			if a.vx <= 0.1 and a.vy <= 0.1 then
				a.state = waiting
				a.stuntime = 20
			end
		end
	})
	i.draw = function(actor)
		if (actor.state == throwing) actor.sprite = actor.spritebase + 5
		if (actor.state == sliding)	actor.sprite = actor.spritebase + 6
		draw1sprite(actor)
	end

	return i
end


function spawndrake(x, y)
	local d = spawnthrowkobold(x, y)
	d.spritebase = 23
	d.pointvalue = 4
	d.palshift = {}
	d.statefns[throwing] = function(a)
		if a.windup then
			if a.windup > 0 then
				a.windup -= 1
			else
				local targetp = players[frnd(#players) + 1]
				-- may be nil if all players just died
				if targetp then
					throwitem(a, targetp, 5,
							  function(f)
								  for p in all(players) do
									  if not shouldnthit(f, p) then
										  p:damage(10)
										  p:setstun(5)
										  add(f.hits, p)
									  end
								  end
							  end, drawflame, 120)
					sfx(10)
				end
			end
		elseif not a.attacktimeout or a.attacktimeout == 0 then
			monsterattacks(a, 60, 30)
			sfx"11"
		end
	end
	return d
end

function spawnhealer(x, y)
	local c = newcreatureat(x, y,
							{kind = 9,
							 spritebase = 63,
							 update = updatehealer})
	add(actors, c)
	return c
end

function spawnevilwzrd(x, y)
	music "6"
	local function hppct(a) return a.hp/a.maxhp end
	local function level(a) return flr(a.x / 1024) end
	local function cast(kind, sprite, vecfn, placefn)
		return function(a)
			a.attack = nil
			a.state = waiting
			
			local intensity = min((5 + level(a)) / hppct(a), 10 + level(a))
			for i=1,intensity do
				local attack = newactor({kind = kind,
										 flipsprite = (frnd"2" == 0),
										 friction = 1,
										 solid = false,
										 layer = 1,
										 spritebase = sprite,						 
										 draw = draw1sprite,
										 y = rnd"40" + 56,
										 update = function(atk)
											 for p in all(players) do
												 if not shouldnthit(atk, p) then
													 vecfn(atk, p)
													 p:damage(intensity)
													 add(atk.hits, p)
												 end
											 end
											 if ((atk.z > 32) or (atk.flipsprite and atk.x < mapoffset - 8) or (not atk.flipsprite and atk.x > mapoffset + 128)) del(actors, atk)
										 end
				})
				placefn(attack)
				newsummon(attack.x, attack.y, 45 - intensity, sprite, function(a) add(actors, attack) end)
			end
		end
	end

	local function wzrdmovestate(a)
		if simpledist(a, a.dest) < 10 then
			a.friction = 0.01
			a.solid = true
			a.state = melee
		else
			a.solid = false
			movetowardspoint(a, a.dest.x, a.dest.y)
		end
	end

	local w = spawncreature(x, y, 0, 100, 5, 1000, {
		[asleep] = koboldsleepstate,
		[waiting] = function(a)
			offsetlock = true
			if (not a.movetimer) a.movetimer = 60 + 60 * hppct(a)
			if a.attack then
				a.attack = nil
				a.movetimer = 1
			end
			a.movetimer -= 1
			if a.movetimer <= 0 then
				a.dest = {x = rnd"96" + 16 + mapoffset,
						  y = rnd"24" + 60}
				a.friction = 0.9
				a.state = moving
				a.movetimer = nil
			end
		end,
		[moving] = wzrdmovestate,
		[melee] = function(a)			
			if (#players == 0) return
			if (not a.attack) a.attack = {chargetime = 0, level = mklevel(10 * hppct(a), 30 * hppct(a))}
			a.attack.chargetime += 1
			
			if (a.attack.chargetime > 30 * hppct(a) + 15) a.state = ({castingpunch, castingkick, summoncreatures})[1+(frnd(2+level(a)) % 3)]
		end,
		[castingpunch] = cast(7, 14,
							  function(atk, player)
								  player.vx += atk.vx * 3
							  end,
							  function(atk)
								  atk.x = mapoffset + (atk.flipsprite and 120 or 8)
								  atk.vx = atk.flipsprite and -1.5 or 1.5
							  end
		),
		[castingkick] = cast(8, 15,
							 function(atk, player)
								 player.vx += (atk.flipsprite and -1 or 1)
								 player.vz += 3
							 end,
							 function(atk)
								 atk.vz = 3
								 atk.x = rnd"112" + mapoffset + 8
							 end
		),
		[summoncreatures] = function(a)
			a.attack = nil
			a.state = waiting

			local intensity = (1 + level(a)) * hppct(a)
			for i=1,intensity do
				local idx = min(1+frnd(2+level(a)), 5)
				local sprs = {16, 16, 7, 32, 23}
				local x = rnd"112" + mapoffset + 8
				local y = rnd"40" + 56
				while x < mapoffset+128 do
					if (checkpassable(x, y)) break
					x+=1
				end
				if x <= mapoffset+128 then
					newsummon(x, y, 45-intensity, sprs[idx],
							  function(a)
								  local k = ({
										  spawnkobold,
										  spawnthrowkobold,
										  spawnsoldier,
										  spawngoat,
										  spawndrake })[idx](0,0)
								  k.x = a.x
								  k.y = a.y
								  k.state = waiting
					end)
				end
			end
		end,
		[escaping] = function(a)
			a.solid = false
			wzrdmovestate(a)
			if a.state == melee then
				offsetlock = false
				othersong = not othersong
                                music(othersong and "8" or "3")
				del(actors, a)
			end
		end,
	})
	w.palshift = sstopalshift(212, 0, 5)
	w.damage = function(actor, dhp)
		if (actor.state == moving or actor.state == escaping) return
		if (actor.movetimer) actor.movetimer = flr(actor.movetimer / 2)

		local level = flr(mapoffset / 1024)

		if actor.hp - dhp <= 0 then
			if level < 4 then
				actor.dest = {x = mapoffset+138, y = actor.y}
				actor.state = escaping
				if #players > 0 then
					for p in all(players) do
						p.score += (level+1)*100
					end
				end
			else
				addhiteffects(actor)
				del(actors, actor)
				gamestate = 3
			end
		else
			basicdamage(actor, dhp)
		end
	end
	w.setstun = function(a, stuntime) end
	w.movetimer = 1 -- make the wizard move immediately upon waking
	return w
end

function updateactor(a)
	if (a.update and (not a.stuntime or a.stuntime == 0)) a:update()
end

function updateplayer(p)
	local l = p.attack and flr(p.attack:level()) or 1
	local dvx = p.dv / l
	local dvy = p.dv / (2*l)
	
	local a = nil
	local function makeattack(kind, spritebase, attacktimeout, levelfn, updatefn, releasebody)
		return { kind = kind,
				 chargetime = 1,
				 level = levelfn,
				 release = function(attack, player)
					 local dmg = copyactor(player, false)
					 tupdate(dmg,
							 {kind = 2, -- spell
							  draw = draw1sprite,
							  x = dmg.x + (dmg.flipsprite and -2 or 2),
							  friction = 1,
							  solid = false,
							  layer = 1,
							  level = flr(attack:level()),
							  spritebase = spritebase,
							  update = updatefn,
							  player = player,
					 })
					 dmg.moveframe = nil
					 player.attacking = true
					 player.attacktimeout = attacktimeout			
					 releasebody(dmg, player)
					 return dmg
				 end,
		}
	end

	local buttonfns = {
		function() -- button 0
			p.vx -= dvx
			p.flipsprite = true
		end,
		function()
			p.vx += dvx
			p.flipsprite = false
		end,
		function()
			p.vy -= dvy
		end,
		function()
			p.vy += dvy
		end,
		function() -- button 4
			a = makeattack(7, 14, 5, mklevel(7, 15),
						   function(player)
							   updateplayerattack(player, 3 * player.level, 0,
												  2 * (player.level ^ 2), 10 * player.level)
						   end,
						   function(attack, player)	   
							   attack.vx += 1 * attack.level * (attack.flipsprite and -1 or 1)
							   attack.vy = 0
							   attack.lifetime = attack.level + 4
			end)
		end,
		function() -- button 5
			a = makeattack(8, 15, 7, mklevel(10, 30),
						   function(k)
							   updateplayerattack(k, k.level, 4 * k.level,
												  4 * (k.level ^ 2), 20 * k.level)
						   end,
						   function(attack, player)
							   attack.x += (player.flipsprite and -4 or 4)
							   attack.vz = player.vz + (2.5*attack.level)
							   attack.lifetime = attack.level
			end)
		end,		
	}

	for i=1,6 do
		if (btn(i-1, p.playerindex)) buttonfns[i]()
	end

	-- attacks
	if p.attacktimeout and p.attacktimeout > 0 then
		p.attacktimeout -= 1
		return
	end

	if not a and p.attack or p.attack and a and a.kind != p.attack.kind then
		local dmg = p.attack:release(p)
		add(actors, dmg)
		addsparkle(dmg)
		sfx(flr(p.attack:level()))
		p.attack = nil
		return
	end
	if (p.attack and a.kind == p.attack.kind) p.attack.chargetime += 1
	if (not p.attack and a) p.attack = a
end

function mklevel(t2, t3)
	return function(atk)
		local ct = atk.chargetime
		if (ct < t2) return 1 + (ct / t2)
		if (ct < t3) return 2 + ((ct - t2) / (t3-t2))
		return 3
	end
end

function addsparkle(attack)
	add(actors, tupdate(copyactor(attack, false),
						{layer = 2,
						 lifetime = attack.lifetime + 3,
						 draw = drawsparkle}))
end

function simpledist(a1, a2) 
	local dx, dy, dist = dists(a1, a2)
	return dist 
end

function dists(a1, a2)
	local dx = a1.x - a2.x
	local dy = a1.y - a2.y
	local dist = sqrt(dx^2 + dy^2)
	return dx,dy,dist
end

function checkhits(attack, actor)
	if (not attack.hits) attack.hits = {}

	for hit in all(attack.hits) do
		if (actor == hit) return true
	end
	return false
end

function updateplayerattack(atk, vx, vz, dmg, stuntime)
	foreach(actors, function(a)
		if (a == atk or shouldnthit(atk, a)) return
		if a.kind == 4 or a.kind == 7 then
			a.vx *= -1
			sfx"15"
		elseif a.kind == 1 then
			a.vx = (atk.flipsprite and -1 or 1) * vx / a.mass
			a.vz += vz / a.mass
			atk.player.score += (atk.level-1) * #atk.hits
			a:damage(dmg)
			if (a.hp == 0) atk.player.score += a.pointvalue
			a:setstun(stuntime)
			sfx"0"
		end	
		add(atk.hits, a)
	end)
end 

lastclosestmonster = {}
lastclosestread = nil
function closestavailablemonster(player)
	if frame == lastclosestread then
		if (lastclosestmonster[player]) return lastclosestmonster[player]
	else
		lastclosestmonster = {}
		lastclosestread = frame
	end
	local mindist = 10000
	local minactor = nil
	foreach(actors, function(a)
		if a.kind == 1 and a.state == waiting then
			local distp = simpledist(a, player)
			if mindist >= distp then
				mindist = distp
				minactor = a
			end
		end
	end)
	lastclosestmonster[player] = minactor
	return minactor
end

function closestplayer(actor)
	local closestp = nil
	local closestd = 32768
	foreach(players, function(p)
		local distp = simpledist(actor, p)
		if not closestp or distp < closestd then
			closestp = p
			closestd = distp
		end
	end)
	return closestp, closestd
end

function koboldsleepstate(a)
	if (a.x > (mapoffset + 128) or a.x < mapoffset) return
	foreach(players, function(p) 
		if abs(p.x - a.x) < 64 then
			a.state = waiting
			return
		end
	end)
end

function cleartargeter(a)
	for p, m in pairs(monstertargets) do
		if (m == a) monstertargets[p] = nil
	end
end

function koboldwaitstate(a)
	cleartargeter(a)
	if (#players == 0) return
	local closestp, closestd = closestplayer(a)
	for p in all(players) do		
		if abs(a.x - p.x) <= 8 and abs(a.y - p.y) <= 6 then
			monstertargets[p] = a
			a.state = melee
			return
		end
		if (monstertargets[p] and monstertargets[p] != a) goto continue

		if a == closestavailablemonster(p) and p == closestp then
			monstertargets[p] = a
			a.state = melee
			return
		end
		::continue::
	end

	if (closestd > 42) movetowards(a, closestp)
end

function gettargetp(a)
	for p, m in pairs(monstertargets) do
		if (a == m) return p
	end
	return nil
end

function monsterattacks(monster, timeout, winduptime)
	monster.attacking = true
	monster.attacktimeout = timeout
	monster.windup = winduptime
end

function koboldmeleestate(a)
	local targetp = gettargetp(a)
	if not targetp then
		a.state = waiting
		return
	end
	local dx,dy,distp1 = dists(a, targetp)
	if a.windup then
		if a.windup >0 then
			a.windup -= 1
		else
			if abs(dx) <= 8 and abs(dy) <= 6 then
				targetp.vx -= sgn(dx) * 3
				targetp:setstun(3)
				targetp:damage(3)
				sfx"4"
			end
			a.windup = nil
			a.state = waiting
		end
	elseif abs(dx) <= 8 and abs(dy) <= 6
		and (not a.attacktimeout
			 or a.attacktimeout == 0) then
			monsterattacks(a, 30, 6)
	else
		if (abs(dx) > 8 or abs(dy) > 6)	movetowards(a, targetp)
	end
end

function runactorstate(actor)
	if (not actor.state) return

	if (actor.attacktimeout and actor.attacktimeout > 0) actor.attacktimeout -= 1

	if actor.stuntime and actor.stuntime > 0 then
		actor.state = waiting
		return
	end

	actor.statefns[actor.state](actor)
end

function throwitem(actor, targetp, kind, updatefn, drawfn, timeout)
	local o = atan2(targetp.x - actor.x, targetp.y - actor.y)
	local p = tupdate(copyactor(actor, true),
					 {kind = kind,
					  solid = false,
					  vx = cos(o) * 3,
					  vy = sin(o) * 3,
					  friction = 1,
					  update = updatefn,
					  draw = drawfn
	})
	add(actors, p)
	actor.windup = nil
	actor.state = waiting
	actor.attacktimeout = timeout
end

function updategravestone(a)
	if (not a.remainingrescharge) a.remainingrescharge = 85
	
	for p in all(players) do
		if (p.playerindex == a.playerindex or not p.attack) return
		if (simpledist(a, p) > 16) return
		a.remainingrescharge -= p.attack:level()
	end

	if a.remainingrescharge <= 0 then
		newsummon(a.x, a.y, 20, 0, function()
					  local p = spawnplayer(a.playerindex, 0, 0)
					  p.x = a.x
					  p.y = a.y
					  foreach(deadplayers, function(other)
								  if (other.playerindex == a.playerindex)	del(deadplayers, other)
					  end)
		end)
		del(actors, a)
		sfx"14"
	end
end

function updatehealer(a)
	if (not a.ticks) a.ticks = {}
	for p in all(players) do
		if (not p.attack) return
		if a.ticks[p] and a.ticks[p] > 0 then
			a.ticks[p] -= 1
			return
		end
		
		if (abs(p.x-a.x) > 6 or abs(p.y-a.y) > 4) return

		local h = flr(p.attack:level())
		a.ticks[p] = flr(30 / h)
		p.hp = min(p.hp + h, p.maxhp)
		sfx"8"
		add(staticactors,
			tupdate(copyactor(p, true),
					{num = h,
					 lifetime = 15,
					 draw = drawhealnum}))
		
	end
end

function updatesummon(a)
	if (a.lifetime == 0) a:completion()
end

function stun(actor, time)
	actor.stuntime = time
	actor.windup = nil
	actor.attack = nil
	actor.dest = nil
	actor.state = actor.state and waiting
end

function ogrestun(actor, time)
	if (not actor.yelltime) actor.yelltime = 0	
	actor.yelltime += 5
end



function basicdamage(actor, dhp)
	actor.hp = max(0, actor.hp - dhp)
	add(staticactors,
		tupdate(copyactor(actor, true),
				{num = dhp,
				 lifetime = 15,
				 draw = drawdamagenum}))
	addhiteffects(actor)
	addhplossscreenshake(dhp)
	if (actor.hp == 0) del(actors, actor)
	for p, m in pairs(monstertargets) do
		if (monstertargets[p] == actor) monstertargets[p] = nil
	end
end

function movetowards(actor, player)
	movetowardspoint(actor, player.x, player.y)
end

function movetowardspoint(actor, destx, desty)
	if actor.z > 0 then return end
	local dx = actor.x - destx
	local dy = actor.y - desty
	-- local distp = sqrt(dx^2 + dy^2)

	if sqrt(dx^2 + dy^2) > 4 then -- if distp > 4 then -- golf :/
		local o = atan2(dx, dy)
		local pvx = cos(o) * actor.dv
		local pvy = sin(o) * actor.dv
		actor.vx -= pvx
		actor.vy -= pvy
		if dx > 4 then			
			actor.flipsprite = true
		elseif dx < -4 then
			actor.flipsprite = false
		end
	end
end

function intersects(a, b)
	return a.layer == b.layer
		and abs(a.x - b.x) <= 4
		and abs(a.y - b.y) <= 4
		and abs(a.z - b.z) <= max(a.h, b.h)
end

function checkpassable(x,y, w)
	if (not w) w = 4
	for i=x-w/2,x+w/2 do
		local mapx,mapy = mapposfrompx(i, y)				
		local f = passable[mget(mapx, mapy)]
		if (f) return f(i, y)
	end
	return true
end

function applyvelocity(actor)
	local nextx = actor.x + actor.vx
	local nexty = actor.y + actor.vy
	local nextz = actor.z + actor.vz
	local nextvx = actor.vx
	local nextvy = actor.vy
	local nextvz = actor.vz
	if actor.solid then
		if flr(nextx) != flr(actor.x) then
			if not checkpassable(nextx, actor.y) then
				nextx = actor.x
				nextvx = 0
			end
		end
		if flr(nexty) != flr(actor.y) then
			if not checkpassable(actor.x, nexty) then
				nexty = actor.y
				nextvy = 0
			end
		end
	else
  if actor.kind != 1 and (nexty >= 104 or nexty <= 56 or nextx <= 0 or nextx > mapw*8) then
			del(actors, actor)
			return
		end
	end

	if actor.friction and actor.z == 0 then
		nextvy *= actor.friction
		nextvx *= actor.friction
	end
	if (abs(nextvx) < 0.001) nextvx = 0
	if (abs(nextvy) < 0.001) nextvy = 0

	local xchg = flr(actor.x) != flr(nextx)
	local ychg = flr(actor.y) != flr(nexty)

	actor.x = nextx
	actor.y = nexty
	if (actor.kind == 0) actor.x = mid(nextx, mapoffset, mapoffset + 127)
	if (actor.solid) actor.y = mid(nexty, 56, 104)

	if nextz <= 0 then
		local p = flr(abs(nextvz) * actor.mass)
		if (p > 4 and actor.hp) actor:damage(p)
		nextz = 0
		nextvz = 0
	elseif actor.kind != 8 then
		nextvz -= 0.8
	end
	
	actor.z = nextz

	if actor.kind == 1 then
		foreach(actors, function(a)
			if ((a == actor) or (a.kind != 1) or (a.z != actor.z)) return
			local dx = a.x - actor.x
			local dy = a.y - actor.y
			if abs(dx) < 3 and abs(dy) < 2 then
				nextvx -= sgn(dx) * 0.4
				nextvy -= sgn(dy) * 0.2
			end
		end)
	end
	
	if actor.moveframe then
		if nextvy == 0 and nextvx == 0 then
			actor.moveframe = -1
		elseif (nextvy != 0 or nextvx != 0) and actor.moveframe == -1 then
			actor.moveframe = 0
		elseif xchg or ychg then
			actor.moveframe = actor.moveframe + 0.5
		end
	end
	
	actor.vx = nextvx
	actor.vy = nextvy
	actor.vz = nextvz
end

function checklife(actor)
	if actor.lifetime then
		if (actor.lifetime <= 0) del(actors, actor)
		actor.lifetime -= 1
	end
	if (actor.stuntime and actor.stuntime > 0) actor.stuntime -= 1
end

function checkstaticlife(actor)
	if actor.lifetime then
		if (actor.lifetime <= 0) del(staticactors, actor)
		actor.lifetime -= 1
	end
	if (actor.kind == 3 and abs(mapoffset - actor.x) > 500) del(staticactors, actor)
end

function updatesprite(actor)
	if (not actor.spritebase) return
	local offset = 0
	if actor.stuntime and actor.stuntime > 0 then
		offset = 6
	elseif actor.moveframe and actor.moveframe >= 0 then
		offset = 1 + (flr(actor.moveframe) % 3)
	elseif actor.attacking and actor.windup and actor.windup > 0 then
		offset = 4
	elseif actor.attacking and actor.windup == 0 then
		offset = 5
	end
	actor.sprite = actor.spritebase + offset
end

function addhiteffects(actor)
	movetimeout = 4

	e = copyactor(actor, false)
	e.kind = 3
	
	if actor.hp > 0 then
		e.layer = 2
		e.lifetime = 2
		e.draw = drawhit
		if (not actor.undamageddraw) actor.undamageddraw = actor.draw		
		actor.draw = drawdamaged
	else
		e.layer = 1
		e.lifetime = nil
		e.friction = 0.75
		e.draw = drawgib
	end
	add(staticactors, e)
end

function addhplossscreenshake(hploss)
	if (hploss >= 12) screenshake += hploss / 6
	screenshake = min(7, screenshake)
end

frame = 0
screenshake = 0
mapoffsetvx = 0
function _draw()
	frame += 1
	drawgame()
	local f = ({drawintro, drawgame, drawgameover, drawwin})[gamestate+1]
	f()
end

function drawintro()
	rectfill(0, 0, 128, 38, 0)
	runpalshift(sstopalshift(196, 18, 3))
	spr(0, 4, 26)
	pal()
	color(15)
	cursor(16,22)
	print "the dark wzrd has stolen the"
	print "amulet of yendor! to return "
	print "it we'll need to call the..."
	
	sspr(0, 96, 32, 16, 16, 48, 96, 48)
	
	restarttext()
	
	centertext("by ryan forsythe", 117, 13)
	centertext("with music by jesse wolfe", 123, 13)
end

function restarttext() centertext("push — and Ž to start", 105, 15) end

function centertext(text, y, textcolor)
	print(text, (128 - #text*4) / 2, y, textcolor)
end

function drawgameover()
	spr(201, 48, 53, 4, 3)
	restarttext()
end

function drawwin()
	spr(205, 52, 53, 3, 3)
	rectfill(0, 76, 128, 104, 0)
	cursor(4, 77)
	color(15)
	print"grasping the amulet of yendor,"
	print" you begin a campaign to take"
	print" over the world. you were the"
	print"    monster the whole time."
	restarttext()
end

maprowpalshifts = {
	nil,
	sstopalshift(196, 36, 7),
	sstopalshift(196, 50, 7),
	sstopalshift(212, 10, 7),
}
offsetlock = false
maxoffset = 0
function drawgame()
	local playercount = #players
	local center = 64
	local avg = 0
	local minp = 32767
	local maxp = 0
		
	if not offsetlock and playercount > 0 then
		local xaccum = 0
		local dirvote = 0
		for p in all(players) do
			local sp = p.x - mapoffset
			minp = min(minp, p.x)
			maxp = max(maxp, p.x)
			xaccum += sp
			dirvote += (p.flipsprite and -1 or 1)
		end
		
		if (dirvote > 0) center = 44
		if (dirvote < 0) center = 84
		avg = xaccum / playercount
		local move = (avg - center) / 15
		if abs(move) > 0.1 then
			move = max(abs(move), 1) * sgn(move)
		end
		
		local next = mapoffset + move
		if next < 0 or
				next > minp - 4 or
				next < maxp - 120 or
				next < maxoffset - 32 then
			next = mapoffset
		end
		mapoffset = next
		maxoffset = max(mapoffset, maxoffset)
	end

	-- camera and camera shaking
	local shakex = 0
	local shakey = 0
	if screenshake > 0 then
		shakex = 3-rnd"6"
		shakey = 3-rnd"6"
		screenshake -= 1
	end
	camera(mapoffset+shakex, shakey)

	--drawmap()
	rectfill(mapoffset, 40, mapoffset+128, 56, 1)
	for x=0,mapw,128 do
		local row = flr(x/128)
		local remaining = min(mapw-x, 128)
		map(0, row*8, row*1024, 40, remaining, 2)
		local shift = maprowpalshifts[row+1]
		if (shift) runpalshift(shift)
		map(0, row*8 + 2, row*1024, 56, remaining, 6)
		pal()
	end
	
	--drawactors()
	local drawn = {}
	local drawtest = function(actor)
		if (actor.draw and (actor.x > mapoffset - 40) and (actor.x < mapoffset+168)) add(drawn, actor)
	end
	foreach(actors, drawtest)
	foreach(staticactors, drawtest)
	heapsort(drawn, actorsort)
	foreach(drawn, function(a) a:draw() end)
	
	--drawwaterfalls()
	local minpx = 32767
	local maxpx = -1
	local palshift = {}

	for cx=tocell(mapoffset-7), tocell(mapoffset + 127) do
		if waterfalllocs[cx] then
			local px = 8 * cx
			minpx = min(px, minpx)
			maxpx = max(px+8, maxpx)
			palshift = maprowpalshifts[flr(cx / 128)+1] or {}
			for y=40,55 do
				local waterfallrow = waterfallrows[1 + ((px + y - flr(frame)) % #waterfallrows)]
				for x=px,px+8 do
					local c = palshift[1] or 1
					if (waterfallrow[1 + (x % #(waterfallrow))]) c = palshift[12] or 12
					pset(x,y,c)
				end
			end
		end
	end

	-- draw spray
	if maxpx != -1 then
		for y=49,59 do
			local d = 56-y
			for x=minpx - d - 2, maxpx + d + 2 do
				if (frnd(max(1, abs(d) * 4)) < 3) pset(x,y, palshift[7] or 7)
			end
		end
	end

	camera()
	rectfill(0, 0, 128, 39, 0)
	rectfill(0,104, 128, 128, 0)
	spr(192, 48, 4, 4, 2)

	for pidx=0,3 do
		--drawplayerinfo(i)
		local p = nil
		local findfn = function(a) if (a.playerindex == pidx) p = a end
		foreach(players, findfn)
		foreach(deadplayers, findfn)	
		
		local xoff = pidx * 32
		spr(197, xoff, 23, 4, 2)
		runpalshift(sstopalshift(196, pidx * 6, 3))
		
		print((pidx+1).."UP", xoff, 23, 2)
		local textindent = xoff+14
		if not p then
			local s1 = "game"
			if gamestate == 1 then
				s1 = "hold"
				print("—+Ž", textindent - 4, 32, 13)
			elseif gamestate == 2 then
				print("over", textindent, 32, 13)
			else
				s1 = ""
			end
			print(s1, textindent, 26, 13)
		else
			local s = (min(9999, p.score))..""
			print(s, xoff+(30 - (#s * 4)), 26, 13)
			local sprite = 31
			if p.hp == 0 then
				print("dead", textindent, 32, 1)
			else
				sprite = 0
				local pips = 20 * p.hp / p.maxhp
				for i=1, 20, 2 do
					line(xoff+9+i, 32, xoff+9+i, 36, (i > pips) and 6 or 8)
				end
			end
			spr(sprite, xoff+1, 30)
		end
		
		pal()
	end
end

function runpalshift(shifts)
	for a,b in pairs(shifts) do
		pal(a,b)
	end
end

function actorsort(a,b)
	local d = (a.y + (a.layer * 128)) - (b.y + (b.layer * 128))
	if (d == 0) return a.index - b.index
	return d
end

-- props to overkill: http://www.lexaloffle.com/bbs/?pid=18374#p18374
function heapsort(t, cmp)
	local n = #t
	if (n <= 1) return
	
	local lower = flr(n / 2) + 1
	local upper = n
	while 1 do
		local i, j, temp
		if lower > 1 then
			lower -= 1
			temp = t[lower]
		else
			temp = t[upper]
			t[upper] = t[1]
			upper -= 1
			if upper == 1 then
				t[1] = temp
				return
			end
		end

		i = lower
		j = lower * 2
		while j <= upper do
			if (j < upper and cmp(t[j], t[j+1]) < 0) j += 1
			if cmp(temp, t[j]) < 0 then
				t[i] = t[j]
				i = j
				j += i
			else
				j = upper + 1
			end
		end
		t[i] = temp
	end
end

function drawoutline(sprite, sprx, spry, flip)
	for i=1,15 do
		pal(i,1)
	end
	
	for x=sprx-1,sprx+1 do
		for y=spry-1,spry+1 do
			spr(sprite, x, y, 1, 1, flip, false)
		end
	end
	pal()
end

function drawshadow(actor)
	local level = flr(actor.x / 1024)
	palt(0, false)
	palt(14, true)
	if ((level == 1) or (level == 2)) pal(5, 2)
	spr(62, actor.x-4, actor.y-6-actor.z)
	pal()	
end

function draw1sprite(actor)
	local sprx = actor.x-4
	local spry = actor.y-8-actor.z
	
	drawshadow(actor)
	drawoutline(actor.sprite, sprx, spry, actor.flipsprite)
	runpalshift(actor.palshift)
	spr(actor.sprite, sprx, spry, 1, 1, actor.flipsprite)
	pal()
	
	if actor.attack then
		local xadj = actor.flipsprite and -4 or 3
		pset(actor.x+xadj, actor.y-6, 1+(frame % 15))

		local level = actor.attack:level()

		function fillcircle(circlevel, pxs, basecolor, fullcolors)
			local rem = max(level - circlevel, 0)
			local count = min(#pxs * rem, #pxs)
			
			for i=1,count do
				local pt = pxs[i]
				local c = (count == #pxs) and fullcolors[frnd(#fullcolors) + 1] or basecolor
				xadj = actor.flipsprite and -8 or -1
				pset(actor.x+pt[1]+xadj, actor.y+pt[2]-10, c)
			end
		end

		fillcircle(1, l2chargepxs, 11, {3,11})
		fillcircle(2, l3chargepxs, 9, {9,8})
	end

	if actor.stuntime and actor.stuntime != 0 then
		for i=0,3 do
			local x = actor.x + (3*cos((actor.stuntime + (4*i)) / 16))
			local y = spry - 2 + (sin((actor.stuntime + (4*i))/ 16))
			pset(x, y, 10)
		end
	end
end

function drawogre(actor)
	local normalhead = 46
	local winduphead = 47
	local yellhead = 30

	local head = normalhead
	if actor.yelltime and actor.yelltime > 0 then
		actor.yelltime -= 1
		head = yellhead
	elseif actor.attacking and actor.windup and actor.windup > 0 then
		head = winduphead
	end
	local body = actor.sprite
	local club = nil
	if actor.attacktimeout and actor.attacktimeout > 0 and (not actor.windup or actor.windup <= 0) then
		body = 53
		club = 54
	end
	
	local sprx = actor.x-4
	local sprbodyy = actor.y-8-actor.z
	local sprheady = actor.y-16-actor.z
	local sprclubx = sprx + (actor.flipsprite and -8 or 8)
	drawshadow(actor)
	drawoutline(body, sprx, sprbodyy, actor.flipsprite)
	drawoutline(head, sprx, sprheady, actor.flipsprite)
	if (club) drawoutline(club, sprclubx, sprbodyy, actor.flipsprite)
	pal()
	runpalshift(actor.palshift)
	spr(body, sprx, sprbodyy, 1, 1, actor.flipsprite)
	spr(head, sprx, sprheady, 1, 1, actor.flipsprite)
	if club then
		spr(club, sprclubx, sprbodyy, 1, 1, actor.flipsprite, false)
	end
	pal()
end

function drawsparkle(actor)
	local sprx = actor.x-4
	local spry = actor.y-8-actor.z

	for i=1,2 do
		local x = sprx + frnd"8"
		local y = spry + frnd"8"
		local c = 9
		if frnd"2" == 1 then
			c = 10
		end
		pset(x, y, c)
	end
end

function drawgib(actor)
	if not actor.particles then
		actor.particles = {}
		for i=1,16 do
			local avx = actor.vx
			if abs(avx) < 0.1 then
				avx -= frnd "1"
			else
				avx += frnd "1"
			end
			add(actor.particles, {
					x = actor.x + (4-frnd"8"),
					vx = avx,
					y = actor.y + (3-frnd"6"),
					vy = actor.vy,
					z = actor.z + frnd"8",
					vz = actor.vz,
					c = (frnd"4" == 0) and 6 or 8,
			})
		end
		actor.vx = 0
	end
	local allgrounded = true
	foreach(actor.particles, function(p)
		if p.z > 0 then
			p.x += p.vx
			p.y += p.vy
			p.z += p.vz
			p.z = max(0, p.z)
			p.vz -= 0.8
			p.vx *= 0.7
			p.vy *= 0.7
			allgrounded = false
		else
			-- remove all gibs which land on a impassable location; only do this while some gibs are still moving
			if not checkpassable(p.x, p.y, 0) then
				del(actor.particles, p)
				return
			end
		end
		
		line(p.x, p.y-p.z, p.x+p.vx, p.y-p.z, p.c)
	end)
	if (allgrounded) actor.layer = 0
end

function drawhit(actor)
	local sprx = actor.x-4
	local spry = actor.y-8-actor.z

	if (not actor.hitloc) actor.hitloc = 2 + frnd"4"
	
	y = spry + actor.hitloc
	x = actor.x
	line(x-2, y, x+2, y, 10)
	line(x, y-2, x, y+2, 10)
end

function drawdamaged(actor)
	local sprx = actor.x-4
	local spry = actor.y-8-actor.z

	if actor.sprite != nil then
		for i=0,15 do
			pal(i,7)
		end
		spr(actor.sprite, sprx, spry, 1, 1, actor.flipsprite)
		pal()
		actor.draw = actor.undamageddraw
	end
end

function drawdamagenum(actor)
	drawfloatingnum(actor, {10, 9, 8})
end

function drawhealnum(actor)
	drawfloatingnum(actor, {12, 13, 1})
end

function drawfloatingnum(actor, colors)
	local c = colors[1]
	if actor.lifetime < 2 then c = colors[2]
	elseif actor.lifetime < 4 then c = colors[3] end
	print(actor.num, actor.x-4, actor.y-8-actor.z-sqrt((200-(actor.lifetime ^ 2))), c)
end

function drawstick(actor)
	if frame % 2 == 0 then
		line(actor.x+2, actor.y-2, actor.x-2, actor.y-2, 6)
	else
		line(actor.x, actor.y, actor.x, actor.y-4, 6)
	end
end

function drawflame(actor)
	circfill(actor.x, actor.y-4, 2, 9)
	circfill(actor.x, actor.y-4, (frame % 5)/2, 8)
end

function drawsummon(actor)
	if frame % 3 == 0 then
		runpalshift(actor.palshift)
	else
		local rp = {}
		for i=0,15 do
			rp[i] = frnd(16)
		end
		runpalshift(rp)
	end
	spr(actor.spritebase, actor.x-4, actor.y-8, 1, 1, actor.flipsprite)
	pal()
end
__gfx__
000e0000000e0000000e0000000e0000000e0000000e0000000e0000000000000000000000000000000000000000000000000000000000000000000000000b00
0022e0000022e0000022e0000022e0000022e0000022e0000022e000005dd000005dd000005dd000005dd000005dd000005dd000005dd000000bbb000000b3b0
02222e0902222e0902222e0002222e0902222e0b02222e0092222e000055500000555000005550000055500060555000005550006055d000bbb33bbb0000b3b0
0f3ff3090f3ff3090f3ff3090f3ff3090f3ff3090f3ff3009f3ff30000a5a00000a5a00000a5a00000a5a00060a5a0000055a00060a5a00003333b3b000b33b0
02222e0f02222e0f02222e0902222e0f02222e0f02222e00f2222e0000b7777000b7777000b7777000b7777060b7777055bbbb0060bbbb000033333bbbb33b00
012222e0012222e0012222ef012222e0012222e001222f9b012222e00b3666700b3666700b3666700b3666706b36667053b300006bb335000bb3333b033333b0
01122200f1122200011222f0f112220001122200011222000012222f055666700556667005566670055666700036667055bb666600b35500000bbbb000bbbbb0
0f000f00000f00000f00000000000f000f000f000f000f00000f0000003030000003000003000000030030000030300000b0300000b030000000000000000000
000000000000b0b00000000000000000000000000000000000003060000000000000aaa00000000000000000000000000000000000a600000000000000066000
000b0b000000aba00000b0b00000b0b0060b0b00000b0b0000ba30600000aaa0aaa089800000aaa000000000000aaa000000aaa0a89000000000000000525600
000aba00000b33330000aba00000aba0060aba00000aba00000b3060aaa0898009a0999aaaa089800000aaa0aaa8a80000008a80aa9600000aaa000000222600
0003333000bb3000000b3333000b3333060b3330000b333000ba336009a0999a00a0960609a0999aaaa0898009a999a0aaa0999aa8990aa00898000000525600
00bb3000b066600000bb3000b0bb300000bb3000003b30000003300000a096060aaa900000a0960600a0999a00a9606000a0960600090a900999000000525600
b06663000bbb3b00b06660000b666000b00b3300000bb666000b30000aaa900000a999000aaa90000aaa96060aaa9000aaa99000aaaa9a000900070000555600
0bbb3000000b00000bbb300000bb30000bbb3000bbbb30000bbb330000a9900000a0000000a9900009a9900000a990000a990990a0a990000944440000555600
00030b000000000000b00b000000b00000030b0000030b00000b000000a090000000000000a009000009000000a090000a09000000a090000999990005555560
00000000000050500000000000000000000000000000000000000000000077700000777000007770000000000000777000007770000000000000000000000000
0000000000002ee000005050000000000000000000000000000000000000b7b00000b7b00000b7b0000077700060b7b00000b7b00000000000000000665000aa
00005050000027e700002ee00000505000005050e0000000000000000000070000000700000007000000b7b00060070000000700000000000000000065555599
00002ee000002220000027e700002ee000002ee020e0000000000000000070000000700000007000000707000006700000007000000000000aaa00000aaa0009
0e0027e70ee0206000002220000027e70e0027e702ee2ee500000700000706600007066000070660000706600000070000070660000000000898000008980009
00202220000e22000ee020600ee0222000202220200027e00006ee25000700000007000000070000000700000000070000070000000777000999070009990709
000e206000020000000e2000002e2060000e206000062225e0e0e720000070000000760000007000000070000000700000007000000b7b000944440009444409
00022000000000000020020000020000000220000000070002222225000707000007000000070600000670000007070000070700000070000999990009999909
0099a0000099a0000099a0000099a0000099a09009a000000000000054445444444454445444544444444444544454440004440000000000eeeeeeee00070000
99999a0099999a0099999a0099999a0000999a00999a00000000000055555555454555555555545454545445555555550040004000099900eeeeeeee007c7000
909999a0909999a0909999a0909999a0009999a09999a0000000000044544454445444544454444444544454445444540004440000988890eeeeeeee00cc7000
909949a0909949a09a995660909949a0009949a09949a9000000000055555555444454555555444555555555555555550000400009800089eeeeeeee00dc7000
90999990909999909a555560909999900049999049994900000000005444544444444444544454445444544454445444000aaa000980b089eeeeeeee00cc7000
9a9956609a495660004444009a49566900444400444440990000000055555555454555555555545455555555554545550099baa009800089ee5555ee00dcc000
9a5555609a555560090900009a555569009004009000400aa5555660445444544454445444544444445444544444445400099900009888905555555500dc7000
0440099909900099090990000009900009900999990099099000556055555555454455555554544555555555545444450000000000099900ee5555ee0ddcc700
00000000000000000000000044444444444444444444444444444444444449c11c9444445444444445445454545555551111111d511111116666666666666666
00bbbbb000000bbb0000000044444444444444499999999999444444444499c11c994444444444444444444545454554111111d556111111dddd65dddddd65dd
0b33333b0bb0b34b0000000044444444444449995d5d5d5d5999444444449dc11cd94444444444454445454454555555111111d556111111dddd65dddddd65dd
0533333bb333343b00bbb000444444444444995dd5d5d5d5d5d99444444995c11c599444444444444444444545545455111115655d6111115555d5555555d555
0353533b344534500b333b0044444444444995dccccccccccd5d994444495cc11cc5944444454444454454545455555511111556556111116666666666666666
0535353b5334540003533b004444444444995dcc111111111cc5d9944499dc1111cd99444444444444444445454545541111d115d5d611115dddddd65dddddd6
005353500053400005345000444444444495dc1111111111111c5d94449dcc1111ccd944444444454445454454555555111d5555555d61115dddddd65dddddd6
00004000000040000004000044444444449dc111111111111111c5944495c111111c594444444444444444454554545511156655515561115555555d5555555d
44444444444444444444444444444444449c1111111111111111c944449cc111111cc9441111111144444444000000001115dd65515561116666666666666666
44444444443343444444444444444444444911111111111111119444449c11111111c94411111111544444440000000011155d555515d111dd65ddddd65ddddd
44444444444444444422444444442444444499111111111111994444444911111111944411111111444444440000000011d155555655d611dd65ddddd65ddddd
4344444443433434444444444244442444444499111111119944444444491111111194441111111144445444000000001d55115555555d6155d555555d555555
4444443444444444444442244442444444444444999999994444444444449111111944449991111144444444000000001d66555555665d616666666666666666
44444444444433444424444444444444444444444444444444444444444491111119444444499111544444440000000015dd65555ddd65d1ddddd65ddddd65dd
443444444434444444444444444442444444444444444444444444444444491111944444444449114444444400000000115d65d5155d65d1ddddd65ddddd65dd
444444444444444444444444444444444444444444444444444444444444491111944444444449c1444444450000000051155555155d55d555555d555555d555
33333333333333333333333333333333495c11111111111100000000444449c11c94444444444444666666666666666655d555555555665555dd655555555555
3333333333333333333333333333333395dc11111111111100000000444449c11c94444434422444dddd65dddddd65dd515d566655515d655155d65555556655
333233331333313333323333133331335dcc11111111111100000000444449c11c94444444233244dddd65dddddd65dd551555dd655515555155d5555551dd65
33122332113311133312233111331113dcc111111111111100000000444449c11c944444444224435555d5555555d55555515d5dd65555555511555566651155
22122222112111111112221113b11111cc1111111111199900000000444449c11c944444444444446661111111111666655155d5d6555d655555555dddd65555
122224241121111111122411333b1111111111111119944400000000444449c11c944444424434345d611111111115d665551555d555155655555515d5dd6555
112242441141111111124411333b1111111111111194444400000000444449c11c944444232444445d611111111115d6556551155565155d55566515555d6555
11122444444111111112241113311111111111111c94444400000000444449c11c9444444244344455d111111111155d5555555555555115551dd65155dd5555
1112424421111111111244111211111111111111111111111c994444449c11111111c9441111c994666111111111166655565556665555555551555511155555
11122444111111111112244444111111111111111c111c1c1cd99999449c11111111c9441111cd99dd611111111115dd655565dddd6555d55555555555555665
1112424411111111111244211111111111111111cccccccc1c5d5d5d449c11111111c9441111c5d5dd611111111115dd55156555d5d6515d555666655555ddd6
11122444111111111112241111111111111111111cc11c1c1cc5d5d5449c11111111c9441111cc5d55d11111111115555515d1555d5d651555ddddd6655155d6
11124244111111111112441111111111111111111111111111cccccc449c11111111c94411111ccc66611111111116665551515555dd65555d55d5ddd65155d6
1112244441111111111224111111111111111111111111c111111111449c11111111c94411111111dd611111111115dd55665155555d655515555d5ddd6515d5
1222424444411111112244411111111111111111cccccccc11111111449c11111111c94411111111dd611111111115dd515d6515555d5566155555555d655115
2222222222241111122222441111111111111111ccc1111111111111449c11111111c9441111111155d11111111115556155651155d55ddd1555555555d65555
e4f4a6b6f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4a6b6f4e4e4f4e4e4f4e4e4f4a6b6f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4
f4e4e4f4e4e4f4a6b6f4e4e4e4f4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4e4f4f4e4e4f4e4e4f4e4e4f4e4e4f4
e4f5a7b7f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5a7b7f5e5e5f5e5e5f5e5e5f5a7b7f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5
f5e5e5f5e5e5f5a7b7f5e5e5e5f5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5e5f5e5f5e5f5e5f5e5f5e5f5e5f5e5f5e5f5e5f5e5f5f5e5e5f5e5e5f5e5e5f5e5e5f5
a505774747474787343405343405343483a373a373930534343483a305778771343405343405e2e20577474747478670837373a3739302053434057070703434
05347070703402778783a37393930170343402343483a37373b39305343477474747474747474747474747474747474747873405343405343405343405343405
a534774747474787717171343434343434837373933402445464348393778771343434343434343434774747474786708373a373b39302446434347070703434
3434707070340277878373b3a3930170e1710234348373b3a3739334343477474747474747474747474747474747474747873434343434343434343434343434
a53477474747479754545454643434348373739334e2027747877183b3778771343434348373a393347747474747867083b3b37393e202778771347070703434
3434707070340277878373a373930170e17102e234837373b3739334f33445555555555555555555555555555555555555653434343434343434403434343434
a5f345555555555555555555653435353483737393e2027747877135347797545454643583b3b3933477474747478670353435b3933502778771343535343535
3435e134353502778783b373b3930170e17102353583737373739334353544545454545454545454545454545454545454643534353534353534353534353534
a5344454545454545454545464343434343483933434027747877134347747474747873434343434347747474747675454546470707070778771343434343434
3434e23434340277873434343434017034710234348373a373a39334343477474747474747474747474747474747474747873434343434343434343434343434
a53477474747474747474747873434343483b3739334347747877134344555555555653434340202024555555555555555556534343434778771348373a3b3a3
9334e134343402456534343434340170343402343483b37373b39334343477474747474747474747474747474747474747873434343434343434343434343434
11111111111111111111111111111111007c1c111111cc7700000000000000000000000000000000000000000000000000000000000000000000000000000000
1c11111c111111c11c1c11ccc11111110077ccc1111ccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc1cccc1c11ccccccc1cc7c1c11c1c00077ccc1c1c7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc7ccc7ccc1cc7ccc7cccc7cccccccc00070c7cc7cc070000000000000000000000000000000000000000000000000000000000000000000000000000000000
c7c7c7c7c7cccc7ccc7cc7c7cc7c7cc70000077c70c7070000000000000000000000000000000000000000000000000000000000000000000000000000000000
c777c77777c7c77c7c77c7777c7c77c7000000777077000000000000000000000000000000000000000000000000000000000000000000000000000000000000
770777070777c70c7700c707770c7707000000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007000007007007000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070700070707077000070000707700000000077070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777c770c7c0c7cc7707c0707c77c7000000007c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77c7cc7c7ccc7cccc7c7cc7c7ccc7c770000070cc770070000000000000000000000000000000000000000000000000000000000000000000000000000000000
c7ccc6cc7c6c7cc6ccc7cccccccccc7c00707c7ccc77770000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc6c666cc6ccc666cccc6c6c6c6cccc0077c67c6cc7c77000000000000000000000000000000000000000000000000000000000000000000000000000000000
c6c666666c66c66666c6c6666666c6c6077cc6c66c67cc7000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666666666666666666666666666667ccc6666666cccc700000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000200202000200002002000002ce61d230000000000000000000000000000000000002220000020000020000200222220002000200222000002000020
00000000282282820282002822820000eb152eef0000000000000666666666666666660000028882000282000282002822888882028202822888200028200282
000000002828228228282028282000001226e715000000000000d111111111111111116000282228200282000282002828222220028228228222820282000282
000000028282282082282282820000003db298a9000000000000d111111111111111116002820028202828200288028828220000028282282002820282002820
000000028820282820282288200000008a424554000000000000d111111111111111116002820282028228202828288288882000028820282002822820002820
00000028820282282002288200000000369dd1cb000000000000d111111111111111116028202220028228202828828282220000002822820002822820028200
00000028282282820020282820000000134556380666666666661111111111111111116028228820288888228202282820000000028202820028228200028200
0000028228282282228282282000000020d2c91ad111111111111111111111111111116028202282822228228200282820000000028202820028228200282000
0000028228282028882282282000000025ed2538d111111111111111111111111111116002822822820028282002828222220000282000282282028222820000
77777777777777777777777077777777f7463c27d111111111111111111111111111116000288228200028282002828888882000282000028820002888200000
707070707000070000700070707000079dc71c54d111111111111111111111111111116000022002000002020000202222220000020000002200000222000000
7070707077770777707077777070777700000000d111111111111111111111111111116000000222002000020022222022220000020000000202002000020020
7070707070000700007077000070000700000000d111111111111111111111111111116000002888208200282288888288882000282000002828228200282282
7000007070777707707077077077770700000000d111111111111111111111111111116000028222828202822822222282228200282000002828228200282282
7707077070000700007077000070000700000000d111111111111111111111111111116000282002828202822822002820028200282000028228228820282282
07777777777777777777777777777777000000000ddddddddddddddddddddddddddddd0000282002828208228888202822282000282000028282282822822820
00000000000000000000000000000000000000000000000000000000000000000000000002820002828228228222028288820000282020282282282822822820
00000000000000000000000000000000000000000000000000000000000000000000000002820028228282282000028282200000282282282822822822822820
00000000000000000000000000000000000000000000000000000000000000000000000002820028228282282000282028200000282882822822822828202200
00000000000000000000000000000000000000000000000000000000000000000000000000282282028822822222282002820000288282828228202828228200
00000000000000000000000000000000000000000000000000000000000000000000000000028820028202888888282000282000282028228228200282028200
00000000000000000000000000000000000000000000000000000000000000000000000000002200002000222222020000020000020002002002000020002000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020200010101010100000002020000000000000101010101010000020200000202020201010001010000000202020202020202020201010101000002020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
626360616263606162636263606162636263606174744c6c6d7575757575756c6c6d4d606162636263606162636061606160616263606162634c6f6c6d6e6f75757575757575756c6d6e6f6c6d6c6d6e6f6c6d6e6f4d7474744c6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c754d6360616263626362637474744c6c6d6e6f6c6d
727370717273707172737273707172737273707174745c7c7d7575757575757c7c7d5d707172737273707172737071707170717273707172735c7f7c7d7e7f75757575757575757c7d7e7f7c7d7c7d7e7f7c7d7e7f5d7474745c7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c755d7370717273727372737474745c7c7d7e7f7c7d
5043434343434351434343514351434343434343435110504774747474747448534343434353695050515050434343435243434343434343434343435051477474747474747474485343434343434343434343434352534353524343434343434343431010435051515167746851115143434343434343435353524343494a4b
5150434343434350434343431043434343434343435069515774747474747478434343434343434343504343104343434343434343434343431043114343545555555555555555564310114343434343434343434343431e43434343434343434343431010434350505047747645454546434343434343434343434343494a4b
5043434343516950434343434343434343434343434310504774747474747478434343434343434343434343434311434343434343434343434310434343435053515052434353434310434343434343434343434343434343434343434343434343431010434343434354555555555556104343434343434343434343494a4b
4343434343434352434343434343434343434343434343435455555555555556431053434343434343434343104343434353434343434343431043114343444545454545454545464310114343434343434343434343434343434343434343434445454545454546435244454545454546104343434343434343434304494a4b
4343434343434343434343431043434343434343535210504343524343431053104310434343434352434343434343434343434343434343434310435050777474747474747474784343434343434343434343435069503f50504343434350505774655555555556434357655555555556434343434343535243434343494a4b
4343434343434343434343434343434343534343535350514343434343434310435343434343434343434343435343694343434343434343434350505169577474747474747474785152434343434343434343435050515151695043435050514774485111515050434367484343114343434343434343434343434343494a4b
6c6d6e6f6c6d6e6f6c6d6c6d4d754c6f6c6d6e6f6c6d6e6f6d6e6f6c6d6e6f6e6f4d754c6f6c6d6c6d6c6d6e6f6c6d6e6f6c6d6e4d74744c6f6c6d6e6f6c6d6e6c756c6d6f6c6d6e6f6c6d6e6c6d6e6f6c4d7474744c6d6e6f6c6d6e6f6c6d6e6d7575756f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e
7c7d7e7f7c7d7e7f7c7d7c7d5d755c7f7c7d7e7f7c7d7e7f7d7e7f7c7d7e7f7e7f5d755c7f7c7d7c7d7c7d7e7f7c7d7e7f7c7d7e5d74745c7f7c7d7e7f7c7d7e7c757c7d7f7c7d7e7f7c7d7e7c7d7e7f7c5d7474745c7d7e7f7c7d7e7f7c7d7e7d7575757f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e
5a43434343534343504343434774484343435243434343434343514311434350514774684343111143434343434353434343434343431e434343505169515053477448434343434343444545454545454545647478431e4343431e434343534347747474685311111e1e43434353434343434343434343434343434343434343
5a52434343434307434343525455564307434343434343434343434343074343507774764545454546434343435243524343434343434343435343434343434354555643074446435154555555555555555555555643434343434343505150437774747476454545454545454545454643434343434343434343434343505150
5a43434343514343434343434343434343114343434343434343434343074343435455555555555556434343434343434343434343070711434343434343434343434307077758505051434343070743504343434343434343434343513f51435455555555555555555555555555555643434343434350434343434304516951
3f434343434343534343434343434343075243434343434343434343430743434343434343434343070707434343434343434343434343434343434343524343434446430757484311434343430707434343435044454546430707075051504343434343431e1e1e070707070707074343434343434343434343434343505150
5a43434352434307435043434343434343114343514344454643434343074343434343534343434307070743434343434343434343434343434343434343434343575843434758431143434343070743434445456474745843071107434343434343444545454545454545454545454643434343434343434343434343434343
5a43434343434343434343514343434307434343434357745843434311434343435352434343434307070743434343434343434343535253434343434343434343477645456448434350515344454545456474747474744853434343434343435343577474747474747474747474655643434353525253434343434343434343
6c6d6e4d754c6e6f6c6d6e6f6c6f6c6f6e6f6c6d6c6d6c6d6f6e6f6c6d6d6f6e6f6c6d6e6f6c6d6e6f6c6d6e6f756c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6f6c6d6e6f6c6c6d6e6f6c6d6e6f6c4d747475757575757575757575757575757574744c6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c4d
7c7d7e5d755c7e7f7c7d7e7f7c7f7c7f7e7f7c7d7c7d7c7d7f7e7f7c7d7d7f7e7f7c7d7e7f7c7d7e7f7c7d7e7f757c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7f7c7d7e7f7c7c7d7e7f7c7d7e7f7c5d747475757575757575757575757575757574745c7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c5d
4343434774484343434343434353525253434320505043434343434343434343434343434343434343434352477448434353434343434343434343434350535252535043434343434343434343434343434343434343434343435455555555555555555555555555555555555643434343434343434343535253434343494a4b
5352525455564343434343434343434343434307434343071143434320434446434343434343434343432043777458434343431744454643434343434343514343514343174343434343434343435343174343434343434343434343434343535253434343202017204343434343434343434343434343434343434343494a4b
43434343505150434343434343434343434343074343430743434343435077584343434343434343434343537774685344454653577458434343434343434343434307074343434343434343435352431e4343204343434343434343434343435352534343202017204343434343434343434343434343434343430443494a4b
434343433f43525353434343434343434343432050515107114343434351574843434343434343432e432043577448435774581747746852434343434343434343430707434343434343434350513f511e4343204343434343434344454545454545454545454545454545454545454546434353525343434343434343494a4b
4343434445464343434343434343434343434307434350434343434320504758434343434343434343434343477478436774764564747646434343434343434343534343174343434343434343535243174343434343434343434464747474747474747474747474747474747474747478434343434343435352534343494a4b
4343435774584343434343434343434343434320434343434343434350695748695150434343434343432043545556524774747474747458434343434343434343515343434343434343434343435343434343434343434343435455597474747474747474747474747474747465597458434350505150434343434343494a4b
a4a0a2a1a1a075a1a1a2a0a1a0a3a1a0a2a1a0a3a2a1a0a2a0a3a1a0a3a0a1a275a1a0a3a1a2a0a1a3a0a3a2a1a2a0a1a3a0a1a3a2a3a0a1a0a2a1a0a3a1a0a2a1a0a375a0a1a2a0a0a1a3a0a1a2a3a2a0a1a3a0a0a1a375a1a0a2a3a0a1a0a2a1a0a3a2a1a2a3a0a2a1a2a1a3a0a1a2a1a3a0a2a3a0a1a2a3a0a3a1a2a3a1a5
b4b0b2b1b1b075b1b1b2b0b1b0b3b1b0b2b1b0b3b2b1b0b2b0b3b1b0b3b0b1b275b1b0b3b1b2b0b1b3b0b3b2b1b2b0b1b3b0b1b3b2b3b0b1b0b2b1b0b3b1b0b2b1b0b375b0b1b2b0b0b1b3b0b1b2b3b2b0b1b3b0b0b1b375b1b0b2b3b0b1b0b2b1b0b3b2b1b2b3b0b2b1b2b1b3b0b1b2b1b3b0b2b3b0b1b2b3b0b3b1b2b3b1b5
43434343434774481717171743534343434343434343535253435352534347747474747474747474746843434343434343435051515043434343434343435051777474747474747474747474746817170707074343434774485051504343434343432e2043434343434343434307204343434343434343434343434350494a4b
43435253437774794545454545454643434343434343434445454643434354555555555555555559746843434343432e2e4343506950434343434343434343507774747474747474747474747476454545454546433f777458516951434343434343432044464343434343434307204343525343434343434343434343494a4b
4343434343545555555555555555562043435343434343777474784343430707072043204350516774684343434343434343434343434343434343434343434354555555555555555555555555555555555555564343777468505050434343434343432077781743434343434307204343434343434343434343434343494a4b
513f515043434343432e2e4343434343434343434343537774747843434307070720432043435067746843434445454545454545464343434343434343434343444545454545454545454545454545454545454650437774684353525343434343432e2077781743695150434307204353434352434353434343430443494a4b
5343434343444545454545454545454545454545454545647474784343430707072043204343434774484353776555555555555556434343434343434343434377747474747474747474747474655555555555564343777448434343434343434343432077781743434343434307204352434353434343434343434343494a4b
43434343515774747474747474747474747474747474747474747843434343434343434343434354555653527768171743434353525343432e2e434351695043777474747474747474747474746817170707074343435455564343434343434343432e2077784343434343434307204343434343434343434343434343494a4b
__sfx__
010400000832004310023200130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000400000751709527075370b51700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
010400001351715527135371751700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001f517215271f5372351700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01050000176200d610023300030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000300000a110061100f120061100a110051100f12000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010400000d7100d7200d73011740117501176011770000000a6000a60005600056000a6000a600056000560000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000a6500a65005650056500a6500a6500565005650004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
010900000452507535375553455500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000800001111004120001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0109000026624226302c6502263026625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000461104611076210b62115621236310000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000700000c6210e6110c6310e6010c6010e6010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000176200d610123300232007330033200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00000c525135350e555155551055517555125550d555085550f5551655511555185552b555325550000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000a620076203f5203d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00201312513105171251a1251a1051a1251a1251a1051a1251a1051712513125131051312513125131051a1251a1251712513125131051312513125111251312513105171051310513105131051310513105
011a002007153121030000300003000030000300003000030e1530e1530000300003000030000300003000030e1530e1530000300003000030000300003000030715300003071530000307153000030715300003
010d00201f012130121301213012130121301213012130121a012180121701215012130121501217012180121a012170121501200002000020000200002000021f7121a71213712137121f7121a7121371213712
013400102b712007022f712007022b7120070226712007022b712007022f712007022b71200702327120070200702007020070200702007020070200702007020070200702007020070200702007020070200702
011a00201f732000001d732000001a7320000017732000001f7322170221732000001a732000001d7320000013732000001373200000000000000000000000001373200000137320000000000000000000000000
013400000c050000000b03000000070300000005030000000c03000000100300000007030000000b030000000c0300c0000b03017000070300000005030000000c03010000100300000007030000000b03015000
011a00200603306003060330900313033060030600306003060330600306033060031303306003070030600306033060030603300000130330010013033000000603300000060330000013033000000000000000
011a002007125131050b1250e1251a1050e1250e1251a1050e1251a1050b12507125131050712507125131050e1250e1250b12507125131050712507125051250712513105171051310513105131051310513105
013400000711007110071000e0000e1100e11007100070000711007110001000000000110001100010000000071100711000100000000e1100e11000000000000711007110000000000010110111101011013110
013400201a5121a5121f5121f5121e5121e5121e512005021a5121a5121f5121f5121e5121e5121e512005021a5121a5121f5121f5121e5121e5121f5121f5121e5121e5121f5121f5121a5121a5121a51200502
011a00081261312603126031260312613126131260300603126031261312603126031261300603006031261312613126131261300603006031261300603006031261300603006031261312613126131261315603
011000201361300000000000000017613000000000000000136130000000000176131761300000000000000013613116030000000000176130000000000000001361300000000001761317613000000000000000
011000200f512125120f512125120f512125120f512125120f512115120f512115120f512115120f512115120f512125120f512125120f512125120f512125120f512115120f512115120f512115120f51211512
011a00203071500705307150070530715007052f70500705187150070518715007051871500705007050070530715007053071500705187150070518715007053c715007053c7150070518715007051871500705
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000202770227702277022770227702277022770227702277022770227702277022770227702277022770227712277122771227712277122771227712277122771227712277122771227712277122771227712
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
01 13 11 12 10
02 14 11 12 13
03 15 16 43 44
01 17 11 43 44
00 17 11 43 44
02 18 11 43 44
01 1c 1b 43 44
02 1c 1b 1f 44
01 15 16 43 44
00 15 16 43 44
02 15 16 1d 44
02 15 16 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
