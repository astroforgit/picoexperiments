pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--willo
--by dan howard @danhowardgames
--music and sfx by chris donnelly @gruber_music

--stop new pal reseting
poke(0x5f2e,1)
--stop btnp repeating
poke(0x5f5c, 255)


function _init()
	reset_pal()

	--game timer and states
	t,title,winlevel,wingame,contselect,showfinalscore,wintimer,level=0,true,false,false,true,false,0,1

	--fade
	fade,fadein=0,false--fade set to 1 to activate
	fades={
		0b1111111111111111.1,
		0b0111111111011111.1,
		0b0101111101011111.1,
		0b0101101101011110.1,
		0b0101101001011010.1,
		0b0001101001001010.1,
		0b0000101000001010.1,
		0b0000001000001000.1
	}

	--start title music
	music(0)

	--init scores
	score={}

	--tutorial and tooltip messages
	tipbob,tutnum=false,1
	tuts={
		split"120,60,  blow out candles for points",
		split"200,70,   tombs act as checkpoints",
		split"200,50,  you can also hide in tombs",
		split"356,48,    dispel pentagrams to win",
		split"484,132, press \x97 to attract skelliwags",
		split"400,456,  eyes alert nearby skelliwags!"
	}

end

function _update60()
	--game timer
	t+=0.5
	if t>=30000 then t=0 end

	menuitem(1)--remove restart mission from menu

	if title then
		if t>60 and btnp"4" then
			title=false
			load_level()
			fade=1
		end

	elseif winlevel then
		--play stinger
		if t==0.5 then music(21) end
		--menu
		if t>120 then
			if contselect and btnp"3" then
				contselect = false
			elseif not contselect and btnp"2" then
				contselect=true
			end
		end

		if t>125 and btnp"4" then
			if contselect then level+=1 end
			winlevel=false
			contselect=true
			if level<=8 then
				load_level()
			else
				t=0
				winlevel=false
				wingame=true
			end
		end

	elseif wingame then
		if t<1 and not showfinalscore then music(22) end

		if t>90 and btnp"4" and not showfinalscore then
			showfinalscore=true
			t=0
		end

		if t<1 and showfinalscore then music(21) end

	else

		menuitem(1,"restart mission",function() load_level() end)--menu

		--slight delay after blowing out pent
		if wintimer>0 then
			wintimer+=1
			if wintimer>=90 then
				fade=1
				wintimer=0
				calculate_score()
				t=0
				winlevel=true
			end
		end

		if tutorial then
			if btnp"4" then
				tutnum+=1
				tutorial=false
			end
		else
			--main game loop
			update_shake()
			check_active_object()
			update_player(player)
			--update enemies
			for o in all(enemies) do
				if not is_offscreen(o) then
					o.update(o)
				end
			end
			--check pathfinders
			update_pathfinders(enemies)
			update_camera()
		end
	end
end

function _draw()
	--fade in
	if fade>0 then
		if fade<9 and fadein==false then
			fillp(fades[fade])
			rectfill(0,0,cmaxx,cmaxy,0)
			fade+=1
			fillp()
			return
		else
 	 		fadein=true
 		end
 	end

	cls()

	if title then
		draw_wisp()
		boldprint("willo",54,54)
		if t>90 then boldprint("press \x8e/z to start",28,100) end

	elseif winlevel then

		draw_score_background()
		reset_pal()
		for f in all(fx) do --draw fx
			f.draw(f)
		end
		draw_scoresheet()

	elseif wingame then

		draw_score_background()
		if not showfinalscore then draw_ending() end
		reset_pal()
		for f in all(fx) do
			f.draw(f)
		end
		if showfinalscore then draw_final_score() end

	else
		camera(camx,camy)

		--draw floor
		rectfill(camx,camy,cmaxx,cmaxy,2)
		--draw level -- 0x80 bitfield means only draw tiles with flag 7
		map(0,0,0,0,128,64,0x80)

		--draw things on floor
		draw_pentagram(pentagram)
		draw_highlights()

		--create list of things to be drawn
		local drawlist = {}
		add(drawlist,player)
		--draw enemies
		for o in all(enemies) do
				add(drawlist,o)
		end
		--draw objects
		for o in all(objects) do
			if o.name!="pentagram" then--pent is drawn seperately
				add(drawlist,o)
			end
		end

		drawlist=isorty(drawlist)--sort list by y

		for o in all(drawlist) do--draw it all baby
			if not is_offscreen(o) then
				o.draw(o)
			end
		end

		--draw all effects
		for f in all(fx) do
			f.draw(f)
		end

		draw_tutorials()

		camera()
	end
	 --fade in
	if fadein then
	 	fade-=1
		if fade>0 then
			fillp(fades[fade])
			rectfill(0,0,cmaxx,cmaxy,0)
			fillp()
		else
			fade=0
			fadein=false
		end
	end

end

function load_level()
	player,enemies,objects,fx,checkpoint,activeobj,t,timesspotted,timeshurt,flames={},{},{},{},{},false,0,0,0,0
	for k,v in pairs(scores) do
		v=0
	end

	--map data parse
	local ld =leveldata[level]
	local map,enlist,swlist = split(ld[1]),split(ld[2],":"),split(ld[4],":")

	--init cam boundaries from map data
	cminx,cminy,cmaxx,cmaxy,shkx,shky = map[1]*8,map[2]*8,map[3]*8-1,map[4]*8-1,0,0

	--init objects through map tiles
	for mx=map[1],map[3],1 do
		for my=map[2],map[4],1 do
			local sx,sy=mx*8+4,my*8+6
			local ref=mget(mx,my)
			if ref==16 then
				checkpoint = create_tomb(sx,sy)
				player = create_player(sx,sy+8)
			elseif ref==103 then
				create_tomb(sx,sy)
			elseif ref==7 then
				create_candle(sx,sy-4)
			elseif ref==121 then
				create_tree(sx,sy)
			elseif ref==40 then
				pentagram = create_pentagram(sx,sy-2)
			end
		end
	end

	--switches
	for s in all(swlist) do
		local t=split(s)
		create_switch(t[1],t[2],t[3],t[4])
		--reset all doors in case of retry
		for x=0,1 do
			for y=0,1 do
				mset(t[3]+x,t[4]+y,14+(y*16)+x)
			end
		end

	end
	--enemies
	for e in all(enlist) do
		spawn_guardpatrol(e)
	end

	--set camera
	camx=max(cminx,player.x-50)
	camy=max(cminy,player.y-64)

	--start music
	fade=1
	music(3)
end

function calculate_score()

	score.spdbonus=max(0,500-flr(t/30)*5) -- -5 pts per sec
	score.extinguished=100*flames --100pts per flame
	score.hurtpenalty=timeshurt*-300 --minus 300 pts per hit
	score.ghostbonus=ternary((timesspotted<1 and timeshurt<1),500,0)
	--add em up and 1000 for mission complete
	score.finalscore=max(0,1000+score.spdbonus+score.extinguished+score.hurtpenalty+score.ghostbonus)
	--save level score and medal
	local ld = leveldata[level]
	ld.score=score.finalscore

	local medalpoints = split(ld[3])

	if score.finalscore>=medalpoints[3] then
		ld.medal="platinum"
	elseif score.finalscore>=medalpoints[2] then
		ld.medal="gold"
	elseif score.finalscore>=medalpoints[1] then
		ld.medal="silver"
	else
		ld.medal="bronze"
	end
end


-->8
--camera

function update_camera()

	-- offset camera depending on which direction the player is facing
	local xoff = cos(player.dir)*15
	local yoff = sin(player.dir)*15
	-- choose a point in front of the player that is further away the faster the player is swimming
	local xpoint = max(cminx,player.x-64+(player.vx*10)+xoff)
	local ypoint = max(cminy,player.y-64+(player.vy*10)+yoff)
	--smoothly move camera towards this point
	camx += (xpoint-camx)*0.1
	camy += (ypoint-camy)*0.1
	--stop camera from going out of bounds
	if camx>cmaxx-127 then camx=cmaxx-127 end
	if camy>cmaxy-127 then camy=cmaxy-127 end
	if camx<cminx then camx=cminx end
	if camy<cminy then camy=cminy end
	--apply shake
	camx +=shkx
	camy +=shky
end

--update shake functions
function update_shake()
 if abs(shkx)+abs(shky)<0.5 then
  shkx,shky=0,0
 else
  shkx*=-0.5-rnd(0.2)
  shky*=-0.5-rnd(0.2)
 end
end

function add_shake(p)
 local a=rnd(1)
 shkx+=p*cos(a)
 shky+=p*sin(a)
end


-->8
--includes

--[[
map data: cminx,cminy,cmaxx,cmaxy,plx,ply
enemies: type,x,y,time,direction,x,y,time,dir... (dirs: E=0,NE=1,N=2,NW=3,W=4,SW=5,S=6,SE=7)
medalpoints: silver,gold,plat
switches: mapx,mapy,doorx,doory
]]
leveldata ={
	{--level 1
		"0,0,48,16,3,9",
		"0,38,3,120,2,38,14,120,6",
		"1250,1600,2250"
	},
	{--level 2
		"48,0,64,32,61,30",
		"0,56,11,45,5,56,11,45,6,56,11,45,7,56,11,45,6:0,53,21,0,0,61,21,0,6,61,25,0,4,53,25,0,2",
		"1250,2000,2250"
	},
	{--level 3
		"64,32,128,48,66,46",
		"0,79,38,120,3,79,38,120,1:0,96,45,30,6,96,38,0,4,91,38,0,6,91,45,0,4,87,45,0,2,87,36,30,2,87,45,0,0,91,45,0,2,91,38,0,0,96,38,0,6:0,115,40,90,6,115,40,90,4,115,40,90,2,115,40,90,0:0,121,40,90,4,121,40,90,2,121,40,90,0,121,40,90,6",
		"1500,2000,2450",
		"68,40,70,39:94,44,100,42:118,38,106,42:115,33,106,39:124,38,106,36"
	},
	{--level 4
		"64,0,96,32,67,3",
		 "0,67,18,90,6,67,14,0,2,65,12,0,2,67,7,90,2,65,12,0,6,67,14,0,6:0,73,10,0,2,73,6,0,0,85,6,0,6,85,2,0,4,77,2,0,6,77,5,0,0,80,10,0,4:0,91,6,45,5,91,6,45,6,91,6,45,7,91,6,45,6:0,70,23,0,0,74,23,0,6,74,29,0,0,78,29,0,2,78,23,0,4,74,23,0,6,74,29,0,4,70,29,0,2",
		"1500,2250,2950",
		"67,1,85,20"
	},
	{--level 5
		"48,32,64,64,61,62",
		"1,53,51,0,0,58,51,0,0,58,42,0,0,53,42,0,0:0,55,44,60,6:0,55,47,60,2",
		"1500,2200,2700",
		"49,39,50,48"
	},
	{--level 6
		"64,48,128,64,124,56",
		"0,116,54,45,6,116,57,45,2:1,107,51,0,0,107,61,0,0:1,90,61,0,0,90,51,0,0:0,84,54,45,6,84,57,45,2:1,73,48,0,0,73,63,0,0:0,76,53,60,2,71,53,0,6,71,57,0,0,76,57,60,6,71,57,0,2,71,53,0,0",
		"1500,2200,2700",
		"69,54,66,52"
	},
	{--level 7
		"96,0,128,32,101,13",
		"1,101,5,0,0,121,5,0,0,121,26,0,0,101,26,0,0:1,121,26,0,0,101,26,0,0,101,5,0,0,121,5,0,0:0,100,2,90,4,105,2,90,0:0,110,6,0,0,121,6,0,6,121,9,0,4,110,9,0,2:0,120,15,60,2,120,15,60,3,120,15,60,4,120,15,60,3:0,120,20,60,4,120,20,60,5,120,20,60,6,120,20,60,5:0,116,21,90,1,111,26,90,5",
		"1500,2150,2700",
		"102,20,101,14"
	},
	{--level 8
		"0,16,48,64,2,18,576,288",
		"0,22,50,60,6,22,50,60,5:0,25,50,60,6,25,50,60,7:1,30,56,0,0,42,56,0,0:0,44,50,60,5,44,50,60,6,44,50,60,7,44,50,60,6:0,2,36,0,0,13,36,0,2,13,27,0,4,2,27,0,6:0,9,31,0,6,9,36,0,4,6,36,0,2,6,31,0,0:0,2,19,0,6,2,22,0,0,7,22,0,2,7,19,0,4:0,38,32,30,0,38,32,30,2,38,32,30,4,38,32,30,6,42,32,30,0,42,32,30,2,42,32,30,4,42,32,30,6:0,42,23,90,6,45,23,90,6",
		"1750,2250,2800",
		"44,45,23,48:12,17,18,38:36,17,18,34"
	}
}


