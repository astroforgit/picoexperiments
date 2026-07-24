pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--bounceball: golf!
--the spinoff you never asked for!
--by twotwos
cartdata("twotwos_trickshot_0")
function _init()
	smoke={}
	balls = {}
	level_names = {"welcome to bounceball: golf!",
																"over and in",
																"remember to fine tune",
																"wonder what that thing does", 
																"climbing the tower",
																"that was too hard, i'm sorry",
																"so sorry",
																"ok, i'll make it easier",
																"two new mechanics in a row?",
																"threading the needle",
																"sit back and melax",
																"that's new",
																"fast and slow, high and low",
																"slow and fast, comes to pass",
																"something's wrong",
																"i'll turn it off and on again",
																"great, now where are we",
																"how are you reading this???"}
	score = 1
	t = 0
	clued = false
	game_speed = 1
	life_line = false
	respawn = false
	shakin = false
	gem =false
	ball_returned = 0
	ghost_path = {}
	state = "in between" --"level out", "in between", "level in", "level start"
	level = 0
	escape = 0
	escape_level = 16
	suspense = -60
	freetime = 0
	mercy = 100
	speed_mercy = 100
	cal_level =	22.1875
	holding = 0
	another_timer = 0
	caught = false
	score = 0 
	--why have i made so many variables
	--dear god
	cameron = {x=0,y=0,x_v=0,g_x_v=0}
	for i=1,1 do
		make_ball(100,100,rnd(10)-5,rnd(16)-8,2.5,9)
	end
--	define_paddle()
		

	--debug
	--escape = 332
	--level = 17
	--suspense = 0
	--mercy = 10
	--balls[1].x = 500
	--escape = 0
	--state = "in between"
	--level_names[cal_level+1] = "oh god what have you done"
	--level = cal_level
	if level >= escape_level then 
		clued = true
	 gem = true 
	end
	--if level <= 8 then gem = true end
	
	
	
	
	--debug
	if level == escape_level + 1 then
		state = "level"
		balls[1].size = balls[1].orig_size
		explode_ball(balls[1])
	end
	
	
	if not dget(0) then
		dset(0,0)
	end
	if not dget(1) then
		dset(1,0)
	end
end
function bounce(xvar,yvar,ball)
		local tiles = {}
		local s = ball.size/2
		add(tiles,nget(xvar/8,yvar/8))
		add(tiles,nget((xvar+s)/8,yvar/8))
		add(tiles,nget((xvar-s)/8,yvar/8))
		add(tiles,nget(xvar/8,(yvar+s)/8))
		add(tiles,nget(xvar/8,(yvar-s)/8))
		for tile in all(tiles) do
			if tile == 15 then
				return "next level"
			end
			if tile == 21 then
				sfx(12)
				for x=0,15 do
				 for y=0,15 do
		    if nget(x, y) == 21 then
		    	nset(x,y,0)
		    end
				 end
				end
				return "gem get"
			end
			if fget(tile,1) then
				--ball.x = (flr(ball.x/8)*8)+4
				--ball.y = (flr(ball.y/8)*8)+8
				return "succed"
			end
			if fget(tile,0)
			then
				--ball.bounce_last = true
				if fget(tile,2) then
					return true,1.5
				elseif fget(tile,3) then
					return true,0.2
				end
				return true,0.9
			end
		end
		return false,-1
end

function move_ball(ball)
	--make_smoke(ball.x,ball.y,1,6,25)
	
	--_,will_bounce = bounce(ball.f_x,ball.f_y,ball)
	--if will_bounce then
	--	ball.xdir = bounce(ball.f_x,ball.y,ball)
	--	ball.ydir,ball.jbv = bounce(ball.x,ball.f_y,ball)
	--end
	--ball.x,ball.y=ball.f_x,ball.f_y
	local air_resistance = 0.0011
	local prec = (flr(abs(ball.xdir))+flr(abs(ball.ydir)))/1.8+10
	local jbv = false
	local add_esc = false
	if ball.ghost then prec = 5 end
	for i=1,prec do
		local f_x = ball.x+(ball.xdir*game_speed/prec)
		local f_y = ball.y+(ball.ydir*game_speed/prec)
		if not ball.ghost then
			local x_bounce,x_sproing = bounce(f_x,ball.y,ball)
			local y_bounce,y_sproing = bounce(ball.x,f_y,ball)
			if x_bounce == "succed" or 
						y_bounce == "succed" then
				if not ball.gone then
					sfx(2)
				end
				--ball.sp_speed = 5
				--ball.sp_dir = (rnd(46)+2)/100
				life_line = ball
				primed = false
				break
			end
			if x_bounce == "next level" or 
						y_bounce == "next level" then
				--sfx(2)
				--ball.sp_speed = 5
				--ball.sp_dir = (rnd(46)+2)/100
				if not ball.gone then
					state = "level out"
					sfx(8)
					sfx(9)
				end
				break
			end
			if x_bounce == "gem get" or 
						y_bounce == "gem get" then
				sfx(21)
				gem = true
				break
			end
			if x_bounce then
				--don't move if bouncing
				ball.xdir *= -x_sproing
				if not ball.gone then
					sfx(0)
				end
				ball.hint +=1
			else
				ball.x = f_x
			end
			if y_bounce then
				--don't move if bouncing
				ball.ydir *= -y_sproing
				jbv = true
				ball.hint += 1
				if not ball.gone then
					sfx(0)
				end
			else
				ball.y = f_y
			end
		else
			add(ghost_path,{x=ball.x,y=ball.y})
			ball.y = f_y
			ball.x = f_x
		end
		if ball.xdir < 0 then
			ball.xdir += ((air_resistance*abs(ball.xdir^2))/prec)
		else
			ball.xdir -= ((air_resistance*abs(ball.xdir^2))/prec)
		end
		if ball.ydir < 0 then
			ball.ydir += ((air_resistance*abs(ball.ydir^2))/prec)
		else
			ball.ydir -= ((air_resistance*abs(ball.ydir^2))/prec)
		end

		if not ball.jbv then
			ball.ydir += 0.5/prec
		else
			ball.jbv = false
		end
		if ball.ydir > 220 then
			ball.ydir = 219
			if level == escape_level and 
						(ball.xdir>210 or 
						ball.xdir<-210) then
				add_esc = true
			end
		end
		if ball.xdir > 220 then
			ball.xdir = 219
			if level == escape_level and 
						(ball.ydir>210 or 
						ball.ydir<-210) then
				add_esc = true
			end
		end
		if ball.ydir < -220 then
			ball.ydir = -219
			if level == escape_level and 
						(ball.xdir>210 or 
						ball.xdir<-210) then
				add_esc = true
			end
		end
		if ball.xdir < -220 then
			ball.xdir = -219
			if level == escape_level and 
						(ball.ydir>210 or 
						ball.ydir<-210) then
				add_esc = true
			end
		end	
	end
	if add_esc then escape += 1 end
