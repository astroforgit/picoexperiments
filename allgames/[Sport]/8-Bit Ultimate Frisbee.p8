pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

dmtns={}	--defense manhattan distances
oio,oiy,oix,dio,dix,diy,oia,dia=0,0,0,0,0,0,0,0		--keeping table indexes bc numeric keys are used. ia is active
ezoneupmax=29
ezoneupmin=3
ezonelomin=234
ezonelomax=260 
wmx1=20
wmx2=90		--washing machine.
redcatches=0 --hax to start

function _init()
	g = game.new()
	music(11)
	camera(0,0)

end 
function _draw()
	g:draw()
end
function _update()
	g:update()
end
game={}
game.__index=game
function game.new()
	local self=setmetatable({}, game)
	self.update=self.homeupdate
	self.draw=self.homedraw
	self.fr=0
	self.frcaught=0
	self.x=0
	self.y=0
	self.turn=0
	self.stall=0
	self.oldbutts={}
	self.newbutts={}
	self.shaking=false
	self.ptflip=1		
	self.someonescored="NA"
	self.frscored=0
	self.someonecaught=false
	self.frcaught=0
	self.message="first team to 4 points wins"
	self.fmessage,self.fmessageend=0,72
	self.fmc1,self.fmc2=1,9
	self.sunring=rnd(8)
	return self
end
function game:homedraw()
	cls(1)
	--camera(self.x,self.y) --lol
	
	local textfr=min(self.fr/56,1)
--	fillp(0b0000111011011000.1)
	rectfill(0,0,128,40,0x11)
--	fillp()
	rectfill(0,41,128,128,3)--,0x3b) --grass
	circ(120,6,1,10)
--	sspr(24,64,96,32,32,26,24,8,false,false)
	if self.fr%16<8 then 
		sspr(0,96,24,8,32,26+(self.fr%8/4))
		line(37,41,50,41,5)
	else
		sspr(0,104,24,8,32,28-(self.fr%8/4))
		line(39,41,48,41,5)
	end 
	line(42,42,45,42,5)

	print("8 BIT ULIMATE!",5,5*textfr,8)
	spr(75,5,11*textfr-3) --#
	print("  THROWEVERYDAY",5,11*textfr,7)
	print("PRESS Ž TO START",5,18*textfr,6)


--	line(12,42,16,42,0)
	spr(23,10,35)--handler
	--spr(22,18,35)--disc
	spr(26,72,38)--blue guy
	spr(20,86,41)

	--pal(split("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"))
	spr(50,10,43)
	spr(34,86,49)		
	spr(34,72,46)
	--pal()
	print("RRM                      ",4,120,0)

	if redcatches>0 then
		print("RED \npoints \nthrowaways \nturnovers \ncatches \n\nBLUE \npoints \nthrowaways \nturnovers \ncatches",20,50,15)
		print("\n"..opoints.." \n"..redthrowaways.." \n"..redturnovers.." \n"..redcatches.." \n\n\n"..
								dpoints.." \n"..bluthrowaways.." \n"..bluturnovers.." \n"..blucatches,10,50,14)
	end

	--spr(39,(self.fr/20)%200,50) --turtle	
	--borderdraw()
end
function game:homedrawsun(x,y) --x,y center
--	fillp(0b11011111111111111.1)
--	rectfill(0,0,128,40,0xcc)
--	fillp()
end
function game:homeupdate()
	self.fr+=1
	if btn(4) then
		self:sportinit()
		self.update=self.sportupdate
		self.draw=self.sportdraw
--	elseif btn(5) then
		--self:tutinit()
		--self.update=self.tutupdate
		--self.draw=self.tutdraw
	end
end
function borderdraw()
	local fx,fy=g.x,g.y
	if g.shaking then fx,fy=shx,shy end	--shx,shy is global
--	rect(fx,fy,fx+127,fy+127,13)
--	rect(fx+1,fy+1,fx+126,fy+126,1)
end
function game:sportinit()
	bluthrowaways=0
	bluturnovers=0
	blucatches=0
	redthrowaways=0
	redturnovers=0
	redcatches=0
	opoints=0
	dpoints=0

	phys=phys:new()
	ofs[1]=ofs:new("x",30,195,true,1,"ofs")
	ofs[2]=ofs:new("y",rnd(40)+20,200,false,2,"ofs")
	ofs[3]=ofs:new("o",100,180,false,3,"ofs")
	dfs[1]=dfs:new("x",20,90,true,1,"dfs")
	dfs[2]=dfs:new("y",50,90,true,2,"dfs")
	dfs[3]=dfs:new("o",100,90,true,3,"dfs")
	ofs[1].gy=-1
	--ofs[3].gy=-1
	
	self.x,self.y=0,ofs[2].y-70
	camera(self.x,self.y)
	music(1)
end
function game:sportresetofspoint()
	self:setptflip()
	
	for i=1,3,1 do
		ofs[i].gx,ofs[i].gy=0,0---g.ptflip
	end
	
	ofs[1].marking,ofs[2].marking,ofs[3].marking = false,false,false 
	ofs[1].active,ofs[2].active,ofs[3].active = false,true,false
	
	if self.ptflip==-1 then --offense in upper endzone for odd total game points 
		ofs[1].x,ofs[1].y,gy,ofs[1].n=20,90,-1,"x"
		ofs[2].x,ofs[2].y,gy,ofs[2].n=50,90,-1,"y"
		ofs[3].x,ofs[3].y,gy,ofs[3].n=100,110,0,"o"
		dfs[3].x,dfs[1].y=20,220
		dfs[1].x,dfs[2].y=50,220
		dfs[2].x,dfs[3].y=100,220
		if g.someonescored=="ofs" then 
			phys.px,phys.py=rnd(40)+40,195
		else phys.px,phys.py=rnd(40)+40,60
		end
	else
		ofs[1].x,ofs[1].y,gy,ofs[1].n=20,220,1,"x"
		ofs[2].x,ofs[2].y,gy,ofs[2].n=50,220,1,"y"
		ofs[3].x,ofs[3].y,gy,ofs[3].n=100,200,0,"o"
		dfs[2].x,dfs[2].y=20,50
		dfs[1].x,dfs[1].y=50,50
		dfs[3].x,dfs[3].y=100,90
		if g.someonescored=="ofs" then 
			phys.px,phys.py=rnd(40)+40,60
		else phys.px,phys.py=rnd(40)+40,195
		end
	end 
	
	self.someonescored="NA"
	self.setindexes()
	phys:resetcurves()
	p1.x,p1.y,p2.x,p2.y,p0.x,p0.y=phys.px,phys.py,phys.px,phys.py,phys.px,phys.py
	phys.hastarget=true
	t=1.1
end
function game:setptflip()
	local n = (opoints+dpoints)
	if n%2==0 then self.ptflip=1	--even
	else self.ptflip=-1 end
end
function game:setindexes()
	oix=game:getofsnum("x")
	oio=game:getofsnum("o")
	oiy=game:getofsnum("y")
	diy=game:getdfsnum("y")
	dix=game:getdfsnum("x")
	dio=game:getdfsnum("o")
	oia=game:getofsactivenum()
	dia=game:getofsactivenum()
end
function game:xyforcam()
	local offcenter=0
	if (self.turn==0 and self.ptflip==1)
	or (self.turn==1 and self.ptflip==-1)
	then offcenter=-70
	else offcenter=-50 end
	
	if self.y<120 then	--up
		self.y=flr(min(max(phys.py+offcenter,2),135)) --
	else								--down
		self.y=flr(min(phys.py+offcenter,135))
	end
end
function blockletter(m,x,y,teamcolors)
	if teamcolors and g.fmessage==0 then --set em n forget em!
		local turn=g.turn
		if g.message=="         turnover!" then turn=(g.turn+1)%2 end  --hax for interceptions..
		
		if turn==1 then
			c1,c2=12,10--global 
		else
			c1,c2=1,9
		end
	elseif g.fmessage==0 then 
		c1,c2=8,9
	end

	for j=0,2,1 do
		for k=0,2,1 do
			print(m,x+j,y+k,c1)
		end
	end
	if g.fmessage>10 and g.fmessage<g.fmessageend-4 then 
		print(m,x+1,y+1,c2)
	end
end
function game:sportdraw()
	self.fr+=1
	cls(3)
	if t>0.1 then				--update camera position on throw.
		self:xyforcam()
	end
	local sh=6
	shx,shy=rnd(sh)+(g.x-sh/2),rnd(sh)+(g.y-sh/2)
	if self.shaking==false then camera(self.x,self.y)
	else camera(shx,shy) end
	
	--grass, mud
	local midfield=128
	local topendzone=64
	map(8,0,0,1,8,1) --top endzone --back row
	map(8,0,64,1,8,1) --top endzone --back row
	map(8,0,0,8,8,1) --top endzone
	map(8,0,64,8,8,1) --top endzone
