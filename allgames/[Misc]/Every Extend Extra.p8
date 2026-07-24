pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
--every extend extra pico 8
--by noba

function _init()
	init_game()
	cls(2)
	cartdata("noba_everyextendextra_1")
end


function _update()
	
	if gamestate==0 then
	end
	
	if gamestate==1 then
		--move player if respawned
		if plyr.respawncooldown<0 and gameover==false then
			if(btn(0) and plyr.x>40)plyr.x-=plyr.spd 
			if(btn(1) and plyr.x<147)plyr.x+=plyr.spd
			if(btn(2) and plyr.y>40)plyr.y-=plyr.spd 
			if(btn(3) and plyr.y<147)plyr.y+=plyr.spd 
			
			if btn(0) or btn(1) or btn(2) or btn(3) then
				if plyr.charge==0 then
					addparticle(plyr.x,plyr.y,rnd(1),20,1,-0.02,3,-0.1,{9,10})
				end
			end
			
			--slow player
			if(btn(4))plyr.spd=0.5
			if(not btn(4))plyr.spd=1
			
			--explode player
			if plyr.respawncooldown<=0 then
				if btn(5) and btn(4) and plyr.explosion==false then
					plyr.charge+=1
					if(plyr.charge==1)sfx(9)
					if(plyr.playsound==true)sfx(10)
					plyr.playsound=false
					
					if plyr.charge>120 then
						playerexplosion()
						plyr.charge=0
						plyr.playsound=true
					end
				else
					plyr.charge=0
					plyr.playsound=true
				end
				if btn(5) and not btn(4) and plyr.explosion==false then
					playerexplosion()
				end
			end
			
			--check for collision with pickups
			for i in all(pickup) do
				if dist(plyr.x+8,i.x+4,plyr.y+8,i.y+4)<16 then
					offset=0.1
					if i.state==0 then
						score:add(200)
						movingtext(plyr.x,plyr.y,30,11,"+200")
						explosioncircle(i.x+4,i.y+4,11,20,1)
						for i=0,3 do
							addparticle(plyr.x,plyr.y,rnd(1),randbi(10,30),randbi(1,3),-0.01,randb(3,8),-0.4,{3,3,11,11})
						end
					elseif i.state==1 then
						if(quicken<8)quicken+=1
						addonscreentext("+1 quicken",14)
						explosioncircle(i.x+4,i.y+4,14,20,1)
						for i=0,3 do
							addparticle(plyr.x,plyr.y,rnd(1),randbi(10,30),randbi(1,3),-0.01,randb(3,8),-0.4,{2,2,14,14})
						end
					elseif i.state==2 then
					addonscreentext("+15 seconds",10)
						timeremaining+=900
						explosioncircle(i.x+4,i.y+4,10,20,1)
						for i=0,3 do
							addparticle(plyr.x,plyr.y,rnd(1),randbi(10,30),randbi(1,3),-0.01,randb(3,8),-0.4,{10,10,9,9})
						end
					end
					del(pickup,i)
					sfx(50)
				end
			end
		end
		
		--player frame
		--based on song tempo
		framechange-=tempo
		if(framechange<=0 and gameover==false)framechange=1 tempo=maxtempo plyr.frame+=1
		if(plyr.frame>2)plyr.frame=0
		
		--enemies
		enemycooldown-=1
		if enemycooldown<=0 and gameover==false then
			--0=1 green 2 whites
			--1=1 green 4 whites
			--2=5 whites
			--3=5 greens
			--4=1 pink 2 whites
			--5=3 pinks
			--6=1 yellow 2 whites
			--7=1 yellow 4 whites
	
			for i=0,ceil(quicken/3) do
		  local formationtype=flr(rnd(9))
		  local anglepos=rnd(1)
		  local addition=64
		  local spawnanglex=startposx+(randbi(-30,30))+(cos(anglepos)*addition)
		  local spawnangley=startposy+(randbi(-30,30))+(sin(anglepos)*addition)
		  local spawnangle=atan2(startposx - spawnanglex, startposy - spawnangley)
		  if formationtype==0 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,1)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,0)
				elseif formationtype==1 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,1)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos+0.02))*(addition+6),startposy+(sin(anglepos+0.02)*(addition+6)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.02))*(addition+6),startposy+(sin(anglepos-0.02)*(addition+6)),spawnangle,0)
				elseif formationtype==2 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos+0.02))*(addition+6),startposy+(sin(anglepos+0.02)*(addition+6)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.02))*(addition+6),startposy+(sin(anglepos-0.02)*(addition+6)),spawnangle,0)		
				elseif formationtype==3 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,1)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,1)
		   addenemybasic(startposx+(cos(anglepos+0.02))*(addition+6),startposy+(sin(anglepos+0.02)*(addition+6)),spawnangle,1)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,1)
		   addenemybasic(startposx+(cos(anglepos-0.02))*(addition+6),startposy+(sin(anglepos-0.02)*(addition+6)),spawnangle,1)				
				elseif formationtype==4 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,2)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,0)		
				elseif formationtype==5 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos+0.02))*(addition+6),startposy+(sin(anglepos+0.02)*(addition+6)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.02))*(addition+6),startposy+(sin(anglepos-0.02)*(addition+6)),spawnangle,0)		
				elseif formationtype==7 then
		   addenemybasic(startposx+(cos(anglepos))*addition,startposy+(sin(anglepos)*addition),spawnangle,3)
		   addenemybasic(startposx+(cos(anglepos+0.01))*(addition+3),startposy+(sin(anglepos+0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos+0.02))*(addition+6),startposy+(sin(anglepos+0.02)*(addition+6)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.01))*(addition+3),startposy+(sin(anglepos-0.01)*(addition+3)),spawnangle,0)
		   addenemybasic(startposx+(cos(anglepos-0.02))*(addition+6),startposy+(sin(anglepos-0.02)*(addition+6)),spawnangle,0)
		 	elseif formationtype==8 then
		 		addspecialenemy(randbi(50,138),randbi(50,138),flr(rnd(4)),32)
		 		sfx(43)
		 	end
			end
			enemycooldown=maxenemycooldown-(quicken*0.4)
		end
		
		if(gameover==false)update_objects()
		
		--extends
		if addextend==true then
			addextend=false
			sfx(51)
			extend=randbi(15,22)+ceil(quicken/1.5)+ceil(quicken/2)
			plyr.bombs+=1
			movingtext(plyr.x,plyr.y,30,9,"+extend")
		end
		
		
		
		--player hit
		plyr.invuncooldown-=1
		if(plyr.invuncooldown<=0)plyr.invun=false
		for i in all(enemybasic) do
			if dist(i.x,plyr.x,i.y,plyr.y)<7 and plyr.respawncooldown<0 and plyr.invun==false and gameover==false then
				playerdeath()
			end
		end
		for i in all(bullet) do
			if dist(i.x+2,plyr.x,i.y+2,plyr.y)<2 and plyr.respawncooldown<0 and plyr.invun==false and gameover==false then
				playerdeath()
				del(bullet,i)
			end
			
			if i.x<30 or i.x>158 or i.y<30 or i.y>158 then
				del(bullet,i)
			end
		end
		
		function playerdeath()
		
		if(timeremaining>7200 and timeremaining<9000)	timeremaining-=600 addonscreentext("-10 seconds",12)
		if(timeremaining>9000 and timeremaining<10800)	timeremaining-=1200 addonscreentext("-20 seconds",12)
		if(timeremaining>10800 and timeremaining<12600)	timeremaining-=2400 addonscreentext("-30 seconds",12)
			timeremaining-=600
			addonscreentext("-10 seconds",12)
			plyr.death=true
			
			if(timeremaining>12600)plyr.bombs-=2
			if(timeremaining<12600)plyr.bombs-=1
			plyr.respawncooldown=40
			quicken=0
			offset=0.1
			sfx(49)
			for i=0,quicken-1 do
				addpickup(plyr.x+randbi(-8,8),plyr.y+randbi(-8,8),1)
			end
			
			for i=0,20 do
				addparticle(plyr.x,plyr.y,rnd(1),randbi(30,80),randbi(1,3),-0.01,randb(2,5),-0.28,{8,9,9,9,10})
			end
			for i=0,5 do
				addparticle(plyr.x,plyr.y,rnd(1),randbi(30,80),randbi(1,3),-0.01,randb(2,5),-0.28,{11,11,11,3,3})
			end
			flash=4
			poke(0x5f43,15)
		end
		
		--gameover
		if (plyr.bombs<=0 or timeremaining<=0) and gameover==false and plyr.respawncooldown<=0 then
			gameover=true
			invuncooldown=-1
			freezecooldown-=1
			sfx(41)
			music(-1)
		end
		if(gameover==true)freezecooldown-=1
		if freezecooldown==0 then
			sfx(40)
			offset=0.3
			for i=0,40 do
				addparticle(plyr.x,plyr.y,rnd(1),randbi(30,50),randbi(2,5),-0.09,randb(18,21),-0.3,{3,3,3,11,11,11})
			end
				for i=0,40 do
				addparticle(plyr.x,plyr.y,rnd(1),randbi(10,50),randbi(2,5),-0.05,randb(15,18),-0.4,{10,10,10,9,9,9})
			end
			explosioncircle(plyr.x,plyr.y,11,100,1)
			explosioncircle(plyr.x,plyr.y,9,60,2)
			explosioncircle(plyr.x,plyr.y,10,60,3)
		end
		if freezecooldown==-120 then
			gamestate=2
		end
		
		--respawn player, works for both
		--death and manual explosions
		plyr.respawncooldown-=1	
		if (plyr.explosion==true or plyr.death==true) and plyr.respawncooldown<=0 then
			plyr.invun=true
			plyr.invuncooldown=40
			plyr.explosion=false
			plyr.death=false
			plyr.x=startposx
			plyr.y=startposy
			plyr.createbomb=true
			poke(0x5f43,0x4300)	
		end
		
		--kill offscreen enemies
		for i in all(enemybasic) do
			if(i.x>startposx+70)del(enemybasic,i)
			if(i.x<startposx-70)del(enemybasic,i)
			if(i.y>startposy+70)del(enemybasic,i)
			if(i.y<startposy-70)del(enemybasic,i)
		end
	end
	
	--sfx warning
	if timeremaining==300 then
		sfx(42,3)
		stopsound=true
	elseif(timeremaining>300 or timeremaining<=0) and stopsound==true then
		stopsound=false
		sfx(-1,3)
	end
 
	--stars
 for st in all(stars) do
  st.y+=st.sp
  if (st.y>=158) then
   st.y=30
   st.sp=rnd(3)+1
  end
 end
