pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--pacifist-8
--by scott_grogin
function _init()
 srand(4)
	d2t=0.00277778
	updlvs=false
	dfclt=1
	lvctr=1
	timer=0
	pl=lvctr
	bltclr=7
	blts={}
	enmy={}
	tls={}
	lvs={}
	plr={
 	x=0,
 	y=0,
 	s=1,--speed
 	ishit=false,
 	ifrm=30,
 	hp=50,
 	e=false,
 	et=2,--explosion timer
 	dt=30*2--death timer
 }
	lvstrt()--1
 lvintro()--2
	lvfarm()--3
	lvt1()--4
 lvsky()--5
 lvt2()--6
 lvcity()--7
 lvt3()--8
 lvfinal()--9
 lvgmovr()--10
 lvs[lvctr]:init()
end

function _update()
	timer+=1/30
	if lvctr!=pl then
		rpal()
		blts={}
		enmy={}
		tls={}
		timer=0
		plr.e=false
		plr.x=64
		plr.y=100
		if dfclt==1 then
			plr.hp=1000
		elseif dfclt==2 then
		 plr.hp=50
		elseif dfclt==3 then
		 plr.hp=25
		elseif dfclt==4 then
			plr.hp=3
		end
		lvs[lvctr]:init()
	end
	pl=lvctr
	updlvs=(lvctr==3 or lvctr==5 or lvctr==7 or lvctr==9)
	for t in all(tls)do
		t:update()
	end
	lvs[lvctr]:update()
	for e in all(enmy)do
		e:update()
	end
	if updlvs then
		pupdate()
	end
	for b in all(blts)do
		b:update()
	end
end

function _draw()
 if(updlvs)then
		cls()
	end
	for t in all(tls)do
		t:draw()
	end
	lvs[lvctr]:draw()
	for e in all(enmy)do
		e:draw()
	end
	if updlvs then
		pdraw()
	end
	for b in all(blts)do
		b:draw()
	end
	if updlvs then
		rectfill(0,0,127,6,2)
 	txt=' dead'
		if pget(plr.x,plr.y)==bltclr then
	 	plr.ishit=true	
	 end
	 if lvctr==3 then
	 		print("†farm†",97,1,14)
	 end
	 if lvctr==5 then
	 		print("‰astral‰",89,1,14)
	 end
	 if lvctr==7 then
	 		print("–ocean–",89,1,14)
	 end
	 if lvctr==9 then
	 		print("final",89,1,14)
	 end
	 if plr.hp>0 then
		 txt='‡:'..plr.hp
	 end
	 print(txt,0,1,14)
	end
end
-->8
function adblt(x,y,a,s,clr,fol)
 add(blts,{
 	fol=false,
 	x=x,
 	y=y,
 	a=a,
 	s=s,
 	clr=clr,--color
 	ttl=30*5,
 	update=function(self)
 		if self.ttl==30*5 and not(self.x>128 or self.y >128 or self.x<0 or self.y<0) then
 	 	sfx(8)
 	 end
 	 if fol then
 	 	self.a=ag(self.x,self.y)
 	 --	atan2(plr.x-self.x,plr.y-self.y)*360
 	 end
 		self.x+=cos((self.a*d2t)%1)*self.s
 		self.y+=sin((self.a*d2t)%1)*self.s
 		self.ttl-=1
 		if(self.ttl==0 or self.x>128 or self.y >128 or self.x<0 or self.y<0)then
 			del(blts,self)
 		end
 	end,
 	draw =function(self)
 	 ex=self.x
 	 ey=self.y
 	 rectfill(ex-1,ey-1,ex+1,ey+1,self.clr)
 	end
 })
end
-->8

function	pupdate()
 if(plr.dt ==0)then
 	music(-1)
 	
 
		lvctr=10
		
	else
		if(plr.ishit and plr.ifrm==30 and plr.hp>0)then
			plr.ishit=false
			plr.ifrm-=1
			plr.hp-=1
			sfx(6)
		end
		if(plr.ifrm<30)then
			plr.ishit=false
			plr.ifrm-=1
		end
		if(plr.ifrm<0)then
			plr.ishit=false
			plr.ifrm=30
		end
		brk=1
		plr.x%=128
		yp = plr.y-7
		yp%=121
		plr.y=yp+7
		if(plr.hp>0) then
 		if(btn())then
 			brk=0.5
 		end
 		if(btn(—))then
 			brk=1.2
 		end
			if(btn(”))then
				plr.y-=brk
			elseif(btn(ƒ))then
				plr.y+=brk
			end
			if(btn(‹))then
				plr.x-=brk
			elseif(btn(‘))then
				plr.x+=brk
			end
	 end	
		
		if(plr.hp==0)then
			plr.e=true
		 plr.dt-=1
		end
 end	
end
  	
function pdraw()
	px=plr.x
	py=plr.y
	px4=px-4
	
	if(plr.dt >0)then
		if(plr.ifrm<30 and plr.ifrm%2==0)then
			spr(2,px4,py-4)
		else
			spr(1,px4,py-4)
		end
		pset(px,py,14)
		if(plr.e)then
			--explode
			plr.et%=14
			plr.et+=2
			et=plr.et+190
 
			if(et%14==0)then
				sfx(34)
			end
			spr(et,px-8,py-8,2,2)
			spr(et,px4,py-2,2,2)
			spr(et,px-12,py-2,2,2)
	 end
	end
end


-->8
function adtil(x,y,s,sp,sz)
	add(tls,{
		x=x,
		y=y,
		s=s,
		sp=sp,
		sz=sz,
		update=function(self)	
			siz=self.sz*8
		 self.y+=siz
			self.y%=128+siz
			self.y-=siz-self.s
		end,
		draw=function(self)
	  scspr(self.sp,1,1,self.x,
	  self.y,self.sz)
		end
	})
end
-->8
function lvsky()
	add(lvs,{
	tmr=0,
	t={30*7,30*12,30*18,30*22,
	30*30,30*37,30*45,30*48,30*54,
	30*59,30*64,30*95,30*100,30*115,
	30*155,30*158,30*166,30*168,
	30*173,30*175,30*181,30*221,
	30*224,30*305,30*308,30*310},
		init = function(self)
		 bltclr=1
			self.tmr=0
			plr.x=64
			plr.y=100
			bgtil(40)
	  music(0)
		end,
		update = function(self)
	 	self.tmr+=1
	 	tm=self.tmr
			tt=self.t
			if(tm==1)then
				adbos(72,2,4,64,-32,1,30*8,4,0)
			end
			if(tm>tt[1] and tm<tt[3])then
					adenmy(9,rnd(128),rnd(32)+10,1,30*3,0,11)
			end
			if(tm==tt[2])then
			 	adenmy(10,32,64,1,30*5,0,1)
			 	adenmy(10,128-32,64,1,30*5,0,1)
			end
			if(tm==tt[4])then
					adenmy(12,128-32,32,1,30*7,0,12)
					adenmy(12,32,32,1,30*7,0,12)
					adenmy(12,128-32,128-32,1,30*7,0,12)
					adenmy(12,32,128-32,1,30*7,0,12)
			end
				if(tm==tt[5])then
					adenmy(10,32,32,1,30*7,0,1)
			 	adenmy(10,128-32,32,1,30*7,0,1)
					adenmy(12,128-32,128-32,1,30*7,0,12)
					adenmy(12,32,128-32,1,30*7,0,12)
			end
			if(tm==tt[6])then
					adenmy(11,32,32,1,30*7,0,13)
			 	adenmy(11,128-32,32,1,30*7,0,13)
					adenmy(11,128-32,128-32,1,30*7,0,13)
					adenmy(11,32,128-32,1,30*7,0,13)
					adenmy(11,64,64,1,30*7,0,12)
			end
			if(tm==tt[7])then
				adenmy(11,64,64,1,30*9,0,13)
			end
				if(tm>tt[8] and tm<tt[9])then
					adenmy(9,rnd(128),rnd(32)+10,1,30*3,0,11)
			end
				if(tm==tt[11])then
				 --minibos
				 	adbos(74,2,2,64,-16,1,30*30,5,5)
				end
				if(tm==tt[12])then
				 altpals()
			end
			if(tm==tt[13])then
				adenmy(11,128-32,32,1,30*15,0,13)
				adenmy(11,32,32,1,30*15,0,13)
			end
			if(tm%40==0 and tm>tt[13] and tm<tt[14])then
				adenmy(12,rnd(128),rnd(32)+10,1,30*2,0,3)
				adenmy(10,rnd(128),rnd(32)+10,1,30*1,0,12)
			end
			if(tm==tt[14])then
				--knife
				--adbos(sp,w,h,x,y,s,t,p,bs)
				adbos(70,2,2,64,60,1,30*40,6,6)
			end
				if(tm%5==0 and tm>tt[16] and tm<tt[17])then
		--		adenmy(12,rnd(128),rnd(32)+10,1,30*2,0,3)
			  	adenmy(11,rnd(32),rnd(118)+10,1,30*3,0,11)
			  	adenmy(11,128-rnd(32),rnd(118)+10,1,30*3,0,11)
			end
			if(tm==tt[18])then
				rpal()
			 adenmy(10,32,32,1,30*7,0,3)
			 adenmy(10,128-32,32,1,30*7,0,3)
			end
			if(tm==tt[19])then
				adenmy(10,64,32,1,30*7,0,12)
			end
			if(tm==tt[20])then
				adenmy(11,32,64,1,30*7,0,1)
				adenmy(11,128-32,64,1,30*7,0,1)
			end
			if(tm==tt[21])then
			 altpals()
				--sqr boi
				adbos(101,2,2,64,-16,1,30*40,7,7)
			end
		if(tm==tt[22])then
				rpal()
				adbos(72,2,4,64,-16,1.2,30*80,8,8)
			end
			if(tm==tt[25])then
				lvctr=6
			end
		end,
		draw = function(self)
			tm=self.tmr
			tt=self.t
			if(tm>30*2 and tm<tt[1])then
			rectfill(32, 60, 95, 90, 1)
			print([[€‚ƒ„…†
‡ˆ‰Š‹Œ
‘’
“”•–—˜™]],37,64,8)
			end
			if(tm>tt[3] and tm<tt[4])then
	--for years the federal alliance	
			rectfill(32, 60, 110, 90, 1)
			print([[…‘ ˜„€‘’
“‡„ 
…„ƒ„‘€‹
€‹‹ˆ€‚„]],37,64,8)
			end
	if(tm>tt[9] and tm<tt[10])then
	--in their desire for
	--societal domination
			rectfill(29, 60, 110, 90, 1)
			print([[ˆ “‡„ˆ‘
ƒ„’ˆ‘„ …‘
’‚ˆ„“€‹
ƒŒˆ€“ˆ]],31,64,8)
			end
 	if(tm>tt[10] and tm<tt[11])then
			--have used violence 
			--and propaganda
			rectfill(29, 60, 110, 90, 1)
			print([[‡€•„ ”’„ƒ 
•ˆ‹„‚„
€ƒ
‘€†€ƒ€]],31,64,8)
			end
	if(tm>tt[12] and tm<tt[13])then
		--to eliminate all who
		--oppose them
			rectfill(19, 60, 110, 90, 1)
			print([[“ 
„‹ˆŒˆ€“„
€‹‹ –‡
’„ “‡„Œ]],22,64,8)
			end
			if(tm>tt[22] and tm<tt[23])then
   -- you will decide
   -- their fate
			rectfill(19, 60, 110, 90, 1)
			print([[˜”
–ˆ‹‹ ƒ„‚ˆƒ„
“‡„ˆ‘ …€“„]],22,64,8)
			end
				if(tm>tt[24] and tm<tt[25])then
  --your belief
  --will be truth
			rectfill(19, 60, 110, 90, 1)
			print([[˜”‘
„‹ˆ„… –ˆ‹‹
„ “‘”“‡]],22,64,8)
			end
		end
	})
