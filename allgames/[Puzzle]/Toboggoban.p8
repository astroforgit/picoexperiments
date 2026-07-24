pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	cls()
	flip()
	extcmd("rec")
	
	cartdata("2darray_toboggoban_b")
	currentmap=dget(0)
	mapnames={
		"intro",
		"donut",
		"boomerang",
		"deadly",
		"monocle",
		"the wall",
		"trio",
		"switches",
		"doors",
		"pillars",
		"finale",
		"crop circle"
	}
	maplocations={
		0,0,
		1,0,
		2,0,
		3,1,
		4,0,
		5,0,
		6,0,
		6,1,
		6,2,
		7,0,
		8,1,
		9,0
	}
	
	coroutines={}
	spots={}
	steps={}
	
	state="menu"
	maketreesprites(true)
	fcount=0
	
	undoing=false
	undoflash=0
	endingtimer=0
	
	_pal={129,1,140,12,132,4,137,9,5,134,6,7,3,139,11,138}
	for i,c in pairs(_pal) do
		pal(i-1,c,1)
	end
	
	music(0)
end

function startcoroutine(func)
	local co=cocreate(func)
	add(coroutines,co)
	return co
end

function updatecoroutines()
	for i,co in pairs(coroutines) do
		if costatus(co)!="dead" then
			coresume(co)
		else
			del(coroutines,co)
		end
	end
end

function finishcoroutines()
	for i,co in pairs(coroutines) do
		//printh("skipping coroutine...")
		while costatus(co)!="dead" do
			coresume(co)
		end
		coroutines[i]=nil
	end
end

function addspots(x,z,count,jitter,speed)
	if jitter==nil then
		jitter=5
	end
	if speed==nil then
		speed=1
	end
	for i=1,count do
		local spot={
			x=x+rnd(jitter*2)-jitter,
			y=0,
			z=z+rnd(jitter*2)-jitter,
			vx=rnd(speed*2)-speed,
			vy=rnd(speed*2),
			vz=rnd(speed*2)-speed
		}
		add(spots,spot)
	end
end

function addstep(mx,my,side)
	local step={
		x=mx*16+8.5+side*3,
		y=my*16+13.5,
		life=3+rnd(3),
		seed=time()
	}
	add(steps,step)
	addspots(step.x,step.y,4,3,.2)
end

function updatewalltimers(instant)
	for i,t in pairs(walltimers) do
		if iswall(i/8,i%8,true) then
			if instant==true then
				printh("instant up!")
				walltimers[i]=1
			else
				walltimers[i]=min(t+.1,1)
			end
		else
			if instant==true then
				printh("instant down!")
				walltimers[i]=0
			else
				walltimers[i]=max(t-.1,0)
			end
		end
	end
end

function updatespots()
	srand(time())
	for i,spot in pairs(spots) do
		spot.x+=spot.vx
		spot.y+=spot.vy
		spot.z+=spot.vz
		spot.vx*=.9
		spot.vy*=.9
		spot.vz*=.9
		spot.vy-=.02
		spot.vx+=rnd(.1)-.05
		spot.vz+=rnd(.1)-.05
		if spot.y<0 then
			del(spots,spot)
		end
	end
end

function drawspots()
	for i,spot in pairs(spots) do
		if spot.vy>0 then
			circ(spot.x,spot.z-spot.y,1,10)
		else
			pset(spot.x,spot.z-spot.y,10)
		end
	end
end

function updatesteps()
	for i,step in pairs(steps) do
		step.life-=1/60
		if step.life<=0 then
			del(steps,step)
		end
	end
end

function drawsteps()
	for i,step in pairs(steps) do
		srand(step.seed)
		for j=1,min(step.life*10,10) do
			local x=rnd(6)-3
			local y=rnd(6)-3
			local dist=sqrt(x*x+y*y)
			x/=dist
			y/=dist
			pset(step.x+x*2,step.y+y*2,10)
		end
	end
end

function _update60()
	if state=="menu" then
		updatemenu()
	elseif state=="game" then
		updategame()
	elseif state=="ending" then
		updateending()
	end
end

function updatemenu()
	fcount+=1
	local t=time()%4-1
	menusledx=-20
	if t>0 and t<1 then
		local x=-10+148*t
		addspots(x,37,5)
	end
	menusledx=-10+148*t
	updatespots()
	if btnp()>0 then
		state="game"
		loadmap(true)
	end
end

function updategame()
	if undoflash>0 then
		undoflash-=.5
	end
	updatecoroutines()
	updatespots()
	updatesteps()
	updatewalltimers()
	local canmove=true
	if isplayerdead()==true then
		canmove=false
	end
	if victory==true then
		canmove=false
	end
	if cropcircleformed==true then
		canmove=false
	end
	
	starttracklisten()
	
	if player.dispx==player.x and player.dispy==player.y then
		if player.dashx!=0 then
			player.dashx-=sgn(player.dashx)/16
			if player.dashx==0 then
				addstep(player.dispx,player.dispy,-player.stepside)
			end
		end
		if player.dashy!=0 then
			player.dashy-=sgn(player.dashy)/16
			if player.dashy==0 then
				addstep(player.dispx,player.dispy,-player.stepside)
			end
		end
	end
	
	if canmove then
		if btnp(0) then
			move(player,-1,0,true)
		elseif btnp(1) then
			move(player,1,0,true)
		elseif btnp(2) then
			move(player,0,-1,true)
		elseif btnp(3) then
			move(player,0,1,true)
		end
	end
	
	if btnp(4,1) then
		//prevmap()
	elseif btnp(5,1) then
		//nextmap()
	end
	if cropcircleformed!=true then
		if victory then
			if btnp(5) or btnp(4) then
				nextmap()
			end
		else
			if btnp(4) then
				undo()
			elseif btnp(5) then
				recordundostate()
				registertrackreset()
				finishtracklisten()
				loadmap(false)
				undoflash=12
			end
		end
	end
	
	for i,sled in pairs(sleds) do
		animate(sled)
	end
	animate(player)
	updatehitcount()
	
	if cropcircleformed then
		if endingtimer==0 then
			music(21)
		end
		endingtimer+=1/60
		if endingtimer>4.9 then
			state="ending"
			endingtimer=0
		end
	end
end

function updateending()
	endingtimer+=1/60
	endingtimer=min(endingtimer,10)
	
	if t()==8 then
		//extcmd("video")
		//stop()
	end
	
	if endingtimer==10 then
		if btnp(4) or btnp(5) then
			state="menu"
			reload()
			dset(0,nil)
			maketreesprites(true)
			currentmap=0
			cropcircleformed=false
		end
	end
end

function _draw()
	if state=="menu" then
		drawmenu()
	elseif state=="game" then
		drawgame()
	elseif state=="ending" then
		drawending()
	end
end