function create_player(x,y)
	local p = {
		state="idle",
		x=x,
		y=y,
		vx=0,
		vy=0,
		accel=0.4,
		deccel=0.8,
		topspeed=1,
		dir=0,
		faceleft=false,
		sprite=1,--use this for draw sprite
		bob=0, --use this to implement a bob
		timer=0,
		actionready=false, -- to stop player from spamming candles
		wooready=true,--stop player from spamming woos
		usingpower=false,
		blinktimer=rnd(60)+90, -- random blink timings
		draw=draw_player,
		wootimer=60, -- time limit for woo
		woocounter=60 -- counter for woo
	}
	p.hitbox=function()
		return new_box(p.x-4,p.y-6,p.x+5,p.y+2)
	end
	return p
end

function update_player(p)
	-- these variables are candidate velocities, and initial state
	local movx,movy,state = 0,0,p.state

	--increment bob
	p.bob+=0.02
	if p.bob >=100 then p.bob=0 end

	--cache input
	local bl,br,bu,bd,bx,bz
	if btn"0" then bl=true end
	if btn"1" then br=true end
	if btn"2" then bu=true end
	if btn"3" then bd=true end
	if btn"4" then bz=true end
	if btn"5" then bx=true end

	--stop woo and action spam
	if not bx then p.wooready=true end
	if not bz then p.actionready=true end

--enter state machine
--------------------------------
	if state=="idle" then
		p.sprite=1--reset to base sprite

		--movement
		if bl or br or bu or bd then
			change_state(p,"moving")
		end

		--override movement with action if button pressed
		if bz and activeobj then
			change_state(p,"action")
		elseif bx and p.wooready then
			change_state(p,"woo")
		end
	end

	------------------
	if state=="moving" then
		--add velocity according to button press
		if bl then movx-=p.accel p.faceleft=true end
		if br then movx+=p.accel p.faceleft=false end
		if bu then movy-=p.accel end
		if bd then movy+=p.accel end

		--set direction of face
		set_player_dir(p,bl,br,bu,bd)
		--idle
		if not (bu or bd or bl or br) then change_state(p,"idle") end

		--override movement with action if button pressed
		if bz  and activeobj then
			change_state(p,"action")
		elseif bx and p.wooready then
			change_state(p,"woo")
		end

	end
	-------------------------------
	if state=="action" then
		if bz then
			p.sprite=44
			--toggle candle if near candle
			for o in all(objects) do
				if o.active then
					--extinguish candle
					if o.name=="candle" and o.lit and p.actionready then
						flames+=1
						o.lit=false
						sfx(61)
						add_shake(1)
						--flare and smoke
						create_particle(o.x,o.y-10,0,0,3)
						o.smoketimer=20
						p.actionready=false
					elseif o.name=="switch" and p.actionready then
						add_shake(2)
						o.on=not o.on
						p.actionready=false
						--swap map tiles to open door
						local x,y,open=o.sx,o.sy,o.on
						mset(x,y,ternary(open,101,14))
						mset(x+1,y,ternary(open,0,15))
						mset(x,y+1,ternary(open,46,30))
						mset(x+1,y+1,ternary(open,47,31))
						--move baddies out the way
						if not open then
							for e in all(enemies) do
								if dist(e.x,e.y,x*8+8,y*8+8)<12 then
									e.y=y*8-6
								end
							end
						end
						--door dust
						create_particle(x*8+6,y*8+16,-0.07,-0.1,1)
						create_particle(x*8+10,y*8+16,0.07,-0.1,1)
						sfx(60,0,8)
					--hide in tomb
					elseif o.name=="tomb" and p.actionready then
						p.actionready=false
						use_tomb(o)
					--hold pentagram
					elseif o.name=="pentagram" then
						o.hold=true
						o.holdtimer+=0.5
						if o.holdtimer==50 then
							--kaboom
							sfx(60)
							add_shake(10)
							nuke(o)
							for e in all(enemies) do
								nuke(e)
								del(enemies,e)
							end
							wintimer=1
							o.won=true
						end
					end
				end
			end
		else
			--reset pentagram if not being held (this is a hack)
			pentagram.hold=false
			change_state(p,"idle")
		end
	end
---------------------
	if state=="woo" then
		--go woo
		p.usingpower=true
		p.wooready=false
		if p.woocounter>0 then
			if p.woocounter==p.wootimer then
				sfx(56)
				p.sprite=3 --change player sprite
				alert_enemies(70)
			end
			--decrease timer
			p.woocounter-=1
		else
			--reset
			p.usingpower=false
			p.woocounter=p.wootimer
			change_state(p,"idle")
		end
	end
---------------------
	if state=="hurt" then
		p.sprite=5
		--reset pentagram if not being held (this is a hack)
		pentagram.hold=false
		--pause after hurt
		if p.timer>0 then
			p.timer-=1
		else
			--reset power counter to fix bug where willo is hurt mid woo
			p.woocounter=p.wootimer
			p.usingpower=false
			create_explosion(p.x,p.y,20,1)
			use_tomb(checkpoint)
		end
	end
	--------------------
	if state=="hidden" then
		set_player_dir(p,bl,br,bu,bd) --let camera still work
		if bz and p.actionready then
			use_tomb(checkpoint)
		end
	end
	--------------------
	--apply candidate velocities to x,y
	update_movement(p,movx,movy,true)
	--sparkle
	if t%10==0 and state!="hidden" then
		local xoff = ternary(p.faceleft,6,-10)
		create_particle(p.x+rnd(3)+xoff,p.y+rnd(4)-6,0,-0.2)
	end
end

function set_player_dir(p,bl,br,bu,bd)
		if bu and not(bl or br or bd) then p.dir = 0.25 end
		if br and not(bu or bl or bd) then p.dir = 0 end
		if bd and not(bl or bu or br) then p.dir = 0.75 end
		if bl and not(bd or br or bu) then p.dir = 0.5 end
		--diagonal directions
		if (bu and br) and not(bl or bd) then p.dir = 0.125 end
		if (br and bd) and not(bl or bu) then p.dir = 0.875 end
		if (bd and bl) and not(br or bu) then p.dir = 0.625 end
		if (bl and bu) and not(br or bd) then p.dir = 0.375 end
end

function draw_player(p)
	local yoff=sin(p.bob)*1.8--used for bobs
	local px,py,state,faceleft=p.x,p.y,p.state,p.faceleft
	--blink timer
	p.blinktimer-=0.5
	if p.blinktimer <=0 then p.blinktimer=rnd(60)+90 end

	if state=="hidden" then
		--hidden, dont draw anything mate
	else
		if state=="woo" then
			local x = ternary(faceleft,-28,10)
			boldprint("wooo!",px+x,py-12+yoff*2,7)
			if t%2==0 then
				fillp(fades[3])
				circ(px,py,70,7)
				fillp()
			end
		end

		if state=="moving" then yoff*=1.4 end --bob more if moving
		--draw outline of willo
		drawoutline(p.sprite,px-8,py-13+yoff*0.5,2,2,faceleft,false,1,true)
		--blink
		if p.blinktimer<4 then
			pal(10,7)
		else
			pal(10,0)
		end
		--draw main body
		spr(p.sprite,px-8,py-13+yoff*0.5,2,2,faceleft,false)
	end
	reset_pal()
end

function hurt_player()
	sfx(57)
	player.timer=40
	add_shake(10)
	timeshurt+=1
	change_state(player,"hurt")
end


--take a string of coords and produce a guard with those coords as waypoints, note d is an int comverted to an angle
--eyeball,x,y,t,d then x,y,t,d
function spawn_guardpatrol(string)
	local table = split(string)
 	local o = create_skeleton(table[2]*8,table[3]*8+4)
 	--1 in first index creates an eyeball
 	if table[1]==1 then
		o.name="eyeball"
		o.bob=0
		o.update=update_eyeball
		o.draw=draw_eyeball
		o.deccel=0.6
	end
	--add waypoints to enemy
	o.waypoints={}
	for i=2,#table,4 do
	 	local point={x=table[i]*8+4,y=table[i+1]*8+4,t=table[i+2],d=table[i+3]*0.125}--*0.125 turns ints 1-8 into angles
	 	add(o.waypoints,point)
	end
	return o
end

function create_skeleton(x,y)
	local o = {
		name="guard",
		state="patrol",
		x=x,
		y=y,
		vx=0,
		vy=0,
		accel=0.1,
		deccel=0.8,
		topspeed=3,
		facedir=0, --direction of face, 0 is facing right, 0.25 up, 0.5 left, 0.75 below
		alert=0, --how alerted they are to player
		indicatorcol=3, -- colour of indicators threat level
		bodyflip=false,--flipping body to make run animation
		canseeplayer=false,
		searchtime=240,--length that wil search for player
		targ={}, --target for follow
		nextpathval=1, -- next path value for following path, ref for path table
		path={},--path for way finding
		nextwayval=1, --target for next waypoint, reference for waypoint table
		waytimer=0, -- timer for waypoint dwelling
		update=update_guard,
		draw=draw_guard
		}
		o.hitbox=function()
			return new_box(o.x-3,o.y-3,o.x+3,o.y+3)
		end
	add(enemies,o)
	return o
end

function update_guard(o)
	local movx,movy,state=0,0,o.state

	--set variables depending on next waypoint
	local nextwaypoint = o.waypoints[o.nextwayval] -- cache next waypoint for returning behaviour
	--variable for determing where guard should look, default is current view
	local facetarg = o.facedir
	--check if can see player
	o.canseeplayer=check_canseeplayer(o)
	--draw sightlines if can see
	if o.state !="hostile" and o.state != "hitplayer" and o.state!="spotted" then
		update_sightlines(o)
	end
----------------------------------------------
	--enter state machine
	if state=="patrol" then
		o.indicatorcol=3
		--if you are far away from waypoint then move towards it
		if dist_obj(o,nextwaypoint)>3 then
			--move
			movx,movy = get_vector(nextwaypoint,o)
			movx*=o.accel
			movy*=o.accel
			--face towards new direction
			facetarg = get_angle(o,nextwaypoint)
		else
		--when at waypoint
			if o.waytimer<=0 then
				--move to next way point or back to first
				if o.nextwayval==#o.waypoints then
					o.nextwayval=1
				else
					o.nextwayval+=1
				end
				--set timer to new waypoint timer
				o.waytimer=o.waypoints[o.nextwayval].t
			else
				--decrease waytimer and face in waypoint's direction
				o.waytimer-=1
				facetarg = nextwaypoint.d
			end
		end
	----------------------
	elseif state=="suspicious" then
		--if lost sight from hostile, then have a guess where player might be
		if o.lostsight then
			o.timer-=0.5
			if o.timer<=0 then
				o.lostsight=false
				repath_guard(o,player)
			end
		end
		--if no path, then put guard in pathfinding queue
		if #o.path<1 then
			o.pathfinding=true
			facetarg=o.facedir -- maintain constant direction
		else --follow to targey point
			facetarg = get_angle(o,o.path[o.nextpathval])
			movx,movy = follow_path(o,ternary(o.lostsight,"suspicious","searching"))
		end
	----------------------
	elseif state=="spotted" then
		o.indicatorcol = 8
		o.timer-=0.5
		if o.timer<=0 then --slight delay before attack
			change_state(o,"hostile")
		end
	--------------------
	elseif state=="hostile" then
		o.accel=0.25 --speed up
		o.alert=0
		o.indicatorcol = 8
		if o.canseeplayer then
			o.targ = player
			--apply velocity towards targ
			movx,movy = get_vector(o.targ,o)
			movx*=o.accel
			movy*=o.accel
	 		facetarg = get_angle(o,o.targ)
 		else
 			o.path={} --if loses sight, get suspicious
 			o.lostsight=true
 			o.timer=30
 			sfx(59)
			change_state(o,"suspicious")
 		end
	-----------------------
	elseif state=="searching" then
		if o.timer==240 then sfx(59) end
		o.accel=0.1
		o.indicatorcol = 9
		o.timer-=1
		o.lostsight = false
		facetarg=o.facedir -- maintain constant direction
		--return to patrol and reset variables if search at end
		if o.timer <=0 then
			change_state(o,"returningtopatrol")
			repath_guard(o,nextwaypoint)
		--face random direction every 2 secs
		elseif o.timer%60==0 and not o.canseeplayer then
			facetarg=(flr(rnd(8))*0.125)
		end
	-----------------------
	elseif state=="returningtopatrol" then
		o.indicatorcol=3
		if #o.path==0 then
			o.pathfinding=true
		else
			facetarg = get_angle(o,o.path[o.nextpathval])
			movx,movy = follow_path(o,"patrol") --trudge back to next waypoint
		end
	----------------------
	elseif state=="hitplayer" then
		o.timer-=0.5
		--after delay, go home
		if o.timer<=0 then
			o.accel=0.1
			change_state(o,"returningtopatrol")
			repath_guard(o,nextwaypoint)
		end
	-----------------------
	elseif state=="alerted" then
		o.indicatorcol = 9
		o.timer-=0.5
		if o.timer<=0 then change_state(o,"suspicious") end
	end
	--end of state machine
	-----------------------

	--change face based on target position  (e.g. face target)
	facetarg+=0.062 -- buffer for smoothness
	if facetarg>=1 then facetarg-=1 end -- wrapping around 0
	o.facedir = (flr(facetarg/0.125))*0.125 -- set view to target

	--move
	update_movement(o,movx,movy,true)

	--deal with payer collisions unless already hit
	if player.state !="hurt" and  player.state!="hidden" then
		collide_player(o)
	end
