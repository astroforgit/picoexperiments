pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- myrtle takes the city
-- #tbj2019
-- by palo blanco games
-- rocco panella


-- convenience
function tand(ang)
 if (ang == 90 or ang == 270) return 0
 angn = -ang/360
 return (sin(angn)/cos(angn))
end

function acos(xx)
	local yy = sqrt(1-xx*xx)
	return atan2(xx,yy)
end

-- drawing constants
fov=60
shrink = tand(fov/2)
nearplane=3
farplane=15
simpleplane=15
widthplane=16 -- in blocks
draw_table={}

-- get camera and player started
--p1 = {}
--p1.x = 8
--p1.y = 4
--p1.z = 0
--p1.dx, p1.dy, p1.dz = 0,0,0
levelx0 = 0
levelx1 = 64
levely0 = 0
levely1 = 64
levelz0 = 0
levelz1 = 16
cam3dx = 32.5
cam3dy = 14
cam3dz = 34
cam3dxmid = 64
cam3dymid = 16 --where the horizon is

-- drawing utility functions
function sort_by_y(tab)
	local newtab = {}
	done=false
	while not done do
  done=true
		for k,v in pairs(tab) do
	  if k > 1 then
	  	if v.y > tab[k-1].y then
	  		local temp = tab[k-1]
	  		tab[k-1] = v
	  		tab[k] = temp
	  		done = false
	  	end
	  end
		end
	end
	return tab
end


-- return screen pix from point
function point2pix(x,y,z)
	camx = x-cam3dx
	camy = y-cam3dy
	camz = z-cam3dz
	scale = 64/(shrink*camy)
	local xpix = camx*scale + cam3dxmid
	local ypix = cam3dymid - camz*scale
	return xpix, ypix, scale
end


			
-->8
-- init
bcols={1,4,6,8,13}
	
function _init()
 music(0)
 blocklist = {}
 actorlist = {}
-- globals
 message=0
 messtime=0
	coins=0
	coinmax=0
	coingoal=100
	gems=0
	gemgoal=7
	mili=0
	sec=0
	minute=0
	gamewin=false
	title=true
	gotsword=false
	gotsheild=false
	gotring=false
	gotboat=false
	swimming=false
	gotkey=false
	ninjacount=10
	gotskull=false
-- city hall
	local b2 = block:inst{x0=26,
	y0=25,z0=0,x1=26+13,
	y1=25+9,z1=8}
	b2.pals={}
	b2.pals[6] = 5
	local b2 = block:inst{x0=27,
	y0=26,z0=8,x1=27+11,
	y1=26+7,z1=16}
	b2.pals={}
	b2.pals[6] = 5
	local b2 = block:inst{x0=28,
	y0=27,z0=16,x1=28+9,
	y1=27+5,z1=24}
	b2.pals={}
	b2.pals[6] = 5
	local b2 = block:inst{x0=31,
	y0=24,z0=0,x1=34,
	y1=25,z1=4}
	b2.pals={}
	b2.pals[6] = 5
	enddoor = block:inst{x0=31,
	y0=23,z0=0,x1=34,y1=24,z1=2,
	kind="door",sprite_off=0}
	enddoor.pals={}
	enddoor.pals[6] = 5
	
	tro = trophy:inst{x=32.5,y=29.5,
	z=24}
	
	sign:inst{x=34.5,y=23.5,
	text=[[

	hey you! see that great trophy
	up there?
	if you want up, you'll need
	7 gems! try lookin' around!
	
	]]}
	
	sign:inst{x=31,y=21.5,
	text=[[
	how to play:
	”ƒ‹‘ move  Žxv run
	—zc jump
 you're invincible myrtle! touch 
 everything!
	
	]]}
--city hall pipes
 pipe:inst({x=32.5,y=23.8,
	xd=26.5,yd=27.5,zd=8.1})
 pipe:inst({x=26.5,y=29.5,
	z=8,xd=32.5,yd=21.5})
 pipe:inst({x=38.5,y=29.5,
	z=8,xd=27.5,yd=28.5,zd=16.1})
 pipe:inst({x=27.5,y=31.5,
	z=16,xd=38.5,yd=27.5,zd=8.1})
 pipe:inst({x=37.5,y=29.5,
	z=16,xd=29.5,yd=28.5,zd=24.1})
 pipe:inst({x=29.5,y=30.5,
	z=24,xd=37.5,yd=27.5,zd=16.1})

-- hero
 p1 = player:inst({x=32.5,y=21.5})
 
-- sad girl
 sg = sadgirl:inst({x=34.5,y=9.5})

-- south corridor
 block:inst{x0=18,
	y0=8,z0=0,x1=30,
	y1=16,z1=5}
	
	sign:inst{x=24.5,y=11.5,z=5,
	text=[[

	i don't know how you did that.
	nice work! 
																								-r
	]]}
	
	
--	b2.pals[6] = 5
	block:inst{x0=35,
	y0=8,z0=0,x1=41,
	y1=16,z1=4}
	
	for xx=35.5,40.5,1 do
		coin:inst{x=xx,y=10.5,z=4}
		coin:inst{x=xx,y=14.5,z=4}
	end
	
	star:inst{x=37.5,y=7.5}
--	b2.pals[6] = 5
	
 coin:inst{x=32.5,y=18.5}
 coin:inst{x=32.5,y=15.5}
 coin:inst{x=32.5,y=12.5}
 coin:inst{x=32.5,y=9.5}

 
 coin:inst{x=36.5,y=21.5}
 coin:inst{x=40.5,y=21.5}
 coin:inst{x=44.5,y=21.5}
 coin:inst{x=48.5,y=21.5}
 coin:inst{x=28.5,y=21.5}
 coin:inst{x=24.5,y=21.5}
 coin:inst{x=20.5,y=21.5}
 
-- southeast corridor
	coin:inst{x=28.5,y=5.5}
 coin:inst{x=24.5,y=5.5}
 coin:inst{x=20.5,y=5.5}
 
 coin:inst{x=36.5,y=5.5}
 coin:inst{x=40.5,y=5.5}
 coin:inst{x=44.5,y=5.5}

-- lake
	local b2 = block:inst{x0=1,
	y0=4,z0=0,x1=14,
	y1=20,z1=0.5,kind="water"}
	b2.pals={}