function drawmenu()
	cls()
	local w=63
	
	srand(0)
	local gapsize=40
	local gappos=15
	local f=fcount
	local count=100
	for i=1,count do
		local y=i/count*(128-gapsize)
		local x=(148-f/2+flr(rnd(148)))%148-10
		if (y>gappos) y+=gapsize
		
		drawtree(x,y)
	end
	
	local tcell=flr(time()/4)
	srand(tcell+2)
	local oldcol=rnd(2)+2+flr(rnd(4))*4
	local oldscol=max(oldcol-2,1)
	if tcell==0 then
		oldcol=0
		oldscol=0
	end
	srand(tcell+3)
	local newcol=rnd(2)+2+flr(rnd(4))*4
	
	pal(7,oldscol)
	sspr(0,96,w,9,64-w/2,33)
	pal(7,oldcol)
	sspr(0,96,w,9,64-w/2,32)
	clip(0,0,menusledx,128)
	pal(7,max(newcol-2,1))
	sspr(0,96,w,9,64-w/2,33)
	pal(7,newcol)
	sspr(0,96,w,9,64-w/2,32)
	if tcell!=0 then
		clip()
	end
	pal(7,7)
	
	spr(6,menusledx-12,27,2,2)
	srand(time())
	
	cprint("it's sokoban",65,3,1,true)
	cprint("(with toboggans)",72,2,1,true)
	cprint("a game by eli piilonen",90,2,1,true)
	cprint("with music by gruber",98,2,1,true)
	cprint("press a button",112,10+t()%2,8,true)

	clip()
	
	drawspots()
end

function drawgame()
	cropcircleformed=false
	cls(11)
	
	for y=0,7 do
		for x=0,7 do
			srand(x*16+y+currentmap*256)
			local tile=mget(x+mapx,y+mapy)
			if tile>=64 and tile<=71 then
				local s=tile-64
				spr(192+s*2,x*16,y*16,2,2)
				local dx,dy=0,0
				if tile==66 or tile==64 then
					dx=1
				elseif tile==67 or tile==65 then
					dy=1
				end
				if dx!=0 or dy!=0 then
					local cx=0
					local cy=0
					local cw=16
					local ch=16
					if mget(x+mapx+dx,y+mapy+dy)!=tile then
						spr(224+dy*4,x*16,y*16,2,2)
					end
					if mget(x+mapx-dx,y+mapy-dy)!=tile then
						spr(226+dy*4,x*16,y*16,2,2)
					end
				end
			end
		end
	end
	
	drawsteps()
	
	srand()
	for y=0,7 do
		for x=0,7 do
			srand(x*16+y+currentmap*256)
			local tile=mget(x+mapx,y+mapy)
			if tile==4 then
				drawtree(x*16+8,y*16+6)
			elseif tile==5 then
				local hassled=false
				for i,sled in pairs(sleds) do
					if sled.dispx==x and sled.dispy==y then
						hassled=true
						break
					end
				end
				if hassled==false then
					sledhologram(x,y)
				end
			elseif tile==20 then
				for i=0,15 do
					local bx=x*16+rnd(15)
					local by=y*16+i
					local col=9+rnd(2)
					circ(bx,by,1,8)
					line(bx,by,bx,by-1-rnd(2),9+rnd(2))
				end
			elseif tile==36 or tile==52 then
				local t=walltimers[x*8+y]
				rectfill(x*16+1,y*16+1,x*16+14,y*16+14,13)
				rect(x*16+1,y*16+1,x*16+14,y*16+14,12)
				rectfill(x*16+3,y*16+12,x*16+12,y*16+12-t*6,12)
				rectfill(x*16+3,y*16+3-t*6,x*16+12,y*16+12-t*6,14)
				for i=4,11 do
					local bx=x*16+4+i*.618%1*8
					local by=y*16+i-t*6
					local col=9+rnd(2)
					local h=1+rnd(2)*t
					circ(bx,by,t+.5,8)
					if t>0 then
						line(bx,by,bx,by-h,col)
					end
				end
			end
		end
		
		if y==player.y then
			if isplayerdead(true)==false then
				drawplayer(player.dispx,player.dispy)
			else
				drawskull(player.x,player.y)
			end
		end
		for i,sled in pairs(sleds) do
			if flr(sled.dispy)==y then
				if sled.spr!=32 then
					if mget(mapx+sled.dispx,mapy+sled.dispy)==5 then
						pal(12,2)
						pal(10,2)
					else
						palt(12,true)
					end
					mspr2(sled.spr,sled.dispx,sled.dispy)
					pal(12,12)
					pal(10,10)
					palt(12,false)
				else
					drawdeer(sled.dispx,sled.dispy)
				end
			end
		end
	end
	
	drawspots()
	
	if currentmap==0 then
		if displayvictory==false then
			cprint("z: undo",5,3,1,true)
			cprint("x: reset",13,6,1,true)
		end
	end
	
	if currentmap==11 then
		drawandtestcropcircle()
	end
	
	if cropcircleformed==true then
		local t2=mid((endingtimer-1)/2,0,1)
		for i=17,0,-1 do
			local y=(i+t()*2%1)*8
			for j=0,6 do
				if y-j<138*t2 then
					circ(64,y-j-60,60,(i+t()*2)%2*4+3-j/3)
				end
			end
		end
	end
	
	//oprint(mapnames[currentmap+1],2,2,6,5)
	
	//oprint("cpu: "..flr(stat(1)*100).."%",2,10,11,9)
	//oprint("mem: "..flr(stat(0)).." / 2048",2,17,11,9)
	
	if isplayerdead(true) then
		drawvictory(false)
	elseif displayvictory then
		drawvictory(true)
		//oprint("you're winner",10,10,7,5)
	end
	
	if undoflash>0 then
		spr(10,108,5,2,2)
		undoing=false
		srand(time())
		local m=8192
		local s=64
		local r=undoflash/2
		for i=0,undoflash*5 do
			local j=m*3+rnd(m-s-r)
			memcpy(j,j+rnd(r),s)
		end
	end
end

seed=0
function drawending()
	cls()
	
	srand()
	
	for i=0,100 do
		pset(rnd(128),rnd(84),8+(rnd(4)+t()*1.2)%4)
	end
	
	//if btnp(0) then
	//	seed-=1
	//end
	//if btnp(1) then
	//	seed+=1
	//end
	//srand(seed)
	srand(21)
	
	circfill(32,200,120,11)
	circfill(135,196,120,11)
	
	local ut=mid((endingtimer-2)/3,0,1)
	local ut2=min(endingtimer/2,1)
	local ufox=44.5+ut*ut*20+cos(t()/3)
	local ufoy=55.5-ut*ut*80+sin(t()/2)
	local ufotilt=-ut*ut*.03+cos(t()/2)*.015*ut2
	
	local count=0
	
	local nextseed=rnd(-1)
	for i=0.02,.85,.02 do
		
		count+=1
		if count==35 then
			drawufo(ufox,ufoy,ufotilt)
		end
		srand(nextseed)
		nextseed=rnd(-1)
		
		local z=30-sqrt(i)*29
		local p=20/z
		local step=7-i
		for x=-64/p,64/p,step do
			if abs(x+8)>6 or abs(z-7)>2 then
				x+=rnd(step)
				y=sin(x/120)*6+cos(z/70)*6-20+z
				local sx=flr(rnd(8))*16
				local sy=32
				local w=1.5*p
				u=64+x*p-w
				v=84-y*p-w*4
				sspr(sx,sy,16,32,u,v,w*2,w*4)
			end
		end
	end
	
	if endingtimer>5 then
		aprint("congratulations!",38.5,3,1,(endingtimer-6)*20)
		aprint("you invented christmas",49.5,7,5,(endingtimer-8)*20)
	end
	
	//oprint("cpu: "..flr(stat(1)*100).."%",2,10,11,9)
	//oprint("seed: "..seed,2,17,11,9)