end
-->8
function lvstrt()
	add(lvs,{
	 x=0,
	 y=0,
		a=false,
		p2=false,
		t=0,
		tmr=0,
		init = function(self)
			self.x=0
	  self.y=0
		 self.a=false
		 self.p2=false
		 self.t=0
		 self.tmr=0
	  music(22)
		end,
		update = function(self)
			self.tmr+=1
			if(btn())then
				self.a=true
			end
		end,
		draw = function(self)
		if(not self.a)then
			cls(9)
			for i=1,128,3 do
				for j=1,128,3 do			
					k=fract((i+timer/1000)*420.2)
					l=fract(j*320.3)	
					g=(k*(k+9.4))+(l*(l+9.4))	
					k+=g
					l+=g					
					f=fract(k*l)
					if(f<0.003)then
						pset(i,j,10)
					end
				end
			end
			
			pal(7,2)
		 n=232
		 w=7
		 h=1
			dx=4
			dy=16
			dz=2.25
		 scspr(n,w,h,dx,dy,dz)
		 	
		 pal(7,8)
			dx=5
			dy=15
		 scspr(n,w,h,dx,dy,dz)
		 	
		 pal(7,1)
		
		 n=248
		 w=4
			dx=49
			dy=31
			
		 scspr(n,w,h,dx,dy,dz)
		 
		 pal(7,12)
			dx=50
			dy=30
		 scspr(n,w,h,dx,dy,dz)
		 	
		 pal()
		 print("PRESS z TO START",
		 	33,80+sin(timer),7)
		 
		 spr(252,5,119)
		 print("I.S.G ZOZO",15,121)
		 end
			if(self.a)then
					music(-1)
					
					if(self.t==0)then
						sfx(35)
					end
					self.t+=1
				if(self.p2)then
		
					for i=0,50 do
					 print('',self.x-1,self.y,0)
				
					 self.x+=6
					 if(self.x>127)then
						 self.y-=5
						 self.x=0
					 end
					 if(self.y==0)then
					  blts={}
						 enmy={}
						 tls={} 
						 self.x=0
	      self.y=0
		     self.a=false
		     self.p2=false
		     self.t=0
					 	lvctr=2
					 	
					 end
				 end		
				else		

					for i=0,50 do
					 print('',self.x,self.y,0)	
					 self.x+=6
					 if(self.x>127)then
						 self.y+=5
						 self.x=0
					 end
				 end
				 if(self.y>128)then
						self.x=0
						self.p2=true
					end		
				end
		end
	end
	})
end
-->8
function lvgmovr()
	add(lvs,{
		tmr=0,
		init = function(self)
		 self.tmr=0
		 music(-1)
		 sfx(36)
		end,
		update = function(self)
			self.tmr+=1
			if(self.tmr == 30*3)then
					self.tmr=0
					plr.x=0
			 	plr.y=0
			 	plr.s=1--speed
			 	plr.ishit=false
			 	plr.ifrm=30
			 	plr.hp=1
			 	plr.e=false
			 	plr.et=2--explosion timer
			 	plr.dt=30*2--death timer
					lvctr=1
			end
		end,
		draw=function(self)
			cls()
			print([[Œgame overŒ]],40,64,7)
		end
	})