--	wall around lake
 block:inst{x0=1,
	y0=3,z0=0,x1=15,
	y1=4,z1=1,kind="sw"}

 block:inst{x0=1,
	y0=20,z0=0,x1=15,
	y1=21,z1=1,kind="sw"}

 block:inst{x0=14,
	y0=3,z0=0,x1=15,
	y1=21,z1=1,kind="sw"}

-- wall left of lake
 block:inst{x0=0,
	y0=0,z0=0,x1=1,
	y1=20,z1=3,kind="sw"}

-- island in lake
	local b2 = block:inst{x0=1,
	y0=9,z0=0,x1=5,
	y1=13,z1=1,kind="grass"}
	b2.pals={}
	b2.pals[15]=3
 gem:inst{x=2.5,y=10.5,z=1.2}
-- lake sign
	sign:inst{x=15.5,y=6.5,
	text=[[

	no swimming!!
	
	(boating is allowed)
	
	]]}
	
	sign:inst{x=2.5,y=11.5,z=1,
	text=[[

	wow, whoever made that boat
	animation must have been in a 
	huge rush.
	
	]]}

-- southwest
--dungeon
	block:inst{x0=44,
	y0=8,z0=0,x1=45,
	y1=16,z1=6,sprite_off=0}
	
	block:inst{x0=48,
	y0=8,z0=0,x1=49,
	y1=16,z1=6,sprite_off=0}

	block:inst{x0=45,
	y0=15,z0=0,x1=48,
	y1=16,z1=6,sprite_off=0}

	block:inst{x0=45,
	y0=9,z0=6,x1=48,
	y1=15,z1=7,sprite_off=0}


 ddoor=block:inst{x0=45,
	y0=8,z0=0,x1=48,
	y1=9,z1=6,sprite_off=0,
	kind="door"}
	ddoor.pals={}
	
	gem:inst{x=46.5,y=13.5}
	
	kn=knight:inst{x=48.5,y=7.5}
 
--grass near dungeon
	block:inst{x0=53,
	y0=0,z0=0,x1=56,
	y1=16,z1=0,kind="grass",
	sprite_off=0}
	
	block:inst{x0=56,
	y0=0,z0=0,x1=64,
	y1=5,z1=0,kind="grass",
	sprite_off=0}
	
	block:inst{x0=63,
	y0=5,z0=0,x1=64,
	y1=16,z1=0,kind="grass",
	sprite_off=0}
	
 block:inst{x0=56,
	y0=5,z0=0,x1=63,
	y1=15,z1=1,kind="grass",
	sprite_off=0}
	
	block:inst{x0=59,
	y0=12,z0=1,x1=63,
	y1=15,z1=5,kind="grass",
	sprite_off=0}
	
	block:inst{x0=59,
	y0=8,z0=1,x1=63,
	y1=12,z1=2,kind="grass",
	sprite_off=0}
	
	block:inst{x0=59,
	y0=10,z0=2,x1=61,
	y1=12,z1=4,kind="grass",
	sprite_off=0}
	
	block:inst{x0=61,
	y0=10,z0=2,x1=63,
	y1=12,z1=3,kind="grass",
	sprite_off=0}
	
	sword:inst{x=61.5,
	y=13.5,z=5.1}
	shield:inst{x=62.5,
	y=2.5,z=0}
	tree:inst{x=62.5,
	y=1.5,z=0}
	tree:inst{x=59.5,
	y=1.5,z=0}
	tree:inst{x=58.5,
	y=3.5,z=0}
	tree:inst{x=57.5,
	y=4.5,z=0}
	tree:inst{x=54.5,y=2.5,
	z=0}
	
--midwest
	b2=block:inst{x0=45,
	y0=25,z0=0,x1=51,
	y1=33,z1=7}
	b2.pals={}
	b2.pals[6] = 4
	star:inst{x=51.5,y=25.5}
	star:inst{x=51.5,y=27.5,z=4}
 key:inst{x=45.5,y=30.5,z=7.1}
 
--west
	x00=55
	y00=25
	x11=64
	y11=45

	make_houses(x00,y00,x11,y11,2)
	gem:inst{x=x00+(x11-x00)*rnd(),
	y=y00+(y11-y00)*rnd(),
	z=15}
	
-- parthenon
	x00=54
	y00=18
	x11=64
	y11=22
	
	block:inst{x0=x00,
	y0=y00,x1=x11,y1=y11,
	z0=0,z1=1,kind="sw"}
	block:inst{x0=x00,
	y0=y00,x1=x11,y1=y11,
	z0=4,z1=5,kind="sw"}
	pillar:inst{x=54.5,y=18.5,z=1}
	pillar:inst{x=54.5,y=21.5,z=1}
	pillar:inst{x=63.5,y=18.5,z=1}
	pillar:inst{x=63.5,y=21.5,z=1}
	chest:inst{x=59,y=19.5,z=1}
	
	-- hedge maze
	x00=35
	y00=44
	x11=50
	y11=56
	local b2 = block:inst{x0=x00+1,
	y0=y00+1,z0=0,x1=x11-1,
	y1=y11,z1=8,kind="grass",
	sprite_off=0}
	b2.pals={}
	b2.pals[15]=3
	local b2 = block:inst{x0=x00,
	y0=y00,z0=0,x1=x00+1,
	y1=y11,z1=5,kind="grass",
	sprite_off=0}
	b2.pals={}
	b2.pals[15]=3
	star:inst{x=x00-.5,y=y11-1.5}	
	local b2 = block:inst{x0=x00,
	y0=y00,z0=0,x1=x11,
	y1=y00+1,z1=6,kind="grass",
	sprite_off=0}
	b2.pals={}
	b2.pals[15]=3
	local b2 = block:inst{x0=x11-1,
	y0=y00+1,z0=0,x1=x11,
	y1=y11,z1=7,kind="grass",
	sprite_off=0}
	b2.pals={}
	b2.pals[15]=3
-- sloppy hedge maze
	for ii=0,25,1 do
		xt=x00+1.5+(x11-x00-2)*rnd()
		xc=x00+1.5+(x11-x00-2)*rnd()
		yt=y00+1.5+(y11-y00-1)*rnd()
		yc=y00+1.5+(y11-y00-1)*rnd()
		
		tree:inst{x=xt,y=yt,z=8}
		coin:inst{x=xc,y=yc,z=8}
	end 
	gem:inst{x=x00+1+(x11-x00-1)*rnd(),
	y=y00+1+(y11-y00-1)*rnd(),
	z=15}
 
