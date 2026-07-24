pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
--main
function _init()

	music(8)
	cartdata("friendlyfire")

	resetgame()
end


function _update60()

	--update stars
	for st in all(stars) do
		st.ys+=st.spd
		if st.ys > 148 then
			st.ys=-20
		end	
	end
	
	--main game
	if gamestate==1 then
	
		--gameover
		if lives<=0 then 
			explosioncooldown-=1
			
			if explosioncooldown==0 then
				explosioncooldown=20
				explosioncount+=1
				gmexplosion(randbi(0,128),randbi(0,128))
			end
			
			if explosioncount>10 then
				if explosioncount==11 then
					sfx(26)
				end
				explosioncount+=1
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
				gmexplosion(randbi(0,128),randbi(0,128))
			end
			if explosioncount==13 then
				music(10)
				gamestate=2
			end
		end
	
	
		--play song
		if enemieskilled==0 and playinitial==true then
			playinitial=false
			music(0)
			songtoplay=0
		end
		
		--move player
		if selectedship==0 then
			thrust=0.14
		end
		if selectedship==1 then
			thrust=0.06
		end
		if selectedship==2 then
			thrust=0.2
		end
		
		if btn(2) and vel>-1.2 then vel-=thrust end
		if btn(3) and vel<1.2 then vel+=thrust end
		
		y1+=vel
		y2-=vel
		vel*=fric
		
		if y1<0 then y1=0 vel=0 end
		if y1>120 then y1=120 vel=0 end
		if y2<0 then y2=0 vel=0 end
		if y2>120 then y2=120 vel=0 end
		
		
		--fire gun
		cooldown-=1
		if btn(4) and cooldown<0 then
			sfx(0)
			pshipfire(x2,y2,12,randbi(135,225))
			pshipfire2(x1,y1,8,randbi(135,225))
			pshipfire(x2,y2,12,randbi(135,225))
			pshipfire2(x1,y1,8,randbi(135,225))
			pshipfire(x2,y2,12,randbi(135,225))
			pshipfire2(x1,y1,8,randbi(135,225))
			pshipfire(x2,y2,12,randbi(135,225))
			pshipfire2(x1,y1,8,randbi(135,225))
			
			if selectedship==0 then
				cooldownmax=30
				addpbullet(x1+8,y1,		1.95,57,0)
				addpbullet(x1+8,y1+8,1.95,57,0)
				addpbullet(x2-8,y2,		1.95,57,1)
				addpbullet(x2-8,y2+8,1.95,57,1)
			end
			if selectedship==1 then
				cooldownmax=75
				addpbullet(x1+8,y1+4,1.8,57,0)
				addpbullet(x1+8,y1  ,1.8,57,2)			
				addpbullet(x1+8,y1+8,1.8,57,3)
				addpbullet(x2-8,y2+4,1.8,57,1)
				addpbullet(x2-8,y2,		1.8,57,		4)			
				addpbullet(x2-8,y2+8,1.8,57,5)			
			end
			if selectedship==2 then
				cooldownmax=27
				addpbullet(x1+8,y1+4,2.1,57,0)
				addpbullet(x2-8,y2+4,2.1,57,1)			
			end
			cooldown=cooldownmax
		end
		
		
		
		--spawn enemies
		if wavecount<=0 and waveintro==false and #simpleenemy==0 then
			wavereset-=1
			
			if wavereset<=0 then
				wavestart=120
				waveintro=true
				sfx(32)
			end
		end		
		
		spawncooldown-=1
		if spawncooldown<0 and waveintro==false and wavecount>0 then
			wavecount-=1
			sfx(14)
			enemyamount=randbi(1,flr((wave*0.35)+0.5))
			spawncooldown=130-flr((wave*0.4)+0.5)
		end
		
		if enemyamount>0 then
			addsimpleenemy(70,randbi(10,120),0.3,randbi(0,1),randbi(0,maxenemy-1))
		end
		enemyamount-=1
		
		
		--wave wall
		if wave>2 then
			wavewallcooldown-=4
		end
		if wavewallcooldown<0 and wavewallchance<=3 then
			wavewallchance=randbi(4,5)
		end
		
		if wavewallchance>3 and wavewallspawntime==180 then
			sfx(33)
			wavewallcooldown=280
		end	

		
		--change bg col
		bgreset-=1
		if bgreset==0 then
			bgcol=0
		end
		
		--collide with enemies
		for se in all(simpleenemy) do
			if dist(se.x,x1,se.y,y1)<6 then
				loselife(x1,y1,8)
				del(simpleenemy,se)
				enemykilled(false)
			end
			if dist(se.x,x2,se.y,y2)<6 then
				loselife(x2,y2,12)
				del(simpleenemy,se)
				enemykilled(false)
			end			
		end
		for pb in all(pbullets) do
			if dist(pb.x,x1,pb.y,y1)<6 and pb.life<40 then
				loselife(x1,y1,8)
				del(pbullets,pb)
			end
			if dist(pb.x,x2,pb.y,y2)<6 and pb.life<40 then
				loselife(x2,y2,12)
				del(pbullets,pb)
			end			
		end	
		
		--create particles
		wallstate=flr(rnd(2))
		
		if wallstate==0 then
			addwallparticles(24,flr(rnd(128)),flr(rnd(20)),8,rnd(1.5),flr(rnd(4)+1),0)
		end
		if wallstate==1 then
			addwallparticles(136,flr(rnd(128)),flr(rnd(20)),12,rnd(1.5),flr(rnd(4)+1),1)
		end
		
		--explosion
		for ex in all(explosion) do
			ex:update()
		end
			
		--bullets
		for pb in all(pbullets) do
			pb:update60()
		end
		for pb in all(pbulletfire) do
			pb:update()
		end
	
		--simple enemies
		for se in all(enemyfire) do
			se:update()
		end
		
		for se in all(simpleenemy) do
				se:update60()
		end
		
		--update wall particles
		for wp in all(wallparticles) do
			wp:update()
		end

	end

	--update gameover explosion
	for gm in all(gameoverexplosion) do
		gm:update()
	end	
	