--	map(8,0,1,16,8,1) --top endzone --rm duplicate. only for top.
--	map(8,0,64,16,8,1) --top endzone
	map(8,0,0,16,8,2) --top endzone
	map(8,0,64,16,8,2) --top endzone
	map(8,4,0,255,8,1) --bottom endzone --back row
	map(8,4,64,255,8,1) --bottom endzone --back row
	map(8,4,0,247,8,1) --bottom endzone
	map(8,4,64,247,8,1) --bottom endzone
	map(8,4,0,239,8,1) --bottom endzone
	map(8,4,64,239,8,1) --bottom endzone
	map(8,3,0,232,8,1) --bottom endzone
	map(8,3,64,232,8,1) --bottom endzone
	map(8,2,0,128,8,1) --midfield
	map(8,2,64,128,8,1) --midfield
	spr(60,10,123)			--50
	spr(59,20,123)			--yd
	map(0,0,0,50,4,4) 	--top left mud
	map(4,0,100,66,4,3) --top right mud
	map(0,4,80,110,4,4) --bottom right mud
	spr(7,99,96)		--top grass
	spr(7,17,43)		--top grass
	map(4,5,50,36,5,4)	--top grassy knoll
	map(4,5,35,76,5,2)	--top grassy knoll
	map(0,8,50,150,8,7)	--bottom mud
	map(4,5,-10,187,5,4)	--botom grassy knoll
	spr(39,((self.fr/20)+180)%200,50) --turtle
	
	--game objects
	dfs[1]:draw()
	dfs[2]:draw()
	dfs[3]:draw()
	ofs[1]:draw()
	ofs[2]:draw()
	ofs[3]:draw()
	phys:draw()

	if g.someonescored~="NA" then
			if self.message==nil then 
				self.message="red  "..opoints.."     "..dpoints.."  blu"
				self.fmessage,self.fmessageend=0,700
			end 
		if opoints==4 or dpoints==4 then 
			local s="  you win!!!"
			if dpoints==4 then s=" you lose!!!" end
			blockletter(s,g.x+40,g.y+20,true)
			if not howdy then
				sfx(-1,1)
				music(10,0,14)
--				bluturnovers-=1
				howdy=true--global 
			end
		end
	elseif opoints==4 or dpoints==4 then
		howdy=nil 
		_init()
	end

	if self.message~=nil then
		local x1,y1,teamcolors=g.x+10,g.y+20,true
		if g.someonescored~="NA" then x1,y1,teamcolors = g.x+31,g.y+4,(opoints==4 or dpoints==4) end --other messages have to set everything.
		blockletter(self.message,x1,y1,teamcolors)
		if self.fmessage>self.fmessageend then
			self.message,self.fmessage,self.fmessageend=nil,0,0
		else
			self.fmessage+=1
		end
	else 
		
	end

	--border
	borderdraw()
end
function game:sportupdate()

	if self.someonescored~="NA" then
		if self.fr>self.frscored+500 then
			self:sportresetofspoint()
			self.message,self.fmessage,self.fmessageend=nil,0,0
		else 
			self.fr+=1
			return		--exit updates.
		end 
	end
		
	phys:caughtdisc()
	phys:discoob()

	if g.turn==0 then
		if btn(4) and btn(5) then ofs[oiy]:lockallkeys(true) --does not let inputs change ofs direction
		else ofs[oiy]:lockallkeys(false) end --let inputs change ofs direction
		
		if btnp(5) and not btn(4) then			--x
			if ofs[oix].active then
					if ofs[oiy].throwto==-1 then phys:throwtarget(oix) end --get target 1 time only
					ofs[oiy].throwto="x"																	 --get target ofs
			else																							 			 --else btnx but x not active
				ofs[oix].active=true
				ofs[oio].active=false
			end
		end
		if btnp(4) and not btn(5) then --o/z
			if ofs[oio].active then
					if ofs[oiy].throwto==-1 then phys:throwtarget(oio) end --get target 1 time only
					ofs[oiy].throwto="o"																	 --get target ofs
			else																										 --else btnx but x not active	
				ofs[oio].active=true
				ofs[oix].active=false
			end
		end 

		if ofs[oiy].throwto~=-1  then  --dothrow
			phys:throw(ofs[oiy].throwto)
		end
	elseif g.turn==1 then
--		if btnp(5) then --x 
--			ofs[oia].n="x"
--			ofs[oix].n="y"
--			ofs[oix].active=true
--			ofs[oia].active=false
--			self:setindexes()
--		elseif btnp(4) then --o/z
--			ofs[oia].n="o"
--			ofs[oio].n="y"
--			ofs[oio].active=true
--			ofs[oia].active=false
--			self:setindexes()
--		end
		if g.frcaught<g.fr-30 and t<1 then --DEBUG mode
			if dfs[1]:imopen() then	--logical short circuiting 
			elseif dfs[2]:imopen() then
			else dfs[3]:imopen() end
		end
		if dfs[diy].throwto~=-1 then
			phys:throw(dfs[diy].throwto)
		end
	end
	

--set stall count
	local oixismarking=phys:manhattan(ofs[oix].x,ofs[oix].y,dfs[diy].x,dfs[diy].y)<16	--more like 'oiy can mark'
	local oiyismarking=phys:manhattan(ofs[oiy].x,ofs[oiy].y,dfs[diy].x,dfs[diy].y)<16	--FIXME tokens 
	local oioismarking=phys:manhattan(ofs[oio].x,ofs[oio].y,dfs[diy].x,dfs[diy].y)<16
	if g.turn==0 and oiyismarking then --stall count
		self.stall+=1 --denominator is somewhere else probably g.stall/20
	elseif g.turn==1 and oixismarking then
		self.stall+=1 --denominator is somewhere else probably g.stall/20
		ofs[oix].marking=true
	else
		ofs[oix].marking=false
	end

--if user ofs on defense is marking, just flip them to another player	
	--if phys:manhattan(ofs[oiy].x,ofs[oiy].y,dfs[diy].x,dfs[diy].y)<10 and g.turn==1 then
	--doublemark=false
	if oiyismarking and g.turn==1 then
		if not oixismarking and t<1 then 
			ofs[oiy].n,ofs[oix].n = ofs[oix].n,ofs[oiy].n
			ofs[oiy].active,ofs[oix].active = false,true
			ofs[oix].gx,ofs[oix].gy=0,g.ptflip
		else
			--g.stall=0
			--doublemark=true
		end
	elseif oioismarking and g.turn==1 then
		if not oixismarking and t<1 then 
			ofs[oio].n,ofs[oix].n = ofs[oix].n,ofs[oio].n
		end
	end
	
	--turnover for stall count
	if g.stall>=10*10 and t==0 then
		local x,y
		if g.turn==0 then
			x,y=ofs[oiy].x,ofs[oiy].y-(8*g.ptflip)
			redturnovers+=1
		else
			x,y=dfs[diy].x,dfs[diy].y+(8*g.ptflip)
			bluturnovers+=1
		end
		p0.y,p1.y,p2.y=y,y,y
		p0.x,p1.x,p2.x=x,x,x
		t=1.1
		g.message,g.fmessage,g.fmessageend="           stall",0,72
		sfx(18)
	end
	
	phys:guys() --set any collisions for ofs-dfs
	ofs[1]:update()
	ofs[2]:update()
	ofs[3]:update()
	dfs[1]:update()
	dfs[2]:update()
	dfs[3]:update()
end
function game:getofsnum(str)
	for i=1,3,1 do
		if ofs[i].n==str then
			return i
		end 
	end
	return -1
end
function game:getofsactivenum()
	for i=1,3,1 do
		if ofs[i].active then
			return i
		end 
	end
	return -1
end
function game:getdfsnum(str)
	for i=1,3,1 do
		if dfs[i].n==str then --changed 1 char lol
			return i
		end 
	end
	return -1
end
------------------------ /game > sport
------------------------ /game
------------------------ guy
guy={}
function guy:new(pn,px,py,pa,pid,pteam)
	self.__index=self
	local self=setmetatable({},self)
	self.state="idle"
	self.n=pn
	self.m=""
	self.team=pteam
	self.id=pid
	self.spr=18
	self.x=px
	self.y=py
	self.xmin,self.xmax,self.ymin,self.ymax=0,0,0,0
	self.vmax=1
	self.vx=0
	self.vy=0
	self.ax=0.1
	self.ay=0.1
	self.gx=0
	self.gy=0
	self.tx,self.ty=0,0
	self.oldbutts={}
	self.newbutts={}
	self.feetup=false
	self.flip=false
	self.red=false
	self.active=pa
	self.fr=0
	self.frun=0 --56 on; 36 off.
	self.fskid=0
	self.throwto=-1
	self.keyslocked=false
	self.doverride=false
	self.draw=self.draw
	self.update=self.update
	self:construct(pn,px,py,pa)
	return self
end
function guy:construct(...) end --dummy for any overriding
function guy:draw() 
	--if g.someonescored=="ofs" and self.team=="ofs" then	
	if g.someonescored~="NA" then 
		if self.n=="y" then --self.y<21 then	--guy who scored does backflip
			if g.someonescored=="ofs" and self.team=="ofs" then	--"ofs" anim for y 
					spr(22,self.x+7,self.y+1)
					self:drawbackflip(19,71,72,73,18) --25,80,81,82,24
			elseif g.someonescored=="dfs" and self.team=="dfs" then		--dfs anim for y 
				spr(22,self.x+10,self.y)
				if g.fr%16<8 then --two sprites switch every four frames
					spr(88,self.x,self.y)
				else
					spr(87,self.x,self.y)
				end 
			elseif self.team=="ofs" then spr(18,self.x,self.y)
			else spr(24,self.x,self.y)
			end
		else	--everyone else is turnt
			if g.someonescored=="ofs" and self.team=="ofs" then		--ofs anim for xo
				local fr=flr(g.fr/2)+self.id --slowing it down by half ig 
				if (fr/5)%1==0 then
					spr(18,self.x,self.y,1,1,flr(fr/5)%3<2,false)
				else
					spr(23,self.x,self.y-2,1,1,flr(fr/5)%3<2,false)
				end 
			elseif g.someonescored=="dfs" and self.team=="dfs" then		--dfs anim for xo 
				self:drawbackflip(25,80,81,82,24)	
			elseif self.team=="ofs" then spr(18,self.x,self.y)
			else spr(24,self.x,self.y)
			end
		end
		return	--no further animation required
	end
	if self.n~="y" and self.ankle then
		spr(30,self.x,self.y,1,1,not self.flip,false)
	elseif self.state=="run" then
