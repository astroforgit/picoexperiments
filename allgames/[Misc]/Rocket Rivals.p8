pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- rocket rivals
-- by nat pryce

-- todo list 
 -- music


debug = false

function class(constructor)
	constructor = constructor or function(self, props)
		if props then
			for k, v in pairs(props) do
			  self[k] = v
		  end
		end
		self:__init()
	end
	
  local class = {}
  class.__index = class
	class.__init = function() end
  setmetatable(class, {
    __call = function(_, ...)
      local new = {}
      setmetatable(new, class)
      constructor(new, ...)
      return new
    end
  })
  return class
end

-- requires class.p8.lua to have been included

v2 = class(function(self, x, y)
	self.x = x
	self.y = y
end)

v2.zero = v2(0,0)

function v2.polar(angle, length)
  return v2(cos(angle), sin(angle))*length	
end

function v2:xcoord()
	return self.x
end

function v2:ycoord()
	return self.y
end

function v2.__tostring(a)
  return "("..a.x..","..a.y..")"
end

-- workaround for pico-8 not 
-- supporting the __tostring
-- metafunction
function v2.__concat(a, b)
  if (type(a)=="table") a=v2.__tostring(a)
  if (type(b)=="table") b=v2.__tostring(b)
  return a..b
end


function v2.__eq(a, b)
  return a.x==b.x and a.y==b.y
end

function v2.__add(a, b)
  return v2(a.x+b.x, a.y+b.y)
end

function v2.__sub(a, b)
  return v2(a.x-b.x, a.y-b.y)
end

function v2.__unm(a)
  return v2(-a.x, -a.y)
end

function v2._op_order(a, b)
	if type(a) == number then
		return b, a
	else
		return a, b
	end
end

function v2.__mul(a, b)
	local v, n = v2._op_order(a, b)
  return v:scale(n, number)
end

function v2.dot(a, b)
	return a.x*b.x + a.y*b.y
end

function v2.__div(a, b)
	local v, n = v2._op_order(a, b)
  return v2(v.x/n, v.y/n)
end

function v2:scale(sx, sy)
	return v2(self.x*sx, self.y*(sy or sx))
end

function v2:lensq()
  return self.x^2 + self.y^2
end

-- see https://www.lexaloffle.com/bbs/?pid=38407
function v2:len()
  local d = max(abs(self.x), abs(self.y))
  local n = min(abs(self.x), abs(self.y)) / d
  return ((n*n + 1) * d)^0.5
end

function v2:uniform()
  return self/self:len()
end

function v2:rotacw()
  return v2(self.y, -self.x)
end

function v2:rotcw()
  return v2(-self.y, self.x)
end

function v2:relto(p, op)
	return op(self-p)+p
end


-- round coordinates down to nearest integer
function v2:flr()
	return v2(flr(self.x), flr(self.y))
end

-- a random uniform vector
function v2.rndu()
	angle = rnd(1)
    return v2(cos(angle), sin(angle))
end


range = class(function(self, min, max)
  self.min = min
	self.max = max
end)

function range.between(min, max)
  return range(min, max)
end

function range.around(v, radius)
  return range(v-radius, v+radius)
end

function range.from(v, extent)
  return range(v, v+extent)
end

function range.only(v)
  return range(v,v)
end

function range:contains(v)
  return self.min <= v and v <= self.max
end

function range:clamp(v)
  return mid(self.min, v, self.max)
end

function range:extent()
  return self.max - self.min
end

function range:rnd()
  return self.min + rnd(self:extent())
end

function range:interpolate(r)
  return self.min + r*self:extent()	
end

range.zero = range.between(0,0)

-- centered printing

-- width of a printed string
function pixelwidth(s)
  s = ""..s
  if #s == 0 then 
    return 0
  end
  
  w = 0
  for i = 1, #s do
    if sub(s,i,i) >= "\x80" then
      w += 7
    else 
      w += 3
    end
  end
  
  return w + #s - 1
end

-- print centered
function printc(s, x, y)
  print(s, x - pixelwidth(s)/2, y)
end

--by @electricgryphon
function trifill( x1,y1, x2,y2, x3,y3, color1)
  local min_x = min(x1,min(x2,x3))
  if(min_x>127) return
  local max_x = max(x1,max(x2,x3))
  if(max_x<0) return
  local min_y = min(y1,min(y2,y3))
  if(min_y>127) return
  local max_y = max(y1,max(y2,y3))
  if(max_y<0) return

	local x1=band(x1,0xffff)
	local x2=band(x2,0xffff)
	local y1=band(y1,0xffff)
	local y2=band(y2,0xffff)
	local x3=band(x3,0xffff)
	local y3=band(y3,0xffff)

	local width=min(127,max_x)-max(0,min_x)
	local height=min(127,max_y)-max(0,min_y)

	if(width>height)then --wide triangle 
		local nsx,nex
		--sort y1,y2,y3
		if(y1>y2)then
			y1,y2=y2,y1
			x1,x2=x2,x1
		end

		if(y1>y3)then
			y1,y3=y3,y1
			x1,x3=x3,x1
		end

		if(y2>y3)then
			y2,y3=y3,y2
			x2,x3=x3,x2 
		end

		if(y1!=y2)then 
			local delta_sx=(x3-x1)/(y3-y1)
			local delta_ex=(x2-x1)/(y2-y1)

			if(y1>0)then
				nsx=x1
				nex=x1
				min_y=y1
			else --top edge clip
				nsx=x1-delta_sx*y1
				nex=x1-delta_ex*y1
				min_y=0
			end

			max_y=min(y2,128)

			for y=min_y,max_y-1 do
				rectfill(nsx,y,nex,y,color1)
				nsx+=delta_sx
				nex+=delta_ex
			end

		else --where top edge is horizontal
			nsx=x1
			nex=x2
		end

		if(y3!=y2)then
		local delta_sx=(x3-x1)/(y3-y1)
		local delta_ex=(x3-x2)/(y3-y2)

		min_y=y2
		max_y=min(y3,128)
		if(y2<0)then
			nex=x2-delta_ex*y2
			nsx=x1-delta_sx*y1
			min_y=0
		end

		for y=min_y,max_y do
			rectfill(nsx,y,nex,y,color1)
			nex+=delta_ex
			nsx+=delta_sx
		end

		else -- where bottom edge is horizontal
			rectfill(nsx,y3,nex,y3,color1)
		end
	else 
		--tall triangle 
		local nsy,ney

		--sort x1,x2,x3
		if(x1>x2)then
			x1,x2=x2,x1
			y1,y2=y2,y1
		end

		if(x1>x3)then
			x1,x3=x3,x1
			y1,y3=y3,y1
		end

		if(x2>x3)then
			x2,x3=x3,x2
			y2,y3=y3,y2 
		end

		if(x1!=x2)then 
			local delta_sy=(y3-y1)/(x3-x1)
			local delta_ey=(y2-y1)/(x2-x1)

			if(x1>0)then
				nsy=y1
				ney=y1
				min_x=x1
			else --top edge clip
				nsy=y1-delta_sy*x1
				ney=y1-delta_ey*x1
				min_x=0
			end

			max_x=min(x2,128)

			for x=min_x,max_x-1 do
				rectfill(x,nsy,x,ney,color1)
				nsy+=delta_sy
				ney+=delta_ey
			end

		else --where top edge is horizontal
			nsy=y1
			ney=y2
		end

		if x3 != x2 then
			local delta_sy=(y3-y1)/(x3-x1)
			local delta_ey=(y3-y2)/(x3-x2)

			min_x=x2
			max_x=min(x3,128)
			
			if x2 < 0 then
				ney=y2-delta_ey*x2
				nsy=y1-delta_sy*x1
				min_x=0
			end

			for x=min_x,max_x do
				rectfill(x,nsy,x,ney,color1)
				ney+=delta_ey
				nsy+=delta_sy
			end

		else --where bottom edge is horizontal
	   	rectfill(x3,nsy,x3,ney,color1)
		end
  end
