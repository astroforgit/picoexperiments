pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- jeremy mondo's semi-pro racquetball
-- by axnjaxn

-- title screen

function inittitle()
	updatefunc = updatetitle
	drawfunc = drawtitle
	offset = {x=0, y=0, vx=0.5, vy=0}
	showtext = false
	textframes = 0
	mondoy = -60
	frames = nil
end

function updatetitle()
	offset.x = (offset.x + offset.vx) % 16
	offset.y = (offset.y + offset.vy) % 16
	if mondoy < 30 then
		mondoy += 4
		if (mondoy >= 30) then
			mondoy = 30
			music(0)
		end
	else
		textframes += 1
		showtext = flr(textframes / 15) % 2 > 0 and frames == nil
	end
	if btnp(4) or btnp(5) and frames == nil then
		music(-1, 1500)
		frames = 45
	end
	if frames != nil then
		frames -= 1
		if (frames <= 0) tutorial()
	end
end

function drawtitle()
	cls()
	pal(13,2)
	for r=-2,16,2 do
		for c=-2,16,2 do
			spr(109, 8*c+offset.x, 8*r+offset.y, 2, 2)
		end
	end
	pal(11,0)
	for r=13,16,2 do
		for c=-2,16,2 do
			spr(96, 8*c+offset.x, 8*r+offset.y, 2, 2)
		end
	end
	map(16, 0, 0, mondoy, 16, 16)
	if (showtext) print("press Ž", 48, 96, 11)
	pal()
end

-- misc

function print_outlined(str, x, y, col_out, col_in)
	for r=-1,1 do
		for c=-1,1 do
			print(str, c+x, r+y, col_out)
		end
	end
	print(str, x, y, col_in)
end

-- tutorial

function tutorial()
	frames = 0
	updatefunc = updatetutorial
	drawfunc = drawtutorial
	if (not showtutorial) charselect()
	showtutorial = false
end

function updatetutorial()
	frames += 1
	if (btnp(4)) charselect()
end

