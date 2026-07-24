pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- alfonzo's bowling challenge
-- by kittenm4ster

state_coach = 1
state_pinbot = 2
state_play = 3
state_score = 4
state_credits = 5
state_end = 6

pbstate_present = 1
pbstate_present_done = 2
pbstate_move = 3
pbstate_move_done = 4

coachstate_wait = 1
coachstate_title = 2
coachstate_done = 3

mode_bowl = 1
mode_breakfast = 2
mode_breakout = 3
mode_bb = 4
mode_bj = 5
mode_bird = 6
mode_bro = 7
mode_barber = 8
mode_boss = 9
b_words = {
	"bowling",
	"breakfast",
	"breakout",
	"basketball",
	"blackjack",
	"birdwatching",
	"brother's",
	"barbershop",
	"bossfight",
}
credits = {
	"created by",
	"andrew",
	'"kittenm4ster"',
	"anderson",
	"",
	"with lots of",
	"help from",
	"aubrianne",
	"anderson",
	"",
	"playtesting",
	"by",
	"amos anderson",
	"",
	"5x6 font by",
	"zep"
}

font = "abcdefghijklnopqrstuvw'"
ballr = 4
netw = 12
ranktxt = {
	[1] = 'a',
	[11] = 'j',
	[12] = 'q',
	[13] = 'k'
}
faces = {
	{11, 72},
	{35, 96},
	{51, 96},
	{67, 96},
	{83, 96},
	{99, 96},
	{35, 112},
	{51, 112},
	{67, 112},
	{83, 112},
	{99, 112},
	{35, 64},
}

function _init()
	tutorialon = true
	tutorial = {y = 110, vy = 0}
	platforms = {
		{x = 0, y = 124, vy = 0, oy = 75, w = 32, h = 1},
		{x = 96, y = 124, vy = 0, w = 32, h = 1}
	}

	actors = {}
	vactors = {}
	balls = {}
	bricks = {}
	fixtures = {}
	pins = {}
	sprites = {}
	knockables = {}
	knockers = {}
	players = {}
	bjbtns = {}
	eggs = {}
	yolks = {}
	paneggs = {}
	targets = {}
	clearables = {}

	particles = {}

	player_colors = {12, 8, 9, 10, 11, 14, 4, 7}
	playercount = 0
	totalscore = 0
	score = 0
	message = {timer = new_timer(120)}
	message.timer.expire()
	pitimer = new_timer(180)

	coroutines = {}
	add_cr(run_coach)
	add_cr(run_pinbot)
	add_cr(run_platforms)

	bgoffset = 0
	coach = {x = -32, y = 64, face = 1}
	state = state_coach
	level = 0
	music(0)
end

function add_player(i)
	playercount += 1
	local x = playercount == 1 and 60 or rnd_int(36, 85)
	local c = del(player_colors, player_colors[1])
	local b = add_ball(x, 105, c)
	players[i] = b
	b.pi = i + 1
end

function del_player(i)
	local p = players[i]
	del_actor(p)
	players[i] = nil
	add(player_colors, p.c)
	playercount -= 1
end

function add_ball(x, y, c)
	return add_actor({
		pos = vec2.new(x, y),
		prev = vec2.new(x, y),
		r = ballr,
		rot = 0,
		gravity = .08,
		friction = .999,
		bounce = 0.6,
		isball = true,
		c = c,
		bbstate = 0,
		overlap = circ_rect_overlap,
		get_knock_velocity = function(b) return b.v end,
		knock_slowdown = function(b) b.framefriction = .7 end
	}, {balls, knockers})
end

function btnp_any(b)
	for p = 0, 7 do
		if players[p] then
			if btnp(b, p) then
				return true
			end
		end
	end
end

function add_pin()
	return add_actor({
		x = 1, y = 1, w = 4, h = 8, s = 1, i = #pins + 1,
		offset = {x = -2, y = 0},
		scoreval = 1,
		receive_hit = function(p)
			p.w, p.h = 8, 4
			p.x -= 2
			p.y += 2
			p.s = 2
			p.flip = rnd_int(0, 1) == 0
			p.offset = {x = 0, y = -2}
			add(knockers, p)
		end,
		overlap = overlap,
		get_knock_velocity = function(p) return {x = p.vx, y = p.vy} end
	}, {vactors, pins, knockables, sprites})
end

function position_pins(pins)
	local halfw, i = pins[1].w / 2, 0
	for y = 8, 11 do
		for x = 8, 14 do
			if mget(x, y) == 1 then
				i += 1
				local p = pins[i]
				p.x, p.y = 32 + ((x - 7) * 8) - halfw, (y - 7) * 8
			end
		end
	end
end

function add_actor(a, tables)
	local r = add(actors, a)
	r.tables = {actors}
	if tables then
		for _, t in pairs(tables) do
			add(t, r)
			add(r.tables, t)
			if t == vactors then
				r.vx, r.vy = r.vx or 0, r.vy or 0
			end
		end
	end
	return r
end

function update_input()
	for i = 0, 7 do
		local p = players[i]
		if p then
			if btn(‹, i) then
				p.pos.x -= .05
			end
			if btn(‘, i) then
				p.pos.x += .05
			end
			if btnp(5, i) then
				del_player(i)
				pitimer.reset()
			end
		elseif btnp(4, i) then
			add_player(i)
			pitimer.reset()
		end
	end
end

function level_is_done()
	if mode == mode_bowl or mode == mode_breakout or mode == mode_bird then
		if #targets == 0 then
			return true
		end
	end

	if mode == mode_bowl then
		return score == 10
	elseif mode == mode_bb or mode == mode_bird then
		return pbstate == pbstate_move_done
	elseif mode == mode_breakfast then
		return #eggs == 0 and #yolks == 0
	elseif mode == mode_bj then
		return costatus(blackjack_cr) == 'dead'
	elseif mode == mode_barber then
		return score == 6
	elseif mode == mode_bro then
		return #knockables == 0
	elseif mode == mode_boss then
		return boss.hp == 0 and #particles == 0
	end
end

function end_level()
	if mode == mode_bird then
		music(0, 1000)
		if score >= 0 then
			add_score(10)
		end
	end

	if (level == 0) return

	message.txt = tostr(score)

	if mode ~= mode_bb and score >= maxscore then
		sfx(61, 3)
		message.txt = "strike!"
	end

	if mode == mode_bj then
		message.txt = "please gamble responsibly!"
	elseif mode == mode_barber then
		message.txt = "lookin' sharp!"
	elseif score == 0 then
		sfx(59, 3)
		message.txt = "gutter ball!"
	end

	message.timer.reset()
end

function update_state()
	if state == state_play then
		if level_is_done() then
			end_level()
			state = state_score
		end
	end
	if state == state_score and message.timer.get_value() <= 15 then
		state = state_coach
	end
	if state == state_coach and coachstate == coachstate_done then
		state = state_pinbot
	end
	if state == state_pinbot and pbstate == pbstate_present then
		state = state_play
	end
end

function choose_mode()
	return level < 3 and mode_bowl or mode + 1
end

function init_mode(mode)
	if mode == mode_bowl then
		for i = 1,10 do add_pin() end
		position_pins(pins)
		targets = pins
	elseif mode == mode_breakout then
		create_bricks()
		targets = bricks
	elseif mode == mode_bb then
		hoop={x=57, y=28, h=13, flashtimer=new_timer(10)}
		add_actor({x=hoop.x, y=hoop.y, w=1, h=2, extrabounce=.1}, {fixtures})
		add_actor({x=hoop.x+netw+1, y=hoop.y, w=1, h=2, extrabounce=.1}, {fixtures})
		targets = {fixtures[1], fixtures[2], hoop}
		targetzipy = -19
	elseif mode == mode_bj then
		add_bjbtn(38,9,21,14,19,'hit')
		add_bjbtn(62,18,29,14,24,'stand')
		blackjack_cr = add_cr(run_blackjack)
		targets = bjbtns
		targetzipy = -5
	elseif mode == mode_barber then
		maxtargetoffset = 40
		local x1, y1 = 48, 2
		head={sx=63,sy=0,w=19,h=28,x=x1+7,y=y1+13}
		add(targets, head)
		local hairpos={
			{sx=108,sy=0,w=13,h=3,x=x1+10,y=y1+17},
			{sx=84,sy=12,w=9,h=2,x=x1+12,y=y1+27},
			{sx=101,sy=8,w=3,h=2,x=x1+15,y=y1+31},
			{sx=99,sy=0,w=17,h=12,x=x1+8,y=y1+24},
			{sx=90,sy=0,w=17,h=8,x=x1+8,y=y1+8},
			{sx=73,sy=0,w=33,h=24,x=x1,y=y1},
		}
		for h in all(hairpos) do
			h.scoreval = 1
			h.receive_hit = function(fixture, ball) hit_fixture(ball, fixture) end
			add_actor(h, {vactors, clearables, knockables, targets})
		end
		add(clearables, head)
	elseif mode == mode_breakfast then
		maxtargetoffset = 34
		for i = 1,10 do add_egg() end
		position_pins(eggs)
		targets = eggs
		skillet = {x=49,h=24,t=0,tween=new_tween(-24,64,1,38,ease_out_quad)}
		add(clearables, skillet)
	elseif mode == mode_bird then
		maxtargetoffset = 40
		targetzipy = -5
		for i = 1, 10 do
			add_actor({
				x = 64, y = 10, w = 8, h = 7, s = rnd_int(75, 76), scoreval = -1,
				timer = new_timer(rnd_int(70, 97))
			}, {vactors, sprites, knockables, clearables, targets})
		end
		position_pins(targets)
		music(-1, 1000)
	elseif mode == mode_bro then
		bro = add_actor({
			x = 128, y = 64, w = 32, h = 64, isbro = true,
			receive_hit = function(bro) brointerrupt = true bro.hit = true end
		}, {vactors, knockables})
		add_cr(run_bro)
	elseif mode == mode_boss then
		for i = 1,10 do add(targets, add_pin()) end
		boss = add_actor({
			x = 54, y = 20, w = 24, h = 64, sx = 113, sy = 96, sw = 12, sh = 32,
			extrabounce = .8, hp = 100, shake = 0, t = 0,
			receive_hit = function(f)
				if f.hp > 0 then
					add_score(2)
					f.shake = 2
					f.hp = max(0, f.hp - 4)
					if f.hp == 0 then
						del_actor(boss)
						for i = 1, 580 do
							add_particle(rnd_int(boss.x, boss.x + boss.w - 1), rnd_int(boss.y, boss.y + boss.h - 1), 7)
						end
						music(-1)
						sfx(55)
						f.shake = 4
					else
						sfx(54, 3)
					end
				end
			end
		}, {fixtures, targets})
	end