end



current_mode = nil


function start_mode(mode, ...)
  if current_mode and current_mode.stop then
    current_mode:stop()
  end
  
  current_mode = mode
  gtime = -1
  
  if mode.start then
    mode:start(...)
  end
end



function _init()
  palt(15, true)
  palt(0, false)
  
  title_mode:init()
  
  menuitem(
    1, "return to title", 
    reset)
  
  reset()
end


function reset()
  start_mode(title_mode)
end


function _update()
  gtime = gtime + 1
  current_mode:update()
end


function _draw()
  current_mode:draw()
  if debug then
    print("cpu:"..(flr(stat(1)*1000)/10).."%", 0, 0, 7)
  end
end




--------------------------------
-- useful functions

function maxof(list, maxf)
  maxf = maxf or max
  local max_element = nil
  
  for e in all(list) do
    max_element = max_element and maxf(max_element, e) or e
  end
  
  return max_element
end


function maxby(list, property)
  return maxof(list, function(a,b)
    if property(a) >= property(b) then
      return a
    else
      return b
    end
  end)
end




-->8
-- menu system

menu = class(function(self, rows, help_y)
  self.rows = rows
  self.row = 0
  self.cols = {}
  self.help_y = help_y or 112
end)


function menu.fg(selected)
  if selected then
    return 0
  else
    return 6
  end
end


function menu.outline(selected)
  if selected and time()%0.5 < 0.25 then
    return 7
  else
    return 6
  end
end


function menu.bg(selected)
		if selected then
    return 6
  else
    return 0
  end
end


function menu:update()
 local r = self.row
 local c = self.cols[r+1] or 0
 local rowcount = #self.rows
 local rowlen = #self.rows[r+1]
 
	if btnp(‹) then
	  self.cols[r+1] = (c - 1) % rowlen
	  sfx(62)
	elseif btnp(‘) then
	  self.cols[r+1] = (c + 1) % rowlen
	  sfx(62)
	elseif btnp(”) then
	  self.row = (r - 1) % rowcount
	  sfx(62)
	elseif btnp(ƒ) then
	  self.row = (r + 1) % rowcount
	  sfx(62)
	elseif btnp(—) or btnp(Ž) then
	  sfx(63)
	  self.rows[r+1][c+1]:action()
	end
end


function menu:draw()
  local selected_row = 
    self.row+1
  local selected_col = 
    (self.cols[selected_row] or 0)+1
  local selected = 
    self.rows[selected_row][selected_col]
  
  for r = 1,#self.rows do
    local row = self.rows[r]
    for c = 1,#row do
      local widget = row[c]
      widget:draw(widget==selected)
    end
  end
  
  color(5)
  printc("‹|”|ƒ|‘ : move focus",
    64, self.help_y)
  printc(
    selected:help_text() or "", 
    64, self.help_y+8)
end

function menu:select(row, col)
  self.row = row-1
  if col then
    self.cols[row] = col-1
  end
end



text_button = class()

function text_button:__init()
  if not self.width then
    self.width = pixelwidth(self.text) + 6
  end
  if not self.height then
    self.height = 11
  end
end

function text_button:draw(selected)
  local tl = self.pos - v2(self.width/2,0)
  
  rect(
    tl.x, tl.y, 
    tl.x+self.width-1, 
    tl.y+self.height-1,
    menu.outline(selected))
 
	 rectfill(tl.x+1, tl.y+1, 
    tl.x+self.width-2, 
    tl.y+self.height-2,
    menu.bg(selected))
  
  color(menu.fg(selected))
  printc(self.text, 
    tl.x+self.width/2, tl.y+3,
    menu.fg(selected))
end

function text_button:help_text()
  return self.help
end

-->8
-- character selector widget

char_sel = class(
  function(self, player, index, top_left, onchange)
    self.player = player
    self.index = index
    self.tl = top_left
    self.onchange = onchange
  end)

char_sel.width = 24


function char_sel:help_text()
  return "<Ž|—> : choose a character"
end


function char_sel:draw(selected)
  local x = self.tl.x
  local y = self.tl.y
  local c = characters[self.index]
  
  if selected then
    rect(x, y, x+19, y+19, 
      menu.outline(selected))
  end
    
  spr(c and c.sprite or 108, 
    x+2, y+2, 2, 2)

  local ctl = controls[self.player]
  color(6)  
  printc("p"..(ctl.pad+1)..((ctl.button == Ž) and "Ž" or "—"),
    x+10, y+21)
end


