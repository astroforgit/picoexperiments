pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--swamp thing aka fen friends
--by good neighbor games
--a rollin salsbery production
ents={}
function ent(x,y,i)
local e={}
e.x=x
e.y=y
e.hx=0
e.hy=0
e.hw=.7
e.hh=.7
e.sprt=1
e.sf=1
e.alen=2
e.spd=.05
e.tmrmax=30
e.tmr=0
e.left=false
e.lv=3
e.lvmx=3
e.stun=false
e.stuntmr=0
e.id=i
add(ents,e)
return e
end

kissz={}
sink=0

function drawe(e)
--if(e.name=='flwr')pal(13,e.col)

local sx=(e.x*8)+30
local sy=(e.y*8)+20
spr(e.sprt,sx,sy,1,1,e.left)
end

function anim(e,sf,nf,sp)
if(not e.act)e.act=0
if(not e.ast)e.ast=0
e.act+=1
if e.act%(30/sp)==0 then
e.ast+=1
if(e.ast==nf)e.ast=0
end
e.sprt=sf+e.ast
end

lastfrm=1

gstate="normal"

--------------------------------
--navigation--------------------

function move(e,dx,dy)
local x=e.x
local y=e.y

if e==p then
for k in all(friends) do
if entchk(e,dx,dy,k) then return x,y end
end
for q in all(items) do
if q.name=="cald" then
if entchk(e,dx,dy,q) then return x,y end
end
end
end

if dx<0 and mchk(x+dx,y)==false
and mchk(x+dx,y+e.hh)==false
then x+=dx
elseif dx>0 and mchk(x+dx+e.hw,y)==false
and mchk(x+dx+e.hw,y+e.hh)==false
then x+=dx end

if dy<0 and mchk(x,y+dy)==false
and mchk(x+e.hw,y+dy)==false
then y+=dy
elseif dy>0 and mchk(x,y+dy+e.hh)==false
and mchk(x+e.hw,y+dy+e.hh)==false
then y+=dy end


return x,y
end

mapx=64
mapy=24

function mchk(x,y,val)
if(val==nil)val=1
return fget(mget(mapx+flr(x),mapy+flr(y)),val)
end

function doorchk(dx,dy)
local x=p.x+(dx*6)
local y=p.y+(dy*6)
if mchk(x,y,2) then
 if keys>0 then
  mset(flr(mapx+x),flr(mapy+y),0)
  if(mchk(x+1,y,2))mset(flr(mapx+x+1),flr(mapy+y),0)
  if(mchk(x-1,y,2))mset(flr(mapx+x-1),flr(mapy+y),0)
  if(mchk(x,y+1,2))mset(flr(mapx+x),flr(mapy+y+1),0)
  if(mchk(x,y-1,2))mset(flr(mapx+x),flr(mapy+y-1),0)
  keys-=1
  end
 end
end

function entchk(e,dx,dy,ee)
 local x2=(e.x+dx)-ee.x
 local y2=(e.y+dy)-ee.y
 if ((abs(x2) < .8) and
     (abs(y2) < .9)) then
       return true
     end
 return false
end

sinkposx=300
sinkposy=300
function sinkingfeeling(u,j)
 if fget(mget(u+mapx,j+mapy),3) then
  if u!=sinkposx or j!=sinkposy then
  sink+=2
  sinkposx=u
  sinkposy=j
  end
else
  sink=0
  sinkposx=14
  sinkposy=14
  lastsafemx=mapx
  lastsafemy=mapy
  lastsafex=u
  lastsafey=j end
end




boundx=7
boundy=7

--------------------------------
---playeraction-----------------

kisscool=0

function smooch(dr)
	local k=ent(p.x,p.y)
	k.sprt=11
	k.spd=.1
	k.dx=0
	k.dy=0
	k.lv=8
	if dr==1 then k.dy+=k.spd k.y+=.4
	elseif dr==3 then k.dy-=k.spd k.y-=.4
	elseif p.left==true then k.dx-=k.spd k.x-=.2
	elseif p.left==false then k.dx+=k.spd k.x+=.4
	end
	add(kissz,k)
	kisscool=9
	return k
end

function kisupd(k)
 if(k.lv<1) del(kissz,k) del(ents,k)
 k.x,k.y=move(k,k.dx,k.dy)
 k.lv-=1
 if(kisscool>0)kisscool-=1
 for g in all(friends) do
   if(col(k,g)) g.kissd=true
 end
 for w in all(items) do
   if w.name=="cald" or w.name=="cald2" then
    if col(k,w) then
     if emptys>0 then
     giftee=w
     gftspr={120,12}
     if w.name== "cald" then gfteesp=59
     else gfteesp=47 end
     gstate="prompt"
     end
    end
   end
  if w.name=="candle" then
   if col(k,w) then
   w.flameon=false
    if w.nom=="cave" then
    cavecandle=true
    end
    if w.nom=="wetland" then
    wetlandcandle=true
    end
    if w.nom=="mangrove" then
    mangrovecandle=true
    end
   end
  end
  end
end




--particl={}
--[[
function updpart(pa)
 if(pa.tm<=0)del(particl,pa)
 --if(colpart(pa))p.lv-=1 p.ifrm=30
 pa.tm-=1
end

function colpart(pa)
  pt={x=pa.x,y=pa.y}
  if(pt.x>p.x+p.hw) pt.x=p.x+p.hw
  if(pt.x<p.x) pt.x=p.x
  if(pt.y>p.y+p.hh) pt.y=p.y+p.hh
  if(pt.y<p.y) pt.y=p.y

  if(sqr((pt.x-pa.x)^2+(pt.x-pa.x)^2)<pa.atsiz) return true
  return false
end
]]--
--------------------------------
----functional------------------
--square root.
--function sqr(a) return a*a end


function col(e1,e2)
local x1=e1.x+e1.hx
local y1=e1.y+e1.hy
local x2=e2.x+e2.hx
local y2=e2.y+e2.hy
 if(x1>x2+e2.hw)return false
 if(y1>y2+e2.hh)return false
 if(y1+e1.hh<y2)return false
 if(x1+e1.hw<x2)return false
 return true
end


function loadroom()

foes={}
friends={}
items={}
bubbles={}

mp=maplookup()
if(not mp)return

for e=3,#mp,5 do
 if mp[e+4]==true then
 local en=mp[e](mp[e+1],mp[e+2],mp[e+3])
 for jb in all(friendslst) do
  if(jb.id==mp[e+3]) bubble(mp[e+1],mp[e+2],jb.want)
 end
 candlechk()
 end
 end
end

function maplookup()

local mp=nil
for r in all(rooms) do
 if r[1]==mapx and r[2]==mapy
  then mp=r
  break
  end
 end
if(not mp)return

return mp
end

function itmset(i)
mp=maplookup()
for e=3,#mp,5 do
 if mp[e]==i.name
  then
   if mp[e+1]==i.x and mp[e+2]==i.y
    then mp[e+4]=false end
 end
 end
itmtotal+=1
end

------------------------
function updf(c)
if c.lv<1 then
 --del(foes,c)
 --del(ents,c)
 --dust(c.x,c.y)
 c.stun=true
 c.lv=c.lvmx
 c.stuntmr=45
end
if(c.stuntmr<=0) c.stun=false
if(c.stun) c.stuntmr-=1 return

if(c.mvfree)seedf(c) c.tmr-=1

movef(c)
anim(c,c.sf,c.alen,3)

if p.ifrm<1 then
if(col(c,p))p.lv-=1 p.ifrm=30
end
end

function movef(c)

  if(c.movesd==0)c.dy=c.spd
  if(c.movesd==1)c.dx=c.spd
  if(c.movesd==2)c.dy=-c.spd
  if(c.movesd==3)c.dx=-c.spd
  if(c.movesd==4)c.dx=0 c.dy=0

  local cx,cy= c.x,c.y
  
  c.x,c.y=move(c,c.dx,c.dy)
  
		
		if(cx==c.x and dx!=0) c.dx*=-1
		if(cy==c.y and dy!=0) c.dy*=-1
		
  if(c.x>boundx or c.x<0)c.dx*=-1
  if(c.y>boundy or c.y<0)c.dy*=-1
