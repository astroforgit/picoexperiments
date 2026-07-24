pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- loose gravel
-- by mot

topspd=0.3
accel=0.002
brake=0.0045
coast=0.001
laps=3
stunframes=30

bgco={}
fgco={}
drawco={}

mode_menu=1
mode_game=2
mode_postrace=3
mode=0

stage=1

demo=false
democt=0

function _init()
 initnpctypes()
 setmode(mode_menu)
end	

function _update()

 -- coroutines
 if(runfg())return
 runbg()
 
 -- gameplay
 if mode==mode_menu then
 	updatemenu()
 elseif mode==mode_game then
 	updategame()
 elseif mode==mode_postrace then
 	updatepostrace()
 end
end

function _draw()
	if mode==mode_menu then
	 drawmenu()
	elseif mode==mode_game then 
	 drawgame()
	elseif mode==mode_postrace then
		drawpostrace()
	end
	
 rundraw() 

--		drawtext("cpu:"..ceil(stat(1)*100),0,92) 
--		drawtext("bg:"..#bgco,0,99) 
--		drawtext("fg:"..#fgco,0,106) 
--  drawtext("dr:"..#drawco,0,113) 
--  if sprites.s~=nil then
--	  drawtext("sp:"..#sprites.s,0,120)
--  end
end

function setmode(m)
 if(mode==m)return

 -- cleanup
 if mode==mode_game then
  menuitem(1)
  menuitem(2)
  music(-1,2000)
 end
 
 clearco()
 sprites={}
 democt=0
 
 -- set mode
 mode=m
 
 -- setup
 if mode==mode_game then
  initgame()
  menuitem(1,"restart race",
   function()
    setmode(0)
    setmode(mode_game)
   end)
  menuitem(2,"quit to menu",
   function() setmode(mode_menu) end)  
 elseif mode==mode_postrace then
 	initpostrace()
 end
end

function dup(o)
 local r={}
 for k,v in pairs(o) do
  r[k]=v
 end
 return r
end
-->8
-- vector maths

vec3={}

vec3.new=function(x,y,z)
 local v={x=x,y=y,z=z}
 setmetatable(v,vec3.mt)
 return v
end

vec3.copy=function(v)
 return vec3.new(v.x,v.y,v.z)
end

vec3.neg=function(a)
 return vec3.new(-a.x,-a.y,-a.z)
end

vec3.add=function(a,b)
 return vec3.new(a.x+b.x,a.y+b.y,a.z+b.z)
end

vec3.sub=function(a,b)
 return vec3.new(a.x-b.x,a.y-b.y,a.z-b.z)
end

vec3.scale=function(v,scale)
 return vec3.new(v.x*scale,v.y*scale,v.z*scale)
end

--vec3.dot=function(a,b)
-- return a.x*b.x+a.y*b.y+a.z*b.z
--end

vec3.div=function(v,d)
 return vec3.new(v.x/d,v.y/d,v.z/d)
end

--vec3.tostring=function(v)
-- return "("..v.x..","..v.y..","..v.z..")"
--end

vec3.len=function(v)
 return sqrt(vec3.dot(v,v))
end

-- metatable
vec3.mt={}
vec3.mt.__unm=vec3.neg
vec3.mt.__add=vec3.add
vec3.mt.__sub=vec3.sub
vec3.mt.__mul=function(a,b)
 if getmetatable(a)~=vec3.mt then
  return vec3.scale(b,a)
 elseif getmetatable(b)~=vec3.mt then
  return vec3.scale(a,b)
 else
  return vec3.dot(a,b)
 end
end
vec3.mt.__div=vec3.div
vec3.mt.__tostring=vec3.tostring
vec3.mt.__len=vec3.len
vec3.mt.__concat=function(a,b)
 if getmetatable(a)==vec3.mt then
 	a=vec3.tostring(a)
 end
 if getmetatable(b)==vec3.mt then
  b=vec3.tostring(b)
 end
 return a..b
end

-- const
vec3.zero=vec3.new(0,0,0)
-->8
-- track

-- constants
seglen=1
segwid=3					 -- actually half
anglef=0.005
tnlheight=4
tnlroof=.5
skycol=12

cartype={
 name="car",
 tex={
  {sx=24,sy=4,sw=8,sh=4,maxw=10},
  {sx=24,sy=8,sw=16,sh=8,maxw=18},
  {sx=32,sy=80,sw=32,sh=16}
 },
 w=1,h=.5,
 trans=12
}
cartypel=dup(cartype)
cartypel.tex={{sx=32,sy=64,sw=32,sh=16}}
cartyper=dup(cartypel)
cartyper.flipx=true
cartypes={cartypel,cartype,cartyper}

-- background types
bg_tree={
 tex={
  {sx=0,sy=64,sw=32,sh=32}
 }, 
 w=2,h=2,
 spacing=2
}
bg_lamp={
 tex={
  {sx=0,sy=32,sw=16,sh=8}
 }, 
 w=.5,h=.25,
 spacing=2,
 trans=12
}
bg_house={
 tex={
  {cx=0,cy=0,cw=11,ch=5}
 },
 w=6,h=2.5,
 spacing=4,
 offset={x=2,y=0}
}
bg_house2={
 tex={
  {cx=24,cy=6,cw=9,ch=9}
 },
 w=4.5,h=4.5,
 spacing=4,
 offset={x=2,y=0}
}
bg_building={
 tex={
  {cx=14,cy=0,cw=10,ch=18}
 },
 w=5,h=9,
 spacing=6,
 offset={x=2,y=0}
}
bg_beam={
 tex={
  {cx=0,cy=13,cw=1,ch=4,maxw=8},
  {cx=0,cy=5,cw=2,ch=8}
 },
 w=1,h=4.5,
 spacing=2
}
bg_beamtop={
	tex={
	 {cx=1,cy=13,cw=6,ch=1,maxw=8},
		{cx=2,cy=5,cw=12,ch=2}
	},
	w=6,h=1,
	spacing=2,
	offset={x=0,y=-3.5}
}
bg_cactus={
	tex={
		{sx=112,sy=32,sw=16,sh=32}
	},
	w=1,h=2,
	spacing=3,
	offset={x=1,y=0}
}
bg_deserthouse={
	tex={
		{cx=24,cy=0,cw=10,ch=6}
	},
	w=5,h=3,
 spacing=4,
 offset={x=2,y=0},
 trans=12
}
bg_stones={
	tex={
		{sx=64,sy=80,sw=16,sh=16}
	},
	w=1.25,h=1.25,
	spacing=4,
	offset={x=0.5,y=0},
	trans=12
}
bg_finish={
	tex={
	 {cx=1,cy=14,cw=6,ch=1,maxw=8},
		{cx=2,cy=7,cw=12,ch=2}
	},
	w=6,h=1,
	spacing=2,
	offset={x=0,y=-3.5}
}
bg_rockwall={
	tex={
		{cx=7,cy=13,cw=1,ch=4}
	},
	w=1,h=4,
	spacing=2,
	trans=12
}
bg_rockwallr={
	tex={
		{cx=8,cy=14,cw=1,ch=4}
	},
	w=1,h=4,
	spacing=2,
	trans=12
}
bg_rockceil={
 tex={
  {cx=8,cy=13,cw=6,ch=1}
 },
 w=6,h=1,
 spacing=2,
 trans=12
}
bg_woodgatel={
 tex={
  {cx=3,cy=24,cw=1,ch=6,maxw=8},
 	{cx=0,cy=18,cw=1,ch=12}
	},
	w=0.5,h=6,
	spacing=1,
	trans=12 	
}
bg_woodgater={
 tex={
  {cx=10,cy=24,cw=1,ch=6,maxw=8},
 	{cx=13,cy=18,cw=1,ch=12}
	},
	w=0.5,h=6,
	spacing=1,
	trans=12 	
}
bg_woodgatet={
 tex={
 	{cx=4,cy=25,cw=6,ch=2,maxw=48},
 	{cx=1,cy=20,cw=12,ch=4}
	},
	w=6,h=2,
	offset={x=0,y=-3},
	spacing=1,
	trans=12 	
}
bg_snowman={
 tex={
  {sx=96,sy=64,sw=16,sh=16},
 },
 w=1.25,h=1.25,
 spacing=4,
 trans=2
}
bg_pine={
 tex={
  {sx=80,sy=0,sw=16,sh=32},
 },
 w=1.5,h=3,
 spacing=2
}
-- road types
road_finish={
 tex={
  {sx=0,sy=24,w=8,h=8}
 },
 gnd={7},
 gndspacing=1
}
road_pebbles={
 tex={
  {sx=0,sy=16,w=8,h=8,maxw=6},
  {sx=0,sy=8,w=8,h=8,maxw=10},
  {sx=8,sy=0,w=16,h=16}
 },
 gnd={13,5},
 gndspacing=2
}
road_asphalt={
 tex={
  {sx=8,sy=16,w=16,h=16}
 },
 gnd={3,6},
 gndspacing=2
}
road_street={
 tex={
  {sx=56,sy=0,w=8,h=8,maxw=14},
  {sx=40,sy=0,w=16,h=16}
 },
 gnd={13,6},
 gndspacing=3
}
road_intersection={
 tex={
  {sx=56,sy=0,w=8,h=8} 
 },
 gnd={5},
 gndspacing=1 
}
road_desertdirt={
 tex={
  {sx=64,sy=8,w=8,h=8,maxw=6},
  {sx=56,sy=8,w=8,h=8,maxw=14},
  {sx=56,sy=16,w=16,h=16}
 },
 gnd={9,4},
 gndspacing=2
}
road_snow={
 tex={
  {sx=8,sy=16,w=16,h=16}
 },
 gnd={7,7,7,7,12},
 gndspacing=1
}

-- tunnel types
tnl_whitelit={
 front=7,
 wall={1,13},
 wallspacing=1,
 bgceil=bg_lamp
}
tnl_gray={
 front=6,
 wall={0,5},
 wallspacing=2
}
tnl_brown={
 front=4,
 wall={4},
 wallspacing=1,
 bgl=bg_rockwall,
 bgr=bg_rockwallr,
 bgceil=bg_rockceil
}

-- scenery types
sc_finish={
 road=road_finish,
 bg=bg_finish,
 bgl=bg_beam,
 bgr=bg_beam,
 tnl=tnl_whitelit
}
sc_countrypebbles={
 road=road_pebbles,
 bgl=bg_tree,
 bgr=bg_tree,
 tnl=tnl_whitelit
}
sc_countryasphalt={
 road=road_asphalt,
 bgl=bg_house,
 bgr=bg_house,
 tnl=tnl_whitelit
}
sc_city={
 road=road_street,
 bgl=bg_building,
 bgr=bg_building,
 tnl=tnl_gray
}
sc_intersection={
 road=road_intersection,
 tnl=tnl_gray
}
sc_citybeams={
 road=road_street,
 bg=bg_beamtop,
 bgl=bg_beam,
 bgr=bg_beam,
 tnl=tnl_gray 
}
sc_desert={
 road=road_desertdirt,
 bgl=bg_cactus,
 bgr=bg_cactus,
 tnl=tnl_brown
}
sc_deserttown={
 road=road_desertdirt,
 bgl=bg_deserthouse,
 bgr=bg_deserthouse,
 tnl=tnl_brown
}
sc_desertgate={
 road=road_desertdirt,
 bgl=bg_woodgatel,
 bgr=bg_woodgater,
 bg=bg_woodgatet,
 tnl=tnl_brown
}
sc_desertstones={
 road=road_desertdirt,
 bgl=bg_stones,
 bgr=bg_stones,
 tnl=tnl_brown
}
sc_snow={
	road=road_snow,
	bgl=bg_snowman,
	bgr=bg_snowman,
	tnl=tnl_whitelit
}
sc_snow2={
	road=road_snow,
	bgl=bg_pine,
	bgr=bg_pine,
	tnl=tnl_whitelit
}
sc_snowtown={
	road=road_snow,
	bgl=bg_house2,
	bgr=bg_house2,
	tnl=tnl_whitelit
}

track={}
segct=0
sprites={}

function inittrack()
	track={}
	segct=0	
 skycol=12

 if stage==1 then
 for i=1,30 do
  local ct=flr(rnd(10))+5
  local tu=0
  local pi=0
  if(rnd(1)>.5)tu=rnd(16)-8
  if(rnd(1)>.075)pi=rnd(50)-25
  add(track,{
  	ct=ct,  
  	tu=tu,
  	pi=pi,
  	sc=sc_countrypebbles,
		 seg=0,
		 tnl=false
  })
 end
 
 for i=1,2 do
  changetrack(5,function(t)t.sc=sc_countryasphalt end)
 end   
 
 maketunnel(flr(rnd(4)+2))
 
 elseif stage==2 then
  skycol=1
  local pi=0
 
 	-- create city region
 	for i=1,50 do
	  local ct=flr(rnd(8))+4
 	 local tu=0
 	 local sc=sc_city
 	 local tnl=false
  	if i%2==1 then
			 local o=flr(rnd(5))+1
			 if o==1 or o==5 then
			  -- corner
			 	tu=rnd(8)-4
			 	tu+=sgn(tu)*4
			 	ct=4			 	
				 if(o==5)pi=0		-- level out
			 	
			 elseif o==2 then
			  -- hill
			 	if pi==0 then 
			 		pi=rnd(25)-12.5
			 		pi+=sgn(pi)*12.5
			 	else          
			 		pi=0
			 	end
			 	ct=4
			 elseif o==3 then
			  -- intersection
			  sc=sc_intersection
			  ct=2
			 elseif o==4 then
			  -- bridge
			  tnl=true
			  ct=1
			 end
  	end
			add(track,{
  		ct=ct,  
	  	tu=tu,
	  	pi=pi,
	  	sc=sc,
			 seg=0,
			 tnl=tnl
	  })	  	
 	end

 	track[1].tnl=false
 	
		for i=1,2 do
		 maketunnel(flr(rnd(3)+2)) 	
	 end
	 
	 for i=1,2 do
	 	changetrack(
	 		rnd(4)+2,
	 	 function(tr)
	 	 	tr.sc=sc_countryasphalt 
	 	  tr.tnl=false	
	 	 end)
 	end
 	
 	changetrack(
 		rnd(4)+4,
 		function(tr)
 		 tr.sc=sc_citybeams
 		end) 		
 		
 elseif stage==3 then 
 	skycol=10 
 	for i=1,50 do
	  local ct=flr(rnd(8))+3
	  local tu=0
	  local pi=0
	  if(rnd(1)>.5)tu=rnd(18)-9
	  if(rnd(1)>.75)pi=rnd(25)-12.5
	  add(track,{
 	 	ct=ct,  
	  	tu=tu,
	  	pi=pi,
	  	sc=cond(rnd(1)>.25,sc_desert,sc_desertstones),
			 seg=0,
			 tnl=false
			  })
		end
			  
 	-- towns
 	for i=1,3 do
	 	local r=changetrack(
	 		rnd(3)+3,
 			function(tr)
	 		 tr.sc=sc_deserttown
 			end)
 		local tr=track[r.f]
 		tr.sc=sc_desertgate
 		tr.ct=1
 		tr=track[r.l]
 		tr.sc=sc_desertgate
 		tr.ct=1
		end
		
	 maketunnel(flr(rnd(4)+5))
	
	elseif stage==4 then
 	skycol=12
 	for i=1,25 do
	  local ct=flr(rnd(12))+3
	  local tu=0
	  local pi=0
	  if(rnd(1)>.5)tu=rnd(18)-9
	  if(rnd(1)>.333)pi=rnd(50)-25
	  add(track,{
 	 	ct=ct,  
	  	tu=tu,
	  	pi=pi,
	  	sc=cond(rnd(1)>.25,sc_snow2,sc_snow),
			 seg=0,
			 tnl=false
			  })
		end
		
	 for i=1,3 do
	  changetrack(5,function(t)t.sc=sc_snowtown end)
	 end   

  for i=1,3 do
		 maketunnel(2)		
		end
	end
 
 -- finish line
 track[1].sc=sc_finish
 track[1].ct=1
 track[1].pi=track[#track-1].pi
 
 -- calc
 local prvpi=track[#track].pi
 segct=0
 for i=1,#track do
 	track[i].sp=prvpi
 	track[i].pd=(track[i].pi-track[i].sp)/track[i].ct
  track[i].seg=segct
  segct+=track[i].ct 	
 	prvpi=track[i].pi
 end 
end

function initsprites() 
	sprites={
	 from={n=1,s=0},
	 to={n=1,s=0},
	 range=0,
	 s={}
	}
end

function updatesprites(from,range)
 local sp=sprites.s
 sortptrs(sp)

 -- advance from pointer. 
 -- remove any off-screen sprites
 local f=sprites.from
 while f.n~=from.n or f.s~=from.s do
 
  -- delete sprites
  for s in all(sp) do
   if s.temp and s.n==f.n and s.s==f.s then
    del(sp,s)
   end
  end    

  -- advance from pointer forward 
  advanceptr(f)
  sprites.range-=1
 end
 
 -- advance to pointer
 local t=sprites.to
 while sprites.range<range do
 
  -- generate sprites?
  local tr=track[t.n]
  local sc=tr.sc
  local seg=tr.seg+t.s
  if not tr.tnl then
   if sc.bgl~=nil and seg%sc.bgl.spacing==0 then
    makebgsprite(sc.bgl,t,-1,tr.tnl)
   end
   if sc.bgr~=nil and seg%sc.bgr.spacing==0 then
    makebgsprite(sc.bgr,t,1,tr.tnl)
   end
   if sc.bg~=nil and seg%sc.bg.spacing==0 then
    makebgsprite(sc.bg,t,0,tr.tnl)
   end
  else
   local tnl=sc.tnl
   if tnl.bgl~=nil and seg%tnl.bgl.spacing==0 then
    makebgsprite(tnl.bgl,t,-1,tr.tnl)
   end
   if tnl.bgr~=nil and seg%tnl.bgr.spacing==0 then
    makebgsprite(tnl.bgr,t,1,tr.tnl)
   end
   if tnl.bgceil~=nil and seg%tnl.bgceil.spacing==0 then
    makebgsprite(tnl.bgceil,t,0,tr.tnl)
   end
  end
  
  -- advance pointer
		advanceptr(t)  
		sprites.range+=1
 end

 -- sort again to get any new sprites
 sortptrs(sp) 
end

function makebgsprite(typ,t,side,istnl)
 -- sprite offset
 local offset
 if typ.offset~=nil then
  offset=typ.offset
 else
  -- default offset based on position
 	offset={x=0,y=0}
  if(side==0 and istnl)offset.y=typ.h
 end

 -- base position
 local pos=vec3.new(side*(segwid+typ.w/2*cond(istnl,-1,1)),0,0)
 if(side==0 and istnl)pos.y-=tnlheight

	-- apply offset
 if side<0 then 
 	pos.x-=offset.x		-- mirror for left side
 else
 	pos.x+=offset.x
 end
 pos.y+=offset.y

 add(sprites.s,{
  typ=typ,
  n=t.n,
  s=t.s,
  temp=true,
  pos=pos
 })
end

function sortptrs(sp)
 sort(sp,compareptrs) 
end

function compareptrs(a,b) 
 local camz=getz(cam,cam.pos.z)
 return getrelz(a,a.pos.z,camz)-getrelz(b,b.pos.z,camz)
end

function maketunnel(ct,from)
 changetrack(
 	ct,
 	function(tr)tr.tnl=true end,
 	from)
end

function changetrack(ct,fn,from)
 if(from==nil)from=flr(rnd(#track))+1
 local t=from
 for i=1,ct do
  fn(track[t],t)
  if(i<ct)t=t%#track+1
 end 
 return { f=from,l=t }
end
-->8
-- rendering

screendist=64
camoffs=vec3.new(0,-2.5,-2)
cam={n=1,s=0,pos=vec3.zero}
drawsegct=40
segxtiles=2
segytiles=1
sky={7,12,12,2,14}
framect=0
hideui=false
carbasecols={4,9,10}
carpalettes={
 carbasecols,
 {0,5,6},
 {1,13,12},
 {9,10,7},
 {3,11,7},
 {2,8,14},
 {8,14,15},
 {2,14,15}
}

-- working
clp={
	l=0,
	r=128,
	t=0,
	b=128
}
sprbuf={}

function drawgame()
 framect+=1
	fillp(0)
	cls(skycol)
 drawscene()
 drawui()
end

function drawui()
 clip(0,0,128,128)
 if player.lap<=laps then
  if not hideui then
	  drawlaps()
	 	drawleaderboard()
	 	drawpodium(82,1,3,false)
	 	if demo and flr(framect/15)%2==0 then
	  drawcenteredtext("demo",30)
	  drawcenteredtext("press Ž to continue",40)
		 end
 	end
 	drawspeedo()	
 else
  if flr(framect/15)%2==0 then
	  drawcenteredtext("race complete!",8)
	 end
  drawcenteredtext("press Ž to continue",20)
	 rectfill(10,30,56,101,1)
  drawpodium(13,32,npcct+1,true)
	end
end

function drawscene()

 -- reset state
	clp={
		l=0,
		r=128,
		t=0,
		b=128
	}
 sprbuf={} 
 clip(0,0,128,128)

 -- walk forward along track
	local n=cam.n
	local s=cam.s
	local tr=track[n]
	local f=cam.pos.z/seglen
	local tu=-tr.tu*f*anglef
	local pi=(tr.sp+cam.s*tr.pd)*anglef
	local tnl=nil
	
	-- walk along sorted sprites 
 -- in parallel
 local camz=getz(cam,cam.pos.z)
	local si=1
	while si<#sprites.s 
 and getrelz(sprites.s[si],sprites.s[si].pos.z,camz)<0 do
  si+=1
	end

	local t=gettangent(tu,pi)
 local pos=adjustpos(cam.pos,t)

	-- road 3d cursor
	local r0=-pos-camoffs
	local pr0=project(r0)
	for i=1,drawsegct do
 	t=gettangent(tu,pi)

  -- next road 3d position
		local r1=r0+t*seglen
		local pr1=project(r1)

  -- add sprites
  while si<#sprites.s 
    and sprites.s[si].n==n 
    and sprites.s[si].s==s do
   local sp=sprites.s[si]
  
   -- calculate projected position
   local spos=r0+adjustpos(sp.pos,t)
   spos=project(spos)

   -- add to buffer
   add(sprbuf,
   {
    typ=sp.typ,
    plt=sp.plt,
    pos=spos,
    clp={
     l=clp.l,
     r=clp.r,
     t=clp.t,
     b=clp.b
    }
   })
   
   si+=1
  end   

  -- render
  local sct=tr.seg+s

  if tr.tnl then
   if tnl==false then
	   drawtunnelface(pr0,tr.sc.tnl)
	  end
   drawtunnelwalls(pr0,pr1,tr.sc.tnl,sct)
  end

  drawroad(pr0,pr1,t,tr.sc.road,tr.tnl,sct)

  -- adjust clip region
  if tr.tnl then
  	local r=gettunnelrect(pr1)
  	adjustcliprect(r)
  else
   clp.b=min(clp.b,ceil(pr1.y))
  end

	 -- update direction
	 tu+=tr.tu*anglef
	 pi+=tr.pd*anglef	 
	 
	 -- update tunnel flag
	 tnl=tr.tnl
	 
	 -- next segment
	 r0=r1
	 pr0=pr1
	 s+=1
	 if s>=tr.ct then
	  s-=tr.ct
	  n+=1
	  if n>#track then
	  	n-=#track
	  end
	  tr=track[n]
	  pi=tr.sp*anglef		-- redundant but for rounding errors
	 end	 
	end
	
	-- render sprite buffer in reverse
	for i=#sprbuf,1,-1 do
	 drawsprite(sprbuf[i])
	end		
end

function project(v)
	f=screendist/v.z
	return vec3.new(v.x*f+64,v.y*f+48,f)
end

function drawroad(p0,p1,t,su,tnl,sct)	
 local top=ceil(p1.y)
	local bot=ceil(p0.y)
	top=max(top,clp.t)
	bot=min(bot,clp.b)
	if(top>=bot)return

 setcliprect(clp)
 palt(0,false)
	
	-- draw ground
	local gndi=flr(sct/su.gndspacing)%#su.gnd+1	
	if not tnl then
 	rectfill(0,top,127,bot-1,su.gnd[gndi])
	end
	
	local h=p1.y-p0.y
	local rasteradj=top-p1.y

	-- road line
	local dr=(p1-p0)/h      -- gradient
	local r=p1+dr*rasteradj -- step to nearest raster line
	
	-- vertical texture coord
	local dv=segytiles/h				-- delta v
	local v=dv*rasteradj	   -- step to nearest raster line
	
	-- step down raster lines
	while r.y<bot do
	
	 -- single tile width
		local tilew=segwid*r.z/segxtiles
		
		-- choose "mipmap" texture
		local ti=1
		local t=su.tex[ti]
		while ti<#su.tex and tilew>t.maxw do
		 ti+=1
		 t=su.tex[ti] 
		end

		-- render tiles
		local sy=flr(t.sy+(v%1)*t.h)
		for i=-segxtiles,segxtiles-1 do
		 local x0=r.x+i*tilew
		 local x1=x0+tilew
		 sspr(t.sx,sy,t.w,1,
		      ceil(x0),r.y,ceil(x1)-ceil(x0),1)
  end
  
  r+=dr
  v+=dv
 end		      
 
 palt()
end

function adjustpos(p,t)
 return vec3.new(p.x,p.y,0)+t*p.z
end

function drawsprite(s)
 local t=s.typ

 setcliprect(s.clp)

 if s.plt~=nil then
  applypalette(s.plt)
 end

 if t.trans~=nil then
  palt(0,false)
  palt(t.trans,true)  
 end

 -- find texture for screen width
 local w=t.w*s.pos.z
 local h=t.h*s.pos.z
 local i=1
 local tex=t.tex[i]
 while i<#t.tex and tex.maxw<w do
  i+=1
  tex=t.tex[i]
 end

 -- draw sprite/map
 if tex.cw~=nil then 
  drawsmap(s.pos,w,h,tex,s.clp)
 else
  drawsspr(s.pos,w,h,tex,t.flipx)
 end

 pal()
 palt()
end

function applypalette(p)
 for i=1,#p.fr do
  pal(p.fr[i],p.to[i],0)
 end
end

function drawspeedo()

 -- speed to display
 local spdf=600
 local speed=player.vel.z*spdf
 local mspeed=topspd*spdf
 
 -- speedo position & radius
	local x=112
	local y=112
	local r=10
	
	-- text offset
	local tx=-5
	local ty=2
	
	-- needle range
	local mn=-.3
	local mx=.3
	local nr=r*.7
	
	-- markings
	local ds=20
	local dl=100
	local dr=r*.8
	
	-- gauge
	circfill(x,y,r+4,7)
	circfill(x,y,r+3,6)
	circfill(x,y,r+2,5)
	circfill(x,y,r,0)

 -- text
	local txt=""..ceil(speed)
	while #txt<3 do txt="0"..txt end
	print(txt,x+tx,y+ty,9)

 -- markings
 for i=0,mspeed,ds do
  local a=mn+(mx-mn)*(i/mspeed)
  pset(x-sin(a)*dr,y-cos(a)*dr,5)
 end
 for i=0,mspeed,dl do
  local a=mn+(mx-mn)*(i/mspeed)
  pset(x-sin(a)*dr,y-cos(a)*dr,6)
 end

 -- needle
 local n=mn+(mx-mn)*(speed/mspeed)
	line(x-1,y-1,x-1-sin(n)*nr,y-1-cos(n)*nr,7)
end

function drawlaps()
 drawtext("lap",1,8)
	spr(192+(player.lap-1)*2,10,0,2,2)
end

function drawleaderboard()
 local i=indexof(leaderboard,player)
 i-=1
 i=clamp(i,1,#leaderboard-2)
 for y=0,2 do
  local sy=y*7+1
  local sx=28
  local car=leaderboard[i]
  local col=6
  if(car==player)col=7
  local place=""..i
  if(i<10)place=" "..place
  drawtext(place,sx,sy,col)
  drawcarname(car,sx+12,sy)
  i+=1
 end 
end

podiumspots={"1st","2nd","3rd"}

function getpodiumspot(i)
 if(i<=#podiumspots)return podiumspots[i]
 return i.."th"
end

function drawpodium(sx,sy,ct,includeempty)
 for i=1,ct do
  if i<=#podium or includeempty then   
   local spot=getpodiumspot(i)
   drawtext(spot,sx,sy)
  end
  if i<=#podium then   
   drawcarname(podium[i],sx+18,sy)
  end
  sy+=7
 end
end

function drawcarname(car,x,y)
  local col=7
  local shadow=5
  if car~=player and car.sp.plt~=nil then
   col=car.sp.plt.to[2]
   shadow=car.sp.plt.to[1]
  end
  drawtext(car.name,x,y,col,shadow)
end

function drawtext(txt,x,y,col,shadow)
 if(col==nil)col=7
 if(shadow==nil)shadow=5
 if(col==shadow)shadow=0
 print(txt,x,y+1,shadow)
 print(txt,x,y,col)
end

function drawcenteredtext(txt,y,col,centerx)
 if(centerx==nil)centerx=64
 local x=centerx-#txt*4/2
 drawtext(txt,x,y,col)
end

function drawtunnelface(p,tnl)
 local r=gettunnelrect(p)
 local t=r.t-tnlroof*p.z

 -- render front walls
 setcliprect(clp)
 if r.l>0 then
  rectfill(
  	0,  
  	r.t,
  	r.l-1,
  	r.b-1,
  	tnl.front)
 end
 if r.r<128 then
  rectfill(
   r.r,
   r.t,
   128,
   r.b-1,
   tnl.front)
 end
 rectfill(0,t,128,r.t,tnl.front)
 
 adjustcliprect(r)
end

function drawtunnelwalls(p0,p1,tnl,seg)
 local r=gettunnelrect(p1)
 
 local coli=flr(seg/tnl.wallspacing)%#tnl.wall+1
 local col=tnl.wall[coli]

 setcliprect(clp)
 rectfill(0,0,128,r.t-1,col)
 rectfill(0,r.t,r.l-1,128,col)
 rectfill(r.r,r.t,128,128,col)
end

function gettunnelrect(p)
 return {
  l=ceil(p.x-segwid*p.z),
  r=ceil(p.x+segwid*p.z),
  t=ceil(p.y-tnlheight*p.z),
  b=ceil(p.y)
 }
end

function setcliprect(r)
 clip(r.l,r.t,r.r-r.l,r.b-r.t)
end

function adjustcliprect(r)
 -- rectangle intersection
 clp.l=max(clp.l,r.l)
 clp.r=min(clp.r,r.r)
 clp.t=max(clp.t,r.t)
 clp.b=min(clp.b,r.b)
end

function gettangent(tu,pi)
 -- simple shear
 return vec3.new(-tu*8,pi*8,1)
end

function drawsspr(pos,sw,sh,tex,flipx)
 local x0=pos.x-sw/2
 local x1=x0+sw
 local y0=pos.y-sh
 local y1=y0+sh
 x0=ceil(x0)
 y0=ceil(y0)
 x1=ceil(x1)
 y1=ceil(y1)
 sspr(
  tex.sx,
  tex.sy,
  tex.sw,
  tex.sh,
  x0,
  y0,
  x1-x0,
  y1-y0,
  flipx==true)
end

function drawsmap(pos,sw,sh,tex,cl)
 -- find top left
 local x,y=pos.x-sw/2,pos.y-sh
 
 -- clipped rectangle
 local x1=min(ceil(x+sw),cl.r)
 local y0,y1=max(ceil(y),cl.t),min(ceil(y+sh),cl.b)
 local x0=max(ceil(x),cl.l)		-- must be set last, or becomes nil somehow!

 if(x0>=x1 or y0>=y1)return
 
 -- map coordinates and deltas
 local dx,dy=tex.cw/sw,tex.ch/sh
 
 -- map coords, adjusted for clip/sub pixel correction
 local mx,my=tex.cx+dx*(x0-x),tex.cy+dy*(y0-y)

 if y1-y0<x1-x0 then
	 for y=y0,y1-1 do
	  tline(x0,y,x1-1,y,mx,my,dx,0)
	  my+=dy
	 end
 else
  for x=x0,x1-1 do
   tline(x,y0,x,y1-1,mx,my,0,dy)
   mx+=dx
  end
 end
end

-->8
-- gameplay

-- constants
carbox={
 mn=vec3.new(-.5, 0,-.2),
 mx=vec3.new( .5,.5,.2)
}
carwid=.5				-- actually half
npcct=9
carelastic=.4
autoaccel=false
npcnames={
 "jess",
 "kel",
 "tom",
 "joe",
 "hannah",
 "leah",
 "mike",
 "dick",
 "harry"
}

npctypes={}

-- variables
player={}
npcs={}
cars={}									-- all cars, including player. used for ai avoidance logic
leaderboard={}		-- cars sorted by position including lap
podium={}

function initgame()
	player={}
	npcs={}
	cars={}
	leaderboard={}
	podium={}

 initsprites()
 initplayer()
 inittrack()
 initcars()
 initrace()
 updatesprites(cam,drawsegct)
end

function initnpctypes() 
 local speeds={}
 for i=1,npcct do
  add(speeds,((i/npcct)*.45+.4)*topspd)
 end
 shuffle(speeds)
 for i=1,npcct do
  add(npctypes,
  	{
  	 name=npcnames[i],
  	 palette=carpalettes[(i-1)%#carpalettes+1],
  	 topspd=speeds[i]
  	})
 end 
end

function initplayer()
	player={
	 lap=1,
		n=1,				
		s=0,				
		pos=vec3.zero,
		vel=vec3.new(0,0,0), -- need own mutable vector! don't want to change vec3.zero.z!
		sp=nil,
		index=0,
		name="player",
		fin=false,
		topspd=topspd,    		 -- topspeed when in ai mode
		stun=0,
  steer=0
	}
end

function initcars()
	local p={n=2,s=0}
	shuffle(npctypes)	
	
	for i=0,npcct do	
	
	 -- position car
	 local x=(i%2)*2-1
	 local pos=vec3.new(x*segwid*.33,0,0)
	
	 -- create car sprite
		local sp={
		 typ=cartype,
		 pos=pos,
		 n=p.n,
		 s=p.s,
		 temp=false,
		 plt={
		  fr=carbasecols,
		  to=carpalettes[i%#carpalettes+1]
		 },
		 index=i
		}
		if i>0 then
		 sp.plt={
		  fr=carbasecols,
		  to=npctypes[i].palette
		 }
		end
		add(sprites.s,sp)
		
		if i==0 then
			player.sp=sp
			player.n=p.n
			player.s=p.s
			player.pos=pos
			add(cars,player)
			add(leaderboard,player)
		else
		 local typ=npctypes[i]
		 local npc={
		  lap=1,
 			n=p.n,
 			s=p.s,
 			pos=pos,
 			vel=vec3.new(0,0,0),
	 	 sp=sp,
	 	 topspd=typ.topspd,
	 	 index=i,
	 	 name=typ.name,
	 	 fin=false,
	 	 stun=0
 		}
 		add(npcs,npc)
 		add(cars,npc)
 		add(leaderboard,npc)
 	end
 	
 	-- advance down track
		for j=1,15 do
			advanceptr(p)
		end
	end
	
	positioncam()
	sortleaderboard()
end

function positioncam()
	copyptr(player,cam)	
	cam.pos.x*=0.85
end 

function initrace()
 doinfg(preracesequence)
end

function updategame()
 updatecars()
 updatecollisions() 
 updatesprites(cam,drawsegct)
 updateleaderboard()
 updatepodium()
 
	if(demo and btnp(Ž))setmode(mode_menu)
	if player.lap>laps then 
  democt+=1
  if demo and democt>300 then
  	setmode(mode_menu)
  end
	 if btnp(Ž) then
   -- fill out podium based on car positions
			for i=1,#leaderboard do
				local car=leaderboard[i]
				if(not car.fin)add(podium,car)
			end			   
   setmode(mode_postrace)
		end
 end 
end

function updatecars()
 sortptrs(cars)
 updateplayer()
 updatenpcs()  
end

function updateplayer()

 local fin=player.lap>laps
 
 if fin or demo then
  docarai(player)
  player.sp.typ=cartype
 else 
  doplayerinput()
 end

 updatecarsprite(player)
 if fin then 
  if(cam.pos.x>-2.7)cam.pos.x-=0.03
  if(not track[1].tnl and cam.pos.y>-5)cam.pos.y-=0.03
 else
  positioncam()
 end
end

function doplayerinput() 

 -- centrifugal force
 local t=track[player.n]
 player.vel.x=t.tu*player.vel.z*0.11
 
 -- ground friction
	if abs(player.pos.x)>segwid 
	and player.vel.z>0.05 then
	 player.vel.z-=0.0075
	 autoaccel=false
	end			  

 -- player input
 local steer=min(player.vel.z/0.075,1)
 if (btn(”) or autoaccel) and player.stun==0 then
  player.vel.z+=accel
  autoaccel=true
 else
  player.vel.z-=coast
 end
 if btn(ƒ) then
  player.vel.z-=brake
  autoaccel=false
 end
 local lbtn=btn(‹)
 local rbtn=btn(‘) 
 if(lbtn)player.steer-=0.25
 if(rbtn)player.steer+=0.25
 if(not lbtn and not rbtn)player.steer=moveto(player.steer,0,0.15)
 player.steer=clamp(player.steer,-1,1)
 player.vel.x+=0.16*player.steer*steer

 -- max speed (and don't go backwards!)
 player.vel.z=clamp(player.vel.z,0,topspd) 

 -- move player
 player.prevpos=player.pos
	player.pos+=player.vel
	if player.pos.z>=seglen then
		player.pos.z-=seglen
		advanceptr(player)
		if(player.n==1 and player.s==0)sfx(25)
	end
	
	-- clamp position
	local xlimit=cond(t.tnl,-carwid/2,carwid*3)
	local prevx=player.pos.x
	player.pos.x=clamp(player.pos.x,-segwid-xlimit,segwid+xlimit)
	player.vel.z-=abs(player.pos.x-prevx)*0.03
	
	if(player.stun>0)player.stun-=1	
	
	player.sp.typ=cartypes[clamp(flr(player.steer+2.5),1,3)]	
end

function updateleaderboard()
 sortleaderboard()
end

function updatepodium()
 for c in all(cars) do
  if not c.fin and c.lap>laps then
   c.fin=true
   add(podium,c)
  end
 end
end

function updatenpcs()
 for npc in all(npcs) do 
  docarai(npc)
  updatecarsprite(npc)
 end
end

function docarai(car)
  local z=getz(car,car.pos.z)
 
  -- horizontal range
  -- start with full road
  local h={-segwid-carwid,segwid+carwid}

  -- find current car in cars array  
  local cari=indexof(cars,car)
  local i=(cari%#cars)+1		-- look at next car
  nxtz=getrelz(cars[i],cars[i].pos.z,z)
  while nxtz>=0 and nxtz<5 
    and i~=cari do
    
   if cars[i].vel.z<car.vel.z+0.05 then
   
    -- find car x position
    local x=cars[i].pos.x
   
    -- sorted insert into horizontal array
    add(h,x)
    local k=#h
    while k>1 and h[k-1]>x do
     local temp=h[k-1]
     h[k-1]=h[k]
     h[k]=temp
     k-=1
    end  	 
   end
   i=(i%#cars)+1
   nxtz=getrelz(cars[i],cars[i].pos.z,z)
  end

  -- if no cars to avoid, steer
  -- back towards center
	 local steer=min(car.vel.z/0.075,1)
	 steer*=0.16
	 steer*=0.5
  if #h==2 then
   h[1]=-segwid/2
   h[2]= segwid/2
   steer*=0.5
  end

  -- find nearest horizontal gap
  local nx=nil
  for j=1,#h-1 do
   l=h[j]+carwid*2.75
   r=h[j+1]-carwid*2.75
   if r>l then
    local tx=clamp(car.pos.x,l,r)
			 if nx==nil
			 or abs(car.pos.x-tx)<abs(car.pos.x-nx) then
			  nx=tx
			 end
			end     
  end
  
  -- steer towards gap
  if nx~=nil then
   local d=nx-car.pos.x
   if abs(d)>steer then
   	car.vel.x=sgn(d)*steer
   else
    car.vel.x=d
   end
  else
   car.vel.x=0
  end
 
  --end
 
  -- advance car
  if car.stun>0 then
   car.vel.z-=coast
  elseif car.vel.z<car.topspd-accel then
   car.vel.z+=accel
  elseif car.vel.z>car.topspd+brake*.3 then
   car.vel.z-=brake*.3
  else
   car.vel.z=car.topspd
  end
  car.vel.z=max(car.vel.z,0)
  car.prevpos=car.pos
  car.pos+=car.vel
  if car.pos.z>seglen then
   car.pos.z-=seglen
   advanceptr(car)
  end
  
  if(car.stun>0)car.stun-=1
  
  car.sp.typ=cartypes[
   clamp(
   flr((cam.pos.x-car.pos.x)*.5+2.5),
   1,3)]  
end

function updatecarsprite(car)
  copyptr(car,car.sp)
end

function updatecollisions()

 -- loop through cars in order
 for i=1,#cars do
  local car=cars[i]
  local p0=getprevpos(car)
  local c0=getpos(car)
  local v0=vec3.copy(car.vel)
  
  -- search forward for nearby cars
  local j=(i%#cars)+1
  while j~=i and getrelz(cars[j],cars[j].pos.z,c0.z)<2 do
   local other=cars[j]
   local p1=getprevpos(other)
   local c1=getpos(other)
   local v1=vec3.copy(other.vel)

   if boxesintersect(c0,carbox,c1,carbox) then
    
    -- determine collision axes by 
    -- moving boxes back to previous 
    -- positions on each axis
    local isx=not boxesintersect(
     vec3.new(p0.x,c0.y,c0.z),carbox,
     vec3.new(p1.x,c1.y,c1.z),carbox)
    local isy=not boxesintersect(
     vec3.new(c0.x,p0.y,c0.z),carbox,
     vec3.new(c1.x,p1.y,c1.z),carbox)
    local isz=not boxesintersect(
     vec3.new(c0.x,c0.y,p0.z),carbox,
     vec3.new(c1.x,c1.y,p1.z),carbox)

    local msg=""
    if(isx)msg=msg.."x"
    if(isy)msg=msg.."y"
    if(isz)msg=msg.."z"
     
    -- if boxes were already intersecting
    -- treat every axis as a collision
    if not(isx or isy or isz) then 
     isx=true
     isy=true
     isz=true
    end
    
    -- filter out axes along which 
    -- the cars are not moving towards
    -- each other.
    isx=isx and sgn(p1.x-p0.x)~=sgn(v1.x-v0.x)
    isy=isy and sgn(p1.y-p0.y)~=sgn(v1.y-v0.y)
    isz=isz and sgn(p1.z-p0.z)~=sgn(v1.z-v0.z)

    msg=""
    if(isx)msg=msg.."x"
    if(isy)msg=msg.."y"
    if(isz)msg=msg.."z"
    
    -- adjust velocities
    local f0=(1-carelastic)/2
    local f1=(1+carelastic)/2
				if isx then
					car.vel.x  =f0*v0.x+f1*v1.x
					other.vel.x=f0*v1.x+f1*v0.x
				end
				if isy then
					car.vel.y  =f0*v0.y+f1*v1.y
					other.vel.y=f0*v1.y+f1*v0.y
				end
				if isz then
					car.vel.z  =f0*v0.z+f1*v1.z
					other.vel.z=f0*v1.z+f1*v0.z
				end
				
				if isz and car.vel.z<other.vel.z then
					car.stun=stunframes
				end
				if isz and other.vel.z<car.vel.z then
					car.stun=stunframes
				end
				
				if (isx or isy or isz)
				and (car==player or other==player) then
				 sfx(2,0)
				end
   end

   -- examine next car  
   j=(j%#cars)+1
  end   
 end
end

function sortleaderboard()
 sort(leaderboard,compareleaderboardpos) 
end

function compareleaderboardpos(a,b) 
 local r=b.lap-a.lap
 if(r==0)r=getz(b)-getz(a)
 return r
end

function preracesequence()
 printh("preracesequence")
 
 hideui=true
  
 local params={}
 local ct=4
 local texty=10
 for i=1,ct do
  local p={
   done=false,
   lit=false,
   x=56+(i-(ct+1)/2)*20,
   y=23
  }
  add(params,p)
  dodraw(function()drawstoplight(p)end)
 end
  
 local showready=true
 dodraw(function()
  while showready do
   drawcenteredtext("get ready...",texty)
   yield()
  end
 end)
  
 for i=1,ct do
  wait(30)
  for j=1,ct do
   params[j].lit=j==i
  end
  sfx(0,0)
 end
 
 for i=1,ct do
  params[i].lit=true
 end
 sfx(1,0)
 
 showready=false
 
 local stayonscreen=60
 
 doinbg(function()
  wait(stayonscreen)
  for i=1,ct do
   params[i].done=true
  end
  wait(15)
  hideui=false
  if (not demo)music(0)
 end)
 
 dodraw(function()
  for i=1,stayonscreen do
   drawcenteredtext("!!! go !!!",texty)
   yield()
  end
 end)
end

function drawstoplight(p)
 while not p.done do
  if not p.lit then
   pal(3,2)
   pal(11,8)
  end
  spr(66,p.x,p.y,2,2)
  pal()
  yield()
 end
end
-->8
-- misc

function clamp(v,lo,hi)
 return min(max(v,lo),hi)
end

function advanceptr(p)
 local ct=track[p.n].ct
 p.s+=1
 if p.s>=ct then
  p.s-=ct
  p.n+=1
  if p.n>#track then 
   p.n-=#track
   if(p.lap~=nil)p.lap+=1
  end
 end
end

function copyptr(src,dst)
 dst.n=src.n
 dst.s=src.s
 dst.pos=vec3.copy(src.pos)
end

function getseg(p)
 return track[p.n].seg+p.s
end

function getz(p,z)
 if(z==nil)z=p.pos.z
 return getseg(p)*seglen+z
end

function getrelz(p,z,reltoz) 
 local rz=getz(p,z)-reltoz
 -- wrap around
 if abs(rz)>segct*seglen/2 then
  rz-=sgn(rz)*segct*seglen
 end
 return rz
end

function getpos(p)
 return vec3.new(
  p.pos.x,
  p.pos.y,
  getz(p,p.pos.z))
end

function getprevpos(p)
 return vec3.new(
  p.prevpos.x,
  p.prevpos.y,
  getz(p,p.prevpos.z))
end  

function indexof(array,elem)
 for i=1,#array do
  if(array[i]==elem)return i
 end
 return 0
end

function sort(array,comparefn)
-- insertion sort sprites
 for i=2,#array do
	 local j=i
	 while j>1 and comparefn(array[j-1],array[j])>0 do
		 local temp=array[j-1]
 		array[j-1]=array[j]
		 array[j]=temp
 		j-=1
 	end
 end 
end

function boxesintersect(pos1,box1,pos2,box2)
 local mn1=pos1+box1.mn
 local mx1=pos1+box1.mx
 local mn2=pos2+box2.mn
 local mx2=pos2+box2.mx
 if(mx1.x<mn2.x)return false
 if(mn1.x>mx2.x)return false
 if(mx1.y<mn2.y)return false
 if(mn1.y>mx2.y)return false
 if(mx1.z<mn2.z)return false
 if(mn1.z>mx2.z)return false
 return true
end

function shuffle(array)
 for i=1,#array-1 do
  local j=i+flr(rnd(#array-i+1))
		local tmp=array[i]
		array[i]=array[j]
		array[j]=tmp
 end
end

function cond(c,a,b)
 if(c)return a
 return b
end

function moveto(v,target,delta)
 if(abs(target-v)<delta)return target
 return v+sgn(target-v)*delta
end

-->8
-- coroutines

function runbg()
 runco(bgco)
end

function runfg()
 runco(fgco)
 return #fgco~=0
end

function rundraw()
 runco(drawco)
end

function runco(co)
 for c in all(co) do
  if costatus(c)=="dead" then
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

function dodraw(fn)
 add(drawco,cocreate(fn))
end

function wait(framect)
 for i=1,framect do
  yield()
 end
end

function clearco()
 fgco={}
 bgco={}
 drawco={}
end
-->8
-- menu

mnutrack=1
mnutrackx=1
mnutracks={
 {name="country",sp=224},
 {name="city",sp=226},
 {name="desert",sp=228},
 {name="snow",sp=230}
}

function drawmenu()
 framect+=1
 
 -- background and logo
 cls(1)
 palt(0,false)
 palt(12,true)
 spr(200,28,0,4,4)
 spr(204,60,5,4,3)
 drawcenteredtext("-by mot",32)
	
 -- track selector
	local trl=56
	local trt=55
	local trs=16
	local trr=trl+trs
	local trb=trt+trs
	local trspace=26
	if mnusel==1 then
	 palt(12,true)
	 palt(0,false)
		spr(142,trl,trt,2,2)
	else
		palt()
	 palt(0,false)
	 for i=1,#mnutracks do
	  local tr=mnutracks[i]
	  local x=trl+(i-mnutrackx)*trspace
	  spr(tr.sp,x,trt,2,2)
	  rect(x-1,trt-1,x+trs,trb,cond(i==mnutrack,7,5))
	 end
	 clip()
	 palt()
	 drawcenteredtext(
	 	mnutracks[mnutrack].name,
	 	trt+25,
	 	7,
	 	trl+trs/2)
	 print("‹",10,trt+trs/2-3,7)
	 print("‘",115,trt+trs/2-3,7)
	end

 -- instructions
 drawtext("‹‘ select  Ž start",20,110,6)
end

function updatemenu()
 democt+=1
 if(btnp(‘)and mnutrack<#mnutracks)mnutrack+=1 democt=0
	if(btnp(‹)and mnutrack>1)mnutrack-=1 democt=0
 mnutrackx=moveto(mnutrackx,mnutrack,0.125)
 
 if btnp(Ž) then 
  demo=false
  stage=mnutrack
  setmode(mode_game)
 elseif democt>900 then
  demo=true
  stage=flr(rnd(#mnutracks))+1
  setmode(mode_game)
 end
end

function initpostrace()
 printh("initpostrace()")
 doinbg(function() wait(100) music(32) end)
end

function drawpostrace() 
 cls(cond(skycol==10,9,skycol))
 drawtext("race results",4,10)
 
	local t=mnutracks[stage]
	drawcenteredtext(t.name,10,7,96)
	sspr(
		(t.sp%16)*8,flr(t.sp/16)*8,
		16,16,
		80,21,
		32,32)
	rect(79,20,112,53,5)

 rectfill(4,20,50,91,1)
 drawpodium(7,22,npcct+1,true)

 local place=indexof(podium,player)
 local spot=getpodiumspot(place)
 drawcenteredtext("you placed "..spot,70,7,96) 
	 
	if place<=3 then
	 palt(12,true)
  fr={9,10,7}
  if(place==2)applypalette({fr=fr,to={5,6,7}})
  if(place==3)applypalette({fr=fr,to={4,9,7}})
		spr(142,88,80,2,2)
		pal()
	end

 drawcenteredtext("press Ž to continue",115)
end

function updatepostrace()
 if(btnp(Ž))setmode(mode_menu)
end
__gfx__
000000006556666555666666cccccccccccccccc55555555555555555555555500000000000000000000000030000000c5555555555555555555555c4445dccc
0000000066dd666666655666cccccccccccccccc555555555555555556555555000000000000000000000000300000005ff4444ff4444fff4444445544445ccc
0070070066dd556666565556cccccccccccccccc555dd55555555555555555550000000000000000000000033300000054444444444444444444455544445ccc
000770006556556665656dd5cccccccccccccccc555665555555555555555655000000000000000000000033b300000054445445555445554555555c44445ccc
0007700065566655657566d5cc6666cccccccccc555665555555555555555555000000000000000000000033b300000054ff4f4444fff44fff4f4455444445cc
007007006666665566557665cc6556cccccccccc555555555555555555555555000000000000000000000033b33000005444444444444444444444454444445c
00000000dd65566665d55556aa9999aacccccccc55555555555dd5555555655500000000000000000000033bb330000055444455554445444554555544444455
00000000dd566566566d566650444405cccccccc55555555555665555555555500000000000000000000033bb3300000c5555555555555555555555c4444445d
5666665656576566567d5665ccccc666666ccccc55555555555665555444454444444444000000000000033b33350000cccd5444ccc55ccccccccccc4444455c
65d665d556655dd665656665cccc6cc77cc6cccc55555555555555554446444444454444000000000000333bb3350000ccc54444cc5445cccccccccc444445dc
6666667566666dd666566566cccc6c5555c6cccc5555555555555555454444644444445400000000000033bbb3335000ccc54444c54ff45ccccccccc4444445c
6dd655666556666656676556aaa4444444444aaa55555555555555554444444444444444000000000003333bb3555000ccc54444c54f445ccccccccc4444455c
67d6756d5dd5666555655666999499999999499955555555dd55555544445444444444440000000000333bbb33335000cc544444c54f445ccccccccc444445dc
6666666d666d5656dd5d666544449900009944445555555566555555454444444444444400000000003b3bb333335500c5444444c54f445ccccccccc444455cc
55655666676d56566d5d6555050444000044405055555555665555554444464544444544000000000333bbbbb335350055444444c54f445ccccccccc44445dcc
7567d6565665665766566556505cccccccccc505555555555555555544544444444444440000000003333bbbb3333550d5444444c54f445ccccccccc44455ccc
666666660555655555655550c55555cc4444444444444444cc55555c5544444444544444000000005333bbbbbb333555c5544444c54f445c4444444444444444
666666d6505555055555550550550504999999999999999940505505664445544464444400000000533bbbbbbb335555cd544444c54f445c4444444444444444
666666665555505055555556505050544999999999999994450505054444466444444444000000005333bbbbb3353355c5444444c54f445c4444444444444444
66666666550055555005555550550504444444444444444440505505444446644444554400000000533bbbb333333555c5544444c54f445c5444444444444445
6d66d6665055055505505555505050544444444444444444450505054454444444456654000000000533bbbbbb333555cd544444c54f445c555444444444555d
666666665565555556555500505505044444444444444444405055054564444444467664000000000533bbbbb3333355cc554444c54f445ccd5554554445cccc
6666666605500555555550555050505444444444444444444505050546644444444466440000000005333bbb33333555ccd54444c54f445ccccd55d5555ccccc
d66d66665505505500555565c50505cccccccccccccccccccc50505c4444444554444444000000000553333333335555ccc55444c54f445cccccccccd5cccccc
77557755555655505505555500000000000000000000000000000000444444466444444400000000005533333535555054444444444444444444444500000000
77557755555555556555500500000000000000000000000000000000444444464444444400000000000555555555550054ff4455444455444444444500000000
55775577555005555555055000000000000000000000000000000000445544444444444400000000000005555550000054444444444444444444444500000000
5577557755055055005556550000000000000000000000000000000044664444445544440000000000000059440000005444444444444ff44554444500000000
77557755055655505505555000000000000000000000000000000000444444444566445400000000000000594500000054455444445554444444444500000000
7755775550555555655555050000000000000000000000000000000044444544466444640000000000000054450000005444444ff4444444444ff44500000000
55775577555500555500555600000000000000000000000000000000444446444444444400000000000000494400000054444444444444444444444500000000
557755775550550550550555000000000000000000000000000000004444444444444444000000000000000440000000c5555555555555555555555c00000000
56566767767665650000005555000000000000044444444440000000666666666666666666666666555555555555555555555555000000000000003330000000
5656676776766565000055666655000000000044444444444400000066666666666666665555555555555555555555555555555500000000000003bb33000000
5555555555555555000566555566500000000444444444444440000066655555555556664444444455666666666666666666665500000000000003bb35000000
9aaaaaaaaaaaaaa9005655333355650000004444444444444444000066611111111116664444444455666666666666666666665500000000000003bb35000000
9aa7a777777a7aa9056553bbbb35565000044444444444444444400066611111111116664444444455666666666666666666665500000000000003bb35000000
c9aaaa7777aaaa9c05653b77bbb3565000444444444444444444440066611111111116664444444455666666666666666666665500000000000003bb35000000
cc99aaaaaaaa99cc5653b7777bbb356505555555555555555555555066611111111116664444444455666666666666666666665500000000000003bb35000000
cccc99999999cccc5653b7777bbb356555555555555555555555555566611111111116664444444455666666666666666666665500000000000003bb35000000
82000028888888885653bb77bbbb3565556666666666666666666655666111111111166644444444ccccddddddddddddddddcccc00000000000003bb35000000
88000088282222285653bbbbbbbb3565556666666666666666666655666111111111166644444444ccccddddddddddddddddcccc00000000000003bb35000000
828008280800000805653bbbbbb35650556666666666666666666655666111111111166644444444ccccddddddddddddddddcccc00000000000003bb35000000
8208802800800080056553bbbb355650556666666666666666666655666111111111166644444444ccccddddddddddddddddcccc00000000000003b335000000
82088028008000800056553333556500556666666666666666666655666111111111166644444444ccccddddddddddddddddcccc00000000000003b335000000
82800828000808000005665555665000556666666666666666666655664444444444446644444444ccccddddddddddddddddcccc00000000000003b335000000
88000088222828220000556666550000556666666666666666666655664444444444446644444444cccc1111111111111111cccc00000000300003b335000000
82000028888888880000005555000000556666666666666666666655666666666666666644444444cccc1111111111111111cccc00000000330003b335000000
2820000000000282222222222222222266666666666666666666666666666666888666666666666666666888222222222222222200000000330003b335000300
2820000000000282888888888888888877777777777777777777777777777777282777777777777777777228288888888888888200000000330003b335003330
2822000000002282222222222222222277777777777777777777777777777777080755757557575575757008282222222222228200000000330003b335003b30
2828200000028282028200000000028277555557557555577557755575575577008757757557575775757080282820000002828200000000333003b335003b30
2822820000282282028200000000028277555557557555557557555575575577008755757557577575557080282282000028228200000000333333b335003350
28202820028202820028200000002820775577775575565575575567755755770007577575575755757578002820282002820282000000003333b3b335003b30
2820028228200282002820000000282077557777557557557557557775575577222777777777777777777822282002822820028200000000055333b335033350
28200028820002820002820000028200775555775575575575575557755755778886666666666666666668882820002882000282000000000005533333333350
2820002882000282000282000002820077555577557557557557755575555577888888880000000000000000282000288200028200000000000003b333333550
2820028228200282000028200028200077557777557557557557775575555577882222880000000000000000282002822820028200000000000003b333335500
28202820028202820000282000282000775577775575575575577655755755778280082800000000000000002820282002820282000000000000033355555000
2822820000282282000002820282000077557777557557557557555575575577820880280000000000000000282282000028228200000000000003b355000000
28282000000282820000028202820000775577775575575575575557755755778208802800000000000000002828200000028282000000000000033355000000
28220000000022822222222222222222777777777777777777777777777777778280082800000000000000002822000000002282000000000000033355000000
2820000000000282888888888888888877777777777777777777777777777777880000880000000000000000282000000000028200000000000003b355000000
28200000000002822222222222222222666666666666666666666666666666668200002800000000000000002820000000000282000000000000033355000000
00000000333333333333555555500000cccccccccccc6666666666cccccccccc66666666666666666666666666666666222222dddd222222cccccccccccccccc
0000033333333bb33333355533550000ccccccccccc665555555566ccccccccc6666666666666666666666666666666622222d777cd22222ccc99aa777aa99cc
003333333333bb33333bb33553355500ccccccccccc65ccc66ccc56ccccccccc666666666666666666666666666666662222d777070d2222ccc99aa777aa99cc
0333333bbb3333333333333355555500cccccccccc66ccc6776ccc66cccccccc655555555555555655555555555555552222d77777992222ccc99aa777aa99cc
3333bb3bb333333333553333553355109999cc99996599555555995699cccccc665000011000056661111111111111162222dc7779944422ccc99aa777aa99cc
333bb3333333333333333353333355515aaaa44996644566666659966aaacccc6655500110055566611111111111111622222dccccd22222cccc9aa777aa9ccc
333b33333533533bb3335553355355510599994496544566666654956999cccc66555551155555666111111111111116222222dddd222222cccc99a777a99ccc
33333335335533bb3333333355335151059999444444444444444444449999cc6655555115555566611111111111111622222d777cd22200cccc99aa7aa99ccc
03353333333333333553333555551551055aaaa444aaaaaaaaaaaaaaaa4aaaac665555511555556661111111111111162222d00777cd0002ccccc9aa7aa9cccc
05553bb3333333333355335555335510055599994499999999999999994999996655555115555566655111111111155622200577777cd202ccccc9aa7aa9cccc
05333b33555533333335555553355510550599994499999999999999994999996655555115555566655551111115555620015777777cd222cccccc9a7a9ccccc
05333333335555333555555555555100c505444444999944444444999944444464444444444444466555551111555556220d7777777cd222cccccc9a7a9ccccc
00533353335555355555335155551100c505444444999400000000499944444464444444444444466555555115555556222dc77777ccd222ccccccc979cccccc
00553555553553355555555111111000c5050000449994000000004999400000666666666666666665555551155555562222dc777ccd2222ccccccc979cccccc
00555555554455555515511110000000c55505054444440000000044440505056666666666666666655555511555555622222dccccd22222ccccc9aa7aa9cccc
00055511154444155111145510000000cc50505ccccccccccccccccccc50505c66666666666666666555555115555556222222dddd222222cccccccccccccccc
00001100005444411054455100000000cccccccccc666666666666cccccccccccccc9999999ccccc655555511555555655555555555555555555555556576565
00000000000544444554451000000000ccccccccc66555555555566ccccccccccc9999999999cccc655555511555555656666666666666666666666565676656
00000000000054444444551000000000ccccccccc65cccc66cccc56ccccccccccc9999999ff4cccc655555511555555655566666666666666666655566576566
00000000000005494445510000000000cccccccc66cccc6776cccc66cccccccccc4ffffff444cccc6555555115555556cc55555555555555555555cc66576566
00000000000005494445100000000000cc9999946599555555559956499999cccc4444444441cccc6555555115555556ccccc55555555555555ccccc66576566
00000000000005494455100000000000caaaaaa669456666666654966aaaaaaccc944444441ccccc6555555115555556ccccc66666666666666ccccc66576566
00000000000000544451000000000000c999999654456666666654456999999cc99944444999cccc4444444444444444ccccc66666666666666ccccc66576566
00000000000000594451000000000000c999999444444444444444444999999cc4ff999999ff4ccc4444444444444444ccccc66666666666666ccccc66576566
00000000000000544451000000000000aaaaaaa4aaaaaaaaaaaaaaaa4aaaaaaac444ffffff444ccc0000000000000000ccccc66666666666666ccccc66576566
0000000000000054945100000000000099999994999999999999999949999999cc4444444441cccc0000000000000000ccccc66666666666666ccccc66576566
0000000000000054945100000000000099999994999999999999999949999999cc14444444199ccc0000000000000000ccccc66666666666666ccccc66576566
0000000000000054445100000000000044444444999944444444999944444444ccc144411999994c0000000000000000ccccc66666666666666ccccc66576566
0000000000000054445100000000000044444444999400000000499944444444ccc99999999ff44c0000000000000000ccccc66666666666666ccccc66576566
00000000000000594451000000000000c000000499940000000049994000000cccc44ffffff4444c0000000000000000ccccc66666666666666ccccc66576566
00000000000000544455100000000000c050505c4444000000004444c505050cccc444444444441c0000000000000000ccccc66666666666666ccccc66576566
00000000000005450545510000000000c505050cccccccccccccccccc050505ccccc1144444111cc0000000000000000ccccc66666666666666ccccc66576566
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccc777cccccccccccccccccccccccccc
0000000770000000000000777700000000007777770000000000000000000000ccccccccccccccccccccccccccccccccccc77ccccccccccccccccccccccccccc
0000007770000000000007777770000000007777777000000000000000000000ccccccccccccccbaabccccccccccccccccc77ccccccccccccccccccccccccccc
0000077770000000000077777777000000005555777700000000000000000000ccccccccccccccaaaacccccccccccccccc77cccc77cccc77cccc777cccc77ccc
0000777770000000000077755777000000000000577700000000000000000000cccccccccccccaaaaaaccccccccccccccc77cccc777cc7777cc77ccccc77777c
0000555770000000000055500777000000000000077700000000000000000000ccccccccccccbaaaaaabcccccccccccccc77ccc77c7cc7cc7cc7777ccc7cc77c
0000000770000000000000000777000000000777777500000000000000000000ccccccccccccaaaaaaaaccccccccccccc777ccc77c7cc7cc7ccc777ccc7777cc
0000000770000000000000007777000000000777777000000000000000000000cccccccccccaaaaaaaaaacccccccccccc77777c7777cc7777ccccc77cc77cccc
0000000770000000000000077775000000000555577700000000000000000000ccccccccccbaaaaaaaaaabccccccccccc77777cc77cccc77ccc7777cccc7777c
0000000770000000000000777750000000000000077700000000000000000000ccccccccccaaaaaaaaaaaacccccccccccccccccccccccccccccccccccccccccc
0000000770000000000007777500000000000000777700000000000000000000cccccccccaaaaaaaaaaaaaaccccccccccccccccccccccccccccccccccccccccc
0000777777770000000077777777000000007777777500000000000000000000ccccccccbaaaaaaaaaaaaaabccccccccccc7777ccccccccccccccccccccccc7c
0000777777770000000077777777000000007777775000000000000000000000cccccccca9aaaaaaaaaaaaaacccccccccc77cccccccccccccccccccccccccc7c
0000555555550000000055555555000000005555550000000000000000000000cccccccaa00aaaaaaaaaaaaaacccccccc77ccccccccccccccccccccccccccc7c
0000000000000000000000000000000000000000000000000000000000000000ccccccba9009aaaaaaaa00aaabccccccc77cccccc7c7cc77c7c7cc7cc777cc7c
cccccccccccccccc1111115666656666aaaa77aaaaaaaaaaccccccddddccccccccccccaaa000aaaaaaaa00aaaaccccccc77cc777c77cc7cc77c7cc7c7cc7c77c
cccccccccccccccc28282156dd656666aaa7777aaaaaaaaacccccd777cdccccccccccaaaa9009aaaaaaaaaaaaaacccccc777cc77c7ccc7ccc7cc7c7c7777c7cc
777777777777777711118156dd656555aaa7777aaaaaaaaac3ccd777070dccccccccbaaaaa000aaaaaa0aaaaaaabcccccc77cc7cc7ccc7cc77cc7c7c7cccc7cc
7777777cc1777777dddd2d5666656dddaaaa77aaaaaaaaaac3ccd7777799ccccccccaaaaaa4009aaaa90aaa00aaaccccccc7777cc7cccc77c7ccc7ccc77c77cc
33333335663333335ddd8d5666656dddaaaaaaaaaaa3aaaa333cdc77799444ccccca90000000000aaa00aaa00aaaaccccccccccccccccccccccccccccccccccc
33333b33666633335ddd2d56dd656dddaaaaaaaaaa33aaaa333ccdccccdcccccccba0000000aa000aa04aa9aaaaaabcccccccccccccccccccccccccccccccccc
3333b4b35666663355dd8d56dd656666aaaaaaaaaa35aaaa747777dddd777722cca40000009aa900a909a0aaaaaaaacccccccccccccccccccccccccccccccccc
333334333666666655dddd5666656666999999999935999977777d777cd77700caa00000000aa000a00409aaaaaaaaaccccccccccccccccccccccccccccccccc
3333333335666666555ddd566665666699999999393593997777d00777cd0007ba40000000000000a0000aaaa00aaaab00000000000000000000000000000000
3344444433666666555ddd56dd656666499999993335939977700577777cd707aaaaaaaaaa44444a90004900a00aaaaa00000000000000000000000000000000
34444444435666665555dd56dd656666444999999533339970015777777cd777aaaaaaaaaa00000a0000004aaaaaaaaa00000000000000000000000000000000
33666666333666665555dd56666565554444499999355999770d7777777cd777aaaaaaaaaa00000a00009aaaaaaaaaaa00000000000000000000000000000000
336d65663335666655555dddddd56ddd4944444999359999777dc77777ccd777caaaaaaaaaaaaaaaaaaaaaaaaaaaaaac00000000000000000000000000000000
336665663333666655555dddddd56ddd44494444499999997777dc777ccd7777cccccccccccccccccccccccccccccccc00000000000000000000000000000000
3333333333335666555555ddddd56ddd444444944449999977777dccccd77777cccccccccccccccccccccccccccccccc00000000000000000000000000000000
3333333333333666555555ddddd566664944444444444999777777dddd777777cccccccccccccccccccccccccccccccc00000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00444545454545454546000000004a4b4b4b4b4b4b4b4b4c00acadadadadadadae0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44454545454545454545460000005455555555555555555600bc555555555555be0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0054474855474855495600000000544748554748554748565a5b5b5b5b5b5b5b5b5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005457585557585559560000000054575855575855575856bc8889af8a8baf8889be00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005455555555555559560000000054555555555555555556bc9899bf9a9bbf9899be00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6c62636263626362636263626354555555555555555556bc5555bfaaabbf5555be00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7b7c727372737273727372737273544748554748554748564445454545454545460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626465666763626465666763545758555758555758560054555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727475767773727475767773545555555555555555560054474855474856000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061000000000000000000000000545555555555555555560054575855575856000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000544748554748554748560054555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061000000000000000000000000545758555758555758560054555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000545555555555555555560054474855494956000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
785151515151511f2f2e2f2e2f2e545555555555555555560054575855595956000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5068696a68696a0f2c0000000000544748554748554949560054555555595956000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
500000000000001f1c0000000000545758555758555959560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
500000000000000f2c0000000000545555555555555959560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001c0000000000545555555555555959560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0000000000000000000000001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d0000000000000000000000002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0d0d0d0d0d0d0d0d0d0d0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0d0d0d0d0d0d0d0d0d0d0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0d0d0d0d0d0d0d0d0d0d0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0d0d0d0d0d0d0d0d0d0d0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d00001d0000000000001d00002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d00003c3d3d3d3d3d3d3e00002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d00003c3d3d3d3d3d3d3e00002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d00002d0000000000002d00002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d00002d0000000000002d00002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d00002d0000000000002d00002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7501f7401f7301f7201f7100070000700007000070000700007000070000700007000070000700007000070000700
000300002b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7502b7402b7402b7402b7402b7302b7302b7302b7302b7302b7202b7202b7202b7202b7102b700
0002000023650266402a640216402064026640296302763021630256302a630276202261000610006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010c0000180551805518025180551c0551d0551f0501c025180551805518025180551c0551d0551f0501c025180551805518025180551c0551d0551f0501c025180551805518025180551c0551d0551f0501c025
010c0000150551505515035150551a0551c0551c05018025150551505515035150551a0551c0551c05018025150551505515035150551a0551c0551c05018025150551505515035150551a0551c0551c05018025
010c00001a0551a0551a0351a0551d0551f055210501d0251a0551a0551a0351a0551d0551f055210501d0251a0551a0551a0351a0551d0551f055210501d0251a0551a0551a0351a0551d0551f055210501d025
010c0000130551305513035130551c0551d0551f0501c025130551305513035130551c0551d0551f0501c025130551305513035130551c0551d0551f0501c025130551305513035130551c0551d0551f0501c050
010c00000c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c7550c7520c755
010c00000975209755097520975509752097550975209755097520975509752097550975209755097520975509752097550975209755097520975509752097550975209755097520975509752097550975209755
010c00000e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e7550e7520e755
010c00000775207755077520775507752077550775207755077520775507752077550775207755077520775507752077550775207755077520775507752077550775207755077520775507752077550775207755
010c00001f143286001f1432f6002465524615246153c6001f143286001f1432f6002465524615246153c6041f143286001f1432f6002465524615246153c6041f1431f3031f1432961424655246151c3231c323
010c00001f143286001f1432f6002465524615246153c6001f143286001f1432f6002465524615246153c6041f143286001f1432f6002465524615246153c6041f1431c3231f1431c32324655246352464524655
010c00001f0501f0551c0501c0501c0501c0501c0501c0501c0501c0501c0501c05521000210002100021000210002100021000210001a0501a0551c0501c0501c0501c0551a0501a05518050180551a0501a055
010c00001c0501c0551505015050150501505015050150501505015050150501505521000210002100021000210002100021000210001c0501c0551c0501c0501c0501c0551a0501a05518050180551a0501a055
010c000021050210551d0501d0501d0501d0501d0501d0501d0501d0501d0501d05521000210002100021000210002100021000210001c0501c0551d0501d0501d0501d0551c0501c0551a0501a0551c0501c055
010c00001a0501a055130501305013050130501305013050130501305013050130501305013050130501305013040130401304013040130301303013030130301302013020130201302013010130101301013010
010c0000307102b710307102b710307102b710307102b710307102b710307102b710307102b710307102b71030710327103471032710307103271034710327103071032710347103271030710327103471032710
010c00002d710287102d710287102d710287102d710287102d710287102d710287102d710287102d710287102d7102f710307102d7102d7102f710307102d7102d7102f710307102d7102d7102f710307102d710
010c0000327102d710327102d710327102d710327102d710327102d710327102d710327102d710327102d71032710347103571034710327103471035710347103271034710357103471032710347103571034710
010c00002f7102b7102f7102b7102f7102b7102f7102b7102f7102b7102f7102b7102f7102b7102f7102b710377102b7102f710357102b7102f7102b710347102b71028710297103471035710347103271030710
010c00001f143286001f1432f6002465524615246153c6001f143286001f1432f6002465524615246153c6041f143286001f1432f6002465524615246153c6041f143286001f1432f60024655246152462524615
010c0000187651a7651c765187651a7651c7651d7651a7651c7651d7651f7651c7651d7651f7652176523765247651f765217651f76522765217651f7651d7651f7651d7651c7651a76518765007052476500705
010c0000247051c2001c2001c200000000000000000000001a2001a2001c200000001a2001a20000000000001c2001c2001c2001c20000000000001c2001c2001c2001c200000000000000000000002872500000
010c00001f2001f2001f2001f200000000000000000000001d2001d20000000000001d2001d20000000000001f2001f2001f2001f20000000000001f2001f2001f2001f200000000000000000000002b72500000
010800001f7751d7751f7752377524770247702477024775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 03 43 44
00 41 04 43 44
00 41 05 43 44
00 41 06 43 44
00 41 03 07 44
00 41 04 08 44
00 41 05 09 44
00 41 06 0a 44
01 41 03 07 15
00 41 04 08 0b
00 41 05 09 15
00 41 06 0a 0c
01 41 03 0d 15
00 41 04 0e 0b
00 41 05 0f 15
00 41 06 10 0c
00 41 03 0d 15
00 41 04 0e 0b
00 41 05 0f 15
00 41 06 10 0c
00 41 03 43 15
00 41 04 43 0b
00 41 05 43 15
00 41 06 43 0c
00 41 03 11 15
00 41 04 12 0b
00 41 05 13 15
00 41 06 14 0c
00 41 03 11 15
00 41 04 12 0b
00 41 05 13 15
02 41 06 14 0c
04 41 16 17 18
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