--		if self.bump then self:bumpdraw() --removing and cutting features uf26 
--		else self:rundraw() end
		self:rundraw()
	elseif self.state=="skid" then self:skiddraw()
	elseif self.state=="throw" then self:throwdraw()
	elseif self.state=="throwing" then self:throwingdraw()
	else self:idledraw()
	end
	--draw a letter above his head
	self:letterdraw()
	self:stalldraw()
	self:wallsdraw(self.x,self.y,self.gx,self.gy,self.active,self.n)
--	self:drawtxty()
end
function guy:drawbackflip(one,two,three,four,five) --19,71,72,73,18 --25,80,81,82,24
	local fr=g.fr+self.id*3
	if fr%36>=(g.frscored+20)%36 and fr%36<=(g.frscored+23)%36 then
		spr(one,self.x,self.y-2)
	elseif fr%36>=(g.frscored+24)%36 and fr%36<=(g.frscored+27)%36 then
		spr(two,self.x,self.y-2)
	elseif fr%36>=(g.frscored+28)%36 and fr%36<=(g.frscored+31)%36 then
		spr(three,self.x,self.y-2)
	elseif fr%36>=(g.frscored+32)%36 and fr%36<=(g.frscored+36)%36 then
		spr(four,self.x,self.y-2)
	else
		spr(five,self.x,self.y)
	end
end
function guy:update() 
	if self.n=="y"then
		if g.turn==0 then --0 means o
			self.state="throw"
			if t>0 then self.state="throwing" end
		else	--y defense is user:
			self:runupdate()
		end--ofs is not offense
	else							 --not thrower:
		self:runupdate() --skid,run,idle
		--if phys:guydisc(self.x,self.y,p0) and t>0 then --t<1 then --disc caught!
		--	self:caughtdis()
		--	g:setindexes()
		--end
	end
	if g.turn==0 and t==0 and g.stall==5*10 and self.active==false then
		if self.doverride==false and self.n~="y" then
			if (g.ptflip>0 and self.y<ofs[oiy].y) or (g.ptflip<0 and self.y>ofs[oiy].y) then
				self.gy,self.gx,self.vy,self.state,self.fskid=flr(rnd(3)-1),flr(rnd(3)-1),0,"run",2 --uf50
			 end
		end
	end
end
function guy:lockallkeys(a) --all guys
	for i=1,3,1 do
		ofs[i].keyslocked=a
	end
end
function guy:skiddraw()
	local skidspr=20								--default not red skid spr
	if self.red and g.turn==0 then					--red mode spr 36 or 52
		skidspr=(self.fr%2)*16+36
	end
	spr(skidspr,self.x,self.y,1,1,not self.flip,false)
end
function guy:throwdraw()
	for j=-1,1,1 do
		for k=-1,1,1 do
			spr(37,self.x+j,self.y+k)
		end
	end
	
	spr(21,self.x,self.y)
	spr(38,self.x+8,self.y)
end
function guy:throwingdraw()
	spr(23,self.x,self.y)
end
--function guy:drawtxty() end
function guy:letterdraw()
	local sprn=-1
	if g.turn==0 then 
		if self.n=="x" then sprn=4
		elseif self.n=="o" then sprn=3 end
		if self.active then sprn-=2 end
	elseif self.n=="y" then sprn=96 end
	
	if sprn>-1 then
		if self.flip then	--going left, spirte is off 1px
			spr(sprn,self.x+1,self.y-7)
		else 
			spr(sprn,self.x,self.y-7)
		end 
	end
end
function guy:stalldraw() --ofs
	if t>1 then return end
	if self.n=="y" and g.turn==0 and self.team=="dfs" then --mark
		if g.stall>0 then
			print(flr(g.stall/10),self.x-7,self.y+1,8)
		end
	elseif self.marking and g.turn==1 then
		if g.stall>0 then
			print(flr(g.stall/10),self.x-7,self.y+1,8)
		end
	end
end
function guy:rundraw()
--regular run:
	if self.fr%8>3 then self.spr=19
	else self.spr=18 end
--flashy blue sprite upon ready for red mode
	if self.frun>54 and self.frun<60 and g.turn==0 then 
		if self.frun%2==0 then self.spr=51
		else self.spr=35 end
	end
	spr(self.spr,self.x,self.y,1,1,self.flip,false)
end
function guy:dsetbuttsgetflag()		--autopilot
--reset
	self.oldbutts=self.newbutts
	self.newbutts={}
--get man
--	for i,v in ipairs(dfs) do 	
--		if self.n==v.n then self.m=i end 
--	end
--y is really x (index)
	if self.n=="o" then self.m=dio
	else self.m=diy end

--get target to run at
	local mantodisc=phys:manhattan(dfs[self.m].x,dfs[self.m].y,p1.x,p1.y)
	local metodisc=phys:manhattan(self.x,self.y,p1.x,p1.y)
	if metodisc<mantodisc and t>0 then --and (t<1 or self.id==1)) or (t>1 and self.id==1) then
		if t<1 or self.n=="x" then
			self.tx=flr(phys.px-2)
			self.ty=flr(phys.py-2)
		else
			self.tx=self.x
			self.ty=self.y-(10*g.ptflip)
		end
	else	--track man 
		self.tx=flr(dfs[self.m].x)
		if g.ptflip==1 then self.ty=flr(dfs[self.m].y-(7*-g.ptflip))+6
		else 								self.ty=flr(dfs[self.m].y-(7*-g.ptflip)) end 
	end
--get newbutts
--uf13 let defense go outside walls
--uf24 newbutts for all again AND put this in ofs class..
--	if g.turn==0 or t>0 then
		if self.tx<self.x+2 then --target is padded. padded again here.
			self.newbutts[0]=true
		elseif self.tx>self.x+2 then
			self.newbutts[1]=true
		end
		if self.ty<self.y+2 then
			self.newbutts[2]=true
		elseif self.ty>self.y+2 then
			self.newbutts[3]=true
		end
--	end
--return inputchanged flag
--	if self.newbutts~=self.oldbutts then
	for i=0,3,1 do 
		if self.newbutts[i]~=self.oldbutts[i] then
			return true
		end
	end
	return false
end
function guy:runupdate() --state machine
	self.fr+=1																		--frame counter
	if (self.active and not self.keyslocked) or g.turn==1 then		--if active, get buttons, get inputchanged
		local inputchanged
		if g.turn==1 and self.n~="y" then inputchanged=self:dsetbuttsgetflag() 
		else inputchanged=self:setbuttsgetflag() end 
		if inputchanged then
			self.doverride=true--uf50
			self.state="skid"														--skid mode on 
			self.fskid=1
			self.x,self.y=flr(self.x),flr(self.y) 			--sub pixels fix diagonal
		end		
		self:butts2gxgy(self.newbutts,self.gx,self.gy)
	end 
	
	if self.state=="skid" then											--if skid state (3 frames)
		self.flip=(self.gx==1)												--flip when going right.
		if self.frun>55 then self.red=true end 				--red mode on 
		if self.fskid==4 then													--reset some vars before they key up.
			self.frun,self.gx,self.gy,self.vx,self.vy=0,0,0,0,0
		end
		if self.fskid==4 then self.state,self.fskid="run",0 --skid mode off
		else self.fskid+=1 end															--skid 4 frames count
	elseif self.gx~=0 or self.gy~=0 then						--if running state (n frames)
		self.state="run"
		self.frun+=1																	--state frame counter
		self.feetup=(self.frun%8>3)
		if not self.feetup then return 0 end 					--exit if feet down
		if self.red then self.vx,self.vy=self.vmax,self.vmax end --red mode super speed
		if self.frun==14 then self.red=false end											 --red mode off 
		self:gx2vx()																											--set unsigned velocity using acceleration
		self.flip=(self.gx==-1)
		self:vx2x()
	else 
		self.state="idle"
		self.red=false
	end

	if self:walls(self.x,self.y,self.gx,self.gy,self.n)~=nil then					--walls
		self.x,self.y,self.gx,self.gy=self:walls(self.x,self.y,self.gx,self.gy,self.n)
		--self.state="idle"
		self.red=false
		--self.frun,self.gx,self.gy,self.vx,self.vy=0,0,0,0,0
		self.frun,self.vx,self.vy=0,0,0
	end
	
	if self.frun<10 and self.state=="run" and self.red and g.turn==0 and t<1 then --screen shake
		g.shaking=true
		sfx(10)
	else g.shaking=false 
	end
	
end
function guy:vx2x()--x,y,vx,vy,gx,gy)
	self.x+=self.vx*self.gx
	self.y+=self.vy*self.gy
end
function guy:gx2vx()
	if self.gx~=0 and self.gy~=0 then					--diagonal velocity is lower
