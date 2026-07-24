pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--bitter
--ver 0.18.06.29.01

function _init()
 cls()
 act={}
 plat={}
 grav=0.7 tvel=7 grounded=false
 fric=0.5 frica=0.5
 gametime=2 frameclock=0
 score=0 kbackdown=false
 roompop=0 endcount=0
 backa={}
	splash={} splashp={}
	cheating=false
 noheart=false brokenheart=false --it is a sin to say the name of god
end

function firstroom()
 roomx=1 roomy=3 zone=1
 makechar(0,0)
 rm_mon()
 roomid(roomx,roomy,8,16)
end

function rm_mon()
 roomset={}
 add(roomset,{n=25,s=5,x=7,y=7})
 add(roomset,{n=26,s=5,x=10,y=7})
 add(roomset,{n=26,s=5,x=10,y=13})
 add(roomset,{n=25,s=5,x=6,y=13})
 add(roomset,{n=25,s=5,x=11,y=13})
 add(roomset,{n=25,s=5,x=11,y=7})
 add(roomset,{n=27,s=5,x=2,y=13})
 add(roomset,{n=27,s=5,x=6,y=12})
 add(roomset,{n=27,s=5,x=11,y=13})
 add(roomset,{n=27,s=5,x=13,y=9})
 add(roomset,{n=27,s=5,x=12,y=5})
 add(roomset,{n=28,s=5,x=4,y=13})
 add(roomset,{n=28,s=5,x=12,y=13})
 add(roomset,{n=28,s=5,x=9,y=10})
 add(roomset,{n=28,s=5,x=8,y=6})
 add(roomset,{n=29,s=5,x=4,y=7})
 add(roomset,{n=29,s=5,x=9,y=11})
 add(roomset,{n=29,s=5,x=7,y=13})
 add(roomset,{n=29,s=5,x=12,y=13})
 add(roomset,{n=17,s=5,x=4,y=8})
 add(roomset,{n=17,s=5,x=13,y=13})
 add(roomset,{n=18,s=5,x=6,y=10})
 add(roomset,{n=18,s=5,x=7,y=6})
 add(roomset,{n=18,s=5,x=13,y=9})
 add(roomset,{n=19,s=100,x=7,y=4})
 add(roomset,{n=19,s=100,x=9,y=4})
 add(roomset,{n=19,s=100,x=10,y=10})
 add(roomset,{n=19,s=100,x=7,y=13})
 add(roomset,{n=19,s=100,x=9,y=13})
 add(roomset,{n=30,s=52,x=4,y=2})
 add(roomset,{n=30,s=44,x=1,y=7})
 add(roomset,{n=30,s=44,x=13,y=13})
 add(roomset,{n=22,s=44,x=1,y=3})
 add(roomset,{n=22,s=44,x=3,y=7})
 add(roomset,{n=22,s=44,x=5,y=12})
 add(roomset,{n=22,s=52,x=6,y=4})
 add(roomset,{n=22,s=52,x=11,y=7})
 add(roomset,{n=14,s=44,x=2,y=4})
 add(roomset,{n=14,s=44,x=4,y=9})
 add(roomset,{n=14,s=52,x=3,y=3})
 add(roomset,{n=14,s=52,x=9,y=13})
 add(roomset,{n=14,s=52,x=10,y=12})
 add(roomset,{n=15,s=44,x=5,y=2})
 add(roomset,{n=15,s=44,x=11,y=4})
 add(roomset,{n=15,s=44,x=7,y=10})
 add(roomset,{n=15,s=44,x=5,y=12})
 add(roomset,{n=15,s=52,x=3,y=6})
 add(roomset,{n=15,s=52,x=6,y=2})
 add(roomset,{n=15,s=52,x=9,y=10})
 add(roomset,{n=15,s=52,x=11,y=4})
 add(roomset,{n=23,s=44,x=8,y=2})
 add(roomset,{n=23,s=44,x=7,y=10})
 add(roomset,{n=23,s=44,x=9,y=11})
 add(roomset,{n=23,s=52,x=6,y=3})
 add(roomset,{n=23,s=52,x=7,y=3})
 add(roomset,{n=23,s=52,x=9,y=5})
 add(roomset,{n=23,s=52,x=10,y=5})
 add(roomset,{n=23,s=52,x=12,y=5})
 add(roomset,{n=23,s=52,x=12,y=10})
 add(roomset,{n=31,s=52,x=5,y=4})
 add(roomset,{n=31,s=52,x=6,y=6})
 add(roomset,{n=31,s=52,x=8,y=3})
 add(roomset,{n=31,s=52,x=9,y=5})
 add(roomset,{n=31,s=44,x=9,y=6})
 add(roomset,{n=31,s=44,x=11,y=9})
 add(roomset,{n=7,s=66,x=8,y=6})
 add(roomset,{n=7,s=66,x=10,y=6})
 add(roomset,{n=7,s=66,x=8,y=10})
 add(roomset,{n=7,s=66,x=10,y=10})
 add(roomset,{n=8,s=66,x=6,y=6})
 add(roomset,{n=8,s=66,x=4,y=6})
 add(roomset,{n=8,s=66,x=6,y=10})
 add(roomset,{n=8,s=66,x=4,y=10})
 add(roomset,{n=16,s=66,x=8,y=6})
 add(roomset,{n=16,s=66,x=10,y=6})
 add(roomset,{n=16,s=66,x=8,y=10})
 add(roomset,{n=16,s=66,x=10,y=10})
 add(roomset,{n=24,s=66,x=6,y=6})
 add(roomset,{n=24,s=66,x=4,y=6})
 add(roomset,{n=24,s=66,x=6,y=10})
 add(roomset,{n=24,s=66,x=4,y=10})
 add(roomset,{n=32,s=66,x=8,y=6})
 add(roomset,{n=32,s=66,x=10,y=6})
 add(roomset,{n=32,s=66,x=8,y=10})
 add(roomset,{n=32,s=66,x=10,y=10})
 add(roomset,{n=10,s=68,x=2,y=13})
 add(roomset,{n=10,s=68,x=10,y=9})
 add(roomset,{n=10,s=12,x=3,y=3})
 add(roomset,{n=10,s=12,x=13,y=3})
 add(roomset,{n=9,s=12,x=3,y=3})
 add(roomset,{n=9,s=12,x=13,y=3})
 add(roomset,{n=1,s=12,x=3,y=3})
 add(roomset,{n=1,s=12,x=13,y=3})
 add(roomset,{n=2,s=12,x=3,y=3})
 add(roomset,{n=2,s=12,x=13,y=3})
 add(roomset,{n=9,s=68,x=3,y=13})
 add(roomset,{n=9,s=68,x=6,y=9})
 add(roomset,{n=9,s=68,x=11,y=7})
 add(roomset,{n=1,s=68,x=8,y=6})
 add(roomset,{n=1,s=68,x=12,y=8})
 add(roomset,{n=1,s=68,x=6,y=10})
 add(roomset,{n=1,s=68,x=10,y=13})
 add(roomset,{n=2,s=68,x=8,y=8})
 add(roomset,{n=2,s=68,x=6,y=12})
 add(roomset,{n=2,s=68,x=9,y=12})
 add(roomset,{n=20,s=100,x=4,y=13})
 add(roomset,{n=20,s=100,x=10,y=13})
 add(roomset,{n=20,s=100,x=9,y=10})
 add(roomset,{n=20,s=100,x=10,y=7})
 add(roomset,{n=20,s=100,x=3,y=7})
 add(roomset,{n=20,s=100,x=3,y=10})
 add(roomset,{n=21,s=100,x=5,y=13})
 add(roomset,{n=21,s=100,x=8,y=13})
 add(roomset,{n=21,s=100,x=11,y=13})
 add(roomset,{n=21,s=100,x=12,y=10})
 add(roomset,{n=21,s=100,x=9,y=7})
 add(roomset,{n=21,s=100,x=6,y=10})
 add(roomset,{n=21,s=100,x=12,y=4})
 add(roomset,{n=19,s=100,x=6,y=10})
 add(roomset,{n=13,s=100,x=13,y=7})
 add(roomset,{n=13,s=100,x=4,y=7})
 add(roomset,{n=13,s=100,x=6,y=7})
 add(roomset,{n=13,s=100,x=3,y=10})
 add(roomset,{n=13,s=100,x=7,y=10})
 add(roomset,{n=13,s=100,x=8,y=13})
 add(roomset,{n=12,s=100,x=3,y=9})
 add(roomset,{n=12,s=100,x=6,y=9})
 add(roomset,{n=12,s=100,x=9,y=9})
 add(roomset,{n=12,s=100,x=12,y=9})
 add(roomset,{n=12,s=100,x=3,y=13})
 add(roomset,{n=12,s=100,x=6,y=13})
 add(roomset,{n=12,s=100,x=9,y=13})
 add(roomset,{n=12,s=100,x=12,y=13})
 add(roomset,{n=11,s=100,x=4,y=4})
 add(roomset,{n=11,s=100,x=8,y=4})
 add(roomset,{n=11,s=100,x=4,y=7})
 add(roomset,{n=11,s=100,x=9,y=7})
 add(roomset,{n=11,s=100,x=4,y=10})
 add(roomset,{n=11,s=100,x=9,y=10})
 add(roomset,{n=11,s=100,x=4,y=13})
 add(roomset,{n=11,s=100,x=9,y=13})
 add(roomset,{n=3,s=70,x=6,y=2})
 add(roomset,{n=3,s=70,x=7,y=13})
 add(roomset,{n=3,s=70,x=8,y=2})
 add(roomset,{n=3,s=70,x=9,y=13})
 add(roomset,{n=4,s=70,x=6,y=2})
 add(roomset,{n=4,s=70,x=7,y=13})
 add(roomset,{n=4,s=70,x=8,y=2})
 add(roomset,{n=4,s=70,x=9,y=13})
