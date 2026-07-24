pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- slime quest
-- a platformer by blackboxai

function _init()
	-- constants
	gravity=0.25
	friction=0.85
	cam_x=0
	
	-- player (slime hero)
	pl={
		x=20,y=80,
		vx=0,vy=0,
		w=6,h=5,
		ongrnd=false,
		facing=1,
		anim=0,
		animt=0,
		dead=false,
		dead_t=0,
		coins=0,
		lives=3,
		inv=0,
		jump_force=-3.2,
	}
	
	-- entities
	coins={}
	enemies={}
	particles={}
	platforms={}
	spikes={}
	
	-- build level from string data
	-- 0=air, 1=wall, 2=coin, 3=spike, 4=goal, 5=enemy, 6=platform_h, 7=platform_v
	parse_level()
	
	-- screen effects
	shake=0
	flash=0
	
	-- messages
	msg=""
	msg_t=0
	msg_c=7
	
	-- title
	show_title=true
	title_t=90
end

function parse_level()
	-- 128x16 level encoded as strings
	-- each char: .=0 #=1 c=2 ^=3 g=4 e=5 -=6 |=7
	local lvl_str={
		"...............................................................................................................................",
		"............................................------....................................................------...................",
		"....|---|................................................................................|---|..............................",
		"....|---|---|............................................................................|---|---|..........................",
		"...............................................................................................................................",
		"...............................................................................................................................",
		"...............................................................................................................................",
		".................c........c...........c.c.c......................c.c.c.c.............................c.........................",
		"...............####.....####.........#######....................#######..............................g.........................",
		".............##.........c..##.......##.....##..........c.c.....##.....##.....c.c.c.................####........................",
		"............##.........###..##.....##.......##.......######...##.......##...#######...............##..##.......................",
		".....c.....##..e.c...........##...##...e....##......##....##.##...e....##..##.....##....c.c......##....##......c...............",
		"...####...##..####............##.##...........##...##......###..........####.......##..####.....##......##....###..............",
		"..##..##.##............e.......###.............#####..................................e..##...##........##...#.#.........e...",
		"c##....###...e...^^............c.c........e...................e...........^^.......e.....c.####..........####.#.#.c.c.c.c.####.",
		"####...c#...####..^^^..####..#####..####..#####..####..####..#####..####..#####..####..#####..####..#####..#############..###",
	}
	
	-- convert to numeric level array
	level={}
	for y=1,16 do
		level[y]={}
		local row=lvl_str[y]
		for x=1,128 do
			local ch=sub(row,x,x)
			local val=0
			if ch=="#" then val=1
			elseif ch=="c" then val=2
			elseif ch=="^" then val=3
			elseif ch=="g" then val=4
			elseif ch=="e" then val=5
			elseif ch=="-" then val=6
			elseif ch=="|" then val=7
			end
			level[y][x]=val
			
			-- spawn entities
			local wx=(x-1)*8+4
			local wy=(y-1)*8+4
			if val==2 then
				add(coins,{x=wx,y=wy,active=true,oy=wy,anim=rnd(1)})
			elseif val==3 then
				add(spikes,{x=(x-1)*8,y=(y-1)*8})
			elseif val==4 then
				goal_x=(x-1)*8
				goal_y=(y-1)*8
			elseif val==5 then
				add(enemies,{x=wx,y=wy,vx=0.6,dir=1,w=6,h=6,dead=false,anim=0})
			elseif val==6 then
				add(platforms,{x=(x-1)*8,y=(y-1)*8,w=24,h=4,vx=0.8,dir=1,minx=(x-1)*8-16,maxx=(x-1)*8+16,vy=0,miny=0,maxy=0})
			elseif val==7 then
				add(platforms,{x=(x-1)*8,y=(y-1)*8,w=24,h=4,vx=0,dir=0,minx=0,maxx=0,vy=0.6,diry=1,miny=(y-1)*8-20,maxy=(y-1)*8+20})
			end
		end
	end
end