end

function draw_guard(o)
	local fd,state,x,y=o.facedir,o.state,o.x,o.y
	local headflip = ((0.625>=fd)and(fd>=0.25))
	local headspr=ternary((fd>0 and fd<0.5),48,49) --set headsprite
	local bodyspr=ternary(state=="spotted",33,32)
	local bodyy=ternary(state=="spotted",4,2)

	--walk animation body sprite
	if abs(o.vx)+abs(o.vy)/2>0.1 then bodyspr=34 end
	--walk animation speed
	local wspd = ternary(o.accel>=0.25,3,10)
	if t%wspd==0 then o.bodyflip = not o.bodyflip end

	drawoutline(bodyspr,x-3,y-bodyy-3,1,1,o.bodyflip) --body
	drawoutline(headspr,x-3,y-15,1,1,headflip,false,true) --head
	pal(10,0)
	spr(headspr,x-3,y-15,1,1,headflip)
	reset_pal()

	--emotion embelishments
	if state=="spotted" then
		sspr(80,8,2,8,x,y-25)
	elseif state=="searching" or state=="alerted" then
		sspr(83,8,5,8,x-1,y-25)
	end

	--draw direction of face as circle
	local fx = cos(fd)
	local fy = sin(fd)
	circfill(x+fx*10,y+2+fy*10,1.5,o.indicatorcol)

	--draw sightlines
	if o.alert>0 and o.canseeplayer and state!="hostile" then
		local vx,vy = get_vector(player,o)
		local col=ternary(state=="spotted",8,7)
		for i=0, o.alert,8 do
			circfill(x+i*vx-1,y+i*vy+1,1.5,0)
			circfill(x+i*vx,y+i*vy,1.5,col)
		end
	end
	--draw guard path and/or target  for debugging
	--[[
	if #o.path>0 then
		for i=1,#o.path do
			pset(o.path[i].x,o.path[i].y,10)
		end
	end

	--draw guard target
	--circ(o.targ.x,o.targ.y,2,o.indicatorcol)
	]]
	--peripheral sensors
	--[[
	local lx,ly = cos(o.facedir+0.125)*16,sin(o.facedir+0.125)*16
	local rx,ry = cos(o.facedir-0.125)*16,sin(o.facedir-0.125)*16

	circ(o.x+lx,o.y+ly,12,8)
	circ(o.x+rx,o.y+ry,12,9)
	]]
end

--little function to save tokens
function repath_guard(o,targ)
	o.path={}
	o.targ=targ
end

function update_eyeball(e)
	--increment bob
	e.bob+=0.02
	if e.bob >=1 then e.bob=0 end

	if dist_obj(player,e)<50 and player.state!="hidden" then
		--alert increase if player in range and not already spotted
		if not e.canseeplayer then
			e.alert+=0.5
			if e.alert==1 then sfx(55) end
		end
		e.indicatorcol=9
		--look at player
		e.facedir = (flr((get_angle(e,player)+0.062)/0.125))*0.125
	else
		--reduce alert if player outof range
		e.indicatorcol=3
		if e.alert>0 then
			e.alert-=0.5
		else
			e.alert=0
		end
		--spin on spot
		if t%8==0 then
			e.facedir+=0.125
		end
	end
	--spot player
	if e.alert>=50 and not e.canseeplayer then
		e.canseeplayer=true
		sfx(54)
		timesspotted+=1
		add_shake(1)
		alert_enemies(126)
	end

	if e.canseeplayer then
		e.indicatorcol=8
		e.searchtime-=2
		if e.searchtime<=0 then
			e.canseeplayer=false
			e.indicatorcol=3
			e.searchtime=240
		end
	end
	--reset to 0
	if e.facedir>=1 then e.facedir = 0 end

	local movx,movy,nextwaypoint=0,0,e.waypoints[e.nextwayval]
	--path to waypoints
	if dist_obj(e,nextwaypoint)>3 then
			--move
			movx,movy = get_vector(nextwaypoint,e)
			movx*=e.accel
			movy*=e.accel
	else
		if e.nextwayval==#e.waypoints then
			e.nextwayval=1
		else
			e.nextwayval+=1
		end
	end

	update_movement(e,movx,movy)

	--deal with payer collisions unless already hit
	if player.state !="hurt" or player.state!="hidden" then
		collide_player(e)
	end
end

function draw_eyeball(e)
	local yoff=sin(e.bob)*1.2--used for bobs
	local x,y,fd=e.x,e.y,e.facedir
	--radius
	if t%2==0 then
		circ(x,y,50,e.indicatorcol)
		if e.alert>0 then
			circ(x,y,e.alert,e.indicatorcol)
		end
	end

	drawoutline(12,x-7,y-17+yoff,2,2)

	pal(10,0)
	pal(3,e.indicatorcol)
	if fd==0 then
		sspr(88,8,4,7,x+4,y-13+yoff) --look e
	elseif fd==0.5 then
		sspr(88,8,4,7,x-7,y-13+yoff,4,7,true) --look w
	elseif fd==0.625 then
		spr(27,x-7,y-11+yoff,1,1,true) --look sw
	elseif fd==0.75 then
		spr(27,x-3,y-10+yoff) --look s
	elseif fd==0.875 then
		spr(27,x,y-11+yoff,1,1) --look se
	end

	reset_pal()
end

function collide_player(o)
	if player.state!="hurt" and coll(o.hitbox(),player.hitbox()) then
		o.timer=30

		local vx,vy = get_angle(player,o)

		player.vx = sin(vx)*10
		player.vy = cos(vy)*10
		o.indicatorcol=8

		o.targ={x=o.x,y=o.y}
		change_state(o,"hitplayer")
		hurt_player()
	end

end


--check view cone and change to hostile if can see player and alert is high
function update_sightlines(o)
	local d = dist_obj(o,player)
	--update alert level
	if o.canseeplayer then
		o.alert+=1.2
	elseif o.alert >0 then
		o.alert-=0.5
	else
		o.alert=0
	end

	if o.alert>=d and o.canseeplayer then
		o.targ = {x=player.x,y=player.y}
		o.timer=10
		sfx(58)
		timesspotted+=1
		change_state(o,"spotted")
		add_shake(1)
	end
end

--returns true if o can see player
function check_canseeplayer(o)
	local insight=false
	if dist_obj(o,player) <100 and player.state!="hidden" then
		--check is within angle of view cone
		local a = get_angle(o,player)
		local face = o.facedir

		--look at where guard is facing, and check the cone according to that angle (face==0 is edge case)
		if (face-0.125<=a and a<=face+0.125 and face>0 ) or (face==0 and not (a>=0.125 and a<=0.875)) then
			--check line of sight
			insight=can_see(o,player)
		else
			--check peripheries
			local lx,ly = cos(o.facedir+0.125)*16,sin(o.facedir+0.125)*16
			local rx,ry = cos(o.facedir-0.125)*16,sin(o.facedir-0.125)*16
			if dist(o.x+lx,o.y+ly,player.x,player.y)<=15 or dist(o.x+rx,o.y+ry,player.x,player.y)<=15 then
				insight=can_see(o,player)
			end
		end
	end
	return insight
end
--alert all enemies in given distance
function alert_enemies(dist)
	for enemy in all(enemies) do
		if dist_obj(enemy,player)<dist and enemy.state!="hostile" and enemy.name!="eyeball" then
			enemy.targ={x=player.x,y=player.y}
			enemy.path={} --clear existing enemy path
			enemy.timer=30
			change_state(enemy,"alerted")
		end
	end
end

function follow_path(o,nextstate)
	--set previous waypoint at target
	local np = o.path[o.nextpathval]
	--move to points
	local movx,movy = get_vector(np,o)
	movx*=o.accel
	movy*=o.accel
	--when arrive at waypoint change to next way point, or return to patrol
	if dist_obj(np,o)<=2 then
		if o.nextpathval==#o.path then
			o.path={}
			o.nextpathval=1
			o.targ={}
			o.timer=ternary(nextstate=="searching",o.searchtime,0) --reset search timer
			change_state(o,nextstate)
		else
			o.nextpathval+=1
		end
	end
	return movx,movy
end


--create candle
function create_candle(x,y)
	local o={
		name="candle",
		x=x,
		y=y,
		sprite=7+flr(rnd(3)),
		lit=true,
		t=0,
		flicker=true,
		active=false,
		smoketimer=0,--set by player script to time smoke release
		random=rnd(10,20),
		draw=draw_candle
	}
	add(objects,o)
	return o
end

function draw_candle(o)
	--draw button tip if active and not interacted
	if o.active and o.lit then
		draw_tooltip(o.x-3,o.y-18)
	end
	--draw candle stick
	drawoutline(o.sprite,o.x-4,o.y-7,1,1)
	--draw candle flame
	if o.lit then
		local s = ternary(o.flicker,10,11)
		o.t+=0.5
		if o.t>o.random then
			o.t=0
			o.flicker = not o.flicker
			o.random=rnd(10,20)
		end
		spr(s,o.x-3,o.y-13)
	end

	if o.smoketimer>0 then
		o.smoketimer-=1
		--smoke
		if o.smoketimer%4==0 then create_particle(o.x+rnd(2)-1,o.y-8,0,-0.5,2) end
	end
end

function create_pentagram(x,y)
	local o={
		name="pentagram",
		x=x,
		y=y,
		glow=0,
		hold=false,
		holdtimer=0,
		fiveflames={
			{x=x+4,y=y-18},
			{x=x+7,y=y-7},
			{x=x-3,y=y+2},
			{x=x-14,y=y-6},
			{x=x-10,y=y-19}
		},
		draw=draw_pentagram
	}
	for i in all(o.fiveflames) do
		i.random=rnd(10,20)
		i.flicker=true
		i.lit=true
		i.t=0
	end

	add(objects,o)

	return o
end

function draw_pentagram(p)
	palt(0,false)
	palt(10,true)
	if not p.won then
		p.glow+=0.015
		if p.glow>=1 then p.glow=0 end

		local glow=sin(p.glow)
		--pulsing glow
		if glow >=0.5 then
			pal(0,8)
		elseif glow>=0.3 then
			pal(0,2)
		elseif glow>=0 then
			pal(0,12)
		elseif glow>=-0.2 then
			pal(0,1)
		end

		spr(23,p.x-12,p.y-12,3,3)

		reset_pal()
		--draw flames
		local flames=p.fiveflames
		if p.hold then
			local fl=min(5,(flr(p.holdtimer/9)+1))
			local flame=flames[fl]
			if flames[fl].lit then
				flames[fl].lit=false
				sfx(61)
				create_particle(flame.x+3,flame.y+5,0,0,3)
				create_particle(flame.x+3,flame.y+5,0,-0.5,2)
			end
		else
			p.holdtimer=0
			for i in all(flames) do
				i.lit=true
			end
		end
		--draw lit flames
		for i in all(flames) do
			if i.lit then
				local s = ternary(i.flicker,10,11)
				i.t+=0.5
				if i.t>i.random then
					i.t=0
					i.flicker = not i.flicker
					i.random=rnd(10,20)
				end
				spr(s,i.x,i.y)
			end
		end
		--tool tip
		if p.active and not p.hold then
			local yoff= ternary(p.y<camy+23,17,-23)
			print("hold \x8e",p.x-14,p.y+yoff,7)
		end
	else
		spr(23,p.x-12,p.y-12,3,3)
	end
	reset_pal()