end

function seedf(c)
  local n=5
  if(c.at==true) n=6
  if c.tmr<=0 then
    c.dx,c.dy= 0,0
    c.movesd=flr(rnd(n))
    c.tmr=c.tmrmax
  end
end

--[[
function attackf(e)
  e.sprt=e.atspr
  bz={(e.x*8)+34,(e.y*8)+24,e.atsiz,e.atcol}
  bz.tm=5

  if p.ifrm<1 then
    local zone={
      x=e.x,
      y=e.y,
      hx=0,
      hy=0,
      hw=e.hw+e.atsiz,
      hh=e.hh+e.atsiz
   }
  --if(col(zone,p))p.lv-=1 p.ifrm=30
  end

  add(particl,bz)
end
]]--

-----------------
switchd=false
function switchem()
if(switchd==false)switchd=true
if(switchd==true)switched=false
end

function switchchk(sw)
if sw.typ== 1 then
 if switchd==true then
  sw.sf=71
 else sw.sf=70 end
elseif sw.typ==2 then
 if switchd==true then
  sw.sf=86
 else sw.sf=87 end
end
end
-----------------
function drawlv()
--spr(12,0,12)
color(2)
print("courage",1,12)
rectfill(32,13,32+p.lv*4,15)

--local ind=20
--[[for e in all(foes) do
if e.stuntmr%8<4 then
 rectfill(110,ind,110+e.lv*4,ind+2,2)
 ind+=9
end
end
]]

end


gftspr=0
giftee=nil
promptanswer=true

ansmod=0
function drawprompt()
rectfill(26,26,100,80,1)
spr(gfteesp,76,40)
sspr(gftspr[1],gftspr[2],4,4,47,43)
print("‘",60,42,2)
print("Ž",42,63,11)
print("—",78,63,8)
print(giftee.name,28,74,6)
rect(39+ansmod,60,51+ansmod,70,7)
end


ldgx=96
ldgmx=30
ldgmn=96
function drawfrnds()

rectfill(ldgx,13,170,128,1)
if ledgefull then
print("‘",ldgx-10,63,1)
else print("‹",ldgx-10,63,1) end
local id=0
 for u in all(friendslst) do
  if u.kissd==false then
   print("???",ldgx+2,17+id,13)
  else
  	print(u.name,ldgx+2,17+id,7)
   sspr(0,5,4,3,ldgx+27,18+id)
   if ledgefull then
   for x=1, u.hppyns do
   sspr(120,8,3,3,ldgx+31+x*6,18+id)
   end
   end
  end
  id+=9
 end
end

function updui()
if ledgefull and ldgx!=ldgmx then
ldgx-=3
elseif ledgefull==false and ldgx!=ldgmn then
ldgx+=3
end
if(ldgx<ldgmx)ldgx=ldgmx
if(ldgx>ldgmn)ldgx=ldgmn
end
--------------------
--title--------------
titleflash=10
circx=65
circy=37
circr=9
function introit()
 titleflash-=1
 if(titleflash<0)titleflash=40
 if titleflash==40 or titleflash==20 then
 if circr==9 then circr=13 else circr=9 end
 end
  
  print("ˆ",62,35,2)
  circ(circx,circy,circr,3)
  if(titleflash<20)print("— to dive in",38,86,13)
  print("fen friends",44,70,2)
  line(4,110,124,110,2)
  print("good neighbor games 2018",6,112,2)
  print("ŠŠ",104,112,3)
end


--------------------
--the finale--------
function victorycount()
for n in all(friendslst) do
 if(n.kissd) met+=1
 happitotal+=n.hppyns
end
end

function victory()
rectfill(0,0,128,128,2)
rectfill(42,20,86,40,0)
rect(41,19,87,41,10)
print("you picked "..trulove,32,44,6)
spr(trulvsp,60,26)
rect(9,0,10,128,1)
rect(118,0,119,128,1)
print("friends met:",17,68,13)
print(met.."/12",86,68,13)
print("items found:",17,84,13)
--note: i need to actually get an item total
print(itmtotal.."/67",86,84,13)
print("total happiness:",17,100,13)
print(happitotal,98,100,13)
end
--------------------
--the essentials----
function _init()
gstate="introit"
swami()
for f in all(friendslst) do
  f.kissd=false
  f.hppyns=0
end
palt(0,false)
palt(14,true)
end

function _update()
updp()
foreach(kissz,kisupd)
foreach(foes,updf)
foreach(friends,updfrds)
foreach(items,upditm)
foreach(bubbles,bubbleupd)
--foreach(particl,updpart)
chkgates()
end

function _draw()
cls()
palt(0,false)
if gstate=="introit" then introit()
elseif gstate=="fin" then victory()
else
map(mapx,mapy,30,20,8,8)
if p.ifrm%8<4 then
drawe(p)
end

if sink>0 then
rectfill(p.x*8+30,p.y*8+20+8-sink,p.x*8+38,p.y*8+28,12)
end

foreach(foes,drawe)
foreach(friends,drawe)
foreach(kissz,drawe)
foreach(bubbles,bubbledrw)
foreach(items,drawe)
--[[
for pa=1,#particl,1 do
 local px=particl[pa]
    circ(px[1],px[2],px[3],px[4])
end
--]]


drawlv()
color(2)
spr(9,6,23)
print(":"..keys,15,25)
spr(13,6,34)
print(":"..flwrs,15,36)
spr(46,6,45)
print(":"..pinaps,15,47)
spr(45,6,56)
print(":"..berri,15,58)
spr(44,6,67)
print(":"..hunys,15,69)

if finalrose==0 then
print("???",101,23)
else
spr(77,99,23) end
if(finalrose>0) spr(0,111,20)
spr(60,99,34)
print(":"..emptys,107,36)
spr(59,99,45)
print(":"..psns,107,47)
spr(47,99,56)
print(":"..juice,107,58)
spr(10,99,67)
print(":"..bttl,107,69)


print("\136",58,3)
line(0,10,126,10)

if(gstate=="list")drawfrnds()
if(gstate=="prompt")drawprompt()
end
end
-->8
--swamp thing

function swami()
p=ent(4,4)
p.spd=.15
p.alen=2
p.lv=7
p.ifrm=0
return p
end

function updp()
if p.lv<1 then
 for i=1,60 do
 rectfill(0,0,128,120,0)
 print("love is hard in the swamp",14,25,7)
 flip()
 end
	resetp()
 return

end

if gstate=="normal" then
local dx=0
local dy=0
if btn(0)then
dx-=p.spd
p.left=true
anim(p,5,2,5)
lastfrm=5
elseif btn(1)then
dx+=p.spd
p.left=false
anim(p,5,2,5)
lastfrm=5
elseif btn(2)then
dy-=p.spd
anim(p,3,2,5)
lastfrm=3
elseif btn(3)then
dy+=p.spd
anim(p,1,2,5)
lastfrm=1
else p.sprt=lastfrm end

doorchk(dx,dy)
p.x,p.y=move(p,dx,dy)

if(p.x>boundx)mapx+=8 p.x=0 loadroom() --1
if(p.x<0)mapx-=8 p.x=7 loadroom() --2
if(p.y<0)mapy-=8 p.y=7 loadroom() --3
if(p.y>boundy)mapy+=8 p.y=0 loadroom() --4

if lastfrm==1 then sinkingfeeling(flr(p.x),ceil(p.y+0.4))
elseif lastfrm==3 then sinkingfeeling(flr(p.x),flr(p.y+p.hh))
elseif p.left then sinkingfeeling(flr(p.x),flr(p.y+0.2))
else sinkingfeeling(flr(p.x+p.hw),flr(p.y+0.2)) end

if sink>6 then
  p.lv-=1
  sink=0
  p.x=lastsafex
  p.y=lastsafey
  mapx=lastsafemx
  mapy=lastsafemy
  loadroom()
end
--if #kissz<2 then
if kisscool<=0 then
if(btnp(4))smooch(lastfrm)
end

--ledger if
elseif gstate=="list" then
updui()
if(btn(0))ledgefull=true
if(btn(1))ledgefull=false

