pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
a=5
b=7
c={}
d={}
for e=1,b do
c[e]={}
for f=1,a do
c[e][f]={}
add(d,{e,f})
end
end
g={
["a_step"]=011,
["b_step"]=012,
["pad_step"]=013,
["button_step"]=021,
["advance"]=014,
["bump"]=015,
["shoot"]=016,
["jump"]=017,
["charge"]=021,
["health"]=018,
["score"]=019,
["enemy_dash"]=020,
}
h={
"a_step",
"b_step",
"pad_step",
"button_step",
"bump",
"jump",
"charge",
"health",
"score",
"enemy_dash",
"advance",
"shoot",
}
i={}
j=0
k=0
l=true
m=false
n=0
o={}
p=32
q=4
r={{0,0}}
s=false
time=0
t=false
u=false
v=false
w=007
x={}
y={}
z={}
ba={}
bb={}
bc={}
bd={}
be={}
bf={}
bg={}
bh={{-1,0},{1,0},{0,-1},{0,1}}
bi={}
bj={}
bk()
for bl in all({{2,3},{3,3},{4,3},{5,3}}) do
local bm=bn("wall_right",bl)
if bm then
bm:bo()
end
end
for bl in all({{2,3},{4,2},{6,3}}) do
local bm=bn("wall_down",bl)
if bm then
bm:bo()
end
end
bp=bq()
br=bq()
bp.bs=true
bt(bp,{3,3})
bt(br,{5,3})
bu()
bv({{2,4},{4,2},{6,4}})
function bw(bx,by,bz)
local ca={
[001]=by,
}
local cb=1
local cc=bx
for cd=1,by-1 do
cc+=cd+bz
local bl=cb+flr(cc)
ca[bl]=by-cd
cb=bl
end
return ca
end
ca=bw(12,12,4)
ce={
[001]={"baby"},
[026]={"baby","dash"},
[051]={"baby","dash","timid"},
[076]={"slime","dash","timid"},
[101]={"slime","dash","timid","grow"},
}
cf={
["baby"]=function()
cg():ch()
end,
["timid"]=function()
ci():ch()
end,
["slime"]=function()
cj():ch()
end,
["dash"]=function()
ck():ch()
end,
["grow"]=function()
cl():ch()
cl():ch()
end,
}
cm=ca[1]
cn=ce[1]
co=cp(cn)
cq(co)
cr={0,0,0}
cs=0
ct=false
cu()
music(000)
end
function _update60()
time+=1
for bl in all(y) do
if bl.cv<=0 and#bl.cw<=1 then
bl:bo()
local cx=cy(cz(bl))
if(not bl.da) db(cx,true)
end
end
if s then
if n>0 then
n-=1
elseif btnp(5) then
_init()
end
return
end
if#bj<2 then
for cd=0,3 do
if btnp(cd) then
add(bj,bh[cd+1])
end
end
if btnp(5) then
add(bj,5)
end
end
if n>0 then
n-=1
elseif bn("exit",cz(bp)) and bn("exit",cz(br)) then
j+=100
add(bi,dc())
dd({41,53},de("you escaped!"),014,007,true)
p=0
s=true
n=20
elseif bp.cv<=0 or br.cv<=0 then
add(bi,dc())
dd({46,53},de("game over"),014,007,true)
s=true
n=20
elseif l==true and#bj>0 then
if bj[1]==5 then
for bl in all(x) do
v=true
bl.bs=not bl.bs
end
df()
i["switch"]=true
else
dg():dh(bj[1])
end
del(bj,bj[1])
elseif l==false then
if di() then
dj()
bk()
bu()
bv()
p-=1
else
bu()
end
cq(y)
for bl in all(y) do
bl:dk()
end
if ce[k] then
cn=ce[k]
co=cp(cn)
cq(co)
end
k+=1
dl()
for cd=1,cr[k] do
cu()
end
if ca[k] then
cm=ca[k]
end
df()
l=true
end
dm()
local dn=false
for bl in all(h) do
if i[bl] then
dn=bl
end
i[bl]=false
end
if dn then
sfx(g[dn],3)
end
if stat(1)>1 then printh(stat(1)) end
end
function dp(dq)
local dr={0,0}
local ds={-dq[1],-dq[2]}
local dt={-dq[1]*2,-dq[2]*2}
r={dr,dt,dt,ds,dr}
end
function du(dv)
if#dv>1 then
del(dv,dv[1])
end
end
function _draw()
cls()
local cx=r[1]
camera(cx[1],cx[2])
du(r)
rectfill(11,11,116,86,007)
rect(12,12,115,85,000)
pal(006,w)
for e=12,115,8 do
spr(008,e,4)
spr(008,e,86,1,1,true,true)
end
for f=13,84,8 do
spr(007,4,f)
spr(007,116,f,1,1,true,true)
end
spr(009,4,5)
spr(010,116,5,1,1,true)
spr(010,4,85,1,1,false,true)
spr(009,116,85,1,1,true,true)
pal()
for dw in all({
z,
bb,
ba,
bf,
bd,
be,
x,
y,
bi,
bc,
}) do
for bl in all(dw) do
bl:dx()
end
end
local dy=bn("button",cz(bp))
local dz=bn("button",cz(br))
local ea=false
local eb=false
if(dy) ea=dy.color
if(dz) eb=dz.color
if s then
local ec
local ed
local ee
if p!=0 then
ec=de("you died with "..j.." gold")
else
ec=de("+100 gold for escaping")
end
local ed=64-#ec*2
print(ec,ed,99,007)
if p!=0 then
local ef=p==1 and" depth"or" depths"
ec=de(p..ef.." from the surface")
else
ec=de("total gold: "..j)
end
ed=64-#ec*2
print(ec,ed,109,007)
print(de("press x to restart"),28,119,005)
elseif not(v and u and t) then
print(de("press x to switch heroes"),16,99,v and 005 or 007)
print(de("bump to attack"),36,109,u and 005 or 007)
print(de("stand on 2"),19,119,t and 005 or 007)
palt(015,true)
pal(006,t and 005 or 007)
spr(016,61,116)
print(de("to ascend"),73,119,t and 005 or 007)
pal()
elseif eg==012 and not o[012] and(ea==012 and bp.eh==true or eb==012 and br.eh==true) then
print(de("when a hero stands on"),15,99,007)
print(",",111,99,007)
print(de("the other hero can jump"),18,109,007)
palt(15,true)
pal(005,001)
pal(006,012)
spr(018,102,96)
pal()
elseif eg==011 and not o[011] and(ea==011 and bp.eh==true or eb==011 and br.eh==true) then
print(de("when a hero stands on"),15,99,007)
print(",",111,99,007)
print(de("the other hero can shoot"),16,109,007)
palt(15,true)
pal(005,003)
pal(006,011)
spr(018,102,96)
pal()
elseif eg==008 and not o[008] and(ea==008 and bp.eh==true or eb==008 and br.eh==true) then
print(de("are refilled with health"),22,99,007)
print(de("when enemies step on them"),14,109,007)
palt(15,true)
pal(005,002)
pal(006,008)
spr(017,10,96)
pal()
elseif eg==009 and not o[009] and(ea==009 and bp.eh==true or eb==009 and br.eh==true) then
print(de("are refilled with gold"),26,99,007)
print(de("when enemies step on them"),14,109,007)
palt(15,true)
pal(005,004)
pal(006,009)
spr(017,14,96)
pal()
else
print(de("depth"),11,99,007)
print(p,34,99,007)
local ei=j..""
print(de("gold"),102,99,007)
print(ei,99-#ei*4,99,007)
spr(032,11,106,7,1)
spr(048,11,116,7,1)
spr(039,70,106,6,1)
spr(055,70,116,6,1)
end
for bl in all(bc) do
bl:dx()
end
end
function dc()
local ej={
dx=function(self)
for ek=14,114,3 do
for el=14,84,3 do
local ek=ek+(el%2*2)
if(ek<114) pset(ek,el,006)
end
end
end
}
return ej
end
function cp(dv)
local em={}
for bl in all(dv) do
add(em,bl)
end
return em
end
function en()
local en={
e=eo,
f=eo,
cw={},
ep={{010,010}},
eq={100},
er=function(self)
du(self.cw)
du(self.ep)
du(self.eq)
pal()
end,
bo=function(self)
if self.e and self.f then
del(c[self.e][self.f],self)
end
del(self.dw,self)
end,
}
return en
end
function bq()
local es=en()
es.type="hero"
es.et="enemy"
es.eu=3
es.cv=3
es.dw=x
es.eh=false
es.dh=function(self,ev)
local ew=x[1]==self and x[2] or x[1]
local ex=ey(cz(self),ev)
if ez(ex) and not bn("hero",ex) then
local fa=bn("enemy",ex)
local bm=fb(cz(self),ex)
if self.fc then
if(fa or bm) o[012]=true
if(fa) fd(fa,3,ev)
local fe=cy(cz(self))
local ff=cy(ex)
local fg={(fe[1]+ff[1])/2,fe[2]-4}
bt(self,ex)
fh(self,{fg,ff},q/2,0)
n=q
i["jump"]=true
l=false
elseif not bm then
local fi=fj(self,ev)
if self.fk and#fi>0 then
for bl in all(fi) do
fd(bl,1,{-ev[1],-ev[2]})
end
fl(self,ev)
o[011]=true
i["shoot"]=true
n=q
l=false
elseif fa then
i["bump"]=true
u=true
fd(fa,1,ev)
local fm=cy(cz(self))
local fn={fm[1]+ev[1]*4,fm[2]+ev[2]*4}
fh(self,{fn,fm},q/2,0)
n=q
l=false
else
bt(self,ex)
fh(self,{cy(ex)},q,0)
n=q
l=false
end
end
end
ew.fc=false
ew.fk=false
local em=bn("button",cz(self))
if em then
if em.color==012 then
ew.fc=true
elseif em.color==011 then
ew.fk=true
end
end
end
es.dx=function(self)
local fo=self.bs and 001 or 000
local fp=self.cw[1][1]
local fq=self.cw[1][2]
local fr=cy(cz(self))[1]
local fs=cy(cz(self))[2]
palt(015,true)
palt(000,false)
if not self.bs then
pal(000,006)
end
if self.fk then
pal(007,011)
pal(006,011)
pal(005,007)
if self.bs then
for bl in all(bh) do
local dv=cz(self)
local em={self.e+bl[1],self.f+bl[2]}
local fo=bl[2]==0 and 003 or 004
local ft
local fu
if bl[1]==-1 then
ft=true
elseif bl[2]==-1 then
fu=true
end
if#fj(self,bl)>0 and not s then
spr(fo,fr+bl[1]*8,fs+bl[2]*8,1,1,ft,fu)
end
end
end
elseif self.fc then
pal(007,012)
pal(006,012)
pal(005,007)
if self.bs then
for bl in all(bh) do
local dv=cz(self)
local em={self.e+bl[1],self.f+bl[2]}
local fo=bl[2]==0 and 003 or 004
local ft
local fu
if bl[1]==-1 then
ft=true
elseif bl[2]==-1 then
fu=true
end
if
not s and
(bn("enemy",em) or
ez(em) and fb(dv,em) and not bn("hero",em))
then
spr(fo,fr+bl[1]*8,fs+bl[2]*8,1,1,ft,fu)
end
end
end
else
pal(005,007)
if self.bs then
for bl in all(bh) do
local dv=cz(self)
local em={self.e+bl[1],self.f+bl[2]}
local fo=bl[2]==0 and 003 or 004
local ft
local fu
if bl[1]==-1 then
ft=true
elseif bl[2]==-1 then
fu=true
end
if not fb(dv,em) and bn("enemy",em) then
spr(fo,fr+bl[1]*8,fs+bl[2]*8,1,1,ft,fu)
end
end
end
end
pal(self.ep[1][1],self.ep[1][2])
spr(fo,fp,fq)
fv(fp,fq,self.cv,0,8)
self:er()
end
add(x,es)
return es
end
function fw()
local fx=en()
fx.eq={021}
fx.type="enemy"
fx.et="hero"
fx.fy=true
fx.cv=2
fx.fz=0
fx.dw=y
fx.ga=nil
fx.gb=nil
fx.dk=function(self)
if l==false then
if self.fy==true then
self.fy=false
else
self.ga=self:gc()
self.gb=self:gd()
self:ge()
self:gf()
end
end
end
fx.gc=function(self)
local gg={}
for bl in all(x) do
if gh(bl.gi,cz(self))==1 then
add(gg,bl)
end
end
if#gg>=1 then
cq(gg)
return gg[1]
else
return nil
end
end
fx.gj=function(self)
local fm=cz(self)
local ga
local gk
local gl={}
local gm
local gn=gh(bp.gi,fm)
local go=gh(br.gi,fm)
local gp=gh(bp.gq,fm)
local gr=gh(br.gq,fm)
local gs=gt(fm,x,false)
local gu=gt(fm,x,true)
if#gs>1 and#gu>0 then
gm=gu
else
gm=gs
end
cq(gm)
ga=gm[1]
gk=gh(ga.gi,fm)
local gv=gw(fm)
for bl in all(gv) do
if bn("enemy",bl) then
del(gv,bl)
end
end
for bl in all(gv) do
if gh(ga.gi,bl)<gk then
add(gl,bl)
end
end
if#gl==0 then
for bl in all(gv) do
if gh(ga.gq,bl)<gk then
add(gl,bl)
end
end
end
if#gl==0 then
gl=gv
end
if#gl>0 then
cq(gl)
return gl[1]
end
end
fx.gd=function(self)
if not self.ga then
return self:gj()
end
end
fx.ge=function(self)
if self.ga then
local ev=gx(cz(self),cz(self.ga))
fd(self.ga,1,ev)
local fm=cy(cz(self))
local fn={fm[1]+ev[1]*4,fm[2]+ev[2]*4}
fh(self,{fn,fm},q/2,2)
n=q
i["bump"]=true
end
end
fx.gf=function(self)
if self.gb then
bt(self,self.gb)
fh(self,{cy(self.gb)},q,0)
n=q
end
end
fx.dx=function(self)
local fo=self.eq[1]
local fp=self.cw[1][1]
local fq=self.cw[1][2]
palt(015,true)
palt(000,false)
if self.fy and l==false or self.fy and n==0 then
pal(000,006)
end
pal(self.ep[1][1],self.ep[1][2])
spr(fo,fp,fq)
local gy=self.fz==012 and 3 or self.fz>0 and 1 or 0
fv(fp,fq,self.cv,gy,8)
if self.cv>=1 and self.fz>006 and not s then
pal(006,self.fz)
spr(002,fp,fq)
end
self:er()
end
fx.ch=function(self)
local gz={}
for bl in all(d) do
if
not bn("hero",bl) and
not bn("enemy",bl) and
gh(bp.gi,bl)>=3 and
gh(br.gi,bl)>=3
then
add(gz,bl)
end
end
if#gz>0 then
cq(gz)
bt(self,gz[1])
else
self:bo()
end
end
add(y,fx)
return fx
end
function ci()
local fx=fw()
fx.eq={021}
fx.cv=1
fx.gd=function(self)
if not self.ga then
local fm=cz(self)
local gb=self:gj()
if gb then
if
gh(bp.gi,gb)>1 and
gh(br.gi,gb)>1
then
return gb
else
local dq=gx(cz(self),gb)
local dv=cy(cz(self))
local em={dv[1]+dq[1]*2,dv[2]+dq[2]*2}
self.eq=ha({027,021})
end
end
end
end
return fx
end
function ck()
local fx=fw()
fx.eq={026}
fx.cv=1
fx.dq={0,0}
fx.gc=function(self)
local ga
for dq in all(bh) do
local hb=fj(self,dq)[1]
if hb and ga then
local hc=gh(hb.gi,cz(self))
local hd=gh(ga.gi,cz(self))
if hc<hd then
ga=hb
self.dq=dq
end
elseif hb then
ga=hb
self.dq=dq
end
end
if ga then
return ga
else
self.dq={0,0}
return nil
end
end
fx.gd=function(self)
if not self.ga then
return self:gj()
end
end
fx.ge=function(self)
if self.ga then
fd(self.ga,1,self.dq)
local gy=cz(self.ga)
local he=cz(self)
local hf={he}
while true do
he=ey(he,self.dq)
if hg(he,gy) then
break
end
add(hf,he)
end
for cd=1,#hf do
local em=bn("button",hf[cd])
local hh=bn("charge",hf[cd])
if em and(em.color==009 or em.color==008) and not hh then
em:hi(cd*2)
end
db(cy(hf[cd]),false,1,4+cd*8)
end
bt(self,gy)
fh(self,{cy(gy)},q,0)
n=q
i["enemy_dash"]=true
self.cv=0
end
end
return fx
end
function cj()
local fx=fw()
fx.eq={022}
fx.gf=function(self)
if self.gb then
bt(cg(),cz(self))
bt(self,self.gb)
fh(self,{cy(self.gb)},q,0)
n=q
self.fy=true
end
end
fx.ge=function(self)
if self.ga then
local ev=gx(cz(self),cz(self.ga))
fd(self.ga,1,ev)
local fm=cy(cz(self))
local fn={fm[1]+ev[1]*4,fm[2]+ev[2]*4}
fh(self,{fn,fm},q/2,2)
n=q
i["enemy_bump"]=true
self.fy=true
end
end
return fx
end
function cg()
local fx=fw()
fx.cv=1
fx.eq={023}
return fx
end
function cz(hj)
return{hj.e,hj.f}
end
function hk(hl)
local dv=gw(hl)
local em={}
for bl in all(dv) do
if
not bn("enemy",bl) and
not bn("hero",bl)
then
add(em,bl)
end
end
return em
end
function cl()
local fx=fw()
fx.cv=1
fx.eq={024}
fx.hm="grow"
fx.hn=function(self)
local ho={}
for bl in all(y) do
if bl.hm=="grow"then
add(ho,bl)
end
end
del(ho,self)
cq(ho)
return ho
end
fx.hp=function(self)
local fm=cz(self)
local ho=self:hn()
local gl={}
local gm
local hq=gt(cz(self),ho,false)
local hr=gt(cz(self),ho,true)
if#hq>1 and#hr>0 then
gm=hr
else
gm=hq
end
cq(gm)
local ga=gm[1]
local gk=gh(ga.gi,fm)
if gk==0 then
return nil
end
local gv=gw(cz(self))
for bl in all(gv) do
local fa=bn("enemy",bl)
if
bn("hero",bl) or
fa and fa.hm!="grow"
then
del(gv,bl)
end
end
for bl in all(gv) do
if gh(ga.gi,bl)<gk then
add(gl,bl)
end
end
if#gl==0 then
for bl in all(gv) do
if gh(ga.gq,bl)<gk then
add(gl,bl)
end
end
end
if#gl==0 then
gl=gv
end
if#gl>0 then
cq(gl)
return gl[1]
end
end
fx.gd=function(self)
if#self:hn()>0 then
return self:hp()
elseif not self.ga then
return self:gj()
end
end
fx.gf=function(self)
if self.cv>0 then
if self.gb then
bt(self,self.gb)
fh(self,{cy(self.gb)},q,0)
n=q
end
for bl in all(c[self.e][self.f]) do
if bl!=self and bl.hm=="grow"then
self.cv=0
self.da=true
bl.cv=0
bt(hs(),cz(self))
end
end
end
end
fx.gc=function(self)
local ho=self:hn()
if#ho==0 then
local gg={}
for bl in all(x) do
if gh(bl.gi,cz(self))==1 then
add(gg,bl)
end
end
if#gg>0 then
cq(gg)
return gg[1]
end
end
end
fx.ch=function(self)
function ht(hu,hv)
for bl in all(hv) do
if
bl.e and bl.f and
gh(bl.gi,hu)<5
then
return true
end
end
return false
end
local gz={}
local hv={}
for bl in all(y) do
if bl.hm=="grow"then
add(hv,bl)
end
end
for bl in all(d) do
if not ht(bl,hv) then
add(gz,bl)
end
end
for bl in all(gz) do
if
bn("enemy",bl) or
gh(bp.gi,bl)<3 or
gh(br.gi,bl)<3
then
del(gz,bl)
end
end
if#gz>0 then
cq(gz)
bt(self,gz[1])
self.gi=hw(cz(self))
self.gq=hw(cz(self),{"enemy","hero"})
else
self:bo()
end
end
return fx
end
function hs()
local fx=fw()
fx.cv=3
fx.eq={025}
return fx
end
function gt(hl,hx,hy)
local hy=hy or{}
local gt={hx[1]}
for cd=2,#hx do
local hz=gh(hy and gt[1].gq or gt[1].gi,hl)
local ia=gh(hy and hx[cd].gq or hx[cd].gi,hl)
if ia<hz then
gt={hx[cd]}
elseif ia==hz then
add(gt,hx[cd])
end
end
return gt
end
function fl(hj,dq)
local bm=nil
local ib=cz(hj)
while bm==nil do
local ex={ib[1]+dq[1],ib[2]+dq[2]}
if
not ez(ex) or
fb(ib,ex)
then
bm=ib
end
ib=ex
end
local dv=cy(cz(hj))
local em=cy(bm)
local ic=dv[1]
local id=dv[2]
local ie=em[1]
local ig=em[2]
if hg(dq,{0,-1}) then
ic+=3
ie+=3
id-=3
ig+=0
elseif hg(dq,{0,1}) then
ic+=3
ie+=3
id+=10
ig+=7
elseif hg(dq,{-1,0}) then
ic-=3
ie+=0
id+=3
ig+=3
elseif hg(dq,{1,0}) then
ic+=10
ie+=7
id+=3
ig+=3
end
local fl={
ih=6,
dx=function(self)
rectfill(ic,id,ie,ig,011)
self.ih-=1
if self.ih==0 then
del(bc,self)
end
end,
}
add(bc,fl)
end
function ha(dr,ii)
local ii=ii or q
local ds={}
for bl in all(dr) do
for cd=1,ii do
add(ds,bl)
end
end
return ds
end
function ij(ik)
local il={}
for dw in all(ik) do
for bl in all(dw) do
add(il,bl)
end
end
return il
end
function fv(im,io,ip,iq,bz)
for cd=1,ip do
pset(im+bz,io+10-cd*3,not s and flr(time/24)%2==0 and 002 or 008)
pset(im+bz,io+9-cd*3,not s and flr(time/24)%2==0 and 002 or 008)
end
for cd=1,ip-iq do
pset(im+bz,io+10-cd*3,008)
pset(im+bz,io+9-cd*3,008)
end
end
function dl()
cr[k+2]=0
if k-cs>=cm then
if flr(rnd(2))==1 then
cr[k+1]+=1
else
cr[k]+=1
end
cs=k
end
end
function cu()
if#co==0 then
co=cp(cn)
cq(co)
end
cf[co[1]]()
del(co,co[1])
end
function dg()
if bp.bs then
return bp
else
return br
end
end
function ir(color)
if(color==012) return 001
if(color==008) return 002
if(color==011) return 003
if(color==009) return 004
if(color==014) return 002
end
function de(is)
local it=""
local dt
for cd=1,#is do
local dr=sub(is,cd,cd)
if dr!="^"then
if not dt then
for iu=1,26 do
if dr==sub("abcdefghijklmnopqrstuvwxyz",iu,iu) then
dr=sub("ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\",iu,iu)
end
end
end
it=it..dr
dt=true
end
dt=not dt
end
return it
end
function ez(cz)
local iv=cz[1]
local iw=cz[2]
if
iv<1 or
iv>b or
iw<1 or
iw>a
then
return false
end
return true
end
function fh(hj,ix,ih,iy)
local iz={}
local hh=hj.cw[1]
for cd=1,iy do
add(iz,hh)
end
for bl in all(ix) do
local ja={(bl[1]-hh[1])/ih,(bl[2]-hh[2])/ih}
for iu=1,ih do
local jb=hh[1]+ja[1]
local jc=hh[2]+ja[2]
local bl={jb,jc}
add(iz,bl)
hh=bl
end
end
hj.cw=iz
end
function bt(hj,hu)
if not ez(hu) then
return
end
if hj.type=="hero"and hj.e then
hj.eh=false
local em=bn("button",hu)
local iz=bn("pad",hu)
if hj==bp then
i["a_step"]=true
local jd=bn("button",cz(br))
if(jd and not o[jd.color] and br.eh==true) eg=jd.color
else
i["b_step"]=true
local jd=bn("button",cz(bp))
if(jd and not o[jd.color] and bp.eh==true) eg=jd.color
end
if iz then
i["pad_step"]=true
elseif em then
local hh=bn("charge",hu) and true or false
if em.color==011 or em.color==012 then
i["button_step"]=true
end
if em.color and not o[em.color] and not hh then
hj.eh=true
eg=em.color
end
end
end
if hj.e then
del(c[hj.e][hj.f],hj)
end
add(c[hu[1]][hu[2]],hj)
hj.e=hu[1]
hj.f=hu[2]
if hj.cw and#hj.cw==0 then
local je=cy(hu)
if hj.type=="enemy"then
for cd=-4,0 do
add(hj.cw,{je[1],je[2]+cd})
end
else
hj.cw={je}
end
end
if hj.type=="enemy"then
local em=bn("button",cz(hj))
local hh=bn("charge",cz(hj))
if em and em.color==008 and not hh then
em:hi()
o[008]=true
i["charge"]=true
elseif em and em.color==009 and not hh then
em:hi()
o[009]=true
i["charge"]=true
end
end
end
function bu()
for bl in all(x) do
bl.gi=hw(cz(bl))
bl.gq=hw(cz(bl),{"enemy"})
end
for bl in all(y) do
if bl.hm=="grow"then
bl.gi=hw(cz(bl))
bl.gq=hw(cz(bl),{"enemy","hero"})
end
end
end
function dm()
for jf in all(x) do
local hh=bn("charge",cz(jf))
if hh then
if hh.color==008 then
if jf.cv<jf.eu then
jf.cv=min(jf.cv+1,jf.eu)
dd(jf,de("+1 health"),008,007)
else
dd(jf,de("+0 health"),008,007)
end
i["health"]=true
elseif hh.color==009 then
j+=1
dd(jf,de("+1 gold"),009,007)
i["score"]=true
end
hh:bo()
end
end
end
function cy(jg)
local ie=jg[1]-1
local ig=jg[2]-1
return{ie*15+15,ig*15+15}
end
function cq(jh)
for cd=#jh,1,-1 do
local iu=flr(rnd(cd))+1
jh[cd],jh[iu]=jh[iu],jh[cd]
end
end
function ch(hj,ji)
local gz={}
for bl in all(d) do
local jj=true
local e=bl[1]
local f=bl[2]
local cz=c[e][f]
for jk in all(cz) do
for jl in all(ji) do
if jk.type==jl then
jj=false
end
end
end
if jj then
add(gz,{e,f})
end
end
local jm=flr(rnd(#gz))+1
local hu=gz[jm]
bt(hj,hu)
end
function dd(jn,jo,jp,jq,jr)
local he={
jn=jn,
ek=function(self)
return#jn==2 and self.jn[1] or self.jn.cw[1][1]-#jo*2+4
end,
el=function(self)
return#jn==2 and self.jn[2] or self.jn.cw[1][2]
end,
js=0,
jh=0,
dx=function(self)
local bx={self:ek(),self:el()+self.js}
for ek in all({-1,0,1}) do
for el in all({-1,0,1,2}) do
local bl={ek,el}
local jt=ey(bx,bl)
print(jo,jt[1],jt[2],jq)
end
end
print(jo,bx[1],bx[2]+1,ir(jp))
print(jo,bx[1],bx[2],jp)
if self.jh<96 then
self.jh+=1
self.js=max(-8,self.js-1)
elseif not jr then
del(bc,self)
end
pal()
end,
}
add(bc,he)
return he
end
function db(je,ju,jv,ih)
local jv=jv or 8
local ih=ih or 15
function jw(je,ih,ju)
local jx=ju and{1,-1,1.5,-1.5,2,-2} or{0}
local jy=cp(jx)
cq(jx)
cq(jy)
local jz={
ka=je[1],
kb=je[2],
jx=jx[1],
jy=jy[1],
kc=ih,
ih=ih,
fo=011,
kd=1,
dx=function(self)
if self.ih==flr(self.kc*2/3) then
self.fo=005
self.kd/=3
elseif self.ih==flr(self.kc*1/3) then
self.fo=006
self.kd/=3
end
palt(015,true)
self.ka+=self.jx*self.kd
self.kb+=self.jy*self.kd
spr(self.fo,self.ka,self.kb)
self.ih-=1
if self.ih<=0 then
del(bd,self)
end
pal()
end
}
add(bd,jz)
end
for cd=1,jv do
jw(je,ih,ju)
end
end
function ke(kf,cz)
for bl in all(kf) do
if cz[1]==bl[1] and cz[2]==bl[2] then
return true
end
end
return false
end
function bn(type,cz)
if ez(cz) then
local e=cz[1]
local f=cz[2]
for cd=1,#c[e][f] do
local bl=c[e][f][cd]
if bl.type==type then
return bl
end
end
end
return false
end
function kg(kh,cz)
local ki=false
for bl in all(kh) do
if bn(bl,cz) then
ki=true
end
end
return ki
end
function gw(cz)
local kj=cz[1]
local kk=cz[2]
local gv={}
local kl={kj,kk-1}
local km={kj,kk+1}
local kn={kj-1,kk}
local ko={kj+1,kk}
local kp={kl,km,kn,ko}
for bl in all(kp) do
if
ez(bl) and
fb(cz,bl)==false
then
add(gv,bl)
end
end
return gv
end
function fj(hj,ev)
local ib=cz(hj)
local gg={}
while true do
local ex={ib[1]+ev[1],ib[2]+ev[2]}
local ga=bn(hj.et,ex)
if
not ez(ex) or
fb(ib,ex) or
bn(hj.type,ex) and not ga
then
return gg
end
if ga then
add(gg,ga)
end
ib=ex
end
end
function ey(cz,dq)
return{cz[1]+dq[1],cz[2]+dq[2]}
end
function df()
local jf=dg()
for bl in all(y) do
bl.fz=0
if gh(jf.gi,cz(bl))==1 then
bl.fz=006
end
end
for dq in all(bh) do
if jf.fk then
local gg=fj(jf,dq)
for bl in all(gg) do
bl.fz=011
end
elseif jf.fc then
local fa=bn("enemy",ey(cz(jf),dq))
if fa then
fa.fz=012
end
end
end
end
function di()
return bn("pad",cz(bp)) and bn("pad",cz(br))
end
function dj()
t=true
local kq
for bl in all(z) do
if
bl!=bn("pad",cz(bp)) and
bl!=bn("pad",cz(br))
then
kq=bl
end
end
kr(kq.color):ch({kq.e,kq.f})
i["advance"]=true
end
function fd(ga,ks,ev)
ga.cv-=ks
if ga.type=="enemy"then
if ga.cv<=0 then
i["bump"]=true
end
end
local kt={000,008}
local f={010,010}
ga.ep={f,f,kt,kt,kt,kt,f}
dp(ev)
end
function gx(dr,ds)
local fr=dr[1]
local fs=dr[2]
local ku=ds[1]
local kv=ds[2]
if ku==fr and kv==fs-1 then
return{0,-1}
elseif ku==fr and kv==fs+1 then
return{0,1}
elseif ku==fr-1 and kv==fs then
return{-1,0}
elseif ku==fr+1 and kv==fs then
return{1,0}
else
return false
end
end
function hg(dr,ds)
return dr[1]==ds[1] and dr[2]==ds[2]
end
function kw(dr,ds)
local kx=abs(dr[1]-ds[1])
local ky=abs(dr[2]-ds[2])
return kx+ky
end
function hw(hl,hy)
local hy=hy or{}
local kz={hl}
local la={}
local gl=0
local lb={}
for e=1,b do
lb[e]={}
for f=1,a do
lb[e][f]=1000
end
end
lb[hl[1]][hl[2]]=0
while#kz>0 do
for cd=1,#kz do
local fm=kz[cd]
for bl in all(gw(fm)) do
if lb[bl[1]][bl[2]]==1000 then
lb[bl[1]][bl[2]]=gl+1
if
not ke(la,bl) and
not kg(hy,bl)
then
add(la,bl)
end
end
end
end
gl+=1
kz=la
la={}
end
return lb
end
function gh(map,cz)
return map[cz[1]][cz[2]]
end
function fb(lc,ld)
local le=lc[1]
local lf=lc[2]
local lg=ld[1]
local lh=ld[2]
if lg==le and lh==lf-1 then
return bn("wall_down",ld) and true or false
elseif lg==le and lh==lf+1 then
return bn("wall_down",lc) and true or false
elseif lg==le-1 and lh==lf then
return bn("wall_right",ld) and true or false
elseif lg==le+1 and lh==lf then
return bn("wall_right",lc) and true or false
end
end
function li()
for bl in all(bf) do
del(c[bl.e][bl.f],bl)
del(bf,bl)
end
bf={}
end
function bk()
li()
lj()
while not lk() do
li()
lj()
end
end
function ll(type)
local lm={
e=eo,
f=eo,
type=type,
dx=function(self)
palt(0,false)
local im=(self.e-1)*8+(self.e-1)*7+15
local io=(self.f-1)*8+(self.f-1)*7+15
local ln=im+11
local lo=io+11
local lp=im+11
local lq=io+11
if self.type=="wall_right"then
lo=io-4
elseif self.type=="wall_down"then
ln=im-4
end
local lr=ln-1
local lt=lo-1
local lu=lp+1
local lv=lq+1
rectfill(lr,lt,lu,lv,000)
rectfill(ln,lo,lp,lq,007)
pal()
end,
bo=function(self)
del(c[self.e][self.f],self)
del(bf,self)
end,
}
add(bf,lm)
return lm
end
function lj()
for cd=1,12 do
ch(ll("wall_right"),{"wall_right"})
end
for cd=1,9 do
ch(ll("wall_down"),{"wall_down"})
end
end
function lk()
local kz={{1,1}}
local la={}
local lw={}
for e=1,b do
lw[e]={}
for f=1,a do
lw[e][f]=false
end
end
while#kz>0 do
for fm in all(kz) do
local gv=gw(fm)
local lx=fm[1]
local ly=fm[2]
lw[lx][ly]=true
for bl in all(gv) do
if lw[bl[1]][bl[2]]==false then
if ke(la,bl)==false then
add(la,bl)
end
end
end
end
kz=la
la={}
end
for bl in all(d) do
if lw[bl[1]][bl[2]]==false then
return false
end
end
return true
end
function bv(lz)
local lz=lz or{}
if#bg==0 then
bg={008,008,008,009,011,012}
cq(bg)
end
for bl in all(z) do
bl:bo()
end
if#ba==a*b-4 then
for cd=1,2 do
local ma={
e=eo,
f=eo,
cw={},
type="exit",
dx=function(self)
palt(015,true)
local fp=self.cw[1][1]
local fq=self.cw[1][2]
spr(020,fp,fq)
pal()
end,
}
add(bb,ma)
ch(ma,{"button","hero","exit"})
end
return
end
local mb={008,009,011,012}
del(mb,bg[1])
del(bg,bg[1])
local z={mc(mb[1]),mc(mb[2]),mc(mb[3])}
if#lz>0 then
cq(lz)
for cd=1,#z do
bt(z[cd],lz[cd])
end
else
local md={}
for bl in all(d) do
if
not bn("pad",bl) and
not bn("button",bl) and
not bn("hero",bl)
then
add(md,bl)
end
end
local me={}
for bl in all(md) do
if
gh(bp.gi,bl)>=3 and
gh(br.gi,bl)>=3
then
add(me,bl)
del(md,bl)
end
end
local mf={}
for bl in all(md) do
if
gh(bp.gi,bl)>=2 and
gh(br.gi,bl)>=2
then
add(mf,bl)
del(md,bl)
end
end
cq(me)
cq(mf)
cq(md)
for cd=1,#z do
if me[1] then
bt(z[cd],me[1])
del(me,me[1])
elseif mf[1] then
bt(z[cd],mf[1])
del(mf,mf[1])
else
bt(z[cd],md[1])
del(md,md[1])
end
end
end
end
function mc(color)
local iz=en()
iz.eq={016}
iz.type="pad"
iz.color=color
iz.dw=z
iz.dx=function(self)
local fo=self.eq[1]
local fp=self.cw[1][1]
local fq=self.cw[1][2]
palt(015,true)
palt(000,false)
pal(006,color)
spr(fo,fp,fq)
self:er()
end
add(z,iz)
return iz
end
function mg(color,mh,bz)
local hh=en()
local fx=mh or 0
local bz=bz or-8
hh.type="charge"
hh.color=color
hh.dw=be
hh.bz=bz
hh.n=q+fx
hh.dx=function(self)
if self.n>0 then
self.n-=1
else
palt(015,true)
palt(000,false)
pal(006,color)
pal(005,ir(color))
local fp=self.cw[1][1]
local fq=self.cw[1][2]-2
spr(019,fp,fq+self.bz)
self.bz=min(self.bz+1,0)
pal()
end
end
add(be,hh)
return hh
end
function kr(color)
local em=en()
local eq
local hi
if color==011 or color==012 then
eq=ij({ha({018},12),ha({016},9),ha({018},6),ha({016},3),{018}})
hi=function(self,mh,bz)
return
end
elseif color==008 or color==009 then
eq=ij({ha({028},12),ha({016},9),ha({028},6),ha({016},3),{017}})
hi=function(self,mh,bz)
bt(mg(color,mh,bz),cz(self))
end
end
em.eq=eq
em.type="button"
em.color=color
em.dw=ba
em.hi=hi
em.ch=function(self,cz)
bt(self,cz)
self:hi(26,0)
end
em.dx=function(self)
local fo=self.eq[1]
local fp=self.cw[1][1]
local fq=self.cw[1][2]
palt(015,true)
palt(000,false)
pal(006,color)
pal(005,ir(self.color))
spr(fo,fp,fq)
self:er()
end
add(ba,em)
return em
end
__gfx__
ffffffffff000fffffffffffffffffffffffffffffffffffffffffff00000707007000700007070000070070ffffffff00000000000000000000000000000000
ffffffffff070ffffff6fffffff555ffffffffffffffffffffffffff70070007700000000070000700700700ffffffff00000000000000000000000000000000
ff000fff0007000ffff6ffffff5565ffff565fffffffffffffffffff00700707000707000700707007000007ffffffff00000000000000000000000000000000
0007000f0777770fffffffffff6556fff55555fffff6ffffffffffff00007007007000700007000000007000ff666fff00000000000000000000000000000000
0777770f0007000f66fff66fff5565fff56565ffff666ffffff6ffff00700707700070000700070700700070ff666fff00000000000000000000000000000000
0007000ff07070fffffffffffff555fff55655fffff6ffffffffffff70070007070707070007000007000700ff666fff00000000000000000000000000000000
f07070fff07070fffff6ffffffffffffffffffffffffffffffffffff00000707000000000070070700070007ffffffff00000000000000000000000000000000
f00000fff00000fffff6ffffffffffffffffffffffffffffffffffff07007007777777770700700700000707ffffffff00000000000000000000000000000000
fffffffffffffffffff65fffffffffffffffffffffffffffffffffffffffffffffffffff000000fffffffffffffffffffff66fff000000000000000000000000
fffffffffffffffffff65ffffff77fffeeeeeeee00000fffffffffffffffffff000000ff077770ffffffffffffffffffff6765ff000000000000000000000000
fffffffffffffffffff65fffff7667ffeffffffe07070ffff0000fffffffffff077770ff007070ff000000ff00000fffff6665ff000000000000000000000000
f66ff66ffffffffff666555ff767657fefeeeefe07070fff077770fff0000fff007070ff077770ff077770ff07070ffffff55fff000000000000000000000000
f6ffff6ff6ffff5ffff66ffff766657fefeffefe077770ff077770ff077770ff077770ff007770ff007070ff07070ffff6ffff5f000000000000000000000000
fffffffff666555ff666555fff7557ffefeeeefe007070ff007070ff007070ff0077770ff077770f0777770f077770fff666555f000000000000000000000000
f6ffff6ffff66ffffff66ffffff77fffeffffffe077770ff0777770f077770fff070700ff070700f0707070f077770fffff66fff000000000000000000000000
f66ff66ff666555ff666555fffffffffeeeeeeee000000ff0000000f000000fff00000fff00000ff0000000f000000fff666555f000000000000000000000000
00000000000000b30000000000000000000000000000000000000000000000000000000000000000009900000000000000000000000000000000000000000000
00000000000000b30000000000000000000000000000000000000000000000000000000000000000097940000000000000000000000000000000000000000000
00000000000000b300000000000b0000000000000000000000000000000000000000000000000000099940000000000000000000000000000000000000000000
000000000000bbb333000000000b0000000000000000000000000000000000000000000000000000004400000000000000000000000000000000000000000000
00700000700000bb000077700bbbbb00077070700770077077700000000000070009000040077700900004007770077070007700000000000000000000000000
777770077700bbb333000000000b0000700070707070707007000000777700777009994440000000999444007000707070007070000000000000000000000000
00700000700000bb0000777000b0b000007077707070707007000000070700070000094000077700009900007070707070007070000000000000000000000000
070700000000bbb33300000000b0b000770070707700770007000000777700000009994440000000999444007770770077707700000000000000000000000000
00000000000000c10000000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000
00000000000000c10000000000000000000000000000000000000000000000000000000000000000087820000000000000000000000000000000000000000000
00000000000000c100000000000c0000000000000000000000000000000000000000000000000000088820000000000000000000000000000000000000000000
000000000000ccc111000000000c0000000000000000000000000000000000000000000000000000002200000000000000000000000000000000000000000000
00700000700000cc000077700ccccc00777070707770777000000000000000070008000020077700800002007070777077707000000000000000000000000000
777770077700ccc111000000000c0000070070707770707000000000777700777008882220000000888222007070770070707000000000000000000000000000
00700000700000cc0000777000c0c000070070707070777000000000070700070000088000077700008800007770700077707000000000000000000000000000
070700000000ccc11100000000c0c000770007707070700000000000777700000008882220000000888222007070777070707770000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000021515225052651522505215152250526515225051f5152150522515215051f5152150522515215051a5151d505215151d5051a5151d505215151d505185151a5051b5151a505185151a5051b5151a505
002000200e7550e7550e7550e7550e7550e7550e7550e7550e7550e7550e7550e7550e7550e7550e7550e75511755117551175511755117551175511755117551075510755107551075510755107550c7550c755
002000201d755000000000000000217550000000000000001d7550000000000000001d7550000000000000001d7550000000000000001a7550000000000000001d7550000000000000001d755000000000000000
0040002010037000071003700007100370000710037000071303718007130370000713037180071303700007150370c0071503700007150370c00715037000071d037000071c037000071a037000071803700007
004100001f0301f035000050000500005000052303023035210302103500005000050000500005260302603528030280350000000000000000000000000000000000000000000000000000000000000000000000
002000000254300500005000050013615176001760000500025430050000500005001361500500005000050002543005000050000500136150050000500005000254300500005000050013615005000050000500
0080001007745007000c7450070007745007000a7450070007745007000f7450070007745007000e7450070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00200000217150070518715007051f715007051b715007051d715007051b715007051f715007051a715007051d715007051a715007051f7150070518715007051a715007051b715007051f715007051a71500705
0020000021515225152651522515215152251526515225151f5152151522515215151f5152151522515215151a5151d515215151d5151a5151d515215151d515185151a5151b5151a515185151a5151b5151a515
0020000021515225152651522505215152250526515225051f5152151522515215051f5152150522515215051a5151d515215151d5051a5151d505215151d505185151a5151b5151a505185151a5051b5151a505
000800000f765027652670522705217052270526705227051f7052170522705217051f7052170522705217051a7051d705217051d7051a7051d705217051d705187051a7051b7051a705187051a7051b7051a705
000800000c7650276500705007052f705177051770500705027050070500705007052f705007050070500705027050070500705007052f705007050070500705027050070500705007052f705007050070500705
000400000c633076030c6330c62300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000c0000037140f7211b7312774133722337250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000306103065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000271201d121131210010300100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00080000000610006100065000000100003000040000a000090000100001000010000000000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000800000c0740f0741b0740000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
000800002774537735377350070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000800000363103625036150a60002603126052f60505605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
000400000c633075001b0302202535000120052f00505705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
00080000277152b51537715335053b505395050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
000800000c755027350c7000f7030d7030b7030970307703067030570304703037030370302703017030170301703017030170301703017030170301703017030170301703017030170301703017030170301703
000400000f715027150c715027150f715027150c71502715007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
010400001c7150371518715037151c715037151871503715007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
010c00000c7540f7341a7240f7040d7040b7040970407704067040570404704037040370402704017040170401704017040170401704017040170401704017040170401704017040170401704017040170401704
00200000037140f7211b7312774133722337250000000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000000000000000
000600000f0330c613130331f60300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300000
010c00002b15318133131130f1000d1040b1040910307103061030510304103031030310302103011030110301103011030110301103011030110301103011030110301103011030110301103011030110301103
000800000503105031050000500004700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010800000303103035000050200004001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
0108000008150160100c6000c6000c6000e6000e60010600106001060011600176001560013600116000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010800000f7330c61313703056031d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001b7501d7501b750207001c700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010400000305103051006230002100051000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 07 42 43 44
01 07 08 43 06
00 07 08 01 06
00 07 08 0a 06
00 07 42 09 44
00 07 08 09 44
00 07 08 09 06
02 07 08 01 06
00 41 42 43 44
00 41 42 43 44
04 41 42 43 44
04 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
