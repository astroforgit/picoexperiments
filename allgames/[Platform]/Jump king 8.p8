pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--lucas dara blondin
function _init()
init_medals()
left=0 right=1 up=2 down=3 fire1=4 fire2=5

gravity		=0.3
friction	=0.7
game_timer = 0
jump_time=0
tick 				=0
thrust			=0
thrustmax=4.3
cam_y =384
cam_x =8
tim			=0

tmp = 0.3
time_push=tmp
push_count= false

scores = 0
scoremax = 10
menu_select = 1
cls_c							=	0
menu														= true
ingame 											= false
menu_in_game						= false
button_pressed 			= false
princesse_rescued = false
score_board							=	false
plane													= true
credit 											= false

g		=6
xx	=6
d		=6
up =6
dn =6

titre ={}
create_title()


cartdata("scoreboard_test")
--reset_scores()
high_score_table.load_scores()


princesse={
	sp=6,
	touched=false,
	anim=0,
	x=95*8,
	y=6*8
}

clouds = {}
			for i=0,16 do
						add(clouds,{
								x=rnd(128)+128,
								y=rnd(490),
								spd=1+rnd(2),
								w=32+rnd(32)
				})
			end

clouds2 = {}
			for i=0,16 do
						add(clouds2,{
								x=rnd(128)+390,
								y=rnd(490),
								spd=1+rnd(2),
								w=32+rnd(32)
				})
			end

stars ={}
	for i=0,60 do
		add(stars,{
				x=rnd(128),
				y=rnd(514),
				spd=1+rnd(2)
				})
	end

rain ={}
	for i=0,30 do
		add(rain,{
				x=rnd(128)+415,
				y=rnd(514),
				spd=10+rnd(4),
				w=0.1
				})
	end
	
end

function creat_clouds(l)
-- clouds
	if l ==1 then
		foreach(clouds, function(c)
					c.x += c.spd
					rectfill(
					c.x,c.y,
					c.x+c.w,
					c.y+4+(1-c.w/64)*12,
					7)
					if c.x > 300 then
						c.x = 100
						
					end
				end)
	else 
		foreach(clouds2, function(c)
					local col = 6
					c.x += c.spd
					if c.spd < 2 then
					col = 14
					end
					rectfill(
					c.x,c.y,
					c.x+c.w,
					c.y+4+(1-c.w/64)*12,
					col)
					if c.x > p.x+200 then
						c.x = p.x - 200
						c.y	=	rnd(490)
					end
				end)
	end
			
--endclouds	
end

function creat_rain()
			foreach(rain, function(c)
				c.y += c.spd
				rectfill(
				c.x,c.y,
				c.x+c.w,
				c.y+4+(1-c.w/64)*12,1)
					if c.y > p.y+128 then
						c.y = p.y-128	
						c.x = rnd(128)	+	415	
					end
			end)
end

function movingtext(text,speed,height,x,y,couleur)	
 tim += 1
 for i=0,#text,1 do
  print(sub(text,i,i),
  x+(i*4),
  y+sin((tim+i)/speed)*height,couleur)
 end
end


function current_time(value)
	local time = flr(value/10)
	local hour = flr(flr(time/60)/60)
	local minute = flr(time/60)-(hour*60)
	local sec = time-(minute*60)
	local mil = value 
	return (hour.."h:"..minute.."m:"..sec.."s")					
end



-->8
--playeur
p={
		sp=7,
		x=936,
		//x=60,
		y=490,
		//y=176,
		w=7,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=8,
		acc=0.85,
		boost=1,
		anim=0,
		running=false,
		jumping=false,
		landed=false,
		falling=false,
		hit=false
	}

function p_update()
player_animate()
--physics
	if p.dy < p.max_dy then
	p.dy+=gravity
	end
	p.dx*=friction
	
	
	if not btn(‹) then
		g=6
		p.running = false
	end
	if not btn(‘) then
		d=6
		p.running = false
	end
	
	if btn(‹) then
		g=10
		p.running = true
	end
	if btn(‘) then
		d=10
		p.running = true
	end
	
	
	
--controls
	if btn(‹) 
	and not button_pressed
	and p.jumping then
	 p.dx-=p.acc
	 --p.running=true
	 p.flp=true
	 g=10
	end
	
	if btn(‘)
	and not button_pressed
	and p.jumping then
	 p.dx+=p.acc
	 --p.running=true
	 p.flp=false
	 d=10 
	end
	
	if p.running
	and not btn(‹)
	and not btn(‘)
	and not p.falling
	and not p.jumping then
		p.running=false
		
	end
	
	if btnp(Ž) then
		menu_in_game = true
	end
	
	
	--jump
	
	if btn(—)
	and p.landed then
		button_pressed=true
		count_time()
	xx=10
	elseif not btn(—)
	and p.landed
	and button_pressed then
	sfx(0)
	button_pressed = false
	jump_time = 0
	p.dy-=p.boost+thrust
	p.landed=false
	thrust = 0
	xx=6
	unlock_medals(1) 
	end
	
	--collision up and down
	if p.dy>0 then
		p.falling=true
		p.landed=false
		p.jumping=false
	--p.running=false

		if collide_map(p,"down",0)then
			p.landed=true
			p.falling=false
			p.dy=0
			p.y-=(p.y+p.h)%8
		end
	elseif	p.dy<0 then
		p.jumping=true
		p.running=false
		if collide_map(p,"up",0)then
				if time_push==tmp then
					push_count = true
					p.dy=1
					sfx(2)
				end
		end
	end
		
	--check collision left nd right
	if p.dx<0 then
		if collide_map(p,"left",0)then
			if time_push==tmp then
					push_count = true
					p.dx=2
					p.dy=0
					sfx(2)
				end
		end
	elseif p.dx>0 then
		if collide_map(p,"right",0)then
			if time_push==tmp then
					push_count = true
					p.dx=-2
					p.dy=0
					sfx(2)
				end
		end
	end
	
	
		
	--deplacement
	p.x+=p.dx
	p.y+=p.dy
	
end


function player_animate()
	if p.jumping or p.falling then
		p.sp=23
	elseif p.running then
--		if time()-p.anim>.1 then
--			p.anim =time()
--			p.sp+=1
--			--sfx(1)
--			if p.sp>3 then
--				p.sp=2
--			end
--  end
	p.sp=9
	elseif button_pressed then
	p.sp = 8
	else
		p.sp=7
	end
end


-->8
--draw
function _draw()
	palt(0, false)
	palt(15,true)
		
	if menu then
			cls(13)
			creat_clouds(3)
			rectfill(
										904,10,
										998,39,6)
			rect(
										904,10,
										998,39,5)
										
			map(0, 0, 0, 0, 128, 128)
			camera(111*8,0)
			--camera(111*8,128)
			--high_score_table.draw()
			
			
			local ligne			=0
			local colonne	=0
			for t in all(titre) do
				if t.p == 8 then
					pset(950+colonne,
									16+ligne,t.p)
				end
				if colonne > 42 then
					colonne = 0
					ligne+=1
				else
					colonne+=1
				end
			end
			
			spr(106,911,13,5,2)
			print("there is a smoking hot\n"
							.." 		babe at the top !"
									,20+(111*8),45,7)
			
			
			rectfill(
				(111*8),103,
				128+(111*8),120,
				8
			)
			
			rect(
				(111*8)-5,103,
				128+(111*8),120,
				6
			)
			
			movingtext(
			"press —  to start",
			30,
			4,
			27+(111*8),
			110,
			0
			)
			
			movingtext(
			"press —  to start",
			30,
			4,
			28+(111*8),
			109,
			7
			)
			
			print("Ž credit",
									42+(111*8),
									15.3*8,
								0)
								
			print("Ž credit",
									43+(111*8),
									15.3*8,
								7)
									
