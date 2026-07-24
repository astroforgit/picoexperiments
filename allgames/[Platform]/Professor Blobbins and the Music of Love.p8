pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--picojump
px=8
py=48
--states 0 idle,1 walk,2 fall,3 land,4 jump
inmenu=true
pstate=0
didfirstfall=false
pat=0 --state timer
pspr=0
pcol=11
pdir=0
mx=0
my=0
cx=0
cy=0
jspd=2
--npcs
npc={}
numnpc=0
pushblocks={}
--bonus blocks and npc per level. made in init()
bonus={}
--sky colors at different heights
skycolor={}
skycolor[0]=12
skycolor[1]=10
skycolor[2]=9
skycolor[3]=8
skycolor[4]=2
skycolor[5]=2
skycolor[6]=1
skycolor[7]=1
--height completion
lastarea=0
currentarea=0
areatobeat=7
armtimer=0
playeronarms=false
--music
beats=0
lyrics={}
curword=0
lyrset=0
musicpaused=false
--ending fireworks
fireworks={}
fireworkcolors={2,3,7,8,9,10,11,14}
newfireworktimer=0

function updatefireworks()
 for f in all(fireworks) do
  f.x+=f.vx
  f.y+=f.vy
  if f.rkt then
	  f.r-=0.05
	  f.vy+=0.05
   if f.y<32 or f.r<=0 or f.vy>=1 then
    for i=0,16 do
     local a=rnd(1)
     local spd=1+rnd(1)
     add(fireworks,{
      x=f.x,
      y=f.y,
      vx=spd*cos(a),
      vy=spd*sin(a),
      r=1+flr(rnd(2)),
      c=f.c
     })
    end
    del(fireworks,f)
    sfx(10+flr(rnd(3)))
   else
    if flr(rnd(3))==0 then
     add(fireworks,{
      x=f.x,
      y=f.y,
      vx=0,
      vy=0,
      r=1+flr(rnd(1)),
      c=f.c
     })
    end
   end
  else
	  f.r-=0.025
	  f.vy+=0.05
   if f.r<=0 then
    del(fireworks,f)
   end
  end
 end
 newfireworktimer-=1
 if newfireworktimer<0 then
 --sfx(13+flr(rnd(3)))
  newfireworktimer=2+rnd(50)
  add(fireworks,{
		 x=136+rnd(64),
		 y=128,
		 r=3,
		 c=flr(rnd(#fireworkcolors))+1,
		 vx=rnd(2)-1,
		 vy=-2-rnd(2),
		 rkt=true
	 })
 end
end

function makeblock(_x,_y,_i)
 local _b={}
 _b.x=_x
 _b.y=_y
 _b.s=_i
 return _b
end

function newbubble(_x,_y)
 local _b={}
 _b.x=_x
 _b.y=_y
 _b.t=30
 _b.s=96
 _b.a=false
 _b.p=false
 return _b
end

function bubbleupdate(_b)
 if _b.a then
  _b.t-=1
  if _b.t<=0 then
   _b.s=97
   _b.a=false
   _b.p=true
   _b.t=120
  end
 elseif _b.p then
  _b.t-=1
  if _b.t==90 then
   _b.s=0
  elseif _b.t<=0 then
   _b.p=false
   _b.s=96
   _b.t=30
  end
 end
end

function bubblepop(_b)
 if(_b.s==96) _b.a=true
end

function makelyric(_l,_b)
 local ret={}
 ret.l=_l
 ret.b=_b
 return ret
end

function delsave()
 for i=0,8 do
  dset(i,false)
 end
end

function _init()
 menuitem(1,"delete save data",function() delsave() end)
 for i=0,6 do
  bonus[i]=false
 end
	--ladders between areas
	ladders={}
	ladders[0]={}
	ladders[0][0]=makeblock(0,0,0)
	ladders[0][1]=makeblock(64,224,86)
	ladders[0][2]=makeblock(80,200,86)
	ladders[0][3]=makeblock(64,176,86)
	ladders[0][4]=makeblock(80,152,86)
	ladders[0][5]=makeblock(64,128,86)
	ladders[0][6]=makeblock(80,104,86)
	ladders[1]={}
	ladders[1][0]=makeblock(64,352,100)
	ladders[1][1]=makeblock(80,328,100)
	ladders[1][2]=makeblock(64,304,100)
	ladders[1][3]=makeblock(80,280,100)
	ladders[1][4]=makeblock(64,256,100)
	ladders[2]={}
	ladders[2][0]=makeblock(0,0,0)
	ladders[2][1]=newbubble(80,496)
	ladders[2][2]=newbubble(72,472)
	ladders[2][3]=newbubble(80,448)
	ladders[2][4]=newbubble(72,424)
	ladders[2][5]=newbubble(80,400)
	ladders[3]={}
	ladders[3][0]=makeblock(72,616,42)
	ladders[3][1]=makeblock(80,616,58)
	ladders[4]={}
	ladders[4][0]=makeblock(80,744,99)
	ladders[4][1]=makeblock(72,744,98)
	ladders[4][2]=makeblock(88,720,98)
	ladders[4][3]=makeblock(96,720,99)
	ladders[4][4]=makeblock(80,696,99)
	ladders[4][5]=makeblock(72,696,98)
	ladders[4][6]=makeblock(88,672,98)
	ladders[4][7]=makeblock(96,672,99)
	ladders[4][8]=makeblock(80,648,99)
	ladders[4][9]=makeblock(72,648,98)
	ladders[5]={}
	ladders[5][0]=makeblock(88,888,59)
	ladders[5][1]=makeblock(88,880,27)
	ladders[5][2]=makeblock(88,872,27)
	ladders[5][3]=makeblock(88,864,27)
	ladders[5][4]=makeblock(88,856,27)
	ladders[5][5]=makeblock(88,848,27)
	ladders[5][6]=makeblock(88,840,27)
	ladders[5][7]=makeblock(88,832,27)
	ladders[5][8]=makeblock(88,824,27)
	ladders[5][9]=makeblock(88,816,27)
	ladders[5][10]=makeblock(88,808,27)
	ladders[5][11]=makeblock(88,800,27)
	ladders[5][12]=makeblock(88,792,27)
	ladders[5][13]=makeblock(88,784,27)
	ladders[5][14]=makeblock(88,776,27)
	ladders[5][15]=makeblock(88,768,27)
	ladders[5][16]=makeblock(88,760,27)
	ladders[6]={}
	ladders[6][0]=makeblock(56,992,17)
	ladders[6][1]=makeblock(64,992,18)
	ladders[6][2]=makeblock(80,968,17)
	ladders[6][3]=makeblock(88,968,18)
	ladders[6][4]=makeblock(56,944,17)
	ladders[6][5]=makeblock(64,944,18)
	ladders[6][6]=makeblock(80,920,17)
	ladders[6][7]=makeblock(88,920,18)
 --music(currentarea)
 --make lyrics
 local lset={}
 local l={}
 l[0]=makelyric("i'm ",16)
 l[1]=makelyric("so ",16)
 l[2]=makelyric("lone",16)
 l[3]=makelyric("ly ",16)
 l[4]=makelyric("way ",8)
 l[5]=makelyric("up ",16)
 l[6]=makelyric("here",42)
 lset[0]=l
 local l={}
 l[0]=makelyric("i ",16)
 l[1]=makelyric("wish ",16)
 l[2]=makelyric("some",16)
 l[3]=makelyric("one ",16)
 l[4]=makelyric("would ",8)
 l[5]=makelyric("kiss ",16)
 l[6]=makelyric("me",42)
 lset[1]=l
 lyrics[0]=lset
 local lset={}
 local l={}
 l[0]=makelyric("some ",32)
 l[1]=makelyric("damn ",32)
 l[2]=makelyric("bas",16)
 l[3]=makelyric("tard",64)
 lset[0]=l
 local l={}
 l[0]=makelyric("stole ",32)
 l[1]=makelyric("my ",32)
 l[2]=makelyric("legs!",48)
 lset[1]=l
 add(lyrics,lset)
 local lset={}
 local l={}
 l[0]=makelyric("i'm ",24)
 l[1]=makelyric("all ",24)
 l[2]=makelyric("toa",36)
 l[3]=makelyric("sty ",24)
 l[4]=makelyric("but",84)
 lset[0]=l
 local l={}
 l[0]=makelyric("i ",12)
 l[1]=makelyric("could ",12)
 l[2]=makelyric("use ",24)
 l[3]=makelyric("mar",24)
 l[4]=makelyric("ga",12)
 l[5]=makelyric("rine!",96)
 lset[1]=l
 add(lyrics,lset)
 local lset={}
 local l={}
 l[0]=makelyric("i've ",48)
 l[1]=makelyric("de",16)
 l[2]=makelyric("flat",24)
 l[3]=makelyric("ed",40)
 lset[0]=l
 local l={}
 l[0]=makelyric("please ",16)
 l[1]=makelyric("will ",16)
 l[2]=makelyric("you ",16)
 l[3]=makelyric("help ",24)
 l[4]=makelyric("me?",40)
 lset[1]=l
 add(lyrics,lset)
 local lset={}
 local l={}
 l[0]=makelyric("i'm ",16)
 l[1]=makelyric("miss",16)
 l[2]=makelyric("ing ",16)
 l[3]=makelyric("my ",16)
 l[4]=makelyric("head",40)
 lset[0]=l
 local l={}
 l[0]=makelyric("can ",16)
 l[1]=makelyric("you ",16)
 l[2]=makelyric("find ",48)
 l[3]=makelyric("it?",72)
 lset[1]=l
 add(lyrics,lset)
 local lset={}
 local l={}
 l[0]=makelyric("i ",12)
 l[1]=makelyric("stay ",12)
 l[2]=makelyric("down ",12)
 l[3]=makelyric("here",42)
 lset[0]=l
 local l={}
 l[0]=makelyric("for ",12)
 l[1]=makelyric("the ",12)
 l[2]=makelyric("mu",48)
 l[3]=makelyric("sic",48)
 lset[1]=l
 add(lyrics,lset)
 local lset={}
 local l={}
 l[0]=makelyric("these ",24)
 l[1]=makelyric("con",24)
 l[2]=makelyric("vey",12)
 l[3]=makelyric("ers",132)
 lset[0]=l
 local l={}
 l[0]=makelyric("drove ",24)
 l[1]=makelyric("me ",24)
 l[2]=makelyric("mad!",132)
 lset[1]=l
 add(lyrics,lset)
 local lset={}
 local l={}
 l[0]=makelyric("i'm ",16)
 l[1]=makelyric("stuck ",16)
 l[2]=makelyric("way ",16)
 l[3]=makelyric("down ",16)
 l[4]=makelyric("here",64)
 lset[0]=l
 local l={}
 l[0]=makelyric("please ",16)
 l[1]=makelyric("help ",16)
 l[2]=makelyric("me",88)
 lset[1]=l
 add(lyrics,lset)
 --scan map for npcs, coveyers, etc
 for y=0,1024,8 do
  for x=0,1024,8 do
   local npcmappos=pix2map(x,y)
   local t=mapget(npcmappos)
   if fget(t,1) then
    add(npc,makeblock(x,y,t))
    mapset(npcmappos,0)
   elseif fget(t,0) and fget(t,3) then
    add(pushblocks,makeblock(npcmappos.x,npcmappos.y,t))
   elseif t==1 then
    px=x
    py=y
    mapset(npcmappos,0)
   elseif t==96 then
    add(ladders[2],newbubble(x,y))
    mapset(npcmappos,0)
   end
  end
 end
 if cartdata("nicholas_walton_professor_blobbins_and_the_music_of_love") then
  --skip levels
  --dset(0,6)
  --dset(5,1)
  for i=dget(0),1,-1 do
	  beatarea()
	 end
	 for i=1,7 do
	  if dget(i)==1 then
	   bonus[7-i]=true
	  end
	 end
	 if(areatobeat!=7)didfirstfall=true
	end
end

function beatarea()
 if not inmenu and areatobeat!=0 then
  dset(0,8-areatobeat)
 end
 if areatobeat==0 then
  if(px>128)return
 	music(-1)
	 musicpaused=true
	 local lset={}
	 local l={}
	 l[0]=makelyric("yay ",16)
	 l[1]=makelyric("now ",16)
	 l[2]=makelyric("that ",16)
	 l[3]=makelyric("we've ",16)
	 l[4]=makelyric("had ",8)
	 l[5]=makelyric("our ",16)
	 l[6]=makelyric("kiss",42)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("please ",16)
	 l[1]=makelyric("pro",16)
	 l[2]=makelyric("fess",16)
	 l[3]=makelyric("or ",16)
	 l[4]=makelyric("ma",8)
	 l[5]=makelyric("rry ",8)
	 l[6]=makelyric("me!",42)
	 lset[1]=l
	 lyrics[0]=lset
	 mset(13,6,0)
	 mset(15,6,0)
	 pspr=101
	 pdir=1
	 py=112
  px=104
  pdir=1
	 pat=0
--	 npc[2].x=128
--	 npc[2].y=112
	 for i=3,#npc do
	  npc[i].x=112+(i-3)*16
	  npc[i].y=112
	 end
	elseif areatobeat==1 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("thanks ",32)
	 l[1]=makelyric("for ",32)
	 l[2]=makelyric("my ",16)
	 l[3]=makelyric("legs",64)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("let's ",16)
	 l[1]=makelyric("scu",16)
	 l[2]=makelyric("ttle ",32)
	 l[3]=makelyric("up",48)
	 lset[1]=l
	 lyrics[1]=lset
	 --move player
	 px=96
	 py=208
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==116) _n.s=118
	 end
	elseif areatobeat==2 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("thanks ",24)
	 l[1]=makelyric("for ",12)
	 l[2]=makelyric("the ",12)
	 l[3]=makelyric("mar",36)
	 l[4]=makelyric("ga",24)
	 l[5]=makelyric("rine",84)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("now ",12)
	 l[1]=makelyric("jump ",12)
	 l[2]=makelyric("on ",24)
	 l[3]=makelyric("these ",24)
	 l[4]=makelyric("pan",12)
	 l[5]=makelyric("cakes",96)
	 lset[1]=l
	 lyrics[2]=lset
	 --move player
	 px=96
	 py=312
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==112) _n.s=114
	 end
	elseif areatobeat==3 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("now ",48)
	 l[1]=makelyric("i'm ",16)
	 l[2]=makelyric("floa",24)
	 l[3]=makelyric("ting",48)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("thank ",32)
	 l[1]=makelyric("you ",16)
	 l[2]=makelyric("so ",24)
	 l[3]=makelyric("much!",40)
	 lset[1]=l
	 lyrics[3]=lset
	 --move player
	 px=96
	 py=496
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==40) _n.s=56
	 end
	 --reset arms
	 armtimer=0
	elseif areatobeat==4 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("you ",16)
	 l[1]=makelyric("got ",16)
	 l[2]=makelyric("me ",16)
	 l[3]=makelyric("my ",16)
	 l[4]=makelyric("head",40)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("i'll ",16)
	 l[1]=makelyric("give ",16)
	 l[2]=makelyric("you ",16)
	 l[3]=makelyric("a ",32)
	 l[4]=makelyric("ride",72)
	 lset[1]=l
	 lyrics[4]=lset
	 --move player
	 px=96
	 py=600
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==60) _n.s=62
	 end
	 --reset arms
	 armtimer=0
 elseif areatobeat==5 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("",12)
	 l[1]=makelyric("what ",12)
	 l[2]=makelyric("will ",12)
	 l[3]=makelyric("i",42)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("lis",12)
	 l[1]=makelyric("ten ",12)
	 l[2]=makelyric("to ",48)
	 l[3]=makelyric("now?",48)
	 lset[1]=l
	 lyrics[5]=lset
	 --move player
	 px=96
	 py=730
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==44) _n.s=46
	 end
	elseif areatobeat==6 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("what ",24)
	 l[1]=makelyric("did ",24)
	 l[2]=makelyric("he ",12)
	 l[3]=makelyric("use",132)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("as ",24)
	 l[1]=makelyric("the ",24)
	 l[2]=makelyric("rope?",132)
	 lset[1]=l
	 lyrics[6]=lset
	 --move player
	 px=96
	 py=848
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==28) _n.s=30
	 end
	elseif areatobeat==7 then
 	music(-1)
	 musicpaused=true
	 if(not inmenu) sfx(3)
		--music
	 local lset={}
	 local l={}
	 l[0]=makelyric("good ",16)
	 l[1]=makelyric("work ",16)
	 l[2]=makelyric("with ",8)
	 l[3]=makelyric("the ",8)
	 l[4]=makelyric("jump",16)
	 l[5]=makelyric("ing",64)
	 lset[0]=l
	 local l={}
	 l[0]=makelyric("now ",16)
	 l[1]=makelyric("let's ",16)
	 l[2]=makelyric("go ",88)
	 lset[1]=l
	 lyrics[7]=lset
	 --move player
	 px=0
	 py=1008
	 --make npc happy
	 for _n in all(npc) do
	  if(_n.s==7) _n.s=11
	 end
	end
 areatobeat-=1