function _update()
	-- title screen
	if show_title then
		title_t-=1
		if btnp(4) or btnp(5) or title_t<=0 then
			show_title=false
		end
		return
	end
	
	-- death timer
	if pl.dead then
		pl.dead_t-=1
		if pl.dead_t<=0 then
			if pl.lives>0 then
				respawn()
			else
				_init()
			end
		end
		update_particles()
		return
	end
	
	-- input
	local ax=0
	if btn(0) then ax=-0.45 pl.facing=-1 end
	if btn(1) then ax=0.45 pl.facing=1 end
	
	-- jump (z or x)
	if btnp(4) or btnp(5) then
		if pl.ongrnd then
			pl.vy=pl.jump_force
			pl.ongrnd=false
			sfx(0)
			-- jump particles
			for i=1,5 do
				add_particle(pl.x,pl.y+pl.h/2,rnd(2)-1,0.5+rnd(1),11)
			end
		end
	end
	
	-- physics
	pl.vx+=ax
	pl.vx*=friction
	pl.vy+=gravity
	
	-- terminal velocity
	pl.vy=min(pl.vy,4)
	
	-- move x
	pl.x+=pl.vx
	collide_map(pl,"x")
	
	-- move y
	pl.y+=pl.vy
	pl.ongrnd=false
	collide_map(pl,"y")
	
	-- moving platform collision
	for p in all(platforms) do
		-- move platform
		if p.vx~=0 then
			p.x+=p.vx*p.dir
			if p.x<p.minx or p.x>p.maxx then p.dir*=-1 end
		end
		if p.vy~=0 then
			p.y+=p.vy*p.diry
			if p.y<p.miny or p.y>p.maxy then p.diry*=-1 end
		end
		
		-- collision with player
		if rect_overlap(pl.x-pl.w/2,pl.y-pl.h/2,pl.w,pl.h,p.x,p.y,p.w,p.h) then
			-- landing on top of platform
			if pl.vy>0 and pl.y+pl.h/2-pl.vy <= p.y+1 then
				pl.y=p.y-pl.h/2
				pl.vy=0
				pl.ongrnd=true
				-- carry player
				if p.vx~=0 then pl.x+=p.vx*p.dir end
				if p.vy~=0 then pl.y+=p.vy*p.diry end
			elseif pl.vy<0 and pl.y-pl.h/2-pl.vy >= p.y+p.h-1 then
				pl.y=p.y+p.h+pl.h/2
				pl.vy=0
			end
		end
	end
	
	-- screen bounds
	if pl.x<4 then pl.x=4 pl.vx=0 end
	if pl.x>1016 then pl.x=1016 pl.vx=0 end
	if pl.y>128 then die() end
	
	-- camera follow
	local target_x=pl.x-64
	cam_x+=(target_x-cam_x)*0.1
	cam_x=mid(0,cam_x,960)
	-- shake via camera offset
	local sx=rnd(shake)-shake/2
	local sy=rnd(shake)-shake/2
	camera(sx,sy)
	shake=max(0,shake-0.5)
	flash=max(0,flash-1)
	
	-- coin collect
	for c in all(coins) do
		if c.active and dist(pl.x,pl.y,c.x,c.y)<10 then
			c.active=false
			pl.coins+=1
			sfx(1)
			for i=1,6 do
				add_particle(c.x,c.y,rnd(3)-1.5,rnd(3)-1.5,10)
			end
			msg="+1 coin!"
			msg_t=20
			msg_c=10
		end
		c.anim+=0.08
	end
	
	-- enemy collision
	if pl.inv<=0 then
		for e in all(enemies) do
			if not e.dead then
				-- move enemy
				e.x+=e.vx*e.dir
				e.anim+=0.1
				-- turn at walls/edges
				local ex=flr(e.x/8)+1