function char_sel:action()
  if btnp(Ž) then
    di = 1
  elseif btnp(—) then
    di = -1    
  else
    di = 0
  end
  
  self.index = (self.index+di) % (#characters+1)
  self.onchange(self.index)
end


function char_sel.row(top, onchange)
  local selectors = {}
  
  local space = 128/max_players
  
  for p = 1, max_players do
    local x = (p-1)*space + (4 + space - char_sel.width)/2
    add(selectors, char_sel(
      p,
      p, 
      v2(x,48),
      function(choice)
        onchange(p, choice)
      end))
  end
  
  return selectors
end

-->8
-- control schemes

share_gamepads = {
  { pad=0, button=Ž },
  { pad=0, button=— },
  { pad=1, button=Ž },
  { pad=1, button=— }
}

individual_gamepads = {
  { pad=0, button=Ž },
  { pad=1, button=Ž },
  { pad=2, button=Ž },
  { pad=3, button=Ž }
}


control_schemes = {
  share_gamepads,
  individual_gamepads
}

controls = share_gamepads

-->8
-- title screen


title_mode = {
  selected = {1, 2, 3, 4},
  controls_index = 1
}


function draw_logo()
  sspr(0, 64, 128, 32, 
       0, 0, 128, 32)
end


function title_mode:init()
		self.menu = menu {
		  char_sel.row(48,
		    function(i, choice)
		      self.selected[i] = choice
		    end
		  ),
    {
		    text_button {
				    text = "‰",
				    pos = v2(12,88), 
				    width = 16,
				    action = function()
				      start_mode(credits_mode)
				    end,
				    help = "Ž|— : credits..."
				  },
				  text_button {
				    text = "?",
				    width = 16,
				    pos = v2(30,88), 
				    action = function()
				      start_mode(help_mode)
				    end,
				    help = "Ž|— : instructions..."
				  },
				  text_button {
				    text = "—",
				    pos = v2(48,88), 
				    width = 16,
				    action = function()
				      self:toggle_controls()
				    end,
				    help = "Ž|— : toggle control scheme"
				  },
				  text_button {
				    text = "start game", 
				    pos = v2(102,88), 
				    action = function()
				      if self:player_count() >= 2 then
		          start_mode(
		            game_start_mode,
		            self.selected)
		        end
				    end,
				    help_text = function()
				      if self:player_count() >= 2 then
				        return "Ž|— : start the game"
				      else
		          return "choose two or more players"
		        end
				    end
				  }
		  }
		}
end


function title_mode:toggle_controls()
  self.controls_index = 
    self.controls_index % #control_schemes + 1
  controls = control_schemes[self.controls_index]
end


function title_mode:start()
  cls(0)
  self.menu:select(2, 4)
end


function title_mode:player_count()
  n = 0
  for c in all(self.selected) do
    if c > 0 then
      n += 1
    end
  end
  return n
end


function title_mode:update()
  self.menu:update()
end


function title_mode:draw()
  cls(0)
  draw_logo()  
  color(10)
  printc("players", 63, 36)
  self.menu:draw()
end


text_mode = class()

function text_mode:__init()
  self.menu = menu {
    {
      text_button {
				    text = "Š back", 
				    pos = v2(64,96), 
			     action = function()
          start_mode(
            title_mode)
				    end,
				    help = "Ž|— : return to title screen"
		    }
    }
  }
end


function text_mode:update()
  self.menu:update()
end


function text_mode:draw()
  cls(0)
  draw_logo()
  
  color(10)
  for i = 1,#self.text do
    self:draw_line(
      self.text[i], 
      40 + (i-1)*8)
  end
  
  self.menu:draw()
end


function text_mode:draw_line(t, y)
  print(t, 6, y)
end


help_mode = text_mode {
  text = {
    "hold your button to thrust.",
    "you earn points when you're",
    "the highest player, but you",
    "lose it all if you touch the",
    "laser beam. the highest score",
    "at the end of the match wins."
  }
}


credits_mode = text_mode {
  text = {
    "by @dredds",
    --"",
    --"music by @gruber",
    "",
    "uses triangle fill routine",
    "by @electricgryphon",
  },
  
  draw_line = function(self, t, y)
    printc(t, 64, y)
  end
}

-->8
-------------------------------
-- particles

particles = {}

function new_particle(
  fade,
  pos, 
  vel, 
  life, 
  mass
)
  add(particles, {
    fade = fade,
    pos = pos,
    vel = vel,
    mass = mass or 1,
    max_life = life, 
    life = life
  })
end


function update_particles()
  local updated = {}
  
  for p in all(particles) do
    p.life -= 1
    if p.life > 0 then
      move(p)
	  
				  if p.pos.y > floor and p.vel.y > 0 then
				    p.pos.y = (floor) - (p.pos.y-floor)
				    p.vel = p.vel:scale(2, -0.1)
			     p.fade = smoke
				  end
	  
      add(updated, p)
    end
  end
  
  particles = updated
end


function draw_particles()
  for p in all(particles) do
    pset(
      p.pos.x, 
      p.pos.y, 
      p.fade[ceil(#p.fade*p.life/p.max_life)])  
  end
end


-- particle fades
electric = {0, 1, 12, 7}
fire = {5, 4, 8, 9, 10, 7}
smoke = {0, 5, 13, 6, 7}
laser = {0, 2, 8, 7}


-- functions to launch multiple
-- particles

function particle_ring(
  fade,
  count,
  center,
  base_vel,
  radius, 
  speed_range,
  life_range,
  mass
)
  for i = 1,count do
    local r = i/count
    local a = r + rnd(r/count)
    local u = v2(cos(a),sin(a))
    local speed = speed_range:rnd()
    
    new_particle(
      fade,
      center + u*radius,
      base_vel + u*speed,
      life_range:rnd(),
      mass
    )
  end  
end

function particle_spray(
  fade,
  count,
  source,
  angle_range,
  speed_range,
  life_range,
  mass
)
  for i = 1,count do
    local r = i/count
	local a = angle_range:interpolate(r + (rnd(1)-0.5)*r/count)
	local u = v2.polar(a, 1)
    
	new_particle(
	  fade,
	  source,
	  u * speed_range:rnd(),
	  life_range:rnd(),
	  mass
	)
	end  
end


function pixels_to_particles(
  tl,
  span,
  bg,
  fade,
  velbias,
  mass
)
  local midv = tl+(span/2)
  
  for y = tl.y, tl.y+span.y-1 do
    for x = tl.x, tl.x+span.x-1 do
      local c = pget(x,y)
      pset(x, y, bg)
      if c != bg then
        local pos = v2(x,y)
        local vel = ((pos+velbias)-midv):scale(1/30)
        
        new_particle(
          fade,
          pos, 
          vel,
          60,
          mass or 0
        )
		    end
    end
  end
end
-->8
-- game logic

gravity = v2(0, 1/3)

max_players = 4

thrust = 2/3
floor = 119
ceiling = 8

max_stun = 10

game_duration = 60*30


characters = {
  {
    sprite = 2
  },
  {
    sprite = 4
  },
  {
    sprite = 6
  },
  {
    sprite = 8
  },
  {
    sprite = 0
  },
  {
    sprite = 10
  },
  {
    sprite = 12
  },
  {
    sprite = 14
  }
}

players = {}
winner = nil


function opal()
  for i = 1,14 do
    pal(i, 0)
  end
end

function restore_pal()
  for i = 1,14 do
    pal(i, i)
  end
end

function ospr(s, x, y, w, h)
  w = w or 1
  h = h or 1
  
  for i = 1,14 do
    pal(i, 0)
  end

  spr(s, x-1, y-1, w, h)
  spr(s, x,   y-1, w, h)
  spr(s, x+1, y-1, w, h)
  
  spr(s, x-1, y,   w, h)
  spr(s, x+1, y,   w, h)
  
  spr(s, x-1, y+1, w, h)
  spr(s, x,   y+1, w, h)
  spr(s, x+1, y+1, w, h)
  
  for i = 1,14 do
    pal(i, i)
  end
  
  spr(s, x,   y,   w, h)
end  


function move(sprite)
  sprite.vel += gravity * sprite.mass
  sprite.pos += sprite.vel
end


function new_player(
  base_frame, 
  control
)
  add(players, {
    player = #players,
    control = control,
    base_frame = base_frame,
    vel = v2(0, 0),
    mass = 1,
    thrust = 0,
    stun = 0,
    score = 0
  })
end



function position_players()
  space = 128/(#players+1)
  for i = 1,#players do
    local p = players[i]
    p.pos = v2(i*space,floor-16)
  end
end


function control_player(p)
  if p.stun == 0 and btn(p.control.button, p.control.pad) then
    p.thrust = thrust
	   particle_spray(
				  fire,
				  6,
				  p.pos + v2(-1,4),
				  range.around(0.75, 0.05),
				  range.between(1, 2),
				  range.between(20, 40),
				  -0.05
    )
  else
    p.thrust = 0
  end
end


function update_player(p)  
  if p.stun > 0 then
    p.stun -= 1
    if p.stun == 0 then
      p.mass = 1
    end
  end
  
  p.vel += v2(0, -p.thrust)
  move(p)
  
  yt = p.pos.y    -- top
  yb = p.pos.y+15 -- bottom
  
  if yt <= ceiling then
    if p.stun == 0 then
      sfx(1)
    end
    
    p.stun = max_stun
    p.thrust = 0
    p.score = 0
    
    particle_ring(
      electric,
      12,
      p.pos + v2(0,8),
      p.vel,
      4,
      range.between(2,4),
      range.between(5,10),
      0)
  end
  
  if yt < 0 and p.vel.y < 0 then
    p.pos.y = -p.pos.y
    p.vel.y = p.vel.y * -0.5
  elseif yb > floor and p.vel.y > 0 then
    if p.vel.y > 1 then
      sfx(5)
    end
    
    p.pos.y = floor - (yb-floor) - 15
    p.vel.y = p.vel.y * -0.5
  end
end


function draw_player(p)
  local pos = p.pos
  local frame
  if pos.y <= ceiling then
    frame = 64
    pos += v2.rndu() - v2(0.5,0.5)
  elseif p.thrust > 0 then
    frame = 32
  else
    frame = 0
  end
  
  ospr(p.base_frame+frame, 
    pos.x-7, pos.y, 2, 2)
end


function best_player(is_better_than)
  local best = nil
  
  for p in all(players) do
    if best == nil or is_better_than(best, p) then
      best = p
    end
  end
  
  return best
end


function highest_player()
  return maxby(players, function(p)
    return -p.pos.y
  end)
end


function winning_player()
  return maxby(players, function(p)
    return p.score
  end)
end


function spawn_laser_sparks()
  for i = 1,2 do
		  new_particle(
		    electric,
		    v2(9+rnd()*109, ceiling),
		    v2.rndu() * (0.5+rnd(1)),
		    flr(10 + rnd(10)),
		    0)
  end
end


function draw_floor(t)
  left = game_duration - t
  if left <= 150 and flr(t/10)%2 == 0 then
    shown = 0
  else
    shown = left/game_duration
  end
  tw = ceil(128 * shown)
    
  line(0, floor+1, tw-1, 
          floor+1, 7)
  line(tw, floor+1, 128, 
           floor+1, 2)
end


function draw_game(draw_mode_details)
  cls(1)
  
  bg_draw()
  
  draw_particles()
  
  -- draw laser beam
  if rnd(1) >= 0.4 then
    color(12)
  else
    color(7)
  end
  spr(127, 0, 5)
  spr(127, 120, 5, 1, 1, 0)
  line(9, ceiling, 118, ceiling)
	 
  draw_mode_details()
  
  foreach(players, draw_player)
end


function draw_scores()
	 color(9)
	 for p in all(players) do
	   printc(
	     flr(p.score/15), 
	     flr(p.pos.x), 122)
	 end	 
end


function show_winner()
	 if winner then
	   ospr(111, 
	     winner.pos.x-3, 
	     winner.pos.y-9)
	 end
end


game_start_mode = {
  start = function(self, charsel)
		  players = {}
		  winner = nil
		  
		  for i = 1,max_players do
		    local c = 
		      characters[charsel[i]]
		    
		    if c then
		      new_player(
		        c.sprite, 
		        controls[i])
		    end
		  end  
    
    particles = {}
    position_players()
    
    bg_gen()
  end,
  
  update = function()
    spawn_laser_sparks()
		  update_particles()
		  
		  if gtime > 120 then
		    start_mode(game_mode)
		  end
  end,
  
  draw = function()
    draw_game(function()
		    draw_floor(game_duration)
		    
				  frame = flr(gtime / 30)
				  r = (gtime % 30)/30
				  side = 16+80 * r^2
				  x = 64-side/2
				  y = 32
      
      for c = 8,11 do
        pal(c, 0)
      end
      
				  for xoffset = -1,1,2 do
				    for yoffset = -1,1,2 do
								  sspr(
								    frame*16, 48,
								    16, 8,
								    x+xoffset, y+yoffset,
								    side, side/2
								  )
				    end
				  end
				  
				  for c = 8,11 do
				    pal(c, c)
				  end
				  
				  sspr(
				    frame*16, 48,
				    16, 8,
				    x, y,
				    side, side/2
				  )
				end)
  end
}


game_mode = {
  update = function(self)
		  foreach(players, 
		    control_player)
		  
		  spawn_laser_sparks()
		  update_particles()
		  
		  foreach(players, 
		    update_player)
		  
		  -- give scores.  you have to
		  -- have launched to earn a
		  -- score
		  local h = highest_player()
		  if h.pos.y < floor-17 then
		    h.score += 1
		  end
		  
				local w = winning_player()
				if w.score > 0 and w != winner then
				  winner = w
				  sfx(0)
		  end
		  
		  local tleft = game_duration - gtime
		  if tleft <= 0 then
      start_mode(game_over_mode)
		  elseif tleft <= 150 and tleft > 0 and gtime % 20 == 0 then
		    sfx(2)
				end
		end,
	 
		draw = function(self)
		  draw_game(function()
		    draw_floor(gtime)
		    draw_scores()
		    show_winner()
		  end)
		end
}



game_over_mode = {
  start = function(self)
    if winner then
		    winner.thrust = 0
		    winner.stun = 0
		    
		    self.wstart = winner.pos
		    self.wpath = v2(63,48) - winner.pos
		    
		    sfx(3)
		  else
		    sfx(4)
		  end
  end,
  
  update = function(self)
    spawn_laser_sparks()
    update_particles()
    
    -- players who didn't win 
    -- fall to the ground
    for p in all(players) do
      if p != winner then
        update_player(p)
      end
    end
    
    if winner then
		    winner.pos = 
		      self.wstart + self.wpath * min(1,gtime/60)
			 end
			 
    if gtime > 90 and (btnp(—) or btnp(Ž)) then
      start_mode(title_mode)
    end
  end,
  
  draw = function(self)
    draw_game(function()
      draw_floor(game_duration)
      
      clip(0, 0, 127, floor)
      
      if winner then
        local x = winner.pos.x
        local y = winner.pos.y+8
        
  	     local n = 11
		      local da = (gtime/240)
		      for i = 1,n do
		        local v = v2.polar(da + i/n, 180)
		        local u = v:uniform() * 1
		        
		        local va = v + u:rotcw()
		        local vb = v + u:rotacw()
		        
		        trifill(
		          x, y,
		          va.x, va.y,
		          vb.x, vb.y,
		          7
		        )
		      end
		      
		 	    circfill(x, y-4, 16, 7)     
		      
		      show_winner()
		      
		      clip()
		    else
		      r = min(1, gtime/30)
						  side = 32 + 64 * r^2
						  
						  sspr(
						    64, 48,
						    32, 8,
						    64-side/2, 32,
						    side, side/4
						  )
      end
      
      if gtime > 90 then
        color(9)
        printc("Ž|— : return to title screen", 
          63, 122)
      end
    end)
  end
}

-->8
-- draw bg

function draw_moon(x, y)
  palt(15, false)
  palt(11, true)
  sspr(0, 96, 64, 32, x, y)
  sspr(64, 96, 64, 32, x, y+32)
  palt(11, false)
		palt(15, true)
end


function vfade(y1, y2, c1, c2)
  local h = y2-y1
  
  for dy = 0, h-1 do
    local y = y1+dy
    local c = 
      rnd(h) < dy and c2 or c1
    
    line(0, y, 128, y, c)
  end
end


-- generate the bg in memory
function bg_gen()
  cls(0)
  
  -- draw sunset
  vfade(16, 40, 0, 1)
  rectfill(0, 40, 128, 48, 1)
  vfade(48, 80, 1, 2)
  rectfill(0, 80, 128, 96, 2)
  vfade(96, 119, 2, 9)
  
  -- draw stars
  for i = 1,24 do
    pset(rnd(128), rnd(48), 7)
  end
  
  draw_moon(8+rnd(56), 12+rnd(8))
  
  memcpy(0x2000, 0x6000, 4096)
  memcpy(0x4300, 0x7000, 4096)
end


function bg_draw()
  memcpy(0x6000, 0x2000, 4096)
  memcpy(0x7000, 0x4300, 4096)
end

__gfx__
ffffff666ffffffffffff66666fffffffffff66666fffffffffff66666ffffffffffff333ffffffff444f44442f444fffffff666ddfffffffffff77777ffffff
fffffff6ffffffffffff6776666ffffffffff67666ffffffffff6776666ffffffffff33333fffffff4e444444424e4ffffff706dd70fffffffff7000007fffff
ffffffdddffffffffff677333666ffffffff678886dffffffff677666666fffffffff77377fffffff4444704704244ffffff00d6d00ffffffff707000007ffff
f66666fdf66666fffff673333366ffffffff666666dffffffff676333666fffffffff70907fffffffff4400e0042ffffffff666ddddffffffff700000007ffff
fd66fffdfff66dfffff663333366fffffffff6ddddfffffffff663a3a366fffffffff39993fffffffff444eee442ffffff6666d6ddd66ffffff700000007ffff
fffffeedeefffffffff633838336ffffffffff6ddffffffffff666333666ffffffffff999ffffffffff444444442fffff666666dddd666ffffff7000007fffff
fffeeeeeeeeefffffff533333335fffffff7f6666df6fffffff556636655ffffff66659995666fffffff4444442ffffff66666d6ddd666fffffff66666ffffff
ffee77eee77eeffffff853333358ffffff76d6766dd6dfffffdd655555555ffff6665666665666fffff442222244fffff6ff666ddddff6fffff777777777ffff
ffe7777e7777efffff88855555288fffff66d6766dd6dffffdd6ddddd5d555ff666656666656666fff44444444244fffffff66d6dddfffffff77777787677fff
fee7707e7077eefff8828888882288ffff6dd6666dd6dfffdd66dddddd5d555f666f5666665f666ff4424444442244fffffff66dddfffffff7767777776677ff
feee77eee77ee2ff882f8888982f288fff6df6766df6dfffd66dddddddd5d55f66ff5566655ff66f442f4444442f244ffffff666ddffffff776f5555555f677f
feeeeeeeeeeee2fff2ff8888882ff2ffff6df6666df6dffff56ddddddd5d55ffffff5555555ffffff2ff4444442ff2ffffffff6ddffffffff6ff7777776ff6ff
feeeeeeeeeeee2ffffff8888882ffffffffff6666dffffffff55ddddddd55fffffff5955595fffffffff4444442fffffffffff66dfffffffffff7766776fffff
f2eeeeeeeeee22fffffff88882ffffffffff6ddddd6fffffffff5555555ffffffffff95559fffffffffff44442fffffffffffdd6ddffffffffff776f776fffff
ff2eeeeeee222fffffff8822222ffffffff6dfffffd6fffffff5fffffff5fffffffff9fff9ffffffffff4422222fffffffffddd6dddffffffff7776f7776ffff
fff222222222ffffffff22fff22fffffffddddfffddddfffff555fffff555fffffff999f999fffffffff22fff22fffffffffddd6dddffffffff5555f5555ffff
ffdd6666666ddffffffff66666fffffffffff66666fffffffffff66666ffffffffffff333ffffffffffff44442fffffffffff666ddfffffffffff77777ffffff
666666ddd666666fffff6776666ffffffffff67666ffffffffff6776666ffffffffff33333ffffffff44444444244fffffff706dd70fffffffff7000007fffff
ffdd6666666ddffffff677333666ffffffff678886dffffffff677666666fffffffff77377fffffff4e447047042e4ffffff00d6d00ffffffff707000007ffff
fffffffdfffffffffff673333366ffffffff666666dffffffff676a3a666fffffffff70907fffffff444400e004244ffffff666ddddffffffff700000007ffff
fffffeedeefffffffff663838366fffffffff6ddddfffffffff663333366fffffffff39993fffffffff444eee442fffffff666d6ddd6fffff7f700000007f7ff
ffffeeeeeeeffffffff633333336ffffffffff6ddffffffffff666333666ffffffffff999ffffffffff444444442ffffff66666dddd66fff777f7000007f776f
fffeeeeeeeeefffffff533333335fffffff7f6666df6fffffff556636655ffffffff6599956fffffffff4444442fffffff6666d6ddd66ffff677f66666f776ff
ffeeeeeeeeee2ffffff853333358ffffff76d6766dd6dfffffdd655555555ffffff656666656fffffff442222244ffffff6f666ddddf6fffff67777777776fff
ffe7707e70772fffff82855555282fffff66d6766dd6dffffdd6ddddd5d555fffff656666656ffffff42444444242fffff6f66d6dddf6ffffff677778776ffff
fee7777e7777e2ffff82888888282fffff6dd6666dd6dfffdd66dddddd5d555ffff656666656ffffff42444444242ffffffff66dddffffffffff7777776fffff
fee2222e2222e2ffff82888898282fffff6df6766df6dfffd66dddddddd5d55ffff655666556ffffff42444444242ffffffff666ddffffffffff5555555fffff
feeeeeeeeeeee2ffff82888888282fffff6df6666df6dffff56ddddddd5d55fffff655555556ffffff42444444242fffffffff6ddfffffffffff7777776fffff
ffeeeeeeeeee2fffffff8888882ffffffffffd666dffffffff55ddddddd55fffffff9995999fffffffff4444442fffffffffff66dfffffffffff7766776fffff
ffeeeeeeeee22ffffffff88882ffffffffffffd6dfffffffffff5555555fffffffff999f999ffffffffff44442fffffffffffdd6ddffffffffff776f776fffff
fff2eeeee222fffffffff82222fffffffffffffdfffffffffffffffffffffffffffff9fff9fffffffffff42222ffffffffffddd6dddffffffff7776f7776ffff
ffff2222222ffffffffff22f22fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff22f22ffffffffffddd6dddffffffff5555f5555ffff
ffffff555ffffffffffff55555fffffffffff55555fffffffffff55555ffffffffffff555ffffffff555f55555f555fffffff55555fffffffffff55555ffffff
fffffff5ffffffffffff5555555ffffffffff57775ffffffffff5555555ffffffffff57775fffffff5555777775555ffffff5577755fffffffff5777775fffff
ffffff555ffffffffff555777555ffffffff5575755ffffffff555555555fffffffff57775fffffff5557557557555ffffff5717175ffffffff577777775ffff
f55555f5f55555fffff557777755ffffffff5577755ffffffff555777555fffffffff55755fffffffff575575575ffffffff5777775ffffffff570777075ffff
f555fff5fff555fffff557777755fffffffff55755fffffffff557575755fffffffff57775fffffffff577757775ffffff55555755555ffffff577707775ffff
fffff55555fffffffff577575775ffffffffff575ffffffffff555777555ffffffffff575ffffffffff557777755fffff5577777777755ffffff5577755fffff
fff555777555fffffff577777775fffffff5f55755f5fffffff555575555ffffff55555755555fffffff5577755ffffff5555557555555fffffff55755ffffff
ff55777777755ffffff557777755ffffff55557775555fffff55577777555ffff5577777777755fffff555575555fffff5ff5777775ff5fffff557777755ffff
ff57777777775fffff57777777775fffff57777577775ffff5577777777755ff557555575555755fff57777777775fffffff5557555fffffff57755755775fff
f5775577755775fff5755557555575ffff57557575575fff577557777755775f575f5777775f575ff5755557555575fffffff57775fffffff5755777775575ff
f5775577755775ff575f5777775f575fff55f57575f55fff555575757575555f55ff5557555ff55f575f5777775f575ffffff55755ffffff575f5557555f575f
f5577777777755fff5ff5557555ff5ffff55f57575f55ffff5575575755755ffffff5777775ffffff5ff5557555ff5ffffffff575ffffffff5ff5577755ff5ff
f5555557555555ffffff5777775ffffffffff57775ffffffff55575557555fffffff5577755fffffffff5777775fffffffffff575fffffffffff5755575fffff
f5577777777755fffffff57575ffffffffff7755577fffffffff5555555ffffffffff75557fffffffffff57575fffffffffff55755ffffffffff575f575fffff
ff55555755555fffffff5755575ffffffff57fffff75fffffff5fffffff5fffffffff7fff7ffffffffff5755575fffffffff5575755ffffffff5575f5755ffff
fff555555555ffffffff55fff55fffffff7777fff7777fffff555fffff555fffffff777f777fffffffff55fff55fffffffff5555555ffffffff5555f5555ffff
fffff88888ffffffffffff9999fffffffffffffaaffffffffbbbbfffbbbbffbbff66666ff66666ffff66fff66ff66fffffffffffffffffffffffffffffffffff
fffffffff88ffffffffff99ff99fffffffffffaaafffffffbbffbbfbbffbbfbbfff66f66f66ff66ff6666ff66ff66ffffff5ffffffff5fffffffffffafffffaf
fffffff888fffffffffffffff99ffffffffffffaafffffffbbfffffbbffbbfbbfff66f66f66ff66f66ff66f66ff66fffff555ffffff555ffffffffffaff9ff4f
fffffffff88fffffffffffff99fffffffffffffaafffffffbbfffffbbffbbfbbfff66f66f66666ff66ff66f666666ffff55555ffff55555fffffffffaa99944f
fffffffff88ffffffffffff99ffffffffffffffaafffffffbbfbbbfbbffbbffffff66f66f6666fff666666f666666fffff55555ff55555ffffffffffa898984f
fffffffff88fffffffffff99fffffffffffffffaafffffffbbffbbfbbffbbfbbfff66f66f66f66ff66ff66f666666ffffff5555555555fffffffffffaa99944f
fffff88888fffffffffff999999fffffffffffaaaafffffffbbbbbffbbbbffbbff66666ff66ff66f66ff66ff6ff6ffffffff55555555ffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff555555fffffffffffffffffffff
f66dffffffddddffffddddfffffdfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff555555fffffffffffff66ffffff
f6d5fffffdd66ddffddddd5fffddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555555ffffffffffff776f7f7f
fd55ffffddddddd5fd6dd65ffdddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5555555555fffffffffff666f6f6f
ff5fffffdd666dd5fddddd5fddddddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555ff55555ffffffffff666d6d66
dd5dddd5ddd66dd5ffddd5ff5dddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555ffff55555fffffffff66df6f6f
dd5d8d85ddd66dd5fff55ffff5dd5555ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff555ffffff555ffffffffffdddfdfdf
ddddddd5fd66665ffdddd55fff5dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5ffffffff5fffffffffffddffffff
55555555ff5555ffddddddd5fff5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000777aaa00000070000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000007aaa99aaa0007aa00000000000000000000077a000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000009aa9447aa0009a900000000000000000000097aa00000000000000
00000000000000000000000000000000000000000007aaa00000000000000007a00000000047a40097a0004940000000000000000000007aa900000000000000
000000000000000000000000000000000000000000097a900000000000000007a0000000007aa0007aa0000400000000000000000000007aa400000000000000
000000000000000000000000000000000000000000047a40000000000000077aaa000000007aa007aa9007aa007a0a00700007700000007a9000000000000000
00000000000000000000000000000000000000000007aa0000000007aaa00aaaaa000000007aaaaaa94007aa00aaaa00a0007a97770007aa4000000000000000
0000000000777aaaaaa0000000000000000000000007aa007a00007a9aa0097aa9000000007a99aaa40007aa0099a900a007aa47aa0007aa00007aaa00000000
0000000777aaa999aaaa000000000000000000000007aa07aaa0007a4aa0047a9400000007aa44aaa00007a90047a400a007a907aa007aa90007a99aa0000000
00000009aaaaa4449aaa00000000000000077aaa0007aaaa999007aa0aa0007a4000000007aa009aa0007aa4007a900a907aa407a9007aa4007aa447a0000000
00000004aaaa90004aaa00000077a000007aa9aa0007aaa9444007aaa990007a00a0000007aa004aaa007aa0007aa0a9407aa07aa4007a90009aaa0990000000
0000000097aa40000aaa000077aaaaa007aa94990007aaaa000007a99440007a0aa000007aaa000aaaa09aa0009aaa94009aaaaaaa07aa4007497aa440000000
0000000047aa00000aaa0007aa99aaa007aa4044000aa99aa00007a44aa0009aaa9000007aa9000999904990004999400049999aa90aaa007a047aa000000000
0000000007aa00007aa90007aa449aaa07aa0000007aa44aa0000aaaa99000499940000099940004444004400004440000044449940999009aa07aa000000000
0000000007aaa077aa94007aa9004aaa07aa000000aaa00aaa0009999440000444000000444000000000000000000000000000044004440049aaaa9000000000
0000000007aaaaaaaa40007aa4000aa90aaa00aa009a900999000444400000000000000000000000000000000000000000000000000000000499a94000000000
0000000007aaa9aaaaa0009aaa00aaa409aaaaa90049400444000000000000000000000000000000000000000000000000000000000000000044940000000000
0000000007aaa49aaaa0004aaa00aa90049999940004000000000000000000000000000000000000000000000000000000000000000000000000400000000000
0000000007aaa049aaaa0009aaaaa940004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007aaa0049aaaa00499999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007aaa0004aaaaa0044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007aaa0000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007aaaaa00444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007aaaa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007aa99400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007a9944000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000994400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb50000002044f444e44ee44242eefefefef4fef4f6fe767ee44244e4e4eef4e8e
bbbbbbbbbbbbbbbbbbbbbbbb77eff7777777e777bbbbbbbbbbbbbbbbbbbbbbbbe01000102244424244e4e4e4eefefee4f4fffefefefff7fffe47eefefe7ef4fd
bbbbbbbbbbbbbbbbbbbbb77f7fef6f4fef777fefef6bbbbbbbbbbbbbbbbbbbbb72000000022e242444242e44244fef4e4feeeeefefefff4fee4f4f8fffef8e4b
bbbbbbbbbbbbbbbbbb7777fffff4e4eefffff76efeff77bbbbbbbbbbbbbbbbbbb22010205042425242404ee44244fffefef4ff7ffefffef7fffffffffffefeeb
bbbbbbbbbbbbbbbb777fff4e4e4e4e4e4fefefefe6e6efe7bbbbbbbbbbbbbbbbbe202000000202052222444e2209444feee74eef4f4f4e6f4fefeeef7f6fe44b
bbbbbbbbbbbbbbb77ff4eeeefee6fef4fefef7f6ffef76ff6bbbbbbbbbbbbbbbbee100200000002442504248e25244eef4fffefffffefe7ffffefee77f7ff45b
bbbbbbbbbbbbb77fee84ee4eeeeeeeeeef4f4eef7e4f77ef7f7bbbbbbbbbbbbbbf440000000100052e2002024e44444fef4fefefef4f4fefefefff4f7f6fef0b
bbbbbbbbbbbb7ff84ef4fffffee6fffefeeee4f4ff77ffffff77bbbbbbbbbbbbbffe40001000204254404244444454fefffeffffefff7ffffffffffffffee8bb
bbbbbbbbbbb74e4e4e4f4feeefeeefef4e4f4eef77777fef7fef7bbbbbbbbbbbbbe7000000000200022502242222248f4eefef777fef6fe6ef4fef4f6fe744bb
bbbbbbbbbb7ef4fee444f8fefef6e4f4e444f7ff7feffffffef4f7bbbbbbbbbbbbff4100202020202042ee42445242eefff7fffffeff7ffffefffffff4e440bb
bbbbbbbbbf44ef442e44488eefef4544442244ef677feeef44444f6bbbbbbbbbbb4f4e000200052204024e222422224effe7777fefe7ffeeefefff7fef4f2bbb
bbbbbbbbf4e7ff84444484eefee74444444242efffffffffe44244febbbbbbbbbbbeee81202022e242414e4e42425244f7f7f7fffffffffffffffffff4f45bbb
bbbbbbb78e7f842224244e4e444e24222422222eee4fe6e7e422024f4bbbbbbbbbb940441224448e02044e442222222e67f7777f776f7ff7eeff47ff4e440bbb
bbbbbbe84ef44022424244eee4e242444242524474ee4ef77e5252feedbbbbbbbbbbfef4e2e244eee04ee444425252fff777f7f7f7ffffffffff77f4fee0bbbb
bbbbb644ee4425022424244eee442422242225244e242f4f775525ef4fbbbbbbbbbb4f4e7e444e44000444244e244e4f777777776f7f7f7fef7fff4fe920bbbb
bbbbb4eefee12052524244eeeefe424252425252424252feffffeefe4ffbbbbbbbbbbf74fee4eef2402022e44efefeff77777777f7fffffffffffff4444bbbbb
bbbb444e4e22020522222e4e444e220222222222022210044effeeee24eebbbbbbbbb44f4e4e4f4402012e444f4f7f7f7777777f77efefefefefef4f45bbbbbb
bbbb425ee452522252424efeeef442545254e25020205052e484fefef4ffbbbbbbbbbbfeeefe44ffe22254e2444efff777f77777f7fff6fffffeffff40bbbbbb
bbb5222f4422220222244e44efee42242e6e2200050000022444294eee4a1bbbbbbbbbbf4fefeeeee4428f4e2fefffe7776f77777f7fffef4fef4fef0bbbbbbb
bbb24544e242525242424242eef84444424420202020204054e2402040445bbbbbbbbbbbfef7fff6feeee8eefefffff7f7fff777fffffffffff4fff4bbbbbbbb
bbd4222222222222022222224e44244f444e00001001000224220101242441bbbbbbbbbbbf4f7fefe7ee444e4f4eef4f7f77777f6fff4f4fefefef4bbbbbbbbb
bb524244424222524252525eee42504224e44010100050102220100152e4e1bbbbbbbbbbbbfff4fff4fee444fefffefff7f7ff7ffff7fffffffff4bbbbbbbbbb
bb020425022205222522252444220100044e2201000014454e010202244444bbbbbbbbbbbbbf4f4f4f4f4e47efefefef47f77fffff4fff4fefee4bbbbbbbbbbb
b520224222505020225252204041205044eee420111024feee50224254eeeedbbbbbbbbbbbbb94eefff4fff4fefffffff7fffffffffffffffef0bbbbbbbbbbbb
b5002514000224220224442500244e244fee4e2411120eee4e8402022eee4edbbbbbbbbbbbbbb84f484e4f4e8e4f4f4f8f4f7f7fefef6fff4e0bbbbbbbbbbbbb
b01042424020504244e4e44252e4f4fefef7eee4edf254f4fee2e25244f4e4ebbbbbbbbbbbbbbb4844f4e4fee498f4e4fffff7f7fffffff49bbbbbbbbbbbbbbb
b2000e220202244eee4e4e42244e8feeef7f8eef7fe44eeeef6ee4244e4eee4bbbbbbbbbbbbbbbbb444e8e4e8e444e4e4f4fef7fffe77f8bbbbbbbbbbbbbbbbb
b000524052204ee4eefeeee2228ee8feffffffff77f4e4eefeffe4e4e4fefffbbbbbbbbbbbbbbbbbbb444ee4eee4fef4fffefffefff49bbbbbbbbbbbbbbbbbbb
2100000224022e4e4fee44420224244fefef7fef7fee4e4f4f4f4eef44ee4e4ebbbbbbbbbbbbbbbbbbbbb484444e4eefeeef8fef444bbbbbbbbbbbbbbbbbbbbb
e2101020424244e4e4944242524444fffffffef7e7feeefee4eefef4e4feeefebbbbbbbbbbbbbbbbbbbbbbbb4894f4f4ffff4440bbbbbbbbbbbbbbbbbbbbbbbb
5400020224240444ee4e2424244eee4eef67ffef677fffee444eefee4fef4fedbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0004bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
d000102054ee5244eee4e2524eeefefefff7fff77ff7f7f4444ef4fe4ef4eee2bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
00020000241600a160261600e1602716012160281601616029160181502a1501b1502b1501d1502c1501f1402c140211402d140231302d130251302d120271202d110291102d1002c1002d100011002c10000100
00100000016600246003660044000560006400076001d6001260014600106000f6000e6000d6000c6000b60009600076000560005600046000360000600006000060000600006000060000600006000060000600
000a00000d0700d0400d0200d0100d0100d0100d01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c7701c7701c7701c7701c7701c7701c7701c770237702377023770237702377023770287702f7702f7702f7702f7602f7502f7402f7302f7202f7102f71007700087000070000700007000070000700
002000001417014170141701317013170131501215012150121501115011150111501115011140111401113011120111100010000100001000010000100001000010000100001000010000100001000010000100
000200000b1700f150061400613006120061200612006110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
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
000200000a04005020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000127701d770127402e70002700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
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
