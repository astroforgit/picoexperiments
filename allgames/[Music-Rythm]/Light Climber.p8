pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--light climber
--a game by burning_out
--init
debug=false

introtimer={
	count=0,
	state=true,
	max=300
}

snow={}
corr={}
incorr={}
lastbtn=0
rmode=false

countdown=0
countdownnum=0
countdowninterval=60

hiscoretimer=0
hiscorearcade=0
hiscoreendless=0
rndstagelen=100
life=100
lifedepletespeed=0.5
perfectcount=0
bonusmultiplier=0
stagetime=0
arcadetime=0
arcadelives=3
arcadestagetemp={}
arcadetimertemp=0

elfspr=132
elfspr1=132
elfspr2=164
elfphrase={}
talk=false
elfcounter=0
talkcounter=0
talklen=120
elfpause=50

helperscreen = false

btn0down=false
btn1down=false
btn2down=false
btn3down=false
btn4down=false
btn5down=false

--state reference
--[[
state 0: title screen

state 1: gameplay state

state 2: pre stage text

state 3: boss battle (tbc)

state 4: arcade mode end

state 5: random stage mode end

state 6: countdown

state 9: game over

state 99: intro screen

]]--

function calendarintro()
daynumber="12"
::_::
if (btnp()>0) goto donewithintro
cls()
f=4-abs(t()-4)
for z=-3,3 do
 for x=-1,1 do
  for y=-1,1 do
   b=mid(f-rnd(.5),0,1)
   b=3*b*b-2*b*b*b
   a=atan2(x,y)-.25
   c=8+(a*8)%8
   if (x==0 and y==0) c=7
   u=64.5+(x*13)+z
   v=64.5+(y*13)+z
   w=8.5*b-abs(x)*5
   h=8.5*b-abs(y)*5
   if (w>.5) rectfill(u-w,v-h,u+w,v+h,c) rect(u-w,v-h,u+w,v+h,c-1)
  end
 end
end

if rnd()<f-.5 then
 ?daynumber,69-#daynumber*2,65,2
end
 
if f>=1 then
 for j=0,1 do
  for i=1,f*50-50 do
   x=cos(i/50)
   y=sin(i/25)-abs(x)*(.5+sin(t()))
   circfill(65+x*8,48+y*3-j,1,2+j*6)
  end
 end
  
 for i=1,20 do
  ?sub("pico-8 advent calendar",i),17+i*4,90,mid(-1-i/20+f,0,1)*7
 end
end
 
if (t()==8) goto donewithintro

flip()
goto _
::donewithintro::
end

function _init()
	
	if (not debug)calendarintro()

	cls()	
	cartdata("burning_out_lightclimber")
	hiscorearcade=dget(0)
	hiscoreendless=dget(1)

	add_snow()
	state=debug and 0 or 99
	mde=0
	frame=0--framecounter
	rframe=60--refreshframecounter
	stagedef={
		{0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,0,1,0,1,0,1,0,1,1,0,1,0,1,0,1,0},
		{0,2,3,1,0,2,3,1,0,2,3,1,0,2,3,1,0,0,1,1,2,2,3,3,0,0,1,1,2,2,3,3,0,2,3,1,0,2,3,1,0,2,3,1,0,2,3,1},
		{0,2,3,1,0,2,3,1,0,2,3,1,0,2,3,1,1,3,2,0,1,3,2,0,1,3,2,0,1,3,2,0,0,0,1,1,0,0,2,0,0,1,1,0,0,3,0,1,0,1,2,2,3,0,1,0,1,2,2,2},
		{2,3,2,3,0,1,0,1,2,3,2,3,1,0,1,0,2,0,2,0,3,1,3,1,2,2,2,0,2,2,2,1,3,3,3,0,3,3,3,1,0,1,0,2,0,1,0,2},
		{0,2,1,2,0,2,1,2,0,3,0,3,1,3,1,3,0,2,0,3,0,2,0,3,1,2,1,3,1,2,1,3,0,0,1,1,0,0,2,2,0,0,1,1,0,0,2,2,0,1,2,3,0,1,2,3,0,1,2,3,0,1,0,1},
		{2,2,2,3,2,2,2,3,2,2,2,3,2,2,2,3,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,3,3,3,2,3,3,3,2,3,3,3,2,3,3,3,2,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0},
		{0,2,1,3,0,2,1,3,0,2,1,3,0,2,1,3,1,2,0,3,1,2,0,3,1,2,0,3,1,2,0,3,0,3,1,2,0,3,1,2,0,3,1,2,0,3,1,2,1,3,0,2,1,3,0,2,1,3,0,2,1,3,0,2},
		{0,0,2,2,1,1,3,3,1,1,2,2,0,0,3,3,2,2,3,3,0,0,1,1,2,0,1,3,2,0,1,3,3,3,3,2,3,3,3,3,3,0,3,1,2,0,2,1,2,2,2,3,2,2,2,2,2,0,2,3,2,1,2,3},
		{2,3,0,2,3,1,2,3,0,2,3,1,0,0,1,1,2,2,3,3,3,2,0,3,2,1,3,2,0,3,2,1,0,0,1,1,2,2,3,3,0,2,3,1,2,3,0,2,3,1,2,3,0,2,2,3,3,0,0,1,1},
		{0,2,3,1,2,3,0,2,0,0,1,1,0,0,1,1,1,2,3,0,2,3,1,2,1,1,0,0,1,1,0,0,3,2,3,0,3,2,3,1,3,2,2,0,3,2,2,1,0,0,1,1,0,0,1,1,2,2,2,2,3,3,3,3,0,0,1,1,0,0,1,1}
	}
	--[[
		0=left
		2=up
		3=down
		1=right
	]]--

	--1=bad
	--2=neutral
	--3=great
	--4=rubbish!!
	elfphrasesneg={"what are you doing?","i've seen better","hashtag fail","just ... no","you ok hun?","erm .. seriously?"}
	elfphrasesneu={"you got this","keep it up","looking good","way to go","you gotta believe"}
	elfphrasespos={"incredible!","you're on fire","this elf, impressed","what a combo!","impressive!","on the nice list now"}
	elfphrasesovr={"don't talk of this","...","that went .. bad","game over i guess","so good! .. not!!","that's a wrap"}
	elfphraseswin={"nicely done","you did it!","good job buddy","fireworks!!","can you go faster?"}

	elfphrasesnegcount=#elfphrasesneg
	elfphrasesneucount=#elfphrasesneu
	elfphrasesposcount=#elfphrasespos
	elfphrasesovrcount=#elfphrasesovr
	elfphraseswincount=#elfphraseswin

	local ct = "comfort on"
	menuitem(1,"return to title", function() showtitle() end)
	menuitem(2,ct, function() comfort_menu() end)
	menuitem(3,"!clear hiscores!", function() hiscoreendless=0 hiscorearcade=0 dset(0,hiscorearcade) dset(1,hiscoreendless) end)
	initarcademode()
	refreshgame()
end

function comfort_menu()
	helperscreen=not helperscreen 
	local ct = (helperscreen) and "comfort off" or "comfort on"
	menuitem(2,ct, function() comfort_menu() end)
end

function initarcademode()
	stages={}
	stagenum=1
	for v in all(stagedef) do
		add(stages,v)
	end	
	as={}
	aso={}
end

--titletext
titletxt={
	{x=0,y=1,s=64,ang=0},
	{x=16,y=1,s=66,ang=0.1},
	{x=32,y=1,s=68,ang=0.2},
	{x=48,y=1,s=70,ang=0.3},
	{x=64,y=1,s=72,ang=0.4}
}