end

function drawufo(x,y,a)
	local dx=cos(a)
	local dy=sin(a)
	
	local ut2=min(endingtimer/2,1)
	if ut2<1 then
		local t2=t()*-3%1
		for i=1,15 do
			for j=0,1 do
				local r=(1-ut2)*(3+j)
				local bx=x
				local by=y+1.5+(i+t2)*3
				line(bx-dx*r,by-dy*r+j,bx+dx*r,by+dy*r+j,3+j*4)
			end
		end
	end
	
	srand(7)
	if ut2<1 then
		for i=0,3 do
			local bx=x+rnd(8)-4
			local by=y+60*(1-ut2)+rnd(8)-4
			for i=0,10 do
				pset(bx+rnd(2),by+rnd(2),rnd(3)+4)
			end
		end
	end
	
	circfill(x+dy*3,y-dx*3,4,2)
	circfill(x+dy*3,y-dx*3,3,3)
	for i=-1,1,.1 do
		circ(x-1+dx*i*11,y+1+dy*i*11,4-abs(i)*3.5,9)
		circfill(x+dx*i*11,y+dy*i*11,4-abs(i)*3.5,10)
	end
	line(x-dx*10,y-dy*10,x+dx*10,y+dy*10,1)
	for i=-1,1,.5 do
		i+=t()*3%1*.3
		circfill(x+dx*i*9,y+dy*i*9,1.7-abs(i),2)
	end
	
end

function drawandtestcropcircle()
	cropcircleformed=false
	local bx=104
	local by=120
	local sx=56
	local sy=112
	local fail=false
	local trackcount=0
	local sledinplace=false
	for x=0,7 do
		for y=0,7 do
			local p=sget(bx+x,by+y)
			local tracked=hastrack(x,y)
			if p!=0 then
				local col=8
				if tracked then
					col=9
					trackcount+=1
				end
				circfill(sx+x*2,sy+y*2,1,col)
			
				if p==10 then
					local sled=getsled(x,y)
					if sled==nil or sled.dx==nil then
						circ(sx+x*2,sy+y*2,2,4+t()%2)
					else
						circfill(sx+x*2,sy+y*2,2,6)
						sledinplace=true
					end
				end
			elseif tracked then
				fail=true
			end
		end
	end
	
	if fail then
		fline(sx+2,sy+2,sx+14,sy+14,2.5,1.5,7,6)
		fline(sx+14,sy+2,sx+2,sy+14,2.5,1.5,7,6)
	end
	
	local deercount=0
	if trackcount==22 and sledinplace then
		for x=0,7 do
			for y=0,7 do
				local p=sget(bx+x,by+y)
				if p==7 then
					local sled=getsled(x,y)
					local col=14
					if sled==nil or sled.dx!=nil then
						circ(sx+x*2,sy+y*2,2,13+t()%2)
					else
						circfill(sx+x*2,sy+y*2,2,15)
						deercount+=1
					end
				end
			end
		end
		
		if deercount==2 then
			if player.x==1 and player.y==6 then
				cropcircleformed=true
				if stat(24)<21 then
					music(21)
				end
				circfill(sx+2,sy+12,2,3)
			else
				circ(sx+2,sy+12,2,1+t()%2)
			end
		end
	end
end

function isplayerdead(display)
	local x=player.x
	local y=player.y
	if display==true then
		if x!=player.dispx or y!=player.dispy then
			return false
		end
	end
	if x%1==0 or y%1==0 then
		if iswall(x,y,true) then
			return true
		elseif mget(x+mapx,y+mapy)==20 then
			return true
		end
	end
	return false
end

function drawvictory(didwin)
	local w=27
	local sy=112
	if didwin==false then
		w=36
		sy=120
		pal(7,5)
	else
		pal(7,1)
	end
	for x=-1,1 do
		for y=-1,1 do
			sspr(66,sy,w,8,64-w/2+x,60+y)
		end
	end
	pal(7,11)
	sspr(66,sy,w,8,64-w/2,60)
	pal(7,7)
	
	if didwin==false then
		cprint("press z to undo",110,3,1,true)
		cprint("press x to reset",118,2,1,true)
	else
		cprint("press x to continue",80,3,1,true)
	end
end

function sledhologram(mx,my)
	local t=time()+rnd(-1)
	pal(4,0)
	pal(5,1)
	pal(6,2)
	pal(7,3)
	local m=-t*8
	srand(flr(t/2))
	local f=rnd(4)
	local sx=48+flr(f/2)*16
	local sy=flr(f%2)*16
	local x=mx*16
	local y=my*16
	local t2=t%2/2
	local t3=1-abs(t2-.5)*2
	local count=min(t3*3,1)*300
	for i=1,count do
		local u=(rnd(16)-m)%16
		local v=rnd(16)
		local p=sget(sx+u,sy+v)
		local r=rnd(1.2)
		if p>0 and p!=12 then
			circ(x+u,y+v,r,p)
		end
	end
	pal(4,4)
	pal(5,5)
	pal(6,6)
	pal(7,7)
end

function updatehitcount()
	victory=true
	displayvictory=true
	if isplayerdead() then
		victory=false
		displayvictory=false
	end
	hitcount=0
	delayhitcount=0
	for i,sled in pairs(sleds) do
		if ontarget(sled) then
			hitcount+=1
		else
			victory=false
		end
		if ontarget(sled,true) then
			delayhitcount+=1
		else
			displayvictory=false
		end
	end
end

function drawtree(x,y)
	spr(64+flr(rnd(8))*2,x-8+rnd(4)-2,y-15+rnd(4)-2,2,4)
end

function maketracksprites()
	for i=0,8 do
		local sx=i*8
		local sy=32
		local dx=i*16
		local dy=96
		maketracksprite(sx,sy,dx,dy)
	end
	maketrackmask(0,112,1,0)
	maketrackmask(16,112,-1,0)
	maketrackmask(32,112,0,1)
	maketrackmask(48,112,0,-1)
end

function maketracksprite(sx,sy,dx,dy)
	for x=0,15 do
		for y=0,15 do
			local p1=sget(sx+x/2,sy+y/2)
			for i=0,1 do
				local x2=mid(x+rnd(2)-1,0,15)
				local y2=mid(y+rnd(2)-1,0,15)
				local p2=sget(sx+x2/2,sy+y2/2)
				if p1!=p2 then
					sset(dx+x,dy+y,10)
				else
					sset(dx+x,dy+y,0)
				end
			end
		end
	end
