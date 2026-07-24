pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--global warming
--by @dollarone
--for the 2019 lowrezjam

--print string with outline.
function printo(str,startx,starty,col,col_bg)
	print(str,startx+1,starty,col_bg)
	print(str,startx-1,starty,col_bg)
	print(str,startx,starty+1,col_bg)
	print(str,startx,starty-1,col_bg)
	print(str,startx+1,starty-1,col_bg)
	print(str,startx-1,starty-1,col_bg)
	print(str,startx-1,starty+1,col_bg)
	print(str,startx+1,starty+1,col_bg)
	print(str,startx,starty,col)
end

--print string centered with 
--outline.
function printc(
	str,x,y,
	col,col_bg,
	special_chars)

	local len=(#str*4)+(special_chars*3)
	local startx=x-(len/2)
	local starty=y-2
	printo(str,startx,starty,col,col_bg)
end

function go_to_menu()
	state=2
end

function contains(t, n)
	for i=1,#t do
		if t[i]==n then
			return true
		end
	end
	return false
end
function help_off()
	help=not help
	if help then
		timeouts=180
	else
		timeouts=2
	end
end

function _init()
	poke(0x5f2c,3)
	palt(14,true)
	palt(0,false)
	menuitem(1, "retry level", restart)
	menuitem(2, "change level", go_to_menu)
	menuitem(3, "toggle help", help_off)
	player={}
	default_player_spr=68
	state=2
	timeouts=180
	map_x=0
	map_y=0
	restart()
	intro_init()
	help=true
	level_select=1
end

function restart()
	ticks=0
	trees={}
	wood=false
	rock=false
	water_level=0
	trees_spr=90
	house=false
	player.x=10
	player.y=12

	--copy_map(23,0) ezier
	--copy_map(13,0) ez
	--copy_map(113,0) ez/med1
	--copy_map(83,0) ez/med2

	--copy_map(33,0) med
	--copy_map(73,0) med2
	--copy_map(93,0)  med3
	--copy_map(103,0)  med4

	--copy_map(43,0) hard
	--copy_map(53,0) harder
	--copy_map(63,0) tricky
	--copy_map(13,10) trickest 
	copy_map(map_x,map_y)
	prepare_map()
	mess_timeout=timeouts
	overlay_timeout=0
	water_timeout=0
	introtext=true
	mess_text="oh no! \nmy house!"
	cantmove=false
	house_sprite=152
	gameover=false
	select=false
	player.offset_x=0
	splash=false
	player.spr=default_player_spr
	death_msg=""
	death=false
	win=false
	float=false
	win_timeout=0
	float_spr=28
end

function can_go(x,y,check_sea)
	check_sea=true
	if check_sea and mget(x,y)==1 then
		return false
	end
	found_tree=false
	for i in all(trees) do
		if i[1]==x and i[2]==y then
			found_tree=true
			return false
		end
	end
	--obsolete:
	if mget(x,y)==6 or mget(x,y)==3 then
		return false
	end
	altitude_cur=fget(mget(player.x,player.y))
	altitude_next=fget(mget(x,y))
	--1,4,7,9
	if altitude_next-altitude_cur>3 then
		return false
	end
	return true
end


function _update60()
	ticks+=1
	if intro then
		intro_update() 
		return
	end

	if state==2 then
		if btnp(0) then
			level_select-=1
			if level_select<1 then
				level_select=12
			end
		end
		if btnp(1) then
			level_select+=1
			if level_select>12 then
				level_select=1
			end
		end
		if btnp(3) then
			level_select+=2
			if level_select>12 then
				level_select=1
			end
		end
		if btnp(2) then
			level_select-=2
			if level_select<1 then
				level_select=12
			end
		end

		if btnp(4) or btnp(5) then
			map_y=0
			if level_select==1 then
				map_x=23
			elseif level_select==2 then
				map_x=13
			elseif level_select==3 then
				map_x=113
			elseif level_select==4 then
				map_x=83
			elseif level_select==5 then
				map_x=33
			elseif level_select==6 then
				map_x=73
			elseif level_select==7 then
				map_x=93
			elseif level_select==8 then
				map_x=103
			elseif level_select==9 then
				map_x=43
			elseif level_select==10 then
				map_x=53
			elseif level_select==11 then
				map_x=63
			elseif level_select==12 then
				map_x=13
				map_y=10
			end
			restart()
			state=1
			return
		end
	end
	if win then
		if btnp(5) or btnp(4) then
			state=2
		end
		return
	end
	if gameover then
		overlay_timeout=0
		mess_timeout=0
		if btnp(4) or btnp(5) then
			restart()
		end
		return
	end
	if (not rock and not wood) and not death and water_level<7 and can_go(player.x-1,player.y,true)==false and can_go(player.x+1,player.y,true)==false and 
		can_go(player.x,player.y-1,true)==false and can_go(player.x,player.y+1,true)==false then
		--gameover=true
		mess_text="i can't go\nanywhere!"
		mess_timeout=timeouts
		death=true
	end
	if win_timeout>0 then
		win_timeout-=1
	end
	if win_timeout==1 then
		win=true
		sfx(7)
	end
	if overlay_timeout>0 then
		overlay_timeout-=1
	end
	if mess_timeout>0 then
		mess_timeout-=1
	end
	if mess_timeout==1 and death then
		gameover=true
	end
	if mess_timeout==1 and introtext then
		overlay_timeout=timeouts
	end
	if mess_timeout==1 and not introtext then
		mess_text="build at\nsea level"
	end
	if overlay_timeout==1 and introtext then
		mess_timeout=timeouts
		mess_text="\x8e harvest\n\x97 build"--"must build\nby the sea"
		introtext=false
	end
	if overlay_timeout==1 and not introtext then
		
	end
	if water_timeout>0 then
		water_timeout-=1
	end
	if water_timeout==40 then
		sfx(8)
	end

	if water_timeout==1 then
		raise_water()
		mset(player.x,player.y,float_spr)
		prepare_map()
		player.spr=default_player_spr
		if water_level==7 then
			mess_text="wow! well\ndone me!"
			win_timeout=timeouts
		else
			mess_text="oh no!\nmy house!"
		end
		introtext=true
		wood=false
		rock=false
		house=false
		mess_timeout=timeouts
		cantmove=false
	end
	if cantmove then
		if btnp(4) or btnp(5) then
			if overlay_timeout>2 then
				overlay_timeout=2
			end
			if mess_timeout>2 then
				mess_timeout=2
			end
		end
		 return
	end
	if select then
		if btnp(0) then
			if harvest(player.x-1,player.y) then
				sfx(9)
			else
				sfx(0)
			end
		end
		if btnp(1) then
			if harvest(player.x+1,player.y) then
				sfx(9)
			else
				sfx(0)
			end		end
		if btnp(2) then
			if harvest(player.x,player.y-1) then
				sfx(9)
			else
				sfx(0)
			end		end
		if btnp(3) then
			if harvest(player.x,player.y+1) then
				sfx(9)
			else
				sfx(0)
			end		
		end
	else
		if btnp(0) and can_go(player.x-1,player.y) then -- and fget(mget(player.x-1,player.y),0) then
			player.x-=1
			player.spr=70
			player.offset_x=-3
		end
		if btnp(1) and can_go(player.x+1,player.y) then
			player.x+=1
			player.spr=72
			player.offset_x=0
		end
		if btnp(2) and can_go(player.x,player.y-1) then
			player.y-=1
			player.spr=66
			player.offset_x=-3
		end
		if btnp(3) and can_go(player.x,player.y+1) then
			player.y+=1
			player.spr=68
			player.offset_x=0
		end
	end
	if btnp(4) then 
		select=not select
		if mess_timeout>0 then
			mess_timeout=2
		end
		if overlay_timeout>0 then
			overlay_timeout=2
		end
	end
	if btnp(5) then
		if mess_timeout>0 then
			mess_timeout=2
		end
		if overlay_timeout>0 then
			overlay_timeout=2
		end
		--overlay=not overlay
		if rock and wood then
			if get_next_water_level()==fget(mget(player.x,player.y)) and has_sea_view(player.x,player.y)
				and mget(player.x,player.y)~=28 and mget(player.x,player.y)~=29 and mget(player.x,player.y)~=30 then
				player.spr=house_sprite
				player.offset_x=0
				cantmove=true
				water_timeout=120
			elseif mget(player.x,player.y)==28 or mget(player.x,player.y)==29 or mget(player.x,player.y)==30 then
				sfx(0)
				mess_text="this won't\nsupport it"
				mess_timeout=timeouts
			elseif get_next_water_level()~=fget(mget(player.x,player.y)) then
				sfx(0)
				mess_text="build at\nsea level"
				mess_timeout=timeouts
				--cantmove=true
			else
				sfx(0)
				mess_text="build next\nto the sea"
				mess_timeout=timeouts
				--cantmove=true
			end
		end
	end
	if splash and player.spr==100 and flr(rnd(8))==1 then
		player.spr=102
		gameover=true
		death_msg=" oops, you\n  drowned!"
	end
	if not gameover and water_level>=fget(mget(player.x,player.y)) then
		player.spr=100
		player.offset_x=0
		splash=true
	end
end

function copy_map(x1,y1)
	for x=3,12 do
		for y=5,14 do
			mset(x,y,mget(x-3+x1,y-5+y1))
		end
	end
end

function harvest(x,y)
	found_tree=false
	for i in all(trees) do
		if i[1]==x and i[2]==y then
			del(trees,i)
			found_tree=true
		end
	end
	if found_tree then --mget(x,y)==6 or mget(x,y)==3 then
		--if mget(x,y)==3 then
		--	mset(x,y,5)
		--else
		--	mset(x,y,7)
		--end
		wood=true
		
		select=false
		overlay_timeout=timeouts
		--cantmove=true
		return true
	end
	if (mget(x,y)>8 and mget(x,y)<12) or (mget(x,y)>12 and mget(x,y)<15) or mget(x,y)==16 then
		mset(x,y,mget(x,y)-1)
		rock=true
		select=false
		overlay_timeout=timeouts
		--cantmove=true
		return true
	end
	return false
end

function raise_water()
	if water_level==0 then
		water_level=1
		house_sprite=152
		float_spr=28
	elseif water_level==1 then
		water_level=4
		trees_spr=92
		house_sprite=152
		float_spr=29
	elseif water_level==4 then
		water_level=7
		trees_spr=94
		house_sprite=152
		float_spr=30
	elseif water_level==7 then
		trees_spr=96
	end
end

function get_next_water_level()
	if water_level==0 then
		return 1
	elseif water_level==1 then
		return 4
	else
		return 7
	end
end


function _draw()
	cls(1)
	if intro then
		intro_draw()
		return
	end

	if state==2 then
		-- challenge menu
		print("GLOBAL WARMING",4,2,8)
		print("PICK A CHALLENGE",0,10,7)

		print("EASY1",1,20,10)
		print("EASY2",44,20,10)
		print("EASY3",1,26,10)
		print("EASY4",44,26,10)

		print("MEDIUM1",1,34,9)
		print("MEDIUM2",35,34,9)
		print("MEDIUM3",1,40,9)
		print("MEDIUM4",35,40,9)

		print("HARD1",1,48,8)
		print("HARD2",44,48,8)
		print("HARD3",1,54,8)
		print("HARD4",44,54,8)


		if level_select==1 then
			print("EASY1",1,20,7)
		elseif level_select==2 then
			print("EASY2",44,20,7)
		elseif level_select==3 then
			print("EASY3",1,26,7)
		elseif level_select==4 then
			print("EASY4",44,26,7)
		elseif level_select==5 then
			print("MEDIUM1",1,34,7)
		elseif level_select==6 then
			print("MEDIUM2",35,34,7)
		elseif level_select==7 then
			print("MEDIUM3",1,40,7)
		elseif level_select==8 then
			print("MEDIUM4",35,40,7)
		elseif level_select==9 then
			print("HARD1",1,48,7)
		elseif level_select==10 then
			print("HARD2",44,48,7)
		elseif level_select==11 then
			print("HARD3",1,54,7)
		elseif level_select==12 then
			print("HARD4",44,54,7)
		end
		return
		-- y/n
	elseif state==1 then
		for x=0,13 do
			for y=0,14 do
				o = mget(x,y)
				s=192
				offset_y=0
				if o==1 then
					s=192
				elseif o==2 then 
					s=224
				elseif o==3 or o==5 then 
					s=198
				elseif o==4 then
					s=90
				elseif o==6 or o==7 then
					s=196
				elseif o==8 then
					s=128
				elseif o==9 then
					s=228
				elseif o==10 then
					s=236
				elseif o==11 then
					s=226
				elseif o==12 then
					s=230
				elseif o==13 then
					s=232
				elseif o==14 then
					s=234
				elseif o==15 then
					s=200
				elseif o==16 then
					s=202
				elseif o==17 then
					s=204
				elseif o==25 then
					s=238
				elseif o==28 then
					s=160
				elseif o==29 then
					s=162
				elseif o==30 then
					s=164
				elseif o==31 then
					s=166
				end

				if o>27 and o<32 and flr((ticks+x*y)/100)%2==0 then
					offset_y=-1
				end
				if s==90 then
					spr(s, 40+8*x-8*y, -48+((y+x)*4),2,3)
				
				else--if s~=192 then
					spr(s, 40+8*x-8*y, -40+((y+x)*4)+offset_y,2,2)
				end
				if select then
					if (mget(player.x-1,player.y)~=1 or harvestable(player.x-1,player.y)==134) and x==player.x-1 and y==player.y then
						spr(harvestable(player.x-1,player.y),40+8*(player.x-1)-8*player.y, 1-40+((player.y+player.x-1)*4)-fget(mget(player.x-1,player.y)),2,2,player.flip,false)
					end
					if (mget(player.x+1,player.y)~=1 or harvestable(player.x+1,player.y)==134) and x==player.x+1 and y==player.y then
						spr(harvestable(player.x+1,player.y),40+8*(player.x+1)-8*player.y, 1-40+((player.y+player.x+1)*4)-fget(mget(player.x+1,player.y)),2,2,player.flip,false)
					end
					if (mget(player.x,player.y-1)~=1 or harvestable(player.x,player.y-1)==134) and x==player.x and y==player.y-1 then
						spr(harvestable(player.x,player.y-1),40+8*player.x-8*(player.y-1), 1-40+((player.y+player.x-1)*4)-fget(mget(player.x,player.y-1)),2,2,player.flip,false)
					end
					if (mget(player.x,player.y+1)~=1 or harvestable(player.x,player.y+1)==134) and x==player.x and y==player.y+1 then
						spr(harvestable(player.x,player.y+1),40+8*player.x-8*(player.y+1), 1-40+((player.y+player.x+1)*4)-fget(mget(player.x,player.y+1)),2,2,player.flip,false)
					end
				end

				for i in all(trees) do
					if i[1]==x and i[2]==y then
						spr(trees_spr,40+8*x-8*y, -51+((y+x)*4),2,3)
						if flr((ticks+x*y)/300)%2==1 then
							spr(74,40+8*x-8*y, -51+((y+x)*4),2,1)
						end
					end
				end

				if x==player.x and y==player.y then
					if player.spr>151 and player.spr<159 then
						spr(player.spr,player.offset_x+41+8*player.x-8*player.y, -42+((player.y+player.x)*4)-fget(mget(player.x,player.y))-5+offset_y,2,3)
		
					else
						spr(player.spr,player.offset_x+41+8*player.x-8*player.y, -42+((player.y+player.x)*4)-fget(mget(player.x,player.y))+offset_y,2,2)
					end
				end
			end
		end
	end
	if help and overlay_timeout>5 then
		rectfill(0,28,64,38,7)
		rect(-1,27,65,39,0)
		if wood then
			spr(48,3,30,2,1)
		else
			spr(32,3,30,2,1)
		end
		if wood and rock then
			spr(62,53,30)
		else
			spr(61,53,30)
		end
		spr(56,17,29)
 		spr(57,41,29)
 		if rock then
 			spr(34,26,29-7,2,2)
 		else
			spr(36,26,29-7,2,2)
		end
	end
	if help and mess_timeout>5 then
		player_x=min(32,max(16,player.offset_x+41+8*player.x-8*player.y))
		player_y=max(28,-42+((player.y+player.x)*4)-fget(mget(player.x,player.y)))
		spr(64,player_x-16, player_y-28)
		spr(65,player_x-8, player_y-28)
		spr(65,player_x, player_y-28)
		spr(65,player_x+8, player_y-28)
		spr(65,player_x+16, player_y-28)
		spr(64,player_x+24, player_y-28,1,1,true,false)
		spr(96,player_x-16, player_y-20)
		spr(80,player_x-8, player_y-20)
		spr(80,player_x, player_y-20)
		spr(80,player_x+8, player_y-20)
		spr(80,player_x+16, player_y-20)
		spr(96,player_x+24, player_y-20,1,1,true,false)
		spr(64,player_x+24, player_y-14,1,1,true,true)
		spr(64,player_x-16, player_y-14,1,1,false,true)
		spr(65,player_x-8, player_y-14,1,1,false,true)
		spr(65,player_x, player_y-14,1,1,false,true)
		spr(65,player_x+8, player_y-14,1,1,false,true)
		spr(65,player_x+16, player_y-14,1,1,false,true)
		spr(80,player_x+10, player_y-14)
		if player_x+10 < player.offset_x+41+8*player.x-8*player.y then
			spr(81,player_x+10, player_y-6,1,1,true,false)
		else
			spr(81,player_x+10, player_y-6)
		end
		print(mess_text, player_x-12, player_y-23,0)
	end

	if gameover then
		rectfill(0,17,64,38,7)
		rect(-1,17,65,39,0)
		--print(death_msg, 8, 4,0)
		print("  game over!\npress \x8e or \x97\n  to restart",5,20,0)
	end
	if win then
		rectfill(0,17,64,45,7)
		rect(-1,17,65,46,0)
		--print(death_msg, 8, 4,0)
		print("you've survived\nglobal warming!\npress \x8e or \x97\nfor the menu",3,20,0)
	end
end

function harvestable(x,y)
	test=get_next_water_level()
	if (test<fget(mget(x,y))) then
		if mget(x,y)>8 and mget(x,y)<18 then
			return 134
		end
	end
	for i in all(trees) do
		if i[1]==x and i[2]==y then
			return 134
		end
	end
	return 132
end
function has_sea_view(x,y)
	if mget(x-1,y)==1 or mget(x+1,y)==1 or mget(x,y-1)==1 or mget(x,y+1)==1 then
		return true
	end
	return false
end

function prepare_map()
	for x=3,11 do
		for y=5,13 do
			if mget(x,y)==4 then
				mset(x,y,7)
				add(trees,{x,y})
			end
			if mget(x,y)==44 then
				mset(x,y,28)
				player.x=x
				player.y=y
			end
			if water_level==1 then
				if mget(x,y)==7 then
					mset(x,y,5)
				elseif mget(x,y)==6 then
					mset(x,y,3)
				elseif mget(x,y)==9 then
					mset(x,y,12)
				elseif mget(x,y)==10 then
					mset(x,y,13)
				elseif mget(x,y)==11 then
					mset(x,y,14)
				elseif mget(x,y)==28 then
					mset(x,y,29)
				end
			elseif water_level==4 then
				if mget(x,y)==13 then
					mset(x,y,15)
				elseif mget(x,y)==14 then
					mset(x,y,16)
				elseif mget(x,y)==29 then
					mset(x,y,30)
				end
			elseif water_level==7 then
				if mget(x,y)==16 then
					mset(x,y,17)
				elseif mget(x,y)==30 then
					mset(x,y,31)
				end
			end
			if water_level>=fget(mget(x,y)) and mget(x,y)~=30 then
				mset(x,y,1)
			end
		end
	end
end

function arc(x, y, r, angle, c)
  circfill(x, y, r, 0)
 if angle < 0 then return end
 for i = 0, .75, .25 do
  local a = angle
  if a < i then break end
  if a > i + .25 then a = i + .25 end
  local x1 = x + r * cos(i)
  local y1 = y + r * sin(i)
  local x2 = x + r * cos(a)
  local y2 = y + r * sin(a)
  local cx1 = min(x1, x2)
  local cx2 = max(x1, x2)
  local cy1 = min(y1, y2)
  local cy2 = max(y1, y2)
  clip(cx1, cy1, cx2 - cx1 + 2, cy2 - cy1 + 2)
  circ(x, y, r, c)
  clip()
 end
end

function intro_init()
  map_x = 30
  map_y_org = 14
  offs=17
  music(0)
  intro=true
  extra=220
end

function intro_update()
	map_x -= 1
	if btnp"5" or btnp"4" or map_x < -470 then
		intro=false
		music(2)
	end
end

function intro_draw()
--	cls(0)

	map_y = map_y_org 
	spr(offs+1, map_x+48, map_y)
	spr(offs+1, map_x+80, map_y)
	spr(offs+1, map_x+96, map_y)

	map_y += 8
	spr(offs+5, map_x+32, map_y)
	spr(offs+7, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+5, map_x+56, map_y)
	spr(offs+7, map_x+64, map_y)
	spr(offs+3, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+5, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+5, map_x+136, map_y)
	spr(offs+1, map_x+144, map_y)

	spr(offs+5, map_x+152, map_y)
	spr(offs+7, map_x+160, map_y)
	spr(offs+3, map_x+168, map_y)

	spr(offs+5, map_x+176, map_y)
	spr(offs+7, map_x+184, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+5, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
	spr(offs+3, map_x+216, map_y)

	map_y += 8
	spr(offs+1, map_x+32, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+1, map_x+56, map_y)
	spr(offs+1, map_x+72, map_y)

	spr(offs+1, map_x+80, map_y)

	spr(offs+1, map_x+96, map_y)

	spr(offs+1, map_x+112, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+1, map_x+152, map_y)
	spr(offs+1, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+1, map_x+200, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y += 8
	spr(offs+2, map_x+32, map_y)
	spr(offs+7, map_x+40, map_y)
	spr(offs+1, map_x+48, map_y)

	spr(offs+2, map_x+56, map_y)
	spr(offs+7, map_x+64, map_y)
	spr(offs+6, map_x+72, map_y)

	spr(offs+2, map_x+80, map_y)
	spr(offs+1, map_x+88, map_y)

	spr(offs+2, map_x+96, map_y)
	spr(offs+1, map_x+104, map_y)

	spr(offs+2, map_x+112, map_y)
	spr(offs+7, map_x+120, map_y)
	spr(offs+1, map_x+128, map_y)

	spr(offs+1, map_x+136, map_y)

	spr(offs+2, map_x+152, map_y)
	spr(offs+7, map_x+160, map_y)
	spr(offs+6, map_x+168, map_y)

	spr(offs+1, map_x+176, map_y)
	spr(offs+1, map_x+192, map_y)

	spr(offs+2, map_x+200, map_y)
	spr(offs+7, map_x+208, map_y)
	spr(offs+6, map_x+216, map_y)

	map_y-=24
	--map_x+=100

	spr(offs+1, extra+map_x+104, map_y)
	spr(offs+1, extra+map_x+152, map_y)
	spr(offs+4, extra+map_x+168, map_y)

	map_y += 8

	spr(offs+7, extra+map_x+24, map_y)
	spr(offs+7, extra+map_x+32, map_y)
	spr(offs+3, extra+map_x+40, map_y)

	spr(offs+5, extra+map_x+48, map_y)
	spr(offs+1, extra+map_x+56, map_y)

	spr(offs+5, extra+map_x+64, map_y)
	spr(offs+7, extra+map_x+72, map_y)
	spr(offs+3, extra+map_x+80, map_y)
	
	spr(offs+5, extra+map_x+88, map_y)
	spr(offs+7, extra+map_x+96, map_y)
	spr(offs+1, extra+map_x+104, map_y)

	spr(offs+1, extra+map_x+112, map_y)
	
	spr(offs+1, extra+map_x+128, map_y)

	spr(offs+5, extra+map_x+136, map_y)
	spr(offs+1, extra+map_x+144, map_y)

	spr(offs+7, extra+map_x+152, map_y)
	spr(offs+1, extra+map_x+160, map_y)

	spr(offs+1, extra+map_x+168, map_y)

	spr(offs+5, extra+map_x+176, map_y)
	spr(offs+7, extra+map_x+184, map_y)
	spr(offs+3, extra+map_x+192, map_y)

	spr(offs+7, extra+map_x+200, map_y)
	spr(offs+7, extra+map_x+208, map_y)
	spr(offs+3, extra+map_x+216, map_y)

	spr(offs+5, extra+map_x+224, map_y)
	spr(offs+1, extra+map_x+232, map_y)

	map_y += 8

	spr(offs+1, extra+map_x+24, map_y)
	spr(offs+1, extra+ map_x+40, map_y)

	spr(offs+1, extra+map_x+48, map_y)

	spr(offs+1,extra+ map_x+64, map_y)
	spr(offs+1,extra+ map_x+80, map_y)
	
	spr(offs+1,extra+ map_x+88, map_y)
	spr(offs+1,extra+ map_x+104, map_y)

	spr(offs+1,extra+ map_x+112, map_y)
	
	spr(offs+1,extra+ map_x+128, map_y)

	spr(offs+1, extra+map_x+136, map_y)

	spr(offs+1,extra+ map_x+152, map_y)

	spr(offs+1,extra+ map_x+168, map_y)

	spr(offs+1,extra+ map_x+176, map_y)
	spr(offs+1,extra+ map_x+192, map_y)

	spr(offs+1,extra+ map_x+200, map_y)
	spr(offs+1,extra+ map_x+216, map_y)

	spr(offs+2,extra+ map_x+224, map_y)
	spr(offs+3,extra+ map_x+232, map_y)

	map_y += 8

	spr(offs+7, extra+map_x+24, map_y)
	spr(offs+7, extra+map_x+32, map_y)
	spr(offs+6, extra+map_x+40, map_y)

	spr(offs+1, extra+map_x+48, map_y)

	spr(offs+2, extra+map_x+64, map_y)
	spr(offs+7, extra+map_x+72, map_y)
	spr(offs+6, extra+map_x+80, map_y)
	
	spr(offs+2, extra+map_x+88, map_y)
	spr(offs+7, extra+map_x+96, map_y)
	spr(offs+1, extra+map_x+104, map_y)

	spr(offs+2, extra+map_x+112, map_y)
	spr(offs+7, extra+map_x+120, map_y)
	spr(offs+6, extra+map_x+128, map_y)

	spr(offs+2, extra+map_x+136, map_y)
	spr(offs+1, extra+map_x+144, map_y)

	spr(offs+2, extra+map_x+152, map_y)
	spr(offs+1, extra+map_x+160, map_y)

	spr(offs+1, extra+map_x+168, map_y)

	spr(offs+2,extra+ map_x+176, map_y)
	spr(offs+7, extra+map_x+184, map_y)
	spr(offs+6,extra+map_x+192, map_y)

	spr(offs+1, extra+map_x+200, map_y)
	spr(offs+1, extra+map_x+216, map_y)

	spr(offs+7, extra+map_x+224, map_y)
	spr(offs+6, extra+map_x+232, map_y)

	map_y += 8

	spr(offs+1, extra+map_x+24, map_y)

end
__gfx__
eeeeeeeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeee6dd6eee6dddd6eeee66eeeee6dd6eee6dddd6eee6dd6ee
eeeeeeeeee6116eeee6aa6eeee6336eeee6bb6eeee6336eeee6336eeee6336eeeee66eeeee6dd6eee6dddd6e6dddddd6ee6dd6eee6dddd6e6dddddd6e6dddd6e
eeeeeeeee611116ee6aaaa6ee633336ee6bbbb6ee633336ee633336ee633336eee6dd6eee6dddd6e6dddddd66dddddd6e6dddd6e6dddddd66dddddd66cccccc6
eeeeeeee611111166aaaaaa6633003366bbbbbb6633333366330033663333336e6dddd6e6dddddd66dddddd6e6dddd6e6dddddd66dddddd6e6dddd6e6cccccc6
eeeeeeee611111166aaaaaa6633003366bbbbbb66333333663300336633333366dddddd66dddddd6e6dddd6eee6dd6ee6cccccc6e6cccc6eee6cc6eee6cccc6e
eeeeeeeee611116ee6aaaa6ee6cccc6ee6bbbb6ee6cccc6ee633336ee633336e6dddddd6e6dddd6eee6dd6eeeee66eeee6cccc6eee6cc6eeeee66eeeee6cc6ee
eeeeeeeeee6116eeee6aa6eeee6cc6eeee6bb6eeee6cc6eeee6336eeee6336eee6dddd6eee6dd6eeeee66eeeeee66eeeee6cc6eeeee66eeeeee66eeeeee66eee
eeeeeeeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeee6dd6eeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eee
e6dddd6ee6cccc6eddddddd1dddddddddd111111ddddddd111111dddddddddd1ddddddddeee66eeeeeeeeeeeeeeeeeeeeee66eeeeee66eeeeee66eeeeee66eee
6dddddd66cccccc6ddddddd1dddddddddddd1111ddddddd1111dddddddddddd1ddddddddee6446eeeeeeeeeeeeeeeeeeee6886eeee6886eeee6886eeee6cc6ee
6cccccc66cccccc6ddddddd11dddddddddddd111ddddddd111dddddddddddd11dddddddde644446eeeeeeeeeeeeeeeeee688886ee688886ee6cccc6ee6cccc6e
e6cccc6ee6cccc6eddddddd11ddddddddddddd11ddddddd11ddddddddddddd11dddddddd64444446e7eeeeeeeeeeeeee68888886688888866cccccc66cccccc6
ee6cc6eeee6cc6eeddddddd111dddddddddddd11ddddddd11dddddddddddd111dddddddd64444446eeee7eeeeee7eeee688888866cccccc66cccccc66cccccc6
eee66eeeeee66eeeddddddd1111dddddddddddd111111111dddddddddddd1111dddddddde644446eeeecceedddeeeeeee688886ee6cccc6ee6cccc6ee6cccc6e
eee66eeeeee66eeeddddddd111111dddddddddd111111111dddddddddd111111ddddddddee6446eee777ccdeeeeeeeeeee6886eeee6cc6eeee6cc6eeee6cc6ee
eee66eeeeee66eee11111111111111111111111111111111111111111111111111111111eee66eeee7e77cd777eeeeeeeee66eeeeee66eeeeee66eeeeee66eee
eee665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cd7e7ee7eeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeee
e6566656eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555eeeeee0000088888eeee7ee7cd7eeeeeeeeee6ff6eeeeeeeeeeeeeeeeeeeeeeeeee
666566656eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55225225eeeee0fff08877eeeeeeee7cd7eeeeeeeee6ffff6eeeeeeeeeeeeeeeeeeeeeeeee
6666566656eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555225225225eee0077f0878877eeeee07cd70eeeeeee6ffffff6eeeeeeeeeeeeeeeeeeeeeeee
6666656dd56eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5525522522555ee00667f08e778877eeee0cd0eeeeeeee6ffffff6eeeeeeeeeeeeeeeeeeeeeeee
e6666d5dd5ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee52222552255585ee0660000eeee7788eeeee00eeeeeeeeee6ffff6eeeeeeeeeeeeeeeeeeeeeeeee
ee66ddd55dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55552252558885ee0000eeeeeeeee77eeeeeeeeeeeeeeeeee6ff6eeeeeeeeeeeeeeeeeeeeeeeeee
eee6ddd5dddeeeeeeeeee5eeeeeeeeeeeeeee6eeeeeeeeeee58855555888844eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeee
eee440eeeeeeeeeeeeee555eeeeeeeeeeeee666eeeeeeeeee58888558800444eeeeeeeeeeeeeeeeecccccccceeeeeeeeeeeeeeeeee5555eeee5555ee33333333
e4044404eeeeeeeeeeee050eeeeeeeeeeeee565eeeeeeeeee54008858000444eeeeeeeeeeeeeeeeecccccccceeeeeeeeeeeeeeeee555555ee555555e33333333
444044404eeeeeeeeee550555eeeeeeeeee665666eeeeeeee54000458000444eeee6eeeeeeeeeeeecccccccceee65eeeeee65eee555555555555555533333333
4444044404eeeeeeee55505550eeeeeeee66656665eeeeeee54000458000444eeee6eeeee6666eeecccccccceee65eeeeee65eeee666666ee444444e33333333
44444045504eeeeee055505500eeeeeee566656655eeeeeee58800458000444ee66666eee5555eeecccccccce66666eee66666eee600606ee400404e33333333
e44445095055eeee550550005555eeee665665556666eeeeeee8888580004eeee55655eeeeeeeeeecccccccce55655eee556555ee600606ee400404e33333333
ee4459500595eeee555005550555eeee666556665666eeeeeeeee885800eeeeeeee6eeeee6666eeecccccccceee65eeeeee65eeee600666ee400444e33333333
eee45550555eeeeee5505555055eeeeee6656666566eeeeeeeeeeee58eeeeeeeeee5eeeee5555eeecccccccceeeeeeeeeeee5eeee600666ee400444e33333333
eeee000000000000eeeeeeee000eeeeeeeee0000eeeeeeeeeeeeeee0000eeeeeeeee00000eeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee00777777777777eeeeeee00000eeeeeee000f00eeeeeeeeeeeeeeef000eeeeeee000ffeeeeeeeeeeee03bbbb300eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e077777777777777eeeeeee00000eeeeeee0f1f1feeeeeeeeeeeeeeff000eeeeeee0f0f1ffeeeeeeeee03333bbbb30eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e077777777777777eeeeeee00000eeeeeeeefffffeeeeeeeeeeeeeeeff0feeeeeeeefffffeeeeeeeee0bbbb33bbbbb0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0777777777777777e5555eeef0feeeeeeeeeef0feee5555ee5555eeeeffeeeeeeeeeef00eee5555eee0bbbbbbbbbbb30eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0777777777777777555eef7fffff7ffeeff7fffff7fee555555eef7fffff7ffeeff7fffff7fee555ee03bbbbbbbbb330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
07777777777777775e5eef7777777ffeeff77fff77fee5e55e5eef7777777ffeeff77fff77fee5e5ee03bbbbbbbb330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
07777777777777775ee5fff777777ffffff777777fff5ee55ee5fff777777ffffff777777fff5ee5ee033bbbbbb330eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
7777777707777770eee5ffe777777ffffff777777eff5eeeeee5ffe777777ffffff777777eff5eeeeeeee00000eeeeeeeeeee00000eeeeeeeeeee00000eeeeee
77777777e077770eeeefffe777777effffe774777efffeeeeeefffe777777effffe774777efffeeeeeee03bbb300eeeeeeee03bbb300eeeeeeee03bbb300eeee
77777777ee0770eeeee9f9e555555ef99fe556655e959eeeeee9f9e555555ef99fe556655e959eeeeee0333bbbb30eeeeee0333bbbb30eeeeee0333bbbb30eee
77777777ee0770eeeeeee5ecccccce9ff9e44666ce5eeeeeeeeee5ecccccce9ff9e44666ce5eeeeeee0bbb33bbbbb0eeee0bbb33bbbbb0eeee0bbb33bbbbb0ee
77777777e0770eeeeeeee5ecc66cc4eeee44c666ce5eeeeeeeeee5ecc66cc4eeee44c666ce5eeeeeee0bbbbbbbbbbb0eee0bbbbbbbbbbb0eee0bbbbbbbbbbb0e
77777777e070eeeeeeeeeeecceecc44ee44cceecceeeeeeeeeeeeeecceecc44ee44cceecceeeeeeeee03bbbbbbbbb30eee03bbbbbbbbb30eee03bbbbbbbbb30e
77777777070eeeeeeeeeeee22ee22e4ee4e22ee22eeeeeeeeeeeeee22ee22e4ee4e22ee22eeeeeeeee03bbbbbbbb330eee03bbbbbbbb330eee03bbbbbbbb330e
7777777700eeeeeeeeeeeee22ee22eeeeee22ee22eeeeeeeeeeeeee22ee22eeeeee222e222eeeeeeee033bbbbbb330eeee033bbbbbb330eeee033bbbbbb330ee
07777777eeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0333bb3330eeeeee0333bb3330eeeeee0333bb3330eee
07777777eeeeeeeeeeeeeff000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee22eeeeeeeeeee03333300eeeeeeee03333300eeeeeeee03333300eeee
07777777eeeeeeeeeeeff1f0f0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee225522eeeeeeeeee00440eeeeeeeeeee00440eeeeeeeeeee00440eeeeee
077777776eeeeeeeeeeefffffeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2255225522eeeeeeeee04400eeeeeeeeeee04400eeeeeeeeeee04400eeeee
07777777666eeeeeeeeee55feee5555eeeee7eeeeee7eeeeeeeeeeeeeeeeeeeee22552255225522eeeeeee044440eeeeeeeeee044440eeeeeeeeee044440eeee
0777777766666eeeeff79fff97fee555eeecceedddeeeeeeeeeeeeeeeeeeeeee2552255225522552eeeeee04400eeeeeeeeeee04400eeeeeeeeeee04400eeeee
077777776666666eeff7799977fee5e5e777ccdeeeeeeeeeeeeeeeeeeeeeeeee2222222222222222eeeeee0440eeeeeeeeeeee0440eeeeeeeeeeee0440eeeeee
0777777766666ddefff777777fff5ee5e7e77cd777eeeeeeeeeeeeeeeeeeeeeee55555555555555eeeeeee0440eeeeeeeeeeee0440eeeeeeeeeeee0440eeeeee
edddd666666ddddefff777777eff5eeeeeee7cd7e7ee7eeeeeeeeeeeeeeeeeeee28844448884482eeeeee04440eeeeeeeeeee04440eeeeeeeeeeeeeeeeeeeeee
edddddd66ddddddeffe774777efffeeee7ee7cd7eeeeeeeeeeeeeeeeeeeeeeeee28400004840042eeeeeee0440eeeeeeeeeeee0440eeeeeeeeeeeeeeeeeeeeee
e55dddddddddd55e9fe556655e9f9eeeeeee7cd7eeeeeeeeeeeeeeeeeeeeeeeee28400004840042eeeeeee0440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e5555dddddd5555ef9e44666ce5eeeeeeee07cd70eeeeeeeeeeeeeeeeeeeeeeee28400004840042eeeeeee0440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e555555dd555555eee44c666ce5eeeeeeeee0cd0eeeeeeeeeeeeeeeeeeeeeeeee28400004884482eeeeeee0440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee5555555555eeee44cceecceeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeee28400004888882eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee555555eeeeee4e22ee22eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee28400004888882eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee55eeeeeeeee222e222eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee28400004888882eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeee78eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555eeee
eeeee005500eeeeeeeeeeee99eeeeeeeeeeeee8eee8eeeeeeeeee78ee78eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55dd5dd5eee
eee0055555500eeeeeeee999999eeeeeeeee8eeeeeee8eeeeee78eeeeee78eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555dd5dd5dd5ee
e00555555555500eeee9999999999eeeee8eeeeeeeeeee8ee78eeeeeeeeee78eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55d55dd5dd555ee
e55555555555555ee99999999999999ee8eeeeeeeeeee8eee87eeeeeeeeee87eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555eeee5dddd55dd55545ee
eee5555555555eeeeee9999999999eeeeee8eeeeeee8eeeeeee87eeeeee87eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55dd5dd5eee5555dd5d554445ee
eeeee555555eeeeeeeeee999999eeeeeeeeee8eee8eeeeeeeeeee87ee87eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555dd5dd5dd5ee54455555444445ee
eeeeeee55eeeeeeeeeeeeee99eeeeeeeeeeeeee8eeeeeeeeeeeeeee87eeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555eeeee55d55dd5dd555ee54444554400445ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55dd5dd5eee5dddd55dd55545ee54004454000445ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44e44444eeeeeeeeee55555eeeeee555dd5dd5dd5ee5555dd5d554445ee54000454000445ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44e44444eeee4eeee4444eeeeeeeeeee55dd5dd5eeee55d55dd5dd555ee54455555444445ee54000454000445ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeee4444eeeeeee44eeeddddd4444eee555dd5dd5dd5ee5dddd55dd55545ee54444554400445ee54400454000445ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeddddd4444eee44dd4444444eeee55d55dd5dd555ee5555dd5d554445ee54004454000445eeee4444540004eeee
eeeeeeeeeeeeeeeeeeeee44e44444eeeee44dd4444444eeeedd5444eedd5555e5dddd55dd55545ee54455555444445ee54000454000445eeeeee445400eeeeee
eeeeeeeeeeeeeeeee4eeee4444eeeeeeedd5444eedd5555eee44455dd55d5eee5555dd5d554445ee54444554400445ee54000454000445eeeeeeee54eeeeeeee
eeeeeeeeeeeeeeeee44eeeddddd4444eee44455dd55d5eee444eed444444444e54455555444445ee54004454000445ee54400454000445eeeeeeeeeeeeeeeeee
eeeee44e44444eeeee44dd4444444eee444eed444444444eeeeeeee55eeeeeee54444554400445ee54000454000445eeee4444540004eeeeeeeeeeeeeeeeeeee
e4eeee4444eeeeeeedd5444eedd5555eeeeeeee55eeeeeeeeeeeeeeeeeeeeeee54004454000445ee54000454000445eeeeee445400eeeeeeeeeeeeeeeeeeeeee
e44eeeddddd4444eee44455dd55d5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee54000454000445ee54400454000445eeeeeeee54eeeeeeeeeeeeeeeeeeeeeeee
ee44dd4444444eee444eed444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee54000454000445eeee4444540004eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
edd5444eedd5555eeeeeeee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee54400454000445eeeeee445400eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee44455dd55d5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4444540004eeeeeeeeee54eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
444eed444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee445400eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee54eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee55555eeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee007700eeeeeeeeee007700eeeeeeeeee55225225eee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeee0077777700eeeeee0077777700eeeee555225225225ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee006600eeeeee00777777777700ee00777777777700ee5525522522555ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0066666600eee0777777777777770077777777777777052222552255585ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00666666666600e0667777777777660e66777777777766e55552252558885ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee33eeeeeeeeeeeeee33eeeeeee06666666666666600666677777766660eee6677777766eee58855555888844ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee333333eeeeeeeeee333333eeeeeedd6666666666ddeedd6666776666ddeeeeee667766eeeee58888558800444ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3333333333eeeeee3333333333eeeeeedd666666ddeeeeeedd666666ddeeeeeeeeee66eeeeeee54008858000444ee
eeeeee1111eeeeeeeeeeee0000eeeeeee33333333333333ee33333333333333eeeeeedd66ddeeeeeeeeeedd66ddeeeeeeeeeeeeeeeeeeeee54000458000444ee
eeee11111111eeeeeeee00000000eeeee44333333333344ee44333333333344eeeeeeeeddeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeeeeeeee54000458000444ee
ee111111111111eeee000000000000eee44443333334444eeee4433333344eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee58800458000444ee
11111111111111110000000000000000e44444433444444eeeeee443344eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888580004eeee
ee111111111111eeee000000000000eeeee4444444444eeeeeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee885800eeeeee
eeee11111111eeeeeeee00000000eeeeeeeee444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee58eeeeeeee
eeeeee1111eeeeeeeeeeee0000eeeeeeeeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee007700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee007700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee0077777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeee0077777700eeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee00777777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee006600eeeeee00777777777700eeeeee006600eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0777777777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0066666600eee0777777777777770eee0066666600eeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0667777777777660eeeeeee00eeeeeeeeeeeeee00eeeeeeee00666666666600e0667777777777660e00666666666600eeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0666677777766660eeeee00dd00eeeeeeeeee00dd00eeeee066666666666666006666777777666600666666666666660eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0dd6666776666dd0eee00dddddd00eeeeee00dddddd00eee0dd6666666666dd00dd6666776666dd00dd6666666666dd0eeeeeeeeeeeeeeee
eeeeeee99eeeeeee0dddd666666dddd0e00dddddddddd00ee00dddddddddd00e0dddd666666dddd00dddd666666dddd00dddd666666dddd0eeeeeee99eeeeeee
eeeee99aa99eeeee0dddddd66dddddd00dddddddddddddd00dddddddddddddd00dddddd66dddddd00dddddd66dddddd00dddddd66dddddd0eeeee994499eeeee
eee99aaaaaa99eee055dddddddddd550055dddddddddd550e55dddddddddd55ee55dddddddddd55ee55dddddddddd55e055dddddddddd550eee9944444499eee
e99aaaaaaaaaa99e05555dddddd5555005555dddddd55550eee55dddddd55eeeeee55dddddd55eeeeee55dddddd55eee05555dddddd55550e99444444444499e
eaaaaaaaaaaaaaaee555555dd555555ee555555dd555555eeeeee55dd55eeeeeeeeee55dd55eeeeeeeeee55dd55eeeeee555555dd555555ee44444444444444e
eeeaaaaaaaaaaeeeeee5555555555eeeeee5555555555eeeeeeeeee55eeeeeeeeeeeeee55eeeeeeeeeeeeee55eeeeeeeeee5555555555eeeeee4444444444eee
eeeeeaaaaaaeeeeeeeeee555555eeeeeeeeee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555eeeeeeeeee444444eeeee
eeeeeeeaaeeeeeeeeeeeeee55eeeeeeeeeeeeee55eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55eeeeeeeeeeeeee44eeeeeee
__gff__
0000010401040404010407090407090709090000000000000001010101040709010101010101000001010100010001010101010101010000010101010100000000000000000000000000000001010101000000000000000000000000000000000000000001010101010100000000000000000000010001010101000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0505050505050505050505050001010101010101010100010101010101010101000101010101010101010001010101010101010100010101010101010101000101010101010101010001010101010101010100010101010101010101000101012c0101010101000101012c010101010100010101010101010101222322232223
05050505050505050505050500010101010101010101000101010101010101010001010101010101010100010101010101010101000101010101010101010001010101010101010100010101070701010101000101010101010101010001010108010101010100010101020201010101000101012c0101010101323332333233
0101010101010101010101010001010101040401010100010101010101010101000101010101010101010001010104040401010100010104010104010101000101010404010101010001010707070701010100010104010104010101000101090808010101010001010202020201010100010b0b090b0b0101013f3f3f3f2021
01010101010101010101010100010101010b04040101000101010101010101010001010101010101010100010104040b040a0101000101042c090a0a010100010104072c0909010100010104070b0b08010100010107010707010101000101080409080101010001020202020201010100010b010101040101013f3f3f3f3031
010101010101010101010101000101090a0a0707010100010101040b0a09080100010101040b070b040100010104040404090201000101191908090a01010001040401080809010100010104070b0b08080100010107072c07010101000101080b08080a0a010001040a0a0b0b0a020100010b0b0a010b0104013f3f3f3f2223
0101010101010101010101010001010b07070707020100010101040a0a09080100010101020207070201000101040a040a090201000101011908080a010100010101010908090a0100010104090a0b0907010001010901010701010100010108090408080b04000101010102020a0202000101010a01010107013f3f3f3f3233
010101010101010101010101000101010a020202020100010101040909090801000101010402070a090100010101040409090201000101010101010a010100010101010b09090801000101010909090707010001010101010a01010100010101080a08010101000101010202020a0a04000101010a0a010107013f3f3f3f2021
0101010101090a040401010100010101010101022c0100010101010101012c0100010101012c0101010100010101010101012c010001010101010119010100010101010108080101000101010107070701010001010101010b0101010001010101010101010100010101010202020201000101010107070707013f3f3f3f3031
01010101010a090b0407010100010101010101010101000101010101010101010001010101010101010100010101010101010101000101010101010b0101000101010101010101010001010101012c010101000101010101040101010001010101010101010100010101010104020101000101010101040101013f3f3f3f2223
0101010101090a0a04070701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3233
01010101010b080807070701000101010101010101010032313031303304043f3f3b3d3a3a3a3a3a3a3a3a3a3a3b3d3f22233f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2021
0101010101010a0707070701000101010101010101010004040303040403033f3f3c3627363736273627363736263e3f32333f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3031
010101010101010202021c010001010b0101010101010004040303040403033f3f3b3626362636373626362636273d3f22233f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2223
0101010101010101010101010001010b0401010101010020232223202122233f3f3f3f3a3a3a3a3a3a3a3a3a3a3f202132333f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3233
01010101010101010101010100010108010101010b010030313233323132333f3f3f3f3a3a3a3a3a3a3a3a3a3a3f30312223222322232223223f22232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223
3f3f3f3f3f3f3f3f3f3f3f3f000101080a2c04040404003f3f3f3f3f3f3f3f3f3f3f3f3a3a3a3a3a3a3a3a3a3a3f3f3f3233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233
2223222322232223222322230001010101090101020200232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223
3233323332333233323332330001010101020202020100333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233
20213f3f3f3f3f3f24250a0b00010101010101010101003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2223
30313f3f3f3f3f3f34351a1b0000000000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3233
20212c3f3f3f3f3f3f3f2a2b3f1a1b3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2021
303124253f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3031
202134353f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2223
30313f3f24253f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3233
20213f3f34353f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2021
30313f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3031
202124253f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2223
303134353f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3233
202183843f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f2021
303193943f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3031
2223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223222322232223
3233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332333233
__sfx__
010700001c31010320043102400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f015300152d01528015300152d01529015280152d0152b0152d015290152d015280152b0152d0152f015300152d015340152f015320152d015300152b0152d015280152901526015280152401526015
011000002301524015210151c01524015210151d0151c0151f0151c015210151d015230151c0151f0152301524012240122401224015210051d00523005210052400523005260052400528005260052b00528005
0110000a0062604626056260062602626006260562602626046260062605626036260062605626036260062605626076260062601626056260562602626006260462605626026260062605626076260462604626
01020000296202b6220c6220c02200022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000029230282302923026230290002323000000000001f230000001c2201a2201722014220142200010000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000186340c633137530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002d0352d0302d0322d01200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002461624611246112461130621306113061224611246122461218611186120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003061200620030000300000000030000300003000000000300003000030000000003000030000300000000030000300003000000000300003000030000000003000030000300000000030000000000000
01100000157500000018750000001c750000001f750000001c7501c7521c7521c7521c752000000000000000000000000000000000001a750000001c750000001d750000001c750000001a750000001875000000
01100000090500c70030710000003471034700377100000021040000000c7000c7000c615000000c7000000009050000003771000000347100c70032710000001f040000000c7000c7000c615000000c70000000
0110000028510285122b5112851128512285122b51128511285122851228512285122851228512285122851224512245122451224512245122451228511285112851228512285122451124512245122451224512
011000002151121512215122151221512215122151221512215122151221512215122151221512215121551124502245022450224502245022450228501285012850228502285022450124502245022450224502
011000000c7630c763000000000015623000000c7630c7630c763000000c76300000156230000000000000000c7630c763000000000015623000000c7630c7630c763000000c7630000015623156231562315623
011000002473030730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000305000000030550305503050000000305503055030500000003055030550305000000030550305503050000000305503055030500000003055030550305000055020550305505055030550205503055
011000000005000000000550005500050000000005500055000500000000055000550005000000000550005500050000000005500055000500000000055000550005002055030550505507055050550205505055
011000001b1201b1221b1221d1201d1251d1251e1221e1221f1211f12122121221222412024122241202412218110000001311113110161111611018111181101d1111d1101b1111b11018111181100000000000
011000002602000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000290402e040290402d00029000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018122181221812213120131251312518122181221b1211b12113121131221612016122181201812218110131001311113110161111611018111181100000000000000000000000000000000000000000
0110000022120241222212222122221121f1051f1251f12522122221211f1211d1211b1251f1251b1211b12118121181211812018120181201810118111181101d1111d1101b1111b11018111181101811000000
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
01 01 42 43 44
04 02 42 43 44
01 0b 42 43 44
00 0b 42 43 44
00 0b 42 0a 44
00 0b 42 0a 44
00 0b 0c 0a 44
00 0b 0c 0a 44
00 0b 0c 43 44
00 0b 0c 43 44
00 0b 0d 43 44
02 0b 42 43 44
00 0a 06 12 44
00 0b 0d 16 44
00 0b 0d 09 44
02 0b 06 16 44
00 0a 06 11 44
00 0b 0d 15 44
01 0a 06 12 44
02 0b 07 16 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
