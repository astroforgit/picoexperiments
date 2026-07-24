pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- slipways
-- by @krajzeg / @gruber_music
function ft(rc,nt,pu)rc[nt]=rc[nt]or {}
add(rc[nt],pu)end
function mv(e,rm,...)local fn=e and e[rm]
if type(fn)=="function" then
return fn(e,...)end
return fn
end
function qj(o,mr)for k,v in pairs(mr or {})do
o[k]=v
end
return o
end
function mw(o)
return qj({},o)end
function ho(rc,mr,gp)
return function(ri)for i,p in pairs(mr)do
ri[p]=gu(gp,p)and r[ri[i]]or ri[i]
end
rc[ri.px]=ri
end
end
function rk(y1,y2,...)rectfill(0,y1,127,y2 or y1,...)end
function eq(x1,y1,x2)rect(x1,y1,x2+1,y1+12,0)rectfill(x1+1,y1+1,x2,y1+11,5)spr(70,x1,y1,1,2)spr(71,x2-2,y1,1,2)end
function io(t,x,y,c,a)
if (a)x-=a*4*#t
for _,d in pairs(er)do
print(t,x+d.x,y+d.y,band(d.c,c))end
end
function jp(qk,ow)local f={}
for e in all(qk)do
if (ow(e))add(f,e)
end
return f
end
function nv(qk,kp)local m={}
for e in all(qk)do
add(m,kp(e)or nil)end
return m
end
function gu(qk,kb)for e in all(qk)do
if (e==kb)return true
end
end
function la(a,b)local t={}
local kg=function(e)add(t,e)end
foreach(a,kg)foreach(b,kg)
return t
end
function oo(fn,a)
return fn
and fn(a[1],a[2],a[3],a[4],a[5])or a
end
function ob(qs,mr)local kn,s,n,lm=
{},1,1,0
fi(qs,function(c,i)local sc,rq=sub(qs,s,s),i+1
if c=="(" then
lm+=1
elseif c==")" then
lm-=1
elseif lm==0 then
if c=="=" then
n,s=sub(qs,s,i-1),rq
elseif c=="," and s<i then
kn[n]=sc=='"'and sub(qs,s+1,i-2)or sub(qs,s+1,s+1)=="("and oo(pi[sc],ob(sub(qs,s+2,i-2)..","))or sc!="f"and band(sub(qs,s,i-1)+0,0xffff.fffe)s=rq
if (type(n)=="number")n+=1
elseif sc!='"'and c==" " or c=="\n" then
s=rq
end
end
end)
return qj(kn,mr)end
function fi(qs,fn)local rs={}
for i=1,#qs do
add(rs,fn(sub(qs,i,i),i)or nil)end
return rs
end
gt="abcdefghijklmnopqrstuvwxyz0123456789 ().,=-+_/\"'?%\n"function unstash(pd)local s=""repeat
local i=peek(pd)s=s..sub(gt,i,i)
pd+=1
until i==0
return s
end
kv={}
function kv:jr(rj)rj=ob(rj or "")rj.iq,rj.ns,kv[rj.fz or ""]=
self,{__index=rj},rj
return setmetatable(rj,{__index=self,__call=function(self,ob)ob=setmetatable(mw(ob),rj.ns)local ko,iy=rj
while ko do
if ko.pq and ko.pq~=iy then
iy=ko.pq
iy(ob)end
ko=ko.iq
end
return ob
end
})end
km={}
km.__index=km
function km:__add(b)
return v(self.x+b.x,self.y+b.y)end
function km:__sub(b)
return v(self.x-b.x,self.y-b.y)end
function km:__mul(m)
return v(self.x*m,self.y*m)end
function km:__div(d)
return v(self.x/d,self.y/d)end
function km:__unm()
return v(-self.x,-self.y)end
function km:rg(v2)
return self.x*v2.x+self.y*v2.y
end
function km:nn()
return self/self:qx()end
function km:pa()
return v(-self.y,self.x)end
function km:qx()
return sqrt(#self)end
function km:__len()
return self:rg(self)end
function v(x,y)
return setmetatable({x=x,y=y
},km)end
function qm(fy,lx)
return v(cos(lx),sin(lx))*fy
end
function qz(xl,yt,xr,yb)
return function(p)
return mid(xl,xr,p.x)==p.x
and mid(yt,yb,p.y)==p.y
end
end
pi={b=qz,v=v,br=rk,qr=io,rf=eq,s=spr}
function cu()local a=0x5000
for p=0,15 do
for c=0,15 do
poke(a,bor(sget(p,c),c==3 and 0x80))
a+=1
end
end
end
function dv(no)memcpy(0x5f00,0x5000+shl(flr(no),4),16)end
er=ob([[
o(x=-1,y=-1,c=0),
o(x=0,y=-1,c=0),
o(x=1,y=-1,c=0),
o(x=-1,y=0,c=0),
o(x=1,y=0,c=0),
o(x=-1,y=1,c=0),
o(x=0,y=1,c=0),
o(x=1,y=1,c=0),
o(x=0,y=0,c=15),
]])function jl()hv,cv,cg={},{},{}
mo,je,ok=
qb(),nf(),ui()end
function lt(e)add(hv,e)for p in all(bm)do
if (e[p])ft(cv,p,e)
end
for t in all(e.nu)do
ft(cg,t,e)end
return e
end
function he(e)del(hv,e)for p in all(bm)do
if (e[p])del(cv[p],e)
end
for t in all(e.nu)do
del(cg[t],e)end
end
bm=ob([[
"kj","ev",
"hd",
"hk","hb",
]])function dg()for _,qc in pairs(hv)do
local fn=qc[qc.me]
if fn then
fn(qc,qc.t)end
if qc.p_ then
he(qc)end
qc.t+=1
end
end
ke=kv:jr([[
me="ph",t=0,
]])ke.pq=lt
function ke:ks(me)self.me,self.t=me,0
end
ci=ob([[0.5,1,1,1,1,1,1,1,1,0,0,0,0,0,0,]])
function dc(nt)
local fl={}
for _,qc in pairs(cv[nt])do
ft(fl,qc.fa,qc)
end
for o=1,15 do
if (nt=="kj" and fl[o])mo:md(ci[o])
for _,qc in pairs(fl[o]or {})do
qc[nt](qc,qc.ra)
end
end
end
nf=ke:jr([[
l=o(),r=o(),ra=v(0,0),
]])function nf:pq()poke(0x5f2d,1)end
function nf:ph()self.ra=v(stat(32),stat(33))bu(self.l,1)bu(self.r,6)end
function bu(qn,oa)local on,ia=
band(stat(34),oa)>0,qn.on
qn.on,qn.jn,qn.hm=
on,on and not ia,ia and not on
end
function gk(e,mp,rp)
return e.kq((e.fa>=10 and rp or mp)-e.ra
)end
ui=ke:jr([[
ql=58,
fa=15,
le=o(),
hw=b(10,10,118,118),
]])function ui:lj()local le=self.le
self.qa=je.ra+mo.ra
self:gw()if #le==0 or gu(le,self.o_)then
self:bh("l")end
self:bh("r")if je.l.jn and self.le==le then
self:cj()end
self.gj=self.o_
end
function ui:ev()spr(self.rheld and 9 or self.o_ and self.o_.ql or self.ql,je.ra.x,je.ra.y)end
function ui:gw()self.ic,self.o_={}
for e in all(cv.hd)do
if mv(e,"hd",self.qa,je.ra)then
ft(self.ic,e.fa,e)self.o_=e
end
end
(self.gj or {}).m_=false
(self.o_ or {}).m_=true
poke(0x5f80,self.o_
and self.o_.fg
or max(peek(0x5f80)-1,0))end
function ui:bh(bt)local b,ni=
je[bt],bt.."held"if b.jn then
local pw=self:jz(bt.."down",self.qa,je.ra)if pw and type(pw.kn)=="table" then
self[ni]=pw.kn
end
end
local held=self[ni]
mv(held,"hq",self.qa,je.ra)if b.hm and held then
local nw=self:jz("gv",held)mv(held,"ey",nw and nw.kv)self[ni]=nil
end
end
function ui:jz(rm,...)for mf=15,0,-1 do
for h in all(self.ic[mf])do
local kn=mv(h,rm,...)if kn then
return {kv=h,kn=kn}
end
end
end
end
function ui:cj()nv(self.le,he)self.le={}
end
js=ke:jr([[
fa=11,
]])js.hd=gk
function js:pq()self.lq=lq(mv(self,"lq"))self.mb=self.lq.w+2
self.kq=qz(0,-1,self.mb,11)self.h_=self.h_ and lq(self.h_)self.jb=self.jb and jb(self.jb)end
function js:ph()if self.qf then
local d=self.qf-self.ra
self.ra+=(#d<=1 and d or d*0.4)
end
end
function js:ev()if self.jb and self.m_ then
self.jb:ol(127,1)end
end
function js:kj(p)local qt,dn,c=
p.x+self.mb-1,p.y+9,self.my
rect(p.x-1,p.y,qt+1,dn+1,1)rectfill(p.x,p.y,qt,dn,c and (self.m_ and 12 or 13)or 5)rectfill(p.x,p.y,qt,p.y,c and 6 or 5)self.lq:ol(p+v(1,2))local c=self.h_
if c then
rectfill(qt+3,p.y+1,qt+c.w+4,dn,c.bg or 2)c:ol(p+v(self.mb+3,2))end
end
function js:ldown()rn(self.my and 60)mv(self,"my")
return true
end
function pz(p,bs)if p.ep then
bs=la({{lq={p.ep,c=13}}},bs)end
rn(p.eo or 62)local ra=p.hi or p.ra
local bp=ra+v(0,0)ok:cj()ok.le=nv(bs,function(b)b.ra,b.qf,b.fa=
ra,bp,p.ca
bp+=p.gq
return js(b)end)
if (p.ff)ok.le={}
end
lq=kv:jr()function lq:pq()local w,s,fs,f,fw=0,0
self.fs=nv(self,function(f)f,fw,fs=self:mn(f)local x=w
w+=fw+fs
return {fn=f,d=v(x,0)}
end)self.w=w-fs
end
function lq:ol(p,a)
if (a)p-=v(a*self.w,0)
for f in all(self.fs)do
f.fn(p+f.d)end
end
function lq:mn(f)local w,qw,qv,fn=6,0
if type(f)=="table" then
if (f.qe)f={f.qe,5}
f,w,qw,qv=f[1],f[2],f[3]or qw,f[4]
end
if type(f)=="string" then
local c=self.c or 6
return function(p)io(f,p.x+2,p.y+1,c)end,#f*4+3,1
elseif f then
fn=function(p)dv(qw)spr(f,p.x,p.y)dv()end
end
return fn or function()end,w,qv or 2
end
pi.ld=lq.ol
jb=kv:jr()function jb:pq()self.ls=nv(self,function(ln)
return lq(type(ln)=="string" and {ln}or ln)end)end
function jb:ol(om,a)local h=#self*8+2
local om-=h*a
local dn=om+h
fillp(0b0000111100001111)rk(om,dn,0x10)fillp()for l in all(self.ls)do
l:ol(v(64,om+2),0.5)
om+=8
end
end
fq=ke:jr([[
fa=14,
hd=1,
]])function fq:ldown()self.p_=mv(self,"my")
return true
end
function rn(no)
if (no and not ih)sfx(no,3)
end
function jf(n_,b)
return function()local v=rnd(1-abs(b))+max(b,0)
b+=(0.5-v)*n_
return v
end
end
function ne(d,c,ku)if d>=0 then
d="+"..d
else
c=8
end
return d..(ku or ""),c
end
function gd(e)
return abs(e.ra.x-mo.ra.x-64)<=76 and abs(e.ra.y-mo.ra.y-64)<=76
end
function ma(p,e)e.ma=max(0,e.ma-0.1)
return p+qm(e.ma,e.t*0.2)end
function ij(p,j_)local mk,nd=32767
for o in all(j_)do
local d=#(p-o.p)if p~=o.p and d<mk then
nd,mk=o,d
end
end
return mk,nd
end
bg=ke:jr([[
fa=1,
hd=1,
pl=o(0,0,0,72,73,74,75,88,89,90,91,88,91,89,91),
]])function bg:pq()local vs,vh,oh,m=
{},0,jf(0.1,0)for y=0,31 do
for x=0,31 do
vh=oh()*8-4+
(vh+(vs[x]or 1))*0.5
vs[x]=vh
mset(x,y,rnd()<0.004
and 122+rnd(5)or bg.pl[flr(vh+rnd(4))])end
end
end
function bg:kj()map(0,0,0,0,32,32)fillp(0b1010010110100101)for xy=3,262,32 do
rectfill(xy,0,xy,262,1)rectfill(0,xy,262,xy)end
fillp()rect(0,0,262,262,5)end
function bg:ldown(mp)
return (#(cg.g_ or {})>0 and mz or g_)()end
function bg:rdown(mp,rp)self.mq=rp
return self
end
function bg:hq(mp,rp)mo.v=self.mq-rp
self.mq=rp
end
jo=ke:jr([[
nu=o("jo","np","prober"),
me="unknown",
hf=1,hs=1,
fa=6,
kq=b(-7,-7,7,7),
ma=0,
ka=o(2,3,9,12),
dz=o(
o("unhappy",c=8),
o("content",c=3),
o("prosperous",c=9),
o("rich",c=12),
),
cq=o(12,36,24,25),
kw=o(mu=0),
gq=v(0,11),ca=9,
em=o(f,3,0,-1),
]])jo.hd=gk
function jo:pq()self.oe={}
if self.hp then
self:lz(gb[self.hp])end
end
function jo:hh()self.nk=
jo.ir()<0.45
and df.ll
or jo.oc()self.ep=self.nk.d
self:ks(self.nk.me or "known")self:kd()end
function jo:ldown()if self.me=="known" then
self:fe()
return true
elseif self.me=="ly" then
return jc({qu=self})end
end
function jo:fe()pz(self,nv(bj(self),function(b)local od=b:od()
return {lq=mv(b,"lq"),h_=od>0 and {od.."$",c=13},my=function()if fm:lu(od)then
self:hu(b)end
end,jb=b:jb()}
end
))end
function jo:gh()local bs={{lq=
self.px or
jo.dz[self.mi]
}}
bs[1].h_=self.kr
and {ne(self.kr).."$",bg=self.kr>=0 and 1}
local ji={"receives:"}
local jx=jp(self.jy,function(i)for j=1,i.gc do
add(ji,i)end
return i.gc==0
end)if jx[1]then
add(bs,{lq=la({"needs:"},jx)})else
if self.mi<4 and #self.jy>0 and self.kw.qe~=r.w then
add(bs,{lq=la({"wants more:"},self.qh
and {self.jy[#self.jy]}
or self.jy
)})end
end
add(bs,ji[2]and {lq=ji})if self.kw.mu>0 then
local lb=gu(jo.cq,self.kw.qe)and {"makes:",tostr(self.kw.mu),self.kw}
or {"exports:",#self.by.."/"..self.kw.mu,self.kw}
add(bs,{lq=lb})end
for i=2,#bs do
add(bs[i].lq,{false,1})end
pz(self,bs)end
function jo:gg()
return self.hf and self.me=="ly"end
function jo:hu(hp)local fp=2
if hp.cw then
self.p_=true
self=kv[hp.cw]({p=self.p,ra=self.ra,id=self.id
})elseif hp.go then
self.nk=df[hp.go]
else
self:ks("ly")self:lz(hp)self.fx=true
fp=ov("autoassemblers",3,2)end
fm:nx(fp)rn(hp.rn or 55)self:kd()end
function jo:lz(hp)self.hn,self.ep=
hp
self.jy=nv(hp.i,mw)self.kw={qe=hp.o,mu=0}
end
function jo:kf(sw)add(self.oe,sw)
if (sw:eb(self).fx)self.fx=true
self:kd()end
function jo:kd()self.ma=1.25
end
function jo:ll(t)self.p_=t>60
end
function jo:gv(s)if self.me=="ly" then
if s.qu==self then
self:gh()else
return true
end
end
end
function jo:cn(lw)local t=lw.t
if t.qe==r.e
and not self.jh then
for i in all(self.jy)do
if i.gc==0 and i.qe~=r["?"]then
del(self.jy,i)break
end
end
self.jy,self.jh=
la({{qe=r.e}},self.jy),1
end
for i in all(self.jy)do
if i.qe==r["?"]and gu(self.ba,t.qe)then
i.qe=t.qe
end
if t.qe==i.qe and i.qe~=r["?"]then
lw:kf(t:kg(self))
return
end
end
end
function jo:ib()local ib=self.by or {}
local qe,mu=
self.kw.qe,self.kw.mu
for w in all(self.oe)do
local lw={t=trade({lp={self},rl={w},qe=qe
}),mu=mu-#ib,kf=function(self,a)if not gu(ib,a)then
add(ib,a)
self.mu-=1
end
end
}
if (lw.mu==0)break
w:eb(self):cn(lw)end
return ib
end
function jo:hk()if self.kr and self.kr~=0 and gd(self)then
iv({ra=self.ra,ne(self.kr,10,"$")})end
end
function jo.ex(is,o,jq,mj,d
)
if (not o)return
local l,lc,ml=
{},#is>=3 and 1 or 0,o==r.w and {25,23}or {o}
local pe=jq*#ml>=3
for i in all(is)do
add(l,{i.qe,3-lc,i.gc~=0 and 0 or 7
})end
if #is>0 then
add(l,{false,d+lc})add(l,(d==1 or pe)and {35,2+d}or {32,5})end
if jq>5 then
add(l,tostr(jq))add(l,{false,-4})l.c=13
jq=1
end
for qq in all(ml)do
for i=1,max(jq,1)do
add(l,{qq,6,(i<=jq and i>mj)and 0 or 7,pe and -4 or -3
})end
add(l,jo.em)end
return lq(l)end
function jo:hb()self.lq=jo.ex(self.jy,self.kw.qe,self.kw.mu,#self.by,0
)end
function jo:kj(p)
if (not gd(self))return
p=ma(p,self)if self.me=="ll" and rnd(30)<self.t-30 then
return
end
circfill(p.x,p.y,7,0)dv(self.qw)palt(3,false)palt(0,true)spr(self.nk and self.nk.s or self.s or 43,p.x-4,p.y-4,2,2)dv()if self:gg()then
circ(p.x,p.y,6,jo.ka[self.mi])spr(self.mi+1,p.x-3,p.y-6)end
mv(self.lq,"ol",p+v(0,7),0.5)if self.fo then
fillp(0b1010101010101010.1)circfill(p.x,p.y,sqrt(self.fo.dw)*128,2)fillp()self.fo=nil
end
end
function bv(self,mp,rp)self.ra,self.p=mp,mp/128
local nq,c=ij(self.p,cg.np)self.et=
nq<self.dw and c or
jp(cg.jc,function(sw)
return be(sw.qu.p,sw.re.p,self.p,0.0032)end)[1]or
not ui.hw(rp)and {}
if (self.et)self.et.fo=self
end
function dl(self)if self.me=="kz" then
local mp,t=je.ra
if self.et then
t=self.et.qs
if (not t)spr(31,mp.x-3,mp.y-8)
elseif self.od then
t=self.od.."$"end
io(t or "",mp.x,mp.y-8,8,0.5)end
end
function d_(self)if not self.et
and fm:lu(self.od)then
self:ks(self.dq or "ph")fm:nx(self.fp or 0)rn(self.ik or 54)
return true
else
rn(57)self.p_=true
end
end
function na(self,t)
self.ra.y+=sin(t*0.005)*0.06
end
mh=ke:jr([[
nu=o("mh"),
fa=14,
rh=5,
]])function mh:pq()
if (kc)kc.p_=true
kc=self
end
function mh:ev()local t=self.t/self.rh-10
if t>=0 and mv(self,"lh")then
self.t,t=self.rh*10,0
end
local nc=-t^3/9
bl(self,nc)camera()if t>10.5 then
self.p_,kc=true
end
end
function bl(rb,nc)for e in all(rb)do
if nc then
camera(nc,0)nc=-nc
end
oo(pi[e.fn],e)end
end
trade=kv:jr()function trade:to()
return self.lp[#self.lp]
end
function trade:kg(np,jc)
return trade({lp=la(self.lp,{np}),rl=la(self.rl,{jc}),qe=self.qe
})end
function trade.ns.__eq(l,r)
return l.lp[1]==r.lp[1]
and l:to()==r:to()end
jc=ke:jr([[
nu=o("jc"),
me="kz",
fa=2,
fp=f,ik=48,
dw=0.004,
k_=o(0,0,7,7,10,10,9,9,9,9,9,9,9,9,4,4,4,2,2,1),
nh=20,
]])function jc:pq()rn(50)self.ts,self.hg={},{}
end
function jc:hq(mp)self.re=ok.o_.gv and ok.o_ or {ra=mp,p=mp/128}
self.od=
dj(self.qu,self.re)self.mt=
self.qu.mt or self.re.mt
self.et=self:ce()if self.et then
self.et.fo=
self
end
self.fa=
self.mt and 2 or 4
end
function jc:ey(re)if not re
or not d_(self)then
if (stat(19)==50)rn(-1)
self.p_=true
return
end
self.nh,self.re=1,re
self.qu:kf(self)re:kf(self)fm:nx(1)end
function jc:ce()local sp,dp=self.qu.p,self.re.p
if #(sp-dp)>ov("space folding",0.5,1.08)then
return {qs="-too far-"}
end
for w in all(self.qu.oe)do
if (w:eb(self.qu)==self.re)return w
end
local ds=la(jp(cg.np,function(n)
return be(sp,dp,n.p,0.0032)end),jp(cg.jc,function(sw)
return sw.mt==self.mt and
cl(sp,dp,sw.qu.p,sw.re.p)end))
return ds[1]
end
function jc:eb(jo)
return jo==self.qu and self.re or self.qu
end
function jc:ch(f,t)if rnd()<0.08 and self.hg[t.id]then
local d=t.ra-f.ra
local v=d:nn()add(self.ts,{ra=f.ra+v:pa(),v=v,l=d:qx()})end
end
function jc:lg(l,h,s,c)local qu,re=
self.qu.ra+qm(1.5,self.t/126),self.re.ra+qm(1.5,self.t/176)for dx=l,h,s do
for dy=l,h,s do
line(qu.x+dx,qu.y+dy,re.x+dx,re.y+dy,c)end
end
end
function jc:kj()if gd(self.qu)or gd(self.re)then
local jv=
self.k_[self.nh]
if (self.nh<20)self.nh+=1
local c,bc,tc=
(self.et or self.fo)and 2 or self.mt and 0 or jv,self.mt and jv or 0,self.mt and 5 or 13
self:lg(-1,2,3,bc)self:lg(0,1,1,c)for _,t in pairs(self.ts)do
t.ra+=t.v
t.l-=1
if (t.l<=0)del(self.ts,t)
local x,y=t.ra.x,t.ra.y
rectfill(x,y,x+1,y+1,0)pset(x,y,tc)end
self:ch(self.qu,self.re)self:ch(self.re,self.qu)end
self.fo=nil
end
function jc:ev()
if (self.qu~=self.re)dl(self)
end
function f_(self)self.qy={}
end
function ez(self,n)while rnd()<n do
add(self.qy,self:mm())
n-=1
end
end
function ei(self)
if (self.fa<10 and not gd(self))return
local cx,cy,qo,qg,ro,q_,cs=
self.ra.x,self.ra.y,self.qo,self.qg,self.ro,self.q_,self.k_
for _,p in pairs(self.qy)do
local pv=p.v
p.p+=pv
p.v.x=qo*pv.x+ro*pv.y
p.v.y=qg*pv.x+q_*pv.y
if (p.a)p.v+=p.a
p.l-=0.14
if p.l<=1 then
del(self.qy,p)else
pset(cx+p.p.x,cy+p.p.y,cs[flr(p.l)])end
end
ez(self,self.fc)end
g_=ke:jr([[
nu=o("g_","prober"),
fx=1,
dq="ly",
od=0,fp=f,
fa=2,
dw=0.025,
py=0.06,ki=9,
pn=3,pk=1,
fc=1,
k_=o(1,1,5,13,6),
qo=1.02,ro=-0.0525,
qg=0.0525,q_=1.02,
du=2,
]])g_.hq=bv
g_.ey=d_
g_.ev=dl
g_.pq=f_
g_.kj=ei
function g_:mm()local a=(flr(rnd(self.pn))+rnd(0.5))/self.pn+self.t*0.001
local p=qm(self.du+rnd(),a)local v=p*self.py
return {p=p,v=self.pk and v:pa()or v,l=self.ki
}
end
function gn(hr,og,r)local oc,nm={},{}
for e in all(hr)do
for n=1,e.r*og do
add(oc,e)end
end
return function()local e
repeat
e=oc[flr(r()*#oc+1)]
until not gu(nm,e)del(oc,e)nm[3-#oc%3]=e
return e
end
end
function bw(n)for id=1,n do
local p
repeat
p=v(rnd(2.75)+0.125,rnd(2.75)+0.125
)until ij(p,cg.jo)>0.05
jo({id="p"..id,p=p,ra=p*128})end
jo.oc,jo.ir=
gn(df,2,jf(0.5,dk.en)),jf(0.8,0.5)end
mz=ke:jr([[
nu=o("mz"),
me="kz",dw=0,
dq="pr",
spawn_snd=52,ik=49,
oi=0,
od=3,fp=1,
fa=5,
kk=o(7,7,6,13,5,1,1,1,0),
jj=o(qs="-too far-"),
]])mz.hq=bv
mz.ev=dl
function mz:pq()rn(53)self.ox=jp(hv,function(p)
return p.fx
end)end
function mz:hq(...)bv(self,...)local nq
nq,self.ij=ij(self.p,self.ox)if nq>ov("space folding",0.19,0.27)then
self.et=mz.jj
end
end
function mz:kz(t)self.oi=ov("space folding",29,35)*
(min(t/15,1)+sin(t/40)*0.1)end
function mz:ey()self.p_=
self.t<15 or not d_(self)end
function mz:pr(t)local sr=self:ej(t)/128+0.031
for pt in all(cg.jo)do
if pt.me=="unknown"and (pt.p-self.p):qx()<sr then
pt:hh()end
end
self.p_=t>25
end
function mz:kj(p)if self.me=="kz" then
if not self.et then
circ(p.x,p.y,self.oi,1)end
local cp=self.ij.ra
line(cp.x,cp.y,p.x,p.y,1)spr(7,p.x-4,p.y-4)else
for dt=0,8,2 do
if self.t>dt then
local sr=self:ej(self.t-dt)circ(p.x,p.y,sr,self.kk[flr(sr/self.oi*8)])end
end
end
end
function mz:ej(t)
return min(sqrt(t/15),1)*self.oi
end
ef=ob("\"\74\65\78\",\"\70\69\66\",\"\77\65\82\",\"\65\80\82\",\"\77\65\89\",\"\74\85\78\",\"\74\85\76\",\"\65\85\71\",\"\83\69\80\",\"\79\67\84\",\"\78\79\86\",\"\68\69\67\",\"\85\78\68\",\"\68\85\79\",\"\84\69\82\",")bz=ob([[
o(26,86,0,fn="br"),
o(51,59,1,fn="br"),
o(76,77,1,fn="br"),
o(24,25,1,fn="br"),
o(33,41,1,fn="br"),
o("",score=0,ra=v(64,21),c=5),
o(55,"planets:   ",
score=1,ra=v(64,34)),
o(19,"population:",
score=2,ra=v(64,43)),
o(24,"technology:",
score=3,ra=v(64,52)),
o(o(27,5),o(f,0),f,o(25,5),"happiness",
score=4,ra=v(64,61)),
o("total:","",
score=5,ra=v(64,74)),
o(score=6,ra=v(64,82)),
]])pj=ke:jr([[
fa=10,
ea=o(
o(42,43,1,fn="br"),
o("",64,40,6,0.5,fn="qr"),
),
gs=o(
o("last year!",64,48,9,0.5,fn="qr"),
o("2 years remain",64,48,2,0.5,fn="qr"),
f,f,
o("5 years remain",64,48,2,0.5,fn="qr"),
),
cr=o(
hi=v(0,11),gq=v(0,11),ca=10,
),
i_=o(
o(126,127,1,fn="br"),
o(0,1,1,fn="br"),
o(8,118,34,fn="rf"),
o(0,-3,26,fn="rf"),
o(81,-3,117,fn="rf"),
),
ou=o(
o(f,13,121,9,fn="qr"),
o(f,37,121,2,fn="qr"),
o(f,13,2,9,fn="qr"),
o(f,29,2,2,fn="qr"),
o(f,59,2,2,fn="qr"),
o(f,85,2,13,fn="qr"),
o(f,99,2,13,fn="qr"),
),
ed=1,
]])function pj:hb()local cf=ne(fm.ge)local ou={fm.nz.."$",cf,fm.jk,"+"..fm.po[r.k]+1,fm.happiness.."%",ef[fm.lo],fm.yr
}
for i,p in pairs(ou)do
pj.ou[i][1]=p
end
eg()end
function pj:kj()bl(la(pj.i_,pj.ou))if self.gz then
self.gz+=0.2
local h=min(self.gz,3.2)^2
rk(0,h,0)rk(127-h,127)end
end
function pj:hk(yr)local iw,pp=
pj.ea,pj.gs[3426-yr]
iw[2][1],iw[3]=
"year "..yr,pp or nil
if pp then
local t=90
function iw.lh()
t-=1
return t>0
end
end
mh(iw)end
function pj:ph()if fm.hl and not self.gz then
fq()js(ob([[
fa=15,
ra=v(51,100),
lq=o(" again? "),
]],{my=_init}))js(ob([[
fa=15,
ra=v(39,100),
lq=o(o(10,7)),
]],de))self.c_,self.gz,self.fa=
true,0,13
end
if self.c_ and kc~=self.ed then
local s=ky()local iw=nv(bz,function(st)if st.score then
st[3]=tostr(s[st.score])if st.score==0 then
st[1]=(fm.hl or "current score").." ("..dk.px..")"end
if st.score==6 then
for i=1,5 do
st[i]=i<=s[6]and 56 or 57
end
end
return {lq(st),st.ra,0.5,fn="ld"}
else
return st
end
end)iw.rh=3
function iw.lh()
return self.c_
end
self.ed=mh(iw)end
end
de={my=function()ju.c_ = not ju.c_
return true
end
}
qh=jo:jr([[
nu=o("qh","jo","np","prober"),
hp=1,px=o("laboratory",c=13),
me="kz",dq="ly",
hf=f,qh=1,
od=15,fp=2,
dw=0.025,
mi=1,
s=174,
ba=o(28,18,20,21,22,48),
]])qh.hq=bv
qh.ly=na
qh.ev=dl
qh.ey=d_
ie=ke:jr([[
kq=b(0,0,9,8),
fa=12,
id=0,
ra=v(999,999),
eh=v(118,120),
]])ie.hd=gk
function ie:hb()if not self.kh and oj(self.ke.rr)then
self.ra,self.kh=
ie.gy,true
ie.gy-=v(10,0)
end
end
function ie:ldown(mp)
ie.id+=1
return self.ke({id="s"..ie.id
})end
function ie:kj(p)if self.kh then
palt(3,false)spr(self.ke.s,p.x,p.y)if self.m_ then
dl(self.ke)self.jb:ol(0,0)end
palt(3,true)end
end
iv=ke:jr([[
fa=9,
l=0,v=v(0,-0.34),
]])function iv:pq()self.ra=self.ra or
je.ra+mo.ra-v(0,5)end
function iv:ph()
self.ra+=self.v
self.l+=0.1
self.p_=self.l>=5
end
function iv:kj(p)dv(self.l)io(self[1],p.x,p.y,self[2],0.5)dv()end
function cr()local bs,rd,gr=
{},{},#fm.invented
local tl=fm.ew
local qi=ek[tl-1]or 0
local bs=nv(cb(true),function(t)
return {lq={t.nk,t.px,c=6},h_={{24,5},tostr(gi(t))},jb=t.oy,my=t.e_ and function()fm:kt(t)end
}
end
)if gr>0 then
add(bs,{lq={30,gr.." invented",c=3},jb=fm.invented
})end
pj.cr.ep=
"level "..tl.." ("..(gr-qi).."/"..(ek[tl]-qi)..")"pz(pj.cr,bs)end
ix=ob([[
o(
ra=v(118,0),
lq=o(o(15,7)),
),o(
ra=v(0,0),
lq=o(o(37,7)),
),o(
ra=v(47,0),
lq=o(o(25,7)),
),o(
ra=v(0,117),
lq=o(o(8,7)),
),
]])ix[1].my=function()fm.lo=1
fm:hk()end
ix[2].my=cr
ix[2].hb=function(self)self.lq=lq({#cb()>0 and 24 or 37
})end
ix[3].my=function()ju.c_=true
fq(de)end
ha=ob([[
o(lq=o(31,"restart     ")),
o(lq=o(42,"toggle music")),
o(lq=o(40,"toggle sfx  ")),
o(lq=o(26,"how to play?"),fg=5,),
hi=v(0,107),gq=v(0,-11),
ca=14,
]])ix[4].my=function()for i,fn in pairs({_init,function()music(-sgn(stat(20)))end,function()ih=not ih end,function()end
})do
ha[i].my=fn
end
pz(ha,ha)end
hj=qh:jr([[
nu=o("hj","jo","np","prober"),
rr="ascension",
hp=2,qh=f,
px=o("ascension nr",c=13),
od=60,
s=166,
py=0.12,ki=9,
pn=5,pk=1,
fc=0.5,
k_=o(1,13,12,12,12,13,13,5,1,1,1),
du=7.5,
qo=0.98,ro=-0.07,
qg=0.07,q_=0.98,
]])hj.pq=f_
hj.mm=g_.mm
function hj:kj(p)if self.mi and self.mi>=2 then
ei(self)end
jo.kj(self,p)end
pm=hj:jr([[
fz="pm",
nu=o("jo","np","prober"),
hp=3,px=o("protostar",c=13),
me="ly",s=98,
py=0.06,ki=9,
pn=8,pk=f,
ng=v(1,0),
du=2,
fc=1,
k_=o(1,2,4,9,10,7),
qo=1.02,ro=-0.0525,
qg=0.0525,q_=1.02,
]])function pm:pq()ga(ob([[
qo=0.97,ro=-0.1255,
qg=0.1255,q_=0.97,
k_=o(1,2,8,14,14,14,14,8,8,2,2,1,1),
iu=-0.009,py=9,ms=1.5,
]],{ra=self.ra+self.ng}))end
mx=hj:jr([[
nu=o("jo","np","prober"),
rr="void synthesis",
hp=5,s=66,px=o("synthesizer",c=13),
od=40,
ht=o(28,20,21,22),
py=0.12,ki=9,
pn=5,pk=1,
fc=0.3,
k_=o(1,1,5,5,3,3,3,5,5,1),
du=5,
qo=0.98,ro=-0.07,
qg=0.07,q_=0.98,
]])function mx:kf(sw)local cp=sw:eb(self)for i in all(cp.jy)do
if i.gc==0
and gu(self.ht,i.qe)then
self.kw.qe,self.ht=
i.qe,{}
end
end
jo.kf(self,sw)end
nl=qh:jr([[
nu=o("jo","np","prober"),
rr="trade league",qh=f,nl=1,
hp=6,s=68,px=o("trading hub",c=13),
od=20,qw=15,
ba=o(28,48,18,20,21,22),
]])function nl:ly(t)na(self,t)if self.mi>=2 then
self.qw=8+t%42/6
end
end
ga=jo:jr([[
fz="ga",
nu=o(),
hf=f,
by=o(),
kq=b(0,0,-1,-1),
fa=3,
fc=0,
qo=0.9,ro=0,
qg=0,q_=0.9,
k_=o(1,2,4,9,9,10,10,7,7,7,7,7),
iu=-0.06,py=6,ms=3,
]])function ga:pq()f_(self)ez(self,140)mo.ma=3
end
function ga:mm()local qd=rnd(1.5)+0.5
if (rnd()<0.6)qd=flr(qd/0.5)*0.5
local p=qm(qd,rnd())
return {p=p,v=p*self.ms,a=p*self.iu,l=rnd(self.py)+self.py
}
end
function ga:kj(p)local pt
for i=1,3 do
pt=self.qy[i]
if pt then
circ(p.x,p.y,pt.p:qx(),self.k_[flr(pt.l/2)])end
end
ei(self)self.p_=not pt
end
os=qh:jr([[
nu=o("jo","np","prober"),
hp=4,px=o("processor",c=13),
qh=f,s=100,
od=15,
hs=0.5,
]])nr=qh:jr([[
nu=o("nr","np","prober"),
od=10,fp=1,
kq=b(-4,-4,5,5),
s=170,
hz=o(170,170,170,168),
dw=0.01,
rr="slipgates",
]])function nr:gv(s)
return s.qu~=self and #self.oe<3
end
function nr:ldown()
return self:gv({})and jc({qu=self})end
function nr:hb()self.s=self.hz[#self.oe+1]
end
function nr:cn(lw)local t=lw.t
for w in all(self.oe)do
if lw.mu>0 and not gu(t.rl,w)then
local gf=mw(lw)gf.t=t:kg(self,w)w:eb(self):cn(gf)lw.mu=gf.mu
end
end
end
fr=nr:jr([[
mt=1,
rr="infraspace",
od=25,
s=78,hz=o(78,78,78,76),
]])qb=ke:jr([[
v=v(0,0),
ma=0,
p=v(192,192),
ra=v(192,192),
pc=o(v(-1,0),v(1,0),v(0,-1),v(0,1)),
]])function qb:ph()local ip=v(0,0)for b=0,3 do
if btn(b)or btn(b,1)then
ip+=self.pc[b+1]*3
end
end
self.p+=self.v
self.v+=(ip-self.v)*0.2
self.p.x=mid(-64,320,self.p.x)self.p.y=mid(-64,320,self.p.y)self.ra=ma(self.p,self)end
function qb:md(fy)local cp=self.ra*(fy or 1)camera(cp.x,cp.y)end
fv=g_:jr([[
fa=10,ra=v(64,28),
hi=v(34,56),
ca=11,
gq=v(0,11),
eo=-1,
ff=1,
fc=5,
k_=o(0,1,1,2,4,9,10,9,4,2,1,1,1),
qo=1.02,ro=-0.007,
qg=0.007,q_=1.02,
pn=5,du=15,
py=0.0067,pk=1,
ki=17,
kq=b(-40,78,40,98),
ql=11,fg=5,
rb=o(
o(192,0,11,16,4,fn="s"),
o(172,20,107,2,2,fn="s"),
o("need help?",40,110,13,fn="qr"),
o("slipways.net/help",40,116,5,fn="qr"),
),
]])fv.hd=gk
function fv:pq()for i,d in pairs(bo)do
d.my=eu
end
pz(self,bo)end
function fv:kj(p)ei(self)bl(self.rb)end
fb=ob([[
2,2,5,5,7,7,10,10,14,14,14,19,19,19,
]])function eg()local ps=#jp(cg.jo,jo.gg)/2
for i,ny in pairs(fb)do
local pd=0x3101+4*ny
poke(pd,peek(pd)%128+(ps<i and 128 or 0))end
end
function _init()cu()jl()ie.gy,kc=
ie.eh
fv()music(0)end
function eu(nj)dk=nj
jl()bg()bw(90)fm,ju=hy(),pj()nv(ix,js)local gx={qh,os,nr,fr,nl,mx,hj
}
for i,b in pairs(gx)do
ie({ke=b,jb=jb(dr[i])})end
fm:lj()end
function _update60()dg()ok:lj()end
function _draw()cls()dv()dc("kj")dc("ev")end
bo=ob([[
o(lq=o(49,"forgiving   "),px="forgiving",
trade=7,en=-0.99),
o(lq=o(50,"reasonable  "),px="reasonable",
trade=6,en=-0.6),
o(lq=o(51,"challenging "),px="challenging",
trade=5,en=-0.4),
o(lq=o(52,"tough       "),px="tough",
trade=4,en=-0.2),
]])hy=kv:jr()function hy:pq()qj(self,ob([[
nz=100,ge=0,
jk=0,ew=1,
invented=o(),
lo=1,yr=3401,
]]))end
function hy:nx(hx)local kx=ov("time compression",12,15)
self.lo+=hx
self:lj()if self.lo>kx then
self.lo-=kx
self:hk()end
end
function hy:hk()
self.nz+=self.ge
self.jk+=self.po[r.k]+1
self.yr+=1
self:lj()for e in all(cv.hk)do
e:hk(self.yr)end
end
function hy:lu(jt)if self.nz<jt then
iv({"-no money-",8})
return
end
self.nz-=jt
if jt~=0 then
iv({ne(-jt,10,"$")})end
return true
end
function hy:lj()repeat
bd()until not bb()self.po,self.fu=
bx(),ck()local dd=0
for p in all(cg.jo)do
p.kr=flr(db(p)-
da(p))
dd+=p.kr
end
self.ge=flr(dd*ov("skill implants",1,1.15))- cz()self.happiness=
bf()self.hl=
self.yr>=3426 and "final score"or self.ge<=0 and self.nz<3 and "bankrupt"for e in all(cv.hb)do
e:hb()end
end
function cm(jm)local p={}
for _,qe in pairs(r)do
p[qe]=jm
end
return p
end
function bx()local p=cm(0)for pt in all(cg.jo)do
if pt.jy then
p[pt.kw.qe]+=pt.kw.mu
end
end
return p
end
function ck()local d=cm(1)for l in all(cg.qh)do
d[l.jy[#l.jy].qe]-=0.15
end
return d
end
bn,bq=
6,0.0977
function dj(pb,to)local ec=
(#(to.p-pb.p)/bq)^0.75
return flr(bn*bk()*max(0.5,ec))end
function bk()
return max(1,sqrt(#(cg.jc or {}))*0.27-0.1
)end
function bd()for pt in all(cg.jo)do
pt.cc={}
end
for pt in all(cg.jo)do
pt.by=pt:ib()for e in all(pt.by)do
for i,w in pairs(e.rl)do
w.hg[e.lp[i+1].id]=true
end
add(e:to().cc,e)end
end
end
function bb()local jg
for pt in all(cg.jo)do
local jw=dh(pt)if not pt.mi or jw>pt.mi then
if pt.mi==1 and pt.hn.dm then
add(pt.jy,{qe=pt.hn.dm})end
pt.mi,jg=
jw,true
end
if pt.mi~=0 then
local po=pt.hn:po()pt.kw.mu=
po[min(pt.mi,#po)]+
(pt.jh or 0)end
end
return jg
end
function dh(pt)
if (pt.me~="ly")return 0
local jd=1
for i in all(pt.jy)do
i.gc=
#jp(pt.cc,function(im)
return im.qe==i.qe
end)
jd*=i.gc
end
if (jd==0)return 1
if pt.nl then
return min(#jp(pt.jy,function(i)
return i.gc>0
end),3)end
if not pt.hf then
local li=pt.jy[#pt.jy]
return li and min(li.gc+1,4)or 2
end
return min(4,1+mid(#pt.by,#pt.cc,1))end
es=ob([[1,0,1,2,]])
function da(pt)
return pt.qh
and #cg.qh
or pt:gg()
and es[pt.mi]
or 0
end
function cz()
local mu=#jp(cg.jo,jo.gg)
return flr(0.18*mu^2)
end
ct=
ob([[-0.333,0,0.25,0.5,]])
function db(pt)
local total=0
for e in all(pt.by)do
local oz=e:to()
if oz.hf then
total+=dk.trade*pt.hs*(1+ct[pt.mi]+ct[oz.mi])
end
end
if pt.kw.qe==r.w then
total+=pt.kw.mu*dk.trade*1.5
end
return total
end
b_=ob([[0,100,200,400,]])
function ky()
local di=0
for pt in all(cg.jo)do
if pt:gg()then
di+=b_[pt.mi]
end
end
local gl=
fm.po[r.p]*40
local el=
flr((#fm.invented*1.2)^2)*10
local total=flr((
di+
gl+
el
)*0.01*fm.happiness)
return {
di,
gl,
el,
fm.happiness.."%",
total,
min(flr(total/2000),5)
}
end
co=ob([[-5,0,1,1,]])
function bf()
local h=100+2*(
fm.po[r.h]+
fm.po[r.w]
)
for pt in all(cg.jo)do
if pt:gg()then
h+=co[pt.mi]
end
end
return h
end
r,iz=ob(unstash(8192)),ob(unstash(8259))df=ob([[
o("ll",45,0,me="ll"),
o("e",160,4.5,"earth-like"),
o("f",128,6,"forgeworld"),
o("m",134,4,"mineral"),
o("o",130,3,"ocean"),
o("r",140,2.5,"remnant"),
o("x",162,3,"xeno"),
o("j",136,2,"jungle"),
o("i",138,2,"iceball"),
o("s",142,2,"barren"),
o("g",96,4,"gas giant"),
]])foreach(df,ho(df,ob([[
"px","s","r","d",
]])))hc=ob(unstash(8383))fd=ob(unstash(8494))function bj(jo)
return jp(gb,function(b)if oj(b.rr)then
local mg
fi(b.lr,function(k)mg=mg or k==jo.nk.px
end)
return mg
end
end)end
hp=kv:jr([[
mr=o("px","lr","fj","ja","i","o","il","dm"),
gp=o("o","dm"),
fk=o(f,2),
]])function hp:pq()ho(gb,hp.mr,hp.gp)(self)if self.ii then
self.lq={self.px,32,{self.ii,8}}
end
self.i=fi(self.i or "",function(c)
return {qe=r[c]}
end)end
function hp:lq()local l=
jo.ex(self.i,self.o,max(self:po()[1],1),0,1
)add(l,hp.fk)add(l,self.px)
return l
end
function hp:jb()
if (self.ii)return
local it
for i in all(self.i)do
it=(it and it.."," or "")..iz[tostr(i.qe)]
end
return {{it,13,iz[tostr(self.o)]}}
end
function hp:po()local qp=hc[self.ja]
return self.il and oj(self.il)and hc[qp.mc]
or qp
end
function hp:od()local od=self.fj
if self.il and oj(self.il)then
od*=1.5
end
if not self.ii and oj("nanomaterials")then
od*=0.85
end
return flr(od)end
gb,rr={}
for ri in all(fd)do
if type(ri)=="string" then
rr=ri
else
ri.rr=rr
add(gb,hp(ri))end
end
dr=ob(unstash(9807))nb=ob(unstash(10457))foreach(nb,ho(nb,ob([["px","lv","nk","od","oy",]]),
{"nk"}
))
ek=ob([[2,4,7,12,]])
function hy:kt(t)
self.jk-=gi(t)
add(self.invented,t.px)
if self.ew<4
and #self.invented>=ek[self.ew]then
self.ew+=1
end
self:lj()
end
function cb(bi)
return jp(nb,function(t)
t.e_=gi(t)<=fm.jk
return t.lv==fm.ew
and not oj(t.px)
and (t.e_
or bi)
end)
end
function oj(px)
return not px or gu(fm.invented,px)
end
function ov(px,lk,mc)
return oj(px)
and mc or lk
end
function gi(t)
return flr(t.od*max(0.55,
fm.fu[t.nk]))
end
function cl(p1,p2,q1,q2)
local oq1,oq2,op1,op2=
ee(p1,p2,q1),ee(p1,p2,q2),
ee(q1,q2,p1),ee(q1,q2,p2)
return oq1 and oq2 and op1 and op2
and oq1~=oq2 and op1~=op2
end
function ee(a,b,c)
local kl=
(b.y-a.y)*(c.x-b.x)-
(b.x-a.x)*(c.y-b.y)
return kl~=0 and sgn(kl)
end
function be(a,b,c,fh)
local d=b-a
local l_=d:rg(c-a)/#d
return l_>0.01
and l_<0.99
and #(a+d*l_-c)<fh
end
__gfx__
00000000000000003000000300000003307700033007700330000033333333330000000333000033331133333305033333330303333333333333333333000333
111000211111111130488803077766033077000330700a03050d0503333003330ddd55033076760331551333330703333330e0e0333003333300033330666033
2211002122222222304882030dd555033066570330a00a0300c7c003330760330000000330777760157c50330007000333008880000090333006003306757d03
333110213333333330400003066d0d03306656030a0330a00d777d03dd0660dd0dd555030767776015cc5033076776d030aa08030999ff033066603306557d03
42211021444444443020113305511103306656030a03309000c7c00311500511000000033077776031551033307777600a44a033000090333006003306777d03
5511102155555555302033333333333330dd5d0309033090050d0503330650330dd55503330776033300050333077603094a9033333003333300033330ddd033
66d51085666666663333333333333333333333333333333330000033333003330000000333000003333330333307760330990333333333333333333333000333
776d108d777777763333333333333333333333333333333333333333333333333333333333333333333333333300000333003333333333333333333333333333
88221021a00490903033303333000333330003333300033330000033330003333300033330030033000000033333333330003333333333333333333333000333
942210219a0049000d0005030007000330ddd033307e20330076100330aaa0333077903307e07e03077777033333333307a00033300300333333303330888033
a942108509a0049000d050030f888f030d77b5030ae221030f7d1a030a4449030777a9030e88e80307ddd7033333d3d30a407a033080803333330b0308008203
bb3310854049002007776d03008820030d7bb5030e22e103047d12030a49a90309aa9903028882030777770333333d3330904403330803330030b00308080203
ccd51021240490000d6d6d0330dd50330dbb5033302e22030f6d1a03094aa903309990333028203307ddd7033333d3d33309403330202033070b003308800203
d5511021dddddddd06666d0330d050333055033333012003005510033099903330d55033330203330666660333333333330403333003003330b0033330222033
ee82108504909a000000000330000033330033333330003330000033330003333000003333303333000000033333333333000333333333333300333333000333
f9421085004909a03333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333300000333300333333333333330003333300033333000003330000033330033330001003330000330000000000000000001111100000000000000000
33300333050d0503307033330033333330dd003330ddd03330756d1330ab5d130007033304249403330a90330001110000000000011000110000000000000000
0000503300c7c003077000330d0333333000d0330d773d030757dd130bb5cd1307660633029aaa13330900330015551000000000110110011000000000000000
015555030d777d037777603305503333300500330d333d0306555113055cd5130666033304a7771330090333015dd50100000000101000001000000000000000
0000503300c7c003067000330503333333000333303330330657651306c515130556063319a777230aa90333015d550100000000100000001000000000000000
33300333050d0503306033330033333333050333305110330d56dd130cdbb1130005033304a77723099403330155500100000000100000001000000000000000
33333333300000333300333333333333330003333000003301111113011111133330033300112223300033330010001000000000110000011000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333330001110000000000011000110000000000000000
33000003333333333333333333333333311133331111133330000033330003333330333333303333003333330000000000000000001111100000000000000000
3049940333333333311133331111133330703333171a13330209020330adc0333307033333020333060333330000000000000000000000000000000000000000
044449033111333330a03333070a0333111113331100033300a7a0030ab5cd030077a00000221000076033330000000000000000000000000000000000000000
04ff490330a0333330003333000003330a0903330a090333097779030d5ccd037777aaa022221210077603330000000000000000000000000000000000000000
04ff4403300033333090333350905333000003330000033300a7a0030ccc5b0309aaa90301111103077760330000000000000000000000000000000000000000
0444403335553333300033333000333350905333509053330209020330ddb03307949a0302101103000700330000000000000000000000000000000000000000
00000333333333333555333335553333300033333000333330000033330003330a000a0301000103330060330000000000000000000000000000000000000000
33333333333333333333333333333333355533333555333333333333333333330033300300333003333000330000000000000000000000000000000000000000
00007000000000000000700000000000015555510000000033003333003333330000000000000000000000000000000000017100000000000001710000000000
007561d000000000007561d0000000001566dd55100000003055333355033333000000000000000000100000000000000001d100000000000001d10000000000
076511d500000000076511d500000000115555511000000005553333555033330000000000000000000000000000000001000001000000000100000100000000
0512221100000000051111110000000005111115000000000555333355503333000100000000000000000000000000006502220560000000650ccc0560000000
002eae2000000000001b7b10000000001607060d000000000555333355503333000000000000000000000000000000000502880500000000050c770500000000
0089798000000000013777310000000051777661100000000555333355503333000000000000000000000000010000000002880000000000000c770000000000
0089a98000000000013a7a31000000005d1111151000000005553333555033330000000000000000000000000000000005700075000000000570007500000000
008e7e8000000000003b7b300000000015dd55511000000005553333555033330000000000000000000000000000000000105050000000000010505000000000
070222050000000007055505000000001c55551b1000000005553333555033330000000001000000000000000000000000000000000000000000000000000000
076616d500000000076616d50000000001ef89a10000000005553333555033330000001000000000000000000010000000000000000000000000000000000000
00650d500000000000650d5000000000001111100000000005553333555033330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000030553333550333330000000000000000000000100000001000000000000000000000000000000000
00000000000000000000000000000000000000000000000033003333003333330000000000000100100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000033333333333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000033333333333333330100000000000000000000000000100000000000000000000000000000000000
00000000000000000000000000000000000000000000000033333333333333330000000000000000000000000000000000000000000000000000000000000000
0001222101000000000001000000000000076d000000000031244403315abd03315ddd0331155503311222033015550330555503306660333000000330ddd033
0024f9e2101000000200020002000000007000d00000000014ffff0315ab5c031dcccc031577760312eee80305babd030577770306000d03221010030d000503
01499e44212000000042494240000000d707000d500000002ff77f035ab5cd035cc77c03177777031e8821031bddbb03577bbb0370ccc0509e210203d0d50050
02efffe4490000000029aaa920000000d711111d500000004f79f903555cdd03dc77cc03577676031228ee035abdba0357bbb60370c77050e4421403d0500050
02ef9ee7a0000000104a777a4010000050ddddd0500000004fffff035cc55d03dccccd0357776d03128e88035bdadd0357b6bb0370c77050fe449003d0000050
4249977f21000000529a777a9250000010000000100000004f9f99035cdbb5035cdcdd035776660328e822035dbd5d0357bb660306000503ee7a000305000503
09a7aa9421000000004a777a40000000003bb3300000000000000003000000030000000300000003000000030000000300000003305550330000000330555033
00224422100000000759aaa91d000000000311000000000033333333333333333333333333333333333333333333333333333333330003333333333333333333
000222210000000000725552600000000000000000000000301555033076d003366ddd03301d1003000000000100000010000000000000000000000030d0d503
00000000000000000100676001000000000000000000000005756d0307000d03d55555031000001300000101100110000000000000000000000001000c000503
0000000000000000000001000000000000000000000000001757dd03707000d3d111110350ccc053000100100011000110011000000110000100000050000003
00000000000000000000000000000000000000000000000056555103711111d36070600350c770530010010001100000001001001010001000011000000c0003
000000000000000000000000000000000000000000000000565765030ddddd037777660300c77003001000000100000000100000001000010111000050c77003
0000000000000000000000000000000000000000000000005d56dd0300bb5003d111110357000753000100000000000100010010000100000100000050070003
00000000000000000000000000000000000000000000000000000003000000030000000301050503010000000000000000000100000000000000001000000003
00000000000000000000000000000000000000000000000033333333333333333333333333333333100000000000010000000010000000000000000033333333
0015551000000000005ddd50000000000000000000000000001222100000000000155510000000000015551000000000005dd410000000000024441000000000
05756d51000000000dccccd500000000000000000000000002eee8210000000005bab3b10000000005777651000000000d565f410000000004ffff4100000000
1757dd15100000005cc77cc51000000000000000000000001e882110000000001b33bb3500000000177777650000000057d55f94000000002ff77f9400000000
565551d510000000dc77ccd51000000000000000000000001228ee82100000005ab3ba5510000000577676d510000000d655f944100000004f79f99410000000
5657655510000000dccccdc5100000000000000000000000128e8822100000005b3a33311000000057776dd510000000d5ff9472100000004fffff9210000000
5d56dd15100000005ccddc5510000000000000000000000028e822121000000053b3535110000000577666d51000000049994755100000004f9f994210000000
15d56551100000001ddcd551000000000000000000000000188282210000000013353511000000001566dd510000000014426d110000000014f9942100000000
01555511000000000155551000000000000000000000000001222210000000000155111000000000015555100000000001222510000000000144221000000000
00111110000000000001110000000000000000000000000000011100000000000001110000000000000111000000000000011100000000000001110000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005abd500000000000533310000000000000000000000000000606d010000000050070050000000005007005000000000000000000000000000dd50000000000
03ab3cd500000000037777b1000000000242022000000000070d0d550100000000056100000000000005610000000000000000e8820000000007760000000000
5ab3cdd5100000005777bb3d0000000027f92ff20000000000c00050c0100000006000d000000000006000d000000000000000ea820000000d07760500000000
b33cddb310000000377bb6b3100000004f94ff9410000000d500000c001000000702220600000000070ccc060000000000000022220000006dd06055d0000000
dcc55d111000000037b6bb331000000049427422100000000000c000501000000702e80600000000070c77060000000000000067cd00000076001006d0000000
5cdbb5551000000037bbbd35100000004f97f94210000000d50c770d501000000702880600000000070c7706000000000000cd5c5dcd00000667776d00000000
1ddb3b31000000001bbd33510000000014f4422100000000d500700d501000000060006000000000006000600000000000000dc6c5d000000066666000000000
0151331000000000013351100000000001442100000000000500000d010000000d0ddd0d000000000d0ddd0d00000000000000c6c50000000600000d00000000
000111000000000000011100000000000001100000000000000d55000000000000001000000000000000100000000000000000cdc50000000066ddd000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ea8060d08a82000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001220701d02222000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008110c010d0000100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008821000000211100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008821900109221100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008221401104221100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002110200002110000000000000000000
33333333333333333333333333333333333333333333333333333333333499994923333333333333333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333334aa999949444423333333333333333333333333333333333333333333333333333333333
3333333333333333333333333333333333333333333333333333334aaa4000000024444233333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333aa4000000000000024423333333333333333333333333333333333333333333333333333333
3333333333333333333333333333333333333333333333333333aa00000000000000000442333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333344000000000000000000044233333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333000000000000000000000002203333333333333333333333333333333333333333333333333333
33333333333333000000000000000000000033000000000000000000000000000000000000000000000000000000333000000300000000003333333333333333
3333333333333007777777766600777d000033077770077761777d00007750000000077500000777766d000777d03330776d000766ddddd00333333333333333
33333333333300776ddddddddd00776d0100330777d07776505666d0007750000000077d0000766ddd66d00666d033306ddd106dd55555550333333333333333
3333333333330776d0000000000776d01003300766d076650006666d057650000000076d000666d000d66d066dd003300ddd50dd500000000333333333333333
333333333330011000111111100766d0100330766d0666501110666d0d6650000000066d100ddd00110ddd00ddd503330ddd5011101111110333333333333333
333333333330777d0000000000666d01003330666d01110000001110066d500000000d6d5011000100011100ddd5003300ddd50dd60000000003333333333333
3333333333307666666666d000666d0100330011100775000000777507dd10007600056d50665010000076500ddd5000006dd500dd6666dddd00033333333333
3333333333300555555566650111001003330777607665000007665007d50007dd50006d507d500000007dd50ddd5177617dd5010ddddddddd51003333333333
3333333333301000000056650776501003330766d07666661676d5010655007dddd500d5507dd67716776dd500dddd16d51dd500100000000555100333333333
3333333333300111111011107665010033300766506ddd5505551011011106dd5ddd5011107ddddd16dddddd5005551dd5155000011111111011100033333333
3333333300000000000776507665000000006dd506ddd5000000011006656dd500ddd5dd10d55555055555dd5000000ddd50010000000000000d551033333333
333333300777777777766506ddd6777766506dd506dd50155055110006dd5550110d555510d5100000000055510155155d50010330ddddddddd5551033333333
333333007666d6dddddd5006dddddddddd506dd506dd50111011100006555101111055551055101110111055510011105551000330d555555555551033333333
3333330655555555555501d555555555555055550555500000000000055110110011011110111011101110111100000011110033301111111111110033333333
33333300000000000000110000000000000000000000000000000000000001100001100000000000000000000000000000000033300000000000001033333333
33333301000010111111101111515155555055550555503300000000055151000000111110111000000000111100333011110333301111110100001033333333
33333301000101111111001111111111111011110111103332000000011110000000011110111000000000111100333011110333301111101000010033333333
33333300000000000000000000000000000000000000003334400000000000000000000000000003333300000000333000000333300000000000000033333333
33333300000000000000000000000000000000000000003333440000000000000000000000000003333300000000333000000333300000000000000033333333
33333333333333333333333333333333333333333333333333344000000000000000000011133333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333332200000000000000000222333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333222000000000000012223333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333312221000000012222133333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333122222222222213333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333122222213333333333333333333333333333333333333333333333333333333333333
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000001000100000000000000000000000000010001000001000000000100000000010101000000000000000000000001000000000000
0002000001000001010000000101010100000000010000000100000000010101000001000101000201000100000000000000010001010000010001000000000000000000000001000201000101000001000000000000010000010000000000010000000000000001000100000000000100010100000000010000000000000001
__map__
33062a1d23290f2a1d1c29022a1c2329102a1c2429072a1f2329142a1d1d290c2a1d1b29172a1c1d290b2a1d1f29312a1e2129012a1e1e29052a201f29082a1d202900331d232a2f060f0f042f291d1c2a2f0f12052f291c232a2f020f14132f291c242a2f10050f100c052f291f232a2f070f0f04132f291d1d2a2f14050308
2f291d1b2a2f0f1207010e0903132f291c1d2a2f0c15181512192f291d1f2a2f130309050e03052f29201f2a2f050e051207192f291d202a2f0a0f192f290033062b2a0f261b291c291d291e290d032a2f062c2f272933062c2a0f261b291d291e291f2729332b2a0f261c291d291e290d032a2f2c2f2729332c2a0f261d291e
291f27293311082a0f261b291c291e2920290d032a2f11082c2f27293311082c2a0f261b291d2920292327293300330f262f2f292f2f291b292f11082f292f10312f292f0b2f292f131510051208150d010e2501092f27290f262f2f292f2f291b292f062c2f292f102f292f082f27290f262f2f292f2f291b292f2b2f292f2f
292f052f27290f262f2f292f2f291b292f062b2f292f0c2f292f062f292f18050e0f060f0f04132f27290f262f2f292f2f291b292f062b2f292f2f292f312f27290f262f2f292f2f291b292f062b2f292f31312f292f172f2906292f312f27290f262f0e010e0f140503082f292f062f2923292f2b2f292f0f2f292f142f2729
0f262f020f14132f292f062f2923292f2c2f292f0f142f292f022f27290f262f070f0f04132f292f062f291c1b292f2c2f292f0f022f292f072f27290f262f070104070514132f292f062f291c1b292f2c2f292f0f142f292f072f27290f262f08091605170f120c042f292f052f2920292f2c2f292f062f292f102f2906292f
072f27290f262f030f0c0f0e192f292f0f2f291c1b292f2b2f292f0f062f292f102f292f07050e0525120517120914090e072f292f072f27290f262f030f0c0f0e192f292f182f291c1b292f2b2f292f14062f292f102f292f07050e0525120517120914090e072f292f072f27290f262f0d090e052f292f0d2f2920292f2b2f
292f102f292f0f2f27290f262f13141209102f292f122f2920292f2b2f292f10062f292f0f2f27290f262f0107120f170f120c042f292f052f2920292f2b2f292f022f292f062f292f18050e0f060f0f04132f292f0c2f27290f262f010c0701052f292f0f2f2923292f2b2f292f022f292f062f292f18050e0f060f0f04132f
292f0c2f27290f262f02120505042f292f0f2f2920292f2c2f292f102f292f0c2f27290f262f02120505042f292f182f2920292f2b2f292f022f292f0c2f27290f262f08150e142f292f0a2f2920292f2b2f292f102f292f0c2f27290f262f0409130d010e140c052f292f122f2920292f2b2f292f10062f292f142f27290f26
2f13030116050e07052f292f122f2920292f2b2f292f10062f292f022f27290f262f140f151209130d2f292f0a2f291c1b292f062b2f292f10072f292f172f27290f262f0c15181512192f292f052f291c1b292f062b2f292f14072f292f172f27292f18050e0f060f0f04132f290f262f0601120d2f292f180a2f291c1b292f
2b2f292f022f292f062f2906292f0c2f27292f07050e0513050504132f290f262f080102091401142f292f13092f291c1d292f2b2f292f0c062f292f102f2906292f072f27290f262f07050e050601120d2f292f13092f291c1d292f2b2f292f0c022f292f062f27292f0412090c0c020f14132f290f262f0518030116011405
2f292f0d2f291c1d292f2c2f292f022f292f0f2f27290f262f05180301160114052f292f09072f291c1d292f2b2f292f022f292f0f2f27292f07050e0525120517120914090e072f290f262f15100c0906142f292f062f291d1b292f2b2f292f0c2f292f102f27292f1205100c09030114090f0e2f290f262f0d050308010e09
1a052f292f0d12130f090a182f291d1b2909092a1e2329070f2a2f062f27292f02090f0d05250801030b090e072f290f262f1405121201060f120d2f292f1809130f0a2f291d1b2909092a1e2429070f2a2f052f27292f1314011202091214082f290f262f030f0c0c011013052f292f070d2f291e1b2909092a1f1c2903172a
2f100d2f29120e2a1f2027292f07050f08011216051314090e072f290f262f080112160513142f292f05060d0f12180a0913072f292b1d1b2909092a1d1e2903172a2f07012f29120e2a1f21272900330f260f262f2b0c01022b2f29032a2427290f262f0d010b05132f291d1f292f130309050e0305251708050e2513151010
0c0905042f27290f262f170914082f291c24292f010e0425010e19251205130f151203052f27290f262f010404090e07250d0f1205250f062514080114251205130f151203052f27290f262f090e03120501130513250f15141015142f272927290f260f262f2b060f0f042510120f030513130f122b2f29032a2427290f262f
030f0e16051214132f291d1b292f090e140f2f291d23272927290f260f262f2b130c0910070114052b2f29032a2427290f262f030f0e0e0503141325151025140f251e25130c0910170119132f272927290f260f262f2b090e061201070114052b2f29032a2427290f262f030f0e0e0503141325151025140f251e25130c0910
170119132f27290f262f120f15140513251408120f15070825090e06120107011405132f27290f262f03010e2503120f1313250f1408051225130c0910170119132f272927290f260f262f2b14120104090e07250815022b2f29032a2427290f262f07050e0512011405132f291d20291d1e292f0f0e030525190f1525030f0e
0e0503142f27290f262f1d250f12251e25040906060512050e14251205130f15120305132f272927290f260f262f2b13190e14080513091a05122b2f29032a2427290f262f03010e2510120f160904052f291d23291d1b291d1c291d1d27290f262f140f250125100c010e05142514080114250e050504132509142f27292729
0f260f262f2b011303050e13090f0e25070114052b2f29032a2427290f262f010303051014132f291c24292f010e04251415120e13251408050d2f27290f262f090e140f2f291d20292f08011010090e0513132f2729272900330f262f131001030525060f0c04090e072f291c292f142f291f290f262f0c0f0e070512251201
0e07052f292f0f0e25130c09101701191325010e042510120f0205132f2727290f262f07050e0513050504132f291c292f0c2f2920290f260f262f1513052f291c1b1d291c1b20292f100c010e0514132f27290f262f140f25130514140c052f291c24292f010e04250601120d2f291d23272727290f262f0e010e0f0d011405
1209010c132f291c292f0f2f2921290f260f262f030f0c0f0e091a090e0725100c010e0514132f27290f262f0205030f0d0513251c203225030805011005122f272727290f262f0412090c0c020f14132f291c292f022f2922290f260f262f0215090c04250d090e0513251513090e072f291c2327290f262f0f0e2f291c1b21
291c1b20291c1c1b292f100c010e0514132f272727290f262f18050e0f060f0f04132f291d292f0c2f291c1b290f260f262f010c0c0f17250601120d090e072f291d23292f0f0e2f291c1b22291c1b2327290f262f090d10120f16052f291d23292f0f1514101514250f062f291c1b1e291c1b1f291c1c24272727290f262f13
0c091007011405132f291d292f142f291c1d290f260f262f0215090c042f291c1b24292f130c091007011405132f27290f262f140f25051814050e0425190f151225130c0910170119132f272727290f262f07050f08011216051314090e072f291d292f0f2f291c1f290f260f262f04051314120f1925050d10141925100c01
0e0514132f27290f262f060f1225010e25090e1314010e14251d1b2f291d1e292f020f0f13142f272727290f262f1412010405250c05010715052f291d292f142f291c21290f260f262f0215090c042f291c1d1b292f14120104090e07250815021325140f2f27290f262f1415120e251d2b1e25040906060512050e14251205
130f15120305132f27290f262f090e140f2f291d20292f08011010090e05131325010e042f291d1e292f0d0f0e05192f272727290f262f1205100c09030114090f0e2f291d292f022f291c23290f260f262f1415120e25010e19250f062f291c1b1d291c1b1f291c1b20291c1b21291c1b22291c1b2327290f262f090e140f2f
291c1c23292f060f120705170f120c04132f272727290f262f0115140f011313050d020c0512132f291e292f022f291c24290f260f262f030f0c0f0e091a090e0725100c010e0514132f27290f262f14010b0513251d250d0f0e14081325090e1314050104250f06251e2f272727290f262f130b090c0c25090d100c010e1413
2f291e292f022f291d1d290f260f262f0501120e251c2032250d0f12052f291d1e292f090e030f0d052f27292f06120f0d2514120104052f2727290f262f1314011202091214082f291e292f0f2f291d20290f260f262f030f0c0c011013052f291c1c1b291c1b21292f090e140f2513140112132f27290f262f140f250d010b
052f29201f292f140801142506090c0c1325010e19250e0505042f27290f262f010e0425090e031205011305132510120f04150314090f0e2f272727290f262f02090f0d05250801030b090e072f291e292f0c2f291d23290f260f262f1405121201060f120d2f291c1b1d291c1b1f291c1b20291c1b22291c1b2327290f262f
090e140f2f291c1b1e292f05011214082b0c090b0525170f120c04132f272727290f262f090e06120113100103052f291e292f142f291e1c290f260f262f0215090c042f291c1d1c292f090e06120107011405132f27290f262f14080114250c051425130c09101701191325100113132f27290f262f150e040512250f140805
1225130c0910170119132f272727290f262f131510051208150d010e2501092f291f292f142f291e1f290f262f0c010213250e0f172507050e05120114052f290f262f1d2e202e232f291d1f292f0201130504250f0e250c0516050c2f272727290f262f160f09042513190e1408051309132f291f292f0f2f291e23290f260f
262f0215090c042513190e14080513091a0512132f27290f262f14080114250312050114052f291d23291d1b291d1c291d1d272727290f262f07050e0525120517120914090e072f291f292f0c2f291f1d290f260f262f030f0c0f0e090513251909050c04250d0f12052f291c2427290f262f190f152503010e2515100c0906
142f291d1b291c1e291c2427290f262f1513090e072f291c1c23292f060f120705170f120c04132f272727290f262f14090d0525030f0d1012051313090f0e2f291f292f022f291f21290f260f262f01040413251e250d0f0e14081325140f25050103082f291c20292f190501122f272727290f262f011303050e13090f0e2f
291f292f012f29201b290f260f262f0215090c042f291c1d22292f011303050e13090f0e2507011405132f27290f262f140f251415120e2f291c24292f090e140f2f291d20292f08011010090e0513132f2727272900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110001e1f7741f74518774187101a7741a7451f7741f74518711187441a7741a7451f7741f745187741d0161f7741f7451a7741a74518774187451a7741a710227111f77418774187451a7741a7451f7041f705
011000140c174000550c1740c1751f0341f0440c174180550c1000c1000c17400575131451f1350c174000750c1740c1750c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c100
010800200c6150c6050c6150c605186150c6050c6150c605306150c6050c6150c605186150c6050c6150c6050c6150c6050c6150c605186150c6050c6150c605306150c6050c6150c605186150c6050c6150c615
010714200a7700a7700a7700a7700a7700a7700b7710b7700c7710c7700c7700c7700c7700c7700c7700c7700c7700c7700c7700c7700c7600c7600c7600c7600c7600c7600c7600c7600c7600c7600c7600c760
010c10201052511545187501875018750187501875018750187501875018750187501876018760187601876018770187701877018770187601876018760187601876018750187501875018750187501876018760
010716181851018510185201852018530185301854018540185501855018560185601855018550185401854018530185301852018520185101851018514185151850018500185001850018500185001850018500
01051f201853018530185301853018520185201851518530185301853018520185201851518530185301853018520185151853018530185201851518530185201851518520185101852518515185151851518500
0110000518735187101f71218735187152670518705187051f7051f70526705267051f7051f7052670526705267051f70518705187051a7051a7051f7051f7050070500705007050070500705007050070500705
0194000012b4412b350d52512b4412b3012b350dd4512b4412b450652512b4412b4012b450d52512b4412b450d52510b4410b4010b450b53510b4410b451052510b4410b4010b450b52510b4410b4010b4510525
018100201052517c2017c2514d3414d2014d2517d3417d2514c2014c2214c2017d3417d2514c2414c2014c251972417c2417c2514d3414d2014d1517d3417d2514c2014c2214c2517d3417d2514c2014c2014c25
019400201cc141cc101cc1519d3419d251cd341cd201cd1519c2419c2219c251cd341cd2519c2019c2019c25155051cc201cc2519d3419d2019d251cd341cd2519c2019c2219c251cd341cd2519c2419c2019c25
012000090a51511515185150a515115151a5150a515115151a5171a5051d5050e505055050e5050e505005051a5050a505115051a5051a5050a505115051a5050a505115051a5050a5051a5050a505115051a505
0180000010d2500a2016e2400a2016e2400a2000a2000a2016e2000a200fe2000a2016d1000a2016e2000a200fd2400a2016e2400a2016e2400a2000a2000a2016d2400a200fe2000a200ad2000a200fd2000a20
01ac00000cb440cb400cb400cb450cb440cb400cb400cb450cb440cb400cb400cb450cb440cb400cb400cb450cb440cb400cb400cb450cb440cb400cb400cb450cb440cb400cb400cb450cb440cb400cb400cb45
01ac0000107041cb241cb201cb201cb201cb25000001cb241cb201cb201cb201cb25000001cb241cb201cb201cb201cb2510d341cb241cb201cb201cb201cb25000001cb241cb201cb201cb201cb201cb2510d34
01ac000026b041ab0426b2426b2026b2026b2026b251ab0523b2423b2023b2023b2023b2524b0026b2426b2026b2026b2026b2524b0023b2423b2023b2023b2023b2524b002db242db202db202db202db202db25
01ac00001ab0410d442ab242ab202ab202ab202ab251cb00175241752017520175201752518b002ab242ab202ab202ab202ab2518b0026b2426b2026b2026b2026b2518b0021b2421b2021b2021b2021b2021b25
018000002082420810208242081020824208152082420810228242281022824228102282422815228242281020824208102082420810208242081520824208102782427810278242781022824228102282422810
01ac000013b4413b4013b400252513b4413b4013b4013b4513b4413b4013b400252513b4413b4013b4013b4513b4413b4013b4013b4513b4413b4013b400252513b4413b4013b4013b4513b4413b4013b4013b45
01ac0000105051ab241ab201ab201ac201ac2510d341ab141ab101ab101ac201ac2512d341cb141cb101cb101cc201cc2510d341cb241cb201cb201cb201cb2510d341ab241ab201ac201ac201ac201ac2510524
01ac000026b041252426b2426b2226b251ac201ac2510d4423b1417c2017c2017c2217c2217c251ac201ac201ac2526b1426b2026b2517c2017c2523b2423b2023b25125242db242db252ab242ab202ab222ab25
01ac0000105251cb241cb2221b2421b2510d341eb241eb201eb201eb201eb201eb2510d441fb241fb201fb201fb201fb2510d441eb241eb221eb201eb201eb2510d4421b2421b2021b2021b2021b2221b2510524
01ac000026b042db142db151ec201ec201ec221ec251ab052db242db252ab242ab202ab222ab251ac002fb242fb252ab242ab202ab222ab2517c052db242db251ec201ec201ec221ec252ab042db242db202db25
01ac000026b040e50226b1426b1226b101ac101ac151ab0523b1417c1017c1017c1217c1524b001ac101ac101ac1526b1426b1026b1517c1017c1523b1423b1023b15125142db142db152ab142ab102ab122ab15
01ac00000cb440cb4507d350cb440cb400cb450b5250cb440cb450b5250cb440cb400cb450b5250cb440cb40075250cb440cb400cb450e5250cb440cb45075250cb440cb400cb450e5250cb440cb400cb4507525
018000201182400a2024b1400a201482400a2000a2000a201182400a2024b1400a201681500a2000a2000a201182400a2024b1400a201681500a2000a2000a201182400a2024b1400a201681500a2000a2000a20
01ac000010b4410b450b52510b4410b4010b450d52510b4410b451052510b4410b4010b45105250eb440eb40095250eb440eb400eb45105250eb440eb45095250eb440eb400eb450e5250eb440eb400eb4509525
0180032010d2517c2017c250ad200ad200bd200bd200bd2016e2016e200bd200bd200bd2016d2016d200bd200bd200bd2016e2416e200bd200bd200bd2016d2016d200bd200bd200ad200ad200bd200bd2016d20
012000221d5151f515225152451526514295142951524514245102451224515295002e5142e5102e5152950029514295122951229515265142651026512265152b5142e5142e5102e512225142e5142e51529500
018000200db440db45085250db440db400db4508d45015250fb440fb45035250fb440fb400fb450ad450352511b4411b451151511b4411b4011b450cd450552514b4414b450852514b4414b4014b4214b3508525
01400322147141471014710197141b7141b710227142271022710227102271022712227151d71420714207102071020710257142771427710277102e7142e7102e7102e7102e7152c7142c7102c7150fe340fe35
0180032010d1517c1017c150ad100ad100bd100bd100bd100ad100ad100bd100bd100bd1016d1016d100bd100bd100bd100ad100ad100bd100bd100bd1016d1016d100bd100bd100ad100ad100bd100bd1016d10
01800020087250db4508e45010250de440102508d4501125030350fe35031240fb45030240fe350ae250353511b450502511e350502511e34050250cd45051240802514e350802514b4414b4514e3514e2508114
018000201491014910149101492516910169101691016925089100891008910089250a9100a9100a9100a9251491014910149101492516910169101691016925089100891008910089250a9100a9100a9100a925
0110001818a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a1518a0018a0018a0018a0018a0018a0018a0018a00
01800000208242081022824225152282422810278241651529824298102c824275152782427810278241b51529824298102c8242251527824278102782416515208242081022824275152282422810278241b515
018000201391013910139101392516910169101691016925079100791009910099100a9100a9100a9100a92514910149101491014925139101391013910139250891008910089100892507910079100791007925
01800000228242251522824295152282422515278241651522824245151f824265152282422515278241651529824275152c824265152782422515278241651529824275152c8242951527824225152782416515
0180000e0f9100f91011910119101391013910159101591016910169100c9100c9100e9100e9100e9000e9050f9000f9000f9000f905000000000000000000000000000000000000000000000000000000000000
018000102281427814298143381426714227141d7141a7141f7141f710298142e814298142e814267142271429804275052c804265052780422505278041650529804275052c8042950527804225052780416505
0180000e109101091012910129101491014910169101691017910179100d9100d9100f9100f9100f9000f9050f9000f9000f9000f905000000000000000000000000000000000000000000000000000000000000
0180001023814288142a8143481427714237141e7141b71420714207102a8142f8142a8142f814277142371429804275052c804265052780422505278041650529804275052c8042950527804225052780416505
012000090b51512515195150b515125151b5150b515125151b5171b5051e5050f505065050f5050f505015051a5050a505115051a5051a5050a505115051a5050a505115051a5050a5051a5050a505115051a505
012000221ef3020f3023f3025f3027f302af302af3025f3025f3025f3025f3025f35237142371023712237151e7141e7101e7121e7151b7141b7101b7121b7152071423714237102371017f3023f3023f3023f25
0120040d2e5102e5122e5152e5050a51511515185150a515115151a5150a515115151a5171a5051d5050e505055050e5050e50500505000000000000000000000000000000000000000000000000000000000000
010500003f62039620306102424329610162431f6100f24300243035430224305543032430654304243075430524308543072430a543092330c5330a2330d5330b2230e5230c2230f5230d213105130e21311513
010500003f62039620306102424329610162431f6100f2431961009243136100524311610032430e610012430c61001240096100124006610012300461001230026100122002610012200061001210005143d521
0120172038b1438b1038b1038b153db143db103db123db1233b1433b1033b1033b1536b1436b1036b1036b1538f2436f2034f2033f2031f2036f2233f2523f2023f202af202af2231f2033f202af202af202af20
0103000022625001450d6250414500234004450024401425012340144402224024350224403425032340344504224044350424404234044250422404224044150421408405082040840508204084050820408405
010700003003030020300123001230714300203001230012300153002030012300143002030012307140000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400060074400755007640074500754007650070400705007040070500704007050020400405002040040500204004050020400405002040040500204004050020400405002040040500204004050020400405
018000000f9100f92513910139250f9100f925139101392510910109251491014925109101092514910149250f9100f92513910139250f9100f92513910139251091010925149101492510910109251491014925
0140001510910109100601512910129100801514910149100a01516910169100b0150b9100b910010150d9100d910030150f9100f910040150d9000d9000b9000b90014900149001290012900000000000000000
010200002e5142e5152e5142e5152e5242e5252e5242e5252e5342e5352e5342e5352e5442e5452e5442e5452e5542e5452e5442e5452e5442e5452e5442e5452e5342e5352e5342e5252e5242e5252e5142e515
0104000019433014213062024620186100c6100003106021010110703102021080110303109021040110a031050210b011060210d011070310e021080110f03109021100110a0311270100501061010050100000
01040000013303062030610080000b041070310302102011010110002100031000430c5241173516524187351d5242273524524297352e5243c735355243a7353060008001050010300101300306003060008001
0180000029e1429f252be142bf2529e1429f252be142bf252ae142af252ce142cf252ae142af252ce142cf2529e1429f252be142bf2529e1429f252be142bf252ae142af252ce142cf252ae142af252ce142cf25
010800000734501345000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
014000201df201ff301df201ff301df201ff301df201ff3024f2026f3024f2024f3524f2026f3024f2024f351ef2020f301ef2020f301ef2020f301ef2020f3025f2027f3025f2025f3025f2027f3025f2025f30
0180000023f1018a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a153000518a15
0102000019045000001e0450000023045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
014000200f9100f925030151391013925070150f9100f925030151391013925070150f9100f9100f9250301510910109250401514910149250801510910109250401514910149250801510910109101092504015
00020000016100d6111c61131611146110c61108611056110261501601016050c600116001a600006000060000600006000060000600006000060000600006000000000000000000000000000000000000000000
01010000006000c7000c600137001860018700306001f7003c6002b70518600187000c60013700006000c70000600006000060000600006000060000600006000060000600006000060000600006000060000600
__music__
00 0d 0e 0f 44
01 0d 0e 10 44
02 12 13 10 44
00 18 15 14 44
01 1a 15 16 44
02 08 09 0a 44
01 1d 1b 1e 44
02 20 1b 1e 44
00 20 0c 1e 44
01 21 0c 11 44
02 21 19 11 44
00 21 11 0b 22
01 21 23 0b 22
00 21 23 0b 22
02 24 25 0b 22
00 26 27 0b 22
00 26 27 0b 22
00 26 27 1c 22
00 26 27 1c 22
02 21 11 2c 22
01 28 29 2b 22
00 33 38 3a 22
00 34 29 2f 22
00 3d 38 3a 22
00 28 29 2f 22
00 33 38 3a 22
00 34 29 2b 22
02 3d 38 3a 22
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 21 11 0b 22
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
