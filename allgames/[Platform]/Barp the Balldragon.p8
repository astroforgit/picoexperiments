pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- barp the balldragon

a,b,
c,d=
0,
1,
1,
{0,0,0,0}
e=0
f={0,0xffff}
g={0xffff,0,h=f}
i={0,1,h=g}
j={1,0,h=i}
f.h=j
k="abcdefghijklmnopqrstuvwxyz1234567890`~!@#$%^&*()-_=+[{]}|;:',./?"
function l()
m={}
for n=1,64 do
m[sub(k,n,n)]=n-1
end
end
function o(p,q)
q,r,s=
q or 6,{},1
if type(p)=="string"then
for n=1,#p do
local t=m[sub(p,n,n)]
for u=0,q-1 do
add(r,v(band(t,shl(1,u))))
end
end
else
for n=p,p+q-1 do
local t=peek(n)
for u=0,7 do
add(r,v(band(t,shr(128,u))))
end
end
end
end
function w(q)
q=q or 5
local x=0
for n=1,q do
x*=2
x+=r[s]
s+=1
end
return x
end
function y()
return w(1)==1
end
function z(q,ba)
if y() then
return w(q)
else
return ba
end
end
function bb()
o(bc)
bc={}
local bd=w(8)
for n=1,bd do
local be,bf={},w(4)
be.bg=w(4)
for n=1,bf do
add(be,w(8))
end
be.bd=be[1]
add(bc,be)
end
end
function bh()
o(bi)
bi={}
local bj=w(4)
for n=1,bj do
local bk={}
for bl=1,20 do
bk[bl-1]=w(4)
end
add(bi,bk)
end
o(bm)
bm,bj=
{},
w(8)
for n=1,bj do
local bk={}
for bl=1,16 do
if y() then
bk[bl-1]=w()
end
end
add(bm,bk)
end
end
function bn()
o(bo)
bo={}
local bd=w(8)
for n=1,bd do
local bp={
map=w(7),
bq=w(8),
br=w(8),
b=y()
}
bo[n]=bp
end
end
function bs()
for n=1,#bt do
o(bt[n])
bt[n]={
bu=w(8),
bv={
w(3),
w(3),
w(3),
w(3)
}
}
end
end
function bw()
local bx={
by,
bz,
ca,
cb,
cc
}
o(cd)
cd={}
local bj=w(8)
for n=1,bj do
local ce={
cf=w(8),
cg=bm[w()],
ch=w(8),
ci=bx[w(3)],
cj=y(),
ck=y()
}
add(cd,ce)
end
end
function cl()
for cm,be in pairs(cn) do
o(be[1])
be.ck=z(6)
be.co=y()
be.cg=z(6)
be.cp=z(5)
be.cq=z(5)
be.cr=z(5)
be.cs=y()
be.ct=z(8)
be.cu=z(4)
end
for cm,be in pairs(cn) do
be.cg=bm[be.cg]
end
end
function cv(cw,cx,cy)
o(cw,cx)
local bd=w(6)
for n=1,bd do
local p,cx=
"",
w(10)
for u=1,cx do
local cz=w(6)+1
p=p..sub(k,cz,cz)
end
add(cy,p)
end
end
function da()
cv(0x2000,0x1000,db)
cv(0x3200,0x0c7c,dc)
end
function dd()
for bq=0,15 do
for br=0,15 do
mset(16+bq,br,106+sget(72+bq,48+br))
mset(32+bq,br,123+sget(111,32+br))
mset(64+bq,br,196+sget(112+bq,32+br))
end
end
end
de=false
function df()
de,dg,dh=
true,
16,
0xffff
end
function di()
de,dg,dh=
true,
0,
1
end
function dj()
local br=56+dk(dg,4)
for n=1,15 do
pal(n,sget(8+n,br),1)
end
dg+=dh
if dg==0 or dg==16 then
de=false
end
end
function dl()
if dm==3 then
circfill(64,48,20,10)
elseif dm>0 then
map(dm*16,0,0,0,16,16)
end
end
function dn(dp)
if dp<1 then
music(0xffff,1500)
return
elseif dp!=dq then
if dp<60 then
o(dc[dp])
local dr,ds=
w(7),w(7)
local bj
for n=1,dr*4 do
poke(0x30ff+n,w(8))
end
local dt,du={},{}
bj=w()
for n=1,bj do
add(dt,w(9))
end
bj=w()
for n=1,bj do
add(du,w(6))
end
for dv=0,ds do
local cw,dw,dx=
0x3200+dv*68,
w(6),
w(1)
for n=cw,cw+63,2 do
local dy,dz=0,0
if y() then
local ea,bk=dt[w()],
du[w()]
dy,dz=
ea*64+bk,
ea/4
end
poke(n,dy)
poke(n+1,dz)
end
poke(cw+65,dw)
poke(cw+66,0)
poke(cw+67,dx*32)
end
music(0,0,12)
dq=dp;
else
reload(0x3100,0x3100,2432)
music(dp,15)
dq=0xffff;
end
end
end
function eb(bl,be,t)
if(bl) return be
return t
end
function v(ec)
return eb(ec==0,0,sgn(ec))
end
function dk(ed,ee)
return flr(ed/(ee or 8))
end
function ef()
end
function eg()
eh,ei=
mid(ej-64,0,ek*8-128),
mid(el-64,0,em*8-128)
en,eo=
dk(eh),
dk(ei)
camera(eh,ei)
end
function ep()
ej,el=
eq.bq+4,
eq.br+4
eg()
end
function er(be)
if(be.bq<0) be.bq+=128
if(be.bq>=128) be.bq-=128
end
function es()
if e<2 then
ej,el=
eq.bq+4,
eq.br+4
elseif e==2 then
ej+=0.3
el=eq.br+4
else
ej=eq.bq+4
el-=0.3
end
eg()
if e==1 then
er(eq)
foreach(et,er)
foreach(eu,er)
foreach(ev,er)
foreach(ew,er)
else
eq.bq,eq.br=
mid(eq.bq,eh,eh+120),
max(eq.br,ei-16)
if ex(eq.bq+7,eq.br,8) then
ey(eq,true)
end
end
end
function ez(bk)
fa=bi[bk]
end
function fb(bk)
if fc!=bk then
fc=bk
if bk then
for n=0,15 do
if bk[n] then
palt(n,false)
pal(n,fa[bk[n]])
else
palt(n,true)
end
end
else
for n=0,15 do
palt(n,false)
pal(n,fa[n])
end
palt(0,true)
end
end
end
function fd(bq,br)
return fe[bq] and
fe[bq][br]
end
function ff(bd)
local p=db[bd]
local cq,cr,fg
o(p)
fh,fi,
fj,a,
dm,fk,fl,
fm=w(3),w(3),
w(4),w(8),
w(4),w(1),
w(3)+1,w(7)
if fk==0 then
cq,cr=w(),w(2)
fg=cq
else
cq,cr=w(2),w()
fg=cr
end
ek,em,e=
cq*8+8,
cr*8+8,
w(2)
fn={}
fo={}
for n=0,fg do
fn[n]={}
local fp=w()
for u=1,fp do
bd=w(6)
local ce={
fq=n,
fr=cd[bd]
}
if fk==0 then
ce.bq,ce.br=w(3),w()
else
ce.bq,ce.br=w(),w(3)
end
ce.cq,ce.cr=w(4)+1,w(4)+1
add(fn[n],ce)
end
fo[n]={}
local fs=w(3)
for u=1,fs do
bd=w()
local be={
fq=n,
ft=bd
}
if fk==0 then
be.bq,be.br=w(3),w()
else
be.bq,be.br=w(),w(3)
end
be.fu,be.fv=w(1),
w(cn[bd].cu)
add(fo[n],be)
end
end
fw()
fx()
end
function fy()
ez(fh)
fb()
local g,ed=dk(eh),
dk(ei)
for bq=g,g+16 do
for br=ed,ed+16 do
local fz=fd(bq,br)
if fz and fz.ga>0 then
fb(fz.cg)
local ga=fz.ga
if fz.ck then
ga+=dk(gb)
end
spr(ga,bq*8,br*8)
end
end
end
end
function gc(bq,br,i)
br=mid(dk(br),0,em-1)
bq=dk(bq)
if e==1 then
bq=(bq+16)%16
elseif bq<0 or bq>=ek then
return true
end
local fz=fd(bq,br)
if fz then
if i and fget(fz.ga,1) then
return true
end
return fget(fz.ga,0)
end
end
function gd(bq,br,cq,ed)
bq=max(bq,0)
for n=band(bq,2040),band(bq+cq-1,2040),8 do
if(gc(n,br,ed)) return true
end
end
function ex(bq,br,cr)
br=max(br,0)
for n=band(br,2040),band(br+cr-1,2040),8 do
if(gc(bq,n)) return true
end
end
function ge(ce)
if fk==0 then
return ce.fq*8+ce.bq,ce.br
end
return ce.bq,ce.fq*8+ce.br
end
function by()
return 0
end
function ca(bq,br,gf,gg,gh,gi)
if(bq-gf>=gi-br) return 0
end
function cb(bq,br,gf,gg)
if(bq-gf<=br-gg) return 0
end
function bz(bq,br,gf,gg)
if(br>gg) return 16
return 0
end
function cc(bq,br,gf,gg,gh,gi)
local ga=0
if(bq>gf) ga+=2
if(bq<gh) ga+=1
if(br>gg) ga+=32
if(br<gi) ga+=16
return ga
end
function gj()
fe={}
for bq=0,ek-1 do
fe[bq]={}
for br=0,em-1 do
fe[bq][br]={ga=a}
end
end
end
function fw()
gj()
for gk=0,#fn do
local gl=fn[gk]
for ce in all(gl) do
gm(ce,ge(ce))
end
end
end
function gm(gn,gf,gg)
local gh,gi=min(gf+gn.cq-1,ek-1),
min(gg+gn.cr-1,em-1)
for bq=gf,gh do
for br=gg,gi do
local ga=gn.fr.ci(bq,br,gf,gg,gh,gi)
if ga then
fe[bq][br]={
ga=gn.fr.cf+ga,
go=gn,
cg=gn.fr.cg,
ck=gn.fr.ck
}
end
end
end
if gn.fr.cj then
for bq=gf-1,gh+1 do
for br=gg-1,gi+1 do
if gp(bq,br,gn) then
local ga=gn.fr.cf
if(bq==0 or gp(bq-1,br,gn)) ga+=2
if(bq==ek-1 or gp(bq+1,br,gn)) ga+=1
if(br==0 or gp(bq,br-1,gn)) ga+=32
if(br==em-1 or gp(bq,br+1,gn)) ga+=16
fe[bq][br].ga=ga
end
end
end
end
end
function gp(bq,br,gn)
local fz=fd(bq,br)
if fz and fz.go then
return fz.go.fr==gn.fr
end
end
function fx()
gq={}
for gk=0,#fo do
local gr=fo[gk]
for be in all(gr) do
gs(be,ge(be))
end
end
end
function gs(be,bq,br)
if(not gq[bq]) gq[bq]={}
gq[bq][br]={
ft=be.ft,
fu=be.fu,
fv=be.fv
}
end
function gt(bq,br)
local fz=gq[bq] and
gq[bq][br]
if fz then
if fz.gu and not fz.gu.gv then
return
end
local be=gw(fz.ft,bq*8,br*8,fz.fv)
be.fu=fz.fu
fz.gu=be
add(eb(be.cp,et,ew),be)
end
end
function gx(br)
for bq=en-4,en+19 do
gt(bq,br)
end
end
function gy(bq)
for br=eo-4,eo+19 do
gt(bq,br)
end
end
function gz(ha)
for be in all(ha) do
if be.bq<eh-128 or
be.bq>eh+256 or
be.br<ei-128 or
be.br>ei+256 then
be.gv=true
end
if(be.gv) del(ha,be)
end
end
hb={
bq=0,br=0,
cq=8,cr=8,
fu=0,
ck=1,
hc=0,
hd=0,
cu=0,
he=ef,
hf=ef,
hg=0,
hh=0
}
hb.__index=hb
function hi(hj,hk)
if hj.hl or hk.hl then
return false
end
return hj.bq+hj.cq>hk.bq and
hk.bq+hk.cq>hj.bq and
hj.br+hj.cr>hk.br and
hk.br+hk.cr>hj.br
end
function hm(be,hn)
return not eb(hn<0,
ex(be.bq+hn,be.br,be.cr),
ex(be.bq+be.cq-1+hn,be.br,be.cr))
end
function ho(be,fu)
if(fu[1]!=0) return hm(be,fu[1])
return hp(be,fu[2])
end
function hq(be,hn)
if hm(be,hn) then
local br=be.br+be.cr
local bq=be.bq
if(hn>0) bq+=be.cq
return gc(bq,br,true)
end
end
function hp(be,hn)
if hn<=0 then
return not gd(be.bq,be.br+hn,be.cq)
else
local ed=(be.br+be.cr-1)%8+hn>=8
return not gd(be.bq,be.br+be.cr-1+hn,be.cq,ed)
end
end
function hr(be,hn)
be.bq+=hn
if(be.cs) return
if hn<0 then
if ex(be.bq,be.br,be.cr) then
be.bq=band(be.bq+7,2040)
end
elseif hn>0 then
if ex(be.bq+be.cq-1,be.br,be.cr) then
be.bq=band(be.bq+be.cq,2040)-be.cq
end
end
end
function hs(be,hn)
if hq(be,hn) then
be.bq+=hn
elseif hn<0 then
be.bq=band(be.bq+7,2040)
else
be.bq=band(be.bq+be.cq,2040)-be.cq
end
end
function ht(be,hn)
local ed=(be.br+be.cr-1)%8+hn>=8
be.br+=hn
if(be.cs) return
if hn<0 then
if gd(be.bq,be.br,be.cq) then
be.br=band(be.br+7,2040)
end
elseif hn>0 then
if gd(be.bq,be.br+be.cr-1,be.cq,ed) then
be.br=band(be.br+be.cr,2040)-be.cr
end
end
end
function hu(be,fu)
if fu[1]!=0 then
hr(be,fu[1])
else
ht(be,fu[2])
end
end
function hv(be,hn)
if(be.fu==1) hn=-hn
return be,hn
end
function hw(be)
be.fu=abs(be.fu-1)
end
function hx(be,hn)
hr(hv(be,hn))
if not hm(hv(be,hn)) then
hw(be)
end
end
function hy(be,hn)
hs(hv(be,hn))
if not hq(hv(be,hn)) then
hw(be)
end
end
function hz(be)
if(be.ia) return
ht(be,be.ib)
be.ib=min(be.ib+0.15,7)
if(not hp(be,v(be.ib)) or be.ia) be.ib=0
end
function ic(be)
be.br+=be.ib
be.ib=min(be.ib+0.15,7)
end
function id(be)
if(be.ia) return false
if(be.ib<0 or hp(be,1)) return true
end
function ie(be,ig,ih)
be.hg+=1
be.br=be.ii+ig*sin(be.hg/ih)
end
function ij(be)
be.gb+=1
if be.gb==be.ck.bg then
be.gb=0
be.ik=(be.ik+1)%#be.ck
end
end
function il(be,im)
if(be.co) return
fb(be.cg)
local ea=be.ck[be.ik+1]+be.hc
local ib=not fget(ea,2)
if be.hd%4<2 then
spr(
ea,
be.bq,be.br+im,
be.cq/8,be.cr/8,
be.fu==1 and ib,be.flip)
if e==1 and be.bq+be.cq>128 then
spr(
be.ck[be.ik+1]+be.hc,
be.bq-128,be.br+im,
be.cq/8,be.cr/8,
be.fu==1 and ib,be.flip)
end
end
end
function he(be)
be.he(be)
ij(be)
if(be.hd>0) be.hd-=1
if(be.ct) then
be.ct-=1
if be.ct<=0 then
be.gv=true
if be.io then
ip(be.io,be.bq,be.br)
end
end
end
end
function iq(be,ck)
be.ck=bc[ck]
be.ik=0
be.gb=0
end
function gw(ir,bq,br,fv)
local fr=cn[ir]
local be={
bq=bq,
br=br,
is=0,
ib=0,
hd=0,
fr=fr,
he=fr[2],
fv=fv
}
setmetatable(be,fr)
iq(be,cn[ir].ck)
if(be[3]) be[3](be,fv)
return be
end
function ip(ft,bq,br)
local be=gw(ft,bq,br)
add(ew,be)
return be
end
function it(ft,bq,br,fu)
local be=gw(ft,bq,br)
be.fu=fu
be.iu=it
add(ev,be)
return be
end
function iv(ft,bq,br,fu)
local be=gw(ft,bq,br)
be.fu=fu
be.iu=iv
add(eu,be)
return be
end
function iw(bk)
local ix=btn(0) and not btn(1)
local iy=btn(1) and not btn(0)
local iz=0.5
if(id(bk)) iz=0.25
if ix then
bk.is=max(bk.is-iz,-0.9)
elseif iy then
bk.is=min(bk.is+iz,0.9)
elseif bk.is!=0 then
if not id(bk) then
bk.is=mid(0,bk.is+0.15,bk.is-0.2)
end
end
if hm(bk,v(bk.is)) then
hr(bk,bk.is)
else
bk.is=0
end
if bk.is>0 then
bk.fu=0
elseif bk.is<0 then
bk.fu=1
elseif iy then
bk.fu=0
elseif ix then
bk.fu=1
end
end
function ja(bk)
local bq,br=bk.bq,bk.br
local jb=bk.bq-bk.jc
if jd=="beam"then
sfx(59)
else
sfx(62)
end
if jd!="3way"then
if(jd=="beam") br-=7
if(bk.fu==0) bq+=3
local cq=it(jd,bq,br+3,bk.fu)
cq.ib=rnd(1)-2
cq.is=jb
else
local cq=it("straight_ball",bq,br,bk.fu)
cq.is=2
cq.je=jb
cq=it("straight_ball",bq,br,bk.fu)
cq.jf=1.4
cq.is=1.4
cq.je=jb
cq=it("straight_ball",bq,br,bk.fu)
cq.jf=-1.4
cq.is=1.4
cq.je=jb
end
end
function jg(bk)
if(jh) return
local ji=bk.is==0
local jj=id(bk)
iw(bk)
local jk=eq.ia
if jk then
if bk.bq+7<jk.bq or
bk.bq>jk.bq+jk.cq-1 then
jl()
end
end
if btnp(4) then
if id(bk) then
if jm then
jm=false
bk.ib=-2.2
sfx(63)
end
else
bk.ib=-2.8
sfx(63)
jl()
jn=true
end
end
if btn(5) then
if bk.jo<2 then
bk.jo=bk.jp
bk.hc=16
ja(bk)
bk.jp=min(bk.jp+2,60)
end
elseif bk.jp>15 then
bk.jp-=1
end
if(bk.ib<-0.5 and not btn(4)) bk.ib=-0.5
hz(bk)
if bk.jo>0 then
bk.jo-=1
if(bk.jo==0) bk.hc=0
end
if bk.br>=ei+144 then
ey(bk,false)
end
if id(bk) then
if(not jj) iq(bk,3)
elseif jj then
if(jq) jm=true
if bk.is==0 then
iq(bk,1)
else
iq(bk,2)
end
elseif ji then
if(bk.is!=0) iq(bk,2)
elseif bk.is==0 then
iq(bk,1)
end
bk.jc=bk.bq
bk.jr=bk.br
end
function js(bk)
ic(bk)
bk.hg-=1
if(bk.hg==0) bk.gv=true
end
function jt(bk)
if id(bk) then
hz(bk)
if(not id(bk)) iq(bk,5)
else
if bk.ju>0 then
bk.ju-=1
else
bk.ib=-2
bk.ju=8
iq(bk,7)
end
end
if bk.hg>0 then
bk.hg-=1
if(bk.hg==0) bk.hg=-180
else
if bk.hg==-180 and not bk.jv then
dn(62)
bk.jv=true
end
bk.hg+=1
if bk.hg==0 then
jw=true
di()
end
end
end
function jx(bk)
sfx(60)
jy-=1
if jy<=0 then
ey(bk,true)
else
bk.hd=60
end
end
function ey(bk,jz)
jy=0
iq(bk,4)
bk.hc=0
bk.he=js
bk.hl=true
bk.hg=180
if(jz) bk.ib=-3
jl()
dn(63)
end
function ka(kb)
iq(eq,5)
eq.hc,
eq.he,
eq.ju=
0,
jt,
8
eq.hl=true
music(0xffff,100)
if kb then
eq.hg=30
else
eq.hg=-180
end
end
function kc(jk)
if(eq.ia or eq.ib<0) return
if eq.bq+eq.cq>=jk.bq and
eq.bq<=jk.bq+jk.cq and
eq.br+eq.cr>=jk.br and
eq.br+eq.cr-2-eq.ib<jk.br then
eq.ia=jk
if(jq) jm=true
jk.kd=eq
eq.br=jk.br-8
eq.ib=0
if eq.is==0 then
iq(eq,1)
else
iq(eq,2)
end
end
end
function jl()
if eq.ia then
eq.ia.kd=nil
eq.ia=nil
end
end
function ke(kf,kg,bq,br,is,jf)
local cq=iv(kf,kg.bq,kg.br+br,kg.fu)
if kg.fu==0 then
cq.bq+=bq
else
cq.bq+=kg.cq-bq-cq.cq
end
return cq
end
function kh(be)
be.hd=30
ki(be)
end
function kj(be,cq)
be.he=kk
be.ib=-1.3
be.hd=30
be.kl=eb(cq.fu==0,1,0xffff)
end
function kk(be)
hr(be,be.kl)
hz(be)
if not id(be) then
be.he=be.fr[2]
ki(be)
end
end
function ki(be)
be.cp-=1
if be.cp<=0 then
ip("death",be.bq,be.br)
sfx(53)
be.gv=true
end
end
function km(be)
if eq.bq>be.bq+4 then
be.fu=0
else
be.fu=1
end
end
function kn(be)
if be.hg>0 then
be.hg-=1
if(be.hg==0) iq(be,24) be.ib=-1.5
elseif id(be) then
hr(hv(be,1))
else
hs(hv(be,0.5))
if not hm(hv(be,1)) then
hw(be)
elseif not hq(hv(be,1)) then
if hp(be,0xffff) then
iq(be,22)
be.hg=30
else
hw(be)
end
end
end
local ko=id(be)
hz(be)
if(ko and not id(be)) iq(be,23)
end
function kp(be)
hz(be)
if id(be) then
hx(be,0.5)
else
hy(be,0.5)
end
end
function kq(be)
be.br+=6
be.hg=90
end
function kr(be)
local ga=(be.hg+1)%240
be.hg=ga
if ga==166 then
km(be)
be.hl=false
elseif ga>166 and
ga<180 and
ga%2==0 then
be.br-=1;
be.cr+=1;
elseif ga==210 then
ke("bouncy_ball",be,5,0)
elseif ga>210 and
ga<224 and
ga%2==0 then
be.br+=1;
be.cr-=1;
elseif ga==224 then
be.hl=true
end
end
function ks(be)
if be.hg>0 then
be.hg-=1
if be.hh==2 and be.kt then
be.kt.br-=0.25
end
elseif not be.kt or be.kt.gv then
be.kt=gw("fish",be.bq,be.br+8)
add(et,be.kt)
be.hh=1
elseif be.hh==1 then
if abs(eq.bq-be.bq)<=32 then
be.hh=2
be.hg=32
end
else
be.kt.ib=-5
be.kt.he=ic
be.hg=100
end
end
function ku(be)
hz(be)
hx(be,0.6)
end
function kv(be)
if be.hg<60 then
be.hg+=1
else
local iy=gw("roller",be.bq,be.br)
add(et,iy)
iy.fu=be.fu
be.hg-=120
end
end
function kw(be)
be.hg+=1
if be.hg>=120 then
local t=ke("bomb",be,5,0)
t.is+=rnd()-0.5
t.ib,be.hg=
0xfffe,
rnd(20)
end
end
function kx(be)
hz(be)
if id(be) then
hx(be,1.6)
else
hy(be,1.6)
if(jn) be.ib=-2
end
end
function ky(be)
if ho(be,be.kz.h) then
be.kz=be.kz.h
end
hu(be,be.kz)
end
function la(be)
be.ii=be.br
end
function lb(be)
km(be)
ie(be,20,180)
end
function lc(be)
kh(be)
be.he=ld
be.hf=kh
be.hg=0
iq(be,36)
end
function ld(be)
if be.hg<30 then
hr(hv(be,0xffff.8))
be.hg+=1
else
hr(hv(be,1.5))
if be.br<eq.br then
ht(be,0.4)
elseif be.br>eq.br then
ht(be,0xffff.9999)
end
end
end
function le(be)
be.bq+=be.is
ie(be,24,120)
end
function lf(be)
be.bq=eq.bq
be.br=eq.br
if be.hg<140 then
be.hg+=1
else
local ib
if eq.bq>ek*8-40 or
eq.bq>40 and rnd()<0.5 then
ib=gw("flier3",eh-8,eq.br+rnd(48)-24)
ib.is,ib.fu=
0.8,
0
else
ib=gw("flier3",eh+128,eq.br+rnd(48)-24)
ib.is,ib.fu=
0xffff.333,
1
end
ib.ii=ib.br
add(et,ib)
be.hg=0
end
end
function lg(be)
if be.hh==0 then
if abs(eq.bq-be.bq)<40 then
be.hh=1
end
elseif be.hh==1 then
if eq.br>=be.br then
be.hh=2
end
elseif be.hh==2 then
hz(be)
if be.br>eq.br-16 then
be.hh=3
iq(be,35)
if be.bq<eq.bq then
be.fu=0
else
be.fu=1
end
end
else
hr(hv(be,0.6))
if be.br<eq.br-1 then
ht(be,0.4)
elseif be.br>eq.br+1 then
ht(be,0xffff.a)
end
end
end
function lh(be)
be.br-=4
end
function li(be)
be.he,be.hf,be.cr=
hz,
ef,
8
be.br+=4
iq(be,38)
sfx(55)
for n=1,4 do
local ea=gw("shard",be.bq,be.br)
add(ew,ea)
end
end
function lj(be)
be.is,be.ib=
rnd(1)-0.5,
0xfffe-rnd(1)
end
function lk(be)
ic(be)
be.bq+=be.is
end
function ll(be)
km(be)
if id(be) then
hz(be)
hr(hv(be,be.is))
else
if abs(eq.bq-be.bq)<32 then
be.is,be.ib=
0xffff,
0xfffe.8
elseif abs(eq.bq-be.bq)>60 then
be.is,be.ib=
1,
0xfffe.8
end
end
if be.hg<90 then
be.hg+=1
if be.hg>60 then
if be.hg%4<2 then
be.cg=bm[13]
else
be.cg=bm[12]
end
end
else
iv("beam",be.bq,be.br-4,be.fu)
sfx(59)
be.hg=0
end
end
function lm(be,cq)
be.hg,be.cg=
min(be.hg,60),
bm[12]
kj(be,cq)
end
function ln(be)
local cq=gw("boss_watcher")
cq.lo=be
add(ew,cq)
end
function lp(be)
local t=ke("ball",be,6,0)
t.ib-=2
t.is-=0.5
t=ke("ball",be,6,0)
t.ib-=2
t.is+=0.5
end
function lq(be)
local t=ke("bomb",be,6,0)
t.ib-=2
end
function lr(be)
if id(be) then
hz(be)
hr(be,be.is)
if not id(be) then
be.is=0
iq(be,45)
end
else
km(be)
be.hg+=1
if be.hg==60 then
iq(be,47)
be.lt(be)
elseif be.hg==85 then
iq(be,45)
elseif be.hg==120 then
be.hg=0
be.ib,be.is=
rnd(2)-4.5,
0.35+rnd(0.5)
iq(be,46)
if(be.fu==1) be.is*=0xffff
end
end
end
function lu(be)
if(eq.gv or id(eq)) return
if be.lo.gv then
ka(true)
be.gv=true
end
end
function lv(be)
sfx(61)
local lw=be.iu("explosion",be.bq,be.br,be.fu)
lw.ej,lw.el,lw.count,be.gv=
be.bq,
be.br,
10,
true
end
function lx(be)
ip("wpn_death",be.bq,be.br)
be.gv=true
end
function ly(lz,bq,br)
bq,br=dk(bq),dk(br)
local fz=fd(bq,br)
if fz then
local ib=band(lz,fget(fz.ga))
if ib!=0 then
if fz.ma then
fe[bq][br]=fz.ma
else
fz.ga=a
end
ip("death",bq*8,br*8)
return true
end
end
end
function mb(be,is)
if not hm(be,sgn(is)) then
local jb=0xffff
if(is>0) jb=6
if ly(128,be.bq+jb,be.br) or
ly(128,be.bq+jb,be.br+4) then
be.gv=true
end
return true
end
end
function mc(be,jf)
if not hp(be,v(jf)) then
local md=0xffff
if(jf>0) md=6
if ly(128,be.bq,be.br+md) or
ly(128,be.bq+4,be.br+md) then
be.gv=true
end
return true
end
end
function me(be)
local is=1+be.is
if(be.fu==1) is-=2
hr(be,is)
local ib=be.ib
hz(be)
if mb(be,is) then
if be.mf then
hw(be)
be.is=-be.is
else
be.gv=true
end
end
if not be.gv and
mc(be,ib) and
ib>0 then
if be.mf then
be.ib=-ib*0.8
else
be.gv=true
end
end
if be.gv then
if be.mg then
sfx(61)
local lw=be.iu("explosion",be.bq,be.br,be.fu)
lw.ej,lw.el,lw.count=
be.bq,
be.br,
10
else
lx(be)
end
end
end
function mh(be)
local is=be.is
if(be.fu==1) is=-is
is+=be.je
hr(be,is)
if(mb(be,is)) be.gv=true
if be.jf and not be.gv then
ht(be,be.jf)
if(mc(be,be.jf)) be.gv=true
end
if be.gv then
ip("wpn_death",be.bq,be.br)
end
end
function mi(be)
if be.fu==0 then
be.bq+=3
else
be.bq-=3
end
end
function mj(be)
ly(192,be.bq+3,be.br+3)
if be.count>0 and be.ct==15 then
local mk=be.iu("explosion",be.ej+rnd(16)-8,be.el+rnd(16)-8)
mk.fu,mk.ej,mk.el,mk.count=
be.fu,
be.ej,
be.el,
be.count-1
end
end
function ml(n)
if n.kf then
sfx(54)
jd=n.kf
mm=n.ck[1]
mn=1799
elseif n.type=="boots"then
sfx(54)
jq=true
eq.cg=bm[12]
jm=true
elseif n.type=="heart"then
sfx(57)
if(jy<3) jy+=1
elseif n.type=="heart2"then
sfx(58)
jy=5
else
sfx(56)
if(mo<9) mo+=1
end
n.gv=true
del(mp,n)
end
function mq()
mm=nil
jd="ball"
end
function mr(be)
if abs(be.bq-eq.bq)<4 and
abs(be.br+8-eq.br)<2 and
btnp(2) and
not jh then
jh,eq.hl=
be.fv,
true
di()
end
end
function ms(be,hn)
be.bq+=hn
if(be.kd) hr(be.kd,hn)
end
function mt(be,hn)
be.br+=hn
if(be.kd) ht(be.kd,hn)
end
function mu(be)
be.hg=(be.hg+1)%240
if be.fv==0 then
if be.hg<120 then
mt(be,-0.6)
else
mt(be,0.6)
end
elseif be.fv==1 then
if be.hg<120 then
mt(be,0.6)
else
mt(be,-0.6)
end
elseif be.fv==2 then
if be.hg<120 then
ms(be,0.6)
else
ms(be,-0.6)
end
end
end
function mv(be)
if not be.mw or be.mw.gv then
be.hg-=1
if be.hg<=0 then
local jk=gw("fallplat",be.bq,be.br)
be.mw,be.hg=
jk,
60
add(ew,jk)
end
end
end
function mx(be)
if be.hh==0 then
if(be.kd) be.hh=1
elseif be.hh==1 then
be.hg+=1
if(be.hg==16) be.hh=2
else
local my=be.br
ic(be)
my=be.br-my
if(be.kd) ht(be.kd,my)
end
end
function mz(be)
be.ii,be.na=
be.br,
""..nb..
"-"..be.bq.."-"..be.br
for n in all(nc) do
if n==be.na then
be.gv=true
return
end
end
end
function nd(be)
ie(be,3,90)
end
function ne(be,cq)
add(nc,be.na)
be.gv=true
cq.hf(cq)
ip("death",be.bq,be.br)
local n=gw("item"..be.fv,be.bq,be.br)
add(mp,n)
end
function nf(be)
if(jh or be.ng) return
if eq.bq>=be.bq+2 and
abs(eq.br-be.br)<16 then
ka(false)
be.gv=true
end
end
bi="c7el%;rw.&}d02as&#!hz{+5)p(baaaaaaaaaa|:g7`j%;rw/&}d02"
bm="|gegf@`!~xuwv}[%}aaaa+t-ieeuxxhh@`exw!uoee`~f`!!~~g`~gemqq4334r344t2x?abv~~vf~v{n*4.de[ff{ve{v}[]{piii^n^*#&%($*^6qyy3s1w5rux4t2t)-#|`[&,9#9:!](58r_j$z;f~v{n*4.c0kts+=lk^%11':d:tktk0ss:'09::hc==991t2t2010::hc==kl^s^s^k^k':hc==kkctdtdlcl::hccssc99ss9cs9ccg7i#d[drqc#e87uq2qw2222y222222222qvzzzzszzzzzzzzzqwwttx1x1xtxtx?qqww4431313434x?7-||`[&,:=%:!](588_j$z;n~v{n*4.brr_j$z;f~v{n*:ds99ts^=lk^%2k{d"
cd="e/pee=?qqn?dbl,he3=6qim?b8m3pek=.q#n}d8j,lewsae|1r-7)ebh~secul8ar^eaf.]mym`ri_&e0d^sm5&l_e-$ete}saj,1_[`#ftt=wm4$1_[~(f+q!smtzlry9&ma,;=ah,ld3j#a"
bc="[0p998a9i8i/i0p6|+a/a9p0|dol7aky&7c%#8)c|dm/q7p`|df/q0pm|dl/-8p,|'k/uib;uqjf|tf/[^cj`sg$`q!$!8p?`=jxb0b!y8no|9h/e_oh|'7zg1`_!y&r|^#ik$&kk2`8gz&jg2`eutd*[7p4|2o/99)||lg/%9)+|lb/s8)m"
cn={
{"$f9bg",mr},
{"za`b",nd,mz,hf=ne},
{"v_b=",mu,nh=true},
{"{jea",kn,hf=kj},
{"{~kea",kp,hf=kj},
{"*jea",kx,hf=kj},
{"4iea",kw},
{"njuea",kr,kq,hf=ki,hl=true},
{"ca",ks},
{".jes",ky,kz=j},
{"daa",kv},
{"d{k`a",lb,la,hf=kh},
{"dj9a",lb,la,hf=lc},
{"0i`a",lg,hf=kj},
{"ceb",lf},
{"tjuda",kp,lh,hf=li},
{"liga",ll,hf=lm,is=0},
{"ca",mv},
{"2qd=",},
{"2$)$b",lr,ln,hf=kh,lt=lp},
{"2z$$b",lr,ln,hf=kh,lt=lp},
{"2;&$b",lr,ln,hf=kh,lt=lq},
{"bj3ya",},
{"cma",nf},
shard={"+ba",lk,lj},
bomb={"_uv1ka",me,hf=lv,mg=true},
item2={";ba",hz,kf="bomb"},
item0={"zba",hz,kf="bouncy_ball"},
roller={".ica",ku,hf=kh},
ball={"_q1ka",me,hf=lx},
item3={"faa",hz,kf="beam"},
item1={";aa",hz,kf="3way"},
death={"jbcd"},
wpn_death={"$q1%-a"},
beam={"j78;b",mi,hf=lx},
player={"b~ga",jg,hf=jx,jo=2,jp=15,jc=0},
explosion={"*a9c",mj},
item7={"vaa",hz,type="1-up"},
fish={"4jea",hf=kh},
item5={"~aa",hz,type="heart"},
boss_watcher={"ca",lu},
item4={"fba",hz,type="boots"},
flier3={"d{o`a",le,hf=kh},
item6={"~ba",hz,type="heart2"},
bouncy_ball={"_uw1%1b",me,mf=true,hf=lx,io="wpn_death"},
straight_ball={"_ur1ka",mh,hf=lx,io="wpn_death"},
fallplat={"^_ba",mx,nh=true},
}
db={
"`daia[ku1y69xk7|$ey/ia86gga9_k8|cxis)m0g]@#jtn#7j9xua|jfa`+meu:8#76qc|$ba5za7pggin[eo%i94k9#8ni/ya7`lt#j?d50j!)qs8g8i77c~q/+a79rs$$*i51y7)cq|@ey]^ycy1lmh&ug|d@at~m;,#0we4nm+xnd7q2$z,raa6fa-6bb`5re.&p_6j_7av8k,7tk6ma-2da7q2(em!iex7erdn8cwu7e`h",
"u-4qascczaisgdc~zaqzocu]j[`bgfz`bsgnhf`~a0eo|=aq#&0ill&9=a89m*kidos=]s&#1~=s%mqkk+&a=o9%&/ckdc1!9j%q$!~jtzb=a07miikd!8=wr`&^i2%aj|!-6$mfmk+~a=o97&till@8=9b#m4ekd%q=a798yhe99j=g",
"`daiauhy1u69}bs|$~3cvo#yg`i9+5w$)r1rzm*(q5#z7yilm4yccve+[r|p--elc4e?+6oa7r6e$&~7m@zi=ye=,hsap|aao*yi=lka,!cat,c+ffjmx0m4=9ib7$l~+rl_&msenlpth![,fde?ia=6ii`kto.u,=~e9mmqm^&m_dka,t=ahf`q_~j[=/f)na-hda,+ya73vjejx!ql8/ugao?-7-xkq3e5-a",
"`daiaukm1y69xk7|*ae/ib!?1a#)ba-;)ca:^f75gd#$cj52i7g1a;8caq#*4i1#i~6s7;)aek#mdreiqobce$5ar,hqe;bq+zq`=s9jdjeia0gq1y69@ga|~ba/zi-ejtolz!mes7a`ca$)gq:za761a|)caq#8cv1zx9}cs|d~3#qabce#3ab,bqaza`q7a&3ca$9a51i76ga|)bajg^q=1`qbe`ec#8.j1#59o,!|$eb5lb76e7|pgyqiaebua$q|e/_a7?ma|f!y5qb`qtdo",
"u-4qa1m5z-qw]&e`b!izfqu/bu`daz;eawodb~haq;jeu!og`jqr;xrw]ag~b7j$lm9;vi0*a=7s`mqaj6n$={%7,`gkdfs=487[lfszif=a8%magk6l==?c&m$oi'nd=z`7,0itn8&=a09mqiida8=p09,~ek@ks=_c`&5kk^g7=`$#3{mix!0=w#a8[ec",
"`daia`ly1#fb$!fya0fc~muas$o0]s{|*aa/rb!)yq;)aa/ia7u$0q#9q`$i`[l0r&9q:jf06cb#|9qe2jaie#ja$sciz9e1_{7pis|n7m/+a7-qdn",
"`oaqaobi%m7qda[brlqbu{!b{kjtfa=*=imki&j]942a4nvy-fa=z9_ev;f-$o=v1avnaq@|qd9dau#_ldoe_722#lf0jz59liy#bism8+&w4`i3m8s4q3a~mo)z{$zu4`qa!3l~r68u1e4nwyqfe[vnub$|oi2w!gim^sw9((1`w~`_1~s3s_m8&eg",
"`daiaule1yd9xcs|^8b5-ide11mgks!|$ga5$b7`l9#0~i/yi7g_t$$!e:ji@@kc|hha/+bq#tt=;r7!ka|nmaey`makmd=ay0ej7[%a|vmawcd77ra-[t-o.am_6oa_31tyju!a3d*u8slqaic1i=_#8i87ic0csya9em7i~7aszi7mka,7d7j8!m3=|bkf_[z87!=7mbhv[9$ftt/9i!pas~8#-sch",
"u-*aaspe4,5uh'g[r9c4q+x:ua{j,i.pfqx#?bwp87{'_a4b58(vs{'sa.gnq)bc[~oa4$u-ow%n8]1k4oeqhtc[4@b.[iq)fe{0ta.kmqx7hrkcu.xqay4-vqxmb[)sa:ocwx7~[~va.@d-(7;&0^oy.`uq?rc[byt:9cvhbb[0{b.a5hjk`[8ha;`9/3q4{=ci49/d8rqauh^ifs.f]rea",
"`daia[3m1q'@]_?;j9i5bi86i7|pae-qc+q5ab!@aq|2aa/fa7?w7b8]aj#4q55|a9}5b`j!!z=$ru5:1^@fw8;`sig=z9/u_$6;2s*m~lk~ypxi!qj8@ea|fbakaj0oi.;vwa5ea!@5q|d`a/dba3:ue8(x0|!tu!#f96ha|?ba5ab-j[9/:$l@+_fr&&tedler@3o&jqe4`js6*;[irj|ue7m)c[2/g6ya_lci,gdk?2a_)m#7^q7q9*cikq#=a-|za&fcqy8b5oy7)da|}aa/}acu1q~@hea|jba5ta7hdg#;*y1oi@/*i;z@a11n98rr|rfac4j9",
"`daaaaku1y69$k8af@a51q7}gam=`e54`q@6uq_j7pk7|^ey/$a9}k7i=`a",
"`oaaafjknqzq'gg4bgr}|yufmuu99yh_-[ba`ueafx#rby}zruz5eu8trw!ox4iuucfr*-ztvge47+r@7q=nagb",
}
dc={
}
bo="&beeyccmqb[w7bgiuccysabeycfu3br1-adi#cfu#ahmrb0h-7aey9ei38qxq8ceq9giy9bmi8fi50di#8fw78hiw9thyqai78hiqreyuscezqgyytbyzqfi`sdq7rdqirvhyrv2[qhiitdho_am#+eui-cyy=gy#_biy=fyn_de7+hi&-d1zjamtkeyyiae7jcwukgi7jci|jbmekfi#ldu#a"
bt={
"acaa",
"7zga",
"-kbd",
"i0ic",
"yb^a",
"|zsd",
"`l9a",
"uhfa",
"msdb",
}
function oc()
eq,jy,jd,
mm,jq,jm,
nc=
gw("player"),
3,
"ball",
nil,
false,
false,
{}
od(b)
end
function oe(of)
c,b,jw=
of,
bt[of].bu,
false
for n=1,4 do
d[n]=bt[of].bv[n]
end
end
function od(bd)
et,ev,eu,
ew,mp,bp=
{},{},{},{},{},
bo[bd]
if(bp.b) b=bd
nb,eq.bq,
eq.br,eq.is,eq.ib=
bp.map,bp.bq*8,
bp.br*8,0,0
iq(eq,1)
ff(nb)
dn(fm)
ep()
for bq=en-4,en+19 do
gy(bq)
end
end
function og(br,oh)
for n=1,4 do
if oh or n!=oi+1 or oj%4<2 then
spr(64+d[n],35+10*n,br)
end
end
end
function ok()
if btnp(2) or btnp(3) then
ol=abs(ol-8)
end
return btnp(4)
end
function _init()
l()
bh()
bb()
bn()
bs()
bw()
cl()
da()
dd()
for cm,om in pairs(cn) do
om.__index=om
setmetatable(om,{__index=hb})
end
on()
gb=0
end
function on()
_update60,_draw,ol,mo=
oo,
op,
0,
3
pal()
end
function oo()
if ok() then
if ol==0 then
oe(1)
oq()
else
os()
end
end
end
function op()
cls()
spr(212,32,36,8,3)
print("the balldragon",36,60,7)
print("start",48,88)
print("password",48,96)
spr(2,40,86+ol)
end
function os()
_update60,_draw,oi,oj=
ot,
ou,
0,
0
end
function ot()
local jb,md=0,0
if(btnp(0)) oi+=3
if(btnp(1)) oi+=1
oi%=4
if(btnp(2)) d[oi+1]+=1
if(btnp(3)) d[oi+1]+=4
d[oi+1]%=5
if btnp(4) then
for n=1,#bt do
if ov(n) then
oe(n)
oq()
return
end
end
elseif btnp(5) then
on()
end
oj+=1
end
function ou()
cls()
og(60)
end
function ov(ow)
for n=1,4 do
if d[n]!=bt[ow].bv[n] then
return false
end
end
return true
end
function oq()
pal()
ox,_update60,_draw=
0,
oy,
oz
end
function oy()
ox+=1
if ox==180 then
pa()
end
end
function oz()
cls()
camera()
print("level "..
dk(c+2,3)..
"-"..(c-1)%3+1,
46,40,7)
spr(51,52,68)
print("x "..mo,64,70)
if(c>1) og(96,true)
end
function pb()
_update60,_draw,ol=
pc,
pd,
0
end
function pc()
if ok() then
mo=3
if ol==0 then
oe(c)
oq()
else
on()
end
end
end
function pd()
cls()
print("game over",46,48,7)
og(68,true)
print("continue",48,92)
print("quit",48,100)
spr(2,40,90+ol)
end
function pa()
_update60,_draw=
pe,
pf
oc()
end
function pe()
gb+=33
gb%=32
he(eq)
if eq.gv then
mo-=1
if mo>0 then
oq()
else
pb()
end
return
end
if jw and not de then
if c<9 then
oe(c+1)
oq()
else
pg()
end
return
end
if mm then
mn-=1
if(mn==0) mq()
end
for n in all(mp) do
he(n)
if hi(n,eq) then
ml(n)
end
end
for cq in all(ev) do
he(cq)
for lw in all(et) do
if lw.hd==0 and hi(cq,lw) then
lw.hf(lw,cq)
cq.hf(cq,lw)
end
end
for fz in all(ew) do
if hi(cq,fz) then
fz.hf(fz,cq)
end
end
end
for cq in all(eu) do
he(cq)
if eq.hd==0 and hi(cq,eq) then
eq.hf(eq)
end
end
for lw in all(et) do
he(lw)
if eq.hd==0 and lw.hd==0 and hi(eq,lw) then
eq.hf(eq)
end
end
for fz in all(ew) do
if fz.nh then
kc(fz)
end
he(fz)
end
local ph,pi=en,eo
if jy>0 then
es()
end
if jh and not de then
od(jh)
jh,eq.hl=
nil,
false
df()
end
jn=false
gz(ev)
gz(eu)
gz(et)
gz(ew)
if en>ph then
gy(en+19)
elseif en<ph then
gy(en-4)
end
if eo>pi then
gx(eo+19)
elseif eo<pi then
gx(eo-4)
end
end
function pf()
camera()
rectfill(0,0,127,127,fj)
palt()
dl()
camera(eh,ei)
fy()
ez(fi)
local pj={
ew,
ev,
eu,
et,
mp
}
for n=1,#pj do
for be in all(pj[n]) do
il(be,eb(n>=4,1,0))
end
end
il(eq,1)
camera()
pal()
for n=1,max(jy,3) do
local ga=52
if(n>jy) ga=53
if(n>=4) ga=54
spr(ga,(n-1)*8,1)
end
if mm then
spr(mm,40,1)
rectfill(48,2,77,7,0)
rectfill(49,3,49+(mn/1800)*28,6,8)
end
if de then
dj()
end
end
function pg()
_update60,_draw=
pk,
pl
end
function pk()
if btnp(4) then
on()
end
end
function pl()
cls()
pal()
print("with the defeat of",
28,32,7)
print("the evil balldragons,",
22,40,7)
print("peace returns to the land.",
12,48,7)
print("the end",50,76,7)
end
__gfx__
000000000f94000000000000009994000000000000000000000000703ba7a000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa04444000000000000000000000000000
00000000fff940000000000009aa994000000000007607600760000003ba7a00a111111aa111111aaa98111aa111111a049940000e82e8200a94a94000000000
007007009f994000007770009a7aa944007607600776066006600060003ba7a0a111111aa171171aaa98888aa13b711a77694000e88e8882a99a999400377300
0007700049944000007887009aaaa944006676600660000000000000003ba7a0a1d6171aa161611aa988998aa113b71a06794000e8888882a999999403b71b30
00077000044400000078887099aa99440007600000007600600000000003ba7aad11611aa1dd111aa889aa9aa113b71a04994000e8888882a999999403bbbb30
007007000000000000788700499994440006600076077600000076000003ba7aad11611aa11d671aa189aa9aa13b711a04449440088888200999994003bbbff0
000000000000000000777000044444400000000066066000070066000003ba7aa111111aa111111aa188998aa111111a0499999400888200009994000388ff00
000000000000000000000000004444000000000000000000000000000003ba7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa04999994000820000009400000882000
003bb300003bb30003bbb30003bb33000000000000770000060070000003ba7a0022220000222200002222000022220000222200002222000022220000222200
03bb673003b67b303b67bb303b67bb300770000000676000700000000003ba7a0244442002674420024476200244442002444420024444200267442002447620
3bbb71b33bb71bb33b71bbb33b71bbb30607000077066000000000000003ba7a2679976224719442244917422449976224499442267994422471944224491742
3bbb71b33bb71bb33b71bbb33b71bfff0076000067600000000070000003ba7a2719917224999942249999422499917224999942271999422499994224999942
3bbbbbb33bbbbbff3bbbbfff3bbbffff000000000660000060060000003ba7a02499994224999172249999422499994227199172249999422499994227199942
03bbaaaf33bbffffa3bffff033bffff0000000000000000000000000003ba7a02449944224499762244917422471944226799762244917422471944226799442
00ffaaf00aaffff0aaffff90aaffff0000000000000000000000000003ba7a000244442002444420024476200267442002444420024476200267442002444420
009990000aaa9900aa000000aaa990000000000000000000000000003ba7a0000022220000222200002222000022220000222200002222000022220000222200
03b6733003673000067bb3300367333000000000000000000088880000211e000011ee00011eee1000211e000670067000676700000670000000700000449900
3bb71bb33b71b330371bbbb33b71bbb300000000008888000899998002eee1e002ee1e102ee1e1e002eee1e00747774000747700007747000070770704499990
3bb71bbb3b71bbb3371bbbb33b71bbb00008800008899880899aa9982ee67ee02e67eee6267eee6d2ee67ee00740007007740070070740700777d07004467967
3bbbbb003bbbbb003bbbb2003bbbbb0000899800089aa98089a77a982ee71ee02e71eee1271eee162ee71ee0700000077000000770000007070d507004471971
3bbbb0003bbbb0003bb220003bbbb00000899800089aa98089a77a982ee71ee02e71eee1271eee162ee71ee07000000770000007700000070056650004471971
03bbaaa003bb0000a3bf222033bf00000008800008899880899aa99802eeee2002eeee20a2eeee2002eeee207000d0077005d007700d000700566500044998ee
00ffaaff0aafffffaaffffffaaffffff0000000000888800089999800922aaa00aa22200aa2222990aa22200070dd070070dd070070dd0700cc5510004499888
00999ff00aaafff0aa0ffff0aaaffff00000000000000000008888000990aa000aaa0990aa000000aaa00000070d0070070d50700700d0700ccc111004499990
003333000673376006333360003bb300001101100011011000110110009a9a0000a9a90000026000020000600056650000566500005665000673376000006600
067bb760371bb17303bbbb3003b67b3001ee1e810166166101aa1a9109dddda00adddd9000287600280000760cc66500005665000156ccc0071bb17000666dd0
371bb173371bb1733bbbbbb33bb71bb301e8e8810167677101a9a9919676676aa676676902887760288007760cc551100cc551000115cc00371bb1730666dddd
371bb1733bbbbbb33bbbbbb33bb71bb301e888810167777101a99991a71661799716617a07187760718877600c0001110ccc1110001000003bbbbbb366222dd1
3bbbbbb33bffffb33bbbbbb33bbbbbff0018881000177710001999109d6666daad6666d906787760678877600000000000000000000000003bb22bb3622d22d1
fffbbfffffffffffffbbbbff33bbffff000181000001710000019100add66dd99dd66dda0028860000288600000000000000000000000000ff2222ffd2222210
affffffaaffffffaaffffffa088ffff00000100000001000000010000adddd9009dddda00002800000028000000000000000000000000000affffffad2222210
aa0000aaaa0000aaaa0000aa0888220000000000000000000000000000a9a900009a9a000028820000288200000000000000000000000000aa0000aa02222200
02eee2000c000c00000a0000bbbbbbb00880880003bbbb3003bbbb3003bbbb300000281200005555000281110000555500022182000055500200010200210302
2eeeee20ccc0ccc0000a0000bbbbbbb0888888803b9abba93b9abba93b9abba90022888112005555002888671100555500288811220055500002024001000020
eeeeeee00ccccc0000aaa000bbbbbbb0888888803ba2bb2a3ba2bb2a3ba2bb2a0288886711205555028888718820555502888671182055501030100102032010
eeeeeee000ccc00000aaa000bbbbbbb0888888803ba2bb2a3ba2bb2a3ba2bb2a2888887188205555028888718882555502888718888255500200200320101001
eeeeeee00ccccc000aaaaa00bbbbbbb00888880003bbbb3003bbbb3003bbbb302888887188825555288888888882555528888718888255510010000100002003
2eeeee20ccc0ccc00aaaaa00bbbbbbb0008880000288882002888820028888202888888888825555288888888882555528888888880055522003020010200120
02eee2000c000c00aaaaaaa0bbbbbbb0000800000aa882000aa882000aaa829028888888888255552888888888ff555528888888800055520100100200010001
00000000000000000000000000000000000000000aaa0990aa00990000aa09002888888888ff555528888888ffff555528888882000055520040000032000202
00111100001001000001010000010100000101000777777777777777777777702888888fffff55552ddd888ffff05555288888fffff055520200321001003100
011111100111111010001110000011100000111077666666666666666666665502dddffffff055552dddffffff00555502dddffffff055522102002200200020
0111111000111100d101111100011111000111117666dddddddddddddddd66d500ddddffff0055550ddd1ffff000555500ddddffff0055530030010010302400
1111111100111100dd11a8181111a8180001a818766d5555555555555555d6d500dddd11100055550dd011000000555500dddd1ff00055540201000200010001
11111111011551100d1111510dd111510011115176d5000000000000000056d55555555555555555555555555555555555555555555555542000020402000200
111111110a8118a011111110011111101110111076d5000000000000000056d55555555555555555555555555555555555555555555555540130002010320012
11111111011111100111110000111100100011107dd500000000000000005dd55555555555555555555555555555555555555555555555540001230020010203
11111111010110100011000000011000000111000550000000000000000005505555555555555555555555555555555555555555555555541020001200102010
11111111077000000000000000222670002226700000ddd000000000000070000000000000000000000000000000006666000000777777666677777777777777
1111111166672670002226700288871002888710000d67d70000ddd0007707000000000000000000000000000000067776600000777776777667777777777777
1111111106678710777887102667871a2867871a000d71d1000d67d7070007000000000000000000000000000000677777660000777767777766777777777777
111111112867871a2667871a777888aa266788aa0000ddd0200d71d1070070000000000000000000000000000000677776660000777767777666777777777777
11111111288888aa288888aa2888899a6667899a022222202220ddd0007070000000000000000000000000000066777777776600776677777777667777777777
111111112888899a2888899a4fff4009477f40092222888002222220007070000000000000000000000000000677777777777660767777777777766777777777
111111114fff40094fff40090444000004440000000aa89000aa8889000700000000000000000000000000006777777777777766677777777777776677777777
1111111104440000044400000000000000000000000aaa99000aa899000000000000000000000000000000006777777777777666677777777777766677777777
000000000123456789abcdef0666666666600000066666666666666666666660000000000000000000000012ccccccccffffffffffffffffffffffffeeeeeeee
00ffff00012121562493d52961d1d1d1d1d5000061d1d1d1d1d1d1d1d1d1d1d5000000002000000000000155ccccccccccccccccffffffffffffffffeeeeeeee
0f1111f000002015224311246d1d1d1d1d1500006d1d1d1d1d1d1d1d1d1d1d15000000005200000012001555ccccccccccccccccffffffffeeeeeeeeeeeeeeee
f111111f000000010221100261d1d1d1d1d5000061d1d1d1d1d1d1d1d1d1d1d5000000005520000155214555ccccccccffffffffffffffffffffffffeeeeeeee
f111111f00000000000000000555555555500000055555555555555555555550000000005532001555355455ccccccccffffffffffffffffffffffffeeeeeeee
f111111f00000000000000000000000000000000000000000000000000000000000000005355215553555545ccccccccccccccccffffffffeeeeeeeeeeeeeeee
f111111f00000000000000000000000000000000000000000000000000000000000000003555543435555554ccccccccffffffffffffffffffffffffeeeeeeee
0f1111f000000000000000000000000000000000000000000000000000000000000000005555555555555555ccccccccffffffffffffffffeeeeeeeeeeeeeeee
00111100001111111111110011111111ee0000eeeeeeeeeeeeeeeeeeeeeeeeee0122221000000fff0ffff00000ffff0000000000000000000000000000000000
02333320023333333333332033333333e0bbbb0eeee00eeee0eeeeee0ee00eee1233332100fffeeefeeeee00ffeeeeff01111120011111111111112011111111
13456431134564456445643164456445e0b8b30eee0bb0e00b0eeeeeb00bb0e0234544620feeeeddeeeeddd0eeeeeeee01345560013433577734336077343357
17578631175786469a3786319a3786460bbb3330eee03b0bb0ee0eee30bb0e0b23535462feedddddddddddd0eeeeeddd01335560013333777733336077333377
186b8c71186b8cade87b8c71e87b8cad0b3bb830e0e003bb0000b0ee3b3000b323545362eeddddddddddddd0dedddddd01554360015575444355756043557544
189b9db1189b9db8cd8b9db1cd8b9db80bb333300b0bb33bb3b30eee3b3b3bb323446362edddddddddddddd0dddddddd01554460015577443355776033557744
1bb888811bb888888bb888818bb88888038bb330e0bb3b33b3b00eeeb3bb3b3b126666210ddddddddddddd00dddddddd02666660086666666666666066666666
11111111111111111111111111111111e033330ee03b3bb33bb330eeb3b3bb3b0122221000dddd00dddd00000dddd00000000000000000000000000000000000
00111100001111111111110011111111ee0000eeeeeeeeeeeeeeeeeeee0000ee0122221001222222222222102222222200000000000000000000000000000000
02333320023333333333332033333333e0bb330eeeeeeee00eeeeeee00bb33001233332112333333333333213333333301111120011111111111112011111111
134564311345644564456431644564450bbbb330eeeee00b300eeeeebbbbb3332345446223454445444544624445444501345560019999aaaa999760aa9999aa
17578631175786469a3786319a3786460bbbb330eeee0bbb3330eeeebbbbbb3323535462235354335433546254335433013355600195554444555b6044555544
186b8c71186b8cade87b8c71e87b8cad03bb3330eee0bbbb33330eeebbbbbb3323545362235453345334536253345334013375600195754443557b6043557544
189b9db1189b9db8cd8b9db1cd8b9db8e033330eee0bbbbb333330eebbbbbbb323446362234463446344636263446344013377600195774433557b6033557744
1be9d8811be9d8889ee9d8819ee9d8880bbbb330e0bbbbbb3333330ebbbbbbb3234364622343644364436462644364430175446001a3447555434c6055434475
18dddbb118dddbb9d89ddbb1d89ddbb90bbbb330e0bbbbbb3333330ebbbbbbb3235354622353543354335462543354330177446001a4447557444c6057444475
18ede98118ede99e88cde98188cde99e03bb33300bbbbbbb33333330bbbbbbbb235453622354533453345362533453340177346001a4345557443c6057443455
1bddbd811bddbddb8b9dbd818b9dbddbe033330e0bbbbbbb33333330bbbbbbbb234463622344634463446362634463440177336001a4335577443c6077443355
18d88cb118d88ce889d88cb189d88ce8ee0000ee0bbbbbbb33333330bbbbbbbb23436462234364436443646264436443013455600197553444575b6044575534
1bc889811bc889d99eb889819eb889d9ee0420ee0bbbbbbb33333330bbbbbbbb23535462235354335433546254335433013355600195554444555b6044555544
189b8c81189b8cdde88b8c81e88b8cddee0420ee0bbbbbbb33333330bbbbbbbb23545362235453345334536253345334013375600195754443557b6043557544
189b9db1189b9db8cd8b9db1cd8b9db8ee0420ee0bbbbbbb33333330bbbbbbbb2344636223446344634466626344634401337760017bbbccccbbbb60ccbbbbcc
1bb888811bb888888bb888818bb88888e044420e0bbbbbbb33333330bbbbbbbb1266662112666666666666216666666602666660026666666666666066666666
11111111111111111111111111111111044444200bbbbbbb33333330bbbbbbbb0122221001222222222222102222222200000000000000000000000000000000
18ede98118ede99e88cde98188cde99e03bb33300bbbbbbb33333330bbbbbbbb235453622354533453345362533453340177346001a4345557443c6057443455
1bddbd811bddbddb8b9dbd818b9dbddbe033330e0bbbbbbb33333330bbbbbbbb234463622344634463446362634463440177336001a4335577443c6077443355
18d88cb118d88ce889d88cb189d88ce80bbbb3300bbbbbbb33333330bbbbbbbb23436462234364436443646264436443013455600197553444575b6044575534
1bc889811bc889d99eb889819eb889d90bbbb3300bbbbbbb33333330bbbbbbbb23535462235354335433546254335433013355600195554444555b6044555544
189b8c81189b8cdde88b8c81e88b8cdd03bb33300bbbbbbb33333330bbbbbbbb23545362235453345334536253345334013375600195754443557b6043557544
189b9db1189b9db8cd8b9db1cd8b9db8e033330e0bbbbbbb33333330bbbbbbbb23446362234463446344636263446344013377600195774433557b6033557744
1be9d8811be9d8889ee9d8819ee9d8880bbbb3300bbbbbbb33333330bbbbbbbb234364622343644364436462644364430175446001a3447555434c6055434475
18dddbb118dddbb9d89ddbb1d89ddbb90bbbb3300bbbbbbb33333330bbbbbbbb235354622353543354335462543354330177446001a4447557444c6057444475
e000000ee00000000000000e000000000000000000000000000000000000000000000000000000000000000000000000e7eeeeeeeeeeeeeeeeeeeeeeeeeeeeee
001111000011111111111100111111110000000000000000000000000000000000000000000000000000000000000000767eeeee7eeeee77eeeeeeeeee777eee
0110011001100000000001100000000000000000000000000000070000000000000d00000000000000000000000000006c67eee7677ee76677777777e766677e
010d1010010d17771ddd10101ddd1777000000000000000000000000000d000000060000000000000000000000000000ccc67776c66776cc6666666676ccc667
0101701001017666d1117010d111766600000000007000000000000000d7d0000d676d00000000000000000000000000cccc666cccc66ccccccccccc6cccccc6
01100110011000000000011000000000000000000000000000d00000000d000000060000000000000000000000000000cccccccccccccccccccccccccccccccc
0011110000111111111111001111111100000000000000000000000000000000000d0000000000000000000000000000cccccccccccccccccccccccccccccccc
e000000ee00000000000000e000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc
e000000ee00000000000000e000000007777777777000000000007777700000077777777777000007777777777700000cccccccccccccccccccccccccccccccc
001111000011111111111100111111117888888888770000000078888870000078888888888770007888888888877000cccccccccccccccccccccccccccccccc
011001100110000000000110000000007888888888887000000078888870000078888888888887007888888888888700cccccccccccccccccccccccccccccccc
010d1010010d17771ddd10101ddd17777888888888888700000788888887000078888888888888707888888888888870cccccccccccccccccccccccccccccccc
0101701001017666d1117010d11176667888888888888870000788888887000078888888888888707888888888888870cccccccccccccccccccccccccccccccc
0107101001071ddd1777101017771ddd7888887788888870000788888887000078888877788888877888887788888887cccccccccccccccccccccccccccccccc
0106d0100106d1117666d0107666d1117888887078888870000788888888700078888870078888877888887078888887cccccccccccccccccccccccccccccccc
010d1010010d17771ddd10101ddd17777888887078888870007888888888700078888870078888877888887007888887cccccccccccccccccccccccccccccccc
0101701001017666d1117010d1117666788888778888887000788887888870007888887007888887788888700788888700220000110001114004444400000000
0107101001071ddd1777101017771ddd788888888888870000788887888870007888887078888887788888707888888700222200110101114004444007666650
0106d0100106d1117666d0107666d111788888888888700007888887888887007888887788888870788888778888887002222222000110110044444006555510
010d1010010d17771ddd10101ddd1777788888888888870007888870788887007888888888888870788888888888887002222222110000004044404006511510
0101701001017666d1117010d1117666788888888888887007888877788887007888888888888700788888888888870022222220110111014444000006516510
01100110011000000000011000000000788888777888888707888888888887007888888888887000788888888888700022222220101111014400000406555510
00111100001111111111110011111111788888700788888778888888888888707888888888887000788888888887000000222200001111004000004405111110
e000000ee00000000000000e00000000788888700788888778888888888888707888887888888700788888777770000000002200101110110004044400000000
0101701001017666d1117010d1117666788888700788888778888888888888707888887888888700788888700000000000000000007700770000000000000000
0107101001071ddd1777101017771ddd7888887778888887788888777888887078888877888888707888887000000000420dd1040077007707aaaa900a999940
0106d0100106d1117666d0107666d1117888888888888877888887000788888778888870788888877888887000000000220d1104770077000a99994009a99420
010d1010010d17771ddd10101ddd1777788888888888887788888700078888877888887007888887788888700000000022011102770077000a94494009944220
0101701001017666d1117010d1117666788888888888870788888700078888877888887007888887788888700000000000000000007700770a94a94009944220
0107101001071ddd1777101017771ddd778888888887700777777700077777777777777000777777777777700000000004420dd1007700770a99994009422220
0106d0100106d1117666d0107666d111007777777770000000000000000000000000000000000000000000000000000004220d11770077000944444004222220
010d1010010d17771ddd10101ddd1777000000000000000000000000000000000000000000000000000000000000000002220111770077000000000000000000
__gff__
0004040404040400040404040404040400000000040404000000000000000000000000000000000000000000000000000000000000000004040404000000000000000000000000000000000000000000000000000004040400000000000000000000000000000000000000000000000000000004040404040000000000000000
0101010100000000020000000101010101010101000000000202020201010101010101010000000000000000010101010101010100000000000000000101010101010101000000000000000000000000010101010000000000000000000000000101010100000000000000000000004101010101000000000000000000008101
__map__
68cc903014011384078110407064d1060f904a167a9c0522cd443e058516a00f28826949e232807304e11980381fc430d5262913b179ac201f20b824e0d2ab1b2d88ea7d123252a05880d842081437bac205184659a12883430964201db33886201200bb92e12a44a12eb3924284260b2079ac201da308ae049880900a0c2289
807104e113437aac601fa2a811534210b0268c248b80750cc040c132e40c010044b6016025820a1f424400a52aa5216441a71811294d03f1170ec41a8d3e111ec8518296f4c9c0be2620cb88c497342f41942920abcf56069512f2d0f2b0d2c9c8bd2220720c3ca3706f0c580405826171e0611fe80f485c0bd2620cba87c317
02f898812ed1128d4807221028a9bc3a1061197e6218b0b789e94b83784220c165d3e221653c93106a24f882491318c818833aa0130240c0500446709c144903819208983ce170cd81b0940541df0588ad720ac602401160b412002004881e01e6318271843020c81a7a1c0b72788701e20281882240de631827302422871788
c201d333884204947a9344d2d081ac01d2b88440de59042888ea7d9064c4908a2f00203282718ce21a801594e59198a65086851110148e401460fa45c33582304e689c4285844b530b500123887505135c5d481296020121d47b53653f1b4904641c09d108770e10dc6885dfc09487027125d0f81c083407d24a0c08436e0246
8530b400221d87540d21f0e750f84e0d138c1f7b110386edc3115c50746e407d6d943f706a13f90f685703bac898fb998746350fce1743e303a80150f681207508744510be59a58d138704830960340640c05004796094544d24a2f309819cc354a784353919941a464104185dc83442502f890d292c9483f12300c51bc52002
79198ba268c84b260092c8c93701f105402566378d009209d254439995ccc056614585124465041dd0da37c2f301019500a24e52ab203c868209ea33844705e433813e09c432c3e429b192ce882303030804a41ec238c430de6b000d122281193c82c201df0b8a4c0de21281252709ba84e4c253241c940600200ba64a04ca52
a80a0a261910cacca031b238a400746d93fe40c0100c4a201e12d1370623ae81248a5a7a0200c22c0da07c4ce1d081295479f090952e2f1513866801e173008c908a0a1c3fa54205e1ca013547e8d083251f94c65c1719f870d6c2170c2c96ce0a1c08a5ce0f296181780c21003b00b22c022dbda17a024154012d83a1780460
5c930855841e3e2a1d2ca40d0de1a181760c6057c8646e7c23284983ce04e11301785aa09340ddb121088d3648010b0e1fd32603092994167b410a368a498810f85840000a072cc41a4011601143b880511f24c0d4003b9a3041d90a0d0d289009543ca41e93d0e131ab493b47c1f795f04293e42620438b6420f23c2883c174
274851850d7c824c9fcb918d9581b69de183926d30a159161c30e944994a6f29c09dc6eae26522f013680296257a60cbcd8900c0141c86a4661781d818ae38de611c04287e527e5d88276a0e210984a1342b09180ae5052bc90b404102d8814ae3c211c0800e100a28e8b60bfe4d5c148f3e15dc03824701a6eb8b7185004882
468a3c71028c826389e69941f9a04071d0909a302ae495e84176b9a74d1d26fb46c0b170f140c414b3410af544ccb2c0f130c4fd501b2ac86e98060cc472ed4c0d40070ed1040c310072f2d82381964bb004c412a12222fa3e02970060916ab92fa1c54e0c98820424a617a5f9c61548d2fb6e9800f2b94c507e012680e0ce6f
8d08774e10e95116548c7588502ef38a10562d440a305d84cfe77080348fe35436a411f0b1f3ce1865d0fbaad8c1ab2842e0ee162bcc609c7b9194f11fdf83f5789999a20c609549f201033636240300d0b61aa14961722127948065209cbb8e9a625716838a7486a1cf98e896277dc0383c162582c26c61e401494da742a910
4a7204454884d64cb98d11a1044c18414da70042481846701208c596527aa4d85f283a14f90c5a2d220a5b3101381e64625d274031a7f26080be80081ab43439208d34c4d716bf15c803f530030d16acd3b828b7f842631f81294d75d67e8e2d109ae54d51d12e1ebc850321965502c5303400002847d864a2069430d701f488
40804bd081ca50a94322102110c85590c09e4c2d00014961d0281f1c97d2d850035b414562ca5af03a46c1097592042b6120008050b31a6058ae1a7e69118789021dca838bc6010a2b549f9a5201da020924210a2d294fb32623d2038ac4032a099be291e41944f8b14043aac494c293e011c87b20265d2000bd2020027440c0
b22030a0c1ad2031b8c87c23068502c70623bb18428600f0a0401d7000a6f258cc02c2925216323102cc3340f140c08519423e14c0f00049b503e08d0418136d0c12fb670a86900ce068436c0516eb670b8612db234536918a1ab2b280896eb234c0608da0544bec8d22784608c984c823071c0ac8a202a38b113688c3c380b2
c9008f34202aa0f530200cbc6013c80c22280b2c140448b7aab036d0804d103071402c00700be80c2a080b26140a4a3c4c1234d140cd807089a02c90002b2c940a4c247c233c45c10484600890ad22500728806519912a03682080890d59182c7886c51a31f4061e1c01164ca04e48480020342c469834228a8b8a4221e24119
46a97e1fca038ac203ea0002c0820217ca0788c201e2080b408262ca946a97e1fcc4381c553e2800a4082021dca038a4201e2000aa721062b94af82f1020a2ff49f9b080020a6ff49f99020bc601852613e68480f2a0e2d11879800063aadf8732a662e8090399d202201da745ff09f100c573b0f13088fd50b061504c7952bd
d61c03189f24406fd40305c5000cd0850724c0cfd4010a19a423f94c0f40073d484c850117c14125c0a8503371e90cdc702bcd1cba740b7f1f01386f0b61f0ed83a0413713571302cd8003b1d140952740a1096c34bab0996761e0a1424e55c31c67399eb0604b940314854324019505c214811454045d14a04511a4344c2268
c9621288aa34293ac7874ac223e6e062b32d5080a71a81094e41e2c350ce9398264f3199146a96a71a1364fd509bbf56031a052086e00b218486c25931ac40a960a0a2d40c6aa822986c68a4821bac2896ab1a2524c6a602301025303d0012a440c04361040adc3141bf88888043b819c26b23611bc4a405911a0468d61b2a05
80468a0b58a789b9814086410229964e817729ac4b886f233296a56411a39a6c68177a184098a600aa298c828a0b5da36b136319a8e8a7531a08c8962232385a04e887821aa8e856212a0d9446993e1182288d5285864b856812a09b8c6b12e15131ae17e19a00fc96803b25f446a1b60182ae8a73202885dc46a832398e8ea2
7011293e2b748f06de6345b791c204e43581104c4674c11508507d003da1200080d0e31ab1d861762e5b1d8f8d0223cb038fc2002d4cb486af7e1acd4c09890e361b85938716232e4a87687ee6058952a16029c9c943e658c3612a621e44940c4f380911130500444c148af4604c5c03118541c481cce36deb4143a4540c895b
e082f6404346d70bf582206ad12af7163d48b1565e1c519999362192ab994001e28042c1c66a98becf0a394953b6562ecd9586512669d58a1065e5e5115a82a244c8c3b22d3170b2e68648f9a2563aaa996f282610851f5303d00128d42db23008408cc2104b788c12514906190890bf05110acb2400b005c162243041490f26
3008c18cb2302a74cc54014b149910e74740180a95a5083318d220c6b640914d943251710db25403411d02724a2641c2c423490250ce46443a51d92786b6d9d06f024411b618c247863351410db47032cc4c0722256ba2029804a016a1184cb0362b3008d94ca886431a4070d6cb18340952c5b05c846023029964c0a721d9c8
00c62a0013207a24a537046e12e3dbcca8b7c232114e464a29293086f22d25a44a807911880a4b682291020d2430cae8480020142446984e2852879bc221e600410af3032b064cfd6bf172803e40032136010ccf74bf079143c542023986c9169028eca8e19d13f4aed90734c507c44011f660c0f24003226c4ca4bae2447c50
202f904c08411d36f84bcd2905213e798a9f834363ec018af510e070d8f8b0605d200086670be09cc02810231d2038c2c8032be120008050661a1149c71a2e698940a52d331a5938b326162d58c1896225c503864103268c981c6666bcc93ab116b061ab325d958585da22ee95881493e02cc8c8e362ede998a3457181bb2211
a58d8a9f96669599f9400023a5c98a3a91233b946bb9609c50389c123eac1989f2620a9a64bba907358ca6d4b30fc203cba00001337003894c0f4004a960b418d32106b500c90912b3513119d246063748900d64455d8084df073c2ec12444b108d12664b4c1500db274c1d93004405c0d980851798100c6a01121840e895411
ae4aab85338382a68cfa6588c6883231a28a804211a48b866d238056026b9192e14280a061b2a21c8c6a10a11a2c883ad1103b640640722ec4440e4b15808689522a24cc0e2ad9bbe6064b0a01184680aa05b44a896e0a2cc00406b08e010a556012e84800202c70c6849e75d6839b4113e68199f2b0e2f194c28edd25e14083
7040e11000f9e0207c706090d2e7e1e5c99966226d1858aa111a2389eb71260b4487b0660b0729886323a2f29fe87c65d999187622cca59982623ecc140cda203ca7c80302f204cdb129f230c0ff9010078460c89002146c38071d20a06213300fa60c00204893a14904c9385f54a13c0d85241344f17a1104d03015c4228250
5e0802274a8f1023121809c9020a05410691174683ac3aee4084281007160408296a3029e416827a36b30000a4187a09c0d161b86b009646aa88868b9272485950acc32c8a1454c0f00000a0ab611c00783b230c1ed9074e1692c82126b20dc2030233ab0379dd90097083691c22382b6c050ed823221e18cb8120bcd0c2e300
20ae001fd4c0f00014978b008d300103408904d003691c0ac30300b490c940a43209812c843248690d841453e00d22380c63f990318744761afdca0043031198d143221412c08366b241c1c70436f118ee823420600c8a542be09c3a5a0b2b041ac1406000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0a9cca8816c162300000b0120600012100c10100466013000c00320c04230100c21100c32013000680320c04233110c30125510281041b3123582209057368532d217362432b93127b45325522614033c6012841
21ca884b14c1401f6206020304042110201d000d0210855018007218100980124d152266110005029221100120025032101a042102012880606a1004c300424110c44048542644431620082732181709a2008073
1458404002c311c82026d101400110e220510219a340133128c03060203c4072073408053015070b021185401c046110140aa010414516842152322462120a2205254224441122408242210560f2442850600950
d783323922d301526109e13254432862206143359060d3742a50323c42012240a232191603411623e013284026d341602038a260f12239802254402862422d4406024199511c23512c1016213102362762118c06
0562291910222062423950609701285031bb72011570ba351e91136d5114a711cc01265340286205376296401994411336314550aa70049542244512044126151e26108a360091118c4315f142244310e240e842
2ab698362850301d0216116172350ca0126b0014a4125e26072630590604b702664021c7416066311062bd011c95026555120451aa261711219a3104b3126c4331c522a830181532cb521a8622a6613015236a42
5396608d0cb521a8622a25121a521a4222392121d6418d151ae130e12322b6111d6038d1618c170ed032b22322b602ad2418c261a40707223168612856238802186210e54404623136452956204c350a64201523
935b34363a8341ae050a6462f221139302a9302cc151ae03272232296121525388342cc350d5602ea2323615294260c8150e746052232b1511b71429036362050e54321a41135142913606a150a7410126526b41
0808688a1aa050d34320a2123074398341cc3528a6311031040100c80000022083020286400040090100c810100220830206862004401e0100d8002580008107124622b5071174012511100303d6222a65420d44
c99654e6283262e2430b22101266384132c404016601404601d040e001181140526110005029201e001113340424110c04058202c405217200404201d0026404130440a22439d2139c0305b301491627f2119417
0c10584207331194150ba71145260f33219115045043c21205a072801428242029222185020155022551b00225250208402304715150201650520114d2008435044002d620301520116414406165050047601d00
5c8a669a05371100050292018001113340426110c060582028405017200404201d060d02128504012601022402d20140431695214a3122e2126a2215a442962630e2209a332581329e602c5462a166091161ba11
97629b26144552a84116b3406a043d6202477211d5704021234043937014007015040a0013851405151304060316010005316340c20110d00058202c405213300400301d06253552a2151a950169511223522e11
51c1048438e210ab3235c0325e402d6240a65219227298522e54434d52236651a0561b217199532db07274053963024363017200b8253e504012601004502d241e001101140c27110d0506960120051162004242
99ec975c2440401e2032d660f2261bb3618b7004d53239452ea20376121927238e270c3362dc03255542d66532e460b216390112df7024d3422a750e23737b010ef43365343a66631326279121dd012c53522545
a42299533a1263b0311a95325a2526e4536d2413a711d23727d5303d4526d3036617102303040201000202020831402064002002eb04008101000228310028600060226904028402030228f00120600062610060
961c90a504915058022090032a10386152255418745224141e250262133414110c0426200116200824311d040504038404012601422601d020d84124d1025441100450292418001113340424110c040667019213
0606384906346310141724120e260a345249541811702d3119802053501c11603e312940600f0106030384440012221d060602030404221701400701502098012451626661100440212617001216340401110c01
838c1d60009462250718046101140a2111c8012ad5010441228400763018053003300b15305d0526840366001264018226090122d80022d1317a6102232345013aa2014042214240923008523059400d4052a504
78dbd25e034361b210189112473500c0207a2018020017310024339d0406700116032fd413a55614b3515e0727e2239666287351ac47179321da311da23211342bd231e95134555267651ae66179341e26039954
68394e6a36a272be603c5421b3760694317a743d62328b222df321a0131995334f3522a713686715a762e623307160e63526f710d6472bd551e121168020d7201f1513852315b022d32012951357232526729d26
708000ec34d151ce520d3771a81717a333c646294041a3502e623307562a6041a740216222b7760a94317b141ba3318f310db730085308022121010000320a00230400040230a000204200003382040200400511
868c3421000031ca043304022014120000ae34298021ad223e246298411b504095051b163224740c4273c81432c603212000d00000000a06008006237141a04010914022713880506b101400328a200e15231805
493a49d023b700c22721c120501010100274241a042183360115309d05069102e445305741024210e440c651260132094009b7013032300063802120024084010202000d0020a4425d5426447306220126008236
084862e30695036441126640a046110120121012146115140a66118150001103450522e6006226138221d2212811225f3104c4702c10020413880506b101400320e300e22331802052602a40213c500c04721451
1468614103261080440030414a511400522f3016110102100c15024d71120572a82116a103533224d1000812231323806418e042021404242009001404118c06069301400121e200626311d02052202840601970
462251d10a0411851605351180050293006060042762363719a132c7312153128e6325b6627620382342a723198560f3153c50122d501e2650a306131001010623d201a041101140623118c07069301400121e20
6619188906a203640609a401412721d020d84128013118530da752651132e6104276236071fa222cf322155128a652455623444042242a7323955128c040650001d0108a21345062166018216225211d04128514
190c5860071341a00119b302640211d0506a203600620a4404956274471b0420133611230082730195408045041742260719a622d7322137128c4727b643e62030520068303c40511b300423321d020f22122506
c2010eac23d201a041101142633118e2700010132151aa611611211a3124a6327e061b8421c3262956229c4607376396202832004440249340cd11194031044231d1111010040002186411010042100c04200022
41420e9020020002100c0420000202300284042040004201014022d1140892312651048320915636e700dd620d71436040099151282226e3509621175151dc5320f0405a300d80121d0405040384042265018026
0848c26104d102657110044032241400211f300424120c02070442e4061172008273011110e841341142824020d140184104c06276101804100f200d22209c02051502844321d500c047118040e2303851106b71
d54656661122009a3203111190212ec020945028044225441a042121140bf111ca1026d501404122e2626b0215a532462028e2221d4225076396402b77208157099552e00534622272563640515641119510da42
82a9ce43032252ad6028e252654639446193342a52311d00354562e54539d352ee63355161e95135d352de4325d161695335f351d25729d151693325f311d2572bb251a63239460131710ee420f4343a60013d65
6c19606b3a61413d6501c422eb003661712a710ca2714c023440637666382362bf721d1452dd15365453ad56073761a2271db311e55335d3526a6236e2617a701d7272317535d361e5442062601a721500729d00
00100000051551a0051a930161511123506a6116c0617a303c62521f32058532550128e21245462144619224049032662102b622ac00105560a8031623102b6229c2030942000000000000000000000000000000
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
000e00001863519600186351863518600186351863500600185001863518600006001863500600156001560016600006001863500600131001310013100131000010000100001000010000100001000010000100
000e0000130400e0001104010040130000e0400c0400e000110000b0402d0000e0400c0400c000270000b000210001e00018040160001d0001910015700122000f200112000e2000b20007200042000320001200
010e00000c5500c5000e5501055010500115501355013500155501755015550175501855018530185201851018510185000c5500c5300c5200c51007500055000150013500135001450015500155001550016500
00180000106153e6053d6050e6050e61538605366050c6050c6152f600076152b6000061527600266002460023600226001f6001e6001c6001a60019600166001560013600106000f6000c600096000760004600
00180000105400c5400c5100b5400c5400c5100e5400e5100c5400c510075400751000540005100b3000520003400004000040000400004000040000400004000040000400004000040000400004000040000400
001800001c25018250182001a25018250222001725017200182502620018300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100001955015550115501454010540115300d5300b530095300f5200c520095200a51007510045000250001500005000050000500005000050000500005000050000500005000050000500005000050000500
010400000f1620f1520f1520f1521b1621b1521b1521b1521b1421b1421b1321b1321b1221b1221b1121b11200102001020010200102001020010200102001020010200102001020010200102001020010200102
010200003f6123f3723f6123f3723f6123f3623f6123f3623f6123f3523f6123f3523f6123f3423f6123f3423f6123f3323f6123f3323f6123f3223f6123f3223f6063f3223f6063f3223f6063f3123f6063f312
01060000151601553017160175301816018530171601753017520175101a1601a5301816018530185201851018000180002416024530245202451000000000000000000000000000000000000000000000000000
0103000018356183561c3561c3561f3561f356243562435628356283562b3562b356303563035630354303522b3003030030300343003430037300373003c3003c3003c3003c3003c30000300003000030000000
010300000c3560c3561035610356133561335618356183561c3561c3561f3561f356243562435628356283562b3562b3563035630356343563435637356373563c3563c3463c3343c3243c3123c3120030000300
000100003d2703927035270302702d26029260332602e2602a250262502d2502925025250222402724025240212401e2401a240162301d2301923015230122300f220112200e2200b22007210042100321001210
00010000301602f6602f1602e6602e1602d6602c1602b6602a160296602616024660211601e6501c1501965017150136400f140106400e1300b63007130056200112013100131001410015100151001510016100
000200003e6703e6703d6703c6703a670386603666034660326602f6502d6502b6502965027650266502464023640226401f6401e6401c6301a63019630166201562013620106200f6200c610096100761004610
010100001b4611d4611e461204512145121451204411f4411d4411b431194311642113411104000b4000540003400004000040000400004000040000400004000040000400004000040000400004000040000400
000100001b3611d3611e3611f36120361223512335124341243412633126331003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
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
04 31 30 2f 44
04 34 33 32 44
