pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--defacto
--by nusan
levelsx,levelsy,inventx,inventy,recipeindex=128,64,1,2,1
cheat,wantcheat,usemusic=false,false,true

function bignum(v1,v2)
	return shr(v1,16)+(v2 and v2 or 0)
end

stars,rando,tconv,tinser,tbridge,tminer,tmcopper,tmiron,tmoil,tfurn,tfact,tlauncher,tfield,tspace,tdel,tlargedel,textradel,tground,tselling={},{},{t=6,s="conveyor",desc="transport products",cost=bignum(5),form=true,rebuild=true},{t=10,s="inserter",desc="pick/drop products",cost=bignum(10),form=true,rebuild=true},{t=26,s="bridge",desc="go over conveyors",cost=bignum(40),form=true,rebuild=true},{t=15,s="miner",desc="exploit raw fields",cost=bignum(60),size=2},{t=50,s="miner",cost=bignum(60),size=2},{t=52,s="miner",cost=bignum(60),size=2},{t=54,s="miner",cost=bignum(60),size=2},{t=55,s="furnace",desc="transform raw products",cost=bignum(200),size=2},{t=56,s="factory",desc="combine products using recipes",cost=bignum(500),size=2},{t=84,s="launcher",desc="send rockets into space",cost=bignum(30784,381),size=4},{t=79,s="field",cost=bignum(60),size=2},{t=0,s="space"},{t=32,s="delete"},{t=32,s="delete",size=2},{t=32,s="delete",size=4},{t=32,s="ground",cost=0},{t=80,s="seller",desc="trade products against money",cost=bignum(300),size=4}
tools={{tconv,tinser,tbridge,tdel,tground},{tminer,tfurn,tfact,tselling,tlauncher}}
curtool=tools[inventy][inventx]

products={{s="oil",f=14,p=bignum(1)},{s="darkblue",p=bignum(1)},{s="articial brains",p=bignum(11160,2.5)},{s="chemical",p=bignum(100)},
					{s="raw copper",f=9,p=bignum(1)},{s="grey",p=bignum(10)},{s="raw iron",f=7,p=bignum(1)},{s="iron plates",p=bignum(5)},
					{s="advanced circuits",p=bignum(1250)},{s="copper plates",p=bignum(5)},{s="robots",p=bignum(16960,15)},{s="basic circuits",p=bignum(100)},
				  {s="processing units",p=bignum(15000)},{s="dirt",p=bignum(10)},{s="refined oil",p=bignum(5)},{s="synthetic skin",p=bignum(10000)},{s="rockets",p=bignum(30784,381)}}

recgreen,recred,recchemical,recblue,recskin,recbrain,recrobot,recrocket={output=11, spr=57, dur=1, p=bignum(1000), input={{9,2},{7,2}}},{output=8, spr=58, dur=4, p=bignum(20000), input={{11,2},{9,4},{14,4}}},{output=3, spr=60, dur=2, p=bignum(17232,0.5), input={{6,3},{14,3}}},{output=12, spr=59, dur=6, p=bignum(27232,0.5), input={{8,2},{7,6},{14,6},{3,4}}},{output=15, spr=61, dur=5, p=bignum(17232,0.5), input={{11,4},{8,1},{3,4}}},{output=2, spr=62, dur=4, p=bignum(13568,12), input={{8,4},{12,2}}},{output=10, spr=63, dur=10, p=bignum(19264,76), input={{15,3},{2,1},{11,4}}},{output=16, spr=100, dur=60, p=0, input={{10,5},{0,9},{9,6},{7,6}}}
recipes,parts={recgreen,recred,recblue,recchemical,recskin,recbrain,recrobot},{}

function addpart(txt,xx,yy,cc,dd)
	local vvx,vvy=rnd()-.5,rnd()-.5
	local sv=1/sqrt(vvx*vvx+vvy*vvy)
	add(parts, {t=txt,x=xx*4,y=yy*4,vx=vvx*sv,vy=vvy*sv,c=cc and cc or 8,d=dd and dd or 10})
end

function getdata(i,j)
	if i<0 or j<0 or i>levelsx-1 or j>levelsy-1 then
		return nil
	end
	return data[i+j*levelsx]
end

function setdata(i,j,v)
	if i<0 or j<0 or i>levelsx-1 or j>levelsy-1 then
		return
	end
	data[i+j*levelsx] = v
end

function getcoord(x,y)
	return flr(x/4),flr(y/4)
end

function island(i,j)
	return fget(mget(i,j),0)
end

function badd(b)
	return b and 1 or 0
end

function basicdraw(s,d,x,y)
 	local size = fget(s,1) and badd(fget(s,5))+1 or 0.5
	spr(s,x,y,size,size)
end

function conveypal(d)
	local c,co,cpal = d.item,d.count,d.act and pali or palo
	palt(13,true)
	pal(2,5)
	pal(cpal[1], co>0 and c or 1)
	for p=2,8 do
		pal(cpal[p], co>=p and c or 1)
	end
end

function conveydraw(s,d,x,y)
	conveypal(d)
	if(d.t==tbridge) y-=1
	if d.corner!=nil and d.corner then
		s+=16
	end
	spr(s,x-1,y-1,0.75,0.875)
	if convedit then -- and not (d.item>=0 or d.count>0) then
		--if abs(px-x-2)+abs(py-y-2)<12 or d.corner then
		if d.corner then --and d.corner then
			spr(s%16+32,x,y,0.625,0.625)
		end
		--end
	end
	pal()
end

function inserdraw(s,d,x,y)
	local c,co,cpal = d.item,d.count,d.act and pali or palo
	local notempty = c>=0 or co>0
	palt(13,true)
	pal(2,5)
	pal(cpal[1], notempty and c or 1)
	pal(cpal[2], (co>=2 or notempty) and c or 1)
	for p=3,8 do
		pal(cpal[p], co>=p and c or 1)
	end
	spr(s,x-1,y-1,0.75,0.875)
	pal()
end

function furnacedraw(s,d,x,y)
	local a,b=3,4
	if(d.act and slowflip) a,b=4,3
	if d.item>=0 and products[d.item+1].f then
		pal(a,d.item)
		pal(b,products[d.item+1].f)
	else
		pal(a,0)
		pal(b,0)
	end
	spr(s,x,y)
	pal()
	--pal(3,3)
	--pal(4,4)
end

function factorydraw(s,d,x,y)
	local a,b=9,4
	if(d.act and slowflip) a,b=4,9
	pal(a,d.counts[1]>0 and d.recipe.input[1][1] or 0)
	pal(b,d.counts[2]>0 and d.recipe.input[2][1] or 0)
	local rc=d.recipe and #d.recipe.input or 0
	if(rc>2) pal(6,d.counts[3]>0 and d.recipe.input[3][1] or 0)
	if(rc>3) pal(7,d.counts[4]>0 and d.recipe.input[4][1] or 0)
	spr(s,x,y)
	--[[pal(9,9)
	pal(4,4)
	pal(6,6)
	pal(7,7)
	]]--
	pal()
end

function minerdraw(s,d,x,y)
	spr(s,x,y)
	local h = d.act and y+1+abs(2.5-(upframe/8)%5) or y+2
	rect(x,h,x+7,h+3,1)
end

function basicget(e,i,vmax)
	if i<0 or e.item==i then
		local q=min(vmax,flr(e.count/2+0.5))
		if e.wait!=nil then
			if q>0 then
				q,e.wait=0,nil
			end
		else
			if e.count==1 then
				e.wait=true
			end
		end
		e.count-=q
		e.act=true
		return q,e.item
	end
	return 0,0
end

function basicadd(e,i,value,b)
	if e.t==tfurn and (b.t==tconv or i<0 or not products[i+1].f) then
		return 0,0
	end
	local q = 0
	if i==e.item or e.item<0 then
		q=min(e.cmax,e.count+value)-e.count
		if q>0 then
			e.count+=q
			e.item,e.act=i,true
		end
	end
	return q
end

function sellingadd(e,i,value,b)
	if b.t!=tconv then
		local v=products[i+1].p*value
		addmoney(v)
		--sfx(flr(rnd(3))+7,3)
		addpart("+"..getscoretext(v),e.x,e.y,11,10)
		return value
	end
	return 0
end

function furnaceget(e,i,vmax)
	if e.item>=0 then
		local ot=products[e.item+1].f
		if ot!=nil and i<0 or ot==i then
			local q=min(vmax,e.count)
			e.count-=q
			return q,ot
		end
	end
	return 0,0
end