end


function _draw()
	cls(bgcol)
	
	shake()

	--stars
	for st in all(stars) do
		pset(st.xs,st.ys,st.starcol)
	end
		
	if gamestate==2 then
		
		print("press —+Ž to reset",hcenter("press —+Ž to reset")+12,100,7)

		if btn(4) and btn(5) then
			resetgame()
			music(9)
			resetcooldown=240
			gamestate=0
			btncool=10
		end
				
		pal()
		sspr(72,32,40,18,60,15)
		
		print("score",hcenter("score")+14,35,7)
	 print(pad(""..score2..score1,7),hcenter(pad(""..score2..score1,7))+14,camy+41,7)
		print("highscore",hcenter("highscore")+14,camy+50)
	 print(pad(""..hscore2..hscore1,7),hcenter(pad(""..score2..score1,7))+14,camy+56,7)
		print("wave",hcenter("wave")+14,camy+66)
	 print(wave,hcenter(tostr(wave))+14,camy+72,7)
		print("max wave",hcenter("max wave")+14,camy+82)
	 print(maxwave,hcenter(tostr(maxwave))+14,camy+88,7)
	 
	 

	 if score2 > hscore2 then
			dset(0,score1)
			dset(1,score2)
			hscore1=score1
			hscore2=score2
		end
		if score2 == hscore2 then
			if score1 > hscore1 then
				dset(0,score1)
				dset(1,score2)
				hscore1=score1
				hscore2=score2
			end
		end
		if wave >= maxwave then
			dset(2,wave)
			maxwave=wave
		end
	end
	
	
	
	if gamestate==-1 then
		logocooldown-=1
		
		sspr(2,34,65,12,logox1,30)
		sspr(2,50,70,12,logox2,45)
		if logocooldown==120 then
			sfx(23)
		end
		if logocooldown<120 then
			if logox1<45 then
				logox1+=3
			end
		end
		if logocooldown==60 then
			sfx(23)
		end
		if logocooldown<60 then
			if logox2>49 then
				logox2-=3
			end
		end
		if logocooldown==0 then
			sfx(24)
		end
		if logocooldown<0 then
			print("—+Ž",68,85,7)
			
			if btn(4) and btn(5) then
				gamestate=0
				music(9)
				btncool=55
			end
		end
	end
	
	
	--menu
	if gamestate==0 then
		
		btncool-=1
	
		pal(5,0)
		palt(15,true)
		palt(0,false)
		
		if currentmenu==2 then
			
			if tipy<10 then tipy+=1end
		
			if selected==1 then
				planeposy=0
				selectedtext="all around\nship.not very\nspecial."			end
			if selected==2 then
				planeposy=90
				selectedtext="slower ship\nwith spread\nshot."
			end
			if selected==3 then
				planeposy=180
				selectedtext="faster ship\nwith a single\nbullet."
			end
			
			rectfill(-10,99,70,117,12)
			print(selectedtext,18,100,0)
			
			rectfill(78,0,113,130,12)
			sspr(32,8,8,8,80,45-planeposy,32,32)
			sspr(40,8,8,8,80,135-planeposy,32,32)
			sspr(48,8,8,8,80,225-planeposy,32,32)
		end 
		if currentmenu==1 then
			if tipy>0 then tipy-=1end
		end

		pal()
		palt()

		if btn(3) and btncool<0 then 
			selected+=1
			btncool=10
			sfx(17)
			end
		if btn(2) and btncool<0 then
		 selected-=1
		 btncool=10
		 sfx(18)
		end
		if btn(4) and btncool<0 then
			btncool=10
			lerppos=0
			sfx(16)
			if currentmenu==1 and showhelptext==false then 
				if selected==1 then
					gamestate=1
				end
				if selected==2 then
					currentmenu=2
				end				
				if selected==3 then
					showhelptext=true
				end
			end
			if currentmenu==2 then 
				if selected==1 then
					selectedship=0
					ship=1
				end
				if selected==2 then
					selectedship=1
					ship=17
				end
				if selected==3 then
					selectedship=2
					ship=18
				end
			end
		end		
		if btn(5) and btncool<0 then
			selected=1
			btncool=10
			lerppos=0
			sfx(15)
			currentmenu=1
			showhelptext=false
		end
		
		if selected==#menu[currentmenu]+1 then selected=1 end
		if selected==0 then selected=#menu[currentmenu] end
	
		if lerppos<5 then lerppos+=2 end
	
		if showhelptext==false then
			for i=1,#menu do
				for j=1,#menu[currentmenu] do
				
					pal()
					if j==selected then
						rectfill(13,39+(10*j),60,45+(10*j),12)
						print(menu[currentmenu][j],18+lerppos,40+(10*j),0)
					end
				
					pal()
					if j!=selected then
						print(menu[currentmenu][j],18,40+(10*j),7)
					end
					
				end
			end
		end
		
		if showhelptext==true then
			print(helptext,18,10,7)
		end
		
		print("Ž accept — back",20,120+tipy,7)
		
	end
	
	
	if gamestate==1 then
	
	
		--for wave wall
		if wavewallchance>3 then
		
			if wavewallspawntime%5==0 then
				sprite=26
			end
			
			if wavewallspawntime%5!=0 then
				sprite=25
			end
			
			
			if wavewallspawntime==180 then
				direc=randbi(0,1)
				basepos=randbi(0,1)
				
				if direc==0 then
					col=8
				end
				if direc==1 then
					col=12
				end
				if basepos==0 then
					pos=4
				end
				if basepos==1 then
					pos=64
				end
				
			end
			
			pal(7,col)	
			for i=0,8 do
				if direc==0 then
					spr(sprite,75,pos+(8*i),1.0,1.0,true)
				end
				if direc==1 then
					spr(sprite,75,pos+(8*i),1.0,1.0,false)
				end
			end
			pal()
			
			wavewallspawntime-=1
			
			if wavewallspawntime<0 then
					for i=0,8 do
						addpbullet(75,pos+(8*i),1.3,57,direc,1)
					end					
				sfx(34)
				wavewallspawntime=180
				wavewallcooldown=280
				wavewallchance=-1
			end
		
		end
	
	
	
		--for wave start
		if waveintro==true then
			wavex+=2
			startx-=2
			pal()
			sspr(5,64,40,8,wavex,40)
			sspr(1,74,60,12,startx,50)
			
			if startx<-40 then
				wavestart-=1
			
				if wavestart<=0 then
					wavex=-27
					startx=128
					nicey=-13
					wave+=1
					wavecount=5*wave
					wavereset=180
					waveintro=false
					
					if maxenemy<4 then
						maxenemy+=1
					end
				end
			end
		end
		
		--explosion
		for ex in all(explosion) do
			ex:draw()
		end
	
		--wall particles
		for wp in all(wallparticles) do
			wp:draw()
		end
		
		--player ships
		pal()
		map(0,0,0,0)
		spr(ship,x1,y1,1,1)
		pal(8,12,false)
		spr(ship,x2,y2,1,1,true)
		
		--bullets
		for pb in all(pbullets) do
			pb:draw()
		end
		for pb in all(pbulletfire) do
			pb:draw()
		end
		
		--simple enemies
		for se in all(enemyfire) do
			se:draw()
		end	
	
		for se in all(simpleenemy) do
			se:draw()
		end
			
		--info
		if lives>0 then
			pal()
			spr(19,camx+17,camy+5)
			print(lives,camx+23,camy+5,7)
			spr(24,camx+123,camy+5)
			print(wavecount,camx+130,camy+5,7)
		end
		
		print(pad(""..score2..score1,7),64,camy+5,7)
		if score1>9999 then
			score1-=9999
			score2+=1
		end
	end

	--draw gameover explosion
	for gm in all(gameoverexplosion) do
		gm:draw()
	end
	
