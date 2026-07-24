pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- ramps
-- by mot
--
-- also freds72:
--  -performance optimisations
--  -rectfill lod logic

-- couroutines
function clearco()
 bgco,fgco,drawfn={},{},{}
end
--clearco()

function runbg()
	runco(bgco)
end

function runfg()
	runco(fgco)
	return #fgco~=0
end

function rundraw()
 for fn in all(drawfn) do
  fn()
 end
 drawfn={}
end

function runco(co)
	for c in all(co) do
		if costatus(c)=="dead"then
			del(co,c)
		else
			assert(coresume(c))
		end
	end
end

function doinfg(fn)
	add(fgco,cocreate(fn))
end

function doinbg(fn)
	add(bgco,cocreate(fn))
end

-- queue code to execute in _draw
-- useful for fg coroutines
function dodraw(fn)
 add(drawfn,fn)
end

function wait(ct)
	for i=1,ct do
		yield()
	end
end

-- basic lua literal parser
do
 local src,off,result

 -- current character
 local function char()
  return sub(src,off,off)
 end
 
 -- skip whitespace
 local function skipwhite()
  while char()<=" " do
   off+=1
  end
 end
 
 -- skip single character
 local function skip(c)
  skipwhite()
  if(char()~=c) return
  off+=1
  skipwhite()
  return true
 end
 
 -- is current character in set
 local function is(chars)
  for i=1,#chars do
   if(sub(chars,i,i)==char())return true
  end
 end 
 
 -- get characters while in set
 local function get(chars)
  local token=""
  while is(chars) do
   token..=char() off+=1
  end
  return token
 end

 -- parse number
 local numchars="0123456789-."
 local function parsenum()
  if(not is(numchars))return
  result=tonum(get(numchars))
  return true 
 end
 
 -- parse string
 local function parsestr()
  if(char()~=chr(34))return
  off+=1 -- skip "
  result=""
  while char()~=chr(34) do
   result..=char() off+=1
  end
  off+=1 -- skip "
  return true
 end
 
 -- parse variable
 local varchars="abcdefghijklmnopqrstuvwxyz0123456789_"
 local function parsevar()
  if(is(numchars) or not is(varchars))return false
  result=get(varchars)
  return true 
 end
 
 -- parse literal constant
 local function parseliteral()
  local saveoff=off
  if(not parsevar())return
  if     result=="true"  then result=true
  elseif result=="false" then result=false
  elseif result=="nil"   then result=nil
  else
   off=saveoff -- restore offset
   return
  end
  return true
 end
 
 -- parse table literal
 local function parsetable()
  if(not skip("{"))return
  local obj={}
  while char()~="}" do
	  if parseval() then
	   add(obj,result)
	  else
			 parsevar()
			 local key=result
			 skip("=") 
			 parseval()
			 obj[key]=result
			end			
			skip(",")
		end
		off+=1 -- skip }  
		result=obj
		return true
 end
 
 function parseval()
  skipwhite()
  return parsestr() or parsenum() or parsetable() or parseliteral()
 end 

 function parse(source)
  src,off=source,1
  return parseval() and result
 end
 
 function expandrefs(obj,ref)  
  for i=1,#obj do
   obj[i]=ref[obj[i]]
  end
  return obj
 end
end 

-->8
-- colour palettes

pals=parse[[{
	{4,9,10},
	{5,6,7},
	{0,5,6},
	{1,13,12},
	{3,11,7},
	{2,14,15}
}]]

function applypal(p)
	local bp=pals[1]	-- base palette
	for i=1,#p do
		pal(bp[i],p[i])
	end
end

function defpal()
 pal()
	palt(0,false)
	palt(12,true)
end
-->8
-- routines

function transpose(m)
	return {m[1],m[4],m[7], m[2],m[5],m[8], m[3],m[6],m[9]}
end

function mattimes(m,x,y,z)
	local rx=m[1]*x+m[4]*y+m[7]*z
	local ry=m[2]*x+m[5]*y+m[8]*z
	local rz=m[3]*x+m[6]*y+m[9]*z
	return rx,ry,rz
end

function mattimesplus(m,x,y,z,ox,oy,oz)
	local tx,ty,tz=mattimes(m,x,y,z)
	return tx+ox,ty+oy,tz+oz
end

function matz(m,factor)
	factor=factor or 1
	return m[7]*factor,m[8]*factor,m[9]*factor
end

function loc2world(tu,pi)
	tu/=360 pi/=360
	local st,ct,sp,cp=sin(tu),cos(tu),sin(pi),cos(pi)
	return {ct,0,st, -st*sp,cp,ct*sp, -st*cp,-sp,ct*cp}  -- Column order
end

function world2loc(tu,pi)
	return transpose(loc2world(tu,pi))
end

function rot(x,y,ang)
	ang/=360
	local s,c=sin(ang),cos(ang)
	return x*c-y*s,x*s+y*c
end
		
function clamp(v,mn,mx)
 return max(min(v,mx),mn)
end

function moveto(v,t,d)
 if(abs(v-t)<d)return t
 return v-sgn(v-t)*d
end

function localangle(a)
	return a-360*flr(a/360+0.5)
end

function localangle180(a)
	a=localangle(a)
	if(a<-90)a+=180
	if(a>90)a-=180
	return a
end

function lerp(a,b,f)
	return a*(1-f)+b*f
end

function defaultlessthan(a,b)
	return a<b
end

function insertionsort(array,lessthan,ct)
 lessthan=lessthan or defaultlessthan
	ct=ct or #array
	for i=1,ct do
		local e,j=array[i],i
		while j>1 and lessthan(e,array[j-1]) do
			array[j]=array[j-1]
			j-=1
		end
		array[j]=e
	end
end

-- equivalent to inseritonsort(array,function(a,b) return a.scale<b.scale end,ct)
-- but inlined "lessthan" function makes it slightly faster
function insertionsortsprites(array,ct)
	ct=ct or #array
	for i=1,ct do
		local e,j=array[i],i
		while j>1 and e.scale<array[j-1].scale do
			array[j]=array[j-1]
			j-=1
		end
		array[j]=e
	end
end

-->8
-- track generation and rendering
fov=125
vvolgrad,volsize=64/fov,37-- (from trial and error!)
camheight,camdist=0.25,0		-- first person
loddist,fillscale=120,2
roadwidth=6
hroadwidth=roadwidth/2
--hidedash=true
frame,npctopspeed=0,0

typs=parse[[{
	planks={c=9,s={0,8,64,8},d={6,1},n="planks"},
	gravel={c=13,s={0,24,64,8},d={6,1},n="gravel"},
	road={c=0,s={0,16,64,8},d={6,1},n="road"},
	steel={c=6,s={64,0,64,8},d={6,1},n="steel"},
	grate={c=6,s={64,8,64,8},d={6,1},n="grate"},
	tree1={s={0,32,16,32},d={3,6},n="tree1",dist=5},
	tree2={s={16,32,32,32},d={7,7},n="tree2",dist=7},
	rock={s={48,48,16,16},d={2,2},n="rock",dist=5},
	pole2={c=8,s={56,32,8,8},d={1,10},n="pole2"},
	rocks={s={96,32,16,32},d={3,4.5},n="rocks",dist=5},
	palm={s={0,64,32,32},d={7,7},n="palm",dist=7},	
	cactus={s={112,32,16,32},d={3,6},n="cactus",dist=5},
 pole={c=7,s={48,32,8,8},d={1,10},n="pole"},
 finish={s={64,16,64,8},d={10,2},n="finish"},
 sign={s={64,32,32,24},d={3,2},n="sign",dist=5},
 
	car0  ={s={0, 112,32,16},d={1.7,0.85},n="car"},
	car15 ={s={32,112,32,16},d={1.7,0.85},n="car",flp=true},
	car30 ={s={64,112,32,16},d={1.7,0.85},n="car",flp=true},
	car45 ={s={96,96, 32,16},d={1.7,0.85},n="car",flp=true},
	car90 ={s={64,96, 32,16},d={1.7,0.85},n="car",flp=true},
	car135={s={32,96, 32,16},d={1.7,0.85},n="car",flp=true},
	car180={s={0, 96, 32,16},d={1.7,0.85},n="car"},
	car225={s={32,96, 32,16},d={1.7,0.85},n="car"},
	car270={s={64,96, 32,16},d={1.7,0.85},n="car"},
	car315={s={96,96, 32,16},d={1.7,0.85},n="car"},
	car330={s={64,112,32,16},d={1.7,0.85},n="car"},
	car345={s={32,112,32,16},d={1.7,0.85},n="car"} 
}]]

roadtypes=expandrefs(parse[[{
	"planks",
	"gravel",
	"road",
	"steel",
	"grate"
}]],typs)

bgtypes=expandrefs(parse[[{
		"tree1",
		"tree2",
		"rock",
		"rocks",
		"palm",
 	"cactus"		
}]],typs)

--cardim={1.7,0.85} carn="car"

cartypes=expandrefs(parse[[{
	"car0",
	"car15",
	"car30",
	"car45",
	"car45",
	"car90",
	"car90",
	"car90",
	"car135",
	"car135",
	"car135",
	"car180",
	"car180",
	"car180",
	"car225",
	"car225",
	"car225",
	"car270",
	"car270",
	"car270",
	"car315",
	"car315",
	"car330",
	"car345"
}]],typs)

--tracks={}

mode_mainmenu,
mode_trackselect,
mode_race=1,2,3
sub_practice,
sub_quickrace=1,2
--app_mode=mode_mainmenu
app_submode=sub_practice
app_track=1

--sprites={}
--bgsprites={}
camx,camy,camz=0,-2,0
camtu,campi=0,0

--volumes={}

--path={}

--col={}
colsz,colct=20,20
colofs,cololap=colsz*colct*.5,6/colsz

function _init()
	cartdata("mot_ramps")
	app_track=max(dget(0),1)		
	difficulty=dget(1)
	if(difficulty==0)difficulty=2

	-- default tracks
	for i=1,8 do
		local track=getdeftrack()
		add(track,{ct=10,tu=0,tpi=0,gap=false,nopoles=false,typ=typs.planks,mn=0,mx=2})
	end 

	-- load tracks from cart
	for i=1,#roadtypes do
		roadtypes[i].idx=i
	end
	for i=1,#bgtypes do
		bgtypes[i].idx=i
	end
	loadtracks()
	
	mainmenumode()
end

function mainmenumode()
 clearco()
 frame=0
	sfx(-1,1) sfx(-1,2)
 app_mode=mode_mainmenu
 camx,camy,camz=0,-2.5,0
 camtu,campi=0,0
	menuitem(1)			
	menuitem(2)
	menuitem(3)
	rebuildtrack()
	initcars(true) 
