pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the lair 
-- by @krajzeg / @gruber_music
function bj(fv,gx)fv=fv or {}
for k,v in pairs(gx or {})do
fv[k]=v
end
return fv
end
function ho(oq,to,sg)sg/=ij(oq,to)
return (to.x-oq.x)*sg,(to.y-oq.y)*sg
end
function ev(br,e)for i,a in pairs(br or {})do
if (a==e)return i
end
end
function sk(m_,fn)for i=1,#m_ do
fn(sub(m_,i,i),i)end
end
function bs(m_)local lh,s={},1
sk(m_,function(c,i)if c=="\n" then
add(lh,ob(sub(m_,s,i)))s=i
end
end)
return lh
end
function ob(m_,gx)local lh,s,n={},1,1
sk(m_,function(c,i)local sc,bi=sub(m_,s,s),i+1
if c=="=" then
n=sub(m_,s,i-1)s=bi
elseif c=="," then
lh[n]=sc=='"'and sub(m_,s+1,i-2)or sc!="f"and sub(m_,s,i-1)+0
s=bi
if (type(n)=="number")n+=1
elseif sc!='"'and c==" " or c=="\n" then
s=bi
end
end)
return bj(gx,lh)end
function ej(sr,nj,q)
return nj+
((sr or nj)-nj)*
(q or 0.857)end
function mc(p)
return p and rnd()<p
end
function im(f_,fz)
return rnd(fz-f_)+f_
end
function im0(d)
return im(-d,d)end
function nl(md)
return md[flr(rnd(#md)+1)]
end
function pq(gx)
return bj({x=im(1,126),y=im(81,100)},gx)end
function g_(e,dx,dy,gx)
return bj({x=e.x+(dx or 0),y=e.y+(dy or 0)},gx)end
el=bs([[
x=1,y=0,c=0,
x=1,y=1,c=0,
x=0,y=1,c=0,
x=-1,y=1,c=0,
x=-1,y=0,c=0,
x=0,y=-1,c=0,
x=0,y=0,c=1,
]])function gm(t,x,y,c,pn)local sx=x-#(t.."")*4*(pn or 0)for sd in all(el)do
print(t,sx+sd.x,y+sd.y,c*sd.c)end
end
function sq(n,hy,fz,f_)
return mid(flr(n/hy),fz or 32767,f_ or 0)end
function hr(fj,om)
return t%fj<(om or 0.5)end
function hg(m)
return abs(m.x-64)<60
end
function jq(no,sv)local pd=0x5f80+no*4
poke(pd,peek(pd)+1)poke(pd+1,sv/256)poke(pd+2,sv)end
qz=ob([[
0,20,20,2,4,3,8,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
20,20,20,2,2,1,1,
0,0,0,0,0,0,0,0,0,
20,20,0,12,11,8,8,0,5,10,33,1,2,11,6,1,9,9,7,12,
]])function kl(n)
if (o_)return
local dv,dl2,dl3=
qz[n+2],qz[stat(18)+2],qz[stat(19)+2]
local ch=dl2<dl3 and 2 or 3
if (dv>=min(dl2,dl3))sfx(n,ch)
end
function ma(kq)ge[kq]=ge[kq]or {}
return ge[kq]
end
function hs(kq,mn,op)while kq do
op(ma(kq),mn)kq=rl[kq].lm
end
end
function so(kq,mn)local le=ld..""
ld+=1
bj(mn,{jz=le,re=kq,t=0
})bc[le]=mn
hs(kq,mn,add)local dj=rl[kq]
while dj do
setmetatable(mn,{__index=dj})mn,dj=
dj,rl[dj.lm]
end
return le
end
function pj()
t+=0.5
for nm,mn in pairs(bc)do
local oc=
mn[mn.pf or "jr"]
if (mn.il or 0)==0 then
if oc(mn,mn.t)then
bc[nm]=nil
hs(mn.re,mn,del)end
mn.t+=0.5
else
mn.il-=0.5
end
end
if qw then
ed()qw()qw=nil
end
end
function kb(lk,...)if lk then
lp(...)end
end
function lp(e,sn,ba)
if (e.pf==sn)return
if e.pf=="jp" then
sfx(-1,3)end
bj(e,ob([[
t=0,dn=f,gb=f,
gj=f,charging=f,
]]))e.pf=sn
if e.ih and sn=="dt" then
e.ih.ja=nil
end
if e.ku then
e.ku.ja=nil
end
if (ba)kl(ba)
end
function cw(su,ls,pt,gx,le)le=(le or ld)..""c_[le]=
bj(gx,{jz=le,nj=su,jd=ls,pt=pt,t=0
})
ld+=1
end
function rq(kq,gx,...)local id=so(kq,gx)cw(id,...)
return bc[id]
end
function qm()local gn={}
for nm,vw in pairs(c_)do
local nj=bc[vw.nj]
if nj then
local qk=vw.pt or flr(nj.y)or o
gn[qk]=
gn[qk]or {}
add(gn[qk],vw)else
c_[nm]=nil
end
end
for qk=0,129 do
for v in all(gn[qk])do
tb()if v.jd(bc[v.nj],v)then
c_[v.jz]=nil
end
v.t+=1
end
end
end
function fp(e,hb,kq,hx)add(hu,{mn=e,it=of[hb],re=kq,hx=hx or kq})end
function sl()for c in all(hu)do
local mn,it=
c.mn,hq(c.it,c.mn)for nj in all(ma(c.re))do
local jf=nj:jf()if jf and
i_(it,hq(jf,nj))then
local cb=mn["hit_"..c.hx]
if (cb)cb(mn,nj)
end
end
end
hu={}
end
function hq(b,e)local f=e.qn<0
return {x1=e.x+(f and -b.x2 or b.x1),y1=e.y+b.y1,x2=e.x+(f and -b.x1 or b.x2),y2=e.y+b.y2
}
end
function i_(b1,b2)
return
b1.x2>=b2.x1 and
b2.x2>=b1.x1 and
b1.y2>=b2.y1 and
b2.y2>=b1.y1
end
function ip(ny,nn,kq)
if ((nn or 0)<1 or not ny)return
local p=ny[flr(min(nn,#ny))]
for i=0,15 do
local ig=p[(pv[i]or i)+1]
pal(i,ig,kq or 0)pv[i]=ig
end
end
function tb()pal()palt(0,false)palt(3,true)pv={}
end
lg=bs([[
0,0,0,3,2,5,5,6,8,9,9,11,12,1,8,9,
0,0,0,1,2,1,5,5,2,4,4,3,13,1,4,4,
0,0,0,0,0,0,1,1,1,2,2,1,1,0,2,2,
0,0,0,0,0,0,1,5,0,0,0,0,0,0,0,0,
]])function pm(ku,n,fa)ku.ps,ku.ji={},fa
for i=1,flr(n)do
add(ku.ps,fa())end
return rq("ku",ku,kv)end
function iy(ku)local ps=ku.ps
for i=1,#ps do
local p=ps[i]
if p then
bu(p,ku)
p.es-=ku.cs
if (not ku.bp)l_(p)
if p.es<0 then
del(ps,p)end
ku.y=p.y
end
end
if mc(ku.ja)then
add(ps,ku.ji()or nil)end
return #ps==0 and not ku.ja
end
function kv(ku)for i=1,#ku.ps do
local p=ku.ps[i]
local gb,rx,ry=
sq(1-p.es,0.25,3),p.x,p.y+p.z
local oe=gb>0 and
lg[gb][p.oe+1]or
p.oe
if p.ko then
gm(p.ko,rx,ry,oe)elseif p.je then
local r=min(1,1-p.es)*p.je
is(rx,ry,r,r,2,oe)else
pset(rx,ry,oe)end
end
end
function eh(mn,ku)camera()cls()fs(mn.re,16-mn.sm*4,31,2,mn.pf,mn.qn<0)for y=31,0,-1 do
for x=y%2,31,2 do
local ph=pget(x,y)if ph!=0 then
add(ku.ps,g_(mn,x-16+rnd(),0,{z=mn.z+y-32,vx=mn.vx*im(0.5,0.75),vy=mn.vy,vz=-0.5,es=1,oe=ph
}
))end
end
end
end
function lr(e,dx,dy,dz,r,oe)local gx=ob([[
dd=0.5,mm=1,
ic=0,rv=1,
ry=0,
]],{rx=r,rz=r,oe=oe,hi=-r/8,rd=-r/16
})
return pm(ob([[
ja=1,cs=0.07,
ml=1,jw=0,
]]),0,function()
return fi(g_(e,e.qn*dx,dy),dz,gx
)()end
)end
function fi(px,z,p)
return function()local a,d,s=
im(p.ic,p.rv),im(p.dd,p.mm),im(p.hi,p.rd)local va=p.io or a
return g_(px,p.rx*d*sin(a),p.ry*d*cos(a),{z=(px.z or 0)+z+p.rz*d*cos(a),vx=s*sin(va),vy=0,vz=s*cos(va),es=1,oe=p.oe
})end
end
function eq(dm,oe,ol,sy,iu,en,dh)local sx,i=62-#dm*2,0
local ku=pm(ob([[
jw=0.1,ml=1,
ir=0.4,
bp=1,
ja=1,
]],{cs=ol==0
and 0 or 0.04
}))ku.ji=function()if i>=#dm then
ku.ja=nil
elseif hr(iu or 2)then
i+=1
return ob([[
vx=0,vy=0,vz=0,
]],{x=sx+i*4,y=sy or 30,z=im(-10,-8)*(en or 1),es=1+(ol or 30)*0.07-(dh or 0)*i,oe=oe,ko=sub(dm,i,i)})end
end
end
kf={}
function lo()ct,gq,pl=
{},{},{}
for b=0,5 do
if btn(b)then
ct[b]=true
if not kf[b]then
gq[b]=true
if ne==b and
t-ha<9 then
pl[b]=true
else
ne,ha=b,t
end
end
end
end
kf=ct
end
kh,qd=2,bs([[
le="friendly",po=0.1,jn=1.2,mw=0.4,mini1="wc",mini2="t",kg=150,p_=10,da=15,fc=1,nw=5.5,
le="normal",po=0.1,jn=1.5,mw=0.5,mini1="t",mini2="e",kg=150,p_=8,da=12,fc=1,nw=7,
le="hard",po=1,jn=1.5,mw=0.5,mini1="tc",mini2="ecc",kg=140,p_=8,da=10,fc=1.3,nw=8,
le="nightmare",po=1.3,jn=2.5,mw=0.6,mini1="tt",mini2="ewc",kg=125,p_=6,da=10,fc=1.5,nw=8,oz=3,
le="hell!",po=2.5,jn=3.3,mw=0.4,mini1="ttw",mini2="eeww",kg=110,p_=5,da=10,fc=1.7,nw=10,oz=3,
]])function bl()rq("lq",{},sj)music(0)for i=1,5 do
jq(i,dget(i))end
end
function cz(nz)kb(gq[4],nz,"mi",55
)end
function qj(nz)for i=0,1 do
if gq[i]then
kh=mid(kh+i*2-1,1,5)kl(55)end
end
if gq[4]then
qw=mf
kl(55)end
end
function sj(nz,v)nz.dy=ej(nz.dy,nz.pf and 0.5 or -8)camera(0,nz.dy)rectfill(-127,58,127,58,1)rw(63,35,25)ip(lg,4)spr(140,48,32,4,4)print("the",58,15,0)spr(114,53,21,3,1)tb()jl(64,59,48)if not nz.pf then
if nz.t>60
and hr(60,30)then
gm("press [z]to start",28,85,13)end
print([[
gfx,code,design        @krajzeg
music,sfx         @gruber_music
]],2,102,1)else
camera(0,nz.dy*5)local mg,jc=
dget(kh),t/5%3
rectfill(64,87,64,mg>0 and 123 or 108,1)print(" difficulty",17,92,13)print(qd[kh].le,69,100,1)if mg>0 then
print("       best",17,113,13)spr(57+mg,69,112)end
spr(12,-jc,92)spr(13,120+jc,92)for i=1,5 do
tb()local d=0
if i<=kh then
d=1
ip(sz,qd[i].oz)else
ip(lg,3)end
spr(1,60+i*8,90.5+cos(t/20+i*0.4)*d)end
end
end
pb=bs([[
x=0,y=0,r=4,c=0,
x=-1,y=0,r=0,c=15,
x=1,y=0,r=0,c=15,
x=0,y=-1,r=-1,c=7,
]])function rw(cx,cy,r)for p in all(pb)do
circfill(cx+p.x,cy+p.y,r+p.r,p.c)end
end
hn=bs([[
w=1,oe=1,
w=0.6,oe=5,
w=0.35,oe=13,
w=0.2,oe=15,
]])function jl(sx,sy,fq)for y=1,17 do
local mu=peek(y+0x29ee)%26/26
local w=sin(t*(0.008+0.0037*mu)+mu
)*(1-y*0.055)*fq
for s in all(hn)do
rectfill(sx-w*s.w,sy+y,sx+w*s.w,sy+y,s.oe)end
end
end
function og(p)bn(p,0.5,true)td(p)p.charge=0
kb(gq[4],p,"jp")km(p)end
function gz(p,tm)td(p)if ev(gq,true)then
lp(p,"gf")og(p)end
kb(sa(p),p,"gf")end
function cp(p,tm)p.qn=1
ru(p,1,0)if tm==15 then
music(32)eq(fr.qy
and "quest complete"or "stage complete",9,0)dset(63,1)end
end
function kn(p,tm)bn(p,0.25)td(p)if tm==5 then
p.ku=
lr(p,-7,1,-16,8,12)sfx(63,3)end
if tm>=5 then
p.gb={hf,abs(sin(t/10)*(p.charge/10.6))}
if (not fr.hl)p.fk+=0.5
if p.charge<40 then
p.charge+=0.5
else
p.ku.ja=nil
end
end
if not ct[4]then
p.vx=p.qn*(0.6+p.charge*0.1)lp(p,"hc",58)end
end
function jj(p,tm)bn(p,0.25)td(p)kb(not ct[5],p,"gf")kb(gq[4],p,"jp")fp(p,9,"proj")end
function cg(p,tm)td(p)km(p)if sa(p)and tm>=3 then
lp(p,"gf")else
fp(p,5,"monster")end
end
function gu(p,tm)qo(p,tm)km(p)end
function km(p)if gq[5]then
lp(p,"de")end
for b=1,4 do
if pl[b-1]then
p.vx,p.vy,p.pu=
tf[b].x*1.5,tf[b].y*1.5,t
lp(p,"oo",58)end
end
end
function hz(p,pr)if pr.vx!=0 and pr.z>-16 then
pr.vx*=-0.7
kl(59)end
end
function dk(p,m)local s_=(p.s_+p.jm)*(1+p.charge/30)cw(m.jz,lb,129,{qn=true},"lasthit")if ef(p,m,s_)then
nh(p,1)end
end
function nh(p,d)
p.jm+=d
jq(6,p.jm)p.gk,p.fk=
max(p.gk,p.jm),t
if p.jm>0 then
cw(p.jz,ga,129,{pz=-70},"combo")end
end
function dp(p,m,s_)if p.pf=="de"and sgn(m.x-p.x)==p.qn
and not m.ix then
p.vx,p.vy=ho(m,p,max(abs(m.bf),0.8))kl(54)if m.monster then
m.vx,m.pu,p.pu=
-m.qn*0.75,t,t
nh(p,0)lp(m,"lx")lp(p,"gf")end
return true
end
p.oh+=s_
end
function ef(e,nj,s_)
s_-=nj.te
e.dn=e.dn or {}
if ev(e.dn,nj)then
return
end
add(e.dn,nj)local ii,fe=
#e.dn+2.5,nj==eg
if nj.ec
and nj:ec(e,s_)then
return
end
if fe then
nj.rj=t+10
end
nj.pa+=s_
kb(not (nj.ez or e.ix),nj,"qi")nj.b_=t
kl(fe
and 5 or flr(im(60,62)))if not e.ix then
nj.vx,nj.vy=ho(e,nj,min(s_/nj.d_,3))e.il,nj.il=ii,ii
end
gr=fe and 4 or 2
return true
end
function td(p)if fr.hl then
local gg=min(p.x-56,1.5)if gg>0
and p.dx>0 then
p.mo=0
fr.x-=gg*fr.rk
p.x-=gg
if (p.x>56)p.x-=1
else
p.mo+=0.5
end
else
p.ck+=0.16667
end
if t-p.fk>=45 then
p.jm=0
end
kk(p)end
tf=bs([[
x=-1.5,y=0,
x=1.5,y=0,
x=0,y=-1,
x=0,y=1,
]])function bn(p,sw,qq)local dx,dy=0,0
for i,d in pairs(tf)do
if ct[i-1]then
dx+=d.x*sw
dy+=d.y*sw
end
end
if dx!=0 and qq then
p.qn=sgn(dx)end
ru(p,dx,dy)if p.gj and
hr(12)and
fr.qy and
fr.x>-256 then
kl(59)end
end
function ds(m,tm)kb(mc(0.005*tm)or
hg(m),m,"sf",56)end
function gy(m)local dx,dy=ho(m,eg,m.sw)m.mx,m.my=
ej(m.mx,dx),ej(m.my,dy)m.qn=sgn(m.mx)ru(m,m.mx,m.my)kk(m)if ij(m,eg)<16 then
m.vx,m.vy=
m.mx*2.5,m.my*2.5
lp(m,"nx",56)end
end
function ca(m,tm)kk(m)fp(m,2,"player")kb(tm>im(35,65),m,"sf")end
function cn()while not bc[ei]or
bc[ei].pf!="gf" do
ei=nl(ma("monster")).jz
end
end
function fh(m)if m.jz==ei then
m.nj=g_(eg,-m.qn*12)else
local d,a=
ij(m,eg)rnd()m.nj=g_(eg,sin(a)*d*0.33,cos(a)*d*0.25
)end
l_(m.nj)end
function iq(m)m.nj=pq({x=(m.qn>0 and 30 or 97)+im0(25)}
)end
function on(m,tm)gc(m)if m.od then
m:du()end
if mc(0.0015*tm)and hg(m)then
m.rg=g_(eg)lp(m,"ln")end
end
function ni(m,p,s,mq,jo,jx)local pw=mid(sqrt(ij(m,p))*
im(mq,jo)*0.5,0.7,jx or 1000
)s.vx,s.vy=ho(m,p,pw)
if (abs(s.vx)<0.07)s.vx=0.07*m.qn
return pw
end
function lt(m,tm)if abs(tm-16)<=1 then
for i=1,m.bd do
local dy=im0(m.fm*0.75)local sp=rq(m.cq,g_(m,m.qn*4+im0(m.fm),dy,{z=-im(8,12),c=dy>0
and ob([[fg=3,bg=1,]])
or ob([[fg=11,bg=3,]])
}
),
m.cq=="bh"
and gt
or fo
)
sp.vz=m.nk*ni(
m,m.rg,sp,
m.mz*0.997,
m.mz*1.003,
m.cr
)
end
end
if tm==16 then
kl(m.ce)
end
kb(tm==32,
m,"gf")
end
function gw(s,tm)
return
mc(
#ma("monster")==0
and 0.5
or tm*0.0004
)
end
function gt(s)
local x,y,c=s.x,s.y,s.c
if s.z<0 then
pset(x,y,0)
pset(x,y+s.z,c.fg)
else
rectfill(x-2,y,
x+2,y+1,c.bg)
rectfill(x-1,y,
x+1,y,c.fg)
end
end
function ey(m,tm)
gc(m)
if ij(m,eg)<30 then
m.df+=0.5
kb(
mc(m.df/130),
m,"ln",50)
else
m.df=0
kb(
mc(tm/5000)
and hg(m),
m,"j_",49)
end
end
function lc(m,tm)
iz(m)
if tm==20 then
m.vx-=m.qn*2.5
for pw=0.15,0.31,0.15 do
local db=rq("lz",
g_(m,0,1,ob([[
z=-16,vz=-0.5,es=100,
]])),fo)ni(m,eg,db,0.45+pw,0.6+pw)end
lp(m,"gf")end
end
function mb(m,tm)iz(m)bj(m,g_(m.po,im0(tm/9),im0(tm/9)))if tm>20 then
kx(m,ob([[
om=17,s_=10,oe=12,
kw=9,w=18,
]]))lp(m,"gf")end
kk(m)end
function iz(m)if m.t==0.5 then
m.ku,m.po=
lr(m,0,2,-16,15,7),g_(m)end
end
function jb(p,tm)bu(p,p)l_(p)if p.z>=0 then
if p:ra(tm)then
lp(p,"dt")
return true
end
fp(p,p.qa,"player")end
end
function fo(p)
if (p.es<13 and hr(2,1))return
is(p.x,p.y,4,1.2,4,p.ll)spr(p.dq,p.x-4,p.y+p.z+p.dy)end
function fu(d)kx(d,d.lu)
return true
end
function ci(fb,tm)if not fb.ih then
fb.ih=pm(ob([[
jw=0,ml=1,
ja=1,cs=0.05,
bp=1,
]]),0,fi(fb,-1,ob([[
rx=3,ry=0,rz=3,
oe=10,hi=0,rd=0.01,
dd=0.1,mm=1,
ic=0,rv=1,
]])))end
if tm>3 then
fp(fb,14,"player")end
return jb(fb,tm)end
function er(p)
p.es-=1
return p.es<=0
end
function cm(p)if p.re=="qf" then
eg.s_+=1
else
eg.pa=max(eg.pa-8,0)end
p.es,eg.pu=0,t
eq(p.hh,p.oe,15)kl(3)kx(p,ob([[
om=0,s_=0,oe=7,
kw=6,w=9,
]]))pm(ob([[
cs=0.025,ml=0.96,
jw=0,bp=1,
]]),16,fi(p,0,ob([[
rx=7,ry=4,rz=0,
hi=1,rd=2,
dd=0.999,mm=1.0,
ic=0,rv=1,
io=0.5,
]],p)))end
function kx(c,gx)local om=gx.om
rq("em",bj(g_(c),gx),e_,1
).r=1
pm(ob([[
ml=1,jw=0.2,cs=0.07,
]]),om,function()local ew=rnd()
return g_(c,0,0,ob([[
z=0,es=1,
]],{vx=sin(ew)*0.1*om,vy=cos(ew)*0.1*om,vz=-im(0,5),oe=gx.oe
}))end
)gr=om/4
end
function qv(b,tm)if tm==0 and b.om>0 then
kl(62)end
b.r+=b.kw
b.kw*=0.707
if b.kw>0.2
and eg:jf()and ij({x=eg.x,y=eg.y*3},{x=b.x,y=b.y*3}
)<b.r
then
b:hit_player(eg)end
b.w-=0.5
return b.w<=0
end
function e_(b)ip(lg,min(b.t/4,2))clip(0,80,127,22)is(b.x,b.y,b.r,b.r*0.33,b.w,b.oe)clip()end
function is(x,y,rx,ry,w,oe)local dx=rx
for dy=0,ry do
while
dx*dx/rx/rx+dy*dy/ry/ry>1 do
dx-=1
end
for mx=-1,1,2 do
for my=-1,1,2 do
local ly=y+my*dy
rectfill(x+mx*dx,ly,x+mx*(dx-min(dx,w)),ly,oe)end
end
end
end
function nr(m)gc(m)if m.jz==ei then
m:du()end
end
function gc(m)cn()m.od=
ns(m,m.nj)if m.od and mc(0.05)or not m.nj then
m:du()end
m.qn=sgn(eg.x-m.x)fp(m,m.nq,"player","radar")kk(m)end
function oi(m,tm)if tm==1 then
m.ku=pm(ob([[
jw=0,ml=1,cs=0.1,
ja=1,
]]),0,function()
return fi(g_(m,0,1),-m.en*8-2,ob([[
rx=4,ry=0.1,rz=2,
oe=10,
hi=0.1,rd=0.2,
dd=0.99,mm=1,
ic=0,rv=1,
io=0.25,
]]))()end)end
kk(m)kb(tm>m.rn+10,m,"gf")end
function hd(m,tm)m.gj=nil
kk(m)if tm>=m.mj then
m.vx,m.vy=m.ax,m.ay
if m.kc then
m:kc()end
lp(m,"hc",m.li)end
end
function r_(m,tm)kk(m)if tm<m.mh then
fp(m,m.cj,"player")end
kb(tm>m.rn,m,"gf")end
function si(m,p)m.ax,m.ay=ho(m,p,m.bf)kb(m.pf!="qi",m,"ln")end
function ns(m,t)if t then
if ij(m,t)<2 then
m.gj=nil
return true
end
local dx,dy=ho(m,t,m.sw)ru(m,dx,dy*0.666)end
end
function cc(s)
s.x+=s.qn*8
kx(g_(s,s.qn*20),ob([[
om=10,s_=5,oe=8,
kw=4,w=9,
]]))end
function hm(w,tm)w.ih=w.ih or pm(ob([[
jw=0,ml=1,
ja=0.6,cs=0.03,
bp=1,
]]),0,fi(w,-10,ob([[
rx=6,ry=2,rz=8,
oe=12,hi=0,rd=0.01,
dd=0.5,mm=1,
ic=0,rv=1,
]])))if mc(tm*0.0003)then
w.rs=function()
return g_(eg,ho(w,eg,25))end
lp(w,"ok",32)else
nr(w,tm)end
end
function ie(b,tm)nt={lg,sq(150-tm,5,2)}
if tm==0 then
boss=b
bj(b,ob([[
x=64,y=79,z=-167.5,
]]))music(-1)ef(b,eg,15)eg.pa,eg.oh,eg.bv=
0,0,2
pm(ob([[
jw=0,ml=1,cs=0.04,
ja=1,bp=1
]]),0,function()if not b.kt then
return fi(b,b.z-16,ob([[
rx=19,ry=0,rz=19,
oe=15,
hi=0,rd=0,
dd=1,mm=1,
ic=0.125,rv=0.875,
]]))()end
end
)end
if tm==40 then
music(23,0,3)eq("this will be far enough.",14,80,110,2,0.2,0.12)end
if hr(rc.p_)and abs(tm-150)<=50 then
qx()end
if tm==230 then
lp(b,"ox")b.t=90
end
if tm>=65 then
b.z+=1.4-b.t/163
end
end
function qu(b,tm)if tm==0.5 then
music(-1)b.z,b.qr=
0,pm(ob([[
jw=0,ml=0.95,cs=0.04,
bp=1,
ja=0,
]]))local c=10
for _,m in pairs(bc)do
if m.monster then
m.il,m.gj,m.pa=c,false,1000
c+=10
end
end
end
b.x,b.y=
im(62,66),im(79,82)if tm<=120 then
add(b.qr.ps,ob([[
vx=0,vy=0,vz=-0.8,
es=1,oe=12,
]],g_(b,im0(15),4,{z=-im(2,29),je=im(2,6)})))
if (hr(6))kl(62)
end
if tm==120 then
ft(b,0.5)b.dg=false
end
return tm==210
end
function ep(b,tm)if b.z<-5 then
b.z=ej(b.z,0,0.967)else
k_(b)end
if tm>=rc.kg and
#ma("monster")<5 then
lp(b,"nd")end
iw(b)end
function iw(b)if b.kt then
nt={hf,9-t+b.kt}
kb(t-b.kt>150,b,"jh")end
kk(b)end
function eu(b,tm)b.z=ej(b.z,-40,0.967)if hr(rc.p_)then
qx()end
if tm==30 then
b.kt=nil
end
kb(tm==60,b,"ox")end
function dw(b,tm)k_(b)if tm==0.5 then
b.ku=lr(b,-13,2,-26,25,15)kl(48)end
if tm==20 then
sk(nl(qp[kh]),bt
)lp(b,"ox")end
iw(b)end
function qx()rq("lz",pq(ob([[
z=-180,jw=0.125,es=100,
]])),fo
)end
function bt(bo)local px=pq({x=(eg.x+im(56,72))%128
})bj(rq(bk[bo],px,rt),ob([[
t=15,pf="ok",
]]))pm(ob([[
jw=0,cs=0.025,
ml=0.96,
]]),16,fi(px,0,ob([[
rx=9,ry=5,rz=0,
oe=15,
hi=1.0,rd=2.0,
dd=0.999,mm=1.0,
ic=0,rv=1,
io=0.5,
]])))end
function rr(b,p,s_)if b.kt then
b.kt-=s_*2
else
kl(53)eg.vx,eg.vy=
ho(b,eg,2)if #ma("crst")==0 then
bt("y")end
cw(b.jz,kr,85)
return true
end
end
rh=bs([[
dx=-20,dy=-31,fx=f,fy=f,
dx=12,dy=-31,fx=1,fy=f,
dx=-20,dy=-15,fx=f,fy=1,
dx=12,dy=-15,fx=1,fy=1,
]])function kr(b,v)local p=v.t/2-3
ip(p<0 and
hf or lg,abs(p))for s in all(rh)do
spr(170,b.x+s.dx,b.y+b.z+s.dy,1,2,s.fx,s.fy)end
return v.t>=12
end
function k_(c)c.z=sin(t/60)*2.5-2.5
end
function ky(c,tm)kb(mc(tm/8000)or
t-c.b_<10,c,"ok")kk(c)end
function bq(c,e,s_)if c.pa+s_>=c.qg then
boss.kt=t
kl(57)end
end
function ou(c,tm)if tm<7 or tm>14 then
c.gb={hf,7-tm%14}
else
c.gb={lg,tm-7}
end
if tm==14 then
bj(c,(c.rs
or pq)())end
kb(tm==21,c,"gf")kk(c)end
function he(mn)
mn.x+=mn.vx
mn.y+=mn.vy
mn.vx*=mn.ml
mn.vy*=mn.ml
if abs(mn.vx)+abs(mn.vy)<0.5 then
mn.vx,mn.vy=0,0
end
end
function sa(mn)
return mn.vx==0 and mn.vy==0
end
function l_(v)if not v.monster then
v.x=mid(v.x,0,127)end
v.y=mid(v.y,80,101)end
function bu(p,nv)local ml,ir=
nv.ml,nv.ir
p.x+=p.vx
p.y+=p.vy
p.z+=p.vz
p.vx*=ml
p.vy*=ml
p.vz=p.vz*ml+nv.jw
if ir and p.z>0 then
p.z*=-ir
p.vz*=-ir
p.vx*=ir
if abs(p.vz)<0.5 then
p.vx,p.vy,p.vz,p.z=0,0,0,0
end
end
end
function qo(c,tm)kb(tm>c.ht,c,"gf")kk(c)end
function ft(c,tm)c.nb=true
if tm==0.5 then
eh(c,pm(ob([[
jw=0.1,ir=0.4,
ml=0.98,cs=0.0125,
]])))if c.ro then
eg.hj+=im(1,1.25)
if eg.hj>=rc.nw then
eg.hj-=rc.nw
local p,a=rq(mc(eg.pa/24)and "sb"or "qf",ob([[
z=-10,vz=-1.5,
es=75,
]],g_(c)),fo
),rnd()p.vx,p.vy=sin(a),cos(a)*0.5
end
end
end
return tm>45 and c!=eg
end
function ru(c,dx,dy)c.dx,c.gj=
dx,abs(dx)+abs(dy)>0.01
and (c.gj or t)
c.x+=dx
c.y+=dy
end
function kk(c)he(c)
if (c!=boss)l_(c)
if (c.ow)k_(c)
kb(c.pa>=c.qg,c,"dt")end
function oa(mv,nj)if mv.s_>0 then
ef(mv,nj,mv.s_)end
end
function gd(c)
return c.z>=-5
and t>=c.rj
and not ev({"oo","qi","dt","ok"},c.pf
)and of[c.pf=="de"and 15
or c.sm
]
end
function ij(c1,c2)local dx,dy=
c1.x-c2.x,c1.y-c2.y
return sqrt(dx*dx+dy*dy)end
function dc(lv)if lv.qh then
ip(lv.qh,t/2%#lv.qh+1)end
gl(lv.x,lv.fl,lv.cl)if lv.bg then
lv.bg(lv.x)end
gh(lv.lj,lv.x)local cv=eg.mo%45
if eg.mo>=90
and cv<23 then
ip(hf,4-cv)spr(7,115,42)gm("go!",114,51,9)
if (cv==0)kl(55)
end
end
function gh(lj,ov)for l in all(lj)do
local os=-ov*l[1]
map(l[3]+(flr(os/8)%112),l[4],-flr(os%8),l[2],17,l[5])end
end
function pk(mu)rw(102,38,17)rectfill(0,50,127,50,1)rectfill(0,51,127,60,0)jl(102,51,38)if fr.x>-200 and
dget(63)==0 then
gm([[
stab:          [z]
shield:   hold [x]
charge:   hold [z]
dash:     2]].."\88 arrow",55,104,13)end
end
function gl(ov,fl,cl)ov%=16
ki(80,24,fl,1,ov)rect(0,105,128,105,1)if cl then
ki(37,6,cl,-1,ov)end
end
function ki(y,h,qs,pp,ov)for oy=0,h-1 do
local ka=1+oy/h
local dx=16*ka
for sx=64-ka*(80-ov),128,dx do
sspr(0,qs+oy,16,1,sx,y+pp*oy,dx+1,1
)end
end
end
na=bs([[
1,2,1,3,
1,2,
]])lf={qe={false},gi={}
}
function jy(gi,qe,gx)
return bj({qe=bs(qe or ""),gi=bs(gi)},gx)end
et={player={po=2,jp=jy([[
192,-1,-18,1,2,
]],[[
7,-15,9,16,
0,-2,15,3,
]]),de=jy([[
4,0,-15,2,2,
]],[[
0,-2,11,3,
0,0,16,1,
]],{jk=2
}),oo=jy([[
192,-1,-18,1,2,
]],[[
7,-15,9,16,
0,-2,15,3,
]],{jg=2,}),hc=jy([[
193,0,-15,3,2,
]])},boss=ob([[
po=140,
rb=1,
gf="nd",
jh="nd",
]],{ox=lf,nd=jy([[
139,2,-31,1,3,
]],[[
10,-31,32,32,
0,-7,32,8,
]]),dt={gi=bs([[
138,11,-31,1,2,
]]),qe={false}
}
}),crst=ob([[
po=234,rb=1,
]]),skel={po=206,hc=jy([[
224,4,-15,2,2,
146,15,-9,1,1,
]],[[
0,-15,4,16,
]]),ln=jy([[
226,0,-15,2,2,
]])},capt={po=206,mp=bs([[
0,1,1,3,5,4,9,7,12,6,10,11,12,13,14,15,
]]),lw=jy([[
6,4,-18,1,1,
]],[[
0,-15,16,16,
]]),hc=jy([[
224,4,-15,2,2,
146,15,-9,1,1,
6,4,-18,1,1,
]],[[
0,-15,4,16,
]]),ln=jy([[
226,0,-15,2,2,
162,4,-18,1,1,
]]),},wrth={po=8,hc=jy([[
10,2,-15,2,2,
]]),ln=jy([[
42,0,-15,2,1,
]],[[
0,-7,16,8,
]])},ston={po=132,hc=jy([[
36,0,-15,4,2,
]]),ln=jy([[
212,0,-23,3,3,
]])},eldr=ob([[
po=151,
j_="ln",
]],{ln=jy([[
135,0,-15,3,1,
]],[[
0,-23,24,8,
0,-7,24,8,
]])}),blch={po=203,ln=jy([[
202,0,-15,1,2,
]])},frsp={po=203,mp=bs([[
0,1,2,3,2,5,6,7,8,8,14,11,12,13,14,15,
]]),ln=jy([[
202,0,-15,1,2,
]])},felm={po=204,nx=jy([[
252,0,-7,2,1,
]])}
}
of=bs([[
x1=-4,y1=-2,x2=3,y2=2,
x1=-6,y1=-2,x2=5,y2=2,
x1=-10,y1=-2,x2=9,y2=2,
x1=-14,y1=-2,x2=13,y2=2,
x1=6,y1=-3,x2=14,y2=3,
x1=0,y1=0,x2=0,y2=0,
x1=8,y1=-4,x2=18,y2=4,
x1=7,y1=-2,x2=13,y2=2,
x1=4,y1=-4,x2=9,y2=4,
x1=10,y1=-3,x2=30,y2=3,
x1=0,y1=-2,x2=9,y2=2,
x1=1,y1=-3,x2=20,y2=3,
x1=8,y1=-4,x2=22,y2=4,
x1=-1,y1=-1,x2=1,y2=1,
x1=-6,y1=-3,x2=6,y2=3,
]])jt=bs([[
0,1,2,kz=0,cu=7,ff=1,
1,2,3,kz=1,cu=7,ff=1,
1,3,5,kz=1,cu=15,ff=2,
1,1,1,kz=1,cu=23,ff=3,
0,2,kz=0,cu=15,ff=2,
2,3,4,kz=2,cu=7,ff=1,
]])function fs(kq,x,y,jg,bz,qt,gb)local fd,re=
et[kq],rl[kq]
local jy=fd[bz]
or fd.lw or lf
while type(jy)=="string" do
jy=fd[jy]
end
local sm,en=
re.sm,re.en
local la=jt[re.gv or en
]
if (fd.rb)jg=nil
jg=jy.jg
or jg
or jy.jk
or 1
ip(fd.mp,1)if gb then
ip(gb[1],gb[2])end
for iv in all(jy.qe)do
if iv then
clip(qt
and x+sm*8-iv[1]-iv[3]
or x+iv[1],y+iv[2],iv[3],iv[4]
)end
spr(fd.po,x,y-en*8+1,sm,la.kz,qt)spr(fd.po+la[jg]*16,x,y-la.cu,sm,la.ff,qt
)end
clip()for ot in all(jy.gi)do
spr(ot[1],qt
and x+(sm-ot[4])*8-ot[2]
or x+ot[2],y+ot[3],ot[4],ot[5],qt
)end
end
sz=bs([[
0,5,2,5,4,2,9,15,8,8,15,7,14,8,14,14,
0,2,2,2,8,2,8,14,8,8,14,14,14,8,14,14,
0,2,2,2,8,2,8,8,8,8,8,8,8,8,8,8,
]])hk=bs([[
0,0,1,1,5,1,13,15,4,6,15,15,13,5,13,13,
]])hf=bs([[
0,13,8,11,9,6,7,7,14,10,7,10,7,12,7,7,
0,12,14,10,10,7,7,7,15,7,7,7,7,7,7,7,
0,12,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
]])function rt(c,v)if c.nb and not c.dg then
return
end
local jg=nil
if c.gj then
local wc=na[c.hw]
jg=wc[flr((t-c.gj)/c.bv
)%#wc+1]
end
if ev({"qi","ln"},c.pf
)then
jg=2
end
local fx,fy,fw=
c.x-c.sm*4,c.y,c.sm*8-2
is(c.x-1,fy,fw/2,2.97,fw,0)
fy+=c.z
local by=fy-c.en*8-1
+c.ms
if c.re!="boss" then
nu(fx+2,by,fx+fw-1,by,c.qg-c.pa,c.qg,8,2)end
local eo,js=
sq(11-t+c.b_,3),sq(11-t+c.pu,3)fs(c.re,fx,fy,jg,c.pf,c.qn<0,eo>0
and {c.jv and hf or sz,eo}
or js>0
and {hf,js}
or c.gb
)end
function nu(x1,y1,x2,y2,qc,n_,fg,bg,rm)if not rm then
rectfill(x1-1,y1-1,x2+1,y2+1,0)end
rectfill(x1,y1,x2,y2,bg)local w=flr(qc/n_*abs(x2-x1))if w>0 then
rectfill(x1,y1,x1+w*sgn(x2-x1),y2,fg)end
end
ss=bs([[
c1=2,c2=0,y1=11,y2=16,
c1=8,c2=1,y1=11,y2=14,nf=1,
c1=8,c2=5,y1=12,y2=12,nf=1,
]])function lb(c,v)local f=v.qn
if c.nb and hr(6,3)then
return c.t>=41
end
clip(0,0,128,10)fs(c.re,f and 128-c.sm*8 or 0,c.en*8-1-c.ms,1,"idle",f)tb()v.hp=ej(v.hp,c.qg-c.pa)local bw,h_=
mid(c.qg,21,60),flr(max(v.hp+0.5,0)).."/"..c.qg
for b in all(ss)do
nu(f and 127 or 0,b.y1,f and 128-bw or bw-1,b.y2,v.hp,c.qg,b.c1,b.c2,b.nf)end
print(h_,f and 128-#h_*4 or 2,11,7)spr(28,16,2)print(flr(eg.s_*(1+eg.charge/30)),24,3,13
)end
function ga(p,v)if v.t<30 or hr(1.5)and p.jm>0 then
v.pz/=2
gm(p.jm.." \72\73\84",v.pz+1.99,32,8)print("+"..p.jm,32-v.pz/4,3,5)end
end
pc={ob([[
q_="fights took",
le="ck",
ju=500,
hv=-10,
ea=0,
ng=32767,
]],{rp="\83"}),ob([[
q_="damage taken",
le="oh",
rp="",
ju=500,
hv=-15,
ea=0.25,
ek=0,
ng=32767,
]]),ob([[
q_="best combo",
le="gk",
ju=0,
hv=85,
ea=-4,
ek=0,
ng=20,
]],{rp="\88"})}
mt=ob([[
-1,480,960,1200,1440,
]])function pe()eg.jm,eg.ck=
0,flr(eg.ck)/10
lp(fr,"ib")lp(eg,"co")local kd={}
pc[1].ek=fr.ta*rc.fc
for st in all(pc)do
st.sv=eg[st.le]
jq(7+#kd,st.sv)local v=min(st.sv-st.ek,st.ng
)st.bx=max((st.ju+
v*(st.hv+
v/2*st.ea
))*kh,0)add(kd,st)
eg.score+=st.bx
end
add(kd,{q_="total score",bx=eg.score
})local rank=5
while eg.score<mt[rank]*kh*jn do
rank-=1
end
jq(0,eg.score)if fr.qy then
local cf=max(rank,dget(kh))dset(kh,cf)end
cw(eg.jz,ri,129,{kd=kd,rank=rank})end
function ri(p,v)for i,r in pairs(v.kd)do
local c,y=
mid((p.t-i*35)/30,0,1),i*7+42
if c>0 then
gm(r.q_,6,y,7)if r.sv then
gm(r.sv..r.rp,89,y,9,1)end
gm(flr(r.bx*c).."0",122,y,9,1)
if (c<1)kl(59)
end
end
if (p.t==180)kl(59)
if p.t>180 then
gm("rank",50,88,9)spr(57+v.rank,72,86)end
end
pg=bs([[
0,1,2,1,1,5,6,10,8,9,10,0,1,13,1,9,
0,1,2,1,0,5,6,9,8,9,10,1,10,13,1,1,
0,1,2,0,1,5,6,1,8,9,10,1,9,13,0,10,
]])nc={ob([[
ik="-stage 1-",
le="old petrel road",
fl=8,
bm=15,
ta=60,
bv=2,rk=1,
]],{lj=bs([[
0.0661,35,0,23,2,
1,56,0,20,3,
]]),bg=pk
}),ob([[
ik="-stage 2-",
le="shearwater keep",
fl=32,cl=56,
bm=1,
ta=75,
bv=2,rk=1,
]],{qh=pg,lj=bs([[
0,39,0,10,3,
0.75,39,0,5,5,
1,39,0,0,5,
]])}),ob([[
ik="-final stage-",
le="the lair",
fl=64,
ex=-256,
bm=33,
ta=52,
bv=3,
qy=1,rk=0.66,
]],{qh=pg,lj=bs([[
0.75,23,64,25,7,
1,23,0,25,7,
]]),se=bs([[
x=-256,rf="x",
]])})}
sh='abcdefghijklmnopqrstuvwxyz0123456789 ,="\n'function di(a)local s=""repeat
local p=peek(a)s=s..sub(sh,p,p)
a+=1
until p==0
return s
end
pi=bs(di(0x2680))qp=bs(di(0x2880))bk=ob(di(0x2920))function mk()local kp,ql={}
if jn<3 then
for i=1,7 do
local ke
repeat
ke=nl(pi[flr(rc.po+
rc.jn*jn+
rc.mw*i
)])until ke!=ql
ql=ke
add(kp,ob([[
kq="fight!",
oe=10,
dr=0,bb=12,
]],{x=-135*i-rnd(100),rf=ke
}))end
end
add(kp,ob([[
x=-1100,kq="final fight!",
oe=8,
qy=1,dr=16,bb=31,
]],{rf=rc["mini"..jn]
}))
return bj(ob([[
x=0,ex=-1130,
mr=1,
]],{se=kp,}),nc[jn])end
function eb(l)if gq[4]then
qw=
(fr.qy or eg.nb)and bl
or py
end
end
function gs(l,tm)if tm==20 then
eq(l.ik,12,60)eq(l.le,15,60,37)music(l.bm,0,3)end
l.hl=#ma("kj")==1
if l.x<=l.ex
and l.mr>#l.se
and l.hl
then
pe()end
if eg.nb then
music(-1)if eg.t>=30 then
o_=qb
music(31)lp(l,"ib")end
end
local gp=l.se[l.mr]
if gp and l.x<=gp.x then
me(gp)
l.mr+=1
end
end
function me(e)sk(e.rf,function(c)rq(bk[c],pq({x=64+sgn(im0(1))*im(72,128)}),rt
)end)if e.kq then
eq(e.kq,e.oe)poke(15110,e.bb)poke(15178,e.bb)sfx(33,2,e.dr)sfx(34,3,e.dr)end
end
rl={lq={jr=cz,mi=qj
},fr={jr=gs,ib=eb
},kj=ob([[
qn=1,
]],{hit_player=oa
}),ks=ob([[
lm="kj",
sm=2,en=2,
pf="gf",
pa=0,
d_=10,te=0,
vx=0,vy=0,z=0,
b_=-100,pu=-100,
bv=2,hw=1,
ht=8,
jm=0,fk=0,charge=0,
ml=0.9,
rj=-1,
ms=0,
]],{jf=gd,qi=qo,dt=ft
}),player=ob([[
lm="ks",
qg=48,
d_=2,
ck=0,
gk=0,
score=0,
]],{gf=og,jp=kn,de=jj,oo=gz,hc=cg,qi=gu,co=cp,hit_monster=dk,hit_proj=hz,ec=dp
}),boss=ob([[
lm="monster",
ro=f,monster=f,
sm=4,en=4,
qg=125,d_=1000,
dg=1,
ez=1,ms=2,
]],{gf=ie,ox=ep,dt=qu,nd=dw,jh=eu,ec=rr
}),crst=ob([[
lm="monster",
ro=f,
sm=1,
qg=30,
ht=3,
ow=1,
]],{gf=ky,ec=bq
}),oj=ob([[
lm="monster",
mh=60,
]],{gf=nr,ln=hd,hc=r_,hit_radar=si,}),skel=ob([[
lm="oj",
qg=20,te=2,
sw=0.45,s_=3,
cj=8,
mh=10,
bf=0.5,li=2,
rn=5,mj=10,
]]),capt=ob([[
lm="skel",
qg=30,sw=0.5,s_=4,
rn=12,
bf=1.1,nq=13,
ms=-2,
]]),wrth=ob([[
lm="oj",
qg=36,te=0,
sw=0.55,s_=4,
bf=1.75,ml=0.982,
mh=18,
li=31,
nq=10,cj=11,
mj=12,
rn=18,
hw=2,bv=3,
gv=5,ow=1,
]],{gf=hm
}),ston=ob([[
lm="oj",
sm=3,en=3,
qg=36,te=6,ez=1,
sw=0.4,s_=5,
bf=0.5,
nq=10,
cj=12,
mj=8,
mh=3,
rn=30,
gv=6,bv=4,
ms=3,
]],{kc=cc
}),eldr=ob([[
lm="monster",
sm=3,en=3,
d_=16,
qg=120,ez=1,
sw=0.3,s_=10,
df=0,
bv=3,
ms=1,jv=1,
]],{gf=ey,ln=mb,j_=lc
}),blch=ob([[
lm="monster",
sm=1,
qg=18,sw=0.5,
bd=3,
nk=-1,mz=0.388,
cq="bh",fm=2,
ce=52,
ms=2,
]],{gf=on,ln=lt,du=iq
}),frsp=ob([[
lm="blch",sw=0.55,
bd=1,
nk=-0.5,
mz=0.52,cr=8,
cq="ia",fm=4,
ce=4,jv=1,
]]),felm=ob([[
lm="monster",
en=1,
qg=6,
sw=0.8,s_=4,
rn=15,
jv=1,
]],{gf=ds,sf=gy,nx=ca,}),monster=ob([[
lm="ks",
monster=1,nq=7,
ro=1,
]],{du=fh,ok=ou,lx=oi
}),proj=ob([[
lm="kj",
vx=0,vy=0,vz=0,
qa=6,
]],{jr=jb,ra=fu,jf=function()
return of[6]
end
}),lz=ob([[
lm="proj",
ml=0.975,ir=0,jw=0.1,
dq=187,ll=13,dy=-4,
]],{lu=ob([[
s_=6,om=9,oe=12,
kw=4.5,w=10,
]])}),ia=ob([[
lm="proj",
es=100,s_=5,
jw=0.11,ml=1,ir=0,
dq=130,ll=0,dy=-4,
]],{jr=ci,lu=ob([[
s_=0,om=2,oe=8,
kw=1.5,w=4,
]])}),sb=ob([[
lm="proj",
qa=14,
ml=0.99,ir=0.3,jw=0.1,
ll=0,dy=-6,
dq=22,oe=14,
hh="+health",
]],{ra=er,hit_player=cm
}),qf=ob([[
lm="sb",
dq=23,oe=12,
hh="+strength",
]]),bh=ob([[
lm="proj",
s_=2,ix=1,
jw=0.11,ml=1,ir=0,
]],{ra=gw
}),em=ob([[
lm="kj",vx=0,
]],{jr=qv,}),ku={jr=iy
}
}
function qb()nu(48,35,78,35,1,1,2)spr(1,60,31)gm("you perished",40,40,15)end
function ed()bc,c_,ge,np,t,ld,o_,gr=
{},{},{},{},0,0,nil,0
end
function mf()jn,rc=0,qd[kh]
eg={s_=rc.da}
py()end
function py()music(-1)
jn+=1
fr=rq("fr",mk(),dc)bj(eg,ob([[
x=56,y=90,
pa=0,oh=0,
ck=0,
gk=0,
pf="gf",
b_=-100,
rj=-100,
pu=-100,mo=0,
hj=0,
]],{bv=fr.bv
}))rq("player",eg,rt)cw(eg.jz,lb,129)end
cartdata("krz_lairv1")ed()qw=
bl
function _update60()lo()pj()sl()end
function _draw()if o_ then
pset(rnd(128),127,13)for i=0,750 do
local x,y=rnd(128),rnd(128)local c=pget(x,y)circ(x,y-1,1,mc(0.12)and hk[1][c+1]
or c
)end
o_()else
camera(sin(t/4)*gr,cos(t/4)*gr)gr=max(gr-0.5,0)cls()qm()end
if nt then
ip(nt[1],nt[2],1)end
end
__gfx__
00000000330000333333030777003333333330003333333333330003333003333333006777703333333006777703333333333d1331d333333333333333333333
000000003077660333307077766503333333077700333333330047033330a033333067755557033330067765557033333333dd1331dd33333dd3335133333333
007007000777766033076076000003333330777665033333301d49030000aa033306675c777570330666775c77533333333ddd1331ddd333000d530033333333
000770000070076033076060676500333330765000003333014d97d00aaaaaa033307615d75160333057675c5d1333333333dd1331dd33330000055111133333
000770000070066033076056705000333330650670000000014dd9900aaaaaa93306661c767100030666675c77d0333333333d1331d333330100000000011133
007007000706660333076056765500333330506600a9982001400d000999aa9030dd001cd5710d70300006c7d503300333333333333333330001010100000013
000000003075003333076005500000003330056750a99820000000000000a90330110001771001103333301c7100077033333333333333333000000000000003
00000000300003333307608000a998203333000550a9982030556070333090333301dc5d11d7c503333330c11d77dc0333333333333333333333000000013333
00000000000000003000000880a9982033300d000000094033000033330000333320001c7c70002333333077c000003300333333333300100000033333330003
0000000000000000306d550a90a99820330f0d0777777040330940333309403333133330dc0333133333330c766d70330d033333333300001000033333330003
00000010000010003000000920e889403309050666666703330750333307603331333300c7033133333300c70000d70301d00003333300500000033333330003
0000010100000000330f902820e889403330050000000003307766033067660333333021002033333300100200330033301d0503333301101000033333300003
01000000000101003300000822088403333300082003003307ee886007ccdd603333021121220333302112122033333333015103333300501010033333300033
1010000000005000333330600010203333333333333333330688825007cdd1503330211121220333021122121033333333051503333301d05000033333300033
01000001001001003333307505100333333333333333333305222200065111503302211121020333011221210333333333010103333300501010033333300033
00000050000000003333305505103333333333333333333330000003000000003330010110000333001011000333333333000003333301d05000033333300033
00000010000000003000000880a99820333333333330006033333333333333333330006777703333333300677770333333333333333333333333333333300033
0011000000000000306d550a90a99820333333333305dd7d03333333333333333306777555570333333067755557033333333333333333333333333330000000
05110000051001103000000920e88940333333333015675660333333333333333330675c777570333333007c7775003313333333333333333333333300d11110
0011000001100000330f902820e8894033333300001608d0870333333333333333067615d75160333330dc05d750d7030013333333333333333333331d000001
0000000000100000330000082208840333333066d0111565d0333333333333333300661c767100033331005c7671001300000003351000033531333310000000
00000051000000003333306000102033333305d6d001511d603333333333333330dd001cd5710d703333070cd570703300000001100000003500333300010000
000000000000510033330750055103333333011d861015d60033333333333333301100017710011033310c017710701300000000000000003500333301000010
05000550000001003333055030510333333301286d01000003333333333333333301dc5d11d7c5033331305d11dc031300000000000000003500351300000000
01100511005000003000000880a9982033333001d580821d60333333000000033320001c7c7000230e88033330a99033077a7033307770333077703333333513
0000001100110000306d550a90a998203333011012d60151d703333305d77d0333133330dc033313088080330a90990307a07a030770bb030770770301333503
00000000000100003000000920e8894033000000015000005d60333301566d0333133300c703331308808803099000030aa0aa030770bb030770003300100103
0000000000000000330f902820e88940300102420006d6000000000000111003333330210020333308808803099033330a77a0330777bb033077f03300000003
055100051005510033000008220884030016104420056502065602444016d033333301212112033308802203099000030770a90307b0bb033000ff0300000000
0511100010001100333333060000203301d5d50224051500055d0000001110033330122112110333022020330990940307a099030bb0bc030770ff0300000000
0011000000000000333333075103033305650002420000000000333305d66d03330112211201033302220333304440330aa990330bc0cc0330fff03300000000
00000000000000003333330551033333015d5000000015d033333333015d6d033330101011003333000033333300033330000333000000033300033300000000
00110010100110013000000030000000000000000000000000000000011111111111111000040040e00b00000000000000000000000000000000000000055500
100000010000000130005515300055151100000000011001000100000010d50000000100000000000000000000111111111111000510000000000d50005d5110
001010000101010030005101300051011010000000101011501100003001111111111003040be0111140e4000000000000000000051101000010511005d51010
1011101101110001300010103000101000000000001001000d10000030100d5000000103b0e110fc711040000005111100001000005110100101110005510000
10000011000000003000000030000000000000000011103330511000300111111111100304111079c1101b000005100101001000000101000010100005100000
00051000011105113300005500155510000000000010103330d100003300100000010033000001caf10000000005100100101000001010100501010000110000
1101101100110111330005110051010010000000000010333050000033300150101003330e0110aaa0111b000005100101001000000101005010100000000000
10000001100001113300011000100010000000000011103330d11000333301d050100333bb01020002011e100005101100101000000000050100000000010001
00055100000100000000000000000000000000030010103330510000333301d05010033304010088800114000005111100001000000000d01000000033333333
51051110510511100000001100000011111000030000103330d00000333301d0501003330000002220000000000100001111100000000d010010000033333333
00011110110511000000010100000101101100030011103330511100333301d050100333040b400200be0e0000010100100010000000d0100101000000003333
51001110110111050000000000000000010100030010103330d10000333301d05010033300eb0b020e0040000001001151011000000d010000501000dd500000
11000000000011010000000000000000000000000010103330500000333301d0501003330000400200400000000101000500100000d010000001010055155110
11051055100000011110110100000000111110000001103330d11000333301d01010033300000000000000000001010005011000005100000000110051111100
10010051110510010101110100000001001011000010103330510000333301505010033300000000000000000000100000111000000000000000000011110000
00000011110111000010110100000000110001000000103330d00000333301d01010033300000000000000000000000000011000000000000000000000000000
51111011110111050000000000000000000000000010103330511000333301501010033300000000000000000000000000000000000000000000000000000000
11111000000000051100000011005110000000000000103330d00000333301501010033300dddd5d5d511100000000000000000000ddd5000000000000000000
11111010051005011010000010101000000000000000100000500000333301501010033300d111111000010000d55100000000000d5d5100015d511000000000
11110051051101000000000000000000000000000011d5d5d5d11000333301501010033300d10101010101005d50011111100d51055510001000000110551101
00000000011100000000000000000000000000000010110110110000333301501010033300d10101000001001000000000015100001100000000010001000010
55051001011100110015101000000000000000000000100100100000333301501010033300d10101010101000001000000000000000000000100000000001000
11011011001101111051010010000000000000000000000000000000333301501010033300d11111000001000100001001000010000000000000100001000001
10000000000001110010000000000000000000000000000000000000333301501010033300d00111000111000000000000000000010000100000000000000000
555555555555555500333330000330030000033300000000000000003333011010100333000500001110100000000d055510dd515510d00005100d5533333333
515155115511515100333300000030030000003311110000000000003330015010100033000d0010111010000000d55111105511511055005110d51130000000
111111111111111100333300330030030033003311101000000000003300100000010003000050101101000000d1d5111010111111105100110051100d550d50
01101110101101010033330033003003003300330101100000050000300111111111100000001000110100001d505111000011110000111011001110d5515510
1001001100101010003333000000300300000333000000000000000030100d500000010000000100101000000500111000001100000011001100100055111100
01001010010010010033330000003003000000331010003300000000300111111111100000000010110000000000000000000000000000000000000011100000
000000000000000000000300330030030033003301100033000000000010d5000000010000000001100000000100000001000000010001000100000010000000
00000000000000000000030033003003003300331110003300000000011111111111111000000000000000000000000000000010000000000000001000000000
111000001110000033333333000000003333333333333333333333333302828820ccd1016e203333333333333333330033333333003333333333300333333333
00001111000011113333333300000000333333333333333333333333330281082077cd016e2e0333333333333333330433333333040333333333040333333333
00005511000055113333333311110000333333333333333333303333333018e020ccd101d0880333000000003333330233333333024000000000420333333333
11110000111100003337a333000011113333333330003333330d0333333000002f00001002203333466ddd660003330033300333004465505564400333300333
5551000055510000333a93330000000033333330006033333067d03333330102847f778800033333200060000200000033308030000267766662000003080333
00000000000000003333333300000000333333055d7d03330dd610033333301828f8f7828e0333330086758000d0700233308800800000060000000800820333
2222222222222222333333330000000033333015675670305551d1d03333010282888f88e0203333067756657075700033308082220008675800002022020333
888888888888888833333333000000003333301608d08703051516dd333330322878288803033333006000605d65600033300202022067756650020220200333
22222222222222220333333300000000333330111d65d0333001dd60330333333333333333033333006000600677707033330020200006555600002002003333
22222222222222220000000300000000333300015116603302055d0333233300033300033323333390566650076677503333300200d906777504000020033333
222222222222222206677760000111113330d61015dd01004030103333020018e0008e003023333310007000016d5500333333020d5100565001100000033333
22222222222222220000000311111110330768dd0000507d0333033333002012eeee28ee020333331a00000905011050333333006d51a0000091110000003333
222222222222222203333333000000003055860608e1605650333333333001288e8e118e003333330110000130d000d0333330dd551011000011011100003333
22222222222222223333333300000000301d605d601d001150333333332012888888888ef0333333011a241030d00d0033330994d11011a24100001994203333
222222222222222233333333000000003015580155104000033333333300002828111118e033333310119101330dd00233309000210101191010002000020333
222222222222222233333333000000003301d26000020103333333333300088881000211ef033333000110103330002033010065020000110100001057010333
8888888888888888333300030001111033301d0d670010333333333330088828200000218f03300033333933330000003301070701066d00006d501070710333
222222222222222233004703001110013333010d56000333333333330882228820000021ee000288333394433028820033010000016d55d11dd5101000010333
0000000000000000301d4903011000003333300515020333333333332000022880000021e802220033394433302882003330100010d510555115100100010333
11110000111100000144900311000000333330100024033333333333030012028f000018ef012033333a94333028e20033300111061151000011100011100333
5555000055550000011dd060100000003333301d024003333333333333301200847f77f88e00033333a94333302ee2003330200006151d111511000000020333
000011110000111101400070000000003333301d60010333333333333333012828f8f788e033333333a94333302ee20d33302e220d1101dd5110100022220333
000011110000111100000070000000003333301550110033333333333330101282888f8e0203333334a94333302ee20d33302ee20d1510111001010022820333
000055550000555530556070000000003333301d6605d03333333333333303012878288e0003333337a93333302ee20d33302ee20d1011000011000028820333
3333333333333333310035030000000033301d0d760010333333333333333300128888e03333333337a933333311113333302e8055101d111110100028820333
333333333333333335001101100011003333010d5d0003333333333333003001188888ee0333333337a93333331dd13333302880511015101510100028220333
3333333333333333310000000111001033333005550240333333333330220ee888828888e03333334794333331dccd1333302809010101000101000002220333
333333333333333331000000000000013333011000242203333333333300e8208e228e22803003337a9333331dc77cd133300000901010041010000200000333
333333333333333310000000000000003333015d02400103333333330308220280008e002e0880337a9333331dc77cd130028880040404000202022000822003
33333510003333510000000000000000333301d60001510333333333208000280200802202e22e007a9333331177771102288822200000022000000022882220
3351100000001500000000000000000033301550033015d0333333330200208022008002000000827a9333333117711300000000000000000000000000000000
1500000000000000000000000000000033301d6603300000333333330000028000000800200000007a9333333300003302222222222222222222222222222220
3333333333333077700333333333333333301d0d760010333333333333088828200000218f030000333333333333333333333330000333333333306677033333
333033333333077766503333333333333333010d5d000333333333330082228820000021ee002288333333333333333333333308eef033333333066777700333
330703333333076000003333333333333333300555040333333333332800022880000021e8022200333000333333033333333028888e03333333067007006033
30760330333306067650033333333333333330100042033333333333000012028f000018ef010033030aaa0300307033333302228eeee0333333066087807033
307603073333056705050333333333333333301ddd0003333333333333301200847f7ff88e00333370099003070000333333082ee80f00333333306660707033
30760307333305676550033333333333333333015500033333333333333301282878f788e0333333049900333040400033302828ee0003333333330057007033
3076030633330055555033333333333333333301d6603333333333333330101282f8888e0203333304090203044999a033302002288803333333306000006033
30760305333300000003003333333333333333000000333333333333333303012888288e00033333044900030449000033300330000033333333005755706033
3076030533307682200060000000333300000003333333333333333333333300128888e033333333704499903044999033333330000333333330490566000003
000000003330667670f0d0777777033305d77d03333333333333333333303301188888ee03333333049909000499090033333308eee033333302449000704903
06d5508833300555509050666666603301566d033330003330003333330200e888828888033330034049a000004aa003333330288efe03333305649066000003
000006893333000000005000000003330011100000077d00077d033300000820822208e2033008e09009aa040909aa0333330228888e03333302224000007033
30f905283333300820330033333333333016d04442056502056503338808e82800008802800888080049a9000049990333302822eeeee0333330220070300033
30000028333306682603333333333333001110000005150005150333008022080200802028222000302490333024903333302888e80f00333333000555033333
3333302233307600006033333333333305d66d0333300011000033330000000800082002022000000200003333000033333000022e0003333333330707033333
33333000330550330550333333333333015d6d03333015005d60333300000000e008000000000000040304033040403333333300228803333333330505033333
0667703333333333333330667003333300000003300000d65d03333300088828200000218f033330333033333044999033333330000333333333049066000003
66777703333333333333066770603333333333330d785d26600333332882228820000021ee0000083307033304990900333333088ef033333330244900704903
67007003333333333333067000703333333333301758655505d033330000022880000021e8022280307790334049a00033333022888e03333330564906000003
66087803333333333333066080703333333333301525550056603333330012028f000018ef01220308a980039009aa04333302288e0f03333330222400007033
066607033333333333333066607033333333333011550011d7d0333333301200847f77f88e00003308999203004999003333028ee80003333333022070300033
300570333333333333333300506033333333333300005665560333333333012828f8ff88e03333330899f2033024903333302828eeee03333333300555033333
06000003300333333330006000603333333333333055ddd851033333333010128278888e02033333089f72030200003333302802280033333333307507503333
057557000093333333049057000003333333333333011112103333333333030128882f8e0003333308f791030403040333300200003333333333305030603333
9056600670933333302449050449033333333333333011882033333333333300128888e0333333330879a2033044999033333330000333333304900566000003
4900070000433333305649000000033333333333333000000333333330000001188888ee03333333089a91033099090033333308eee033333024490000704903
490660033003333330222405607033333333333333305602033333330220eee888828888e000333308a992033009a00333333028888803333056490666000003
240000333333333333022000000033333333333333305d6003333333300e88208e288e228eee0333089982033090a90333330222800003333022240000007033
2005650333333333333003075033333333333333333011d503333333330820028008e0002888e03300822003300499033333028e0f5f03333302203070300033
00500060333333333333330510333333333333333330056700333333308000280200802000008033302210333024903333302828000033333330033050333333
06033070333333333333330750333333333333333330101550333333008008800220080002008003330103333300033333302802200003333333333070333333
60333050333333333333330510333333333333333330101d67033333020020000000008800002820333033333304033333320000022203333333333050333333
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000073000000000000000000000000000000000000000000000000000000000073000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000047480000004748000000474800000000000000004748474800000047484748000000000000004748000047480000000000000000000000004748474800000047480000004748474800000000000000000000004748004748004748004748000000000000000000000000000000000000
0000000000000000000000000000000057580000005758000000575800000000000000005758575800000057585758000000000000005758000057580000000000000000000000005758575800000057580000005758575800000000000000000000005758005758005758005758000000000000000000000000000000000000
0000000000000000000000000000000067680000006768000000676800000000000000006768676800000067686768000000000000006768000067680000000000000000000000006768676800000067680000006768676800000000000000000000006768006768006768006768000000000000000000000000000000000000
0000000000000000000000000000000067680000006768000000676800000000000000006768676800000067686768000000000000006768000067680000000000000000000000006768676800000067680000006768676800000000000000000000006768006768006768006768000000000000000000000000000000000000
0000000000000000000000000000000077780000007778000000777800000000000000007778777800000077787778000000000000007778000077780000000000000000000000007778777800000077780000007778777800000000000000000000007778007778007778007778000000000000000000000000000000000000
6464646464646464646464646453540000000000004262646464646464646464646453540000000043626464646464646464646464646464646464646453540000426464646464646464646464646464646464646464646464646464645354000000424464646464646464646464646464646464646464646464646464646464
646445466464494a6464454664537500000000000000434464494a6464494a6464645275000000000042626464494a6464696a4d4e696a646464494a64645354434464644b4c644d4e644b4c6464644546454664494a644546454664646452540000436264646464494a64696a64494a644d4e64494a64646464646464646464
646455566464595a6464555664645354000000000000426464595a6464595a6464535400000000000000426264595a6464797a5d5e797a646464595a64646464646464645b5c645d5e645b5c6464645556555664595a645556555664646453750042636464646464595a64797a64595a645d5e64595a64646464646464646464
6464656664646464646465666464537500000000004263646464646464646464645375000000000000000042446464646464646464646464646464646464646464646464646464646464646464646465666566646464646566656664646464535443446464646464646464646464646464646464646464646464646464646464
6464646464646464646464646464535400000000004344646464646464646464645354000000000000000043446464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464646464
7600000000760000007600000000760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000760000007600760000007600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3938383a38393a3b3a38393a3b3838300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2528132826292528131328262813022826281306282925281313132826280313282628030628262813020628262806062826281313022826281313062826281302022826292528172826281728262817062826281702282628031313062826280313020228262803032826280313131328262925280313102826281710282628
1713132826281703282628131002282628131006282628031002282628100628262925281428262814022826281717282628171006062826281703032826280303131028262803030310282628030303030328262925281410282628141728262814131313282628140303282628171010282628171703062826281010060628
2628171717282629252805282628050628262814142826281417172826281403030306282628141403282628030303101028262814170310282629252805030328262805172826280514282628051028262805030606282628141414032826281717171728262925280503030328262805171428262805101028262814141417
2826281717171428262817171717102826280303101010060628262925280514142826280517172826280510100606282628141414171728262817171710101028262805030303031010282629252828262925282826292528282629252828262925282829002828290000012814282628032826280728262901280428262814
2528132826280228262806282629252803282628131328262813022826280202282628062826292528172826281028262813062826281313132826280313282628020228262806062826292528170328262803032826280306062826280302022826280606062826281028262925281428262817030628262817030328262803
030606282628030302022826281010282629000000000000000000000000000025132728130b050c282606272806050c0d28262925022728020c03082826172728171214082826292514272813140f0e2826052728050c0412282629250327280301101428261027280612131028262925182728020f13132826192728031213
142826290013100f151428262925182728020f131328261927280312191314010c2826290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000428c36875dec01741698c1bf86d1491c65eb
00000000000000000000000000000000000000000000001f0000000000000000000000000000001f00000000000000000000000000000000000000000000000000000000000000000000000000000000000e0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000007f000000000000000000001f000000000000000000000000007f001f0000000000000000007f5f000000000000000000000000000000005f0000005f007f000000000000001f0000000000000000007f5f7f5f00000000000000000000000000000000000000000000000000000000007f000000
6b6c6d6e7b7c7c7e7d7b7c7e7e7c7d6f6c6c6d6e6b4f6c2f6c7b7d6f6b6f6c6c4f6f7b7c7e7c7c7e7e7d6f6c6e6d6e6f7b7c7c7e7c7d6e7b7e7d6e6c6f6b6f7b7d6f7b7e7d6c7b7c7c7c7d6f6c6e4f6b6c2f6b6c4f6b6d6f6c7b7c7c7c7c7c7d6f6f6b6c4f6b6f6e6c6b6f7b7d7e7e6f6b6c6d6e7b7c7c7e7d7b7c7e7e7c7d6f
0000000000000000000000000000000000000000002e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000b0b1b1b23f2c2db1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000001d1e00000000001d1e00000000001d1e00000000001d1e00001d1e0000000000001d1e00001d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000057580000000000575800000000005758000000000057580000575800000000000057580000575800000000000000000000000000000000000000004b4c000000004b4c000000004b4c00000000000000000000494a0000494a0000000000000000000000000000000000000000000000000000000000
0000000000000000000057580000000000575800000000005758000000000057580000575800000000000057580000575800000000000000000000000000000000000000005b5c000000005b5c000000005b5c00000000000000000000595a0000595a0000000000000000000000000000000000000000000000000000000000
0000000000000000000067680000000000676800000000006768000000000067680000676800000000000067680000676800000000000000000000000000000000000000000000000000000000000000000000000000000000494a00000000000000000000494a00000000000000000000000000000000000000000000000000
0000000000000000000067680000000000676800000000006768000000000067680000676800000000000067680000676800000000000000000000000000000000000000000064000000000000000000000000000000000000595a00000000000000000000595a00000000000000000000000000000000000000000000000000
0000000000000000000067680000000000676800000000006768000000000067680000676800000000000067680000676800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777800000000007778000000000077780000000000777800007778000000000000777800007778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102830405060708090a0b0c0d0e0f
__sfx__
015000000e7240e7120e715000001172411712117150000015724157121571500000107241071210715000001d7241d7101d7150040021724217102171500400247142471225714257152671426712267150e000
015000001a0441a0351a0251a01521044210352102521015240442403524025240151c0441c0351c0251c0151a0441a0351a0251a0151d0441d0351d0251d0151c0441c0351c0441c0351a0441a0301a0251a005
0103000024635306050c4350c60500635246050c635246050c6051d605004050f4050260501605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
010600000c05013041130150d05014041140150e05015041150151005017041170151100018000180050400004000050000600007005000000000000000000000d00014000140050000000000000000000000000
010800000c61430614186110c6110c6110c615186003a5003b5003a5003b5003b5003a5003b5003a5003a5003b5003a5003b5003a500215022150221502005000050000500005000050000500005000050000500
0112000015753047000500005700070000770009000097000b0000b7000c0000c7000c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
010e00000c0430415504155041550c04304155041550415504155031051c5151c5150c0431c515235001c5150c0430015500155001550c04302155021550215502155225001c5151c5150c0431c5151c5151c515
010e00003f7053f7051c5151c5151c5151c5153f7051b4030c0433f705175151751517515175153f705175150c0033f7051c5151c5153f7053f7051c515000000c0433f70517515175153f705175151751517515
010e00000c0430415504155041550c613041550415504155041553f7051055010540155401754117530175320c0430015500155001550c6130215502155021550215516540155401354015540155301354017540
010e00003f7053f7051c5151c5151c5151c5153f7051c5150c0431c51517515175150c613175153f7051751517532175251c5151c5153f7050c0431c5151c5150c0433f70517515175150c613175151751517515
010e000017540175401a540175401754017532175251c5153f7051c5151a515175153f705175153f705175153f7051c5151c5151c5153f7053f7051c5153f7050c0431a5051a515175151c505175151751517515
010e00000c0430415504155041550c6130415504155041550c0433f7051f5151c5150c6131c515235001c5150c0430015500155001550c613021550215502155021551f5051f5151c5150c6131c5151c5151c515
010e000017540175401a5401c5401e5411e5401c54017540175421753517515175153f705175153f705175153f705175051c5151c5153f7053f7051c5153f7050c0433f70517515175150c003175151751517515
010e00001c5401e5411e5401e5401e5321e5321c54017540175401753517535185150c003185153f705185153f705175051c5151c5150c0033f7051c5153f7050c0433f7051e5401e5301f5401f5401f5421e540
010e00000c0430915509155091550c6130915509155091550c043031051c5151c5150c6131c515235001c5150c0430715507155071550c61307155071550715507155225001c5151c5150c6131c5151c5151c515
010e00000c0430515505155051550c6130515505155051550c043031051c5151c5150c6131c515235001c5150c0430415504155041550c613041550415504155041500404004140061400c613071501304007140
010e00001754017540175301554015540155401553015532155351550518515185150c003185153f7051851515540155401553014540145401454014530145351454014540145321554015530175401754017535
010e00001c5401e5411e5401e5401e5321e5321c54023540235402354223535185150c003185153f705185153f705175051c5151c5150c0033f7051c5153f7050c0433f70526540265302354023540235421f540
010e00000c0430915509155091550c6130915509155091550c0433f7051c5151c5150c6131c5153f7051c5150c0430b1550b1550b1550c6130b1550b1550b1550b1500b0400b1300b02009021070210601104011
010e00001e5401e5401e5301e5301e5301e5321e5321e5321c5401c5401c5301c5301c5301c5321c5321c5351c5401c5401c5301c5301c5301c5321c5321c5321b5411b5401b5301b5301b5301b5321b5321b535
011000000214502145182351a4250e1451d235021450c145182351a4250e145021451122513225091450914507145071451d22507145071451d22507145071451d2251f2251d2251a22518225071451522509145
011000000c0430c04313235154253c60518235306150c04313235154250c0430c0430c2250e22530615000000c04300000182250c04300000182253061500000182251a225182251522530615152251a2250c043
0110000009145091451d2251f2251d2251a2251822509145152250914509145212150914509145152150a0451d2251f2251d2251a22518225152251a2250a145262250a1450a1451a2250a1450a145262250a045
011000000c04309105182251a225306151522513225152251a2250c0433060526225306150c0431a2250c0430a1450a1450c043152253061515205152250c043212250c0431a20515225306150c043212250c043
011000000914509145182251a225306151522509145091450a1450a145182251a22530615152250a1450a1450b1450b145182251a22530615152250b1450b1450c1450c145182251a22530615152250c1450c145
011000000c043000001d2251f2251d2251a2250c043306150c043306051d2251f2251d2251a2250c043306150c043000001d2251f2251d2251a2250c043306150c043000001d2251f2251d2251a2250c04330615
011000000d1450d1451f42521425306151c4250d1450d1450e1450e1451f42521425306151c425021450214504145041451c21521215306150c0430414504145091450914521415091451c415154150914509145
011000000c0430c043244252642524425214250c043306150c0430c043244252642524425214250c04330605306150c04321215262152c4202d4112d4122c42030615294102641024410214101a2202641026412
015000001a0041a0051a0051a00521004210052100521005240042400524005240051c0041c0051c0051c005021240211202115001000012400112001151d105151141511509114091150212402112021151a005
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
01030000187112671128711297112b7112d7112e7112e7112f7112e7112f7112f7112e7112f7112e7112e7112f7112e7112f7112e7112d0022150221502005000050000500005000050000500005000050000500
010200000f7650f7650f7651076510765107651176511765117651276512765127651376501410024100341003410044100541006410064100b41010420144201d4202d425077050670505705047050370502705
010a0c0d1d12522125261252912529105291252912529125291052410229105251052610426102261050e1001e5462a5361e5262a5161f5362b5261f5162b51624546305362452630516235362f526235162f516
010a0c0d1a4251d425224252642529405264252642526425295052450229505255052650426502265050e50027027330172701733017280273401728017340172d027390172d017390172c027380172c01738017
010e000000145071350c12500145071350d12500145071350c12500145071350d12500145071350d1250712500145071350c12500145071350d12500145071350c12500145071350d12500145071350d12507125
010e00000c04313525185250c5250c0430e52524600186050c0430c525135250e5250c0431f716197161f7160c04313525185250c5250c0430e52518525135250c0430c525135250e5250c0430d5251352519525
010e00000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c043000000000000000
010e00000c043165251b525105250c0430e52510525165250c0431052516525195250c0431c71622716277160c043165251b525105250c0430e52510525165250c0431052516525195250c043165251952516525
011800000f5500f5400f5401055010540105401355013540135401255012540125401555015540155401655016540165401955019540195401855018540185402e54622546225362e536225262e526225162e516
011800000014000140001300013000130001300314003140031300313003130031300614006140061300613006130061300914009140091300913009130091301712017110171101711017110130110c01100011
010e0000041450a1350f125041450a1350d125041450a1350f125041450a1350d125041450a1350d1250a125041450a1350f125041450a1350d125041450a1350f125041450a1350d125041450a1350d1250a125
010e0000041450a1350f125051450b13510125071450d135121350d125121350d125101350b125101350b1251d04518125121250c1251c04517125111250b1251b0451812515125121250f1250c1250911503115
010e00000c043165251b525115250c0431c52513525195250c043165251b525165250c043175251c525235250c043245252a525245250c043235251d525175250c0431b52518525155250c04315525125250c525
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
016000000073400730007300073200730007300073000735007340073000730007300073000730007300073503734037320373203732037300373003732037350173401730017300173001732017320173201735
01600000003140031000310003150c0140c0100c0100c015003140031000310003150c014000130c5100c015033140331003310033150f0140f0100f0100f015013140131001310014150d014010130d5100d015
01180000016140e6111d6112a6111d6110f61101615186000e6020d6020f6020e6020c60301600026000360004600056000660007605006000060000600006000060000600006000060000600006000060000600
010c000004314057210631107721083110c52006521005210052530600186000c6050c6050c0000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
010900000731408721093110a7210b3110c7210d3110e7250f30010705376000c7000c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
01020000136250c6222f7022f705175062350617506235061a506265061a50626506195062550619506255061c506285061c506285061d506295061d50629506205062c506205062c5061f5062b5061f5062b506
010200000c1440d1410e5410f53110031110311272113721147211572500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012c00003c325243033130337303303033630331303373033030536305313053730530305363053130537305243002a300253002b300243002a300253002b300243002a300253002b300243002a300253002b300
011200003c325243033130337303303033630331303373033030536305313053730530305363053130537305243002a300253002b300243002a300253002b300243002a300253002b300243002a300253002b300
010300003051534515044050440610406044050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000013234004351423400435152340043516234004351723400435172340043516233004351523300435142330043513233004351223300435112330043510233004350f233004350e233004350d23300435
012600003f214006250873405731027210172100711067000570004700037000270001700007002d205006052c205006052b205006052a2050060529205006052420500205002050020500205002050020500205
010700000c6241c6252b6002f60024600286002b6002f6003060034600376001360415604176040c6040e60410604116041360400000000000000000000000000000000000000000000000000000000000000000
01010000090230010518605000000c10500000000000000000000000000000000000000000000000000000000c005000000000000000000000000000000000000000000000000000000000000000000000000000
010600002336311000103330400010705107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000017153001450003500025070001300009000150000b000170000c000180000c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
010c0a0c04044047410504105741070410774109041097410b0410b7410c0410c7410c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
__music__
04 00 01 1c 44
01 06 07 43 44
00 06 07 43 44
00 08 09 43 44
00 0b 0a 43 44
00 08 09 43 44
00 0b 0c 43 44
00 08 09 43 44
00 0b 0a 43 44
00 08 09 43 44
00 0b 0c 43 44
00 0e 0d 43 44
00 0f 10 43 44
00 0e 11 43 44
02 12 13 43 44
01 14 15 43 44
00 14 15 43 44
00 14 15 43 44
00 14 15 43 44
00 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 1a 1b 43 44
00 27 28 43 44
01 23 25 43 44
00 23 25 43 44
00 23 24 43 44
00 23 24 43 44
00 29 26 43 44
00 23 24 43 44
02 2a 2b 43 44
04 41 42 2c 2d
04 1d 1e 43 44
03 2e 2f 43 44
00 41 42 21 22
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 39 42 43 44
