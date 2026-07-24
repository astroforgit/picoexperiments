pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- f l o w e r h e a d 
-- by charlie tran 
-- this code is minified 
-- see original source here: 
-- github.com/charlietran/flowerhead
a={
b={},
c={d=1},
e={},
f={g=0},
h={},
}
cartdata("pootify_flowerhead")
function _init()
i=dget(0)
j=dget(1)
k=false
l=a.b
printh("------\n")
m=.05
n=.88
o=.3
p=.2
q=0
r=0
s=0
t={}
u={}
v={w}
a.b:x()
y:x()
z:x()
ba:x()
w:x()
end
function _update60()
bb()
if not bc then
l:bd()
end
end
function bb()
for be,bf in pairs(t) do
if costatus(bf)!='dead'then
local bg,bh=bi(bf)
else
del(t,bf)
end
end
end
function _draw()
l:bj()
for be,bk in pairs(u) do
bk()
end
end
function a.c:bd()
q+=.016666667
z:bd()
for be,bl in pairs(v) do
bl:bd()
end
bm:bd()
bn:bd()
end
function a.c:bj()
cls()
y:bj()
z:bj()
ba:bj()
bo:bj()
for be,bl in pairs(v) do
bl:bj()
end
bm:bj()
bn:bj()
bp:bj()
z:bq()
end
y={
br=.1,
bs=40,
}
y.bt={}
function bu()
w:x()
z.bv=1
bw.bx=bw.by
if not bw.bz then
bw.bz=true
bp:add(bw)
end
ca={}
bo.map={}
bo.cb={}
for be,cc in pairs(bw.cd) do
mset(cc[1],cc[2],cc[3])
end
ce.count=0
sfx(-1,3)
for cf,cg in pairs(bw.ch) do
bw.ch[cf]=1
end
bw.ci=0
bw.cj=0
bw.ck=true
v={w}
if bw.cl then
cm:cn({
co=bw.cl,
cp=bw.cq
})
end
cr(bo.map)
cr(bm.bt)
cr(bn.bt)
cr(u)
for be,cs in pairs(bw.ct) do
cu:cn({
co=cs[1],cp=cs[2],cv=0,cw=0
})
end
end
function y:x()
for cx=1,45 do
srand(cx)
local cy=cx/3
self.bt[cx]={
co=cy+rnd(128-cy),
cp=cy+rnd(128-cy),
cy=cy
}
end
srand(bnot(time()))
end
function y:bj()
camera(0,0)
local cz=time()
fillp(0b0110111110111111)
for be,da in pairs(self.bt) do
local db,dc
dc=da.cp-
(z.cp*da.cy*.01)%
192
local dd=.1*z.co+cz
local de=da.co-
(dd*
da.cy*
y.br)
local df=128+
y.bs+
2*da.cy
db=de%df-da.cy
circfill(db,dc,da.cy,1)
end
fillp()
end
dg={
dh=nil,di=nil,dj=nil,dk=nil,
cf=nil,
dl=false,
dm=0,
cd={},
ck=true,
dn=""
}
function dg.cn(dp)
local dq=setmetatable(
dp or{},
{__index=dg}
)
dq:dr()
return dq
end
function dg:dr()
local dh,di=self.dh,self.di
self.ds=dh*8
self.dt=di*8
self.du=0
self.cj=0
self.ci=0
self.dv={}
self.ct={}
for dj=dh,127 do
if mget(dj,di)==9 then
self.dj=dj
self.dw=dj*8+8
break
end
end
for dk=di,63 do
if mget(dh,dk)==7 then
self.dk=dk
self.dx=dk*8+8
break
end
end
for dy=di,self.dk do
for dz=dh,self.dj do
if ea(dz,dy) then
self.du+=1
end
if mget(dz,dy)==64 then
self.eb=dz*8+3
self.ec=dy*8
mset(dz,dy,0)
end
local ed=mget(dz,dy)
local ee=ef(ed) or
eg(ed)
if ee then
self.dv[dy]=self.dv[dy] or{}
self.dv[dy][dz]=true
end
if eh(ed) then
self.cl=dz*8+3
self.cq=dy*8+2
mset(dz,dy,0)
end
if ed==35 or ed==36 then
self.ei=dz
self.ej=dy
self.ek=dz*8
self.el=dy*8
self.by=ed==36
end
if ed==18 then
add(
self.ct,
{dz*8+3,dy*8+3}
)
mset(dz,dy,0)
end
end
end
self.ch={}
for cx=1,self.dm do
local em=flr(
cx/(self.dm+1)*
self.du
)
self.ch[em]=1
end
end
function dg:en()
self.bx=true
sfx(0,0)
add(
u,
self:eo())
end
function dg:eo()
local co,cp=self.ei*8+5,
self.ej*8+2
local ep=0
return function()
if ep>240 then return end
ep+=1
local cc=time()
local eq=16
local er,es=w.co-co,w.cp-cp
local et=sqrt(
(er/1000)^2+(es/1000)^2
)*1000
if ep>120 then
et*=1-(ep-120)/120
end
local eu=.5+atan2(er,es)
for cx=1,eq do
local ev=cc/eq+cx/eq
local ew=ev-eu
local ex=-.7*cos(ew)*(1-.2*cos(cc/4))
fillp(0b0011100111000110.1)
line(
co,cp,
co+ex*et*cos(ev),
cp+ex*et*sin(ev),
10)
fillp()
end
end
end
ba={bt={}}
function ba:x()
reload(0x2000,0x2000,0x1000)
ba.bt={
ey(1,0,0,0,"hive entrance"),
ey(2,16,0,0,"outer defenses"),
ey(3,32,0,0,"inner garden"),
ey(4,48,0,0,"viaduct"),
ey(5,64,0,0,"over the top"),
ey(6,78,0,0,"winding passage"),
ey(7,94,0,1,"guard post"),
ey(8,16,16,0,"unsteady grounds"),
ey(9,0,16,3,"barracks"),
ey(10,32,16,0,"catacombs"),
ey(11,48,16,6,"trench run"),
ey(12,61,32,1,"hidden tunnel"),
ey(13,78,16,2,"twisted tower"),
ey(14,96,32,6,"the throne room"),
ey(15,0,32,2,"escape the hive")
}
ba.bt[3].ez={
"press —",
"flower the floor",
"unlock the door"
}
ba.bt[7].ez={
"",
"beware the bee",
"defeat it with three"
}
ba.cf=1
ba.fa=0
bw=ba.bt[1]
end
function ey(cx,co,cp,fb,fc)
return dg.cn({
cf=cx,
dh=co,
di=cp,
dm=fb,
dn=fc
})
end
function ba:bj()
if bw.bx then
self.fa=(self.fa+.0625)%5
mset(bw.ei,bw.ej,37+self.fa)
else
self.fa=(self.fa+.0625)%5
mset(bw.ei,bw.ej,32+self.fa)
end
if bw.fd then
map(bw.ei,bw.ej,bw.ek,bw.el,1,1)
else
map(
bw.dh,bw.di,
bw.ds,bw.dt,
bw.dj-bw.dh+1,
bw.dk-bw.di+1)
end
if not bw.bx then
local fe=""..(bw.du-bw.cj)
print(fe,bw.ek+(8-#fe*4)/2,bw.el-6,10)
end
end
function ba:ff()
self.cf+=1
i=self.cf
dset(0,mid(dget(0),i,15))
bw=self.bt[self.cf]
sfx(-1,3)
if bw then
l=a.c
cr(u)
music(0,0,1)
bu()
else
l=a.f
music(13)
end
end
bp={bt={}}
function bp:add(dq)
local fg={
fh="level "..dq.cf,
fi=dq.dn,
fj=32,
co=0
}
fg.cp=-fg.fj
add(self.bt,fg)
local fk={
fl=45,
fm={co=0,cp=64-(fg.fj/2)}
}
local fn=fo({
fp(fg,fk),
fq(60),
function() del(self.bt,fg) end
})
add(t,fn)
end
function bp:bj()
local cz=time()
for be,fb in pairs(self.bt) do
local co=z.co-64
local cp=z.cp-64+fb.cp
local fr=73
local fs=(128-fr)/2
rectfill(
co+fs+2,cp+2,
co+fs+fr+2,cp+fb.fj+2,
2
)
rectfill(
co+fs,cp,
co+fs+fr,cp+fb.fj,
1
)
print(
fb.fh,
co+fs+(fr-#fb.fh*4)/2,
cp+fb.fj/4,
10)
print(
fb.fi,
co+fs+(fr-#fb.fi*4)/2,
cp+fb.fj*3/4,
7)
end
end
function a.e:ft()
l=a.e
bw.fd=true
music(10,0,15)
fu(
1,
120,
function()
ba:ff()
end
)
end
function a.e:bd() end
function a.e:bj()
cls()
y:bj()
z:bj()
ba:bj()
for be,bl in pairs(v) do bl:bj() end
end
function fu(color,fv,fw,fx)
local fy={
co=z.co-64,cp=z.cp-64-127,
fz=127,ga=127,color=color,
gb={
fm={
co=z.co-64,
cp=w.cp-15-127
},
fl=30,
fv=fv-30
},
}
fy.gb.bj=function()
gc(fy)
end
local gd={
co=z.co-64,cp=z.cp+64,
fz=127,ga=127,color=color,
gb={
fm={
co=z.co-64,
cp=w.cp+15
},
fl=30,
fv=fv-30
},
}
gd.gb.bj=function()
gc(gd)
end
ge(fy,fy.gb)
ge(gd,gd.gb)
if fx then
local gf={co=gd.co,cp=gd.cp}
ge(
gf,
{
fm={
co=gf.co,
cp=gd.gb.fm.cp+6
},
fl=30,
fv=fv-30,
bj=function()
for cx,line in pairs(fx) do
print(
line,
gf.co+(64-#line*2),
gf.cp+8*(cx-1),
7)
end
end
}
)
end
add(
t,
fo({
fq(fv),
fw
})
)
end
function gg(co,cp,gh)
for cx=1,64 do
gi(
co,cp,
cos(cx/64),
sin(cx/64),
1,
gh,
22
)
end
end
gj={
co=0,cp=0,cv=0,cw=0,
fz=0,ga=0,gk=0,gl=0,
gm=1,
fk={gn=0,go=0,br=1},
gp=0,gq=0,
gr=false,
gs=false,
gt=false,
gu=true,
gv=false,
gw=true,
}
function gj:cn(fm)
local gx=setmetatable(
fm or{},
{__index=gj}
)
return gy(v,gx)
end
function gj:gz(ha)
end
function gj:hb()
self.gs=true
del(v,self)
end
function gj:hc()
local hd=abs(self.cv)
local he,hf
for cx=hd,0,-1 do
he=min(cx,1)*sgn(self.cv)
hf=self.gu and
hg(self,'x',he)
if hf then
self:gz(hf)
break
else
if not self.hh then
self:hi()
end
self.co+=he
end
end
if self.gw then
self.cw+=m
end
local hj=abs(self.cw)
for cx=hj,0,-1 do
he=min(cx,1)*sgn(self.cw)
hf=self.gu and
hg(self,'y',he)
if hf then
self:gz(hf)
break
else
if not self.hh then
self:hi()
end
self.cp+=he
end
end
end
function gj:hi()
for be,gx in pairs(v) do
if gx~=self then
if hk(self,gx) then
self:hl(gx)
end
end
end
end
function gj:bj()
self:hm()
end
function gj:hm()
if self.gs then return end
self.fk.gn=
(self.fk.gn+
self.fk.br)%
self.fk.go
sspr(
self.gp+flr(self.fk.gn)*self.fz,
self.gq,
self.fz,
self.ga,
self.co-self.gk*self.gm,
self.cp-self.gl*self.gm,
self.fz*self.gm,
self.ga*self.gm,
self.gr
)
end
cm={
hn="flowerheart",
fz=7,ga=7,
gk=3,gl=3,
gp=56,gq=40,
fk={gn=0,go=7,br=.142857143}
}
setmetatable(cm,{__index=gj})
function cm:cn(ho)
return setmetatable(
gj:cn(ho or{}),
{__index=cm}
)
end
function cm:bd()
self:hi()
end
hp={}
function cm:hl(gx)
if not gx.hh then return end
if bw.ez
and not hp[bw.cf]
then
hp[bw.cf]=1
music(11,0,15)
bc=true
fu(
3,
260,
function()
bc=false
self:hq()
music(0,0,1)
sfx(7)
end,
bw.ez
)
else
self:hq()
sfx(7)
end
end
function cm:hq()
self:hb()
bw.ck=false
gg(self.co,self.cp,3)
end
w={}
setmetatable(w,{__index=gj})
function w:x()
for hr,cg in pairs(hs) do w[hr]=cg end
self.co=bw.eb
self.cp=bw.ec
end
hs={
hn="player",
gm=1,
hh=1,
cv=0,
cw=0,
ht=0,
hu=0,
hv=0,
hw=0,
gk=1,
gl=2,
fz=3,
ga=5,
hx=false,
hy=1.5,
hz=false,
ia=false,
ib=false,
ic=1,
id=false,
ie=false,
ig=7,
ih=0,
ii=0,
ij=0,
ik=0,
il=8,
im=9,
gs=false,
gt=false,
io=0,
spr=64,
gu=true,
}
function w:bj()
if self.gs then return end
self.ij=
self.ij%3+1
if self.ik>0 then
local ip=-4
if self.gr then
ip=-2
end
sspr(
32,32,7,6,
self.co+ip,
self.cp-5,
7,6,
self.gr)
self.ik-=1
end
if self.hz then
if self.ih>0 then
self.spr=67
else
self.spr=64+self.ii%3
end
elseif self.ia then
self.spr=96+flr(self.ii%4)
else
if self.cw<0 then
self.spr=80
else
self.spr=81
end
end
spr(
self.spr,
self.co-self.gk,
self.cp-self.gl,
.375,
.625,
self.gr)
end
function w:bd()
if self.gs then
w.io-=1
if self.io<=0 then bu() end
return false
end
self.hz=self.ig<7
if not self.ib then
self:iq()
end
self.cv*=.98
self.ig+=1
self:hc()
self:ir()
self:is()
self:it()
self.dz,self.dy=flr(self.co/8),flr(self.cp/8)
end
function w:gz(ha)
if ha.iu=='x'then
self.cv=0
elseif ha.iu=='y'then
self.cw=0
if self.cw>1 then
self.iv=self.cw
end
if ha.et>0 then
self.ig=0
self.hz=true
if iw(ha.ed) then
ix(ha.dz,ha.dy)
end
end
end
end
function w:ir()
self.ia=false
if hg(self,'y',1,true) then return end
if hg(self,'x',1,true) then
self.ia=true
self.ic=-1
self.gr=false
if self.cw>0 then self.cw*=.97 end
elseif hg(self,'x',-1,true) then
self.ia=true
self.ic=1
self.gr=true
if self.cw>0 then self.cw*=.97 end
else
self.ic=self.gr and-1 or 1
end
end
function w:iq()
if self.hz then
self:iy()
else
self:iz()
end
self:ja()
if not bw.ck then
self:jb()
end
end
function w:ja()
local jc=btn(4)
if jc and not self.jd then
self.im=0
end
self.im+=1
self.jd=jc
end
function w:jb()
local je=btn(5)
if not je then
self.ie=false
end
if not self.ie and je then
local jf=-1.5
local jg=self.ic*
rnd(.4)+
self.cv*1.2
sfx(11)
self.ie=true
self.ik=7
s+=1
cu:cn({
co=self.co,
cp=self.cp-1,
cw=jf,
cv=jg
})
end
end
function w:is()
if self.im>self.il then return end
if self.hz then
self.im=self.il
self.cw=min(self.cw,-self.hy)
sfx(9)
elseif self.ia then
self.im=self.il
self.cw-=self.hy
self.cw=mid(self.cw,-self.hy/3,-self.hy)
self.cv=self.ic
self.co+=self.ic
self.gr=(self.ic==-1)
sfx(10)
end
end
function w:iy()
if btn(0) then
self.gr=true
self.ic=-1
if self.cv>0 then self.cv*=.9 end
self.cv-=.05
elseif btn(1) then
self.gr=false
self.ic=1
if self.cv<0 then self.cv*=.9 end
self.cv+=.05
else
self.cv*=n
end
end
function w:iz()
if btn(0) then
self.cv-=.0375
elseif btn(1) then
self.cv+=.0375
end
end
function w:it()
if self.hz then
self:jh()
self:ji()
elseif self.ia then
self:jj()
end
self:jk()
end
function w:jh()
if abs(self.cv)<.03 then
self.ii=0
else
local jl=self.ii
self.ii+=abs(self.cv)*o
if abs(self.cv)>1 and flr(jl)!=flr(self.ii) then
gi(
self.co,
self.cp+2,
-self.cv/3,
-abs(self.cv)/6,
.5
)
end
end
if self.ih>0 then
self.ih-=.4
end
end
function w:ji()
if not self.iv then return end
if self.iv>2 then
sfx(15)
else
sfx(14)
end
self.ih=self.iv
for jm=0,self.iv*2 do
gi(
self.co,
self.cp+2,
self.iv/3*(rnd(2)-1),
-self.iv/2*rnd(),
.3)
end
self.iv=nil
end
function w:jj()
local jl=self.ii
self.ii-=self.cw*p
if flr(jl)!=flr(self.ii) then
gi(
self.co-self.ic,
self.cp+1,
self.ic*abs(self.cw)/4,
0,
.2)
end
end
function w:jk()
if self.hw%19==0 then
local jn,jo,jp
jp=self.hv and-1 or 1
gi(
self.ht,
self.hu-self.gl,
-jp*.3,
-.1,
0,
10,
21
)
self.ht=self.co
self.hu=self.cp
self.hv=self.gr
end
self.hw+=1
if self.hw>20 then
self.hw=1
end
end
function w:jq()
if self.gs then return end
r+=1
self.gs=true
self.io=30
for cx=1,100 do
gi(
self.co,self.cp+2,
sgn(self.cv)*(-.5+rnd(2))*rnd(4),
-7.5*rnd(),
1,
7,
22
)
sfx(42)
end
z:jr(30,2)
end
function js(gx,iu,jt)
local ju,jv,jw,jx
if iu=='x'then
ju=gx.co+jt*gx.gk
jw=gx.cp-gx.gl
jv=ju
jx=gx.cp+gx.gl
elseif iu=='y'then
ju=gx.co-gx.gk
jw=gx.cp+jt*gx.gl
jx=jw
jv=gx.co+gx.gk
end
return ju,jw,jv,jx
end
function hg(gx,iu,et,jy)
jz=false
ka=nil
ju,jw,jv,jx=js(gx,iu,sgn(et))
if iu=='x'then
ju+=et
jv+=et
else
jw+=et
jx+=et
end
local dh,di,dj,dk=
flr(ju/8),
flr(jw/8),
flr(jv/8),
flr(jx/8)
local kb=mget(dh,di)
local kc=mget(dj,dk)
if gx.hh and
not bw.fd and
(kd(kb) or
kd(kc))
and ju%8>1
and ju%8<6
and jw%8>1
then
a.e:ft()
return
end
if not jy and
(ke(kb,ju,jw) or
ke(kc,jv,jx))
then
gx:jq()
return
end
local hf={
iu=iu,
et=et
}
if ef(kb) then
hf.ed,hf.dz,hf.dy=kb,dh,di
elseif ef(kc) then
hf.ed,hf.dz,hf.dy=kc,dj,dk
end
if hf.ed then
return hf
else
return false
end
end
ca={}
function ix(dz,dy)
local cf=tostr(dz).."."..tostr(dy)
if ca[cf] then return end
mset(dz,dy,14)
ca[cf]=true
add(t,cocreate(function()
local gn=30
while gn>0 do
gn-=1
if gn==12 then mset(dz,dy,15) end
yield()
end
mset(dz,dy,0)
gn=120
while gn>0 do
if w.dz==dz and w.dy==dy then yield() end
gn-=1
if gn==12 then mset(dz,dy,15) end
if gn==6 then mset(dz,dy,14) end
yield()
end
mset(dz,dy,13)
ca[cf]=false
end))
end
kf={
{1,4,7,8},
{4,1,8,7},
{0,1,4,7},
{1,0,7,4},
{1,1,7,8},
{1,1,8,7},
{0,1,7,7},
{1,0,7,7}
}
function ke(ed,co,cp)
if not eg(ed) then
return
end
local kg,kh,ki=
co%8,
cp%8,
kf[ed-47]
return kg>ki[1] and
kh>ki[2] and
kg<ki[3] and
kh<ki[4]
end
function hk(kj,kk)
return
kk.co+kk.gk*kk.gm>
kj.co-kj.gk*kj.gm and
kk.cp+kk.gl*kk.gm>
kj.cp-kj.gl*kj.gm and
kk.co-kk.gk*kk.gm<
kj.co+kj.gk*kj.gm and
kk.cp-kk.gl*kk.gm<
kj.cp+kj.gl*kj.gm
end
function ef(ed)
return fget(ed,0)
end
function eg(ed)
return fget(ed,4)
end
function kl(ed)
return fget(ed,3)
end
function kd(ed)
return fget(ed,2)
end
function eh(ed)
return fget(ed,5)
end
function iw(ed)
return fget(ed,6)
end
function ea(dz,dy)
local ed=mget(dz,dy)
local km=mget(dz,dy-1)
return fget(ed,1) and
not ef(km) and
not eg(km) and
not kl(km)
end
function gi(co,cp,cv,cw,kn,color,fl)
local ko={
co=co,
cp=cp,
kp=co,
kq=cp,
cv=2*(cv+rnd(kn*2)-kn),
cw=2*(cw+rnd(kn*2)-kn),
gh=color or 5,
kr=1
}
local ks=fl or 15
ko.fl=ks+rnd(ks)
ko.kr=1
add(bm.bt,ko)
end
bm={bt={}}
function bm:bd()
for be,ko in pairs(self.bt) do
ko.kp=ko.co
ko.kq=ko.cp
ko.co+=ko.cv
ko.cp+=ko.cw
ko.cv*=.85
ko.cw*=.85
ko.kr-=1/ko.fl
if ko.kr<0 then
del(self.bt,ko)
end
if l.d and ef(mget(ko.co/8,ko.cp/8)) then
del(self.bt,ko)
end
end
end
function bm:bj()
for be,ko in pairs(self.bt) do
line(
ko.co,ko.cp,
ko.kp,ko.kq,
ko.gh+(ko.kr/2)*3)
end
end
bo={
map={},
cb={},
fk={gn=0,go=4,br=.066666667}
}
function bo:bj()
self.fk.gn=(self.fk.gn+self.fk.br)%self.fk.go
local gp,gq
for kt,bo in pairs(self.map) do
for ku,kv in pairs(bo) do
gp=3*flr(self.fk.gn)
gq=8+2*kv
sspr(
gp,gq,
3,2,
ku-1,kt)
end
end
end
function bo.kw(co,cp)
local co,dz=flr(co),flr(co/8)
local cp,dy=flr(cp),flr(cp/8)
bo.map[cp]=bo.map[cp] or{}
if bo.map[cp][co] or
not ea(dz,dy+1)
then return end
bo.map[cp][co]=flr(rnd(4))
bo.kx(dz,dy+1)
end
function bo.kx(dz,dy)
bo.cb[dy]=bo.cb[dy] or{}
bo.cb[dy][dz]=bo.cb[dy][dz] or 0
if bo.cb[dy][dz]==8 then
return
end
bo.cb[dy][dz]+=1
if bo.cb[dy][dz]<4 then
return
end
bo.cb[dy][dz]=8
bw.cj+=1
ky=mget(dz,dy)
mset(dz,dy,ky+9)
add(bw.cd,{dz,dy,ky})
if bw.ch[bw.cj]
then
ce:kz(dz,dy)
bw.ch[bw.cj]=false
end
if not bw.bx and
not bw.fd and
bw.cj>=bw.du
then bw:en() end
end
cu={
hn="bomb",
la=true,
fz=3,ga=3,
gk=1,gl=1,
cw=-2.5,
gp=16,gq=8,
fk={gn=0,go=8,br=.166666667}
}
setmetatable(
cu,
{__index=gj}
)
function cu:cn(ho)
return setmetatable(gj:cn(ho or{}),{__index=cu})
end
function cu:bd()
self:hc()
end
function cu:gz(ha)
if ha.iu=='x'then
self.cv=-self.cv/4
elseif ha.iu=='y'then
if self.cw>0 then
if not ea(ha.dz,ha.dy) then
self:lb()
else
self:lc()
end
else
self.cw=0
end
end
end
function cu:hl(gx)
end
function cu:jq()
self:lb()
end
function cu:lb()
bn.add(self.co,self.cp+2,2)
sfx(43)
self:hb()
end
function cu:lc()
for cx=self.co+5,self.co-5,-1 do
bo.kw(cx,self.cp)
end
bn.add(self.co,self.cp,4)
ld(self.co,self.cp)
sfx(40)
sfx(41)
z:jr(6,1)
self:hb()
end
le={
"woo",
"haa",
"hoo",
"hee",
"hii",
"yaa"
}
function ld(co,cp)
local ld={
co=co,
cp=cp,
gf=le[1+flr(rnd(6))],
ku=3+8*flr(rnd(2)),
}
ge(ld,{
fm={co=co,cp=cp-10},
fl=60,
bj=function()
print(
ld.gf,
ld.co+cos(time()),
ld.cp,
ld.ku
)
end
})
end
bn={}
bn.bt={}
function bn.bd()
for be,bl in pairs(bn.bt) do
if#bl.lf==0 then
del(bn.bt,bl)
end
for be,cs in pairs(bl.lf) do
cs.co+=cs.cv/cs.lg
cs.cp+=cs.cw/cs.lg
cs.lh-=.2
if cs.lh<.5 then
del(bl.lf,cs)
end
end
end
end
function bn.bj()
for be,bl in pairs(bn.bt) do
for be,cs in pairs(bl.lf) do
local color=13
if cs.lh>2.5 then
color=11
elseif cs.lh>2 then
color=3
end
circfill(cs.co,cs.cp,cs.lh,color)
end
end
end
function bn.add(co,cp,li,color)
local bl={}
bl.co=co
bl.cp=cp
bl.lf={}
for cx=1,50 do
local lj={}
lj.lg=.5+rnd(2)
lj.lh=.25+rnd(li)
lj.cv=(-1+rnd(2))*.5
lj.cw=(-1+rnd(2))*.5
lj.co=bl.co+lj.cv
lj.cp=bl.cp+lj.cw
add(bl.lf,lj)
end
add(bn.bt,bl)
end
function a.b:x()
self.lk=0
self.lh=2
self.fh="flowerhead"
self.ll="by charlie tran"
self.lm="press — to start"
self.ln="press    for level select"
self.g=0
self.lo=8
music(63)
end
function a.b:bd()
if btnp(5) then
l=a.c
bu()
music(0,0,1)
end
if btnp(1) then
l=a.h
end
bm:bd()
if self.g%2==0 then
gi(
32+rnd(96),
32+rnd(96),
-5,
-5,
.1,
5)
end
end
function a.b:bj()
cls()
y:bj()
bm:bj()
self.g+=.25
if self.g>self.lo then
self.g=1
end
for cx=1,#self.fh do
cp=sin(cx/16+time()/8)*4
print(
sub(self.fh,cx,cx),
66-#self.fh*4+((cx-1)*8),
50+cp,
3)
if cx==5 then lp=50+cp-5 end
end
spr(64,58,lp)
if self.g%3==0 then
gi(
57,
lp,
-.7,
-.2,
0,
10,
21
)
end
print(
self.ll,
64-#self.ll*2,
70,
13)
print(
self.lm,
64-#self.lm*2,
88,
7)
print(
self.ln,
64-#self.ln*2,
96,
7)
spr(60,64-#self.ln*2+24,95)
end
lq=1
function a.h:bd()
if btnp(0) then
lq=max(1,lq-1)
elseif btnp(1) then
lq=min(#ba.bt,lq+1)
elseif btnp(5) then
k=ba.cf>1
ba.cf-=1
ba:ff()
end
ba.cf=lq
bw=ba.bt[ba.cf]
end
function a.h:bj()
cls()
camera(0,0)
y:bj()
map(
bw.dh,bw.di,
0,
112-8*(bw.dk-bw.di),
bw.dj-bw.dh+1,
bw.dk-bw.di+1)
rectfill(0,0,127,8,2)
lr(
"level "..bw.cf..": "..bw.dn,
2,7)
rectfill(0,117,127,127,1)
print(
"      : select     —: start",
4,120,7)
spr(60,9,119,1,1,true)
spr(60,19,119)
end
function lr(gf,cp,ku)
print(gf,64-#gf*2,cp,ku)
end
z={}
function z:x()
self.co=0
self.cp=0
self.lt=0
self.lu=0
self.lv=24
self.lw=24
self.bv=0
end
function z:bd()
self.lt=max(0,self.lt-1)
if(self.co+self.lv)<w.co then
self.co+=min(w.co-(self.co+self.lv),4)
end
if(self.co-self.lv)>w.co then
self.co-=min((self.co-self.lv)-w.co,4)
end
if(self.cp+self.lw)<w.cp then
self.cp+=min(w.cp-(self.cp+self.lw),4)
end
if(self.cp-self.lw)>w.cp then
self.cp-=min((self.cp-self.lw)-w.cp,4)
end
self.co=mid(self.co,bw.ds+64,bw.dw-64)
self.cp=mid(self.cp,bw.dt+64,bw.dx-64)
end
function z:lx()
local jr={co=0,cp=0}
if self.lt>0 then
jr.co=rnd(self.lu)-self.lu/2
jr.cp=rnd(self.lu)-self.lu/2
end
return self.co-64+jr.co,self.cp-64+jr.cp
end
function z:jr(ly,lz)
self.lt=ly
self.lu=lz
end
function z:bj()
camera(z:lx())
end
function z:bq()
if self.bv>0 then
for cx=0,15 do
pal(cx,cx*(1-self.bv),1)
end
self.bv-=.1
else
pal()
end
end
ma={
hn="bee",
fk={gn=0,go=3,br=.25},
gp=64,gq=8,
mb=true,
gw=false,
mc=.05,
md=.1,
fz=7,ga=7,gk=3,gl=3,
gr=false,
me=0,
mf=15,
mg=.5,
mh=.5,
mi={}
}
setmetatable(ma,{__index=gj})
function ma:jq()
self.cw=-self.cw
end
function ma:cn(ho)
local mj=ho or{}
mj.mk=ml:cn(mj)
return setmetatable(mj,{__index=ma})
end
function ma:kn()
local mm=sin(time())*.15
self.cw=mid(self.cw+mm,-self.mh,self.mh)
end
function ma:bd()
self.me+=1
if self.me==self.mf then
self.me=0
self.mk:bd(w)
end
self:mn()
self:mo()
self:kn()
self:hc()
end
function ma:bj()
gj.bj(self)
end
function ma:mn()
if self.mk.mp then
self.mq,self.mr=self.mk:ms()
end
end
function ma:mo()
if not self.mq then return end
if self.mq<self.co then
self.cv=max(self.cv-self.mc,-self.mg*1/self.gm)
else
self.cv=min(self.cv+self.mc,self.mg*1/self.gm)
end
self.gr=self.cv<0
if self.mr<self.cp then
self.cw=max(self.cw-self.md,-self.mh*1/self.gm)
else
self.cw=min(self.cw+self.md,self.mh*1/self.gm)
end
end
function ma:hl(gx)
if self.mt then return end
if gx.hh then
w:jq()
elseif gx.la then
gx:lb()
self.gm+=.4
if self.gm>=2 then
self:hb()
end
end
end
function ma:hb()
gg(self.co,self.cp,9)
gj.hb(self)
sfx(42)
ce.count-=1
if ce.count==0 then sfx(-1,3) end
end
ce={
count=0,
}
function ce:kz(dz,dy)
local mu=sgn(-1+rnd(2))
local mj=ma:cn({
gr=-mu,
co=dz*8+ma.gk+mu*32,
cp=dy*8-32,
gm=8,
mt=true,
mq=dz*8+ma.gk+1,
mr=dy*8-8+ma.gl
})
mj.mk.mp=false
add(t,fo({
ce:mv(dz*8+4,dy*8-1,(-1+rnd(2))*.5,-1,60),
function()
gy(v,mj)
ce.count=ce.count+1
end,
function() sfx(16,3) end,
fp(mj,{fm={co=dz*8+mj.gk+1,cp=dy*8-8+mj.gl,gm=1},fv=60,fl=60}),
function()
mj.mk.mp=true
mj.mt=false
end
},true))
end
function ce:mv(co,cp,cv,cw,fl)
return function()
for cx=1,fl do
if w.gs then return end
gi(co,cp,cv,cw,.25,10)
yield()
end
end
end
function a.f:bd()
if btnp(4) then _init() end
bm:bd()
self.g+=1
if self.g%2==0 then
gi(
32+rnd(96),
32+rnd(96),
-3,
-3,
.1,
10)
end
end
function a.f:bj()
cls()
camera(0,0)
bm:bj()
mw=k and
"    Œ you skipped levels Œ"
or""
fx={
"      good job, flowerhead",
"  you planted every dang flower",
"",
"      game time: "..(k and"Œ"or(flr(q)).." seconds"),
"    flowerbombs: "..s.." thrown",
"         deaths: "..r,
mw,
"     press jump to restart"
}
for cx,line in pairs(fx) do
local co=0
local cp=16+cx*8
print(line,co,cp,7)
end
end
ml={
mp=true,
mx=20
}
function ml:cn(my)
return setmetatable({my=my,mi={}},{__index=ml})
end
function ml:bd(mz)
if not self.mp then return end
if mz.gs then return end
self.na=nb(mz.co+mz.gk,mz.cp+mz.gl)
self.nc=nd(self.na)
local ne=nb(self.my.co,self.my.cp)
local nf=nd(ne)
self.ng={{nh=ne,cf=nf}}
self.ni={}
self.ni[nf]=ne
self.nj={}
self.nj[nf]=0
self.nk={}
self.nl=nm(ne,self.na)
local nn=self:no()
if not nn then return end
self.mi={nn,self.na}
local np=nd(nn)
while np!=nf do
gy(self.mi,nn)
nn=self.ni[np].nh
np=self.ni[np].cf
end
end
function ml:no()
local nq=0
while#self.ng>0 do
local nr=ns(self.ng)
if nr.cf==self.nc then
return nr.nh
end
local nt=self.nu(nr.nh)
self:nv(nt,nr,nq)
nq+=1
end
end
function ml.nu(nh)
local nw={}
local co,cp=nh[1],nh[2]
local nx={
{co-1,cp-1},
{co,cp-1},
{co+1,cp-1},
{co-1,cp},
{co+1,cp},
{co-1,cp+1},
{co,cp+1},
{co+1,cp+1}
}
for be,ny in pairs(nx) do
local nz=ny[1]>bw.dh and ny[1]<bw.dj and
ny[2]>bw.di and ny[2]<bw.dk and
not bw.dv[ny[2]][ny[1]]
if nz then add(nw,ny) end
end
if(nh[1]+nh[2])%2==0 then
oa(nw)
end
return nw
end
function ml:nv(nt,nr,nq)
for ob in all(nt) do
local oc=nd(ob)
local od=self.nj[nr.cf]+1
local oe=1
if(not self.nj[oc]) or(od<self.nj[oc]) then
add(self.nk,{ob,od})
self.nj[oc]=od
of(self.ng,{
nh=ob,
cf=oc,
og=od+oe*nm(ob,self.na)
})
self.ni[oc]=nr
end
end
end
function ml:ms()
local oh=self.mi[1]
if not oh then return end
if self.my.dz==oh[1] and
self.my.dy==oh[2]
then
del(self.mi,oh)
oh=self.mi[1]
if not oh then
return
end
end
return oh[1]*8+4,oh[2]*8+4
end
function cr(oi)
for dp in all(oi) do
del(oi,dp)
end
end
function nm(ft,oj)
local ok=abs(ft[1]-oj[1])+abs(ft[2]-oj[2])
local gh=max(abs(ft[1]-oj[1]),abs(ft[2]-oj[2]))
return(ok+gh)/2
end
function nb(co,cp)
return{
flr(co/8),
flr(cp/8)
}
end
function ns(oi)
local ol=oi[#oi]
del(oi,oi[#oi])
return ol
end
function gc(om)
rectfill(
om.co,om.cp,
om.co+om.fz,om.cp+om.ga,
om.color)
end
function oa(oi)
for cx=1,(#oi/2) do
local on=oi[cx]
local oo=#oi-(cx-1)
oi[cx]=oi[oo]
oi[oo]=on
end
end
function nd(nh)
return(nh[1]+1)*128+nh[2]
end
function op(cf)
local cp=cf%128
local co=((cf-cp)/128)-1
return{co,cp}
end
function gy(oi,oq)
for cx=#oi,1,-1 do
oi[cx+1]=oi[cx]
end
oi[1]=oq
return oq
end
function of(oi,os)
if#oi==0 then
add(oi,os)
return
end
add(oi,{})
for cx=#oi,2,-1 do
local ot=oi[cx-1]
if os.og<ot.og then
oi[cx]=os
return
else
oi[cx]=ot
end
end
oi[1]=os
end
function bi(ou,...)
local bg,ov=coresume(ou,...)
assert(bg,ov)
end
function ge(ho,gb)
add(
t,
cocreate(
fp(ho,gb)
)
)
end
function fp(ho,gb)
return function()
local fl=gb.fl
local fv=gb.fv or 0
local ow=gb.ow or ox
local oy=0
local oz={}
for pa,kv in pairs(gb.fm) do
oz[pa]={
pb=ho[pa],
oj=kv,
pc=kv-ho[pa]
}
end
if gb.bj then add(u,gb.bj) end
for go=1,fl do
oy=ow(go/fl)
for pa,fk in pairs(oz) do
ho[pa]=fk.pb+oy*fk.pc
end
yield()
end
for pa,fk in pairs(oz) do
ho[pa]=fk.oj
end
while fv>0 do
fv-=1
yield()
end
if gb.bj then del(u,gb.bj) end
end
end
function fq(ks)
return function() for cx=1,ks do yield() end end
end
function fo(pd,pe)
return cocreate(function()
for be,pf in pairs(pd) do
if pe and
w.gs
then return end
pf()
end
end)
end
function ox(cc)
return cc*(2-cc)
end
function pg(cc)
return cc*cc
end
function ph(cc)
return cc
end
__gfx__
00000000d55555550000d66dd666666dd66d000000000000d66d00000000d66d000000000000000033333333323223333333333376d766d676d766d6666d666d
000000006576666600006dd56dddddd56dd50000000000006dd5000000006dd500000000000000003333333333332323333333336ddddddd6ddddddd76d76666
00700700d166666600006dd56dddddd56dd50000000000006dd5000000006dd50000000000000000333b3333316363363dd3d333dd7d65d5dd0d65d0d70d776d
00077000d56ddddd00006dd5d55555516dd5000000000000d55100000000d55100000000000000003333333bd56dd3dd355355317dddddd50dd0ddd5ddd00dd0
000770005155151100006dd5000000006dd50000d666666d00000000000000000000d66dd66d00003b33353351551511300300306d65d6dd6d6006dd50500d05
00700700666d576600006dd5000000006dd500006dddddd5000000000000000000006dd56dd50000336d3736666d576600030000ddddd5d5dddd05d00dd5055d
00000000666d566600006dd5000000006dd500006dddddd5000000000000000000006dd56dd50000366d5666666d5666000000006dddddd50dddddd000500050
00000000dddd56dd0000d55100000000d5510000d555555100000000000000000000d551d5510000dddd56dddddd56dd00000000555d5d55000d5d000000d000
0c0c000c000c000000b000000000000000b000b03232233300000000000000000770004000000000000000000000000000000000000000000000000000000000
0b00b00b00b0000004004b040040040b400400403333232300000000000000007667040000004400000440000000000000000000000000000000000000000000
070700070007000000000000b0b0b000000000003dd3dd35000000000000000007667a007777a000a66a00000000000000000000000000000000000000000000
0300300300300000000000000000000000000000d5535551000000000000000005a5a8a6666a8a056678a0000000000000000000000000000000000000000000
0808000800080000000000000000000000000000000000000000000000000000a5a5aaaa5a5aaaa777aaa0000000000000000000000000000000000000000000
0b00b00b00b0000000000000000000000000000000000000000000000000000005a5aa005a5aa005a5aa00000000000000000000000000000000000000000000
0a0a000a000a00000000000000000000000000000000000000000000000000004040400040404004040400000000000000000000000000000000000000000000
03003003003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c5c50000c5c50000c5c50000c5c50000c5c50000cccc0000cccc0000cccc0000cccc0000cccc00000000000000000008888880000000000000000000000000
05c5a5a005c5a5a005c5a5a005c5a5a005c5a5a00cccaaa00cccaaa00cccaaa00cccaaa00cccaaa00dddd000000dddd088700078000000000000000000000000
c5c5a575c5c575a5c575a5a575c5a5a5c5c5a5a5cccca77cccc77aacc77caaac7cccaaacccccaaa70d000000000000d087870078000000000000000000000000
c5c57575c57575a57575a5a575c5a5a5c5c5a575ccc77777c77777ac7777aaac77ccaaaccccca7770d0d00000000d0d087780078000000000000000000000000
75c56565c56565c56565c57565c575c5c575c56577cc666ccc666ccc666ccc776ccc77cccc77cc660d00d000000d00d082778778000000000000000000000000
7575c5c5c5c5c5c5c5c5c575c5c57575c57575c5777cccccccccccccccccc777ccc7777cc7777ccc00000d0000d0000082720878000000000000000000000000
65c5c5c5c5c5c5c5c5c5c565c5c565c5c565c5c566cccccccccccccccccccc66cccc66cccc66cccc000000d00d00000082222282000000000000000000000000
c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5cccccccccccccccccccccccccccccccccccccccc000000000000000008888820000000000000000000000000
0000000000000772270000002222222200700000000777222000000022222222d66d00000000d66dd666666dd666666d00007000000000000000000000000000
00000000000077722777000077277277077000700777777222227770272222206dd5000000006dd56dddddd56dddddd500007700000000000000000000000000
00000000000000222200000077077070077700700000722222777777772027206dd5000000006dd56dddddd56dddddd577777770000000000000000000000000
00000000000077722770000007070070077700770000002222277700777077206dd5000000006dd56dd55551d5555dd577777777000000000000000000000000
07007070000007722777000000000000027707770077722222000000770077706dd5666dd6666dd56dd5000000005dd577777770000000000000000000000000
07077077000000222200000000000000027202777777772222270000070077706dddddd56dddddd56dd5000000005dd500007700000000000000000000000000
77277277000077722777000000000000022222720777222227777770070007706dddddd56dddddd56dd5000000005dd500007000000000000000000000000000
2222222200000072277000000000000022222222000000022277700000000700d5555551d5555551d55d00000000d55100000000000000000000000000000000
00e0000000e0000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000e00000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44400000040000004440000000000000050055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000000444000000440000044400000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40400000040000004000000040400000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e0000000e0000000e0000000e0000000e0000000e00000000000000b3033000b030000030000003000000300000303000b3033000000000000000000000000
00400000404000000040000040400000004000000040000000000000bfb33330bf333000bf330000b300003fb3003bf330bfb333300000000000000000000000
440000000400000004000000040000000400000044000000000000003fb333303f3330003f330000b300003f330033f3303fb333300000000000000000000000
0440000044000000044000000440000004000000044000000000000033f333300fb330003f3300003300003f330003fb3033f333300000000000000000000000
40000000004000000400000004000000404000000400000000000000033333000333300003300000330000033000033330033333000000000000000000000000
00000000000000000000000000000000000000000000000000000000003330000033000003300000330000033000003300003330000000000000000000000000
00000000000000000000000000000000000000000000000000000000000300000030000003000000300000030000003000000300000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0000000e0000000e0000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40400000404000004040000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000000040000000400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04400000040000000400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000000004000000400000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
80505050505050505050505050505090805050505050505050505050505050908050505050505050505050505050509000000000000000000000000000805050
00000000000000000000000000902000001000001000000000000000004000008050505050505050505050505050505050505050505050505050505050505090
20630000000000000000000000040040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000200004
40000000000000000000000000002000001000001000000000000000004000002000000000000000000000000000000000000000000000000000000000000040
20630000b0b0b0b0b0b0b0b0b0b0b0402000000000000000000000000000004020000000000000000000000000000040000000000000000000000000002000b0
40000000000000005050000000002000001000001010101010101000004000002000000000000000000000000000000000000000000000000000000000000040
20630013106333333333333333335340200000000000007500000000000000402000000000000075000000000000004000000000000000000000000000200013
40000000000000207373400000002000001000000000000000000000004000002000000000000000000000000000000000000000000000000000000000000040
20630013106300000000000000005340200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000200013
4000000000000020000040000000200000100000000000000000000000400000200000b0b0b0b000000000d00000000000000000000000000000000000000040
20630013106300b0b0b0b0b0b0000040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000200000
4000000000000020320040000000200000100000d0d0000000d0d000004000002000001073737300000000000000000000000000000000000000000000000040
20630013106300102300000010000040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000200000
4000000000000020b000400000002004001043434343434343434343434000002000001023000000000000000000000000000000000000000000000000000040
206300131063001023b0b00010230040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000202300
4000000000000020230040000000705151303030303030303030303030600000200000102300000000d000000000000000000000000000001010101010100040
20630013106300102300100010000040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000202300
400000000000002023004000000000000000000000000000000000000000000020000010230000000000000000d0000000101010100000000000000000000040
20630013106300102342100010001340200000000000000000000000003200402000000000000000000000000032004000000000000000000000000000200000
40000000000000200013400000000000000000000000000000000000000000002000001023000000000000000000000000100000100000000000000000000040
20630013106300101010100010000040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000200013
400000000000002000134000000000000000000000000000000000000000000020000010230000000000000000000000000000000000000000000000d0000040
20630013106300000000000010230040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000200013
83900000000080930000835090000000000000000000000000000000000000002000001023000000000000000000000000000000000000000000000000000040
206300131010b0b0b0b0b0b010230040200000000000000000000000000000402000000000000000000000000000004000000000000000000000000000207500
00835050505093000000000040000000000000000000000000000000000000002000001023000000000000000000000000000000000000000000000000000040
2063000000003333000033333300004020000000000000000000000000000040200000000000000000000000000000400000000000000000000000000020d000
000000000000000000b0000040000000000000000000000000000000000000002000001023000000000000000000000000000000000000000000101010101040
20630000000000000000000000000040200400000000000000000000000000402004000000000000000000000000004000000000000000000000000000204343
000000000000000000a351516000000000000000000000000000000000000000200000102300000000000000000000000000000000d000000000000000000040
2063d0d00000d0d00000d0d0d0d00040703030303030303030303030303030607030303030303030303030303030306000000000000000000000000000705151
30303030303030303060000000000000000000000000000000000000000000002000001023000000000000000000100000000000000000000000000000000040
20630303030303030303030303030340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002000001023000000000000000010101000000000000000000000000000000040
70303030303030303030303030303060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002000001023000000000000001010101010000000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002000001023000000000000101010101010100000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002000001023000000000010100000000000101000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000020000010b0b0b0b0b0b010000000000000000000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000200000b01000001000000000000000b000000000000000d00000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002032001000000010000000000000001000000000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000020b0b01000000033000000000000001000000000000000000000000000d00040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000200000000000007500000000000000100000b0000000000000d0000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000200000000000004300000000000000100000100000d000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002004000000000010000000000000001000001000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000020b0b0b000000010000000000000000000001000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000020000000000000100000b0b0b00000b000001000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002000000000000010000000000000001000001000000000000000000000000040
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002043434343434310434343434343434343431043034303430343034303430340
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007030303030303030515151515151515151513030303030303030303030303060
__gff__
000301030101010101010101014141010000000000010000000000000000000008080808080c0c0c0c0c0000000000001010101010101010010101010000000000000000000000000000000000000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0805050505050505050505050505050908050505050505050505050505050509080505050505050505050505050509000805050505050505050505050505050908050505050505050505050505090805050505050505050505050505050908050505050505050505050505050505050505050505050505090000000000000000
0270000000000000000000000000000402010100003132000037373700010104020000000000000000000000000004000200000000000000000000000000000402000000000000000000000000040200000000000000000000000000000402333333333333333333333333333333333333333333333333040000000000000000
0224700000000000000000000000000402010000003132000000000000000104020000000000004000000000000004000200000000000000000000000000000402000000000000000000000000040200000000000000000000000000000402000000000000000000000000000000000000000000000000040000000000000000
0201010101010101010101010000000402000000003132000000000000000004020000000000000000000000000004000200000000000000000000000000000402000000000000000000000000040223000000000000000000000000000402230000000000000000000000000000000000000000000000040000000000000000
02000000000000000000000100000004020000000031320000000000000000040200000000000101010000000000040002000000000000000000000000000004020000000000300000000000000402010000000000000000000000000004023b0000000000000000000000000000000000000000000000040000000000000000
020000000000000000000000000000040224000000313200000001000000000402000000000000000000000000230400020000000000000057000000000000040200000b00000b000000000023040200000057000000303030300000000402020101010100000b0b0b0000000000000000000000000000040000000000000000
020000000000000000000000000034040201340000000000000101010000000402010000000000570000000000010400024000000000000000000000000000040200000100000100010101010104020000000b0b0b0b0b0b0b0b2b00000402023333333300003333330000000000000000000000000000040000000000000000
0200000000010130303001010101010402010101010101010101010101000004020000000000000000000000000004000200000000000000000000000000230402000001000001000000000000040200000000000000000000000000000402024000000000000000000000010101000000000000000000040000000000000000
0200000101010101010101000000000402000000003737000037370001010004020000000101010101010100000004000201010101000000000000010101010402000001000001000000000000040200003000000000000000000000000402020000000000570000000000333333000000000001010101040000000000000000
022b000100000000000000000000000402000000000000000000000001010004020000000000000000000000000004000200000000000000000000000000000402000001000001000000000000040200310100000000000000000000000402020000000000000000000000000000000000000000000000040000000000000000
0200000100000000000000000000400402000000000000000000000000010004020100000000000000000000000104000200000000000000000000000000000402000001000001000000000000040200000000003000000000000000000402020000000000000000000000000000000001000000000000040000000000000000
02002a0000000101010000000000010402400000000000000000000000010004020000000000000000000000000004000200000000000000000000000000000402000001005701000000000000040200000000000132000000000000000402020b0b000000000000000000000000000000000000000000040000000000000000
07030303030303030303030303030306020000000030300000303000000000040200010101010101010101010100040002000000000000000000000000000004020000010000010000000000000402000000000000000000000101010104020201010b0000000000010101010100000000000000000000040000000000000000
0000000000000000000000000000000007030303030303030303030303030306020000000000000000000000000004000200000000000000000000000000000402000001000001000000000000040200000040000000000000000000000402020101010101010101010101010101010101010101010101040000000000000000
000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000400023434343434343434343434343434040240000134340134343434343404023434340b343434343434343434340407030303030303030303030303030303030303030303030303060000000000000000
0000000000000000000000000000000000000000000000000000000000000000071515151515151515151515151506000703030303030303030303030303030607030303030303030303030303060703030303030303030303030303030600000000000000000000000000000000000000000000000000000000000000000000
0805050505050505050505050505050908050505050505050505050505050509080505050505050505050505050505090805050505050505050505050505050505050505050505050505050505090805050505050505050505050505050900000000000000000000000000000000000000000000000000000000000000000000
0233333333333333333333333333330402000000000000000000000000000004023633333333333333333333333333040237373737010101010101010101010101373737373737373737010101040200000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000
020000000000000000000000000000040257000000000000000000000000400402360000000000000000000000403104023f003f3f330101010101010101010101000000000000000000010100040223000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000
02000000000000000000000000000004020d0b0b0b0b0b0b0b0b0b0b0b0b0b040236000000310101010101010101010402000000000033330101010101010101010000000000000000000100000402010b0b00000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000402000000000000000000000000000004023600000031013633333333333701040200000000000000333301010101010101000000000000000000000000040200000000000000000000010101010400000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000402000000000000000000000000000004023600000035013201010101013101040200001200000000000033330101010101000000000000000000000000040200000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000
020000000000005700000000000000040201010d0d0101010101010101010d04023600003101013201363333013101040200120000000000000000000000000000000000000000000000003000040200000000000000000d00000000000400000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000402000000000000000000000000000004023600003101013201320101013101040212000000000000000000000000000000000000000000000000300100040200000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000
0200000000000001000000000000000402230000000000000000000000000004023600003101013201343030303501040200000000000000000000000000005700000000000000000000010100040200000000000d00000000000000000400000000000000000000000000000000000000000000000000000000000000000000
02000000000001010100000000000004020b0000000000000000000000000004020136000031013201010101010101040200000000000000000000000b0b0b0b0b000000000000000000010100040200000000000000003434343434340400000000000000000000000000000000000000000000000000000000000000000000
020000000001010101010000000000040200000000000d00000000000000000402013600003101010101010101010104020000000000000040000b0b01010101013200000d0d0d000000010100040200000000000000000101010101010400000000000000000000000000000000000000000000000000000000000000000000
02000000010101010101014000000004020000000000000000000d00000000040201013600003737373737373737370402000000000000000b0b01010101010101320000000000000000010100040201010101303000000137373737370400000000000000000000000000000000000000000000000000000000000000000000
0200000101010101010101010000000402000000000000000000000000000d04020101360000000000000000000035040201000000000b0b010101010101010101320d00000000000d00010100040237373701010100000100000000000400000000000000000000000000000000000000000000000000000000000000000000
02000101010101010101010101002304020000000000000000000000000000040201013600000000000000000000350402010100000b0101010101010101010101320000000000000000010100040200000000010100000100000000000400000000000000000000000000000000000000000000000000000000000000000000
02343434343434343434343434343404023434303434303434303434303434040201013434010101010134302430350402010101230101010101010101010101010b0b0b0b0b0b0b0b0b010101040200005700000100000100000000000400000000000000000000000000000000000000000000000000000000000000000000
0703030303030303030303030303030607151515151515151515151515151506070303030303030303030303030303060703030303151515151515151515151515151515151515151515151515060200000b00000100003700000000000400000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0107000025731257310b634166342b7342b734136341963431734317341a6341f63435734357340170607706397062a7062b7062b7062d7063770637706377063770636706157061870618706187061870600706
011800200c0533f2051b3031b303246150c0533f4053f3050c0533f2053f2051b303246151b3030c0531b3030c0533f4053f3053f205246153f3050c0533f4050c0530c0533f2053f20524615246150c05324615
01180020021500e05002155020500215002055021500205502150020500e1000e155021550e155021550e1550215002055021500e0500e1550205002150020500e150020550e1000e155021550e155021550e155
01180020001500c05000155000500015000055001500005500150000500e1000c155001550c155001550c1550015000055001500c0500c1550005000150000500c150000550e1000c155151550c155001550c155
01180020001500c0500e155000500e1500c005021500c155021500c0520e15010155001500e1550c1000c050000500c155001500c0550c0000005500150000500c0550e1050e100001551315215155101550c155
010c00200e732217301c732217301d732217301373213732157321573221732157322173221732217322172221722237022170200702000000000000000000000000000000000000000000000000000000000000
01100020001530c1552462324623131550c623246232462500155246233060324623001550015524623246030c15510155246231115524623180030c1550c1530c155180030c6230c623181550c1550c62300153
0108000018634365252c5251b52512525195252852531525255042750427504025040250402504185041850418504185041850418504185041850418504185041850418504185041850418504185041850400000
011400080001602716000160271600016027160201600716000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000216130c5001c5001050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002d61318405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001a7210e7211a1010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00080c111001110c1120c1110c1120c1120c1110c111180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140020005530c5552452324523135550c523245232452500555245233050324523005550055524523245030c55510555245231155524523185030c5550c5530c555185030c5230c523185550c5550c52300553
010300000041500605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000004770c675180001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e002006136061260812608126041360612607136091260812607136071260213608136061260612606126061360613607136081260812609126091360a1260912609136081260813608126071260713607126
010b0000188051880016804168021880516805168041680218805188001b8041b802188051880016804168021880518800168041680218805188001b8041b8021880518800168041680218805188001680416802
010b000030e0530600306003060030e053060030600306003060530600306003060030e0530e0030e0030e0030e0530e0030e0030e0030e0530e0030e0030e0030e0530e0030e0030e0030e0530e0030e0030e00
010b000030e0530e0000c0530e0030e0530e0000c0530e0030e0530e0000c0530e0030e0530e0030e0530e0000c0530e0030e0530e0030e0530e0000c0530e0030e0530e0000c0530e0030e0530e0000c0530e00
010b00001ff0613f061ff0500f0000f0000f0000f0000f0000f0000f001ff0000f001ff0013f001ff0613f061ff0500f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f00
010b00001ff0613f061ff0500f001bf060ff061bf0500f0000f0000f001ff0000f001ff0013f001ff0613f061ff0500f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000d00
010b00000ce0500e0000e000ce050ce0500e000ce0500e000ce000ce050ce0500e000ce0500e000ce050ce050ce0500e0000e000ce050ce050ce050ce050ce050ce000ce050ce050ce050ce050ce050ce050ce05
010b00001880418802188051680018800188001880418805188051880518800188001880516800168051680018804188052280018800188001880018805188001880518800188001880018800188001880516800
000100001fe0505e00180001800012e001ae001ee0023e0026e0026e0026e0028e0029e0029e0029e0028e0026e0025e0021e001fe001ee0018e0014e0011e000ee000be000be0007e0003e0003e0003e0002e00
010b00001ff0613f061ff0613f061ff0613f061ff0613f061ff0613f061ff0613f061bf060ff061bf060ff061bf060ff061bf060ff061bf060ff061bf060ff061bf060ff061bf060ff060ff050ff061bf060ff06
01090000001020010200100001000c10000100001000010000105001000c100001000c10000100001000010000102001020c100001000c10000100001000010000105001000c100001000c100001000010000100
010900000c5040c50500500005000e5040e50500500005000f5040f50500500005000050000500145041450500500005001450414505135041350511500005001150411505005000050000500005001350413505
0109000000500005001350413505115041150500500005000f5040f505005000050000500005001150411505005000050011504115050f5040f50500500005000e5040e505005000050000500005000050000500
010900000c5040c50500500005000e5040e50500500005000f5040f50500500005000050000500145041450500500005001450414505135041350511500005001150411505005000050000500005001850418505
0109000000500005001850000500145041450500500005001350413505005000050000500005001a5041a50500500005000050000500185041850500500005001350413505005000050000500005000050000500
01090000180060c006180000c0001a0060e0061a0000e0001b0060f0061b0060f00620006140062000614006180000c00020006140061f006130061d0000c0001d006110061d006110061f006130061f00613006
01090000180000c0001f006130061d006110061d006110061b0060f0061b0060f0061d006110061d00611006180000c0001d006110061b0060f0061b0060f0061a0060e0061a0060e006180060c006180060c006
01090000180060c006180060c0061a0060e0061a0060e0061b0060f0061b0060f00620006140062000614006180000c00020006140061f006130061f006130061d006110061d0061100624006180062400618006
01090000180060c006180060c006200061400620006140061f006130061f00613006260061a006260061a00624006180062400618006240061800624006180061f006130061f00613006180060c006180060c006
010900000c6050c6050c6050c6050c6050c6050c605000000c6050c6050c6050c6050c6050c6050c6050c6050c6050c6050c605000000c6050c6050c6050c6050c6050c6050c605000000c6050c6050c6050c605
010900000c6050c6050c6050c6050c6050c6050c605000000c6050c6050c6050c6050c6050c6050c6050c6050c6050c6050c605000000c6050c6050c6050c6050c6050c6050c605000000c6050c6050c6050c605
000900000c60500000000000000000000000000c60500000000000000000000000000c6050000000000000000c60500000000000000000000000000000000000006050000000605000000c605000000c60500000
0109000000506075060050607506075060f506075060f5060c5060f5060c5060f5060c506135060c50613506135060f506135060f506135061b506135061b506185061b506185061b50618506275061850627506
010900000040500000000000000000000000000040500000004030000000000000000040500000000000000000405000000000000000004050000000405000000040300000000000000000000000000000000000
01090000243330160018323046070c313026070031300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900002763307630016030c0000360014100026000f1000c6050c6050c6050c6050c1030c0000c1030c0000c0000c0000c1030c0000c6050c6050c1030c0000c6050c0000c0000c0000c1030c0000c6050c000
010c00003034324343183430034300303183030030300303003030c303003030c3030030300303003030c30300303003030030300303003031830300303003030030300303003030030300303003030030300303
010900000761000100001000c10000100001000010000105001000c100001000c10000100001000010000102001020c100001000c10000100001000010000105001000c100001000c10000100001000010000000
010900000710207102001000010000100001000010000100071050010000100001000010000100001000010007102071020010000100001000010000100001000710500100001000010000100001000010000100
010900000710207102001000010000100001000010000100071050010000100001000010000100001000010007102071020010000100001000010000100001000710500100001000010000100001000010000100
010300000e0000c0001800015000120000f0000f0000d0000c0000a0000a000080000400004000040000300003000020000100001000010000000000000000000000000000000000000000000000000000000000
010200000860006600076000560004600046000360003600026000260001600016000160004600046000360003600026000160001600016000000000000000000000000000000000000000000000000000000000
010300000c906189060c9062490618906249062490630906159000d9000d9000e900179000d90012900129000f9000e9000d9000f9001490015900169000c9000c9000f90011900139001490015900169000c900
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01120010181001a1000c1001b7001b404220001f1001f504181031a1021f1001d104201001f100371062b7041e1002200026000290002a0002a0002a0002a0002900027000240001d00000000000000000000000
011200100030000102003020010502201021060250402101033010310703107033010510605202057010520000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 02 43 44
00 01 03 43 44
00 01 02 43 44
02 01 04 43 44
00 11 13 19 44
00 11 13 14 44
00 11 13 19 44
00 11 13 15 44
03 08 42 43 44
00 17 16 15 44
04 05 42 43 44
03 06 42 43 44
01 1a 25 23 44
03 0d 42 43 44
00 1a 1b 24 44
00 28 1c 24 44
00 2b 1d 25 44
00 2b 1e 26 44
00 1a 1f 27 44
00 1a 20 27 44
00 1a 21 27 44
00 1a 22 27 44
00 2b 25 27 44
00 2b 27 29 44
00 2c 2a 29 44
00 2c 2a 29 44
00 1a 27 29 44
00 1a 27 2d 44
00 2c 24 27 44
02 2d 24 27 44
03 32 33 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 1a 1f 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 01 42 43 44