end

function _update60()
 if inmenu then
  if btnp(0) then
   pcol-=1
  	pcol=pcol%16
   while pcol==0 or pcol==1 or pcol==2 or pcol==7 or pcol==8 or pcol==9 or pcol==10 or pcol==12 do
    pcol-=1
  		pcol=pcol%16
   end
  end
  if btnp(1) then
   pcol+=1
  	pcol=pcol%16
   while pcol==0 or pcol==1 or pcol==2 or pcol==7 or pcol==8 or pcol==9 or pcol==10 or pcol==12 do
    pcol+=1
  		pcol=pcol%16
   end
  end
  if btnp(4) or btnp(5) then
   inmenu=false
   startmusic()
  end
 end
 if not inmenu then
		pat+=1 --state timer
	 npcframe=flr(time()%2)
		beats+=1
	 if areatobeat>-1 then
		 armtimer+=1
		 playeronarms=false
		 --update pushblocks
		 for _pushblock in all(pushblocks) do
		  _pushblock.s+=0.1
		  if(_pushblock.s>=27)_pushblock.s=25
		  mset(_pushblock.x,_pushblock.y,flr(_pushblock.s))
		 end
		 --update robo arms
		 if areatobeat<4 then
		  if px+6>ladders[3][0].x and px-1<ladders[3][1].x+8 and abs(flr(ladders[3][0].y)-flr(py+8))<3 and pstate!=4 then
		   playeronarms=true
		  end
		  if(armtimer>=620) armtimer=0
		  if armtimer>420 then
		   ladders[3][0].y=504+112*(armtimer-420)/200
		   ladders[3][1].y=504+112*(armtimer-420)/200
		  elseif armtimer>100 and armtimer<300 then
		   ladders[3][0].y=616-112*(armtimer-100)/200
		   ladders[3][1].y=616-112*(armtimer-100)/200
		  end
		  if playeronarms then
		   py=ladders[3][0].y-8
		  end
		 end
		 local hmov=0
		 local vmov=0
		 local left=btn(0)
		 local right=btn(1)
		 local jump=btn(2)
		 --idle state
		 if pstate==0 then
		  pspr=1
		  if(left or right) changestate(1)
		  if canfall() then changestate(2)
		  else if(jump) changestate(4)
		  end
		 end
		 --walk state
		 if pstate==1 then
			 if(left) pdir=-1
			 if(right) pdir=1
			 hmov=pdir
			 pspr=1+flr(pat/8)%2
			 if(not (left or right)) changestate(0)
			 if(jump) changestate(4)
			 if(canfall()) changestate(2)
			end
			--fall state
			if pstate==2 then
			 pspr=3
				 if(left) pdir=-1 hmov=pdir
				 if(right) pdir=1 hmov=pdir
			  vmov=min(2,pat/2)
			end
			--land state
			if pstate==3 then
			 if(py==1008) didfirstfall=true
			 if(pat>12) pstate=0 jspd=2
			 pspr=4
			 if(left) pdir=-1 hmov=pdir*0.5
			 if(right) pdir=1 hmov=pdir*0.5
			 if(jump and pat>10) changestate(4)
			 if(canfall()) changestate(2)
			end
			--jump state
			if pstate==4 then
			 pspr=3
			 vmov=-max(0,jspd-(pat/11))
			 if(left) pdir=-1 hmov=pdir
			 if(right) pdir=1 hmov=pdir
			 if(not jump or pat>30) changestate(0)
			end
			if(onpushblock()) hmov-=1.5
			px+=hmov
			--wall collisions
		 local xmov=1
		 if(hmov>0) xmov=6
		 if fget(mapget(pix2map(px+xmov,py)),0) or fget(mapget(pix2map(px+xmov,py+7)),0) or fget(ladderget(px+xmov,py).s,0) or fget(ladderget(px+xmov,py+7).s,0) then
		  px=(flr(px-hmov)/8)*8
		 end
		 py+=vmov
		 --ceiling collisions
		 if vmov<0 then
		  local _t1=mapget(pix2map(px+1,py))
		  local _t2=mapget(pix2map(px+6,py))
		  local _l1=ladderget(px+1,py).s
		  local _l2=ladderget(px+6,py).s
		  if fget(_t1,0) or fget(_t1,5) or fget(_t2,0) or fget(_t2,5) or fget(_l1,0) or fget(_l1,5) or fget(_l2,0) or fget(_l2,5) then
		   py-=vmov
		  end
		 --floor collisions
		 elseif vmov>0 then
		  if not canfall() then
		   py=flr(py/8)*8
		   changestate(3)
		  end
		 end
		 --update bubbles
		 for _b in all(ladders[2]) do
		  bubbleupdate(_b)
		 end
		 --check if beat area
		 local pcell=pix2map(px+4,py+4)
		 if fget(mapget(pcell),2) then
		  beatarea(areatobeat)
		  for x=-1,1 do
		   for y=-1,1 do
		    local tempcell=pix2map(px+4+x*8,py+4+y*8)
		    if fget(mapget(tempcell),2) then
		     --mapset(tempcell,0)
		     fset(mapget(tempcell,2,false))
		    end
		   end
		  end
		 end
		 --check bonus
		 if fget(mapget(pcell),7) then
		  bonus[flr(py/128)-1]=true
		  dset(8-flr(py/128),1)
		  music(-1)
		  musicpaused=true
		  beats=0
		  sfx(3)
		  for x=-1,1 do
		   for y=-1,1 do
		    local tempcell=pix2map(px+4+x*8,py+4+y*8)
		    if fget(mapget(tempcell),7) then
		     mapset(tempcell,0)
		    end
		   end
		  end
		 end
			--keep player in bounds
		 px=max(0,px)
		 if(not didfirstfall) px=min(88,px)
		 px=min(1014,px)
			--move camera
			cx=cx*0.95+(px-60+pdir*16)*0.05
			cx=max(0,cx)
		 cx=min(cx,894)
		 cy=cy*0.95+(py-80)*0.05
			cy=max(cy,0)
			cy=min(cy,896)
		else
		 pspr=101+npcframe
			--move camera
			cx=cx*0.95+105*0.05
		 cy=cy*0.95
		 if(cy<1)cy=0
		 if(cy==0)updatefireworks()
		end
	end
	--progress lyrics
	if musicpaused then
	 if beats>150 then
	  musicpaused=false
		 currentarea=flr(py/1024*8)
	  startmusic()
	 end
	elseif beats>=lyrics[currentarea][lyrset][curword].b then
	 beats=0
	 curword+=1
	 if curword>#lyrics[currentarea][lyrset] then
	  curword=0
	  beats=0
	  lyrset+=1
	  if lyrset>#lyrics[currentarea] then
	   lyrset=0
			 --update music+lyrics
			 --currentarea=flr(py/512*7)
			 currentarea=flr(py/1024*8)
			 if currentarea!=lastarea then
     startmusic()
			 else
		   music(currentarea)
			 end
	  end
	 end
	end
