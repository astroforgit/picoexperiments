pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--froggi knight
	debx=1000
	deby=200
	debug=false
function _init()
	player={
		x=8,y=220,
		w=16,h=16,
		dx=0,dy=0,
		max_dx=2,
		max_dy=3,
		jump=4,
		first_sp=true,
		sp=64,
		anim_time=.15,
		facing=false,--right=false
		atk_state=0,
		a_length=12,
		speed=1.333,
		delta_t=0,
		moving=false,
		jumping=false,
		falling=false,
		upgrading=false,
		max_health=3,
		health=3,
		sword_box={
			x=8,y=0,s=12
		},
		vul=true,
		flash=false,
		hurt=false,
		move_lock=false,
		
		dub_jump=false,
		jumps=1,
		bubble=false,
		
		m_move=0,
		m_sp=-1,
	}
	cors={
		p_inv=nil,
		sword=nil,
		death=nil,
		upgrade=nil,
		door=nil,
		end_sc=nil,
		start=nil,
		intro=nil
	}
	if debug then
		player.bubble=true
		player.dub_jump=true
		player.x=debx
		player.y=deby
		game_state="game"
	end	
	title_sc={
	0x2c23,0x2323,0x2344,
	0x8c06,0x0003,0x0397,
	0x5d55,0x9a9a,0x9a9a,
	0xdddd,0xdddd,0xdddd,
	0x4483,0x4234,0x44dd,
	0x0600,0x0038,0x78cd,
	0x5555,0x59a5,0x59ad}
	the_end={
	0x4d44,0x2c2c,0x8343,
	0x8c87,0x8c8c,0x0000,
	0x9c55,0x9c9c,0x555a
	}
	gravity=.4
	friction=.5	
	max_dy=3
	cur_sc=0
	palt(1, true)
	palt(0,false)

	signs={}
	swim={
		x=552,y=200,
		msg={
			"frog fact:",
			"frogs can hold",
			"their breath for",
			"4 to 6 hours!"
		}
	}
	jump={
		x=935,y=96,
		msg={
			"frog fact:",
			"a frog can",
			"jump over 44",
			"times its body",
			"length!"
		}
	}	
	
	add(signs,swim)
	add(signs,jump)
	
	add_enemies()
	--actor key: ypos/16,xpos16,
	--type,screen
	actor_list={0x08420,0x6a34,0xb908,
	0xa909,0x7b19,0x7b18,0x821a,0xff5a,
	0xaa60,0x6760,0x9061,0x6c46,
	0x8145,0x4845,0xa146,0xfb5b,
	0x7b1c,0xa90d,0x4e1d,0x4e0d
	}
	if(not debug)cors.intro=cocreate(intro)
end

function intro()
	game_state="intro"
	music(32)
	player.move_lock=true
	fade_pal(true,.2)
	wait(3)
	fade_pal(false,.2)
	game_state="title"
	wait(.5)
	fade_pal(true,.2)
	player.move_lock=false
end

function fade_pal(fade_in,s)
	if fade_in then
		shift_pal(1,15,0)
		wait(s)
		shift_pal(5,15,5)
		wait(s)
		shift_pal(1,15,-1)
		return
	else
		shift_pal(5,15,5)
		wait(s)
		shift_pal(1,15,0)
		return
	end
end

function title_screen()
	game_state="title"
	active_actors={}
	cur_sc=0
	music(32)
end

function start_game()
	player.move_lock=true
	cur_sc=8
	player.x=8
	player.y=220
	door_open=false
	end_cutscene=false
	end_close=false	
	player.bubble=false
	player.dub_jump=false
	player.jumps=1
	sfx(60)
	fade_pal(false,.2)
	game_state="game"
	wait(1.2)
	music(-1)
	fade_pal(true,.2)
	load_actors(0)
	load_actors(1)
	music(0)
	player.move_lock=false
end

function add_enemies()
	--enemy info
	scorpion={
		w=16,h=16,
		sp_list={98,100},
		speed=1,
		facing=0,
		anim_length=.15,
		name="scorpion"
	}
	spider={
		w=16,h=16,
		sp_list={96,97},
		speed=.8,
		facing=3,
		anim_length=.35,
		name="spider",
		
		wait_time=-1,
		start_y=-1
	}
	water_upgrade={
		w=8,h=8,
		speed=.03,
		sp_list={5},
		anim_length=0,
		name="upgrade",
		bob=4
	}
	jump_upgrade={
		w=8,h=8,
		speed=.03,
		sp_list={21},
		anim_length=0,
		name="upgrade",
		bob=4
	}
	bird={
		w=16,h=16,
		sp_list={108,110},
		speed=.15,
		facing=1,
		anim_length=.15,
		name="bird"
	}
	fish={
		w=16,h=16,
		sp_list={104,106},
		speed=1.4,
		facing=0,
		anim_length=100,
		name="fish",
		
		jumping,
		start_x,
		jump_wait
	}	
	jelly={
		w=16,h=16,
		sp_list={128,130},
		speed=.2,
		facing=0,
		anim_length=.3,
		name="jelly",
		bob=8
	}
	health={
		x=-1,y=-1,
		w=8,h=8,
		sp_list={16},
		facing=0,
		anim_length=0,
		name="health",
		active=false		
	}
	bubble={
		x=-1,y=-1,
		w=8,h=8,
		sp_list={5},
		facing=0,
		anim_length=0,
		name="bubble",
		active=false,
		speed=4
	}
	
	add(actors,scorpion)
	add(actors,spider)
	add(actors,water_upgrade)
	add(actors,jump_upgrade)
	add(actors,bird)
	add(actors,fish)
	add(actors,jelly)
	
	health_drop=new_actor(0,0,health,0)
	bub_shot=new_actor(0,0,bubble,0)
end

function get_band(data)
	return band(0x000f,data)
end

function coresume_check(cor)
	if cor and costatus(cor)!= 'dead' then
		coresume(cor)
		return true
	else
		cor=nil
		return false
	end
end

function player_attack()
	local hold_vul=player.vul
	local atk_timer=time()
	player.vul=false
	player.atk_state=1
	local x_off
	if(player.facing) then x_off=-8
	else x_off=8
	end
	player.x+=x_off
	if(player.bubble)spawn_bubble()
	while(time()-atk_timer<.1)yield()
	player.atk_state=2
	player.x-=x_off
	while(time()-atk_timer<.25)yield()
	player.atk_state=0
	player.vul=hold_vul
end

function player_hurt()
	sfx(61,1)
	player.health-=1
	cors.p_inv=cocreate(player_inv)
end

function player_inv()
	player.vul=false
	player.hurt=true
	local inv_time=time()
	local flash=time()
	while(time()-inv_time<2.5) do
		if(time()-inv_time>.5) player.hurt=false
		if time()-flash>.1 then
			flash=time()
			player.flash = not player.flash
		end
		yield()
	end
	player.flash=false
	player.vul=true
end

function update_screen()
	local lower = cur_sc>7
	local px = flr(player.x/128)
	local py = 8*flr(player.y/128)
	local cs = px+py
	local load_offset=0
	if cur_sc != cs then
		if lower and cs>7 
		or (not lower) and cs<7 then
			if cur_sc<cs then
				load_offset=1
			else
				load_offset=-1
			end
		end		
		cur_sc=cs
		load_actors(load_offset)
	end
end

