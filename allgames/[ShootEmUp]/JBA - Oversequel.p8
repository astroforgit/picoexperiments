pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--hacky rushed ludum dare code
--don't judge me

daystart_timer = 0
daystart_text_offset = 128
player_health = 15
function daystart_draw()
	daystart_timer += 1
	cls(13)
if day <= 10 then	daystart_text = [[

	
	            day ]].. day ..[[
	
  this man is your target
  kill him before he kills you

             wanted


			 
			 
			 
			 
          dead or alive
			 
        reward:$]] .. reward .. [[
	]] elseif day == 11 then daystart_text = [[
	

		ok, this is my last order.
		you have done well this far.
		this might just be the
		strongest foe you've met.


			 
			 
			 
			 
			 
			 						best of luck!
]] else daystart_text = [[
	

		        --credits--
		
		code: anton petrochenko
		graphics: david bykov


			 
			 
			 
			 
			 
			 						   the end.
			 						
		 	thank you for playing!
]] 
if flr(time()%2) == 0 then target.features = shuffle_features() end
end
	print(daystart_text,daystart_text_offset,0,1)
	draw_character(64+daystart_text_offset,64,target.features)
	daystart_text_offset *= 0.95
	if daystart_timer < 60 then
		reward = flr(rnd(65535))
	end
	if (btn(5) or btn(4)) and daystart_timer > 60 then
		music(0)
			if day > 11 then run() end
		_draw = game_draw
		_update60 = game_update60
	end
end

player_features = {hat = 0, face = 0, body = 0, legs = 0, left_eye = 5, right_eye = 5, hair = 5}
editor_modes = 
{
	"hat", "face", "body", "legs", "left_eye", "right_eye", "hair"
}
editor_limits =
{
	5,5,5,5,8,8,14
}
selected_mode = 1
tutorialstring = [[

”ƒ - select
‹‘ - change value
Ž   - change skin tone
—   - confirm
]]
function editor_draw()
	camera(0,-16)
	print("create your disguise",8,-7,1)
	print("create your disguise",8,-8,7)
	for i=0,512 do
		x = flr(rnd(128))
		y = flr(rnd(128))
		pset(x,y,pget(x,y-1))
		pset(x,y-1,0)
	end
	for i,v in pairs(editor_modes) do
		print(v .. ": " .. player_features[v],9,8*i+1,1)
		print(v .. ": " .. player_features[v],9,8*i,7)
	end
	print(tutorialstring,9,65,1)
	print(tutorialstring,9,64,7)
	spr(39,0,selected_mode*8)
	draw_character(88,36,player_features)
end

function editor_update()
	if (btnp(ƒ))	selected_mode+=1
	if (btnp(”))	selected_mode-=1
	if selected_mode < 1 then
		selected_mode = 7
	end
	if selected_mode > 7 then
		selected_mode = 1
	end
	
	if btnp(‘) then
		player_features[editor_modes[selected_mode]] += 1
	end
	if btnp(‹) then
		player_features[editor_modes[selected_mode]] -= 1
	end
	player_features[editor_modes[selected_mode]] %= editor_limits[selected_mode]+1
	if btnp(—) then
		start_day()
	end
	if btnp(Ž) then
		player_features.black = not player_features.black
	end