--skyscraper w gem
	x00=16
	y00=52
	x11=30
	y11=64
 
	b2=block:inst{x0=x00,
	y0=y00,z0=0,x1=x11,
	y1=y11,z1=25}
	b2.pals={}
	b2.pals[6] =14
	
	sxold=x00
	for zz=0,20,5 do
		xrnd=8-16*rnd()
		if (sxold+xrnd<x00 or sxold+xrnd>x11) xrnd=-xrnd
		xrnd=sxold+xrnd
		star:inst{x=xrnd,y=y00-0.5,z=zz}
	end
	
	for ii=0,25,1 do
		xc=x00+1.5+(x11-x00-2)*rnd()
		yc=y00+1.5+(y11-y00-2)*rnd()
		
		coin:inst{x=xc,y=yc,z=25}
	end 
	gem:inst{x=x00+1+(x11-x00-1)*rnd(),
	y=y00+1+(y11-y00-1)*rnd(),
	z=25}
	
-- ninja town
	x00=0
	y00=27
	x11=16
	y11=46
	
	make_houses(x00,y00,x11,y11,1)
	
 for i=1,10,1 do
 	xn=x00+(x11-x00)*rnd()
 	yn=y00+(y11-y00)*rnd()
 	ninja:inst{x=xn,
		y=yn,
		z=15}
	end
	landlord:inst{x=18.5,y=25.5}
	pipe:inst{x=16.5,y=25.5,
	xd=16.5,yd=28.5,zd=10}
 
-- graveyard
	local b2 = block:inst{x0=1,
	y0=49,z0=0,x1=10,
	y1=53,z1=0,kind="grass"}
	b2.pals={}
	b2.pals[15]=3	 
	tree:inst{x=2.5,y=50.5}
	tree:inst{x=8.5,y=50.5}
	grave:inst{x=5.5,y=50.5}
	
-- northeast city
	x00=0
	y00=55
	x11=12
	y11=61
	
	make_houses(x00,y00,x11,y11,1)
	ring:inst{x=6.5,y=62.5,z=20}
 
-- northwest
 x00=35
	y00=58
	x11=64
	y11=62
	
	make_houses(x00,y00,x11,y11,1)
	skull:inst{x=59.5,y=60.5}
	star:inst{x=62.5,y=57.5}
-- north of city hall
		
	x00=23
	y00=37
	x11=49
	y11=40
	
	make_houses(x00,y00,x11,y11,1)
	star:inst{x=22.5,y=36.5}

--	grass south of skyscraper
	local b2 = block:inst{x0=23,
	y0=45,z0=0,x1=31,
	y1=49,z1=0,kind="grass"}
	b2.pals={}
	b2.pals[15]=3	 
	
	for ii=0,10,1 do
		xc=23+.5+(31-23-1)*rnd()
		yc=45+.5+(49-45-1)*rnd()
		
		tree:inst{x=xc,y=yc,z=0}
	end 
	
	boat:inst{x=27,y=47}
		
 
 add_sidewalks()
 drawlist_build()
 zones_build()
 
-- initialize shadows
	for act in all(actorlist) do
		act:collide()
	end
	
end

function add_sidewalks()
	for bb in all(blocklist) do
		if bb.kind == "bl" and
			bb.z0==0 then
			block:inst({x0=bb.x0-1,
			y0=bb.y0-1,x1=bb.x1+1,
			y1=bb.y0,z0=0,z1=0,kind="sw"})
			
			block:inst({x0=bb.x0-1,
			y0=bb.y1,x1=bb.x1+1,
			y1=bb.y1+1,z0=0,z1=0,kind="sw"})

			block:inst({x0=bb.x0-1,
			y0=bb.y0,x1=bb.x0+1,
			y1=bb.y1,z0=0,z1=0,kind="sw"})
			
			block:inst({x0=bb.x1,
			y0=bb.y0,x1=bb.x1+1,
			y1=bb.y1,z0=0,z1=0,kind="sw"})

		end
	end
end

function drawlist_build()
 drawlist = {}
 for i=levely0,levely1-1,1 do
 	drawlist[i] = {}
 	local dl1={}
 	-- currently broken
 	-- try adding children to
 	-- blocks?
 	for _,bb in pairs(blocklist) do
 		if bb.y0<=i and bb.y1>i then
 		 
 		 add(dl1,bb)
 		end
 	end
 	stack=true
 	while stack do
 		stack=false
 		local dl2 = {}
 		for b1 in all(dl1) do
 			for b2 in all(dl1) do
 				if b1.x0 < b2.x1 and
					b1.x1 > b2.x0 and
					b1.y0 < b2.y1 and
					b1.y1 > b2.y0 then
						if b1.z1>b2.z1 then
							add(dl2,b1)
							stack=true
						end
					end
 			end
 		end
 		for __,b1 in pairs(dl2) do
				del(dl1,b1)
 		end
 		add(drawlist[i],dl1)
 		dl1={}
 		for __,each in pairs(dl2) do
 			add(dl1, each)
 		end
 	end
 end
end

-- zones for collisions
function zones_build()
	zones={}
	for xx=levelx0,levelx1-1,8 do
		local xloc={}
		for yy=levely0,levely1-1,8 do
			local zblocks = {}
			local zactors = {}
			for bb in all(blocklist) do
				if bb.x0 < xx+9 and
					bb.x1 > xx-1 and
					bb.y0 < yy+9 and
					bb.y1 > yy-1 then
					add(bb.myzone,{(xx/8)+1,(yy/8)+1})
					add(zblocks,bb)
				end
			end
			for aa in all(actorlist) do
				if aa.x < xx+8 and
					aa.x > xx and
					aa.y < yy+8 and
					aa.y > yy then
					add(zactors,aa)
					if (aa.sprite==48) coinmax+=1
				end
			end
			add(xloc,{zblocks,zactors})
		end
	add(zones,xloc)
	end
end

function make_houses(x00,y00,
x11,y11,cc)
	for xx=x00,x11,5 do
		for yy=y00,y11,5 do
			zr=5+flr(2*rnd())
			b2=block:inst{x0=xx,
			y0=yy,z0=0,x1=xx+4,
			y1=yy+4,z1=zr}
			b2.pals={}
			b2.pals[6] = bcols[flr(1+5*rnd())]
			--star:inst{x=xx+.5+3*rnd(),y=yy+0.5+3*rnd(),z=zr}
			for i=1,cc,1 do
				coin:inst{x=xx+.5+3*rnd(),y=yy+0.5+3*rnd(),z=zr}
			end
		end
	end