end

function trackselectmode()
	clearco()
	app_mode=mode_trackselect
	camtu=0
	loddist=120
	rebuildtrack()
	initcars()
end

function racemode()
	clearco()
	app_mode=mode_race
	hidedash=true
	loddist=85
	menuitem(3,"quit race",mainmenumode)
	doinfg(function()
		levelintro()
		startsequence()
	 menuitem(1,"respawn",function()respawncar(player)end)
		menuitem(2,"restart race",restartrace)
	end)
end

function restartrace()
	rebuildtrack()
	initcars()
	doinfg(startsequence)			
end

function _draw() 
	frame+=1
	if app_mode==mode_race then
		drawrace()
 elseif app_mode==mode_mainmenu then
 	drawmainmenu()
	elseif app_mode==mode_trackselect then 
		drawtrackselect()
	end

 rundraw()
end

function _update()
	if(runfg())return
	runbg() 

 if app_mode==mode_mainmenu then
  updatemainmenu()
	elseif app_mode==mode_trackselect then
		updatetrackselect()
	elseif app_mode==mode_race then
		updaterace()
	end
end

function drawrace()
 drawtrack()
	if not hidedash then
	 drawcockpit()
		drawdash()
	end
end

function drawtrack()
	local lastsprite=0
	local track=tracks[app_track]

	-- calculate horizon
	local hs,hc=sin(campi/360),cos(campi/360)
	local flipped=false
	if abs(hc)>0.01 then
		local h=hs/hc*fov+64
		if hc>0 then
			rectfill(0,0,128,h,track.colsky)  
			rectfill(0,h+1,128,128,track.colgnd)
		else
			rectfill(0,0,128,h,track.colgnd)  
			rectfill(0,h+1,128,128,track.colsky)
			flipped=true
		end
		line(0,h,128,h)
	else 
		cls(hs>0 and track.colsky or track.colgnd)
	end
	
	-- create camera matrix (world to cam)
	local m=world2loc(camtu,campi)
		
	-- process bounding volumes
	--for sp in all(sprites) do sp.scale=-1 end
	for _,v in pairs(volumes) do
		-- volume position in camera space
		v.cx,v.cy,v.cz=mattimes(m,v.x-camx,v.y-camy,v.z-camz)
		-- potentially intersects view volume?
		v.vis=false
		if v.cz+volsize>0.01 then
			local xylim=v.cz*vvolgrad+v.rad/2
			if abs(v.cx)<xylim and abs(v.cy)<xylim then
				v.vis=true
			end
		end
	end
	
	-- sort bounding volumes by cam space z
	insertionsort(volumes,function(a,b) return a.cz>b.cz end)

	-- add volume sprites
	for _,v in pairs(volumes) do
		if v.vis then
			local lod=max(flr(v.cz/loddist),0)
			local lodscale=1<<lod
			local lodmask=lodscale-1

			local ang=localangle(camtu-v.tu)
			local vsp=v.sprites
			if abs(ang)<=90 then
				for i=#vsp,1,-1 do
					local sp=vsp[i]
					if (sp.lod or 0) & lodmask==0 and processsprite(m,sp,lodscale,lodmask) then
							lastsprite+=1
							sprites[lastsprite]=sp
					end
				end
			else
				for _,sp in pairs(vsp) do
					if (sp.lod or 0) & lodmask==0 and processsprite(m,sp,lodscale,lodmask) then
						lastsprite+=1
						sprites[lastsprite]=sp
					end
				end
			end
		end
	end
	
	-- sort sprites
	insertionsortsprites(sprites,lastsprite)

	-- mark npc car sprites as non-visible
	-- processsprite() will mark them as visible
	-- if appropriate
	for car in all(cars) do
		car.sp.scale=-1
	end

	-- process background sprites
	local i,bglast=1,#bgsprites
	while i<=bglast do
		local s=bgsprites[i]
		if processsprite(m,s,1) then
			i+=1
		else
			bgsprites[i]=bgsprites[bglast]
			bgsprites[bglast]=s
			bglast-=1
		end
	end
	
	for car in all(cars) do
		if(car.sp.scale>0)selectcarframe(car.sp)
	end
	
	insertionsortsprites(bgsprites,bglast)
	
	-- draw visible sprites
	defpal()
	camera(-64,-64)
	local cpi=cos(campi/360)
	local i,j=1,1
		-- localize inner loop values
		local cpi,camtu,fillscale=cpi,camtu,fillscale
		while i<=lastsprite or j<=bglast do
		local s
		if i<=lastsprite and (j>bglast or sprites[i].scale < bgsprites[j].scale) then
			s=sprites[i]
			i+=1
		else
			s=bgsprites[j]
			j+=1
		end

			local typ=s.typ
			local sp,d,c=typ.s,typ.d,typ.c
			local w,h=d[1],d[2]
			if s.isnpc then
				flpy=cos((s.pi-campi)/360)<0
				applypal(s.p)
			else
				flpy=flipped
				if(s.h)h=s.h*cpi
				if(s.w)w=s.w*cos((camtu-s.tu)/360)
			end
			w*=s.scale h*=s.scale*(s.yscale or 1)
			local sx,sy=s.px,s.py
			local x1,x2=flr(sx-w/2),flr(sx+w/2)
			local y1,y2=flr(sy-h/2),flr(sy+h/2)
			if c and s.scale<fillscale then
					rectfill(x1,y1,x2-1,y2-1,c)
			else
				-- rectfill(x1,y1,x2,y2,s.lod or 0)
				sspr(sp[1],sp[2],sp[3],sp[4],x1,y1,x2-x1,y2-y1,typ.flp,flpy and s.idx==0)
				if(s.isnpc)applypal(pals[1])
			end
	end 
	camera()
end

function processsprite(m, s, lodscale) 
	local ix,iy,iz=s.x-camx,s.y-camy,s.z-camz
	local z=ix*m[3]+iy*m[6]+iz*m[9]
	if z>0.01 then
		local x=ix*m[1]+iy*m[4]+iz*m[7]
		local y=ix*m[2]+iy*m[5]+iz*m[8]
		local xylim=z*vvolgrad+3
		if abs(x)<xylim and abs(y)<xylim then
			-- won't change overnight!
			local w=125/z
			s.px,s.py,s.scale=x*w,y*w,w
			if(s.idx>0)s.yscale=lodscale   
			return true
		end
	end
end

