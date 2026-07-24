pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
function a() b=1 c=1 d=0 e=f g=h i=0 j=3 k=0 for l=1,7 do m[l]=0 end n() for o=1,16 do for p=1,16 do mset(o-1,p-1,q[o][p]) end end r(b,c) end s,t=0 u=8 v=28 w=58 x=70 y=7 z=54 ba=11 bb=31 bc=17 bd=63 be=66 bf=96 bg=75 bh=0 bi=6 bj=7 bk=23 bl=31 bm=27 bn=33 bo=0 bp=1 bq=2 br=3 bs=4 bt=5 bu=7 bv=nil bw=0 bx={} by=false bz=0 ca=0 cb=0 cc=0 cd=0 ce={6,6,14,13} cf=1 cg=1 ch=nil ci=nil cj=0 ck=0 cl=0 cm=nil cn=nil co=""cp=0 cq=0 q={} function _init() poke(0x5f2c,3) for o=1,16 do add(q,{}) for p=1,16 do add(q[o],mget(o-1,p-1)) end end cr=false cs=false ct=0 cu={} cu.cv=0 cu.cw=1 cu.cx=3 cu.cy=4 cu.cz=5 cu.da=6 cu.db=7 cu.dc=8 cu.dd=9 cu.de=10 cu.df=11 dg={} dg.dh=0 dg.di=1 dg.dj=2 dg.dk=3 dg.dl=4 dg.dm=5 m={} dn=0 dp=48 dq=1 dr=0 ds={} dt=du(1,0,0) a() bx={"   alex in\n  pico world\n\ndomarius games\n\ncode/art/music:\n clint hobson","Ž(z) - punch\n—(x) - items\n”(up) - jump"} end function _update() if bv==nil
and#bx>0 then local dv=bx[1] dw(dv) del(bx,dv) end if bv~=nil then
if bw>0 then
bw-=1 elseif btnp(4) or btnp(5) then bv=nil end return end e() end function f() if btnp(5) then
ch=e e=dx g=dy end dz(dt) ea(ds) ea(eb) ea(ec) ea(ed) if d>0 then
ee() end for ef in all(ec) do local eg=ef.o local eh=ef.p+4 if not ef.ei then
eg+=4 else eg+=3 end if ej(eg,eh) then
ef.ek-=1 end end if el==dg.dj
and ca>63 then em() end if el==dg.dl then
if dt.o<bz then
dt.o=bz end if bz>63
and c<#en then em() end end if el==dg.dm then
local eo=flr(dt.o/64) local ep=flr(dt.p/64) if eo~=0
or ep~=0 then c+=eo c+=(ep*16) eq() dt.o-=eo*64 dt.p-=ep*64 cb=dt.o cc=dt.p if ep~=0 then
dt.o-=dt.er*2 end if ep<0 then
dt.p-=8 end end end if dt.cu==cu.da
and#es>0 then et=true en=es es={} eu(dg.dl) dt.p=0 dt.o=8 bz=0 ca=0 c=1 ev=bj ew() end end function ex() dz(dt) if dt.o>55 then
dt.o=55 end ea(ec) if dt.ey then
by=true end for l=1,#ez do local fa=ez[l] if by and fa.fb then
if fc(dt,fa) then
if k<fa.fd then
dw("you are short\nof money,\naren't you?") by=false else if not fe(fa.ff) then
fg(fa.ff) k-=fa.fd fa.fb=false dw("thank you.") end by=false end end end end return end function dx() if btnp(5) then
e=ch g=h end if btnp(1) then
dq+=1 end if btnp(0) then
dq-=1 end if dq>#m then
dq=1 end if dq<1 then
dq=#m end if btnp(4) and dr==0
and m[dq]~=0 then dr=dq sfx(27,3) sfx(26,2) end return end function dy() camera(0,0) rectfill(0,0,64,64,0) if cs then
spr(59,dn+(dq*8),dp-8-1) end for l=1,#m do spr(m[l],dn+(l*8),dp) end if btnp(4) then
local l=m[dq] end if dr>0 and cs then
rectfill(dn+(dr*8),dp,dn+(dr*8)+8,dp+8,0) end spr(bg,8,5) print("x "..j,21,8,7) spr(y,8,16) print("x "..k,21,17,7) print("score: "..i,8,26,7) return end function fh() bz=0 ca=0 camera(0,0) rectfill(0,0,64,64,fi) circfill(31,32,33,5) rectfill(0,32,64,56,5) rectfill(0,44,8,56,12) rectfill(8,22,54,40,12) map(0,7,0,56,8,1) spr(y,0,0) print(k,10,2,0) for l=1,#ez do local fa=ez[l] if fa.fb then
spr(fa.ff,fa.o,fa.p) print(fa.fd,fa.o-2,fa.p-8,0) end end spr(60,48,48) fj(dt) return end function h() if el==dg.dj then
if dt.p-32>ca then
ca=dt.p-32 end if c==#en and ca>63 then
ca=63 end end if el==dg.dl then
if dt.dc or dt.df then
bz=dt.o-8 else if dt.o-32>bz then
bz=dt.o-32 end end if c==#en and bz>63 then
bz=63 end end if el==dg.dm then
bz=0 ca=0 end if fk then
bz=0 end camera(bz,ca) rectfill(bz,ca,bz+128,ca+128,fi) for l=1,#fl do circfill(fl[l][2],56,fl[l][1],3) end for l=1,#fm do circfill(fm[l][2]+64,56,fm[l][1],3) end if et then
if ct==0 then
cf+=cg if cf==#ce then cg=-1 end
if cf==1 then cg=1 end
end pal(6,ce[cf]) map(0,0,0,0,16,16,0) pal() else map(0,0,0,0,16,16,0) end foreach(ec,fj) foreach(ed,fj) foreach(eb,fj) foreach(ds,fj) if dt.fn>0
and cr then fj(dt,1) else fj(dt) end if dt.de then
line(dt.o+3,dt.p-1,dt.o+4,dt.p-1,1) if cs then
line(dt.o,dt.p-2,dt.o+7,dt.p-2,1) else line(dt.o+3,dt.p-2,dt.o+4,dt.p-2,1) end end map(0,0,0,0,16,16,64) end function _draw() cr=not cr ct+=1 if ct>4 then
cs=not cs ct=0 end g() if bv~=nil then
local fo=bz+1 local fp=ca+8 rectfill(fo,fp,fo+60,fp+((#bv/14)+1)*8,1) print(bv,fo+2,fp+2,7) end end function fq(o,p) circfill(o-7,p,3,7) circfill(o+3,p,3,7) circfill(o-2,p+2,2,7) circfill(o-1,p-2,3,7) end function fj(fr,fs) if fs==nil then
fs=0 end if fr.fb==false then
return end if fr.ft>0 and cr then
fu(8) end if fr.spr<0 then
spr(abs(fr.spr),fr.o+fs,fr.p,fr.fv,fr.fw,fr.ei==false) else spr(fr.spr,fr.o+fs,fr.p,fr.fv,fr.fw,fr.ei) end pal() end function eu(fx) s=64 t=64 el=fx if el==dg.dl then
fy=8 fz=0 s=128 end if el==dg.dj then
fy=0 fz=8 t=128 end end function em() for p=0,7 do for o=0,7 do ga(o,p,mget(o+fy,p+fz)) end end local gb=fy*8 local gc=fz*8 bz-=gb ca-=gc dt.o-=gb dt.p-=gc cb-=gb cc-=gc gd(gb,gc,ec) gd(gb,gc,ed) gd(gb,gc,eb) gd(gb,gc,ds) c+=1 if ge then
fl={} for l in all(fm) do add(fl,l) end fm={} for l=0,2 do add(fm,{rnd(10)+5,l*21}) end end if c>#en then
return end gf(c,fy,fz) end function gd(gb,gc,gg) for fr in all(gg) do fr.o-=gb fr.p-=gc end end function gh(gi,gg) for fr in all(gg) do if fr.ff==gi then
del(gg,fr) end end end function gf(gj,gk,gl) local fx=0 if el==dg.dm then
fx=gj gm=fx else fx=en[gj] end if gn~=nil then
for o=0,7 do for p=0,7 do ga(o+gk,p+gl,gn[o][p]) end end return end local go=gp[gm] local gq=flr(fx%16) gr=flr(fx/16) gq*=8 gr*=8 for o=0,7 do for p=0,7 do local gi=mget(o+gq,p+gr) if gi==bg and gs[c]==true then
gi=0 end if el==dg.dm then
if(gi==7 or gi==4)
and go>0 then gi=0 go-=1 end end ga(o+gk,p+gl,gi) end end end function r(l,fx) n() dt.ft=0 dt.gt=true dt.o=8 dt.p=48 en={} es={} eu(dg.dl) ev=bh fi=12 gu=0 et=false ge=false gv=true ci=nil fk=false bz=0 ca=0 b=l c=fx local gw={bb,w,bg} local gx={200,100,500} gp={} for l=1,128 do add(gp,0) end gm=1 gs={} bx={"level "..l} if l==1 then
eu(dg.dj) en={0,16,32,48,64,47} es={1,2,3,4} ca=-32 dt.p=8 end if l==2 then
en={112,113,114,46,113,113,46,114,113,114,114,46,115,116} ge=true end if l==3 then
dt.p=8 et=true ev=bj en={96,97,98,99,100} end if l==4 then
en={49,50,51,52,53} end if l==5 then
en={11,12,11,12,11,12,11,12,8,7,8,9,8,63,7,9,8,63,8,7,11,9,11,47,15} es={54,55,56,57} gy(dt) ev=bl dt.p=0 end if l==6 then
gw[1]=bd en={33,34,35,36,35,37,35,38,39} end if l==7 then
fi=2 en={40,41,42,41,43,42,44,45} end if l==8 then
fi=5 en={58,59,60,59,61,60,59,61,60,59,61,62} end if l==9 then
en={47,7,8,7,8,9,8,63,7,9,8,63,8,7,9,7,8,9,47,10} es={80,81,82,83} dt.df=true dt.gz=ha dt.cu=cu.df dt.hb=nil ev=bk end if l==10 then
gw[1]=bd en={112,23,24,25,24,25,23,26} end if l==11 then
ev=bn eu(dg.dm) c=102 fi=5 gv=false dt.gt=false end if l==12 then
gw[1]=bg gx[1]=500 en={58,65,66,67,68} ge=true end if l==13 then
gy(dt) ev=bl en={17,18,19,20,18,20,19,18,21} end if l==14 then
en={84,85} dt.o=0 end if l==15 then
en={112,27,29,28,30,27,27,29,28,27,27,30,28,31} ge=true end if l==16 then
c=90 ev=bn eu(dg.dm) fi=5 gv=false end if l==17 then
bx={} e=hc g=hd he="the heroic\naction taken\nby alex kidd\nresulted in\nthe downfall\nof janken the\ngreat and a\nreturn of\npeace and\ntranquility to\n\"radaxian.\" in\na dazzling\ncoronation,\n\"igul,\" his\nelder brother,\nbecame the\nking of\n\"radaxian.\"\nthe citizens\nwho were\nturned into\nstone reverted\nback to human\nbeings through\nthe power of\nthe \"crown.\"\nalex was\noverjoyed that\nhe was able to\nuse his\nmartial art\nskills for the\ngood of the\ncitizens.\nsome doubt\nstill lingers\nin his mind as\nto whether or\nnot all of the\nsinister enemy\nforces were\nactually\ndestroyed.\nadded to this\nfear, is the\nuneasiness he\nfeels because\nof the fact\nthat the\nwhereabouts of\nhis father,\nking sander,\nis still\nunknown."hf=64 for l=3,14 do hg(l,32) end music(1) return end if l==18 then
bx={} dt.p=8 et=true ev=bj en={5,6} end if l==19 then
bx={} en={69,101,117} b=3 end fl={} fm={} ew() ez=hh(gw,gx) end function eq() ds={} ec={} ed={} eb={} cb=dt.o cc=dt.p gf(c,0,0) if el~=dg.dm then
c+=1 gf(c,fy,fz) end end function ew() eq() music(ev) end function gy(fr) fr.hb=nil fr.de=true fr.gz=hi fr.hj=0.1 fr.hk=1 fr.hl=0.5 music(bl) end function hm(gi,o,p,gg) local fr={} fr.hn=false if gg~=nil then
add(gg,fr) end fr.ho=0 fr.ff=gi fr.o=o fr.p=p fr.hp=4 fr.fv=1 fr.fw=1 fr.hq=8 fr.hr=8 fr.hs=0 fr.ht=0 fr.hu=7 fr.hv=7 fr.er=0 fr.hw=0 fr.cu=cu.cv fr.hl=1 fr.hx=1 fr.spr=gi fr.hy={} fr.ei=false hz(fr,cu.cv,{fr.ff}) hz(fr,cu.cx,{22,23}) fr.fb=true fr.ia=0.1 fr.ib=1 fr.ek=1 fr.ic=1 fr.ft=0 hz(fr,cu.cx,{22,23}) fr.fk=false fr.id=true fr.hj=0.6 fr.ey=false fr.hk=5 fr.ie=false fr.ig=false fr.gt=false if b==1 then
fr.gt=true end fr.ih=false fr.ii=false fr.ij=-1 fr.i=0 if gi==v then
fr.id=false fr.hj=0 hz(fr,cu.cv,{28,44}) fr.ik=2*30 fr.ib=0 fr.gz=function() if fr.ik>0 then
fr.ik-=1 return end fr.ib=1 if d<=0 then
il(fr,dt) end end end if gi==110
or gi==126 then fr.i=8 fr.gt=true fr.ek=3 fr.fk=true fr.hl=2 fr.gz=function() if dt.o>fr.o-30 then
im() fk=true em() bz=0 io(gi,fr) end end end if gi==20
or gi==55 or gi==68 or gi==87 or gi==103 or gi==102 or gi==76 then io(gi,fr) end if gi==41 then
fr.hj=0 fr.ig=true fr.i=6 fr.ho=z hz(fr,cu.cv,{41,-41}) fr.ek=3 fr.hl=0.5 fr.hw=fr.hl fr.ip=0 fr.gz=function() if fr.ip>0 then
fr.ip-=1 fr.spr=fr.ff if fr.ip==0 then
sfx(47,2) for l=0,3 do iq(fr) end fr.hw=-fr.hl end return end ir(fr) if fr.ii then
if fr.hw<0 then
fr.ip=1*30 fr.hw=0 end end end end if gi==42
or gi==92 then fr.id=false fr.hj=0 fr.i=4 fr.ho=z fr.er=0.25 fr.is=0 fr.it=3*30 fr.iu=0.025 fr.iv=8 fr.iw=0 fr.ix=fr.p fr.gz=function() iy(fr) iz(fr) ir(fr) end end if gi==79 then
fr.i=42 fr.ho=z fr.ek=3 fr.hj=0 fr.ja=5 fr.jb={} fr.gz=function() ir(fr) if fr.ek<=0 then
for ef in all(fr.jb) do ef.ek=0 end end if fr.ja>0 then
local ef=jc(47,fr.o-2-(fr.ja*4),fr.p+4,ds) fr.jb[fr.ja]=ef fr.ja-=1 ef.iu=0.007 ef.iv=fr.ja*3 ef.iw=0-fr.ja*0.07 ef.ix=ef.p ef.gz=function() iz(ef) ir(ef) end end end end if gi==81 then
fr.i=2 hz(fr,cu.cv,{81}) hz(fr,cu.cz,{82}) fr.ei=true fr.jd=30*1 fr.je=0 fr.hj=0.1 fr.gz=function() if fr.cu==cu.cx then
return end if fr.ey then
fr.je+=1 if fr.je>=fr.jd then
fr.hw-=2 fr.je=0 fr.cu=cu.cz fr.ey=false end end if fr.ey and fr.cu~=cu.cv then
fr.cu=cu.cv end ir(fr) end end if gi==109 then
fr.hj=0.01 end if gi==108 then
fr.i=4 hz(fr,cu.cv,{gi,-gi}) fr.jf=0 fr.jg=30*3 fr.ia=0.2 fr.gz=function() if fr.o<bz or fr.o>bz+56 then
return end jh(fr,dt,100) if fr.jf>30*2 then
fr.spr=fr.ff end ir(fr) end end if gi==66
or gi==64 or gi==65 or gi==bf then ci=fr fr.hj=0 fr.i=20 fr.fk=true fr.ek=3 fr.gz=function() if dt.o>fr.o-20
and e==f then fk=true im() gh(v,ds) e=ji dt.cu=cu.cw dt.ei=true dt.gz=nil dt.hw=0 dt.ft=0 if gv then
em() bz=0 end end end if gi==bf then
fr.i=100 fr.fw=2 end end if gi==14 then
jj(fr,{"oh, alex, i'm \nterribly sorry \nbut i was just \nrobbed of the \nmoonlight \nstone.","the \"crown\" is \nwith your \nprincess and \njanken the \ngreat has \ntaken her.",}) end if gi==84 then
jj(fr,{"thank you,\nalex. janken\nhad trapped me\nin here.","your mother is\nsafe as well,\nshe is in good\nhands.","sadly, i do\nnot know where\nyour father\nis."}) end if gi==29 then
if(b==6) then
jj(fr,{"prince alex of \n\"radaxian,\" \nyou are \nlooking very \nwell indeed! \nwe hear that \nyour elder \nbrother is ","imprisoned in \nthe \"radaxian\" \ncastle and you \nare the only \nperson who can \ncome to his \nrescue.",}) else jj(fr,{"welcome, alex. \nyou are a \nprince from \nthe country of \nradaxian, who \nwas kidnapped \nby evil men \nwhen you were ","but a small \nboy. your \nnative land is \nnow being \ngrossly \nmisgoverned by \nthe tyrant, ","\"janken the \ngreat.\" your \nmission is to \nsave the \npopulace from \nhim."}) end end if gi==60 then
jj(fr,{"thank you, \nalex. the \nmoon-light \nstone is in \nthe nibana \nkingdom,","so you must \nreach there \nbefore janken \nthe great \ndoes.",}) end return fr end function io(gi,fr) fr.i=2 fr.ie=true if gi==103
or gi==102 then hz(fr,cu.cv,{gi,-gi}) else if gi~=76 then
hz(fr,cu.cv,{gi,gi+1}) else fr.hj=0.25 end end if gi==20
or gi==55 or gi==87 then fr.hj=0 end fr.er=-0.5 if gi==55 then
fr.ho=z end fr.gz=function() if gi~=102 then
ir(fr) end if gi==68
or gi==102 or gi==110 or gi==126 then local jk=jl(fr.o+fr.er+4,fr.p+8) if not fget(jk.gi,bo) then
fr.er*=-1 end end if gi==76
and fr.ey then fr.hw=-1.5 end end end function jj(fr,dw) fr.jm=false fr.ib=0 fr.jn=dw fr.gz=function() if(dt.o>fr.o-20
and dt.o<fr.o+8 and fr.jm==false) then fr.jm=true bx=fr.jn end end end function ea(gg) for l=#gg,1,-1 do local fr=gg[l] dz(fr) if fr==nil or fr.hn then
del(gg,fr) end end end function dz(fr) if fr.cj~=nil then
fr.cj-=1 end if fr.ek<=0
or(fr.cj~=nil and fr.cj<=0) then fr.hn=true i+=fr.i local jo=fr.hy[cu.cx] if jo[1]~=0 then
local jp=jc(22,fr.o,fr.p,eb) hz(jp,cu.cv,jo) jp.cj=30*(#jo*0.5) jp.ia=0.065 end if fr.fk and fr.ff~=bf then
ga(6,4,ba) if b==6 then
ga(6,6,29) end end end local hy=fr.hy[fr.cu] fr.hx+=fr.ia if flr(fr.hx)>#hy then
fr.hx=1 if fr.cu==cu.cy then
fr.cu=cu.cv end end fr.spr=fr.hy[fr.cu][flr(fr.hx)] if not fr.fb then
return end if fr.gz~=nil then
fr.gz(fr) end if fr.cu~=cu.db then
fr.hw+=fr.hj end if fr.id then
id(fr) end fr.o+=fr.er fr.p+=fr.hw if jq(fr)==false then
fr.hn=true end if fr.ft>0 then
fr.ft-=1 end if fr.er!=0 and fr~=dt then
fr.ei=fr.er<0 end end function id(fr) fr.ih,fr.ii=false fr.ij=-1 local jr=fr.o+fr.er if jr<0
or jr+7>s or(fk and jr>56) then fr.ih=true end if fr==dt
and el==dg.dm then fr.ih=false end if js(fr) then
local er=fr.er fr.er=0 if js(fr) then
fr.ii=true end fr.er=er local hw=fr.hw fr.hw=0 if js(fr) then
fr.ih=true end fr.hw=hw if not fr.ih
and not fr.ii then fr.ii=true end end if(not fr.ey or btn(3))
and fr.ij~=-1 and fr==dt then fr.o=fr.ij fr.ey=false fr.er=0 return end if fr.ih then
if fr.ie then
fr.er*=-1 else fr.er=0 end end if fr.ii then
if fr.ig then
fr.hw*=-1 else local jt=sgn(fr.hw) fr.hw=0 while(not js(fr)) do fr.p+=jt end fr.p-=jt fr.ey=jt>0 end else fr.ey=false end end function iq(fr) local ef=jc(57,fr.o,fr.p,ed,rnd(2)-1,(rnd(1)*-1)-0.5) end function hz(ju,cu,jv) ju.hy[cu]=jv end function du(gi,o,p) local fr=hm(gi,o,p) fr.gz=jw fr.ek=6 fr.jx=0 fr.jy=false fr.jz=nil fr.ka=nil fr.kb=false hz(fr,cu.cv,{1}) hz(fr,cu.cw,{2,18}) hz(fr,cu.cy,{3,3,1,1}) hz(fr,cu.cz,{19}) hz(fr,cu.da,{12,13}) hz(fr,cu.db,{83,-83}) hz(fr,cu.dc,{bb}) hz(fr,cu.dd,{15}) hz(fr,cu.df,{bc}) fr.fn=0 fr.kc=false fr.hb=nil return fr end function n() dt.dc=false dt.de=false dt.df=false dt.kd=false dt.fb=true dt.cu=cu.cv dt.hj=0.6 dt.hk=5 dt.hl=1 dt.gz=jw dt.ft=2*30 dt.er=0 dt.hw=0 music(ev) end function jw(fr) if fr.fn>0 then
fr.fn-=1 if fr.cu==cu.da then
fr.hw=0 fr.er=0 end return end if m[dr]==w then
fr.kd=true m[dr]=0 dr=0 end local gi=ke(fr) if gi==ba then return end
if(fr.cu~=cu.db
and fr.ij~=-1) then fr.cu=cu.db fr.er=0 fr.hw=0 fr.hj=0.6 gu=0 end local jk=jl(fr.o+3,fr.p+8) local kf=jk.gi if fr.cu==cu.db then
if btn(2) then
fr.kb=true fr.p-=1 end if btn(3) then
fr.p+=1 end if fr.ij==-1 then
fr.cu=cu.cv fr.ey=true fr.p=flr(fr.p/8) fr.p*=8 end else kg(fr) if fr.cu==cu.da then
kh(fr) if btn(3)
and kf==95 then r(18,1) return end if fr.p<0 then
r(19,1) return end else if fr.jx<=0 then
ki(fr) end if btn(3)
and fr.ey and fget(kf,bt) then fr.p+=8 fr.o=jk.kj*8 end end end if(fr.cu~=cu.da and
fget(gi,bs)) then fr.cu=cu.da fr.hj=-0.2 sfx(24,3) sfx(25,2) gu=z end if(fr.cu==cu.da and
gi==39) then fr.hw+=1 end if fr.ey then
if el~=dg.dm then
cb=fr.o cc=fr.p end if kf~=cd then
if kf==27 then
hm(v,jk.kj*8,jk.kk*8,ds) end end cd=kf end if btnp(2) and e~=ex
and(gi==61 or gi==62) then e=ex g=fh sfx(-1,3) fr.hw=0 fr.o=8 dw("welcome.\nplease buy the\nthings that\nyou like.") end if(e==ex
and btnp(2) and dt.o<8) then e=f g=h fr.hw=0 sfx(-1,3) if fe(bb) then
fr.dc=true kl(bb) fr.cu=cu.dc fr.ei=false fr.gz=ha music(bk) end if fe(bd) then
gy(dt) kl(bd) end end for ef in all(ed) do if(fc(fr,ef)
and fr.ft==0) then km(fr) break end end local kn=ko(fr) if(kn~=nil
and fr.ft==0) then km(fr) end end function ee() d-=1 if d<=0 then
j-=1 if j<=0 then
kp() return end n() gh(v,ds) if dt.cu~=cu.da
or el~=dg.dm then dt.o=cb dt.p=cc end if b==13 then
gy(dt) end end end function km(fr) d=3*30 fr.er=0 fr.hw=0 fr.fb=false local kq=jc(9,fr.o,fr.p,ed,0,-0.5) hz(kq,cu.cv,{9,10}) kq.cj=30*2.75 if fr.jz~=nil then fr.jz.fb=false end
music(bi) end function ke(fr) local jk=jl(fr.o+4,fr.p+4) local gi=jk.gi local kj=jk.kj local kk=jk.kk if gi==y then
ga(kj,kk,gu) k+=20 sfx(17,3) gp[gm]+=1 end if gi==w then
fg(w) kr(kj,kk) end if gi==bg then
j+=1 kr(kj,kk) gs[c]=true end if gi==ba then
b+=1 r(b,1) end if fget(gi,bq)
and fr.ft==0 then if(fr.dc or fr.de or fr.df) then
im() else km(fr) end end return gi end function kr(o,p) ga(o,p,gu) sfx(27,3) sfx(26,2) end function ha(fr) if btn(0)==false and btn(1)==false then
fr.er=1 end if btn(0) then fr.er=0.5 end
if btn(1) then fr.er=2 end
local jk=jl(fr.o+fr.er+8,fr.p+5) local gi=jk.gi if fget(gi,bp) then
ks(jk.kj,jk.kk) end if(fget(gi,bp)==false
and fget(gi,bo)) then im() end if gi==39 and fr.df then
fr.hw=-1 fr.ey=true end if btn(2) and fr.ey
and fr.kb==false then fr.kb=true sfx(0,3) fr.hw=-fr.hk end if btn(2)==false and fr.ey then
fr.kb=false end if fr.ey==false
and fr.kc and fr.kb==false then fr.hw=-2 fr.kc=false end if fr.dc then
if fr.ey==false then
fr.cu=cu.dd end if fr.ey then
fr.cu=cu.dc fr.kc=true end end ke(fr) local kn=ko(fr) if kn~=nil then
if fr.df then
im() else ib(kn) end end if fr.df then
kt(fr) end end function hi(fr) local jk=jl(fr.o+4,fr.p+fr.hw) local gi=jk.gi if fget(gi,bo) then
im() end if fr.p>0 then
fr.ey=true end ki(fr) fr.spr=bd kt(fr) local gi=ke(fr) if gi==39 then
im() end if ko(fr)~=nil then
im() end end function ko(fr) for kn in all(ds) do if(kn.ib>0
and fc(fr,kn)) then return kn end end return nil end function kt(fr) local ef=fr.hb if btnp(4) and ef==nil then
sfx(15,3) local er=4 if dt.ei then
er=-4 end ef=jc(47,fr.o,fr.p,ec,er,0) hz(ef,cu.cx,{80}) ef.cj=10 ef.ek=1 fr.hb=ef end if ef~=nil
and ef.hn then fr.hb=nil end end function im() if
dt.dc==false and dt.df==false and dt.de==false then return end n() dt.hw=-4 ku(dt.o,dt.p) dt.ey=false dt.kb=true cb=dt.o cc=dt.p end function ku(o,p) local jp=jc(80,o,p,eb) jp.cj=30*0.5 jp.hj=0 end function fg(gi) if gi==bg then
j+=1 return end for l=1,#m do if m[l]==0 then
m[l]=gi return end end end function fe(gi) for l=1,#m do if m[l]==gi then
return true end end return false end function kl(gi) for l=1,#m do if m[l]==gi then
m[l]=0 end end return end function hh(kv,kw) local kx={} for l=1,#kv do local ky=hm(kv[l],-4+(l*16),32,ds) ky.fd=kw[l] add(kx,ky) del(ds,ky) end return kx end function fu(kz) for l=0,15 do pal(l,kz) end end function ki(fr) fr.cu=cu.cv if btn(0) then
fr.er-=fr.hl fr.cu=cu.cw fr.ei=true end if btn(1) then
fr.er+=fr.hl fr.cu=cu.cw fr.ei=false end if btn(2) and fr.ey and fr.kb==false then
fr.kb=true if fr.de==false then
sfx(0,3) end fr.hw=-fr.hk fr.ey=false end if btn(2)==false and fr.ey then
fr.kb=false end if fr.ey==false then
fr.cu=cu.cz end fr.er/=1.5 if abs(fr.er<0.25)
and not btn(0) and not btn(1) then fr.er=0 end end function kh(fr) cb=fr.o cc=fr.p if fr.hw>4 then fr.hw=4 end
if btn(0) and fr.er>-fr.hp then
fr.er-=fr.hl fr.ei=true end if btn(1) and fr.er<fr.hp then
fr.er+=fr.hl fr.ei=false end if btn(2) and fr.hw>-fr.hp then
fr.hw-=fr.hl end if btn(3) and fr.hw<fr.hp then
fr.hw+=fr.hl end fr.er/=2 fr.hw/=2 end function js(fr) local la=fr.o+fr.er local lb=fr.p+fr.hw local lc=la+7 local ld=lb+7 la/=8 lb/=8 lc/=8 ld/=8 return le(la,lb,fr) or le(la,ld) or le(lc,ld) or le(lc,lb,fr) or(el==dg.dl and fr.p+fr.hw>=56) end function le(lf,lg,fr) if fget(lh(lf,lg),bt)
and fr~=nil then fr.ij=flr(lf)*8 end return fget(lh(lf,lg),bo) end function fc(li,lj) if
li.o+li.hu<lj.o+lj.hs or lj.o+lj.hu<li.o+li.hs or li.p+li.hv<lj.p+lj.ht or lj.p+lj.hv<li.p+li.ht then return false else return true end end function ib(fr) if fr.ft>0 then
return end fr.ek-=1 fr.ft=fr.ic*30 sfx(21,3) if fr.ff==110
or fr.ff==126 then fr.er*=(4-fr.ek)*0.75 end end function iy(fr) fr.is+=1 if fr.is>fr.it then
fr.er*=-1 fr.hw*=-1 fr.is=0 end end function iz(fr) fr.p=fr.iv*sin(fr.iw) fr.p+=fr.ix fr.iw+=fr.iu end function jh(fr,gi,lk) fr.jf+=1 if fr.jf>=fr.jg then
fr.jf=0 local ef=jc(lk,fr.o,fr.p,ed) il(ef,gi) end end function jc(gi,o,p,gg,er,hw,ll) local fr=hm(gi,o,p,gg) hz(fr,cu.cx,{0}) fr.id=false if er~=nil then
fr.er=er fr.hw=hw end fr.hq=4 fr.hr=4 fr.hj=0 if ll~=nil then fr.hj=ll end
fr.hs=2 fr.ht=2 fr.hu=5 fr.hv=5 return fr end function jq(fr) if fr.o<0
or fr.o+7>s or(fr.p<ca+-7 and el==dg.dj) or fr.p+7>t then return false end return true end function kg(fr) if btn(4)
and fr.jx==0 and fr.jy==false then fr.jx=10 fr.jy=true sfx(1,3) fr.hx=1 if fr.cu~=cu.da then
fr.cu=cu.cy end local ef=jc(x,fr.o,fr.p,ec) fr.jz=ef ef.cj=30*0.15 ef.ek=1000 ef.hl=0 ef.ei=fr.ei if fr.kd then
sfx(28,2) local lm=jc(43,fr.o,fr.p,ec) fr.ka=lm lm.ib=10 lm.ln=1000 lm.ek=1000 lm.ei=fr.ei if fr.ei==false then
lm.er=4 else lm.er=-4 end end end if not btn(4) then
fr.jy=false end if fr.jx>0 then
fr.jx-=1 if fr.ey then
fr.er/=1.5 end end if fr.jz~=nil then
local ef=fr.jz ef.o=fr.o+fr.er ef.p=fr.p+fr.hw if fr.ei then
ef.o-=7 else ef.o+=7 end end end function jl(lo,lp) local lq={} lq.kj=flr(lo/8) lq.kk=flr(lp/8) lq.gi=mget(lq.kj,lq.kk) return lq end function ej(o,p) if o>bz+64 then
return end local jk=jl(o,p) local gi=jk.gi if fget(gi,bp) then
ks(jk.kj,jk.kk) return true end return false end function ks(kj,kk) local gi=mget(kj,kk) ga(kj,kk,gu) local lo=(kj*8) lp=(kk*8) jc(8,lo,lp,eb,-1,-5,0.5) jc(8,lo+4,lp,eb,1,-5,0.5) jc(8,lo,lp+4,eb,-1,-3,0.5) jc(8,lo+4,lp+4,eb,1,-3,0.5) sfx(16,3) if gi==4 then
ga(kj,kk,y) end if gi==6 then
if(dt.kd or
fe(w)) then local ll=hm(v,kj*8,kk*8,ds) else ga(kj,kk,w) end end if gi==16
and not dt.de then dt.fn=2*30 dt.er=0 end end function dw(dv) bw=30 bv=dv end function ga(o,p,gi) if fget(gi,bu) then
local fr=hm(gi,o*8,p*8,ds) gi=fr.ho end local lr=8 local lt=8 if el==dg.dl then
lr=16 end if el==dg.dj then
lt=16 end if o>=0 and o<lr and p>=0 and p<lt then
mset(o,p,gi) end end function lh(o,p) o=flr(o) p=flr(p) if(el==dg.dm
and(o<0 or o>7 or p<0 or p>7)) then return 0 end return mget(o,p) end function ir(fr) if fr.cu==cu.cx then
return end for ef in all(ec) do if fc(fr,ef) then
ef.ek-=1 ib(fr) end end end function il(fr,gi) local lf=gi.o-fr.o local lg=gi.p-fr.p local lu=sqrt(lf*lf+lg*lg) fr.er=(lf/lu)*fr.hl fr.hw=(lg/lu)*fr.hl end function hg(sfx,hl) poke(0x3200+68*sfx+65,hl) end function ji() if dt.o>8 then
dt.er=-1 dz(dt) ea(eb) end if dt.o<=10 then
lv() end end function lv() eb={} ec={} ed={} dt.ft=0 cq=0 cp=0 co=""dt.o=8 dt.p=48 dt.ei=false cm=hm(x,15,47,eb) cn=hm(x,42,48,eb) cm.spr=x cn.spr=x cm.fb=false cn.fb=false cn.ei=true dt.spr=1 bx={"i'm\n\"stone head\",\nthe third\nhenchman of\nthe king.","i'll let you\npass by here\nif you win 3\n\"janken\"\nmatches.","you must\nchoose either\nthe \"paper\",\n\"scissors\" or\n\"stone\" before\nthe music\nstops.",} if ci.ff==64 then
bx[1]="i'm \"scissor\nhead\", the\nsecond\nhenchman of\nthe king."end if ci.ff==65 then
bx[1]="i'm \"paper\nhead\", the\nfirst\nhenchman of\nthe king."end if ci.ff==bf then
bx[1]="it's lucky\nyou've come\nthis far,\nhowever, i'll\nput and end\nto that."
bx[2]="let's \"janken\"\nfor 3 matches,\nand if you\nlose, i'll\nturn you into\nstone."
cn.o-=2 cn.p-=2 end e=lw g=lx music(-1) end function lx() h() fq(16,16) fq(48,16) spr(x+ck,12,12) spr(x+cl,42,12,1,1,true) print(co,8,24,0) end function lw() if#bx==0 and bv==nil then
e=ly cj=0 music(bm) end end function ly() cj+=1 if(cj%60==0
and cj<8*30) then local lz=cl while(cl==lz) do cl=flr(rnd(3)) end end if btnp(2) then
ck+=1 if ck>2 then
ck=0 end end if btnp(3) then
ck-=1 if ck<0 then
ck=2 end end if cj%25==0 then
dt.ei=not dt.ei ci.ei=not ci.ei end if cj>10*30 then
cj=0 dt.ei=false dt.spr=3 ci.ei=false e=ma end end function ma() cj+=1 local mb=cj%30 if mb==0 or mb==15 then
cm.fb=not cm.fb cn.fb=not cn.fb end if mb==15 then
sfx(1,3) if cj>=2*30 then
cm.spr=x+ck cn.spr=x+cl e=mc end end end function mc() local md=false if((ck==0
and cl==2) or(ck==1 and cl==0) or(ck==2 and cl==1)) then md=true end if ck==cl then
dw("it's a draw.\nyou sure\nlucked out.") else if md then
dw("darn it. i\nlose.") cp+=1 co=co.."o"else dw("i win. you got\nit.") cq+=1 co=co.."x"end end if cq>=2 then
e=me cj=0 return end if cp>=2 then
e=mf return end e=mg cj=0 end function mg() if#bx==0 and bv==nil then
cm.fb=false cn.fb=false cm.spr=x cn.spr=x dt.spr=1 e=ly cj=0 music(bm) end end function me() if cj==0 then
dw("you'd better\naccept the\ninevitable!") cm.fb=false cn.fb=false end if cj==1 then
km(dt) end cj+=1 f() if cj>=4*30 then
e=ji dt.ft=2*30 dt.fb=true end end function mf() e=f eb={} dt.cu=cu.cv dt.gz=jw g=h local mh="well it looks\nlike that's\nthe way it's\nmeant to be.\nok. take this!"if b==11
or b==12 or b==15 then if b==11 then
ga(1,7,77) end ev=bn music(bn) dw(mh) ci.er=0.5 ci.hw=0.5 ci.ie=true ci.ig=true ci.hj=0 ci.iu=0.025 ci.iv=8 ci.iw=0 ci.ix=40 ci.gz=function() ir(ci) if b==15 then
iz(ci) end end return end if ci.ff==bf then
dw(mh) e=mi ci.gz=ir mset(0,5,97) mset(0,6,97) music(bn) cb=10 dt.o=10 return end ci.ek=0 end function mi() f() cj+=1 if cj>30*3 then
cj=0 local ef=jc(100,ci.o-2,ci.p,ed,-0.5,0) ef.iu=0.025 ef.iv=8 ef.iw=0 ef.ix=40 ef.gz=function() iz(ef) end end if ci.ek<=0 then
e=f for l=1,5 do mset(1,l,113) end end end function kp() e=mj g=mk camera(0,0) rectfill(0,0,64,64,0) print("game over",14,16,7) print("score: "..i,8,32,7) music(39) bw=90 end function mk() end function hc() hf-=0.25 if hf<-330 then
kp() bw=300 end end function hd() camera(0,0) rectfill(0,0,64,64,0) print(he,2,hf,7) end function mj() if bw>0 then
bw-=1 elseif btnp(4) or btnp(5) then a() end end
__gfx__
000000000444440004444400004444407aaaaaa7044444407aaaaaa701717171000000000777770007777700000770000000000000000000a00aa00a04444400
00000000494444404944444004944444a7a1aa794fff9994a7aeea7901777771000000007000007070000070007777000044444000444440aaaaaaaa49444440
00000000497171404999714004999714aaa9aaa94ffff494aae11ea900177710000ff0007070707070707070077777700494444404944444a44ff44a49997140
00000000449999004499990004499990a19991a94fffff94aaaae1a90177777100ff99007700077077000770071111700499971404999714ff1ff1ff44999900
00000000008180000011800000081990aa191aa94fff9f94aaae1aa9077171770099990000777000007770007711117704499990044999900ff11ff000011910
00000000088888000098800000088800a19a91a949ff4994aaaaaaa9077717770009900007000700770007707711117700881190188811900088880001588151
00000000098889000088800000088800a7aaaa7949999994a7ae1a790177777100000000070007000000000007111170188000000880000000f88f0015180010
00000000001010000010100000001000799999970444444079999997001111100000000000707000007070000011110000000000100000000118811001000000
7aaaaaa704444400044444000444440000000000000000000000000000ffff000000660000066000002882007eeeeee700011100009999000033300000444440
a71111794944444049444440494444400371331000013310000000000f77f7f0000777676077760008878880e7111172001d1110099999903344433304944444
a11111194999714049997140499971403331a8310011a831000ff000f777777f077777777677776028788882e111111201d1a1a097799779422b444404999714
a1a11a19449999004499990044999900313333881337338800f77f00f777777f677777777777777688888888e1e11e1201dd11179919919944444bbb04499990
a1111119008886600081800000118000113333703133337000f77f000f7777f06777777777777766888888e8e111111201dddd70099119903334222400018000
aa1aa1a90088666a00819000009880000319910013199100000ff0000f77777006777667777666602888eee2ee1ee1e201d1117000d77d002244433301511910
a7a11a795aaaaaaa000800000188810000000000000000000000000000ff77f00066660066606600088eee80e7e11e721ddddd7009dddd903bb334bb15188151
799999975aaaaaa000010000000000000000000000000000000000000000ff0000000000000000000028820072222227111111700dd44dd0b233b44401000010
3bb333b33bb33bb333b33bb30111111000000110011000000030000b00000000157511751703307100033300000000000011100000000f4444f0000000000000
bbbb3bbbbbbb3bbb3bbbbbbb13bb3b3100011b3113b110000003b3b0000000005766576677333377033bbb300777700001d11100000ff4ffff4ff00000000000
3bbbbbbb3bbb3bbbbbb3bbb313b33bb1001b3bb11bb3b10000003b00007000005666166603bbbb3000baa1300089a7001d1a1a0700ff4ffffff4ff0000022000
03332bb3bbb3bbbb3bb233301b33b3b10133b331133b331003030bb0070ddd00156665650bbbbbb030bbaa3000089a701d1111700ff4ffffffff4ff000288200
029942333bbb3bb3b3249920133b33b1013b33b11b33b31000300b0bd00000dd7656615108bbbb88b3b7878300089a701dddd1700ff4ffffffff4ff000288200
00244423b3b3b3b3324442001bb3bb311bb33b3113b33bb100300b00000000006665176108dddd0abbbbbbb30089a7001dd11d70444444444444444400022000
00022294943432394922200013bbb33113b3bb3113bb3b310300b00000000000565656660aa00d00b3bbbbb3077770001ddddd70ff4ffffffffff4ff00000000
0000002244422944220000000111111001111110011111100300b000000000001516656600000aa0303333300000000011111100fceecececeeeceef00000000
22222222222222222222222201111110011111100111111006000000013310000133100007700000001881000000000000444400fcecceeecececeef06666660
29942992299429922992499213bbb33113b3bb3113bb3b310000060003bb177003bb177077760070018aa8100000000009999990feeccececeeececf69444446
2444294294442942249244421bbaab311bb33b3113b33bb1000000001bb1b7101bb1b1707766000017c88c710007770094499449444444444444444469997146
0242944294429442444924201baaaab1013b33b11b33b310000000003b31bbb13b31bbb1066000001c1001c10007770099199199ff4ff411114ff4ff64999906
0222444244424442444422201babaab10133b331133b3310000060003b31bbb83b31bbb800000770010000100007770009911990ff4ff411114ff4ff55888555
00224422222244222244220013babb31001b3bb11bb3b1006000000013b1bbb113b1bbb100007776010000100077777000333300ff4ff411114ff4ff55515550
000222949949229949222000133bb33100011b3113b11000000000000011b1000011b10000707766001001000007770000933900ff4ff411114ff4ff00151000
00000222444229442220000001111110000001100110000000000060013100000013100000000660000110000000700001133110ff4ff411114ff4ff00010000
99000990000940000000990000dccd0000882000008820000000000000000000000099000003100000000300000000000288811011111111fffccff902288820
9990999000494900009999900c7c2cc008088000080880000000000000000000000999000003100000003b30000000002889770066616666fdcffcd928888882
099999000949490001791799d7cc8ccd802880008028800000990000009900000949900000031000b30024000000000088897100ccc16cccfcf22fc922882228
017917000999990009994999c728882c808200008082000009999000099499000994999900031000344402400044440088899991ccc16ccccf2ee2fc1a8881a8
099999900179174000999440ccc282cc80000770800007709944900099499990994499990003100002244444004994008dd9191111111111cf2ee2fc88998888
009999900999949000022200dc28c82d08088712080887129949900099999990999990000003100003b2222400088000dccd911866666661fcf22fc989119888
0033300000999900000222000cccccc00088888800888888094990000999990000999000000310003b300002000880002dcd88826cccccc1fdcffcd929119882
08808800088088000088088000dccd00008080800800080800000000000000000000000000031000b30000000001100002aa88a06cccccc1999cc99902998882
0008000000000000000071bb04444400003aa3300dddddd0000000000030030000300300005665001b141bb30555555000022000166666610000000088188188
08090800000071bb000b77ba4444444003333393d677666d0000000090333309009339000667666013b31b3b5d6d67d5002712201cccccc1000000008d98d9d8
009a9000000b77ba0bbbbbaa4444444003171793d6766669888888883103301300333300567666651133b3bb566665d500022000111111110000000088d88d88
89aaa9800bbbbbaabbbbbba04444444000999933d76666f48a8a8a8a33333333003333006666666642441bb156d666d500c270001c1001c10000000018dd8d81
009a9000bbbbbba0bb3aba0009818800000ccc33d6669f99a8a8a8a83333333300333300666666f641b14112566676d5002270001666666100000000dddddddd
08090800b333abb0bb00b0000888800000c686c0d6ff4f948888888833133133003333005666fff51b3b3bb15d665dd500c200001cccccc1000000001dddddd1
00080000bbbb3abbbb0bbb0000888000009c6c90d9499994282828283101101300311300066fff601b3b1b3b5dddddd50022020011111111000000001dddddd1
000000000bbbb0b0b000b000000010000ccccccc0dddd4402222222210000001001001000056650041b141b305555550000220001c1001c10000000001dddd10
00dddd0022222222007000700006000000000000144441000008000099133100333333b3000000001b101bb30044044000000000224942220000000000000000
066dddd099929999007000700060600000000000444414100008800099333331333b33b30000000013b31b3b04f92f9400444400444944440000700000007000
d6ddddd9444294440c7c0c7c0060600000033000014414410808800097131799333b3333000b000b1133b3bb4f9b49b494999940000700000000994000009940
1111111944429444077c077c00606000003bb300001144410878a870977377993b3333330b0b0b0b00001bb149b42434449191400c77cc000999971009999710
a111aa1922222222c77cc77c00060000003bb300014144418871a170931311393b3333b33b3b3b3b01b1011002422420444444440077c0009999999899999998
119111199999999200700070006060000003300014441444888aa880133133313b33b3b333b333b31b3b3bb14f944f940004400400c7c000a4999948a4999948
959599909444444224942494006060000000000044441441088aa880133313313333b333b3b3b3331b3b1b3b49b329b400444409000700000900009000900900
099999009444444224942494006060000000000014444110008888000111011033333333b333b33301b101b3044404400940049000070000a000000a000aa000
0dddddd02999999222222222f999999f00000000141014400000014441441414141000000000333144442442000000000000000000dd0dd00313000003130000
d17771dd24444442249424949f9229f400000000444144410001444444444444444410000333111342442442f0f0f0f0000000000d7c17cd3111000031110006
911711dd222222220070007099499494000000004441444100144441411444444444410031131003424424429090909000000000d7ccdccd3172100031721060
917711dd24200242c77cc77c92922924000000004444144100441144444144444114440031031313444424424040404000000000dccd1dcd111dd000111dd600
0aaaaa9929999992077c077c9292292400000000144414400044444444444441444414000313103144244442222222220000000001d11d10111d0000111d6000
01111199244444420c7c0c7c99499494000000001441141001444114444411441444441000033100442442422442442400000000d7cdd7cd2111666622110000
0770777022222222007000709f9229f4000000001410010014441444411444444114444100031000244442424244244200000000dccc1ccd2230000022200000
ddd0dddd2420024200700070f444444f0000000001000000441444414444444444441144000310002444444222222222000000000ddd0dd01011000001100000
410000021222000000000000a6a5a60000a6a5a6a6a5a600000000000000a65777a5a577a577a5778191000000000000d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4
d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
00007000004000000000000000a700000000a7c660a7000000000040000000a657575757575757770000000000008191d427270000000027d400753636000000
00000000000000d4d4707000000000d41600000000000000000000000000001616d6d6d6d6000016160000004400000000000075003700161616373737371616
00507000005000000081910044a762400000b5b5b5b500008191000040000000a60000000000c67700000000a1000000d4000000000000000000003636000000
000000000000b4d4d4000000000000d4160000150000000000000000000000000000000000003716160000001616160000000000003700161637000000003716
005000000040000062000000b5b5b5b5000000000000000000000000c6400000000000000000a4770000004095400000d4000070e470e4d4d4e400d4d400e4d4
d40066000000d4d4d4000000000060d4160000160000161616000000001500000000000000000016160000000000001616004400001600161600000000000016
0002220002220002b5000000000000000000008191000000000000004000000000000000000000770000404095404000d4001500e400e4d4d4000000000000d4
d400d4d4d40000d4d4e4e4e400d4d4d4161500000000271616000015001600161600000000003716161600004400000000001616161600161600000000000016
0000000000000000000000000000000000b500004400000000000040b500000000000000000000770095959595959595d400e400000000d4d400e40075000000
00757070707500d4d4e400e4002727d41616000000000016160000160000001616000000000037161600000016161616161616000016001616000000b0000016
70000000000000000000b5620000000000000044b5b54062440062b5b562000000000000000004779696969696969696d400e426002600d4d400260000260000
0000e400e40000d4d4e4c3e4000000d4166066000000001616000000000000161600000000000016160015440000000000001600003700161600000000450016
700000000000000086868686868686868686868686868686868686868686868686868686868686868686868686868686d4d5d4d4d4d4d4d4d4d4d40000d4d4d4
d4d4d4d5d4d4d4d4d4d4d4d4d4d4d5d4161616161616161616171616161616161616161616160016160016161616171616171616171617161617161616161616
127272727272727272727272727272727272727272727272727272727272723200000000819100001616161616161616d4d5d4d4d4d4d4d4d4d4d40000d4d4d4
d4d4d4d5d4d4d4d4d4d4d4d4d4d4d5d4161616161616161616171616161616161616161616160016160016161616171616171616171617161617161616161616
133352636363636363636363425263636363334040326363636363425263b03200160016001600161637373737373737d4d500e4007500d4d4600000000075d4
d470000000e4e4000000e4e47500d5d4160000000000001616170000000000161600000000000016160000001600001616171616171617161600000000000016
1363326363736263634352636333637362636363326332626363634332636332001616161616161616a78585a78585a7d400e400e40000d4d4d40000000000d4
d4d400d400e4e4000000e4e4000000d4160000000000001616004400000000161600000000761616160000b40000001616171616171600161600000000000016
1363326363423252636332636332636332636232636363326373636332626332001637373737371616a70000a70081a7d4e4700070e400d4d400e400000000d4
d400000000e4d4d4d4d4d4d4d4d4d5d4160000000000001616001616160000161600001616161616161616161600001616171616171600161600000000000016
13633263633263605263327363435263326332636363636332636342323263320016a785a785a71616a79100a70000a7d4e4e4e4e4e400d4d4000000000000d4
d400d40000d4e400000040d47070d5d4160000000000001616000000000017161600000000000016160000000000001616171600001615161600000000000016
136333634232633253633240403333633263636363636363636342323232633200a7a700a700a7a7a7a70000a7e0b0a7d4e4e4e4e4e400d4d4000000e40000d4
d4000000d400e400000040d40000d5d4160000000000401616000000000017161600000044000000000000000000001616171600161616161600000000000616
136263404033333262624340406340423252626263926362633333333333403200a7a7a7a7a7a7a7a7a7161616161616d4e4006600e400d4d4262600002600d4
d46600000000e400000000d4440000d4160000000000001616000000000066161626161616160000000000000000001616171600004400000000000000000016
131212121212121212121212121212121212121212121212121212121212121216161616161616161616161616161616d4d4d4d4d4d4d5d4d4d4d4d4d4d4d5d4
d4d4d4d5d4d4d4d4d4d4d4d4d4d4d4d4161600000000161616161716161616161616161616161616161616000016161616171616161616161616161616161616
127272727272727272721212121272727272727212121212721272727272727212727272727272120000000000008191d4d4d4d4d4d4d5d4d4d4d4d4d4d4d5d4
d4d4d4d5d4d4d4d4d4360000000036d4161600000000161616161716161616161616161616161616160000000000001616171616161616161616000037000016
1363636363636363637332323232636342325263323232326343324063636332536363636363b0138191000041000000d43600003600d5d4d40000000000d5d4
d400d400000000d4d4e4e4e4e4e4e4d416160000000070161600170000000000000000000000371616000000000016161617d6d6d6d6d6161616000037000016
13325263636363626363433232536363324033633240333363634332406363536363a263636312130070707000707070d4d60000d600d5d4d4000000000000d4
d400d4d4d4d400d4d4000000000000d4161616000000161616000037000000161600000000003716161600000000001616170000000000161616000037000016
13636352636312126363634353406363433253634332325363636343403333636333626363631313009595a1009595a1d40000000000d5d4d4000000d500e4d4
d4000000000000d4d4000000000000d416700000001616161600003700000016160037000037401616161600000016161617000000000016161600003700b416
136063326363435363636363636363636363636363333333c56363636363636363323263636213130000000095000000d40000000000d5d4d400d50000000000
000000000000d4d4d4000000000000d4161600000000701616000016000000161637373700373716161600000000161616170000000000161616000016161616
133233337363636363636363f4636363c5636363633333336363636363f4636363633363631213130000440095004400d40000000000d5d4d400d500000000d4
d4d4000000d400d4d4000000000000d4161616000000161616001627000000161637403700370016167000000000701616170000000000000000370000000016
133232336362404063636363f563636363636212121212406262636363f5636362633373621313139696969696969696d4000000000000d4d4000066000066d4
d4000066000066d4d4000000000024d4160000000016161616000000002626161637373700370016161600000000161616000000000000000000370000000016
131212121212121212121212121212121212121313131312121212121212121212121212121313138686868686868686d4d4d4d4d4b1d4d4d4d5d4d4d4d4d4d4
d4d4d4d4d4d4d4d4d4d5d4d4d4d4d4d4160016161616161616161616161616161616161616161716161616000016161616161616161616161616161616161716
00000000000000000000000081910000000000000000000000000000a10000000000000000000000000000a100b4a100d4d4d4d4d4d4d4d4d4d5d4d4d4d4d4d4
d4d4d4d4d4d4d4d4d4d5d4d4d4d4d4d4160016161616161616161616161616161616161616161716167272727272721616161616161616161627272727271716
00819100000000000000000000000000000081910000000000000000a10000000000000000000000000000a100a10000d4000000000000d4d4000000000000d4
d4003600003600d4d4d50000000000d4160027272700000000000000000000000000000000001716166363636363971616271627271627161663636363636316
00000000000000000000000015000000000000000081910000008191a10000000000000000000000000000a100950000d4000000000000d4d4d40000d400d4d4
d400d60000d600d4d4d50000d40000d4160000000000000000000000000000000000000000001716166397636363161616631663631663161663161616161616
00000000008191000000000050008191000000000000000000000000a181910000000000000000000000004095950000d4000000000000000000d400000000d4
d4000000000000d4d4000000440000d4160000000000001616000000440000161600000000000016166394636363631616631663636363161663636363632716
00000000000000000000155050501500000000000000000000000000a1000000000000000000000000009540000000a1d40000660000000000000000d400d4d4
d4000000000000d4d4006600d4d4d5d4160000001600001616000016160000161600001600000016161616166363631616636363639763161626262663636316
000000d2e2000000000050705050500000000000000000000000a100a1000000000000000000000000954440959595b0d400e4e4e4e400d4d400d40000000000
000000000000e40000d4d4d40000d5d41600001600000016160000161600001616000000000037000000b4166397636363639763631663161627272763636316
000000d3e3000000005050505070505000000044a10000440000a1000000a10000000000000024009696969696969696d400e4b466e400d4d400440000d40000
000000000000e40000000000000000d4166000262626261616262616162626161666000000663700000060166394636363631663631663636363636363632616
8282828282828282e182e1828282e1828282828282828282828282828282828282828282828282828686868686868686d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4
d4d4d4d4b1d4d4d4d4d4d4d4d4d4d4d4161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616
__gff__
0000000003030300010000080000800003000000800000000000010180800400010101010101001001808000000000000101010301011080000200008000000080808000800000000004010080010380018000008003048000030001802100018001040000018080014000038080800000210403010101010104000401018000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000027272727272727272727272727272727272727272727272727272727272727236565656565656565656565656565653600000000000000001819000000000000000000000000000000000000000000000000000000000000000000001a1a1a1a00000000000000001819000000000000000000001a000000
0000000018190000363636363636263636342323353625363636242323232536363636363636232365363636363637366536363636363636001819000000000000000000000000000000000000181900000000000000001a00000018190000001a1a000007070707000000000000000000000000000000001819000000000007
00000000000004002121253636363425363634353636342536362336363633362a36363636330b23653636366536363665362a3636363676000000000000000000000000181900000000000000000000000000000000001a0000000000000000001819000707070700000018190000001400000000000000000000000b000000
2121220000202121103623373636362337363636363636363636233636363336363636363633042365656536653665366536363636367677000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000001a07071a0000001a1a1a00001a1a1a1a000000
3132000000003031043634253636243536362121363624353636103636363336363636363333042365363636653665366536363636367777000000070700000000000000000000000000000000000000000000000000001a00000007071a1a000000001a0000001400000000000000000000001a0700071a0000070700001a00
040000000000050637363623363633363626313137362336363633362936232624333336363606236536656565366536652a363636767777000007000007000000000000000000070700000000000000070000000b00001a1a1a000000000000000000000007071a0000000000001a00001a1a000000001a0000000000000007
040000002021212123262633363604043621313136362326363623263636342323043336363633236526373636262636363736367677777700000000000000000000001a000000000000001a1a0000001a0000000000001a000000000000000000000000001a1a0000000000071a00000007070000000000000000001a000000
21212200003031312121212121212121213131312121212121212121212121212121212121212121656565656565656565656565777777772727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727271a1a27272727272727272727272727272727271a1a
313200050000303100001a0000001a0000000000000000001a0000000000001a0000000000181900001a0000001a000000000000000000000005070507050700000000000000000000000000000000000018190000005b5b00000000000000000018190000000000000000000000000000000000000000000000000000001819
320000050018193000001a0000001a00000000000018190000001a1a000000000018190000000000001a0000001a00000000000000000000000505050505050500000000000000000000000000070000000000000000005b00000000000000000000000000000000000000000000000000000000000000070000000000000000
000020212200000000001a0000001a000000000000000000000000001a0000000000000000007900001a0000001a00000000000000000000005b00000500000500000000000000000000000000000000000000181900005b00000000000000000000000004040404000044070707070000000000000007140000001819000000
140000000000000400001a001a001a00000018190000000000000000001a1a000000000000004900001a001a001a00000000000000000000000507000500075b000000000000000000000079005b0000000000000000005b00000000000000000000005b5b5b5b5b000005050505050000000000000000000000000000000000
0000052021220004000000001a0000000000000000000014007900000000000000790000000049000000001a000000000000000000000000000500005b0000050000000079000000005b004900070000000000000000005b00000000000000000505000000000000070705070705000000000000000000000000000000000000
0400050000050000000000000000000000000000000000001a4900000000000000490000790049000000000000000b000000000000000000000500000500000500000500490005000007004900000000000000000000005b00000500000005000000000000000000050505070700000000000005070005050000000000000000
0505000000000500000000001a0079000000000000000000004900000000791a00490000490049000000001a007900000000000000000000005b00000500000500790000490000000000004900000000000000000000415b00000500440005000000000505050505050505000500000500790005074405050000000000004100
212122140000040528281e1e1e1e1e28281e1e1e1e1e1e1e281e1e1e1e1e1e28281e1e1e1e1e1e28281e1e1e1e1e1e0000000000000000002828282828282828281e1e1e1e1e1e1e281e1e1e1e1e1e1e2828282828282828282828282828282828281e2828281e2828282828281e2828281e2828282828282828282828282828
04000000000504300000000007070707000000000000000000000000181900000707000000000505000007070018190000000000005b5b5b000000000000000065656565757565650000000000070707000000000000000000000000045500000000000000000000756575656565656500000000000000000000000000000000
000500000500000000001819070707070000000000000000000000000000000000000018190007000000000000000000050504000000005b000000000018190065757500000000750000000000555555000000000000006700000000555500000000000066000000007500757565656500000000000000000000000000000000
0005000000000000000000000000070000181900000500000000000000000400000000000000070505050000004c0000000000050500045b000000000000000075650055555555000000670055555555555500000000555500000000000000000000555555040000000000000075656500000000000000000000000000000000
040005050000000000000000000007000000000000050504000044000000000005040000000007000000000000055b00000700070500005b001819000000000065650004000004000000550004000057005555555555060400000076786600000000040000000600000000000000756500000000000000000000000000000000
000000050000000600000000000000000000000000000000000505000000000000000000040000000000006600005b00040505000005005b000000000000000065750000005500005504000000000000000404000055550000000077777778000000100000000004000000000000007500000000000000000000000000000000
140000040400202100002d2e00000000100400000500000005000000000010050405000500000000000005050000050000000000005b0005000000000000000075000000550000005555000000000000000000000000000076780000000077000055040000000055000000000000000000000000000000000000000000000000
000000040000000000003d3e000000000500004c000000000000004c000000000000000000000000000000000044050005004c4c4c5b0005000000000000006e0000000055000076777777777800000076777777777777777777004b070077785504004400000055000000000000400000000000000000000000000000000000
21212122000000046868686868686868686868681e1e6868686868681e1e1e6868681e1e1e1e68686868686868686868686868686868681e6868686868686868777777777777777777777777775656567777777777777777777756777756777777777777771b7777777777777777777728282828282828282727272727272727
3131320000000505000000000000000059590000000000000000000018190000001819000000000000000000000000002325272727272727272727272727272727272727272727272727272727272721000000006a5a6a6a6a6a6a6a6a6a6a6a6a6a5a6a6a6a6a6a6a6a6a6a6a6a6a6a6a5a6a6a6a6a6a6a0000000000000000
05050500002021210000000000181914100400000059000000005900000059040000000000000044000000000076780023353624232536363624253637363636363636362423232536232a3636360b3100000000007a00000000000000000000006c7a000000000000000000000000006c7a00000000007d0000000000000000
040005001400303100181900000044001a59000000000000000459000000590400001a1a1a1a1a1a0000000076777778233636331033363636343536242536362436253736043336362336363636263100000000007a00000000570000000000004a7a000000000000000000000000004a7a00000000007d0000000000000000
100005000000000400000000005959005959000000000000001a59000000595900000059595959590000000065750b772336363423353636363636363435363623262336342323353623363736362131000000004a7a0000000000000004000000007a0000000000000000040000006b007a00000000007d0000000000000000
0400050000000000000000000059100000005900000014590059100059000000000059591400001a0000000075000077233636363636362423253636363636363423353636363736362336363636313100000000007a00000000000000006b0000007a00000000000000006b00000000007a00000000007d0000000000000000
2121212200201b210000595900595900000000000000001a00591a0000000000595959590404041a00000000001d00772336363636363633043337363624253636363636363636363626263636363131002d2e00007a0000000000006b00000000007a006b000000006b0000007d0000007a00000000007d0000000000000014
3131320000003031696969696969696969696900006969696969690000696969696969696969696969696969777777772336363636373634233536262634353636043636262626363634352626263131003d3e00007a000000007d000000007d00007a00000000000000000000000000007a000000007e7d0000000000000000
000000000000000068686868686868686868685656686868686868565668686868686868686868686868686868686868212121212121212121212121212121212121212121212121212121212121313168686868686868687b7b7b7b7b7b7b7b68686868687b68687b7b7b687b7b7b7b68686868686868682727272727272727
__sfx__
00020000253701e3701a37015370123700f3702037020370213702137021370223702237022370223702237023370233702337024370243702537025370263702737028370293702a3702b3702c3702d3702e370
000000001d3701d3701d3700a3700937009370083701437014370163701737017370173701837018370183702537025370253702537017300183001e3001e3001f30020300000000000000000000000000000000
011000000f1450f1450a1450a1450f1450f1450a1450a1450f1450f1450a1450a1450f1450f1050f1450a1050f1450f1450a1450a1450f1450f1450a1450a1450f1450f1450a1450a1450f1450f1050f1450a105
011000001b3451b34516345163451b3451b34516345163451b3451b34516345163451b3451b3051b3450a3051b3451b34516345163451b3451b34516345163451b3451b34516345163451b3451b3051b3450a305
011000000f1450f145001000f1450f1450a1450f1450010011145111450010011145111450c145111450010016145161450010016145161451110514145141051314513105111451310513145111451314500100
011000001b3451b345003001f345223461f346223061f3061d3451d3451d00520345243462034624306203062234522345233052434026345003002434500000223450030020345203051f3461b3461f3001b300
011000000f1450f145001000f1450f1450a1450f1450010011145111450010011145111450c1451114500100161451610516145161051a1451110516145001001314013140131401314500300003000030000300
011000001b3451b345003001f345223461f346223061f3061d3451d3451d00520345243462034624306203062234522305223452430526345260052234500000273461f346273461f3461f3001f3051f00500000
01100000181450010018145001001a1451a1451010518145161451614516100161451614514145161450010014145001001414500100161451614514105141451314500100141450010016145001001414500100
011000002434524305243450000026345263450000024345223461f346223461f3462230500000000000000020345243052034500000223452234500000203451f3461b3461f3461b34600000000000000000000
01100000181450010018145001001a1451a145101051814516145001001b145001001614500100151450010014145001001614500100141450010016145001001b1450010014145001001a1451a1051614500300
01100000243452430524345000002634526345000002434522345000002734500000223461f346223461f34624345000002234500000203450000022345000002734622346273462234626346223462634622346
0110000018625186252f6252f60518625186252f6250000018625186252f6252f6052f625000032f6250000018625186252f6252f60518625186252f6250000018625186252f6252f6052f625000032f62500000
0110000018625006052f6252f60518625186252f6251e00018625006052f6252f60518625186252f6252400018625006052f6252f60518625186252f6252b0052f625000002f625000002f625000002f6202f625
0110000018625006052f6252f60518625186252f6250000018625006052f6252f60518625186252f625000002f625006052f6252f6052f625006052f6251d305006052f6252f6252f6252f6252f6052f60500000
010200001b075190751d0701b0751f0701d075200701e070210751f07522070210752407022075260702406028065260552a055280452b0452a0352d0252b0152e0100e1000e1000e1000e100223050000000000
000200000f6000f6700e6400e600016400c6700b6000a6400a6600960009670086000866007670076200760007650066400667005600036700360003630036500264003610026300261002670016200160001620
000200001b4701b4701b4701b4701b4701b4701b4703f4603f4603f4603f4603f4503f4503f4503f4503f4403f4403f4403f4403f4303f4303f4203f4203f4103f4103f4103f4002f0002f000300003000000000
011000002977018605277702677018705247702677000700247002477018700227002277022770227702277518605186052f6052f60518605186052f6050000018605186052f6052f6052f605000032f60500000
012000001877418774180001b7741a774180001a7041a77419774197042f605207741f7741e7042f605000001877418774180001b7741a774186051a774197742f605207741f7711f7701f7701f7701f7751f705
01200000187741877218772187721b7711b7721b7721b7721a7711a7721a7721a77217771177721777217772187711877218772187721877218772187721877500605182341b2341823418204182002f60500000
000100000f4700e4700d4700b4700b47009470074703f6703f6703f6703f6603f6603f6503f6503f6503f6503f6503f6403f6403f6303f6303f6303f6203f6203f6203f6103f6103f6103f6103f6103f6003e600
010e00002f3402d3412d4002d3402c3412f3002c3402b3412b3002b3402a341060002a340293412b0002934028341000002834027341000002734026341000002630025301000000000000000000000000000000
010e00002b3402a3412d4002a340293412f30029340283412b3002834027341060002734026341040002634025341000002534024341000002434023341000000000000000000000000000000000000000000000
000400003f6703f6603f6503f6403f6303f62001600286702867027670266702666025660256602465024650236402364022630226302163020620206201f6101f6101e6101e6101d6101d6101d6001c6001c600
000400000c0700b0700a0700807007070070700d0000b0700b0700907007070060700607005070050700507004070040700407004070030700207002070020700203002030020200202002020020100201002000
01100000284442a4442c4442a444284442d4442d4452d400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002344425444284442544423444284442844500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000564006640066400664005640066400664005640056400564005640056400664006640056400564007640076400a6400d6400e6401064013640166401a6401c64022640236402964033640396403e640
011000000f040244000f0000f0400a0400f0000f040000000f040244000f0000f0400a0400f0000f040274000f040244000f0000f0400a0400f0000f040000000f04000000110400f00011040110400f04000000
011000000a040244000f0000a040050400f0000a040000000a040244000f0000a040050400f0000a040000000a040244000f0000a040050400f0000a040000000a040244000f0000a040050400f0000a04000000
011000000a040244000f0000a040050400f0000a040000000a040244000f0000a040050400f0000a040000000a040244000f0000a040050400f0000a040000000a040244000a0400a0000c040060000e04000000
011000000f040244000f0000f0400a0400f0000f040000000f040244000f0000f0400a0400f0000f040000000f040244000f0000f0400a0400f0000f040000000f040244000a0400a00008040070000704000000
011000002b440274062b4002b4002b4002b4002b44027406294402940000000274002940029400294400000027440294000000027400294002940027440274002744027440264402644026440264402744027400
011000002744622446274462244627440274402644526400264462244626446224462644622446264462244626446224462644622446264462244626446224460000000000000000000000000000000000000000
01200000187741877218772187721b7711b7721b7721b7721a7711a7721a7721a7721d7711d7721d7721d7721c7711c7721c7721c7721c7721c7721c7701c7752440218234182341823418204224002440000000
012000001d7541d7521d7521d752207512075220752207521f7511f7521f7521f7521d7511d7521d7521d7521d7541d7521d7521d7521d7521d7521d7501d755000001d154201541d15400000000000000000000
011000002944024400000000000000000000002944000000274400000000000000000000000000274400000026440000000000000000000000000026440000002b440000002b4402b4402b4402b4402944000000
011000002744622446274462244627446224462744622446274462244627446224462744622446274462244627446224462744622446274462244627446224460000000000000000000000000000000000000000
012000001f7541f7521f7521f75224751247522475224752237512375223752237521f7511f7521f7521f75223751237522375223752237521d1541c1541a1541d1541c154191541a1541c204192041a2041a204
012000001505410004100541500415054100041005415004150541000410054150041505410004100541500415054100041005415004150541000410054150041705417004120541800417054170041205400000
011000002744622446274462244627446224462744622446274462244627446224462744622446274462244627446224462744622446274462244627446224460000000000227422274224742247422674226742
011000002774227742277422774227742277422674226742247422474224742247422474224742267422674227742277422774227742277422774226742267422974229742277422774226742267422774227742
011000002674226742267422674226742267422474224702247422474224742247422474224742247422474224742247422474224742247422474224742247422474024740247402474500000000000000000000
011000002674226742267422674226742267422474224742227422274222742227422274222742247422474226742267422674226742267422674226742267402b7422b7022b7422b7422b7422b7422974200700
011000002774227742277422774227742277422774227742277422774227742277422774227742277422774227740277402774027745007000070000700007000070000700227422274224742247422674226742
011000002774227742277422774227742277422774227742277422774227742277422774227742277422774227740277402774027745007000070000700007000070000000000000000000000000000000000000
010b00001f0442404123044280412404429041260442b041280442f0412e0001e0001f00024000290002d000180011a0011d001280011900118001190011a0013000035000290002d00032000380003e0003f000
011000000c63500000000000c63530610306150c635000000c63500000000000c63530610306150c635000000c63500000000000c63530610306150c635000000c635000000c6350000030610306150c63500000
011000002d445284452844528445284452b40028400284452a44526445264002a445284452a400254452540026445234452344523445234450000000000234452c445000002c4450000028445000000000000000
0110000015045130051504500000150450000015045000000e045000000e04500000150450000015045000001004500000100450000010045000001004500000140450000014045000001004500000100050f005
012000001705417004120540000017054170041205400000170541700415054000001405417004100540000015054000001005400000150540000010054000001a0541a0041a0540000019054190541905419054
011000002d4452d445000002c4452d4452d4452f4452d4452c44528445284452844528445000002a405284052a4452a4452a405284452a4452a4452c4452a44528445000002a445000002c445000000000000000
010a00000c6350c605306000c635306203062030625306250c6350c605306000c635306203062030625306250c6350c605306000c635306203062030625306253062030625264053060030620306250000000000
011000001504500000150450000015045000001504500000100451000510045000001004500000100450000012045000001204500000120450000012045000001004500000120450000014045000001004500000
011000002d4452d445000002c4452d4452d4452f4452d4452c445284452844528445284450000000000000002a4452a4452a405284452a4452a4052c4452a4052d4450000028445000002d445000000000000000
010a00002d40028400284052647029470294752d4052b4702d4702d4752d4052b4702d4702d4751d4002b4702b475264052d4002d470304703047526405304003047030475254050000028405000000000000000
011000001504500000150450000015045000001504500000100451000510045000001004500000100050000012045120450000010045120451204512045140451504510005100451300515045150050000000000
011000000000000000306103061500000000003061030615000000000030610306150000000000306103061500000000003061030615000000000030610306150000000000306003060500000306153061530615
010a00002d40028400284052d47028470284752d4052b4702d4702d4752d4052d47028470284751d4002b4702b4753040030400304702d4702d4752b4002b4702d4702d47500000000002d4702d4750000000000
010a00002d40028400284052b47026470264752d405294702b4702b4752d4052b47026470264751d400294702947530400304002b4702d4702d4752b4002b4702d4702d47500000000002b4702b4750000000000
012000000c6250c625306100c6250c6250c625306100c6250c6250c625306100c6250c6250c625306100c6250c6250c625306100c6250c6250c625306100c6250c6250c625306100c6250c6250c625306100c625
01200000284752d475000002a4752c4752a4752a47528475284752d475000052a4752c4752a4752c4752d475284752d475000002a4752c4752a4752a475284752d4752f4752d4752f4752c4752c475000002d475
01200000264752f4750000028475264752d4752547528475264752f475254752c475234752c4752c4752a475254752d475000002a4752a4752c475284752a4752d4752f4752d4752f4752c4752f4752f4752f475
__music__
00 02 03 0c 44
00 04 05 0d 44
00 06 07 0d 44
00 08 09 0c 44
00 0a 0b 0c 44
02 06 07 0e 44
04 16 17 43 44
01 1d 21 30 44
00 1e 22 30 44
00 1f 25 30 44
00 20 26 30 44
00 1d 21 30 44
00 1e 22 30 44
00 1f 25 30 44
00 20 29 30 44
00 1d 2a 30 44
00 1e 2b 30 44
00 1f 2c 30 44
00 20 2d 30 44
00 1d 2a 30 44
00 1e 2b 30 44
00 1f 2c 30 44
02 20 2e 30 44
01 31 32 3a 44
00 31 32 3a 44
00 34 36 3a 44
02 37 39 3a 44
01 3b 35 43 44
00 3c 35 43 44
00 3b 35 43 44
04 38 35 43 44
01 3e 28 43 44
02 3f 33 43 44
01 3d 13 43 44
00 3d 13 43 44
00 3d 14 43 44
00 3d 23 43 44
00 3d 24 43 44
02 3d 27 43 44
04 12 42 43 44
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