--		self.x,self.y=flr(self.x),flr(self.y)
		self.vmax,self.ax,self.ay=1.4,0.2,0.2
	else 
		self.vmax,self.ax,self.ay=2,0.2,0.2
	end
	if self.bump then										----lower velocity if bumping offense
		self.vmax,self.ax,self.ay=0.5,0.2,0.2
		self.frun=0
	end
	self.vx=min(self.ax+self.vx,self.vmax)
	self.vy=min(self.ay+self.vy,self.vmax)
end
function guy:butts2gxgy(nb,gx,gy)
--	self.gx,self.gy=0,0
	if self.newbutts[0] then self.gx=-1						--if different input, change dirn else keep dirn
	elseif self.newbutts[1] then self.gx=1 end
	if self.newbutts[2]  then self.gy=-1
	elseif self.newbutts[3] then self.gy=1 end
end
function guy:setbuttsgetflag() --requires 1 fr per btn it seems
	self.oldbutts=self.newbutts
	self.newbutts={}
	for i=0,3,1 do
		if btn(i) then
			self.newbutts[i]=true
			if self.newbutts[i]~=self.oldbutts[i] then
				return true
			end 
		end 
	end
	return false
end
function guy:throwerupdate() end
function guy:idledraw()
--	spr(self.spr,self.x,self.y)
	spr(18,self.x,self.y,1,1,self.flip,false)
end
function guy:idleupdate() end
phys={} --todo might have to rename the instance as p.
function phys:new()
	self.__index=self
	local self=setmetatable({},self)
	self.tgtx=0
	self.tgty=0
	self.hastarget=false
	self.tgti=-1			--index of target
	self.thri=-1			--index of thrower
	self.tquad=-1			--which quadrant to throwto --TODO nr
	self:resetcurves()
	self.tdistance=0	--throw distance
	self.px,self.py=0,0 --the disc when up
	self.tdx=0.02					--disc speed
	self.tuser=0			--timer to limit user from wildness
--	self.dcalldisc=-1
--	self.ocalldisc=-1 --NR. see t<1 and t>0 :)
	return self
end
function phys:draw()
	if self.hastarget then
		local color=5 
		if t<1 then
			color=1
	--		spr(64,self.tgtx,self.tgty) --target spr
	--	circfill(x,y,size,14)--size-1,14)
--			circ(self.tgtx+4,self.tgty+4,1/(t/2),10)
			circ(p1.x+4,p1.y+4,1/(t/2),10)
		--dat lift
	--    spr(21,p0.x,p0.y)--pset(p0.x,p0.y,11)
	--    spr(18,p1.x,p1.y)--pset(p1.x,p1.y,11)
	--    spr(31+(flr(((g.fr%6)+1)/2)*16),p2.x,p2.y)--pset(p2.x,p2.y,8) --orb spr 
			--pset(mx,my,2)
	  end
	  pset(qbcvector(p0.x,p1.x,p2.x,t)+4,qbcvector(p0.y,p1.y,p2.y,t)+4,color)
	  pset(qbcvector(p0.x,p1.x,p2.x,t)+5,qbcvector(p0.y,p1.y,p2.y,t)+4,color)
	  pset(qbcvector(p0.x,p1.x,p2.x,t)+4,qbcvector(p0.y,p1.y,p2.y,t)+5,color)
  	pset(qbcvector(p0.x,p1.x,p2.x,t)+5,qbcvector(p0.y,p1.y,p2.y,t)+5,color)
	end
end
function guy:walls(x,y,gx,gy,l) --for 8x8 spr...ofs only --updated uf26 for allowing mans to run out of the frame.
	--if x<-20 or x>148 or y<-20 or y>283 then
	if x<-5 or x>133 or y<g.y-10 or y>g.y+138 then
		if x<-5 then x,gx=x+2,1 end
		if x>133 then x,gx=x-2,-1  end
		if y<g.y-10 then y,gy=y+2,1 end
		if y>g.y+138 then y,gy=y-2,-1 end
		
		return x,y,gx,gy
	end
	--return nil --saving tokebs 
end
function guy:wallsdraw(x,y,gx,gy,a,n)
	local posx,posy
	if x<g.x+2 or x>g.x+128-8 or y<g.y+2 or y>g.y+128-8 then
		if x<g.x+2 then posx,posy=4,y end
		if x>g.x+128-8 then posx,posy=108,y end
		if y<g.y+2 then posx,posy=x,g.y+4 end
		if y>g.y+128-8 then posx,posy=x,g.y+124 end
	else return end
	posx=max(min(posx,108),4)
	posy=max(min(posy,g.y+116),g.y+4)
	
	local s
	if gy<0 or gy>0 then
		if gy<0 then s=76
		elseif gy>0 then s=78 end
		if gx<0 then s+=32
		elseif gx>0 then s+=33 end 
	elseif gx<0 then
		s=77
	elseif gx>0 then
		s=79
	else s=83 end
	if not a then s+=16 end 
	
	local sprn=0
	if n=="x" then sprn=4
	elseif n=="o" then sprn=3 
	elseif n=="y" and g.turn==1 then sprn=98 end
	if a then sprn-=2 end
	spr(s,posx,posy)
	spr(sprn,posx+8,posy)
	
end
function phys:guydisc(x,y)
	self.px=(qbcvector(p0.x,p1.x,p2.x,t)+4) --evaluate position of disc...called every frame 
	self.py=(qbcvector(p0.y,p1.y,p2.y,t)+4)
	local size
	if g.turn==0 or t>1 then size=8 else size=5 end
	if x+size>=flr(self.px) and x<=flr(self.px) and y+size>=flr(self.py) and y<=flr(self.py) then
		return true
	else return false end		
end
function phys:dfsdisc(x,y,p,n)	--x means dfs[i].x
--disc position evaluated in guydisc fn
	local size
	if g.turn==0 then size=5 else size=9 end
	if n=="y" then --mark has smaller window more fun.
		if x+size>=flr(self.px) and x<=flr(self.px) and y+size>=flr(self.py) and y<=flr(self.py) then
			return true
		end
	else	--in coverage
		if x+size>=flr(self.px) and x<=flr(self.px) and y+size>=flr(self.py) and y<=flr(self.py) then
			return true
		end
	end
	return false
end
function phys:guys() --guys collisions. not very fun. uncomment to see it.
--	local dy=game:getdfsnum("y")
--	if g.turn==1 then
--		for i,o in ipairs(ofs) do 	--for each offense		
--			if o.xmin<=dfs[dy].xmax+8 --dfs left
--			and o.xmax>=dfs[dy].xmin-8
--			and o.ymin<=dfs[dy].ymax+8
--			and o.ymax>=dfs[dy].ymin-8		
--			then
--				o.bump=true
--			else
--				o.bump=false
--			end
--		end
--	end
--old code was for ofs on offense to collide with their opponent
--	for i,o in ipairs(ofs) do 	--for each offense
--		local d=dfs[i]
--		o.bump=false
--		if o.xmin<=d.xmax --dfs left
--		and o.xmax>=d.xmin
--		and o.ymin<=d.ymax
--		and o.ymax>=d.ymin
--		then
--			o.bump=true
--		end
--	end
end
function phys:manhattan(x1,y1,x2,y2)
	return (abs(x2-x1)+abs(y2-y1))*0.7071
end
function phys:scoredorno(team,teamname,i)
	if team[i].y<ezoneupmax-7 and team[i].y>ezoneupmin-7 then	--guy who caught it is in upper endzone 
		if (teamname=="ofs" and g.ptflip==1 and t<1) 
		or (teamname=="dfs" and g.ptflip==-1 and t<1)
		then
--			music(11)
			sfx(6,1)
			return true
		else return false end 
	elseif team[i].y>ezonelomin-7 and team[i].y<ezonelomax then --guy who caught it is in lower endzone
		if (teamname=="ofs" and g.ptflip==-1 and t<1) 
		or (teamname=="dfs" and g.ptflip==1 and t<1)
		then
			--music(-1)
--			music(11)
			sfx(6,1)
			return true
		else return false end 
	else 
		sfx(11)
		return false
	end 
end
function phys:caughtdisc() 
--printh("phys:caughtdisc() t="..t.." g.fr="..g.fr,"uf19.txt")
--xyzia
	dfs[1].active,dfs[2].active,dfs[3].active=true,true,true --so we can get new buttons zomg
	g:setindexes()																					 --just incase active changes without any catch 
	
	for i=1,3,1 do																										--loop offense
		if phys:guydisc(ofs[i].x,ofs[i].y) and (g.turn==1 or ofs[i].n~="y") then--catchable
			if ofs[i].marking==true and t<0.3 and g.turn==1 then return end --no handblocks
			if phys:scoredorno(ofs,"ofs",i) then g.someonescored,g.frscored,opoints = "ofs",g.fr,opoints+1						-- scoring touchdown.
			elseif t<1 then g.someonecaught,g.frcaught = true,g.fr end											-- making catch
			g.shaking=false																						--dont shake on framestop (i later removed framestops)
			
			if (g.turn==0 and t<1) or g.turn==1 then											--time is right for different turns 
				ofs[1].active,ofs[2].active,ofs[3].active = false,false,false
				ofs[i].fskid,ofs[i].red = 4,false 															--kill run vars before definitely becoming thrower