end
function start_day()
	bullets = {}
	music(28)
	day += 1
	player_health = min(player_health+5,16)
	daystart_timer = 0
	daystart_text_offset = 128
	hunters = {}
	create_hunter(1,64,64,player_features,player_brain)
	hunters[1].features.black = false

	for i=0,10 do
		create_hunter(2,40*8,35*8,shuffle_features(),wander_brain)
	end
	reward = 0
	target = hunters[mid(2,flr(rnd(#hunters)),#hunters)]
	_draw = daystart_draw
	_update60 = empty
end

function draw_gameover()
	music(-1)
	for i=0,512 do
		x = flr(rnd(128))
		y = flr(rnd(128))
		pset(x,y,pget(x,y-1))
		pset(x,y-1,0)
	end
	gmtimer += 1
	if gmtimer > 30 then
		print("you died",32,65,1)
		print("you died",32,64,7)
		print("days survived: " .. day,32,64+7,1)
		print("days survived: " .. day,32,64+6,7)
		if btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5) then
			run()
		end
	end
end
gmtimer = 0
_draw = daystart_draw

ask_text = {
	"over there?",
	"i think that way",
	"that way?",
	"he's there",
	"that way",
	"-->",
	"<--",
	"blah blah",
	";)",
	"get lost",
	"go away",
	"flob you"
}

you_text = {
	"it's me!",
	"you're dead!",
	"prepare yourself!",
	"nghaaaaah!",
	"raaah!",
	"pls no kill ;-;"
}

ask_text[0] = "huh?"
you_text[0] = "huh?"
textparticles = {}

bossbar = 0
bossbar_max = 16

day = 0

function textparticle_update(this)
	this.x+=sin(this.angle)*this.speed
	this.y+=cos(this.angle)*this.speed
	this.speed*=0.9
	if this.speed < 0.1 then
		del(textparticles,this)
	end
end

function textparticle_draw(this)
	pal()
	if this.text == "arrow" then
		line(1+this.x,1+this.y,1+this.x+sin(this.angle)*8,1+this.y+cos(this.angle)*8,1)
		line(1+this.x+sin(this.angle-0.10)*6,1+this.y+cos(this.angle-0.10)*6,1+this.x+sin(this.angle)*8,1+this.y+cos(this.angle)*8,1)
		line(1+this.x+sin(this.angle+0.10)*6,1+this.y+cos(this.angle+0.10)*6,1+this.x+sin(this.angle)*8,1+this.y+cos(this.angle)*8,1)
		
		line(this.x,this.y,this.x+sin(this.angle)*8,this.y+cos(this.angle)*8,7)
		line(this.x+sin(this.angle-0.10)*6,this.y+cos(this.angle-0.10)*6,this.x+sin(this.angle)*8,this.y+cos(this.angle)*8,7)
		line(this.x+sin(this.angle+0.10)*6,this.y+cos(this.angle+0.10)*6,this.x+sin(this.angle)*8,this.y+cos(this.angle)*8,7)
	else
		print(this.text,this.x+1,this.y+1,1)
		print(this.text,this.x,this.y,7)
	end
end

function create_textparticle(x,y,angle,speed,text)
	length = #text
	new_textparticle = {
		x = x-length/2*4,
		y = y,
		angle = angle,
		speed = speed,
		text = text,
		update = textparticle_update,
		draw = textparticle_draw
	}
	add(textparticles,new_textparticle)
end


function empty()

end

bullets = {}

function bullet_update(this)
	for attrib in all(this.attribs) do
		attrib(this)
	end
	this.x+=sin(this.angle)*this.speed
	this.y+=cos(this.angle)*this.speed
	
	if fget_at(this.x,this.y,0) then 
		del(bullets,this)  
		create_textparticle(this.x,this.y,rnd(),rnd(),"pop")
	end
end

function bullet_draw(this)
	circfill(this.x,this.y,2,2)
	circfill(this.x,this.y,1,6)
	
end

function create_bullet(team,x,y,angle,attribs)
	create_textparticle(x,y,rnd(),rnd(),"pew")
	new_bullet = {}
	new_bullet.team = team
	new_bullet.x = x
	new_bullet.y = y
	new_bullet.angle = angle
	new_bullet.speed = 2
	new_bullet.draw = bullet_draw
	new_bullet.update = bullet_update
	new_bullet.attribs = attribs
	if day > 10 and team == 99 then
		add(attribs,megaboss_bullet)
	end
	add(bullets,new_bullet)
end


function point_direction(x1,y1,x2,y2)
	return atan2(y2 - y1, x2 - x1)
end

function shuffle_features()
	return {
		hat = flr(rnd(6)),
		face = flr(rnd(6)),
		body = flr(rnd(6)),
		legs = flr(rnd(6)),
		left_eye = flr(rnd(8))+1,
		right_eye = flr(rnd(8))+1,
		hair = flr(rnd(15))
	}
end

function recircfill(x,y,s,c)
	rectfill(x-s/2,y-s/2,x+s/2,y+s/2,c)
end


function fget_at(x,y,f)
	return fget(mget(flr(x/8),flr(y/8)),f)
end

t = 0
cx = 0
cy = 0

function draw_gun(x,y,angle,this)
	if flr(angle*2)%2==0 then
		yom = -1
		angle *= -1
	else
		yom = 1
	end
	
	x_offset = sin(angle) * yom
	y_offset = cos(angle)
	--barrel
	bs = 1.5
	col = false
	for i=-5,10 do
		if fget_at(x+x_offset*i,y+y_offset*i,0) then
			x -= x_offset
			y -= y_offset
		end
	end
	recircfill(x,y,bs,6)
	recircfill(x+x_offset*2,y+y_offset*2,bs,6)
	recircfill(x+x_offset*4,y+y_offset*4,bs,6)
	recircfill(x+x_offset*6,y+y_offset*6,bs,6)
	this.gunpoint_x = x+x_offset*6
	this.gunpoint_y = y+y_offset*6
	x_offset = sin(angle+0.25) * yom
	y_offset = cos(angle+0.25)
	recircfill(x+x_offset*2,y+y_offset*2,bs,1)
	x_offset = sin(angle+0.30) * yom
	y_offset = cos(angle+0.30)
	recircfill(x+x_offset*4,y+y_offset*4,bs,1)
	x_offset = sin(angle+0.15) * yom
	y_offset = cos(angle+0.15)
	circ(x+x_offset*3,y+y_offset*3,bs,6)
	
	
end

function draw_character(x,y,features,flip)
	if features.black then
		if (not poster) pal(15,1) 
	end
	if features.black then
		pal(14,0)
	end
	if (not poster) pal(5,features.hair)
	if flip then
		draw_left_eye,draw_right_eye = features.right_eye,features.left_eye
	else
		draw_left_eye,draw_right_eye = features.left_eye,features.right_eye
	end 
	spr(features.hat,x-4,y-18,1,1,flip)
	
	spr(32+features.body,x-4,y-4,1,1,flip)
	
	spr(16+features.face,x-4,y-10,1,1,flip)
	spr(48+features.legs,x-4,y+4,1,1,flip)
	if (not poster) pal(1,0)
	spr(7+draw_left_eye,x-6,y-11,1,1,flip)
	spr(7+draw_right_eye,x-2,y-11,1,1,flip)
	if (not poster) pal(1,1)
	if (not poster) pal(5,5)
	if (not poster) pal(15,15)
	pal(14,14)
end




hunters = {}

function hunter_draw(this)

	while this.features.hat == target.features.hat and
		  this.features.face == target.features.face and
		  this.features.body == target.features.body and
		  this.features.legs == target.features.leg and
		  this.features.left_eye == target.features.left_eye and
		  this.features.right_eye == target.features.right_eye and
		  this.features.hair == target.features.hair and
		  this.features.black == target.features.black
	do
	this.features = shuffle_features()
	end
	if this.draw_gun then 
		if not this.aimlockat then
			draw_gun(this.x+this.xvel*8,this.y-10+this.yvel*8,this.direction,this)
		else
			direction = point_direction(this.x,this.y,this.aimlockat.x,this.aimlockat.y)
			draw_gun(this.x+sin(this.direction)*8,this.y-10+cos(this.direction)*8,this.direction,this)
		end
	end
	draw_character(this.x,this.y-this.z,this.features,this.left)
	if this.target then
		spr(6,this.x-12,this.y-10)
		spr(6,this.x+4,this.y-10,1,1,true)
		spr(7,this.x-4,this.y-18)
		spr(7,this.x-4,this.y-2,1,1,true,true)
	end
	pal(15,15)
end

function hunter_update(this)
	pset(this.x-4,this.y-10,7)
	pset(this.x+4,this.y-2,7)
	for bullet in all(bullets) do
		if bullet.team != this.team then
			if bullet.x > this.x-4  and bullet.x < this.x+4 and
			   bullet.y > this.y-10 and bullet.y < this.y-2
			then
					if this == target then
						provoke(this)
						this.aimlockat = hunters[1]
						hunters[1].aimlockat = this
						hunters[1].target = true
						this.target = true
					end
				this.health -= 1
				sfx(9)
				create_textparticle(this.x,this.y,0.5,2,"ouch!")
				if this.health < 0 then
					del(hunters,this)
					if this == target then
						sfx(10)
						music(-1)
						for i=0,32 do
							rectfill(64-i*2,0,64+i*2,128,13)
							flip()
						end
						start_day()
					end
				end
				del(bullets,bullet)
				
			end
		end
	end
	
	
	local xcol = false
	local ycol = false
	for i=-10,8 do
		if fget_at(this.x+this.xvel,this.y+i,0) then
			xcol = true
		end
		if fget_at(this.x,this.y+this.yvel+i,0) then
			ycol = true
		end
	end
	
	if not xcol then this.x += this.xvel end
	if not ycol then this.y += this.yvel end
	
	if fget_at(this.x,this.y+8,4) then
		this.y += 110
	end
	if fget_at(this.x,this.y-10,5) then
		this.y -= 110
	end
	
	
	this.xvel *= 0.9
	this.yvel *= 0.9
	this.z = abs(sin(t/3))*this.walkoffset
	if abs(this.xvel) > 0.1 or abs(this.yvel) > 0.1 then
		if this.walkoffset < 3 then
			this.walkoffset += 0.25
		end
	else
		if this.walkoffset > 0 then
			this.walkoffset -= 0.5
		end
	end
	this:brain()
	if not this.aimlockat then
		if not btn(4) then
			this.direction = point_direction(this.x,this.y,this.x+this.xvel,this.y+this.yvel)
		end
	else
		this.direction = point_direction(this.x,this.y,this.aimlockat.x,this.aimlockat.y)
	end
	
	if this.xvel < -0.3 then
		this.left = true
	end
	if this.xvel > 0.3 then
		this.left = false
	end
end
--sqrt((this.x-v.x)^2+(this.y-v.y)^2)
function player_brain(this)
	if this.health < 16 then
		this.health = 16
		player_health -= 1
	end
	cx = this.x-64
	cy = this.y-64
	this.draw_gun = true
	local spd = 0.1
	if not btn(4) then
		pscd = -1
	end
	if btn(”) then this.yvel -= spd end
	if btn(ƒ) then this.yvel +=  spd end
	if btn(‹) then this.xvel -= spd end
	if btn(‘) then this.xvel +=  spd end 
	if btn(4) and pscd < 0 then
		pscd = 15
		sfx(0)
		local modifiers = {}
		add(modifiers,fast_bullet)
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,this.direction,modifiers)
	end
	if btnp(5) then
		for hunter in all(hunters) do
			if hunter[1] != this then
				if this.x > hunter.x-32 and this.x < hunter.x+32 and
				   this.y > hunter.y-32 and this.y < hunter.y+32 and hunter != hunters[1]
				then
					if hunter == target then
						create_textparticle(hunter.x,hunter.y,0.5,4,you_text[flr(rnd(#you_text))])
						provoke(hunter)
						this.aimlockat = hunter
						this.target = true
						hunter.target = true
					else
						if rnd()<0.1 then
							hunter.brain = angry_brain
							hunter.fire_timer = 60
							hunter.aimlockat = this
							sfx(11)
							create_textparticle(hunter.x,hunter.y,0.5,4,"it's you!!!")
							hunter.draw_gun = true
						end
						create_textparticle(hunter.x,hunter.y,0.5,4,ask_text[flr(rnd(#ask_text-2))])
						create_textparticle(hunter.x,hunter.y,point_direction(this.x,this.y,target.x,target.y)+rnd(0.3)-0.15,4,"arrow")
					end
				end
			end
		end
	end
	this.xvel = mid(-0.7,this.xvel,0.7)
	this.yvel = mid(-0.7,this.yvel,0.7)
end


function angry_brain(this)
	this.fire_timer -= 1
	direction = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
	if this.fire_timer < 0 and not hunters[1].target then 
		mods = {}
		add(mods,slow_bullet)
		create_bullet(2,this.gunpoint_x,this.gunpoint_y,direction,mods)
		this.fire_timer = 120+rnd(60)
		sfx(0)
	end
	mult = 1
	if hunters[1].target then mult = -1 end
		this.xvel = sin(direction)/5*mult
		this.yvel = cos(direction)/5*mult
end

function provoke(this)
	if not this.battling then
		music(5)
		this.health = 16 + day*5
		bossbar_max = this.health
		this.battling = true
		this.brain = boss_brain
		this.bosstimer = 0
		this.team = 99
		this.bossammo = 10
		this.draw_gun = true
		this.aimlockat = hunters[1]
	end
end


patterns = {
	function (this)
		sfx(1)
		create_textparticle(this.x,this.y,0.5,4,"trickshot!")
		local rangle = rnd()
		for i=0,1,0.2 do
			modifiers = {} 
			add(modifiers,swirling_bullet)
			add(modifiers,despawning_bullet)
			create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,i+rangle,modifiers)
		end
		if rnd()<0.2 then this.bosstimer -= 20 end
	end,
	function (this)
		sfx(8)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle,{})
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle+0.15,{})
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle-0.15,{})
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle+0.10,{})
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle-0.10,{})
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle+0.05,{})
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle-0.05,{})
	end,
	function (this)
		sfx(2)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		create_textparticle(this.x,this.y,0.5,4,"shrapnel!")
		modifiers = {}
		add(modifiers,shrapnel_bullet)
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle,modifiers)
		if rnd()<0.2 then this.bosstimer -= 20 end
	end,
	function (this)
		sfx(3)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		create_textparticle(this.x,this.y,0.5,4,"wahaha!")
		modifiers = {}
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle,modifiers)
		this.xvel += rnd(8)-4
		this.yvel += rnd(8)-4
		this.bosstimer +=60
	end,
	function (this)
		sfx(4)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		modifiers = {}
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle,modifiers)
		if this.bossammo < 1 then
			create_textparticle(this.x,this.y,0.5,4,"hah!")
			this.bossammo = 10 + rnd(5)
		else
			this.bossammo -= 1
			this.bosstimer -= 30
		end
	end,
	function (this)
		sfx(5)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		modifiers = {}
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle,modifiers)
		if this.bossammo < 1 then
			this.bossammo = 10 + rnd(10)
			create_textparticle(this.x,this.y,0.5,4,"hahaaa!")
		else
			this.bossammo -= 1
			this.bosstimer -= 15
		end
	end,
	function (this)
		sfx(6)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		modifiers = {}
		create_bullet(this.team,this.gunpoint_x,this.gunpoint_y,shootangle-rnd(0.5)+0.25,modifiers)
		if this.bossammo < 1 then
			this.bossammo = 5 + rnd(5)
			create_textparticle(this.x,this.y,0.5,4,"woooooo!")
		else
			this.bossammo -= 1
			create_textparticle(this.x,this.y,0.5,4,"blah!")
			this.bosstimer -= 15
		end
	end,
	function (this)
		sfx(7)
		local shootangle = point_direction(this.x,this.y,hunters[1].x,hunters[1].y)
		modifiers = {}
		add(modifiers,fast_bullet)
		offsetx = sin(shootangle)
		offsety = cos(shootangle)
		for i=0,10,2 do
			create_bullet(this.team,this.gunpoint_x+offsetx*i,this.gunpoint_y+offsety*i,shootangle,modifiers)
		end
		create_textparticle(this.x,this.y,0.5,4,"snipe!")
	end,
}