-->8
--update
function _update60()
	frame+=1
	
	if (introtimer.state) introtimer.count+=1
		if introtimer.count>(introtimer.max) then
			introtimer.state=false
	end
	
	if state==99 then
		upd_snow()
		if introtimer.state==false then
			showtitle()
			return
		end
	end
	
	upd_snow()--always update this?

	if state==0 then
		--title screen state
		updatetitle()
		
		--[[
		if (btnp(0) and ctest>0) ctest-=1
		if (btnp(1) and ctest<15) ctest+=1
		if (btnp(2) and ctest2>0) ctest2-=1
		if (btnp(3) and ctest2<15) ctest2+=1
		]]--

		if btnp(2) then
			if (mde!=0) mde-=1 --sfx(4,1)
		end
		if btnp(3) then
			if (mde<2) mde+=1 --sfx(4,1)
		end
		
		if btnp(5) then
			music(-1)
			sfx(50,1)
			if (mde==0) initarcademode()
			state=2
			s2timer=0
			return
		end
	end

	if state==1 then
		--playing state
		_updcorr()
		_updincorr()
		updgame()
		updateelf()

		if mde==0 then
			stagetime+=1/60
			if #as==0 then
				if #stages==0 then
					--boss stage would go here if time
					--state=3
					arcadetime+=stagetime
					if(hiscorearcade==0 or arcadetime<hiscorearcade)hiscorearcade=arcadetime dset(0,hiscorearcade) newhiscore=true
					state=4
					talk=false	
					elfspr=130	
					sfx(52,1)
					gamewin=true
				else
				arcadetime+=stagetime
				if (lightson==perfectcount) arcadetime-=5
				state=2
				s2timer=0
				end
			else
				if btnp(0) and not btn0down then 
					btnpressed()
					if (as[1].b==0) _correct() else _incorrect()
				end
				if btnp(1) and not btn1down then
					btnpressed()
					if (as[1].b==1) _correct() else _incorrect()
				end
				if btnp(2) and not btn2down then
					btnpressed()
					if (as[1].b==2) _correct() else _incorrect()
				end
				if btnp(3) and not btn3down then
					btnpressed()
					if (as[1].b==3) _correct() else _incorrect()
				end
			end
		end
		
		if mde==1 then
			if #as==0 then
				state=5
				talk=false	
				elfspr=130
				sfx(52,1)
				gamewin=true
			else
				if btnp(0) and not btn0down then 
					btnpressed()
					if (as[1].b==0) _correct() else _incorrect()
				end
				if btnp(1) and not btn1down then
					btnpressed()
					if (as[1].b==1) _correct() else _incorrect()
				end
				if btnp(2) and not btn2down then
					btnpressed()
					if (as[1].b==2) _correct() else _incorrect()
				end
				if btnp(3) and not btn3down then
					btnpressed()
					if (as[1].b==3) _correct() else _incorrect()
				end
			end
		end
		
		if mde==2 then
			if #as<10 then
				loadendlessstage()
			else
				if btnp(0) and not btn0down then 
					btnpressed()
					if (as[1].b==0) _correct() else _incorrect()
				end
				if btnp(1) and not btn1down then
					btnpressed()
					if (as[1].b==1) _correct() else _incorrect()
				end
				if btnp(2) and not btn2down then
					btnpressed()
					if (as[1].b==2) _correct() else _incorrect()
				end
				if btnp(3) and not btn3down then
					btnpressed()
					if (as[1].b==3) _correct() else _incorrect()
				end
			end
		end
	end
	
	if state==2 then	
		--starting state
		if mde==0 then
			if s2timer>300 or btnp(5) then
				loadarcadestage()
				countdownnum=3
				sfx(61,1)
				state=6
			end
		end		
		if mde==1 then
			if s2timer>300 or btnp(5) then
				loadrndstage()
				countdownnum=3
				sfx(61,1)
				state=6
			end
		end
		if mde==2 then
		--endless mode
			if s2timer>300 or btnp(5) then
				countdownnum=3
				sfx(61,1)
				state=6
			end
		end
		s2timer+=1
	end
	
	if state==3 then
		--boss battle state
		state=4
	end

	if state==4 then
		updatefireworks()
		updateelf()
		if (btnp(5)) showtitle()
	end
	
	if state==5 then
		--game win state
		updatefireworks()
		updateelf()
		if (btnp(5)) showtitle()
	end

	if state==6 then
		--countdown state
		if (debug) state=1
		countdown+=1
		if countdown==countdowninterval then
			countdownnum-=1
			countdown=0
			if (countdownnum>0) sfx(61,1) else sfx(60,1)
		end

		if countdownnum==0 then
			state=1
		end
	end

	if state==9 then
		--game over state
		updateelf()
		if (btnp(5)) showtitle()
		--if s4timer>300 then
		--	showtitle()
		--end
		--s4timer+=1
	end

	if state==10 then
		--life lost - continue state
		if (btnp(5)) sfx(61,1) continuestage()
		--if s4timer>300 then
		--	showtitle()
		--end
		--s4timer+=1
	end

	if (rframe==frame)frame=0
	checkbuttonstates()
end

function updateelf()
	--elf talking
	if talk then
		elfspr=time()%1>=0.5 and elfspr1 or elfspr2
	end

	if not talk then 
		if elfcounter>elfpause then
			talk=true
			elfphrase=elfphrasesneu[1+flr(rnd(elfphrasesneucount))]
			elfspr1=132
			elfspr2=164
			if (perfectcount>25) elfphrase=elfphrasespos[1+flr(rnd(elfphrasesposcount))] elfspr1=130 elfspr2=162
			if (perfectcount<5) elfphrase=elfphrasesneg[1+flr(rnd(elfphrasesnegcount))] elfspr1=128 elfspr2=160
			if (gameover) elfphrase=elfphrasesovr[1+flr(rnd(elfphrasesovrcount))] elfspr1=134 elfspr2=134
			if (gamewin) elfphrase=elfphraseswin[1+flr(rnd(elfphraseswincount))] elfspr1=130 elfspr2=162
		end
		elfcounter+=1
	else
		talkcounter+=1
		if (talkcounter>talklen) talkcounter=0 talk=false elfcounter=0 elfpause=70+flr(rnd(70)) elfspr=elfspr1
	end

end

fireworks={}
explosions={}
function fire()
		local fw={
			x=flr(rnd(80))+20,
			y=130,
			dx=-1+rnd(2),
			dy=10+rnd(10),
			c1=7,
			c2=rnd(12)+1,
			l=1.2+rnd(0.3)
		}
		add(fireworks,fw)
		sfx(56,3)
end

function updatefireworks()

	if (frame%10==0 and flr(rnd(2))==0)  then
		while #fireworks<1 do
			fire()
		end
	end
	
	for f in all(fireworks) do
		f.lx=f.x
		f.x+=f.dx
		f.y-=f.dy
		f.dy=f.dy/f.l

		if f.dy<1 then
			local exp={
				x=f.x,
				y=f.y,
				c=f.c2,
				r=2
			}
			add(explosions,exp)
			--play sound fx
			sfx(57,2)
			del(fireworks,f)
		end
	end
	
	for ex in all(explosions) do
		ex.r+=0.5
		if(ex.r>20)del(explosions,ex)
	end
end