end



function _update()
	t += 1
	foreach(smoke,move_smoke)
	if state == "level" and 
				(not (life_line or respawn or paused)) then
		for ball in all(balls) do
			move_ball(ball)
			if (ball.y > 128+ball.size and level != escape_level+1) or
						ball.y < 0-ball.size or 
						(ball.x > 120+ball.size and level != escape_level+1) or
						ball.x < 8-ball.size then
				explode_ball(ball)
				if bottomgone and not padx then
					ready_paddle()
				end
			end
			if ball.y > 128+ball.size and level == escape_level+1 then
				if rnd(mercy) < 1 then
					return_ball(ball)
					sfx(2)
				else
					explode_ball(ball)
					mercy *= 0.96
				end
			end
		end
		if btn(4) and holding then
			holding += 1
		else
			holding = false
		end
		if btnp(4) and level != escape_level and (not holding) then
			explode_ball(balls[1])
		end
		--if level == escape_level + 1 then
		--	cameron.g_x_v = 1
		--end
	elseif life_line and not paused then
		move_life_line()
		cameron.g_x_v = 0.6
		cameron.speed = 0.6
	elseif respawn then
		freetime = 0
		respawn -= 1
		if respawn < 0 then
			respawn = false
			for ball in all(balls) do
				ball.gone = false
			end
		end
	elseif state == "level out" then
		for ball in all(balls) do
			ball.size *= 1.05
			ball.size += 1
			if ball.size >= 156 then
				state = "in between"
				level += 1
			end
		end
	elseif state == "in between" then
		if btnp(5) then
			balls[1].x,balls[1].y = place_ball()
			state = "level in"
			sfx(10)
			sfx(11)
			
		end
	elseif state == "level in" then
		for ball in all(balls) do
			ball.size /= 1.05
			ball.size -= 1
			if ball.size <= ball.orig_size then
				ball.size = ball.orig_size
				state = "level start"
			end
		end
	elseif state == "level start" then
	 life_line = balls[1]
	 state = "level"
	end
	--escape scene!
	if escape == 150 then
		weak_explode(50,100,20)
	elseif escape == 200 then
		weak_explode(60,12,21)
	elseif escape == 250 then
		weak_explode(70,70,22)
	elseif escape == 260 then
		weak_explode(10,100,23)
	elseif escape == 280 then
		weak_explode(80,64,24)
	elseif escape == 290 then
		weak_explode(64,30,25)
	elseif escape == 300 then
		weak_explode(40,90,26)
	elseif escape == 310 then
		weak_explode(60,64,27)
	elseif escape == 315 then
		weak_explode(90,100,28)
	elseif escape == 320 then
		weak_explode(70,20,29)
	elseif escape == 323 then
		weak_explode(23,25,30)
	elseif escape == 326 then
		weak_explode(100,64,31)
	elseif escape == 328 then
		weak_explode(34,110,32)
	elseif escape == 329 then
		weak_explode(120,5,33)
	elseif escape == 330 then
		weak_explode(64,64,34)
	elseif escape == 331 then
		weak_explode(64,64,35)
		level = escape_level+1
		escape +=1
	elseif escape == 332 then
		explode_ball(balls[1])
		escape = -1
		paused = true
		cameron.speed = 0
	end
	if level == escape_level+1 then
		if escape < 0 then
			escape -= 1
		end
		if escape < suspense-150 and escape >= suspense-151 then
			paused = false
			--cameron.g_x_v = 0.5
		elseif escape < suspense-151 then
			set_camera()
			if balls[1].x < cameron.x then
				deadness += 1
			else deadness = 0 end
			if deadness > 20 and not respawn then
				life_line = false
				explode_ball(balls[1])
				speed_mercy *= 0.99
				deadness = 0
			end
		end
	end
	--let me fix that for you
	if cameron.x == 664 then
		cameron.x = 0
		level = cal_level
		balls[1].x -= 664
	end
	--but wait, there's more
	if life_line and level == cal_level then
		--another_timer += 1
		caught = true
	elseif caught and 
								not leftgone and 
								balls[1].x < 30 and 
								balls[1].y < 30 then
		nset(0,0,18)
		nset(0,1,18)
		nset(0,2,18)
		weak_explode(4,12,25)
		leftgone = true
		if rightgone then caught = false end
	elseif caught and 
								not rightgone and 
								balls[1].x > 98 and 
								balls[1].y < 30 then
		nset(15,0,18)
		nset(15,1,18)
		nset(15,2,18)
		weak_explode(124,12,25)
		rightgone = true
		if leftgone then caught = false end
	elseif leftgone and
						 	rightgone and
						 	not topgone and 
						 	caught and
						 	primed and
						 	balls[1].y < 30 then
		nset(1,0,54)
		nset(0,0,3)
		nset(15,0,5)
		nset(14,0,55)
		nset(1,14,0)
		nset(7,7,16)
		for i = 2,13,1 do
			nset(i,0,39)
		end
		for i = 8,120,16 do
			weak_explode(i,4,5)
		end
		topgone = true
		--weak_explode(64,12,25)
	end
	if topgone and 
				balls[1].sp_dir > 0.5 and
				not bottomgone then
		bottomgone = true
		for i = 8,120,16 do
			weak_explode(i,124,5)
		end
		nset(0,15,18)
		nset(15,15,18)
		for i = 1,14,1 do
			nset(i,15,0)
		end
	end