--				phys:resetcurves()																							--kill physics of previous throw 
				g.stall,g.frcaught = 0,g.fr																			--no stall, keep stall frames seperately. reset both.
				
				if g.turn==0 then																								--reception caught!
					redcatches+=1
					ofs[oiy].n,ofs[oiy].active = ofs[i].n,true										--previous thrower becomes active runner. everyone was reset above.
					ofs[oiy].throwto = -1																					--previous thrower set forward
					local j
					if ofs[i].n=="x" then j=dix else j=dio end 										--man switching occurs when subscripts dont match. fix that with this.
					dfs[diy].n,dfs[j].n = dfs[j].n,dfs[diy].n
				elseif g.turn==1 then																						--interception caught!
					if (t>0 and t<1) then 
						bluturnovers+=1
						g.message,g.fmessage,g.fmessageend="         turnover!",0,72
						sfx(16) 
					end
					
					
					if oia==i then
						ofs[oix].active = true																			--if active caught it, make someone else active
						--ofs[i].n,ofs[oix].n = ofs[oix].n,ofs[i].n
						dfs[i].n,dfs[dix].n = dfs[dix].n,dfs[i].n
					else 
					--ofs[i].active = true 
						ofs[oia].active = true
						ofs[i].n,ofs[oia].n = ofs[oia].n,ofs[i].n
						dfs[i].n,dfs[dia].n = dfs[dia].n,dfs[i].n
					end																	--if somebody not active caught it, the active guy can remain active
				end
				--dfs[ofs[i].id].n,dfs[diy].n="y",dfs[ofs[i].id].n							--my man changes letter with me
				ofs[i].n = "y"																									--i become thrower 
				ofs[i].throwto = -1
				dfs[diy].throwto = -1
				g.turn = 0																											--ofs catch, ofs turn
				g:xyforcam()																										--refresh bc camera has different offset for different turns
				phys:resetcurves()																							--kill physics of previous throw 
				--g:setindexes()																									--refresh global indexes bc our letter references
				--for i=1,3,1 do ofs[i].gy,ofs[i].gx,ofs[i].vy,ofs[i].state=-g.ptflip,0,0,"run" end
				for i=1,3,1 do 
					--if ofs[i].active==false then 
						ofs[i].gy,ofs[i].gx,ofs[i].vy,ofs[i].state=-g.ptflip,flr(rnd(3)-1),0,"run" 
					--end
					ofs[i].doverride=false
				end--uf50
				--ofs[1].gy,ofs[2].gy,ofs[3].gy=-g.ptflip,-g.ptflip,-g.ptflip
				--ofs[1].fskid,ofs[2].fskid,ofs[3].fskid=1,1,1
				--ofs[1].gx,ofs[2].gx,ofs[3].gx=0,0,0
				return true
			end
		end--catch
	end
	for i=1,3,1 do																										--loop defense
		if phys:dfsdisc(dfs[i].x,dfs[i].y,p0,dfs[i].n) and (g.turn==0 or dfs[i].n~="y") then --and i==1 then--catch
			if t<0.3 and g.turn==0 then return end --no handblocks
			if phys:scoredorno(dfs,"dfs",i) then g.someonescored,g.frscored,dpoints = "dfs",g.fr,dpoints+1								--framestop scoring touchdown.
			elseif t<1 then g.someonecaught,g.frcaught = true,g.fr end														--framestop making catch
			g.shaking=false																						--dont shake on framestop 
			
			if (g.turn==1 and t<1) or g.turn==0 then											--time is right for different turns 
				--phys:resetcurves()
				g.stall,g.frcaught = 0,g.fr
				if g.turn==0 then																							--interception caught!
					if (t>0 and t<1) then 
						redturnovers+=1
						g.message,g.fmessage,g.fmessageend="         turnover!",0,72
						sfx(16)
					end
					
					---for i=1,3,1 do ofs[i].gy,ofs[i].gx,ofs[i].fskid=-g.ptflip,0,1 end
					--ofs[1].gy,ofs[2].gy,ofs[3].gy=g.ptflip,g.ptflip,g.ptflip
					--ofs[1].gx,ofs[2].gx,ofs[3].gx=0,0,0 
					local ois,oi  
--					if dfs[diy].throwto="x" then oi,ois="x",oix else oi,ois="o",oio end --this is for later down there 
					
					dfs[i].throwto,dfs[i].active = -1,true
					dfs[i].n,dfs[diy].n = "y",dfs[i].n
					dfs[i].active,dfs[diy].active = false,true
					dfs[diy].state = "run"
					ofs[1].marking,ofs[2].marking,ofs[3].marking = false,false,false 
					ofs[1].active,ofs[2].active,ofs[3].active = false,false,false
					
--					ofs[oix].n,ofs[oix].active,
					--ofs[oiy].n,ofs[oia].n,ofs[oia].active = ofs[oia].n,"y",true 
					if g.turn==0 then ofs[oiy].n,ofs[oia].n,ofs[oia].active = ofs[oia].n,"y",true end 
					----ofs[oiy].throwto,ofs[oiy].n,ofs[oiy].active=-1,ofs[i].n,true	
				elseif g.turn==1 then																					--reception caught!
					blucatches+=1
					--dfs[oiy].throwto,dfs[oiy].n,dfs[oiy].active = -1,dfs[i].n,true
					dfs[diy].n = dfs[i].n												--previous thrower set forward
					--odfs[diy].n,dfs[i].n = dfs[i].n,dfs[diy].n

				end
				dfs[i].n = "y"																									--i become thrower
				dfs[i].throwto = -1
				ofs[oiy].throwto = -1
				g.turn=1
				g:xyforcam()																									--refresh bc camera has different offset for different turns
				phys:resetcurves()																							--kill physics of previous throw 
				g:setindexes()																								--refresh global indexes bc our letter references
				dfs[1].gy,dfs[2].gy,dfs[3].gy=g.ptflip,g.ptflip,g.ptflip				--everyone going forward.
				local leftd,rightd
				if dfs[dix].x<dfs[dio].y then leftd,rightd=dix,dio
				else leftd,rightd=dio,dix end 
				--dfs[leftd].tx,dfs[leftd].ty=wmx2,(dfs[diy].y+50*g.ptflip)
				--dfs[rightd].tx,dfs[rightd].ty=wmx1,flr(dfs[diy].y+30*g.ptflip)
				firstsetroutes=0
				return true
			end 
		end--catch
	end
	return false
end
function phys:discoob()
local oob
	if self.py<ezoneupmax and t>1 then --disc down in endzone
		p0.y,p1.y,p2.y=30,30,30
		p0.x,p1.x,p2.x=24,24,24
		t=1.1
		oob=true
	elseif self.py>ezonelomin and t>1 then
		p0.y,p1.y,p2.y=215,215,215
		p0.x,p1.x,p2.x=24,24,24
		t=1.1
		oob=true
	end
	if (self.py<ezoneupmin or self.py>ezonelomax) and t>0 then		--out the back 
		if self.py<ezoneupmin then	--upper endzone
			p0.y,p1.y,p2.y=30,30,30
			p0.x,p1.x,p2.x=24,24,24
			t=1.1
			oob=true
		else							--lower endzone
			p0.y,p1.y,p2.y=215,215,215
			p0.x,p1.x,p2.x=24,24,24
			t=1.1
			oob=true
		end
	elseif (self.py<ezoneupmax+10 or self.py>ezonelomin-10) and (self.px<5 or self.px>123) and t>0 then --out the side of endzone
		oob=true
		if self.py<100 then --which endzone 
			p0.y,p1.y,p2.y=30,30,30
			p0.x,p1.x,p2.x=24,24,24
			t=1.1
		else
			p0.y,p1.y,p2.y=215,215,215
			p0.x,p1.x,p2.x=24,24,24
			t=1.1
		end
	elseif ((self.px<5 or self.px>123 and g.turn==0) 
	or (self.px<7 or self.px>121 and g.turn==1))
	and t>0.3 then --sides. tbh time condition is just for game start.
		t=1.1
		p0.x,p1.x,p2.x=64,64,64
		p0.y,p1.y,p2.y=phys.py,phys.py,phys.py
		oob=true
	end
	
	if oob then 
		g.message="       out of bounds"
		g.fmessage,g.fmessageend=0,72
		sfx(17)
		incrthrowaways()
	end
end
function incrthrowaways()
	if g.turn==0 then redthrowaways+=1 redturnovers+=1
	else bluthrowaways+=1 bluturnovers+=1 end
end
function phys:throwtarget(n)
	local team
	if g.turn==0 then
		self.thri=game:getofsnum("y") 
		team=ofs
	elseif g.turn==1 then
		self.thri=game:getdfsnum("y")
		team=dfs --DEBUG 
	end
--	local xmin,xmax,ymin,ymax --5,64,123

--	local pad=15 								--thrower hitbox size
--	local range=50
--	repeat																		--dont throw to the thrower
--		self.tgtx=rnd(xmax-xmin)+xmin					--random target testing
--		self.tgty=rnd(ymax-ymin)+ymin
		--local flip = g.ptflip
		
		self.tgtx=team[n].x+(rnd(40)*team[n].gx) +((20)*1*team[n].gx) *((g.turn+1)%2)--*(abs(team[n].gy+1)%2)-- +(rnd(20))				--throw where he is going
		self.tgty=team[n].y+(rnd(50)*team[n].gy) +((20)*1*team[n].gy) *((g.turn+1)%2)--*(abs(team[n].gy+1)%2) --70 is about perfect.
		--self.tgty=team[n].y+((rnd(range))+rnd(30)*-g.ptflip) *team[n].gy