end

function _draw()
 camera(cx,cy)
 cls()
 palt()
 if inmenu then
  cls(1)
 --
  print("á  á  á  á  á  á  á  á",0,2,8)
  print("  ç  ç  ç  ç  ç  ç  ç  ç",0,2,0)
  print("á  á  á  á  á  á  á  á",0,120,8)
  print("  ç  ç  ç  ç  ç  ç  ç  ç",0,120,0)
  --print("áçáçáçáçáçáçáçáç\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅ                            Å\nÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅ",0,0,11)
  print("professor blobbins",28,24,pcol)
  print("and the       of",21,32,7)
  print("music",53,32,0)
  print("love",88,32,8)
  print("by nicholas walton",28,40,7)
  print("z or x to start",34,56,7)
  print("ã and ë change colour",18,72,7)
  palt(0,false)
  palt(14,true)
  spr(106,64,84)--bookshelves
  spr(122,64,92)
  spr(106,56,84)--bookshelves
  spr(122,56,92)
  spr(105,76,96)--table
	 pal(11,pcol)
  spr(1+time()%2,60,96)--player
  pal()
 else
	 --make pink transparent
	 palt(0,false)
	 palt(14,true)
	 --draw bg
	 for i=flr(cy/128),flr(cy/128)+1 do
	  rectfill(0,i*128,1024,i*128+128,skycolor[i])
	 end
	 --ending screen
	 if areatobeat==-1 then
 	 --bonus npcs
		 for i=0,#bonus do
		  if(bonus[i]) spr(73+i+npcframe*16,120+i*16,112)
		 end
		 for _f in all(fireworks) do
		  circfill(_f.x,_f.y,_f.r,fireworkcolors[_f.c])
		 end
		 print("professor blobbins\n       and        \nthe music of love\n\nby nicholas walton",132,32,0)
	 end
	 --draw map
	 for i=flr(cy/128),flr(cy/128)+1 do
	  if i==0 or i==7 or didfirstfall then
	   map(0,i*8,0,i*128+64,128,8)
	  end
	 end
	 --draw ladders
	 for i=6,max(0,areatobeat),-1 do
	  for b=0,#ladders[i] do
	   spr(ladders[i][b].s,ladders[i][b].x,ladders[i][b].y)
	  end
	 end
	 --draw npcs
	 for n in all(npc) do
	  if n.y<128 or n.y>896 or didfirstfall then
	   spr(n.s+npcframe,n.x,n.y,1,1,n.x<px)
	  end
	  --print(""..npc[n].." "..npc[n+1]..","..npc[n+2])
	 end
	 --stuff on top layer
	 if areatobeat==0 then
	  print("human hair...\nfrom my back",264,64,0)
	  print("i can't believe\nit's not butter!",392,64,0)
	  print("~kiss de girl~",520,64,0)
	  print("professor blobbins\nand the music of love\n\nby nicholas walton\n\nthanks so much\nfor playing!",640,48,0)
	  print("thanks to my wife\nfroggie717\neditor",780,48,0)
	  print("find my other games at\nnicholaswalton.net",912,48,0)
	 end
	 --draw player
	 pal(11,pcol)
	 spr(pspr,px,py,1,1,pdir==-1)
	 pal()
	 --draw bonus dots
	 if areatobeat!=-1 then
		 for i=0,#bonus do
		  if bonus[i] then
	 	  pset(cx,cy+17+i*2,11)
		  else
	 	  pset(cx,cy+17+i*2,0)
		  end
		 end
		 --draw dot for player level
		 pset(cx+1,cy+17+max(0,flr(py/128)*2-2),6)
		end
	 --draw lyrics
	 if not musicpaused then
		 local lidx=currentarea
		 local lx=cx+4
		 local ly=cy+4
		 --local wordi=0
		 local wordcol=0
		 for wordi=0,#lyrics[lidx][lyrset] do
		  wordcol=0
		  if wordi==curword then
		   wordcol=8
		   if(ly>380 and ly<512) wordcol=7
		  end
			 if lx+#lyrics[lidx][lyrset][wordi].l*4 > cx+120 then
			  lx=cx+4
			  ly+=6
			 end
			 print(lyrics[lidx][lyrset][wordi].l,lx,ly,wordcol)
			 lx+=#lyrics[lidx][lyrset][wordi].l*4
		 end
		end
	end