end



-->8
--objects

function initobjects()
	pbullets={}
	stars={} --not set up here
	wallparticles={}
	simpleenemy={}
	shootingenemy={}
	explosion={}
	pbulletfire={}
	enemyfire={}
	gameoverexplosion={}
end


function addwallparticles(_x,_y,_life,_col,_spd,_startsize,_state)
	add(wallparticles,{
		x=_x,
		y=_y,
		life=_life,
		col=_col,
		spd=_spd,
		size=_startsize,
		state=_state,
		draw=function(self)
			pal()
			circfill(self.x,self.y,ceil(self.size),self.col)
		end,
		update=function(self)
		
			self.size-=0.3
			
			if self.size<0 then
				del(wallparticles,self)
			end

			if self.state==0 then
				self.x+=self.spd
			end
			if self.state==1 then
				self.x-=self.spd
			end
		
		end
	})
end

function addpbulletfire(_x,_y,_amount,_col,_size,_spd,_angle)
	add(pbulletfire,{
		x=_x,
		y=_y,
		amount=_amount,
		col=_col,
		size=_size,
		spd=_spd,
		angle=_angle,
		draw=function(self)
			pal()
			circfill(self.x,self.y,ceil(self.size),self.col)
		end,
		update=function(self)
		
			self.size-=0.1

			self.x+=cos(self.angle/360)*self.spd
			self.y+=sin(self.angle/360)*self.spd
			
			if self.size<0 then
				del(pbulletfire,self)
			end
		
		end

	})
end

function addenemyfire(_x,_y,_amount,_col,_size,_spd,_angle)
	add(enemyfire,{
		x=_x,
		y=_y,
		amount=_amount,
		col=_col,
		size=_size,
		spd=_spd,
		angle=_angle,
		draw=function(self)
			pal()
			circfill(self.x,self.y,ceil(self.size),self.col)
		end,
		update=function(self)
		
			self.size-=0.1

			self.x+=cos(self.	angle/360)*self.spd
			self.y+=sin(self.angle/360)*self.spd
			
			if self.size<0 then
				del(enemyfire,self)
			end
		
		end

	})
end