function swirling_bullet(this)
	this.angle += 0.01
end

function despawning_bullet(this)
	if not this.timer then
		this.timer = 0
	end
	this.timer += 1
	if this.timer > 30 then
		create_textparticle(this.x,this.y,rnd(),2,"*")
		create_textparticle(this.x,this.y,rnd(),2,"*")
		create_textparticle(this.x,this.y,rnd(),2,"*")
		this.attribs = {}
	end
end

function boss_brain(this)
	bossbar = this.health
	if day <= 10 then this.bosstimer += 1 + day/5
	else this.bosstimer += 1.5 end
	if this.bosstimer > 110 and this.bosstimer < 120 then
		this.bosstimer = 120
		patterns[this.features.left_eye](this)
	end
	if this.bosstimer > 230 and this.bosstimer < 240 then
		this.bosstimer = 240
		patterns[this.features.right_eye](this)

	end
	if this.bosstimer > 300 then
		this.bosstimer = 0
		this.xvel+=rnd(5)-2.5
		this.yvel+=rnd(5)-2.5
	end
end

function wander_brain(this)
	if not this.timer then this.timer = 0 end
	this.timer += 1
	if this.timer > 0 then
		this.timer = -rnd(150)
		this.xforcedir = (rnd(2)-1)*1.2
		this.yforcedir = (rnd(2)-1)*1.2
	end
	this.xvel = this.xforcedir
	this.yvel = this.yforcedir
	if fget_at(this.x,this.y+8,0) then
		this.xforcedir *= -1
		this.yforcedir *= -1
	end
	if rnd(10000)<2 then
		this.brain = angry_brain
		this.draw_gun = true
		this.aimlockat = hunters[1]
		this.fire_timer = 60
	end
