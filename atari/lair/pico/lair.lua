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