end

function create_tree(x,y)
	local r=1>=rnd(2)
	local o={
		name="tree",
		x=x,
		y=y,
		hflip=r,--randomly flip branches
		trunk=ternary(r,105,106),
		draw=draw_tree
	}
	add(objects,o)
	return o
end

function draw_tree(o)
	drawoutline(121,o.x-8,o.y-6,2,1)
	drawoutline(73,o.x-9,o.y-30,2,2,o.hflip)
	--draw trunk last
	spr(o.trunk,o.x-4,o.y-14)
end

function create_tomb(x,y)
	local o={
		name="tomb",
		x=x,
		y=y,
		active=false,
		hidefaceleft=true,
		draw=draw_tomb
	}
	add(objects,o)
	return o
end

function use_tomb(o)
	checkpoint=o
	if player.state!="hidden" then
		change_state(player,"hidden")
		sfx(62)
		player.x,player.y=o.x,o.y+8 -- player pops out bottom of tomb
	else
		change_state(player,"idle")
		sfx(63)
	end
	player.actionready=false
	create_explosion(o.x,o.y-15,10,0.5)
	add_shake(2)
end

function draw_tomb(o)
	local ox,oy=o.x,o.y
	--draw tomb
	drawoutline(71,ox-8,oy-22,2,3)

	if o.active then
		--if player near tomb
		if player.state!="hidden" then
			draw_tooltip(ox-4,oy-30)
		else --if player hiding in tomb
			drawoutline(16,ox-4,oy-18,1,1,false,false,true)
			--sparkle
			if t%10==0 then create_particle(ox+rnd(10)-5,oy+rnd(8)-24,0,-0.2) end

			pal(10,ternary(player.blinktimer<4,7,0))

			if t%30==0 then o.hidefaceleft=not o.hidefaceleft end
			local xoff= ternary(o.hidefaceleft,-5,-4)
			circ(ox-1,oy-15,4.5,6)
			spr(16,ox+xoff,oy-18,1,1,o.hidefaceleft)
			reset_pal()
		end
	end
end

--x,y,sx,sy are map tiles, sx, sy are top left of target door in map tiles
function create_switch(x,y,sx,sy)
	s={
		name="switch",
		x=x*8+4,
		y=y*8+8,
		sx=sx,
		sy=sy,
		on=false,
		draw=draw_switch
	}
	add(objects,s)
	return s
end

function draw_switch(s)
	local spr=ternary(s.on,63,62)
	drawoutline(spr,s.x-4,s.y-8,1,1)
end


function draw_tutorials()
	local t=tuts[tutnum]
	if tutnum<7 and dist(t[1],t[2],player.x,player.y)<20 then
		tutorial=true
		fillp(fades[5])
		rectfill(camx+2,camy+36,camx+124,camy+52,12)
		fillp()
		boldprint(t[3],camx,camy+42)
		draw_tooltip(camx+117,camy+50)
	end
end

function draw_tooltip(x,y)
	local yoff = ternary(tipbob,0,1)
	if not tipbob then
			print("\x8e",x,y,0)
	end
	print("\x8e",x,y-yoff,7)
	if t%10==0 then	tipbob=not tipbob end
end

function draw_scoresheet()
	boldprint("mission "..level.."/8: complete!",22,16)
	--draw scores
	if t>10 then boldprint("completion bonus: 1000",20,34) end
	if t>20 then boldprint("speed bonus: "..score.spdbonus,40,44) end
	if t>30 then boldprint("candle bonus: "..score.extinguished,36,54) end
	if t>40 then boldprint("hurt penalty: "..score.hurtpenalty,36,64) end
	if t>50 then boldprint("super ghost bonus: "..score.ghostbonus,16,74) end
	if t>70 then
		boldprint("final score: "..score.finalscore,20,90)
		local medal = leveldata[level].medal
		set_medal_cols(medal)
		local xoff=0
		if medal =="platinum" then
			xoff = -4
			--laurels for plat
			spr(38,91,92,1,2)
			spr(38,109,92,1,2,true)
		elseif medal =="gold" then
			xoff = 5
		end

		if t<71 then
			create_explosion(104,104,75,1.5,medal) --sparkles
		end

		--medal sprite
		spr(42,96,96,2,2)
		boldprint(medal,92+xoff,115,m)
		reset_pal()
	end

	if t>100 and t<110 then
		pal(10,7)
		pal(9,7)
		if t>108 then
		spr(42,96,96,2,2)

		elseif t>106 then
			dsspr"92,16,4,16,108,96,4,16"
		elseif t>104 then
			dsspr"88,16,4,16,104,96,4,16"
		elseif t>102 then
			dsspr"84,16,4,16,100,96,4,16"
		elseif t>100 then
			dsspr"80,16,4,16,96,96,4,16"
		end
		reset_pal()
	end
	--option to leave
	if t>120 then
		boldprint("\148  continue",18,104,7)
		boldprint("\131  retry",18,114)
		if contselect then
			rect(32,102,66,110)
		else
			rect(32,112,54,120)
		end
	end
end

function draw_ending()
	boldprint("congratulations!",32,7)
	boldprint("willo has saved his graveyard",6,32)
	boldprint("and stopped those naughty",6,44)
	boldprint("skelliwags from taking over",6,56)
	boldprint("maximum spooky!",33,86)
	drawoutline(3,56,98,2,2)
	if t>90 then draw_tooltip(116,118) end
end

function draw_final_score()
	reset_pal()
	boldprint("final ranking",38,7)

	for x=1,4 do
		for y=0,4,4 do
			local l =x+y
			local medal=leveldata[l].medal
			--draw one by one
			if l*6<t then
				boldprint(l,-2+x*26,20+y*7)
				set_medal_cols(medal)
				spr(42,-9+x*26,27+y*7,2,2)
				reset_pal()
				if medal=="platinum" then
					spr(38,-13+x*26,23+y*7,1,2)
					spr(38,3+x*26,23+y*7,1,2,true)
				end
			end
		end
	end
	--calculate final score
	local fscore = 0
	for i=1,8 do
		fscore+=leveldata[i].score
	end
	--calculate final medal
	local finalmedal="bronze"
	if fscore>=20800 then
		finalmedal="platinum"
	elseif fscore>=16650 then
		finalmedal="gold"
	elseif fscore>=11750 then
		finalmedal="silver"
	end
	if t>65 then
		boldprint("final score:",12,88)
		boldprint(fscore,24,97)
	end
	if t>70 then
		if t<71 then
			create_explosion(100,104,200,1.5,finalmedal)
		end

		set_medal_cols(finalmedal)
		dsspr"80,16,16,16,78,82,32,32"
		reset_pal()
		if finalmedal=="platinum" then
			dsspr"48,16,8,16,70,74,16,32"
			dsspr"48,16,8,16,118,74,-16,32"
		end
	end

	if t>130 then
		boldprint("thanks for playing!",26,119)
	end
end

function create_particle(x,y,vx,vy,type)
	p = {
		x=x,
		y=y,
		vx=vx,
		vy=vy,
		cols={7,6},
		size=1,
		age=0,
		maxage=30,
		draw=draw_particle
	}
	--1: door dust
	if type==1 then
		p.size=5
		p.cols=split"5,5,5,1"
		p.maxage=160
		p.age=90
	--2: smoke
	elseif type==2 then
		p.size=0.5
		p.cols=split"6,5,5"
	--3: candle flare
	elseif type==3 then
		p.size=2
		p.cols=split"8,9,8"
		p.maxage=10
	--pent explosion
	elseif type==4 then
		p.size=8
		p.cols=split"7,0,7,2,12,2,12,2,1"
	--zzzap
	elseif type==5 then
		p.zap=true
		p.cols=split"36,37,52,53"--actually sprite refs
	elseif type=="platinum" then
		p.cols=split"6,6,13"
		p.maxage=75
	elseif type=="gold" then
		p.cols=split"10,10,9"
		p.maxage=75
	elseif type=="silver" then
		p.cols=split"6,6,5"
		p.maxage=75
	elseif type=="bronze" then
		p.cols=split"4,4,11"
		p.maxage=75
	end
	add(fx,p)
end

function draw_particle(p)
	p.age+=1
	--kill if too old
	if p.age>=p.maxage then del(fx,p) end

	if p.zap then --zzap
		if t%3==0 then spr(p.cols[flr(p.age/7)],p.x,p.y) end
	else
		--set colour depending on age/maxage and num of cols
		local ci = 1+flr((p.age/p.maxage)*#p.cols)
		p.col = p.cols[ci]
		if p.age/p.maxage > 0.6 then p.fill = fades[4] end
		if p.age/p.maxage > 0.8 then p.fill = fades[2] end
		p.x+=p.vx
	 	p.y+=p.vy
	 	--actually draw
		if p.fill then fillp(p.fill) end
		circfill(p.x,p.y,p.size,p.col)
		fillp()
	end
end

function create_explosion(x,y,num,spd,type)
	for i=1,num do
		local a=rnd(1)
		local vx=cos(a)*rnd(spd)
		local vy=sin(a)*rnd(spd)
		create_particle(x+vx*8,y+vy*8,vx,vy,type)
	end
end

function nuke(e)
	create_explosion(e.x,e.y,5,0.2,4)
	create_explosion(e.x,e.y,5,3,5)
end

function drawoutline(n,x,y,w,h,flip_x,flip_y,dontdrawmain)
	for i=1,15 do
		pal(i,1)
	end
	for xx=-1,1 do
		for yy=-1,1 do
			if((abs(xx)+abs(yy))==1)spr(n,x+xx,y+yy,w,h,flip_x,flip_y)
		end
	end
	reset_pal()
	if not dontdrawmain then spr(n,x,y,w,h,flip_x,flip_y) end
end

function draw_highlights() --and shadows
	--enemy shadows
	for e in all(enemies) do
		spr(35,e.x-3,e.y-2)
	end
	for o in all(objects) do
		local ox,oy=o.x,o.y-3
		if o.name=="tree" then
			spr(35,ox,oy)
			spr(35,ox-8,oy)
			spr(35,ox-4,oy+2)

		end
		if o.name=="candle" then
			spr(35,ox-3,oy-1)
		end
		if o.name=="tomb" then
			spr(35,ox-4,oy+1)
		end
		if o.active and o.lit!=false and o.name!="pentagram" then
			spr(50,ox-7,oy,2,1)
		end
	end
end

function draw_wisp()
	--modified from @alexis_lessard
	--https://twitter.com/Alexis_Lessard/status/1312089894550990849
	local e=sin(t*.01+sin(t*.005))/4+1.8
	local x=64+12*sin(t*.015)
	local y=54+12*sin(t*.02)
	fillp(fades[2])
	circfill(x,y,40*e,12)
	fillp(fades[3])
	circfill(x,y,24*e,5)
	circfill(x,y,15*e,6)
	fillp()
	circfill(x,y,9*e,6)
	circfill(x,y,6*e,7)
	--draw face
	pal(10,0)
	sspr(14,4,7,3,-3+x+sin(t),-2+y+sin(t)*2)
end

function draw_score_background()
	draw_wisp()
	fillp(fades[3])
	rectfill(0,0,127,127,1)
	fillp()
end

function set_medal_cols(medal)
	local h,m,l = 7,6,13
	if medal =="gold" then
		m,l = 10,9
	elseif medal =="silver" then
		l = 5
	elseif medal =="bronze" then
		h,m,l= 9,4,11
	end
	pal(7,h)
	pal(10,m)
	pal(9,l)
end

function boldprint(str,x,y,col)
 c=col or 7
 for xx=-1,1 do
  for yy=-1,1 do
   print(str,x+xx,y+yy,0)
  end
 end
 print(str,x,y,c)
end
--new pal, changes light blue to deep purple
function reset_pal()
	pal()
	pal(12,130,1)
	pal(11,132,1)
end


function change_state(o,state)
	o.state=state
end

function update_movement(o,nx,ny,coll_walls)
	o.vx*=o.deccel
	o.vy*=o.deccel

 	o.vx+=nx
 	o.vy+=ny

 	local tpsp = o.topspeed
	o.vx=mid(o.vx,-tpsp,tpsp)
	o.vy=mid(o.vy,-tpsp,tpsp)

	if coll_walls then
 		local ox,oy=o.x,o.y

 		o.x+=o.vx

  		if wall_col(o) then
			o.x=ox
			o.vx*=0.2
  		end

  		o.y+=o.vy

  		if wall_col(o) then
   			o.y=oy
   			o.vy*=0.2
  		end
 	else
  		o.x+=o.vx
  		o.y+=o.vy
 	end
end

function new_box(x1,y1,x2,y2)
	return {x1=x1,y1=y1,x2=x2,y2=y2}
end

function wall_col(o)
	local hb = o.hitbox()
	local x1,x2,y1,y2=hb.x1,hb.x2,hb.y1,hb.y2

	return checkiswall(x1,y1)
		or checkiswall(x1,y2)
		or checkiswall(x2,y1)
		or checkiswall(x2,y2)

		or checkiswall((x1+x2)/2,y1)--top middle
		or checkiswall((x1+x2)/2,y2)--bottom middle
		or checkiswall(x1,(y1+y2)/2)--left middle
		or checkiswall(x2,(y1+y2)/2)--right middle
end

--check for collisions between 2 boxes
function coll(a,b)
  return not (a.x1>b.x2 or a.y1>b.y2 or a.x2<b.x1 or a.y2<b.y1)
end

function dsspr(string)
	local t=split(string)
	sspr(t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8])