end

function startmusic()
 if currentarea==0 or currentarea>=areatobeat then
  music(currentarea)
 else
  musicpaused=true
 end
 lastarea=currentarea
 lyrset=0
 beats=0
 curword=0
end

function canfall()
 if(playeronarms) return false
 --check map tile under player is floor
 local _t1=mapget(pix2map(px+6,py+8))
 local _t2=mapget(pix2map(px+2,py+8))
 local _l1=ladderget(px+6,py+8)
 local _l2=ladderget(px+2,py+8)
 if fget(_t1,0) or fget(_t1,4) or fget(_t2,0) or fget(_t2,4) or fget(_l1.s,0) or fget(_l2.s,0) or fget(_l1.s,0) or fget(_l1.s,4) or fget(_l2.s,4) then
  if(_l1.s==96) bubblepop(_l1)
  if(_l2.s==96) bubblepop(_l2)
  return false
 end
 return true
end

function onpushblock()
 local _s1=mapget(pix2map(px+7,py+8))
 local _s2=mapget(pix2map(px+2,py+8))
 if(fget(_s1,0)and fget(_s1,3))or(fget(_s2,0)and fget(_s2,3)) then
  return true
 end
 return false
end

function changestate(s)
 pstate=s
 pat=0
 if pstate==3 then
	 jspd+=0.2
	elseif pstate==4 then
  sfx(0)
	 if (jspd>2.5) jspd=2.5
 end