end
-->8
function lvfarm()
	add(lvs,{
		tmr=0,
		t={30*7,30*13,30*27,30*43,
					30*63,30*70,30*93,30*104,
					30*128,30*133,30*148,30*163,
			 	30*178,30*189,30*200,30*205,
			  30*210,30*303,30*308,30*311,
			  30*315},
		init = function(self)
		 bltclr=7
		 self.tmr=0
		 bgtil(25)
	  music(12)
		end,
		update = function(self)
		s16=30*16
		s20=30*20
		if(self.tmr>30*317)then
			lvctr=4
		end
			self.tmr+=1
			tm=self.tmr
			tt=self.t
			if(tm==tt[1])then
			 loctmrs=-9
				for i=1,3 do
					loctmrs+=10
					adenmy(22,40+loctmrs,-5*loctmrs,1,30*(6.5+i),1,1)
					adenmy(22,128-(50+loctmrs),-5*loctmrs,1,30*(6.5+i),2,1)
				end
			end
			if(tm==tt[2])then
				adenmy(23,50,-8,2,s16,3,2)
				adenmy(23,128-50,-8,2,s16,4,2)
			end
			if(tm==tt[3])then
				adenmy(24,25,-8,1,s16,5,3)
				adenmy(24,128-25,-8,1,s16,5,3)
			end
			if(tm==tt[4])then
			 adenmy(24,64,-8,1,s16,5,3)
				adenmy(21,128-25,-8,1,s16,6,4)
			end
			if(tm==tt[6])then
				adbos(106,2,2,76,-5,1,s20,1,1)
			end
			if(tm==tt[8])then
				adbos(64,2,1,128-30,-20,1,s20,2,2)
				adbos(128,2,4,30,-20,1,s20,2,3)
			end
			if(tm==tt[10])then
		 	adenmy(21,65+10,-5,1,s16,7,5)
				adenmy(22,75+10,-5,1,s16,7,5)
				adenmy(23,65+10,-20,1,s16,7,5)
				adenmy(24,75+10,-20,1,s16,7,5)
			end
			if(tm==tt[11])then
	
				adenmy(23,65,-10,1.5,s16,5,7)
				adenmy(24,65,-2,1.5,s16,5,6)
			end
			if(tm==tt[12])then
				adenmy(21,-10,65,1,30*16.5,8,8)
				adenmy(22,-2,65,1,30*16.5,8,9)
			end
			if(tm==tt[13])then
				adbos(106,2,2,76,-6,1,s20,1,1)
				adenmy(23,128-50,-50,2,s16,3,10)
			end
			if(tm==tt[14])then
		  adenmy(22,70,-100,1,30*9.5,1,1)
			end
			if(tm==tt[16])then
				adbos(76,4,4,64,-8,1,30*100,3,4)
			end
		end,
		draw = function(self)
			tm=self.tmr
			tt=self.t
	
			if(tm<tt[1]and tm>30*2)then
			
			rectfill(20, 60, 105, 90, 0)
			print([[who the heck are ya?
yer with the feds, 
ain't ya!?
go on boys, git em!]],24,64,12)
			end
			if(tm>tt[5] and tm<tt[6])then
		--	sfx(49)
			rectfill(20, 60, 113, 95, 0)
			print([[well heck!!!, yall
couldn't hit the broad 
side of a barn!
show em how it's done
shelby!]],24,64,12)
			end
			if(tm>tt[7] and tm<tt[8])then
		--	sfx(49)
			rectfill(4, 60, 125, 93, 0)
			print([[dogonit shelbs, i
said show em how it's done,
not, miss every shot and run.
freg,haleigh,xxander, yer up!]],9,64,12)
			end
			
   if(tm>tt[9] and tm<tt[10])then
  -- sfx(49)
			rectfill(4, 60, 125, 93, 0)
			print([[shoot, they got
heat stroke! 
we need some back up!
git em git em git em!]],9,64,12)
			end
if(tm>tt[15] and tm<tt[16])then
		-- sfx(49)
			rectfill(4, 60, 125, 93, 0)
			print([[that's it!
if ya want somethin done
right, do it yer self. face
the wrath of rhettly!]],9,64,12)
			end
if(tm>tt[16] and tm<tt[17])then
		-- sfx(49)
			rectfill(20, 65, 100, 80, 0)
			print([[dagnabbit!!!
git off my farm!!!]],25,67,12)
			end
if(tm>tt[18] and tm<tt[19])then
		--	sfx(49)
			rectfill(20, 65, 100, 80, 0)
			print([[dagnabbit...
heat stroke]],40,67,12)
			end

if(tm>tt[20] and tm<tt[21])then
			music(-1)
			
			rectfill(15, 65, 121, 80, 0)
			print([[...ya know, i
don't feel so good either]],20,67,7)
			end
if(tm>tt[21])then
	plr.e=true
end
		end
	})
end
-->8
function adenmy(sp,x,y,s,t,p,bs)
	add(enmy,{
			sp=sp,--sprite
  	x=x,
  	y=y,
  	s=s,--speed
  	t=t,--time to live
  	it=t,
  	p=p,--ptrn num
  	bs=bs,--bullet spread
  	update=function(self)
  		speed=self.s
  	 self.t-=1
  	 tmr=self.t
  	 ex=self.x
  	 ey=self.y
  	 ptn=self.p
  	 blt=self.bs
  		if(tmr<0)then
  			del(enmy,self)
  		end
  		if(ptn==1 or ptn==2)then
  			if(tmr>30*5)then
  				self.y+=speed
  			else
  				if(ptn==1)then
  					self.x-=speed
  				else
  					self.x+=speed
  				end
  		 end
  	 end--end of ptrns 1 & 2
  	 if(ptn==3or ptn==4)then
  			if(tmr>=30*14)then
  				self.y+=speed
  			elseif(tmr>=30*7)then
  				if(ptn==3)then
  				 self.x+=cos((timer)%1)*2
  			  self.y+=sin((timer)%1)*2
  			 else
  			  self.x-=cos((timer)%1)*2
  			  self.y+=sin((timer)%1)*2
  			 end
  			elseif(tmr>=0)then
  				self.y-=speed
  			end
  	 end
  	 if(ptn==5)then
  	 	if(tmr>30*14)then
  	 		self.y+=speed
  	 	elseif(tmr<=30*5)then
  				self.y-=speed
  	 	end
  	 end
  	 if(ptn==6)then
  	 	self.x+=0.5
  	 	self.x%=128
  	  if(ey<4)then
  	 		self.y+=1
  	  end
  	 end
  	 if(ptn==7)then
  	 	if(tmr<30*4)then
  	 		self.y-=1
  	 	elseif(tmr>30*14)then
  	 		self.y+=1
  	 	else
  	 		self.x+=5*sin((timer*2)%1)+cos(((timer))%1)*1
  			 self.y+=sin((timer)%1)*2+cos(((timer))%1)*3
  	 	end
  	 end
  	 if(ptn==8)then
  	 	if(tmr>30*14)then
  	 		self.x+=speed
  	 	elseif(tmr<=30*5)then
  				self.x-=speed
  	 	end
  	 end
  	   if(ptn==9)then
	  	if(tmr>30*15)then
	  		self.y+=speed
	  	elseif(tmr<=30*15)then
	  		self.x+=(cos(timer)*cos(0.01*timer))*4
	  		self.y+=(sin(timer)*cos(1.4*timer))*4
	  	end
	  end
  	 
  	 if(blt==1 and tmr%35==0)then
  	  circb(ex,ey,tmr)
  	 end
  	 if(blt==2 and tmr%3==0)then
  	 	rndbct(ex,ey,2)
  	 end
  	 if(blt==3 and tmr%3==0)then
  	  t20=tmr*20
  	 	adblt(ex,ey,t20,1,bltclr)
  	 	adblt(ex,ey,-t20,1,bltclr)
  	 	adblt(ex,ey,90+t20,1,bltclr)
  	 	adblt(ex,ey,90-t20,1,bltclr)
  	 end
  	 if(blt==4)then
  	 sprl(ex,ey,{0,90,180,270},
  	0,2)
  	 	
  	
  	 end
  	  if(blt==5 and tmr%24==0)then
  	 	 circb(ex,ey,tmr)
  	  end
  	 if(blt==6 and tmr%60==0)then
  	 	for i = 0,128 do
  				adblt(i,ey,90,1,bltclr)
  			end
  	 end
  	 if(blt==7 and tmr%60==59)then
  	 	for i = 0,128 do
  				adblt(i,ey,270,1,bltclr)
  			end
  	 end
  	 if(blt==8 and tmr%60==0 and tmr<30*14)then
  	 	for i = 0,128 do
  				adblt(ex,i,0,1,bltclr)
  			end
  	 end
  	 if(blt==9 and tmr%60==30 and tmr<30*14)then
  	 	for i = 0,128 do
  				adblt(ex,i,180,1,bltclr)
  			end
  	 end
  	 if(blt==10)then
  	 	adblt(ex,ey,timer*400,1,bltclr)
  	 end
  	 if(blt==11 and tmr%10==0)then
 
  	 	adblt(ex,ey,ag(ex,ey),5,bltclr)
  	 end
  	 if(blt==12 and tmr%5==0)then
  	 	
  	 	
  	 	adblt(ex,ey,ag(ex,ey),1,bltclr)
  	 end
   if(blt==13)then
    if(tmr%3==0)then
   		sprl(ex,ey,{0,90,180,270},
  	0,1)
  	  end
  	 end
  	 if(blt==14)then
	 	 	if(tmr%15==0)then
	 	 			trk(ex,ey,1)
	 	 	end
  	 
  	 end
  	 if(blt==15)then
  	 	if(tmr%10==0)then
  	 			trk(ex,ey,2)
  	 	end
  	 
  	 end
  	 
  	 	if(blt==16 and tmr%40==0)then
  			 	for i = 1,360,40 do
  			  	lx=cos((i*d2t)%1)*cos((1.6*i*d2t)%1)*8
	  		   ly=sin((i*d2t)%1)*cos((1.6*i*d2t)%1)*8
  			  	adblt(ex+lx,ey+ly,i+timer*2,1,bltclr)
  			  	adblt(ex-lx,ey,i+timer*2,1,bltclr)
  			  end
  		 end
  	end,
  	draw=function(self)
  			
  			if(self.it-5<self.t or self.t<5)then
  				spr(49+(self.t%3),self.x-4,self.y-4)
  				else
  				spr(self.sp,self.x-4,self.y-4)
  	 	end
  	end
  	})
end
function adbos(sp,w,h,x,y,s,t,p,bs)
	add(enmy,{
		sp=sp,--sprite
		w=w,
		h=h,
 	x=x,
 	y=y,
 	s=s,--speed
 	t=t,--time to live
 	p=p,--ptrn num
 	bs=bs,--bullet spread
 	e=false, --explode
 	et=2,--explosion timer
 	update=function(self)
 		 speed=self.s
  	 self.t-=1
  	 tmr=self.t
  	 ex=self.x
  	 ey=self.y
  	 ptn=self.p
  	 blt=self.bs
  	if(tmr<0)then
  		del(enmy,self)
  	end
  	if(ptn==1)then
   	if(tmr<30*2)then
   		self.y+=2
  		elseif(ey<64)then
  			self.y+=speed
  		else
  			self.x+=sin((cos((timer)%1)*1)%1)*4
  		end
  	end
  	if(ptn==2)then
  		if(ey<20)then
  			self.y+=1
  		end
  		if(tmr<30*3)then
  			self.e=true
  		end
  	end
  	if(ptn==3)then
  	--rhettly
  		if(tmr>30*98)then
  			self.y+=1
  		elseif(tmr>30*85)then
 				self.x+=cos((timer)%1)*2
  			self.y+=sin((timer)%1)*2
  		elseif(tmr<30*50 and tmr>=30*25)then
  			self.x+=1
  			self.x%=128
  		elseif(tmr<30*25 and tmr>=30*4)then
 				self.y+=1
  			self.y%=128
  		elseif(tmr<30*4)then
  			self.e=true
 			end
  	end
  	if(ptn==4)then
  		if(tmr>30*5.5)then
  			self.y+=1
  		elseif(tmr<30*2.4)then
  			self.y-=1
  		end
  	end
  	--gmba
  	if(ptn==5)then
  		if(tmr>30*28.5)then
  			self.y+=1
  		elseif(tmr<=30*28.5 and tmr>30*2.4)then

  			self.x+=cos(timer)*2
  			self.y+=sin(timer)*2
  		elseif(tmr<30*2.4)then
  			self.y-=1
  		end
 
	 
  	end
  	--knife
  	 if(ptn==6 and tmr>30*2.4 and tmr<30*37)then
	  		c=cos(timer)
  			s=sin(timer*0.5)
  			self.x+=(c)*8
  			self.y+=(s)*2
  			elseif(tmr<30*2.4)then
  			self.y-=1
	  	end
	  if(ptn==7)then
	  	if(tmr>30*37.5)then
	  		self.y+=speed
	  	end
	  end
	  
	  if(ptn==8)then
	  	if(tmr>30*77.5)then
	  		self.y+=speed
	  	elseif(tmr<=30*77.5)then
	  		self.x+=(cos(timer)*cos(0.01*timer))*4
	  		self.y+=(sin(timer)*cos(1.4*timer))*4
	  	end
	  end
  	if(ptn==9)then
  		if(tmr>30*76.0)then
  			self.y+=1
  		else
  			self.x+=cos((rnd(360)*d2t)%1)*3
	  		self.y+=sin((rnd(360)*d2t)%1)*2
	  		self.x%=128
	  		self.y%=128
  		end
  	
  
  	end
  
  	if(blt==1)then
  		adblt(ex,ey,timer*400,1,bltclr)
  		if(tmr%35==0)then
  			circb(ex,ey,tmr)
  		end
  		if(tmr<30*8 and tmr%60==0)then
  			for i = 0,128 do
  				adblt(i,ey,90,1,bltclr)
  			end
  		elseif(tmr<30*15 and tmr%60==0)then
  		 for i = 0,128 do
  				adblt(i,ey,270,1,bltclr)
  			end
  		end
  	end
  	if(blt==2 and tmr%2==0)then
  	sprl(ex,ey,{1,90,180,270},
  	1,1)
  
  	end
  	if(blt==3 and tmr%2==0)then
  			sprl(ex,ey,{1,90,180,270},
  			-1,1)
  	end
  	if(blt==4)then
 		--rhettly
 		--time for txt box
 			if(tmr<30*95 and tmr>=30*75)then
  	 	rndbct(ex,ey,5)
 			elseif(tmr<30*75 and tmr>=30*70)then
 			 sprl(ex,ey,{1,45,90,135,
 			 180,270,315},
  	-1,1)
 
 			elseif(tmr<30*70 and tmr>=30*60)then
  			sprl(ex,ey,{90,180,270},
  			-1,1)
  	 	sprl(ex,ey,{90,180,270},
  	  1,1)
  		
  		elseif(tmr<30*60 and tmr>=30*50)then
  				if(tmr%60==0)then
  	 			for i = 0,128 do
  						adblt(i,ey,90,1,bltclr)
  					end
  	 		end
  	 		if(tmr%60==59)then
  	 			for i = 0,128 do
  						adblt(i,ey,270,1,bltclr)
  					end
  	 		end
  	 elseif(tmr<30*50 and tmr>=30*25)then
  	 
  	 		sprl(ex,ey,{90,270},
  	0,1)
  		sprl(ex,ey,{90,270},
  	0,2)
  	
  	 	rndbct(ex,ey,3)
 			elseif(tmr<30*25 and tmr>=30*4)then
 					sprl(ex,ey,{0,180},
  	0,1)
  	sprl(ex,ey,{0,180},
  	0,2)
 			
  	 	rndbct(ex,ey,3)
 			end
  	end
  	--gmba
  	if(blt==5 and tmr<30*28)then
  	
  	rndbct(ex,ey,2)
  		if(tmr%10==0)then
  			for i = 1,360,15 do
  				adblt(ex+cos((i*d2t)%1)*5,ey+sin((i*d2t)%1)*5,ag(ex,ey),2,bltclr)
  			end
  		end
  	
  	end
  	if(blt==6 and tmr<30*37)then
  		sprl(ex,ey,{0,90,180,270},
  	-1,1)
  	 
  			
  	end
  	if(blt==7 and tmr<=30*37)then
  
  		ang=0
  		if(tmr%10==0)then
  		knfpt(ex,ey,10)
    end
 	 end
 	 if(blt==8 )then
 	 	if(tmr%10==0 and tmr<=30*77 and tmr>30*40)then
  				knfpt(ex,ey,20)
    elseif(tmr<=30*40)then
    	if(tmr%10==0)then
  			 
  			 for i = 1,360,15 do
  				 adblt(ex+cos((i*d2t)%1)*5,ey+sin((i*d2t)%1)*5,ag(ex,ey),2,bltclr)
  			 end
  		 end
 	  end
 	  if(tmr<30*30)then
 	 		rndbct(ex,ey,2)
 	  end
 	 end
 	 if(blt==9 and tmr<30*35)then	
  		if(tmr>30*20)then
  		
  		sprl(ex,ey,{0,180,270},
  	20,1)
  	sprl(ex,ey,{0,180,270},
  	-20,1)
  	else
  		if(tmr%35==0 and tmr<30*10)then
  			circb(ex,ey,tmr)
  		end
  		if(tmr%40==0)then
  			trk(ex,ey,1)
  		end
  	end
 	 end
 	 
 	 if(blt==10 and tmr<30*38)then
 	 	sprl(ex,ey,{0,45,90,
 	 	180,225,270},
  	80,1)
  	 if(tmr<30*30 and tmr%30==0)then
  	 	for i = 1,360,15 do
  				adblt(ex+cos((i*d2t)%1)*5,ey+sin((i*d2t)%1)*5,ag(ex,ey),1,bltclr)
  			end
  	 end
 	 end
 	 if(blt==11 and tmr<30*75 )then
 	 	rndbct(ex,ey,4)
 	 	if(tmr<30*40)then
 	 	sprl(ex,ey,{0,
 	 	180,270},
  	80,1)
  	end
 	 end
 	 
 	end,
 	draw=function(self)
 	 sx=self.x
 	 sy=self.y
 		spr(self.sp,sx-(self.w*8)/2,sy-4-(self.h*8)/2,self.w,self.h)
 		if(self.e)then
 			--explode
 			self.et%=14
 			self.et+=2
 			ett=self.et+190
	   
 			if(ett%14==0)then
 				sfx(34)
 			end
 			spr(ett,sx-(self.w*8)/2,sy-4-(self.h*8)/2,2,2)
 			spr(ett,sx+8-(self.w*8)/2,sy+8-(self.h*8)/2,2,2)
 			spr(ett,sx+16-(self.w*8)/2,sy-(self.h*8)/2,2,2)
 		end
 	end
	})
end
-->8
function fract(x)
	return (x-flr(x))
end
function knfpt(ex,ey,skp)
	for i = 1,360,skp do
	 mplt=cos((1.6*i*d2t)%1)*8
	 id2=(i*d2t)%1
	 it2 =i+timer*2
  				lx=cos(id2)*mplt
	  		 ly=sin(id2)*mplt
  				adblt(ex+lx,ey+ly,it2,1,bltclr)
  				adblt(ex-lx,ey,it2,1,bltclr)
 		end
end
function bgtil(til)
 amt=8*2
 for i=-amt,128,amt do
		for j=0,128,amt do
			adtil(j,i,1,rnd(6)+til,2)
		end
 end
end

function rndbct(x,y,ct)
	for i=1,ct do
		adblt(x,y,rnd(360),1,bltclr)
	end
end

function circb(x,y,tim)
	for i = 1,360,15 do
 	adblt(x,y,(i+tim),1,bltclr)
 end
end

function scspr(n,w,h,dx,dy,dz)

 sspr(8*flr(n%16),
 	8*flr(n/16),8*w,
 	8*h,dx,dy,
 	8*w*dz,8*h*dz)
end


function sprl(x,y,angs,timedir,spd)
	for a in all(angs) do
			adblt(x,y,
			a+(timedir*timer*400),
			spd,bltclr)
	end
end
function altpals()
 pal({1,130,130,131,132,
			133,134,135,136,137,138,
			139,140,141,142,143})
end

function rpal()
 pal({1,2,3,4,5,6,7,8,9,10,
		11,12,13,14,15,16})
end
function trk(ex,ey,speed) 
  
  for i = 1,360,15 do
  		 adblt(ex+cos((i*d2t)%1)*5,ey+sin((i*d2t)%1)*5,ang,speed,bltclr,true)
  end
  	
end

function ag(ex,ey)
 return atan2(plr.x-ex,plr.y-ey)*360
end
-->8
function lvintro()
	add(lvs,{
	 tmr=0,
	 dsel=false,
	 cx=37,
	 cy=62,
	 t={30*6,30*12,30*18,30*24,
	 			30*30,30*36,30*42},
		init=function(self)
		 self.dsel=false
			self.tmr=0
			music(-1)
		end,
		update=function(self)
		px=self.cx
		py=self.cy
		if(self.tmr>30*48)then
			lvctr=3
		end
		if(self.tmr==self.t[2] and self.dsel==false)then
			if(btnp(ƒ))then
				self.cy+=6
				sfx(50)
			elseif(btnp(”))then
				self.cy-=6
				sfx(50)
			end
			if(py>74)then
				self.cy =56
			elseif(py<56)then
				self.cy=74
			end
			if(btnp() or btnp(—))then
			 
				if(py==56)then
					dfclt=1
				elseif(py==62)then
					dfclt=2
				elseif(py==68)then
					dfclt=3
				elseif(py==74)then
					dfclt=4
				end
				self.dsel=true
			end
		else
		 self.tmr+=1
		 tmr=self.tmr
		 tt=self.t
		end
			
		end,
		draw=function(self)
		cls()
		 if(tmr==tt[2] and self.dsel==false)then
				print("select dificulty",35,48,7)
				print("practice",45,56,7)
				print("normal",45,62,7)
				print("hard",45,68,7)
				print("good luck lol",45,74,7)
				print("‘",self.cx+sin(time()),self.cy,9)
				print("MOVE:‹”‘ƒ SLOW:z FAST:x",10,122,7)
				print("1px hit box:",10,110,7)
				if(flr(t())%2==0)then
				 spr(1,60,108)
				else
				 spr(3,60,108)
				end
			end
			if(tmr<tt[1])then
			--	rectfill(20, 60, 105, 90, 0)
				print([[there are many 
causes i would die for. 
there is not a single 
cause i would kill for.
     - mahatma gandhi]],24,64,7)

elseif(tmr>tt[1] and tmr<tt[2])then
			--	rectfill(20, 60, 105, 90, 0)
				print([[sometimes you 
have to pick the gun up 
to put the gun down.
        - malcom x]],24,64,7)
			end
if(tmr>tt[2])then
	spr(157,64,32,2,2)
end
if(tmr>tt[2] and tmr<tt[3])then
				print([[i didn't think
any allies made it out
of that last battle
uninjured.]],24,64,15)
			end
if(tmr>=tt[3] and tmr<tt[4])then
				print([[anyway, we need
medicinal plants from 
rhettly's farm, it's just
south of here.]],24,64,15)
			end
if(tmr>=tt[4] and tmr<tt[5])then
				print([[only problem,
he's a bit
paranoid as of late. 
thinks the government
is out to get him.]],24,64,15)
			end
if(tmr>=tt[5] and tmr<tt[6])then
				print([[he will
attack you on sight, 
but you can't attack back.
it wouldn't look good. in
fact, i'll take your arms
so you arn't tempted.]],24,64,15)
			end
if(tmr>=tt[6] and tmr<tt[7])then
				print([[just evade
his attacks until he gets
tired, take the plants,
then meet at the ocean.]],24,64,15)
			end
			if(tmr>=tt[7])then
print([[good luck ‡]],24,64,15)
			end
		end
	})
end
-->8
function lvt1()
	add(lvs,{
	 tmr=0,
	 t={30*7,30*12},
		init=function(self)
			self.tmr=0
			music(-1)
		end,
		update=function(self)
		if(self.tmr>30*14)then
			lvctr=5
		end
		
		 self.tmr+=1

		end,
		draw=function(self)
		cls()
		
if(self.tmr<self.t[1] and self.tmr>30*2)then
			--	rectfill(20, 60, 105, 90, 0)
				print([[oh rhettly,
they ain't with the feds.
they're resistance.]],24,64,7)
			end
if(self.tmr>self.t[1] and self.tmr<self.t[2])then
			--	rectfill(20, 60, 105, 90, 0)
				print([[we gotta go,
but i'll leave a
little somethin nice
for em, for when they
wake up.]],24,64,7)
			end

		end
	})
end
-->8
function lvt2()
	add(lvs,{
	 tmr=0,
	 t={30*2,30*7,30*13,30*18},
		init=function(self)
			self.tmr=0
			music(-1)
		end,
		update=function(self)
			self.tmr+=1
			if(self.tmr==self.t[4])then
				lvctr=7
			end
		end,
		draw=function(self)
		cls()
		tm=self.tmr
		tt=self.t
if(tm>tt[1] and tm<=tt[2])then
print([[keep fighting 
the good fight‰ 
		       -shelby]],24,64,7)
elseif(tm>tt[2] and tm<=tt[3])then
print([[you recived a
single shot pistol and
medicinal plants]],5,64,7)		
elseif(tm>tt[3])then
 print([[let's get to
the ocean]],40,64,8)  
end     
end
	})
end
-->8
function lvt3()
		add(lvs,{
	 tmr=0,
	 t={30*0,30*5,30*9,30*14,30*17,
	 30*22},
		init=function(self)
			self.tmr=0
			music(-1)
		end,
		update=function(self)
			self.tmr+=1
			if(self.tmr==self.t[4])then
			  sfx(34)
			
			end
		end,
		draw=function(self)
		cls()
		 tm=self.tmr
		 tt=self.t
			if(dfclt==1)then
				print([[practice
makes perfect!]],35,60,7)
	   if(tm>tt[2])then
	   	lvctr=1
	   end
			elseif(dfclt==2 or dfclt==3 )then
			 
			 if(tm<tt[2])then
			 	print([[well now what?
it's not like you 
have any weapons haha!]],20,66,15)
			 end
			 			 if(tm>=tt[2] and tm<tt[3])then
			 	print([[single shot
pistol drawn]],30,90,8)
			 end
			 		 if(tm>=tt[3] and tm<tt[4])then
			 	print([[whatever,
even if you kill me the
federal alliance won't
stop until the resistance
is destroyed.]],20,66,15)
			 end
			 if(tm>=tt[4] and tm<tt[5])then
					 	print([[bang!]],55,90,8)
			 	
			 end
			 if(tm<tt[4])then
			 		spr(224,32,40,8,2)
			 end
		if(tm>=tt[5] and tm<tt[6])then
				print([[you understand
nothing, you fool.]],55,90,8)
			 				print([[you understand
nothing, you fool.]],55,50,15)
			end
			if(tm>tt[6])then
			 lvctr=1
			end
			elseif(dfclt==4)then
			spr(72,60,30,2,4)
					 if(tm<tt[2])then
			 	print([[now you understand,
oh arbiter, your will
is the only truth.
it is absolute!]],20,66,8)
			 end
			  if(tm>tt[2])then
	   	lvctr=1
	   end
			end
		end
	})
end
-->8
function lvcity()
	add(lvs,{
	 tmr=0,
	 t={30*0,30*6,30*11,30*51,
	 30*56,30*75,30*95,30*115,
	 30*155,30*220,30*234,30*313,
	 30*318},
	 
		init=function(self)
			self.tmr=0
			music(50)
			bgtil(52)
			bltclr=7
			
		end,
		update=function(self)
		sixt = 30*16
		sevt=30*17
		fift=30*15
		s9=30*79
			self.tmr+=1
			tm=self.tmr
			tt=self.t
			if(tm==1)then
			 adbos(157,2,2,64,-16,1,30*7.5,4,0)
			elseif(tm==tt[2])then
			 adbos(152,2,2,64,-16,1,30*39.5,7,9)
			elseif(tm==tt[5])then
				adenmy(5,64,-8,1,sixt,5,15)
			elseif(tm==tt[6])then
				adenmy(6,2,9,1,fift,0,13)
		 	adenmy(6,128-2,9,1,fift,0,13)
				adenmy(6,128-2,128-2,1,fift,0,13)
				adenmy(6,2,128-2,1,fift,0,13)
			 adenmy(5,64,-8,1,sixt,5,14)
			 adenmy(7,64,-8,1,30*18,9,16)
		 elseif(tm==tt[7])then
		 	adenmy(8,64,-8,1,sevt,5,15)
		 	adenmy(8,64,-16,1,sevt,5,2)
			elseif(tm==tt[8])then
			 adbos(150,2,2,64,-16,1,30*40,7,10)
			elseif(tm==tt[9])then
				adbos(147,3,3,64,16,1,s9,8,1)
			elseif(tm>tt[9] and tm<tt[10] and tm%10==0)then
				adenmy(7,rnd(128),rnd(40)+10,1,30*1,0,12)
			end
			if(tm==tt[11])then
				adbos(154,3,3,64,-16,1,s9,9,11)
			elseif(tm==tt[12])then
			 adbos(157,2,2,64,-16,1,30*7.5,4,0)
			end
			if(tm==tt[12]+(30*7))then
			 lvctr=9
			end
		end,
		draw=function(self)
		 tm=self.tmr
		 tt=self.t
		 if(tm>tt[1] and tm<tt[2])then
		 rectfill(4, 60, 125, 93, 0)
			print([[you got the meds.
this will help the fe... ah
alliance! oh what the hell.
i used you resistance scum!]],9,64,15)
		 end
		 if(tm>tt[2] and tm<tt[3])then
		 rectfill(25, 60, 110, 90, 0)
			print([[federal alliance
a.i. protocol ac-12
....initalized]],30,64,8)
end
		 if(tm>tt[4] and tm<tt[5])then
		 rectfill(15, 60, 115, 90, 0)
			print([[by the way,
these are international
waters. that means 
no law!]],20,64,15)
end

 if(tm>tt[12] and tm<tt[13])then
		 rectfill(15, 60, 115, 85, 0)
			print([[i can't
belive you are still 
alive...]],20,64,15)
end
		end
	})
end
-->8
function lvfinal()
		add(lvs,{
	 tmr=0,
	 fbx=32,
	 fby=30,
	 dst=1,
	 t={30*3,30*12,30*35,30*50,
	 30*60,30*63,30*75,30*90,
	 30*140,30*170,30*173,30*190,
	 30*220,30*222,30*226},
		init=function(self)
			self.tmr=0
			self.fbx=32
	  self.fby=30
	  music(-1)
		end,
		update=function(self)
			
			self.tmr+=1/self.dst
			tm=self.tmr
		 tt=self.t
		 fx=self.fbx
		 fy=self.fby
		 xa=fx+32
		 ftm=flr(tm)
		 self.dst=(abs(fx-plr.x+32)+abs(fy-plr.y))/100
			if(tm<tt[1])then
			 self.fbx+=cos(timer)*3
		  self.fby+=sin(timer)*3
		 end
		 if(ftm==tt[1])then
		 music(38)
		 end
		 if((tm>=tt[1]) and tm<tt[2])then
		 ar1={0,90,180,270}
		 		sprl(xa,fy,ar1,
  	900,1)
  	sprl(xa,fy,ar1,
  	-900,1)
  			sprl(xa,fy,{90,270},
  	300,1)
  	sprl(xa,fy,{0,180},
  	-300,1)
		 end
		 if(tm>=tt[2] and tm<tt[3])then
		 	if(ftm%10==0)then
  	 			trk(xa,fy,1)
  	 end
		 	if(fx<32)then
		 	 self.fbx+=1
		 	end
		 	if(fx>32)then
		 	 self.fbx-=1
		 	end
		 	if(fy<40)then
		 	 self.fby+=1
		 	end
		 end
		 if(tm>=tt[3] and tm<tt[4])then
				if(ftm%40==0)then
  	 	trk(xa,fy,1)
  	 end
				if(ftm%10==0)then
  	 	circb(xa,fy,tm)
  	 end
  
		 end
		 if(tm>=tt[4] and tm<tt[5])then
				if(ftm%40==0)then
  	 	trk(xa,fy,2)
  	 end
				if(ftm%9==0)then
  	 	
  	 	circb(xa,fy,tm)
  	 end
  
		 end
		 if(tm>=tt[6] and tm<tt[7])then
		 	rndbct(fx+32,fy,8)
		 end
		 if(tm>=tt[7] and tm<tt[8])then
		  self.fbx+=cos((rnd(360)*d2t)%1)*3
  		self.fby+=sin((rnd(360)*d2t)%1)*2
  		self.fbx%=125
  		self.fby%=125
		 	if(ftm%15==0)then
		 	 knfpt(xa,fy,10)
		 	end
		 end
		 if(tm>=tt[8] and tm<tt[9])then
		  rd = (rnd(360)*d2t)%1
		  self.fbx+=cos(rd)*4
  		self.fby+=sin(rd)*2
  		self.fbx%=125
  		self.fby%=125
  			sprl(xa,fy,{90,180,270},
  	900,1)
  			adblt(xa,fy,ag(xa,fy),1,bltclr)
		 end
		 
		 if(tm>=tt[9] and tm<tt[10])then
		 	if(fx<32)then
		 	 self.fbx+=1
		 	end
		 	if(fx>32)then
		 	 self.fbx-=1
		 	end
		 	if(fy<40)then
		 	 self.fby+=1
		 	end
		 	if(fy>40)then
		 	 self.fby-=1
		 	end
		 	ar1={90,180,270}
		 sprl(xa,fy,ar1,
  	600,1)
  	sprl(xa,fy,ar1,
  -600,1)
		 end
			if(self.dst<0.6)then
				self.dst=0.6
			end
			if(tm>=tt[11] and tm<tt[12])then
			 if(ftm%5==0)then
  	 	circb(xa,fy,tm)
  	 end
			end
			if(tm>=tt[12] and tm<tt[13])then
				adblt(xa,fy,ag(xa,fy),3,bltclr)
				rndbct(xa,fy,3)
			end
			if(tm>=tt[15])then
				lvctr=8			
			end
		end,
		draw=function(self)
		cls()
		tm=self.tmr
		tt=self.t
		ftm=flr(tm)
		if(tm>0 and tm<tt[1])then
			print("let's finish this",30,64,15)
			if(ftm%(ftm-tt[1])==0)then
				spr(224,self.fbx,self.fby,8,2)
			else
		
			spr(157,xa-10,self.fby,2,2)
			end
			
			else
			spr(224,self.fbx,self.fby,8,2)
		end
		
			if(tm>tt[14] and tm<tt[15])then
			print([[dang, out of ammo...]],30,66,15)
		end
	
		end
	})
end
__gfx__
0000000000000000000000000000000000000000000000000001e000000000000000000000000000122222220012200000122000222222220000000000000000
0000000000000000000000000000000000000000001ee0000001e0000eeeeee01e01e01e00000000122992220129920001201200222222220000000000000000
0070070000018000000160000000000000000d0001eeee0001ee8ee0e28ee82e1ee282ee001220001729a222129aa92012000120222222220000000000000000
000770000018880000166600000000000000bbd001e28e0001ee2ee0082ee2801e01e01e012222001e7229920129920012090012222222220000000000000000
000770000188e8800166e6600000e000000b3bbd01e22e000001e00001eeee001e01e01e122992201ee729a200122000120a0012222222220000000000000000
0070070018888888166666660000000000bbbbbb01eeee000001e00001e88e000001e0001229a22017ee72220001200012000120222222220000000000000000
0000000000000000000000000000000000000000001ee0000001e00001e01e000001e00001222200127ee7220001200001201200222222220000000000000000
0000000000000000000000000000000000000000000000000001e0000000000000000000000000001227ee720012200000122000222222220000000000000000
000000005656656556566565565565650656656000000000002cc000001000000000000044544444445444444454444444544444445443b44454444400000000
00000000565665655622256556566565005065602cc02ccc002110002ca0000002c02c0044544444445444444454444444544444445433bb4445434400000000
00000000565555655222226555555565500000052cccccc00029a2c02c02c0002cccccc0445444444454444444543b4444544444445433b3444544b300000000
000000005656656552ddd265565655555650006502c11c002c2cc2c02c02ccc02caccacc4454444444543b44445333b444544444445443344445443300000000
000000005656656552222265565665655650006502cccc002cccccc02ccccc002cccacc04454444444533bb444333b3b44544444454444444454434400000000
000000005655556556566565565555655605500502c99c0002cccc002ccccc0002cccc00445444444453b3b4443333b344544444454444444454444400000000
00000000565665655655556555566555500665052cc9acc0002cc0000002ccc0002cc00044544444445433444453333444544444454444444454444400000000
000000005656656556566565565655650656650002cccc00002cc000000000000000000044544444445444444454334444544444445444444454444400000000
00000000999999999999999999a999a99a955599111111111111111100000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000
000000009a9999999a9999999aa9a9a999556559111111111111111100000000cc677ccccccccccccccccccccccccccccccccccc677ccccc0000000000000000
00000000994444499999a9999aa9a9a99556665511ccc11111ccc11100000000c67777ccccccccccccccccccccccccccc67ccccccccccccc0000000000000000
0000000094444444999999999aa9a9a9955555551c111c111c111c1100000000cccccccccccccccccccccccccccccccc67777ccccccccccc0000000000000000
000000009a4444499a99999999a9a9a995556659c11111ccc11111cc00000000ccccccccccccccccccccccccccccccc67777667ccccccccc0000000000000000
00000000999999a9999999a999a999a999556559111111111111111100000000cccccc67cccccccccccccccccccccccccccccccccccc77cc0000000000000000
00000000999a9999999a99999aa999a999955599111111111111111100000000cccc6777ccccccccccccccccccccccccccccccccccc6777c0000000000000000
0000000099999999999999999aa999a999999999111111111111111100000000cccccccccccccccccccccccccccccccccccccccccc6777770000000000000000
00000000000000000000000000555500111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000
0000000000000000000550000500005011111111111111111111111111c1111111111111111ccc11000000000000000000000000000000000000000000000000
00000000000000000050050050000005111111111111111111111111111111111111111111c1c111000000000000000000000000000000000000000000000000
0000000000055000050000505000000511111111111111111111111111111111111111111c111c11000000000000000000000000000000000000000000000000
000000000005500005000050500000051111111111111111111111111111111111111111c11111cc000000000000000000000000000000000000000000000000
000000000000000000500500500000051111111111111c1111111111111111111111111111111111000000000000000000000000000000000000000000000000
00000000000000000005500005000050111111111111c1c111111111111111111111111111111111000000000000000000000000000000000000000000000000
00000000000000000000000000555500111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000112222200000000000000000000000000000000000000000000000000000
0002ccc0002cc0000000000000000000000000000000000000000001200000000001220000122000000000000000000000000000000000000000000000000000
02cccac02ccac00000000000000000000000000000000000000000122200000000120000000012000777700000077770000000000000000000000022222cccc0
2ccccccccccccc00000000000000000000000000000000007766000120006770012000000000012076666770007666670000000000000000000002ccccccc000
2cc575cccc575c0000000000000000000000000000000000006667012066700001207660076701200076666700765670000000000000000222222ccccccc0000
02ccccc02cccccc000000000000000000000000000000000007666712766700012000766766000120076566677666670000000000000222cccccccccccc00000
0002cc00002c02c000000000000000000000000000000000007666612666700012000009960000120076656676656700000000000022ccccccccccccccc00000
000000000000000000000000000000000000000000000000000669a29a67000012000009a900001200765661266667000000000222cccccccccccccccccc0000
000000000000000000000000000000000000000000000000000766122667000012000009a900001200076612226670000222222ccccccccccccccccccccc0000
0000000000000000000000000000000000000000000000000000671226700000120000009900001200076122222670002ccccccccccccccccccccccccccc2c00
0000000000000000000000000000000000000000000000000000001220000000012000000000012000761222222267002cccccccccccccccccccccccccccccc0
000000000000000000000000000000000000000000000000000000012000000001200000000001200071229a29a2270002222222222222222222222222222220
000000000000000000000000000000000000000000000000000000011000000000120000000012000012222222222200000002cc111111111ccccccccc000000
00000000000000000000000000000000000000000000000000000000100000000001220001222000012257555557522000002ccccccccccccccccccc00000000
00000000000000000000000000000000000000000000000000000000100000000000012001200000122222222222222200002cccca9cccca9cccccccc0000000
00000000000000000000000000000000000000000000000000000000000000000000012212200000001220120122001200002ccccccc2ccccccccc0000000000
00000000000000000000000000000000000000001222200000001222000000000000012222200000000002ccc000000000002ccccc2cccccccccc00000000000
00000000000000000000000000000000000000001299122201222912000000000000012222200000002ccccccccc0000000002c5ccc2ccccc5cc000000000000
000000000000000000000000000000000000000012a999912299991200000000000012222200000002cccccccccccc00000002cc5ccccc555ccc000000002c00
00000000000000000000000000000000000000001299a9129129a9120000000000001222222000002cc111cccccccc000002cccc5575755ccccc02cccccccc00
000000000000000000000000000000000000000001299129991299120000000000001222220000002ccc9cccc1111c0000000002ccccccccccccccccccc00000
0000000000000000000000000000000000000000012912999a9129120000000000000122222000002cccaccccca9ccc000000002c2ccc2ccccccccccc0000000
0000000000000000000000000000000000000000012129a99999121200000000000001222200000002cccc575cccccc000000002cc222cccccccccccc0000000
000000000000000000000000000000000000000000129999a999912000000000000000122220000002ccc55555cccc000000002cccccccccccccccccc0000000
00000000000000000000000000000000000000000012999999999120000000000000012222000000002cc57575ccc000000000002ccccccccccccccc00000000
00000000000000000000000000000000000000000121299a99a912120000000000000122222000000002c2ccc2cc0000000000002ccccccccc2cccc000000000
0000000000000000000000000000000000000000012912999991291200000000000000012200000002cccc222ccccc00000000002cc22cccc2ccccc000000000
0000000000000000000000000000000000000000012991299912991200000000000000012220000002c02cccccc02c00000000002cccc2222cccc00000000000
0000000000000000000000000000000000000000129a99129129a91200000000000000001200000002c002cc02c02cc00000000002cccccccccc000000000000
00000000000000000000000000000000000000001299999122999912000000000000000012200000000002cc02c002c00000000000002cccc000000000000000
00000000000000000000000000000000000000001299122201222912000000000000000001200000000002cc02c0000000000000000000000000000000000000
00000000000000000000000000000000000000001222200000001222000000000000000000120000000002cc02c0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cc0000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002ccccccccc2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002c2000002c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002c2000002c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
022cc220022cc2200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2cccccc22cccccc20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2caccac22caccac20000000000000111110000111110000011110000000011110100000000000010011111100000000001111110000000000000000000000000
2cccccc22cccccc20000000000011eeeee1001eeeee110001eee10000001eee11e100000000001e11eeeeee1000000001eeeeee1000000088800800000000000
002cc200002cc20000000000001eeefeee1001eeefeee1001eee10000001eee11e110000000011e11eefffe1000000001efffee100888008f888f80000000000
002c20000002c2000000000001eefffeeee11eeeefffee1001eee100001eee101eee11111111eee11eefeee1000000001eeefee108fff888ffffff8000000000
0022cc2002cc22000000000001eefeeeeee11eeeeeefee101eefe100001efee101eeeeeeeeeeee101eeeeee1000000001eeeeee108fffffffff8fff800000000
02cccccccccccc20000000001eeeeeeeeee11eeeeeeeeee11effee1111eeffe101eeeeeeeeeeee101eeeeee1110000111eeeeee18ff8fff88ffffff800000000
0002c200002c2000000000001eeeeeeeeee11eeeeeeeeee11eeeeeeeeeeeeee101eeeeeffeeeee1001eeeeeeee1111eeeeeeee108fffff8ff8fcfff800000000
0002cc2222cc2000000000001eeeeeeeee1ee1eeeeeeeee10111ee8888ee111001eefeeeeeefee1000111111ee1111ee111111008ffcffff88fffff800000000
002cccccccccc200000000001efeeeeee1eeee1eeeeeefe10111ee8888ee1110001efee22eefe10000000001eeeeeeee100000008ffffffffffffff800000000
0002cc2222cc2000000000001efeeeeee111111eeeeeefe11eeeeeeeeeeeeee1001efe2882efe10011111111eee888ee111111118fffff88888ffff800000000
00002c2cc2c20000000000001efeeeee1eeeeee1eeeeefe11effee1111eeffe1001eee2882eee1001eeeeeeeee82228eeeeeeee18ffff8fffff8fff800000000
000002cccc200000000000001eeeeeee1efeeee1eeeeeee11eefe100001efee10001ee2882ee10001efeeefeeee828eeefeeefe18fffff88888ffff800000000
0000022cc2200000000000001efeeee11eeeeee11eeeefe101eee100001eee100001ee2882ee10001eee1ee1efee8eee1ee1eee18ffffffffffff88000000000
00002c2cc2c20000000000001efeee1eeee88eeee1eeefe11eee10000001eee100001ee22ee1000001e11e11efeeeeee11e11e1008ffff888fff800000000000
0002cc2cc2cc2000000000001eeeee1eee8888eee1eeeee11eee10000001eee100001eeeeee1000000101e1eeeeeeeeee1e10100008ff80008f8000000000000
002cccccccccc200000000001eeeee1eeee88eeee1eeeee111110000000011110000011111100000000001ee11111111ee100000000880000080000000000000
02cc2cccccc2ccc00000000001eeee10eeeeeeee01eeee100000000000000000000000000000000000001ee1000000001ee10000000000000000000000000000
02c2cc2cc2cc2cc00000000001eee1100eeeeee0011eee10000000000000000000000000000000000001eee1000000001eee1000000000000000000000000000
02c2ccccccccc2c000000000001e110000eeee000011e100000000000000000000000000000000000001ef110000000011fe1000000000000000000000000000
002c25775775c20000000000001ee10000000000001ee100000000000000000000000000000000000001fe100000000001ef1000000000000000000000000000
0002cccccccc2000000000000001e00000000000000e1000000000000000000000000000000000000011e10000000000001e1100000000000000000000000000
0002ccc22cccc000000000000001100000000000000110000000000000000000000000000000000001eee10000000000001eee10000000000000000000000000
00002c2cc2cc0000000000000000000000000000000000000000000000000000000000000000000001ee1000000000000001ee10000000000000000000000000
000002ccccc000000000000000000000000000000000000000000000000000000000000000000000001100000000000000001100000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000000009000090000000000000000000
00000000000000000000000000000000000000000000000000000000000000000009900009900000090990000990009000000000000090900000000000000000
00000000000000000000000000000000000000000000000000009909000000000009999999990000000999999999000000090000000000000000000000000000
0000000000000000000000000000000000000009000000000000999999000000000099aaa9999900000090000009990000000000000000000000000000000000
00000000000000000000000000000000000009990000000000099aaa999000000999aaaaaaa99000099900aaa009900009900000000000000000000000000000
00000000000000000000009990000000000099a9900000000099aaaaa99900000099aaaaaaa9900000900aaaaa00900000000000000000000000000000000000
00000009000000000000099a9900000000999aaa99000000009aaaaaaa990000009aaaaaaaaa90000090aaaaaaa090000000000aaa0000090000000000000000
0000009a90000000000009aaa90000000009aaaaa9900000009aaaaaaa900000009aaaaaaaaa90000000aaaaaaa00000000000aaaaa000000000000000000000
00000009000000000000099a9900000000099aaa99000000099aaaaaaa900000009aaaaaaaaa90000000aaaaaaa09000000000aaaaa000000000000000000000
00000000000000000000009990000000000099a9900000000099aaaaa99000000099aaaaaaa990000090aaaaaaa09000000000aaaa0000990000000000000000
00000000000000000000000000000000000009990000000000999aaa999000000999aaaaaaa9000009900aaaaa0900000900000aa00000000000000000000000
0000000000000000000000000000000000000009000000000009999999000000000999aaa9990000000990000009000000009000000000000000000000000000
00000000000000000000000000000000000000000000000000009990900000000009099999999000000909990999900000000000000000000000000000000000
00000000000000000000000000000000000000000000000000009000000000000000099090000000090009909000009009000000000000900000000000000000
00000000000000000000000000000000000000000000000000000000000000000000090000000000000009000000090009000900000009000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999000000000000000000000
00888800000000000000000000000000000000000000000000000000008888007777707777770777770777707777707777077770777700077777700000000000
08fff800000000088800800000000008880080000000000888008000008fff807770707777770777770777707777707777077770777700077777700000000000
08fff80000888008f888f80000888008f888f80000888008f888f800008fff807770707700770770000077007700000770077000077000077007700000000000
8ffff80008fff888ffffff8008fff888ffffff8008fff888ffffff80808ffff87777707777770770000077007777700770077770077000077777700000000000
8ffff80008fffffffffffff808fffffffffffff808fffffffff8fff8888ffff87700007777770770000077007777700770077770077000077777700000000000
8ff8f8888ff8fff8888ff8fffffffff88fffffff8ff8ffff88ff8ffffff8fff87700007700770770000077007700000770000770077000077007700000000000
8f8ffffffffff88cccc8ff8fffffff8ff8ffffffff8fff88cc8ff8ffffff8ff87700007700770777770777707700007777077770077000077777700000000000
8f88fffffff88ccccccc8fffffffffff88fffffff8fff8ccccc8fffffff88ff87700007700770777770777707700007777077770077000077777700000000000
8f8f8ffffff8ccccc888ffffffffffffffffffffffff8ccccc8fffffff8f8ff80000000000000000000000000000000000000000000000000000000000000000
8ff88fff8ff88ccc8fffffffffffff88888ffffffffff8ccc8ffffffff888ff80000000000000000000000000000000000777000000000000000000000000000
8ffffffff8fff888ff88fffffffff8fffff8ffffffffff8c8ffffffffffffff80000000000000000000000000000000007000700000000000000000000000000
8ffff888ff8ffffffff8ffffffffff88888ffff8fffffff8fffffff88ffffff80000000000000000000000000000000070770070000000000000000000000000
8ffff8008fffffffff8ff8888ffffffffffff8808ffffffffffff880888ffff87700000770700000000777000000000070700070000000000000000000000000
08fff80008ffff888fff800008ffff888fff800008ffff888fff8000008fff807700000700700000000070000000000070770070000000000000000000000000
08fff800008ff80008f80000008ff80008f80000008ff80008f80000008fff807007770070777077077070770077000007000700000000000000000000000000
00888800000880000080000000088000008000000008800000800000008888007000000770707077077070777070000000777000000000000000000000000000
__gff__
0004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010a0020150531500015000050001505308000080000a000150530a00001000010001505302000020000200015053050000800008000150530a0000a000010001505301000020000200015053150001505315000
010a00001c7551c705187551f7051c7551c70518755217051f7551f7051c755007051f755287051c7550e7051875524705157550e705187552870515755007051d755307051a755007051c755267051875510705
010a00001c7551c705187551f7051c7551c70518755217051f7551f7051c755007051f755287051c7550e7051875524705157550e705187552870515755007051d755307051a755007051c755267051875510705
010a000028735287352473528735287352473524735247352b73528735287352b7352873528735287352b73524735217352173524735247352173521735247352973526735267352873528735247352873524735
010a0000100401004010040100400c0400c0400c0400c04013040130401304013040100401004010040100400c0400c0400c0400c0400904009040090400904011040110400e0400e04010040100400c0400c040
010700003b570325702d5702b570285702457022570205701d5701c570195701457013570105700e5700a57008570075700357002570015700057000570005700057000570005700057000570005700057000570
010200003b1533b1533b1533b1533a15338153351533015330153301532f1532d1532915324153211531e15319153161530e15309153021533e100381033f1033f103061030c105111001a100231002d10038100
010c000021550185501c5501f5502350023552235502455021552185501c5501f550000001a5501d550215501f55023550265501d5502155200000285520000021552185001c500285521f550235501d50024550
010100000e440164400b4000440005400064000740007400064000640006400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
01100018100530000000000346331c0001c0001c6001005300003346330000300003100530000000000346331c0001c0001c6001005300003346331c0001c0001c0001c000000031c600000031c0001c0001c000
010c00000e4550e4550e4550e455114551145511455114550c4550c4550c4550c455184551845518455184550e4550e4550e4550e455074550745507455074551145513455114551345511455134551145513455
011000000e2371023713237182371c2371f2370e237132371a2371f2372123724237132371a237262372b2372d237322372b23726237212371a23715237102370920709207092070920709207092070920709207
010c00000e0700e0700e0000e070110701100011070110700c0700c0700c0000c070180701800018070180700e0700e0700e0000e070070700700007070070701107011070110001107013070130001307013070
010a00001f15523155261551f15523155261551f15523155261551f15523155261551f155231552615509105261551e15521155261551e15521155261551e15521155261551e15521155261551e1552115500100
010e0000210502103021010210501c10012400230502303023010124002305023000090002305012400176002605026030260100900026050174001c100090002505025030250100900025050124001760009000
010e0000250502503025010250501c10012400260502603026010124002605023000090002605012400176002a0502a0302a010090002a050174001c100090002805028030280100900028050124001760009000
010e00001f053120031f630120031f053150031f630150031f053120031f630120031f053150031f630150031f053120031f630120031f053150031f630150031f053120031f630000001f053000001f63000000
010e00001f053120031f600120031f053150031f600150031f053120031f600120031f053150031f600150031f053120031f600120031f053150031f600150031f053120031f600000001f053000001f60000000
010e0000210502103021010210501c10012400230502303023010124002305023000090002305012400176002605026030260100900026050174001c100090002505025030250100900025050124001760009000
010e0000250502503025010250503505112400260502603026010124002605023000350002605012400176002a0502a0302a010090002a050350001c100090002805028030280100900028050124001760009000
010e00202105021030210102105000000210001e0501e0301e0101e050000001e0001e0500000000000000002105021030210102105000000210001e0501e0301e0101e050000001e0001e050000000000000000
010e000025050250302501025050000002100021050210302101021050000001e0002105000000000000000025050250302501025050000002100021050210302101021050000001e00021050000000000000000
010e00002405024030240102405003000240002105021030210102105003000210002105003000030000300024050240302401024050030002400021050210302101021050030002100021050030000300003000
010e00002805028030280102805003000240002405024030240102405003000210002405003000030000300028050280302801028050030002400024050240302401024050030002100024050030000300003000
010e00002705027030270102705006000270002405024030240102405006000240002405006000060000600027050270302701027050060002700024050240302401024050060002400024050060000600006000
010e00002b0502b0302b0102b0500600027000270502703027010270500600024000270500600006000060002b0502b0302b0102b050060002700027050270302701027050060002400027050060000600006000
010a00001b4400f440164401b44013440164401b440164401b4401f4401b440274401b4401d440164401b4401f4401b440244401f4402744022440244401d4402b44024440274401d44022440244402744029440
010a0000150531500029633050001505308000296330a000150530a00029633010001505302000296330200015053050002963308000150530a00029633010001505301000296330200015053150001505315000
010a00001b1520f1521b1520f152131521315213152131521b1521b1521b15227152161521615216152161521f1521f1521f1521f152241522415224152241522b15224152271521d15222152241522715229152
010e00001c0531c6001c0001c0001c0531c0001c0001c6001c0531c6001c0001c0001c0531c0001c0001c6001c0531c6001c0001c0001c0531c0001c0001c6001c0531c6001c0001c0001c0531c0001c0001c600
010e000027050270502905029050290501d0501f0501f050300502e0502e050330503300035000240002400027050270502905029050290501d0501f0501f050300502e0502e05033050330002e0003300033000
010e00000f0500f0501105011050110500505005050050501805018050180501b0501b0503500024000240000f0500f0501105011050110500505005050050501805018050180501b0501b050350002400024000
010e00001c0531c6001c6331c0001c0531c0001c6331c6001c0531c6001c6331c0001c0531c0001c6331c6001c0531c6001c6331c0001c0531c0001c6331c6001c0531c6001c6331c0001c0531c0001c6331c600
010e000027355273552935529355293551d3551f3551f355303552e3552e355333553330535305243052430527355273552935529355293551d3551f3551f355303552e3552e35533355333052e3053330533305
000400001045314453194531d45320453214532245321453214530a45305453004530045302453054530b4530c4530f453174531d4531f45321453204530e4530a453124531645318453144530f4530545303453
000300003b050390503605033050310502c050250501f0501b05019050160501505012050110500f0500b050060500105006050030500805010050180501c050220502405026050280502d05034050370503b050
001000001f350273501b3501f350163501b35011350163500a3500f3500335007350003500035000350003500f3000c3000a3000a300053000330003300003000730005300033000030000300003000030000300
01160000185501855018550185501855018550185501855013550135501355013550135501355013550135501b5501b5501b5501b5501b5501b5501b5501b5501655016550165501655016550165501655016550
011600001c5501c5501c5501c5501c5501c5501c5501c55017550175501755017550175501755017550175501f5501f5501f5501f5501f5501f5501f5501f5501a5501a5501a5501a5501a5501a5501a5501a550
01160000182551825518255182551825518255182551825513255132551325513255132551325513255132551b2551b2551b2551b2551b2551b2551b2551b2551625516255162551625516255162551625516255
011600001845300403004030040318453004030040300403184530040300403004031845300403004030040318453004030040300403184530040300403004031845300403004030040318453004030040300403
011600001845300403184530040318453004031845300403184530040318453004031845300403184530040318453004031845300403184530040318453004031845300403184530040318453004031845300403
011600001845318453184531845318453184531845318453184531845318453184531845318453184531845318453184531845318453184531845318453184531845318453184531845318453184531845318453
01160000182551825518200182551825518200182551825513255132551325513200132551325513255132551b2551b2001b2551b2001b2551b2001b2551b2551625516255162551625516255162551725517255
011600001c2551c2551c2001c2551c2551c2001c2551c25517255172551725517200172551725517255172551f2551f2001f2551f2001f2551f2001f2551f2551a2551a2551a2551a2551a2551a2551b2551b255
0109000035620336202f6202b620286202562023620206201d6201962013620116200d6200a620086200662003620006200c6000a600076000360000600006000060000600006000060000600006000060000600
011600001065500000000001060034655000000000010655106550000010655000003465500000000000000010655000000000010600346550000000000106550000010655106550000034655000000000000000
001600003015000100001002715000100221502e15024150001000010000100001000f1500015007150031500010000100001001110016150051500a15003150001003a1001b1003a1003a15035150301502b150
011600003c4563a456304562e4562b45627456274562b45624456334562e456224562945629456274562e4562e4562745627456244561d4561d4562245622456134561f4561b4560f4561d456184561645618456
010500001655516555165553850500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000b00003a55500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
010c00001f05624056270562b0562e006300063a0063a0063a0063a0063a0063c0063a0063c0063f0063f0063f0063f0063f00600006000060000600006000060000600006000060000600006000060000600006
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 01 03 44
00 00 01 03 44
00 00 01 43 03
00 00 01 43 03
00 00 01 43 04
00 00 01 43 04
00 00 01 43 04
00 00 01 43 04
00 00 42 03 04
00 00 42 03 04
00 00 42 03 04
02 00 42 03 04
01 0a 0c 43 44
00 0a 0c 43 44
00 0a 42 0c 0b
00 0a 42 0c 0b
00 41 09 0c 0b
00 41 09 0c 0b
00 0a 09 0c 44
00 0a 09 0c 44
00 0a 09 0c 44
02 0a 09 0c 44
01 25 26 43 44
00 25 26 43 44
00 25 26 27 44
00 25 26 27 44
00 25 26 27 28
00 25 26 27 28
00 25 26 27 29
00 25 26 27 2a
00 2b 2c 2d 30
00 2b 2c 2e 30
00 2b 2c 2e 2f
00 2b 2c 2e 2f
00 2b 2c 2e 2f
00 2b 2c 2e 2f
00 2b 2c 2e 2f
02 2b 2c 2e 2f
01 00 1a 43 44
00 00 1a 43 44
00 1b 1a 43 44
00 1b 1a 43 44
00 1b 1a 19 44
00 1b 1a 19 44
00 1b 1a 19 44
00 1b 1a 19 44
00 1b 42 19 1c
00 1b 42 19 1c
00 1b 42 19 1c
02 1b 42 19 1c
01 1d 1e 43 44
00 1d 1e 43 44
00 20 1e 43 44
00 20 1e 43 44
00 20 1e 1f 44
00 20 1e 1f 44
00 20 21 1f 44
00 20 21 1f 44
00 20 21 1f 44
00 20 21 1f 44
00 20 42 1f 44
02 20 42 1f 44
03 25 26 27 44
00 41 42 43 44