end
-->8
-- update

function _update()
	
	swimming=false
 -- print text
 printtext=""
 messtime=max(0,messtime-1)
 
 -- time
 if (not gamewin) and (not title) then
 	mili += 2
 	sec += flr(mili/60)
 	mili = mili%60
 	minute += flr(sec/60)
 	sec = sec%60
 end
	
	if title then
		if btnp(4) or btnp(5) then
		 title = false
		 music(6)
		end
	end
	  
 -- actor row store
 actrow={}
 -- actor update
 for act in all(actorlist) do
 	act:update()
 	--act:collide()
 	act:updatelate()
 end
 cam_update()
 stat1=stat(1)
 
end



function cam_update()
 damp=16
 if (title) damp=96
 cam3dx += (p1.x-cam3dx+30*p1.dx)/damp
 cam3dy += (p1.y-7-cam3dy+30*p1.dy)/damp
 cam3dz += (p1.z+4-cam3dz)/damp
 cam3dx = min(levelx1-2.5,max(levelx0+2.5,cam3dx))
 cam3dy = min(levely1-10,max(levely0-4,cam3dy))


end


-->8
-- draw

plist={0b0000000000000000,
0b0001000001000000,
0b0101000001010000,
0b0101101001011010,
0b1111111111111111}
dl={11,21,31,41,51}

function draw_floor()
	cls(12)
	circfill(96,20,10,sunc)
	palt(0,false)
	pal(6,5)
	pal(7,6)
	map(0,0,(64-cam3dx)/2-64,cam3dz/1-20,32,10)
	pal()
	c1=1
	c2=0
	ylist={}
	yold=127
	i=1
	--draw the floor
	for _,yd in pairs(dl) do
		_x,yp,_s = point2pix(8,yd+cam3dy,0)
		--add(ylist,yp)	
		fillp(plist[i])
		rectfill(0,yp,127,yold,c2*16+c1)--0x5f)
		yold=yp
		i+=1
	end
 fillp()
 --draw some guide lines
 ypl,xml={},{}
-- xml={}

 for yd=11,3,-1 do
  yworld = flr(yd+cam3dy)
  _x,yp,_s = point2pix(8,yworld,0)
  line(0,yp,127,yp,c1*16+c2)
 end
 for xd=-5,5,1 do
  xw = flr(xd+cam3dx)
  y0 = flr(11+cam3dy) 
  y1 = flr(3+cam3dy)
  local xp0,yp0,_s = point2pix(xw,y0,0)
  local xp1,yp1,_s = point2pix(xw,y1,0)
  line(xp0,yp0,xp1,yp1,c1*16+c2)
 end

end

function drawblocks()
	fp = flr(cam3dy)+farplane
	np = max(0,flr(cam3dy)+nearplane)
	drawact={}
	for i=levely0,levely1-1,1 do
 	drawact[i] = {}
 end
	for act in all(actorlist) do
		actlayer = flr(act.y)
		add(drawact[actlayer],act)
	end
	for sl=fp,np,-1 do
		palt(0,false)
		for layer in all(drawlist[sl]) do
		 for _,b in pairs(layer) do
		  b:drawprep(sl)
		  b:drawside()
		 end
		 for _,b in pairs(layer) do
		  b:drawtop()
		 end
		end
		palt()
		if actrow[sl] then
			actrow[sl]=sort_by_y(actrow[sl])
			for act in all(actrow[sl]) do
				act:drawshadow()
			end
			for act in all(actrow[sl]) do
				act:draw()
			end
		end
		palt(0,false)
		for layer in all(drawlist[sl]) do
		 for _,b in pairs(layer) do
		  b:drawfront()
		 end
		end
		palt()
	end
	

end
-------------
-- draw utilities
-------------

function palw(w)
	for i=1,15,1 do
		pal(i,w)
	end
end

function oprint(str,xnew,y)
 --xnew = x--+8-#str*2
 for xx=xnew-1,xnew+1,1 do
 	for yy=y-1,y+1,1 do
 		print(str,xx,yy,0)
 	end
 end
 print(str,xnew,y,7)
end

skyc,sunc=9,15
--sunc=15

