pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--bists - ver. 38 by c†ldbach
--watch as they evolve or play
--https://www.lexaloffle.com/bbs/?tid=34481

--if you make your own version
--please add one or more
--letters after the number
--(eg ver 3f by foo)

local foodvalue=35 --food gives this much hp
--local corpsevalue=70 --corpses give this much hp
local gestationcost=35 --this much hp is wasted by giving birth to an egg
local attackhp=1 --hp lost per frame when under attack
local starveevery=20 --1 hp is lost every this many frames
assert(6000%starveevery==0)
local minbists=4 --random bists will be created if population falls below this
local foodevery=20 --food is created every this many frames
assert(6000%foodevery==0)
local gestation=120 --an egg hatches after this many frames
local attackdist=5 --bists under this distance attack each other
local eatdist=6 --food under this dist is eaten
local stability=30 --the bigger this is, the smaller the mutations are
local trapratio=0.01 --the ratio of food that will be a trap
local iceperiod=10000 --how long a bist will be trapped in ice
local basedelay=0.5 --base probability that the bist will keep its last decision instead of rethinking
local basehpreduction=2 --how much hp is lost per starveevery frames when standing still
local movinghpreduction=2.5 --how much hp is lost per starveevery frames while moving
local maxhpspeedpenatly=0.1 --ratio of speed lost for every 100hp above 100hp
local decaytime=30*10 --frames that a corpse takes to decay into regular food


local p,lkps,bic1,bic2,bists,
	eggs,foods,paus,lkan,
	brcls,fdcns,sf2c,dbgm,f6k,
	msgs,hlpp,upd,ups,menu,muse,
	dead,tree,typc

function _init()
	initplayer()
	initlake()
	bic1=0
	bic2=0
	bists={}
	eggs={}
	dead={}
	foods={}
	paus=false
	brcls={ --brain parameter to color
		7,8,14,
		7,8,11,10,8,11,10,8,11,10,
		6,2,3,9,2,3,9,2,3,9,
	}
	typc={
		l=9,
		i=12,
		e=15,
	}
	fdcns={
		{x=10,y=10,w=0.2}, --0.2
		{x=128-10,y=128-10,w=0.6} --0.7
	}
	sf2c={ --sound channels that will be used by each sfx
		[0]=2, --birth
		[1]=1, --attack
		[2]=1, --eating
		[3]=2, --hatch
		[4]=0, --cry
		[5]=0, --system command
		[6]=0, --frozen
	}
	dbgm={
		[0]="no debug info",
		"showing brain pixels",
		"brain pixels and impulses"
	}
	f6k=0 --6000 is the smallest number that can be devided nicely by 1000, 300, 100, 60, 30, 20, 16, 15, 10, 8, 5, 4, 2
	msgs={}
	hlpp=false
	upd=1
	ups=0
 loadcartdata()
 menu={
		s=1,
		{t="pause",f=function (entr)
			paus=not paus
			entr.t=paus and "unpause" or "pause"
			mysfx(5)
			newmessage(paus and "paused" or "unpaused")
		end},
		{t="player "..interpretmhp(p.b.mhp).."hp",f=function (entr)
			p.b.mhp=(p.b.mhp+10)%90+10
			entr.t="player "..interpretmhp(p.b.mhp).."hp"
			dset(3,p.b.mhp)
			mysfx(5)
		end},
		{t="debug info ("..dbgl..")",f=function (entr)
			dbgl=(dbgl+1)%3
			entr.t="debug info ("..dbgl..")"
			dset(2,dbgl)
			mysfx(5)
			newmessage(dbgm[dbgl])
		end},
		{t=snds and "sound " or "sound",f=function (entr)
			mysfx(5)
			snds=not snds
			mysfx(5)
			dset(0,snds and 0 or 1)
			entr.t=snds and "sound " or "sound"
		end},
		{t=muse and "music " or "music",f=function (entr)
			muse=not muse
			togglemusic()
			dset(4,muse and 0 or 1)
			entr.t=muse and "music " or "music"
		end},
		{t=deco and "decorations •" or "decorations",f=function (entr)
			deco=not deco
			mysfx(5)
			dset(1,deco and 0 or 1)
			entr.t=deco and "decorations •" or "decorations"
		end},
		{t="save to clip",f=function ()
			if #bists>0 then
				local best,winr=-1
				for bist in all(bists) do
					if bist.s>best then winr=bist best=bist.s end
				end
				bisttoclip(winr)
				makecry(winr)
				mysfx(4)
				newmessage("saved oldest to clip")
			else
				newmessage("there are no bists alive")
			end
		end},
		{t="add from clip",f=function ()
			mysfx(5)
			if loadbistfromclip() then
				newmessage("loaded from clip and added")
			else
				newmessage("failed to load from clip")
			end
		end},
		{t="save to cart",f=function ()
			if #bists>0 then
				local best,winr=-1
				for bist in all(bists) do
					if bist.s>best then winr=bist best=bist.s end
				end
				bisttocart(winr)
				makecry(winr)
				mysfx(4)
				newmessage("saved oldest to cart")
			else
				newmessage("there are no bists alive")
			end
		end},
		{t="add from cart",f=function ()
			mysfx(5)
			if loadbistfromcart() then
				newmessage("loaded from cart and added")
			else
				newmessage("failed to load from cart")
			end
		end},
		{t="analyze",f=function ()
			local text=""
			for bist in all(bists) do
				text=text..bistdescription(bist).."-----------\n"
			end
			mysfx(5)
			newmessage("saved full analysis in clip")
			printh(text,"@clip")
		end},
		{t="add random",f=function ()
			createbist()
			mysfx(5)
			newmessage("added random bist")
		end},
		{t="kill all",f=function ()
			bists={}
			eggs={}
			mysfx(5)
			newmessage("killed all bists and eggs")
		end},
		{t="speed up “",f=function (entr)
			upd=31-upd --alternates between 30 and 1
			mysfx(5)
			entr.t=upd==1 and "speed up “" or "slow down “"
		end},
		{t="graph",f=function (entr)
			tree=not tree --alternates between family tree and brain plot
			mysfx(5)
			dset(5,tree and 0 or 1)
			newmessage(tree and "showing family tree" or "showing oldest brain plot")
		end},
	}