function factoryadd(e,i,value,b)
	local q = 0
	if b.t!=tconv and e.recipe!=nil then
		for r=1,#e.recipe.input do
			if e.recipe.input[r][1]==i then
				q=min(e.cmax,e.counts[r]+value)-e.counts[r]
				if q>0 then
					e.counts[r]+=q
				end
				break
			end
		end
	end
	return q
end

function factoryget(e,i,vmax)
	if e.recipe!=nil then
		local ot=e.recipe.output
		if i<0 or ot==i then
			local q=min(vmax,e.count)
			e.count-=q
			return q,ot
		end
	end
	return 0,0
end

function nodrop() return 0 end
function noget() return 0,0 end

function initent(i,j)
	local nent=nil
	local s = mget(i,j)
	if fget(s,3) then
		nent,needprod={x=i,y=j,size=1,spr=s,item=-1,draw=basicdraw,canadd=nodrop,count=0},false
		if s==50 or s==52 or s==54 then
			needprod,nent.prod,nent.item,nent.cmax,nent.t,nent.draw,nent.d,nent.canget=true,12,s==50 and 4 or badd(s==52)*6,24,s==50 and tmcopper or (s==52 and tmiron or tmoil),minerdraw,nodrop,basicget
		elseif s==49 or s==51 or s==53 then
			nent.count,nent.t,nent.mine=nil,tfield,s==49 and tmcopper or (s==51 and tmiron or tmoil)
		elseif s==84 then
			needprod,nent.cmax,nent.t,nent.draw,nent.canadd,nent.canget,nent.recipe,nent.counts,nent.timer,nent.prod,nent.tick=true,9,tlauncher,basicdraw,factoryadd,noget,recrocket,{0,0,0,0},0,0,0
			add(uplaunch,nent)
		elseif s==55 then
			needprod,nent.cmax,nent.t,nent.draw,nent.canadd,nent.canget,nent.prod=true,16,tfurn,furnacedraw,basicadd,furnaceget,0
		elseif s>55 and s<64 then
			needprod,nent.cmax,nent.t,nent.draw,nent.canadd,nent.canget,nent.recipe,nent.counts,nent.prod,nent.tick=true,6,tfact,factorydraw,factoryadd,factoryget,s>56 and recipes[s-56] or nil,{0,0,0,0},0,0
		elseif s==80 then
			needprod,nent.cmax,nent.t,nent.draw,nent.canadd,nent.canget,nent.prod=true,20,tselling,basicdraw,sellingadd,noget,0
		elseif s>5 and s<14 then
			nent.cmax,nent.canget=8,basicget
			if s<10 then
				nent.t,nent.corner,nent.draw,nent.canadd=tconv,true,conveydraw,basicadd
			else
 				nent.t,nent.draw=tinser,inserdraw
			end
			add(s%2==1 and upreg or upinv, nent)
		elseif s>25 and s<30 then
			nent.cmax,nent.t,nent.draw,nent.canget=8,tbridge,conveydraw,basicget
			add(s%2==1 and upreg or upinv, nent)
			add(upbridge,nent)
		else
			nent.count=nil
		end
		if(nent.t and nent.t.size) nent.size=nent.t.size
		if(needprod) add(upprod,nent)
		add(grent,nent)
		if nent.size then
			for ui=0,nent.size-1 do
				for uj=0,nent.size-1 do
					if ui+uj>0 then
						mset(i+ui,j+uj,16)
					end
					setdata(i+ui,j+uj,nent)
				end
			end
		else
			setdata(i,j,nent)
		end
	end
	return nent
end

function initpickdrop(e)
	if e==nil then
		return
	end

	local picker,s,i,j={{s=10,x=-1,y=0},{s=11,x=1,y=0},{s=12,x=0,y=-1},{s=13,x=0,y=1}},e.spr,e.x,e.y
	for p in all(picker) do --conveyor
		local isbridge=((s-16)==p.s)
		local dist=isbridge and 2 or 1
		if s==p.s or isbridge then
			local pickloc = getdata(i+p.x*dist,j+p.y*dist)
			if pickloc and pickloc.count then
				e.pick = pickloc
			end
		end
		if s==p.s or (s+4)==p.s or isbridge then --conveyor, inserter, bridge
			local droploc = getdata(i-p.x*dist,j-p.y*dist)
			if droploc and droploc.count then
				e.drop = droploc
				if e.spr == droploc.spr then
					if droploc.corner then
						droploc.corner=false
					end
				end
			end
		end
	end
end

function sort(t,fromend,side)
	local loop,st,en,step = true,1,#t-1,1
	if(fromend) st,en,step=#t-1,1,-1
	while loop do
		loop = false
		for i=st,en,step do
			local t1,t2 = t[i],t[i+1]
			local c1=t1.x-t2.x
			if c1*side>0 then
				t[i],t[i+1],loop = t2,t1,true
			elseif c1==0 and (t1.y-t2.y)*side>0 then
				t[i],t[i+1],loop = t2,t1,true
			end
		end
	end
end

function screenup(i,j)
	local s = mget(i,j)
	if not island(i,j) then
		local up,down,left,right = island(i,j-1),island(i,j+1),island(i-1,j),island(i+1,j)
		local count = badd(up) + badd(down) + badd(left) + badd(right)
		if count < 3 then
			if up then
				s = down and 36 or (left and 1 or (right and 3 or 2))
			elseif down then
				s = left and 33 or (right and 35 or 34)
			else
				s = left and (right and 37 or 17) or badd(right)*19
			end
		elseif count ==3 then
			s = down and (up and (left and 20 or 5) or 21) or 4
		else
			s = 32
		end
	end
	mset(i,j,s)
end

function uppickdrop(b)
	for e in all(b) do
		e.act=false
	end
	for e in all(b) do
		if e.drop!=nil then
			if e.count!=nil and e.count==0 then
				e.item=-1
			end
			if e.count>0 then
				local q=e.drop.canadd(e.drop,e.item,e.count,e)
				if q>0 then
					e.count-=q
					e.act=true
				end
			end
		end

		if e.pick!=nil then
			local mq=min(e.cmax,e.count+(e.t==tbridge and 4 or 1))-e.count
			if mq>0 then
				local q,it=e.pick.canget(e.pick,e.item,mq)
				if q>0 then
					e.count+=q
					e.item,e.act=it,true
				end
			end
		end
	end
end

-- noise

function noise(sx,sy,startscale,scalemod,featstep)

	local n = {}
	for i=0,sx do
		n[i] = {}
		for j=0,sy do
			n[i][j] = 0.5
		end
	end

	local step,scale = sx,startscale
	while step>1 do
		local cscal = scale
		if(step == featstep) cscal = 1
		for i=0,sx-1,step do
			for j=0,sy-1,step do
				local c1 = n[i][j]
				n[i+step/2][j],n[i][j+step/2] = (c1+n[i+step][j])*0.5 + (rnd()-0.5)*cscal,(c1+n[i][j+step])*0.5 + (rnd()-0.5)*cscal
			end
		end
		for i=0,sx-1,step do
			for j=0,sy-1,step do
				n[i+step/2][j+step/2] = (n[i][j]+n[i+step][j]+n[i][j+step]+n[i+step][j+step])*0.25 + (rnd()-0.5)*cscal
			end
		end
		step /= 2
		scale *= scalemod
	end
	return n
end

function findplace(id,count)
	local maxcount=5000
	while count>0 and maxcount>0 do
		local ra,d=rnd(),rnd()*10
		local ca,sa=cos(ra),sin(ra)
		local x,y=levelsx/2+ca*(16+d),levelsy/2+sa*(16+d)
		if mget(x,y)==32 and mget(x+1,y)==32 and mget(x,y+1)==32 and mget(x+1,y+1)==32 then
			mset(x,y,id)
			mset(x+1,y,16)
			mset(x,y+1,16)
			mset(x+1,y+1,16)
			count-=1
		end
		maxcount-=1
	end

end

function createemptylevel()

	cleandata()

	memset(0x1000,0,0x2000)

	local cur,cur2 = noise(levelsy,levelsy,0.9,0.7,levelsy),noise(levelsy,levelsy,0.9,0.4,16)
	for i=0,levelsy-1 do
		for j=0,levelsy-1 do
			local dist = max((abs(i/levelsy - 0.5) * 2), (abs(j/levelsy - 0.5) * 2))
			mset(i+32,j,(abs(cur[i][j] - cur2[i][j])*4 - dist*dist*dist*4)>0 and 32 or 0) -- ground
		end
	end

	findplace(49,10)
	findplace(51,10)
	findplace(53,10)

	startmap(true,false)
end