function addexplosion(_x,_y,_amount,_col,_size,_spd,_angle)
	add(explosion,{
		x=_x,
		y=_y,
		amount=_amount,
		col=_col,
		size=_size,
		spd=_spd,
		angle=_angle,
		draw=function(self)
			pal()
			circfill(self.x,self.y,ceil(self.size),self.col)
		end,
		update=function(self)
		
			self.size-=0.1

			self.x+=cos(self.angle)*self.spd
			self.y+=sin(self.angle)*self.spd
			
			if self.size<0 then
				del(explosion,self)
			end
		
		end

	})
end

function addgmexplosion(_x,_y,_amount,_col,_size,_spd,_angle)
	add(gameoverexplosion,{
		x=_x,
		y=_y,
		amount=_amount,
		col=_col,
		size=_size,
		spd=_spd,
		angle=_angle,
		draw=function(self)
			pal()
			circfill(self.x,self.y,ceil(self.size),self.col)
		end,
		update=function(self)
		
			self.size-=0.1

			self.x+=cos(self.angle)*self.spd
			self.y+=sin(self.angle)*self.spd
			
			if self.size<0 then
				del(gameoverexplosion,self)
			end
		
		end

	})
end

function addpbullet(_x,_y,_bspd,_life,_state,_wall,_col)
	add(pbullets,{
		x=_x,
		y=_y,
		bspd=_bspd,
		life=_life,
		state=_state,
		wall=_wall,
		col=_col,
		bspr=2,
		keepchanges=false,
		draw=function(self)
		
			if self.col==nil and self.keepchanges==false then
				
				self.bspr=2
				if self.state==0 then
					self.col=8
				end
				if self.state==1 then
					self.col=12
				end
				self.keepchanges=true
			end
			if self.col!=nil and self.keepchanges==false then
				self.bspr=39
			end
		
			if self.state==0 then
				pal(8,self.col)
				spr(self.bspr,self.x,self.y-1,1,1)
			end
			
			if self.state==1 then
				pal(8,self.col)
				spr(self.bspr,self.x,self.y-1,1,1,true)
				pal()
			end
			
			if self.state==2 or self.state==3 then
				pal()
				spr(38,self.x,self.y-1,1,1)				
			end
			if self.state==4 or self.state==5 then
				pal(8,12)
				spr(38,self.x,self.y-1,1,1,true)
				pal()			
			end
			
			if self.state==2 then
				self.angle=15/360
			end
			if self.state==3 then
				self.angle=345/360
			end
			if self.state==4 then
				self.angle=165/360
			end
			if self.state==5 then
				self.angle=195/360
			end
		end,
		update60=function(self)
		
			if self.state==0 then 
				self.x+=self.bspd
			end
			if self.state==1 then 
				self.x-=self.bspd
			end
			
			if self.state>=2 then
				self.x+=movedirx(self.angle,self.bspd)
				self.y+=movediry(self.angle,self.bspd)
			end
			
			self.life -= 1
			
			if self.life<0 then
				del(pbullets,self)
			end
		end
	
	})
end





function addsimpleenemy(_x,_y,_spd,_state,_etype)
	add(simpleenemy,{
		x=_x,
		y=_y,
		espr=randbi(3,5),
		col=randbi(8,14),
		spd=_spd,
		state=_state,
		etype=_etype,
		hp=-10,
		colreset=10,
		counter=0,
		
		update60=function(self)

			if self.hp==-10 then
				self.basecol=self.col
				self.base=self.y
				
				if self.etype<4 then
					self.hp=1
				end
			end
			
			if self.etype==0 then
				addenemytrail(self.x,self.y,self.col,self.state)
				self.espr=3
				
				if self.state==0 then 
					self.x+=self.spd
					if self.x>126 then
						bgcol=7
						bgreset=3
						loselife(x2,y2,12)
						del(simpleenemy,self)
						enemykilled(false)
					end
				end
				
				if self.state==1 then
					self.x-=self.spd
					if self.x<23 then
						bgcol=7
						bgreset=3
						loselife(x1,y1,8)
						del(simpleenemy,self)					
						enemykilled(false)
					end
				end
			end
			
			
			
			if self.etype==2 then
				addenemytrail(self.x,self.y,self.col,self.state)
				self.espr=3
				self.spd=0.4
				
				if self.state==0 then 
					self.x+=self.spd
					if self.x>126 then
						bgcol=7
						bgreset=3
						loselife(x2,y2,12)
						del(simpleenemy,self)
						enemykilled(false)
					end
				end
				
				if self.state==1 then
					self.x-=self.spd
					if self.x<23 then
						bgcol=7
						bgreset=3
						loselife(x1,y1,8)
						del(simpleenemy,self)					
						enemykilled(false)
					end
				end			
			
				self.counter+=0.005
				self.espr=4
				self.mag=20
				self.y=self.base+(cos(self.counter)*self.mag)
			end
			
			
			
			if self.etype==1 then
				self.espr=9
				self.spd=0.4
				
				if self.state==0 then
					self.angle=atan2(x1 - self.x,y1 - self.y)
				end
				
				if self.state==1 then
					self.angle=atan2(x2 - self.x,y2 - self.y)				
				end
				
				self.x+=movedirx(self.angle,self.spd)
				self.y+=movediry(self.angle,self.spd)
			end
			
		
			
			if self.etype==3 then
				addenemytrail(self.x,self.y,self.col,self.state)
				self.espr=5
				self.spd=0.15
				
				if self.state==0 then 
					self.x+=self.spd
					if self.x>126 then
						bgcol=7
						bgreset=3
						loselife(x2,y2,12)
						del(simpleenemy,self)
						enemykilled(false)
					end
				end
				
				if self.state==1 then
					self.x-=self.spd
					if self.x<23 then
						bgcol=7
						bgreset=3
						loselife(x1,y1,8)
						del(simpleenemy,self)					
						enemykilled(false)
					end
				end
			end			
			
			
			
			for pb in all(pbullets) do
			
				if dist(self.x,pb.x,self.y,pb.y)<9 and pb.wall!=1 then
					if pb.wall!=1 then
						del(pbullets,pb)
					end	
					
					if self.etype!=3 then
						self.hp-=1
						offset=0.08
						sfx(31)
					end

					if self.etype==3 then
						if pb.state!=self.state then
							sfx(35)
						
							if self.state==0 and pb.state==1 then
								addpbullet(self.x		,self.y+2,1.7,57,self.state,1,self.basecol)
							end
							if self.state==1 and pb.state==0 then
								addpbullet(self.x-8,self.y+2,1.7,57,self.state,1,self.basecol)
							end
						end				
								
						if pb.state==self.state then
							self.hp-=1
							sfx(31)
						end
						
						offset=0.3
					end
				
					self.col=7
					self.colreset=5
				end
				
				if self.hp<1 then
					enemykilled(true)
					score1+=50
					sfx(randbi(1,3))
					del(simpleenemy,self)
					offset=0.2
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
					addexplosion(self.x,self.y,1,self.basecol,flr(rnd(6)),flr(rnd(3)),rnd(1)*360)
				end
				
			end
			
			self.colreset-=1
			
			if self.colreset<0 then
				self.col=self.basecol
			end
			
		end,
		
		draw=function(self)
			pal(1,self.col)
			if self.state==0 then
				spr(self.espr,self.x,self.y,1,1)
			end
			if self.state==1 then
				spr(self.espr,self.x,self.y,1,1,true)
			end
		end,
		
	})