end

--returns the distance between 2 objects with x y keys
function dist_obj(o,s)
	return dist(o.x,o.y,s.x,s.y)
end

function dist(xa,ya,xb,yb)
 if xb then xa=xb-xa ya=yb-ya end
 local d = max(abs(xa),abs(ya))
 local n = min(abs(xa),abs(ya)) / d
 return sqrt(n*n +1)*d
end

-- check if x,y is flag (0 default)
function checkiswall(x,y,flag)
	return fget(mget(flr(x/8),flr(y/8)),flag) --divide by 8 to return tile ref in map
end

function ternary(c,a,b)
	if c then return a else return b end
end

--return angle, 0/1 is right of o, 0.25 top, 0.5 left, 0.75 below
function get_angle(o,s)
	local opp,adj = s.x-o.x,s.y-o.y
	local a = atan2(opp,adj)
	return a
end

--check if near an object and set object to active
function check_active_object()
	local closest = 18
	local activeobject ={}
	for o in all(objects) do
		if o.name!="tree" and o.lit!=false then
			local d = dist_obj(player,o)
			if d<closest then
				closest=d
				activeobject=o
			end
			o.active=false
			activeobj=false
		end
	end
	if activeobject.name!=nil then
		activeobject.active=true
		activeobj=true
	end
end

function is_offscreen(o)
 if o.x<camx-96 or o.x>camx+223 or o.y<camy-96 or o.y>camy+223 then return true end
end

-- return normalised x and y vectors between 2 objects
function get_vector(o,s)
	local vx = (o.x-s.x)/dist_obj(o,s)
 	local vy = (o.y-s.y)/dist_obj(o,s)
 	return vx,vy
end

function isorty(t) --insertion sort, ascending y
    for n=2,#t do
        local i=n
        while i>1 and t[i].y<t[i-1].y do
            t[i],t[i-1]=t[i-1],t[i]
            i-=1
        end
    end
    return t
end


function update_pathfinders(enemies)
  local list={}
  for o in all(enemies) do
    if o.pathfinding==true then
      add(list,o)
    end
  end
  --just do one pathsearch per frame
  if #list>0 then
    local e=list[1]
    e.path=get_path(e.targ,e)
    if e.path==nil then
      change_state(e,"returningtopatrol")
      repath_guard(e,e.waypoints[e.nextwayval])
    end
    e.nextpathval=1
    e.pathfinding=false
  end
end

-- by @casualeffects
function get_path(from,to)
	local start = {x=flr(from.x/8), y=flr(from.y/8)}
	local goal  = {x=flr(to.x/8), y=flr(to.y/8)}
	local p = find_path(start, goal,
	              dist_obj,
	              flag_cost,
	              map_neighbors,
	              function (node) return shl(node.y, 8) + node.x end,
	              nil)
  if p!=nil then
  	for i=1,#p do
  		p[i].x = p[i].x*8+4
  		p[i].y = p[i].y*8+4
  	end
  end
	return p
end

function find_path(start,goal,estimate,edge_cost,neighbors, node_to_id, graph)

 local shortest,
 best_table = {
  last = start,
  cost_from_start = 0,
  cost_to_goal = estimate(start, goal, graph)
 }, {}

 best_table[node_to_id(start, graph)] = shortest

 local frontier, frontier_len, goal_id, max_number = {shortest}, 1, node_to_id(goal, graph), 32767.99

 while frontier_len > 0 do

  local cost, index_of_min = max_number
  for i = 1, frontier_len do
   local temp = frontier[i].cost_from_start + frontier[i].cost_to_goal
   if (temp <= cost) index_of_min,cost = i,temp
  end

  shortest = frontier[index_of_min]
  frontier[index_of_min], shortest.dead = frontier[frontier_len], true
  frontier_len -= 1

  local p = shortest.last

  if node_to_id(p, graph) == goal_id then

   p = {goal}

   while shortest.prev do
    shortest = best_table[node_to_id(shortest.prev, graph)]
    add(p, shortest.last)
   end

   return p
  end

  for n in all(neighbors(p, graph)) do

   local id = node_to_id(n, graph)
   local old_best, new_cost_from_start =
    best_table[id],
    shortest.cost_from_start + edge_cost(p, n)

   if not old_best then

    old_best = {
     last = n,
     cost_from_start = max_number,
     cost_to_goal = estimate(n, goal, graph)
    }

    frontier_len += 1
    frontier[frontier_len], best_table[id] = old_best, old_best
   end


   if not old_best.dead and old_best.cost_from_start > new_cost_from_start then

    old_best.cost_from_start, old_best.prev = new_cost_from_start, p
   end
  end

 end
end

function flag_cost(from, node)
	return (from.x-node.x)+(from.y-node.y)%2 ==0 and 1.4 or 1
end

function map_neighbors(node, graph)
 local neighbors,nx,ny = {},node.x,node.y
 if (not fget(mget(nx, ny - 1), 0)) add(neighbors, {x=nx, y=ny - 1})
 if (not fget(mget(nx, ny + 1), 0)) add(neighbors, {x=nx, y=ny + 1})
 if (not fget(mget(nx - 1, ny), 0)) add(neighbors, {x=nx - 1, y=ny})
 if (not fget(mget(nx + 1, ny), 0)) add(neighbors, {x=nx + 1, y=ny})
 --[[ diagonals]]
 if (not fget(mget(nx-1, ny - 1), 0)) add(neighbors, {x=nx-1, y=ny - 1})
 if (not fget(mget(nx+1, ny - 1), 0)) add(neighbors, {x=nx+1, y=ny - 1})
 if (not fget(mget(nx - 1, ny+1), 0)) add(neighbors, {x=nx - 1, y=ny+1})
 if (not fget(mget(nx + 1, ny+1), 0)) add(neighbors, {x=nx + 1, y=ny+1})

 return neighbors
end

function can_see(o,s)
	local grid_size,line_start,line_end,grid_matches,wall=8,{x=o.x,y=o.y},{x=s.x,y=s.y},{},false

	local points=get_intersections(line_start.x,line_start.y, line_end.x,line_end.y)


	for p in all(points) do
		local check={
     		x=flr(p.x/grid_size)*grid_size,
    		y=flr(p.y/grid_size)*grid_size
		}

		if not already_found(grid_matches,check) then
     		add(grid_matches,check)
 		end
	end

	for i in all(grid_matches) do
		if not wall then
			wall = checkiswall(i.x,i.y,1)
		else
		end
	end
	return not wall