end

function _draw()
	
	--rectfill(0,0,128,128,0)
	cls()
	camera(0,0)
	--debug
	--print(mercy,8,24,8)
	--print(balls[1].sp_dir,8,16,8)
	--line(30,0,30,128)
	--shake
	if shakin then
		camera(cameron.x+rnd(shakin)-shakin/2,
									cameron.y+rnd(shakin)-shakin/2)
		shakin *=0.95
		shakin -= 0.5
		--updating in _draw(), tsk tsk
		if shakin <= 1 then shakin = false end
	else
		camera(cameron.x,cameron.y)
	end
	--smoke
	foreach(smoke,draw_smoke)
	
	--print(balls[1].y, 12,12,15)
	--walls
	--line(0,0,0,127,8)
	--line(127,127)
	--line(127,0)
	--line(0,0)
	if level != escape_level+1 then
		nap(0,0,16,16)
	else
		nap(0,0,6000,16)
	end
	--balls

	--the lime
	if life_line and not paused then
		line(
	  	life_line.x,
	   life_line.y,
	   life_line.x+life_line.sp_speed^2*cos(life_line.sp_dir),
	   life_line.y+life_line.sp_speed^2*sin(life_line.sp_dir),
	   11
	  )
		if gem then
			for ghost in all(ghost_path) do
				pset(ghost.x,ghost.y,3)
			end
		end
  if level == 0 then
  	printc("hit Ž/z to launch",64,32,3,1)
			printc("hold ‹‘”ƒ to adjust",62,38,3,4)
		end--print(life_line.sp_dir, 12, 12, 15)
 	if level > 0 and level < 3 then
 		printc("hold — and ‹‘”ƒ",63,26,3,5) 
 		printc("to fine-tune shot",63,32,3,0)
 	end
 end
	for ball in all(balls) do
		if not ball.gone then
			circfill(ball.x,ball.y,ball.size,ball.color)
		end
	end
	--newgame
	if state == "in between" then
		printc(level_names[level+1], 65, 44, 12)
		print("hit — to begin", 36, 64, 7) 
	end
	--hint (not even all drawing)
	for ball in all(balls) do
		if ball.hint > 5 and not (life_line or ball.gone or clued) then
			printc("hit Ž/z to explode ball",ball.x,ball.y-12,8)
		end
	end
	if ball_returned > 0 then
		ball_returned -= 1
		printc("free ball!",balls[1].x,balls[1].y-12,7)
	end
	if holding and holding > 30 then
		if holding > 1000 then
			printc("you can stop now, there are",64,18,8)
			printc("no more messages here",64,28,8)
		elseif holding > 775 then
			printc("seriously?",64,18,8)
		elseif holding > 600 then
			printc("...",64,18,8)
		elseif holding > 375 then
			printc("please",64,18,8)
		elseif holding > 250 then
			printc("stop it",64,18,8)
		else
			printc("no need to hold z",64,18,8)
		end
	end
	pal()
	camera()
	if escape < suspense-30 and escape >= suspense-60 then --and escape > -35 then
		spr(64,48,48,4,4)
	elseif escape < suspense-60 and escape >= suspense-90 then
		spr(68,48,48,4,4)
	elseif	escape < suspense-90 and escape >= suspense-120 then
		spr(72,48,48,4,4)
	elseif escape < suspense-120 and escape >= suspense-150 then
		spr(76,48,48,4,4)
	end

end

	
-->8
--the smoke zone
function make_smoke(x,y,init_size,col,max_t)
	local s = {}
	s.x=x
	s.y=y
	s.col=6
	s.width=init_size
	s.width_final=init_size+rnd(2.5)+0.75
	s.t=0
	s.max_t=max_t+rnd(10)
	s.dx=(rnd(.8)-.4) --what
	s.dy=(rnd(0.5))
	s.ddy= .02
	add(smoke,s)
	return s
end

function move_smoke(sp)
	if (sp.t>sp.max_t) then
		del(smoke,sp)
	end
	if (sp.t>sp.max_t-(rnd(15)+15)) then
		sp.width+=1
		sp.width=min(sp.width, sp.width_final)
	end
	sp.x=sp.x+sp.dx
	sp.y=sp.y+sp.dy
	sp.dy=sp.dy+sp.ddy --sure
	sp.t =sp.t+1
end

function draw_smoke(s)
	circfill(s.x,s.y,s.width,s.col)
end

--yoinked from mozz's smoke particle tutorial
--with some changes
-->8
--oh whatever

function print_thicc(text,x,y,ic,oc,h) 
	for r=y-1,y+h+1 do for i=x-1,x+1 do print(text,i,r,oc) end end  
	print(text,x,y,ic)  
	--function by pixelï
end

function nget(x,y)
	return mget(x+(level%8)*16,y+flr(level/8)*18) 
end

function nset(x,y,tile)
	return mset(x+(level%8)*16,y+flr(level/8)*18,tile) 
end

function nap(three,four,five,six)
	return map((level%8)*16,flr(level/8)*18,three,four,five,six)
end