--			print("press — to start"
--									,30+(111*8),100,7)
--
	elseif credit then
		//cls(13)
		
		rectfill(880,60,
											888+128,128,8)
		rect(880,60,
											888+128,128,7)
		print("as you may know this is a knock\n"
						.."off of the original game jump\n"
						.."king created by swedish studio\n"
						.."called nexile if you don't know\n"
						.."go check it out it's available\n"
						.."on steam it's way better them\n"
						.."my pico version.\n\n"
						.."			anyway plz don't sue me\n"
						.." 							coded by lucas d.b"
						.."\n\n 				thank for playing"
							,4+888
							,63
							,7)
		print("Ž back",5+888,120,1)					
	elseif score_board then
		pal(9,137,1)
		//cls(9)
		cls(13)
		creat_clouds(3)
		rectfill((114*8)+2,(17*8)+1,
											(124*8)-2,(28*8)-1,2)
		
	 map(0, 0, 0, 0, 128, 128)
		
		camera(111*8,128)
		
		high_score_table.draw()
		local hour = flr(flr(game_timer/60)/60)
		local minute = flr(game_timer/60)-(hour*60)
		local sec = game_timer-(minute*60) 
		
		print("— save",p.x-58,245,7)
	
	if menu_in_game then		
		print("Ž resume ",(111*8)+40,245,7)
	else					
		print("Ž restart",p.x+25,245,7)
	end
		//111*8,128
		
	if not menu_in_game then
		print("‹",111*8+52,128+118,g)
		print("”",111*8+60,128+115,up)
		print("ƒ",111*8+60,128+122,dn)
		print("‘",111*8+68,128+118,d)
	end					
		spr(p.sp,p.x,p.y,1,1,p.flp)
		spr(princesse.sp,
							p.x,
							p.y-6)
							
		
					
	elseif princesse_rescued then
		cls(13)
		creat_clouds(3)
		map(0, 0, 0, 0, 128, 128)
		camera(cam_x,cam_y)
		
		
--		local hour = flr(flr(game_timer/60)/60)
--		local minute = flr(game_timer/60)-(hour*60)
--		local sec = game_timer-(minute*60) 
--		
--		
--		print(" you got the hot babe in\n\t"
--								.."         "
--								..hour
--								..":"
--								..minute
--								..":"
--								..sec
--								.."\n     "
--								.." Ž restart",
--									cam_x+15,
--									cam_y+8,7)
									
		
													
		spr(p.sp,p.x,p.y,1,1,p.flp)
		spr(princesse.sp,
							p.x,
							p.y-6)
							
	elseif menu_in_game then
	 local x = cam_x
	 local y = cam_y
	 
	 
		rectfill(
			x+38,y+25,
			x+83,y+40,
			8
			)
		rect(
			x+38,y+25,
			x+83,y+40,
			7
			)
			
			print(current_time(game_timer),
									x+45,
									y+30)
			--------------
			rectfill(
			x+38,y+45,
			x+83,y+60,
			8
 		)		
		rect(
			x+38,y+45,
			x+83,y+60,
			7
			)
			
			print("resume",
									x+52,y+50,7)
			
		--------------	
		rectfill(
			x+38,y+65,
			x+83,y+80,
			8
 		)		
		rect(
			x+38,y+65,
			x+83,y+80,
			7
			)
			
			print("restart",
									x+52,y+70,7)
			
			---------------
			rectfill(
			x+38,y+85,
			x+83,y+100,
			8
 		)		
		rect(
			x+38,y+85,
			x+83,y+100,
			7
			)
			
			print("scores",
									x+52,y+90,7)
			
			if menu_select == 1 then
			print("—",x+42,y+50,7)
			rect(
			x+38,y+45,
			x+83,y+60,
			9
			)
			elseif menu_select == 2 then
			print("—",x+42,y+70,7)
			rect(
			x+38,y+65,
			x+83,y+80,
			9
			)
			else
			print("—",x+42,y+90,7)
			rect(
			x+38,y+85,
			x+83,y+100,
			9
			)
			end
													
									
	elseif ingame then 
		camera(cam_x,cam_y)
		
		if p.x < 130 then
			//pal(10,10+128,1)
			cls(cls_c)//2
			
			--tronc
			sspr(8,0,
							16,8,
							4,0,
							60,520)
					
		elseif p.x < 270 then
			pal(9,137,1)
			cls(cls_c)//9
			creat_clouds(1)
			
			--toit
--			sspr(40,32,
--								8,8,
--								224,1,
--								48,63)
							
		elseif p.x < 408 then
			cls(cls_c)//0
				for i in all(stars) do
					pset(i.x+270,i.y,7)
				end
		elseif p.x < 544 then
			pal(3,131,1)
			cls(cls_c)//3
			creat_rain()	
		elseif p.x < 672 then
			cls(cls_c)//13
			creat_clouds(2)
		elseif p.x < 818 then
		cls(cls_c)//13
			creat_clouds(3)
			spr(princesse.sp,
							princesse.x,
							princesse.y)
			else
			cls(cls_c)//9
		end
	 map(0, 0, 0, 0, 128, 128)
	 //draw_medals()
--	 print("\nmed_num:"..med_num
--	 				.."\nmed_tin:"..med_tin
--	 				,cam_x,cam_y,7)
--		print("x = "..p.x.."\n"
--						.."y = "..p.y.."\n"
--						..(p.y/128).."\n"
--						..(p.x/128)
--						.."\ncam_y="..cam_y
--						.."\ncam_x="..cam_x
--						,cam_x,cam_y,7)

--				print("time_p "..time_push
--								.."\np.dx = "..p.dx
--								.."\np.dy = "..p.dy 		
--				,
--						cam_x+5,
--						cam_y+20,7)
						
		print("Ž",cam_x+2,cam_y+2,7)
		print(current_time(game_timer),
									cam_x+11,
									cam_y+2)
									
		spr(p.sp,p.x,p.y,1,1,p.flp)
		print("‹",cam_x+50,cam_y+122,g)
		print("—",cam_x+60,cam_y+122,xx)
		print("‘",cam_x+70,cam_y+122,d)
	end
end


-->8
--update

function _update()
	if time()-tick > .1 and
			not princesse_rescued and
			not menu_in_game then
		tick = time()
		game_timer +=1
		if push_count then
			time_push-=0.1
			if time_push <= 0.0 then
				push_count = false
				time_push = tmp
			end
		end
	end
	
	if	menu then
		if btnp(—) then
			ingame = true
			menu 		= false
			p.x 			= 60
			p.y 			= 490
--		p.x = 56*8
--		p.y =	0
--		 
		end
		if btnp(Ž) then
			menu		= false
			credit 	= true
		end
	elseif credit then

		if btnp(Ž) then
					credit=false		
					menu=true
		end
		
	elseif score_board and
					not princesse_rescued then
			if btnp(Ž) then
				score_board = false
				cls(cls_c)
				camera(cam_x,cam_y)
				cls(cls_c)
			 map(0, 0, 0, 0, 128, 128)
			 spr(p.sp,p.x,p.y,1,1,p.flp)
				spr(princesse.sp,
									princesse.x,
									princesse.y)
				sfx(4)
			end
	elseif score_board then
	if btnp(Ž) then
			p.x=60
			p.y=490
			game_timer = 0
			score_board = false
			princesse_rescued = false
			menu_in_game = false
			sfx(4)
			
		end
	
	if btn(”)then
		up=10
	else
		up=6
	end
	
	if btn(ƒ)then
		dn=10
	else
		dn=6
	end
	
	if btn(‹)then
		g=10
	else
		g=6
	end
	
	if btn(‘)then
		d=10
	else
		d=6
	end
	
	high_score_table.update()
				if plane then
					if p.y < 232 then
						p.y +=0.2
					else
						plane = false
					end
				else			
					if p.y > 229 then
						p.y -=0.2
					else 
						plane = true 
					end
				end 
	elseif princesse_rescued then		
		p_update()
		
		if p.x > 102*8 or
					p.y > 16*8 then
					score_board = true
			p.x=(111*8)+60
			p.y=230
			high_score_table.current_score = game_timer
			high_score_table.check_current_score(high_score_table.current_score)

		end
