pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lode runner 0.81
-- 2021 paul hammond
_a="0.81"
cartdata("phammond_loderunner_1p8")
_b=6
_c=28
_d=_c*_b
_e=16
_f=_e*_b
_g=0
_h=1
_i=2
_j=3
_k=4
_l={[0]=0,0,1,0,-1}
_m={[0]=0,-1,0,1,0}
_n=0
_o=1
_p=2
_q=3
_r=-1
_s=-3
_t=0
_u=9
_v=0
_w=1
_x=99
_y=0
_z=1
_0=2
_1=3
_2=4
_3=5
_4=0
_5=1
_6=2
_7=3
_8=4
_9=5
_aa=6
_ab=7
_ac=8
_ad=9
_ae=10
_af={0.75,64,65,66,67,68,69,70,71}
_ag={0.5,76,77,78}
_ah={0.05,114,115,114,114,112,114,114,115,115,114,114,112,114,114}
_ai={1.0,72,73,74,75}
_aj={0.75,82,83,84,85,86,87,88,89}
_ak={0.8,96,97,98,99,100,101,102,103,104,105}
_al={0.2,90,91}
_am={0.3,106,107,108,109,110,111}
_an=0
_ao=2
_ap=4
_aq=5
_ar=7
_as=8
_at=9
_au=10
_av=11
_aw=32
_ax=0
_ay=16
_az=24
_a0=56
_a1=max(1,dget(1))
_a2=dget(0)
_a3=0
function _init()
poke(24365,1)
pal({129,133,138,139,1,6,10,13,130,8,7,9,128,136,12},1)
poke(0x5f2e,1)
_ft()
_a4=_f3
_a4:_f4()
_a5()
end
function _a5()
_a6=false
_a7=0
_a8=_n
_a9=0
sfx(-1)
music(-1)
if _a1==1 and _a3>_a2 then
_a2=_a3
dset(0,_a2)
end
_fk:_fm()
_fp._ba=false
_g0:_fm()
end
function _bb()
_a8=_q
_bo()
end
function _update60()
_a4:_fo()
_a7=(_a7+1)%60
_a6=_a7<30
if _a8==_n then
_be()
elseif _a8==_o then
_bi()
elseif _a8==_p then
_bm()
else
_bc()
end
_fk:_fo()
_fp:_fo()
if(kb("q")) _bd=true
end
function _bc()
_ch()
if _bd then
_a3=_br._do
_a5()
end
end
function _be()
_g0:_fo()
if(btnp(5)) _bh()
_a9+=1
if(_a9==2160) _bg()
if(btnp(4)) _bg()
end
function _draw()
cls(1)
_a4:_fn()
if _a8==_n then
_bf()
elseif _a8==_o then
_bk()
elseif _a8==_p then
_bn()
else
_co()
end
_fp:_fn()
_fk:_fn()
end
function _bf()
_g0:_fn()
end
function _bg()
_a8=_p
_bo()
_fk:_fm()
end
function _bh()
_a8=_o
_bj=nil
_fk:_fm()
music(_ay)
end
function _bi()
if(_bj!=nil) _ch()
if btnp(0) then
_a1-=1
sfx(_av)
end
if btnp(1) then
_a1+=1
sfx(_av)
end
if(_a1>#_fu) _a1=1
if(_a1<1) _a1=#_fu
dset(1,_a1)
if(btnp(4)) _a5()
if _bj!=_a1 then
_bj=_a1
_bo()
end
end
function _bk()
if(_bj!=nil) _co()
_bl(12)
if(_a1==1) _ez("hi~" .._e2(_a2,5).."0",28,0,6)
_e0("level . " .._e2(_a1,3).." /",12,56,12,1)
end
function _bl(y)
for i=0,2 do
pal(11,({14,10,11})[i+1])
spr(116,20-i,y-i,11,1)
pal(11,11)
end
end
function _bm()
_ch()
if(btnp(4) or btnp(5)) _a5()
end
function _bn()
_co()
_bl(12)
if(_a6) _e0("demo",47,56,12,1)
end
function _bo()
_bd=false
_bp=_a1-1
_bq={}
_br=_dl(0)
_bs=nil
if _a8==_p then
_bp=flr(rnd(3))
if(_bp==2) _bp=31
end
_bt(true)
end
function _bt(_bu)
if(_bu) _bp+=1
_bv=_bp\#_fu
_bw=0
_bx=0
_by=0
_bz=0
_b0=0
_b1={}
_b2={}
_b3={}
local _b4=1+(_bp-1)%#_fu
local _b5=_fu[_b4]
_b6={}
_b7={}
for y=_e+1,-2,-1 do
_b7[y]={}
for x=-1,_c do
local t={_b9=-1,_cu=x,_cv=y,x=x*_b,y=y*_b,w=_b,h=_b,type=_y,_ed=0,_de=nil}
_b7[y][x]=t
if x==-1 or x==_c then
t.type=_2
elseif x>=0 and y>=0 and x<_c and y<_e then
local _b8=1+x+y*_c
local c=sub(_b5,_b8,_b8)
if c=="#" then
t.type=_z
t._b9=2
elseif c=="@" then
t.type=_2
t._b9=5
elseif c=="h" then
t.type=_0
t._b9=3
elseif c=="s" then
t.type=_y
t._ca=true
t._b9=4
elseif c=="-" then
t.type=_1
t._b9=6
elseif c=="$" then
t.type=_3
t._b9=16
_bx+=1
elseif c=="&" then
_b6._cb=x
_b6._cc=y
elseif c=="0" then
_ct(x,y)
end
elseif y<0 then
t.type=_y
else
t.type=_2
t._b9=5
end
end
end
_dm(_br,_b6._cb,_b6._cc)
_cd=0
_ce=true
_cf=0.5
_cg(_r)
if _a8==_q then
_fk:_fm()
_fp:_fm("level " .._bp,64,14)
if(_bu) music(_aw)
end
end
function _cg(s,c)
_ci=s
_cj=c or 0
end
function _ch()
if #_bq>0 then
if _bs then
if _bs._ba then
_bs:_fo()
else
del(_bq,_bs)
_bs=nil
if(#_bq==0) _bt(true)
end
else
_bs=_bq[1]
_bs:_fm()
end
return
end
_ek()
_eq()
_e3(_br._dn)
if _ci==_r then
if _a8==_p then
_cg(_t)
if _bp==1 then
_ck="PAUL" _fi(_br._dn,"-04r83u18l25-14o01-4fl17-1bu3er2f-01u1flb2-03u14l27-1ao01-18l09-22d30r26-1fx01-18r07-5ar47-0ed12-0ar77u15l3f-03u3d-02r2du23l45u21")
elseif _bp==2 then
_ck="PAUL" _fi(_br._dn,"-0er57-01u34r1bu0er27d21r1a-05l11-01u25r13u1el35u20r20l1d-01u0fl4e-08o01-10r05-06o01-0dr07-05o01-acl7e-03u33l39d3er23-1eo01-0fr05-09o01-11l08-15o01-0cl09-09d07-19x01-11r08-15r41-04u2a-04r80u25r3cu1al5c-4br12-14r06-03u2alb7-01u39")
elseif _bp==32 then
_ck="FINN" _fi(_br._dn,"-15l10-02u2dr21-02u07-0fr2a-25x01-44r1c-18o01-10r05-05o01-19d0d-0er2fd25l13-01u0e-04l0f-07d0f-0dl06-07u0b-26d04-07l20-01d13-08r0f-02l0c-03u09-04r19-0fd0e-06r07-04u13-0fr3bu16l5cr27u1ar10-05o01-11r07-04o01-23r05-06o01-2dr04-05o01-0dr2e-0fr03-0cr02-21r04-07o01-13l07-1bd16-08r03-08x01-25r0b-1dl19d21l0f-0ar05-09o01-11d0a-01l38u18l10u21l28d04-19r9a-6ao01-44l11-16u01-07u1d-02r14-02u1cr27-15l06-ff-1ao01-4dl0d-0bd22-01l0c-1bo01-28x01-12d1a-0do01-13d09-02l38u1b-03o01-0cd0b-05o01-0ad10l21r7f-59l10-02u30r12u20-02r12-01u27r0c-01u18l4bd5b-13r2d-09u1dr16u1f-09l05u29r14u29r0bu19l60d10-06l07-11l08-27o01-15r04-13o01-0er05-47l6bd32-03l67-2dx01-1dd07-03r2bl33-02u4cl07-01u2br21u1f")
end
elseif _br._dn._fa and _cj>2 then
_cg(_t)
if _a8==_o then
music(_aw)
_a8=_q
end
_ej("play",_br.x,_br.y-10)
end
elseif _ci==_t then
if _cj==1 then
_ce=false
_fp._ba=false
end
for c in all(_b1) do _c9(c) end
_dz(_br)
_bz+=1/60
if _bw==_bx and _br._a8==_v and _br.y<=0 and _br._dn._cl==_h then
_cg(_s)
end
elseif _ci==_s then
_ei(_br,75)
_br._dp+=1
add(_bq,_gv)
if(_a8==_p) _a5()
elseif _ci==_u then
if _cj==1 then
music(_az)
_fp:_fm("game over",0,48)
elseif _cj==420 then
_bd=true
end
for c in all(_b1) do _c9(c) end
end
for y=0,_e do
for x=0,_c-1 do
local t=_b7[y][x]
if(t._ed>0) t._ed-=1
end
end
if _ce then
_cd+=_cf
if(_cd==-1 or _cd==(_c*_b)-127) _cf*=-1
else
local _cm=_br.x+_br.w/2-64
if _br._cl==_k then
_cn=_cm-32
elseif _br._cl==_i then
_cn=_cm+32
end
if(_cn==nil) _cn=_br.x+_br.w/2-64
_cd=_ev(_cd,_cn,0.5)
_cd=mid(-1,_cd,(_c*_b)-127)
end
if(_br._dq<_br._do) _br._dq+=1
_cj+=1
end
function _co()
if #_bq>0 then
if(_bs and _bs._ba) _bs:_fn()
return
end
camera(_cd,-28)
_cp()
if(_a8==_q) _cr()
camera()
clip()
if(_a8==_p and _cj<240) print(_ck,0,123,9)
if _by>45 and _ci==_t and _br._a8==_v then
rectfill(0,53,128,63,14)
rectfill(0,54,128,62,10)
rectfill(0,54,(128/130)*_by-45,62,14)
_ew("hold — to lose life",56,11,true,1)
end
end
function _cp()
local _cq=1-cos(time()*0.8)*1.5
for y=0,_e do
for x=0,_c-1 do
local t=_b7[y][x]
if t._ed>0 then
local sp=-1
if t._ed<7 then
sp=7
elseif t._ed<14 then
sp=8
elseif t._ed<21 then
sp=9
end
if(sp!=-1) spr(sp,t.x,t.y)
elseif t.type==_3 then
spr(16+(time()*10)%4,t.x,t.y-_cq)
elseif t.type!=_y then
spr(t._b9,t.x,t.y)
end
end
end
for e in all(_b1) do _c8(e) end
_dx(_br)
_er()
_el()
end
function _cr()
camera(0,0)
_ez(_e2(_br._dq,5).."0",40,1)
spr(59,2,1)
_ez(_br._dp.."",9,1)
local lv="" .._bp
spr(60,120-#lv*8,1)
_ez(lv,127-#lv*8,1)
end
function _cs()
if _bw==_bx then
for y=0,_e do
for x=0,_c-1 do
local t=_b7[y][x]
if(t._ca) t.type=_0
end
end
sfx(_ar)
end
end
function _ct(_cu,_cv)
local s={
_cw=_7,x=_cu*_b,y=_cv*_b,w=_b,h=_b,_cu=_cu,_cv=_cv,_cx=_cu,_cy=_cv,_cz=0.25+0.05*(min(4,_bv)),_c0=0,_c1=112,_c2=_af,_c3=0,_c4=false,_c5=0,_c6=0,_c7=0
}
_dj(s)
add(_b1,s)
return s
end
function _c8(s)
if s._cw==_6 then
circfill(s.x+3,s.y+3,s._c0/15,15)
else
if(s._c6>0) pal(4,7)
spr(s._c1,s.x-1,s.y-2+s._c5,1,1,s._c4,false)
pal(4,4)
end
end
function _c9(s)
local _da=s.y
local t=_b7[s._cv][s._cu]
local tb=_b7[s._cv+1][s._cu]
local tt=_b7[s._cy][s._cx]
local _db=t.type==_1 and tt.type==_1
local _dc=t.type==_0 and tt.type==_0 and not (tb.type==_z or tb.type==_2)
_f6(s)
_di(s)
s._c5=0
if s._cw==_5 then
if s._cv==s._cy then
s._c2=_al
else
s._c2=_ai
end
s._c5=2
elseif s._cw==_aa or (_db and s.y!=_da) then
s._c2=_ai
elseif _db then
s._c2=_aj
s._c5=2
elseif s._cw==_7 or s._cw==_4 then
s._c2=_ah
elseif s._cw==_ac or s._cw==_ad then
if _dc then
s._c2=_ag
else
s._c2=_af
end
elseif s._cw==_8 or s._cw==_9 then
s._c2=_ag
end
s._c4=(s._cw==_ac)
_et(s)
end
function _dd(s)
s._df._de=nil
s._df=nil
s._c0=0
if s.gold then
end
_b0+=1
local _dg=0
if(_bp==66) _dg=2
srand(_dg+_bp+_b0)
local x,y
while true do
x=1+flr(rnd(1)*(_c-1))
y=0
while y<_e-1 and _b7[y][x].type!=_y do
y+=1
end
if(y<_e-1) break
end
del(_b1,s)
s=_ct(x,y)
s._cw=_6
end
function _dh(s,st,c)
s._a8=st
s._c0=c or 0
end
function _di(s)
if(s._dk) s._dk._de=nil
local t=_b7[s._cy][s._cx]
t._de=s
s._dk=t
end
function _dj(s)
local t=_b7[s._cv+1][s._cu]
if(t.type!=_z and t.type!=_2 and t.type!=_0) s._c1=72
end
function _dl()
local s={
_ba=true,w=_b,h=_b,_dn={_fy=0},_do=0,_dp=3,_dq=0,}
return s
end
function _dm(s,_cu,_cv)
s._dr=true
s._cl=_i
s._ds=_i
s._dt=false
s.x=_b*_cu
s.y=_b*_cv
s._cz=0.6
s._cu=_cu
s._cv=_cv
s._cx=_cu
s._cy=_cv
s._du=30
s._dv=0
s._c1=112
s._c2=_af
s._c3=0
s._c4=false
s._dw=false
s._c5=0
_dj(s)
_dh(s,_v)
end
function _dx(s)
if(not s._dr) return
pal(4,14)
pal(15,12)
spr(s._c1,s.x-1,s.y-2+s._c5,1,1,s._c4,s._dw)
pal(4,4)
pal(15,15)
if _ci==_r then
local _dy=1-cos(time()*0.8)*2
_ey("— to play",s.x-16,s.y-10+_dy,11,1)
end
end
function _dz(s)
local _d0,_da=s.x,s.y
local tx,ty=s._cu,s._cv
if s._a8==_v then
local i=s._dn
local t=_b7[ty][tx]
local ta=_b7[ty-1][tx]
local tb=_b7[ty+1][tx]
local _d1=_b7[s._cy+2][s._cx]
local tl=_b7[ty][tx-1]
local tr=_b7[ty][tx+1]
local _d2=_d1._de!=nil and _d1._de._cw==_aa
local _d3=s._dt
s._dt=(tb.type==_y or tb.type==_3 or tb.type==_1 or (tb._ed>0 and tb._de==nil)) and t.type!=_0 and t.type!=_1 and not _d2
if(_d3 and not s._dt) s._cl=s._ds
if not s._ee and abs(s._cx-s._cu)<1 and abs(s._cy-s._cv)<1 then
if s._dt then
s._cy+=1
else
if i._cl==_h then
if t.type==_0 and ta.type!=_z and ta.type!=_2 then
s._cy-=1
s._cl=_h
end
elseif i._cl==_j then
if(t.type==_0 or t.type==_1 or tb.type==_0) and tb.type!=_z and tb.type!=_2 then
s._cy+=1
s._cl=_j
end
elseif i._cl==_k then
if(tl.type!=_z and tl.type!=_2) or tl._ed>0 then
s._cx-=1
s._cl=_k
s._ds=_k
end
elseif i._cl==_i then
if(tr.type!=_z and tr.type!=_2) or tr._ed>0 then
s._cx+=1
s._cl=_i
s._ds=_i
end
end
end
end
local _d4,_d5=s._cx*_b,s._cy*_b
s.x=_ev(s.x,_d4,s._cz)
s.y=_ev(s.y,_d5,s._cz)
if abs(s.x-_d4)<0.1 and abs(s.y-_d5)<0.1 then
s._cu=s._cx
s._cv=s._cy
end
t=_b7[s._cv][s._cu]
local tt=_b7[s._cy][s._cx]
if t.type==_3 then
t.type=_y
_bw+=1
_eo(t.x,t.y)
_ei(s,25)
_ej("250",t.x+3,t.y-5)
sfx(_ao)
_cs()
end
local _db=t.type==_1 and tt.type==_1
local _dc=t.type==_0 and tt.type==_0 and not (tb.type==_z or tb.type==_2)
if s.x==_d0 and s.y==_da or s._ee then
s._du+=1
else
s._du=0
end
local _d6=_b7[s._cv+1][s._cx]
local _d7=_d6.type==_z and _d6._ed>0 and _d6._de==nil
if not s._ee and not s._dt and not _d7 and (i._e9 or i._fa) then
if i._e9 then
s._d8=_k
else
s._d8=_i
end
s._cl=s._d8
s._d9=s._cy+1
s._ea=s._cx+_l[s._d8]
s._eb=_b7[s._d9][s._ea]
local _ec=_b7[s._d9-1][s._ea]
if s._eb.type==_z and s._eb._ed==0 and (_ec.type==_y or _ec._ed>0) then
s._ee=true
s._dv=15
s._eb._ed=440
s._c3=0
_en(s._eb)
sfx(_an)
if _a8==_p then
if s._d8==_k then
_ej("Ž dig",s.x-12,s.y)
else
_ej("— dig",s.x+15,s.y)
end
end
end
elseif s._ee then
s._cl=s._d8
s._dv-=1
if s._dv<=0 then
s._ee=false
end
end
if t.type==_z and t._ed<20 then
_dh(s,_w)
else
for c in all(_b1) do
if c._cw!=_6 then
local _ef=5
local cy=c.y
if c._cw==_5 then
_ef=3
cy+=2
end
if abs(s.x-c.x)<5 and abs(s.y-cy)<_ef then
_dh(s,_w)
break
end
end
end
end
if  _d0%6<2 and s.x%6>=2 and not _db then
if(tb.type==_z) sfx(_as)
if(tb.type==_2) sfx(_at)
end
if _ci==_t and i._ff then
_by+=1
if(_by==180) _dh(s,_w)
else
_by=0
end
local _eg,_eh=false,false
s._c5=0
s._dw=false
if s._ee then
s._c2=_ak
if _db then
s._dw=true
s._c5=2
end
_eh=true
elseif s._dt or ((_db or tt.type==_y) and _da<s.y) then
s._c2=_ai
elseif not _db and not _dc and _d0==s.x and _da==s.y and (s._du>15 or s._cl==_h or s._cl==_j ) then
s._c2=_ah
elseif(_d0!=s.x or _db) and not _dc then
if _db then
s._c2=_aj
s._c5=2
_eg=_d0==s.x
else
s._c2=_af
end
elseif s._cl==_h or s._cl==_j or _dc then
s._c2=_ag
_eg=_da==s.y and _d0==s.x
else
if s._du>15 then
s._c2=_ah
else
_eg=true
end
end
s._c4=s._cl==_k
_et(s,_eg,_eh)
elseif s._a8==_w then
if s._c0==1 then
local tb=_b7[s._cv+1][s._cu].type
s._c3=0
sfx(_aq)
if tb!=_z and tb!=_2 then
s._dr=false
_ep(s)
end
elseif s._c0==30 and s._dr then
s._dr=false
_ep(s)
elseif s._c0==120 then
_dh(s,_x)
end
s._c5=0
s._c2=_am
_et(s,false,true)
elseif s._a8==_x then
s._dp-=1
if _a8==_p then
_a5()
elseif s._dp==0 then
_cg(_u)
s._dr=false
else
_bt(false)
end
end
s._c0+=1
end
function _ei(s,v)
if(_a8!=_p) s._do+=v
end
function _ej(t,x,y)
add(_b3,{_fq=t,x=x,y=y,c=11,_em=30})
end
function _ek()
for t in all(_b3) do
t._em-=1
if(t._em<20) t.c=6
if(t._em<10) t.c=5
t.y-=0.2
if(t._em==0) del(_b3,t)
end
end
function _el()
for t in all(_b3) do
_ey(t._fq,t.x-#t._fq*2,t.y,t.c,1)
end
end
function _en(t)
for i=0,10 do
add(_b2, {
x=t.x+1+rnd(4),y=t.y+rnd(4),r=rnd(2),rx=rnd(0.1),c=_eu(rnd(1)<0.2,13,3),dx=0.2-rnd(0.4),dy=-rnd(0.5),g=0.05,_es=30
})
end
end
function _eo(x,y)
for i=0,10 do
add(_b2, {
x=x+rnd(6),y=y+rnd(4),r=rnd(2),rx=rnd(0.1),c=7,dx=0.2-rnd(0.4),dy=-rnd(0.325),g=0,_es=30
})
end
end
function _ep(s)
local c1,c2=10,15
if(s==_br) c2=12
for i=0,10 do
add(_b2, {
x=s.x+1+rnd(4),y=s.y+rnd(4),r=rnd(2),rx=rnd(0.1),c=_eu(rnd(1)>0.8,c1,c2),dx=0.2-rnd(0.4),dy=-rnd(1.75),g=0.075,_es=30
})
end
end
function _eq()
for p in all(_b2) do
p._es-=1
if p._es==0 or p.r==0 then
del(_b2,p)
else
p.r=max(0,p.r-p.rx)
p.x+=p.dx
p.y+=p.dy
p.dy+=p.g
end
end
end
function _er()
for p in all(_b2) do
circfill(p.x,p.y,p.r,p.c)
end
end
function _et(s,_eg,_eh)
local _bu=0
if(not _eg) _bu=s._cz*s._c2[1]
if _eh then
if(s._c3<#s._c2-2) s._c3=min(#s._c2-2,s._c3+_bu)
else
s._c3=(s._c3+_bu)%(#s._c2-1)
end
s._c1=s._c2[2+flr(s._c3)]
end
function _eu(c,t,f)
if c then
return t
else
return f
end
end
function _ev(c,d,s)
s=s or 1
if(c<d) return min(c+s,d)
if(c>d) return max(c-s,d)
return c
end
function kb(k)
return stat(30) and stat(31)==k
end
function _ew(s,y,c,_ex,sc)
local _e1=0
for i=1,#s do
if(ord(sub(s,i,i))>134) _e1+=2
end
local x=64-_e1-#s*2
if _ex then
_ey(s,x,y,c,sc)
else
? s,x,y,c
end
end
function _ey(s,x,y,c,sc)
for y1=-1,1 do
for x1=-1,1 do
? s,x+x1,y+y1,sc or 0
end
end
? s,x,y,c
end
function _ez(s,x,y,c)
if(c!=nil) pal(11,c)
for i=1,#s do
local n=ord(sub(s,i,i+1))
local f=0
if n==32 then
elseif n<=57 then
f=22+n-48
else
f=32+n-97
end
if(f>0) spr(f,x,y)
x+=8
end
if(c!=nil) pal(11,11)
end
function _e0(s,x,y,c,sc)
for y1=-1,1 do
for x1=-1,1 do
_ez(s,x+x1,y+y1,sc)
end
end
_ez(s,x,y,c)
end
function _e2(n,l)
local s="0000000000" ..n
return sub(s,#s-l+1)
end
function _e3(s)
local i=s._fy
if s._fj!=nil then
local _b8=s._e6
local _e4=s._fj
local _em=s._e7
local _e5=s._e8
if _e4!=nil then
if _em==0 and _b8<#_e4-3 then
_b8+=3
_e5=sub(_e4,_b8,_b8)
_em=tonum("0x" ..sub(_e4,_b8+1,_b8+2))
end
if _em>0 then
_em-=1
else
_e5="" end
s._e6=_b8
s._e7=_em
s._e8=_e5
end
s._e9=_e5=="o" s._fa=_e5=="x" s.up=_e5=="u" s._fb=_e5=="r" s._fc=_e5=="d" s._fd=_e5=="l" else
s.up=btn(2,i)
s._fc=btn(3,i)
s._fd=btn(0,i)
s._fb=btn(1,i)
s._fe=btn(4,i)
s._ff=btn(5,i)
s._e9=s._fe and not s._fg
s._fa=s._ff and not s._fh
end
if s.up then
s._cl=_h
elseif s._fb then
s._cl=_i
elseif s._fc then
s._cl=_j
elseif s._fd then
s._cl=_k
else
s._cl=_g
end
s._fg=s._fe
s._fh=s._ff
end
function _fi(s,_e4)
s._e6=-2
s._fj=_e4
s._e7=0
s._e8="" end
_fk={
_ba=false,_fl=0,_fm=function(self)
self._ba=true
self._fl=128
end,_fn=function(self)
if self._ba then
fillp(0b0101101001011010.1)
circfill(64,64,self._fl,1)
fillp()
if(self._fl>8) circfill(64,64,self._fl-8,1)
end
end,_fo=function(self)
if self._ba then
self._fl-=3
if(self._fl<=0) self._ba=false
end
end
}
_fp={
_ba=false,_fm=function(self,_fq,fromy,_fr)
self._ba=true
self._fq=_fq
self.y=fromy
self._fr=_fr
end,_fn=function(self)
if self._ba then
local x,y=(128-#self._fq*8)/2,self.y
rectfill(0,y,127,y+16,10)
rectfill(0,y+1,127,y+15,14)
_ez(self._fq,(128-#self._fq*8)/2,y+4,11)
end
end,_fo=function(self)
if(self._ba) self.y=_ev(self.y,self._fr,2)
end
}
_fs="^^^s^   |c$^^ s^   |!#h!#   s^   |^ hdd--sc$c|^ hc##h   !#h##|^ hc##h^ch  |c 0 hc##h^ $0 h  |##ha#c!##h!#|  h^^c h^ |  h^c 0c h^ |!###h!ah^ |^   h^ch^ |^ $ hdd--h   $   |ch!^   !#h|ch^   &  $^   h|#|   $^^^c h|h@@#@@h^c $^  h|hc hch!###h $   h|h $ 0 hch^   haxh|h#@#@#hch^   hc s|hc hdhd--  0hc s|hc hchc h###b@@h|hc hch  $  h^   h|h   0 h $  ha#h^   h|@###@##@##@h^   h###h##|@###@^h^   h   h  |@$  @^h   d--h   h $|!##h###bc h  a|^  h^^h^|^  h   &^  h^|#|^^^^   s|dd--c$^^s|h $^h!ah^s|a#h   h^chb@@@|c h 0 hc $ch^ |c h!ha#h##^ |  $  h^hc h  --c |ah#^h  0  hc--   |chch!h##^--$|chdh^h  0^ #|ch^ h!###hc |10|###h!a   $   a#h#|###h!a h###h a#h#|   h^&ch###h   $  h |#|s^^^^   |sdd---^^c|hc hc # $ #c hc |h $  hhh  $ a# $  hhh  $ |h hh  h  hh^ hh  h  hh |h h hhhhh h^ h hhhhh h |h h  $0$  h   h   h  $0$  h |h  ha#h   hhh   ha#h  |h   hhhhh hh  h  hh hhhhh   |h^   h hhhhh h^   |hc$ch  $0$  hc $   |h!h   ha#h  h!#|h^hchhhhh   h^ |h^h^^h^ |h^h^ $  & h^ |#|^   s^^^|^   s^ $^0   |###^s^ah!#|  ##c sc ##   h^ |   ##csc##ch^ |$0 ###   s  $###ch   $   |##ha  s  ah###h!#|  h   ## s ##   h^c |  h$0  ##h##chc $c |h###hchc #h##h###c |h   h^^  h^  |h   hc$c 0   h^  |h   h!#h!ha#h##|h^c h^^h  |h^c h  &^   h  |#|!!!s!###|# $^^   s# 0 $   #|#x###hah   $   s!#h#|#x###h!!## ###  h#|#ch  $ 0c a ###  h#|#h!###h!## ###  h#|#h   !ha#$$# ###$ h#|#h   !h!!##h#|#h   #c$hc$  0   $ #h#|#h   ###h!#h!#h#h#|#h  $###h^ h!#h#h#|#h##x#  hc&  h  ##   h#h#|#h##x#ha#h!##$$ h#h#|#h##x#ha#h!$!h#|#h0   h##$##hc$  0c h#|#|  s^^^^ |  s^^c dd|  s^c0^h^h|a#h#c#h###   0hc$ h|c h^hc###h!#|  0  h   $  h^ h^ |a#ha  h^ h^ |c h^h^ h^ |  $  h   $  h^ h^ |##h!!hch a h|  h^^h $  h a h|  h  $^   hdh # $# h|!#h^^h a#h|^ h^^h^h|^ h &^  $ h  0   h|#|^c scs^c |0|   $ 0   h#scs#h   0 $   |ha#h--h#scs#h--ha#h|h#   #h   #scs#   h#   #h|4|h# $ #h   #scs#   h# $ #h|ha#h   #scs#   ha#h|4|h#   #h---#hah#---h#   #h|h#   #   h#hch#h   #   #h|h#0$ #   h#h  $0m|h##x##   h#b@@#h   ##x##h|hc x  h^  h  xc h|h^x0hc&   h x^h|#|s^^^^   |sdddddd---|h# 0   #^^ #c #|h a#^^   a# |h # ###^^   #$### |h a# 0c0^0 a# |h ### #x!!a# # |h a#x### $## $!##h# |h a#x!!a#h# |8|h a#xac!###h# |10|h a#xa   $h!##h# |h^c ahddh  |h^cb^^ |h^&  b^0^ |^c$^^  s  |^  h!#  $^s  |c$   h^!cs  |!ah^   $cs  |^ch!sa#h##  |0^   h^sc hc|!ah^s 0   h   $|!ah!#@@   ha|!ah^^hc|!ah^ $ ---hc|##^##h^ ##   hc|##  $$  ##hc $^hc|!a#h!#h   hc|^c h^ !##h|c$c& h^^   h|#|^ h^^^  | 0$ch^^c $0 |h##0$  h^^   $0##h|h  ##  hasha#h   ##  h|h^c hh$ch^ h|h^c $hhch^ h|h^c hh$^^h|h^c $hh^^h|6|7|6|7|6|7|h^ &   hh$^^h|hch!!ahch|^$c $^c h   |h!!a#hc h   |h^^ $   hd-h  $|!###h!###c h###|!##hh^^  h   |!#hhd---h^ h   |#$ $##hh^0 h  $  0 h  $|a#hhc ha@@@ah###|c h^h^c h   |8|c0h   $  hdd---h  $|h!a#h  $c $  h###|h^c h !### h   |h^c h^c h   |h^$chc& $ch   |#|^^0^c0c|xhxhxhxhxhxhxhxhxhxhxhxhxhxs|1|$h#h h#h$h#h h#h$h#h h#h$h#s|xh#hxh#hxh#hxh#hxh#hxh#hxh#s|4|4| h#h$h#h h#h$h#h h#h$h#h h#s|4|4|$h h h h h h h h h h h h h#s|h!!!!##s|h^   $ 0 $   $ 0^s|hbbbbbb@@s|h$^ &^^c$s|#|  h   0c-   0-hch-   $| -h   -h-   -  - h-   h -  h|- h  - h -c-  h -  h  - h|$ h -  h  -  -   h  -$h   -h|  h-  -h   --ch$  -hch|h-   - h-  --  - hd-- -  |h -   -h  -$ -   h  -   h - |h- -   h$--h  -  hc -h  -|h - -  h-- h   - hc- h  -|h- $ -0h-  h -  -h-  -  h  -|h -h  -ch   -   -ch  -|h- h   -   h  - -   -   h  -|h -h -  -  h$-   -   -  h $-|h- h   - - h- -  $-   - h - |h -h  -   -hc - - - -h-  |   hc $c $&^ h   |s^^^^  s|sc $ 0  $c $  0 $cs|ssss!##h   h!##sss|^^h   h^c |^ h!!#h^|$  0  $hc $ $c h$ 0  $|!#h $ $a#$ $ h!|^ h a   a h^|c$  h^$^h $c|  h!!!ah  |  h^c &^ch  |  h $c$h!#h$   $ h  |!ah^ h!###|^ch^ h^   |  $^ h^ h^$  |#@#@#@#@#@#@#@#@#@#@#@#@#@#@|^^^^ s  |^^^  &c s |   xahh!hhhhh^s|^   h   #  h^   s |c$c h h#  h^  s  |c#$c hh#  h^ s   |   ###$c h#  h^sc|  a#$ch#  hc sc |!##ch#  h^sc| $a#c h#  h^ s   |   ###^h#  h^  s  |c#^ h#  h^   s |^ 0ch#  h   0^s| h!!##x!### s| !!###^   h#s|!!a   $$$$$$h##|s^^^^  s|0|s^   0^^cs|h###x!!!ah|3|h   $   ##dd##^ h|h^ $#hc0 $##c0  h|h  ###  ##h !##  a#h|h  #$#  ##h^ ##  ##$##h|h   &   ##h^ ##  a#h|h  ###  !##hh##  ##$##h|h  ###  !##hh##  a#h|h  ###  ##^h ##^ h|h  ###  ##c $h ##c$  h|!ah!###h!#|!#  $h! $ h!#|   s^^^^|   s^$^   $^$|hx#hch###hc h###h#  #h|h  !   ha#h   h  $ h|h$ 0^  hc h   a h|hxa^   ###h#^ h|h @a^ ##^  h# h|h @a#c ##^ h#h  h|h @!a#c$   h   ##|h @!a#   ###  hc |h @c### ###^  h   0$|h @  $ ## $ ##c 0  h   ##|h @h!a#h!h   ##|h  h^c h^h   ##|h  h^ &^ch   ##|#|^^h##h^^|^c0$h##h$0^c|^ch!h^c|^   $h!h$^   |^  h!ah^  |^0$h!ah$0^|^h!!##h^|c $h   $$$$$$$$   h$c |ch!!!hc|   $h!!!h$   |  h!!!ah  |10|  h^^^ch  |12|  h^c&^c h  |#|^^ 0$^^ |^c !##h   0 $  |^ 0 $^   h#ha#h|c $a#h^ h hc h|###x###chd---h h$ch|^c h^ h !#| $^   h^ h^  |###h!#h^ hdd|$  h   0   hc$  h^ $|!###  !##hca|^ $   $^ h^  |a#h###x###h  $  h   $c|c h^ !!##h|c h^^^   h|c h $   &^$^  h|#|bbbbbb@@s#|hddddd--hsss#|h  hc ##  0   $c hs$ #|h  h !!!###h#|h  h ###^^$c h#|h  h   # !!!#|h  h  h#   $  # $ # $ # $  #|h  h  h##h!!!|h  h--h  ha# a#^#|h  h  h  hc# $#c 0   #|h  h  h  h--h ah--!#|h  h  h  h  hc h  !#|h  h  h  h  h--h  h  !#|h  h  h  h  h  h #h### $$$ #|h  h& h  h 0h  h  h###ha#|!!!h $$ha#|^ $c$^^   |$$!!ah^   |##^c$  $  h^   |^   h!##h  $   $  |^   h^  h!## |c$ 0$ h^^^|   h!hd--c $c |   h^h^h!###h| $ h^h^h^   h|###hc0 h  0 $ h^ $ h|^h###h!hcha#|^hddc$  hc |c$ h$^ h!h   $ |!#h^ h^ha#|^ h^ h^^|^ h  $  & h^$c |   bb@^c sc|  @^   @^cs @@ | @   $$ 0c#h^  s @@ |@@##h!##@@hc0  s$@@ |@###h!a#h##@@@#hb|@##hhh#d---#hhh#dh---h|@##h h#  $c#h h# $c$ h|@##h h#  &c#h h#^  h|@##h$hahah$h#@^@h|@!###h!!ah|@^##hhh##  $c$   $ h|@d--#hh hhddd--h|@ $c#h   h^^0 h|@^ h   h  !a# h|bch   h ### $##  $ ##h|@!@h$ $h  !!#|^^cs^c |^^   ss^c |^^  ss^^|^^ ss^^ |^^ss^^  |^^s^^   |^ch##h^^  |^ch##h$^^ |^ h!#h  0^   | #h  0 h# $ $ #h #h#h^ |  ###h!!h###hc |   ## $  a $   h$  ##h   |cah  $ ###h h##h #h   |c #$#h###h $ h h$#h$#h   |  0   !!!h & |bbbbbbb|c@c @c @^   s@|c@c @c @   $c s@|c@xa@c @a  ###s@|###^   ###h0  $c $s@|!a#h   h!## #h@|^ &   h ##h#   $c#h@|#h!###h $#h# a#h #h@|#dd##h ##h# #ch #h@|#  #  # $##h   hh # ###h #h@|#  #  #  #hhah##$###h #h@|#  # $#  #h#^# ###h  h@|#  a  #h# a #ch#hh@|#h##  ##hhh# #$## !#h @|#h   @@#hh##   #  ##$ch#@|#h   @   h##xax!#h#@|#h###chc 0^   h @|^^^^  s |c 0^^^  s |h!ah  0  $c $  s |h^cha#h   ###h###|h $^$ hc@h^h   |h #  ### # h $$ @hc0 h   |h # ###  # h @@ @!###@@|h #  ### # h @@^c @$|h # ###  # h @d---  $  @h|h #$ ### # h @$^ah@h|h a#  # h @@^ch h|h !## h @@c$c h##|h^ch @@ !   h  |hbb#b@^ch  |h^^ &^ch  |#|s^^^^  s|s^&^^0^s|s   @#h#@dd--@#h#@   s|s   @$h @ $^$ @ h @   s|s @## h ##@^@## h$##@ s|ss@$  h  $@ $   $@ $ h #m|@s### h   ##@  @a#h # #s@|@c hc @ $@$ch #  $@|@c ha#@h#@##  $h ## #@|@ $ 0 h   0  hc ##hc @|@hah   @##h###@   h   #h@| h@ $ h   #  h $ #   h  0m| h@## h ###  h m| h $@ h @chc$@ h @$ h | h   ###c h^###   h |#|^^ s^^  |dd---  s^^  |  $c$ @h  s $^^|!###b@@@h  $h@hc |#@#@#@#b@   b@@@hc |^c@@  $^@h 0$  |ddh @@a#h   @@ah|^  h @@c h0cah|^  h @@ !##h ah| $c$ h @@ #^#h ah|###0  # h @@ #   $  #h ##$#h|!# h @@ !##h ## #h|^  hc#  $   #hc#h|!!## h##h !#h|^c&ch $h^  h|#|  0 -- -^^ 0^|a  h   -^   ##hc |a  h ## -   0   -##hc |#$$#  h ##- !#  -hc |a  hc !# h h###  |^h---  !# h  #$#  |c-c h !# h  ###  |c a h ##$$$## h^ |   - a h !# h^ |###- #$$# h-c - -h^ |#$#  a h -   - h  a   |###^ h   &   h  a   |^ch  ###  h  #$$#   |   ##c h  #$#  h  a   |   ##c h  #x#  h^   |^ch^ h^   |@^^^^  s|@c $$$$0 0 0^&c s|@!ax!!###h|^^^^   h|c@ $  $^ $^$@ h|c@!#x!#xa@ h|3|^@  $c$c $  @   h|^@###x!xa#@   h|3|^ @  $c $c$@ch|^@@!!##@ch|3|3|$$$$   0^c0c h@ h|!ab@@!#@@@ h|^^ s^^  |0|$^^ss^^$|#h hdd--sdd-h h#|##hh 0^^c$ hh##|###h hd-- dd-h h###|ahh $^^  hha|axh hd-- d-h0hxa|ax#hh^c$ hh#xa|ax##h h--- dh h##xa|ax###hh $^hh###xa|axah h-- -h haxa|axa#hhchha#xa|ax!hch!xa|ax!#h&$h!#xa|a0^ h##h^  a| |###sa^   d-- 0   |   s --  0^^b@h|   h#  a#h!---   # h|ha  #$---hd-#   ah#|h^a   ###h#   #$  h |h^#dhdh#   #-  h |h &#   #h$#$h$#h$h#   #   h$|#h##   !!   ##h###| hc$#c $c#c h   | hc##   ###h   #c h   | h  $# #^h   #$  ha#| h  #  #   $  h   ##  hc | h$#   # h!h # #$hc | h#  $ # h#  $ #hc#hc |#|a#s!!a# a|c#s# d---^^#|s##s s# #$   #h#^   0 #|s a# !ha#$ #ha|#sc$---ah!##h# ##|!#   #  #h### ah# ##|^ 0c #h### ## #h#$ #|h!#h#h$ #h### ## #ha|h^ ha#h###$ # #h## #|h^   ah! #h##$#|h^ #c h^  h   #|h###hah#@#@#@#@#@#@#h#@#@|h###hah!  a#h#@#@|h   hch!#  ahc|h!##h!##$ !#h|h&^ h $ !  0c h| dd$$!$$dd |h^ $###hhhh###$^ h|h^$##hhh00hhh##$^h|h^##hh^hh##^h|hc $#hh^  hh#$c h|hc ##h$^  $h##c h|hc #hh$^  $hh#c h|hc #h$$^  $$h#c h|6|5|h^#hh$^$hh#^h|h^#xhh$$  $$hhx#^h|h^ x#hhh$$hhh#x^ h|h^  ###hhhh###^  h|h&^0  !  0^ h|!###h^  h!###|s^^##^^s|s^^@@^^s|s $^ $  ##  $^ $ s|@#@#@#@#@#@#h@m|   $c $  h##h  $c $   |h@#@#@#@#@#@#@m|h   $   $c##c$   $   h|3|c$0 0$   h##h   $0 0$c|5|h  $c $   ##   $c $  h|3|  $^ $ h##h $^ $  |5|h^^&^^ h|#@#@#@#@#@#@#@#@#@#@#@#@#@#@|c$c$c $^ 0$   |h!h### a#h### a#h|h^h^   h^   h| h^h  -ch^   h |h^h  - -ch^   h| h^h-   -  h ddh |hd--h^-  h^   h|c0   h-c -h^   h |! h  -   -  hc0$ $ h|## ###  h  - -  hc-###@@@| $   $ hc-ch   -###@@@|##x###  h  - -  hc-###@@@|##x# # h  -   -  h   -##$$@@|  $ $   h-c -hc-b@@|! hc$ &  h $  b@@|#|s^^^^   |s^0^^^  |s!ab@@#b#bh|$^^^   hch|##^   @   $c$---$  h|a#hh#hh!##  #   #  h|c#hh hh# @@ac 0   h|c#hh$hh# @ a ###hah|c!# @$###c hch|^^^chch|^ &^ #ha#hbh|##h!##h### h $$  hch|  h^  hch @@c ##h|  h##$#ch  ### @@! h|  ha   0h   $  @@^ h|!!!@@ab|s^^^^  s|0|!hah0 0hah!#| -chch@h@hchc - |h a#^h   $  ! h|h a#  #hhhhhhh#  ! h|h ###$#  #hb@h#  ##$### h|5|h^   d---^ch|h 0   h^@^hc0 h|hb@hc$@@@$chb@@h|hc hcb@ch^h|ha#h   b@@@   h!h|hc h $bb@$ h^h|hb@h bb@@@ hb@@h|$c hbbb@h  &   $|###  s ##c##c## s  ###|a sa 0a 0as a|h  ##h#  ##h# m|h   #h--h #h   $m|h 0a$hahhah$a &h|h###  ##h#  #h#m|h##c#h$   h#   $h#c##h|h###  ahhahha  ###h|2|h   #hc#h   $h#ch#   h|h  ahhahhahha  h|5|h##c#hch#ch#c##h|7|hc$chh $  hhc$ch|h!!!!##h|s^c!!a#|s^c!##@ d--#|sc$   h#c$   @h # $  #|!###h@!# @h !|c$ch@c$   @h !|h!###@ ##x### @h !|hc0$   @^$ @h   0   |!###h@ ##xxx# !##h| $^ h@c$^c h|h!###@ ##x###^   h|h  $^@^$^   h|!###h@ ##xxx#  a#  h|^  $h@^$  #  $#  h|h!###@ ##x###ch##  h|h   0^ &^   h# $ h|#|c--$ dd0d- d-|   h $#$^  h- # -h  $$$|$&h $# #$^h- ### -h  $$|## $#   #$ch- #   # -h  $| 0 x  #  #   h- ##   ## -h 0|h##  ###  @@@-   #$$$#   -m|h   #   #   $   hh###^h|h  - ###   $h  h##h#^ h|h   - #   $h   h$$h d---h|hc-   $h   hbh^ h|@@@h  ---hch$  $h d--h|   h^   h!h^h|###h###hc h$c$h d-h|^ hchbbhc h|^ h  0 h$   0  $h dh|!##b@!##hc h|  $^ $^c$c$ |h###ch###ch!ah|h $   $ hc $ h $c$   h|h###h###h   a#@##@a@##|h   h  0h   ddd--- |ah!h^$   $0   h|ch^h @ab@@###h|chb@ h @^$  $   h|#   h  $ @ h @   bb@ h|#$$@@@###@ h @   @  $ $  @ h|###@@@###@ h @ $ @ hah@ h|  $  $c h @@x@@ hch@ h|!###  h @c h   0h@ h|  $ $   @  h @!##b h|!h ba@   $  $  &h|a$#h^c h!###| |  s^^^c s |  h!!!a#h |  h h##   $   $ 0 $   ##h h |  h###h!!###h###h |  h h h ### $   $0##h h h h |  ##h###h h!#h h###h## |  h h h h h h###h h h h h h |  h###h###h h $ h h###h###h |$ h h h h h0h@@@h0h h h h h$|ah###h$h@h@@@h@h$h###h###|##h h h h@h@h@@@h@h@h h h h#|##h## h@h@h@h@@@h@h@h@h ##h#|##h h@h@h@h@h@@@h@h@h@h@h h#|##h@h h h h h  &h h h h h@h#|!!h#$#h!a#|!!!!###s|#   hhhhhhhhhhhhhhhhhhh   #s|# & h hhhch   hh   h 0 #s|ah hhh hh h hh h hhhas|#   h hhh hh h hh h   h   #s|# 0 h hhh hh h hh h hhh 0 #s|ah   hch   hh   has|hhhhhhhhhhhhhhhhhhhhhhhhhhhs|h $ h $ h $  h  $ h $ h $ hs|7|h   h h h hh h hh h   h   hs|h h h h h  h h  h h hhh h hs|h  hh h h h  h h  h   h  hhs|h h h h h hh h hh h hhh h hs|h h h   h hh h hh h   h h hs|7|bbb@@@  s bb@|  0h^h---   s h^$ |@@@s##b@#x#@@@s hb h@#|@--h^ hdh  h   a#|@  h^ $ #$#h0 h  $   ##|$ xh^ hc@#h @@a@#|@#xhd---hd-@hd---h@|#$ @^ h   $h@@@^h#|@@x#c$$$hch@d  $ hh|@^chch@h $   x#@h|###x##c h &  h@h^  h|#hd h@###@##x@@h^  h|#h$   #h^  h#h  @a h|#h@--###h^ h@h  # $ @ h|#h  ###@#h  0   h h   #@@#@@|@a#b!!##@###| $^^^ s^|ah^^0   s^|  $ h^ch!h   $ |!##h!hc !#|^  h^h $^  $ |c $  h^h!!|#h!h   $  h^^| h   $  hb@@h^$c |#h!h^a#h!h|^  h 0c$ch^h| $^h###h!#bb|###ha#   h  $^$ 0   |   h^ h!##h!#|   hd---h^  h^ |   h^   &^hc $ |!!!a#sa|@^^   bb@@@s|@0^  0c @  $ @c s|@@d--a#h &@ h@ @h@###s|@a#   $  ###@@ h@ @h@###s|@c!^ h@ @h@   s|###h^ah $ h@ @h@ $ s|# ###@#h^h###@@ @h@###s|#  $  ##@#h   hc@ @h@###s|a#c###@#hc@ @h@   s|# $ #@h#c ##@##h@ @h@$$ s|###   h##@@#  $  @h@ @h@###s|# #@##hc###@@#@h@ @h@###s|#   ###@##h  $   @h@ @h@ ##s|# h##   $###@@#h#@h@ @h@  #s|# h#^c h $h@  h   $s|#$h#@a@a#@##@@##@a#|^^$^^   | d--- ah&^^ |h^c$ hc$^$  |h^  hb !#ha#|h^  h $^chc |h!h ah^  hc |h^h   $ h0h!a#h|h^h hb hbb@@@h|hc$h# h$ch@c $   @h|hch#  ah h@hb@@@h@h|h  $h#^$h h@h@   $  h@h|h  h#chb h@hbb@h|h h#c h $   h@hc$ch|hh#^ah hbbb|hh  0^  s hc0^ |#|c -c - -^-  $  $ |-   - -   - h -c- h!| - -   - -  h  -  -  h^|  -c -   h   --   h  0   | $   $  $   h   -chb@h|b@@@xb@@h-c h@ $ @h|^^  @^h@h@$@h|^^ $@  & $ h@h@$@h|h!ah#@@ha-h@h@$@h|hc 0ch##hhc h@h@$@h|hc##ch##h   $0  @h@$@h|h ###  ### h##@@a#h@hd|h ###  ### h##^ h^|h ###$$### h#c --$h a |h $ $##$ $ h##  h#  #h##$$##|#|h   -^^^hd|hch^^c h @  |hch^^ 0   h @$$|h $  ha  $  $ha#x#h###|h##  h   !###^hh#x|hch^^^ hhx|hc hdddd---hh|hc h^^^  h|hc h $^ 0   $c $h|hc a#hbb@@##x###|h---^ h^c---   |   0$^h^   h^|!###h h   $c h-   $ |^  a#h@@@ha #$###|$^ &ch   h   0 a#|!!#h   h!a|#@#@@#^^ s@#@@###@|##@@##^^ s#@@###@@|   @#@#  $^$  s#@c @|h#   @##@###@h##@  s#@ #@h @|h#@  @#@@###@h ## $s@  #@h @|h##c @##@@h  #@### $#@h @|h@##$c#@@#h^  ##@h$ |h#@a   @##h  d---#@@#h|h @@#@##$  #@h $^ #@  h|hc h##   @@#@@#@c#@  h|@###@@h@##^^$#@  h|#@#@@@h#@##$   0c$###@  h|   $  h@@###xb@@x###@@h##|h#@###@@   0^   &   h@#|h@###@  h##@@#@@##@#@@##@@@#|h   $   h^^0   @#@|^   h^^^|^   h^$c0^|d  $  sc bbbh|h  b@@@^^c h|h^   d-  d- hb|hdd-^  hchc|c0^c$  h#   hc|hbbbb@@#   bh|h^^^^ hh|h^$^$c 0  @  h |b##bh #@@#bb  h |^ch^^   h |^ $  h^$^  h |hbb@@ bb^h |h^^^ d--h |h^c&^  0^ | |^   0c 0^  $ $s|^h!!##  ha|^h !!  ha#|h!  #$##$##$##  h!|h!#^c 0h!#|h!!#x!###c|h!##$ $c$ $a# $$ |h!###x###x!!#|h^ 0^c$!  |h  ha#ha#h  -ha  $h|h  h  h  h  h  h   ###  $h##|h  h$$h$$h$$h$$h   #  $ha|h  ha#ha#hc$h!|h^^  &   h!##|h!!!!###|s^^  !!#|s  $c $c !!#|!!##h  $^c|!!!!###h|c $ 0   0 $^^ h|h!!!!###|h^  $^c$^ |3|c$^  $^$^h|5|h   $  0 0  0c $^   |3|   $^$^$^$  h|5|hc $^c $  &^|#|!!s !!##|#dd-# s  #dd-#  | #$  h  $#  s   #$  h  $#   |  #$ h $#   sc#$ h $#c|   #$h$#csc #$h$#c |c#h#c sb@##h#^| &  #h#c s@   $ #h#  0   |###h#h!x!#h!h|   h h 0^^h^h|h" _fu={}
function _ft()
local x,y=0,0
for i=0,8191 do
local n=mget(x,y)
_fs=_fs..chr(n)
x+=1
if x==128 then
x=0
y+=1
end
end
local _fv=split(_fs,"|")
local _fw,_e4,_fx=0,"",{}
for i=1,#_fv do
local s=_fv[i]..""
if #s<3 then
local _fy=tonum(s)
if _fy!=nil then
s=_fx[_fy+1]
end
end
if(#s==1) s=_f0(s,28)
s=_f1(s,"!","######")
s=_f1(s,"^","      ")
s=_f1(s,"a","####")
s=_f1(s,"b","@@@@")
s=_f1(s,"c","    ")
s=_f1(s,"d","----")
if sub(s,#s,#s)=="m" then
s=sub(s,1,#s-1)
local _b8,_fz=1,"" while #s+#_fz<28 do
_fz=sub(s,_b8,_b8).._fz
_b8+=1
end
s=s.._fz
end
_fw+=1
add(_fx,s)
_e4=_e4..s
if _fw==16 then
add(_fu,_e4)
_e4="" _fw=0
_fx={}
end
end
end
function _f0(c,l)
local s="" for i=1,l do s=s..c end
return s
end
function _f1(s,fc,rs)
local _f2="" for i=1,#s do
local c=sub(s,i,i)
if c==fc then
_f2=_f2..rs
else
_f2=_f2..c
end
end
return _f2
end
_f3={
_f4=function(self)
self._f5={}
for i=1,100 do
add(self._f5,{x=rnd(128),y=rnd(128)})
end
end,_fn=function(self)
for i=1,100 do
local s=self._f5[i]
pset(s.x,(s.y-time()*(30+i%3))%128,5)
end
end,_fo=function(self)
end
}
function _f6(s)
local _d4,_d5=s._cx*_b,s._cy*_b
s.x=_ev(s.x,_d4,s._cz)
s.y=_ev(s.y,_d5,s._cz)
if(s._c7>0) s._c7-=1
if abs(s.x-_d4)<0.1 and abs(s.y-_d5)<0.1 then
s._cu=s._cx
s._cv=s._cy
if s._cw==_6 then
s._c0+=1
if s._c0==60 then
s._cw=_4
end
elseif s._cw==_5 then
s._c0+=1
if s._df._ed<10 then
if _b0<15 then
_ei(_br,10)
_ej("100",s.x+3,s.y)
end
_ep(s)
_dd(s)
sfx(_ap)
elseif s._c0>=240 then
s._cw=_ae
s._df._de=nil
s._df=nil
s._cy-=1
end
elseif s._cw==_ae then
if s._cy==s._cv then
s._cw=_4
s._c7=2
end
elseif s._cw==_6 then
else
local _cw=_gc(s)
local t=_b7[s._cv][s._cu]
local tb=_b7[s._cv+1][s._cu]
local _f7=false
if _cw==_9 and tb.type==_y then
_cw=_aa
elseif s._c7==0 and tb._ed>30 and tb._de==nil and _cw!=_8 and _cw!=_9 then
_cw=_5
tb._de=s
s._df=tb
s._cy+=1
s._c0=0
if(s._c6>0) _gt(s,true)
if _b0<15 then
_ei(_br,5)
_ej("50",s.x+3,s.y)
end
elseif t.type==_3 and s._c6==0 then
s._c6=flr(rnd(1)*26)+14
t.type=_y
_eo(t.x,t.y)
end
s._cw=_cw
local _f8=false
local _f9,_ga=s._cu,s._cv
if _cw==_ac then
_f9-=1
elseif _cw==_ad then
_f9+=1
elseif _cw==_8 then
_ga-=1
elseif _cw==_9 or _cw==_aa then
_ga+=1
end
local _gb=_b7[_ga][_f9]
if _gb.type==_2 or (_gb.type==_z and _gb._ed<40) then
_f8=true
else
if(_gb._de!=nil and _gb._de!=s and _gb._de._cx==_f9 and _gb._de._cy==_ga) _f8=true
end
if _f8 then
elseif _cw==_ac then
s._cx-=1
elseif _cw==_ad then
s._cx+=1
elseif _cw==_8 then
s._cy-=1
if(s._c6>0) _gt(s,false)
elseif _cw==_9 then
s._cy+=1
if(s._c6>0) _gt(s,false)
elseif _cw==_aa then
s._cy+=1
end
end
end
end
function _gc(s)
local x,y=s._cu,s._cv
local t=_b7[y][x]
local tb=_b7[y+1][x]
local px,py=_br._cu,_br._cv
local _gd=false
if not _gd then
if t.type==_0 or t.type==_1 then
elseif tb.type==_y then
return _aa
elseif tb.type==_z or tb.type==_2 or tb.type==_0 then
else
return _aa
end
end
if y==py and not _br._dt then
while x!=px do
t=_b7[y][x]
tb=_b7[y+1][x]
if t.type==_0 or t.type==_1 or
tb.type==_2 or tb.type==_0 or
tb.type==_z or
tb.type==_1 or tb.type==_3 then
if x<px then
x+=1
elseif x>px then
x-=1
end
else
break
end
end
if x==px then
if s._cu<px then
return _ad
elseif s._cu>px then
return _ac
else
return _7
end
end
end
return _ge(s)
end
function _ge(s)
local _gf={
_gg=255,_gh=_7,_gi=0,_gj=0,_gk=s._cu,_gl=s._cv
}
local x,t,tb,tl,tr,_gm,_gn
local y=_gf._gl
x=_gf._gk
while x>0 do
tl=_b7[y][x-1]
_gm=_b7[y+1][x-1]
if((tl.type==_z and tl._ed<40) or tl.type==_2) break
if tl.type==_0 or tl.type==_1 or _gm.type==_z or _gm.type==_2 or _gm.type==_0 then
x-=1
else
x-=1
break
end
end
_gf._gi=x;
x=_gf._gk
while x<_c do
tr=_b7[y][x+1]
_gn=_b7[y+1][x+1]
if((tr.type==_z and tr._ed<40) or tr.type==_2) break
if tr.type==_0 or tr.type==_1 or _gn.type==_z or _gn.type==_2 or _gn.type==_0 then
x+=1
else
x+=1
break
end
end
_gf._gj=x
x=_gf._gk
t=_b7[y][x]
tb=_b7[y+1][x]
if(tb.type!=_z and tb.type!=_2) _go(x,_9,_gf)
if(t.type==_0) _gr(x,_8,_gf)
for x=_gf._gi,_gf._gk-1 do
t=_b7[y][x]
tb=_b7[y+1][x]
if(tb.type!=_z and tb.type!=_2) _go(x,_ac,_gf)
if(t.type==_0)	_gr(x,_ac,_gf)
end
for x=_gf._gj,_gf._gk+1,-1 do
t=_b7[y][x]
tb=_b7[y+1][x]
if(tb.type!=_z and tb.type!=_2) _go(x,_ad,_gf)
if(t.type==_0)	_gr(x,_ad,_gf)
end
return _gf._gh
end
function _go(x,_gp,_gf)
local t,tb,tl,_gm,tr,_gn
local px,py=_br._cu,_br._cv
local y=_gf._gl
while true do
t=_b7[y][x]
tb=_b7[y+1][x]
if(tb.type==_z or tb.type==_2) break
tl=_b7[y][x-1]
_gm=_b7[y+1][x-1]
tr=_b7[y][x+1]
_gn=_b7[y+1][x+1]
if t.type!=_y then
if x>0 then
if _gm.type==_z or _gm.type==_0 or _gm.type==_2 or tl.type==_1 then
if y>=py then
break
end
end
end
if x<_c then
if _gn.type==_z or _gn.type==_0 or _gn.type==_2 or	tr.type==_1 then
if y>=py then
break
end
end
end
end
y+=1
end
local _gq
if y==py then
_gq=abs(_gf._gk-x)
elseif y>py then
_gq=y-py+200
else
_gq=py-y+100
end
_gs(_gf,_gq,_gp)
end
function _gr(x,_gp,_gf)
local t,tb,tl,tr,_gm,_gn
local px,py=_br._cu,_br._cv
local y=_gf._gl
while true do
t=_b7[y][x]
if(t.type!=_0) break
y-=1
t=_b7[y][x]
tb=_b7[y+1][x]
tl=_b7[y][x-1]
_gm=_b7[y+1][x-1]
tr=_b7[y][x+1]
_gn=_b7[y+1][x+1]
if x>0 then
if _gm.type==_z or _gm.type==_2 or _gm.type==_0 or tl.type==_1 then
if y<=py then
break
end
end
end
if x<_c then
if _gn.type==_z or _gn.type==_2 or _gn.type==_0 or tr.type==_1 then
if y<=py then
break
end
end
end
end
local _gq
if y==py then
_gq=abs(_gf._gk-x)
elseif y>py then
_gq=y-py+200
else
_gq=py-y+100
end
_gs(_gf,_gq,_gp)
end
function _gs(_gf,_gq,_gp)
if _gq<_gf._gg then
_gf._gg=_gq
_gf._gh=_gp
end
end
function _gt(s,_gu)
local t=_b7[s._cv][s._cu]
if _gu then
s._c6=0
else
s._c6-=1
end
if s._c6==0 then
if t.type==_y then
t.type=_3
_eo(t.x,t.y)
else
if _gu then
_bx-=1
_cs()
else
s._c6+=1
end
end
end
end
_gv={
_ba=false,_fm=function(self)
local s=self
s._ba=true
s._em=0
s.py=128
s._c1=0
s._c2=_ag
s._c3=0
s._cz=0.5
s._gw=(_bp%#_fu==0)
music(-1)
sfx(_au)
_fk:_fm()
local _gx=_eu(s._gw,"well done{","level complete")
_fp:_fm(_gx,0,48)
end,_fn=function(self)
local s=self
if s._gw then
srand(1)
for z=5,1,-0.015 do
local t=time()
local c=({8,9,5,2})[z-z%1]
local u=(rnd(140)+cos(t/2+z*9)*(8/z)+t*(20+rnd(20))/z)%140
local v=(rnd(140)+t*(40/z))%140
local s=max(1,3/z)
local q=sin(t*rnd(1)+z)*0.7
if(c==8) c=({10,14,15,7,3,4})[1+flr(rnd(6))]
for i=1,s do
line(u,v+i,u+s,v-q*s+i,c)
end
end
end
for i=0,8 do
if(i!=4) spr(2,37+i*6,100)
spr(3,61,100+i*6)
end
pal(4,14)
pal(15,12)
spr(s._c1,60,s.py)
pal(4,4)
pal(15,15)
local _gy=_bz\60
local _gz=flr(_bz-60*_gy)
_ew(_gy..":" .._e2(_gz,2),30,11,true,1)
end,_fo=function(self)
local s=self
if s.py>92 then
s.py-=0.5
_et(s)
else
s._c1=112
end
s._em+=1
if(btn(5) and s._em>60 and not s._gw) s._em=1000
if(s._gw and s._em==120) music(_a0)
if s._em>=_eu(s._gw,540,300) then
s._ba=false
_fp._ba=false
end
end
}
_g0={
_fm=function(self)
local s=self
s._em=0
s._g1={
_fq={"avoid the guards, collect","gold and then climb to the","top of the screen","","use Ž and — to dig holes","hold — if you are trapped","q to quit back to titles","","lemming sprites mike dailly","confetti tweetcart by zep","","2021 paul hammond (@paulhamx)","testing by finn","","based on the 1983 game","by doug smith" },_g2=1,_g3=0,_g4=0,_g5=0,}
s._g6={}
for y=0,21 do
for x=0,21 do
add(s._g6,{x=x*6,y=y*6,dy=rnd(2)})
end
end
sfx(_ar)
end,_fn=function(self)
local s=self
if s._em>120 then
spr(11,48,22,4,1)
_ew(sub("featuring lemmings",1,s._em-120),33,15,true,1)
end
_bl(min(12,-40+s._em/2))
if s._em>200 then
local tt=s._g1
clip(8,45,127,100)
camera(-8,-tt._g5)
local y,x=86,0
local _fq=sub(tt._fq[tt._g2],1,tt._g3)
for i=1,#_fq do
if ord(sub(_fq,i,i))>130 then
x+=6
else
x+=4
end
end
_ey(_fq,0,y,11,1)
if(_a6) rectfill(x+1,y,x+4,y+4,11)
for i=tt._g2-1,1,-1 do
local c=11
y-=8
if(y<40) c=6
_ey(tt._fq[i],0,y,c,1)
end
tt._g5=max(0,tt._g5-0.5)
clip()
camera()
end
if s._em>120 then
if(_a3 and _a3>0) _ez(_e2(_a3,5).."0",40,0,6)
if(_a6) _ew("— start",116,11,true,1)
end
for b in all(s._g6) do
spr(2,b.x,b.y)
end
end,_fo=function(self)
local s=self
if s._em>60 then
for b in all(s._g6) do
b.y=min(129,b.y+b.dy)
b.dy+=0.15
end
end
s._em+=1
if s._em>200 then
local tt=s._g1
if tt._g4>0 then
tt._g4-=1
else
local _fq=tt._fq[tt._g2]
tt._g3+=1
tt._g4=2
if tt._g3>#_fq then
if tt._g2<#tt._fq then
tt._g2+=1
tt._g3=0
tt._g4=_eu(tt._fq[tt._g2]=="",40,20)
tt._g5+=8
else
tt._g3-=1
end
end
end
end
if s._em==60 then
sfx(_an)
elseif s._em==120 then
music(_ax)
end
end
}
__gfx__
00000000001122337d333300eaaaae00eeeeee0022222200bbbbbb00000000000000000000000000000000000011110111100111001111000001111000000000
00000000001122337d333300e0000e00e0000e0022222200000000007d3333000000000000000000000000000133331333311333113333100013333100000000
0070070044556677dddddd00eaaaae00eeeeee002222220000000000dddddd00d0000d0000000000000000001331331133113311133133111013113100000000
00077000445566773337d300e0000e00e0000e0022222200000000003337d3003337d30000000000000000001333331133113310133133133133333100000000
000770008899aabb3337d300eaaaae00eeeeee0022222200000000003337d3003337d3003337d300000000001331110133113311133133111133113100000000
007007008899aabbdddddd00e0000e00e0000e002222220000000000dddddd00dddddd00dddddd00000000001331001333313333133331000133333100000000
00000000ccddeeff0000000000000000000000000000000000000000000000000000000000000000000000000110000111101111011110000011111000000000
00000000ccddeeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777000007700000000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77cc77000777700000c7000007777000000b0000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c77b70007cb700000c7000007bc700000bb0000000bb000bbbbbbb000bbb000bbbbbb00bbbbbb00bbb00bb0bbbbbbb00bbbbbb0bbbbbbb0bbbbbbb00bbbbb00
7c77b70007cb700000c7000007bc70000bbbbb000bbbbb0000000bb000bbb0000000bbb00000bbb0bbb00bb0bbb00000bbb0000000000bb0bbb00bb0bb00bbb0
77bb77000777700000c7000007777000bbbbbb000bbbbbb0bb000bb000bbb000bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb00000bb00bbbbbbb0bbbbbbb0
077770000077000000c70000007700000bbbbb000bbbbb00bb000bb000bbb000bbb000000000bbb000000bb000000bb0bbb00bb0000bb000bbb00bb00000bbb0
0000000000000000000000000000000000bb0000000bb000bbbbbbb000bbb000bbbbbbb0bbbbbb0000000bb0bbbbbb000bbbbb00000bb000bbbbbbb0bbbbbb00
00000000000000000000000000000000000b0000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000b0bb0000000000000000000000
bbbbbbb000000000bbbbbbb0bbbbbb00bbbbbbb0bbbbbbb0bbbbbbb0bbb00bb000bbb00000000000bbb00bb0bbb00000bb000bb0bbb00bb0bbbbbbb0bbbbbb00
00000bb0000000000000000000000bb00000000000000000bbb00000bbb00bb000bbb00000000000bbb0bb00bbb00000bbb0bbb0bbbb0bb000000bb000000bb0
bbbbbbb000000000bbb00000bbb00bb0bbbbbbb0bbbbbbb0bbb00bb0bbbbbbb000bbb00000000000bbbbb000bbb00000bbbbbbb0bbbbbbb0bb000bb0bbbbbb00
bbb00bb000000000bbb00000bbb00bb0bbb00000bbb00000bbb00bb0bbb00bb000bbb00000000000bbb0bb00bbb00000bb0b0bb0bbb0bbb0bb000bb0bbb00000
bbb00bb000000000bbbbbbb0bbbbbb00bbbbbbb0bbb00000bbbbbbb0bbb00bb000bbb00000000000bbb00bb0bbbbbbb0bb000bb0bbb00bb0bbbbbbb0bbb00000
00000000000000000000000000000000000000000000000000000000bbb000000000000000000000000000000000000000000000000000b00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbb00000bbbbbbbbbbbb0bbb00bb0bbb0bbb0bb000bb0bbb00bb0bbb00bb000000000000bb000aa0aa000beeee000000000000000000000000000
0000000000000bb000bbbb0000000000bbb00bb0bbb0bbb0bb000bb0bbb00bb0bbb00bb000000000000bb000aaaaa000beeee000000000000000000000000000
00000000bbbbbb0000bbbb0000bbb000bbb00bb0bbb0bbb0bb0b0bb00bbbbb0000bbb00000000000000bb000aaaaa000beeee00000bbb0000000000000000000
00000000bbb00bb000bbbb0000bbb000bbb00bb00bbbbb00bbbbbbb0bbb00bb000bbb00000000000000000000aaa0000b0000000000000000000000000000000
00000000bbb00bb0bbbbb00000bbb000bbbbbbb000bbb000bbb0bbb0bbb00bb000bbb00000000000000bb00000a00000b0000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400000444000040400000044000004444000004440000404000000440000004400000404000000440000040400000004000000440000004400000000000
0044b0000044b000004440000044b0000044b0000044b000004440000044b0000044b0000044b0000044b0000044b000000444000004400000b4400000000000
000bbb00000bbb000004b000004bbb00004bbb00000bbb000004b000004bbb00004bbb00000bbb00004bbb00004bbb0000044400000ff00000fffb0000000000
000bf000000bf000000bbb00000bf000000bf000000bf000000bbb00000bf0000b0ff0b0000ff000000ff000000ff00000bffb0000bffb00000fff0000000000
000bf00000bff00000bbf00000bbf000000bf000000fb000000fb000000bf00000bffb000bbffbb000bffb000bbffbb000bfff00000fff0000fff00000000000
000ff00000bff0b000bff00000bff000000fb000000fb0b0000ffb00000fb000000ff000000ff0000b0ff0b0000ff00000f0ff00000ffb0000bff00000000000
00bff00000ff0b0000ffff000bffff0000bff00000ff0b0000ffff000bffff000b0ff000000ff0b00b0ff0000b0ff0b000b00f0000f0000000000f0000000000
000bb00000bb00000bb00bb00b00bb00000bb00000bb00000bb00bb00b00bb0000b00bb00bb00b0000b00bb000b00b0000000b0000b0000000000b0000000000
00000000000000000b000b000b000b000b0000b00b0000b0b00000b0b00000b0b00000b0b0000b00000440000004400000000000000000000000000000000000
0000000000000000bf00b000bf00b000bf000b00bf000b00bf000b00bf000b00bf000b00bf00b0000044b000000b440000000000000000000000000000000000
0000000000000000fffbf000fffbf000ffffb000ffffb000ffffb000ffffb000ffffb000fffbf0000b4bbb0000bbb4b000000000000000000000000000000000
00000000000000000fffbbb00fffbbb00fffbbb00ffff0000ffff0000ffff0000ffff0000ff4bbb000bff0b00b0ffb0000000000000000000000000000000000
000000000000000000f44b0000444b000044bb000044bbb000ff000000ff000000ffbbb00f44bb00000ffb0000bff00000000000000000000000000000000000
00000000000000000004440000044400000444000044bb00044bbb00004bbb000004bb0000444400000ff000000ff00000000000000000000000000000000000
000000000000000000000000000000000000000000044400044bb000044bb00004444400004400000b0ff000000ff0b000000000000000000000000000000000
0000000000000000000000000000000000000000000000000044400004444000004400000000000000b00bb00bb00b0000000000000000000000000000000000
0bb0440000000bb000044000000440000000000000000000000440000004400000000bb00000bbb00000b0000000b0000000b00000b44b000000000000000000
bb044b00000044bb00444b0000444400000440000044400000444b0000444bb0000044bb000b0b4b004bb400004bb400b04bb40b0b4bb4b00000000000000000
bbb4bbb000044bbb0044b0000044bb000044440000444b000044b0000044b0bb00044bbb00004bbb004bb400004bb4000b4bf4b00b4bb4b000b44b0000000000
b0bbbf000000fb0b00ffbb0b00fb00000004bb000044b00000ffbb0b00ffbbbb0000fb0b00004bf000bffb00bbbffbbb00bffb0000bffb000b4bb4b000000000
0000ff000000ff000fff0bbb00fbb00000fff0000ffbb0000fff0bbb0fff000b0000ff000000fff00b0ff0b0000ff000000ff000000ff0000b4bb4b000b44b00
000fff00000ff0000fff00bb0fffb0b00fffbb0b0fffbbbb0fff00bb0fff00b0000ff000000ffff0000ff000000ff000000ff00000ffff0000bffb000b4bb4b0
00ff0f0000fff0000ff00bb00fbbbbb00ffffbbb0fff0bb00ff00bb00ff0000000fff00000ffff00000ff000000ff000000ff000000ff00000ffff000b4ff4b0
0bb00bb00bb0bb000bbb00000bb0bb000bbbbbb00bbbbb000bbb00000bbbb0000bb0bb000bb00bb000bbbb0000bbbb0000bbbb0000bbbb000bbffbb0bbffffbb
0000b000004444000004400000044000bbb00000000000000000000000000000000000000000000000000000b0000000b0000000000000000000000000000000
004bb4000044b000004bb4000044bb00bbb00000000000000000000000000000000000000000000000000000bb000000bb000000000000000000000000000000
004bb400000bbb00004bb400000bb000bbb00000bbbbbbb0bbbbbb00bbbbbbb000000000bbbbbb00bbb00bb0bbb00bb0bbb00bb0bbbbbbb0bbbbbb0000000000
00bffb00000bf00000bffb0000bffb00bbb0000000000bb000000bb0000000000000000000000bb0bbb00bb0bbbb0bb0bbbb0bb00000000000000bb000000000
0b0ff0b0000bf0000b0ff0b00b0ff0b0bbb00000bb000bb0bbb00bb0bbbbbbb000000000bbbbbb00bbb00bb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbb0000000000
000ff000000ff000000ff000000ff000bbb00000bb000bb0bbb00bb0bbb0000000000000bbb00bb0bbb00bb0bbb0bbb0bbb0bbb0bbb00000bbb00bb000000000
000ff00000bff000000ff000000ff000bbbbbbb0bbbbbbb0bbbbbb00bbbbbbb000000000bbb00bb0bbbbbbb0bbb00bb0bbb00bb0bbbbbbb0bbb00bb000000000
00bbbb00000bb00000bbbb0000bbbb0000000000000000000000000000000000000000000000000000000000000000b0000000b0000000000000000000000000
c7861212323286464646c7861212323286020202040204020402040204c7860202620203e502020286020202328732873287323232c786123232861232328636
0287323232c78612323286020202163286168687323232c78612323286323242020232323286168687323232c786123232861642020232860203020286873232
32c7e50202028612020286168687323232c73642024202028612323286168687323232c712121286024242028687323232c7e5e5e5e502020237c703c7e5e5e5
02020203d2424242d237c7020242d242d2e5e502020286423232324286c742863202320242d2e5e54286163286c732863632e5360242023286323242323286c7
0286e542d2e502023286d286163286c70286e532e5024202d2860202423232324202c70286e5e502023286e536c70286e5020242e58636424242420202c70286
e50202320202024202d28602020242164202c70286e5e53286360216868702c70286e502020242d2020286360232323286873202c70286e5020202320242d286
360232328687323202c70286e53642320286360232868732323202c70286020262e50232020286020302020286871602c73637e5e5e53602c73637e5e5020203
e50202c73637e5e58616328636c702428616863286033642028632020202328636c73286163286163286323286128632323286c7328636048602420202048602
04860202043202328602024286c732860232323204860204320204860204860242043202328602323286c7328602423232048602020242048602048602320232
02328602323286c732860232323204860232023204860204860204040202328602323286c7328602020242048602040202028642328602323242023286030242
86c73286163286163286873286128632323286c7428646d2d2d202424202860202030232323602044286c7040404863632320404043232860404324236024204
86c702020286323232423226043286260404862686c762020286324232324242424242420286423602863686c72604041626040404121632c737e5e5e5e50202
02c737e546464646d2d2323232c786364203e502020286e53632c78632328716e5020286e53632c786e532e50202860242038602323202420232c78602420286
0202320242020202d2d2d286323232861232c7863232328642021632024202028602020286e502c736861216878602020286e542c78602020286323202024202
1687860242328646d23232c78632323286121687863232328602420286023232c7863602324646d2863242328687323286023232c78642038602023236024202
0202863232328602020286023232c73232328602023202020242023232020286323232860202028602d6c7020202860202320242023232368632323286020202
86023232c702020286026216364202863232328602020386023232c732c702c7e5373737373737376237e502373602c736033637363737360237370304020202
c702024286423637360237370202023737020404040202c702428686864202020237e5373702373702260402c742868686868642020237e50237373702260404
04c786868686868686d2d237020242030242020237468686860202c7020202863612123686020202c70202420442020202320242e54202323686020202c70242
0404044202023202464602323686020202c70226040202320286e58602323686020202c70202040404020202320286e58602323686020202c786163286023242
860202020302028642323686020202c7863602860212123686020202c786360286020286e5020286360286020202c7861632868612128686163286c7360237e5
e5e536c7360237e536022626040404c72604372604864686e53604c7043637360286026202028602020203e504c716328612121216c732328602028602028632
32323616e53232c7328686163286323232023232021212c73286120286323202423202323232023232020232320232c732863202323232023286323202323202
323232024232323202420232c732863232024202323286323236323232023232024232320232c732861232861232323287123232c73286020232023242028686
e5e50202038632c732861232028612323286128632c73286024232323202020286e5323286e58632c73286e50302860202024202023232860202024202028632
c732c7e50202024202020242e5e50202c702420202024202020232328632320202024202020242364202c7023232863232360286360232328632320202023286
32c702020286e586e5020286e58602c73686e586e502028636860202c702020286e5020386020202424202020286368602c7020286e502028636323202028602
460286c733c73686e5860246d2d2028636866202c7020202860246d2020386e5020286363232c7020286020202424202020286e5020286e502c7020202860202
3232020286e5020286e50202c70202030286e586e502028602033602c71632878787878787878787878787878787123286c7e5e5e5e502020286c732c7121232
3232e5e537c732e5e50232e5e537c73202464646868612324202020237c732e5e50286320202420202320232d2d2d286c73242024203e5620202863236023202
3203020286c73286128626040432040402020286020232320286c7328636023286e532323202020286360286c732864236328646d2d2d2020202030232863686
c7328602020232320486e51232860202028632c732860202323242048636323232360232861632c7328602023202020486020242323242320242420202328632
32023232c73286323202020204860202323202021232863202320232c73286324202020204860232320202023246d232863232023232c7328636028686863236
32020242020232863242320232c732863602863286e5360232863232023232c732c70246e54242424242424236024602c786361212123686c786020404041212
120404040286c713c786030486021212120286040386c704040486023236323632363232320286040404c7020202860232424242423242424242324242424232
32d6c702020286021212120286020202c773c773c702020286023232323632363236320286020202c702020286023232324242424232424242423242424242d6
c773c773c773c702020286e5e5e5026286020202c732e5e5e5e5023237c732e5420202030202024646d2d2d2423237c7121232868636030242020286323237c7
16e502020286861216320237c7163202024202020302028686e502023232020237c7121232868602024236323232860237c71232e586861232320202860237c7
02020242020232320202420202868636023232328732860237c7861212868602420202323236860237c786323202320216020202868616320242020202860237
c786020286328632024232320202868602021632873232860237c704040486028632861662868602323202423602860237c72604860286320232323286861632
8716860237c726040404868686320232868632e5020202860237c7e5020202860286028686e536860237c732c7e5e5e502020237e5c73603e536020436370202
02030242c786260402260404048604040202023237328616c786e502d2d2d20202028604423232863237328616c7323286323202323202028632030286023232
32863237328632324232c702028602023232423202860232028632320202863237328616c786320202021687860202328602028632323237328636c786366236
860202023202028632020237021686c7861232320232024232020242863286123286c78612323287320232020216863232360286c78612323287323602423232
86020212c7863232420202023232873246863202328646d2d20202c786323202020242323287328602020232020232423632023286c786123232873286020212
3286323232423286c7860202023232423686023232e586020232323286c7861216861216323686c7e54646d2d2d242e536c72604040202023232360232260404
3286020202c70446d2d202024242360232e53286020202c70486e53232328736320203020202423286020202c70486424236420202423612873286020202c726
8602420232873232e536038686020202c73686e502420202024202020203d2d20286020202c7368636023226260432d2d20286020202c7368642030242023203
36024202023202020286020202c73686168612871602020286020202c736023202023286e5e5020286020202c71303c736023242423286e5e5020286020202c7
36023232873286e5e5020286020202c7e5020202863603020262e586020202c732323226043232322632323226323232040404c737e5e5e5e5020202c703c726
04040486e5e50202028626c7e5028602020203e502020203028636c7e50286123204040416328636c70202023202020286e5e50202028636c70202320202d2d2
86e5e50202028636c702023202420242863642324236024242428636c70202320232423286d2d20202320232024242420232323286d2d2d6c702320202324232
86420242d2d24232023232320232423286420242d2c70232020232323286324232024232420242424202323232863242d6c70232363286423242023232320232
3232023242328642324202c73236023286324232e50202023232328632423202c7e50286d286e5e50286d2860202c7e502863662e5368636c732323204040412
3232322612323232c726262602370226262604c7044646863204d237d20432864646d204c704e542028632d2d237d2d232860242e50204c70402020242020232
3286d2d2423742d2d28632320202423604c704020242323287d28686320432373204328686d232873202d6c70402423232d2d286d23287d2863786d28732d286
d2d232d6c732423232d2d28646d286378646d286d2d2d232324204c73287d2d2d28646d2d286378646d2d286468732c732d2d2d2860346d2d286378646d2d203
864632c7320202028612878662868712863632c73202420286e502323232e502860202420232c786020202863603020232423202020336863686c786d2d2d286
3287163286028616328732864686c7860242020286e5860286e586020242020286c786368602024202020286028602024202020286360286c712323232041232
041226c7024642e5e536420242623237c736023286e5e5020286163237c736023286e5e5028687163237c736023286e5e5863287323202023237c736023286e5
360286323287323242023237c702420203023286e5368632423287323287873237c71602023286e50202863202863287323202023237c7420202023242023286
42360286320242863287323202023237c732323286023202023232860202028616863287323202023237c7420202328602324202328642038632024202428632
87323202023237c73232860232860232020232328612863287323202023237c7420232860232860232420232860242024202d2863287323202023237c7328602
32860232860232023286163202863287323287873237c7023286023286023286e536863287323202020237c70202860202860202863602033686e50237c732c7
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
23234023682121232368234061237c682d2d2d2368236464642368235e7c6820242320682023245e202024232068202363207c682423202468242023245e2423202068202023637c682320242368232420232420206823232320202068202020232024207c682024232368242368682340682340232020302068202024202323
237c212323236820206820242121237c242424642424242024242464642d2d2d2424247c23232363232323682323235e63202323237c317c232323632323236823232363242424632323237c232323632323236823232363232323632323237c347c347c347c347c232323242d2d2423232368232323242d2d246d7c61242461
6861242461232424617c216168212161237c202123232068202123202123207c20202120206820206123202020612320207c20202030632026685e63305e7c237c23732121212123237c237364646464646420237c237323404040234040402340404023404023406823402d2d2d2368237c2373236324632420202024202068
20202024682368237c237324686262626262684068237c237323682364646464402024682368237c237324682320626262626168237c237323682320402024242424242424242424242420202024232468237c237324682320402323236240402362406823232368237c23732368236320305e63206824232468237c23732468
2362624040402323626823204068237c23732368646464642d2d2020682368237c237323404023234040684040234023404068624040682468237c237320306320682040406368202030202024682368237c234040402340232323626840402340234040232340402368237c20265e6320685e5e68237c212121232323632073
237c23202623232d2d2d204040202020245e632073237c23202340202024206840402168682068236820682073237c232023632068634040232068682468206820682073237c232023686140232324202020232068682068206823682073237c23202368235e40232320202068682068206820682073237c2324206823202020
24202023402320682320682068206820682073237c232368682323782340232323402320682324237323236823682073237c2323685e306320682378237323206820682073237c23236823234021234068686820237323206820682073237c23236820234021234068682020237323206820683068237c232068202040202024
634068202020237323686823232368237c23206868234021234068202420237323683020202068237c23202368234021234068404040237361202068237c232023682363202420204040232020207320202023202068237c232024682023626240232030207320202061237c2020202d2d20245e2020202d24632463207c2020
68202023235e2020682023232020202323682020207c2020685e202024302020685e2020682020247c2024682d2d5e23232024682020302463686823237c232368202068243063202323682020232320202024206820207c20202024206823235e20685e2323206820207c2020232320682d202d2d30242d2d2d685e20202068
20207c2020246368202023236324202020242d2020206824207c20232363685e20232320202323206824682323207c632d2024682020245e63206823232020207c202020682023236820202323202020245e6863207c202420686320246323232024636824637c682323686323235e2023232020206823232020207c685e5e5e
5e2020207c685e5e20265e5e207c237c5e5e202020642d5e20207c5e636468632030242020242020207c632064685e302024202123687c202d2d2d685e20202024206123202024202023687c685e2020202624206120202024302378236823687c682020782378202323206120202420237823232320236823687c6820202420
24202420202320202420232378232020242020236823687c682023232078237820202320612020202423232368236823687c682020242024202420202320232020242023782378202368236823687c682020232323207823202320232023237823202024202368236823687c6820202420242024202023202320232020242023
23682368236823687c682023782078232320202320232023206123682368236823687c682020242024202420202320232023202320202023682368236823687c682020232378207823202320232023202320242023682368236823687c685e2020302320232023206123682368236823687c2161235e63682068206820687c5e
63735e5e63207c307c202420302024202020406840202020646420262020207c6840232323404023204068245e636120207c68405e2040684063245e63247c6840642020204068402020612d2d2d5e687c68405e244068402020245e202020242020687c6820202440232323404068402323235e686120687c68402340406340
68405e302420682363687c6840642d2d2d24684020202021232363687c684063242020406840202020245e2020242020687c6840202020402323234068402d2d612d2d20206823232020687c6840245e4068405e202024206863687c6840232363204068405e612363687c68632030202020685e5e63687c4023232340616223
23234061404023234040407c232373617361237361237361237323237c232073243020207363207320202024207320242020207320237c2368212323786178216168237c236823245e2030245e2020242020202368237c2368612378212323782123682368237c2368232020245e63245e23682368237c236823686178617861
237823236823682368237c23682368235e5e63236823682368237c236823682368232463203063202420236823682368237c236823682368232323782323782323237861236823682368237c236823682368202020245e2020242020206823682368237c2368236823232378212178232323682368237c23682368202020245e
202020245e682368237c23682323237861786178217823232368237c236820202030202020246326632024202030202068237c237c5e5e5e305e2020207c21212121232323737c2420306320235e202420202320246320737c23232368232023682368212323202368232023236823237c232323682368236823682320202420
20202320236823202323686d7c232323682368232023682320612023202368232020206820687c232423682368236823682368232620232023202368232061687c232020682368236823682368232320232023202368232023682020687c206823682368236823682368202024232023202368232023682323237c6823232320
6823682368212023202368232023682020687c682323202368236823682024632023202368202d61687c6820202d236823682161202368232023682020687c68232320236823685e63202368232023682323237c2d2d232023682121232368232023682020687c6320685e305e2068232061687c212121612030202020687c40
735e5e5e5e73407c4073202030242424242424242420246d7c626262407362626240407c5e242024637363202420202463207c634068622020207320202040686240637c632068242024637363682420202463207c202020624040684020207320206240404068402020207c5e242024682020207363202420202468637c2020
40686262207320406862624020207c202020682020242024637320206820202420202463207c206262404068407362624040406840207c5e242020242068207363242020202420206820207c204068626240407362626240207c2020685e5e5e5e207c202068202020242020245e2620242020202463307c237c5e5e5e202123
20207c64642d2d245e3073202120207c685e202068236864202020732021687c685e2068782378682024682420202073202323202023687c68642d2d2d68782378682023232368202020732023242023687c685e2068782378683023232368637320232323687c68305e68686868682023232368632073202323687c23642d20
20407868784020232323685e732023687c2323242020682020407868784063685e207373687c2323232420682020407868784020682d2d6864642d687c6124682020407868784020685e5e207c612368302040786878402068642d2d682323242323237c63206820204078687840206863206840217c63206820204078687840
206863684021237c63206820202026682020206863684021237c237c2123686864642d2d686821237c2168682020202d632d2020206868217c612368686320233030236320686861237c616868632d2061202d636868617c2323236868632d2021202d6368682323237c23236868642d2021232320642d686823237c23686863
2d2061242461202d636868237c68685e21215e68687c367c23236868632d20212323202d63686823237c347c337c61236868632d632d63686861237c2168685e5e6868217c2123686830202020266330686821237c237c735e5e5e5e2020207c7363232020203020235e203020202030637c73642d2d24682368202323682323
73732373732323682020207c685e2368202368232068232024232024232020682020207c682026632023202023206823206823202023202020682020207c612363232320682320202320202363682020207c63232020202423206823202423202023202d2d2d20682020207c202020236323206868682023632320206123687c
2024232020202423202023686823202023232020785e687c232363232024232068232020232020232020236320687c232020202423202023206823202023632320202324202020687c632320242320682320242320206823202023242023202020687c202024232020232068232020232020206820232020232020232020687c
202023202423206823202023636820202324202320202320687c202320202320686863202420206820202023632023687c5e682121212020687c626262626240407363407c405e202020305e63207363407c4063682340232340402368405e207363407c4063685e736840234023234040237363407c40202323406863206873
68232023203023642d2d2d407c40242020206820202024736873232320232040235e24407c40636820202068736873232020232020235e30407c40682020206820202068736873232024232620235e23407c406820202068202020687340232320202323202363202423407c406862782340407340632023202363202323407c
406820646440642d23202320202420202023407c406863202420206863202323202363232323407c406820206840784040406840404023682320202320202024232020407c406820206840202020406840202023686178234023202420407c406820206840202020406840242023685e2020232340407c406820246840203020
406840612340402323234061407c6820302023235e636464647c6861235e202323685e5e7c6861235e202323682023402340234023402340237c6861235e202323682024202420242024202420247c6823232423235e202323682378237823782378237823787c68612320242020302020232368237823782378237823782378
__sfx__
010100003b67137761335512e6412b73129531276312673126621267212753127631287212b5212c6112e7112d6312971125511206111d71117511126110c7110761103721005110061100711005010060100701
0102000024752187420c73224722287521c74210732287222b7521f742137322b7222e75222742167322e7221f7021d7021c7021a702187020070200702007020070200702007020070200702007020070200702
010600003535532335353453232535335323250030500305357003270035700327003570032700003000030000305003050030500305003050030500305003050030500305003050030500305003050030500305
010500001013204122103350431200000001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
010400001d05725057290572c05730047330473304732047310372f0372c03726037210271c02718017140171d0071d0071e0071f0072100723007260072b0072f0073100733007340073400733007300072f007
010500002d0532a05326053220531a05315053130531205312053120531305315053190531b0431e0432104323043230331e033130230a0130300300003000030000300003000030000300003000030000300003
000200001f1201b120151300f140091500715005160041600515006150081500a1400c1400d1300a1200712005120031200112000120001200212000120021300b1400c150031501b10019100001001510011100
01040000147551675518755197551b7551d7551f7552175525755287552b7552f75532755367553a7553c7552b7553074533745347452c7252f72534725367252d725347153771537715347052d7050070500705
010100003c62510615000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
01010000356250461500005000001d500045000000000005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
01050000140571605718057190571b0571d0571f0572105725057280572b0572f05732057360573a0573c0572b0573004733047340472c0272f02734027360272d027340173701737017340072d0070000700007
010200003055500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
0110000028555285351f5451f5352154521535245452453528545285351f5451f5352154521535245452453528545285351f5451f5352154521535245452453528545285351f5451f53521545215352454524535
0110000028755287251d7451d7252174521725247452472528755287251d7451d7252174521725247452472528755287251d7451d7252074520725247452472528755287251d7451d72520745207252474524725
0110000018735187251c7351c7251f7351f72524735247251c7351c7251f7351f7252173521725247352472528745287452873528735287252872528715287152871528715187051870518705187051870518705
011000002870528755287351f7451f7352174521735247452473528745287351f7451f7352174521735247452473528745287351f7451f7352174521735247452473528745287351f7451f735217452173524745
011000002870528755287251d7451d7252174521725247452472528755287251d7451d7252174521725247452472528755287251d7451d7252074520725247452472528755287251d7451d725207452072524745
011000001870518735187251c7351c7251f7351f72524735247251c7351c7251f7351f72521735217252473524725287452874528735287352872528725287152871528715287151870518705187051870518705
010a00000c4500c4500c4500c450004500045000450004500c4010c4010c4010c401184011840118401184010540105401074010740109401094010a4010a4010c4010c4010a4010a40109401094010740107401
010a00000c5500c5300c5200c510185501853018520185100a5500a5300a5200a5100c5500c5300c5200c510055500553005520055100c5500c5300c5200c5100e5500e5300e5200e5101c5501c5301c5201c510
010f000000075000550003500025000750005500035000250a0750a0550a0350a0250a0750a0550a0350a02509075090550903509025090750905509035090250507505055050350502505075050550503505025
010f0000000750007500065000650005500055000450004500035000350002500025000150001500005000051f0050b0051f0050b0051d0050b0051b0050c0051d0050c0051b0051b0051b0051a0051a00500005
010f00000c5700c5600c5520c5420c5320c5220c5700c5350e5700e5420e5250f5700f5420f5250c5720c53513570135601355213542135321352213522135121157011542115250f5700f5420f5250e5700e535
010f00000c5700c5600c5620c5520c5420c5420c5320c5320c5220c5220c5120c5150000000000000000c5000e5020c5020c5020c5021b5020c5020f5020c5021b5020c5020e5020e50210502215022250222502
011000001857518575005030c5032453626526285162951624500265002850029500185461a5361c5261d5162757227535285722853228515105052156221515245622453224522245120c5550c5052656527561
0110000027542275351f5721f535215521f5721f5321f51521572215252457224525265722652524572245252757227552275332752326572265522653226525245722453224522245152c5722c5322c5222c525
01100000187751877518755187251b7701b7251c7621c7251877518715187751871515772157121b7751b7151c7751c715137751373215775157351877218752187321871520772207321b7721b7321d7721d732
011000001f7521f7521f7421f7421f7321f7321f7321f7221f7121f7121f7121f7151f7321f7221f7121f7151d7521d7521d7521d7521d7521d7421d7321d722207522075220752207521a7521a7521a7521a752
011000001875218752187521874218742187421873218732187321872218722187221871218712187121871211700117001d7001d7000c7000c70018700187001170011700137001370014700147001570015700
011000001805518055180551804518045180451803518035180351802518025180251801518015180151801518000180001800018000187001870018700187001870018700187001870018700187001870018700
010a000017750177301772217712187501873018722187121c7501c7301c7221c7121f7501f7301f7221f71217750177301772217712187501873018722187121c7501c7301c7221c7121f7501f7301f7221f712
010a00001075010730107221071211750117301172211712157501573015722157121875018730187221871210750107301072210712117501173011722117121575015730157221571218750187301872218712
010a00001075010730107221071211750117301172211712157501573015722157121875018730187221871210750107301072210712117501173011722117121475014730147221471218750187301872218712
010a00000e7500e7300e7220e7121175011730117221171215750157301572215712187501873018722187120e7500e7300e7220e712117501173011722117121575015730157221571218750187301872218712
010a00001775217752177521774217742177421773217732177321772217722177221375213752137521374213742137421373213732137321372213722137221371213712137121371213712137121371213712
010a000013512135121351213512135121351213512135121a5521a5521a5421a5421a5321a5321a5221a52218552185521854218542185321853218522185221755217552175421754217532175321752217522
010a00001555215552155521554215542155421553215532155321552215522155221155211552115521154211542115421153211532115321152211522115221151211512115121151211512115121151211512
010a00000e7500e7300e7220e7121175011730117221171214750147301472214712187501873018722187120e7500e7300e7220e712117501173011722117121475014730147221471218750187301872218712
010a00000b7500b7300b7220b7120c7500c7300c7220c7120f7500f7300f7220f712137501373013722137120b7500b7300b7220b7120c7500c7300c7220c7120f7500f7300f7220f71213750137301372213712
010a00000b7500b7300b7220b7120c7500c7300c7220c71210750107301072210712137501373013722137120b7500b7300b7220b7120c7500c7300c7220c7121075010730107221071213750137301372213712
010a00000e5420e5420e5320e5320e5220e5220e5120e512115411154211532115321152211522115121151215541155421553215532155221552215512155121854118542185321853218522185221851218512
010a00000e5420e5420e5320e5320e5220e5220e5120e512115411154211532115321152211522115121151214541145421453214532145221452214512145121854118542185321853218522185221851218512
010a00001555215552155521554215542155421553215532155321552215522155221d7521d7521d7521d7421d7421d7421d7321d7321d7321d7221d7221d7221d7121d7121d7121d7121d7121d7121d7121d712
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001f7501f7222175021722287502872224750247221d7501d7222175021722247502472226750267221d7501d72220750207222475024722267502672224750247221c7201c71218720187120c7100c712
011300001c7221c7221c7221c7221c7221c7221c7221c7221872218722187221872218722187221872218722207222072220722207221a7221a7221a7221a7220c7220c7220c7220c7220c7220c7220c7220c722
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002403523735210151f71523025217251f0151d715217151f7151d7151c7151f7151d7151c7151a7150c7350b73509715077150b7250972507715057150971507715057150471507715057150471502715
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600000c7320c7221073210722137321372215732157220e7320e7221173211722157321572218732187221073210722137321372217732177221a7321a7221173211722157321572218732187221c7321c722
011600002d7322d7322d7222d7222d7122d7122b7322b7322b7322b7322b7222b7222b7222b7222b7122b7122b7122b7122b7122b7122b7122b7122b7122b7122973229722297222971228732287222872228712
011600002473224732247322473224722247222472224722247122471224712247122471224712247122471224012240122401224012240122401224012240120070200702007020070200702007020070200702
011600002173221732217222172221712217121f7321f7321f7321f7321f7221f7221f7221f7221f7121f7121f7121f7121f7121f7121f7121f7121f7121f7121d7321d7221d7221d7121c7321d7221c7221c712
0116000018745187351872518725187351872518715187150c0250c0250c0150c0150c0150c0150c0150c01518705187051870518705187051870518705187051870518705187051870518705187051870518705
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0c 42 43 44
00 0d 10 43 44
00 0c 0f 18 44
00 0d 10 19 44
00 0c 0f 1a 44
00 0d 10 1b 44
00 0c 0f 1c 44
00 0d 10 43 44
04 1d 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 36 42 43 44
01 36 37 43 44
00 36 38 43 44
00 36 39 43 44
02 36 3a 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 14 16 43 44
04 15 17 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 1e 22 43 44
00 1e 23 43 44
00 1f 24 43 44
00 1f 42 43 44
00 1e 22 43 44
00 1e 23 43 44
00 1f 2a 43 44
00 20 32 43 44
00 21 28 43 44
00 25 29 43 44
00 27 32 43 44
00 26 42 43 44
00 21 28 43 44
00 25 29 43 44
00 27 32 43 44
02 26 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 2c 2d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