onemillion=bignum(16960,15)
function addmoney(m)
	statmoney+=m
	if(cheat) return
	local neg=m<0 and -1 or 1
	money1+=neg*(abs(m)%onemillion)
	money2+=neg*((abs(m)/1000)/1000)
	if money1>=onemillion then
		money1-=onemillion
		money2+=shr(1,16)
	end
	if money1<0 and money2>0 then
		money1+=onemillion
		money2-=shr(1,16)
	end
end

function hasmoney(m)
	if(cheat) return true
	local mil=(m/1000)/1000
	return money2>mil or (money2>=mil and money1>=m%onemillion)
end

function getscoretext(val)
    local s,v = "",abs(val)
    repeat
      s = shl(v % 0x0.000a, 16)..s
      v /= 10
    until (v==0)
    if (val<0)  s = "-"..s
    return s
 end

function cleandata()
	data,grent,upprod,upreg,upinv,upbridge,uplaunch,curpal,frame,upframe,backpaste,recipeelement,laststatmoney,stats={},{},{},{},{},{},{},0,0,0,false,nil,0,{}
end

function startmap(clean,load)

	cleandata()

	if clean then
		if load then
			money1,money2,statmoney,cheat=dget(1),dget(2),0,dget(3)==1
		else
			money1,money2,statmoney,cheat=0,0,0,wantcheat
			addmoney(bignum(500))
		end
	end

	-- create entities
	for i=0,levelsx-1 do
		for j=0,levelsy-1 do
			initent(i,j)
		end
	end
	for e in all(grent) do
		initpickdrop(e)
	end

	-- invert array that need to be traversed backward
	local tmpinv={}
	for e=#upinv,1,-1 do
		add(tmpinv,upinv[e])
	end
	upinv=tmpinv

	sort(upbridge,false,1)

	-- call screen up on everything
	for i=0,levelsx-1 do
		for j=0,levelsy-1 do
			screenup(i,j)
		end
	end

	if clean then
		px,py=levelsx*2-22,levelsy*2-2
		cx,cy,lastmx,lastmy=px-64,py-64,stat(32),stat(33)
	end
end

function _init()

	cartdata("nusan_defacto")
	menuelem=dget(0)*2
	if(usemusic) music(0,500)

	poke(0x5f2d, 1)

	menuitem(1, "help", function() openhelp,helpy=true,0 end)
	--menuitem(1, "restart sim", function() startmap(false,false) end)
	menuitem(2, "new map", createemptylevel)
	menuitem(3, "load", function() if dget(0)==1 then reload() startmap(true,true) end end)
	menuitem(4, "save", function() dset(0,1) dset(1,money1) dset(2,money2) dset(3,badd(cheat)) cstore() end)
	menuitem(5, "toggle music", function() usemusic = not usemusic music(usemusic and 0 or -1,500) end)

	for i=1,300 do
		add(stars,{x=rnd(128),y=rnd(128),c=rnd(100)>96 and 7 or rnd(2)+5})
	end

	for i=0,1023 do
		rando[i]=rnd(100)>60 and rnd(16) or 0
	end
	cx,cy,px,py=0,0,0,0
	cleandata()
end

function build(enttype,ni,nj,show,sprite)
	if enttype.cost then
		addmoney(-enttype.cost)
		if show and enttype.t!=32 then addpart("-"..getscoretext(enttype.cost),ni,nj) sfx(flr(rnd(3)+1),2) end
	end
	if enttype==tconv or enttype==tinser or enttype==tbridge then
		sprite+=lastdir
	end

	if enttype.size then
		for ui=0,enttype.size-1 do
			for uj=0,enttype.size-1 do
				mset(ni+ui,nj+uj,enttype.t==32 and 32 or 16)
			end
		end
	end
	mset(ni,nj,sprite)

	local size,nent=enttype.size and enttype.size or 1,initent(ni,nj)
	if nent!=nil then
		initpickdrop(nent)
	end
	for ui=-2,size+1 do
		for uj=-2,size+1 do
			screenup(ni+ui,nj+uj)
			initpickdrop(getdata(ni+ui,nj+uj))
		end
	end

	sort(upreg,true,1)
	sort(upbridge,false,1)
	sort(uplaunch,false,1)
	sort(upinv,true,-1)
	backpaste=false
end

function destroy(previous,enttype,ni,nj,show)
	addmoney(previous.t.cost)
	if(previous.recipe) addmoney(previous.recipe.p)
	if show then addpart("+"..getscoretext(previous.t.cost),ni,nj,11) sfx(4) end

	setdata(ni,nj,nil)
	if enttype.size!=nil then
		for ui=0,enttype.size-1 do
			for uj=0,enttype.size-1 do
				setdata(ni+ui,nj+uj,nil)
			end
		end
	end

	for dd=1,6 do
		del(({grent,upprod,upreg,upinv,upbridge,uplaunch})[dd],previous)
	end
	--[[
	del(grent,previous)
	del(upprod,previous)
	del(upreg,previous)
	del(upinv,previous)
	del(upbridge,previous)
	del(uplaunch,previous)
	]]
	if previous.corner!=nil then
		if previous.drop!=nil and previous.drop.corner!=nil then
			if previous.drop.spr==previous.spr then
				previous.drop.corner=true
			end
		end
	end

	local size=enttype.size and enttype.size or 1
	for ui=-2,size+1 do
		for uj=-2,size+1 do
			local e=getdata(ni+ui,nj+uj)
			if e!=nil and previous!=nil then
				if(e.drop==previous) e.drop=nil
				if(e.pick==previous) e.pick=nil
			end
		end
	end

	local btype=enttype.t
	if previous.draw==minerdraw then
		enttype,btype=tfield,previous.spr-1
		addmoney(tfield.cost)
	end
	build(enttype,ni,nj,false,btype)
	backpaste=false
end

lasti,lastj,lastmx,lastmy,lastmb1,lastmb2,last4,last5,press,openmenu,openinvent,showinventcursor,openrecipe,recipeelement,lastdir,openhelp,helpy=-100,-100,-100,-100,false,false,false,false,false,true,false,false,false,nil,0,false,0

function trybuild(enttype,i,j,canreb)
	if stat(0)>2020 then
		return
	end
	local marge = enttype.size==nil and 1 or enttype.size
	if i>0 and j>0 and i<levelsx-marge and j<levelsy-marge then
		local previous=getdata(i,j)
		if enttype.t==15 then
			if previous!=nil and previous.mine then
				if hasmoney(enttype.cost) then
					destroy(previous,enttype,previous.x,previous.y,false)
					build(previous.mine,previous.x,previous.y,true,previous.mine.t)
				else
					sfx(6)
				end
			end
		else
			if enttype.size!=nil then
				for ui=0,enttype.size-1 do
					for uj=0,enttype.size-1 do
						if(previous==nil) previous=getdata(i+ui,j+uj)
					end
				end
			end
			if previous!=nil then
				if canreb and previous.t.rebuild!=nil and previous.t==enttype then
					destroy(previous,enttype,i,j,false)
				else
					sfx(6)
				end
			else
				if hasmoney(enttype.cost) then
					build(enttype,i,j,true,enttype.t)
				else
					sfx(6)
				end
			end
		end
	end
end

