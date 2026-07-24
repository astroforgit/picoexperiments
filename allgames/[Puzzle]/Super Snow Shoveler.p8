pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--11. super snow shoveler
--by @seansleblanc for advent2018
function _init()
seed=rnd()
done=false
mox=5
moy=6
mw=6
mh=8
px=3
py=0
pdx=px
pdy=py
ps="idle"
pf=false
throw=0
kx=0
ky=0
moves=0
barkx=0
barky=0
barkt=0
barktxt=0
barkb=false
barks={"ha!","hup!","ho!","hoo!","whup!","wup!","hoop!"}
barkbs={"oops!","ouch!","uff!","oof!","ouf!","ow!"}
cls()
palt(0,false)
palt(11,true)

m={}
for y=0,mh-1 do
m[y]={}
for x=0,mw-1 do
m[y][x]=1
end
end
for x=0,mw-1 do
m[0][x]=0
m[#m][x]=0
end
splats={}
splats[1]={}
splats[2]={}
for x=0,mw-1 do
splats[1][x]=0
splats[2][x]=0
end

parts={}
curpart=1
for i=1,100 do
local part={x=0,y=0,t=0,c=0}
add(parts,part)
end

menutim=10
wipe=0
btnps={"‹","”","ƒ","‘","—"}
btnpi=1
scene=menu
gametim=0
restart=false
scx=0
scy=0


music(0,0,0+1+2)
end
-->8
function _update()
scene:u()
update_parts()
--addpart(rnd(127),rnd(127),rnd(4)-2,rnd(4)-2,8,10)

kx*=0.5
ky*=0.5
end

function cltile(x,y)
m[y][x]=0
mset(mox+x,moy+y,48+flr(rnd(16)))
updatetile(x,y-1)
updatetile(x,y+1)

check_gameover()

end

function updatetile(x,y)
local cur=gettile(x,y)
if(cur==nil)return
if(cur==0)return
local c=mget(mox+x,moy+y)
if(c<64)return
local above=abs(gettile(x,y-1))
local below=abs(gettile(x,y+1))
local s=0
if above>0 and below>0 and c==67 then
 s=67
elseif above==0 and below==0 then
 s=64
elseif above>0 then
 s=65
elseif below>0 then
 s=66
end
if c>s then
 mset(mox+x,moy+y,s)
 updatetile(x,y+1)
 updatetile(x,y-1)
end
end

function gettile(x,y)
local r=m[y]
if(r==nil)return nil
return r[x]
end

function move(x,y)
color(0)
print(py)
if not done then
moves+=1
end
local curs=gettile(px,py)
if(curs==nil)return blocked(x,y)
if(curs>=3)return blocked(x,y)
local tgts=gettile(px+x,py+y)
if tgts==nil then
 if(curs!=0)return blocked(x,y)
 tgts=0
end
if(tgts+curs>3)return blocked(x,y)

moved=true
for i=1,3+rnd(3) do
addpart(
(mox+px)*8+rnd(8),
(moy+py)*8+rnd(8),
-x*2,-y*2,7,4+rnd(12))
end

sfx(2,3)
local r=m[py+y]
if(r==nil)return
if(r[px+x]==nil)return
r[px+x]+=curs
end

function blocked(x,y)
 px-=x
 py-=y
 pdx-=x/2
 pdy-=y/2
 kx+=rnd(2)
 ky+=2-kx
 kx*=sgn(rnd()-.5)
 ky*=sgn(rnd()-.5)
 moved=false
 barkb=true
 barktxt+=ceil(rnd(3))
	barkx=(px+mox+.5+rnd(.5))*8
	barky=(py+moy-.5-rnd(.5))*8
	barkt=10
 sfx(1,3)
end

function inc(x,y)
 if gettile(x,y)==nil then
  if x>=0 and x<mw and y<0 then
   splats[1][x]+=1
   barkb=true
 		barktxt=0
  end
  if x>=0 and x<mw and y>=mh then
   splats[2][x]+=1
   barkb=true
 		barktxt=0
  end
  return
 end
 m[y][x]+=1
 m[y][x]=min(3,m[y][x])
 updatetile(x,y)
end

function check_gameover()
if not done then
for y=0,mh-1 do
for x=0,mw-1 do
if gettile(x,y) > 0 then
 return
end
end
end
done=true
sfx(5,3)
end
end
-->8
function _draw()
 camera(flr(kx+.5),flr(ky+.5))
 scene:d()
 draw_parts()
end--draw

pstates={
idle={8,1,7,8,0,0},
down={15,1,6,10,0,0},
side={21,1,9,8,-3,0},
up={30,0,6,9,0,0},
throw={36,0,8,9,-2,0},
}
function draw_p(state,x,y,fx,fy)
local s=pstates[state]
local f=fx and 0 or 1
sspr(s[1],s[2],s[3],s[4],x+1+s[5+f],y+s[2],s[3],s[4],fx,fy)
end

function clouds()
for i=0,24 do
x=(rnd(160)+t()*8+sin(t()+i/9))%160-16
y=rnd(12)+sin(t()+i/9)
r=16-rnd(5)
circ(x,y+2,r-1,13)
circfill(x,y,r,7)
end
end

function snow()
seed=rnd()
srand(0)
for i=0,69 do
x=(rnd(127)+t()+sin(t()+i/9)*3)%128
y=(rnd(127)+t()*(1+rnd(.5))*8)%128
r=1.5-rnd()
circ(x,y,r,7)
if r>1 then
pset(x,y,6)
end
end
srand(seed)
end

function printol(s,x,y,f,o)
for a=-1,1 do
for b=-1,1 do
print(s,x+a,y+b,o)
end
end
print(s,x,y-2,o)
print(s,x,y,f)
end

letters={
s=0,
u=1,
p=2,
e=3,
r=4,
n=5,
o=6,
w=7,
h=8+8,
v=9+8,
l=10+8
}
letters[" "]=11+8
function bigprint(s,x,y)
spr(96+2*letters[s],x,y,2,2)
end
-->8
function lerp(f,t,b)
return f+(t-f)*b
end
-->8
function addpart(x,y,vx,vy,c,t)
curpart=(curpart+1)%#parts+1
local part=parts[curpart]
part.x=x
part.y=y
part.vx=vx
part.vy=vy
part.c=c
part.t=t
end

function update_parts()
for i = 1,#parts do
local p=parts[i]
if p.t>0 then
p.t-=1
p.vx*=.8
p.vy*=.8
p.x+=p.vx
p.y+=p.vy
end
end
end

function draw_parts()
for i = 1,#parts do
local p=parts[i]
if p.t>0 then
circ(p.x,p.y,1,p.c)
end
end
end
-->8
--intro from 2darray
--slightly modified
daynumber="11"
::_::
if (btnp()>0) goto donewithintro
cls(7)
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
  ?sub("pico-8 advent calendar",i),17+i*4,90,mid(-1-i/20+f,0,1)*7+7
 end
end
 
if (t()==8) goto donewithintro

flip()
goto _
::donewithintro::
-->8
--menu
menu={
u=function(self)
menutim=lerp(menutim,0,.05)
if menutim < 1 then
if btnpi==1 and btnp(‹) then
 btnpi+=1
 kx-=4
 for i=0,3 do
 addpart(rnd(127),rnd(127),rnd(4)-2,rnd(4)-2,12+rnd(4),4+rnd(12))
 end
 sfx(2,3)
elseif btnpi==2 and btnp(”) then
 btnpi+=1
 ky-=4
 for i=0,10 do
 addpart(rnd(127),rnd(127),rnd(4)-2,rnd(4)-2,12+rnd(4),4+rnd(12))
 end
 sfx(2,3)
elseif btnpi==3 and btnp(ƒ) then
 btnpi+=1
 kx+=4
 for i=0,20 do
 addpart(rnd(127),rnd(127),rnd(4)-2,rnd(4)-2,12+rnd(4),4+rnd(12))
 end
 sfx(2,3)
elseif btnpi==4 and btnp(‘) then
 btnpi+=1
 ky+=4
 for i=0,30 do
 addpart(rnd(127),rnd(127),rnd(4)-2,rnd(4)-2,12+rnd(4),4+rnd(12))
 end
 sfx(2,3)
elseif btnpi==5 and btnp(—) then
 btnpi+=1
 kx+=rnd(2)
 ky+=rnd(2)
 scene=game
 for i=0,99 do
 addpart(rnd(127),rnd(127),rnd(4)-2,rnd(4)-2,12+rnd(4),4+rnd(12))
 end
 sfx(0,3)
end
end
end,--update

d=function(self)
cls(7)
local tim=1-mid(0,(10-menutim)/10,1)^.5
local str="super snow"
pal(0,1)
for x=-2,1 do
for y=-1,2 do
for i=1,#str do
bigprint(sub(str,i,i),
-3+x+11*i+sin(t()+i/4)*(tim+.5)+.5,
-i*8*tim+y+48+sin(t()*2+i/6)*2*(tim+.5)+.5-tim*74)
end
end
end
for i=#str,1,-1 do
pal(0,i%4+12)
bigprint(sub(str,i,i),
-3+11*i+sin(t()+i/4)*(tim+.7)+.5,
-i*8*tim+48+sin(t()*2+i/6)*2*(tim+.7)+.5-tim*74)
end
str="shoveler"
pal(0,1)
for x=-2,1 do
for y=-1,2 do
for i=1,#str do
bigprint(sub(str,i,i),
10+x+11*i+cos(t()+i/4)*(tim+.5)+.5,
i*8*tim+y+70+cos(t()*2+i/6)*2*(tim+.5)+.5+tim*74)
end
end
end
for i=#str,1,-1 do
pal(0,i%4+12)
bigprint(sub(str,i,i),
10+11*i+cos(t()+i/4)*(tim+.7)+.5,
i*8*tim+70+cos(t()*2+i/6)*2*(tim+.7)+.5+tim*74)
end
pal(0,0)
if menutim < 1 then
for i=1,#btnps do
if btnpi>i then
printol(btnps[i],36+i*8,96,1,i%4+12)
else
printol(btnps[i],36+i*8,96,12,1)
end
end
end

end--draw
}
-->8
--game
game={
u=function(self)
if not done then
gametim+=1/30
else

scx=lerp(scx,44,.1)
scy=lerp(scy,44,.1)
if scx>=43 then
 if scoretimer==nil then
  scoretimer=30
 elseif scoretimer>=1 then
  scoretimer-=1
 elseif score==nil then
  score=1000
  scoretimer=30
  sfx(2,3)
 elseif moves>0 then
  moves-=1
  score-=2
  scoretimer=1
  if moves==0 then
   scoretimer=30
  end
  sfx(4,3)
 elseif gametim>=1 then
  gametim-=1
  score-=5
  scoretimer=1
  sfx(4,3)
 elseif not restart then
  restart=true
  sfx(1,3)
 end
end

end
wipe=lerp(wipe,1,.1)
local x=0
local y=0
local t=0
if throw==0 then
 if(btnp(”))y-=1
 if(btnp(ƒ))y+=1
 if(btnp(‹))x-=1
 if(btnp(‘))x+=1
 if(btnp(—))t+=1
 if(btnp(Ž))t+=1
else
 throw-=1
 if throw==1 then
  ps=oldstate
 end
end

if t>0 then
 x=0
 y=0
end
if(x!=0)y=0

px+=x
py+=y

--throw
if t>0 then
 if ps!="side" then
  pf=px<8
 end
	if ps=="up" then
	 pdy-=.5
	elseif ps=="down" then
	 pdy+=.5
	elseif pf then
  pdx-=.5
 else
  pdx+=.5
 end
 local ox=0
 local oy=0
 if ps=="side" then
  if pf then
   ox-=1
  else
   ox+=1
  end
 elseif ps=="down" then
  oy+=1
 elseif ps=="up" then
  oy-=1
 end
 local r=m[py+oy]
 if r==nil then
  blocked(0,0)
 else
  if r[px+ox]==nil then
   blocked(0,0)
  else
 		barkt=10
 		barktxt+=ceil(rnd(3))
 		barkx=(px+mox+.5+rnd(.5))*8
 		barky=(py+moy-.5-rnd(.5))*8
   barkb=false
 		throw=6
 		if not done then
 		moves+=1
 		end
 		sfx(0,3)
   
   local til=gettile(px+ox*2,py+oy*2)
   if til!=nil then
    local tot=til+r[px+ox]
    for i=1,r[px+ox] do
     inc(px+ox*2,py+oy*2)
    end
    if tot>3 then
     inc(px+ox*3,py+oy*3)
     if abs(ox)>0 then
      inc(px+ox*2,py+1)
      inc(px+ox*2,py-1)
     else
      inc(px+1,py+oy*2)
      inc(px-1,py+oy*2)
     end
    end
    updatetile(px+ox*2,py+oy*2)
   elseif r[px+ox]>0 then
    inc(px+ox*2,py+oy*2)
   end
   cltile(px+ox,py+oy)

   local cur=r[px+ox]
   r[px+ox]=0
 	 oldstate=ps
 		ps="throw"
   for i=1,3+rnd(3) do
    addpart(
    (mox+px)*8+rnd(8),
    (moy+py)*8+rnd(8),
    ox*2,oy*2,7,4+rnd(12))
   end
  end
 end
end
--endthrow

if x>0 then
 ps="side"
 pf=false
end
if x<0 then
 ps="side"
 pf=true
end
if y<0 then
 ps="up"
 pf=false
end
if y>0 then
 ps="down"
 pf=false
end

moved=false
if abs(x)+abs(y)>0 then
 move(x,y)
end

pdx=lerp(pdx,px,.5)
pdy=lerp(pdy,py,.5)

if moved then
cltile(px,py)
end
if restart and btnp(—) then
run()
end
end,--update

d=function(self)
cls(12)

seed=rnd()
srand(0)
clouds()
srand(seed)

map()
local s="side"
if(t()%1 > 0.5)s="throw"
draw_p(
ps,
flr((pdx+mox)*8+.5),
flr((pdy+moy)*8-.5)
,pf)

--spr(32,48,48)
for y=0,mh-1 do
for x=0,mw-1 do
spr(32+m[y][x],
(mox+x)*8,
(moy+y)*8)
--[[print(m[y][x],
(mox+x)*8,
(moy+y)*8,
8)]]
end
end
seed=rnd()
for x=0,mw-1 do
if splats[1][x]>0 then
srand(x)
spr(80+flr(rnd(3)+splats[1][x]*8)%3,
(mox+x)*8,
38)
end
if splats[2][x]>0 then
srand(x)
spr(80+flr(rnd(3)+splats[2][x]*8)%3,
(mox+x)*8,
112)
end
end
srand(seed)

snow()

seed=rnd()
srand(4)
clouds()
srand(seed)

camera(-scx,-scy)
color(7)
fillp(0b1010010110100101.1)
rectfill(-2,-2,40-4,28-4)
fillp(0b1111010111110101.1)
rectfill(-6,-6,40,28)
fillp()

txt="moves:"..moves
cl={2,8,14,15,14,8}
for i=1,#txt do
printol(sub(txt,i,i),i*4,5+sin(i/2+t()),cl[flr(i+t()*6)%#cl+1],1)
end

txt="time: "..flr(gametim)
cl={5,6,3,11,3,6}
for i=1,#txt do
printol(sub(txt,i,i),i*4,15+sin(i/2+t()+.5),cl[flr(i+t()*6)%#cl+1],1)
end

if flr(scx)>=43 then
txt="all done!"
cl={8,9}
for i=1,#txt do
printol(sub(txt,i,i),i*4-4,25+sin(i/2+t()+.5),cl[flr(i+t()*6)%#cl+1],1)
end

if score!=nil then
txt="score: "..score.."000"
cl={13,14,15}
for i=1,#txt do
printol(sub(txt,i,i),i*4-12,35+sin(i/2+t()+.5),cl[flr(i+t()*6)%#cl+1],1)
end

if restart then
txt="— restart—"
cl={12,13,2}
for i=1,#txt do
printol(sub(txt,i,i),i*4-8,45+sin(i/2+t()+.5),cl[flr(i+t()*6)%#cl+1],1)
end
end
end

end

camera()
if barkt > 0 then
 barkt-=1
 if barkb then
  txt=barkbs[barktxt%#barkbs+1]
  cl={2,8,14,15,14,8}
  for i=1,#txt do
  printol(sub(txt,i,i),
  barkx+i*4,
  barky+sin(i/#txt+barkt/10)+rnd(2),
  cl[flr(i+t()*6)%#cl+1],1)
  end
 else
  txt=barks[barktxt%#barks+1]
  cl={5,6,3,11,3,6}
  for i=1,#txt do
  printol(sub(txt,i,i),
  barkx+i*4,
  barky+sin(i/#txt+barkt/10),
  cl[flr(i+t()*6)%#cl+1],1)
  end
 end
end

local w=wipe*148
color(7)
fillp()
rectfill(-w,0,127-w,127)
fillp(0b1010000100000001.1)
rectfill(-7-w,0,127-w+7,127)
fillp(0b1010010110100101.1)
rectfill(-13-w,0,127-w+13,127)
fillp(0b1111010111110101.1)
rectfill(-20-w,0,127-w+20,127)
fillp()
end
}
__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8888b888bbbbbbbbbdbbbbbbbbbbbbbbd7766776676777767bbbbbbbbbbbbbbbb44444444777667774444444466666666
bbbbbbbbbb33b82bb33bbbb33bbbbb8833888228b33bbbbb8dbbbbbbbbbbbbd86605660667777776bbbbbbbbbbbbbbbb22222222767776772222222266666666
bbbbbbbbb333388b3333bb3333bbbb833338b88d3333bbbb88dbbbbbbbbbbd880507705657767777bbbbbbbbbdbbbddb44444444677777674444444455555555
bbbbbbbbbffffbdbffdfbbffffbbbbbffffbbbfdffffbbbb288dbbbbbbbbd8825760575055677767bbbbbbbbdddddddd22222222777777762222222266666666
bbbbbbbbb1111bd11fd1bdd111bbbb11111bbb11d111bbbb8288dbbbbbbd88287555756755577377bbbbbbbb6dd6ddd644444444677667776666666666566566
bbbbbbbb111111fb11d111fddfb8bbb11111bbbbdf11bbbb18288dbbbbd882810705050505554343bbbbbbbb6776676622222222776776776666666655555555
bbbbbbbbfccccbdbccf1bccccdd82bbccccbbbbbcdccbbbb21828dbbbbd828125557657550555454bbbbbbbb7777777747774474667777766666666666666666
bbbbbbbbbcbbcbd888888bcbccb882bcbbcbbbbbcdcbbbbbb212dbbbbbbd212b7655555605055555bbbbbbbb77777777777777777777776766666666dddddddd
bbbbbbbbb4bb4bd822228b4bb4bb88b4bb4bbbb4bb4bbbbb44218288882812447777777776777767656565656565656542444444444444244444444444444444
bbbbbbbbbbbbbbb822228bbbbbbbbbbbbbbbbbbbbbbbbbbb22421828828124227777777767777776565656565656565622222222222222222222222222222222
bb7776bbbbbbbbbb8888bbbbbbbbbbbbbbbbbbbbbbbbbbbb44442182281244447777777777776775555555555555555524444444444444424444444444444444
b777776bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22224218812422227777777776777655555555555555555522222222222222222222222222222222
b776676bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4444442112444444773773777737755555555555555555654244444444444424255d66666666d552
bb6776bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222222422422222234344343343455505555555555655555222222222222222225d6666666666d52
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb44444444444444444545454545455505555555555555555524444444444444422d666666666666d2
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222222222222225555555555555050555555555555555522222222222222222666666666666662
bbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbbbbbbbbbbbdbbbbbbbbbbbbbbd7773377777777777555555554444444442222224444444442666666666666662
bbbbbbbbbbbbbbbbbbbbbbbbb67776bbbbbbbbbbbbbbbbbb8dbbbbbbbbbbbbd87737737777777777555555552222222224999942222222222666666666666662
bbbbbbbbbbbbbbbbbbbbbbbb6777776bbbbbbbbbbbbbbbbb88dbbbbbbbbbbd8877373377777337775666665544444444299999922cc22cc22665555555555662
bbbbbbbbbbbbbbbbb67776bb77777776bbbbbbbbbbbbbbbb288dbbbbbbbbd88273733737773773775566666522222222299999922c7227c22666666666666662
bbbbbbbbbb777bbb7777776b67766777bbbbbbbbbbbbbbbb8288dbbbbbbd88287333333773733337555555554444444429999292522552252666666666666662
bbbbbbbbb77777bb7776676b77677677bbbbbbbbbbbbbbbb18288dbbbbd8828133333333633333365555555522222222299994922c7227c22665555555555662
bbbbbbbbbb777bbbb77776bb6677777bbbbbbbbbbbbbbbbb218288dbbd88281263333336763333675555555544444444299999922cc22cc22666666666666662
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2218288dd88281227663366777777777555555552222222214444441222222222dddddddddddddd2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000
00000050050006000000000000000000050000000000006006000000000500000005000000000000000000000000060000000000000050000000000000000000
00500000000000000000500005000600000000000000000000000500060000000000000000000000000000000000000006000000006000000000000000000000
00006000000000500000000000000000000605000000000000000000000000000000060000000000000000000000000000000000000000000500000000000000
00000000006000000000000000000050000000000006000000506000000000000500000000000000000000000000000000000500000000000000000000000000
00000000000000000000000000000000005000000000050000000000000060000000000000000060000000600005000000000000000000000060000000000600
06000000000000000060000060000000000000600500000000000050050000000000005000005000000000000000000000000000000000000000000000050000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000
00000000777777770000000077777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000777777770000000077777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
05650505777777770565050577777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
67606660777776776760666077777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
67677766767777776767776677777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
77767776777777777776777677777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
67676767676767677767677777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
76767676767676767777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
7bbbbbbbbb7bbbb7bb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb777b7bbbb777bbb77b7b7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b777b7bb7bbb7b7bbbb7777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b777777bbb77b77bbb7777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7bbbbbb7b7b7b7bb777b777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb77b7b7bb777bbb77777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb77b7bbbbb77bbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
7bbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb00000000bbbbbbbb000bbbbb000bbbb00000000bbbbbbbb0000000bbbbbbbbbb0000000bbbbbbbb000bbb000bbbbbbbbbb0000bbbbbbbbb000bbbbbb000bbb
b0000000000bbbbbb00000bbb00000bb0000000000bbbbbb000000000bbbbbbbb000000000bbbbbb00000bb0000bbbbbbb00000000bbbbbbb0000bbbb0000bbb
00000000000bbbbbb00000bbb00000bb00000000000bbbbb000000000bbbbbbb00000000000bbbbb00000bb0000bbbbbbb00000000bbbbbb00000bbbb00000bb
00000bbb000bbbbb000000bbb00000bb00000bb0000bbbbb0000bbbbbbbbbbbb00000bb0000bbbbb000000b0000bbbbbb0000000000bbbbb00000bbbb00000bb
0000bbbbbbbbbbbb00000bbbbb0000bb0000bbbb000bbbbb0000bbbbbbbbbbbb0000bbbb0000bbbb000000b0000bbbbb00000bb00000bbbb00000bbbb00000bb
0000bbbbbbbbbbbb00000bbbbb0000bb0000bbbb000bbbbb000000bbbbbbbbbb0000bbbb0000bbbb00000000000bbbbb0000bbbb0000bbbb0000bbbbbb0000bb
0000000000bbbbbb00000bbbbb0000bb00000bb0000bbbbb000000bbbbbbbbbb00000bb00000bbbb00000000000bbbbb0000bbbb0000bbbb0000bb00bb0000bb
b0000000000bbbbb00000bbbbb0000bb0000000000bbbbbb000000bbbbbbbbbb00000000000bbbbb00000000000bbbbb0000bbbb0000bbbb0000b0000b0000bb
bb0000000000bbbbb00000bbb00000bb000000000bbbbbbb0000bbbbbbbbbbbb0000000000bbbbbb00000000000bbbbb0000bbbb0000bbbb0000b0000b0000bb
bbbbbbbb0000bbbbb0000000000000bb00000000bbbbbbbb0000bbbbbbbbbbbb000000000bbbbbbb0000b000000bbbbb00000bb00000bbbb00000000000000bb
b000bbb00000bbbbb0000000000000bb0000bbbbbbbbbbbb0000bbbbbbbbbbbb0000000000bbbbbb0000b000000bbbbb000000000000bbbb00000000000000bb
000000000000bbbbbb00000000000bbb0000bbbbbbbbbbbb000000000bbbbbbb0000b000000bbbbb0000bb00000bbbbbb0000000000bbbbbb0000000000000bb
00000000000bbbbbbbb000000000bbbb0000bbbbbbbbbbbb000000000bbbbbbb0000bb00000bbbbb0000bb00000bbbbbb0000000000bbbbbb000000000000bbb
b000000000bbbbbbbbbbb000000bbbbbb00bbbbbbbbbbbbbb0000000bbbbbbbbb000bbb000bbbbbbb000bbb000bbbbbbbbb000000bbbbbbbbb0000bb0000bbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000bbbbb000bbbb00000bbbbb0000bbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000bbbbb0000bbb000000bbb00000bbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000bbbbb0000bbbb00000bbb0000bbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000bbbbb0000bbbb00000bbb0000bbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000bbbbb0000bbbbb0000bbb0000bbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000bbbbb0000bbbbb00000b0000bbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000bbbbbb00000b0000bbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000bbbbbbb0000b0000bbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00000000000bbbbbbb0000b000bbbbb0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00000000000bbbbbbbb0000000bbbbb0000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b0000bbb0000bbbbbbbb000000bbbbbb00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b0000bbb0000bbbbbbbbb00000bbbbbb00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb000bbb000bbbbbbbbbbb000bbbbbbb00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb000bbb000bbbbbbbbbbb000bbbbbbbb000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__gff__
0000000000000707000007070707070700000000000007070000070707070707000000000000070700000007070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0a0a0a0a0a0a271716260a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a27172b2b16260a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a27172d2b2b2d16260a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a27172b2b2b2b2b2b16260a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a07172d2b1e0e1f2b2b2d16060a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b1c0c1d2e0f2f1c2c0c1d0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
294343430d33393739333e0d4343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4328430d0d4242424242420d4329434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
432928430d4343434343430d0d43432900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
430d43430d4343434343430d4328434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343430d0d4343434343430d430d434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2943430d0d4343434343430d4343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
434328430d4343434343430d0d43294300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181819080808080808091818181800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1a1a1a1a1a1b1a1b1a1a1a1a1b1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010400003f0712206105051016010260105601196011b601346043060128601226011b60100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000200001b6711b6611b651036011d601086610865108641076010360103601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
00030000115551a56523555155550250505505195051b505345053050528505225051b50500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
010200001b2311b2211b211032011d201082510822108211072010320103201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201
000100001b2311332108411032011d201082010820108201072010320103201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201
001000000aa100ea2011a3012a4015a4018a5019a501da601ea701dc001ea001dc001ea001da00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b5001d5002b530305003550035500335302b5001f530165301b50022530275302b5002b5302b5302950027500275301b500115301b5301b5001b5301850013530185001d53027530295002e53027530
0110000818615186151c6150c005186151d6151a6152c6051800514605180052400538605240051800514605180052400538605240052060514605180052c605300052c605180050c005180052c6053000500005
011100001b5021d5022b512305023550235502335122b5021f512165121b50222512275122b5022b5122b5122950227502275121b502115121b5121b5021b5121850213512185021d51227515295020000000000
011000001b5001d5002b530227303550022730335302b5001f530165301b5002253027530247302b5302b530295000f730275302b730115301b5301b5001b5301850013530185001d53027530357302e53027530
011100001b5021d5022b512227123550222712335122b5021f512165121b5022251227512247122b5122b512295020f712275122b712115121b5121b5021b5121850213512185021d51227512357150000000000
0110000018615186051c6150c605186151d6051a6152c605186151a6151c615246051c6151a615186151460518615246051c615246051c61514605186152c605186151a615186051a6151c6152c6051861500000
001000001b5001d500137300f0100a0100c0100f7301301016730117301805022530275302b02030730307302b02029020275301d020117300f7301b5001b730185002273018500277301d730295002403024030
001000001b5000a5500f5300c550355000f5503350030550275301f5301b5000f55002500115500f5300c5300f5000f55016500185001b5501d5501d5501350022550245500f5001f550165001d530225501d550
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c0340c1320c1220c1340c1250c1120c12218012181221812218132181241812518112181222202222112221122212222114221252212222132180221813218122181321812418125181321812218112
011000000021200212052120c212052120c2120521218212002120021205212002120521200212052120a21200212002120a212002120a212002120a21200212002120a212152120a21200212002121621200212
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
01 0a 0b 43 44
00 0a 0b 0c 44
00 0a 0b 43 44
00 0a 0b 0c 44
00 0d 0b 0c 44
00 0d 0b 0e 44
00 11 0f 43 44
00 11 0b 43 44
00 15 0f 0a 44
00 15 0b 43 44
00 14 0b 43 44
00 14 0f 43 44
00 0a 0b 15 44
00 0a 0f 15 44
00 0d 42 15 44
00 41 0b 14 44
00 41 15 14 44
00 0b 0a 15 44
02 10 0f 0d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