elseif gstate=="prompt" then
  if(btn(0))promptanswer=true ansmod=0
  if(btn(1))promptanswer=false ansmod=36
  if btnp(4) then
    if promptanswer then
     if(giftee.name=="cald") emptys-=1 psns+=1 gstate="normal" return
     if(giftee.name=="cald2") emptys-=1 juice+=1 gstate="normal" return
      if(giftee.want[1]==0)flwrs-=1
      if(giftee.want[1]==1)bttl-=1
      if(giftee.want[1]==2)berri-=1
      if(giftee.want[1]==3)pinaps-=1
      if(giftee.want[1]==4)psns-=1
      if(giftee.want[1]==5)juice-=1
      if(giftee.want[1]==6)hunys-=1
      if(giftee.want[1]==7)finalrose-=1 gstate="fin" victorycount() trulove=giftee.name trulvsp=gfteesp return
      giftee.hppyns+=1
      if(giftee.hppyns==8)roseready=true
      del(giftee.want,giftee.want[1])
      gstate="normal"
    else gstate="normal" promptanswer=true ansmod=0 end
  end

--elseif gstate=="fin" then


end

if gstate=="introit" then
 if btnp(5) then
  gstate="normal"
 end
elseif gstate=="fin" then
 if btnp(5) then
 resetp()
 gstate="introit"
 end
else
 if btnp(5) then
  if(gstate=="prompt") return
  if gstate=="normal" then gstate="list"
  else gstate="normal" ledgefull=false end
 end
end


if(p.ifrm>0)p.ifrm-=1
end

function resetp()
 mapx=64
 mapy=24
 ents={}
 friends={}
 bubbles={}
 items={}
 keys=0
 flwrs=0
 berri=0
 hunys=0
 pinaps=0
 emptys=0
 psns=0
 juice=0
 bttl=0
 finalrose=0

 itmtotal=0
 swami()
end
-->8
--------------------------------
----items-----------------------
items={}
keys=0
flwrs=0
berri=0
hunys=0
pinaps=0

emptys=0
psns=0
juice=0
bttl=0
finalrose=0

itmtotal=0

cavecandle=false
wetlandcandle=false
mangrovecandle=false

cavegate=false
wetgate=false
grovegate=false

roseready=false
rosegate=false

function cald(x,y)
local e=ent(x,y)
e.sf=82
e.name="cald"
add(items,e)
end

function cald2(x,y)
local e=ent(x,y)
e.sf=120
e.name="cald2"
add(items,e)
end

function jet(x,y,type)
local e=ent(x,y)
e.sf=23
e.name="jet"
e.jeton=false
if type==15 then
  e.jtmrmax=15
  e.jinterval=30
  e.jtmr=30
elseif type==30 then
  e.jtmrmax=30
  e.jinterval=45
  e.jtmr=30
elseif type==45 then
  e.jtmrmax=45
  e.jinterval=60
  e.jtmr=15
elseif type==60 then
  e.jtmrmax=60
  e.jinterval=60
  e.jtmr=15
end
e.sf2=39
add(items,e)
end

function candle(x,y,nom)
local e=ent(x,y)
e.sf=99
e.alen=2
e.flameon=true
e.name="candle"
e.nom=nom
e.sf2=78
add(items,e)
end

function dust(x,y)
local e=ent(x,y)
e.sf=66
e.alen=1
e.timr=9
add(items,e)
end

function key(x,y)
local e=ent(x,y)
e.sf=9
e.alen=1
e.name=key
add(items,e)
end

function flwr(x,y)
local e=ent(x,y)
e.sf=13
e.alen=1
--e.col=col
e.name=flwr
add(items,e)
end

function berry(x,y)
local e=ent(x,y)
e.sf=45
e.alen=1
e.name=berry
add(items,e)
end

function huny(x,y)
local e=ent(x,y)
e.sf=44
e.alen=1
e.name=huny
add(items,e)
end

function pinap(x,y)
local e=ent(x,y)
e.sf=46
e.alen=1
e.name=pinap
add(items,e)
end

function empty(x,y)
local e=ent(x,y)
e.sf=60
e.alen=1
e.name=empty
add(items,e)
end

function lvpotion(x,y)
local e=ent(x,y)
e.sf=10
e.alen=1
e.name=lvpotion
add(items,e)
end


function rose(x,y)
local e=ent(x,y)
e.sf=77
e.alen=1
e.name=rose
add(items,e)
end

function upditm(i)
anim(i,i.sf,i.alen,3)
if i.timr!=nil then
 if i.timr>0 then i.timr-=1
 else del(items,i) end
end

if i.name==key then
  if col(i,p) then
   keys+=1
    itmset(i)
    del(items,i)
  end

elseif i.name==flwr then
  if col(i,p) then
    flwrs+=1
    itmset(i)
    del(items,i)
  end

elseif i.name==lvpotion then
  if col(i,p) then
    if(p.lv<7)p.lv+=1
    bttl+=1
    itmset(i)
    del(items,i)
  end

elseif i.name==rose then
  if col(i,p) then
   finalrose+=1
   itmset(i)
   del(items,i)
  end

elseif i.name==huny then
 if col(i,p) then
  hunys+=1
  itmset(i)
  del(items,i)
 end

elseif i.name==berry then
 if col(i,p) then
  berri+=1
  itmset(i)
  del(items,i)
 end

elseif i.name==empty then
 if col(i,p) then
  emptys+=1
  itmset(i)
  del(items,i)
 end

elseif i.name==pinap then
 if col(i,p) then
  pinaps+=1
  itmset(i)
  del(items,i)
 end

elseif i.name=='candle' then
 if i.flameon==false then
 anim(i,i.sf2,2,3)
 end

elseif i.name=='jet' then

  if i.jtmr <=0  and i.jeton==false then
    i.jeton=true
    i.jtmr=i.jtmrmax
  elseif i.jtmr<=0 and i.jeton then
    i.jeton=false
    i.jtmr=i.jinterval
  end
  i.jtmr-=1
  if i.jeton then
    anim(i,i.sf2,i.alen,3)
    if p.ifrm<=0 then
    if col(i,p) then
      p.lv-=1
      p.ifrm=45
    end
  end
  end
end
end

function chkgates()
if cavecandle==true and cavegate==false then
 for x=0,3 do
 mset(106+x,56,16)
 end
 cavegate=true
end
if wetlandcandle==true and wetgate==false then
  mset(37,37,0)
  wetgate=true
end
if mangrovecandle==true and grovegate==false then
  for x=0,3 do
  mset(57,58+x,0)
  end
  grovegate=true
end

if roseready==true and rosegate==false then
 mset(21,56,0)
 rosegate=true
end
end

function candlechk()
for yop in all(items) do
if yop.name=="candle" then
  if mapx==40 and mapy==0 and wetlandcandle==true then
   yop.flameon=false
  end
  if mapx==8 and mapy==48 and mangrovecandle==true then
   yop.flameon=false
  end
  if mapx==104 and mapy==32 and cavecandle==true then
   yop.flameon=false
  end
 end
end
end
-->8
----------------------------
---friends------------------

friends={}
friendslst={
	{name="bert",id=1,want={1,2,2,6,6,3,6,5,7},hppyns=0},
	{name="geoff",id=2,want={0,1,0,3,3,1,6,4,7},hppyns=0},
  {name="humfri",id=3,want={0,2,1,0,1,4,4,6,7},hppyns=0},
  {name="banjo",id=4,want={2,1,1,4,3,4,5,4,7},hppyns=0},
  {name="filber",id=5,want={1,0,6,3,1,3,4,5,7},hppyns=0},
  {name="yunis",id=6,want={2,1,6,1,4,5,6,5,7},hppyns=0},
  {name="bryan",id=7,want={1,0,3,2,2,3,2,4,7},hppyns=0},
  {name="agnes",id=8,want={0,0,2,4,4,3,6,6,7},hppyns=0},
  {name="maude",id=9,want={3,3,3,3,4,4,4,0,7},hppyns=0},
  {name="heidi",id=10,want={2,6,0,1,6,4,5,6,7},hppyns=0},
  {name="cthulu",id=11,want={0,0,2,3,6,2,5,4,7},hppyns=0},
  {name="haris",id=12,want={1,6,2,0,1,3,4,5,7},hppyns=0}
}

