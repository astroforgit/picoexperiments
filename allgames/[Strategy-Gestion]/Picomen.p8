pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- picomen
-- by @astrangefool
-- v2.0.0
-- part of the 2020/1 toyboxjam
-- by tom hall & friends
g = {}

function _init()
	_split_values()
	_af()
	cartdata"strangefool_picomen_202"
	player:load()
	title:init()
end

function _update60()
	j:u()
	if g.start then
		if g.battle then
			g.battle:update()
			if g.battle.complete then
				if g.battle.outcome == -1 then
					overworld:resume()
				else
					overworld:resume(g.battle.outcome)
				end
				j:p"6"
				g.battle = nil
			end
		elseif g.selector then
			g.selector:update()
			if g.selector.complete then
				g.battle = battle:new(g.selector:team(), g.next_fight[1])
				g.selector = nil
				j:p(g.next_fight[3])
			end
		else
			overworld:update()
			if overworld.complete then
				if overworld.ending then
					save_clear()
					extcmd"reset"
				else
					g.next_fight = overworld.next_fight
					g.selector = selector:new(g.next_fight[2])
					j:p"37"
				end
			end
		end
	else
		title:update()
		g.start = title.complete
		if g.start then
			overworld:populate()
			overworld:resume()
		if (player.has_save == false)	overworld._textbox = textbox:new(1)
		end
	end
end

function _draw()
 cls()
 if g.start then
 	if g.battle then
 		g.battle:draw()
 	elseif g.selector then
 		g.selector:draw()
 	else
	 	if (not overworld.complete) overworld:draw()
	 end
 else
  title:draw()
 end
end

-->8
function ability_print(f,x,y)
	_ab_p(f,2,x,y)
	_ab_p(f,3,x,y+10)
end

function c_b(x,y,x2,y2,c)
	rect(x,y-1,x2,y2+1,c)
	rect(x-1,y,x2+1,y2,c)
	rectfill(x,y,x2,y2,0)
end

function _ab_p(f,a,x,y)
	local _a = abilities[fighters[f][a]][3]
	print(_a[1],x,y,6)
	for i=2,#_a do
		spr(_a[i][1],x+_a[i][2],y-1)
	end
end

function b_d(b)
	for r in all(backgrounds[b][1]) do
		rectfill(r >> 9 & 0x7f,r >> 2 & 0x7f,r << 5 & 0x7f,r << 12 & 0x7f,r << 16 & 0xf)
	end
	for l in all(backgrounds[b][2]) do
		spal(l[2])
		for s in all(l[1]) do
			bgd(s >> 8 & 0xff,s & 0xff,s << 8 & 0xff,s << 16 & 0xff)
		end
	end
end

function bgd(x,y,sprite,scale,do_flip)
	scale *= 8
	sspr(sprite%16*8,sprite\16*8,8,8,x-scale\2,y-scale\2,scale,scale,do_flip)
end

function f_p(s,x,y,c,b)
	for _x=-1,1 do
		for _y=-1,1 do
			print(s,x+_x,y+_y,b or 0)
		end
	end
	print(s,x,y,c)
end