function selectcarframe(sp)

	local ctu=camtu
	if(cos(campi-sp.pi)<0)ctu+=180

	-- angle relative to camera
	local tu=(sp.tu-camtu)/360
	
	-- adjust based on position
	tu-=sp.px/125*0.125
	
	-- select corresponding frame
	local fr=flr((tu-flr(tu))*#cartypes+0.5)
	fr=fr%#cartypes+1
	sp.typ=cartypes[fr]
end

function rebuildtrack()

--	printh("rebuilding track")

	-- calculate pitch delta
	local pi=0
	local track=tracks[app_track]
	for t in all(track) do
		t.spi=pi
		t.pi=localangle(t.tpi-pi)
		
		pi=t.tpi
	end
	
	-- allocate 2d collision array
	col={}
	for z=1,colct do
		local c={}
		for x=1,colct do
			add(c,{})
		end
		add(col,c)
	end 

	-- calculate segment 3d positions
	sprites={}
	bgsprites={}
	path={}
	prg=0
	local x,y,z=0,0,0
	local xd,yd,zd=0,0,1
	local tu
	tu,pi,idx=0,0,1
	local ct=1
	local col0={
		x=x,y=y,z=z,
		xd=xd,yd=yd,zd=zd,
		tu=tu,pi=pi,
		gap=false		
	}
	local roadside={}
	volumes={}
	for t in all(track) do
		local v={min={x=x,y=y,z=z}, max={x=x,y=y,z=z}, tu=tu+t.tu/2, sprites={}}
		add(volumes, v)
		local tracklod,polelod=0,0
		for s=1,t.ct do

			-- path
			if not col0.gap then
				col0.prg=prg
				prg+=1
			end
			col0.t=t
			col0.d=#path
			add(path,col0)
		
			-- calculate next segment pos and dir
			local nx,ny,nz=x+xd,y+yd,z+zd
			if(ny>0)ny=0
			local ntu,npi=tu+t.tu/t.ct,pi+t.pi/t.ct
			local l2w=loc2world(ntu,npi)
			local nxd,nyd,nzd=matz(l2w)
			local col1={
				x=nx,y=ny,z=nz,
				xd=nxd,yd=nyd,zd=nzd,
				tu=ntu,pi=npi,
				gap=t.gap
			}
			if not t.gap then
			
				-- visible sprite
				local mx,my,mz=x+xd/2,y+yd/2,z+zd/2
				addvolumesprite(v, {x=mx,y=my,z=mz,idx=idx,typ=t.typ,lod=tracklod})
				tracklod+=1
				
				-- collidable
				local c={
					x=x+xd/2,y=y+yd/2,z=z+zd/2,
					col0=col0,col1=col1,
					debug_seg=s
				}
				local x1,x2,z1,z2=getcolrange(x+xd/2,z+zd/2,6)
				for z=z1,z2 do
					for x=x1,x2 do
						add(col[x][z],c)
					end
				end                
			
				-- poles
				ct+=1
				if not t.nopoles and y<-5 and ct%8==0 and abs(localangle((pi+npi)/2))<80 then
					local h=y+.5
					addvolumesprite(v, {x=mx+zd*2,y=h/2,z=mz-xd*2,idx=0,typ=typs.pole,h=h,lod=polelod})
					addvolumesprite(v, {x=mx-zd*2,y=h/2,z=mz+xd*2,idx=0,typ=typs.pole,h=h,lod=polelod})
					polelod+=1
				end
				
				-- signs
				if y>-0.2 and abs(t.tu/t.ct)>3 and ct%6==0 then
					local sp={
						x=mx-zd*sgn(t.tu)*6,
						y=-typs.sign.d[1]/2,
						z=mz+xd*sgn(t.tu)*6,
						idx=0,
						typ=typs.sign,
						w=3,
						tu=tu,
						scale=-1}
					if(t.tu<0)sp.tu+=180
					add(roadside,sp)
				end
			end
			
			-- move to start of next seg
			x,y,z=nx,ny,nz
			tu,pi=ntu,npi
			xd,yd,zd=nxd,nyd,nzd
			col0=col1
		end
		
		v.rad=0
		for coord,val in pairs(v.min) do
			v[coord]=(v.min[coord]+v.max[coord])/2
			v.rad=max(v.rad, v.max[coord]-v.min[coord])
		end
		
		idx+=1
	end

	-- road-side objects
	for sp in all(roadside) do
		if (not sp.typ.dist or not isneartrack(sp.x,sp.y,sp.z,sp.typ.dist)) add(bgsprites,sp)
	end
	
	-- random objects
	local saveseed=rnd(30000)
	srand(track.seed)
	for obj in all(track.obj) do
		local nextseed=rnd(30000)
		makerandomobj(obj.typ,obj.ct,track.objrng,track.objxofs,track.objzofs)
		srand(nextseed)	 
	end
	srand(saveseed)
	
	-- finish line
	add(bgsprites,{x= 5.5,y=-2.5,z=0,idx=0,typ=typs.pole2,h=5,scale=-1})
	add(bgsprites,{x=-5.5,y=-2.5,z=0,idx=0,typ=typs.pole2,h=5,scale=-1})
	add(bgsprites,{x= 0,y=-4,z=0,idx=0,typ=typs.finish,w=10,tu=0,scale=-1})	
	
	for sp in all(bgsprites) do addsprite(sp) end
	
	-- track ai data
	inittrackaidata()
end

function volidx(coord)
	return flr(coord/volsize)*volsize
end

function addvolumesprite(v, sp)  
	-- add to sprites array
	addsprite(sp)

	for coord,val in pairs(v.min) do
		v.min[coord]=min(v.min[coord], sp[coord]-3)
		v.max[coord]=max(v.max[coord], sp[coord]+3)
	end
	add(v.sprites,sp)
end

function addsprite(sp)
	sp.scale=-1
	add(sprites,sp)
end

function getdeftrack(i)
	return {
		seed=rnd(30000),
		objrng=150,
		objxofs=0,
		objzofs=0,
		colsky=12,
		colgnd=3,
		mn=0.35,
		mx=0.55,
		obj={
			{typ=typs.tree1,ct=50},
			{typ=typs.tree2,ct=15},
			{typ=typs.rock,ct=10}
		}
	}
end

function getcolrange(x,z,radius)
	local x1,x2=getcolidx(x-radius),getcolidx(x+radius)
	local z1,z2=getcolidx(z-radius),getcolidx(z+radius)
	return x1,x2,z1,z2
end

function getcolidx(v)
	local i=flr((v+colofs)/colsz)
	return min(max(i,1),colct)
end 

function makerandomobj(typ,ct,rng,xofs,zofs)
	for i=1,ct do
	
		-- search for position not overlapping track
		local fnd=false
		while not fnd do
			fnd=fnd or makegndobj(typ,rnd(rng)-rng/2+xofs,rnd(rng)-rng/2+zofs)
		end    	 
	end
end

function makegndobj(typ,x,z)
	y=-typ.d[2]/2
	if(typ.dist and isneartrack(x,y,z,typ.dist))return nil
	local sp={x=x,y=y,z=z,idx=0,typ=typ,scale=-1}
	add(bgsprites,sp)
	return sp
end

function isneartrack(x,y,z,lim)
	lim/=10
	local lim2=lim*lim	
	for s in all(sprites) do
		if s.idx>0 then  -- is track?
			local dx,dy,dz=x-s.x,y-s.y,z-s.z
			dx/=10 dy/=10 dz/=20
			local d2=dx*dx+dy*dy+dz*dz
			if(d2<lim2)return true
		end
	end
	return false
end	  

cpcols=parse[[{5,6,7,6,5,0}]]
barcols=parse[[{7,7,6,6,13,5}]]
cpl,cpr,cph,cprad=8,120,22,32

function cpcorner(x,y)
 for i=1,#cpcols do
  circfill(x,y,cprad-i+1,cpcols[i])
 end
end

--wheelcols={0,0,0,5,5,6,5,5}
wheelcols=parse[[{6,6,5,5,0,0,0,0}]]

function drawcockpit()

 --ensure wheels don't turn by 
 --more than 4 units per rendered
 --frame. otherwise they can appear
 --to freeze/turn backwards.
 player.wheelturn=min(player.wheelturn,player.prevwheelturn+4)
 player.prevwheelturn=player.wheelturn

	--wheels
 pal()
 palt(0,false)
 palt(1,true)
	local wt,y=flr(player.wheelturn),100-player.wheelspringssmoothed
	for i=0,7 do
	 pal(8+i,wheelcols[(wt+i)%#wheelcols+1])
	end	 	
	spr(132,0,  y,2,4)
	spr(132,112,y,2,4,true)
	pal()

 --struts
	for x=-5,5 do
	 local c=barcols[abs(x)+1]
	 line (20+x,128-cph,5+x,0,c)
		line (108+x,128-cph,122+x,0,c)
	end

 -- dashboard
 cpcorner(cpl,128-cph+cprad)
 cpcorner(cpr,128-cph+cprad)
 for i=1,#cpcols do
  rectfill(cpl,127-cph+i,cpr,128,cpcols[i])
 end 
 
 -- top
 rectfill(0,0,128,6,0)
 rectfill(0,7,128,9,13)
 rectfill(0,8,128,8,7)
end

function drawdash()	
	defpal()
	
	-- markings
	for m=0,100,10 do
	 local x=speeddashy(m)
	 if(m/50)%1==0 then
	  print(m*2,x-4,113,7)	 
	 	rectfill(x,119,x,121,7)
	 else
	 	rectfill(x,120,x,121,5)
		end	 
	end
	
	-- bar
	local speed=flr(player.speed*100)
	local y=speeddashy(speed)
	rectfill(speeddashy(0),122,y,126,player.speed>=0 and 9 or 8)
 
 -- max/min speeds
	if player.seg then
		speed=flr(player.seg.mn*100)
		if speed>0 then
			y=speeddashy(speed)
			rect(y,121,y,127,11)
--		print(abs(speed),100,y-3,11)
  end
		speed=flr(player.seg.mx*100)
  if speed<100 then  
			y=speeddashy(speed)
			rect(y,121,y,127,8)
--		print(abs(speed),100,y-3,8)
		end
	end	

		-- lap and position
		print("lap",1,1,3)
		print(player.lap,17,1,11)
		
	 palt(0,true)
		for i=1,#leaderboard do
	  local l,s=leaderboard[i],2
	  if l==player then
	   s=3
	   pal(7,6+flr(frame/6)%2)
		  print("pos",26,1,3)
		  print(i,42,1,11)
	  else
		  applypal(l.sp.p)
		 end
		 spr(s,(#leaderboard-i)*10+52,1)
 	 defpal()
		end
	 
 -- respawn warning	
	if player.offroad>0 then
		local t=(offroadtimeout-player.offroad)/30
		if t<=3 and (t-flr(t))*2&3~=0 then
			local txt="respawn in "
			print(txt,34,32,5)
			print(txt,34,31,7)
			spr(170+flr(t)*2,72,21,2,2)
		end 	 
	end
end

function speeddashy(speed)
 return abs(flr(speed))+16
	--return 110-abs(flr(speed))
end

function startsequence()
	hidedash=false
	
-- if(true)return
	
 camx,camy,camz=0,-1-camheight,-camdist
 camtu,campi=0,0
	for t=2,0,-1 do
	 sfx(1)
	 for frame=0,29 do
	  if (frame%30)<15 then
		  dodraw(function()
		   defpal()
			  spr(170+t*2,56,32,2,2)
		  end)
	  end
		 getinputy()
	  enginenoise()
	  yield()
	 end
	end
	
	sfx(2)
	doinbg(function()
	 for frame=0,47 do
	  if (frame%16)<8 then
		  dodraw(function()
		   defpal()
		   spr(140,48,32,4,2)
		  end)
	  end
	  yield()
	 end
	end) 
   end

npcnames=parse[[{ 
	"sam sloth",
 "slow joe",
 "jimmy",
 "speedy sal",
 "green flash",
 "pink dust"   
}]]

placenames=parse[[{
 "1st","2nd","3rd"
}]]

function racefinishedsequence()
	for frame=0,149 do
	 if (frame%30)<15 then
	  dodraw(function()
	   defpal()
	   print("race finished",38,29,7)
	  end)
	 end
	 yield()
	end
	
	-- complete podium
	for car in all(leaderboard) do
	 if(not car.finished) add(podium,car)
	end
	
	doinfg(function()
		wait(10) frame=0
		while frame<30 or not (btn(—) or btn(Ž)) do
		 dodraw(function()
		  defpal()
		  if app_submode==sub_quickrace then
			  rectfill(24,16,103,111,0)
			  rect(24,16,103,111,6)
			  for i=1,#podium do
			   local car=podium[i]
			   local place=i<=3 and placenames[i] or (i.."th")
			   local col,name
			   if car==player then
	      col,name=7,"player"
						 print(place.." place!",44,20,7)      
			   else
			    col,name=car.sp.p[2],npcnames[car.idx]
			   end
			   local y=i*8+28
			   print(place,34,y,7)
			   print(name,50,y,col)
			  end
 		  print("press — or Ž",37,103,7)
 		 else
 		  print("press — or Ž",37,29,7)
		  end
		 end)
		 yield()
  end
  yield()
  mainmenumode()
	end)
end
	   
-->8
-- gameplay

--npcs={}
smoothpitchcollide,
smoothpitchaerial,
accel,
aiaccel,
brake,
aibrake=
0.5,
0.075,
0.005,
0.0048,
0.01,
0.01
laps,grav,gndfric,roadfric=5,0.008,0.988,0.995
aijumprecovery,cornercut,offroadtimeout=50,50,150
--cars,leaderboard,podium={},{},{}
carwidth,carlength=0.85,2
npcsteer,npcsteerlight,npcsteeraccel,npclookahead=0.06,0.03,0.0065,10
difnames=parse[[{" easy ","medium"," hard "}]]
difmn,difmx=parse[[{0,0.15,0.6}]],parse[[{0.3,0.7,1}]]
revs,inputy=0,0			-- for engine noise

function initcars(ismenu)
	local track=tracks[app_track]
	
	-- player
	if(not ismenu)player=makeplayer()
	
	-- difficulty
	vmn,vmx=lerp(track.mn,track.mx,difmn[difficulty]),lerp(track.mn,track.mx,difmx[difficulty])
	
	npcs={}
	if ismenu or app_submode~=sub_practice then
		-- npcs
		local ct=6
		local d=1
		for i=1,ct do
			for s=1,5 do
				d+=1
				while path[d].gap do
					d+=1
				end
			end
			local npc={
			 idx=i,
				world={					-- world space 
					x=0,y=0,z=0,		-- position
					xd=0,yd=0,zd=0,		-- velocity
					tu=0,pi=0 			-- orientation
				},
				track = {
					-- position
					x=(i%2-0.5)*1.5,y=-0.95,z=0,
					xd=0,yd=0,zd=0,		-- velocity
					tu=0,pi=0,			-- orientation
					valid=true
				},						
				lap=1,
				d=d,
				finished=false,
				basetv=clamp((i-1)/(ct-1)
				+rnd(0.8)-0.4
				,-0.1,1.1),
				v=0,
				sp={
					idx=0,
					isnpc=true,
					p=pals[(i-1)%#pals+1]
				},
				recovery=0	  
			}
			randomnpcparams(npc)
			updatenpcsp(npc)
			add(npcs,npc)
			add(bgsprites,npc.sp)
		end
 end	
	npctopspeed=0
	
	cars,leaderboard,podium={player},{player},{}
	for npc in all(npcs) do
	 add(cars,npc)
	 add(leaderboard,npc)
	end
	sortleaderboard()
end

function randomnpcparams(npc)
 npc.lx,npc.tv=rnd(.4)+.3,lerp(vmn,vmx,clamp(npc.basetv+rnd(0.6)-0.3,0,1))
end

function inittrackaidata()
	-- calculate minimum and maximum speeds for each segment
	
	-- copy from corners onto segments
	local t=nil
	for seg in all(path) do
		if seg.t~=t then
			t=seg.t
			seg.mn,seg.mx=t.mn,t.mx
		else
			seg.mn,seg.mx=0,2
		end
	end

	local s=0.5 				 -- timestep
	local fs=roadfric^s

	-- walk backwards to smooth out
	-- max based on available braking
	for it=1,2 do
		local i,v=#path+1,path[1].mx
		local prvi=i
		i-=v*s
		while i>=1 do
			local seg=path[flr(i)]
			local a,b=pitchaccel(seg.pi)
			local pv=(v-b*s)/fs
			v=min(2,pv)
			if flr(prvi)~=flr(i) and seg.mx<v then
				v=seg.mx i=flr(i)
			else
				seg.mx=v
			end
			prvi=i	i-=v*s
		end
	end

	-- likewise smooth min speed 
	-- based on available acceleration
	for it=1,2 do
		local i,v=#path+1,path[1].mn
		local prvi=i
		i-=max(v,0.1)*s
		while i>=1 do
			local seg=path[flr(i)]
			local a,b=pitchaccel(seg.pi)
			local pv=(v-a*s)/fs
			v=max(0,pv)
			if flr(prvi)~=flr(i) and seg.mn>v then
				v=seg.mn i=flr(i)
			else
				seg.mn=v
			end
			prvi=i i-=max(v,0.1)*s
		end
	end
end

function makeplayer()
	local player={
		world={					-- world space 
			x=0,y=-1,z=0,		-- position
			xd=0,yd=0,zd=0,		-- velocity
			tu=0,pi=0 			-- orientation
		},
		track={					-- track space 
			x=0,y=0,z=0,		-- position
			xd=0,yd=0,zd=0,		-- velocity
			valid=true
		},
		sp={
			idx=0,
			isnpc=true,
			p=pals[4]
		},

		lap=1,
		d=0,
		v=0,								-- (copy of track.zd)
		speed=0,
		finished=false,

		inpx=0,
		prg=1,		-- "progress". index into "path" array
		offroad=0,
		
		wheelturn=0,
		prevwheelturn=0,
		wheelspin=0,
		wheelsprings=12,					-- y offset (upwards) in pixels
		wheelspringssmoothed=12
	}
	updatecarsp(player)
	add(bgsprites,player.sp)
	return player
end

function updaterace()
 getinputy()
	moveplayer(player)	
	movenpcs()
	docarcollisions()
	positioncam(player.world)
	updateracerules()	
	enginenoise()	
end

function enginenoise()
	-- engine noise
	sfx(8,1,abs(revs)*28+3)
	sfx(9,2,abs(revs)*28+3.5)
end

function compared(a,b)
 return a.d<b.d
end

function moveplayer(p)
	local w=p.world			-- world space position

	-- default wheel animation
	p.wheelspin*=0.96

	-- move
	w.yd+=grav
	w.x+=w.xd
	w.y+=w.yd
	w.z+=w.zd

	-- collisions
	local collision=nil
	local x1,x2,z1,z2=getcolrange(w.x,w.z,1.5)
	for z=z1,z2 do
		for x=x1,x2 do
			for c in all(col[x][z]) do
				collision=collision or collide(w,c)
			end
		end
	end

	local above,contact,collided,spi,impulse=false,false,false,nil,0
	if collision then
		above,contact,collided,spi,impulse=collision.above,collision.contact,collision.collided,collision.pi,collision.impulse

		-- player track relative position and distance
		local pt,st=p.track,collision.track
		pt.x=st.x pt.y=st.y pt.z=st.z
		pt.xd=st.xd pt.yd=st.yd pt.zd=st.zd
		pt.valid=true
		p.v=pt.zd
		
		p.d=collision.seg.d+st.z
	else
	 player.track.valid=false
	end

	-- ground collision
	local friction=roadfric
	if not contact and w.y>-1.3 then
		contact=true
		spi=0
		friction=gndfric
		if w.y>-1 then
			impulse=max(w.yd,0)
			w.y=-1 w.yd=min(w.yd,0) 
			w.pi=smoothpitch(w.pi,0,smoothpitchcollide)
			collided=true
		end
	end  		
	
	-- get player relative velocity
	local l2w=loc2world(w.tu,spi or w.pi)
	local w2l=transpose(l2w)
	local xd,yd,zd=mattimes(w2l,w.xd,w.yd,w.zd)
	
	-- store speed for dashboard
	p.speed=zd

	-- car control
	local upsidedown=false
	if contact then

		-- right side up?
		if spi and cos((spi-w.pi)/360)>0 then
	
			-- sliding
			if abs(xd)>0.05 then
				xd*=0.92
			else
				xd=0
			end
	
			-- accelerate/brake
			local a=accel
			if(inputy~=sgn(zd))a=brake
			zd+=inputy*a

			-- friction
			xd*=friction
			zd*=friction
			
			p.wheelspin=zd*16
			revs=zd
		
		else
			-- upside down
			-- friction
			xd*=0.85
			zd*=0.85
			upsidedown=true
		end
	
		-- back to world rel
		w.xd,w.yd,w.zd=mattimes(l2w,xd,yd,zd)

		-- steering
		local s=0
		if(btn(‹))s-=1
		if(btn(‘))s+=1
		local srate=0.075--0.1
		if s==0 then
			srate=0.05--0.075
		elseif sgn(s)~=sgn(p.inpx) then
			srate=0.2
		end

		-- assist
		if collision then
			local a=localangle180(collision.seg.tu-w.tu)
			local as=clamp(a*0.015,-.1,.1)
			s=clamp(s+as,-1,1)
		end

		p.inpx=moveto(p.inpx,s,srate)  
		w.tu+=p.inpx*zd*7.5*cos(w.pi/360)
	end

	if not collided then 
		-- adjust pitch to match direction
		local hx,hz=rot(w.xd,w.zd,-w.tu)
		if abs(hz)>0.01 then
			local tpi=atan2(hz,w.yd)*-360
			tpi=w.pi+localangle180(tpi-w.pi)
			print("adj tpi="..tpi)
			w.pi=smoothpitch(w.pi,tpi,smoothpitchaerial)
		end
	end
	
	-- progress and respawn logic
	local isoffroad=true

	-- is player above the road?
	if collision and collision.above and collision.seg.prg then
		
		-- must be above a nearby segment to the previous one
		-- (otherwise car is cutting corners, and should be 
		-- treated as if off road)
		local relprg,rellap=relprogress(collision.seg.prg,p.prg)
		if abs(relprg)<cornercut then
			p.prg=collision.seg.prg
			p.lap+=rellap			
			p.seg=collision.seg
			p.offroad=0
			isoffroad=false
		end
	end

	-- respawn logic
	if isoffroad then
		-- start off road counter once car is in contact with ground
		if contact or p.offroad>0 then
			p.offroad+=1
			if(p.offroad>offroadtimeout)respawncar(p)
		end
	end
	
	-- sprite
	updatecarsp(player)	
	
	-- animate wheels
	p.wheelturn+=p.wheelspin
	if(impulse>0)impulse+=0.05
	p.wheelsprings=clamp(max(p.wheelsprings-5,impulse*200),0,25)
	p.wheelspringssmoothed=lerp(p.wheelspringssmoothed,p.wheelsprings,0.15)
end

function getinputy()

 -- get input
	inputy=0
	if(btn(Ž))inputy+=1  
	if(btn(—))inputy-=1
	
	-- adjust revs
	revs=min(revs*0.95+inputy*0.12,1)	
end

function positioncam(p,yoff,zoff)
 yoff=yoff or -camheight
 zoff=zoff or -camdist
	local m=loc2world(p.tu,p.pi)
	local x,y,z=mattimes(m,0,yoff,zoff)
	camx,camy,camz=p.x+x,p.y+y,p.z+z
	camtu,campi=p.tu,p.pi
end

function smoothpitch(pi,tpi,factor)
	return pi+localangle180(tpi-pi)*factor
end

function collide(p,c)

	-- check if car in vicinity of segment.
	-- return nil if not.

	-- distance to collidable (squared)
	local dx,dy,dz=p.x-c.x,p.y-c.y,p.z-c.z
	local d2=dx*dx+dy*dy+dz*dz
	if(d2>36)return nil
	
	-- must be infront of front plane
	if(getcolplaneh(p,c.col0)<0)return nil
	
	-- must be behind end plane
	if(getcolplaneh(p,c.col1)>0)return nil

	-- player positon rel to segment
	local s=c.col0
	local l2w=loc2world(s.tu,s.pi)
	local w2l=transpose(l2w)
	local x,y,z=mattimes(w2l,p.x-s.x,p.y-s.y,p.z-s.z)
	local xd,yd,zd=mattimes(w2l,p.xd,p.yd,p.zd)

	-- test for collisions
	local above,contact,collided,pi,impulse=false,false,false,nil,0

	-- above track?
	above=y<0

	if abs(x)<3.1 then

		-- in contact with track?
		contact=above and y>-1.3

		-- collided with track?
		if y>-1 and y<0 then
			impulse=max(yd,0)
			y=-1 yd=min(yd,0)
			collided=true
		end
		if y>0 and y<1 then
			y=1 yd=max(yd,0)
			collided=true
		end

		-- calculate effective track pitch
		if collided or contact then
			local tu=s.tu
			--local tu=lerp(s.tu,c.col1.tu,z)
			pi=lerp(s.pi,c.col1.pi,z)
			local nr180=flr(pi/180+0.5)*180
			local of180=pi-nr180
			of180*=cos((tu-p.tu)/360)
			pi=nr180+of180

			-- align car to track
			--if collided then
				p.pi=smoothpitch(p.pi,pi,smoothpitchcollide)
			--end
		end
	end
	
	if collided then
		-- recalculate world position
		p.x,p.y,p.z=mattimesplus(l2w, x,y,z, s.x,s.y,s.z)
		p.xd,p.yd,p.zd=mattimes(l2w,xd,yd,zd)
	end
	
	return {
		seg=s,
		above=above,
		contact=contact,
		collided=collided,
		impulse=impulse,
		pi=pi,
		track={
			x=x,y=y,z=z,
			xd=xd,yd=yd,zd=zd
		}
	} 
end

function getcolplaneh(p,c)
	local x,y,z=p.x-c.x,p.y-c.y,p.z-c.z
	return x*c.xd+y*c.yd+z*c.zd
end

function calcnpcworldpos(car)
	local w=car.world
	local tr=car.track
	
	-- find segment
	local idx=(flr(car.d)-1)%#path+1
	local s=path[idx]
	local s2=path[idx%#path+1]
	
	-- direction 
	w.tu=lerp(s.tu,s2.tu,tr.z)+tr.tu
	w.pi=lerp(s.pi,s2.pi,tr.z)+tr.pi
	
	-- world space position 
	local l2w=loc2world(s.tu,s.pi)
	local x,y,z=tr.x,tr.y,tr.z
	w.x,w.y,w.z=mattimesplus(l2w,x,y,z,s.x,s.y,s.z)
end

function updatenpcsp(npc)
	calcnpcworldpos(npc)
	updatecarsp(npc)
end

function updatecarsp(car)
 -- copy car world position to sprite
	local sp,w=car.sp,car.world
	sp.x,sp.y,sp.z=w.x,w.y,w.z
	sp.tu,sp.pi=w.tu,w.pi
end

function movenpcs()
	for npc in all(npcs) do

		-- find segment
		local idx=flr(npc.d)%#path+1
		local s=path[idx]

  -- random steering/speed changes
  if(rnd(1000)<=1)randomnpcparams(npc)

		-- steer around other cars
		local xlimit=hroadwidth+carwidth/2-0.1
		local xpts={-xlimit,xlimit}

		local adjv=npc.v+0.05
  for car in all(cars) do
   if car~=npc then
    if adjv>car.v then
	    local card=reld(car.d,npc.d)
	    if card>0 and card-0.75<60*(adjv-car.v) then
	     -- should catch up to car in next 60s
	 			 add(xpts,car.track.x)    
	    end
	   end
   end
  end
		
		-- sort car x positions
		insertionsort(xpts)

		-- find best gap to steer towards
		local npcx,bx,px=npc.track.x,nil,nil
		for xi=1,#xpts-1 do
		 local l,r=xpts[xi]+carwidth,xpts[xi+1]-carwidth
		 
		 -- must be room for a car
		 if r>l then
		  local x=clamp(npc.track.x,l,r)
		  if not bx or abs(npcx-x)<abs(npcx-bx) then
		   bx=x
		   px=lerp(l,r,npc.lx)
		  end		
		 end
		end
		bx,px=bx or npcx,px or npcx
		
		-- steer towards target x
		local tx,steerspeed=bx,npcsteer
		if (npcx==bx) tx,steerspeed=px,npcsteerlight
		local txd=clamp(tx-npc.track.x,-steerspeed,steerspeed)
		npc.track.xd=moveto(npc.track.xd,txd,npcsteeraccel)
		
--		local prvx=npc.track.x
--		if bx and not s.t.gap then
--		 if npcx~=bx then
--				npc.track.x=moveto(npcx,bx,clamp(npc.v,0,npcsteer))
--			else
--			 npc.track.x=moveto(npcx,px,clamp(npc.v,0,npcsteerlight))
--			end
--		end
--		npc.track.xd=npc.track.x-prvx
		
		-- calculate target velocity
		local tv=npc.tv
		if npc.recovery>0 then
			-- "recovering" from jump
			-- acceleration is banned
			npc.recovery-=1
			tv=min(tv,npc.v)
		elseif not bx then
		 -- road is blocked. brake!
		 tv=0   
		end

		-- clamp preferred speed to min-max range	 
		tv=min(tv,s.mx)
		tv/=roadfric
		
		local prvv=npc.v
		
		-- accel/brake to target speed    
		if not s.t.gap then
			local a,b=pitchaccel(s.pi)  
			local adj=clamp(tv-npc.v,b,a)
			npc.v+=adj
			npc.v*=roadfric
		else
			npc.v-=sin(s.pi/360)*grav
			npc.recovery=aijumprecovery
		end
		
		-- don't drop below seg minimum speed
		-- or fixed min speed, once that 
		-- velocity has been reached
		npc.v=max(max(npc.v,s.mn),min(prvv,0.15))
		
		npc.track.zd=npc.v
		
		-- move forward
		npc.d+=npc.v
		if npc.d>=#path then
		 npc.d-=#path
		 npc.lap+=1
		 if npc.lap>laps and not npc.finished then
		  npc.finished=true
		  add(podium,npc)
		 end
		end

		-- update track space position
		if not s.t.gap then
			npc.track.x=clamp(
				npc.track.x+npc.track.xd,
				-xlimit,
				 xlimit)
		end
		
		npc.track.z=npc.d-flr(npc.d)

		-- update sprite
		updatenpcsp(npc)

  npctopspeed=max(npctopspeed,npc.v)
	end
end

function pitchaccel(pi,v)
	local adj=sin(pi/360)*grav
	return aiaccel-adj,-aibrake-adj
end

function respawncar(p)
	-- find corresponding segment
	local i=1
	while i<#path and (not path[i].prg or path[i].prg<p.prg) do
		i+=1
	end
	
	-- search backwards for decent starting point 
	while path[i].gap or path[i].mn>0 do
		i=(i-2)%#path+1
	end
	
	-- take car back a little farther
	for ct=1,10 do
		local j=(i-2)%#path+1
		if not path[j].gap and path[j].mn==0 then
			i=j
		end
	end

	-- reposition car 
	local s=path[i]
	local l2w=loc2world(s.tu,s.pi)
	local w=p.world
	w.x,w.y,w.z=mattimesplus(l2w,0,-1,0,s.x,s.y,s.z)
	w.tu,w.pi=s.tu,s.pi

	-- starting velocity 
	local v=gettargetvel(0.2,s.mn,s.mx,0.1)
	w.xd,w.yd,w.zd=matz(l2w,v)
	
	-- progress tracking state
	p.prg=s.prg
	p.offroad=0
end

function relprogress(prg1,prg2)
	local res=prg1-prg2
	local lap=-flr(res/prg+0.5)
	res+=lap*prg
	return res,lap
end

function reld(d1,d2) 
 return (d1-d2+#path/2)%#path-#path/2
end

function gettargetvel(v,mn,mx,buf)
	if (mx-mn)<2*buf then
		return (mx+mn)/2
	else
		return clamp(v,mn+buf,mx-buf)
	end
end

elastic=0.5

function docarcollisions()
	for i=1,#cars-1 do
		local a=cars[i]
		local at=a.track
		for j=i+1,#cars do
			local b=cars[j]
			local bt=b.track
			-- check for intersection
			if at.valid and bt.valid and abs(at.x-bt.x)<carwidth and abs(a.d-b.d)<carlength and abs(at.y-bt.y)<1 then
				local collided=false

				-- x collision?		
				if (sgn(at.x-bt.x)==-sgn(at.xd-bt.xd)) then
					local xd=(at.xd+bt.xd)/2
					local vel=at.xd-xd
					at.xd=xd-vel*elastic
					bt.xd=xd+vel*elastic
					collided=true
				end
				-- z collision
				if (sgn(a.d-b.d)==-sgn(at.zd-bt.zd)) then
					local zd=(at.zd+bt.zd)/2
					local vel=at.zd-zd
					at.zd=zd-vel*elastic
					bt.zd=zd+vel*elastic
					a.v=at.zd
					b.v=bt.zd
					collided=true
				end

				if collided then
					if a==player or b==player then

						-- recalculate player world space velocity
						local w=player.world
						local tr=player.track
						local idx=(flr(player.d)-1)%#path+1
						local s=path[idx]
						local l2w=loc2world(s.tu,s.pi)
						w.xd,w.yd,w.zd=mattimes(l2w,tr.xd,tr.yd,tr.zd)

						sfx(0,0)
					end
				end
			end
 	end
	end
end

function sortleaderboard()
	insertionsort(leaderboard,
	 function(a,b)
	  return a.lap>b.lap or (a.lap==b.lap and a.d>b.d)
	 end)
end
   
function updateracerules()
	sortleaderboard()
   
 -- detect race finished
 if player.lap>laps and not player.finished then
		player.finished=true
		add(podium,player)
		doinbg(racefinishedsequence)
 end
end
-->8
-- menus
mainmenu_y,mainmenu_animy,mainmenu_t=0,0
   
function menucar(f,x,y,scale)
	local typ=cartypes[flr(f)%#cartypes+1]
	local s=typ.s
	sspr(s[1],s[2],s[3],s[4],x-16*scale,y-8*scale,32*scale,16*scale,typ.flp)
end 
   
function drawmainmenu()
	drawtrack()
	rectfill(35,57,93,100,0)
	rect(35,57,93,100,6)
 spr(236,48,6,4,2)
	print("-mot",72,25,5)
	print("-mot",72,24,7)
	print("practice",48,64,mainmenu_y==0 and 7 or 6)
	print("race",56,76,mainmenu_y==1 and 7 or 6)
	print("‹ "..difnames[difficulty].." ‘",40,88,mainmenu_y==2 and 7 or 6)
	print("— or Ž to select",28,115,7)
   
	for x=-1,1 do
	 applypal(pals[5+x]) 
	 menucar(12-x*3,64+x*40,42,1)
	end
	applypal(pals[1])
	menucar(-frame*0.5,23, mainmenu_animy*12+66,0.5)
	menucar( frame*0.5,105,mainmenu_animy*12+66,0.5) 
end
   
function updatemainmenu()
 -- animate npc cars
	movenpcs()

 -- camera animation
	camtu+=0.14
	local camshot=flr(frame/1000)
	camshot*=camshot
	local d=abs(sin(camshot*0.7)*100)
	campi=abs(sin(camshot*0.37)*20)
 orbitcam(d,1)	
	
	if(btnp(ƒ)and mainmenu_y<2)mainmenu_y+=1
	if(btnp(”)and mainmenu_y>0)mainmenu_y-=1
	mainmenu_animy=moveto(mainmenu_animy,mainmenu_y,1/6)

	if mainmenu_y==2 then
		if(btnp(‹)and difficulty>1)difficulty-=1
		if(btnp(‘)and difficulty<3)difficulty+=1
		dset(1,difficulty)
 end 	
	if btnp(—) or btnp(Ž) then
	 if mainmenu_y==0 then
	  app_submode=sub_practice
	  trackselectmode()
	 elseif mainmenu_y==1 then 
		 app_submode=sub_quickrace
		 trackselectmode()
	 end
	end
end
   
function drawtrackselect()
 drawtrack()
	print("select track",38,16,7)
	print("‹ track "..app_track.." ‘",36,96,7)
	print("Ž or — to start",26,108,7)
end

function updatetrackselect()
	camtu+=1
	campi=25
	
	-- count active tracks (more than one cnr)
	local num=1
	while num<#tracks and #tracks[num+1] > 1 do
		num+=1
	end
	
	if btnp(‹) and app_track>1 then
		app_track-=1
		dset(0, app_track)
		rebuildtrack()
		initcars() 
	end
	if btnp(‘) and app_track<num then
		app_track+=1
		dset(0, app_track)
		rebuildtrack()
		initcars() 
	end

	orbitcam(200,1)
	
	if(btnp(Ž) or btnp(—))racemode()
end

function levelintro()
	local fromtu=localangle(camtu)
	local frompi=campi
	local fromd=200
	for i=0,1,0.005 do
		if(btnp(Ž)or btnp(—))return
		local f=cos(i/2)*-0.5+0.5
		camtu=lerp(fromtu,0,f)
		campi=lerp(frompi,0,f)
		local d=lerp(200,0,f)+camdist
		orbitcam(d,1-sqrt(f))
		yield()
	end 
end

function orbitcam(dist,ofsfactor)
	camx,camy,camz=matz(loc2world(camtu,campi),-dist)
 local track=tracks[app_track]
	camx+=track.objxofs*ofsfactor
	camz+=track.objzofs*ofsfactor
 camy-=camheight+1
end
-->8
-- file io

base,filever=0x2000,7

function loadtracks()
	-- load data into ram
--	printh("loading from this cart")
	reload(0x4300,base,0x1000)
	
	-- unpack data
	local addr=0x4300
	local ver=peek(addr) addr+=1
--	printh("file version: "..ver)
	if ver>filever then
--		printh("incompatible version: "..ver)
		stop()
	end 
	local numtrack=peek(addr) addr+=1
	tracks={}
	for i=1,numtrack do
		local track=getdeftrack()
		add(tracks,track)
		local numcnr=peek2(addr) addr+=2
		for j=1,numcnr do
			local ct=peek(addr) addr+=1
			local tu=peek2(addr) addr+=2
			local tpi=peek2(addr) addr+=2
			local flagidx=peek(addr) addr+=1
			local mn,mx=0,2
			if ver>=6 then
				mn=peek(addr)/100 addr+=1
				mx=peek(addr)/100 addr+=1
			end			
			local flags=flagidx&0x0f
			local typidx=(flagidx&0xf0)>>4
			local gap,nopoles=flags&1~=0,flags&2~=0
			add(track,{ct=ct,tu=tu,tpi=tpi,gap=gap,nopoles=nopoles,typ=roadtypes[typidx],mn=mn,mx=mx})
		end
		
		-- obj generation info
		if ver>=2 then
			track.seed=peek4(addr) addr+=4
			track.objrng=peek2(addr) addr+=2
			if ver>=5 then
				track.objxofs=peek2(addr) addr+=2
				track.objzofs=peek2(addr) addr+=2
			end
			local ct=peek(addr) addr+=1
			for i=1,ct do
				if ver>=4 then
					local typidx=peek(addr) addr+=1
					track.obj[i].typ=bgtypes[typidx]
				end
				track.obj[i].ct=peek2(addr) addr+=2
			end   
			if ver>=3 then
				track.colsky=peek(addr) addr+=1
				track.colgnd=peek(addr) addr+=1
				if ver>=7 then
					track.mn=peek(addr)/100 addr+=1
					track.mx=peek(addr)/100 addr+=1
				end
			end
		end
	end
end
__gfx__
000000007cccccccc9999cccc7777ccc000000000000000000000000000000002888888265666566656665666566656665666566656665666566656628888882
0000000077ccccccc99999ccc77777cc0000000000000000000000000000000028eeee8266666666666666666666666666666666666666666666666628eeee82
00700700777ccccc9999999977777777000000000000000000000000000000002888888266666666666666666666666666666666666666666666666628888882
000770007777cccc9999999977777777000000000000000000000000000000002888888266666666666666666666666666666666666666666666666628888882
0007700077777ccc99cccc9977cccc77000000000000000000000000000000002888888266666666666666666666666666666666666666666666666628888882
00700700777777cccccccccccccccccc000000000000000000000000000000002888888266666666666666666666666666666666666666666666666628888882
000000007777cccccccccccccccccccc000000000000000000000000000000002222222255555555555555555555555555555555555555555555555522222222
0000000077cccccccccccccccccccccc000000000000000000000000000000002222222255555555555555555555555555555555555555555555555522222222
caaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaac5dddddd5cccccccccccccccccccccccccccccccccccccccccccccccc5dddddd5
99999999999999999999999999999999999999999999999999999999999999995dddddd56666666666666666666666666666666666666666666666665dddddd5
99999999999999999999999999999999999999999999999999999999999999995dddddd5cccccccccccccccccccccccccccccccccccccccccccccccc5dddddd5
44444444444444444444444444444444444444444444444444444444444444445dddddd5cccccccccccccccccccccccccccccccccccccccccccccccc5dddddd5
44444444444444444444444444444444444444444444444444444444444444445dddddd5cccccccccccccccccccccccccccccccccccccccccccccccc5dddddd5
55555555555555555555555555555555555555555555555555555555555555555dddddd55555555555555555555555555555555555555555555555555dddddd5
55555555555555555555555555555555555555555555555555555555555555555dddddd5cccccccccccccccccccccccccccccccccccccccccccccccc5dddddd5
c55555555555555555555555555555555555555555555555555555555555555c5dddddd5cccccccccccccccccccccccccccccccccccccccccccccccc5dddddd5
c56666650000000000000000000000077000000000000000000500005666665c2222222222222222555555555555555555555555555555552222222222222222
56667665000000000000000000d000077000005000d0000000000000566676658888888888888888000000000000000000000000000000008888888888888888
56666665000000000000000000005000000000000000000000000000566666652222222222222222007777077077007707700777077077002222222222222222
566665650005000000000050000000000d000000000000d000000500566665652222222222222222007700077077707707707700077077002222222222222222
565666650000000d0000000000000000000500000005000000500000565666652222222222222222007770077077077707700777077777002222222222222222
566667650000000000000000000d0000000000000000000000000000566667652222222222222222007700077077007707707770077077002222222222222222
55555555000000000000000000000000000000000000000000000000555555558888888888888888000000000000000000000000000000008888888888888888
55555555000000000000000000000000000000000000000000000000555555552222222222222222555555555555555555555555555555552222222222222222
cccdd66dddddddd55dddddddddddddd55dddd66ddd66ddd55dddd66ddd66dccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccddd56dd5dddddddddddddddd5dddddddddd56ddd666dddddddd56ddd666dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cddddd5dd0ddddddd66ddddddd0dddddd66ddd5ddd555ddddddddd5ddd555ddccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dd55dddddddddddd665dddddddddd66d665dddddddddd66ddddddddddddddd55cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dd00dddddd66dddd55ddd66dddddd66d55dddddddd66d66dddddd66ddd66dd00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddd55dddddddd6666ddddd55ddddd55dddd55d55ddddd6666dd55ddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddd566ddddddddddddd00dddddddddddddd566dddddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6dddddddddddddd66dddd55dddddddd66dddddddddddddd66dddd55dddddddd6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc3ccccccccccccccc3333333333335555555ccccc567777652825528205666650000566665000056666500005cccccccccccccccccccccc5445cccccc
cccccccc3cccccccccccc33333333bb3333335553355cccc567777652825528255677776555567777655556777765555ccccccccccccccccccccc549445ccccc
ccccccc333cccccccc3333333333bb33333bb335533555cc567777652825528255567777655556777765555677776555cccccccc555cccccccccc5aa445ccccc
cccccc33b3ccccccc333333bbb33333333333333555555cc567777652825528255556777765555677776555567777655ccccc5556665555cccccc4a9945ccccc
cccccc33b3cccccc3333bb3bb3333333335533335533551c567777652825528265555677776555567777655556777765ccc5566666666665cccc54994455cccc
cccccc33b33ccccc333bb333333333333333335333335551567777652825528276555567777655556777765555677776cc55777776666775cccc54994555cccc
ccccc33bb33ccccc333b33333533533bb333555335535551567777652825528277655556777765555677776555567777cc5dd66667777dd5cccc54944455cc5c
ccccc33bb33ccccc33333335335533bb3333333355335151567777652825528277765555677776555567777655556777cc5ddd6666666dd5cccc54994455c595
ccccc33b3335ccccc3353333333333333553333555551551000000000000000077765555677776555567777655556777ccc5dd6666666dd5c5cc54494455c545
cccc333bb335ccccc5553bb333333333335533555533551c000000000000000077655556777765555677776555567777ccc5dd666666dd5c595c54494455c545
cccc33bbb3335cccc5333b3355553333333555555335551c000000000000000076555567777655556777765555677776cccc5dd66666d5cc545c54994455c545
ccc3333bb3555cccc53333333355553335555555555551cc000000000000000065555677776555567777655556777765cccc555ddd5555cc545c549a4555c545
cc333bbb33335ccccc5333533355553555553351555511cc000000000000000055556777765555677776555567777655ccc566655566665c545c54494555c545
cc3b3bb3333355cccc553555553553355555555111111ccc000000000000000055567777655556777765555677776555ccc57766667777d5545c544945555445
c333bbbbb33535cccc55555555445555551551111ccccccc000000000000000055677776555567777655556777765555ccc5d67777666dd5545c549944554a45
c3333bbbb333355cccc5551115444415511114551ccccccc000000000000000005666650000566665000056666500005ccc5d66666666dd5545c549944559445
5333bbbbbb333555cccc11cccc54444110544551cccccccccccccccccccccccccccccccc5665cccccccc5665cccccccccc55dd6666666d5c545c54944455445c
533bbbbbbb335555ccccccccccc544444554451ccccccccccccccccccccccccccccccccc5665cccccccc5665cccccccc55665d66666d55cc545c54a9445555cc
5333bbbbb3353355cccccccccccc54444444551ccccccccccccccccccccccccccccccccc5665cccccccc5665cccccccc576665555555c5cc544554994455cccc
533bbbb333333555ccccccccccccc549444551ccccccccccccccccc66666cccccccccccc5665cccccccc5665cccccccc5d776666666675cc549454494455cccc
c533bbbbbb333555ccccccccccccc54944451cccccccccccccc6666666666ccccccccccc5665cccccccc5665cccccccc5dd677777777d5cc544954994455cccc
c533bbbbb3333355ccccccccccccc54944551ccccccccccccc666776676666cccccccccc5665cccccccc5665cccccccc5dd6666666ddd5ccc54454994455cccc
c5333bbb33333555cccccccccccccc544451ccccccccccccc66667666666666ccccccccc5665cccccccc5665ccccccccc5d6666666dd5ccccc5554494455cccc
c553333333335555cccccccccccccc594451ccccccccccccc666666676666666cccccccc5665cccccccc5665ccccccccc5d666666dd5655ccccc54994555cccc
cc5533333535555ccccccccccccccc544451cccccccccccc5666666666666665cccccccccccccccccccccccccccccccccc5d6666d5566675cccc549a4555cccc
ccc55555555555cccccccccccccccc549451cccccccccccc5666666666656565cccccccccccccccccccccccccccccccccc555555566667d5cccc54994455cccc
ccccc555555ccccccccccccccccccc549451cccccccccccc5566666566666655cccccccccccccccccccccccccccccccccc5dd66667777dd5cccc54944455cccc
cccccc5944cccccccccccccccccccc544451cccccccccccc5666566666566555cccccccccccccccccccccccccccccccccc5dd66666666dd5cccc54994455cccc
cccccc5945cccccccccccccccccccc544451cccccccccccc5566665656665565cccccccccccccccccccccccccccccccccc5dd66666666d55cccc54a94455cccc
cccccc5445cccccccccccccccccccc594451cccccccccccc5555666665556555cccccccccccccccccccccccccccccccccc5ddd666666dd5ccccc54994455cccc
cccccc4944cccccccccccccccccccc5444551cccccccccccc555555555555555ccccccccccccccccccccccccccccccccccc5dddddddd55cccccc54944455cccc
ccccccc44cccccccccccccccccccc545054551ccccccccccc55555555555555ccccccccccccccccccccccccccccccccccccc55555555ccccccccc544555ccccc
cccccccccccccccccccccccccccccccccccccccca1111111000000000000000000000000000000000000000000000000cccccccd66666dcccccccd6666dccccc
cccccccccccc3b3ccccccccccccccccceeeeeeedcca11111000000000000000000000000000000000000000000000000cccccd7777777dcccccd77777777dccc
ccccccccccccb3b3cccccccccccccccc88888ffeee001111000000000000000000000000000000000000000000000000ccccd66666666dccccd6666666666dcc
ccccccccccc333b3ccc33bbbcccccccc9999988ff0000111000000000000000000000000000000000000000000000000cccdddddd55555cccdddddd55ddddddc
ccccccccccc333b3cc3bb333bbccccccaaaaa99800000011000000000000000000000000000000000000000000000000cccd11d55ccccccccd11d55cc55d11dc
cccccccccccc333b33b3333333bcccccbbbaaaa900000011000000000000000000000000000000000000000000000000ccdddddcccccccccdddddccccccddddd
cccccccccccc3c3b33b333c3c33ccccccccbbaa000000001000000000000000000000000000000000000000000000000ccd66d5cccccccccd66d5cccccc5d66d
cccccbbbbbcccc3b3b333cccc33cccccdddccb0000000001000000000000000000000000000000000000000000000000ccd77dccd7777dccd77dccccccccd77d
cccbb33333bbcc3b3b33cccccc3ccccceedddc0000000000000000000000000000000000000000000000000000000000ccd66dccd6666dccd66dccccccccd66d
ccb333333333bc3b3b3cccccccccccccffeedd0000060000000000000000000000000000000000000000000000000000ccdddddcddddddccdddddccccccddddd
cb333c3c33333b33b33ccccccccccccc88ffe00000656000000000000000000000000000000000000000000000000000cc5d11dc55d11dcc5d11dccccccd11d5
cb33cc3c3c3333b3bbbbbbbccccccccc9988f00000656000000000000000000000000000000000000000000000000000cccddddddcddddcccddddddccddddddc
c3c3cccc3c3bbbb3bb33333bbbcccccca999800006555600000000000000000000000000000000000000000000000000ccc5d6666dd66dccc5d6666dd6666d5c
c3ccccccc3b333b33333333333bcccccbaa9900006555600000000000000000000000000000000000000000000000000cccc5d7777777dcccc5d77777777d5cc
cccccccc3b33353335333333333bbbcccbba000006555600000000000000000000000000000000000000000000000000ccccc55d66666dccccc55d6666d55ccc
cccccccc3b333555553cc333333333bcdccb000006555600000000000000000000000000000000000000000000000000ccccccc5555555ccccccc555555ccccc
cccccccc3b3c3499993cc33cc3c3c333eddc00000655560000000000000000000000000000000000ccccccd66dcccccccccd666666dccccccccd666666dccccc
ccccccc3b33c449ffe4cc33cc3c3c3c3eeed00000655560000000000000000000000000000000000cccccd777dcccccccccd7777777dcccccccd7777777dcccc
ccccccc3b3cc44eee44cc3ccccccccc3ffee00000655560000000000000000000000000000000000ccccd6666dcccccccccd66666666dccccccd66666666dccc
ccccccc3b3ccc44449cccccccccccccc88f000000655560000000000000000000000000000000000cccdddddddccccccccc55555dddddcccccc55555dddddccc
cccccc333ccc449ff94ccccccccccccc998000006555556000000000000000000000000000000000cccd11111dcccccccccccccc5d11dccccccccccc5d11dccc
ccccccc33ccc449ffe4cccccccccccccaa9000006555556000000000000000000000000000000000ccc555ddddcccccccccccccccddddccccccccccccddddccc
ccccccc3cccc44eee44cccccccccccccbba000006555556000000000000000000000000000000000ccccccd66dcccccccccccccccd66dccccccccd666666dccc
ccccccccccccc44449ccccccccccccccccb000006555556000000000000000000000000000000000ccccccd77dccccccccccccccd777dccccccccd77777d5ccc
cccccccccccc449ff94cccccccccccccdcc000006555556000000000000000000000000000000000ccccccd66dcccccccccccccd666d5ccccccccd666666dccc
cccccccccccc449ffe4ccccccccccccced0000006555556000000000000000000000000000000000ccccccddddccccccccccccddddd5ccccccccc5555ddddccc
cccccccccccc44eee44cccccccccccccfe0000006555556000000000000000000000000000000000ccccccd11dcccccccccccd111d5ccccccccccccccd11dccc
ccccccccccccc44449cccccccccccccc8f0000006555556000000000000000000000000000000000ccccccddddccccccccccddddd5ccccccccccccccdddddccc
cccccccccccc449ff94ccccccccccccc980000006555556000000000000000000000000000000000cccd66666666dccccccd66666666dccccccd66666666dccc
cccccccccccc449ff94ccccccccccccca90000006555556000000000000000000000000000000000cccd77777777dccccccd77777777dccccccd7777777d5ccc
ccccccccccccc49ff4ccccccccccccccba0000006555556000000000000000000000000000000000cccd66666666dccccccd66666666dccccccd666666d5cccc
cccccccccccccc444ccccccccccccccccb0000006555556000000000000000000000000000000000ccc5555555555cccccc5555555555cccccc55555555ccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccaaaaaaaaaaaaaaccccccccccccccccccccccccccaaaaaaaaaaaaacccccccccccccccccccccaaaaaaaaaaccccccccccccccccccaaaaaaaaaaaaacccc
ccccccccc44444444444444ccccccccccccccccccccccccc64444644444444cccccccccccccccccccc64444444444ccccccccccccccccc65444446544444cccc
cccccccccc5cccccccccc5ccccccccccccccccccccccccc65ccc65c65ccc65ccccccccccccccccccc65ccccccccc65ccccccccccccccc65ccc65c65ccc65cccc
cccccccccc5cccceecccc5ccccccccccccccccccccccccc65ccc65c65ccc65cccccccccccccccccc65cccceecccc65ccccccccccccccc65ccc6ee65ccc65cccc
cccccccccc5cc565565cc5cccccccccccccccccccc565655ccd65dd5cccc65ccccccccc56565ccc65cccce1fe6dcc65ccccccccc565665ccccefd65dcc65cccc
ccc99999cc5cd655556dc5cc99999cccccccccccccc55555cd66566d999aaacccccccccc5c5ccc65ccccceffe6aaa65cccccccccc55565ccaaa99956da65999c
cccaaaaac95995666659959caaaaacccccccccccc5656665cd44444999a444accccccc5666665c4444444444aa444aa4ccccccc56665444a444a99944444a999
ccc99050944444444444444905099ccccc05000c4405000444aaaaa44440004cccc00444444444aaaaaaaaaa4400044acc0005044444aaa40004444999994444
ccc50505499f99999999f99450505cccc500444445000000aa9999905000500cc000000aaaaaaa999999999400050004c0000005aaaa99900500050999884050
ccc0505049f7f999999f7f9405050cccc0549f9f90500500999999950505750cc0055009999999999999999000765000c0050050999999905750505999884505
ccc50505499f99999999f99450505cccc504979795005750999999905005650c00576500999999999999999005666500c0575005999999905650050444494050
ccc05050444444444444444405050cccc0549f9f90505650999999950505650c00566500999999999999999000565000c0565050999999905650505555494505
ccc50505444444444444444450505cccc500444445000500444444405000500cc0055004444444444444444400050004c0050005444444400500050555444050
ccc05050cccccccccccccccc05050cccc0500000c0500000500000c50500000cc000000ccccccccccccccccc0000000cc0000050c00000500000505c00000505
cccc0505cccccccccccccccc5050cccccc05000ccc05000505000ccc505000ccccc00ccccccccccccccccccccc000ccccc00050ccc00055c000505ccc000505c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd6666dcccccccccccccccccccccccccc
cccccccccaaaaaaaaaaaaaacccccccccccccccccccaaaaaaaaaaaaaacccccccccccccccccccccccaaaaaaaaaaaacccccd777777dcccccccccccccccccccccccc
ccccccccc44444444444444ccccccccccccccccccc44444444444444cccccccccccccccccccccc6546544444444cccccd6666666dccccccccccccccccccccccc
cccccccccc5cccccccccc5cccccccccccccccccccc5c65ccccc5c65ccccccccccccccccccccccc65c65c65cc65ccccccdddd5ddddccccccccccccccccccccccc
cccccccccc5cccceecccc5cccccccccccccccccccc5c65cceec5c65cccccccccccccccccccccc65cc65e65cc65ccccccd11dc5d11dcccccccccccccccccccccc
cccccccccc5ccddddddcc5cccccccccccccccccccc5c655eddddc65ccccccccccccccccccc56565cd65dddcc65ccccccddddcc5dddcccccccccccccccccccccc
ccc99999cc5cd666666dc5cc99999cccccccccca9999656d6666d65ca99999ccccccccccccc56aa9995666da65999cccd66dccd66dcccccccccccccccccccccc
cccaaaaac44444444444444caaaaaccccccccccaaaaa444444444444aaaaaacccccccccccc44a44a9994444444a999ccd7777777dccccccccccccccccccccccc
ccc99999499999999999999499999ccccccc5004a9999999999999994a9999cccccc005044aa400444499999994444ccd6666666dc6c66c666c66c6666ccc666
ccc50500498899999999889400505ccccccc00505050988999999889400505ccccc000005a99055005089999884050ccddddddddcd5dddcdd5d5dcdd55dcd555
ccc05050498899999999889405050ccccccc05070505988999999889405050ccccc055050999075050589999884505ccd11d5d11d1c511c11c1c1c11cc1c1ccc
ccc50506499944444444999460505ccccccc60565050999444444999460505ccccc075005999065005044444494050ccddddcdddddccddcddcdcdcddccdc5ddc
ccc05050499945555554999405050ccccccc65060505999555555999405050ccccc065050999065050545555494505ccd66dc5d66dc666c66c6c6c666c6cc556
ccc50500444445555554444400505ccccccc00505050444555555444400505ccccc055005444055005045555444050ccd77dccd777d577c77c7c7c77575c7775
ccc05050cccccccccccccccc05050ccccccc05000505ccccccccccc0505050ccccc000050ccc0000505ccc00000505ccd66dcc5d66dc55c55c5c5c66c5cc555c
cccc050cccccccccccccccccc050cccccccc5050505cccccccccccc500050ccccccc0050ccccc00505ccccc000505ccc5555ccc5555ccccccccccc55cccccccc
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0708220028000000003000c80fe2ff00003000c8143c00000030003c143c00000030003c0c000000003000c80a0000c4ff1000c80f0000d3ff1000c81f00002d001000220500001e001000280f0000d3ff1000c80f00001e0010002a1a00001e0010002312000000001000201e5a0000003000371e5a0000003000c814a6ff00
0030003c0a000000003000c81e5a00000030003c14000000003000c80f0000e7ff5000c80f000000005000370e000000005000c80f5a00000050003c0fa6ff000050003217000000005000c80a000000005200c80a000000005000c80fa6ff00005000320a0000280050001e0a000000005000230f000000003000c814a6ff00
0030003214a6ff000030003216000000003000c896686c0bfa003200320003013200021e000319000c0319411b001e000000002000c8145a0000002000371e000000002000c8060000e7ff1000c80a0000e7ff1000c81400001900112f320a000019001000c806000000001000c80a000000002000c81ea6ff00002000371000
0000002000c814a6ff000020003c14000000003000c80fd3ff00003000c80f000000003000c80f2d0000003000390d000000003000c80f1e0000003000c80fe2ff00003000c807000000003000c814d3ff00003000c81df1ff000030003c0f2d0000003000c814a6ff0000200037170f0000002000c827a6ff000020003729a6
ff000020003ccce31974fa003200320003041900050f00061e000c061e3f230014000000003000c80a2d00000030003c1e000000003000c81ea6ff000030003214d3ff00003000af14f1ff00003000c814a6ff00003000320ae2ff00003000c80d000000003000c80c0000e2ff1000c81200001e001200230c000000001000af
14000000003000af142d00000030003c19000000003000c80f0000e2ff4000af0f0000e2ff4000af2300001e0011393c0a00001e004000af0a000000004000c80f000000004000c80f42000000400034192d00d3ff4000c80f2d00e2ff4000c80f000000004000af0d000000004000af0f00001e004000300f00001e00400064
1100002a00113e640e000000001000c80e000000002000c8145a00000020003c14090000002000c810b5ff00002000410e000000002000c8895067402c010000000003013200021900031e000104193f1e000c000000003000c80cd3ff00003000c8195a000000300032195a00e2ff4000320f2d00e2ff4000af140000000040
00af1300003c0041223201000000004100c80f000000004000c80fa6ff000040002d05000000004000c808d3ff00004000320f00002d004000230f0000d3ff4000af0f00002d004000150b0000000040001914a6ff000020003714a6ff000020003714000000002000af142d0000002000c804000000002000c80a0000ebff10
00c81c00001500113d400a000000001000c808000000003000c81ea6ff00003000321ea6ff00003000370a000000003000af1fa6ff000030003c09000000003000af1f93bf47c8001900190003040a00021e00031400020d193e260031000000003000c832000000003000c819f7ffa6ff1000af19f7ff4cff1000c81909005a
001025af19090000001000af23000000003000c8192d0000003000c823a6ff000030003a1e000000003000af0a0000d8ff1000af0f0000d8ff1000c81e000028001132350f000028001000c80a000000001000c814000000003000c814a6ff000030003219a6ff00003000320f000000003000c80a0000ceff1000af22000032
001134360a000000001000af0f000000003000c80f2d0000003000c80f0000d8ff5000c80f00000a005000231e2d0005005000192a000005005000b119e2ffecff5000c80f1e00ecff5000c80fdfff00005000c80f00002d0050001919a6ff00005000320a000000003000c8143c0000003000c810000000003000c82da6ff00
0030003722b8ff000030003ab0ea0f089001ceff640003051e00022800030a00010d19484e0016000000002000c80a2d00000020004019000000002000c80a0000d3ff1000c8140000d3ff1000c80a000000001000190a0000000010001914a6ff00001000c814000000001000c80ad3ff00001000c80a0000e2ff1000c80a00
00e2ff1000c81900001e001000231900001e001000af0f0000d3ff1000c83200002d001140430a00002d001100c81f000000001000c81e000000002000c814a6ff00002000321e000000002000af14a6ff000020003214ebff000020003214150000002000c80a0000d3ff4000c80f00002d004000370f0000d3ff4000200f00
002d004000200a00000000400032145a00000020002814c4ffeeff4000c814c4ffebff40003214a6fff1ff40003214d3ff00004000321e150000004000c8145a00f4ff400032145a00eeff400032145100000040003214000000004200af0f0000360042001906000036004000190e000042004332af0b000000004200af0a00
0000002200c814a6ff00002200321e000000002200c8145a00000022003214000000002200320a0000dfff1000c81400002100112b2d0a000000001000af195a0000002200af195a000000220032195a00000022003219000000002200af195a00000022003219a6ff00002200321e000000002200af195a0000002200321400
000000220032195a000000220032195a00000022003214000000002200320a0000dfff1000af1400002100112d320a000000001000af18000000002200af0a0000d6ff1000c80a0000d6ff1000c80a000000001000230e00000000120019125a000900100032125a001200100032125a00120010003212000000001000c80a00
0000002000c80b4200000020003a1e000000002000afd350390ff4010000000003053200041400030f000c0f19462f000f000000002000c80a2d0000002000c80a000000002000c80ad3ff00002000af0a000000002000c80a5a0000002000320f000000002000c8080000d3ff1000c80f0000d3ff1000c807000000001000af
160000000010002d160000000010002d0f5a0000001000190a00003c001000190700003c001000190b0000000010001906000000002000320a3c0000002000c806370000002000320e000000002000c8080000e2ff1000c8080000e2ff1000c81500001e00112d2f0800001e0010191908000000001000af0a000000002000af
14a6ff00002000320ad3ff00002000c810000000002000c810a6fff6ff10003210a6fff6ff10003210a6fff6ff10003208d3fff6ff1000320a000000001200c80f3c0000001000c80c0000d3ff1200c80c00002d0011212410000028001000af0a000000001000320fa6ff00002000320fa6ff00002000320a000000002000c8
0a1e0000002000c80aa6ff000020003204000000002000c808e7ff00002000c808000000002000c8a2bf4830c8001900190003013200020f00030a000c03193f290023000000002000c81ca6ff000020003719a6ff00002000c80f2d00000020003a1e000000002000c80f0000bfff4000c8190000bfff4200c80f0000000040
19c80f0000000042001e0f0000000040001e0fa6ff00004200370fa6ff00004000370a000032004200190a2d000000400019145a000000420032145a000000400032145a000000420032140000320040001e190000ceff4200c814d3ff000040002814a6ff0f0042003214a6ff0f00400032145a000f004200c8145a000f0040
00321ea6ff0f004200321ea6ff000040003919000000002000c819d3ff00002000411e000000002000c8080000d8ff1000c80c0000d8ff1000c82d00002800113c3e0c000028001000c808000000001000c80f000000002000c814a6ff000020003714e2ff000020004106000000002000c8141e000000200041180000000020
00c80e000000002000c858eaf527c800b5ffe7ff03013200060f00030a000d0f1941e7ff03013200060f00030a000d0f1932000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001765016650166501665017650186401964019630196301962018620196101a6101b6101c6101961018610006000060000600006000060000600006000060000600006000060000600006000060000600
001000001915019150191501915000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
001000002515025150251502514025130251202511000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0008000005760067600776008760097600a7600b7600c7600d7600e7600f760107601176012760137601476015760167601776018760197601a7601b7601c7601d7601e7601f7602076021760227602376024760
0008000005130061300713008130091300a1300b1300c1300d1300e1300f130101301113012130131301413015130161301713018130191301a1301b1301c1301d1301e1301f1302013021130221302313024130
010500020c03000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070002002100c740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000cd600dd600ed600fd6010d6011d6012d6013d6014d6015d6016d6017d6018d6019d601ad601bd601cd601dd601ed601fd6020d6021d6022d6023d6024d6025d6026d6027d6028d6029d602ad602bd60
012000000ce600de600ee600fe6010e6011e6012e6013e6014e6015e6016e6017e6018e6019e601ae601be601ce601de601ee601fe6020e6021e6022e6023e6024e6025e6026e6027e6028e6029e602ae602be60
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
00 03 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
