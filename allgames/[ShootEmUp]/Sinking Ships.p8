pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- sinking ships
-- by musurca

function a()
b={
c("0, 0,0,0,0"),
c("1, 0,0,0,0"),
c("2, 0,0,0,0"),
c("3, 0,0,0,0"),
c("4, 2,0,0,0"),
c("5, 5,1,0,0"),
c("6, 5,1,0,0"),
c("7, 6,5,1,0"),
c("8, 8,2,2,0"),
c("9, 4,2,0,0"),
c("10, 10,10,10,0"),
c("11, 3,0,0,0"),
c("12,13,13,1,0"),
c("13, 5,1,0,0"),
c("6, 5,1,0,0"),
c("15, 4,2,0,0")}
local d=0x4300
for e=1,5 do
for f=1,16 do
poke(d,b[f][e])
d+=1
end
end
end
g=1
function h(t)
local i=band((1-t)*4.5,0xffff)
if(i==g) return
g=i
memcpy(0x5f00,0x4300+0x10*i,0x10)
end
function j() end
function k(l,m)
return sub(l,m,m)
end
function n(o,l)
for m=1,#l do
if(k(l,m)==o) return m
end
return false
end
p="0123456789"
function c(l)
local q,r={},""
local function s()
if(n(k(r,#r),p)) r=tonum(r)
add(q,r)
r=""
end
for m=1,#l do
local o=k(l,m)
if o==","then
s()
else
r=r..o
end
end
s()
return q
end
function u(q)
return q[flr(rnd(#q))+1]
end
function v(w)
return rnd(w)-shr(w,1)
end
function x(y,z)
for m=1,#z do
del(y,z[m])
end
end
function ba(bb,bc)
local bd,be=abs(bb),abs(bc)
return max(bd,be)*0.9609+min(bd,be)*0.3984
end
function bf(bg,bh)
local bi=ba(bg,bh)
if(bi>0) return bg/bi,bh/bi,bi
return bg,bh,0
end
function bj()
return peek2(0x5f28),peek2(0x5f2a)
end
bk={}
function bl(bm,bn)
add(bk,{cocreate(bm),bn})
end
function bo(bp,bg,bh,bq,br,bs)
local bt,bu=bv[2],{bg,bh,1,0,0.6,bq,br,0,0.991,false,bs,0,false,false,false,bg,bh,bw=true,bx=bp}
by[#by+1],bt[#bt+1],bz[#bz+1]=bu,bu,bu
end
function ca()
local cb,cc,bu,cd,ce,t,cf,cg,ch,ci,cj,ck=by,{}
for m=1,#cb do
bu=cb[m]
cf,cg,ch,ci=bu[1],bu[2]+bu[3],bu[16],bu[17]+bu[3]
for m=1,#cl do
cd=cl[m]
if cd!=bu.bx and cd.cm<2 then
ce,t=cn(cd,ch,ci,cf,cg)
if ce!=co then
cj,ck=ch+t*(cf-ch),ci+t*(cg-ci)
sfx(3)
cp(cd,10,ce,cj,ck)
cc[#cc+1],bu[11]=bu,0
goto skiploop
end
end
end
if bu[11]<1 then
cr(cs,
bu[1],bu[2],0,
7,0.5,0,0,0,1,false,10,0.1,false,false,false)
cc[#cc+1]=bu
end
bu[16],bu[17]=bu[1],bu[2]
::skiploop::
end
x(by,cc)
end
ct,cu,cv=-1,0,1
function cw(bn)
local cx=bn[1]
if(cx.cy<=0) return
if(cx.cz>0) return
local da,db,dc,dd,de,df,f,dg,dh,di,dj=bn[2],mid(0,1,bn[3]/120),cx.dk,600
if(dl==dm) dd/=2
cx.cz=dc.dn
sfx(dc.dp)
dq=max(20,dc.dr*db)
cx.ds=da
for m=1,dc.dt do
f=0.6*(1+(dc.dt/2)-m)
dg,dh,di,dj=cx.du*da,cx.dv*da,cx.di,cx.dj
de,df=dg*3.5,dh*3.5
de+=cx.dw*f
df+=cx.dx*f
cr(dy,
cx[1]+de,
cx[2]+df,
1,
10,
1+rnd(1),
0,0,0,
0.95,
false,
3,
0.1,
false,
false,
false)
bo(cx,
cx[1]+de*2+v(6),
cx[2]+df*2+v(6),
dg*2+di,dh*2+dj,dq+v(0.1*dq))
for m=1,3 do
cr(dy,
cx[1]+de*1.5+v(4.5),
cx[2]+df*1.5+v(4.5),
1.1,
5,
3,
di+dg*rnd(2)+v(0.5),dj+dh*rnd(2)+v(0.5),0.02,
0.7,
false,
dd+v(150),
0.01,
true,
true,
true)
end
for m=1,12 do
yield()
end
end
cx.ds=cu
end
dz=c("12,12,12,7,7")
function ea(bn)
local cx,eb=bn[1],dz
while cx.cy>0 do
ec=cx.ec
if ec>0.1 then
local ed,ee=cx[1],cx[2]
local dw,dx,du,dv,ef=cx.dw,cx.dx,cx.du,cx.dv,sgn(v(2))
if 0.5+sin((2+ec)*t()/1.5)>0 then
cr(cs,
ed+4.25*dw+ef*1.25*du+v(1),
ee+4.25*dx+ef*1.25*dv+v(1),
0,
u(eb),
0.5,
1.5*ef*du*ec,
1.5*ef*dv*ec,
0,
0.96,
false,
40+v(20),
0,false,false,true)
end
if rnd()>0.5 then
cr(cs,
ed-4*dw,ee-4*dx,0,
u(eb),0.5,v(0.2),v(0.2),0,0.99,false,100+v(20),0,false,false,false)
end
end
yield()
yield()
yield()
end
end
function eg(bn)
eh=true
for m=1,240 do yield() end
eh=false
end
function ei(bn)
local cx=ej.cx
local ed,ee=cx[1],cx[2]
if(cx.cy>0) cx.cy=min(cx.dk.cy,cx.cy+ek[el[em.en]].cy/3)
if(eo>0) for m=1,180 do yield() end
eo+=1
ep=rnd(32700)
srand(eo)
local eq,er=rnd(),90+rnd(90)
for m=1,rnd(10) do es() et() end
em.cx=eu(el[em.en],ed+er*cos(eq),ee+er*sin(eq),rnd(),ev,true)
srand(ep)
bl(eg)
end
function ew(bn)
local cx,eb=bn[1],dz
if ex==ey then
if ej.cx==cx or ez!=fa then
bl(fb)
else
music(7,0,8)
bl(ei)
end
end
sfx(12)
fc=true
cx.fd,cx.fe=0,v(0.9)
while cx.cm<8 do
cx.cm+=0.5
for m=1,60 do
if rnd()>0.3 then
cr(cs,
cx[1]+cx.di,cx[2]+cx.dj,0,
u(eb),0.5,v(0.35),v(0.35),0,0.99,false,100+v(20),0,false,false,false)
end
yield()
end
end
ff(cx)
end
function fb(bn)
if ej.cx.cy<=0 and em.cx.cy<=0 then
fg=nil
elseif ej.cx.cy<=0 then
fg=em
else
fg=ej
end
if ez==fa or ez==fh or fg==ej then
music(4)
else
music(0)
end
for m=1,240 do yield() end
ex=fi
fj(ej,fk)
end
fl=c("12,12,7")
function fm(bn)
local fn,er=fl
while true do
er=1.333*128/fo
cr(cs,
fp+v(er),fq+v(er),0,
u(fn),0.5,0.05*fr,0.05*fs,0,1,false,35,0,true,false,false)
yield()
yield()
yield()
end
end
function ft(bn)
local fu=fv[fw]
fx,fy=rnd(),flr(fu[1]+rnd(fu[2]-fu[1]))
local fz,ga=gb,gc
for m=1,120 do
gb,gc=fz+m*(fx-fz)/120,ga+m*(fy-ga)/120
fr,fs=cos(gb),sin(gb)
yield()
end
end
bz,bv,cs,dy={},{},1,2
function cr(gd,bg,bh,fd,o,ge,bq,br,gf,gg,gh,gi,gj,gk,gl,gm)
local bt,bu=bv[gd],{bg,bh,fd,o,ge,bq,br,gf,gg,gh,gi,gj,gk,gl,gm,bw=true,gn=bh+shl(fd,7)}
bt[#bt+1]=bu
if(gd==dy) bz[#bz+1]=bu
end
function go(gp,gq,gr)
local bs,gs,cd,bi=gr,nil
for m=1,#cl do
cd=cl[m]
if cd.ds!=cu then
bi=ba(cd[1]-gp,cd[2]-gq)
if(bi<gr) bs,gs=bi,cd
end
end
return gs,bs
end
gt={0b1010010110100101.1,0b101101001011010.1}
function gu(gv,gw)
if gw then
local f,gx
for w=2,#gv do
f=w
gx=f-1
while f>1 and gv[f].gn<gv[gx].gn do
gv[f],gv[f-1]=gv[f-1],gv[f]
f-=1
end
end
end
local gy,gz=bj()
local ha,hb,hc,bu,hd,he,ge,hf,hg,hh,hi,hj,eb,hk,hl=gt,fo,dl==dm
for m=1,#gv do
bu=gv[m]
if bu.bw then
hd,he,ge,hh=(bu[1]-63)*hb+63,(bu[2]-bu[3]-63)*hb+63,bu[5]*hb,bu[4]
hk,hl=hd-gy,he-gz
if band(bor(hk+ge,hl+ge),0xff80)==0 and band(bor(hk-ge,hl-ge),0xff80)==0 then
hf=nil
if bu[15] and hc then
hf,hg=go(bu[1],bu[2],75)
if hf then
eb=b[hh+1]
hj=peek(0x5f00+hh)
hi=eb[6-band(5*(0.2+min(0.8,rnd(0.05)+15/(hg+0.01))),0xffff)]
poke(0x5f00+hh,hi)
end
end
if ge<1.5 then
pset(hd,he,hh)
else
if(bu[13]) fillp(ha[flr(hd)%2+1])
circfill(hd,he,flr(ge),hh)
if(bu[13]) fillp()
end
if(hf) poke(0x5f00+hh,hj)
end
else
hm(bu)
end
end
end
hn,ho=0,1
hp="01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz,.?!\"&();:'-"
function hq(l,bg,bh,hh,hr)
hr,hh=hr or ho,hh or 7
local ed,ee=bj()
ed,ee=ed+bg,ee+bh
if(hr==ho) ed=ed-#l*3
local hs,ht,hj,hu=ed,dl==dm and 2 or 0,peek(0x5f07),peek(0x5f00)
pal(7,hh)
pal(0,ht)
for bu=1,#l do
local o=k(l,bu)
if o=="\n"then
ee+=10 ed=hs
elseif o==" "then
ed+=6
else
local i=n(o,hp)-1
local hv,hw,hx=i%21*6,93+flr(i/21)*9,9
if(hw+hx>127) hx=127-hw
sspr(hv,hw,5,hx,ed,ee)
ed+=6
end
end
pal(0,hu)
pal(7,hj)
end
function hy(hz,ia,ib,hx,ic,id)
local ie,ig,ih,o=ib/2,hx/2,{}
for m=hz,hz+ia-1 do
for bh=0,hx-1 do
for bg=0,ib-1 do
o=sget((hz%16)*8+(m-hz)*ib+bg,flr(m/16)*8+bh)
if(o!=14) add(ih,{bg-ie+ic,bh-ig+id,m-hz,o})
end
end
end
return ih
end
function ii(hz,ia,ib,hx,ic,id)
local ie,ig,ih,ij=ib,hx,{}
local function ik(il,im,io,f)
add(ih,{il-ie+ic,im-ig+id,io,f})
end
for count=hz,hz+ia-1 do
local ip,iq,ir,is,bb,bc,o,bi,it,iu,iv,hx,m,iw,ix,iy,iz=(hz%16)*8+(count-hz)*ib,flr(count/16)*8,ib-1,hx-1
for bh=0,is do
for bg=0,ir do
local bq,br=ip+bg,iq+bh
it=sget(bq,br)
bb,bc,o,bi,iu,iv,hx,m=it,it,it,it,it,it,it,it
if(bh>0) bc=sget(bq,br-1)
if(bh<is) hx=sget(bq,br+1)
if bg>0 then
bi=sget(bq-1,br)
if(bh>0) bb=sget(bq-1,br-1)
if(bh<is) iv=sget(bq-1,br+1)
end
if bg<ir then
iu=sget(bq+1,br)
if(bh>0) o=sget(bq+1,br-1)
if(bh<is) m=sget(bq+1,br+1)
end
iw,ix,iy,iz=it,it,it,it
if bc!=hx and bi!=iu then
if(bi==bc) iw=bi
if(bc==iu) ix=iu
if(bi==hx) iy=bi
if(hx==iu) iz=iu
end
local ja,jb,fd=bg*2,bh*2,count-hz
if(iw!=14) ik(ja,jb,fd,iw)
if(ix!=14) ik(ja+1,jb,fd,ix)
if(iy!=14) ik(ja,jb+1,fd,iy)
if(iz!=14) ik(ja+1,jb+1,fd,iz)
end
end
end
return ih
end
jc=c("0,4,2,4,2, 4, 4,14, 8, 4, 4, 4,12, 4, 4, 4")
function jd(ih,ed,ee,je,hb,jf)
hb,jf=hb or 1,jf or 0
jg=jf-1
local jh,ji,bu,bg,bh,fd,bb,bc,o,jj=je+0.25,jc
local dw,dx=-cos(jh),-sin(jh)
if jf>0 then
if hb>1 then
local jk=jf%1
jg*=2
jf,hb=flr(jf*2),1
for m=1,#ih do
bu=ih[m]
bg,bh,fd,o=bu[1]*hb,bu[2]*hb,bu[3]*2,bu[4]
if fd>jg then
bb,bc,jj=ed+bg*dw-bh*dx,ee+bg*dx+bh*dw-fd+jf,ji[o+1]
if jk>0 and fd==(jf+1) then
pset(bb,bc+1,o)
pset(bb+1,bc+1,jj)
else
rectfill(bb,bc,bb,bc+1,o)
rectfill(bb+1,bc,bb+1,bc+1,jj)
end
end
end
else
jf=flr(jf)
for m=1,#ih do
bu=ih[m]
bg,bh,fd,o=bu[1]*hb,bu[2]*hb,bu[3]*hb,bu[4]
if fd>jg then
bb,bc,jj=ed+bg*dw-bh*dx,ee+bg*dx+bh*dw-fd+jf,ji[o+1]
pset(bb,bc,o)
pset(bb+1,bc,jj)
end
end
end
else
if hb>1 then
hb=1
for m=1,#ih do
bu=ih[m]
bg,bh,fd,o=bu[1]*hb,bu[2]*hb,bu[3]*2,bu[4]
bb,bc,jj=ed+bg*dw-bh*dx,ee+bg*dx+bh*dw-fd,ji[o+1]
rectfill(bb,bc,bb,bc+1,o)
rectfill(bb+1,bc,bb+1,bc+1,jj)
end
else
for m=1,#ih do
bu=ih[m]
bg,bh,fd,o=bu[1]*hb,bu[2]*hb,bu[3]*hb,bu[4]
bb,bc,jj=ed+bg*dw-bh*dx,ee+bg*dx+bh*dw-fd,ji[o+1]
pset(bb,bc,o)
pset(bb+1,bc,jj)
end
end
end
end
ek={}
function jl(bn,jm,jn)
local jo,hz,ia,ib,hx,ic,id,jp,jq=bn[1],jn[1],jn[2],jn[3],jn[4],jn[5],jn[6],jn[7],jn[8]
local cx={jr=jo,
js=bn[2],
dt=bn[3],
dp=bn[7],
jt=bn[8],
ju=jm,
dr=bn[4],
dn=bn[5],
cy=bn[6],
jv=hy(hz,ia,ib,hx,ic,id),
jw=ii(hz,ia,ib,hx,ic,id),
jx={-jp/2,-jq/2,jp/2,jq/2},
jy=max(jp/2,jq/2)}
ek[jo]=cx
end
jz,ev=8,12
function eu(ka,bg,bh,eq,kb,kc)
local dc=ek[ka]
local cd={bg,
bh,
1,
dk=dc,
jv=dc.jv,
jw=dc.jw,
cy=dc.cy,
ec=0,
di=0,
dj=0,
fe=0,
cm=0,
je=eq,
dw=cos(eq),
dx=sin(eq),
kb=kb,
kd=kc or false,
ke=0,
kf=0,
bw=false,
ds=cu,
kg=ct,
cz=0,
h=0,
gn=bh+128}
cd.du,cd.dv=-cd.dx,cd.dw
add(bz,cd)
add(cl,cd)
bl(ea,{cd})
return cd
end
function ff(cd)
cd.cy=0
if(ej.cx==cd) ej.cx=nil
if(em.cx==cd) em.cx=nil
del(bz,cd)
del(cl,cd)
end
kh=c("4,4,2,0")
function cp(cd,ki,kj,cj,ck)
if(cd.cy<=0) return
if kj==kk then
ki*=1.75
elseif kj==kl then
ki*=2.5
else
local km,kn,ko=bf(cj-cd[1],ck-cd[2])
local kp,kq=max(0,kj*cd.du*km+kj*cd.dv*kn),ki
ki=(0.5*kq)+0.5*kp*kq
end
cd.cy-=ki
local eb,kr,ks=kh,cd.di,cd.dj
for m=1,6 do
cr(dy,cj,ck,1.1,u(eb),0.6,kr+v(0.2),ks+v(0.2),0.6+rnd(0.5),0.99,true,240,0,false,false,true)
end
if(cd.cy<=0) bl(ew,{cd})
end
function kt(cd)
cd.je+=max(0.325,3*cd.ec)*cd.fe*0.01
cd.dw,cd.dx=cos(cd.je),sin(cd.je)
local dw,dx=cd.dw,cd.dx
cd.du,cd.dv=-dx,dw
local du,dv=cd.du,cd.dv
if cd.kd and cd.cy>0 then
local ku,kv,kw,kx,ky,kz=ej.cx,0,0,0
if(cd==ku) ku=em.cx
if ku then
kv,kw,kx=bf(ku[1]-cd[1],ku[2]-cd[2])
ky=du*kv+dv*kw
if cd.cz==0 and ku.cy>0 and kx<0.75*cd.dk.dr and abs(ky)>0.9 and rnd()>0.1 then
bl(cw,{cd,sgn(ky),120})
end
end
if(kx>250) cd.kf=1
if cd.kf==1 then
local la=(dw*kv+dx*kw+1)/2
cd.fe=-sgn(ky)*(1-la)
if(kx<120) cd.kf=0
elseif cd.ke<=0 then
cd.fe=v(0.6)
cd.ke=200+flr(rnd(40))
end
cd.ke-=1
end
local lb,lc,ld,le,lf,lg,lh=cd.di,cd.dj,0,0,0,0,0
if cd.cy>0 then
local lh,li=mid(-1,0.9999,dw*fr+dx*fs),cd.dk.ju
local lj,lk=((lh+1)/2)*(#li-1)+1
local ll=lj%1
lj=flr(lj)
lk=(1-ll)*li[lj]+ll*li[lj+1]
lh=lk*gc/(cd.dk.jt*1024)
lf,lg=lh*dw,lh*dx
end
ld,le=lb+lf,lc+lg
local lm=max(0,ld*dw+le*dx)
lm=-0.05*lm*lm/2
local ln,lo=lm*ld,lm*le
lm=abs(ld*du+le*dv)
lm=-0.75*lm*lm/2
local lp,lq=lm*ld,lm*le
ld,le=ld+ln+lp,le+lo+lq
local lr,lt=cd[1],cd[2]
cd[1]+=ld
cd[2]+=le
cd.gn=cd[2]+shl(cd[3],7)
local function lu(cx,kj)
if(kj==kk) return cx.dw,cx.dx
if(kj==lv) return cx.du,cx.dv
if(kj==lw) return-cx.du,-cx.dv
return-cx.dw,-cx.dx
end
if cd.cy>0 then
local lx,ly,lz
for m=1,#cl do
lx=cl[m]
if cd!=lx then
ly,lz=ma(cd,lx)
if ly!=co then
local mb,mc,md,jt,me=0,0,0,cd.dk.jt,lx.dk.jt
local mf,mg=lu(lx,lz)
local mh,mi,mj=bf(ld,le)
if mj>0 then
local mk,ml=-mh,-mi
local mm=mk*mf+ml*mg
local mn,mo=2*mm*mf-mk,2*mm*mg-ml
mm=max(0,-mm)
ld+=mn*mm*mj
le+=mo*mm*mj
mj*=me
md=mm*mj
mb,mc=-mf*mm*mj,-mg*mm*mj
end
local mp,mq=lx.di,lx.dj
local mr,ms,mt=bf(mp,mq)
if mt>0 then
local mu=min(1,max(0,mr*mf+ms*mg))
ld+=mu*mp
le+=mu*mq
mt*=jt
mb+=-mf*(1-mu)*mt
mc+=-mg*(1-mu)*mt
md+=mu*mt
end
local de,df=lx[1]-cd[1],lx[2]-cd[2]
cd[1],cd[2]=lr+ld,lt+le
if lx.cy>0 then
lx.di+=mb
lx.dj+=mc
lx.ec=ba(lx.di,lx.dj)
end
sfx(11)
md*=5
if md>1 then
local cj,ck=cd[1]+de/2,cd[2]+df/2
cp(cd,md,lz,cj,ck)
cp(lx,md,ly,cj,ck)
end
end
end
end
end
cd.di,cd.dj,cd.ec=ld,le,ba(ld,le)
if(cd.cz>0) cd.cz-=1
if cd.ds!=cu then
cd.h=rnd(0.5)
if dl==dm then
local mv=cd.h*18
cr(cs,cd[1]+mv*cd.ds*du,cd[2]+mv*cd.ds*dv,0,7,mv,0,0,0,1,false,1,0,false,false,false)
end
else
cd.h=0
end
if(not cd.kd) cd.fe*=0.95
end
function hm(cd)
local jv,hd,he=(fo>1) and cd.jw or cd.jv,(cd[1]-63)*fo+63,(cd[2]-63)*fo+63
if dl==dm then
if cd.ds!=cu then
h(min(1,1-0.5+cd.h*(cd.ds*cd.dv+1)/2))
else
local hf,hg=go(cd[1],cd[2],200)
local mw=0
if(hf) mw=min(0.6-rnd(0.3),rnd(0.05)+20/(hg+0.01))
h(0.2+mw)
end
else
if cd.ds!=cu then
local mv=cd.h*12*fo
circ(hd+cd.ds*mv*cd.du,he+cd.ds*mv*cd.dv,mv,12)
end
end
if(cd.cy>0) pal(6,cd.kb)
jd(jv,hd,he,cd.je,fo,cd.cm)
pal(6,6)
if(dl==dm) h(0.2)
end
co,lw,lv,kk,kl=0,-1,1,2,3
function mx(my,mz,na,nb,nc,nd,ne,nf)
local function ng(my,mz,na,nb,nh,ni,nj,nk)
local nl,nm=((nj-nh)*(mz-ni)-(nk-ni)*(my-nh))/((nk-ni)*(na-my)-(nj-nh)*(nb-mz)),
((na-my)*(mz-ni)-(nb-mz)*(my-nh))/((nk-ni)*(na-my)-(nj-nh)*(nb-mz))
if(nl>=0 and nl<=1 and nm>=0 and nm<=1) return true,min(nl,nm)
return false
end
local nn,no,t,np=co,2
np,t=ng(my,mz,na,nb,nc,nd,nc,nd+nf)
if np then
no=t
nn=kl
end
np,t=ng(my,mz,na,nb,nc+ne,nd,nc+ne,nd+nf)
if np and t<no then
no=t
nn=kk
end
np,t=ng(my,mz,na,nb,nc,nd,nc+ne,nd)
if np and t<no then
no=t
nn=lw
end
np,t=ng(my,mz,na,nb,nc,nd+nf,nc+ne,nd+nf)
if np and t<no then
no=t
nn=lv
end
return nn,no
end
function cn(cx,my,mz,na,nb)
local nq,ed,ee=cx.dk.jy,cx[1],cx[2]
local nr,ns,nt,nu=my-ed,mz-ee,na-ed,nb-ee
if(ba(nr,ns)>nq and ba(nt,nu)>nq) return co,2
local jx,nv,nw=cx.dk.jx,cx.dw,-cx.dx
local nx,ny,nz,oa,ob,oc,od,oe=nr*nv-ns*nw,nr*nw+ns*nv,nt*nv-nu*nw,nt*nw+nu*nv,jx[1],jx[2],jx[3]*2,jx[4]*2
return mx(nx,ny,nz,oa,ob,oc,od,oe)
end
function ma(of,og)
local oh,oi,oj,ok,ol,om=of.dk.jy,og.dk.jy,of[1],of[2],og[1],og[2]
if(ba(ol-oj,om-ok)>(oh+oi)) return co,co
local on,oo,nv,nw=of.dk.jx,og.dk.jx,og.dw,-og.dx
local op,oq,os,ot,ou,ov,ow,ox=on[1]+oj,on[2]+ok,on[3]*2,on[4]*2,oo[1],oo[2],oo[3]*2,oo[4]*2
local oy,oz,pa,pb=op-ol,oq-om,(op+os)-ol,(oq+ot)-om
local pc,pd,pe,pf=oz,pa,pa,pb
local function pg(bg,bh)
return bg*nv-bh*nw,bg*nw+bh*nv
end
local nx,ny=pg(oy,oz)
local nz,oa=pg(pa,pc)
local ph,pi=pg(pd,pb)
local pj,pk=pg(pe,pf)
local pl=mx(nx,ny,nz,oa,ou,ov,ow,ox)
if(pl!=co) return kk,pl
pl=mx(nz,oa,ph,pi,ou,ov,ow,ox)
if(pl!=co) return lv,pl
pl=mx(ph,pi,pj,pk,ou,ov,ow,ox)
if(pl!=co) return kl,pl
pl=mx(pj,pk,nx,ny,ou,ov,ow,ox)
if(pl!=co) return lw,pl
return co,co
end
function pm()
gb=rnd()
fr,fs,gc=cos(gb),sin(gb),flr(6+rnd(10))
end
dm,pn=0,1
dl=pn
function po(pp)
dl=pp
h(1)
if(pp==dm) h(0.2)
end
pq,fh,fa=1,2,3
ez=pq
cl={}
function pr()
bk={}
if(bv[2]) x(bz,bv[2])
bv[1],bv[2]={},{}
by={}
for cd in all(cl) do
del(bz,cd)
end
cl,fo={},1
bl(fm)
end
ps,el={pn,dm},c("sloop,xebec,brig,line")
function pt()
pr()
pm()
ej.cx=eu(u(el),rnd(200),rnd(200),rnd(),jz,true)
em.cx=eu(el[flr(rnd(3))+1],rnd(200),rnd(200),rnd(),ev,true)
po(u(ps))
end
function pu(kd)
ex,eh,eo=ey,false,0
fj(ej,nil)
fj(em,nil)
pr()
local pv,hq=0.5+v(0.125),70+rnd(90)
local gp,gq=hq*cos(pv),hq*sin(pv)
ej.cx=eu(el[ej.en],gp,gq,v(0.4),jz,false)
if ez==fa then
bl(ei)
else
em.cx=eu(el[em.en],-gp,-gq,0.5+v(0.4),ev,kd)
bl(eg)
end
po(ps[pw])
bl(ft)
end
function _init()
a()
pal(14,6)
px,py,pz,qa=hy(40,5,5,16,1,0),c("ACHERON,ACHILLE,AIGLE,AJAX,ARGO,AQUILON,ARIADNE,BACCANTE,BELLONA,BERMUDA,BILLY-BOY,CAESAR,CALCUTTA,CANADA,CHARON,CIRCE,COLOSSUS,CULLODEN,CUTTY SARK,DART,DIADEM,DIANA,ESSEX,FLAMBEAU,GANGES,GIBRALTAR,GOLIATH,HARPY,HELLFIRE,HIBERNIA,ISIS,JAVA,JUPITER,LEANDER,LIVELY,MAJESTIC,MALTA,MANLY,MARS,NAIAD,NAMUR,NELSON,NEPTUNE,NYMPHE,ORION,PALLAS,PEGASUS,POLYCHREST,PROVIDENT,QUEEN,RENOWN,REPULSE,REQUIN,RIVOLI,ROMULUS,SATURN,SCIPION,SOPHIE,STATELY,ST.ALBANS,SUPERB,SURPRISE,TERROR,THALIA,THAMES,THESEUS,ULYSSES,VALIANT,VENUS,ZEPHYR"),{{"          ",qb},{"          ",qc}},{{"          ",qd},{"          ",qe},{"ENGAGE!",qf}}
qg,qh,qi,qj,qk,ql,qm,fk,qn,qo=qp({{"1P Encounter",qq},{"2P Encounter",qr},{"Survival",qs}},13),qp(pz,14,qt,j,qu,j,function(bu) fj(bu,qi)
qi.qv=qh.qv end),qp({{"          ",et},{"          ",es}},14,qt,j,qu,function(bu) fj(bu,qh) qh.qv=qi.qv end,j),qp(qa,14,qt,function(bu) fj(bu,qh) end),qp(pz,14,qt,j,function(bu) fj(bu,qm) end),qp(pz,14),qp(qa,14,qt,function(bu) fj(bu,qk) end),qp({{"Replay",pu},{"Back to Menu",qt}},14),qp(pz,14,qt,j,function(bu) fj(bu,qo) end),qp({{"ENGAGE!",qf}},14,qt,function(bu) fj(bu,qn) end)
jl(c("line,Man o'War,10,160,260,250,7,1.75"),
c("0, 0.25,  0.4, 0.55,  0.6, 0.75,  0.8, 0.82, 0.84, 0.86,  0.9, 0.95, 1.0"),
c("0,8,7,16,1,-1,16,8"))
jl(c("brig,Brigantine,6,160,200,210,8,1.25"),
c("0, 0.25, 0.45,  0.6,  0.7,  0.8,  0.9, 0.92, 0.95,  1.0, 0.95, 0.92, 0.9"),
c("7,8,7,16,1,0,12,6"))
jl(c("xebec,Xebec,4,140,150,180,9,0.7"),
c("0,  0.4,  0.6, 0.75,  0.8,  0.9,  1.0,  0.9,  0.8, 0.75,  0.5,  0.4, 0.3"),
c("32,8,3,16,1,0,12,4"))
jl(c("sloop,Sloop,2,100,100,140,10,0.6"),
c("0,  0.6, 0.75,  0.8,  0.9,  0.9, 0.95, 0.96, 0.99,  1.0,  0.9, 0.85, 0.8"),
c("35,7,5,16,1,0,9,4"))
qw={}
for m=1,2 do
local bu={cx=nil,
en=1,
qx=flr(rnd(#py))+1,
qy=false,
qz=ct,
ra=0,
rb=nil}
qw[m]=bu
end
ej,em=qw[1],qw[2]
ej.kb,em.kb=jz,ev
qc(ej)
qt()
end
function qt()
ex=rc
fj(ej,qg)
fj(em,nil)
pt()
end
rd={c("0,0,0,0,0,0"),
c("0,0,0,0,0,0")}
function re(bc,rf)
if(not rf.cx) return
if(rf.cx.kd) return
if rf.qy and((bc==4 and rf.qz==ct) or(bc==5 and rf.qz==cv)) then
rf.qy=false
bl(cw,{rf.cx,rf.qz,rf.ra})
rf.ra=0
sfx(6,-2)
end
end
function rg(bc,rf)
if ex!=ey then
local rh={ri,rj,rk,rl,rm,rn}
if(bc<4) sfx(1)
if(rf.rb) rh[bc+1](rf,rf.rb)
return
end
if(not rf.cx) return
if(rf.cx.kd) return
if(bc==4 or bc==5) and not rf.qy then
if rf.cx.cz==0 then
rf.qz=bc==4 and ct or cv
rf.qy=true
rf.ra=0
sfx(6)
else
sfx(1)
end
end
end
function ro(bc,rf)
if(not rf.cx) return
if(rf.cx.kd) return
if(rf.qy and((bc==4 and rf.qz==ct) or(bc==5 and rf.qz==cv))) rf.ra+=1
if(bc==0) rf.cx.fe+=0.01
if(bc==1) rf.cx.fe-=0.01
end
function _update60()
if(rnd()>rp[fw]) bl(ft)
for bu=0,1 do
for f=0,5 do
if btn(f,bu) then
if not rd[bu+1][f+1] then
rd[bu+1][f+1]=true
rg(f,qw[bu+1])
end
ro(f,qw[bu+1])
elseif rd[bu+1][f+1] then
rd[bu+1][f+1]=false
re(f,qw[bu+1])
end
end
end
local rq,rr,bi,cc,bs,cd=0,0,0,{}
for m=1,#cl do
cd=cl[m]
kt(cd)
if cd==ej.cx or cd==em.cx then
rq,rr=rq+cd[1],rr+cd[2]
cc[#cc+1]=cd
end
end
rq,rr=rq/#cc,rr/#cc
for m=1,#cc do
cd=cc[m]
bs=2*ba(cd[1]-rq,cd[2]-rr)
if(bs>bi) bi=bs
end
cc={}
if fo==1 then
if bi>120 then
fo=0.5
elseif bi<50 and#cl<3 then
fo=2
end
elseif fo==2 then
if bi>=64 then
fo=1
end
elseif fo==0.5 then
if bi>250 then
fo=0.25
elseif bi<115 then
fo=1
end
else
if(bi<240) fo=0.5
end
if fp then
fp,fq=fp+(rq-fp)/24,fq+(rr-fq)/24
else
fp,fq=rq,rr
end
camera(flr(fp*fo-63*fo),flr(fq*fo-63*fo))
local it,rs={}
for m=1,#bk do
it=bk[m]
rs=it[1]
if costatus(rs)!='dead'then
coresume(rs,it[2])
else
add(cc,it)
end
end
x(bk,cc)
cc={}
local rt,ru,rv,rw,bu,bq,br,gf,fd,gg,gi=bv[1],bv[2],fr*gc/256,fs*gc/256
for m=1,#rt do
bu=rt[m]
gi=bu[11]
if gi>0 then
bq,br,gg=bu[6],bu[7],bu[9]
bu[1]+=bq
bu[2]+=br
bu[5]+=bu[12]
bq*=gg
br*=gg
gi-=1
bu[6],bu[7],bu[11]=bq,br,gi
else
cc[#cc+1]=bu
end
end
x(rt,cc)
cc={}
for m=1,#ru do
bu=ru[m]
gi=bu[11]
if gi>0 then
fd,bq,br,gf,gg=bu[3],bu[6],bu[7],bu[8],bu[9]
if(bu[10]) gf-=0.03
fd+=gf
if fd<0 then
cc[#cc+1]=bu
else
if bu[14] then
bu[1]+=bq+rv
bu[2]+=bq+rw
else
bu[1]+=bq
bu[2]+=br
end
bu[5]+=bu[12]
bq*=gg
br*=gg
gf*=gg
gi-=1
bu[3],bu[6],bu[7],bu[8],bu[11],bu.gn=fd,bq,br,gf,gi,bu[2]+shl(fd,7)
end
else
cc[#cc+1]=bu
end
end
x(ru,cc)
x(bz,cc)
ca()
end
rc,rx,ry,rz,ey,fi=0,1,2,3,4,5
function qp(sa,sb,sc,sd,se,sf,sg)
sf,sg,sc,sd,se=sf or j,sg or j,sc or j,sd or j,se or j
local sh,ib={si=sb,
qv=1,
sj=sc,
sk=sf,
sl=sg,
sm=sd,
sn=se,
so=false,
rf=nil},0
for m=1,#sa do
if(#sa[m][1]>ib) ib=#sa[m][1]
sh[m]=sa[m]
end
sh.sp,sh.sq=#sa,ib*6
return sh
end
function sr(ss,bg,bh)
local ee,ib=bh,ss.sq/2+1
local st,su=bj()
for m=1,ss.sp do
if(ss.qv==m and ss.so) rect(bg+st-ib-1,ee+su-2,bg+ib+st-1,ee+su+9,7)
hq(ss[m][1],bg,ee)
ee+=ss.si
end
end
function fj(rf,ss)
if(rf.rb) rf.rb.so=false
rf.rb=ss
if(ss) ss.so=true
end
function rn(rf,ss)
sfx(2)
ss.sj(rf,ss)
end
function ri(rf,ss)
ss.sk(rf,ss)
end
function rj(rf,ss)
ss.sl(rf,ss)
end
function rk(rf,ss)
ss.qv-=1
if ss.qv<1 then
ss.qv=1
if(ss.sm!=j) ss.sm(rf)
end
end
function rl(rf,ss)
ss.qv+=1
if ss.qv>ss.sp then
ss.qv=ss.sp
if(ss.sn!=j) ss.sn(rf)
end
end
function rm(rf,ss)
sfx(0)
ss[ss.qv][2](rf)
end
function qu(rf)
fj(rf,qj)
end
function qb(rf)
rf.en+=1
if(rf.en>#el) rf.en=1
end
function et(rf)
qb(em)
end
function qc(rf)
rf.qx+=1
if(rf.qx>#py) rf.qx=1
if(ej.qx==em.qx) qc(rf)
end
function es(rf)
qc(em)
end
fw,sv,fv,rp,pw,sw=1,c("Calm Seas,Rough Seas,Gale"),{{6,12},{14,20},{12,30}},c("0.9999,0.9995,0.999"),1,c("Day,Night")
function qd()
pw+=1
if(pw>2) pw=1
end
function qe()
fw+=1
if(fw>3) fw=1
end
function qf(rf)
local kd=true
if(ex==ry) kd=false
pu(kd)
end
function qq(rf)
ez,ex,fw=pq,rx,1
fj(rf,qh)
end
function qr(rf)
ez,ex=fh,ry
fj(ej,qk)
fj(em,ql)
end
function qs(rf)
ez,ex,fw,pw,em.en=fa,rz,2,1,1
fj(ej,qn)
end
sx,sy=c("E,ENE,NE,NNE,N,NNW,NW,WNW,W,WSW,SW,SSW,S,SSE,SE"),c("SHIP'S BOY.,ABLE SEAMAN.,WARRANT.,MIDSHIPMAN.,ENSIGN.,LIEUTENANT.,MASTER.,CAPTAIN.,POST-CAPTAIN.,COMMODORE.,REAR ADMIRAL.,VICE ADMIRAL.,FLEET ADMIRAL.,PRIME MINISTER.,NATIONAL HERO.,LORD OF THE SEA.")
function sz()
local st,su=bj()
palt(14,true)
local function ta(rf,jr,bg,bh)
hq(jr,bg+32,bh)
local gp,gq,dk=bg+st,bh+su+14,ek[el[rf.en]]
rectfill(gp+4,gq-5,gp+60,gq-5,rf.kb)
spr(44,gp,gq,4,4)
rectfill(gp+34,gq,gp+60,gq+32,1)
rect(gp+34,gq,gp+60,gq+32,7)
pal(6,rf.kb)
jd(dk.jv,47+gp,gq+18,t()/4)
pal(6,6)
hq(dk.js,bg+32,bh+50,rf.kb)
hq(py[rf.qx],bg+32,bh+64,rf.kb)
local li=dk.ju
local function tb(tc)
local jh,td,te,tf=0.04167,16+gp,16+gq,14.5*li[2]
line(td,te,td+tc*tf*sin(-jh),te-tf*cos(-jh),7)
for m=3,#li do
jh,tf=jh+0.04167,14.5*li[m]
line(td+tc*tf*sin(-jh),te-tf*cos(-jh))
end
end
tb(1)
tb(-1)
end
local function tg(fd)
hq(sw[pw],63,fd)
hq(sv[fw],63,fd+14)
end
if ex==rc then
sspr(0,48,107,44,10+st,8+su)
sr(qg,63,80)
print("                      BY MUSURCA",st,su+122,5)
elseif ex==rx then
sr(qh,32,52)
sr(qi,97,52)
sr(qj,63,85)
ta(ej,"Player",1,2)
ta(em,"Opponent",65,2)
tg(85)
elseif ex==ry then
sr(qk,32,52)
sr(ql,97,52)
sr(qm,63,85)
ta(ej,"Player 1",1,2)
ta(em,"Player 2",65,2)
tg(85)
elseif ex==fi then
if ez==fa then
hq("The "..ek[el[ej.en]].js,63,4)
hq(py[ej.qx],63,16,jz)
hq("dispatched",63,28)
hq((eo-1).." ship"..(eo==2 and""or"s")..",",63,40)
hq("earning the title",63,52)
hq(sy[min(eo,16)],63,64,jz)
else
if fg==nil then
hq("DRAW",63,32)
else
local th,ti=ej,"Defeat for"
if ez==fh or fg==ej then
th,ti=fg,"Victory to"
end
hq(ti,63,20)
hq("the "..py[th.qx].."!",63,32,th.kb)
end
end
sr(fk,63,85)
elseif ex==rz then
sr(qn,62,62)
sr(qo,62,95)
ta(ej,"Player",30,12)
else
if eh then
if ez==fa then
hq(eo..".",63,8)
hq("The "..em.cx.dk.js,63,20)
hq(py[em.qx],63,30,ev)
else
hq(py[ej.qx],38,10,jz)
hq("vs.",63,20,7)
hq(py[em.qx],88,30,ev)
end
end
local function tj(bb,bc,o,bi,f)
rectfill(bb+st,bc+su,o+st,bi+su,f)
end
local tk,tl=" "..flr(gc).." kt ",sx[flr(min(0.99999,gb+0.075)*#sx)+1]
local tm=118-#tl*5/2
hq(tk,tm-#tk*6,120,7,hn)
hq(tl,tm,120,7,hn)
tj(117,113,127,113,2)
jd(px,117+st,113+su,gb+max(0.018,gc*0.002)*sin(t()/2))
local function tn(rf,bg)
local cx=rf.cx
if cx then
if cx.cy>0 then
local to=bg+10
tj(to,2,to+30*rf.cx.cy/rf.cx.dk.cy,4,rf.cx.kb)
tj(to,7,to+30*(rf.qy and(1-min(120,rf.ra)/120) or(1-cx.cz/cx.dk.dn)),7,rf.qy and flr(rnd(14)+1) or 5)
end
spr(cx.cy>0 and 64 or 80,bg+st,su+1,5.25,1)
end
end
tn(ej,2)
tn(em,83)
end
end
function _draw()
cls(fc and 7 or dl)
fc=false
if(dl==dm) h(0.2)
gu(bv[1])
gu(bz,true)
h(1)
sz()
end
__gfx__
eeeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeee07e
eeeeeeeeee4eeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2eeeeee4eeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00070eeeeeee00e
eee2eeeee424eeee222eeee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2e2eeee424eeee4e4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000eeee55e5ee
ee222eee42224ee2eee2e7777777eeeeeee7777777e77777eeeeeeeee2eee2ee42224eee4e4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000eeee5e5eee
e2eee2e42222244ee4ee4eee4eeeeee4eeeeee4eeeeee4eeeeee4eeee2eee2ee42224eeeeeeee7777777eeeeeee7777777e77777eee777eeee000eeee5eeeeee
e2eee2e42222244eeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eee0ee42224eeeeeeeeeee4eeeeee4eeeeee4eeeeee4eeeeee4eeeeeeeeeeee07eeeee
e2eee2e02222204eeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2eee2ee42224eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeee
e2eee2e42222244eeeee47777777eeeeeee7777777e77777ee77777ee0eee0ee42224eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e2eee2e02222204ee4ee4eee4eeeeee4eeeeee4eeeeee4eeeeee4eeee2eee2ee42224eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee06ee06eeee6eee
e2eee2e42222244eeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eee0ee42224eeeeeeeeeeeeeee77777777777777e77777eeeeeeeee000e000eee00eee
e2eee2e02222204eeeee4e77777eeeeeeeee77777eee777eeeeeeeeee2eee2ee42224eeeeeeeeeee4eeeeee4eeeeee4eeeeee4eeeeee4eeeee0eee0eeee0eeee
e2eee2e42222244ee4ee4eee4eeeeee4eeeeee4eeeeee4eeeeeeeeeee0eee0ee42224eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee06eeeeaeeeee
e2eee2e0222220222222244444442222222eee7eeeeeeeeeeeeeeeeee2eee2ee42224ee42224eeee7eeeeee7eeeeee7eeeeeeeeeeeeeeeeeeee000eeeaeeeeee
e2eee2e4eeeee4222222244444442444442eee7eeeeee7eeeeeeeeeeee222eee42224ee42224eeee7eeeeee7eeeeee7eeeeeeeeeeeeeeeeeeeee0eee9a9eeeee
ee222eee24242e24a4a42424242422222226ee7ee6eee7eeeeeeeeeeeeeeeeeee4a4eee44444ee6e7e6eeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeea99eeeee
eeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaeeeeeeeeeeeeeeee2999999999999999999999999992ee
eeeeeee4ee7eeeeeeeeeeeeeeeeeeee4eeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaeeeeeeeeeeeeee22294444444444455444444444449222
eeee4ee4ee7ee7eeeeeeeeeeeeeeeee4eeee7eeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaeeeeeeeeeeeeee99944444444454455445444444444999
e4e4244e4e7ee7ee7eeeeeeeee2eeee2eeee7eeee7eeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeee94444444454444444444445444444449
e4e4244e4e7ee7ee7ee7eeeeee2eee424eee7eeee7eeee7eeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeee94444544444444444444444444544449
e4e424eeee7ee7ee7ee7ee7eee2eee222eee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeee94444454444444455444444445444449
e4e424e4ee4ee4ee4ee4eeeeee2eee020eeeeeeeeeee777777777777777eeeeeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeee94444444444454444445444444444449
e4e424eeee7ee7eeeeeeeeeeee2eee242eee4eeee4eeee4eeee4eeee4eeeeeeeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeee94444444444444444444444444444449
e4e424eeee7ee7ee7eeeeeeeee2eee020eeeeeeeeeeeee7eeee7eeee7eeeeeeeee5eeee5eeee0eeee9eeeeeeeeeeeeee94454444454444444444445444445449
e4e424eeee7ee7ee7ee7eeeeee2eee222eeeeeeeeeeeee7eeee7eeee7eeeeeeeeeeeeeeeeeeeeeeee9eeeeeeeeeeeeee94444444444444455444444444444449
e4e424eeee7ee7ee7ee7ee7eee2eee424ee424ee6e6eee7eeee7eeee7eeeeeeeeeeeeeeeeeee9eeee9eeee9eeeeeeeee94444444444444444444444444444449
e4e424e4ee4eeeeeeeeeeeeeeeeeee4a4ee444eeeeeeee7eeee7eeeeeeeeeeeeeeeeeeeeeeee9eeee9eeee9eeeeeeeee94444445444454444445444454444449
e4e4244e4e7ee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9eee494eee9eeeeeeeee94544444444444444444444444444549
e4e444444e7ee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9eee494eee9eeeeeeeee94444444444444455444444444444449
eee4a4444676e7ee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9ee44944ee9eeeeeeeee94444444444444544544444444444449
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9ee44944ee9eeeeeeeee95544544445445444454454444544559
eeee77eeeedddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee95544544445445444454454444544559
eeeee7eeedeeeeeeeeeeeeeeeeeeeeeeee777eeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444444444544544444444444449
e22e74eeeeee7eeeeeeeeeeeeeeeeeeeeeee7eeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444444444455444444444444449
e4404044edeee77eeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94544444444444444444444444444549
ee22222eeedddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444445444454444445444454444449
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444444444444444444444444449
eee06eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444444444455444444444444449
eee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94454444454444444444445444445449
eeee77eeeeddddddddddddddddeeeeddddddd7dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444444444444444444444444449
eeeee7eeedeeeeeeeeeeeeeeedeeeddeeee77eeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444444454444445444444444449
e22e74eeeeee7eeeeeeeeeeeedeeeeddeeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444454444444455444444445444449
e4404044edeee77eeeeeeeeedeeedeeedeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444544444444444444444444544449
ee22222eeedddddddddddddddedeeeeedddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee94444444454444444444445444444449
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee99944444444454455445444444444999
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee22294444444444455444444444449222
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2999999999999999999999999992ee
eeeeeedddeeeeeeeeeeeeeeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddeeeeeeeeeeedddddeeeeeeeeeeeeeeeeeeeeeeeeee
eeed777777deeed7777777ed7777deeeeeed777777e777777de777777deee7777777dd7777deeeeeee777777deeeedd777777777deeeeeeeeeeeeeeeeeeeeeee
eed77777777deed777777d0d77777deeeeed777777e777777de777777deed7777777dd777777eeeeee777777deeed777777777777deeeeeeeeeeeeeeeeeeeeee
ee77710e777deeeed77700eeed7777deeeeee777eeeed777deed777deeeeeee777eeeeee77777eeeeeed77d00ee77777d0000d7777eeeeeeeeeeeeeeeeeeeeee
ed77d0eed77deeeed77d0eeeed77777eeeeeed77eeeed777eee77deeeeeeeee777eeeeee77777deeeeee77deee7777d00eeeeee777eeeeeeeeeeeeeeeeeeeeee
ed77deeeed7deeeed77deeeeed777777eeeeed77eeeee77deed77eeeeeeeeee777eeeeee777777deeeee77deed77770eeeeeeeee77eeeeeeeeeeeeeeeeeeeeee
ed777eeeeee0eeeed77deeeeed777777deeeed77eeeee77dee77eeeeeeeeeee777eeeeee7777777eeeee77dee7777d0eeeeeeeeed70eeeeeeeeeeeeeeeeeeeee
ed7777deeeeeeeeed77deeeeed77ee777deeed77eeeee77de77deeeeeeeeeee777eeeeee77ded77deeee77ded77770eeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeee
ee777777ddeeeeeed77deeeeed77eed777eeed77eeeee777777eeeeeeeeeeee777eeeeee77dee777deee77ded77770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee7777777deeeeed77deeeeed77eee7777eed77eeeee777777eeeeeeeeeeee777eeeeee77deed777dee77ded777d0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeed777777deeeed77deeeeed77eeee777ded77eeeee777777deeeeeeeeeee777eeeeee77deeed777de77ded777deeeeeed777777eeeeeeeeeeeeeeeeeeeeee
eeeeeed77777eeeed77deeeeed77eeeed7777777eeeee7777777eeeeeeeeeee777eeeeee77deeee7777777dee777deeeeeed777777deeeeeeeeeeeeeeeeeeeee
eddeeeeed777eeeed77deeeeed77eeeeed777777eeeee77ded777eeeeeeeeee777eeeeee77deeeee777777dee777deeeeeeeed77770eeeeeeeeeeeeeeeeeeeee
e77deeeeed77deeed77deeeeed77eeeeee777777eeeee77deed77deeeeeeeee777eeeeee77deeeeed77777deed777eeeeeeeee777d0eeeeeeeeeeeeeeeeeeeee
e777eeeeed770eeed77deeeeed77eeeeeed77777eeeed77eeeed77deeeeeeee777eeeeee77deeeeeed7777deee7777eeeeeeee777deeeeeeeeeeeeeeeeeeeeee
e777deeee7770eeed777eeeeed77eeeeeeed7777eeeed77eeeeed77deeeeeee777deeeee77deeeeeee7777eeeee777deeeeeed777deeeeeeeeeeeeeeeeeeeeee
ed7777ded77d0eed7777deeed7777eeeeeee777deedd777deeeed7777deeed77777eeeed777deeeeeed7770eeeee7777ddeed7777deeeeeeeeeeeeeeeeeeeeee
eed7777777d0ed77777777dd777777deeeeed77dee777777deee7777777e77777777de777777deeeeeed770eeeeeed77777777777eeeeeeeeeeeeeeeeeeeeeee
eeedd7777d0eed777ddd77eed7777deeeeeeed7eeed77dddeeee77777dded77ddd77ded77777deeeeeeedd0eeeeeeeedd7777dde00eeeeeeeeeeeeeeeeeeeeee
eeeeee0000eeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeed777777eee777777deeed7777777ee7777777ded777ddddddeeeeeeed777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeee777777777ed777777deeed777777ded7777777de77777777777deeee777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeed77d00d777eee777deeeeeee7777eeeeee777eeeeed7777dd7777deed77d00d7770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee7770eeed77eeed77eeeeeeeed77deeeeee777eeeeeed77d0eed777ee7770eeed770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee7770eeee77eeed77eeeeeeeed77eeeeeee777eeeeeed77deeed777ee7770eeee770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee777deeeeeeeeed77eeeeeeeed77eeeeeee777eeeeeed77deeed777ee777deeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee7777ddeeeeeeed77deeeeeeed77eeeeeee777eeeeeed77deeed777ee7777ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeed777777deeeeed777deeeeed777eeeeeee777eeeeeed777eed7777eed777777deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeed7777777deeed7777777777777eeeeeee777eeeeeed777777777eeeed7777777deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeed777777eeed777ddddddd777eeeeeee777eeeeeed7777777deeeeeeed777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeed7777deed77eeeeeeeed77eeeeeee777eeeeeed777eeeeeeeeeeeeeed7777deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee7deeeee7777eed77eeeeeeeed77eeeeeee777eeeeeed77deeeeeeeee7deeeee7777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeed77eeeeee7770ed77eeeeeeeed77eeeeeee777eeeeeed77deeeeeeeed77eeeeee7770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeed77deeeee77d0ed77eeeeeeeed77eeeeeee777eeeeeed77deeeeeeeed77deeeee77d0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeed777deeed77dee777deeeeeeed77deeeeee777deeeeed77deeeeeeeed777deeed77deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee7777ded777ee77777deeeeed7777deeed77777eeeed777deeeeeeeee7777ded7770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeed77777777ee77777777eeed777777de77777777ded777777deeeeeeed7777777700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeed7777deeed7dddddeeeeeddddddeed77ddd77ded77777deeeeeeeeeed7777d00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee77eeee77eee777eee777eeeeee7eee777eee77ee7777eeee777ee777eeee77eee777ee7777eeee777e7777ee7777ee77777eee777e77e77e7777eee7777eee
e7007eee07ee70007e70007eee770ee7000ee7007e0007eee7007e70007ee7007ee707ee07007ee7007e07007e07007e07007ee7007e07e07e0070eee0070eee
e7ee7eeee7ee0e770e0e777ee707eee777eee7ee0eee70eee7770e07777ee7ee7ee7e7eee7770ee7ee0ee7ee7ee77e0ee77e0e70ee0ee7777eee7eeeeee7eeee
70ee7eee70eee700eeee007e77777ee007ee7777eee70eee7007eee0007e70ee7e7777eee7007e70eeee70ee7ee70eeee70eee7ee77e77007ee70eeeee77eeee
7ee70eee7eee70ee7e7ee70e00070e7ee7ee7007ee77eeee7ee7ee7ee70e7ee70e7007ee70ee7e7eee7e7eee7e70ee7e70eeee7ee07e70e77ee7eeee7e70eeee
0777ee7777ee77770e0770eeee70ee0770ee7770ee70eeee7770ee0770ee0777ee7ee77e77770e77777e77770e77770e7eeeee07770e7ee70e777eee077eeeee
e000ee0000ee0000eee00eeeee0eeee00eee000eee0eeeee000eeee00eeee000ee0ee00e0000ee00000e0000ee0000ee0eeeeee000ee0ee0ee000eeee00eeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77e77e777eee77e77e77e77ee777ee77777ee7777e7777eeee777e77777e77e77e77e77e77e77e77e77e77e77e77777eeeeeee77eeeeeeeeeeee77eeeeeeeeee
07e70e070eee07770e07e07ee7007e07007e70007e07007ee7007e00700e07e07e07e07e07e70e07e70e07e07e70007eeeeeee07eeeeeeeeeeee07eeeeeeeeee
e770eee7eeeee777eee77e7e70ee7ee7770e7eee7ee7e77ee77e0eee7eeee7ee7ee7ee7ee7e7eee070eee7770e0ee70ee77eeee777eee777eee777ee777eeeee
e707ee70eeeee707eee7077e7eee7ee700ee7eee7ee7700ee007eee70eee70ee7ee7ee7ee777eee707eee070eeee70ee7007ee7007ee7000ee7007ee707eeeee
77e7ee7eee7e77e7ee77e07e7ee77e70eeee07770e7707ee7ee07ee7eeee7eee7ee7770ee777eee7e7eee70eeee70e7e7e77ee7e70ee7eeeee7e77ee770e7eee
70e77e77770e70e77e70e77e77770e77eeeee0077e70e77e77770ee7eeee77770ee070ee77077e77e77e777eee77770e77007e077eee777eee7770ee07770eee
0ee00e0000ee0ee00e0ee00e0000ee00eeeeeee00e0ee00e0000eee0eeee0000eeee0eee00e00e00e00e000eee0000ee00ee0ee00eee000eee000eeee000eeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee77eeeeeeee77eeeeeeeeeeeeeeee77eeeee77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e700eeeeeeee07eeeeee7eeeeeeeee07e7eee07eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e7eeeee7777ee777eeee0eeeeeee7ee7e7eee70eeee7e7ee7777eee777eee777eee7777e77e7eeee777e0700eee7e7ee77e77e77e77e77e77e77e77e77777eee
7777ee70070ee707eee77eeeeeee7ee770eee7eeeee7777e07007e7007eee7007e70007e00707ee7000e70eeee70e7ee07e70e07e70e07770e07e70e00070eee
0700ee7ee7ee70e7eee70eeeeee70e7707eee7ee7e70707e77ee7e7ee7eee7ee7e7eee7ee70e0ee077ee7ee7ee7e77eee7e7eee777eee707eee7e7eee770eeee
e7eeee0770ee7e70ee70eeeeeee7ee70e7eee0770e7e0e7e70e77e7770eee7770e07770e77eeee7770ee7770ee0770eee770eee707ee70e07ee777ee77777eee
e0eeee7007ee0e0eee0eeeee7e70ee0ee0eeee00ee0eee0e0ee00e000eee7000eee007ee00eeee000eee000eeee00eeee00eeee0e0ee0eee0ee070ee00000eee
eeeeee7777eeeeeeeeeeeeee077eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeee
eeeeee0000eeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeee
eeeeeeeeeeeee777eeee77eee7e7eee77eeeee7eeeee7eeeeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee0077eee77ee7070ee700eeee70eeeee07eee7eeeee7eeeee70eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeee77eee70ee0e0eee07e7eee7eeeeeee7eee0eeeee0eeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee7770ee77eeeeeeeeee770eee7eeeeeee7eeeeeeeeeeeeeeeeeeee77777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee000eee00eeeeeeeee7007eee7eeeeeee7eee7eeeee7eeeeeeeeee00000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee7eee7eeeee7eeeeee7eeeeeeeeee07707ee07eeeee70ee70eeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
770eee0eeeee0eeeeee0eeeeeeeeeee00e0eee0eeeee0eee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
000500000053003600066000a600051000f6000f6000e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000075500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a7101971018710127100f710087100671000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000037634326302e630286301b6300a630006350e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000137501375013750137501375513750137501375013755137551375013750137501375013750137501375013750137551370013700000000d700000000e70000000000000000000000000000000000000
001400000f700000000f7000f70014700000000000000000000000000000000000000000000000000000000000000000000000000000000000f750000000f7550f750147500f7000f70014700000000000000000
000800000100001000000000000000000000000000000000000000000000102031050200003000040002a1000500006000060000700008000080000800009000090000a0000a0000b0000b0000c0000011005110
0018000024636156361d63610636216361863623636136361c636286361a62215622106120c612096120461202612006120061200612006150060200602006020060200602006050060200602006050000000000
0018000024636106361a636266362063218622126220e6120b6120961205612036120161200612006120061503602026020160200602006020060200602006020060200602006050060200602006050000000000
0018000024636106361a636126320d6220d6220b61208612066120461202612006120061200615006020060503602026020160200602006020060200602006020060200602006050060200602006050000000000
0018000024636176320c6220961206612046120261202612016150160200605036020260201602006020060200602006020060200602006020060500602006020060500000000000000000000000000000000000
000b0000007741e627036200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000a774167731977318770137700f7700677003760027500175000740007300072000720007100071000715045000350003500005000060000600006000060000600006000060000600005000050000505
011000000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7000e7520e7520e7520e7520e7520e7550e7000e7520e7520e7520e7520e7550e7520e7550e7520e752
011000000e7520e7520e7520e755117521175211752117521175510752107551075210752107521075210752107550e7520e7550e7520e7520e7520e7520e7550d7520d7550e7520e7520e7520e7520e7520e752
011000000e7520e7520e7520e75502700027001c7001c7001c7001c70000700007002170021700217002170005700057001f7001f7001f7001f70000700097002270022700227002270007700077002170021700
010700000e7000e700027000270000700007000970009700097001570000700007001170011700117001170000700007000c7000c7000c7001870000700007000770007700137001370000700007000e7000e700
011400000e7510e7500e7500e7500e755137501375013750137501375513750137501375013755137551375213752137521375213755177501775017750177551575513750137501375013755127551375013750
011400001375013755107550e7520e7520e7520e7520e7520e7550e7001550015500155001550019700197000e5000e5000e5000e50002700135000d5000d5000d5000d500097000970011500115001150011500
0105000021700217000e7000e7000a7000a700167001670000700007002570025700257002570015700157001d7001d7001d7001d70002700027001c7001c7001c7001c700097001570021700217002170021700
010500000e7000e70000700007000070000700007000070000700007001570015700097000970000700007000e7000e7000270002700007000070009700097000970015700007000070011700117001170011700
01140000007001f500185001850000700007750d7001e5001a5000070000775007000070000700007450077518500215002650025500265002850029500295000074500775007001d5001d5001d5000050000500
01140000007000070000745007751c5001c50018700215001f7001f700185001850022700105001d5001d5001d5000e5001650016500135001350015500155000950009500215002150021500215000270002700
0110000000700007000c7000c7000c7001870000700097001f7001f7001f7001f7002270022700217002170000775007000070000700007000070000700007750070000700267000070000745007000077502700
0110000000700007000c7000c7000c700187000070000700227000074500700007750070000700117001170000700007450070000775007000070000700007000074500700007750070000700007000070000700
0110000000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007001c500175001850021500135001a5001f500265002450022500215001f500
000500001d0300c020010200d02019020060301803011020070200202000020072000520003200022000220001200012000020001200002000020000200012000120000200002001650013500135001a5001a500
000d00000e610066000f6001b60528600056000360002600016000160500700007000070011700217001d7000070000700007001f700007000070000700187000070013700227001f70000700007000070021700
012d00001d5001c5001a5001850016500215001f500295002850026500255002850021500255001c5001f5000e500155001a500215001f5001d5001c5001a5001950013500155001050011500185001d50024500
012d00000e5000e500005002150026500265000a5000a50016500165001550015500155001350011500105001d5001d50011500115000e5000e50015500155000950009500005000050021500215001550015500
012d0000005000050000500007002170016700267001f7000070000700007000070000700007000070000700007000e7001d7001a7000070000700007001c700007001970000700007000070011700217001d700
012d000022500215001f5001a5001c500165001850021500135001a5001f5002650024500225001a5001f5001d50021500165001d50026500285002150026500255001f5002650022500215001f5001d5001c500
012d0000115001150018500185000c5000c50000500125002250022500165001650013500135002150021500215001c50026500155001f50022500295002950028500285000e5000e5000e5000e5000250002500
012d00000070000700007001f700007001c70000700187000070013700227001f7000070000700007001a70000700187000070026700167001370015700157000970009700007002670026700267000070000700
012d00000e5000d5000e500105001150013500155001350015500105000d50009500115001050011500135001550016500185001350010500135000c500105001350011500135001550016500185001a50015500
012d00001550015500155001550015500155001950019500195001950019500195001850018500185001850018500185001c5001c5001c5001c5001c5001c5001a5001a5001f5001f5001f5001f5001d5001d500
012d00001a7001a7001a7001a7001a7001a7001c7001c7001c7001c7001c7001c7002170021700217002170021700217001f7001f7001f7001f7001f7001f7002270022700227002270022700227002170021700
012d00001d7001d7001d7001d7001d7001d7000050000500005000050000500005000050000500005000050000500000000000000000000000000000000000000000000000000000000000000005000050000500
012d000011500155000e500115000a50011500165001550013500265001550016500155001350011500105000e5000950005500095000250005500095001050015500135001150010500115000c500095000c500
012d00001d5001d5001d5001d5002650026500285002850028500165001c5001c5001c5001c5001c5001c5001550015500155001550015500155001950019500195001950019500195001d5001d5001d5001d500
012d00002170021700217002170021700217001f7001f7001f7001f7002170021700217002170021700217001a7001a7001a7001a7001a7001a7001c7001c7001c7001c7001c7001c70021700217002170021700
012d0000000000000000000000000050000500005000050000700007002570025700257002570025700257001d7001d7001d7001d7001d7001d70000700007000050000000000000000000000000000000000000
002d000005500095000c5000a5000c5000e5001050011500135000e5000a5000e500075000a5000e500105000e5002150026500255002650028500215002650025500215001a5001550011500155000e5000e500
012d00001d5001d5001c5001c5001c5001c5001c5001c5001a5001a5001f5001f5001f5001f5002150021500215000c5000a500095000a50007500155001350015500095001d5001d5001d5001d5000050000500
012d000021700217001f7001f7001f7001f7001f7001f7002270022700227002270022700227001d7001d7001d7001d7001f7001f700007000070029700297002870028700217002170021700217000070000500
012d00000050000500005000050000000000000000000500005000050000500005000050000500005000050000500005000050000500005000050000500005000070000700267002670026700267000050000500
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
01 10 42 43 44
01 0d 17 43 44
01 0e 18 43 44
04 0f 42 43 44
01 13 42 43 44
01 11 15 43 44
04 12 16 43 44
01 13 42 43 44
04 04 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
