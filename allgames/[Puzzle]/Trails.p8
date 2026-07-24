pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--trails
--by matthias

a="6"
while(not b) do
if(btnp()>0) b=true
cls()
c=4-abs(time()-4)
for d=-3,3 do
for e=-1,1 do
for f=-1,1 do
g=mid(c-rnd(.5),0,1)
g=3*g*g-2*g*g*g
h=atan2(e,f)-.25
i=8+(h*8)%8
if(e==0 and f==0) i=7
j=64.5+(e*13)+d
k=64.5+(f*13)+d
l=8.5*g-abs(e)*5
m=8.5*g-abs(f)*5
if(l>.5) rectfill(j-l,k-m,j+l,k+m,i) rect(j-l,k-m,j+l,k+m,i-1)
end
end
end
if rnd()<c-.5 then
print(a,69-#a*2,65,2)
end
if c>=1 then
for n=0,1 do
for o=1,c*50-50 do
e=cos(o/50)
f=sin(o/25)-abs(e)*(.5+sin(time()))
circfill(65+e*8,48+f*3-n,1,2+n*6)
end
end
for o=1,20 do
print(sub("pico-8 advent calendar",o),17+o*4,90,mid(-1-o/20+c,0,1)*7)
end
end
if(time()==8) b=true
flip()
end
function _init()
p()
q=0x5e00
r()
s={}
s.t="intro"
s.u=1
s.v=true
s.w="Ž"
s.x="—"
if(not y()) then
s.v=false
s.w="(c)"
s.x="(x)"
end
s.z=false
s.ba=false
bb={}
bb[1]={}
bb[1]["up"]=1
bb[1]["down"]=2
bb[1]["left"]=3
bb[1]["right"]=4
bb[2]={}
bb[2]["up"]=17
bb[2]["down"]=18
bb[2]["left"]=19
bb[2]["right"]=20
bb[3]={}
bb[3]["up"]=33
bb[3]["down"]=34
bb[3]["left"]=35
bb[3]["right"]=36
bb[4]={}
bb[4]["up"]=49
bb[4]["down"]=50
bb[4]["left"]=51
bb[4]["right"]=52
bc={}
bc[1]={38,22}
bc[2]={39,23}
bd={}
be()
if(bf()) s.t="piracy"
if(s.t=="intro") bg()
if(s.t=="title") bh()
if(s.t=="select") bi()
if(s.t=="deluxe") bj()
if(s.t=="play") bk()
if(s.t=="credits") bl()
bm("game","launched")
end
function _update60()
if(s.t=="intro") bn()
if(s.t=="title") bo()
if(s.t=="select") bp()
if(s.t=="deluxe") bq()
if(s.t=="play") br()
if(s.t=="credits") bs()
end
function _draw()
if(s.t=="piracy") bt()
if(s.t=="intro") bu()
if(s.t=="title") bv()
if(s.t=="select") bw()
if(s.t=="deluxe") bx()
if(s.t=="play") by()
if(s.t=="credits") bz()
end
function be()
ca={}
cb(5,"//// o b",{"1d41","2d21"})
cb(5,"/   b// o/",{"1r22","2l44"})
cb(5,"//   bo//",{"1r13","2r23"})
cb(5,"  b/   o///",{"1u34","2r33"})
cb(5," b p//// q",{"1u45"})
cb(5,"/    p/ o  b// q",{"1r33","2u45"})
cb(5,"  q/o/  b//  p",{"1d41","2l54"})
cb(5,"/ d l// b/",{"1u44"})
cb(5,"//ob  l//",{"1d42","2r33"})
cb(5,"//bo  l//",{"1u44","2r33"})
cb(5,"  d/ r/   o/  b/",{"1l33","2u24"})
cb(5,"/ d/r d/  bo/",{"1d41","2l52"})
cb(5,"/b  p// q l/",{"1d22"})
cb(5,"/ o qb// p u/",{"1d21","2r12"})
cb(5,"   o/  bq//  pl/  u",{"1d21","2r12"})
cb(5,"   g//    o/ b/",{"1d22","2r23","3u34"})
cb(5,"//  bg/   o/",{"1l53","2r34","3u45"})
cb(5," o////g b",{"1d32","2u34","3l54"})
cb(5,"  p/ g o//  b/  q",{"1u24","2r12","3l53"})
cb(5,"/  b/  o q/p g/",{"1u25","2l54","3d42"})
cb(5,"/  oy/  bg//",{"1d41","2r22","3l53","4u34"})
cb(5,"/  oy/  gb//",{"1r22","2d31","3d41","4l52"})
cb(5,"//   p/o q l/ g b",{"1d31","2r12","3u55"})
cb(5,"/gb/ o/ u l/",{"1r13","3d31","2l42"})
cb(5,"/ pbog/  q//",{"1r13","2d23","3u24"})
ca.cc=25
if(s.z) ca.cc=102
end
function cb(cd,ce,cf)
local cg={}
cg.cd=cd
cg.ce=ce
cg.cf=cf
add(ca,cg)
end
function ch(ci)
u={}
for e=1,ca[ci].cd do
u[e]={}
for f=1,ca[ci].cd do
u[e][f]=nil
end
end
local e=0
local f=1
for o=1,#ca[ci].ce do
e+=1
if(sub(ca[ci].ce,o,o)=="/") then
e=0
f+=1
else
u[e][f]=sub(ca[ci].ce,o,o)
end
end
u.cd=ca[ci].cd
u.cj=0
u.ck=1
u.cl=1
u.cm=1
u.cn=0
u.co="intro"
u.cp=-100
u.cq=false
cr={}
cf={}
foreach(ca[ci].cf,cs)
ct={}
cu()
cv()
music(0)
end
function cs(cw)
local cx=sub(cw,1,1)
local cy=sub(cw,2,2)
local e=sub(cw,3,3)
local f=sub(cw,4,4)
cz(cx,cy,e,f,false)
end
function cz(da,db,e,f)
local dc={}
dc.da=tonum(da)
if(db=="u") dc.z=0 dc.dd=-1 dc.db="up"
if(db=="d") dc.z=0 dc.dd=1 dc.db="down"
if(db=="l") dc.z=-1 dc.dd=0 dc.db="left"
if(db=="r") dc.z=1 dc.dd=0 dc.db="right"
dc.e=tonum(e)
dc.f=tonum(f)
dc.d=0
dc.de=.4
dc.cn=0
local df=dg()
dc.dh=e*16+df
dc.di=f*16+df
dc.dj=false
add(cf,dc)
dk(dc)
return dc
end
function dl()
s.u=mid(1,s.u+1,#ca)
ch(s.u)
end
function dm()
s.u=mid(1,s.u-1,#ca)
ch(s.u)
end
function dn()
if(s.t=="play"and u.co!="won") then
ch(s.u)
u.co="retry"
end
sfx(1)
end
function p()
pal()
palt(0,false)
palt(10,true)
end
function by()
dp()
foreach(cr,dq)
dr()
foreach(cf,ds)
foreach(ct,dt)
du(3,50)
if(u.co!="intro"and not dv.dw) dx()
if(u.co=="intro") then
rectfill(42+u.cp,58,86+u.cp,70,12)
print("level "..dy(s.u),49+u.cp,62,7)
end
if((u.co=="won"or u.co=="outro") and u.cn<90) then
rectfill(0,54,127,74,9)
rect(-1,54,128,74,15)
sspr(48,32,32,15,47,56)
end
if(u.co=="lost") then
rectfill(0,54,127,74,8)
rect(-1,54,128,74,15)
sspr(0,48,47,15,41,56)
end
dz()
ea(u.cl)
end
function dp()
rectfill(0,0,127,127,7)
eb()
if(u.cd==5) then
ec(24,24)
ed(4,8)
ee(104,0)
ef(8,112)
ef(13,114)
ef(106,112)
ef(99,113)
ef(103,116)
end
if(u.cd==6) then
ec(16,16)
ec(32,16)
ec(16,32)
ec(32,32)
ed(2,4)
ee(108,0)
ef(4,114)
ef(9,116)
ef(110,114)
ef(104,115)
ef(107,118)
end
if(u.cd==7) then
ec(8,8)
ec(40,8)
ec(40,40)
ec(8,40)
ed(0,2)
ee(115,0)
ef(0,118)
ef(5,120)
ef(114,117)
ef(108,118)
ef(111,121)
end
end
function eb()
spr(15,18,18)
spr(15,49,49)
spr(31,64,5)
spr(31,24,112)
spr(31,75,75)
spr(47,100,100)
spr(47,120,56)
spr(47,32,62)
spr(61,8,32)
spr(61,108,40)
spr(61,12,78)
spr(62,4,40)
spr(62,112,80)
spr(63,64,110)
spr(63,6,90)
end
function ec(e,f)
sspr(47,47,81,81,e,f)
end
function ed(e,f)
sspr(103,0,13,11,e,f)
end
function ee(e,f)
sspr(0,64,24,24,e,f)
end
function ef(e,f)
sspr(103,16,14,7,e,f)
end
function dr()
local df=dg()
u.cj+=1
if(u.cj%30==0) then
u.ck+=1
if(u.ck>2) u.ck=1
end
for f=1,u.cd do
for e=1,u.cd do
local c=u[e][f]
local eg=nil
if(c=="o") eg=21
if(c=="b") eg=5
if(c=="g") eg=37
if(c=="y") eg=53
if(c=="p"or c=="q") then
eg=54
spr(bc[1][u.ck],e*16+df,f*16+df-8)
end
if(c=="s"or c=="t") then
eg=55
spr(bc[2][u.ck],e*16+df,f*16+df-8)
end
if(c=="u") eg=8
if(c=="d") eg=24
if(c=="l") eg=40
if(c=="r") eg=56
if(c=="w") ed(e*16+df-3,f*16+df-2)
if(c=="1") sspr(72,0,16,16,e*16+df-4,f*16+df-4)
if(c=="2") sspr(88,0,16,16,e*16+df-4,f*16+df-4)
if(c=="3") sspr(72,16,16,16,e*16+df-4,f*16+df-4)
if(c=="4") sspr(88,16,16,16,e*16+df-4,f*16+df-4)
if(eg) spr(eg,e*16+df,f*16+df)
end
end
end
function dg()
local df
if(u.cd==5) df=13
if(u.cd==6) df=5
if(u.cd==7) df=-3
return df
end
function ds(cw)
local eg=0
eg=bb[cw.da][cw.db]
spr(eg,cw.dh,cw.di+cw.d)
end
function dx()
local df=0
local eh=u.cm
local ei=74
if(not s.v) ei=78
if(eh==1 or eh==3) df=-4
if(eh==4) df=-8
local ej=114
if(btn(4)) ej=115
spr(79,65+df,115)
spr(ei,65+df,ej)
if(eh>=2) then
local ek=114
if(btn(5)) ek=115
spr(79,56+df,115)
spr(75,56+df,ek)
end
if(eh>=3) then
local el=114
if(btn(2)) el=115
spr(79,74+df,115)
spr(76,74+df,el)
end
if(eh==4) then
local em=114
if(btn(3)) em=115
spr(79,83+df,115)
spr(77,83+df,em)
end
end
function dq(cn)
line(cn.e,cn.f,cn.e+cn.l,cn.f,6)
end
function dt(cy)
cy.cn+=1
cy.d=cos(cy.cn/20)*3-2
spr(cy.eg,cy.e,cy.f+cy.d)
end
function dy(eh)
local en=tonum(eh)
local eo=en
if(eh<10) eo="0"..en
return eo
end
function ep(eq,e,f,er,es)
if(e=="c") e=et(eq)
if(f=="c") f=eu(eq)
for n=-1,1,1 do
for o=-1,1,1 do
print(eq,e+o,f+n,es)
end
end
print(eq,e,f,er)
end
function et(eq)
if(ev(eq)==1) then
return(64-#eq*2)+1
else
local ew=0
local ex=0
for o=1,#eq,1 do
ew+=1
if(sub(eq,o,o)=="\n"or o==#eq) then
if(ew-1>ex) ex=ew-1
ew=0
end
end
return(64-(ex)*2)+1
end
end
function eu(eq)
local count=ev(eq)
return(64-count*3)+1
end
function ev(eq)
local count=1
for o=1,#eq,1 do
if(sub(eq,o,o)=="\n") count+=1
end
return count
end
function ea(ey)
ey=max(min(1,ey),0)
local ez=8
local fa=15
local fb=1/ez
local fc=flr(ey/fb)+1
local fd={
{1,1,1,1,0,0,0,0},
{2,2,2,1,1,0,0,0},
{3,3,4,5,2,1,1,0},
{4,4,2,2,1,1,1,0},
{5,5,2,2,1,1,1,0},
{6,6,13,5,2,1,1,0},
{7,7,6,13,5,2,1,0},
{8,8,9,4,5,2,1,0},
{9,9,4,5,2,1,1,0},
{10,15,9,4,5,2,1,0},
{11,11,3,4,5,2,1,0},
{12,12,13,5,5,2,1,0},
{13,13,5,5,2,1,1,0},
{14,9,9,4,5,2,1,0},
{15,14,9,4,5,2,1,0}
}
for fe=1,fa do
pal(fe,fd[fe][fc],0)
end
end
function du(ff,de)
local cn=time()
srand(1)
for f=0,ff do
for e=0,ff do
local e=e*(128/ff)+rnd(16)+cn*de
local f=f*(128/ff)+rnd(16)
local fg=rnd(1)
e+=3*cos(cn+fg)
f+=3*sin(cn+fg)*(sgn(rnd(2)-1))
e=e%127
if rnd(10)<2 then
rect(e,f,e+1,f+1,6)
else
pset(e,f,6)
end
end
end
end
function bk()
menuitem(1,"retry level",dn)
menuitem(2,"level select",fh)
if(not s.z) menuitem(3,"get dx version",fi)
menuitem(4,"-",fj)
s.t="play"
ch(s.u)
ea(u.cl)
end
function br()
fk()
if(s.ba) then
if(btnp(0)) dm()
if(btnp(1)) dl()
end
if(u.co=="intro") then
u.cn+=1
u.cl=max(0,u.cl-.02)
if(u.cn>15 and u.cn<120) u.cp=min(0,u.cp+2)
if(u.cn>120) u.cp=min(100,u.cp+2)
if(u.cn>170) u.co="play"u.cn=0
end
if(u.co=="won") then
u.cn+=1
if(u.cn>30 and btnp(4)) u.co="outro"sfx(1)
foreach(cf,fl)
end
if(u.co=="outro") then
u.cl+=.01
if(u.cl>=1.5) then
if(s.u==ca.cc) then
bl()
else
dl()
end
end
end
if(u.co=="lost") then
u.cn+=1
if(u.cn>15 and btnp(4)) dn()
foreach(cf,fl)
end
if(u.co=="retry") then
u.cn+=1
u.cl=0
if(u.cn>15) u.co="play"
end
if(u.co=="play") then
local da
local fm=false
if(not u.cq and not dv.dw) then
if(s.u>1 and btn(4) and btn(5)) fn()
if(btnp(4)) da=1 fm=true
if(btnp(5)) da=2 fm=true
if(btnp(2)) da=3 fm=true
if(btnp(3)) da=4 fm=true
if(fo()) then
u.co="won"
u.cm=1
fp(s.u)
music(-1)
music(7)
bm("level"..dy(s.u),"won")
end
if(fq()) fn()
end
if(u.co!="lost"and fm) then
for o=1,#cf do
if(cf[o].da==da and not cf[o].dj) fr(cf[o])
end
else
foreach(cf,fl)
local cq=false
for o=1,#cf do
if(cf[o].dj) cq=true
end
u.cq=cq
end
foreach(ct,fs)
end
end
function fo()
local ft=true
for o=1,#cf do
if(not fu(cf[o])) ft=false
end
return ft
end
function fu(cw)
local da
if(cw.da==1) da="b"
if(cw.da==2) da="o"
if(cw.da==3) da="g"
if(cw.da==4) da="y"
if(da==u[cw.e][cw.f]) return true
return false
end
function fq()
if(u.co!="won") then
local fv=true
for cw in all(cf) do
if(not fw(cw) and not fx(cw)) fv=false
end
return fv
end
end
function fn()
u.co="lost"
u.cm=1
music(-1)
music(8)
bm("level"..dy(s.u),"lost")
end
function fr(cw)
local df=dg()
if(not fw(cw) and fy(cw)) then
local fz=fy(cw)
local ga,gb=gc(fz)
gd(bb[cw.da][cw.db],cw.e*16+df,cw.f*16+df,(cw.e+cw.z)*16+df,(cw.f+cw.dd)*16+df,1)
sfx(7)
cw.ge=cw.e
cw.gf=cw.f
cw.e=ga
cw.f=gb
cw.dh=cw.e*16+df
cw.di=cw.f*16+df
cw.de=0.4
end
if(not fw(cw) and not fx(cw)) then
if(gg(cw)) then
local gh=gg(cw)
gh.gi=gh.z
gh.gj=gh.dd
gh.z=cw.z
gh.dd=cw.dd
cw.dj=true
if(not gh.dj and not fr(gh)) then
if(cw.ge) then
cw.e=cw.ge
cw.f=cw.gf
cw.dh=cw.e*16+df
cw.di=cw.f*16+df
cw.ge=nil
cw.gf=nil
end
if(cw.gi) then
cw.z=cw.gi
cw.dd=cw.gj
cw.gi=nil
cw.gj=nil
end
cw.dj=false
u.cq=false
sfx(10)
return false
end
end
cw.e+=cw.z
cw.f+=cw.dd
cw.ge=nil
cw.gf=nil
cw.dj=true
u.cq=true
sfx(3)
return true
end
if(cw.ge) then
cw.e=cw.ge
cw.f=cw.gf
cw.dh=cw.e*16+df
cw.di=cw.f*16+df
cw.ge=nil
cw.gf=nil
end
if(cw.gi) then
cw.z=cw.gi
cw.dd=cw.gj
cw.gi=nil
cw.gj=nil
end
u.cq=false
sfx(10)
return false
end
function fl(cw)
local df=dg()
if(cw.dj) then
cw.cn+=1
cw.d=cos(cw.cn/20)*3-2
if(flr(cw.d)==0) dk(cw)
if(cw.dd!=0 and cw.di<(cw.f*16+df)) cw.di+=cw.de
if(cw.dd!=0 and cw.di>(cw.f*16+df)) cw.di-=cw.de
if((cw.dd>0 and flr(cw.di+1)==(cw.f*16+df)) or(cw.dd<0 and flr(cw.di)==(cw.f*16+df))) then
if(cw.gj!=nil) cw.dd=cw.gj
if(cw.gi!=nil) cw.z=cw.gi
cw.dj=false cw.cn=0 cw.de=.4
gk(cw)
end
if(cw.z!=0 and cw.dh<(cw.e*16+df)) cw.dh+=cw.de
if(cw.z!=0 and cw.dh>(cw.e*16+df)) cw.dh-=cw.de
if((cw.z>0 and flr(cw.dh+1)==(cw.e*16+df)) or(cw.z<0 and flr(cw.dh)==(cw.e*16+df))) then
if(cw.gj!=nil) cw.dd=cw.gj
if(cw.gi!=nil) cw.z=cw.gi
cw.dj=false cw.cn=0 cw.de=.4
gk(cw)
end
else
if(abs(cw.d)>0) then
cw.d*=.75
else
cw.d=0
end
end
if(u.co=="won") cw.cn+=1 cw.d=cos((cw.cn+cw.da*8)/30)*3-2
end
function gk(cw)
local gl=u[cw.e][cw.f]
if(gl=="u"and cw.db!="up") cw.z=0 cw.dd=-1 cw.gi=nil cw.gj=nil cw.db="up"sfx(8)
if(gl=="d"and cw.db!="down") cw.z=0 cw.dd=1 cw.gi=nil cw.gj=nil cw.db="down"sfx(8)
if(gl=="l"and cw.db!="left") cw.z=-1 cw.dd=0 cw.gi=nil cw.gj=nil cw.db="left"sfx(8)
if(gl=="r"and cw.db!="right") cw.z=1 cw.dd=0 cw.gi=nil cw.gj=nil cw.db="right"sfx(8)
if(gl=="1") cw.da=1 cu() sfx(9)
if(gl=="2") cw.da=2 cu() sfx(9)
if(gl=="3") cw.da=3 cu() sfx(9)
if(gl=="4") cw.da=4 cu() sfx(9)
end
function cu()
u.cm=1
for cw in all(cf) do
if(cw.da==2) u.cm=max(u.cm,2)
if(cw.da==3) u.cm=max(u.cm,3)
if(cw.da==4) u.cm=max(u.cm,4)
end
end
function fw(cw)
if(cw.dd>0 and cw.f==u.cd) return true
if(cw.dd<0 and cw.f==1) return true
if(cw.z>0 and cw.e==u.cd) return true
if(cw.z<0 and cw.e==1) return true
return false
end
function fx(cw)
if(u[cw.e+cw.z][cw.f+cw.dd]=="w") return true
return false
end
function gg(cw)
for o=1,#cf do
if(cf[o].e==cw.e+cw.z and cf[o].f==cw.f+cw.dd) then
return cf[o]
end
end
return nil
end
function fy(cw)
if(u[cw.e+cw.z][cw.f+cw.dd]=="p") return"q"
if(u[cw.e+cw.z][cw.f+cw.dd]=="q") return"p"
if(u[cw.e+cw.z][cw.f+cw.dd]=="s") return"t"
if(u[cw.e+cw.z][cw.f+cw.dd]=="t") return"s"
return nil
end
function gc(gm)
for f=1,u.cd do
for e=1,u.cd do
if(u[e][f]==gm) return e,f
end
end
return nil,nil
end
function gn(e,f,l)
local go={}
go.e,go.f,go.l=e,f,l
add(cr,go)
end
function dk(cw)
local cy=cw.db
if(cy=="up"or cy=="down") gn(cw.dh+1,cw.di+7,5)
if(cy=="left") gn(cw.dh+2,cw.di+7,3)
if(cy=="right") gn(cw.dh+2,cw.di+7,3)
end
function gd(eg,e,f,gp,gq,de)
local gr={}
gr.eg=eg
gr.e,gr.f,gr.d=e,f,0
gr.gp,gr.gq=gp,gq
gr.de=de
gr.cn=0
add(ct,gr)
end
function fs(cy)
local z,dd=0,0
if(cy.e<cy.gp) z=1
if(cy.e>cy.gp) z=-1
if(cy.f<cy.gq) dd=1
if(cy.f>cy.gq) dd=-1
cy.e+=z*cy.de
cy.f+=dd*cy.de
if(abs(cy.e-cy.gp)<0.2 and abs(cy.f-cy.gq)<0.2) del(ct,cy)
end
function bg()
gs={}
gs.cn=0
gs.cj=0
gs.cl=1
gs.gt={5,6,12,8}
ea(gs.cl)
end
function bn()
gs.cn+=1
if(gs.cn>30 and gs.cn<210) then
gs.cl=max(0,gs.cl-.02)
if(gs.cn%10==0) gs.cj=min(gs.cj+1,13)
end
if(gs.cn>210) then
if(gs.cn%10==0) gs.cj=max(0,gs.cj-1)
end
if(gs.cn>270) gs.cl+=.01
if(gs.cn>450) p() bh()
end
function bu()
rectfill(0,0,127,127,7)
eb()
du(16,30)
local gu="matthias"
if(gs.cn>150) then
for o=1,8 do
for gv=0,3 do
local n=7-gv
local gw=gs.gt[gv+1]
local gx=gs.cn+o*4-n*16
local f=64+n+cos(gx/90)*16
local gy=sub(gu,o,o)
print(gy,32+o*7,f,gw)
end
end
end
local gz="a game by"
local ha=sub(gz,1,gs.cj)
ep(ha,"c",36,7,0)
ea(gs.cl)
end
function bh()
s.t="title"
hb={}
hb.co="in"
hb.cn=0
hb.cj=0
hb.f=-100
hb.cl=1
hb.hc=""
ea(hb.cl)
music(4)
end
function bo()
hb.cj+=1
if(hb.co=="in") then
hb.cl-=0.02
if(hb.cl<=0) hb.co="in2"
end
if(hb.co=="in2") then
hb.f+=1
if(hb.f==0) hb.co="menu"
end
if(hb.co=="menu") then
if(btnp(4)) then
if(peek(q+1)==1) then
hb.hc="select"
sfx(1)
else
hb.hc="level1"
music(-1)
sfx(2)
end
hb.co="out"
bm("game","started")
end
end
if(hb.co=="out") then
hb.cn+=1
if(hb.cn>60) then
if(hb.hc=="select") then
bi()
else
hb.cl+=.01
end
end
if(hb.cl>2) p() bk()
end
end
function bv()
rectfill(0,0,127,127,7)
eb()
ec(24,24)
ed(4,8)
ee(104,0)
ef(8,112)
ef(13,114)
ef(106,112)
ef(99,113)
ef(103,116)
spr(5,1*16+13,1*16+13)
spr(21,5*16+13,1*16+13)
line(5*16+13+2,4*16+13+7,5*16+13+6,4*16+13+7,6)
line(1*16+13+1,5*16+13+7,1*16+13+5,5*16+13+7,6)
spr(3,5*16+13,4*16+13+cos(hb.cj/30)*2-1)
spr(20,1*16+13,5*16+13+sin(hb.cj/30)*2-1)
spr(8,5*16+13,5*16+13)
du(6,20)
rectfill(33,53+hb.f,95,75+hb.f,1)
sspr(0,32,47,16,40,56+hb.f)
if(s.z) ep("dx",88,54+hb.f,7,9)
if(hb.co=="menu") print(s.w.." start game",38,115,5)
if(hb.co=="out") then
if(hb.cn%4!=0) print(s.w.." start game",38,115,5)
end
ea(hb.cl)
end
function bi()
s.t="select"
hd={}
hd.he=1
hd.hf=2
if(s.z) hd.hf=flr(ca.cc/16)+1
hd.hg={1,1}
hd.cn=0
hd.co="select"
hd.eh=0
hd.hh=ca.cc
hd.cl=0
hd.music=false
bm("game","level select")
end
function fh()
sfx(1)
bi()
hd.music=true
end
function bp()
hd.cn+=1
if(hd.co=="select") then
if(hd.music and hd.cn==15) music(4)
local hi=0
local hj=5
local hk=5
if(s.z) hk=4
if(hd.he==1) hi=1
if(hd.he==hd.hf) hj=4
hd.hg[1]=mid(hi,hd.hg[1],hj)
if(btnp(0)) hd.hg[1]=mid(hi,hd.hg[1]-1,hj) sfx(0)
if(btnp(1)) hd.hg[1]=mid(hi,hd.hg[1]+1,hj) sfx(0)
if(btnp(2)) hd.hg[2]=mid(1,hd.hg[2]-1,hk) sfx(0)
if(btnp(3)) hd.hg[2]=mid(1,hd.hg[2]+1,hk) sfx(0)
if(hd.cn>15 and btnp(4)) then
if(hd.hg[2]<5) then
if(hd.hg[1]==0) hd.he=max(0,hd.he-1) sfx(1)
if(hd.hg[1]>0 and hd.hg[1]<5) then
local eh=hd.hg[1]+(hd.hg[2]-1)*4+(hd.he-1)*16
if(eh>hd.hh and not s.z) bj() sfx(1)
if(eh<=hd.hh) hd.eh=eh hd.cn=0 hd.co="out"music(-1) sfx(2)
end
if(hd.hg[1]==5) hd.he=max(0,hd.he+1) sfx(1)
else
bj()
sfx(1)
end
end
end
if(hd.co=="out") then
if(hd.cn>60) hd.cl+=.01
if(hd.cl>1.5) p() s.u=hd.eh bk()
end
end
function bw()
rectfill(0,0,127,127,7)
eb()
print("select a level",37,16,5)
sspr(47,47,65,65,32,32)
ed(4,8)
ee(104,0)
ef(8,112)
ef(13,114)
ef(106,112)
ef(99,113)
ef(103,116)
if(hd.co=="select") print(s.w.." ok",55,115,5)
if(hd.co=="out") then
if(hd.cn%4!=0) print(s.w.." ok",55,115,5)
end
if(hd.he>1) then
sspr(47,47,17,17,7,56)
spr(40,12,61)
end
if(hd.he<hd.hf) then
sspr(47,47,17,17,104,56)
spr(56,109,61)
end
if(not s.z) then
rect(26,100,102,110,6)
print("get deluxe version",29,103,8)
end
for f=1,4 do
for e=1,4 do
local eh=e+(f-1)*4+(hd.he-1)*16
local i=6
if(hd.hg[1]==e and hd.hg[2]==f) i=12
if(peek(q+eh)==1) i=9
local hl=21
if(eh>99) hl=19
if(eh<=hd.hh) print(dy(eh),e*16+hl,f*16+22,i)
end
end
if(hd.hg[2]<5) then
if(hd.hg[1]==0) rect(9,58,9+12,58+12,12)
if(hd.hg[1]>0 and hd.hg[1]<5) rect(hd.hg[1]*16+18,hd.hg[2]*16+18,hd.hg[1]*16+18+12,hd.hg[2]*16+18+12,12)
if(hd.hg[1]==5) rect(106,58,106+12,58+12,12)
else
rect(26,100,102,110,12)
print("get deluxe version",29,103,12)
end
du(6,20)
ea(hd.cl)
end
function bj()
s.t="deluxe"
hm={}
hm.cn=0
ea(0)
bm("deluxe version","show infos")
end
function fi()
sfx(1)
music(-1)
music(4)
bj()
end
function bq()
hm.cn+=1
if(hm.cn>15 and btnp(4)) bi() sfx(1) hd.cn=15
end
function bx()
rectfill(0,0,127,127,7)
eb()
print("trails dx",47,16,9)
ed(4,8)
ee(104,0)
ef(8,112)
ef(13,114)
ef(106,112)
ef(99,113)
ef(103,116)
print(s.w.." awesome!",45,115,5)
ep(
"get the deluxe version\n"..
"of trails, including:\n\n"..
" over 100 levels\n"..
" more game mechanics\n"..
" larger maps\n"..
" higher difficulty","c",32,5,7)
ep("check out","c",80,5,7)
ep("pocketfruit . itch . io","c",87,7,9)
ep("for more info.","c",94,5,7)
end
function bl()
s.t="credits"
hn={}
hn.co="in"
hn.cn=0
hn.cj=0
hn.cl=1
ea(hn.cl)
music(9)
bm("credits","seen credits")
end
function bs()
if(hn.cn>360 and btnp(4) and hn.co!="out") hn.co="out"sfx(1)
if(hn.co=="in") then
hn.cl-=.01
if(hn.cl<=0) hn.co="credits"
end
if(hn.co=="credits") then
hn.cn+=1
if(hn.cn%10==0) hn.cj=min(hn.cj+1,27)
end
if(hn.co=="out") then
hn.cn+=1
hn.cl+=.01
if(hn.cl>=1.5) then
if(not s.z) then
bj()
else
bh()
end
end
end
end
function bz()
rectfill(0,0,127,127,7)
eb()
du(16,30)
local ho="together we achieve more! ‡"
ep(sub(ho,1,hn.cj),"c",32,5,7)
if(hn.cn>300) then
if(not s.z) then
ep("now check out trails dx!","c","c",5,7)
ep("              trails    ","c","c",7,1)
ep("                     dx ","c","c",7,9)
else
ep("thanks for playing!","c","c",7,8)
end
end
if(hn.cn>360) then
if(hn.co=="credits") print(s.w.." ok",55,80,5)
if(hn.co=="out") then
if(hn.cn%4!=0) print(s.w.." ok",55,80,5)
end
ep("a game by matthias falk","c",108,6,7)
end
ea(hn.cl)
end
function y()
local hp=stat(102)
if(hp==0 or hp=="www.lexaloffle.com") return true
return false
end
function bf()
local hq={
0,
'',
'127.0.0.1',
'localhost',
'lexaloffle.com',
'www.lexaloffle.com',
'pocketfruit.itch.io',
'playpico.com',
'www.playpico.com'
}
local hr=stat(102)
local eo=true
for h in all(hq) do
if(hr==h) eo=false
end
if(sub(hr,-14)=='.ssl.hwcdn.net') eo=false
return eo
end
function bt()
if(not hs) hs=stat(102)
cls()
print("you are playing this game from",0,0,8)
print("an unauthorized website.",0,6,8)
print("please visit",0,18,8)
print("pocketfruit.itch.io",0,24,7)
print("to play a legitimate copy.",0,30,8)
print("please help to avoid piracy",0,42,8)
print("and properly support the author",0,48,8)
print("of this game.",0,54,8)
print("thank you.",0,66,8)
print("domain: "..hs,0,78,9)
end
function cv()
dv={}
dv.eq=""
dv.ht=nil
dv.cn=0
dv.f=32
dv.hu=false
dv.dw=false
end
function hv(eq,ht)
cv()
dv.eq=eq
dv.ht=nil or ht
dv.dw=true
end
function dz()
if(dv.dw) then
dv.cn+=1
if(dv.cn<35) dv.f=max(0,dv.f-1)
if(dv.cn>30 and not dv.hw and(btn(4) or btn(5))) dv.hw=true sfx(1)
if(dv.hw) then
dv.f=min(32,dv.f+1)
if(dv.f>=32) then
dv.dw=false
if(dv.ht) dv.ht()
end
end
rectfill(0,112+dv.f,128,128,12)
print(dv.eq,4,114+dv.f,7)
pal(12,6)
local eg=74
if(not s.v) eg=78
spr(eg,114,120+dv.f)
pal(12,12)
end
end
function fk()
if(s.u==1) then
if(not bd.hx and u.co=="intro"and u.cn>160) then
bd.hx=true
hv("welcome! what a beautiful day!\nlet's play in the snow.",hy)
end
if(not bd.hz and cf[1].f==5 and cf[2].f!=5) then
bd.hz=true
hv("perfect! now move the red\nplayer with — to his mark.")
end
end
if(s.u==2) then
if(not bd.ia and u.co=="intro"and u.cn>160) then
bd.ia=true
hv("you can only move in the\ndirection you are facing.",ib)
end
end
if(s.u==4) then
if(not bd.ic and u.co=="intro"and u.cn>160) then
bd.ic=true
hv("did you notice? you can push\nother players around.")
end
end
if(s.u==6) then
if(not bd.id and u.co=="intro"and u.cn>160) then
bd.id=true
hv("you can check out the menu\nby pressing (enter).",ie)
end
end
if(s.u==16) then
if(not bd.ig and u.co=="intro"and u.cn>160) then
bd.ig=true
hv("let's invite more friends.\n” moves the green player.")
end
end
if(s.u==21) then
if(not bd.ih and u.co=="intro"and u.cn>160) then
bd.ih=true
hv("even more friends are coming!\nƒ moves the purple player.")
end
end
end
function hy()
hv("push "..s.w.." to move the blue\nplayer to the blue mark.")
end
function ib()
hv("in case you are stuck, you can\npush "..s.x.."+"..s.w.." to retry.")
end
function ie()
hv("you can go to level select and\nretry levels from there.")
end
function fj()
sfx(1)
end
function r()
cartdata("matthias_trails")
if(peek(q)==0) then
ii()
end
end
function fp(eh)
poke(q+eh,1)
end
function ii()
poke(q,1)
for o=1,256 do
poke(q+o,0)
end
end
do
local ij=' !"#%\'()*+,-./0123456789:;<=>?abcdefghijklmnopqrstuvwxyz[]^_{~}'
local ik={}
for o=1,#ij do
ik[sub(ij,o,o)]=o
end
local il=0x5f80
local df=0
local function im()
if il+df>0x5fff then assert(false,'event is too large.') end
end
local function io(ip)
im()
poke(il+df,ik[ip])
df+=1
end
local function iq(fe)
im()
poke(il+df,fe)
df+=1
end
local function ir()
im()
poke(il+df,255)
df=0
end
local function is(it)
iq(#it)
for o=1,#it do io(sub(it,o,o)) end
end
function bm(iu,iv,iw,ix)
iw=iw or""
ix=tostr(ix) or""
is(iu)
is(iv)
is(iw)
is(ix)
ir()
end
end
__gfx__
aaaaaaaaaa5500aaaa5500aaaaa500aaaa500aaaaaaaaaaa0000000000000000aaaaaaaaccccccccccccccca888888888888888aaaa222000aaaaaaaaaaaaaaa
aaaaaaaaa5cc110aa5cc110aaa5c110aa5c110aaaac1caaa0000000000000000aa55aaaaccaaaaaaaaaaacca88aaaaaaaaaaa88aaa22977421aaaaaaaaa6aaaa
aa7aa7aaa5111110a5111110a511110aa511110aac111caa0000000000000000a5555aaacaaaaaaaaaaaaaca8aaaaaaaaaaaaa8aaa24000041aaaaaaa66aaaaa
aaa77aaaaa00000aaa0ff00aaa0fff0aa5fff0aaa11111aa0000000000000000555555aacaaaaacccaaa6aca8aa6aa888aaaaa8aaa24497411aaaaaaaaaaaa6a
aaa77aaaaa0cc0aaaa0ff0aaaa0ff0aaaa0ff0aaac111caa0000000000000000aa55aaaacaa6aacccaaaaaca8aaaaa888aaaaa8aaa24244241aaaaaaaaaaa6aa
aa7aa7aaa00cc00aa00cc00aaaa0c00aa00c0aaaaac1caaa0000000000000000aa55aaaacaaa6acccaaaaaca8aa6aa888aaa6a8aaa24494741aaaaaaaaa6aaaa
aaaaaaaaaa0000aaaa0000aaaaa000aaaa000aaaaaaaaaaa0000000000000000aa55aaaacaaaaacccaaaaaca8aaaaa888aa6aa8aa7244444217aaaaaaaaaaaaa
aaaaaaaaaa0aa0aaaa0aa0aaaaa0a0aaaa0a0aaaaaaaaaaa0000000000000000aaaaaaaacaaaaacccaaaaaca8aaaaa888aaaaa8a742240041147aaaaaaaaaaaa
00000000aa5500aaaa5500aaaaa500aaaa500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaacaaaaacccaa6aac78aaaaa888aaaaa8a0022222222007aaaaaaaaaaa
00000000a599880aa599880aaa59880aa59880aaaa282aaaaaaaaaaaaaaaaaaaaa55aaaacaa6aaaaaaaaaaca8aaaaaaaaaaaaa8aa6000000006aaaaaaaaa6aaa
00000000a5888880a5888880a588880aa588880aa28882aaaaa9aaaaaaaeaaaaaa55aaaacaaaaacccaaaaaca8aa6aa888aaaaa8aaaa6666666aaaaaaaaaaa6aa
00000000aa00000aaa0ff00aaa0fff0aa5fff0aaa88888aaa9aaa9aaaeaaaeaaaa55aaaacaaaaacccaaaaaca8aaaaa888aaaaa8aaaaaaaaaaaaaaaaaaaaaaaaa
00000000aa0880aaaa0ff0aaaa0ff0aaaa0ff0aaa28882aaaaa9aaaaaaaeaaaa555555aacaaaaaaaaaaaaaca8aaaaaaaaaaaaa8aaaaaaaaaaaaaaaaaa6aa6aaa
00000000a008800aa008800aaaa0800aa0080aaaaa282aaaa9aaa9aaaeaaaeaaa5555aaaccaaaaaaaaaaacca88aaaaaaaaaaa88aaaaaaaaaaaaaaaaaaaaaa66a
00000000aa0000aaaa0000aaaaa000aaaa000aaaaaaaaaaaaaa9aaaaaaaeaaaaaa55aaaaccccccccccccccca888888888888888aaaaaaaaaaaaaaaaaaaaaaaaa
00000000aa0aa0aaaa0aa0aaaaa0a0aaaa0a0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00000000aa5500aaaa5500aaaaa500aaaa500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa333333333333333aeeeeeeeeeeeeeeeaaaaaadddaaaaaaaaaa6aaaaa
00000000a5bb330aa5bb330aaa5b330aa5b330aaaab3baaaaaaaaaaaaaaaaaaaaaa5aaaa33aaaaaaaaaaa33aeeaaaaaaaaaaaeeaaaaad7330aaaaaaaaaaaaaaa
00000000a5333330a5333330a533330aa533330aab333baaaaaaaaaaaaaaaaaaaa55aaaa3aaaaaaaaaaaaa3aeaaaaaaaaaaaaaeaaaad733730aaaaaaaa6aaaaa
00000000aa00000aaa0ff00aaa0fff0aa5fff0aaa33333aaaaa9aaaaaaaeaaaaa555555a3aaaaa333aa6aa3aeaaaaaeeeaaa6aeaaad33377370aaaaaaaaaaaaa
00000000aa0330aaaa0ff0aaaa0ff0aaaa0ff0aaab333baaa9aaa9aaaeaaaeaaa555555a3aaaaa333aaa6a3aeaa6aaeeeaa6aaeaad3b33333330aaaaaaaaaaaa
00000000a003300aa003300aaaa0b00aa00b0aaaaab3baaaaaa9aaaaaaaeaaaaaa55aaaa3aaaaa333aaaaa3aeaa6aaeeeaaaaaead333333333330aaaaaaaaaaa
00000000aa0000aaaa0000aaaaa000aaaa000aaaaaaaaaaaa9aaa9aaaeaaaeaaaaa5aaaa3aaaaa333aa6aa3aeaaaaaeeeaaaaaeaaa6666666666aaaaaaaaaaaa
00000000aa0aa0aaaa0aa0aaaaa0a0aaaa0a0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa3aaaaa333aaaaa3aeaaaaaeeeaaaaaeaaaaaaaaaaaaaaaaaaaaaaaaa
00000000aa5500aaaa5500aaaaa500aaaa500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa3aaaaa333aa6aa3aeaaaaaeeeaaaaaeaaaaaaaaaaaaaaaaaaaaaaaaa
00000000a5ee220aa5ee220aaa5e220aa5e220aaaae2eaaaaaf9faaaaafefaaaaaaa5aaa3a6aaaaaaaaaaa3aeaaaaaaaaaaaaaeaaaaaaaaaaaaaaaaaaa66aaaa
00000000a5222220a5222220a522220aa522220aae222eaaaf999faaafeeefaaaaaa55aa3aa6aa333aaaaa3aeaa6aaeeeaaaaaeaaaaaaaaaaaaaaaaaa6aaaaaa
00000000aa00000aaa0ff00aaa0fff0aa5fff0aaa22222aaf99999fafeeeeefaa555555a3aaaaa333aaaaa3aeaaa6aeeeaaaaaeaaaaaaaa6aaaaaaaaaaaaaaaa
00000000aa0220aaaa0ff0aaaa0ff0aaaa0ff0aaae222eaaf99999fafeeeeefaa555555a3aaaaaaaaaaaaa3aeaaaaaaaaaaaaaeaaaaaaaaaaa6aaaaaaaaa6aaa
00000000a002200aa002200aaaa0200aa0020aaaaae2eaaaaf999faaafeeefaaaaaa55aa33aaaaaaaaaaa33aeeaaaaaaaaaaaeeaaaaaaaaaaaaaaa6aaaaaaaaa
00000000aa0000aaaa0000aaaaa000aaaa000aaaaaaaaaaaaaf9faaaaafefaaaaaaa5aaa333333333333333aeeeeeeeeeeeeeeeaaaaaaaaaaaaaa6aaaaaaaaaa
00000000aa0aa0aaaa0aa0aaaaa0a0aaaa0a0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa6aaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaccccccaa888888aa333333aa222222aaccccccaa666666a
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaaaacccccccc888888883333333322222222cccccccc66666666
a77777777a777777aaaaa7777aaaa777aa77aaaaaa7777aaaaaa7777aa7aaaaaaaaaaaaaaaaaaaaacc7777cc887887883337733322277222ccc777cc66666666
a77777777a7777777aaaa7777aaaa777aa77aaaaa77777aaaaa77aaaaa7aaaaaaaaaaaaaaaaaaaaac77cc77c888778883377773327277272cc7ccccc66666666
aaaa77aaaa777a777aaaa7777aaaa777aa77aaaaa77aaaaaaaa7aaaaaa7aaaaaaaaaaaaaaaaaaaaac77cc77c888778883737737322777722cc7ccccc66666666
aaaa77aaaa777aa77aaa777777aaa777aa77aaaaa77aaaaaaa7aaaaaaa7aaa777aaaa777aaa7a77acc7777cc887887883337733322277222ccc777cc66666666
aaaa77aaaa777aa77aaa777777aaa777aa77aaaaa77aaaaaaa7aaaaaaa7aa7aaa7aaaaaa7aa77aaacccccccc888888883333333322222222cccccccc66666666
aaaa77aaaa777a777aaa77aa77aaa777aa77aaaaa777aaaaaa7aaaaaaa7aa7aaa7aaaaaa7aa7aaaaaccccccaa888888aa333333aa222222aaccccccaa666666a
aaaa77aaaa777777aaaa77aa77aaa777aa77aaaaaa7777aaaa7aaaaaaa7aa7aaa7aaaaaa7aa7aaaa000000000000000000000000000000000000000000000000
aaaa77aaaa777777aaa777aa777aa777aa77aaaaaaa777aaaa7aaaaaaa7aa77777aaa7777aa7aaaa000000000000000000000000000000000000000000000000
aaaa77aaaa777a77aaa77777777aa777aa77aaaaaaaa777aaa7aaaaaaa7aa7aaaaaa7aaa7aa7aaaa000000000000000000000000000000000000000000000000
aaaa77aaaa777a77aaa77777777aa777aa77aaaaaaaa777aaa7aaaaaaa7aa7aaaaaa7aaa7aa7aaaa000000000000000000000000000000000000000000000000
aaaa77aaaa777a777aa77aaaa77aa777aa77aaaaaaaa77aaaaa7aaaaaa7aa7aaaaaa7aaa7aa7aaaa000000000000000000000000000000000000000000000000
aaaa77aaaa777aa77a777aaaa777a777aa777777a77777aaaaa77aaaaa7aaa7aaaaa7aa77aa7aaaa000000000000000000000000000000000000000000000000
aaaa77aaaa777aa777777aaaa777a777aa777777a7777aaaaaaa7777aa7aaa7777aaa77a7aa7aaaa000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa666777766666666666666666777776666666666666677666666666666677766666666666777666666
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
a777777aaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaaaaaaaaaaaaaaaaaaa7aaaaaaaaaaaaaaaaaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaaa777aaaa777aaaaaa7a777aaaa777aaaa777a7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
aaaa7aaa7aaa7aa7aaa7aaaaa77aa77aaaaaa7aa77aa77a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7
aaaa7aaa7aaa7aa7aaa7aaaaa7aaaa7aaaaaa7aa7aaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7
aaaa7aaa7aaa7aa7aaa7aaaaa7aaaa7aaaaaa7aa7aaaa7a6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7
aaaa7aaa7aaa7aa7aaa7aaaaa7aaaa7aaa7777aa7aaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaa7aaa7aa7aaa7aaaaa7aaaa7aa7aaa7aa7aaaa7a7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaa7aaa7aa7aaa7aaaaa7aaaa7aa7aaa7aa7aaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaa7aaa7aa7aaa7aaaaa7aaaa7aa7aaa7aa7aaaa7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa7aaa7aaa7aa7aaa7aaaaa77aa77aa7aa77aa77aa77a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaa777aaaa777aaaaaa7a777aaaa77a7aaa777a7a6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa666666666666666666666676776666666666666777776666666666776666666666666667766666666
666666666666766666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
a66666666666766666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aa6666666666666666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaa666666666666666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaa66666666766666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
aaaaa6666666766666666666000000000000000000000007aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
aaaaa6666666766666666666000000000000000000000007aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
aaaaaa666666766666666666000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaa66666666666666666000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaa6666666666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaa666766666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
aaaaaaaaaa66766666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
aaaaaaaaaaaa766666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaa6a6666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaa6aa666666666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaaaaaaa666666600000000000000000000000666666777766666666666666766666666666666667766666666677776666767666666777666666666
aaaaaaaaaaaaaaaaaaa66666000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaa6aaaa6aaaaaaaaaa66000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaa66aaaaaaaaaaaaa000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaaaa6aaaaaaaaa000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
aaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
aaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
aaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
aaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000007aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000007aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000007aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
00000000000000000000000000000000000000000000000666666667766666666666677766666666666666667766666666667767666666666666666676666666
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000007aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000007aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
00000000000000000000000000000000000000000000000666667776666666666666667766666666666667776666666666666666776666666667776666666666
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000007aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa7aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
000000000000000000000000000000000000000000000006aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6aaaaaaaaaaaaaaa6
00000000000000000000000000000000000000000000000666666677766666666666666677766666666666777666666666666777766666666666666666776666
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
010100001554500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01060000185551d5451f545185001d5001f5001350716507185071b5071b5071d5071f50722507225070050700507005000050000500005000050000500005000050000500005000050000500005000050000500
010c000024555295452b5453054524545295352b5353053524535295252b5253052524525295152b5153051524515295152b5153051524515295152b515305152850528505285052850528505285050050500505
0103000018120191201b120001001b1000000000000000000000000000000000000018120191201d11022100231002f1002f100321000310018100191001b1000010000100000000000000000000000000000000
010400000c0000c0000c0000c0000c0000c0000c0000c0000c0000c00018630196201b6200c0000c0000c0000c0000c00018620196101b6102e6002f6003b6003b6003e6000f6002460025600276000c0000c000
01040000050000500005000050000500005000050000500005000050001d6301e6202062005000050000500005000050001d6201e610206102760028600346003460037600086001d6001e600206000500005000
01040000070000700007000070000700007000070000700007000070001f630206202262007000070000700007000070001f6202061022610296002a6003660036600396000a6001f60020600226000700007000
010600000f04116041200001d0412b0411d0002300032000310002f0002c00026000210001c000180001600000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000000000000000000000000c630000001861000600006000060000600006000060000600006000060000600006000060000600000000000000000000000000000000000000000000000000000000000000
01060000270412204120000110411f0411d0002300032000310002f0002c00026000210001c000180001600000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002175700007000070000700007000070000700707157570070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707
0110000018015180051d015180051f03518000180151800500005000050000500005000050000500005000050c0001800024015240000c0001800024025240000000500005000050000500005000050000500005
0110000018015002051d015002051f03500205140150020500205002050020500205002050020500205002050c000180002401524000160002200022015220000020500205002050020500205002050020500000
0110000000000000000c0000000000000000000c0000000000000000000c023000000c00000005186230000000000000000c0000000000000000000c0000000000000000000c0230000000000000001862300000
0110000000000000000c0000000000000000000c0230000000000000000c023000000c00000005186230000000000000000c0000000000000000000c0230000000000000000c0230000000000000001862300000
011000000001200002050123c00213012000020c01200002000020000200012000000000000000000120000000000000000c012000000c0000c0000c0120c0000000200002000120000000000000000001200000
011000000001200002050123c002130120000214012000020000200002080120000000000000000801200000000000000018012000000c0000c000160120c00000002000020a0120000000000000000a01200000
0110000018732007021d742007021f74200702247520070229752007022b75200702307521870200702007022e702007023070200702007020070200702007020070200702007020070200702007020070200702
01100000186151d6151f615186251d6251f625186351d6351f635186451d6451f6451865518655006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010c00000c331003000e331003000c331003000233102300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
01100000180450000518045000051c065000051804500005140450000514045000051b065000051404500005160450000516045000051d0650000516045000051104500005110450000518065000051104500005
011000000c024000040c0240000410024000040c02400004080240000408024000040f0240000408024000040a024000040a0240000411024000040a02400004050240000405024000040c024000040502400004
011000000c0530000000000000001865300000000000000000000000000c05300000186530000000000000000c053000000c000000001865300000000000000000000000000c0530c00018653000000000000000
011000000c0530000000000000001865300000000000000000000000000c05300000186530000000000000000c053000000c053000001865300000000000000000000000000c0530c05318653000000000000000
010c00000c055000050c055000050f0650000511055000050c055000050c055000050f0650000511055000050c055000050c055000050f0650000511055000050c055000050c055000050f065000051105500005
010c0000080550000508055000050f065000051105500005080550000508055000050f065000051105500005070550000507055000050f0650000511055000050f055000050e045000050c045150050a04500005
010c00000c0530000000000000000c6430000000000000000c053000000c04300000186430000000000000000c053000000c043000000c643000000c043000000c000000000c0530000018643000000000000000
010c00001803200002180320000200002000020000200002000020000200002000020000200002000020000218032000021803200002000020000200002000020000200002000020000200002000020000200002
010c00001b032000021b032000020000200002000020000200002000020000200002000020000200002000021d032000021d03200002000020000200002000021a032000021a0320000200002000020000200002
010c00001f032070021f032070020700207002070020700207002070020700207002070020700207002070021f032070021f03207002070020700207002070020700207002070020700207002070020700207002
010c00001b032000021b0320000200002000020000200002050020500205002050020500205002050020500222032050022203205002050020500205002050021f032050021f0320500205002050020500205002
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
01 0b 0d 43 44
00 0b 0d 0f 44
00 0c 0e 10 44
02 0b 0d 0f 44
00 14 42 43 44
00 14 16 43 44
03 14 17 15 44
04 11 12 43 44
04 13 42 43 44
00 18 42 43 44
00 19 42 43 44
00 18 1a 43 44
00 19 1a 43 44
00 18 1a 1b 44
00 19 1a 1c 44
01 18 1a 1b 44
00 19 1a 1c 44
00 18 1a 1b 1d
02 19 1a 1c 1e
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
