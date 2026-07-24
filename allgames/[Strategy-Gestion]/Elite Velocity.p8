pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

--elite velocity
--by raptorbandit
--sprites inspired by https://www.slynyrd.com/blog/2018/12/12/pixelblog-12-to-the-stars

--object types
--1. drifting asteroid
--2. space station
--3. ore
--4. misc details, no interaction
--5. enemies
--6. splosions
--7. rings

--sfx
--0. shoot blaster 
--1. thrust
--2. tractor
--3. hit asteroid
--4. ore pickup
--5. warp
--6. mlaser
--7. enemy alert
--8. enemy shoot
--9. menu buy
--10. menu move
--11. enemy explosion
--12. not enough ore
--13. charge warp
--14. music 1-1 (station)
--15. music 2-1 (title)
--16. music 2-2 (title)
--17. music 2-3 (title)
--18. music 1-2 (station)
--19. warp whiteflash

function _init()

	mode="title"
	music(0)
	t=0
	
	charge=0
	fuel=0
	ore=10
	num_jumps=0
	num_kills=0
	total_ore=0

	shake=0
	rotspd=0
	item_sel=1
	menu_sel=1
	
	hostile_timer=2700
	player_flash_timer=0
	ore_timer=0
	butt_press_timer=15
	warp_timer=0
	alert_timer=90
	start_timer=0
	death_timer=120
	white_flash_timer=0
	display_name_timer=0
	
	fnum=0
	fade_timer=0
	fade_typ="out"
	
	cx,cy=64,64

	sector_max=384
	sector_min=64

	tractor=false
	own_tractor=false
	mmap=false
	colliding=false
	player_dead=false
	player_thrust=false
	warping=false
	alert=false
	
	fuel_flash=false
	ore_flash=false
	warp_lines=false

	txt_buff=false
	
	start=false
	retire=false
	early_end=false
	roids_exist=false
	ore_exist=false
	
	dr_pl=false
	dr_pl2=false
	dr_mn=false
	
	flash_white_col=7
	flash_red_col=8
	flash_yellow_col=10

	player_gfx={}
	player_thrust_gfx={}
	lins={}
	obj={}
	bullets={}
	ebull={}
	floaty_num={} --x,y,txt,color,timer
	
	stars={}
	title_stars={}
	blinky_stars={}
	border_stars={}
	shooting_stars={}
	star_cols={1,5,6,7}
	s_ani1={}
	s_ani2={}
	ss_ani={192,194,196,198,200,202,204,206,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192,192}
	
	populate_star_tables()
	
	ss_n1={"last","new","the","rebel","imperial","dead","rumble","tau","united","freedom","subspace","ambrosia","mount","star","etheral","giant","terran","vanu","outer","bleak","frozen","amber","quartz","amethyst","emerald","ruby","opal","topaz","lone","azure","auxillary","future","fifth","legitimate"}
	ss_n2={"hope","city","rock","mountain","sky","viper","ark","star","b7r","destiny","nova","derelict","bomb","republic","sovereignty","conglomerate","rim","bastion","heaven","house","hulk","dawn","shadowdeep","alliance","remnant","falls","guard","justice","temple","expedition","2.0","twilight","tower","loop","monarchy","war cult","orbit","sphere","spacedock","authority"}	
	sys_names={"vellos","aurora","capella","vega","moash","heraan","freya","dani","tekel","korra","altair","polaris","nil'kemorya","scheall","mjolnir","procyon","avalon","pfhor","s'pht","durandal","marathon","oni","korell","telluer","tuatha","obatta","holpa","viola","rigel","galatea","bastion","knossos","fomalhaut","primus","ngc-1337","hot'a'tania","tichel","kerella","gonq","ugo-20416","diomedes","belisarius","ambrosia"}
	
	items={"fuel","radar","tractor beam","mining laser","mk2 blaster","repair","retire"}
	item_tut={false,false,false,false,false,false,false}
	item_cost={10,25,25,50,25,10,250}
	item_col={11,11,11,11,11,11,11}
	item_desc={"use fuel to reach new systems","shows objects in system","attract ore to your ship","short range, high intensity","high rate of fire","repair ship to full health","end your career"}
	
	player={
		x=128,
		y=128,
		dx=0,
		dy=0,
		ang=0.875,
		r=4,
		th=0.05,
		atspeed=false,
		max_vel=2,
		turn_spd=0.025,
		c=11,
		h=3,
		gun={
			r=1,
			drift=true,
			t=25,
			spd=5,
			timer=15,
			sfx=0
			}
	}
	
	mlaser={
		r=1,
		drift=false,
		t=4,
		spd=4,
		timer=0,
		sfx=6
	}
	
	mk2blaster={
		r=1,
		drift=true,
		t=10,
		spd=7,
		timer=10,
		sfx=0
	}
		
	e_max_vel=player.max_vel-0.25
	cam_x=player.x-64
	cam_y=player.y-64

end