function player_die()
	player.move_lock=true
	 wait(.3)
	shift_pal(1,4,0)
	shift_pal(5,15,5)
	 wait(.2)
	player.x=8
	player.y=210
	player.facing=false
	player.health=player.max_health
	active_actors={}
	load_actors(0)
	load_actors(1)
	shift_pal(5,15,0)
	wait(.4)
	shift_pal(5,15,5)
	wait(.2)
	shift_pal(1,15,-1)
	player.move_lock=false
end

function shift_pal(a,b,col)
	for i=a,b do
		if col==-1 then
			pal(i,i,1)
		else
			pal(i,col,1)
		end
	end
end
-->8
--update and draw

function _update()
coresume_check(cors.start)
coresume_check(cors.intro)
if game_state=="intro" then
	camera(0,0)
	rect(0,0,127,127,0)
elseif game_state=="title" then
	camera(0,0)
	rect(0,0,127,127,0)	
	if(not player.move_lock and btnp(Ž)) cors.start=cocreate(start_game)

elseif game_state=="game" then
	update_player()
	update_actors()
	update_screen()
	
	coresume_check(cors.p_inv)
	coresume_check(cors.sword)
	coresume_check(cors.death)
	coresume_check(cors.upgrade)
	
	coresume_check(cors.end_sc)	
	
	if player.atk_state==0 and not end_cutscene then
		local c_min=0 local c_max=895
		if cur_sc<4 then c_max=383
		elseif cur_sc<8 then c_min=512
		end
		camera(mid(c_min,player.x-64,c_max),128*flr(cur_sc/8))
	elseif end_cutscene then
		camera(0,128)
	end
	coresume_check(cors.door)
end
end

function _draw()
	cls()
if game_state=="intro" then
	spr(195,58,58,2,2)
	print("a game by grant ross",28,78,7)
elseif game_state=="title" then
	camera(0,0)
	rect(0,0,127,127,0)
	draw_big_text(title_sc,24,24)
elseif game_state=="game" then
	local cx = peek2(0x5f28)
	rectfill(512,0,1023,128,12)
	rectfill(0,242,511,256,1)
	rectfill(0,0,511,128,1)
	if end_cutscene then	
		rectfill(0,128,128,256,1)
		map(112,32,0,128,128,128)
		
	else		
		map()
	end
	draw_signs()
	draw_player()
	draw_actors()
	if(not end_cutscene) draw_ui()
	if(player.upgrading) draw_upg()
	if not end_cutscene
	and door_open
	and player.x>976
	and player.y>195 then
		cors.end_sc=cocreate(end_scene)
	end
	if(end_close)end_scr_wipe()
	--if(active_actors[2]!=nil)print(active_actors[2].x,player.x,player.y-5,7)
	--print(bub_shot.x,player.x,player.y-10,7)
	--print(player.vul,player.x,player.y-5,7)
end
end

function update_player()
	
	local swimming=cur_sc<4 or player.y>232
	player.dy+=gravity
	if(swimming)player.dy-=.2
	player.moving=false
	if player.atk_state==0 and not player.hurt then	
		if player.move_lock and player.m_move!=0 then
			player.dx=player.speed*player.m_move
			player.moving=player.m_move!=0
			player.facing=player.m_move==-1
		elseif not player.move_lock then
		for i=-1,1,2 do
		--l=0,r=1
			local b=mid(0,i,1)
			if btn(b) then
				player.moving=true
				if not collide_check(player,b,1) then
					player.dx=player.speed*i
				else player.dx=0
				end			
				player.facing=i==-1
			end
		end end
	end
	player.dy=min(player.max_dy, player.dy)
		
	if not player.moving then
		player.first_sp=true
		player.dx*=friction
		player.delta_t = time()
	end
	if player.dy>0 and collide_check(player,3,0) then
		player.dy=0
		if(player.dub_jump) then
			player.jumps=2
		else
			player.jumps=1
		end
		player.y-=(player.y+16)%8
	end
	if player.dy<0 and collide_check(player,2,1) then
		player.dy=0
		player.y=flr(player.y)+1
	end
	if btnp(—) and not player.move_lock then
		if swimming then
			player.dy-=2.8
			player.dy=max(player.dy,-4)
			sfx(56,1)
		elseif player.jumps>0 then
			player.jumps-=1
			player.dy=-player.jump		
			player.landed=false
			sfx(63,1)
		end
	end
	if not player.move_lock and btnp(Ž) and player.atk_state==0 then
		cors.sword=cocreate(player_attack)
		sfx(62,1)
	end
	
	if(player.upgrading)player.dx=0	
	player.x=mid(1,player.x+player.dx,1007)
	player.y+=player.dy
	
	
	if player.y>256 then
		if (player.x<512) then
			player.y=0
		else
			player.y=120
		end
	end
	if(player.y<0) player.y=256
	--check for enemy hurt
	if player.vul then
		if spr_col_check(4)then
			player_hurt()
		else
			for i=0,3 do			
				if collide_check(player,i,2)then
					player_hurt()
					i=4
				end			
			end
		end
		if player.health<=0 then
			cors.death=cocreate(player_die)
		end
	end
end

function draw_player()
	if(player.flash) return

	local sp = player.sp
	local x = player.x
	if player.atk_state==1 then
		sp+=8
	elseif player.atk_state==2 then
	 	sp+=10
	else 
		if(player.dy<0) then sp+=4
		elseif(player.dy>0) then sp+=6
		else
			if time()-player.delta_t>player.anim_time then	
				player.first_sp = not player.first_sp
				player.delta_t=time()
			end
			if (not player.first_sp) sp+=2
		end		
	end
	if(player.hurt) sp=76
	if(player.upgrading)sp=78
	if(player.m_sp!=-1)player.sp=player.m_sp
	spr(sp,x,player.y, 2,2,player.facing)
end

function draw_ui()
	cx = peek2(0x5f28)
	cy = peek2(0x5f2a)
	rectfill(cx,cy,cx+46,cy+13,19)
	rect(cx-1,cy-1,cx+47,cy+14,0)
	--print("health:",cx+2,cy+2,0)
	--print("health:",cx+1,cy+1,7)
	for i=1,player.max_health do
		local sp=2
		local x=cx+i*15-15
		if(i>player.health)sp+=1
		spr(sp,x,cy-2,1,2)
		spr(sp,x+8,cy-2,1,2,true)
	end
end

