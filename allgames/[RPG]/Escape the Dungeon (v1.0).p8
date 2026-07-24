pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
a,b,c,d,e,f,g,h,i,j,k,l={},0,{},{},{},0,46,0,false,{"","cl","st","dx","iq","sk"},0,{"plane: air","plane: earth","plane: ice","plane: fire"}
function m(n)
o=p(n)
q(o,{"continue"},nil,r,true)
end
function _init()
s,t,u,d,v,w,x,y,z,ba,bb,bc,bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx=by("1,4,5,2,12,9,6,8",","),1,8,{},{},0,0,0,-1,0,0,0,0,{},54,12,0,0,0,-1,1,0,0,{},0,1,false,0,nil,false,0,0,0,1
bz()
for ca=0,3 do
cb(ca*32,0,32,ca+1)
end
for cc=0,31 do
c[cc]={}
for cd=0,127 do
c[cc][cd]=0
end
end
ce()
o=p({"pick your party:"})
q(o,{"the a team","pure hearts","hunting party","team divine"},nil,cf,false)
music()
end
function cf(ca,n)
ce()
cg(ca)
ch,u={},0
ci("your party awakes|in the dark.|the only way out|is down through|the planes of|existance.| |better light a|torch!|z: map/cancel|x: menu/sel")
m(ch)
end
function cj(cd,cc,ck)
for ca=cd,cd+ck-1 do
for cl=cc,cc+ck-1 do
mset(ca,cl,16)
if(cm(15)) mset(ca,cl,17)
end
end
end
function cn(cd,cc,ck,co,cp)
for ca=1,cp do
cq,cr=cs(co),cs(co)
ct,cu=cs(ck-cq-2)+cd,cs(ck-cr-2)+cc
for cv=0,cq-1 do
for cw=0,cr-1 do
mset(cv+ct,cw+cu,2)
end
end
end
end
function cm(cx)
if(rnd(100)<cx) return true
return false
end
function cy(ck,cz)
if(cz>0 and cz<ck-1) return true
return false
end
function da(ck,cz)
if(cm(50)) return 1
return-1
end
function db(ct,cu,cd,cc,ck,dc)
for cl=1,cs(dc)+9 do
if cm(50) then
if dd!=0 then
if(cy(ck,ct+dd)) ct+=dd
if(cm(15)) dd=0
else
de=da(ck,ct)
if(de!=0) dd=de
if(cy(ck,ct+dd)) ct+=dd
end
else
if df!=0 then
if(cy(ck,cu+df)) cu+=df
if(cm(15)) df=0
else
dg=da(ck,cu)
if(dg!=0) df=dg
if(cy(ck,cu+df)) cu+=df
end
end
if mget(ct+cd,cu+cc)>15 then
mset(ct+cd,cu+cc,1)
elseif mget(ct+cd,cu+cc)==2 then
break
end
end
end
function dh(cd,cc,ck,dc,cp)
for ca=1,cp do
ct,cu,dd,df=cs(ck-2),cs(ck-2),0,0
if mget(ct+cd,cu+cc)==2 then
db(ct,cu,cd,cc,ck,dc)
end
end
end
function di(cd,cc,ck,ca,n)
ct,cu=-1,-1
while(ct<0) do
ct,cu=cs(ck-2)+cd,cs(ck-2)+cc
if mget(ct,cu)<3 then
mset(ct,cu,ca)
if ca==3 then
w,x=ct,cu
elseif ca==7 then
add(d,{n=n,cd=ct-cd,cc=cu})
end
else
ct=-1
end
end
end
function dj(cd,cc,ck,n)
for dk in all(d) do
if dk.n==n-1 then
db(dk.cd,dk.cc,(n-1)*ck,0,32,6)
mset(dk.cd+(n-1)*ck,dk.cc,6)
end
end
end
function dl(dm,co,ca,cd,cc,ck)
for cl=1,dn(dm,co) do
di(cd,cc,ck,ca,2)
end
end
function cb(cd,cc,ck,n)
cj(cd,cc,ck)
if n<3 then
cn(cd,cc,ck,4,60)
dh(cd,cc,ck,20,425)
else
cn(cd,cc,ck,3,48)
dh(cd,cc,ck,25,600)
end
if n==1 then
di(cd,cc,ck,3,n)
end
di(cd,cc,ck,7,n)
if n>1 then
dj(cd,cc,ck,n)
dl(4,10,12,cd,cc,ck)
end
dl(12-n,13,8,cd,cc,ck)
dl(4,8,9,cd,cc,ck)
dp=(n-1)*10+9
a[n]=dn(dp,dp+1)
a[n+4],a[n+8]=dq(n+1,n+1,1,6),dq(n+1,n+1,1,6)
end
function dr()
rect(0,0,127,127,5)
for cc=0,31 do
for cd=0,31 do
ds,dt,du=cd*4,cc*4,cd+ba*32
dv=c[cc][du]
if dv>0 then
dw=13
if(dv>1) dw=6
rectfill(ds,dt,ds+3,dt+3,dw)
dx=mget(du,cc)
if dx>15 then
rectfill(ds,dt,ds+3,dt+3,5)
end
if dv>1 then
if dx>3 and dx<13 then
sspr((dx-4)*4,16,4,4,ds,dt)
end
end
if(w==cd and x==cc) sspr(48,16,4,4,ds,dt)
end
end
end
end
function dy(cq,dz,ea,cx)
eb,ec,ed,ee=64,1,32,false
if(cq>1) cq,eb=cq-2,96
ef=cq*64
if cx>0 then
ef+=32
ed=8
if abs(ea)>1 then
ed=24
ef+=8
if(abs(ea)>2) ec=1.75
end
end
eg=0.125*2^(4-dz)
eh,ei=eg*32,eg*32
ej,ek=27-(eh/2)+ea*eh,35-(ei/2)
if cx==1 then
ej+=eh
eh=ed*eg*ec
elseif cx==2 then
ee,eh=true,ed*eg*ec
ej-=eh
end
sspr(ef,eb,ed,32,ej,ek,eh,ei,ee,i)
i=false
end
function el(dz)
bj,bk,bl,bm=0,-1,1,0
if y==2 then
bk,bl=1,-1
elseif y==1 then
bj,bk,bl,bm=1,0,0,1
elseif y==3 then
bj,bk,bl,bm=-1,0,0,-1
end
end
function em(dz,cq)
return mget(mid(0,w+bj*dz+cq*bl,31)+ba*32,mid(0,x+bk*dz+cq*bm,31))
end
function en()
el(y)
if ba==1 then
pal(11,4)
pal(3,5)
elseif ba==2 then
pal(8,12)
pal(2,1)
pal(11,6)
pal(3,7)
elseif ba==3 then
pal(8,9)
pal(11,8)
pal(3,2)
end
for dz=z,0,-1 do
if dz<4 then
for cq=6,1,-1 do
dx=em(dz,-cq)
if(dx>15) dy(dx-16,dz,-cq,1)
dx=em(dz,cq)
if(dx>15) dy(dx-16,dz,cq,2)
end
end
if(dz>0) then
eo=-8
for cq=eo,-eo do
dx=em(dz,cq)
if dx>15 then
dy(dx-16,dz,cq,0)
elseif dx==7 then
dy(2,dz,cq,0)
elseif dx==6 then
i=true
dy(2,dz,cq,0)
elseif dx==8 then
dy(3,dz,cq,0)
end
end
end
end
pal()
end
function ep(cd,cc,ch,cx)
for cp in all(ch) do
print(cp,cd,cc,cx)
cc+=6
end
bh=cc
end
function eq(ch,er)
if not br then
bn,bo,br=75,{},true
end
for cp in all(ch) do
add(bo,cp)
end
add(bo,"")
bs,bt=(#ch+1)*6,er
end
function es()
clip(bf,bg,72,76)
ep(bf,bg+bn,bo,7)
end
function et()
o=e[#e]
if(o.ch!=nil) ep(bf,bg,o.ch,7)
clip(bf,bg+7,72,69)
if(o.eu!=nil) ev(o.eu,bh+2)
end
function _draw()
cls(0)
clip()
if(bu) then
dr()
return
end
rect(0,0,127,8,5)
print("escape the dungeon",2,2,7)
rect(0,10,127,89,5)
rect(0,91,127,127,5)
print("name     ac  cl hp      sp",2,93,6)
ew=93
for cz in all(ex) do
ew+=7
dw=cz.dw
if cz.ey>0 then
cz.ey-=1
if(cz.ey==0) cz.ez=7
elseif cz.stat>0 then
cz.ez=8
if(cz.stat==99) dw="de"
end
print(cz[1],2,ew,cz.ez)
print(cz.fa,38,ew)
print(dw,54,ew)
print(cz.fb.."/"..cz[7],66,ew)
print(cz.fc.."/"..cz[8],98,ew)
end
rect(0,10,52,61,5)
rect(0,61,52,89,5)
spr(60+y,2,64)
if z>0 then
spr(g,44,63)
if k%2==0 then
g+=1
if(g>50) g=46
end
end
if bb<0 then
spr(31,28,63)
end
if(bc>0) spr(45,36,63)
print(l[ba+1],2,73,7)
clip(2,13,49,47)
if u>0 then
if u>68 then
pal(1,s[ba+1])
pal(12,s[ba+5])
end
spr(u,10,19,4,4)
else
en()
end
pal()
clip()
if br then
es()
return
end
if#e>0 then
et()
else
ep(bf,bg,be,7)
end
end
function fd(cc,cd,ca)
c[cc][cd]=bor(c[cc][cd],ca)
end
function fe(dz,ff)
for cc=max(0,x-dz),min(31,x+dz) do
for cd=max(0,w-dz),min(31,w+dz) do
fd(cc,cd+ba*32,ff)
end
end
end
function fg()
fd(x,w+ba*32,2)
fe(1,2)
end
function fh()
cz=ex[bv]
return{cz[1].."  cl: "..cz.dw,"ar: "..cz.fi[1].fj[1],"sh: "..cz.fi[2].fj[1],"rn: "..cz.fi[3].fj[1],"hm: "..cz.fi[4].fj[1],"gv: "..cz.fi[5].fj[1],"wp: "..fk(cz.fi[6].fj)}
end
function fl()
cz=ex[bv]
return{cz[1].."  cl: "..cz.dw,"level: "..cz.fm,"xp: "..cz.cv,"next lv: "..cz.fn,"st: "..cz[3].." dx: "..cz[4],"sk: "..cz[6].." iq: "..cz[5],"hide shdws: "..cz[9].."%"}
end
function fo(fp)
ew={}
for cz in all(ex) do
if(cz.stat<fp) add(ew,cz[1])
end
return ew
end
function fk(fj)
if fj[6]==6 then
return fj[1].." "..fj[5].."0'"
end
return fj[1]
end
function fq(dw,fr,fs,ft,cq,er)
ff,n,ca,cl={},{},1,1
for fj in all(ex.fu) do
if fj.fj[6]>=dw and fj.fj[6]<=fr and band(fj.fj[2],fs)>0 and fj.fv<=ft then
if band(cq,fj.fj[14])==cq then
ff[ca],n[ca]=fk(fj.fj),cl
ca+=1
end
end
cl+=1
end
o=p({"select:"})
q(o,ff,n,er,true)
end
function fw(ca,n)
eo,n,bv={"inventory","use item","move up","move back"},{1,2,4,5},ca
o=fx(fl)
if ex[bv].fc>0 then
add(eo,"cast spell")
add(n,3)
end
q(o,eo,n,fy,true)
end
function fz(ca,n)
if ca==1 then
ga(1)
end
ce()
end
function gb(ca,n)
if ca==1 then
ga(-1)
end
ce()
end
function gc(gd,er)
ff,n,ca={},{},1
for dk in all(ex[bv].ge) do
if band(dk[5],gd)>0 then
if dk[4]<=ex[bv].fc then
ff[ca],n[ca]=dk[4].."|"..dk[1].." "..max(1,gf[dk[6]][3]).."o'",dk
ca+=1
end
end
end
o=p({"select:"})
q(o,ff,n,er,true)
end
function fy(ca,n)
cz=ex[bv]
if n==1 then
o=fx(fh)
q(o,{"equip","view item","unequip all"},nil,gg,true)
elseif n==2 then
fq(50,255,2^cz[2],0,1,gh)
elseif n==3 then
gc(1,gi)
elseif n==4 then
bv=gj(cz,-1)
ce()
elseif n==5 then
bv=gj(cz,1)
ce()
end
end
function gg(ca,n)
cz=ex[bv]
if ca==1 then
fq(0,49,2^cz[2],0,0,gk)
elseif ca==2 then
fq(0,7,63,999,0,gl)
elseif ca==3 then
for cl=1,6 do
cz.fi[cl].fv,cz.fi[cl]=0,gm()
end
gn()
go()
end
end
function gk(ca,n)
gp(bv,n)
gq()
end
function gr(ch,gs,ff)
if(gs>0) add(ch,gt[gs]..ff)
end
function gl(ca,n)
fj=ex.fu[n].fj
ch={fj[1],"type:"..gu[fj[6]],"ac: "..fj[3],"dmg: "..fj[4].." x d4"}
if(fj[6]==6) add(ch,"range: "..fj[5].."0'")
add(ch,"special effects")
o=p(ch)
gr(ch,fj[10],fj[11])
gr(ch,fj[12],fj[13])
q(o,{"continue"},nil,gv,true)
end
function gv(ca,n)
gq()
end
function gw(er,n)
h,o=n,p({"target:"})
q(o,fo(100),nil,er,true)
end
function gh(ca,n)
gx=gf[ex.fu[n].fj[10]]
if gx[2]==1 then
gw(gy,n)
else
gz(bv,n)
ce()
end
end
function gy(ca,n)
gz(bv,h,ex[ca])
ce()
end
function gi(ca,n)
gx=gf[n[6]]
if gx[2]==1 then
gw(ha,n)
else
hb(ex[bv],n,nil)
ce()
end
end
function ha(ca,n)
hb(ex[bv],h,ex[ca])
ce()
end
function hc(ca,n)
_init()
end
function hd()
el(y)
be={}
for ca=1,bc do
dx=em(ca,0)
if(dx>3 and dx<15) add(be,he[dx-3])
end
end
function _update()
if bu then
if(btnp()>0) bu=false
return
end
k+=1
if bi==1 then
ce()
o=p({"thou art slain"})
q(o,{"fight again"},nil,hc,false)
br=false
end
if br then
hf()
return
elseif#e>0 then
hg()
return
end
f+=1
if f>1790 then
f=0
for eo=1,#v do
hh=v[eo]
if hh!=nil then
hh[2]-=1
if hh[2]<1 then
hi=hh[1]
del(v,hh)
if hi==3 then
bb=0
elseif hi==4 then
bc=0
else
z=-1
end
eo-=1
end
end
end
end
fg()
dx=em(0,0)
if f%300==0 and(dx<4 or dx>8) then
hj=40
if(ex[1].fm>=(ba+1)*3) hj=5
if cm(hj) then
hk(0)
f+=1
return
end
end
if bd%30==0 then
if dx==12 then
z,be=-1,{"darkness!"}
elseif dx==9 then
for cz in all(ex) do
hl(cz,(ba+1))
end
elseif dx==6 and b<1 then
o=p({"there are stairs","up here.","take them?"})
q(o,{"yes","no"},nil,gb,true)
b=80
return
elseif dx==7 and b<1 then
if a[ba+1]==0 then
o=p({"there are stairs","down here.","take them?"})
q(o,{"yes","no"},nil,fz,true)
b=80
return
else
hk(a[ba+1])
b=80
return
end
elseif dx==8 then
hk(0)
b,hm=80,true
mset(w+ba*32,x,1)
end
end
bd+=1
if(b>0) b-=1
if btnp(2) then
el(y)
w+=bj
x+=bk
if em(0,0)>15 then
w-=bj
x-=bk
be={"ouch!"}
else
bd=0
hd()
end
elseif btnp(0) then
y-=1
if(y<0) y=3
hd()
elseif btnp(1) then
y+=1
if(y>3) y=0
hd()
end
if(btnp(4)) bu=true
if btnp(5) then
o=p({"choose:"})
q(o,fo(90),nil,fw,true)
end
end
function ga(ca)
ba+=ca
bd=20
end
fi,gf,ge,he,hn,gu,gt={},{},{},{},{},{"armour","shield","ring","helm","gloves","weapon"},{"ac: ","to hit bonus: ","resist magic: ","initiative: ","dmg mult: ","attk magic: ","hide shdw: "}
function ho(hp,hq)
hr=by(hq,"\n")
for ca=1,#hr do
cx=by(hr[ca],",")
hp[ca]=cx
end
end
function bz()
ho(fi,[[
none,63,0,1,1,0,0,0,5,0,0,0,0,0, hands
robes,63,-1,0,1,1,1,50,5,0,0,0,0,0, 
leather armour,31,-2,0,1,1,1,40,5,0,0,0,0,0, 
dagger,63,0,2,1,6,1,60,5,0,0,0,0,0, 
torch,63,0,0,0,50,1,30,5,1,0,0,0,1, 
herb,63,0,0,0,60,1,50,5,4,0,0,0,3,+hp 
party herb,63,0,0,0,60,1,20,5,5,0,0,0,3,+hp 
lantern,63,0,0,0,50,1,30,5,2,0,0,0,1, 
dynamite,63,0,0,0,50,1,30,5,9,0,0,0,1, 
tnt,63,0,0,0,50,2,30,5,10,0,0,0,1, 
reveal gem,63,0,0,0,50,2,30,5,11,0,0,0,1, 
reveal2 gem,63,0,0,0,50,3,30,5,12,0,0,0,1, 
chain mail,31,-3,0,1,1,1,40,5,0,0,0,0,0, 
short sword,63,0,3,1,6,1,50,5,0,0,0,0,0, 
short bow,63,0,2,3,6,1,50,5,0,0,0,0,0, 
long bow,23,0,3,6,6,2,50,5,0,0,0,0,0, 
super p herb,63,0,0,0,60,2,15,5,35,0,0,0,3,+hp
super herb,63,0,0,0,60,2,20,5,36,0,0,0,3,+hp
mighty p herb,63,0,0,0,60,2,20,5,37,0,0,0,3,+hp
mighty herb,63,0,0,0,60,2,25,5,38,0,0,0,3,+hp
ult. p herb,63,0,0,0,60,4,15,5,39,0,0,0,3,+hp
ult. herb,63,0,0,0,60,3,25,5,40,0,0,0,3,+hp
hero p herb,63,0,0,0,60,4,15,5,41,0,0,0,3,+hp
broad sword,23,0,4,1,6,1,26,5,0,0,0,0,0, 
thief dagger,8,-1,3,1,6,3,13,5,2,25,2,1,0, 
halberd,7,0,6,1,6,2,50,5,0,0,0,0,0, 
scale armr,23,-4,0,0,1,2,50,5,0,0,0,0,0, 
plate armr,7,-5,0,0,1,2,40,5,0,0,0,0,0, 
elf cloak,63,-4,0,0,1,3,30,5,3,2,0,0,0, 
helm,31,-1,0,0,4,1,60,5,0,0,0,0,0,  
mthrl helm,31,-2,0,0,4,2,40,5,0,0,0,0,0, 
rage helm,1,-2,0,0,4,2,20,5,5,0.5,0,0,0, 
guantlets,3,-1,0,0,5,1,60,5,0,0,0,0,0,  
leath. gloves,31,-1,0,0,5,1,60,5,0,0,0,0,0,  
buckler,31,-1,0,0,2,1,60,5,0,0,0,0,0, 
tower shield,31,-2,0,0,2,2,50,5,0,0,0,0,0, 
hero shield,7,-2,0,0,2,2,30,5,2,1,0,0,0, 
mage gem,50,0,0,0,70,2,32,5,42,0,0,0,3,+sp
mage staff,32,-1,2,1,6,1,15,5,6,1,0,0,0, 
shdw dagger,8,-1,2,1,6,1,12,5,7,25,0,0,0, 
luck shield,31,-1,0,0,2,1,15,5,2,1,3,2,0, 
battle gloves,3,-1,0,0,5,1,15,5,2,1,5,0.2,0, 
stealth ptn.,8,0,0,1,50,1,40,5,24,0,0,0,3, 
life gem,63,0,0,1,60,1,35,5,43,0,0,0,3, 
true bow,20,0,2,3,6,1,15,5,2,1,4,2,0, 
mage cloak,32,-3,0,0,1,1,15,5,3,2,0,0,0, 
thors hammer,7,0,4,1,6,1,15,5,2,1,4,2,0, 
str. mage gem,50,0,0,0,70,3,25,5,59,0,0,0,3,+sp
stealth ptn.,8,0,0,1,50,3,40,5,24,0,0,0,3, 
life gem,63,0,0,1,60,3,25,5,43,0,0,0,3, 
dark dagger,8,-2,5,1,6,3,15,5,2,3,4,5,0, 
master cloak,32,-4,0,0,1,3,15,5,3,3,6,2,0, 
hunters bow,4,-1,5,8,6,3,15,5,2,2,4,2,0, 
odins hammer,23,0,6,1,6,3,15,5,2,1,4,3,0, 
master staff,32,-2,3,1,6,3,15,5,6,2,4,2,0, 
battle shield,31,-3,0,0,2,3,15,5,2,2,3,2,0, 
rage gloves,1,-2,0,0,5,3,15,5,2,2,5,0.3,0, 
hero helm,1,-2,0,0,4,3,20,5,2,1,4,2,0, 
mthrl plate,3,-6,0,0,1,3,30,5,0,0,0,0,0, 
hunters scale,4,-6,0,0,1,3,30,5,0,0,0,0,0, 
rogue cloak,8,-5,0,0,1,3,30,5,7,5,4,2,0, 
blood dagger,8,-2,6,1,6,4,15,5,2,3,4,5,0, 
sage cloak,32,-5,0,0,1,4,15,5,4,3,6,2,0, 
power bow,23,0,7,8,6,4,30,5,2,1,4,1,0, 
moon hammer,17,0,8,1,6,4,30,5,3,3,0,0,0, 
first blade,23,0,7,1,6,4,20,5,4,8,0,0,0, 
inv. ring,63,-1,0,1,3,1,15,5,4,1,0,0,0, 
resist ring,63,0,0,1,3,1,20,5,3,1,0,0,0,
dork ring,63,1,0,1,3,1,30,5,2,-2,0,0,0,
strike ring,31,0,0,1,3,2,20,5,4,1,2,1,0,
cast ring,50,0,0,1,3,2,20,5,6,1,0,0,0,
dork ring,63,1,0,1,3,3,25,5,2,-2,0,0,0,
master ring,50,-2,0,1,3,4,10,5,3,2,6,1,0,
rage ring,15,1,0,1,3,3,25,5,5,0.5,0,0,0,
battle ring,23,0,0,1,3,4,15,5,5,0.2,2,2,0,
shadow ring,8,0,0,1,3,1,15,5,7,20,4,1,0,
thief ring,8,0,0,1,3,3,15,5,7,10,4,2,0,
quick ptn.,63,0,0,1,50,2,40,5,21,0,18,0,3, 
resist ptn.,63,0,0,1,50,2,40,5,63,0,0,0,3, 
battle ptn.,63,0,0,1,50,2,40,5,19,0,22,0,3, 
cast ptn.,63,0,0,1,50,2,40,5,64,0,0,0,3, 
divine ring,16,-1,0,1,3,3,10,5,3,2,6,2,0,
pure ring,2,0,0,1,3,2,15,5,6,2,2,2,0,
pure ring,2,-1,0,1,3,4,15,5,6,2,2,2,0,
pure helm,2,-2,0,0,4,3,15,5,2,1,4,2,0, 
divine helm,16,-2,0,0,4,3,15,5,2,1,4,2,0, 
pure shield,2,-2,0,0,2,2,15,5,2,1,6,1,0, 
divine shield,16,-3,0,0,2,4,15,5,3,1,4,1,0, 
cross bow,23,0,4,7,6,2,50,5,0,0,0,0,0, 
pure blade,2,0,4,1,6,1,15,5,2,1,3,1,0, 
pure blade,2,0,4,1,6,2,20,5,2,1,3,1,0, 
palins blade,2,-1,8,1,6,4,20,5,2,2,3,2,0, 
divine blade,16,0,4,1,6,2,20,5,6,1,3,1,0, 
divine bow,16,0,5,7,6,3,20,5,2,2,6,2,0, 
clerics bow,16,0,7,8,6,4,20,5,2,2,6,3,0, 
divine ring,16,-1,0,1,3,1,10,5,3,2,6,2,0,
clerics armr,16,-5,0,0,1,3,20,5,3,1,0,0,0, 
pure armr,2,-6,0,0,1,3,20,5,3,1,0,0,0, 
str. mage gem,50,0,0,0,70,4,30,5,59,0,0,0,3,+sp
casters helm,48,-2,0,0,4,3,20,5,3,1,4,2,0, 
casters gloves,48,-2,0,0,5,2,20,5,3,1,0,0,0, 
mage dagger,32,-1,6,1,6,4,20,5,2,3,4,5,0, 
mage bow,32,0,3,6,6,2,20,5,6,2,2,2,0,   
]])
ho(gf,[[
1,5,2,3,0,0,0
1,5,3,5,0,0,0
1,5,4,10,0,0,0
2,1,0,0,0,4,8
2,5,0,0,0,8,12
3,5,0,5,0,-3,0
4,5,3,4,0,0,0
4,5,5,8,0,0,0
5,5,3,0,0,0,0
5,5,5,0,0,0,0
6,5,4,0,0,0,0
6,5,6,0,0,0,0
7,1,1,0,0,1,2
7,1,1,0,0,2,4
7,1,1,0,0,4,8
8,2,3,0,1,4,8
8,3,3,0,16,10,16
9,1,1,0,1,1,-3
9,1,1,0,1,2,8
9,5,1,0,1,3,10
9,1,1,0,1,4,15
9,1,1,0,1,5,0.5
9,1,3,0,1,4,15
9,1,3,0,1,7,60
10,3,9,0,1,7,1
7,1,1,0,0,1,2
7,1,1,0,0,2,6
7,1,1,0,0,4,8
7,1,3,0,0,2,4
7,1,6,0,0,2,4
7,5,3,0,1,2,8
7,1,3,0,1,1,2
9,3,6,0,1,6,-10
11,5,1,0,1,0,0
2,5,0,0,0,16,24
2,1,0,0,0,16,24
2,5,0,0,0,24,48
2,1,0,0,0,24,48
2,5,0,0,0,50,100
2,1,0,0,0,50,100
2,5,0,0,0,200,300
12,1,0,0,0,32,64
2,1,0,0,0,999,999
14,3,6,0,0,-6,-6
14,3,3,0,0,6,6
7,1,1,0,0,6,10
7,1,1,0,0,8,12
7,1,1,0,0,12,20
7,1,1,0,0,16,24
7,1,1,0,0,20,28
7,1,4,0,0,8,12
7,1,6,0,0,12,16
7,5,3,0,1,8,16
7,1,3,0,1,10,16
9,3,6,0,1,2,-8
9,3,6,0,1,1,6
9,1,1,0,1,2,8
7,1,3,0,1,4,8
12,1,0,0,0,64,128
9,1,1,0,1,5,-0.5
10,3,9,0,1,13,1
9,1,1,0,1,4,-10
9,1,1,0,1,3,8
9,1,6,0,1,6,6
8,2,6,0,8,8,16
2,1,0,0,0,200,300
10,3,9,0,1,27,1
7,5,5,0,1,24,32
7,1,3,0,0,32,48
7,1,1,0,0,64,80
7,5,6,0,1,16,24
7,1,1,0,0,20,28
9,5,1,0,1,1,3
9,1,1,0,1,1,3
10,3,9,0,1,37,1
7,1,1,0,0,16,24
8,3,3,0,2,12,24
8,3,6,0,4,24,36
9,3,6,0,1,4,-15
9,5,1,0,1,4,15
9,5,1,0,1,2,8
9,1,1,0,1,5,2
8,3,6,0,8,48,64
8,3,4,0,8,64,128
9,5,1,0,1,1,-3
8,2,7,0,4,96,128
8,2,3,0,1,20,36
]])
ho(ge,[[
flame,48,1,2,1,1,0,light!
quick fix,48,1,2,3,4,0,+hp
arc fire,32,1,2,2,16,0,fries
sight,48,2,3,1,7,0,sight!
boom,34,2,5,1,9,0,kaboom!
anti magic,34,2,3,2,33,0,-am
confuse,48,2,3,2,55,56,-thb +ac
reveal,34,3,5,2,11,0,reveal!
resist mag.,34,3,5,2,20,0,+rm
cyclone,32,3,7,2,77,0,batters
stealth,34,3,3,2,24,57,+hs +thb
grapple,48,4,3,2,44,0,pulled closer
heal,48,4,4,3,38,0,+hp
mastr sight,48,4,5,1,8,0,sight!
blur,48,5,3,2,18,0,-ac
battleskill,34,6,3,2,19,22,+thb+dmm
mage strk,32,6,2,2,87,0,zaps
bright,34,5,3,1,3,0,light!
revive,48,4,11,3,43,0,revived!
party heal,48,6,8,3,37,0,+hp
earthquake,32,6,11,2,78,0,rumbles
mag. shield,48,7,6,1,6,0,-ac 
gr. reveal,34,7,7,1,12,0,reveal! 
freeze,32,7,3,2,56,79,+ac-init
big boom,34,8,7,1,10,0,kaboom!
far foe,48,7,4,2,45,0,pushed further
strikefirst,34,8,6,2,80,81,+init+thb
rage,32,9,7,2,82,0,+dmm
ice storm,32,9,15,2,83,0,freezes
restore,48,9,14,3,66,0,+hp
restore all,48,10,20,3,41,0,+hp
party blur,48,10,8,2,85,0,-ac
ice strike,32,11,9,2,86,0,freezes
obliterate,32,12,20,2,84,0,nukes
holy hold,16,7,3,2,56,79,+ac-init
godsmak,16,9,14,2,83,0,freezes
pure heart,2,9,5,2,82,81,+dmm+thb
]])
he=by([[
store near
temple near
stairs near
stairs near
chest near
danger near
special near
special near
light flickers
evil near
evil near]],"\n")
hr=by([[
air elementl,1,75,1,2,9,7,21,5,2,26,29,slams,flys by,3,0,1,3,72
cloud giant,1,50,2,3,9,7,20,-1,2,28,30,swings,throws,2,0,1,4,204
djinni,1,60,1,2,8,7,24,1,2,27,30,slams,blasts,2,0,1,3,196
air dragon,1,30,1,4,9,12,21,7,2,27,31,claws,breathes,3,0,1,2,76
hippogriff,1,75,1,1,8,6,22,-2,0,27,0,bites,n,2,0,1,2,204
wizard,1,65,2,2,9,5,21,1,0,26,25,swings,inv. stalker,2,0,1,4,72
inv. stalkr,1,10,1,1,7,4,23,-2,0,26,0,slams,n,1,1,1,2,72
air mephit,1,30,1,1,8,4,21,-2,2,26,32,claws,breathes,1,0,2,4,76
hydra,1,50,3,3,4,40,23,8,2,47,31,bites,breathes,10,3,1,1,76
wind mage,1,50,3,3,4,40,22,9,2,25,53,inv. stalker,fries,10,0,1,1,72
earth elmntl,2,70,1,6,7,13,22,9,4,27,51,slams,shakes,10,3,1,4,72
hill giant,2,55,3,6,7,9,22,0,4,48,30,clubs,throws,15,3,1,4,204
grimlock,2,40,1,2,7,9,21,-1,4,46,0,stabs,n,8,0,1,4,72
dirt dragn,2,30,3,6,5,16,22,10,4,27,53,claws,breathes,15,1,1,3,76
shrieker,2,70,2,3,8,12,20,2,4,60,61,shrieks,grimlock,8,1,2,4,72
earth mage,2,55,2,6,7,11,21,4,0,27,61,swings,grimlock,15,1,1,4,76
ghoul,2,35,2,4,4,12,23,7,0,28,0,bites,n,15,4,1,3,196
stone golem,2,40,1,1,6,14,21,1,4,46,62,slams,slows,15,3,1,2,204
gargoyle,2,10,5,6,2,75,25,12,4,46,53,claws,breathes,50,6,1,1,196
king kobold,2,10,5,6,2,75,25,9,4,48,51,stabs,spears,50,6,1,1,204
ice elemntl,3,40,3,8,5,21,23,10,8,28,52,slams,flys by,50,8,1,4,72
ice giant,3,70,3,6,4,20,22,1,8,48,30,swings,throws,70,6,2,4,204
frost worm,3,33,1,3,5,20,21,1,8,47,0,chews,n,50,5,2,4,72
stirge,3,25,3,7,6,22,20,12,0,27,53,claws,breathes,50,3,2,4,76
homonculus,3,75,1,3,5,24,24,0,0,28,0,bites,n,50,6,2,4,196
ice mage,3,65,3,6,6,19,20,6,8,46,67,swings,grter shadow,50,3,2,4,72
grter shadow,3,10,2,4,0,21,25,10,0,46,0,gropes,n,60,5,1,3,196
ice devil,3,40,1,5,3,25,23,10,8,47,58,slams,breathes,85,8,1,3,72
white dragon,3,40,4,4,0,145,27,12,8,72,71,claws,breathes,200,10,1,1,76
bone devil,3,40,1,1,-1,145,27,10,8,72,73,slams,freezes,250,10,1,1,72
fire elemntl,4,40,1,4,1,36,25,11,16,46,71,slams,burns,300,9,1,4,72
fire giant,4,70,1,6,2,34,25,2,16,48,51,swings,throws,325,8,2,4,204
rust monster,4,33,2,3,1,45,24,2,16,72,0,claws,n,350,11,1,4,204
phase spider,4,25,1,6,0,33,26,4,0,46,74,bites,webs,250,7,3,6,72
devourer,4,75,1,3,1,34,24,11,0,48,0,stares,n,300,10,2,4,196
red dragon,4,65,3,6,1,40,25,13,16,48,53,slams,breathes,350,6,2,4,76
imp,4,10,1,1,-2,35,27,4,0,46,0,slams,n,300,10,2,4,196
fire mage,4,40,2,6,5,35,26,10,16,54,75,burns,imp,300,5,1,4,196
erinyes,4,40,4,4,-7,340,29,16,16,70,68,claws,breathes,500,14,1,1,72
efreeti,4,40,3,3,-8,340,29,16,16,69,68,claws,breathes,500,16,1,1,204
]],"\n")
for ca=1,#hr do
cx=by(hr[ca],",")
cx.hs=1
hn[ca]=cx
end
end
ex,ht={},{}
hu={"el cid,0,12,10,8,10,15,0,0,0,0,0|grady,3,9,12,9,10,12,0,30,0,0,0|markus,2,10,10,10,12,14,0,0,0,0,0|merlin,5,8,10,12,9,12,16,0,0,0,0","the fist,1,11,12,9,11,15,9,0,0,0,0|pick,3,9,12,9,10,12,0,30,0,0,0|eve,2,10,10,10,12,14,0,0,0,0,0|carra,4,9,11,11,10,12,14,0,0,0,0","brian,1,11,12,9,11,15,9,0,0,0,0|chloe,4,9,11,11,10,12,14,0,0,0,0|sara,2,10,10,10,12,14,0,0,0,0,0|erron,2,11,10,9,12,13,0,0,0,0,0","joan,4,9,11,11,10,12,14,0,0,0,0|rathe,3,9,12,9,10,12,0,30,0,0,0|stryder,2,10,10,10,12,14,0,0,0,0,0|misha,5,8,10,12,9,12,16,0,0,0,0"}
hv={{5,0.2},{3,2},{2,2},{2,2},{3,3},{3,3}}
function hw(cz)
fa=9-flr((cz[4]-10)/2)
for fj in all(cz.fi) do
ft=fj.fj
fa+=ft[3]
hx(cz,ft[10],ft[11])
hx(cz,ft[12],ft[13])
end
cz.fa=fa+bb
end
function gn()
for cz in all(ex) do
hw(cz)
end
end
function hy()
bi,hz=1,1
for ca=1,4 do
ia=ex[hz]
if ia.stat==99 then
del(ex,ia)
add(ex,ia)
else
bi=0
hz+=1
end
end
end
function gj(ib,dz)
ic=id(ib)
ie=dz+ic
if(ie>4 or ie<1) return ic
ig=ex[ie]
ex[ie],ex[ic]=cz,ig
return ie
end
function hl(cz,ih)
if cz.stat<99 then
ih=ceil(ih/cz.ij)
cz.fb-=ih
ik=ih
if cz.fb<1 then
cz.fb,cz.stat,cz.il=0,99,{}
hy()
end
im(cz,-ih)
end
end
function io(cz,ih)
if cz.stat<99 then
cz.fb+=ih
if(cz.fb>cz[7]) cz.fb=cz[7]
im(cz,ih)
end
end
function im(cz,ih)
if ih<0 then
cz.ez=2
else
cz.ez=3
end
cz.ey=10
end
function ip(cz,ih)
cz.fc+=ih
if(cz.fc>cz[8]) cz.fc=cz[8]
im(cz,ih)
end
function iq(ca)
add(ex.fu,{fj=fi[ca],fv=0})
end
function gp(ca,ir)
cz=ex[ca]
is=ex.fu[ir]
local fj=is.fj
if fj[6]==2 and cz.fi[6].fj[5]>1 then
return
end
if band(fj[2],2^cz[2])>0 then
it=cz.fi[is.fj[6]]
if it.fj[6]!=0 then
it.fv=0
end
if is.fv>0 then
ex[is.fv].fi[is.fj[6]]=gm()
end
cz.fi[fj[6]]=is
is.fv=ca
if fj[6]==6 and fj[5]>1 then
cz.fi[2].fv,cz.fi[2]=0,gm()
end
gn()
end
end
function dn(dm,co)
return flr(rnd(co-dm+1))+dm
end
function gz(ca,ir,iu)
cz,fj=ex[ca],ex.fu[ir].fj
gx=iv(fj[10],iu)
del(ex.fu,ex.fu[ir])
return gx
end
function hb(cz,dk,iu)
gx=iv(dk[6],iu,4)
cz.fc-=dk[4]
return gx
end
function gm()
return{fj=fi[1],fv=0}
end
function iw(cz)
for ix in all(ge) do
if band(ix[2],2^cz[2])>0 and ix[3]==cz.fm then
add(cz.ge,ix)
end
end
end
function cg(iy)
iz=by("fi,pa,hu,ro,cl,mg",",")
dk=by(hu[iy],"|")
for ca=1,4 do
cx=by(dk[ca],",")
cx.fb,cx.fc,cx.fa,cx.dw=cx[7],cx[8],9,iz[cx[2]+1]
cx.ez,cx.ey,cx.fm,cx.cv,cx.fn,cx.stat=7,0,1,0,25,0
cx.fi={gm(),gm(),gm(),gm(),gm(),gm()}
cx.ge,cx.hs,cx.ij,cx.ja={},0,1,0
iw(cx)
jb(cx)
ex[ca]=cx
end
ex.fu={}
for fu in all({2,3,3,4,4,15,35,5,5,8,6,11,9,11,9,44,10}) do
iq(fu)
end
end
function by(dk,jc)
jd,je={},1
if sub(dk,1,1)=="\n"then
dk=sub(dk,2)
end
for ca=1,#dk do
if sub(dk,ca,ca)==jc or ca==#dk then
if(ca==#dk) ca+=1
jf=sub(dk,je,ca-1)
jg=tonum(jf)
if jg==nil then
add(jd,jf)
else
add(jd,jg)
end
ca+=1
je=ca
end
end
return jd
end
function p(ch)
o={ch=ch,eu=nil,jh=nil}
add(e,o)
return o
end
function fx(ji)
ch=ji()
o={ch=ch,eu=nil,jh=ji}
add(e,o)
return o
end
function jj(o)
del(e,o)
if#e>0 then
jk=e[#e]
if(jk.jh!=nil) jk.ch=jk.jh()
end
end
function gq()
jj(e[#e])
go()
end
function ce()
e={}
end
function go()
if#e>0 then
jk=e[#e]
if(jk.jh!=nil) jk.ch=jk.jh()
end
end
function q(o,jl,jm,jn,jo)
o.eu={jl=jl,jm=jm,jp=1,er=jn,jo=jo}
end
function hg()
o=e[#e]
eu=o.eu
if eu!=nil then
if btnp(2) then
if(eu.jp>1) eu.jp-=1
sfx(60)
elseif btnp(3) then
if(eu.jp<#eu.jl) eu.jp+=1
sfx(60)
elseif btnp(4) and eu.jo then
jj(o)
elseif btnp(5) then
sfx(61)
if(#eu.jl==0) jj(o) return
n=eu.jm
if(n!=nil) n=n[eu.jp]
eu.er(eu.jp,n)
end
else
if btnp(4) then
jj(o)
end
end
end
function ev(eu,cc)
ca=1
if eu.jp>11 then
cc-=6*(eu.jp-11)
end
for jq in all(eu.jl) do
cx=2
if(ca==eu.jp) cx=3
print(jq,bf,cc+(ca-1)*6,cx)
ca+=1
end
end
function hf()
bp-=1
if bs>0 then
if bp<1 then
bp=bq
bn-=t
bs-=t
if bn<-5 then
bn=0
del(bo,bo[1])
end
end
else
if bp<-(bq*8) then
bt()
bp=bq
end
end
if btnp(2) then
t+=0.5
if(t>2) t=0.5
end
end
function jr(il,gx)
add(il,{gx[1],gx[4]})
end
function iv(ir,iu,js)
gx,jt=gf[ir],js or 3
ju,ik,jv,jw,jx=gx[1],-1,gx[2],gx[6],gx[7]
jy=dn(jw,jx)
if ju==1 then
z=gx[3]
jr(v,gx)
elseif ju==2 then
if jv==1 then
if jw>400 then
if iu.stat==99 then
iu.stat,iu.fb=0,1
hy()
im(iu,1)
elseif jt==3 then
ip(iu,iu.fm*7)
io(iu,iu.fm*8)
end
else
io(iu,jy)
end
elseif jv==5 then
for cz in all(ex) do
io(cz,jy)
end
end
elseif ju==3 then
jr(v,gx)
bb=jw
gn()
elseif ju==4 then
jr(v,gx)
bc=gx[3]
elseif ju==5 then
jz(gx[3],1)
be={"boom!"}
elseif ju==6 then
fe(gx[3],1)
be={"map revealed!"}
elseif ju==7 then
hl(iu,jy)
elseif ju==8 then
if(band(gx[5],iu.eo[10])>0) jy/=2
ka(jy,iu)
elseif ju==9 then
kb(jv,iu,jw,jx)
elseif ju==10 then
kc(jw,jx)
elseif ju==12 then
ip(iu,jy)
elseif ju==14 then
kd=iu.kd
if(jw>0 or kd.jh>1) kd.stat=10
kd.jh+=jw
if(kd.jh>9) kd.jh=9
if(kd.jh<1) kd.jh=1
end
end
function jz(ke,kf)
for dz=1,ke do
for cq=-kf,kf do
cd,cc=mid(0,w+bj*dz+cq*bl,31)+ba*32,mid(0,x+bk*dz+cq*bm,31)
if(mget(cd,cc)>15) mset(cd,cc,1)
end
end
end
function kg(il,gs,ih)
for eo in all(il) do
if eo[1]==gs then
del(il,eo)
end
end
add(il,{gs,ih})
end
function kb(kh,iu,gs,ih)
if kh<4 then
kg(iu.il,gs,ih)
jb(iu)
elseif kh==5 then
for cz in all(ex) do
if(cz.stat<99) kg(cz.il,gs,ih)
jb(cz)
end
end
end
function kc(ca,jh)
eo,ki=hn[ca],0
for kj in all(kk) do
ki+=1
if kj.ca==ca then
kl(kj,ca)
return
end
end
if ki<4 then
km(ca,1,jh)
end
end
kn,kk,ko,kp,kq,kr,ks,hm,kt={},{},0,1,0,nil,false,0
function cs(dz,cp)
ff,cp=0,cp or 1
for ca=1,cp do
ff+=flr(rnd(dz))+1
end
return ff
end
function kl(kd)
eo=hn[kd.ca]
add(kd,{eo=eo,fb=cs(2,eo[7]),stat=0,kd=kd,il={}})
end
function km(ca,ki,jh)
kd={jh=jh,ca=ca}
for ku=1,ki do
kl(kd)
end
add(kk,kd)
return kd
end
function hk(kv)
kk,ks={},false
kw=min(4,cs(ba+2))
if kv>0 then
eo=hn[kv]
kw=max(1,kw-1)
kd=km(kv,dn(eo[17],eo[18]),eo[4])
ks=true
end
for ca=1,kw do
kx=true
while kx do
kx=false
cl=dn(1,8)+(ba*10)
for kj in all(kk) do
if(cl==kj.ca) kx=true
end
eo=hn[cl]
if(not cm(eo[3])) kx=true
end
jh=eo[4]
if(ca>1) jh=dn(jh,eo[5])
km(cl,dn(eo[17],eo[18]),jh)
end
ko=0
o=p(ky("death and drek|you curse."))
kz(o)
for cz in all(ex) do
cz.il,cz.la={},1
end
end
function kz(o)
lb={"fight","run"}
ku=true
for kj in all(kk) do
if kj.jh==1 then
ku=false
end
end
if(ku) add(lb,"advance")
q(o,lb,nil,lc,false)
end
function ld()
for kj in all(kk) do
kj.le=false
if kj.jh>1 then
if lf(kj[1].eo[12])<kj.jh or cm(30) then
if cm(75) then
kj.le=true
end
end
end
if not kj.le then
for eo in all(kj) do
lg(eo,kj)
end
end
end
lh()
end
function li(o,er)
ch,lj={},{}
for kj in all(kk) do
add(ch,#kj.." "..kj[1].eo[1].." "..kj.jh.."0'")
add(lj,kj)
end
q(o,ch,lj,er,true)
end
function lh()
for kj in all(kk) do
if kj.le then
kj.jh-=1
kj.le=false
eq({"the "..kj[1].eo[1].."s","advance."},lh)
return
end
end
while(#kn>0) do
lk=kn[1]
for cp in all(kn) do
if cp[1]>lk[1] then
lk=cp
end
end
if(ll(lk)) return
end
ce()
br=false
if#kk==0 then
for cz in all(ex) do
if(cz.stat<99) cz.cv+=ko
cz.ij=1
end
kp=0
o=p({"victory!","you receive",ko.." xp."})
q(o,{"continue"},nil,lm,false)
else
o=p(ky(""))
kz(o)
end
end
function ln(ca,n)
ce()
kp,lo,u=0,ba+1,0
lp,lq=dq(lo,lo,1,6),dq(lo-1,lo,1,6)
if ks then
a[ba+1]=0
b=1
if lo==4 then
lr()
return
end
lp,lq=a[lo+4],a[lo+8]
end
if ks or hm then
o=p({"pick your prize:"})
q(o,{fi[lp][1],fi[lq][1]},{lp,lq},lt,false)
hm=false
u=64
end
end
function lu(lv)
ce()
ch={"party receives:"}
for ca in all(lv) do
iq(ca)
ci(fi[ca][1])
end
o=p(ch)
q(o,{"continue"},nil,r,true)
end
function r(ca,n)
ce()
u=0
end
function lt(ca,n)
lw,lx=ba+1,{n}
if ks then
add(lx,dq(lw,lw+1,60,69))
add(lx,dq(lw,lw+1,70,79))
else
if(cm(60)) add(lx,dq(lw-1,lw,50,80))
if(cm(60)) add(lx,dq(lw-1,lw,60,80))
end
lu(lx)
end
function ci(ly)
hr=by(ly,"|")
for lz in all(hr) do
add(ch,lz)
end
end
function ll(cp)
kj,ma=cp[6],cp[4]
if cp[2]==0 then
cz=cp[3]
mb=cz[1]
if cz.stat==99 or cp[4]==2 then
del(kn,lk)
return false
end
if ma==1 then
del(kn,lk)
if(#kj==0) return false
eo,mc=kj[1],cp[7]
if(mc=="none") mc="hands"
ch,md={mb.." attacks",eo.eo[1].." with",mc},cz.fi[6].fj[5]
md+=(cz.la-1)
if me(eo,cz,0) then
if(md==1 and id(cz)>2) or(md<kj.jh) then
ci("but was to far|away!")
else
mf,mg=mh(cz)," dmg."
if cz.la>1 then
mf*=2
mg=" dmg (x2)."
end
ci("and hits for|"..mf..mg)
ka(mf,eo)
if(eo.stat==99) ci("killing it!| ")
end
else
ci("but misses!")
end
cz.la=1
eq(ch,lh)
elseif ma==3 or ma==4 then
ix,mi,mj,cz.la=cp[9],false," casts",1
if ma==3 then
if ix.fv==2 then
del(kn,lk)
return false
elseif ix.fj[6]>49 then
del(ex.fu,ix)
ix.fv=2
end
ix=ix.fj
mk,ml,mj=ix[10],ix[11]," uses"
else
mk,ml=ix[6],ix[7]
end
gx=gf[mk]
mm,mn=gx[2],gx[1]
if mm==1 or mm==5 then
eo,mi=kj,true
mo(ma,cz,ix)
del(kn,lk)
else
if#kj==0 then
del(kn,lk)
return false
end
eo=kj[1]
if mm==3 and mn<14 then
if cp[8]>#kj then
mo(ma,cz,ix)
del(kn,lk)
return false
end
eo=kj[cp[8]]
cp[8]+=1
else
mo(ma,cz,ix)
del(kn,lk)
end
end
ch={mb..mj}
if mi then
if mm==5 then
ci(ix[1].." at|party.")
else
ci(ix[1].." on|"..eo[1])
end
ci(cp[7])
iv(mk,eo,ma)
if(ml>0) iv(ml,eo)
else
ci(ix[1].." on|"..eo.eo[1])
if me(eo,cz,1) or mn==14 then
iv(mk,eo)
if ik==-1 then
if(ml>0) iv(ml,eo)
ci("and hits!|"..cp[7])
else
ci("and "..cp[7].." it|for "..ik.." dmg.")
end
if eo.stat==99 then
ci("killing it!| ")
cp[8]-=1
end
else
ci("but it fizzled.")
end
end
eq(ch,lh)
elseif ma==5 then
del(kn,lk)
ch={mb.." tries"}
ci("to hide in the|shadows...")
if cm(cz.ja) then
ci("and succeeds!")
cz.la+=1
if(cz.la>9) cz.la=9
else
ci("but is seen!")
cz.la=1
end
eq(ch,lh)
end
else
if cp[3].stat>90 or kj.stat>0 then
del(kn,lk)
return false
end
kt=cp[4]
if kt>0 then
gx=gf[kt]
if gx[2]==5 then
if cp[8]==5 then
del(kn,lk)
return false
end
cz=ex[cp[8]]
cp[8]+=1
else
cz=ex[cp[5]]
del(kn,lk)
end
if(cz.stat==99) return false
mn=gx[1]
if mn<10 then
ch={}
ci(cp[3].eo[1].."|"..cp[7].." at|"..cz[1])
if me(cz,cp[3],gx[5]) and lf(cp[4])>=kj.jh then
iv(kt,cz)
if ik>0 then
ci("and hits for|"..ik.." dmg.")
else
ci("and hits.")
end
if(cz.stat==99) ci("killing "..cz[1].."!| ")
else
ci("but misses!")
end
else
jb(cp[3])
ch={cp[3].eo[1],"summons a",cp[7]}
if cm(min(95,100*(cp[3].mp+11)/20)) then
iv(kt,cz)
else
ci("but it fizzled!")
end
end
eq(ch,lh)
else
del(kn,lk)
end
end
return true
end
function mo(ma,cz,ix)
if(ma==4) cz.fc-=ix[4]
end
function lg(eo,kd)
hs,kd.stat=eo.eo,0
mq,mr,ki,ms,ma=lf(hs[11]),lf(hs[12]),0,cs(2),0
if(mr>=kd.jh) ki+=1
if(mq>=kd.jh) ki+=1
if ki==1 and mr>0 then
if cm(66) then
ma=12
if(mr>1) ms=cs(4)
end
elseif ki==1 then
ma=11
if(mq>1) ms=cs(4)
elseif ki==2 then
if cm(10) then
if(mr>1) ms=cs(4)
ma=12
else
ma=11
if(mq>1) ms=cs(4)
end
end
if ma>0 then
mt(eo,hs[ma],ms,kd,hs[ma+2])
end
end
function ky(mu)
ch,u={},kk[1][1].eo[19]
ci(mu.."|you face:")
for kj in all(kk) do
ci(#kj.." "..kj[1].eo[1].." "..kj.jh.."0'")
end
return ch
end
function mt(cz,mv,mw,mx,ch,ix)
jb(cz)
add(kn,{cz.my,cz.hs,cz,mv,mw,mx,ch,1,ix})
end
function mz(ca,js)
kq,cz=js,ex[kp]
cz.ij,bv=1,kp
if js==1 then
if#kk>1 then
o=p({cz[1],"choose:"})
li(o,na)
else
na(1,kk[1])
end
elseif js==2 then
cz.ij=2
kp+=1
nb()
elseif js==3 then
fq(50,255,2^cz[2],2,3,nc)
elseif js==4 then
gc(2,nc)
elseif js==5 then
mt(ex[kp],kq,1,nil,nil,nil)
kp+=1
nb()
end
end
function na(ca,n)
if kq==1 then
mt(ex[kp],1,ca,n,ex[kp].fi[6].fj[1],nil)
kp+=1
nb()
end
end
function nc(ca,n)
if kq==3 then
ft=ex.fu[n].fj
mm=gf[ft[10]][2]
else
mm=gf[n[6]][2]
end
kr=n
if mm==2 or mm==3 then
if#kk>1 then
o=p({cz[1],"target:"})
li(o,nd)
else
nd(1,kk[1])
end
elseif mm==1 then
gw(ne,n)
else
nd(1,nil)
end
end
function nd(ca,n)
if kq==4 then
mt(ex[kp],kq,1,n,kr[8],kr)
else
ft=ex.fu[kr]
mt(ex[kp],kq,1,n,ft.fj[15],ft)
end
kp+=1
nb()
end
function ne(ca,n)
if kq==4 then
mt(ex[kp],4,ca,ex[ca],kr[8],kr)
else
ft=ex.fu[kr]
mt(ex[kp],kq,ca,ex[ca],ft.fj[15],ft)
end
kp+=1
nb()
end
function nb()
ce()
for ca=kp,4 do
cz=ex[ca]
if cz.stat<99 then
o,ch,jm=p({cz[1],"choose:"}),{"attack","defend","use item"},{1,2,3}
if cz.fc>0 then
ci("cast spell")
add(jm,4)
end
if cz[9]>0 then
ci("hide in shdws "..cz.la.."0'")
add(jm,5)
end
q(o,ch,jm,mz,false)
return
end
end
ld()
end
function lc(ca,cl)
for cz in all(ex) do
cz.ij=1
end
kp,nf=1,0
if ca==2 then
for cz in all(ex) do
nf+=cz[4]
end
if not cm(min(90,(nf-25)/22*100)) then
ca,kp=1,5
end
end
if ca==1 then
nb()
elseif ca==2 then
ce()
hm,u=false,0
else
for kj in all(kk) do
kj.jh-=1
end
eq({"the party","advances!"," "},nb)
kp=5
end
end
function jb(cz)
if cz.hs==0 then
cz.my,cz.ng,cz.nh,cz.ni,cz.ja=cz[4]*2+cs(4),(cz[6]-10)/2,cz[5]-9,cz[3]*2/20,cz[9]
hw(cz)
fr=hv[cz[2]+1]
hx(cz,fr[1],fr[2])
else
nj=cz.eo
cz.my,cz.fa,cz.ng,cz.nh,cz.la=nj[8]+cs(4),nj[6],nj[16],nj[9],1
end
cz.mp=cz.nh
for hh in all(cz.il) do
hx(cz,hh[1],hh[2])
end
end
function hx(cz,gs,ih)
if gs==1 then
cz.fa+=ih
elseif gs==2 then
cz.ng+=ih
elseif gs==3 then
cz.nh+=ih
elseif gs==4 then
cz.my+=ih
elseif gs==5 then
cz.ni+=ih
elseif gs==6 then
cz.mp+=ih
elseif gs==7 then
cz.ja+=ih
end
end
function me(dz,ku,nk)
jb(dz)
jb(ku)
if(dz.la>1) return false
nl=(8+dz.fa+ku.ng)/20
if nk==1 then
nl=(ku.mp-dz.nh+12)/20
end
return cm(max(5,100*nl))
end
function mh(cz)
return ceil(cs(4,cz.fi[6].fj[4])*cz.ni)
end
function ka(nm,eo)
ik,kj=ceil(nm),eo.kd
eo.fb-=ik
if eo.fb<1 then
ko+=eo.eo[15]
eo.stat=99
del(kj,eo)
if(#kj==0) del(kk,kj)
end
end
function lf(nn)
if(nn==0) return 0
return gf[nn][3]
end
function id(cz)
for ca=1,4 do
if(cz==ex[ca]) return ca
end
return 4
end
function dq(no,np,dm,co)
for ca=1,700 do
mv=dn(2,#fi)
fj=fi[mv]
if fj[7]>=no and fj[7]<=np then
if fj[6]>=dm and fj[6]<=co then
if(cm(fj[8])) return mv
end
end
end
return 17
end
function nq(ku)
return ceil(cs(2,3)+(ku-10)/2)+5
end
function nr(cz)
ch={cz[1],"levelled up!",""}
cz.fm+=1
for cl=1,dn(1,2) do
ca=dn(3,6)
cz[ca]+=1
add(ch,j[ca].." +1")
end
ns=nq(cz[3])
add(ch,"hp +"..ns)
cz.fb+=ns
cz[7]+=ns
if cz[8]>0 then
nt=nq(cz[5])
add(ch,"sp +"..nt)
cz.fc+=nt
cz[8]+=nt
iw(cz)
end
if cz[9]>0 then
ff=cz[4]-4
cz[9]=min(96,cz[9]+ff)
add(ch,"hide shdws +"..ff)
end
p(ch)
q(o,{"continue"},nil,lm,false)
end
function lm(ca,cl)
while kp<4 do
kp+=1
cz=ex[kp]
if cz.fm<12 then
if cz.cv>=cz.fn then
cz.cv-=cz.fn
cz.fn=cz.fn*2
nr(cz)
return
end
end
end
ln(0,0)
end
function lr()
u=68
ch={}
ci("you have escaped!|for now...| |your party is|teleported back|to the material|plane.| |you win!")
p(ch)
q(o,{"play again"},nil,hc,false)
end
__gfx__
000000001111111111111111000000000000000000000000000070000000700007777772212107ccc77021211011010144444444088800000888008000000000
0000000011111111111111110000000007777700077777700007770000007000722222227171077ccc7071717101107140004444080080000800808000000000
00700700111111111111111100777700070000000000700000707070000070007211100272720777ccc072727211027140440444080080000800808000000000
000770001111111111111111007007000777770000007000070070070000700072100002717170777c0171717170720140440444088800000888008000000000
00077000111111111111111100700700000007000000700000007000070070077210000221212088880121212120027140440444080080000800808000000000
00700700111111111111111100777700077777000000700000007000007070707210000271717108807171717170720140440444080080000800808000000000
00000000111111111111111100000000000000000000700000007000000777007210000272727270017272727270027140004444088800000888008000000000
00000000111111111111111100000000000000000000000000007000000070007210000271717171717171717170720044444444000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000007210000221212121212121212120000700000000000000000000000077777770
5555555555555555000000000000000000000000000000000000000000000000721000027171717171717171717007700000000000000000000000007ccccc70
5555555555555555000000000000000000000000000000000000000000000000700000000000000000000000000000070000000000000000000000007cc7cc70
5555555555555555000000000000000000000000000000000000000000000000077007077777777777777777777777000000000000000000000000007c787c70
55555555555555550000000000000000000000000000000000000000000000007777707700000000000000000000000700000000000000000000000007c7c700
55555555555555550000000000000000000000000000000000000000000000000007027207777777777000101010100000000000000000000000000007ccc700
555555555555555500000000000000000000000000000000000000000000000077700777070000000070700101010107000000000000000000000000007c7000
55555555555555550000000000000000000000000000000000000000000000007000272707088888807077001010101000000000000000000000000000070000
ccc00cccc00cccc0c000888833333333222200000000000070070000000000007770777707088888807072701000000700000000000000000080000000008000
c00000c0c00cc00cc000888833333333222200000000000007700000000000000007727207088888807077701000000000000000000000000008800000088000
0cc000c0c00cc00cc000888833333333222200000000000007700000000000007707777707088888807072701000000700000000002220000008980000089800
ccc000c0ccccccc0ccc0888833333333222200000000000070070000000000000007272707088888807077701000000000000000027772000089980000899800
00000000000000000000000000000000000000000000000000000000000000007707777707088800007072701000000700000000277cc720088a9880008a9980
000000000000000000000000000000000000000000000000000000000000000000077272070888808070777010000000000000000277720088aaa88008aaa880
000000000000000000000000000000000000000000000000000000000000000077707777070888888070727007777707000000000022200088aa880008aaa880
0000000000000000000000000000000000000000000000000000000000000000077077270708888880707770717171000000000000000000088a8000088a8000
000008000900800000080000000000000000000000000000000000000000000077070777070888888070770717171707000c0000000300000003000000030000
00808800000088000008800000000000000000000000000000000000000000007077027207088888807070717171710000ccc0000033c0000033300000c33000
0008998000089900000898000000000000000000000000000000000000000000077070770000000000000717171717070ccccc000333cc00033333000cc33300
008999800089998000899800000000000000000000000000000000000000000077770027272727272727272727272700333c3330333cccc0333c3330cccc3330
008aa980088aa980088a9880000000000000000000000000000000000000000070707077777777777777777777777707033333000333cc000ccccc000cc33300
08aaa88008aaa88088aaa880000000000000000000000000000000000000000007070772727272727272727272727270003330000033c00000ccc00000c33000
08aaa88008aaa88088aa88000000000000000000000000000000000000000000107007777777777777777777777777770003000000030000000c000000030000
088a800008888000088a800000000000000000000000000000000000000000001007272727272727272727272727272700000000000000000000000000000000
11111111111111111111119a11111111666666551000000000000101555666660000000000000001100000000000000000000000000000000000000000ccc000
1111111111aa11111111119a11111111666655000000777777cc000000155666000000000000011000000000000000000000000000cc0000000cc001cc000000
1111111111a9a1111111119a1111111166551100000777777ccccc00000115660000000000ccc010101000000000000000000000cc11cc001cc11cc000000c11
11111111111a9a111111119a11111111655100000cccccccccccccccc00011560000000000001110000000000000000000000001110111cc01011110000c1111
1111111aa11a92a111199aaaaaaa1111551000007cccccccccccc999cc000056000001ccccc100000101000000000000000000011018811100881110cc111101
1111111999aa922a11119966aaa11111550000077ccccc9ccccc99999cc000150000000001111111100000000000000000000000118c811118c8101111110111
1111111199988999a1111156111111115100007ccccc999ccccc9776993300050000001111101101110101000000000000000000111111101111110011111001
1111991199988a9a0911116611111111500000cccccc99999c766766633b30050000000011111111101110000000000000000000010011010011111100111110
1111999999999aa049111156111111115000099ccc99997799676666633b300000001c000011100111100000000000000000000010110011c110c11111011110
1111199922999a04999911661111111110000999c96666666666665563bbb300000000000800111110800c100000000000000001111110111110111111101101
111111992299a0499aaa9a561111111100006769c96555666516511533b4bb000000cc000088000088000000000000000cc000ccccc001011c110c1111101111
1111111a999a049aaaaa9a6611111111000b366696551156511111111b3b4630011cc000000000000000011cc1000000cc1c0c1cc1cc11101111011110111100
11111140a9a0499a99aaa999aa111111000b666611111111111111153bb44b5000001000111111111110000111ccc000c101c100001c111011c110c111100000
111199900a049a9aaa9aaaaa99aa111100bb3b611111111151131113b35443b3111c000001111111111000000000000010010000001c11110111101101000000
991199099099aaa9aaa9aaaaaa9aa11100bbb361151113313313313333b44b330000100000111111110000001cc1111010010000011c11111111110110000000
99999099999aaa9a9aaa99aaaaa9aaaa06b3bb33133133b3b333b333333443b311111000000000000000000000000000010010001c11c0111111111010000000
90949999999aa9aaaa9aa999aaaa8a9a03343b3333333333333b33b33334433300000c100000000000100011cc1111100100100c10c11c001111111110000000
99099994090aaaaa9aaaaa889aaaa2a90334333b3b333c1c1c1c333b333443330011110cc10010101000000000000000c011111cc10c11cc01100101cc000000
99909909999aaaa9a999aa72a9aaaaaa003433333333c1c1c1c1c13333344330000000110000010101101cc111111000c0c00c01cc11cc11c011101111cc0000
999909909049aaaaaa449aaa799aaaa500333b3b333c1c1c1c1c1c13b3333330000000001ccc0010100000000000000000c000c0111010cc1c011101c111cc00
9090990999999aaaaaaaaaaaaa99aa55000b333331c1c1ccccc1c1cc3b333300000000000000c0000000111111000000000c000011000001c1c110110c1111c0
9999909949999aaaaaaaaaa9aaaa995500033b3c1c1ccccccccc1cc3333b33000ccc00001111cc0000cc000000cc10000000001110000011c1c1011000ccc11c
59999909982909aa78aaa88a9aaaaa55000033c1c1ccc9c9cccccc33b33330000011cc0000011110000011100cc00c0000000cc10001010c1c10110c00000c11
559909909220999a22aa972aa99aaaa510001c1c1ccc9c9ccccccc333b3300011000010c00000000000000000c10cc100cc001c00011c11c1c110001000000cc
55555999a990999aaaaa9aaaaa99aaa5500001c0cccccacccccc33b333300005c000000c10000001cc111000cc00c10cc11cc10101c1100c11c0000c00000000
5555559999909099aaaaa9aaaaa999555100000c0ccc9c9ccccc333b330000160cc000c100011c0000000000000c10c1cc01c010c1c10000c1c0000c0c000000
5959555999a999999aaaaa9aaaaa9a55651000c0cccccaccccc33b333000015601cc0c1000000000cc1100cc000c0000000cc10cc1110000c11c00c00ccc0000
55555559a99999099aaaaaa9aaaaaa5a6511000c0cccacccccc3b3330000156610110c001110010000000001cc00000c001cc01cc10cc0000c1c00100c11c00c
5555555599a999999aaaaaaa9aaa555566510000cccccccccc33330000015666c0000000000000011ccc100011c000000011c11111000c000c11cc0000c11cc1
595599555999999999aaaaaa99555555666510000cccccccc3333000001566660cc0000011100000000000000000000000111001c000010000c111cc000cc11c
5555959555599995555aaaa555555a5566665510000cccccc33300011156666601c0000000000c111cc11000000000000000000c00000c00000cc11c00000cc0
5555555555555555555555555555a555666666550000ccccc33011555566666600000000001110000000000000000000000000100000010000000c11c0000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000003330000000000000000000003333333333333333333333333333333330000000333000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3000000bbb3330000000000000000003333333333333333333333333333333333000000333333000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb3330000000000000003333333333333333333333333333333333300000333333333000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb30000bbbbbbbbb3330000000000003333333333333333333333333333333333330000333333333333000000000000
bbbbbbbb88bbbbbbbbbbbbbbbbbbbbbbbbbb3000bbbbbbbbbbbb3330000000003333888888883333333333333333333338333000333333333333333000000000
bbbbbb8888888bbbbbbbbbbbbbbbbbbbbbbbb300bbbbbbbbbbbbbbb333000000333388bbbbb83333333333333333333338b33300333338883333333333000000
bbbbbb88888888bbbbbbbbbbbbbbbbbbbbbbbb30bbbbbbbbbbbbbbbbbb333000333388bbbbb83333333333333333333338b83330333338bb8833333333333000
bbbbbb8888888888bbbbbbbbbbbbbbbbb88bbbb3bbbbbbbbbbbbbbbbbbbbb333333388bbbbb82333333333333333333338b23333333338bbbb83333333333333
bbbbbb88888888888bbbbbbbbbbbbbbbb88bbbbbbbbbbb888bbbbbbbbbbbbbbb333388bbbbb82333333333333333333338233333333338bbbb83333333333333
bbbbbb28888888888bbbb3333333bbbbb88bbbbbbbbbb888888bbbbbbbbbbbbb333388bbbbb82333333333333333333333333333333338bbbb82333333333333
bbbbbb228888888888bbbbb33333bbbbbb8bbbbbbbbbb888888bbbbbbbbbbbbb3333888888882333333388888888333333333333333338bb8823338883333333
bbbbbbb22888888888bbbbbb333333bbbb2bb33bbbbbbb888888bbbb333bbbbb3333888888882333333388bbbbb8333333333333333338882233338bb8833333
bbbbbbbb2228888888bbbbbbbbbbbbbbbb22bbbbbbbbbbbbb222bbbbbb333bbb3333322222222333333388bbbbb8333333333333333332223333338bbbb83333
bbbbbbbbb222288888bbbbbbbbbbbbbbbbb2bbbbbbbbbbbbbbb2bbbbbbbbbbbb3333333333333333333388bbbbb8233333333833333333333333338bbbb83333
bbbbbbbbbbb2228882bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333388bbbbb82333333338b3333333333333338bbbb82333
bbbbbbbbbbbb222222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333388bbbbb82333333338b3333333333333338bb8823333
bbbbbbbbbbbbbbb222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333388888888233333333823333333333338888882233333
bbbbbbbbbbbbbbbb22bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333888888888888888233333383333333333333338bb2223333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb88bbbbb333333333333388bbbbb8222222223333338b333333333333338bbbb83333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb883bbbbbbb3333bbbbbb8883bbb333333333333388bbbbb8233333333333338b833333333333338bbbb83333333
bbbbbbbbbbbbbbbb222bbbbb8888bbbbbbbbb88bbbbbbb3333bbbbbbb388bbbb333333333333388bbbbb8233333333333338b233333333333338bbbb82333333
bbbbbbbbbbbbbbbb222bbbbb888883bbbbbbb3bbbbbbbb33bbbbbbbb3388bbbb333333333333388bbbbb82333333333333382333333333333338bb8823333333
bbbbbbbbbbbbbbbbbbbbbbbb888883bbbbbbbbbbbbbbbbbbbbbbbbbb3bb8bbbb333333333333388bbbbb82333333333333333333333333333338882233333333
bbbbbbbbbbbbbbbbbbbbbbbbb8888bbbb333bbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333888888882333333333333333333333333333332223333333333
bbb3333333bbbbbbbbbbbbbbbb388bbbb33bbbb3bbbbbbbbbbbbbbbbbbbbb3333333333333333888888882333333333333333333333333333333333333333333
bbbb33333333bbbbbbbbbbbbb3388bbbbbbbbb30bbbbbbbbbbbbbbbbbb3330003333333333333332222222333333333333333330333333333333333333333000
bbbbb333333333bbbbbbbbb333bb8bbbbbbbb300bbbbbbbbbbbbbbb3330000003333333333333333333333333333333333333300333333333333333333000000
bbbbbbbbbbbbbbbbbbbbbb333bbbbbbbbbbb3000bbbbbbbbbbbb3330000000003333333333333333333333333333333333333000333333333333333000000000
bbbbbbbbbbbbbbbbbbbbb333bbbbbbbbbbb30000bbbbbbbbb3330000000000003333333333333333333333333333333333330000333333333333000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb300000bbbbbb3330000000000000003333333333333333333333333333333333300000333333333000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3000000bbb3330000000000000000003333333333333333333333333333333333000000333333000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000003330000000000000000000003333333333333333333333333333333330000000333000000000000000000000
000000000000000000000000000000000011ccc11100000000000000000000000000000000000000000000000000000000000000000001cc1100000000ccc000
0000000000000000000000000000000001000000ccc000000000000011111ccc00000000000000000000000000000000000000000001c00100c100000ccccc00
000000000000000000000000000000001ccc11100000000000000000000000000000000000000000000000000000000000000000001c0111111c10000ccc1c00
0000000000000000000000000000000000000011111ccc1000011111111cccc1000000000000000000000000000000000000000000111c81c811000001ccc100
00000000000000000000000000000000cc1101110101101100000000000000000000000000000000000000000000000000000000001111111111100000c1c000
00000000000000000000000000000000000001000000011c10111111cccc01cc0000000000000000000000000000000000000000000111010111000000ccc000
00000000000000000000000000000000c11011010010001010000000000000000000000000000000000000000000000000000011111010111010111110cc1000
000000000000000000000000000000000000100011101001c01111ccc000011c000000000000000000000000000000000000110010100100010c000001ccc000
00000000000000000000000000000000111010100101001010000000000000000000000000000000000000000000000000010cc10001011011c00000001cc000
00000000dd000000000000dd00000000c1101001000c800cc1011cccc00001cc0000000000000000000000000000000000100011000100111c00c001001c0000
00000000dd000000000000dd000000000000100c810000100100000000000000000000000000000000000000000000000010ccc10c00c000c0000001000c0000
00000000dddddddddddddddd00000000cc10100000000001c101111cccc00ccc0000000000000000000000000000000000100001000001000000cc0101111100
00000000dddddddddddddddd000000000000110000101000110000000000000000000000000000000000000000000000010ccc0010c100c00100001001000100
00000000dd000000000000dd000000001110010001010100c1101111cccc01cc000000000000000000000000000000000101000010000001001001001c111100
00000000dd000000000000dd00000000cc100010001010001000000000001000000000000000000000000000000000000010ccc010cc110c0001100001c00100
00000000dd000000000000dd0000000010000001000100010000011cccc811110000000000055555555550000000000000010011100000001000000000011100
00000000dd000000000000dd000000000ccc1000110000100000000000008110000000000055555555555500000000000001011110cccc110cc0000011c10100
00000000dddddddddddddddd000000001111100000111100000001111cc81181000000000559999999999550000000000000111c000000000001cc010c111100
00000000dddddddddddddddd00000000cc1c11100000000000000000000808180000000055999999999999550000000000001101000ccccc1100000000000000
00000000dd000000000000dd0000000011110888000000000000001111111118000000055555555555555555500000000001cc01000000000000000010000000
00000000dd000000000000dd000000001118100000000000000000011cccc00000000005555555555555555550000000000110011000cccccccc110010000000
00000000dd000000000000dd00000000180c8c0000000000000000000000001100000005555555555555555550000000000cc000100000000000000010000000
00000000dd000000000000dd000000000180088000000000001ccc1111cccc110000000551111111111111155000000000000000010000cccc10011110000000
00000000dddddddddddddddd00000000000800000000000000000000000000110000000551111111111111155000000000000001111000000001100001000000
00000000dddddddddddddddd0000000000000000000000111cc111111cccc1110000000551111111111111155000000000000011000100000110000000100000
00000000dd011111111110dd00000000000000000000000000000000000000000000000551111111111111155000000000000110ccc011001000cc1c00100000
00000000dd111111111111dd00000000000000000000001cc111111111cccc110000000551111111111111155000000000011000000000110100000000010000
00000006dd111111111111dd6000000000000000000000000000000000000000000000055111111111111115500000000001000cccc1001001001ccc1c011000
000000000d771717171717d000000000000000000000cccc11111101111111110000000555555555555555555000000000010000000001000100000000001000
000000000d777777777777d000000000000000000000000000000000000000000000000555555555555555555000000000010cccc1c0100001000011ccc01100
000000000007777777777000000000000000000001cccccc11110000011111110000000000000000000000000000000000110000000010000010000000000100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100cc11c010000000100001ccc0110
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001353013530135301353013530135301353013535135301353013530135301353013530135301353511530115350c5300c535105301053010530105350e53510530105350e53510530105301053010535
011e00001053010530105301053010530105301053010535105301053010530105301053010530105301053513530135350e5300e535125301253012530125351053512530125351053512530125301253012535
011e000012530125351253012535155301553515530155350f5300f5350f5300f5351453515535175351953519530195301953019535195301953019530195351953019530195301953519530195301953019535
011e0000000000000000000000000000000000000000000000000000000000000000000000000000000000001453515535145351253514535155351453512535145351553514535125350f535105351253012535
011e00001053010530105301053010530105301053010535105301053010530105301053010530105301053500000000000000000000000000000000000000000000015535000001353510530105301053010535
001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00000000000000000000000000000000000000000000000000000000000000000000000000000000000011050110501105011055100501005010050100550e0500e0500e0500e05510050100501005010055
011e00000905009050090500905009050090500905009055090500905009050090500905009050090500905513050130501305013055120501205012050120551005010050100501005512050120501205012055
011e00000b0500b0550b0500b05509050090550905009055080500805508050080551405515055170550d05500000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00000f055100550f0550d0550f055100550f0550d0550f055100550f0550d0550f0550d0550b0550904508050080551405014055090500905515050150550b0500b05517050170550b0500b0550b0500b055
011e00000000000000000000000000000000000000000000000000000000000000000000000000000000000004050040551005010055040500405510050100551505015055130501305510050100501005010055
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e0000117002675526755247552975528755247551f75526755297552875524755247552675526750267552975528755247552175523755267552475521755217551f755247552375523750237502375023755
011e00001c7501c7501c7501c7551a7501a7501a7501a7551c7501c7501c7501c755217502175021750217552b7552a7552675523755257552875526755237552375521755267552575525750257502575025755
011e00001c7001e7551e7551c75521755207551c7551e75527755277552575523755207502075020750207552d7552c7552a7552d7552c7552a7552d7552c7552a7552d7552c7552a7552a7552d7552c7552a755
011e00002a7502a7551e7501e7552c7502c75520750207552d7302d7352173021735237302373525730257352773528735277352573527735287352773525735277352873527735257352373521735207551e755
011e0000000002373523735217352673525735217351c73523735267352573521735217352373523730237351c7301c7301c7301c7351c7301c7301c7301c7350000025735000002573528730287302873028735
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
0001000015730157100c7000f7000d7000670001700047000070000700027000070019700167001470012700107000e7000e7000c7000a7000870008700067000570004700027000170000700007000070000700
00010000157301072007710177000c7001970010700047000070000700027000070019700167001470012700107000e7000e7000c7000a7000870008700067000570004700027000170000700007000070000700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01 07 0d 44
00 02 08 0e 44
00 03 09 0f 44
00 04 0a 10 44
00 05 0b 11 44
00 3f 42 43 44
00 3f 42 43 44
00 3f 42 43 44
00 07 42 43 44
00 08 02 43 44
00 09 03 0f 44
00 0a 04 43 44
00 0b 05 11 44
02 3f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