end

do
	local lsec,upsc=0,0
	function _update(ffwd)
		local tsec=stat(85)
		if lsec~=tsec then
			lsec=tsec
			ups,upsc=upsc,0
		end
		upsc=upsc+1
		if not ffwd then checksysbuttons() end
		if not paus then
			f6k=(f6k+1)%6000
			af2=f6k%10<5 and 0 or 1
			local af4m=f6k%20
			af4=af4m<5 and 0 or (af4m<10 and 1 or (af4m<15 and 2 or 3))
			if rnd()<1/300 and #bists>0 then
				local bist=bists[flr(rnd(#bists))+1]
				makecry(bist)
				mysfx(4)
			end
			if f6k%4==0 then
				movethelake()
			end
			if rnd()<0.1 then randomizetile(flr(rnd(15)),flr(rnd(15))) end
			maintainpopulation()
			if f6k%foodevery==0 and #foods<60 then
				createfood()
			end
			hatcheggs()
			if p.a then
				starve(p)
				eat(p)
			end
			if not ffwd then moveplayer() end
			for bist in all(bists) do
			 starve(bist)
			 eat(bist)
				if bist.hp<=0 then
					bist.dcay=decaytime
					add(dead,bist)
					del(bists,bist)
				else
					think(bist)
					age(bist)
					assert(bist.hp>0)
				end
			end
			if p.a then
				if f6k%30==0 then
					sc=sc+1
					if sc%60==0 then
						newmessage("survived: "..sc.." sec")
					end
				end
				if p.hp<=0 and p.a then
					p.a=false
					add(dead,{c=p.c,x=p.x,y=p.y,dcay=decaytime,f=p.f,o=p.o})
					newmessage("you starved to death")
					wincheck()
				end
			end
			attack()
			olda=-1
			oldb=nil
			for bist in all(bists) do
				if bist.hp<=0 then
					bist.dcay=decaytime
					add(dead,bist)
					createfood(bist.x,bist.y)
					del(bists,bist)
				else
					if olda<bist.s then
						olda=bist.s
						oldb=bist
					end
				end
			end
			if p.hp<=0 and p.a then
				p.a=false
				add(dead,{c=p.c,x=p.x,y=p.y,dcay=decaytime,f=p.f,o=p.o})
				createfood(p.x,p.y)
				newmessage("you were killed")
				wincheck()
			end
			for dbst in all(dead) do
				dbst.dcay=dbst.dcay-1
				if dbst.dcay<=0 then
					del(dead,dbst)
				end
			end
		end
		if not ffwd then
			for i=2,upd do
				_update(true)
			end
		end
	end
end

function _draw()
	cls(1)
	drawdecorations()
	drawcorpses()
	if dbgl>=2 then
		drawimpulses()
	end
	if not p.a then
		draweggsandice()
	end
	drawfoodandtraps()
	drawbists()
	drawheaderandfooter()
	if p.a then
		myspr((p.c-1)*16+p.o+(p.lm and af2*2 or 0),p.x,p.y,p.f)
		myspr(10+p.o,p.x,p.y,p.f)
		drawhealth(p)
	end
	local thetree=gettree(12)
	if hlpp then
		drawmenuscreen(thetree)
	end
end

function initplayer()
	p={
		x=64,y=64,
		o=1,f=false,c=1,
		hp=100,a=false,
		lm=nil,
		b={mhp=50},
	}	
end

function initlake()
	lkps=0
	lkan={
		[0]={x=0,y=0},
		{x=0,y=0},
		{x=1,y=1},
		{x=1,y=1},
		{x=2,y=2},
		{x=2,y=2},
		{x=3,y=3},
		{x=3,y=3},
		{x=4,y=4},
		{x=4,y=4},
		{x=5,y=5},
		{x=5,y=5},
		{x=6,y=6},
		{x=6,y=6},
		{x=7,y=7},
		{x=7,y=7},
	}
	for x=0,15 do
		for y=0,15 do
			randomizetile(x,y)
		end
	end
	for x=16+0,16+16 do
		for y=0,16,1 do
			laketile(x,y,mget(x-1,y)~=0)
		end
	end
end

function movethelake()
	lkps=(lkps+1)%16
	if lkps==0 then
		for x=16,16+16 do
			for y=0,16 do
				if x==16+16 or y==16 then
					laketile(x,y,mget(x-1,y)~=0)
				else
					mset(x,y,mget(x+1,y+1))
				end
			end
		end
	end
end

function maintainpopulation()
	local msng=minbists-#bists-#eggs
	if msng>0 then
		newmessage("low population - adding "..msng.." bist"..(msng>1 and "s" or ""))
		for i=1,msng do
			createbist()
		end
	end
end

function hatcheggs()
	for egg in all(eggs) do
		egg.t=egg.t-1
		if egg.t==0 then
			add(bists,egg.bist)
			del(eggs,egg)
			mysfx(3)
		end
	end
end

function drawdecorations()
	if deco then
		map(16,0,-lkan[lkps].x,-lkan[lkps].y,17,17)
		map(0,0,0,0,16,16)
	end
end

function drawcorpses()
	for dbst in all(dead) do
		myspr(14+dbst.o-1+16*(dbst.c-1),dbst.x,dbst.y,dbst.f)
	end
end

function drawimpulses()
	for bist in all(bists) do
		if bist.inf then
			if bist.inf.gdx then line(bist.x+4,bist.y+4,bist.inf.gdx+bist.x+4,bist.inf.gdy+bist.y+4,11) end
			if bist.inf.rdx then line(bist.x+4,bist.y+4,bist.inf.rdx+bist.x+4,bist.inf.rdy+bist.y+4,14) end
			if bist.inf.fdx then line(bist.x+4,bist.y+4,bist.inf.fdx+bist.x+4,bist.inf.fdy+bist.y+4,10) end
			if bist.inf.ix then line(bist.x+4,bist.y+4,bist.inf.ix+bist.x+4,bist.inf.iy+bist.y+4,7) end
		end
	end
end

function draweggsandice()
	for egg in all(eggs) do
		if egg.i then
			local eggsp=55+flr((iceperiod-egg.t)/(iceperiod/4))
			if eggsp>=57 and egg.bist.c==2 then
				eggsp=eggsp+2
			end
			myspr(eggsp,egg.bist.x,egg.bist.y)
		else
			myspr(25+flr((gestation-egg.t)*4/gestation),egg.bist.x,egg.bist.y)
		end
	end
end

function drawfoodandtraps()
	for food in all(foods) do
		if food.t then
			myspr(49+af4,food.x,food.y)
		else
			myspr(5+(af4+food.ofst)%4,food.x,food.y-2,food.f1,false)
		end
	end
end

function drawbists()
	for bist in all(bists) do
		myspr((bist.c-1)*16+bist.o+((bist.ldx~=0 or bist.ldy~=0) and af2*2 or 0),bist.x,bist.y,bist.f)
		if bist.g then
			myspr(8+bist.o,bist.x,bist.y,bist.f)
		end
		if not p.a then
			drawhealth(bist)
			if dbgl>0 then
				drawbistbrainpixels(bist)
				--print(bist.inf.ic,bist.x,bist.y,0)
			end
		end
	end
end

function drawbistbrainpixels(bist)
	nonoverlapxpset({
		{x=bist.x+round(7*(bist.b.h.ra+100)/200),y=bist.y-7,c=2},
		{x=bist.x+round(7*(bist.b.h.ga+100)/200),y=bist.y-7,c=3},
		{x=bist.x+round(7*(bist.b.h.fa+100)/200),y=bist.y-7,c=9},
	},-1)
	nonoverlapxpset({
		{x=bist.x+round(7*(bist.b.l.ra+100)/200),y=bist.y-6,c=8},
		{x=bist.x+round(7*(bist.b.l.ga+100)/200),y=bist.y-6,c=11},
		{x=bist.x+round(7*(bist.b.l.fa+100)/200),y=bist.y-6,c=10},
	},1)
	nonoverlapxpset({
		{x=bist.x+round(7*(bist.b.h.rdt)/100),y=bist.y+9,c=8},
		{x=bist.x+round(7*(bist.b.h.gdt)/100),y=bist.y+9,c=11},
		{x=bist.x+round(7*(bist.b.h.fdt)/100),y=bist.y+9,c=10},
		{x=bist.x+round(7*(bist.b.l.rdt)/100),y=bist.y+9,c=2},
		{x=bist.x+round(7*(bist.b.l.gdt)/100),y=bist.y+9,c=3},
		{x=bist.x+round(7*(bist.b.l.fdt)/100),y=bist.y+9,c=9},
	},1)
	nonoverlapypset({
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.h.rce+100)/200),c=8},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.h.gce+100)/200),c=11},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.h.fce+100)/200),c=10},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.h.cb+100)/200),c=7},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.l.rce+100)/200),c=2},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.l.gce+100)/200),c=3},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.l.fce+100)/200),c=9},
		{x=bist.x-2,y=bist.y+7-round(7*(bist.b.l.cb+100)/200),c=6},
	},-1)
	nonoverlapypset({
		{x=bist.x+9,y=bist.y+7-round(7*(bist.b.dz)/100),c=14},
		{x=bist.x+9,y=bist.y+7-round(7*(bist.b.d)/100),c=7},
		{x=bist.x+9,y=bist.y+7-round(7*(bist.s)/olda),c=12},
	},1)