--	until((not(self.tgtx<=team[self.thri].x+pad	--dont throw to the thrower
--				and self.tgtx>=team[self.thri].x-pad
--				and self.tgty<=team[self.thri].y+pad
--				and self.tgty>=team[self.thri].y-pad))) --DEBUG 
				
	sfx(9)
end
function phys:throw(str)
	local team 
	if g.turn==0 then team=ofs
	else team=dfs end
	if not self.hastarget then --first run we get our target coords
		--self:throwtarget(str)
--		self:resetcurves()
	else 
	--some lifting required 
		if (t>1 and t<1.1) then 
			team[self.thri].throwto=-1
			--firstrun=true
			t=1.1	--i swear this condition here is the only place i use this hack lol 
			incrthrowaways()
			return --hopefully fix recurring hastarget issue with this bc it bogged 
		end --reset() end

		if firstrun then
			throw=false
			p0.x=team[self.thri].x
			p0.y=team[self.thri].y
			p1.x=self.tgtx
			p1.y=self.tgty
			local r=30
			mx=((p0.x+p1.x)/2)-(r/2)+rnd(r) --midpoint formula
			my=((p0.y+p1.y)/2)-(r/2)+rnd(r)
			p2.x,p2.y=mx,my
			mangle=atan2(p0.y-my,p0.x-mx)
			self.tdistance=self:manhattan(p0.x,p0.y,p1.x,p1.y)
			firstrun=false
		end

		if btn(5) and btn(4) and self.tuser<15 and 0==1 then --thnx for hacking ;)
			if btn(0) then 
				p2.x-=3
				p1.x-=0.5
			end
			if btn(1) then 
				p2.x+=3 
				p1.x+=0.5
			end
			if btn(2) then 
				p2.y-=3
				p1.y-=1.5
			end
			if btn(3) then 
				p2.y+=3 
				p1.y+=1.5
			end
			self.tdx=0.01
			self.tuser+=1
		end

		if t>0.9 and t<1 then		--more fun to have disc catchable even after path done
			t+=0.003	--throw clock
			self.t2+=0.003
		elseif self.tdistance>20 then
			t+=self.tdx	--throw clock
			self.t2+=self.tdx
		else
			t+=self.tdx+0.02	--throw clock
			self.t2+=self.tdx+0.02
		end

	end
	self.hastarget=true
end
function phys:resetcurves()
	t=0
 p0={	--starting point 
 x=-100,
 y=-100*g.ptflip*3
 }
 p1={	--ending point
 x=-100,
 y=-100*g.ptflip*3
 }
 p2={	--bend point
 x=-100,
 y=-100*g.ptflip*3
 }
 t=0
 --self.px,self.py=0,0 --this is evaluated position of disc
 self.t2=0
 throw=false
 firstrun=true --sus
 	dx,dy=0,0
	angle=0
	rot=0
	numclicks=0
	self.tuser=0
	self.tdx=0.02
	speed=4 --orb speed 
	self.hastarget=false --bug002 i forgot this line and it bogged the game down so bad. another thing you can do sometimes is remove cls() just to check drawing methods. 
end
function lv(v1,v2,t)
    return (1-t)*v1+t*v2
end
function qbcvector(v1,v2,v3,t) --Quadratic Bezier Curve Vector
    return  lv(lv(v1,v3,t), lv(v3,v2,t),t)
end
--x1,y1 = starting point 
--x2,y2 = end point
--x3,y3 = 3rd manipulating point 
--n = "smoothness"
--c = color
function drawqbc(x1,y1,x2,y2,x3,y3,n,c)
	for i = 1,n do 
		local t = i/n
		pset(qbcvector(x1,x2,x3,t),qbcvector(y1,y2,y3,t),c)
	end
end
ofs=guy:new()
dfs=guy:new()
function dfs:construct(pn,px,py,pa)
	self.state="idle"
	self.n=pn
	self.m=0 --man
	self.spr=18
	self.x,self.y=px,py
	self.xmin,self.xmax,self.ymin,self.ymax=self.x+1,self.x+5,self.y,self.y+7
	self.vmax=1
	self.vx,self.vy=0.0
	self.ax,self.ay=0.1,0.1
	self.gx,self.gy=0,0
	--self.tx,self.ty=0,0
	self.oldbutts={}
	self.newbutts={} --for defense on offense, need property to persist.
	self.staybutts={}
	self.feetup=false
	self.flip=false
	self.red=nil
	self.bump=false
	self.active=pa
	self.fr=0
	self.frun=0 --56 on; 36 off.
	self.fankle=0
	self.ankle=false
	self.fskid=0
--	self.active=false --now we need all the things.
	self.throwto=-1
	self.draw=self.draw
	self.update=self.update
end
function dfs:setbuttsgetflag()
--reset
	local tp=6 --3 
	self.oldbutts=self.newbutts
	self.newbutts={}
	self.tx,self.ty=flr(self.tx),flr(self.ty) --bc i am seeing x=9 bump up to x=9.3396 not sure why.
--get man
	for i,v in ipairs(ofs) do 
		if self.n==v.n then self.m=i end 
	end
	local mantodisc=phys:manhattan(ofs[self.m].x,ofs[self.m].y,p1.x,p1.y)	--TODO not local pls.
	local metodisc=phys:manhattan(self.x,self.y,p1.x,p1.y)
	local metoptgt=phys:manhattan(self.x,self.y,phys.tgtx,phys.tgty)
--get target to run at
	if g.turn==0 then
		if ((metodisc<mantodisc and t>0) and (t<1 or self.id==1)) or (t>1 and self.id==1) then
			self.tx=ceil(phys.px-2)
			self.ty=ceil(phys.py-2)
		else	--track man 
			--self.tx=ceil(ofs[self.m].x)
			self.tx=max(min(ceil(ofs[self.m].x),108),4)
			if g.ptflip==1 then self.ty=ceil(ofs[self.m].y-(6*g.ptflip))-2
			else 								self.ty=ceil(ofs[self.m].y-(6*g.ptflip))+4 end 
		end
	elseif g.turn==1 then
		if t>0 and t<1 then																	--chase any disc up 
			if dfs[diy].throwto~=self.n then									--unless its not my disc 
				self.ty=200*g.ptflip
			elseif metoptgt>metodisc then
				self.tx=ceil(phys.px)--(2*g.ptflip))
				self.ty=ceil(phys.py)--(2*g.ptflip))
			else
				self.tx=ceil(phys.tgtx)-- -(0*g.ptflip))
				self.ty=ceil(phys.tgty)-- -(0*g.ptflip))
			end
		elseif t>1 then																				--pending turnover.
			self.tx=30*self.id
			self.ty=ceil(phys.py-(20*g.ptflip))
		elseif (self.x>self.tx-tp and self.x<self.tx+tp) and (self.y>self.ty-tp and self.y<self.ty+tp) or firstsetroutes<2 then --washing machine. if hit the target pretty close, get new targer
			local yroutel, yrouter
			if g.ptflip>0 then yroutel,yrouter=g.y+110-rnd(12),g.y+68+rnd(6)
			else yroutel,yrouter=g.y+10+rnd(12),g.y+58-rnd(6)		--some variation added to y
			end 
			if firstsetroutes<2 then --+1 for each guy thru here
				if self.n=="x" then self.tx,self.ty=self.x,flr(yroutel)--rm wmx2
				else 
					local wmx
					if dfs[dix].x<60 then wmx=wmx2 else wmx=wmx1 end
					self.tx,self.ty=wmx,flr(yroutel)
				end
			elseif g.stall>5*10 then self.tx,self.ty=self.tx,flr(dfs[diy].y-20*g.ptflip*ceil(rnd(1))) --route for panic throw
			elseif self.x<rnd(60)+30 then --(left target)
				self.tx,self.ty=wmx2+rnd(12),flr(yroutel)--dfs[diy].y+70*g.ptflip)	--some variation added to x first time.
			else	--right target must be...
				self.tx,self.ty=wmx1-rnd(12),flr(yrouter)--dfs[diy].y+30*g.ptflip)
			end
			firstsetroutes+=1
		end
		--dtxs[self.n],dtys[self.n]=self.tx,self.ty		--populate tgt table
	end
--get newbutts
--uf13 let defense go outside walls
--uf24 newbutts for all again 
--	if g.turn==0 or t>0 then
		if self.marking then return false end 
		if self.tx<self.x then
			self.newbutts[0]=true
		elseif self.tx>self.x then
			self.newbutts[1]=true
		end
		if self.ty<self.y then
			self.newbutts[2]=true
		elseif self.ty>self.y then
			self.newbutts[3]=true
		end
--	end
--return inputchanged flag
--	if self.newbutts~=self.oldbutts then
	for i=0,3,1 do 
		if self.newbutts[i]~=self.oldbutts[i] then
			return true
		end
	end
	return false
end
function dfs:update()
	if self.n=="y" and g.turn==1 and t<1 then
		self.state="throw"
		if self.throwto~=-1 then self.state="throwing" end
	else
		self:runupdate() --skid,run,idle
--		if phys:dfsdisc(self.x,self.y,p0,self.n) and t>0 then --(t<1 and t>0) then --disc caught!
--				self:caughtdis()
			--end --turn0/1
--		end --disc
	end --not thrower