function spal(palette)
	local p = palette or {0x0302.0110,0x0706.0504,0x0b0a.0908,0x0f0e.0d0c}
	local sp = scene_palette or {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
	for b=1,4 do
		local out = p[b] & 0xf0f0.f0f0
		for s=-16,8,8 do
			out += sp[1+(p[b] >> s & 0xf)] << s
		end
		poke4(0x5efc+b*4,out)
	end
end
command = {}

function command:new(id, delay, args)
	local r = {
		cmd = commands[id],
		_delay = delay,
		_args = args
	}
	n(r,self)
	return r
end

function command:update(state)
	if self._delay > 0 then
		self._delay -= 1
	else
		self.cmd(state, self._args)
		return true
	end
end
effect = {}

function effect:new(id, delay, x, y, args)
	local r = {
		_delay = delay or 0,
		_x = x or 0,
		_y = y or 0,
		_args = args or {},
		_timer = effects[id][1],
		_draw = effects[id][2],
		_snd = args and args.snd or effects[id][3],
	}
	r._play = r._snd != nil
	n(r,self)
	return r
end

function effect:update()
	if self._delay > 0 then
		self._delay -= 1
	else
		if self._play then
			sfx(self._snd)
			self._play = false
		end
		if self._timer > 0 then
			self._timer -= 1
		else
			return true
		end
	end
end

function effect:draw(e)
	if (self._delay == 0) self:_draw(self._timer, e)
end
portrait = {
	_delta_x = 0,
	_timer = 0
}

function portrait:new(s, px, d, py)
	local r = {
		_speaker = portraits[s],
		_x = px,
		_ox = px,
		_y = py or 0
	}
	n(r,self)
	if d then
		r._delta_x = (d - px) / 30
		r._timer=30
	end
	return r
end

function portrait:update()
	if self._timer > 0 then
		self._timer-=1
		self._x+=self._delta_x
	end
end

function portrait:draw()
	spal(self._speaker[3])
	for s in all(self._speaker[2]) do
		bgd((s >> 8 & 0xff) + self._x - 64, (s & 0xff) + self._y, s << 8 & 0xff, s << 16 & 0xff)
	end
	spal()
end

function portrait:slide(d)
	self._delta_x = (d - self._x) / 30
	self._timer=30
end

function portrait:stopped()
	return self._timer==0
end

player = {
	has_save = false,
	fighters = {}
}

function player:add(i)
	add(self.encounters, i)
end

function player:remove(i)
	del(self.encounters, i)
	self:save()
end

function player:set(n)
	self.fighters[n] = true
end

function player:save()
	player.has_save = true
	poke(0x5e00, 0x69)
	for i = 0, 31 do
		poke(0x5e10 + i, player.encounters[i+1] or 0)
	end
	for i = 0, 99 do
		poke(0x5e30 + i, (player.fighters[i+1]) and 0xff or 0)
	end
end

function player:load()
	self.encounters = {}
	for i = 0, 31 do
		local _v = @(0x5e10 + i)
		if (_v > 0)	add(self.encounters, _v)
	end
	for i = 0, 99 do
		self.fighters[i+1] = @(0x5e30 + i) == 0xff
	end
	if @0x5e00 == 0x69 then
		self.has_save = true
	else
		self.has_save = false
		self.encounters = {1}
		self.fighters[1] = true
	end
end

j = {
	_t = 0
}

function j:u()
	if self._t > 0 then
		self._t -= 1
		if self._t == 0 then
			if self._n then
				music(self._n, 1000)
			else
				self._p = false
			end
		end
	end
end

function j:p(i)
	if self._p then
		self._n = i
		music(-1, 1200)
		self._t = 100
	else
		music(i, 1000)
		self._p = true
	end
end

textbox = {
	_portraits = {},
	_line = 1,
	_character = 0,
	_page = 0,
	_timer = 0,
	_fade = "in"
}

function textbox:new(_s)
	local r = {
		_dialogue = dialogues[_s]
	}
	n(r,self)
	r._portraits[r._dialogue[1]] = portrait:new(r._dialogue[1], 192, 96)
	r._portraits.touchdown = portrait:new("touchdown", -64, (_s > 4 and _s != 25) and 32 or -64)
	r._portraits[r._dialogue[1]]._y -= 5
	return r
end

function textbox:update()
	local result = false
	for k,v in pairs(self._portraits) do
		v:update()
	end
	if self._fade != "none" then
		if (self._timer < 12)	self._timer += 1
		if self._timer == 12 then
			if self._fade == "in" then
				self._timer = 0
				self._fade = "none"
			else
				result = true
				for k,v in pairs(self._portraits) do
					result = result and v:stopped()
				end
			end
		end
	else
		local _l = self._dialogue[2]
		if self._character == 56 then
			if btnp"5" and not self._held then
				sfx"2"
				self._character = 0
				self._page += 1
				if self._page*56 >= #_l[self._line][2] then
					self._page = 0
					self._line += 1
					if self._line > #_l then
						for i in all({self._dialogue[1],"touchdown"}) do
						self._portraits[i]:slide(self._portraits[i]._ox)
					end
						self._timer = 0
						self._fade = "out"
					else
						self._portraits[_l[self._line-1][1]]._y += 5
						self._portraits[_l[self._line][1]]._y -= 5
					end
				end
			end
			if (not btn"5") self._held = false
		else
			self._timer += 1
			if btn"5" then
				self._held = true
				self._timer = 5
			else
      	self._held = false
      end
			if self._timer > 4 then
				self._timer = 0
				self._character += 1
				if (self._character + self._page*56 > #_l[self._line][2]) self._character = 56
			end
		end
	end
	return result
end

function textbox:draw()
	for k,v in pairs(self._portraits) do
		v:draw()
	end
	local _f = 1
	if self._fade != "none" then
		_f = min(self._timer, 12) / 12
		if (self._fade == "out") _f = 1-_f
	end
	if _f > 0 then
		c_b(4,104-_f*19,123,104+_f*19,9)
		local _l = self._dialogue[2][self._line]
		for i = 1, self._character do
			spr(ord(_l[2],i+56*self._page),8+((i-1)%14)*8,89+((i-1)\14)*8)
		end
		if self._fade == "none" then
			f_p(portraits[_l[1]][1],8,78,9)
		end
		if self._character == 56 then
			f_p("—",119,120,9)
		end
	end
end


battle = {
	_turn = 0,
	_to = {{"attack", 26}, {"defence", 29}, {"poison", 164}, {"fire", 167}, {"ice", 96}, {"bolt", 124}, {"coin", 66}, {"food", 230}, {"health", 5}},
	_timer = 0,
	_input_box = 0
}

function battle:new(g, b)
	local r = {}
	n(r,self)
	r._effects, r._commands = {},{}
	r._goodies = {team = g}
	r._baddies = {team = b}
	local params = {
		{r._goodies, -64, 30},
		{r._baddies, 192, 97}
	}
	for p in all(params) do
		p[1].max_health = 0
		p[1].portraits = {}
		for i in all(p[1].team) do
			p[1].max_health += fighters[i][1]
			p[1].portraits[i] = portrait:new(i, p[2])
		end
		for s in all {"p","c","a"} do
			p[1][s] = {}
			for t in all(r._to) do
				p[1][s][t[1]] = 0
			end
		end
		p[1].immune = {}
		p[1].c.health = p[1].max_health
		p[1].a.health = p[1].max_health
		p[1].head = 1
		add(r._commands, command:new("slide", 60, {p[1].portraits[p[1].team[p[1].head]], p[3]}))
		p[1].early_swap = false
	end
	add(r._effects, effect:new"wipe_in")
	r:iterate()
	r._turn = 1
	return r
end

function battle:update()
	self._timer += 1
	self._timer %= 4
	if self._input then
		self._help = btn"3"
		self._goodies.early_swap = false
		self._baddies.early_swap = false
		self._input_box = 0
		local state_change = false
		if btnp"0" then
			self._input_box = 1
			self._exit = true
			state_change = true
		elseif btnp"4" then
			self._input_box = 2
			self._goodies.early_swap = true
			state_change = true
		elseif btnp"5" then
			self._input_box = 3
			state_change = true
		end
		if state_change then
			sfx"0"
			self:iterate()
			self._input = false
		end
	else
	  self._help = false
		local ready = true
		for t in all({self._goodies, self._baddies}) do
			for k, v in pairs(t.portraits) do
				v:update()
				ready = ready and v:stopped()
			end
		end
		for e in all(self._effects) do
			if (e:update()) del(self._effects, e)
		end
		ready = ready and (#self._effects == 0)
		for e in all(self._commands) do
			if (e:update(self)) del(self._commands, e)
			ready = false
		end
		if ready then
			if self._exit then
				self.complete = true
			else
				self._input = true
			end
		end
	end
end

function battle:draw()
	spal()
	b_d"battle1"
	if self._timer == 0 then
		for i = 1, 4 do
			local _x = rnd(127) - 32
			local _y = rnd(54) + 34
			line(_x,_y,_x+64,_y,13)
		end
	end
	for t in all({self._goodies, self._baddies}) do
		local prev = t.head - 1
		if (prev == 0) prev = #t.team
		local prev2 = prev - 1
		if (prev2 == 0) prev2 = #t.team
		for i in all{t.head, prev, prev2} do
			t.portraits[t.team[i]]:draw()
		end
	end
	spal()
	f_p("ƒ?", 2, 2, 9)
	local c = self._input and 9 or 1
	c_b(4,113,123,123,c)
	print("‹ flee",7,116,(self._input_box==1)and 9 or c)
	print("Ž swap",48,116,(self._input_box==2)and 9 or c)
	print("— attack",86,116,(self._input_box==3)and 9 or c)
	local params = {
		{self._goodies,1,85,13,87},
		{self._baddies,119,19,71,22}
	}
	for p in all(params) do
		spr(5,p[2],p[3])
		c_b(p[4],p[5],p[4]+44,p[5]+2,9)
		add(p,p[1].a.health/p[1].max_health)
		f_p(p[1].a.health,62-4*#p[1].a,p[5]-1,8)
	end
	if (params[1][6] > 0) rectfill(params[1][4], params[1][5], params[1][4]+44*params[1][6], params[1][5]+2, 8)
	if (params[2][6] > 0) rectfill(params[2][4]+44-44*params[2][6], params[2][5], params[2][4]+44, params[2][5]+2, 8)
	params = {
		{self._goodies.a, 0, 94, 10},
		{self._baddies.a, 0, 12, -10}
	}
	for p in all(params) do
		local w = 0
		for t in all(self._to) do
			if (p[1][t[1]] != 0 and t[1] != "health") w += 1
		end
		w *= 10
		if p[4] > 0 then
			if (w > 0) rectfill(p[2],p[3],p[2]+w+1,p[3]+5,9)
		else
			if (w > 0) rectfill(127-p[2]-w-1,p[3],127-p[2],p[3]+5,9)
		end
		local x = (p[4]<0)and(128-p[2])or(p[2]-9) 
		local y = (p[4]<0)and(p[3]-11)or(p[3]+1)
		for t in all(self._to) do
			if p[1][t[1]] != 0 and t[1] != "health" then
				x += p[4]
				spr(t[2], x, y)
				f_p(p[1][t[1]], x+1, y+10, 9)
			end
		end
	end
	if (self._goodies.early_swap) f_p("swap",2,79,9)
	if (self._baddies.early_swap) f_p("swap",111,28,9)
	for e in all(self._effects) do
		e:draw(self._effects)
	end
	if self._help then
		params = {
			{self._goodies, 98},
			{self._baddies, 2}
		}
		for p in all(params) do
			local _f = p[1].team[p[1].head]
			rectfill(0,p[2]-3,127,p[2]+29,0)
			c_b(1,p[2]+9,126,p[2]+28,9)
			f_p(portraits[_f][1], 3, p[2], 9)
			ability_print(_f, 3, p[2]+12)
		end
	end
end

function battle:iterate()
	if self._exit then
		self.outcome = -1
		add(self._effects, effect:new("caption",0,0,0,{"escape",9}))
		add(self._effects, effect:new("wipe_out", 100))
		add(self._commands, command:new("slide", 0, {self._goodies.portraits[self._goodies.team[self._goodies.head]], -64}))
	else
		if self._turn > 1 then
			self._baddies.early_swap = false
			if (rnd() < 0.025) self._baddies.early_swap = true
		end
	  local _delay = 0
		local params = {
			{self._goodies, self._baddies, -64, 30, "_goodies"},
			{self._baddies, self._goodies, 192, 97, "_baddies"}
		}
		for p in all(params) do
			if p[1].early_swap then
				_delay = 35
				p[1].portraits[p[1].team[p[1].head]]:slide(p[3])
				p[1].head += 1
				if (p[1].head > #p[1].team) p[1].head = 1
				p[1].portraits[p[1].team[p[1].head]]:slide(p[4])
			end
		end
		if (self._goodies.early_swap or self._baddies.early_swap) self:_update_passives(params, _delay)
		if self._turn > 0 then
			local good_ability = abilities[fighters[self._goodies.team[self._goodies.head]][2]]
			local bad_ability = abilities[fighters[self._baddies.team[self._baddies.head]][2]]
			if good_ability[2] > bad_ability[2] then
				if (not self._goodies.early_swap) good_ability[4](self._goodies, self._baddies, true)
				if (not self._baddies.early_swap) bad_ability[4](self._baddies, self._goodies, true)
			else
				if (not self._baddies.early_swap) bad_ability[4](self._baddies, self._goodies, true)
				if (not self._goodies.early_swap) good_ability[4](self._goodies, self._baddies, true)
			end
			_delay += 10
			local health_delay = 0
			if not self._goodies.early_swap then
				health_delay = effects[good_ability[1]][1]
				add(self._effects, effect:new(good_ability[1], _delay, {32, 96}, -4, good_ability[5]))
			end
			if not self._baddies.early_swap then
				health_delay = max(effects[bad_ability[1]][1], health_delay)
				add(self._effects, effect:new(bad_ability[1], _delay, {96, 32}, 4, bad_ability[5]))
			end
			health_delay += _delay
			_delay += 5
			for p in all(params) do
				local _a = _total(p[1], "attack")
				if (_a > 0) _a = max(0, _a - max(0, _total(p[2], "defence")))
				add(self._commands, command:new("update_status", _delay, {p[5], "attack", _a}))
			end
			for p in all(params) do
				if (not p[1].immune.attack) p[1].c.health -= max(0, _total(p[2], "attack") - max(0, _total(p[1], "defence")))
				local _d_dmg = max(0, _total(p[2], "attack"))
				for s in all({p[1].c, p[1].p}) do
					if _d_dmg > 0 and s.defence > 0 then
						s.defence -= _d_dmg
						_d_dmg = 0
						if s.defence < 0 then
							_d_dmg = s.defence * -1
							s.defence = 0
						end
					end
				end
				local _d = max(0, _total(p[1], "defence"))
				if (_d == 0) p[1].p.poison += max(0, p[1].c.poison)
				p[1].c.poison = 0
				if (not p[1].immune.poison) p[1].c.health -= max(0, p[1].p.poison)
				p[1].p.fire += max(0, p[1].c.fire - _d)
				p[1].c.fire = 0
				if (not p[1].immune.fire) p[1].c.health -= max(0, p[1].p.fire)
				if (not p[1].immune.ice) p[1].c.health -= max(0, _total(p[1], "ice") - _d)
				if (not p[1].immune.bolt) p[1].c.health -= max(0, _total(p[1], "bolt"))
				for t in all(self._to) do
					if (t[1] != "attack" and t[1] != "health") add(self._commands, command:new("update_status", _delay, {p[5], t[1], _total(p[1], t[1])}))
				end
				p[1].p.coin += max(0, p[1].c.coin)
				p[1].c.coin = 0
				p[1].p.fire = max(0, p[1].p.fire - 1)
				p[1].c.health = mid(0, p[1].c.health, p[1].max_health)
			end
			add(self._commands, command:new("update_health", health_delay, {self._goodies.c.health, self._baddies.c.health}))
			_delay = health_delay + 10
			if self._goodies.c.health == 0 then
				self.outcome = 0
				self._exit = true
				add(self._effects, effect:new("caption",_delay,0,0,{"defeat",8}))
				add(self._effects, effect:new("wipe_out", 100 + _delay))
			elseif self._baddies.c.health == 0 then
				self.outcome = 1
				self._exit = true
				add(self._effects, effect:new("caption",_delay,0,0,{"victory",11}))
				add(self._effects, effect:new("wipe_out", 100 + _delay))
			else
				self._turn += 1
			end
			if not self._exit then
				for p in all(params) do
					add(self._commands, command:new("slide", _delay, {p[1].portraits[p[1].team[p[1].head]], p[3]}))
					p[1].head += 1
					if (p[1].head > #p[1].team) p[1].head = 1
					add(self._commands, command:new("slide", _delay, {p[1].portraits[p[1].team[p[1].head]], p[4]}))
				end
			end
		end
		if (not self._exit) self:_update_passives(params, _delay)
	end
end

function battle:_update_passives(params, delay)
	for p in all(params) do
		p[1].immune = {}
		for t in all(self._to) do
			if (t[1] != "health") p[1].c[t[1]] = 0
		end
		for i = 1, #p[1].team do
			abilities[fighters[p[1].team[i]][3]][4](p[1], p[2], (p[1].head == i))
		end
		for t in all(self._to) do
			if (t[1] != "health") add(self._commands, command:new("update_status", delay, {p[5], t[1], _total(p[1], t[1])}))
		end
	end
end

function _total(team, token)
	return team.c[token] + team.p[token]
end

overworld = {
	_e = {},
	_t = 0,
	_x = 126
}

function overworld:update()
	self._t += 1
	self._t %= 40
	if self._input then
		if self._textbox then
			if (self._textbox:update()) self._textbox = nil
		elseif self.ending then
			if self._ending2 then
				self._wipe, self._exit, self._input = effect:new"wipe_out", true
			else
				self._textbox = textbox:new(25)
				j:p"14"
				self._ending2 = true
			end
		else
			if (btn"0") self._x -= 2
			if (btn"1") self._x += 2
			self._x = mid(0, self._x, 378)
			self._selected = nil
			for k, v in pairs(slots) do
				if self._x >= v[2] and self._x <= v[3] then
					self._selected = k
				end
			end
			if btnp"5" then
				local _o = self._e[self._selected]
				if _o then
				  sfx"0"
				  local _v = encounters[_o][3]
					if encounters[_o][2] == "?" then
						self._textbox = textbox:new(_v)
						self:_execute(encounters[_o][7], -1)
					else
						self.next_fight = battles[_v]
						self._wipe, self._exit, self._input = effect:new"wipe_out", true
					end
					if (not self._exit) self:_remove()
				end
			end
		end
	else
		if (self._wipe and self._wipe:update()) self._wipe = nil
		if not self._wipe then
			if self._exit then
				self.complete = true
			else
				self._input = true
			end
		end	
	end
end

function overworld:draw()
	if (self._textbox or self.ending) scene_palette = grey_palette
	spal()
	b_d"city_sky"
	for l in all({{"lefty", 0, 3}, {"right", 128, 3}, {"crane", 0, 1}, {"hotel", 128, 1}, {"slums", 256, 1}, {"tower", 384, 1}}) do
		local _sx = l[2] - self._x / l[3]
		clip(_sx, 0, 128, 128)
		spal(city[l[1]][2])
		for s in all(city[l[1]][1]) do
			bgd((s >> 8 & 0xff) + _sx, s & 0xff, s << 8 & 0xff, s << 16 & 0xff)
		end
	end
	clip()
	scene_palette = nil
	spal()
	if self._textbox or self.ending then
		if (self._textbox) self._textbox:draw()
	else
		if self._selected then
			c_b(4,113,123,123,9)
			local s = slots[self._selected][1]
			if self._e[self._selected] then
				s = encounters[self._e[self._selected]][1]
				f_p("—", 60, 109, 9)
			end
			print(s, 64 - #s*2, 116, 9)
		end
		local _dy = self._t \ 10
		for k,v in pairs(self._e) do
		  local _v = encounters[v]
		  local _x = _v[5] - self._x
		  if _x < -7 then
		  	spr(210, 0, _v[6] - _dy, 1, 1, true, false)
		  elseif _x > 127 then
		  	spr(210, 120, _v[6] - _dy, 1, 1, false, true)
		  else
				spr(80, _x, _v[6] - _dy, 1, 1, false, true)
				f_p(_v[2], _x+7, _v[6]-_dy-4, 9)
			end
		end
		if (self._x > 0) f_p("‹", 2, 64, 9)
		if (self._x < 378) f_p("‘", 119, 64, 9)
	end
	if (self._wipe) self._wipe:draw()
end

function overworld:populate()
	self._e = {}
	for i in all(player.encounters) do
		local _slot = encounters[i][4]
		if not self._e[_slot] then
			self._e[_slot] = i
		end
	end
end

function overworld:_execute(p, a)
	for f in all(p) do
		local _t = f[1]
		local _v = f[2]
		local _e = false
		if (_t < 5) _e = true
		if (_t > 4 and _t < 9 and a == 1) _e = true
		if (_t > 8 and _t < 13 and a == 0) _e = true
		if _e then
		 _t-=1
		 _t%=4
		 if (_t == 0) player:add(_v)
		 if (_t == 1) player:remove(_v)
		 if (_t == 2) player:set(_v)
		 if (_t == 3) self._textbox = textbox:new(_v)
		end
		if (_t == 13) self.ending = true
	end
end

function overworld:_remove()
	player:remove(self._e[self._selected])
	if (#player.encounters == 0 and not self.ending) player:add(38)
	self:populate()
end

function overworld:resume(args)
	if args then
		self:_execute(encounters[self._e[self._selected]][7], args)
		self:_remove()
	end
	self._wipe, self._input, self._exit, self.complete = effect:new"wipe_in"
end

selector = {
	_page = 0,
	_t = 0,
	_c = {0, 0}
}

function selector:new(l)
	local r = {}
	r._team = {}
	r._fighters = {}
	r._l = l
	n(r,self)
	for k,v in pairs(fighters) do
		local _p = (v[4] - 1) \ 24 * 24
		local _x = (v[4]-_p-1) % 6
		local _y = (v[4]-_p-1) \ 6
 		r._fighters[v[4]] = {k, portrait:new(k, _x*19+portraits[k][4][1], 0, _y*19-64+portraits[k][4][2])}
	end
	r._wipe = effect:new"wipe_in"
	return r
end

function selector:update()
	self._t += 2
	self._t %= 120
	if self._input then
		if (btnp"0") self._c[1] -= 1
		if self._c[1] == -1 then
			self._c[1] = 5
			self._page -= 1
		end
		if (btnp"1") self._c[1] += 1
		if self._c[1] == 6 then
			self._c[1] = 0
			self._page += 1
		end
		if (btnp"2") self._c[2] -= 1
		if (btnp"3")	self._c[2] += 1
		self._c[2] = mid(0, self._c[2], 3)
		if btnp"4" then
			local _i = self._page*24+self._c[2]*6+self._c[1]+1
			if _i > 0 and _i <= #self._fighters and player.fighters[_i] then
				sfx"0"
				if (not del(self._team, _i)) add(self._team, _i)
			end
		end
		if btnp"5" and #self._team >= 1 and #self._team <= self._l then
			sfx"3"
			self._wipe, self._exit, self._input = effect:new"wipe_out", true
		end
	else
		if (self._wipe and self._wipe:update()) self._wipe = nil
		if not self._wipe then
			if self._exit then
				self.complete = true
			else
				self._input = true
			end
		end
	end
end

function selector:draw()
	for i = -2,4 do
		line(i*40+self._t\3, 0, i*40+10+self._t\3, 127, 1)
	end
	for i = 0,23 do
		local _x = i % 6
		local _y = i \ 6
		clip(_x*19+8, _y*19+11, 17, 17)
		rectfill(_x*19+8, _y*19+11, _x*19+24, _y*19+27, 0)
		local _id = self._page*24+_y*6+_x+1
		local _f = self._fighters[_id]
		if (_f and player.fighters[_id]) _f[2]:draw()
		rect(_x*19+8, _y*19+11, _x*19+24, _y*19+27, 1)
	end
	clip()
	local _dx = 0
	for s in all({114,101,97,100,121,0,117,112}) do
		spr(s, _dx + 32, 1)
		_dx += 8
	end
	print("max "..self._l,5)
	print(self._page<1 and "‘" or "‹",self._page<1 and 121 or 0,47,9)
	print("Ž add/remove      — fight!",9,88,5)
	local _x = self._c[1]
	local _y = self._c[2]
	local _id = self._page*24+_y*6+_x+1
	local _f = self._fighters[_id]
	rect(_x*19+8,_y*19+11,_x*19+24,_y*19+27,9)
	c_b(1,105,126,126,9)
	if _f and player.fighters[_id] then
		local _fn = _f[1]
		f_p(portraits[_fn][1], 3, 98, 9)
		spr(5, 107, 96)
		f_p(fighters[_fn][1], 118, 98, 8)
		ability_print(_fn, 3, 110)
	end
	local _di = 0
	for i in all(self._team) do
		_di += 1
		local _p = (i - 1) \ 24
		if _p == self._page then
			_p *= 24
			_x = (i-_p-1) % 6
			_y = (i-_p-1) \ 6
			f_p(_di, _x*19+9, _y*19+22, 9)
		end
	end
	if (self._wipe) self._wipe:draw()
end

function selector:team()
	local result = {}
	for i in all(self._team) do
		add(result, self._fighters[i][1])
	end
	return result
end

title = {}

function title:init()
	self._wipe = effect:new"wipe_in"
	menuitem(1, "clear save data", save_clear)
	j:p"0"
end

function title:update()
	if self._input then
		if btnp"5" then
			sfx"3"
			menuitem(1)
			self._wipe, self._exit, self._input = effect:new"wipe_out", true
			j:p"6"
		end
	else
		if (self._wipe and self._wipe:update()) self._wipe = nil
		if not self._wipe then
			if self._exit then
				self.complete = true
			else
				self._input = true
			end
		end
	end
end

function title:draw()
	b_d"title"
	f_p(player.has_save and "— continue" or "— new game",42,100,self._exit and 6 or 9)
	print("@astrangefool's",52,26,7)
	print("made for toyboxjam 2020",18,111,7)
	if (self._wipe) self._wipe:draw()
end



battles = {}
fmap = {}
fighters = {}
encounters = {}

slots = {
	docks = {"the docks",0,33},
	factory = {"old bean factory",62,118},
	hotel = {"sunrise hotel",135,180},
	slums = {"crime district",210,305},
	tower = {"chickencorp",335,378}
}

slotmap = {"docks","factory","hotel","slums","tower"}
dialogues = {
	{
		"none",
		{
			{"none","in future year1999, new zonecity is filledwith bad gangsthen one day  american hero  \"touchdown\"  become arrive"}
		}
	},
	{
		"helpy",
		{
			{"helpy","howdy partner,i'm helpy the tutorial beast              if you want tolearn how to  play the game pick me again if you don't, head straight on over to thehotel!"}
		}
	},
	{
		"helpy",
		{
			{"helpy","now the folks in town eitherwanna talk (?)or fight (!)  when you starta fight you'llfirst pick outyour team.    the trick is  putting 'em ina decent orderfor the battleall the healthgets added up so bring alongplenty hearts!each turn in afight you can attack, swap  or run away...by pressing ? you can read  your enemies' abilities...  you wanna win fights? keep  your best guysat the front!"}
		}
	},
	{
		"helpy",
		{
			{"helpy","good tussle,  partner!      i'll join yourstable."}
		}
	},
	{
		"landlard",
		{
			{"landlard","it's high timesome cool herocleaned up    this city...  hey, kid! you look like you got moxie, andfootball pads i'll tell you where to find the three big street gangs!"},
			{"touchdown","..."},
			{"landlard","there's the   cy-birds who  run the tower district...   the dandy ladswho work outtathe docks zone              and lastly,   the league of mystical jerks(est. 1997)"},
			{"touchdown","..."},
			{"landlard","you sort thoseguys out and  i'll give you a boiled egg!"}
		}
	},
	{
		"secretary",
		{
			{"secretary","welcome to    chickencorp   how may i helpyou?"},
			{"touchdown","..."},
			{"secretary","i'm afraid    our ceo only  fights gangs  by appointmentperhaps you'd care to beat  down a junior executive?"}
		}
	},
	{
		"engineer",
		{
			{"none","beaten right  back to the   bottom of the pecking order!hey... i don'tsuppose you'relooking for   an assistant?"}
		}
	},
	{
		"secretary",
		{
			{"secretary","welcome back! we now have anopening for a new executive.we offer a    competitive   salary, full  business squadand an option to fight the  ceo in mortal combat!       you just need to get through5 'interviews'"}
		}
	},
	{
		"chicken",
		{
			{"chicken","let me shake  the wing of   the new memberof our family the way you   eggs-pertly   fought off thecompetition...reminded me   of me, when   i was a chick."},
			{"touchdown","..."},
			{"chicken","i built this  company! with the sweat off my own beak!  (and a small, $200,000,000  loan from my  old man)      and now you   come and wreckit all for a  boiled egg?!  kid, i have   eggs coming   out of my     behind!       you know what?  ya fiyad!   if you ever   come back...  i'll turn the break room    into a        beak you'm!"}
		}
	},
	{
		"chicken",
		{
			{"chicken","you cooked my goose, kid. mycompany is nowyours...      which is how  this works    apparently."}
		}
	},
	{
		"hedgehog",
		{
			{"hedgehog","oh, gee misterall i wanted  to do was go  fast and...   infringe on   intellectual  property in   peace...      let me make itup to you!"}
		}
	},
	{
		"flamingo",
		{
			{"flamingo","bokka! bokka! i'm sick of   doing what theold bird tellsme to. gimme afistful of    worms and i'm all yours, pal"}
		}
	},
	{
		"shipping",
		{
			{"shipping","ahoy! shippingforecast, herethe leader of the dandy ladsi believe dockwork can be anelegant balletfit for a kingbut the verminin the slums  seek to debasethis fine art!"},
			{"touchdown","..."},
			{"shipping","if you seek myprotection, goto the crime  district...   beat my enemy to dust and   you shall gainmy favour."}
		}
	},
	{
		"sirhute",
		{
			{"sirhute","lemme guess...a !$?@# cloud sent you here to whack me?  that freak is gonna take theheart outta   dock workin'  all people:   boys, girls,  grandmas they all got the   right to haul freight, no   matter how    fancy they is."},
			{"touchdown","..."},
			{"sirhute","tell you what,you go to the docks n' bump off that cloudwith her outtathe way i can take back the docks again...and you have  my word nobodywill bother   the hotel."}
		}
	},
	{
		"sirhute",
		{
			{"sirhute","i knew you wasa sports hero of the people,touchdown!    my boys's hereto back you upnow let's shipthese creeps  outta town!"}
		}
	},
	{
		"shipping",
		{
			{"shipping","splendid work!i shall send  my dandiest   lads to you...bring me sir  hute's head   and my gift toyou will be   the hotel!"}
		}
	},
	{
		"landlard",
		{
			{"landlard","hey, kid...   you know how isaid 'clean upthe city'?"},
			{"touchdown","..."},
			{"landlard","did you hear: join the mafiabecome ceo of a company...  and summon thedevil? 'cause it seems like you did!"},
			{"touchdown","..."},
			{"landlard","ahh, whatever!you did good, kid. here's anegg. thanks."}
		}
	},
	{
		"djinnius",
		{
			{"djinnius","good tidings, fellow seeker of arcane     mysteries..."},
			{"touchdown","..."},
			{"djinnius","we are not a  common street gang! we are  mystic fellowstis' true we  have sometimeslet a spectre or demon loosebut it's not  like there's  one loose     right now!"},
			{"touchdown","..."},
			{"djinnius","ok, so maybe  there's like  *one* demon   loose now...  tell you what,you fix this  little magicalsnafu...      and we'll stopbothering the land lard withour meetings!"},
		}
	},
	{
		"harmy",
		{
			{"harmy","howdy, partneri'm harmy, theprimordial    beast...      since you beatme i reckon   we're soul    bonded, hoss."}
		}
	},
	{
		"djinnius",
		{
  		{"djinnius","i perceive it didn't go wellworry not! i  have a plan...more demons!!!if you beat a demon it will join your team(and it will  only cost you your immortal soul)"}
		}
	},
	{
		"djinnius",
		{
			{"djinnius","ah, you're notdead! super!  it is time to confront harmyevoke the manydemonic alliesyou presumablyhave..."}
		}
	},
	{
		"djinnius",
		{
			{"djinnius","you've saved  our clubhouse!     ...      oh and realityit's just likethe magic codesays: when in doubt, demons!in honour of  this victory  i pronounce   you...        junior wizard!              you're welcome"}
		}
	},
	{
		"shipping",
		{
			{"shipping","oh you wretch,you philistinemy vision of  utopia ruined i thought you were my silverlining..."}
		}
	},
	{
		"sirhute",
		{
			{"sirhute","you's a real  piece of work,touchdown, a  real dandy ladnow dock work is only gonna be for the    wealthy elite!"}
		}
	},
	{
		"none",
		{
			{"none","in future year1999, americanhero touchdownate one egg                    the  end"},
		}
	}
}
abilities = {
	none = {"none", 0,{""}, function () end},
}

decor = {
	attack = {{"slam",{26,5}},{"slam",{26,5,snd=6}},{"slam",{26,8,snd=8}}},
	fire = {{"burst",{166}},{"burst",{74,snd=18}},{"burst",{167,snd=20}}},
	bolt = {{"multi",{71,3}},{"multi",{78,4}},{"multi",{124,5,snd=18}}},
	ice = {{"sml_beam"},{"med_beam"},{"lrg_beam"}},
	poison = {{"bubble",{11}},{"bubble",{87,snd=14}},{"bubble",{129,snd=15}}}
}

function _af()
	for t1 in all(battle._to) do
		abilities["imm_"..t1[1]] = {"",0,{t1[1].." immune: take no   damage",{t1[2],65+4*#t1[1]}},(function(_t) return function(u,t,h) if h then u.immune[_t]=true end end end)(t1[1])}
		for i in all({-3,-2,-1,1,2,3,4,5}) do
			abilities["acc_"..t1[1]..i] = {"rise",0,{"gain "..i,{t1[2],28}},(function(_t,_i) return function(u) u[(_t == "health" and "c" or "p")][_t] += i end end)(t1[1],i),{t1[2],i+1}}
			local _id = max(1, (i+1)\2)
			abilities["att_"..t1[1]..i] = {decor[t1[1]] and decor[t1[1]][_id][1] or "slam",0,{i.."   attack",{t1[2],6}},(function(_t,_i) return function(u,t) local _c = (_t == "attack" and u or t) _c.c[_t] += _i end end)(t1[1],i),decor[t1[1]] and decor[t1[1]][_id][2] or {t1[2],i+1}}
			abilities["buf_"..t1[1]..i] = {"",0,{"has "..i.."    when at the front",{t1[2],26}},(function(_t,_i) return function(u,t,h) if h then u.c[_t] += _i end end end)(t1[1],i)}
			abilities["eff_"..t1[1]..i] = {"",0,{"gives "..i.."    when in the team",{t1[2],32}},(function(_t,_i) return function(u,t,h) u.c[_t] += _i end end)(t1[1],i)}
		end
		for t2 in all(battle._to) do
			for s in all({true, false}) do
				abilities["att_"..(s and "u" or "t")..t1[1].."_"..t2[1]] = {decor[t2[1]] and decor[t2[1]][2][1] or "slam",0,{"a   attack = "..(s and " your" or "their"),{t2[2],6},{t1[2],74}},(function(_s,_t1,_t2) return function(u,t) local _c = (_t2 == "attack" and u or t) _c.c[_t2] += max(0,_total(s and u or t,_t1)) end end)(s,t1[1],t2[1]),decor[t2[1]] and decor[t2[1]][2][2] or {t2[2],4}}
				abilities["cnv_"..(s and "b" or "u")..t1[1].."_"..t2[1]] = {"glow",1,{"convert "..(s and "all " or "your").."   to",{t1[2],50},{t2[2],69}},(function(_s,_t1,_t2) return function(u,t) u[(_t2 == "health" and "c" or "p")][_t2] += max(0,u.p[_t1]) u.p[_t1] = 0 if _s then t[(_t2 == "health" and "c" or "p")][_t2] += max(0,t.p[_t1]) t.p[_t1] = 0 end end end)(s,t1[1],t2[1]),{snd=s and 16 or 11}}
			end
		end
	end
end
backgrounds = {
	title = {"0x0003.fff7,0x0207.f7e0,0x040b.efd9,0x0c1b.cf90,0x0e1f.c787,0x1023.bf7c,0x112b.bdd7,0x114f.bd96",{{"0x2229.7005,0x2432.6902,0x3032.6302,0x3f30.4602,0x4f32.6d02,0x5d32.6502,0x6b32.6e02","0x0301.0110,0x0106.0501,0x0b01.0101,0x0f0e.0d0c"},{"0x1e23.7005,0x2023.7005,0x2025.7005,0x1e25.7005,0x212e.6902,0x232e.6902,0x232c.6902,0x212c.6902,0x2f2e.6302,0x2d2e.6302,0x2d2c.6302,0x2f2c.6302,0x3d2c.4602,0x3b2c.4602,0x3b2a.4602,0x3d2a.4602,0x4e2e.6d02,0x4c2e.6d02,0x4c2c.6d02,0x4e2c.6d02,0x5c2e.6502,0x5a2e.6502,0x5a2c.6502,0x5c2c.6502,0x6a2e.6e02,0x682e.6e02,0x682c.6e02,0x6a2c.6e02","0x0300.0010,0x0006.0500,0x0b00.0000,0x0f0e.0d0c"},{"0x1f24.7005,0x222d.6902,0x2e2d.6302,0x4d2d.6d02,0x5b2d.6502,0x692d.6e02","0x0302.0110,0x0706.0504,0x0b0a.0908,0x0f0e.0d0c"},{"0x3c2b.4602","0x0300.0110,0x0706.0504,0x0b0a.0909,0x0f0e.0d0c"}}},
	city_sky = {"0x0003.fc88,0x0127.fdf2,0x0183.fff1,0x00cf.fbd9,0x00a7.fac9,0x0087.fa19",{{"0x5f01.dd04,0x6a08.dd03,0x6009.dd03,0x1205.dd03,0x0c0a.dd02,0x390f.dd02,0x3c10.dd02","0x0302.0110,0x0f06.0504,0x0b0a.0908,0x0f0e.0d0c"},{"0x0b3b.c801,0x143e.c601,0x183e.c601,0x3c39.b301,0x572e.7e01,0x5736.5901,0x6236.5901,0x6229.5901,0x6220.5901,0x6215.5401,0x213c.3c01,0x2539.3c01,0x213a.1301,0x412e.0201,0x4133.0201,0x4138.0201,0x413c.0201,0x413f.0201,0x2939.f702,0x5639.f702,0x4f38.f501,0x623d.ef01,0x2337.de01,0x033b.dd01,0x363a.db01,0x4c3d.da01,0x363d.d901,0x722e.da01,0x7236.d801,0x723a.d701,0x6512.d501,0x353d.d502,0x3a3e.cd01,0x463c.cd01,0x6d3b.cd01,0x753d.c601,0x7c3b.a901,0x6737.a801,0x673b.a801","0x0812.0810,0x0808.0808,0x1b0a.1908,0x0f0e.0808"}}},
	battle1 = {"0x0003.f9c1,0x017f.fff1,0x007b.fde0,0x0183.fe30,0x01b3.fea0,0x01db.ff60,0x005f.f9b0,0x0037.f8f0,0x0013.f840"}
}

city = {}
grey_palette = {0,0,0,5,0,0,5,6,5,6,6,5,5,0,5,6}
portraits = {
	none = {"","0x4040.0101","0x0302.0110,0x0716.0504,0x0b0a.0908,0x0f0e.0d0c",{0,0}},
	touchdown = {"touchdown","0x4036.ee05,0x402f.be04,0x4e3c.ba01,0x543c.ba01,0x333c.ba01,0x2c3c.ba01,0x3a33.4d02,0x4833.4d02,0x401c.4b02","0x030d.0110,0x0706.0c04,0x0b0a.0908,0x0f0c.0d0c",{10,34}},
	helpy = {"helpy","0x3f3c.3f06,0x3924.9001,0x4324.9001,0x3924.9901,0x4324.9901,0x3824.ac01,0x4323.ac01","0x0302.0710,0x0e16.150e,0x0b0e.0e00,0x0f0e.0d0c",{17,45}},
	chicken = {"cyber chicken","0x4540.e409,0x5829.e602,0x2e2b.cb04,0x282f.aa02,0x342f.aa02,0x2d21.e401,0x5262.1302,0x3759.1302","0x0302.0110,0x0706.0504,0x0b1a.0908,0x0908.0d0c",{35,46}},
	secretary = {"ms. terry","0x3e22.f606,0x4217.f404,0x2e32.f602,0x3832.f602,0x344e.1305,0x484e.1305,0x343d.2d06,0x483d.2d06,0x441d.2d02,0x441f.2d02,0x4013.4d01,0x4913.4d01,0x5032.9101,0x3f12.ad01,0x4812.ad01","0x0f12.0810,0x0704.0214,0x080a.0901,0x081e.0d07",{14,60}},
	flamingo = {"flaming-go","0x422c.5505,0x2a2d.4502,0x3f39.1203,0x3f45.1203,0x3f50.1203,0x3c27.5301,0x3f17.7702,0x451a.7702,0x4c1f.7702,0x4c41.b501,0x3340.b301","0x0302.1110,0x070e.0004,0x0b0a.0908,0x0f0e.080c",{25,42}},
	eastindia = {"east india company","0x403f.ee06,0x4839.0403,0x3939.0403,0x2d41.1a03,0x504b.1d02,0x4028.3002","0x0305.0010,0x0706.050c,0x0b0a.0907,0x0f0c.0d0c",{17,38}},
	hedgehog = {"fast hedgehog","0x403d.d305,0x4d30.d202,0x503d.d202,0x504b.d202,0x4359.d604,0x353a.c702,0x3259.d701,0x3e59.d701,0x313e.4a01,0x393e.4a01","0x0801.0110,0x0c0c.050c,0x0807.0708,0x0f0e.0d0c",{30,25}},
	castle = {"a castle","0x4035.1703,0x303d.1501,0x503d.1501,0x583d.1501,0x283d.1501,0x4326.1901","0x0302.0110,0x0706.0504,0x0b0a.0908,0x0f0e.0d0c",{16,44}},
	pincher = {"penny pincher","0x403f.b604,0x3e31.b805,0x3028.6301,0x5328.6301,0x5328.6301,0x3925.8d01,0x4325.8d01,0x4338.be01","0x0608.0710,0x0808.0208,0x0b08.0808,0x0f08.0108",{28,42}},
	softserve = {"soft serve","0x422b.a604,0x4c23.4102,0x414a.7f05,0x4146.7b03","0x0302.0810,0x0707.0204,0x0b0f.0708,0x000e.080c",{15,17}},
	engineer = {"trusted employee","0x3f29.e203,0x3f20.dd03,0x3f3d.ce02,0x3f3d.b702,0x3539.2d02,0x3236.0301","0x050a.0010,0x0a16.0504,0x0409.0a0a,0x0f0a.0d09",{13,40}},
	deserthorse = {"desert horse","0x5049.1703,0x5759.2703,0x3d51.1704,0x4769.2705,0x3165.2704,0x4945.5404,0x3a40.4e0c,0x2a35.5402,0x342a.3d02","0x0304.1110,0x0404.0214,0x0c0a.0908,0x0f0e.0d1c",{33,40}},
	bumbler = {"rogue bumbler","0x421f.de02,0x4029.e704,0x4031.3d04,0x4038.3b03,0x5020.de02,0x3b24.9c01,0x4324.9c01","0x0700.0110,0x0706.0504,0x0d0a.0900,0x0f00.0d0c",{20,46}},
	sirhute = {"sir hute","0x403d.0406,0x304c.5001,0x504c.5001,0x404c.5001,0x384c.5001,0x484c.5001,0x3c36.5301,0x4336.5301,0x3b31.8701,0x4330.8701","0x0302.0110,0x0706.000f,0x0b0e.0408,0x0f0e.0d0c",{24,30}},
	deadhands = {"deadhands","0x3a46.4204,0x3e32.4204,0x462e.4204,0x4647.4f02,0x442b.5301,0x4e2b.5301,0x4932.5401","0x0302.0110,0x0706.0004,0x0b04.0908,0x040e.0d0c",{8,38}},
	thesperado = {"thesperado","0x3c25.c804,0x3c3d.c604,0x3c4a.be02,0x364f.b501,0x444f.b501,0x3d28.b902,0x5034.8903,0x2834.8903","0x0305.0410,0x070e.150e,0x0b0a.1908,0x0f0c.1d00",{16,42}},
	nudeman = {"nude man","0x3f41.b004,0x3e1f.a603,0x3a31.a503,0x2c26.9a02","0x0002.0010,0x0706.0514,0x0f0f.0408,0x0f0e.0d0c",{16,38}},
	rudedolph = {"rude dolph","0x3829.0801,0x3826.1201,0x4134.1d02,0x4a27.2c02,0x3332.2d02,0x322a.ac01,0x453d.af01,0x3c3c.af01,0x312c.2e02","0x0400.0410,0x0404.0404,0x1b0a.0908,0x0f0e.070c",{29,40}},
	bobbybell = {"bobby bell","0x4454.d604,0x4038.d405,0x392e.9901,0x462e.9901,0x4123.9802","0x0302.0110,0x0709.0504,0x0b0c.0108,0x0f0e.0a0c",{15,44}},
	awfulthing = {"wretched hauler","0x3f37.4c04,0x2e31.9d01,0x5031.9d01,0x403f.b802,0x444a.af01,0x3a4a.af01,0x4021.dc02,0x2e2b.dd01,0x502b.dd01,0x5131.dd01,0x2d31.dd01","0x0300.1110,0x0909.0904,0x070a.091c,0x0f0f.0d0c",{32,30}},
	djinnius = {"djinnius","0x413a.de03,0x4725.b103,0x3b4d.e003,0x4718.0b02","0x0600.0710,0x0706.1504,0x1a0a.0908,0x0f0e.0d0c",{15,46}},
	geezer = {"geezer","0x3f2c.dd04,0x3924.dc04,0x4b24.dc04,0x303f.da01,0x383e.da01,0x3f40.da01,0x453e.da01,0x4c40.da01,0x3647.d302,0x4847.d302,0x3454.c602,0x4b54.c602","0x0302.1110,0x0706.0504,0x080a.0908,0x0f0e.0d0c",{24,30}},
	trotodile = {"trotodile","0x362f.fc03,0x2f2b.da02,0x3a29.da02,0x3739.d003,0x4939.d003,0x502f.e701,0x402e.ac01,0x2935.ac02,0x4e36.8801,0x4936.8801","0x0308.0010,0x0706.0014,0x0b0a.0908,0x0f0e.070c",{5,30}},
	firewyrm = {"fire wyrm","0x5536.5f01,0x573b.5f01,0x5243.5f02,0x4a48.5f02,0x3e43.5f03,0x3f36.5f03,0x3529.5f04,0x3037.1c01,0x3837.1c01,0x2f29.e901,0x3929.e901","0x0312.1110,0x0a16.1507,0x0b09.0702,0x0f08.0d0c",{30,40}},
	treehider = {"tree hider","0x3e37.c003,0x3c3a.af01,0x3631.9d01,0x4531.9d01,0x3c4a.8003,0x3730.2e01,0x4630.2e01","0x0315.0110,0x0706.0504,0x0b0a.0908,0x0f12.0d0c",{23,28}},
	shiftly = {"shiftly","0x2745.d703,0x5141.d803,0x5f35.d702,0x1855.d802,0x3e31.8104,0x3125.5602,0x4925.5602,0x3426.5501,0x4d26.5501","0x0312.0110,0x0700.0114,0x0b0a.0908,0x0f0e.000c",{32,45}},
	failure = {"abject failure","0x403a.bd08,0x3124.5f01,0x4129.5f01,0x3631.aa01,0x433d.aa01,0x3e43.aa01,0x3055.e602,0x4959.e602","0x0302.0110,0x0006.0501,0x0b0a.0d08,0x0f0e.0d0c",{21,40}},
	hammurabi = {"hammurabi","0x4032.f405,0x402f.f404,0x402c.f403,0x402a.f402,0x4029.f401,0x3829.2802,0x4829.2902,0x3a36.5601,0x4636.5601,0x4041.5702","0x0912.0610,0x0016.0504,0x050a.0908,0x1f02.0d0c",{24,30}},
	harmy = {"harmy","0x403d.210a,0x4117.fb03,0x4005.dd03,0x4508.b301,0x3b0b.b501,0x3a13.9001,0x4811.9002,0x3b12.5501,0x4a16.5501","0x0702.0110,0x0800.0808,0x0708.0808,0x0f0e.1d0c",{22,65}},
	shipping = {"shipping forecast","0x3f0e.dd07,0x3420.dd03,0x481e.dd04,0x4234.7c02,0x343e.7c01,0x3624.a002","0x0306.0010,0x0705.1504,0x0b0a.0906,0x0f0e.0d0c",{27,48}},
	mystery = {"shambling pile","0x3a3f.aa04,0x4a3f.aa04,0x3f2f.8f04,0x3f2b.cd04,0x3250.c602,0x4d50.c602,0x382a.aa01,0x452a.aa01","0x0302.0810,0x0702.150e,0x0b0a.0208,0x0f0e.1d08",{18,38}},
	dirigibert = {"dirigibert","0x3f1f.5704,0x3f33.8402,0x3f3b.b803,0x3820.3d03,0x4620.3d03,0x3f42.5c01,0x443c.9c01,0x3f3c.9c01","0x0c04.0010,0x0c10.1514,0x0c0a.0607,0x0f0e.0007",{18,26}},
	manglerfish = {"mangler fish","0x3824.b301,0x3827.b301,0x392a.b301,0x382e.b301,0x3932.b301,0x3c24.8101,0x3e30.d405,0x3d18.f302,0x3a0f.fb01,0x5332.4202,0x3c42.d201,0x4342.d201","0x0812.0110,0x1707.0505,0x0803.0308,0x1f1e.050c",{23,44}},
	foultaint = {"foul taint","0x4158.1305,0x4639.2f04,0x3d33.2102,0x4f33.2102,0x3a47.4303,0x3b36.4d01,0x4c36.4d01,0x5447.5101,0x453e.5402","0x0802.0110,0x0706.0214,0x0206.0708,0x0f0e.0d0c",{8,28}},
	embarker = {"embarker","0x3339.fd03,0x3c39.fd03,0x4539.fd03,0x3c29.f404,0x473e.2101,0x313e.2101,0x383e.2101,0x403e.2101,0x3c25.a302","0x0302.1210,0x0809.020d,0x0b0a.0c08,0x0606.0d0c",{20,48}},
	bugknight = {"bug knight","0x333f.1603,0x372e.1603,0x3023.1e02,0x3b23.1e02,0x3b26.2e01,0x3026.2e01,0x3535.5602,0x2435.1a02,0x463c.1d02,0x2a46.f402,0x3d46.f402","0x0202.0310,0x000b.0200,0x0806.1908,0x030e.030b",{27,39}},
	landlard = {"land lard","0x403a.0504,0x4231.0503,0x3634.5301,0x3b2d.5301,0x354b.8503,0x4a4b.8503,0x513c.2f01,0x4c3d.2f01,0x2d3c.2f01","0x0302.0110,0x0707.0102,0x0b0a.0d08,0x0f0e.0d0c",{24,35}}
}
effects = {
	none = {0,function() end},
	wipe_in = {60,function(self,_t) rectfill(128 - _t*4.27,0, 128, 128, 0) end},
	wipe_out = {60,function(self,_t) rectfill(-1, 0, 128 - _t*4.27, 128, 0) end},
	caption = {150,function(self,_t) f_p(self._args[1], 64-2*#self._args[1], 120-max(_t, 60), self._args[2]) end},
	slam = {40,function(self,_t)
		local _dx = (self._x[2] > self._x[1]) and 1 or -1
		bgd(self._x[2]+((_t<38) and 0 or -15*_dx)-((_t<30) and 5*_dx or 0),50+self._y,self._args[1],self._args[2],_dx<0)
	end,5},
	burst = {21,function(self,_t)
		bgd(self._x[2],50+self._y,self._args[1],7-2*_t\7)
	end,21},
	rise = {40,function(self,_t)
		bgd(self._x[1],self._y+_t/2+50,self._args[1],self._args[2])
	end,13},
	bubble = {40,function(self,_t)
		for t in all({40,30,20}) do
			if (_t <= t) bgd(self._x[2]+t/2-15,self._y-t*1.5+_t/2+90,self._args[1],2)
		end
	end,13},
	multi = {24,function(self,_t)
		for t in all({24,16,8}) do
			if (_t <= t) bgd(self._x[2]+12-t,self._y+20+t*2,self._args[1],self._args[2])
		end
	end,19},
	sml_beam = {40, function(self)
		rectfill(0, self._y+62, 127, self._y+64, 12)
		line(0, self._y+63, 127, self._y+63, 7)
	end, 7},
	med_beam = {60, function(self,_t,e)
		if (_t == 60) add(e, effect:new("particle", 0, 0, self._y + 58, {128, 12, 12}))
		local _dx = (self._x[2] > self._x[1]) and 12 or -12
		local _sp = 64 - 65*_dx/12
		for p in all({{5,1},{4,12},{2,7}}) do
			rectfill(_sp+_dx*(60-_t),self._y + 64-p[1]-rnd(2),_sp-40*_dx+_dx*(60-_t),self._y + 64+p[1]+rnd(2),p[2])
		end
	end, 9},
	lrg_beam = {80, function(self,_t,e)
		if (_t == 72) add(e, effect:new("particle", 0, 0, self._y + 40, {128, 48, 12}))
		local _dx = (self._x[2] > self._x[1]) and 14 or -14
		local _sp = 64 - 65*_dx/14
		for p in all({{65,0,1},{62,-3,12},{58,-10,7}}) do
			local _y = mid(0, p[1] - _t, 20+p[2])
			rectfill(_sp+_dx*(80-_t),self._y+64-_y,_sp-48*_dx+_dx*(80-_t),self._y+64+_y,p[3])
		end
	end, 22},
	glow = {0, function(self,_t,e)
		for i = 7,15 do
			add(e, effect:new("particle",0,0,32,{128,48,i}))
		end
	end},
	particle = {60, function(self,_t)
		for i = 1, _t/2 do
			pset(self._x+rnd(self._args[1]),self._y+rnd(self._args[2]),self._args[3])
		end
	end}
}
commands = {
	slide = function(s, r) r[1]:slide(r[2]) end,
	update_health = function(s, r)
		s._goodies.a.health = r[1]
		s._baddies.a.health = r[2]
	end,
	update_status = function(s, r)	s[r[1]].a[r[2]] = r[3] end}


-->8
function n(r,s)
	setmetatable(r,s)
	s.__index = s
end

function save_clear()
	sfx"4"
	memset(0x5e00,0,255)
	player:load()
end

function _split_values()
	for param in all({
	{backgrounds, 1},
	{city, 1},
	{city, 2},
	{portraits, 2},
	{portraits, 3}
	}) do
		for k,v in pairs(param[1]) do
				v[param[2]] = split(v[param[2]])
			if param[1] == backgrounds then
				for l in all(v[2]) do
					l[1] = split(l[1])
					l[2] = split(l[2])
				end
			end
		end
	end
	local i = 0
	local f = 0
	while i < 1280 do
		local _hp = @(0x2700+i)
		if _hp == 0 then
			i = 1280
		else
			f += 1
			local _sl = @(0x2701+i)
			local _k = cnc(0x2702+i,_sl)
			local _o = _sl
			_sl = @(0x2702+i+_o)
			local _a = cnc(0x2703+i+_o,_sl)
			_o += _sl
			_sl = @(0x2703+i+_o)
			local _p = cnc(0x2704+i+_o,_sl)
			_o += _sl
			local _f = {_hp, _a, _p, f}
			fighters[_k] = _f
			fmap[f] = _k
			i += _o + 4
		end
	end
	for i=0,245,7 do
		local _team = {}
		for j=0,4 do
			local _v = @(0x2002+i+j)
			if (_v > 0) add(_team, fmap[_v])
		end
		add(battles, {_team,@(0x2000+i),@(0x2001+i)})
	end
	i = 0
	while i < 1536 do
		local _l = @(0x2100+i)
		if _l == 0 then
			i = 1536
		else
			local _sl = @(0x210c+i)
			local _s = cnc(0x210d+i,_sl)
			_sl += i+13
			local _p = {}
			for f=0,@(0x2100+_sl)-1 do
				add(_p,{@(0x2101+_sl+f*2),@(0x2101+_sl+f*2+1)})
			end
			local _e = {
				_s,
				(@(0x2101+i) > 33) and "?" or "!",
				@(0x2102+i),
				slotmap[@(0x2103+i)],
				$(0x2104+i),
				$(0x2108+i),
				_p
			}
			add(encounters,_e)
			i += _l
		end
	end
	i = 0
	while i < 1024 do
		local _l = @(0x2c00+i)
		if _l == 0 then
			i = 1024
		else
			local _p = {}
			for p=0,3 do
				add(_p, $(0x2c06+i+p*4))
			end
			local _s = {}
			for s=0,_l-1 do
				add(_s, $(0x2c16+i+s*4))
			end			
			local _c = {_s, _p}
			city[cnc(0x2c01+i,5)] = _c
			i += _l*4 + 22
		end
	end
end

function cnc(a,w)
	local _s = ""
	for c=0,w-1 do
		_s ..= chr(@(a+c))
	end
	return _s
end
__gfx__
00000000606660667507056060666066009999000000000016666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
00000000000000005656565000000000094444900e82e8206d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
0000000066606660057775006033330694444449e788888262444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
00000000000000007677666000333300999aa999e888888264222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
00000000066606660576650060333306955aa5590888882064442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
00000000000000005656565000331300954444490088820064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
00000000660666067506056060331306954444490008200064424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0000000000000000000000000033330099999999000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550777777767776777600dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676076666665766576650dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007607667766576657665dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676076766565655565550555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007607676656576777677066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000766556656576657606dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766666656576657606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000655555555565556506dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0000000000044000044044000440440000044000044004407777777600044000000444000044400000000000000000000000000000000000000000000076dc00
000000000009900009909900099099000099999009900990766666650009900000990000000099000990099000099000000000000000000000000000075555d0
00000000000aa0000aa0aa00aaaaaaa00aa000000000aa0076666665000aa00000aa00000000aa0000aaaa00000aa00000000000000000000000000001c6dc10
00000000000770000000000007707700007777000007700076666665000000000077000000007700077777700777777000000000077777700000000007cc6d50
00000000000aa00000000000aaaaaaa000000aa000aa0000766666650000000000aa00000000aa0000aaaa00000aa00000000000000000000000000007cc6d50
00000000000000000000000009909900099999000990099076666665000000000099000000009900099009900009900000099000000000000099000007cc6d50
00000000000440000000000004404400000440000440044076666665000000000004440000444000000000000000000000440000000000000044000007cc6d50
0000000000000000000000000000000000000000000000006555555500000000000000000000000000000000000000000000000000000000000000000066d500
00444400004440000044440000444400044004400444444000444400044444400044440000444400000000000000000077777776000000007777777600444400
09900990000990000990099009900990099009900990099009900990000009900990099009900990000000000000000076666665000000007766665509900990
0aa00aa0000aa00000000aa000000aa00aa00aa00aa000000aa0000000000aa00aa00aa00aa00aa0000aa000000aa000765555650aaaaaa07676656500000aa0
07700770000770000077770000077700077777700777770007777700000077000077770000777770000000000000000076566765000000007667566500077700
0aa00aa0000aa0000aa0000000000aa000000aa000000aa00aa00aa0000aa0000aa00aa000000aa0000aa000000aa000765667650aaaaaa076675665000aa000
09900990000990000990099009900990000009900990099009900990000990000990099009900990000000000009900076577765000000007676656500000000
00444400004444000444444000444400000004400044440000444400000440000044440000444400000000000044000076666665000000007766665500044000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065555555000000006555555500000000
00444400000005d9007a42000000000000000009000099990011108a00000000000000000049400000040000a7a9999900076000000000000001000000000000
0990099000555d5507a9942000000000000909aa009999aa011102000009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
0aaaaaa005d6d5550a999940000000000000aaaa09a9aaaa11711011008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
077a07705d7ddd500a99994000000009090a9a9a099a99091111111200a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0aaaaa0056dddd500a9999400000a09a00a9a9a999a997901111111209a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0990000055ddd5500ae999400000099a09aa9a7799a9700011111112008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
004444000555550007fe9420000099a70aa9a7779aa090000211112000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000002222000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
0017c100004444000444440000444400044444000444444004444440004444000440044000444400000044400440044004400000040000400400044000444400
0177cc10099009900990099009900990099009900990000009900000099009900990099000099000000009900990099009900000099009900990099009900990
1777ccc10aa00aa00aa00aa00aa000000aa00aa00aa000000aa000000aa000000aa00aa0000aa00000000aa00aa0aa000aa000000aaaaaa00aaa0aa00aa00aa0
7777cccc077777700777770007700000077007700777700007777000077077700777777000077000000007700777700007700000077777700777777007700770
1ccc11110aa00aa00aa00aa00aa000000aa00aa00aa000000aa000000aa00aa00aa00aa0000aa00000000aa00aa0aa000aa000000aa00aa00aa0aaa00aa00aa0
01cc1110099009900990099009900990099009900990000009900000099009900990099000099000099009900990099009900990099009900990099009900990
001c1100044004400444440000444400044444000444444004400000004444400440044000444400004444000440044004444440044004400440004000444400
00011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044444000044440004444400004444000444444004400440044004400440044004400440044004400444444009aaaa90000049aa00a7777d0007700000077000
09900990099009900990099009900990000990000990099009900990099009900990099009900990000009909a1aa1a900049aa90a6666dd0076670000700700
0aa00aa00aa00aa00aa00aa00aa00000000aa0000aa00aa00aa00aa00aa00aa000aaaa000aa00aa00000aa009a5aa5a9049aaaa4a7777d5d0766667007000070
07777700077007700777770000777700000770000770077007700770077777700007700000777700000770009aaaaaa949aaaa4076666d5d7666666770000007
0aa000000aa00aa00aa00aa000000aa0000aa0000aa00aa00aa00aa00aaaaaa000aaaa00000aa00000aa000009affa90049aaaa976666d5d0005500000077000
09900000099009900990099009900990000990000990099000999900099009900990099000099000099000009a9aa9a949aaa99476666d5d0006600000700700
0440000000444400044004400044440000044000004444000004400004000040044004400004400004444440a900009a9aaa944076666dd00006600007000070
00000000000004400000000000000000000000000000000000000000000000000000000000000000000000009a9009a9aa9940006ddddd000006600070000007
0bb3b3b030bbb003015005100150051094000049999999999400004900009999000000000007d000007665000076650000aaaa000007000000dddd0000dddd00
bb3b3b350bbb33001575565115755151945444494444444444444444000944440000000000766d0007500650075006500a999940000e00000d7cc7d00d7cc7d0
b3b33333bb3bbb3057576515575765159455554905500550045555500094400000000000076666d00650065006500000a979979400e88000d70cc07dd77cc77d
b3333335b3b3b33505766650057656509400004904500450045004500944000000000000000440007666666576666665a71991740e111800d77cc77dd70cc07d
0b4334503bbb3b350566665005656550940000490450045004500450994540000007d000000940007661666576636665a9999994e8191880dccccccddccccccd
0009450033b3b35557566515551655159454444904500450045444509440540000766d00000940007661666576636665a992299408111820dcc11ccddcc11ccd
0009450003335550156551511155515194555549444444444455554494000544076666d0000940007666666576666665b30880d5008882000dccccd00dceecd0
095454540033350301500510015005109400004999999999940000499400004900044000000940006555555565555555ff0ee0660008200000dddd0000dddd00
000990000777770000077000d777777dd55550000554455000007000067666500007000000777700056650000000000000666000000770000076660000766600
049aa9407566666000766700566666657665d650554444550000770000565100007a9000071111605600650007a00a7006000600007755000702826007282060
49a99a940065d56000077000566666657661656045444454000076700067650007aaa90071111115607006000a9009a060700060077665500602825006282050
9a9aa9a9006666600766667011111155766176d0455a9554000077770067650007aaa90071100115600006000000000060000060775555550066550000665500
9a9aa9a900655d607655556776d176d576611100411a911407007000006765000a99990071100115560065000000000060000060775e275507d75d6007d75d60
49a99a940066666065000056656165607661d6504445544476666667006765007556559071111115056694500a90000006000600775227557d7dd5d67d7dd5d6
049aa9400067777756500565d650d650766165604444444407666670006765000aaaa900061111500000094507a0000000666000777776557d7dd5d57d7dd5d5
00499400005555500567765000000000d55176d05444444500777700067666500000000000555500000000940000000000000000055555500665565006655650
0022220050222205bb0bb0bb0b0bb0b00000bbb00000000000099000000880009999999900000000002820000077770000000000000000000000020000077000
552882550528825003abba30b3abba3b000b1b1ba000bbb0000079000000a8009004040500000000028e8200076566d000000000000080000000220000766500
22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a999000898880944444450000000008e7e8007665666d00088800000000000022212000766500
271881722708807203baab3003baab30b00b3707b00bbbbb0979a99908a89888900040050000000008eee8007665556d00888880000888000022122000766500
2888888228888882b003300b00033000b00bbb00b00b370799a99979889888a89444444502028200028e82007666666d00888880080888080221122000766500
28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa99888a9988955555550021111000282000076666d000888880000888002111221200766500
028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a9900888988000055000011dddd00028200000dddd0000088800000000002111111207666650
99222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a9900008988000506400566666666002820000000000000000000000080000111111006555550
004aa4000077770000777700000000076776d77650000000000000000000000000000000c0c6cc007777777711111100566666660015d0005666666500000000
44a77a4407666670000666700000007676675665650000000301000022000022000000000cccccc07555555717777610655115510015d0006666666600000000
aa7777aa71166117a0776657000007667667566566500000030133000220022020020202cdd7d7d0756556571777610065155551001d50006000000601111110
4aa77aa4712662177a66666600007666766756656665000000313830002202002008280206ddddd0755555571776610051155551000d15006000000605555550
04a77a40066116606d6666660007666676675665666650000033133000082800022222200d665ddd7555555717667610655115110001d5006000000605555550
4a7aa7a405666650d056611500766666766756656666650003313013000222000022220000c5ccc07565565716116761655551510001d0006000000605155150
4aa44aa40061160000066650076666667667566566666650111000000000000000000000005c00c075555557010016716555515100105d006000000605111150
aa4004aa0056650000665000766666666552155666666665100000000000000000000000050c00c077777777000001105111111500150d000000000005111150
b3b00b3b0bbbbbb00040000000000900aaaaaaaaaaaaaaaa994499444444444499999999555555555555555566666666666d6666dd5555ddcccccccc00088000
b039930bbbb33bbb4090004000009a90aaa999aaaaaa99aa944494444444444499444499555d55ddd55dd55d6d6666d66dd666d6d566665dcccccccc00800800
00999200b33bb33b90a0409000000900aaaaaa9aaaaaaa9a444444444444444444444444dddddddddddddddd6666666666dd6d6656666665cccccccc08099080
00944200b393323ba00090a400e00b00aa9aaa9a99aaaaaa1414141499449944991111995d55d555dd555d55666666666d66666656666665cccccccc80900908
00999200009992000405a0090eae0300a9aaa9aaaa9aaaaa414141419444944494111149dddddddddddddddd6666666666666dd656666665cccccccc80900908
09999920044499200905004a00e00300a9aaaaaaaaaaa9aa11111111444444449911119955dd5d55d555d55d666666666666d6665d6666d5cccccccc08099080
04449920099999200a50009000b00300aa99aaaaaa999aaa000000004444444444111144dddddddddddddddd6d6666d66dd666ddd5dddd5d1cc11cc100800800
0299922002999220dd1110a000300300aaaaaaaaaaaaaaaa000000004444444499111199555555555555555566666666d666666ddd5555dd1111111100088000
00000000002222200777000000044000000aa000007000000777700000bbbbbbbbbbbbbbbbbbbb002222222222222222000000000000000000000bbb55677655
2222222202944442067770000049940000a7aa0000700000070070000b333b333b333b3333b333b042244224422442240000000000000000000b3b3b56555565
44444444029999420677770000444200007aa90000700000070070000b34333433343334433343b04444444444444444000000000000000000bbb3bb56677665
44444444022222220677777000494200007aa9007770000077077000b3444444444444444444443b44444444444444220b00000000000000003b3b3056677665
222222220294949206777700004992000a7aaa907770000077077000b3344444444444444444433b4444444444444422b0b0bb00000000000bb3bbb055677655
222222220294949206777000004942000aaa99900000000000000000bb34444444444444444443bb444444444222444400b0b0b0000000000b3b3b0056555565
2442442402949492066600000049920000666d000000000000000000b3344224422442244224433b4224422442224224000b0000077707703bbb000056677665
22422424002222200000000000042200000000000000000000000000b3222222222222222222223b2222222222222222000b0000777777773300000056677665
00aaa900000ee0000000000000800000008000000000000000000000008008000000000000808000000000000fffff000fffff000fffff00002ee20055555555
00666d000eeaaee0000ee0000877000008770000008000000007000000088000000000000008800000000800f44444f0f44444f0f44444f00222222056677665
067176d00eeaaee00eeaaee0a7170007a7170f0708770007000770700088e800080880800088e80008088000f4fff4f0f4fff4f0f4fff4f0047ff74055555555
6771766db0beeb0b0eeaaee0087777770877ff77a71777770004007708888e800088e80008888e800088e800f4f4f4f0f4f4f4f0f4f4f4f0471ff17457777775
6771116db3bbbb3b0bbeebb0077fff77077fff77087fff77009994400818818008888e800818888008888e80f4f444f0f4f444f0f4f444f00ffffff075555557
6777766d3bb1b1bb33bb1b1b077ff7700777f770077ff7700949994002888e8001888e100288888001888e80f4ff22f0f4ff1e10f4fff1e10022220055677655
067766d03bbbbbbb33bbbbbb0077770000a7770000777a00099494400288888002888880022288800222888044422220444feee0444feeee00eeee0056776665
00666d000333333003333330000a0a0000000a00000a000009944400002228000022280000222200002222000422220004eeeee004eeeeee0040040056677665
0002ee20002ee200007aaa00000a00000000000000000000000000000000000000331000000310000003100000000000bdddddd0002222000000000056776665
00222222022222200a999aa0000790000000000000000000000000000000000000311100000310000003100003303300d1d1d1d0022222200022220056677665
0447ff74047ff7600a9aaa90000a900000000000050055000000110000000000b30111000b333333333333303b333330d5d5d5d0044444400222222055776655
0471ff17471ff1640a9aaaa000099000000000000500050000313000076cccc030013100011111111111111033333330d5d5d5d14f4444f40444444075555557
00ffffff0ffffd6d0a9aaa90000a9000002ee200057dd50003b33300cccc111100031011011111111111111033333330ddd3d3310ffffff04f4444f457777775
00222200002222d00a9aaa9000099000022222200d515d0003333300111155510033100100031000000310000333330015555511002222000ffffff055555555
00eee40000eeee4009aaaa9000099000011ff1100d5155000333330015555511003330000003100000031000003330001515151100eeee0000eeee0056677665
004000000040040000999900000090004ffffff40d55550000333000011111100013300000031000000310000003000011111111004004000040040055555555
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0114020000000002140b0000000003140c08000000031408060000000314070a060000041409070a0000051405090d0c00051c0400000000021422200000000314242523000004142120250000051c241f21000002140f100000000314111412000004141113100000051c0e12000000032b1e00000000031418161700000314
1c1d1b000003141a1900000005331e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a3f02020000900000004a00087475746f7269616c0201020104183f03020000900000004a00087475746f7269616c0101032c2101020000900000004a001a6c65742773207468726f7720646f776e2c20706172746e6572210203020404323f05030000de00000050001a61206865726f2077616c6b7320696e746f20612062
61722e2e2e05020201050111011d0303223f06050000c10100004600126120666f6f7420696e2074686520646f6f72010106232102050000c101000046000d6c756e6368206d656574696e6704050709060807070b223f08050000c1010000460012616e2061726d20696e2074686520646f6f72010108192104050000c10100
003c0007666c6f6f72203002050909081c2103050000c1010000320008666c6f6f7220313303050a050f09091a2105050000c1010000280008666c6f6f7220343202050b090a1c2106050000c10100001e0008666c6f6f7220363903050c0510090b1b2107050000c1010000140009666c6f6f722031303102050d090c283f09
050000c10100000d0018612077686f6c6520626f647920696e2074686520646f6f7201010e282108050000c10100000d000a646f776e73697a696e6708080a090e070507070709070a070c070d1b3f0b030000d90000003c000b6865616468756e74696e670103081b3f0c030000e20000002c000b636f6c64207475726b6579
010306233f0d010000310000004e0013686172626f7572696e672061206772756467650101121e3f0e040000140100003f000c6120647279206d7574696e790201130118262109010000310000004e0012736964652077697468207369722068757465030514021809132c3f0f010000310000004e0016612066726569676874
20746f2074686520646561746804011503100311031223210b0100001500000025001177616c6b696e672074686520706c616e6b020516091522210a010000150000002500106861756c696e6720746865206b65656c020517091628210c0100001500000025000e68656176696e672074686520686f0608170917070e070f07
1307142f210d040000140100003f001b736964652077697468207368697070696e6720666f72656361737403051902130918253f10040000140100003f000f676f696e67206f766572626f61726404011a03200321032322210e040000680100003900106c612064616e7365206d61636162726502051b091a25210f04000068
0100003900137265766f6c7574696f6e61727920657475646502051c091b2b211004000068010000390011676f65747465726461656d6d6572756e67060818091c071f072207240725243f12020000ad0000004c0014697427732061206b696e64206f66206d6167696301011e242111020000900000004a000e7370656c6c69
6e67206572726f7204051f09200813071e1c3f16020000ad0000004c000e636c6f7365207570206d6167696300233f14030000d90000003c001173756d6d6f6e696e6720636f75726167650201210315242114030000e20000002c000e6b696e6720696e2079656c6c6f7704052209210719071a222112030000e20000002c00
0a626c61636b206a61636b0505230922071607170718272113030000e20000002c000f7468696e2077686974652064756b650505240923071b071c071d283f15020000ad0000004c0018616e6420666f72206d79206e65787420747269636b2e2e2e010125262115020000900000004a0014796f7520616e6420776861742c20
6861726d793f02051f0925263f11030000de000000500016627265616b66617374206f66206368616d70696f6e73010d0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0309746f756368646f776e136174745f75646566656e63655f61747461636b0c6275665f646566656e636531020568656c7079096163635f666f6f6432046e6f6e6503086c616e646c61726410636e765f62666f6f645f6865616c746808696d6d5f666972650707636869636b656e0b6163635f6865616c7468330c6275665f
646566656e6365330209736563726574617279086174745f6963653308696d6d5f666972650308666c616d696e676f106174745f74666972655f61747461636b0b6275665f61747461636b31020965617374696e646961096174745f636f696e3208696d6d5f626f6c7402086865646765686f67096174745f66697265320769
6d6d5f6963650206636173746c650c6163635f646566656e6365320c6566665f61747461636b2d31020770696e636865720e6174745f74636f696e5f666972650c6275665f646566656e6365310308656e67696e656572096174745f626f6c743108696d6d5f626f6c74020b646573657274686f7273650b6174745f706f6973
6f6e310c6275665f646566656e636531020762756d626c65720b6174745f706f69736f6e320a696d6d5f706f69736f6e060773697268757465096174745f626f6c74350b6275665f706f69736f6e3102096465616468616e64730b6174745f61747461636b310c6566665f646566656e636531020a7468657370657261646f0b
6174745f61747461636b320d6275665f646566656e63652d3102096275676b6e696768740b6163635f706f69736f6e320a696d6d5f706f69736f6e010972756465646f6c706812636e765f62706f69736f6e5f6865616c74680a696d6d5f706f69736f6e0309626f62627962656c6c12636e765f75706f69736f6e5f61747461
636b0c6275665f646566656e636531040a617766756c7468696e670f6174745f75706f69736f6e5f6963650a696d6d5f706f69736f6e0208646a696e6e6975730b6163635f6865616c7468310c6566665f61747461636b2d3103066765657a6572096163635f666972653308696d6d5f66697265020974726f746f64696c6510
636e765f75666972655f6865616c74680c6275665f646566656e6365310508666972657779726d096174745f666972653308696d6d5f666972650409747265656869646572116174745f74646566656e63655f626f6c740a696d6d5f706f69736f6e040773686966746c790b6174745f706f69736f6e320d6566665f64656665
6e63652d310209736f66747365727665086174745f6963653307696d6d5f69636504076661696c757265086174745f696365310c6566665f646566656e636531030968616d6d7572616269136174745f74646566656e63655f61747461636b0b6275665f61747461636b3109056861726d79126174745f756865616c74685f61
747461636b0a696d6d5f61747461636b05087368697070696e67086174745f6963653508696d6d5f626f6c7402076d797374657279126174745f7461747461636b5f61747461636b08696d6d5f66697265010a64697269676962657274096163635f66697265310b6566665f61747461636b31020b6d616e676c657266697368
0f6174745f746865616c74685f69636507696d6d5f6963650109666f756c7461696e740b6174745f706f69736f6e32046e6f6e650308656d6261726b65720c6163635f646566656e6365310c6275665f646566656e63653102076e7564656d616e136174745f75646566656e63655f61747461636b046e6f6e65000000000000
1f726967687410020202080808080808020202080e0f0210427f0210337f0210267f0110346b01103c6b0110446b03105163011c4b74011d4e3c011d533c02104d2f011046300110465801103f580110305c0110375c01103f5c0110465c0114490301124540021047100126441a01294e3d014c476301944a0201d33f2e0101
440d0202484e013a1f7a013a2d5e017d4b2223686f74656c101101130101010f0801011b0c010f0f040660610406406101585d710158557101584d710158457101583d71015b3d4f015b4b4f015b5c4f02be316302be2f63022a3a650229485b02284865022a595e02295966022a6b6402da607701f3567c02fc623f02045934
0204592d01585336013d5a2504955f1301ae4e1a01ae4e1301ae4e0c01bd512b01bd4e2b01bd4b2b01df613601df613201df612c246372616e65100112131401160101190f0f010f010f013e601d013e591d013e521d013e4b1d013e441d013e3d1d013e361d013e2b1d01a8241d01c6302101c6302901c6303101c6303902c8
2d1901c630150104251d05bf5f0f02bf520702bf5d2102bf593502bf4d1401f35a3a01f34e1901f3530c01f3631d02d2614203836657025b5b770126527502f75c6701ef596901ef546901cb6b5301cb6b5e01cb6b6902c8587f196c656674791002020214020208081908021c020e0f01c8403d01c83b3d01c8363d01c83646
01c83b4601c8404601cb453d01cb454603cb504404ac4c0701584c340158543401ce3c2101ce3c2902d3412401fc481a01025312022a4b5a04305066015c526e01b3467501b3457d01c04b6601d75560015847642d746f77657210010101010101010f190f0f0f1d1e0103ee214502ee194502ee2d4502eb364602eb414602eb
4e4602eb5a460197394b01975b3f01fc515002ff5c4c01135f7f01135f6e01135f5d015b5855015c585d015c5865015c586d015c5875015c587d01a9526401a9527801fc12460122384301225a4801231d4901241d4501252b4701274248012742460127424201286243012c1b3a012c1b52043c5600033c601b024c5d27014f
441001615d2101615d1e01615d13018752150187522001cd3f0504d5530b1a736c756d73100112130101010118011a1b011d0f1f02da411b04d9481b06d8542303ce664704ce5e6702ce466b01b6483901b54a2601ae564c01a93a6901844a5d018152760180391d015b5e08015b5808015b52080206533601fe406c01fe486c
01fe4a6801fe506f01fe506a01fe481801fe501b01fe521e01fe522300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010200000000021565265750050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010a1f200c4520c4510c4410c4310c4210c4110c4110c4100c4100c4100c4100c4100c4120c4120c4120c4120c4120c4210c4310c4410c4510c4610c4710c4020c4020c4020c4020c4020c4020c4020c4020c402
00010000190711c0611f05122041280051f000220002200021000220001f0001f000220002200021000220001f0001f0002e0012e0002d0002e0002b0002b0002b0022b005000000000000000000000000000000
000200002e5702e5703557035570166003a5703a57037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000800002a770267702a7700070032770377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c00000c37300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000600001c37311000103431032310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002d27321363164530c3430733303323013130d50309503075031550300003000030000300003000031d303123031b0030000300003000030000300003153030b3031a7031f5031b003217031d50322003
000300000865111651206003367032671306712a671226711a671136610d661086610465101651006310063500000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001237311373103730f3730e3730e3730d3730d3630c3630c3630b3630b3630a3630a363093530935308353083530735307353063530634305343053430434304343033430334302333023330133301333
000100002b54329563265732557323571215711f5711c5711957118571165711457113561105610d5510b54108541075410553103531025310153102400023000130003400024000140001400024000240001400
000300001b3701b2701c1711d1611f161211512315127141371413b1301b3501b2501c1511d1511f151211512314127141371313b1301b3301b2301c1311d1311f131211312313127131371313b1300000000000
000200000b3540d361103711c371233712637127371293712c3612e35500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000500000b07012741127350c07013741137350d07014741147350f0701674116735182001840018300185021800512200122050a2000a4000a3000a0050a70500000000000d0001400014005000000000000000
00070000187751a5751c7751556517765195651275514555167550f54511745135450c7350e535107350060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500001b5711e07125071010001a0611d0612406100000197511c7512375100700187401b741227410050000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000019170201701c170231702315519150201501c150231502314519140201401c140231402313519130201301c1302313023135001000010000100001000010000100001000010000100001000010000100
000900001d3751d7651d3551377513365137550070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000900000c373236750936520651063611b6510435116641023510f641013410a6410364104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
001000001c1731c1631c1531c1431b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000000373016732b3730167300473233731c26301663053631a26301663016530d253024531e3530164300343054431c2430163325333016330033325423016230162309323016231d313016131021300413
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000500003f673232633a67121261346711e2612f671172612a66112251246610d2511e66109251186610525111651032410c65101241086550124504655002450264500645006000060500600006000060000600
011400002742018716217161871627420187162171627420295150040026425264252442526425247162042000400000001d420004002771618716217161871627700187162d5151870024615187162d51518700
011400000c03305310295150c310306150331005310295050c033053101d21505310306151d215000000c03305320000001b41005310306150000003310053200c03300310335150c033033100f3200431010320
011400002e4202a71627716247162051524716304202c420000000b2100c2100d2100f2101e410204101e410314202d7162a716277162351527716334202f4202f7162b51528716257162b5152b5152b5152b515
011400000c033083102051506320306150c03306310083200c0330b31000310013100331006310083100b9400c033099300b9300c033306150b320235150c0330993019515079300c03330615129300793013930
0114000027400187002171618716270001800021716187162740018700217161801627000184152171618716274001870021016187161831518415217161801627400187002151624506275162d3152171118016
0114000020724200251c7241c0251972419525157243951520724200251c7241c0251952219025147241502121724210251c7241c0161972419025237241702521724395151c7241c02519724195251772717025
011400000c033090452071409035246151971315545090450c043090551971309555207142461509055155550c043060552071406055246151671306055125550c04306055167130655520714246150605515545
011400000c043021551e7140205524615197350e7550c04302155020551e7241e7250255524615020550e55501155010551e7140c04324615167130b0350d0550c04301155197340b55520714246150105515545
0114000020714200151c7141c01525732287321571439515207142a7322c7312c7222c71219015147142a73228732287351c7241e7321e7321e725237141701521714395151c7241c02519724195251772617025
0114000020714200151c7141c01525732287321571439515207142a7322c7312c7222c71219015147142f7322d7322d7352d724217322173221725237141701521714395151c7241c02519724195251772617025
011100000c3330034500335003253c6150a3200a4220a3220c3330334503335033253c6151332013422133220c3330734507335073253c6151632016422163220c3330334503335033253c6151b3201b4221b322
01110000162151b415222153751227415375122b5112e2151b4252b2302943027230224371f430244322442224412244153a512222153a513274152e2153a415162251b4252e4202e22222421222202242222222
011100000c3330534505335053253c6150f3201f4160f3220c3330334503335033253c6151331616315133220c3330734507335073253c6151632026416163220c3330334503335033253c6150f3161b3150f312
011100001d21522415272153f51227415375122b5112e215322303322133212304303042030412375112e43237432372222c2312c2222c2122c4102c4153a415162251b4252b4302b4222b210224302242222212
011100001f2301f4201f2101f21527415375122b5112e215162151b5112e2153a5122b415375122b5112e215162151b415225133021033410375123341027211162151b415222153751227415373112b3112e315
01110000182151f511242133c5122b415335122b5112e215162151b5112e2153a5122b415375122b5112e215162151b415225133021033410375123341027211162151b415222153751227415373112b3112e315
011100000f21522415272153f51227415375122b5112e2152723027222272122443024420244122b511224322b4322b22220231202222022220420204153a415162251b4251f4301f4221f2101d4301d4221d212
010d00000c0330443504235134253f6150443513225044350c0331342513225044353f6150443513225134250c0330443504235134253f6150443513225044350c0331342513225044353f615044351322513425
010d000028535234252d2152b5352a4252b2152f53532225395103723536520374153b2303952537410342353652034215325352f2202d5152b2302a4252b510284352622623510214351f22023515284102a225
010d00002b5352a4252821523535214251f2151e5351c4252b215235352a425232152d5352b4252a2152b535284252a215285352642523215215351f4251c2151a535174251e2151a5351c4251e2151f53523215
010d00000c0330043500235104253f6150043510225004350c0330042500225104353f6150043510225104250c0330043500235104253f6150043510225004350c0331042510225004353f615004351022500435
010d00000c0330243502235124253f6150243512225024350c0331242512225024353f6150243502235124250c0330243502235124253f6150243512225024350c0330242512225024353f615124350222512425
010d00002b5352a43528235235352b5252a42528525235252b5252a02528525235252b0252a02528725237252b0152a01528715237151f7151e7151c715177151f7151e7151c715177151371512715107150b715
010e0000184151d3152031524415356152c315184151d31520315184151d3152c315356151d31520315184151d31520315184151d31535615244151d31520315184151d3152c3152441535615203151841529315
010e00000c0230542505415054250541505425054150542501415014250141501425014150142501415014250c0230342503415034250341503425034150342500415004250041500425004150c0230041500425
010e00002041524315293152c4151d3152031524415293152c3151d4152031524315294152c3151d3152041524315293152c4151d3152031524412293152c3151d4152031524315294152c3151d3152041524315
010e00000c023014150142501415014250141520415014150c02320415014150141501415014251d415204150c023014150142501415014250141501425014150c02300425004150042500415004150041500425
010e0000182151d3251d3251d325356151d325304201d3252e4202e4201d3251d325356151d325292202c2202c2201d3251d3251d325356151d3252e4201d325294201b3251b32527420356151b3251b3251b325
010e00000c033014350142501415034350342503415034150c03305435054250541508435084250841508415356150a4350a4250a415356150c4250c4150c4150c03300435004350043500435004350042500425
010e000029420294112941229415356152b4202b4112b4122d4202d4112d4122d4123561530420304123041232411324103241032412354113541235412294163541635416294162941635416354162941629416
010e00000c0233f2153f215243032461018615243033f2150c023243033f2153f215246101201403021000210c023001053f2153f21524610186153f215003040c0233f215000053f21524610000140c01118011
010e00000c0350014500130000250c033001300002500314001450013000025001300c033186153f215003140c0350014500130000250c033001300002500314001450013000025001300c033186153f21500314
010e00000c0230010500100000050c0230010000005003040c0230010000005001000c0231201403011000110c0230010500100000050c0230010000005003040c0230010000005001000c023000140c01118011
010e00000c0250013500120000150013500120000150031400135001200001500120000151861430600003140c025001350012000015001350012000015003140013500120000150012000015186143060000314
010e00000c0333f2153f215000052461018615000053f2150c033001003f2153f215246101200403000000000c033001053f2153f21524610186153f215003040c0333f215000053f21524610000040c00018000
010e00000c0250013500130000050c023001300000500304001350013000005001300c023186153f215003040c0250013500130000050c023001300000500304001350013000005001300c023186153f21500304
010c00200c0430c225004203a314004353c3153c3140c0433c6150c0430043000430002253e5153e5150c1430c0430f234034351b313034353701437512370153c6153e5150333003430032251b3130c0431b313
010c00200c04312225064203a314064353c3153c3140c0433c6150c0430643006430062253e5153e5150c1430c04311234054351b313054353a0142e5123a0153c6153e51503335054351322605426033351b313
010c00202201524215244102431422415243152431422315223152401522410242142221524415245152421522315222142441524316224152401424512220152451524514223152441522217244162431522315
010c0000224002b4102e41030410304103041033410304103041030212294102b2102e410302102b410272102a4102a4122a41227410274102741025411274112741027410274102721027412272122741227212
010c00002a4102a4122a412274102741027412272122741527400254102a2102e4102b2102a416252102a4102741027412274122441024212244122241124411244102441024410244102421024412182110c411
__music__
01 1b 18 43 44
00 1b 18 43 44
00 17 18 43 44
00 17 18 43 44
00 19 1a 43 44
02 19 1a 43 44
01 1c 1d 43 44
00 1c 1e 43 44
00 1f 1d 43 44
00 20 1e 43 44
00 1f 1d 43 44
02 20 1e 43 44
00 21 42 43 44
00 21 42 43 44
01 21 22 43 44
00 21 22 43 44
00 23 27 43 44
00 23 24 43 44
00 21 25 43 44
02 21 26 43 44
01 28 42 43 44
00 2b 42 43 44
00 2c 42 43 44
00 28 42 43 44
00 28 2a 43 44
00 2b 2a 43 44
00 2c 29 43 44
02 28 2d 43 44
01 30 2f 43 44
00 30 2f 43 44
00 2e 2f 43 44
00 2e 2f 43 44
00 31 32 43 44
00 31 32 43 44
00 31 32 43 44
00 2f 32 43 44
02 33 34 43 44
01 37 38 43 44
00 37 38 43 44
00 35 36 43 44
00 35 36 43 44
00 39 3a 43 44
02 39 3a 43 44
00 3b 42 43 44
00 3c 42 43 44
01 3b 3d 43 44
00 3c 3d 43 44
00 3b 3d 43 44
00 3c 3d 43 44
00 3b 3e 43 44
00 3c 3f 43 44
00 3b 3e 43 44
02 3c 3f 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
