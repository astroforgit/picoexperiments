pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- breakalt
-- by fishdollars

---- goals ----

--13.sound
-- high score music
--	game won fanfare
-- sfx channels


function _init()
	cartdata("breakalt_save")
	cls()
	screenbox={left=127,
												right=0,
												top=140,
												bottom=7}
	
	mode="start"
	level=""
	debug=""
	levelnum=1
	shaketoggle=true
	shake=0
	startlives=3
	blink_g=7
	blink_g_i=1
	blink_grey=7
	blink_grey_i=1
	blink_b=7
	blink_b_i=1
	blink_w=7
	blink_w_i=1
	blinkframe=0
	blinkspeed=10
	
	fadeperc=1
	
	startcountdown=-1
	govercountdown=-1
	goverrestart=false
	arrm=1
	arrm2=1
	arrmframe=0
	
	--particles
	part={}
	
	lasthitx=0
	lasthity=0
	
	--highscore
	hs={}
	hs1={}
	hs2={}
	hs3={}
	hsb={true,false,false,false,false}
	loadhs()
--	reseths()
	hschars={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
	hs_x=128
	hs_dx=128
	loghs=false
	--typing in initials
	nitials={1,1,1}
	nit_sel=1
	nit_conf=false
	--sash
	sash_w=0
	sash_dw=0
	sash_tx=0
	sash_tdx=0
	sash_c=8
	sash_tc=7
	sash_text="hi"
	sash_frames=0
	sash_v=false
	sash_delay_w=0
	sash_delay_t=0
	
	--infinite loop protection
	infcounter=0
	
	--sick messages
	sick={
							"so sick!",
							"nice!",
							"holy h e double chili dogs!",
							"godlike!!",
							"unstoppable!",
							"have my babies!",
							"i can't feel my legs!"
						}

	levels={}
	loadlevels()
	
	-- music
	music(0)
end

function startgame()
	levelnum=1
	levelnam=1
	level=levels[levelnum]
	name=names[levelnam]
	restartlevel()
end

function restartlevel()
	mode="game"
	ball_r=2
	ball_dr=0.5
	ball_col=10
	
	pad_x=64
	pad_y=120
	pad_dx=0
	pad_wo=24 --original width
	pad_w=24  --current width
	pad_h=6

	brick_w=9
	brick_h=4

	buildbricks(level)

	lives=startlives
	points=0
	sticky=false

	chain=1 --combo multiplier
	
	timer_mega=0
	timer_slow=0
	timer_expand=0
	timer_reduce=0

	showsash("stage "..levelnum..name,0,7,7)
	serveball()
end

function nextlevel()
	mode="game"
	pad_x=64
	pad_y=120
	pad_dx=0

	levelnum+=1
	levelnam+=1
	lives+=1
	if levelnum>#levels then
		--game finished screen
		wingame()
		return
	end
	level=levels[levelnum]
	name=names[levelnam]
	buildbricks(level)

	chain=1 --combo multiplier
	sticky=false
	
	showsash("stage "..levelnum..name,0,7,7)
	serveball()
end

function buildbricks(lvl)
	local i,j,o,chr,last
	bricks={}

	j=0
	-- b = normal brick
	-- x = empty space
	-- i = indestructible
	-- h = hardened brick
	-- s = sploding brick
	-- p = powerup brick
	for i=1,#lvl do
 	j+=1
 	chr=sub(lvl,i,i)
		if chr=="b" 
		or chr=="i" 
		or chr=="h" 
		or chr=="j" 
		or chr=="s"
		or chr=="p" then
			last=chr
			addbrick(j,chr)
		elseif chr=="x" then
			last="x"
		elseif chr=="/" then
			j=(flr((j-1)/11)+1)*11
		elseif chr>="1" and chr<="9" then
			--debug=chr
			for o=1,chr+0 do
				if last=="b" 
				or last=="i" 
				or last=="h" 
				or last=="j" 
				or last=="s"
				or last=="p" then
				addbrick(j,last)
				elseif last=="x" then
				--nothing 
				end		
				j+=1
			end
			j-=1
		end
	end
end

function resetpills()
	pill={}
end

function addbrick(_i,_t)
	local _brick
	_b={}
	_b.x=4+((_i-1)%11)*(brick_w+2)
	_b.y=11+flr((_i-1)/11)*(brick_h+2)
	_b.v=true
	_b.t=_t
	_b.fsh=0
	_b.ox=-(80+rnd(64))
	_b.oy=-(80+rnd(64))
	_b.dx=rnd(64)
	_b.dy=rnd(64)
	
	add(bricks,_b)
end

function levelfinished()
	if #bricks==0 then
		return true 
	end
	for i=1,#bricks do
		if bricks[i].v==true and bricks[i].t!="i" then
			return false
		end
	end
	return true
end

function serveball()
	ball={}
	ball[1]=newball()
	
 ball[1].x=pad_x
 ball[1].y=pad_y-ball_r
 ball[1].dx=1
 ball[1].dy=-1
 ball[1].ang=1
 ball[1].stuck=true
 
 pointsmult=#ball
 chain=1
 timer_mega=0
	timer_slow=0
	timer_expand=0
	timer_reduce=0
	
 resetpills()
	 
	sticky_x=0
	sticky=false
	
	ball_col=10
end

function newball()
	b={}
	b.x=0
	b.y=pad_y-ball_r
	b.dx=0
	b.dy=0
	b.ang=1
	b.stuck=false
	b.rammed=false
	return b
end

function copyball(ob)
	b={}
	b.x=ob.x
	b.y=ob.y
	b.dx=ob.dx
	b.dy=ob.dy
	b.ang=ob.ang
	b.stuck=ob.stuck
	b.rammed=ob.rammed
	return b
end

function setang(bl,ang)
	bl.ang=ang
	if ang==2 then
		bl.dx=0.50*sign(bl.dx)
		bl.dy=1.30*sign(bl.dy)
	elseif ang==0 then
		bl.dx=1.30*sign(bl.dx)
		bl.dy=0.50*sign(bl.dy)
	else
		bl.dx=1*sign(bl.dx)
		bl.dy=1*sign(bl.dy)
	end
end

function multiball()
	local ballnum=flr(rnd(#ball))+1
	local ogball=ball[ballnum]
	
	ball2=copyball(ogball)
	
	if ogball.ang==0 then
		setang(ball2,2)
	elseif ogball.ang==1 then
		setang(ogball,0)
		setang(ball2,2)
	else
		setang(ball2,0)	
	end
	
	ball2.stuck=false
	ball[#ball+1]=ball2
end

function sign(n)
	if n<0 then
		return -1
	elseif n>0 then
		return 1
	else
		return 0
	end
end

function gameover()
	mode="gameoverwait"
	govercountdown=60
	blinkspeed=16
	resethsb()
end

function levelover()
	sfx(-2,1)
	mode="leveloverwait"
	govercountdown=60
	blinkspeed=16
end

function wingame()
	mode="winnerwait"
	govercountdown=60
	blinkspeed=16
		
	--find out if player made hs
	if points>hs[5] then
		loghs=true
		nit_sel=1
		nit_conf=false
	else
		loghs=false
		resethsb()
	end
end

function releasestuck()
	for i=1,#ball do
		local _b=ball[i]
		if _b.stuck then
			_b.x=mid(3,_b.x,124)
			_b.stuck=false
		end
	end
end

function pointstuck(sign)
	for i=1,#ball do
		local _b=ball[i]
		if _b.stuck then
			_b.dx=abs(_b.dx)*sign
		end
	end
end

function powerupget(_p)
	if _p==1 then
		--slowdown
		timer_slow=400
		showsash("slow!",0,9,9)
	elseif _p==2 then
		--life
		lives+=1
		showsash("extra life!",0,6,6)
	elseif _p==3 then
		--catch
		--check for stuck balls
		hasstuck=false
		for i=1,#ball do
			if ball[i].stuck then
				hasstuck=false
			end
		end
		if hasstuck==false then
			sticky=true
		end
		showsash("sticky paddle!",0,11,11)
	elseif _p==4 then
		--expand
		timer_expand=900
		timer_reduce=0
		showsash("expand!",0,12,12)
	elseif _p==5 then
		--reduce
		timer_reduce=900
		timer_expand=0
		showsash("reduce for 2x score!",0,7,7)
	elseif _p==6 then
		--megaball
		timer_mega=300
		showsash("megaball!",0,14,14)
	elseif _p==7 then
		--multiball
		multiball()
		showsash("multiball!",0,8,8)
	end
end

function hitbrick(_b,_combo)
	local fshtime=8
	--brick
	if _b.t=="b" then
		infcounter=0
		sfx(2+chain)
		--spawn particles
		shatterbrick(_b,lasthitx,lasthity)
		_b.fsh=fshtime
		_b.v=false
		if _combo then
			getpoints(10)
			boostchain()
		end
	--indestructible brick
	elseif _b.t=="i" then
		sfx(10)
	--hardened brick
	elseif _b.t=="h" or _b.t=="j" then
		infcounter=0
		if timer_mega>0 then
			shatterbrick(_b,lasthitx,lasthity)
			sfx(2+chain)
			_b.fsh=fshtime
	 	_b.v=false
			if _combo then
				getpoints(10)
				boostchain()
			end
		else
			sfx(21)
--			shatterbrick(_b,lasthitx,lasthity)
			if _b.t=="h" then
				shatterbrick(_b,lasthitx,lasthity)
			 _b.t="j"
			elseif _b.t=="j" then
				shatterbrick(_b,lasthitx,lasthity)
				_b.t="b"				
			end
		end
	--powerup brick
	elseif _b.t=="p" then
		infcounter=0 
		sfx(2+chain)
		--spawn particles
		shatterbrick(_b,lasthitx,lasthity)
		_b.fsh=fshtime
		_b.v=false
		if _combo then
			getpoints(10)
			boostchain()
		end
		spawnpill(_b.x,_b.y,1)
	--exploding brick
	elseif _b.t=="s" then
		infcounter=0
		sfx(12)
		_b.t="zz"
		if _combo then
			getpoints(10)
			boostchain()
		end
	end
end

-- increase chain by 1
function boostchain()
	if chain==6 then
		local _si=1+flr(rnd(#sick))
		showsash(sick[_si],12,0,1)
	end
		chain+=1
		chain=mid(1,chain,7)
end

--get points
function getpoints(_p)
	if timer_reduce<=0 then
		points+=(_p*chain)*pointsmult
	else
		points+=((_p*chain)*pointsmult)*2
	end
end

function spawnpill(_x,_y)
	local _t,_pill
	
	_t=flr(rnd(7))+1
--	_t=flr(rnd(2))
--	if _t==0 then
--		_t=3
--	else
--		_t=3
--	end
	
	_pill={}
	_pill.x=_x
	_pill.y=_y
	_pill.t=_t
	add(pill,_pill)

end

function checkexplosions()
	for i=1,#bricks do
		local _b=bricks[i]
		if _b.t=="zz" and _b.v then
			_b.t="z"
		end
	end
	
	for i=1,#bricks do
		local _b=bricks[i]
		if _b.t=="z" and _b.v then
			explodebrick(i)
			spawnexplosion(_b.x,_b.y)
			if shake<0.4 then
				shake+=0.1
			end
		end
	end
	
	for i=1,#bricks do
		if bricks[i].t=="zz" then
			bricks[i].t="z"
		end
	end
end

function explodebrick(_i)
	bricks[_i].v=false
	for j=1,#bricks do
		local _bj,_bi=bricks[j],bricks[_i]
		if j!=_i
		and _bj.v
		and abs(_bj.x-_bi.x)<=(brick_w+2)
		and abs(_bj.y-_bi.y)<=(brick_w+2)
		then
			hitbrick(_bj,false)
		end
	end
end

function box_box(box1_x,box1_y,box1_w,box1_h,box2_x,box2_y,box2_w,box2_h)
	--checks for a collision boxes
	if box1_y>box2_y+box2_h then return false end
	if box1_y+box1_h<box2_y then return false end
	if box1_x>box2_x+box2_w then return false end
	if box1_x+box1_w<box2_x then return false end
	return true
end
-->8
---- juicy stuff ----

function showsash(_t,_c,_tc,_bc)
	sash_w=0
	sash_dw=4
	sash_c=_c
	sash_text=_t
	sash_frames=0
	sash_v=true
	sash_tx=-(#sash_text*4)
	sash_tdx=64-(#sash_text*2)
	sash_delay_w=0
	sash_delay_t=5
	sash_tc=_tc
	sash_bc=_bc
end

function toggleshake()
	if shaketoggle==true then
		shaketoggle=false
		showsash("screenshake turned off",0,7,7)
	elseif shaketoggle==false then
		shaketoggle=true
		showsash("screenshake turned on",0,7,7)
	end
	sfx(14)
end

menuitem(3,"screenshake y/n",toggleshake)

function doshake()
-- -16 +16
	local shakex=16-rnd(32)
	local shakey=16-rnd(32)
	
	if shaketoggle==true then
		shakex=shakex*shake
		shakey=shakey*shake
	else
		shakex=0
		shakey=0
	end
	
	camera(shakex,shakey)
	
	shake=shake*0.95
	if shake<0.05 then
		shake=0
	end
end


function doblink()
	local g_seq,grey_seq,b_seq,w_seq={0,3,11,11,11,11,3},{0,5,6,7,7,7,6,5},{11,3,0,0,0,0,3},{7,6,5,0,0,0,5,6}
	
	blinkframe+=1
	arrmframe+=1
	
	--text blinking
	if blinkframe>blinkspeed then
		blinkframe=0
		
		blink_g_i+=1
		if blink_g_i>#g_seq then
			blink_g_i=1
		end
		blink_g=g_seq[blink_g_i]
		
		blink_grey_i+=1
		if blink_grey_i>#grey_seq then
			blink_grey_i=1
		end
		blink_grey=grey_seq[blink_grey_i]
		blink_g_i+=1
		
		blink_b_i+=1
		if blink_b_i>#b_seq then
			blink_b_i=1
		end
		blink_b=b_seq[blink_b_i]
		
		blink_w_i+=1
		if blink_w_i>#w_seq then
			blink_w_i=1
		end
		blink_w=w_seq[blink_w_i]
	end
	
	--arrow animation
	arrmframe+=1
	if arrmframe>75 then
		arrmframe=0
	end
	arrm=1+(1*(arrmframe/50))
	local af2=arrmframe+15
	if af2>75 then
		af2=af2-75
	end
	arrm2=1+(1*(af2/50))
end

function fadepal(_perc)
 local p=flr(mid(0,_perc,1)*100)
 local kmax,col,dpal,j,k

 dpal={0,1,1, 2,1,13,6,
          4,4,9,3, 13,1,13,14}
 
 for j=1,15 do
  col = j
  kmax=(p+(j*1.46))/22
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

--particle stuff

--add particle
function addpart(_x,_y,_dx,_dy,_type,_maxage,_col,_s)
	local _p={}
	_p.x=_x
	_p.y=_y
	_p.dx=_dx
	_p.dy=_dy
	_p.tpe=_type
	_p.mage=_maxage
	_p.age=0
	_p.col=0
	_p.rot=0
	_p.rottimer=0
	_p.s=_s
	_p.os=_s
	
	_p.colarr=_col
	add(part,_p)
end


--raining particles
function spawnbgparts()
	addpart(flr(rnd(128)),0,0.1,0.5+rnd(1),0,1+rnd(200),{11,3,3},0)
	addpart(flr(rnd(128)),0,-0.1,0.5+rnd(1),0,1+rnd(200),{11,3,3},0)
end

function spawnpadparts()
	for i=0,1 do
		addpart(flr(rnd(pad_w-4)+(pad_x-((pad_w-4)/2))),pad_y+4,0,0.1+rnd(1),0,1+rnd(30),{14,14,14,12,8,9,10},0)
		addpart(flr(rnd(pad_w-4)+(pad_x-((pad_w-4)/2))),pad_y+4,0,0.1+rnd(1),0,1+rnd(30),{14,14,14,12,8,9,10},0)
	end
end

function spawnendparts()
	if loghs then
		_tr=20
		_br=112
	else
		_tr=33
		_br=100
	end
	for i=0,3 do
		local _rnd=rnd(128)
		addpart(_rnd,_tr-6,0.1,-0.1-rnd(0.5),0,1+rnd(20),{11,3,3},0)
		addpart(_rnd,_tr-4,-0.1,-0.1-rnd(0.5),0,1+rnd(20),{11,3,3},0)
		addpart(_rnd,_tr-rnd(4),0,0,0,1+rnd(70),{11},0)
		addpart(_rnd,_tr-rnd(2),0,0,0,1+rnd(120),{11},0)
	
		addpart(_rnd,_br+6,0.1,0.1+rnd(0.5),0,1+rnd(20),{11,3,3},0)
		addpart(_rnd,_br+4,-0.1,0.1+rnd(0.5),0,1+rnd(20),{11,3,3},0)
		addpart(_rnd,_br+rnd(4),0,0,0,1+rnd(70),{11},0)
		addpart(_rnd,_br+rnd(2),0,0,0,1+rnd(120),{11},0)
	end
end

--spawn small wall puft
function spawnpuft(_x,_y)
	for i=0,6 do
		local _ang=rnd()
		local _dx=sin(_ang)*(0.1+rnd(1))
		local _dy=cos(_ang)*(0.1+rnd(1))
		addpart(_x,_y,_dx,_dy,2,30+rnd(30),{6,5},1+rnd(2))
	end
end

--spawn powerup puft
function spawnpillpuft(_x,_y,_p)
	for i=0,15 do
		local _ang=rnd()
		local _dx=sin(_ang)*(0.3+rnd(2))
		local _dy=cos(_ang)*(0.3+rnd(2))
		local _mycol

		if _p==1 then
			--slowdown
			_mycol={9,9,4,4,5}
		elseif _p==2 then
			--life
			_mycol={7,7,6,5,5}
		elseif _p==3 then
			--catch
			_mycol={11,11,3,3,5}
		elseif _p==4 then
			--expand
			_mycol={12,12,13,13,5}
		elseif _p==5 then
			--reduce
			_mycol={5,5,5,6,6}
		elseif _p==6 then
			--megaball
			_mycol={14,14,2,2,5}
		else
			--multiball
			_mycol={8,8,4,4,5}
		end

		addpart(_x,_y,_dx,_dy,2,45+rnd(30),_mycol,1+rnd(3))
	end
end

--spawn death particles
function spawndeath(_x,_y)
	for i=0,20 do
		local _ang=rnd()
		local _dx=sin(_ang)*(1+rnd(1))
		local _dy=cos(_ang)*(1+rnd(1))
		local _mycol={10,10,9,4,5}

		addpart(_x,_y,_dx,_dy,2,80+rnd(30),_mycol,2+rnd(4))
	end
end

--spawn explosion particles
function spawnexplosion(_x,_y)
--	first smoke
	for i=0,15 do
		local _ang=rnd()
		local _dx=sin(_ang)*(0.5+rnd(2))
		local _dy=cos(_ang)*(0.5+rnd(2))
		local _mycol={0,0,5,5,6,0}

		addpart(_x,_y,_dx,_dy,2,60+rnd(30),_mycol,2+rnd(4))
	end
	--fireball
	for i=0,10 do
		local _ang=rnd()
		local _dx=sin(_ang)*(0.1+rnd(1))
		local _dy=cos(_ang)*(0.1+rnd(1))
		local _mycol={1,10,9,8,5}

		addpart(_x,_y,_dx,_dy,2,20+rnd(30),_mycol,1+rnd(4))
	end	
end

--spawns trail particles
function spawntrail(_x,_y)
	if rnd()<0.6 then
 	local _ang=rnd()
 	local _ox=sin(_ang)*ball_r*0.6
 	local _oy=cos(_ang)*ball_r
 	
 	addpart(_x+_ox,_y+_oy,0,0,0,10+rnd(15),{10,9},0)
	end
end

--spawns mega trail particles
function spawnmtrail(_x,_y)
	spawnpadparts()
	local _ang=rnd()
	local _ox=sin(_ang)*ball_r
	local _oy=cos(_ang)*ball_r	
	addpart(_x+_ox,_y+_oy,0,0,2,45+rnd(15),{5,12,12,12,14,14,14,8,9,10},1+rnd(2))
end

--shatter brick
function shatterbrick(_b,_vx,_vy)
	--screenshake
	if shake<0.5 then
		shake+=0.05
	end
	--bump the brick
	_b.dx=_vx/5
	_b.dy=_vy/5
	--make particles
	if timer_mega<=0 then
		for _x=0,brick_w*0.8 do
			for _y=0,brick_h*0.8 do
				local _ang=rnd()
		 	local _dx=sin(_ang)*rnd(1)+(_vx/2)
		 	local _dy=cos(_ang)*rnd(1)+(_vy/2)
				local _mycol={11,11,11,3,5}
				
		 	if _b.t=="p" then
		 		_mycol={12,12,12,13,5}
				end
				if _b.t~="h" and _b.t~="j" then
					addpart(_b.x+_x,_b.y+_y,_dx,_dy,1,80,_mycol,0)
				end
				if _b.t=="h" and timer_mega>0 then
					addpart(_b.x+_x,_b.y+_y,_dx,_dy,1,80,_mycol,0)
				end
			end
		end
	end

	local chunks=5+flr(rnd(4))
	if chunks>0 then
		for i=1,chunks do
			local _ang=rnd()
			local _dx=sin(_ang)*rnd(1)+(_vx/2)
			local _dy=cos(_ang)*rnd(1)+(_vy/2)
			local _spr=32+flr(rnd(16))
			local _ptpe=3
			
			if _b.t=="p" then
				_spr=32+flr(rnd(8))
				_ptpe=4
			end
			addpart(_b.x,_b.y,_dx,_dy,_ptpe,70,{_spr},0)
		end		
	end	
	
end
--particles
-- type 0 = static
-- type 1 = gravity pixel
-- type 2 = ball of smoke
-- type 3 = brick shell sprite
-- type 4 = powerup shell sprite

--big particle updater
function updateparts()
	for i=#part,1,-1 do
		local _p=part[i]
		_p.age+=1
		if _p.age>_p.mage or _p.x<-20 or _p.x>148 or _p.y<-20 or _p.y>148 then
			del(part,_p)
		else
			if #_p.colarr==1 then
				_p.col=_p.colarr[1]
			else
				--change colours
				local _ci=_p.age/_p.mage
				_ci=1+flr(_ci*#_p.colarr)
				_p.col=_p.colarr[_ci]
			end
			
			--apply gravity
			if _p.tpe==1 or _p.tpe==3 or _p.tpe==4 then
				_p.dy+=0.05
			end
			
			--rotate
			if _p.tpe==3 or _p.tpe==4 then
				_p.rottimer+=1
				if _p.rottimer>5 then
					_p.rot+=1
					_p.rottimer=0
					if _p.rot>3 then
						_p.rot=0
					end
				end
			end
			
			--shrink
			if _p.tpe==2 then
				local _ci=1-(_p.age/_p.mage)
				_p.s=_ci*_p.os
			end
			
			--friction
			if _p.tpe==2 then
				_p.dx=_p.dx/1.1
				_p.dy=_p.dy/1.1
			end
				
			--move particle
			_p.x+=_p.dx
			_p.y+=_p.dy
		end
	end
end

--big particle drawer
function drawparts()
	for i=1,#part do
		local _p=part[i]
		--pixel particle
		if _p.tpe==0 or _p.tpe==1 then
			pset(_p.x,_p.y,_p.col)
		elseif _p.tpe==2 then
			circfill(_p.x,_p.y,_p.s,_p.col)
		elseif _p.tpe==3 or _p.tpe==4 then
			local _fx,_fy
			if _p.rot==1 then
				_fx=false
				_fy=true
			elseif _p.rot==2 then
				_fx=true
				_fy=true
			elseif _p.rot==3 then
				_fx=true
				_fy=false
			else
				_fx=false
				_fy=false
			end
			if _p.tpe==4 then
				pal(3,6)
			end			
			spr(_p.col,_p.x,_p.y,1,1,_fx,_fy)
			pal()
		end
	end
end

--rebound bumped bricks
function animatebricks()
	for i=1,#bricks do
		local _b=bricks[i]
		if _b.v or _b.fsh>0 then
			--see if brick is moving
			if _b.dx~=0 or _b.dy~=0
			or _b.ox~=0 or _b.oy~=0 then
				--apply speed of brick
				_b.ox+=_b.dx
				_b.oy+=_b.dy
				
				--change speed of
				--return to zero
				_b.dx-=_b.ox/20
				_b.dy-=_b.oy/20
				
				--dampening
				if abs(_b.dx)>(_b.ox) then
					_b.dx=_b.dx/1.2
				end
				if abs(_b.dy)>(_b.oy) then
					_b.dy=_b.dy/1.2
				end
				
				--snapping to zero
				if abs(_b.oy)<0.2
				and abs(_b.dy)<0.9 then
					_b.oy=0
					_b.dy=0
				end	
				if abs(_b.ox)<0.2
				and abs(_b.dx)<0.9 then
					_b.ox=0
					_b.dx=0
				end
				
			end
		end
	end
end

-->8
---- update functions ----

function _update60()
	doblink()
	doshake()
	updateparts()
	update_sash()
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover() 
	elseif mode=="gameoverwait" then
		update_gameoverwait() 
	elseif mode=="levelover" then
		update_levelover() 
	elseif mode=="leveloverwait" then
		update_leveloverwait() 
	elseif mode=="winner" then
		update_winner()
	elseif mode=="winnerwait" then
		update_winnerwait()		
	end
end

function update_sash()
	if sash_v then
		sash_frames+=1
		--animate width
		if sash_delay_w>0 then
			sash_delay_w-=1
		else
			sash_w+=(sash_dw-sash_w)/5
			if abs(sash_dw-sash_w)<0.3 then
				sash_w=sash_dw
			end
		end
		--animate text
		if sash_delay_t>0 then
			sash_delay_t-=1
		else
			sash_tx+=(sash_tdx-sash_tx)/10
			if abs(sash_tdx-sash_tx)<0.3 then
				sash_tx=sash_tdx
			end
		end
		--make sash go away
		if sash_frames==75 then
			sash_dw=0
			sash_tdx=160
			sash_delay_w=15
			sash_delay_t=0
		end
		if sash_frames>115 then
			sash_v=false
		end
	end
end

function update_winnerwait()
	govercountdown-=1
	if govercountdown<=0 then
		govercountdown=-1
		blinkspeed=3
		mode="winner"
	end
end

function update_winner()
	if govercountdown<0 then
		if loghs then
			if btnp(0) then
				sfx(19)
				nit_conf=false
				nit_sel-=1
				if nit_sel<1 then
					nit_sel=3
				end
			end
			if btnp(1) then
				sfx(19)
				nit_conf=false
				nit_sel+=1
				if nit_sel>3 then
					nit_sel=1
				end
			end
			if btnp(2) then
				sfx(18)
				nit_conf=false
				nitials[nit_sel]-=1
				if nitials[nit_sel]<1 then
					nitials[nit_sel]=#hschars
				end
			end
			if btnp(3) then
				sfx(18)
				nit_conf=false
				nitials[nit_sel]+=1
				if nitials[nit_sel]>#hschars then
					nitials[nit_sel]=1
				end
			end
			if btnp(5) then
				sfx(20)
				if nit_conf then
					--confirm initials
					--add new hs
					addhs(points+(lives*100),nitials[1],nitials[2],nitials[3])
					savehs()
					govercountdown=70
					blinkspeed=1
					sfx(14)
				else
					nit_conf=true
				end
			end
			if btnp(4) then
				nit_conf=false
			end
			
		else
			if btnp(5) or btnp(0) then
				govercountdown=70
				blinkspeed=1
				sfx(14)
			end
		end
	else
		govercountdown-=1
		fadeperc=(70-govercountdown)/70
		if govercountdown<=0 then
			govercountdown=-1
			blinkspeed=8
			mode="start"
			hs_x=128
			hs_dx=0
			part={}
		end
	end
end

function update_start()
	spawnbgparts()

	--slide the hs list
	if hs_x~=hs_dx then
		hs_x+=(hs_dx-hs_x)/8
	end
	
	if startcountdown<0 then
		 -- fade in game
	 if fadeperc~=0 then
	 	fadeperc-=0.05
	 	if fadeperc<0 then
	 		fadeperc=0
	 	end
	 end
		if btnp(5) then
			startcountdown=70
			blinkspeed=1
			sfx(17)
			music(-1,2000)
		end
		if btnp(0) then
			hs_dx=0
		end
		if btnp(1) then
			hs_dx=128
		end
		
	else
		startcountdown-=1
		fadeperc=(70-startcountdown)/70
		if startcountdown<=0 then
			startcountdown=-1
			blinkspeed=8
			startgame()
			part={}
		end
	end
end

function update_gameover()
	if govercountdown<0 then
		if btnp(5) or btnp(1) then
			govercountdown=90
			blinkspeed=1
			sfx(14)
			goverrestart=true
		end
		if btnp(4) or btnp(0) then
			govercountdown=90
			blinkspeed=1
			sfx(14)
			goverrestart=false
		end
	else
		govercountdown-=1
		fadeperc=(90-govercountdown)/90
		if govercountdown<=0 then
			if goverrestart then
				govercountdown=-1
				blinkspeed=8
				restartlevel()
			else
				govercountdown=-1
				blinkspeed=8
				mode="start"
				hs_x=128
				hs_dx=128
				music(0)
			end
		end
	end 
end

function update_gameoverwait()
	govercountdown-=1
	if govercountdown<=0 then
		govercountdown=-1
		mode="gameover"
		sfx(22)
	end
end

function update_leveloverwait()
	govercountdown-=1
	if govercountdown<=0 then
		govercountdown=-1
		mode="levelover"
		sfx(23)
	end
end

function update_levelover()
	if govercountdown<0 then
		if btnp(5) or btnp(1) then
			govercountdown=70
			blinkspeed=1
			sfx(14)
		end
	else
		govercountdown-=1
		fadeperc=(70-govercountdown)/70
		if govercountdown<=0 then
			govercountdown=-1
			blinkspeed=8
			nextlevel()
		end
	end
end

function update_game()
	local buttpress=false
 
 -- fade in game
 if fadeperc~=0 then
 	fadeperc-=0.05
 	if fadeperc<0 then
 		fadeperc=0
 	end
 end
 
 --infinite loop protection
 if timer_slow>0 then
	 infcounter+=0.5
 else
 	infcounter+=1
 end
 
	if timer_expand>0 then
		--extended pad
		pad_w=flr(pad_wo*1.5)
	elseif timer_reduce>0 then
		--reduced pad
		pad_w=flr(pad_wo/2)
	else
		--normal pad and ball
		pad_w=pad_wo
		pointsmult=#ball
	end
	
	if btn(0) then --left
	 if timer_slow>0 then
	 	pad_dx=-1.25
			buttpress=true
			pointstuck(-1)
		else
			pad_dx=-2.5
			buttpress=true
			pointstuck(-1)
		end
	end
 
	if btn(1) then --right
	 if timer_slow>0 then
	 	pad_dx=1.25
			buttpress=true
			pointstuck(-1)
		else
			pad_dx=2.5
			buttpress=true
			pointstuck(1)
		end
	end
	
	if btnp(5) then
		releasestuck()
	end
	
--	if btnp(4) then
--  nextlevel()
-- end
 
	if not (buttpress) then
		pad_dx=pad_dx/2.5
	end
	
	pad_x+=pad_dx
	pad_x=mid(0+(pad_w/2),pad_x,127-(pad_w/2))

	--big ball loop
	for bi=#ball,1,-1 do
		updateball(bi)
	end
	for bi=#ball,1,-1 do
		--check if paddle rammed ball
		padramcheck(ball[bi])
	end


	--move pills
	--check pill collision
	for i=#pill,1,-1 do
		local _p=pill[i]
		_p.y+=0.7
		if _p.y>128 then
		-- remove pill
			del(pill,_p)
		elseif box_box(_p.x,_p.y,8,6,pad_x-(pad_w/2),pad_y,pad_w,pad_h) then
			powerupget(_p.t)
			spawnpillpuft(_p.x,_p.y,_p.t)
			-- remove pill
			del(pill,_p)
			sfx(11)
		end
	end
	
	checkexplosions()
	
	if levelfinished() then
		_draw()
		if levelnum>=#levels then
			wingame()
		else
			levelover()
		end
	end
	
	--powerup timers
	if timer_mega>0 then
		timer_mega-=1
	end
	
	if timer_slow>0 then
		timer_slow-=1
	end
	
	if timer_expand>0 then
		timer_expand-=1
	end
	
	if timer_reduce>0 then
		timer_reduce-=1
	end
	
	--animate bricks
	animatebricks()
	
end
-->8
---- draw functions ----

function _draw()
	
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="gameoverwait" then
		draw_game()
	elseif mode=="gameover" then
		draw_gameover() 
	elseif mode=="levelover" then
		draw_levelover()
	elseif mode=="leveloverwait" then
		draw_game()
	elseif mode=="winner" then
		draw_winner()
	elseif mode=="winnerwait" then
		draw_game()
	end
	
		-- fade the screen
	pal()
	if fadeperc~=0 then
		fadepal(fadeperc)
	end
end

function draw_sash()
	if sash_w>0 then
		rectfill(0,63-sash_w,128,65+sash_w,sash_bc)
		rectfill(0,64-sash_w,128,64+sash_w,sash_c)
		print(sash_text,sash_tx,62,sash_tc)
	end
end

function draw_winner()
	draw_game()
	spawnendparts()
	local _y=20
	if loghs then
--	w, type name for hs list
	 _y=20
		rectfill(0,_y,128,_y+91,11)
		rectfill(29,_y+63,97,_y+85,12)
		rectfill(42,_y+39,84,_y+49,3)
		rect(29,_y+63,97,_y+85,0)
		print("congratulations!",34,_y+6,0)
		print("you have beaten all levels",14,_y+17,0)
		print("and you got a high score!!",14,_y+23,0)
		print("enter your initials",28,_y+29,0)
		
		--initials
		sspr(84,0,10,5,44,_y+42)
		sspr(84,0,10,5,73,_y+42)
		local _colours={0,0,0}
		if nit_conf then
			print("press — to confirm",26,_y+54,blink_b)
			_colours={blink_b,blink_b,blink_b}
		else
			print("use ‹‘”ƒ—Ž",32,_y+54,3)
			_colours[nit_sel]=blink_w
			line(58,_y+47,60,_y+47,_colours[1])
			line(62,_y+47,64,_y+47,_colours[2])
			line(66,_y+47,68,_y+47,_colours[3])
		end
		print(hschars[nitials[1]],58,_y+41,_colours[1])
		print(hschars[nitials[2]],62,_y+41,_colours[2])
		print(hschars[nitials[3]],66,_y+41,_colours[3])
	
		--total box
		local _score=" "..points
		local _lives=" "..lives
		local _total=" "..points+(lives*100)
		print("score:",32,_y+66,0)
		print(_score,96-(#_score*4),_y+66,0)
		print("lives:",32,_y+72,0)
		print(_lives,96-(#_lives*4),_y+72,0)
		print("total:",32,_y+78,7)
		print(_total,96-(#_total*4),_y+78,7)
		
	else
--	won but no high score
	 _y=33
		rectfill(0,_y,128,_y+66,11)
--		rectfill(0,_y+4,128,_y+12,0)
		print("congratulations!",34,_y+6,0)
		print("you have beaten all levels",14,_y+18,0)
		print("but did not score enough",18,_y+24,0)
		print("for a high score",34,_y+30,0)
		print("try again!!",42,_y+42,0)
		print("press — or ‹ for main menu",8,_y+54,blink_b)
	end	

end

function draw_start()
	cls()	
	rectfill(0,0,127,127,0)
	drawparts()
	
--draw logo
	palt(3,true)
	spr(64,(hs_x-128)+36,10,7,5)
	palt()
	print("by fishdollars",36+(hs_x-128),50,13)
	print("made using the awesome",20+(hs_x-128),60,13)
	print("lazydevs tutorials",28+(hs_x-128),66,13)
	print("created by krystman",26+(hs_x-128),72,13)

	prinths(hs_x)
	print("press — to start",30,85,blink_g)
	print("press ‹ for highscores",18+(hs_x-128),97,3)
end

function draw_gameover()
	local _c1,_c2
	rectfill(0,60,128,83,0)
	print("game over",46,62,7)
	if govercountdown<0 then
		_c1=5
		_c2=5
	elseif goverrestart then
		_c1=blink_grey
		_c2=5
	else
		_c1=5
		_c2=blink_grey
	end
	print("press — or ‘ to retry level",6,69,_c1)
	print("press Ž or ‹ for main menu",8,76,_c2)
end

function draw_levelover()
	rectfill(0,59,128,76,0)
	print("stage clear!",42,62,7)
	print("press — or ‘ to continue",14,69,blink_grey)
end

function draw_game()
	local i
	cls()
	rectfill(0,0,127,127,0)
	rect(0,7,127,127,3)
	
	--draw bricks
	local _bsprite=false
	local _bspritex=64
	
	for i=1,#bricks do
		local _b=bricks[i]
		if _b.v or _b.fsh>0 then
			if _b.fsh>0 then
				brickcol=13
				_b.fsh-=1
				_bsprite=false
			elseif _b.t=="b" then
				brickcol=11
				_bsprite=false
			elseif _b.t=="i" then
				brickcol=6
				_bsprite=true
				_bspritex=64
			elseif _b.t=="h" then
				brickcol=15
				_bsprite=true
				_bspritex=104
			elseif _b.t=="j" then
				brickcol=15
				_bsprite=true
				_bspritex=94
			elseif _b.t=="s" then
				brickcol=9
				_bsprite=true
				_bspritex=74
			elseif _b.t=="p" then
				brickcol=12
				_bsprite=true
				_bspritex=84
			elseif _b.t=="z" or _b.t=="zz" then
				brickcol=8
				_bsprite=false
			end
			local _bx=_b.x+_b.ox
			local _by=_b.y+_b.oy
			if _bsprite then
				sspr(_bspritex,0,10,5,_bx,_by)
			else			
				rectfill(_bx,_by,_bx+brick_w,_by+brick_h,brickcol)
			end
			if _b.t=="b" then
				rect(_bx,_by,_bx+9,_by+4,3)
			end
		end	
	end

	draw_sash()

	--particles
	drawparts()
	
 --pills
	for i=1,#pill do
		local _p=pill[i]
		if _p.t==5 then
			palt(0,false)
			palt(15,true)
		end
		spr(_p.t,_p.x,_p.y)
		palt()
	end

	--pad effects
 local _px=pad_x-(pad_w/2)
 local _py=pad_y-(pad_h/2)
 local _pshift=1
 local _pshift2=0
 if timer_expand>0 then
 	_pshift+=1
 elseif timer_reduce>0 then
 	_pshift+=3
 	_pshift2+=3
 else
 	_pshift=1
 	_pshift2=0
 end
 if timer_mega>0 then
 	line(_px+1,pad_y+3,_px+pad_w-1,pad_y+3,14)
 	line(_px+2,pad_y+4,_px+pad_w-2,pad_y+4,10)
 end
 
 --particles
	drawparts()
	
		--balls
	for i=1,#ball do
		local _b=ball[i]
		if timer_mega>0 then
			ball_col=14
			ball_r=4
		else
			ball_col=10
			ball_r=2
		end
  	circfill(_b.x,_b.y,ball_r,ball_col)
		if timer_mega>0 then
			circfill(_b.x+2,_b.y-2,0.5,7)
  elseif _b.stuck then
  	--draw trajectory dots
  	pset(_b.x+_b.dx*4*arrm,
  	_b.y+_b.dy*4*arrm,10)
  	pset(_b.x+_b.dx*4*arrm2,
  	_b.y+_b.dy*4*arrm2,10)  
	 end
	end
	
 --draw normal pad
 sspr(_pshift2,24,1,6,_px,_py)
 sspr(_pshift2,24,1,6,_px+pad_w,_py)
 for i=1,pad_w-1 do
  sspr(_pshift,24,1,6,_px+i,_py)
 end
 if sticky then
 	line(_px,pad_y-3,_px+pad_w,pad_y-3,11)
 end


	--ui
	rectfill(0,0,128,6,2)
	if debug!="" then
		print(debug,1,1,7)
	else
		local score="score:"..points
		print("lives:"..lives,1,1,0)
		print(score,64-#score*2,1,0)
		local _ct="combo:"..(chain)*pointsmult
		local _cc=0
		if timer_reduce>0 then
			_ct="combo:"..(chain*pointsmult)*2
			_cc=7
		end
		if #ball>1 then
			_cc=7
		end
		print(_ct.."x",124-(#_ct*4),1,_cc)

--		print(pointsmult,10,110,3)		
	end
end

-->8
---- highscore ----

--add new highscore
function addhs(_score,_c1,_c2,_c3)
	add(hs,_score)
	add(hs1,_c1)
	add(hs2,_c2)
	add(hs3,_c3)
	for i=1,#hsb do
		hsb[i]=false
	end
	add(hsb,true)
	sorths()
end

function resethsb()
	for i=1,#hsb do
		hsb[i]=false
	end
	hsb[1]=true
end

--sort high score list
function sorths()
 for i=1,#hs do
  local j = i
  while j > 1 and hs[j-1] < hs[j] do
   hs[j],hs[j-1]=hs[j-1],hs[j]
   hs1[j],hs1[j-1]=hs1[j-1],hs1[j]
   hs2[j],hs2[j-1]=hs2[j-1],hs2[j]
   hs3[j],hs3[j-1]=hs3[j-1],hs3[j]
   hsb[j],hsb[j-1]=hsb[j-1],hsb[j]
   j = j - 1
  end
 end
end

--resets the highscore
function reseths()
	--create default values
	hs={1000,800,750,500,200}
	hs1={13,2,16,9,5}
	hs2={1,5,9,19,1}
	hs3={14,1,7,18,12}
	hsb={true,false,false,false,false}
	sorths()
	savehs()
end

--load the highscore list
function loadhs()
	local _slot=0
	
	if dget(0)==1 then
		--load the data
		_slot+=1
		for i=1,5 do
			hs[i]=dget(_slot)
			hs1[i]=dget(_slot+1)
			hs2[i]=dget(_slot+2)
			hs3[i]=dget(_slot+3)
			_slot+=4
		end
	sorths()
	else
		--file is empty
		reseths()
	end
end

--save the highscore list
function savehs()
	local _slot
	
	dset(0,1)
	--load the data
	_slot=1
	for i=1,5 do
		dset(_slot,hs[i])
		dset(_slot+1,hs1[i])
		dset(_slot+2,hs2[i])
		dset(_slot+3,hs3[i])
		_slot+=4
	end
end

--prints hs list
function prinths(_x)
	rectfill(_x+29,8,_x+99,16,11)
	print("high scores",_x+45,10,0)


	for i=1,5 do
		--number of rank
		print(i.." - ",_x+30,15+7*i,5)
		
		--name
		local _c=7
		if hsb[i] then
			_c=blink_grey
		end
		local _name=hschars[hs1[i]]
		_name=_name..hschars[hs2[i]]
		_name=_name..hschars[hs3[i]]
		
		print(_name,_x+45,15+7*i,_c)
		
		--actual score
		local _score=" "..hs[i]
		
		print(_score,(_x+100)-(#_score*4),15+7*i,_c)
	end
end
-->8
---- new collision ----
function intercept(_x1,_y1,_x2,_y2,_x3,_y3,_x4,_y4,_d)
 _denom=((_y4-_y3)*(_x2-_x1))-((_x4-_x3)*(_y2-_y1))
 if _denom != 0 then
  _ua=(((_x4-_x3)*(_y1-_y3))-((_y4-_y3)*(_x1-_x3)))/_denom
  if _ua>=0 and _ua<=1 then
   _ub=(((_x2-_x1)*(_y1-_y3))-((_y2-_y1)*(_x1-_x3)))/_denom
   if _ub>=0 and _ub<=1 then
    _x = _x1+(_ua * (_x2-_x1))
    _y = _y1+(_ua * (_y2-_y1))
    return {x=_x,y=_y,d=_d}
   end
  end
 end
 return nil
end


function ballintercept(_b,_box,_nx,_ny)
 local _pt=nil
 if _ny<_b.y then
  _pt = intercept(_b.x,_b.y,_nx,_ny,
                  _box.left   - ball_r,
                  _box.bottom + ball_r,
                  _box.right  + ball_r,
                  _box.bottom + ball_r,
                  "bottom")
 elseif _ny>_b.y then
  _pt = intercept(_b.x,_b.y,_nx,_ny,
                  _box.left   - ball_r,
                  _box.top    - ball_r,
                  _box.right  + ball_r,
                  _box.top    - ball_r,
                  "top")
 end
 if _pt==nil then
  if _nx<_b.x then
   _pt = intercept(_b.x,_b.y,_nx,_ny,
                   _box.right  + ball_r,
                   _box.top    - ball_r,
                   _box.right  + ball_r,
                   _box.bottom + ball_r,
                   "right")
  elseif _nx>_b.x then
   _pt = intercept(_b.x,_b.y,_nx,_ny,
                   _box.left   - ball_r,
                   _box.top    - ball_r,
                   _box.left   - ball_r,
                   _box.bottom + ball_r,
                   "left")
  end
 end
 return _pt
end

function updateball(bi)
	myball=ball[bi]
	
	if timer_mega>0 then
		sfx(15,1)
	else
		sfx(-1,1)
	end
	
	if myball.stuck then
		myball.x=pad_x+sticky_x
		myball.y=pad_y-ball_r-4
		infcounter=0
	else
		--regular ball physics
		if timer_slow>0 then
			nextx=myball.x+(myball.dx/2)
			nexty=myball.y+(myball.dy/2)
		else
			nextx=myball.x+myball.dx
			nexty=myball.y+myball.dy
		end

		local _cols={}
		local _mcols={}
		local _tmpcol=nil
		local _box
		
		--check if ball hit wall
		_tmpcol=ballintercept(myball,screenbox,nextx,nexty)
		if _tmpcol~=nil then
			_tmpcol.t="wall"
			add(_cols,_tmpcol)
		end
		
		--collision with pad
		_box=getpadbox()
		_tmpcol=ballintercept(myball,_box,nextx,nexty)
		if _tmpcol~=nil then
			_tmpcol.t="pad"
			add(_cols,_tmpcol)
		end
			
		--collision with bricks
		for i=1,#bricks do
			local _b=bricks[i]
			-- check if ball hit brick
			if _b.v then
				_box=getbrickbox(_b)
				_tmpcol=ballintercept(myball,_box,nextx,nexty)
				if _tmpcol~=nil then
					_tmpcol.t="brick"
					_tmpcol.brick=_b
					if timer_mega>0 
					and _b.t=="i" 
					or timer_mega<=0 then
						--megaball
						add(_cols,_tmpcol)
					else
						add(_mcols,_tmpcol)
					end
				end
			end
		end
		
		--save speed before collision
		lasthitx=myball.dx
		lasthity=myball.dy
		
		-- see if there are collisions
		if #_cols==0 then
			-- no collisions
			myball.x=nextx
			myball.y=nexty
		else
		 -- some collision
	  local _coli=1
	  if #_cols>1 then
	   -- more than one collisiom
	   -- find the closest
	   local _coldst=coldist(myball,_cols[1])
	   for i=2,#_cols do
	    local _dst=coldist(myball,_cols[i])
	    if _dst<_coldst then
	     _coldst=_dst
	     _coli=i
	    end
	   end
 	 end
 	 --deal with collision
			collide(myball,_cols[_coli])
		end
		
		--do megaball collisions
		if #_mcols>0 then
			for i=1,#_mcols do
				hitbrick(_mcols[i].brick,true)
			end
		end
		
			--trail particles
		if timer_mega>0 then
			spawnmtrail(myball.x,myball.y)
		else
			spawntrail(myball.x,myball.y)
		end
			
		--check if ball left screen
		if myball.y>129 or 
					myball.y<-5 or 
					myball.x>135 or 
					myball.x<-5 then
			sfx(2)
			spawndeath(myball.x,myball.y+2)
			if #ball>1 then
				shake+=0.4
				del(ball,myball)
			else
				shake+=0.15
				lives-=1
				if lives<0 then
					lives=0
					gameover()
				else 
					serveball()
				end
			end
		end
	
	end -- end of sticky if
end

function collide(_b,_c)
	--set position
	_b.x=_c.x
	_b.y=_c.y
	
	--wall collision
	if _c.t=="wall" then
	reflect(_b,_c.d)
		sfx(0)
		spawnpuft(_b.x,_b.y)
		checkinf(_b)
	
	--pad collision
	elseif _c.t=="pad" then
		local bend,angf=false,false
		local _pspeed=2
		chain=1
		infcounter=0
		
		--hit side, save?
		if _c.d=="left" or _c.d=="right" then
			if _b.y+ball_r>pad_y+2 then
				--lost ball
				_b.rammed=true
			else
				bend=true
			 angf=false
				_c.d="top"
				_b.y=pad_y-ball_r
			end
		end
		reflect(_b,_c.d)
		
		if timer_slow>0 then
			_pspeed=1.2
		else
			_pspeed=2
		end
		
		--change angle
		if _c.d=="top" then
			--change angle
			if bend==false and abs(pad_dx)>_pspeed and _c.d=="top" then
		 	bend=true
		 	if sign(pad_dx)==sign(_b.dx) then
		 		angf=true
		 	else
		 		angf=false
			 end
			end
			if bend then
				if angf then
					--flatten angle
					setang(_b,mid(0,_b.ang-1,2))
				else
					--raise angle
					if _b.ang==2 then
						_b.dx=-_b.dx
					else
						setang(_b,mid(0,_b.ang+1,2))
					end
				end						
			end
			--reset pos
			_b.y=pad_y-ball_r-1
	
			--catch powerup
			if sticky then
				releasestuck()
				sticky=false
				_b.stuck=true
				sticky_x=_b.x-pad_x
			end
		end
		sfx(1)
		spawnpuft(_b.x,_b.y)
		
	--brick collision
	elseif _c.t=="brick" then
		reflect(_b,_c.d)
		checkinf(_b)
		hitbrick(_c.brick,true)
		if _c.brick.t=="i" then
			spawnpuft(_b.x,_b.y)
		end
	end
end

function reflect(_b,_d)
	--reflect ball
	if _d=="left" or _d=="right" then
		_b.dx=-_b.dx
	else
		_b.dy=-_b.dy
	end
end

function checkinf(_b)
	if infcounter>600 then
		infcounter=0
		local _nuang
		repeat
			_nuang=flr(rnd(3))
	 until _nuang~=_b.ang
		setang(_b,_nuang)
	end
end

function coldist(_b,_col)
 return dist(_b.x,_b.y,_col.x,_col.y)
end

function dist(x1,y1,x2,y2)
 local dx = x1 - x2
 local dy = y1 - y2
 return sqrt(dx*dx+dy*dy)
end

function getpadbox()
 local _l=flr(pad_x-(pad_w/2))
 local _r=_l+pad_w
 local _t=pad_y-(pad_h/2)
 local _b=pad_y+(pad_h/2)
 return {left=_l,right=_r,top=_t,bottom=_b}
end

function getbrickbox(_b)
 local _l=_b.x
 local _r=_b.x+brick_w
 local _t=_b.y
 local _b=_b.y+brick_h
 return {left=_l,right=_r,top=_t,bottom=_b}
end

function padramcheck(_b)
	if _b.stuck then
		return
	end
	local _pbox=getpadbox()
	if box_box(_pbox.left+1,
												_pbox.top+1,
												pad_w-2,
												pad_h,
												_b.x-ball_r,
												_b.y-ball_r,
												ball_r*2,
												ball_r*2
												) then
		if _b.dy<0 then
			--ball flying upwards
			--don't touch
			return
		end
		if b.y+ball_r>pad_y+2 then
			--change speed of ball
			if sign(_b.dx)==sign(pad_dx) then
				_b.dx+=pad_dx
			else
				_b.dx=-_b.dx
				_b.dx+=pad_dx
			end
			--reset ball position
			if _b.x<pad_x then
				_b.x=_pbox.left-ball_r
			else
				_b.x=_pbox.right+ball_r
			end
			--puft and sound
			if _b.rammed~=true then
				sfx(1)
				spawnpuft(_b.x,_b.y)
				_b.rammed=true
			end
		else
			local _c={}
			_c.d="top"
			_c.t="pad"
			_c.x=_b.x
			_c.y=_b.y
			collide(_b,_c)
		end
	end
end
-->8
---- levels ----

function loadlevels()

names={}

names[1]=" - beginnings"
levels[1]="//i9ib9bp9pb9bb9b" 

names[2]=" - baby steps"
levels[2]="/p/bb/b2/b3/b3p/xb4/xxb4/x2b4/x3b4/px3b4/h9"

names[3]=" - learning pillars"
levels[3]="/sxbxbxbxbxsbxbxbxbxbxbbxbhbhbhbxbhxhpipiphxhbxbxbxbxbxbbxbxbxbxbxbbxbxbxbxbxbhxixixixixhbxbxbxbxbxbbxbxbxbxbxb"

names[4]=" - invasion"
levels[4]="x2px2p/x3pxp/x3pxp/x2b4/x2b4/xxbbsbsbb/xxbbsbsbb/xb8/xb8/xbxb4xb/xbxbx2bxb/xbxbx2bxb/x3bxb/x3bxb/"

names[5]=" - the key"
levels[5]="x3pxpx4h8/xhx2px2h/xhxh4xh/xhxhxpxhxh/xhxh4xh/xhxhhphhxh/xhxh4xh/xhxhx2hxh/xhxh4xh/xhx6h/xh8"

names[6]=" - seeing patterns"
levels[6]="//xixxixixxi/xiix4iix5hx8isix5ixxhxxix6px6ixxhxxix5isix8hx5iix4iixxixxixixxi"

names[7]=" - monkey king"
levels[7]="//xixix2ixi/xisix2isi/xipix2ipi/xi2x2i2//x2hb2hx5hbpbhx5hb2hx5hbpbhx5hb2h"

names[8]=" - the sternum"
levels[8]="x4hx7bbxbbx3bbxxhxxbb/jxxbbxbbxxjxbbxxhxxbb/jxxppxppxxjxbbxxhxxbb/pxxbbxbbxxpxbbxxhxxbb/jxxbbxbbxxjxbbx4bb/bx8b"

names[9]=" - box box box"
levels[9]="//h2xh2xh3shxhshxhsh3xh2xh2/xxh2xh2x3hshxhshx3h2xh2//j2xj2xj3sjxjsjxjsj3xj2xj2"

names[10]=" - cave diver"
levels[10]="s9s/b9bi3j2i3ibbix2ibbiijjix2ijjiix8iix8iix8iixxib2ixxiibbi4bbi"

names[11]=" - overpowered!"
levels[11]="bi8bbx8bp9p/bi8bbx8bp9p/bi8bbx8bj9j/ix8i"

names[12]=" - any hole..."
levels[12]="xi//xix3s/xix2bhb/xixxb4/xixshbibhs/xixxb4/xix2bhb/xix3s/xi/xi/xi9"

names[13]=" - plinko"
levels[13]="/hxjxhxhxjxhixixixixixi/xbxbxjxbxbxxixixixixix/pxjxsxsxjxpixixixixixi/xbxhxhxhxbxxixixixixix"

names[14]=" - getting tricky"
levels[14]="b9b/hi6xp//b9b/xpxi7/b9b/i7/"

names[15]=" - the boss"
levels[15]="i9i2b6i2b8i/xxjx4j/bjsjxhxjsjbbxsxxhxxsxbx3h2//bbi6b3ix4ibbxbbxs2xbb/xxb6x4b4"

end
__gfx__
00000000049449400766667003b33b30066cc660f660066f02eeee200aaa88806676777676222998922206c7777c603333333333333333333300000000000000
0000000049949994766886673bb33bb36cccccc6600000062eeee7e2aaaa8888d6666d666629998899926ccccc7cc63bb3bb3bb33bb3333bb300000000000000
000000009994499966888866bbb3bbbbc777777c000770002eeeeee28aa88aa856d666666d9998a88999cccc777ccc3333bb3333333333333300000000000000
0000000049994994766886673bb33bb36cccccc6600000062eeeeee28888aaaa566d66d6d629987a89926cccccccc63bb3bb3bb33bb3333bb300000000000000
00000000049449400766667003b33b30066cc660f660066f02eeee200888aaa05555555555229988992206cc77cc603333333333333333333300000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000aaa000000000
0000000000000000000000000000000000000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000aaa7a00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaaaa00000000
00600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000059aaaa00000000
06000000000000000000000000006000000000000060000000000000000000000060000000000000000000000000000000000000000000000055999000000000
00000000000600000000000000000600000000000006000000000600000000000000000000000000000000000000000000000000000000000005555000000000
00000000006000000000060000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000600000000000000600000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000003000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000
03330000000003000000300000000000000000000000000003000000000030000003333000000300033300000000000000000000000333000030000003333000
00000000000003000000300000000000000000000000300000000000000003000000003000000300030000000000300000000000000003000030000003000000
00000000000000000000300000000000000000000000300000000000000000000000003000000300000000000000300003000000000000000030000003000000
00000000000000000000000000000000000330000000000000000000000000000000000000033300000000000003300003330000000000000033300000000000
00000000000000000000000000333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06c07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06c07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333333333333333333333eeee330000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333333373333333333333333333333333333eeeeee30000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333733333333333333333337333333ee7eee2e0000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333377333333333333333333333333ee7eee2e0000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333337733333333333333333333333eeeee22e0000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333337673333333333333333333373eeee222e0000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333333333337773333333333333333333733e2222e30000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333377773333333333333333337733eeee330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333337773333373333333333377733333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333767333337373373373777777773330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333377733333333333333777777733330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333337673373333737733777777333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333337333777333773337733777773333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333376733777333337777733333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333337337773377733337777333333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333767337737337773337333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333337737333376733333377733377333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333337733337337673773377337377333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333377333333333333773773373333333337330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333337337377733337777333377733333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333773333333333377733337777733377733733770000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333337777773333337777777777733333333330000000000000000000000000000000000000000000000000000000000000000000000000
11111331111133111111331113311111113311133111111111111330000000000000000000000000000000000000000000000000000000000000000000000000
17777131777713177771317771317717713177713177117777771330000000000000000000000000000000000000000000000000000000000000000000000000
1ddddd11ddddd11dddd11ddddd11dd1dd11ddddd11dd11dddddd1330000000000000000000000000000000000000000000000000000000000000000000000000
1dd1dd11dd1dd11dd1111dd1dd11dd1dd11dd1dd11dd1111dd111330000000000000000000000000000000000000000000000000000000000000000000000000
16666131666661166613166666116666131666661166133166133330000000000000000000000000000000000000000000000000000000000000000000000000
16666611666613166613166666116666131666661166133166133330000000000000000000000000000000000000000000000000000000000000000000000000
17717711771771177113177177117717711771771177111177133330000000000000000000000000000000000000000000000000000000000000000000000000
17777711771771177771177177117717711771771177771177133330000000000000000000000000000000000000000000000000000000000000000000000000
17777131771771177771177177117717711771222222221227122230000000000000000000000000000000000000000000000000000000000000000000000000
11111331111111111111111111111111111111282828882882288820000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333282828222828282820000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333332888828828882822820000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333323232232222232828288228282828230000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333332828288828282888230000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333232322322222222222222232223222330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001f7301f7301f7201f7201f7101f7101f7001d700067000370001700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100002675026750267402673026720267200170000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0006000024050210501f0501c0501905016050120500f0400b0300703004020010200100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002c5302f530325203252032510325100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100002e53031530345203452034510345100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100003053033530365203652036510365100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100003253035530385203852038510385100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0001000034530375303a5203a5203a5103a5100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0001000036530395303c5203c5203c5103c5100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00010000395303c5303f5203f5203f5103f5100150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200000c4300b4300b4300a40000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
00010000390502d050230503903039030390301a03017020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000306532e6532b6522765223652206521d642196421664213632106350c6330863305623026130061300613006040060500604006000060000600006000060000600006000060000600006000060000600
000200002f5562f5262f5063455634526345062f5562f5262f5063454634526345261e0561e0540b506295060b50629506245060b50624506295060b506295060b5060b5060b5060b5060b5060b5060b5060b506
0009000024555245262b5262b5162b016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500190e6150e6150f6150f6150f6150f6150f6150e6150d6150c6150b6150b6150a615096150961509615096150a6150b6150b6150b6150c6150d6150d6150d61509615066150461502615006150060500605
000900200f4141241415414194141e4142141422414224141f4141a414124140d4140b4140b4140c4140d4141041413414174141d4142241423414224141e41417414114140c4140b4140a4140b4140c4140d414
000200002f5562f5262f5063455634526345062f5562f5262f5063455634526000062f5462f5240b5063454634526295062f5362f526245063452634516005062f5262f5161250634516345150b5062f51500000
000200001f020210201f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001005012050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003202034020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003d6303a6203962035620356202b620296203662036610376102e6102c6102c61000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001300001d420254201d420124201d420114200a4200a4200a4200a4200a4200a4200a4000a4000a4000a4000a4000a4000040000400004000040000400004000040000400004000040015400004000040000400
00080000164201c42021420264202a420004003242232421324223242132422324250b4000a400094000840007400064000540004400044000340002400024000140001400014000040000400004000c4000d400
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000405500005000050000504665000050000500005040550000504000040550466500005000050000504055000050000500005046650000500005000050405500005040000405504665000050405500000
012400000313506135081350a1350d1350f135121351413516135001050010500105001050010500105001050310006100081000a1000d1000f10012100141001610000105001050010500105001050010500105
01120000190751b0751e07520075220751b0751e075200752207500105004050040500405004050040500405190751b0751e07520075220751b0751e075200752207500405004050040500405004050040500405
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
01 1e 42 43 44
00 1e 1f 43 44
00 1e 1f 43 44
03 1e 1f 20 44
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