met=0
happitotal=0

wants={
 {0,{80,36}},--flower
 {1,{80,32}},--lvpotion
 {2,{84,32}},--berry
 {3,{84,36}},--pinap
 {4,{88,32}},--poison
 {5,{88,36}},--juice
 {6,{92,32}},--honey
 {7,{92,36}} --finalrose
 }

function updfrds(c)
  for k in all(friendslst) do
   if k.id==c.id then
     if c.kissd then
      k.kissd=true
      if k.want[1]==0 then
        if flwrs>0 then
        enterprompt(k,c)
       end
      elseif k.want[1]==1 then
       if bttl>0 then
       enterprompt(k,c)
       end
      elseif k.want[1]==2 then
       if berri>0 then
       enterprompt(k,c)
       end
      elseif k.want[1]==3 then
       if pinaps>0 then
        enterprompt(k,c)
       end
      elseif k.want[1]==4 then
       if psns>0 then
       enterprompt(k,c)
       end
      elseif k.want[1]==5 then
       if juice>0 then
       enterprompt(k,c)
       end
      elseif k.want[1]==6 then
       if hunys>0 then
       enterprompt(k,c)
       end
      elseif k.want[1]==7 then
       if finalrose>0 then
       enterprompt(k,c)
       end
      end
     c.kissd=false
  end
  end
 end
 anim(c,c.sf,c.alen,3)
end

function enterprompt(k,c)
for it in all(wants) do
 if k.want[1]==it[1] then
  gftspr=it[2] end
end
giftee=k
gfteesp=c.sprt
gstate="prompt"
end

bubbles={}
function bubble(x,y,want)
local bub=ent(x,y-1)
bub.sprt=15
bub.alen=1
bub.want=want
for it in all(wants) do
 if bub.want==it[1] then
  bub.ss=it[2]
  end
end
if(bub.want==nil) bub.ss={0,4}
if(mapx==16 and mapy==0)bub.y-=1
add(bubbles,bub)
return bub
end

function bubbleupd(b)
--if(b.want==nil) return
if(b.want==nil or b.want=={}) b.ss={0,4}
for it in all(wants) do
 if b.want[1]==it[1] then
  b.ss=it[2]
  end
 end

end

function bubbledrw(e)
drawe(e)
if e.ss==nil then
sspr(0,4,4,4,e.x*8+32,e.y*8+21)
else
sspr(e.ss[1],e.ss[2],4,4,e.x*8+32,e.y*8+21)
end
end

--------------------
--friend types------

function nessi(x,y,i)
local e=ent(x,y,i)
e.sf=118
e.alen=1
local g=ent(x,y-1,i)
g.sf=102
g.alen=1
add(friends,e)
add(friends,g)
end

function croc(x,y,i)
local e=ent(x,y,i)
e.sf=67
add(friends,e)
end

function devil(x,y,i)
local e=ent(x,y,i)
e.sf=112
add(friends,e)
end

function witch(x,y,i)
local e=ent(x,y,i)
e.sf=80
add(friends,e)
end

function pyrm(x,y,i)
local e=ent(x,y,i)
e.sf=33
e.alen=4
add(friends,e)
end


function snerson(x,y,i)
local e=ent(x,y,i)
e.sf=17
e.alen=3
add(friends,e)
end

function hat(x,y,i)
local e=ent(x,y,i)
e.sf=20
e.alen=3
add(friends,e)
end

function bee(x,y,i)
local e=ent(x,y,i)
e.sf=37
add(friends,e)
end

function king(x,y,i)
local e=ent(x,y,i)
e.sf=49
add(friends,e)
end

function medusa(x,y,i)
local e=ent(x,y,i)
e.sf=51
add(friends,e)
end

function skeleton(x,y,i)
local e=ent(x,y,i)
e.sf=64
add(friends,e)
end


function ivy(x,y,i)
local e=ent(x,y,i)
e.sf=114
add(friends,e)
end

function beast(x,y,i)
local e=ent(x,y,i)
e.sf=105
add(friends,e)
end

--[[
function snail(x,y,i)
local e=ent(x,y,i)
e.sf=116
e.alen=1
e.sn=true
add(friends,e)
end
]]
foes={}

function fuzz(x,y,i)
local e=ent(x,y,i)
e.sf=96
e.at=true
e.atspr=98
e.atsiz=14
e.atcol=9
e.dx=0
e.dy=0
if i==104 then
e.mvfree=true
else e.mvfree=false end

if i==100 then
e.dy=e.spd
elseif i==101 then
e.dx=e.spd
elseif i==102 then
e.dy=-e.spd
elseif i==103 then
e.dx=-e.spd
end
add(foes,e)
end

-->8
---------------------
--rooms--------------