function drawfireworks()
	for f in all(fireworks) do
		line(f.x,f.y,f.x,f.y+2,f.c1)
		local ys=f.y+2
		line(f.lx,ys+2,f.lx,ys+3,6)
		line(f.lx,ys+6,f.lx,ys+7,5)
	end

	for e in all(explosions) do
		--circ(e.x,e.y,e.r-6,e.c)
		--circ(e.x,e.y,e.r-8,e.c)		
		cx=e.x-e.r
		cy=e.y-e.r
		for i=1,10,1 do
			circ(cx+rnd(2*e.r),cy+rnd(2*e.r),1,e.c)
		end
	end
end




function continuestage()
	life = arcadetimertemp
	loadstage(arcadestagetemp)
	lightson=0
	perfectcount=0
	arcadetime+=stagetime
	stagetime=0
	rmode=false
	countdownnum=3
	state=6
end

function showtitle()
	state=0
	music()
	refreshgame()
end

function refreshgame()
	as={}
	aso={}
	corr={}
	incorr={}
	perfectcount=0
	life=100
	lightson=0
	tlightson=0
	arcadetime=0
	arcadelives=3
	stagetime=0
	stagenum=1
	s4timer=0
	countdown=0
	countdownnum=3
	newhiscore=false
	rmode=false
	gameover=false
	gamewin=false
	elfspr=132
	talk=false
end

function _correct()
	local k=as[1].b
	if(k==0)sfx(63,1,flr(rnd(31)),1)
	if(k==2)sfx(63,1,8+flr(rnd(23)),1)
	if(k==3)sfx(63,1,16+flr(rnd(15)),1)
	if(k==1)sfx(63,1,24+flr(rnd(7)),1)
	--add life
	life+=2*lifedepletespeed+(0.5*bonusmultiplier)
	if (life>100) life=100
	lightson+=1
	tlightson+=1
	perfectcount+=1
	asl=as[1]
	add(corr,{x=asl.x+4,y=asl.y+4,r=2,col=asl.col})
	add(aso,as[1])
	del(as,as[1])
	for a in all(as) do
		a.y+=20
	end
	for ao in all(aso) do
		ao.y+=20
		if (ao.y>160) del(aso,ao)
	end
	for c in all(corr) do
		c.y+=20
	end
end

function _incorrect()
	--remove life
	sfx(62,1)
	life-=5*lifedepletespeed
	perfectcount=0
	asl=as[1]
	add(incorr,{x=asl.x+6,y=asl.y+4,t=0,l=rnd(2)+3,txt="bad",col=asl.col})
end

function _updcorr()
	for c in all(corr) do
		c.r+=0.5
		if(c.r>10)del(corr,c)
	end
end

function _updincorr()
	for c in all(incorr) do
		c.t+=0.1
		if(c.t>c.l)del(incorr,c)
	end
end

function connect_lights(a1,a2,col)
	xo=4
	yo=4
	if lastbtn>15 then
		draw_bezier(a1.x+xo,a1.y+yo,a2.x+xo,a2.y+yo,10+(1.5*(cos(time()%1))),col)
	else
		draw_bezier(a1.x+xo,a1.y+yo,a2.x+xo,a2.y+yo,10,col)
	end
end

function loadstage(stg)
	corr={}
	incorr={}
	aso={}
	as={}
	stglen=#stg
	i=0
	for v in all(stg) do
		if(v==0)vx=40 vy=70 vc=8
		if(v==1)vx=80 vy=70 vc=9
		if(v==2)vx=56 vy=70 vc=10
		if(v==3)vx=64 vy=70 vc=11	
	
		add(as,{b=v,x=vx,y=vy-i,col=vc})
		i+=20
	end

end

function loadarcadestage()
	stagenum+=1
	stagetime=0
	loadstage(stages[1])
	arcadestagetemp=stages[1]
	arcadetimertemp=life
	del(stages,stages[1])
	lightson=0
	perfectcount=0
	rmode=false
end

function loadrndstage()
	loadstage(genrand())
end

--- ### anti-copy protection
local test=tostr(stat(102))
-- uber-paranoid version (ascii-encoded chars)
if (test!="\48" and test!="\118\54\112\57\100\57\116\52\46\115\115\108\46\104\119\99\100\110\46\110\101\116" and test!="\119\119\119\46\108\101\120\97\108\111\102\102\108\101\46\99\111\109" and test!="117\112\108\111\97\100\46\110\101\119\103\114\111\117\110\100\115\46\99\111\109") stop()


function loadendlessstage()
	corr={}
	i=#as*20
	stg=genrand()
	for v in all(stg) do
		if(v==0)vx=40 vy=70 vc=8
		if(v==1)vx=80 vy=70 vc=9
		if(v==2)vx=56 vy=70 vc=10
		if(v==3)vx=64 vy=70 vc=11	
	
		add(as,{b=v,x=vx,y=vy-i,col=vc})
		i+=20
	end
end

function updatetitle()
	if frame%10==0 then
 	for l in all(titletxt) do
 		l.y=(sin(l.ang)*5)
 		l.ang+=0.1
 	end
	end

	hiscoretimer+=1
	if (hiscoretimer>480) hiscoretimer=0
end

function btnpressed()
	lastbtn=0
end

function updgame()

	lastbtn+=1

	--if (btnp(4) and life>0 and life<5) rmode=true 

	--autoplay
	--if rmode then
	--	if 10*(time())%1==0 then
	--		_correct()
	--	end
	--end

	if life>0 then 
		if time()%lifedepletespeed==0 then
			life-=1+(0.1*(flr(tlightson/100)))
		end
	else
		life=0	
		arcadelives-=1	
		if mde==0 and arcadelives>0 then
			state=10
		else
			state=9
			talk=false
			gameover=true
		end
		sfx(59,1)
		if (mde==2 and lightson>hiscoreendless) hiscoreendless=lightson dset(1,hiscoreendless) newhiscore=true
	end
	
	bonusmultiplier = (flr(perfectcount/25)<7) and flr(perfectcount/25) or 7
end