end

function null_brain(this)

end

function create_hunter(team,x,y,features,brain)
	new_hunter = {}
	new_hunter.gunpoint_x = -99
	new_hunter.gunpoint_y = -99
	new_hunter.direction = 0
	new_hunter.team = team
	new_hunter.x = x
	new_hunter.left = false
	new_hunter.y = y
	new_hunter.xvel = 0
	new_hunter.yvel = 0
	new_hunter.walkoffset = 0
	new_hunter.z = 0
	new_hunter.features = features
	new_hunter.brain = brain
	new_hunter.health = 2
	new_hunter.update = hunter_update
	new_hunter.draw = hunter_draw
	new_hunter.aimlockat = nil
	new_hunter.draw_gun = false
	if rnd()<0.1 then
		new_hunter.features.black = true
	else
		new_hunter.features.black = false
	end
		
	add(hunters,new_hunter)
end

function slow_bullet(this)
	this.speed = 1
end

function game_draw() -----
	cls()
	
	
	camera(
		mid(0,cx,128*3),
		mid(0,cy,128+54)
	)
	map(0,0,0,0,128,128)
	for v in all(hunters) do
		v:draw()
	end
	for v in all(bullets) do
		v:draw()
	end
	for v in all(textparticles) do
		v:draw()
	end
	camera(0,0)
	rectfill(0,0,13,24,13)
	
	for i=0,16 do
		pal(i,0)
	end
	poster = true
	for x=-1,1 do
		for y=-1,1 do
			draw_character(7+x,15+y,target.features)
		end
	end
	pal()
	poster = false
	draw_character(7,15,target.features)
	print("target",1,17+4+6,1)
	print("target",0,16+4+6,7)
	print("day " .. day,1,17+4+6+6,1)
	print("day " .. day,0,16+4+6+6,7)
	if bossbar > 0 then
		rectfill(13,0,13+bossbar_max,8,1)
		rectfill(13,0,13+bossbar,8,8)
	end
	for i=0,16 do
		heart = 54
		if i > player_health then
			heart = 55
		end
		spr(heart,120,i*8)
	end
	print(
[[(z) shoot
(x) talk
”ƒ‹‘ walk]],1,128-15-2,1)
	print(
[[(z) shoot
(x) talk
”ƒ‹‘ walk]],0,128-16-2,7)
end
pscd = 10
function game_update60()
	pscd -= 1
	if player_health < 0 then
		_draw = draw_gameover
		_update60 = empty
	end
	t+=0.1
	for v in all(hunters) do
		v:update()
	end
	for v in all(bullets) do
		v:update()
	end
	for v in all(textparticles) do
		v:update()
	end