local ey=flr(e.y/8)+1
				if level[ey] and level[ey][ex+e.dir] and level[ey][ex+e.dir]==1 then
					e.dir*=-1
				end
				-- collision
				if rect_overlap(pl.x-pl.w/2,pl.y-pl.h/2,pl.w,pl.h,e.x-e.w/2,e.y-e.h/2,e.w,e.h) then
					if pl.vy>0 and pl.y+pl.h/2<e.y then
						-- stomp enemy
						e.dead=true
						pl.vy=-2.8
						sfx(2)
						for i=1,10 do
							add_particle(e.x,e.y,rnd(4)-2,rnd(4)-2,8)
						end
						msg="squish!"
						msg_t=25
						msg_c=11
					else
						die()
					end
				end
			end
		end
	else
		pl.inv-=1
	end
	
	-- spike collision
	for s in all(spikes) do
		if rect_overlap(pl.x-pl.w/2,pl.y-pl.h/2,pl.w,pl.h,s.x+2,s.y+4,4,4) then
			die()
		end
	end
	
	-- goal
	if goal_x and rect_overlap(pl.x-pl.w/2,pl.y-pl.h/2,pl.w,pl.h,goal_x,goal_y,8,8) then
		msg="you win!"
		msg_t=120
		msg_c=11
		sfx(3)
		-- confetti
		for i=1,30 do
			add_particle(goal_x+4,goal_y+4,rnd(6)-3,rnd(6)-3,flr(rnd(15))+1)
		end
	end
	
	-- animation
	pl.animt+=1
	if abs(pl.vx)>0.2 then
		pl.anim=flr(pl.animt/5)%4
	else
		pl.anim=0
	end
	
	-- particles
	update_particles()
	
	-- message timer
	if msg_t>0 then msg_t-=1 end
end