function populate_star_tables()
	for i=1,256 do
		add(title_stars, {
		x = rnd(128),
		y = rnd(128),
		c = star_cols[flr(rnd(#star_cols)+1)]
		})
	end
	
	for i=1,8 do
		add(blinky_stars, {
		x = rnd(128),
		y = rnd(128),
		typ=flr(rnd(2)),
		ani={}
		})
	end
	
	for b in all (blinky_stars) do
		for i=1,flr(rnd(5)+20) do
			add(b.ani,16)
		end
		
		if b.typ==1 then
			for i=17,21 do
				add(b.ani,i)
			end
		else
			for i=33,36 do
				add(b.ani,i)
			end
		end
	end
	
	for i=8,48 do
		add(border_stars, {
		x = i*8,
		y = flr(rnd(8)+56),
		ani={}
		})
	end
	
	for i=8,48 do
		add(border_stars, {
		x = flr(rnd(8)+56),
		y = i*8,
		ani={}
		})
	end
	
	for i=8,48 do
		add(border_stars, {
		x = flr(rnd(8)+376),
		y = i*8,
		ani={}
		})
	end
	
	for i=8,48 do
		add(border_stars, {
		x = i*8,
		y = flr(rnd(8)+376),
		ani={}
		})
	end
	
	for d in all (border_stars) do
		for i=1,flr(rnd(5)+20) do
			add(d.ani,48)
		end
		for i=49,53 do
			add(d.ani,i)
		end
	end
end

function make_system()

	sys_name=sys_names[flr(rnd(#sys_names))+1]
	display_name_timer=120
	hostile_timer=2700
	item_col[1]=11

	make_station(flr(rnd(224)+128),flr(rnd(224)+128))
	
	local n=flr(rnd(3)+5)
	for i=0,n do
		make_roid(flr(rnd(254)+132),flr(rnd(254)+132),rnd(0.5)-0.25,rnd(0.5)-0.25)
	end
	
	if (num_jumps==1) make_bad(flr(rnd(256)+128),flr(rnd(256)+128),150)
	if num_jumps==2 then
		make_bad(flr(rnd(256)+128),flr(rnd(256)+128),150)
		make_bad(flr(rnd(256)+128),flr(rnd(256)+128),150)
	end
	if num_jumps>=3 then
		make_bad(flr(rnd(256)+128),flr(rnd(256)+128),150)
		make_bad(flr(rnd(256)+128),flr(rnd(256)+128),150)
		make_bad(flr(rnd(256)+128),flr(rnd(256)+128),150)
	end
	
	for i in all (stars) do
		del(stars,i)
	end
	
	for i=1,1024 do
		add(stars, {
		x = rnd(896),
		y = rnd(896),
		c = star_cols[flr(rnd(#star_cols)+1)]
		})
	end
	
	for b in all (blinky_stars) do
		b.x=(flr(rnd(320)+64))
		b.y=(flr(rnd(320)+64))
	end
	
	--the sector limits are 384 and 64
	--we offset by a certain amount to make sure the sprites don't get drawn past the boundaries
	px,py=flr(rnd(288)+64),flr(rnd(288)+64)
	px2,py2=flr(rnd(288)+64),flr(rnd(288)+64)
	mx,my=flr(rnd(288)+64),flr(rnd(288)+64)
	sx,sy=flr(rnd(256)+128),flr(rnd(256)+128)
	
	if rnd(4)>3 then
		dr_pl=true
		make_ring(px-8,py+28)
	else
		dr_pl=false
	end
	
	if rnd(4)>3 then
		dr_pl2=true
	else
		dr_pl2=false
	end
	
	if rnd(4)>3 then
		dr_mn=true
	else
		dr_mn=false
	end
end

function make_roid(ox,oy,odx,ody)
	add(obj, {
		x=ox,
		y=oy,
		dx=odx,
		dy=ody,
		r=12,
		n=6,
		c=6,
		typ=1
	})
end

function make_station(ox,oy)

	n1=ss_n1[flr(rnd(#ss_n1))+1]
	n2=ss_n2[flr(rnd(#ss_n2))+1]
	
	add(obj, {
		x=ox,
		y=oy,
		dx=0,
		dy=0,
		r=16,
		n=3,
		c=12,
		typ=2
	})
	
	add(obj, {
		x=ox,
		y=oy,
		dx=0,
		dy=0,
		r=4,
		n=4,
		c=12,
		typ=4
	})
end

function make_bad(ox,oy,ost)
	add(obj, {
		x=ox,
		y=oy,
		dx=0,
		dy=0,
		r=5,
		n=5,
		c=8,
		typ=5,
		h=3,
		--st = shoot timer = time until enemy shoots when first spawning
		--allows us to give the player time to react before enemy starts shooting
		--after the first shot, st defaults to 60~ as per enemy update function
		st=ost
	})
end

function make_splode(ox,oy,oc,ot)
	add(obj, {
		x=ox,
		y=oy,
		dx=(rnd(0.5)-0.25)*3,
		dy=(rnd(0.5)-0.25)*3,
		r=2,
		n=3,
		c=oc,
		typ=6,
		t=ot
	})
end

function make_ring(ox,oy)
	for i=1,12 do
		add(obj, {
			x=ox+(i*4)+rnd(2)-1,
			y=oy-(i*1.5),
			dx=-0.25,
			dy=-0.25,
			r=1,
			n=6,
			c=15,
			typ=7
		})
	end
end

-->8
--main update/draw
function _update()
	
	if (mode=="game") update_game()
	if (mode=="station") update_station()
	if (mode=="warp") update_warp()
	if (mode=="title") update_title()
	if (mode=="help") update_help()
	if (mode=="retire") update_retire()
	
	if (butt_press_timer>0) butt_press_timer-=1
	if (ore_timer>0) ore_timer-=1
	if (warp_timer>0) warp_timer-=1
	if (player_flash_timer>0) player_flash_timer-=1
	if (fade_timer>0) fade_timer-=1
	if (fade_timer%4==2) dofade()
	if (start_timer>0) start_timer-=1
	if (display_name_timer>0) display_name_timer-=1
	
	t+=1
	if (t>60) t=0
	
	rotspd+=0.0025
	if (rotspd==1) rotspd=0
	
	if player_flash_timer>0 then 
		player.c=flash_white_col
		player_h_col=flash_red_col
	else 
		player.c=11 
		player_h_col=11
	end
	
	if (t%30<15) then
		flash_red_col="8"
		flash_white_col="7"
		flash_yellow_col="10"
	else
		flash_red_col="11"
		flash_white_col="11"
		flash_yellow_col="11"
	end
	
	for n in all (floaty_num) do
		n.x-=1
		n.y-=1
		if (n.t>0) n.t-=1
		if (n.t<=0) del(floaty_num,n)
	end
end

function _draw()
	if mode=="game" or mode=="warp" then draw_game() end
	if (mode=="station") draw_station()
	if (mode=="title") draw_title()
	if (mode=="help") draw_help()
	if (mode=="retire") draw_retire()
	
	for n in all (floaty_num) do
		oprint8(n.txt,n.x,n.y,n.c,1)
	end
	
	--debug
	-- print("mem:"..stat(0),cam_x,cam_y,8)
	-- print("cpu:"..stat(1),cam_x,cam_y+8,8)
	-- print("fps:"..stat(7),cam_x,cam_y+16,8)
end

-->8
--update+draw game,player,warp
function update_game()

	roids_exist=false
	ore_exist=false
	early_end=false
	player_thrust=false
	alert=false
	do_stn_txt=false

	roid_drift_x=rnd(0.5)-0.25
	roid_drift_y=rnd(0.5)-0.25
	if (shake>0.25) shake=0.25
	
	--If the player takes too long in a system
	--spawn some baddies
	hostile_timer-=1
	if hostile_timer<=0 then
		hostile_timer=2700
		if num_jumps<3 then
			make_bad(flr(rnd(320)+128),flr(rnd(320)+64),150)
		elseif num_jumps==3 then
			make_bad(flr(rnd(320)+128),flr(rnd(320)+64),150)
			make_bad(flr(rnd(320)+128),flr(rnd(320)+64),150)
		else
			make_bad(flr(rnd(320)+128),flr(rnd(320)+64),150)
			make_bad(flr(rnd(320)+128),flr(rnd(320)+64),150)
			make_bad(flr(rnd(320)+128),flr(rnd(320)+64),150)
		end
	end
	
	update_player()
	update_objects()
	update_bullets()
	
	if alert==true then
		if (alert_timer==90) sfx(7)
		if (alert_timer>0) alert_timer-=1
		if (alert_timer==0) alert_timer=90
	end
	
	--if there are no more asteroids or ore in the system
	--and the player doesn't have enough ore to buy fuel
	--and the player doesn't have any fuel to warp to new system
	--the game is over!
	if mode!="warp" then
		if ((roids_exist==false) and (ore_exist==false)) and (ore<10 and fuel==0) then
			mmap=false
			early_end=true
			if btn(4) and btn(5) then
				restart_game()
			end
		end
	end
	txt_buff=false
end

function draw_game()
	if (warping==false) cls()
	
	doshake()
	draw_planets()
	
	if (t==0) sx,sy=flr(rnd(256)+128),flr(rnd(256)+128)
	draw_star(sx,sy,ss_ani)
	
	if white_flash_timer>0 then
		white_flash_timer-=1
		for i=15,0,-1 do
			pal(i,7,1)
		end
	end
	
	if (white_flash_timer==0) pal()
	
	for b in all (blinky_stars) do
		draw_star(b.x,b.y,b.ani)
	end
	
	for d in all (border_stars) do
		draw_star(d.x,d.y,d.ani)
	end
		
	for b in all (bullets) do
		line(b.x,b.y,b.x+b.dx*3,b.y+b.dy*3,9)
	end
	
	for e in all (ebull) do
		line(e.x,e.y,e.x+e.dx*3,e.y+e.dy*3,8)
	end

	for s in all (stars) do
		if (warp_lines==false) pset(s.x,s.y,s.c)
		if (warp_lines==true) line(s.x,s.y,s.x+3,s.y+3,star_cols[flr(rnd(#star_cols))+1])
	end
	
	--draw objects
	for o in all(obj) do
		ngon(o.x,o.y,o.r,o.n,o.c)
		
		if o.typ==5 then
			line(o.x,o.y,o.x+cos(player_loc(o.x,o.y))*o.r,o.y+sin(player_loc(o.x,o.y))*o.r,8)
		end

		--print station text
		if col(player,o) and o.typ==2 and txt_buff==false then
			do_stn_txt=true
			line(o.x+o.r,o.y+o.r,o.x+o.r-5,o.y+o.r,11)
			line(o.x+o.r,o.y+o.r,o.x+o.r,o.y+o.r-5,11)
			
			line(o.x-o.r,o.y-o.r,o.x-o.r+5,o.y-o.r,11)
			line(o.x-o.r,o.y-o.r,o.x-o.r,o.y-o.r+5,11)
			
			line(o.x-o.r,o.y+o.r,o.x-o.r+5,o.y+o.r,11)
			line(o.x-o.r,o.y+o.r,o.x-o.r,o.y+o.r-5,11)
			
			line(o.x+o.r,o.y-o.r,o.x+o.r-5,o.y-o.r,11)
			line(o.x+o.r,o.y-o.r,o.x+o.r,o.y-o.r+5,11)
		end
	end
	
	--draw bottom console
	rectfill(cam_x,cam_y+119,cam_x+127,cam_y+127,1)
	rect(cam_x,cam_y+119,cam_x+127,cam_y+127,11)
	
	draw_health(cam_x+100,cam_y+112)
	
	game_text()
	
	--draw player
	if player_dead==false then
		for l in all (player_gfx) do
			line(l[1],l[2],l[3],l[4],l[5])
		end
	end
	
	if player_thrust==true then
		for l in all (player_thrust_gfx) do
			line(l[1],l[2],l[3],l[4],l[5])
		end
	end

	if tractor==true then
		ngon(player.x,player.y,9,5,12)
	end
	
	--minimap
	if mmap==true then
		rectfill(cam_x+2,cam_y+2,cam_x+20,cam_y+20,1)
		rect(cam_x+2,cam_y+2,cam_x+20,cam_y+20,11)
		pset(cam_x+player.x/20,cam_y+player.y/20,11)
		for o in all(obj) do
			pset(cam_x+o.x/20,cam_y+o.y/20,o.c)
		end
	end
end

function game_text()
	
	--draw game text
	if display_name_timer>0 then
		txt_buff=true
		print("entering the "..sys_name.." system",cam_x+2,cam_y+121,11)
	end

	if do_stn_txt==true and txt_buff==false then
		txt_buff=true
		print("reduce speed & press Ž to dock",cam_x+2,cam_y+121,11)
	end
	
	if ore_timer>0 and txt_buff==false then 
		txt_buff=true
		print("ore:"..ore,cam_x+98,cam_y+121,flash_yellow_col)
	end
	
	if charge>0 and fuel>0 then
		rectfill(player.x-20,player.y+10,player.x-20+charge,player.y+15,12)
	end
	
	if charge>0 and fuel>0 and txt_buff==false then
		txt_buff=true
		print("hold ƒ to charge warp. fuel:"..fuel,cam_x+2,cam_y+121,11)
	end
	
	if btn(3) and fuel==0 and txt_buff==false then
		txt_buff=true
		print("fuel:"..fuel,cam_x+100,cam_y+121,flash_white_col)
	end 
	
	if own_tractor==true and tractor==true and txt_buff==false then
		txt_buff=true
		print("hold Ž to tractor",cam_x+2,cam_y+121,11)
	end
	
	if alert==true and txt_buff==false then
		txt_buff=true
		print("! hostiles detected !", cam_x+22,cam_y+121,flash_red_col)
	end
	
	if death_timer<=0 then
		oprint8("pirates have ended your career",cam_x,cam_y,11,1)
		oprint8("pirates destroyed:"..num_kills,cam_x,cam_y+6,8,1)
		oprint8("number of warps:"..num_jumps,cam_x,cam_y+12,12,1)
		oprint8("total ore collected:"..total_ore,cam_x,cam_y+18,10,1)
		oprint8("press — to start a new career",cam_x,cam_y+24,flash_white_col,1)
	end
	
	if early_end==true then
		oprint8("there are no more asteroids",cam_x,cam_y,11,1)
		oprint8("you have no fuel and not enough",cam_x,cam_y+6,11,1)
		oprint8("ore to buy more.",cam_x,cam_y+12,11,1)
		oprint8("your career is over.",cam_x,cam_y+18,11,1)
		oprint8("pirates destroyed:"..num_kills,cam_x,cam_y+24,8,1)
		oprint8("systems visited:"..num_jumps,cam_x,cam_y+30,12,1)
		oprint8("total ore collected:"..total_ore,cam_x,cam_y+36,10,1)
		if butt_press_timer==0 then oprint8("press Ž+— to start a new game",cam_x+2,cam_y+100,flash_white_col,1) end
	end
end

function draw_planets()
	if dr_pl==true then
		spr(72,px,py,4,4)
		spr(76,px,py,4,4)
	end
	
	if dr_pl2==true then
		spr(136,px2,py2,4,4)
		spr(68,px2,py2,4,4)
	end
	
	if dr_mn==true then
		spr(132,mx,my,4,4)
	end	
end

function update_player()

	draw_player()

	if player_dead==false then
		if (btn(0)) player.ang-=player.turn_spd
		if (btn(1)) player.ang+=player.turn_spd
		
		--arrow up
		if btn(2) then 
			player.dx+=sin(player.ang)*player.th
			player.dy+=cos(player.ang)*player.th
			sfx(1)
			player_thrust=true
		end 
		
		--arrow down
		if btn(3) and charge<40 and fuel>0 then
			charge+=0.5
			sfx(13)
		elseif charge>0 then
			charge-=1
		end 
		
		if btn(4) and own_tractor==true then
			tractor=true
			sfx(2)
		else
			tractor=false
		end
		
		if player.gun.drift==true then
			bullet_drift = rnd(0.3)-0.15
		else
			bullet_drift=0
		end
		
		if butt_press_timer==0 then
			if btn(5) then
				add(bullets, {
				x=player.x,
				y=player.y,
				r=player.gun.r,
				dx=sin(player.ang)+bullet_drift,
				dy=cos(player.ang)+bullet_drift,
				t=player.gun.t,
				spd=player.gun.spd
				})
				butt_press_timer=player.gun.timer
				sfx(player.gun.sfx)
			end 
		end
	end
	
	if charge==40 then
		fuel-=1
		warp_timer=180
		mode="warp"	
		sfx(5)
		charge=0
	end
	
	--clamp max velocity
	if (player.dx>player.max_vel) player.dx=player.max_vel
	if (player.dx<-player.max_vel) player.dx=-player.max_vel
	if (player.dy>player.max_vel) player.dy=player.max_vel
	if (player.dy<-player.max_vel) player.dy=-player.max_vel
	
	if (player.ang>1) player.ang=0
	if (player.ang<0) player.ang=1
	
	if player_dead==false then
		player.x+=player.dx
		player.y+=player.dy
	end
		
	--sector limits
	if (player.x>sector_max) player.x=sector_min
	if (player.x<sector_min) player.x=sector_max
	if (player.y>sector_max) player.y=sector_min
	if (player.y<sector_min) player.y=sector_max

	--camera
	cam_x=player.x-64
	cam_y=player.y-64
	camera(cam_x,cam_y)
	
	--is player moving 'fast'?
	if 
		player.dx>-0.25 and 
		player.dx<0.25 and
		player.dy<0.25 and
		player.dy>-0.25
	then
		player.atspeed=false
	else
		player.atspeed=true
	end
	
	--player death
	if player.h<=0 then
		mmap=false
		player_dead=true
		death_timer-=1
	end
	
	if player_dead==true and death_timer<=0 then
		if btnp(5) then
			restart_game()
		end
	end
end

function draw_player()
	player_gfx={
		{	player.x+(sin(player.ang)*player.r),
			player.y+(cos(player.ang)*player.r),
			player.x+(sin(player.ang-.40)*player.r),
			player.y+(cos(player.ang-.40)*player.r),
			player.c},
			
		{	player.x+(sin(player.ang)*player.r),
			player.y+(cos(player.ang)*player.r),
			player.x+(sin(player.ang+.40)*player.r),
			player.y+(cos(player.ang+.40)*player.r),
			player.c},
			
		{	player.x+(sin(player.ang-.40)*player.r),
			player.y+(cos(player.ang-.40)*player.r),
			player.x+(sin(player.ang+.40)*player.r),
			player.y+(cos(player.ang+.40)*player.r),
			player.c}
		}
		
	player_thrust_gfx={
		{	player.x-(sin(player.ang)*7),
			player.y-(cos(player.ang)*7),
			player.x+(sin(player.ang-.40)*player.r),
			player.y+(cos(player.ang-.40)*player.r),
			9},
		
		{	player.x-(sin(player.ang)*7),
			player.y-(cos(player.ang)*7),
			player.x+(sin(player.ang+.40)*player.r),
			player.y+(cos(player.ang+.40)*player.r),
			9}
		}
end

function update_objects()
--main obj loop
	for o in all (obj) do
	
		--sector limits for objects
		if (o.x>sector_max) o.x=sector_min
		if (o.x<sector_min) o.x=sector_max
		if (o.y>sector_max) o.y=sector_min
		if (o.y<sector_min) o.y=sector_max
			
		--clamp max vel
		if (o.dx>e_max_vel) o.dx=e_max_vel
		if (o.dx<-e_max_vel) o.dx=-e_max_vel
		if (o.dy>e_max_vel) o.dy=e_max_vel
		if (o.dy<-e_max_vel) o.dy=-e_max_vel
		
		if o.typ==1 or o.typ==5 then
			o.x+=o.dx
			o.y+=o.dy
		end
		
		--floating ore update
		if o.typ==3 then
			--TRASEVOL_DOG's 'homing missle' code
			--https://www.lexaloffle.com/bbs/?tid=3320
			if tractor==true then
				o.x += 1 * cos(player_loc(o.x,o.y))
				o.y += 1 * sin(player_loc(o.x,o.y))
			else
				o.x+=o.dx
				o.y+=o.dy
			end
		end
		
		--collect ore
		if col(player,o) and o.typ==3 then
			ore+=1
			total_ore+=1
			add(floaty_num,{x=player.x,y=player.y,txt="+1",c=10,t=15})
			del(obj,o)
			ore_timer=90
			sfx(4)
		end
		
		--enemy update
		if o.typ==5 then
		
			o.st-=1
			if (o.st<0) o.st=0
			
			alert=true
		
			if o.h==0 then
				for i=0,flr(rnd(3+3)) do
					make_splode(o.x,o.y,8,30)
				end
				num_kills+=1
				del(obj,o)
				sfx(11)
			end
			
			--enemy should try to orbit the player, not collide with them
			if player_dist(o)>32 then
				o.dx += cos(player_loc(o.x,o.y))*0.05
				o.dy += sin(player_loc(o.x,o.y))*0.05
			else
				o.dx -= cos(player_loc(o.x,o.y))*0.15
				o.dy -= sin(player_loc(o.x,o.y))*0.15
			end
			
			--enemy shoots
			if (o.st<=0) then
				add(ebull, {
				x=o.x,
				y=o.y,
				r=1,
				--"playerPos - playerVelocity * someScaleFactor" - Dovuro from Lazy Devs Discord
				dx=(cos(player_loc(o.x,o.y))-player.dx/8)*3,
				dy=(sin(player_loc(o.x,o.y))-player.dy/8)*3,
				t=30
				})
				o.st=flr(rnd(10)+50)
				sfx(8)
			end
		end
		
		--hit marker timer
		if o.typ==6 then
			if (o.t>0) o.t-=1
			if (o.t==0) del (obj,o)
			o.x+=o.dx
			o.y+=o.dy
		end
		
		--player bounces off roids and enemies
		if player_dead==false then
			if col(player,o) and (o.typ==1 or o.typ==5) then
			colliding=true
				if player.atspeed==true then
					o.dx=player.dx*0.5
					o.dy=player.dy*0.5
					player.dx*=-0.5
					player.dy*=-0.5
				else
					player.dx=o.dx*0.5
					player.dy=o.dy*0.5
					o.dx*=-0.5
					o.dy*=-0.5
				end
				if (shake==0) shake+=0.1
			end
		end
		
		--station docking
		if col(player,o) and o.typ==2 then
			if btnp(4) 
				and player.dx<0.5 
				and player.dy<0.5 
				and player.dx>-0.5
				and player.dy>-0.5 
			then
				mode="station"
				music(2)
				butt_press_timer=15
				reset_tut()
			end
		end
		
		--update for player's bullets
		for b in all (bullets) do
			if col(b,o) and o.typ==5 then
				o.dx=b.dx*0.5
				o.dy=b.dy*0.5
				del(bullets,b)
				o.h-=1
				make_splode(o.x,o.y,8,30)
				sfx(3)
			end
			
			--make smaller roid
			if col(b,o) and o.typ==1 and o.r>1.5 then
				
				sfx(3)
				
				for i=0,flr(rnd(3+3)) do
					make_splode(o.x,o.y,6,30)
				end
				
				add(obj, {
				x=o.x,
				y=o.y,
				dx=roid_drift_x,
				dy=roid_drift_y,
				r=o.r/2,
				n=o.n,
				c=o.c,
				typ=o.typ
				})
				
				if rnd()>0.5 then
					add(obj, {
					x=o.x,
					y=o.y,
					dx=-roid_drift_x,
					dy=-roid_drift_y,
					r=o.r/2,
					n=o.n,
					c=o.c,
					typ=o.typ
					})
				end
				
				del(obj,o)
				del(bullets,b)
			end
			
			--make ore
			if col(b,o) and o.typ==1 and o.r==1.5 then
		
				sfx(3)
		
				add(obj, {
					x=o.x,
					y=o.y,
					dx=roid_drift_x,
					dy=roid_drift_y,
					r=o.r/2,
					n=o.n,
					c=10,
					typ=3
				})
				
				
				if rnd()>0.5 then
					add(obj, {
					x=o.x,
					y=o.y,
					dx=-roid_drift_x,
					dy=-roid_drift_y,
					r=o.r/2,
					n=o.n,
					c=10,
					typ=3
					})
				end
					
				del(obj,o)					
				del(bullets,b)
			end
		end
				
		if (o.typ==1) roids_exist=true
		if (o.typ==3) ore_exist=true
	end
end

function update_bullets()
	--update bullets
	for b in all (bullets) do
		b.x+=b.dx*b.spd
		b.y+=b.dy*b.spd
		b.t-=1
		if (b.t<0) del(bullets,b)
	end
	
	--update enemy bullets
	for e in all (ebull) do
		e.x+=e.dx
		e.y+=e.dy
		e.t-=1
		if (e.t<0) del(ebull,e)
		
		if player_dead==false then
			if col(player,e) and player_flash_timer==0 then
				player.h-=1
				sfx(3)
				add(floaty_num,{x=cam_x+100,y=cam_y+112,txt="-‡",c=8,t=30})
				player.dx=e.dx/2
				player.dy=e.dy/2
				make_splode(e.x,e.y,11,30)
				del(ebull,e)
				if (shake==0) shake+=0.1
				player_flash_timer=60
				if player.h<=0 then
					sfx(11)
					for i=1,7 do
						make_splode(player.x,player.y,11,120)
					end
				end
			end
		end
	end
end

function update_warp()

	draw_player()
	
	player.x+=player.dx
	player.y+=player.dy
	cam_x=player.x-64
	cam_y=player.y-64
	camera(cam_x,cam_y)
	if (player.ang>1) player.ang=0
	if (player.ang<0) player.ang=1
	
	--local warp_ang=rnd(1)
	local warp_ang=0.875
	
	if warp_timer>120 then
		if (player.dx>0) player.dx-=player.th
		if (player.dx<0) player.dx+=player.th
		if (player.dy>0) player.dy-=player.th
		if (player.dy<0) player.dy+=player.th
	end
	
	if (player.ang>warp_ang) player.ang-=player.turn_spd
	if (player.ang<warp_ang) player.ang+=player.turn_spd
	
	if warp_timer<120 then
		player.dx+=player.th
		player.dy+=player.th
	end
	
	if (warp_timer<90) warp_lines=true
	
	if (warp_timer==30) warping=true
	
	if (warp_timer==5) white_flash_timer=10
	
	if warp_timer==0 then
		num_jumps+=1
		player.dx=0
		player.dy=0
		warp_lines=false
		player.x=100
		player.y=100
		sfx(19)
		warping=false
		cleanup()
		make_system()
		mode="game"
	end
end

-->8
--station
function update_station()

	if (player.h==3) item_col[6]=3

	if btnp(2) and retire==false then
		item_sel-=1
		sfx(10)
	end
	
	if btnp(3) and retire==false then
		item_sel+=1
		sfx(10)
	end
	
	if (item_sel<=0) item_sel=1
	if (item_sel>#items) item_sel=#items
	
	if butt_press_timer==0 then
		if item_cost[item_sel]<=ore and btnp(5) and item_col[item_sel]==11 then
			reset_tut()
			if item_sel==1 then
				fuel+=1
				fuel_flash=true
			end
			if item_sel==2 then
				mmap=true
			end
			if item_sel==3 then
				own_tractor=true
			end
			if item_sel==4 then
				player.gun=mlaser
				item_col[5]=11
			end
			if item_sel==5 then
				player.gun=mk2blaster
				item_col[4]=11
			end
			if item_sel==6 then
				player.h=3
				add(floaty_num,{x=cam_x+70,y=cam_y+108,txt="+‡",c=11,t=30})
			end
			if item_sel==7 then
				doretire()
			end
			sfx(9)
			item_tut[item_sel]=true
			ore-=item_cost[item_sel]
			item_col[item_sel]=3
			butt_press_timer=15
			ore_timer=90
		end
		
		if item_cost[item_sel]>ore and btnp(5) then
			ore_timer=90
			sfx(12)
		end

		if btnp(4) then
			player.dx=0
			player.dy=0
			music(-1,2500)
			mode="game"
			item_col[6]=11
		end
	end
	
	if retire==true and fade_timer==0 then
		fade_typ="in"
		fade_timer=60
		butt_press_timer=90
		mode="retire"
	end
end

function draw_station()
	cls()
	
	rectfill(cam_x,cam_y,cam_x+127,cam_y+127,1)
    rect(cam_x,cam_y,cam_x+127,cam_y+127,11)
	
	rectfill(cam_x,cam_y+20,cam_x+127,cam_y+24,0)
    rect(cam_x,cam_y+20,cam_x+127,cam_y+24,11)
	
	rectfill(cam_x,cam_y+102,cam_x+127,cam_y+106,0)
    rect(cam_x,cam_y+102,cam_x+127,cam_y+106,11)
	
	print("welcome to the space station",cam_x+2,cam_y+2,3)
	print("'"..n1.." "..n2.."'",cam_x+20,cam_y+8,11)
	print("what're ya buyin'?",cam_x+2,cam_y+14,3)
	
	if (fuel_flash==false) print("fuel:"..fuel,cam_x+2,cam_y+108,11)
	if (fuel_flash==true) print("fuel:"..fuel,cam_x+2,cam_y+108,flash_white_col)
	if (ore_timer>0) then 
		print("ore:"..ore,cam_x+40,cam_y+108,flash_red_col)
	else 
		print("ore:"..ore,cam_x+40,cam_y+108,11)
	end
	
	draw_health(cam_x+70,cam_y+108)
	
	print(item_desc[item_sel],cam_x+2,cam_y+70,3)
	
	if item_tut[1]==true then
		print("fuel aquired",cam_x+2,cam_y+84,flash_white_col)
		print("in space, hold ƒ",cam_x+2,cam_y+90,11)
		print("to charge warp",cam_x+2,cam_y+96,11)
	end
	
	if item_tut[2]==true then
		print("radar aquired",cam_x+2,cam_y+84,flash_white_col)
		--print("minimap now shows",cam_x+2,cam_y+90,11)
		--print("object type with colour",cam_x+2,cam_y+96,11)
	end
	
	if item_tut[3]==true then
		print("tractor beam aquired",cam_x+2,cam_y+84,flash_white_col)
		print("in space, hold Ž/z",cam_x+2,cam_y+90,11)
		print("to tractor ore",cam_x+2,cam_y+96,11)
	end
	
	if item_tut[4]==true then
		print("mining laser aquired",cam_x+2,cam_y+84,flash_white_col)
		print("in space, hold —/x to fire",cam_x+2,cam_y+90,11)
	end
	
	if item_tut[5]==true then
		print("mk2 blaster aquired",cam_x+2,cam_y+84,flash_white_col)
		print("in space, hold —/x to fire",cam_x+2,cam_y+90,11)
	end
	
	if item_tut[6]==true then
		print("ship repaired",cam_x+2,cam_y+84,flash_white_col)
	end
	
	print("press — to buy",cam_x+2,cam_y+114,3)
	print("press Ž to launch",cam_x+2,cam_y+120,3)
	
	print(">",cam_x+2,cam_y+20+(item_sel*6),11)
	
	for i=1,#items do
		print(items[i],cam_x+6,cam_y+20+(i*6),item_col[i])
	end
	
	for i=1,#item_cost do
		print(item_cost[i],cam_x+100,cam_y+20+(i*6),item_col[i])
	end
end

-->8
--retire, title, help
function doretire()
	fade_timer=60
	retire=true
	cleanup()
	for b in all (blinky_stars) do
		b.x=rnd(128)
		b.y=rnd(128)
	end
end

function update_retire()
	dotitlestars()
	if butt_press_timer==0 and btnp(5) then
		restart_game()
	end
end

function draw_retire()
	cls()
	draw_title_stars()
	
	if (t==0) sx,sy=rnd(128),rnd(128)
	draw_star(sx,sy,ss_ani)
	
	if t==0 then 
		if cx==64 then 
			cx+=1 
			cy-=1 
		else 
			cx-=1 
			cy+=1 
		end 
	end
	
	spr(64,64,64,4,4)
	spr(68,cx,cy,4,4)
	
	oprint8("you retire from mining and",0,0,11,1)
	oprint8("enjoy a peaceful life.",0,6,11,1)
	oprint8("pirates destroyed:"..num_kills,0,12,8,1)
	oprint8("systems visited:"..num_jumps,0,18,12,1)
	oprint8("total ore collected:"..total_ore,0,24,10,1)
	oprint8("thanks for playing!",0,30,flash_white_col,1)
	if butt_press_timer==0 then oprint8("press — to start a new career",4,122,flash_white_col,1) end
end

function update_title()
	dotitlestars()

	if start_timer==0 then
		if btnp(2) then
			menu_sel-=1
		end
		
		if btnp(3) then
			menu_sel+=1
		end
	end
	
	if (menu_sel<=0) menu_sel=1
	if (menu_sel>2) menu_sel=2

	if (btnp(4) or btnp(5)) and butt_press_timer==0 and start_timer==0 then
		butt_press_timer=15
		if menu_sel==1 then
			music(-1,2500)
			sfx(9)
			start_timer=59
			fade_timer=60
			start=true
		end
		if (menu_sel==2) mode="help"
	end
	if start_timer==0 and start==true then 
		pal()
		mode="game"
		make_system()
	end
end


function draw_title_stars()
	for s in all (title_stars) do
		pset(s.x,s.y,s.c)
	end
	
	for b in all (blinky_stars) do
		draw_star(b.x,b.y,b.ani)
	end
end

function draw_title()
	cls()
	draw_title_stars()
	
	if (t==0) sx,sy=rnd(128),rnd(128)
	draw_star(sx,sy,ss_ani)
	
	if menu_sel==1 and start_timer==0 then
		ngon(26,102,3,3,11)
		ngon(100,102,3,3,11)
	end
	
	if menu_sel==1 and start_timer>0 then
		ngon(26,102,3,3,flash_white_col)
		ngon(100,102,3,3,flash_white_col)
	end
	
	if menu_sel==2 then
		ngon(26,110,3,3,11)
		ngon(100,110,3,3,11)
	end
	
	ngon(64,64,10,3,11)
	
	rectfill(34,20,96,32,1)
	rect(34,20,96,32,11)
	print("eLITE vELOCITY",38,24,11)
	oprint8("start new career",32,100,11,0)
	oprint8("how to play",42,108,11,0)
end

function update_help()
	if (btnp(4) or btnp(5)) and butt_press_timer==0 then
		butt_press_timer=15
		mode="title"
	end
end

function draw_help()
	cls()	
	
	ngon(16,16,12,6,6)
	oprint8("asteroid",0,30,11,1)
	
	ngon(46,16,1.5,6,10)
	oprint8("ore",40,30,11,1)
	
	ngon(70,16,5,5,8)
	line(70,16,70,19,8)
	oprint8("pirate",60,30,11,1)
	
	ngon(106,16,16,3,12)
	ngon(106,16,4,4,12)
	oprint8("station",96,30,11,1)
	
	rectfill(0,38,127,127,1)
    rect(0,38,127,127,11)
	
	print("”: thrust",2,40,11)
	print("‹: turn left",2,46,11)
	print("‘: turn right",2,52,11)
	print("ƒ: charge warp (requires fuel)",2,58,11)
	print("—/x: shoot",2,64,11)
	print("Ž/z: tractor beam (if owned)",2,70,11)
	print("Ž/z: dock at station",2,76,11)
	
	print("shoot asteroids to find ore.",2,84,11)
	print("dock at stations to buy fuel",2,90,11)
	print("and upgrades using ore.",2,96,11)
	print("use fuel to warp to new systems.",2,102,11)
	print("watch out for pirates!",2,108,11)
	print("don't run out of ore and fuel!",2,114,11)
	print("— or Ž: return to title",2,120,3)
end

function draw_health(ox,oy)
	for i=1,3 do
		oprint8("‡",ox+(i*6),oy,0,1)
	end
	for i=1,player.h do
		oprint8("‡",ox+(i*6),oy,player_h_col,1)
	end
end

--Kyrstman's sprite ani code from Porklike
function draw_star(ox,oy,n)
	star = n[flr((t/2)%#n+1)]
	if n==ss_ani then
		spr(star,ox,oy,2,2)
	else
		spr(star,ox,oy)
	end
end

-->8
--misc
function dotitlestars()
	camera(0,0)
	for s in all (title_stars) do
		if s.c==1 then 
			s.x+=0.005
			s.y+=0.005
		end
		if s.c==5 then 
			s.x+=0.025
			s.y+=0.025
		end
		if s.c==6 then 
			s.x+=0.05
			s.y+=0.05
		end
		if s.c==7 then 
			s.x+=0.1
			s.y+=0.1
		end
		if (s.x>128) s.x-=128
		if (s.y>128) s.y-=128
	end
	
	for b in all (blinky_stars) do
		b.x+=0.005
		b.y+=0.005
		if (b.x>128) b.x-=128
		if (b.y>128) b.y-=128
	end
end

function cleanup()
	for o in all (obj) do
		del(obj,o)
	end
end

function reset_tut()
	for t=1,#item_tut do
		item_tut[t]=false
	end
	ore_flash=false
	fuel_flash=false
end

function restart_game()
	cleanup()
	stars=nil
	title_stars=nil
	blinky_stars=nil
	_init()
end

function player_loc(ox,oy)
	return atan2(player.x-ox,player.y-oy)
end

--ngon function from pico-8 wiki, edited to add lines to table so I can rotate them later
--https://pico-8.fandom.com/wiki/Line
function ngon(x,y,r,n,color)
	line(color)
	for i=0,n do
		ln={}
		local angle = i/n
		ln.x1=x+r*cos(angle)
		ln.y1=y+r*sin(angle)
		ln.x2=x
		ln.y2=y
		add(lins,ln)
	end
	
	for ln in all(lins) do
		x1,y1=rotate(ln.x1,ln.y1,ln.x2,ln.y2,rotspd)
		line(x1,y1)
		del(lins,ln)
	end
end

--2darray's line rotation tool
--https://www.lexaloffle.com/bbs/?pid=40230
 function rotate(x,y,cx,cy,angle)
     local sina=sin(angle)
     local cosa=cos(angle)
    
     x-=cx
     y-=cy
	 
     local rotx=cosa*x-sina*y
     local roty=sina*x+cosa*y
     rotx+=cx
     roty+=cy
    
     return rotx,roty
 end
 
 function col(a,b)
	if 
		a.x + a.r >= b.x - b.r and
		a.y + a.r >= b.y - b.r and
		a.x - a.r <= b.x + b.r and
		a.y - a.r <= b.y + b.r 
	then
		return true
	end
 end
 
 --from JTE on the pico-8 forums
 --https://www.lexaloffle.com/bbs/?tid=2694
function wait(a) for i = 1,a do flip() end end

--Kyrstman's juicy stuff
--https://www.youtube.com/watch?v=GhIpA03VD-c
function doshake()
	local shakex=16-rnd(32)
	local shakey=16-rnd(32)
	
	shakex=shakex*shake
	shakey=shakey*shake
	camera(cam_x+shakex,cam_y+shakey)
	
	shake=shake*0.95
	
	if shake<0.05 then
		shake=0
	end
	
	if shake==0 then
		colliding=false
	end
end

--print with drop shadow by Kyrstman
function oprint8(_t,_x,_y,_c,_c2)
	dirx={-1,1,0,0,1,1,-1,-1}
	diry={0,0,-1,1,-1,1,1,-1}
	for i=1,8 do
		print(_t,_x+dirx[i],_y+diry[i],_c2)
	end
	print(_t,_x,_y,_c)
end

--http://gamedev.docrobs.co.uk/orbital-motion-in-pico-8
function player_dist(e)
	return sqrt((player.x-e.x)^2+(player.y-e.y)^2)
end

function dofade()
	if fade_typ=="out" then
		if (fnum==15) fnum=0
		fade(fnum)
		fnum+=1
	end
	
	if fade_typ=="in" then
		if (fnum==0) fnum=15
		fade(fnum)
		fnum-=1
	end
end

--http://kometbomb.net/pico8/fadegen.html
local fadetable={
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
 {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
 {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
 {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
 {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
 {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
 {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
 {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
 {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
 {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
 {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
 {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
 {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
 {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
 {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,0)
  else
   pal(c,fadetable[c+1][flr(i+1)])
  end
 end
end

-- --http://gamedev.docrobs.co.uk/collisions-between-objects-using-line-intersection
-- function line_intersect(ax1,ay1,ax2,ay2,bx1,by1,bx2,by2)
  -- --output
  -- out={}
  -- out.cross=false
  -- out.x=0
  -- out.y=0
  
  -- --linear equation
  -- local l1={}
  -- local l2={}
  
  -- l1.m=(ay2-ay1)/(ax2-ax1)
  -- l1.c=-(l1.m*ax1)+ay1
  -- l2.m=(by2-by1)/(bx2-bx1)
  -- l2.c=-(l2.m*bx1)+by1
  
  -- if l1.m==l2.m then
    -- --parallel
    -- return out
  -- else
    -- --coordinates of cross
    -- local tm = l1.m-l2.m
    -- local tc = l2.c-l1.c
    
    -- --x intercept
    -- local ix = tc/tm
    -- out.x=ix
    
    -- --y intercept
    -- local iy = l1.m*ix+l1.c
    
    
    -- --finally, check the range
    -- local amax_x=max(ax1,ax2)
    -- local amin_x=min(ax1,ax2)
    -- local amax_y=max(ay1,ay2)
    -- local amin_y=min(ay1,ay2)
    -- local bmax_x=max(bx1,bx2)
    -- local bmin_x=min(bx1,bx2)
    -- local bmax_y=max(by1,by2)
    -- local bmin_y=min(by1,by2)
    
    -- if (ix>amax_x or 
      -- ix<amin_x or
      -- iy>amax_y or 
      -- iy<amin_y) or
      -- (ix>bmax_x or 
      -- ix<bmin_x or
      -- iy>bmax_y or 
      -- iy<bmin_y) then
    -- out.cross=false
  -- else
    -- out.x=ix
    -- out.y=iy
    -- out.cross=true 
  -- end
  -- end  
  -- return out  
-- end
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
00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000010000000c000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001000000010000000c000000c7c000000c0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000
000111000001c100001c7c1001c777c1001c7c100001c10000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001000000010000000c000000c7c000000c0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000010000000c000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001000000010000000c00000001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000111000001c100001c7c100101c101100111001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001000000010000000c00000001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000020000000e000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002000000020000000e000000e7e000000e0000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000
000222000002e200002e7e2002e777e2002e7e200002e20000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002000000020000000e000000e7e000000e0000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000020000000e000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000011111111111100000000000000000000000000000000000000000000000000002222222222222222000000000000000000eeeeeee00eee0e100000
00000001111dcccccccccccc10000000000000000000000000007777770000000000000112222222222222222220000000000000de0ee1e111eeee1eee100000
000000333bbccccccccccccccc000000000000000000000000007111177000000000001d2222222222eeeeeeeee20000000000000e0110eeee11110111000000
00000333bbbbccccccccccccccc0000000000000000000000000770001770000000001d2222222222eeeeeeeeeee20000000002ee1eeeee10700777700771000
0003333bbbbbccccccccccccccccc0000000000000000000000017700017000000001d2222222222eeeeeeeeeeeee200000000e11ee11e100700711700710000
00033bbbbbbcccccccccccccccccc000000000000000000000000110000700000001d2222222222eeeeeeeeeeeeeee20000dde10ee100ee00777710777710000
00333bcbbbcccccccccccccccccccc00000000000000000000000000007700000011d222222222eeeeeeeeeeeeeeeee000dd110ee10e01700117100177100000
03333bcccbccccccccccccccccccccc000000000000007777700007777110000011dd222222222eeeeeeeeeeeeeeeee000d10eee100e0e700001077711007710
01133bcccccccccccccccccbbbbbccc000000000007777777777777111000000011d2222222222eeeeeeeeeeeeeeeee200d10e10000eee107777171700777100
0333bbcccccccccccccccccbbbbbcccc0000000007711771111111100000000001dd2222222222eeeeeeeeeeeeeeeee200210e100001e1077177171771711000
11d3bccccccccccccccccccbbbbbbccc0000000007100710770000000000000011dd2222222222eeeeeeeeeeeeeeeee20d210ee1eeeeee771071171177710000
11ddcccccbcccccccccccccbbbbbbccc0000000007100717171000000000000011dd2222222222eeeeeeeeeeeeeeeee2011001e1e1111e710077771011100771
11ddccccbbcccccccccccccbbbbbbccc0000000077100711071000000000000011dd2222222222eeeeeeeeeeeeeeeee20022e1e1e10001100011117771007710
11ddcccbbbcccccccbbbbbccbbbbbccc0000000071000770071000000000000011dd2222222222eeeeeeeeeeeeeeeee20d21eee1e10eee777100007177777100
11ddccbbbbccccccbbbbbbbcbbbbbbcc0700000771000177071000000000000011dd2222222222eeeeeeeeeeeeeeeee2dd101110e1ee11117710077111771000
11ddcccbbbccccccbbbbbbbbbbbbbbcc0177777710000017771000000000000011dd22222222222eeeeeeeeeeeeeee22d100eeeee1e100001171071000110000
11ddcccbbbbcccccbbbbbbbbbbbbbbcc0011111100000001111000000000000011dd222222222222eeeeeeeeeeeee2220002100ee1e10ee10077770000777ee1
11ddcccbbbbbcccccbbbbbbbbbbbbbcc0000000000000000000000000000000011dd2222222222222eeeeeeeeeee22220002100110e1eeeee100000000711110
11ddcccccbbbcccccbbbbbbbbbbbbccc0000000000000000000000000000000011dd22222222222222eeeeeeeee222220002100000e1e111e100000000710000
11ddccccccbbccccccccccbbbccccccc0000000000000000000000000000000011ddd22222222222222222222222222d0002210eeee1e1e1e1eeee100ee10000
11ddcccccccbcccccccccccccccccccc0000000000000007777000000000000011ddd22222222222222222222222222d000121ee1110e1e1e1e11eeeee100ee1
111ddcccccccccccccccccccccccccc100000000000000071177710000000000111dd222222222222222222222222220000221e10000eee1e1e1011111000e10
01133bbcccccccccccccccccccccccc000000000000000071011710000000000011ddd222222222222222222222222d000d110e100001110e1e100000000e100
013333bccccccccccccccccccccccc10000000000000000771007100000000000111ddd2222222222222222222222d00001000210eee1000eee10eeeee1ee100
0133d3bccccccbbbbbcccccccccccd10000000770000000110077107777700000111dddd22222222222222222222dd0000000221ee1eeeeee100ee100eee1000
00133ddccccccbbccbccccccccccc1000000007777000000077710771117710000111dddd222222222222222222dd0000000d212210111111000e10001110000
000131dddccccccccccccccccccd100000000071170000077777771100017100000111dddd2222222222222222dd00000000110210000000000ee10000210000
0000111dddcbbbbbbbbbbcccccd10000000000770100000711111100000771000000111ddddd222222222222ddd0000000000dd20000000000ee10ee22210000
000001111dbbbbbbbbbbbbccd110000000000017770007710000000000771000000001111dddddddddddddddd100000000000111022222202221222111100000
0000001133333333333333d1110000000000000117777710000000000011000000000011111dddddddddddd11000000000000000dd1111222112211000000000
00000001333333333333311110000000000000000111110000000000000000000000000111111111111111110000000000000000d100001110dd100000000000
000000000033333333331100000000000000000000000000000000000000000000000000001111111111100000000000000000001000000000d1000000000000
00000000000077777770077707000000000000000000000000000000000000000000000000111111111111000000000000000000000000000000000000000000
000000007707707000777707770000000000000000006666666600000000000000000001111d3333333333331000000000000000000000000000000000000000
00000000070000777700000000000000000000000666dd55ddd6666000000000000000222ee33333333333333300000000000000000000000000000000000000
0000007770777770070077770077000000000000655dddd5d55dddd60000000000000222eeee3333333333333330000000000000000000000000000000000000
0000007007700700070070070070000000000066d5d555555555d5d6660000000002222eeeee3333333333333333300000000000000000000000000000000000
00077700770007700777700777700000000006d5555555661165556ddd60000000022eeeeee33333333333333333300000000000000000000000000000000000
00770007700700700007000077000000000065d55555551dddd5556d5d66000000222e3eee333333333333333333330000000000000000000000000000000000
0070077700070770000007770000770000005d55666655dd55d555555dd6000002222e333e333333333333333333333000000000000000000000000000000000
007007000007770077770707007770000006d55511116555666155666d55600001122e33333333333333333eeeee333000000000000000000000000000000000
00700700000070077077070770700000006d1665d1116555111655116d5666000222ee33333333333333333eeeee333300000000000000000000000000000000
0770077077777777007007007770000000d51116dddd555111165511655dd60011d2e333333333333333333eeeeee33300000000000000000000000000000000
000000707000077000777700000007700055d1d555555555d111651165555d0011dd33333e3333333333333eeeeee33300000000000000000000000000000000
00777070700000000000007770007700065dd155111111555d1165dd5556666011dd3333ee3333333333333eeeeee33300000000000000000000000000000000
077077707007777770000070777770000d55d5115151555155d55555555ddd6011dd333eee3333333eeeee33eeeee33300000000000000000000000000000000
77000000707700007700077000770000055551155551111115555555516555d011dd33eeee333333eeeeeee3eeeeee3300000000000000000000000000000000
700077777070000000700700000000000555111515111111115555666116666011dd333eee333333eeeeeeeeeeeeee3300000000000000000000000000000000
000700077070077000777700007777700551155511111151111555111116556011dd333eeee33333eeeeeeeeeeeeee3300000000000000000000000000000000
000700000070777770000000007000000555111111511151511555d16d16656011dd333eeeee33333eeeeeeeeeeeee3300000000000000000000000000000000
0007000000707000700000000070000005155111155111555115551d16d5666011dd33333eee33333eeeeeeeeeeee33300000000000000000000000000000000
0007700777707070707777000770000005155511155511115115551165556d6011dd333333ee3333333333eee333333300000000000000000000000000000000
000070770000707070700777770007700511551111155111111555d116555d0011dd3333333e3333333333333333333300000000000000000000000000000000
0007707000007770707000000000070000155511111551111115551165565600111dd33333333333333333333333333100000000000000000000000000000000
007000700000000070700000000070000011111111111111551155dd6556660001122ee333333333333333333333333000000000000000000000000000000000
000000700777000077700777770770000011111111111111151155555555d000012222e333333333333333333333331000000000000000000000000000000000
00000770770777777000770007770000001111111155511155115611655d00000122d2e333333eeeee33333333333d1000000000000000000000000000000000
0000770770000000000070000000000000011111111155515115511d5556000000122dd333333ee33e3333333333310000000000000000000000000000000000
000000070000000000077000007000000001111111115551111551d566d00000000121ddd333333333333333333d100000000000000000000000000000000000
00000777000000000077007777700000000011111111111111555d55550000000000111ddd3eeeeeeeeee33333d1000000000000000000000000000000000000
00000000077777707770777000000000000001111111155555555566d0000000000001111deeeeeeeeeeee33d110000000000000000000000000000000000000
000000007700007770077000000000000000001111111551555555d0000000000000001122222222222222d11100000000000000000000000000000000000000
00000000700000000077000000000000000000001111115555566d00000000000000000122222222222221111000000000000000000000000000000000000000
00000000000000000070000000000000000000000000ddddddd00000000000000000000000222222222211000000000000000000000000000000000000000000
00000000000000010000000000000001000000000000000100000000000000010000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000010000000000000001000000000000000100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000100000000000000010000000000000001000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c000000000000000100000000000000010000000000000001000000000000000000000000000000000000000000000000000
000000000000000000000000000c0000000000000001000000000000000100000000000000010000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000010000000000000001000000000000000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000100000000000000010000000000000001000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000c000000000000000100000000000000010000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000c000000000000000c000000000000000100000000000000010000000000000000000000000000000000000000
00000000000000000000000000000000000000c000000000000000c0000000000000001000000000000000100000000000000000000000000000000000000000
00000000000000000000000000000000000007000000000000000c00000000000000010000000000000001000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000c000000000000000100000000000000010000000000000001000000000000000000000000000
000000000000000000000000000000000000000000000000000c000000000000000c000000000000000100000000000000010000000000000000000000000000
00000000000000000000000000000000000000000000000000c000000000000000c000000000000000c000000000000000100000000000000000000000000000
00000000000000000000000000000000000000000000000007000000000000000c000000000000000c0000000000000001000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000007000000000000000c000000000000000c0000000000000001000000000000000
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
0000000000000000080101010101010101010101010101010101010101010101010101010101010101010101010101070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200000d73018730187301d73000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000000061010700117000d7000f7001c7001c700107001c70010700107000d7000f70011700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000f7200e7000f7000e7000d7000a7000b7000d700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00020000046300461004610056200b6200b6200a50007500055000a6000a600096000960009500095000950008500085000050000500005000050000500005000050000500005000050000500005000050000500
000400001d3401e3401d340000001a300103000430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0018000003d4003d4003d4003d4004d4004d4004d4004d4004d4004d4004d4004d4005d4005d4006d4007d4009d400bd400dd400fd4012d4015d4017d4019d401bd401cd401dd401ed401fd401ed4015d5023d50
001400000631006300063000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00050000085300b5300c5300f530155301c5301e5300b5300c5300e53011530155301b5301e5301a50000500085300b5300c5300f530155301c5301e5300b5300c5300e53011530155301b5301e5300050008500
000200000d13018130181301d13000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00040000135500e55014550235502e550285000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000a00000b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000b6500b6500b6500a65007650036500065000650146000d60006600046000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00060000000000f0500f0500705007050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000175001750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000001000010000200002000010000100002000020000100001000020000200001000010000200002000010000100002000020000100001000020000200001000010000200002000010000100002000020
001000000171001710017100171001710017100171001710017100171001710017100171001710017100171001710017100171001710017100171001710017100171001710017100171001710017100171001710
001000003d5753d5653d5553d5453d5353d5253d5153d5153d5053d5153d5053d5153d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050d5050e5050f505
001000003d0753d0653d0553d0453d0353d0253d0153d0153d0053d0153d0053d0150d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050d0050e0050f005
001000000011000110001200012000110001100012000120001100011000120001200011000110001200012000110001100012000120001100011000120001200011000110001200012000110001100012000120
000500003f9503f9503d9503c9503b9503895035950339502e95029950239501b950159500b950009500095000950179001790017900009000090000900009000090000900009000090000900009000090000900
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
00 0f 10 43 44
02 0f 11 43 44
01 0e 42 43 44
02 12 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
