pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--tetyis
--by spaz48
function _init()
 prt={}
 frame=0
 ttlcnt=0
 mcur=0
 mode="title"
 level=1
 bg=true
 rotsys="srs" --"classic"
 goalsys="fixed"--"variable"
 randomizer="7bag"--"classic"
 currentblock=1--11--rnd(64)--1
 currentghost=1
 starttimer=0
 musicenabled=true
 prtenb=true
 if mode=="tet" then
  tetinit()
 end
end

--make guideline compliant
function _update60()
 frame+=1
 --camera(0,-128)--+frame%256)
 if mode=="menu" then
  currentsong=4
  musiccheck()
  if btnp(2) then mcur-=1 end
  if btnp(3) then mcur+=1 end
  if btnp(0) then
   if mcur==1 then
    currentblock-=1
    currentblock=mid(0,currentblock,63)
   end
   if mcur==2 then
    currentghost-=1
    currentghost=mid(0,currentghost,63)
   end
  end
  if btnp(1) then
   if mcur==1 then
    currentblock+=1
    currentblock=mid(0,currentblock,63)
   end
   if mcur==2 then
    currentghost+=1
    currentghost=mid(0,currentghost,63)
   end
  end
  if btnp(0) or btnp(1) or btnp(4) or btnp(5) then
   if mcur==3 then
    musicenabled=not musicenabled
   end
   if mcur==4 then
    if randomizer=="7bag" then randomizer="classic"
    else randomizer="7bag" end
   end
   if mcur==5 then
    if goalsys=="variable" then goalsys="fixed"
    else goalsys="variable" end
   end
   if mcur==6 then
    if rotsys=="srs" then rotsys="classic"
    else rotsys="srs" end
   end
   if mcur==7 then
    prtenb=not prtenb
   end
  end

  if btnp(4) or btnp(5) then
   if mcur==0 then
    tetinit()
    mode="tet"
    starttimer=2
   end
  end
 end
 if mode=="tet" then
  tetupdate()
 end
end