end


function rm_plat()
 platset={}
 add(platset,{15,61,16,43,-1,40,0,0})
 add(platset,{32,60,8,96,-1,104,0,0})
 add(platset,{32,60,8,80,-1,32,0,0})
 add(platset,{32,60,80,80,-1,32,0,0})
 add(platset,{32,60,112,56,1,32,0,0})
 add(platset,{32,60,40,56,1,32,0,0})
 add(platset,{32,60,112,32,1,104,0,0})
 add(platset,{24,60,60,16,0,0,-.7,72})
 add(platset,{24,60,30,96,0,0,.7,72})
 add(platset,{24,60,90,96,0,0,.7,72})
 add(platset,{16,60,24,88,-1,72,0,0})
 add(platset,{16,60,32,64,-1.5,56,0,0})
 add(platset,{16,60,24,40,-2,72,0,0})
 add(platset,{8,60,24,32,-1,72,0,0})
 add(platset,{8,60,96,88,1,72,0,0})
 add(platset,{8,60,32,80,0,0,.7,40})
 add(platset,{8,60,88,40,0,0,-.7,40})
 add(platset,{7,60,40,32,1.5,24,0,0})
 add(platset,{7,60,48,48,1.5,32,0,0})
 add(platset,{7,60,48,64,1.5,32,0,0})
 add(platset,{7,60,56,80,1.5,40,0,0})
 add(platset,{7,60,64,96,1.5,48,0,0})
 add(platset,{7,60,56,32,-1.5,48,0,0})
 add(platset,{7,60,64,48,-1.5,40,0,0})
 add(platset,{7,60,72,64,-1.5,32,0,0})
 add(platset,{7,60,72,80,-1.5,32,0,0})
 add(platset,{7,60,80,96,-1.5,24,0,0})
 for i in all(platset) do
  if i[1]==roomnum then
   make_plat(i[2],i[3],i[4],i[5],i[6],i[7],i[8])
  end
 end
end

function roomid(rmx,rmy,pcx,pcy)
 for i in all(act) do
  if i.typ==2 then
   del(act,i)
  end
 end
 
 for i in all(plat) do
  del(plat,i)
 end

 for i=1,20 do
  backa[i]=flr(rnd(64))
 end

	prevzone=zone
	zone=mget(rmx*16,rmy*16)-16
	if zone!=prevzone then
	 if (zone==1) music(0)
	 if (zone==2) music(21)
	 if (zone==3) music(11)
	 if (zone==4) music(15)
	 if (zone==5) music(8)
	 if (zone==6) music(9)
	end
	
	roomnum=rmy*8+rmx+1

	showroom(rmx,rmy)

 if rmx==1 and rmy==3 and brokenheart and noheart then
  bossset()
 else
 	ch.x=pcx ch.y=pcy
		
  roompop=0
  for i in all(roomset) do
   if i.n==roomnum then
    make_enemy(i.s,i.x*8,i.y*8) --it is a sin to know the name of god
    roompop+=1
   end
  end
 end
	
 rm_plat()

end

function bossset()
 ch.x=8 ch.y=96 ch.mir=false
 make_enemy(94,84,36)
 gametime=3
 roompop=-1
 mset(16,58,17)
 mset(16,59,17)
 mset(31,59,17)
 mset(31,60,17)
 music(22)
 gamedraw()
end