--		if btnp(—) then
--			score_board = true
--			p.x=(111*8)+60
--			p.y=230
--			high_score_table.current_score = game_timer
--			high_score_table.check_current_score(high_score_table.current_score)
--		end
	elseif menu_in_game then
		
		if btnp(”) and
			not rappel then
			if menu_select == 1 then
					menu_select = 3
					sfx(4)
			else
					menu_select-=1
					sfx(4)
			end
		elseif btnp(ƒ) and
			not rappel then
			if menu_select == 3 then
					menu_select = 1
					sfx(4)
			else
					menu_select+=1
					sfx(4)
			end
	end
	
		if btnp(Ž)  then
			menu_in_game = false
					sfx(4)
		end
		
		if btnp(—) and
									menu_select == 2 then
			menu_in_game = false
			p.x=60
			p.y=490
			game_timer = 0
					sfx(4)
		elseif btnp(—) and
									menu_select == 1 then
			menu_in_game = false
					sfx(4)
		elseif btnp(—) and
									menu_select == 3 then
			score_board = true
					sfx(4)
		end
		
	elseif ingame then
		//playeur_pos()
		camera_pos()
		p_update()
		princesse_update()
		playeur_pos()
	end

end

function princesse_update()
	princesse_rescued = collision(princesse,p)	
end

function count_time()
	if time()-jump_time > .1 then
		jump_time = time()
		if thrust < thrustmax then
			thrust+=1
		end
	end
	
	if thrust > thrustmax then
	thrust = thrustmax
	end
end

function camera_pos()
	local pos = p.y/128
	if pos > 3.99 then
		cam_y=512
	elseif pos > 2.99 then
		cam_y=384
	elseif pos > 1.99 then
		cam_y=256
	elseif pos > 0.99 then
		cam_y=128
	else 
		cam_y=0
	end
end

function playeur_pos()
	if	(p.y < -1) then
	p.x+=128
	p.y=510
	camera_pos()
	end
	if (p.y > 511) then
	p.x-=128
	p.y=0
	camera_pos()
	end
	
	local pos = p.x/136
	if pos < 0.99 then
		cam_x=8
		cls_c=1
	elseif pos < 1.99 then
		cam_x=144
		cls_c=9
	elseif pos < 2.99 then
		cam_x=280
		cls_c=0
	elseif pos < 3.99 then 
		cam_x=416
		cls_c=3
	elseif pos < 4.99 then
		cam_x=552
		cls_c=13
	else
		cam_x=688
		cls_c=13
	end
end



-->8
--collisions

function collide_map(obj,aim,flag)
	local x=obj.x local y=obj.y
	local w=obj.w local h=obj.h
	
	local x1=0 local y1=0
	local x2=0 local y2=0
	
	if aim=="left" then
			x1=x-1 				y1=y
			x2=x							y2=y+
			h-1
	
	elseif aim=="right" then
			x1=x+w 				y1=y
			x2=x+w+1			y2=y+h-1
	
	elseif aim=="up" then
			x1=x+1 				y1=y-1
			x2=x+w-1			y2=y
	
	elseif aim=="down" then
			x1=x							y1=y+h
			x2=x+w					y2=y+h
	end


--pixels to tiles
	x1/=8		y1/=8
	x2/=8		y2/=8
	
	if fget(mget(x1,y1),flag)
	or fget(mget(x1,y2),flag)
	or fget(mget(x2,y1),flag)
	or fget(mget(x2,y2),flag) then
			return true
	else
			return false
	end
end

function collision(a,b)
		return not 
		(a.x>b.x+8
		or a.y>b.y+8
		or a.x+8<b.x
		or	a.y+8<b.y)
end
-->8
-- title
function add_px(px,num)
	for i=0,num do
		add(titre,{p = px})
	end
end

function create_title()
	add_px(15,5)
	add_px(8,4)
	add_px(15,6)
	add_px(8,2)
	add_px(15,26)
	add_px(8,5)
	add_px(15,2)
	add_px(8,1)
	add_px(15,1)
	add_px(8,2)
	add_px(15,17)
	add_px(8,3)
	add_px(15,5)
	add_px(8,3)
	add_px(15,3)
	add_px(8,3)
	add_px(15,20)
	add_px(8,5)
	add_px(15,3)
	add_px(8,4)
	add_px(15,2)
	add_px(8,2)
	add_px(15,4)
	add_px(8,2)
	add_px(15,13)
	add_px(8,2)
	add_px(15,1)
	add_px(8,2)
	add_px(15,2)
	add_px(8,3)
	add_px(15,2)
	add_px(8,2)
	add_px(15,4)
	add_px(8,5)
	add_px(15,3)
	add_px(8,1)
	add_px(15,1)
	add_px(8,1)
	add_px(15,1)
	add_px(8,1)
	add_px(15,3)
	add_px(8,1)
	add_px(15,2)
	add_px(8,3)
	add_px(15,1)
	add_px(8,3)
	add_px(15,3)
	add_px(8,4)
	add_px(15,2)
	add_px(8,2)
	add_px(15,1)
	add_px(8,2)
	add_px(15,2)
	add_px(8,1)
	add_px(15,3)
	add_px(8,1)
	add_px(15,3)
	add_px(8,8)
	add_px(15,2)
	add_px(8,1)
	add_px(15,1)
	add_px(8,1)
	add_px(15,1)
	add_px(8,9)
	add_px(15,1)
	add_px(8,1)
	add_px(15,3)
	add_px(8,1)
	add_px(15,3)
	add_px(8,9)
	add_px(15,5)
	add_px(8,1)
	add_px(15,3)
	add_px(8,3)
	add_px(15,0)
	add_px(8,2)
	add_px(15,1)
	add_px(8,1)
	add_px(15,3)
	add_px(8,1)
	add_px(15,4)
	add_px(8,2)
	add_px(15,0)
	add_px(8,5)
	add_px(15,4)
	add_px(8,1)
	add_px(15,3)
	add_px(8,2)
	add_px(15,1)
	add_px(8,2)
	add_px(15,1)
	add_px(8,1)
	add_px(15,3)
	add_px(8,1)
	add_px(15,4)
	add_px(8,2)
	add_px(15,2)
	add_px(8,4)
	add_px(15,3)
	add_px(8,1)
	add_px(15,3)
	add_px(8,2)
	add_px(15,1)
	add_px(8,2)
	add_px(15,1)
	add_px(8,1)
	add_px(15,0)
	add_px(8,4)
	add_px(8,2)
	add_px(15,0)
	add_px(8,2)
	add_px(15,3)
	add_px(8,3)
	add_px(15,4)
	add_px(8,2)
	add_px(15,2)
	add_px(8,2)
	add_px(15,1)
	add_px(8,2)
	add_px(15,1)
	add_px(8,3)
	add_px(15,0)
	add_px(8,9)
	add_px(15,1)
	add_px(8,2)
	add_px(15,6)
	add_px(8,2)
	add_px(15,2)
	add_px(8,3)
	add_px(15,0)
	add_px(8,3)
	add_px(15,7)
	add_px(8,1)
	add_px(15,1)
	add_px(8,2)
	add_px(15,12)
	add_px(8,1)
	add_px(15,5)
	add_px(8,1)
	add_px(15,2)
	add_px(8,1)
	add_px(15,7)
	add_px(8,2)
	add_px(15,39)
	add_px(8,2)
	add_px(15,35)
	add_px(8,2)
	add_px(15,1)
	add_px(8,2)
	add_px(15,38)
	add_px(8,2)
end
-->8
--newground

function set_pin(pin,value)
	poke(0x5f80+pin, value)
