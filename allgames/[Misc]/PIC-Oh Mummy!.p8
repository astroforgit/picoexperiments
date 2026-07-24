pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- oh mummy pico8 remake
-- by hokutoy (adria estrades celma)
-- dedicated to axel, aina, mireia, eric i jan!

function _init()

_shex={["0"]=0,["1"]=1,
["2"]=2,["3"]=3,["4"]=4,["5"]=5,
["6"]=6,["7"]=7,["8"]=8,["9"]=9,
["a"]=10,["b"]=11,["c"]=12,
["d"]=13,["e"]=14,["f"]=15}
_pl={[0]="00000015d67",
     [1]="0000015d677",
     [2]="0000024ef77",
     [3]="000013b7777",
     [4]="0000249a777",
     [5]="000015d6777",
     [6]="0015d677777",
     [7]="015d6777777",
     [8]="000028ef777",
     [9]="000249a7777",
    [10]="00249a77777",
    [11]="00013b77777",
    [12]="00013c77777",
    [13]="00015d67777",
    [14]="00024ef7777",
    [15]="0024ef77777"}
_pi=0-- -100=>100, remaps spal
_pe=0-- end pi val of pal fade
_pf=0-- frames of fade left
function fade(from,to,f)
    _pi=from _pe=to _pf=f
end

	w=128
	h=128

	//para que el cofre se abra solo 1 vez
	ches1=0 ches2=0 ches3=0 ches4=0 ches5=0 ches6=0 ches7=0 ches8=0 ches9=0 ches10=0
	ches11=0 ches12=0 ches13=0 ches14=0 ches15=0 ches16=0 ches17=0 ches18=0 ches19=0 ches20=0

	music(1)
	sorteo=0
	p1={}
	p1.x=56
	p1.y=0
	p1.s=1
	p1.m=5
	p1.look=false
	frameskip=0
	click=0

	score=0
	topscore=0
	lives=5
	floor=1
	open=false 
	intro=true
	velocidad=1
	glevel=0
	topglevel=0
	mazmorra=0
	topmazmorra=0
	onlyone=0
	button=0
	buttonold=0
	scount=0
	cobrar=0
	
	
	
	
	tablero = {} // donde van las pisadas
	piramide = {}
	demons = {}
	dust = {}
	prize = {}
	

	ejex={0,24,48,72,96,120}
	ejey={16,40,64,88,112}

	
	//primera fila
	chest1 = {3,4,5,6,19,22,35,38,51,52,53,54}
	chest2 = {51,52,53,54,67,70,83,86,99,100,101,102}
	chest3 = {99,100,101,102,115,118,131,134,147,148,149,150}
	chest4 = {147,148,149,150,163,166,179,182,195,196,197,198}
	chest5 = {195,196,197,198,211,214,227,230,243,244,245,246}

	//segunda fila
	chest6 = {6,7,8,9,22,25,38,41,54,55,56,57}
	chest7 = {54,55,56,57,70,73,86,89,102,103,104,105}
	chest8 = {102,103,104,105,118,121,134,137,150,151,152,153}
	chest9 = {150,151,152,153,166,169,182,185,198,199,200,201}
	chest10= {198,199,200,201,214,217,230,233,246,247,248,249}

	//tercena fila
	chest11 = {9,10,11,12,25,28,41,44,57,58,59,60}
	chest12 = {57,58,59,60,73,76,89,92,105,106,107,108}
	chest13 = {105,106,107,108,121,124,137,140,153,154,155,156}
	chest14 = {153,154,155,156,169,172,185,188,201,202,203,204}
	chest15 = {201,202,203,204,217,220,233,236,249,250,251,252}

	//cuarta fila
	chest16 = {12,13,14,15,28,31,44,47,60,61,62,63}
	chest17 = {60,61,62,63,76,79,92,95,108,109,110,111}
	chest18 = {108,109,110,111,124,127,140,143,156,157,158,159}
	chest19 = {156,157,158,159,172,175,188,191,204,205,206,207}
	chest20 = {204,205,206,207,220,223,236,239,252,253,254,255}


 	
	
	palt (11,true) --color negro si
palt(0,false) -- color verde trans

level(0)
end
		
		
function level (l)

while click<200 do click+=1 end
//if fade(0,-100,32) -- a oscuro

fade(-100,0,32) -- a claro



	//lista de premios

for a in all(prize) do
				 del(prize,a)  end
prize = {"nada1","nada2","nada3","nada4","nada5","nada6","key","cofre","vida","demon","coin1","coin2","coin3","coin4","coin5","coin6","coin7","coin8","coin9","coin10"}


//glevel=l
--anular a false


//para que el cofre se abra solo 1 vez
	ches1=0 ches2=0 ches3=0 ches4=0 ches5=0 ches6=0 ches7=0 ches8=0 ches9=0 ches10=0
	ches11=0 ches12=0 ches13=0 ches14=0 ches15=0 ches16=0 ches17=0 ches18=0 ches19=0 ches20=0

--limpiamos tablas

for a in all(demons) do
				 del(demons,a)  end
for a in all(piramide) do
				 del(piramide,a)  end
for a in all(tablero) do
				 del(tablero,a)  end
-------------------------
	
-- el tablero se llena de pisadas
		for z=0,15 do
			ws=z+(z*7)
				for zy=0,15 do
					wy=zy+(zy*7)
				    pisadas(45,ws,wy)	
				end
	    end
---------------------------------
open=false
	
	
	


	if l==0 then intro=true glevel=0 
	if onlyone==3 then
		for a=1,3 do 
			mummy(ejex[flr(rnd(6)+1)],16,1)
			mummy(ejex[flr(rnd(6)+1)],16,0.5)
			mummy(ejex[flr(rnd(6)+1)],120,1)
			mummy(ejex[flr(rnd(6)+1)],120,0.5)
			//mummy(ejex[flr(rnd(6)+1)],120,0.7)
		 end
		end

		else intro=false	
		-- formula de creacion enemigos
		for a=1,l*(2+mazmorra) do enemy(ejex[flr(rnd(6)+1)],ejey[flr(rnd(5)+1)],flr(rnd(100)))	 end
	end

	

end

function polvo ()

	dust.x=p1.x-7
	dust.y=p1.y
	//anim(dust,60,4,6,false) 
	end

function shake ()

	if scount>0 then camera(rnd(5),rnd(5)) scount-=1 end 
	if scount==0 then camera() end
end

function sarcofago (qual,cuant)
	unlock=0
 	for a=1,cuant do
 		b=qual[a]	
 		if tablero[b].s!=45	then unlock=unlock+1   end
	end
 	
 	if unlock==cuant then 
 	
 		return true
 	end
end

