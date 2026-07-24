pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--bytesabor
--by noba

function _init()
	init_game()
	cartdata("noba_byteslice_1")
end


function _update()
	
	--clamp item stats
	itemstats[1]=mid(-1,itemstats[1],1)
	itemstats[2]=mid(-0.1,itemstats[2],1.5)
	itemstats[3]=mid(-2,itemstats[3],4)
	itemstats[4]=mid(-600,itemstats[4],600)
	itemstats[5]=mid(-6,itemstats[5],20)
	itemstats[6]=mid(-3,itemstats[6],8)
	itemstats[7]=mid(-4,itemstats[7],4)
	
	if gamestate==1 then
		enemythreshold=mid(0,enemythreshold,70)
		plyr.chain=mid(1,plyr.chain,35)
		
		--gameover
		if enemythreshold>=69 and gameover==false then
			playerstate=0
			gameover=true
			sfx(-1)
		end
		if gameover==false then
			if freezeframe==true then
				freezeframecooldown-=1
				if(freezeframecooldown<=0)freezeframe=false
			end
		
			if freezeframe==false then
				
				--fair invulnerability
				fairinvun-=1
				
				--enemy speed increase
				baseenemyspeedinc+=0.00005
				baseenemyspeedinc=mid(0,baseenemyspeedinc,4)
			
		  --enemy spn
				spn+=0.2
				if spn>2.8 then
				 spn=0
				end
		
				--update objects--
				updateobjects()
				
				--player--
				--teleport control
				if(btn(4) and playerstate==0)sfx(9) playerstate=1
				if(not btn(4) and playerstate==1) playerstate=2
				
				--teleport and do effects
				if playerstate==2 then
					offset=0.15
					local lineangle=returnangle(plyr.x,plyr.y,crsr.x,crsr.y)
					for i=0,12 do
					 addspeedlines(rnd(128)+(cos(lineangle+0.5)*80),rnd(128)+(sin(lineangle+0.5)*80),5,18,lineangle,12,70)
					end
					for i=0,4 do
					 local angle=returnangle(plyr.x,plyr.y,crsr.x,crsr.y)+0.5+randb(-0.05,0.05)
					 addparticle(plyr.x,plyr.y,angle,15,randbi(4,10),0,randb(5,8),-0.3,{1,1,7,12,12,12})
					 addparticle(crsr.x,crsr.y,rnd(1),15,randbi(4,10),0,randb(5,8),-0.3,{1,1,7,12,12,12})
					end
					sfx(26)
					sfx(-1,3)
					playerstate=3
				elseif playerstate==3 then
					plyr.spd=20
					plyr.ang=returnangle(plyr.x,plyr.y,crsr.x,crsr.y)
				 addparticle(plyr.x,plyr.y,plyr.ang+0.5,15,randbi(2,5),0,randb(5,8),-0.3,{1,1,7,12,12,12})
					plyr.x+=cos(plyr.ang)*plyr.spd
					plyr.y+=sin(plyr.ang)*plyr.spd
					
					if dist(plyr.x,plyr.y,crsr.x,crsr.y)<20 then
						playerstate=0
						plyr.spd=0
						fairinvun=23
					end
				end
				
				--basic player movement
				if playerstate==0 then
					crsr.x=plyr.x
					crsr.y=plyr.y
				
					if(btn(0))plyr.ang=0.5
					if(btn(1))plyr.ang=0
					if(btn(2))plyr.ang=0.25
					if(btn(3))plyr.ang=0.75
					if(btn(1) and btn(2))plyr.ang=0.125
					if(btn(0) and btn(2))plyr.ang=0.375
					if(btn(1) and btn(3))plyr.ang=0.875
					if(btn(0) and btn(3))plyr.ang=0.625
				elseif playerstate==1 then
					if(btn(0))crsr.x-=8
					if(btn(1))crsr.x+=8
					if(btn(2))crsr.y-=8
					if(btn(3))crsr.y+=8
				end
				
				if (btn(0) or btn(1) or btn(2) or btn(3)) and playerstate==0 then
					plyr.spd=2.2+itemstats[1]
					
					if(plyr.invun==false)addparticle(plyr.x,plyr.y,rnd(1),randb(5,20),randbi(1,4),0,randbi(1,3),-0.1,{1,1,12,12,12})
					if(plyr.invun==true)addparticle(plyr.x,plyr.y,rnd(1),randb(5,20),randbi(1,4),0,randbi(1,3),-0.1,{4,4,9,9,9})
				else
					plyr.spd=0
					plyr.ang+=0.01
				end
				
				plyr.x=mid(0,plyr.x,128)
				plyr.y=mid(0,plyr.y,128)
				crsr.x=mid(0,crsr.x,128)
				crsr.y=mid(0,crsr.y,128)
				
				plyr.x+=cos(plyr.ang)*plyr.spd
				plyr.y+=sin(plyr.ang)*plyr.spd
				--player--
				
				
				
				--enemies--
				if #pickup==0 and #screentext==0 then
					if(minibossalive==false or (minibossalive==true and miniboss[1].hp>0))enemyspawncooldown-=1
				end
				
				if enemyspawncooldown==30 then
					
					if(minibossalive==false)enum=flr(rnd(3))+itemstats[3]+baseenemycount
					if(minibossalive==true)enum=0
					
					for i=0,enum do
						eangle=rnd(1)
						ex1=64+(cos(eangle)*95)
						ey1=64+(sin(eangle)*95)
						ex2=randbi(10,118)+(cos(eangle+0.5)*95)
						ey2=randbi(10,118)+(sin(eangle+0.5)*95)
						add(enemyangle,{
							ang=returnangle(ex1,ey1,ex2,ey2),
							x=ex1,
							y=ey1,
						})
					end
				end
			 if enemyspawncooldown<30 then
			  for i in all(enemyangle) do
				 	for j=0,1 do
					 	addparticle(i.x,i.y,i.ang+randb(-0.005,0.005),30,randbi(4,10),0,randb(2,5),-0.1,{2,2,8,8,8,7})
						 addparticle(i.x,i.y,i.ang+randb(-0.007,0.015),randbi(10,45),randbi(1,3),0,randb(3,5),-0.1,7)
					 end
				 end
				end
			 if enemyspawncooldown==0 then
					for i in all(enemyangle) do
						for k=0,4+itemstats[6] do
							addenemybasic(i.x+(cos(i.ang)*(9*k)),i.y+(sin(i.ang)*(9*k)),i.ang)
						end
						del(enemyangle,i)
						enemyspawncooldown=91
					end
					if rnd(7)>5 then
						for i=0,4+itemstats[7] do
							local ang=rnd(1)
							addenemybasic(64+cos(ang)*100,64+sin(ang)*100,0,1)
						end
					end
				end
				--enemies--
					
					
					
				--enemy collision--
		 	for i in all(enemybasic) do		

					--how enemies should die
					if (mainlineintersect(i,0,16,30).cross==true  or 
						   mainlineintersect(i,1,16,30).cross==true) and
						  playerstate==3 then
						  
						for j=0,3 do
							addparticle(i.x,i.y,rnd(1),30,randbi(1,3),0,randb(1,3),-0.05,{2,2,8,8,8,7})
						end
						plyr.score:add(50*flr(plyr.chain))
						plyr.chain+=0.2
						freeze(5)
						del(enemybasic,i)
						sfx(27)
						enemythreshold-=0.1
					end
					
					--ensures enemies die off
					--screen
					i.life-=1
					if(i.life<0 and i.state==0)del(enemybasic,i) enemythreshold+=0.5+itemstats[2] plyr.chain-=1.3
					
					--enemy collision with player
					if dist(plyr.x,plyr.y,i.x,i.y)<8 and playerstate!=3 then
						damageplayer(enemybasic)
					end
				end
				
				for i in all(minibosspart) do
					if dist(plyr.x,plyr.y,i.x,i.y)<6then
						if playerstate!=3 then
							damageplayer(minibosspart)
						end
					end
					if (mainlineintersect(i,0,12,12).cross==true  or 
									mainlineintersect(i,1,12,12).cross==true) and 
									playerstate==3 and bossinvuncooldown<=0   then
						freeze(5)
						del(minibosspart,i)
						sfx(28)
					end
				end
				
				for i in all(bullet) do
					if (dist(plyr.x,plyr.y,i.x,i.y)<6 and i.state==39) or (dist(plyr.x,plyr.y,i.x,i.y)<4 and i.state==41) then
						damageplayer(bullet)
					end
				end
				
				for i in all(miniboss) do

					--how enemies should die
					if (mainlineintersect(i,0,24,32).cross==true    or
							  mainlineintersect(i,1,24,32).cross==true)   and
							  playerstate==3 and bosscorevulnerable==true then
						
						for j=0,20 do
							addparticle(i.x,i.y,rnd(1),30,randbi(2,5),0,randb(7,10),-0.5,{2,2,8,8,8,7})
						end
						
						for i=0,10 do
							addparticle(randbi(1,28),randbi(1,8),rnd(1),35,randbi(1,2),0,randb(1,3),-0.07,8)
						end
						
						plyr.score:add(500*flr(plyr.chain))
						flashcooldown=4
						sfx(11)
						bossinvuncooldown=90
						i.hp-=1
						barhpx-=27/i.maxhp
						fairinvun=120
						i.moveanginc+=0.0006
						bosscorevulnerable=false
						i.setfirepoints=true
					end
					
					if i.hp<=0 then
						minibossexplosioncool-=1
						if	minibossexplosioncool<0 then
							minibossexplosioncool=10
							offset=0.15
							music(-1)
							sfx(14)
							minibossexplosioncount-=1
							for j=0,6 do
								addparticle(i.x+randbi(-8,8),i.y+randbi(-8,8),rnd(1),30,randbi(2,7),-0.05,randbi(5,8),0,{2,2,8,8,8})
							end
							for j=0,3 do
								addspeedlines(i.x,i.y,6,12,rnd(1),8,30)
							end
						end
						
						if minibossexplosioncount<0 then
							for j=0,30 do
									addparticle(i.x+randbi(-8,8),i.y+randbi(-8,8),rnd(1),120,randbi(2,4),-0.05,randbi(8,16),-0.1,{2,2,8,8,8})
							end
							offset=0.2
							flashcooldown=15
							sfx(15)
							del(miniboss,i)
							bossbulletcount+=3
							reinitboss()
							addpickup(64,64,2)
							fairinvun=120
							if(baseenemycount<6)baseenemycount+=1
							bosscount+=1
							plyr.score:add(500*flr(plyr.chain))
							minibossexplosioncount=6
						end
					end
				end
				--enemy collision--
				
				
				
				--miniboss spawn--
			 if(#miniboss==0 and minibossalive==false and #pickup==0)minibossspawncooldown-=1
				if minibossspawncooldown==0 then
					sfx(12)
					flashcooldown=45
					fairinvun=180
				elseif minibossspawncooldown<0 then
					addparticle(114,64,rnd(1),30,randbi(2,7),-0.05,randbi(2,5),0,{2,2,8,8,8,7,7})
					addspeedlines(114,64,6,12,rnd(1),8,30)
				end
				if minibossspawncooldown==-45 then
					addminiboss(64,64)
					hpdeduction=0
					barhpx=40
					freeze(3)
					offset=0.3
					sfx(13)
					music"16"
					for i=0,40 do
						addparticle(114,64,rnd(1),30,randbi(2,7),-0.2,randbi(15,15),-0.4,{2,2,8,8,8,7,7})
					end
					reinitboss()
				end
				--miniboss spawn--
			end
		end
	end
end


function _draw()

	--screen shake
	if(shakeon==true)screen_shake()

	--screen flash
	if flashon==true then
		if minibossspawncooldown>0 and freezeframe==false then
			if(flashcooldown>0)flashcooldown-=1
			if(flashcooldown%2==0 or (gameover==true and slidex<128))cls()
			if(flashcooldown%2==1)cls(7)
		end
		if minibossspawncooldown<=0 and freezeframe==false then
			if(flashcooldown>0)flashcooldown-=1
			cls()
			if(flashcooldown%8==1)cls(6)
			circfill(114,64,7,1)
		end
 else
 	cls()
 end

	if gamestate==0 then
		drawparticles()
		rectfill(0,37-liney,shipx,38+liney,0)
		if(shipx==0)sfx(24) offset=0.6 flashcooldown=6
		shipx+=5
		if(shipx<128)addparticle(shipx,38,0.5+randb(-0.2,0.2),60,randbi(1,5),0,randbi(2,4),-0.08,{12,12,12,7})
		sspr(112,64,16,16,shipx,30)
		
		if(shipx==270) sfx(25)
		if shipx>270 then
			if liney<17 then liney+=2
			else
				if(menutexty>0)menutexty-=2
				addparticle(0,rnd(128),0,randb(10,35),randbi(1,4),0,randbi(3,12),-0.3,{1,1,12,12,12})
				addparticle(128,rnd(128),0.5,randb(10,35),randbi(1,4),0,randbi(3,12),-0.3,{1,1,12,12,12})
				drawmenu()
				mspn+=0.5
				if(mspn>3.8)mspn=0
				
			 if menutransition==false then 
			 	sspr(8,0,16,16,56,100+menutexty)
					spr(57+mspn,60,112+menutexty)
					addparticle(64,112+menutexty,0.75+randb(-0.15,0.15),randb(10,35),randbi(1,4),0,randbi(3,6),-0.3,{1,1,12,12,12})
				end
				
				otext8("use ã é ó ë",35,3,7)
				
				if btnp(4) then
					if currentmenu==start then
						if selected==1 then
							sfx(29)
							menutransition=true
							offset=0.7
						elseif selected==2 then
							selected=1
							currentmenu=options
						elseif selected==3 then
							showextratext=2
						else
							showextratext=1
						end
					else
						if selected==1 then
							bosshpon= not bosshpon
						elseif selected==2 then
							shakeon= not shakeon
						elseif selected==3 then
							musicon= not musicon
						elseif selected==4 then
							lineson= not lineson
						elseif selected==5 then
						 flashon= not flashon
						else
							partion= not partion
						end
						
						if(partion==true)   options[1]="particles on"
						if(flashon==true)   options[2]="flash on"
						if(lineson==true)   options[3]="lines on"
						if(musicon==true)   options[4]="music on"
						if(shakeon==true)   options[5]="shake on"
						if(bosshpon==true)  options[6]="boss hp on"
						if(partion==false)   options[1]="particles off"
						if(flashon==false)   options[2]="flash off"
						if(lineson==false)   options[3]="lines off"
						if(musicon==false)   options[4]="music off"
						if(shakeon==false)   options[5]="shake off"
						if(bosshpon==false)  options[6]="boss hp off"
					end
				elseif btnp(5) then
					currentmenu=start
					basemenuangle=0
					menuangle=0
					selected=1
				end
				
				if showextratext==1 then
					otext8("Éãîë - move\nhold é - position teleport\nrelease é - teleport",3,64,7)
				elseif showextratext==2 then
					otext8("noba - programming & sounds\nnyeti - music\nfull credits on bbs, sorry! :(",3,64,7)
				end
				
			end
			if(liney==14)flashcooldown=8 music(12)
			sspr(0,64,111,32,8,22)
		end
		
		line(shipx,37-liney,-30,37-liney,6)
		line(shipx,38+liney,-30,38+liney,6)
		
		if liney>16 then
			mline+=5
			if(mline>140)mline=-40
			line(0+mline,37-liney,20+mline,37-liney,12)
			line(128-mline,38+liney,108-mline,38+liney,12)
			
			for i=0+mline,10+mline do
				if pget(i,38)==6 then
					pset(i,38,12)
				end
			end
			for i=128-mline,118-mline,-1 do
				if pget(i,38)==6 then
					pset(i,38,12)
				end
			end
		end
		
		if shipx>270 and liney<16 then
			rectfill(0,36-liney,128,20-liney,0)
			rectfill(0,39+liney,128,60+liney,0)
		end
		
		if menutransition==true then
			sspr(8,0,16,16,56,100-transy)
			
			transy+=5
			
			if(transy>128)transx+=5
			addparticle(64,112-transy,0.75+randb(-0.15,0.15),randb(10,35),randbi(2,4),0,randbi(7,12),-0.3,7)
			rectfill(63-transx,116-transy,63,128,7)
			rectfill(64+transx,116-transy,64,128,7)
			
			if transx>80 then
				print("ready?",64-hcenter("ready?"),64)
			end
			if transx>100 then
				gamestate=1.5
		 	music()
				offset=0.5
				sfx(31)
			end
		end
	elseif gamestate==1.5 then
		
		addparticle(rnd(128),-10,0.75,80,randbi(7,12),0,randbi(3,7),-0.3,{6,6,7,7})
		addparticle(rnd(128),-10,0.75,80,randbi(7,12),0,randbi(1,3),0,1)
		map(44,0,8,-172+mapy,14,16)
		drawparticles()
		addparticle(64,112-transy,0.75+randb(-0.15,0.15),randb(10,35),randbi(5,7),0,randbi(5,7),-0.3,7)
	 sspr(8,0,16,16,56,100-transy)
		rectfill(63-transx,116-transy,63,128,7)
		rectfill(64+transx,116-transy,64,128,7)
			
	 if(transx>0)transx-=5
	 if(transx==0 and transy>58)transy-=10
	 if(transy<=58 and mapy<180)mapy+=3
	 if mapy>=180 then
	 	rectfill(0,0,128,128,7) 
	 	sfx(-1) 
	 	sfx(30) 
	 	gamestate=1
	 	offset=0.4
	 	flashcooldown=6
	 	for i=0,30 do
	 		addparticle(64,64,rnd(1),randb(10,35),randbi(2,7),0,randbi(3,15),-0.3,{1,1,12,12,12,7})
	 	end
	 end
	elseif gamestate==1 then
		
	if freezeframe==true then
			freezeframecooldown-=1
			if(freezeframecooldown<=0)freezeframe=false
		end
	
		if freezeframe==false then
			
		 for st in all(stars) do
		  st.y+=st.sp

		  if (st.y>=128) then
		   st.y=0
		   st.sp=rnd(3)+1
		  end
		  pset(st.x, st.y, st.sc)
		  pal()
		 end	
		 
		 		
			--map
			map(44,0,8,8,14,14)
				
			--draw particles below everything
			
			--particles--
			drawparticles()
			--particles--
				
				
			--draw player
			if gameovercooldown>0 then
			if(plyr.invun==true)pal(12,9) pal(1,4)
			if(plyr.invun==false)pal()
				rspr(8,0,16,16,plyr.ang-0.25,plyr.x,plyr.y,23,23)
			end
			--draw teleport line, cursor
			--and particles
			if playerstate==1 then
				local angle=returnangle(plyr.x,plyr.y,crsr.x,crsr.y)
				local life =dist(plyr.x,plyr.y,crsr.x,crsr.y)
				addparticle(plyr.x,plyr.y,angle+randb(-0.01,0.01),15,6,0,5,-0.3,{7,7,12,12,1,1})
			
				local col
				crsr.spn+=0.25
				if(crsr.spn%2==0)col=7
				if(crsr.spn%2==1)col=12
				if(crsr.spn==6)crsr.spn=3
				
				line(plyr.x,plyr.y,crsr.x+4,crsr.y+4,col)
				spr(crsr.spn,crsr.x,crsr.y)
			end	
			
			--speedlines--	
			if lineson==true then
				for i in all(speedlines) do
				 i.x1+=cos(i.angle)*i.spd
				 i.y1+=sin(i.angle)*i.spd
				 i.x2+=cos(i.angle)*(i.spd-i.ad)
				 i.y2+=sin(i.angle)*(i.spd-i.ad)
				 
				 if i.ad<10 then
				  i.ad+=0.9
				 end
				 
				 i.lifespan-=1
				 if(i.lifespan<0)del(speedlines,i)
				 
				 line(i.x1,i.y1,i.x2,i.y2,i.col)
				end
			end
			--speedlines--
			
			
		
			--draw objects and map--
			drawobjects()
			
			rectfill(3,25+ceil(enemythreshold),5,94,12)
			rectfill(123,94-ceil(plyr.chain*2),125,94,12)
			
			for i=2,5 do
				sidebarsweep+=1
				if(sidebarsweep>61)sidebarsweep=0
			
			 for j=25+sidebarsweep,35+sidebarsweep do
			 	if pget(i,j)==12 or pget(i,j)==9 then
			 		pset(i,j,7)
			 	end
			 end
			end
			for i=122,127 do
			 for j=25+sidebarsweep,35+sidebarsweep do
			 	if pget(i,j)==12 or pget(i,j)==9 then
			 		pset(i,j,7)
			 	end
			 end
			end
			
			map()
			
			--draw invun stuff
			pal()
			
			invuncolnum+=0.09
			if(invuncolnum>4.8)invuncolnum=1
			
			if plyr.invun==true then
				
				cautionbar()
	
				otext8("ê!caution!ê",64-hcenter("ê!caution!ê"),113,invuntextcolour[flr(invuncolnum)])
				
				plyr.invuncooldown-=1
				if plyr.invuncooldown<=0 then
					plyr.invuncooldown=75
					plyr.invun=false
					poke(0x5f43,0)
				end
				cautionbarlines()
			end
			
			--boss invun core
			if bosscorevulnerable==true and plyr.invun==false then
				otext8("boss is vulnerable",64-hcenter("boss is vulnerable"),113,invuntextcolour[flr(invuncolnum)])
				cautionbar()
				cautionbarlines()
			end
			
			--boss hp
			if #miniboss>0 and bosshpon==true then
				
				clip(1,1,barhpx+abs(offset_x),8+abs(offset_y))
				spr(112,1,1)
				for i=1,3 do
					spr(113,1+(8*i),1)
				end
				spr(114,33,1)	
				clip()				
				spr(115,1,1)
				for i=1,3 do
					spr(116,1+(8*i),1)
				end
				spr(117,33,1)
				ospr(118,0,1,1)
				
				barswipe+=2
				if(barswipe>35)barswipe=1
				for i=0,1 do
					for j=1,9 do
						if pget(i+barswipe,j)==2 then 
							pset(i+barswipe,j,13)
						elseif pget(i+barswipe,j)==8 then
							pset(i+barswipe,j,6)
						elseif pget(i+barswipe,j)==7 then
							pset(i+barswipe,j,6)
						end
					end
				end
			end
			
			
			--print text
			otext8(flr(plyr.chain).."x".." "..plyr.score:text(),75,3,7)
			--draw objects and map--
			
			--draw screen text--
			if #screentext>0 then
				for i=0,5 do
					addparticle(0,64,0+randb(-0.1,0.1),60,randbi(3,7),0,randbi(5,10),0,itemcol)
					addparticle(128,64,0.5+randb(-0.1,0.1),60,randbi(3,7),0,randbi(5,10),0,itemcol)
				end
			end
			for i in all(screentext) do
				otext8(i.text,i.x,i.y,itemcol)
				i.ang+=0.0085
				i.x+=abs(sin(i.ang)*3.5)
				if(i.x>128)del(screentext,i)
			end
			--draw screen text--
			
			
			--polish--
		 mswipe+=2
		 for i=1+mswipe,mswipe+8 do
		 	for j=1,7 do
		 		if pget(i,j)==7 then
		 			pset(i,j,9)
		 		end
		 	end
		 end
			--polish--
		end
		
		
		--gameover
		if gameover==true then
			currentmenu=gameovermenu
			music(-1)
			gameovercooldown-=1
			if(gameovercooldown==149)sfx(17)
			if(linelength<150)linelength+=5 circradius+=8
			if gameovercooldown>0 then
				for i in all(gameoverlineang) do
				 i+=0.1
					line(plyr.x,plyr.y,plyr.x+cos(i)*linelength,plyr.y+sin(i)*linelength,7)
				end
				circ(plyr.x,plyr.y,circradius,7)
				circ(plyr.x,plyr.y,circradius/2+26,7)
			end
			if gameovercooldown<30 and gameovercooldown>0 then
				addparticle(plyr.x,plyr.y,rnd(1),60,randb(2,4),0,randb(3,6),-0.2,7)
			end
			if(gameovercooldown==0) then
				sfx(18)
				offset=2
				flashcooldown=6
				freeze(7)
				for i=0,40 do
					addparticle(plyr.x,plyr.y,rnd(1),60,randb(2,4),0,randb(10,15),-0.2,{2,2,12,12,12,7,7})
				end
			end
			if gameovercooldown<-70 then
				gamestate=2
			end
		end
	elseif gamestate==2 then
		slidex+=5
		menutexty=20
		
		if(slidex<128)rectfill(0,0,slidex,128,0)
		drawparticles()
		
		if slidex>128 then
			sndcooldown-=0.2
			
			if sndcooldown<0 and gameoverlettercount<8.2 then
				offset=0.2
				sfx(19) 
				
				for i=0,7 do
					addparticle(16*flr(gameoverlettercount),38,rnd(1),120,randbi(2,7),0,randbi(5,10),-0.5,7)
				end
				
				sndcooldown=1
			end
			
		 if gameoverlettercount<8.4 then 
		 	gameoverlettercount+=0.2
		 else
		 
		 	addparticle(rnd(128),128,0.25,randb(10,70),randbi(1,4),0,randbi(3,12),-0.1,{1,1,12,12,12})
		 	if showscore==false then
			 	showscorex+=10
			 	addparticle(0,60+randbi(-5,5),0,randb(10,70),randbi(5,9),0,randbi(5,10),-0.1,7)
			 	if showscorex>128 then
			 		showscorey+=0.8
			 		if(showscorey>5)flashcooldown=6 showscore=true
			 	end
			 	
			 	rectfill(showscorex,60+showscorey,0,60-showscorey,7)
		 	else
					otext8(plyr.score:text(),64-hcenter(plyr.score:text()),60,6)
					line(30,67,98,67,6)
					line(30,68,98,68,0)
		 	end
		 	if showchain==false then
			 	showchainx-=10
			 	addparticle(128,85+randbi(-5,5),0.5,randb(10,70),randbi(5,9),0,randbi(5,10),-0.1,7)
			 	if showchainx<=0 then
			 		showchainy+=0.8
			 		if(showchainy>5)flashcooldown=6 showchain=true
			 	end
			 	rectfill(showchainx,85+showchainy,128,85-showchainy,7)
		 	else
		 		local string="ó "..flr(plyr.chain).."    Ç "..bosscount
					otext8(string,64-hcenter(string),85,6)
					line(30,92,98,92,6)
					line(30,93,98,93,0)
		 	end
		 end
		 
		 if showchain==true and showscore==true then
		 	drawmenu()
		 	if btn(4) then
		 		init_game()
		 	end
		 end
		 
		 sspr(0,112,16*flr(gameoverlettercount),16,0,30)
		 swipe+=5
		 if(swipe>200)swipe=-10
		 for i=0+swipe,8+swipe do
		 	for j=30,100 do
		 		if pget(i,j)==6 then
		 			pset(i,j,7)
		 		end
		 	end
		 end
		end
	end
	
	if(musicon==false)music(-1)
end
-->8
--objects

function initobjects()
 enemybasic={}
 miniboss={}
 minibosspart={}
 item={}
 pickup={}
 bullet={}
end


function updateobjects()
 for i in all(enemybasic) do
  i:update()
 end
 for i in all(miniboss) do
  i:update()
 end
 for i in all(minibosspart) do
 	i:update()
 end
 for i in all(item) do
  i:update()
 end
 for i in all(pickup) do
  i:update()
 end
 for i in all(bullet) do
  i:update()
 end
end


function drawobjects()
 for i in all(enemybasic) do
  i:draw()
 end
 for i in all(miniboss) do
  i:draw()
 end
 for i in all(minibosspart) do
 	i:draw()
 end
 for i in all(item) do
  i:draw()
 end
 for i in all(pickup) do
  i:draw()
 end
 for i in all(bullet) do
  i:draw()
 end
end

function addenemybasic(_x,_y,_angle,_state)
	add(enemybasic,{
		x=_x,
		y=_y,
		ang=_angle,
		spd=2+baseenemyspeedinc,
		spn=19,
		life=120,
		state=_state,
		update=function(self)
			if(self.state==nil)self.state=0
			
			if self.state==0 then
				self.x+=cos(self.ang)*self.spd
				self.y+=sin(self.ang)*self.spd
			end
			if self.state==1 then
				self.spd=0.8
				self.spn=7
				self.ang=returnangle(self.x,self.y,plyr.x,plyr.y)
				self.x+=cos(self.ang)*self.spd
				self.y+=sin(self.ang)*self.spd
				
				if bossbulletcount>=18 then
					if(rnd(130)>120)addbullet(self.x,self.y,rnd(1),41)
				end
			end
		end,
		draw=function(self)
			spr(self.spn+flr(spn),self.x-4,self.y-4)
		end
	})

end



function addminiboss(_x,_y)
	add(miniboss,{
		spn=randbi(33,38),
		x=_x,
		y=_y,
		cooldown=60,
		hp=randbi(4,7),
		maxparts=randbi(10,15)+itemstats[5],
		setfirepoints=true,
		ang=0,
		dis=randbi(10,20),
		x1=0,y1=0,x2=0,y2=0,
		x3=0,y3=0,x4=0,y4=0,
		bulletcount=randbi(3,7),
		bulletstate=0,
		distx=randbi(12,24),
		disty=randbi(12,24),
		id=rnd(30000),
		fireangle=0,
		spd=40,
		startx=_x,
		starty=_y,
		moveanginc=0,
		aimeedbulletcooldown=120,
		teleportcooldown=120,
		update=function(self)
			minibossalive=true
		
			self.x5=self.x
			self.y5=self.y+randbi(-8,8)
		 self.fireangle=randb(0,0.15)
		 self.x1=self.x+(cos(0.25+self.fireangle)*self.dis)
		 self.y1=self.y+(sin(0.25+self.fireangle)*self.dis)
		 self.x3=self.x+(cos(0.25-self.fireangle)*self.dis)
		 self.y3=self.y+(sin(0.25-self.fireangle)*self.dis)
		 self.fireangle=randb(0.15,0.25)
		 self.x2=self.x+(cos(0.75+self.fireangle)*self.dis)
		 self.y2=self.y+(sin(0.75+self.fireangle)*self.dis)
		 self.x4=self.x+(cos(0.75-self.fireangle)*self.dis)
		 self.y4=self.y+(sin(0.75-self.fireangle)*self.dis)					
		 
		 if self.setfirepoints==true and self.hp>0 then
		 	for i=0,self.maxparts do
		 		addminibosspart(self.x,self.y,self.distx,self.disty,(1/self.maxparts)*i,self.id)
		 	end
		 	self.setfirepoints=false
		 	self.maxhp=self.hp
			end
			
			addparticle(self.x,self.y,rnd(1),randb(5,20),randbi(1,4),0,randbi(1,3),-0.1,{2,2,8,8,8})
			
			if bossbulletcount>=9 then
				self.aimeedbulletcooldown-=1
				if self.aimeedbulletcooldown <=0 then
					sfx(10)
					for i=0,bossbulletcount-1 do
						local bulletang=returnangle(self.x,self.y,plyr.x,plyr.y)
						addbullet(self.x,self.y,bulletang+randb(-0.2,0.2),39)
					end
					self.aimeedbulletcooldown=60
				end
			end
			if bossbulletcount>=18 then
				self.teleportcooldown-=1
				
				if self.teleportcooldown<=0 then
					sfx(25)
					offset=0.2
					self.ang+=0.5
					self.teleportcooldown=120
					for i=0,7 do
						addparticle(self.x,self.y,rnd(1),40,randbi(1,4),0,randbi(7,12),-0.05,8)
					end
				end
			end
			
			for i in all(minibosspart) do
				if i.id==self.id then
					i.startx=self.x-4
					i.starty=self.y-4
				end
			end
			
			self.ang+=0.005+self.moveanginc+(bossbulletcount/1400)
			self.x=self.startx+cos(self.ang)*self.spd
			self.y=self.starty+sin(self.ang)*self.spd
			
			if(self.bulletcount%2==1)self.bulletcount+=1
			
			self.cooldown-=1
			
			if self.cooldown<=0 and self.hp>0 then
				sfx(10)
				flashcooldown=3
				self.cooldown=randbi(60,100)
				self.bulletstate=randbi(39,41)
				if(self.bulletstate%2==0)self.bulletstate+=1
				if randbi(0,1)==0 then
					for i=0,self.bulletcount do
						addbullet(self.x1,self.y1,(1/self.bulletcount)*i,self.bulletstate)
						addbullet(self.x3,self.y3,(1/self.bulletcount)*i,self.bulletstate)
					end
				end
				if randbi(0,1)==1 then
					for i=0,self.bulletcount do
						addbullet(self.x2,self.y2,(1/self.bulletcount)*i+0.25,self.bulletstate)
						addbullet(self.x4,self.y4,(1/self.bulletcount)*i+0.25,self.bulletstate)	
					end
				end
				if randbi(0,1)==0 then
					for i=0,self.bulletcount do
				 	addbullet(self.x5,self.y5,(1/self.bulletcount)*i,self.bulletstate)
				 end
				end
				for j=0,4 do
					addparticle(self.x,self.y,rnd(1),30,randbi(4,7),0,randb(4,8),-0.1,{2,2,8,8,8,7})
				end
				offset=0.15
				flashcooldown=2
				self.bulletcount=randbi(2,5)+bossbulletcount
			end
			
		end,
		draw=function(self)
			spr(self.spn,self.x-4,self.y-4)

			if #minibosspart!=0 then
				sspr(88,8,16,16,self.x-8,self.y-8)
				bosscorevulnerable=false
			end
			if playerstate==0 and #minibosspart==0 then
				bosscorevulnerable=true
				bossinvuncooldown=60
			end
			bossinvuncooldown-=1
		end
	})
end

function addbullet(_x,_y,_angle,_state)
	add(bullet,{
		x=_x,
		y=_y,
		ang=_angle,
		spn=0,
		state=_state,
		life=100,
		update=function(self)
			self.x+=cos(self.ang)*1
			self.y+=sin(self.ang)*1
			self.life-=1
			if(self.life<0)del(bullet,self)
		end,
		draw=function(self)
			self.spn+=1
			if(self.spn>1)self.spn=0
			spr(self.state+flr(self.spn),self.x-4,self.y-4)
		end
	})
end

function addminibosspart(_x,_y,_distx,_disty,_startang,_id)
	add(minibosspart,{
		x=_x,
		y=_y,
		startx=_x-4,
		starty=_y-4,
		distx=_distx-4,
		disty=_disty-4,
		startang=_startang,
		ang=0,
		id=_id,
		update=function(self)
			self.ang+=0.005
			if(self.ang>1)self.ang=0
			self.x=self.startx+(cos(self.startang+self.ang)*self.distx)
			self.y=self.starty+(sin(self.startang+self.ang)*self.disty)
		end,
		draw=function(self)
			spr(21,self.x,self.y)
		end,
	})
end

function addpickup(_x,_y,_choice)
	add(pickup,{
	 x=_x,
	 y=_y,
	 startx=_x,
	 starty=_y,
	 choice=_choice,
	 ang=0,
	 setchoice=true,
	 chosenstat=0,
	 stattoadd=0,
	 spn=31,
	 pcol=7,
		update=function(self)
			enemyspawncooldown=100
			if self.setchoice==true then
				if self.choice==0 then
					self.chosenstat=randbi(1,7)
					self.stattoadd=self.chosenstat
					self.pcol=0
					self.spn=29
				elseif self.choice==1 then
					self.chosenstat=randbi(8,14)
					self.stattoadd=self.chosenstat-7
					self.spn=30
				else
					self.chosenstat=randbi(1,14)
					if(self.chosenstat<8)self.stattoadd=self.chosenstat itemcol=7
					if(self.chosenstat>7)self.stattoadd=self.chosenstat-7 itemcol=8
					self.spn=31
				end
				self.setchoice=false
			end
			
			if itemcollected==false then
				self.ang+=0.010
				self.x=self.startx+cos(self.ang)*15
				self.y=self.starty+sin(self.ang)*15
				addparticle(self.x,self.y,self.ang-0.25+randb(-0.1,0.1),60,rnd(3),-0.03,randb(2,4),-0.01,self.pcol)
			else
				itemeffectcooldown-=1
				addparticle(self.x,self.y,rnd(1),60,randb(2,8),-0.03,randb(5,8),-0.05,self.pcol)
				
				if itemeffectcooldown<=0 then
					offset=0.3
					itemstats[self.stattoadd]+=itemlist[self.chosenstat][2]
					del(pickup,self)
					sfx(24)
					addscreentext(itemlist[self.chosenstat][1])
					itemeffectcooldown=60
					itemcollected=false
					music(flr(rnd(11)))
					for i=0,20 do
						addparticle(self.x,self.y,rnd(1),60,randb(2,8),-0.03,randb(5,8),-0.05,self.pcol)
					end
				end
			end
			
			if dist(plyr.x,plyr.y,self.x,self.y)<8 and itemcollected==false then
				sfx(16)
				itemtocollect=self.chosenstat
				itemcollected=true
			end
		
		end,
		draw=function(self)
			pal(7,self.pcol)
				spr(self.spn,self.x-4,self.y-4)
				sspr(88,8,16,16,self.x-8,self.y-8)
			pal()
		end
	
	})
end
-->8
--misc

--returns angle from start point
--to end point
function returnangle(startx,starty,endx,endy)
	return atan2(endx-startx,endy-starty)
end

--returns distance from start point
--to end point
function dist(_x1,_y1,_x2,_y2)
    distx = abs(_x1-_x2)
    disty = abs(_y1-_y2)
    
    m = max(distx,disty)
    distx = distx / m
    disty = disty / m
    
    return sqrt((disty*disty)+(distx*distx)) * m
end

function randbi(l,h) --inclusive
    return flr(rnd(h+1-l))+l
end

function randb(l,h) --inclusive
    return rnd(h-l)+l
end

--line intersect by doc robs
function line_intersect(ax1,ay1,ax2,ay2,bx1,by1,bx2,by2)
  --output
  out={}
  out.cross=false
  out.x=0
  out.y=0
  
  --linear equation
  local l1={}
  local l2={}
  
  l1.m=(ay2-ay1)/(ax2-ax1)
  l1.c=-(l1.m*ax1)+ay1
  l2.m=(by2-by1)/(bx2-bx1)
  l2.c=-(l2.m*bx1)+by1
  
  if l1.m==l2.m then
    --parallel
    return out
  else
    --coordinates of cross
    local tm = l1.m-l2.m
    local tc = l2.c-l1.c
    
    --x intercept
    local ix = tc/tm
    out.x=ix
    
    --y intercept
    local iy = l1.m*ix+l1.c
    
    
    --finally, check the range
    local amax_x=max(ax1,ax2)
    local amin_x=min(ax1,ax2)
    local amax_y=max(ay1,ay2)
    local amin_y=min(ay1,ay2)
    local bmax_x=max(bx1,bx2)
    local bmin_x=min(bx1,bx2)
    local bmax_y=max(by1,by2)
    local bmin_y=min(by1,by2)
    
    if (ix>amax_x or 
      ix<amin_x or
      iy>amax_y or 
      iy<amin_y) or
      (ix>bmax_x or 
      ix<bmin_x or
      iy>bmax_y or 
      iy<bmin_y) then
    out.cross=false
  else
    out.x=ix
    out.y=iy
    out.cross=true 
  end
  end  
  return out  
end

function hcenter(s)
	return (#s/2)*4
end

function reinitboss()
	minibossspawncooldown=750+itemstats[4]
	bosscorevulnerable=false
	bossinvuncooldown=60
	minibossexplosioncool=30
	minibossexplosioncount=7
	minibossalive=false
end


function drawmenu()
 for i=1,#currentmenu do
		
 	ang=(1/#currentmenu)
 	text=currentmenu[i]
 
 	otext8(text,64-hcenter(text)+(cos(menuangle+(ang*i))*64),150+menutexty+(sin(menuangle+(ang*i))*64),7)

 	btncooldown-=1
 	if btncooldown<0 then
 		if btnp(0) then basemenuangle-=(1/#currentmenu) selected-=1 btncooldown=20 mswipe=-30 sfx(21) showextratext=0 end
 		if btnp(1) then basemenuangle+=(1/#currentmenu) selected+=1 btncooldown=20 mswipe=-30 sfx(20) showextratext=0 end
 	end
 	if(menuangle<basemenuangle)menuangle+=0.005 
 	if(menuangle>basemenuangle)menuangle-=0.005 
		
		if(selected>#currentmenu)selected=1
		if(selected<1)selected=#currentmenu

	 if(mswipe>=74)mswipe=34
	 mswipe+=0.4
	 
	 if menutransition==false then
		 if (gamestate==0 and flashcooldown<=0) or gamestate>0 then
			 for i=1+mswipe,mswipe+4 do
			 	for j=80,120 do
			 		if pget(i,j)==7 then
			 			pset(i,j,9)
			 		end
			 	end
			 end
		 end
	 end
 end
end

--score
function newscore()
    local s = {u=0,k=0}
    s.add = function (this,p)
    
    								--add particles to score
    							 mswipe=80
    							 for i=0,2 do
    							 	addparticle(randbi(80,120),randbi(0,10),rnd(1),15,randbi(1,2),0,randb(0.5,2),-0.07,9)
    							 end
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

--outline text
function otext8(t,x,y,c)
 for i=-1,1 do
  for j=-1,1 do
   print(t,x+i,y+j,0)
  end
 end
 print(t,x,y,c)
end

--function to save tokens with line intersect
function mainlineintersect(_object,_linetype,_dist1,_dist2)

	--linetype 0=x1a and x2a
	--linetype 1=x3a and x4a
	--object must be an identifier
	--from a table, eg
	--for i in all(enemybasic)
	--mainlineintersect(i,0,16,30)
	
 local x1a=_object.x+(cos(_object.ang)*_dist1)
	local y1a=_object.y+(sin(_object.ang)*_dist1)
	local x2a=_object.x+(cos(_object.ang+0.5)*_dist1)
	local y2a=_object.y+(sin(_object.ang+0.5)*_dist1)
	local x3a=_object.x+(cos(_object.ang+0.25)*_dist2)
	local y3a=_object.y+(sin(_object.ang+0.25)*_dist2)
	local x4a=_object.x+(cos(_object.ang+0.75)*_dist2)
	local y4a=_object.y+(sin(_object.ang+0.75)*_dist2)
	
	if _linetype==0 then
		return line_intersect(x1a,y1a,x2a,y2a,plyr.x,plyr.y,crsr.x,crsr.y)
	else
		return line_intersect(x3a,y3a,x4a,y4a,plyr.x,plyr.y,crsr.x,crsr.y)
	end
end


-->8
--effects


--particles
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

function drawparticles()
	
	if partion==true then
		for i in all(particles) do
			pal()
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
end

-- draw a rotated, scaled
-- sprite at dx,dy with dw,dh
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

function addspeedlines(_x,_y,_maxdist,_spd,_angle,_col,_lifespan)
 add(speedlines,{
		x1=_x,
		y1=_y,
		x2=_x+(cos(_angle+0.5)*10),
		y2=_y+(sin(_angle+0.5)*10),
		ad=0,
		maxdist=_maxdist,
		spd=_spd,
		angle=_angle,
		col=_col,
		lifespan=_lifespan,	
 })
end


function screen_shake()
	if freezeframe==false then
  local fade = 0.95
  offset_x=16-rnd(32)
  offset_y=16-rnd(32)

  offset_x*=offset
  offset_y*=offset
  
  camera(offset_x,offset_y)

  offset*=fade
  if offset<0.05 then
    offset=0
  end
 end
end

function freeze(duration)
	freezeframe=true
	freezeframecooldown=duration
end

function addscreentext(_text)
	add(screentext,{
		text=_text,
		x=0-#_text*5,
		y=62,
		ang=0,
	})
	itemx1=0 
	itemx2=0
end

function addmovingtext(_text,_x,_y,_col)
	add(movingtext,{
		text=_text,
		x=_x,
		y=_y,
		col=_col,
		inc=0,
	})
end

function damageplayer(_tablename)
	if plyr.invun==false and playerstate<2 and minibossspawncooldown>0 and fairinvun<=0 then
		plyr.invun=true
		sfx(28)
		flashcooldown=6
		freeze(5)
		offset=0.2
		enemythreshold+=16
		del(enemybasic,i)
		poke(0x5f43,15)
		for i=0,15 do
			addparticle(plyr.x,plyr.y,rnd(1),30,randbi(1,12),-0.05,randb(7,12),-0.2,{4,4,9,9,9,7})
		end
	end
end

function cautionbarlines()
	cautionlinesweep+=3
	if(cautionlinesweep>150)cautionlinesweep=-10
	line(cautionlinesweep,120,cautionlinesweep+10,120,7)
	line(128-cautionlinesweep,127,118-cautionlinesweep,127,7)
	
	for i=0+cautionlinesweep,10+cautionlinesweep do
		for j=120,128 do
			if pget(i,j)==4 then
			 pset(i,j,9)
			end
		end
	end
	for i=118-cautionlinesweep,128-cautionlinesweep do
		for j=120,128 do
			if pget(i,j)==4 then
			 pset(i,j,9)
			end
		end
	end
end

function ospr(n,o,x,y,...)
    memcpy(0x4300,0x5f00,16)
    for i=0,15 do
        pal(i,o)
    end
    for a=x-1,x+1 do
        for b=y-1,y+1 do
            spr(n,a,b,...)
        end
    end
    memcpy(0x5f00,0x4300,16)
    spr(n,x,y,...)
end


function cautionbar()
	if(barinc>3.8)barinc=0
	for i=0,16 do
		spr(73+flr(barinc),0+8*i,120)
	end
end


-->8
--init

function init_game()
	

	initobjects()
	
	
	--modifiers/item	
	itemstats={
		0, --speed
		0, --threshold lost
		0, --enemies
		0, --miniboss spawnrate
		0, --boss shields
		0, --enemy line count
		0, --stalker spawns
	}
	itemlist={
		{"+speed"													, 0.3},
		{"-threshold lost"				,-0.15},
		{"-enemies"											,-1},
		{"-boss spawnrate"				, 100},
		{"-boss shields"						,-2},
		{"-line size"									,-1},
		{"-stalker spawns"				,-1},
		{"-speed"													,-0.45},
		{"+threshold lost"				, 0.15},
		{"+enemies"											, 1},
		{"+boss spawnrate"				,-100},
		{"+boss shields"						, 3},
		{"+enemy line count"		, 1},
		{"+stalker spawns"				, 1},
	}	
	
	
	
	--plyr
	plyr={
		x=64,
		y=64,
		lives=3,
		anim=1,
		ang=0,
		spd=0,
		angimg=0,
		xprev=0,
		yprev=0,
		invun=false,
		invuncooldown=60,
		score=newscore(),
		chain=1,
	}
	crsr={
		x=0,
		y=0,
		teleportcount=0,
		spn=3,
	}
	playerstate=0
	gamestate=0
	
	
	--misc vars
	enum=1
	freezeframe=false
	freezecooldown=1
	offset=0
	combo=0
	invuncolnum=1
	flashcooldown=6
	enemythreshold=0
	bossbulletcount=1
 spn=0
	reinitboss()
	itemcollected=false
	itemeffectcooldown=60
	itemtocollect=0
 itemx1=128 itemy1=58
 itemx2=128 itemy2=70
 gameover=false
 linelength=0
 circradius=0
 gameovercooldown=150
 slidex=0
 sndcooldown=1
 showscorex=0
 showscorey=0
 showscore=false
 showchainx=128
 showchainy=0
 showchain=false
 swipe=0
 mswipe=0
 fairinvun=0
 baseenemyspeedinc=0
	barswipe=0
 barhpx=27
 barinc=0
 cautionlinesweep=0
 sidebarsweep=0
	gameoverlineang={
		0.25,
		0.50,
		0.75,
		1,
	}
 gameoverlettercount=0
 liney=0
 shipx=-30
 menuswipe=0
 menutexty=50
 mspn=0
 mline=0
 showextratext=0
 menutransition=false
 transx=0
 transy=0
 transchange=false
 mapy=0
 baseenemycount=0
 itemcol=7
 bosscount=0
 
	--enemy vars
	enemyangle={}
	enemyspawncooldown=31
	eangle=0
	ex1=0 ex2=0
	ey1=0 ey2=0
	
	
	--misc tables
	teleportpos={}
	particles={}
	speedlines={}
	movingtext={}
	invuntextcolour={1,4,9,10}
	screentext={}
	
	

	
	--menus
	start={
	 "start",
	 "help",
	 "credits",
	 "options",
	}
	options={
		"particles on",
	 "flash on",
	 "lines on",
	 "music on",
	 "shake on",
	 "boss hp on",
	}
	partion=true
	flashon=true
	lineson=true
	musicon=true
	shakeon=true
	bosshpon=true
	
	gameovermenu={
		"restart",
		"restart",
		"restart",
		"restart",
	}
	currentmenu=start
	btncooldown=0
	selected=1
	menuangle=0
	basemenuangle=0
	
	
	--stars
 stars={}
 
 local totstars=80

 for i=1,totstars do
 
  local tc=flr(rnd(4)+1)
  
  if (tc==1) then sc=1 end
  if (tc==2) then sc=13 end
  
  add(stars,{
   x=rnd(128),-- random "x" pos.
   y=rnd(128),-- random "y" pos.
   sp=tc,     -- speed from 1-3.
   sc=sc      -- star color.
  })
   
 end
end
__gfx__
00000000000000000000000000100100001001000010010000000000000000000000000000088000007007000000000000700700007007000000000000777700
00000000000000000000000000111100001111000017710000000000000000000008800000077000007007000000000000700700007007000000000000700700
007007000000000cc000000011111111111771111177771100000000000880000007700000877800007007000000000000700700007007000000000000700700
000770000000000cc000000001177110017117100771177000000000008778000877778087777778007007000000000000777700007007000000000000700700
00077000000000cccc00000001177110017117100771177000000000008778000877778087777778007007000000000000700700007007000000000000700700
00700700000000cccc00000011111111111771111177771100000000000880000007700000877800007007000000000000700700007007000000000000700700
000000000000077cc770000000111100001111000017710000000000000000000008800000077000007007000000000000700700007007000000000000700700
00000000000007777770000000100100001001000010010000000000000000000000000000088000007007000000000000700700007777000000000000700700
00000000000077700777000000000000000000000088880000000000000000000000000088888888000000000000000000000000000000000000000000000000
00000000000077000077000000000000000880000887788000000000000000000777777087777778000000000000007777000000000770000007700007777770
00000000000c77000077c00000088000008888008877778800000000008888000788887087888878000000000000777007770000007777000007700007000070
00000000000cc770077cc00000888800088778808778877800000000008778000787787087877878000000000007700000077000077777700007700000077770
0000000000cccc7777cccc0000888800088778808778877800000000008778000787787087877878000000000077000000007700000770000777777000077000
0000000000cccc0000cccc0000088000008888008877778800000000008888000788887087888878000000000070000000000700000770000077770000000000
00000000000000000000000000000000000880000887788000000000000000000777777087777778000000000770000000000770000770000007700000077000
00000000000000000000000000000000000000000088880000000000000000000000000088888888000000000700000000000070000000000000000000000000
00000000000000000000000000000000000000000000000000000000009999000022220000000000000000000700000000000070000000000000000000000000
00000000007777000008800006600660000660000808808006000060099229900229922000022000000990000770000000000770000000777700000000000000
000000000886688000088000086006800608806006700760007007009922229922999922002222000099990000700000000007000000777cc777000000000000
00000000007007000770077000888800007777000766667006088060922222292999999202299220099229900077000000007700000777cccc77700000000000
0000000007600670077777700007700000088000060000600776677092222229299999920229922009922990000770000007700000777cccccc7770000000000
000000000070070007088070007777000606606007600670006886009922229922999922002222000099990000007770077700000077cccccccc770000000000
000000000008800006066060000770000700007008000080006006000992299002299220000220000009900000000077770000000777cccccccc777000000000
00000000000000000000000000000000000000000000000000000000009999000022220000000000000000000000000000000000077cccccccccc77000000000
00000000007777000777777000077000007777009999999999999999999999990cccccc000000000000000000777777000000000077cccccccccc77000000000
0000000007700770770000770077770000700700004400444004400400000000cccccccc000000000077770077cccc77007777000777cccccccc777000000000
0000000077000077700000070070070077700777044004400044004400000000c7cccc7c00077000077cc7707cccccc7077cc7700077cccccccc770000000000
0000000070077007700770070770077070077007440044000440044000000000c77cc77c007cc70007cccc707cccccc707cccc7000777cccccc7770000000000
0000000070077007700770070707707070077007400440044400440000000000cccccccc007cc70007cccc707cccccc707cccc70000777cccc77700000000000
0000000077000077700000077707707777700777004400444004400400000000cccccccc00077000077cc7707cccccc7077cc7700000777cc777000000000000
000000000770077077000077700000070070070004400440004400440000000000cccc00000000000077770077cccc7700777700000000777700000000000000
000000000077770007777770777777770077770099999999999999999999999900c00c0000000000000000000777777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000099999999999999999999999999999999000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000440044400440044400440004400440000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000004400440004400444004400444004400000000000000000000000000
00011111111111111111100000000011111111111100000000001111111111111111000044004400044004400044004440044004000000000000000000000000
00011111111111111111100000000111111111111110000000011111111111111111100040044004440044000440044000440044000000000000000000000000
00011000000110000001100000001011001100110011000000011000000000000001100000440044400440044400440004400440000000000000000000000000
00011000000110000001100000011110011001100111100000011001100110011001100004400440004400444004400444004400000000000000000000000000
00011000000110000001100000011100110011001101100000011011111111111101100099999999999999999999999999999999000000000000000000000000
00011000000110000001100000011001100110011001100000011011111111111101100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011011001100110011100000011001100110011001100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011110011001100111100000011001100110011001100000000000000000000000000000000000000000000000000000000000
00011111111111111111100000011100110011001101100000011011111111111101100000000000000000000000000000000000000000000000000000000000
00011111111111111111100000011001100110011001100000011011111111111101100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011011001100110011100000011001100110011001100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011110011001100111100000011001100110011001100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011100110011001101100000011011111111111101100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011001100110011001100000011011111111111101100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000011011001100110011100000011001100110011001100000000000000000000000000000000000000000000000000000000000
00011000000110000001100000001110011001100111000000011000000000000001100000000000000000000000000000000000000000000000000000000000
00011111111111111111100000000111111111111110000000011111111111111111100000000000000000000000000000000000000000000000000000000000
00011111111111111111100000000011111111111100000000001111111111111111000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077777777777777777707777770000000000000000000000000000000000000000000000000000000000000000000000000
00000088888888888888888000000700000000000000000777777777000000000000000000000000000000000000000000000000000000000000000000000000
00000888888888888888880000007000000000000000007070777707000000000000000000000000000000000000000000000000000000000000000000000000
00008888888888888888800000070000000000000000070070077007000000000000000000000000000000000000000000000000000000000000000000000000
00022222222222222222000000700000000000000000700077777777000000000000000000000000000000000000000000000000000000000000000000000000
00222222222222222220000007000000000000000007000077700777000000000000000000000000000000000000000000000000000000000000000000000000
02222222222222222200000070000000000000000070000007777770000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077777777777777777700000000700700000000000000000000000000000000000000000000000000000000000000000000000000
00000777777777700000077770007777007777777777777000000777777777770000000000000000000000000000000000000000000000000000000000000000
00007777777777770000777700007777007777777777777700007777777777770000000000000000000000000000000000000000000000000000000000000000
00007777777777770000777700007777007777777777777700007777777777770000000000000000000000000000000000000000000000000000000000000000
000077777777777700007777000077770007777777777777000077777777777700000000000000000000000000000000000000000000000000cc000000000000
000777700007777000077770000777700000000777700000000777700000000000000000000000000000000000000000000000000000000000cccc0000000000
000777700007777000077770000777700000000777700000000777700000000000000000000000000000000000000000000000000000000000ccc77700000000
000777700007777000077770000777700000000777700000000777700000000000000000000000000000000000000000000000000000000000cc777777000000
00777777777777000077777777777700000000777700000000777777777777000000000000000000000000000000000000000000000000000007700777cc0000
0077777777777700007777777777770000000077770000000077777777777700000000000000000000000000000000000000000000000000000700007ccccc00
00777777777777000077777777777700000000777700000000777777777777000000000000000000000000000000000000000000000000000007700777cc0000
077770000777700000000000077770000000077770000000077770000000000000000000000000000000000000000000000000000000000000cc777777000000
077770000777700000000000077770000000077770000000077770000000000000000000000000000000000000000000000000000000000000ccc77700000000
077770000777700000000000077770000000077770000000077770000000000000000000000000000000000000000000000000000000000000cccc0000000000
777777777777000077777777777700000000777700000000777777777777000000000000000000000000000000000000000000000000000000cc000000000000
77777777777700007777777777770000000077770000000077777777777700000000000000000000000000000000000000000000000000000000000000000000
77777777777000007777777777700000000077770000000077777777777000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000000000000
000000000000000000000000000000000000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000000000000000
000000000000000000000000000000000000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000000000000000
000000000000000000000000000000000000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000000000000000
00000000000000000000000000000000000cccc000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc00000000000000000
00000000000000000000000000000000000cccc000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc00000000000000000
00000000000000000000000000000000000cccc000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc00000000000000000
0000000000000000000000000000000000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccc0000cccc0000cccccccccc00000000000000000000
0000000000000000000000000000000000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccc0000cccc0000cccccccccc00000000000000000000
0000000000000000000000000000000000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccc0000cccc0000cccccccccc00000000000000000000
00000000000000000000000000000000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000000000000000000
00000000000000000000000000000000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000000000000000000
00000000000000000000000000000000000000000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000000000000000000
00000000000000000000000000000000cccccccccccc0000cccc0000cccc0000cccccccccccc0000cccccccccccc0000cccc0000cccc00000000000000000000
00000000000000000000000000000000cccccccccccc0000cccc0000cccc0000cccccccccccc0000cccccccccccc0000cccc0000cccc00000000000000000000
00000000000000000000000000000000ccccccccccc00000cccc0000cccc0000ccccccccccc00000ccccccccccc00000cccc0000cccc00000000000000000000
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
00000666666666660000066666666666000006666666666600000666666666660000066666666666000006660000666600000666666666660000066666666660
00006666666666660000666666666666000066666666666600006666666666660000666666666666000066660000666600006666666666660000666666666666
00006666666666660000666666666666000066666666666600006666666666660000666666666666000066660000666600006666666666660000666666666666
00006666666666660000666666666666000066666666666600006666666666660000666666666666000066660000666600006666666666660000666666666666
00066660000000000006666000066660000666066660666000066660000000000006666000066660000666600006666000066660000000000006666000006660
00066660000000000006666000066660000666066660666000066660000000000006666000066660000666600006666000066660000000000006666000006660
00066660000000000006666000066660000666066660666000066660000000000006666000066660000666600006666000066660000000000006666000006660
00666600006666000066666666666600006660666606660000666666666666000066660000666600006666000066660000666666666666000066666666660000
00666600006666000066666666666600006660666606660000666666666666000066660000666600006666000066660000666666666666000066666666660000
00666600006666000066666666666600006660666606660000666666666666000066660000666600006666000066660000666666666666000066666666660000
06666000066660000666600006666000066606666066600006666000000000000666600006666000066660000666600006666000000000000666600006666000
06666000066660000666600006666000066606666066600006666000000000000666600006666000066660000666600006666000000000000666600006666000
06666000066660000666600006666000066606666066600006666000000000000666600006666000066660000666600006666000000000000666600006666000
66666666666600006666000066660000666066660666000066666666666600006666666666660000666666666666000066666666666600006666000066660000
66666666666600006666000066660000666066660666000066666666666600006666666666660000666666666666000066666666666600006666000066660000
66666666666000006666000066660000666066660666000066666666666000006666666666600000666666666660000066666666666000006666000066660000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000040414141414141414141414141424344444444444444444444444445464747474747474747474747474800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000050515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000050515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f00000000000000000000000000000f50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c00000000000000000000000000000c50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c00000000000000000000000000000c50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d00000000000000000000000000000d50515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000050515151515151515151515151525354545454545454545454545455565757575757575757575757575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000060616161616161616161616161626364646464646464646464646465666767676767676767676767676800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01030203180701b070180702400032200322003220032200322003220032200322003220032200322003220032200322003220032200322003220032200322003220032200322003220032200322003220000000
01030203180701c07018070180003560012400306001b4002a6000740024600104001e6000140016600064000d60006600006001c600156000f60004600006000660005600046000360003600026000260000600
01030203180701d070180701b000316001c2001060004200000000000000000000000000023200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900041b0601a06016060130602230038700343003b7003330035700283001a7000e70009700007000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0109000416060130601b0601a0600a600054000e600054000a6000540002600004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900041d0601c06018060130600a3000a30030300303001140011400004000040011400114000c4000c40011400034001b400114003740037400114003c4003e4000340003400034001b4000c4001b40000400
0109000018060130601d0601c0600e3000e3000e3000e3000e3000e3000e3000e3000c3000c3000c3000c3001030010300103000e3000e3000e3000c3000c3000c3000c3000c3000c3000c3000c3000c3000c300
010300002060018600116000c6000a600086000760006600066000660006600066000760008600096000a6000b6000d6000e60010600116001360015600176001a6001b6001d6001f6002260025600286002b600
011000200763007630086300763007630086300863008630096300963009630086300663008630076300763007630076300863007630086300863008630086300863008630086300863008630086300863008630
01030000321302c130261301d13019130131300d1300b130061300313000130321003210032100321003210032100321003210032100321003210032100321003210032100321003210032100321003210032100
01020000284302033023430242301b43011330144301d230134300b33010430182300d43007330084300c2300543003330054300b230034300033001430032300330003300033003c6001b3001b4001b30000000
010300002543021630303301c6302f430166302233013630264300f6301c3300c6301e4300b630153300963014430066300d330046300f4300563009330036300a43003630053300163005430016300533001630
01050000053510b45115351204512a3512f451313512d451053510a45115351214512a3512f451313512e451053510a45115351214512a3512f451313512e451053510a45115351214512a3512f451313512e451
010400002c430226302a43020330284301e630264301b3302343019630214301733020430156301d430123301c43011630194300f330174300c630134300933010430076300d430053300b430016300843000330
01040000366302f630366302a63034630216302863013630196300d63014630086300e63005630006300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f34035640356401e44035640346401b3403364032640194402f6402e6401534029640286401044023640206400d3401a640176400a4401264010640053400b640086400144004640036400034000640
010900000b4320e33207432093320443205332024320433201432033320043203332024320533203432073320543208332074320b332094320f3320e43215332154321c3321b43223332214322b3322a4322d432
0102000027333273332423327333263332243325333253332023324333243332043323333233331f23322333223331e43322333223331e23321333213331e43321333213331d23320333203331c4331f3331e333
0108000035330306302b330286302f3302b63027330236302d33026630223301f63027330206301c33017630213301c63018330136301c33017630133300f63016330126300f3300c630123300f6300b33007630
010300002c630204301d63017430186301a43015630114300c6300843004630004300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001c6301f6302263025630286402b6402d6402f650306503165032640326403264031640306402f6302e6302d6202b6202a62028620266102561022610206101e6101c61018610156100f6100961003610
0102000001630056300a6300f6301064015640186401a6501b6501e6502064021640236402464027640286302963029620286202862027620256102461022610206101e61019610146100e610076100261000610
01050000153501535029350293500f3500f3502235022350223502235000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b00
000500001865027650326503f6503f650356502865024650226501f6501c650196501865016650146501365012650106500f6500d6500c6500a65009640086400663005630046200362002620016100061000610
0005000023350346502e3503b6502135025650163501b650153501d65012350196500e350136500b350136500d350156500e35012650043500a6500235008650063500b650063500a65000350026500065000350
010300001f650226502965032650396503f65038650316502a650236501e65018650136500e6500a6500465000650006500065000650006500000000000000000000000000000000000000000000000000000000
010200003b630104303a6301b4303563012430306301b4302a6300743024630104301e6300143016630064300d63006630006301c600156000f60004600006000660005600046000360003600026000260000600
010500003d63029330316301a33020630093300e630054300a6400543002620004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002a3302563032330296302d330216302433013630173300463006330003300033000330004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600002065018650116500c6500a650086500765006650066500665006650066500765008650096500a6500b6500d6500e65010650116501365015650176501a6501b6501d6501f6502265025650286502b650
010500003d6300f63038630156202f620116202c6200a62027620076202062002620156200b620036200062000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010002020610206101f6101f6101f6101f6101f6101f6101f6101f6101f6101f6101f6101f61020610206101f6101f6101f6102061020610206102061020610206101f610206102061020610216102161021610
001200200e1000e1001a6000e3000e1000e1001a6000e6000e1000e1001a6000e1001a1000e1001a6000e600112150e1001a6001f800132250e1001a6000e3000c2350c2001a615000000c2450c2451a6251a625
011200000e2550e2551a6351d9000e2550e2551a63518a000e2550e2551a635000000e2550e2551a6351f80011255112551a6351f80013255132551a6351c8000c2550c2551a635000000c2550c2551a6351a635
011200001a87515a551a8651ca551d9751ca551a865000001a87515a551a8651ca551d9751ca551a865000001d97518a55218651d9551fa751d9551c865000001fa751c855249651fa55218751fa551d9651c855
011200001a060150511a0601d052000001c0641a06218050210601d0501a06000000210601f052000001f0541d060210511d0601f052000001f0501d0601c05021060000001f060000001d060000001c06000000
011200001a0621a0621a0621a0621a0652b0001a0501c0501d0601d0651c0601c0651a0601a06518060180651606216062160651a0501a0501a0551c0501c0551f0601f0651d0601d0651c0601c0651a0601a065
0112000021060210651f0601f0651d0601d0651c0601c0652106021060210652206022060220651c0601c0651d0601d06521060210651a0001f0501d0501c05018060180601d0001d0001c000180501d0601c060
011200001a0601a0001a0601a6001a0601a6001a0601a6001ab601ac601ab601ac601ab601ac601ab601ac60180600e1001806002000180600e100180600e30018d6018e6018d6018e6018d6018e6018d6018e60
011200001a0601a0001a0601a6001a0601a6001a0601a6001ab601ac601ab601ac601ab601ac601ab601ac60180600e1001806002000180600e100180600e3001d0651d0601f0601d0601c0601a0601806015060
011200001d0621d0621d0622106121062210651d0621d0622206222062220622106221062210621d0621d0622406224065220622205521052210551f0521f0551d0621d0651c0621c0651a0621a0651806218065
012000001a87515a551a8651ca551d9751ca551a865000001a87515a551a8651ca551d9751ca551a865000001d97518a55218651d9551fa751d9551c865000001fa751c855249651fa55218751fa551d9651c855
002000000e2550e2551a6351d9000e2550e2551a63518a000e2550e2551a635000000e2550e2551a6351f80011255112551a6351f80013255132551a6351c8000c2550c2551a635000000c2550c2551a6351a635
012000001a030150211a0301d022000001c0341a03218020210301d0201a03000000210301f022000001f0241d030210211d0301f022000001f0201d0301c02021030000001f030000001d030000001c03000000
010c00001a075150551a0651c0551d0751c0551a065000051a075150551a0651c0551d0751c0551a065000051d07518055210651d0551f0751d0551c065000051f0751c055240651f055210751f0551d0651c055
010c00000e2450c2451a6450c6450e2450e2451a6450c6450e2450c2451a6450c6450e2450e2451a6450c64511245112451a6451a64513245132451a6451a6450c2450c2451a6451a6450c2450c2451a6451a645
010c00001a040150411a0401d042000001c0441a04218040210401d0401a04000000210401f042000001f0441d040210411d0401f042000001f0401d0401c04021040000001f040000001d040000001c04000000
010c00001a0501a0001a0501a6001a0501a6001a0501a6001ab501ac501ab501ac501ab501ac501ab501ac50180500e1001805002000180500e100180500e30018d5018e5018d5018e5018d5018e5018d5018e50
010c00001a0601a0001a0601a6001a0601a6001a0601a6001ab601ac601ab601ac601ab601ac601ab601ac60180600e1001806002000180600e100180600e30018b6018c6018b6018c6018b6018c6018b6018c60
010c00000e2450c2451a6450c6450e2450e2451a6450c6450e2450c2451a6450c6450e2450e2451a6450c64511245112451a6451a64513245132451a6451a6450c2450c2451a6451a64526635266353262532625
010c00001a0621a0621a0621a0621a0652b0001a0501c0501d0601d0651c0601c0651a0601a06518060180651606216062160651a0501a0501a0551c0501c0551f0601f0651d0601d0651c0601c0651a0601a065
010c000021060210651f0601f0651d0601d0651c0601c0652106021060210652206022060220651c0601c0651d0601d06521060210651a0001f0501d0501c05018060180601d0001d0001c000180501d0601c060
010c000021560215651f5601f5651d5601d5651c5601c5652156021560215652256022560225651c5601c5651d5601d56521560215651a5001f5501d5501c5501f5501f5501d5501d5501c5501c5501a5501a550
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
00 22 42 43 44
00 22 20 43 44
00 22 21 43 44
00 22 21 43 44
01 22 21 23 44
00 22 21 23 44
00 22 21 26 44
00 22 21 27 44
00 22 21 24 44
00 22 21 25 44
00 22 21 24 44
02 22 21 28 44
00 29 42 43 44
01 29 2a 43 44
02 29 2a 2b 44
00 2c 42 43 44
01 2c 2d 43 44
00 2c 2d 2e 44
00 2c 2d 2e 44
00 2c 2d 32 44
00 2c 2d 33 44
00 2c 2d 32 44
00 2c 2d 34 44
00 2c 2d 2f 44
00 2c 2d 30 44
00 2c 2d 2f 44
00 2c 2d 30 44
02 2c 31 34 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