end
-->8
--misc functions

function dist(_x1,_x2,_y1,_y2)
	distx = abs(_x1-_x2)
	disty = abs(_y1-_y2)
	
	m = max(distx,disty)
	distx = distx / m
	disty = disty / m
	
	return sqrt((disty*disty)+(distx*distx)) * m
	
end

function randbi(l,h) 
 return flr(rnd(h+1-l))+l
end

function pow(x,a)
 if (a==0) return 1
 if (a<0) x,a=1/x,-a
 local ret,a0,xn=1,flr(a),x
 a-=a0
 while a0>=1 do
   if (a0%2>=1) ret*=xn
   xn,a0=xn*xn,shr(a0,1)
 end
 while a>0 do
   while a<1 do x,a=sqrt(x),a+a end
   ret,a=ret*x,a-1
 end
 return ret
end

function shake(_amount,_speed)
	
	fade=0.95
	camx=rnd(32)-16
	camy=rnd(32)-16

	camx*=offset
	camy*=offset
	
	camera(16+camx,camy)
	
	offset*=fade
	
	if offset<0.05 then
		offset=0
	end
	
end

function pad(string,length)
  if (#string==length) return string
  return "0"..pad(string, length-1)
end

function loselife(_x,_y,_col)
	if lives>0 then lives-=1 end
	sfx(7)
	offset=0.6
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
	addexplosion(_x,_y,1,_col,flr(rnd(7)),flr(rnd(3)),rnd(1)*360)
end

function gmexplosion(_x,_y)
	col=randbi(0,1)
	if explosioncount<10 then
		sfx(25)
	end
	offset=1
	if col==0 then _col=8 end
	if col==1 then _col=12 end
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
	addgmexplosion(_x,_y,1,_col,flr(rnd(20)),flr(rnd(3)),rnd(1)*360)
end

function enemykilled(_killed)
		
	if _killed==true then	
		if enemieskilled%10==0 and enemieskilled!=0 and songtoplay<3 then
			songtoplay+=1
			music(songtoplay)
			playinitial=true
		end
		
		enemieskilled+=1
	end
	if _killed==false then 
		enemieskilled=0
	end
	if enemieskilled !=0 and killed==false then
		playinitial=true
	end
end

function pshipfire(_x,_y,_col,_dir)
		addpbulletfire(_x,_y,1,_col,flr(rnd(4)),flr(rnd(3)),_dir)
end

function pshipfire2(_x,_y,_col,_dir)
		state=randbi(0,1)
		
		if state==0 then
			addpbulletfire(_x,_y,1,_col,flr(rnd(4)),flr(rnd(3)),randbi(0,45))
		end
		if state==1 then
			addpbulletfire(_x,_y,1,_col,flr(rnd(4)),flr(rnd(3)),randbi(315,360))
		end
end

function addenemytrail(_x,_y,_col,_state)
	
	if _state==0 then
		angle=randbi(165,185)
	 diff=0
	end
	if _state==1 then
		chosenangle=randbi(0,1)
		if chosenangle==0 then
			angle=randbi(0,15)
		end
		if chosenangle==1 then
			angle=randbi(345,360)
		end
		diff=8
	end
	
	
	addenemyfire(_x+diff,_y+4,1,_col,rnd(2),rnd(3),angle)
	addenemyfire(_x+diff,_y+4,1,_col,rnd(2),rnd(3),angle)
	addenemyfire(_x+diff,_y+4,1,_col,rnd(2),rnd(3),angle)
	addenemyfire(_x+diff,_y+4,1,_col,rnd(2),rnd(3),angle)

end

function lerp(tar,pos,perc)
 return (1-perc)*tar + perc*pos
end

function hcenter(s)
 return 64-#s*2
end
 
function vcenter(s)
 return 61
end

function resetgame()
	
	--game state -1=logo 0=menu 1=game 2=gameover
	gamestate=-1

	--logo
	logox1=-61
	logox2=128
	logocooldown=121

	--menu
	showhelptext=false
	helptext="don't let enemies reach\nthe border.\nbullets cannot damage it,\nbut they can damage you.\nthat includes your own bullets.\ndon't die."
	start={"start","ships","help"}
	ships={"sparrow","pigeon","robin"}
	menu={start,ships}
	currentmenu=1
	selected=1
	btncool=30
	lerppos=0
	planeposy=0
	tipy=0
	selectedtext=0
		
	--gameover
	explosioncount=0
	explosioncooldown=40

	--init objects
	initobjects()

	--camera
	offset=0

	--waves
	maxenemy=0
	enemyamount=1
	wavereset=180
	wavestart=120
	wave=0
	wavecount=5
	spawncooldown=60
	waveintro=true
	wavex=-27
	startx=128
	nicey=-13

	--wave wall
	wavewallcooldown=280
	wavewallchance=0
	wavewallspawntime=180


	--player vars
	powerups={" ","shield","bomb","speed ”","fire ”","hp ”"}
	currentpu=1
	bgreset=0
	bgcol=0
	selectedship=0
	ship=1
	lives=10
	
	cooldown=30
	cooldownmax=30

	x1=26
	x2=126
	y1=60
	y2=60
	
	thrust=0.1
	vel=0
	fric=0.96
	
	--col
	partx=x1
	party=y1
	partcol=12	
	
	--score
	infomov=0
	score1=0
	score2=0
	hscore1=dget(0)
	hscore2=dget(1)
	maxwave=dget(2)
	songtoplay=0
	enemieskilled=0
	prevenemieskilled=0
	playinitial=true
	
	--init stars
	maxstars=75
	
	for i=1,maxstars do
		rndcol=flr(rnd(3)+1)
		
		if rndcol==1 then starcol=5 end
		if rndcol==2 then starcol=6 end
		if rndcol==3 then starcol=7 end
		
		add(stars,{
			xs=rnd(128),
			ys=rnd(128),
			spd=rndcol,
			starcol=starcol,			
		})
	end
	
end

function movedirx(_angle,_speed)
	return cos(_angle)*_speed
end

function movediry(_angle,_speed)
	return sin(_angle)*_speed
end
__gfx__
0000000088886660888000000110000011100000111110000011111101111100011100000060060000077000111111110002222211111000222880800c0cc111
0000000008888000088800001166660001110000011111000111666011166666111000000661166000777700111111112222000000001111222888800cccc111
007007000855000088800000055110000556660000566666055110005511100051666000661551660770077011111111022222221111111022228088cc0c1111
000770005558770000000000051771105555771105557710551177000551770055117700015775107700007711111111222220000001111122228008c00c1111
000770005558770000000000051771105555771105557710551177000551770055117700015775107700007711111111220222221111101120208008c00c0101
007007000855000000000000055110000556660000566666055110005511100051666000661551660770077011111111000200021000100020208888cccc0101
0000000008888000000000001166660001110000011111000111666011166666111000000661166000777700111111112222020210101111202000800c000101
0000000088886660000000000110000011100000111110000011111101111100011100000060060000077000111111110002000210001000222288800ccc1111
00000000088866608888888006060000fffffffffff55ffff5ffff5f01110000066600000000000000000000222222222202222211111011202288800ccc1101
000000008888800008888666867680005ffffff55ff55ff555ffff5511111000606060000077000000000000222222222202222211111011202288800ccc1101
000000000555500008550000885880005ff55ff55ff55ff555f55f551111100066666000077000000000000022222222000222221111100020028888cccc1001
0000000055888778555778008555800055f55f555555555555f55f551111100066666000777777770000000022222222220002221110001122088000000cc011
000000005588877855577800055500005555555555555555555555550111000006060000777777770000000022222222222222221111111122088888ccccc011
000000000555500008550000000000005555555555555555555555550000000000000000077000000000000022222222222200021000111100088000000cc000
000000008888800008888666000000005555555555555555555555550000000000000000007700000000000022222222220202021010101120228888cccc1101
000000000888666088888880000000005ff55ff5f5f55f5f5ff55ff500000000000000000000000000000000222222222202000210001011202288800ccc1101
1111111111110000111111111100000000001111111100000880000000000000000000000000000000000000000000002202222211111011020208800cc01010
0111111111111000111111111110000000011111111100008888000000888800000000000000000000000000000000002202222211111011020208800cc01010
5511111111111100011111111111000000111111116666668888000008888880000000000000000000000000000000002200002211000011020208800cc01010
55511111111111100011111111110000001111111166666608800000088888800000000000000000000000000000000022220222111011112222280000c11111
00000666666666000055566666666600005511111100000000000000088888800000000000000000000000000000000022200222111001110002280000c11000
00005555116666000055566666666600055511111100000000000000088888800000000000000000000000000000000022222000000111112202000000001011
0005555111177000055555557777000055555577771100000000000000888800000000000000000000000000000000000002202001011000220228800cc11011
00055551111777000555555777777000555555777771000000000000000000000000000000000000000000000000000022022000000110110002000000001000
0005555111177700055555577777700055555577777100000000000000000000000000000000000000000000000000002220200000010111222088800ccc0111
000555511117700005555555777700005555557777110000000000000000000000000000000000000000000000000000222022221111011122208000000c0111
000055551666660000555666666666000555111111000000000000000000000000000000000000000000000000000000000020000001000022208888cccc0111
000006666666660000555666666666000055111111000000000000000000000000000000000000000000000000000000202222221111110100008000000c0000
555111111111111000111111111100000011111111666666000000000000000000000000000000000000000000000000202200021000110122222888ccc11111
55111111111111000111111111110000001111111166666600000000000000000000000000000000000000000000000020000202101000012220200000010101
011111111111100011111111111000000001111111110000000000000000000000000000000000000000000000000000222200021000111122202888ccc10101
1111111111110000111111111100000000001111111100000000000000000000000000000000000000000000000000002222222211111111222088800ccc0101
00000000000000000000000000000000000000000000000000000000000000000000000088888888088888888088888888088888888000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000088888888088888888088888888088888888000000000000000000000
00888888808888880088888880888888808888888088888800888000008880888000000088000000088000088088088088088000000000000000000000000000
00888888808888880088888880888888808888888088888800888000008880888000000088000088088888888088088088088888888000000000000000000000
00888888808888880088888880888888808888888088888800888000008880888000000088000088088888888088088088088888888000000000000000000000
00888000008880888000888000888000008880888088808880888000008880888000000088000088088000088088088088088000000000000000000000000000
00888000008880888000888000888000008880888088808880888000008880888000000088888888088000088088088088088888888000000000000000000000
00888888808888888000888000888888808880888088808880888000008888888000000088888888088000088088088088088888888000000000000000000000
00888888808888888000888000888888808880888088808880888000008888888000000000000000000000000000000000000000000000000000000000000000
008888888088888880008880008888888088808880888088808880000088888880000000cccccccc0cc0000cc0cccccccc0cccccc00000000000000000000000
008880000088808880008880008880000088808880888088808880000000088880000000cccccccc0cc0000cc0cccccccc0cccccc00000000000000000000000
008880000088808880888888808888888088808880888888808888888088888880000000cc0000cc0cc0000cc0cc0000000cc0000cc000000000000000000000
008880000088808880888888808888888088808880888888808888888088888880000000cc0000cc0cc0000cc0cccccccc0cccccccc000000000000000000000
008880000088808880888888808888888088808880888888808888888088888880000000cc0000cc0cc0000cc0cccccccc0cccccccc000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000cc0000cc0cc0000cc0cc0000000cc0000cc000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000cccc000cccccccc0cc0000cc000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000cccc000cccccccc0cc0000cc000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccccccc0ccccccc0cccccc00ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccccccc0ccccccc0cccccc00ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccccccc0ccccccc0cccccc00ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccc0000000ccc000ccc0ccc0ccc0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccccccc000ccc000ccccccc0ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccccccc000ccc000ccccccc0ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccccccc000ccc000ccccccc0ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccc0000000ccc000ccc0ccc0ccc0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccc0000000ccc000ccc0ccc0ccc0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccc00000ccccccc0ccc0ccc0ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccc00000ccccccc0ccc0ccc0ccccccc000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ccc00000ccccccc0ccc0ccc0ccccccc000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000880880880888888880880000880888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000880880880888888880880000880888888880000000007777777707777777707777777707777777707700000000000000000000000000000000000000000
00000880880880880000880880000880880000000000000007777777707777777707777777707777777707700000000000000000000000000000000000000000
00000880880880888888880880000880888888880000000007700007700007700007700000007700000007700000000000000000000000000000000000000000
00000880880880888888880880000880888888880000000007700007700007700007700000007777777707700000000000000000000000000000000000000000
00000880880880880000880880000880880000000000000007700007700007700007700000007777777707700000000000000000000000000000000000000000
00000888888880880000880008888000888888880000000007700007700007700007700000007700000000000000000000000000000000000000000000000000
00000888888880880000880008888000888888880000000007700007707777777707777777707777777707700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007700007707777777707777777707777777707700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc0cccccccc0ccccccc0cccccc000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc0cccccccc0ccccccc0cccccc000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cc0000000000cc0000cc000cc0cc0000cc0000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc0000cc0000ccccccc0cccccccc0000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc0000cc0000ccccccc0cccccccc0000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000cc0000cc0000cc000cc0cc0000cc0000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc0000cc0000cc000cc0cc0000cc0000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc0000cc0000cc000cc0cc0000cc0000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
1c1b0e00000000000000000000000000000f2d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c1b1e00000000000000000000000000003f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b3c1e00000000000000000000000000003f0b0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b2e00000000000000000000000000002f1d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c1b0e00000000000000000000000000001f0b2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1b3e00000000000000000000000000001f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b3e00000000000000000000000000000f3d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b3c2e00000000000000000000000000002f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b0e00000000000000000000000000002f1d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c0c0e00000000000000000000000000000f0b2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b0e00000000000000000000000000003f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1e00000000000000000000000000003f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c2c1e00000000000000000000000000002f0d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b2e00000000000000000000000000001f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b0e00000000000000000000000000001f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c1b3e00000000000000000000000000000f0b3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b3e00000000000000000000000000002f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1c2e00000000000000000000000000002f1d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b0e00000000000000000000000000000f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c1b0e00000000000000000000000000003f0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000003f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000002f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01020000220501e0501805014050100500b0500605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000034652273522b6523435225652183421e6422a342186420d332136321f3320f632073320663212322046220a32202622073220162212322026220b322046221332207622103420c6721f3720000200002
00010000356432b64327653216531c6631a66317663166631b55315653285431563332523176233b2262a6163551628616305161d6162921608626185360a5561125600606006060060600606006060060600606
00010000386533165623653206561d653264462a4432d446146432244624443254460a6431c4461f4330a63612433134260062312426184200c6201a430224502845000600006000060000600006000060000600
011200000c043000003f20000003306150000300000000000c04300000000000c043306150000000000000000c043000000000000000306150000000000000000c043000000c04300000306150c0430000000000
011200000c043000003f2150000330615000033f215000000c043000003f2150c04330615000003f215000000c043000003f2150000030615000003f215000000c043000000c04300000306150c0433f21500000
011200000413504124021150253404125041140213502024041150413402125021140413504114021350211404135041240211502134041250411402135021240411504134021250211404135051140513502114
00020000353532b25331343212432b3331823324333142231b3230e21310313092130331318333202340000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000532313323052030532313323000030532310323000030532311323000030732300003183230000311323073230000311323073230000311323043230000311323053230000311323103231532300323
01120000105351053510535105051053510535105350050511535115351153500505135351353513535115351053510535105350050510535105351053500505135351353513535005051153511535115350c535
010d00000c02300004000000c023306250c02300000000000c023000000c0230c023306250c02300000000000c02300000000000c023306250c02300000000000c023000000c0230c023306250c0233062500000
010d0000104151041510415104051041510415104150040511415114151141500405134151341513415114151041510415104150040510415104151041500405134151341513415004051141511415114150c415
010d00000c7220c7220c7220c7220c7220c7220c7220c722107221072210722107221072210722107221072219722197221972219722197221972219722197221672216722167221672216722167221672216722
010d000019300193001932300400000001930019323001001930019300193230010019300193231932300100193231930019323001001930019300193230010019400194001932300100193231b4001932319400
010100001e75317753107530c7530975308753087530c75310753167531d753237532b753357533f7530000300003151030000300003000031510000000000000000000000161000000000000000001710000000
0003000038150341502c150251401f13017130111200a110031100011000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000300000a11011120161201d130251302a14030140371503a0600010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000100001503015030160301703017030190301b0301b0401d0401f05022050260602707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002c0502c0502b0502a040290402704025030220301f0201c02018010140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000326433164330643306432f6432f6432e6432d6332b6332b63329633276232562323623216231e6231c6231962315623126130d6130561302613006030060300603006030060300603006030060300603
0111000010015100151001510015100151001510015100150c0150c0150c0150c0150c0150c0150c0150c0150e0150e0150e0150e0150e0150e0150e0150e0151101511015110151101511015110151101511015
011100000c03300100000003f200306350000300000000000c033000000c0000c033306350000000000000000c033000000c03300000306350c03300000000000c033000000c0330c033306350c0330000000000
01110000104151041510415104051041510415104150040511415114151141500405134151341513415114151041510415104150040510415104151041500405134151341513415004051141511415114150c415
01020000276112b6212e6213063131631326313463135631366413764137641376413664136641356413363132631306312f6312c631296212762123621206111b611156110e6110561100011000010000100001
010100001e3451d3351b3351932518325163251432512315123151131510315103151031511315113151332515325173351d34525355393550030500305003050030500305003050030500305003050030500305
010300003c6103863035630346302f630266301e63017630146300a62009620066200462003620026100161000610006100060000600006000060000600006000060000600006000060000600006000060000600
00060000314502f67024450266701d4501e67014450156600d4500f660084500b660052500a660052500545007650052400464005240046500323003630022100162000210006200000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180000104151041510415104051041510415104150040511415114151141500405134151341513415114151041510415104150040510415104151041500405134151341513415004051141511415114150c415
011800000c1150c1150c1150c1150c1150c1150c1150c11510115101151011510115101151011510115101150e1150e1150e1150e1150e1150e1150e1150e1150c1150c1150c1150c1150c1150c1150c1150c115
011800000c02300004000000c023306250c02300000000000c023000000c0230c023306250c02300000000000c02300000000000c023306250c02300000000000c023000000c0230c023306250c0233062500000
01010000235421a5420e5420654201542275422154219542005420050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
010700001033410334133341333411334113341733417334153341533415334153341533400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
0108000019326003061b3260030619326003061b3260030619326003061b3260030619326003061b3260030600306003060030600306003060030600306003060030600306003060030600306003060030600306
010200002a4272c4272d4272d4272d4272b4372943727437224371c427154270e41705407004070040701407104070b4070740702407004070040700407004070040700407004070040700407004070040700407
0101000015245152451524515245152451524514245142451324513245122451124511245102450f2450e2450c2450a2450824507245000050000500005000050000500005000050000500005000050000500005
000200002f15026350221501735018150113501f150153502d7500030000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0005000010251103511145111251153511545117251173511845118251183511845118251382013720136201352013420133201302012e2012b2012820125201212011b20115201102010b201002010020100201
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
03 06 42 43 44
03 06 04 43 44
03 06 04 08 44
03 06 04 08 09
03 41 42 0c 44
03 41 42 0c 0b
03 0a 0b 0c 44
03 0a 0b 0c 0d
03 14 42 16 44
03 14 15 16 44
03 1c 1d 1e 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