function loteria (size,ta,tb,tc,td)
	spe=0
	sorteo=0
	if #prize==1 then sorteo=1 end
	while (sorteo==0) do
	sorteo=flr(rnd(#prize))
	end
	


	if prize[sorteo]=="key" then 
		sfx(10)
		if mazmorra==0 or mazmorra==4 then ai=136 bi=152 ad=137 bd=153 end
		if mazmorra==1 or mazmorra==5 then ai=204 bi=220 ad=205 bd=221 end
		if mazmorra==2 or mazmorra==6 then ai=168 bi=184 ad=169 bd=185 end
		if mazmorra==3 or mazmorra==7 then ai=238 bi=254 ad=239 bd=255 end
		
		open=true; 
		tablero[98].s=115
		sfx(13)
		
	end
	if prize[sorteo]=="cofre" then
		sfx(10) 
		if mazmorra==0 or mazmorra==4 then ai=134 bi=150 ad=135 bd=151 end
		if mazmorra==1 or mazmorra==5 then ai=202 bi=218 ad=203 bd=219 end
		if mazmorra==2 or mazmorra==6 then ai=166 bi=182 ad=167 bd=183 end
		if mazmorra==3 or mazmorra==7 then ai=236 bi=252 ad=237 bd=253 end
		
		score+=100 print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="vida" then 
		
		if mazmorra==0 or mazmorra==4 then ai=130 bi=146 ad=131 bd=147 end
		if mazmorra==1 or mazmorra==5 then ai=198 bi=214 ad=199 bd=215 end
		if mazmorra==2 or mazmorra==6 then ai=162 bi=178 ad=163 bd=179 end
		if mazmorra==3 or mazmorra==7 then ai=232 bi=248 ad=233 bd=249 end
		
		
		if lives>=10 then score+=250 scount=10 sfx(14) print (score, 76,1,10) print (score, 77,0,8) else sfx(10) lives+=1*(mazmorra+1) if lives>10 then lives=10 end end
	
	end
	
		if prize[sorteo]=="demon" then 
			sfx(11)
		
		if mazmorra==0 or mazmorra==4 then ai=140 bi=156 ad=141 bd=157 end
		if mazmorra==1 or mazmorra==5 then ai=128 bi=144 ad=129 bd=145 end
		if mazmorra==2 or mazmorra==6 then ai=160 bi=176 ad=161 bd=177 end
		if mazmorra==3 or mazmorra==7 then ai=174 bi=190 ad=175 bd=191 end
						
		if p1.x<60 then xm=120 else xm=0 end
		if p1.y<60 then ym=112 else ym=16 end
				mummy(xm,ym,1)
				mummy(xm,ym,0.3)
				mummy(xm,ym,0.5)
	end
	
	if prize[sorteo]=="coin1" then 

		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
		
	end
	if prize[sorteo]=="coin2" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin3" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	
	end
	if prize[sorteo]=="coin4" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin5" then 
	
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin6" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin7" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin8" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin9" then 
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="coin10" then 
		
		if mazmorra==0 or mazmorra==4 then ai=132 bi=148 ad=133 bd=149 end
		if mazmorra==1 or mazmorra==5 then ai=200 bi=216 ad=201 bd=217 end
		if mazmorra==2 or mazmorra==6 then ai=164 bi=180 ad=165 bd=181 end
		if mazmorra==3 or mazmorra==7 then ai=234 bi=250 ad=235 bd=251 end
		score+=10 sfx(4) print (score, 76,1,10) print (score, 77,0,8)
	end
	if prize[sorteo]=="nada1" then 
		if mazmorra==0 or mazmorra==4 then ai=138 bi=154 ad=139 bd=155 end
		if mazmorra==1 or mazmorra==5 then ai=206 bi=222 ad=207 bd=223 end
		if mazmorra==2 or mazmorra==6 then ai=170 bi=186 ad=171 bd=187 end
		if mazmorra==3 or mazmorra==7 then ai=142 bi=158 ad=143 bd=159 end
		sfx(8)
	end
	if prize[sorteo]=="nada2" then 
		
		if mazmorra==0 or mazmorra==4 then ai=138 bi=154 ad=139 bd=155 end
		if mazmorra==1 or mazmorra==5 then ai=206 bi=222 ad=207 bd=223 end
		if mazmorra==2 or mazmorra==6 then ai=170 bi=186 ad=171 bd=187 end
		if mazmorra==3 or mazmorra==7 then ai=142 bi=158 ad=143 bd=159 end
		sfx(8)
	end
	if prize[sorteo]=="nada3" then 
		
		if mazmorra==0 or mazmorra==4 then ai=138 bi=154 ad=139 bd=155 end
		if mazmorra==1 or mazmorra==5 then ai=206 bi=222 ad=207 bd=223 end
		if mazmorra==2 or mazmorra==6 then ai=170 bi=186 ad=171 bd=187 end
		if mazmorra==3 or mazmorra==7 then ai=142 bi=158 ad=143 bd=159 end
		sfx(8)
	end
	if prize[sorteo]=="nada4" then 
		
		if mazmorra==0 or mazmorra==4 then ai=138 bi=154 ad=139 bd=155 end
		if mazmorra==1 or mazmorra==5 then ai=206 bi=222 ad=207 bd=223 end
		if mazmorra==2 or mazmorra==6 then ai=170 bi=186 ad=171 bd=187 end
		if mazmorra==3 or mazmorra==7 then ai=142 bi=158 ad=143 bd=159 end
		sfx(8)
	end
	if prize[sorteo]=="nada5" then 
		
		if mazmorra==0 or mazmorra==4 then ai=138 bi=154 ad=139 bd=155 end
		if mazmorra==1 or mazmorra==5 then ai=206 bi=222 ad=207 bd=223 end
		if mazmorra==2 or mazmorra==6 then ai=170 bi=186 ad=171 bd=187 end
		if mazmorra==3 or mazmorra==7 then ai=142 bi=158 ad=143 bd=159 end
		sfx(8)
	end
	if prize[sorteo]=="nada6" then 
		
		if mazmorra==0 or mazmorra==4 then ai=138 bi=154 ad=139 bd=155 end
		if mazmorra==1 or mazmorra==5 then ai=206 bi=222 ad=207 bd=223 end
		if mazmorra==2 or mazmorra==6 then ai=170 bi=186 ad=171 bd=187 end
		if mazmorra==3 or mazmorra==7 then ai=142 bi=158 ad=143 bd=159 end
		sfx(8)
	end
	


	tablero[ta].s=ai 
	tablero[tb].s=bi
	if size==4 then 
		tablero[tc].s=ad 
		tablero[td].s=bd 
	end	
		
	del(prize,prize[sorteo])
	return
end

-- decide para donde ir
function padonde(a,direc)

		//for a in all(demons) do
			// si te pillan una vida menos
				if collide(a,p1) then scount=5 lives-=1 sfx(3)
				 del(demons,a)  end
				
			//end

		indeciso=flr(rnd(100))
		//vertical
		if a.x==0 or a.x==24 or a.x==48 or a.x==72 or a.x==96 or a.x==120 then
			
			if direc<=10 then
			a.d=3
			a.y+=a.s end
			if direc>=10 and direc<=20 then
			a.d=2
			a.y-=a.s end
			end
		
		//horizontal
		if a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112 then
			
			if direc>=20 and direc<=30 then
			a.d=0
			a.x-=a.s end
			if direc>=30 and direc<=40 then
			a.d=1
			a.x+=a.s end
		end
		
		if a.x<0 then a.x=0 end
		if a.x>120 then a.x=120 end
		if a.y<16 then a.y=16 end
		if a.y>112 then a.y=112 end
		
		if indeciso>50 then
		if a.x==0 and ( a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112) then a.dire=flr(rnd(100)) end
		if	a.x==24 and ( a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112) then a.dire=flr(rnd(100)) end
		if	a.x==48 and ( a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112) then a.dire=flr(rnd(100)) end
		if	a.x==72 and ( a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112) then a.dire=flr(rnd(100)) end
		if	a.x==96 and ( a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112) then a.dire=flr(rnd(100)) end
		if	a.x==120 and ( a.y==16 or a.y==40 or a.y==64 or a.y==88 or a.y==112) then a.dire=flr(rnd(100)) end
		end
	end
	
	
	
//	end

-- dibuja pisadas

function pisadas(s,x,y)
	a={}
	a.x=x
	a.y=y
	a.t=false

	
		if(s~=a.s) then a.s=s	 end
	
	if p1.y<=8 then a.s=45 end
	

	
	if (flr(p1.x/8)==p1.x/8) and (flr(p1.y/8)==p1.y/8)  then
	add(tablero,a)  
	return a
	end
	
	end

function enemy(x,y,dire)
 
 
 b=rnd(30)
 if b<10 then c=0.1 end
 if b>10 and b<20 then c=0.3 end
 if b>20 and b<30 then c=0.5 end
	
	a={}
	a.x=x
	a.y=y
	a.s=c
	a.m=5
	a.ms=0
	a.d=0
	a.dire=dire
	
	add (demons,a) //return a
	end

function mummy(x,y,vel)
 
 

 
 
	
	a={}
	a.x=x
	a.y=y
	a.s=vel
	a.m=8
	a.ms=0
	a.d=0
	
	add (piramide,a) return a
	end
	
	
	
function apply_ramp_fade(ramp, proportion)
	pal()
	for color = 0, 15 do
		local colorramp = ramp[color + 1]
		local slot = flr(#colorramp * proportion + 1)
		pal(color, colorramp[slot], 1)
	end  
end

function _update60()

	shake()
	click+=1 if click>=200 then click=0 end
	
	if (open==true and collide (tablero[241],p1) or lives==0) or (btn(4) and intro==true and onlyone==3) then p1.x=-10 
		onlyone=4
		fade(0,-100,36)
		if lives>0 then sfx(6)  glevel+=1 else sfx(9) end
		if glevel==6 then glevel=1 mazmorra+=1 cobrar=1 end -- sfx(14) score+=mazmorra*500 print (score, 76,1,10) print (score, 77,0,8)
		if lives==0 then 
			if topscore<score then topscore=score topglevel=glevel topmazmorra=mazmorra end
			glevel=0 mazmorra=0 lives=5 p1.x=56 p1.y=64 
			score=0 onlyone=2
		else 
				p1.x=0
				p1.y=0
				p1.look=false
		end
		level(glevel)  
	end
	if #prize==0 then scount=10 sfx(14) score+=250 print (score, 76,1,10) print (score, 77,0,8) add(prize,"relleno") end
	 // pone reja al final nivel
	 if open==true and p1.y<8 then tablero[241].s=127 end
	
		drw()
	--escalera
	if not intro then tablero[209].s=45 else 

		if (onlyone==1 and btn(5)) then  fade(0,-100,32) fade(-100,0,32) sfx(4) onlyone=2 end
		if (onlyone==0 and btn(4)) then  fade(0,-100,32) fade(-100,0,32) sfx(4) onlyone=1 end
	
		if onlyone==3 then	

			print ("highscore:", 13,1,8)
			print ("highscore:", 13,0,7)
				print (topscore, 53,1,5)
				print (topscore, 53,0,7)
			
			print ("tomb:", 76,1,8)
			print ("tomb:", 76,0,7)
			
			print ("-", 101,1,5)
			print ("-", 101,0,7)
				
				
				print (topglevel, 106,1,5)
				print (topglevel, 106,0,7)
				
				print (topmazmorra+1, 97,1,5)
				print (topmazmorra+1, 97,0,7)
		end
	end
	
	// ponemos los corazones de vida
	
		if lives<0 then lives=0 end
	if not intro then
	
		if lives>0 and p1.y>8 then tablero[1].s=172 else if not open then tablero[1].s=99 else tablero[1].s=45 end end
		
		if  p1.y>8 then
			if lives>1 then tablero[17].s=172 else tablero[17].s=173 end
			if lives>2 then tablero[33].s=172 else tablero[33].s=173 end
			if lives>3 then tablero[49].s=172 else tablero[49].s=173 end
			if lives>4 then tablero[65].s=172 else tablero[65].s=173 end

			if lives>5 then tablero[1].s=188 end
			if lives>6 then tablero[17].s=188 end
			if lives>7 then tablero[33].s=188 end
			if lives>8 then tablero[49].s=188 end
			if lives>9 then tablero[65].s=188 end
			if lives>10 then tablero[65].s=188 end
		else
			tablero[17].s=45 
			tablero[33].s=45 
			tablero[49].s=45 
			tablero[65].s=45  

		end
	
	end
	
		
		--if open==true then tablero[98].s=115 else if intro==true then tablero[98].s=45 else tablero[98].s=57  if cobrar==1 and p1.y>17 then sfx(14) score+=mazmorra*500 print (score, 76,1,10) print (score, 77,0,8) cobrar=0 end end end
		if open==true then tablero[98].s=115 else if intro==true then tablero[98].s=45 else tablero[98].s=57   end end
		
		if (open==false and p1.y<16  and onlyone>2) then tablero[98].s=115 end
		if p1.y==14 and not open then sfx(13) end
	pupd(p1)
	for a in all(demons) do
		
		padonde(a,a.dire)
		
	end
	for a in all(piramide) do
		eupd(a,p1)
	end
	
	
	
	frameskip=frameskip+1
if frameskip==20 then frameskip=0
	if p1.y>=16 or p1.y<=40 then 
			// primera fila
			if sarcofago(chest1,10)==true and ches1==0 then
			ches1=1
			loteria (4,20,21,36,37)
			end
			if sarcofago(chest2,12)==true and ches2==0 then
			ches2=1
			loteria (4,68,69,84,85)
			end
			if sarcofago(chest3,12)==true and ches3==0 then
			ches3=1
			loteria (4,116,117,132,133)
			end
			if sarcofago(chest4,12)==true and ches4==0 then
			ches4=1
			loteria (4,164,165,180,181)
			end
			if sarcofago(chest5,10)==true and ches5==0 then
			ches5=1
			loteria (4,212,213,228,229)
			end
	end

	if p1.y>=40 or p1.y<=64 then	
			// segunda fila
			if sarcofago(chest6,10)==true and ches6==0 then
			ches6=1 loteria (4,23,24,39,40)
			end
			if sarcofago(chest7,12)==true and ches7==0 then
			ches7=1 loteria (4,71,72,87,88)
			end
			if sarcofago(chest8,12)==true and ches8==0 then
			ches8=1 loteria (4,119,120,135,136)
			end
			if sarcofago(chest9,12)==true and ches9==0 then
			ches9=1 loteria (4,167,168,183,184)
			end
			if sarcofago(chest10,10)==true and ches10==0 then
			ches10=1 loteria (4,215,216,231,232)
			end
	end
	
	if p1.y>=64 or p1.y<=88 then
			// tercera fila
			if sarcofago(chest11,10)==true and ches11==0 then
				ches11=1 loteria (4,26,27,42,43)
			end
			if sarcofago(chest12,12)==true and ches12==0 then
				ches12=1 loteria (4,74,75,90,91)
			end
			if sarcofago(chest13,12)==true and ches13==0 then
				ches13=1 loteria (4,122,123,138,139)
			end
			if sarcofago(chest14,12)==true and ches14==0 then
				ches14=1 loteria (4,170,171,186,187)
			end
			if sarcofago(chest15,10)==true and ches15==0 then
				ches15=1 loteria (4,218,219,234,235)
			end
		end
end
	if p1.y>=88 or p1.y<=112 then
			// cuarta fila
			if sarcofago(chest16,10)==true and ches16==0 then
				ches16=1 loteria (4,29,30,45,46)
			end
			if sarcofago(chest17,12)==true and ches17==0 then
				ches17=1 loteria (4,77,78,93,94)
			end
			if sarcofago(chest18,12)==true and ches18==0 then
				ches18=1 loteria (4,125,126,141,142)
			end
			if sarcofago(chest19,12)==true and ches19==0 then
				ches19=1 loteria (4,173,174,189,190)
			
			end
			if sarcofago(chest20,10)==true and ches20==0 then
				ches20=1 loteria (4,221,222,237,238)
			
			end
		end
		
			if(_pf>0) then --pal fade
    if(_pf==1) then _pi=_pe
    else _pi+=((_pe-_pi)/_pf) end
    _pf-=1
end

	
	end

function drw()

	
	
			
	conta = rnd (50)
	if(conta<10) then 
	luck = rnd(2) else luck=2 end

	cls() 
	if cobrar==1 and p1.y>17 then scount=10 sfx(14) score+=mazmorra*500 print (score, 76,1,10) print (score, 77,0,8) cobrar=0 end


	if intro==true then 
		-- credits
		-- pantalla intro oh mummy
		if onlyone==2 then 
			for a=1,3 do 
				mummy(ejex[flr(rnd(6)+1)],16,1)
				mummy(ejex[flr(rnd(6)+1)],16,0.5)
				mummy(ejex[flr(rnd(6)+1)],120,1)
				mummy(ejex[flr(rnd(6)+1)],120,0.5)
			end 
			p1.x=56 p1.y=64 onlyone=3 end 
		if onlyone==3 then map(16,0,0,0,16,16) end 
		--credits
		if onlyone==0 then
			print ("pic-oh mummy!",39,1,4)
			print ("pic-oh mummy!",39,0,9)

			print ("code + graphics",34,21,1)
			print ("code + graphics",34,20,12)

			print ("hokutoy (aka adria estrades)",09,28,2)
			print ("hokutoy (aka adria estrades)",09,27,14)

			print ("music 'the streets of cairo'",09,41,1)
			print ("music 'the streets of cairo'",09,40,12)

			print ("tyroney",49,48,2)
			print ("tyroney",49,47,14)

			print ("awesome runing mario animation",04,61,1)
			print ("awesome runing mario animation",04,60,12)
			print ("and aditional gfx taken from",08,68,1)
			print ("and aditional gfx taken from",08,67,12)

			print ("johan vinet",42,75,2)
			print ("johan vinet",42,74,14)

			print ("some snippets sounds and sprites",00,88,1)
			print ("some snippets sounds and sprites",00,87,12)
			print ("http://www.lexaloffle.com/bbs/ ",3,95,2)
			print ("http://www.lexaloffle.com/bbs/",3,94,14)

			print ("dedicated to my future son",12,108,1)
			print ("dedicated to my future son",12,107,12)
			print ("axel",57,115,5)
			print ("axel",57,114,6)

			
		end
		-- howto
		if onlyone==1 then
			map(34,0,0,0,16,16)

			print ("how to play",44,1,4)
			print ("how to play",44,0,9)

			print ("10",12,66,5)
			print ("10",12,65,7)
			print ("100",34,66,5)
			print ("100",34,65,7)

			print ("extra points",39,79,4)
			print ("extra points",39,78,9)
			
			print ("overheal +10  :",19,91,8)
			print ("overheal +10  :",19,90,7)
			print ("250",93,91,5)
			print ("250",93,90,7)
			print ("unlock all level:",19,101,8)
			print ("unlock all level:",19,100,7)
			print ("250",93,101,5)
			print ("250",93,100,7)
			print ("finish tomb:      x lv tomb",9,111,8)
			print ("finish tomb:      x lv tomb",9,110,7)
			print ("500",63,111,5)
			print ("500",63,110,7)

		
		end	

		
	else 
		if mazmorra==0 or mazmorra==4 then map(0,0,0,0,16,16) 
		elseif mazmorra==1 or mazmorra==5 then map(16,16,0,0,16,16) 
		elseif mazmorra==2 or mazmorra==6 then map(0,16,0,0,16,16) 
		elseif mazmorra==3 or mazmorra==7 then map(32,16,0,0,16,16)
		end
		
	end

	
	
	for a in all(tablero) do
		
		spr(a.s,a.x,a.y)
	end
	
	
	
	if not intro then
		
		if p1.y>8 then
		//print ("lives:", 5,0,10)
		//print (lives, 30,0,9)
		
		
		print ("score:", 48,1,8)
		print ("score:", 48,0,7)
		
		print (score, 75,1,5)
		print (score, 75,0,7)
		
		print ("tomb:", 94,1,8)
		print ("tomb:", 94,0,7)
		
		print ("-", 119,1,5) 
		print ("-", 119,0,7)

		print (glevel, 124,1,5)
		print (glevel, 124,0,7)
		print (mazmorra+1, 115,1,5)
		print (mazmorra+1, 115,0,7)
	end

	else
		if onlyone==3 then
		print("by hokutoy",44,77,4)
		print("by hokutoy",44,76,10)
	end
	
end
	
	
if onlyone>2 then
	if btn(0)  then
				// polvo()
				buttonold=1
				
				p1.look=true
				for a in all(tablero) do
					if p1.y>8 and collide(a,p1) then a.s=31 end
				end		
				
				anim (p1,3,6,10,true)
				
	elseif btn(1) then
				buttonold=2
				// polvo()
				p1.look=false
				
				for a in all(tablero) do
					if p1.y>8 and collide(a,p1) then a.s=14 end
				end
			 anim (p1,3,6,10,false)
	--up
	elseif btn(2)  then
				buttonold=3
				 //polvo()	
	   				//if (open==false and p1.x==48 and p1.y<=15) then p1.y=16 end 
	   				for a in all(tablero) do
					if p1.y>8 and collide(a,p1) then a.s=15 end
					end
			 anim(p1,32,6,10,p1.look)
	--down
	elseif btn(3) then
				buttonold=4
				// polvo()
				for a in all(tablero) do
					if p1.y>8 and collide(a,p1) then a.s=30 end
				end
				anim(p1,16,6,10,p1.look) 
	else
			
			spr(luck,p1.x,p1.y,1,1,p1.look,false)

	end
end
	if button!=buttonold then sfx(12) polvo()  button=buttonold end

	if (open==false and p1.x==48 and p1.y==15) then p1.y=16 end 
for a in all(piramide)  do	
 if a.d==0 then 	anim(a,80,3,6,true)
  elseif a.d==1 then 	anim(a,80,3,6,false)
	 elseif a.d==2 then 	anim(a,64,3,6,false)
	 elseif a.d==3 then 	anim(a,67,3,6,false)
 end
end
 for a in all(demons)  do	
 if a.d==0 then 	anim(a,208,3,6,true)
  elseif a.d==1 then 	anim(a,208,3,6,false)
	 elseif a.d==2 then 	anim(a,192,3,6,false)
	 elseif a.d==3 then 	anim(a,195,3,6,false)
 end
end

	local pix=6+flr(_pi/20+0.5)
if(pix!=6) then
    for x=0,15 do
        pal(x,_shex[sub(_pl[x],pix,pix)],1)
    end
else pal() palt (11,true) --color negro si
 palt(0,false) -- color verde trans
end

	
end

function colm(fx,tx,fy,ty)
	alargo=0
	if intro then alargo=16 else alargo=0 end
	local a=fget(mget((fx/8)+alargo,fy/8),0)
	local b=fget(mget((fx/8)+alargo,ty/8),0)
	local c=fget(mget(tx/8,ty/8),0)
	local d=fget(mget(tx/8,fy/8),0)
	local e=fx<0 or fx+8>w
	local f=fy<0 or fy+8>h
	return (a or b or c or
         d or e or f)


end

	

function collide(obj, other)
    if
      (other.x+1+2>obj.x+1) and 
      (other.y+1+2>obj.y+1) and
      (other.x+1<obj.x+1+2) and
      (other.y+1<obj.y+1+2)
   	   then
       return true
    end
end

function pupd(p)
	local c
	local lx=p.x -- last x
	local ly=p.y -- last y

	if(btn(0)) then p.x-=p.s 
	elseif(btn(1)) then p.x+=p.s 
	elseif(btn(2)) then p.y-=p.s  
	elseif(btn(3)) then p.y+=p.s  
	end 

	-- collision, move back
	c=colm(p.x,p.x+7,p.y,p.y+7)
	if(c) p.x=lx p.y=ly

	-- no collision, set moving dir
	if(p.x<lx) p.m=0
	if(p.x>lx) p.m=1
	if(p.y<ly) p.m=2
	if(p.y>ly) p.m=3

	-- collision, move in last dir
	if(c) then
		if(p.m==0) p.x-=p.s
		if(p.m==1) p.x+=p.s
		if(p.m==2) p.y-=p.s
		if(p.m==3) p.y+=p.s
	end

	c=colm(p.x,p.x+7,p.y,p.y+7)
	if(c) p.x=lx p.y=ly
end

function eupd(e,t)
	e.ms+=e.s

	// cohque entre enemigos

		//for a in all(piramide) do
			// si te pillan una vida menos
	if collide(e,p1) then lives-=1 scount=5 sfx(3) del(piramide,e)  end
				//if e!=a and collide(e,a) then del(piramide,e) del(piramide,a) end
			//end

		
	
	// fin choque entre

	if(flr(e.ms)==1) then
		local ex=e.x
		local ey=e.y
		local em=e.m
		local tx=t.x
		local ty=t.y
		local cl=colm(ex-1,ex-1,ey,ey+7)
		local cr=colm(ex+8,ex+8,ey,ey+7)
		local ct=colm(ex,ex+7,ey-1,ey-1)
		local cb=colm(ex,ex+7,ey+8,ey+8)
		local ld=dst(ex-4,tx+4,ey+4,ty+4)
		local rd=dst(ex+11,tx+4,ey+4,ty+4)
		local td=dst(ex+4,tx+4,ey-4,ty+4)
		local bd=dst(ex+4,tx+4,ey+11,ty+4)
		local lo=not cl and em!=1
		local ro=not cr and em!=0
		local to=not ct and em!=3
		local bo=not cb and em!=2
		local sd=w

		if(lo)           sd=ld em=0
		if(ro and rd<sd) sd=rd em=1
		if(to and td<sd) sd=td em=2
		if(bo and bd<sd) em=3

		if(em==0) e.x-=1 e.d=0 
		if(em==1) e.x+=1 e.d=1 
		if(em==2) e.y-=1 e.d=2 
		if(em==3) e.y+=1 e.d=3 

		e.m=em
		e.ms=0
	end
end

function dst(fx,tx,fy,ty)
 return sqrt((fx-tx)^2+(fy-ty)^2)
end

--object, start frame,
--num frames, speed, flip
function anim(o,sf,nf,sp,fl)
	if(not o.a_ct) then o.a_ct=0 end
	if(not o.a_st)	then o.a_st=0 end

	o.a_ct+=2

	if(o.a_ct%(30/sp)==0) then
		o.a_st+=1
		if(o.a_st==nf) then o.a_st=0 
	 		//if o==p1 then sfx(7) end
	 		if o==dust then o.x=0 end
		end
	end
	o.a_fr=sf+o.a_st
	spr(o.a_fr,o.x,o.y,1,1,fl)
end



if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
bbb8887bbbb8887bbbb8887bbbb8878bbbb8878bbbb8887bbbb8887bbbb8887bbbb8887b4999999999999994999999994999999999999994bbbbbbbbbb55bbbb
bbb88888bbb88888bbb88888bbb88888bbb88888bbb88888bbb88888bbb88888bbb888884499999999999947999999994499999999999947bbbbbbbbbb55bbbb
bb4f40fbbb4f4ffbbb4f40fbbbf40f0bbbf40f0bbb4f40fbbb44f40bbb44f40bbb4f40fb444aaaaaaaaaa477aaaaaaaa444aaaaaaaaaa4776b55bbbbbbbbbbbb
bb4ff44fbb4ff44fbb4ff44fbbff44f4bbff44f4bb4ff44fbb44ff44bb44ff44bb4ff44f44a9999999999a779999999944acccccccccca77bb55bbbbbb6bbbbb
bbb4fffbbbb4fffbbbb4fffbbbbffffbb88ffffbbbb4fffbbbb44ffbbbb44ffbbbb4fffb44a9999999999a779999999944accc0000ccca77bbbbbb55bbbb55bb
b88acc9bb88acc9bb88acc9bb88acc9b7b8acc97bb88ac1bbbc88a1bbbc88a17bb88ac1b44a9999999999a779999999944acc09aaa0cca77bbbb6b55bbbb55bb
7bcccc167bcccc167bcccc167bcccc16b2cccc1bbb87cc1bbbcc887bb4cc888bbb87cc1b44a9999999999a779999999944ac09a70aa0ca77bbbbbbbbbbbbbbbb
bb4bb2bbbb4bb2bbbb4bb2bbbb4bb2bbbbbbbb4bbbb4b2bbbb4bb2bbbbbbbb2bbbb442bb44a9999999999a779999999944ac09a70aa0ca77bbbbbbbbbbbbb6bb
bb8778bbbb8778bbbb8778bbbb8778bbbb8778bbbb8778bb0000000079999999bbbbbbbb44a9999999999a779999999944ac09a70aa0ca77bb6bbbbbbbbbbbbb
bb8888bbbb8888bbbb8888bbbb8888bbbb8888bbbb8888bb000000007aaaaaa97777077744a9999999999a779999999944ac09a00aa0ca77bbbbbbbbbbbbbbbb
b40ff04bb40ff04bb40ff04bb40ff04bb40ff04bb40ff04b00000000777777790077077044a9999999999a779999999944acc09aaa0cca77bb55bbbbbbbb55b6
b4f44f4bb4f44f4bb4f44f4bb4f44f4bb4f44f4bb4f44f4b00000000000000000077077044a9999999999a779999999944accc0000ccca77bb55bbbbbbbb55bb
bb4ff4bbbb4ff4bbbb4ff4bbbb4ff4bbbb4ff4bbbb4ff4bb00000000799999990700077044a9999999999a779999999944acccccccccca77bbbbb6bb55bbbbbb
b8acc91bb8acc91bb8acc91bb8acc91bb8acc91bb8acc91b000000007aaaaaa977000770444aaaaaaaaaa477aaaaaaaa444aaaaaaaaaa477bbbbbbbb55b6bbbb
b7cccc7bbb7ccc7bbb7cccb7b7cccc7b7bccc7bbb7ccc7bb00000000777777777007077044aaaaaaaaaaaa47aaaaaaaa44aaaaaaaaaaaa47bbbb55bbbbbbbbbb
bb4bb2bbbb4bb2bbbb4bbbbbbb4bb2bbbbbbb2bbbb4bb2bb0000000000000000777707774aaaaaaaaaaaaaa4aaaaaaaa4aaaaaaaaaaaaaa4bbbb55bbbbbbbbbb
bb8888bbbb8888bbbb8888bbbb8888bbbb8888bbbb8888bb09a70000999099990000000099909999999099999990999900000000bbbbbbbbbbbbbbbbbbbbbbbb
bb8888bbbb8888bbbb8888bbbb8888bbbb8888bbbb8888bb09a70777aa907aaa0777777aaa907aa97a907aaa7a907aaa00000000bbbbbbbb0777077777077777
b444444bb444444bb444444bb444444bb444444bb444444b099a09a777a0777707aaaaa977a0777777a0777777a0777700000000bbbbbbbb7777077077077077
b444444bb444444bb444444bb444444bb444444bb444444b000009a7000000000799999900000000000000000000000000000000bbbbbbbb0077077077077077
bb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bb097709a7079999990000000007999999799999997999999900000000bbbbbbbb0077077077077077
b1cccc8bb1cccc8bb1cccc8bb1cccc8bb1cccc8bb1cccc8b09a709a707aaaaa977a0777707aaaaa97aaaaaa97aaaaaa900000000bbbbbbbb0077077077077077
b7cccc7bb7ccccbb7bccc4bbb7cccc7bbb2cccb7bbcccc7b09a709a70777777aaa907aaa0777777a7777777a7777777a00000000bbbbbbbb0077077077077077
bb2bb4bbbb2bb4bbbb2bbbbbbb2bb4bbbbbbb4bbbb2bb4bb09a7099a000000009990999900000000000000000000000000000000bbbbbbbb0077077777077777
000000000000000000000000bbbbbbbb000000000777099999990777000007a909a7099ab666676b000007a900000000bbbbbbbbbbbbbbbbbbbbbbbb7b6bbbbb
0000000000000000000000006bbbbbb60000000007a907aaaaa709a7077707a909a7000060600606077707a97777777abbbbbbbbb6bb66bbb6bb6bbbb6bb7bbb
0000000000000000000000007bbbbbb60000000007a90777777709a707a907a909a707777667666607a90a997aaaaaa9bbbb7bbbbbbb7bbbbb7b7bbbb77bbbbb
0000000000000000000000006bbbbbb70000000007a90000000009a707a90777077709a76060060707a9000079999999bbbbbb7bbbb6bb7b7bb6bb7b7bb6bbbb
0000000000000000000000006bbbbbb60000000007a90779097709a707a90000000009a76666676607a9077900000000bbbbbbb6bbbbb7b6bbbbb7bbbbbbbbbb
0000000000000000000000006bbbbbb60000000007a907a909a709a707a90777777709a76060060607a907a977a07777bbbbb6bbbbb7b67b7b77b6bb7bbbbbbb
0000000000000000000000007bbbbbb60000000007a907a909a709a707a907aaaaa709a77666766607a907a9aa907aaabbbbbbbbbbbb7bbbbbbb7bbbbbbbbbbb
000000000000000000000000bbbbbbbb000000000a9907a909a7099a0a99079999970997bbbbbbbb099907a999909999bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
5b888b5b5b888b5bb5b888b55b888b5b5b888b5bb5b888b522202222000000002eeeeeeeeeeeeee25550555500000000d66666666666666dbbbbbbbbbbbbbbbb
5888885b5888885bb58888855888885b5888885bb5888885ee207eee0777777e22eeeeeeeeeeee276650766607777776dd666666666666d7bbbbbbbbbbbbbbbb
b88888bbb88888bbbb88888bb8a8a8bbb8c8c8bbbb81818b77e0777707eeeee2222ffffffffff2777760777707666665ddd5555555555d77bbbbbfebfebbbbbb
bb888bb22b888bbb2bb888bbbb828bbbbb828bbbbbb828bb000000000722222222feeeeeeeeeef770000000007555555dd56666666666577bbbbfeefee2bbbbb
b288812b22888122b218882bb2888122b288812b2218882b072222220000000022feeeeeeeeeef770755555500000000dd56666666666577bbbbeeeeee2bbbbb
2b122bbbbb222bb2bbb221b22b122bbb2b222bb2bbb221b207eeeee277e0777722feeeeeeeeeef770766666577607777dd56666666666577bbbbbeeee2bbbbbb
bb288bbbbb282bbbbbb882bbbb288bbbbb282bbbbbb882bb0777777eee207eee22feeeeeeeeeef770777777666507666dd56666666666577bbbbbbee2bbbbbbb
bbbb22bbb22b22bbbb22bbbbbbbb22bbb22b22bbbb22bbbb000000002220222222feeeeeeeeeef770000000055505555dd56666666666577bbbbbbb2bbbbbbbb
5b288b5b5b288b5b5b288b5bbbbb5b288b5bbbbb00000000222022220000000022feeeeeeeeeef775550555500000000dd56666666666577bfebfebb00000000
5288885b5288885b5288885bbbbb5288885bbbbb000000007e207eee7777777e22feeeeeeeeeef777650766677777776dd56666666666577feefee2b00000000
b28a8abbb28c8cbbb28181bbbbbbb28a8abbbbbb0000000077e077777eeeeee222feeeeeeeeeef777760777776666665dd56666666666577eeeeee2b00000000
bbb828bbbbb828bbbbb828bbbbbbbbb828bbbbbb00000000000000007222222222feeeeeeeeeef770000000075555555dd56666666666577beeee2bb00000000
b2888122b288812b2288812bbbbbb2888122bbbb00000000722222220000000022feeeeeeeeeef777555555500000000dd56666666666577bbee2bbb00000000
b2122bbb2b122bb2bb122b2bbbbbb2122bbbbbbb000000007eeeeee277e07777222ffffffffff2777666666577607777ddd5555555555d77bbb2bbbb00000000
bb2882bbbb288bbbb2288bbbbbbbbb2882bbbbbb000000007777777eee207eee22ffffffffffff277777777666507666dd555555555555d7bbbbbbbb00000000
b2bbbbbbb2bbb2bbbbbbb2bbbbbbb2bbbbbbbbbb0000000000000000222022222ffffffffffffff20000000055505555d55555555555555dbbbbbbbb00000000
00000000000000000000000055555555000000000000000011101111000000005cccccccccccccc544a9999999999a7799999999000000000000000044a99990
000000000000000000000000556000050000000000000000cc107ccc0777777c55cccccccccccc5744a9999999999a7799999999000000000000000044a99990
00000000000000000000000055656005000000000000000077c0777707ccccc1555111111111157744a9999999999a7799999999000000000000000044a99990
0000000000000000000000005565656500000000000000000000000007111111551cccccccccc17744a9999999999a7799999999000000000000000044a99990
0000000000000000000000005565656500000000000000000711111100000000551cccccccccc17744a9999999999a7799999999000000000000000044a99990
00000000000000000000000055656565000000000000000007ccccc177c07777551cccccccccc17744a9999999999a7799999999000000000000000044a99990
0000000000000000000000005565656500000000000000000777777ccc107ccc551cccccccccc17744a9999999999a7799999999000000000000000044a99990
0000000000000000000000005555555500000000000000000000000011101111551cccccccccc17744a9999999999a7799999999000000000000000044a99990
0000000000000000000000006000000600000000000000001110111100000000551cccccccccc1770000000044a9999444a99999000000090000000055555555
0000000000000000000000006000000600000000000000007c107ccc7777777c551cccccccccc1779999999944a9999444a99999999999990000000055600005
00000000000000000000000060000006000000000000000077c077777cccccc1551cccccccccc1779999999944a9999444a99999999999990000000055656005
0000000000000000000000006000000600000000000000000000000071111111551cccccccccc1779999999944a9999444a99999999999990000000055656565
0000000000000000000000006000000600000000000000007111111100000000551cccccccccc1779999999944a9999444a99999999999990000000055656565
0000000000000000000000006000000600000000000000007cccccc177c0777755511111111115779999999944a9999944a99999999999990000000055656565
0000000000000000000000006000000600000000000000007777777ccc107ccc55111111111111579999999944a9999944a99999999999990000000055656565
000000000000000000000000000000000000000000000000000000001110111151111111111111159999999944a9999944a99999999999990000000055555555
d66666666666666d4999999999999994499999999999999449999999999999944999999999999994499999999999999449999999999999945cccccccccccccc5
dd666666666666d744999999999999474499999999999947449999999999994744999999999999474499999999999947449999999999994755cccccccccccc57
ddd5555555555d77444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa4775551111111111577
dd5888888888857744a3333333333a7744acccccccccca7744a3330000033a7744a3333003333a7744a5555555555a7744a8888888888a775516666666666177
dd5888000088857744a3300300033a7744accc0000ccca7744a3304444403a7744a3330a70333a7744a5555555555a7744a8880000888a775516666666666177
dd5880667708857744a30f80f8803a7744acc09aaa0cca7744a3304aa5450a7744a330a037033a7744a5555555555a7744a8806677088a775516666666666177
dd5806677770857744a0f88f88820a7744ac09a70aa0ca7744a330a9aa450a7744a330a00a033a7744a5555555555a7744a8066777708a775516666666666177
dd5806600700857744a0888888820a7744ac09a70aa0ca7744a3009a9a403a7744a3330aa0333a7744a5555555555a7744a8066007008a775516666666666177
dd5806600700857744a3088888203a7744ac09a70aa0ca7744a0444444403a7744a33300a0333a7744a5555555555a7744a8066007008a775516666666666177
dd5880666070857744a3308882033a7744ac09a00aa0ca7744a045a545403a7744a330aaa0333a7744a5555555555a7744a8806660708a775516666666666177
dd5888005708857744a3330820333a7744acc09aaa0cca7744a0455545403a7744a33300a0333a7744a5555555555a7744a8880057088a775516666666666177
dd5888800008857744a3333003333a7744accc0000ccca7744a0444444033a7744a330aaa0333a7744a5555555555a7744a8888000088a775516666666666177
dd5888888888857744a3333333333a7744acccccccccca7744a3000000333a7744a3330003333a7744a5555555555a7744a8888888888a775516666666666177
ddd5555555555d77444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa477444aaaaaaaaaa4775551111111111577
dd555555555555d744aaaaaaaaaaaa4744aaaaaaaaaaaa4744aaaaaaaaaaaa4744aaaaaaaaaaaa4744aaaaaaaaaaaa4744aaaaaaaaaaaa475511111111111157
d55555555555555d4aaaaaaaaaaaaaa44aaaaaaaaaaaaaa44aaaaaaaaaaaaaa44aaaaaaaaaaaaaa44aaaaaaaaaaaaaa44aaaaaaaaaaaaaa45111111111111115
2eeeeeeeeeeeeee22eeeeeeeeeeeeee22eeeeeeeeeeeeee22eeeeeeeeeeeeee22eeeeeeeeeeeeee22eeeeeeeeeeeeee2bf8bf8bbb88b82bb5cccccccccccccc5
22eeeeeeeeeeee2722eeeeeeeeeeee2722eeeeeeeeeeee2722eeeeeeeeeeee2722eeeeeeeeeeee2722eeeeeeeeeeee27f88f882b8bb8bb2b55cccccccccccc57
222ffffffffff277222ffffffffff277222ffffffffff277222ffffffffff277222ffffffffff277222ffffffffff2778888882b8bbbbb2b5551111111111577
22f8888888888f7722f3333333333f7722fccccccccccf7722f3330000033f7722f3333003333f7722f5555555555f77b88882bbb8bbb2bb5518888888888177
22f8880000888f7722f3300300033f7722fccc0000cccf7722f3304444403f7722f3330a70333f7722f5555555555f77bb882bbbbb8b2bbb5518880000888177
22f8806677088f7722f30f80f8803f7722fcc09aaa0ccf7722f3304aa5450f7722f330a037033f7722f5555555555f77bbb2bbbbbbb2bbbb5518806677088177
22f8066777708f7722f0f88f88820f7722fc09a70aa0cf7722f330a9aa450f7722f330a00a033f7722f5555555555f77bbbbbbbbbbbbbbbb5518066777708177
22f8066007008f7722f0888888820f7722fc09a70aa0cf7722f3009a9a403f7722f3330aa0333f7722f5555555555f77bbbbbbbbbbbbbbbb5518066007008177
22f8066007008f7722f3088888203f7722fc09a70aa0cf7722f0444444403f7722f33300a0333f7722f5555555555f77bfebfebbbf8bf8bb5518066007008177
22f8806660708f7722f3308882033f7722fc09a00aa0cf7722f045a545403f7722f330aaa0333f7722f5555555555f77feefee2bf88f882b5518806660708177
22f8880057088f7722f3330820333f7722fcc09aaa0ccf7722f0455545403f7722f33300a0333f7722f5555555555f77eeeeee2b8888882b5518880057088177
22f8888000088f7722f3333003333f7722fccc0000cccf7722f0444444033f7722f330aaa0333f7722f5555555555f77beeee2bbb88882bb5518888000088177
22f8888888888f7722f3333333333f7722fccccccccccf7722f3000000333f7722f3330003333f7722f5555555555f77bbee2bbbbb882bbb5518888888888177
222ffffffffff277222ffffffffff277222ffffffffff277222ffffffffff277222ffffffffff277222ffffffffff277bbb2bbbbbbb2bbbb5551111111111577
22ffffffffffff2722ffffffffffff2722ffffffffffff2722ffffffffffff2722ffffffffffff2722ffffffffffff27bbbbbbbbbbbbbbbb5511111111111157
2ffffffffffffff22ffffffffffffff22ffffffffffffff22ffffffffffffff22ffffffffffffff22ffffffffffffff2bbbbbbbbbbbbbbbb5111111111111115
b666666bb666666bb666666bb77777bbbb7777bbbb77777bd66666666666666dd66666666666666dd66666666666666dd66666666666666dd66666666666666d
666666666666666666666666b077067bb707707bb760770bdd666666666666d7dd666666666666d7dd666666666666d7dd666666666666d7dd666666666666d7
655555566555555665555556b077067bb707707bb760770bddd5555555555d77ddd5555555555d77ddd5555555555d77ddd5555555555d77ddd5555555555d77
b666666bb666666bb666666bb077067bb707707bb760770bdd53333333333577dd5cccccccccc577dd53330000033577dd53333003333577dd5ffffffffff577
b666666bb666666bb666666bb777777bb777777bb777777bdd53300300033577dd5ccc0000ccc577dd53304444403577dd53330a70333577dd5ffffffffff577
b666666bb666666bb666666bbdddcddbbddccddbbddcdddbdd530f80f8803577dd5cc09aaa0cc577dd53304aa5450577dd5330a037033577dd5ffffffffff577
b666622bb226622bb226666bb566665bb566665bb566665bdd50f88f88820577dd5c09a70aa0c577dd5330a9aa450577dd5330a00a033577dd5ffffffffff577
bbbbb22bb22bb22bb22bbbbbbbbbb22bb22bb22bb22bbbbbdd50888888820577dd5c09a70aa0c577dd53009a9a403577dd53330aa0333577dd5ffffffffff577
b667776bb666777bb666677bbbbbbbbbbbbbbbbbbbbbbbbbdd53088888203577dd5c09a70aa0c577dd50444444403577dd533300a0333577dd5ffffffffff577
667707066667070b6666707bbbbbbf8bf8bbbbbbb666676bdd53308882033577dd5c09a00aa0c577dd5045a545403577dd5330aaa0333577dd5ffffffffff577
b5770706b557070bb555707bbbbbf88f882bbbbb60600606dd53330820333577dd5cc09aaa0cc577dd50455545403577dd533300a0333577dd5ffffffffff577
b6770706b667070bb666707bbbbb8888882bbbbb76676666dd53333003333577dd5ccc0000ccc577dd50444444033577dd5330aaa0333577dd5ffffffffff577
b667777bb667777bb666777bbbbbb88882bbbbbb60600607dd53333333333577dd5cccccccccc577dd53000000333577dd53330003333577dd5ffffffffff577
665dccdb6665dcdb6665dcdbbbbbbb882bbbbbbb66666766ddd5555555555d77ddd5555555555d77ddd5555555555d77ddd5555555555d77ddd5555555555d77
656666656656666b6656666bbbbbbbb2bbbbbbbb60600606dd555555555555d7dd555555555555d7dd555555555555d7dd555555555555d7dd555555555555d7
b222b222bb222b22bbb222bbbbbbbbbbbbbbbbbb76667666d55555555555555dd55555555555555dd55555555555555dd55555555555555dd55555555555555d
99999999999999999999999999999999999999999999999949999999999999945cccccccccccccc55cccccccccccccc55cccccccccccccc55666666666666665
999999999999999999999999999999999999999999999999449999999999994755cccccccccccc5755cccccccccccc5755cccccccccccc575566666666666657
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444aaaaaaaaaa4775551111111111577555111111111157755511111111115775551111111111577
99999999999999999999999999999999999999999999999944a9999999999a775513333333333177551dddddddddd17755133300000331775513333003333177
44444444444449944444444444444444444444444444444444a9999449999a775513300300033177551ddd0000ddd17755133044444031775513330a70333177
aaaaa4aa44aa4994aaaaaa4aa44aa4aaaaaa4aaaaaa4a44a44a9999449999a7755130f80f8803177551dd09aaa0dd1775513304aa5450177551330a037033177
aa4aa4aa44aa4994aaaaaa4aa44aa4aaaaaa4aaaaaa4a44a44a9999449999a775510f88f88820177551d09a70aa0d177551330a9aa450177551330a00a033177
aa4aa4aaaaaa4994aaaaaa4aa44aa4aaaaaa4aaaaaa4aa4a44a9999449999a775510888888820177551d09a70aa0d1775513009a9a4031775513330aa0333177
aa4aa4aaaaaa4994a4aa4a4aa44aa4a4aa4a4a4aa4a4aaaa44a9999449999a775513088888203177551d09a70aa0d177551044444440317755133300a0333177
aa4aa4aaaaaa4994a4aa4a4aa44aa4a4aa4a4a4aa4a44aaa44a9999449999a775513308882033177551d09a00aa0d177551045a545403177551330aaa0333177
aaaaa4aaaaaa4994a4aa4a4aaaaaa4a4aa4a4a4aa4a444aa44a9999449999a775513330820333177551dd09aaa0dd177551045554540317755133300a0333177
aaaaa4aa44aa4994a4444a4aaaaaa4a4444a4a4444a494aa44a9999949999a775513333003333177551ddd0000ddd1775510444444033177551330aaa0333177
44444444444449944499444444444444994444499444944444a9999949999a775513333333333177551dddddddddd17755130000003331775513330003333177
999999999999999999999999999999999999999999999999444aaaaa99999a775551111111111577555111111111157755511111111115775551111111111577
99999999999999999999999999999999999999999999999944aaaaaa99999a775511111111111157551111111111115755111111111111575511111111111157
0000000000000000000000000000000000000000000000094aaaaaaa99999a775111111111111115511111111111111551111111111111155111111111111115
__gff__
0202020202020202040101010101000002020202020200010001010101010000020202020202010101010101000400000000000200010101010301010000000000000000000001010101010101010000000000000000010101010101010100000000000000000101010101010101000100000000000001010101010101010000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000001010101010101010101010101010000010100000000000001010101010101010101000000000003010101010101010101010101010101010101010101010101010101010101010101010101010101010101
__map__
000000000000000000000000000000002c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b2727272727002a27272727272727272b272727272727272727272727272727273a0000000000000e0e0e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c002c2c2c2c2c2c2c2c2c2c2c2c2c2c2c002c2c2c2c2c2c2c3a0000000000000f090a1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c090a2c090a2c090a2c090a2c090a2c2c8a8b2c090a2c84852c090a2c82832c2c3a00000e0e0e0e0f191a0e0e0e04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c191a2c191a2c191a2c191a2c191a162c9a9b2c191a2c94952c191a2c929316163a0000000000001e0e0e0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c002c002c2c2c2c2c2c2c2c2c2c2c2c2c3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c090a2c090a2c090a2c090a2c090a2c2c8c8d00e6e0e1e2e3e4e5e70084852c2c3a008485008687008283008889008c8d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c191a2c191a2c191a2c191a2c191a2c2c9c9d007bf0f1f2f3f4f5f70094952c2c3a009495009697009293009899009c9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000006f6e6e6e6e6e6d6b0000002c2c3a00000000000000d3d400d56300524400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c090a2c090a2c090a2c090a2c090a2c2c090a007c7a7a7a7a7a7d6b008a8b2c2c3a00000000000000000000000000535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c191a2c191a2c191a2c191a2c191a2c2c191a00191b1b1b1b1b1b1a009a9b2c2c3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c3a00000000000000004e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c090a2c090a2c090a2c090a2c090a2c2c88892c090a2c8a8b2c86872c090a2c2c3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c191a2c191a2c191a2c191a2c191a2c2c98992c191a2c9a9b2c96972c191a2c2c3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b2828282828282828282828282828283b282828282828282828282828282828283700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
564646464646005646464646464646465a4a4a4a4a4a005a4a4a4a4a4a4a4a4a766666666666007666666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c002c2c2c2c2c2c2c2c2c2c2c2c2c2c2c002c2c2c2c2c2c2c2c2c2c2c2c2c2c2c002c2c2c2c2c2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c48492c48492c48492c48492c48492c2c4c4d2c4c4d2c4c4d2c4c4d2c4c4d2c2c68692c68692c68692c68692c68692c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c58592c58592c58592c58592c5859162c5c5d2c5c5d2c5c5d2c5c5d2c5c5d162c78792c78792c78792c78792c7879160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c48492c48492c48492c48492c48492c2c4c4d2c4c4d2c4c4d2c4c4d2c4c4d2c2c68692c68692c68692c68692c68692c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c58592c58592c58592c58592c58592c2c5c5d2c5c5d2c5c5d2c5c5d2c5c5d2c2c78792c78792c78792c78792c78792c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c48492c48492c48492c48492c48492c2c4c4d2c4c4d2c4c4d2c4c4d2c4c4d2c2c68692c68692c68692c68692c68692c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c58592c58592c58592c58592c58592c2c5c5d2c5c5d2c5c5d2c5c5d2c5c5d2c2c78792c78792c78792c78792c78792c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c48492c48492c48492c48492c48492c2c4c4d2c4c4d2c4c4d2c4c4d2c4c4d2c2c68692c68692c68692c68692c68692c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c58592c58592c58592c58592c58592c2c5c5d2c5c5d2c5c5d2c5c5d2c5c5d2c2c78792c78792c78792c78792c78792c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
574747474747474747474747474747475b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b776767676767676767676767676767670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00140000051300e0000c1350c1300c1000c0000c1301a000051300c0000c1350c130001300c0000c1300c00005130091000c1350c13000130090000c1302010005130091000c1350c13000130090000c13000000
00140000207302073020730207301f7301f7301f7301f7301d7301d7301d7301d7351d7301d7301f7301f730207302073024730247301f7301f73020730207301d7301d7301d7301d73020730207302273022730
001400002473024730247302473524730247302573025730247302473022730227301f7301f73020730207302273022730227302273522730227302473024730227302273020730207301d7301d7301f7301f730
000300003a5753e5753f5753c57527575275752a5752d57530575365753d0753c0753b075390753306526065270552a0552e04533045360453a0453903537035340352f02529025220251c025190151505014050
000d0000331703a1703a1503a1303a1203a1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000136250c622000000260007600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000336701a00026660120001d65021000156400d0000e6301200004620140000161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000907301000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00002336300105103331c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000024075270652d05523075260652c05522075250552b04522055250552b04522055250452b02522745257452b72522725257252b72522725257252b7250000000000000000000000000000000000000000
0107000014760187601b760207602476027760167601a7601d760227602676029760187601c7601f76024760287602b7603075030740307403074030730307250000000000000000000000000000000000000000
0002000012270014701427002470152700247017270014701827001470182700147017270014701427001470122700147010270014700e270014700d270014700c270024700a2700147008270014700827001470
000100002a7501475014750147501475015750177501b750227502675002500025000250002500025000250002500025000250002500025000250002500015000150030000025000350004500045000450001500
010800001b37522375003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c5501c5601057023570195702c5702157037570285703b5702c5703e560315503e540315303e530315203f520315203f520315103f510315103f510315103f510315100050000500005000050000000
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
01 01 00 43 44
02 02 00 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