end

function maketrackmask(x,y,dx,dy)
	x+=8
	y+=8
	for i=-8,7 do
		local bx=x+dx*7.5+dy*i
		local by=y+dy*7.5-dx*i
		for j=0,1+rnd(6) do
			sset(bx-dx*j,by-dy*j,11)
		end
	end
end

function maketreesprites(menu)
	srand(currentmap)
	local scol1=10
	local scol2=9
	if menu then
		scol1=1
		scol2=2
	end
	for j=0,7 do
		local snowchance=rnd(5)+5
		cls()
		local x=8
		local y=21
		for a=rnd(),40,.618 do
			local r=(1-a/40)*(3+rnd())
			for i=0,1 do
				local col=12+a/10+rnd()-i
				col=mid(col,12,14)
				if rnd(snowchance)<1 then
					col=11
				end
				circfill(x+i+cos(a)*r,
				     y-i-a*.4+sin(a)*r,
				     r+rnd(),col)
			end
		end
		for u=0,15 do
			for v=0,31 do
				local col=pget(u,v)
				local x2=u+j*16
				local y2=v+32
				if col!=0 then
					if pget(u,v+1)==0 then
						sset(x2,y2,scol1)
					elseif pget(u,v+2)==0 then
						sset(x2,y2,scol2)
					elseif pget(u,v-1)==0 or pget(u+1,v)==0 then
						sset(x2,y2,15)
					else
						sset(x2,y2,col)
					end
				else
					sset(x2,y2,0)
				end
			end
		end
	end
	cls()
end

function move(obj,mx,my,canpush,tdelay)
	if tdelay==nil then
		tdelay=1
	end
	if obj==player then
		recordundostate()
	end
	local nx=obj.x+mx
	local ny=obj.y+my
	local tile=mget(nx+mapx,ny+mapy)
	local canmove=true
	local didpush=false
	if nx<0 or ny<0 or nx>7 or ny>7 then
		canmove=false
	end
	
	if iswall(nx,ny) then
		canmove=false
	else
		local sled=getsled(nx,ny)
		if sled then
			if canpush==false then
				canmove=false
			elseif move(sled,mx,my,true)==false then
				canmove=false
			else
				didpush=true
			end
		end
	end
	
	if canmove==false then
		if obj==player then
			discardundorecord()
		end
		return false
	end
	
	local oldx=obj.x
	local oldy=obj.y
	obj.x=nx
	obj.y=ny
	
	local laststep=true
	if obj.dx and didpush==false then
		if obj.dx*mx+obj.dy*my==1 then
			if move(obj,mx,my,false,tdelay+2) then
				laststep=false
				sfx(2)
			end
		else
			sfx(3)
		end
	end
	
	if obj.dx then
		maketrack(oldx,oldy,obj.dx,obj.dy,mx,my,tdelay,true)
		if laststep==true then
			maketrack(nx,ny,obj.dx,obj.dy,mx,my,tdelay,false)
		end
	end
		
	if obj==player then
		finishtracklisten()
		if didpush==false then
			sfx(0)
		end
		player.dashx=mx
		player.dashy=my
		player.stepside=-player.stepside
	end
	return true
end

function isblank(tile)
	if tile==0 then
		return true
	elseif tile>=64 and tile<=72 then
		return true
	end
	return false
end

function hastrack(x,y)
	local tile=mget(mapx+x,mapy+y)
	if tile>=64 and tile<=72 then
		return true
	end
	return false
end

function maketrack(x,y,dx,dy,mx,my,delay,dospots)
	
	local tile=mget(mapx+x,mapy+y)
	if isblank(tile)==false then
		return
	end
	local newtile=tile
	if dy==0 then
		if my==0 then
			newtile=64
		else
			newtile=67
		end
	else
		if mx==0 then
			newtile=65
		else
			newtile=66
		end
	end
	
	registertrackedit(x,y,tile,newtile)
	local co=startcoroutine(delayedtrack)
	coresume(co,x,y,mx,my,newtile,delay,dospots)
end

function delayedtrack(x,y,mx,my,newtile,delay,dospots)
	local i=0
	while delay>0 do
		delay-=1
		yield()
		if dospots==true then
			addspots(x*16+8+mx*i*4,
			         y*16+11+my*i*4,
			         8)
		end
		i+=1
	end
	
	mset(mapx+x,mapy+y,newtile)
end

function iswall(x,y,delayed)
	local tile=mget(x+mapx,y+mapy)
	if tile==4 then
		return true
	elseif tile==36 or tile==52 then
		local flipper=1
		if (tile==52) flipper=0
		if delayed==true then
			if delayhitcount%2==flipper then
				return true
			end
		elseif hitcount%2==flipper then
			return true
		end
	end
	return false
end

function animate(obj)
	local speed=.5
	if abs(obj.x-obj.dispx)>speed then
		obj.dispx+=sgn(obj.x-obj.dispx)*speed
	else
		if obj==player and obj.dispx!=obj.x then
			addstep(obj.x,obj.y,player.stepside)
		end
		obj.dispx=obj.x
	end
	if abs(obj.y-obj.dispy)>speed then
		obj.dispy+=sgn(obj.y-obj.dispy)*speed
	else
		if obj==player and obj.dispy!=obj.y then
			addstep(obj.x,obj.y,player.stepside)
		end
		obj.dispy=obj.y
	end
end

function getsled(x,y)
	for i,sled in pairs(sleds) do
		if x==sled.x then
			if y==sled.y then
				return sled
			end
		end
	end
end

function ontarget(sled,delayed)
	if delayed then
		if sled.x!=sled.dispx then
			return false
		end
		if sled.y!=sled.dispy then
			return false
		end
	end
 return mget(sled.x+mapx,sled.y+mapy)==5
end

function mspr(sprite,x,y)
	local sx=sprite%16
	local sy=flr(sprite/16)
	sspr(sx*8,sy*8,8,8,x*16,y*16,16,16)
end
function mspr2(sprite,x,y)
	local index=flr(x)*8+flr(y)
	local yoff=0
	if walltimers[index]!=nil then
		yoff=walltimers[index]*-6
	end
	spr(sprite,x*16,y*16+yoff,2,2)
end