end


 function already_found(t, chk)
     for p in all(t) do
         if p.x==chk.x and p.y==chk.y then
             return p
         end
     end

     return false
 end

 function get_intersections(x1, y1, x2, y2)
   local points,x,y,dx,dy = {},x1,y1,x2-x1,y2-y1
   local xstep, ystep, err, errprev, ddx, ddy

   points[#points + 1] = {x = x1, y = y1}

   if dy < 0 then
      ystep = -1
     dy = -dy
   else
     ystep = 1
   end

   if dx < 0 then
     xstep = -1
     dx = -dx
   else
     xstep = 1
   end

   ddx, ddy = dx * 2, dy * 2

   if ddx >= ddy then
     errprev, err = dx, dx
     for i = 1, dx do
       x = x + xstep
       err = err + ddy
       if err > ddx then
         y = y + ystep
         err = err - ddx
         if err + errprev < ddx then
           points[#points + 1] = {x = x, y = y - ystep}
         elseif err + errprev > ddx then
           points[#points + 1] = {x = x - xstep, y = y}
         else
           points[#points + 1] = {x = x, y = y - ystep}
           points[#points + 1] = {x = x - xstep, y = y}
         end
       end
       points[#points + 1] = {x = x, y = y}
       errprev = err
     end
   else
     errprev, err = dy, dy
     for i = 1, dy do
       y = y + ystep
       err = err + ddx
       if err > ddy then
         x = x + xstep
         err = err - ddy
         if err + errprev < ddy then
           points[#points + 1] = {x = x - xstep, y = y}
         elseif err + errprev > ddy then
           points[#points + 1] = {x = x, y = y - ystep}
         else
           points[#points + 1] = {x = x, y = y - ystep}
           points[#points + 1] = {x = x - xstep, y = y}
         end
       end
       points[#points + 1] = {x = x, y = y}
       errprev = err
     end
   end
   return points
 end



__gfx__
000000000000006666660000000000666666000000000066666600000000400000004000000040000001000000100000000006666600000022224444b4442222
0000000000000667777660000000066777766000000006677776600000f777f000ff7f000f7777f0001810000181000000067777776600001244bbcbcbbb4422
0070070000006677777760000000667777776000000066777777600000ffff00000ffff00fffff0001881000018810000067777777766000c4bbbbcbcbcbbb42
00077000000067777777660000006777777766000000677777776600000f7f00000f7f0000f77f00189981001889810006777777777766004bcbbbcbcbcbbbc4
000770000000677a777a760000666770777076600000677707077600000f7700000f770000ff7700189a8100189981000777777777777600bbbbcbcbcbcbcbcb
007007000000677a777a760006776770777076760000677007007600000f77000000770000f7770001881000018810006777777777777660bbbbcbbbcbcbcbcb
00000000000067e77777e600067777e77777e77600006ee7777ee600000f7700000777000ffffff000110000001100006777777777777660bbcbcbbbcbcbcbbb
000000000000677770077600006777777077777600006ee7707ee60000ff777000ff7ff00000000000000000000000006777777777777660bbcbc65bcb65cbbb
00777000000067767777766000067777777777600000676677777600aaaaf7aaaaaaaaaaaaaaaaaa88099999003330006777777777777660cbcbb55ccb55cbbc
07777700066677776777776000006777777776000006677767766600aaaaf7aa00000000aaf7aaaa88099999033333006677777777776660cbcbcbcccbcccbbc
7a77a770677777767777776000667777777776000666776677677600aaafff00aaaaaaaa00f77aaa88000099337a33300667777777766600cbcbbbcbcbcbcbbc
7a77a770067777777777760066777777777760006777777777766000aaaa00aaaaaaaaaaaa00aaaa8800999933aaa3300666777777666600cbbcbbcbcbcbbbbc
e7777e70006777777777600067777777777600000677777777776000aaa0a000aaaaaaaa000a0aaa88009900333a33300066666666666000bbbcbbcbcbcbbcbc
07777700000667777776000006677777776000000066677777760000aa0aaa0a0aaaaaa0a0aaa0aa00000000033333000006666666660000bbbcbbcbcbbbbcbb
00777000000066666660000000066666660000000000666666600000a0aaaa0aa0aaaa0aa0aaaa0a88009900003330000000066666000000c1cc1c1c1c1c1c1c
00000000000000000000000000000000000000000000000000000000a0aaaa0aaa0000aaa0aaaa0a880099000000000000000000000000001cc2c2c2c2c2c2c2
07777770700000070777777000000000000000000000000000000070a0aaaaa0aaa00aaa0aaaaa0a000099aaa77700000000006666660000c1cc222222222222
0700007070000007070000700c0c0c00000a000000000000000070700aaaaaa0a00aa00a0aaaaaa000099aaaaaa9700000000667777660001cc2c22222222222
700770070707707070077007c0c0c0c000a0a000a0000a00000060700aaaaaa00aaaaaa00aaaaaa00099aaaaaaaa97000000667777776000c1cc222222222222
7700007707777770700000770c01010c0a000a0a0a000000007066600aaaaa000aaaaaa000aaaaa0099aaaa777aaa97000006777777766001cc2c22222222222
000770000000000070077000c01010c00a0000a000000000006066000aaaa0aa0aaaaaa0aa0aaa70099a7a9aaa7aa9700000677777777600c1cc222222222222
0000000000077000000007000c01010ca0000000000000a000666000ffaa0aaa0aaaaaa0aaa0aaf799aaa9aaaaa7aa9700006770070076001ccccccccccccccc
007007007000000700700770c0c0c0c0a00000000000000006060000f700aaaa0aaaaaa0aaaa00f799a79aa9aa9a7a9a000067e77777e600c1cc1c1c1c1c1c1c
0770077077077077077000000c0c0c0000000000000000000d660000ff00000000000000000000ff99a79aa9aa9a7a9a00006767707776001cc2c22222222222
00666600006776000000007000700000000a000a000000a060600000a0aaaaaaa0aaaa0aaaaaaa0a99a79a9aaaa97a9a000667767777776000688d00006ddd00
0677776006777760000070007000700000a0a0000000000a66600000a0aaaaaaa0aaaa0aaaaaaa0a99a79aaaaaaa7a9a0666776777777760068e88d006d00dd0
6777777667777776007000700070007000000a00000000000d600000aa0aaaaaaa0aa0aaaaaaa0aa99aaa9aaaaa7aa9a67777777777776000d8882d00dd00dd0
677777776aa777aa7000700070007000a000a0000000000060600000aaa0aaaaaa0aa0aaaaaa0aaa099a7a9aaaaaa9a006777777777760000dd82dd00dd00dd0
677777776aa7a7aa0070007000700070000a000000000000d6600000aaaa00aaaa0aa0aaaa00aaaa099aaaa999aaa9a000666777777600000dd00dd00dd66dd0
66666676667777767000700070007000a0a0a0a0a00000000d600000aaaaaa00aaaf7aaa00aaaaaa0099aaaaaaaa9a0000006666666000000dd00dd00d6766d0
067777700077777000700070007000000a000a0a0a00000000600000aaaaaaaa000f7000aaaaaaaa00099aaaaaa9a00000000000000000000cd00dc00c6665c0
00067600007070700000700070000000000000000a00000000d00000aaaaaaaaaaff7faaaaaaaaaa000099aaaaaa0000000000000000000000cddc0000c55c00
222222222222222222dddd22dddd22222222222244b1c44b4444444b000000ddd000000000b000000b00b0b0444c115151515444444224444442244444422444
222222222222c2222d5ddd12ddd5d222222222224bcc14bc4bbbbbbc000000d510000000000b000000cb0b00bbb1c115151514bb4bb1c4bbbbbc14bbbbbc14bb
2222222222e222122ddddd11dddd5222222222224bc1c4bc4bb4cbbc0000dd55515000000000c0b000000b00bbcc1151515154bc4bcc14bcbbc1c4bcbbc1c4bc
22222222221c21c22d5555115555d2222cc222224bcc14bc4bbccbbc000d00d5100500000b000b00b0000c00ccc1c11515151bcc4bb1cbcccccc1bcccccc14bb
22c2222222222c2225555551555552222222c1224bc1c4bc4bbbbbbc00d000d510005000b000b0000b0000b0cc1c115151515bbc4bbc11c1c1c1c1c1c1c1c4bb
22222222222222222555115555555222222222224bcc14bc4bbbbbbc00d000d5100050000b000bc000b000bb11111115151511114bbc111111111111111114bb
222222222cc2222222d5555555555222222222224bc1c4bcbcccccccdd5ddd5555dd5dd000b0b0000b0c0c0011111151515151114bcc111111111111111114bc
2222ccc222222ccc2dd511115115522222222222bc1c1bc11c1c1c1c55555551d555555000b00b0000b000001515151515151515bccc11151515151515151bcc
2cc222222222222c1d555555555551221c1c1c1c44b1c44b1444444b1151115dd51151100b000b000c0000b05151515151515151444c11515151515151515444
22221c22c22222221555115111155122c1c1c1c14bcc14bc14bbbbbc0010005550001000b0000b0b0c000b0015151515151515154bb1c11515151515151514bb
222222222222cc2215555555555551121cccccccccc1cccccccccccc001000d510005000b00000c0b0000c0051515151515151514bbc115151515151515154bb
2211c22222e222221551555555515111c1c2c2c2cccc1ccccccccccc000500d5100500000b0b0b0b0cbcb00044411515151514444bc1c11515151515151514bc
222222222211c22211555155155151121ccc2c2c44b1c4441444444b000055d51110000000bc00cb0b0b0bbbbbbc1151515154bb4bbc115151515151515154bb
c22221c2222222e21111111111111111c1c2c2224bcc14bc14bbbbbc000000d510000000000bbcbbb0bbc000bbc1c115151514bc4bb1c11515151515151514bb
222222222222221121111111111111121ccc2222c1c1c1c1cccccccc000000d5100000000000bbccbbccc000cccc115151515bcc4bcc115151515151515154bc
2222222222cc22222221212121212121c1c2c2221c1c1c1c1c1c1c1c000000d51000000000000bbbbbbc0000ccc1c11515151cbcbcc1c1151515151515151bcc
22222222222222222222ddddddd2222222222222222222221111111100000d55511000001bbbbbc11bbbbbc151515151bcbcbcbc444c11515151515151515444
222222222222222222dd5dddddd5d2222222222212222222111551110000d555555100001bbbcbc11bbbbbc1d55555514bbbbbbc4bb1c11515151515151514bb
22222222222cc2c22dddd555555d5d2222222c22c1222222551555110000d5dd5d5100001bbbcbc11bccbbc1d5dd5dd14b444bbc4bbc115151515151515154bb
22222222222222222dd555555555d522222222221cc22222551555510000d555555100001bcbcbc11bcbbbc1d51dd1114bc4cbbc4bc1c44444411444444114bc
22222222222222222d55555555555d2222222222c1cc2222555555510000d5d5dd5100001bbbbbc11bbbbbc1d551d5514b4c4bbc4bbc14bbbbb1c4bbbbb1c4bb
222222222cc222222555115115155522222222221cc2c222555555510000d555551000001bbbbbc11bbbbbc1d55d15514bb4bbbc4bb1c4bcbbcc14bcbbcc14bb
2222222222222cc2155555555555551222222222c1cc2222555555510000d5ddd10100001bcbbcc11bbcbbc1d55155514bbbbbbcbccc1bccccc1cbccccc1cbcc
22222222222222221555111151155512222222221cc2c222515151510000d55555d100001bbbbcc11bbbbbc115151511cbcbcbcc1c1c1c1c1c1c1c1c1c1c1c1c
c1cc22221c1c1c1c155555555555551221c1c1c11ccc222251111111006ddd0000688d0000000bbcbbc000001111111111111111bcbcbcbc1111111111111111
1cc2c222c1c1c1c11555115111155512221c1c1cc1c2c222d551151106d11dd0068e88d000000bbcbbc0000051151555555551154bb4bbbc1551155151151111
c1cc2222cccccccc1555555555555512222ccccccccc2222d55515550dd11dd00d8882d000000bbbbbc0000055155555555155554b444bbc5551555555555515
1cc2c222c2c2c2c215515511555555112222c2c2c2c22222d55555550dd11dd00dd82dd000000bbbbbc0000055555555551d55554bc4cbbc5555555555155515
c1cc22222c2c2c2c151555151551551222222c2c2c2c2222d55555550dd88dd00dd11dd000000bbbbbc000005515555555d555554bb4bbbc555551d555555515
1cc2c2222222222211111111111111112222222222222222d55555550d8e88d00dd11dd00000bbbbbcbc000055555555555555554bbcbbbc55555d5555555555
c1cc22222222222221111111111111122222222222222222d55555550c8882c00cd11dc000bbcbcbc0bbc00055555555555555554bbbbbbc5555555555555555
1cc2c22222222222222121212121212122222222222222225151515100c82c0000cddc000b00b00b00b00b005151515151515151cbcbcbcc5151515151515151
f5070647175706d4f4560647175706d5f5451717171717574406471717171717d5f507064757064717570647171717d5f5c7e7f7b7e7f7c7e7b7f7e7c6b6c6d5
f5c7e7f7b7e7f7c7e7b7f7b7c7f7e7f7c7e7d5e5e5f5f7c7e7b7d5e5e5e5e5e5e5e5e5e5e5f5c6b6c6b7f7e7c754d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6b5
f5070606067006d5f5070606060606d5f5070606460606060606060644060606d5f507060644050606060606060670d5f54597171717171797171717171717d5
f54517171717171717171717971717171717d6e6b5f545171717d5e5e5e5e5e5e5e5e5e5e5f54517171717171754e7f7c7e7d7f7d7e7e7f7b7e7f7c7e7b7f7d5
f5070664655606d6f6070665645606d5f564e0f0645565656565d4e4e4e4e4e4b4f565656456066565560664655606d5f57606060606061606060606068206d5
f507060606060644060606060670067006706766d5f507060670d5e5e5e5e5e5e5e5e5e5e5f507820606064406544517171717171717171717171717171717d5
f50706c66607066766070667c60706d5f5b6e1f1b654c7b7b7c7d5e5e5e5e5e5e5f5e7b7d70706b6b60706d7660706d5f50705160606060606060606060606d5
f507060626362636263606060606064406064717d5f50706d4f4d6e6e6e6e6e6e6e6b5e5e5f507060606460606540770060606060616060606060606067006d5
f50706471757064717570647175706d5f5455706475445761717d5e5e5e5e5e5e5f545171757064717570647175706d5f50744060606646565556565656565d5
f507060627372537273706060606060606060606d6f60706d5f5d776d7e7b7f7b766d5e5e5c4e4e4f464e0f064540706060644060606060606460606060606d5
f50706060644060606060606061606d5f5074616065407144406d5e5e5e5e5e5e5f507060606060616060606064406d5f50706060606d7b76654c7b7e7b766d5
f507160606060606060606060606061606060606b6c60706d5f54515171717171717d5e5e5e5e5e5f5d7e1f1d7540706646456060664656456060664645606d5
f50706646565656564560665655606d6f664e0f0645507060606d6e6e6e6e6e6e6f607066565656556066565655606d5f56456060606471717644517171717d5
f50706060606060606064606060606060606060647175706d5f50706060606064406d6e6e6e6b5e5f5455744475407066766070606d7f7d7070606d7660706d5
f50706d7b7f7b766d707066766070667b7b6e1f1b6660706160667b7e7c7e7f7b766070667b7e766070667b7660706d5f5b707060606050606c60706064406d5
f56565656565e0f065655556060626362434060606060506d5f50706d4e4e4f4560667c7b7e7d5e5f564e0f064540706471757060647171757060647175706d5
f507064717171717175706471757064717175706471757060606471717171717171757064717171757064717175706d5f54557160606645606475706645606d5
f5f7c7e7b7d7e1f1d7e754070606273725350606d4f45606d5f50706d5e5e5f5070647171717d5e5f5d7e1f1d7540706060646464606150506060606060606d5
f507060606060644060606060606060606050606060606060606060606160606060606060644060606060606060606d5f50705460606540706040606540706d5
f545971717175706471754070606060606060606d5f50706d5f50706d5e5e5f5070606060606d5e5f545574647540706060606064646060606060646060606d5
c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f456060406d4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4f56565656555556565555606540706d5
f507060644060616060654070606060606060606d5f50706d5f50706d5e5e5f507066465e0f0d6e6f664e0f064550706646456060664656456060664645606d5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5c4f45606d4b4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5c5e6b5e5e5f5e7d7d7b754c7b7f7640706540706d5
f507010606060606060654070606060406060606d5f50706d6f60706d6e6e6f6070654c6e1f1c6e7b6d7e1f1d7b607066766070606c6c7c607060667660706d5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f50706d5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5c5f664d6b5e5f54517171754451717c60706540746d5
f50714050406060606065407069706060606d4e4b4f50706b6c6070664d7b6d707065445570647177617571647175706471757060647171757060647175706d5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5c5f60744d6b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5c5f6b666b6d6b5f50770700654077006475716540706d5
f50746064406060697065407064406060606d5e5e5f50706471757065445171757065407060606051516064606060670060616060606060606160606067006d5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f5b60706b6d5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f56645171767d5f50770700654077006160606540706d5
f50706060606060606465407060606060606d5e5e5f50706440606066407060606065407060606060606060606060606060606060606060606060606060606d5
e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f545571647d5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f54557154447d5f50770700654070606645606540706d5
c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4e5e5c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4
c5e6e6e6e6b5c5e6e6e6e6e6b5c5e6e6e6e6e6b5c5f664e0f064d6b5c5e6e6e6e6e6b5c5e6e6e6e6e6f60746060606d5f564e0f06455656565550744640706d5
f5c6b6c6d5e5f5c7e7b7f7e7c7f7e7f7c7e7f7c7d5f5f7c754b7f7e7c7f7e754c7e7e7d5f5e7f7c7e7b7f7e7c7f7e7f7c7e7e7d5f5e7f7c7e7b7f7e7c7f7e7d5
f5e7f7c766d6f6b7c7c6b766d6f6f7b7d7e766d6f6b7c6e1f1c666d6f6c7b7d7f766d6f6f7c7c6e766646456060664d5f5b6e1f1b6e766d5f5660706c60704d5
f5451717d5e5f545171717171717171717171717d5f545176445171717171764451717d5f54517171717179717171717171717d5f545171717171717171717d5
f545971717b6b64517971717b6b64597171717b6b6451757064717b6b64597171717b6b64517171717b6b6070644b6d5f5455706471717d5f5455706475706d5
f5078206d5e5f507700670060606060604060606d5f50706d7070670700606d7070606d5f50706060606060606060606064406d5f507060606060606970606d5
f507060616471757060606064717570606060647175706150606064717570606060647175706060606471757040647d5f5070606067006d5f5077006060606d5
f5070606d5c5f665656565645606645606160606d5f507064757066565564447570606d5f50706263606060606062636060606d5f5070605d4f45606064406d5
f565656565555606060606060606064606060606060606060605060606060606060606060606460606060606060606d5f5070626360606d6f6070606440606d5
c4f4e0f0d5f5c7b7f7e766c60706540706060606d6f607060646066766070606060606d6f60706273706067006062737060606d6f6070606d5f50706060606d5
f5e7b7f766640797060606050606060697060606064406060606060646060624340606069706060626360606060606d5f50716253706066766070624340606d5
e5f5e1f1d6f64517171717175706540706645606c6c607066456064717570664560606c6c60706060606061405440606060606c6c6070606d6f60706060606d5
f545171717c60706060606060606060606060606060606060606060606060625350606060644060627370606062434d5f50706060606064717570625350606d5
e5f507045466070406067006460654070654070647175716540706060606065407060676175706060606060606060606060606471757060667660706010606d5
f507010606475706060606060606060606160606646565646465656456060606060606060606060606060606062535d5f50706060606061605064406060606d5
e5f507155445570664656565656564070654070606050606556565656565655507060415440606062636243424342636060606160606060647175744150606d5
f507154406060606060606556565655556060606c6e7f7d7d7b766c607060606060606060606060606060606060606d5f50706060606060606060606060606d5
e5f5071654071516c6f7e7b7c7665407065407064606060654b7f7b7e7c7665407060606060606062737253527352737060606060506060606060606060604d5
f50706060646060606060664f7d7666407060606471717171717171757060606460606060606060606060506060606d5f56456066465656564656565656465d5
e5f50746d4f40646471717171717540706640706160606066445171717171764070606060606060697060606060606060606060606060606d4f45606060606d5
f507060606645606160606c6451797c607060606060606060606060606064406040606263624340606060606060606d5f5b60705b6f7b766c6b7f7e766c666d5
e5f50706d5f50606060670060406540706c60706d4f45606d7071606060606d7070606d4f45606060606060606060606060606d4f4560606d5f50706060606d5
f565656565550706060606475706064757060606061606062636060606060606060606253725350606060626360606d5f54557064717179717179717171717d5
e5f50706d6f66565656565645606640706765706d5f507064757066565560647570606d5f50706060606067006062434060606d5f5070406d6f60706060606d5
f5b7f7c7f7660706060606060670061606060697060606062737060606060606060606060606060606060625370606d5f50706060616060606060606050106d5
e5f50706b6b7c7f7b7f766c60706c60714440606d5f507060606066766070606060406d5f50706060606064406062535060606d5f507060667660706060606d5
f545171797175706060606645606066456060606060606060606060606d4e4e4f40606060606060606060606060606d5f50797060606060606060606461544d5
e5f5070647171717171717175706475706060606d5f507066456064717570664560606d5f50706060626360606060606060606d5f507060647175706069706d5
c4e4f456060606060606065565656555070606060606060606060606d4b4e5e5c4f456061606d4f456060606060606d5f50706060606064406060606060606d5
e5f5070606060604060606060606060606060606d5f507065407067070060654070606d5f50706060627370606060606060606d5f507060606060646060606d5
e5e5c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4e5e5e5e5c4e4e4e4e4b4c4e4e4e4e4e4e4e4b4c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4
e5c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4c4e4e4e4e4e4e4e4e4e4e4e4e4e4b4c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4c4e4e4e4e4e4e4e4e4e4e4b4
__gff__
0000000000000000000000000000838301000000000000000000000000008383000000000000000000000000000080800000000000000000000000000000000080808383808383000000008383838383808083838083830000000083838383838080838380808301000000838383838380808383808083000003008383838383
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5f7c7e7f7b7e7f7c7e7b7f7e7c7f7e457b6d6e6e6f7e457c7e7d6b7d7c7f7c7f7e7f5d5e5c6e6e6e5b5f7f6c6b6c7e5d5f7c7e7f7b7e7f7c7e7b7f7e7c7f7e5d5f7c6d6e6f7f7f7c7e7b7f7e7c7f7e7b7b7c7e7f7b7e7f457e7b6d6e6f7f7e455f7c7e7f7b7e7f7c7e7b7f7e7c7b7f7c7b7f7e7f7b7e7f7c7e7b666d5b5e5e5e
5f547171717171717171717171717145547d6b6b7d544554717171717171717171715d5e5f7e7b7f5d5f54717171715d5f54717171717171717171717171715d5f546c6b6c5471717171717171717171717171717171714554716c6b6c5471455f54717171717171717171717171717171717171717171717171716b6d5b5e5e
5f7060796060606060606060606060457074717171754570606060606060606060605d5e5f5471715d5f70606060605d5f70606007606060604460600760605d5f707471717560606060606060606060076050606060604570607471717560455f706060600760600760606060606060606007606007606060606074766d5b5e
5f7060606263606060607960606044457007606007604570606060606060626360605d5e5f7060505d5f70602860605d5f70616060605556565655656060605d5f796064446060606263626360606263626362636060604570076007600760455f70616060606060606060606060604665606060406060604665606074766d5b
5f7051617273606060606060606060467060506060604570646067406060727360605d5e5f7060605d5f70606060605d5f7060606055556c6b6c55556560605d5f706060606060607273727360607273727372736060604570606060606060455f70606046565656564665606060607d70446060606060607d70606060746b5d
5f70446060606060606060606060607d7060606060604570606051616060606060606d6e6f7060605d5f70606060605d5f70796060457d5471717d457060605d5f706060606060606060606040606060606060606060605556466560604656555f7060606c7e7b7c7f6c7060606060747560606060606060747560606060745d
5f7060606060606160424360606060747560606160604570606060606060606060606c7c6c7061605d5f46656060465d5f70606060455475606074457060605d5f70606060606060606060606060606060606060606160767b6c7061606c7f4d5f7060607471717171717560606060606060606060606060606060606060605d
5f7079606060606060525360606060606060606060604570616060606060606060607471717560605d5f6c7060446c5d5f70606050457060286060457060445d5f706050604d4e4f65604656564665604656564665606074717175606074715d5f7060606060606060606060606060465656564646565656466560606060605d
5f706060606263606060606060606060606060606060457060604d4e4f65606044606060606060605d5f54756060745d5f70606060457060606060457060605d5f705160605d5e5f70607d7b7e7d70607d7f7c7d70606060606060606044605d5f70606060446060604460626360606c7e7b7c7d7d7b7c7f6c7060607960605d
5f706060607273606060606050606060606060607960457060605d5e4c4e4e4e4e4e4e4e4f6560605d5f70606160605d5f70606060457060606060457060605d5f706060605d5e5f70607471717175607471717175606060606060606060605d5f7060606060606060606072736060747171717171717171717544606060605d
5f706060606060606060606060606046656060606060467060606d6e6e6e6e6e5b5e5e5e5f7060605d5f70606060605d5f70607960554665604446557060605d5f706060605d5e5f70606060606460446060606060606060606079606060605d5f7060601060606060606060606060606060606060606060606060606060605d
5f7060606060606060796060606060457060606060606c7060606c7e7b7f7c7f5d5e5e5e5f7060606d6f70606060605d5f70606060766c7050606c7f7060605d5f706060605d5e5f565656466560626360604d4f65604060606060606060605d5f706064514060606060606060606060606060606060606060604d4f6560605d
5f706010604060606060606060796045706060606060747560607471717171715d5e5e5e5f7060607d7d70606067605d5f70506060747175606074717560605d5f706079605d5e5f7e7b7f6c7060727360605d5f70606060606060606060605d5f706060606060606060606160604243606060606040606060605d5f7007605d
5f706050516060606060446060606045707960605144606060600760074007605d5e5e5e5f706060747175646141605d5f70606060606060606160606060605d5f706060606d6e6f547171717560606060605d5f70606060626360607960605d5f706060606060606060606060605253600760626360606060606d6f7007605d
5f706044606060606060606060606045706060606060616060606064606060605d5e5e5e5f705060606060606060605d5f70606060626342436263626360615d5f706060607d7e7d706061606060606060605d5f70606060727360606060605d5f707955460e0f4656556560606060606051617273606060606076667060445d
4c4e4e4e4e4e4e4e4e4e4e4e4e4e4e454e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b5e5e5e4c4e4e4e4e4e4e4e4e4e4e4b5f70604467727352537273727360605d5f70606060747171756060606060606060605d5f70606060606060606007605d5f7060456b1e1f6b66457060606060606060606060606060606074717560605d
5c6e6e6e6e6e6e6e6e5b5e5c6e5b5e5e5e5f6b6c6b7d6b6c6b7d6b6c6b7d6b5d5e5e5e5c6e5b5e5e5c6e6e6e6e6e6e5b5f70606041606060606060606060605d5f70796060606060606062634243606060615d5f70606060605060606061605d5f7079455475607471457060606060606060606060606060606060606060605d
5f7c7e7f7b7e7f7c7e5d5c6f7b6d5b5e5e5f547171717171717171717171715d5e5e5c6f7b6d5b5e5f7b7f7e7c7f7e5d5f70606060606060446060506060605d5f70606060606060606072735253106060605d5f70606060406060606060605d5f56565570602860605556564d4f5646565646564d4f5656564665606060605d
5f54717171717171716d6f6b546b6d5b5e5f704046606060606060604644605d5e5c6f6b546b6d5e5f5471717171715d5f56565656565656565656564665605d5f704007604d4e4f656060606060606060605d5f70606060606060607960605d5f7b66457060606060457b7f5d5f7b7d7e7f7d665d5f7c7f666c70606067605d
5f70616060076060604566547574765d5e5f70606b650760606007606b65605d5e5f66547574765b5f7060600740605d5f7f7b7b7e7c7f7b7c7b7e7f7d70605d5f705161606d6e6f706060606050606060606d6f70606040406060606060605d5f54715556565656565554715d5f5471717171716d6f5471717175606151445d
5f70604656564665604654756060745d5e5f706074756060606060607475605d5e5f54755160746d6f7060565665605d5f54717171717171717171717175605d5f56465656565656565656565656565656565656460e0f46565656565656565d5f70797d7e6b7b6b7b7d70606d6f70074060076076667044606060606060605d
5f70607d7b7c7d70606b70605061605d5e5f706007606060606060600760605d5e5f7061604460766c7060766670605d5f70606060606060646060606060615d5f6c6b6c7f7b7e7c7b7e7f7c7e7c7b7e7f7f7e7e7d1e1f7d7c7c7b7e7f7f7e5d5f7060747171717171797560766670604243606074717560606042436060605d
5f70607471717175607475606060605d5e5f706060606060606060606060605d5e5f706060606074717560747175605d5f70604665444656565656564665605d5f5471717171717171717171717171717171717171756074717171717171715d5f7064606044616460606060747175605253606060606060606052536060605d
5f70606064606060604460646060605d5e5f706060606060286060606040605d5e5f706060606044606060606160605d5f70604570606c7e7c6b7b7f6c70605d5f7060606060604460606060606060606060606060606044606060606060605d5f7060606060606060606040606060606060606060646060606060606060605d
5f70604656564665604656564656565d5e5f706060606060606060606060605d5e5f465656465656466560565665605d5f70404570507471717171717175605d5f7060604665606046656160466544605556565655565656555656565565605d5f7060607960606060606060606060606060606060606060606060605060605d
5f70606c7b666c70606b7e7b6b7f665d5e5f706007606060606060600760605d5e5f6b7e7b6b7f666b7060766670605d5f70604570606007400760076060605d5f706060457060504570606045706060457b6b7f457e6b7c457f6b7e4570605d5f7060606060606060606263606060606060606160606263606060606060605d
5f70607471717175607471717171715d5e5f706046606060606060604660605d5e5f547171717171717560747175605d5f70605556565656565656565656565d5f7028604570076045700760457007604554677145547171455471714570605d5f7060606060606060607273606060506060606060607273606060424342435d
5f70604060606060606060606040605d5e5f70606b650760606007606b65605d5e5f706461606060606060606060605d5f70606c7b7e7b7f7c7b7f7b7e7c7b5d5f7060604670606046704060467060604670516046700760467007604670605d4c4f65606040606060606060606060606060606060606060606060525352535d
5f70604d4f6560606046564d4f65605d5e5f706074756060606060607475605d5e5f70604665604d4f656060604d4e4b5f70607471717171717171717110715d5f7060606b7064607d7060607d7050606b7060406c7060606c7060606b70605d5e4c4f656060606760446060606160606060796060606060606060606060605d
5f70605d5f706060607d665d5f70605d5e5f706460606060606060606060405d5e5f70604570605d5f706060605d5e5e5f70606060646060606060646151505d5f7060607475606074756060747560607475606074756460747560607475605d5e5e4c4f656061404164604d4f6560606060606060606044606060606107605d
5f70606d6f7060606074716d6f70605d5c6f565656564665606046565656566d5b5f70604670606d6f706046566d6e5b5f70646060406060606060606060605d5f7060606060606060606060606044606060606060606060606060616060605d5e5e5e4c4f6560606060605d5f7060606060606060606060606060606060605d
5f70647666706050446060766670605d5f7b7d7f6c666b7060606b7f6c7b7d665d5f70606c7060766670606c7b7e665d4c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b4c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b5e5e5e5e4c4e4e4e4e4e4e4b4c4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4b
__sfx__
0108000c243333000530615306053c615000003c6153c615300053c615306053c6153000530005300053000530005300053000530005300053000530005300053000530005300053000530005300053000530005
011002030016000151001410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01ff000c185301853530505305053c505005003c5053c5053050530505305053c5053050530505305053050530505305053050530505305053050530505305053050530505305053050530505305053050530505
011000011802200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010602031602218021180200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01eb00001802018025000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000c247541f7541b74418744137340f7340c7240f72413734187441b7541f7542470400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
0102000000373016732b3730167300473233731c26301663053631a26301663016530d253024531e3530164300343054431c2430163325333016330033325423016230162309323016231d313016131021300413
0108000a3c6053000530605306053c605000003c6053c605300053000530005300053000530005300053000530005300053000530005300053000530005300053000530005300053000530005300053000530005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001b7641c7621d7521d7521c7521c7521d7521d7521c7521c7521d7521d7521c7521c7521d7521d7521c7521c7421c7421c7421b7421b7321c7321c7151870000000000000000000000000000000000000
010400002945312053314532055327053366570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013400000c0340c0310c0210c0210c0120c0120c0120c015080340803108021080210801208012080120801505034050310502105021050120501205012050150703407031070210702107012070120701207015
013400001b5321b5211b5111b5121f5321f5211f5111f512205322052120511205122353223521235112351224532245212451124512275322752127511275122b5322b5212b5112b5122f5322f5212f5112f512
013400001f7141f7111f7121f7121b7141b7111b7121b712237142371123712237121b7141b7111b7121b71220714207112071220712247142471124712247122471424711247122471226714267112671226712
011000040cf000cf000c8151e6000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf000cf00
01100000189401b7161b706189401b700177001b71617700149401771617706149401770013700177161370011940187161470011940207001c700207161c7001394017716177061394017700137001771613700
011000001fb341fb211fb111fb122bb312bb212bb112bb122ab312ab212ab112ab122ab102ab1026b3126b2129b3129b2029b1129b1029b1027b2026b2024b2023b3023b2123b1123b1026b3126b2126b1126b10
011000200c8100c8150c8150c815186150c8150c8150c8150c8150c8150c8150c815186150c8150c8150c8150c8150c8150c8150c815186150c8150c8150c8150c8150c8150c8150c815186150c6150c8150c825
0110000030a6030a6030a6030a6030a5030a5030a5230a5230a4130a4230a4230a4230a3230a3230a3230a3230a2130a2230a2230a2230a2230a2230a2230a2230a1230a1230a1230a1230a1230a1230a1230a12
010200000e5510e5510e5510e5511d5511d5511d5512915329501293012b3002b3001f3001f3051f3001f3001f3001f3001f3051f3001f3001f3001f3001f3001f3051f3001f3001f3001f3001f3001f3001f305
011000001fb141fb121fb121fb121fb122bb112bb122bb122bb122ab112ab122ab122ab122ab122ab1226b1226b1229b1129b1229b1229b1229b1227b1226b1224b1223b1223b1223b1223b1226b1126b1226b12
0110000027b3427b2127b1127b121fb311fb211fb111fb121eb311eb211eb111eb1229b3129b2129b1129b122ab312ab212ab112ab121eb311eb211eb111eb1220b3120b2120b1120b121fb311fb211fb111fb12
0110000027b1427b1227b1227b1227b121fb111fb121fb121fb121eb111eb121eb121eb1229b1129b1229b1229b122ab112ab122ab122ab121eb111eb121eb121eb1220b1120b1220b1220b121fb111fb121fb12
0110000027b3427b2127b1127b122bb312bb212bb112bb122ab312ab212ab112ab122db312db212db112db122eb312eb212eb112eb1222b3122b2122b1122b1230b3130b2130b1130b122fb312fb212fb112fb12
0010000027b1427b1227b1227b1227b122bb112bb122bb122bb122ab112ab122ab122ab122db112db122db122db122eb112eb122eb122eb1222b1122b1222b1222b1230b1130b1230b1230b122fb112fb122fb12
00100000119402071620706119001194018700139401870014940187161d9051894018b1418b1024b1124b151794018700147001394014a061aa061d7161aa1616940189051ca161494018b1418b1024b1124b15
0110000030c3230b2130b1130b1030b1030b1030b1030b1030b1030b1030b1030b1514905199051d71619905149051a7161d9051a905149051a9051d7001a90513905187161c9051890513905189051c71618905
01100000051100511514100051000511005115071100711508110081150a1000c1100c115187151d715207150b1100b115081000711007115207141d7140f1000a1100a1150e100081100811518515145151c515
0110000014900187001d9051890514905187161d9051890514900187001d9051890514905199051d71619905149051a7161d9051a905149051a9051d7001a90513905187161c9051890513905189051c71618905
011000002092020716207061d9201190019945189451794014900187161d9051694018b1418b1024b1124b151794018700147001394014a061aa061d7161aa1616940189051ca161494018b1418b1024b1124b15
0110000014110141150000011110111150d1150c1150b1100b1150a100000000a1100a115187051d705207050b1100b115081000711007115207141d7140f1000a1100a1150e1000811008115185150000000000
011000001dc301db301db211db201db111db101db101db101fb311fb301fb211fb201fb111fb101fb101fb1020b3120b3020b2120b2020b1120b1020b1020b1024b3124b3024b2124b2024b1124b1024b1024b10
0110000028c3028b3028b2128b2028b1128b1028b1028b1024b3124b3024b2124b2024b1124b1024b1024b1027c3127b3027b2127b2027b1127b1027b1027b1025b3125b3025b2125b2025b1125b1025b1025b10
0110000029c3029b3029b2129b2029b1129b1029b1029b102bb312bb302bb212bb202bb112bb102bb102bb102cb312cb302cb212cb202cb112cb102cb102cb1030b3130b3030b2130b2030b1130b1030b1030b10
0010000035c2435b2035b1135b1035b1135b1035b1035b1030b3130b3030b2130b2030b1130b1030b1030b1033c3133b3033b2133b2033b1133b1033b1033b1034b3134b3034b2134b2034b1134b1034b1034b10
001000001d94020716207061d940207001c700207161c700199401c7161c706199401c700187001c71618700169401d716197001694025700217002571621700189401c7161c706189401c700187001c71618700
0110000035c2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d2235d22
011000000c0100c0151b7150c0100c0151b715187051b70508010080151b715080100801517715170001300005010050151471505010050151471520000147150701007015177150701007015177151700013000
0110000013500185001b5161850013500185001b716185000f5001450017516145000f500145001771614500115001450018516145001150014500187161450013500175001a5161750013500175001a71617500
01100000189401b70518715189401b705187151f70518705149401b705177151494017705147151b705147051194014705117151194014705117151870511715139401770513715139401a705137151f70517705
001000001d940207051d7151d940207051d715247051d70519940207051c715199401c7051971520705197051694019705167151694019705167151d70516715189401c70518715189401f70518715247051c705
011000001101011015207151101011015207151d705207050d0100d015207150d0100d0151c7151c000180000a0100a015197150a0100a0151971525000197150c0100c0151c7150c0100c0151c7151c00018000
01100000185001d500207161d500185001d500207161d50014500195001c7161950014500195001c7161950016500195001d7161950016500195001d71619500185001c5001f7161c500185001c5001f7161c500
011000001994019921199110d9400d911219402191115940159111e9401e9211e9111294012911209402091114940149110d9400d9310d9210d9120d915010000100001000010000100001000010000100001000
011000001c7401c7201c71520740207152174021715247402471525740257202571528740287152c7402c71530740307153174031731317223171501700017000170001700017000170001700017000170001700
011000000c8400c8210c8110d8400d8210c8400c8210d8400d8210c8400c8210c8110d8400d8210c8400c8210d8400d8210c84000000000000000000000000000000000000000000000000000000000000000000
0110000019e5019e5019e5019e5019e5521e5021e5021e5021e552ae502ae502ae502ae502ae552ce502ce502ce502ce5531e5031e5031e4131e4031e4131e403d71531e00010000100001000010000100001000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002be760c0062ce760c0062de660c0062ee660c0062ee560d0062ee560d0062ee460d0062ee460d0062ee360d0062ee260d0062be060c0062be060c0062be060c0062be060c0062be060c0062be060c006
010500001fe662be461fe2621e662de4621e2623e662fe4623e2625e6631e4625e263700637006370063700637006370063700637006370063700637006370063700637006370063700637006370063700637006
0003000018b3419b3118b3119b411ab4119b411ab511bb511ab531bb611cb611bb611cb711db711cb711db611cb611db611cb511bb511cb511cb411bb411cb411cb311bb311cb3519b0018b0119b0118b0118b01
010800001b3530f333000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
01010000181761e166181561e146181361e136181261e11600000000000000000000191761f166191561f146191361f1360100001000010001a126201161a176201661a156201461a136201361a1262011602000
010600001316416121071000710007100071000710007100071000710007100071000710007100071000710007100071000710007100071000710007100071000710007100071000710007100071000710007100
010600000ff700ff700ff610ff600ff510ff500ff410ff400af500af500af410af400af310af300af300af3500f3000f3000f2100f2000f1100f1000f1000f1000f0000f0000f0000f0011f0000f0004f0000f00
0104000018614246111861537e253ce35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000030e1430715196141961522e132e713196141961520e132c7130d6100d6151ee132a7130d6100d6151ce13287130d6100d6151ae13267130d6100d61518e1324713016100161016e10167150161001615
00010000016140161516e132e713016140161518e13247130d6100d6151ae13267130d6100d6151ce13287130d6100d6151ee132a7130d6100d61520e132c713196101961022e132e713196101961030e133c714
__music__
00 0c 0d 0e 44
00 27 26 13 28
03 27 26 0f 28
00 27 26 28 12
00 27 26 28 12
01 15 12 11 10
00 17 12 16 10
00 15 12 11 10
00 19 12 18 10
00 1c 12 1b 1a
00 1d 1c 12 1a
00 1d 1f 12 1e
00 1d 1c 12 1a
00 1c 12 1a 20
00 1c 12 1a 21
00 1f 12 1e 22
00 1c 12 1a 23
00 2a 12 29 25
00 2b 2a 12 29
00 27 26 28 12
02 27 26 28 12
04 2c 2d 2e 2f
03 1c 1a 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