rooms={
{0,0,
berry,7,5,0,true
},
{0,8,
empty,1,2,0,true
},
{0,16,
berry,2,4,0,true,
pinap,2,6,0,true
},
{0,32,
berry,6,3,0,true
},
{0,40,
pinap,4,4,0,true
},
{0,56,
empty,1,6,0,true
},
{8,0,
empty,4,2,0,true,
pinap,5,6,0,true,
lvpotion,3,4,true
},
{8,8,
croc,5,4,9,true
},
{8,48,
candle,6,2,"mangrove",true
},
{8,56,
huny,3,2,0,true,
key,6,1,0,true
},
{16,0,
nessi,4,3,3,true
},
{16,8,
lvpotion,1,1,0,true
},
{16,40,
empty,4,6,0,true
},
{16,48,
rose,4,1,0,true
},
{24,0,
pinap,2,1,0,true,
lvpotion,7,5,0,true
},
{24,16,
berry,3,2,0,true
},
{24,24,
empty,6,2,0,true,
flwr,5,2,0,true
},
{24,32,
berry,6,1,0,true
},
{32,0,
cald2,5,4,0,true,
huny,5,1,0,true,
huny,6,3,0,true
},
{32,16,
berry,3,5,0,true,
key,6,2,0,true
},
{32,24,
huny,1,1,0,true
},
{32,32,
berry,6,6,0,true
},
{32,40,
king,3,1,1,true
},
{32,48,
fuzz,2,5,100,true,
fuzz,4,5,100,true,
fuzz,1,2,102,true,
jet,3,1,15,true,
jet,3,2,15,true,
fuzz,5,3,102,true,
jet,6,1,30,true,
jet,6,2,30,true
},
{32,56,
huny,4,3,0,true
},
{40,0,
candle,4,1,"wetland",true,
huny,3,1,0,true
},
{40,16,
lvpotion,3,2,0,true
},
{40,32,
flwr,6,3,0,true
},
{40,48,
empty,1,4,0,true,
empty,1,5,0,true,
flwr,5,6,0,true
},
{40,56,
ivy,1,3,10,true,
empty,6,1,0,true
},
{48,8,
jet,6,5,30,true
},
{48,16,
key,3,4,0,true
},
{48,32,
pinap,2,5,0,true
},
{48,40,
fuzz,4,3,102,true
},
{48,48,
key,5,2,0,true
},
{56,24,
lvpotion,2,6,0,true
},
{56,32,
lvpotion,1,2,0,true
},
{56,40,
empty,6,5,0,true
},
{56,48,
key,1,1,0,true,
flwr,3,2,0,true,
huny,1,4,0,true,
empty,2,6,0,true
},
{56,56,
pinap,5,1,0,true
},
{64,8,
berry,2,2,0,true
},
{64,16,
--king,3,3,1,true,
lvpotion,2,5,0,true,
key,3,1,0,true
},
{64,32,
medusa,5,2,12,true
},
{64,48,
pinap,6,3,0,true
},
{72,0,
flwr,5,4,0,true
},
{72,8,
lvpotion,2,4,0,true
},
{72,24,
pyrm,5,3,2,true,
flwr,6,6,0,true
},
{72,16,
hat,4,6,5,true
},
{72,48,
bee,2,3,0,true,
bee,3,5,0,true,
bee,6,6,0,true,
bee,5,4,0,true,
flwr,4,6,0,true,
empty,2,6,0,true,
huny,1,4,0,true,
huny,4,5,0,true,
huny,5,6,0,true
},
{72,56,
huny,2,3,0,true,
pinap,5,1,0,true,
empty,2,5,0,true
},
{48,24,
devil,1,3,4,true
},
{80,0,
witch,3,1,6,true
},
{80,24,
flwr,5,5,0,true
},
{80,32,
huny,1,3,0,true,
jet,3,3,45,true,
jet,2,3,45,true,
jet,2,2,15,true,
jet,2,4,15,true
},
{80,40,
berry,1,5,0,true
},
{80,56,
jet,1,1,15,true,
jet,2,1,15,true,
jet,3,1,15,true,
jet,1,2,30,true,
jet,2,2,30,true,
jet,3,2,30,true,
jet,1,3,45,true,
jet,2,3,45,true,
jet,3,3,45,true
},
{88,0,
key,4,1,0,true,
cald,2,2,0,true,
cald,2,4,0,true,
cald,5,3,0,true
},
{88,8,
fuzz,2,1,104,true,
fuzz,4,4,104,true,
fuzz,3,5,104,true
},
{88,16,
snerson,2,1,7,true,
jet,6,3,45,true,
jet,6,0,60,true
},
{88,24,
jet,3,1,60,true,
lvpotion,5,2,0,true,
key,6,5,0,true
},
{88,48,
berry,3,2,0,true
},
{96,0,
pinap,2,2,0,true,
flwr,2,5,0,true,
jet,5,1,60,true,
jet,3,2,45,true,
jet,2,1,45,true,
jet,2,3,45,true,
jet,1,2,45,true
},
{96,8,
jet,1,6,60,true,
jet,2,7,60,true,
jet,3,7,60,true,
jet,4,6,60,true
},
{96,16,
berry,4,2,0,true,
pinap,1,5,0,true,
jet,6,4,45,true,
jet,6,5,15,true,
jet,6,6,45,true,
jet,5,4,15,true,
jet,5,5,45,true,
jet,5,6,15,true,
jet,4,4,15,true,
jet,4,5,15,true,
jet,4,6,15,true
},
{96,24,
fuzz,3,5,103,
fuzz,5,2,101
},
{96,32,
empty,5,1,0,true
},
--{96,56,
--candle,0,5,"cave",true
--},
{104,0,
lvpotion,3,4,0,true,
jet,3,1,45,true
},
{104,24,
beast,3,3,11,true,
key,6,4,0,true
},
{104,32,
empty,1,1,0,true,
candle,3,6,"cave",true
},
{104,40,
fuzz,2,4,100,true,
fuzz,0,6,102,true
},
{112,0,
jet,5,6,60,true,
jet,6,4,30,true,
jet,5,2,45,true,
jet,6,2,45,true
},
{112,16,
jet,6,5,30,true,
jet,6,6,30,true
},
{112,24,
jet,1,2,60,true,
jet,6,2,15,true
},
{112,32,
huny,6,6,0,true,
jet,1,2,45,true
},
{112,40,
lvpotion,5,2,0,true,
fuzz,2,3,101,true
},
{112,48,
pinap,1,6,0,true,
fuzz,2,0,100,true
},
{120,0,
pinap,6,6,0,true,
flwr,6,1,0,true,
jet,2,1,45,true,
jet,5,4,60,true,
jet,6,4,60,true,
jet,1,5,15,true,
jet,1,6,15,true,
jet,2,5,45,true,
jet,2,6,30,true,
jet,3,5,45,true,
jet,3,6,15,true
},
{120,8,
skeleton,4,1,8,true
},
{120,16,
berry,2,2,0,true,
flwr,1,1,0,true,
jet,2,5,45,true,
jet,2,6,45,true,
jet,3,5,45,true,
jet,3,6,45,true,
jet,5,2,30,true,
jet,6,2,30,true,
jet,5,3,60,true,
jet,6,3,60,true
},
{120,32,
empty,2,2,0,true,
huny,5,2,0,true,
pinap,2,5,0,true,
key,5,5,0,true
}
}
__gfx__
eeeeeeee3e3333e33e3333e33e3333e33e3333e33e3333ee3e3333ee0000000000020000eeeeeeeeeeeeeeeeee8e8eee00cccc00eeeeeeee00000000effffffe
eeeeeeeeb333333bb333333bb333333bb333333bb333333eb333333e000d0000000d000066eee66eeee44eeee88888ee0ccdccc0eeddddee00000000ffffffff
eeeeeeeeb353353bb353353bb333333bb333333bb333353eb333353e00cdcccccccdcc006e6e6e6ee666666e8558558ecccdcccced2dd2de0ffffff0ffffffff
eeeeeeee313993133139931331333313313333133133339e3133339e0ccdccdccccdccc0e66e66eeee6996eee88588eecccdcc2cedd9adde0fddfdf0ffffffff
eeeeeeeeee1331eeee1331eeee1111eeee1111eeee1131eeee1131eecccdccdccccdcdcceee6eeeee6999f6eee888eeecdccccdcedd99dde0ffffff0ffffffff
eee3eeeeee3333eeee3333eeee3113eeee3113eeee3333eeee3333eeccccccdccdcccdccee6e6eeee699996eeeeeeeeecdcc2cdced2dd2de0000f000effffffe
3e3eeeeee333333ee333333ee333333ee333333ee33333eee33333ee0cccccdccdccccc0e6eee6eee699996eeeeeeeeeccccdccceeddddee0000f000eeeeffee
e3eeeeeeee3ee3eeeeeee3eeee3ee3eeee3eeeeeee3e3eeeeeeee3ee00cccccccccccc006eeeee6eee6666eeeeeeeeee0cccccc0eeeeeeee0000f000eeefeeee
ddddddddeee333eeeeee333eee333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ddd01000bb30300000000000000d00000000000eeeeeeee8e8eeeee
22d2d22de33eee3eee33eee333eee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebeeeeedd1ddd10bb3b3b300000000d0000d0000000000deeeeeeee888eeeee
dddddd2de3fee33eee3fe33e3feee3eeeeeeeeeeeeeeeeeeeee1eeeeeeeebeeeeeeeeeeeddd1ddd133b3bbb20d00000d0d00d0000d00000deeeeeeeee8eeeeee
dddddd2de5573555e5573555e5573555eee1eeeeeeeeeeeeeee11eeeeeeeeeeeeeeebeee0dd1dd1103bbb3320d00000d0d00d0000d00000deeeeeeeeeeeeeeee
d222d222ee57755eee57755eee57755eeee11eeeeeee11eeeee11eeeeebeeeeeeeeeeeeeddddd1103b3b33200d00200d0d00d0000d00d00deeeeeeee6446eeee
dd2dddddee55555eee55555eee55555eeee11eeeeee11eeeee1111eeeeeeebeeeeebeeee0d111110032222000d00d00d0d00d00d0d00d00deeeeeeeee66eeeee
2d2222ddee55555eee555e5eee5e555eee1111eeee1111ee11178111552222555522225500244000002440000dccdccd0dccdccd0dccdccdeeeeeeee6666eeee
ddddddddee5eee5eee5eeeeeeeeeee5e1111111111111111e188871ee555555ee555555e0444440004444400ccccdccccdcccccdccccdccceeeeeeee6666eeee
56666665eeeeeeeeeeeeeeeeeeeeeeeeeee99eeeeeeceeeeeeeeeeeeeeebeebeeeebeeee0000002000000030000b0000e99eeeeeee331e33ee3e1eeeeeeeeeee
65565666eee99eeeeee99eeeeee99eeeeeffffeeeeceeeeeeeeeeeeeeebeeeeeeeeebeee02000000030000000b0b0b009af9e99eeee3331e3331bbeeeee44eee
65666666eeffffeeeeffffeeeeffffeee997799ee90eeeeeeeceeeeeeebbebeeeebebbee0000000000000000bb0b00b09aa99af9ee883131ee3b3eeee666666e
65566565e999999ee997799ee997799eff7557ffeee6eeeee90eeeeeeeb3bbeeeebb3bee0002002000030030b03b03b0e9999aa9e8788833eea34eeeee6886ee
66565665ff5ff5ffff7557ffff7557ff99955999eeeeeceeeee6e6eeeeb3bbeeeeeb3bee0000000030000000b30b303bee99999e87888883ea9a94eee688886e
566566659995599999999999999559995f9999f5eeeee09eeeeeee09eeeb3eeeeee3beee0000020000000300b300b03be9af9eee8f8888eee9a9a4eee658586e
556666555f9999f55f9999f55f9999f55e9ee9e5eeee6eeeeeeeeece55bbbb5555bbbb5500000000000000000b33b3b0e9aa9eee888888eeea9a94eee655556e
55555555ee9ee9eeee9ee9eeee9ee9eeee9ee9eeeeeeeeeeeeeeeeeee555555ee555555e20020002300300030bbbbb00ee99eeeee8888eeeee994eeeee6666ee
00066650eeeeeeeeeeaaeaeee3e3ee333e3e33e33e33ee3e0000000003000330033000300020000022222222eebebeeeeeeeeeee00065550cc7ccccc0000b01b
00666655eeaeaaeeeeaaaaee3e3e33eee3e3e3e3e3e3e3e30099990033330330033033330020010022522225eee44eeeeee44eee00656655cc7cc6cc00003bb3
06666665eeaaaaeee313313e3e33533ee333333ee33333330aaaaaa035333353313333132022012025222252e666666ee666666e06665665c776767c0002d2b1
06665555e313313e73377337e35555e33e5555333e3353ee0999999035335353313133132122112022222222ee6b36eeee6776ee06656655c767767c0227223b
0666655573377337337777333ed5523e3ed5523ee38558330aaaaaa030534303303131032122122022222222e6b3bb6ee666676e06666555c767767c2df22210
0666565533777733e3e77e3e3dd2d22eedd2dd23edd5522e0995599030034300001130032212122022522252e63b336ee666666e06665655cc7667cc22222210
66666555ee3773eee33ee33eeddd2d2eedd2dd2eeddd2d2e0aa55aa000434400004414000221220025222522e633336ee666666e66666555ccc3cccc12222100
6555555133eeee33ee3ee3eeedddd22eeddd2d2eedddd22e99999999c444c44cc44c444c0022200022222222ee6666eeee6666ee65555551cccc333c01111000
eee77eeeeee77eee00100000cccccccccccccccccccccccc000000000000000006666666666666606446e3336446e99e6666666600666600eeeeeeeeeeeeeeee
ee7777eeee7777ee01000010ccc32ccccccccccccccccccc00000000000000006656655555555566e66e883be66e9aa90555555006000060eeeeeeeeeeeeeeee
ee5775eeee5775ee01000000cc32333cccc323cccccccccc02222220000000006566666666666656699678836bb69aa90656565060081806eeeeeeeeeeeeeeee
eee77eeee7e77eee00000110c33337cccc3233cccccccccc0222dd200000000066666f56666666566666888e6666e99e0656565060088006eee5eeeeeee5eeee
e776677e7e76677e00001000cc333ccccc333ccccccccccc02222d20000000006566666666f56656edde33336446e66e06565650600b0076ee777eeeee777eee
6ee77ee67ee77ee6100000003ccccccccccccccccccccccc52222d2552dddd256566666666666656dd9dea9ee66e68860656565060bb0076eee76eeeeee76eee
7e7667e7ee7667e701100100ccc3cccccccccccccccccccc52222225522222250655555555555560dddda9a968866be6065656506000b006eee76eeeeee76eee
ee7ee7eeee7eeeee00000000cccccccccccccccccccccccc05555550055555500066666666666600eddeea9e66666eb66666655555555555ee6776eeee6776ee
eeee1eeeeeee1eeeeeee3eeeee3ee3eeeee3eeee0000000000000000000000001111111122222222cccccccccc1111cc0000000000000000000000000000b000
eee111eeeee111eeee3eeeeeeeee3eeee3eee3ee909009090000000000000000111111112292922245454545c111111c999999999999999000b00b0000b00b00
1111111111111111eeeee3eee3eeeeeeee3eeeee90900909099999900000000011111111222922224545454511111111098888888888890000b0b0b00b0b0b00
ee0060eeee0060ee555555555555555555555555099999900999ff90000000001111111122222222454545451111111199898989898989900b0000b00b00b000
ee2022eeee2022eee155551ee155551ee155551e000ff00009999f90000000001111111122222222454545451111111109899898989989000b000b0000b0b000
ee2202eeee2202e21155555511555555115555550009900059999f9559ffff9511111111222292224545454511111111998989898989899000b00b000b000b00
e222222eee22222e111555551115555511155555000ff0005999999559999995111111119292229244444444c111111c0988888888888900000b00b000b0b000
ee0ee0eeee0eee0ee111155ee111155ee111155e0099990005555550055555501111111129222222c22cc22ccc1111cc999999999999999000b00b0000b00b00
ee9ee9eeeeeeeeeeeeeeeeeeee8eeeeeeeee8eeeee8eeeeecccccccccccccccc005555555555555555555555cccccccccccccccccccccccc0066660000666600
e99999eeee9ee9eeee9ee9eeeee88eeeee88eeeeeee88eeeccccccccc111cccc055555500080080000800800c11ccccccc55cccccc11cccc0699996006888860
ee999999e99999eee99999eeee898eeeee898eeeee898eeecc9999cccccccccc055555008000000880000008ccccccccc55551cccccccccc6967799668677886
995959eeee999999ee999999eee5eeeeeee5eeeeeee5eeeec999999ccccc111c555550000000080000000800ccc55cccc11111cccccc111c6999979668888786
ee99999e995959ee999999eeee777eeeee777eeeee777eeec999199ccccccccc555550000800000008000000cc55551ccccccccccccccccc6499979662888786
e9ee9eeeee99999eee11199eeee76eeeeee76eeeeee76eeecccc999ccccccccc555550000080808000808080cc11111cccccccccc55ccccc6449999662288886
eeeeeeeee9ee9eeee9ee9eeeeee76eeeeee76eeeeee76eeeccccc99ccc111ccc555550000080808000808000cccccccccccc111c55551ccc0644496006222860
ee6666eee666666ee666666eee6776eeee6776eeee6776eeccccc99ccccccccc555550000080008000008000cccccccccccccccc11111ccc0066660000666600
ee88eeeeeee88eee8ebbb333eeeeee3eeeeee9eeccccccccccccc99ccccccccceeee8eeeee8ee8ee0000000000000000eeffffee555555000066660000000000
eeee8eeeee8eeeeeebb3bbe38ebbb3e3eeee949eccccccccccccc99ccddddd2cee8eeeeeeeee8eee00000000000000002ffffff20555555006dddd6007070707
ee88eeeeeee8eeee82bbb2e3eb3bbee3eee49944ccc999ccccccc99cddd22dd2eeeee8eee8eeeeee0000010000000000effffffe005555506d677dd607070707
e4eeee4ee4ee8e4ee2828e338bbb2ee3eff94ff9cc99999cccccc99c2d2dddd255555555555555551100000000000000e9afff9e000555556dddd7d677777777
8488884ee488884eeeeeee3ee2828ee3eff99ff9cc99cc9cccccc99c22dddd2ce155551ee155551e001000000000b000f599995f0005555561ddd7d607070707
8ef88feee8f88feeeeee333eee22ee3eed9111d41991c191ccccc99cc22222cc1155555511555555000000100000bb0055ffff5500055555611dddd607070707
e88888eeee8888eeeee33eeee3ee33eeedddddd9111ccc1ccccc1991cccddccc111555551115555500001100000300005aaaaaa50005555506111d6077777777
ee8ee8eeee8ee8eee333e33e3e333e33eedddd19cccccccccccc111ccccccdcce111155ee111155e0000000000030000e5ffff5e000555550066660007070707
b1000000b1b1b1b1b1b10000240000b1b1000000b1b1b1b1b1b1b1b1b1b1b1b1a1a1a1a1a1a1a1a1a1a1a10000a1a1a173737373737373737373737373737373
7373737373737373737373737373737391000000000092919191910000009191030101030303030393939393939393939300930000000093f7f7f70000f7f7f7
b10000002424b1b1b1b10024242400b1b100000000b1b10000b1b176760000b1a1b1a1a1000000a1a100a200000000a173000000000000737373000000007373
7373737300737373737300000000737391919191919200919100000000000091030101010301010393929393000000939300000000000093f7959595959595f7
b100a724242424b1b1b10024002424b1b10000000000000000000076b1c1b1b1a100a1a100c000a1a1a200000000a1a173000000000000737300007080000000
0073730000007300007300007300007391910000919200919191910000000091030303010301010393009200000000000000939393000093f7959595959595f7
b100a724242424b1b1b10024a724a7b1b100b1b1000000000000b176760000000000a1a10000000000a200a1a1a1a2a173000000007300737300007080000000
0000000000000000000000007373007391000000009200910000910000009191030303010301010393009292920000009292929293939393f795c49595c495f7
b100a7242424b1b1b1b12424242400b1b1000000000000000000b176760000000000b1a1000000a2000000a100a100a173000073730000737300000000000000
0000730000737300007373737373007391910000919200919191000000919191030101010303010393000000000000000092920093930093f7959595959595f7
b10000a724b1000000a72400a7a700b1b1000000000000000000007676000000000000a1a1e6a1a1a100a1a2a10000a173000073730000737373730000737373
7373e0000073737373737373730000739191919191920091919100000000919103010103030301039300000092000000000000b200000093f7959595959595f7
b1000000b1a700000000a724242424b1b100000000000000000000767600b100000000000000a2a1a1000000000000a173737373730000737300000000737373
737300000000737373730000000000739191919191920091910000000000919103030101010301039393f600f60000939300939300000093f795c49595c495f7
b1000000b1a7a7b1b1b1b12424a7a7b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1a1a1a1a1a1a1a1a1a1a1a1a1a1a100a173737373737300737300000073737373
7373007300000073730000000000007391000000009200919191919100009191030103030103010393939393939393939393939393939393f7959595959595f7
b1000000b124a7b1b1b1b124242424b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1a17080a1a1a100a173737373737300737300000073737373
7373007300000073730000000000007391000000000000919393939392009393030103030103010303030303030303030303030303030303f7959595959595f7
b1a7a700b12424b1b1b124242470800000a700b1b1b1b12424b1b1000000b1b1000055925500b1b1a1000000000000a173000000000000737300000073000073
7300000000007373730000737300007393930000000000939393930092009293030101010103010101010101010101030301010103030103f7959595959595f7
b100a700b10024b1b1b1b12400000000a72424242424b12424a7b100b170800000000092000000b1a10000000000000000000000007300737300007373000073
7373730000000073730073000073007393000000000000939393939292000093030101010103030303030303010101030301010101010103f7959595959595f7
b100a700b10000b1b1b1b100000000a70024242424242424a700b1e0b1000000000000000000b1b1a10000a1a1a100a173000000007300737300007373000073
7373730000737373730000000000007393000000009300939300009292009393030303030101010101010103030301030301010101010103f7959595959595f7
b1a7a7b1000000b1b1b1b1b100b1b1b1b1b1b1b1242424a700000000000000000000007080b1a100a1b2a100a1a100a17300730000000073730000737373b273
7373000000007373730000000000007393000000009300000000000092920000009393030303030101010101030101030301010303030103f7959595959595f7
b100a7a7b1b1b1b1b1b1b100b124242424a700b1b1b1000000000000000000a1a1a1a1a1a1a1a100a10000a2a200a1a173007300000000737300007373000073
7373730000000073730073000073007393000000939300000000000092929200000093939393930101010101010101010101010301030103f7959595959595f7
b10000a7a7b1b1b1b1002424242424242400000000b100000000000000a1a1a10000a1a1a1a1a100a100a200a2a200a173000000000000737300000000000073
7373000073000073730000737300007393000093000000000000000000009200000000009393930101010101010101010101010101030103f7959595959595f7
b1000000000000b1b1b10000b1b1b1b1b1b1b1b1b1b1b1b1a1000000a1a1a1a1a1a1a1a1a1a1a1a1a1a100a2a1a1a1a173737373737300737373730000000073
7300007373730073737383737373737393939393939393939393939393939393930000000000939303030303030303030303010101010103f7f7959595f7f7f7
b1000000000000b1b1b1b2b2b1b1b1b10055555555555555a1000000a1a1a1a1a1a1a1a1a1a1a1a1a1a10000a1a1a1a173737373737300737373730000000073
7300007373730073737300737373737393939393939393939393939393939393930000000000939303030303030303030303010101010103f7f7e5e5e5f7f7f7
b10000a7a7a7a7a700a700a7000000e70055000000000055a1000000a1a10000000000000000000000a10000000000a173000073000000737300007373000073
7300007373730073737300000000837393939393939300000000009393000093939300000000009303010101010101010101010101010103f7959595959595f7
b100a7a7a7a7a7a7a7a7a7a7000000e700550000c4000055a100000000000000000000000000000000a1a1a1000000a173000073000000737300000073000073
730000000000b273737373737373837393939393000000000000000093930093939300929200009303010101010101010101010101010103f7959595e7e795f7
b1a7a7b1a7a7a7a7a700a7a7000000e70055000092000055a100000000000000000000a10000a100000000a1000000a173000073737373737300000073000073
73000000737300737373006300008373939393930000000000000000009393939393930092000093030101010101010101b2030303030303f79595e6e7e795f7
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10055009292920055a10000000000a1a1a1a1a1a1a1a1a100000000a100000000000000000000007373000000b2000073
7300000000737373730000000000007393939300000000000000000000009393930093009200009303010101010101030301010103010303f79595e6e69595f7
b1b1b1b1b1b1b1b10000b1b100b1b1b10055009292920055a1000000000000000000000000000000000000a1000000a1730000000000007373000000b2000073
73000000000073737300000000000073930000000000000000000000000000939300e00092000093030101010101010303010101b20101d395959595959595f7
b1b1b1b1b1b1b1b1b1b1000000b100b10055000092920055a1000000000000000000000000000000000000a1000000a173000000000000737300000073000073
7373000000000073736300730000007393000000000000939300000000000093930000009292009303010101010101030301010303030303f7959595959595f7
b1b1b1b1b1b1b10000b1b1b1b1b1b1b10055555555925555a1a100000000a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a173000000000073737373737373737373
7373737300000073737373737373737393000000000000939300000000000093939393939392009303010101010103030303030303030303f795959595f7f7f7
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a155a1a1a1a10000920073737373737373737373737373737373737373000000000073737373737373737373
737373730000007393939393939393939300000000000093930000b2b200009393939393930000930303f6f6f6f6030000f7f7f7f7f7f7f7f795959595f7f7f7
a1000000000000a1a1a10000000000a1a1a1a1000000000000000000000000737300000000000073730000007373007373000000000000000073000000000073
73737373000000739300939300009393930000009300009393009300009393939393930000000093930001010101930000f7959595959595959595959595f7f7
a100a2a2a2a200a1a1a100000000a1000000a10000000000009200000000007373007373737300737300000000000073730073737300000000e7730000007373
737300000000007393930000000093939300000093000093939393b2b20093939393000000009393930001010101930000f795959595959595959595959595f7
a100a2e0a2a200a1a1a1000000a100000000000000000000000000e09200007373007300007300737300000000000073730000007300000000e70073b2730000
00000073737300739300000000000000000000009393939393000000000000000000000000009300000000010101930000f795959595959595959595959595f7
a100a2a2a2a200a1a100000000a1000000000000000000000000000000000000000000000073007373737373b2737373730000000000c00000e7767676767600
0000007373730073930000000000000000000000939393939300000000000000000092929200e000000000000000930000f795959595959595959595959595f7
a10000000000000000a10000a10000000000000000a1a19200000000000000000000c073737300000000000000708073730000000000000000e7730073007300
00000000000000739393000000000000000000939393939393939393930000000000920392000000000000000000930000f795959595959595959595959595f7
a100a1a100a1a1000000000000000000000000a1a1a1a1a192929292000092737300000000000000000000000000920000000000000000000073000000000073
73000073730000739393930000000000000093939393939300000000939300000000929292000000009393000000930000f795959595959595959595959595f7
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a173a173737373737373737373737373737373737373737373737373737373737373737373737373
73737373737373739393939393939393939393939393939300000000009393939393939393939393939393939393930000f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
__gff__
0000000000000002020800000200020000000000000000000002020202020000020000000000000000000006000000000200000000000202000200000000020000000000000002020000000002000000000002020202020280000000000002000000000202020008000000020202020200000000000200000202000000000200
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b19191919191919190000001919191919191919191919191919191919191919191919191919191919202020202020202019191919191919193939393939393939393939393939393939393939393939393939393939393939
1b676767676767676767777777776b6767676767677567676767776767676767676c67000000361b19296e00006e291900000019191919000000000000000000000029000029000000001919191919192000555c5d55002019000000000000193900000000000000000000000000000000000039390000000000000000000039
1b676767676777676767773e77776b6767677567676767756767673e773e67775a5a5a2b0000001b19291900001900190000001919191900000000292929000000000000000029000000001919191919200000000000002019000000000000193900000000000000000000000000003939000039390000393939393939000039
1b676777676767676767777777776b6767676767676767676767673e673e6767676b67000000001b19292900000000190000191919190000002900000000000000000000000000000000001919191919205500000000552019000029000000193900000000393939393939393939393939000039390000393939393939000039
1b67676767676767676767773e776b6767756767776767676767676767776777676c67000000001b19291900291929191919191919000029290000000000000029292900000029000000001919001919200000000000002019000000290000193939393939390000393929292939393939000039390000393939393939000039
1b6767676767677767673e7777676b6767676777776767676767773e67676777676d67000000001b192919002919001919191919000000000000000000190000001919290000290000001919000000192000550000550020190000000000001939000000393939393939290e2939393939000039390000000000000000000039
1b676767676767676767676767776b676767677777776767676767673e3e676767676c6b6d6c6d1b19290000002900191919190000000029000019190000191919191919190000000000191900000019200000000000002019000000000000193900000000000000000000002900393939000039390000000000000039390039
1b676777676767676767676b6b6b6b67676777777777676767676777673e6767676767676767671b19291929001929190019000000292900000019000000191919191919190000000000191900000019202020000020202019000000000000193900000000000029000029000000003939000039390000393939393900393939
1b676767676767676767676b6b6b6b67677777677777676767676767676c6767676767676767671b190019000019001929190000000000000000190000001919191919191900002900001919000000191919195c5d19191919000000000000193900000000000029002900000000003939000039390000393939393939393939
1b67676767676767676767676767676b67777767777767676767677767676767676767676767671b1900292929190019190000000000000000001900000019191900000019000000000019190000001919190000000e191919000000000000193900000000000000000000392900003900000000000000393939390000000039
1b6767676767776767775a000000006b6777776777776767676767776b6c6767676767673e77671b19191900292900000029290000000000000019000019191919000000192900000000001900000019190000000000001919000000000019193939393939393939393939390000390000000000003939393939000000000039
1b67677767676767676767000000006b67676777776767676767673e676d6777776767677777671b19191900000000292929000000001919191919000019190000000000192929000000001900000000000000000000000000000000001900000000000000000000000000000039000000000000390000000000000000003939
1b67676767676767676700004545006b67676777776767676777676767676767676767676767671b19191919191919191919191919190000000000000019190000000019000029000000001900000000000000000000000000000000001900000000000000000000000000000039000000000039000000000000000000393939
1b67676767776767676700004545006b67676777776767676767676767776767677767776767671b19190000000000002b00000000190019191919191919190000001900000029000000001900000000000000000000000000000000001900193900000000393939390000000000000000003939000000000000000039000039
1b67776767676767676700000000006b67677777777767676767677767676767676767676767671b19190000000000002b00000000190000000000000000000000001900000000000000001900000000000000000000000000000000001900193900000000003939390000000000000000390000000000393939393939000039
1b676767676767676767676b6b6b6b6b67677777777767676767676767676767676767677767671b19190000001919191919000019191919191919191919191919191919191900191919191919191919191919002900191919191919191900193900000000003939390000000039393939000000000039393939390000000039
1b67676767676767676767676767676767676777777767676767676767676767676767677767671b19190000001919191919000019191919191919191919191919191919191900191919191919191919191919292900191919191919191900193900000000003939390000000039393939000000000039393939000000000039
1b67776767776767677767676767676767676777776767676767673e67676767676767677767671b19190000190000000000000000000000000000000000001919676767190000000000000000000000000000002900191919000000001900193900000000393939393900000000000000000000000039393900000000000039
1b77777767676767676767776767676767676767777767676767677767676777677767676767671b19190000190000000000000000000000000000000000000000006767190029000000000000292929290000002900191919000000001900193939393900390000003900000000000000003900393939393939000039000039
1b77677767676767677767676777776767676767777777676767776767676767676767676767671b191919190000001a1919191919190000000000000000000000006700190029292929291919292929290029292900000000000000001900193900003939000000000000000000000000003939393939393939393939000039
1b77777767676767777767676767777767777777777777676777777767676767676767677767671b1a1a19190000001a1929290000001919191919191900001919676700292929290029292929292929292929000000292929292900001900193900000000000000000000000000000000003939393939393939390000000039
1b676767676767677777676767677777676767777777776777773e7767777767676777777767671b1a191a000000001a1929000000291900000000001929001919000029290000000019002900191900000000000000000000290000191900193900000000000000000000000000000000000000000000000000000000000039
1b67676767676767676767676767676767676777777767676777777767676767676767676767671b1a191a000000001a1900000000001900000000190029001919000029000000191919000000001900000000000000001919292919000000193900000000000000000000000000000000000000000000000000000000000039
1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b7777771b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1a1a1a00001a1a1a191919002919190000001900002929191919000000191919191919191919191919191919191919191929001900001919393939393939393939393939393939393939392b2b3939393939393939393939
1b1b1b1b1b1b1b000000001b1b1b1b1b1b1b1b0000001b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1a1a1a00001a0c1a1919196767191919191919292900001919190000001919191919191919191919191919191919191919290019000019193030303030303030303030303030303039393900003939392020202020202020
1b42424242420c1b1b1b1b7a7a42421b1b0000000000002b0000000000001b1b1b0000676767771b1a2a2a2a0000001a1919000000000000000000002900001919000000000029191900000019000019190000000000001919000000000000193010101010101030303030303030303039000000000000392029555c5d552920
1b0042424242001b1b1b42424242421b1b00000000001b1b1b1b1b1b00001b1b1b00001b6767671b1a2a00000000001a190000000000000000000000290000191900000019192919190000000e000000000000002929292900001919000000193010103030101030303030303030303039003939393900392029292929292920
1b00424242424200007a4242427a421b1b00000000001b00000000001b1b001b1b1b1b67773e671b1a1a1a1a1a00001a1900000000290029290000000000191919192900001900000000290000002900292929001919000000001919190000193010103030101030303068697d30303039000000000000392055290000295520
1b0007084242421b1b1b42427a42421b1b0000000000000000000000000000000000671b1d67671b1a1a1a1a002a2a1a1929290000000000000000000019191919190000000029290029292929292900000000001919191919000000191919193010103030101010103010101030103039390000390000392029290000292920
1b0000070842001b1b1b7a7a4242421b1b000000000000000000000000000000000067676700001b1a1a0000002a000c1900000000000000676767671919191919190000290000000029002900000000001919191900001919000000000000193010101030101010101010101010103039390000393900392055290000295520
1b000007080000000000007a00427a1b1b00000000000000000000000000001b1b6767676700001b1a1a002a0000001a1967000000002967676767191919191919000000000000000000000000000000001900000000001919000708000000193010103030101010101010101010103039000000393900392055550000555520
1b0000001b1b1b1b1b1b00000000001b1b0000001b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1a1a1a00001a1a1a1919191919191919191919191919191919191919191919191919191919191919190000292900001919191900000019193010103030303030303030303030303039003900000000392020200000202020
__sfx__
010b00000000031000086730a67308600076003f00038000340002d00028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000017050000000000035050270502b0500000000000320502a050220500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002c6502c6502c650000002c6502a6502965027650276502765000000000002665026650256502565024650256502965030650326503265032650326503165000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