end
function dfs:runupdate() --state machine
	self.fr+=1																		--frame counter	
	if self.active then											--if active, get buttons, get inputchanged
		local inputchanged=self:setbuttsgetflag()
		if inputchanged then
			self.state="skid"														--skid mode on 
			self.fskid=0
			self.x,self.y=flr(self.x),flr(self.y) 			--sub pixels fix diagonal
			
		end		
		self:butts2gxgy(self.newbutts,self.gx,self.gy)
	end
	
	if self.state=="skid" then											--if skid state (4 frames)
		self:brokeankle()
		if self.ankle then return 0	end
		self.flip=(self.gx==1)												--flip when going right.
--		if self.frun>55 then self.red=true end 				--red mode on 
		if self.fskid==4 then													--reset some vars before they key up.
			self.frun,self.gx,self.gy,self.vx,self.vy=0,0,0,0,0
		end
		if self.fskid==4 then self.state,self.fskid="run",0 --skid mode off
		else self.fskid+=1 end															--skid 4 frames count
	elseif self.gx~=0 or self.gy~=0 then						--if running state (n frames)
		self.state="run"
		self.frun+=1																	--state frame counter
		self.feetup = (self.fr%8 > 3)
		if not self.feetup then return 0 end 					--exit if feet down
--		if self.red then self.vx,self.vy=self.vmax,self.vmax end --red mode super speed
--		if self.frun==14 then self.red=false end											 --red mode off 
		self:gx2vx(self.vx,self.vy,self.ax,self.ay,self.vmax)		--set unsigned velocity using acceleration
		self.flip=(self.gx==-1)
		self:vx2x(self.x,self.y,self.vx,self.vy,self.gx,self.gy)
	else 
		self.state="idle"
--		self.red=false
	end
	--self:walls()
--	if phys:walls(self.tx,self.ty)~=nil then					--walls
--		self.x,self.y=phys:walls(self.x,self.y)
--		self.state="idle"
--		self.red=false
--		self.frun,self.gx,self.gy,self.vx,self.vy=0,0,0,0,0
--	end
end
function dfs:brokeankle()
	if g.turn==1 then 
		self.ankle,self.fankle=false,0
	end
	if self.ankle then self.fankle+=1 end
	if not self.ankle and ceil(rnd(20))==1 
	and phys:manhattan(self.x,self.y,ofs[self.m].x,ofs[self.m].y)<10 then self.ankle=true end
	if self.fankle==16 then 	--how long to stay down
		self.ankle=false
		self.fankle=0
	end
end
function dfs:imopen()
--	if doublemark then return end
	--if g.stall>8 then return true end --panic throw
	local copen=20
	local metodisc=phys:manhattan(self.x,self.y,p1.x,p1.y) --using self now 
	local ytomark=phys:manhattan(dfs[diy].x,dfs[diy].y,ofs[oiy].x,ofs[oiy].y)
	if self.n~="y" then
		for i=1,3,1 do
			dmtns[i]=phys:manhattan(self.x,self.y,ofs[i].x,ofs[i].y)
		end
		if (dmtns[1]>copen and dmtns[2]>copen and dmtns[3]>copen and ((g.ptflip<0 and self.y<dfs[diy].y-10) or (g.ptflip>0 and self.y>dfs[diy].y+10))) or g.stall>80 then 
			if ((self.x<dfs[diy].x+20 or self.x>dfs[diy].x-60) and metodisc>32) or g.stall>80  then --and g.fr>g.frcaught+40 then
				if dfs[diy].throwto==-1 then -- and 1==0 then --DEBUG MODE 
					phys:throwtarget(self.id)
					dfs[diy].throwto=self.n
--					if self.n=="x" then dfs[dio].tx,dfs[dio].ty=0,g.ptflip
--					else dfs[dix].gx,dfs[dix].gy=0,g.ptflip end
					return true
				end --get target 1 time only
			end
		end
	end
end
function dfs:rundraw()
	if self.fr%8 > 3 then self.spr=25
	else self.spr=24 end
	spr(self.spr,self.x,self.y,1,1,self.flip,false)
end
function dfs:skiddraw()
	local skidspr=26								--default not red skid spr
	if self.red then					--red mode spr 36 or 52
		skidspr=(self.fr%2)*16+36
	end
	spr(skidspr,self.x,self.y,1,1,not self.flip,false)
end
function dfs:throwdraw()
	spr(27,self.x,self.y)
	spr(22,self.x+8,self.y)
end
function dfs:throwingdraw()
	spr(28,self.x,self.y)
end
function dfs:letterdraw() end --stub overriding
function dfs:idledraw()
	spr(24,self.x,self.y)