end

function total_hand(hand)
	local total,acecount = 0,0
	for _, c in pairs(hand) do
		total += min(c.r, 10)
		if c.r == 1 then
			acecount += 1
		end
	end
	for i = 1, acecount do
		if total + 10 <= 21 then
			total += 10
		end
	end
	return total
end

function draw_card(c, x, y, top)
	if c.hidden then
		map(8, 16, x, y, 2, 2)
		return
	end
	local txtx,txty,my
	local tenoffset = (c.r == 10 and 1 or 0)
	local mx = ((c.s - 1) * 2)
	if top then
		my = 16
		txtx = x + 11 - tenoffset
		txty = y + 2
	else
		my = 18
		txtx = x + 4 + tenoffset
		txty = y + 9
	end

	pal(1, 0)
	palt(9, true)
	map(mx, my, x, y, 2, 2)
	pal()

	local col = c.s % 2 == 0 and 8 or 0
	local txt = ranktxt[c.r] or tostr(c.r)
	cprint(txt, txtx, txty, col)
end

function take_card()
	return del(deck, deck[rnd_int(1, #deck)])
end

function give_card(p, hidden)
	local c = add(p.hand, take_card())
	add(bjcardsout, c)
	c.xoffset = 90
	c.hidden = hidden
	p.total = total_hand(p.hand)
	p.bust = p.total > 21
end

function run_blackjack()
	local delay = 12
	repeat
		deck = {}
		for s = 1, 4 do
			for r = 1, 13 do
				add(deck, {s=s, r=r})
			end
		end
		dealer = {hand={}}
		bjplayer = {hand={}}
		bjcardsout = {}
		bjmsg = {}

		while state ~= state_play do yield() end

		for i = 1, 2 do
			give_card(bjplayer)
			wait(delay)
			give_card(dealer, i == 1)
			wait(delay)
		end

		for b in all(bjbtns) do
			b.disabled = false
		end

		local dealerbj = dealer.total == 21
		local playerbj = bjplayer.total == 21

		if dealerbj then
			add(bjmsg, 'dealer has blackjack')
		else
			while not (bjbtns[2].pushed or bjplayer.bust or bjplayer.total == 21
						     or pbstate == pbstate_move_done) do
				if bjbtns[1].pushed then
					give_card(bjplayer)
				end
				yield()
			end
		end

		for b in all(bjbtns) do
			b.disabled = true
		end
		wait(delay)
		dealer.hand[1].hidden = false

		if bjplayer.bust then
			add(bjmsg, 'bust')
		elseif not playerbj then
			while dealer.total <= 16 do
				wait(delay)
				give_card(dealer)
			end
		end
		wait(delay)

		if not dealer.bust then
			if dealer.total > bjplayer.total or bjplayer.bust then
				dealer.win = true
				add(bjmsg, 'dealer wins')
			end
		end

		if not bjplayer.bust then
			if dealer.bust then
				add(bjmsg, 'dealer busts')
			end

			if bjplayer.total > dealer.total or dealer.bust then
				if playerbj then
					add(bjmsg, 'blackjack')
				end
				bjplayer.win = true
				add(bjmsg, 'you win')
				add(bjmsg, bjplayer.total .. ' points')
				add_score(bjplayer.total)
			elseif bjplayer.total == dealer.total then
				bjmsg = {'push'}
			end
		end

		for i = 1, 120 do
			if i % 10 == 0 then
				bjflash = not bjflash
			end
			yield()
		end
		bjplayer.done = true
		dealer.done = true

		for c in all(bjcardsout) do
			c.done = true
			wait(delay)
		end
		wait(60)
	until pbstate == pbstate_move_done
	bjmsg = {}
end

function run_bro()
	repeat yield() until pbstate == pbstate_present
	tween_move(bro, 'x', 128, 95, 30, ease_out_quad)
	local lines = {
		"hi! i'm alfonzo's brother, alonzo!",
		"hey, aren't you jonsey's kid?",
	}
	while true do
		for s in all(lines) do
			if say(s, nil, true) then
				return
			end
		end
		lines = {
			"you seem like you'd get along great with hobart. i'll introduce you!",
			"have you met bridget? she's the one they call the turkey.",
			"fredericka works at the pro shop. she can give you a discount!",
			"stay away from gustav. they don't call him gutterball for nothing!",
			"i heard jimmy bowled a dutch 200 last week!",
			"i can introduce you to darius if you come to scimone's wedding.",
		}
		shuffle(lines)
	end
end

function add_score(n)
	score += n
	totalscore += n
end

function receive_hit_egg(e)
	e.s = 33
	add_actor({
		x = e.x, y = e.y, s = 79, offset = e.offset, w = 8, h = 8,
		vx = -e.vx + rnd_vel(1), vy = e.vy + rnd_vel(1)
	}, {vactors, sprites, clearables})
	add_actor({
		x = e.x, y = e.y, s = 38, gravity = .03,
		offset = {x = -2, y = -1},
		w = 5, h = 6,
	}, {yolks, vactors, sprites, clearables})
end

function add_egg()
	add_actor({
		w = 4, h = 5, s = 34,
		offset = {x = -2, y = -3},
		scoreval = 0,
		receive_hit = receive_hit_egg
	}, {vactors, eggs, knockables, sprites})
end

function run_pinbot()
	while true do
		while state ~= state_coach do yield() end

		local vy = 0
		repeat
			vy -= .1
			for _, a in pairs(clearables) do
				a.y += vy
			end
			yield()
		until all_offscreen(clearables)
		for a in all(actors) do
			if not a.isball then
				del_actor(a)
			end
		end
		clearables = {}

		while state ~= state_pinbot do yield() end
		pbstate = nil

		score = 0
		mode = choose_mode()
		level += 1
		targets = {}
		maxtargetoffset = 75
		targetzipy = nil

		init_mode(mode)
		maxscore = #targets
		pbstate = pbstate_present
		present(targets)

		if state == state_play then
			pbstate = pbstate_present_done
			repeat yield() until (state == state_play and playercount > 0)
					 or state == state_pinbot
			pbstate = pbstate_move
			if mode == mode_boss then
				repeat yield() until boss.hp == 0
			else
				move_targets()
			end
		end
		pbstate = pbstate_move_done
	end
end

function run_platforms()
	repeat yield() until state == state_play and playercount > 0

	local p, p2 = platforms[1], platforms[2]

	repeat
		p.y += .1
		yield()
	until flr(p.y) == 128
	p.enabled = true

	repeat
		local y2 = p.oy + (p.oy - p.y)
		yield()
	until flr(y2) == p2.y
	p2.enabled = true
end

function add_bjbtn(x, y, w, h, mx, txt)
	add_actor({
		x = x, y = y, w = w, h = h, mx = mx,
		extrabounce = .5,
		txt = txt,
		isbjbtn = true,
		pushtimer = new_timer(4),
		disabled = true,
		receive_hit = function(f)
			if not f.disabled then
				sfx(57)
				f.pushed = true
				f.pushtimer.reset()
			end
		end
	}, {bjbtns, fixtures})
end

function add_cr(f)
	return add(coroutines, cocreate(f))
end

function create_bricks()
	local c, row = {8,9,11,10}, 1
	for y = 0, 28, 4 do
		for x = 0, 55, 12 do
			add_brick(35 + x, 8 + y, c[flr(row)])
		end
		row += .5
	end
end

function add_brick(x, y, c)
	add_actor({
		x = x, y = y, w = 10, h = 3, c = c, extrabounce = .05,
		receive_hit = function(f)
			del_actor(f)
			sfx(62, 3, 24, 1)
			add_score(1)
		end
	}, {vactors, bricks, fixtures})
end

function present(targets)
	for a in all(targets) do
		a.origy = a.y
		a.botmoving = true
	end

	local maxy = 0
	for a in all(targets) do
		maxy = max(a.y + a.h - 1, maxy)
	end

	local t = new_tween(-maxy - 2, 0, 1, 40, ease_out_quad)
	for ticks = 1, 40 do
		local offset = t.update(ticks)

		for _, p in pairs(targets) do
			p.y = p.origy + offset
		end
		yield()
	end

	for a in all(targets) do
		a.origy = nil
		a.botmoving = false
	end
end

function move_targets()
	local vy, offset = .075, {x = 0, y = 0}

	if level < 3 then
		vy = 0
	elseif level == 3 then
		vy = 0.09
	elseif mode == mode_bb or mode == mode_bj then
		vy = .05
	end

	repeat
		if offset.y >= maxtargetoffset then
			vy = -abs(vy)
		end

		if targetzipy then
			if vy < 0 and offset.y < targetzipy then
				vy -= .1
			end
		elseif offset.y <= 0 then
			vy = abs(vy)
		end

		offset.y += vy

		for _, t in pairs(targets) do
			if not t.isknocked then
				t.y += vy
			end
		end

		while playercount == 0 do yield() end
		yield()
	until state ~= state_play or all_offscreen(targets)
end

function all_offscreen(t)
	for _, a in pairs(t) do
		if a.y + a.h > 0 then
			return false
		end
	end
	return true
end

function gc_actor(a)
	if not a.botmoving then
		if a.y + a.h < 0 or a.y > 128 or a.x + a.w < 0 or a.x > 128 then
			del_actor(a)
		end
	end
end

function del_actor(a)
	for _, t in pairs(a.tables) do
		del(t, a)
	end
	del(targets, a)
	del(knockers, a)
end

function update_ball_anim(b)
	b.rot += (b.v.x * .2)
	b.rot %= 4
	b.s = 3 + b.rot
end

function _update60()
	update_btnp()
	update_input()

	for c in all(coroutines) do
		if costatus(c) == 'dead' then
			del(coroutines, c)
		else
			assert(coresume(c))
		end
	end

	if mode == mode_bj then
		for _, b in pairs(bjbtns) do
			b.pushed = false
		end
	elseif mode == mode_boss and state == state_play then
		boss.t += .0167
		boss.x = 54 + (sin(boss.t * .4) * 5)
		if pbstate == pbstate_move then
			boss.y = 20 + (cos(boss.t * .3) * 4)
		end
		boss.shake = max(0, boss.shake - .1)
		for p in all(pins) do
			if not p.isknocked then
				p.x = boss.x+boss.w/2+sin(t()/2+p.i/10)*45
				p.y = -4+boss.y+boss.h/2+cos(t()/2+p.i/10)*45
			end
		end
	end

	for _, a in pairs(actors) do a.framehit = false end
	update_physics()
	update_particles()
	foreach(balls, update_ball_anim)

	if mode == mode_bb and hoop then
		update_hoop()
	elseif mode == mode_bj then
		for _, c in pairs(bjcardsout) do
			if c.done then
				c.xoffset -= (1 + abs(c.xoffset))
				c.xoffset = max(-128, c.xoffset)
			else
				c.xoffset -= (c.xoffset / 4)
			end
		end
		for _, b in pairs(bjbtns) do
			b.pushtimer.update()
		end
	elseif mode == mode_breakfast then
		update_breakfast()
	elseif mode == mode_bird then
		for i, b in pairs(targets) do
			if b.timer.update() then
				b.timer = new_timer(rnd_int(70, 97))
				b.s = rnd_int(75, 76)
				if i == 1 and rnd(1) > .5 then
					sfx(5, -1, rnd_int(0, 3) * 8, 8)
				end
			end
		end
	end

	bgoffset += .1667
	bgoffset %= 128

	message.timer.update()
	pitimer.update()
	update_state()
end

function update_hoop()
	for _, b in pairs(balls) do
		if b.pos.x + ballr >= hoop.x + 1 and b.pos.x - ballr <= hoop.x + netw then
			if b.bbstate == 0 then
				b.bbstate = 1
			end
		else
			b.bbstate = 0
		end

		if b.bbstate == 1 and b.pos.y + ballr - 1 <= hoop.y then
			b.bbstate = 2
		end

		if b.bbstate == 2 and b.pos.y - ballr >= hoop.y then
			sfx(58, 1)
			add_score(2)
			b.bbstate = 0
			hoop.flash = true
			hoop.flashtimer.reset()
		end
	end

	if hoop.flashtimer.update() then
		hoop.flash = false
	end
end

function play_hit_sfx(actor, v, edge)
	if (abs(v) < 0.3) return
	if mode == mode_breakout then
		sfx(62, 2, edge and 25 or 26, 1)
	elseif edge then
		sfx(63, 2, 0, 1)
	end
end

function rnd_vel(n, m)
	local v = rnd_int(m or 1, n) / 10
	if rnd_int(0, 1) == 0 then
		v = -v
	end
	return v
end

function add_particle(x, y, c)
	add(particles, {x=x, y=y, c=c, vx=rnd_vel(30), vy=rnd_vel(30), gravity=.03})
end

function update_particles()
	for _, p in pairs(particles) do
		move_vactor(p)
		if p.y > 128 then
			del(particles, p)
		end
	end
end

function draw_sprite(s)
	local offset = s.offset or {x = 0, y = 0}
	spr(s.s, flr(s.x + offset.x), flr(s.y + offset.y), 1, 1, s.flip)
end

function draw_panegg(s)
	clip(pan.x, pan.y, pan.w, pan.h)
	camera(-pan.x, 0)
	draw_sprite(s)
	camera()
	clip()
end

function draw_hoop(h)
	local x1, y1, x2, y2 = h.x - 15, h.y - 25, h.x + netw + 16, h.y + 2
	rect(x1, y1, x2, y2, 6)
	fillp(4680.5)
	rectfill(x1, y1, x2, y2, 6)
	fillp()

	if h.flash then
		pal(7, 10)
	end
	sspr(32, 32, 20, 19, h.x - 3, h.y - 14)
	pal()
end

function draw_bj_cards()
	local x, y = 77, 0
	for c in all(dealer.hand) do
		draw_card(c, x - c.xoffset, y, true)
		x -= 9
	end

	x, y = 38, 112
	for c in all(bjplayer.hand) do
		draw_card(c, x + c.xoffset, y)
		x += 9
	end
end

function draw_bj_txt()
	if #dealer.hand >= 2 and not dealer.hand[1].hidden and not dealer.done then
		if bjflash or not dealer.win then
			cprint(dealer.total, 64, 11, 1, dealer.bust and 8 or 11)
		end
	end

	for i, msg in pairs(bjmsg) do
		cprint(msg, 64, 27 + (i * 8), 1, 10)
	end

	if #bjplayer.hand > 1 and bjplayer.hand[2].xoffset < 1
			and not bjplayer.done then
		if bjflash or not bjplayer.win then
			cprint(bjplayer.total, 64, 112, 1, bjplayer.bust and 8 or 11)
		end
	end
end

function draw_bjbtn(b)
 	local pushed = not b.pushtimer.is_done()

	if b.disabled then
		palt(1, true)
	else
		pal(1, 0)
	end

	if pushed then
		pal(7, 5)
		pal(5, 7)
	end

	map(b.mx, 1, b.x - 7, b.y, 5, 2)
	pal()

	cprint(b.txt, b.x + (b.w / 2) + (pushed and 1 or 0), b.y + (b.h / 2) - 3 + (pushed and 1 or 0), b.disabled and 13 or 0)
end

function coach_leave()
	tween_move(coach, 'x', 14, -32, 26, ease_out_quad)
end

function run_coach()
	while true do
		repeat yield() until state == state_coach

		coach.face = 1
		if level == 1 or level == 2 then
			coach.face = 2
		elseif level == 3 then
			coach.face = 5
		elseif nextmode == mode_bj then
			coach.face = 6
		elseif mode == mode_bird then
			coach.face = score < 0 and 5 or 2
		elseif mode == mode_boss then
			coach.face = 10
		end

		local nextmode, visible = choose_mode(), true
		if nextmode == mode_breakout or nextmode == mode_bb then
			visible = false
		end

		if visible then
			tween_move(coach, 'x', -32, 14, 40, ease_out_quad)
			wait(15)
		end

		if mode == mode_boss then
			say("you...you did it!", 10)
			say("you have avenged my father alfredo's death!")
			wait(30)
			coach.face = 11
			wait(20)

			music(30, 0, 15)
			wait(10)
			tearf = 0
			coach.tearx = 18
			coach.teary = 13
			local vy = 0
			while coach.teary < 384 do
				vy+=.007
				coach.teary += vy
				if coach.teary >= 14 then
					coach.tearx = 19
				end
				tearf+=1
				yield()
			end
			coach.teary = nil

			say("anyway, congratulations!", 1)
			say("we've decided to invite you to join our league!")
			say("practice is on tuesday nights!")
			say("see you then!")
			state = state_credits
			mode = nil
			creditsy = 0
			show_title('bowling', 'credits')
			add_cr(function() wait(100) coach.face = 3 wait(20) coach_leave() end)
			run_credits()
			message.txt = 'thanks for playing!'
			message.timer.reset()
			sfx(61, 3)
			state = state_end
			title = nil
			return
		end

		if level == 1 then
			say("wow! a strike on your first try!")
		elseif level == 2 then
			say("amazing!", 2)
		elseif level == 3 then
			say("incredible!", 5)
			say("it's been a long time since i've seen a newcomer bowl at this level.", 8)
			say("we've got to start your training right away!", 4)
		elseif mode == mode_bird then
			if score >= 0 then
				say("wow! you're a natural@@ist!")
			else
				say("you scared them away!", 5)
			end
		elseif mode == mode_bro then
			say("i think you made an impression on him!", 2)
		end

		if level == 2 then
			say("hey kid, i think you may have some potential!", 7)
			say("let's see how you handle something a little different...", 6)
		elseif nextmode == mode_bj then
		 	say("good.", 6)
		 	say("in a real tournament, however...", 1)
			say("things aren't always so predictable.")
		 	say("but you still have to play the hand you're dealt!", 9)
		elseif nextmode == mode_bird then
			say("a *true* bowler is patient...", 6)
			say("observant...", 12)
			say("study each pin!", 9)
		elseif nextmode == mode_bro then
			say("i'm going to let you in on a little secret, kid.", 6)
			say("it's not how you throw, but who you know.")
			say("i'm talking about networking!", 2)
			say("here, let me introduce you to my brother! he knows everyone!")
		elseif nextmode == mode_barber then
			say("unfortunately, even with the best connections...", 6)
			say("bowling doesn't always pay the bills.")
			say("time to practice for your side-hustle!", 9)
		elseif nextmode == mode_boss then
			say("you're almost ready.")
			say("there's just one last--")
			music(-1)
			say("oh no...", 5)
			say("i didn't think she was going to come back this soon...")
			say("run for your life!!!!!!", 10)
			music(15)
		end

		coachstate = coachstate_title
		local pause = {}
		if level >= 3 and level <= 5 then
			 add_cr(function() show_title(b_words[mode], nil, pause) end)
		else
			 add_cr(function() show_title(b_words[nextmode]) end)
		end

		local erase_and_type = function(a, b, c)
			wait(a)
			erase_title(b)
			wait(15)
			type_title(b_words[nextmode], c)
			wait(120)
			pause.done = true
			wait(30)
		end

		if level == 2 then
			wait(60)
			coach_leave()
			wait(160)
		elseif level == 3 then
			wait(30)
			coach.face = 6
			wait(30)
			coach_leave()
			erase_and_type(15, 6, 2)
		elseif level == 4 then
			erase_and_type(75, 4, 6)
		elseif level == 5 then
			erase_and_type(75, 7, 2)
		elseif nextmode == mode_boss then
			wait(50)
			coach_leave()
			wait(160)
		else
			wait(34)
			coach.face = level > 1 and 3 or 2
			wait(170)
			if visible then
				coach_leave()
			end
			wait(16)
		end

		coachstate = coachstate_done
		repeat yield() until state == state_play
		coachstate = coachstate_wait
	end
end

function erase_title(n)
	local txt = title.word2
	for i = #txt - 1, #txt - n, -1 do
		title.word2 = sub(txt, 1, i)
		sfx(62, -1, 0, 2)
		wait(8)
	end
end

function type_title(txt, start)
	for i = start, #txt do
		title.word2 = sub(txt, 1, i)
		sfx(53)
		wait(10 + rnd_int(1, 5))
	end
end

function run_credits()
	for y = 0, 288 do
		creditsy = y
		wait(8)
	end
end

function draw_credits()
	clip(36, 0, 57, 120)
	for i, c in pairs(credits) do
		cprint(c, 64, 113 + (i * 8), 8, 7)
	end
	clip()
end

function show_title(word2, word3, pause)
	title = {word2 = word2, word3 = word3 or 'challenge'}
	tween_move(title, 'x', -36, 64, 44, ease_out_quad)
	if state == state_credits then
		wait(60)
		music(23)
		return
	end
	if pause then
		repeat yield() until pause.done
	else
		wait(180)
	end
	tween_move(title, 'x', 64, 164, 30, ease_in_quad)
	title = nil
end

function say(txt, face, isbro)
	dialog = {
		txt = wrap(txt, 19),
		len = 0,
		isbro = isbro
	}
	if face then
		coach.face = face
	end

	local skip,sfxframe = false,0
	for i = 1, #txt do
		local c,delay = sub(txt, i, i),2
		if c == ',' then
			delay = 10
		elseif c == '@' or c == '.' or c == '!' then
			delay = 20
		end

		if c ~= '@' then
			dialog.len += 1
			if sfxframe >= 4 then
				sfxframe = 0
				sfx(53, 2)
			end
		end

		for j = 1, delay do
			sfxframe += 1
			yield()

			if btnp_any(4) or (isbro and brointerrupt) then
				skip = true
				dialog.len = #dialog.txt
				break
			end
		end
		if skip then
			break
		end
	end

	if not (isbro and brointerrupt) then
		promptvisible = true
		local i = 0
		repeat
			i += 1
			promptoffset = (i % 60) < 30 and 0 or 1
			yield()
		until btnp_any(4) or (isbro and brointerrupt)
		promptvisible = false
	end

	dialog = nil
	if brointerrupt then
		brointerrupt = false
		return true
	elseif isbro and score < 10 then
		add_score(1)
	end
end

function draw_dialog()
	local d = dialog
	if (not d) return

	local w, h = 81, 29
	local x = d.isbro and bro.x - 84 or coach.x + 28
	local y = coach.y - 15
	local x2, y2 = x + w - 1, y + h - 1

	map(8, 3, x - 1, y - 1, 11, 4)
	print(sub(d.txt, 1, d.len), x + 3, y + 3, 7)
	palt(1, true)
	if d.isbro then
		spr(7, x + w - 4, y + h, 1, 1, true)
	else
		spr(7, x - 2, y + h)
	end
	palt()

	if promptvisible then
		sspr(32, 24, 3, 4, x + w - 7, y2)
		print('Ž', x + w - 9, y + h - 2 + promptoffset, 7)
	end
end

function font_i(chr)
	for i = 1, #font do
		if sub(font, i, i) == chr then
			return i
		end
	end
end

function font_xy(chr)
	local i = font_i(chr) - 1
	return 64 + ((i % 8) * 8), 64 + (flr(i / 8) * 8)
end

function bigprint(s, x, y)
	for i = 1, #s do
		y += (i % 2 == 0 and 1 or -1)
		rectfill(x - 2, y - 2, x + 6, y + 13, i % 2 == 0 and 9 or 12)
		local sx, sy = font_xy(sub(s, i, i))
		sspr(sx, sy, 5, 6, x, y, 5, 12)
		x += 9
	end
end

function draw_title()
	fillp(20158)
	for w = 39, 0, -1 do
		local y = 138 - title.x - w
		rectfill(64 - w, y, 64 + w, y, 0x31)
	end
	fillp()

	bigprint(title.word2, 67 - #title.word2 * 4.5, title.x - 18, 7)
	cprint(title.word3, 128 - title.x, 63, 8, 7)
	sspr(72, 43, 56, 21, title.x - 28, 23)
end

function draw_alfonzo()
	local x, w, f = 0, 32, faces[coach.face]

	palt(1, true)
	palt(0, false)
	sspr(x, 64, w, 64, coach.x, coach.y)
	sspr(f[1], f[2], 9, 11, coach.x + 11, coach.y + 8)

	if coach.teary then
		pset(coach.x+coach.tearx, coach.y+coach.teary, tearf % 8 < 4 and 7 or 12)
	end
	palt()
end

function sspr_sym(s)
	local sw = s.w / 2
	sspr(s.sx, s.sy, ceil(sw), s.h, s.x, s.y)
	sspr(s.sx, s.sy, flr(sw), s.h, s.x + ceil(sw), s.y, flr(sw), s.h, true)
end

function update_breakfast()
	if not skillet.tween.is_done() then
		skillet.t += 1
		skillet.y = skillet.tween.update(skillet.t)
	end
	skillet.x = flr(49 + (sin(t() / 2.9) * 17))
	pan = {
		x = skillet.x + 4,
		y = skillet.y + 12,
		w = 23,
		h = 6
	}
	local panhitbox = {
		x = pan.x + 4,
		y = pan.y + pan.h + 1,
		w = pan.w - 8,
		h = 1
	}

	for _, yolk in pairs(yolks) do
		if overlap(yolk, panhitbox) then
			del_actor(yolk)
			add_actor({
				x = yolk.x - pan.x, y = flr(yolk.y) + rnd_int(-1, 1),
				s = 21, offset = {x = -1, y = -2},
				w = 7, h = 4,
			}, {paneggs, clearables})
			add_score(1)
			sfx(56, 3)
		end
	end
end

function draw_tutorial()
	if (playercount == 0 or not tutorialon) return

	if tutorial.vy == 0 then
		for b in all(balls) do
			if b.pos.y < 100 then
				tutorial.vy = 0.1
			end
		end
	end

	tutorial.y += tutorial.vy
	local y = tutorial.y
	if (tutorial.vy == 0) y += cos(t()) / 2
	print('‹', 39, y, btn(0) and 10 or 7)
	print('‘', 83, y, btn(1) and 10 or 7)

	if (tutorial.y > 127) tutorialon = false
	if (tutorial.vy > 0) tutorial.vy += .04
end

function get_boss_shake()
	return rnd_int(-boss.shake, boss.shake)
end

function _draw()
	if boss and boss.hp == 0 then
		camera(get_boss_shake(), get_boss_shake())
	end
	map(32, 0, 0, bgoffset - 128, 16, 32)
	map(0, 0, 36, 0, 8, 16)
	for p in all(platforms) do
		map(8, 0, p.x, p.y - 8, 4, 2)
	end

	if mode == mode_breakout then
		for b in all(bricks) do
			pal(9, b.c)
			spr(35, b.x, b.y, 2, 1)
			pal()
		end
	elseif mode == mode_bb and hoop then
		draw_hoop(hoop)
	elseif mode == mode_bj and #bjbtns > 0 then
		foreach(bjbtns, draw_bjbtn)
		draw_bj_cards()
	elseif mode == mode_barber then
		palt(0, false)
		palt(1, true)
		sspr_sym(head)
		foreach(targets, sspr_sym)
		palt()
	elseif mode == mode_breakfast then
		palt(1, true)
		spr(27, skillet.x, skillet.y, 5, 3)
		palt()
		foreach(paneggs, draw_panegg)
		sspr(32, 87, 25, 9, skillet.x + 3, skillet.y + 14)
	elseif mode == mode_boss and boss.hp > 0 then
		local b = boss
		sspr(b.sx, b.sy, b.sw, b.sh, b.x+get_boss_shake(), b.y+get_boss_shake(), b.w, b.h)
	elseif mode == mode_bro then
		palt(1, true)
		palt(0, false)
		pal(2, 5)
		pal(4, 0)
		pal(14, 10)
		pal(8, 3)
		sspr(0, 64, 32, 64, bro.x, bro.y, 32, 64, true)
		pal()
	end

	foreach(sprites, draw_sprite)
	for b in all(balls) do
		pal(1, 0)
		pal(12, b.c)
		if not pitimer.is_done() then
			cprint('p' .. b.pi, b.pos.x, b.pos.y - ballr - 8, b.c, 1)
		end
		spr(b.s, b.pos.x - ballr, b.pos.y - ballr)
		pal()
	end

	if mode == mode_bb and hoop then
		sspr(56, 32, 14, 14, hoop.x, hoop.y)
	end

	for p in all(particles) do
		pset(p.x, p.y, p.c)
	end

	if (level > 0) bprint('frame ' .. level, 2, 2, 10, 1)
	rprint(totalscore, 126, 2, 10, 1)

	if mode == mode_boss then
		rectfill(38, 4, 38 + ((boss.hp / 100) * 51), 5, 8)
		rect(38, 3, 90, 6, 7)
	end

	if state == state_credits then
		camera(0, creditsy)
		draw_credits()
	end
	if (title) draw_title()
	camera()

	draw_alfonzo()
	draw_dialog()
	if (mode == mode_bj) draw_bj_txt()
	if state ~= state_coach and playercount == 0 or not message.timer.is_done() then
		rectfill(0, 56, 127, 64, 8)
		cprint(playercount == 0 and 'press Ž to join' or message.txt, 64, 58, 7)
	end

	draw_tutorial()

	if state == state_end then
		music(-1)
		while true do
			local p=add_pin()
			p.x,p.y=rnd_int(0,120),rnd_int(0,50)
			p.gravity,p.vx=.1,rnd_vel(8,3)
			repeat
				move_vactor(p)
				if p.y>=120 then
					p.y,p.vy=120,-p.vy*.7
				end
				draw_sprite(p) flip()
			until p.x > 128 or p.x < 0
			del_actor(p)
		end
	end
end

ballr = 4
ballr2 = ballr * 2

function bounce_axis(b, axis, hitpoint, extrabounce)
	b.pos[axis] = hitpoint
	b.prev[axis] = hitpoint + (b.v[axis] * (b.bounce + (extrabounce or 0)))
end

function circ_rect_overlap(c, r)
	local distx = abs(c.pos.x - r.x - (r.w / 2))
	local disty = abs(c.pos.y - r.y - (r.h / 2))

	if distx > (r.w / 2) + c.r or disty > (r.h / 2) + c.r then
		return false
	end
	if distx <= r.w / 2 or disty <= r.h / 2 then
		return true
	end

	local dx = distx - (r.w / 2)
	local dy = disty - (r.h / 2)
	return (dx * dx) + (dy * dy) <= c.r * c.r
end

function collide_with_knockables(a)
	local hit = false

	for _, k in pairs(knockables) do
		if k ~= a and a:overlap(k) then
			del(knockables, k)
			k.isknocked = true

			local knockv = a:get_knock_velocity()
			k.vx = knockv.x + rnd_vel(1)
			k.vy = knockv.y + rnd_vel(1)
			if (abs(k.vx) < .5) k.vx = k.vx < 0 and -.5 or .5
			if (abs(k.vy) < .5) k.vy = k.vy < 0 and -.5 or .5

			if k.receive_hit then
				k:receive_hit(a)
			end
			if k.scoreval then
				add_score(k.scoreval)
			end

			hit = true
			sfx(62, 1, 0, 2)
		end
	end

	if hit then
		if a.knock_slowdown then
		  a:knock_slowdown()
		else
		  a.vy += (-a.vy / 3)
		  a.vx += (-a.vx / 3)
		end
	end
end

function hit_fixture(b, f)
	local nearestx = max(f.x, min(b.pos.x, f.x + f.w))
	local nearesty = max(f.y, min(b.pos.y, f.y + f.h))
	local diff = vec2.new(b.pos.x - nearestx, b.pos.y - nearesty)
	local pendepth = diff:mag() - ballr
	local penv = diff:normalized() * pendepth
	local pos = b.pos - penv

	if nearestx == b.pos.x then
		bounce_axis(b, 'y', pos.y, f.extrabounce)
	elseif nearesty == b.pos.y then
		bounce_axis(b, 'x', pos.x, f.extrabounce)
	else
		b.pos = pos
	end
end

function constrain_to_fixtures(b)
	local hit
	for _, f in pairs(fixtures) do
		if circ_rect_overlap(b, f) then
			hit_fixture(b, f)
			if f.receive_hit and not f.framehit then
				f:receive_hit(b)
				f.framehit = true
			end
			hit = true
		end
	end
	return hit
end

function constrain_to_platforms(b)
	for _, p in pairs(platforms) do
		if p.enabled then
			if (p.vy <= 0 and b.prev.y <= p.y) or b.prev.y + ballr <= p.y then
				if circ_rect_overlap(b, p) then
					b.pos.y = p.y - ballr
					play_hit_sfx(b, b.v.y - p.vy)
				end
			end
		end
	end
end

function constrain_to_screen(b)
	local minval, maxval, hit = ballr, 128 - ballr

	for _, axis in pairs({'x', 'y'}) do
		if b.pos[axis] < minval then
			bounce_axis(b, axis, minval)
			play_hit_sfx(b, b.v[axis], true)
			hit = true
		elseif b.pos[axis] > maxval then
			bounce_axis(b, axis, maxval)
			play_hit_sfx(b, b.v[axis], true)
			hit = true
		end
	end
	return hit
end

function move_vactor(a)
	if a.gravity then
		a.vy += a.gravity
	end
	if a.friction then
		a.vx *= a.friction
	end
	a.x += a.vx
	a.y += a.vy
end

function overlap(a, b)
	return a.x + a.w > b.x and a.x < b.x + b.w and a.y + a.h > b.y and a.y < b.y + b.h
end

function resolve_ball_collisions()
	local moved
	local r2sq = ballr2 * ballr2
	for i = 1, #balls do
		for j = i + 1, #balls do
			local a = balls[i]
			local b = balls[j]
			local diff = b.pos - a.pos

			if diff:magsq() < r2sq then
				local offset = diff - diff:normalized(ballr2)
				a.pos += offset
				b.pos -= offset
				moved = true
			end
		end
	end
	return moved
end

function update_physics()
	for _, b in pairs(balls) do
		verlet(b)
		b.pos.y += b.gravity
	end
	foreach(vactors, move_vactor)
	update_platforms()

	for i = 1, 5 do
		local moved = resolve_ball_collisions()

		for _, b in pairs(balls) do
			for func in all(ball_constraints) do
				if func(b) then
					moved = true
				end
			end
		end

		if not moved then
			break
		end
	end

	foreach(knockers, collide_with_knockables)
	foreach(vactors, gc_actor)
end

function update_platforms()
	local p = platforms[1]
	if p.enabled then
		local d = (p.oy - p.y) * .003
		p.vy += d
		p.y += p.vy
	end

	local p2 = platforms[2]
	if p2.enabled then
		p2.y = p.oy + (p.oy - p.y)
		p2.vy = -p.vy
	end
end

function verlet(b)
	local c = b.pos:copy()
	b.v = b.pos - b.prev
	b.v:limit(ballr2)
	if b.framefriction then
		b.v *= b.framefriction
		b.framefriction = nil
	end
	b.pos = b.pos + b.v
	b.prev = c
end

ball_constraints = {
	constrain_to_fixtures,
	constrain_to_platforms,
	constrain_to_screen
}

vec2={}
vec2.__index=vec2
vec2.__add=function(a,b)
	if type(a)=='number' then
		return vec2.new(a+b.x, a+b.y)
	elseif type(b)=='number' then
		return vec2.new(a.x+b, a.y+b)
	else
		return vec2.new(a.x+b.x, a.y+b.y)
	end
end
vec2.__sub=function(a,b)
	if type(a)=='number' then
		return vec2.new(a-b.x, a-b.y)
	elseif type(b)=='number' then
		return vec2.new(a.x-b, a.y-b)
	else
		return vec2.new(a.x-b.x, a.y-b.y)
	end
end
vec2.__mul=function(a,b)
	if type(a) == 'number' then
		return vec2.new(a * b.x, a * b.y)
	elseif type(b) == 'number' then
		return vec2.new(a.x*b, a.y*b)
	else
		return vec2.new(a.x*b.x, a.y*b.y)
	end
end
function vec2.new(x,y)
	return setmetatable({x=x,y=y},vec2)
end
function vec2:magsq()
	return (self.x*self.x) + (self.y*self.y)
end
function vec2:mag()
	return sqrt(self:magsq())
end
function vec2:copy()
	return vec2.new(self.x, self.y)
end
function vec2:norm(n)
	local n = n or 1
	local m = self:mag()
	if m~=0 then
		self.x=(self.x/m)*n
		self.y=(self.y/m)*n
	end
end
function vec2:normalized(n)
	local v=self:copy()
	v:norm(n)
	return v
end
function vec2:limit(mag)
	if self:magsq()>mag*mag then
		self:norm(mag)
	end
end

btnps={}
for b=0,5 do btnps[b]={}end
function btnp(b, p)return btnps[b][p or 0]==1 end
function update_btnp()
	for b=0,5 do
		for p=0,7 do
			local s=btnps[b][p]
			if btn(b,p)then
				if (s<2)s+=1
			else
				s=0
			end
			btnps[b][p]=s
		end
	end
end

function new_timer(len)
	local v = len
	return {
		expire = function() v = 1 end,
		get_value = function() return v end,
		is_done = function() return v == 1 end,
		reset = function() v = len end,
		update = function()
			if v>1 then
				v-=1
			else
				return true
			end
		end
	}
end

function new_tween(src, dst, ticksrc, tickdst, func)
	local ticktotal, v = tickdst-ticksrc, src
	return {
		is_done = function() return v == dst end,
		update = function(ticks)
			ticks = mid(0, ticks-ticksrc, ticktotal)
			v = func(ticks, src, dst-src, ticktotal)
			return v
		end
	}
end
function ease_in_quad(t, b, c, d)
  t=t/d
  return c*(t^2)+b
end
function ease_out_quad(t, b, c, d)
	t=t/d
	return -c*t*(t-2)+b
end
function tween_move(actor, axis, src, dst, frames, easefunc)
	local t = new_tween(src, dst, 1, frames, easefunc)
	for f = 1, frames do
		local v = t.update(f)
		actor[axis] = v
		yield()
	end
end

function txtw(txt)
	txt=tostr(txt)
	local w=0
	for i=1,#txt do
		if sub(txt,i,i)=='Ž' then
			w+=8
		else
			w+=4
		end
	end
	return max(0,w-1)
end
function cprint(s,x,y,c,b)
	bprint(s,x-flr(txtw(s)/2),y,c,b)
end
function bprint(s,x,y,c,b)
	if b then
		for yo=-1,1 do
			for xo=-1,1 do
				if not (yo==0 and xo==0) then
					print(s,x+xo,y+yo,b)
				end
			end
		end
	end
	print(s,x,y,c)
end
function rprint(s,x,y,c,b)
	bprint(s,x-txtw(s),y,c,b)
end
function rnd_int(a,b)
	return flr(rnd((b+1)-a))+a
end
function shuffle(t)
	for i=#t,1,-1 do
		local j=flr(rnd(i))+1
		t[i],t[j]=t[j],t[i]
	end
end
function wait(n)
	for i=1,n do yield() end
end
function wrap(s,w)
	if #s<=w then
		return s,1
	end
	local new,s2='',''
	for i=1,#s do
		local c=sub(s,i,i)
		if c~='@' then
			s2=s2..c
		end
	end
	s=s2
	local a,b=1,w+1
	while b>a do
		local c=sub(s,b,b)
		if c==' ' or c=='\n' then
			new=new..sub(s,a,b-1)..'\n'
			a=b+1
			b=a+w
		else
			b-=1
		end
		if b>#s then
			b=#s
			new=new..sub(s,a)
			break
		end
	end
	return new
end

__gfx__
00000000000770000000000000cccc0000cccc0000cccc0000cccc00077333711111444441111111111100000010000000001111111110000111111177787776
0000000000077000000000000ccc1cc00cccccc00cccccc00cccccc0733377011144444441111111100000000000000000000111111100000011111177777776
007007000008800007777000cc1cccccccccc1ccccc1cccccccccccc077700011444444441111111000000000000000000000000000001111111111177777776
000770000077770077777877ccccccccccccccccccccccccc1ccc1cc000000014444444441111100000000000000000000000000000011111111111177777776
000770000077770077777877cccccccccc1ccc1ccccccccccccccccc000000014444444441111000000000000000000000000000111111111111111177777776
007007000077770007777000cccc1cccccccccccccccc1cccc1ccccc000000014444444441110000000000000000000000000000111111111111111177777776
0000000000777700000000000cccccc00cccccc00cc1ccc00cccccc0000000014444444441100000000000000000111111110000011111111111111177777776
00000000000770000000000000cccc0000cccc0000cccc0000cccc00000000014444004441100000000000000001111111110000000011111111111177777776
edddedddedddeddde0000000eeeeeeeee00000000000000077777777000000044444004441000000000000000011111111111000000011110000000000000000
edddedddedddeddde000000000000000000000000000000033333333000000044444444441000000000000000011111111111100000011110000000000006600
edddedddeddddddde000000000000000000000000077770033333333000000044444444400000000000000000011111111111110000011110000000000660060
edddedddedddeddde00000000000000000000000077aa77033333333000000044444444040000000000000000011111111111111000011110000000066666600
edddedddeddeeedde00000000000000000000000077aa77733333333000000044444444440000000000000000011111111111111111111110000006666600000
edddedddeddddddde000000000000000000000000077777033333333000000014444444440000000000001111111111111111111111111110000066660000000
edddedddedddeddde000000000000000000000000000000033333333000000014444444440000000000111111111111111111111111111110000666000000000
edddedddedddeddde000000000000000000000000000000033333333000000014444477770000000001111111111111111111111111111110006660000000000
066666600000000000000000999999999900000007777777000000000000000144444eeee0000000011111111100000000000000000000000066600000000000
6333333600000000000000009999999999000000733333330006660000000001144444eee0000000011111111100000000555555555550000666000000000000
63333336000000000000000099999999990000007333333300666660000000011444444440000000011111111100000555ddddddddddd5556660000000000000
63333336000000000007700000000000000000007333333300666660000000011144444441000000011111111100055ddddddddddddddddd5560000000000000
633333360000000000777700000000000000000073333333006aa6600000000111144444410000000111111111005ddddddddddddddddd6ddd50000000000000
633333360070700000777700000000000000000073333333006aa600000000011114544441100000011111111105dddddd55555555555ddd6dd5000000000000
63333336007777000077770000000000000000007333333300066000000000011114455551110000011111111106ddd55555555555555555ddd6000000000000
06666660000770000007700000000000000000007333333300000000000000011114444441111000011111111105655555555555555555555565000000000000
63333336770000007333333333700000333333337333333333700000000000011114444441111111333333330005566555555555555555556655000000000000
66666666337000007333333333700000333333337333333333700000000000011114444441111111333333330005555666555555555556665555000000000000
00077000337000007333333333700000333333337333333333700000000000011114444441111111333333330005555555666666666665555555000000000000
00777700337000007333333333700000333333337333333333700000000000011111444441111111333333330000555555555555555555555550000000000000
00000000337000007333333333700000333333337333333333700000000000010000000000000000333333330000055555555555555555555500000000000000
00000000337000007333333333700000333333337333333333700000000000010000000000000000333333330000000555555555555555550000000000000000
00000000337000000777777777000000333333337333333333700000000000000000000000000000777777770000000000555555555550000000000000000000
00000000337000000000000000000000333333337333333333700000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111777777777777777777770000999999999999990006777777771117760000000000000000788788878887887000000000
11111118111111111111111111111191777777777777777777770000999999999999990006777777777777760aaaa000000aaaa0788887888788887000000000
11118881111111111111111111111111770000000000000000770000700700700770070006777777777777760acaaa0000aaaca0788788878887887000000000
1111811111111111111f441111111113770000000000000000770000700700700070070006777777777777769aaaaaa00aaaaaa9788887888788887000077000
111181111111111111f44f11111111117700000000000000007700007007007000700700067777777777777600bbaaaaaaaabb00788788878887887000777700
11881111111111111f44ff111111111177000000000000000077000007707070077070000677777777777776000bbbb00bbbb000788887888788887000070700
1181111111111111f44ff11111111111770000000000000000770000070007000700700006777777777777760009009009009000788788878887887000000000
111111111111111144ff111111111111770000000000000000770000070070707700700006777777777777760090090000900900778888888888877000000000
11811111111111111111111111111111770000000000000000770000007700077007000000000000000000000000000000000000077777777777770000000000
18881111111111111111111111111111770000000000000000770000007000777007000000000000000000000000000000000000000000000000000000000000
18881111111111111111111111111111770000000000000000770000007007700707000000000000000000000000000000000000000000000000000000000000
18881111171111111111111111aaaaa1770000000000000000770000000777000070000000000077700000000000000000000000000000000000000000000000
188811111471111111111aaa1aaaaaa1770000000000000000770000000770700070000000000778870000000000000000000000000000000000000000000000
1888111177441111111aa11111aaaaa1777777777777777777770000000700700770000000007787787007777007777000000000000000000000000000000000
111111114477111a1a11111111111111777999999999999997770000000770707070000000077877787007887077887000000000000000000000000000000000
11111111774411111111111111111111000000099999900000000000000707070070000000078770778777887077887000000000000000000000000000000000
11111111ffff11111111111111111111000000099999900000000000000000000000000000078700078778787078787000000000000000000000000000000000
11111111ffff11111111111111111111000000099999900000000000000000000000000000778700077878787078787000000000000000000000000000000000
111111111ff111111111111111111111000000099999900000000000000000000000000000787700007878787078787000000000000000000000000077700000
111111111ff111111111111111111111000000000000000000000000000000000000000000787000007878787078787000000000000000000000000078700000
11111111111111111111111111111111000000000000000000000000000000000000000000787000007877887078877007777077777007777000777778777000
11111111111111111111111114444411000000000000000000000000000000000000000000787000007878877778777777887787887777887777788777787700
11111111111111111611111111aaa111000000000000000000000000000000000000000000787000077887877788788888778888778778778778877887788770
111111111111111161161111118aa111000000000000000006666666666666000000000000787007778877877878877787778787778787787788777878877870
11111111111111116161111111aa8111677777776777777767777777677777777777776077787777887877878778787787787787078787887878778777777877
119111111111111166111111111a1111677777776777777767777777677777777777776078888888777877787778778778877787078877788777887700788887
111111111811f61611111111111a1111677777776777777767777777677777777777776077778777707870777078778707770777077777878707777000777777
1b111111188fff688111111111111111677777776777777767777777677777777777776000078770007870000078778700000000000778778700000000000000
111111111888fff888fff11111111111677777776777777767777777677777777777776000077870078770000078787700000000000787778700000000000000
111111111888fff888ffff1111111111677777776777777767777777677777777777776000007770077700000078787000000000000787778700000000000000
1e111111166616666666661111111111677777776777777767777777677777777777776000000000000000000077877000000000000778887700000000000000
11111111111111111111111111111111677717776777877767711177678878877777776000000000000000000007770000000000000077777000000000000000
1111111111114411111111111111111177744ffffffff44400666666666666600777000077770000077700007777000007777000077770000777700077077000
11111111111144441441111111111111774ffffff444f44400000000000000007707700077077000770770007707700077000000770000007700000077077000
1111111144444444444444111111111174f444ffff70ff4400000000000000007707700077770000770000007707700077770000777700007700000077777000
111111114444444444444411111111114fff70ff5fffff4400000000000000007777700077077000770000007707700077000000770000007707700077077000
11111144444444777777744411111111ffffffff5fffff4400000000000000007707700077077000770770007707700077000000770000007707700077077000
11111114444477777777777111111111fffffffff5fff44400000000000000007707700077770000077700007777000007777000770000000777700077077000
111111144477777777777771411111114fffff4444fff44100000000000000000000000000000000000000000000000000000000000000000000000000000000
111111444777744fffff44441111111144fff444444ff11100000000000000000000000000000000000000000000000000000000000000000000000000000000
1111144477744ffffffff4441111111144ff444ff444f11100000000000000007777000077777000770770007700000077770000077700007777000007770000
11111117774ffffff444f44441111111144fffffffff111100000000000000000770000000770000770770007700000077077000770770007707700077077000
1111111774f444ffff77ff4411111111144ffffffff1111100000000000000000770000000770000777000007700000077077000770770007707700077077000
111114444fff77ff5f07ff44411111111111ffffff11111100000000000000000770000000770000770770007700000077077000770770007777000077077000
11111144ffff70ff5fffff44111111111111ffffff11111100000000000000000770000000770000770770007700000077077000770770007700000077770000
11111444fffffffff5fff444111111111111ffffff11111100000000000000007777000077700000770770007777700077077000077700007700000007777000
111111444fffff4444fff4411111111111188ffff888111100000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111444fff444444ff1111111111111888ffff8888e8800000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111444ff444ff444f11111111111000000000000000000000000000000007777000007777000777770007707700077077000770770000070000000000000
11111111144fffffffff111111111111000000000000000000000000000000007707700077000000077000007707700077077000770770000070000000000000
11111111144ffffffff1111111111111000000000000000000000000000000007707700007770000077000007707700077077000770770000000000000000000
111111111111ffffff11111111111111000000000000000000000000000000007770000000077000077000007707700077077000777770000000000000000000
111111111111ffffff11111111111111000000000000000000000000000000007707700000077000077000007707700007770000777770000000000000000000
111111111118ffffff81111111111111000000000000000000000000000000007707700077770000077000000777000000700000770770000000000000000000
111111111188ffffff88111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111888ffffff888eee81111111600000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000
1111111e28888fffff8882ee88811111560000000000000000000006500000001111111111111111111100007666666666666666665100000000000000000000
1111188ee2888ffff8882eee88881111556600000000000000000665500000007777777777777777775100007666666666666666665100000000000000000000
1111888eee222ffff222eeee88888111555566600000000000666555500000007666666666666666665100007666666666666666665100000000000000000000
1118888eeeee2ffff2eeeee888888811555555566666666666555555500000007666666666666666665100007666666666666666665100000000000000000000
11188888eeee8fff2eeeeee888888811055555555555555555555555000000007666666666666666665100005555555555555555555100000000000000000000
11888888eeee82ff2eeee2e288888881005555555555555555555550000000007666666666666666665100001111111111111111111100000000000000000000
11888888eeee82ffee222ee282888881000055555555555555555000000000007666666666666666665100000000000000000000000000000000000000000000
18888882eeee82f8eeeeeee222888881000000055555555555000000000000007666666666666666665100000000000000000000000000000000000000000000
18888822eeee82f8eeeeeee22888888177744ffff444f44477744ffff444f44477744ffff444f44477744ffff444f44477744ffffffff4440000007700000000
18888882eeee82f8eeeeffff28888881774444fffffff444774ffffffffff444774444ffff77f444774444ffff77f444774ffffff444f4440000077770000000
18888282eeee8828effffff28888888174ffffffff77ff4474ffffffff77ff4474ff77ffff07ff4474ff77ffff07ff4474f444ffff07ff440000777777000000
88888822eeee8ffffffffff2888888814fff77ff5f07ff444ff444ff5f07ff444fff70ff5f77ff444fff70ff5f77ff444fff07ff5fffff440000777777000000
8888888ffffffffffffff22888888881ffff70ff5fffff44ffff70ff5fffff44ffff77ff5fffff44ffff77ff5fffff44ffffffff5fffff440000777777000000
88882fffffffffffff555fff28888881fffffffff5fff444fffffffff5fff444fffffffff5fff444fffffffff5fff444fffffffff5fff4440000777777000000
882fffffffffffff55ffffffff2888814fffff4444fff4414fffff4444fff4414fffff4444fff4414ffffff55ffff4414fffff4444fff4410000777777000000
88ffffffffffff55fffffffffff8888144fff444444ff11144fff444444ff11144fff444444ff11144ffff4444fff11144fff444444ff1110000077770000000
8fffffffffff55ffffffffffffff881144ff44777744f11144ff44777744f11144ff444ff444f11144fff444444ff11144ff444ff444f1110000088880000000
28fffffff5558888fffffffffff28811144fff0000ff1111144fff0000ff1111144fffffffff1111144ff44ff44f1111144fffffffff11110000088880000000
122ffff55eee8888eeeeffffff228111144ffffffff11111144ffffffff11111144ffffffff11111144ff4ffff411111144ffffffff111110000077770000000
1115555eeeee8888eeeeeee8111111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111110000777777000000
111111eeeeee8288eeeeeee8111111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111110007777777700000
111111eeeeee8888eeeeeee8111111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111110077777777770000
11111eeeeeee8288eeeeeee88111111111188ffff888111111188ffff888111111188ffff888111111188ffff888111111188ffff88811110077777777770000
11111eeeeeee8288eeeeeee88111111111888ffff8888e8811888ffff8888e8811888ffff8888e8811888ffff8888e8811888ffff8888e880077777777770000
11111eeeeee88888eeeeeeee8811111177744ffffffff44477744ffff444f44477744ffffffff44477744ffff444f44477744ffff44ff4440777777777777000
11111ee000050666005000ee88111111774444fff444f444774444ffff70f444774ffffff444f444774444ffff77f444774ff44fff44f4440777777777777000
1111110000050666005000008811111174ffffffff77ff4474ff70ffff77ff4474ffffffff77ff4474ff77ffff07ff4474f444ffff77ff440777777777777000
111111550555555555550555511111114fff77ff5f07ff444fff77ff5fffff444ff444ff5f07ff444fff70ff5f77ff444fff77ff5f07ff440777777777777000
11111150055555055555505551111111ffff70ff5fffff44ffffffff5fffff44ffff70ff5fffff44ffff77ff5fffff44ffff70ff5f77ff440777777777777000
11111150555555055555550555111111fffffffff5fff444fffffffff5fff444fffffffff5fff444fffffffff5fff444ffff77fff5fff4440777777777777000
111115505555550555555505551111114fffff4444fff4414ffffff55ffff4414fffff4444fff4414fffff4444fff4414fffff4444fff4410777777777777000
1111150555555505555555505511111144fff444444ff11144ffff4444fff11144fff444444ff11144fff444444ff11144fff444444ff1110777777777777000
1111155555555505555555555511111144fff44ff44ff11144fff444444ff11144fff44ff44ff11144ff44000044f11144ff44777744f1110077777777770000
11115555555555055555555555111111144ff4ffff4f1111144ff44ff44f1111144ff4ffff4f1111144fff0000ff1111144fff0000ff11110077777777770000
11155555555555505555555555111111144ffffffff11111144ff4ffff411111144ffffffff11111144fffffffff1111144fffffffff11110077777777770000
111555555555555055555555551111111111ffffff1111111111ffffff1111111111ffffff1111111111fffffff111111111fffffff111110007777777700000
115555555555555055555555511111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111110007777777700000
115555555555550055555555511111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111111111ffffff1111110007777777700000
1555555555555010555555555111111111188ffff888111111188ffff888111111188ffff888111111188ffff888111111188ffff88811110000777777000000
1555555555550110555555555111111111888ffff8888e8811888ffff8888e8811888ffff8888e8811888ffff8888e8811888ffff8888e880000777777000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101012202020200000000000000000000000000000000000000000404142434041424340414243404142430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012303030300000000000000027b8b9ba0027b8b9b9ba000000505152535051525350515253505152530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012000000000000000000000037bbbcbd0037bbbcbcbd000000606162636061626360616263606162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012251616161616161616163100000000000000000000000000707172737071727370717273707172730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012353434343434343434343600000000000000000000000000424340414243404142434041424340410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012353434343434343434343600000000000000000000000000525350515253505152535051525350510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012323a3a3a3a3a3a3a3a3a3300000000000000000000000000626360616263606162636061626360610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012000000000000000000000000000000000000000000000000727370717273707172737071727370710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012010001000100010000000000000000000000000000000000404142434041424340414243404142430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012000100010001000000000000000000000000000000000000505152535051525350515253505152530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101110101012000001000100000000000000000000000000000000000000606162636061626360616263606162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010111011101012000000010000000000000000000000000000000000000000707172737071727370717273707172730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011101010111012000000000000000000000000000000000000000000000000424340414243404142434041424340410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1110101010101112000000000000000000000000000000000000000000000000525350515253505152535051525350510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101012000000000000000000000000000000000000000000000000626360616263606162636061626360610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131314000000000000000000000000000000000000000000000000727370717273707172737071727370710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
494a490f494a490f4d4e00000000000000000000000000000000000000000000404142434041424340414243404142430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86878687868786875d5e00000000000000000000000000000000000000000000505152535051525350515253505152530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6667666766676667000000000000000000000000000000000000000000000000606162636061626360616263606162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7478757876787778000000000000000000000000000000000000000000000000707172737071727370717273707172730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000424340414243404142434041424340410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000525350515253505152535051525350510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000626360616263606162636061626360610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000727370717273707172737071727370710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000404142434041424340414243404142430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000505152535051525350515253505152530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000606162636061626360616263606162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000707172737071727370717273707172730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000424340414243404142434041424340410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000525350515253505152535051525350510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000626360616263606162636061626360610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000727370717273707172737071727370710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01080000180761c0761f0762307600003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01080004180561c0561f0562105600502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200500
01080000180561b0561f0562205617100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
01080004180561b0561f0562105600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000180561c0561f0561605600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000305213d52132521375212851100505005000b5002b511375210c0002b511385210c0002b511385212e5213a5213d5213952126511225002e500315003a5113d5113a5113d5113a511385110050000500
011000000016000160001600016000160001600016000160001600016000160001600016000160001600016000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003c6151c0001f0002300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000024865248652b0052f0050c0050c00524965249652b0052d0050c0050c00524965249650c0050c00524865248652b0052f0050c0050c00524965249652b0052d0050c0050c00524965249650c0050c005
0110000024a6524a650c0050c0050c0050c00524b6524b652b0052d0050c0050c00524b6524b650c0050c00524a6524a652b0052f0050c0050cb0524b6524b652b0052d0050c0050c00524b6524b650c0050c005
011000002286522865290052d0050c0050c0052296522965290052b0050c0050c00522965229650c0050c0052286522865290052d0050c0050cb052296522965290052b0050c0050c00522965229650c0050c005
0110000022a6522a65290052d0050c0050c00522b6522b65290052b0050c0050c00522b6522b650c0050c00525a6525a650c0052ac651b0052ac650c0052900526a6526a650c0052bc65240052bc650c0050c005
0110000018e5000e0000e001fe5000e0000e0021e5000e0000e0000e001fe5000e0000e0021e5000e0000e0018e5000e0000e001fe5000e0000e0021e5000e0000e0000e001fe5000e0000e0021e5000e0000e00
0110000016e5000e0000e001de5000e0000e001fe5000e0000e0000e001de5000e0000e001fe5000e0000e0016e5000e0000e001de5000e0000e001fe5000e0000e0000e001de5000e0000e001fe5000e0000e00
0110000016e5000e0000e001de5000e0000e001fe5000e0000e0000e001de5000e0000e001fe5000e0000e0019e5519e5300e001ee501ee501ee0000000000001ae551ae5300e001fe501fe501ae5013e5000000
0110000018f3018f1318f1318f3318f1318f1318f3318f1318f1318f1318f3318f1318f1318f3318f1318f1318f3318f1318f1318f3318f1318f1318f3318f1318f1318f1318f3318f1318f3318f1318f1318f13
0110000024f3024f1324f3324f1324f3324f3324f1324f3324f1324f3324f1324f3324f3324f1324f3324f1324f3324f1324f3324f1324f3324f3324f1324f3324f1324f3324f1324f3324f3324f1324f3324f13
010e00002953429512295142e5342e5122e5143053430512305143051532510325123253432512325123251432534325123251232512325123251232512325123251232512325123251232512325123251232512
0110000015e5000e0000e001ce5000e0000e001ee5000e0019e5000e00000001ee5000e00000001ce5000e0015e5000e0000e001ce5000e0000e001ee5000e0019e5000e00000001ee5000e00000001ce5000000
0110000014e5000e0000e001be5000e0000e001de5000e0018e5000e00000001de5000e00000001be5000e0014e5000e0000e001be5000e0000e001de5000e0018e5000e00000001de5000e00000001be5000000
0110000014e5000e0000e001be5000e0000e001de5000e0018e5000e00000001de5000e00000001be5000e001ce551ce5300e0021e5021e5000e0017e0000e001ae551ae53000001fe501fe501ae5013e5000000
010e00000100001000010000100001000150001500015000000001610016102161021f1041f1021f1021f1021d1141d1121d1121f1141f1121f1121f1121f1121f1121f1121f1121f1121f1121f1121f1121f112
010e00000000000000000001ae001ae001ae001ae001ae001ae001de001be421be421be421be421be421be421be421be321be221be221be221be221be221be221be221be221be221be121be121be121be121be12
01100000208652086527005208650800508005000000000020965209652700520965080050800023c00209001ca651ca652600521c650900521c65000000000026a6526b65260052bc65000002bc650000000000
0110000023120241200010023120001001f12021120211220000000100000000000000000000001f1202112023120241200010026120001002312021120211220010000000001000010000000000001f12021120
0110000022120241200010022120001001f12021120211220010000000000000000000000000001f1202112022120241200010026120001002212000100211202112200100000000000000000241202312022120
0110000021120221200000021120000001d1201f1201f12200000000000000000000000001a1201d1201f1202112022120000002412000000211201f1201f1220000000000000000000000000211201f1201a120
011000001d12011125000001f12013125000002012014125000002212016125050002412018125050000000023120231252012022122221220000000000000002412024125211202312223122000000000000000
011000001d12011125000001f1201312500000201201412500000221201612505000241201812505000231201712508000251201912500000271201b1250d000241201812500000261201a12500000371151f115
011000002186521865280052186509005090050000000000219652196528005219650900509000219002190021865218652800521865090050900500000000002196521965280052196521900219000000000000
011000002086520865270052086508005080050000000000209652096527005209650800508000209002090020865208652700520865080050800500000000002096520965270052096500000000000000000000
01100000141201512017120191201c1201e120201202112023121231222312221120201201c12019120171201c1201e1201c12019120191220000000000000000000000000000000000000000141201712019120
0110000018120000001b1201d1201d1221b12018120000001b1201d1201f1211f1221b1201812016120181202212024121221211f1201f1221f1221e111000000000000000000000000000000000000000023120
0110000025122251222512223120211202012021120231212312221120201201e1201c1201912017120191201c1201e1201c12019122191220000000000101201712019120000001c120201201e1201c12020120
011000001f1221f12200000161201b1201d1202412124122000001f12022120241202b1212b122000002912028122251210000025122000000000000000000002612224121000002312200000000000000000000
0111000015e6021e4021e2021e2021e2016e6022e4022e2022e2022e2015e6021e4021e2021e2021e2011e601de401de201de201de2014e6020e4020e2020e2020e2008120081200813008140071510616105161
0111000000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090020b1520b1020b2020b3020b4020b5020b6020b6020b6020b6120b61
0111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026b1526b1026b2026b3026b4026b5026b6026b6026b6026b6126b61
0110000016e6016e000000017e6017e050000016e6022e5513e601fe5516e6022e000000017e6023e000000016e6022e5513e601fe5517e0023e000100018e0024e000100017e0023e0014e0020e000000000000
0110000017e6023e000100018e6024e000100017e6023e5514e6020e5517e6023e000100018e6024e000100017e6023e5514e6020e55000000000000000000000000000000000000000000000000000000000000
0110000025b6525b650100028b6528b650100023b650100024b650100025b6525b650100028b6528b650100023b650100024b6500000000000000000000000000000000000000000000000000000000000000000
0110000026b6526b650200029b6529b650200024b650200025b650100026b6526b650200029b6529b650200024b650200025b6500000000000000000000000000000000000000000000000000000000000000000
010a000024f3024f1324f1324f130000024f33000000000024f0024f0024f0024f0024f0000000000000000024f3024f1324f1324f130000024f33000000000024f0000000000000000000000000000000000000
011000002212023120221201e12021120211202112221122201211f11100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011000000000000000000000000000000000000000000000000000000000000235000000000000000000e120111200f1201412017120235002350000000000000000000000000000000000000000000000000000
011000002312024120231201f12022120221202212222122211212011100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011600002112023120011002412001100211201d1201d1222d5152f5150d100305150d1002d51529510295121f120211200110023120011001f1201c1201c1222b5152d5150d1002f5150d1002b5152851028512
011600001a1201c120000001d12001100000000000000000295152b515000002d515000001a120221211f1201f1220000000000305152f5152b51528515000000000000000000002b515285151f5152651500000
011600001a1201c120000001d1200000000000000000000000000000000000000000000000000000000000001c1201e1200000020120000002112000000231202312200000000002851526515235152051500000
011600001ae5002e0002e001de5002e0002e0024e5000000000000000000000000000000000000000000000018e5000e0000e001fe5000e0000e0023e50000000000000000000000000000000000000000000000
0116000026a65000000000026a6500000000000000000000000000000026a65000000000000000000000000024865000000000024865000000000000000000000000000000248650000000000000000000000000
011600001ae5002e0002e001de5002e0002e0024e5000000000000000000000000000000000000000000000017e5002e0002e001ce5002e0002e0020e50000000000000000000000000000000000000000000000
0116000026a6500c000000026a6500000000000000000000000000000026a65000000000000000000000000028c6500c000000028c6500000000000000000000000000000028c650000000000000000000000000
01020000373152b315000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001b35019650173501565014340136400f3300e6300b3300a63008320066200531004610023100060000300003000030000300003000030000300003000030000300003000030000300003000030000300
010600000f3700d6700b37009670083600766003350026500c3400a6400834006640053300463000320006200b310096100731005610043100361000610006100031000610006100061000610006100061500603
010300003f6303f6203f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f610006000060000600006000060000600006000060000600006000060000600006000060000600
010300003955500500265550050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01050000265552b555005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
011000001f251132510d2500d2500c2510b2510020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010e00000000000000000000000000000000000000000000000000000000000000001610016124161221612216124161221612216122161221612216122161221612216122161221612216122161221612216122
01080000367503b7513b7550f70033750397513275132752317513175503700037000370003700037000370003700037000370003700037000370003700037000370003700037000370003700037000370003700
010300002b5512d55300500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500233452f3453b3450050000500005000050000500
010400002174318703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
__music__
00 0c 08 0f 18
00 0c 09 0f 19
00 0d 0a 0f 1a
00 0e 0b 0f 1b
00 0c 08 0f 18
00 0c 09 0f 19
00 0d 0a 0f 1a
00 0e 0b 0f 1c
00 12 1d 0f 44
00 13 1e 0f 44
00 12 1d 0f 1f
00 13 1e 0f 20
00 12 1d 0f 21
02 14 17 0f 22
00 41 42 43 44
00 23 24 25 44
00 2a 26 28 44
00 2a 27 29 44
01 2a 26 28 2b
00 2a 27 29 2c
00 2a 26 28 44
02 2a 27 29 2d
00 41 42 43 44
01 31 42 32 44
00 31 42 32 44
00 31 42 32 2e
00 31 42 32 2f
00 31 42 32 2e
02 33 42 34 30
00 41 42 43 44
04 16 3c 15 11
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