end

--function pix2map(_px,_py,_ox,_oy)
-- return mget(flr(_px/8)+_ox,flr(_py/8)+_oy)
--end

function pix2map(_x,_y)
 local tile={}
 local yeven=(flr(_y/64)%2)==0
 if yeven then
  tile.x=0
  tile.y=0
  return tile
 else
	 tile.x=flr(_x/8)
	 tile.y=flr(_y/8)-flr(_y/128)*8-8
	 return tile
 end
end

function mapget(_pos)
 return mget(_pos.x, _pos.y)
end

function mapset(_pos,_s)
 mset(_pos.x, _pos.y,_s)
end

function ladderget(_x,_y)
 _x=flr(_x/8)
 _y=flr(_y/8)
 for i=6,areatobeat,-1 do
  if i!=3 then
	  for b=0,#ladders[i] do
	   if flr(ladders[i][b].x/8)==_x and flr(ladders[i][b].y/8)==_y then
	    return ladders[i][b]
	   end
	  end
	 end
 end
 return ladders[0][0]
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end
__gfx__
eeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeeeeeeeeeeeeee77eeeee7722eeee7722eeeeeeeeeeeeeeeeeeee7722eeeeeeeeeeeeeeeeeeeee99eeeeeeeeeee
eeeeeeeeeee77eeeeeeeeeeeeee70eeeeeeeeeeeeee777eee777777ee207222ee207222eeee77eeeeee77eeee207222eee7722eeeeeeeeeeee9999eeeee99eee
eeeeeeeeeeb70beeeeee77eeeebbbbeeebb77bbee77777777777777e222c222222222222eef07feeeef07fee22222222e207222eeeeeeeeee779977eee9999ee
eeeeeeeeebbbbbbeeebb70beeebbbbeebbb70bbb771777777777777700222222002c2222effffffeeffffffe2222222222222222eeeeeeeee709907ee779977e
eeeeeeeeebbbbbbeebbbbbbbeebb00eebbbbbbbbe7711117717777172202222222022222effffffe8ffffffe7702222222222222eeeeeeeee999999ee709907e
eeeeeeeeebbbb00eebbbbb00eebbbbeebbbbb000ee77777e77111177e222222ee222222ee88ffffee8fffffe0022222e77022222eeeeeeeee900009ee999999e
eeeeeeeeebbbbbbeebbbbbbbeebbbbeebbbbbbbbeeeeeeeeee77777eee2922eeee2922eeeffffffe8ffffffeee2922ee0029222ee6e6e6e6e990099e99000099
eeeeeeeeeebbbbeeeebbbbbeeeebbeeeebbbbbbeeeeeeeeeeeeeeeeeee9944eeee9944eeeeffffeeeeffffeeee9944eeee9922ee00000000e999999e99900999
ffffffffeffffffffffffffe4444444ff444444444444444f44444444444444f44444444e6eee6eeeee6eee6ee5440eeeee99eeeeee99eeeeee99eeeeeeeeeee
aaaaaaaafaaaaaaaaaaaaaaf4444444ff444444444444444f44444444444444f444444446aaa6aaaaa6aaa6aee0544eeee9999eeee9999eeee9999eeeee99eee
99999999f99999999999999f4444444ff444444444444444f44444444444444f444444449699969999969996ee4054eee779970ee079977ee779970eee9999ee
99999999f99999999999999f4444444ff444444444444444f44444444444444f444444449999999999999999ee4405eee079977ee779970ee079977ee079977e
99999999f99999999999999f4444444ff444444444444444f44444444444444f444444449999999999999999ee5440eee999999ee999999ee999999ee779970e
99999999f99999999999999f4444444ff444444444444444f44444444444444f444444449999999999999999ee0544eee990099ee990099ee900009ee999999e
44444444f44444444444444f4444444ff444444444444444f44444444444444f444444444444444444444444ee4054eee990b99ee990099ee990b99e99000099
44444444f44444444444444f4444444ff4444444ffffffffeffffffffffffffe444444444444444444444444ee4405eee999999ee999b99ee999999e99900b99
eeeeeeeeeeeeeeffeeeeeee6eeeeeeeeeeeeeee997eeeeeeeeeeee5eeeeeeeeeeeeeeeeeeeeeeeee65555555ee5440eeee9999eee9999eeeee9999eeee4999ee
eeeeeeeeeeeeefaaeeeee060000eeeeeeeeee99aa67eeeeeeeeeeee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0544eee444999e444999eee444999ee444499e
eeeeeeeeeeeeef99eeee0088a800eeeeeeee96aa6aa7eeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4054eeee0fa4eee0fa4eeeee0ff4eeeef0ffee
eeeeeeeeeeeff444eeee08888a80eeeeeee9aa6a6aa7eeeeeeeeeeee77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4405eeeeff44eeeff44eeeeeff44eeee0ff4ee
eeeeeeeeeefaaaaaeee60f5ff5f0eeeeeee9aaa66aa7eeeeeeee66666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeee5440eeeeedceeeeeedceeeeeedfeeeeeedceee
eeeeeeeeeef99999ee6e0ff00ff6eeeeee96666a6aa7eeeeeee6666666666eeeeeeeeeeeeeeeeeeeeeeeeeeeee0544eeeeedfeeeeeedfeeeeeeddeeeeeedfeee
eeeeeeeeff444444eeeeaef55fe0eeeeee9aaaa66a09eeeeee006666666600eeee999deeee999deeeeeeeeeeee4054eeeee33eeeeee33eeeee655eeeeee33eee
eeeeeeefaaaaaaaaeeee0e0000eaeeeeeee9666a0099eeeeee006666666600eee99999dee99999deeeeeeeeeee4405eeee655eeeee655eeeee500eeeee655eee
eeeeeeef99999999eeee650ff050eeeeeeee999999999eeeeee6666666666eeeee9999eeeeeeeeee55555556ee5440eeeeeeeeeeeeeeeeeeeee5eeeeeee5eeee
eeeeeff444444444eee7557ff7557eeeeeeeeeeeeee99eeeeee6666666666eeee776677eee9999eeeeeeeeeeee0544eeeeeeeeeeeeeeeeeeeeee7eeeeeee7eee
eeeefaaaaaaaaaaaeee7755775577eeeeeeeeeeeeee66eeeeee6666666666eeee709907ee776677eeeeeeeeeee4054eee5eeeeeeeeeeee5ee506605eee0660ee
eeeef99999999999ee779905555777eeeeeee56665e9eeeeeee6666666666eeee999999ee709907eeeeeeeeeee4405eee5eeeeeeeeeeee5ee5e66e5eeee66eee
eeff444444444444ee77e440444e77eeeeee5655999eeeeeeee6666666666eeeee9999eee999999eeeeeeeeeee5440eeee5555eeee5555eeee5555eeee5555ee
efaaaaaaaaaaaaaaee7fe333333ef7eeeee445666544eeeeeeee66666666eeeeeee99eeeee9999eeeeeeeeeeee0000eeeee66e5ee5e66eeeeee66eeee5e66e5e
ef99999999999999eeeee33ee33eeeeeeefffffffffffeeeeeeeee5555eeeeeeeeeddeeeeee99eeeeeeeeeeeeee00eeeee6ee65ee56ee6eeee6ee6eee56ee65e
f444444444444444eeeee44ee44eeeeeee44444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeeeeeeeeee5ee5eeee6ee6eeee6ee6eeee6ee6eeee6ee6ee
eeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eeee2e2ee2e2e55ee55eee8888eeeee3eeeeee9999eeee44eeeeee9977ee
eeeeeeeeee67e6eeeeeeeeeeeeeeeeeeeeeeee88eeeeeeeeeeeeeeeeeeee0aaaaaaa0eeee07ee70e57755775e778877eeeee6eeee99999eee4444eeee999709e
ee666eeeee6ee6eeeeeeeeeeeeeeeeeeeeeee88888eeeeeeeeeeeeeeeee0a9999999a0eee77ee77e57044075e708807ee30bb03ee99440eee44f0eee99999999
e6e776eeeee66eeeeeeeeeeeffeeeeeeeeeee888228eeeeeeeeeeeeeee0a990000099a0eee5ee5ee54444445e888888ee3ebbe3ee99944eee44ffeee99999999
e6ee76eeeeeeeeeeeeeeefffffffeeeeeeeeeee88888eeeeeeeeeeeeee0990eeeee0990eee2222ee5444a445ee8888eeee3333eeee948eeee447eeee99999099
e6eee6eeee666eeeeeefffffffffaeeeee8eeeee88828eeeeeeeeeeeeee00eeeeee0990ee202202e54044045eee88eeeeeebbeeeeee88eeeee75f8aee999990e
ee666eeee6eee6eeee9ffffffaaaaeeee888eeeee8828eeeeeeeeeeeeeeeeeeeee09990e2220022254400425eeeddeeeeebeebeeeee556eeee77eeeeee99b9ee
eeeeeeee6e77ee6eee99ffaaaaaaa5eee888eeeeee8888eeeeeeeeeeeeeeeeeee0a990ee2eeeeee2e555555eeeeeeeeeeebeebeeeee005eeee75eeeeee33bbee
ee6666ee6e7eee6ee5999aaaaaaaa56ee8888eeeeee888eee88ee88eeeeeeeee0a990eeeeeeeeeeeeeeeeeeeeeeeeeeeeee3eeeeee9999eeee44eeeeeeeeeeee
e6eeee6e6eeeee6e65999aaaaaaa567eee8288eeeeee88ee88888888eeeeeee0a990eeee2e2ee2e2e55ee55eee8888eeeeee6eeee99999eee4444eeeee9977ee
6ee77ee6e6eee6ee76599aaaa55567eeee82888eeeeeeeee88888888eeeeee0a990eeeeee07ee70e57755775e778877eee0bb0eee94404eee44f0eeee999709e
6eee7ee6ee666eeee7659a5556667eeeeee88888eeeeeeee88888888eeeeee0990eeeeeee77ee77e57044075e708807eeeebbeeee99440eee44ffeee99999999
6eeeeee6eeeeeeeeee7655666777eeeeeeee88228eeeeeee88888888eeeeeee00eeeeeeeee5ee5ee54444445e888888eee3333eee9928eeee447eeee99999999
6eeeeee6eeeeeeeeeee766777eeeeeeeeeeeee88888eeeee88888888eeeeee0aa0eeeeeeee2222ee5404a045ee8888eee3ebbe3eeee48eeeee755f8a99999099
e6eeee6eeeeeeeeeeeee77eeeeeeeeeeeeeeeeee888eeeeee888888eeeeeee0990eeeeeee202202e54400425eee88eeee3beeb3eeeeaaeeeee77eeeee999b90e
ee6666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88eeeeeeeeee00eeeeeee22200222e555555eeeeddeeeeebeebeeeee556eeee75eeeeee99bbee
ee6666eeeee7eeeeeee00000000000eeeeeaaeeeeeeeeeeeeeeeeeeeee77eeeeee77eeee444444ee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e6eeee6ee6eeee6eeee0eeeeeeeee0eeeffffffeeee77eeeeee77eeeee07eeeeee07eeee9444444e496f2984eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
6ee77ee6ee6ee6eeeee00000000000eee444444eeeb70beeeeb70beeebbbbeeeebbbbeee9e444444496f2984eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
6eee7ee6eeeeeee7eee0eeeeeeeee0eeeffffffeebbbbbbeebbbbbbebbbbbbeebbbbbbee9e9ee9e9496f2984eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
6eeeeee67eeeeeeee000eeeeeee000eea444444aebbbbbbeebbbbbb000bbbbbe00bbbbbe9e9ee9e9496f2984eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
6eeeeee6ee6ee6ee0000eeeeee0000ee77777777ebbbb00eebbbbb0ebbb3b3bebbb3b3be9e9ee9e9496f2984eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e6eeee6ee6eeee6e0000eeeeee0000ee66666666ebbbbbbeebbbbbb0eee3e33eebb3e33eee9eeee9496f2984eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee6666eeeeee7eeee00eeeeeeee00eeee666666eeebbbbeeeebbbbeeee33ee33ee33ee33ee9eeee944444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e44ee44eeeeeeeeee44ee44eeeeeeeeeeeeeeeeeeeeeeeeee07ee70eeeeeeeeeeeeeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
47744774e44ee44e47744774e44ee44eeeeeeeeeeeeeeeeee77ee77ee07ee70eeeeeeeeeeeeeeeee48f92f64eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
470ff07447744774470ff07447744774e07ee70eeeeeeeeeee5ee5eee77ee77eeeeeeeeeeeeeeeee48f92f64eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
4ffffff4470ff0744ffaaff4470ff074e77ee77e07eeee70ee8888eeee5ee5eeeeeeeeeeeeeeeeee48f92f64eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
4ffffff44ffffff44ffaaff44ffaaff4ee5ee5ee775ee577e808808eee8888eeeeeeeeeeeeeeeeee48f92f64eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
4ff00ff44ff00ff44f0ff0f44f0aa0f4ee8888eeee8888eee880088ee808808eeeeeeeeeeeeeeeee48f92f64eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
4f0ff0f44f0ff0f44ff00ff44ff00ff4e880088ee880088e88eeee8888800888eeeeeeeeeeeeeeee48f92f64eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
e444444ee444444ee444444ee444444ee808808ee808808e8eeeeee88eeeeee8eeeeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00404040
00000000000000000000000000000000000000000000d0000000000000000000000000000000000000d00000000000d000000000000000000000000000000000
00000000d000000000000000000000000000000000000000000000000000000000000000001121d0d0d0d09191d0d0d0d09191d0d0d0d0919100000000748400
00000000000000000000000000000000000000000000b2000000000000000000000000000000000000b20000000000b200000000000000000000000000000000
00000000b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2000001000000758500
00000000000000000000000000000000000000000000b1001101012100000000000000000000000000b10000000000b100000000000000000000000000000000
00000000b100000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000b1000000110101010101
00000000000000000000000000000000000000000000b1004181813100000000000000000000000000b10000000000b100000000000000000000000000000000
00000000b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1000000000000000000
00000000000000000000000000000000000000000000b1004181813100000000000000000000000000b30000000000b300000000000000000000000000000000
00000000b300000000000000000000000000000000000000010000000000000000001121000000919191910000001101210000000000b3000000000000627200
00000000000000000000000000000000000000000000b30061515171d0d0d0d0110101210000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0110101210000d0d0919191
d0d0d0d0d0d0d0d091919191d0d0d0d0110101210000d0d0d0d0d0d0d0d0d0d0d0d04131000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000637300
000000000000000000000000000000c3000000000000000000000000000000004181813100000000000000000000000000000000004181813100000000000000
00000000000000000000000000000000418181310000000000000000000000000000413100000000000000000000000000000000000000000000000000000000
00000000000000000000000011010101010101010101010191919191919191918181818101019191919191919191919191919191918181818101019191919191
91919191919191919191919191919191818181810101919191919191919191919191818101010191919191919191919191919191919191919101010101010101
00000000000000000000000000000000000000000000d000000000000000000000d0000000000000000000000000000000d00000000000000000000000000000
d0000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000748400
00000000000000000000000000000000000000000000b200000000000000000000b2000000000000000000000000000000b20000000000000000000000000000
b2000000000000000000000000000000000000000000000000000000b2000000110101210000000000009191000000009191d0d0d0d09191d011210000758500
00000000000000000000000000000000000000000000b100001101210000000000b1000000000000000000000000000000b10000000000000000000000000000
b1000000000000000000000000d00000000000000000000000000000b10000004181813100000000000000000000000000000000000000b20000610101010101
00000000000000000000000000000000000000000000b100004181310000000000b1000000001101010121000000000000b10000000000112100000000000000
b1000000000000000000000000b20000000000000000000000000000b10000004181813100000000000000000000000000000000000000b10000000000000000
00000000000000000000000000000000000000000000b100004181812100000000b3000000004181818181010121000000b30000000000618121000000000000
b3000000000000000000000000b10000000000000000000000000000b30000004181818121000000000000000000000000000000000000b10000000000425200
00000000000000000000000000000000000000000000b1000041818131000000d0d0d0d0d0d041818181818181310000d0d0d0d0d0d0d0d061710000d0d0d0d0
d0d0d0d0110101210000d0d0d0b3d0d0d0110101010121000000000000000000418181813100000000000000001121d0d0d01121d0d0d0b3d0d0000000435300
0000000000000000000000000000000000c200000000b30000418181310000000000000000004181818181818131000000000000000000000000000000000000
00000000418181310000000000000000004181818181310000000000000000004181818131000000000000000000000000000000000000000000000000000000
00000000000000000000000011010101010101010101010101818181810101919191919191918181818181818181010191919191919191919101010191919191
91919191818181810101919191919191918181818181810101010101010101018181818181010101010101010191919191919191919191919191010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000009191000000001101210000000091919121000000000000748400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000112100000000000000000000000000000061515171000000000000758500
00000000000000000000000000000000000000000000000000000000919191000000112100000000919191000000919191010121000000000000000000000000
00110101010101010121000000009191919100000091919191000000000000000000000000000000000000000000000000000000000000000000919101010101
00000000000000000000000000000000000000000000000000000000000000000000413100000000000000000000418181818131000000000000000000000000
00418181818181818131000000000000000000000041818131000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001121000000000000000000418121000000000000000000418181818181210000000000919191910000
00418181818181818181210000000000000000000041818131000000000000000000000000000000000000000000000000000000919100000000000000000000
00000000000000000000000000000000000000000000118131000000000000000000418131000000000000000000418181818181310000000000418181310000
00418181818181818181310000000000000000000041818131000000009191919100000000000000919191000000000000000000413100000000000000223200
000000000000000000000000000000c1000000000000418131000000000000000000418131000000000000000000418181818181310000000000418181310000
00418181818181818181310000000000000000000041818131000000004181813100000000000000418131000000000000000000413100000000000000233300
00000000000000000000000011010101019191910101818181019191919191919191818181010101010101010101818181818181810191919191818181810101
01818181818181818181810101010101010101010181818181010101018181818101019191919191818181019191919191919191818101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001101012100000000000000000000000000000000000000000000000000000000000000748400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000110121000000000000000000006151518121000000000000000000000000110101010101012100000000001121000000758500
00000000000000000000000000000000000000000000000000000000001101210000000000000000000000000011012100000011210000000000112100000000
00000000000000112100000000615171000000000011012100000000006171000000001101012100000000000000000000000000000000006151010101010101
00000000000000000000000000000000000000000000000000000000004181310000000000000000112100000061517100000061710000000000413100000000
00000000000000617100000000000000000000000041818121000000000000000000000000000000000000000000000011210000000000000000000000000000
00000000000000000000000000000000000000000000110121000000004181812100000000000000418121000000000000000000000000000000418121000000
00000000000000000000000000000000000000000041818181210000000000000000000000000000000000000000000041310000000000000000000000021200
00000000000000000000000000000000000000000000615171000000004181813100000000000000418131000000000000000000000000000000418131000000
00000000000000000000000000000000000000000041818181310000000000000000000000000000000000000000000041310000000000000000000000031300
00000000000070000000000000000000000000000000000000000000004181813100001121000000418131000000000000000000000000000000418131000000
00000000112100000000000000000000000000000041818181310000000000000000000000000000000000001121000041310000000000000000000000000000
01010101010101010101010101010101010101010101010101010101018181818101018181010101818181010101010101010101010101010101818181010101
01010101818101010101010101010101010101010181818181810101010101010101010101010101010101018181010181810101010101010101010101010101
__gff__
0000000000000002020202020220040201010101010101010109091002020202040404040404040402021000020202020404040404040404020210100202020204040404040404808000000000000000040404040404018080000000000000005000010101020202020000000000000002020202020202020000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000005000600000000000000000000000000000000000000000000000000000000000000000000000500000606000000000000000000000000000000000000000000000000000000000006050500000000000000000000000000000000050600000000060000000000000000
0000000005000000000000000600000000000000000000000000000000000005050600222300000000050005060000000000004243000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000006000000000500000000000000000000000000000000000005050000
0000000000000000000000050000000000000000000500000000000000000000000000323300000000000000000000000606005253050000060000000000000000000000760000000000000000000000000000000000000000000000000000000000000000670000000000000000000000000000000000000000000000000000
0000000006060000000000000000000600000000000000000000000000000000060000111205000000000000000000000000001112000000000000000500000000000011101200000006000000000000000000000000000000000000000000000000000511101200000000000000000000000000000005000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000141300000000000000000000000000001413000000000000000000000000000014181300000000000000000005000000000000000000000000000000000000000014181300000000000000000000000000000000000000000000000006
0001000000000000000000000046094600000000000000000000000000000000000000141300000000000000000000000000001413000000000000000000000000000014181300000000000000000000000000000000000000000000000000000000000014181300000000000000000000000000000000000000000000000000
1010120000000000000000001110101010101010101010101010101010101010101010181810101010101010101010101010101818101010101010101010101010101018181810101010101010101010101010101010101010101010101010101010101018181810101010101010101010101010101010101010101010101010
0000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019190000000000000000474800
0000000000000000000000000000000000000000002b00000000000000000000000000000000000000000000000000000000001919191900000000000000000000000000002b00000000000000000000000000000000000000000010000000001000000000000000000000000000000000000000000000000060000000575800
0000000000000000000000000000000000000000001b00000000000000000000606060000000111012000000001919191900001418181300000000000000000000600000003b00000000000000000000000000111012000000000000000000000000000000606060000000001110120000000000000000000000111010101010
0000000000000000000000000000000000000000001b00000019191912000000000000000000141813000000000000000000001418181300000000000060600000000000000000000000000011101200000000141813000000000000000000000000000000000000000000001418130000000000000000000000000000000000
0000000000000000000000000000000000000000001b00000014181813000000000000000000141818120000000000000000001418181300006060000000000000000000000000000000000000000000000000141813006000000000000000000000000000000000000000001418130000000000000000000000000000444500
0000000000000000000000000000000000000000003b00000014181813000000000000000000141818130000000000000000001418181300000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000000000000000000000141813000000000000000000000000000000000000000000001615170000000000000000000000000000545500
0000000000000000000000000000007400000000000000000014181813000000000000000000141818130000000000000000001418181300000000000000000000000000000000000000000000000000000000141813000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000001110101010101010101010101018181818101010101010101010181818181010101010101010101818181810101919191919191919191919191919191010101010101010101010181818101010101010101010101010101010101010101010101919191010101010101010101010101010101010
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000060000000000000000000474800
0000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000600000000000000000002b00000000000000000000000000000000000000000000000000000000000000000000000000000000002b00000019190000000000000000000000000000575800
0000000000000000000000000000000000000000001110120000000000600000000000000000000000000011101012000000600000000019120000000000001b00000000000000000010000000001919190000000000000000000000000000000000000000000000001b00000000000000000000000000000000111010101010
0000000000000000000000000000000000000000001418130000000000000000000000000000006000000014181813000000000000001918181200000000001b00000000600000000000000000001615170000000000000000000000000000000000000000000000001b00000000000000000000000000000000000000000000
0000000000000000000000000000000000000060001418181200000000000000000000000000000000000014181813006000000000191818181300000000001b00000000000000000000000000000000000000006060606060600000000060600000000011120000001b00000000000000000000000000000000000000424300
0000000000000000000000000000000000000000001418181300000000000000000000000000000000000014181813000000000019181818181300000d0d0d3b0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000003b00000000000000000000000000000000000000525300
0000000000000000000000000000007000000000001418181300000000000000000000000000000000000014181813000000001918181818181300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000001110101010101010101818181810101010101010101010101010101010101018181818101919191818181818181810101919191919191919191919191919191919191910101010191919191919191919191919191919191919101010101010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000d000000000000000000000d0000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000d000019190000000019190000000019190000000000000000474800
00000000000000000000000000000000000000000000000000000000000000002b000000000000000000002b0000000000000000000000000000000000002b000000000000000000000000000000000000000000000000000000000000000000000000002b000000000000000000000000000000000000000000000000575800
00000000000000000000000000000000000000000000000000000000000000001b000000000000000000003b0000000011101200000000191919190000001b000000000000000000000000000000000000000000000000000000000000000000000000001b000000000000000000000000000000000000000011101010101010
00000000000000000000000000000000000000000000000000000000000000001b00000000000000000000000000000014181300000000000000000000003b000000000000000000000000000000000000000000000000000000000000000000000000003b000000000000000000000000000000000000000016151515151515
00000000000000000000000000000000000000000000000000111010120000003b0000000000000000000000000000001418181200000000000000000000000000000000001110120000000000000000000000000000000000111010120000000000000000000000000000000000000000000000000000000000000000404100
00000000000000000000000000000000000000191919190d0d161515170d0d0d0d0d0d0d0d11120000000000000000001418181300000d0d0d0d0d0d0d0d0d0d00000000001615170d0d0d0d0d111010120d0d1919190d0d0d161515170d0d0d0d000000111200000d0d111010120d0d0d191919000000000000000000505100
0000000000000000000000000000002800000000000000000000000000000000000000000014130000000000000000001418181300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001118130000000000000000000000000000000000000000000000000000
0000000000000000000000001110101010101019191919191919191919191919191919191918181010101010101010101818181810101919191919191919191919101010101919191919191919191919191919191919191919191919191919191910101818181010191919191919191919191919101010101010101010101010
__sfx__
000c00001c75024750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002055020500205502f500285502f50028550355002c55028550285502c5502c5501650020500195002b550205002b5502150024550145002455024500295502d5502d5503255032550145003f5003f500
0010000005140091000514005140051400514007140071400514005130051200511009100091000910008100011000514005130051500513009150091400913009120091100e1000910009100091000910001100
00080000213702135021350213501d350213502737024360273502b3402f330323203533038340383303832038310383103831000300003000030000300003000030000300003000030000300003000030000300
001800002505025030250502503028050250502503025020250102501025000250002500025000250002500025050250302505025030280502804028030280202801028010280002800028000280002800028000
000c00000815008150091500915008150081500915009150091100910009100091000910016100081500815007150071500815008150081500815008150081500815009150091500911009100091000910009100
001000000e2500e23010250102300e2500e2300e2500e2301025010230122001520016200182000e2500e2300d2500d2300e2500e2500e2500e2500e2500e2301025010250102501023010210392003b2003e200
001000001c3501c3501c3501c3501c3501c3501a3501a3501c3501c3501c3501e3501e3502530023300213001e3001c3501c3301a3501a3301c3501c3301e3501e3501e350213502135021320213100330001300
001800001b2501b2301b2501b2301e2501e2501e2301b2501b2301b2501b2201b20018200192001b2001d2001b250192501b2501b2301b2501b2501d2501f2501f2301f2101c2001e2001e2001c2001e2001e200
00100000092500925009250092000925009250092500b2000c2500c2500925009250092201a2001c2001e2000920009200092500923007250072300925009250092300c2000c2500c2300c2200c210392003a200
00100000256201f62018610106100c6100c61009600096000960009600146001660017600196001c6001d6001f600216002360025600286002a6002b6002d6002f60031600326003460036600386003a6003c600
001000001c620186201562012610106100f6100e6100e610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002f620256201b61019610186100f6000f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000017700187001a7001b7001c7001e7001f700207002270024700267002770032700307002f7002d70024700217001e7001b70018700167001470012700107000e7000c7000970006700037000170001700
000300003e050320502e0402a03028020280100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000310502e0402b0302802025010220102001020010200100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
04 01 42 43 44
04 09 42 43 44
04 08 42 43 44
04 07 42 43 44
04 06 42 43 44
04 05 42 43 44
04 04 42 43 44
04 02 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