function _update()

	mx,my=stat(32),stat(33)

	local mb1,mb2,b4,b5=band(stat(34),1)>0,band(stat(34),2)>0,btn(4),btn(5)
	press=mb1 or b4
	local press2,waspress,waspress2 = mb2 or b5,lastmb1 or last4,lastmb2 or last5
	local pressframe=press and not waspress

	if openmenu then
		local mcount,prevelem=2+dget(0),menuelem
		if(btnp(2)) menuelem = (menuelem+(mcount-1))%mcount
		if(btnp(3)) menuelem = (menuelem+1)%mcount

		local mouseclic=false
		if mx>37 and mx<96 then
			for i=1,mcount do
				local h=80+i*13
				if my>h-10 and my<h+2 then
					if lastmx!=mx or lastmy!=my then
						menuelem=i-1
					end
					mouseclic=lastmb1 and not mb1
				end
			end
		end

		if last4 and not b4 or mouseclic then
			sfx(11)
			if menuelem<2 then
				wantcheat,openhelp,helpy=menuelem==1,true,0
				createemptylevel()
			else
				--reload()
				startmap(true,true)
			end
			menuitems,openmenu=nil,false
		end
		if(menuelem!=prevelem) sfx(12)
		lastmb1,lastmb2,last4,last5,lastmx,lastmy = mb1,mb2,b4,b5,mx,my
		return
	elseif openhelp then
		openhelp=press or not waspress
		local movedmouse=lastmx!=mx or lastmy!=my
		if(btn(2) or (movedmouse and my<28)) helpy-=2
		if(btn(3) or (movedmouse and my>100)) helpy+=2
		helpy=min(max(0,helpy),108)
		lastmb1,last4,lastmx,lastmy = mb1,b4,mx,my
		return
	end

	if upframe%30==0 then
		stats[flr(upframe/30)%16+1]=statmoney*0.0625
		laststatmoney,statmoney=0,0
		for i=1,#stats do
			laststatmoney+=stats[i]
		end
	end

	upframe+=1
	if upframe%2==0 then
		curpal=(curpal+1)%8
	end

	slowflip=flr(upframe/12)%2==0

	pressinsert = press and (curtool==tinser or curtool==tbridge)

	local s,isc,previnvx,previnvy,prevrec,lasttool,forcemoved = 4,false,inventx,inventy,recipeindex,curtool,false
	if openinvent then
		if(btnp(0)) inventx-=1
		if(btnp(1)) inventx+=1
		if(btnp(2)) inventy-=1
		if(btnp(3)) inventy+=1
		--inventy=(inventy-1)%#tools+1
		--inventx=(inventx-1)%#tools[inventy]+1
		inventx,inventy=(inventx-1)%5+1,(inventy-1)%2+1
		curtool=tools[inventy][inventx]
		if(lasttool!=curtool) inventmoved=true
	elseif openrecipe then
		if(btnp(2)) recipeindex-=1
		if(btnp(3)) recipeindex+=1
		recipeindex=(recipeindex-1)%7+1--#recipes
	else
		local newdir,npx,npy=lastdir,px,py
		if btnp(0) then npx-=s isc=true newdir=1 end
		if btnp(1) then npx+=s isc=true newdir=0 end
		if btnp(2) then npy-=s isc=true newdir=3 end
		if btnp(3) then npy+=s isc=true newdir=2 end
		if isc then
			if pressinsert then
				forcemoved,lastdir=true,newdir
			else
				px,py=flr(npx/4)*4+2,flr(npy/4)*4+2
			end
		end
		showinventcursor,inventmoved=false,false
	end

	if mx!=lastmx or my!=lastmy or lastmb1 and not mb1 then -- also active when releasing mouse button 1, to fix when moving inserters
		if openinvent then
			local nty,ntx = flr((my-40)/12)+1,flr((mx-37)/11)+1
			if nty>0 and nty<=2 then --#tools
				if ntx>0 and ntx<=5 then --#tools[nty]
					inventy,inventx=nty,ntx
				end
			end
			showinventcursor=true
		elseif openrecipe then
			local nty=flr((my-32)/10)+1
			if abs(14-mx+3)<6 then
				if nty>0 and nty<=7 then --#recipes
					recipeindex=nty
				end
			end
			showinventcursor=true
		end
		if pressinsert then
			local diffx,diffy=mx+cx-px,my+cy-py
			if diffx!=0 or diffy!=0 then
				newdir = abs(diffx)>abs(diffy) and badd(diffx<0) or badd(diffy<0)+2
				if newdir!=lastdir then
					forcemoved,lastdir=true,newdir
				end
			end
			lastmx,lastmy=mx,my
		else
			px,py,lastmx,lastmy=mx+cx,my+cy,mx,my
		end
	end

	if previnvx!=inventx or previnvy!=inventy or prevrec!=recipeindex then
		sfx(flr(rnd(3))+7)
	end

	local ni,nj=getcoord(px,py)
	local hasmoved = lasti!=ni or lastj!=nj

	if openinvent then
		if pressframe or waspress2 and not press2 and inventmoved then
			openinvent = false
			sfx(10)
		end
	elseif openrecipe then
		if pressframe then
			openrecipe=false
			if recipeelement then
				local nrec=recipes[recipeindex]
				if nrec!=recipeelement.recipe then
					local moneyreq = nrec.p - (recipeelement.recipe and recipeelement.recipe.p or 0)
					if hasmoney(moneyreq) then
						addmoney(-moneyreq)
						recipeelement.count,recipeelement.tick=0,0
						for i=1,#recipeelement.counts do
							recipeelement.counts[i] = 0
						end
						recipeelement.recipe=nrec
						mset(recipeelement.x,recipeelement.y,nrec.spr)
						sfx(5)
					else
						openrecipe=true
						sfx(6)
					end
				end
			end
		end
	else
		local curd,badtool=getdata(ni,nj),curtool==tdel or curtool==tground
		if not badtool and curd!=nil and curd.t==tfact and not waspress then
			if press then
				openrecipe,recipeelement=true,curd
				for i=1,7 do --#recipes
					if recipes[i]==curd.recipe then
						recipeindex=i
					end
				end
				sfx(10)
			end
		else
			if press then
				--if curtool.form!=nil then
				if curtool==tconv or curtool==tdel then
					local bx,by=lasti,lastj
					repeat
						local prevx,prevy=bx,by
						if abs(bx-ni)>abs(by-nj) then
							if bx>ni then bx-=1 end
							if bx<ni then bx+=1 end
						else
							if by>nj then by-=1 end
							if by<nj then by+=1 end
						end
						if curtool==tconv then
							if not waspress then
								trybuild(curtool,bx,by,true)
							end
							if hasmoved then

								if(bx-prevx>0) lastdir=0
								if(bx-prevx<0) lastdir=1
								if(by-prevy>0) lastdir=2
								if(by-prevy<0) lastdir=3

								trybuild(curtool,prevx,prevy,true)
								if curtool==tconv then trybuild(curtool,bx,by,false) end
							end
						elseif not waspress or hasmoved then
							local previous=getdata(prevx,prevy)
							if previous!=nil and previous.t!=tfield then
								destroy(previous,({tdel,tlargedel,nil,textradel})[previous.size and previous.size or 1],previous.x,previous.y,true)
							end
						end
					until bx==ni and by==nj

				elseif not waspress or hasmoved or forcemoved then
					trybuild(curtool,lasti,lastj,true)
				end
			end
		end
	end
	if press2 and not waspress2 then
		if openrecipe then
			openrecipe=false
		else
			openinvent=not openinvent
		end
		sfx(10)
	end
	--openinvent=b5

	lastmb1,lastmb2,last4,last5,lasti,lastj = mb1,mb2,b4,b5,ni,nj

	if not openrecipe then
		if cx>px-20 then cx-=2 backpaste=false end
		if cx<px-108 then cx+=2 backpaste=false end
		if cy>py-20 then cy-=2 backpaste=false end
		if cy<py-108 then cy+=2 backpaste=false end
	end

	local step = upframe%8
	if step==0 then

		-- production
		for e in all(upprod) do
			if e.prod!=nil then
				if e.recipe!=nil then
					local isok=true
					for r=1,#e.recipe.input do
						if e.recipe.input[r][2]>e.counts[r] then
							isok=false
							break
						end
					end
					e.act=false
					if isok then
						if e.count<e.cmax then
							e.tick+=1
							e.act=true
							if e.tick>=e.recipe.dur then
								e.tick=0
								for r=1,#e.recipe.input do
									local input=e.recipe.input[r]
									e.counts[r]-=input[2]
								end
								e.count+=1
								--e.recipe.stat+=1
							end
						end
					end
				else
					local q = min(e.cmax,e.count+e.prod)-e.count
					if q>0 then
						e.count+=q
						e.act=true
					else
						e.act=false
					end
					if e.count==0 then
						e.item=-1
					end
				end
			end
		end

	--elseif step==8 then
		uppickdrop(upreg)
	elseif step==4 then
		uppickdrop(upinv)
	end

	for e in all(uplaunch) do
		if e.timer<=0 then
			if e.count>0 then
				e.count-=1
				e.timer=140
			end
		else
			e.timer-=1
			if e.timer==1 then
				sellingadd(e,16,1,e)
			end
		end
	end

end

function dtex(s,x,y,c,f)
	f=f and f or 0
	print(s,x-1,y,f)
	print(s,x+1,y,f)
	print(s,x,y-1,f)
	print(s,x,y+1,f)
	print(s,x,y,c)
end

function drawtool(tool, x,y,dir)

	local cstr,offx,offy=tool.t,0,0
	if fget(cstr,2) then
		if(tool==tground) cstr=18
		if(tool==tdel) cstr=47
		cstr+=dir
		offx,offy=-1,-1
		if(tool==tbridge) offy=-2
		if tool.form then
			pal(2,5)
			for p=1,8 do
				pal(palo[p],1)
			end
		end
	else
		pal(3,0)
		pal(4,0)
	end
	local size=tool.size==4 and 2 or 1
	spr(cstr,x+offx,y+offy,size,size)
	pal()