function drawplayer(x,y)
	local sx=x*16+8.5
	local sy=y*16+13
	
	local a=t()/2
	
	local neckx=sin(a+.06)/2+player.dashx*5
	local necky=player.dashy*1.5
	local hipx=player.dashx*3
	local hipy=sin(a+.02)/2+min(player.dashy,0)
	local stepy=abs(player.dashx-player.dashy*.6)*7
	
	for k=0,1 do
		for i=-1,1,2 do
			local kneex=sin(a-i/8)/2-.5
			local footy=stepy
			local handy=max(stepy-3,0)+abs(player.dashy)*2
			if player.stepside==i then
				footy=0
				handy*=2
			end
			for j=0,1,.2 do
				circfill(sx+(3+kneex*j)*i+k+hipx/2*j,sy-j*2+hipy/2*j-footy*(1-j/2),1,1+k)
			end
			for j=0,1,.1 do
				circfill(sx+(3+kneex)*j*i+k+hipx*(1-j),sy-5+j*(3+hipy)-footy*(1-j/2),1,1+k)
			end
			local handx=sin(a-i/3+.1)/2
			for j=0,1,.1 do
				circfill(sx+k+j*i*(4+handx+handy/4)+neckx/2*j,sy-10+j*j*5+necky*(1+j)-handy*j,1,6+k)
			end
		end
		for i=0,1,.1 do
			circfill(sx+k+neckx*i+hipx/2,sy-7-i*5+necky*(i/2)*1.5+hipy*2*(1-i),2-i,5+k)
		end
	end
	
	for i=0,1 do
		circfill(sx+neckx+i,sy-14+necky,2,4+i)
	end
	
end

function drawdeer(mx,my)
	local x=mx*16+8
	local y=my*16+7
	
	local a=sin(time()/2)/2
	local b=cos(time()/2)/2
	
	// legs
	for k=-1,1,2 do
		for j=-1,1,2 do
			local m=a
			local n=b
			if j*k==1 then
				m=b
				n=a
			end
			fline(x-1-(4+k*1.5)*j,
			      y-2+m*3,
			      x-1-(5+k*1.5)*j,
			      y+6+k,
			      2,1,
			      5+k/2,4)
		end
	end
	// torso
	fline(x-5,y-3+b/2,x+6,y-2+a/2,3.6,2,5,4)
	fline(x-4,y-2+b/2,x+5,y-2+a/2,1,1,7,6)
	circfill(x+3,y-3,2,6)
	//circfill(x-7,y-3,2,5)
	
	// antlers
	for k=-1,1,2 do
		fline(x+7-k*2-b,y-6.5+k/2+a,x+5-k*2-b,y-10+a,0,1,7+k/2,6+k/2)
		for j=-1,1,2 do
			fline(x+4-k*2-b,y-9+a,x+6-k*2+j*4-b,y-13+a,1,0,7+k/2,6+k/2)
		end
		
		if k==-1 then
			// head
			fline(x+6,y-5+a,x+11,y-2.5+a*2,2.5,2,5,4)
			circfill(x+11,y-2.5+a*2,1,4)
			pset(x+7,y-4.4+a*1.5,0)
			pset(x+9,y-5.5+a*1.5,0)
			circfill(x+6,y-7,1,5)
		end
	end
	
end

function fline(x1,y1,x2,y2,r1,r2,col1,col2)
	local dx=x2-x1
	local dy=y2-y1
	local dr=r2-r1
	for j=1,0,-1 do
		local col=col1
		if j==1 then
			col=col2
		end
		for i=0,1,.1 do
			local r=r1+dr*i
			circfill(x1+dx*i-j*r/2,y1+dy*i+j*r/2,r,col)
		end
	end
end

function drawskull(mx,my)
	local x=mx*16+2
	local y=my*16-1
	pal(9,1)
	pal(10,1)
	pal(11,1)
	for ox=-1,1 do
		for oy=-1,1 do
			spr(238,x+ox,y+oy,2,2)
		end
	end
	pal(9,9)
	pal(10,10)
	pal(11,11)
	spr(238,x,y,2,2)
end

function nextmap()
	currentmap+=1
	if currentmap==#mapnames then
		currentmap=0
	end
	loadmap(true)
end

function prevmap()
	currentmap-=1
	if currentmap<0 then
		currentmap=#mapnames-1
	end
	loadmap(true)
end

function loadmap(resetundo)
	if currentmap==nil or currentmap<0 or currentmap>#mapnames-1 then
		currentmap=0
	end
	hitcount=0
	delayhitcount=0
	
	if coroutines!=nil then
		finishcoroutines()
	end
	
	endingtimer=0

	dset(0,currentmap)
	reload()
	maketracksprites()
	maketreesprites()
	menuitem(1)
	menuitem(2)
	
	mapx=maplocations[currentmap*2+1]
	mapy=maplocations[currentmap*2+2]
	
	mapx*=8
	mapy*=8
	
	if currentmap<#mapnames-1 then
		menuitem(1,"next",nextmap)
	end
	if currentmap>0 then
		menuitem(2,"previous",prevmap)
	end
	
	sleds={}
	walltimers={}
	spots={}
	steps={}
	switchdelay=0
	
	for x=0,7 do
		for y=0,7 do
			local tile=mget(mapx+x,mapy+y)
			if tile==1 then
				makeplayer(x,y)
				mset(mapx+x,mapy+y,0)
			elseif tile==2 or tile==3 or tile==18 or tile==19 or tile==34 then
				addsled(x,y,tile)
				mset(mapx+x,mapy+y,0)
			elseif tile==36 then
				walltimers[x*8+y]=0
			elseif tile==52 then
				walltimers[x*8+y]=1
			end
		end
	end
	
	
	if resetundo then
		//x/y for all sleds and player
		undostride=#sleds*2+2
		undostate={}
		trackundo={}
	end
	
	//cls()
	//spr(0,0,0,16,16)
	//::_:: flip()goto _
end

function recordundostate()
	for i,sled in pairs(sleds) do
		add(undostate,sled.x)
		add(undostate,sled.y)
	end
	add(undostate,player.x)
	add(undostate,player.y)
end
function starttracklisten()
	trackframecount=0
end
function registertrackedit(x,y,old,new)
	if isblank(old) then
		if new!=old then
			//printh(x..","..y.." - "..(new-old))
			add(trackundo,x*8+y)
			add(trackundo,new-old)
			trackframecount+=1
		end
	end
end
function registertrackreset()
	for x=0,7 do
		for y=0,7 do
			registertrackedit(x,y,mget(mapx+x,mapy+y),0)
		end
	end
end
function finishtracklisten()
	add(trackundo,trackframecount)
	//printh("trackundo: "..#trackundo)
end

function discardundorecord()
	local index=#undostate-undostride
	for i=1,undostride do
		undostate[index+i]=nil
	end
end