function _draw()
 if mode=="tet" then
  tetdraw()
 end
 if mode=="title" then
  level=frame%15
  cls()
  drawtitle()
 end
 if mode=="menu" then
  cls()
  --textbox("an error has occured.",63,63)
  level=frame%15
  drawbg()
  logodraw(16,0,0,1,1,120,1)
  menustr={"sTART gAME","mINO dESIGN:"..currentblock.."   ","gHOST dESIGN:"..currentghost.."   ","mUSIC:"..tostr(musicenabled),"rANDOMIZER:"..randomizer,"gOAL sYSTEM:"..goalsys,"rOTATION sYSTEM:"..rotsys,"pARTICLES:"..tostr(prtenb)}
  mcur=(mcur%#menustr)
  for i=-2,2 do
   pal(7,6)
   pal(6,13)
   textbox(menustr[(mcur-i)%#menustr+1],64,64-(i*12))--28+i*12)
  end
  pal(7,7)
  pal(6,6)
  textbox(menustr[mcur+1],64,64)
  if mcur<=3 or mcur==7 then
   local xo=0
   if currentblock>9 then xo=2 end
   palt(9,false)
   pal(4,4)
   pal(15,15)
   if mcur==7 then
    spr(currentblock,89+xo,63-((mcur-9)*12))

   else
    spr(currentblock,89+xo,63-((mcur-1)*12))
   end
  end
  if mcur<=4 then
   local xo=0
   if currentghost>9 then xo=2 end
   palt(9,true)
   pal(4,13)
   pal(15,7)
   spr(currentghost,89+xo,63-((mcur-2)*12))
  end
 end
 pal(5,140,1)
 if phase=="end" then
  if score>0 then
   textbox("fINAL sCORE:"..score.."0",64,52)
  else
   textbox("fINAL sCORE:"..score,64,52)
  end
  textbox("gAME oVER",64,64)
  textbox("cTRL+r tO rESTART",64,76)
 end
--[[ print('mem:'..stat(0),0,0,7)
 print('cpu:'..stat(1),0,6,7)
 print('particles:'..#prt,0,12,7)]]
end

function drawtitle()
 --play thunder sound
 if ttlcnt==0 then  sfx(40,2) end
 --increment counter
 if ttlcnt<200 then
  ttlcnt+=1
 end
 if (btnp(4) or btnp(5)) then
  --skip intro if button is pressed and mute thunder
  if ttlcnt<200 then ttlcnt=200 sfx(-1,2)
  --if already past info then go to menu
  else mode="menu" if btn(3) then bg=false end end
 end
 --draw logo with electricity effects using shake
 if ttlcnt<160 then
  local logox=16 logoy=32
  logodraw(logox,logoy,8,1,1,flr(ttlcnt/2),1)
  logodraw(logox+1,logoy+1,8,1,1,flr(ttlcnt/2),1)
  logodraw(logox,logoy,2,1,1,flr(ttlcnt/2),12)
  logodraw(logox+1,logoy+1,2,1,1,flr(ttlcnt/2),12)
  logodraw(logox,logoy,0,1,1,flr(ttlcnt/2),7)
 end
 --flash the screen
 for i=1,8 do
   if ttlcnt>=158+(i*2) and ttlcnt<163+(i*2) then
    colors={13,7,15,6,13,5,1,0,3}
    cls(colors[i])
    --palt(colors[j],true)
    --palt(colors[i],false)
   end
  end
  --draw the background
  if ttlcnt>190 or (ttlcnt>160 and colorblend(0,1)==1) then drawbg() end
  --draw the actual title screen
  if ttlcnt>162 then
   local counter
   if counter==nil then counter=0 else counter+=1 end
   --sspr(0,96,96,127,16,32,96,32)
   --sspr(96,96,128,128,48,64,32,32)
   spr(192,16,32,12,4)
   spr(204,48,64,4,4)
   logodraw(16,32,-min(0,-(20-(ttlcnt-160))*4),1,1,flr(ttlcnt/2),1)
   logodraw(16,32,-min(0,-(20-(ttlcnt-160))*3),1,1,flr(ttlcnt/2),12)
   logodraw(16,32,-min(0,-(20-(ttlcnt-160))*2),1,1,flr(ttlcnt/2),3)
   logodraw(16,32,0,1,1,flr(ttlcnt/2),11)
   textbox("-pRESS — OR Ž-  ",64,max(80,counter))
   print("-sPAZ",108,122,7)
   print("1.01",1,122,7)
   --textbox("push the button to start the 2",64,max(96,counter)) --textbox("press — or Ž",60,max(80,counter))
  end
end

function textbox(str,x,y)
 local strl=(#str*2)
 --[[spr(144,x-strl-12,y-2,2,2)
 spr(146,x+strl+6,y-2,2,2)]]
 --draw a rectangle behind the text
 rectfill(x-strl-4,y-2,x-1+strl+4,y+7,1)
 --define the colors
 local tbcltbl={6,7,7,6,1,1,1,1,1}
 for i=1,#tbcltbl do
  --draw the diagonal bits and fill in the rest of the blue
  line(x-strl-8+i-4,y+6,x-strl+i-4,y-2,tbcltbl[i])
  line(x+strl-i+3,y+7,x+strl+7-i+4,y-1,tbcltbl[i])
 end
 --draw lines on the top and bottom
 line(x-strl-1,y-2,x+strl+10,y-2,7)
 line(x-strl-11,y+7,x+strl+1,y+7,7)
 --print the shadow
 print(str,x+1-strl,y+1,13)
 --print the text
 print(str,x-strl,y,7)
end

function logodraw(lx,ly,shk,scx,scy,stp,clr)
 --vector system to draw the logo
 --lx=location x, ly=location y, shk=shake amount, scx=stretch width, scy=stretch height,
 --stp=number of lines to render, clr=color
 --offset the logo so shaken layers line up
 lx-=shk/2
 ly-=shk/2
 --the main "tetyis" logo
 logot="01011701170712071230063006070107010100001801330130072407241030102815241524243424373018301801000034014901510652074507453039303907340734010000490156016112660173016419643058305820490100007301770177077107000071097709773071307109000078019401930192068406850794249430783078237924862478077801"
  for  i=1,min((#logot/4)-1,stp) do
   --get data from string
   local drs=(i*4)-3
   local drs2=(i*4)+1
   local pos1=tonum(sub(logot,drs,drs+1))
   local pos2=tonum(sub(logot,drs+2,drs+3))
   local pos3=tonum(sub(logot,drs2,drs2+1))
   local pos4=tonum(sub(logot,drs2+2,drs2+3))

   if pos1!=0 and pos2!=0 and pos3!=0 and pos4!=0 then
    --draw lines based on data from the string
    line(
    lx+(pos1+rnd(shk))*scx,
    ly+(pos2+rnd(shk))*scy,
    lx+(pos3+rnd(shk))*scx,
    ly+(pos4+rnd(shk))*scy,clr)
   end
  end
end
-->8
function tetinit()
 --initialize variables
 mode="tet"
 press=false
 autorepeat=0
 --camera=0
 holdnum=0
 minoinit(true)
 minolastx1=6
 minolastx=6
 lockdelay=30
 ghminox=6
 ghminoy=18
 locktimer=0
 speed=60
 minotimer=0
 holdused=false
 tetnum=0
 tspin=false
 backtoback=0
 gameover=false
 hdrop=false
 danger=false
 lastsong=0
 currentsong=1

 lines=0
 score=0
 subscore=0
 level=1
 oldgoal=0
 if goalsys=="variable" then
  goal=5
 elseif goalsys=="fixed" then
  goal=10
 end

 truespeed=((0.8-((level-1)*0.007))^(level-1))
 --init 7 bag
 bag={0,0,0,0,0,0,0}
 queue={}
 --init grid
 hitlist={}
 grid={}
 --layer2={}
 for i=1,10 do
  grid[i-1]={}
  --layer2[i-1]={}
  for j=1,40 do
   grid[i-1][j]=0
   --layer2[i-1][j]=0
  end
 end
 phase="setup"
end

function tetupdate()
 minolastx1=minolastx
 minolastx=minox
 score=flr(score)
 if starttimer>0 then starttimer-=1 end
 musiccheck()

 if phase=="setup" then
  phase="gen"
 end
 --generation phases
 if phase=="gen" then
  gen()
 end
 --falling phase
 --hard drop?
 if phase=="fall" then
  fall()
 end
 --lock phase
 --moved?
 --space to fall?
 --reset lockdown timer?
 if phase=="lock" then
  lock()
 end
 --pattern phase
 --pattern match?
 --mark block for destruction
 if phase=="patt" then
  patt()
 end
 --iterate phase
 if phase=="iter" then
  phase="anim"
 end
 --animate phase
 --for i=1,#layer2 do
  --for j=1,#layer2[1] do
   --if layer2[i-1][j]>0 then layer2[i-1][j]-=1 end
   --if layer2[i-1][j]<0 then layer2[i-1][j]+=1 end
  --end
 --end
 --[[if phase=="anim" then
  anim()
 end]]
 --eliminate phase
 --line clear?
 if phase=="elim" then
  elim()
 end
 --completion phase
 if phase=="comp" then
  comp()

 end
 --game over
 if phase=="over" then
  if overc==nil then overc=0 currentsong=0 else overc+=1 end
  if overc==60 then currentsong=3 musiccheck() phase="end" end
 end
 --game over
 if phase=="end" then
 end

 minoshape()
end

function minoinit(initial)
 if initial==nil then intiial=false end
 minox=4
 minolastx=minox
 minolastx1=minox
 minoy=17
 rotation=0
 if tetnum==0 then minoy=16 end
 if not initial then minoshape() end
end

---------------------------------------------------

function gen()
 if #queue>0 then
  for i=1, #queue do
   queue[i]=queue[i+1]
   queue[i+1]=nil
  end
 end
 repeat
  queue[#queue+1]=rndgen()
 until #queue==7
 tetnum=queue[1]
end

function rndgen()
 local rndnum
 if randomizer=="7bag" then
  rndnum=flr(rnd(7))+1
  local bagcnt=0
  for i=1,#bag do
   bagcnt+=bag[i]
   if bagcnt==7 then
    for j=1,#bag do
     bag[j]=0
    end
   end
  end
  repeat
   rndnum=flr(rnd(7))+1
  until bag[rndnum]==0
  bag[rndnum]=1
  phase="fall"
  add(queue,tetnum)
 elseif randomizer=="classic" then
  rndnum=flr(rnd(7))+1
  phase="fall"
  add(queue,tetnum)
 end
 return rndnum
end


function fall()
 minotimer+=1
 if starttimer==0 then inputmain() end
 if hdrop then locktimer=5
 else locktimer=lockdelay end
 if minotimer>speed then
  minotimer=0
  if not gridcheck(0,-1) then
   minoy-=1
   if btn(3) then subscore+=1 end
  else
   minotimer=speed
   lockcount=true
   phase="lock"
  end
 end
end

function lock()
 if hdrop==false then inputmain() end
 if lockcount then
  if gridcheck(0,-1) then
   minotimer=speed
   locktimer-=1
   if locktimer==0 then placemino() end
  else
   minotimer=0
   lockcount=false
   minoy-=1
   minotimer+=1
   locktimer=lockdelay
   phase="fall"
  end
 end
end

function patt()
 for i=1,40 do
  linecount=0
  for j=1,10 do
   if grid[j-1][i]>0 and grid[j-1][i]<8 and i>16 then gameover=true end
   if grid[j-1][i]>0 and grid[j-1][i]<8 then linecount+=1 end
   if linecount==10 then add(hitlist,i) end
  end
 end
 if gameover==true then phase="over"
 else phase="iter" end
end

function anim()
 --local animcounter
 local atb={131,132,133,134,134,134,134,134,134,134,133}
 if animcounter==nil then animcounter=0
 else animcounter+=1 end
 if #hitlist>=4 then
  printsh("tetyis",0,82)
  --logodraw(16,(animcounter*animcounter/4),2,1,1,200,11)
  if backtoback>0 then
   printsh("back",4,89)
   printsh("to",8,96)
   printsh("back",4,103)
  end
 elseif #hitlist==3 then
  printsh("triple",0,82)
 elseif #hitlist==2 then
  printsh("double",0,82)
 elseif #hitlist==1 then
  printsh("single",0,82)
 end

 if animcounter==10+(#hitlist*3) or #hitlist==0 then phase="elim" animcounter=nil end
 for i=1,#hitlist do
  for j=1,10 do
   if animcounter!=nil then
    spr(atb[mid(0,flr(animcounter+1),10)],16+(j*8),128-hitlist[i]*8)
   end
  end
 end


end

function elim()
 if #hitlist>=4 then sfx(4) end
 for i=1, #hitlist do
  removeline(hitlist[#hitlist-i+1])
 end
 danger=false
 currentsong=1
 for i=1,40 do
  for j=1,10 do
   if grid[j-1][41-i]>0 and grid[j-1][41-i]<8 and i<28 then
    currentsong=2
    danger=true
   end
  end
 end
 phase="comp"
end

function comp()
 newlines=0
 local btbmp=1
 if backtoback>0 then
  btbmp=1.5
 end
 if #hitlist==1 then
  score+=1*level*btbmp
  backtoback=0
 elseif #hitlist==2 then
  score+=3*level*btbmp
  backtoback=0
 elseif #hitlist==3 then
  score+=5*level*btbmp
  backtoback=0
 elseif #hitlist==4 then
  score+=8*level*btbmp
  backtoback+=1
 end
 if goalsys=="variable" then
  if #hitlist==1 then
   if tspin then newlines+=8
   else newlines+=1 end
  elseif #hitlist==2 then
   if tspin then newlines+=12
   else newlines+=3 end
  elseif #hitlist==3 then
   if tspin then newlines+=16
   else newlines+=5 end
  elseif #hitlist==4 then
   newlines+=8 end
 elseif goalsys=="fixed" then
  newlines+=#hitlist
 end
 if backtoback>1 then
  newlines+=newlines/2
 end
 for i=1, #hitlist do
  hitlist[i]=nil
 end
 lines+=newlines
 newlines=0
 truespeed=((0.8-((level-1)*0.007))^(level-1))
 speed=60*truespeed
 if lines>=goal+oldgoal then
  level+=1 oldgoal+=goal
  if goalsys=="variable" then goal=level*5 end
  if goalsys=="fixed" then goal=10 end
 end
 phase="gen"
end

------------------------------------------------

function gridcheck(xf,yf)
 minoshape()
 local vtbl={x0=minox,y0=minoy,x1=minox1,y1=minoy1,x2=minox2,y2=minoy2,x3=minox3,y3=minoy3}
 if mid(0,vtbl.x0+xf,9)!=vtbl.x0+xf or mid(0,vtbl.x1+xf,9)!=vtbl.x1+xf or
 mid(0,vtbl.x2+xf,9)!=vtbl.x2+xf or mid(0,vtbl.x3+xf,9)!=vtbl.x3+xf then return true
 elseif
 grid[vtbl.x0+xf][vtbl.y0+yf]==nil or --grid[vtbl.x0][vtbl.y0+yf]>10) or
 grid[vtbl.x1+xf][vtbl.y1+yf]==nil or --grid[vtbl.x1][vtbl.y1+yf]>10) or
 grid[vtbl.x2+xf][vtbl.y2+yf]==nil or --grid[vtbl.x2][vtbl.y2+yf]>10) or
 grid[vtbl.x3+xf][vtbl.y3+yf]==nil then return true--grid[vtbl.x3][vtbl.y3+yf]>10) then return true
 elseif
  grid[vtbl.x0+xf][vtbl.y0+yf]>0 or
  grid[vtbl.x1+xf][vtbl.y1+yf]>0 or
  grid[vtbl.x2+xf][vtbl.y2+yf]>0 or
  grid[vtbl.x3+xf][vtbl.y3+yf]>0 then
   return true
  else
   return false
  end
end

function inputmain()
 if autorepeat>0 then autorepeat-=1 end
 if not btn(0) and not btn(1) then autorepeat=0 press=false end
 if btn(0) and btn(1) then autorepeat=0 end

 if btn(1) and press==true and autorepeat==0  then
  if not gridcheck(1,0) then
   minox+=1
   sfx(2,2)
   autorepeat=3
   locktimer=lockdelay
  end
 elseif btn(0) and press==true and autorepeat==0 then
  if not gridcheck(-1,0) then
   minox-=1
   sfx(2,2)
   autorepeat=3
   locktimer=lockdelay
  end
 end

 if btn(1) and press==false and autorepeat==0 then
  if not gridcheck(1,0) then
   minox+=1
   sfx(2,2)
   autorepeat=18
   press=true
   locktimer=lockdelay
  end
 elseif btn(0) and press==false and autorepeat==0 then
  if not gridcheck(-1,0) then
   minox-=1
   sfx(2,2)
   autorepeat=18
   press=true
   locktimer=lockdelay
  end
 end

 if btn(4) and btnp(5) then hold()
 elseif btnp(4) and btn(5) then hold() end

 if btnp(4) and not btn(5) then rotate(-1) end
 if btnp(5) and not btn(4) then rotate(1) end

 if btn(3) then minotimer+=truespeed*19 end
 if btnp(2) then
  sfx(7,2)
  harddrop()
 end
 ghost()
end

function rotate(dir)
 sfx(0)
 rotation+=dir
 if rotation<0 then rotation=3 end
 if rotation>3 then rotation=0 end
 minoshape()
 if gridcheck(0,0) then
  if rotsys=="classic" then
   rotation-=dir
  elseif rotsys=="srs" then
   if tetnum==2 or tetnum==3 or tetnum==5 or tetnum==6 or tetnum==7 then
    rightsrstable={
    {{-1,0},{-1,1},{0,-2},{-1,-2}}, --0>1
    {{1,0},{1,-1},{0,2},{1,2}}, --1>2
    {{1,0},{1,1},{0,-2},{1,-2}}, --2>3
    {{-1,0},{-1,-1},{0,2},{-1,2}}} --3>0
    --[y][x][1/2]
    leftsrstable={
     {{1,0},{1,-1},{0,2},{1,2}}, --1>0
     {{-1,0},{-1,1},{0,-2},{-1,-2}}, --2>1
     {{-1,0},{-1,-1},{0,2},{-1,2}}, --3>2
     {{1,0},{1,1},{0,-2},{1,-2}}} --0>3
   elseif tetnum==1 then
    rightsrstable={
    {{-2,0},{1,0},{-2,-1},{1,2}},--0>1
    {{-1,0},{2,0},{-1,2},{2,-1}},--1>2
    {{2,0},{-1,0},{2,1},{-1,-2}}, --2>3
    {{1,0},{-2,0},{1,-2},{-2,1}}} --3>0
    --[y][x][1/2]
    leftsrstable={
     {{2,0},{-1,0},{2,1},{-1,-2}}, --1>0
     {{1,0},{-2,0},{1,-2},{-2,1}}, --2>1
     {{-2,0},{1,0},{-2,-1},{1,2}}, --3>2
     {{-1,0},{2,0},{-1,2},{2,-1}}} --0>3
    end
    --if rotation-dir==0 and dir==1 then
   local solved=0
   for i=1,4 do
    if solved==0 and dir==1 then
     if not gridcheck(rightsrstable[rotation+1][i][1],rightsrstable[rotation+1][i][2]) then
      solved=i
     end
    elseif solved==0 and dir==-1 then
     if not gridcheck(leftsrstable[rotation+1][i][1],leftsrstable[rotation+1][i][2]) then
      solved=i
     end
    end
   end
   if solved>0 then
    minoshape()
    minox+=(rightsrstable[rotation+1][solved][1])*dir
    minoy+=(rightsrstable[rotation+1][solved][2])*dir
    solved=0
    locktimer=lockdelay
   else
    rotation-=dir
   end
  end
 end
 if rotation<0 then rotation=3 end
 if rotation>3 then rotation=0 end
 minoshape()
end

function harddrop()
 repeat
  if not gridcheck(0,-1) then
   minoy-=1
   subscore+=2
  end
 until gridcheck(0,-1)
 --layer2[minox][minoy+1]=12
 --layer2[minox1][minoy1+1]=12
 --layer2[minox2][minoy2+1]=12
 --layer2[minox3][minoy3+1]=12
 minotimer=speed
 hdrop=true
end

function ghost()
 ghminox=minox
 ghminoy=minoy
 repeat
  if not gridcheck(0,ghminoy-minoy-1) then ghminoy-=1 end
 until gridcheck(0,ghminoy-minoy-1)
end

function hold()
 if holdused==false then
  holdused=true
  local temp=holdnum
  if holdnum>0 then
   holdnum=tetnum
   tetnum=temp
   minoinit()
  else
   holdnum=tetnum
   gen()
   minoinit()
  end
 if holdused==true then end
 end
end

function placemino()
 sfx(5,2)
 minoshape()
 lockcount=false
 holdused=false
 hdrop=false
 grid[minox][minoy]=tetnum
 grid[minox1][minoy1]=tetnum
 grid[minox2][minoy2]=tetnum
 grid[minox3][minoy3]=tetnum
 minoinit()
 phase="patt"
end

--1=i 2=j 3=l 4=o 5=s 6=t 7=z
function minoshape()
 minor0={
 {-1,0,1,0,2,0},
 {-1,0,-1,-1,1,0},
 {-1,0,1,-1,1,0},
 {0,-1,1,0,1,-1},
 {-1,0,0,-1,1,-1},
 {-1,0,0,-1,1,0},
 {1,0,0,-1,-1,-1}}
 minor1={
 {0,-1,0,1,0,2},
 {0,-1,1,-1,0,1},
 {0,-1,1,1,0,1},
 {0,-1,1,0,1,-1},
 {0,-1,1,0,1,1},
 {0,-1,1,0,0,1},
 {0,1,1,0,1,-1}}
 minor2={
 {-1,0,1,0,2,0},
 {-1,0,1,1,1,0},
 {-1,0,-1,1,1,0},
 {0,-1,1,0,1,-1},
 {1,0,0,1,-1,1},
 {1,0,0,1,-1,0},
 {-1,0,0,1,1,1}}
 minor3={
 {0,-1,0,1,0,2},
 {0,-1,-1,1,0,1},
 {0,-1,-1,-1,0,1},
 {0,-1,1,0,1,-1},
 {0,1,-1,0,-1,-1},
 {0,1,-1,0,0,-1},
 {0,-1,-1,0,-1,1}}
  minox1=minox+rotatemath(tetnum,1)
  minoy1=minoy-rotatemath(tetnum,2)
  minox2=minox+rotatemath(tetnum,3)
  minoy2=minoy-rotatemath(tetnum,4)
  minox3=minox+rotatemath(tetnum,5)
  minoy3=minoy-rotatemath(tetnum,6)
  ghminox1=ghminox+rotatemath(tetnum,1)
  ghminoy1=ghminoy-rotatemath(tetnum,2)
  ghminox2=ghminox+rotatemath(tetnum,3)
  ghminoy2=ghminoy-rotatemath(tetnum,4)
  ghminox3=ghminox+rotatemath(tetnum,5)
  ghminoy3=ghminoy-rotatemath(tetnum,6)
end

function rotatemath(tee,ess)
 if rotation==0 then return minor0[tee][ess]
 elseif rotation==1 then return minor1[tee][ess]
 elseif rotation==2 then return minor2[tee][ess]
 elseif rotation==3 then return minor3[tee][ess]
 end
end

function removeline(line)
 sfx(3)
 for i=1,10 do
  grid[i-1][line]=0
  makeparticle(prt,i*8+20,128-line*8,0,-8,5,7,6,20,rnd(2)+1,-1,6)
  for j=1,40-line do
   grid[i-1][line+j-1]=grid[i-1][line+j]
  end
 end
end

function drawbg()
 if prtenb==true then
  poff={x=0,y=0}
  makeparticle(prt,sin(frame%level/level)*level*8+64,cos(frame%level/level)*level*8+64,-sin(frame%level/level),-cos(frame%level/level),0,level%10+6,level,200,rnd(3),-rnd(1),level%10)
  updateparticle(prt)
  drawparticle(prt)
 end
end

function musiccheck()
 if not musicenabled then
  music(-1)
  currentsong=-1
  lastsong=-1
 else
  if currentsong==0 and lastsong!=0 then music(-1)
  elseif currentsong==1 and lastsong!=1 then music(0)
  elseif currentsong==2 and lastsong!=2 then music(32)
  elseif currentsong==3 and lastsong!=3 then music(36)
  elseif currentsong==4 and lastsong!=4 then music(37)
  end
  lastsong=currentsong
 end
end

----------------------------------------------------------------

function tetdraw()
 cls()
 pal()
 mapx=110
 mapy=124
 yoff=-40
 if bg==true then drawbg() end
 map(0,0,0,-128)
 map(0,0,0,0)
 --if harddrop then drawbackfx() end
 rectfill(mapx,mapy,mapx+11,mapy+-21,0)
 rect(mapx,mapy,mapx+11,mapy+-17,1)
 for i=1,10 do
  for j=1,40 do
   if grid[i-1][j]>0 then
    minocolor(grid[i-1][j])
    spr(currentblock,(i*8)+16,yoff-((j-20)*8)+8)
    pset(i+mapx,mapy-j,9)
    --debug=minox
   end
  end
  if phase=="fall" then
   pal()
   palt(9,true)
   pal(4,13)
   pal(15,7)
   drawblock(currentghost,1)

  end
 minocolor(tetnum)
 if locktimer<5 and locktimer>0 then
  pal() pal(9,6) pal(4,13) pal(15,7)
  vtb={minox,minoy,minox1,minoy1,minox2,minoy2,minox3,minoy3}
  for i=1,4 do
   makeparticle(prt,vtb[i*2-1]*8+rnd(7)+24,128-vtb[i*2]*8+7,0,-rnd(32),-64-rnd(32),7,1,3,2,-.1,6)
  end

  end
 if hdrop==false and phase=="fall" then
  pset(ghminox+mapx+1,-ghminoy+mapy,7)
  pset(ghminox1+mapx+1,-ghminoy1+mapy,7)
  pset(ghminox2+mapx+1,-ghminoy2+mapy,7)
  pset(ghminox3+mapx+1,-ghminoy3+mapy,7)
 end
 pset(minox+mapx+1,-minoy+mapy,9)
 pset(minox1+mapx+1,-minoy1+mapy,9)
 pset(minox2+mapx+1,-minoy2+mapy,9)
 pset(minox3+mapx+1,-minoy3+mapy,9)
 drawblock(currentblock,0)
 --drawfrontfx()
 drawhud()
 end
 if phase=="anim" then
  anim()
 end
end

function drawblock(blk,fx)
 local vartable={}
 local smthy
 local smthx
 if fx==1 then
  vartable={ghminox,ghminoy,ghminox1,ghminoy1,ghminox2,ghminoy2,ghminox3,ghminoy3}
  smthy=8
  smthx=((minox-minolastx)+(minolastx-minolastx1))*-2
 else
  vartable={minox,minoy,minox1,minoy1,minox2,minoy2,minox3,minoy3}
  smthy=(minotimer/speed)*8
  smthx=((minox-minolastx)+(minolastx-minolastx1))*-2
 end
 for i=1,4 do
  spr(blk,(vartable[(i*2)-1]*8)+24+smthx,yoff-((vartable[i*2]-20)*8)+smthy)
 end
end

function drawhud()
 printsh("hold",4,0)
 printsh("next",108,0)
 printsh("lines",2,25)
 printsh(lines,(22-(#tostr(lines)*4)+2)/2,32)
 printsh("level",2,39)
 printsh(level,(22-(#tostr(level)*4)+2)/2,46)
 printsh("goal",4,53)
 printsh(goal+oldgoal-lines,(22-(#tostr(goal+oldgoal-lines)*4)+2)/2,60)
 printsh("score",2,67)
 if score>0 then
  printsh(tostr(score).."0",(22-(#tostr(score.."0")*4)+2)/2,74)
 else
  printsh(tostr(score),(22-(#tostr(score)*4)+2)/2,74)
 end

 spr(67,4,7,2,1)
 spr(69,4,15,2,1)
 spr(67,108,7,2,1)
 spr(69,108,15,2,1)
 spr(73,4,19,2,1)
 minocolor(holdnum)
 palt(0,true)
 if holdnum>0 then sspr((holdnum*8)-8,40,8,8,4,5,16,16) end
 pal()
 for i=1, #queue-1 do
  minocolor(queue[i+1])
  if i==1 then sspr((queue[i+1]*8)-8,40,8,8,108,(i*8)-3,16,16)
  else spr(queue[i+1]+79,112,(i*9)+2)
  spr(71,108,i*9+2,2,1) end
 end
 if debug!=nil then print(debug,0,64,7) end
end

function printsh(sstring,sx,sy)
 print(sstring,sx+1,sy+1,13)
 print(sstring,sx,sy,7)
end

function colorblend(color1,color2)
 if frame%2==0 then
  return color2
 else
  return color1
 end
end

function minocolor(m)
 pal()
 if m==1 then
  pal(9,12)
  pal(4,5)
  pal(15,7)
 elseif m==2 then
  pal(9,5)
  pal(4,1)
  pal(15,12)
 elseif m==3 then
  pal(9,9)
  pal(4,4)
  pal(15,15)
 elseif m==4 then
  pal(9,10)
  pal(4,9)
  pal(15,7)
 elseif m==5 then
  pal(9,11)
  pal(4,3)
  pal(15,7)
 elseif m==6 then
  pal(9,13)
  pal(4,2)
  pal(15,6)
 elseif m==7 then
  pal(9,8)
  pal(4,2)
  pal(15,14)
 end
end

function makeparticle(tb,x,y,dx,dy,g,c,rn,l,rd,drd,c2,c3,c4)
 if prtenb then
  if rd==nil then rd=0 end
  if drd==nil then drd=0 end
  tb[#tb+1]={x=x,y=y,dx=dx,dy=dy,g=g,c={c,c2,c3,c4},rn=rn,l=l,rd=rd,drd=drd,il=l}
 end
end

function updateparticle(tb)
 for i=1,#tb do
  local p=tb[i]
  if p!=nil then
   p.dx-=(rnd(p.rn)/16)
   p.dx+=(rnd(p.rn)/16)
   p.dy-=(rnd(p.rn)/16)
   p.dy+=(rnd(p.rn)/16)
   p.x+=p.dx/4
   p.y+=p.dy/4
   p.dy+=p.g/32
   p.rd+=p.drd/8
   p.rd=mid(0,p.rd,128)
   p.l-=1
   tb[i]=p
   if p.l==0 then
    del(tb,p)
   end
  end
 end
end

function drawparticle(tb)
 for i=1,#tb do
  local p=tb[i]
  if p!=nil then
   local cm=#p.c-flr(p.l/p.il*#p.c+.99)+1
   if cm<0 or cm>#p.c then cm=0 end
   if p.rd<1 then
    circfill(p.x+poff.x,p.y+poff.y,p.rd,p.c[cm])
   else
    circfill(p.x+poff.x,p.y+poff.y,p.rd,p.c[cm])
   end
  end
 end
end


__gfx__
00000000fffffff9fffffff9fffffff9fffffff9fffffff99ffffff94444444494f994f94444444444444444fffffff9ffff9444fffffff99999999444444444
00000000f9999994f9999994ff999994f9fff994f99999f9f9ffff944ff99994949994994fffff944fffff94f9999994ff999944f9999994944447944ff44ff4
00000000f9999994f9444994f9f99944ffff99f4f9fff4f9ff9999444f444494444444444f9999444f999994f99999f4ff999944f9ff9ff4949997944f4994f4
00000000f9999994f9499f94f99f9444fff99ff4f9f994f9ff999944494ff494f994f9944f9999444f999994f9999f94ff999944f9fffff494999794449f9944
00000000f9999994f9499f94f9994444ff99ff94f9f994f9ff999944494ff494999499944f9999444f999994f999f9f4ff999944f99fff949499979444999944
00000000f9999994f99fff94f9949444f99ff994f94444f9ff99994449444494444444444f9999444f999994f99f9ff4ff999944f999f994977777944f4994f4
00000000f9999994f9999994f9499944f9ff9994fffffff9f94444944999999494f994f94944444449999994f9f9fff4ff999944f9999994999999944ff44ff4
000000009444444494444444949999949444444499999999944444494444444494999499444444444444444494444444fff94444944444444444444444444444
44444444fffffff49ffffff9fffffffff9999994f99999944444444499999999fffffff4f999999999999999ffffffff00099000ffffffff444444449ffffff9
4ffff994f444444449ffff94f99999949ff999949fffff944ffffff4f9999994f44444f499999994999999999f9f9f9f099ff990449999ff4999ff9499ffff99
4f999994f499994444444444f99999949f9999949fffff944f999994ff999949f44949f49944449499999999f9f9f9f909fff940449999ff499999f4499ff994
49999994f499994444f44f44f9494944999999949fffff944f999994fff99499f49494f49944449499999999949494949fff9944449999ff499449f494999949
49999994f499444449ffff94f9999994999999949fffff944f999994fff44999f44999f49944449499999999f9f9f9f999f99944449999ff4494499449499494
49999994f499444449ffff94f9494944999999949fffff944f999994ff444499f49499f499444494999999999494949409999440449999ff4499999494944949
49999994f444444449999994f494949499999994999999944f9999f4f4444449fffffff499999994999999994949494909444440449999ff4444499449444494
444444444444444444444444f44444444444444444444444444444444444444444444444944444449999999944444444000440004444444f4444444494444449
00999900ffffff990ffffff0099999900444444004444440044444400044444000444400004444009999999499999994ffff9999ffff9999ffff9999ffff9999
09f99990f4444449499449949f4444f94999999f4999999f4999999f0499949f04499ff0049999f09f4444f49ff9f9f4f0000009f0f0f009f000ff09f4000009
9f999999f499999949499494944444494999999f49944f9f4944449f494449ff449999ff49f99f9f949999f49f9f9994f0000009ff0f0009f00ff009f0449909
99499499f49999f949994994944444494999999f49449f9f49499f9f49499f9f4999999f4999999f949999f499f99994f0000009f0f00049f0ff00f9f0400909
99499499f49999f449999994944444494999999f4949ff9f49499f9f49499f9f4999999f49f99f9f949999f49f999994900000049f0004049ff00ff490900f04
99999999f49999f449944994944444494999999f49fff99f494fff9f449fff9f449999ff499ff99f949999f49999999490000004900040449f00fff49099ff04
99999999949ffff4499999949f4444f94999999f4999999f4999999f49f999f004499ff0049999f09ffffff49f9999f49000000490040404900fff04900000f4
099999909999444444444444099999900ffffff00ffffff00ffffff00fffff0000ffff0000ffff00444444444444444499994444999944449999444499994444
99999999fffffffffffffff40ffffff09f9999f9fffffff44fffffff9fff49f4009fff00000f900009999490009999004949ffff004fff004444444ff00f9009
9f0909f9f9ff99f4f4999944ff9999ffff4444fff499994444fffffff9994f94099449f000ff990099ff99490999ff90949fffff00499f0049f49fff0f000090
90909099ff99ff94f9444494f900009494999949f9ffff94449999fff99944444940049f0fff99909f9499449999ff9999ffffffffff44444f94f44f00000000
99090909ff99ff94f9444494f900009494999949f9f99494449999fff9994ff44f00004fffff99999f99494449999994499ffffff999999f4f99ff4ff0000009
90909099f9ff99f4f9444494f900009494999949f9f99494449999ff44994f944f00004f99994444999994444999999449f9fff94999999f4949f9ff90000004
99090909f9ff99f4f9444494f900009494999949f9f44494449999ffff44f99449f00499099944404949944444999944499f9f944444ffff4994944f00000000
9f9090f9ff99ff94f4999944ff999944ff4444fff4999944444444fff9f4f944049ff9900099440094444444044444409499994900f994004ff4499f09000040
99999999f4444444444444440f4444409f9999f9444444444444444f4444444900444400000940000944444000444400f944499400fff400ffffffff90094004
101010107766dd670000000006777777777777607600000000000067000677777777600000000000000000005555555555555555555555551111111100000000
0000000170000005066dd55067600000000006767600000000000067006760000006760000707007007770005dddddddddddddddddddddd51111111100000000
10000000600000050600005076000000000000676760000000000676007600000000670000070d77707d7d005d66666666666666666666d51111111100000000
00000001600000050d0000d076000000000000670677777777777760007600000000670000707007dd777d005d67777777777777777776d51111111100000000
10000000d00000050d0000d0760000000000006700000000000000000076000000006700000d0d00d00ddd005d67777777777777777776d51111111100000000
00000001d000000d0500006076000000000000670000000000000000007600000000670000000000000000005d67777777777777777776d51111111100000000
100000006000000d055dd66076000000000000670000000000000000006760000006760000000000000000005d67777777777777777776d51111111100000000
0101010175555ddd0000000076000000000000670000000000000000000677777777600000000000000000005d67777777777777777776d51111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000797d7d7d7b79005d67777777777777777776d50000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000094d2d2d2b394005d67777777777777777776d50000000000000000
0000000007900000000007900079790000079790000790000797900000000000000000007a7978780000007a5d67777777777777777776d50000000000000000
797979790940000000000940009494000009494000094000094940000000000000000000a9948282000000a95d67777777777777777776d50000000000000000
9494949407979790079797900079790007979000079797900007979000000000000000007a7979787800007a5d67777777777777777776d50000000000000000
000000000949494009494940009494000949400009494940000949400000000000000000a9949482820000a95d67777777777777777776d50000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000007c7c7c000000007c5d67777777777777777776d50000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000c1c1c100000000c15d67777777777777777776d50000000000000000
ff9ff9ff9ff90000000000ff90000000ff9000000000000000000000000000000000000000000000000000005d67777777777777777776d50000000000000000
f94f94f94f940000000000f940000000f94000000000000000000000000000000000000000000000000000005d67777777777777777776d50000000000000000
944944944944000000000094400000009440000000000000000000000000000000000000007575757d7d7d005d67777777777777777776d50000000000000000
0000000000000000ff9ff9ff90000000ff9ff9ff9000000000000000000000000000000000515151d2d2d2005d67777777777777777776d50000000000000000
0000000000000000f94f94f940000000f94f94f940000000000000000000000000000000007a7a757b7d00005d67777777777777777776d50000000000000000
00000000000000009449449440000000944944944000000000000000000000000000000000a9a951b3d200005d66666666666666666666d50000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000797a7a7d7b7b79795dddddddddddddddddddddd50000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000094a9a9d1b3b394945555555555555555555555550000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000000000000000000000000000000006666666666766667000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006666666677777777000000000000000000000000000000000000000000000000000000000000000000000000
67676767606060600000000000000000666666667777777777777777000000000000000000000000000000000000000000000000000000000000000000000000
06060606000000000000000066666666777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000
76767676060606060000000066666666777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000
76767676000000000000000000000000666666667777777777777777000000000000000000000000000000000000000000000000000000000000000000000000
67676767060606060606060600000000000000006666666677777777000000000000000000000000000000000000000000000000000000000000000000000000
77777777676767676060606000000000000000006666666676666766000000000000000000000000000000000000000000000000000000000000000000000000
00000000677777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006771111111111111776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000067711111111111117760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000677111111111111177600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006771111111111111776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00067711111111111117760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677111111111111177600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06771111111111111776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67711111111111117760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888886666666666666666666666666666668
8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbb886666666666666666666666666666668
8b888888888888888bb88888888888888bb88888888888888b888888b555555555b888888b888bb88888888888888b5886666666666666666666666666666668
8b888888888888888bb8888888888888b5b888888888888888b888888b5555555b888888b8888bb88888888888888b5886666666666666666666666666666668
8b888888888888888bb8888888888888b5b888888888888888b888888b5555555b888888b8888bb8888888888888b5588f6f6f6f6f6f6f6f6f6f6f6f6f6f6f68
8b989898989898989bb898989898989bd5b8989898989898989b989898b5d5d5b898989b98989bb8989898989898b5d886666666666666666666666666666668
8b888888888888888bb888888888888b55b8888888888888888b888888b55555b888888b88888bb88888bbbbbbbbb5588f6f6f6f6f6f6f6f6f6f6f6f6f6f6f68
8bbbbbb89898bbbbbbb89898bbbbbbb5d5bbbbbb98989bbbbbbbb898989bd5db989898bbbbbbbbb898989bd5d5d5d5d886666666666666666666666666666668
855555b88888b55555b88888b55555555555555b88888b555555b888888b555b888888b5555555b8888888b5555555588f6f6f6f6f6f6f6f6f6f6f6f6f6f6f68
85d5d5b89898b5d5d5b89898b5d5d5d5d5d5d5db98989bd5d5d5db989898b5b898989bdbbbbbbbdb989898b5d5d5d5d886f6f6f6f6f6f6f6f6f6f6f6f6f6f6f8
8d5d5db98989bd5d5db98989bbbbbbbd5d5d5d5b89898b5d5d5d5b898989bdb989898b5b89898b5b8989898b5d5d5d588f6f6f6f6f6f6f6f6f6f6f6f6f6f6f68
85d5d5b89898b5d5d5b89898989898b5d5d5d5db98989bd5d5d5d5b898989b989898b5db98989bd5b898989bd5d5d5d886f6f6f6f6f6f6f6f6f6f6f6f6f6f6f8
8d5d5db98989bd5d5db9898989898b5d5d5d5d5b89898b5d5d5d5db989898b898989bd5b89898b5db9898989bd5d5d588ffffffffffffffffffffffffffffff8
8dddddb99999bdddddb9999999999bdddddddddb99999bdddddddddb99999999999bdddb99999bdddb999999bdddddd886f6f6f6f6f6f6f6f6f6f6f6f6f6f6f8
8d5d5db98989bd5d5db989898989bd5d5d5d5d5b89898b5d5d5d5d5b89898989898b5d5b89898b5d5b8989898b5d5d588ffffffffffffffffffffffffffffff8
8dddddb99999bdddddb99999bbbbbddddddddddb99999bddddddddddb999999999bddddb99999bddddb999999bddddd88ffffffffffffffffffffffffffffff8
8dddddb99999bdddddb99999bddddddddddddddb99999bddddddddddb999999999bddddb99999bddddb9999999bdddd88ffffffffffffffffffffffffffffff8
8dddddb99999bdddddb99999bddddddddddddddb99999bdddddddddddb9999999bdddddb99999bdddddb999999bdddd88f7f7f7f7f7f7f7f7f7f7f7f7f7f7f78
86d6d6ba9a9ab6d6d6ba9a9ab6d6d6d6d6d6d6db9a9a9bd6d6d6d6d6db9a9a9a9bd6d6db9a9a9bd6d6db9a9a9a9bd6d88ffffffffffffffffffffffffffffff8
8dddddb99999bdddddb99999bddddddddddddddb99999bddddddddddddb99999bddddddb99999bddddddb999999bddd88f7f7f7f7f7f7f7f7f7f7f7f7f7f7f78
86d6d6ba9a9ab6d6d6ba9a9ab6d6d6d6d6d6d6db9a9a9bd6d6d6d6d6d6ba9a9ab6d6d6db9a9a9bd6d6d6ba9a9a9ab6d887f7f7f7f7f7f7f7f7f7f7f7f7f7f7f8
8d6d6db9a9a9bd6d6db9a9a9bd6d6d6d6d6d6d6ba9a9ab6d6d6d6d6d6db9a9a9bd6d6d6ba9a9ab6d6d6d6ba9a9a9bd688f7f7f7f7f7f7f7f7f7f7f7f7f7f7f78
86d6d6ba9a9ab6d6d6ba9a9ab6d6d6d6d6d6d6db9a9a9bd6d6d6d6d6d6ba9a9ab6d6d6db9a9a9bd6d6d6db9a9a9a9bd887f7f7f7f7f7f7f7f7f7f7f7f7f7f7f8
8d6d6db9a9a9bd6d6db9a9a9bd6d6d6d6d6d6d6ba9a9ab6d6d6d6d6d6db9a9a9bd6d6d6ba9a9abbd6d6d6db9a9a9ab6887777777777777777777777777777778
866666baaaaab66666baaaaabbbbbbbbbbb6666baaaaab666666666666baaaaab666666baaaaabbbbbbbbbbaaaaaaab887f7f7f7f7f7f7f7f7f7f7f7f7f7f7f8
8d6d6db9a9a9bd6d6db9a9a9a9a9a9a9a9ab6d6ba9a9ab6d6d6d6d6d6db9a9a9bd6d6d6ba9a9abb9a9a9a9a9a9a9a9b887777777777777777777777777777778
866666baaaaab66666baaaaaaaaaaaaaaaab666baaaaab666666666666baaaaab666666baaaaabbaaaaaaaaaaaaaaab887f7f7f7f7f7f7f7f7f7f7f7f7f7f7f8
8d6d6db9a9a9bd6d6db9a9a9a9a9a9a9a9a9bd6ba9a9ab6d6d6d6d6d6db9a9a9bd6d6d6ba9a9abb9a9a9a9a9a9a9a9b887777777777777777777777777777778
866666baaaaab66666baaaaaaaaaaaaaaaaab66baaaaab666666666666baaaaab666666baaaaabbaaaaaaaaaaaaaaab887777777777777777777777777777778
866666baaaaab66666baaaaaaaaaaaaaaaaaab6baaaaab666666666666baaaaab666666baaaaabbaaaaaaaaaaaaaaab887777777777777777777777777777778
866666bbbbbbb66666bbbbbbbbbbbbbbbbbbbb6bbbbbbb666666666666bbbbbbb666666bbbbbbbbbbbbbbbbbbbbbbbb887777777777777777777777777777778
88888888888888888888888888888888866666666666666666666666666666688888888888888888888888888888888888888888888888888888888888888888
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010000001a7502875035750377502775001750027503b750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700000000000000000000000000000000
00000000282700d270102501c2500c2500b2400a25009250042500a25005250022500125000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000000002355026250256502075000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0000000001b5002b5003b5004b5006b5007b5008b5009b500ab500bb500cb5010b5012b5013b5015b5017b5017b5019b5019b501cb501db501fb5021b5024b5027b502ab502fb5034b5036b5039b503bb503fb50
0103000018770187701c7701c7701f7701f7701a7701a7701d7701d77021770217701c7701c7701f7701f77023770237702477024770247722477224772247722476224762247522475224742247322472224712
010000001b250032500f1500305006050020530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00002400023000210001f0001d0001c0001a00018000130001300010000100000f0000f0000f0000f00012000120001200012000120001200012000120000d0000d0000d0000d0000d0000d0000d0000d000
010000003e650356500a55023550034500f4500245000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014000010054100531c5521c55210054100531c7511c75210054100531c7521c75210054100531c5511c55215054150532155221552150541505321751217521505415053217522175215054150532155121552
00140000140541405320552205521405414053207512075210054100531c7521c75210054100531c5511c55215054150532155221552150541505321751217521505415053217522175217054170531855118552
011400001a0541a0520e0500e05300000000000e5500e55300000000000e0550e055155511555211050000001805418052247512475000000000002475224752000000000018552195521a5521a5521b5511b552
01140000000000000023552235530000000000230522305200000000001c0521c0530000000000205522055215054150531c7521c75215054150531c5511c5521575215752157521575300000000000000000000
011400000c053246153c625246150c053246153c625246150c053246153c6253c6250c053246153c625246150c053246153c625246150c053246153c625246150c053246153c6253c6250c0533c6253c62524615
011400002875428752000000000023754237502475024750267502675028750267502475224752237502375021750217550000000000217542175224752247522875028755000002400026751267502475024753
01140000237542375317752177522375123752247522475326754267531a7521a752287522875228752287522475424753000001f700217512175215752157532175421752217522175215754157521575215752
0114000026700267002675426752000002370029752297522d7542d7552d7502d7502b7512b752297502975028754287522875228753000002170024751247522875428752000002400026751267522475224752
01140000237542375200000000002013420130217502175023750237502475023750211322113220750207501c7501c75500000000001c1341c13221752217522475024755000002070023131231302175021753
01140000207542075314752147522113121132217522175323754237531775217752231322313217752177522175421753000001a7001c1311c13210752107531c7541c7521c7521c75210134101321075210752
0114000026700267001d7541d7520000023700217522175224754247552475524755237512375221750217501f7541f7521f7521f75500000187001c7511c7521f7541f752217501f7501d7511d7521c7521c752
012800002875028750287522875224752247522475224755267502675026752267522375223752237522375524750247502475224752217522175221752217552075120750207522075223752237522375223755
0128000028750287502875228752247522475224752247552675026750267522675223752237522375223755247502475028752287522d7522d7552d7542d7522c7512c7502c7522c7522c7522c7522c7522c755
0028000021752217522175221752217522175221752217521f7511f7521f7521f7521f7521f7521f7521f752217512175221752217521c7511c7521c7521c7521a7521a7521c7521c75223751237522375223752
0128000021752217522175221752217542175221752217521f7511f7521f7521f7521f7541f7521f7521f75221751217522175221752217542175221752217522675126752267522675226754267522675226752
01280000151541c155151551c155151541c155151551c155141541c155141551c155141541c155141551c155151541c155151551c155151541c155151551c155141541c155141551c155141541c155141551c155
012800000c0533c6250c0533c6250c0533c6250c0533c6250c0533c6250c0533c6250c0533c6253c6253c6250c0533c6250c0533c6250c0533c6250c0533c6250c0533c6250c0533c6250c0530c0533c6250c053
010a0000345750000010100101002f5750000030575000003257500000000000000030575000002f575000002c57500000141001410038575000003b5750000038575000003b5750000039575385753557532575
010a00002f5750000017100171002f57500000305750000032575000000e1000e1003457500000000000000030575000000c1000c1002d5750000039575000002d5750000039575151002d575000003957500000
010a000032575000000e1000e100355750000029575000003957500000151001510037575000002b575000003457500000305750c1003457500000285750e1003457500000325750c10030575000002d57515100
010a000028053340502805034050280503405028051340511c051280511c050280501c053280501c05028050210532d050210502d050210502d050210512d051210512d050210502d050210532d050210502d050
010a0000200532c050200502c050200532c050200512c0511c051280511c050280501c053280501c05328050210532d050210502d050210532d050210512d051210512d051210502d0502405318050260531a053
012800002c5502c5552e5022e5502c5502c5552d5022b5502b5502b55500502295502b5502b555005022955029550295550050227550295502955500502275502755027555005022555024550245550050225550
012800002005324054270542b0542005324054270542b05420053240542605429054200532405426054290541f0532205425054290541f0532205425054290541b0531d0541f054220541b0531f0542205424054
010c000023651216511f6511d6511c6511a65118651006513065129651286511a6510065100651006510065100651006513565134651326510c65100651006513c65037651306512b651246511f6511865111653
012a00001c0541c0521c0521c052170541705518054180551a0541a0521a0521a0521805418055170541705515054150521505215052150541505518054180551c0541c0521c0521c0521a0541a0551805418055
012a000017054170521705217052170541705518054180551a0541a0521a0521a0521c0541c0521c0521c05218054180521805218052150541505015050150551505415052150521505215052150521505215055
012a00001a0541a0521a0521a0521d0541d0551105411055210542105221052210521f0541f0551d0541d0551c0541c0521c0521c0521c0521c05218054180551c0541c0521c0521c0521a0541a0551805418055
012a00000705507055070550705500055000550005500055020550205502055020550405504055040550405505055050550505505055090550905509055090550405504055040550405505055050550505505055
012a00000c0730c0530c0330c013026540263502625026150c0730c0530c0330c053026540263502625026150c0730c0530c0330c013026540263502625026150c0730c0530c0330c01302654026350262502615
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 15 18 10 14
00 16 19 11 14
00 17 1a 12 14
00 16 19 13 14
00 15 18 10 14
00 16 19 11 14
00 17 1a 12 14
00 16 19 13 14
00 1b 1d 1f 20
00 1c 1e 1f 20
00 14 18 1f 1d
00 14 17 1f 1e
00 14 18 1f 1d
00 14 16 1f 1e
00 14 1a 1f 1d
00 14 15 1f 1e
00 14 1a 1f 1d
00 14 16 1f 1e
00 15 18 1d 20
00 16 19 1e 20
00 17 1a 1d 20
00 16 19 1e 20
00 15 18 10 20
00 16 19 11 20
00 17 1a 12 20
00 16 19 13 20
00 1b 1d 1f 20
00 1c 1e 1f 20
00 14 18 10 1d
00 14 19 11 1e
00 14 1a 12 1d
02 14 19 13 1e
01 21 24 21 14
00 22 25 22 14
00 23 24 23 14
02 22 25 22 14
03 26 27 43 20
01 29 2c 2d 44
00 2a 2c 2d 44
00 2b 2c 2d 44
00 2a 2c 2d 44
00 29 2c 43 44
00 2a 2c 43 44
00 2b 2c 43 44
02 2a 2c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
