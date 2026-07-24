pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--dami and flo
--by nusan

function rndi(n) -- return random integer value between [1-n]
	return flr(rnd(n)+1)
end

function rndi2(n) -- return random integer value between [1-n] with more chance for higher values
	local v=rnd()
	return n-flr(v*v*n)
end

function getlen(x,y)
	x,y=x*0.1,y*0.1
	return sqrt(x*x+y*y+0.0001)*10
end

function lerp(a,b,c)
	return a*(1-c)+b*c
end

function clamp(v,mi,ma)
	return max(mi,min(ma,v))
end

function pinit(index,model)
 return {x=index*16,y=64,player=index,spr=model,anim=0,speed=0,closest=nil,pile={},ldx=0,ldy=0,dfun=pdraw}
end

pileheight=3
pilelimit=5
pileplayer=10
visiblerequests=10
twoplayers=false
playerone=1
automatic=false
speedboost=1
wagcount=1
timedifficulty=1
itemdifficulty=0
titlemenu=true
menuchar=0
mainmenu=false
menuindex=1
statmenu=false
helpmenu=false
helplaunch=true
helpindex=1
time=0
playmusic=true
lastmusic=-1

dbgtxt=""

menu={}
add(menu,{name="players:",list={"one","two"},index=1})
add(menu,{name="character:",list={"dami","flo"},index=flr(rnd(2))+1})
add(menu,{name="wagons:",list={"1","2","3"},index=1})
add(menu,{name="timer:",list={"none","chill","heavy","capitalist"},index=1})
add(menu,{name="items:",list={"low","mid","high","too much"},index=1})

function modi(a,b)
	return (a-1)%b+1
end

function insertdepth(s,e)
	local ins=false
	for i = #s, 1, -1 do
		if s[i].y<=e.y then
			ins=true
			s[i+1]=e
			break
		end
		s[i+1]=s[i]
 end
	if not ins then
		s[1]=e
	end
end