function printc(str, y, col)
	if (col == nil) col = 7
	print(str, 64 - 2 * #str, y, col)
end

function drawtutorial()
	cls()
	
	rectfill(0, 4, 127, 12, 7)
	printc("tutorial", 6, 0)

	printc("hold Ž to charge up your swing", 26)
	printc("and let go when the ball is in", 32)
	printc("the circle", 38)

	x = 25
	y = 64

	spr(16, x - 4, y - 4)
	circ(x, y, 12, 11)

	x = 64

	spr(16, x - 4, y - 4)
	circ(x, y, 12, 9)

	x = 103

	spr(16, x - 4, y - 4)
	circ(x, y, 12, 8)

	circfill(x - 8, y, 1, 2)
	circfill(x - 6, y - 6, 1, 2)
	circfill(x, y - 8, 1, 2)
	circfill(x + 6, y - 6, 1, 2)
	circfill(x + 8, y, 1, 2)

	spr(33, x - 18, y - 2, 1, 1, true)
	spr(34, x - 15, y - 12, 1, 1, true)
	spr(35, x - 2, y - 16, 1, 1)
	spr(34, x + 8, y - 12, 1, 1, false)
	spr(33, x + 11, y - 2, 1, 1, false)

--(diagram)

	printc("when it's your turn,", 90)
	printc("hit the ball to the front", 96)
	printc("and don't let it bounce twice", 102)

--(diagram)

	if (frames % 60 > 30) printc("press Ž", 122)
end

-- intro screens

function charselect()
	music(4)
	updatefunc = updatecharselect
	drawfunc = drawcharselect

	x = 0
	y = 0
	s = "jeremy mondo's semi-pro racquetball"
	n = 4 * #s + 4
	frames = 0

	names = {
		"'beej' barney jacobi",
		"leia m. himalaya",
		"tommy 't. jack' jacobi",
		"paul 'southpaw' botox"
	}
	names_short = {
		"barney",
		"leia",
		"tommy",
		"paul"
	}
	index = 1
end

function updatecharselect()
	if btnp(4) or btnp(5) then
		tournament = {
			playername = names[index],
			playername_short = names_short[index],
			round = 1
		}
		initmatch()
		music(-1,1000)
		return
	end

	x = x - 1
	y = y - 1
	if y < -12 then
		y += 10
		x = (x + n / 5) % n - 192
	end

	frames += 1

	if (btnp(2) and index > 1) index -= 1
	if (btnp(3) and index < #names) index += 1
end

function drawcharselect()
	cls()

	pal(0, 1)
	pal(7, 12)
	rectfill(0, 0, 127, 127, 0)
	x1 = x
	y1 = y
	while y1 < 128 do
		x1 = x1 % n - 192
		while x1 < 128 do
			print(s, x1, y1, 7)
			x1 += n
		end
		x1 += n / 5
		y1 += 10
	end
	pal()

	s1 = "character select"
	rectfill(0, 4, 127, 12, 7)
	print(s1, 64 - 2 * #s1, 6, 1)

	y1 = 64 - #names * 5
	if frames % 2 > 0 then
		pal(1, 0)
		palt(2, true)
	else
		pal(2, 0)
		palt(1, true)
	end
	for i=1,#names do
		for c=2,118,4 do
			spr(104, c, y1, 1, 1)
		end
		if (i == index) rectfill(2, y1, 125, y1 + 8, 10)
		print_outlined(names[i], 4, y1 + 2, 0, 7)
		y1 += 10
	end
	pal()
end

-- match intro

function initmatch()
	names = {
		"coby shears",
		"harry yep",
		"'sidewinder' guy ramunujan",
		"jasun brost",
		"jeremy mondo"
	}
	names_short = {
		"coby",
		"harry",
		"guy",
		"jasun",
		"jeremy mondo"
	}
	points = {3, 3, 5, 5, 7}

	ai = {
		{spread=0.3, lookahead=20, reaction=15, chase=15, fatigue = 1, speed = 0.8, maxpower = 12, reach = 12},
		{spread=0.2, lookahead=40, reaction=10, chase=10, fatigue = 5, speed = 1.0, maxpower = 12, reach = 12},
		{spread=0.1, lookahead=35, reaction=10, chase=10, fatigue = 2, speed = 1.25, maxpower = 8, reach = 12},
		{spread=0.125, lookahead=40, reaction=5, chase=10, fatigue = 1, speed = 1.25, maxpower = 9, reach = 11},
		{spread=0.1, lookahead=50, reaction=3, chase=5, fatigue = 1.25, speed = 1.5, maxpower = 10, reach = 12}
	}

	match = {
		p1score = 0,
		p2score = 0,
		template = ai[tournament.round],
		opponent = names[tournament.round],
		opponent_short = names_short[tournament.round],
		towin = points[tournament.round],
		serve = 0
	}

	frames = 0

	updatefunc = updatematch
	drawfunc = drawmatch
end

function updatematch()
	frames += 1
	if (frames >= 120 and (btnp(4) or btnp(5))) initgame()
end

function octothorpe(x, y, col)
	line(x + 1, y, x + 1, y + 4, col)
	line(x + 3, y, x + 3, y + 4, col)
	line(x, y + 1, x + 4, y + 1, col)
	line(x, y + 3, x + 4, y + 3, col)
end

function drawmatch()
	flyin = 30
	beginfade = 60
	endfade = 65

	cls()

	if frames % 2 > 0 then
		pal(1, 7)
		pal(2, 6)
 	else
		pal(2, 7)
		pal(1, 6)
	end
	for c=0,120,8 do
		spr(104, c, 60, 1, 1)
	end

	if frames < beginfade then
		print("match " .. tournament.round, 50, 62, 8)
	elseif frames < endfade then
		print("match " .. tournament.round, 50, 62, 15)
	end

	if frames >= flyin then
		t = frames - flyin
		t = min(3 * t, 48)
		print(tournament.playername, 64 - 2 * #tournament.playername, t, 7)
	end

	if frames < beginfade then
		palt(8, true)
	elseif frames < endfade then
		pal(8, 15)
	end
	spr(160, 52, 56, 3, 2)
	pal()

	if frames >= endfade then
		t = frames - endfade
		t = min(3 * t, 53)
		str = #names - tournament.round + 1 .. " " .. match.opponent
		octothorpe(64 - 2 * #str - 3, 128 - t, 7)
		print(str, 64 - 2 * #str + 3, 128 - t, 7)
	end

	if frames > 120 then
		str = match.towin .. " point game"
		print(str, 64 - 2 * #str, 90, 7)
		if (frames % 30 >= 15) print("press Ž", 48, 96, 7)
	end
end

-- game

function loadplayer(player, template)
	player.ai = {state = 0, dstx = 64, dsty = 64, waitchg = 0, waithit = 0}
	for k,v in pairs(template) do
		player.ai[k]  = v
	end
	player.speed = template.speed
	player.maxpower = template.maxpower
	player.reach = template.reach
end

function initgame()
	wall = {
		x0 = 8,
		x1 = 120,
		y0 = 8,
		y1 = 127
	}
	damping = 0.02
	stop_threshold = 0.25
	servebounce = 70
	firstbounce = 60
	secondbounce = 45

	beginserve()
end

-- service

function beginserve()
	sparks = { }
	ball = {
		inplay = false,
		x = 64,
		y = 54,
		vx = 0,
		vy = -1,
		speed = 0,
		tillbounce = 0,
		bounces = 0,
		hitwall = false,
		next=2
	}
	p1 = {
		id = 1,
		x = 60,
		y = 100,
		w = 8,
		h = 8,
		speed = 2,
		tile = 16,
		moving = false,
		animframes = 0,
		power = 0,
		maxpower = 10,
		reach = 12,
		flip = tournament.playername_short == "paul",
		pink = tournament.playername_short == "leia"
	}
	p2 = {
		id = 2,
		x = 60,
		y = 100,
		w = 8,
		h = 8,
		tile = 16,
		moving = false,
		animframes = 0,
		power = 0,
		flip = false,
		pink = false
	}
	loadplayer(p2, match.template)

	if match.serve == 0 then
		p1.x = 86
		p2.x = 42
		ball.x = 90
		ball.y = 100
		ball.next = 1
	elseif match.serve == 1 then
		p1.y = 54
		ball.next = 1
	else
		p2.y = 54
		ball.next = 2
	end
	frames = 0
	panic = nil
	updatefunc = updateserve
	drawfunc = drawserve
end

function updateserve()
	frames += 1
	if ball.next == 1 then
		if (not btnp(5)) return
	else
		if (frames < 60) return
	end

	serve()
	updatefunc = updategame
	drawfunc = drawgame
end

function drawserve()
	drawgame()
	if (match.serve != 2 and frames % 30 >= 15) print("press — to serve", 30, 68, 0)
end

function splash(th, basespeed, maxspeed, falloff, col)
	if (basespeed == nil) basespeed = 1
	if (maxspeed == nil) maxspeed = 3
	if (falloff == nil) falloff = 0
	if (col == nil) col = 9
	for i = -2,2 do
		t = 0.05 * i
		v = rnd(maxspeed - basespeed) + basespeed
		add(sparks, {x = ball.x, y = ball.y, vx = v * cos(th + t), vy = v * sin(th + t), life = 20, col = col, falloff = falloff})
	end
end

function splashc(speed, falloff, col)
	if (speed == nil) speed = 1.25
	if (falloff == nil) falloff = 0.125
	if (col == nil) col  = 14
	for t = 1.0/16,1.0,1.0/16 do
		add(sparks, {x = ball.x, y = ball.y, vx = speed * cos(t), vy = speed * sin(t), life = 15, col = col, falloff = falloff})
	end
end

function serve()
	if match.serve == 0 then
		t = rnd(0.05) + 0.275
	else
		t = rnd(0.1) + 0.2
	end
	ball.vx = cos(t)
	ball.vy = sin(t)
	ball.speed = 5
	ball.inplay = true
	ball.tillbounce = servebounce
	splash(t, 1, 3, 0.05)
	sfx(24)

	debug_msg = ""
end

-- rally

function checkhit(p)
	-- only check hit when in play
	if (not ball.inplay or ball.hitwall == false or ball.next != p.id) return

	-- ball must be in motion to hit it
	if (#ball == 0) return

	-- get ball's last frame movement
	x0 = ball[#ball].x0 - p.x - p.w / 2
	y0 = ball[#ball].y0 - p.y - p.h / 2
	x1 = ball[#ball].x1 - p.x - p.w / 2
	y1 = ball[#ball].y1 - p.y - p.h / 2
	
	-- todo: find x, y as closest point?
	x = x1
	y = y1

	-- collision check
	r = sqrt(x^2 + y^2)
	test = false
	if (not test and r > p.reach + 1) return

	-- cut the path at x,y
	ball.x = x + p.x + p.w / 2
	ball.y = y + p.y + p.h / 2
	ball[#ball].x1 = ball.x
	ball[#ball].y1 = ball.y

	-- angle from player to ball	

	-- determine new angle
	th = atan2(x, -abs(y))
	ball.vx = cos(th)
	ball.vy = sin(th)

	-- determine new ball speed
	ball.speed = max(p.power + 2.5, ball.speed)
	ball.tillbounce = firstbounce
	ball.bounces = 0
	ball.hitwall = false

	if ball.speed > 7.0 then
		splash(th, ball.speed / 5, 2 + ball.speed / 5, 0.05)
		sfx(24)
	else
		splash(th, 0.25, 0.5, 0.0, 12)
		sfx(25)
	end
end

function animplayer(p)
	if p.moving then
		p.animframes -= 1
		if p.animframes <= 0 then
			p.animframes = 2
			p.tile = 17 + p.tile % 2
		end
	else	
		p.tile = 16
	end
end

function doctrl(p)
	speed = p.speed * (1 - max(0, p.power / p.maxpower))

	if ((btn(0) or btn(1)) and (btn(2) or btn(3))) speed /= sqrt(2)

	if btn(0) then
		p.x -= speed
		if (p.x < wall.x0) p.x = wall.x0
	end
	if btn(1) then
		p.x += speed
		if (p.x + p.w >= wall.x1) p.x = wall.x1 - p1.w
	end
	if btn(2) then
		p.y -= speed
		if (p.y < wall.y0) p.y = wall.y0
	end
	if btn(3) then
		p.y += speed
		if (p.y + p.h >= wall.y1) p.y = wall.y1 - p1.h
	end

	p.moving = speed > 0 and (btn(0) or btn(1) or btn(2) or btn(3))
	
	if not btn(4) then
		if (p.power > 0) checkhit(p)
		p.power = 0
	elseif p.power >= 0 then
		p.power = 1.035 * p.power + 0.1
		if (p.power > p.maxpower) p.power = p.maxpower
	end
end

function ceil(x)
	return -flr(-x)
end

function predict(p)
	-- number of frames to simulate
	n = ball.tillbounce + secondbounce - 1
	dopanic = (p.ai.state == 0) -- panic if no solution possible

	-- prediction
	best = -n
	p.ai.dstx = p.x
	p.ai.dsty = p.y
	p.ai.waithit = 2 * n
	p.ai.waitchg = 0
	p.ai.state = -1 --panic if no solution found
	p.animframes = 0

	-- simulated ball position
	x = ball.x
	y = ball.y
	vx = ball.vx
	vy = ball.vy
	speed = ball.speed
	for i=1,n do
		-- advance ball position
		x += vx * speed
		if x < wall.x0 then
			x = 2 * wall.x0 - x
			vx = -vx
		elseif x > wall.x1 then
			x = 2 * wall.x1 - x
			vx = -vx
		end
		y += vy * speed
		if y < wall.y0 then
			y = 2 * wall.y0 - y
			vy = -vy
		elseif y > wall.y1 then
			y = 2 * wall.y1 - y
			vy = -vy
		end
		speed = (1 - damping) * speed

		-- determine desired hit position
		th = (2 * rnd() - 1) * p.ai.spread + 0.25
		if (rnd() < 0.5) th = -th
		r = rnd(p.reach - 3) + 3

		-- time to arrive at hit position in frames
		hx = x + r * cos(th) - p.w / 2
		hy = y + r * sin(th) - p.h / 2
		if hx > wall.x0 and hx + p.w < wall.x1 and hy > wall.y0 and hy + p.h < wall.y1 then
			t = sqrt((hx - p.x) ^ 2 + (hy - p.y) ^ 2) / p.speed
		else
			t = 2 * n -- out of reach
		end
		t += flr(rnd(p.ai.reaction + 1))

		if (t < i) dopanic = false

		-- if amount of "free time" is better, choose it
		if i <= p.ai.lookahead and i - t > best then
			best = i - t
			p.ai.dstx = hx
			p.ai.dsty = hy
			p.ai.waitchg = t
			p.ai.waithit = i - t
			if t < i then
				p.ai.state = 1
			else
				p.ai.state = -1
				p.ai.waitchg = p.ai.chase
			end
		end
	end

	if (dopanic) panic = {player=p, frames=0}
	if (p.ai.state < 0) p.ai.waitchg = p.ai.chase
end

function doai(p)
	if (not ball.inplay) return

	-- first, apply movement
	p.moving = false
	if p.ai.state == 1 or p.ai.state == -1 then
		dx = p.ai.dstx - p.x
		dy = p.ai.dsty - p.y
		d = sqrt(dx ^ 2 + dy ^ 2)

		if d < p.speed then
			p.x = p.ai.dstx
			p.y = p.ai.dsty
		else
			p.x += p.speed * dx / d
			p.y += p.speed * dy / d
		end

		p.moving = (d > 0)
	end

	-- other stateful behavior
	if p.ai.state == 0 then --done
		if (ball.hitwall and ball.next == p.id) then
			predict(p)
			p.ai.lookahead = max(5, p.ai.lookahead - p.ai.fatigue)
			p.speed = max(1.0, p.speed - 0.01 * p.ai.fatigue)
		end
	elseif p.ai.state == 1 then --run/wait
		p.ai.waitchg -= 1
		if (p.ai.waitchg <= 0) then
			p.ai.state = 2
		end
	elseif p.ai.state == 2 then --charging/hit
		p.ai.waithit -= 1
		if p.ai.waithit <= 0 then
			if (p.power > 0) checkhit(p)
			p.power = 0
			p.ai.state = 0
		else
			p.power = 1.035 * p.power + 0.1
			if (p.power > p.maxpower) p.power = p.maxpower
		end
	elseif p.ai.state == -1 then --chase fruitlessly
	       p.ai.waitchg -= 1
	       if (p.ai.waitchg <= 0) predict(p)
	end
end

function pushball(t)
	x0=ball.x
	y0=ball.y
	x1=ball.x+ball.vx*t
	y1=ball.y+ball.vy*t
	ball.x = x1
	ball.y = y1

	if (#ball > 16) del(ball, ball[1])
	add(ball, {x0=x0,y0=y0,x1=x1,y1=y1})
end

function moveball()
	if ball.speed < 0.5 and #ball > 0 then
		del(ball, ball[1])
	end

	total = ball.speed
	while total > 0 do
		if ball.vx < 0 then
			tx = (wall.x0 - ball.x) / ball.vx
		elseif ball.vx > 0 then
			tx = (wall.x1 - ball.x) / ball.vx
		else
			tx = total * 2
		end
		if (tx == 0) tx = total * 2
		
		if ball.vy < 0 then
			ty = (wall.y0 - ball.y) / ball.vy
		elseif ball.vy > 0 then
			ty = (wall.y1 - ball.y) / ball.vy
		else
			ty = total * 2
		end
		if (ty == 0) ty = total * 2
		
		if min(tx,ty) < total then
			if tx < ty then
				pushball(tx)
				total -= tx
				ball.vx = -ball.vx
			elseif tx > ty then
				if ball.vy < 0 and not ball.hitwall then
					ball.hitwall = true
					ball.next = 1 + ball.next % 2
				end
				pushball(ty)
				total -= ty
				ball.vy = -ball.vy
			else
				if ball.vy < 0 and not ball.hitwall then
					ball.hitwall = true
					ball.next = 1 + ball.next % 2
				end
				pushball(tx)
				total -= tx
				ball.vx = -ball.vx
				ball.vy = -ball.vy
			end
			if (ball.speed > 1) splash(atan2(ball.vx, ball.vy), ball.speed * 0.2, ball.speed * 0.6, 0.125, 2)
			sfx(26)
		else
			pushball(total)
			total = 0			
		end
	end
	
	ball.speed = (1 - damping) * ball.speed
	if ball.speed < stop_threshold then
		ball.speed = 0
	else
		ball.tillbounce -= 1
		if ball.tillbounce <= 0 then
			ball.bounces += 1
			splashc()
			ball.tillbounce = secondbounce
			sfx(27)
		end
	end
end

function movesparks()
	for spark in all(sparks) do
		spark.x += spark.vx
		spark.y += spark.vy
		spark.life -= 1
		spark.vx *= (1 - spark.falloff)
		spark.vy *= (1 - spark.falloff)
		if (spark.life < 0) del(sparks, spark)
	end
end

function updategame()
	moveball()
	if ball.inplay and (ball.bounces > 1 or (not ball.hitwall and ball.bounces > 0)) then
		ball.inplay = false
		awardpoint()
	end
	
	doctrl(p1)
	animplayer(p1)
	
	doai(p2)
	animplayer(p2)

	if (panic) panic.frames += 1

	movesparks()
end

function awardpoint()
	updatefunc = updatepoint
	drawfunc = drawpoint

	if ball.next == 1 then
		wait_before_out = 15
	else
		wait_before_out = 0
	end
	wait_after_out = 120

	if match.serve == 0 then --decide serve
		match.serve = ball.next % 2 + 1
		s0 = "p" .. match.serve .. " serve"
	elseif match.serve == ball.next then --switch places
		match.serve = match.serve % 2 + 1
		s0 = "switch sides"
	else
		if match.serve == 1 then
			match.p1score += 1
			s0 = "point p1"
		else
			match.p2score += 1
			s0 = "point p2"
		end
	end
end

function updatepoint()
	wait_before_out -= 1

	moveball()
	movesparks()

	if wait_before_out > 0 then
		doctrl(p1)
		p1.power = 0
		animplayer(p1)
		
		doai(p2)
	 	p2.power = 0
		animplayer(p2)

		return
	end

	-- todo: switch sides or point px

	s1 = max(match.p1score, match.p2score) .. " - " .. min(match.p1score, match.p2score)
	if match.p1score > match.p2score then
		s2 = "adv. p1"
		if (match.p1score >= match.towin) s2 = "p1 win"
	elseif match.p2score > match.p1score then
		s2 = "adv. p2"
		if (match.p2score >= match.towin) s2 = "p2 win"
	else
		s2 = "tie game"
	end
	s3 = ""
	if ((match.p1score == match.towin - 1 and match.serve == 1) or (match.p2score == match.towin - 1 and match.serve == 2)) s3 = "match point"
	
	wait_after_out -= 1
	if wait_after_out <= 0 then
		if match.p1score >= match.towin then
			winmatch()
		elseif match.p2score >= match.towin then
			losematch()
		else
			beginserve()
		end		
	end
end

function drawpoint()
	drawgame()
	if wait_before_out <= 0 then
		pal(8,7)
		for r=-1,1 do
			for c=-1,1 do
				spr(133, c+40, r+56, 6, 2)
			end
		end
		pal()
		spr(133, 40, 56, 6, 2)
	end
	
	if wait_after_out <= 90 then
		print_outlined(s0, 64 - 2 * #s0, 80, 7, 0)
		print_outlined(s1, 64 - 2 * #s1, 90, 7, 0)
		print_outlined(s2, 64 - 2 * #s2, 100, 7, 0)
		if (wait_after_out % 2 > 0) print_outlined(s3, 64 - 2 * #s3, 110, 7, 0)
	end
end

function drawgame()
	cls()
	
-- background
	map(0, 0, 0, 0, 16, 16)
	
-- players
	if p1.pink then
		pal(1,14)
		pal(12,13)
	end
	spr(p1.tile, p1.x, p1.y, 1, 1, p1.flip)
	if p1.power <= 0 then
		col=0
	elseif p1.power < p1.maxpower * 0.3 then
		col=11
	elseif p1.power < p1.maxpower * 0.7 then
		col=9
	else
		col=8
	end
	if (col > 0) circ(p1.x+p1.w/2,p1.y+p1.h/2,p1.reach,col)
	pal()

	pal(1,3)
	pal(12,11)
	spr(p2.tile, p2.x, p2.y, 1, 1, p2.flip)
	if p2.power <= 0 then
		col=0
	elseif p2.power < p2.maxpower * 0.3 then
		col=11
	elseif p2.power < p2.maxpower * 0.7 then
		col=9
	else
		col=8
	end
	if (col > 0) circ(p2.x+p2.w/2,p2.y+p2.h/2,p2.reach,col)
	if panic then
		pal(1,0)
		if (panic.frames % 2 == 0 and panic.frames < 10) spr(32,panic.player.x,panic.player.y-9,1,1)
	end
	pal()

-- ball
	if not ball.inplay then
		pal(2,0)
	elseif ball.next == 1 then
		pal(2,2)
	else
		pal(2,3)
	end
	for l in all(ball) do
		line(l.x0,l.y0,l.x1,l.y1,2)
	end
	circfill(ball.x,ball.y,1,2)

-- sparks
	for spark in all(sparks) do
		line(spark.x, spark.y, spark.x - spark.vx, spark.y - spark.vy, spark.col)
	end
	pal()
	
	print(debug_msg,0,0)
end

-- match won screen

function winmatch()
	sfx(9)

	quote = {}
	if tournament.round == 1 then
		quote = {
			"i don't even like racquetball.",
			"i like nickelback and the",
			"phantom menace, and that's it!"
		}
	elseif tournament.round == 2 then
		if tournament.playername_short == "leia" then
			quote = {
				"do you, like, have a sister",
				"or something?"
			}
		else
			quote = {
				"you guys wanna play darts?"
			}
		end
	elseif tournament.round == 3 then
		quote = {"..."}
	elseif tournament.round == 4 then
		if tournament.playername_short == "barney" then
			quote = {
				"guess i'll have to find a",
				"*new* best friend now!"
			}
		elseif tournament.playername_short == "leia" then
			quote = {
				"what are you, the fun police?"
			}
		elseif tournament.playername_short == "tommy" then
			quote = {
				"quit your blabberin' and",
				"saddle up!"
			}
		else
			quote = {
				"liberty and justice for all!"
			}
		end
	elseif tournament.round == 5 then
		quote = {
			"i'm jeremy mondo!"
		}	
	end

	x = 0
	y = 0
	s = "jeremy mondo's semi-pro racquetball"
	n = 4 * #s + 4
	frames = 0

	updatefunc = updatewinmatch
	drawfunc = drawwinmatch
end

function updatewinmatch()
	if btnp(4) or btnp(5) then
		if tournament.round >= 5 then
			wingame()
		else
			tournament.round += 1
			initmatch()
		end
	end

	x = x - 1
	y = y - 1
	if y < -12 then
		y += 10
		x = (x + n / 5) % n - 192
	end
end

function drawwinmatch()
	cls()
	
	pal(0, 3)
	pal(7, 11)
	rectfill(0, 0, 127, 127, 0)
	x1 = x
	y1 = y
	while y1 < 128 do
		x1 = x1 % n - 192
		while x1 < 128 do
			print(s, x1, y1, 7)
			x1 += n
		end
		x1 += n / 5
		y1 += 10
	end
	pal()

	s1 = "match results"
	rectfill(0, 4, 127, 12, 7)
	print(s1, 64 - 2 * #s1, 6, 3)

	result = {
		tournament.playername,
		"def. " .. match.opponent,
		match.p1score .. " - " .. match.p2score
	}

	y1 = 55
	for str in all(result) do
		print_outlined(str, 64 - 2 * #str, y1, 0, 7)
		y1 += 6
	end

	y1 = 96
	print_outlined(match.opponent_short .. ":", 4, y1, 0, 7)
	y1 += 8

	for str in all(quote) do
		rectfill(3, y1 - 1, 124, y1 + 5, 0)
		print(str, 4, y1, 7)
		y1 += 6
	end
end

-- match lost screen

function losematch()
	updatefunc = updatelosematch
	drawfunc = drawlosematch

	x = 0
	y = 0
	s = "jeremy mondo's semi-pro racquetball"
	n = 4 * #s + 4
	frames = 0

	choices = {
		"continue",
		"return to title"
	}
	index = 1
end

function updatelosematch()
	if btnp(4) or btnp(5) then
		if index == 1 then
			initmatch()
		else
			inittitle()
		end
		return
	end

	x = x - 1
	y = y - 1
	if y < -12 then
		y += 10
		x = (x + n / 5) % n - 192
	end

	frames += 1

	if (btnp(2) and index > 1) index -= 1
	if (btnp(3) and index < #choices) index += 1
end

function drawlosematch()
	cls()

	pal(0, 0)
	pal(7, 5)
	rectfill(0, 0, 127, 127, 0)
	x1 = x
	y1 = y
	while y1 < 128 do
		x1 = x1 % n - 192
		while x1 < 128 do
			print(s, x1, y1, 7)
			x1 += n
		end
		x1 += n / 5
		y1 += 10
	end
	pal()

	s1 = "game over"
	rectfill(0, 4, 127, 12, 7)
	print(s1, 64 - 2 * #s1, 6, 0)

	y1 = 64 - #choices * 5
	if frames % 2 > 0 then
		pal(1, 0)
		palt(2, true)
	else
		pal(2, 0)
		palt(1, true)
	end
	for i=1,#choices do
		for c=2,118,4 do
			spr(104, c, y1, 1, 1)
		end
		if (i == index) rectfill(2, y1, 125, y1 + 8, 10)
		print_outlined(choices[i], 4, y1 + 2, 0, 7)
		y1 += 10
	end
	pal()
end

-- game won screen

function wingame()
	updatefunc = updatewingame
	drawfunc = drawwingame

	x = 0
	y = 0
	s = tournament.playername .. "'s semi-pro racquetball"
	n = 4 * #s + 4
	frames = 0

	confetti = {}

	credits = {
		{"logo"},
		{"gap", 4},
		{"lg", "for bimmy"},
		{"gap", 4},
		{"lg", "program + design"},
		{"gap", 1},
		{"sm", "brian jackson (axnjaxn)"},
		{"gap", 3},
		{"lg", "special thanks"},
		{"gap", 1},
		{"sm", "emahlea jackson"},
		{"gap", 1},
		{"sm", "phil bohun"},
		{"gap", 1},
		{"sm", "jasun brost"},
		{"gap", 2},
		{"lg", "and you!"},
		y = 128,
		vy = -0.4
	}
	congrats = {y = 60, vy = -1}

	credits.y -= (congrats.y + 16) * credits.vy

	music(6)
end

function updatewingame()
	if frames > 30 and (btnp(4) or btnp(5)) then
		music(-1, 1000)
		inittitle()
		return
	end

	x = x - 1
	y = y - 1
	if y < -12 then
		y += 10
		x = (x + n / 3) % n - 192
	end

	frames += 1

	if frames % 4 == 0 then
		c = {
			th = rnd(),
			dth = rnd(0.2),
			y = -3,
			x = rnd(125) + 1,
			col = flr(rnd(16))
		}
		add(confetti, c)
	end

	for c in all(confetti) do
		if x > 128 then
			remove(confetti, c)
		else
			c.th += c.dth
			c.y += 1
		end
	end

	if frames > 128 then
		credits.y += credits.vy
		congrats.y += congrats.vy
	end
end

function drawwingame()
	cls()

	pal(0, 7)
	pal(7, 6)
	rectfill(0, 0, 127, 127, 0)
	x1 = x
	y1 = y
	while y1 < 128 do
		x1 = x1 % n - 192
		while x1 < 128 do
			print(s, x1, y1, 7)
			x1 += n
		end
		x1 += n / 3
		y1 += 10
	end
	pal()

	spr(163, 12, congrats.y, 13, 1)

	for c in all(confetti) do
		line(c.x + cos(c.th), c.y + sin(c.th), c.x - cos(c.th), c.y - sin(c.th), c.col)
	end

	if frames > 128 then
		y0 = credits.y
		for credit in all(credits) do
			if (credit == credits[#credits] and y0 < 62) y0 = 62
			
			if credit[1] == "sm" then
				y1 = y0 + 8
				if (y0 < 128 and y1 > 0) print_outlined(credit[2], 64 - 2 * #(credit[2]), y0, 0, 7)
			elseif credit[1] == "lg" then
				y1 = y0 + 8
				if y0 < 128 and y1 > 0 then
				x0 = 64 - 2 * #(credit[2]) - 5
				x1 = 64 + 2 * #(credit[2]) + 3
					print_outlined(credit[2], 64 - 2 * #(credit[2]), y0, 0, 7)
					line(x0 - 20, y0 + 2, x0, y0 + 2, 0)
					line(x1, y0 + 2, x1 + 20, y0 + 2, 0)
				end
			elseif credit[1] == "logo" then
				y1 = y0 + 48
				if (y0 < 128 and y1 > 0) map(16, 0, 0, y0, 16, 6)
			elseif credit[1] == "gap" then
				y1 = y0 + 6 * credit[2]
			end
			y0 = y1
		end
	end
end

-- main functions

function _init()
	debug_msg = ""
	showtutorial = true
	inittitle()
end

function _update()
	updatefunc()
end

function _draw()
	drawfunc()
end
__gfx__
00000000f7f7f7f767777777777777777777777666666666f7f7f7f7f7f7f7f7f7f7f7f8f7f7f7f8f7f7f7f70000000000000000000000000000000000000000
00000000f7f7f7f766777777777777777777776666666666f7f7f7f7f7f7f7f7f7f7f7f8f7f7f7f8f7f7f7f70000000000000000000000000000000000000000
00000000f7f7f7f766677777777777777777766666666666f7f7f7f7f7f7f7f7f7f7f7f8f7f7f7f8f7f7f7f70000000000000000000000000000000000000000
00000000f777f77766667777777777777777666666666666f777f777f777f777f777f778f777f778f777f7770000000000000000000000000000000000000000
00000000f7f7f7f766666777777777777776666666666666f7f7f7f7f7f7f7f7f7f7f7f8f7f7f7f8f7f7f7f70000000000000000000000000000000000000000
0000000077f777f76666667777777777776666666666666677f777f777f777f777f777f877f777f877f777f70000000000000000000000000000000000000000
00000000f7f7f7f766666667777777777666666666666666f7f7f7f7f7f7f7f7f7f7f7f8f7f7f7f8f7f7f7f70000000000000000000000000000000000000000
00000000f7f7f7f7666666667777777766666666666666666666666688888888f7f7f7f888888888878787870000000000000000000000000000000000000000
00440000004400000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004400cc004400cc004400cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011110cc011110cc011110cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40110400401104004011040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000001100000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00440000004400000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04004000004100000014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01001000001000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000700000777700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001a1000000070000007700007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01a1a100777777000070700070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01a1a100000070000700700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1aaaaa10000700007000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1aa1aa10000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1aaaaa10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000880000008888000888888800000888800888000008880008800008800000088800000888000008888000088000008800880000000000888800000880000
00000880000888888008888888880088888800888800008880008800008800000088880000888000088888800088800008808888880000008888880000880000
00000880000888000008880008880088800000888880088888008800008800000088888008888800888888880088880008808888888800088888888008800000
00000888000880000008800000880088000000888888088888008800008800000088888808888808880000888088888008808800888880888000088808800000
00000088000880000008800000880088000000888888888088008800008800000088888888808808800000088088888808808800008880880000008800000888
00000088000880000008800000880088000000088088888088008880008800000008808888808808800000088088088888808800000880880000008800008888
00000088800880000008800008880088000000088008888088008888088800000008800888808808800000088088008888808800000880880000008800008800
00000008800888888008888888880088888800088000000088000888888800000008800000008808800000088088000888808800000880880000008800008880
00000008800888888008888888800088888800088000000088000008888800000008800000008808800000088088000088808800000880880000008800000888
00000008800880000008800008800088000000088000000088000000008800000008800000008808800000088088000088808800000880880000008800000088
00000008800880000008800008800088000000088000000088000000088800000008800000008808800000088088000008808800000880880000008800008888
88000008800880008808800008800088000880088000000088000000088800000008800000008808800000088088000008808800000880880000008800008880
88000088800880088808800008880088008880088000000088000000888000000008800000008808800000088088000008808800008880880000008800000000
88000088800888888808800008880088888880088000000888000888880000000008800000088808880000888088000008808800088880888000088800000000
88888888000888880000000000880088888000088000000880008888880000000008800000088008888888888088000008808888888800888888888800000000
08888888000000000000000000880000000000088000000880008880000000000008800000088000888888880088000000008888888000088888888000000000
b444b444b444b4440000000555555555555555555555555555555555500000002121212100000000000000000000000000000000777777777777777600000000
b444b444b444b4440000005556656665665665666555566556655566550000001212121200000000000000000000000000000000777777777777777600000000
b444b444b444b4440000055565556555656565565555565656565656555000002121212100000000000000000000000000000000777777777777777600000000
b444b444b444b4440000055566656655655565565566565656565656555000001212121200000000000000000000000000000000777777777777777600000000
b444b444b444b4440000055555656555655565565555566556655656555000002121212100000000000000000000000000000000666666666666666600000000
b444b444b444b4440000055555656555655565565555565556565656555000001212121200000000000000000000000000000000777777767777777700000000
b444b444b444b4440000005566556665655565666555565556565665550000002121212100000000000000000000000000000000777777767777777700000000
b444b444b444b4440000000555555555555555555555555555555555500000001212121200000000000000000000000000000000777777767777777700000000
b444b444b444b4440011111000111100011111001111001100110111111011111101111100011110011000001100000000000000777777767777777700000000
b444b444b444b4440011111101111110111111011111101100110111111011111101111110111111011000001100000000000000777777767777777700000000
b444b444b444b4440011001101100110110000011001101100110110000000110001100110110011011000001100000000000000777777767777777700000000
bbbbb444b444b4440011001101100110110000011001101100110111100000110001100110110011011000001100000000000000777777767777777700000000
b444b444b444b4440022222002222220220000022002202200220222200000220002222200222222022000002200000000000000666666666666666600000000
b444b444bbbbb4440022002202200220220000022022002200220220000000220002200220220022022000002200000000000000777777777777777600000000
b444b444b444b4440022002202200220222222022222202222220222222000220002200220220022022222202222220000000000777777777777777600000000
b444b444b444b4440022002202200220022222002202200222200222222000220002222200220022022222202222220000000000777777777777777600000000
00000888888000000880088888000000888888800000008888000000880000000880088888888888800008800000000000000000000000000000000000000000
00008888888880000880088888880000888888800000888888800000880000000880088888888888800008800000000000000000000000000000000000000000
00088800008880000880088000888008880000000008888888880008880000000880000000880000000008800000000000000000000000000000000000000000
00088000000000008880088000088008880000000088800008880008880000000880000000880000000008800000000000000000000000000000000000000000
00088000000000008800880000088008800000000088800000888008800000000880000000880000000088800000000000000000000000000000000000000000
00088800000000008800880000088008800000000888000000888008800000000880000000880000000088800000000000000000000000000000000000000000
00088888800000008800880000088008888888000880000000088008800000008880000008880000000088000000000000000000000000000000000000000000
00008888888800008800880000088008888888000880000000088008800000008800000008800000000088000000000000000000000000000000000000000000
00000000888880008800880000088088000000000880000000088008800000008800000088800000000888000000000000000000000000000000000000000000
00000000000880088808800000088088000000000880000000888008800000088800000088800000000888000000000000000000000000000000000000000000
00000000000880088008800000880088000000000888000008888008880000088800000088000000000880000000000000000000000000000000000000000000
00888000088800088008800008880088000000000888800888880008888000888000000888000000000000000000000000000000000000000000000000000000
00888888888800088008888888800088888880000088888888800000888888888000000880000000088000000000000000000000000000000000000000000000
00008888880000088008888888000088888880000008888880000000088888880000000880000000088000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001111100111100110011001111001111100011110011111101100110110000001111001111110111111001111001100110011111
88000000008800008888880011111101111110111011011111101111110111111011111101100110110000011111101111110111111011111101110110111111
88800000008800088888888811000001100110111111011001101100110110011000110001100110110000011001100011000001100011001101111110110000
88800000008800888000088811000001100110110111011000001100110110011000110001100110110000011001100011000001100011001101101110111110
08880000088800880000000022000002200220220022022022202222200222222000220002200220220000022222200022000002200022002202200220022222
08880000088000880000000022000002200220220022022002202200220220022000220002200220220000022002200022000002200022002202200220000022
00880000088000888000000022222202222220220022022222202200220220022000220002222220222222022002200022000222222022222202200220222222
00888000888000888888000002222200222200220022002222002200220220022000220000222200222222022002200022000222222002222002200220222220
00888008880000088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088008880000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088088800000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888800000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888000008880000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888000008888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008880000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
02030303030303030303030303030304404142434445464748494a4b4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05010101010101010101010101010105505152535455565758595a5b5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000006263646566670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0507070707070707070707070707070500000072737475767778797a7b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0508080101010101010101010808010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0509090707070707070707070909070500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050a0a0a0a0a0a0a0a0a0a0a0a0a0a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0506060606060606060606060606060500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000001c760000001c760000001c7600000000000000001a7600000000000000001d760000001d760000001d760000001a700000001c7600000018700000001a76023700000000000000000000000000000000
011000001876000000187600000018760000000000000000177600000000000000001a760000001a760000001a760000001a70000000187600000018700000001776023700000000000000000000000000000000
011000001c760000001c760000001c760000001c700000001a7600000000000000001876000000000000000017760000000000000000000000000000000000000000000000000000000000000000000000000000
011000001876000000187600000018760000001c70000000177600000000000000001576000000000000000013760000000000000000000000000000000000000000000000000000000000000000000000000000
011000201c760007001c760007001c7600070000700007001f760007001c700007001c76018700187001870018760007000070000700007000070000700007001870000700007000070000700007000070000700
0110002018760007001876000700187600070000700007001c760007001c700007001876018700187001870015760007000070000700007000070000700007001870000700007000070000700007000070000700
01100020187551c7551f75523755187551c7551f755237552175524755287552b7552175524755287552b7551d7552175524755287551d7552175524755287551f7552375526755297551f755237552675529755
011000201c7551f75523755267551c7551f75523755267552175524755287552b7552175524755287552b7551d7552175524755287551d7552175524755287551f7552375526755297551f755237552675529755
011000100043501435004350040500435014350043500405044350543504435084050043501435004350040500405004050040500405004050040500405004050040500405004050040500405004050040500405
011000001323515235162351823515232152321123513235002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
011000001307215002180721a00215072180021c07200002160721a0021d0720000217072190021b0720000215072180721c0721f00215072180021c0721f0721107216072190020000213072150021807200002
011000001300015000150001700011000150001300013000150001600016000000001700015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110002018615000051a605000052c6152c6052c60500005186150000518615000052761500005000050000518615000050000500005276150000500005000051861500005186150000527615000050000500005
011000001c62500605216251d62500605006051c62500605186251a6251c6251d6251f625216251f6251d6251c625006051c625006051f625006051e625006051c6251a6251c6251d6251f625216251f6251d625
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002b635186101c6201c6201c6100e6100e61000610006000060000600006000060029600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01080000246150c5040c6041a6040c604006040e60400604006040060400604006040060429604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
000400000c0550c030100401003010025100000e00000000000000000000000000000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c0550b0250b0000b0050b005100000e00000000000000000000000000000000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 00 01 08 10
00 02 03 08 10
00 00 01 08 10
02 04 05 08 10
01 06 11 43 44
02 07 11 43 44
00 41 42 08 44
00 41 10 08 44
00 06 10 08 44
00 06 10 08 44
00 06 10 43 44
00 06 10 43 44
00 07 42 43 44
04 06 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