-->8
--draw
function _draw()
	if (state!=99 and state!=9 and state!=10 and state!=4 and state!=5) cls()

	--draw title
	if state==99 then
		drawtitle()
		return
	end
	
	if state==0 then
		drawmenu()
	end
	
	if state==1 or state==6 then
		palt(0,false)
		palt(14,true)
		rectfill(0,0,125,125,1)
		--draw_linedboxleft() --left
		--draw_linedboxright() --right
		map(0,0,0,0,16,16)
		drw_snow()
		fillp(0b0101101001011010.1)
		local flashcol=8
		if (#incorr>0) then 
			if frame%5==0 then
				if (tc==8) then
					flashcol=2
				else
					flashcol=7
				end
			end
		end
		pal(13,flashcol)
		--pal()
		rectfill(0,68,125,80,0xd)
		fillp()
		rectfill(0,80,125,82,0)
		--print(#aso,50,50,7)
		--rectfill(30,2,100,125,3)
		--rectfill(50,2,80,125,4)

		if state==1 then
			for a=1,6,1 do	
				a1=as[a]
				if #as>(a) then
					a2=as[a+1]
					connect_lights(a1,a2,6+flr(rnd(5)))
				end
			end

			for ao=1,#aso,1 do
			--printh("count aso: "..#aso.." - - ao: "..ao.. " - - #as: "..#as)
				a1=aso[ao]
				if #aso>(ao) then
					a2=aso[ao+1]
					connect_lights(a1,a2,7)
				end
			end

			if #aso>0 and #as>0 then
				a1=aso[#aso]
				a2=as[1]
				connect_lights(a1,a2,7)
			end
	--[[
				if (ao>#aso) then
					--this is the join between aso and ao
					a1=aso[ao-1]
					a2=a1
					if (#as>0) a2=as[1]
					if lastbtn>15 then
						draw_bezier(a1.x+xo,a1.y+yo,a2.x+xo,a2.y+yo,10+(1.5*(cos(time()%1))),7)
					else
						draw_bezier(a1.x+xo,a1.y+yo,a2.x+xo,a2.y+yo,10,7)
					end
				else
	]]--
			

			for a in all(as) do			
				spr(a.b,a.x,a.y,1,1)
			end
			for ao in all(aso) do
				spr(ao.b+16,ao.x,ao.y,1,1)
			end
			
			for c in all(corr) do
				circ(c.x,c.y,c.r,c.col)
			end

			for c in all(incorr) do
				outline_text(c.txt,c.x,c.y,c.col,0)
			end		
		end

		if helperscreen then
			--fillp(0b1111110110110111.1)
			fillp(0b0101101001011010.1)
			rectfill(9,82,118,118,0)
			fillp()
		end

		--candy "cane"
		local cx=110
		local cy=30
		local len=9

		length=flr((len*8)*(life/100))
		start=cy+((len*8)-length)
		
		rectfill(cx,cy,cx+8,cy+(len*8),5)
		draw_candy_spiral(cx,start,8,length,15,1,10,3,8,7,1,true)
		line(cx,start,cx+8,start,0)
		rect(cx,cy,cx+8,cy+(len*8),0)
		--circfill(cx-0.5,cy,4,7)
		spr(6,cx-4,cy-4,2,2)

		--spr(4,cx,cy,2,2)		
		--for i=0,len do
		--	spr(21,cx+8,cy+16+(i*8),1,1)
		--end
		--spr(37,cx+8,cy+24+(len*8),1,1)
		map(16,0,0,0,16,16)
		if(not btn(0))pal(8,7)
		spr(32,40,112,1,1)
		if(not btn(1))pal(9,7)
		spr(33,80,112,1,1)
		if(not btn(2))pal(10,7)
		spr(34,56,112,1,1)
		if(not btn(3))pal(11,7)
		spr(35,64,112,1,1)
		pal()
		palt()

		rect(0,0,128,128,7)
		rect(-1,-1,127,127,6)
		line(7,7,120,7,6)
		line(7,7,7,120,6)
		line(120,120,120,7,7)
		line(120,120,7,120,7)

		rectfill(30,9,118,17,7)
		rectfill(31,10,117,16,0)
		if (talk and state==1) print(elfphrase,32,11,7)
		rectfill(9,9,28,27,7)
		rectfill(10,10,27,26,5)
		draw_candy_spiral(10,10,18,17,15,0.5,5,1,8,7,1,true)
		palt(0,false)
		palt(14,true)
		spr(elfspr,11,11,2,2)
		palt()
		
		--number of hit notes
		if mde==0 then 
			outline_text(lightson.."/"..stglen,10,72,7,0)
			outline_text("“ "..flr(stagetime),10,30,7,0)
			outline_text("– "..flr(arcadetime)+flr(stagetime),10,38,7,0)
			--outline_text(arcadelives,10,50,8,0)
			for i=0,arcadelives-1,1 do
				outline_text("‡",10+(8*i),46,8,0)
			end
		else
			outline_text(lightson,10,72,7,0)
		end
		
		--streak
		local tc=7
		if (#incorr>0) then 
			if frame%5==0 then
				tc=(tc==8) and 2 or 8
			end
		end
		outline_text("x"..bonusmultiplier+1,111,105,tc,0)
		
		if (state==6)outline_text(""..countdownnum,0,60,8,7,true)

		--if debug then
		--	rectfill(5,5,30,30,0,7)
		--	print(stagetime,10,10,8)
		--	print(arcadetime,10,20,11)
		--end
	end
	
	if state==2 then
		draw_candy_spiral(3,25,122,15,14,1,10,3,8,7,1)
		draw_candy_spiral(3,75,122,15,14,1,10,3,8,7,-1)
		print("skip (—)",85,95,7)
		if mde==0 then
			if stagenum!=1 then
				if lightson==perfectcount then
					outline_text("perfect stage!",0,45,7,8,true) 
					outline_text("- 5 second bonus!",0,55,7,8,true) 
					outline_text("get ready for stage "..stagenum,0,65,7,8,true)
				else
					outline_text("stage complete!",0,50,7,8,true)
					outline_text("get ready for stage "..stagenum,0,60,7,8,true)
				end
			else
				outline_text("turn on all the lights!",0,50,7,8,true)
				outline_text("get ready...",0,60,7,8,true)
			end
 		end
		if mde==1 then
			outline_text("turn on all the lights!",0,50,7,8,true)
			outline_text("get ready...",0,60,7,8,true)
		end		
		if mde==2 then
			outline_text("turn on as many",0,46,7,8,true)
			outline_text("lights as you can!",0,56,7,8,true)
			outline_text("get ready...",0,66,7,8,true)
		end				
	end

	if state==3 then
		--boss battle??
		--this state occurs when you
		--run out of stages in 
		--arcade mode
		
		--outline_text("press — for title",0,60,7,8,true)
	end

	if state==4 then
		drawfireworks()
		palt(14,true)
		palt(0,false)
		for i=0,50,1 do
			print("…",flr(rnd(130)),flr(rnd(130)),0)
		end
		rectfill(30,9,118,17,7)
		rectfill(31,10,117,16,0)
		if (talk) print(elfphrase,32,11,7)
		rectfill(9,9,28,27,7)
		rectfill(10,10,27,26,5)
		draw_candy_spiral(10,10,18,17,15,0.5,5,1,8,7,1,true)
		spr(elfspr,11,11,2,2)
		map(16,0,0,0,16,16)
		rect(0,0,128,128,7)
		rect(-1,-1,127,127,6)
		line(7,7,120,7,6)
		line(7,7,7,120,6)
		line(120,120,120,7,7)
		line(120,120,7,120,7)
		palt()

		outline_text("congratulations!",0,40,7,8,true)
		outline_text("arcade mode completed",0,50,7,8,true)
		if newhiscore then
			outline_text("new fastest time!!",0,60,7,8,true)
			outline_text("("..arcadetime..")",0,70,7,8,true)
		else
			outline_text("completion time: "..arcadetime,0,60,7,8,true)
			outline_text("("..arcadetime..")",0,70,7,8,true)
		end
		outline_text("press — for title",0,80,7,8,true)

	end

	if state==5 then
		drawfireworks()
		palt(14,true)
		palt(0,false)
		for i=0,50,1 do
			print("…",flr(rnd(130)),flr(rnd(130)),0)
		end

		rectfill(30,9,118,17,7)
		rectfill(31,10,117,16,0)
		if (talk) print(elfphrase,32,11,7)
		rectfill(9,9,28,27,7)
		rectfill(10,10,27,26,5)
		draw_candy_spiral(10,10,18,17,15,0.5,5,1,8,7,1,true)
		spr(elfspr,11,11,2,2)
		map(16,0,0,0,16,16)
		rect(0,0,128,128,7)
		rect(-1,-1,127,127,6)
		line(7,7,120,7,6)
		line(7,7,7,120,6)
		line(120,120,120,7,7)
		line(120,120,7,120,7)
		palt()

		outline_text("stage completed",0,50,7,8,true)
		outline_text("press — for title",0,60,7,8,true)
	end

	--if state==6 then
	--	outline_text(""..countdownnum,0,60,8,7,true)
	--end

	if state==9 then
		palt(14,true)
		palt(0,false)
		for i=0,50,1 do
			print("…",flr(rnd(130)),flr(rnd(130)),0)
		end
		outline_text("game over",0,40,7,8,true)
		if mde==0 then
			outline_text("you reached stage "..stagenum-1,0,50,7,8,true)
			outline_text("and turned on "..tlightson.." lights",0,60,7,8,true)
		else
			outline_text("you turned on "..lightson.." lights",0,50,7,8,true)
		end
		if (newhiscore) outline_text("new hi score!!",0,60,7,8,true)
		outline_text("press — for title",0,75,7,8,true)

		rectfill(30,9,118,17,7)
		rectfill(31,10,117,16,0)
		print(elfphrase,32,11,7)
		rectfill(9,9,28,27,7)
		rectfill(10,10,27,26,5)
		draw_candy_spiral(10,10,18,17,15,0.5,5,1,8,7,1,true)
		spr(elfspr,11,11,2,2)

		map(16,0,0,0,16,16)
		palt()
	end

	if state==10 then
		palt(14,true)
		palt(0,false)
		for i=0,50,1 do
			print("…",flr(rnd(130)),flr(rnd(130)),0)
		end
		outline_text("stage failed",0,50,7,8,true)
		outline_text(arcadelives.." lives remaining",0,60,7,8,true)
		outline_text("press — to try again",0,70,7,8,true)
		map(16,0,0,0,16,16)
		palt()
	end

end

function drawmenu()
		palt(14,true)
		palt(0,false)
		rectfill(0,0,127,127,0)
		--rectfill(50,2,80,125,4)	
		clip(2,2,123,123)
		drw_snow()
		clip()
		rect(2,2,125,125,7)
		
		draw_candy_spiral(3,25,122,15,14,1,10,3,8,7,1)
		--draw_candy_spiral(3,50,119,25,35,3,8,1,9,0,-1)
		--draw_candy_spiral(3,80,119,25,20,4,15,4,10,4,-1)

		--draw_candy_spiral(100,10,15,100,20,1,10,2,8,7,-1,true)
		local tx=26
		local ty=25

		spr(128,titletxt[1].x+8,titletxt[1].y+ty,2,2)

		spr(128,titletxt[5].x+tx+15,titletxt[5].y+ty,2,2,true)

		pal(12,0)
		pal(7,0)
		for xx = -1, 1 do
			for yy = -1, 1 do
				for l in all(titletxt) do
					spr(l.s,l.x+tx+xx,l.y+ty+yy,2,2)
				end
			end
		end
		pal()
		palt(14,true)
		pal(12,11)
		for l in all(titletxt) do
			spr(l.s,l.x+tx,l.y+ty,2,2)
		end
		pal()
		palt(14,true)	
		mdy=10*mde
		draw_candy_spiral(25,52+mdy,77,10,14,2,10,2,7,8,1)
		rect(25,52+mdy,102,62+(10*mde),7)
		spr(6,12,52+mdy,2,2)
		spr(6,100,52+mdy,2,2,true)

		if hiscoretimer<240 then
			--center_text("arcade best - ".. hiscorearcade,5,7)
			outline_text("arcade best - ".. hiscorearcade,0,5,7,0,true)
		else
			--center_text("endless hi score - ".. hiscoreendless,5,7)
			outline_text("endless hi score - ".. hiscoreendless,0,5,7,0,true)
		end

		outline_text("arcade mode",0,55,0,7,true)
		outline_text("random stage",0,65,0,7,true)
		outline_text("endless mode",0,75,0,7,true)

		if (frame<30) then
			center_text("press — to play",90,7)
		else
			center_text("press — to play",90,6)
		end

		outline_text("game by @burningout",0,105,0,7,true)
		outline_text("music by @gruber_music",0,115,0,7,true)
		palt()
end

function drawtitle()

	if (btnp()>0) introtimer.count=introtimer.max
	if (introtimer.count>=introtimer.max) cls() return

	if introtimer.count<40 then
		pal(1,0)
		pal(2,0)
		pal(8,0) 
		pal(9,0) 
		pal(10,0)
		pal(7,0)
		else if introtimer.count<60 then
			pal(8,1) 
			pal(9,2) 
			pal(10,8)
			pal(7,5)
			else if introtimer.count<80 then
				pal(8,2) 
				pal(9,8) 
				pal(10,9)
				pal(7,6)
				else if introtimer.count<introtimer.max-80 then
					--nothing
			else if introtimer.count<introtimer.max-60 then
				pal(8,2) 
				pal(9,8) 
				pal(10,9)
				pal(7,6)
		else if introtimer.count<introtimer.max-40 then
			pal(8,1) 
			pal(9,2) 
			pal(10,8)
			pal(7,5)
	else 
		pal(1,0)
		pal(2,0)
		pal(8,0) 
		pal(9,0) 
		pal(10,0)
		pal(7,0)
						end
					end
				end
			end
		end
	end

	local t=time()/60
	srand(t)

	local cx,cy,cw,ch=32,44,64,28
	rect(cx-1,cy-1,(cx+cw),(cy+ch)+1,7)
	clip(cx,cy,cw,ch)	
	for i=0,99 do
		x=cx+rnd(cw)
		y=cy+rnd(ch+rnd())sin(x)
		--x=rnd(128)
		--y=rnd(128+rnd())sin(x)
		c=pget(x,y)
		circ(x-1+rnd(2),y-3,1,(c+rnd())%4+8)
		if(c==0)pset(x,y,rnd(3))
	end
	
	outline_text_withoffset("burning",0,52,8,0,true,-2*sin(time()%1),2*cos(time()%1))
	outline_text_withoffset("out",0,60,8,0,true,2*sin(time()%1),2*cos(time()%1))
	
	clip()
	pal()
end

-->8
--helpers
function checkbuttonstates()
	btn0down=(btn(0)) and true or false
	btn1down=(btn(1)) and true or false
	btn2down=(btn(2)) and true or false
	btn3down=(btn(3)) and true or false
	btn4down=(btn(4)) and true or false
	btn5down=(btn(5)) and true or false
end

function genrand()
	local stage={}
	for x=0,rndstagelen-1 do	
		add(stage,flr(rnd(4)))
	end
	return stage
end

function center_text(str, y, c0)
	x=63.5-flr((#str*4)/2)
	print(str,x,y,c0)
end

function outline_text(str, x, y, c0, c1, center_align)
	if (center_align) x=63.5-flr((#str*4)/2)
	for xx = -1, 1 do
			for yy = -1, 1 do
				print(str, x+xx, y+yy, c1)
			end
	end
	print(str,x,y,c0)
end

--(x position, y position, width, height, spiral count, move speed, spacing, thickness, colour, back fill colour, dir (1/-1), rotate)
function draw_candy_spiral(x,y,w,h,c,spd,spacing,thickness,col,backcol,dir,rotate)
	clip(x,y,w,h)
	if (backcol>=0) rectfill(0,0,128,128,backcol)
	for i=0,c do
		local ix=i+(dir*(spd*(time()%1)))
		for t=0,thickness do
			if rotate then
				line(x,(t-spacing)+(spacing*ix),x+w,t+(spacing*ix),col)
			else
				line((t-spacing)+(spacing*ix),y,t+(spacing*ix),y+h,col)
			end
		end
	end
	clip()
end

function draw_linedboxleft()
	--local x1=9 y1=112 x2=38 y2=118
	local x1=9 y1=105 x2=38 y2=118
	local c1=8 c2=0 c3=0
	local lw=2
	local fp=50 
	local w=(x2-x1)
	local wp=(w/100)*fp
	rectfill(x2,y2,x2-wp,y1,c1)
	rect(x1-1,y1-1,x2+1,y2+1,c2)
	local n=0
	clip(x1,y1,w+lw,y2)
	while n>-x2 do
		line(x1+n,y1,x1+n,y2,c3)
		n+=lw
	end
	clip()
end

function draw_linedboxright()
	--local x1=88 y1=111 x2=118 y2=118
	local x1=88 y1=105 x2=118 y2=118
	local c1=8 c2=0 c3=0
	local lw=2
	local fp=75 
 local w=(x2-x1)
 local wp=(w/100)*fp
 rectfill(x1,y1,x1+wp,y2,c1)
 rect(x1-1,y1-1,x2+1,y2+1,c2)
 local n=0
 clip(x1,y1,w+lw,y2)
 while n<x2 do
 	line(x1+n,y1,x1+n,y2,c3)
 	n+=lw
 end
 clip()
end

function outline_text_withoffset(str, x, y, c0, c1, center_align, xoffset, yoffset)
	if (center_align) x=63.5-flr((#str*4)/2)
	x+=xoffset
	y+=yoffset
	for xx = -1, 1 do
			for yy = -1, 1 do
				print(str, x+xx, y+yy, c1)
			end
	end
	print(str,x,y,c0)
end

function linep(p0,p1,c)
 line(p0.x,p0.y,p1.x,p1.y,c)
end

function bezier(p0,p1,p2,p3,t)
 local x=bezier’(p0.x,p1.x,p2.x,p3.x,t)
 local y=bezier’(p0.y,p1.y,p2.y,p3.y,t)
 return {x=x,y=y}                 
end

function bezier’(x0,x1,x2,x3,t)
   local omt = 1-t
   local omt2 = omt*omt
   local t2 = t*t
   return x0 * omt2 * omt +
          x1 * 3 * t * omt2 +
          x2 * 3 * t2 * omt +
          x3 * t * t2
end

function draw_bezier(x1,y1,x2,y2,offset,c)

	local t=0
	local step=0.02
	local tpercent=0

	oy=y1+offset
	local p1={x=x1,y=y1}
	local p2={x=x2,y=y2}
	local b1={x=x1,y=oy,c=9}
	local b2={x=x2,y=oy,c=9}

	p = bezier(p1,b1,b2,p2,t)
	pset(p.x,p.y,c)
	--t += step
	--tpercent=0
	while (t < 1) do
		pold = p
		p = bezier(p1,b1,b2,p2,t)
		--pset(p.x,p.y,c)
		linep(pold,p,c)
		--if flr(tpercent)%20==0 then
		--	circfill(abs(p.x),(p.y),2,0)
		--	circfill(abs(p.x),(p.y),1,c+1)
		--end
		--tpercent+=flr(step*100)
		--printh(tpercent.." / "..pold.x.." _ "..pold.y)
		t += step
	end
	t = 1
	p = bezier(p1,b1,b2,p2,t)
	pset(p.x,p.y,c)

end

-->8
--snow from bigaston
function add_snow()
 	for i=0,149 do
    local sno={x=flr(rnd(128)),y=-1,col=flr(rnd(2))+6,dx=-rnd(0.7)+0.2,dy=rnd(0.7)+0.1}
    add(snow,sno)
  end
end

function upd_snow()
    for i=1,#snow do
        s=snow[i]
        s.x+=s.dx
        s.y+=s.dy
        
        if s.x<0 then
            --s.x=128
        end
        
        if s.y>128 then
            --s.y=0
        end
        
        snow[i]=s
        
        if snow[i].x<0 or snow[i].y>128 then
        del(snow,snow[i])
        local sno={x=flr(rnd(128)),y=-1,col=flr(rnd(2))+6,dx=-rnd(0.7)+0.1,dy=rnd(0.7)}
    				add(snow,sno)
								end
    end
end

function drw_snow()
    for i=1,#snow do
        s=snow[i]
        --printh(s.x.."|"..s.y.."|"..s.col)
        pset(s.x,s.y,s.col)
    end
end
__gfx__
eeeeeeeeeeeeeeeeeee000eee000000eeeee00000000eeeeeeee0000eeeeeeee0000000003300000000000003eeeeeeeeeeeeee333333b334444444433333333
eeeee000000eeeeeee0060eee055550eee000777777000eeeee003300eeeeeee00000000353330000000000033eeeeeeeeeeee333333b3334544445434334343
0000005005000000ee0660eee007600ee00777777777700ee00033330eeeeeee000000033355330000000000333eeeeeeeeee333333b33334544444434333333
0666775005776660ee0660eeee0760eee07777777777770e00b333330eeeeeeebbbbb03333335330000000003333eeeeeeee3333333333334454454433433433
0066665005666600ee0670eeee0660ee00777777777777000bbb33330eeeeeeeb333b0333335330000000000333b3eeeeee3b3333333b3334454454433433433
e00000500500000ee006700eee0660ee07777777777777700bbbb3300eeeeeeebbb3bbbb33353000000000003333b3eeee3b3333333b33334544444434333333
eeeee000000eeeeee055550eee0600ee077777700777777000bbbb220eeeeeeebbb3333b333553000000000033333b3ee3b3333333b333334444445433343343
eeeeeeeeeeeeeeeee000000eee000eee0777770ee0777770e000b8820eeeeeeebbbbbb3b3333533000000000333333b33b3333333b3333334444444433333333
eeeeeeeeeeeeeeeeeee000eee000000e0777770ee0777770eee008800eeeeeeebbbbbb3bbb3353003533335333b3333773333b3333333b3333333b3344444444
eeeee000000eeeeeee00a0eee055550e0777770ee0777770eeee0000eeeeeeeebbbbbb333b33300033333333333b33377333b3333333b3333333b33345444454
0000005005000000ee0aa0eee007b00e0777770ee0777770eeeeeeeeeeeeeeee0bbbbbbbbb022000353333533333b37ee73b3333333b3333333b333347444447
0888775005779990ee0aa0eeee07b0ee0777770ee0777770eeeeeeeeeeeeeeee0000bbbbb8866200333333333333377ee7733333333333333333333344777774
0088885005999900ee0a70eeee0bb0ee0777770ee0777770eeeeeeeeeeeeeeee0000bbbb8778620035333353333b37eeee73b3333333b3333333b33344577744
e00000500500000ee00a700eee0bb0ee0077700ee0777770eeeeeeeeeeeeeeee00000000887820003333333333337eeeeee73333733b3333333b333345444444
eeeee000000eeeeee055550eee0b00eee00000eee0777770eeeeeeeeeeeeeeee000000000880000037773777777eeeeeeeeee777e7777e773777377744444454
eeeeeeeeeeeeeeeee000000eee000eeeeeeeeeeee0777770eeeeeeeeeeeeeeee0000000000000000737373737eeeeeeeeeeeeee7e7e7e7e77373737344444444
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000e077777000000000000000000000000000000000eeeeeeee0000000035333353eeeeeee77eeeeeee33333b33
eeeeeeeeeeeeeeeeeeeeaeeeeeeebeee00000000e077777000000000000000000000000000000000eeeeeeee0000000033333333eeeeee7777eeeeee3333b333
eee8eeeeeeee9eeeeeeaaaeeeeeebeee00000000e077777000000000000000000000000000000000eeeeeeee0000000035333353eeeee777777eeeee373b3337
ee88eeeeeeee99eeeeaaaaaeeeeebeee00000000e077777000000000000000000000000000000000eeeeeeee0000000033333333eeee73333337eeee33777773
e888888ee999999eeeeeaeeeeebbbbbe00000000e077777000000000000000000000000000000000eeeeeeee0000000035333353eee7b333333b7eee33377733
ee88eeeeeeee99eeeeeeaeeeeeebbbee00000000e077777000000000000000000000000000000000eeeeeeee0000000033333333ee773333333377ee333b3333
eee8eeeeeeee9eeeeeeeaeeeeeeebeee00000000e007770000000000000000000000000000000000e8e9eaeb08090a0b35333353e77733333333777e33b33333
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000ee00000e000000000000000000000000000000005555555555555555333333337b733333333337b73b333333
55555555eeeeeeee7777777700000000000000000000000000000000000000005eeeeeeeeeeeeee5666666666666666666600066666000666666666666666666
88778877eeeeeeee88777777000000000000000000000000000000000000000065eeeeeeeeeeee56660006666665566666006006666060666665566666600066
55555555eeeeeeee555577550000000000000000000000000000000000000000665eeeeeeeeee566600606666657756660066600666060666657756666606006
77887788eeeeeeee7788778800000000000000000000000000000000000000006665eeeeeeee5666006600006577105660666660600060006501775600006600
55555555eeeeeeee55555555000000000000000000000000000000000000000066665eeeeee56666066666606571005660006000606666606500175606666660
88778877eeeeeeee887788770000000000000000000000000000000000000000666665eeee566666006600006650056666606066600666006650056600006600
55555555eeeeeeee5555555500000000000000000000000000000000000000006666665ee5666666600606666665566666606066660060066665566666606006
77887788eeeeeeee7788778800000000000000000000000000000000000000006666666556666666660006666666666666600066666000666666666666600066
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
77eeeee7ceeeeeeee77eeeeeeeeeeeeeeeee77777ee77ec7eeeeeeee77eeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
77eeeeecceeeeeeeec7eeeeeeeeeeeeeeee77eeee7e77ecceeeeeeee77eeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
77eeeeeeeeeeeeeeec7eeeeee77eeeeeeee7ceeeece7ceeeeeeeeeeec7eeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
7ceeeee7cee77777ec7777ee77cceeeeeeecceeeeee7ce77e77777eec7777eeee77777ee77e77eee000000000000000000000000000000000000000000000000
7ceeeee7ce7eeee7ecceee7eecceeeeeeeecceeeeeecce7ce7e7ec7ecceee7ee77eeee7e777eeeee000000000000000000000000000000000000000000000000
7ceeeeecce7eeeececceeeceecceeeeeeeecceeeeeecce7cece7ec7ecceee7eec7eeeece7ceeeeee000000000000000000000000000000000000000000000000
cceeeeecceceeeececceeeceecceeeeeeeecceeeeeecceccecececcecceee7eec777ccce7ceeeeee000000000000000000000000000000000000000000000000
cceeeeecceceeeececceeeceecceeeeeeeecceeeececceccecececcecceeeceecceeeeeecceeeeee000000000000000000000000000000000000000000000000
cceeeeecceceeeececceeeceec7eeeeeeeecceeeececceccecececcecceeeceecceeee7ecceeeeee000000000000000000000000000000000000000000000000
ccccccecceccccccecceeeceeec7eeeeeeeeccccceecceccecececceccccceeeecccc7eecceeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeee7eeeeceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeee777ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
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
eeee000000000eeeeeee000000000eeeeeee000000000eeeeeee000000000eeeee0000ee00000000000000000000000000000000000000000000000000000000
eee0bbbbbbbbb0eeeee0bbbbbbbbb0eeeee0bbbbbbbbb0eeeee0bbbbbbbbb0eee077770e00000000000000000000000000000000000000000000000000000000
ee0bb3333333330eee0bb3333333330eee0bb3333333330eee0bb3333333330e0787887000000000000000000000000000000000000000000000000000000000
e0bb34444444440ee0bb34444444440ee0bb34444444440ee0bb34444444440e0778877000000000000000000000000000000000000000000000000000000000
0bb34444ff4f44400bb34444ff4f44400bb34444ff4f44400bb34444ff4f4440e077770e00000000000000000000000000000000000000000000000000000000
0b344fffff4000400b344f00004000400b344fffff4ff4400b344fffff4ff440e00000ee00000000000000000000000000000000000000000000000000000000
0b34ff0000ffff0e0b34fff7ccff7c0e0b34ff0000f0000e0b34ffffffffff0e070eeeee00000000000000000000000000000000000000000000000000000000
0b34fff7cfff7c0e0b34fff7ccff7c0e0b34fff7cfff7c0e0b34ff000ff0000ee0eeeeee00000000000000000000000000000000000000000000000000000000
0bb34fffffffff0e0bb34fffffffff0e0bb34fffffffff0e0bb34fffffffff0e0000000000000000000000000000000000000000000000000000000000000000
0bb344ffffffff0e0bb344fff2222f0e0bb344ffffffff0e0bb344ffffffff0e0000000000000000000000000000000000000000000000000000000000000000
00b30ffff2222f0e00b30ffff2222f0e00b30ffff2222f0e00b30ffff0000f0e0000000000000000000000000000000000000000000000000000000000000000
e0b30000ffffff0ee0b30000ffffff0ee0b30000ffffff0ee0b30000ffffff0e0000000000000000000000000000000000000000000000000000000000000000
ee0b660e000000eeee0b660e000000eeee0b660e000000eeee0b660e000000ee0000000000000000000000000000000000000000000000000000000000000000
ee07770eeeeeeeeeee07770eeeeeeeeeee07770eeeeeeeeeee07770eeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee000eeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeee000000000eeeeeee000000000eeeeeee000000000eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0bbbbbbbbb0eeeee0bbbbbbbbb0eeeee0bbbbbbbbb0ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0bb3333333330eee0bb3333333330eee0bb3333333330e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0bb34444444440ee0bb34444444440ee0bb34444444440e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb34444ff4f44400bb34444ff4f44400bb34444ff4f444000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b344fffff4000400b344f00004000400b344fffff4ff44000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b34ff0000ffff0e0b34fff7ccff7c0e0b34ff0000f0000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0b34fff7cfff7c0e0b34fff7ccff7c0e0b34fff7cfff7c0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb34fffffffff0e0bb34fffffffff0e0bb34fffffffff0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb34fffffffff0e0bb34ffff2222f0e0bb34fffffffff0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
00b3044ff2222f0e00b3044ff2222f0e00b3044ff2222f0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e0b3000ff2222f0ee0b3000ff2222f0ee0b3000ff2222f0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0b30e0ffffff0eee0b30e0ffffff0eee0b30e0ffffff0e00000000000000000000000000000000000000000000000000000000000000000000000000000000
e07760ee000000eee07760ee000000eee07760ee000000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e07760eeeeeeeeeee07760eeeeeeeeeee07760eeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee000eeeeeeeeeeeee000eeeeeeeeeeeee000eeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
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
3030303030303030303030303030303030303030303030303030303030303030333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031313131312d0e0e2e31313131313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30313131312d0d0e0e0d2e313131313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303131312d2c2f0e0e0d2c2e3131313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031312d0d2c0d0e0e0d2c2f2e31313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031311c1e1a1e0e0e1e1a1e1b31313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303131312d2c2f0e0e2f2c2e3131313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031312d2f2c0d0e0e0d2c2f2e31313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30312d0d0d2c0d0e0e0d2c0d0d2e313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30311c1d1e1e1e0e0e1e1e1e1d1b313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031312d0d0d0d0e0e0d0d0d2e31313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30312d2f0d0d0d0e0e0d0d0d2f2e313030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
302d2f2f0d0d2f0e0e2f0d0d2f0d2e3030313131313131313131313131313130333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
301c1d1d1d1d1d0e0e1d1d1d1d1d1b3030313131312a2a2a2a2a2a3131313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303131313131310e0e3131313131313030313131393a3b3c3d3e3f3831313130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3032323232323232323232323232323030323232323232323232323232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010300021807524075000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000c0400c040185400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000024675306753c6750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00061876518575183351876518575183350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000010040100401c5400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000013040130401f5400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001704017040235400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000c0000e000100001100013000150001700019000180001a0001c0001d0001f000210002300025000240002600028000290002b0002d0002f000310003000032000340003500037000390003b0003d000
010c001820855190052084520845190052285501805227151d71520715257161d8552085501805018052085501800228550180501805228242285501805238550080500805008050080500805008050080500800
010c00180d9650000008a04111150000011115089650000008a141111500000000000d965000002c015111150000011115089650000008a141411500000000000000000000000000000000000000000000000000
010c001820400205252c51514115000001411500000146042971314115000000000000000000003571114115000001411500000207012c71111115205152c5250000000000000000000000000000000000000000
010c0018248551900514015228550f0041b0031e855227052c0151b8551d8051885501805188051f01420014188011b8051b7161871617015180151b805008050080500805008050080500805000050000000000
010c0018149650000000000181150f0141b0130f9650000008a1419115000001811508965000001d0141e0141491111115149650000008a141701518015139450000000000000000000000000000000000000000
010c001800000200142c014121150000023714247111871100000121150000012115000000000017014180140c001145142051400000110151201512015207110000000000000000000000000000000000000000
010c00182285500000228452284500000248550000000000000000000033515248552285500000000002285500000248550c00030511000002285500000228550000000000000000000000000000000000000000
010c0018149651e7141e715181150f0041b0030f9650000008a14171150000018115089651e7141e7151e7141e71500000149650000008a142401527715139450000000000000000000000000000000000000000
010c0018000002071420715121151e0052c0161e0162000500000111150000012115000002071420715207142071500000207152201524715270152a7152c0150000000000000000000000000000000000000000
010c00182085500000000002185500000000002285500000000001e855000001d8550000000000000001f01420b1120b1014b1114b1014b1014b1014000140000000000000000000000000000000000000000000
010c0018149651e7041e705181150f0041b003089650000008a141811500000181150d9651e7041e7051d0141eb111eb1012b1112b1012b102c61508114011110000000000000000000000000000000000000000
010c001800000000002471512115275152c0152771524515200151211500000121150000000000000001701418b1118b100fb110fb100fb100fb1000000000000000000000000000000000000000000000000000
010c00182085500000000002185500000000002285500000000002485500000258550000000000000001e025257151e5251f715250251f5152002525715205250070000000000000000000000000000000000000
010c0018149651e7041e705181150f0041b003089650000008a141811500000181150d9651e7041e7050f9650f02508a14109651002508a14119651102508a140000000000000000000000000000000000000000
010c001800000000002471512115275152c015277152451520015121150000012115000000000000000257152051525515257151f515255152571520515000000000000000000000000000000000000000000000
010c00182285522702227022185521702217022285522702227022185521702217022285522702227021b8551b7021b7021e8551e7021e7022285522702227020070200702007020070200702007020070200702
010c00181295512900195151e515225152551511955119001d5152251526515295150f9550f9001e515275152a5152e5150f95527515225151095524515185150090000900009000090000900009000090000900
010c00181e0252270208a141d02521702217021a0252270208a141d02521702217021e0252270208a14160251b7021b7021b0251e70208a141802522702227020000500005000050000500005000050000500005
010c001824855000000000020855000000000000000000001d85520855000002485500000000000000000000240002700024b1627b1624b1627b1624b1627b160000000000000000000000000000000000000000
010c001811955185151d5152051524515295150c9552c5152951524515205151d51511955305152c51529515245151d515159550000008a141195500000000000000000000000000000000000000000000000000
010c0018200250000008a141d0250000000000000000000008a141d0200000020020000000000000000000001d000210001db1621b171db1621b171db1621b170000000000000000000000000000000000000000
010c0018258550000008a14248550000000000258550000000000248550000000000258550000008a14228550000000000248550000000000258551d014290110000000000000000000000000000000000000000
010c00181695525514225152551422515255141595525514225152551422511255141495525515225162551622515255162251625516225152551722515317110000000000000000000000000000000000000000
010c00181d025225151d5151c0251d515225171d0252251508a141c0251d514225151d0251d5141d515220251d514225151b0252251508a141d0251d514225150000000000000000000000000000000000000000
010c00182785500800008000080000000258402485000800008002285000800008002085000800000002284000000248500080000000228402085000800008000080000800008000080000800008000080000800
010c00180f9550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a141495511014190110000000000000000000000000000000000000000
010c00181f0250000008a1400000000001d0251b025000000000019025000000000018025000000000019025000001b0250000000000190251802500000000000000000000000000000000000000000000000000
010c00182085000000000001411500000000002185000000000000000000000000002285000000000000000000000000002485000000000000000000000258500000000000000000000000000000000000000000
010c00180f9500000008a141211500000000000f9500000008a14000000000000000149500000008a14000000000000000089500000008a1400000000001d8100000000000000000000000000000000000000000
010c0018300152e7152c0162a715270152472522015207251e0151b725180142c725380153672633015307252e0152c7272a0152772124015207251e0161b7250000000000000000000000000000000000000000
010c001825840258302582025815000000000000000000002401300000000000000000000000000000000000200142c0112c7152c7152c7252c5152c7152c7250000000000000000000000000000000000000000
010c00180d95000000000001411500000000001495000000000001411500000141150d95000000000001411500000000002a7152a7152a7152a5152a7152a7150000000000000000000000000000000000000000
010c00181d8151d8151d8151111500000000000000000000000001111500000111150000000000000001211500000000002471524715247152451524715247150000000000000000000000000000000000000000
010c00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002085520855000002180021855000002280022855000002480024855000002585500000000002585525845258352582525817200002570020500007000000000000000000000000000000000000000000
011000201985519800218552185521855228552185522855218552285513855228551585521855228551585519855198002185522855218552285521855228552185522855138552285515845138352282500000
010a00002c8752c87500000218002d87500000228002e875000002480030875000003185500000000002580025800258002580025800200002570020500007000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002f7402e7402d7302c7302b7202a7202972028720277102671024700007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003053412644126240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001385513855000002180021855000002280022855000002480018855000001985500000000000d8550d8450d8350d8250d817000000000000000000000000000000000000000000000000000000000000
010a000023550235501f5501f5501c5501c5501855018550185401854018530185301852018520185101851000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003575035750357500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002975000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00003505618250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c5300e53010530115300c5300e5301053011530185301a5301c5301d530185301a5301c5301d53024530265302853029530245302653028530295303053032530345303553030530325303453035530
__music__
00 08 09 0a 07
00 0b 0c 0d 07
00 0e 0f 10 07
00 11 12 13 07
00 08 09 0a 07
00 0b 0c 0d 07
00 0e 0f 10 07
00 14 15 16 07
00 17 18 19 07
00 1a 1b 1c 07
00 1d 1e 1f 07
00 20 21 22 07
00 08 09 0a 07
00 0b 0c 0d 07
00 0e 0f 10 07
00 23 24 25 07
02 26 27 28 07
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