end

function drawheaderandfooter()
	print("‡ "..#bists..(#eggs>0 and "+"..#eggs or ""),1,1,7)
	if oldb then print("Œ"..olda..","..oldb.gen,50,1,7) end
	print("“"..formatedups(),108,1,7)
	showmessages()
end

function drawmenuscreen(thetree)
	local vismi={}
	local fvismi=mid(menu.s-3,1,#menu-5)
	local mby
	for mii=fvismi,fvismi+5 do
		add(vismi,{i=mii,t=menu[mii].t})
		if mii==menu.s then
			mby=22+(mii-fvismi)*6
		end
	end
	if fvismi~=1 then vismi[1].t="[...]" end
	if fvismi+5~=#menu then vismi[6].t="[...]" end
	rectfill(3,9,128-3,128-9,0)
	rect(2,8,128-2,128-8,6)
	rect(62,8,128-2,61,6)
	rectfill(64,mby,120,mby+6,5)
	cursor(5,11,7)
	print("    keys           menu")
	print("")
	print("Ž enter/color "..vismi[1].t)
	print("— help/menu   "..vismi[2].t)
	print("”ƒ‹‘ move  "..vismi[3].t)
	print("               "..vismi[4].t)
	print("bists need     "..vismi[5].t)
	print("food to keep   "..vismi[6].t)
	print("up their hp")
	print("which is falling constantly,")
	print("especially when moving. their")
	print("evolving brains have 23")
	print("parameters. touching = fight")
	print("higher hp = slower movement")
	print("‡ population")
	print("Œ oldest's age,gen")
	print("‰ total births")
	print("“ simulation speed")
	if (tree) then
		--print(round(stat(0)/20.48).."%",103,96)
		drawtree({hp=-1},thetree,83,96,true)
	else
		if (oldb) then
			local nums=bistnums(oldb)
			for i,n in pairs(nums) do
				line(103,95+i,round(103+n/6),95+i,brcls[i])
			end
		end
	end
end

function signpower(x,p)
	return abs(x)^p*sgn(x)
end

function mutate(v,f,t)
	local d
	repeat
		d=0
		for i=1,stability do
			d=d+(rnd(2)-1)*max(v-f,t-v)
		end
	until v+d/stability<=t and v+d/stability>=f
	return v+d/stability
end

function gettree(maxh)
	local tree={}
	local mh=0
	function addit(bist,typ)
		local ances={}
		bist.typ=typ
		while bist do
			add(ances,bist)
			bist=bist.par
		end
		mh=max(mh,#ances)
		local node=tree
		for anci=#ances,1,-1 do
			local ance=ances[anci]
			node[ance]=node[ance] or {}
			node=node[ance]
		end
	end
	for bist in all(bists) do
		addit(bist,"l")
	end
	for egg in all(eggs) do
		local bist=egg.bist
		addit(bist,egg.i and "i" or "e")
	end
	if mh>maxh then
		if cleantree() then
			return gettree(maxh)
		end
	end
	return tree
end

function drawtree(par,tree,x,y,top)
	if top then
		local nx=x
		for par,chi in pairs(tree) do
			nx=drawtree(par,chi,nx,y)
		end
	elseif next(tree) then
		pset(x,y,(par.hp>0 and par.hp) and typc[par.typ] or (par.cut and 7 or 6))
		local nx=x
		local lnx
		for par,chi in pairs(tree) do
			lnx=nx
			nx=drawtree(par,chi,nx,y+2)
		end
		line(x,y+1,lnx,y+1,7)
		return nx
	else
		pset(x,y,typc[par.typ])
		assert(not par.cut)
		return x+2
	end
end

function cleantree()
	local revs={}
	local alive={}
	function addit(bist)
		if bist.par then
			revs[bist.par]=revs[bist.par] or {}
			revs[bist.par][bist]=true
			addit(bist.par)
		end
	end
	for bist in all(bists) do
		alive[bist]=true
		addit(bist)
	end
	for egg in all(eggs) do
		local bist=egg.bist
		alive[bist]=true
		addit(bist)
	end
	for par,cs in pairs(revs) do
		if not next(cs,next(cs)) and not alive[par] and not alive[next(cs)] then
			next(cs).par=next(cs).par.par
			next(cs).cut=true
			return true --might be dangerous to clean more in this round
		end
	end
	return false
end

function birth(bist)
	mysfx(0)
	bic1=bic1+1
	if bic1==10000 then
		bic1,bic2=0,bic2+1
	end
	local egg={
		t=gestation,
		i=false, --is ice trap
		bist={
			par=bist,
			gen=bist.gen+1,
			s=0,
			a=true,
			g=false,
			x=bist.x,
			y=bist.y,
			o=bist.o,
			f=not bist.f,
			c=bist.c,
			hp=ceil((bist.hp-gestationcost)/3),
			b={
				d=mutate(bist.b.d,0,100),
				mhp=mutate(bist.b.mhp,0,100),
				dz=mutate(bist.b.dz,0,100),
				l={
					cb=mutate(bist.b.l.cb,-100,100),
					rdt=mutate(bist.b.l.rdt,0,100),
					gdt=mutate(bist.b.l.gdt,0,100),
					fdt=mutate(bist.b.l.fdt,0,100),
					ra=mutate(bist.b.l.ra,-100,100),
					ga=mutate(bist.b.l.ga,-100,100),
					fa=mutate(bist.b.l.fa,-100,100),
					rce=mutate(bist.b.l.rce,-100,100),
					gce=mutate(bist.b.l.gce,-100,100),
					fce=mutate(bist.b.l.fce,-100,100),
				},
				h={
					cb=mutate(bist.b.h.cb,-100,100),
					rdt=mutate(bist.b.h.rdt,0,100),
					gdt=mutate(bist.b.h.gdt,0,100),
					fdt=mutate(bist.b.h.fdt,0,100),
					ra=mutate(bist.b.h.ra,-100,100),
					ga=mutate(bist.b.h.ga,-100,100),
					fa=mutate(bist.b.h.fa,-100,100),
					rce=mutate(bist.b.h.rce,-100,100),
					gce=mutate(bist.b.h.gce,-100,100),
					fce=mutate(bist.b.h.fce,-100,100),
				},
			}
		}
	}
	egg.bist.hp=min(egg.bist.hp,interpretmhp(egg.bist.b.mhp))
	add(eggs,egg)
	bist.hp=ceil((bist.hp-gestationcost)*2/3)
	--while cleantree() do end
end

function togglemusic()
	if muse then
		music(0,0,8)
	else
		music(-1,1000)
	end
end

function loadcartdata()
	cartdata("bists_coldbach")
	snds=dget(0)==0
	deco=dget(1)==0
	dbgl=dget(2)
	if dget(3)~=0 then p.b.mhp=dget(3) end
	muse=dget(4)==0
	tree=dget(5)==0
	togglemusic()
end

function makenote(ptch) --4 bit pitch
	return bor(band(flr((ptch+100)*30/200)+20,0x3f),0x40),0x6
end

function makecry(bist)
	local base=0x3200+68*4
	local addr=base
	local nums=bistnums(bist)
	for num in all(nums) do
		local b1,b2=makenote(num)
		poke(addr,b1)
		poke(addr+1,b2)
		addr=addr+2
	end
	--cstore(base,base,#nums*2)
end

function newmessage(msg)
	add(msgs,{m=msg,t=30*3})
end

function fourdigits(n)
	if n<10 then
		return "000"..n
	elseif n<100 then
		return "00"..n
	elseif n<1000 then
		return "0"..n
	else
		return n
	end
end

function mysfx(s)
	if snds and upd==1 then sfx(s,sf2c[s]) end
end

function wincheck()
	mysfx(5)
	newmessage("you survived "..sc.." sec")
	newmessage("the oldest has survived "..olda.." sec")
	if olda<sc then
		newmessage("you won!")
	elseif olda==sc then
		newmessage("it's a tie!")
	else
		newmessage("you lost!")
	end
end

function formatedups()
	if ups>=30 then
		return round(ups/30).."x"
	else
		return round(ups*100/30).."%"
	end
end

function getms(mhp)
	return 1-mhp/110
end

function round(x)
	return flr(x+0.5)
end

function bistdescription(bist)
	return "age: "..bist.s.."\n"..
							 "gen: "..bist.gen.."\n"..
								"hp: "..bist.hp.."\n"..
								"position: "..bist.x..","..bist.y.."\n"..
								"delay: "..bist.b.d.."\n"..
								"maximum hp: "..interpretmhp(bist.b.mhp).."\n"..
								"impulse deadzone: "..bist.b.dz.."\n"..
								"low hp color bias: "..bist.b.l.cb.."\n"..
								"low hp red distance threshold: "..bist.b.l.rdt.."\n"..
								"low hp green distance threshold: "..bist.b.l.gdt.."\n"..
								"low hp food distance threshold: "..bist.b.l.fdt.."\n"..
								"low hp red attraction: "..bist.b.l.ra.."\n"..
								"low hp green attraction: "..bist.b.l.ga.."\n"..
								"low hp food attraction: "..bist.b.l.fa.."\n"..
								"low hp red color effect: "..bist.b.l.rce.."\n"..
								"low hp green color effect: "..bist.b.l.gce.."\n"..
								"low hp food color effect: "..bist.b.l.fce.."\n"..
								"high hp color bias: "..bist.b.h.cb.."\n"..
								"high hp red distance threshold: "..bist.b.h.rdt.."\n"..
								"high hp green distance threshold: "..bist.b.h.gdt.."\n"..
								"high hp food distance threshold: "..bist.b.h.fdt.."\n"..
								"high hp red attraction: "..bist.b.h.ra.."\n"..
								"high hp green attraction: "..bist.b.h.ga.."\n"..
								"high hp food attraction: "..bist.b.h.fa.."\n"..
								"high hp red color effect: "..bist.b.h.rce.."\n"..
								"high hp green color effect: "..bist.b.h.gce.."\n"..
								"high hp food color effect: "..bist.b.h.fce.."\n"
end

function bistnums(bist)
	return {
		bist.b.d,
		bist.b.mhp,
		bist.b.dz,
		bist.b.l.cb,
		bist.b.l.rdt,
		bist.b.l.gdt,
		bist.b.l.fdt,
		bist.b.l.ra,
		bist.b.l.ga,
		bist.b.l.fa,
		bist.b.l.rce,
		bist.b.l.gce,
		bist.b.l.fce,
		bist.b.h.cb,
		bist.b.h.rdt,
		bist.b.h.gdt,
		bist.b.h.fdt,
		bist.b.h.ra,
		bist.b.h.ga,
		bist.b.h.fa,
		bist.b.h.rce,
		bist.b.h.gce,
		bist.b.h.fce,
	}
end

function bisttoclip(bist)
	local data=""
	local nums=bistnums(bist)
	for i=1,#nums do
		data=data..tostr(nums[i],true)
	end
	printh(data,"@clip")
end

function bisttocart(bist)
	local nums=bistnums(bist)
	for i=1,#nums do
		dset(i+23,nums[i])
	end
end

function chopnum(str)
	return tonum(sub(str,1,11)),sub(str,12,-1)
end

function emptybist()
	return {
		gen=1, --generation
		s=0, --"score", age
		a=true, --alive, never false except for the player when dead
		g=true, --"god made", 1st generation
		x=flr(rnd(128)), --x pos
		y=flr(rnd(128)), --y pos
		o=flr(1+rnd(2)), --orientation 1=horizontal 2=vertical
		f=rnd(1)<0.5, --flipped sprite
		c=1, --color 1=green 2=red
		hp=100, --hitpoints
		b={l={},h={}}
	}
end

function loadbistfromclip()
	local data=stat(4)
	if #data==23*11 then --number of parameters in the brain, increase if you add more parameters to the brain.
		local bist=emptybist()
		local nums={}
		for i=1,23 do
			local n
			n,data=chopnum(data)
			add(nums,n)
		end
		loadnums(bist,nums)
		bist.hp=min(bist.hp,interpretmhp(bist.b.mhp))
		add(bists,bist)
		return true
	end
end

function loadnums(bist,nums)
	bist.b.d,data=nums[1]
	bist.b.mhp,data=nums[2]
	bist.b.dz,data=nums[3]
	bist.b.l.cb,data=nums[4]
	bist.b.l.rdt,data=nums[5]
	bist.b.l.gdt,data=nums[6]
	bist.b.l.fdt,data=nums[7]
	bist.b.l.ra,data=nums[8]
	bist.b.l.ga,data=nums[9]
	bist.b.l.fa,data=nums[10]
	bist.b.l.rce,data=nums[11]
	bist.b.l.gce,data=nums[12]
	bist.b.l.fce,data=nums[13]
	bist.b.h.cb,data=nums[14]
	bist.b.h.rdt,data=nums[15]
	bist.b.h.gdt,data=nums[16]
	bist.b.h.fdt,data=nums[17]
	bist.b.h.ra,data=nums[18]
	bist.b.h.ga,data=nums[19]
	bist.b.h.fa,data=nums[20]
	bist.b.h.rce,data=nums[21]
	bist.b.h.gce,data=nums[22]
	bist.b.h.fce,data=nums[23]
end

function loadbistfromcart()
	local bist=emptybist()
	local nums={}
	for i=25,25+23-1 do
		add(nums,dget(i))
	end
	loadnums(bist,nums)
	bist.hp=min(bist.hp,interpretmhp(bist.b.mhp))
	add(bists,bist)
	return true
end

function interpretmhp(mhp)
	return ceil(1+gestationcost+mhp*2)
end

function adjimpulses(d,dt,dx,dy,ix,iy,ic,a,ce)
	if not d or d>=dt then
		return ix,iy,ic+ce*dt,false
	end
	return ix+dx*a/(d*10),iy+dy*a/(d*10),ic+ce*d,true
end

function closest(bist,items,c,shst,wdx,wdy)
	shst=shst or 10000
	for item in all(items) do
		if item~=bist and (not c or item.c==c) then
			local dist,dx,dy=dist(bist,item)
			if dist<shst then
				shst,wdx,wdy=dist,dx,dy
			end
		end
	end
	return shst,wdx,wdy
end

function dist(a,b)
	local dx=b.x-a.x
	local dy=b.y-a.y
	return sqrt(dx^2+dy^2),dx,dy
end

function randomizetile(x,y)
	if rnd()<0.9 then
		mset(x,y,0)
	else
		mset(x,y,33+flr(rnd(15)))
	end
end

function laketile(x,y,ip)
	if rnd()>(ip and 0.7 or 0.025) then
		mset(x,y,0)
	else
		mset(x,y,53+flr(rnd(2)))
	end
end

function checksysbuttons()
	if btnp(—) then
		hlpp=not hlpp
		mysfx(5)
	elseif hlpp then
		if btnp(ƒ) then
			menu.s=(menu.s%#menu)+1
		elseif btnp(”) then
			menu.s=(menu.s-2)%#menu+1
		elseif btnp(Ž) then
			menu[menu.s]:f()
		end
	end
end

function age(bist)
	if f6k%30==0 then
		bist.s=bist.s+1
	end
end

do
	local las=0
	function attack()
		local found=false
		for ei=1,#bists do
			for ej=ei+1,#bists do
				if dist(bists[ei],bists[ej])<attackdist then
					bists[ei].hp=bists[ei].hp-attackhp
					bists[ej].hp=bists[ej].hp-attackhp
					found=true
				end
			end
			if p.a and dist(bists[ei],p)<attackdist then
				bists[ei].hp=bists[ei].hp-attackhp
				p.hp=p.hp-attackhp
				found=true
			end
		end
		if found then
			if las==0 then mysfx(1) end
			las=(las+1)%16
		else
			las=0
		end
	end
end

function starve(bist)
	if bist.a and f6k%starveevery==0 then
		local active=bist.lm or (bist.ldx~=0 and bist.ldy~=0)
		bist.hp=bist.hp-(active and movinghpreduction or basehpreduction)
	end
end

function eat(bist)
 if bist.a then
	 for food in all(foods) do
	 	if dist(bist,food)<eatdist then
	 		if food.t then
	 			if bist~=p then
		 			add(eggs,{
		 				t=iceperiod,
		 				i=true,
		 				bist=bist
		 			})
		 			del(bists,bist)
		 		end
		 		mysfx(6)
	 		else
		 		bist.hp=min(bist.hp+foodvalue,interpretmhp(bist.b.mhp))
		 		mysfx(2)
		 	end
	 		del(foods,food)
	 		break
	 	end
	 end
	end
end

function moveplayer()
	if not hlpp and btnp(Ž) then
		if p.a then
			p.c=3-p.c --alternates between 2 and 1
		else
			mysfx(5)
			p.a=true
			p.hp=min(100,interpretmhp(p.b.mhp))
			sc=0
			p.x,p.y=flr(rnd(128)),flr(rnd(128))
			mysfx(5)
			newmessage("you joined the game. survive!")
		end
	end
	if p.a and not hlpp then
		if btn(‹) then
			p.x=(p.x-getms(p.b.mhp))
			p.o,p.f,p.lm=1,true,0
		elseif btn(‘) then
			p.x=(p.x+getms(p.b.mhp))
			p.o,p.f,p.lm=1,false,1
		elseif btn(”) then
			p.y=(p.y-getms(p.b.mhp))
			p.o,p.f,p.lm=2,true,2
		elseif btn(ƒ) then
			p.y=(p.y+getms(p.b.mhp))
			p.o,p.f,p.lm=2,false,3
		else
			p.lm=nil
		end
		p.x,p.y=mid(p.x,0,120),mid(p.y,0,120)
	end
end

function think(bist)
	if bist.ldx and
		--rnd(1)>startfreq/(1+bist.b.d/10+bist.s/agedivisor)
		rnd(1)<bist.b.d*(1-basedelay)/100+basedelay-0.01
	then
		bist.x,bist.y=mid(bist.x+bist.ldx,0,120),mid(bist.y+bist.ldy,0,120)
	else
		if bist.hp==interpretmhp(bist.b.mhp) then birth(bist) end
		local cfd,fdx,fdy=closest(bist,foods)
		local cgd,gdx,gdy=closest(bist,bists,1)
		local crd,rdx,rdy=closest(bist,bists,2)
		if p.a then
			cgd,gdx,gdy=closest(bist,{p},1,cgd,gdx,gdy)
			crd,rdx,rdy=closest(bist,{p},2,crd,rdx,rdy)
		end
		local ab=bist.hp<=interpretmhp(bist.b.mhp)/2 and bist.b.l or bist.b.h
		local ix,iy,ic=0,0,ab.cb*2
		ix,iy,ic,hfi=adjimpulses(cfd,ab.fdt,fdx,fdy,ix,iy,ic,ab.fa,ab.fce)
		ix,iy,ic,hgi=adjimpulses(cgd,ab.gdt,gdx,gdy,ix,iy,ic,ab.ga,ab.gce)
		ix,iy,ic,hri=adjimpulses(crd,ab.rdt,rdx,rdy,ix,iy,ic,ab.ra,ab.rce)
		local il=sqrt(ix^2+iy^2)
		if il==0 then il=1 end
		bist.inf={
			gdx=hgi and gdx,gdy=hgi and gdy,
			rdx=hri and rdx,rdy=hri and rdy,
			fdx=hfi and fdx,fdy=hfi and fdy,
			ix=ix*16/il,iy=iy*16/il,
			ci=ci
		}
		bist.c=ic<0 and 1 or 2
		local dm=false
		if 2*il*10*100/(abs(ab.ra)+abs(ab.ga)+abs(ab.fa))<bist.b.dz then
			bist.ldx,bist.ldy=0,0
			dm=true
		end
		local ms=getms(bist.b.mhp)
		if (abs(ix)>abs(iy) and ((bist.x>0 and ix<0) or (bist.x<120 and ix>0)))
			or (abs(ix)<abs(iy) and ((bist.y==0 and iy<0) or (bist.y==120 and iy>0))) then
			if ix<0 then
				if not dm then
					bist.x=mid(bist.x-ms,0,120)
					bist.ldx,bist.ldy=-ms,0
				end
				bist.o,bist.f=1,true
			else
				if not dm then
					bist.x=mid(bist.x+ms,0,120)
					bist.ldx,bist.ldy=ms,0
				end
				bist.o,bist.f=1,false
			end
		else
			if iy<0 then
				if not dm then
					bist.y=mid(bist.y-ms,0,120)
					bist.ldx,bist.ldy=0,-ms
				end
				bist.o,bist.f=2,true
			else
				if not dm then
					bist.y=mid(bist.y+ms,0,120)
					bist.ldx,bist.ldy=0,ms
				end
				bist.o,bist.f=2,false
			end
		end
	end
end

function createfood(x,y)
	local mx,my=rnd(120),rnd(120)+2
	local c=mx+my<=128 and fdcns[1] or fdcns[2]
	add(foods,{
		x=x or flr((c.x*c.w+mx*(1-c.w))),
		y=y or flr((c.y*c.w+my*(1-c.w))),
		t=rnd()<trapratio,
		f1=rnd(1)<0.5,
		f2=rnd(1)<0.5,
		ofst=flr(rnd(4))
	})
end

function createbist()
	local bist=emptybist()
	bist.b={ --brain
		d=flr(rnd(100)), --delay, makes decisions less frequent
		mhp=rnd(100), --max hp factor. see interpretmhp
		dz=rnd(100), --impulse deadzone
		l={ --low brain, under hp threshold brain
			cb=rnd(200)-100, --color bias
			rdt=rnd(100), --red bist distance threshold
			gdt=rnd(100), --green bist distance threshold
			fdt=rnd(100), --food distance threshold
			ra=rnd(200)-100, --red attraction
			ga=rnd(200)-100, --green attraction
			fa=rnd(200)-100, --food attraction
			rce=rnd(200)-100, --red bist distance effect on color
			gce=rnd(200)-100, --green bist distance effect on color
			fce=rnd(200)-100, --food distance effect on color
		},
		h={ --high brain, over hp threshold brain
			cb=rnd(200)-100,
			rdt=rnd(100),
			gdt=rnd(100),
			fdt=rnd(100),
			ra=rnd(200)-100,
			ga=rnd(200)-100,
			fa=rnd(200)-100,
			rce=rnd(200)-100,
			gce=rnd(200)-100,
			fce=rnd(200)-100,
		},
	}
	bist.hp=min(bist.hp,interpretmhp(bist.b.mhp))
	add(bists,bist)
end

function showmessages()
	if #msgs>0 then
		local y=128-#msgs*6
		for mi=1,#msgs do
			local msg=msgs[mi]
			print(msg.m,1,y,7)
			y=y+6
		end
		msgs[1].t=msgs[1].t-ceil(#msgs/4)
		if msgs[1].t<=0 then	del(msgs,msgs[1]) end
	else
		print("— help/menu",1,122,7)
		print("‰"..(bic2>0 and bic2..fourdigits(bic1) or bic1),90,122,7)
	end
end

function drawhealth(bist)
	line(bist.x,max(bist.y-2,1),bist.x+7,max(bist.y-2,1),bist.hp<=interpretmhp(bist.b.mhp)/2 and 8 or 2)
	line(bist.x,max(bist.y-2,1),bist.x+round(7*bist.hp/interpretmhp(bist.b.mhp)),max(bist.y-2,1),11)
	pset(bist.x+round(7*bist.b.mhp/100),max(bist.y-3,0),8)
end

function nonoverlapxpset(pixels,d)
	local used={}
	d=d or -1
	for pixel in all(pixels) do
		used[pixel.x]=(used[pixel.x] or pixel.y-d)+d
		pset(pixel.x,used[pixel.x],pixel.c)
	end
end

function myspr(s,x,y,f,f2)
	f2=f2==nil and f or f2
	spr(s,x,y,1,1,f,f2)
end

function nonoverlapypset(pixels,d)
	local used={}
	d=d or -1
	for pixel in all(pixels) do
		used[pixel.y]=(used[pixel.y] or pixel.x-d)+d
		pset(used[pixel.y],pixel.y,pixel.c)
	end
end
__gfx__
00000000000003300300003003033000000000000000000000600000000000000000006000000000000000000000000000000000000000000000000000000000
00000000330033300339933003003300333993330060000000000000000000600000000000000000000900000000000000066000000000000003300003393300
00700700033933900033330003393390003333000000060000d00060000000000060000000000000000090000000000000066000000000000303333000333000
0007700009333336009339000933333630933903006000600d0d0000006000d00000060000909090000900000666666600066000000000000333333500993330
000770000933333603333330093333363333333300006d0006d000000000660d0060006009090909000090000666666600066000000000000939339500333330
007007000339339033333333033933900333333006d0d0d0000066000d6000d00000600000000000000900000000000000066000000000000339339000333300
00000000330033303393393303003300009339000d0d6d00006d0d00d0d06000060d0d0000000000000090000000000000066000000000000300000000993300
000000000000033000066000030330000006600000d000000000d0000d0000000000d00000000000000900000000000000066000000000000000000000055000
000000000000088008000080080880000000000000000000000000000000000000000000000ff0000004f0000004f0000004f000000000000000000000000000
00000000880088800889988008008800888998880000000000000000000000000000000000ffff0000f4ff0000f4ff0000f4ff00000000000008800008898800
00000000088988900088880008898890008888000000000000000000000000000000000000ffff0000ff4f0000ff4f0000ff4f00000000000808888000888000
0000000009888886009889000988888680988908000000000000000000000000000000000ffffff00ffffff00f44f4f00f44f4f0000000000888888500998880
0000000009888886088888800988888688888888000000000000000000000000000000000ffffff00ffffff00fffff400ff4ff40000000000989889500888880
0000000008898890888888880889889008888880000000000000000000000000000000000ffffff00ffffff00ffffff00ff4fff0000000000889889000888800
00000000880088808898898808008800009889000000000000000000000000000000000000ffff0000ffff0000ffff00004f4f00000000000800000000998800
00000000000008800006600008088000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000055000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088800000a0a000000003000000000000000000
0000000000000000000000000000b000000000000000b0b000bb0b0000000000000000000000333000e00000089a9800000833000000e8e00033330000000000
000000000000000000000a00000b0000000000000000b0b00b004000000000000000000000000300033300000088800000a0a030000034000bbb7b3000000000
0000000000a0a0000000a9a00000b00000030000000040400b0040000b0b00000000000000000000003000000003000000000300000003000dbbbbd000000000
000000000009000000000a00000b000000003030000004000000400000b0b00000000800000000000000000000b30000000030000000043000dddd0000300000
0000000000a0a000000000000003000000000300000040400000400000b000000000898000000000000000000003b00000003000000033000000000000003000
00000000000000000000000000030000000000000000040000004000003000000000080000000000000000000003000000003000000004000000000003000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c0000000700000007000000070000000000000000000000cccccccc0000000000000000000000000000000000000000000000000000000000000000
00000000c070070070c00c0070700700707007000000000000000000cccc7ccc009c7cc000933300009333000098880000988800000000000000000000000000
000000000770c0700c7070c007c07070077070700000000000000000ccc7cccc0cc7cccc03333390033333900888889008888890000000000000000000000000
0000000000007c0000007700000077000000c7000000000000000000cc7ccc7ccc7ccc7c037ccc3003333330087ccc8008888880000000000000000000000000
0000000000c700000077000000770000007c000000000dddddd00000c7ccc7ccc7ccc7cc07ccc7cc0333333007ccc7cc08888880000000000000000000000000
00000000070c07700c0707c007070c7007070770ddddd000000dddddcccc7ccccccc7ccccccc7ccc39cc9336cccc7ccc89cc9886000000000000000000000000
000000000070070c00c00c0700700707007007070000000000000000ccc7ccccccc7ccccccc7ccccccc7cc3cccc7ccccccc7cc8c000000000000000000000000
00000000000000c00000007000000070000000700000000000000000cc7ccccccc7ccccccc7ccccccc7ccccccc7ccccccc7ccccc000000000000000000000000
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
000100001406012060110600e0600b0600905009050090500a0500a0500a0500a0500b0500c0500d0500d0500d0500e0501005012050130501404016030180301c0301f02023020260202a0202c0202e0102e010
00060000366102b31012310196101760016600321002d600236003a6002160012600136001e600116001b6000e600196001760016600146001260011600106000e6000c600096000760000000000000000000000
00030000000001d040000000000029030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000066000b6302660004600276001c6101d600176001b60017620236001260039600136201460016600206301f6001b6001d6001f6002160023620246002360027600276002a6002c6002f6002f60033600
00030000241301f1301e1301e1301d1301c1301c1301b1301c1301a1301a1301b1301c1301d1301f130231302513025130251302413022130211301f130220001f0003a0003a0003b0003c0003c0003c0003d000
00040000000001d0700000000000160001607000000000001c0701c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f1703f1603f1603f1503f1503f1403f1403f1403f1403f1403f1403f1303f1303f1303f1303f1303f1303f1303f1303f1203f1203f1203f1203f1103f1103f1103f1103f1103f1103f1103f1103f110
012600201d7241d7221d7221d7221d7231d7241d7241d7241d7241c7211c7221c725187001870018700187001d7241d7221d7221d7221d7231d7241d7241d7241c7241d7211c7221f7221f725007000070000700
0126000002623006030e623006030062300603106230060302623000000e6230060304623000000c6230060302623000000e623006030062300000106230060302623000000e6230060304623006030c62300003
012600001d7241d7221d7221d7251d7231d7041d7241d7041d7241c7211c7221c725187001870018700187001d7241d7221d7221d7251d7231d7041d7241d7041c7241d7211c7221f7221f725007000070000700
012600003071600000000000000030716000000000000000307160000034716000003071600000000000000030716000000000000000307160000000000000003071600000287160000030716000000000000000
0126000002623006030e623006030062300603106230060302623000000e6230060304623000000c6230060302623026230e623006030062300623106230060302623000000e6230060304623006030c62300003
000100003f1703f1603f1603f1503f1503f1403f1403f1403f1403f1403f1403f1303f1303f1303f1303f1303f1303f1303f1303f1203f1203f1203f1203f1103f1103f1103f1103f1103f1103f1103f1103f110
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
01 41 42 43 08
00 41 42 0a 08
00 41 42 0a 0b
00 41 09 43 08
00 41 09 0a 08
00 41 09 0a 0b
00 41 07 0a 08
00 41 09 0a 0b
00 41 07 0a 08
00 41 09 0a 44
00 41 07 0a 44
00 41 42 0a 44
02 41 0d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