function _draw()
	if show_title then
		draw_title()
		return
	end
	
	cls(1)
	
	-- sky gradient
	for i=0,128 do
		local c=12
		if i>40 then c=1 end
		if i>80 then c=13 end
		line(cam_x,i,cam_x+127,i,c)
	end
	
	-- parallax clouds
	for i=0,8 do
		local cx=(i*64-t()*5)%1024-cam_x*0.3
		circfill(cx,20+rnd(8),8,7)
		circfill(cx+8,18+rnd(6),6,7)
	end
	
	-- draw level tiles
	for y=1,16 do
		for x=1,128 do
			local c=level[y][x]
			local sx=(x-1)*8-cam_x
			local sy=(y-1)*8
			if sx>-16 and sx<144 then
				if c==1 then
					-- wall / ground
					rectfill(sx,sy,sx+7,sy+7,5)
					-- grass top
					if y>1 and level[y-1][x]==0 then
						rectfill(sx,sy,sx+7,sy+2,11)
						pset(sx+2,sy+1,3)
						pset(sx+6,sy+1,3)
					end
					-- brick detail
					if (x+y)%2==0 then
						pset(sx+2,sy+4,6)
						pset(sx+6,sy+6,6)
					end
				elseif c==3 then
					-- spike
					local spike_bob=sin(t()*4+x*0.5)*1
					line(sx+1,sy+7+spike_bob,sx+4,sy+2+spike_bob,8)
					line(sx+4,sy+2+spike_bob,sx+7,sy+7+spike_bob,8)
					line(sx+1,sy+7+spike_bob,sx+7,sy+7+spike_bob,8)
					line(sx+2,sy+6+spike_bob,sx+4,sy+3+spike_bob,9)
					line(sx+4,sy+3+spike_bob,sx+6,sy+6+spike_bob,9)
				elseif c==4 then
					-- goal portal
					local glow=flr(t()*8)%2
					rectfill(sx-2+glow,sy-8+glow,sx+10-glow,sy+8-glow,11+glow)
					rectfill(sx,sy-6,sx+8,sy+6,12)
					print("★",sx+1,sy-2,10)
				end
			end
		end
	end
	
	-- draw platforms
	for p in all(platforms) do
		local sx=p.x-cam_x
		rectfill(sx,p.y,sx+p.w-1,p.y+3,4)
		rectfill(sx,p.y,sx+p.w-1,p.y,9)
		-- rivets
		pset(sx+2,p.y+1,6)
		pset(sx+p.w-3,p.y+1,6)
	end
	
	-- draw coins
	for c in all(coins) do
		if c.active then
			local sy=c.oy+sin(c.anim)*3
			local sx=c.x-cam_x
		-- sparkle
			if flr(t()*8+c.x)%4==0 then
				pset(sx+5+rnd(2),sy-5+rnd(2),10)
			end
			circfill(sx,sy,4,10)
			circfill(sx,sy,3,9)
			circfill(sx-1,sy-1,1,7)
		end
	end
	
	-- draw enemies (slugs)
	for e in all(enemies) do
		if not e.dead then
			local sx=e.x-cam_x
			local bounce=abs(sin(e.anim))*1
			-- body
			circfill(sx,e.y+bounce,5,2)
			rectfill(sx-5,e.y+bounce,sx+5,e.y+3+bounce,2)
			-- shell
			circfill(sx,e.y-1+bounce,3,8)
			-- eyes on stalks
			line(sx-3,e.y-2+bounce,sx-4,e.y-6+bounce,2)
			line(sx+3,e.y-2+bounce,sx+4,e.y-6+bounce,2)
			circfill(sx-4,e.y-6+bounce,2,2)
			circfill(sx+4,e.y-6+bounce,2,2)
			-- pupils
			pset(sx-4+e.dir,e.y-6+bounce,0)
			pset(sx+4+e.dir,e.y-6+bounce,0)
			-- slime trail
			if flr(t()*4)%2==0 then
				pset(sx-5+rnd(10),e.y+4+bounce,3)
			end
		end
	end
	
	-- draw spikes (additional detail)
	for s in all(spikes) do
		local sx=s.x-cam_x
		-- already drawn in tile loop
	end
	
	-- draw slime player
	if not pl.dead then
		draw_slime(pl.x-cam_x,pl.y,pl.facing,pl.anim,pl.inv>0 and flr(t()*4)%2==0)
	end
	
	-- particles
	for p in all(particles) do
		if p.life>5 or flr(t()*4)%2==0 then
			pset(p.x-cam_x,p.y,p.c)
		end
	end
	
	-- ui
	camera(0,0)
	
	-- ui bar
	rectfill(0,0,127,10,0)
	rectfill(0,0,127,10,1)
	
	-- hearts
	for i=1,pl.lives do
		print("♥",2+(i-1)*8,2,8)
	end
	
	-- coins
	circfill(60,5,3,10)
	circfill(60,5,2,9)
	print("x"..pl.coins,66,2,10)
	
	-- message
	if msg_t>0 then
		local mx=64-#msg*2
		rectfill(mx-4,58,mx+#msg*4+4,68,0)
		print(msg,mx,61,msg_c)
	end
	
	-- flash effect
	if flash>0 then
		rectfill(0,0,127,127,7)
	end
	
	-- game over
	if pl.dead and pl.lives<=0 then
		rectfill(0,0,127,127,0)
		print("game over!",44,56,8)
		print("press ❎ to restart",20,68,7)
		if btnp(4) or btnp(5) then _init() end
	end
end

function draw_title()
	cls(1)
	
	-- animated background
	for i=0,16 do
		local tx=i*16
		local ty=60+sin(t()*0.5+i*0.3)*20
		circfill(tx,ty,12,3+i%2)
	end
	
	-- title
	local bounce=sin(t()*2)*3
	print("★ slime quest ★",28,30+bounce,11)
	print("★ slime quest ★",29,31+bounce,10)
	
	-- slime mascot
	draw_slime(64,70,1,flr(t()*3)%4,false)
	
	-- instructions
	print("⬅️ ➡️  move",34,90,7)
	print("❎ / 🅾️  jump",34,100,7)
	
	if flr(t()*2)%2==0 then
		print("press any button!",26,115,10)
	end
end

-- slime player drawing
function draw_slime(x,y,f,anim,blink)
	local sy=y
	local h=5
	local w=4
	
	-- squish when on ground
	if pl.ongrnd then
		if abs(pl.vx)>0.2 then
			-- running squish
			h=4+sin(anim*1.2)*1.5
			sy=y+(5-h)/2
		else
			-- idle breathe
			h=5+sin(t()*2)*0.5
			sy=y+(5-h)/2
		end
	else
		-- jumping - stretch
		h=6
		sy=y-0.5
	end
	
	-- body (green slime with shading)
	-- main color
	circfill(x,sy-1,w,11)
	rectfill(x-w,sy-1,x+w,sy+2,11)
	-- bottom shadow
	rectfill(x-w+1,sy+2,x+w-1,sy+3,3)
	-- highlight
	circfill(x-f*1.5,sy-2,w-2,3)
	pset(x-f,sy-3,7)
	
	-- eyes
	local ex=x+f*2.5
	local ey=sy-3
	if blink then
		-- closed eyes
		line(ex-2,ey,ex,ey,0)
		line(ex+1,ey,ex+3,ey,0)
	else
		-- open eyes
		circfill(ex-1,ey,2,0)
		circfill(ex+2,ey,2,0)
		-- pupils looking direction
		pset(ex-1+f,ey-1,7)
		pset(ex+2+f,ey-1,7)
	end
	
	-- mouth
	if pl.ongrnd then
		-- happy smile
		pset(x,sy+1,0)
		pset(x-1,sy,0)
		pset(x+1,sy,0)
	else
		-- o mouth when jumping
		circfill(x,sy+1,1,0)
		-- worried eyebrows
		pset(x-2,sy-4,0)
		pset(x+2,sy-4,0)
	end
	
	-- drip when moving
	if pl.ongrnd and abs(pl.vx)>0.5 and flr(t()*8)%4==0 then
		pset(x-f*3,sy+3,3)
	end
end

-- collision system
function collide_map(obj,axis)
	local cx=flr(obj.x/8)+1
	local cy=flr(obj.y/8)+1
	
	for dy=-1,1 do
		for dx=-1,1 do
			local tx=cx+dx
			local ty=cy+dy
			if tx>=1 and tx<=128 and ty>=1 and ty<=16 then
				local tile=level[ty][tx]
				if tile==1 then
					local wx=(tx-1)*8
					local wy=(ty-1)*8
					if rect_overlap(obj.x-obj.w/2,obj.y-obj.h/2,obj.w,obj.h,wx,wy,8,8) then
						if axis=="x" then
							if obj.vx>0 then
								obj.x=wx-obj.w/2
							elseif obj.vx<0 then
								obj.x=wx+8+obj.w/2
							end
							obj.vx=0
						else
							if obj.vy>0 then
								obj.y=wy-obj.h/2
								obj.vy=0
								obj.ongrnd=true
							elseif obj.vy<0 then
								obj.y=wy+8+obj.h/2
								obj.vy=0
							end
						end
					end
				end
			end
		end
	end
end

function rect_overlap(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1<x2+w2 and x1+w1>x2 and y1<y2+h2 and y1+h1>y2
end

function dist(x1,y1,x2,y2)
	return sqrt((x2-x1)^2+(y2-y1)^2)
end

function die()
	if pl.dead then return end
	pl.dead=true
	pl.dead_t=60
	pl.lives-=1
	shake=10
	flash=3
	sfx(4)
	for i=1,15 do
		add_particle(pl.x,pl.y,rnd(5)-2.5,rnd(5)-2.5,11)
	end
	msg="ouch!"
	msg_t=30
	msg_c=8
end

function respawn()
	pl.dead=false
	pl.x=20
	pl.y=80
	pl.vx=0
	pl.vy=0
	pl.inv=90
	shake=3
end

-- particle system
function add_particle(x,y,vx,vy,c)
	add(particles,{
		x=x,y=y,
		vx=vx,vy=vy,
		c=c,
		life=15+rnd(15),
		grav=0.05+rnd(0.1)
	})
end

function update_particles()
	for p in all(particles) do
		p.x+=p.vx
		p.y+=p.vy
		p.vy+=p.grav
		p.life-=1
		if p.life<=0 then del(particles,p) end
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__sfx__
000100000c0500c0500c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000090500a0500b0500c0500d0500e0500f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000f0500e0500d0500c0500b0500a0500905000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000018050180501805018050180501805018050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000100500f0500e0500d0500c0500b0500a0500905008050070500605005050040500305002050010500000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