function draw_signs()
	for i=1,#signs do
		local s=signs[i]
		if mid(s.x-12,player.x+8,s.x+12)==player.x+8 then
			local msg=s.msg
			rectfill(s.x-34,s.y-#msg*8-2,s.x+32,s.y-2,15)
			rect(s.x-35,s.y-#msg*8-3,s.x+33,s.y-1,4)
			for i=#msg,1,-1 do
				local msg_y=s.y-i*8				
				print(msg[#msg-i+1],s.x-32,msg_y,0)
			end
		end
	end
end

upg_x=0
upg_y=0
function draw_upg()
	if upg_x<28then
		upg_x+=2
		upg_y+=.7
	end
	local y_off=player.y-15
	rectfill(player.x-upg_x+8,y_off-upg_y,player.x+upg_x+8,y_off+upg_y,3)
	rect(player.x-upg_x+8,y_off-upg_y,player.x+upg_x+8,y_off+upg_y,0)
	if upg_x>=25 then
		print("you found the",player.x-17,y_off-6,7)
		local item_str
		if cur_sc<4 then
			item_str="bubble shot!"
		else
			item_str="double jump!"
		end
		print(item_str,player.x-15,y_off+1,7)
	end
end

function draw_big_text(data,tx,ty)
	for i=1,21 do
		tx+=24
		for k=0,3 do
			tx-=8
			local tile=164+get_band(title_sc[i]>>>(k*4))
			if (tile>170)tile+=9
			spr(tile,tx,ty)		
		end
		tx+=40
		if i!=1 and i%3==0 then
			ty+=8		
			tx=24
			if(i>9)tx+=4
		end
		print("lost in the forest",28,82,11)
		print("press z to start",32,98,7)
	end	
end

function draw_the_end()
	local tx=20
	local ty=160
	for i=1,9 do
		tx+=24
		for k=0,3 do
			tx-=8
			local tile=164+get_band(the_end[i]>>>(k*4))
			if (tile>170)tile+=9
			if((i+1)%3==0 and k==0)tx+=8
			if((i+1)%3==0 and k==2)tx-=8
			spr(tile,tx,ty)		
		end
		tx+=40
		if((i+1)%3==0)tx=92
		if i!=1 and i%3==0 then
			ty+=8		
			tx=20			
		end
	end
end
-->8
--collisions

col_x_offset=0
col_y_offset=0

function collide_check(obj,aim,flag)
	local x1 local y1
	local x2 local y2
	local x = obj.x+(8*col_x_offset)
	local y = obj.y+(8*col_y_offset)
	local w = obj.w
	local h = obj.h
	if(aim<2) then
		x1=x+(w*aim)-1	y1=y+2
		x2=x+(w*aim) y2=y+h-3
	else
		x1=x+2	y1=y+(h*(aim-2))-(-3+aim)
		x2=x+w-3 y2=y+(h*(aim-2))
	end
	x1/=8	y1/=8
	x2/=8	y2/=8
	return fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag)
end

function spr_col_check(flag)
		for i=1,#active_actors do
			local a=active_actors[i]
			if fget(a.sp_list[1])==flag 
			and spr_overlap(a) then
				return true
			end
		end
	return false
end

function spr_overlap(a)
	local ox = player.x local oy=player.y
	return (mid(ox,a.x+1,ox+player.w)==a.x+1
		or mid(ox,a.x+a.w-1,ox+player.w)==a.x+a.w-1)
		and (mid(oy,a.y,oy+player.h)==a.y
		or mid(oy,a.y+a.h,oy+player.h)==a.y+a.h)
end

function sprs_overlap(a,a2)
	local ox = a2.x local oy=a2.y
	return (mid(ox,a.x,ox+a2.w)==a.x
		or mid(ox,a.x+a.w,ox+a2.w)==a.x+a.w)
		and (mid(oy,a.y,oy+a2.h)==a.y
		or mid(oy,a.y+a.h,oy+a2.h)==a.y+a.h)
end
-->8
--actors

actors={}
actor_list={}
active_actors={}

function load_actors(off)
	--active_actors={}
	for i=1,#actor_list do
		local act=actor_list[i]
		if get_band(act)==cur_sc+off then 	
			local a_inst=new_actor(
				get_band(act>>>8)+(16*((cur_sc+off)%8)),
				get_band(act>>>12)+(16*flr(cur_sc/7)),
				actors[get_band(act>>4)+1],
				cur_sc+off)
			add(active_actors,a_inst)
		end
	end
	for i=#active_actors,1,-1 do
		local aa=active_actors[i]
		if aa.scr<cur_sc-1
		or aa.scr>cur_sc+1 then
			del(active_actors,active_actors[i])
		end
	end
			
end

function update_actors()
	for i=1,#active_actors do
		local a=active_actors[i]
		if a.alive then			
			if(a.name=="scorpion")scorp_move(a) 
			if(a.name=="spider")spid_move(a) 
			if(a.name=="upgrade")upgrade_idle(a)
			if(a.name=="fish")fish_move(a)
			if(a.name=="jelly")jelly_move(a)
			if(a.name=="bird")bird_move(a)
		end
	end
	move_health()
	move_bubble()
	if(end_cutscene)update_cs_actors()
end

function draw_actors()
	for i=1,#active_actors do
		local a=active_actors[i]
		if a.alive then				
			
			if a.name=="spider" then 
				spid_draw(a)
			else
				basic_draw(a)
			end
		elseif a.circ_size>0 then
			circfill(a.dead_x,a.dead_y,a.circ_size,7)
			a.circ_size-=1			
		end
	end
	if(health_drop.active)basic_draw(health_drop)
	if(bub_shot.active)basic_draw(bub_shot)
	if(end_cutscene)draw_cs_actors()
end

function new_actor(ax,ay,data,load_sc)
	local a={
		scr=load_sc,
		sp=1,
		sp_list=data.sp_list,
		x=ax*8,
		y=ay*8,
		dx=0,
		dy=0,
		alive=true,
		w=data.w,
		h=data.h,
		facing=data.facing,
		speed=data.speed,
		name=data.name,
		anim_time=time(),
		anim_length=data.anim_length,
		circ_size=5,
		dead_x=dx,dead_y=dy,
		--spider
		start_y=ay*8,
		wait_time=data.wait_time,
		--fish
		jump_state=0,
		start_x=ax*8,
		jump_wait=time(),
		flip_y=false,
		--bob move
		bob=data.bob,
		--health
		active=data.active
	}	
	return a
end

function basic_draw(a)
	update_actor_spr(a)
	spr(a.sp_list[a.sp],a.x,a.y,a.w/8,a.h/8,a.facing==1,a.flip_y)
end

function mirror_y_draw(a)
	update_actor_spr(a)
	spr(a.sp_list[a.sp],a.x,a.y,1,2)
	spr(a.sp_list[a.sp],a.x+8,a.y,1,2,true)
end
function quad_draw(sp,x,y)

	for i=0,3 do
		local fx=i%2 
		local fy=flr(i/2)
		spr(sp,x+(8*fx),y+(8*fy),
		1,1,fx==1,fy==1)
	end
end

function spid_draw(spid)
	quad_draw(102,spid.x,spid.start_y)
	rect(spid.x+7,spid.start_y+7,spid.x+7,spid.y,7)
	mirror_y_draw(spid)
end

function update_actor_spr(a)
	if time()-a.anim_time>a.anim_length then	
		if a.sp==#a.sp_list then
			a.sp=1
			a.anim_time=time()
		else 
			a.sp+=1
			a.anim_time=time()
		end
	end
end

function kill_check(a)
	if (player.atk_state==1 
	and spr_overlap(a))
	or (bub_shot.active 
	and sprs_overlap(bub_shot,a)) then
		if(sprs_overlap(bub_shot,a))bub_shot.active=false
		a.alive=false
		a.dead_x=a.x+a.w/2
		a.dead_y=a.y+a.h/2
		if(flr(rnd(8))==0)spawn_health(a.dead_x,a.dead_y)
		a.x=-1 a.y=-1		
	end
end

function scorp_move(s)
	if not collide_check(s,s.facing,0) then
		s.x+= -s.speed+(s.speed*2*s.facing)
	else	
		s.facing=abs(s.facing-1)
	end
	s.dy+=gravity
	s.dy=min(max_dy, s.dy)
	if collide_check(s,3,0) then
		s.dy=0
		s.y-=(s.y+16)%8	
	end
	s.y+=s.dy
	kill_check(s)	
end

function spid_move(spid)
	--turn around
	if spid.wait_time==-1
	and (collide_check(spid,spid.facing,0) 
	or spid.y<spid.start_y) then
		spid.wait_time=time()
		spid.facing=abs(spid.facing-5)
		spid.y+=1
	end
	if spid.wait_time!=-1 then
		if(time()-spid.wait_time>1) spid.wait_time=-1
	else
		spid.y+=spid.speed-(spid.speed*-2*(spid.facing-3))	
	end
	kill_check(spid)	
end

function upgrade_idle(upg)
	if(cur_sc<4 and player.bubble)
	or(cur_sc>3 and player.dub_jump)then
		upg.alive=false
	end
	bob_move(upg)
	if spr_overlap(upg) and mid(upg.x-4,player.x+4,upg.x+12)==player.x+4 then
		upg.alive=false
		cors.upgrade=cocreate(upgrade_get)--bubble
	
	end
end

function jelly_move(j)
	bob_move(j)
	kill_check(j)
end

function bob_move(a)
	if a.y>a.start_y-a.bob then
		a.dy-=a.speed
	else
		a.dy+=a.speed
	end
	a.y+=a.dy
end

function fish_move(f)
	if f.jump_state==0 then
		if time()-f.jump_wait>1.5 then
			f.jump_state=1
			f.dy=-5
			f.sp=1
		end
	elseif f.jump_state==1 then
		f.dx=-f.speed+(f.speed*2*f.facing)
		f.dy+=.25
		if f.dy>=0 then 
			f.jump_state=2
			f.sp=2
		end
	else
		f.dx=-f.speed+(f.speed*2*f.facing)
		f.dy+=.25
		if f.y>255 then
			f.jump_state=0
			f.jump_wait=time()
			f.dx=0
			f.dy=0
			f.x=f.start_x
			f.y=248
			f.sp=1	
		end
	end	
	f.x+=f.dx
	f.y+=f.dy
	kill_check(f)
end

function bird_move(b)
	if player.x>b.x then
		b.facing=1
	else
		b.facing=0
	end
	b.dx-=b.speed-(b.speed*2*b.facing)
	b.dx=mid(-4,b.dx,4)
	b.x+=b.dx
	kill_check(b)
end

function spawn_health(hx,hy)
	health_drop.active=true
	health_drop.x=hx
	health_drop.y=hy-8
	health_drop.dy=-3
end

function move_health()
	if health_drop.active then
	if not collide_check(health_drop,3,1)then
		health_drop.dy=min(health_drop.dy+.7,max_dy)
	
	else
		health_drop.dy=0
		--health_drop.y=(health_drop.y+16)%8
	end
	health_drop.y+=health_drop.dy

	if spr_overlap(health_drop) and mid(health_drop.x-4,player.x+4,health_drop.x+12)==player.x+4 then
		health_drop.active=false
		player.health=min(player.health+1,player.max_health)
	end
	end
end

function spawn_bubble()
	bub_shot.active=true
	bub_shot.x=player.x
	if player.facing then
		bub_shot.facing=0
		bub_shot.x+=8
	else
		bub_shot.facing=1
	end
	bub_shot.y=player.y+2	
end

function move_bubble()
	if bub_shot.active then
		bub_shot.x-=bub_shot.speed-(bub_shot.speed*2*bub_shot.facing)
		--lol
		if not door_open 
		and mid(980,bub_shot.x,984)==bub_shot.x
		and mid(168,bub_shot.y,172)==bub_shot.y then
			bub_shot.active=false
			door_open=true		
			cors.door=cocreate(open_door)
		end
	end
end




-->8
--cutscenes

function upgrade_get()
	local timer=time()
	player.upgrading=true
	if(cur_sc<4) then
		player.bubble=true
	else
		player.dub_jump=true
	end
	while(time()-timer<2)yield()
	player.upgrading=false
end

function open_door()
	music(36)
	mset(122,21,8)
	mset(123,21,9)
	player.move_lock=true
	local door_timer=time()
	local sh_timer=time()
	local camx = peek2(0x5f28)
	local camy = peek2(0x5f2a)
	for i=1,6 do
		camera(camx-1,camy)
		wait(.2)
		camera(camx+1,camy)
		wait(.2)
	end
	wait(1)
	sfx(57)
	mset(122,25,0)
	mset(123,25,0)
	mset(122,26,0)
	mset(123,26,0)
	player.move_lock=false	
end

function end_scene()
	player.move_lock=true
	active_actors={}
	end_cutscene=true
	--cs_end_t=time()
	col_x_offset=112
	col_y_offset=16
	
	player.x=0 player.y=150
	fade_pal(true,.2)	
	player.m_move=1
		wait(1.4)
	player.m_move=0
		wait(1.5)
	player.m_move=.5
		wait(.5)
	player.m_move=0
		wait(1)
	player.anim_time=.3
	player.m_move=.5	
		wait(1)
	player.anim_time=.15
	player.m_move=0
		wait(1.5)
	player.m_sp=138	
		wait(.2)
	player.m_sp=64
		wait(.6)
	mset(124,43,186) mset(124,44,186)
	mset(125,43,186) mset(125,44,186)
	player.dy=-2
	player.dx=-20
	sfx(63)
	frog_girl.active=true
		wait(2)
	frog_girl.state=1
	frog_girl.sp=1
	player.dy=-.8
	player.dx=-5	
		wait(1.5)
	music(33)
	frog_girl.dx=-.8
		wait(.2)
	player.dx=-4
		wait(.8)
	frog_girl.dx=0
		wait(.8)
	frog_girl.state=2
		wait(.2)
	player.x-=-1
	player.m_sp=160
		wait(.05)
	player.x+=2
		wait(.05)
	player.x-=1.5
	heart.active=true
		wait(1.8)
	heart.active=false
	frog_girl.x+=2
	frog_girl.state=3
		wait(.5)
	player.m_sp=64
		wait(1.2)
	player.m_sp=78
	end_close=true
	wait(8)
	fade_pal(false,.2)
	wait(.5)
	game_state="title"
	col_x_offset=0
	col_y_offset=0
	player.move_lock=false
	end_cutscene=false
	player.m_sp=-1
	player.sp=64
	cors.intro=cocreate(intro)	
end


function wait(t)
local timer=time()
while time()-timer<t do
		yield()
end
	return false	
end

frog_girl={
	x=96,y=216,
	h=16,w=16,
	dx=0,
	sp=164,	
	sp_list={132,134},
	state=0,
	anim_time=0,
	anim_length=.15,
	active=false
}
heart={
	x=72,y=214,
	h=8,w=8,
	dx=2,dy=0,
	sp=1,
	sp_list={194},
	state=0,
	anim_time=0,anim_length=0,
	active=false
}

function update_cs_actors()
	if(frog_girl.active)update_frog_girl()
	if(heart.active)update_heart()
end

function draw_cs_actors()
	if(frog_girl.active)draw_frog_girl()
	if(heart.active)basic_draw(heart)
end

function update_frog_girl()
	if frog_girl.state==0 then
		if time()-frog_girl.anim_time>.2 then
			frog_girl.anim_time=time()	
			if frog_girl.sp==171 then frog_girl.sp=187
			else frog_girl.sp=171
			end
		end
	elseif frog_girl.state==1 then
		if frog_girl.dx!=0 then
		frog_girl.x+=frog_girl.dx
			if time()-frog_girl.anim_time>.2 then
				frog_girl.anim_time=time()	
				--frog_girl.sp=134+abs(frog_girl.sp-134)
			end
		else
			frog_girl.sp=1
			frog_girl.anim_time=time()
		end
	elseif frog_girl.state==2 then
		frog_girl.sp_list[1]=136
		frog_girl.sp=1
		frog_girl.anim_length=100
	else
		frog_girl.sp_list[1]=132
		frog_girl.anim_length=.2
		frog_girl.state=1
	end
end

function draw_frog_girl()
	local x = frog_girl.x
	local y = frog_girl.y
	local sp= frog_girl.sp
	if frog_girl.state==0 then
		quad_draw(sp,x,y)
	else
		basic_draw(frog_girl)		
	end
end

function update_heart()
	if heart.x>72 then
		heart.dx-=.3
	else
		heart.dx+=.3
	end
	heart.y-=.2
	heart.x+=heart.dx
end

end_close=false
wipe=1
function end_scr_wipe()
	if wipe<63 then
		rectfill(0,128,wipe,256,0)
		rectfill(128,128,128-wipe,256,0)
		wipe+=1
	else		
		rectfill(0,128,128,256,0)
		draw_the_end()
	end
end
__gfx__
00000000044444401111111111111111000000001100001110000000000000010000000000000000000000000000000000000000000000000000000000000000
000000004444242411111111111111117799997710cccd0102444444444444200dd5555555555d00aa999977779999aa055dddddddd555500d55007799005d00
00700700049424401111111111111111444444440c77ccd0044ffffffffff440d55555555555555009944444444449900000000000000000d500970079990050
00077000444422241110001111100011222222220c77ccd004f000ff0f00ff405500000000005550100222222222200107767770777777d05099707007799900
00077000044494401103b3011105d501000000000cccccd004ffffffffffff405000000000000050111000000000011107777000077777d05099700007799900
0070070044444424110b0b30110d0050111111110dcccdd004ff0f000f0f0f405555555555555550111111111111111107777d0d07777d005500970079990050
0000000002222200103b0bb310500dd51111111110dddd0104ffffffffffff40d55555555555550011111111111111110077d077d077d0d0d555007799005500
000000004000002410bbbb0b10d0dd0d111111111100001104fff00ff0f0ff40050505000050505011111111111111110077d077d077d0700505050000505050
100110010444444010bbbbbb10dddddd1117117100001111044ffffffffff440000000000000000000000000000000000d0d07777d0d0d700000055000005500
0bb00bb0444444241030000010500000111e1e1107b0111102444444444444200030dddddb0ddddb003055555305555307d0777777d0d77066dd05550ddd00dd
0a0bb0a009444440100ff00e10055502710ee0110bb0111110000000000000010b0d6666dd30ddb00305dddd5530553007d0777777d07770dddd50550ddd0ddd
0bbbbbb040449424110dff00110555021ee2220e03b0110111111102201111110bd666666d30d30d035dddddd530530507d0777777d07760555500000dd50005
0b0220b0044444401110ffff1110550211e2221103bb0030111111044011111100d66ddddd0dd3dd005dd55555055355000000000000000000000dd00550dd00
103ee30144944224111100df111100501102201103bbbb0011111104401111110dddddddddddd0dd0555555555555055055ddddddd5555506dd00ddd0000ddd0
110ee0110444024011111100111111001e2101e13333bb3011111104401111110ddddd505055555005555550505555500555555555555500dddd0555dd0dd550
111001114400400411111111111111111111e11100000000111111044011111100505505050505000050550505000500005555555555000055550000d5505000
0000000000000000544444444444555502404202422444200300bb00b003333b331bbbb3bbbbb313111111111111111105003300300555533333333333333333
333bb30333bb300344444444444444440240202440449440b033b000bbabbb001bbab131bb1111b111111111111111113055300033b33300b033b000bbabbb00
03b33030533bb300444499994444444404442099404994200bbbb030bb30bb303113133311b133b1110011100011111103333050335033500bbbb030bb30bb30
3b3300350533bb30499999999999444404992099004944400ba003b3b03000303333bbb111b1331b103300033301111103b00535305000500ba003b3b0300030
0330550050033333999955559999999909922040002444203b333330300b00b01311333133331333033bb0333301111153555550500300303b333330300b00b0
5005444444500300955554445555999909942099022442003bbb3030bbbb3b0331311113b3b311b10300b0b33330111153335050333353053bbb3030bbbb3b03
4554444444455055544444444444555504940499049944203b3bbb33003bbb331111111111111111033300030350111153533355005333553b3bbb33003bbb33
44449999444444444444999944444e4404420994049902200030bb3333b30b33111111111111111103bb03333300111100503355553503550030bb3333b30b33
000000000000000049999999999944440242099400200000330bbbb3bbbbb30311111111111111110bb03bbb3500111155033335333335051111111111111111
5553350555335005999955559999999902442994404994200bbab030bb0000b0155111111111111100b0b00030500000033b30503300003011ccccc711cccc71
0535505005533500955554445555999904944099409992203bb30b33abb333b011151111503311510b000bb3500030305005055500305530cc11111cccc111cc
535500550055335054444e444444555504044099409990203bb3bb3bb3bb3b3b331001150b00100503b0b3330050333055553330003055031111111111111111
05500000000555554444999944444e440444204920990420303b333303b3bbbb110bb0b0b0bb0bb003b0b3500030033005005550555505551111111111111111
0000222222000500499999999999444402442042204002203b30b003330bb3b000b0031b030b00b0033033000550030150500005353500301111111111111111
0002220220200000999955559999999902442444222422200b30bbbb000b00b000b0300b00b0300b103350110301030100000000000000001111111111111111
20202040020022009555544e555599990044444022222200b3003b030033b0330330330b00b03333110001105301101100000000000000001111111111111111
11110011100111111111111111111111111100111001111111110011100111111111001116115111111111001110011111111111111111111011100110011111
1110bb000bb0111111110011100111111110b0000b0011111110bb000bb011111100bb0011166651111110bb000bb011111100111001111106010bb00bb01111
1103b0bbbb0b01111110bb000bb011111103b0bbbb0b01111103bbbbbbbb0111103bb0bb01156661111103b0bbbb0b011110bb000bb011110600b0bbbb0b0111
100bb0bbbb0bb0111103b0bbbb0b0111100bbbbbbbbbb011100bb0bbbb0bb01103bbb0bbb011666511110bb0bbbb0bb01103b0bbbb0b0111060b0b0bb0b0b011
060bbbbbbbbbb011100bb0bbbb0bb011060bbbb200bbb011060bb0bbbb0bb01103bbbbbbbb01666611110bbbbbbbbbb0110b00bbbb00b011060bbbbbbbbbb011
0603bb20000b3011060bbbbbbbbbb0110603bbb00bbb30110603bbb200bb301103bbbb2000016666111103bb20000b30110bbbbbbbbbb0110503b000000b3000
05600300bbb301110603bb20000b3011056003bbbbb30111056003b00bb301111003bb003011666611111003000bb3011103bbb2000b301100403b0220b30040
106020000000000105600300bbb3011110602000000000011060200000000001044000000016666611111020000000001100030000b300000bb0000000000340
1050228888820401106020000000000110502288888204011050228888820401020bb00011166661111110228888804010302000000002401030088888800340
100402887782040110502288888204011004028877820401100402887782040110200bbb01666661111110028877804010302288888202401000288877820020
103b0288878204011004028877820401103b028887820401103b028887820401102880000666666111000b028887044003000288778203401030288887820101
110b022888200201103b028887820401110b022888200201110b020088000201100288001006670110665002288802010bb00280078203401100028888201111
1110000000010011110b0028880002011110000000010011111000bb00bb00111000203b0110067006500030000000110046020bb02000011111000000001111
11103b003b0011111110000000bb001111103bb13bb01111111103bb03bb011110300003b001110100010330003b00111006600bb00bb01111110bb33bb01111
111003bb03bb01111110b3003bbb011111103b003b01111111111033003301110bbb01103bb0111111110bbb0103bb011110060003bbb0111110bb3003bb0111
11110000000001111110001100000111111100000011111111111100110011111000011100001111111110000100000111111011100001111110000110000111
11011111111011021111111111111111111111111111111111111111000000111100000111111111111111111000111111111111111111111111111111111111
10201112110200221111111111111111111111111000111111011110bbbbbb011066666010000111111001110550111111111111110000111111111111111111
020110001020100011111111100001111111111100aa001110701007bbbbbbb01066076d05660011110060110dd5011111111111108882011111111111111111
0201002210200022111111110aa00011111111100000a00111070770333333011066776d005660011006600100d5011111111111088820111111111000111111
020102ee102002ee111111100000a90111111110a01009011110700000000011006666d005066601106665000d2d501111111111088801111110000882011111
02002eee10202eee11111110a01009901111111101110a9011070707111111110666dd0edd0500111065005de220d50111100000888201111108088088201101
10202eee11002eee1111111101110a901111111111110990110700701111111100dd0020ed50011110505dde022ddd5011080880088011011080788888820080
110022ee100022ee111111111111099011001110011109901070070711111111110056222ed0111111000de22266d50010807888880110800980788888880880
10000222022002221100111110009a9010990110700099a0111111000000000010005d6220e0000110dd0e022665001109807888888008809988888808888020
020000022200000210990110007099900994401000079990100000bbbbbbbbbb10500566222d0d500666d02266d0111199888888888888200008820880888001
22000700201107000994400aa07aa9400044400aaa079a4003bbbbbbbbbbbbbb105500d66222dd5006776d06d501111100088208888882011110000022080201
2002070e2002070e00400009aaaa990104000000aaaa99011033333333333333100001056d0d550006076d055000111111100000220222011111111100400011
202200ee202010ee110aaaa00a9994011010aaaa00999401110000000000000011111110ddd50011066666d00050111111111111004000111111111110990111
20201020002011021110aaaa9994004011110aaa999404011111111111111111111111105d501111066666d00550111111111111104990111111111110901111
00201101110201101109999004040040111099990040040111111111111111111111111105011111100006010000111111111111110901111111111111011111
10201111111011111110000110101001111100000001101111111111111111111111111100111111111100011111111111111111111011111111111111111111
11111100001111111111111111111111111110a0a0a01111111111111111111111110a0a0a011111111111111111111100000000000000000000000000000000
111100eee200111111111000000111111111100aaa001111111110a0a0a01111111100aaa0011111111110001100011181918191819181918191819181918191
1110eeeeeee20111111002eeee20011111110bb000bb01111111100aaa00111111103b000b30111111110bbb000bb01100000000000000000000000000000000
110ee777eeeee0111102ee777eee2011111000bbbb00301111110bb000bb01111100bbbbbbb3011111103bbbbbbbbb01b12a3a2b3b2b3b2b3babab2b3babab81
102e77eeeeeee201102e777eeeeee201110bb0bbbb0bb011111000bbbb00301110300bb00bbb01111100bb00bbb00bb000000000000000000000000000000000
10ee7eeeeeeeee0110ee77eeeeeeee01110bbbbbbbbbb011110bb0bbbb0bb01110bbbbbbb0bb01111060bbbbbbbbbbb0a1b12a3a2b3b2b3b2b3b2b3b2b3b8191
02e77eeeeeeeee200ee7eeeeeeeeeee01103b0bbb0bb3011110bbbbbbbbbb01110b00bbbbbb0111110603bbbbbbb003000000000000000000000000000000000
0eeeeeeeeeeeeee0eeeeeeeeeeeeeeee1110ff000ff001111103b0bbb0bb3011110f0bbbff0011111056003bbbbb0301b1a1b12a3a2b3b2b3b2b3b2b3b2b3b81
00000000000000000000000000000000111100fff00030111110ff000ff001111110ffff00030111110602000000000000000000000000000000000000000000
0f0020f0220f00f10f0020f0220f00f01111080002820011111100fff000301111110000220b01111105022888882040a1b1a1b12a3a2b3b2b3b2b3b2b3b8191
10f000f0e00f0f01f0000f00ee00f00f111000888800030111110800028200111110008800b00111110040288778204000000000000000000000000000000000
100e0e00e0000001000e000e0e0e0000110b088882800bb0111100888800b301110b0880bb0011111103b02888782040918191819181912b3b2b3b2b3b2b3b81
10e010e00e0e00e010e0100e0e0e0e011110888882820b01111108888280b011111088880b0201111110b0228882002000000000000000000000000000000000
0ee010ee00ee00e010e010e0100e0e01110228882822201111108888828200111102288820222011111100000000100181912b3b2b3b2b3b2b3b2b3b2b3b8191
0e01110e00e00ee0110e00e010e000e0110000000000001111020088282220111100000000000011111003bb03bb011100000000000000000000000000000000
101111101101100111101101110110011110bb30bb3001111100b300000000111110bb30bb30011111110000000001119181912b3babab2b3b2b3babab2b3b81
111100111001111100000000000000000bbbbb30000000000000000000000000000000000bbbbb300bbbbb30000000d700000000000000000000000000000000
111088000880111100305001110011100bbbbb30bbbbbbbb00bbbbbbbbbbb30000bbb3000bbbbb30bbbbb3300000676781912b3b2b3b2b3b2b3b2b3b2b3b8191
11028088880801110305ddd0011111110bbbbb30bbbbbbbb0bbbbbbbbbbbbb300bbbbb300bbbbb30bbbb3300000d667700000000000000000000000000000000
1008808888088011035dddddd00111110bbbbb30bbbbbbbb0bbbbbbbbbbbbb300bbbbb300bbbbb30bbb330000d67777791819181912b3babab2b3b2b3bab9181
0608888888888011005dd555550011110bbbbb30bbbbbbbb0bbbbbbbbbbbbb300bbbbb300bbbbb30bbb300000d77777700000000000000000000000000000000
060288200008201105555555555001010bbbbb30bbbbbbbb0bbbbbbbbbbbbb300bbbbb3003bbb330bbbb3000006777778191abababababababababababab8191
056002008882011105555550505500100bbbbb30333333330bbbbb333bbbbb300bbbbb30003333003bbbb3000776777700000000000000000000000000000000
106020000000000100505505050005000bbbbb30000000000bbbbb300bbbbb300bbbbb30000000000bbbbb300d777777918191ababababababababab0c1c9181
105022888882040100000000000000000bbbbb300bbbbb300bbbbb300bbbbb300000000000000000000000000000000000000000000000000000000000000000
10040288778204010001111111111110bbbbbb300bbbbbbb0bbbbbbbbbbbbb3000bbbbbbbbbbb30000000000000000d781918191abababababababab0d1d8191
103b0288878204010011111110111100bbbbbb300bbbbbbb0bbbbbbbbbbbbb300bbbbbbbbbbbbb30000000000000066700000000000000000000000000000000
110b0228882002010011111111111110bbbbbb300bbbbbbb0bbbbbbbbbbbbb300bbbbbbbbbbbbb300000000000000d6791819181918191819181918191819181
11100000000100110111111111011111bbbbbb300bbbbbbb0bbbbbbbbbbbbb300bbbbbbbbbbbbb30000000000007d06600000000000000000000000000000000
11103b003b0011110111111111010101bbbbbb300bbbbbbb03bbbbbbbbbbb33003bbbbbbbbbbb3300000000000d766d781918191819181918191819181918191
111003bb03bb011100111110101000103bbbbb300bbbbb3300333333333333000033333333333300000000000076767700000000000000000000000000000000
111100000000011100000000000000000bbbbb300bbbbb30000000000000000000000000000000000000000000d77777b1819181918191819181918191819181
0000000000000a0011011101ff0ffff000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000024200aa010801080f004440bb30004420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004444420aa18780888f40444088b0b30420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044fff4420018788888f40040b80bb883020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000022f0fff440010888880f40040bbbbb08b020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000ff0fff42011088201f444403bbbbbb3020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000fffffff4011102011f44444003bbb30420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000020fef0f40011110111f44400b0000304420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000880fff000011111111f4007b0030b0b0420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000088000004f0011111111f00770770b0b30420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000880ff04ff05011111111f0000770b00304420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000888800ff0055011111111f0400007070030420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088888882000000011111111f0404000700304420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
028882820005555011111111f0444440000044420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000288220355550011111111f4444444040444420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ff022222055503011111111f2222222022222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000001080000000001010000000010000000050800000303000000000303030303030000000000000000000001010000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040404040001040404040404040404040404040401010404040404040404
0404040400000000000000000000000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e0000000000000000000000000000000000000000000000001f1ed2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2
1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f0000000000000000000000000000000000000000000000001e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f00000000000000000000000000000000000000000000001f1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f14141414141f1e1f1e1f1e00000000000000000000000000000000000000000000001e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1e1f000000000000000000000000000000001e1f1e1f1e1f1e141400000000001e1f1e1f1e1f1e000000000000000000000000000000000000000000001f1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1f000000000000000000000000000000000000001f1e1f1e0000000000000000001e1f1e1f1e1f1e1f000000000000000000000000000000000000001f1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1e0000000000000000000000000000000000000000000000000000000000000000001e1f1e1f1e1f1e1f1e1f1e1414141e1f000000000000000000001e1f1e0000000000000000000000000000000000000000000000000000000000000000000000000a0b0000000000000000000000000000000000000000000000000000
1e1f0000000000000000000000000000000000000000000000000000000000000000001f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f00000000000000141e1f1e1f000000000000000000000000000000000000000000000000000a0b000000000a0b00000000000000000000000000000000000000000000000000000000000000
1f1e000000000000000000000000000000000000000000000000000000000000000000001f1e1f1e1f1e1f1e1f1e1f1e1f1e1400000000000000141e1f1e1f1e0000000000000000000a040b0000000000000000000a0b00000000000000000000000000000000000a0b00000a0b000000000000000000000000000000000000
1e1f1e0000001e1f000000000000000000000000000000000000000000001400000000001e1f1e1f1e1f000000000000000000000000000000141e1f1e1f1e1f0000000000000000000000000000000a0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1e1f1e1f1e1f1e000000000000000000000000000000001414141e1f1e1f14000000001f141400000000000000000000000000000000141f1e1f1e1f1e1f1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a04040b00000000000000000000000000
1e1f1e1f1e1f1e1f00000000000000000000000000000000141f1e1f1e1f1e1f1e0000000000000000000000000000000000000000001e1f1e1f1e1f1e1f1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1e1f1e1f1e1f1e1f1e000000000000000000000000001e1f1e1f1e1f1e1f1e1f1e000000000000000000000000001f0000001e1f1e1f1e1f1e1f1e1f1e1f1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0b00000000000000060700000000000000000000
1e1f1e1f1e1f1e1f1e1f1e1f00000000000000001e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f14141414141f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161700000000000000000000
1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e00000000000000002f2f2e2f2e2f2e2f2e2f2e2f2f2e2f2e2f0000002e2f2f2e2f2e2f000000002e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e2f2e
1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f1e1f0000000000002e3736373637363736373637363736373637362d2c2d262736363736372e2f2e2f36373637363736373637363736373637363736373637363736
262726272627262726272627262726272627262726272627363736373637262736373637363736373637363736373637363736373637363736373637363736372d2c2d2c2d2f363736373637363736373637363736373637362c2d2c363736262726272928292726272627262737363736373637363736373637363736373637
363736373637363736373637363736373637363736373637262726272627363726272627262726272627262726272627262726272627262726273637363726272c2d2c2d2c27262726272627262726272627262726272627262d2c2d262726363728290000002836372627363727262726272627262726272627262726272627
26272627262726272627262726272627262726272627262736373637363726273637363736373637363736373637363736373637363736373637363736373637362c2d2c2d37363736373637363736373637363736373637362c2d2c36373637290000000a0b0028292829263637363736373637363736373637363736373637
36373637363736373637363736373637363736373637363726272627262736372627262726272627262726272627262726272627262726272627262726272627262d2c2d2c272627262726272627262726272627262726272c2d2c2d27272627000000000000000024252d362627262726272628292829282928292829282927
26272627262726272627262726272627262726272627262736373637363726273637363736373637363736373637363736373637363736373637363736373637282c2d2c2d3736373637363736373637363736373637362c2d2c2d2c36373637000a0b000000000034352c28292829282928292c2d1819181918191819181918
363736373637363736373637363736373637363736373637262726272627363726272627262726272627282928292827363726272829282928292829282928292c2d2c2d2c2926272627262726272627282928292829282d2c2d2c2d26272600000000000000000024253c2c2d24252c2d2c2d3c3d00000000000e0f1a1b1a1b
2627262726272726272627282928262627262726262726272828282928292627363736373637362828292d2c2d2c2d29282928292d2c2d2c2d2c2d2c2d2c2d2c3c3d3c3d3c3d282928292829282928290000010024253d3c3d3c3d3c28292800000000000a0b00003435003c3d34353c3d3c3d00000000181918191819181918
28292829282928292829282c2d2c282928292829282928292c2d24252c2d2829262726272627292d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d2c2d3c3d3c3d0000000000000000000024250000110000001100343500000000010000242500000000000000000024250011002425000001000000001a1b1a1b1a1b1a1b1a1b
2d2c2d2c2d24252c2d2c2d2c2d2c2d24252d2c2d2c2d2c2d3c3d34353c3d3c3d2829282928292d2c2d2c2d2c2d2c2d2c2d2c2d2c3c3d3c3d3c3d3c3d000000000000000000000000000034350000010000000100242500000000110000343500000a0b00000000003435000100343500001100000000001a1b1a1b1a1b1a1b1a
3d3c3d3c3d34353c3d3c3d3c3d3c3d34353d3c3d3c3d3c3d0000242500110000000024252c2d2c2d2c2d2c2d3c3d3c3d3c3d3c3d0000010000000000000000000000000006070000000024250000112a2b0011003435000000000100002425000000000000002a2b242500110024252a2b01000000001a1b1a1b0c0d1a1b1a1b
0000000000242500000001000000002425000100000000110000343500012a2b000034353c3d3c3d3c3d3c3d00000001000000000000110000000000000000000000383916173839383934353839383a3b393839242500002a2b1100003435383938393839383a3b343538393934353a3b383938391a1b1a1b1a1c1d1b1a1b1a
0000000000343500000011000000003435001100000000010000242500113a3b38392425000000010000000000000011000000000000010000000000000000000000202120212021202120212021202120212021343538393a3b3839202120212021202120212021202120212021202120212021202120212021202120212021
0000000000242500000001002a2b002425000100000000112a2b343538392021202134353800001100000000000000010000000000001100000000000000000000203233323332333233323332333233323332332021202120212021323332333233323332333233323332333233323332333233323332333233323332333233
2021202139343538393839383a3b393435393839383938393a3b202120213233323320212030303130313031303130313031303130313031303130313031301f1e322223222322232223222322232223222322233233323332333233222322232223222322232223222322232223222322232223222322232223222322232223
323332332021202120212021202120212021202120212021202132333233222322233233321e76673e3f7677673e3e3e3f76673e3f3e3f7677673e3f3e3e3f1e1f223233323332333233323332333233323332332223222322232223323332333233323332333233323332333233323332333233323332333233323332333233
222322233233323332333233323332333233323332333233323322232223323332332223221f0000000000000000000000000000000000000000000000001e1f33322223222322232223222322232223222322233233323332333233222322232223222322232223222322232223222322232223222322232223222322232223
__sfx__
011400002872128731287412875128752287522875228752267522675226752267522b7512b7512b7522b75128731287212874128731287512874128741287312873128721287212872128721287112376524765
0114000815565185451c54515565185451c54515565185451a5001a5001a5001a7001870018700187001870000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000237651f7651c7621c7611c7511c7511c7511c7511c7411c7411c7411c7311c7311c7311c7211c71100700007000070000000000000000000000000000000000000000000000000000000000000000000
0114000010022100221002210022100201002010020100200e0200e0200e0200e0200e0200e0200c0310c03110031100311003110030100301003010021100211002210022100221002213021130221302213022
011400081802300000266130000018023180232661300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000b0300b0310b0210b0210b0220b0220b0220b0221303213031130311303113031130310c0210c0210b0210b0310b0310b0310b0210b0210b0210b0210403104031040310403111031110311103111031
011400081c5551f535235351c5551f535235351c5551f535005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000237552b75528751287512875128751287412874128741287412873128731287312873128731287311c7211c7211c7211c7211c7211c7211c7111c7111c7111c7111c7111c71100000000000000000000
011400000c6250c62500000000000000000000006250000000000000000000000000000000000000000000000c6250c625000000000000000006250c625000000000000000000000062500625006252661318023
011400000c6250062500000000000000000605006250000000000000000000000000000000000000000000000c62500625000000000000000006250c625000000000000000000000000000000000000000000000
011400001514215140091450914500000151401514013145151421514009145091450000018100171001510015140151400914509145000001514215140131451514015140091450914518140171401514511145
011400001314213140071450714500000131401314011141131411314007145071450000000000000000000013140131400714507145000001314213140111411314113140071450714507145071450814508145
01140000151401514009145091450000015140151401314515140151400914509145000000000000000000000000000000000000000000000000000000000000000000000013145151451814017140151451c142
01140000181411a1411a1411a1411a1311a1311a1211a1211a1211a1211a1311a1311a1411a1421a1421a14218142181421814118141181411814118141181411714217142171411714117141171411714117141
01140000155651a5451e545155651a5451e545155651a545155651a5451e545155651a5451e545155651a54515565185451c54515565185451c545155651854515565175451c54515565175451c5451556517545
01140000090400904009040090400904009040090400904009040090400904009040090400904009040090400c0400c0400c0400c0400c0400c0400c0400c0400b0400b0400b0400b0400b0400b0400b0400b040
011400001802300000266130000018023180232661300000180230000026613180231800318023266130000018023000002661300000180231802326613000001802300000266131802318023180232661326613
0114000015140151311512115125157501575015750157501c7511c7511c7511c7511875118751187511875117751177511776117761177611776117751177511075110751107511075110741107411074110741
011400001e700000000000000000157501575015750157501c7511c7511c7511c7511f7511f7511f7511f7511e7511e7511e7511e7511e7411e7411e7411e7421e7521e7611e7621e7621e7511e7511e7511e752
0114000015140151311512115125157501575015750157501c7511c7511c7511c7511875118751187511875117751177511776117761177611776117751177511375013750137501375017750177501775017750
011400001575115751157511575115751157511575115751157511575115751157511575115751107551275012751127511275112751127511275112751127511275112751127511275121751217512174121741
01140000095550c555105551555500000000000000000000095550c555105551555500000000000000000000075550b555105551355500000000000000000000075550b555105551355500000000000000000000
0114000009050090510905109051100411004110041100410e0510e0510e0510e0510e0510e0510c0510c0510b0510b0510b0510b0510b0510b0510b0510b0511004110041100411004110041100411004110041
0114000012030120311203112031120311203112031120311202112021120211202112021120210e0350203002030020300203002030020300203002030020300203002030020300203002030020300203002030
01140000095550c555105551555500000000000000000000095550c555105551555500000000000000000000065550b5550e5551255500000000000000000000065550b5550e5551255517555125550e55502555
0114000006565095650e56512565155651a5651e5652156526565215651e5651a565215651e5651a5650956506565095650e56512565155651a5651e565215651a56515565125650e56505565055650756507565
012c0000157001570015754157521c7711c77218772187621776217762177621776213771137721776217765177000000015754157521c7711c7721877218762177621776217762177621c7611c7621c7621c765
012c00000906009065091600916010161101600c1600c1600b1620b1620b1620b1620217202172041620416509060090650916009160041610416002160021600416204162041620416204162041620716007160
012c0000095650c565105651556500000000000000000000075650b5650e5651356500000000000000000000095650c565105651556500000000000000000000075650b565105651356500000000000000000000
011600200c0630c0000c06300000000000000000000000000c000000000000000000006650000000000000000c06300000000000000000000000000c063000000000000000000000000000665000000000000000
011600002814128140281402814028142281422814228142261402614026140261402414024140241402414028141281402814028140281402814028140281402614126142261422614224142241422414224142
011600002114021140211402114121142211422114221142211312113121131211312113121131211352110521130211302113021130211302113021130211322113221132211322113221132211322113221132
012c0000075650c565105651356500000000000000000000095650e56512565155650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600000c0100c0110c0210c0210c0310c0310c0310c0310c0510c0510c0510c0510c0510c0510c0510c0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e0510e051
011600001f1421f1421f1421f14500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000b0500b0500b0500b05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200001755017550175501755500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0104000010551175311c5211c5251d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000154430e4000c4000e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000065300653006530065300653006530065300653006530065300653006530065300653006530065300003000030000200002000000000000000000000000000000000000000000000000000000000000
011100001343313433134331343313433134331343313433134331343313433134331343313433134331343300000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001735521355000001330022300173452134500000000000000017325213250000000000000001631520315000000000000000000002031500000000000000000000000000000000000000000000000000
01060000240310e1311b0210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000346211d621106210512500000000000000000000103000510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001c5511f541235312852129521295251c2001d5001d5001d5001e500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00 01 03 44
00 02 06 05 09
01 00 01 03 09
00 07 06 05 08
00 0a 01 03 04
00 0b 06 05 04
00 0c 01 03 08
00 0d 0e 0f 04
00 11 15 03 09
00 12 18 16 08
00 13 15 03 04
00 14 19 17 04
00 00 01 03 04
02 02 06 05 04
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 1a 1c 1b 1d
00 1e 1c 43 44
00 1f 20 21 44
04 22 24 23 44
04 3b 3a 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 04 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
