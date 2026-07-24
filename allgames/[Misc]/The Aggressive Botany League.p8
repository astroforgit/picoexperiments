pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- the aggressive botany league
-- v.1.1 - gabrielepala.com

grid={}
defwtr={}
max_actors=128
accel=1.6
cornaccel=0.8
frict=0.2
erosion=300
tfade=60
tred=21
life=30
redpower=8
t=0
tm=0
idlet=0
gmstate=0
gmlvl=0
frtlst={}
sdsp=200
tsd=sdsp
players=2
winner=0
tstart=5 -- timer at the start of the match

nx={0,1,0,-1}
ny={-1,0,1,0}
mx={-1,1,0,0}
my={0,0,-1,1}
nv={2,1,3,0}

function mkactor(k,x,y,d)
	local a={}
	a.kind=k
	a.life=life
	a.x=x a.y=y a.dx=0 a.dy=0
	a.d=d
	a.fr=1 a.f0=0
	if (count(actor)<max_actors) then
		add(actor,a)
	end
	return a
end

function mkplayer(x,y,d)
	pl=mkactor(1,x,y,d)
	pl.id=0 --pl1
	pl.accel=0.5
	pl.frict=frict
	pl.mspd=2
	
	pl.points=0
	pl.crossx=x
	pl.crossy=y
	pl.w=3
	pl.h=3
	pl.offx=-2
	pl.offy=-2
	pl.centerx=1
	pl.centery=1

	-- soft cornering
	pl.cornx= -((8-pl.w-1)/2)
	pl.corny= -((8-pl.h-1)/2)
	pl.corners={{},{},{},{}}

	initplayer(x,y,pl)

	pl.pal={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
	return pl
end

function initplayer(x,y,pl)
	pl.x=x*8+1
	pl.y=y*8+1
	pl.d=1
	pl.fr=64
	pl.run=false
	pl.fly=false
	pl.alive=true
	pl.shoot=false
	pl.charge=0
	pl.sd=-1
	pl.f0=0

	updcorners(pl)

	--mkseed(pl.x-1,pl.y-1)
end

function updcorners(pl)
	x=pl.x+pl.cornx
	y=pl.y+pl.corny
	pl.corners[1].x=x
	pl.corners[1].y=y
	pl.corners[1].sld=sld(pl.corners[1].x,pl.corners[1].y)
	pl.corners[2].x=x+7
	pl.corners[2].y=y
	pl.corners[2].sld=sld(pl.corners[2].x,pl.corners[2].y)
	pl.corners[3].x=x+7
	pl.corners[3].y=y+7
	pl.corners[3].sld=sld(pl.corners[3].x,pl.corners[3].y)
	pl.corners[4].x=x
	pl.corners[4].y=y+7
	pl.corners[4].sld=sld(pl.corners[4].x,pl.corners[4].y)
end

function mkseed(x,y)
	if(x==nil and y==nil)then
	n=frtlst[flr(rnd(count(frtlst)))+1]
	if(n!=nil)then
		sd=mkactor(3,n.x*8,n.y*8,0)
		sd.sd=flr(rnd(4))
	end
	else
		sd=mkactor(3,x,y,0)
		sd.sd=flr(rnd(4))
	end
end

function prtcl(x,y,sec,spd,col,th)
	pl=mkactor(4,x,y,0)
	pl.life=sec*30
	pl.spd=spd
	pl.col=col
	pl.dia=1
	if(th==nil)then
		pl.th=1
	else
		pl.th=th
	end
end

function mkripple(rx,ry)
 if #ripples<20 then
	rip={}
	rip.x=rx
	rip.y=ry
	rip.life=12
	rip.spd=0.4
	rip.dia=4
	add(ripples,rip)
 end
end

function updripples(pl)
	for rip in all(ripples) do
	 rip.dia+=rip.spd
	 rip.life-=1
	 if(rip.life<=0)then
	 	del(ripples,rip)
	 end
	end
end

function drawripples()
 for rip in all(ripples) do
 	circ(rip.x,rip.y,rip.dia,7) 
 end
end

function mkwallspawn(x,y,s,d,p)
	pl=mkactor(2,x,y,0)
	pl.tspawn=10
	pl.push=6 --px/fr
	pl.sd=s
	pl.d=d
	pl.pow=p
	if(pl.pow==nil)then pl.pow=7 end
	if(s==3 or s==2)then
		pl.tspawn=1
		pl.push=8
	end
end

function seedtocolor(sd)
	if(sd==0)then return 11 end
	if(sd==1)then return 9 end
	if(sd==2)then return 8 end
	if(sd==3)then return 1 end
end

function gridget(x,y)
	if(x>=0 and x<16 and y>=0 and y<16)then
		bl=grid[x+y*16]
		if(bl!=nil)then
			return bl
		else
			return defwtr
		end
	else
		return defwtr
	end
end

function gridset(x,y,bl)
	if(x>=0 and x<16 and y>=0 and y<16)then
		grid[x+y*16]=bl
	end
end

function sld(x,y)
	if(x<0 or x>127 or y<0 or y>127)then
	return true end
	val=mget(x/8,y/8)
	return fget(val,0)
end

function sldrect(x,y,x1,y1)
	return (sld(x,y)or sld(x1,y)or sld(x,y1)or sld(x1,y1))
end

function mapsld(x,y)
	if(x<0 or x>15 or y<0 or y>15)then
	return true end
	val=mget(x,y)
	return fget(val,0)
end

function wet(x,y)
	if(x<0 or x>127 or y<0 or y>127)then	return true end
	val=mget(x/8,y/8)
	return fget(val,4)
end

function drowning(x,y,x1,y1)
	return (wet(x,y)and wet(x1,y)and wet(x,y1)and wet(x1,y1))
end

function mapwet(x,y)
	if(x<0 or x>15 or y<0 or y>15)then
	return true end
	val=mget(x,y)
	return fget(val,4)
end

function mvplayer(pl)
 if pl.alive then
	-- corners
	updcorners(pl)

	local b=pl.id
	-- diagonal speed reduction
	if(btn(0,b)or btn(1,b))and(btn(2,b)or btn(3,b))then
		diag=0.85
	else
		diag=1
	end
	-- player control
	if (btn(0,b)) then
		pl.dx-=accel*diag 
		pl.d=0
		if ((pl.corners[1].sld)and not(pl.corners[4].sld)) then
			pl.dy+=cornaccel
		elseif (not(pl.corners[1].sld)and(pl.corners[4].sld)) then
			pl.dy-=cornaccel
		end
	end
	if (btn(1,b)) then
		pl.dx+=accel*diag 
		pl.d=1
		if ((pl.corners[2].sld)and not(pl.corners[3].sld)) then
			pl.dy+=cornaccel
		elseif (not(pl.corners[2].sld)and(pl.corners[3].sld)) then
			pl.dy-=cornaccel
		end
	end
  
  -- y movement
	if (btn(2,b)) then
		pl.dy-=accel*diag
		if(abs(pl.dy)>abs(pl.dx))then pl.d=2 end
		if ((pl.corners[1].sld)and not(pl.corners[2].sld)) then
			pl.dx+=cornaccel
		elseif (not(pl.corners[1].sld)and(pl.corners[2].sld)) then
			pl.dx-=cornaccel
		end
	end
	if (btn(3,b)) then
		pl.dy+=accel*diag
		if(abs(pl.dy)>abs(pl.dx))then pl.d=3 end
		if ((pl.corners[4].sld)and not(pl.corners[3].sld)) then
			pl.dx+=cornaccel
		elseif (not(pl.corners[4].sld)and(pl.corners[3].sld)) then
			pl.dx-=cornaccel
		end
	end

	--x collision
	if(sldrect(pl.x+pl.dx,pl.y,pl.x+pl.dx+pl.w,pl.y+pl.h))then
		if(pl.dx>0)then
			i=0
			while(i<8 and sldrect(pl.x+pl.dx-i,pl.y,pl.x+pl.dx+pl.w-i,pl.y+pl.h))do
				i+=1
			end
			pl.x=pl.x+pl.dx-i
			pl.dx=0
		else if(pl.dx<0)then
			i=0
			while(i<8 and sldrect(pl.x+pl.dx+i,pl.y,pl.x+pl.dx+pl.w+i,pl.y+pl.h))do
				i+=1
			end
			pl.x=pl.x+pl.dx+i
			pl.dx=0
			end
		end
	else
		pl.x=pl.x+pl.dx
	end
	
	-- y collision
	if(sldrect(pl.x,pl.y+pl.dy,pl.x+pl.w,pl.y+pl.dy+pl.h))then
		if(pl.dy>0)then
			i=1
			while(i<8 and sldrect(pl.x,pl.y+pl.dy-i,pl.x+pl.w,pl.y+pl.dy+pl.h-i))do
				i+=1
			end
			pl.y=pl.y+pl.dy-i
			pl.dy=0
		else if(pl.dy<0)then
			i=1
			while(i<8 and sldrect(pl.x,pl.y+pl.dy+i,pl.x+pl.w,pl.y+pl.dy+pl.h+i))do
				i+=1
			end
			pl.y=pl.y+pl.dy+i
			pl.dy=0
			end
		end
	else
		pl.y=pl.y+pl.dy
	end
 --squash death--buggy
 if(sld(pl.x,pl.y)and sld(pl.x+pl.w,pl.y+pl.h))then
		pl.alive=false
		sfx(11)
		prtcl(pl.x,pl.y,0.5,2,8,3)
		return
	end
	--max speed
	if(not(pl.fly))then
		if (abs(pl.dx)>pl.mspd) then
			if(pl.dx>0)then pl.dx=pl.mspd 
			else pl.dx=-pl.mspd end
		end
		if (abs(pl.dy)>pl.mspd) then
			if(pl.dy>0)then	pl.dy=pl.mspd
			else pl.dy=-pl.mspd end 
 	end
 end
 
 if(abs(pl.dx+pl.dy)>0.3)then
 	pl.run=true
 	if(t%8==0)then sfx(pl.id,pl.id) end
 else
 	pl.run=false
 end
--friction 
 pl.dx=pl.dx*pl.frict
	pl.dy=pl.dy*pl.frict
	if abs(pl.dx)<0.1 then pl.dx=0 pl.fly=false end
	if abs(pl.dy)<0.1 then pl.dy=0 pl.fly=false end
-- crosshair
	if(pl.d==0)then
		pl.crossx=pl.x+pl.centerx-8 pl.crossy=pl.y+pl.centery
	else if(pl.d==1)then
			pl.crossx=pl.x+pl.centerx+8 pl.crossy=pl.y+pl.centery
		else if(pl.d==2)then
				pl.crossx=pl.x+pl.centerx pl.crossy=pl.y+pl.centery-8
			else
				pl.crossx=pl.x+pl.centerx pl.crossy=pl.y+pl.centery+8
			end
		end
	end

-- plant sd
	if((btn(5,b))and(pl.sd>=0))then
		if(plant_sd(pl,flr(pl.crossx/8),flr(pl.crossy/8),pl.sd,pl.d))then
		pl.sd=-1
		sfx(pl.id+2)
		end
	end
-- brak wall
	if(btnp(4,b))then
		attack(flr(pl.crossx/8),flr(pl.crossy/8))
	end
-- fr direction
	if(pl.d<2)then pl.fr=64
		else 
			if(pl.d==2)then pl.fr=80
		 	else pl.fr=96
			end
		end
	
	if(pl.run)then
	 pl.f0 = (pl.f0+abs(pl.dx+pl.dy))%6
	 pl.fr = pl.fr+4+flr(pl.f0)
 else
	 pl.f0 = (pl.f0+0.2)%4
	 pl.fr=pl.fr+pl.f0
 end
 
 if(drowning(pl.x,pl.y,pl.x+pl.w,pl.y+pl.h))then
 	pl.life-=1
 	if(pl.dx+pl.dy==0)then pl.life-=2 end
 	if rnd(10)<2 then mkripple(pl.x+pl.centerx,pl.y+pl.centery) end
 else
 	pl.life=life
 end
 
 if(pl.life<=0)then 
 	pl.alive=false
 	sfx(11)
 end

end	
end

function plant_sd(pl,x,y,sdtp,d)
	if(sdtp==0)then
		bl=gridget(x,y)
		if(bl.type==2)then
			bl=initsdwall(sdtp,d,7)
			bl.thatch+=30
			bl.tfade+=30
			bl.pow=2
			gridset(x,y,bl)
			return true
		end
	elseif(sdtp==1)then
		x=flr((pl.x+pl.centerx)/8)
		y=flr((pl.y+pl.centery)/8)
		bl=initsdwall(sdtp,d,7)
		bl.thatch+=2
		bl.tfade+=5
		bl.pow=3
		mkwallspawn(x,y-2,sdtp,2,bl.pow)
		mkwallspawn(x,y+2,sdtp,3,bl.pow)
		mkwallspawn(x-2,y,sdtp,0,bl.pow)
		mkwallspawn(x+2,y,sdtp,1,bl.pow)
		return true
	elseif(sdtp==2)then
		bl=gridget(x,y)
		if(bl.type==2)then
			bl=initsdwall(sdtp,d,7)
			bl.pow=redpower
			gridset(x,y,bl)
			return true
		end
	elseif(sdtp==3)then
		bl=gridget(x,y)
		if(bl.type==2)then
			bl=initsdwall(sdtp,d,7)
			if(d>1)then
			mkwallspawn(x+1,y,sdtp,bl.d,bl.pow)
			mkwallspawn(x-1,y,sdtp,bl.d,bl.pow)
			else
			mkwallspawn(x,y+1,sdtp,bl.d,bl.pow)
			mkwallspawn(x,y-1,sdtp,bl.d,bl.pow)
			end
			gridset(x,y,bl)
			return true
		end
	end
end

function attack(x,y)
	bl=gridget(x,y)
	if(bl.type==2)then
		bl.life-=1
		prtcl(x*8+4,y*8+4,0.3,1,15)
		sfx(07)
		if(bl.life<=0)then
			sfx(06)
			prtcl(x*8+4,y*8+4,0.2,3,2,2)
			bl=initground(-1)
			gridset(x,y,bl)
		end
	end
end

function spawnpush(pl,x,y,d,push)
	if(pl.x<8+x*8 and
				pl.x+pl.w>x*8 and
				pl.y<8+y*8 and
				pl.y+pl.h>y*8)then
		if(d==0)then
			pl.dx=-push
		else if(d==1)then
				pl.dx=push
			else if(d==2)then
					pl.dy=-push
				else
					pl.dy=push
				end
			end
		end
		pl.fly=true
	end
end

function mvwallspawn(ws)
	if(ws.tspawn>0)then
		--collisione push
		spawnpush(pl1,ws.x,ws.y,ws.d,ws.push)
		spawnpush(pl2,ws.x,ws.y,ws.d,ws.push)
		spawnpush(pl3,ws.x,ws.y,ws.d,ws.push)
		spawnpush(pl4,ws.x,ws.y,ws.d,ws.push)
		ws.tspawn-=1
	end
	if(ws.tspawn<=0)then
		if(ws.sd<0)then
			gridset(ws.x,ws.y,initwall())
		else if(ws.sd<5)then
				gridset(ws.x,ws.y,initsdwall(ws.sd,ws.d,ws.pow))
			end
		end
		del(actor,ws)
	end
end

function sdcoll(sd,pl)
	if(pl.x+pl.w>=sd.x and pl.x<=sd.x+7
	and pl.y+pl.h>=sd.y and pl.y<=sd.y+7)then
		return true
	else
		return false
	end
end

function mvseed(sd)
	if(not(fget(mget(sd.x/8,sd.y/8),7)))then
		del(actor,sd)
		return
	end
	
	if(sdcoll(sd,pl1))then
		pl1.sd=sd.sd
		prtcl(sd.x+4,sd.y+4,0.2,3,seedtocolor(sd.sd),2)
		del(actor,sd)
		sfx(10)
		return	
	elseif(sdcoll(sd,pl2))then
		pl2.sd=sd.sd
		prtcl(sd.x+4,sd.y+4,0.2,3,seedtocolor(sd.sd))
		prtcl(sd.x+4,sd.y+4,0.3,2,seedtocolor(sd.sd))
		del(actor,sd)
		sfx(10)
		return
	elseif(sdcoll(sd,pl3))then
		pl3.sd=sd.sd
		prtcl(sd.x+4,sd.y+4,0.2,3,seedtocolor(sd.sd))
		prtcl(sd.x+4,sd.y+4,0.3,2,seedtocolor(sd.sd))
		del(actor,sd)
		sfx(10)
		return
	elseif(sdcoll(sd,pl4))then
		pl4.sd=sd.sd
		prtcl(sd.x+4,sd.y+4,0.2,3,seedtocolor(sd.sd))
		prtcl(sd.x+4,sd.y+4,0.3,2,seedtocolor(sd.sd))
		del(actor,sd)
		sfx(10)
		return
	--end
	end
end

function mvprtcl(pl)
	pl.dia+=pl.spd
	pl.life-=1
	if(pl.life<=0)then
		del(actor,pl)
	end
end

function mvactor(pl)
	if(pl.kind==1)then
		mvplayer(pl)
	else 
		if(pl.kind==2)then
			mvwallspawn(pl)
		else 
			if(pl.kind==3)then
				mvseed(pl)
			else if(pl.kind==4)then
					mvprtcl(pl)
				end
			end
		end
	end
end

function initbl()
 bl={}
 bl.timer=0
 bl.type=0
	return bl
end

function initwater()
	bl=initbl()
	bl.type=0
	return bl
end

function initground(timer)
	bl=initbl()
	bl.type=1
	bl.timer=timer
	return bl
end

function initwall()
	bl=initbl()
	bl.type=2
	bl.life=3
	return bl
end

function initsdwall(sd,d,p)
	bl=initbl()
	bl.type=3
	bl.d=d
	bl.thatch=2
	bl.pow=p
	if(bl.pow==nil)then bl.pow=7 end
	if(sd==2)then
		bl.tfade=15
	else
		bl.tfade=tfade+rnd(5)-2
	end
	bl.sdtp=sd
	return bl
end

function draw_ground(x,y,bl)
	fr=49
	if(bl.timer>=0)then
		if(bl.timer<erosion*0.6)then
			fr=fr+2
			if(bl.timer<erosion*0.3)then
				fr=fr+2
			end
		end
	end
	--shadow tiles
	
	if(mapsld(x,y-1))then
		fr-=16 end
	if(mapsld(x-1,y))then
		fr-=1 end
		
	mset(x,y,fr)
end

function draw_water(x,y)
	mset(x,y,(1+(t*0.1)%5)+(y%2)*16)
	n=6
	
	for i=1,4 do
	 if (not(mapwet(x+nx[i],y+ny[i]))) then
	  if (nx[i] != 0) then n += 1+((nx[i]+1)/2) end
	  if (ny[i] != 0) then n += (1+((ny[i]+1)/2)) * 16 end
	 end
	end
	mset(x+16,y,n)
end

function draw_sdwall(x,y,bl)
	fr=12
	if(bl.sdtp==0)then
		fr=12
	elseif(bl.sdtp==1)then
		fr=28
	elseif(bl.sdtp==2)then
		fr=44
	else
		fr=60
	end
	
	if(bl.tfade<tfade*0.18)then
		fr+=1
	 if(bl.tfade<tfade*0.12)then
	  fr+=1
	  if(bl.tfade<tfade*0.06)then
				fr+=1
			end
	 end
	end
	
	mset(x,y,fr)
end

function check_fert(x,y)
	if(mapwet(x,y-1)or mapwet(x+1,y)or mapwet(x,y+1)or mapwet(x-1,y))then
		frt={}
		frt.x=x
		frt.y=y
		add(frtlst,frt)
	end
end

function updmapcell(x,y)
 bl=gridget(x,y)
 if(bl.type==0)then
 	draw_water(x,y)
 else
  if((bl.type==1)or(bl.type==4))then
  	draw_ground(x,y,bl)
  	check_fert(x,y)
  else if(bl.type==2)then
  		fr=11+(16*(4-bl.life))
  		mset(x,y,fr)
  	else if(bl.type==3)then
  			draw_sdwall(x,y,bl)
  		end
  	end
  end
 end
end

function updmap()
	for x=16,31 do
		for y=0,15 do
			mset(x,y,0)
		end
	end
	
	for x=0,15 do
		for y=0,15 do
			updmapcell(x,y)
		end
	end
end

function erode(x,y)
	bl=gridget(x,y)
	if(bl.type==1)then
		if(bl.timer<0)then
			gridset(x,y,initground(erosion))
		end
	else if(bl.type==2 or bl.type==3)then
			gridset(x,y,initground(erosion*2))
		end
	end
end

function makeland(x,y)
	if(mapwet(x,y))then
		if(x>=0 and x<=15 and y>=0 and y<=15)then
			gridset(x,y,initground(erosion))
		end
	end
end

function updground(x,y,bl)
	-- ground sink
	if(bl.timer>0)then
		bl.timer-=1
	else
	if(bl.timer==0)then
		gridset(x,y,initwater())
		
		for dy=-1,1 do
		 for dx=-1,1 do
		  if (dx !=0 or dy !=0) then
		   erode(x+dx,y+dy)
		  end
		 end
		end
	end
	end
end

function greenhatch(x,y,d,pow)
	bl=gridget(x,y)
	p=pow
	if(bl.type<3)then
		if(bl.type<2)then
			p-=1
		end
		bl=initsdwall(0,d)
		bl.pow=p
		gridset(x,y,bl)
	end
end

function updgreen(x,y,bl)
	if(bl.thatch==0 and bl.pow>0)then
		sfx(4)
		for i=1,4 do
		 greenhatch(x+nx[i],y+ny[i],nv[i],bl.pow)
		end
	end
	
	if(bl.tfade<=0)then
	if(bl.pow>0)then
 	gridset(x,y,initground(erosion*2))
 else
 	gridset(x,y,initwall())
 end
 end
end

function updyellow(x,y,bl)
	if(bl.thatch==0 and bl.pow>0)then
		sfx(05)
		--for i=1,4 do
		--	bl2=gridget(x+nx[i],y+ny[i])
		--	if(bl2.type<2)then
		--		mkwallspawn(x+nx[i],y+ny[i],1,nv[i],bl.pow-1)	
		--	end
		--end
		if(bl.d!=1)then
			target=gridget(x-1,y)
			 if target.type<3 then mkwallspawn(x-1,y,1,bl.d,bl.pow-1) end
		end
		if(bl.d!=0)then
			target=gridget(x+1,y)
			if target.type<3 then mkwallspawn(x+1,y,1,bl.d,bl.pow-1) end
		end
		if(bl.d!=3)then
			target=gridget(x,y-1)
			if target.type<3 then mkwallspawn(x,y-1,1,bl.d,bl.pow-1) end
		end
		if(bl.d!=2)then
			target=gridget(x,y+1)
			if target.type<3 then mkwallspawn(x,y+1,1,bl.d,bl.pow-1) end
		end
	end
	
	if(bl.tfade<=0)then
   if(bl.pow==0)then
 	  gridset(x,y,initwall())
   else
 	  gridset(x,y,initground(erosion*2))
   end
  end
end

function updred(x,y,bl)	
	if(bl.thatch==0)then
		bl2=gridget(x+mx[bl.d+1],y+my[bl.d+1])
		if(bl2.type==2 or bl.pow>0)then
			mkwallspawn(x+mx[bl.d+1],y+my[bl.d+1],2,bl.d,bl.pow-1)
		end
		sfx(05)	
	end
	
	if(bl.tfade<=0)then
	 bl2=gridget(x+mx[bl.d+1],y+my[bl.d+1])
		if(bl2.type<2)then
			for i=-2,2 do
			for j=-2,2 do
				mkwallspawn(x+i,y+j,5,bl.d)
			end
			end
		end	
	 for i=1,4 do
		if(bl.d>1)then
			mkwallspawn(x+i,y,5,1)
			mkwallspawn(x-i,y,5,0)
		else
			mkwallspawn(x,y+i,5,3)
			mkwallspawn(x,y-i,5,2)
		end
		end
		gridset(x,y,initground(erosion*2))
		prtcl(x*8+4,y*8+4,0.5,3,7)
		sfx(06)
	end
end

function updblue(x,y,bl)
	if(bl.thatch==0 and bl.pow>0)then
		sfx(15)
		mkwallspawn(x+mx[bl.d+1],y+my[bl.d+1],3,bl.d,bl.pow-1)
	end
	
	if(bl.tfade<=0)then
		if(bl.pow<=0)then
			gridset(x,y,initwall())
		else	
 		gridset(x,y,initground(erosion*2))
 	end
 end
end

function updsdwall(x,y,bl)
 bl.thatch-=1
 bl.tfade-=1
 
 if(bl.sdtp==0)then
 	updgreen(x,y,bl)
 else if(bl.sdtp==1)then
 		updyellow(x,y,bl)
 	else if(bl.sdtp==2)then
 			updred(x,y,bl)
 		else
 			updblue(x,y,bl)
 		end
 	end
 end
end

function updbl(x,y)
	bl=gridget(x,y)
	if(bl.type==1)then
	 updground(x,y,bl)
	else if(bl.type==3)then
			updsdwall(x,y,bl)
		end
	end
end

function updgrid()
	reset_fert()
	for x=0,15 do
		for y=0,15 do
			updbl(x,y)
		end
	end
	
	updmap()
end

function reset_fert()
	for item in all(frtlst) do
		del(frtlst,item)
	end
end

function printstroke(text,x,y,col,strokecol)
 if not strokecol then strokecol=1 end
 for i=1,4 do
	print(text,x+nx[i],y+ny[i],strokecol)
 end
 print(text,x,y,col)
end

function startgame(lvl)
 reset_fert()
	
	for i in all(actor) do
	if(i.kind==2 or i.kind==3 or i.kind==4)then
	del(actor,i)
	end
	end
	
	initgrid(lvl)

	randomseed=flr(rnd(4))
	pl1.sd=randomseed
	pl2.sd=randomseed
	if players>2 then pl3.sd=randomseed end
	if players>3 then pl4.sd=randomseed end

	if players==3 then sdsp=sdsp*0.90
	elseif players==4 then sdsp=sdsp*0.75 end

	tstart=5

	updgrid()
	
	gmstate=1
	--sfx(9)
end

function initgrid(lvl)
	grid={}
	for x=0,15 do
		for y=0,15 do
			initgridcell(x,y,lvl)
		end
	end
	
	updmap()
end

function initgridcell(x,y,lvl)
	val=sget(x+(lvl*16),y+96)
	bl={}
	if(val==12)then
		--water
		bl=initwater()
	else if(val==7)then
			--ground
			bl=initground(-1)
			else if(val==15)then
				--breaking ground
				bl=initground(erosion)
				else if(val==2)then
						--wall
						bl=initwall(0)
					else
				 	--players
				 	if(val==8)then
							initplayer(x,y,pl1)
						else if(val==11)then
								initplayer(x,y,pl2)
							else if(val==9)and(players>=3)then
								initplayer(x,y,pl3)
							 else if(val==14)and(players>=4)then
								initplayer(x,y,pl4)
							  end
							 end
							end
						end
						bl=initground(-1)
					end
				end			
			end
	end
	
	gridset(x,y,bl)
	
end

function _init()
	t=0
	gmstate=0
	actor={}
	defwtr=initwater()

	ripples={}
		
	pl1=mkplayer(64,96,1)
	pl2=mkplayer(64,32,1)
	pl2.id=1
	pl2.pal={1,3,3,4,5,6,7,11,9,10,11,12,13,14,15}
	pl3=mkplayer(64,32,1)
	pl3.id=2
	pl3.pal={1,4,3,4,5,6,7,9,9,10,11,12,13,14,15}
	pl4=mkplayer(64,32,1)
	pl4.id=3
	pl4.pal={1,13,3,4,5,6,7,14,9,10,11,12,13,14,15}
end

function _update() 
 if(gmstate==1)then
	if(tstart<0)then
	 foreach(actor,mvactor)
	 updripples()
	 updgrid()
		tsd-=1
		if(pl1.sd<0)then
			tsd-=1
		end
		
		if(pl2.sd<0)then
			tsd-=1
		end
		
		if(tsd<=0)then
			mkseed()
			tsd=sdsp
		end

	 plcount=0

	 if(pl1.alive)then plcount+=1 end
	 if(pl2.alive)then plcount+=1 end
	 if(pl3.alive)then plcount+=1 end
	 if(pl4.alive)then plcount+=1 end

	 if plcount <= 1 then
	 	if(pl1.alive)then
	 		pl1.points+=1
	 		winner=1
	  elseif(pl2.alive)then
	  	pl2.points+=1
	  	winner=2
	  elseif(pl3.alive)then
	  	pl3.points+=1
	  	winner=3
	  elseif(pl4.alive)then
	  	pl4.points+=1
	  	winner=4
	  end

	  gmstate=2
	 	idlet=30
	 end
	 
	else
		tstart-=1
		if(tstart<0) sfx(17)
	end
	t+=1

 else if(gmstate==0)then
 	tm+=1
 	if(btnp(4) or btnp(5))then
 		startgame(0)
 	elseif(btnp(0))then
 		if players>2  then players-=1 end
 	elseif(btnp(1))then
 		if players<4  then players+=1 end
 	end

 else if(gmstate==2)then
 	idlet-=1
 	if(btnp()>0 and idlet<0)then
 		gmlvl=(gmlvl+1)%4
 		startgame(gmlvl)
 	end
 end
 end
 end
end

function draw_actor(pl)
 if(pl.kind==1)then
  if (pl.pal ~= nil) then
   for i=1,15 do
    pal(i, pl.pal[i])
   end
  end
	
	if(not(pl.alive))then
		pl.fr=112
	end
	
	spr(pl.fr,pl.x+pl.offx,pl.y+pl.offy,1,1,pl.d<1)

	pal()
	
	if(pl.sd>=0)and(pl.alive)then
		cx=pl.x+pl.centerx
		cy=pl.y+pl.centery
		circ(cx,cy,7,7)
		circ(cx,cy,8,seedtocolor(pl.sd))
	end
	

	-- player debug
	--rect(pl.x,pl.y,pl.x+pl.w,pl.y+pl.h,0)
	--pset(pl.crossx,pl.crossy,0)
	
	--pset(pl.corners[1].x,pl.corners[1].y,0)
	--pset(pl.corners[2].x,pl.corners[2].y,0)
	--pset(pl.corners[3].x,pl.corners[3].y,0)
	--pset(pl.corners[4].x,pl.corners[4].y,0)

 else if(pl.kind==3)then
 	spr(114+((t*0.2)+pl.sd)%8,pl.x,pl.y-1)
 else if(pl.kind==4)then
		circ(pl.x,pl.y,pl.dia,pl.col) 
		circ(pl.x,pl.y,pl.dia-0.5,pl.col)
		if(pl.th>1)then
			circ(pl.x,pl.y,pl.dia-1,pl.col)
			circ(pl.x,pl.y,pl.dia-1.5,pl.col)
			if(pl.th>2)then
				circ(pl.x,pl.y,pl.dia-2,pl.col)
				circ(pl.x,pl.y,pl.dia-2.5,pl.col)
				end
		end
	end
 end
 end
end

function _draw()
	mapdraw(0,0,0,0,16,16)
	drawripples()
	mapdraw(16,0,0,0,16,16)
	foreach(actor,draw_actor)
	printstroke(pl1.points,4,4,8,2)
	printstroke(pl2.points,121,4,11,3)
	if(players>=3) printstroke(pl3.points,4,120,9,4)
	if(players>=4) printstroke(pl4.points,121,120,14,2)
	if(gmstate==0)then
		for i=0,15 do
		for j=0,15 do
			spr((1+(tm*0.1)%5)+(j%2)*16,i*8,j*8)
		end
		end
		rectfill(0,18,128,72,15)
		rectfill(0,19,128,71,13)
		rectfill(0,21,128,69,5)
		sspr(0,64,64,32,32,16)
		sspr(64,64,64,32,30,40)
		sspr(0,88,16,8,54,12)
	end

	if((gmstate==0 or gmstate==2)and idlet<=0)then
	 printstroke("press — button to start",16,90,15)
		if gmstate==0 then
		 printstroke("‹ "..players.." players ‘",34,82,15)
		elseif gmstate==2 then
			if winner==1 then printstroke("red player wins!",32,82,8,2)
			elseif winner==2 then printstroke("green player wins!",28,82,11,3)
			elseif winner==3 then printstroke("yellow player wins!",26,82,9,4)
			elseif winner==4 then printstroke("pink player wins!",30,82,14,2) end
		end
	end
end













__gfx__
00000000cccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf6000000007dddddd57666666b7dd66dd57dddddd57dddddd5
000000006ff6ccccc6ff6ccccc6ff6ccc6ff6cccc6ff6ccc00000000d4d0000000000cf6d4d00cf600000000d22222216bbbbbb3d3bbbb31d2233221d2222221
00000000cccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf600000000d22222216bbbbbb3dbbbbbb1d23bb321d2233221
00000000cccccccccccccccccccccccccccccccccccccccc00000000d44d00000000cff6d4d00cf600000000d22222216bbbbbb36bbbbbb3d3bbbb31d23bb321
00000000cccccccccccccccccccccccccccccccccccccccc00000000d44d00000000cff6d4d00cf600000000d22222216bbbbbb36bbbbbb3d3bbbb31d23bb321
00000000cccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf600000000d22222216bbbbbb3dbbbbbb1d23bb321d2233221
00000000cccc6ff66cccc6ffcccc6ff6ccc6ff6ccccc6ff600000000d4d0000000000cf6d4d00cf600000000d22222216bbbbbb3d3bbbb31d2233221d2222221
00000000cccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf60000000051111111b3333331511331115111111151111111
ddddddddccccccccccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddd7dddddd57dddddd57aaaaaa97dd66dd57dddddd57dddddd5
55555555cccccccccccccccccccccccccccccccccccccccc44444444d44444444444444dd444444d52222221d2222221a9999994d4999941d2244221d2222221
11111111c6ff6ccc6ff6cccc6ff6ccccff6cccc66ff6ccccddd44dddd44dddddddddd446d4dddd4671522512d2222221a9999994d9999991d2499421d2244221
0dd00dd0cccccccccccccccccccccccccccccccccccccccc000dd000d4d0000000000cf6d4d00cf6ddd522d1d2222221a999999469999994d4999941d2499421
d00dd00dcccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf6d22d2221d2222221a999999469999994d4999941d2499421
0d000d00cccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf6d2221221d2222221a9999994d9999991d2499421d2244221
000d000dcccc6ff6ccc6ff6ccccc6ff6cccc6ff6ccc6ff6c00000000d4d0000000000cf6d4d00cf6d221d221d2222221a9999994d4999941d2244221d2222221
00000000cccccccccccccccccccccccccccccccccccccccc00000000d4d0000000000cf6d4d00cf6511121115111111194444445511441115111111151111111
dddddddddddddddddddddddddddddddddddddddddddddddd00000000d4d0000000000cf6d4d00cf6000000007dddddd5feeeeee87dd66dd57dddddd57dddddd5
d2dddd2dd2dddd2dd2dddd2dd2dddd2dd2dddd2dd2dddd2d00000000d4d0000000000cf6d4d00cf60000000052222221e8888882d2888821d2255221d2222221
dd66666666666666dd66666666666666dd4644666446444600000000d4d0000000000cf6d4d00cf60000000071122212e8888882d8888881d2588521d2255221
d677777777777777d6f777f77ff7777fd4f7fff77ffff7ff00000000d4d0000000000cf6d4d00cf600000000ddd121d1e888888268888882d5888851d2588521
d677777777777777d67f77777777ff77d67fff7ff7f7ff77000cc000d4d0000000000cf6d4d00cf600000000d22d1d21e888888268888882d5888851d2588521
d677777777777777d6777ff777777777d4ff7ff77fffff7fcccffcccd44ccccccccccff6d4dcccf600000000d2221d21e8888882d8888881d2588521d2255221
dd77776776777767dd77776776777767ddf7f767f67f7f67ffffffffd44ffffffffffff6d44ffff600000000d221d221e8888882d2888821d2255221d2222221
d677777777777777d67f7777777ff777d47f7f7777fff7f766666666dd66666666666666dd666666000000005111211182222221511221115111111151111111
d677777777777777d677777777ff7ff7d6f77f7777ff7ff7dddddddddddddddddddddddddddddddd00000000f7ddddd47dddddd57dd66dd57dddddd57dddddd5
dd77776776777767dd7ff767767f7767dd7ff767767f7f6744444444d44444444444444dd444444d0000000075d22251d1111112d5111151d2255221d2222221
d677777777777777d6777777ff77f7ffd4ff7f77ff7ff7ffddddddddd4dddddddddddd46d4dddd4600000000d11d2d1dd1111112d1111111d2511521d2255221
d677777777777777d677ff777ff7777fd67fff7f7ff7ff7f00000000d4d0000000000cf6d4d00cf60000000045d1d175d111111261111112d5111151d2511521
d677777777777777d6f777f7f777ff77d4f7f7f7ff7ffff700000000d4d0000000000cf6d4d00cf6000000007d2d17d1d111111261111112d5111151d2511521
d677777777777777d677777777f77ff7d4ff7f777fff7ff7ccccccccd4dcccccccccccf6d4dcccf600000000d2221d21d1111112d1111111d2511521d2255221
dd77776776777767dd7ff767767f7767ddfff767767f7f67ffffffffd44ffffffffffff6d44ffff60000000051217221d1111112d5111151d2255221d2222221
d677777777777777d67f7777fff777ffd67f7f77fff777ff66666666dd66666666666666dd666666000000004511211452222222511221115111111151111111
00008008000800800080080000080080008008000088028000800800008008000088028000800800000000000000000000000000000000000000000000500000
00080080000888800008008000088880008888000008888000080080008888000008888000080080000000000000000000000000000000000000000000052200
00088880000881200008888000088120008812000dd8812000088880008812000dd8812000088880000000000000000000000000000000000000000000222880
0dd881200dd288800dd881200dd288800d2888000881888000d881200d2888000551888000d88120000000000000000000000000000000000000000000228180
05528880055111000552888005511100055112000511000000558880055110000511180000558880000000000000000000000000000000000000000000228880
05811100058111000558110005581100058110005511dd000081100005518000dd11550000518000000000000000000000000000000000000000000008022200
00dd0dd000dd0dd000dd0dd000dd0dd00005d000000000000051d000000d50000000000000d15000000000000000000000000000000000000000000000550110
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000800800008000080008000800008008008008800088000000000008008000880008800000000000000000000000000000000000000000000000005000050
80088800088888800088800808888880080000800888888008000080080000800888888008000080000000000000000000000000000000000000000005222250
8882220002dddd200022288802dddd20088888800222222008000080088888800222222008000080000000000000000000000000000000000000000002222220
22dddd20025dd52002dddd22025dd52002dddd2082dddd2008dddd8002dddd2002dddd2808dddd80000000000000000000000000000000000000000008222280
225dd52002555520025dd52202555520025dd520005dd520825dd520025dd520025dd500025dd528000000000000000000000000000000000000000002222220
08555580081551800855558008155180805555280055550802555528825555088055550082555520000000000000000000000000000000000000000080522508
05d00d5005d00d5005d00d5005d00d5000d005500d0000000015515005500d00000000d005155100000000000000000000000000000000000000000000100100
000000000000000000000000000000000d0000000000000005d00500000000d00000000000500d50000000000000000000000000000000000000000000000000
08000800800008000080008000800008008008008800088000000000008008000880008800000000000000000000000000000000000000000000000005000050
80088800088888800088800808888880080000800888888008000080080000800888888008000080000000000000000000000000000000000000000005222250
88821800081221800081288808122180088888800812218008000080088888800812218008000080000000000000000000000000000000000000000002888820
81288000008888000008821800888800081221808288882008888880081221800288882808888880000000000000000000000000000000000000000008188180
08811180081111000811188000111180008888000011110888122180008888008011110008122188000000000000000000000000000000000000000002888820
021111000011118000111120081111008211112000d00500028888280211112800500d0082888820000000000000000000000000000000000000000080222208
0dd00dd00dd00dd00dd00dd00dd00dd000d005500d0000000011110005500d00000000d000111100000000000000000000000000000000000000000000100100
000000000000000000000000000000000d000000000000000dd00500000000d00000000000500dd0000000000000000000000000000000000000000000000000
009aa9000000000000000000000ee000000ee000000ee00000000000000000000000000000000000000000000000000000000000008008000008208200000000
0900009000000000000ee000000220000002200000022000000ee000000000000000000000000000000000000000000000800800008888000000888800820820
0c9aa9c0000000000002200000e2210000e2210000e2210000022000000ee000000ee000000ee000000000000000000000888800008881000000888100088880
c7cccc7c0000000000e22100006cc600006cc6000022210000e22100000220000002200000022000000000000000000000888100000888000088188800088810
c777777c00000000006cc600001221d6001221d6001221d6006cc60000e2210000e2210000e22100000000000000000000088800002112000001100000008880
c787787c00000000001221d000011ddd00011ddd00011ddd001221d0006cc600006cc600006cc600000000000000000000012000080110000221188000002100
0c7777c00000000000d11dd0000ddddd000ddddd000ddddd00d11dd0001221600012216000122160000000000000000000111200002188000000000000018100
00cccc0000000000006ddd600006ddd60006ddd60006ddd6006ddd6000d11d6000d11d6000d11d60000000000000000000208000020000000000000000020800
000000000000000000000000000000000000000000000000000000000000000000ffffffffffffdfdfffffffffffffddfffdfffffffdfffffffffffdddfffff0
00000000000000000000000000000000000000000000000000000000000000000f7777777777777777777777777777777777777777777777777777777777777f
00000000000000000000000000000000000000000000000000000000000000000f7773355536777335555655555555555673335673336777735557767735577f
00011000011110011111111100111110111100111111111111111111111111000f777655d65567355d6555d6d35555d66735555566553677355d56777735d77f
001dd1001dddd11dddd1dddd11ddddd1dddd11dddd1d7a627211d72dddddd1000d67773567555655567355677d355d777755d655d6355576355d65777355677f
01d7a511d7a665d7a6657a665d7a666577a65d77a6525a557211d7277a6671000f77735567355d355673556777355677755567553655557735566577755d777d
1d72565d722562722562622565622225722575722572d7257211da27222221000f77735567555d3556735567773556777555673556355567355675677556777f
1d72562d721d62721d62721d6572111da21d65a21d62d72d6211d62a211111000f77735567555d3556735567773556777355675556355d57355676573556777f
1d72562d721d62721d62621d6572101d621d65621d62d62d7211d627210000000f66735567355d35567555677735567773556735563556573556765735d7777f
1d721565a21d62a21d62621d65621015621115621111d72d7211d72a210000000f7773556735563556735567775556767355673556355656555677563567777f
1da21565721122721122621d65621001562101562101d62da211d626210000000f7773556735675556735567775556777355673556555656355677655567776d
1d721d6562101d62101d621d65721001565d11565d11d72d6211d626210000000f777555d5567735567555677755567775556735565556d5555677655d77767f
1d621d6572101da2101d621d656210001567d11567d1d62d621d75d6210000000f7775556653675556735567773556777355d55556555665555677735677777f
1da21d65a2111d72111d621d75621000015575115575d62d621d72d6210000000f7773556755365556755567775556777355663556355675555677355677777f
1d621d65621dd5621dd565d72d65d100001562101562d62d621d62d65d1000000f77735567555d555675556767555677735567555635567555567755d777777f
1d621d6562177562177566765d667111111d72101d72d625621d62d6671000000d67755567355d555675556777355677755567355655567d555677556777777f
1d6677656212a562126562257562211d721d65721d62d62562d751d6221000000f77755567355d3556735567773556777555675556555676555673556777777f
1d622565621d65621d65621d6562101d621d65621d62d621565621d6210000000f777655d73556555673556777355677735567555d555777555d735d7777667f
1d621d65621d65621d65621d6562101d621d65621d62d621565621d6210000000f7775555555676555555677755555775555675555556766d55555f67677777f
1d621d65621d65621d65621d65651115651d65651d62d621d6751156511110000f77776dddd67776666667777766666776dd6776ddd6777776dddd677677777f
1d621d6256dd6256dd65621d62565d11565d62565d62d621d662101565dd10000f7777777777777777777777777777777777777777777777777777777777777f
1d621d62156672156675621d621567101567721567725651d62100015667100000ffffffdfddfffffffffdddfddffffffffffffffffffffdddfffffffdfffff0
1d721d72115222112225721d7211521001522101522d776252100000152210000001111100011111111111101111100001111111111100011111111111111000
11111111101111101111111111101110001110001111111111000000011110000001d7210001d7a6666662101d7510001d777a6657210001d727a66666651000
0000000000000000cccccccc00000000000000000000000000000000000000000001d7210001d72111111111d7572101d721111117210001d727211111111000
0222222112122220cccccccc00000000000000000000000000000000000000000001da210001da2111000001da5a211da21000001a210001da2a211100000000
27aaaa722727aaa2ffffffff00000000000000000000000000000000000000000001d7210001d7a62100001d751d721d7210011117210001d727a65100000000
122a22a22a2a2221dddddddd00000000000000000000000000000000000000000001d6210001d6211100001d621d621d621001d656210001d626211100000000
1129229999299211dddddddd00000000000000000000000000000000000000000001da210001da20000001da2111da2da51001d65a510001da2a210000000000
11292292292922215555555500000000000000000000000000000000000000000001d6511111d651111111d666666621d65111562565111d65d6511111111000
112822822828888255555555000000000000000000000000000000000000000000015666666656666666656211111d621d6666662156666651d6666666651000
01121121121222205555555500000000000000000000000000000000000000000001111111111111111111110000011101111111101111111011111111111000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cf7777777777777cccccccccccccccccccc7777777777cccccccccc22ccccccccf7777777777777cccccccccccccccccccc7777777777cccccccccc22ccccccc
c72222222222727ccccccc7777cccccccc772227722277ccccccccccccccccccc72222222222727ccccccc7777cccccccc772227722277cccccccccccccccccc
c72777777777727cccc77777b7777cccc77227777772277ccc7772c7bfff77ccc72777777777727cccc7777777777cccc77227777772277ccc7772c77fff77cc
c7279722777b727cccc7227777227cccc72277777777227ccc7972c77ccc77ccc7272227777b727cccc7227777227cccc72277777777227ccc7772c77ccc77cc
c72777727777727cccc72cc77cc27cccc7277e7227b7727ccc2777c77ccc77ccc72727777777727cccc72cc77cc27cccc72777777777727ccc2777cccccc77cc
c77727227272727ccc777cc77cc777ccc72777777777727ccc777777cccc77ccc77727227277727cccc72cc77cc27cccc72777777777727ccc7777cccccc77cc
c72227277272727ccc7e7772277777ccc777727ff727777ccc77777ccc2777ccc72227277277727cccc72c2222c27cccc777777ff777777ccc7777cccc2777cc
c72727277272227ccc777772277797ccc777727ff727777ccc7772ccc77777ccc72777277272227cccc72cc77cc27cccc777777ff777777ccc7772cccc7777cc
c72727272272777ccc777cc77cc777ccc72777777777727ccc77cccc777772ccc72777272272777cccc72cc77cc27cccc72777777777727ccc77cccccc7772cc
c72777772777727cccc72cc77cc27cccc72778722797727ccc77ccc77c7777ccc72777777772727cccc7227777227cccc72777777777727ccc77cccccc7777cc
c7278777227e727cccc7227777227cccc72277777777227ccc77ccc77c27e7ccc72787777222727cccc7777777777cccc72277777777227ccc77ccc77c2777cc
c72777777777727cccc7777877777cccc77227777772277ccc77fff87c2777ccc72777777777727ccccccc7777ccccccc77227777772277ccc77fff77c2777cc
c72722222222227ccccccc7777cccccccc772227722277ccccccccccccccccccc72722222222227ccccccccccccccccccc772227722277cccccccccccccccccc
c7777777777777fcccccccccccccccccccc7777777777cccccccccc22cccccccc7777777777777fcccccccccccccccccccc7777777777cccccccccc22ccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000aaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000088aaaa9990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008888ccc9999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008888ccc9999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008888ccc9999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000888bbbb990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000008bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0010101010101010101010010101010110101010101010101010100101010101808080808080000000001001010101018080808080800000000010010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a00000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a00000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a00000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a00000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a00000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101040405050505050404040100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111103050505111104111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0112120101010505050505010104040100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112111112051111030303111104041100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101121201010103030104010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111110311111111111111030304121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101030301010101010404030312120100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111110404040404040404041212120100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010404010101010101011201011200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111110404040404041111031111110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501050412120401040505050111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505111212041204040403051101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501040401011212040411111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0511041105050112120101040403010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050504040404010101030404040100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111101010404040404041100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001c7001e10018620011001a600196001760008600086002060008600076000760011610136000b6000a600197002070009600106000e6000f600106000b6100c600136000e6000e600146003770038700
0001000000000141000b6200d100000000000000000000000360002600000000000000000000000a1001161012600000000000000000000000000003600176000000000000000000000005620000000000000000
000100000a7100272002720027200272002720037100371003710047100571006710087100c7100f71012720157201972018720197201b7301c7301e7302170025700297002e700317003e7003f7003a70000000
0001000028710287102871028710297102971029710297102971027710277102572024730237302273021730207401e7401c7501975016750147600f7600c7600000000000000000000000000000000000000000
00010000245102451023100241002d1002e520161002f100161001310003500035000350003500035000350003500000000000000000000000000000000000000000000000000000000000000000000000000000
000100000a5700a570000000000000000125700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f6103f6203d6503c65039650346503365016650146501064029640276302363006630046200462017620176100362002620026200161003610016100161001610016100261002610016100161000000
0001000012640136401364012630106300f6300e6300d6200d6200561005610056100461003610026100261002610016100161001610016100161001610000000000000000000000000000000000000000000000
000f00000f6200463002610026100161001610016100161001610016300160001600016000160001600145000f5000b50007500065001a4001840015400144000530005300033000230002300013000130001300
000200002c6502b6502b6501b6501b6501b6502f100221003010020100301002210030100251002f100271002f100281002f100291002f1002b1002e1002c1002e1002f10032100380003b0003c0002a0002a000
000100001502015020160201e0101e0102f0203102031020360303603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000181301f1302014019050160700a5700857006570045500355003540025400254002530025200152001520015101e70014700015001e70020700227002370025700267002970000000000000000000000
000100000b7100c7100c7100e7200f72010730127401c750257502a76018700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0400c0400c0402464026650286502b6502b6500d0000d0000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000015510165200c0200502006020105200f5100f51003010020100101002010070100501002010010100150009500065000150009700077000670005700057000f700107001070011700000000000000000
0001000004320043200331002310023100d6300b6300a620096200862007600066000560005600056000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001314019150191501d17017100076000660006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b5201d5201e5302b5302e540335100000023530265202652028520295202a5102d5102e500305003a100000000000000000000000000000000000000000000000000000000000000000000000000000
000200002773028730287301a000167401674016740230001b7701b7701b770305002e7502e7402e7202e71000000000002e3002e3002e3002e3002e3002f3002f3002f3002f3002f3002e3002e3002e30000000
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
