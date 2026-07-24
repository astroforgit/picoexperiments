pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--brave pixel v1.1
--extar 2020

--can save more tokens by making a function to replace ceil(rnd(x))

function _init()
	menuitem(1,'back to menu',function() level_select_init() end)
	splash_init()
end
-->8
--functions

function centre_text(message,y,c)
	print(message,64-#message*2,y,c)
end

function randint(num)
	return flr(rnd(num))
end

--src=https://pastebin.com/skuBnY4g
function cheat_input()

	if (cheat_buffer==nil) cheat_buffer={}

	if (btnp(”)) add(cheat_buffer,'”')
	if (btnp(ƒ)) add(cheat_buffer,'ƒ')
	if (btnp(‹)) add(cheat_buffer,'‹')
	if (btnp(‘)) add(cheat_buffer,'‘')
	if (btnp(—)) add(cheat_buffer,'—')
	if (btnp(Ž)) add(cheat_buffer,'Ž')
		 
	while #cheat_buffer>10 do
		del(cheat_buffer,cheat_buffer[1])
	end

	cheatstr=''
	for i=1,#cheat_buffer do
		cheatstr=cheatstr..cheat_buffer[i]
	end
	
	if cheatstr=='””ƒƒ‹‘‹‘—Ž' and cheats==false then
		cheatstr=''
		cheat_buffer={}
		sfx(14)
		--test cheats
		for i=1,#level_complete do
			level_complete[i]=1
		end
		player_upgrades=3
		cheats=true
	end		
end

--function work_out_time(frames)
	--rawseconds=frames/30
	--time_complete_minutes=flr(rawseconds/60)
	--time_complete_seconds=tostr(flr(rawseconds%60))
	--if #time_complete_seconds==1 then
		--time_complete_seconds='0'..time_complete_seconds
	--end
	--time_complete_fractions=flr(((frames%30)*0.0333)*1000)
	--return tostr(time_complete_minutes..':'..time_complete_seconds..'.'..time_complete_fractions)
--end

function work_out_time(rawtime)
	--rawseconds=frames/30
	time_complete_minutes=flr(rawtime/60)
	time_complete_seconds=tostr(flr(rawtime%60))
	if #time_complete_seconds==1 then
		time_complete_seconds='0'..time_complete_seconds
	end
	time_complete_fractions=flr((rawtime%1)*1000)
	return tostr(time_complete_minutes..':'..time_complete_seconds..'.'..time_complete_fractions)
end

function check_level_completion()
	if score>=level[current_level] and run_clock==true then
		run_clock=false
		finish_time=time()-start_time
		complete_times[current_level]=finish_time
		--is this vestigal?
		--complete_time='time: '..work_out_time(finish_time)
		if finish_time<complete_times[current_level] then
			complete_times[current_level]=finish_time()
		end
		
		if level_complete_music==false then
			music(8)
			level_complete_music=true
		end
		
		level_completed_time_message=work_out_time(complete_times[current_level])
		mark_accessible_levels()
		sfx(2)
	end
end

function level_music(lev)
	music_list={
	1,--1
	1,--2
	2,--3
	2,--4
	2,--5
	3,--6
	1,--7
	2,--8
	2,--9
	3,--10
	1,--11
	3,--12
	1,--13
	3,--14
	1,--15
	3,--16
	}
	if music_list[lev]==1 then
		--water music
		bgm1=32
		bgm2=20
	elseif music_list[lev]==2 then
		--forest
		bgm1=49
		bgm2=33
	elseif music_list[lev]==3 then
		--city
		bgm1=62
		bgm2=50
	end
end

function mark_accessible_levels()
	level_complete[current_level]=2
	if level_complete[current_level+1]==0 and current_level%4!=0 then
		level_complete[current_level+1]=1
	end
	if level_complete[current_level-1]==0 and current_level%4!=1 then
		level_complete[current_level-1]=1
	end
	if level_complete[current_level+4]==0 then --and current_level%4!=1 then
		level_complete[current_level+4]=1
	end
	if level_complete[current_level-4]==0 and current_level%4!=0 then
		level_complete[current_level-4]=1
	end
end

--level complete code
--function calculate_complete_time()
	--if score>=level[current_level] then --and run_clock==true then
		--run_clock=false
		--mark_accessible_levels()
		--sfx(2)
		--complete_times[current_level]=clock
		--complete_time='time: '..work_out_time(clock)
		--if clock<complete_times[current_level] then
			--complete_times[current_level]=clock
		--end
	--end
--end

function check_score()
	for i=1,#player_coords do
		player_coords[i].c=8
		cx=player_coords[i].x
		cy=player_coords[i].y
		x=player_x+cx
		y=player_y+cy
		if pget(x,y)==12 and #player_coords>1 then
			del(player_coords,player_coords[i])
			score+=1
			frames_since_last_pixel=0
			square_size=sqrt(score)
			sfx(0)
			--win level complete
			--calculate_complete_time()
			break
		end
	end
end

function kill_player()
	if death_cooldown==0 and score<level[current_level] then
		player_x=64
		player_y=64
		player_death_nova(64,64,6)
		--create_explosion(64,64,5,8)
		sfx(13)
		death_cooldown=120
		reset_worm_targets=true
	end
end

--used for explosion/radius-based collision
--pythagoras' theorem ftw
function pythagoras(ax,bx,ay,by,r)
	return sqrt((ax-bx)^2+(ay-by)^2)<r
end

--banana chase tips code
function update_tips()
	tip_x-=1
	if tip_x<0-(#tips[tip_to_show])*4 then
		last_tip=tip_to_show
		while tip_to_show==last_tip do
			tip_to_show=ceil(rnd(#tips))
		end
		tip_x=127
	end
end

-->8
--enemy and terrain code

function create_enemy(name,x,y)
	local new_random_x=randint(128)
	local new_random_y=randint(128)
	
	if name=='small_worm' then
		local worm={
			colour=8,
			size=1,
			target_x=new_random_x,
			target_y=new_random_y,
			type=1,
			x=x,
			y=y,
			}
		add(worms,worm)
	elseif name=='big_worm' then
		local worm={
			colour=8,
			size=2,
			target_x=new_random_x,
			target_y=new_random_y,
			type=2,
			x=x,
			y=y,
			}
		add(worms,worm)
	elseif name=='e_traffic' then
		local traffic={
			dx=rnd(1)+0.5,
			dy=0,
			next_car=0,
			h=2,
			w=8,
			x=-32,
			y=y,
			}
		add(traffics,traffic)
	elseif name=='w_traffic' then
		local traffic={
			dx=0-(rnd(1)+0.5),
			dy=0,
			next_car=0,
			h=2,
			w=8,
			x=160,
			y=y,
			}
		add(traffics,traffic)
	elseif name=='n_traffic' then
		local traffic={
			dx=0,
			dy=0-(rnd(1)+0.5),
			next_car=0,
			h=8,
			w=2,
			x=x,
			y=160,
			}
		add(traffics,traffic)
	elseif name=='s_traffic' then
		local traffic={
			dx=0,
			dy=rnd(1)+0.5,
			next_car=0,
			h=8,
			w=2,
			x=x,
			y=-32,
			}
		add(traffics,traffic)
	end
end

function enemies_update()
	for traffic in all (traffics) do
		if traffic.next_car<0 then
			traffic.next_car=15+rnd(60)
			local car={
				colour=8,
				dx=traffic.dx,
				dy=traffic.dy,
				h=traffic.h,
				w=traffic.w,
				x=traffic.x,
				y=traffic.y,
				}
			add(cars,car)
		else
			traffic.next_car-=1
		end
	end
	for car in all (cars) do
		car.x+=car.dx
		car.y+=car.dy
		if car.x!=mid(car.x,-33,161) then
			del(cars,car)
		end
		if car.y!=mid(car.y,-33,161) then
			del(cars,car)
		end
	end
	for worm in all (worms) do
		if anim_clock%2==0 then
			local worm_tail={
				age=30*worm.size,
				colour=worm.colour,
				colour1=worm.colour,
				size=worm.size-1,
				x=worm.x,
				y=worm.y,
				}
			add(worm_tails,worm_tail)
			if worm.target_x!=worm.x then
				if worm.target_x<worm.x then
					worm.x-=1
				else
					worm.x+=1
				end
			end
			if worm.target_y!=worm.y then
				if worm.target_y<worm.y then
					worm.y-=1
				else
					worm.y+=1
				end
			end
			--worm finds new target
			if worm.target_x==worm.x and worm.target_y==worm.y then
				if score>=level[current_level] then
					worm.target_x=randint(128)
					worm.target_y=144
				else
					if worm.type==1 then
						sfx(7)
						worm.target_x=randint(128)
						worm.target_y=randint(128)
					elseif worm.type==2 then
						sfx(6)
						worm_target_pixel=ceil(rnd(#player_coords))
						worm.target_x=player_coords[worm_target_pixel].x+player_x
						worm.target_y=player_coords[worm_target_pixel].y+player_y					
					end
				end
			end
		end
		--eat player (not required, red collision does same job)
		--if player_x==mid(worm.x-worm.size,worm.x+worm.size,player_x) and player_y==mid(worm.y-worm.size,worm.y+worm.size,player_y) and #player_coords==1 then
			--kill_player()
		--end
		if reset_worm_targets==true then
			worm.target_x=randint(256)-128
			worm.target_y=randint(256)-128
		end
	end
	for worm_tail in all (worm_tails) do
		worm_tail.age-=1
		if worm_tail.age<1 then
			del(worm_tails,worm_tail)
		end
	end
	reset_worm_targets=false
end

function enemies_draw()
	for car in all (cars) do
		rectfill(car.x,car.y,car.x+car.w,car.y+car.h,car.colour)
	end
	for worm in all (worms) do
		rectfill(worm.x-worm.size-1,worm.y-worm.size-1,worm.x+worm.size+1,worm.y+worm.size+1,worm.colour)
	end
	for worm_tail in all (worm_tails) do
		if worm_tail.age%3==0 then
			worm_tail.colour=0
		else
			worm_tail.colour=worm_tail.colour1
		end
		rectfill(worm_tail.x-worm_tail.size,worm_tail.y-worm_tail.size,worm_tail.x+worm_tail.size+1,worm_tail.y+worm_tail.size+1,worm_tail.colour)
	end
end

function obstacle_rectangle(x,y,w,h,d)
	local rectangle={
		x=x,
		y=y,
		w=w,
		h=h,
		c=wall_colour,
		d=d,
	}
	if rectangle.d==true then
		rectangle.c=0x82
	end
	add(obstacles,rectangle)
end

function draw_obstacles()
	for rectangle in all(obstacles) do
		if rectangle.d==true then
			fillp(damage_obstacle_pattern)			
			rectfill(rectangle.x,rectangle.y,rectangle.x+rectangle.w,rectangle.y+rectangle.h,rectangle.c)--0x82)
			fillp()
		else
			rectfill(rectangle.x,rectangle.y,rectangle.x+rectangle.w,rectangle.y+rectangle.h,rectangle.c)
		end
	end
end
-->8
--pixels and collision
function check_pixel_collision()

	--if #player_coords==1 then
		--player_x=player_x+player_coords[1].x
		--player_y=player_y+player_coords[1].y
		--player_coords[1].x=0
		--player_coords[1].y=0
	--end
	--if #player_coords!=old_player_coords and #player_coords==1 then
		--player_death_nova(player_x,player_y,3)
	--end
	--old_player_coords=#player_coords

	for i=1,#player_coords do
		x=player_x+player_coords[i].x
		y=player_y+player_coords[i].y
		--check if touching square or edge of screen
		if pixels_in_square==true then
			if x<48 or x>80 then
				player_x=player_old_x
			end
			if y<48 or y>80 then
				player_y=player_old_y
			end
		end
		if x<0 or x>127 then
			player_x=player_old_x
		end
		if y<6 or y>127 then
			player_y=player_old_y
		end
		--
		if overloaded==false and pget(x,y)==pixel_colour then
			for i=1,#pixels do
				if x==pixels[i].x and y==pixels[i].y then
					frames_since_last_pixel=0
					if player_auto_clear==true then
						player_x=player_old_x
						player_y=player_old_y
						score+=1
						square_size=sqrt(score)
						create_returner(pixels[i].x,pixels[i].y)
						del(pixels,pixels[i])
						sfx(12)
					else
						player_x=player_old_x
						player_y=player_old_y
						local player_pixel={
							c=player_colour,
							x=pixels[i].x-player_x,
							y=pixels[i].y-player_y,
							}
						add(player_coords,player_pixel)
						del(pixels,pixels[i])
						sfx(1)
					end
					break
				end
			end
		end
	end
end

function check_radius_collision()
	for grab_ring in all(grab_rings) do
		for i=1,#pixels do
			if pixels[i].delete!=true and grab_ring.colour==pixel_colour_2 and pythagoras(pixels[i].x,grab_ring.x,pixels[i].y,grab_ring.y,grab_ring.r) then
				score+=1
				frames_since_last_pixel=0
				square_size=sqrt(score)
				create_returner(pixels[i].x,pixels[i].y)
				pixels[i].delete=true
				sfx(12)
			end
		end
	end
	for pixel in all (pixels) do
		if pixel.delete==true then
			del(pixels,pixel)
		end
	end
end

function reseed_pixels()
	if frames_since_last_pixel==0 then
		frame_rot=30
	end
	frames_since_last_pixel+=1
	if frames_since_last_pixel>300 and #player_coords>1 then
		frames_since_last_pixel-=frame_rot
		sfx(8)
		create_explosion(latest_player_pixel_x,latest_player_pixel_y,1,pixel_colour_2)
		del(player_coords,player_coords[#player_coords])
		make_replacement_pixel()
		if frame_rot>1 then
			frame_rot-=1
		end
	end
end

function make_replacement_pixel()
	local pixel={
		frame=randint(6),
		frame_max=6,
		id=#pixels+1,
		x=randint(128),
		y=randint(122)+6,
		}
	if pixel.x==mid(48,pixel.x,80) and pixel.y==mid(48,pixel.y,80) then
		if pixel.x>=64 then
			pixel.x+=randint(32)
		else
			pixel.x-=randint(32)
		end
		if pixel.y>=64 then
			pixel.y+=randint(32)
		else
			pixel.y-=randint(32)
		end
	end
	add(pixels,pixel)
	if no_overlapping_pixels==true then
		create_radius_tick(pixel.x,pixel.y)
		sfx(11)
	end
end

function obstacle_collision()
	for i=1,#player_coords do
		if pget(player_coords[i].x+player_x,player_coords[i].y+player_y)==wall_colour then
			sfx(9)
			for rectangle in all (obstacles) do
				if collide(player_coords[i].x+player_x,player_coords[i].y+player_y,rectangle.x,rectangle.y,rectangle.h,rectangle.w) then
					return true
				end
			end
		end
	end
end

function damage_obstacle_collision()
	for rectangle in all(obstacles) do
		if rectangle.d==true then
			rectangle.c=0x82
		end
	end
	for i=1,#player_coords do
		x=player_x+player_coords[i].x
		y=player_y+player_coords[i].y
		--red things destroy player coords
		if pget(x,y)==8 and #player_coords>1 then
			for rectangle in all(obstacles) do
				if rectangle.d==true then
					rectangle.c=0
				end
			end
			create_explosion(x,y,2,13)
			del(player_coords,player_coords[i])
			frames_since_last_pixel=0
			make_replacement_pixel()
			sfx(10)
			break
		elseif pget(x,y)==8 and #player_coords==1 then
			kill_player()
		end
	end
end

--pixels are destroyed by red things and the square
function move_pixels_from_obstacles()
	for i=1,#pixels do
		--the square
		if pget(pixels[i].x,pixels[i].y)==wall_colour then
			--create_explosion(pixels[i].x,pixels[i].y,2,pixel_colour_2)
			del(pixels,pixels[i])
			make_replacement_pixel()
		--red things
		elseif pget(pixels[i].x,pixels[i].y)==8 then
			create_explosion(pixels[i].x,pixels[i].y,2,pixel_colour_2)
			del(pixels,pixels[i])
			make_replacement_pixel()
		--blue things (the square?)	--this looks unnecessary
		--elseif pget(pixels[i].x,pixels[i].y)==12 then
			--del(pixels,pixels[i])
			--make_replacement_pixel()
		end
	end
end

function move_pixels_from_square()
	for i=1,#pixels do
		if pget(pixels[i].x,pixels[i].y)==12 then
			del(pixels,pixels[i])
			make_replacement_pixel()
		end
	end
end

function obstacle_collision_damage()
	for i=1,#player_coords do
		if pget(player_coords[i].x+player_x,player_coords[i].y+player_y)==boundary_colour then
			for rectangle in all (obstacles) do
				if collide(player_coords[i].x+player_x,player_coords[i].y+player_y,rectangle.x,rectangle.y,rectangle.h,rectangle.w) then
					obstacle_collide=true
				end
			end
		end
		if obstacle_collide==true then
			del(player_coords,player_coords[i])
		end
	end
end

--adapted from domex2 collision
function collide(px,py,ox,oy,oh,ow)
	if px+1>ox and px-1<(ox+ow) and py+1>oy and py-1<(oy+oh) then
		return true
	end
end
-->8
--graphics

function move_upgrade_floater(x,y)
	show_floater=true
	floater_x=x
	floater_y=y
	floater_target_x=-8+(player_upgrades*8)
	floater_target_y=94
end

function draw_upgrade_floater()
	if show_floater==true then
		print('†',floater_x,floater_y,8)
	end
	if floater_x>floater_target_x then
		floater_x-=2
	end
	if floater_y<floater_target_y then
		floater_y+=2
	end
	if show_floater==true and floater_x==floater_target_x and floater_y==floater_target_y then
		show_floater=false
		power_selected=player_upgrades
	end
end

function clouds_init()
	clouds={}
	for i=1,16 do
		local cloud={
			w=ceil(rnd(32)),
			h=ceil(rnd(8)),
			c=cloud_colour,
			}
		if cloud.w<cloud.h then
			cloud.w+=cloud.h
		end
		cloud.x=ceil(rnd(127))
		cloud.y=ceil(rnd(64))
		cloud.s_max=max(cloud.y,8)
		cloud.s=cloud.s_max
		add (clouds,cloud)
	end
end

function clouds_update()
	if #clouds<16 then
		local cloud={
			w=ceil(rnd(32)),
			h=ceil(rnd(8)),
			c=cloud_colour,
			}
		if cloud.w<cloud.h then
			cloud.w+=cloud.h
		end
		cloud.x=0-cloud.w
		cloud.y=ceil(rnd(64))
		cloud.s_max=max(cloud.y,8)
		cloud.s=cloud.s_max
		add (clouds,cloud)
	end
	for cloud in all(clouds) do
		cloud.s-=2
		if cloud.s<1 then
			cloud.x+=1
			cloud.s=cloud.s_max
		end
		if cloud.x>128 then
			del(clouds,cloud)
		end
	end
end

function clouds_draw()
	palt(0,true)
	fillp(0b01011010010110100101.1)
	for cloud in all(clouds) do
		rectfill(cloud.x,cloud.y,cloud.x+cloud.w,cloud.y+cloud.h,cloud.c)
	end
	fillp()
end

function bubbles_init()
	bubbles={}
	for i=1,64 do
		local bubble={
			x=randint(128),
			y=96+rnd(32),
			c=water_colour,
			f=randint(6),
			s=0.1+rnd(0.4),
			}
		add(bubbles,bubble)
	end
	waves={}
	for i=1,128 do
		local wave={
			x=i,
			y=96,
			c=water_colour,
			}
		add(waves,wave)
	end
end

function bubbles_update()
	if #bubbles<32 then
		local bubble={
			x=randint(128),
			y=128,
			c=water_colour,
			f=randint(6),
			s=0.1+rnd(0.4),
			}
			add(bubbles,bubble)
	end
	for bubble in all(bubbles) do
		bubble.y-=bubble.s
		bubble.f+=1
		if bubble.f>4 then
			bubble.f=0
		end
		if bubble.y%1==0 then
			bubble.x+=1-rnd(2)
		end
		if bubble.y<96 then
			del(bubbles,bubble)
		end
	end
	for wave in all(waves) do
		if anim_clock%4==0 then
			local num=rnd(3)
			if num>2 then
				wave.y=95
			elseif num>1 then
				wave.y=96
				if wave.x==mid(15,33,wave.x) then
					wave.c=moon_colour
				end
			else
				wave.c=water_colour
				wave.y=130
			end
		end
	end
end

function bubbles_draw()
	for wave in all(waves) do
		pset(wave.x,wave.y,wave.c)
	end
	for bubble in all(bubbles) do
		if bubble.f<2 then
		--if bubble.f%2==0 then
			pset(bubble.x,bubble.y,bubble.c)
		end
	end
end

function create_radius_tick(x,y)
	if #radius_ticks<3 then
		local radius_tick={
			colour=pixel_colour_1,
			r=1,
			t=5,
			x=x,
			y=y,
			}
		add(radius_ticks,radius_tick)
	end
end

function create_grab_ring(x,y)
	local grab_ring={
		colour=pixel_colour_2,
		r=1,
		t=12,
		x=x,
		y=y,
		}
	add(grab_rings,grab_ring)
end

function player_death_nova(x,y,n)
	for i=1,n do
		local radius_tick={
			colour=2,
			r=i*2,
			t=i*5,
			x=x,
			y=y,
			}
		add(radius_ticks,radius_tick)
	end
end

function update_radius_ticks()
	--if overloaded==false and clock%2==1 then
	for radius_tick in all (radius_ticks) do
		if anim_clock%2==1 then
			radius_tick.r+=1
			radius_tick.t-=1
			if radius_tick.t<1 then
				del(radius_ticks,radius_tick)
			end
		end
	end
	for grab_ring in all (grab_rings) do
		grab_ring.r+=1
		grab_ring.t-=1
		if grab_ring.t<1 then
			del(grab_rings,grab_ring)
		end
	end
end

function draw_radius_ticks()
	if anim_clock%2==1 then
		for radius_tick in all (radius_ticks) do
			circ(radius_tick.x,radius_tick.y,radius_tick.r,radius_tick.colour)
		end
		for grab_ring in all (grab_rings) do
			circ(grab_ring.x,grab_ring.y,grab_ring.r,grab_ring.colour)
		end
	end
end

function create_explosion(x,y,size,colour)
	if #explosions<#pixels+100 then
	for i=1,size*10 do
		local spark={
			dx=rnd(size)-(size/2),
			dy=rnd(size)-(size/2),
			x=x,
			y=y,
			age=rnd(size*10),
			colour=colour,
			}
		add(explosions,spark)
	end
	end
end

function update_explosions()
	for spark in all (explosions) do
		spark.x+=spark.dx
		spark.y+=spark.dy
		spark.age-=1
		if spark.age<1 then
			del(explosions,spark)
		end
	end
end

function draw_explosions()
	for spark in all(explosions) do
		if flr(spark.age)%2==0 then
			pset(spark.x,spark.y,spark.colour)
		end
	end
end

function create_returner(x,y)
	local returner={
		colour=pixel_colour_2,
		x=x,
		y=y,
		}
	add(returners,returner)
end

function update_returners()
	for returner in all (returners) do
		if returner.x<64 then
			returner.x+=1
		elseif returner.x>64 then
			returner.x-=1
		end
		if returner.y<64 then
			returner.y+=1
		elseif returner.y>64 then
			returner.y-=1
		end
	end
end

function draw_returners()
	for returner in all (returners) do
		if pget(returner.x,returner.y)==12 then
			del(returners,returner)
		end
		pset(returner.x,returner.y,returner.colour)
	end
end

function rain_init()
	rain={}
	for i=1,64 do
		local drop={
			x=randint(128),
			y=rnd(96),
			c=water_colour,
			f=randint(6),
			s=1.5+rnd(1.5),
			w=0.1
			}
		add(rain,drop)
	end
end

function rain_update()
	if #rain<64 then
		local drop={
			x=randint(128),
			y=0,
			c=water_colour,
			f=randint(6),
			s=1.5+rnd(1.5),
			w=0.1
			}
			add(rain,drop)
	end
	for drop in all(rain) do
		drop.y+=drop.s
		drop.f+=1
		if drop.f>4 then
			drop.f=0
		end
		drop.x+=drop.w
		if drop.y>96 then
			del(rain,drop)
		end
	end
end

function city_rain_update()
	if #rain<64 then
		local drop={
			x=randint(128),
			y=0,
			c=water_colour,
			f=randint(6),
			s=1.5+rnd(1.5),
			w=0.1
			}
			add(rain,drop)
	end
	for drop in all(rain) do
		drop.y+=drop.s
		drop.f+=1
		if drop.f>4 then
			drop.f=0
		end
		drop.x+=drop.w
		if drop.y>128 then
			del(rain,drop)
		end
	end
end

function rain_draw()
	for drop in all(rain) do
		--if drop.f<2 then
			pset(drop.x,drop.y,drop.c)
		--end
	end
end

function kelp_init()
	kelps={}
	wave_frame=randint(6)
	for i=1,32 do
		local kelp={
			c=3,
			f=randint(6),
			h=ceil(rnd(16)),
			x=randint(128),
			y=128,
		}
		add (kelps,kelp)
	end
end

function kelp_update()
	if anim_clock%6==0 then
		if wave_frame<1 then
			wave_frame=5
		else
			wave_frame-=1
		end
	end
end

function kelp_draw()
	for kelp in all(kelps) do
		for i=1,kelp.h do
			if (kelp.h-i)%6==wave_frame then
				pset(kelp.x+1,kelp.y-i,kelp.c)
			else
				pset(kelp.x,kelp.y-i,kelp.c)
			end
		end
	end
end

function hills_init()
	hills={}
	for i=1,16 do
		local hill={
			colour=4,
			h=5+rnd(25),
			w=5+rnd(45),
			x=(i*8)-8,
			y=128,
			}
		if hill.h>hill.w then
			hill.h*=1.5
			hill.w/=0.75
		end
		add(hills,hill)
	end
end

function draw_hills()
	for hill in all (hills) do
		rectfill(hill.x,hill.y-hill.h,hill.x+hill.w,hill.y,hill.colour)
	end
end

function trees_init()
	trees={}
	for t=1,8+ceil(rnd(8)) do
		local tree={
			x=rnd(128),
			y2=128,}
			tree.foliage_x=tree.x
			tree.y1=tree.y2-rnd(48)
			tree.foliage_width=min(8+rnd(16),(tree.y2-tree.y1)/2)
			tree.trunk=tree.foliage_width/5
		add(trees,tree)
	end
end

function trees_update()
	if anim_clock%30==0 then
		for tree in all (trees) do
			if rnd(1)>0.5 then
				tree.foliage_x+=randint(5)-2
			else
				tree.foliage_x=tree.x
			end
		end
	end
end

function draw_trees()
	for tree in all(trees) do
		--trunks
		rectfill(tree.x,tree.y1,tree.x+tree.trunk,tree.y2,building_colour)
		--foliage
		fillp(0b0101101001011010.1)
		rectfill(tree.foliage_x-tree.foliage_width,tree.y1-tree.foliage_width,tree.foliage_x+(tree.foliage_width)*0.66,tree.y1+tree.foliage_width,3)
		fillp()
	end
end

function buildings_init()
	buildings={}
	for i=1,8 do
		local building={
			colour=5,
			h=10+rnd(50),
			w=10+rnd(10),
			x=rnd(128),
			y=128,
			}
		add(buildings,building)
	end
end

function draw_buildings()
	for building in all (buildings) do
		color()
		fillp(0b0000011000000110)
		rectfill(building.x,building.y-building.h,building.x+building.w,building.y,0x95)--building.colour)
		fillp()
		rect(building.x,building.y-building.h,building.x+building.w,building.y,building.colour)
	end
end

function level_colours_init(lev)
	
	--if lev==1 then scheme=1
	--elseif lev==2 then scheme=3
	--elseif lev==3 then scheme=2
	--elseif lev==4 then scheme=2
	--elseif lev==5 then scheme=5
	--elseif lev==6 then scheme=6
	--elseif lev==7 then scheme=1
	--elseif lev==8 then scheme=2
	--elseif lev==9 then scheme=5
	--elseif lev==10 then scheme=4
	--elseif lev==11 then scheme=3
	--elseif lev==12 then scheme=6
	--elseif lev==13 then scheme=1
	--elseif lev==14 then scheme=6
	--elseif lev==15 then scheme=3
	--elseif lev==16 then scheme=4
	--end
	
	--1=night, 2=toxic, 3=purple, 4=blue, 5=forest, 6=city
	scheme_list={
	1,--1
	3,--2
	2,--3
	2,--4
	5,--5
	6,--6
	1,--7
	2,--8
	5,--9
	4,--10
	3,--11
	6,--12
	1,--13
	6,--14
	3,--15
	4,--16
	}
	scheme=scheme_list[lev]
	if scheme==1 then
		--default night/pink pixels
		--sky_colour=0
		--boundary_colour=2
		cloud_colour=5
		moon_colour=6
		pixel_colour_1=14
		pixel_colour_2=2
		wall_colour=13
		water_background_colour=0
		water_colour=1
	
	elseif scheme==2 then
		--toxic water/pink pixels
		--sky_colour=0
		--boundary_colour=2
		cloud_colour=5
		moon_colour=6
		pixel_colour_1=14
		pixel_colour_2=2
		wall_colour=1
		water_background_colour=11
		water_colour=4
	
	elseif scheme==3 then
		--purple/pink, yellow pixels
		--sky_colour=0
		--boundary_colour=9
		cloud_colour=4
		moon_colour=15
		pixel_colour_1=10
		pixel_colour_2=9
		wall_colour=5
		water_background_colour=4
		water_colour=14
	
	elseif scheme==4 then
		--blue water, orange moon
		--sky_colour=0
		--boundary_colour=2
		cloud_colour=5
		moon_colour=9
		pixel_colour_1=14
		pixel_colour_2=2
		wall_colour=15
		water_background_colour=4
		water_colour=1
	
	elseif scheme==5 then
		--forest
		--sky_colour=0
		--boundary_colour=3
		cloud_colour=6
		moon_colour=7
		pixel_colour_1=11
		pixel_colour_2=3
		wall_colour=5
		water_colour=5
	
		--hill_colour=4
		building_colour=9
	
	elseif scheme==6 then
		--city
		--sky_colour=0
		--boundary_colour=3--11
		cloud_colour=5
		moon_colour=10
		pixel_colour_1=11--14
		pixel_colour_2=3--11
		wall_colour=6
		water_colour=1
		
		--hill_colour=4
		building_colour=5
	end
	sky_colour=0
	hill_colour=4
	boundary_colour=pixel_colour_2
end
function level_colours_draw()
	pal()
	if scheme==1 then
		pal(1,129,1)
		pal(5,133,1)
		pal(6,135,1)
	elseif scheme==2 then
		pal(3,138,1)
		pal(4,3,1)
		pal(5,128,1)
		pal(6,135,1)
		pal(11,139,1)
	elseif scheme==3 then
		pal(3,131,1)
		pal(4,130,1)
		pal(9,137,1)
		pal(14,141,1)
		pal(15,13,1)
	elseif scheme==4 then
		pal(4,129,1)
		pal(5,128,1)
		pal(9,135,1)
		pal(15,140,1)
	elseif scheme==5 then
		pal(3,131,1)
		pal(4,128,1)
		pal(6,133,1)
		pal(7,134,1)
		pal(9,130,1)
	elseif scheme==6 then
		pal(4,128,1)
		pal(5,133,1)
		pal(6,5,1)
		pal(9,137,1)
		pal(10,135,1)
		--pal(11,130,1)
	end
end
-->8
--time

-->8
--screens

function splash_init()
	music(0)
	splash_screen_time=0

	cx={63,51,75,63,63,51,75,63}
	cy={43,48,48,52,56,63,63,68}
	lines={}
	
	_update=splash_update
	_draw=splash_draw

end

function splash_update()
	splash_screen_time+=1
	if btnp()>0 or splash_screen_time>128 then
		title_init()
	end
end

function splash_draw()
	cls()
	rect(42,40,81,81,4)
	rectfill(43,39,82,79,5)
	rect(43,39,82,80,9)
	
	n1=ceil(rnd(8))
	n2=n1
	while n2==n1 do
		n2=ceil(rnd(8))
	end
	--if #lines>24 then
		--del(lines,lines[1])
	--end
	for i=1,2 do
		local l={
			x1=cx[n1],
			y1=cy[n1],
			x2=cx[n2],
			y2=cy[n2],
			}
		add(lines,l)
	end
	for l in all (lines) do
		if l.y1==52 or l.y1==56 or l.y2==52 or l.y2==56 then
			line(l.x1,l.y1+1,l.x2,l.y2+1,4)
			if l.y1<46 and l.y2<46 then
				line(l.x1,l.y1,l.x2,l.y2,9)
			end
		end
		if l.y1==l.y2 or (l.y1+l.y2==111 and l.x1!=l.x2) then
			del(lines,l)
		end
	end
	
	for l in all (lines) do
		if not(l.y1==60 or l.y1==64 or l.y2==60 or l.y2==64) then
			line(l.x1,l.y1+1,l.x2,l.y2+1,4)
			line(l.x1,l.y1,l.x2,l.y2,9)
		end
	end
	
	--spr(3,55,56,2,2)
	print('e x t a r',45,74,4)
	print('e x t a r',46,73,9)
	
end

function title_init()
	cheats=false
	red_pixel_x=0
	red_pixel_y=64
	title_pixels={}
	title_pixels_2={}
	
	--player stuff that only resets for a new game
	player_upgrades=1
	power_selected=1
	upgrade_51=8
	upgrade_15=8
	--level select stuff that only resets for a new game
	last_row=1
	last_column=1
	last_column_level=0
	
	--for testing, each level has only 1 pixel
	--level={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	--     1   2   3   4   5   6   7   8   9   10  11  12  13  14  15   16
	level={128,256,384,512,640,128,192,256,320,384,128,512,768,768,1024,1024}
	complete_times={}
	level_complete={}
	for i=1,#level do
		add(complete_times,32767)
		add(level_complete,0)
	end
	level_complete[1]=1
	
	_update=title_update
	_draw=title_draw
end

function title_update()

	if red_pixel_x>128 then
		red_pixel_x=0
	else
		red_pixel_x+=1
	end

	local pixel={
		age=0,
		c=ceil(rnd(16)),
		x=rnd(128),
		y=0,
		}
	add(title_pixels,pixel)
	local pixel_2={
		age=0,
		c=ceil(rnd(16)),
		x=rnd(128),
		y=128,
		}
	add(title_pixels_2,pixel_2)
	for pixel in all(title_pixels) do
		if pixel.age<128 then
			pixel.y+=pixel.c/32
		end
		pixel.age+=1
		if pixel.age>512 then
			del(title_pixels,pixel)
		end
	end
	for pixel_2 in all(title_pixels_2) do
		if pixel_2.age<128 then
			pixel_2.y-=pixel_2.c/32
		end
		pixel_2.age+=1
		if pixel_2.age>512 then
			del(title_pixels_2,pixel_2)
		end
	end
	if btn(Ž) and btn(—) then
		for pixel in all(title_pixels) do
			del(title_pixels,pixel)
		end
		for pixel_2 in all(title_pixels_2) do
			del(title_pixels_2,pixel_2)
		end
		level_select_init()
	end
	
	cheat_input()

end

function title_draw()
	cls()
	for pixel in all(title_pixels) do
		pset(pixel.x,pixel.y,pixel.c)
	end
	for pixel_2 in all(title_pixels_2) do
		pset(pixel_2.x,pixel_2.y,pixel_2.c)
	end
	pset(red_pixel_x,red_pixel_y,8)
	rectfill(30,34,96,56,0)
	rectfill(10,41,124,49,0)
	line(30,38,96,38,8)
	rectfill(41,36,85,40,0)
	--rectfill(36,56,90,72,0)
	--centre_text('brave pixel',62,8)
	centre_text('brave pixel',36,8)
	centre_text('press —/x and Ž/z to start',43,7)
	if (btn(Ž)) print('Ž/z',72,43,8)
	if (btn(—)) print('—/x',36,43,8)
	centre_text('v1.1 extar 2020',50,5)
	
	if cheats==true then
		print('cheats: all levels unlocked',0,0,8)
	end
end

function level_select_init()
	
	cloud_colour=2
	water_colour=2
	rain_init()
	clouds_init()
	
	sfx(5)
	--clock=0
	anim_clock=0
	--place cursor on next level
	row=last_row
	column=last_column
	column_level=last_column_level
	--
	message=' '
	tips={
		'clear the starting area to unlock the rest of the zone.',
		'hold — to move one pixel at a time ',
		'press Ž to use your special power ',
		'red objects will destroy your pixels.',
		'small worms just want to eat pixels.',
		'big worms will try to eat you.',
		'you can unlock new powers with † ',
		--'you will start to drop pixels if you don`t keep collecting new ones',
		'you can quit a level by pressing start/enter.',
		'the easier zones are in the centre.',
		'return pixels to the blue square at the centre of each zone.',
		'looking for the last pixel? look out for expanding rings.',
		'your pixel is brave, but not so clever.',
		'save your fellow pixels from the red worms!',
		'the word pixel is short for picture element',
	}
	tip_x=128
	tip_to_show=ceil(rnd(#tips))
	
	--calculate completed levels
	all_levels_completed=0
	for i=1,#level_complete do
		all_levels_completed+=level_complete[i]
	end	
	--calculate game time
	total_time=0
	for i=1,#complete_times do
		if complete_times[i]<32767 and complete_times[i]>0 then
			total_time+=complete_times[i]
			if total_time<0 then
				total_time=-32767
			end
		end
	end
	
	--if total_time<0 then
		--total_time_message='too slow!'
	--else
		total_time_message='total time: '..work_out_time(total_time)
	--end
	
	--reset upgrade floater reset
	floater_x=0
	floater_y=96
	floater_target_x=0
	floater_target_y=96
	--
	_update=level_select_update
	_draw=level_select_draw
end

function level_select_update()

	city_rain_update()
	clouds_update()

	--clock+=1
	anim_clock+=1
	old_row=row
	old_column=column
	old_column_level=column_level
	if btnp(”) then
		sfx(4)
		row-=1
	end
	if btnp(ƒ) then
		sfx(4)
		row+=1
	end
	if btnp(‘) then
		sfx(4)
		column+=1
		column_level+=4
	end
	if btnp(‹) then
		sfx(4)
		column-=1
		column_level-=4
	end
	if row==5 and column==1 and level_complete[4]==2 then
	elseif row==5 and column==4 and level_complete[16]==2 then
	elseif row==1 and column==5 and level_complete[13]==2 then	
	elseif level_complete[row+column_level]==0 or row!=mid(1,4,row) or column!=mid(1,4,column) then
		row=old_row
		column=old_column
		column_level=old_column_level
		sfx(9)
	end
	if btnp(—) then
		if row==5 or column==5 then
			--complete game
			if row==5 and column==4 then
				init_win()
			--upgrade 15
			elseif row==1 and column==5 then
				if upgrade_15==8 then
					player_upgrades+=1
					upgrade_15=5
					sfx(2)
					move_upgrade_floater(80,54)
				else
					sfx(9)
				end
			--upgrade 51
			elseif row==5 and column==1 then
				if upgrade_51==8 then
					player_upgrades+=1
					upgrade_51=5
					sfx(2)
					move_upgrade_floater(32,78)
				else
					sfx(9)
				end
			end
		else
			--start next level
			if level_complete[row+column_level]>0 then
				--select level
				game_init(row+column_level)
				sfx(3)
				last_row=row
				last_column=column
				last_column_level=column_level
			end
		end
	end
end

function level_select_draw()

	cls()
	pal()
	
	rain_draw()
	clouds_draw()
	
	rectfill(0,0,111,23,0)
	print('you`ve got to get back home.\nreturn all the pixels to the\ncentre to clear each zone.\nwatch out for worms!',0,0,8)
	color(7)
	--banana chase tips code
	update_tips()
	rectfill(tip_x-1,29,tip_x+#tips[tip_to_show]*4,35,0)
	print(tips[tip_to_show],tip_x,30,8)
		
	centre_text('choose zone',42,7)
	--map background
	rectfill(28,50,90,86,0)
	--draw accessible levels
	for i=1,4 do
	col=(i*4)-4
	cursor(20+(i*12),54)
		color(2)
		for i=1,4 do
			i_test=i
			if level_complete[col+i]==1 then
				print('€')
			else
				print('  ')
			end
		end
	end
	--mark completed levels
	for i=1,4 do
	col=(i*4)-4
	cursor(20+(i*12),54)
		color(8)
		for i=1,4 do
			if level_complete[i+col]==2 then
				print('€')
			else
				print('  ')
			end
		end
	end
	rect(28,50,90,86,5)
	rectfill(78,62,90,86,5)
	rectfill(42,80,64,86,5)
	cursor(32,54)
	color(7)
	print('01 05 09 13')
	print('02 06 10 14')
	print('03 07 11 15')
	print('04 08 12 16')
	--saving tokens: upgrade==true/false replaced with 8/5 to double as upgrade colour in print commands
	--if upgrade_15==8 then
		print('†',80,54,upgrade_15)
	--else
		--print('†',80,54,5)
	--end
	--if upgrade_51==8 then
		print('†',32,78,upgrade_51)
	--else
		--print('†',32,78,5)
	--end
	print('Š',68,78,8)
	--level select cursor
	if anim_clock%20>10 or btn()>0 then
		rect(18+(column*12),46+(row*6),28+(column*12),54+(row*6),8)
	end

	--upgrades sub-menu
	rect(-1,92,128,106,5)
	if  level_complete[1]!=2 then
		print('complete zone 1\nto unlock powers',0,94,5)
	else
		if btnp(Ž) then
			sfx(3)
			upgrades_menu_colour=7
			power_selected+=1
			if power_selected>player_upgrades then
				power_selected=1
			end
		else
			upgrades_menu_colour=8
		end	
		for i=1,player_upgrades do
			print('†',-8+(i*8),94,5)
		end	
		print('†',-8+(power_selected*8),94,upgrades_menu_colour)
		print('special power',24,94,upgrades_menu_colour)
		if power_selected==1 then
			print('Ž return pixels',0,100,upgrades_menu_colour)
		elseif power_selected==2 then
			print('Ž detonate pixels',0,100,upgrades_menu_colour)
		elseif power_selected==3 then
			print('Ž auto-return pixels',0,100,upgrades_menu_colour)
		end
	end
	--------
	
	if all_levels_completed>=0 and total_time_message!=nil then --==#level then
		centre_text(total_time_message,108,8)
	end
	
	if row==5 and column==4 then
		print('   goal',0,114,10)
		print('— finish',0,120,10)
	elseif row==1 and column==5 then
		if upgrade_15==8 then
			print('— unlock new power',0,120,8)
		end
	elseif row==5 and column==1 then
		if upgrade_51==8 then
			print('— unlock new power',0,120,8)
		end
	else
		print('— start level',0,120,8)
	end

	if row<5 and column<5 then

	if level_complete[1]==2 then
		print('Ž change power',60,120,upgrades_menu_colour)
	end
	if level[row+column_level]!=nil then
		print('pixels\n'..level[row+column_level],92,50,7)
	end
	if complete_times[row+column_level]!=nil then
		if complete_times[row+column_level]<32767 and complete_times[row+column_level]>0 then
			print('best time\n'..work_out_time(complete_times[row+column_level]),92,62,7)
		--else
			--print(' ')
		end
	end
	
	end
	
	draw_upgrade_floater()
	
	--debug crap
	--print(row..' '..column..' '..column_level,0,0,15)
end

function init_win()
	
	music(63)
	sky_colour=0
	boundary_colour=1
	cloud_colour=5
	moon_colour=6
	pixel_colour_1=14
	pixel_colour_2=2
	wall_colour=13
	water_background_colour=0
	water_colour=1
	
	bubbles_init()
	clouds_init()
	kelp_init()
	rain_init()

	win_messages={}
	win_step=1
	_update=update_win
	_draw=draw_win
end

function update_win()
	
	--clock+=1
	anim_clock+=1
	bubbles_update()
	clouds_update()
	kelp_update()
	rain_update()
	
	if level_complete[win_step]==2 and complete_times[win_step]<32767 and complete_times[win_step]>0 then
		win_message=tostr('zone '..win_step..': '..work_out_time(complete_times[win_step]))
		add(win_messages,win_message)
	end
	if win_step<=#level_complete then
	win_step+=1
	end
	if win_step>#level_complete and btn(—) and btn(Ž) then
		splash_init()
	end
end

function draw_win()
	cls()
	
	bubbles_draw()
	clouds_draw()
	kelp_draw()
	rain_draw()
	
	print('you win!\nyou have made it home and have\ndefeated the evil red worms.\nyour pixel friends and family\nare safe once more.',0,0,8)
	cursor(0,30)
	color(7)
	for i=1,#win_messages do
		print(win_messages[i])
	end
	if win_step>#level_complete then
		color(8)
		--if total_time_message!=nil then
			--print(total_time_message)
		--end
		print(total_time_message)
		print('—+Ž to restart')
	end
end
-->8
--main game

function game_init(lev)

	start_time=time()

	level_music(lev)

	music(bgm1)

	no_overlapping_pixels=false
	
	cars={}
	--clock=0
	anim_clock=0
	clouds={}
	complete_time='0'
	current_level=lev
	death_cooldown=0
	explosions={}
	frames_since_last_pixel=0
	grab_rings={}
	highlight_square=0
	level_complete_music=false
	level_completed_time_message='time'
	obstacles={}
	pixels={}
	--player={}
	player_colour=8
	player_coords={}
	player_speed=1
	player_x=64
	player_y=64
	radius_ticks={}
	radius_tick_time=0
	rain={}
	returners={}
	run_clock=true
	score=0
	square_size=sqrt(score)
	square_sfx=false
	pixels_in_square=true
	--test=0
	traffics={}
	win_colour=1
	worms={}
	worm_tails={}
	
	--level_colour=level[lev]
	level_colours_init(lev)
	
	local player_pixel={
		c=8,
		speed=1,
		x=0,
		y=0,
		}
	add(player_coords,player_pixel)
	--create level pixels
	for i=1,level[current_level] do
		local pixel={
			frame=randint(6),
			frame_max=6,
			id=i,
			x=randint(128),
			y=randint(122)+6,
			}
		if pixel.x==64 and pixel.y==64 then
			pixel.x+=randint(32)
			pixel.y+=randint(32)
		end
		add(pixels,pixel)
	end
	
	--obstacle placement
	if lev==1 then
		obstacle_rectangle(0,6,8,122)
		obstacle_rectangle(9,104,112,32)
		obstacle_rectangle(122,6,8,122)
	elseif lev==2 then
		obstacle_rectangle(3,22,92,16)
		obstacle_rectangle(32,95,92,16)
	elseif lev==3 then
		obstacle_rectangle(0,0,96,46)
		obstacle_rectangle(32,94,64,16)
	elseif lev==4 then
		obstacle_rectangle(32,16,64,30)
		obstacle_rectangle(0,95,32,32,true)
		obstacle_rectangle(0,100,27,27)
		obstacle_rectangle(96,95,32,32,true)
		obstacle_rectangle(101,100,27,27)
	elseif lev==5 then
		obstacle_rectangle(44,44,2,2,true)
		obstacle_rectangle(44,82,2,2,true)
		obstacle_rectangle(82,44,2,2,true)
		obstacle_rectangle(82,82,2,2,true)
		obstacle_rectangle(0,0,16,96)
		obstacle_rectangle(112,0,16,96)
	elseif lev==6 then
		obstacle_rectangle(22,22,24,24)
		obstacle_rectangle(22,82,24,24)
		obstacle_rectangle(82,22,24,24)
		obstacle_rectangle(82,82,24,24)
		obstacle_rectangle(0,122,128,6)
	elseif lev==7 then
		obstacle_rectangle(0,0,47,47)
		obstacle_rectangle(0,112,16,16,true)
		obstacle_rectangle(81,81,47,47)
	elseif lev==8 then
		obstacle_rectangle(13,81,1,64,true)
		obstacle_rectangle(32,100,1,64,true)
		obstacle_rectangle(40,95,1,64,true)
		obstacle_rectangle(64,108,1,64,true)
		obstacle_rectangle(71,91,1,64,true)
		obstacle_rectangle(89,104,1,64,true)
		obstacle_rectangle(115,75,1,64,true)
		obstacle_rectangle(124,103,1,64,true)
	elseif lev==9 then
		obstacle_rectangle(0,0,128,16)
		obstacle_rectangle(32,0,64,46)
		obstacle_rectangle(0,95,32,32)
		obstacle_rectangle(96,95,32,32)
	elseif lev==10 then
		obstacle_rectangle(24,14,8,106,true)
		obstacle_rectangle(104,14,8,106,true)
	elseif lev==11 then
		obstacle_rectangle(8,14,112,8)
		obstacle_rectangle(8,112,112,8)
		obstacle_rectangle(8,30,8,72)
		obstacle_rectangle(112,30,8,72)
	elseif lev==12 then
		obstacle_rectangle(37,37,40,4,true)
		obstacle_rectangle(37,37,4,40,true)
		obstacle_rectangle(60,90,30,4,true)
		obstacle_rectangle(86,64,4,30,true)
	elseif lev==13 then
		obstacle_rectangle(39,47,8,34)
		obstacle_rectangle(39,81,50,24)
		obstacle_rectangle(81,47,8,34)
	elseif lev==14 then
		obstacle_rectangle(8,15,8,41)
		--obstacle_rectangle(8,30,8,8)
		--obstacle_rectangle(8,46,8,8)
		--obstacle_rectangle(8,62,8,8)
		--obstacle_rectangle(8,78,8,8)
		--obstacle_rectangle(8,94,8,8)
		obstacle_rectangle(24,72,8,56)
		obstacle_rectangle(64,24,64,8)
		obstacle_rectangle(82,47,8,81)
	elseif lev==15 then
		obstacle_rectangle(38,0,8,62,true)
		obstacle_rectangle(38,66,8,62,true)
		obstacle_rectangle(82,0,8,62,true)
		obstacle_rectangle(82,66,8,62,true)
	elseif lev==16 then
		--obstacle_rectangle(0,6,8,122,true)
		--obstacle_rectangle(9,104,112,32,true)
		--obstacle_rectangle(122,6,8,122,true)
	end
	
	--enemy placement
	if lev==1 then
	
	elseif lev==2 then
		create_enemy('small_worm',128,64)
	elseif lev==3 then
		create_enemy('small_worm',0,0)
	elseif lev==4 then
		create_enemy('small_worm',64,128)
		create_enemy('small_worm',64,128)
		--create_enemy('small_worm',64,128)
	elseif lev==5 then
		create_enemy('w_traffic',33,104)
		create_enemy('n_traffic',33,104)
	elseif lev==6 then
		create_enemy('small_worm',0,128)
		create_enemy('small_worm',128,128)
	elseif lev==7 then
		create_enemy('small_worm',0,128)
		create_enemy('small_worm',0,128)
	elseif lev==8 then
		create_enemy('big_worm',0,0)
	elseif lev==9 then
		create_enemy('small_worm',0,64)
	elseif lev==10 then
		create_enemy('big_worm',64,128)
	elseif lev==11 then
		create_enemy('big_worm',128,128)
	elseif lev==12 then
		create_enemy('e_traffic',16,16)
		create_enemy('n_traffic',16,16)
		create_enemy('w_traffic',112,112)
		create_enemy('s_traffic',112,112)
	elseif lev==13 then
		create_enemy('e_traffic',16,16)
		create_enemy('w_traffic',24,24)
	elseif lev==14 then
		create_enemy('big_worm',64,128)
	elseif lev==15 then
		create_enemy('n_traffic',0,0)
		create_enemy('s_traffic',125,125)
		create_enemy('e_traffic',0,6)
		create_enemy('w_traffic',125,125)	
	elseif lev==16 then
		create_enemy('big_worm',0,0)
		create_enemy('small_worm',128,0)
		create_enemy('small_worm',0,128)
		create_enemy('small_worm',128,128)
	end
	
	bubbles_init()
	clouds_init()
	kelp_init()
	rain_init()
	
	hills_init()
	buildings_init()
	trees_init()
		
	_update=game_update
	_draw=game_draw
	
end

function game_update()
	
	--update player positions and other crap
	latest_player_pixel_x=player_x+player_coords[#player_coords].x
	latest_player_pixel_y=player_y+player_coords[#player_coords].y
	player_old_x=player_x
	player_old_y=player_y
	if #player_coords==1 then
		player_x=player_x+player_coords[1].x
		player_y=player_y+player_coords[1].y
		player_coords[1].x=0
		player_coords[1].y=0
	end
	if #player_coords!=old_player_coords and #player_coords==1 then
		player_death_nova(player_x,player_y,3)
	end
	old_player_coords=#player_coords
	
	if death_cooldown>0 then
		death_cooldown-=1
		create_explosion(player_x,player_y,1,2)
	end
	
	--if run_clock==true then
		--clock+=1
	--end
	anim_clock+=1
	
	if time()%1>0.5 then
		damage_obstacle_pattern=-1
	elseif time()%1==0 then
		damage_obstacle_pattern=randint(32767)
	end
	
	if no_overlapping_pixels==false then
		pixel_overlap_check=false
		for i=1,#pixels do
			local pci=pixels[i].id
			local pcx=pixels[i].x
			local pcy=pixels[i].y
			for pixel in all (pixels) do
				if pcx==pixel.x and pcy==pixel.y and pci!=pixel.id then
					pixel.x=randint(128)
					pixel.y=randint(122)+6
					pixel_overlap_check=true
				end
			end
		end
		if pixel_overlap_check==false then
			no_overlapping_pixels=true
		end
	end

	clouds_update()
	if scheme>4 then
		city_rain_update()
		trees_update()
	else
		rain_update()
		kelp_update()
		bubbles_update()
	end
	enemies_update()
	update_radius_ticks()
	check_radius_collision()
	update_returners()
	update_explosions()
	
	if pixels_in_square==true then
		pixels_in_square=false
		for i=1,#pixels do
			if pixels[i].x==mid(48,80,pixels[i].x) and pixels[i].y==mid(48,80,pixels[i].y) then
				pixels_in_square=true
				break
			end
		end
	end
	if pixels_in_square==false and square_sfx!=true then
		sfx(5)
		music(bgm2)
		square_sfx=true
	end	
	
	--player powers
	--if power_selected==1 then
		--drop pixels
		--if (btn(Ž)) score=2000
		--if btnp(Ž) and #player_coords>1 then
			--create_explosion(player_x+player_coords[#player_coords].x,player_y+player_coords[#player_coords].y,1,pixel_colour_2)
			--del(player_coords,player_coords[#player_coords])
			--make_replacement_pixel()
			--sfx(8)
		--end
	if btnp(Ž) and level_complete[1]==2 then
		frames_since_last_pixel=0
		--auto-return pixels
		if #player_coords>1 then --and power_selected!=2 then
			create_returner(latest_player_pixel_x,latest_player_pixel_y)
			del(player_coords,player_coords[#player_coords])
			score+=1
			square_size=sqrt(score)
			sfx(12)
		end
	
		--grab ring
		if #player_coords>1 and power_selected==2 then
			create_grab_ring(latest_player_pixel_x,latest_player_pixel_y)
			--if #player_coords>1 then
				--create_returner(latest_player_pixel_x,latest_player_pixel_y)
				--del(player_coords,player_coords[#player_coords])
				--score+=1
				--square_size=sqrt(score)
			--end
			sfx(15)
		end
	
		--toggle auto-clear
		if power_selected==3 and player_auto_clear!=true then
			player_auto_clear=true
		else
			player_auto_clear=false
		end
	end
	
	if btn(—) then
		if btnp(‹) then
			player_x-=player_speed
			sfx(16)
		end
		if btnp(‘) then
			player_x+=player_speed
			sfx(16)
		end
		if obstacle_collision() then
			player_x=player_old_x
		end
		if btnp(”) then
			player_y-=player_speed
			sfx(16)
		end
		if btnp(ƒ) then
			player_y+=player_speed
			sfx(16)
		end
		if btn()>0 then
			check_pixel_collision()
		end
	else
		if btn(‹) then
			player_x-=player_speed
		end
		if btn(‘) then
			player_x+=player_speed
		end
		if obstacle_collision() then
			player_x=player_old_x
		end
		if btn(”) then
			player_y-=player_speed
		end
		if btn(ƒ) then
			player_y+=player_speed
		end
		if btn()>0 then
			check_pixel_collision()
		end	
		if obstacle_collision() then
			player_y=player_old_y
		end
	end
	if btn()>0 then
		check_pixel_collision()
	end	
	reseed_pixels()
	if #player_coords<score+8 then
		overloaded=false
		pixel_colour=pixel_colour_1
	else
		overloaded=true
		player_auto_clear=false
		pixel_colour=pixel_colour_2
	end
	
	--return to level select screen
	if score>=level[current_level] and (btn(—) and btn(Ž)) then
		level_select_init()
	end
	
	--if clock<0 then
		--level_select_init()
	--end
	
	check_level_completion()
end

function game_draw()
	cls()
	level_colours_draw()
	rectfill(0,0,127,127,sky_colour)
	if scheme<5 then
		rectfill(0,96,127,127,water_background_colour) --water
	end
	rectfill(16,16,32,32,moon_colour) --moon
	clouds_draw()
	rain_draw()
	if scheme==5 then
		draw_hills()
		draw_trees()
	elseif scheme==6 then
		draw_hills()
		draw_buildings()
	else
		kelp_draw()
		bubbles_draw()
	end
		
	--pixel radius tick
	if time()%3==0 and #pixels>0 then
		rt_target=ceil(rnd(#pixels))
		create_radius_tick(pixels[rt_target].x,pixels[rt_target].y)
	end
	--draw boundary
	boundary=sqrt(level[current_level])
	boundary_xy1=63-boundary/2
	boundary_xy2=65+boundary/2
	if time()%2<1.9 then
		rect(boundary_xy1,boundary_xy1,boundary_xy2,boundary_xy2,boundary_colour)
	end
	--square draw
	square_xy1=64-(square_size/2)
	square_xy2=64+(square_size/2)
	rectfill(square_xy1,square_xy1,square_xy2,square_xy2,12)
	move_pixels_from_square()
	--move pixels in square
	if overloaded==true and anim_clock%8>4 then
		rectfill(square_xy1,square_xy1,square_xy2,square_xy2,13)
	end
	--end of square draw
	--highlight square when its time
	--to return to base
	if overloaded==true and highlight_square==0 then
		highlight_square=30
	end
	if highlight_square>0 then
		highlight_square-=2
		if highlight_square<15 and anim_clock%2==0 then
			rect(square_xy1-highlight_square,square_xy1-highlight_square,square_xy2+highlight_square,square_xy2+highlight_square,boundary_colour)
		end
	end
	--end of highlight
	--if not (btn(—) or btn(Ž)) then
		check_score()
	--end
	for i=1,#pixels do
		pset(pixels[i].x,pixels[i].y,pixel_colour)
	end
	if pixels_in_square==true then
		rect(47,47,81,81,wall_colour)
		for i=1,#pixels do
			if pget(pixels[i].x,pixels[i].y)==13 then
				pixels[i].x-=1
				pixels[i].y-=1
			end
		end

	end
	
	draw_obstacles()
	enemies_draw()
	draw_radius_ticks()
	draw_returners()
	draw_explosions()
	damage_obstacle_collision()
	move_pixels_from_obstacles()
		
	--player turns black in damage zone?
	for i=1,#player_coords do
		x=player_x+player_coords[i].x
		y=player_y+player_coords[i].y
		if #player_coords==1 and pget(player_x+player_coords[1].x,player_y+player_coords[1].y)==8 then
			pset(x,y,0)
		else
			pset(x,y,player_colour)
		end
	end
	--player hud
	rectfill(0,0,128,5,1)
	print('pix:'..#pixels,1,0,pixel_colour_1)
	if anim_clock%8>4 then
		hud_colour=8
	else
		hud_colour=7
	end
	if overloaded==true then
		print('return pixels',64-26,0,hud_colour)
	else
		if btn(—) then
			print('sneak',37,0,hud_colour)
		end
		if level_complete[1]==2 then
			if btn(Ž) or player_auto_clear==true then
				print('power',61,0,hud_colour)
			end
			if not(btn(Ž) or btn(—) or player_auto_clear==true) then
				print('brave pixel',64-22,0,8)
			end
		end
	end
	score_message='scr:'..score
	print(score_message,128-(#score_message*4),0,12)
	--pixel capacity
	line(1,5,126,5,2)
	player_capacity=(127/(score+8)*(#player_coords))
	line(1,5,player_capacity,5,8)
	--print(stat(1),0,18,10)
	
	--draw level complete section
	if score>=level[current_level] then
		if win_colour>=16 then
			win_colour=2
		else
			win_colour+=0.1
		end
		palt(0,false)
		rectfill(29,52,96,74,0)
		rect(29,52,96,74,1)
		centre_text('zone complete!',55,win_colour)
		if current_level==1 then
			centre_text('powers unlocked!',61,win_colour)
		end
		centre_text(level_completed_time_message,67,win_colour)
		centre_text('press — and Ž to continue',120,7)
	end
	
	--debug crap
	--print(btn(),0,6,7)
end
__gfx__
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
010100002705033050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001a050220500e0000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000181521f1521f152000001f142000001f132000001f122000001f112000001f10200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000001052090520c05210052140521d0522205200005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000705013050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000185501a7501c5501d7501f550217502355024750185501a7501c5501d7501f55021750235502475000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000024610221152210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000024610223000000024610223000000024610223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000e05000000160500e00002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000c05014150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000c15000000186500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001a050225500e0000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001a050220500e0002705033050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000c05318653186431863300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001a5521d55221552265522d55226552215521d5521a5521a5421a532005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
011f00000c65300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002403130031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000189151a9151c9151a91518915189131891318913000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
015000000004500010000350001000035000100003500010000350001000035000100003500010000350001000045000350003500035000350003500035000350004500035000350003500035000350003500035
015000000c734057340b7340b7340b7340b734057340c7340c7340c73411734117341773417734177341773417735177351773517735177351773217732177321773217732177321773217732177321773217732
012400000c0120c0120c0120c0100c0100c0100c0120c0120c0120c0100c0100c0100c0120c0120c0120c0100c0100c0100c0120c0120c0120c0100c0100c0100c0120c0120c0120c0100c0100c0100c0120c012
011400000c53212522145220c5321252214522135321352213522135321352213522135320c52212522145320c522125221453213522135221653215522105221653215522105220f53213522135221353213522
011400000c732117321773217732177221771217732177320c7320c73211732117321773217732177221772217712177221772217712177221772217712177221772217712177221772217712177221772217712
011400000000000000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000101300c1300b13008130081300813008130081300c1300c1300c1300c1300c1300c1300c1300c1300c1200c1200c1200c1200c1200c1200c1200c1200c1100c1100c1100c1100c1100c1100c1100c110
00140000101300c1300b1300813008130081300813008130071300713007130071300713007130071300713007120071200712007120071200712007120071200711007110071100711007110071100711007110
0114000024910188100c9100081024910188100c9100081024910188100c9100081024910188100c9100081024910188100c9100081024910188100c9100081024910188100c9100081024910188100c91000810
015000000004500035000350003500035000350003500035000450003500035000350003500035000350003500045000350003500035000350003500035000350004500035000350003500035000350003500035
01240000051350b1350e135001000010000100051350b1350e135001000010000100051350b1350e135001000010000100051350b1350e135001000010000100051350b1350e135001000010000100051350b135
014800003031400000000003131400000000003031400000000003031400000000003131400000000003131400000000003531400000000003531400000000003031400000000003031400000000003031400000
01240000052211132111422112221132211422112220532100000000000a3220a3220a3220a3220a3220a322052211132111422112221132211422112220532100000000000a3220a3220a3220a3220a3220a322
01240000053250532505322053220532205322053220532205325053250532205322053220532205322053220b3250b3250b3220b3220b3220b3220b3220b3220f3250f3250f3220f3220f3220f3220f3220f322
011200001102017020110200000019020190201802018020180200000011020170201902019020180201802018020000001102017020110200000019020190201802018020180200000011020170201902019020
01120000051350b1350e135001000010000100051350b1350e135001000010000100051350b1350e135001000010000100051350b1350e135001000010000100051350b1350e135001000010000100051350b135
012400000504505045000050504505045000050504505045000050504505045000050504505045000050504505045000050504505045000050504505045000050504505045000050504505045000050504505045
012400000403004130045300403004030041300453004030000300013000530000300003000130005300003001030011300153001030010300113001530010300203002130025300203002030021300253002030
012400002875223750287501f7402875223750287501e74028752237401e752237402175223740217521e7401c7521f7501e7501c7401a7521e7501c7501a740187521c7501a7501874017752187501775015740
0124000028752237501f7501c75028752237501f7501c75028752237502475223750217521f7501e7521c750187501a7501c7501e7521c7501e7501f750217521f75021750237502475223750247522375021750
012400001c0451f045230451f0451c0451f045230451f0451c0451f045240451f0451c0451f045240451f0451c0451f045250451f0451c0451f045250451f0451c0451f045260451f0451c0451f045260451f045
0124000010030100301003010030100301003010030100300c0300c0300c0300c0300c0300c0300c0300c0300d0300d0300d0300d0300d0300d0300d0300d0300e0300e0300e0300e0300e0300e0300e0300e030
012400001c7501e7501f750237502375223752237522375024752237502475223750217501f7501e7501c7501c7501f7502375028750287522875228752287522875228750297512875029751237501f7501c750
014000000074500745007450074500745007450074500755007650076500765007650076500765007450074500745007450074500745007450074500745007450074500745007450074500745007450074500745
001000000c7400074000740007400c7300073000730007300c7200072000720007200c7100071000710007100c7400074000740007400c7300073000730007300c7200072000720007200c710007100071000710
011000000c54000540135300753011520055201051004510165400a5401553009530135200752013510075101354007540165300a530185200c5201351007510165400a540185300c530165200a520185100c510
011000000c5400c5400c5400c5400e5300e5300c5300c5300a5400a5400a5400a5400c5300c5300a5300a530095400954009540095400a5300a53009530095300754007540075400754005530055300753007530
01100000075400754009540095400a5400a5400c5400c5400c5400c5400c5400c5400a5400a540055400554007540075400754007540095400954009540095400a5400a5400a5400a5400c5400c5400c5400c540
011000000c03013030180301f0200c02013020180101f0100c03013030180301f0200c02013020180101f0100c03013030180301f0200c02013020180101f010180301f030240302b020240202b0203001037010
0110000013050000001303000000130100000000000000001a050000001a030000001a0100000000000000001d050000001d030000001d010000001c050000001c030000001c010000001a030000001a01000000
0110000018050000001803000000180100000000000000001f050000001f030000001f0100000000000000002205000000220300000022010000002105000000210300000021010000001f030000001f01000000
__music__
00 3f 42 43 44
00 3f 42 43 39
00 3e 42 43 39
00 3e 42 38 39
00 3f 3d 38 39
00 3f 3d 38 44
00 3e 3d 38 44
00 3e 3d 38 44
00 3f 3d 3c 38
00 3f 3d 3c 38
00 3e 3d 3b 38
00 3e 3d 3b 38
00 3e 3d 3a 38
00 3f 3d 3a 38
00 3e 3d 3a 38
00 3e 3d 3a 38
00 3e 42 3a 38
00 3f 42 3a 38
00 3e 42 3a 38
02 3e 42 3a 38
01 35 36 43 44
00 35 36 43 44
00 35 36 37 44
00 35 36 37 44
00 35 36 34 44
00 35 36 34 44
00 35 36 33 44
00 35 36 33 44
00 32 36 37 44
00 32 36 37 44
00 32 36 34 44
02 32 36 34 44
03 32 36 43 44
01 31 2c 23 44
00 31 2c 23 44
00 30 31 2c 44
00 30 31 2c 44
00 30 31 2f 44
00 30 31 2f 44
00 30 31 2f 2e
00 30 31 2f 2e
00 41 31 2c 2e
00 41 31 2c 2e
00 41 31 2d 2e
00 31 42 2d 2e
00 31 30 2d 2e
00 31 30 2d 2e
00 31 2f 2d 2e
02 31 2f 2d 2e
03 2b 31 23 44
01 26 2a 29 44
00 26 2a 29 44
00 26 2a 28 29
00 26 2a 27 29
00 26 2a 28 25
00 26 2a 27 25
00 24 2a 28 25
00 24 2a 27 25
00 24 2a 28 44
00 24 2a 27 44
00 24 2a 29 44
02 24 2a 29 44
03 26 21 22 44
03 3a 3d 38 39