end


function _draw()

	if gamestate==4 then
		cls(0)
		readycooldown-=1
		print("ready?",hcenter("ready?"),64,7)
		
		if readycooldown<0 then
			readycooldown=120 
			music(-1)
			if(disablemusic==false)music(musicpoint)
			gamestate=1
		end
	end
	
	if gamestate==0 then
		cls(2)
		pal(3,141,1)
		if startfadeout==false then
			if(menu>=4)pixlimit=2000
			if(menu<4)pixlimit=3500
		else
			pixlimit=0
		end
		for i=0,pixlimit do
			local x		=flr(rnd(128))
			local y		=flr(rnd(128))
			pset(x,y,randbi(2,3))
		end
		
		if menu<5 then
			pal(15,0)
			sspr(0,69,72,59,3,3)
		end
		if startfadeout==false then
			sspr(82,34,40,40,-10,100,40,40,1,0)
			sspr(82,34,40,40,100,-10,40,40)
			sspr(82,34,40,40,100,100,40,40,1,1)
		end
		if(btnp(2) and selected>1)selected-=1 sfx(25)
		if(btnp(3) and selected<#menulist[menu])selected+=1 sfx(25)
				
		if(ang<0.37 and startfadeout==false)ang+=0.03
				
		if menu<4 then
			for i=1,#menulist+1 do
				local addition=70
				local xpos=145+cos(ang+(0.04*i))*addition
				local ypos=80+sin(ang+(0.04*i))*addition
				
				if i!=selected then
					printshadow(menulist[menu][i],xpos,ypos,7)
				else
					printshadow("‘"..menulist[menu][i],xpos-3,ypos,13)
				end 			
			end
		elseif menu==4 then
			printshadow("welcome to every extend extra\nyour goal is to detonate your\nship, causing chain reactions\nin enemies to gain points.\nuse — to detonate Ž to slow\nand hold both for a delayed\nexplosion. try not to die!\npress Ž to show a gui guide.",2,68,7)
		elseif menu==5 then
			sspr(56,11,5,7,7,6)
			printshadow("-these arrows are quickens.\ncollecting them will\nspeed up parts of\nthe game, making chains\neasier to get.",15,7,7)
			sspr(61,10,11,12,2,40)
			printshadow("-this is your max chain.\nbig chain = good.",15,42,7)
			sspr(68,1,12,12,1,55)
			printshadow("-this is your bomb count.\ngetting extends will\nincrease it. getting hit\nwill decrease it,\nas well as detonating\nmanually.",15,58,7)
			
			printshadow("the numbers at the left\nfrom the top are your time,\nscore, and chain count\nrequired for an extend.",15,98,7)
		elseif menu==6 then
			printshadow("original concept by\nq entertainemnt",5,7,7)
			printshadow("programming and sound effects\nby noba",5,20,7)
			printshadow("music by gruber",5,33,7)
			printshadow("fade out script by dw817",5,40,7)
			printshadow("ruairidx for help with\nvarious issues",5,47,7)
			printshadow("dianne i guess",5,60,7)
			printshadow("menu glitch effect by\nwhiteoutlabs.com",5,67,7)
			printshadow("thank you for playing!",5,80,7)
			printshadow("press — to go back",5,100,7)
		end
		
		if btnp(4) then
			sfx(26)
			ang=0
			if(menu==5)menu=1
			if(menu==4)menu=5
			if menu==2 then
				if(selected==1) disablemusic= not disablemusic
				if(selected==2) disableparticles= not disableparticles
				if(selected==3) showbg= not showbg
				if(selected==4) showcpu= not showcpu
			end
			if menu==3 then
				if(selected==1) tempo=0.24 musicpoint=0 enemyspr=11
				if(selected==2) tempo=0.24 musicpoint=6 enemyspr=28
				if(selected==3) tempo=0.21 musicpoint=31 enemyspr=29
				if(selected==4) tempo=0.24 musicpoint=23 enemyspr=30
				startfadeout=true
			end			
			if menu==1 then
				if(selected==1)menu=3 
				if(selected==2)menu=2
				if(selected==3)menu=4
				if(selected==4)menu=6
			end
			selected=1
		elseif btnp(5) then
			ang=0
			sfx(27)
			menu=1
			selected=1
		end		
		if(startfadeout==true)fadeout()
		
		if disablemusic==true then options[1]="enable\nmusic"
		else options[1]="disable\nmusic" end
		if disableparticles==true then options[2]="enable\nparticles"
		else options[2]="disable\nparticles" end
		if showbg==true then options[3]="disable\nbg"
		else options[3]="enable\nbg" end
		if showcpu==true then options[4]="disable cpu\nusage"
		else options[4]="enable cpu\n usage" end
		
	end


	if gamestate==1 then
		if(flash>0)flash-=1
		if(flash%2==0)cls()
		if(flash%2==1)cls(7)
			
		--backgrounds
		if showbg==true and stat(1)<0.5 then
			if enemyspr==11 then
				--stars
				for st in all(stars) do
			  pset(st.x, st.y, st.sc)
			 end
		 elseif enemyspr==28 then
		 	leftrightcooldown-=1
		 	circlebgcooldown-=1
				
				if leftrightcooldown<0 then
					addmovingcircle()
					addmovingcircle()
					addmovingcircle()
					leftrightcooldown=5
				end
				if circlebgcooldown<0 then
					add(circlebg,{
						spd=rnd(0.7)+0.2,
						rad=0,
					})
					circlebgcooldown=40
				end
				for i in all(circlebg) do
					if(i.rad<90)i.rad+=i.spd
					if(i.rad>=70)del(circlebg,i)
					
					circ(startposx,startposy,i.rad,1)
				end
		 elseif enemyspr==29 then
		 
		 	linecooldown-=1
		 	leftrightcooldown-=1
				
				if leftrightcooldown<0 then
					addmovingcircle()
					addmovingcircle()
					addmovingcircle()
					leftrightcooldown=5
				end
		 	if(linecooldown<0)linecooldown=10 addline() addline()
		 
		 	for i in all(lines) do
		 		i.linex1=i.x+(cos(i.ang)*i.siz)
		 		i.liney1=i.y+(sin(i.ang)*i.siz)
		 		i.linex2=i.x+(cos(i.ang+0.5)*i.siz)
		 		i.liney2=i.y+(sin(i.ang+0.5)*i.siz)
		 		
		 		if(i.siz>40)del(lines,i)
		 		
		 		i.siz+=i.sizinc
		 		i.ang+=i.anginc
		 		
		 		line(i.linex1,i.liney1,i.linex2,i.liney2,i.col)
		 	end
		 elseif enemyspr==30 then
		 	squarecooldown-=1
		 	
		 	if squarecooldown<=0 then
		 		for i=0,14 do
		 			addsquare()
		 		end
		 		for i=0,12 do
		 			addsquaresmall()
		 		end
		 		squarecooldown=40
		 	end
		 	for i in all(squaresmall) do
		 		spr(66,i.x,i.y)
		 		i.y+=4
		 		if(i.y>159)del(squaresmall,i)
		 	end
		 	for i in all(square) do
		 		sspr(0,32,16,16,i.x,i.y)
		 		i.y+=2
		 		if(i.y>159)del(square,i)
		 	end
		 end
	 end

		for i in all(circleleftright) do
			if(i.rad<10)i.rad+=i.inc
			i.x+=cos(i.ang)*i.spd
			i.y+=sin(i.ang)*i.spd
			
			i.lif-=1
			if(i.lif<0)del(circleleftright,i)
			
			if(i.st==0)circfill(i.x,i.y,i.rad,1)
			if(i.st==1)pset(i.x,i.y,7)
		end 
 	
 	if(showcpu==true)print(stat(1),60,35,7)
		
		screen_shake()
		
		--draw explosion circles
		for i in all(explosioncircles) do
			circ(i.x,i.y,i.rad,i.col)
			
			if i.rad<i.maxrad then
				i.rad+=i.inc
			elseif i.rad>=i.maxrad then
				del(explosioncircles,i)
			end
			pal()
		end
		
		--draw particles
		if disableparticles==false then
			for i in all(particles) do
				i.life-=1
				if(i.life<0)del(particles,i)
				
				i.x+=cos(i.angle)*i.spd
				i.y+=sin(i.angle)*i.spd
				
				i.spd+=i.sinc
				i.rad+=i.rinc
				
				if type(i.fade)=="table" then
					i.col=i.fade[flr(#i.fade*(i.life/i.origlife))+1]
				else
					i.col=i.fade
				end
				circfill(i.x,i.y,i.rad,i.col)
			end
		end
		
		--draw moving text
		for i in all(text) do
			print(i.texttoshow,i.x-(hcenter(i.texttoshow)/2),i.y,i.col)
			
			i.y-=0.5
			i.timeremaining-=1
			if(i.timeremaining<0)del(text,i)
		end
	
		--draw objects
		draw_objects()
	
		--player sprite		
		if plyr.respawncooldown<=0 and gameover==false then
			if plyr.charge==0 then
				if plyr.invun==false then
					sspr(8+(plyr.frame*16),0,16,16,plyr.x-8,plyr.y-8)
				elseif plyr.invun==true and gameover==false and plyr.invuncooldown%10==0 then
					sspr(8+(plyr.frame*16),0,16,16,plyr.x-8,plyr.y-8)
				end
			else
				if(plyr.charge%2==0)pal(3,15)
				if(plyr.charge%2==1)pal()
				if plyr.invun==false then
					sspr(40,0,16,16,plyr.x-8,plyr.y-8)
				elseif plyr.invun==true and plyr.invuncooldown%10==0 then
					sspr(40,0,16,16,plyr.x-8,plyr.y-8)
				end
				pal()
			end
		elseif gameover==true and plyr.respawncooldown<=0 and freezecooldown>0 then
			sspr(8+(plyr.frame*16),0,16,16,plyr.x-8,plyr.y-8)
		end
	
		--ui
		
		--time bar
		if(timeremaining>5400 and timeremaining<7200)extendscore=11 barcol=7
		if(timeremaining>7200 and timeremaining<9000)extendscore=21 barcol=7
		if(timeremaining>9000 and timeremaining<10800)extendscore=31 barcool=9
		if(timeremaining>10800 and timeremaining<12600)extendscore=37 barcol=8
		if(timeremaining>12600)																							extendscore=44 barcol=8
		
		rectfill(32,85-extendscore,38,85,barcol)
		
  if #onscreentext > 0 then
   print(onscreentext[1].text,0+onscreentext[1].xaddition,140,onscreentext[1].col)
      
   if onscreentext[1].movetext==true then
   	onscreentext[1].xaddition+=5
   end
      
   if onscreentext[1].xaddition>=30+hcenter(onscreentext[1].text) then
    onscreentext[1].movetext=false
   	onscreentext[1].movecooldown-=1
          
    if onscreentext[1].movecooldown<=0 then
     onscreentext[1].movetext=true
     onscreentext[1].xaddition+=1
    end
   end
      
   if onscreentext[1].xaddition>170 then
    del(onscreentext,onscreentext[1])
   end
  end
		
		pal()
		line(40,0,40,33,7)
		line(40,41,40,85,7)
		line(40,93,40,127,7)
		line(40,135,40,158,7)
		
		line(147,0,147,34,7)
		line(147,52,147,85,7)
		line(147,100,147,127,7)
		line(147,144,147,158,7)
		pal()
		
		--time
		timeremaining=mid(0,timeremaining,32000)
		timeremaining-=2
		local timeminutes=timeremaining/60
		local timeseconds=flr(timeminutes)%60
		print(flr(flr(timeminutes)/60)..":"..timeseconds,30,35)
		print(flr(flr(timeminutes)/60)..":"..timeseconds,30,35)
		
		--score
		print(score:text(),30,87)
			
		--next extend
		print(extend,39,129)
			
		--quicken count
		for i=0,7 do
			if i<4 then
				pal(7,5)
				sspr(56,10,5,8,135+(i*5),35)
			else
				sspr(56,10,5,8,139+((i-5)*5),43,5,8,true)
			end
		end
		for i=0,quicken-1 do
			if i<4 then
				pal(7,14)
				sspr(56,10,5,8,135+(i*5),35)
			else
				sspr(56,10,5,8,139+((i-5)*5),43,5,8,true)
			end
		end
		
		--max chain
		pal()
		sspr(61,10,11,12,136,87)
		print(maxchain,148,90)
		
		--stock
		sspr(68,1,12,12,136,130)
		print(plyr.bombs,148,133)
	end
	
	function speed_to_bpm(speed, notes_per_beat)
	    return 60 / (speed / (120 / notes_per_beat))
	end
	
	if gamestate==2 then
		fadeout()
	end
	if gamestate==3 then
		cls(0)
		print("gameover",hcenter("gameover"),40,7)
		
		print("final score",hcenter("final score"),60,7)
		print(score:text(),hcenter(score:text()),67,7)
		
		print("press —+Ž to restart",hcenter("press —+Ž to restart"),80,7)
		
		if btn(4) and btn(5) then
			init_game()
		end
	end
	
	if(gamestate!=1)glitch()
end
-->8

--objects


function init_objects()
	enemybasic={}
	enemyspecial={}
	explosion={}
	chainhandler={}
	pickup={}
	boss={}
	enemybomb={}
	bullet={}
end


function update_objects()
	for i in all(enemybasic) do
		i:update()
	end
	for i in all(enemybomb) do
		i:update()
	end
	for i in all(enemyspecial) do
		i:update()
	end
	for i in all(explosion) do
		i:update()
	end
	for i in all(chainhandler) do
		i:update()
	end
	for i in all(pickup) do
		i:update()
	end
	for i in all(boss) do
		i:update()
	end
	for i in all(bullet) do
		i:update()
	end
end

function draw_objects()
	for i in all(enemybasic) do
		i:draw()
	end
	for i in all(enemybomb) do
		i:draw()
	end
	for i in all(enemyspecial) do
		i:draw()
	end
	for i in all(explosion) do
		i:draw()
	end
	for i in all(chainhandler) do
		i:draw()
	end
	for i in all(pickup) do
		i:draw()
	end
	for i in all(boss) do
		i:draw()
	end
	bulletcolswap-=1
	if(bulletcolswap==-1)bulletcolswap=2
	if(bulletcolswap==1)pal(12,8) pal(8,12)
	if(bulletcolswap==0)pal(8,12) pal(12,8)
	for i in all(bullet) do
		i:draw()
	end
	pal()
end

--visual effect for enemy that
--creates new chain handler
function addenemybomb(_x,_y)
	add(enemybomb,{
		x=_x,
		y=_y,
		deathcooldown=120,
		col=10,
		playsound=true,
		update=function(self)
			if self.playsound==true then
				sfx(9)
				self.playsound=false
			end
		
			self.deathcooldown-=1
			
			if(self.deathcooldown%2 ==0)self.col=9
			if(self.deathcooldown%2 ==1)self.col=10
			
			if self.deathcooldown<=0 then
				offset=0.3
				addchainhandler(1,self.x,self.y)
				explosioncircle(self.x+4,self.y+4,8,60,5)
				explosioncircle(self.x+4,self.y+4,9,60,6)
				explosioncircle(self.x+4,self.y+4,10,60,7)
					
				for i=0,20 do
					addparticle(self.x+4,self.y+4,rnd(1),randbi(30,80),randbi(5,7),-0.01,randb(3,8),-0.28,{8,9,9,9,10})
				end
				
				sfx(48)
				del(enemybomb,self)
			end
			for i=0,2 do
				addparticle(self.x+4,self.y+4,rnd(1),randbi(30,80),randbi(1,3),-0.01,randb(2,5),-0.28,randbi(9,10))
			end
		end,
		draw=function(self)
			pal(7,self.col)
			pal(6,7)
			spr(13,self.x,self.y)
			pal()
			if self.deathcooldown<=0 then
				cls(7)
			end
		end
	})
end

--special enemies
function addspecialenemy(_x,_y,_state,_maxscale)
	add(enemyspecial,{
		x=_x,
		y=_y,
		cooldown=120,
		timer=_timer,
		scale=0,
		maxscale=_maxscale,
		state=_state,
		angle=0,
		addchain=0,
		id=-1,
		sinangle=0,
		reverseangle=false,
		update=function(self)
			
			if self.scale<self.maxscale then
				self.scale+=1
			else
				for i in all(chainhandler) do
					if i.id==self.id then
						i.chaincount+=1
						del(enemyspecial,self)
						sfx(17)
						movingtext(self.x+8,self.y+8,60,7,"+500")
						score:add(500)
						for i=0,5 do
							addparticle(self.x+8,self.y+8,rnd(1),randbi(30,80),randbi(1,3),-0.01,randb(7,9),-0.28,flr(rnd(16)))
						end
							addpickup(self.x,self.y,2)
					end
				end
			end
			
			self.cooldown-=1
			if self.state==0 then
				self.angle+=0.01
				if self.cooldown<=0 then
					self.cooldown=120
					addbullet(self.x,self.y,self.angle+0.25)
					addbullet(self.x,self.y,self.angle+0.23)
					addbullet(self.x,self.y,self.angle+0.27)
					addbullet(self.x,self.y,self.angle+0.625)
					addbullet(self.x,self.y,self.angle+0.605)
					addbullet(self.x,self.y,self.angle+0.645)
					addbullet(self.x,self.y,self.angle+0.875)
					addbullet(self.x,self.y,self.angle+0.855)
					addbullet(self.x,self.y,self.angle+0.895)
					sfx(16)
				end
			end
			if self.state==1 then
				self.angle+=0.01
				if self.cooldown<=0 then
					self.cooldown=120
					for i=0,10 do
						addbullet(self.x,self.y,0.1*i)
					end
					sfx(16)
				end
			end
			if self.state==2 then
				self.angle=returnangle(self.x,self.y,plyr.x,plyr.y)
				
				if self.cooldown<=0 then
					self.cooldown=55
					sfx(16)
					addbullet(self.x,self.y,self.angle-0.1)
					addbullet(self.x,self.y,self.angle+0.1)
					addbullet(self.x,self.y,self.angle)
				end
			end
			if self.state==3 then
				if self.reverseangle==false then
					self.angle+=0.01
					
					if(self.angle>=0.5)self.reverseangle=true
				else
					self.angle-=0.01
					if(self.angle<=0.3)self.reverseangle=false
				end
				
				self.y+=sin(self.sinangle)*0.3
				self.sinangle+=0.05
				self.cooldown-=1
				
				if self.cooldown<=0 then
					self.cooldown=100
					sfx(16)
					addbullet(self.x-8,self.y,0.73)
					addbullet(self.x-8,self.y,0.75)
					addbullet(self.x-8,self.y,0.77)					
					addbullet(self.x-8,self.y,0.71)					
					addbullet(self.x-8,self.y,0.79)					
				end
			end
		end,
		draw=function(self)
		if(self.state==0)rspr(88,16,16,16,self.angle,self.x+8,self.y+8,self.scale,self.scale)addparticle(self.x+8,self.y+8,rnd(1),20,1,-0.02,3,-0.1,11)
		if(self.state==1)rspr(72,16,16,16,self.angle,self.x+8,self.y+8,self.scale,self.scale) addparticle(self.x+8,self.y+8,rnd(1),20,1,-0.02,3,-0.1,1)
		if(self.state==2)rspr(32,16,16,16,self.angle,self.x+8,self.y+8,self.scale,self.scale) 	addparticle(self.x+8,self.y+8,rnd(1),20,1,-0.02,3,-0.1,13)
		if self.state==3 then
			addparticle(self.x,self.y,rnd(1),20,1,-0.02,3,-0.1,8)
			rspr(120,24,8,8,self.angle+0.5,self.x-4,self.y+12,16,16)
			rspr(120,16,8,8,-self.angle+0.5,self.x+4,self.y+12,16,16)
			rspr(104,16,16,16,0,self.x,self.y,self.scale,self.scale)
		end
	end
	})
end

function addbullet(_x,_y,_angle)
	add(bullet,{
		x=_x,
		y=_y,
		angle=_angle,
		spd=0.4,
		update=function(self)
			self.x+=cos(self.angle)*(self.spd+((quicken/10)/0.3))
			self.y+=sin(self.angle)*(self.spd+((quicken/10)/0.3))
		end,
		draw=function(self)
			spr(12,self.x+4,self.y+4)
		end
	})
end


--handles individual explosion
--chains
function addchainhandler(_state,_x,_y)
	add(chainhandler,{
		id=rnd(30000),
		state=_state,
		x=_x,
		y=_y,
		chaincount=0,
		checkcooldown=30,
		initialexplosion=true,
		update=function(self)
		
			--create the initial explosion
			if self.initialexplosion==true then
				
				if(self.state==0)addexplosion(plyr.x,plyr.y,self.id)
				if(self.state==1)addexplosion(self.x,self.y,self.id)
				self.initialexplosion=false
			end
			
			--when this reaches 0,
			--if no explosions with an identical
			--id are existing, destroy the
			--handler and display chain
			self.checkcooldown-=1
			
			if self.checkcooldown<=0 and #explosion == 0 then
    del(chainhandler,self)
    addonscreentext("chain "..self.chaincount,7)
    score:add(((self.chaincount*50)*(flr(self.chaincount/3)))+((extendscore*5)*(abs(self.chaincount-3))))
    if(self.chaincount>=extend)addextend=true
    if self.chaincount>maxchain then
    	maxchain=self.chaincount
    end
   end
		end,
		draw=function(self)
		
		end
	})
end

--explosions created by the handler
function addexplosion(_x,_y,_id)
	add(explosion,{
		myid=_id,
		mychaincount=0,
		col=flr(rnd(16)),
		x=_x,
		y=_y,
		rad=0,
		update=function(self)
			--increase radius and 
   --destroy explosion once at
   --max, passing chain count over
   --to the handler with an identical id's
   --chain count
			self.rad+=5
			if self.rad>30 then
				for i in all(chainhandler) do
					del(explosion,self)
					if i.id==self.myid then
						i.checkcooldown=40
					end
				end
			end
			
			--destroys enemies and adds to
			--personal chain count if inside
			--explosion radius,
			--creating another explosion
			for i in all(enemybasic) do
				if dist(self.x,i.x+4,self.y,i.y+4)<self.rad then
					addexplosion(i.x,i.y,self.myid)
					i.addchain=true
					i.id=self.myid
				end
			end
			for i in all(enemyspecial) do
				if dist(self.x,i.x+4,self.y,i.y+4)<self.rad and i.scale==i.maxscale then
					addexplosion(i.x,i.y,self.myid)
					i.addchain=true
					i.id=self.myid
				end
			end
		end,
		draw=function(self)
			circ(self.x,self.y,self.rad,self.col)
		end
	})
end


function addenemybasic(_x,_y,_angle,_state)
	add(enemybasic,{
		x=_x,
		y=_y,
		angle=_angle,
		state=_state,
		spd=0.5,
		addchain=true,
		id=-1,
		update=function(self)
			self.x+=cos(self.angle)*(self.spd+((quicken/10)*0.8))
			self.y+=sin(self.angle)*(self.spd+((quicken/10)*0.8))
			
			for i in all(chainhandler) do
				if i.id==self.id then
					i.chaincount+=1
					del(enemybasic,self)
					for i=0,2 do
						addparticle(self.x,self.y,rnd(1),randbi(30,80),randbi(1,3),-0.01,randb(2,5),-0.28,flr(rnd(16)))
					end
					
					if self.state==1 then
						addpickup(self.x,self.y,0)
					elseif self.state==2 then
						addpickup(self.x,self.y,1)
					elseif self.state==3 then
						addpickup(self.x,self.y,2)
						addenemybomb(self.x,self.y)
					end
				end
			end
		end,
		draw=function(self)
			--basic
			if self.state==0 then
				pal()
			--score pickup
			elseif self.state==1 then
				pal(6,3)
				pal(7,11)
			--quicken pickup
			elseif self.state==2 then
				pal(6,2)
				pal(7,14)
			--time pickup
			elseif self.state==3 then
				pal(6,9)
				pal(7,10)			
			end
			if(self.state!=3)spr(enemyspr,self.x,self.y)
			if(self.state==3)spr(27,self.x,self.y)
		end
	})
end

--add pickups
function addpickup(_x,_y,_state)
	add(pickup,{
		x=_x,
		y=_y,
		angle=rnd(1),
		spd=0.3,
		state=_state,
		update=function(self)
			self.x+=cos(self.angle)*self.spd
			self.y+=sin(self.angle)*self.spd
		end,
		draw=function(self)
			--basic pickup
			if self.state==0 then
				pal(6,3)
				pal(7,11)
			--quicken pickup
			elseif self.state==1 then
				pal(6,2)
				pal(7,14)
			--extra time pickup
			elseif self.state==2 then
				pal(6,9)
				pal(7,10)
			end
			spr(10,self.x,self.y)
			pal()
		end
	})
end
-->8
--misc

--random range int
function randbi(l,h)
 return flr(rnd(h+1-l))+l
end
--the same but not int
function randb(l,h)
 return rnd(h-l)+l
end

--distance
function dist(_x1,_x2,_y1,_y2)
 distx = abs(_x1-_x2)
 disty = abs(_y1-_y2)
 
 m = max(distx,disty)
 distx = distx / m
 disty = disty / m
 
 return sqrt((disty*disty)+(distx*distx)) * m
end

--angle
function returnangle(_startx,_starty,_endx,_endy)
	return atan2(_endx-_startx,_endy-_starty)
end

--hcenter
function hcenter(s)
	return 64-#s*2
end

--score
function pad(string,length)
  if (#string==length) return string
  return "0"..pad(string, length-1)
end

function newscore()
    local s = {u=0,k=0}
    s.add = function (this,p)
            this.u += p%10000
            this.k += flr(p/10000)
            while this.u>=10000 do
                this.u -= 10000
                this.k += 1
            end
            while this.u<0 do
                this.u += 10000
                this.k -= 1
            end
        end
    s.text = function (this)
            local vunit = this.u
            local kilo = ""..this.k
            if this.k<0 then
                kilo = "-"..(abs(this.k)-1)
                vunit = abs(((this.u)-10000))
            end
            local units = "000"..vunit

            return ""..kilo..sub(units, #units-3,#units)
        end
    return s
end

function newextendscore()
    local s = {u=0,k=0}
    s.addextend = function (this,p)
            this.u += p%10000
            this.k += flr(p/10000)
            while this.u>=10000 do
                this.u -= 10000
                this.k += 1
            end
            while this.u<0 do
                this.u += 10000
                this.k -= 1
            end
        end
    s.textextend = function (this)
            local vunit = this.u
            local kilo = ""..this.k
            if this.k<0 then
                kilo = "-"..(abs(this.k)-1)
                vunit = abs(((this.u)-10000))
            end
            local units = "000"..vunit

            return ""..kilo..sub(units, #units-3,#units)
        end
    return s
end
-->8
--effects

-------------
--x=starting x pos
--y=starting y pos
--angle=angle of particle
--life=life of particle
--spd=speed of particle
--sinc=increase/decrease
--of particle speed
--rad=radius of particle
--rinc=increase/decrease
--of particle radius
--col=colour of particle 
--can also use table
-------------


--for when the player explodes
function playerexplosion()

	--only create a single handler
	if plyr.createbomb==true then
		addchainhandler(0,0,0)
		plyr.createbomb=false
	end

	sfx(48)
	plyr.explosion=true
	plyr.bombs-=1
	plyr.respawncooldown=40
	explosioncircle(plyr.x,plyr.y,8,60,5)
	explosioncircle(plyr.x,plyr.y,9,60,6)
	explosioncircle(plyr.x,plyr.y,10,60,7)
	offset=0.2
		
	for i=0,20 do
		addparticle(plyr.x,plyr.y,rnd(1),randbi(30,80),randbi(2,5),-0.01,randb(3,8),-0.28,{8,9,9,9,10})
	end
end

--explosion circle effect
function explosioncircle(_x,_y,_col,_maxrad,_inc)
	add(explosioncircles,{
		x=_x,
		y=_y,
		col=_col,
		maxrad=_maxrad,
		inc=_inc,
		rad=0,
	})
end

--add particle information to table
--particles are handled in draw
--function
function addparticle(_x,_y,_angle,_life,_spd,_sinc,_rad,_rinc,_col)
	add(particles,{
		x=_x,
		y=_y,
		angle=_angle,
		life=_life,
		origlife=_life,
		spd=_spd,
		sinc=_sinc,
		rad=_rad,
		rinc=_rinc,
		col=0,
		fade=_col,
	})
end

--shake screen
function screen_shake()
 local fade = 0.95
 local offset_x=16-rnd(32)
 local offset_y=16-rnd(32)
 offset_x*=offset
 offset_y*=offset
 
 camera(30+offset_x,30+offset_y)
 offset*=fade
 if offset<0.05 then
  offset=0
 end
end

--moving text for score, chains
--etc
function movingtext(_x,_y,_time,_col,_text)
	add(text,{
		x=_x,
		y=_y,
		timeremaining=_time,
		col=_col,
		texttoshow=_text,
	})
end


function addonscreentext(_text,_colour)
	add(onscreentext,{
		xaddition=0,
		movecooldown=30,
		text=_text,
		col=_colour,
		movetext=true,
		movetime=false,
	})
end


-- draw a rotated, scaled
-- sprite at dy,dy with dw,dh
-- as dimensions
--     sx,sy,sw,sh - pos,dimensions
--     in spritesheet
--     a - angle
--     dx,dy,dw,dh - pos,dimensions
--     on screen
-- serious performance issues
-- with large values of dw,dh
function rspr(sx,sy,sw,sh,a,dx,dy,dw,dh)
    sx,sy,sw,sh,a,dx,dy,dw,dh=
        sx or 0, sy or 0,
        sw or 8, sh or 8,
        a or 0,
        dx or 0, dy or 0,
        dw or 8, dh or 8
   
    local s1,c1 = sin(a+0.125),cos(a+0.125)
    local half_dw,half_dh = dw/2,dh/2
    local x1,y1 = half_dw*c1,half_dh*s1
    local x2,y2 = half_dw*s1,half_dh*-c1
    local x3,y3 = half_dw*-c1,half_dh*-s1
    local x4,y4 = half_dw*-s1,half_dh*c1

    local dx1,dy1=(x4-x1)/dh,(y4-y1)/dh
    local dx2,dy2=(x3-x2)/dh,(y3-y2)/dh
       
    local dtxx,dtxy=(x1-x2)/dw,(y1-y2)/dw

    local dsx,dsy=sw/dw,sh/dw
    for y=0,dh-1 do
        local ssx,px,py=sx,dx+x2,dy+y2
        for x=0,dw-1 do
            local col=sget(ssx,sy)
            if (col ~= 0)    pset(px,py,col)
            px+=dtxx
            py+=dtxy
            ssx+=dsx
        end
        sy+=dsy
        x2+=dx2
        y2+=dy2
    end
end

function printshadow(_text,_x,_y,_col)
	print(_text,_x+1,_y+1,0)
	print(_text,_x,_y,_col)
end

function fadeout()
local fade,c,p={[0]=0,17,18,19,20,16,22,6,24,25,9,27,28,29,29,31,0,0,16,17,16,16,5,0,2,4,0,3,1,18,2,4}
  fading+=1
  if fading%fadespeed==1 then
    for i=0,15 do
      c=peek(24336+i)
      if (c>=128) c-=112
      p=fade[c]
      if (p>=16) p+=112
      pal(i,p,1)
    end
    if fading==7*fadespeed+1 then
      cls()
      pal()
      camera(0,0)
      sfx(-1,3)
      
      if(startfadeout==false)gamestate=3
      if(startfadeout==true)gamestate=4 startfadeout=false glit.width=158 glit.height=158
      fading=-1
    end
  end
end

function glitch()
    if g_on == true then -- on boolean is mangaged by the timer
        local t={7,2,5} -- create array of three colors
        local c=rnd(3) -- generate a random number between 1 and 3, we'll use this in a bit
        c=flr(c) -- make sure our random number is an integer and not a float
        for i=0, 5, 4 do -- the outer loop generates the vertical glitch dots
            local gl_height = rnd(glit.height)
            for h=0, 100, 2 do -- the inner loop creates longer horizontal lines
                pset(rnd(glit.width), gl_height, t[c]) -- write the random pixels to the screen and randomize the colors from the previously generated random number against out color array
            end
        end
    end
   
    -- animation timeline that turns the static on and off
    if glit.t>30 and glit.t < 50 then
        g_on=true
    elseif glit.t>70 and glit.t < 80 then
        g_on=true
    elseif glit.t>120 then
        glit.t = 0
       
    else 
        g_on=false
       
    end
    glit.t+=1
end

function addmovingcircle()
		add(circleleftright,{
			ang=rnd(1),
			spd=randb(2,5),
			inc=rnd(0.5),
			lif=70,
			rad=0,
			x=startposx,
			y=startposy,
			st=randbi(0,1)
		})
end

function addline()
	add(lines,{
		ang=rnd(1),
		anginc=rnd(0.02),
		x=startposx,
		y=startposy,
		siz=0,
		sizinc=randb(0.3,0.4),
		col=1,
		linex1=0,
		linex2=0,
		liney1=0,
		liney2=0
	})
end

function addsquare()
	add(square,{
		x=30+(flr(rnd(8))*16),
		y=30+(flr(rnd(8))*16)-128,
		life=40,
		size=randbi(0,1)
	})
end
function addsquaresmall()
	add(squaresmall,{
		x=30+(flr(rnd(8))*16),
		y=(flr(rnd(8))*16)-128,
		life=40,
		size=randbi(0,1)
	})
end
-->8
--init game
--big function, need space

function init_game()
	
	music(39)
	
	--init game state
	gamestate=0	

	--glitch by whiteoutlabs.com
 glit = {}
 glit.height=128 -- set the width of area the screen glitch will appear
 glit.width=128 -- set the width of area the screen glitch will appear
 glit.t=0 -- glitch timer start

	--reset/set camera
	camera(0,0)
	
	--options vars
	disablemusic=false
	showbg=true
	disableparticles=false
	showcpu=false
	
	
	--menu background variables
 
 --stars
 stars={}
 for i=1,125 do
 
  local tc=flr(rnd(4)+1)

  if (tc==1) then sc=1 end
  if (tc==2) then sc=5 end
  if (tc==3) then sc=13 end
  if (tc==4) then sc=6 end
  if (tc==5) then sc=7 end
  add(stars,{
   x=rnd(158),
   y=rnd(158),
   sp=tc,   		  
   sc=sc   		  
  })
	end
	
	--bubbles and circles
	circlebgcooldown=70
	leftrightcooldown=30
	circlebg={}
	circleleftright={}
	
	--lines
	lines={}
	linecooldown=40
	
	--squares
	square={}
	squaresmall={}
	squarecooldown=60
	
	
	--menu
	menu=1
	selected=1
	ang=0
	menucooldown=5
	pixlimit=3500
	startfadeout=false
	musicpoint=0
	readycooldown=120
	
	start={
		"start",
		"option",
		"help",
		"credit",
	}
	options={
		"disable\nmusic",
		"disable\nparticles",
		"disable\nbg",
		"show cpu\nusage",
	}
	song={
		"into the\nbelt",
		"like\nclockwork",
		"robot\ndance",
		"dimensional\ngate",
	}
	menulist={
		start,
		options,
		song,
		blank,
	}
	
	--init objects
	init_objects()

	--basic game vars
	timeremaining=2400
	quicken=0
	extend=randbi(5,14)
	addextend=false
	offset=0
	enemycooldown=60
	maxenemycooldown=60
	score=newscore()
	chain=0
	maxchain=0
	startposx=30+64
	startposy=30+64
	flash=4
	prevpos=1
	fading=0
	fadespeed=5
	enemyspr=11
	stopsound=true
	bulletcolswap=2
	extendscore=0
	barcol=7
	
	--gameover vars
	gameover=false
	freezecooldown=120
	
	
	--score
	ones=0
	thousands=0
	milllions=0
	
	--player vars
	plyr={
		x=30+64,
		y=30+64,
		bombs=10,
		spd=3,
		frame=0,
		explosion=false,
		respawncooldown=0,
		death=false,
		invun=false,
		invuncooldown=120,
		explosioncooldown=120,
		createbomb=true,
		charge=0,
		playsound=true
	}
	
	--for player tempo sync
	tempo=0.24
	maxtempo=tempo
	framechange=0
	
	--misc tables
	chainlist={}
	explosioncircles={}
	particles={}
	text={}
	onscreentext={}
end
__gfx__
000000000000000aa000000000000000000000000000000000000000777777777777777077707707000770007700007700088000007777000000000000000000
000000000000000aa000000000000009900000000000000000000000000000000000000009900000007777007770077700888800077777700000000000000000
00700700000000a00a000000000000099000000000000009900000000000000000000000999900000076670007777770088cc880777667770000000000000000
00077000000000a00a00000000000090090000000000000990000000000000000000000090090000076666700076670088cccc88776666770000000000000000
00077000000000000000000000000090090000000000009009000000000000000000000000000000076666700076670088cccc88776666770000000000000000
0070070000000000000000000000000000000000000000900900000000000000000009900bb009900076670007777770088cc880777667770000000000000000
0000000000aa000bb000aa00000990033009900000009903309900000000000000009900bbbb0099007777007770077700888800077777700000000000000000
00000000aa0000bbbb0000aa099000333300099000990033330099000000000000009900bbbb0099000770007700007700088000007777000000000000000000
b0000000aa0000bbbb0000aa0990003333000990009900333300990000000000000009900bb00990000000000007700000077000077777700007700000000000
0000000000aa000bb000aa0000099003300990000000990330990000000000000000000000000000000000000077770000777700776666770007700000000000
00000000000000000000000000000000000000000000009009000000000000009900000090090000000000000776677000777700766666670077770000000000
00000000000000000000000000000090090000000000009009000000000770999999000099990000000000007766667707766770766776677776677700000000
00000000000000a00a00000000000090090000000000000990000000007700990099000009900000000000007766667707766770766776677776677700000000
00000000000000a00a00000000000009900000000000000990000000077009900009900000000000000000000776677077666677766666670077770000000000
000000000000000aa000000000000009900000000000000000000000770009900009900000000000000000000077770077777777776666770007700000000000
000000000000000aa000000000000000000000000000000000000000077000990099999000000000000000000007700077777777077777700007700000000000
000000000000000aa000000000000000000000000000000000000000007700999990099000000011110000000000555555550000000000000000000000001111
000000000000000aa00000000000000000220200000000000000000000077000990000990000001aa10000000000000000000000000001100110000000010ee1
00000000000000a00a0000000000000002200220000000000000000000000000990000990000001aa100000000000bbbbbb00000000111100111100000010ee1
00000000000000a00a000000000000002200002220000dd00000000000000000099009900000001111000000000000000000000000011011110110000001dd01
00000000000000000000000000000000200dd0002200ddd000000000000000000999999000000001100000000000005555000000001ee011110ee1000010dd10
0000000000000000000000000000000000dddd00022ddd0000000000000000000009900000000001100000000000000000000000001ee001100ee10001080010
0000000000aa000bb000aa00000000000ddeedd0002dd00e00000000000000000000000011110001100011110000000bb00000000010dd0110dd010001901100
00000000aa0000bbbb0000aa00000000ddeeeedd002dd0ee0000000000000000000000001aa1111111111aa1000000bbbb0000000100dd0110dd001001110000
00000000aa0000bbbb0000aa00000000ddeeeedd002dd0ee0000000000000000000000001aa1111111111aa10000500bb0050000010008811880001011110000
0000000000aa000bb000aa00000000000ddeedd0002dd00e000000000000000000000000111100011000111100b0050000500b0001000881188000101ee01000
0000000000000000000000000000000000dddd00022ddd000000000000000000000000000000000110000000500b00500500b00501000001100000101ee01000
00000000000000000000000000000000200dd0002200ddd000000000000000000000000000000001100000000500b005500b0050010009911990001010dd1000
00000000000000a00a000000000000002200002220000dd0000000000000000000000000000000111100000000500b0000b00500011109911990111001dd0100
00000000000000a00a0000000000000002200220000000000000000000000000000000000000001aa1000000000500b00b005000000110011001100001008010
000000000000000aa00000000000000000220200000000000000000000000000000000000000001aa10000000000500000050000000010a11a01000000110910
000000000000000aa000000000000000000000000000000000000000000000000000000000000011110000000000050000500000000011100111000000001110
11111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000dd000000000000000000000000000000000000
11111111111111110007700000000000000000000000000000000000000000000000000000000000000000000ddd000000000000000000000000000000000000
1111111111111111000770000000000000000000000000000000000000000000000000000000000000000000ddddd00000000000000000000000000000000000
111111111111111100000000000000000000000000000000000000000000000000000000000000000000000ddddddd0000000000000000000000000000000000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000000dddddddd0000000000000000000000000000000000
1111111111111111000000000000000000000000000000000000000000000000000000000000000000000dddddddddd000000000000000000000000000000000
1111111111111111000000000000000000000000000000000000000000000000000000000000000000000dddddddd00000000000000000000000000000000000
111111111111111100000000000000000000000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000
111111111111111100000000000000000000000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000d000000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000ddddddd00000000000000000000000000000ddd000000
11111111111111110000000000000000000000000000000000000000000000000000000000000000000ddddddd00000000000000000000000000dddddd000000
1111111111111111000000000000000000000000000000000000000000000000000000000000000000dddddddd0000000000000000000000000dddddddd00000
1111111111111111000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd000000000000000000000000000ddddddd00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd0000000000000000000000000dddddddd00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd0000000000000000000000000ddddddd000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd0000000000000000000000000ddddddd000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd00000000000000000000000dddddddd000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd000000000000000000000dddddddd0000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd000000000000000000000dddddddd0000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd0000000000000000000dddddddd00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddd000000000000000dddddddddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddd0000000000000dddddddddd000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddd0000000dddddddddddd0000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddddddddddddddd00000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddddddddddddd000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddddddddddd0000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddddddddd00000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddddd0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddd000000000000000000
77777777707777000007777077777777707777777770000777700007777000000000000000000000000000000000000000ddddddddd000000000000000000000
777777777f7777f00007777f777777777f77777777777007777f0007777f00000000000000000000000000000000000000000000000000000000000000000000
777777777f7777f00007777f777777777f77777777777f00777f000777ff00000000000000000000000000000000000000000000000000000000000000000000
777777777f7777f00007777f777777777f777777777777007777007777f000000000000000000000000000000000000000000000000000000000000000000000
6767ffffff6767600067676f6767ffffff6767fff76767f00767f0676ff000000000000000000000000000000000000000000000000000000000000000000000
7676f0000006767f007676ff7676f000007676f0007676f0067676767f0000000000000000000000000000000000000000000000000000000000000000000000
666666666006666f006666f066666666606666f0006666f000666666ff0000000000000000000000000000000000000000000000000000000000000000000000
666666666f066666066666f0666666666f6666f0066666f000666666f00000000000000000000000000000000000000000000000000000000000000000000000
666666666f006666f6666ff0666666666f66666666666ff00006666ff00000000000000000000000000000000000000000000000000000000000000000000000
666666666f006666f6666f00666666666f66666666666f000006666f000000000000000000000000000000000000000000000000000000000000000000000000
6666ffffff006666f6666f006666ffffff666666666fff000006666f000000000000000000000000000000000000000000000000000000000000000000000000
6666f000000006666666ff006666f00000666666666600000006666f000000000000000000000000000000000000000000000000000000000000000000000000
66666666600006666666f00066666666606666f6666660000006666f000000000000000000000000000000000000000000000000000000000000000000000000
666666666f0006666666f000666666666f6666f0666666000006666f000000000000000000000000000000000000000000000000000000000000000000000000
666666666f000066666ff000666666666f6666f0066666f00006666f000000000000000000000000000000000000000000000000000000000000000000000000
666666666f000066666f0000666666666f6666f0006666f00006666f000000000000000000000000000000000000000000000000000000000000000000000000
0fffffffff00000fffff00000fffffffff0ffff0000ffff00000ffff000000000000000000000000000000000000000000000000000000000000000000000000
77777777707770000000777077777777707777777770777700007777077777777000000000000000000000000000000000000000000000000000000000000000
777777777f777f000000777f777777777f777777777f7777f0007777f77777777770000000000000000000000000000000000000000000000000000000000000
777777777f7777000007777f777777777f777777777f7777f0007777f77777777777700000000000000000000000000000000000000000000000000000000000
777777777f7777700077777f777777777f777777777f777770007777f777777777777f0000000000000000000000000000000000000000000000000000000000
6767ffffff067676067677ff0ff767ffff6767ffffff76767f007676f7676fff6767670000000000000000000000000000000000000000000000000000000000
7676f00000006767f7676ff0000676f0007676f00000676767006767f6767f00067676f000000000000000000000000000000000000000000000000000000000
666666666000666666666f00000666f0006666666660666666f06666f6666f00006666f000000000000000000000000000000000000000000000000000000000
666666666f0006666666ff00000666f000666666666f666666606666f6666f000066666000000000000000000000000000000000000000000000000000000000
666666666f0006666666f000000666f000666666666f6666666f6666f6666f000066666f00000000000000000000000000000000000000000000000000000000
666666666f00666666666000000666f000666666666f666666666666f6666f000066666f00000000000000000000000000000000000000000000000000000000
6666ffffff006666f6666f00000666f0006666ffffff6666f6666666f6666f00006666ff00000000000000000000000000000000000000000000000000000000
6666f00000066666f6666600000666f0006666f000006666f6666666f6666f00066666f000000000000000000000000000000000000000000000000000000000
666666666066666ff0666660000666f00066666666606666f0666666f6666f00666666f000000000000000000000000000000000000000000000000000000000
666666666f6666ff0006666f000666f000666666666f6666f0666666f666666666666ff000000000000000000000000000000000000000000000000000000000
666666666f666ff00000666f000666f000666666666f6666f0066666f66666666666ff0000000000000000000000000000000000000000000000000000000000
666666666f666f000000666f000666f000666666666f6666f0066666f6666666666ff00000000000000000000000000000000000000000000000000000000000
0fffffffff0fff0000000fff0000fff0000fffffffff0ffff000fffff0ffffffffff000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777707770000000777077777777707777777770000000000077000000000000000000000000000000000000000000000000000000000000000000000000
777777777f777f000000777f777777777f7777777777700000000077f00000000000000000000000000000000000000000000000000000000000000000000000
777777777f7777000007777f777777777f77777777777f0000000777700000000000000000000000000000000000000000000000000000000000000000000000
777777777f7777700077777f777777777f77777777777700000007777f0000000000000000000000000000000000000000000000000000000000000000000000
6767ffffff067676067677ff0ff767ffff6767fff76767f000007676760000000000000000000000000000000000000000000000000000000000000000000000
7676f00000006767f7676ff0000676f0007676f0007676f00000676767f000000000000000000000000000000000000000000000000000000000000000000000
666666666000666666666f00000666f0006666f0006666f0000666ff666000000000000000000000000000000000000000000000000000000000000000000000
666666666f0006666666ff00000666f0006666f0066666f0000666f0666f00000000000000000000000000000000000000000000000000000000000000000000
666666666f0006666666f000000666f00066666666666ff000666ff0066600000000000000000000000000000000000000000000000000000000000000000000
666666666f00666666666000000666f00066666666666f0000666f000666f0000000000000000000000000000000000000000000000000000000000000000000
6666ffffff006666f6666f00000666f000666666666fff0006666666666660000000000000000000000000000000000000000000000000000000000000000000
6666f00000066666f6666600000666f000666666666600000666666666666f000000000000000000000000000000000000000000000000000000000000000000
666666666066666ff0666660000666f0006666f66666600066666666666666000000000000000000000000000000000000000000000000000000000000000000
666666666f6666ff0006666f000666f0006666f066666600666666ff666666f00000000000000000000000000000000000000000000000000000000000000000
666666666f666ff00000666f000666f0006666f0066666f666666ff0066666600000000000000000000000000000000000000000000000000000000000000000
666666666f666f000000666f000666f0006666f0006666f66666ff000066666f0000000000000000000000000000000000000000000000000000000000000000
0fffffffff0fff0000000fff0000fff0000ffff0000ffff0fffff000000fffff0000000000000000000000000000000000000000000000000000000000000000
66660666066606660000066600000006660660066606660666066606660000000000000000000000000000000000000000000000000000000000000000000000
6ff6f06ff6f6f6f6f00006f6f0000006fff6f6006ff06ff06ff6f6f6f6f000000000000000000000000000000000000000000000000000000000000000000000
6666f06f06f0f6f6f6660666f00000066606f6f06f006f006f06f6f6f6f000000000000000000000000000000000000000000000000000000000000000000000
6ffff06f06f606f6f0fff6f6f0000006fff6f6f06f006f006f06f6f6f6f000000000000000000000000000000000000000000000000000000000000000000000
6f0006660666f666f0000666f0000006660666f666006f06660666f6f6f000000000000000000000000000000000000000000000000000000000000000000000
0f0000fff0fff0fff00000fff0000000fff0fff0fff00f00fff0fff0f0f000000000000000000000000000000000000000000000000000000000000000000000
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
000500002e6001f600164002b60021600144002d60020600124002a600206000e400286001f6000c400256001d60009400226001b600064001e60017600034001960010600004000000000000000000000000000
00040000236002520024600202002060018200196000f2000c6000420001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a5001a5001a5002250022500225000050000500005000050000500005001750000500005001a50012500125001250000500005000050000500005000050000500005000050000500005000050000500
000e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
000e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
000e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
000e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
000e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
000500000a420082200b420092200e4200c220114200e2201342011230164301223018430132301a430142301c430172301d4401a240214401d240244401f240264402224028440232402a440262402d44029240
010d00003307533075330753307500005000050000500005330753307533075330750000500005000050000533075330753307533075000050000500005000053307533075330753307500005000050000500005
000c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010c00200c05312235064303a324064453c3253c3240c0533c6150c0530644006440062353e5253e5250c1530c05311244054451b323054453a0242e5223a0253c6153e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
0002000020450253501c45021350164501c3500b4500b440004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000700002663024430223302c630204301e3302663018430163301e6300e430083300e63006430023300063000430004000040000400004000040000400004000040000400004000040000400004000040000400
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
001d0c201072519d5519d4519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f72500000
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0020000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
00010000323502e3502d3502935025350213501e3501b35018350063000630001300063000d30004300043000b300043000b300043000b300043000b3000b300043000b300043000b3000b300043000b3000b300
0002000019350193501935019350223502235022350223501a000065001a0000650006400065001900019000045001700004500005000450000500045001e0001e000045001e0000450004500005000450004500
00020000213502135021350213501d3501d3501d3501d350003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
00060000253501f350133500c3501d65018650203501b350113500b35019650136501a350163500f3500c350186501265019350163500e35009350166501165015350113500b35008350126500e6500a35006350
0008000037455324552d45527455224551d45515455104550b4550845503455014550040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405
00100020093110c3210f32100321093210c3210f32100321093210c3210f32100321093210c3210f32100321093210c3210f32100321093210c3210f32100321093210c3210f32100321093210c3210f32100321
00070000174400f540164300e530144300d520124200b520104200a5200e410085100b4100551008410045100741004510064100151003410015100241000510004100c4000b4000940008400064000440001400
017800000c6110c6110c6150c6000c6140c6100c6100c6100c6110c6110c6150c6000c6140c6100c6100c6100c6110c6110c6150c6000c6140c6100c6100c6100c6110c6110c6150c6000c6140c6100c6100c610
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
000500002e6201f620164202b62021620144202d62020620124202a620206200e420286201f6200c420256101d61009410226101b610064101e61017610034101961010610004100000000000000000000000000
00040000236202522024620202202062018220196100f2100c6100421001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a5201a5201a5202252022520225200050000500005000050000500005001750000500005001a50012500125001250000500005000050000500005000050000500005000050000500005000050000500
000300001d3502145014350194500e350164500c3501e450183502945024350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 03 04 43 44
00 03 04 43 44
00 03 04 43 44
00 05 06 43 44
00 05 06 43 44
02 07 08 43 44
01 0b 42 43 44
00 0c 42 43 44
00 0b 0d 43 44
00 0c 0d 43 44
00 0b 0d 43 44
00 0c 0d 43 44
00 0b 0e 43 44
00 0c 0f 43 44
00 0b 0e 43 44
02 0c 0f 43 44
01 13 14 43 44
00 13 14 43 44
00 15 16 43 44
00 13 17 43 44
00 13 17 43 44
02 15 18 43 44
00 19 1a 43 44
01 12 42 43 44
00 1c 42 43 44
00 1d 42 43 44
00 12 42 43 44
00 12 1e 43 44
00 1c 1e 43 44
00 1d 1f 43 44
02 12 20 43 44
01 21 42 43 44
00 21 42 43 44
00 21 22 43 44
00 21 22 43 44
00 23 24 43 44
00 23 25 43 44
00 21 26 43 44
02 21 27 43 44
03 2c 2d 2e 2f
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