end
function dfs:wallsdraw() end
--function dfs:stalldraw() --dfs
--	if self.n=="y" then --and g.turn==0 then --mark
--		if g.stall>0 then
--			print(flr(g.stall/20),self.x,self.y-7,8)
--		end
--	end
--end
--function dfs:drawtxty()
--	spr(48,self.tx,self.ty)
--end
------------------------ /dfs
__gfx__
000000000fffff000fffff0007777700077777000000000033333333333333333633333333344444444446333333333344444444444444f44444444477777777
00000000ff000ff0ff0f0ff077000770770707700d777c0033333333333333333bb36b3333b44444444444b33b3bb3b344444444444f4444444444447dddddd7
00000000ff0f0ff0fff0fff0770707707770777007dd67003333333333333333334b64b43b44f44444444b3364bb44b34444444444444444444444447d9999d7
00000000ff000ff0ff0f0ff0770007707707077007df970033333333333333333b4444443664444444f4bbb3444b4b334444444444444444444444447d9ee9d7
000000000fffff000fffff00077777000777770007b99700333333333333b3333bbb4f4433b4b444444444b344444663444444444444444f4444b4447d9ee9d7
000000000000000000000000000000000000000003777900333333333b3b333333b444443b44bb464b46b433444f44b344444444444444444b4b44447d9999d7
000000000000000000000000000000000000000000000000333333333b3b33333b4444443b3bb3b333b63bb344444b3344444444444444444b4b44447dddddd7
00000000000000000000000000000000000000000000000033333333333333333364444433333333333333634444443344444444444444444444444477777777
1100000000000000000000000099ee00000000000000000000000000000000000000000000ccdd0000000000000000000000000000000000000000000c000000
110000000099ee000099ee00099ae0000ee9900000099ee00000000000099ee000ccdd000cc6d0000ddcc000000ccdd0000ccdd0000000000000000000000000
00000000099ae000099ae000091f190000ea99000099ae00000000000099ae000cc6d0000c1f1c0000d6cc0000cc6d0000cc6d000ddcc0000ddcc00000000c00
00000000091f1900091f190000fff000091f19000091f190000000000091f1900c1f1c0000fff0000c1f1c0000c1f1c000c1f1c000d6cc0000d6cc0000070000
0000000000fff00000fff0007977797070fff000000fff0000000000000fff0700fff0007c777c7070fff000000fff00000fff070c1f1c000c1f1c0000707000
00000000097779700977790007191700097779000097779711000000009777900c777c00071c17000c777c0000c777c700c777c070fff00070fff00000070000
0000000007191000071917000000000000191070007191001100000007019100071c170000000000001c10700071c1000701c1000c777c000c777c000c000000
00000000007070000070700000000000070700000007070000000000000700700070700000000000070700000007070000070070474710705757107000000000
111100000099ee000505000000777700000000000000000000000000444b70003634444444444444444443633333333344444444333333333333333300000000
111100000e9ae0000055505007777000088880000001111000000000444bb0003bb4444444444444444446333bb3b63b44444444333333333333333300000000
11110000091f19000555550007777700008888000011110000000000b0b000003344444444444444444444b3bb44b36444444444333333333ddcc3330c000000
1111000000fff0005055500000777000088888000011111000000000000000003b44444444444f4444444b334b4f44444444444fa9aa99a633d6cd330007c000
00000000097779700555550077777770808880000001110011110000000000003bbb444444444b444444bbb344444444444444449a6a9a993c1f1c3300707000
0000000070191000005555000777770008888800001111111cc100000000000033b44f4463b44bb444444fb344444444444444443333333373fff33300070000
0000000000700700055550000000000000888080001111001cc10000000000003b44444436b3bb3b4444443344444444444f4444333333333c777c3300000c00
0000000000000000000000000000000008080000000101001111000000000000336444443333333344444bb344444444444444f433333333b7b7137300000000
00888800000000000005005000cccc000000000000000000000000009999000099999999000000aa33333633f3f3fff3fff3fff3333333334444444400000000
080000800eeeee00050555000cccc00007777000000222200000000099990000999999990a0000aa333333b3f3f3f33ff333f3f33b3bb3b644444444000c0000
800000080000e000005555500ccccc000077770000222200000000009999000099999999aa8ae00033663b333f33f33ffff3f3f364bb45b34ddcc44400000000
80000008000e00000005550500ccc00007777700002222200000000099999999999999999998e800333bbbb63f33f33f33f3f3f3a9aa99a644d6cd4400070000
8000000800e0000000555550ccccccc070777000000222000000000099999999999999999999ea0033fb3fb63f33fff3fff3fff39a6a9a994c1f1c4400707000
800000080eeeee00005555000ccccc00077777000022222222000000999999999999999999999e003bb36336333333333333333344f4464674fff44400070000
08000080000000000005555000000000007770700022220022000000999999999999999999999aa033333bb33333333333333333b644b3464c777c4400000c00
00888800000000000000000000000000070700000002020000000000999999999999999999999a00333333633333333333333333b33bb33357571474c0000000
00888800888088808888880088800000888888808888880088800888000000700071917000070000000000000000000000000000000000000000000000000000
0899998087808780877778008780000087777780877778008788087800e0909707977797007909900000000000000000000f0000000f0000000f00000000f000
8998899887808780870078008780000088878880870078008777887800ee1f71000fff000017f199000000000000000000fff00000f00000000f000000000f00
898ee898878087808700780087800000008780008700780087878878009aff790091f1900097ffa900000000070700000f0f0f000fffff000f0f0f0000fffff0
898ee89887808780877778008880000000878000877778008788787800991f71000ea9900017f1ee0000000077777000000f000000f0000000fff00000000f00
899889988788878087888800888000000087800087788800878877780009909700ee99000079090e0000000007070000000f0000000f0000000f00000000f000
08999980877777808780000087800000008780008787800087808878000000700000000000070000000000007777700000000000000000000000000000000000
00888800888888808880000088800000008880008888800088800888000000000000000000000000000000000707000000000000000000000000000000000000
000000700071c1700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d0c0c707c777c7007c0cc000000000000000000000000000000000000000000000000000000000000000000000000000070000000700000007000000007000
00dd1f71000fff000017f1cc000000000000000000000000000000000000cc000000000000000000000000000000000000777000007000000007000000000700
00c6ff7c00c1f1c000c7ff6c00000000000000000000000000000000017f1cc00000000000000000000000000000000007070700077777000707070000777770
00cc1f71000d6cc00017f1dd000000000000000000000000000000007c7ff6c00000cc0000000000000000000000000000070000007000000077700000000700
000cc0c700ddcc00007c0c0d00000000000000000000000000000000017f1dd0717f1cc000000000000000000000000000070000000700000007000000007000
0000007000000000000700000000000000000000000000000000000070c000d00c7ff6c000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000700000717f1dd000000000000000000000000000000000000000000000000000000000
0fffff00000000000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff000ff0000000007700077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff000ff0000000007700077000000000000000000000000000000000000000000000000000000000000000000000000000ffff0000ffff0000f00f0000f00f00
fff0fff0000000007770777000000000000000000000000000000000000000000000000000000000000000000000000000ff00000000ff0000f0f000000f0f00
0fffff00000000000777770000000000000000000000000000000000000000000000000000000000000000000000000000f0f000000f0f0000ff00000000ff00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00f0000f00f0000ffff0000ffff00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777700007777000070070000700700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000770000000077000070700000070700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707000000707000077000000007700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700700007007000077770000777700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000011111111111111111111111000000000000000000000000000000000000001111111111111111111111100000000000000
00000000000000000000000000000157777777777777777777777100000000000000000000000000000000000015777777777777777777777510000000000000
00000000000000000000000000000157777777777777777777777510000000000000000000000000000000000177777777777777777777777510000000000000
00000000000000000000000000000155777777777777777777777771000000000000000000000000000000001777777777777777777777775510000000000000
00000000000000000000000000000015d777777777777777777777710000000000000000000000000000000017777777777777777777777d5100000000000000
000000000000000000000000000000155dd77777777777777777777510000000000000000000000000000001577777777777777777777dd55100000000000000
00000000000000000000000000000001555d777777777777777777771000000000000000000000000000000177777777777777777777d5551000000000000000
00000000000000000000000000000000115557777777777777777777710000000000000000000000000000177777777777777777777555110000000000000000
00000000000000000000000000000001111115557777777777777777710000000000000000000000000000177777777777777777555111111000000000000000
00000000000000000000000000000015d777777777777777777777777710000000000000000000000000017777777777777777777777777d5100000000000000
00000000000000000000000000000015d777777777777777777777777710000000000000000000000000017777777777777777777777777d5100000000000000
000000000000000000000000000000115d7777777777777777777777771000000000000000000000000001777777777777777777777777d51100000000000000
0000000000000000000000000000000115dd777777777777777777777751000000000000000000000000157777777777777777777777dd511000000000000000
000000000000000000000000000000001155dddd7777777777777777777100000000000000000000000017777777777777777777dddd55110000000000000000
0000000000000000000000000000000000115555dd777777777777777771000000000000000000000000177777777777777777dd555511000000000000000000
00000000000000000000000000000000001111111115557777777777777510000000000000000000000157777777777777555111111111000000000000000000
00000000000000000000000000000000015ddddd7777777777777777777710000000000000000000000177777777777777777777ddddd5100000000000000000
00000000000000000000000000000000015ddddddd777777777777777777100000000000000000000001777777777777777777ddddddd5100000000000000000
000000000000000000000000000000000015dddddddd77777777777777771000000000000000000000017777777777777777dddddddd51000000000000000000
00000000000000000000000000000000000155ddddddddd77777777777775100000000000000000000157777777777777ddddddddd5510000000000000000000
00000000000000000000000000000000000011555555555555555555577771000111111111111110001777755555555555555555551100000000000000000000
000000000000000000000000000000000000001111111111111111111577111119999999fffffff1111177511111111111111111110000000000000000000000
000000000000000000000000000000000000000000000000000000000111d99999999999999999ffffff11100000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000001d999999999999999999999999fdd100000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000001d99999f99999999999999999999d100000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000001d99999fff9999999999999999994100000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000001199999999fffffffff9999999991100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000001444499999999999999999944441000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000011114444449999999d444411110000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000001111114444dddd1111110000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000111111110000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05777770000000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777000000007777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777000000077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005777770000007777d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd77770000007777dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099ff9900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05777770000000000777775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777700000077777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099ff9900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
57777770000000007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05777777000000007777775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777000000077777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577777700000077777d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd7777700000077777dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099ff9900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2b2b2b0b080b07062c2c0c2c0c2c2c2c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292c0c2a092c0b070a2929290a29292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07282c0a07090a062d2d2d2d2d2d2d2d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0709290a3a3a3a3a2b2b082b2b2b082b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
082b0b06060606060d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
282c2a0b07070706060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09292c2a07070707070606061a06060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606090a070706070706061e3e06060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606070707060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
082b2b2b2b0b0606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
282c2c0d2c2a0706060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090e0d0d0e2a0706060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
280d0e0d290a0606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
280d0d2a07070606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0929290a07070606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000725000000000000725000000000000725000000000000e2500000000000112500000000000112500c25000000000000c25000000000001325000000000001325000000000000c250002500225006250
00100000166550c053000000000024655000000c053000000c05300000000000000024655000000000000000117000c0530c05300000246550000000653180531f0500c053137001665524650166550165000655
001000000745000000000000745000000000000745000000000000e4500000000000114500000000000114500c45000000000000c45000000000001345000000000001345000000000000c450004500245006450
0010002013550175501a35013650171501a1501f65013050170501a0501f05000000116501505018450000000c65010150133500c65010150131501f6500c150102501345011450153501865013250171501a150
0010000013750177501a45013150173501a3501f15013250172501a2501f25000000111501535018650000000c15010350135500c15010350133501f1500c350104501365011650155501815013450173501a350
000800002b1502b15000000000002b150000002b15000000321503215032150321500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000050013550005001355013550000000755000500005001a5501a55000500115500050000500115500c55000500005001855000500005001f5501f550005001355000500005000c550005500255006550
001000001f0501a0501f0501f05023050260501f050180501a0501f0501f0501d0501f05023050180501f0500000000000000000000000000000000000000000262501f250232501a2501f250212502825026250
00020000006500065000650073500d3501035012350173501b3502035025350293500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000007500175002750027500375005750077500875009750097500b7500c7500d7500e7500e7500f750066503965005650056500665006650066502d4500665006650066500665006650384500465004650
00010000000002a450284502345014450084500245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001800001125014250182501d2501825014250112500c2500e250162501a2501d250002000020000200002000f250162501a2501f2501a250162500f2500c2500e25013250182501f2501f2501f2501d2501d250
0018000018550185501855018550185501855018550185501a5501a5501a5501a550005000050000500005001a5501a5501a5501a5501a5501a5501a5501a5501655016550165501655016550165501855018550
001800001d0501d0501d0501d0501d0501d0501d0501d0501d0501d0501d0501d0502215024150261502b1501f0501f0501f0501f0501f0501f0501f0501f0501a0501a0501a0501a0501a0501a0501605016050
001000000c25010250132500c25010250132500c25010250132500c25010250132500c25010250132500c25010250132500c25010250132500c25010250132500c25010250132500c25010250132500c25010250
0003000014550022500005010250000502225000050263500005027350000501b250152500e250042500125000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000032570000000000000000215700000000000000000000000000000000000000000000000000000000000000b5700000000000000000000000000000000000000000000000000000000000000000000000
000100000a4700a4700b4700c4700d4700d4700e4700e4700e4700e4700e470000000000000000000000000000000000000000000000000000747005470054700347003470024700000000000000000000000000
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
03 05 42 43 04
00 41 42 03 44
00 01 02 03 44
00 01 02 03 44
01 01 02 03 04
00 01 02 03 04
00 01 02 03 05
00 01 02 03 05
00 05 02 03 07
02 41 02 03 08
03 0c 0d 0e 44
03 0f 02 03 44
00 10 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 0c
00 41 42 43 44
00 0c 42 43 44
00 41 0c 43 44
00 41 42 0e 44
00 41 42 43 10
00 41 42 43 44
00 11 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