function acos(x) 
	return atan2(x,-sqrt(1-x*x))
end

function asin(y) 
	return atan2(sqrt(1-y*y),-y)
end
--thanks to a comment made by @rgb 4 years ago
-->8
--why do i need this stuff anyway
function make_ball(x,y,xdir,ydir,size,colour,ghost)
	local ball = {}
	ball.x = x
	ball.y = y
	ball.xdir = xdir
	ball.ydir = ydir
	ball.color = colour --what?
	ball.size = 156
	ball.orig_size = size
	ball.jbv = false
	ball.sp_dir = 0.3 --special dir
	ball.sp_speed = 5 --special speed
	ball.gone = false
	ball.hint = 0
	ball.ghost = ghost or false
	if not ball.ghost then
		add(balls, ball)
	end
	return ball
end


--with apologies to matt hughson
function printc(
	str,x,y,
	col,special_chars)
	local special_chars = special_chars or 0
	local len=(#str*4)+(special_chars*3)
	local startx=x-(len/2)
	local starty=y-2
	print_thicc(str,startx,starty,col,0,0)
end

-->8
--"organisation"
function move_life_line()
	local dir_speed = 0.007
	local	speed_speed = 0.2
	local max_speed = 9
	if (level == escape_level+1 and 
					balls[1].x > 500) then
		max_speed = 100
	elseif level == cal_level then
		max_speed = 12
	end
	if btn(5) 
	then dir_speed = 0.0014
					 speed_speed = 0.04
	--really clever variable names
	end
		
	if btn(1) 
		--and life_line.sp_dir > 0.01 
		then
		primed = false
		life_line.sp_dir -= dir_speed
	end
	if btn(0)
	 --and life_line.sp_dir < 0.49 
	 then
	 	primed = false
		life_line.sp_dir += dir_speed
	end
	if btn(2) and
			life_line.sp_speed < max_speed then
		life_line.sp_speed += speed_speed
		primed = false
	elseif life_line.sp_speed > max_speed then
		life_line.sp_speed = max_speed
	end
	if btn(3) and
			life_line.sp_speed > 0.2 then
		life_line.sp_speed -= speed_speed
		primed = false
	elseif life_line.sp_speed < 0.2 then
		life_line.sp_speed = 0.2
	end
	if life_line.sp_dir < 0 then 
		life_line.sp_dir += 1
	elseif life_line.sp_dir > 1 then
		life_line.sp_dir -= 1
	end
	if btnp(4) then
		holding = 0
		life_line.xdir=life_line.sp_speed*cos(life_line.sp_dir)
	 life_line.ydir=life_line.sp_speed*sin(life_line.sp_dir)
		life_line = false
		ghost_path = {}
		sfx(4)
	elseif gem then
		ghost_path = {}
		ghost_ball = make_ball(life_line.x,
												life_line.y,
												life_line.sp_speed*cos(life_line.sp_dir),
												life_line.sp_speed*sin(life_line.sp_dir),
												life_line.size,
												0,
												true)
		for i=1,100 do
			move_ball(ghost_ball)
			if ghost_ball.y < 8 then
				primed = true
			end
		end
	end
	
end

function place_ball() 
	for y=16,0, -1 do
	  for x=16,0, -1 do
	    if nget(x, y) == 16 then
	    	return x*8+4,y*8+4
	    end
	  end
	end
end

function explode_ball(ball)
	deadness = 0
	weak_explode(ball.x,ball.y,20)
	cameron.d_x = cameron.x
	clued = true
	ball.gone = true
	ball.x,ball.y=place_ball()
	state = "level start"
	respawn = 20
	
end

function weak_explode(x,y,power)
	for i=0,power+5 do
		make_smoke(x,y,1,6,25)
	end
	sfx(6)
	sfx(7)
	if not shakin then
		shakin = 0
	end
	shakin += power
end

function return_ball(ball)
	ball.sp_speed = sqrt(abs(ball.xdir)^2+abs(ball.ydir)^2)
	ball.sp_dir = asin(ball.ydir/ball.sp_speed)
	ball.sp_dir += 0
	ball.xdir = ball.sp_speed*cos(ball.sp_dir)
	ball.ydir = ball.sp_speed*sin(ball.sp_dir)
	sfx(14)
	ball_returned = 40
end
-->8
--crazy camera code

function set_camera()
	if cameron.x < 664 and level != cal_level then
		if freetime <= 0 then
			cameron.g_x_v = cameron.speed
		else 
			cameron.g_x_v = cameron.speed/3
			freetime -= 0.3
		end
		
		if balls[1].x > 500 then
			cameron.g_x_v = 2	
		end
		
		if cameron.g_x_v <= 0.009 and cameron.g_x_v >=-0.009 then
			cameron.g_x_v = 0
		end
		if cameron.x_v <= 0.009 and cameron.x_v >=-0.009 then
			cameron.x_v = 0
		end
		if cameron.x_v < cameron.g_x_v then
			cameron.x_v += 0.01
		elseif cameron.x_v > cameron.g_x_v then
			cameron.x_v -= 0.01
		end
		if respawn then
			--cameron.x = bezier_hell((20-respawn)/20,0.14,0.72,0.34,1.27)*cameron.d_x
			cameron.x = cameron.d_x-easinghell((respawn)/20)*cameron.d_x
			cameron.x_v = 0
		end
		if balls[1].x - cameron.x > 100 and balls[1].x < 760 then
			cameron.x = balls[1].x - 100
			freetime += 1
		end
		--664
		cameron.x += cameron.x_v*speed_mercy/100
	elseif level != cal_level then
		cameron.x = 664
	end
end
-->8
--what in god's name is this

function bezier_hell(t,x_2,y_2,x_1,y_1)
	
	--x_1 = 1-x_1
	--x_2 = 1-x_2
	--y_1 = 1-y_1
	--y_2 = 1-y_2
	return ((1-t)*((1-t)*((1-t)*1+t*x_1)+t*((1-t)*x_1+t*x_2))+t*((1-t)*((1-t)*x_1+t*x_2)+t*((1-t)*x_2)))
	--return x_1*(1-t)^3 + 3*y_1*(1-t)^2*t + 3*x_2*(1-t)*t^2 + y_2*t^3
end
--produces an animation curve 
--almost, but not entirely 
--unlike the bezier you put 
--into it
--let's not use that...

function easinghell(t)
	return (1-(t^3))
end

-->8
--bounceball deluxe!
--it's okayer
function ready_paddle()
	--newgame = true
	for i = 1,14,1 do
		nset(i,0,4)
	end
	nset(7,7,0)
	weak_explode(64,64,64)
	_init = _pad_init
	_draw = _pad_draw
	_update = _pad_update
	_pad_init()
end
function _pad_init()
	smoke={}
	padx=52
	pady=122
	padw=24
	padh=4

	ballx=64
	bally=64
	ballsize=2.5
	ballxdir=5
	ballydir=-3

	bouncenext = false
	bouncenow = false

	speed = 1
	lives = 3
	score = 0
	
	colorconvert = {[true]=9, [false]=12}
	
	dead = false
	dying = false
	safe = false
	
	deluxemode = false
	
	if not dget(0) then
		dset(0,0)
	end
	if not dget(1) then
		dset(1,0)
	end
end

function movepaddle()
 if btn(0) then
 	padx-=3.25*speed --left arrow
 	--pady+=1
 elseif btn(1) then
  padx+=3.25*speed --right arrow
  --pady-=1
 end
end

function pad_moveball()
	if bouncenow then
		make_smoke(ballx,bally,1,6,25)
	end
	ballx+=(ballxdir*speed)
	bally+=(ballydir*speed)
	if ballx > 119-ballsize or ballx < 8+ballsize then
		ballxdir = -ballxdir
		sfx(0)	
	end
	if bally < 8+ballsize and not bouncenow then
		ballydir = -ballydir
		sfx(0)
	end
	if bally < 100 then
		safe = false
	end
	if bouncenow then
		ballydir += 0.5 --gravity!
	end
end

function bouncepaddle()
	if ballx+ballsize>=padx and 
				ballx-ballsize<=padx+padw and
				bally+ballsize>pady and 
				not safe then
		safe = true
		sfx(2)
		bouncenow = bouncenext
		if deluxemode then
			ballxdir = (ballx-(padx+padw/2))/2
		end
		if (rnd(1) > 0.5 and not bouncenext) or rnd(1) > 0.9 then bouncenext = true
		else bouncenext = false
		end
		if not bouncenow then
			if ballydir < 4 then
				ballydir =-ballydir
			else ballydir = -3 end
		else
			ballydir = -8 --negative is up
			sfx(13)
	 end
		speed +=0.025--what?
		score+=flr(speed*100)	
	end
end

function losedeadball()
	if bally>(127+ballsize) and 
				not (ballx+ballsize>=padx and 
				ballx-ballsize<=padx+padw) and
				not safe 
				then
		if lives == 0 then
			dead = true
			sfx(5)
			endoflife = time()
		end
		sfx(3)
		lives-=1
		bouncenow=false
		bally=64
		ballx=64
		ballydir=-3
		deadtime = time()
		dying = true
		
		speed -=1
		speed /=2
		speed +=1
	end
end
function _pad_update()
	movepaddle()
	foreach(smoke,move_smoke)
	if not (dying or dead or newgame) then
			pad_moveball()
			bouncepaddle()
		elseif not newgame and time()-deadtime > 1.5 then
			dying = false
		end
		losedeadball()
	if deluxemode then
		if score > dget(1)then
			dset(1,score)
		end
	else
		if score > dget(0)then
			dset(0,score)
		end
	end
	--resets
	if dead then
	 if btn(5) then
			_init() --this should be illegal
		end
		if btn(4) then
			_init()
			deluxemode = true
		end
	end
	if newgame then
		if btn(5) then 
			newgame = false 
			deluxemode = false
		end
		if btn(4) then
			newgame = false
			deluxemode = true
		end
		if rnd(1) > 0.7 then
			make_smoke(56,64,2,rnd(15),60)
		end
	end
end


function _pad_draw()
	--rectfill(0,0,128,128,0)
	cls()
	if shakin then
		camera(cameron.x+rnd(shakin)-shakin/2,
									cameron.y+rnd(shakin)-shakin/2)
		shakin *=0.95
		shakin -= 0.5
		if shakin <= 1 then shakin = false end
	else
		camera(cameron.x,cameron.y)
	end
	--wonder what happens if i remove this?
	--paddle
	rectfill(padx, pady, padx+padw, pady+padh, colorconvert[bouncenext])
	--walls
	
	nap(0,0,16,16)
	if bouncenow then 
		rectfill(8,0,119,8,0)
		line(120,0,120,127,8) 
		line(7,127,7,0,8)
	end
	--ball
	if not (dying or dead or newgame) then
		circfill(ballx,bally,ballsize, colorconvert[bouncenow])
	end
	--score
	print(score, 16,12,15)
	if deluxemode then
		print("hi: ".. dget(1), 16, 20, 15)
	else
		print("hi: ".. dget(0), 16, 20, 15)
	end
	--hearts
	for i=1, lives do
		spr(001,82+i*8,12)
	end
	--smoke
	foreach(smoke,draw_smoke)
	--end
	if dead then
		if (time() - endoflife > 2.5) then
			printc("thank you for playing", 64,54,8)
		end
		if (time() - endoflife > 3.5) then
			printc("bounceball: golf!", 64, 64, 8)
		end
		if (time() - endoflife > 4.5) then
			printc("a game by twotwos",64,74,8) 	
		end
		if (time() - endoflife > 5.5) then
			printc("hit — to go again?",64,84,8) 	
		end
	end
	--newgame
	if newgame then
		print_thicc("bounceball!", 42, 44, 9, 12, 0)
		print("hit — to begin", 36, 64, 7) 
	end
end
	
__gfx__
00000000000000008888888880000000000000000000000888888880000000088000000008888888a000000a08888888888888808880a000000a088866666666
000000000880880000000000800000000000000000000008000000080000000880000000800000000a0000a08000000000000008800a00000000a00860007776
0070070087888880000000008000000000000000000000080000000800000008800000008000000000aaaa00800000000000000880a0000000000a0860007776
000770008888888000000000800000000000000000000008000000080000000880000000800000000000000080000000000000088a000000000000a860007776
000770002888882000000000800000000000000000000008000000080000000880000000800000000000000080000000000000088a000000000000a867770006
0070070002888200000000008000000000000000000000080000000800000008800000008000000000000000800000000000000880a0000000000a0867770006
00000000002820000000000080000000000000000000000800000008000000088000000080000000000000008000000000000008800a00000000a00867770006
000000000002000000000000800000008888888800000008000000088888888008888888800000000000000008888888888888808880a000000a088866666666
00000000000000008000000880000008088888800000000088888888888888880000000a8888888800000000888888888888888888a0000000000000a0000000
000aaa00000000008000000880000008800000080000000000000000800aa008000000a08000000800000000800aa00880000008800a0000000aaa000a000000
00a000a00000000080000008800000088000000803bbbbb00000000080a00a0800000a00a000000a0000000080a00a08a00000088000a00000a000a000a00000
0a00000a000000008000000880000008800000083bbbb7bb000000000a0000a000000a000a0000a0a000000a0a0000a80a00000880000a000a00000a00a00000
0a00000a0000000080000008800000088000000803bbb7b000000000a000000a00000a0000a00a000a0000a0a00000a800a0000880000a000a00000a00a00000
0a00000a00aaaa00800000088000000880000008003b7b00000000000000000000000a00000aa00080a00a0800000a08000a00088000a0000a00000a00a00000
00a000a00a0000a08000000880000008800000080003b0000000000000000000000000a000000000800aa0080000a0080000a008800a000000a000a00a000000
000aaa00a000000a8000000808888880800000080000000088888888000000000000000a0000000088888888000a088800000a8888a00000000aaa00a0000000
88888888a00000000000000aa00000000000000a00000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc0a00000aa00000a00a000000000000a0aa0000aa000000a0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaaa00aaaaa0000a0000000000a0000aaaa0000000a00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000a0000aaaa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a0000000000000000a0aa0000aa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a000000000000a000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000a0000000000a000000000000aaaaa00aaaaa000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a000000000000a0000000000a00000aa00000a00000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000a00000000000000a00000000a00000000000000a0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ccccccccc00000000000000000000000000000000000000000000000000000000ccc00000000000000000000000000000000000000000000000
00000000000cccccccccccc000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000000000000000
000000000ccccc000000ccc0000000000000000000000000000000000000000000000000000cccccc0000000000000000000000000000000000000000000cc00
00000000cccc000000000ccc00000000000000000ccccccccccc0000000000000000000000cccc0cc0000000000000000ccccccccc000000000000000000cc00
0000000cccc0000000000ccc000000000000000cccccccccccccc000000000000000000000ccc00cc000000000000000cccccccccc00000000ccc0000000cc00
0000000ccc00000000000ccc00000000000000cccc000000000ccc0000000000000000000ccc000cc000000000000000ccc00000cc000000cccccc000000cc00
000000000000000000000ccc000000000000cccc000000000000ccc00000000000000000ccc0000cc000000000000000cc000000cc00000ccccccc000000cc00
00000000000000000000ccc0000000000000ccc00000000000000ccc000000000000000ccc00000cc000000000000000c000000ccc0000cccc00ccc00000cc00
0000000000000000000ccc00000000000000000000000000000000cc00000000000000ccc000000cc000000000000000cc0000cccc000cccc0000cc00000cc00
000000000000000000cccc00000000000000000000000000000000cc00000000000000cc0000000cc000000000000000cc0ccccccc00ccc000000ccc0000cc00
00000000000000000cccc000000000000000000000000000000000cc0000000000000ccc0000000cc000000000000000ccccccc0cc00cc00000000cc0000cc00
00000000ccccc000cccc000000000000000000000000000000000ccc0000000000000cc00000000cc000000000000000cccc0000cc00cc00000000cc0000cc00
00000000cccccccccc00000000000000000000000000000000000cc000000000000000000000000cc00000000000000000000000cc00cc0000000ccc0000cc00
00000000ccccccccccc0000000000000000000000000000000000cc000000000000000000000000cc00000000000000000000000cc00cc0000000ccc0000ccc0
0000000000000000cccc00000000000000000000000000000000ccc000000000000000000000000cc00000000000000000000000cc00cc0000000cc00000ccc0
000000000000000000cccc000000000000000000000000000000cc0000000000000000000000000cc00000000000000000000000cc00cc0000000cc000000cc0
0000000000000000000ccc00000000000000000000000000000ccc0000000000000000000000000cc00000000000000000000000cc00ccc00000ccc000000cc0
00000000000000000000ccc0000000000000000000000000000cc00000000000000000000000000ccc0000000000000000000ccccc000cc00000ccc000000cc0
000000000000000000000cc000000000000000000000000000ccc000000000000000000000000000cc000000000000000000ccccc0000ccc00cccc0000000cc0
000000000000000000000ccc00000000000000000000000000cc0000000000000000000000000000cc000000000000000cccccc0000000ccccccc0000000ccc0
0000000000000000000000cc000000000000000000000000cccc0000000000000000000000000000cc000000000000000cccc0000000000cccc000000000cc00
000000000000000000000ccc00000000000000000000000cccc00000000000000000000000000000cc000000000000000000000000000000000000000000cc00
00000000000000000000cccc000000000000000000000ccccc000000000000000000000000000000cc0000000000000000000000000000000000000000000000
00000000000cccccccccccc00000000000000000000ccccc00000000000000000000000000000000cc0000000000000000000000000000000000000000000000
000000000cccccccccccc0000000000000000000cccccccccc000000000000000000000000000000cc0000000000000000000000000000000000000000000000
000000000cccc000000000000000000000000000ccccccccccccccccccc00000000000000000000ccc000000000000000000000000000000000000000000cc00
0000000000000000000000000000000000000000000000000cccccccccc000000000000000cccccccccccc0000000000000000000000000000000000000cccc0
00000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccc0000000000000000000000000000000000000cccc0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc0
50000000000030005000000000000030500000305000003050000000000000305000000030500000000030500000003050000000000030005000000000000030
50000100000000000000000000000030500001000000000000000000000000305000010000000000000000000000003050000100000000000000000000000030
50000000000030005000000000000030500000305000003000202020202020000020712000002071712000002071200050000000000030005000000000000030
0020202020919191917191719191910000202020207171717191719171717100002020202012525222717112525222000031404120e1d0d0e080d0d0d1d0d000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000300000000000030500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000300000000000030500000000000000000000000000000000000000000000000000000003003
03500000000000000000000000000000000000000000000000000000000000000000004100000000000000000000000000004100000000000000000000000000
00000000000000000000000000000000000000000000000000000300000000000030500000000000000000000000000000000000000000000000000000008040
00500000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
000000000040a1a1a1a140000000000000000000004040a140404000000000000030500000000000000000000000000000000000000000000000000000000000
30500000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000500000000000003000000000000000005000000000000000000000000030500000000000000000000000000000000000000000000000000000000000
30002020122260000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000e0000000000000d00000000000000000e000000000000000000000000030e00000000000000000000000000000000000000000000000009060000000
30004040404070000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000e0000000000000d00000000000000000e000000000000000000000000080700000000000000000000000000000000000901222600000003050000000
d0500000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000e0000000000000d00000000000000000e000000000000000000000000000000000000000000000000000000000000000320000420000003050000000
30500000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000e0000100000000d00000000000000000e00001000000000000000000000000000000902060000000000000000000000033000043000000f150000000
80700000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000500000000000003000000000000000005000000000000000000000000000000000003200500000000000000000000000806373700000003042000000
00000000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000002071717171200000000000000000000020202020712000000000000000000000003300500000009012226000000000000000000000003062000000
00000000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000000000000000000000000000000000000000000000000300000000000000000000008040700000003000005000000000000000000000003043000000
00000000000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000002100000000000000000000000000
00000000000000000000000000000000000000000000000000000300000090202020600000000000000000003000005000000000000000000000003050000000
90a06000000000000000000000000000009012525252525222600000000000000000002100000000000000000000000000002100000000000000000000000000
00000000000000000000000000000000000000000000000000000300000030000000500000000000000000003000005000000000000000000000003050000000
30005000000000000000000000000000003000000000000000500000000000000000002101000000000000000000000000002100000000000000000000000000
00000000000000000000000000000000000000000000000000000300000030000000500000000000000000003000005000009020202020716000003000919191
00005000000000000000000000000000003000000000000000500000000000000000003012525252525252525252525252225000000000000000000000000000
00000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000
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
0000010101010101010102010105050000020101010001050209050509090002000202020202020200000000000000000100000202000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0004040404040404040404040404040000040404040404040404040404040400000404040404040000040404040404000004040404040400000404040404040000040404040404040404040404040400000404040404040404040000000000000004040404040404040404040404040000040404040400000004040404040400
0500000000000000000000000000000305000000000000000000000000000003050000000000000305000000000000030500000000000003050000000000000305000000000000000000000000000003050000000000000000000300000000000500000000000000000000000000000305000000000003000500000000000003
050000000000000000000000000000030500000000000000000000000000000305000000000000030500000000000003050000000000000305000000000000030500000000000000000000000f00000305000000000000000f000300000000000500001400000000140000000000000305000000000003000500000000000003
050000000000000000000000000000030500000000000000000000000000000305000000000000030500000000000003050000000f0000030500000000000003050000000000000000000000000000030500000000000000000008041104040005000b110c00000b110c00000000000305000000000008040700000000000003
0500000000000000000000000000000305000000000000000000000000000003050000000000000305000000000000030500000000000003050000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000001400000305000000000000150000000000000003
0500000000000000000000000000000305000000000000090600000000000003050000000000000305000000000000030500000000000008070000100000000305000000000000000000000b0a0c00030500000921220600000000000000000305000000000000000000000b110c000305000000000009020600000000000003
050000000000000000000000000000030500000000000003050000000000000305000000000000080700000000000003050000000000000000000000000000030500000000000000000000001300000305000003000005000b0c000000000003050000000f000000140000000000000305000000000003000500000000000003
05000000000000000000000f000000030500000000000003050000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000305000003000005000000000000000003050000000000000b110c00000000000305000000000003000500000000000003
0500000000000000000000000000000305000000000000030500000000000003050000000000000906000000000000030500000000000000000000000000000305000b0a0c0000000000000000000003050000030000050000000000000000030500001400000000000000001400000305000000000003000500000000000003
05000000000000000000000000000003050000000000000305000000000000030500000000000003050000000000000305000000000000000000000000000003050000130000000000000000000000030500000300000500000000000000000305000b110c0000000000000b110c000305000010000003000500000000000003
0500000000000000000000000000000305000000000000030500000000000003050000000000000305000000000000030500000000000000000000000000000305000000000000000000000000000003050000030000050000000000000000030500000000000000000000000000000305000000000008040700000000000003
050000000000000000000000000000030500000000000003050000000000000305000000000000030500000000000003050000090a060000000000000000000305000000000000000000000b0a0c0003050000030000050000000000000000030500000000000000140000000000000300020202020600000000000000000003
050000100000000000000000000000030500000f00000003050000001000000305000010000000030500000f0f000003050000030005000000000000000000030500000000000000000000001300000305000003000005000000000000000003050000000000000b110c00001000000300040404040700000000000000000003
05000000000000000000000000000003050000000000000305000000000000030500000000000003050000000000000305000003000500000000000000000003050000100000000000000000000000030500000300000500000000001000000305000000000000000000000000000003050000000000000000000b21220c0003
0500000000000000000000000000000305000000000000030500000000000003050000000000000305000000000000030500000300050000000000000000000305000000000000000000000000000003050000030000050000000000000000030500000000000000000000000000000305000000000000000000000807000003
00020202020202020202020202020200050000000000000305000000000000030002020202020200050000000000000300020200000500000000000000000003000202020202020202020202020202000500000300000002020202020202020000020202020600000000090202020200050000090f0600000000000000000003
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000003000500000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000404040404000000040404040404000004040000040400000404040404040000040404040404000004040404040400050000000000030000040404040404000004040404040404040404040404040000040404040404040404040404040400000404040404040404040404040404000b120b04091209040209090609070702
05000000000003000500000000000003050000030500000305000000000000030e000000000000030e000000000000030500000000000300050000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000312000000000000000000000000000003
0500000f000003000500000000000003050000030500000807000000000000030e000000000000030e00000000000003050000000000030005000000000000030500000000000000000000000f0000030500000000000000000000000f0000030500000000000000000000000f0000031300001000000000000000000f000002
05000000000003000500000000000003050000080700000000000000000000030e000000000000030e000000000000030700000000000300050000001000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000305000000100000001000000010000016
0500000000000300050000000000000305000f0000000000000000000000000d0e000000090600030e00090600000003000000000000030005000000000000030500000000000000000000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000100000000000000c
05000000000008000500000010000003050000090600000000000000000000030500000003050003050003050000000300000000000008000500000000000003050000000000000000000000000000030500000000000000000000000000000305000000000000000000000000000003131e000010000000000010000000000b
0500000000000008070000000000000305000003050000090600000000000003050000000305000305000305000000030000000000000008070000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000307000000000010000000000000100005
0500000000000000000000000000000305000003050000030500000000000003050000000305000305000305000000030000000000000000000000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000305000010000000001000001000000005
0500000000000000000009060000000305000003050000031800000000000003050000000305000305000305000000030600000000000000000009060000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000305000000000010000000100000000003
050000000000000000000807000000030500000305000003050000000000000305000000030500080700030500000003050000000000000000000807000000030500000000000000000000000000000305000000000000000000000000000003050000000000000000000000000000030c1e0000000000001e00000000001003
05000000000000000000000000000003050000030500000305000000000000030500000003050000000003050000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000305000000000000000000000000000003080000000000000000001e0000000002
0500000000000917060000000000000305000003050000030500000000000003050000000305000000000305000000030500000000000919060000000000000300020a0206000000000000000000000300020a0206000000000000000000000300021702060000000000000000000003000211020800001e0000000000000003
0500000000000300050000000000000305000003050000030500000000000003050000000305000000000305000000030500000f00000300050000000000000300040404070000000000000000000003000404040700000000000000000000030004040407000000000000000000000314141404080000000000000010000007
0500000000000300050000000000000305000003050000030500000000100003050010000305000000000305000f00030500000000000300050000000000000305000000000000000000000000000003050000000000000000000000000000030500000000000000000000000000000305000000000000000000000000000004
__sfx__
00010000275502755026550255502455023550250001c5001d5001d5002b00027000220001f0001d0001b0001c0001e0001e0002af002ef002df002df002df002af0013f0014f0014f002390014f0014f0023800
000d00000a5510e5511255115551195411b5311b5311b5411955115551115510b5513080030801308012480130801000010000100001000010000100001000010000100001000010000100001000010000100001
0001000028050250502305022050200501f0502300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002600002953028540245501c55016570165750000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000100002355024550255502655027550275502350024500255002650027500275001f0001d0001b0001c0001e0001e0002af002ef002df002df002df002af0013f0014f0014f002390014f0014f002380000000
002600002953028540245501c550165701650013570000000f5600f5550c5000e5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001300001f6431c633226032260322603226032260322603226032260322603216030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
000c00001d64024630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000d7500d7500d7500f7501075011750127501475016750197501b7501d7501f7502175022750247502675028750297402b7402e730307303272035710280002e0003a0003e0001e000210002400027000
000800000d0500d0500d0500e0500f0501005011050130501505017050190501b0501d0501f05020050210502205023050250402604027030290302a0202b0102b0002e0003a0003e0001e000210002400027000
00080000297102672024720227301f7301d7401c7401a750187501675015750137501275011750107500e7500d7500b7500a75009750087500875008750000000000000000000000000000000000000000000000
000800002a01029020260202503023030210401f0401d0501c0501b0501a050180501705016050140501305012050100500f0500d0500b0500b0500b050000000000000000000000000000000000000000000000
000b000022550265501a55029550165502d55010550305500c550335500955036530055503d510045503f510045503f510075503b53009550355500c5502f5500d5502b550115502755017550245501e5501f550
000c00001b5511e551205512455126541275312753126541235511f5511a551165513080030801308012480130801000010000100001000010000100001000010000100001000010000100001000010000100001
00060000175501e5502555025550155501d5502255022550195502055025550255502555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