end

function get_pin(pin)
	return peek(0x5f80+pin)
end

function unlock_medals(num)
	set_pin(0,1)
	set_pin(1,num)
end

function init_medals()
	med_num=0
	med_tin=0
end

function test_medals()	
	if get_pin(0)==2 then
		set_pin(0,0)
		med_num=get_pin(1)
		med_tic=0
		
		if med_num==1 then
			med_inf={1, "yeah"}
		end
	end
end

function draw_medals()
	if med_num!=0 then --trigger
		med_tic+=1 --add 1 to the tic value
				rectfill(cam_x+10,cam_y+20,
													cam_x+50,cam_y+40)
				sfx(5)
--		rectfill(cam_x-1,cam_y+116,
--				cam_x+10+#med_inf[2]*4,cam_y+128,0) --draw a black background
--		rect(cam_x-1,cam_y+116,
--				cam_x+10+#med_inf[2]*4,cam_y+128,5)	--draw a gray square
--		
--		spr(med_inf[1],cam_x+1,cam_y+118) --draw the sprite who represent the medals
--		print(med_inf[2],cam_x+10,cam_y+120,5) --print the medals' name
--		
		if med_tic>=70 then --reset. you can change the duration here
			med_num=0 --reset
		end
	end
end



-->8
-- high score
 -- high score code
-- taken from this thread https://www.lexaloffle.com/bbs/?tid=31901

high_score_table = { magic_number = 42, pad_digits = 8, base_address=0, a=0, current_score = 0 }
high_score_table.characters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " " }
score_entry = { entering = false, entry_number=1, entry_character=1, cycle_colours={10,9,8,14}, current_colour=1, cycle_count=0 }

high_score_table.scores = {}

function high_score_table.update()
	if (score_entry.entering) then
		score_entry.cycle_count += 1

		if (score_entry.cycle_count > 5) then
			score_entry.cycle_count = 0
			score_entry.current_colour += 1
			if (score_entry.current_colour > #score_entry.cycle_colours) then
			score_entry.current_colour=1
			end
		end

		if (btnp(”)) then
			score_entry.characters[score_entry.entry_character] += 1
			if (score_entry.characters[score_entry.entry_character] > #high_score_table.characters) then
			score_entry.characters[score_entry.entry_character] = 1
			end
		end

		if (btnp(ƒ)) then
			score_entry.characters[score_entry.entry_character] -= 1
			if (score_entry.characters[score_entry.entry_character] < 1) then
			score_entry.characters[score_entry.entry_character] = #high_score_table.characters
			end
		end

		if (btnp(right)) score_entry.entry_character = min(3, score_entry.entry_character+1)
		if (btnp(left)) score_entry.entry_character = max(1, score_entry.entry_character-1)

		if (btnp(fire2)) then
			high_score_table.scores[score_entry.entry_number].name = high_score_table.array_to_string(score_entry.characters)
			score_entry.entering = false
			high_score_table.save_scores()
			sfx(4)
		end
	end
	high_score_table.a += 0.0157
end

function high_score_table.draw()

	local title_text = "time stamps"
	? title_text, 888+64-#title_text*2, 130, 7
	for i=0, #high_score_table.scores-1 do
		local score = high_score_table.scores[i+1]
		local score_name = score.name
		local score_c = 7

		if (score_entry.entering and score_entry.entry_number == i+1) then
			score_name = high_score_table.array_to_string(score_entry.characters)
			score_c = score_entry.cycle_colours[score_entry.current_colour]
		end

		local score_text = score_name.."...."..high_score_table.get_score_text(score.score)
		local score_x = 64-#score_text*2
		--if (not score_entry.entering) score_x += sin(high_score_table.a+i/10)*5
		 
		? score_text, 888+score_x, 8*i+140, score_c

		if (score_entry.entering and score_entry.entry_number == i+1) then
			local start_x = 888+score_x+(score_entry.entry_character-1)*4
			line (start_x, 8*i+146, start_x+2, 8*i+146,score_c)
		end
	end
end

-- adding scores using bit shifting to allow for higher values
-- taken from this thread https://www.lexaloffle.com/bbs/?tid=3577
function high_score_table.add_current_score(addition)
	high_score_table.current_score += shr(addition, 16)
end

function high_score_table.check_current_score()
	for i=1,10 do
		if (high_score_table.current_score < high_score_table.scores[i].score) then
			for j=10,i+1,-1 do
				high_score_table.scores[j] = high_score_table.scores[j-1]
			end
			score_entry.entering = true
			score_entry.entry_number = i
			score_entry.entry_character = 1
			score_entry.characters = {1,1,1}
			high_score_table.scores[i] = {name="aaa", score=high_score_table.current_score}
			return true
		end
	end
	return false
end

function high_score_table.load_scores()
	local value = dget(high_score_table.base_address)

	if (value != high_score_table.magic_number) then
		for i=1,10 do
			high_score_table.scores[i] = { name = "aaa", score = shr(0,16)}
		end
		return false
	end

	local current_address = high_score_table.base_address + 1
	high_score_table.scores = { }
	for i=1,10 do
		local digits = ""
		score = dget(current_address)
		digits = digits..high_score_table.int_to_char(dget(current_address+1))
		digits = digits..high_score_table.int_to_char(dget(current_address+2))
		digits = digits..high_score_table.int_to_char(dget(current_address+3))
		high_score_table.scores[i] = { name=digits, score=score }
		current_address += 4
	end
	
	return true
end

function reset_scores()

	local current_address = high_score_table.base_address + 1
	for i=1,10 do
		local digits = ""
		dset(current_address,144000)
		
		dset(current_address+1,
		high_score_table.char_to_int("n"))
		dset(current_address+2,
		high_score_table.char_to_int("u"))
		dset(current_address+3,
		high_score_table.char_to_int("l"))
		
		current_address += 4
	end
end

function high_score_table.save_scores()
	dset(high_score_table.base_address, high_score_table.magic_number)

	local current_address = high_score_table.base_address + 1
	for i=1,10 do
		dset(current_address, high_score_table.scores[i].score)

		dset(current_address+1, high_score_table.char_to_int(sub(high_score_table.scores[i].name,1,1)))
		dset(current_address+2, high_score_table.char_to_int(sub(high_score_table.scores[i].name,2,2)))
		dset(current_address+3, high_score_table.char_to_int(sub(high_score_table.scores[i].name,3,3)))

		current_address += 4
	end
end

function high_score_table.get_score_text(score_value)
	if (score_value == nil) return "0"
	
	return current_time(score_value)
end

function high_score_table.char_to_int(char)
	for k,v in pairs(high_score_table.characters) do
		if (v == char) return k
	end

	return -1
end

function high_score_table.int_to_char(int)
	for k,v in pairs(high_score_table.characters) do
		if (k == int) return v
	end

	return ""
end

function high_score_table.array_to_string(array)
	local string = ""
	for i=1,#array do
		string = string..high_score_table.int_to_char(array[i])
	end
	return string
end
__gfx__
000000004422242222422242fffffffffffffffffffffffffaaaaafffafafafffffffffffafafafff2f22222f2f2f2f2ffffffff222222f2f2ffffff00000000
000000004422242222422442ffffffffffffffffffffffffa99999affaaaaafffffffffffaaaaaff2f2f22222f2f2f2fffffffff22222f2f2f2fffff00ffff00
007007002422244222422444ffffffffffffffffffffffffae2e2e9ffc111cfffa9a9afffcc111fff2f2f222f2f2f2f2ffffffff2222f2f2f2f2ffff0ffffff0
000770004422244222422444ffff88fffaafffffffffffffaaeeee9ffcc1ccfffa999afffccc1cffff2f2f22ffffffffffffffff222f2f2f2f2fffff0ffffff0
000770002422244222422244ffff8a8ffa9afffffffffffffa88829f8877788ffc111cff8877788ffff2f2f2ffffffffffffffff22f2f2fff2ffffff0ffffff0
007007002442222224422242ffffb88ffbaafffffbfffffff28882ff8811188f8871788f8811188fffff2f2fffffffff2f2f2f2f2f2f2fff2f2fffff0ffffff0
0000000044422222244222443ffff3ffff3ff3ffff3ff3ffff8888ff4411144f4417144f4411144ffffff2f2fffffffff2f2f2f2f2f2fffff2ffffff0ffffff0
000000002442222222222242f3bfb3fbfb3fbf3bfb3fbf3bff6f6fff44fff44f4411144f44fff44fffffff2fffffffff2f2f2f2f2f2fffff2f2fffff0ffffff0
fffff2f29999999922fffffffffffffffffffffffffffffffffffffffafafafff666666600000000222224240dddddd11dddddddddddddd11ddddd110ffffff0
ffff2f2f9999999944222fffffffffffffffffffffffffffffffffff88aaaa88666656650000000042424242dd1d1111ddddddddddd11111ddddd1110ffffff0
fff2f2f2999999994444422ffffffffffffffffffffffffff3ffffff88c11188656555550000000044242444d1111111ddd1d1d111111111dd1d11110ffffff0
ff2f2f229999999944444442ffffffffffffffffffeffffff33ffbff1ccc1c1f665555550000000044444444d1111111dddd1d1111111110d1d1d1110ffffff0
f2f2f2229999999922424444fffffffffffffffffe8effffff3fff3ff17771ff65655055000000004444444411111111dd1dd11111111110d11d11110ffffff0
2f2f222299999999ff2f2444fbcfffffff44444ffbeefffffb3ff3fff11111ff6555500f000000004444444411111111ddd11111111111101d1111110ffffff0
f2f2222299999999fffff244ff3ff3cfff4424ffff3ff3ffff3f3fff4411144f555550ff00000000f444444f01111110dd11111111111111111111110ffffff0
2f22222299999999ffffff22fb3cbf3bfb4424fffb3fbf3bfb3f3fbf44fff44fff55ffff00000000ffffffff00111000d111111111111101111111110ffffff0
ffb33bffb3b33bbbb3b33bbb11565511442ffffffffff222fffffffff6666666066666605ffffffffffffff50dddddd1d111111111111100111111110ffffff0
fbb3b3bf3bb3b3b33bb3b3b311155111442ffffffffff224ffffffff666656656656656555ffffffffffff55ddddd1d11111111111101010111111100ffffff0
33333343333333434443334316555561422ffffffffff244ffffffff6565555565656655555ffffffffff555d1d1dd11d111111111110110111111100ffffff0
43434334434343344444433415777751222ffffffffff224ffffffff66555555565565565555ffffffff5556dd11d111d111111111110000111111100ffffff0
44332444443344444424244415770751422ffffffffff222ffffffff656555555555555556555ffffff55565d1111111d111111111110000111111000ffffff0
24422244444444424442424215707751442ffffffffff244222222226555555055555555656555ffff555656111111111111111111010000111100010ffffff0
f424242f242424242424242415777751442ffffffffff2442442224455555500505555506655555ff55655661111111011111111101000001110000000ffff00
ff4242ff224242222242422216555561222ffffffffff24444422444ff5550000505000066656555555566661111100011111101010100001100000000000000
4444444fffb3b3b33b3bbfffffffff333fffffffffffffffff44444f5666666655666655444444242424444f42424244b3b3424222222222ff4424242424444f
44444444f3bb344433b3b3fffffff33333ffffffffffffffff44244f6666566555565665b44444424224444f244442442b33442222222222fff442424224444f
f44424443b344444444b3bbfffff3b444b3ffffffffffffff444244f65655555556565663b4444242422444f22244444b224444222222222fff444242422444f
4444244fb3444444244444b3fff3b34444b3fffffffffffff44224446655555555555666f344424242444444242424444222242422222222fff444424244444f
44424444b44444222444433bff3bb3444433bffffbfff3fff44244446565555555556565f344442424244244222224244424424222222222ffff444444444fff
f44244443444424242244333f3b3b422444b33bff33f3ffff442444f6555555005555555ff4442424222424f222242444244444422222222ffffffffffffffff
4444444434442422242444333b34444222444b33ff333ffff442444f5555550000555555ff4444242424444f222222244444444222222222ffffffffffffffff
4444444444424242224244433333444222443333fb33ffbf4444444f5555500000055555ff4442224244444f222222244424242422222222ffffffffffffffff
ff5555ffffffffffffffffffffffffffffffffffffffffff442444244424442444244424222222224aaaaaa99aaaaa9aaaaaaaa99aaaaa994aaaaaaaaaaaaa99
f555555fffffffffff5ff5fffff5fffff5fff5ffffffffff24244224242442244422442444224444aa9a9999aaaaaaaaaaa99999aaaaa999aa9aa999aaa99999
f555555fff5ff5fff55ff55ffff55fff55fff55ffff11fff22222222222222222222222244244444a9999999aaa9a9a999999999aa9a9999a9a9999999999999
f5dddd5ff55ff5ffff5ff5fffff5fffff5fff5fffff111ff00000000ffffffffffffffff22222222a9999999aaaa9a9999999994a9a9a999aaa9999999999999
f55d555fff555555ff5555555555555f555555ffff11211f00000000ffffffffffffffff4244422499999999aa9aa99999999994a99a9999aa99999999999999
f555555fff5ff5ff555ff5fffff5fffff5fff555f111221f00000000ffffffffffffffff4244442499999999a9a99999999999949a9999999999999999999949
f555555fff5ff55fff5fff5ffff5fffff5fff5fff111121100000000ffffffffffffffff2202222049999994aa99999999999999999999994499999999994444
f555555fff5fff5fff5fff5ffff5fffff5fff5ff1111112100000000ffffffffffffffff0000000044999444a999999999999949999999994449999999444444
ffd22dffd2d22dddd2d22ddd02dd2d200000000000000000222e2e22eeeeeeee21222222eeeeeeee4aaaaaa9a99999999999994499999999eeee2eeeffffffff
fdd2d2df2dd2d2d22dd2d2d22222d2d2d11101000110111d2e222222e2eeeee212122222eeeeeeeeaaaaa9a9999999999994949499999994e2e22e2effffffff
222222122222221211122212222222221110100000010111e22e22e2ee2ee2ee21222222eeeeeeeea9a9aa99a99999999999499499999994e22ee2e2ffffffff
12121221121212211111122112222222d11101000010111d22e22e22e2eeeeee12121222eeeeeeeeaa99a999a999999999994444999999942e22eeeeffffffff
1122011111221111110101111222022200000000000000002e22e222eee2e2ee21222222eeeeeeeea9999999a99999999999444499999944e222e2eefff88fff
01100011111111101110101001202021d11101100110111d22e2222eeeeeeeee12121222eeeeeeee99999999999999999949444499994449e2e22e2eff8118ff
f101010f010101010101010101010100111010000001011122222e222ee2ee2e21212222eeeeeeee99999994999999999494444499944444e22222e2f818118f
ff1010ff001010000010100000101000d11101100010111d22222222eeeeeeee12121222eeeeeeee999994449999994949494444994444442222222e81111118
4444444fffd2d2d22d2ddfff010001010000000f00000fff00000000f0f00000f0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8
44444444f2dd211122d2d2ff101010100000f0ff0000f0ff00000000ff0f00000ffffffff0fff0ffffffffffffffffffffffffffffffffffffffffffffffff82
f44424442d211111111d2ddf1101011100000f0f00000f0f00000000fff0f00000f0ffff0f0f0f0ffffffffffffffffffffffffffffffffffffffffffffff888
4444244fd2111111011111d21111111100f000ff0000f0ff0f0f0f0fff0f0f00f00ffffff0f0f0f0ff888888ffffffffffffffffffffffffffff8fffffff8281
44424444d11111000111122d111111110f0f0f0f00000ffff0f0f0f0fffff0f00000f0ff00000000ff888ff8fffffffffffffffffffff88f8ff888fffff88811
f44244442111101010011222111111110000f0ff0000f0ff0f0fff0fffff0f0f00f00fff00000000ff88ffffffffffffffffffffffffff888f8888ffff828111
444444442111010001011122f111111f0f0f0fff00000ffffffffffffffffff0000000f000000000ff88f888fffffffffffffffffffffff888ff88fff8881111
444444441110101000101112ffffffffffffffff000000ffffffffffffffff0f0000f00f00000000fff8f888fffffffffff88ff88ff88ff88fff88ff82811111
111111010101111f10101011d2d21010fff00000f11010000101111fdeeeeee2ffffff2ff2f2fffffffff88ffffffffff888f888f888fff88fff88ff8fffffff
d11111101001111f111110110d221100ff0f0000ff1101011001111fee2e2222fffff2f22f2f2ffffffff888f8ffff8f888888888888f888888f88ff28ffffff
2d1111010100111f11011111d0011110fff0f000ff1110100100111fe2e22222ffff2f2f22f2f2fff888ff88f88ff88fff888f888f888ff8888888ff888fffff
f2111010101111110111011110000101ff0f0000ff1111011011111fe22e22e2fffff2f2222f2f2fff88fff8ff8ff88fff88ff88ff88fff88ff88fff1828ffff
f2111101010110111010010111011010fff0f000fff1111111111fffe2222222ffffff2f2222f2f2ff88ff88ff8ff88fff88ff88ff88fff88fffffff11888fff
ff1110101000101f0110101110111111ff0f0000ffff111111ffffff22222e2efffff2f222222f2fff88ff88f88f888fff88ff88ff88fff888ffffff111828ff
ff1111010101111f1111111111111110fff0f000ffffffffffffffffd22222edffffff2f222222f2ff88888ff888888ff888f888f888fff888ffffff1111888f
ff1110001011111f1111111111010101ff0f0000ffffffffffffffffdd222eddfffff2f22222222ffff8888ff88fff88ff8fff8fff8ffff88fffffff11111828
12000000000000e3f300000000000000e3a4b1b1b200000000c2d2b2b20000000000a400000000000000000000000000820000a4000045969696000000000000
00000000a4c1d1e100000000000000000000000000a400000087d3d3d3d3d3d397a40000e4f4a400000000000000b20000000000000000000000000000000000
1200000000000000000000000000000000a4b2b2b2b2b1b2b2b1b1b1b20000000000a400000000000000000000000000000000a4000045919191646464860000
00000000a4c2d28200000000000000000000b1b2b1a400000000a0d3d3d3d3d3d397c0c0c0c0a400000000000000000000000000000000000000000000000000
1200000000000000000000000000510000a4b2b1b1b2b1c1d1b2b273820000000000a400000000000000000000f6f700000000a4000045919191919191918600
00000000a4b1b100000000000000000000b1b1b1b1a400000000a4a0d3d3d3d3d3d3d3d3d3d3a400000000000000000000000000000000000000000000000000
1200000000000000000050000000120000a4b1b2b2b2b1c2d2c1d100000000000000a40000f500000000000000b1b100000000a4000045919191919191919186
00000000a4e1b1000000000000000000e1b1b1c1d1a4000000000087d3d3d3d3d3d3d3d3d3d3a400000000000000000000000000000000000000000000000000
120000000000000000002297c001d3e000a4c1d1b2b2917382c2d200000000000000a400f682f7000000000000738300000000a400004591f09191f09191f091
64550000a4e2b1b1000000000000b1b1e2b1f0c2d2a4000000000000a0d3d3d3d3d3d3d3d3d3a400000000000000000000000000000000000000000000000000
1200000061615100c001d3d3d3d3d00000a4c2d2b2b1b10000000000000000000000a400b1b2b2f70000000000b2b200000000a400004591f19191f19191f191
91550000a4b1b1b1b11424343444b2b1b1b1f1b1b2a400000000000000a0a4d3d3d3d3d3b4c4a400000000000000000000000000000000000000000000000000
1200000013222300d3d3d3d3d3d3e00000a4828282000000000000000000000000f6a400b1b291b20000000000b2b200000000a400007691f29191f29191f291
91550000a4b1b1b1b1b10084848484b1c1d1f2b1b1a4000000000000c001d3d3d3d3d3d3b5c5a400000000000000000000000000000000000000000000000000
12000000e3a1f300d3d3d3d3d3d0000000a4828282000000000000f6f7000000f6b2a4000000b2e1b2000000b2b20000000000a4000000769191919191919191
91550000a4b1b1b1b1b1000000000000c2d2b1e1b1a400000000c001d3d3d3d3d3d3d3d3d000a400000000000000000000000000000000000000000000000000
1223000000000000d3d3d0b0b000000000a40000000000000000f6b2b2f700f6b2b1a400000000e291b27382b2000000000000a4000000007664646464919191
91550000a4c1d1b1b10000000000000000b1b1e2b1a400000087d3d3a4d3d3d3d3d3d0b00000a400000000000000000000000000000000000000000000000000
12a3000000000000d3d000000000000000a40000000000005000b2c2c1d182b2b2e1a40000000000b291c1d1b2000000000000a4000000000066666666666691
91550000a4c2d2b1b1000000000000000000b2c1d1a400000087d3d3d3d3d3d3d3d000000000a400000000000000000000000000000000000000000000000000
12f3000000000000b00000000000000000a400000000000072b2b1b2c2d2b1b2b2e2a40000000000b2b2c2d2b2000000000000a4000000000000000000000076
91550000a4b1b1e1b1b10000000000000000b1c2d2a40000c001d3d3d3d3d3d3d00000000000a400000000000000000000000000000000000000000000000000
1200005000000000000000000000000000a4000000000000000000e1b2b2b2e1b2b2a4000000000000b2b2b291b22434000000a4000000000000000000000000
76550000a4b1b1e2b1b10000000000000000738282a40087d3d3d3d3d3d3d3d3e00000000000a400000000000000000000000000000000000000000000000000
1200000200000061000000000000000000a4000000000000000000e2b2b2b2e291b2a40000000000000000b2e1b12535000000a4740000000000000000000000
00000000a4b1b1b1b1e1000000000000000000b1b1a4a487d3d3d3d3d3d3d3d0000000000000a400000000000000000000000000000000000000000000000000
1200000000000013230000000000000000a40000000000000000f682b2b1b29191b2a40000000000000000b1e2b1b2b1000000a4000000000000000000000000
00000000a4b1b1b1b1e200000002000000000000b1a40000a0d3d3d3d3d3d397c0c0c0000000a400000000000000000000000000000000000000000000000000
12000000000013c3b34351500000000000a400000000000000f68282b2b2b2b2b2b2a40000000000000000b19191b100000000a4000000000000000000000000
00000000a4b1b10000000000000000000000000000a4000000a0d3d3d3d3d3d3d3d3d397c0c0a400000000000000000000000000000000000000000000000000
12000000000093b3b3b322222300000000a4000000000000f682b2b2c1d1b2b2e1b2a40000000000000000b1b2b10000000000a4000000540000000000000000
00000000a4b1000000020000000000000000000000a4000000a4a0d3d3d3d3a4d3d3d3d3d3d3a400000000000000000000000000000000000000000000000000
120000000000e3a1a1a1a1a1f300000000a400000000000072b2b1b2c2d2b2b2e2b2a40000000000000000b1b1b10000000000a4000000829191919191919191
91560000a400000000000000000000000000000000a40000000000b0b0b0b0a0d3d3d3d3d3d3a400000000000000000000000000000000000000000000000000
1200000000000000000000000000000000a400000000000072b2b2b28282b2b2b2b1a44434001424442424b182000000000000a4000000459191919191919191
91560000a461000000000000000000000000000000a40000000000000000c001d3d3d3d3b4c4a400000000000000000000000000000000000000000000000000
1250000000000000000000000000000000a400000000000072b19191b2b2b2f0b2b2a4152600b1b1b1b1b1c1d1000000000000a4000000459191919191919191
91560000a422222300000000000000000000000000a40000000000000001d3d3d3d3d3d3b5c5a400000000000000000000000000000000000000000000000000
1223000000000000000000000000005061a400000000000072d291919191b2f2b273a4e1b1b1b1b1b1b1b1c2d2000000000000a4000000459191919191919494
94550000a4b1f0b100000000000000000000000000a4c0000000000087d3d3d3d3d3e4f4e4f4a400000000000000000000000000000000000000000000000000
12f3000000000000000000000000001312a400000000000072e2b2f0b2b1b2b2b1b2a4e2b1b1b1b1359191b1b1000000000000a40000004791f09191f09191f0
91560000a4b1f1b1b1000000000000000000000000a4d397c0c0c00087d3d3d3d3d3d3e00000a400000000000000000000000000000000000000000000000000
12000000005000000000000000000093d3a400000000000072b2b2f2b2b2b2b2c1d1a4b1b1c1d1b1e19191b100000000000000a40000004791f19182f19191f1
91560000a4e1f2b1b1b15300000000000000000000a4d3d3d3d3d3e087b4c4d3d3d3d3e00000a400000000000000000000000000000000000000000000000000
120000001312435300000000000000e3a1a400000000000072b2b1b28282b2b2c2d2a4b1b1c2d2b1e2b191b100000000000000a40000004791f29191f29191f2
91560000a4e2b1b194948200000000000000000000a4d3d3a5d3d3e087b5c5d3d3d3d3e00000a400000000000000000000000000000000000000000000000000
1200000093d3b323000000000000000000a400000000000072b2b2b2b1b2b2b1b2b2a4b1b1b2919191b1e1b100000000000000a4000000479191919191919191
91560000a4b1b1b1c1d18200000000000000000000a4d3d3d3d3d3e087d3d3d3d3d3d3e00000a400000000000000000000000000000000000000000000000000
12000000e3a1a1f3000051500000000000a400000000000000c1d1b2b2e1b2919191a4b2b135d1b191b1e2b134000000000000a4000000479191919191919191
91560000a4e1b1b1c2d28274000000000000000000a4d3d3d3d0b00087d3d3d3d3d3d3e00000a400000000000000000000000000000000000000000000000000
120000000000000097c013230000000000a400000000000000c2d2b2b2e2919191b1a4b1b1c2d2c1d1b1b2b226000000000000a4000000479494919191919191
66460000a4e2b2b1b1b1b100000000000000000000a4d3d3d397c00087d3d3d3d3d3d397c0c0a400000000000000000000000000000000000000000000000000
1200000000000000d3d3d3d00000000000a4000000000000728282b2b2b29191b282a40000b191c2d29191b167000000000000a4000000479191919191919156
00000000a4b1b2b2e191b100000000000000000000a4d3d3d3d3d39701d3d3d3d3d3d3d3d3d3a4a4000000000000000000000000000000000000000000000000
1200000000000000d3d3d0000000005300a400000000000072b2b2b2b191f0c1d1b2a4000000b1b1829191b100000000000000a4000000479191919191829156
00000000a48282b1e2f0b100000000005053610000a4d3d3d3d3d3d3d3e4f4d3d3d3d3d3e4f4a4a4000000000000000000000000000000000000000000000000
1200000000000000b0b000000000131212a4000000000000729191919191f2c2d2b1a400000000b1b1b191b214243400000000a4000000479191919191919156
00000000a4b1b2b1b1f1b100000000001312230000a4b0b0b0b0b0b0a0d3d3d3d3d3d3d3d4a4a4a4000000000000000000000000000000000000000000000000
1200000000000000000000000013c3d3d3a4000000810000b1b191c1d19191e1b2b2a400000000b1c1d1919182822600000000a4000000479191919166666646
00000000a4b1c1d1b2f2b20000000000e3a1f30000a400000000000087d3d3d3d3d3d3d3d5a4a4a4000000000000000000000000000000000000000000000000
12003041000061535150006113c3d3d3d3a4000000000000b1b2b2c2d2b2b2e2b2b1a4000400b1b1c2d291b1b1b11700000000a4000000479191915600000000
00000000a4b1c2d2b2b2b200000000000000000000a400000000000000a0d3d3d3d3d3d3a5a4a4a4000000000000000000000000000000000000000000000000
121212121212121212121212c3d3d3d3d3a4000000000000b1b1b2b2b1b282b2b2b2a4251526b1b1b1b1b1b1b1b11700000000a4000000459494914600000000
00000000a494949494949400000000000000000000a40000000000000000a0d3a5a4d3d3d3f4a400000000000000000062000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000100010000000000010101000000000101000000000000000101010000000001010101010100010100000000000001010101010101010101010101010101000000000101010100000101010100000000000000000000000001010101000101000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
21000000000000000000000000000000004a0000001b1b1b1b0000000000000000004a000000000000000000000000000000004a282800000000000000000000000000004a000000000000000000000000000000004a0000000000000000000000000000000000000000000000004a0000000000000000000000000000000000
21000000000000000000000000000000004a0000002b2b1b2b0000000000000000004a0000001b0000004440430000000000004a280000000000000000000000000000004a000000000000000000000000000000004a0000000000000000000000000000000000000000000000004a0000284747474747474747474728000000
21000000000000000000000000000000004a0000002b1e2b280000000000000000004a00001b1e1b1b1b6151526200000000004a000000000000000000000000000000004a000000000000000504161335030000004a0000000000000000000000000000000000000000000000004a0000240000000000000000000025000000
21000000000000000000000021000000004a0000002b2e192b0000000000000000004a001b1b2e1b2b1b0000000000000000004a000000000000000000000000000000474a00000000000c0c3121212121213200004a0000000000000000000000000000000000000000000000004a0000240000000000000000000025000000
2100000000000000790c0c103d0e0000004a0000002b191e2b0000000000000000004a1b1c1d1b1b1b000000000000000000004a000000000000450000000047000000004a00000000103d3d3d3d3d3d3d3d3d00004a0000000000000000000000000000000000000000000000004a0000282626262626262626262628000000
2100000000000000213d3d3d0d000000004a0000002b192e1b00000000006f7f00004a1e2c2d1b0000000000000000000000004a494949494949550000000000000000004a350305103d3d3d3d3d3d3d3d3d0d00004a0000000000000000000000000000000000000000000000004a0000000000000000000000000000000000
21000000000000003d3d3d0d00000000004a0000002b37282b2b0000006f1b1b7f004a2e1b1b000000000000000000404300004a191919191919550000000000000000004a2121213d3d3d3d3d3d3d3d3d3d0e00004a0000000027000000000000000018000000000000000000004a0000000000000000000000000000000000
21000000000000000d0b0b0000000000004a0000002b2b2b1c1d2b2b6f1b1b1b1b7f4a1c1d00000000000000000000616200004a1919190f1919550000000000000000004a3d3d3d3d3d3d3d3d3d3d3d3d0d0000004a0000000027494949494949494928000000000000000000004a0000000000000000000000000000000000
21000000003132000000000000000000004a000000002b1b2c2d192b1e2b1b2b1b2b4a2c2d00000000000000000041707100004a1919191f1919550000474700000000004a3d3d3d3d0d0b0b210b0b0b0b000000004a00000027281b1b1e1b1b1c1d1d28000000000000000000004a0000000000000000000000000000000000
2100000000393a000000000000000000004a00000000002b19192b2b2e2b1c1d2b2b4a1b1b00000000004243000061737100004a1919192f1919550000000000000000004a3d3d3d0d0000000000000000000000004a000000001b1b1b2e1b1b2c2d2d28000000000000000000004a0000003700000900000600003800000000
21000000003e3a351500000000000000004a00000000002b2b37281919192c2d2b2b4a1b1b1b0000000061620000756376001e4a191919191919550000000000000000004a3d3d0d000000000000000000131400004a000000001b2b2b2b2b1e2b2b2b28000000000000000000004a0000002749494949494949492800000000
2100000000003b223200000000000000004a000000000000002b2b2b191919190f2b4a1b1b1b1b0000001b1b0000000000002e4a191919191919650000000000000000474a3d0d00000000000000000031222132004a000000001b2b1b2b2b2e2b2b2b28000000000000000000004a000000271b1b1e1b1b1c1d1d2800000000
21222200000000000000000000000405004a00000000000000002b2b2b3728191f194a1b1b1c1d1b2b2b1b1b00414344001b1b4a191919191919650000000000000000004a0d00000005160400000000393d3d3a004a000000001b1b2b2b2b2b2b2b2b28000000000000000000004a000000271b1b2e1b1b2c2d2d2800000000
21000000000000000000000000003132004a00000000000000000000002b1e191f194a1b1b2c2d1b1b1b1b1b421b1b1b1b1c1d4a191919191919650000000000000000004a00000000312132000000003e1a1a3f004a0000282828281b1b1b1b1b1b1b28000000000000000000004a000000272b2b2b2b1e2b2b2b2800000000
21000000000000000000000000003e3f004a00000000000000000000002b2e192f1e4a1b1b2800001b1b1b1b1b1b001b0f2c2d4a191919191919650000474800000000004a000000003e1a3f0000000000000000004a00000000371b1b1b1b281b1b1b38000000000000000000004a000000272b1b2b2b2e2b2b2b2800000000
21000000002200000000000000000000004a00000000000000000000001c1d19192e4a191b1b001b1c1d1b1b0000001b1f1b1b4a191919191919650000000000000000004a000000000000000000000000000000004a00000000271b1b1b1b1b1b1b1b28000000000000000000004a000000272b2b2b2b2b2b2b2b2800000000
21000000000000000000000000000000004a00000000000000000000002c2d2b37284a19192b00002c2d1b1b00001e1b2f1b1b4a1919190f1919650000000000000000004a050416350000000000000000000000004a00000000371b1b1b1b1b1b1b1b38000000000000000000004a00000000393c3b3b3c3b3b3a0000000000
21000000000000000000000000000000004a00000000000000000000002b2b1e2b1b4a1b191b0000001b531b1b1b2e191b531b4a1919191f1949550000000000000000004a212121320000000000000000000000004a00000000371b281b1b1b1b1b1b38000000000000000000002b0000002847484748474847482800000000
21000000000000001300000000000000004a00000000000000000000002b2b2e2b2b4a1b1b1b000000001e0000001b19191c1d4a1919192f1919550000000000000000004a2e2b0f2b2b00000000000000000000004a00000000271b1b1b1b1b1b1b1b2800000000000000000000240000002400000000000000002500000000
2100000000000000200000000000210c0c4a0000000000000000000037281b2b2b2b4a1c1d1e000000002e0000001b1b1b2c2d4a191919191919550000000000000000004a1b1b1f1b1e1b000000000000000000004a00000000371b1b1b1b1b1b1b1b3800000000000000000000240000002400000000000000002500000000
21000000000000000000000000000a3d3d4a0000000000000000006f2b2b2b1c1d2b4a2c2d2e000000001b00000000001b1b1b4a191919191919550000000000000000004a1c1d2f1b2e00000000000000000000004a00000000271b1b1b1b1b1b1b1b2800000000000000000000240000002400000000000000002500000000
2100000000000000000000053505000b0b4a0000000000000000001c1d1e2b2c2d2b4a1b192b000000001e0000616200001b1b4a191919191919550000000000000000004a2c2d1b1b1b000000000000002b1e2b2b4a000000002b1b1b1b1b1b282b2b3800000000000000000000240000002400000000000000002500000000
21000000000000000000003121320000004a0000000000000000002c2d2e2b2b2b1b4a1b1b2b000000002e000075760000001b4a494919191919550000000000000000004a1b1b1b47470000000000001b2b2e2b2b4a000000002b2b1b1b1b1b2b2b2b3800000000000000000000240000002400000000000000002500000000
21000000000000000000783d3d3b0e00004a000000000000181818282b1b0f2b2b1e4a1b1b00000061621b00000000000000004a191919191919550000000000000000004a1e1b00000000000000271b1b1b2b2b2b4a000000002b281b1b1b1b2b2b2b2800004a00000000000000240000002400000000000000002500000000
21000000000000050500783d3d3d7900004a0000000000000000001e2b2b1f2b2b2e4a1b0000000075761b00000000000000004a1919190f1919550000000000000000004a2e0000000000000000000000002b1c1d4a000000002b2b1b1b1b2b2b2b2b2800004a00000000000000240000002400000000000000002500000000
21000000000000313200000a3d3d3d79314a0000000000000000002e2b2b2f2b372828000000000000002b00000000000000004a1919191f4949550000000000000000004a00000000000000000000000000152c2d4a000000002b1b1b1b2b2b2b2b2b3800004a00000000000000240000002400000000000000002500000000
21000000000000003d0e00783d3d3d3d3b4a7f00000000000000001c1d1b2b2b1c1d4a004000000000000000000000000000004a1919192f1919650000000000000000004a000000000000000000000000003121214a000000006766666666666666640000004a00000000000000240000002400000000000000002500000000
21000000000000000d0000783d3d3d3d3d4a2b7f000000000000002c2d2b1e2b2c2d4a525253000000000000000000000000004a191919191919640000000000000000004a000000000000000000000000003e1a1a4a00000000000c0c0c280c0c0c000000004a00000000000000240000002826262626262626262800000000
2100000000000000000000000a213d3d3d4a1c1d0000000000000037282b2e1919194a636376000000000000000000000000004a191919191964000000000000000000004a000000000000051635160500000000004a00000000783d3d3d3d3d3d3d0e0000004a00000000000000240000000000000000000000000000000000
210000002200000000000000000a3d3d3d4a2c2d050000000000002b2b2b1919192b4a000000000041424044000000000000004a191919196400000000000000000000004a000000000000312121223200000000004a00000000783d3d3d3d3d3d3d0e0000004a00000000000000240000000000000000000000000000000000
21000000000000050500000000000b0a3d4a2828380000000000002b1b1b2b1b2b2b4a000000000051525253000000000000004a474847470000000000000000000000004a0000000000003e1a1a1a3f00000000004a00000000103d4a3d3d3d3d0d000000004a00000000000000240000000000000000000000000000000000
21000000000000313200000000000000314a2b2b2b000000001c1d2b2e2b2b28281b4a000000000075636376000000000000004a000000000000000000000000000000004a000000000000000000000000000000004a000000783d3d3d3d3d3d0d00000000004a00000000000000000000000000000000000000000000000000
__sfx__
0101000009710097100a7100b7200c7200e7200f7201172013720177301b7301f7302273027730297302d40031400384000000000000000000000000000000000000000000000000000000000000000000000000
000200000000011030100300e0300c030080200502003010010100101004000020000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000126301462016620186301c6302063023640276402d6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000b6160d6160c616096160561603616046160461605616076160861608616096160a6160b6160b6160c6160c6160b6160a61608616066160561605616056160661607616096160b616096160861608616
000100002c447294372643724437214371d4271a4271742714427114270e4170a41706417024070040708407084070740705407054070540704407034070340706407094070d4070f4070f4070c4070740701407
00080000007510275104751067510a751107511d7511c7510e7510875104751037510a751107511b75128751147510c75108751077510b7511075118751217512b75117751117510b75106751037510175100701
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
