pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- dungeon witches - minimal
-- by doc1oo
function _init()
t,kc=true,{kd,ke,kf}
_m[[
wg
xm
_m,wG]]
_g([[xr,pu,pa,po]],false,2,im":101000000",gD(oE[1]))
kg(0)
gt,ga=0,1
kh=t end
function _update()
for i=0,5 do
local a=oF[i]
local b=oG[a]
if btn(i)then
b=oH[a]end
if(b!="")oF[i]=b
end
_m[[
ge=hu,4,oB
rk=hu,5,oB
gu=false]]
for i=0,3 do
if(btnp(i))gu=oI[i]
end
if _c[[&&,io,,,]]then
ki,kj=gE(gu)
if _i[[&&,kj,!,0,}
sfx,10]]then
gt=gd(gt+kj,#io)end
ga=gt+1
_i[[&&,ge,,,}sfx,11]]
_i[[&&,rk,,,}sfx,22]]
if _c[[&&,ki,!,0]]then
if _c[[&&,ip,,,]]then
kk=#ip[ga]
pa[ga]=gd(pa[ga]+ki,kk)
_i[[&&,kk,=,1,}
sfx,30
}
sfx,22]]end end end
_[[disp_l10n_lang=mt,xr,vx,vy]]
pb()
_[[yq=hp,yq]]
_i[[&&,pb,!,prev_scn,}
yq,pc=0,t
}
pc=false]]
_m[[
t,prev_scn=t,pb
pf=hp,pf]]end
function _draw()
if(pc)return
pd=pe[pf\4%4+1]+pg
_m[[
vl
pm
kh=false]]end
function ph()
_g([[qi,kB,kA,xs,xt]],pi[pj],{},{},unpack(pk[kl+1]))
pl=t
_m(km)
pb,pm=kn,ko end
function kp()
_g([[xu,pB,xv,pj,xw,os,kl]],time(),_[[unpack,pa]])
_[[_m,wH]]end
function pn(a,b)
kq(po[b],a)end
function kr()
if _c[[&&,pu,=,2]]then
if ge then
local a={kp,pq,_s[[kh,pu,gt,ga,ip=t,3,0,1,po]]}
hj(a[ga])end
else
if _c[[&&,ge,,,||,rk,,,]]then
local b=pa[ga]
local c={function()end,function()end,function()end,_s[[kh,pu,gt,ga,ip=t,2,2,3]]}
hj(c[ge and gt-4 or 4])end end
io=pt[pu]
if _c[[&&,stu_d1,=,0,&&,pu,=,2]]then
io[2]="--"end end
function ks()
hk()
if _c[[&&,pu,=,2]]then
_m[[palt,3,t
palt,0,false
sspr,32,47,8,1,4,14,24,3
sspr,32,48,40,16,4,17,120,48
hk]]
_[[_m,xc]]end
kt(unpack(gD[[
40,84
36,83
2,14
]][pu]))
_i[[&&,pu,!,3,}
iH,10
mz,128,2,-5,88,32,32,1]]end
function kt(a,b,c)
c=c or 12
hk()
for fy,fx in _[[pairs,io]]do
ku,pv,kv,kw=1,a,
fy*c-c+b,
ip and ip[fy][pa[fy]+1]or""
if fy==ga then
_m[[
vu,0,kv
rectfill,0,-2,127,8,pd
fillp
spr,92,pv,0
ku=3
camera]]end
if(kh or fy==ga)px[fy]=hm(fx)..hm(kw)
gG(px[fy],a+12,kv,ku)end end
function cntd(a,b,c)
if(not c)c=_ENV
ho=c[a]
if ho then
c[a]=ho>(b or 0)and ho-1 or false end end
function pz()
_g([[pF,pD,pE]],{},unpack(pA[pB+1]))
for fy,e in _[[pairs,yv]]do
pC,gH=e,_[[iF,yi]]
_[[nw,gH,pC]]
_g([[gH.h,gH.d,gH.ds]],ceil(gH.h*pD),ceil(gH.d*pE),
_c[[&&,gH.a,!,0]]and gH.sn-gH.sn%2 or gH.sn)
_g([[gH.en,gH.mh]],_[[hm,pC.n,vy]],gH.h)
pF[fy]=gH end end
function kn()
pG=time()
if iq then
cntd[[iq]]
if _c[[&&,iq,=,false]]then
ky(unpack(pH[pI+p_y\8%2*16]))
kz()
else
return end end
if _i[[&&,pc,,}
io=false
xm
pz]]then
for i=0,6,2 do
qa=i+63
qb[i]=_[[hB,qa,0,0]]end end
if p_e>=qc[p_l]then
_m[[
sfx,24
p_l+=1]]end
ir()
_g([[ql,kb,ot,kD]],_a[[p_h,0,false,false]])
foreach(kA,function(e)
if(e.ac==1)e.ay-=.4
e.u+=e.mx
e.v-=e.ay
e.c=hp(e.c)
del(kA,is(e)and e)end)
if _c[[&&,qd,,,&n,ge,,,]]then
_[[qd=hp,qd]]
return end
qd=it
if _i[[&&,hv,,}sd]]then
foreach(kB,function(e)
hq(e)end)
return end
if gf"5"and gu then
_[[qA=t]]
elseif _i[[&&,rk,,,&&,qA,,,}
qA=false]]then
return end
_[[qh=hp,qh]]
qe=_c[[&&,qh,>=,2]]
foreach(kB,function(e)
hq(e)
if(e.h<e.prev_h)e.dmcnt+=1
e.prev_h=e.h
cntd("dm",-4,e)end)
qf,qg=qh>=qi,_c[[&&,pj,>=,1]]
if p_h>0 then
kC()
if(kD or _c[[&&,qg,,,&&,qf,,]])then
kE=_m[[
mget,p_x,p_y
qh,qe=0
ys+=1
kD=t]]
if not gI and _[[fget,kE,1]]then
hr(flr((fE(kE,split"45,76,108,126")and 20 or 10)*pE))
sfx"8"end end end
kF=kG(qj)
if kD then
if _c[[&&,p_wing,=,1]]and _[[gp,pI,13,14]]then
qk=ha(80,_[[go,14,97]],gg)
_[[qk.f1,qk.f2=0,1]]end
kH()end
cntd("p_dm",-1)
_m[[
p_h=mid,p_h,0,p_mh
p_m=mid,p_m,0,p_mm]]
if p_h<=0 then
_i[[&&,yr,=,0,}
qh=0
sfx,25
kg,-1
yj=5
yr+=1
}
qh=0
yr+=1]]
_i[[&&,yr,=,90,}
yr,pb,pm=0,qt,qu]]end
if p_h<ql then
_g([[p_dm,la,lb]],6,iu"4",iu"4")end
p_p,kI=_c[[&&,xC,,,&n,ld,,]]and 2 or 0,
p_h<=p_mh/5
_m[[
qm
kz
rv]]end
function qm()
qn=-mid(0,p_y%16*2-8,16)end
function kz()
pI=p_x\qo*2+p_y\qo+1
hs=pI<=0
_i[[&&,pI,!,yo,}
sq
yo=pI
}
yo=pI]]end
function ko()
p_ds,p_a=_a(kI and"162,0"or"128,1")
_m[[
hk
sv
sv,128,t
sB
sv,128
hk
?&n,hv,,,}ta]]
la/=-3
lb/=-3
iv=gw(_[[jm,p_x,p_y,p_dr]])or qp
if(iv and iw(iv))_[[tf,iv]]
_m[[
sI
sfd_item_explain=^>]]
if qq then
_[[_m,wI]]end
_i[[&&,field_story,,}draw_demo,field_story,0]]
qr=gf"5"
_i[[&&,sh,,,&n,qr,,}
tg]]
_i[[&&,yj,,,}
iG,yj,1
]]
cntd[[yj]]
if iq then
qs=iq\3-10
_[[iG,qs,1]]end end
function qt()
_i[[&&,pc,,,}
oA=99
kg,4]]
_i[[&&,ge,,,&n,io,,,}
yq=120
]]
_i[[&&,yq,=,121,&n,io,,,}
kh,pu,gt,ga,ip=t,1,0
io=split,xe]]
if _c[[&&,io,,,&&,ge,,,]]then
if _i(lc)then
else
run()end end end
function qu()
qv=130+30*gt
_[[_m,xd]]
_i[[&&,io,,,}
vs,qv,56,102
kt,28,78
}
vs,160,56,72]]end
function kC()
_m[[
ir
?&&,qh,>=,4,}uk]]
_g([[qw,qx,p_dr,xx,xy]],_[[mget,p_x,p_y]],not gI,gu or p_dr)
_[[ix,hb=jm,p_x,p_y,p_dr]]
hb,ht,qq=gd(hb,32),fget(qw,2)and qx,false
if(qy>15 or gf"5")add(kA,gx(qb[p_dr],ix,hb))
if hu(5,qz)then
_[[lv=0]]
elseif gf"5"then
_[[lv+=1]]end
if(qA)return
if hu(4,qz)then
_[[le,ld=0,false]]
elseif gf"4"and not ld then
_[[le+=1]]
elseif ld then
_[[le=0]]end
_m[[
pc_s=mget,ix,hb
qH=kG,qj
fG=gw,ix,hb]]
_g([[xz,qF,xA,qG]],_m[[
fget,pc_s,3
fget,pc_s,0
fget,qw,1,
fget,pc_s,6]])
_g([[qq,rf,rh,xB,p_prev_x,p_prev_y,xC,kD]],
_c[[&&,fG,,,&&,qx,,,&n,checked_obj,,]]and(fG.ev and _c[[&n,p_spboss,,,&&,fG.md,=,rl]]or _c[[&&,fG.md,=,rm]]),ix,hb,{ix,hb},p_x,p_y,
le>=qB and(qx and p_l>=6 or gI and p_l>=4))
local function iy()
_i[[&&,xz,,,&&,gu,,,}
sn,ix,hb,t]]
_m[[
pwe_m=mget,rf,rh
pwe_f=fget,pwe_m,6
?&n,pwe_f,,,}ky,rf,rh]]
if _i[[&&,gI,,}
gI=false
sfx,23]]then
elseif fG then
_i[[&&,fG.id,=,qj,}
gI=t
sfx,23]]
_i[[&&,fG.o,=,lD,}
ro,fG]]
else
sfx(_[[go,1,10]])end
if not p_spboss and _[[fget,pwe_m,4]]then
_m[[
iq,qs,oA=30,0,99
sfx,9,3
kg,-1]]
if _i[[&&,pwe_m,=,40,}
mf=p]]then end end end
local function iz()
_m[[
qq=false
checked_obj,mf=t,fG]]
hv=_c[[&&,fG.md,=,rl]]and fG.ev or fG.ev2 end
local function lf()
local a,b=_[[gE,p_dr]]
qC,qD=8*a,8*b
fG.h-=p_d
_m[[
uk
p_u+=qC
p_v+=qD
fG.dm=5
sfx,15]]end
local function lg()
qE=(qF or qG)and not p_fairym
if _i[[&&,fG,,,||,qE,,,||,ht,,,||,xA,,,}
sfx,30]]then
return t end
if not _i[[&&,qH,,}
gx,qH,xB]]then
qH=add(kB,_[[hB,11,rf,rh]])end
_m[[
hw,12,qH.x,qH.y,t
ot=t
sfx,22]]end
local function lh()
hw(14,p_x-3,p_y-2)
hw(31,_[[iu,1,p_x]],p_y-2.4)
_m[[
ot=t
sfx,17]]
if p_h<p_mh then
hr(-p_mh\10)
else
_[[kD=t]]
return t end end
local function li()
qI={}
_[[rb,rc=gE,p_dr]]
function lj(a,b,hc)
lk,ll=a,b
local c=_[[gw,lk,ll]]
if c then
_m[[
lk+=rb
ll+=rc]]
if(fget(_[[mget,lk,ll]],3))_[[sn,lk,ll]]
if _[[uy,lk,ll,false,t,false,t]]then
add(hc,c)
hc=lj(lk,ll,hc)
else
return end end
return hc end
_m[[
hw,75,p_x,p_y,t
ra=lj,rf,rh,qI]]
foreach(ra,function(e)
gx(e,e.x+rb,e.y+rc)
if e.id!=qj then
e.h-=1
e.dm=5
if(e.h<=0)sfx"29"
end
end)
if _i[[&&,ra,,,}
ky,rf,rh
sfx,15
}
sfx,7]]then
return end
return t end
local function lm()
_m[[
lF,qH
sfx,27
gI=false]]end
local function ln()
_[[pwh_wkfail=t]]
_i[[&&,fG.o,=,lD,}
fG.h=0]]
_[[_i,xb]]
_i[[&&,xz,,,}
sn,rf,rh
pwh_wkfail=false]]
if _i[[&&,pwh_wkfail,,,}
sfx,30]]then
return t end end
local function lo()
_[[_m,xg]]
_[[_i,xh]]
for i=1,16 do
_m[[
awth_hy+=-1
hw,74,awth_hx,awth_hy,t]]end end
local function lp()
_m[[
rg,ri=gE,p_dr
xx,xy,lr=p_x,p_y
xx+=rg
xy+=ri]]
for i=1,16 do
rd,re=rf+rg,rh+ri
_m[[
lq=gw,rd,re
pkh_mc=mget,rd,re
]]
if not _[[uy,rd,re,t,false,oC,false]]then
if lq and i>=2 and _c[[&&,lq.md,=,uv]]then
lq.h-=p_d*3
_m[[
lq.dm=6
qp=lq]]
break
elseif not _[[fget,pkh_mc,0]]and _c[[&&,lq,,,&&,lq.md,=,rx,&&,lq.o,!,oC]]then
_m[[
lq.h=0
rf+=rg
rh+=ri]]
break
elseif _[[fget,pkh_mc,3]]then
_m[[
sn,rd,re
rf+=rg
rh+=ri]]
break
else
break end
else
if _i[[&&,lq,,,&&,lq.md,=,rx,&&,lq.o,=,lD,}
lq.h=0
rf+=rg
rh+=ri
]]then
break end
lr=not _[[uy,rd,re]]end
_m[[
rf+=rg
rh+=ri
?&n,lr,,,}xx,xy=rd,re
hw,86,rf,rh,t]]end
_m[[
?&&,lr,,,}gx,qH,xx,xy,}gx,qH,rf,rh
sfx,29]]end
local function lt()
_[[_m,xa]]
for i=1,16 do
_m[[
phe_pcv=rh
?&&,phe_dx,!,0,}phe_pcv-=1]]
if(_[[uy,rf,rh,t,t,oC,t]])then
hx,rj=_[[gw,rf,rh]],lu(i)
_m[[
?&&,rj,,,}hw,73,rf,phe_pcv,t
ky,rf,rh]]
if(hx)hx.h-=p_d hx.dm=5
lr=not _[[uy,rf,rh]]
else
_m[[
hw,73,rf,rh,t
rf=xx
rh=xy
?&&,lr,,,}ky,rf,rh]]
break end
_m[[
?&n,lr,,,}xx,xy=rf,rh
rf+=phe_dx
rh+=phe_dy]]end
if(fget(_[[mget,rf,rh]],3))_[[sn,rf,rh,t]]
end
local d={{lo,1,6,_s[[&&,qx,,,&&,xC,,,&&,qH,,]],ge},{lt,1,4,_s[[&&,gI,,,&&,xC,,]],ge},{lm,0,0,"",rk and lv<6},{iz,0,0,_s[[&n,p_spboss,,,||,fG.md,!,rl,&&,qx,,,&n,checked_obj,,]],ge and fG and fE(fG.md,{rl,rm})},{lp,3,3,_s[[&&,fG.id,=,qj,&n,xC,,,&n,gI,,,&n,ld,,]],ge and fG},{lg,0,0,_s[[&n,gI,,,&n,xC,,,&n,ld,,,]],ge},{li,1,2,_s[[&&,fG.id,=,qj,&&,qx,,,&n,xC,,,&&,gu,,]],gf"4"and fG},{lh,1,0,_s[[&&,gI,,,&n,xC,,,&n,ld,,]],ge},{ln,1,5,_s[[&&,gI,,,&&,gu,,]],gf"4"and(_[[uy,ix,hb,false,t,false,false]])},{lf,0,0,_s[[&&,fG.o,=,0,&&,qx,,]],gu and fG and _[[iw,fG]]},{iy,0,0,[[]],gu and(_[[uy,ix,hb,false,false,oC,false]]or _c[[&&,debug_test_mode,,,&n,fG,,]])}}
for fA in all(d)do
hy,hz,lw,lx,ly=unpack(fA)
if ly and p_l>=lw and _c(lx)then
if p_m>=hz then
_[[checked_obj,qp=false]]
if _i[[&&,p_sleep,,,}
kD=t
hw,31,p_x,p_y]]then
cntd"p_sleep"
elseif not hy()then
_[[p_m-=hz]]
kD=hy!=iz
if(hz>=1)hA(-hz,t,hB(1,gb+3+#tostr(p_h)*.5,gg-qn/8+12)) 
end
else
_m[[
hw,13,p_x,p_y
sfx,7
kD=t]]end
_[[ld,qy=t,0]]
return
elseif hy==iy then
_i[[&&,gu,,,}
p_u+=2
sfx,27]]end end
_m[[
?&&,ge,,,}le=0
?&&,rk,,,}lv=0
qy+=1]]end
function ro(a)
rp,rq=a,_[[go,5,1]]
_m[[
?&&,rp.id,=,82,}p_sleep=rq
hr,rp.d
lF,rp
sfx,29]]end
function kH()
lz={}
for fx in all(kB)do
hd(fx,t)end
for e in all(kB)do
if iw(e)and(not e.dur or e.c<e.dur-1)then
hC,e.prev_x,e.prev_y=e,e.x,e.y
if e.t==0 and fget(mget(hC.x,hC.y),2)then
_m[[
un,hC.x,hC.y,t
lF,hC
sfx,29]]end
gl,gm=lA(e)
e.cdx,e.cdy=gl-e.x,gm-e.y
e.dr=lB[fF(e.cdx)][fF(e.cdy)]
iA,lC=iB(gl,gm),gw(gl,gm)
if e.o==lD then
if iA or lC then
if _i[[&&,iA,,,&n,gI,,,}
ro,hC]]then
elseif e.c!=0 then
_i[[&&,lC.id,=,qj,}
sfx,23
hw,75,gl,gm
ot=t
lF,hC
}
lF,hC]]end
else
gx(hC,gl,gm)end
else
if not gn(gl,gm,it,e.t)then
gx(e,gl,gm)
elseif iA and not gI then
lE(e)end end
e.actc=hp(e.actc)end
e.c=hp(e.c)end end
function hd(a,b)
lz[a.y*256+a.x]=b and a end
function lF(a)
if type(a)=="table"then
if(a==gw(a.x,a.y))hd(a)
del(kB,a)end end
function lE(a)
rs,hD=a,{}
foreach(lG,function(fx)
hD[fx]=a[fx]end)
_m[[
sfx,20
hr,rs.d]]
_g([[rs.hidden,hD.mx,hD.ay,hD.c,hD.dur]],6,a.cdx*1.7,a.cdy*-1.25+2,0,9)
iC(_[[add,kA,hD]])end
function is(a)
return(a.id!=qj or hs)and(
(a.dur and a.c>=a.dur)or not iD(a.u,a.v,-1,129,-1,129)or(a.id==rt and ru[pI]==1 and not p_spboss))end
function rv()
for e in all(kB)do
lH=e
if is(e)then
_[[lF,lH]]
elseif e.h<=0 then
lI,rw=e.x,e.y
if e.md==rx then
e.ay,e.mx=rnd"2"+3.5,rnd"3"-1.5+fF(lI-p_x)*2.5
_m[[
p_e+=lH.mh
iC,lH
lH.fx=1]]
lF(_[[add,kA,lH]])
if _c[[&&,lH.o,!,lD]]and not _[[gn,lI,rw]]then
local a,b=go"99",0
for fy,fx in _[[pairs,yA]]do
b+=fx
ry=85+fy
if(a<b)_[[mset,lI,rw,ry]] break
end
end
elseif _i[[&&,lH.md,=,uv,}
kg,-1
lH.md,yj=rm,5]]then
ru[pI]=1
foreach(kB,function(l)
if(l.md==rx)l.h=0
end)
rz=rA[pI]
_i[[&n,hs,,,}
sfx,24
kg,rz,7000]]
p_e=max(qc[lH.bos],p_e)
p_spboss=false
if p_fairym then
p_fairym=false
p_x,p_y=106,29 end end end end end
function rB()
_g([[kB,rE,rD]],{},{},{})
_m[[
gbe_px=p_x
gbe_px+=2
ir]]
for i=gg,gg+15 do
for j=gb,gb+15 do
rC=mget(j,i)
if rC>=128 then
for fy,fx in _[[pairs,pF]]do
if rC==fx.sn then
_g([[ou,ov,ow,ox]],i,j,fy,fx)
add(_c[[&&,ox.rn,=,0]]and rD or rE,{_a[[ow,ox,rC,ov,ou]]})
_[[un,ov,ou]]
break end end end end end
_[[kq,rD,rE]]
for fy,mc in _[[ipairs,rD]]do
_g([[ow,ox,rC,ov,ou]],unpack(mc))
rF=_c[[&&,ox.fx,=,1]]and hw or ha
for l=1,4 do
_m[[
gbe_x=iu,ox.rn,ov
gbe_y=iu,ox.rn,ou
gbe_dist=jh,gbe_x,gbe_y]]
if not _[[gn,gbe_x,gbe_y,t,ox.t]]and _[[nj,gbe_x,gbe_y]]and(_c[[&&,ox.rn,=,0]]or _c[[&&,ox.rn,!,0,&&,gbe_dist,>,3]])then
_[[_m,xj]]
break end end end
_[[_m,xk]]end
function rG()
_[[event_talker=hB,oy]]end
function rH()
_m[[
ee_e=kG,me
?&&,ee_e,,,}ee_e.md=md
?&&,ee_e,,,}ee_e.c=0]]end
function rI()
_m[[
?&&,event_talker,,,}event_talker.md=2
?&&,event_talker,,,}event_talker.c=0]]end
function sa()
_g([[p_]]
..md,me)end
function sb()
_i[[&n,hs,,,}
oA=md]]end
function sc()
_m[[
ee_e=kG,61,kA
?&&,ee_e,,,}ee_e.dur=1
ee_e=kG,62,kA
?&&,ee_e,,,}ee_e.dur=1
]]end
function sd()
if hv then
if se>#hv then
_[[sh,se,field_story,hv,qd,mes_text,yk,mes_sn=false,1,false]]
return end
iE=hE(hv[se])
_g([[sf,md,me,oy]],iE[1],false)
if sf then
_g([[md,me,oy]],gh(iE[2]))end
_[[se+=1]]
sg,sh=_c[[&&,sf,=,Tp,]]and p or mf,false
if fE(sf,split"e,p,edc")then
_m[[
sh=t
mes_sn,yk,event_talker,qd=sg.sn,sg.n,sg,0
sfx,11]]
else
_i[[&&,sf,=,Tboss}
event_talker=sg]]end
hj(si[sf])end end
function sj(a)
sk=a
mf=_m[[hB,sk
sm=sk
sm-=84]]
sl=mg[sm]
if _i[[&&,sk,>=,91}
sfx,-1
sfx,24,3]]then
else
sfx"16"end
_m[[
hj,sl]]end
function sn(...)
mh,so,mi,mj=129,...
_[[mk=mget,so,mi]]
if _[[gp,mk,85,95]]and mj then
_[[sj,mk]]
if mk<=90 then
sp,mh=mi-1.5,_[[jn,so,mi]]
_[[hw,98,so,sp]].ds=mk end
else
_m[[
bmc_fx=hw,13,so,mi
bmc_fx.dr=6
sfx,28]]end
_m[[
?&&,128,>,mh,}mset,so,mi,mh,}mh=un,so,mi
um,so,mi,mh]]end
function sq()
_g([[kA,lz,xD]],{},{},_[[kG,qj]])
_m[[
uf
rB]]
if not p_bgsfx then
if not _i[[&&,gI,,,}
ha,qj,p_x,p_y]]then
_i[[&&,xD,,}
gx,xD,xD.x,xD.y
add,kB,xD]]end end
if _c[[&&,p_wing,=,1]]then
rA[13],rA[14]=31,31 end
sr=rA[pI]or 32
_i[[&&,sr,!,oA,&n,sC,,,&&,pb,!,kr,}
kg,sr
oA=sr]]end
function hA(a,b,c,d)
ss,ml=c,c or p
st=ml.y+1
_i[[&n,ss,,}
kb+=1
st+=kb]]
_[[hw,87,ml.x,st]].str=d or mn[fF(a)+2][b and 1 or 2]..a
return a end
function hr(a)
p_h+=hA(-a)end
function sv(a,b)
sw,sx,sy=a or false,b,p_fairym or hs
if(_c[[&&,sw,,,&&,sx,,,&n,sy,,]]or _c[[&&,sw,,,&n,sx,,,&&,sy,,]])return
_m[[hk
sA]]
pal(mo[p_wing+1][pI])
_[[_m,xf]]end
function sA()
if(_[[mC,la,lb]]>=0.003)_[[camera,la,lb]]
end
function sB()
_m[[
hk
sA]]
local a={}
if kF then
_i[[&&,gI,,,}
kF.p,kF.a,kF.ds=p_p,3,236,}
kF.p,kF.a,kF.ds=0,0,234]]
_i[[&&,yj,,,}
iG,yj,1]]
_i[[&&,ot,,,}
kF.p=2]]end
if _c[[&n,gI,,,&&,p_hidden,!,1,&&,pb,!,kr]]then
mp()
s=iF(p)
_g([[s.z,s.draw_ds,s.draw_a]],
p_y+.999,unpack((p_h<=0 or p_sleep)and split"160, 3"or{p_ds,p_a}))
add(a,s)end
foreach(kB,function(e)
if e.hidden then
cntd("hidden",0,e)
else
e.z,e.draw_a,e.draw_ds=e.y,e.a,e.ds
add(a,e)end end)
for i=1,#a-1 do
for j=1,#a-i do
local b,c=a[j],a[j+1]
if(b.z>c.z)a[j],a[j+1]=c,b
end
end
foreach(a,function(s)
local d,e,f,g,h=s.s,mq"8",mget(s.x,s.y),s.u,s.v-2
if(d>=2)g-=4 h-=8
if(fget(f,5)or p_fairym)h+=2*sin(pf/30)
local ba=fget(f,2)and not fE(s.t,{1,2})
if(ba)h+=d*4
if(not fE(s.draw_a,{0,2}))g-=e
if(fE(s.draw_a,{1,2}))s.draw_ds+=e*d
if(s.dm and s.dm<=4)iG(s.dm)else iH(s.p)
if not(qe or fE(s.md,{rm,rl}))then
h-=2
if(s.x!=s.prev_x)g-=4*gE(s.dr)
end
local bb=s.md==rm and not sC
local bc=d>=2 and not ba and not bb and not p_fairym and gn(s.x,s.y-1,nil,nil,t)
local bd=mt(bc)
h+=qn
for i=0,bd do
local be=(i==0 and bc)and mw or spr
be(s.draw_ds+i*16,g,h+i*8,d,ba and d/2 or d/(bd+1),gp(s.dr,3,5),bb)end end)end
function iI(a)
return a%16*8,a\16*8 end
function mw(a,b,c,d,e,f)
local g,h=iI(a)
for i=0,7 do
local ba=c+i
for j=0,15 do
local bb,bc=f and b+15-j or b+j,sget(g+j,h)
if bc!=0 then
pset(bb,ba,sH[bc*16+pget(bb,ba)])end end
h+=1 end end
function iC(a)
a.v-=2
if(a.s>=2)a.u-=4 a.v-=8
end
function sI()
foreach(kA,function(s)
iH(s.p)
local a,b=s.u,s.v+qn
if s.str then
gG(s.str,a,b)
else
local c,d,e=s.ds,s.s,s.c
if s.a<=3 then
spr(c,a,b,d,d,gp(s.dr,3,5))
elseif s.a<=5 then
jd,je=gE(s.dr)
a-=jd*e*6+6
b-=je*e*4+6+e
mz(c+e%4,d,a,b,20,20)end end end)end
function ta()
_g([[xE,xF,tc,xG,td,xH,te]],
p_mh/2,
p_h/2,sub("srpklmw",1,p_l+1),_[[mt,kI,0,13]],_[[mt,kI,2,1]],
qh*8/qi,#(tostr(p_e))*4)
tb=116-#tc*4
_m(mA)
gG(jf{"^e‡^7 ",p_h,p_m<5 and" ^cŠ^9 "or" ^cŠ^7 ",p_m},4,114,td)
gy(jf{" ^elv^7",p_l,"^e…^7 ",p_d,"^ee^7",p_e},84-te,114)end
function tf(a)
local b,c=a.x%qo*8+2,p_y%qo*8+12+qn
b-=max(0,b+gy(a.n,0,-127)-105)
if(c>=96)c-=40
jg(b,c,a.h+17,13)
jg(b+16,c+1,a.h,4,14)
gy("^e‡^7 "..a.h.."\n^6… "..tostr(a.d),b,c,nil,nil,7)
gG(a.n,b+18,7+c)end
function tg()end
function iH(a)
pal()
if(not a)return
a=tonum(a)or 0
if a<=9 and a!=0 then
iG(a)
elseif a>=12 then
pal(th[a-11])
elseif a==10 then
pal(8,12)
elseif a==11 then
pal(mB)end end
function lA(a)
hf=a
_[[_m,xi]]
_g([[tk,ti,tj,oz,xI]],jh(hH,hI))
_g([[tm,ya,yb,yc,yd,ye]],mC(p_prev_x-hH,p_prev_y-hI),fF(ti),fF(tj),tk<=1 and not gI,ji(hH,hI))
if a.bos then
tl=go"10"
if a.h<a.prev_h and _c[[&&,tl,=,0,||,hf.dmcnt,=,9]]then
_[[hf.algo,hf.dmcnt=oD,0]]end
_i[[&&,tr,=,8,&&,hf.algo,=,oD,}
hf.algo=to]]
else
a.algo=tm<=1 and tn or to end
if(tp!=a.algo)_[[hf.actc,tr=0,0]]
local b="act"..chr(a.algo+0x30)
mD=a[b]or 2
local c,d,e=tq[mD],0,0
for i=2,#c,3 do
d+=c[i]end
for i=1,#c,3 do
gi,mF,hg=jj(c,i,3)
e+=mF
if(tr%d<e)break
end
function mH()
_i[[&&,yc,,,}
nc,ne=yd,ye]]end
function mI(gi,...)
if(not gn(...))ha(gi,...)
end
function ts(fv,fw,na)
for i=-2,5,na do
nb=gd(hf.dr+i,8)
jk,jl=jm(fv,fw,nb)
if not gn(jk,jl,t,hf.t)then
_[[hf.dr=nb]]
break end end
return jk,jl end
function tt()
if(hg==3 and _[[lu,ys]])return
_[[eaa_reso=1]]
if _c[[&&,hg,>=,2,&&,xI,,]]then
_i[[&&,oz,,,}
yd=nc
eaa_reso=2
}
ye=ne
eaa_reso=2]]end
if hf.f2==10 or _[[gn,yd,ye,t,hf.t]]and not _[[iB,yd,ye]]then
_m[[
nc,ne=ts,nc,ne,eaa_reso
hf.f2=10
ib,ic=nc,ne]]
else
_m[[
nc,ne=yd,ye
ib,ic=nc,ne]]end
for i=1,16 do
ib,ic=ji(ib,ic)
if(gn(ib,ic,t,hf.t))break
end
if(jh(ib,ic)<=1)_[[hf.f2=0]]
end
function tu()end
function tv()
_m[[
eal_l,eal_m=hH,hI
eal_l-=ya
eal_m-=yb
eal_cond=nj,eal_l,eal_m
?&&,eal_cond,,,}nc,ne=eal_l,eal_m]]end
function tw()
if(_c[[&&,hf.mov,=,0,&&,hg,=,0]])nc=hH+nd else ne=hI+nd
if(_[[gn,nc,ne,t,hf.t]])a.f1*=-1
mH()end
function tx()
_g([[yf,ty,tA,yg,yh]],
hg%10)
if _c[[&&,yf,=,0]]and _[[lu,e_c,5]]then
_[[ty,tA,yg,yh=hH,ye,0,yb]]
elseif _i[[&&,yf,>,0,}
ty,tA,yg,yh=yd,ye,ya,yb]]then end
if ty and not gn(_a[[ty,tA,false,3]])then
tz=ha(81+hg\10,ty,tA)
_[[tz.f1,tz.f2=yg,yh]]end end
function tB()
_i[[&&,e_c,!,0,}
nc+=nd
ne+=hf.f2]]end
function tC()
_m[[
nc=iu,1,hH
ne=iu,1,hI]]
if _[[nj,nc,ne]]and fget(_[[mget,nc,ne]],tD)then
_m[[
mset,nc,ne,73
um,nc,ne,73
hw,13,nc,ne,t
sfx,23]]end end
function tE()
_m[[
eas_v=hI
eas_v+=1
mI,hg,hH,eas_v
sfx,16]]end
function tF()
for i=-3,3 do
for j=-3,3 do
tG,tH=p_x+j,p_y+i
if go"100"<hg and not _[[gn,tG,tH,t]]then
_m[[
hw,13,tG,tH
ha,83,tG,tH]]end end end
sfx"29"end
function tI()
while _[[lu,e_c,hg]]do
ua,ub=go(13,gb+1),go(13,gg+1)
if not _[[gn,ua,ub,false,hf.t]]then
_m[[
sfx,28
hg=0
hw,13,nc,ne,t
hw,13,ua,ub,t
nc,ne=ua,ub]]
break end end end
function uc()
mI(_[[go,hg,1]],_[[iu,2,hH]],_[[iu,2,hI]])
sfx"16"end
function ud()
a.h+=_[[hA,hg,false,hf]]end
function ue()
_i[[&&,e_c,!,0,}
nc+=ya
ne+=yb
]]end
_ENV[nf[gi]]()
return nc,ne end
function uf()
for i=0,31 do
for j=0,127 do
local a=jn(j,i)
if a>=128 or gp(mget(j,i),83,90)then
mset(j,i,a)end end end end
function iB(a,b)
return p_x==a and p_y==b end
function gw(a,b)
return lz[b*256+a]end
function kG(a,b)
for e in all(b or kB)do
if(e.id==a)return e
end
end
function ha(...)
local a=hB(...)
if(#kB<uh)add(kB,a).ac=1
return a end
function hw(...)
local a=hB(...)
a.fx=1
return add(kA,a)end
function ir()
gb,gg=p_x\qo*qo,p_y\qo*qo
return gb,gg end
function jo(a,b)
return 8*(a-gb),8*(b-gg)end
function uk()
p_u,p_v=jo(p_x,p_y)end
function hq(a)
a.u,a.v=jo(a.x,a.y)end
function hB(a,b,c,d)
hh=iF(pF[a])
if c then
gx(hh,b,c)
if(d)iC(hh)
end
if(hh.bos and ru[pI]==1)_[[hh.md=rm]]
return hh end
function um(a,b,c)
poke(b*128+a+0x4300,c)end
function jn(a,b)
return peek(b*128+a+0x4300)end
function un(a,b,c)
uo,up,uq=a,b,c
_[[us,nh=32,32766]]
local d=c and mget or jn
for i=0,6,2 do
local e=d(jm(a,b,i))
local f=fget(e)
if f&0b00001001==0 and f<nh and gp(e,1,127)then
us,nh=e,f end end
_i[[&&,uq,,}
mset,uo,up,us
um,uo,up,us
}
mset,uo,up,us
]]
return gA end
function jq(a,b)
return p_x-a,p_y-b end
function ji(a,b)
local c,d=jq(a,b)
return a+fF(c),b+fF(d)end
function jh(...)
local a,b=jq(...)
local c,d=abs(a),abs(b)
local e=fF(c)
return c+d,a,b,c<d,e==fF(d)and e!=0 end
function iw(a)
return a.h>0 and(a.md==rx or a.md==uv)end
function gn(a,b,c,d,e)
b=gd(b,32)
if gw(a,b)or not(e or nj(a,b))then
return t
elseif not c and iB(a,b)then
return t end
local f=mget(a,b)
return fget(f,0)and d!=3 or d==1 and not fget(f,2)or d==0 and fget(f,2)end
function uy(a,b,c,d,e,f)
b,ju=gd(b,32),
fE(a,{gb-1,gb+16})or fE(b,split"0,16,32")
if hs or p_fairym then
if(ju)return
else
local g=mget(a,b)
if fget(g,0)and not fget(mget(rf,rh),3)or not c and fget(g,6)or p_wing==0 and fget(g,5)or p_spboss and ju then
return end end
jw,uA,uB=gw(a,b),f,d
if jw and not _c[[&&,uA,,,&&,jw.md,=,uv]]and fE(jw.o,{0,e})and not _c[[&&,uB,,,&&,jw.md,=,rx,&&,jw.o,=,0,&&,jw.id,!,rt,||,jw.id,=,qj,]]then
return end
return t end
function gE(a)
return unpack(nk[(a or 8)+1])end
function jm(a,b,c)
local d,e=gE(c)
return a+d,b+e end
function kq(a,b)
foreach(b,function(fA)
add(a,fA)end)end
function mt(a,b,c)
local b,c=b or 1,c or 0
return a and b or c end
function go(a,b)
return flr(rnd(a+1))+(b or 0)end
function iu(a,b)
return go(a*2,(b or 0)-a)end
function hp(a)
return(a+1)%32767 end
function mC(a,b)
return abs(a)+abs(b)end
function fF(a)
return a==0 and 0 or sgn(a)end
function gd(a,b)
return(a+b)%b end
function lu(a,b,c)
return a\(c or 1)%(b or 2)==0 end
function gp(a,b,c)
return a>=b and a<=c end
function iD(a,b,c,d,e,f)
return gp(a,c,d)and gp(b,e,f)end
function nj(a,b)
local c,d=ir()
return iD(a,b,c+1,c+14,d+1,d+14)end
function fE(a,b)
for fx in all(b)do
if(a==fx)return t
end
end
function mysplit(a,b,c,d)
if(not a)return{}
local e,f,g={},kc[(c or 2)],d or 1
for fv in all(split(a,b,false))do
e[g]=f(fv)
g+=1 end
return e end
function hE(a)
return split(a,"\n",false)end
function gD(a,b,c,d)
local e={}
foreach(hE(a),function(fv)
add(e,mysplit(fv,b,c,d))end)
return e end
function jf(a,b)
local c,b="",b or""
foreach(a,function(s)
c..=tostr(s)..b end)
return c end
function nw(a,b)
for fy,fx in pairs(b)do
a[fy]=fx end
return a end
function iF(a)
return nw({},a)end
function vg(a,b)
local c={}
for i=a,b do
add(c,dget(i))end
return c end
function nz(a,b)
local c,b={},b or 1
for i=b,a do
c[i]={}end
return c end
function vh(a,b,c)
foreach(c,function(ie)
local d=ie[1]
if(not a[d])a[d]={}
local e=a[d]
for i=1,#ie do
local f,g=b[i],ie[i]
if g then
if tonum(g)then
e[f]=tonum(g)
elseif g!=""then
e[f]=g end end end end)end
function vk(a,b,c)
foreach(gD(b,c and"",c),function(l)
local d=deli(l,1)
if#l>=2 then
a[d]=l
else
a[d]=l[1]or 0 end end)end
function hk()
memcpy(0x5f00,0x5d80,64)end
function vl(a)
cls(a)
hk()end
function jg(a,b,c,d,e)
if(c>=1)rectfill(a,b,a+c,b+d,e)
end
function iG(a,b)
local c,d={},tonum(a)>=0 and vn or vo
for i=0,15 do
local e=peek(0x5f00+i)&15
for j=1,abs(a)do
e=d[e]end
c[i]=e end
pal(c,b)end
function mz(a,b,...)
local c,d=iI(a)
b*=8
sspr(c,d,b,b,...)end
function vs(a,b,c,d)
spr(a,b,c,2,2,d)end
function hm(a,b)
local c=split(a,"|",false)
return(c and#c>=2)and c[1]or a end
function jz(a)
return false end
function vu(a,b)
camera(-a,-b)end
function gy(a,b,c,d,e,f)
local g,a,ba,bb,bc,bd=jz(e),hm(a,e),b,c,0,1
local be,bf,bg,bh=d or 7,unpack(g and{6,10,10.16}or{4,9,15})
if(f)bg=f
pal(7,be)
while bd<=#a do
local ca=sub(a,bd,bd)
if ca=="^"then
bd+=1
local cb,cc,ca=bd+1,bh,sub(a,bd,bd)
if ca==">"then
while cb<=#a do
local ce=sub(a,cb,cb)
if ce=="/"then
break
elseif ce=="^"then
cb+=1
elseif ce!=""and ce!=""then
cc-=.5 end
cb+=1 end
ba=cc*bf+b
else
be=d or tonum("0x"..ca)
pal(7,be)end
elseif ca=="\n"or ca=="/"then
ba=b
bb+=bg
else
if ca!=" "then
camera()
print(ca,ba,bb+1,be)end
ba+=bf end
bc=max(ba,bc)
bd+=1 end
camera()
return bc end
function gG(a,b,c,d,e)
local f=jz(e)and vx or vy
memcpy(0x5c00,0x6000,0x180)
memset(0x6000,0xff,0x180)
local g,h,ba=b-1,b+1,gy(a,0,0,8,f)-1
color(d or 0)
for i=0,5 do
local bb=c+i-1
local bc=bb+2
for j=0,ba do
if(pget(j,i)==8)rectfill(g+j,bb,h+j,bc)
end
end
gy(a,b,c,it,f)
memcpy(0x6000,0x5c00,0x180)end
function mq(a,b)
return pf\a%2*(b or 1)end
function gf(a)
return hu(a,1)end
function hu(a,b)
return oF[tonum(a)]&b==b end
function kg(a,b)
music(a,b,3)end
function gx(a,b,c)
local d=a.fx!=1
if(d)hd(a)
a.x,a.y=unpack(c and{b,c}or b)
if(d)hd(a,t)
hq(a)
return a end
function ky(a,b)
vE,vF=a,gd(b,32)
_m[[
p_x,p_y,p.x,p.y=vE,vF,vE,vF
ir
uk]]end
function im(a)
return mysplit(a,"",3,0)end
function vG(a)
return gD(a,"",3,0)end
function hj(a)
if a then
if type(a)=="function"then
a()
else
_m(a)end end end
function _s(a)
return a end
function fz(a)
return a end
function _m(a)
local b={}
foreach(hE(a),function(jC)
if(jC!="")add(b,_(jC)or false)
end)
return unpack(b)end
function gh(...)
return unpack(mysplit(...))end
function jD(a)
local b,c={},split(a)
local d=deli(c,1)
for i=1,#c do
b[i]=gC(c[i])end
return d,b end
function _(a)
if sub(a,1,1)=="?"then
_i(sub(a,2))
return end
gr,gs=gh(a,"=")
if gs==nil then
local b,c=jD(a)
return _ENV[b](unpack(c))
else
local d=#gr
local e=sub(gr,d,d)
if e=="+"or e=="-"then
local f,g=gC(gs),sub(gr,1,d-1)
if e=="+"then
_ENV[g]+=f
else
_ENV[g]-=f end
else
if type(gs)=="string"then
local b,c=jD(gs)
if type(_ENV[b])=="function"then
_g(gr,_ENV[b](unpack(c)))
else
_g(gr,_a(gs))end
else
_g(gr,gs)end end end end
function gC(a)
if(type(a)!="string")return a
if(sub(a,1,1)=="T")return sub(a,2)
local b=_ENV[a]
if b then
return b end
if(a=="false")return false
local c,d=gh(a,".")
if d then
return _ENV[c]and _ENV[c][d]or(tonum(a)or a)end
if b==false then
return false end
return tonum(a)or a end
function _a(...)
local a={}
foreach(split(...),function(fD)
add(a,gC(fD))end)
return unpack(a)end
function _g(a,...)
local b,c={...},split(a)
for i=1,#c do
local d,e,f=b[i],gh(c[i],".")
if f then
_ENV[e][f]=d
else
_ENV[e]=d end end end
function _i(a)
local b,c,d=gh(a,"}")
if _c(b)then
_m(c)
return t
elseif d then
_m(d)end end
function jj(a,b,c)
local d={}
for i=1,c do
d[i]=a[i-1+b]end
return unpack(d)end
function _c(a)
local b,c,d=split(a),t
for i=1,#b,4 do
local e,f,g,h=jj(b,i,4)
if(not f)break
if g==""then
d=_ENV[f]or false
else
local ba,bb=gC(f),gC(h)
if g=="="then
d=ba==bb
elseif g==">"then
d=ba>bb
elseif g==">="then
d=ba>=bb
else
d=ba!=bb end end
if(sub(e,2,2)=="n")d=not d
if(sub(e,1,1)=="&")c=c and d else c=c or d
end
return c end
function wf()
for fy,fx in pairs(p)do
_ENV["p_"..fy]=fx end end
function mp()
for fy in _[[pairs,p]]do
p[fy]=_ENV["p_"..fy]end end
function kd(a)
return a end
function ke(a)
return tonum(a)or(a!="false"and a or false)end
function kf(a)
local b=ord(a)-0x30
return b>=-12 and b or""end
function wg()
_g([[p,yi,pb,pm,uh,oA,kb,le,lv,oB,lD,oC,oD,nf,nk,lB,mn,lG,mB,yj,ot,yk,oz,yl]],{},{},kr,ks,40)
wh=fz[[
"16
<boss
3
"15
<s

"19
<boss
22
"23
<boss
24
"22
<boss
21
|c
0,41
|c
0,42
"24
<boss
14
|r
fairym,1
"25
<boss
19
"27
<ae
26,-10,4
|c
4,27
"26
<boss
33
<sp
-58,15
|r
d,0,
|r
m,0,
|ae
28,-56,4
"28
<r
wing,0
|r
snow,1
|endf

|m
50
|edc
122,23,25




|edc
105,23,24




|edc
86,9,22




|edc
71,9,23




|edc
39,27,19




|edc
25,21,16




|edc
8,8,20




|end2
]]
wi,wj=fz[[
n,elle
x,7
y,14
z,0
u,7
v,14
h,100
mh,100
m,40
mm,40
dr,6
d,1
a,1
sn,128
ds,128
s,2
e,0
l,1
p,0
wing,0
dm,8
prev_x
prev_y]],fz[[
x
y
z
u
v
h
c,0
d
ds
dn
o
mov
act1
dr,8
sn
md
f1,0
f2,0
ac
mx
ay
t
s,1
a,1
prev_x
prev_y
fx
algo,1
dmcnt,0
prev_h,1
act2
act3
actc,0
rn,0]]
wk=fz[[
0310
1110
2210
3622340
4510
5550340551340
6242
7710
8282
9283
:62<340
;480
<A10
A>11
B480
C480
D>11370
O91T3:0
P9173M091_3M0
c281460380
d926281846480
e>84681=40180
f281681480@42
g28169<34064<
h284>1191c64Œ>1164Œ91c@21
j>41=@H?88]]
wl=fz[[
id,n,fx,rn,sn,act1,act2,act3,h,d,p,s,md,a,dur,mov,f1,o,bos
id,n,fx,rn,sn,act1,act2,act3,h,d,p,t,f1,mov,o,a,dur,ay,z,ac
id,n,fx,rn,sn,s,a,p,dur,md,o,dr,fx,ac,ay,t]]
wm=fz[[
18,seal,,,201,0,,,99,,,,,2
41,ayame,,,165,54,1,,25,3,12,2,1
42,momoka,,,164,54,1,,25,4,13,2,1
16,catherine,,,132,51,2,20,20,10,0,2,1,,,,,,1
19,lamia,,,136,52,,20,35,5,,2,1,,,,,,2
22,dragonurse,,,164,54,,20,50,5,,2,1,,,,,,4
23,graves,,,140,53,53,17,45,3,,2,1,,,,,,3
24,fairim,,,168,55,,17,60,3,,2,1,,,,5,,5
25,wizard of legend,,,172,56,,17,70,3,,2,1,,,,,,6
26,ruin,,,129,58,,20,99,3,11,2,1,,,,6,,1
27,erity,,,162,,,,,,10,2,1,0
28,erity,,,162,,,,,,10,2,1,0
29,ruin_ed,,,130,58,,,1,3,11,2,1
30,wizard of legend,,,174,56,,,60,3,,2,1
71,erity_ed,,,128,,,,,,10,2,1
]]
wn=fz[[
1,mew,,4,192,4,6,19,1,5,,,-1
2,baty,,6,194,9,9,19,3,4,,2
3,whity,,1,195,4,1,,3,8,2,2,-1,1
4,geko,,3,210,2,2,,3,5
5,eyebo,,1,226,5,2,,4,6,,2,-1
6,kobbit,,3,212,51,1,,3,4
7,uouo,,3,230,8,8,,2,20,,1
8,meg,,1,214,3,11,,6,1
9,nez,,10,246,2,2,19,2,1
33,pix,,4,244,2,2,,2,25
34,gol,,,224,9,6,,5,49
36,firel,,4,242,9,9,,1,5,,2
37,drapy,,7,240,9,6,,3,10,,2
38,guard,,1,196,1,1,,4,20
39,knig,,,197,1,1,,30,20,-2
40,pinc,,2,193,4,1,,1,15,-3,,-1
47,shiromi,,2,231,8,2,,10,5,1,1,-1
49,slimy,,4,199,51,51,,7,10,13
50,bones,,8,208,9,1,,8,3
51,slam,,10,198,9,9,,7,1
52,mag,,1,215,10,11,,6,10,12
53,eyedo,,1,227,5,2,,2,3,1,2,-1
54,drapy,,7,241,2,6,,5,10,12,2
72,stone,,,247,0,,,10,0,1,,,,4,0
80,meteor,,,216,7,7,,1,30,,2,,1,3,2,16
81,shot,,,228,7,7,,1,20,,2,,1,3,2,8
82,sleep_shot,,,228,7,7,,1,5,12,2,,1,3,2,8
83,burst,,,232,0,,,1,20,,,0,,3,2,2
84,genfi,,2,233,31,,,3,10,,2
85,fish_egg,,1,204,32,,,3,10,,2
87,disp_dmg,1,,192,0,,,1,0,,,,,,0,12,2.8,1000,1
90,homing_shot,,,228,12,12,,1,16,2,2,,1,3,2,8
202,calbone,,,209,1,1,,4,6,1,,-1
]]
wo=fz[[
11,home,,,234,2,,0,,5,2,,,,,2
12,ho,1,,234,2,0,3,1,,,,,1
17,ba,,,200,1,2,,,1,,,,,,2
86,ho_emit,1,,234,2,0,,2
73,elle_slip,1,,160,2,0,,3
74,elle,1,,128,2,0,,3
75,brust_mini,1,,202,,5,,5,,,,1
76,fire_bg,,,216,1,2,,,1,,,,,,2
78,elle,1,,128,2,
88,hz,1,,234,2,9,0,30000
13,br,1,,202,,4,,5,,,,1
14,zzz_img,1,,64,2,0,,20
31,zz,1,,123,1,0,,20,,,1,,,0.8
15,check point,,,248,,1,,,1
61,bo,1,,220,1,0,,,,,,1,,0
62,ss,1,,221,1,0,,,,,,1,,0
63,arrowl,1,,68,1,0,0,1,,,
65,arrowt,1,,69,1,0,0,1,,,
67,arrowr,1,,68,1,0,0,1,,,3
69,arrowb,1,,219,1,0,0,1,,,
98,pop,1,,94,1,0,,40,,,1,,,1
]]
wp=fz[[

new game,--,options
game level ... ,play speed ... ,game mode  ... ,elle's level.. ,time watch ... ,stage  ,music  ,sfx    ,exit]]
om=fz[[
easy,normal
normal
wait,active
normal
off
--
--
--
]]
wq="40,150,450,800,1300,9999,30000"
wr="13,2,3,4,12,6,7,13,6,10,11,12,13,14,6"
ws="a,p,s,u,v,ac,dr,ds,dur"
wt=fz[[
.5,.5
.8,.7
]]
on="30000,90"
wu=":6622D9D<;;MMNMa="
wv=fz[[
000000
00000000000000000
0426
3  13
 4 40]]
ww="0x1100.1248,0x1100.2481,0x1100.4812,0x1100.8124"
wx=fz[[
^9,^8
^7,^7
^amp+,^bhp+]]
wy=fz[[
-1,0
-1,-1
0,-1
1,-1
1,0
1,1
0,1
-1,1
0,0]]
wz=fz[[
028<35679:;<=>8?
0431<5673<=>9:3?]]
wA=fz[[
5,14
]]
wB=fz[[
:26152
0123456789:;<=>?011125===233=1=2512125=4>444==>4511355=6::;33=:6522545=?>44:>244055555=6444665465=====66=>636=665=46?667>???76?72=>:>4=>889:>>>>524:44>?89::;>>?534;446?9:::;>??5343:63?:::;<=::===3>667>;;<<==;51==25=6>>>====65=>:446?>>?:==>?52464667>??:;6??
158;9677>:7:6>?:
001122=:24?3=5=>
]]
wC,wD=fz[[





0|1|2|3|4|4|9|7|8|14|10|11|12|4
0|2|1|4|4|4|15|7|8|9|10|9|12|13



0|1|2|0|4|5|6|7|8|9|0|0
0|1|2|7
0|1|2|12|13|5|6|7|8|6|10|7|12|13|14|7

0|1|2|3|4|5|6|7|3|11|10|11|12|13|7
]],[[





0|1|2|3|4|4|9|7|8|14|10|11|12|4
0|2|1|4|4|4|15|7|8|9|10|9|12|13



0|1|2|4|1|5|8|9|8|9|7|9|8
0|1|2|15|1|13|9|15|8|9|7|9|8|2
0|5|1|0|0|0|1|8|2|2|10|2|0|0|14|13
0|1|1|8|2|13|9|8|8|9|7|9|1|0|5

0|1|2|3|4|5|6|7|13|6|10|11|12|13|7]]
wE=fz[[
1,20,30
5,49,30
12,83,14
15,-8,14
16,119,14
20,8,7
24,39,3
30,126,30
31,120,24
32,110,29]]
wF=[[
mH,tt,tu,tv,tw,tx,tB,tC,tE,tu,tx,tx,tF,tI,uc,ud,ue,]]
wG=[[
cartdata,doc1oo_dw_cart
poke,0x5f5c,6
poke,0x5f5d,6
poke,0x5f34,1
memcpy,0x5d80,0x5f00,64
]]
wH=[[
yo=-10
oA=99
sfx,16
ph
]]
km=[[
ir
ky,xs,xt
reload,0x2000,0x2000,0x1000
memcpy,0x4300,0x2000,0x1000
resume_pos_x,resume_pos_y=p_x,p_y
]]
wI=[[
pal
jg,0,62,127,9,pd
fillp
gG,Tpress z key,43,64,3]]
xa=[[
phe_dx,phe_dy=gE,p_dr
xx,xy,lr=p_x,p_y
hw,13,p_x,p_y,t
gI=false
lF,qH
sfx,29]]
xb=[[
&n,fG,,,||,fG.o,=,lD,}
awh_fx=hw,75,p_x,p_y,t
awh_fx.dr=p_dr
gx,qH,xB
sfx,27
ky,rf,rh
pwh_wkfail=false]]
xc=[[
gG,T^f (c) 2020 1oogames & doc1oo,8,122,0,t
gG,T^>^7- minimal cart ver. -,4,68,0
]]
xd=[[
gy,T^c    can't i save my sister?,0,22
gy,T^c           erity,0,32
gy,T^> ^6elle falls asleep,0,52
pal
]]
xe="never give up!,good night."
lc=[[
&&,gt,=,0,}
ky,resume_pos_x,resume_pos_y
p_h,p_m=p_mh,p_mm
p_sleep,p_spboss,p_fairym=false,false,false
sfx,16
yo,pb,pm=99,kn,ko
prev_bg=99
]]
xf=[[
?&&,kI,,,}iG,-1
?&&,p_fairym,,,}iG,-2
?&n,hs,,,}map,gb,gg,0,qn,16,16,sw
]]
mA=[[
xE+=2
dps_mm=p_mm
dps_mm+=2
jg,0,112,128,16,xG
line,0,112,127,112,1
jg,4,121,xE,3,1
jg,5,122,xF,1,14
jg,4,124,dps_mm,2,1
jg,5,125,p_m,0,12
gy,tc,tb,121,7,t
]]
xg=[[
pwh_lx,pwh_rx,pwh_ty,pwh_by=gb,gb,gg,gg
pwh_rx+=15
pwh_by+=15
pwh_home_inblk=iD,qH.x,qH.y,pwh_lx,pwh_rx,pwh_ty,pwh_by]]
xh=[[
&&,p_spboss,=,false,&&,p_x,>=,0,||,pwh_home_inblk,=,t}
awth_hx,awth_hy=qH.x,qH.y
ky,awth_hx,awth_hy
uk
gI=t
sfx,23
}
sfx,30]]
xi=[[
hH,hI,hg=hf.x,hf.y
nc,ne,tp,e_c,nd,tr=hH,hI,hf.algo,hf.c,hf.f1,hf.actc]]
xj=[[
?&&,rC,!,218,}rF,ow,gbe_x,gbe_y
]]
xk=[[
?&&,hs,,,}ha,27,-8,6
?&&,pI,=,11,}ha,42,85,6
?&n,hs,,,&&,sC,,,}ha,71,gbe_px,p_y
]]
xl=[[
edc|
rG
sh=t
ky,md,me
qm
kz
<endf|
sC=t
dt_hop_freq=false
<c|
rH
<r|
sa
<sp|
p_x=md
p_y=me
qm
kz
<ae|
ha,md,me,oy
<m|
kg,md
sb
<s|
resume_pos_x=p_x
resume_pos_y=p_y
p_h,p_m=p_mh,p_mm
sfx,16
<boss|
p_spboss=1
kg,md
sb
sc
rI
<end2|
run
]]
oo=[[
split,xl,<
im,yz
split,yu
gD,wp
gD,wA
gD,wt
vk,pH,wE
vk,tq,wk,3]]
_g([[lB,pi,lG,mB,mn,nf,nk,ym,th,oF,ru,oI,oH,oG]],_[[nz,3,-1]],mysplit(on,",",2,0),_[[split,ws]],_[[split,wr]],_[[gD,wx]],_[[split,wF]],_[[gD,wy]],_[[gD,wi]],_[[vG,wz]],unpack(_[[vG,wv]]))
_g([[p_wing,pg,la,lb,to,tn,oD,pI,qo,rx,rl,uv,rm,vy,vx,lD,oC,qj,rt,qB,yn,yo,oA,se,qe,qz,oB,pf,yp,yq,le,lv,qh,kb,yr,ys,qy,os,kl,yt,qn]],unpack(im":01001230@01231234;A?Nkk112400000000000000"))
_m[[
reload,0,0,0x4300
vk,p,wi
wf
vk,yi,wj]]
for fy,fx in pairs(nk)do
lB[fx[1]][fx[2]]=fy-1 end end
function xm()
_g([[yu,qc,px,lz,yv,tq,xo,pH,si,mo,yw,yx,qb,yy]],"no,ev,ev2",_[[split,wq]],unpack(nz"14"))
_g([[oE,mo,pe,yz,yA,sH,vn,vo]],{om},{_[[gD,wC,|,1,0]],_[[gD,wD,|,1,0]]},_[[split,ww]],_[[split,wu]][kl==1 and 2 or 1],unpack(_[[vG,wB]]))
_g([[xp,rA,yB,pt,pk,pA]],_m(oo))
foreach(_[[split,wh,"]],function(e)
_g([[xn,yC,yD]],gh(e,'<'))
if xn then
add(xo,{xn,_[[split,yC,|,false]],_[[split,yD,|,false]]})end end)
_g([[yE,yF,yG,yH,yI,za]],_[[gD,wm]],_[[gD,wn]],_[[gD,wo]],unpack(_[[gD,wl]]))
_m[[
vh,yv,yH,yE
vh,yv,yI,yF
vh,yv,za,yG

vh,yv,yB,xo]]
foreach(xp,function(op)
local a,b=gh(op,"|")
si[a]=b end)
mg={_s[[hr,-25]],function()
hr(-p_mh)end,function()
p_m+=_[[hA,10,t]]end,function()
p_m+=hA(p_mm\2,t)end,_s[[
hr,20
sfx,-1
sfx,14]],function()
oq=p_l*5
_[[p_e+=oq]]
_(_s[[hA,0,t,false,Texp+]]..oq)end,function()
_m[[p_wing=1
mf=p
]]end,[[
p_mm+=10
p_m=p_mm]],[[
p_mh+=20
p_h=p_mh]],[[
p_d+=1]]}end
__gfx__
0000000031dccccc000000003333333377777777311b310355111111ccccccc3400000004494494d4444444422222222ccccccccdd5ddd5d4441444100000000
0000000031dccccc00000000333333337777777711b3331151d66666cccccc1374000000df949f4d4444444422000022ccccccccd565d5651111111157777775
00000000331dcccc000000003333333377777777033bb3315155ddddccccc133644000004f49494d4444444420000002cccccccc56665666212441446777777d
000000003331cccc00000000333333337777777713b1111015d57777ccccc133764240004949444d2222222200000000cccccccc66d666d6000001116677776d
00000000333311cc0000000013333333777777771311131115d5d666cccc133367694000d494944d4444444400000000000000005ddd5ddd01101221566666d5
000000003333331c0000000001333333777777770113133b51111dddcc11333376664420d94f944d444444440000000076557655765576550000001107677d60
000000003333333c000000003133333377777777313301b36d555156c1333333776464404949444d4444444420000002665d665d665d665d0112024407677d60
00000000333333330000000031313333777777773131011b556d55113333333377764942d944494d222222222200002266666666666666660001111107677d60
776337774941444131331113777777e000000000cccccccccccccccc01111100999999114444042449ff9f40ccc61ccc6d6d6d6d567666d107677d6007677d60
66637666111111111b1131317fffff1e00000000cccccccccccccccc1111100194449991242044449f99ff9dcc6d51ccd6d006d65555555107677d6007677d60
6663766641444144b313b3137fffff1100700070ccccccccc7777ccc11131111944959492222022299ff79f4c6ddd51c6d00116d567656d107677d6007677d60
3333333311111111333333337fffff1100700070cccccccc77777777000111119495494500000000ff79ff946ddddd51d60111d65555555107677d6007677d60
3777776344414941133113137fffff1107650765cccccccc7777777c011111119954494524444420499f9942ddddddd56d01116d565666d107677d6067677d65
7666666311111111311131317fffff1107650765ccccccccc7777ccc11100131999999454424240244444442576666d1d60111d65555555107677d6076666dd6
7666663341444144131313b10eeeeee107650765cccccccccccccccc1100000119444495222222204dd4d4d1576006d16d05556d567656d107677d6057677675
33333333111111111b33333300eeeeee76607660cccccccccccccccc131011111155555900000000dddd4dd0576006d1d6d6d6d65555555107677d6000000000
3333333366666666333333334444944444444000000444444444499433333333d5deeed51111111375111111111115702212122288888888222222220b3b3305
333333336aaaaa6333e3333344294444444000000000044449944994333333335deeed5d0000003076d766666666d67021222122889888e822222222b3b3b330
333333336a7777c33e3e33339424442444000000000000444994499433333333deeed5dd00000100765ddddddddd5670212781228a898888228228223b3b3330
333333336a7666c333e333339224442440000000000000044944449433333333eeed5ddd0000100076d777777776d670218828118888888822888822b3b33330
333333336a7666c333333333422242244000000000000004444494443333333beed5ddde1313131176d766666666d6701112212288888888281881823b33b310
333333336a7666c3333333b324424222000000000000000099499494bb33bbb0ed5dddee00100000765ddddddddd567022212122888888a822888822333b3110
3333333366ccccc333333b3b2422222300000000000000009949949400bb0004d5dddeee0100000076d666666666d67022221272888889892222222213311110
333333336c333333333333b332222233000000000000000094444494440044445dddeeed100000006511111111111560222118288e8888882222222201111105
1151555055555550666666663fffff331dddcccc1111111134442211ccccccccbbbbbbbbbbbbbc00311b31010666666000000000000000005200055555551111
111515d055d5d5d06aaaaa637fffff931ddcccccdddddddd442111ddccccccccbcccccccccccbc3011b333116776665500000011110000005027702555551111
111151505d5d5d506a7777c3fff6ffff1dddccccdddddddd4211ddddccccccccbc3333333333bc35033bb3316776665500000111111000005277772255551111
00000000111111106a7666c3ffffffff1ddcccccdcdcdcdc21dcdcdcccccccccbc3555555553bc3513b111106666665500001555555100005207700255551111
11101555555055556a7666c3f9fff7ff1dddcccccccccccc21ddccccccccccccbc3333333333bc35131113116666665000005544445500002207700511115555
111051d5d5d055d56a7666c3ffffff9f1ddccccccccccccc1ddcccccccccccccbbbbbbbbbbbbbc350113133b6666660000054444444450002206602211115555
1110151d5d505d5d66ccccc33ff9fff61dddcccccccccccc1dddcccccccccccc0ccccccccccccc35313301b36555000000444999999444005277770211115555
00000111111011116cc3333333fffff31ddccccccccccccc1ddccccccccccccc00333333333333353131011b0d55000004999999999999400500005011115555
000011111110000000000dc676c000000001100000010000055155050000000000000000491114416165717100dd5555122888880000000011111111dddeeedd
00111111111110000003cc676c66c000001710000017100003312201222222220000000011111161d615d7770d55555511288e880000000166666666ddeeeddd
0111118111111100003bc6cccc673c0001710000017171000331220144444444000000004147714451661d1d055555501129888800000011dddddddddeeedddd
011111881111111003b3cc3c676333d01710000017101710033122014444444400000000111161111d6d616100000000118888880000000177777777eeeddddd
11188855555111100cccbbccc6cc33d001710000110001100dd1550144444444000000001411194116661d1655500dd5112888880000011166666666eeddddde
111185f555551111cc3bbb3c6cccc333001710000000000003312201444444440000000011711111511111155550d555122888a800000101ddddddddedddddee
11115fff555556c1cdbbb333ccc6c3350001100000000000100100109999999900000000476614440511dd5155005555112289890000000166666666dddddeee
11115ffff55557c1d3bb3c33cc676335000000000000000099999999011055010000000011111111511d0dd100000000112288880000001111111111ddddeeed
111122ff222557c1d3b3b33cc3cc66513333333300444400004444000277720033322233311111130000000000111777000880f0000000000000000011224443
66665fffff5556c6dc33ccc333c66c5133333333047999400479994027eee7203328e72318888821000a800001177666008888f007707780e77ff77edd111244
7777777777777776cc3ccc3b336ccd1133333333479aae94479aae927e988e72328e76828888888200a7a80011776761088788807ee7ee78e77f7f7edddd1124
677777777777777d0ccc66b33ccccd1033333333499ee994499ee99278888872288888828a88a882aa777aaa17667611887778887e8e8e78e77ff77ecdcdcd12
d7777777777777d00c6c7c3cccccd110333333334f9999e44f9999e2f78887ff88888882888888820a7a7a8076776761077777e07e888e78e77f777ecccccc12
0d77777777777ddd00c6ccccc33311003333333344ffff4449fff942ff777fef99999992332992330aa8aa8077667611077747e007e8e780e777777eccccccd1
000d67777766dd77000ccc3333d1100033333333044444404f9944e2efffffeffffffff232ff92130a800a8076776110077747e1007e7800dffffffdccccccc1
0000000000000d7700000333d110000077feee030000000004ff99402efffee22222222332ff2111000000007d111100001111110007800000000000ccccccc1
0000010022222222c00000000000000c7fe00ee033333333333333333333333333333333444ffffff99994440b3b330511122112ddd707dd11155d6511442144
01000011211111220c000000000000c0fed030dd033333333333333333333333333333334ff4444444444994b3b3b33022228221dd70007d651155d512111114
10101100218888e2c0cc00000000ccc0edd033dd0707e07fe0337e0337e0337e037fe033f444f4f4f4f4f4493b3b333022898822d7000007ddd1111514212411
00110010218888e21c0cc000000ccc0cedd033dd0f0dd0f0dd070dd070dd070dd0f0dd0344f4f4f4f4f4f4f4b3b3331028888882d7000007777d555144111121
01011000218888e20110c00000ccc0c1edd033dd0e0dd0e0dd0e0dd0eddd0e0dd0e0dd032ffc77777777c4f23b33b11028888888d70000076666d55111124410
00100010218888e20c111c0000c1ccc1edd03dd00d0dd0d0dd0d0dd0d0000d0dd0d0dd03244c77777777c442333b1110888888a8d7000007dddd551542144112
0100010022eeeee200c11cc00ccc1c10eddddd0030ddd0d0dd00ddd00ddd00dd00d0dd03277c77777777cd621311111088888989dd77777d666d551544111121
000100002222222200c100c0c0c11c11000000033300000000030dd03000030003000003777dffffffffdd66011111058e888888dddddddd1111115512142142
b0b0bbbabb3b003b0000000cc0100000333eee033ee03333333ddd003ee033333333333344944945666666d077771000f9fff999fff999f61111111261657171
00000b3aabb3000000000ccc1c0c0000333eee033ee03333333000033ee033333333eee0df949f45655555d511711000999f99999f99999911128221d615d777
00b003baab3b00000000ccc011ccc000333eee0e0ee0cc0ee0330ccc0ee03333333ee0004f49494565b115d50711000099fff999fff999f9112988225d661d1d
033033bbab330300000cc0011111cc00333eee0e0ee0000eeee0cc000eeee03cc03eee0349494445651115d5777707779fffff9fffff9ff91288888210606161
00030bbabbb3300b00cc1c110111c0c0333eee0e0ee0cc0ee000cc000e0ee0cc0c00eee0d4949445651115d511111171f9fff999fff999f61188888816661d16
00b00bbaabbb00000c10c11001111c11333eeeeeeee0cc0ee0030ccc0e0ee0ccc0030ee0d94f9445655555d500001710999f99999f999999118888a851111115
0030b3baab330b30c1c11100100111cc3330ee0eee00cc00eee030000e0ee00ccc0eee00494944450cccccd50000777199fff999fff999f9129889890511dd51
0b3003bbabb30033c111000000100c113333000000030003000033333000003000000003d944494500333335000011119fffff9fffff9ff912288888511d0d01
00005555551000000000555555100000000088888800000077008888870000000000fefefe00000000000ae9eae0000000011111110000000000111111100aa0
0085555555551000008555555555100077088888877700000e7888887e780000a00aa777aeee00000a00aa777aeee0000011111111110aa0000111111111a00a
008555555555510000855555555551000e7888887ee780000e888888eee780000aaeeeeeeaefe00000aaeeeeeeaeae00011111111111100a001111111111110a
8855f555555555008855f555555555000888f8888e7880800888f88888e780800aeeeeeeeeaeee0000aeeeeeeeeaeee0011177771111100a00111777711111a0
055fff5555555510055fff5555555510088fff8888788880088fff8888888880eeefeeefeeeeee000eeefeeefeeeeee011177777771111a00111777777711110
055ffff55f551510055ffff55f55151008ffffff8288880088fffff8f88888007effeefffeeeee000eeffeefffeeeee01177ff777771110001177ff777771110
055d1fff11d511100551ffff11f51110822ffff22f8888008822fff2228888007eddfeffddeeee007eeddfeffddeeee01172fff72277110001122fff22777110
0157177771751110015717777175111082f277772788820082f27777272822007ef1777717deff007eef1777717deff00172777f2771f00000172777f2771f00
0157d7777d751f100157d7777d751f1082f877778782220082f87777878222007efe7777e7effe007eef3777737effd00078777787ef000000078777787ef000
0015f77ee7f511000015977ee7951100082f7eee7e822207082f7eee7e8267007eef77e77feee00007eef77777feee00000f77e77f0077f00000f77777f00000
00015187785110000001158778151000000215b555080007000215b5550886707eeeee99eeeee00007eeeeeffeeeee0000f7011110077f000000001111000000
00000f8888ff00000000ff8888f00000007755355f50007600075535755000677fe077f776ee0000070e077f776ee00c000701d11117f0000007701d111177f0
0000f8888800000000000088888f0000007e55577755076000765557e7555067f796777776f000cc070f6777776f0ccc00001111f111000000ff01111f111fff
0000088888800000000008888880000000000057655556000070005555555770070009ff9ccffcc000ff009ff9cffcc00000111f1111160000000111f1111160
0000088880f7000000000f08888000000000055555555500000005755557500007000cfffccccc00007000cfffccccc000116111111661000001161111116610
0000007000000000000070000700000000007775555777000000007755577000070000ccccccc0000070000ccccccc0000011666666110000000116666661100
0000000001100000000000000000000000007777777000000000777777700000a0000a9999990000ae00a999999900009990000ddddddd550000000ddddddd55
0000000017710111000055555510000000077777777770000007777777777003ae099af9999990000aa99af999999000809005ddddddd550999005ddddddd550
000000001771177100855555555510000007bbbbbb7773003007bbbbbb777b030aa99af9f9999e00009999f9f9999e0000905ccccccd550080905ccccccd5500
0008000011f11771008555555555510000bbbbbbbbb7333030bbbbbbbbb73bb3009f9fffff9f9ee0009f9fffff9f9ee00990cccccccc55000090cccccccc5500
00880001188101f18855f555555555000bbbbbbbbbbb33303bbbbbffbbbbbbb3099f9fff9ff99ee0099f9fff9ff99ee0090cccfcccccc500099cccfcccccc500
80881111188881f10555ff55555555100b2bbb3b3bb2b3301b2bfffbbfb2bbb1099999f999999ee0099999f999999ee0090c11ff1111c000090cccfcccccc000
8815555111188881055ffff55f5515100bb22bfb322bb3301bb22ffff22bbbb10991999f1999ee00d991199f1199ee77070cc177711cc000090c1177111cc000
8855555551118881055f1fff11f5111000bf2ffff27bbff01b2f27777272bff100991f97f119ee0706991797f11ee77009ddc7777fcccdf00700c7777fccc000
05555555551188810151177771151110000f8777787bff001b0f8777787eff1166093777737ee77706693777737e677009ddc22322cccdd007ddc22322cccdf0
55555555555118810157d7777d751f100330f7ee77fb30000130f77777fbb3336660977777e07777006d977ff7e07700090ddd222dccdd0009dddd222dccddd0
55f555555551181000159777779511003133000ff00333300333306666031113666d04ddd44677700066041d54407ee00900ddddddcc0000090dddddddccdd00
55ff55555555181000015189985110003131307777f31313031137777771111006664f565ff477e000064f565ff47eee09000ddddcc2000009000ddddcc20000
55fff55555551110000008888880000031000f66670f001300003f666f7661000006533333d60ee000006133333500ee09000ddddd52200009000ddddd520000
1111fff55551110000000f8888f000003100077777700013000000f7f7660000006d31319336770001013333f93670e009000d5ddd55222209000d5ddd552000
ff5e7711151ff1000000f8888888f000010f077777770f03000000777700000006619919f13377700f1f911f1133770009005dd55dd5522209005dd55dd55220
ff159fffe19ff9100000088888800000000fff00077fff000000000f0f000000061ff0ff100007700ff110ff100007000055dddddddd55200955dddddddd5522
0000070000000007081010800000000001ddd20701ddd22000000000007770008888888888888888000555000000000000000060070000702018c2a082080901
0700007007000007811111280010100016766d1716766d10007777000777b7002828282882828282000556500060000006606770765007772b48400104000804
077000700770000781e1e1280111110015111d1d16111d170777bb707b7bbb70282828288282828255505665067766006770677665000566b0c05f984250aa10
77777776777777778111112821e1e1806661d11d1166d117777bbbb77b1b1b71282828288282828255600665067766605770077000000550c9f23c8410000000
73777777737777778211102881111128ee61d66d661dd61d7b1b1b377b1b1b712828282882828282056665500066666655650000000000000000002280e00000
77777777777777778000000882111028ee616d5de6166d6d7b1b13376bbbb36128282828828282820556650006666776577657700500055604000f8800fabe4b
07760677007000678000000282000028ee61551de615551d7333333763bb3361282828288282828200055500006606606776577665505567bbf0ffc9ff7bebed
770006070070000700011000800110021615d61de61d61000777777005333511888888888888888800000000000000000665566076000670ddc75d42448e4e3b
00577760a05777600033000037bb3000000333307003333000888800008888000808980000000000777777710000000027722222022222209ef1e292789ee200
00717170a07171703b7bb300717bb30000999933709999330888888008888880088ef8800800080876667671110001102a2a2272277277200000000000022811
00677760a0677760b717bb30b7bbbb300091f1937091f1930eeeee880eeeee88098fa8908908089877777771171017102aa22a2a2a22a2200000004000447df2
a0056650a00665000b7bbbb303bb3bb0709fff99709fff99ceeeeee60eeeeee68feaaf989a8989ae76766671017171002a2a2a2a22a22a2074888845032be840
0a6665660a656665003bb3bb0b33bbb0070333f907f333097e3f3fee0e3f3ee0eaf7aaa89aff9fae77777771001710002aa222a22aa2aa2044c4436aaca64a5f
00a565000a05650603b33bbb000f3bb000f33300070333f070fff88f00fffe808fa77a9889aafaf8000910000001000022220222222222008d4ed09a93cd729c
000656000a0666503b00f3bb00003bb000033300000333300f888820cf7888f709faa98008f77ae0001f111100000000000002777720000095a00aa100000000
000606a00a650060b303bbb0000000bb000e0e0000ee00ee0728888200088888008ee80000899800011f11100000000000000027720000002000178480100007
0012221001222100000000000e777e20000e0000800000800000000000000000008ee8000008800000000000000000000000000000006666442272be88805152
01994441199444100e777e20e7777fe20009000008e9e800000000000000000008e99e80008ee8000000082222200000000008222206666011370490942b9aca
0191414119141410e7777fe2777777f2009a90000eaaae0000666000000000008efaafe80e9ff9e00000888222220000000088822226660052949f7c5789af02
0144444114444410777777f27fff7af2e9a7a9e009a7a9000666660600666000efaaaafe09faaf900008868822279000000886882226900018aa29b739ef1aa0
12411141141114217fff7af27e2eaaf2009a90000eaaae0066a66666066666069aa77aa98faaaaf800886678822792000088667882279200400e0003e6089ce7
44444442244444447e2eaaf2e77aafe20009000008e9e8000555550555a555559a7777a9eaaaaaae088667778822222008866777882222209c00dc42caa4448c
4214442442444124e77aafe22efffe20000e0000800000800055500005555505fa7777af9aa77aa9886677777882222288667777788222222113211008490bd3
40444414414444042efffe200022200000000000000000000000000000555000fa7777af9a7777a9866777777788888886677777778888886bade530ded5cf52
b00b00300000000001288280088222000aaa0000000070070000000000000060000000000000000006777777777555500677777777755550435c216e8394544a
bbbb3030b00b0000189999881ee888e1aaaaaa770aaa707700566000005660567777777077777770077777111776666007777744477666602b010a14a0000002
7bb71333bbbb000089aaaa98eeaa99a8a5f5a770aaaaaa77566e6550566e60567777477077774770077771111176c6c0077774444476a6a0b84430000ea1d36a
0bb133037bb700339aaaaaa99aaaaa9e0fffe700a5f5a77065665665656656657779946177799461077771111176c6c0077774aaa476a6a070293d8e618d3398
011330030bb11330a87877aaa87877a9feeef0770fffe70066656666666566667777777177777771077771111176666007777444447666606fb4e6bcd9950d9a
03f3330001133103a878777aa878777a000eee00feeef07055556566555565666111116161111161077771111176666007777444467666609324c4674c67adca
00ff333303ff3333a777777aa77777aa000eeff0000eee0000565666005656566100006161eeee61077771111176666107777444447666617dd8873808414e02
0b3993b00b3993b0077777a00aaaaaa00000d0000000eff000565665006506566100006161eeee610001111111111111000111111111111100046098e5000511
__gff__
0000010000810100200100060101000100000001062021040101010101010101000100010000010010000101060600010000090044444444010180011010010000000000000001802000090006040100000000000009090909090909090909440000202000000000000101090600010000002020000000000009010180800601
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000100000100000000010100000000010100000000000000000101000000000101000000000000
__map__
0503202727272727272727272727200513696a13131313131313134913132f2f2f2f2f2f2f2f2626262612202f2f2f2f2f2f2f2f2f2f2f2f2f202f2f2f2f2f2f3e3e3e3e7f7f7f7f4c2d2d2d2d6f6f3e4848f04870714848484848484848707105050505151515f01515151515f415050505050505053b3b3b3b050505050505
05f82726262626262626262626262727497c7d2e2e492e2e2e2e2e130b2e11111110102f2cf826242526122c2f2020202020202f2f2f2f2f2f202f6b6b6b6b2f3e3131d86f6f6f7e2de92d2d2d6f6f3e48484848707148484848707148487071050515f41515151515161616161615090d05054c61f83b02023b612d0505050d
05262623232323232323232323232626137c7d2e2e2e2e2e2ec7c1132e2e11111110102f2c20233c3d23122c2f201010202020202f2f2f2ff8202f6b2f6b6b2f3ef831316f6f6f4c2d2d2d2d2d6c6c3e48484848636248484848707148487071051515161616161515151515161515091c054c2df4613b3c3d3bf4e92d05051c
2626232020333333332c3320202f23234913130b0b2e2e2ec30b2e2e2e2e36355f10102f2c2020202020202c2f20102f2f20202020f6202020202f6b6b2f6b2f3e3e3ed86f6f6f4c6f4c2d2d2d2d6f3e484848727273624848487262484870710915151515f415161616161615151509054c2d2d2de261c9c961e22d2d2d0505
262320c233203b3b3b3b203320202005132e2e2e1313131313131313133637e62f10102f2f2f2f2f2f2f2f2f2f10102f2f2f203b3b3b3b3b2027272f6b2f5d2f7f7f3e6c6c6c6f4c3e6f4c6f4c6f6f3e484863637248737348637248734819190916161615151615151515f415151509054c2d2d2d2d2d2d2d2d2d2d2d050505
053a0333202c3b02023b2c33064e2b051313132ec12e2e2e130b2e2e0b1334372f101010c4c4c4c4c42020201010d22f2f2f3b3b115e113b3b22202f6b2f2f2f7f5cc82d2d2d6cdcddd84c6c2d6c6c3e486372634848dcdd734848484819f8311515151515160315150505031515da09054d0f0f0f7f7f7f7f7f050505050505
053a0533202c3b3c3d3b2c332020c205135c2ef72ec30b2e2e2e2e2e2e493437351010102f2f2f2f2f2222101010102f2f2f3b111111f6113b22202f6b6b2f2f7f7f4c2d2d2d6f6f6f6f6f4c2de92d3e724872484848484873a548484831c8311515696a090505030509090909090909054d17ca177f3f5e3f7f4d17e7054d05
055d05332005033333f82033202705054913132e2e0b2e2e2e2e2e0b2e133437371010102f22202220226b106b10102f2f2f3b11111111113b2220202f6b6b2f7f4c2d6f6f4c6f6f8c6f6f6f4c6f6f3e48484848484848a4484848484819191909157c7d09150515151515c3151579090531d74d177fd7da3f7f4d3fd7c53f05
05030533200505033333332227363535132e0b2e132e2e2e130b2ec30b1301373710da102f10101010101010101036372f2f3b11f73b3b3b3b222020202f6b2f7f3e6fd06f4c6f6f6f6f6f6f4c6f6f3e484848484848484848484848484848480909097d050315f41515151615151509050f0f0f4d7f3f3fd77f4d3f4d0f3f05
09200533062b3a05032020203637e63713492e0b131313134913132ed1131234371010102f222222f8221010103637e62f2f3b3b11113b352f2220d2202f6b2f7f3e6f6fd84c6f696a6f6f7e6f7e6c3e484848f048487071484848484848484879795c090509091516161515f0097909054d17e7177f7fd77f7f4d3f4d0f4d05
0935353320203a6b6b222a6e3437373713182e2e130b2e2e2e2e2e0b2e1312343710f6106b22222222221036353737372fda11f7f7f76b372f22d26bd2206b2f7f3e3e3e3e3e7e7c7d6f7e6f6f4c2d3e4848484848487071484848484848484809090909155d0909151515f005791509054d1717e70f2c3f2c4d173f4d0fca05
053707333635050505032020343737371318181813d12e2e0b2e2e2e49131234375f10102f1010101010101010101010102011113b1111012f2220d220222f2f7f4a7f7f4a4a7f7f7f7f7f7e6fd06f3e48484848484870714848484848484848090915151515150909d7161615150c09054d17e7170f2c3f3fd73f3f4d0f4d05
052020333737072f05052020013737372f1313131311131313131313daf8120137373535350c0c0c0c10101010c41010102020f711f76b202f2f2222202f2f2f7fda6f6f7f6f6fd0d0d87f7f6f6fc86f0408484848486373484848484848484809040404040404040979151515151c09054d0f0f0f0f0f0f0f0f4d17e70f4d05
2f20da20332020202f050322202020052f1112c11211121212121212121212120137370c371c1c1c1c365f365f1111365f20203b203b6b6b6b2f2f2f2f2f6b2f7f7f6fc54a6f6f6f6f6f6f7f7f6fc86f0404f80848726348624848487071484809040505f0040504090915160c0c0d0905e717c21717173131310f0f0f4d1705
052f0305033333332f050505222005052f11111111c1111111111111111112363537371d0c0d0d0d0d0c0c370c11110c2f2020201010f7106b27365f276b6b6b4a4af77f7f7e6c6f6f6f7f7e7f6fc86f04040404da08484848734848726248480904040409f00904040915151d1cf809054d17173131313131314d1717171705
050505050505050533330505050505051a1a1a1a1a1a1a1a1a1a1a1a1a0e121a370c0c1d1c1c1c1c1c1c1d0c1d11111d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f7f7f6f7f6f6f6f6f7e6c2d2d7f7f7f7f7f7f7f04040408484848484848487348090904040909090904091212121212090f05050505053c3d050505050505050f
050505050505050505050505050505051a1a1a1a1a1a1a1a1a1a1a1a1a30311a0f066e061f1f1f0f062b1f1f1d0e111d191919191919191919191919191919193e3e3e3e6f6f6f6f4c2d2d3e3e3e3e3e7f7f7f040404212121212121212121212121040421212121041912121212124639383938393839383938393839383938
050905050505050505050505050505051a1af831f6313131c0dcdd311ac8c81a1e11c4110fd6111e4911d8141e11110f19cc18f8314d17cc17183031313131316f6fdaf86f6c6c6c2d2d3e3e4c2d2d2d2d6f6f7f04040404040428f83604c60404040404042104040419da121212c64639292929d729292929292929d7383938
050960600505050505606060090560051a30313131313131313131311a30311a0f0e11c41f0e111f0e1111111f0e491e194d183031184d17c2183031313131316f6f6f6f6c3e3e3e3e3e3e4c2de96f6f6f6f6fe27f040404040404043404042121040404c6213232194747471247474639292929297a7adcdd29292929292938
160916601505051509156015091660151a30313131313131313184313131311a1e110f114911062b110f49060f11111f194d18303131184d4b181717171830193e7e6f7e3e3e4c2d2d2d2d2d6f6f7e6c6c6f6fe27f7f04040404f0043404210404044bf721214f4f194646463346463039292929c67a2929297a7a2929292938
150915601509151609166015091560161a30313131313131313131313131311a1f0e1f0e11111111111e11111eda112a194d18303131184d17c2184d17cc18193e4c6f4c2d2d2d6fe96fd06f7e6c7f4c2d6ce26f5c7fda040404042121212121212121324f214fc41946464630464647390be0297a292929ac29297a7a292938
150915601509151509156015091560151a30313131313131c03131313131311a0f110f11d4d81111111f0e111f0e110f194d183031184d17171717184d17e6193e4c6f6f6ff26f6c6c6c6c6c2d2d7f4c2d2d6fe27f7f35353535215b4f28c52121c64f5e4f2132191946464630464646390be0297a29297a7a2929292929d738
2f092f2f2f2f2f2f092f2f2f2f2f2f2f1a3031313131064e4e4e4e4e4e2b301a1f141f0e1111d4492a6e0e11c411111e194d1717184d1717174b4d17184d17193e4c6f6f6f7e6c2d2d7f7f7f7f7f7f4c2d6f6fe27f2104c6040404214f324f21214f21324f214f19304b4b4bc54b4b46390be0297a297a02027a292929292938
202020202020202020202020202020201a064e2b30313131313131313131c01a0f1149062b0e11062b0e1111c411d41f194d171717174b4d17171717184d17193e4c6f6f6f4c2d4a7f7f4c2d2d2d6f6f6f6f6f7f7f212104040432212121322121c52121214ff019474b4b4b4b474746390be0297a297a3c3d7a292929292938
191919191919191919191919191919191a303131064e4e2b3031f6313131311a1f11112a0f49110f0f0f6e2a6e49110f194d17e6171717171818184d17184d193e3e3e6f7f7f7f4a4c2d2dd06f6f6f6c6c7f7f7f212121042121210432323232214f4f214f32194646dcdd4bf0464630390be02938397a29297a2929297a2938
191111151115111111111111242511191a303131313131c03131312a4e4e6e1a0fd611111f0e061f1f1fdcdd060fd81e194d1717174b4d18145c14184d18e6193e3e3e7f4c2d2d2d6fd06f6c6c6c6c2d7f7f213232322132212121042121213232214fc54f19194646304b4b4b464647390be029293839da29c8c8c838392938
190511111111111111111111000005191a30313131313131313131313131311a1e111111492a6e3f3f3f3f3f3f1f0f1e194d4b4d17184d1831e031184d184d193e6f7e6c6f6fe96f6c6c6c2d7f7f7f7f7f04e032213232322121d60404040421325c214f191947474b4ba84747474746390be029293839f82929292938392938
19050a0a0a0a0a0a0a0a0a0a0a0a05191a3031064e4e4e6e064e4e4e2b30311a1f141414110ff83f3f3f3f883f062b1f194d1717184d1718143114184d184d193e6f6f6f6f7e6c6c7f7f7f7f7f4c2d3e3e32212121212121212121212121d7042121211947474646d84b4b4646020246390b7a292929293839383938395d2938
190a0a0a0a696a0a0a696a0a0a0a0a191a30313131313131313131313131311a0f141111111f3f3f3f3f3f3f3f696a0f194d1717171717171831184d171717193e3e3e7e6c6f6f7f7f6f6f6f6fe94c3e3e323607042136370704e00421c60404040421696a46464630c64b46463c3d463929297a292929292929292929292938
190a0a4b4b7c7d484b7c7d484b0a0a191a30da3131313131313131313131311a1e11d614143f3f3f3f3f3f3f3f7c7d1e19304b4b4b4bda4d1831184d4b4d17193e5d3e7f7f6f6f4cf26f6f7e6c6f4c3e3e360704e03637072104365fe03635355f04217c7d304b4b4b4b4bc8f80a0a1939c529297ac5c5c5c5c5c5c538393839
190a0a4b4b7c7d484b7c7d484b0a0a191a1a301a30311a303131313131c01a1a1ed811113fc43f3f3f0fc8c80f7c7d1f19304b4b4b4b4b4d1831184d17174b4b4b4b4a4ad86f6f6f6f7e6c2d2d6f4c3e3e0704042107040404043407042137370704217c7d304b4bf04b4bc84b4b4b1939293529292d2d2d2d2d2d2d2d292938
191919191919191919191919191919191a1a1a1a3c3d1a1a1a1a1a1a1a1a1a1a1f0f0f0f0f0f0f0f0f1e3f3f1e0f0f0f193c3d191919191919301919191919193e3e3e7f7f7f7f7f6c2d2d2d2d6f4c3e3e21212121212121212121212121212121212119191919191919191919191919393839383938393839383938393c3d38
__sfx__
00200020083550832514355143250f3550f3251935519325183551d3551f355203551f3551d3551b3321b3421d3551b355193551b3501b3521835514355113550f3220f3420f352113621135511355103550f345
00200020083550832514355143250f3550f3251935519325183551d3551f355203551f35524355293552b355293452734525345243352431520345223202233220332203322033520355343342f3542b33427354
001000202c35527345273452c3552a34525345253552a34528345283552a3452834527355273452b3452b3452c35527345273452c3552e3552a3452c3452e3552f3452e3452f3553135533355313552f3552e355
000100002435024350241502415024150243502415024350243502435024350243502435024450244502445024450244502445024350244502435024350242502425024250242502425024350243502435024350
001000001e0652106524065270552a0552d055300553305534055300552e0552b0552805525055220651f0651e0652106524065270652a0552d05530055330552a0552d055300553305535055380553a0553d055
004000201857217572002321457200232135720023211572135721377213772137721377213772137721377232532315320d5720d5720d5720d5720d5720d5721057210572155721557215572155721557215572
001000200844508445203451444506445064451e3451244504445044451c3451044503445034451b3450f44508445084452034514445064450644525345064452a545295452a5452c5452e5350d245276450b245
00020000000002f06028060280602b0602706026060280602c0602a06000000000000000014170000000000016170051701117018170000000000000000000000000000000000000000000000000000000000000
010100001d050200502205028050160502e0501f0503405039050170503b0503c0503a050350502f0502805026050260501e05028050000002d05018050330503b0502f0501b0500b050130501e0502405028050
00070000386252d00530005330053264533605340052f0052c6452c6052e0053100534005370052c0052e0053100534005350052a0052b0052e0052b005300053200534005370053a005360053c0053b0053f005
000300002553030530005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000285302b530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100020273552705522365220651b4651e365223552275525355250552036520065194651d365203552075523355230651e3651e065174651b3551e3551e75522355220651d36516465193651d3552035520755
001000001e6531e25325066122551c2531c2532f042102551a6531a2532d0420e2551e2532a0562a052280521a6431e2432d0522d5502f2532f05031052315502f052232533105631540340521f640350521c243
000300003b1303913038140361403314031140301402c14027140221401e1401a14016140131401114009140091400a1400b1400c14011140151401a1401f14022140271402c1403314034140001000010000100
00010000210502102017620196201b6201e62021620240502402026620296202d6302f6303063032620326302e0502e020386503a6503b65035600386003b6003005030040396003c6003d6003c6003d6003f600
00030000003000f34013340183401a3401d34021340243402134014340193401e3402234024330283302a3302b3301d3301f3302233027330293302b3302e3303033033330343303733018300003000030000300
000200001533016330183301a3301c3301d33020330233301c3301d3301e3302033023330283302b3302e33031330363303a3303c3303a3300000000000000000000000000000000000000000000000000000000
0010000026630266201e0300000016640000001e050280001e0501e0551e0000000000000000001e0000b6002155021550215502155021550205501f5501f5501e5501e5501e5501e5501e5001e5001e5001e500
000800203fb003fb00256003a6003fb153fb1513600016003fb003fb0012600136003fb253fb1524600326003fb003fb000b600076003fb153fb1507600390003fb003fb0034000380003fb153fb150000000000
0002000012440164401a4401e44021440264402a4402f440324403b5401e440134401c4401644010440164000040014400144001440016400004001f4001f4001c40017400134000040011400144000040000400
00100020326253260532615326153a6103eb2532615326153262532b0532615326153a6103eb253261532615326253260532615326153a6103eb253261532615326253e61232625326153a612266253e6153a625
000100003104032040160401b04027040270402f04030040310403204033050390003d00000000000003700000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000030640296401f6301963016630116200c62007610036100b6000c6000b600006001a600076002060002600016000160001600016000160038000390002b0003000034000380003a000000000000000000
000b00002835527355283552a3552a3552a3552f3552f35531355313553135531345313453133531335273552c35533355293552f355343552a35531355363553634536345363453634536345363453633500305
000300003e3653c3653c3653c3653936538365323653136532365313652e3653b3653b365273652636518365213651f3651d3651c3652f3652e3652e3651336511365283650d3650a36507365163650136501365
0010002003465044650f465034650f465034650646503465034551f5401b53018540195301e540255302654002465024650e465024650e4650246508465024650245521540275302554028530255402253027540
000700002964029610296002260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000c050210501a05021050170501d050270501a00020000240002c0002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f35038350323502e350263501f3501835012350353402f340273402034019340123400d340073402833025330213301d3301c3301a330183301633013330113300e3300b33008330053300233001330
00060000122500d2001225012250122500d2000d20000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
001000001833518335173351733516335173351c3351c3351c3351c3351c3351f3351e3351e3351a3351e3352133521335213351f3351f3351f3351e3351e3351e3351d3351d3351d33522335233352433525335
00100020116300000038705116002d610126003870500000116300000038705000002d610326000000000000126300000000000000002d610000000000000000116300000000000000002d610000000000000000
00080020136300000013620136002a630000001460014600146301460014620006002a630136000000000000146301560014620000002a630000000000000000156301660015620000002a630000001463000000
001000200e2520e2521a2421a2420e25219242192420e25218242182420e252172421724216242152421424210242102421424210242102420e24211242112421824211242112420f24214242162421a2421e242
001000200c6600c6501e0501e05023640116401e0201e060016501e0600c6501e0600c6503f61023640016200c6700c6601c0500c650206401c0500c6700c6601a0600c650206401b060246401c060246401e060
001000003d0303d7303603036730390303973032030327302f0322f73200000350002a0502a7502b7502b7502d0522d7522d7522d752000002c0522b052000002a0522a7522a7522a75222030290303003035030
01100020086652845426444214442444223454214441f4441f465234541f44424444264421f45424444234442446524354284421d344300621d354244421d344076651f3542b4422434426062304422435232442
00200010083450834508345083450f3450f3450f3450f3450634506345063450634502355013550d3450d3450f3550f3550f3550f3550f3550f3550f3550f3550d3550d3550d3550d3550d3550d3550d3550d355
0010002020332253422834220332253422a34220332253422b34228332273322e3322c3322c3322c3322a3322833224332203321c3322a332273422434227342243322a3323433237332313322d3323833231332
00100000270552775529055297552b0552b75522055227552e0552e7552c0552b0552c0552c75529055297552b045277552e045277552c0452775529045277452b0452b7552b7452b75529042297522975229752
0010002017375177751b0751707517375177751b075177751c3651c765200651c0651c3651c765220651c0651e3651e765230651e0651e3651e7652a0651e0652036520765280652006522355280552c0552f055
001000003313233122331222b1322c1312c1322c1322c132341323413238132381323613236132311323113233255332553325531562315623156231562315622f5652f5652f5652d5622d5622d5622f5622f522
00100000311323112231122291312a1322a1322713227132361323613234132341323113231132321323213233135334653356533465335653346533565334652f5622f5622f5022d5622d5622d5022756227562
00100000311323113231132291322a1312a1322c1322c132331323313231132311322f1322f13231132311322c1322c1422c1422c5522c5522c55220552385513855138552385523855238552385523855238552
002000000727506275052750427502275032750227503275022750327502275032750227503275022750327501275022750127502275012750227501275022750127502275012750227501275022750127502275
0010000026b6226b6225b6225b6224b6224b6223b6224b6224b6223b6221b621fb621db621bb6219b6217b620ab620ab620ab620ab620db620db620db620db6210b6610b6613b6616b6619b6219b6219b6219b62
00100000270552775529055297552b0552b75522055227552e0552e7552c0552b0552c0552c755290552905527145277552c1452c7552a1452915527145277452a1452a755251452575020142201522015200000
00100000270552775529055297552b0552b75522055227552e0552e7552c0552b0552c0552c75530055307552e7502e7502c7502b750297522975229752297522b7502b750297502775029752297522975229700
001000200145001400084400144001400084400144001400084400144003400084400b4400b440034000144004440044400444004440084400844008440084400a4400b4400b4400b4400c4400d4400d4400d440
001000202e7652e7652776527765297652976531765317652e7652c7652a7652a7652a7651e7651d7651e7652c75520765207652a7551e7651e7652c755207652a7552c7552e7552e7552a7552a7552775527755
001000002d040000002d020000002d010000002a040000002a020000002a0100000028040000002802000000280102d0002704030000270203000027010000002604000000260200000025030000002501000000
00100020031742773525345273352334527335223452733506746277351e345223352034524335223452533501174297351a3452933519345293351734529335057462c33516345263351d3452c3352e34526335
0010000803455084550f45509455084550a4550d455104550d4550040515455004050945500405114550040500405004050040500405004053240531405304052f4052e4052e4052f40530405004050040500405
001000000346203402054520145203452044520645203452034620340205452014520345204452064520945203462014020545201452034520445206452034420845203442064520344205452034520045202452
0010002025b5221b6206b7326b5221b6206b7328b5221b6206b732ab622ab322ab3219b521cb521fb521cb5225b6221b6206b7326b5221b6206b7328b5221b6212b632a342210421e77231572315723156231552
001000201263000000000000000028620000000000000000136300000013630000002862000000000002760013630000000000000000286200000000000000001263029600126301260028620000000000000000
001000201263015600000000000028620000000000000000126300160012630000002862000000000000000012630000000000000000286202260000000000001265012630000001964012630000001265012630
001000003c0453c7253c7353c715350453573535735357253c0453c7253c7253c715350453573535735357253c0353c7253c7253c715350453573535735357253c0353c7253c7253c71535045357353573535725
001000080247504475054750247501475024750147503475004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405
00200020223421b342223421b342253421d342253401d345273421e345273421e345253421d345263421c3421e3421b340203401e3421e3421e3401e3401b3421b34229752267522c75232752267522b75230752
001000200936509455074550945509255094502476009450073650745505455074550725507450237600745005365054550345505455052550545021760054500736507455054550745507255074501f75007450
00100020166600b60030620106500b60030620166500b600306201d6500060030620186500760018650076001e65006600306201e6300b600306301e62000600306301e62000600306202d630156102d6300e620
0010002001450014500145002450024500245004450044500445006450064500645006450004000d4500640001450014500145002450024500245004450044500445006450064500645009450094500945009450
__music__
03 3a 26 20 44
03 2d 20 21 44
03 1f 20 43 44
03 22 23 43 44
01 24 12 43 44
03 33 39 43 44
01 2f 38 43 44
02 30 38 43 44
03 41 42 43 44
03 34 38 15 44
03 04 38 21 13
03 36 13 20 44
03 35 39 43 44
03 1a 20 39 44
03 02 06 15 38
01 28 38 43 44
02 30 38 43 44
03 41 42 43 44
03 41 42 43 44
03 25 3d 39 15
03 26 15 43 44
03 0d 3b 38 15
03 27 31 39 13
02 41 42 43 44
01 3c 3f 21 0b
00 3c 3f 21 0b
00 3c 3f 21 0b
00 3c 3f 21 0b
02 3c 3f 21 20
03 32 39 15 13
03 29 15 43 44
03 0c 39 15 44
03 3b 42 43 44
01 41 2e 43 44
00 2a 36 3e 44
00 2b 36 3e 44
00 2a 36 3e 44
00 2c 36 3e 44
00 2a 36 3e 33
00 2b 36 3e 33
00 2a 36 3e 33
00 2c 36 3e 33
00 37 36 38 44
00 37 36 38 44
00 37 36 3e 44
02 37 36 3e 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 05 39 43 44
01 00 20 43 44
02 01 20 43 44
00 41 42 43 44
00 41 42 43 44
03 08 42 43 44
03 29 1d 08 0f
03 3b 1a 1d 3f
01 0d 00 43 15
02 0d 01 43 15
04 12 42 43 44
03 41 42 43 44
03 0f 42 43 07
03 07 03 12 13
03 02 13 43 04