function undo()
	local index=#undostate-undostride
	if index<0 then
		return
	end
	
	for i=1,undostride-2,2 do
		local sled=sleds[(i-1)/2+1]
		sled.x=undostate[index+i]
		sled.y=undostate[index+i+1]
		sled.dispx=sled.x
		sled.dispy=sled.y
		undostate[index+i]=nil
		undostate[index+i+1]=nil
	end
	index+=undostride-2
	player.x=undostate[index+1]
	player.y=undostate[index+2]
	player.dispx=player.x
	player.dispy=player.y
	undostate[index+1]=nil
	undostate[index+2]=nil
	
	if #trackundo>0 then
		finishcoroutines()
		local count=trackundo[#trackundo]
		index=#trackundo-count*2
		for i=0,count*2-1,2 do
			local j=index+i
			local cellid=trackundo[j]
			local x=mapx+cellid/8
			local y=mapy+cellid%8
			local delta=trackundo[j+1]
			local tile=mget(x,y)
			//printh(x..","..y..": "..delta..", "..(tile-delta))
			mset(x,y,tile-delta)
		
			trackundo[j]=nil
			trackundo[j+1]=nil
		end
		trackundo[index+count*2]=nil
	end
	
	spots={}
	steps={}
	updatehitcount()
	updatewalltimers(true)
	
	undoing=true
	undoflash=min(undoflash+5,10)
end

function makeplayer(x,y)
	player={
		x=x,
		y=y,
		dispx=x,
		dispy=y,
		dashx=0,
		dashy=0,
		stepside=1
	}
end

function addsled(x,y,tile)
	local sled={x=x,y=y}
	if tile==2 then
		sled.dx=1
		sled.dy=0
		sled.spr=6
	elseif tile==3 then
		sled.dx=0
		sled.dy=1
		sled.spr=8
	elseif tile==18 then
		sled.dx=-1
		sled.dy=0
		sled.spr=38
	elseif tile==19 then
		sled.dx=0
		sled.dy=-1
		sled.spr=40
	elseif tile==34 then
		sled.spr=32
	end
	sled.dispx=x
	sled.dispy=y
	add(sleds,sled)
end

function oprint(text,x,y,col,ocol)
	print(text,x-1,y,ocol)
	print(text,x+1,y,ocol)
	print(text,x,y-1,ocol)
	print(text,x,y+1,ocol)
	print(text,x,y,col)
end

function cprint(text,y,col,ocol,box)
	if box then
		rectfill(62-#text*2,y-1,64+#text*2,y+5,0)
		rectfill(63-#text*2,y-2,63+#text*2,y+6,0)
	end
	oprint(text,64-#text*2,y,col,ocol)
end

function aprint(text,y,col,ocol,count)
	local tcount=#text
	local x=64-tcount*2
	local a=t()
	for i=1,min(count,tcount) do
		local char=sub(text,i,i)
		print(char,x+(i-1)*4,y+1+sin(a+i/20)*2,ocol)
		print(char,x+(i-1)*4,y+sin(a+i/20)*2,col)
	end
end
__gfx__
00000000000000000000000000000000dddddddd0999999000000000000000000000000000000000000000000000000000000000000000007777777777777777
00000000000550000000000000494900dddddddd90000009000000000000000000ccc00000ccc0008b000008b000008b00000000000000007777777774999997
00700700000550000999994005494950dddddddd90000009000000000000000000c8ccccccc8c0008b000088b000088b00000000000000007777777764444447
00077000066666600444444705494950dddddddd90000009000000000000000000c444444444c0008b000888b000888b00000000000000007777777764999997
00077000006666000999994005494950dddddddd9000000900cccccccccccccc00c544676445c0008b0088b8b0088b8b00000000000000007777777774444447
00700700001111000444444005494950dddddddd9000000900c45555555555c900c544676445c0008b088bb8b088bb8b00000000000000007777777767477477
00000000001111000040040706444460dddddddd900000090cc44444444444c900c544676445c0008b88bbb8b88bbb8b00000000000000007777777766555557
00000000001001000555556007000070dddddddd099999900c4777777777779c00c544676445c000888bbbb888bbbb8b00000000000000007777777777777777
00000000000000000000000000000000d5d5d5d500000000cc466666666666c000c544676445c000888bbbb888bbbb8b00000000000000007777777777744777
000000000000000000000000004444005d5d5d5d00000000c444444444444acc00c544676445c0008b88bbb8b88bbb8b00000000000000007999994777744777
00000000000000000499999007494970d5d5d5d500000000c45555555555ac9c00c544676445c0008b088bb8b088bb8b00000000000000007444444679999997
000000000000000074444440064949605d5d5d5d00000000cca84aaaa84aac9c00c544676445c0008b0088b8b0088b8b00000000000000007999994677999977
00000000000000000499999005494950d5d5d5d500000000caa84aaaa84ac9cc00c4a46764a4c0008b000888b000888b00000000000000007444444777111177
000000000000000004444440054949505d5d5d5d00000000c888888888899cc000c9aaa7aaa9c0008b000088b000088b00000000000000007747747677111177
00000000000000007040040005494950d5d5d5d500000000cccccccccccccc0000c9caaaaac9c0008b000008b000008b00000000000000007555556677177177
000000000000000006555550050000505d5d5d5d00000000000000000000000000ccc00a00ccc000000000000000000000000000000000007777777777777777
0000000000000000000000000000000000d00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000707000000000d0000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007000000000d000000d00000000000000000000000000ccc0ccc0ccc000000000000000000000000000000000000000000000000000
000000000707060005555655000000000000000000000000000000000000000000c9ccc7ccc9c000000000000000000000000000000000000000000000000000
000000000076060005566650000000000000000000000000cccccccccccccc0000c9c46764c9c000000000000000000000000000000000000000000000000000
00000000007060000050050000000000d000000d000000009c55555555554c0000c544676445c000000000000000000000000000000000000000000000000000
000000000007000000500500000000000d0000d0000000009c44444444444cc000c544676445c000000000000000000000000000000000000000000000000000
0004555000545400000000000000000000d00d0000000000c9777777777774c000c544676445c000000000000000000000000000000000000000000000000000
4545555577551444000000000000000000000000000000000c666666666664cc00c544676445c000000000000000000000000000000000000000000000000000
0455577777555544000000000000000000dddd0000000000cca444444444444c00c544676445c000000000000000000000000000000000000000000000000000
045777777777000000000000000000000dddddd000000000c9ca55555555554c00c544676445c000000000000000000000000000000000000000000000000000
045555555550000000000000000000000dddddd000000000c9caa48aaaa48acc00c544676445c000000000000000000000000000000000000000000000000000
054000000450000000000000000000000dddddd000000000cc9ca48aaaa48aac00c544676445c000000000000000000000000000000000000000000000000000
054000000450000000000000000000000dddddd0000000000cc998888888888c00c444444444c000000000000000000000000000000000000000000000000000
0500000000500000000000000000000000dddd000000000000cccccccccccccc00c4aaaaaaa4c000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000c8aaaaaaa8c000000000000000000000000000000000000000000000000000
00000000060006000000000006506060000000000600006000000000067565600000000000000000000000000000000000000000000000000000000000000000
00000000060006006666666606506060666666660600006066666666067565600000000000000000000000000000000000000000000000000000000000000000
00000000060006000000000006506060000000000600006000000000067565600000000000000000000000000000000000000000000000000000000000000000
66666666060006006666666606506060000000000600006066666666067565600000000000000000000000000000000000000000000000000000000000000000
00000000060006000000000006506060000000000600006000000000067565600000000000000000000000000000000000000000000000000000000000000000
00000000060006005555555506506060000000000600006054455445044564400000000000000000000000000000000000000000000000000000000000000000
66666666060006006666666606506060665665660650056064466446044564400060060000000000000000000000000000000000000000000000000000000000
00000000060006000000000006506060000000000600006000000000067565600000000000000000000000000000000000000000000000000000000000000000
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
77777700777007777000777000777700077770007770077770007770070007000000000000000000000000000000000000000000000000000000000000000000
77777707777707777707777707777770777777077777077777077777077007700000000000000000000000000000000000000000000000000000000000000000
00770007707707707707707707700770770077077077077077077077077707700000000000000000000000000000000000000000000000000000000000000000
00770007707707707707707707700000770000077077077077077077077777700000000000000000000000000000000000000000000000000000000000000000
00770007707707777007707707700000770000077077077770077777077077700000000000000000000000000000000000000000000000000000000000000000
00770007707707707707707707707770770777077077077077077777077007700000000000000000000000000000000000000000000000000000000000000000
00770007707707707707707707700770770077077077077077077077077007700000000000000000000000000000000000000000000000000000000000000000
00770007777707777707777707777770777777077777077777077077077007700000000000000000000000000000000000000000000000000000000000000000
00770000777007777000777000777700077770007770077770077077077007700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077770777707777700070777770700000000000000000000000abbbb0000000
000000000000000000000000000000000000000000000000000000000000000000700007007000700000700070007000000000000000000000aabbbbbbb00000
0000000000000000000000000000000000000000000000000000000000000000007000070070007000007000700070000000000000000000099bbbbbbbaa0000
0000000000000000000000000000000000000000000000000000000000000000007077070070007000007000700070000000000000000000099bbbbbbbaa0000
0000000000000000000000000000000000000000000000000000000000000000007007070070007000007000700070000000000000000000999bbababbaaa000
000000000000000000000000000000000000000000000000000000000000000000700707007000700000700070000000000000000000000099ba99b999baa000
0000000000000000000000000000000000000000000000000000000000000000007777077770007000007000700070000000000000000000aba00090009bb000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009b0000a0000ba000
00000000000000000000000000000000000000000000000000000000000000000070070777707007000077700707777077700000000000009b0009ba000ba000
0000000000000000000000000000000000000000000000000000000000000000007007070070700700007007070700007007000007bbbb700bbbb90abbbb0000
000000000000000000000000000000000000000000000000000000000000000000700707007070070000700707070000700700000b0bb0b0099bb808bbaa0000
000000000000000000000000000000000000000000000000000000000000000000777707007070070000700707077700700700000b0bb0b0000bababab000000
000000000000000000000000000000000000000000000000000000000000000000000707007070070000700707070000700700000b0bb0b0000a9b9b9a000000
000000000000000000000000000000000000000000000000000000000000000000000707007070070000700707070000700700000b0000b000090a9a0a000000
00000000000000000000000000000000000000000000000000000000000000000077770777707777000077700707777077700000030000a000000a0a00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000001010000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040424000005000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404000000040404000200000505040400000000000004040404040404040404000000050000040401000000040504040404000034050404010000243414340000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400030000000504040005120001040404010000000000040400000404000004040500000004050404000200000100040400000000001404040100000000340404000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401000000000004040000040400000404040404040000040400020404000004040404000004140404000000001400040400000300000004040000040000040400000000000013000000000100000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000004040000040400000404040404040000040400000404000004040000000013000404000000001400040400001313000004040002020014050403000000240000000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400020000000504040400000000000404040404040013040400000014000104040000000012000404000300001400040400000000001404040000040004040434000002052400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040400000004040404040404040000040400000014000504040000040400010404000000000500040405040000040504040000000004040405000000000000040012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404042424242404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040404040404040404040404040404040404040404040404000000000000000000000000000000000404040404040404000000000000000004040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000401000000001405040400000000140504000000000000000000000000000000000404040404040404000000000000000004010000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000002010414141414001414040400010000141404000000000000000000000000000000000401000200000504000000000000000004000400000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000040404040400000000001400040400020000030004000000000000000000000000000000000434040404040404000000000000000004000200052414040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000040404040400141414141400040400000000000004000000000000000000000000000000000400000200000504000000000000000004000400000034040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000000400140000001413040414140000000004000000000000000000000000000000000424040404040404000000000000000004000000030014040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040000000000050400000014000000040405140000000004000000000000000000000000000000000400000200000504000000000000000004000000000405040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000040404040404040404040404040404040404040404040404000000000000000000000000000000000404040404040404000000000000000004040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000401000024000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000024020005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000434343404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000024000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024020004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000024000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000161400611006150160501601006010260100601026010160103601046010060100601006010060100601016010060123601006010060100601006010060100601006010060100601006010060100601
01080000135161f516135162b51724516245153050624506005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0102000007610096100b6100e6100f610106101161012610136101461015620166201762017620176201762017620176201762017620166201461013610116100d6100b610076100561001610000000000000000
0101000007610096100b6100e6100f610106101161012610136101461015620166201762017620176201762017620176201762017620166201461013610116100d6100b610076100561001610000000000000000
0001000013610036100e610066100d610096100361001610016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000e65014650176501b6501b6501d6501b6501965015650136500f6500e6500b6500b650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001965022650286502b6502c6502d6502d6502d650000002d6502d6502b650276501d650116500e65000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000026650296502c6502f65034650366503665035650336502f6502c650276502165017650106500f65000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000e51617716115160e7161051617716115160e716175161071611516177160c5160e71617516107161151617716105160e716175160c7160e516177161051611716175161071611516177160c51610716
010300000e54617746115460e7461054617746115460e746175461074611546177460c5460e74617546107461154617746105460e746175460c7460e546177461054611746175461074611546177460c54610746
010f00000c04303415034150c0433c615034150c0330c033034150c043034150c0433c61503415034150c0330c04303415034150c0433c615034150c0230c033034150c043034150c0433c615306150c0330c033
010f00000a8500a8200a3450a8500a8200a3450a8500a8200a3450a8500a8200a34500000000000a3350a3450a8500a8200a3450a8500a8200a3450a8500a8200a3450a8500a8200a34503415000000341500000
010f000029440292152b4402b230294202624024420222402444024225244402624024420222401f4401f2351d4401d2401d2321d2250000011025000000000011025000001d4401f22022440242202644027220
010f00000a8500a8200a3450a8500a8200a3450a8500a8200a3450a8500a8200a34500000000000a3350a3450a8500a8200a3450d8500d8200d3450f8500f8250f8500f8500f8200f81505850058400583005820
010f000029440292152b4402b230294202624024420222402444024225244402624024420222401f4401f2252244022230224250832008312083150a3200a3150a3200a310294402922529440292252944029225
010f00000a8500a8200a3450a8500a8200a3450a8500a8200a3450a8500a8200a34500000000000a3350a3450a8500a8200a3450d8500d8200d3450a8500a8200a8500a8200a3450a81008811078110482102831
010f000029440292252b4402b230294202624024420222402444024215244402624024420222401f4401f22522440224322222508320083100831505320053100532005310053151d71429711357111e2401f440
010f00000c0433f4153f4150c0033c615153353f415093550c0430c0330c0233f4153c615093553f415093550c0433f4153f4150c0433c6153f4153f4150c0433f4150c0433f4150c0433c615306150c0230c033
010f00000985026410262151e4101f2101585526215098551585526210262152841028215158550e805098550e8500e8400e8301584015830158201c8501e8411e8251c8451a845178551585512855108550f855
010f000026440262251e4401f24026440262251e4401f240264402622528440282252544025225217161e7161e71619716264402642525440214401e4401e4252344023432234152f5252d5252a527285251e525
010f00000c04303415034150c0033c6151330503415073050c0430c0330c023034153c6150730503415073050c04303415034150c0433c61503415034150c043034150c043034150c0433c615306150c0230c033
010f000010850040451304517850040450b325108500932515850190251302515850150550935509850093550e8500e845020451585015845090451c8501e8411e8351c8551a855178551585512855108550e855
010f00000000000000264402622225440212401e4401e2252344023220264402622025440252202844021440214422123221422212151a7261e7262571621716007001e425212252342525227284251c2401d440
010f00000c04303415034150c0033c6151333503415073550c0430c0330c023034153c6150735503415073550c04303415034150c0433c61503415034150c043034150c043034150c0433c615306150c0230c033
010f00000785024410242151c4101d2101385524215078551385524210242152641026215138550c805078550c8500c8400c8301384013830138201a8501c8411c8301c8201c8151a85518855158551385510855
010f000024440242251c4401d24024440242251c4401d2402444024225264402622523440232251f7161c7161c716177162444024425234401f4401c4401c4252144021432214152652524525215271f5251c525
010f00000c0433f4153f4152922029322242220c0430c0430c0432222222222242222922224222242220c0430c0430c0433c227302170c043300003c227302170c04300000000000000000000000000c00300000
010f00000015000152001520014100140001311832318333001500015200152001410014000131183231833305850058420583205825058500584205832058250585005845001000010500100001001830318303
010f00003c6150000029440292402444024240224401d240224402224024440292402444024240224401d24022440222202444229242244422424222442222421d4421d225294402922529440292252944029225
010f000029440292152b4402b230294202624024420222402444024225244402624024420222401f4401f22522440224322222508320083100831505320053100532005310053151d71429711357111e3201f330
010f00000c04309425152350c04309425152350c03309425152350c043152350c0433c61502044263110c0330c04303415034150c0433c615034150c0230c033034150c043034150c0433c615306150c0330c033
010f00000e850020250e0150e850020250e0150e850020250e0150e850020250e0150e850020450e850020450e85011934119351194511945174201c2101e4202121023420282172a4202d2102f4273421036420
010f0000213451541521345154152134515415213451541521345154152134515415213451541521345154152634014934149351493514945149051f3401f3101e3401e3401e3221e3221e3121e3121a3401c340
010f00000e850020250e0150e850020250e0150e850020250e0150e850020250e0150e850020450e850020450e850119341193511945119453b4203921036420342102f4202d2172a4202821023427212101e420
010f00001e345124151e345124151e345124151e345124151e345124151e345124151e345124151e345124152334014934149351493514945149051e3401e3101c3401c3401c3221c3221c3121c3121734018340
010f00000c04303415034150c0033c6151530503415093050c0430c0330c023034153c6150930503415093050c04303415034150c0433c61503415034150c043034150c043034150c0433c615306150c0230c033
010f00000885008840080450485004840040400985009840090451585015840150450a8500a8400a0451685016840160450b8500b8400b0451785017840108501084012140101450b1450714506145021450e145
010f00001a34018440173401741017340174201a3401834018332182221f4401f2201e4401e3321e2221c3401a440262202344024221234402f222214401f2401f4302b2201f4102b2151f402000001e3401c440
010f00000d8500d840100450f8500f8401204510850108401304511850118401104506840128401e035068400b8400b8400b0451785017840178300b8500b8451c831098550b855178550c855188550d85519855
010f00001e3401c3401b340273251b340273261c3401e3401e3222a327273402834127340333262534023340233362f326233172f317233122f3122330000000321253e0252d1263902526125320261e3401f340
010f00001a34018440173401741017340174201a3401834018332182221f4401f2201e4401e3321e2221c3401a440262202344024221234402f222214401f2401f4302b225213202333026325283302d32632330
010f00000c0433f4153f4152622026322212220c0430c0430c0431f2221f222212222622221222212220c0430c0430c043392272d2170c0432d000392272d2170c0433f4153f4153f4153f415213132132321333
010f0000098500985209852090410984509031213232133309850098520985209041098450903118323183330985009840090300982509850090400983009825098500984509835158400a840168400b84017840
010f00003c6150000032440322402d4402d2452b445262402b4402b2452d445322402d4402d2452b445262402b4402b2202d442322422d4422d2422b4422b24226442262251d71429511357111d5112971135511
010f00000c0533f4153f41529222293222422224322222221d32222222223222422229322242220c0430c0430c0533f4153f41529222293222422224322222221d32222222223222422229322242220c0430c043
010f00000015000150001520015200141001420014200142001310013200121001220011100112183231833300150001500015200152001410014200142001420013100132001210012200111001121832318333
010f00003c615183031d4401d432184401843016440114401644016432184401d440184401843216440164323c615183031d4401d430184401843016440114401644016430184401d44018440184301644016430
010f0000001500015200152001410014000131183231833300150001520015200141001400013118323183330c8500c8420c8320c8250c8500c8420c8320c8250c8500c845001000010500100001001830318303
010f00003c6150000029440294402444024440224401d440224402244024440294402444024440224401d4402444030437244273041724440304372442730417244400c000294402942529440294252944029425
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
01 0a 42 43 44
00 0a 42 43 44
00 0a 0b 43 44
00 0a 0f 43 44
00 15 17 43 44
00 14 15 43 44
00 17 1e 43 44
00 17 1b 43 44
00 0a 0b 43 44
00 0a 0d 43 44
00 0a 0b 43 44
00 0a 0f 43 44
00 1e 1f 43 44
00 1e 21 43 44
00 23 24 43 44
00 23 26 43 44
00 1e 1f 43 44
00 1e 21 43 44
00 23 24 43 44
02 26 24 43 44
02 1f 1e 43 44
00 09 42 43 44
00 09 42 43 44
00 09 42 43 44
00 09 42 43 44
00 09 42 43 44
00 09 42 43 44
00 08 42 43 44
00 08 42 43 44
00 08 42 43 44
00 2c 2d 2e 44
00 1a 2f 30 44
01 0a 0b 0c 44
00 0a 0d 0e 44
00 0a 0b 0c 44
00 0a 0f 10 44
00 11 12 13 44
00 14 15 16 44
00 17 18 19 44
00 1a 1b 1c 44
00 0a 0b 0c 44
00 0a 0d 0e 44
00 0a 0b 0c 44
00 0a 0f 1d 44
00 1e 1f 20 44
00 1e 21 22 44
00 23 24 25 44
00 23 26 27 44
00 1e 1f 20 44
00 1e 21 22 44
00 23 24 28 44
00 29 2a 2b 44
02 1a 1b 1c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