end

function fast_bullet(this)
	this.speed = 5
end

function shrapnel_bullet(this) 
	create_textparticle(this.x,this.y-4,rnd(),1,".")
	if fget_at(this.x+sin(this.angle)*this.speed,this.y+cos(this.angle)*this.speed) then
		create_bullet(this.team,this.x,this.y,this.angle+0.45,{})
		create_bullet(this.team,this.x,this.y,this.angle-0.45,{})
		create_bullet(this.team,this.x,this.y,this.angle-0.5,{})
	end
end

function megaboss_bullet(this)
	this.speed += 0.05
	if fget_at(this.x+sin(this.angle)*this.speed,this.y+cos(this.angle)*this.speed) then
		for i=0,rnd(5) do
			mods = {}
			add(mods,slow_bullet)
			create_bullet(5,this.x,this.y,point_direction(this.x,this.y,hunters[1].x,hunters[1].y),{})
		end
	end	
end

function refuse_bullet(this)
	this.attrib = {}
end
function _update60()

end

box_angle = 0
display_text = ""
function _draw()
	fade = {7,6,13,1}
	cls()
	if time()>1 then
		cls(fade[flr(time()*5)-10])
	end
	if fade[flr(time()*5)-10] == 7 then
		box_open = true
		display_text = "cardboard box"
		sfx(13)
	end
	box_angle += 0.01
	pr = box_angle
	sc = box_angle+0.25
	cut = box_angle+0.125
	prx = sin(pr)
	pry = cos(pr)
	scx = sin(sc)
	scy = cos(sc)
	cutax = sin(cut+0.25)
	cutay = cos(cut+0.25)
	cutbx = sin(cut+0.5+0.25)
	cutby = cos(cut+0.5+0.25)


	if box_open then
	camera(-64,-64+8)	
	
	line(prx*16,pry*8,scx*16,scy*8)	
	line(-prx*16,-pry*8,-scx*16,-scy*8)

	
	line(prx*16,pry*8,prx*16,pry*8+16)
	line(-prx*16,-pry*8,-prx*16,-pry*8+16)
	line(-scx*16,-scy*8,-scx*16,-scy*8+16)
	line(scx*16,scy*8,scx*16,scy*8+16)
	else
		camera(-64,-64)	
	line(cutax*10,cutay*6,cutbx*10,cutby*6)
	end
	
	
	camera(-64,-64)
	line(prx*16,pry*8,scx*16,scy*8)
	line(-prx*16,-pry*8,scx*16,scy*8)
	line(-prx*16,-pry*8,-scx*16,-scy*8)
	line(prx*16,pry*8,-scx*16,-scy*8)
	
	line(prx*16,pry*8,prx*16,pry*8+16)
	line(-prx*16,-pry*8,-prx*16,-pry*8+16)
	line(-scx*16,-scy*8,-scx*16,-scy*8+16)
	line(scx*16,scy*8,scx*16,scy*8+16)
	
	camera(-64,-64-16)
	line(prx*16,pry*8,scx*16,scy*8)
	line(-prx*16,-pry*8,scx*16,scy*8)
	line(-prx*16,-pry*8,-scx*16,-scy*8)
	line(prx*16,pry*8,-scx*16,-scy*8)
	camera(-64+#display_text/2*4,-64+26)
	print(display_text)
	if box_angle > 4 then
		_draw = editor_draw
		_update60 = editor_update
		camera(0,0)
	end
end
--start_day()
__gfx__
00000000000000000000000000000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000077777700000000000290000000000000009900000100000010000000000000000000000000000000000000000000000
00000000000000000000000000000000077777700000000000829000028888200097790000011000001000000000000000000000000000000000000000000000
00000000000000000000000000000000077777700000000000822900092222900977779000077000000110000007770000077000001110000001700000001000
0000000001111110000aa00000999900077777700000000000822900009229000977179000071000000110000007710000071000000010000007700000010000
008888000111111000aaaa0009999990077777700055555500829000000990000097790000000000000001000007770000000000000000000000000000001000
00881800088888800099990001111110011111105555555500290000000000000909900000000000000000000000000000000000000000000000000000000000
8888888811111111aaaaaaaa99999999777777775555555500000000000000000900000000000000000000000000000000000000000000000000000000000000
555ff555555ff555ffffffff555f5555555ff555555ff55544441151777444444444444451151151111111119999999499999995999999990000000000000000
5ffffff55ffffff5ffffffff55ffff555ffffff55feffff544447711777444444444444451151151111111119999999499999994999999990000000000000000
5fffffff5fffffffffffffff5ffffff55fffffff5fefffff44440711777444444444444454444441111111119999999594494494999239990000000000000000
ffffffffffffffffffffffffffffffffffffffffffefffff44447711777444444444444455444441111114519999999455555555993323990000000000000000
ffffffffffffffffffffffffffeffeffffffffffffefffff44440711666444444444444451544451111114519999999494494494992332990000000000000000
ffffeeff0fffeef0ffffeeffffeeeeffffffffff0fefeef044447711555555555555555551544451111114519999999594494494993339990000000000000000
0ffffff000fffff00ffffff0ffeffefffeeeeeef00effff044440711555555555555555551544451111114519999999455555555999999990000000000000000
000fff00000fff00000fff000ffffff00ffffff0000fff0044447711551111111111115551151151111114519999999494494494999999990000000000000000
022ffff2011ffff102ffff2f0fffffff077ffff7077ffff7444407110070000051151151aaa454aa111114519932339999933999aaaaa99a0000000000000000
2222ff2211111111f2ffff2fffffffff7777ff777777ff77555577110710000051555511aaa5444a144444519933339999332399a99aaaaa0000000000000000
222277221111191129222292ffffffff77777f7777777777555507110777777715544451aa4444aa144444519923339999333399aaaa99aa0000000000000000
222277221111111122222222fefffffe77777f7777777777545577117777111154454445a4444aaa144445519933332999333339aaaa99aa0000000000000000
222277221111191122222222ffffffff77777f777777177754545511777777005544545444445aaa155555519933333999323339a99aaa990000000000000000
222277221111111122222222ffffffff77777f7777777777554455117777110054555544a4a54aaa154115419933339999333329aaaa99aa0000000000000000
222277221111191122222222ffffffff77777f7777771777554555111777700054544454aaa44aaa154115419932339999333399aa99aaaa0000000000000000
222277221111111122222222ffffefff77777f7777777777554555510111100054544454aaa44aaa154115419933339999323399aaaaa99a0000000000000000
01100010110000010011001022220010011001002222222200000000000000005454454500000000000000000000000000000000511511510000000000000000
01100010011000100110001005500010011000100550055001101100011011005454454500000000000000000000000000000000511771510000000000000000
01100010011000100011001005500010011000100550055017818810100100105454454500000000000000000000000000000000511771510000000000000000
55500055555000550555005505000055555000550500005018888810100000105454454500000000000000000000000000000000511771510000000000000000
00000000000000000000000000000000000000000000000018888810100000105544445500000000000000000000000000000000577777710000000000000000
00000000000000000000000000000000000000000000000001888100010001005555555100000000000000000000000000000000517777510000000000000000
00000000000000000000000000000000000000000000000000181000001010005115115100000000000000000000000000000000511771510000000000000000
00000000000000000000000000000000000000000000000000010000000100005115115100000000000000000000000000000000511511510000000000000000
aaaaaaaaaaaaaaaaaaaaaaaa99999999999999991aaaaaa100000000000000005555555555555555aaaaaaaa44bbb44499999999000000004444444411113111
aaaaaaaaaaaaa3aaaaaaaaaa99999999399399991177771100000000000000005665666665666565aa8bbaaa5bbbbb559999999905000500438939b411133111
aaaaaaaaa3a3aaaaaaaaaaaa99995959993999391777777100000000000000005666666666666665aabbbaaa4bbbbb449449449950050505438939b4155a6551
aaaaaaaaaa3aaa3aaaa5a5aa95999599999399999757757900000440044000005666666666666665aabb8baa48bbb8445555555505000050444444445446a445
aaaaaaaaaaaaa3aaa5aa5aaa9959959999999399a777777a00044440044440005666666666666665aabbbbaa5bbbbb559449449950505005455355b454433445
aaaaaaaaaa3aaaaaaa5a5aaa9999999993999999a977779a00455540045554005666665666666565aa8bbaaa4bbbb8b4944944990550055043939ab454444445
aaaaaaaaaaa3aa3aaaaaaaaa9999999999399939aa7557aa44544540045445445666655666665565aa999aaa4bbbbbb4555555550055050043939ab415555551
aaaaaaaaaaaaaaaaaaaaaaaa9999999999999999aa9779aa45555540045555545555555555555555aaaaaaaa5bb8bbb594494499000550004444444411154111
99999999aaaaaaaa4444444444444444144444414444444445444540045444545555555555555555aabbbaaaa8bbb8aa99999999aaaaaaaa4444444451151151
95999599aa5555aa5555555555555555117777115555555545555540045555545666566550505055abbbbbaa8bbbbbaa99999999a5aaa5aa4939b39451151151
59959595a554445a4444444444444444177777714444444445444540045444545666566550505005abbbbbaabbb8bbaa999999995aa5a5a54939b39455559955
95999959544544454444444444444444475775744444444445555540045555545676576550505055a8bbb8aaabbbbbaa99999999a5aaaa5a4444444444449994
59595995554454555555555555555555557777555555555544454540045454445667567550505005abbbbbaaabbb8baa999999995a5a5aa54355b53444449944
95599559545555454445550000555444447777444444444400445540045544005666566550505055abbbb8ba9bbbbb9a99999999a55aa55a4398b33444444444
99559599545445454455000000005544447557445555555500044440044440005666566550505005abbbbbba9bbbbb9a99999999aa5595aa4398b33455555555
99955999545445455500000000000055555775555555555500000440044000005555555555555555abb8bbbaa99999aa99999999aa9559aa4444444444444444
66666661545444455444445444444544454444454444444455555555555555555555555551151151511511511111111151151151511511515115115151151351
61616161545445455555555555555555555555555555555544444444445444445766576551151151511555511111911151151151511511515115115151153351
61616161545445455444444444445444444444454444444444444444445444445666566551151151511511511555755155555555555555555555555555559d55
6161616154544445544444444444544444444445444444445555555555555555566756755115115151151151544474455444444444444444444444454444d944
61616161555444555555555555555555555555555555555544444444444454445666566551151151555511515444114554444444444444444444444544443344
61616161955555595444445444444544454444454444444444444444444454445666566551151151511511515444444554444444444444444444444544444444
61616161a999999a5444445444444544454444454444444455555555555555555666566551151151511511511555555155555555555555555555555555555555
66666661aaaaaaaa5555555555555555555555555555555555555555555555555555555551151151511511511115411115444444444444444444445144444444
51151666511511510000000000000000000000005149915155555555555555555555555551151151111111115155441115454444445444544454545144445444
51151656511aa5510000000000000000000000005444345154444444444444455444444555551151111111115155541115455444445444544454545145445454
511516565999aaa10000005555555555550000005144334154444444444444455444444551151551155995515111111115454444444444444444445144444444
5115165699999aaa0000055544544544555000005443344155555555555555555555555551155051544999455555115115444454444545444545445144544454
51151656999999aa0005545445444454454550004444334454444444444444455444444551150051544994455115115115444454444545444444445144544444
51151656999999aa0554554454444445445545504444334454444444444444455444444551155051544444455115555115555555555555555555555155555555
51151656511511515455444444444444444455455443344455555555555555555555555551151551155555515115115151151151511511515115115151151151
51151666511511515555555555555555555555555144345155555555555555555444444551151151111541115115115151151151511511515115115151151151
0404040404040404040404040404040404040404040404040404040404040404b504040404040404040404040404040404040404040404040404040404040404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404150404040404040404d50404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04045404040404040404045404040404040404040404040404040404040404040404040404040404040404040404040404040404160404040404240404041404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404040404a40404040404040404040404040454040404040404d50404040404040404040404040404042404040404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404042404150404040404040404040404040404040404040404040404040404040404040404040404040404a40404d50404040404040404240404040424
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040416040404040404040404040404040404040404040404040404a50404040404040404040404040404040404040404a404b40404140404d50404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040404a404040404040404040404040404a40404040404040404040404040404b5040404040404040404a4040404040404040404040404b50404040404040404
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404d50404042404
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
0100000000000000000000000000000000000000000001010101010001010000000000000000010001010101012200000000000000000000010000000010000002020200000101010101050501000101000101010101010101010505000001010101010101010101010000010101010100010101010101010100010001010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
786565636554654e5e5e4e5e5465637866666766666667665c6666666766666667666667666666675c76675e4e5e676666676654666766784c4c4c4c4c4c4c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7869696a69696969696969696969697866717169757569665c676917186919666769697a69691a6644766969696975766769696969697a78445c5c2c5c5c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
586a696969796c6f6d5f6d6f6d6e6a786769696a69696a6650666a69696969676679697b6a692a665c76696a6969697677696a696a697b585c5c432b5c44501b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7869796969697c7d7f7f7d7f7d7e697866696975696971674466696a696979696969696969696b665c6869696a6a696777694f69696969785c5c5c5c5c5c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7869696969696a69796969696969695866696969696a71665c5969697969696969696a4f69697b68507669796969696777697b6969796a695c5c5c5c5c431d1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7869697a79696969696b69696f696978666971696969696643666969696969696969697b696969665c76696969691a767769696a6969696a5c5c5c445c5c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
786a697b69696969697b69697b696978666969696a6a756650676917186a6966666a69696a6969674476166969692a76776969696969696a5c5c5c5c5c50431b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
58697969696a69696a7969696969697867286969696969665c6667666666676666286a69696969665c7626696a694f76776c6d5f6e69796a5c435c1d5c2c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7869696a6969696a69696969696a6a7866386a696969696643661718696919666638696c6e696a664467696969697b76677c7d7f7e6969785c5c5c5c5c2b5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
786969696a69696969696a6969696978666766607066676650596969796a69666769697c7e6969675c7667666969666777696a69697969675c505c43505c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
786a696969694f69696969696b69697858796969696a69665c66171869696969696a696969696966437617186969697677696969796969785c435c5c5c5c441b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78166a6969697b69796969697b6a69586669696a6a6a6a6644666a6969696a6969696969696969675c6769696a69696a69696969696969585c5c5c5c5c5c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7826696a69696a6969696a69696969786669696a6a6a6a585c5969697969696969696a69696969685076696a69696a6969697969696a69785c5c1d5c5c5c501b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
786969696a69696a696a697969696a786769796969696967506617186969796766696969696a6966435869696a6969696969696969284f785c445c5c505c431b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
786a6969696a69693d3d6969696969786669693d3d7969665c6769696a1969666769693d3d6969665c76691969696967773d3d6a69387b785c5c5c5c5c5c5c1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7667586667666877464776586766686766676646476658674c6666676667666666686646476758674c7666675866676677464776586667674c4c4c4c4c4c4c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000727373737373740000000000000000000000000000000000727373737373737373737373737374000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000626565636565640000000000000000000000000000000000626565636565656565656563656564000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7273737373737373737373737373737400626565636565640072737373737373737373737373737400626565656565656365656565656564000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62656565656365656563656565636564006268636565586400626565636565656365656563656564006265656865636565656565686565644d004d0000004d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62656563656565634849656365656564006565484965656400626565656365656563654849636564006265656365654849635465656365644c4c4c4c4c4c4c4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
626565655465636552536365655465644d626552536365644d6265636565656565636552536565644d626565656563656552536565656564445c5c5c5c505c4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6265586565656864464762586565686444626446476258645c6265596559656365686546476568645c6265656865656564464765686565645c5c505c5c5c445c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62656565634b656456576265656365644c626456576265644c624b656365656565636556576565644c62654b6565656564565763656565644c4c4c4c4c4c4c4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404a4041295b40412d2d4140404a41514040452d2d404a5140405b40414040404029402d2d5d41404042405b40404140402d2d5d404a4041404040404040424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404040404040404040404040404040614040404040404061404040404040404040404040404040404040405d404040404040404040404040402940405140404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404040404040404040404040404040402940404040404040404040405d4040404040404040405a4040404040404040404040404040404040404040406140405d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404040404040404040404040404040404040404040404040404040404040404040404040405b404040404040404040404040404040404a404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404040404040404040424040404040404040404040404040404040404040404040404040404040405d404040404040404040404040404040404042404140404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404040404040404040404042405a40404040404540404040404040404040404040404040404040404040404040404040405d404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404040414040404040404040405b4040404040404040404040404040404040404040404040404040404040404040404040404040404040405d4040404240404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404040404040404040404040404040404040404040404040404040404040405a4040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010e00001865500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
00040000096500b650200502005023050000002105000000000000000000000000002900026000000002600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000011650106501065012050110500e0500b05008040050400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000196501765016650156501465025050290502b0502c0502c0502c0502b05029050270502505023050210501e0501c0501a05019050190501b0501f0502505000000000000000000000000000000000000
000100002805025050200501a05015050110500d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003d0503c050370503505032050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000a6500f05014050190501c0501e6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000034640346403364031640306402f6402e6302d6302c6302b6302a6302963029630276202662025620246202362022620206201f6201e6201d6201c6201b62019620186201761014610146101260011600
000100003e6502e650216503f6502e650216503f6502e650206502205021050200501e0501f0501d0501c0501b0501a0501a0501a050190501805018050170501605015050150501405013050120501105000000
000100001f0501d0501905016050140500e0500805005050010500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000170501605015050140501305014050130501305013050120501105011050100500f0500f0500e0500d0500d0500c0500b0500b0500b0500a0500a0500905009050080500805007050070500605006050
000400002f050000002f050000002f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000c0501105013050180500c0401104013040180400c0301103013030180300c0201102013020180200c010110101301018010000000000000000000000000000000000000000000000000000000000000
010500000c0750000500005000050c075000050c075000050c0750000500005000050c075000050c075000050e0750000500005000050e075000050e075000050e0750000500005000050e075000050e07500005
010500000c0750000500005000050c075000050c075000050c0750000500005000050c075000050c075000050c0750000500005000050c075000050c075000050c0750000500005000050c075000050c07500005
011000000061600616006160061600616006160061600616006160061600616006160061600616006160062600636006460065600656006560065600656006460063600626006160061600616006160061600616
011000001505215052180521805218052180521a0521a0521a0421a0421a0321a0321a0221a0221a0121a01200002000020000200002000020000200002000020000200002000020000200002000020000200000
011000001505215052180521805218052180521a0521a0521a0521a0521d0521d0521c0521c0521a0521a0521a0521a0521805218052180521805215052150521504215042150321503215022150221501215012
0110000015052150521d0521d0521d0521d0521c0521c0521c0421c0421c0321c0321c0221c0221c0121c01200002000020000200002000020000200002000020000200002000020000200002000020000200002
011000001d0521d052150521505215052150521a0521a0521a0321a0321a0221a0221a0121a012000020000200002000020000200002000020000200002000020000200002000020000200002000020000200000
010500000e0550000500005000050e055000050e055000050e0550000500005000050e055000050e055000050e0550000500005000050e055000050e055000050e0550000500005000050e055000050e05500005
0105000000000000000000000000000000000000000000001305213052130521305213052000020000200002110521105200002000020e0520e0520000200002000020000200002000020e0520e0520e0520e052
010500000e0420e0420e0420e0420e0320e0320e0320e0320e0220e0220e0220e0220e0120e0120e0120e01200000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000000000000000000000000000000000000000000001305213052130521305200000000000000000000110521105200000000000e0520e05200000000000000000000000000000011052110521105211052
01050000110521105211052110521305213052130521305213052130521305213052110521105211052110521105211052110521105210052100521005210052100521005210052100520c0520c0520c0520c052
010500000c0520c0520c0520c0520c0420c0420c0420c0420c0320c0320c0320c0320c0220c0220c0220c0220c0120c0120c0120c012000000000000000000000000000000000000000000000000000000000000
010500000c0520c0520c0520c0520c0420c0420c0420c0420c0320c0320c0320c0320c0520c0520c0520c0520c0520c0520c0520c052100521005210052100521105211052110521105211052110521105211052
010500001005210052100521005210042100421004210042100321003210032100321002210022100221002210012100121001210012100001000010000100001000010000100001000010000100001000010000
000500001305213052130521305213042130421304213042130321303213032130321302213022130221302213012130121301213012100001000010000100001000010000100001000010000100001000010000
01050000110521105211052110520e0520e0520e0520e05200000000000000000000000000000000000000000e0520e05200000000000c0520c05200000000000000000000000000000000000000000000000000
010500001105211052110521105211052110521105211052130521305213052130521305213052130521305211052110521105211052110521105211052110521005210052100521005210052100521005210052
01050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090520905209052090520c0520c0520c0520c052
010500000e0520e0520e0520e0520e0420e0420e0420e0420e0320e0320e0320e0320e0220e0220e0220e0220e0120e0120e0120e012000000000000000000000000000000000000000000000000000000000000
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
01 11 10 43 44
00 12 10 43 44
00 13 10 43 44
02 11 10 43 44
00 41 42 43 44
01 15 42 43 44
01 15 42 43 44
00 15 16 43 44
00 15 17 43 44
00 15 18 43 44
00 15 19 43 44
00 0f 1a 43 44
00 0f 1b 43 44
00 15 1c 43 44
00 15 1d 43 44
00 15 1e 43 44
00 15 1e 43 44
00 15 1e 43 44
00 15 1f 43 44
00 15 1e 43 44
00 15 1e 43 44
00 15 1e 43 44
00 15 1f 43 44
00 0f 1c 43 44
00 0f 20 43 44
02 15 21 43 44
00 41 42 43 44
00 41 42 43 44
03 10 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