end

menuitems={}

function drawcross(x,y)
	line(x-2,y,x+2,y,7)
	line(x,y-2,x,y+2,7)
end

function _draw()

	pal()
	cls()
	if openmenu then

		if frame%8==0 and rnd()>0.25 then
			add(menuitems,{x=-8,y=16,vy=0,t=64+({0,2,3,4,6,7,8,9,10,11,12,14,15})[flr(rnd(13))+1]})
		end

		for i=1,#stars do
			local s=stars[i]
			local d=((s.y+frame)%128)/128
			pset(s.x,130-d*d*130,s.c)
		end

		for i=8,11 do
			pal(i,(i%4+4-flr(frame))%4<3 and 13 or 5)
		end

		for i=0,16 do
			spr(120+i%3,i*8,24)
			spr(123+i%3,i*8-4,70)
		end

		pal()
		palt(0,false)
		palt(13,true)
		for i=#menuitems,1,-1 do
			local m=menuitems[i]
			spr(m.t,m.x-4,m.y+2)
			m.x+=(m.y<20 and 1 or -1)
			if m.y<20 then
				if m.x>132 then
					m.y=62
				end
			else
				if m.x<-4 then
					del(menuitems,m)
				end
			end
		end

		pal()
		spr(88,44,40+sin(frame/100)*5-0.01,6,2)

		rectfill(40,4,90,12,1)
		dtex("nusan - 2018",42,6,6)

		local str={"new map","new sandbox"}
		if dget(0)==1 then add(str,"load game") end
		for i=1,#str do
			local h=80+i*13
			rect(37,h-9,96,h+1,1)
			dtex(str[i],46,h-6,menuelem+1==i and 6+flr(frame/10)%2 or 13,1)
		end
		frame+=1
	elseif openhelp then
		----[[ -- helping
		palt(13,true)
		local helplines,y={94,"you are cr_xu39d","a commander robot newly arrived","on asteroid as_f53bz."
		,82,"your goal is to exploit and","transform raw resources to","construct rockets full of robots","and continue to conquer","the galaxy"
		,84,"to build new equipment, you will","need money. you can gain money","by inserting your products into","a trading station."
		,80,"put miners on raw fields, use","inserters and bridges to put","products on conveyor belts.","cook raw resources in furnaces","and combine products in","factories by setting a recipe."
		,102},-helpy
	  for i=1,#helplines do
			local line=helplines[i]
			if type(line)=="number" then
				spr(line,56,y+4,2,2)
				y+=24
			else
		    print(line,64-#line*2,y,6)
				y+=6
			end
	  end
		--]]
	end

	if openmenu or openhelp then
		drawcross(mx,my)
		return
	end

	local scrx,scry=getcoord(cx,cy)
	scrx-=3
	scry-=3
	local scrxmax,scrymax=scrx+35,scry+35

	if backpaste then
		memcpy(0x6000,0x3e00,0x2000)
		camera(cx,cy)
	else

		for st in all(stars) do
			pset(st.x,st.y,st.c)
		end

		camera(cx,cy)

		rect(0,0,levelsx*4,levelsy*4,1)

		-- draw backgrounds
		for j=scry,scrymax do
			for i=scrx,scrxmax do
				local i4,j4=i*4,j*4
				local s = mget(i,j)
				if s!= 0 then
					if fget(s,2) then
						rectfill(i4,j4,i4+3,j4+3,13)
						local tr=rando[i%32+(j%32)*32]
						if tr>0 then
							pset(i4+tr%4,j4+flr(tr/4),2)
						end
					else
						if not fget(s,4) then
							local size = fget(s,1) and badd(fget(s,5))+1 or 0.5
							spr(s,i4,j4,size,size)
						end
					end
				end
			end
		end
		memcpy(0x3e00,0x6000,0x2000)
		backpaste = true
	end

	local cursorx,cursory=px,py
	if lastmb1 and pressinsert then
		cursorx,cursory=mx+cx,my+cy
	end
	circ(cursorx,cursory,5,7)

	palo,pali={1,5,2,6,4,8,3,7},{}
	for p=1,8 do
		pali[p],palo[p]=(curpal+palo[p]+3)%4+3+(p%2)*4,(palo[p]+3)%4+3+(p%2)*4
	end
	convedit=curtool==tconv
	for j=scry,scrymax do
		for i=scrx,scrxmax do
			local s = mget(i,j)
			if s!=0 and s!=32 then
				if fget(s,4) then
					local d=getdata(i,j)
					d.draw(s,d,i*4,j*4)
				end
			end
		end
	end
	pal()
	for i=3,8 do pal(i,1) end
	for b in all(upbridge) do
		if b.x>=scrx and b.x<=scrxmax and b.y>=scry and b.y<=scrymax then
			conveypal(b)
			local bx1,by1,bx2,by2,s,m=-7,0,3,0,42,false
			if b.spr>27 then
				bx1,by1,bx2,by2,s=-2,-7,-2,2,44
			end
			if b.spr%2==1 then
				bx1,bx2,by1,by2,m=bx2,bx1,by2,by1,true
			end
			spr(s,b.x*4+bx2,b.y*4+by2,1,1,m,b.spr==29)
			spr(s+1,b.x*4+bx1,b.y*4+by1,1,1,m,b.spr==29)
		end
	end
	pal()
	for b in all(uplaunch) do
		if b.timer>0 then
			local lval = (140-b.timer)*0.1+0.2
			local bx,by=b.x*4,b.y*4+12-lval*lval
			for p=1,10 do
				circfill(bx+6+rnd(4),by+rnd(4),badd(p<=5)*2+rnd(7),p>5 and 10 or 9)
			end
			spr(82,bx,by-19,2,2)
		end
	end

	local curd,us=getdata(getcoord(px,py)),mget(lasti,lastj)
	local showtool=us==32 or curtool==tground

	local showrotation = curtool.form and (not curd or curd.t==curtool)
	if showrotation then
		local df=abs(flr(upframe/4)%8-4)
		local tmpa={5+df,-8-df,-2,-2}
		for b=1,4 do
			local iscurdir=b-1==lastdir
			if iscurdir or press then
				pal(6,iscurdir and 7 or 12)
				spr(111+b,tmpa[b]+lasti*4,tmpa[(b+1)%4+1]+lastj*4)
			end
		end
		pal()
	end

	if curd!=nil then
		if(not showrotation or not press) rect(curd.x*4-1,curd.y*4-1,curd.x*4+curd.size*4,curd.y*4+curd.size*4,12)
		if(curtool.t==15 and curd.mine) showtool=true
		--if(curd.t==curtool) showtool=true
		--showtool=true
	elseif press then
		local cts=(curtool and curtool.size) and curtool.size or 1
		rect(lasti*4-1,lastj*4-1,lasti*4+cts*4,lastj*4+cts*4,8)
	end
	if showtool then
		palt(13,true)
		drawtool(curtool,lasti*4,lastj*4, curtool.form and lastdir or 0)
	end

	--line(px-2,py,px+2,py,7)
	--line(px,py-2,px,py+2,7)
	--[[
	local cursorx,cursory=px,py
	if lastmb1 and pressinsert then
		cursorx,cursory=mx+cx,my+cy
	end
	circ(cursorx,cursory,5,7)
	--spr(116,cursorx,cursory)
	]]

	for p in all(parts) do
		dtex(p.t,p.x,p.y,p.c)
		p.d-=1
		p.x+=p.vx
		p.y+=p.vy
		if p.d<=0 then
			del(parts,p)
		end
	end

	camera()

	if openinvent then
		rectfill(35,37,93,72,0)
		for j=1,2 do -- #tools
			for i=1,5 do --#tools[j]
				local ct=tools[j][i]
				local tx,ty=27+i*11,28+j*12
				rectfill(tx-1,ty-1,tx+8,ty+9,13)
				if not ct.size then tx+=2 ty+=2 end
				if ct==tlauncher then
					spr(86,tx,ty)
				elseif ct==tselling then
					spr(14,tx,ty)
				else
					drawtool(ct,tx,ty,0)
				end
			end
		end
		local tx,ty=27+inventx*11,28+inventy*12
		rect(tx-1,ty-1,tx+8,ty+9,7)
		dtex(curtool.s,37,65,7)
		if curtool.cost!=nil then
			local pctool=getscoretext(curtool.cost)
			if(curtool.cost>30) pctool=sub(pctool,0,#pctool-6).."m"
			dtex(""..pctool,84-#pctool*4,65,7)
		end
		if curtool.desc then
			rectfill(1,120,#curtool.desc*4,128,0)
			dtex(curtool.desc,0,122,7)
		end
	elseif openrecipe then
		rectfill(12,30,114,101,0)
		rectfill(24,31,115,100,1)
		palt(13,true)
		for i=1,7 do --#recipes
			local ct=recipes[i]
			local tx,ty,proditem=14,i*10+22,ct.output
			if i==recipeindex then
				palt(13,false)
				rectfill(tx-1,ty-1,tx+9,ty+8,13)
				spr(46,tx+10,ty)
				palt(13,true)
				print(products[proditem+1].s,30,33,proditem)
				local cc=hasmoney(ct.p) and 13 or 8
				rect(29,42,66,50,cc)
				print(""..getscoretext(ct.p),30,44,cc)
				print("duration:"..ct.dur,70,44,13)
				print("ingredients:",29,54,13)
				for r=1,#ct.input do
					local input=ct.input[r]
					local spx,spy=29,52+r*10
					spr(input[1]+64,spx,spy-1)
					print(products[input[1]+1].s.." "..input[2],spx+9,spy,input[1])
				end
			end
			spr(proditem+64,tx,ty)
			--print(products[ct.output+1].s,tx,ty,i==recipeindex and 13 or 7)
		end
		pal()
	else
		if curd!=nil then
			local py,ps=curd.recipe and 110 or 118,curd.t.s
			rectfill(0,py,128,128,1)
			rectfill(0,py,128,py,0)
			if(curd.mine) ps=ps.." of "..products[curd.spr==49 and 5 or (curd.spr==51 and 7 or 1)].s
			dtex(ps,2,py+3,13)
			local proditem=curd.recipe and curd.recipe.output or curd.item
			local pro=products[proditem+1]
			if pro then
				if(proditem==16) proditem=23
				print(pro.s..":"..curd.count.."/"..curd.cmax,44,py+3,proditem)
				palt(0,false)
				palt(13,true)
				spr(proditem+64,34,py+2)
				if curd.recipe then
					local percent,ri=(curd.tick + badd(curd.act)*(upframe%8)/8)/curd.recipe.dur,curd.recipe.input
					rectfill(1,py+13,percent*30+1,py+13,proditem)
					rect(1,py+12,31,py+14,0)
					for r=1,#ri do
						local input,spx=ri[r],34+(r-1)*(#ri>3 and 24 or 32)
						spr(input[1]+64,spx,py+10)
						print(""..curd.counts[r].."/"..input[2],spx+9,py+11,input[1])
					end
				end
				pal()
			elseif curd.t==tfact then
				dtex("- no recipe selected",33,py+3,13)
			end
		end
	end

	if showinventcursor then
		drawcross(lastmx,lastmy)
	end

	if not cheat then
		local score=getscoretext(money1)
		if money2!=0 then
			for i=1,6-#score do
				score="0"..score
			end
			score=getscoretext(money2)..score
		end
		dtex(""..score,119-#score*4,1,8)
	end
	dtex(""..getscoretext(laststatmoney).."/s",0,1,8)
	--[[for i=1,#stats do
		dtex(getscoretext(stats[i]),32,i*8-8,12)
	end]]

	local ram=stat(0)
	if ram>1900 then
		rectfill(0,0,63,5,0)
		print("ram warning:"..flr(ram),0,0,ram>2020 and frame%2+8 or 7)
	end
	-- tmp
	--[[if false then
		--dtex(curtool.s,80,0,8)
		print("cpu "..stat(1),0,8,8)
		print("ram "..stat(0),0,14,8)
	end]]

	--previzmap()

	frame+=1
end
__gfx__
00000000ddd200002dd200002ddd0000dddd00002ddd0000000000000000000000390000004a000000000000000000000025000008000000ddaaaadd01111110
00000000dd2000000220000002dd0000dddd000002dd00000000000000000000004a0000003900003dddd0000dddd4000226d00007ddd000d9aaaa9d10000001
00000000d200000000000000002d0000d22d000006dd00003456340043654300005700000068000004ddd0000ddd5000027dd000026dd00049aaaa9411111111
00000000200000000000000000020000200200006ddd00009a789a00a987a90000680000005700000256d0000d762000028dd000025dd0004999999410000001
000000000000000000000000000000000000000000000000222222002222220000390000004a0000022278009822200009ddd0000224d0004444444411111111
0000000000000000000000000000000000000000000000000000000000000000004a00000039000000000000000000000a000000002300005111a11510000001
0000000000000000000000000000000000000000000000000000000000000000002200000022000000000000000000000000000000000000511a1a1510000001
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005111a11501111110
00000000600000000077000000060000ddd2000060060000000000000000000000000000004a0000000000000000000000000000000000000000890000800000
00000000d600000007dd7000006d0000dd200000d66d000000000000000000000000000000390000000000000000000000390000006800000089550000900000
00000000d20000007dddd700002d0000dd600000dddd0000005634004365000000570000006800000345600006543000004a0000005700008955000000800000
00000000200000002dddd20000020000ddd60000dddd000000789a00a9870000006800000057000009a78000087a900000570000004a00005500000000900000
000000000000000002dd200000000000000000000000000000222200222200000039000000220000022220000222200000680000003900000000000000800000
0000000000000000002200000000000000000000000000000000000000000000004a000000000000002200000022000000220000002200000000000000900000
00000000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000220000002200000000000000800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd00006000000000000000000600002dd20000600600000e00000000e00000000000000000000003400000000007800000000000000000d000000080080000
dddd0000d600000000000000006d000002200000d66d00000ee000000ee00000eee000000e00000002256000000562200002300002300000dd00000008800000
dddd0000dd6000000660000006dd000006600000d22d00000e00000000e000000e000000eee0000000022780034220000002400002400000ddd0000008800000
dddd0000ddd600006dd600006ddd00006dd60000200200000000000000000000000000000000000000000220022000000025000000250000dddd000080080000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026000000260000dddd000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000270000000027000ddd0000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000280000000028000dd00000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000
00000000ddd9d9ddd111111dddd6d7ddd111111dddd525ddd111111dd555555d55555555bbbbbbbb88888888cccccccc33333333ffffffff22222222aaaaaaaa
00000000dd9d9d9d1d9d9d91dd6d6d6d1d6d6d61d552125d155212515511115551111115b111111b81111118c111111c31111113f111111f21111112a111111a
00000000d9d4d4d919d4d4d1d7d7d7d617d7d7d15255255d125525515143431554444445b444999b84449998c444999c34449993f444999f24449992a444999a
000000009d9d4d4d1d9d4d416d6d7d6d1d6d7d6121255255112552515434343554444445b444999b84449998c444999c34449993f444999f24449992a444999a
00000000d4d9d9d914d9d9d1d7d6d6d717d6d6d152552125125521215343434554444445b444999b84466998c666777c34449993f446699f24449992a446699a
000000009d9d9d4d1d9d9d416d7d7d6d1d7d7d6155525255155252511534345154444445b444999b86666668c666777c34449993f666666f24449992a666666a
00000000d9d4d9dd19d4d9d1d6d6d6dd16d6d6d1d521255d152125511155551155555555bbbbbbbb88888888cccccccc33333333ffffffff22222222aaaaaaaa
00000000dd9d9dddd111111ddd7d6dddd111111ddd525dddd111111dd111111d1111111111111111111111111111111111111111111111111111111111111111
d111111d00000000ddddddddd111111dddd44ddd00000000ddd66dddddd77ddddddd222dddd99ddddddffddddddd111ddddd111d00000000d111111ddd2222dd
1166661100000000d22dd22d11666611d444444400000000d6666666dd7777dd88829992dd9999dddddffdddbbb13331ccc166610000000011666611d24fff2d
15500661000000002222322215533661424424240000000065665656d676767d89882222d494949ddd1aa1ddb3bb1111c6cc111100000000155ee66124ff77f2
15000061000000002222232215333361244244220000000056656655166767678989898814494949d24aa42db3b3b3bbc6c6c6cc0000000015eeee6124ff77f2
15000061000000003322232315333361222424210000000055565651d166767689898898d144949421d44d12b3b3bb3bc6c6cc6c0000000015eeee6124fffff2
155006610000000013322331155336611244221d000000001566551ddd16666189898988dd144441d2d22d2db3b3b3bbc6c6c6cc00000000155ee661224fff42
1155551100000000d113331d11555511d12221dd00000000d15551ddddd1661d28888882ddd1441ddd1221dd1bbbbbb11cccccc10000000011555511d224442d
d111111d00000000ddd111ddd111111ddd111ddd00000000dd111ddddddd11ddd222222ddddd11dddd1dd1ddd111111dd111111d00000000d111111ddd2222dd
5d5d5d5ddaaaaadd0000000ee0000000d5ddddddddd55555dd1111ddddddeddd00000000000000000000000000000000000000000000000000000000077f5000
dddddddd9aaaaa9d000000eeee000000515ddd5555d55555d122221dddde8edd0000111000000000000000000000000000000000000000000000000077fff500
5dd999d49aaaaa94000000e88e000000555d55222255111112288221dde888ed0001999110000000000000000000000000000000000000000000000077fff500
dda999a49aaaaa9400000e8888e00000111522289222511112822821dd67776d00018819910000000000001100000000000100000000000000000007557ff510
5d5aaa549aaaaa940000062882600000111229a22a8225dd12288221dd67776d00018811191000000000019910000000001910000000000000000007155f5110
dd51115499999994000006722760000011128222222925dd51222215dd67776d0001881001910000000019110000000000181000000000000000007fffff5110
5d5111544444444400000677776000001112a222222a225dd511115dd6656566000188100181011000019100000000000018100000000000000005fffff51110
d9999955111111150000067777600000111922222222825ddd5555ddddd565dd000188100181199100018110011100001118910001100000000000555f511110
a99999a5111a11150000067777600000111822222222925dd111111ddddddddd000188100181911910018881199910019918100019910000000000ff55116650
5aaaaa1511a1a11500007677776700001112a222222a225d17676761dddddddd0001881001818888111181100111911911181001911910000000005551167651
511111151a111a150007667777667000155592222228251d111111116dddd66d0001881118118111188181000188811810181001811810000656000001166551
5111111511a1a1150000067777600000155528a22a9225dd17676761566dd66d0001881881018118111181001811811811181111811810000005660000155511
51111115111a11150000067777600000d55522298222515d167676715556666d0001888110001881000181001888881188118881188100000656666000111111
51111115111111150000016776100000d11155222255155511111111ddddd66d0000111000000110000010000111110011001110011000000506555601111651
d555555d111111150000015665100000d11111555511d15116767671ddddd66d0000000000000000000000000000000000000000000000000065005561116511
dddddddd5555555d0000005665000000d111dd1111dddd1dd111111dddddd66d0000000000000000000000000000000000000000000000000050000555165111
000100000001000000000000000110007777000000000000d555555ddddd666d00ab89ab89ab89ab89ab89000098ba98ba98ba98ba98ba000000000000000000
00161000001610000000000000166100777000000000000055111155ddd6d66d09ab89ab89ab89ab89ab89a00a98ba98ba98ba98ba98ba900000000000000000
00166100016610000111111001666610777700000000000051767615d665d66d89ab89ab89ab89ab89ab89abba98ba98ba98ba98ba98ba980000000000000000
001666101666100016666661166666617077700000000000576767666555d66d8955500000005550000555abba55500005550000000555980000000000000000
00166610166610000166661001111110000700000000000056767675ddddd66d85515500000551550055155bb551550055155000005515580000000000000000
00166100016610000016610000000000000000000000000015676751ddddd55d85111511111511151151115bb511151151115111115111580000000000000000
00161000001610000001100000000000000000000000000011555511dddddddd1551551111155155115515511551551155155111115515510000000000000000
000100000001000000000000000000000000000000000000d111111ddddddddd0155511111115551111555100155511115551111111555100000000000000000
00000000003102020201010101010101010101010102020101010101010101010101010101010102807070707070020202029002020202020202020202020202
028080a00101b090800202609080a180801200222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000222232020202c0d1d1c0c0d1d1c0c0d1d1c00202d0c1c1d0d0c1c1d0d0c1c1d0d0c1c1d002800202020202020202029002020202020202020202020202
028080a0a301b090800202d002808070800251020202021100000000000000000000000000000000000000000000000000000000000000000000000000000000
00003180707070707070707070707070707070707002707070707070707070707070707070707070700202020202020202029070026060606060606080020202
028080a10101a19080a0b301b1808002800202020202021100000000000000000000000000000000000000000000000000000000000000000000000000000000
00003180414242500270707070707070707070707070707070707070707070707070707070707002020202020202020202020202029002020202028080020202
029080a1a301a19080a10101b0808002800202020202021100000000000000000000000000000000000000000000000000000000000000000000000000000000
0000316060606060606060606060606060606060606060606060606060606060606060606060606060606060606060800202d1d1029002020202028080020202
029080a00101b09080a1b301b0808002800202020202021100000000000000000000000000000000000000000000000000000000000000000000000000000000
00003102020202400202020202020202020202020202102020202020202020300202020202020202020202020202028002027301029002020202028080020202
029080a0a301b09080a00101b1808002800202020210200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000020202020310202020202021020202020202020000000000000000000002020300202020202020202020202028002020101029002020202028080020202
029080a10101a190800202c002020202800202414200220000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000202020202020000000000000000000000000000000000000000032020202020202020202020202800202d1d1029002020202028080b1f301
b0900202020202908002026060807070700202020251021100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000031020202020202020202020202028002022301029002020202028080a00101
b1909002026060908002020202800202020202024002100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000300202020202020202020202028002020101029002020202028080a0f301
b1909002029002028002020202800202330102412220000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000022222222222222222222225002020202020202020202026060606060609002020202028080b10101
b09090020290028080b1e30102800202010102020211000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000003160606060606060606060606060606060606060606060606080020202020202020202028080a0f301
b09090020290028080a00101b0800202020202021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000003190700270707070707070707070707070707070707070707070707070707002020202028080b10101
b19090026090028080a0e301b0800202020202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000030707070707070707070707070707070707070707070707070020202029070707070708080b1f301
b19090020202028080b1010102800202020202110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002250c0c1c00202c10202c0c10202c0c10202c0c10202c0c190020202020202025301907080a00101
b0909002d1d1028080b1e30102800202020202110000000022000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000003145010101450101014501010145010101450101014501010190020223010202020101020202020202
029090707070707080a00101b0800202020210000000223202120000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000003101010101010101010101010101010101010101010101010190020201010202050101010202020202
029060606060029080a0e301b0800202020211000031020202021100000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000310101010101010101010101010101010101010101010101019002b1c1630102010101010202020233
019090020202029002b1010102024142424222222232020202100000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000310101010101010101010101010101010101010101010101019002b1c1010102010101010202020201
01909002020202020202020260606060606060606060606010000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000002050d0d1d00202d10202d0d1d1d00202d1d00202d1d0028002b17301020202010101010202020202
02909002024301a17301a10290606060606060606060606011000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000031707070707070707070707070707070707070707070707002b101018002b17301b1430102026002
a1909002020101a10101a1029090102050c1c14150c1c14100000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000317070707070707070707070707070707070707070707070707070707002b10101b1010102029002
a190900202020202020202020290113102c1c10202c1c10211000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000202020202020202020203002020202020202020202020202020202020202020202020202029002
0290020202022301a17301a140901131930193019301930111000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000003102020202020202020202020202020240020202020202020202029002
0290020202020101a10101a152901131010101010101010111000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000202020202020202030020202020210002030026301a17301a1029010
30904150020202020202024122422232c0c0c0c0c0c0c0c011000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031020210202000000000300101a10101a1029011
31907070707070707070707070707070707070707070707011000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000202020202020202000
00202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000001d1d1d1d1d1d1d1d1b00010000000000000000001d1d1d1d000005000000000000000000000000000000000b1b0b1b0b1b1b1b1b1b1b1b1b1b1b000000000000000000000000000000003b1b00003b003b0000000000000000001b1b000000001b0000000000000000000000000000001b000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222222222222222220000000000002222222223202020212222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000002320070707070707070707070707070707070707070707071100000000232020202020202020202020210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000132020070707070707070707070707070720202020142403091100220013202020202020202020202020201100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000232020201c1c20201c1c20201c1c20200920202020202025092123202113202020202020202020202020202122002222000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000013202020201c1c20201c1c20201c1c20200920202020202015092020202015202020202020202020202020202020152020212320212222222222000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000132020203c103c103c103c103c103c10200920202020202020092020202020202020202020202020202020202020202020202020202020202020212222222200000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000001320202010101010101010101010101020092020202020202009201b341020202020202020202020202020202020202020202020202020202020202020202011000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000022222222222222222222222223202020200c0c20200c0c20200c0c2020092020203510202009201b101020202020202020202020202020202020202006060606060606060606060606082011000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000013080707070707070707070707070707070707070707070707070707202009202020101020202020202020202020202020202020202020202020202020200d0d20200d0d20200d0d2020082021000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000130801020202020202020202020202032020202020202020202020202006092020202020202020202020202032102020202020202020202020202020203c103c103c103c103c103c1020082020110000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001308110000000000000000000000000003202020202020202020202020202020202020202020202020202020101020202031102020202020202020202010101010101010101010101020082020110000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000013081100000000000000000000000000000202020320202020202020201d1d2032101a3710202020202020201c1c20202010102036101a37101a200820201d1d20201d1d20201d1d2020082020110000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000130811000000000000000000000000000000000013200420202036101a37102010101a101020202035102020371020202020202010101a10101a200820201d1d20201d1d20201d1d2020082020110000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000130811000000000000000000000000000000000000021320202010101a1010202020201c1c202020101020201010203310202034101a2008202020060606060606060606060606060620080820110000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000013081100000000000000000000000000000000222200232020202020202020202020202020202020202020201c1c201010202010101a2006060606060606060606060606060606060620080820110000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001308110000000000000000000000000000001320201520202020202020202020202020060606082020202020202020202037101b36102020202020202020202020202020202020202020080820110000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000013081100000000000000000000000000000013202020202020202020351020202034101a3710082020202020060820202010101b10102020202020202020202020202020202020202020082020110000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000013081100000000000000000000000000000013202020202020202020101020202010101a101008202020202020082020201c1c2020202020202020202020202020202020202020202020082001000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001308110000000000000000000000000000000005202020202020140520202020202020201c1c082020202020200820202020202020311020203110202020202020202020202020202020082011000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001308110000000000000000222222222222001308201b37102020202020202020202020202008082020202020200820202006082020101031101010202020202020202020202020202020082011000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001308110000000000222223202020202020212308201b10102020200420202020202020200608082020202020200820202020082020202010103410202020202020202020202020200103080100000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000130811000000002320200707070707070707070720201d1d2020201520202020202020202008081a1a39100a08080a3a100b08082037101b1b1010202014242424242405202020142223081100000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000130811000022232020200707070707070707070707203210202020202020202020202020200808202010100a08081a10101a08082010101a1a0608080707070707070707070707070707071100000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000022222222000013081100132020202020201c1c20201c1c20202009201010202036101a37102020202020200808202039100a08081a3a101a080820202020080707082001020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000
00000000000000000000002222222320202020212223082122232020202020201c1c20201c1c20202009202020202010101a101020202020202008081a1a10102008080a10100b080820202020082008070100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000232020202020202020202020082020202020202020391039103910391020200920202020202020201c1c20202020202008081a1a39100a08080a3a100b080820200608081a08081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000222222232020202020202020202020200820202020202020201010101010101010202009041b37101b34102020202020202020200808202010100a08081a10101a080820200d08080807081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001320202007070707070707070707070707072020202020202020200c0c20200c0c20202009151b10101b10102008072020202020200808202039100a08081a3a101a08080a3b101b080820081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132020200707070707070707070707070707070707070707070707070707070707202020202020070707070707072020202020202008081a1a10100a08080a10100b08081a10100b080820081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000013202020201c1c20201c1c20201c1c20202007070707070707070707070707070707070707070707070707070707202020202020202020202020202008080a3a100b08081a3b100b080820081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000013202020201c1c20201c1c20201c1c2020200c1c1c0c0c1c1c0c0c1c1c0c0c1c1c0c20202020201c1c2020202009202020202020202020202020202008081a10101a08080a10101b080820081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000132020203d103d103d103d103d103d1020203a103a103a103a103a103a103a103a10202020202020202020202009202020202020202020202020202008081a3a101a090820200c09080608081100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b62500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000266251f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c62500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002262400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002205527042270450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001245511455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002371500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c71500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001871500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b7241b512000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000147551c755000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001675500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000800155000000010000625000550000000155006050c05500000000000c6250c05500000000000c6050c055000000c0050c6250c0550c605000000c6050c05500000000000c6250c05500000000000c605
01100020001550c000000000c625001550c00000000000000c05500000000000c6250c05500000000000c60500155000000c0050c625001550c605000000c6050c05500000000000c6250c05500000000000c605
012000201a7551a7451a7351a7251f7551f7251d7551d7251a7551a7451a7351a725217552172523755237251f7551f7451f7351f7251d7551d7451d7351d7251c7551c7251f7551f7251a7551a7251c7551c725
0110002007555095550a555035550352506555095550d5550e5550e5250455504535045250e55504555065550b5550b5250d555025550355508555095550c5550b555075550a5550b55506555065250855508525
011000200c455004450043500425004151f400000000000011455004450043500425004150000500005000050a455004450043500425004150040500005000050545500445004350042500415004050000500005
011000201f7541f7411f7311f7211f7111f71500700007000f7540f7410f7310f7210f7110f71500700007001d7541d7411d7311d7211d7111d71500700007002175421741217312172121711217150070000700
011000201d5551c5552455521555000052155500005215520f5551d55524555245551a555235551c552245522155524555000052455500005215552355521552215551c5551d5552455500005245550000524552
012000201e0541e0411e0311e022220542204122031220251b0541b0411b0311b022160541604116031160251d0541d0411d0311d0221b0541b0411b0311b0251605416041160311602218054180411803118025
01100020075520754207532075250a5520a5420a5320a525075520754207532075250f5520f5420f5320f5150c5520a55207552055550a5520a53507552075350a5520a5350f5520f53513552115420c5520f535
01100020115521154211532115250f5520f5420f5320f5250c5520c5420c5320c5250a5520a5420a5320a515075520a5550c5520f55507552075350a5520a5350f5520f5351355213535055520a5420f55213535
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
dddddddd0000000000000000000000000000000000020d651df651d30000000000000000000000000000000000000000000000000000000000000000000000000000000c651df651df651df651d7621df651df65
dddddddd1df651df651d7621df650000000c651df651d30000000000000000500000000000000000000000000000600000000000000000000000000000000c651df651df651df651df651df651df651df6512f65
dddddddd1df651df651df6512f651df651df651df651df651df652dc651df6512f651df651df651df651df651db151df651df651df651df651df651d7621df651df651df651df651df651df651df651df651df65
dddddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df6512f651df651db151df651df651df65
dddddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df652dc651df651df651df651df651df651db151d7621df651d7621df651df651df651df65
ddd2dddd1df651df651df651df651df651df651df651df651d7621df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df65
dd2ddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651d7621df651df651df651df651df651d7621df651df651df651df651df651df651df651df652dc651df651df65
dddddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df6512f651df651df651df651df651df651df651db151df651df65
dddddddd1df651df651df6512f651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651db151df651df651df651df651df651df651df651df651df651df65
dddddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651d7621df651df651df651df651df651df651df651df651df651df651df65
dddddddd1df651df651df651df6512f651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df6512f651df651df651df651df65
dddddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651d7621df651df651df6512f651db151df651df651d7621df651df651df651df651df651df651df651df65
dddddddd1df651df652dc651db151d7621df651df651df651df651df651df651db151df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df652dc651df651df651df65
dddddddd1df651df651df651df651df651df651df6512f651df651df651df6512f651df651df651df651df651df651df651df651df651df651df651df651df651df651db151df651df652dc651df651df651df65
dddddddd1df651df651df651df651db151df651df651d7621df651df651df651d7621d7621df651df651df651df651df651df651df651df651df651df651df651df651df651df652d4621df651d7621df651df65
ddddddd21df651df651df651df651db151df651df651df651df651df651df651df651df651db151df651df651df651df651df651df651df651df651df651df651df651df651df651df651df652dc651df651df65
dddddddd1df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651db151df651df651df651df651df651df651df651df651df651df651df651df651df651df65
dddddddd1df651df651df651df651df651df651df652d8152d8152d8152d8152d8152d8152d8152d8152d8151df651df651df652dc651df651df651df651df651df651df651df651df651df651df651df651df65
dd0000001d300000001df651df651df650200202002020020200202002020020200202002020021df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df651df65
__music__
01 17 42 43 44
00 17 14 43 44
00 1a 14 43 44
00 1a 14 43 44
00 15 13 43 44
00 16 14 43 44
00 16 14 43 44
00 15 14 43 44
00 15 14 43 44
00 16 13 43 44
00 16 13 43 44
00 19 13 43 44
00 19 14 43 44
00 16 14 43 44
00 1b 14 43 44
00 1c 14 43 44
00 16 14 43 44
02 17 14 43 44
00 41 42 43 44
00 16 14 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