function _draw()
	-- draw background
	
	draw_floor()
	drawblocks()
 
 
 --print time
 mm=""..mili
 sc=""..sec
 mins=""..minute
 if (#mm<2) mm = "0"..mm
 if (#sc<2) sc = "0"..sc
 texttime=mins..":"..sc
 --status bar
 rectfill(0,120,127,127,1)
 print("coins: "..coins.."  gems: "..gems.." time: "..texttime,1,121,7)
 -- print messages
 if #printtext>0 then
 	rectfill(0,96,127,127,15)
 	rect(0,96,127,127,3)
 	print(printtext,0,97,3)
 end
 -- messages
 if messtime>0 then
 	rectfill(0,104,127,127,8)
 	rect(0,104,127,127,0)
 	print(message,1,105,7)
 end

	
	--print("mem:"..(stat(0)/2048).."  cpu:"..stat(1))
	--print("x:"..cam3dx.."  y:"..cam3dy.."  z:"..cam3dz,0,0,10)
	--print("")
	--print(stat(1))
	--print(p1.cycle)
	--print(p1.angle_t)
	
	-- end game
	if gamewin then
		palt(5,true)
		palt(6,true)
		dsprintxy("you won!",2,32,8,1,1)
		printo("time: "..texttime..":"..mm,38,48,8,1)
		printo("gems: "..gems.."/10",38,58,8,1)
		printo("coins: "..coins.."/135",38,68,8,1)
		printo("thanks for playing!",30,88,8,1)		
		printo("#tbj2019, paloblanco games",13,98,8,1)		
	end
	if title then
		pal(5,10)
		palt(6,true)
		dsprintxy("myrtle",14,32,8,1,1)		
		printo("takes the city",38,48,8,1)
		printo("#tbj2019, paloblanco games",13,68,8,1)						
		printo("press —Ž (z or c) to start",9,107,7,0)
		pal()
	end
end


-->8
-- block class

kinds = {}
kinds.bl = {
top=63,
front=1,
side=1,
c=0,
pals={}}
kinds.bl.pals[6]=6

kinds.door = {
top=1,
front=90,
side=1,
c=0,
pals={}}
kinds.bl.pals[6]=6


kinds.sw = {
top=59,
front=59,
side=59,
c=0,
pals={}
}

kinds.water = {
top=16,
front=16,
side=16,
c=0,
pals={}
}

kinds.grass = {
top=14,
front=14,
side=14,
c=0,
pals={}
}
kinds.grass.pals[15]=11

block = {
x0=0,
y0=0,
z0=0,
x1=0,
y1=0,
z1=0,
kind="bl",
pals={},
topx=8*(141%16),
topy=8*(flr(141/16)),
frontx=8*(141%16),
fronty=8*(flr(141/16)),
sidex=8*(141%16),
sidey=8*(flr(141/16)),
sprite_off=4*8,
drawme=false,
myzone={}
}

block.__index = block

function block:new(o)
	local o = o or {}
	setmetatable(o,self)
	-- do some lookup stuff
	tops=kinds[o.kind].top
	fronts=kinds[o.kind].front
	sides= kinds[o.kind].side
	o.topx=8*(tops%16)
	o.topy=8*(flr(tops/16))
	o.frontx=8*(fronts%16)
	o.fronty=8*(flr(fronts/16))
	o.sidex=8*(sides%16)
	o.sidey=8*(flr(sides/16))
	for cc1,cc2 in pairs (kinds[o.kind].pals) do
	 o.pals[cc1]=cc2
	end
	o.__index=o
	return o
end

function block:inst(o)
	oo = self:new(o)
	add(blocklist,oo)
	return oo
end

function block:killme()
	del(blocklist, self)
	for yy=self.y0-1,self.y1+1,1 do
		for stack in all(drawlist[yy]) do
			del(stack, self)
		end
	end
	for zz in all(self.myzone) do
		del(zones[zz[1]][zz[2]][1],self)
	end
end

function block:drawprep(ysl)
	--ysl is the depth of interest
	self.ysl=ysl
	self.xp0,self.yp0,self.s0 = point2pix(self.x0,ysl+1,self.z1)
	self.xstep=self.x1-self.x0
	self.drawme=true
	if (self.xp0>127 or self.xp0+self.xstep*self.s0<0) self.drawme=false
	if self.drawme then	
	self.xp1,self.yp1,self.s1 = point2pix(self.x0,ysl,self.z1)
	self.ystep=self.z1-self.z0
	self.xpp1=self.xp1+self.s1*self.xstep
	self.xpp0=self.xp0+self.s0*self.xstep	
	self.ypp1=self.yp1+self.s1*self.ystep
	self.ypp0=self.yp0+self.s0*self.ystep
	end
end

function block:drawside()
--side
	if self.drawme then
	for cc1,cc2 in pairs(self.pals) do
		pal(cc1,cc2)
	end
	if (self.xp0 < self.xp1) and
	 (self.xp0<128) then
	 for xpix=self.xp0,self.xp1,1 do
	 	if (xpix>=128) break
	 	rate=(xpix-self.xp0)/(self.xp1-self.xp0)
		 ypix=self.yp0+(self.yp1-self.yp0)*rate
		 spix=self.s0+(self.s1-self.s0)*rate
		 spx=flr(8*rate)+self.sidex
		 for ii=1,self.ystep,1 do
		 	yoff=(ii-1)*spix
		 	xpoff=self.sprite_off*(1-(ii%2))
		 	sspr(spx+xpoff,self.sidey,1,8,xpix,ypix+yoff,1,spix+1)
		 end
	 end
	 line(self.xp0,self.ypp0,self.xp1,self.ypp1,0)	
	 if self.y1-1 == self.ysl then
			line(self.xp0,self.yp0,self.xp0,self.ypp0,0)
		end
	elseif (self.xpp0 > self.xpp1) and
		(self.xpp0 > 0) then
		for xpix=self.xpp1,self.xpp0,1 do
	 	if xpix>0 then
	 	rate=(xpix-self.xpp1)/(self.xpp0-self.xpp1)
		 ypix=self.yp1+(self.yp0-self.yp1)*rate
		 spix=self.s1+(self.s0-self.s1)*rate
		 spx=flr(8*rate)+self.sidex
		 for ii=1,self.ystep,1 do
		 	yoff=(ii-1)*spix
		 	xpoff=self.sprite_off*(1-(ii%2))
		 	sspr(spx+xpoff,self.sidey,1,8,xpix,ypix+yoff,1,spix+1)
		 end
		 end
	 end
	 line(self.xpp0,self.ypp0,self.xpp1,self.ypp1,0)	
	 if self.y1-1 == self.ysl then
			line(self.xpp0,self.yp0,self.xpp0,self.ypp0,0)
		end
	end	
	pal()
	palt(0,false)
	end
end

function block:drawtop()
	--top
	if self.drawme then
	for cc1,cc2 in pairs(self.pals) do
		pal(cc1,cc2)
	end
	if (self.yp0 < self.yp1) and
		(self.yp0 < 128) then
		for ypix=self.yp0,self.yp1,1 do
		 rate=(ypix-self.yp0)/(self.yp1-self.yp0)
		 xpix=self.xp0+(self.xp1-self.xp0)*rate
		 spix=self.s0+(self.s1-self.s0)*rate
		 spy=flr(8*rate)+self.topy
		 for ii=1,self.xstep,1 do
		 	xoff=(ii-1)*spix
		 	if (xpix+xoff>128) break
		 	sspr(self.topx,spy,8,1,xpix+xoff,ypix,spix+1,1)
		 end
		end
		if self.y1-1 == self.ysl then
			line(self.xp0,self.yp0,self.xpp0,self.yp0,0)
		end
		if self.y1-1 == self.ysl then
			line(self.xp0,self.ypp0,self.xpp0,self.ypp0,0)
		end	
	end
	--lines
	line(self.xp0,self.yp0,self.xp1,self.yp1,0)
	line(self.xpp0,self.yp0,self.xpp1,self.yp1,0)
	pal()
	palt(0,false)
	end
end

function block:drawfront()
	if self.drawme then
	for cc1,cc2 in pairs(self.pals) do
		pal(cc1,cc2)
	end
	if self.y0 == self.ysl then
		for i=1,self.xstep,1 do
			xpix=self.xp1+(i-1)*self.s1
			if (xpix>128) break
			for ii=1,self.ystep,1 do
				ypix=self.yp1+(ii-1)*self.s1
				if (ypix>128) break
				if ypix+self.s1>0 then	
					xpoff=self.sprite_off*(1-(ii%2))
					if (xpix+self.s1+1>0) sspr(self.frontx+xpoff,self.fronty,8,8,xpix,ypix,self.s1+1,self.s1+1)
				end
			end
		end
		rect(self.xp1,self.yp1,self.xpp1,self.ypp1,0)
	end
	pal()
	palt(0,false)
	end
end


-->8
-- demo utils
----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|€€‚ƒ„…†‡ˆ‰Š‹ŽŒŽ‘’“”•–—˜™~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end

setup_asciitables()
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end

-------------------------------

-------------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end
-------------------------------
-------------------------------
-- double-sized sprite print at x,y pixel coords
function dsprintxy(_str,_x,_y,_c,_c2,_c3)
 local i, num,sx,sy
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
 -- (btw you can use this technique
 -- just to draw sprites bigger)
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  sy=flr(num/16)*8
  sx=(num%16)*8
  sspr(sx,sy,8,8,_x+(i-1)*16,_y,16,16)
 end
 pal()
end
-->8
-- actor class
actor = {
x=0.5,
y=0.5,
z=0,
dx=0,
dy=0,
dz=0,
xw=0.8,
yw=0.8,
zw=0.8,
angle=0.75,
angle_t=0.75,
cycle=0,
freezet=0,
shadow=true,
ground=false,
fast=false,
zfloor=0,--height to draw shadow
akind="harry",
sprite=98,
spritesize=8,
myblocks={},
text="",
drawme=true
}

actor.__index = actor

function actor:new(o)
	local o = o or {}
	setmetatable(o,self)
	--fix sprite location
	o.xp = (o.sprite%16)*8
	o.yp = 8*flr(o.sprite/16)
	o.__index=o
	return o
end

function actor:setsprite(num)
	self.sprite=num
	self.xp = (num%16)*8
	self.yp = 8*flr(num/16)
end

function actor:inst(o)
	local oo = self:new(o)
	add(actorlist,oo)
	return oo
end

function actor:draw()
	--ysl is the depth of interest
	if self.drawme then
	local xp0,yp0,s0 = point2pix(self.x,self.y-0.25,self.z)
	local xpix=xp0-s0*self.xw*0.5+0.5
	local ypix=yp0-s0*self.zw
	sspr(self.xp,self.yp,
	self.spritesize,
	self.spritesize,
	xpix,ypix,s0*self.xw,
	s0*self.zw)
	end
end

function actor:drawfancy()
	--ysl is the depth of interest
	local xp0,yp0,s0 = point2pix(self.x,self.y-0.25,self.z)
	yp0 = yp0-(s0*0.3)-s0*0.2*(abs(sin(self.cycle/15)))
	local xpix=xp0-s0*self.xw*0.5+0.5
	local ypix=yp0-s0*self.zw
	local xmid=xpix+s0*self.xw*0.5
	pal(2,8)
	circfill(xp0+0.5,yp0-s0*self.zw*0.5,s0*self.zw*0.7,8)
	for xpp=xpix,xpix+s0*self.xw,1 do
		-- get fancy!!
		xunit=(xpp-xmid)/(s0*self.xw*0.5)
		xpcos=flr(8*(-self.angle_t+acos(xunit)-0.75)*2)%16
  if xpcos<8 then
  	sspr(self.xp+xpcos,self.yp,
  	1,self.spritesize,
  	xpp,ypix,1,s0*self.zw)		
  end
	end
	circ(xp0+0.5,yp0-s0*self.zw*0.5,s0*self.zw*0.7,0)
	if swimming then
		sspr((54%16)*8,8*flr(54/16),
		self.spritesize,
		self.spritesize,
		xpix,ypix,s0*self.xw*1.7,
		s0*self.zw*1.7)
	end
end

function actor:drawshadow()
 if self.shadow then
 	local xp0,yp0,s0 = point2pix(self.x,self.y-0.25,self.zfloor)
		local xpix=xp0-s0*self.xw*0.5+0.5
		rectfill(xp0-s0/2,yp0-s0/4,
		xp0+s0/2,yp0+s0/4,0)
	end
end

function actor:collide()
	if (self.x-self.xw/2 < levelx0)	self.x = levelx0+self.xw/2
	if (self.x+self.xw/2 > levelx1)	self.x = levelx1-self.xw/2
	if (self.y-self.yw/2 < levely0)	self.y = levely0+self.yw/2
	if (self.y+self.yw/2 > levely1)	self.y = levely1-self.yw/2
	
	zblocks=zones[1+flr(self.x/8)][1+flr(self.y/8)]
	local newblocks={}
	self.zfloor=0
	self.ground=false
	
	for bb in all(zblocks[1]) do
	 if self.dx>0 then
	 	-- did i cross into the box?
	 	if self.x+(self.xw/2)>bb.x0 and
	 		self.x+(self.xw/2)-self.dx<=bb.x0 and
	 		self.y-self.yw/2<bb.y1 and self.y+self.yw/2>bb.y0 then
	 		-- is my z colliding?
	 		if self.z+self.zw>=bb.z0 and 
	 			self.z+0.1<=bb.z1 then
	 			--push outside the box
	 			self.dx=0
	 			self.x=bb.x0-self.xw/2
	 		else -- enter this block
	 			--add(newblocks,bb)
	 		end
	 	end
	 end
	 if self.dx<0 then
	 	-- did i cross into the box?
	 	if self.x-self.xw/2<bb.x1 and
	 		self.x-self.xw/2-self.dx>=bb.x1 and
	 		self.y-self.yw/2<bb.y1 and self.y+self.yw/2>bb.y0 then
	 		-- is my z colliding?
	 		if self.z+self.zw>=bb.z0 and 
	 			self.z+0.1<=bb.z1 then
	 			--push outside the box
	 			self.dx=0
	 			self.x=bb.x1+self.xw/2
	 		else -- enter this block
	 			--add(newblocks,bb)
	 		end
	 	end
	 end
	 if self.dy>0 then
	 	-- did i cross into the box?
	 	if self.y+self.yw/2>bb.y0 and
	 		self.y+self.yw/2-self.dy<=bb.y0 and
	 		self.x-self.xw/2<bb.x1 and self.x+self.xw/2>bb.x0 then
	 		-- is my z colliding?
	 		if self.z+self.zw>=bb.z0 and 
	 			self.z+0.1<=bb.z1 then
	 			--push outside the box
	 			self.dy=0
	 			self.y=bb.y0-self.yw/2
	 		else -- enter this block
	 			--add(newblocks,bb)
	 		end
	 	end
	 end
	 if self.dy<0 then
	 	-- did i cross into the box?
	 	if self.y-self.yw/2<bb.y1 and
	 		self.y-self.yw/2-self.dy>=bb.y1 and
	 		self.x-self.xw/2<bb.x1 and self.x+self.xw/2>bb.x0 then
	 		-- is my z colliding?
	 		if self.z+self.zw>=bb.z0 and 
	 			self.z+0.1<=bb.z1 then
	 			--push outside the box
	 			self.dy=0
	 			self.y=bb.y1+self.yw/2
	 		else -- enter this block
	 			--add(newblocks,bb)
	 		end
	 	end
	 end
	-- enter this block
		if self.x-self.xw/2 < bb.x1 and
			self.x+self.xw/2 > bb.x0 and
			self.y-self.yw/2 < bb.y1 and
			self.y+self.yw/2 > bb.y0 then
			add(newblocks,bb)
		end
	end
	for bb in all(newblocks) do
		-- do z collisions
		if self.z < bb.z1 and self.z > bb.z0 then
			if self.dz < 0 then
			 self.dz=0
			 self.z=bb.z1
			 self.ground=true
			 if bb.kind=="water" then
			 	if gotboat then
			 		swimming=true
			 	else
			 		self.x=15.75
			 		self.y=6.75
			 		self.z=0
			 		sfx(16)
			 	end
			 end
			end
		end
		if (self.z >= bb.z1) self.zfloor=max(bb.z1,self.zfloor)
	end
	if self.z < 0 then
		self.dz=0
		self.z=0
		self.ground=true
	end
end

function actor:updatelate()
 myrow=flr(self.y)
 if actrow[myrow] then
 	add(actrow[myrow],self)
 else
 	actrow[myrow]={self}
 end
end

function actor:update()
end

-- specific classes

player = actor:new({sprite=101})
foot = actor:new({sprite=185,shadow=false})

function player:update()
	self.dx,self.dy=0,0
	fast=false
	if self.feet==nil then
		self.feet={}
		fl = foot:new({x=0,y=0})
 	add(actorlist,fl)
 	fr = foot:new({x=0,y=0})
 	add(actorlist,fr)
 	add(self.feet,fl)
 	add(self.feet,fr)
	end
	if self.freezet <=0 and
		not gamewin and
		not title then
		if (btn(0)) self.dx = -0.1
		if (btn(1)) self.dx = 0.1
		if (btn(2)) self.dy = 0.1
		if (btn(3)) self.dy = -0.1
		if btnp(4) and self.ground then
			self.dz = 0.22
			sfx(7)
		end
		if (btn(5)) fast=true
	end
	self.freezet = max(0,self.freezet-1)
	--if (btn(5)) self.dz = -0.2
	if abs(self.dx)+abs(self.dy)>0.1 then
		self.dx/=1.41
		self.dy/=1.41
	end
	
	if (fast) self.dx*=2
	if (fast) self.dy*=2
	
	self.dz += -.02
	self.x+=self.dx
	self.y+=self.dy
	self.z+=self.dz
	
	cp=1
	if (fast) cp=2
	if self.dx!=0 or self.dy!=0 then
		self.angle=atan2(self.dx,-self.dy)
		self.cycle = ((self.cycle+cp)%15)
	else
		if self.cycle<7 then
			self.cycle+=(0-self.cycle)/3
			if (self.cycle<2) self.cycle=0
		else
			self.cycle+=(15-self.cycle)/3
			if (self.cycle>13) self.cycle=0
		end
	end
	if (not self.ground) self.cycle=4
 if (self.cycle%7==1) sfx(20)	
 if (self.cycle%7==2 and fast) sfx(20)	
		
	if self.angle-self.angle_t < -0.5 then
		self.angle_t = (self.angle_t + (1+self.angle-self.angle_t)*0.25)%1				
	elseif self.angle-self.angle_t <= 0.5 then
		self.angle_t = (self.angle_t + (self.angle-self.angle_t)*0.25)%1
	else
		self.angle_t = (self.angle_t + (self.angle_t-(1-self.angle))*0.25)%1
	end
	if (abs(self.angle-self.angle_t)<0.1) self.angle_t = self.angle
	addx=cos(self.angle_t)*sin(self.cycle/15)*0.3
	addy=sin(-self.angle_t)*sin(self.cycle/15)*0.3
	addz=abs(sin(self.cycle/15))*0.3
	self.feet[1].x=self.x-sin(-self.angle_t)*0.3+addx
	self.feet[1].y=self.y+cos(self.angle_t)*0.3+addy
	self.feet[2].x=self.x+sin(-self.angle_t)*0.3-addx
	self.feet[2].y=self.y-cos(self.angle_t)*0.3-addy
	self.feet[1].z=self.z+addz
	self.feet[2].z=self.z+addz
	
	self:collide()
	self:act_collide()
end

function player:draw()
	--ysl is the depth of interest

	
	self:drawfancy()
end

function player:act_collide()
	-- check against actors in zones
	zblocks=zones[1+flr(self.x/8)][1+flr(self.y/8)]
	for other in all(zblocks[2]) do
		if abs(self.x-other.x)<1 and abs(self.y-other.y)<1 and abs(self.z-other.z)<1 then
			if fget(other.sprite,0) then
				printtext=other.text
			end
			if fget(other.sprite,1) then
				coins+=1

				if coins==100 then
					other:setsprite(122)
					other.z+=1.5
					message=[[
	100 coins! nice job!
	there are a few more hiding
	still...
					]]
					messtime=150
					sfx(5)
				else
					sfx(10)
					del(zblocks[2],other)
					del(actorlist,other)
				end
				
			end
			if other.sprite==122 then
				gems+=1
				del(zblocks[2],other)
				del(actorlist,other)
				sfx(12)
				if gems == gemgoal then 
					enddoor:killme()
					message=[[
	that's 7 gems! head to city
	hall! there are 3 more gems
	hiding if you care...
					]]
					messtime=150
				end
			end
			if other.sprite==143 then
				self.x = other.xd
				self.y = other.yd
				self.z=other.zd
				self.freezet=30
				sfx(3)
			end
			if other.sprite==75 then
			 -- end game
			 del(zblocks[2],other)
				del(actorlist,other)
				music(-1)
				music(24)
				gamewin=true
			end
			if other.sprite==26 then
				del(zblocks[2],other)
				del(actorlist,other)
				gotsword=true
				if (gotsword and gotshield) swordshield()
				message="got the sword!"
				messtime=150
				sfx(5)
			end
			if other.sprite==29 then
				del(zblocks[2],other)
				del(actorlist,other)
				gotshield=true
				if (gotsword and gotshield) swordshield()
				message="got the shield!"
				messtime=150
				sfx(5)
			end
			if other.sprite==116 then
				if other.drawme then
					other.cycle=60
					self.dz=0.5
					other.drawme=false
					sfx(2)
				end
			end
			if other.sprite==30 then
				del(zblocks[2],other)
				del(actorlist,other)
				gotkey=true
				message="where does this *key* go?"
				messtime=150
				sfx(5)
			end
			if other.sprite==53 then
				if gotkey then
					other:setsprite(122)
					other.z+=1.5
					other.dz=0.2
					message=[[
	it was right over there!?
	are you kidding me???
					]]
					messtime=150
					sfx(5)
				end
			end
			if other.sprite==128 then
				del(zblocks[2],other)
				del(actorlist,other)
				ninjacount+=-1
				message="only "..ninjacount.." ninjas to go!"
				messtime=150
				sfx(5)
				if ninjacount == 0 then
					message="that's the last ninja!"
					messtime=150
					sfx(5)
				end
			end
			if other.sprite==102 then
				if ninjacount==0 then
					other:setsprite(122)
					other.z+=1.5
					other.dz=0.2
					message=[[
	thanks myrtle!
	(ninja stew...mmm)
					
					]]
					messtime=150
					sfx(5)
				end
			end
			if other.sprite==117 then
				del(zblocks[2],other)
				del(actorlist,other)
				gotskull=true
				message=[[
		...return me...
								...to my place...
				]]
				messtime=150
				sfx(18)
			end
			if other.sprite==52 then
				if gotskull then
					other:setsprite(122)
					other.z+=1.5
					other.dz=0.2
					message=[[
		...thanks myrtle...
								...you're a peach...

					]]
					messtime=150
					sfx(18)
				end
			end
			if other.sprite==50 then
				del(zblocks[2],other)
				del(actorlist,other)
				gotring=true
				message=[[
		found an engagment ring!
		... looks like its worth
				alot!!
				]]
				messtime=150
				sfx(5)
			end
			if other.sprite==96 then
				if gotring then
					other:setsprite(122)
					other.z+=1.5
					other.dz=0.2
					message=[[
		...oh, my ring...thanks 
	 myrtle...(now i gotta ditch
	 this thing again!)	
					]]
					messtime=150
					sfx(5)
				end				
			end
			if other.sprite==54 then
				del(zblocks[2],other)
				del(actorlist,other)
				gotboat=true
				message=[[
	who just leaves their boat in
	the middle of a park?
	
	]]
				messtime=150
				swimming=true
				sfx(5)
			end
		end
	end
end

function swordshield()
	if gotsword and gotshield then
	 ddoor:killme()
	 ddoor:killme()
	 knight.text=[[
	 
	 well met, myrtle!
	 ...
	 it's not much of a dungeon...
	 *sob*
	 ]]
	end
end
-->8
-- actor types
-- flags:
-- 0 = read text
-- 1 = coin
-- 2 = gem


npc = actor:new()

function npc:update()
	if self.dz<0 and self.z<self.zfloor then
		self.dz=0.15
	end
	
	self.dz += -.02
	self.z+=self.dz
end

sign = npc:new({sprite=57, 
	text=""})
	
sadgirl = npc:new({sprite=96,
	text=[[
	i've lost my engagement	*ring*! 
	i remember having it in	the 
	north-east part of town! i cant
 get married without it!	
	]]})
	
knight = npc:new({sprite=24,
	text=[[
	
	wo ho! you are not properly
	equipped to enter my dungeon!
	you will need a *sword* and
	*shield*!
	]]})

coin = actor:new({sprite=48})

gem = npc:new{sprite=122}

tree = actor:new{sprite=32,
xw=1.4,yw=1.4,zw=1.8}

sword = npc:new{sprite=26,text=""}
shield= npc:new{sprite=29,text=""}

pipe = actor:new({sprite=143,
xd=0,yd=0,xw=1.2,yw=1.2,zw=1.2})

trophy = actor:new({sprite=75,
xw=1.5,yw=1.5,zw=1.5})

star = actor:new{sprite=116}

chest = npc:new{sprite=53,
text=[[

	wouldn't you like to know what
	is in here? you'll never find
	the *key*!
	
]]}

key = npc:new{sprite=30}

ninja=npc:new{sprite=128}
landlord=npc:new{sprite=102,
text=[[

 those blasted ninjas are
 bothering my tenants! please
 catch them!
]]}

function star:update()
	self.cycle=max(0,self.cycle-1)
	if (self.cycle==0) self.drawme=true
end

grave=actor:new{sprite=52}
skull=npc:new{sprite=117}
ring=npc:new{sprite=50}
boat=npc:new{sprite=54,xw=1.3,zw=1.3}
pillar=actor:new{sprite=55,xw=1,
zw=3}
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900091141415565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90091114115767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d71cc17dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd71cc17d271881722718817203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000000000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000000000755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013000770007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000007667007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000056650075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000005500077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
000101010181010001000000000000000000000000000000010000000000020000000000000000000000000000000000020000000001000000010000000000000000000000000c0000040400000000000000000000000000000000000000000001000000000001000c0c00000000000000000001000000000000040001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000000000000000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000000050500000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000000050500000505050500000000050500000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000505050500000505050500000005050500000505000000050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000505050500000505050500000005050500000505000000050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000505050500000505050500000005050500000505000000050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050500000505050500000505050500000005050500000505000000050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050505050505050505050505050505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
000c00001125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
01 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