function shufflefull(t,c)
	if(#t<1) return
	for i=1,c do
		for j=1,#t do
			local r=rndi(#t)
			if j!=t then
				local tmp=t[r]
				t[r]=t[j]
				t[j]=tmp
			end
		end
	end
end

function shuffle(t,c)
	if(#t<1) return
	for i=1,c do
		local r=rndi(#t-1)
		local tmp=t[r]
		t[r]=t[r+1]
		t[r+1]=tmp
	end
end

function getinside(spr)
	for i=1,#inside do
		local ii=inside[i]
		if ii.type==spr then
			return ii
		end
	end
end

function modinside(spr, num)
	local ii=getinside(spr)
	if ii then
		ii.amount+=num
		assert(ii.amount>=0, "total should never be under 0")
		if ii.amount==0 then
			del(inside, ii)
		end
	else
		assert(num>0, "should always add when new item")
		add(inside, {type=spr,amount=num})
	end
	totalinside+=num
end

function removetype(s,type,maxamount)
	local found=0
	-- try first to remove from pile
	local todel={}
	for i=1,#s.pile do
		local it=s.pile[i]
		if it.spr==type and maxamount>0 then
			maxamount-=1
			found+=1
			modinside(it.spr, -1)
			add(todel,it)
		end
	end
	for i=1,#todel do
		del(s.pile,todel[i])
	end
	-- then try remove the base
	if not s.player then
		if s.spr==type and maxamount>0 then
			maxamount-=1
			found+=1
			modinside(s.spr, -1)
			if #s.pile>0 then
				-- if there is still objects in the stack, swap one
				local re=s.pile[#s.pile]
				del(s.pile,re)
				s.spr=re.spr
			else
				-- if there is nothing left, remove the whole stack
				remcache(s)
				del(stacks,s)
			end
		end
	end
	return found
end

function addstack(s)
	for i=1,#s.pile do
		local it=s.pile[i]
		modinside(it.spr, 1)
	end
	modinside(s.spr, 1)
	add(stacks,s)
	addcache(s)
end

function spawnpile(w,xx,yy,n,diversity)
		local sp=rndi(flr(diversity))
		local subpile={}
		for k=1,n-1 do
			add(subpile, {x=0,y=0,spr=pool[sp],pile={},dfun=sdraw})
			if rnd()<0.3 then
				sp=rndi(flr(diversity))
			end
		end
		add(w.inputs, {x=xx,y=yy,spr=pool[sp],pile=subpile,dfun=sdraw})
end

function fillinputs(w, total, diversity)
	diversity=min(diversity,64)
	-- spawn everywhere
	local v={}
	for i=1,16 do
		local c=total>0 and rndi(min(total,5)) or 0
		add(v,c)
		total-=c
	end
	shufflefull(v,5)
	for i=1,4 do
		for j=1,4 do
			local c=v[i+(j-1)*4]
			if c>0 then
				spawnpile(w, w.offx+i*8-16, 88+j*8, c, diversity)
			end
		end
	end
end

function fillrequests(w,num,pool)
	w.requests={}
	for i=1,num do
		-- pop last array element
		local ii = inside[pool[#pool]]
		pool[#pool]=nil
		local am=rndi(min(6,ii.amount))
		if rnd()<.1 then
			-- some times, more chance to request a large amount
			am=rndi2(ii.amount)
		end
		add(w.requests, {type=ii.type, amount=am, anim=0})
	end
end

function cachecoord(x,y)
	--return flr((x)/8),flr((y)/8)
	return flr((x)/32),flr((y)/32)
end

function getclosecells(x,y)
	local r={}
	pushcachecell(r,x-15,y-15)
	pushcachecell(r,x+16,y-15)
	pushcachecell(r,x-15,y+16)
	pushcachecell(r,x+16,y+16)
	return r
end

function addcache(s)
	local px,py=cachecoord(s.x,s.y)
	local line=cache[px]
	if line==nil then
		cache[px]={}
		line=cache[px]
	end
	local cell=line[py]
	if cell==nil then
		line[py]={}
		cell=line[py]
	end
	add(cell,s)
	cacheminx=min(cacheminx,px)
	cachemaxx=max(cachemaxx,px)
	cacheminy=min(cacheminy,py)
	cachemaxy=max(cachemaxy,py)
end

function remcache(s)
	local px,py=cachecoord(s.x,s.y)
	local line=cache[px]
	if line==nil then
		return
	end
	local cell=line[py]
	if cell==nil then
		return
	end
	del(cell,s)
end

function buildcache()
	cache={}
	cacheminx,cachemaxx,cacheminy,cachemaxy=0,0,0,0
	for i=1,#stacks do
		addcache(stacks[i])
	end
end

function pushcachecell(t,x,y)
	local px,py=cachecoord(x,y)
	local line=cache[px]
	if line!=nil then
		local cell=line[py]
		if cell!=nil then
			add(t,cell)
		end
	end
end

function getcachecell(x,y)
	local px,py=cachecoord(x,y)
	local line=cache[px]
	if line!=nil then
		local cell=line[py]
		if cell!=nil then
			return cell
		end
	end
	return nil
end

function startgame()

		cx,cy,cof=64,60,0

		mainmenu=false

		moving = true
		time=0
		chronoon=true
		phasemove = 150
		phasestop = 150
		moveduration = 3000-timedifficulty*500
		stopduration = 1250-timedifficulty*250
		if timedifficulty==0 then
			stopduration = 150
		end
		trainpos=0
		trainspeed=1

		pmusic(0,1000)

		stacks={}
		cache={}

		p1=pinit(0,playerone==1 and 112 or 96)
		add(stacks,p1)
		addcache(p1)
		if twoplayers then
			p2=pinit(1,playerone==1 and 96 or 112)
			add(stacks,p2)
			addcache(p2)
		end

		inamount=0
		reqamount=0

		packagedelivered=0
		stopcompleted=0
		packagelost=0
		inputlost=0
		goaldiversity=itemdifficulty==0 and 3 or 5
		goalvariation=({500,1000,2000,4000})[itemdifficulty+1]
		goalinside=30
		mulgoal,decgoal=1.1,0.05 -- 207
		muldiv,decdiv=1.1,0.07 -- 11
		--1.2/0.08
		if itemdifficulty==1 then
			mulgoal,decgoal=1.1,0.04 -- 331
			muldiv,decdiv=1.03,0.03 -- 12
		elseif itemdifficulty==2 then
			mulgoal,decgoal=1.2,0.065 -- 555
			muldiv,decdiv=1.04,0.03 -- 17
		elseif itemdifficulty==3 then
			mulgoal,decgoal=1.3,0.08 -- 977
			muldiv,decdiv=1.05,0.03 -- 24
		end

		itemnumber=64
		totalinside=0
		inside={}
		pool={}
		for i=1,itemnumber do
			pool[i]=i
		end
		shufflefull(pool, 50)

		wagons={}
		for i=1,wagcount do
			add(wagons, {offx=(i-1)*192,requests={},inputs={}})
		end

		-- clear map for not used wagons (will need reload to have them back)
		local numw=#wagons
		for j=0,11 do
			memset(0x2000+numw*24+j*128,0,24)
		end

		message=""
		lastmessage=0

		--buildcache()
end

function _init()

	menuitem(1,"show stats",function () statmenu=true music(-1,300) end)
	menuitem(2,"help",function () helpmenu=true helplaunch=false helpindex=1 music(-1,300) end)
	menuitem(3,"toggle music",function () playmusic=not playmusic updatemusic() end )
	menuitem(4,"quit",function () titlemenu=true townmusic(1000) end)
	menuitem(5,"im stuck",function ()
			if p1 then
				p1.x,p1.y=flr(rnd(160)-80),flr(rnd(96))+32
			end
			if p2 then
				p2.x,p2.y=flr(rnd(160)-80),flr(rnd(96))+32
			end
	 end)

	if not titlemenu then
		startgame()
	end
	townmusic(1000)
end

function getclosest(x,y,maxdist)
	local cells=getclosecells(x,y)
	local closestdist=maxdist
	local closest=nil
	for i=1,#cells do
		local c=cells[i]
		for k=1,#c do
			local s=c[k]
			local cd = max(abs(s.x-x),abs(s.y-y))
			if cd<closestdist then
				closest=s
				closestdist=cd
			end
		end
	end
	return closest
end

function limittrain(x,y)
	local offx=0
	for i=1,#wagons do
		if x+88>wagons[i].offx then
			offx=wagons[i].offx
		end
	end
	if (x<offx-80 or x>offx+88) and (y>70 and y<82) then
		y=clamp(y,72,80)
	else
		x=clamp(x,offx-80,offx+88)
		y=clamp(y,32,120)
	end
	x=clamp(x,-88,-92+192*#wagons)
	return x,y
end

function playnote(s,n)
	local location=0x3200+s*68
	local prev=peek(location)
	prev-=prev%64
	prev+=12+({0,2,4,5,7,9,11,12,14,16})[modi(n,10)]
	poke(location, prev)
	sfx(s)
end

function psfx(n)
	sfx(n)
end

function townmusic(f)
	pmusic(rnd()>0.5 and 7 or 8, f)
end

function pmusic(m,f)
	lastmusic=m
	if playmusic then
		music(m,f)
	else
		if m==0 or m==1 then
			music(0,f)
		elseif m==-1 then
			music(-1,f)
		end
	end
end

function updatemusic()
	if playmusic then
		music(lastmusic,500)
	else
		if lastmusic==0 then
		elseif lastmusic==1 then
			music(0,500)
		else
			music(-1,500)
		end
	end
end

function pup(p)

  local dx,dy = 0,0

 	if(btn(0,p.player)) dx -= 1
 	if(btn(1,p.player)) dx += 1
 	if(btn(2,p.player)) dy -= 1
 	if(btn(3,p.player)) dy += 1

 	local dl = 1.7/getlen(dx,dy)

 	dx *= dl
 	dy *= dl

  p.anim += (abs(dx)<.1 and abs(dy)<.1) and 0 or 1

  if abs(dx)>0 or abs(dy)>0 then
			p.speed=lerp(p.speed,1,0.2)
   p.ldx = dx
   p.ldy = dy
		else
			p.speed=lerp(p.speed,0,0.5)
  end
		dx*=p.speed
		dy*=p.speed

  local npx,npy=p.x+dx,p.y+dy
  local colstack=nil
  local coldist=5
		local cellscol=getclosecells(npx,npy)
		for j=1,#cellscol do
			local c=cellscol[j]
			for k=1,#c do
				local s=c[k]
				if s != p then
					local cd = max(abs(s.x-npx),abs(s.y-npy))
					if cd<coldist then
						colstack=s
						coldist=cd
					end
				end
				if colstack then
					if abs(colstack.x-p.x)>abs(colstack.y-p.y) then
						if(colstack.x>p.x) dx=min(dx,0)
						if(colstack.x<p.x) dx=max(dx,0)
					else
						if(colstack.y>p.y) dy=min(dy,0)
						if(colstack.y<p.y) dy=max(dy,0)
					end
				end
			end
		end

		remcache(p)
  p.x+=dx
  p.y+=dy
		p.x,p.y=limittrain(p.x,p.y)
		addcache(p)

  p.closest=nil
  local closestdist=5
		local cpx,cpy=limittrain(p.x+p.ldx*5,p.y+p.ldy*5)
		local cells=getclosecells(cpx,cpy)
		for j=1,#cells do
	  local c=cells[j]
	  for k=1,#c do
    local s=c[k]
				if s != p then
	    local cd = max(abs(s.x-cpx),abs(s.y-cpy))
	    if cd<closestdist then
	     p.closest=s
	     closestdist=cd
	    end
	   end
	  end
		end

  -- pickup object
  if btnp(4,p.player) then
   if p.closest then
    local pile = p.closest.pile
				if #p.pile<pileplayer then
	    if #pile>0 then
	     local ns=pile[#pile]
	     del(pile,ns)
	     add(p.pile,ns)
	    elseif not p.closest.player then
						remcache(p.closest)
	     del(stacks,p.closest)
	     add(p.pile,p.closest)
						p.closest=nil
	    end
					playnote(8,#p.pile)
				else
					psfx(10)
				end
    --[[
    -- long press, pickup the whole pile
				remcache(p.closest)
    del(stacks,p.closest)
    local pile = p.closest.pile
    for i=1,#pile do
     add(p.pile,pile[i])
    end
    p.closest.pile={}
    add(p.pile,p.closest)
    ]]
   end
  end

  -- drop object
  if btnp(5,p.player) then
   local num = #p.pile
   if num>0 then
    local top = p.pile[num]
    if p.closest then
     -- drop on existing pile
					local cpl=p.closest.player and pileplayer or pilelimit-1
					if #p.closest.pile<cpl then
	     add(p.closest.pile,top)
						del(p.pile,top)
						playnote(9,#p.closest.pile+1)
					else
						psfx(11)
					end
    else
     -- drop on the ground
     top.x = p.x+p.ldx*5
     top.y = p.y+p.ldy*5
					top.x,top.y=limittrain(flr(top.x/8+.5)*8,flr(top.y/8+.5)*8)
     add(stacks, top)
					addcache(top)
					--insertdepth(stacks,top)
					del(p.pile,top)
					playnote(9,1)
    end
   end
  end

end

function satisfaction()
	-- try to satisfy requests
	for i=1,#wagons do
		local w=wagons[i]
		local sat={}
		local rsx,rsy=w.offx+4,32
		-- find stacks in request bay
		local closeenough={}

		if automatic and true then
			-- cheat, everything is possible
			for j=1,#stacks do
				add(closeenough,stacks[j])
			end
		else
			local cells=getclosecells(rsx,rsy)
			local closestdist=maxdist
			local closest=nil
			for j=1,#cells do
				local c=cells[j]
				for k=1,#c do
					local s=c[k]
					local cd = max(abs(s.x-rsx)-16,abs(s.y-rsy)-10)
					if cd<0 then
						add(closeenough,s)
					end
				end
			end
		end
		-- requests loop
		for j=1,min(#w.requests,visiblerequests) do
			local rr = w.requests[j]
			if rr.amount>0 then
				local haschanged=false
				for k=1,#closeenough do
					local cs=closeenough[k]
					if cs!=nil then
						local found=removetype(cs,rr.type,rr.amount)
						if found>0 then
							haschanged=true
						end
						rr.amount-=found
					end
				end
				if rr.amount<=0 then
					packagedelivered+=1

					if packagedelivered==3 or packagedelivered==10 or packagedelivered%50==0 then
						message="bravo "..packagedelivered.." packages delivered!"
						lastmessage=300
					end

					psfx(12)
					rr.anim=50
				elseif haschanged then
					psfx(13)
					rr.anim=5
				end
			else
				if rr.anim<=0 then
					add(sat,rr)
				end
			end
			if rr.anim>0 then
				rr.anim-=1
			end
		end
		-- satisfied
		for j=1,#sat do
			del(w.requests,sat[j])
		end
	end
end

function _update()

	if titlemenu then
		if btnp(4) or btnp(5) then
			titlemenu=false
			mainmenu=true
			psfx(12)
		end
		time+=1
		if menuchar<0.95 then
			menuchar+=0.05
		end
		return
	end

	if mainmenu then
		local lmi=menuindex
		if(btnp(3)) menuindex+=1
		if(btnp(2)) menuindex-=1
		menuindex=modi(menuindex,#menu)
		if(lmi!=menuindex) playnote(9,menuindex)

		local lmi2=menu[menuindex].index
		if(btnp(0)) menu[menuindex].index-=1
		if(btnp(1)) menu[menuindex].index+=1
		menu[menuindex].index=modi(menu[menuindex].index,#(menu[menuindex].list))
		if(lmi2!=menu[menuindex].index) playnote(8,menu[menuindex].index+4)

		if btnp(4) or btnp(5) then
			mainmenu=false
			menuchar=0
			twoplayers=menu[1].index==2
			playerone=menu[2].index
			wagcount=menu[3].index
			timedifficulty=menu[4].index-1
			itemdifficulty=menu[5].index-1
			psfx(12)
			helpmenu=true
			helplaunch=true
			helpindex=1
		end
		time+=1
		if menuchar>0 then
			menuchar-=0.1
		end
		return
	end

	if statmenu then
		if btnp(4) or btnp(5) then
			statmenu=false
			updatemusic()
		end
		return
	end

	if helpmenu then
		if btnp(4) or btnp(5) then
			helpindex+=1
			if helpindex>3 then
				helpmenu=false
				updatemusic()
				if helplaunch then
					startgame()
				end
				psfx(12)
			else
				psfx(9)
			end
		end
		return
	end

	--buildcache()

	-- packet delivery on time
	if time%10==0 or automatic then
		for i=1,#wagons do
			local w=wagons[i]
			if #w.inputs>0 then
				local ns=w.inputs[rndi(#w.inputs)]
				if getclosest(ns.x,ns.y,5) == nil then
					addstack(ns)
					del(w.inputs,ns)
					psfx(14)
				else
					ns.x=w.offx+rndi(4)*8-16
					ns.y=88+rndi(4)*8
					if automatic then
						ns.x=w.offx+(rndi(22)-11)*8
						ns.y=88+(rndi(11)-7)*8
					end
				end
			end
		end
	end

chronoon=true

	if moving then
		if phasemove>0 then
			phasemove-=1*speedboost
			if phasemove==1000 then
				local maxreq=clamp(flr(goalinside*0.03),3,10)
				reqamount = clamp(flr((totalinside-goalinside*wagcount)*0.1+5),3,maxreq)
				local amper = min(reqamount,flr(#inside/#wagons))
				local pool={}
				for i=1,#inside do
					add(pool,i)
				end
				shufflefull(pool,5)
				for i=1,#wagons do
					fillrequests(wagons[i],amper,pool)
				end
			end
		else
			phasemove=moveduration
			moving=false
			-- train stops
			local maxam=clamp(flr(goalinside*0.15),30,60)
			inamount = clamp(flr((goalinside*wagcount-totalinside)*0.2+20),10,maxam)
			for i=1,#wagons do
				fillinputs(wagons[i], inamount, goaldiversity)
				shuffle(pool, goalvariation)
			end
			pmusic(-1,500)
		end
	else
		satisfaction()
		local reqleft = 0
		local inleft = 0
		for i=1,#wagons do
			reqleft += #wagons[i].requests
			inleft += #wagons[i].inputs
		end
		if phasestop>0 then
			if phasestop==110 and timedifficulty==0 then
				-- pause chrono if not finished
				if reqleft>0 or inleft>0 then
					chronoon=false
				end
			end
			if chronoon then
				phasestop-=1*speedboost
			end
			if phasestop==stopduration-20 then
				townmusic(3000)
			end
			if phasestop==100 then
				pmusic(-1,3000)
			end
			if phasestop==60 then
				psfx(15)
			end
		else
			--temptext=""..reqleft.." "..inleft
			-- can we quit the station?
			if timedifficulty>0 or (reqleft==0 and inleft==0) then
				-- when start moving, remove all requests and pending inputs left
				local curlostp=0
				local curlosti=0
				for i=1,#wagons do
					for j=1,#wagons[i].requests do
						local ci=wagons[i].requests[j]
						if ci.amount>0 then
							curlostp+=1
						end
					end
					curlosti+=#wagons[i].inputs
					wagons[i].requests={}
					wagons[i].inputs={}
				end
				packagelost+=curlostp
				inputlost+=curlosti
				if curlostp>0 then
					if curlosti>0 then
						message="you lost "..(curlostp+curlosti).." things"
					else
						message="you missed "..curlostp.." deliveries"
					end
					lastmessage=300
				elseif curlosti>0 then
					message="you lost "..curlosti.." inputs"
					lastmessage=300
				end
				moving=true
				phasestop=stopduration
				-- train starts moving
				stopcompleted+=1
				--update goals
				goalinside*=mulgoal
				mulgoal=lerp(mulgoal,1,decgoal)
				goaldiversity*=muldiv
				muldiv=lerp(muldiv,1,decdiv)

				pmusic(0,1000)
			end
		end
	end

 pup(p1)
 if(p2) pup(p2)

	if moving then
		if phasemove>150 then
			trainspeed=lerp(trainspeed, 1,0.01)
		else
			trainspeed=lerp(trainspeed, 0,0.02)
		end
	else
		trainspeed=0
	end

	-- train track sound
	local sfxspd=flr(20-trainspeed*16)
	dbgtxt=sfxspd
	poke(0x3244+0x41, sfxspd)
	if sfxspd==4 then
		if prevsfxspd==5 then
			pmusic(1)
		end
	else
		if prevsfxspd==4 then
			pmusic(0)
		end
	end
	--[[
	if sfxspd==4 then
		poke(0x3100+1,3+128)
		poke(0x3100+2,4)
	else
		poke(0x3100+1,3+128+64)
		poke(0x3100+2,4+64)
	end
	]]--
	prevsfxspd=sfxspd

	--trainpos+=(sin(time*0.001)*0.5+0.5)*0.5
	trainpos+=trainspeed*0.5
	time+=1

	if lastmessage>0 then
		lastmessage-=1
	end

	-- check if inside, stacks and cache are coherent
	if false then
		for i=1,#inside do
			local cur=inside[i]
			local count=0
			for j=1,#stacks do
				local sc=stacks[j]
				if sc.spr==cur.type then
					count+=1
				end
				for k=1,#sc.pile do
					if sc.pile[k].spr==cur.type then
						count+=1
					end
			 end
			end
			assert(count==cur.amount, "error "..cur.type..":"..count.."!"..cur.amount)
		end
	end

end

function drawpile(p,px,py)
  for i=1,#p.pile do
   spr(p.pile[i].spr-1, px-4, py-7-i*pileheight)
  end
end

function bspr(n,x,y,c)
	for i=1,15 do
		pal(i,c)
	end
	spr(n, x-1,y)
	spr(n, x+1,y)
	spr(n, x,y-1)
	spr(n, x,y+1)
	pal()
	spr(n, x,y)
end

function bprint(t,x,y,c,cb)
	print(t,x-1,y,cb)
	print(t,x+1,y,cb)
	print(t,x,y-1,cb)
	print(t,x,y+1,cb)
	print(t,x,y,c)
end

function dinfo(p)
 if p then
		if p.closest then
			local cpx,cpy=persp(p.closest.x,p.closest.y)
			local ofy=pileheight*#p.closest.pile
	  rect(cpx-5,cpy-5-ofy,cpx+4,cpy+4,7)
			if not p.closest.player then
				bprint(#p.closest.pile+1,cpx-1,cpy-ofy-11,7,1)
			end
		end
		if #p.pile>0 then
			local cpx,cpy=persp(p.x+p.ldx*3,p.y+p.ldy*3)
			local ofy=pileheight*#p.pile
			bprint(#p.pile,cpx-(#p.pile>9 and 3 or 1),cpy-ofy-12,15,1)
		end
 end
end

function pdraw(p,x,y)

	local px,py=persp(p.x,p.y)
 if not p.closest and #p.pile>0 then
		local cpx,cpy=p.x+p.ldx*5,p.y+p.ldy*5
		--local tmpx,tmpy=persp(cpx,cpy)
		--rectfill(tmpx-4,tmpy-4,tmpx+3,tmpy+3,8)
		cpx,cpy=limittrain(flr(cpx/8+.5)*8,flr(cpy/8+0.5)*8)
  local dx,dy=persp(cpx,cpy)
  rect(dx-4,dy-4,dx+3,dy+3,6)
 end

	local ppx,ppy=persp(p.x+p.ldx*3,p.y+p.ldy*3)
 if p.ldy<0 then
  drawpile(p,ppx,ppy)
 end

 local left=p.ldx>0
 local off = p.spr
 spr(off+1,px-4,py-11+sin(p.anim*.1+.1)*1.2,1,1,left)
 spr(off,px-4,py-14+sin(p.anim*.1)*1.2,1,1,left)
 spr(off+2,px-4+cos(p.anim*.1)*2.2,py-6,1,1,left)
 spr(off+2,px-4+sin(p.anim*.1+0.2)*2.2,py-7,1,1,left)
 --pset(p.x,p.y,8)

 --dinfo(p)

 if p.ldy>=0 then
  drawpile(p,ppx,ppy)
 end

end

function sdraw(s,x,y)
	--rect(s.x-5,s.y-5-pileheight*#s.pile,s.x+4,s.y+4,0)
 spr(s.spr-1, x-4,y-4)
 for i=1,#s.pile do
  local s2=s.pile[i]
  spr(s2.spr-1, x-4,y-4-i*pileheight)
 end
end

function perspx(x,y)
	return x - (x-cx+cof)*(1-(y)/64)*.5
end

function persp(x,y)
	--y = y*.8+26
	x = perspx(x,y)
	return x,y
end

function dlinequad(px11,px12,py1,px21,px22,py2,c)
	local d=py2-py1
	for i=py1,py2 do
		local p=(i-py1)/d
		local px1=px11+(px12-px11)*p
		local px2=px21+(px22-px21)*p
		rectfill(px1,i,px2,i,c)
	end
end

function dbackground(bgbase)
	local bgx=(bgbase*0.3)%128
	rectfill(0,20,128,128,3)
	pal(3,6)
	rectfill(0,14,128,14,6)
	map(bgx/8-8,19,-64-bgx%8,6,32,1)
	bgx=(bgbase*0.4+70)%128
	pal(3,11)
	rectfill(0,17,128,17,11)
	map(bgx/8-8,19,-64-bgx%8,9,32,1)
	pal()
	bgx=(bgbase*0.5+32)%128
	map(bgx/8-8,19,-64-bgx%8,12,32,1)

	bgx=(bgbase*0.7+32)%128
	map(bgx/8-8,17,-64-bgx%8,14,32,2)
end

function drawview()
		camera()

		-- background
		dbackground(cx+trainpos*16)

		camera(cx-64,cy-64)

		-- ground rails
		local gstart=(cx/16+trainpos)%16
		--for j=0,111 do
		for j=49,78 do
		--for j=0,16 do
			local py=j
			local p1x=perspx(cx-75,py)
			local p2x=perspx(cx+75,py)
			local speed=151/((p2x-p1x)*16)
			tline(p1x-2,py+16,p2x-2,py+16, gstart, j/8+14, speed)
		end

		-- station
		local gof=phasemove
		if phasemove>moveduration*0.5 then
			gof = phasemove-moveduration
		end
		if gof<300 then
			gof*=0.15
			gof=gof*abs(gof)
			pal(15,9)
			if not moving then
				pal(9,1)
			end
			for i=1,#wagons do
				local stationx = perspx(-232+24*8*i+gof,8+24)
				map(8,13,stationx,8,8,3)
			end
			pal()
		end

		-- requests display
		for i=1,#wagons do
			local w=wagons[i]
			local rx,ry=w.offx-56,30
			local vreq=min(#w.requests,visiblerequests)
			--vreq=10
			for j=0,vreq-1 do
				local rr = w.requests[j+1]
				--local rr = {amount=rndi(52),type=12+j}
				local prx,pry=persp(rx+32*(j%5+(5-min(vreq,5))*0.5),ry)
				pry-=9*flr(j/5)
				local sdr=rr.amount.."X"
				local ppy= pry-20+sin(rr.anim*0.1)*3
				bprint(sdr,prx-#sdr*4,ppy,rr.amount>0 and 7 or 5,0)
				bspr(rr.type-1,prx,ppy-3,0)
			end
		end

		-- train
		----[[
		for j=0,95 do
			local py=j+28
			local p1x=perspx(cx-90,py)
			local p2x=perspx(cx+91,py)
			local speed=182/((p2x-p1x)*8)
			tline(p1x-2,py,p2x-2,py, cx/8, j/8, speed)
		end
		--]]

		--[[
	 for i=1,#stacks do
	  local s=stacks[i]
			local sx,sy=persp(s.x,s.y)
	  s.dfun(s,sx,sy)
	 end
		--]]

		-- sort depth per cell
		--[[
		for i=cacheminx,cachemaxx do
			local line=cache[i]
			if line!=nil then
				for j=cacheminy,cachemaxy do
					local cell=line[j]
					if cell!=nil then
						local sortedcell={}
						for k=1,#cell do
							insertdepth(sortedcell,cell[k])
						end
						line[j]=sortedcell
					end
				end
			end
		end
		--]]

		-- find all stacks in view
		-- and insert them into their respective y line
		-- so they can be displayed sorted
		local renderlines={}
		local r={}
		for i=-3,3 do
			pushcachecell(r,cx+i*32,32)
			pushcachecell(r,cx+i*32,64)
			pushcachecell(r,cx+i*32,96)
		end
		for i=1,#r do
			local cell=r[i]
			for k=1,#cell do
				local elem=cell[k]
				local idx=flr(elem.y)
				--print(idx,i*12+30,k*6,10)
				local curline=renderlines[idx]
				if curline==nil then
					renderlines[idx]={}
					curline=renderlines[idx]
				end
				add(curline,elem)
			end
		end
		-- render stacks of each line from back to front
		for i=32,127 do
			local curline=renderlines[i]
			--print(curline,0,i*6,12)
			if curline!=nil then
				for k=1,#curline do
					local elem=curline[k]
					local sx,sy=persp(elem.x,elem.y)
					elem.dfun(elem,sx,sy)
					--rect(sx-4,sy-4,sx+4,sy+4,8)
				end
			end
		end

		dinfo(p1)
		dinfo(p2)
end

function clock(t)
	local sec = flr(t/30+1)
	local min = ""..flr(sec/60)
	sec=""..sec%60
	sec=#sec==1 and "0"..sec or sec
	min=#min==1 and "0"..min or min
	return ""..min..":"..sec
end

function paragraph(px,py,t)
	foreach(t, function(a)
		print(a,px,py,7)
		py+=(#a>0 and 6 or 3)
		end)
end

function _draw()

	if titlemenu or mainmenu then

		cls(13)
		dbackground(t()*30)
		rectfill(0,36,128,128,1)

		-- mini train
		local px,py=36,20
		line(0,py+13,128,py+13,5)
		line(0,py+14,128,py+14,5)
		line(0,py+15,128,py+15,0)
		for i=0,2 do
			spr(236,px+i*14,py+sin((t()+i)*1.2),2,2)
		end
		py=py+sin((t()+3)*1.2)
		spr(238,px+42,py,2,2)
		spr(139,px+58,py,1,2)


		if mainmenu then
			local mx,my=10,27+menuindex*14
			rect(mx-2,my-2,mx+108,my+12,14)
			for i=1,#menu do
				local m=menu[i]
				local mx,my=10,27+i*14
				print(m.name,mx,my,7)
				--mx += #m.name*4+10
				my+=6
				for j=1,#m.list do
					local cur=m.list[j]
					if j==m.index then
						rectfill(mx-1,my-1,mx+#cur*4-1,my+5,13)
					end
					print(cur,mx,my,7)
					mx+=#cur*4+4
				end
			end
		end

		if titlemenu then
			print("by nusan",42,123-menuchar*menuchar*60,6)
			px,py=174-menuchar*menuchar*60,50
			circfill(px,py-1,12,2)
			circfill(px,py-1,9,1)
			circ(px,py-1,11,8)
			--spr(123,px-8,py-6,2,1)
			bspr(123,px-8,py-6,2)
			bspr(124,px,py-6,2)
			bspr(171,px-3,py,2)
		end

		-- character portraits
		px,py=menuchar*menuchar*60-60,64
		spr(128,px,py,6,8)
		px=80-menuchar*menuchar*60+60
		spr(134,px,py,5,8)
		spr(187,px+40,py+24,1,5)

		-- title
		px,py=38,11+menuchar*menuchar*28
		py+=sin(t()*0.2+.5)*3

		-- title border
		for i=1,15 do
			pal(i,0)
		end
		spr(140,px+1,py,4,3)
		spr(188,px+33,py,4,3)
		spr(140,px-1,py,4,3)
		spr(188,px+31,py,4,3)
		spr(140,px,py+1,4,3)
		spr(188,px+32,py+1,4,3)
		spr(140,px,py-1,4,3)
		spr(188,px+32,py-1,4,3)
		pal()

		-- title
		spr(140,px,py,4,3)
		spr(188,px+32,py,4,3)

		--line(0,113,128,113,13)
		local ban=menuchar
		if mainmenu then
			ban=(ban-0.5)*2
		end
		px,py=24,126-ban*ban*10
		rectfill(px-1,py-1,px+83,py+5,1)
		print("press x or c to start",px,py,time%30<15 and 6 or 14)
		return
	end

	if statmenu then
		rectfill(8,8,120,122,1)
		print("statistiques:",10,10,7)
		print("packages:",12,18,7)
		print("delivered:",16,24,7)
		print(packagedelivered,90,24,7)
		print("missed:",16,30,7)
		print(packagelost,90,30,7)

		print("inputs lost:",12,38,7)
		print(inputlost,90,38,7)

		print("stations visited:",12,46,7)
		print(stopcompleted,90,46,7)
		print("current content:",12,54,7)
		print(totalinside,90,54,7)
		local bpx=11
		local px,py=bpx,62
		local tt=#inside
		for i=1,min(35,tt) do
		 local ci=inside[i]
			spr(ci.type-1,px,py)
			print(min(ci.amount,99),px+9,py+3,7)
			if modi(i,6)==6 then
				px=bpx
				py+=10
			else
				px+=18
			end
		end
		if tt>35 then
			print("...",px+3,py+3,7)
		end
		return
	end

	if helpmenu then
		cls(1)
		if helpindex==1 then
			paragraph(6,10,{"dami and flo are two workers","on a delivery train"
			,"","at each station, they have to","take input packages at the","bottom and store them","somewhere in the wagon"
			,"","delivery requests for the next","station are displayed at the","top of the screen"})

			print("stock",55,97,6)
			print("input",55,120,9)
			print("output",54,77,8)
			line(32,116,46,85,6)
			line(32,116,96,116,6)
			line(96,116,82,85,6)
			line(46,85,82,85,6)
			line(56,108,72,108,9)
			line(72,108,74,116,9)
			line(54,116,56,108,9)
			line(54,116,74,116,9)
			line(61,85,69,85,8)
			line(60,90,70,90,8)
			line(60,90,61,85,8)
			line(69,85,70,90,8)
		elseif helpindex==2 then
			paragraph(6,10,{"between stations, take your","time to sort and store all the","packages in the wagon"
			,"","clear the input area as fast","as possible so new packages","can be inserted at next stop"
			,"","you can drop off requested","items in the output area, they","will be picked up","automatically at next station"
		 ,"","you can stack items on the","ground up to 5 items high"
			,"","your character can carry up to","10 items at a time"})
		else
			paragraph(6,10,{"controls:"
			,"","player 1:","   pick: z or c or n","   drop: x or v or m","   move: arrow keys"
			,"","player 2:","   pick: left shift","   drop: tab or w or q or a","   move: s+f+e+d"
			,"","enter: open main menu","   to see stats","   or toggle music"
		 ,"","","have fun"})
		end
		print(helpindex.."/3",110,120,7)
		return
	end

	cls(13)
	cof=0
	if p2 then
		-- two player mode
		local center=(p1.x+p2.x)*.5
		if abs(p1.x-p2.x)>64 then
			clip(0,0,64,127)
			--cof=32
			cx=min(p1.x,p2.x)+32
			drawview()
			clip(65,0,127,127)
			--cof=-32
			cx=max(p1.x,p2.x)-32
			drawview()
			clip()
			camera()
			rectfill(64,0,64,127,6)
		else
			cx=center
			drawview()
		end
	else
		cx=p1.x
		drawview()
	end

	camera()

	if moving then
		bprint("next stop: "..clock(phasemove),32,1,15,1)
	else
		if chronoon then
			bprint("departure: "..clock(phasestop),32,1,(phasestop<300 and timedifficulty>0 and phasestop%30<15) and 8 or 7,1)
		else
			bprint("waiting for delivery",32,1,8,1)
		end
	end

	if lastmessage>0 then
		bprint(message,64-#message*2,128-min(8,min(lastmessage,292-lastmessage)),7)
	end

	if false then
	 print("cpu "..flr(stat(1)*100),98,0,8)
		--print(stopcompleted.." stops "..packagedelivered.." packages",64,6,7)
		if temptext then
			print(temptext,0,120,7)
		end

		if moving then
			print("move "..phasemove,0,0,7)
		else
			print("pause "..phasestop,0,0,7)
		end
		print(totalinside.." "..#inside,0,6,7)
		print("in:"..inamount.." out:"..reqamount,0,12,8)
		print(goalinside*wagcount.." "..goaldiversity.." "..goalvariation,0,18,7)

		--[[
		for i=1,#inside do
			local cur=inside[i]
			local count=0
			for j=1,#stacks do
				local sc=stacks[j]
				if sc.spr==cur.type then
					count+=1
				end
				for k=1,#sc.pile do
					if sc.pile[k].spr==cur.type then
						count+=1
					end
				end
			end
			print(cur.type..":"..count.."!"..cur.amount,flr(i/17)*40,(i%17)*6+18,count==cur.amount and 7 or 8)
		end
		]]

		--[[
		for i=1,#stacks do
			local cur=stacks[i]
			print(cur.spr,40,i*6+18,9)
		end
		]]

end

end
__gfx__
c9cc9cc988888888cccccaccccddcccc53335335000d7000002ee200000b00000088880000ffff0000bbbb0000cccc0000a000a00000000000fe820000bbb000
cc9c9c9c89999998cccaaccaccdccc4435353353000d7700e2eeee2e00b3b000088ee8800ff66ff00bb66bb00cc66cc00aaaaaa000000000000820000b333b00
ccc9a9cc89555598ccaaacaccdccc44435533353000d77002e7ee7e20b333b0088e7e822ff676f99bb676b33cc676cdd0a7aa7aa00aaaa0000082000b33333bb
c99a7a9989999998caa8aaac444c4cc433355353d00d000d2eeeeee2b33333b088ee8822ff66ff99bb66bb33cc66ccddaaaaaaaaaa4444aa00fe8200b333333b
ccc9a9cc89999598caaaacac4444cccc553553355dddddddee4ee4ee0b333b00288882219ffff9943bbbb331dccccdd1aa4aa4aaa400004a0077820033333333
cc9c9c9c89999998ccaaacca444ccccc3555355305ddddd54ee44ee4b33333b01222222149999994133333311dddddd14aa44aa4aa0000aa0077820053333333
c9cc9cc988888888cccccacccccccccc33533535005555500eeeeee00333330001222210049999400133331001dddd100aaaaaa044aaaa440077820005333355
22222222222222222222222222222222222222224444444404444440004440000011110000444400001111000011110004444440004444000022210000555500
0077700000eee00000777000007770000000000000049f40006000607777700006dd6000e0066660000ff0000004000000040000007000000000086000224400
07000a000e00080007000a0007000a0004f9404404f9f9f4666666606558600006dd60000e6ddd6d0fff9ff008e488000b64bb000a7000000008868802442440
88a8a888ff8f8fffbbababbbccacaccc4f9f949f4f9f9f9f6557576565b5677706dd606006ed556df9ffff9f8ef2e880b6f26bb009a000000868688b244f4240
aa9aa9aa88988988aafaafaaaa9aa9aaf9f9f999f99444f9655575656c5b6556066660066dde56d5fff9ffff88ee8880bb66bbb004aa0000088886b32444f424
88889888ffff9fffbbbbfbbbcccc9ccc999f9f999f4000496555576565c565c6056650066d556d5549fff9f488888880bbbbbbb0049a000088688b3322444f42
8888a888ffff8fffbbbbabbbccccaccc4999999499f9f9f96555556565556556005500066d56dd5024f9ff42288888203bbbbb30044aa00a6886b33302444442
8888a888ffff8fffbbbbabbbccccaccc49949994499f9994666666656666666600050065666d5500024444202288822033bbb3300049aa94bbbb333002244442
222222229999999933333333dddddddd04404440044444405555555555555555000055500dd55000002222000222220003333300000444400333330000222220
000000000055000007d77d700006660000bb670000055500000535000005d5000ff00ff00004000000ffff000dd000d00000000000667700333b333306666660
600d000005dd50000d7ee7d0006555d00b333370005bbb50000535000005d50009f009f0004f4000099ff990d6d60d0d00777700061f117033bb7b356ddd0000
660dd0005d66d500077887700656565db3633737053bbb3500537350005d7d5009f009f000994200944994492ded000d07666670611f11173b5b55336d640000
66666cc05d6d6d5007e88e700655555db33673360533b33500537350005d7d5009fffff0099244202474474202ddd00d76ffff67611f111735bb73356d464000
d666666605d6d6d507e88e700655655d6337633b05bb3bb5005b7b50005c7c50094ff4f09924444222955922002ddd0d7ffffff7d117fff6335b5b3360046400
dd666ddd005d66d5077887700656165d7373363b05bb3bb5005b7b50005c7c5009fffff00004444229944992002d2ddd27ffff72d11111163bbb753560004640
066660000005dd500d7ee7d00dd666dd073333b0005b3b50005bbb50005ccc5009944ff00002442009411490022d2dd2027777200d111160355b533300000464
066000000000550007d77d7000ddddd00076bb00000555000055555000555550009999000099229900244200020222220022220000dd66003335333500000044
0999000000022200000a0a0a0007700000000c0000222200c696ccbc0000000000000000000f700000006600006606600066000000dddd0000fff00000999900
0a440000002eee200a0a0a0a00affa000008cdc00229922069a96b3b6777777600000000007fff000006666006660566666500000d8efed00ffeff0009ffff90
9444000002ee6ee200a7a7a700aaaa000f8e8db029244292c696cc3c76777767000000000ffff7f0006665560666656665556600d8ef7fedff9fff009f9999f9
444499902e2eeee2009aa7a909ffff90f9fe8b3b24422442cc6cc33c77677677671717160ff7fff0066655560665666666666500d8eefeedf99999009f9999f9
044444492ee222e20089aa9809999990f9fe8b3b24299242c999339c77766777671717169ffff7f9666551656665566656655566d28eee8dff00000f9f9999f9
044444442eeee2e2008899888ffffff8f9fe8b3b0294492094444449777887776777777649fffff4556666556650556655666665d228882d9ff000f949ffff94
044444402eeee2e2002888828ffffff8f9f88b3b00444400cddddddc7777777766666666049999405555555055500555055665551d2222d199ffff9004999940
0204204002eee2000002882008888880fff00bbb00222200ccccccccdddddddd111111110044440000555500550000550055555001dddd100999990000444400
4444444442444444111111111211111111111111111111111111111111111111ddddddddd2dddddd111111111111111111111111004444444444444444444444
55554444455545555555511115555155155555511dddddd1155555555555555155555dddd5555d55155555555555555555555551044222222222222222222222
44422254244444441112111121112111155555511dddddd11511115115111151ddd2dddd2ddd2ddd1515111111111111111151514422f1f12441111111111442
42444244444444451211121111111115155555511dddddd11511115115111151d2ddd2ddddddddd51551111111111111111115514242f1f12449191919191442
44444444455555521115111115555551155555511dddddd11511115115111151ddd5ddddd555555d1511111111111111111111512442f1f12449191919191442
44454442444444421115111211111122155555511dddddd11511115115111151ddd5ddd2dddddd221511111111111111111111510442f1f12449191919191442
44454444444544441115111111151111155555511dddddd11555555115555551ddd5ddddddd5dddd1511111111111111111111510442ffff2449191919191442
4555554444444455155555111151115511111111111111111511111111111151d55555dddd5ddd551511111111111111111111510442f1f12449999999999442
4224424444444244111111111111121111111111111111111511111111111151ddddddddddddd2dd1511111111111111111111510442f1f12449191919191442
4444444422444224111111112211122114444441122222211555555115555551dddddddd22ddd22d1511111111111111111111510442f1f12449191919191442
4224244542444424112121151211111114444441122222211511115115111151dd2d2dd5d2dddddd151111111111111111111151044444444449191919191444
55444445455555555115555515515515144444411222222115111151151111515dd55555d55d55d5151111111111111111111151044222222449191919191442
4444444444442444111111111111211114444441122222211511115115111151dddddddddddd2ddd151111111111111111111151044244442449999999999442
4555444444444444155155555511111114444441122222211511115115111151d55d555555dddddd151111111111111111111151044244442449191919191442
4442244445444455111211111111555514444441122222211555555555555551ddd2dddddddd5555151111111111111111111151044222222449191919191442
4444444222224244111111122111111111111111111111111111111111111111ddddddd22ddddddd151111111111111111111151044244442441111111111442
00909000000999000000000000000000000000000000000000000000333333333544533344444400151111111111111111111151000544000004440000000000
02929000009999000000090000000000000000000000000000003000355553336666666622222440151111111111111111111151000545000ffff40000000000
999990000099990000000900000000000000030000000000300030003544533355555555f1f12244151111111111111111111151000544000999f40000000000
999940000999999000000900300000000003033000030303330030003544533335445333f1f1242415111111111111111111115100044f000999f40000000000
444400000999999000000900300300000003033000030303333333003544533335445333f1f12442155111111111111111111551000454000999f40000000000
000000000499999000009990330330330033333300330333333333336666666635445333f1f12440151511111111111111115151005454000999f40000ff0000
000000000099994000999990333333333333333333333333333333335555555535555333ffff2440155555555555555555555551004454000999f4000ff4f000
000000000044440000444440333333333333333333333333333333333544533333333333f1f124401111111111111111111111110004f5000999f40005f45000
006060000006660000000000000002000070007000000000000005553554533335445333f1f12440444244440000088088000800000454000005540005454000
07676000006d660000000600000024200067076000000000000006663544533335445333f1f12440444244440880800800880000000454000004440004554000
06566000006d66000000060000024442000676002220022205550666354453333544533344444440444244448008800800808080000444000004440005445000
0666600006d6dd600000060030004440000767009990299906660666354553333544533322222440222222228080800800800080000f45000004440004454000
056650000d6d6dd00000060030034440007666709990999906660666354453333544533344442440002220000800800808000008000544000004450005444000
0055000005d6d6d00006666033033433003363339933333306330333354453333545533344442440004440000080088008000008000454000005440005445000
00000000006d6d500065556033333333333333333333333333333333354453333545533322222440004440000008000000000000005454500054545005455500
00000000005555000050005033333333333333333333333333333333354453333544533324442440004440000000000000000000055545550555455555555550
0000000000000000777700000000000000000000000000000000000fffff00000000000000000000000000000000000000000000000000000000000000000000
0000000000000007ddd6600000000000007766000000000000000049999fff0000000000000ffff0000000000000000005555550000000000000000000000000
0000000000000007dddd60000000000007666dd000000000000000944999fff0000000000ff94490000000000000000005777775000000000000000000000000
0000000000000007dddd6607777777707666dddd00000000000000994449ff9ffffff000ff944990000000000000000005666667500000000000000000000000
0000000000000007ddddd676666666676666dddd00000000000000999944f9fffffffffff9449990000000007700000005666666750000000000000000555500
00000000000000006666dd6666666666666dd00d000000000000000999449ffffffff99999499900000000006677000005666666675000000000000000577500
000000000000000000666ddd66666666666dd0000000000000000000994ffffffff9999999499000000000006666700005665566667500000000000000566502
00000000000000000066666dd666666666dd00000000000000000000044ffffff999999999900000000000006666670005665556666500000000000000555522
0000000000000000076666666ddd6666ddd60000000000000000000004ffffff994f999999f00000000000006666667005665555666500000000000000555527
0000000000000000076666566555d6665556000000000000000000000ffffff994f9999999f00000000000006666667005665555666555555555555555577527
00000000000000000765666551115555111500000000000000000000ffffff994444499999f00000000000005555550005665555666577755775775775566527
0000000000000000076656665ddd5665ddd50000000000000000000ffffff9999222299999f00000000000001122110005665555666766677666666666566522
0000000000000000776666665ddd5665ddd50000000000000000000fffff99999499999999f00000000000001211200005665557666655565566566566566522
000000000000000077666666655566565556000000000000000000fffff999999999999999f00000000000001455400005665576666555565566566566566522
00000000000000077766666666676656766670000000000000000fffff9999999999999999f00000000000000044000005667766665777765566566566566527
0000000000000007777666666776666567667000000000000000fffff99999999999999999ff0000000000000000000005666666657655565566566566566527
0000000000000007777666677666665d56767000000000000009ffff99999999f9999999999f0000000000000000000005666666556655565566566566566527
0000000000000007777766666666665d5666700000000000009444449999999f99949999999f0000000000000880088005666665555666656566566566566522
0000000000000007776576666666665dd5670000000000000944444449f999f999449999999f0000000000008000800805555555555555555555555555555522
0000000000000077776557666666755dd56700000000000009411411499f9f9994499999999ff000000000008000800800000000000000000000000000000000
00000000000000777666557666675665d57700000000000009441414499ff999442449999999f000000000008000800800000000000000000000000000000000
00000000000007777766555777756666567700000000000009444444499ff994224449999999f000000000008000800800000000000000000000000000000000
00000000000077777766555555556666677700000000000000944444999f44422444499999999f00000000000880088000000000000000000000000000000000
0000000000007776666655555555566677770000000000000099449999f4422244444999999999f0000000000000000000000000000000000000000000000000
000000000007776667765565555555775567700000000000000994499f422024444449999999999f000000000000000000000000000000000000000000000000
00000000000777666776556655555555566670000000000000000444422000244444999999999999ff0000000000000000000000000000000000000000000000
0000000000777667766655666655555566657700000000000000002220000024444999999999999999ff00000000000000000004444444444000000000000000
000000000077766776665566666666666665570000000000000000000000002444499999999999999999ff000000000000000004ffffffff4000000000000000
00000000077776666666556665666666666557700000000000000000000002444999999999999999999999999000000000000004999999994000000000000000
000000000777766666665566665666666665567000000000000000000000f9999999999999999449999999999944000022200004994444444400000000000000
00000000777666677666556666555666666556770000000000000000000f99999444499999944999999999999994400027220004994444fff400044444000000
00000000777666677666556666655666655556670000000000000000000f9999999994494449999999999999999444007272200499444499940044fff4400000
0000000777666666666655665665556665555667000000000000000000f99999999999999999999999999999999944002227200499ff449994044f999f440000
0000000777667766666655565566556665555666700000000000000000f999999999999999999999999999999999444022272004999944999404f99499f40000
000000077666776666666556555655666555666670000000000000000f9999999999999999999999999999999999444022272004994444999404994449940000
00000077766666666666655655566555665566667000000000000000f99999999999999999999999999999999999444072722004994004999404994449940000
0000007776666666666665566555655566556666670000000000000ff99999999999999999999999999999999999444027222224994004999404994449940000
000007777666666666666556655566556655666667000000000000ff999949999999999999999999999994499994444072722724994004999404994449940000
00000777666666666666655566556655655566666700000000000ff9999944999999999999999999999944999999444022272724994004999404994449940000
00007777666666666666665566666666555566666700000000000f9999999499999999999999999999444999999944402222722499400499944499f4f9940000
0000777666666666666666556665666566556666667000000000ff99999994999999999999999999944499999999444422272724994004999ff4499f99440000
000076666666666666656655666556556655666666700000000ff999999994999999999999999999444499999999944477722274994004999994449994400000
00077666666666666665665566555655665566666670000000fff999999944999999999999999994444499999999944422222224444004444444444444000000
00076666666666666665665556555655565566666660000000ff9999999444999999999999999994444449999999994400000000000000000000000000000000
0007666666666666666656555655665556556656666600000ff99999999444499999944444444494444449999999994400000000000000000000000000000000
0007666666666666666656655655666566556656666600000ff99999994442499994fffffffff444444249999999994400000000000000000000000000000000
0077656666666666666665655665666566556565666600000ff99999994422499944f999999ffffff42249999999994400000000000000000000000000000000
0076656666665666665665655666665666556565666660000ff99994444444444444444449999944444444499999994400000000000000000000000000000000
007665666666566666566565566665565655655566666000fff9fffffffffffffffffff449999999999994999999994400666666666600000066666600000000
007666566566566666556555555655565555655666566000ffffffff99999999999999ff44999999999999499999944407777777777770000777777777000000
007666566566565666656555556555566555655666566000ffff9999999999999999999ff4499999999999949999944406666666666660000666666666777000
007666566566565666656556556655666555655566566600fff999999999999999999999ff449999999999949999444406556555565560000655556556666777
007656566566565666656556556655666555656566566600f9999999999999999999999999f44999999999999999444406dd6dddd6dd600006dddd6dd6666666
077656566566565666655556556565666555656566556600ff999999999999999999999999944499999999999999444006dd6dddd6dd600006dddd6dd6666666
0766565665666556666555565555666566556565565566000ff99999999999999999999999942444999999999999444006dd6dddd6dd600006dddd6dd6666666
07665665656565556665555655566665565565655655660000f99999999999999999999999422224449999999999444006776dddd677600006dddd6776666666
076656656655655566655565555666655655656555556560000f9999999999999999999942224422244999999944440006666dddd666600006dddd6666666666
0766565656556555565555555566566556555566555565600000f999999999999999944422444444424449999444000066666777766666006677776666666666
07666556565666556656556555655666565555656565656000000444444444444444422244444444442224444200000055555555555555005555555555555555
76656556565666556656556555655666565555656565556000000000000000022222224444444444944442222400000001122122122110000112211122111221
76656556555666556566556655656656565555656556565600000000000000044444444444444999944444444000000000211211211200000021121211212112
76565655555666565565556655666656565565556555565600000000000000044444444449999999499944444000000000455455455400000045545455454554
76565656566565665565555555666556665565556565565600000000000000449444999999994444449999444000000000044044044000000004400044000440
76565665666565665565555555665566665565556565565600000000000000499994444444444999949999444000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
004140414041404140415a5b5b5c40414041404140414000005859585958595859495a5b5b5c48495859585958594800005253525352535253435a5b5b5c424243424342434243000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005145454545454550516a6b6b6c50515454545454545000005844444444444458596a6b6b6c58595555555555555800004244454445444552536a6b6b6c525355455545554543000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041454545454545404140414041404154545454545440000048444545454544585958595859484955545454545548000052454445444544424352535253424345554555455553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00514545454545455051464b4b475051545454545454500000484445454545444849464b4b475859555454545455580000424445444544455253464b4b47525355455545554543000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004145454545454540415a46475c40415454545454544000005844444444444458595a46475c48495555555555554800005245444544454442435a46475c424345554555455553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505150515051505150515a56575c50515050515051505150484849484948494848495a56575c58594849484948495848424342434243424352535a56575c525342434243424342430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40414041404140414041566b6b574041404041404140414058585958595859585859566b6b574849585958595859485852535253525352534243566b6b57424352535253525342530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0051555555555555404140414041404144444444444450000048545454545454484948494849585945454545454558000043545554555455525342434243525344544454445442000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004155555555555550514a4b4b4c40514444444444444000005854555555555458594a4b4b4c48494544444444454800005355545554555442434a4b4b4c424354445444544452000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004155555555555540405a5b5b5c41404444444444445000004854555555555448495a5b5b5c58594544444444455800004354555455545552535a5b5b5c525344544454445442000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005155555555555540415a5b5b5c51414444444444444000004854545454545458595a5b5b5c48494545454545454800005355545554555442435a5b5b5c424354445444544452000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004140414041404150515a5b5b5c41515051505150515000004849494849484948495a5b5b5c58484948494849484900004243424342434243535a5b5b5c525253525352535253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004d4e4e4f4f690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005d5e5e5f5f790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007a7a7a7a7a7a7a7a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d00000000006e0000006f00000000006d00000000006e0000006f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d00000000007e0000007f00000000007d00000000007e0000007f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6476636463646674636465646673637564766364636466746364656466736375000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6767676767676767676767676767676767676767676767676767676767670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777877777777787778777777777877777778777777777877787777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7878777878777778777877787878777878787778787777787778777878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6868686868686868686868686868686868686868686868686868686868680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010a0000102501d2502925029250222501b2401724014240112400d2400c2400b2500924007230052300423003220032200322003220032100320003200030000200001000010000000000000000000000000000
000400040765007630076100760007650076300761007600076500763007610076000765007630076100760007650076300761007600076500763007610076000765007630076100760007650076300761007600
0110002022750227322271222700277502475024732247122e7502e7322b7502b73200000000000f7541f7511d7510f7510000000000187501a750187501c7501d7501d7311d7211d71100000000001f7501c750
01100020186550000000000000001c6531c6003461500000186550000000000000001d653000000000000000186550000000000000001c6531c6003461500000186550000000000000001d653000003461534615
0110002002432024351f050210501d0501d0311d0221d01205432054351a050000001f0501d050210502105202432024351f050210502405024031240222401209432094351a050000001f0501d0501c0501c052
01100020024320243507533210501d05007533075331d01005432054351a050075331f0501f0550753307533024320243507533075002405024031240222401209432094351a050075331f0501f0550753307533
01200020211501d1501c150181501515215135151251511515150181501d1501c1501f1521f1351f1251f1151d150151501f1501f150151521513515125151151d1501a1311a1501c1311c1501f1311f1521f132
011000201113300772007720075211633007720077200752111330277202772027521163307772077720775211133047720477204752116330077200772007521113302772027720275211633047720477204752
001000000c45500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000012410214401b44015440104400e4300943006430054300543004430044300443004430044300442004420034100341002410024100241002410024100241002410024100241002410024100040000400
0001000012010210501b05015050100500e0500905006050050400504004040040400404004040040500404004040030400304002040020400203002030020300202002020020200202002020020200000000000
010b00000f41018430224502243022420224100e4001240015400174001a4001c4002040024400274002a4002c4002d400314000a4000e400104001140017400144001c4001f40016400124000e4000b4000b400
010b00000f41018430224002240022400224000e4000b700047000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000008750107501175010750107500d7500d7500b730047200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018154181522f00016000000000000000000000001d1541d15206000060000000000000000000000021154211522114221132211120000000000000000000000000000000000000000000000000000100
011800201a1551a1451a1351a1221d1551d1451d1351d1251c1551c1451c1351c1251f1551f1451f1351f1251a1551a1451a1351a1251d1551d1451d1351d125211552114521135211251f1551f1451f1351f125
0130002010552105521055210555155521555215552155551755217552155521555213552135521355213555105521055210552105550c5520c5520c5520c5551755217552105521055211552115521155211555
010c00200e655000000000000000126530003200000000000e655000000000012633126530000212633000000e655000000e635000000e6550000000000000000e65500000000000000012653000021260012633
011e002029150291412913229112271502713229150291322b1502715029150271502b1502b1412b1222b112291502b1502f1502f1222e1502e1412e1212e112301502e1502b1502b15229150271502715224150
01220020180501d0502205022040220202201024050290502705027040270202701024050220502405027050300502e0502b0502b052290502904029020290102405024042240222401227050270422702227012
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
03 01 42 43 44
01 01 03 04 44
00 01 03 04 44
00 01 03 04 44
00 01 03 04 44
00 01 03 05 44
02 01 03 05 44
03 07 06 43 44
03 10 11 12 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
