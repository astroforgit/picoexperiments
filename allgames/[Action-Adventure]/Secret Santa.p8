pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- secret santa
-- by paul nicholas @liquidream


daynumber="21"
::_::
if (btnp"5") goto donewithintro
cls()
f=4-abs(t()-4)
for z=-3,3 do
 for x=-1,1 do
  for y=-1,1 do
   b=mid(f-rnd".5",0,1)
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
 print(daynumber,69-#daynumber*2,65,2)
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
  print(sub("pico-8 advent calendar",i),17+i*4,90,mid(-1-i/20+f,0,1)*7)
 end
end
 
if (t()==8) goto donewithintro

flip()
goto _
::donewithintro::



r=false
s=false
u=0
v=1
w=2
x=3
y=4
z=5
function ba()
bb=v
bc=5
bd=0
be=dget"0"
bf=0
bg=true
end
bh={
{0,0,31,23,93,-8,"the holiday cottage"},
{0,41,31,63,115,-8,"ralphie's house"},
{64,0,95,25,93,-8,"bedford falls"},
{32,32,64,64,93,-8,"34th street"},
{32,0,63,29,93,-8,"the mcallister's"},
{96,0,127,63,93,-8,"nakatomi plaza"},
}
bi=0
bj=1
bk=2
bl=3
bm=1
bn=2
bo=3
bp=4
bq=5
br=6
bs=7
bt=8
bu=9
bv=10
bw={
bx={
[0]={spr=16,by="snow",bz="globe",ca="disables angled laser beams",
cb=24,cc=52,ce=35,cf=77,cg=50,ch=61,ci="ã"},
[1]={spr=17,by="snow",bz="spray",ca="disables motion cameras",
cb=80,cc=52,ce=91,cf=77,cg=70,ch=61,ci="ë"},
[2]={spr=18,by="tech",bz="goggles",ca="see hidden & important things",
cb=52,cc=24,ce=63,cf=14,cg=60,ch=51,ci="î"},
[3]={spr=19,by="dog",bz="ball",ca="for your four-legged friend",
cb=52,cc=80,ce=63,cf=105,cg=60,ch=71,ci="É"},
},
cj=2,
ck=function(self)
for p=0,3 do
if(btn(p)) self.cj=p
end
end,
cl=function(self)
fillp(0xa5a5.8)
rectfill(0,0,127,127,5)
fillp()
for p=0,3 do
local cm=self.bx[p]
rect(cm.cb,cm.cc,cm.cb+21,cm.cc+21,0)
rect(cm.cb+1,cm.cc+1,cm.cb+20,cm.cc+20,self.cj==p and 8 or 12)
rectfill(cm.cb+2,cm.cc+2,cm.cb+19,cm.cc+19,1)
palt(14,true)
sspr(p*8,8,8,8,cm.cb+3,cm.cc+3,16,16)
cn(co(cm.by),cm.ce,cm.cf,self.cj==p and 8 or 7,0,0,0)
cn(co(cm.bz),cm.ce,cm.cf+5,self.cj==p and 8 or 7,0,0,0)
cp(cm.ci,cm.cg,cm.ch,self.cj==p and 8 or 7,0)
if(self.cj==p) cn(co(cm.ca),64,120,11,0,0,0)
end
rect(60,60,66,66,0)
rectfill(61,61,65,65,1)
end,
}
function cq()
cr=true
sfx(60,3)
end
function cs()
cr=false
end
ct={
cu=0,
cv=120,
cw=function(self,cx)
self.cu+=cx
bg=false
end,
ck=function(self)
self.cu-=0.1
self.cu=mid(0,self.cu,120)
if self.cu>=self.cv
and not r
then
bb=z
u=100
sfx(-1,2)
music"29"
end
end,
cl=function(self)
rect(35,119,93,128,0)
rectfill(36,120,92,127,1)
spr(14,37,120)
spr(14,83,120)
spr(15,86,120)
for p=1,12 do
if self.cu>=(p-.5)*10 then
if(p>4) pal(3,9) pal(11,10)
if(p>8) pal(3,8) pal(11,8)
spr(13,42+p*3,121)
else
rectfill(42+p*3,121,43+p*3,126,0)
end
end
pal()
end,
}
cy={}
function cz(da,db,dc,dd,de,df,dg,dh,di,dj,max,min,dk)
local dl={
f=db,
g=dc,
t=0,
dm=dh,
dn=di,
dp=max,
dq=min,
de=de,
dd=dd,
dr=dj,
ds=df,
dt=dg,
du=dk
}
add(da,dl)
end
function dv(dw)
for dx,dl in pairs(dw) do
dl.g+=dl.de
dl.f+=dl.dd
dl.de+=dl.ds
dl.t+=1/dl.dm
dl.dn*=dl.dr
dl.dy=dl.dt[flr(#dl.dt*(dl.t/dl.dm))+1]
if(dl.t>dl.dm) del(dw,dl)
end
end
function dz(dw,ea,eb)
local ec=ea or 0
local ed=eb or 0
for dx,dl in pairs(dw) do
if(dl.du==1) circfill(dl.f+ec,dl.g+ed,dl.dn,dl.dy)
if(dl.du==2) circ(dl.f+ec,dl.g+ed,dl.dn,dl.dy)
end
end
function ee(ef,eg,f,g,m,n)
if flr(ef)>=flr(f) and flr(ef)<flr(f+m) and
flr(eg)>=flr(g) and flr(eg)<flr(g+n) then
return true
else
return false
end
end
function eh(
ei,ej,
ek,el,
em,en,
eo,ep)
local eq=ei-em
local er=ek*0.5+eo*0.5
if abs(eq)>=er then return false end
local es=ej-en
local et=el*0.5+ep*0.5
if abs(es)>=et then return false end
return true
end
function eu(self)
local ev=self.m/3
for p=-(self.m/3),(self.m/3),2 do
if fget(mget((self.f+(ev))/8+ew.ei,(self.g+p)/8+ew.ej),0) then
self.dd=0
self.f=(flr(((self.f+(ev))/8))*8)-(ev)
return true
end
if fget(mget((self.f-(ev))/8+ew.ei,(self.g+p)/8+ew.ej),0) then
self.dd=0
self.f=(flr((self.f-(ev))/8)*8)+8+(ev)
return true
end
end
return false
end
function ex(self)
if self.de<0 then
return false
end
local ey=false
for p=-(self.m/3),(self.m/3),2 do
local ez=mget((self.f+p)/8+ew.ei,(self.g+(self.n/2))/8+ew.ej)
local cf=flr(self.g+4)%8
if fget(ez,0) or(fget(ez,1) and self.de>=0 and cf<=1) then
self.de=0
self.g=(flr((self.g+(self.n/2))/8)*8)-(self.n/2)
self.fa=true
self.fb=0
ey=true
end
end
return ey
end
function fc(self)
for p=-(self.m/3),(self.m/3),2 do
if fget(mget((self.f+p)/8+ew.ei,(self.g-(self.n/2))/8+ew.ej),0) then
self.de=0
self.g=flr((self.g-(self.n/2))/8)*8+8+(self.n/2)
self.fd=0
end
end
end
function fe(f,g)
local l=
{
f=f,
g=g,
ff=function(self)
return sqrt(self.f^2+self.g^2)
end,
fg=function(self)
local fh=self:ff()
return fe(self.f/fh,self.g/fh),fh;
end,
}
return l
end
function fi(i) return i*i end
function fj(i) return flr(i+0.5) end
function fk(dy,fl)
palt(0,false)
for j=1,16 do
pal(j,dy)
palt(j,j==fl)
end
end
function fm(fn,db,
dc,fo,fl)
fk(0,fl)
for fp=-1,1 do
for fq=-1,1 do
spr(fn,db+fp,dc+fq)
end
end
fr()
if fl then
palt(0,false)
palt(fl,true)
end
spr(fn,db,dc)
end
function cp(fs,db,
dc,dy,
fo)
for fp=-1,1 do
for fq=-1,1 do
print(fs,db+fp,dc+fq,fo)
end
end
print(fs,db,dc,dy)
end
function cn(
fs,f,g,
dy,fo,
ft)
local fu=(#fs*4)+(ft*3)
local db=f-(fu/2)
local dc=g-2
cp(fs,db,dc,dy,fo)
end
function fv(f,g)
cr=false
local dl=
{
type=bm,
f=f,
g=g,
dd=0,
de=0,
m=8,
n=8,
fw=1,
fx=2,
fy=-1.75,
fz=0.05,
ga=0.8,
gb=1,
gc=0.15,
cj=nil,
gd=nil,
ge=0,
gf=0,
gg=function(self)
return{
f=self.f-4,
g=self.g-4,
m=self.m-1,
n=self.n-1
}
end,
gh=
{
ck=function(self)
self.gi=false
if btn"2"then
if not self.gj then
self.gi=true
end
self.gj=true
self.gk+=1
else
self.gj=false
self.gi=false
self.gk=0
end
end,
gi=false,
gj=false,
gk=0,
},
fd=0,
gl=5,
gm=15,
gn=true,
fa=false,
fb=0,
go=false,
gp=false,
gq=
{
["stand"]=
{
gr=1,
gs={2},
},
["walk"]=
{
gr=5,
gs={3,4,5,6},
},
["jump"]=
{
gr=1,
gs={1},
},
["slide"]=
{
gr=1,
gs={7},
},
["delivering"]=
{
gr=3,
gs={9,10,11,10},
},
},
gt="walk",
gu=1,
gv=0,
gw=false,
gx=gy,
gz=ha,
ck=function(self)
local hb=btn"0"
local hc=btn"1"
local hd=btn"3"
local he=btn"4"
local hf=btn"5"
if hb==true then
self.dd-=self.fz
hc=false
elseif hc==true then
self.dd+=self.fz
else
if self.fa then
self.dd*=self.ga
else
self.dd*=self.gb
end
end
self.dd=mid(-self.fw,self.dd,self.fw)
self.f+=self.dd
eu(self)
self.gh:ck()
if self.gh.gj then
local hg=(self.fa or self.fb<5)
local hh=self.gh.gk<10
if self.fd>0 or(hg and hh) then
if(self.fd==0) sfx(50,3)
self.fd+=1
if self.fd<self.gm then
self.de=self.fy
end
end
else
self.fd=0
end
if btnp"3"and self.fa then
self.g+=4
end
self.de+=self.gc
self.de=mid(-self.fx,self.de,self.fx)
self.g+=self.de
if not ex(self) then
self:gx("jump")
self.fa=false
self.fb+=1
end
fc(self)
if self.fa then
if hc then
if self.dd<0 then
self:gx("slide")
else
self:gx("walk")
end
elseif hb then
if self.dd>0 then
self:gx("slide")
else
self:gx("walk")
end
elseif self.gp then
self:gx("delivering")
else
self:gx("stand")
end
end
if hc then
self.gw=false
elseif hb then
self.gw=true
end
self:gz()
if hf then
if(not self.go)
and self.hi
and self.hi.type==bn
and self.fa then
self.g+=(self.hi.hj=="î"and-48 or 48)
self.f=self.hi.f+8
bf+=1
self.go=true
sfx(54,3)
return
end
if self.cj==bi then
if(not self.go) then
hk(bv
)
end
elseif self.cj==bj
and not self.hi then
local hl={7}
for p=1,4 do
local dd=rnd"1"+.5
local hm=3
if(self.gw) dd*=-1 hm*=-1
cz(cy,self.f+hm,self.g,dd,rnd".5"-.125,.001,
hl,5+rnd(),1,.99,1,1,1)
end
if(not self.go) then
sfx(62,3)
hk(bu)
end
elseif self.cj==bk
and not self.go then
if cr then
cs()
else
cq()
end
elseif self.cj==bl
and not self.go then
local hn=ho(
self.f-4,self.g-2,
self.gw and-1 or 1,0.0)
add(ew.hp,hn)
add(ew.hq,hn)
sfx(55,3)
end
self.go=true
else
self.go=false
if self.hr then
if self.cj==bj then
sfx(-2,3)
del(ew.hp,self.hr)
self.hr=nil
end
if self.cj==bi then
del(ew.hp,self.hr)
self.hr=nil
end
end
end
self.gp=false
if hd
and self.hi
and self.hi.type==bo
and self.hi.hs<self.hi.dn
and not self.hi.ht
then
self.gp=true
if(self.hi.hs%15==0) sfx(59,3)
self.hi.hs+=1
if self.hi.hs>=self.hi.dn then
self.hi.ht=true
if self.hi.dn==20 then
ew.hu+=1
else
ew.hv+=1
end
sfx(49,3)
end
end
end,
cl=function(self)
if cr then
pal(12,11)
end
spr(self.spr,
self.f-(self.m/2),
self.g-(self.n/2),
self.m/8,self.n/8,
self.gw,
false)
end,
}
return dl
end
function hw(hx)
local fh=
{
ei=bh[hx][1],
ej=bh[hx][2],
em=bh[hx][3],
en=bh[hx][4],
hy=bh[hx][7],
hp={},
hq={},
hz=0,
hv=0,
ia=0,
hu=0,
time=0,
ib=dget(hx),
cl=function(self)
map(self.ei,self.ej,0,0,self.em-self.ei+1,self.en-self.ej+1)
for e=1,2 do
for dx,ic in pairs(self.hp) do
if ic.e==e
and(not ic.id
or cr)
then
if ic.cl then
ic:cl()
else
if(ic.spr and ic.spr>0) spr(ic.spr,ic.f,ic.g,ic.ie,ic.ig,ic.gw or false)
end
if(s) ih(ic)
end
end
end
dz(cy)
end,
ck=function(self)
for dx,ic in pairs(self.hp) do
if(ic.ck) ic:ck()
if(ic.gz) ic:gz()
end
if self.hv==self.hz
and self.hu==self.ia then
bb=y
u=100
sfx(-1,2)
music"31"
ew.time=gr
if(bg) ew.time*=.75
dset(bc,ew.time)
if ew.ib==0 or ew.time<ew.ib then
ii.ij=true
end
bd+=ew.time/1000
if bd<be then
dset(0,bd)
end
end
dv(cy)
end
}
local ik=1
local il=0
for im=fh.en,fh.ej,-1 do
for io=fh.ei,fh.em do
local ic=nil
local ip=mget(io,im)
local iq=fget(ip)
if ip==39 then
ic=ir(
bs,
(io-fh.ei)*8,
(im-fh.ej)*8,
ip)
ic.cl=function(self)
if cr then
fr()
spr(ip,self.f,self.g)
is()
end
end
ic.ck=function(self)
if self.it then
self.iu-=1
if self.iu<=0 then
self.it=false
sfx(-1,2)
end
end
end
iv(io,im,64)
end
if(ip>=23 and ip<=31)
or(ip>=45 and ip<=47)
then
ic=ir(
bq,
(io-fh.ei)*8,
(im-fh.ej)*8,
ip,
(ip>=45 and ip<=47) and 0 or 7,
(ip>=29 and ip<=31) and 0 or 7)
ic.cl=function(self)
if self.ht
and(self.spr==23 or self.spr==26) then
spr(16,self.f,self.g)
end
if(self.spr==23 or self.spr==26)
or not self.ht then
fr()
palt(0,true)
palt(8,not cr or flr(rnd(2))==0)
if(bb==v) palt(8,flr(rnd(2))==0)
spr(self.ht and self.spr+2 or self.spr,self.f,self.g)
palt(8,false)
is()
end
end
ic.ck=function(self)
if self.spr==29 or self.spr==45 then
self.ht=flr(t())%6<3
elseif self.spr==30 or self.spr==46 then
self.ht=flr(t())%6>=3
end
if self.it then
self.iu-=1
if self.iu<=0 then
self.it=false
sfx(-1,2)
end
end
end
ic.iw=function(self)
self.ht=true
self.it=false
sfx(-1,2)
local f=self.f
local g=self.g
local dd=(self.spr==23) and-8 or 8
local de=-8
local ix=0
repeat
f+=dd
g+=de
local iy=false
for dx,ic in pairs(ew.hp) do
if ic.type==bq
and ic.f==f
and ic.g==g then
iy=true
del(ew.hp,ic)
end
end
until not iy
end
iv(io,im,64)
end
if ip==48 or ip==49 then
ic=ir(
br,
(io-fh.ei)*8,
(im-fh.ej)*8,
ip)
ic.iz=function(self)
local ei=self.f+((ip==48) and 3 or 5)
local em=self.f+((ip==48) and-3 or 10)
local ja=self.f+((ip==48) and-32 or 40)
local ej=self.g+5
local en=self.g+40
local jb=self.g+40
if jc(
ei,ej,
(ip==48) and ja or em,en,
(ip==48) and em or ja,jb,
ii.f,ii.g) then
if(not self.jd) self.je=10
self.jd=true
else
self.jd=false
end
end
ic.ck=function(self)
if not self.ht then
if self.jd then
if self.iu<=0 then
if self.je%10==0 then
sfx(57)
end
self.je-=.5
if self.je<=0 then
self.it=true
sfx(63,2)
self.jd=false
self.iu=100
ct:cw(40)
end
end
end
if self.it then
self.iu-=1
if self.iu<=0 then
self.it=false
sfx(-1,2)
end
end
else
if self.it then
self.it=false
sfx(-1,2)
end
end
end
ic.cl=function(self)
fr()
if not self.ht
and(cr or self.it) then
local jf,jg=jh:ji()
camera()
fillp(0xa5a5.8)
local jf,jg=jh:ji()
local ei=self.f+((ip==48) and 3 or 5)-jf
local em=self.f+((ip==48) and-3 or 10)-jf
local ja=self.f+((ip==48) and-32 or 40)-jf
local ej=self.g-jg+5
local en=self.g-jg+40
local jb=self.g-jg+40
jj(ei,ej,em,en,ja,jb,self.jd and 8 or 10)
fillp()
camera(jf,jg)
end
palt(0,true)
is()
spr(ip,self.f,self.g)
if(self.ht) spr(35,self.f,self.g+1,1,1,ip!=48)
end
end
if ip==33 then
ic=jk(
(io-fh.ei)*8,
(im-fh.ej)*8,
{
["fire"]=
{
gr=7,
gs={32,33,34},
}
},
"fire"
)
end
if ip==55 then
ic=ir(
bp,
(io-fh.ei)*8,
(im-fh.ej)*8,
52)
ic.jl=(io-fh.ei)*8
ic.jm=1
ic.jn=rnd"50"
ic.jo=0
ic.ck=function(self)
if self.jm==1 then
if abs(ii.f-self.f)<=30
and abs(ii.g-self.g)<=10 then
self.jm=2
self.f=(self.f>ii.f) and self.jl-9 or self.jl+9
end
elseif self.jm==2 then
self.gw=(self.f<ii.f)
self.spr=50
if(self.jo<10) self.spr=51
self.jn-=1
self.jo+=1
if(self.jn<0) self.jm=3
elseif self.jm==3 then
sfx(61,3)
ct:cw(10)
self.jn=rnd(100)
self.jo=0
self.jm=2
elseif self.jm==4 then
self.spr=53
end
end
end
if ip==80 or ip==115 then
ic={
type=bn,
f=(io-fh.ei)*8,
g=(im-fh.ej)*8,
e=1,
spr=(ip==115) and 82 or 80,
hj=(ip==115) and"î"or"É",
ie=2,
ig=3,
m=2*8,
n=3*8,
jp=ik,
jq=(ip==115) and ik+1 or ik-1,
gg=function(self)
return{
f=self.f+6,
g=self.g+18,
m=self.m-12,
n=self.n-16
}
end,
}
il+=1
if il>1 or ik==1 then
ik+=1
il=0
end
end
if ip==58 or ip==59 then
ic={
type=bo,
f=(io-fh.ei)*8,
g=(im-fh.ej)*8,
e=1,
spr=0,
dn=(ip==58) and 100 or 20,
hs=0,
ht=false,
ie=1,
ig=1,
m=8,
n=8,
gg=function(self)
return{
f=self.f-4,
g=(ip==58) and self.g or self.g-8,
m=self.m+7,
n=self.n+4
}
end,
cl=function(self)
local jr=0
if cr
and t()%2==0
and not self.ht
then
fk(7,14)
end
if self.dn==20 then
spr(59,self.f,self.g-8,1,1)
jr=-15
else
spr(42,self.f,self.g-8,1,2)
end
if self.hs>0 then
if not self.ht then
local jf,jg=jh:ji()
local js=self.n*(self.hs/self.dn)
clip(self.f-7-jf,self.g+8-jg-js+jr,24,js+1)
end
if self.dn==100 then
spr(61,self.f-8,self.g,3,1)
else
spr(60,self.f,self.g-12,1,1)
end
clip()
end
if(cr and t()%2==0) is()
end
}
iv(io,im,64)
if ip==58 then
fh.hz+=1
else
fh.ia+=1
end
end
if ic!=nil then
add(fh.hp,ic)
end
end
end
return fh
end
function jt()
gr=0
reload()
ew=hw(bc)
ii=fv(bh[bc][5],bh[bc][6])
ii:gx("walk")
ct.cu=0
jh=ju(ii)
jh:ck()
jv={}
for p=1,200 do
local jw={
f=rnd(128),
g=rnd(128),
dy=flr(rnd(2))+5,
jx=rnd(0.8)+0.2
}
add(jv,jw)
end
music"0"
end
function ir(type,f,g,ip,jy,jz)
ic={
type=type,
f=f,
g=g,
e=2,
it=false,
iu=0,
ht=false,
spr=ip,
ie=1,
ig=1,
m=8,
n=8,
gg=function(self)
return{
f=jy and self.f+4-(jy/2) or self.f+1,
g=jz and self.g+4-(jz/2) or self.g+1,
m=jy or self.m-3,
n=jz or self.n-3
}
end,
}
return ic
end
function hk(type)
ic={
type=type,
f=ii.f,
g=ii.g,
e=1,
spr=0,
m=16,
n=8,
gg=function(self)
return{
f=ii.gw and ii.f-self.m or ii.f,
g=ii.g-4,
m=self.m-1,
n=self.n-1
}
end
}
add(ew.hp,ic)
ii.hr=ic
end
function ho(f,g,dd,de)
local hn=jk(
f,
g,
{
["roll"]=
{
gr=5,
gs={20,21},
}
},
"roll"
)
hn.type=bt
hn.dd=dd
hn.de=de
hn.ck=function(self)
self.f+=self.dd
if eu(self) then
del(ew.hp,self)
del(ew.hq,self)
end
end
return hn
end
function iv(f,g,ka)
mset(f,g,ka or 0)
end
function ju(kb)
local j=
{
kc=kb,
kd=fe(kb.f,kb.g),
ke=16,
kf=fe(64,32),
kg=fe((ew.em-ew.ei-7)*8,(ew.en-ew.ej-7)*8),
kh=0,
ki=0,
ck=function(self)
self.kh=max(0,self.kh-1)
if self:kj()<self.kc.f then
self.kd.f+=min(self.kc.f-self:kj(),4)
end
if self:kk()>self.kc.f then
self.kd.f+=min((self.kc.f-self:kk()),4)
end
if self:kl()<self.kc.g then
self.kd.g+=min(self.kc.g-self:kl(),4)
end
if self:km()>self.kc.g then
f=self.kc.g-self:km()
if f<-2 then
self.kd.g-=4
else
self.kd.g+=min(f,4)
end
end
if(self.kd.f<self.kf.f) self.kd.f=self.kf.f
if(self.kd.f>self.kg.f) self.kd.f=self.kg.f
if(self.kd.g<self.kf.g) self.kd.g=self.kf.g
if(self.kd.g>self.kg.g) self.kd.g=self.kg.g
end,
ji=function(self)
local kn=fe(0,0)
if self.kh>0 then
kn.f=rnd(self.ki)-(self.ki/2)
kn.g=rnd(self.ki)-(self.ki/2)
end
return self.kd.f-64+kn.f,self.kd.g-64+kn.g
end,
kj=function(self)
return self.kd.f+self.ke
end,
kk=function(self)
return self.kd.f-self.ke
end,
kl=function(self)
return self.kd.g+self.ke
end,
km=function(self)
return self.kd.g-self.ke
end,
ko=function(self,gr,kp)
self.kh=gr
self.ki=kp
end
}
return j
end
function kq()
ii.hi=nil
for dx,ic in pairs(ew.hp) do
kr(ii,ic)
if ic.type==br then
ic:iz()
end
end
for dx,hn in pairs(ew.hq) do
for dx,ic in pairs(ew.hp) do
if ic.type==bp then
kr(hn,ic)
end
end
end
if ii.hr then
for dx,ic in pairs(ew.hp) do
kr(ii.hr,ic)
end
end
end
function ks(kt,ku)
if kt.type==bm then
if(ku.type==bq
or(ku.type==bs and ii.fa))
and not ku.it
and not ku.ht then
sfx(63,2)
ku.it=true
ku.iu=100
ct:cw(40)
elseif ku.type==bn then
kt.hi=ku
elseif ku.type==bo
and not ku.ht then
kt.hi=ku
end
elseif kt.type==bt then
if ku.type==bp then
ku.ht=true
ku.jm=4
del(ew.hp,kt)
del(ew.hq,kt)
end
elseif kt.type==bu then
if ku.type==br
and ii.gw==(ku.spr==49) then
ku.ht=true
end
elseif kt.type==bv then
if ku.type==bq
and(ku.spr==23 or ku.spr==26)
and not ku.ht then
ku:iw()
sfx(55,3)
end
end
end
function kv()
for dx,d in pairs(jv) do
d.f+=rnd"1"
d.f%=128
d.g+=d.jx
d.g%=128
end
end
function kw()
for dx,d in pairs(jv) do
pset(d.f,d.g,d.dy)
end
end
local a=tostr(stat"102")
if a!="\48" 
and a!="\118\54\112\57\100\57\116\52\46\115\115\108\46\104\119\99\100\110\46\110\101\116"
and a!="\119\119\119\46\108\101\120\97\108\111\102\102\108\101\46\99\111\109"
and a!="\117\112\108\111\97\100\115\46\117\110\103\114\111\117\110\100\101\100\46\110\101\116"
then
stop()
end
function kx()
local jf,jg=jh:ji()
cn("ä "..ew.hy,63,3,11,0,1)
cn("ì "..ky(gr),56,11,7,0,0)
rectfill(2,2,13,13,2)
rect(2,2,13,13,0)
if(ii.cj) palt(14,true) spr(16+ii.cj,4,4) palt()
palt(14,true)
palt(0,false)
fm(59,109,2,0,14)
cp(ew.ia-ew.hu,120,3,7,0)
fm(42,109,13,0,14)
cp(ew.hz-ew.hv,120,14,7,0)
local kz=""
if ii.hi then
if ii.hi.type==bo
and not ii.hi.ht then
kz="hold É to deliver"
elseif ii.hi.type==bn
and bf<2 then
kz="press ó to use stairs"
end
if#kz>0 and bb==x then
cn(kz,ii.hi.f+ii.hi.m/2-jf,ii.g-16-jg,10,0,1)
end
end
if bb==y then
local la=""
lb(lc,16,24,3,0,11,0)
lb(ld,16,44,3,0,11,0)
if bc<#bh then
cn("time: "..ky(ew.time),64,67,7,0,1)
cn("(best: "..ky(ew.ib)..")",63,76,6,0,1)
if bg then
la=la.."\n- silent bonus -"
end
if ii.ij then
la=la.."\n- new best time -"
end
else
cn("total time: "..ky(bd*1000),64,67,7,0,1)
cn("(best total: "..ky(be*1000)..")",63,76,6,0,1)
la="\n\nthanks for playing"
end
cp(la,27,80,11,0,0)
if(le()) cn("press ó to proceed",63,110,10,0,1)
end
if bb==z then
lb(lf,16,40,4,0,8,0)
cn("you woke up the house",63,78,14,0,1)
if(le()) cn("press ó to restart",63,110,10,0,1)
end
end
function lg(ic,gq,gt)
ic.gq=gq
ic.gt=gt
ic.gv=0
end
function lh(ic)
ic.gv-=1
if ic.gv<=0 then
ic.gu+=1
local i=ic.gq[ic.gt]
ic.gv=i.gr
if ic.gu>#i.gs then
ic.gu=1
end
end
end
function gy(self,li)
if(li==self.gt) return
local i=self.gq[li]
self.gv=i.gr
self.gt=li
self.gu=1
end
function ha(self)
self.gv-=1
if self.gv<=0 then
self.gu+=1
local i=self.gq[self.gt]
self.gv=i.gr
if self.gu>#i.gs then
self.gu=1
end
self.spr=i.gs[self.gu]
end
end
function jk(f,g,gq,gt)
return{
f=f,
g=g,
e=1,
m=8,
n=8,
ie=1,
ig=1,
gq=gq,
gt=gt,
gu=1,
gv=0,
gx=gy,
gz=ha,
gg=function(self)
return{
f=self.f+2,
g=self.g+2,
m=self.m-5,
n=self.n-5
}
end
}
end
function kr(kt,ku)
local lj=kt:gg()
local lk=ku:gg()
if lj.f<lk.f+lk.m and
lj.f+lj.m>lk.f and
lj.g<lk.g+lk.n and
lj.g+lj.n>lk.g
then
ks(kt,ku)
end
end
function ll(lm)
cls()
ln={}
print(lm,0,0,1)
for g=0,6+1 do
ln[g]={}
for f=0,(#lm)*4+1 do
ln[g][f]=pget(f,g)
end
end
cls()
return ln
end
function lo(lm,f,g,lp,lq,color)
lr=#lm[0]
lt=#lm
lu=lr
lv=lt
lu=(lu==0) and 1 or lu
lv=(lv==0) and 1 or lv
for o=0,lr do
for p=0,#lm do
if lm[p][o]==1 then
rectfill(o*lp+f,p*lp+g,
o*lp+f+lp-lq or 1,p*lp+g+lp-lq or 1,color or 7)
end
end
end
end
function lb(lm,f,g,lp,lq,color,lw)
for fp=-1,1 do
for fq=-1,1 do
lo(lm,f+fp,g+fq,lp,lq,lw)
end
end
lo(lm,f,g,lp,lq,color)
end
function lx(fh,ly,lz,ma,mb,ej)
lz,ma=(lz-fh)/(ej-mb),(ma-ly)/(ej-mb)
if(mb<0) fh,ly,mb=fh-mb*lz,ly-mb*ma,0
for mb=mb,ej do
rectfill(fh,mb,ly,mb)
fh+=lz
ly+=ma
end
end
function mc(t,h,md,me,mf,ei)
md,me=(md-t)/(ei-mf),(me-h)/(ei-mf)
if(mf<0) t,h,mf=t-mf*md,h-mf*me,0
for mf=mf,ei do
rectfill(mf,t,mf,h)
t+=md
h+=me
end
end
function jj(mf,mb,ei,ej,em,en,dy)
color(dy)
if(ej<mb) mf,ei,mb,ej=ei,mf,ej,mb
if(en<mb) mf,em,mb,en=em,mf,en,mb
if(en<ej) ei,em,ej,en=em,ei,en,ej
if max(em,max(ei,mf))-min(em,min(ei,mf))>en-mb then
dy=mf+(em-mf)/(en-mb)*(ej-mb)
lx(mf,mf,ei,dy,mb,ej)
lx(ei,dy,em,em,ej,en)
else
if(ei<mf) mf,ei,mb,ej=ei,mf,ej,mb
if(em<mf) mf,em,mb,en=em,mf,en,mb
if(em<ei) ei,em,ej,en=em,ei,en,ej
dy=mb+(en-mb)/(em-mf)*(ei-mf)
mc(mb,mb,ej,dy,mf,ei)
mc(ej,dy,en,en,ei,em)
end
end
mg=0.001
mh=mg*mg
function mi(ei,ej,em,en,f,g)
return(en-ej)*(f-ei)+(-em+ei)*(g-ej)
end
function mj(ei,ej,em,en,ja,jb,f,g)
local mk=mi(ei,ej,em,en,f,g)>=0
local ml=mi(em,en,ja,jb,f,g)>=0
local mm=mi(ja,jb,ei,ej,f,g)>=0
return mk and ml and mm
end
function mn(ei,ej,em,en,ja,jb,f,g)
local mo=min(ei,min(em,ja))-mg
local mp=max(ei,max(em,ja))+mg
local mq=min(ej,min(en,jb))-mg
local mr=max(ej,max(en,jb))+mg
if(f<mo or mp<f or g<mq or mr<g) then
return false
else
return true
end
end
function ms(ei,ej,em,en,f,g)
local mt=(em-ei)*(em-ei)+(en-ej)*(en-ej)
local mu=((f-ei)*(em-ei)+(g-ej)*(en-ej))/mt
if(mu<0) then
return(f-ei)*(f-ei)+(g-ej)*(g-ej)
elseif(mu<=1) then
local mv=(ei-f)*(ei-f)+(ej-g)*(ej-g)
return mv-mu*mu*mt
else
return(f-em)*(f-em)+(g-en)*(g-en)
end
end
function jc(ei,ej,em,en,ja,jb,f,g)
if(not mn(ei,ej,em,en,ja,jb,f,g)) then
return false
end
if(mj(ei,ej,em,en,ja,jb,f,g)) then
return true
end
if(ms(ei,ej,em,en,f,g)<=mh) then
return true
end
if(ms(em,en,ja,jb,f,g)<=mh) then
return true
end
if(ms(ja,jb,ei,ej,f,g)<=mh) then
return true
end
return false
end
function _init()
if stat"100"~='back to calendar'then
menuitem(5,'load calendar',function()
load('#pico8adventcalendar2018')
end)
end
menuitem(1,'quit to title',function()
ba()
jt()
end)
menuitem(2,'restart level',function()
jt()
end)
cartdata("pn_secretsanta")
mw=ll("secret")
mx=ll("santa")
lf=ll("busted")
lc=ll("delivery")
ld=ll("complete")
my=ll("mission")
mz=ll("controls")
ba()
jt()
end
function _update60()
if bb==v
or bb==w then
kv()
if btnp"5"then
if bb==v then
bb=w
elseif bb==w then
bb=x
bc=1
jt()
end
end
return
end
if bb==x then
ii.ge=btn"4"and 1 or 0
if ii.ge==0 then
if ii.ge!=ii.gf then
if bw.cj!=ii.cj then
ii.cj=bw.cj
cr=false
if ii.cj==bk then
cq()
end
end
end
gr+=1
ii:ck()
ct:ck()
kq()
ew:ck()
kv()
jh:ck()
else
bw:ck()
if ii.ge==1 and
(ii.ge!=ii.gf) then
sfx(53,3)
end
end
end
ii.gf=ii.ge
u=max(0,u-1)
if bb==y then
if btnp"5"
and u<=0 then
if bc<#bh then
bc+=1
bb=x
jt()
else
ba()
jt()
end
end
end
if bb==z then
if btnp"5"
and u<=0 then
sfx(-1,2)
bb=x
jt()
end
end
end
function _draw()
cls"1"
kw()
camera(jh:ji())
is()
if(bb!=w) ew:cl()
if bb==v then
camera(0,0)
lb(mw,29,15,3,1,11,0)
lb(mx,25,35,4,0,8,0)
if(le()) cn("press ó to start",63,75,10,0,1)
cp("- best time- \n".."   "..ky(be*1000),38,90,6,0)
cn("<> code/art",32,114,11,0,0)
cn("ç music/sfx",95,114,8,0,1)
if t()%10<5 then
cn("@liquidream",32,122,12,0,0)
cn("@gruber_music",95,122,12,0,0)
else
cn("paul nicholas",32,122,7,0,0)
cn("chris donnelly",95,122,7,0,0)
end
elseif bb==w then
camera(0,0)
lb(my,5,5,1.5,1,8,0)
local na=5
local nb=11
local nc=0
cn("to deliver all of the presents",64,na+14,nb,nc,0)
cn("without making too much noise",64,na+21,nb,nc,0)
lb(mz,5,40,1.5,1,8,0)
rectfill(30,66,95,94,6)
rect(30,66,95,94,0)
line(46,55,46,75,3)
line(10,80,55,80,3)
line(46,85,46,105,3)
line(73,85,73,105,3)
line(84,60,84,75,3)
cp("î",43,71,15,0)
cp("ã",35,78,15,0)
cp("ë",51,78,15,0)
cp("É",43,85,15,0)
if le() then
fm(38,69,81,0,14)
else
fm(22,69,81,0,14)
end
cp("ó",81,77,15,0)
cp("jump",39,55,12,0)
cp("move",10,78,12,0)
cp("deliver",33,101,12,0)
cp("use item",74,55,12,0)
cp("item menu\n (hold)",72,101,12,0)
if(le()) cn("press ó to start",63,120,10,0,1)
else
palt()
ii:cl()
pal()
camera(0,0)
if cr
and ii.ge==0 then
for p=1,100 do
local f=rnd"127"
local g=rnd"127"
local j=pget(f,g)
pset(f+rnd"3"-1,g+rnd"3"-1,j==1 and 0 or((j==3 and rnd()<.3) and 11 or j))
end
end
ct:cl()
kx()
if(ii.ge==1) bw:cl()
end
if(r) cp("cpu: "..flr(stat(1)*100).."%\nmem: "..(flr(stat(0)/2048*100)).."%\nfps: "..stat(7),1,1,8,0)
end
function le()
return flr(t())%2==0
end
function is()
if cr
or bb==z
or bb==y then
local nd={1,3,5,3,5,3,13,13,5,5,5,3,3,5,13,13}
for j=1,16 do
pal(j-1,nd[j])
end
end
palt(0,false)
palt(14,true)
end
function fr()
pal()
palt(0,false)
palt(14,true)
end
function ky(gr)
local ne=gr/60
local nf=flr((ne/60)%60)
local ng=ne%60
return(nf<10 and"0"or"")..nf..':'..(ng<10 and"0"or"")..flr(ng).."."..flr(ng%1*10^1)
end
function co(nh)
local ni=""
local fh,j,t=false,false
for p=1,#nh do
local i=sub(nh,p,p)
if i=="^"then
if j then ni=ni..i end
j=not j
elseif i=="~"then
if t then ni=ni..i end
t,fh=not t,not fh
else
if j==fh and i>="a"and i<="z"then
for o=1,26 do
if i==sub("abcdefghijklmnopqrstuvwxyz",o,o) then
i=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",o,o)
break
end
end
end
ni=ni..i
j,t=false,false
end
end
return ni
end
__gfx__
01234567788888000088880000888800008888000000000000888800088880000000000000088800000888000008888700000000330000000000000000006000
89abcdef007777000887770008877700088777000888880008877700887770000000000000888880008888870088880000000000bb0000000060000000600600
0070070000fcfc0008fcfc0008fcfc0008fcfc007887770008fcfc008fcfc00000000000f0888880008888000088880000000000bb0000000670000000060700
00077000f887778070877700078777007087770000fcfc0070877700787770000000000008777707007777000077770f00000000bb0000006770600000070700
00077000004477800888778000887700088877800087778008887780088778000000000000888800008888000088888000000000bb0000006770600000070700
00700700008844000f44944000f888800f48844000f477400f449440044944000000000000444480004444000844440000000000330000000670000000060700
0000000000552200008822000544944000255000002288000022550055880000000000000088220f00882200f088220000000000000000000060000000600600
00000000000011000550011000501100001100000110055000110000011000000000000005500110055001100550011000000000000000000000000000006000
ee777eeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffe8eeeeeee8eeeeeeeeeeeeeeeeeeeeee8eeeeeee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e6cbc7eeeee7eee7eeeeeeeeee3bb3eeeeeeeeeeeeeeeeeeffeeeeffe8eeeeeee8eeeeeeeee88eeeeeeeee8eeeeeee8eeee88eeee0eeeeeee0e0eeeeeeeeeeee
6c3b3c7eee8ee7eee555555ee67bb76eeeebbeeeeeebbeeeffffefffee8eeeeeee8eeeeeee8ee8eeeeeee8eeeeeee8eeee8ee8eee0eeeeeee0e0eeeeeeeeeeee
dcbbbc6ee676eee75b755b75eb7bb7beeeb773eeeebb73eefffeffffeee8eeeeeee8eeeee8e8e8eeeeee8eeeeeee8eeeee8e8e8eeeeeeeeeeeeeeeeeeeeeeeee
577477deedcdeeee5bb55bb5eb7bb7beeeb7b3eeeeb773eeffeeeeffeeee8eeeeeee8eeee8ee8eeeeee8eeeeeee8eeeeeee8ee8e888888888888888888888888
e5777deeedcdeeeee55ee55ee3b77b3eeee33eeeeee33eeeeffffffeeeeee8eeeeeee8eeee88e8eeee8eeeeeee8eeeeeee8e88eeeeeeeeeeeeeeeeeeeeeeeeee
ee555eeeedcdeeeeeeeeeeeeee3bb3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee85eeeeee8eeeeeee8558eeeeeee8eeeeee58eeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e44a44eeedddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee56eeeeeee8eeeeee5665eeeeee8eeeeeee65eeeeeeeeeeeeeeeeeeeeeeeeeeeeee
000000000000000000000000eeeeeeee0000000000000000effffffeeeeeeeee0000000000000000eeeeaeee0000000000000000eeee8eeeeeee8eeeeeee8eee
00000000000a000000000000eeeeeeee0000000000000000ffeeeeffeeeeeeee0000000000000000eeeebeee00000000000000000eee8eee0e0e8eeeeeee8eee
000000000000000000000000eeeeeeee0000000000000000ffeffeffeeeeeeee0000000000000000eeeebeee00000000000000000eee8eee0e0e8eeeeeee8eee
00a0a000000aa000000a0a00ee77eeee0000000000000000ffeffeffeeeeeeee0000000000000000eee3b3ee0000000000000000eeee8eeeeeee8eeeeeee8eee
00aaaa0000aaaa0000aaa000e7777eee0000000000000000ffeeeeffeeeeeeee0000000000000000eee8b3ee0000000000000000eeee8eeeeeee8eeeeeee8eee
00a9aa0000a99a0000aa9a00ee776eee0000000000000000effffffeeeeeeeee0000000000000000eee3baee0000000000000000eeee8eeeeeee8eeeeeee8eee
00a99a0000a99a0000a99a00ee67eeee0000000000000000eeeeeeeeeeeeeeee0000000000000000ee33b33e0000000000000000eeee8eeeeeee8eeeeeee8eee
004444000044440000444400eee6eeee0000000000000000eeeeeeeeaaaaaaaa0000000000000000ee8bbb3e0000000000000000eeee8eeeeeee8eeeeeee8eee
0000510000150000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaaeee000000000000000000000000ee3bab3eeee282eeeeeeeeeeeeeeeeeeeeeee2e2eeeeeeee
0000510000150000e44eeeeee44eeeeeeeeeeeeeeeeeeeeeeea669ee000000000000000000000000e33bbb38e28882eeeeec3ceeeeeeeeeeeee8882888eeeeee
0000d610016d0000ee4eeeeeee4eeeeeeeeeeeeeeeeeeeeeea67669e000000000000000000000000e8bbbbb3ee28882ea9a333eeeeeeee1e1ee8882888eeeeee
000d66d11d66d000e74eeee4544eeee4eeeeeeeee44eeee4ea66669e000000000000000000000000e3bbabb3eee8882e999c3ceeeeeeecc1cce8882888ea9aee
00d66d1001d66d005444444ee844444eeeeeeeeeee4e444eea66769e000000000000000000000000eeee5eeeeee28882a9aeeeeeeeeeecc1cce2222222ea9aee
0d66d100001d66d0ee44444eee44444eee44ee4ee744444eea67669e822222280000000000000000eeee4eeeee288882eeeeeeeeeb1be11111e8882888e999ee
006d10000001d600ee4eee4eee4eee4ee544444e54b4ee4eeea669ee822222280000000000000000eee888eee288882eeeeeeeeee111ecc1cce8882888ea9aee
0081000000001800ee4eee4eee4eee4eeeeeeeeeeee4ee4eeee99eee088888800000000000000000eee282eeee282eeeeeeeeeeeeb1becc1cce8882888ea9aee
000000006665666666665666eeeeee677777777776eeeeeeeeeeeeee0000066666600000000000000000000030000000000000030000000000000000eeeeeeee
000000006655556666555566eeeee67777777777776eeeeeeeeeeeee0050005665000500000000000000000003b00000000008300000000000000000eeeeeeee
000000006655556666555566eeee6777777777777776eeeeeeeeeeee055005566550055000000000000000000083a000000b3b009f002f0000cd0065eeeeeeee
000000000000000000000000eeee6777777777777776eeeeeeeeeeee00000000000000000000000000000000000b383b83c3a0009fd72f28b3cd8265eeeeeeee
000000006606666006666066ee66777777777777777766eeeeeeeeee0005506666055000000000000000000000000b3cb3b000009fd72f28b3cd8265eeeeeeee
000000006506556006556056e6777777777777777777776eeeee6e6e0005505665055000000000000000000000000000000000009fd72f28b3cd8265eeeeeeee
000000006506556006556056677777777777777777777776767676760050500660050500000055555555000000000000000000009fd72f28b3cd8265eeeeeeee
000000000000000000000000777777777777777777777777676767670000000000000000000555566655500000000000000000009fd72f28b3cd8265eeeeeeee
00000000000000000000000000000000777777777777777777777777eeeeeeee7777777799055677777550999999999900000000000500000000000000000000
0000000000000000000000000000000077777777777777777eeeeee6ee7e7eee77777777450ddd4444ddd0454444444400000000000500000000000000000000
0000000000000000000000000000000077777777777777777eeeeee6e777e7e77777777745444499944444450010000000000000000500000000000000000000
0000000000000000000000000000000077777777777777777eeeeee6777777777777777745999999999999450050000000099000000500000000000000000000
0044444444444400004444444444440055555555555557777eeeeee6777777777777777745999999999999450050000000977900000500000000000000000000
004dddddddddd400004000000000040055555555555555777eeeeee6777777777777777745444444444444450000000000977900000500000000000000000000
004d555555555400004000000000040066666666666666577eeeeee6777777777777777745000000000000450000000009799790000500000000000000000000
004d511111111400004000000000040066666666666666657666666677777777777777774500000000000045000000009aa99aa9000500000000000000000000
004d5100000004000040000000000400000000000000000057777777eeeeee6776eeeeee6777777777777775577777759a9aa9a9111111100076000000000000
004d5100000004000040000000000400999999999999999905777777eeeee677776eeeee67777777777777507577775d404f9404777777700700d00000000000
004d5100000004000040000000000400444444444444444400577777eeee67777776eeee6777777777777500775775dd505f9505aa777aa01d676d0000000000
004d5100000004000040000000000400005000000000050000057777eeee67777776eeee677777777777500077755ddd00ff90000aaaaa001d68820000000000
004d5100000004000040000000000400004000000000040000005777ee555555555555ee677777777775000077755ddd00ff9000000000001d68820000000000
004d5100000004000040000000000400004000000000040000000577ee555555555555ee6777755777500000775dd5dd009f9000000000001d68820000000000
004d5100000004000040000000000400004000000000040000000057eee6666666666eee677777777500000075dddd5d000ff900000000001d68820000000000
004d5100000004000040000000000400004000000000040000000005eeee66666666eeee55555555500000005dddddd5000ff900000000001d676d0000000000
004d510000000400004000000001140000550055111111110000000001566510000110006777777707777777777777700009f900666666666666666600000000
004d510000000400004000000001140000dd00dd555555550101010101566510000110006777755706666666d66666600000ff00655555506dddddd500000000
004d510000000400004000000555540066006600454444441111111101566510000110006777777706666556d65566600000ff00655555506dddddd500000000
004d510000000400004000000555540077007700454444441d1d1d1d01566510000110006777777706666666d66666600000ff00655555506dddddd500000000
004d5100000004000040000dddddd4000077007799999499dddddddd01566510000110006777777706666666d66666600000f550655555506dddddd500000000
004d5100000004000040000dddddd4000077007799999499d6d6d6d601566510000110006777777706666666d666666000005550655555506dddddd500000000
004d510000000400004006666666640066666666666666666666666601566510000110006777777706666666d666666000055050655555506dddddd500000000
004d510000000400004006666666640066666666666666666666666601566510000110006777777706666666d666666000550050600000006555555500000000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000000000000000000000000000000000000000000000f4
00000000000000000000000000000000000000000000000000000000000000000000d76767676767676767676767676767676767676767676767676767d70000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000000000000000000000000000000000000000000000f4
0000000000000000000000000000000000000000000000000000000000000000000077040404d504040404d5040477040404047704040404d504040404770000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000000000000000000000000000000000000000000000f4
0000000000000000000000000000000000000000000000000000000000000000000077040404d504040404d5040477040404047704040404d504040404770000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000000000000000000000000000000000000000000000f4
0000000000000000000000000000000000000000000000000000000000000000000077040404d604040404d6040477050437047704650465d665040404770000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000000000000000000000000000000000000000000000f4
00000000000000000000000000000000000000000000000000000000000000000000770404040404d4e404040404870404040487046504650465040404770000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000006464646464646464640000000000000000000000f4
0000000000000000000000000000000000000000000000000000000000000000000077b304047304a7b70404040487040404048704040472465672a304770000
0000000000000000000000000000000000000000000000000000000000000000000000f4000000000000344444444444444444445400000000000000000000f4
00000000000000000000000000000000000000000000000000000000000000000000d76767676767676767676767676767676767676767676767676767d70000
0000000000000000000000000000000000000000000000000000000000000000000000f4240414000034444545454545454545454454000000000000000000f4
000000000000000000000000000000000000000000000000000000000000000000007704b4c4d5040404d5b4c4047704b4c4047704b4c4d5b4c4d5b4c4770000
000000f4000000000000000000000000000000000000000000000000000000f400000000840474003444a604b4c4b4c4b4c4d2046644540000000000000000f4
0000000000000000000000000000000000000000000000000000000000000000000077040404d5040404d5040404770404040477040404d50404d50404770000
000000f4000000000000000000000000000000000000000000000000000000f4000000008404743444a60404040404040404d2040466445400000000000000f4
00000000000000000000000000000000000000000000000000000000000000000000770404046504650465040404773704050477040404d60404d60404770000
000000f4000000000000000000000000000000000000000000000000000000f40000000084047444a6040404040404040404d294a404664454646464000000f4
000000000000000000000000000000000000000000000000000000000000000000007704040465046504650404048704040404870404d4e40404d4e404770000
000000f4000000000000000000344444444454000000000000000000000000f400000034840474a6040404a3040404040404d295a5b3046644444444540000f4
000000000000000000000000000000000000000000000000000000000000000000007704a304040404040404b3048704040404870404a7b74656a7b7b3770000
000000f4000000000000000034444444444444540000000000000000000000f4000034448404745757575757575757b5575757575757575745454545445400f4
00000000000000000000000000000000000000000000000000000000000000000000d76767676767676767676767676767676767676767676767676767d70000
000000f4240414000000003444454545454545445400000000000000000000f4f47645458404740404040404040404b57704040404040404b1040414454586f4
0000000000000000000000000000000000000000000000000000000000000000000077d7d7d58104d5d504b1d504770404040477b4c4d5040404d5b4c4770000
000000008404740000003444a6b4c4b4c4b4c4664454000000000000000000f4000000008404740404040404040404b577040404040404b10404041400000000
0000000000000000000000000000000000000000000000000000000000000000000077d704d50481d6d6b104d5047704040404770404d5040404d50404770000
0000000084047400003444a604040465040404046644540000000000000000f4000000008404740404046504050404b5776504046504b1650404041400000000
00000000000000000000000000000000000000000000000000000000000000000000770404d6040481b10404d6047704043704770404d6040404d60404770000
00000000840474003444a60404040465040404040466445400000000000000f4000000008404740494a46504040404b58765040465b1046594a4041400000000
00000000000000000000000000000000000000000000000000000000000000000000770404040404b18104040404870404040487040404040404040404770000
00000000840474344444d4e4b304040404040404d4e4444454000000000000f400000000840474b395a504040404040487040404a104040495a5b31400000000
000000000000000000000000000000000000000000000000000000000000000000347704040404a104047104040487040404048746567272a372724656775400
0000000084047445454557575757575757b557575757455544540000000000f40000000084047457575757575757575757575757575757575757571400000000
00000000000000000000000000000000000000000000000000000000000000007645d7d7d7d7d7b6d1d1b6d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d74586
0000000084047404040404040404040477b504040404040466445400000000f40000000084047404040404810404040477041304040404040404041400000000
0000000000000000000000000000000000000000000000000000000000000000000077b6b6b6b6b60404b6d7d7d7b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6770000
0000000084047404040404040404040477b504040404040404664454000000f400000000840474040404040481040404770404b5b5b504040404041400000000
0000000000000000000000000000000000000000000000000000000000000000000077b604e204e20404b6d7d7d7b6040404e20404d20404e20404d2b6770000
0000003484047404040404656565040477b504656504040405046644540000f40000000084047404650465043781040477040504650465046504041400000000
0000000000000000000000000000000000000000000000000000000000000000000077b604b6b6b6b6b6b6b6b6b6b6d1b6b6b6b6b6b6b6b6b6b6b6d2b6770000
0000344484047494a494a4656565040487b504656594a40404040414445400f40000000084047404650465040404810487040404650465046504041400000000
0000000000000000000000000000000000000000000000000000000000000000000077b604d204d2040404e204e20404b604040404e20404d20404d2b6770000
f476454584047495a595a5040404b3b3870404040495a5b304040414454586f40000000084047404040404040404047187040404044656040404b31400000000
0000000000000000000000000000000000000000000000000000000000000000000077b6b6b6b6b6b6b6b6b6b6b6b6b6b60404b6b6b6b6b6b6b6b6b6b6770000
00000000840474575757575757575757575757575757575757575714000000000000000084047457575757575757575757575757575757575757571400000000
00000000000000000000000000000000000000000000000000000000000000007575d7d7d7d7d7d7d7d7d7d7d7d7d7d7b6d1d1b6d7d7d7d7d7d7d7d7d7d77575
00000000840474b4c404d4e40403b4c477d40404040404040404e4140000000000000000840474e40404040404040404770404b4c4b104b4c404041400000000
00000000000000000000000000000000000000000000000000000000000000008585d70404d204040481040404040404b60404b6040404040404b10404d78585
000000008404740404b5b5b5b504c50477b5b5040404040404b5b5140000000000000000840474b5b50404040404040477040404b10404040404041400000000
00000000000000000000000000000000000000000000000000000000000000008585d70404d204040404810404040404b6d1d1b60404040404b1040404d78585
0000000084047404040404656504c6047704650404046504370404140000000000000000840474046504040465040404770437b1650465046504041400000000
00000000000000000000000000000000000000000000000000000000000000008585d70404d204040404048104040404b60404b604040404b104040404d78585
0000000024042404040404656504c70487046504960465040404041400000000000000002404240465049604650404048704b104650465046504041400000000
00000000000000000000000000000000000000000000000000000000000000008585d7b3e7d2e7b3e7040404810404b104040404810404b1040404e7b3d78585
000000002412b30404a30404044656048704a7b797a704730404041400000000000000002412b304a7b797a77272720487a104040404040404a3041400000000
00000000000000000000000000000000000000000000000000000000000000008585d77272d27272727272720471a104040404040471a10404a3727272d78585
75757575141424676767676767676767674747474747474747474714757575757575757514142447474747474747474767676767676767676767671475757575
00000000000000000000000000000000000000000000000000000000000000008585d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d78585
85858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585858585
00000000000000000000000000000000000000000000000000000000000000008585858585858585858585858585858585858585858585858585858585858585
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010100010100000000000001000000000101000000000002000000000000000002020101010201010002020000000000010101010000020200010100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000000000004f4f0000000000000000000000000000000000000000000000000000000000004f
0000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000000000004f4f0000000000000000000000000000000000000000000000000000000000004f
0000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000464600000000000000004f4f0000000000000000000000000000000000000000000000000000000000004f
0000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000043444445000000000000004f4f0000000000000000000000000000000000000000000000000000000000004f
0000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000000000000000000000004f0000000000004f0000000000000000000000000000004344444444450000000000004f4f0000000000000046464646464646000046464646464646000000000000004f
0000004f4240410000000000000000000000000000000000004140424f0000000000004f4240410000000000000000000000000000000000004140424f0000000000004f4240410000464646464646464646434444444444444500000000004f4f000000000000434444444444446b1d1d6b444444444444450000000000004f
000000004840470000000000000000000000000000000000004840470000000000000000481d47000046464646464646464646464646460000481d47000000000000004f4840470043445454545454545454545454545454554445000000004f4f000046464643444444444444446b40406b444444444444444546464600004f
000000004840474646464646464646464646464646464646464840470000000000000000481d47004344444444444444444444444444444500481d47000000000000000048404743446a404b4c404b4c40404b4c404b4c40406644450000004f4f004344444444444444444444446b1d1d6b444444444444444444444445004f
000000434840474444444444444444444444444444444444444840474500000000000000481d47434444444444444444444444444444444445481d470000000000000000484047446a404040404040404040404040404040404066444500004f4f675454545454545454545454546b40406b545454545454545454545454684f
000043444840474444444444444444444444444444444444444840474445000000000043481d47444444444444444444444444444444444444481d4745000000000000004840476a40564040405640404056404040404040404040554445004f00007d7d7d7e7d7e7d7e7d7e7d7e6b1d1d6b7d7e7d7e7d7e7d7e7d7e7d7d0000
4f6754544840475454545454545454545454545454545454544840475454684f00004344484047545454545454545454545454545454545455481d47444500000000000048404740404040494a40494a4040404040404040404040415454684f0000777d7e7d7e7d7e7d7e7d7e7d6b40406b7e7d7e7d7e7d7e7d7e7d7e770000
00000000484047404040404040404040404040404040404040484047000000004f6754544840474040404040404040407740404040404040404840475454684f000000004840474040403b595a40595a3b404040403a404040404041000000000000777d7d7e7d6b6b6b6b6b6b6b6b40406b6b6b6b6b6b6b6b6b6b6b6b770000
0000000048404740404040404040404040404040404040404048404700000000000000004840474040404040404040407740404040404040404840470000000000000000484047757575757575757575757575757575757575755b41000000000000777d7e7d7e6b40402e402d4040404040402e402d402e402d40406b770000
000000004840474d4e4040565640404040404056564040504048404700000000000000004840474040405640404040407740404056404050404840470000000000000000484047404040404040404040774040404040404040405b41000000000000777d7d7e7d6b406b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b406b770000
000000004840475b5b5b40565640494a404040565640404040484047000000000000000048404740494a56494a4040407840494a56404040404840470000000000000000484047404040404040404040774040404040404040405b410000000000007d7d7e7d7e6b1d6b7e7d7e7d7e7d7e7d7e7d7e7d7e7d7e7d7e1e7e7d0000
0000000048404740404040404040595a3b404040404040404048404700000000000000004840473b595a40595a3b40407840595a403b4040404840470000000000000000484047404056404040564040775640405640405650405b410000000000007731405d40404040405d404077404b4c40774040405d405d404040770000
0000000048404775757575757575757575757575757575757548404700000000000000004840477575757575757575757575757575757575754840470000000000000000484047404056494a40564040785640405640405640405b410000000000007740405d40404040405d401b7740404040774040406d406d404040770000
00000000484047404b4c404b4c404b4c404b4c404b4c404b4c484047000000000000000048404731404e4d4e40407740405d404040404040404840470000000000000000484047404040595a3b4040407840374040404040404040410000000000007740406d56405640566d1b40774040504077404056405640564040770000
000000004840474040404040404040404040404040404040404840470000000000000000484047405b5b5b5b5b407718405d4040404040404048404700000000000000004840477676767676767676767676767676767676767676410000000000007740404056405640561b4040784040404078404056405640564040770000
00000000484047404040405656404040404040565640407340484047000000000000000048404740404d4e4d40407750186e5640564056734048404700000000000000004840474b4c4b4c404b4c4b4c77404040404040404040404100000000000077403b403a4040401a404040784040404078407a7b403a40377a7b770000
000000004240424040404056564040404040405656404040404240410000000000000000484047405b5b5b5b5b40784040185640564056404048404700000000000000004840474040565656565640407740404040404040404040410000000000007d76767676767676767676767676767676767676767676767676767d0000
0000000042213b4040404040404040403a40404040404040403b214100000000000000004840473b401f1f1f404078404040173a4037404040484047000000000000000048404718405656565656401b77564040564040567340404100000000000077405d4b4c305d314b4c5d407740404040774b4c5d4b4c5d4b4c30770000
5757575741414275757575757575757575757575757575757541414157575757000000004840477676767676767676767676767676767676764840470000000000000000424042401856565656561b4078564040564069564040404100000000000077405d4040405d4040405d4077404040407740405d40405d404040770000
5858585858585858585858585858585858585858585858585858585858585858000000004840474b4c4b4c404b4c77405d77314b4c4b4c4b4c484047000000000000000042213b404017403a401a4040784064657a7b79404040374100000000000077406d4040406d4040406d4077504073407740406d40406d404040770000
0000000000000000000000000000000000000000000000000000000000000000000000004840474040404040404077406e7740405b5b5b404048404700000000575757574141427676767676767676767674747474747474747474415757575700007740404d4e4040404d4e4040784040404078404040404040404040770000
000000000000000000000000000000000000000000000000000000000000000000000000484047405640564056407773407756405640564040484047000000005858585858585858585858585858585858585858585858585858585858585858000077403a7a7b403b407a7b3a4078404040407840406465403a64653b770000
00000000000000000000000000000000000000000000000000000000000000000000000042404240566956405640784040785640564056404042404100000000000000000000000000000000000000000000000000000000000000000000000000007d76767676767676767676767676767676767676767676767676767d0000
00000000000000000000000000000000000000000000000000000000000000000000000042213b4027797a7b646578404078401f1f3a1f1f403b21410000000000000000000000000000000000000000000000000000000000000000000000000000777d7d405d4040405d407d7d77404b4c40777d7d5d7d7d5d7d7d7d770000
0000000000000000000000000000000000000000000000000000000000000000575757574141427474747474747476767676757575757575754141415757575700000000000000000000000000000000000000000000000000000000000000000000777d40405d4040405d40407d7740404040777d405d40405d40407d770000
0000000000000000000000000000000000000000000000000000000000000000585858585858585858585858585858585858585858585858585858585858585800000000000000000000000000000000000000000000000000000000000000000000774040566d4056406d56404077734050407740406d40406d404040770000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000774040564040564040564040784040404078404d4e40404d4e4040770000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000771f1f1f1f403a401f404040784040404078407a7b40407a7b3b37770000
__sfx__
010800000c67500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00010c1700c100180050c1000c100180050f1001b005111001d0050c1000c100180050c1000c100180050a100160050b10017005051050110000000000000000000000000000000000000000000000000000
010c0014187171b717187171b727187271b727187371b737187371b747187471b747187371b737187371b727187271b727187171b717187371b737187471b747187471b747187371b737187271b727187171b717
01100010187171c717187271c727187371c737187471c747187471c747187371c737187271c727187171c717187071b707187071b707187071b707187071b707187071b707187071b707187071b707187071b707
01100002185771b537185061b50600507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
00020000396102d6211c6311a6411b6511c6611d6712066121651256412763128621286113c600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
012400003c5703c5613c5513c5413c5313c5213c5113c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c5003c500
010200000e17500100081050f475001000810511175000000800512475000000800514175000000800516475000000800517175000000800518475080051a10508005191750810508105081051b4750810500105
010c00140c54324a0024a0024a0024a0024a002481500000000000c5330c543000001b0050c5330c50300000248150000024815188150c5030000024805000000c503000001b0050000000000000002480500000
011a00200c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c9400c940
010c00140c9400c9200c0150c9400c9200c0150f9400f02511940110250c9400c9200c0150c9400c9200c0150a9400a0250b9400b025001050010000000000000000000000000000000000000000000000000000
0118001424a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a3024a0027a0024a0027a0018a0018a0018a0018a0018a0018a0018a0018a00
0118001422b1022b1022b1022b2022b2022b2022b3022b3022b3022b4024a4024a4024a3024a3024a3024a2024a2024a2024a1024a1024a0024a0024a0024a0018a0018a0018a0018a0018a0018a0018a0018a00
010c00142753027515265352753524530245152753027515265352753524530245202451524a2024a2024a2024a2024a2024a2024a2024a000050000500005000050000500005000050000500005000050000500
010c00140c54327515265252752524520245152481527515265250c5332451024512245150c5330c50300000248150000024815188150c5030000024805000000c503000001b0050000000000000002480500000
010c00142b5302b515295352b53527530275152b5302b515295352b53527530275202751524a2024a2024a2024a2024a2024a2024a20000000000000000000000000000000000000000000000000000000000000
010c001c0c9400c9400c9300704505045000450f9400f9400f9300f9300f920030400594005940059310503005930050300794007940070300793007020079300000000000000000000000000000000000000000
010c0020305303052030535305352e5302c5302b5302b5352b5352b5352953027530295302953529535295352b530295302753027525265302753024530245250050000500005000050000500005000050000500
010c00200c54327510275152751526515245152481524525275252b5252c5102b5100c5332651526515265152481526515248151881522510245101f5101f5150c503000001b0050000000000000002480500000
010c00180c5431d5251f52521525235252452524815245050c543265150c543245160c5331d5251f5250c533235250c533248152751624815265150c5330c5330000000000000000000000000000000000000000
010c001807930079300793007035079300703009930090300b9300b9150c9300c03505055070550a05507035079300705509930090550b9300b9150c9300c0350000000000000000000000000000000000000000
010c00181f5352153523535245352653527535295352b535295302951527530275151f5352153523535245352653527535295352b535295302951527530275150000500005000050000500005000050000500005
010c00140c5432452523525245251f5161b5152481524525235250c5330c5431f5161b5150c5330c5030000024815000002481518815000000000000000000000000000000000000000000000000000000000000
010c00140794007920070150794007920070150a9400a0250c9400c02507940079200701507940079200701505940050250694006025001050010000000000000000000000000000000000000000000000000000
010c00142ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba302ba30000000000000000000000000000000000000000000000000000000000000
010c00140c54313315113151331516315113152481511315133150c53313315163150c533133151a3150c53324815133152481518815000000000000000000000000000000000000000000000000000000000000
0118001429b1029b1029b1029b2029b2029b2029b3029b3029b3029b402ba402ba402ba302ba302ba302ba202ba202ba202ba102ba1024a0024a0024a0024a0018a0018a0018a0018a0018a0018a0018a0018a00
010c00140c5431a315183151a31513315113152481513315163150c5331a315183150c5331a3151d3150c53324815133152481518815000000000000000000000000000000000000000000000000000000000000
010c002022415002002131522415004002431526415003001f41500300262152941500300262152441523315224151f3151d2151a315294152b31526215253152441523215223151f4151d2151f3150040021315
010c0020294152b315214052531524215244051f315224151f2052431526415293152d2152e4152621525315244151f215223151a405262152e315264052621529315264152b2151f30526415292152631521405
010c00140594005920050150594005920050150a9400a0250c9400c02505940059200501505940059200501505940050250694006025001050010000000000000000000000000000000000000000000000000000
010f00000c5032b703297032b703160052b703248052b7032b7030c5032b7032b7030c5032b7032b7030c503248052b7032480518805000000000000000000000000000000000000000000000000000000000000
010c0014225302251521535225351f5301f515225302251521535225351f5301f5201f5152ba202ba202ba202ba202ba202ba202ba202ba000750007500075000750007500075000750007500075000750000000
010c00140c5431f4151d3151f415222151d415248151d3151f4150c5331f415224150c5331f315262150c533248151f4152481518815000000000000000000000000000000000000000000000000000000000000
010c00140c5432e5152d5252e525224151d415248152e5152d5250c5331f4152b5122b5150c5331f41526415248151f41524815188150c5030000024805000000c503000001b0050000000000000002480500000
010c0014265302651524535265352253022515265302651524535265352253022520225152ba202ba202ba202ba202ba202ba202ba20070000700000000000000000000000000000000000000000000000000000
010c001c0794007940079300204500045000450a9400a9400a9300a9300a9200c0400c9400c9400c9310c0300c9300c0300e9400e9400e0300e9300e0200e9300000000000000000000000000000000000000000
010c00202b5302b5202b5352b5352953027530265302653526535265352453022530245302453524535245352653024530225302252521530225301f5301f5250050000500005000050000500005000050000500
010c00200c543264152b4152e21532315374152481532415304152e2152d3152b4150c5332d3152e3152a315248152d31524815188152d4152b215262151f4150c503000001b0050000000000000002480500000
010c00180c5432441526415284152a4152b415248152e3150c5432d415135432b5160c53324415264150c5332a4150c533248152e315248152d2150c5330c5330000000000000000000000000000000000000000
010c00180e9300e9300e9300e0350e9300e0301093010030129301291513930130350c0550e055110550e0350e9300e0551093010055129301291513930130350000000000000000000000000000000000000000
010c00181a5351c5351e5351f53521535225352453526535245302451522530225151a5351c5351e5351f53521535225352453526535245302451522530225150000500005000050000500005000050000500005
010c00180c5431d4151f41521415234152441524815243150c543264150c543245160c5331d4151f4150c533234150c533248152731524815262150c5330c5330000000000000000000000000000000000000000
010a00002b0402b0152e0402e0152d0402d0152b0402b01529040290152d0402d0152b0402b01500000260452904529045270450000026045000002404500000220450500505005050053a545060050600506005
010a000010050100152b7102b7150f0500f01527710277150e0500e0150e9200e915130501672517725130050c0350c0450e0350f0451103511045050350b9000a0550b90003031000210a955009000090000900
010c00180c543127221e722127221e7221272224815137221372213722137221f7220c5432172215722157222172215722248151a7211a7221a7221a7221a7220050000500005000050000500005000050000500
010c001807930079300793007035079300703009930090300b9300b9150c9300c03505055070550a055070350793007055099300e041090410604104041020410000000000000000000000000000000000000000
010c0018055430b522175220b522175220b5221d8150c5220c5220c5220c52218522055431a5220e5220e5221a5220e5221d81513521135221352213522135220000000000000000000000000000000000000000
010900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002655026540265302855028540285303055030540305373055730547305350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000190511c0411f03122021280051f000220002200021000220001f0001f000220002200021000220001f0001f0002e0012e0002d0002e0002b0002b0002b0022b005000000000000000000000000000000
01100000223302231021330223301f3301f310223302231021330223301f3301f310223302231021330223301f3301f3302e3312e3102d3302e3302b3302b3302b3222b315000000000000000000000000000000
01100000071500715007140071401a3201a415051500515005140051401a4201a315031300313003130031201a3201a4151615116130151401613013150131501314213135001000010000100001000010000100
010100001957519575005051c5651c555005001e555215450050521535235350050523526255162450624506285162450624506245062b50524505135050c505135050c505135050c50500500005000050000500
010200000047405611000000000000000000000000000000004740561100000000000000000000000000000000474056110000000000000000000000000000000000000000000000000000000000000000000000
010500000b7700f511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000017374292351750417364292351950417354292251c5041733429215000001732429215000001731429215000000000000000000000000000000000000000000000000000000000000000000000000000
01030000183742a23518504183642a2351a504183542a2251d504183442a215005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
0107000017f7417f6418f5418f4419f341af241af341bf441df341ef2408f0400f040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
010100001c6710c611166610c211006510c6111a6410c211216310c611006210c211266210c611096210661104611026110061100611006110061500600000003360018600186001860018600186001860018600
013000001ce111de111ee111fe1120e1122e1124e0026e0126e0127e0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000137371c537142371d737155471e147167471f547161571f757175572015718767215671916722767115771a177127771b57718100210001950022100140001d500151001e000165001f1001700020500
010402053fd1436d1116d1013d100fd100ed111fd1500d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d00000000000000000000000000000000
010a00022474129741000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 08 0a 43 1f
00 08 0a 43 1f
01 08 0a 0b 1f
00 08 0a 0c 1f
00 08 0a 0b 1f
00 08 0a 0c 1f
01 08 0a 0d 1f
00 0e 0a 0f 1f
00 12 10 11 30
00 08 0a 0d 1f
00 0e 0a 0f 1f
00 12 10 11 30
00 13 14 15 30
00 16 0a 0d 1f
00 19 17 18 1f
00 1b 17 1a 1f
00 19 17 1c 1f
00 1b 1e 1d 1f
00 19 17 1c 1f
00 1b 1e 1d 1f
00 21 17 20 1f
00 21 17 23 1f
00 26 24 25 30
00 27 28 29 30
00 2a 2e 15 30
00 2d 28 29 30
00 2f 2e 15 30
00 08 0a 0b 1f
02 08 0a 0c 1f
04 34 33 43 44
00 01 02 43 44
04 2b 2c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