function make_plat(s,x,y,hs,hr,vs,vr)
 local a={}
 a.s=s a.x=x a.y=y 
 a.dx=hs a.xrng=hr
 a.dy=vs a.yrng=vr
 a.tx=0 a.ty=0
 if (#plat<128) add(plat,a)
end

function draw_plat()
 for p in all(plat) do
  if p.tx>=p.xrng then
   p.tx=0
  elseif p.tx==0 then
   p.dx*=-1
   p.tx+=abs(p.dx)
   p.x+=p.dx
  else
   p.tx+=abs(p.dx)
   p.x+=p.dx
  end
  if p.ty>=p.yrng then
   p.ty=0
  elseif p.ty==0 then
   p.dy*=-1
   p.ty+=abs(p.dy)
   p.y+=p.dy
  else
   p.ty+=abs(p.dy)
   p.y+=p.dy
  end
  spr(p.s,p.x,p.y-0.7)
 end
end

function makeact(s,x,y,t)
 local a={}
 a.s=s a.x=x a.y=y
 a.dx=0 a.dy=0
 a.ddx=1 a.ddy=grav
 a.mir=false
 a.typ=t
 a.fly=false a.ghost=false
 a.alive=1 a.dmgboost=0
 a.value=1
 
 if a.s==12 then
  a.ddx=0.5 a.ddy=0.5 a.ghost=true
  a.dx=0 a.dy=0 a.value=0
 elseif a.s==52 then
  a.ddx=0 a.ddy=1 a.fly=true
  a.dy=flr(rnd(0))+1
  if (a.dy==0) a.dy=-1
  a.alive=10000
 elseif a.s==44 then
  a.ddx=1 a.ddy=0 a.fly=true
  a.alive=10000
 elseif a.s==66 then
  a.ddx=0.75 a.ddy=0.75 a.dx=0 a.dy=0
  a.ghost=true a.value=3
 elseif a.s==70 then
  a.ddx=0.67 a.ddy=0.67 a.dx=0 a.dy=0
  a.ghost=true a.value=4
  a.alive=2
 elseif a.s==68 then
  a.value=0
 elseif a.s==100 then
  a.alive=3
  a.value=2
 elseif a.s==94 then
  a.value=10 a.mir=true
  a.alive=24
  a.ghost=true
  a.ddx=0.5 a.ddy=0.5 a.dx=0 a.dy=0 --it is a sin to want the name of god
 end
 
 --bullet info
 a.bulx=0 a.buly=0 a.bult=0 
 a.bulmir=false
 a.bulspd=4 a.bulsfx=4 
 a.bulspr=003 a.bullife=10
 a.burstspr=028
 a.but=100
 if (#act<128) add(act,a)
 return a
end

function makechar(x,y)
 ch=makeact(001,x,y,1)
 ch.alive=8 ch.bullife=5
end

function make_enemy(s,x,y)
 local n=makeact(s,x,y,2)
end

function drawact(a)
 if a.s==94 then
 spr(a.s,a.x-4,a.y-4,2,2,a.mir)
  else
  spr(a.s,a.x,a.y,1,1,a.mir)
  if (a.bult>0) drawbul(a)
 end
end

function mback()
 local bgc=0
 if (zone==1) bgc=0
 if (zone==2) bgc=12
 if (zone==3) bgc=0
 if (zone==6) bgc=0
 rectfill(0,0,127,127,bgc)

 if zone==4 then
  rectfill(0,0,127,127,9)
  rectfill(20+backa[1]/2+20*sin(frameclock/256),(128-frameclock%256),backa[2]/2+60+20*sin(frameclock/256+.2),(256-frameclock%256),10)
  rectfill(backa[3]+20*sin(frameclock/256),(backa[5]-frameclock%256+.3)*backa[14]/12,backa[3]+24+20*sin(frameclock/256+.3),(backa[5]+128-frameclock%256)*backa[14]/12,10)
  rectfill(backa[4]+80+20*sin(frameclock/256),(backa[7]-frameclock%256+.6)*backa[15]/12,backa[4]+24+20*sin(frameclock/256+.6),(backa[7]+128-frameclock%256)*backa[15]/12,10)
  rectfill(backa[8]+10*sin(frameclock/256+0.4),backa[9],backa[8]+20+10*sin(frameclock/256+.04),backa[10],8)
  rectfill(backa[11]+10*sin(frameclock/256+0.5),backa[12],backa[11]+20+10*sin(frameclock/256+.05),backa[13],8) end
 
 if zone==5 then
  rectfill(0,0,127,127,13)
  rectfill(0,25+5*sin(frameclock/256),127,127,2)
  rectfill(0,31+4*sin(0.1+frameclock/256),127,127,1)
  rectfill(0,37+3*sin(0.2+frameclock/256),127,127,0)
 end
end

function showroom(rmx,rmy)
 mback()

 map(rmx*16,rmy*16+1,0,8,16,14)

 rectfill(0,0,127,7,0)
 rectfill(0,120,127,127,0) 
 
 if ch.alive>4 then
  hcol=3
 elseif ch.alive>2 then
  hcol=9
 elseif ch.alive>0 then
  hcol=8
 else
  hcol=0
 end
 texcol=7
 rectfill(23,0,57,6,texcol)
 rectfill(24,1,56,5,0)
 rectfill(24,1,24+ch.alive*4,5,hcol)
 spr(118,0,0) spr(119,8,0) spr(120,16,0)

 print(score,120-#tostr(score)*4,1,texcol)
 print("00",120,1,texcol)
 spr(121,80,0) spr(122,88,0) spr(123,96,0) spr(124,104,0)

 if (noheart) spr(126,69,0)
 if (brokenheart) spr(125,61,0) --it is a sin to say the name of god

 read_sign(ch.x+3,ch.y+7)
 comp_button(ch.x+3,ch.y+7)
end

function get_comments()
 if (roomnum==1) roomcom="`the world is worth any effort!'"
 if (roomnum==2) roomcom="`do you know what love is?'"
 if (roomnum==3) roomcom="`oh, god, i can't bear it.'"
 if (roomnum==4) roomcom="`why?'"
 if (roomnum==5) roomcom="you're not permitted to enter."
 if (roomnum==6) roomcom="there's no way to get this."
 if (roomnum==7) roomcom="`who are you? i hate you.'"
 if (roomnum==8) roomcom="`why won't they leave me be?'"
 if (roomnum==9) roomcom="`i want everyone to be happy.'"
 if (roomnum==10) roomcom="`the world is beautiful!'"
 if (roomnum==11) roomcom="`it's not fair! why can't i?'"
 if (roomnum==12) roomcom="`what?? impossible!! unjust!!'"
 if (roomnum==13) roomcom="`thou art unworthy of it. fool!'"
 if (roomnum==14) roomcom="`but, it's impossible for you.'"
 if (roomnum==15) roomcom="`what is it like to dream? ha..'"
 if (roomnum==16) roomcom="`i hate the world. go away.'"
 if (roomnum==17) roomcom="`i shall take whatever i want!'"
 if (roomnum==18) roomcom="`i deserve the world!'"
 if (roomnum==19) roomcom="`i shall be a knight of valor.'"
 if (roomnum==20) roomcom="`hmph! mere peasant! begone!'"
 if (roomnum==21) roomcom="`gaze upon my wondrous glamour!'"
 if (roomnum==22) roomcom="`it's effortless for me.'"
 if (roomnum==23) roomcom="`are you jealous?'"
 if (roomnum==24) roomcom="`i don't care. leave me alone.'"
 if (roomnum==25) roomcom="`i will be their dunce no more!'"
 if (roomnum==26) roomcom="`i hate this. i hate the world.'"
 if (roomnum==27) roomcom="`i starve at the banquet table.'"
 if (roomnum==28) roomcom="`i am in solitude without end.'"
 if (roomnum==29) roomcom="`o woe is me! i am an apoplexy!'"
 if (roomnum==30) roomcom="`guess what i did!'"
 if (roomnum==31) roomcom="`you'll never be able to do it.'"
 if (roomnum==32) roomcom="`get out! get out! get out!'"
end

function show_comments()
 print(roomcom,2,122,1)
 print(roomcom,1,121,7)
 if (roomnum==5) brokenheart=true
 if (roomnum==6) noheart=true
end

function movechar()
 if btnp(2) and cheating then
  ch.alive=8
  brokenheart=true
  noheart=true
 end

 if btnp(5) then
  shoot(ch)
 end
 
 if btn(4) and grounded then
   sfx(3)
   if not sol(ch.x,ch.y-1) and
   not sol(ch.x+7,ch.y-1) then
    ch.dy=-6
    grounded=false
   end
 end

 if btn(0) and (ch.dmgboost==0 or ch.dmgboost>10) then
  ch.dx-=ch.ddx
  ch.mir=true
 end
 if btn(1) and (ch.dmgboost==0 or ch.dmgboost>10) then
  ch.dx+=ch.ddx
  ch.mir=false
 end

 if ch.dx<0 then
  if not sol(ch.x-1+ch.dx,ch.y)
  and not sol(ch.x-1+ch.dx,ch.y+7)
  then
   ch.x+=ch.dx
  else
   while not sol(ch.x-1,ch.y)
   and not sol(ch.x-1,ch.y+7) do
    ch.x-=0.05
   end
   ch.dx=0
  end
 end
 
 if ch.dx>0 then
  if not sol(ch.x+8+ch.dx,ch.y)
  and not sol(ch.x+8+ch.dx,ch.y+7)
  then
   ch.x+=ch.dx
  else
   while not sol(ch.x+8,ch.y)
   and not sol(ch.x+8,ch.y+7) do
    ch.x+=0.05
   end
   ch.dx=0
  end
 end
 
 if ch.dy>=0 then
  if not solb(ch.x,ch.y+8+ch.dy)
  and not solb(ch.x+7,ch.y+8+ch.dy)
  then
   grounded=false
   ch.dy+=ch.ddy
  else
   if sol(ch.x,ch.y+8+ch.dy) or
   sol(ch.x+7,ch.y+8+ch.dy) then
    ground()    
   else
    if solf(ch.x,ch.y+7) or
    solf(ch.x+7,ch.y+7) then
     ch.dy+=ch.ddy
    else
     ground()   
    end
   end
   
  end
 elseif ch.dy<0 and (sol(ch.x,
 ch.y-1+ch.dy) or sol(ch.x+7,
 ch.y-1+ch.dy)) then
   while not sol(ch.x,ch.y-1)
   and not sol(ch.x+7,ch.y-1) do
    ch.y-=0.05
   end
   ch.dy=0
 end

 ch.y+=ch.dy ch.dy+=grav
 if (ch.dy>tvel) ch.dy=tvel

 if solb(ch.x,ch.y+8)
 or solb(ch.x+7,ch.y+8) then
  ch.dx*=fric
 else
  if (not grounded) ch.dx*=frica
 end

 for p in all(plat) do
  check_plat(p)
 end

end

function check_plat(p)
 if ch.x>p.x-7 and ch.x<p.x+7 then
  if ch.y<=p.y-8+p.dy then
   if ch.y+ch.dy>p.y-8+p.dy then
    ch.y=p.y-8.7
    ch.dy=p.dy
    if (p.dy<0) ch.y+=p.dy-grav
    if p.ty>=p.yrng then
     if p.dy>0 then
      ch.dy*=-1
      ch.y-=p.dy
     elseif p.dy<0 then
      ch.y-=p.dy-grav
     end
    end
     ch.dx=p.dx
     if p.tx>=p.xrng then
      ch.dx*=-1
     end
    grounded=true
   end
  end
 end
end

function ground()
 while not solb(ch.x,ch.y+8)
 and not solb(ch.x+7,ch.y+8) do
  ch.y+=0.05
 end
 ch.dy=0
 grounded=true
end

function move_enemy(e)
 if e.s==94 then
  if frameclock%48==0 then
   make_enemy(70,e.x,e.y)
   sfx(25)
  end
 end

 if e.ghost then
  local angle=atan2(e.x-ch.x,e.y-ch.y)
  e.dx=-cos(angle)*e.ddx
  e.dy=-sin(angle)*e.ddy
  if e.dx>0 then
   e.mir=false
  else
   e.mir=true
  end
 elseif not e.fly then
  if solb(e.x+1,e.y+8+min(7,e.dy)) or solb(e.x+6,e.y+8+min(7,e.dy)) then
   e.dy=0
   while not (solb(e.x+1,e.y+8) or solb(e.x+6,e.y+8)) do
    e.y+=1
   end
  end 
  if solb(e.x+1,e.y-e.dy) or solb(e.x+6,e.y-e.dy) then
   e.dy=0
  end
  if not solb(e.x+1,e.y+8) and not solb(e.x+6,e.y+8) then
   e.dy+=grav
    if (e.dy>7) e.dy=7 
  end
 else
  if e.dy<0 then
   if sol(e.x+7,e.y+e.dy) then
    e.dy=1
    e.ddy*=-1
    e.mir=false
   end
  elseif e.dy>0 then
   if sol(e.x+7,e.y+7+e.dy) then
    e.dy=-1
    e.ddy*=-1
    e.mir=true
   end
  end
 end
 
 if not e.ghost then
  e.dx+=e.ddx
  e.dx*=fric

  if e.dx<0 then
   if sol(e.x+e.dx,e.y+7) then
    e.dx=1
    e.ddx*=-1
    e.mir=false
   elseif not solb(e.x+e.dx,e.y+8) and not e.fly then
    e.dx=1
    e.ddx*=-1
    e.mir=false
   end
  elseif e.dx>0 then
   if sol(e.x+7+e.dx,e.y+7) then
    e.dx=-1
    e.ddx*=-1
    e.mir=true
   elseif not solb(e.x+7+e.dx,e.y+8) and not e.fly then
    e.dx=-1
    e.ddx*=-1
    e.mir=true
   end
  end
 end
 
 e.x+=e.dx e.y+=e.dy
 
 if e.x<-8 or e.x>136 or e.y<-8 or e.y>132 then
  e.alive=0
  roompop-=1
  if (roompop==0) commpop()
 end
end

function shoot(q)
 q.bulx=q.x q.buly=q.y
 q.bulmir=ch.mir
 q.bult=1
 sfx(q.bulsfx)
end

function drawbul(w)
 if w.bult<w.bullife then 
  if not w.bulmir then
   w.bulx+=w.bulspd
   w.bult+=1
   spr(w.bulspr,w.bulx,w.buly,1,1,w.bulmir)
  else
   w.bulx-=w.bulspd
   w.bult+=1
   spr(w.bulspr,w.bulx,w.buly,1,1,w.bulmir)
  end
 else
  spr(w.burstspr,w.bulx,w.buly) sfx(burstsfx) 
  w.bult=0
 end
end

function sol(x,y)
 x=flr(x/8) y=flr(y/8)
 x=x+(16*roomx)
 y=y+(16*roomy)
 local f=mget(x,y)
 return fget(f,0)
end

function sol_spike(x,y)
 x=flr(x/8) y=flr(y/8)
 x=x+(16*roomx)
 y=y+(16*roomy)
 local f=mget(x,y)
 kbackdown=fget(f,7)
 return fget(f,4)
end

function read_sign(x,y)
 x=flr(x/8) y=flr(y/8)
 x=x+(16*roomx)
 y=y+(16*roomy)
 if fget(mget(x,y),3) then
  get_comments()
  show_comments()
 elseif zone==4 and roomnum!=6 then
  get_comments()
  show_comments()
 end
end

function comp_button(x,y)
 x=flr(x/8) y=flr(y/8)
 x=x+(16*roomx)
 y=y+(16*roomy)
 if fget(mget(x,y),6) then
  commpop()
  sfx(24)
  mset(x,y,90)
  mset(x,y+1,106)
 end
end

function solf(x,y)
 x=flr(x/8) y=flr(y/8)
 x=x+(16*roomx)
 y=y+(16*roomy)
 local f=mget(x,y)
 return fget(f,2)
end

function solb(x,y)
 return (sol(x,y) or solf(x,y))
end

function ch_dmg(e)
 if e.value!=0 then
 
 if ch.dmgboost==0 then
  if ((ch.x-e.x)^2+(ch.y-e.y)^2)<49 then 
   chhit(e)
   sfx(8)
   ch.dmgboost=1

   kback(false)
   
   if ch.alive==0 then
    death()
   end
  end
 end
 
 end
end

function spike() 
  if sol_spike(ch.x+3,ch.y+3) then 
   if ch.dmgboost==0 then
    chhit(ch)
    sfx(8)
    ch.dmgboost=1
   end
 
   kback(true)
   
   if ch.alive==0 then
    death()
   end
  end
end

function kback(isspikes)
 local kbd=4
 if not isspikes then
 
 if ch.mir then
  ch.dx=kbd
  if sol(ch.x+8,ch.y) or sol(ch.x+8,ch.y+7) then
   ch.dx=0
  end
 elseif not ch.mir then
  ch.dx=-kbd
  if sol(ch.x-1,ch.y) or sol(ch.x-1,ch.y+7) then
   ch.dx=0
  end
 end
 
 end
 
 if kbackdown then
  ch.dy=4
 else
  ch.dy=-4
 end
end

function bulhit(e)
 if ch.bult!=0 then
  if ((ch.bulx-e.x)^2+(ch.buly-e.y)^2)<48 then
   e.alive-=1
   ch.bult=0
   sfx(9)
   if e.alive==0 then
    healing(e)
    splashing(e)
    e.x=10000 e.y=10000
    score+=e.value
    sfx(12)
    if (e.s==94) bosskill()
    roompop-=1
    if (roompop==0) commpop()
   end
  end
 end
end

function bosskill()
 for i in all(act) do
  if i.typ==2 then
   del(act,i)
  end
 end
 gametime=4 endcount=0
end

function commpop()
 if zone==5 then
  qtar=93
 elseif zone==1 then
  qtar=58
 elseif zone==2 then
  qtar=117
 elseif zone==3 then
  qtar=101
 elseif zone==6 then
  qtar=81
 end
 for i=0,15 do
  for j=0,13 do
   qx=roomx*16+i
   qy=roomy*16+1+j
   qq=mget(qx,qy)
   qqq=fget(qq,5)
   if qqq==true then
    mset(qx,qy,qtar)
    sfx(23)
   end
  end
 end
end

function healing(e)
 if e.s!=70 and e.s!=71 then
  if rnd(1)>0.9 then
   if ch.alive<8 then
    ch.alive+=1
    sfx(20)
   end
  end
 end
end

function damboost()
 if ch.dmgboost!=0 then
  ch.dmgboost+=1
 end
 if ch.dmgboost==30 then
  ch.dmgboost=0
 end
end

function death()
 sfx(11)
 gametime=1
end

function moveroom()
 if ch.x>=124 then
  roomx+=1
  roomid(roomx,roomy,0,ch.y)
 end
 if ch.x<=-4 then
  roomx-=1
  roomid(roomx,roomy,120,ch.y)
 end
 if ch.y>=116 then
  if roomx==5 and roomy==0 then
   roomx=6 roomy=0
   roomid(roomx,roomy,ch.x,8)
  elseif roomx==6 and roomy==0 then
   roomx=7 roomy=0
   roomid(roomx,roomy,ch.x,8)
  else
   roomy+=1
   roomid(roomx,roomy,ch.x,8)
  end
 end
 if ch.y<=4 then
  if roomx==7 and roomy==0 then
   roomx=6 roomy=0
   roomid(roomx,roomy,ch.x,112)
  elseif roomx==6 and roomy==0 then
   roomx=5 roomy=0
   roomid(roomx,roomy,ch.x,112)
  else
   roomy-=1
   roomid(roomx,roomy,ch.x,112)
  end
 end
end

function gameupdate()
 movechar()
 spike()
 for i in all(act) do
  if i.typ==2 and i.alive>=1 then
   ch_dmg(i)
   move_enemy(i)
   bulhit(i)
  end
 end
 moveroom()
 damboost()
end

function _update()
 frameclock+=1
 if (frameclock==1024) frameclock=0
 if (gametime==0) gameupdate()
 if (gametime==1) deathupdate()
 if (gametime==2) titleupdate()
 if (gametime==3) cutsceneupdate()
 if (gametime==4) theendupdate()
end

function deathdraw()
 gamedraw()
 rectfill(21,53,106,76,2)
 rectfill(22,54,105,75,0)
 print("g a m e o v e r",33,58,1)
 print("x+z",58,67,1)
end

function theenddraw()
 endcount+=1
 endcomone="`were it only so easy...'"
 if endcount<120 then
  print(endcomone,2,122,1)
  print(endcomone,1,121,7)
 elseif endcount==120 then
  gamedraw()
  gamedraw()
  gamedraw()
  gamedraw()
  gamedraw()
 else
  rectfill(21,53,106,76,2)
  rectfill(22,54,105,75,0)
  print(" t h e   e n d ",33,58,1)
  print("x+z",58,67,1)
 end
end

function titledraw()
 rectfill(0,0,127,127,1)
 rectfill(2,2,125,125,0)
 print("better",53,54,1)
 print("bitter",52,53,2)
 print("bitter",51,52,13)
 print("x+z",58,88,1)
end

function deathupdate()
 if btn(4) and btn(5) then
  run()
 end
end

function cutscenedraw()
 endcount+=1
 endcomone="`my son, can you forgive me?'"
 if endcount<120 then
  print(endcomone,2,122,1)
  print(endcomone,1,121,7)
 elseif endcount>120 then
  gametime=0
 end
end

function cutsceneupdate()
 if endcount>180 then
  if btn(4) or btn(5) then
   gametime=0
  end
 end
end

function theendupdate()
 if btn(4) and btn(5) then
  run()
 end
end

function titleupdate()
 --if (btn(3)) cheating=true
 if btn(4) and btn(5) then
  gametime=0
  firstroom()
  music(1)
 end
end

function cycspr(a)
 if btn(0) or btn(1) then
  if frameclock%5==0 then
   if a.s==1 then
    a.s=2
   else
    a.s=1
   end
  end
 else
  a.s=1
 end
 if ch.dmgboost!=0 then
  if frameclock%3==0 then
   if a.s==1 then
    a.s=27
   else
    a.s=1
   end
  end
 end
 
 for i in all(act) do
  if i.typ==2 then
   if frameclock%5==0 then
    if i.s==5 then
     i.s=6
    elseif i.s==6 then
     i.s=5
    elseif i.s==12 then
     i.s=13
    elseif i.s==13 then
     i.s=12 
    elseif i.s==44 then
     i.s=52
    elseif i.s==52 then
     i.s=44
    elseif i.s==66 then
     i.s=67
    elseif i.s==67 then
     i.s=66
    elseif i.s==68 then
     i.s=69
    elseif i.s==69 then
     i.s=68
    elseif i.s==100 then
     i.s=116
    elseif i.s==116 then
     i.s=100
    elseif i.s==70 then
     i.s=71
    elseif i.s==71 then
     i.s=70
    end
   end
  end
 end
end

function gamedraw()
 cls()
 showroom(roomx,roomy)
 cycspr(ch)
 draw_plat()
 for i in all(act) do
  if i.alive>=1 then
   drawact(i)
   if (i.bult>0) drawbul(i)
  end
 end
 if (splash.ing) splashdraw()
 if (splashp.ing) splashpdraw()
 
 if cheating and btn(3) then
  rectfill(ch.x,ch.y,ch.x,ch.y,8) --the name of god is          
  print(ch.x,0,4,3)
  print(ch.dx,40,0,3)
  print(ch.dy,60,0,3)
  print(ch.y,0,12,3)
  print(ch.bulx,0,20,4)
  print(ch.buly,0,28,4)
  print(ch.bult,0,36,4)
  print(roomnum,0,42,5)
  print(frameclock,0,48,7)
  print(roompop,1,54,8)
 end
end

function _draw()
 if (gametime==0) gamedraw()
 if (gametime==1) deathdraw()
 if (gametime==2) titledraw()
 if (gametime==3) cutscenedraw()
 if (gametime==4) theenddraw()
end

function splashing(e)
	splash={}
	splash.x=e.x+4 splash.y=e.y+4
	splash.clock=0
	splash.ing=true
	splash.left=e.mir
end

function splashdraw()
 if splash.clock<10 then
  splash.clock+=1

  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)
  circ(splash.x+splrnd(),splash.y+splrnd(),0.5,8)

 else
  splash.ing=false
 end
end

function splrnd()
 return rnd(splash.clock*2)-splash.clock
end

function splprnd()
 return rnd(splashp.clock*2)-splashp.clock
end

function chhit(e)
 if e.s==94 and ch.alive>=2 then
  ch.alive-=2
 else
  ch.alive-=1
 end
 splashingp()
end

function splashingp()
	splashp={}
	splashp.clock=0
	splashp.ing=true
	splashp.left=ch.mir
end

function splashpdraw()
 if splashp.clock<10 then
  splashp.clock+=1

  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)
  circ(ch.x+splprnd(),ch.y+splprnd(),0.5,7)

 else
  splashp.ing=false
 end
end
__gfx__
00000000001111100011111000d0000000ee0ee008000008080000080f40f40fdddddddd0005f500444444406666666600888800000000007777777777777777
00000000011111110111111100d000000e88e882088888880888888804444444d222222100050500040404006dddddd10098888000888000f888f88f88f8888e
0070070001f2ff2f01f2ff2f05ddddd00e88888208818818088188180f7f7f7fd2222221000f5f0004040400111111110009888000988800fe0fe00fe0fe00fe
0007700001ffffff01ffffff56d6666d0e888882088888880888778805050505111111110000f0000404040000100100aaa0988000988800fe0fe0fe00fe00fe
00077000001111100011111056d6666d00e88820008877800088778004040404010000100005f5000404040000001000aaaaa991aaa99910fe0fe0fe000fe0fe
00700700099999909999999005ddddd0000e82000222222022222220040404040100001000050500040404000001000088aaaa10aaaaa100fefe00fe000fe0fe
00000000999991109991111000d000000000200002111110221111100404040401000010000f5f0004040400001001000088811088aa1100fefe0fe00000fefe
00000000001000100100000100d000000000000020100010010000010a0a0a0a000000000000f00004040400010000100000010000881000fefe000000000fee
88888888ddddddddaaaaaaaaffffffffaaaaaaaa095444950000000100410000008e8800030b00b004040400005555500000000000000000fefe000000000fee
88777788d2222221abbbbcb3f4555545a999999109511195100000100041000000e88800b80be0b004040400055555550700007000000000fefe00fe00000fee
87877878d2222221abbbcac3f4444555a98888210950999501000100004100008eaaaa8803bb08000404040005b6bb6b0070070000000000fe0fe0fe0000fefe
87787778d2222221abbbbcb3f5544445a9888821095095550010100000410000e8aaa98800300b000404040005bbbbbb0006600010101010fe0fe0fe0000fefe
87778778d2222221ab8bbbb3f4555445a988882109509500000100000041000088aa9a820080bbe004040400005555500006600000000000fe0fe00fe00fe0fe
87877878d2222221a8a8bbb3f4445555a988882149549544001010000041000088a9a9280b030b00040404000dddddd00070070000000000fe00fe0fe00fe0fe
88777788d2222221ab8bbbb3f5544445a2222221195195110100010000410000008882000be3b03004040400ddddd5500700007000000000fe77f77f77f777fe
888888881111111133333333555555551111111109509500100000100041000000882800b003003004040400005000500000000000000000f88888888888888e
dddddddd0000000002121210444444446666666609509599004100000000000000bb3000ffffffff040404000000000000776600000000007777777777777777
d222222101010100021212104000000461dddd1109509555004100000000000000b33000f55444450404040000000000076666d000010000a222a22a22a22228
d22222210010101002121210420012046dddddd1095000950041000000000000000b3300f44555550404040000a00a006666666d00000000a800a80a80a800a8
11111111010101000212121042c812546dddddd1095990950041000000000000000bb300f55544450404040000200200666d166d00010000a800a80a80a800a8
dddddddd001010100212121042c812546dddddd10955509500410000000000000000b3300500005004040400004004006661d66600000000a800a82a82a800a8
2221d222010101000212121042c812546dddddd100095095444444444444444400000b300500005004040400004004007666666600010000a802a82a82a820a8
2221d222001010100212121042c8125461dddd11444950951111111111111111000b3330000000000404040005555550076666d000000000a802a82a82a820a8
1111111100000000021212104444444411111111111950950041000000000000000b300000000000444444400050050000d6dd0000010000a802a82a82a820a8
1ddd1ddd00700070000d11000000000000766d0000095095000000000000000000077700000000000ffffff000000000aaaaaaaa06666660a800a82a82a800a8
d221d22100700070000d010000101000076666d000095095000000766d00000000777777044444400ff111f088888888a99999916dddddd1a800a82a82a800a8
d221d221007000700001d100101010107666666d0999509500007666666d000077767777040000400ffffff0999999991988881161dddd11a800a82a82a800a8
111d111d076d076d0000d000101010106661d66609555095000766666666d00077677777040440400f1111f099999999012882106dddddd1a800a80a80a800a8
1ddd1ddd076d076d000d110010101010666d1666095000950076676666766d0077777777040440400ffffff0aaaaaaaa0012210001111110a800a80a80a800a8
d221d221076d076d000d0100101010107666666d49544495006676666766660077777777040000400f111ff0aaaaaaaa0001100000000000a800a80a80a800a8
d221d221766676660001d10010101010066666d01951119507676666666666d007777776044444400ffffff0aaaaaaaa0000000000000000a877a77a77a777a8
111d111d766676660000d0001010101000d66d00095000950666666d16666660007776600000000000000000aaaaaaaa0000000000000000a222222222222228
0a9a898001020020ff0000ff00000000000000000007ee0000000000000000006666666666666666000000004444444400000000000000000000000000000000
0a9a898025024020fff0eeefff00eeef0007ee000077eee00000000000202220d111d11d11d11112000000004000000400000000000000000000000000000000
0a9a8980012205000ffeeeeefffeeeee0077eee00eeee7702000222002121112d20d200d20d200d2000000004200120400000000000000000000000000000000
0a9a89800010020000feeeee0ffeeeee0eeee77077eee77e1202111221211112d20d20d200d200d20000000042c8125400000000000000000000000000000000
0a9a898000502240000eeeee000eeeee77eee77e0ffdfdf02121111212021112d20d20d2000d20d20000000042c8125400000000000000000000000000000000
0a9a89800201020000f0eee000f0eee00ffdfdf00ffdfdf00212111220002220d2d200d2000d20d20000000042c8125400000000000000000000000000000000
0a9a898002412010ff000f0f0f00f0f00ffdfdf00ffffff00020222000000000d2d20d200000d2d20000000042c8125400000000000000000000000000000000
0a9a89802001001000000f0f0f00f0f044ffff44044004400000000000000000d2d2000000000d22000000004444444400000000000000000000000000000000
00282200001111000ee7777eeeeeee7777eeeee000000000000b30000b008030d2d2000000000d22000000000000000066666666666666660000000022220000
0082220001122110e888aa888888888aa88888820111111100bb30000b00b0e0d2d200d200000d2200066000000660006111111d6bbbbbbd0000022222222200
2844442201111110e88888888aa888888888888a0100000000b33000e08b0030d20d20d20000d2d2006bbd0000688d006111111d6b3b33bd000002dd2ddd2800
8244452201222210e8888888aaaa88888888888a0100001000b30000000eb080d20d20d20000d2d2006bbd0000688d006111111d6bbbbbbd000002ddddddd820
2244542101111110e8888888aaaa8888888aa8820100001000b3300008bb0330d20d200d200d20d2000dd000000dd0006111111d6b333bbd000022111d111820
2245451201221210e88888888aa8888888aaaa820100001000bb300000b03300d200d20d200d20d200000000000000006666666d6666666d000022ddddddd820
00222100011111107a2288822888882228aaaa8201011110000b30000b838be0d266d66d66d666d200000000000000006d1d1d1d6d1d1d1d000022dd111dd220
002212001111111199002220d22222950229002201000000000bb0000b300b00d111111111111112000000006666666661d1d1dd61d1d1dd0051822dddddd220
80051000aaaaaaaa3b3bbb33d44d4995886666600444444000051000020050100001000000010000666666660d1d1d1000000000000000000555828dd2dd2200
08511000ab9bbbb3bbb3b3bb07f7ffa4866161610499994008055080020020400001000000010000666666666666666600000000000000005555818112102000
00051108a9a9bbb3b3b333bb07ff7ff487616161044444400085180040520010000100000001000061dddd1161dddd1100000000000000001555858518158551
00055180ab9bbbb33333bb3b07ff7f408766cc8804999940005110000004205000010111111100006dddddd16dddddd100000000000000001555515551158558
00005110abbbbeb3b33b3b337fff7f4007ddcc8804444440055100000522011000010000000000006dddddd16dddddd100000000000000001155155555100008
08000510abbbeae3b3b333b37fff7f40111dcc8804444440051000800020110000010000000100006dddddd16dddddd100000000000000001111155555000000
00851110abbbbeb3bb3b333b7ff7fff401dd88cc057777700511180002515240000100000001000061dddd1161dddd1100000000000000000880111155000000
000510003333333333bbb3b37ff7faa400d008c00555555000051000021002000001000000010000111111111111111100000000000000000080000811000000
000ddd0054554454544543437ff7ffa4086666600000770001110011101111011110000000111001110011001110011100000000000000000100000100777700
00dddddd554545445445443007f7fff486616161000677701ddd11ddd1dddd1dddd1000001ddd11ddd11dd11ddd11ddd100000000ee00ee0001e0e1007000070
ddd1dddd055545454454433007ff7ff486716161007e766701d1001d101d1d11d1d100001d1111d1111d11d1d11d1d1100000000e880e8820e81e18207000070
dd1ddddd054445454454443007ff7f40867cc88606ee777001d1001d101d1101dd10000001d101d1001d11d1d11d1dd100000000e880e8820e88188200777770
dddddddd05544544545443437fff7f40807cc8807777770001d1101d101dd101d1100000001d11d1001d11d1ddd11d1100000000e88208820e81818200000070
dddddddd05454544544544337fff7f400111c8807767700001d1d11d101d1001d1d100000111d1d11111dd11d11d1ddd10000000088208200018881000000070
0dddddd154554454454543437ff7ffa400188cc0076700001dddd1ddd1dd101dddd100001ddd101ddd101101d101d11100000000008082000108820100000070
00ddd11055454454454544337ff7faa40d008cd00070000001111011101100011110000001110001110000001000100000000000000020000000200000000070
110101010101010101010101010101011101010101010101010101010101010131013101310131a1310131010131010131310131010131010031313131013101
3101010131013101010131010131010151014201014287870101014201014201510101010101010101010101420101524187a701010101010101010101010141
111111111111111111111111111111111111111111111111111111111111111131313100313131a131313100003131313131a031313131009031313131003131
31313131319031313131310000313131514242000042424242424242000042515142424242424242424242424200005241000000000000000000000000000041
11a423002323000000230000002300111100232300000000000000001212121131009000900000a1a0a0000000a000313100a100000000009000000000a40031
3100a40000900000a0a00000b2000031510000b0b000d27272726200000000515161616161616161d1d1d100d200005241c30000000000000000000000000041
111100112323000000000000002300111100232300000000001200001212121131009000900000a1a1a10000a1a100313100a1a1009300009000009300310031
3100313100900000a1a100009200003151d1d1d1d1d1d1d1d1d1710000000051510000000000d2d200d2d200d200005241000000000000000000000000000041
110000002323000000003300330033111100232300000012121200001233120000007000700000a1a1a10000a1a1b2313100a1a1009300707070009300a00031
31b2a0a000900000a1a1000000009331510000000000d200000071006373c551510000000000d2d200d2d200d200005241000000000000000000000000000041
1100000023230000121212121212121111022300000033331212000012001200000000000000929231313100a1a192313100a1a1009300000000009300a20031
3192a1a170907000a1a1003131009331510000424200d200000000b04242b051510000424242d2d242d2d242d242005241000000000000000000000000000041
11000011230000000000800080008011110023000012333312120080128012113100a1000000323231323200a1a1b2313100a1a1009300930093009300310031
3100a1a10070000000a1003232009331510000006200d200000000d200000051510000510061d2d200d2d2517251005241000000000000000000000000000041
11000000230000000000000000000011110000001212808012120000121212113193a1a10000323231b43293a1a192313100a2a2009300000000000000a00031
31b2a1a10000000000000032320093315100d1d17100d200d1d1d1d200d1d151510000516161d20000d200527152005241000000000000000000000000000041
11000000230000000000110000000011110000001212333312120000123312113193a1a1a100929231313193a1a1933131003131009300003131313100a10031
3192a1a10093930031310032320093315100006171424200000000d2424200515100005161b50000b00000007153005241000000000000000000000000000041
11000002020202000000110212121211111111001212333312120000120012113192a1a1a193323231323293a1a192313100a0a0009393003232323200a10031
3100a1a10000930032320032320093315100006171616100000000d2616100515161005161b60000000000000051005241000000000000000000000000000041
11000000121200001212111233331200002222001212121212120002020202023193a1a1a193323231323293a1a193000000a1a1000000003232323200a10031
3100a1a10000000032320032320093315100006171616100000000d261610051516100516100d1d1d1d142420052005241000000000000000000000000000041
110000000000000000001112333312000022220012121111121200222222a4023193a1a1a193929231313193a1a193000000a131313131003131313131a10031
310000a1003131003232003131b2933151000000000061424200000042420051516100516161d1d1d1d10000d100d15241000000000000000000000000000041
11020000121200000202020212121211111111001212000012120022222280023192a1a1a193323231323293a1a193313100a132323232003232323232a10000
000000000032320032320032329293315100d16161d1d16161d1d1d16161d1515161005161610000000061000000005241000000000000000000000000000041
11220200121200022222221212121211112222001212000012120022222222023100a2a2a200323231323200a2a200313100a232323232003232323232a20000
000000000032320032320032320000315100b56161000061000000006161005151610051637300424200616100c5005241000000000000000000000000000041
11111111000011112211111111111111111111111111111111110022111111113131313131313131313131313131313131313131313131003131313131310031
310031313131310031310031313131315142b642424200424200004242004251510000424242425151424242424242524100000000000000000000000000c341
01010111010111020102010101010101010101010101010101110101110101010101010101010101010101010101010101010101010131013101010101310131
31013101010131013131013101010101010101010142014242010142420142015201015201010101010101010101010141010101010101010101010101010141
11010111010111020102010101010101110101010101010101110101110101011101010101010101010101010101010111010101010111011101010101110111
11011101010111011111011101010101519767010142014242010142420142015101015201010101010101010101010141879701010101010101010101010141
11111111000002022211111111111111118494111102021111112323110211111111111111111111111111111111111111111111111111001111111111111211
11231111111111001111001111111111524242424242004242000042420042525100004242424242424242424242425141000000000000000000000000000041
1100121200001212a40000232300001111859500122222121200232300220011110023002300000000000023002300111100000000000000232300000000a411
1123230000000000000000000000001153000000d200610061b0b07151005253510000616100007100616161616161514100000000000000000000000000c341
11003312808012331100002323000011118696001222221212002323002200111100231223000000000000231223001111005555000000002323005555001111
1123230000000000000000000000001151727272d20061616100007152005351510000b0b0d2d271000000616161005141000000000000000000000000000041
11003312000012331200001111000002118696001222221212000000002200111100231223001212120000231223000000005555000000002323005555000000
0000230002020200000080000000001152000000d200616161000071420042525100000000d2d271d20000006161005141000000000000000000000000000041
110012120000121212000022220000111186960012222212120000a400220011110023a423001233120000230023000000000000000000002323000000000000
0000000000000000120012000000001153000000d200616161424262727272515100000000d2d242d2d200000000005141000000000000000000000000000041
11000012111112120000002222000011110000001222221212000080002200111100020202001233120000020202001111808002000000002323000000000202
1100000000000000121212120000001151000000d2006161610000710000005151610000c5d2d25200d200d1d1d1d15141000000000041000041000000000041
02000000000012000000002222008011020000000202020212000000002200110200000000000033120000123312000211121202008012001111001280120011
1100000000000000121212120000001152d1d1d1d1d14242420000710000005251b0b04242d20042000042424200005141000000000000000000000000000041
02111111808011111100001111000011020000001222221212111111002200110200000000000002120000123312000211121202000012002323001212120011
1180120002020200121212120011111153000000d2006161000000710000c5535161005151000000000061616161005141000000000000000000000000000041
11121212000012232312121212121211111212121222221212121212122212111100120012000200000000121212001111808002000012002323001233120011
1100121212121200123312330011111142000042d200616161000042b0b0b042426161424200d1d1d10000b56161005141000000000041000041000000000041
11123312000012122312123312331200003312331222221212331233122212111100121212121212120000111111001111121202003312002323001233120011
11001212121212001233123300222222727272514272616161000000420000616161616100000042424242b64261615141000000000000000000000000000041
11123312020212121212123312331200003312330202020212331233122212000000123312331233120000222222000211121202003312001111001233120002
11021212121212001233123300222222000000525242616161000061420000616161616100610062616171626200004241000000000000000000000000000041
11120012000012121212120012001211113312331222221212338033122212000000121200000000000000222222000211808002001212000000001212120002
11000000000000000202020200111111420000535353726161637361424242424200610000616171716161717100616100000000000000000000000000000041
11121212000012111112121212121211110212121222221212121212122212111100121200020202000000222222001111121200001212001111001212120011
11a400111311000000000000001111115200005151516161b5424261d1d1d1525163734242637362626373726200616100000000000000000000000000000041
11111111020211111111131111131111111111111102021111020202111111111111111111111111111113111111131111111111111111131111131111111311
111111110211111111131311111111115342424242424242b642424242424253514242515142424242424242424242424141b3b3b3b3b3b3b3b3b3b3b3b34141
01010101010101010101110101110101010101010101010101010101010101010101010101010101010111010101110101010101010101110101110101011101
01010101010101010111110101010101010101010101010101010101010101010101010101010101010101010101010101014141414141414141414141410101
__gff__
0000000200000000040000040000080800010101010100000100000000000808010000000101000000040000000008080110000010011010040008100400080800000000000000000000202000000000010801010100000000000040200800001001010000089000000001010000000004010100000800000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
121010101010101010101010101010101210101010101010101010101010101016505050505050505050505050505050165050505050505050505050505050501650505050505050505050505050501014101010101010101010101010101014147d1010101010101010101010101014147e1010101010101010101010101014
6262626262626262626262626262626262626262626262626262626262626262506666666666666666666666666666665066666666666666666666666666666650674141676741410067676741674150141414141414141414141414141414141400000000000000000000000000001414000000000000000000000000000014
62626262571957190057195719626262626262191957191957191919571975716666666666665050506666665066506666666650505066665050506666666666664141006700670000414141416767661400000000000000000000000000001414000000000000000000000000003c14143c0000000000000000000000000014
7219195719571900001975195719577172195719570000571957005719193871666666665050414141506650416641666666500041675050416741506666666666674100670041000000416741006766140000140000000000000000140000141400000000000000000000000000001414000000000000000000000000000014
7257001919000000005718181957007172570057000000001919001900571971666666504167670067415041676641666650410000416700674141005066666666674167410000000000414167006766140000401400000000000014400000141400000000000000000000000000001414000000000000000000000000000014
721900000000180000002828570000717219000000383800190000000019197166665041674100004167410041506766664167004a004100414141000050666666414167000000000000670041006750140000404014000000001440400000141400000000000000000000000000001414000000000000000000000000000014
7257000000002800000028560000000000000000000000000000001261126171665066674100004a00410000416641666641410050004100004100000041506666670041000000000000670067006760140000404040140000144040400000141400000000000000000000000000001414000000000000000000000000000014
72000000000056181800562800000000000000000000000000000019195719716666666741000050000000006750676666674100410050000050500000674166664100410000000e0f00000041006760140000404040402e2f404040400000141400000000000000000000000000001414000000000000000000000000000014
72383800000028285600282800000071720000383800000000000019571919716666005041000060600000500000416666670000410000000041000000004166660000670000001e1f00000041004160140000404040403e3f404040400000141400000000000000000000000000001414000000000000000000000000000014
7200000000005628280028611200007172000000000000181800000019571971660000005000006060500041000041666641000041000000004141000000416666000041000070707070000041000060140000404040141414144040400000141400000000000000000000000000001414000000000000000000000000000014
7200000000002828560056195700001919000000000000282800000019005771500000000000006050600041000041505000000050000000004141005000005050000000000000000000000067000050140000404040000000004040400000141400000000000000000000000000001414000000000000000000000000000014
720000000052535428002800190000191900000000000028280000000000194100000000000000606050504100000000000000004100000000004100600000000000000000707070707070006700006014000040143b3b3b3b3b3b14400000141400000000000000000000000000001414000000000000000000000000000014
7200000000576357560028005700007172000000000000181800000000000067000000000050006060506041000000000000000041606060600041606060000000000000000000000000000000005060140000141414141414141414140000141400000000000000000000000000001414000000000000000000000000000014
7200000000197319280056001900007172180000005253545253540052535471505000000060606050606050000050505050000050606060605050606060505050505000006000006000000000006060140000000000000000000000000000141400000000000000000000000000001414000000000000000000000000000014
535400005253546112611818186112717228181261126328286361120063007160606060506060506060606060606060606060606060606060606060606060606060606060606060606060606060606014000000000000000000000000003c14143c000000000000000000000000001414000000000000000000000000003c14
1012101061101010101010101010101010101010101010101010101010101010505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050141010101010101010101010101010141410101010101010101010101010101414101010101010101010101010101014
121210101210101010101010101010101210101010101010101010101010101013101010101010101010101010101010131010101010101010101010101010101310101010101010101010101010101015777a1010101010101010101010101015777b1010101010101010101010101014777c10101010101010101010101014
6262000062626262626262626262626262626262626262626262626262626262131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313152424242424242424242424242424151524242424242424242424242424241514000000000000000000000000000014
6262000019195719571919571962626262626219571919195719191919196262130000000000004a0a0a000009000013130000000a0a000909000a0a000000131300000900000a0a00000900000a0a1315165c16001600000000002626172715150017000000001717001d1d1d16161514000000000000000000000000003c14
72190038005719007519571957191971725719570000570019571919000057711300000000001a291a1a000009002913132b00001a1a070707071a1a00002b131300070907001a1a00070907001a1a1315160b161616161600000027262626151527262d0b0b2717260000000000161514000000000000000000000000000014
7257000000190038380019001919577172190000000000000019190075001971130000001a1a1a1a1a1a000009000013132900391a1a390000391a1a390029131300000700001a1a00000700001a1a131516162d00161616161d1d1d17275b151500002d00000017001d1d1d1d1d1d1514000000000000000000000000000014
7200380000570000000057001957197172570000000000000057003838380071130000391313131a1313130707070013130000391a1a390000391a1a390000131300000000001a1a000000000013131315160b2d000000001600002424246b24240b002d00002d00002d002d2400001514000000000000000000000000000014
7200000000000000000019000000197172190000000038380019000000000071133900392323231a2323230000002913132b00391a1a390000391a1a39002b131300393939001a0000393939002323131516002d0000000000000016161616160000000000002d00002d002d1516001514000000000000000000000000000014
7200000038380000000000000000007172000000000000000000000000000071133900392323231a2323230000000013132900391a1a392929391a1a3900291313000000000000000000000000234b131500002d0024000000000016161616160000000036372d00002d002d2516161514000000000000000000000000000014
7200000000000000000038383800007172000000383800000000000000000071133939391313131a1313130039392b13130000001a1a000000001a1a000000131329292929002929292913000029291315000024240000002436372424242424240b000024241600242d00003516161514000000000000000000000000000014
7200000000000000000000000000007172000000000000000000000000000071130a0a0a2323231a2323230000392913130000002a1a000000002a2a0000001313232323230023232323130000232313151d1d1d1d1d1d1600242416160000151500001624241600150000002416161514000000000000000000000000000014
7200180000001818000000000000007172000000000000000052535400000071131a1a1a2323231a232323000039000000000013131313232313131313002b13132323232300232323231300002323131500000000001616002d2d16161600151500001616161600250000002516161514000000000000000000000000000014
7200281800002856000000000000001919000052535400000057631900180000001a2b1a1313131a1313130000392b00002b00232323232323232323230029131329292929002929292913000029291315000024240b16160016161616161615150b001600161600350b00003516161514000000000000000000000000000014
72005628180028280000000000000000000000006300001800577319005600000000291a2323231a23232300393929131329002323232323232323232300000023232323230023232323130000232313150000000000170000161616001616151516161600161616151616001516161514000000000000000000000000000014
7200285628005628000052535452535472000000730000560019730000280071130000002323232a23232300000000131300002323234b2323232323230000002323232323002323232313000023231315000016162726272727270000161615155c0016363716162516165b2516161514000000000000000000000000000014
7212611261126112525354630000630072126112611261126112611261126171131313001313130a131313000013131313132313131313232313131313231313131313131300131313131300001313131524241616242424242424240000241515242424242424242424246b24000015143c0000000000000000000000000014
1010101010101010101010101010101010101010101010101010101010101010101013101310131a13101310101310101013101310101310101310101310131010101010131013101010131010131010101024101024101010101024101024101010101010101010101010102410102514101010101010101010101010101014
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000040500000004050000000000000000040500205004050000000405000000000000000000000000000405000000040500000000000000000405002050040500000004050000000000000000
011000000000000000040500000004050000000000000000040500205004050000000405000000000000000000000000000405000000040500000000000000000405002050040500000005050000000000000000
000100000e5560e5510e5560f556105511255114551185561c556225562a5522e5561e506225062e5002e5002e5002d5002d5002a5002c5002c5002b500000002a5002a500000002950029500285002750026500
0101000024610206101d6101b6101a6101c6101e61021620256202b6203062016600196001d600236002c6002e6002e6002c60016500175002150021500205001f50013500135001a5001c500205002250024600
010800001c5501c5401c5301c5201c5101c5001c5001c5001d5501d5401d5301d5201d5101d5001d5001d5001f5501f5401f5301f5201f5101f5001f5001f5001d5501d5401d5301d5201d5101d5001d5001d500
011000203b0153901537015350153b0153901537015350153b0153901537015350153b01539015370153501539015370153501534015390153701535015340153901537015350153401539015370153501534015
012000201e5121e5221e5321e5421e5321e5221e5121e512195121952219532195421953219522195121951216512165221653216542165321652216512165121b5121b5221b5321b5421b5321b5221b5121b512
00010000226501d5501d5501d650175501a65015550135501255016650156501155011550116500f5501065000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000111500f1500c1500915007150051500415004150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00010000105501365017550117501b750085500e65008550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002f1502c1502b1502715027150292502d25030250302502e25027250230502505026050270502b0502615028150250501f2501d2501d2501f0501f1501e1501b150191501505012150121500815000000
00010000315302b540205501c5501b5501f45020450234502b4502b450115500e5500d55010550175501d4502545016550125500f5500e4501045013450194500955007550065500754007530075200251000000
01200020205122052220532205422053220522205122051222512225222253222542225322252222512225121e5121e5221e5321e5421e5321e5221e5121e5121b5121b5221b5321b5421b5321b5221b5121b512
011000201e745007050070500705207451e735007051e745007051e745207350070500705007051e74500705007050070522745207350070520745007052074522735007050000000000207451b7352072500000
010800200c655000050000500005000050000500005000050c655000050000500005000050000500005000050c655000050c65500005000050000500005000050c65500005000050000500005000050000500005
011000200073200741007320074102732027410273202741037320374103732037410873208741087320874102732027410273202741077320774107732077410173201741017320174100732007410073200741
011000200f0130f0230f0330f0431205312043140331602311013110230f0330f043150531504312033120231301313023140331404313053110431503310023100130f0230f033120430d0530d0430c0330e023
01100020011550110501105011050315503105031050310501155011050110501105061550310503105031050115501105011050110508155031050310503105011550110501105011050a155031050310503105
011000202e555275552e55527555245052450524505245052e555245052c555245052a555245052755524505275552e555275552e55524505245052450524505255552450527555245052a555245052c55524505
010100000a5220c5220d5220f5221152213522165321a5521a5421a5421a5321a5321b5221b5221d5221d5221f52222532265422a5522a5422b5322b5322b5322c5222d5222f522325223452236532385523e562
011000200010000100001550010000100001000010000100001000010000155001000010000100001000010000100001000015500100001000010000100001000010000100001550010000100001000010000100
01100020306550e635246551063518655116351363515635306550e635246551063518655116351363515635306550e635246551063518655116351363515635306550e635246551063518655116351363515635
0101000024556265462853629526245562654628536295262b516245562654628536295262b5162d516245562654628536295262b5162d5162f516245562654628536295262b5162d5162f516305163051630516
000100000644006430064400643006440064300b4200b430014001f4001c40017400104000840001400264000b400074000640000400004000040000400004000040000400004000040000400004000040000400
000100000c55012530085400b54006540095300e550145401f5400150022500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011000202a55527555255552555500000000000000000000275552a555000002a55525555000002c5552a55525555255552a5552c55500000000000000000000255550000025555000002c555000002c55500000
011000002e5552c555000002e5552c555000002e5552c5552c5552c555000000000000000275552a5552e55500000275552a5552e555000002e5552a55527555000002e5552a5552c55525555275552755527555
012000202051220522205322054220532205222051220512235122352223532235422353223522235122351221512215222153221542215322152221512215122451224522245322454224532245222451224512
01200020235122352223532235422353223522235122351222512225222253222542225322252222512225121b5121b5221b5321b5421b5321b5221b5121b5121d5121d5221d5321d5421d5321d5221d5121d512
010800200204002040000400204000040000400204000040020400004002040000400204000040020400004002040000400204000040020400004002040000400204000040020400004002040000400204000040
011000200053002540045500556007560095500b5400c5300c5600c5500c5400c5300e5600e5500e5400e5300c5600c5500c5400c5300e5600e5500e5400e5300c5600c5500c5400c5300b5600b5500b5400b530
011000000b5600b5500b5400b530065600655007560075500754007530055600555005540055300456004550045400453009560095500a5600a5500a5400a5300756007550065600655006540065300756007550
010800201d62500000000002162500000216151f625000050000000005000052162500000216151f625000050000500005000052162500000216151f625000051f62500000000001f625000051c6151d62500000
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
01 01 42 43 44
00 02 42 43 44
00 01 15 43 44
00 02 15 43 44
00 01 15 43 44
02 02 15 43 44
00 41 42 43 44
00 41 42 43 44
03 16 42 43 44
01 10 42 43 44
03 10 11 43 44
01 12 42 43 44
01 12 13 43 44
00 12 1a 43 44
02 12 1b 43 44
01 0d 42 43 44
00 07 42 43 44
01 0d 06 43 44
00 07 06 43 44
00 1c 06 43 44
02 1d 06 43 44
03 0e 42 43 44
01 1e 1f 43 44
02 1e 20 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
