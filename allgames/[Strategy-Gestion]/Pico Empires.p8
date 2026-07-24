pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
a,c,d,e={},{},{},{}
function tostr(f)
return f..""
end
for g=-3,255 do
e[tostr(g)]=g
end
for g=-200,2500,10 do
e[tostr(g)]=g
end
function i(t,f)
for x in all(t) do
if(x==f) return true
end
end
function j(k)
local m,n,o=1,{},{}
while#k>0 do
while m<=#k do
local p=sub(k,m,m)
if p==","or(p==" "and m<=1) then
break
end
m+=1
end
if m>1 then
add(n,sub(k,1,m-1))
end
k=sub(k,m+1)
m=1
end
for f in all(n) do
add(o,e[f] or f)
end
return o
end
q=j"feedback,upkeep_fail,heal,building,killed,disabled,block,producing,selected,highlighted,blocked,exhaused,attacked,show_health,show_building,blocked_delay"
s=j"7,10,11,4,8,5,6,2,0,7,6"
for f in all(q) do
d[f]={}
end
function u(v,k,z)
for g,ba in pairs(k) do
z[v[g]]=ba
end
end
function bb(bc)
sfx(e[bc])
end
bd=0.03333
be,bf,bg,bh,bi,bj,bk,bl,bm,bn=64,32,16,16,8,9,0,4,6,90
bo,bp,bq=195,10,8
function br(bs,bt,bu)
if not bs[bt] then
add(d[bt],bs)
end
bs[bt]=bu
end
function bv() return true end
function bw()
palt(0,false)
palt(14,true)
end
function bx()
for g=1,bp do
local by={}
for bz=1,bq do
by[bz]=sget(g*bi+(bz-1),0)
end
c[g]=by
end
end
ca={
j"-1,-1",j"0,-1",j"1,-1",
j"-1,0",j"0,0",j"1,0",
j"-1,1",j"0,1",j"1,1",
}
cb=j"12,13,14,15"
cc={
cd=ca[4],
ce=ca[6],
cf=ca[2],
cg=ca[8],
}
ch={
cc.cf,
cc.cd,
cc.ce,
cc.cg,
}
ci={
cc.cd,
cc.ce,
cc.cf,
cc.cg,
}
cj=j"2,-3,15,11,8,7,-2,5,4,-1"
ck=j"woods,hills,fishes,whales,game,gold,oasis,cyprus,bears,mushrooms,rocks,sharks,pine,iron,oil,grapes,ruins"
cl=j"135,136,137,138,139,140,141,142,143,151,152,153,155,156,157,158,159"
cm={}
u(ck,cl,cm)
cn={
ruins=true
}
co={
j"0,0,0,0,0,0,5,0,0,0,0,0,0,0,5,0,5",
j"0,0,5,0,0,0,0,0,0,0,0,2,0,0,0,0,0",
j"0,0,0,0,0,3,0,0,0,0,0,0,0,5,0,0,0",
j"0,0,0,0,5,0,0,0,0,0,0,0,5,0,0,0,5",
j"0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0",
j"10,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,5",
j"0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0",
j"0,10,0,0,0,0,0,0,0,0,3,0,0,0,0,0,5",
j"0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,3,5",
j"0,0,18,0,0,0,0,0,0,0,0,3,0,0,0,0,0",
}
cp=j"sahara,australia,mongolia,brazil,peru,argentina,madagaskar,somalia,egypt,cameroon,iran,libya,new zealand,iceland,sweden,england,france,italy,mexico,cuba,china,spain,greece,ukraine,finland,russia,columbia,thailand,indonesia,korea,japan,india,pakistan,south arabia,canada,west usa,east usa,new england,ivory coast,south africa,norway,ireland,greenland,bangladesh,preussia,venice,vietnam"
cq=j"22,18,59,29,52,7,14,21,8,24,10,30,35,27,34,22,30,16,27,22,38,15,27,16,0,30,21,3,28,5,23,6,25,8,28,12,8,16,13,17,53,15,23,13,30,12,30,9,31,5,37,8,8,20,50,20,55,24,58,13,60,15,44,20,41,16,36,16,8,9,5,15,14,15,15,11,23,21,28,29,26,4,21,7,15,4,48,18,28,9,29,9,53,20"
cr={}
local cs=1
for p in all(cp) do
cr[p]={rx=cq[cs],ry=cq[cs+1]}
cs+=2
end
ct,cu,cv,cw={},{},{},{}
function cx(cy)
for x=0,be-1 do
for y=0,bf-1 do
cy(x,y)
end
end
end
function cz(x,y)
local da=ct[x] or{}
ct[x]=da
da[y]={
db=mget(x,y),
dc={},
dd=false,
}
end
function de(x,y)
return ct[x][y]
end
function df(x,y)
return not(x<0 or x>=be or y<0 or y>=bf)
end
function dg(x,y,dh)
return(x+dh[1])%be,y+dh[2]
end
di,dj,dk=7,8,7
dl={}
dm={
dn={
move="set rally",
stop="remove rally",
}
}
dp={
stop=function(dq)
return dr(dq)
end,
tax=function(dq)
return dq.ds
end
}
dt={
build=function(du,dq)
if(dq.que_num>0 or dq.dv>0) return false
return true
end,
}
dw=function(du,dq)
local cy=dp[du] or bv
return cy(dq)
end
ea={
build=function(du,dq)
eb(dq.player,"build",du)
end,
prop=function(du,dq)
eb(dq.player,du)
end,
tax=function(du,dq)
dq.ds=nil
end,
disband=function(du,dq)
if dq.ec then
ed(dq)
eb(dq.player,"nav")
else
dq.ec=true
bb"12"
end
end
}
ee={}
function ef(eg,du,...)
ea[eg](du,...)
end
function eh(eg,du,dq)
local cy=dt[eg] or dw
return cy(du,dq)
end
function ei(du)
return dl[du]
end
function ej(eg,du,dq)
local cy=ee[eg] or ei
return cy(du,dq)
end
ek=j"food,prod,gold"
el=j"big_food,big_prod,big_gold"
em={
prod="gold",
big_prod="big_gold",
}
function en(eo,ep)
for g=1,3 do
if fget(eo,g-1) then
return ek[g],(ep and el or ek)[g],ep and 3 or 1
end
end
end
function eq(x,y)
if(not df(x,y)) return nil
local da=de(x,y)
local er=da.db
local ep=false
local es=da.es
if es then
if es.et and not es.eu then
er,ep=es.def_sprite,true
else
er,ep=0,false
end
elseif da.ev then
er,ep=cm[da.ev],true
end
return en(er,ep)
end
function ew(x,y,ex,ey,player,bt)
local bt,ez=bt or{},false
for dh in all(ca) do
local dx,dy=dg(x,y,dh)
if df(dx,dy) then
local da=de(dx,dy)
local es=da.es
if es and es.et and es.player==player then
ez=(es.key==ey) or ez
if es.fa==ex and not bt[es] then
bt[es]=true
ez=ew(dx,dy,es.key,ey,player,bt) or ez
end
end
end
end
return ez
end
function fb(dq,fc,x,y)
local da=de(x,y)
if da.es then
return false
end
local fd=a[fc]
local fe=fd.ff
if fe then
return ew(x,y,fe,fe,dq.player)
end
return true
end
function fg(x,y)
local da=de(x,y)
for g=1,4 do
local dh,db,fh,fi=ch[g],di,dj,cj[da.db]
local fj,fk=dg(x,y,dh)
if df(fj,fk) then
db=de(fj,fk).db
end
if fi<cj[db] then
db=da.db
elseif fi<0 and cj[db]<0 then
fh=dk
end
da.dc[g]=c[db][fh]
end
end
fl,fm,fn,fo,fp,fq={},{},{},{},{},{}
function fr(fs)
local m={
gold=fs,
o=1,
ft={},
fu=j"1,1,1,1",
fv={
x=0,
y=0,
},
}
for g,f in pairs(fl) do
m.ft[g]=1
end
for f in all(fw) do
m[f]={}
end
return m
end
function fx(f,l,h)
return min(h,max(f,l))
end
function fy(t)
local fh=c[t]
for fz,ga in pairs(fh) do
pal(fz,ga)
end
end
function gb(gc)
for dc,gd in pairs(gc) do
pal(cb[dc],gd)
end
end
by=-1
function ge(da,gf,gg,gh,gi)
local db=da.db
if db~=by then
fy(db)
by=db
end
gb(da.dc)
map(gf+be,gg,gh,gi,1,1)
end
function gj(da,gf,gg,gh,gi)
if da.ev then
spr(cm[da.ev],gh,gi)
end
end
function gk(da,gf,gg,gh,gi)
if da.es then
gl(da.es,gh,gi)
end
end
function gm(fv,gn)
local go,gp=flr(fv.x),flr(fv.y)
local gq,gr=fv.x-go,fv.y-gp
for x=0,fv.w do
for y=0,fv.h do
local gf,gg=(go+x)%be,gp+y
if gg<bf then
local da=de(gf,gg)
if da.dd then
gn(da,gf,gg,(x-gq)*bi,(y-gr)*bi)
end
end
end
end
end
function gs(fv)
gm(fv,ge)
pal()
bw()
gm(fv,gj)
gm(fv,gk)
end
function gt(x,y,eo)
spr(eo,x,y)
end
function gu(x,y)
if x<0 then
x=x+be
elseif x>=be then
x=x-be
end
return x*bi,y*bi
end
function gv(gd,...)
for g=0,15 do
if g~=14 then
pal(g,gd)
end
end
spr(...)
pal()
bw()
end
function gw(gd,...)
spr(...)
end
gx=j"hp_progress,build_progress,produce_progress,food_progress"
gy=j"show_health,show_building"
gz=j"11,4,7,9"
function ha(dq,hb,x,y)
local hc=dq[gx[hb]]
if hc then
local w=bi-1
local sx=x
local hd=y+1
rectfill(sx,y,sx+w,hd,0)
rectfill(sx,y,sx+w*hc,hd,gz[hb])
return hd+1
end
return y
end
function he(dq,x,y)
for g=1,#gx do
y=ha(dq,g,x,y)
end
for g=0,(dq.hf or 0)-1 do
spr(dq.upkeep_fail and 252 or 251,x+(g%3)*3,y+flr(g/3)*3)
end
end
hg={}
u(q,s,hg)
function gl(dq,x,y)
local cy=gw
local gd=0
for g,f in pairs(hg) do
if dq[g] then
cy,gd=gv,f
break
end
end
local ry=y+dq.def_sprite_y
cy(gd,dq.def_sprite,x,ry,dq.def_sprite_w,dq.def_sprite_h)
local txt=dq.txt
if txt then
local w=max(#txt-1,0)*bl
print(txt,x+bi*0.5-w*0.5-1,ry+bi*0.5-bm*0.5,dq.txt_col or 7)
end
end
function hh(dq,x,y)
y+=bi
for g=1,#gy do
if dq[gy[g]] then
y=ha(dq,g,x,y)
end
end
end
function hi(dq,x,y)
gl(dq,x,y-dq.rz)
end
function hj(fv,dq)
local x,y=gu(dq.rx-fv.x,dq.ry-fv.y)
dq.selected=true
for hk in all(ch) do
hi(dq,x+hk[1],y+hk[2])
end
dq.selected=false
hi(dq,x,y)
end
function hl(dq,x,y)
gt(x,y,dq.bt=="shots"and 191 or 112)
end
function hm(a,fv,cy)
for g,dq in pairs(a) do
local x,y=gu(dq.rx-fv.x,dq.ry-fv.y)
cy(dq,x,y)
end
end
function hn(a,fv)
hm(a,fv,hi)
end
function ho(a,fv)
hm(a,fv,hh)
end
function hp(a,fv)
hm(a,fv,hl)
end
function hq(dq)
local x,y=dq.x,dq.y
for cc in all(dq.que) do
x+=cc[1]
y+=cc[2]
end
return x,y
end
function hr(dq,fv)
bw()
local sx,sy=dq.x,dq.y
local hs=1
for cc in all(dq.que) do
sx,sy=dg(sx,sy,cc)
local eo=(hs<=dq.que_num) and 223 or 207
local ht=de(sx,sy).dq
if ht and ht~=dq then
eo=(bk<0.5) and 48 or 222
end
spr(eo,gu(sx-fv.x,sy-fv.y))
hs=hs+1
end
end
function hu(dq,dx,dy,fv,eo)
local hv,hw,bu=eq(dx,dy)
local rx,ry=gu(dx-fv.x,dy-fv.y)
spr(eo,rx,ry)
if hv then
spr(a[hw].def_sprite,rx,ry)
end
end
function hx(dq,dx,dy,fv)
spr(254,gu(dx-fv.x,dy-fv.y))
end
function hy(dx,dy,dq,cy,...)
local es=de(dx,dy).es
if es and es.fa==dq.key and es.et and not es.eu then
hz(es,cy,...)
else
cy(dq,dx,dy,...)
end
end
function ia(dx,dy,dq,ib)
if ib>0 then
de(dx,dy).dd=true
else
ic(dq,dx,dy,ia,ib+1)
end
end
function ic(dq,x,y,cy,...)
for dh in all(ca) do
local dx,dy=dg(x,y,dh)
if df(dx,dy) then
cy(dx,dy,dq,...)
end
end
end
function id(dq)
local x,y=dq.x,dq.y
ic(dq,x,y,ia,0)
local da=de(x,y)
local ev=da.ev
if ev and cn[ev] then
while da.ev==ev do
ie(x,y)
end
local player=dq.player
player.gold+=flr(rnd(10)+1)*20
ig("big_gold",player,x,y)
bb"0"
end
end
function hz(dq,...)
ic(dq,dq.x,dq.y,hy,...)
end
function ih(dq,fv,eo)
hz(dq,hu,fv,eo)
end
function ii(dq,fv)
hz(dq,hx,fv)
end
function ij(player,fv,sx,sy)
local dq=player.ik
if dq then
local dh=ca[player.il]
local x,y=gu(sx+dh[1]-fv.x,sy+dh[2]-fv.y)
if player.im then
spr(player.im,x,y)
end
spr(player.io,x,y)
end
end
function ip(fv,x,y)
spr(fv.m_unit_sel,x+fv.m_ff*(1-max(0,cos(bk)))*2,y)
end
function iq(x,y,w,h,ir)
local is,it=x+w,y+h
rectfill(x,y,is,it,0)
rect(x,y,is,it,ir)
end
function iu(iv,fv,y,selected)
iq(fv.m_bg_x,y,2.25*bi,bi,5)
gl(iv,fv.m_unit_x,y)
he(iv,fv.m_status_x,y)
if selected then
ip(fv,fv.m_sel_x,y)
end
local iw=iv.ix
if(iw and(iv.feedback or iv.upkeep_fail or iv.block)) print(iw,fv.m_sel_x+fv.m_name_f*bl*#iw+bi*fv.m_name_sel_w,y,8)
end
function iy(txt,sx,sy,iz,ja,gn,jb)
local w=#txt*bl+bi+2
local x=sx+ja*w
iq(x,sy,w,bi,5)
gn(jb,sx+ja*bi,sy)
print(txt,x+iz*bi+1-ja,sy+2,7)
end
function jc(iv,fv,y,selected)
iy(iv[1],fv.m_info_x,y,fv.m_iname_sel_w,fv.m_iname_f,spr,iv[2])
end
function jd(iv,fv,y,selected,eg,dq)
local prop=dq.def_prop
local je=prop and dm[prop]
local jf=je and je[iv] or iv
local w=#jf*bl
local x=fv.m_name_x+fv.m_name_f*w
if dq.ds==iv and dq.produce_progress then
iy(flr(dq.produce_progress*100).."% "..(dq.jg and"no exit"or jf),fv.m_name_x,y-2,fv.m_name_sel_w,fv.m_name_f,spr,dq.producing and 250 or 249)
else
iq(x-1,y-1,w+1,7,0)
print(jf,x,y,eh(eg,iv,dq) and 7 or 5)
end
if selected then
ip(fv,x+fv.m_name_sel_w*w+bi*fv.m_name_f,y)
local jh=ej(eg,iv,dq)
if(jh) ji(jh,1,nil,0,fv,jc)
end
end
function ji(bt,jj,jk,y,fv,cy,...)
for g=jj,#bt do
local dq=bt[g]
cy(dq,fv,y,dq==jk,...)
y+=bi
end
return y
end
jl,jm,jn,jo=214,16,4,bi*4+5
jp,jq,jr,js,jt,ju,jv,jw,jx=j"civs,cities,military,outposts",j"civs,military",j"military,outposts,cities,civs,improvers,statics",j"military,outposts,cities",j"cities",j"shots",j"particles",j"outposts,cities,improvers,statics",j"cities,military,outposts"
function jy(dq)
local g=0
for eg in all(dq.jz) do
g=g+#ka[eg](dq)
end
return g
end
function kb(dq,hs)
for eg in all(dq.jz) do
local bt=ka[eg](dq)
for g=1,#bt do
if hs>1 then
hs-=1
else
return eg,bt[g]
end
end
end
end
function kc(player,dq,fv)
local hs=player.du
local it=bi-max(hs-5,0)*bi
local x=fv.m_rect_x
local kd=dq.jz
if dq.build_progress and not dq.et then
it+=2
iy(flr(dq.build_progress*100).."%",fv.m_corner_x,it,fv.m_name_sel_w,fv.m_name_f,spr,dq.building and 250 or 249)
it+=bi
end
local ke,du=kb(dq,player.du)
for eg in all(kd) do
local bt=ka[eg](dq)
if#bt>0 then
it=ji(bt,1,du,it+2,fv,jd,eg,dq)
end
end
iy(dq.key,fv.m_corner_x,0,fv.m_name_sel_w,fv.m_name_f,gl,dq)
end
function kf(player,fv)
local hs=player.kg
local sx=fv.m_rect_x
local x=sx
iq(x,-1,sx+jo,bj,5)
bw()
for g=1,jn do
local kh=player.o==g
local ki=(kh and 0 or jm)+g+jl
spr(ki,x+1+bj*(g-1),0)
end
iy(tostr(player.gold),fv.m_corner_x+fv.m_ff*jo,0,fv.m_name_sel_w,fv.m_name_f,spr,219)
local kj=max(hs-5,1)
local bt=player.kk
ji(bt,kj,bt[player.kg],bj,fv,iu)
end
function kl(dx)
if(dx>be*0.5) dx-=be
if(dx<-be*0.5) dx+=be
return dx
end
function km(player,x,y,bu)
local fv=player.fv
local x,y=x-fv.w*0.5+0.5,y-fv.h*0.5+0.5
local dx,kn=kl(x-fv.x),1-bu
fv.x,fv.y=(fv.x*kn+(fv.x+dx)*bu)%fv.ww,fx(fv.y*kn+y*bu,0,fv.wh)
end
function ko(kp,y,kq)
local kr,ks=bg*bi,bi
if(kp) then
return{ks,ks*2,1,0,kr,-1,0,0,1,0,1,65,247,-1,0}
else
return{kr-ks-bi,kr-ks*2-bi,-1,kr-bi,0,(bg-2.25)*bi,kr-jo,kr,kr,-1,0,64,246,0,1}
end
end
kt=j"m_unit_x,m_sel_x,m_ff,m_status_x,m_info_x,m_bg_x,m_rect_x,m_corner_x,m_name_x,m_name_f,m_name_sel_w,m_map_x,m_unit_sel,m_iname_f,m_iname_sel_w"
ku=j"l,r,t,b,w,h,ww,wh"
function kv()
local kq,y,kp=bh/#cv,0,true
for kw,player in pairs(cv) do
u(ku,{0,bg-1,y,bh-1,bg,kq,be,bf-kq},player.fv)
u(kt,ko(kp,y,kq),player.fv)
y+=kq
kp=not kp
end
end
function kx(o)
local t={}
for g,f in pairs(o) do
add(t,g)
end
return t
end
function ky()
local bt,kz=kx(cr)
for g,m in pairs(cu) do
while true do
local la=flr(rnd(#bt))
local lb=bt[la+1]
local lc=cr[lb]
if not kz or ld(lc,kz)<=16 then
m.le=lb
m.lc=lc
del(bt,lb)
kz=lc
break
end
end
end
end
fw=j"civs,military,cities,outposts,improvers,statics,particles,shots"
lf=j"foot,horse,boat,ship,air,rally"
lg={
j"1,0,0,1,1,1,0,1,1,3",
j"2,0,0,2,2,1,0,1,1,3",
j"0,1,0,0,0,0,0,0,0,1",
j"0,1,0,0,0,0,1,0,0,1",
j"1,1,1,1,1,1,1,1,1,1",
j"1,1,1,1,1,1,1,1,1,1",
}
lh={}
u(lf,lg,lh)
li={
j"settler,worker,inventor,thinker,scout,architect,engineer",
j"militia,guard,warrior,slinger,rider,canoe, longboat,sailboat,frigate,manowar,steamship,ironclad,battleship,destroyer,cruiser,carrier, archer,longbow,crossbow, spearman,fencer,knight, horseman,lancer, horsesling,horsearcher, catapult,ballista,cannon,fieldgun,howitzer,assaultgun,rocket, musket,rifleman,ranger,bazooka, cavalry,car,tank,armored,heavytank, balloon,biplane,bomber,supersonic",
j"city",
j"fort,tower,bunker,lab,university",
j"farm,workshop,market,garrison,archery,stables,docks,expansion,siege,barracks,mechanized,airfield,harbour,artillery",
j"wall,trench",
j"big_prod,big_food,prod,food,fail,big_gold,gold,pos",
j"club,pebble,arrow,spear,blade,sword,lance,bullet,bolt,grenade,boulder,ironarrow,ironball,shell,sabot,rocketp,nuke",
}
lj=j"def_hp,def_sprite,def_description,def_shot,def_armor,def_speed,def_dmg,def_knockback,def_rate,def_upkeep,def_range,def_cost,def_prop,def_pop_cost"
lk={
j"40,40,40,40,40,40,40,300,300,400,150,400,300,300,300,300,300,300,300,300,300,300,300,150,150,150,400,400,400,400,400,150,150,100,100,100,100,100,100,100,400,450,500,450,400,400,400,400,400,200,200,200,200,40,250,100,350,200,300,60,60,60,180,180,180,180,120,180,300,300,300,300,300, 500,750",
j"96,104,122,120,121,105,106,80,107,81,113,97,64, 65,66,67,68,69,70,71,72,73,119, 114,115,116, 82,83,84, 98,99, 100,101, 74,75,90,76,77,78,79, 85,86,87,88, 123,124,125,126,127, 91,92,93,94,128,130,162,226,165,225,129,163,164,131,132,133,134,160,166,192,193,194,195,224,161,227,220,221,236,237,253,219,235,118,174,167,168,169,175,170,171,172,173,183,184,185,186,187,188,189,190",
j"build cities,improve city,forts & research,nop,fast,modern era,bunkers & research",
j"nop,nop,nop,nop,nop,nop,nop,club,bullet,blade,pebble,club,club,blade,ironball,ironball,ironball,ironball,ironball,shell,shell,rocketp,bullet,arrow,arrow,bolt,spear,sword,sword,spear,lance,pebble,arrow,boulder,ironarrow,ironball,ironball,shell,shell,rocketp,bullet,bullet,bullet,rocketp,bullet,bullet,shell,bullet,sabot,ironball,bullet,sabot,rocketp,arrow,blade,arrow,bullet",
j"0,0,0,0,0,0,0,0,0,10,0,0,0,0,10,10,20,30,40,60,50,50,50,0,0,10,10,20,30,10,20,0,0,0,0,0,0,10,20,10,10,20,20,10,10,20,40,30,60,0,10,10,10,0,10,10,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,50",
j"20,20,20,20,30,30,30,20,25,20,20,60,40,40,60,50,40,50,40,40,50,60,50,20,20,18,20,20,18,50,40,60,55,15,15,15,20,20,25,30,25,30,30,30,50,70,30,80,40,10,100,130,150",
j"0,0,0,0,0,0,0,20,90,40,40,40,20,30,60,60,60,100,100,200,120,180,80,50,60,80,50,60,60,50,60,50,60,60,30,90,110,90,150,180,90,90,80,180,90,60,180,60,200,400,60,1600,80,10,30,20,50",
j"0,0,0,0,0,0,0,20,40,40,20,40,20,15,30,30,30,50,50,100,60,0,20,50,60,80,100,60,40,50,60,50,60,0,0,0,0,0,0,0,45,40,35,100,45,30,100,30,100,0,30,0,60,10,30,20,25",
j"30,30,30,30,30,30,30,30,90,30,15,30,30,30,45,30,15,30,30,60,30,120,20,15,15,30,30,20,15,30,30,15,15,90,30,90,80,45,75,120,60,45,30,90,60,15,60,10,45,300,10,600,10,30,45,30,30,30,15",
j"0,0,0,0,0,0,0,3,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,4,4,5,4,5,3,6,6,6,0,3,2,3,0,0",
j"10,10,10,10,10,10,10,10,11,10,16,10,10,10,16,19,12,15,15,18,22,32,10,17,19,16,12,10,10,12,12,16,17,21,22,24,26,27,29,30,14,17,19,19,12,12,11,12,11,3,17,6,19,13,13,19,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13,13",
j"125,75,100,100,40,150,200,100,100,150,150,250,200,210,225,240,280,200,240,270,300,340,370,160,180,200,160,190,240,300,350,250,300,300,320,340,350,370,390,420,150,200,250,220,250,270,340,320,380,300,340,370,430",
j"foot,foot,foot,foot,foot,foot,foot,foot,foot,foot,foot,horse,boat,boat,ship,ship,ship,ship,ship,ship,ship,ship,ship,foot,foot,foot,foot,foot,foot,horse,horse,horse,horse,foot,foot,foot,foot,foot,foot,foot,foot,foot,foot,foot,horse,horse,horse,horse,horse,air,air,air,air,rally",
j"1",
}
ll={}
u(lj,lk,ll)
lm=j"def_cost,def_pop_cost,def_hp,def_dmg,def_armor,def_speed,def_range,def_upkeep"
ln=j"220,230,212,228,244,213,229,245"
lo=j"1,1,1,10,10,20,10,-1"
lp=j"0,0,0,0,0,20,0,0"
lq={
def_dmg=function(lr,lt)
return lr.."/"..(lt.def_rate/30).."s"
end
}
lu={
"move",
"stop",
}
lv={
"confirm disband",
}
lw={
"disband",
}
lx={
"tax",
}
local ly={}
ka={
prop=function(dq)
return lu
end,
build=function(dq)
return lz[dq.key]
end,
disband=function(dq)
return dq.ec and lv or lw
end,
tax=function(dq)
if dq.et and not dq.eu then
return lx
end
return ly
end,
}
function ma(z,o)
for mb in all(o) do
add(z,mb)
end
end
lz={
worker=j"expansion,farm,workshop,market,garrison,archery,stables,docks,siege",
architect=j"expansion,farm,workshop,market,barracks,mechanized,airfield,harbour,artillery",
inventor=j"fort,tower,wall,lab",
engineer=j"bunker,trench,university",
settler=j"city",
}
mc=j"docks,garrison,archery,stables,siege,industry,barracks,mechanized,airfield,harbour,artillery"
md=j"0,0,0,0,0,1,0,0,0,0,0"
me=j"1,1,1,1,1,4,1,1,1,1,1"
mf=j"0,-50,-50,0,50,750,150,250,350,200,200"
mg={
j"canoe,longboat,sailboat,frigate,manowar",
j"warrior,spearman,fencer,knight",
j"slinger,archer,longbow,crossbow",
j"rider,horsesling,horseman,horsearcher,lancer",
j"catapult,ballista,cannon",
j"worker,settler,inventor,militia,architect,settler,engineer,guard",
j"musket,rifleman,ranger,bazooka",
j"cavalry,car,tank,armored,heavytank",
j"balloon,biplane,bomber,supersonic,carrier",
j"steamship,ironclad,battleship,destroyer,cruiser",
j"fieldgun,howitzer,assaultgun,rocket",
}
mh={}
u(mc,mg,mh)
dl.tax={{"generate gold",219}}
mi=j"build_tick,att_tick,upkeep_tick,tick"
mj=j"0,0,0,0"
mk=j"def_sprite_w,def_sprite_h,def_sprite_y,def_mv_z,def_mv_freq"
function ml(bt,fc)
for dq in all(bt) do
if dq.key==fc and dq.et then
return true
end
end
end
function mm(dq)
dq.et,dq.build_progress=false,0
end
function mn()
local hs=1
local mo=1
for mp in all(li) do
for mq in all(mp) do
local bt=fw[mo]
local dq={
bt=bt,
}
u(mi,mj,dq)
for key,bt in pairs(ll) do
dq[key]=bt[hs]
end
dq.mr=dq.def_hp
local jh={
{mq,dq.def_sprite}
}
if(dq.def_description) add(jh,{dq.def_description,214})
for g=1,#lm do
local ms=lm[g]
local bu=dq[ms]
local cy=lq[ms] or tostr
if(bu and bu~=lp[g]) add(jh,{cy(bu/lo[g],dq),ln[g]});
end
dl[mq]=jh
local jz={}
if dq.def_prop then
if(mq=="city") then
ma(jz,j"industry,tax,barracks,mechanized,airfield,harbour,artillery,garrison,archery,stables,docks,siege")
end
add(jz,"prop")
end
local mt=bt=="improvers"
dq.mu=mt
if(mq=="lab") ma(jz,j"research_garrison,research_archery,research_stables,research_docks,research_siege,research_industry")
if(mq=="university") ma(jz,j"research_barracks,research_mechanized,research_airfield,research_harbour,research_artillery")
if(dq.def_upkeep and dq.def_upkeep~=0) add(jz,"disband")
if(lz[mq]) add(jz,"build")
dq.jz=jz
a[mq]=dq
hs+=1
end
mo+=1
end
for g,fd in pairs(a) do
u(mk,fget(fd.def_sprite,7) and(j"1,2,-3,0,0") or(j"1,1,-1,2,12"),fd)
if(fd.bt=="improvers") fd.ff="city"
if fd.bt=="particles"then
fd.life,fd.dz=1,5
end
end
a.expansion.fa="city"
local city=a.city
u(j"range,pop,prod,gold,food",j"1,1,0,0,0",city)
city.txt="1"
for mv,g in pairs(mc) do
local f=mh[g]
local mw,mx,my,mz,hs={},{},{},{},"research_"..g
fm[g]=hs
local bi,na=me[mv],md[mv]
local nb=#f/bi
for bz=1,nb do
local bt={}
for y=max(1,(bz-1)*bi+na),bz*bi do
add(bt,f[y])
end
mw[bz]=bt
if bz<nb then
local nc=bz*150+mf[mv]
add(my,nc)
mx[bz]={g.." lv"..(bz+1)}
local nd={{tostr(nc),219}}
for f in all(dl[f[bz*bi+1]]) do
if(f[2]~=220) add(nd,f)
end
mz[bz]=nd
end
end
fl[hs],fn[hs],fo[hs],fp[hs],fq[hs]=mw,mx,my,mz,a[g] and g or nil
end
for key,bt in pairs(fn) do
ka[key]=function(dq)
local player=dq.player
if dq.et and not dq.eu and(key~="research_industry"or player.ne) then
return bt[player.ft[key]] or ly
end
return ly
end
dt[key]=function(du,dq)
local player=dq.player
return(not fq[key] or ml(player.improvers,fq[key])) and player.gold>=fo[key][player.ft[key]]
end
ea[key]=function(du,dq)
local player=dq.player
local nf=player.ft[key]
player.gold-=fo[key][nf]
player.ft[key]+=1
mm(dq)
for dq in all(player.improvers) do
if dq.key==fq[key] then
mm(dq)
end
end
if nf>=#bt then
player.ne=true
end
end
ee[key]=function(du,dq)
return fp[key][dq.player.ft[key]]
end
end
for key,bt in pairs(mh) do
ka[key]=function(dq)
local player=dq.player
if(not a[key] or ew(dq.x,dq.y,dq.key,key,player)) and dq.et and not dq.eu then
local ng=fm[key]
if ng then
return fl[ng][player.ft[ng] or 1]
else
return bt
end
end
return ly
end
dt[key]=function(du,dq)
return dq.ds~=du
end
ea[key]=function(du,dq)
dq.ds=du
bb"13"
end
end
li,lk,ll,cq,cp=nil,nil,nil,nil,nil
end
function nh(dq,ni,nj)
if df(ni,nj) then
local da,nk=de(ni,nj),lh[dq.def_prop]
local es=da.es
local nl=(es and fget(es.def_sprite,6) and es.player~=dq.player) and 5 or 0
local my=nk[da.db]
if(my>0) then
return nl+my
else
return(es and es.player==dq.player) and 3 or nil,true
end
end
end
function nm(player,dq)
player.dq=dq
if dq then
if(dq.nn) dq.rz+=4
km(player,dq.x,dq.y,1)
end
end
function no(t,z)
local np=z or{}
for g,f in pairs(t) do
np[g]=f
end
return np
end
function nq(fc,player,dq)
no(a[fc],dq)
add(player[dq.bt],dq)
if(dq.x) id(dq)
end
nr=j"key,x,y,rx,ry,rz,que,que_num,player"
function ns(fc,player,x,y)
local dq={
dv=0,
dx=0,
dy=0,
nn=0,
}
u(nr,{fc,x,y,x,y,0,{},0,player},dq)
nq(fc,player,dq)
local da=de(x,y)
da.dq=da.dq or dq
dq.nt=da
return dq
end
function nu(fc,player,x,y)
local dq={
build_progress=0,
}
u(nr,{fc,x,y,x,y,0,{},0,player},dq)
local da=de(x,y)
if da.es then
ed(da.es)
end
nq(fc,player,dq)
dq.mr,dq.hp_progress=0,0
dq.nv,da.es=da,dq
end
function ig(fc,player,x,y)
local dq={
rx=x,
ry=y,
rz=0,
dx=0,
dy=0,
dz=0,
player=player,
}
nq(fc,player,dq)
return dq
end
nw=j"sx,sy,rx,ry,rz,prg,dmg,dist,knockback,target,player"
function nx(fc,player,x,y,target,dmg,knockback,dist)
local dq={}
u(nw,{x,y,x,y,0,0,dmg,dist,knockback,target,player},dq)
nq(fc,player,dq)
end
function ed(dq)
local player=dq.player
del(player[dq.bt],dq)
if player.dq==dq then
nm(player,nil)
eb(player,"nav")
end
ny(dq)
end
function nz(oa,x,y)
de(x,y).ev=oa
end
function ie(x,y)
local da=de(x,y)
for g,oa in pairs(ck) do
if rnd(100)<co[da.db][g] then
nz(oa,x,y)
break
end
end
end
function ob()
for g,m in pairs(cu) do
local x,y=m.lc.rx,m.lc.ry
for dq in all(j"settler,scout") do
ns(dq,m,x,y)
end
u(j"txt,life,dz,txt_col",{m.le,5,2,2},ig("pos",m,x,y))
eb(m,"nav")
end
end
function oc(od)
local oe=flr(rnd(25))*20
for g=1,od do
local player=fr(oe)
player.of=g-1
add(cu,player)
add(cv,player)
end
end
function _init()
mn()
bx()
oc(2)
kv()
ky()
cx(cz)
cx(ie)
cx(fg)
ob()
end
function og(dq,dh)
local dx,dy=dh[1],dh[2]
dq.dx,dq.dy=dx,dy
dq.dv=sqrt(abs(dx)+abs(dy))*(nh(dq,dg(dq.x,dq.y,dh)) or 5)
end
function oh(dq)
return dq.que[#dq.que]
end
function oi(dq)
local oj=#dq.que
del(dq.que,dq.que[oj])
dq.que_num=min(dq.que_num,oj-1)
end
function dr(dq)
return dq.que_num>(dq.cc and 1 or 0)
end
function ok(dq)
for cc in all(dq.que) do
if dq.cc~=cc then
del(dq.que,cc)
end
end
dq.que_num=#dq.que
end
function ol(dq,dx,dy)
add(dq.que,{dx,dy})
end
function om(dq,cc)
del(dq.que,cc)
dq.que_num-=1
end
function on(dq)
local oo=#dq.que
dq.que_num=oo
end
function op(dq)
local oq=dq.que_num+1
for g=oq,#dq.que do
del(dq.que,dq.que[oq])
end
end
function os(dq,x,y,ot,ou)
local ov,hv,ow,bu,ox,oy=0
while ov<ot do
ov+=1
local oz=ou or(flr(rnd(9))+1)
local pa,pb=dg(x,y,ca[oz])
if df(pa,pb) then
local da=de(pa,pb)
if not da.exhaused then
local pc=da.es
if pc and pc.fa==dq.key then
local pd,pe,pf,fj,fk=os(pc,pa,pb,ot)
if pf and(not bu or(pf>bu)) then
bu,hv,ow,ox,oy=pf,pd,pe,fj,fk
end
else
local pd,pe,pf=eq(pa,pb)
if pf and(not bu or(pf>bu)) then
bu,hv,ow,ox,oy=pf,pd,pe,pa,pb
end
end
elseif da.exhaused<bn then
return nil,"fail",0,pa,pb
end
end
end
return hv,ow,bu,ox,oy
end
function pg(dq,pop)
dq.pop,dq.txt=pop,tostr(pop)
end
function ph(dq,g)
if(not dq.et) return
local x,y,player=dq.x,dq.y,dq.player
dq.tick+=1
if dq.tick>bn then
dq.hf=g-1
local pop=dq.pop
dq.food-=pop-0.5
local pi=15+pop*pop*10
if dq.food>pi then
dq.food-=pi
pg(dq,dq.pop+1)
elseif dq.food<-pi then
pg(dq,max(dq.pop-1,1))
dq.food=0
end
local ds=dq.ds
for g=0,dq.pop do
local hv,ow,bu,dx,dy=os(dq,x,y,9,(g==0) and 5 or nil)
if(hv) then
br(de(dx,dy),"exhaused",bn)
if not ds then
hv,ow=em[hv] or hv,em[ow] or ow
end
dq[hv]+=bu
end
if(ow) ig(ow,player,dx,dy)
end
dq.food_progress,dq.tick=fx(dq.food/pi,0,1),0
if ds then
local pj=a[ds]
local pk=fx(dq.prod/pj.def_cost,0,1)
if pk~=dq.produce_progress then
br(dq,"producing",10)
dq.produce_progress=pk
bb"10"
end
dq.jg=false
if dq.prod>=pj.def_cost then
if(de(x,y).dq) then
dq.jg=true;
if not dq.blocked_delay then
br(dq,"blocked",5)
br(dq,"blocked_delay",300)
sfx"14"
end
return
end
if pj.def_pop_cost then
local pl=dq.pop-pj.def_pop_cost
if pl>0 then
pg(dq,pl)
else
return
end
end
local pm=ns(ds,player,x,y)
bb"11"
if pm.bt=="military"then
for cc in all(dq.que) do
x,y=dg(x,y,cc)
if nh(pm,x,y) then
ol(pm,cc[1],cc[2])
else
break
end
end
on(pm)
end
dq.prod,dq.ds,dq.produce_progress=0,nil,nil
end
else
dq.produce_progress=nil
end
player.gold+=dq.gold
dq.gold=0
end
end
function pn(dq)
dq.rx+=dq.dx*bd
dq.ry+=dq.dy*bd
dq.rz+=dq.dz*bd
dq.life-=bd
if(dq.life<0) ed(dq)
end
function po(dq,bu)
local mr,pp=dq.mr,dq.def_hp
if mr<pp or bu<0 then
dq.mr=min(mr+bu,pp)
dq.hp_progress=(dq.mr<pp) and dq.mr/pp or nil
return true
end
end
function pq(dq,pr)
if dq.nn then
dq.nn=max(0,dq.nn-pr/dq.def_hp*2)
end
end
function ps(dq,dmg)
if(dq.eu) return
local pt=dq.def_hp
po(dq,-dmg)
dq.ix=tostr(-dmg)
if dq.mr<=0 then
local pop=dq.pop
if pop and pop>1 then
pg(dq,pop-1)
dq.mr=pt
bb"5"
else
if dq.mu then
br(dq,"disabled",9000)
dq.eu,dq.et=true,false
else
br(dq,"killed",30)
dq.eu=true
end
bb"3"
end
end
end
function pu(dq)
dq.prg+=bd*2
local prg=dq.prg/max(dq.dist,1)
local pv=1-prg
local target=dq.target
local pw,px=target.rx,target.ry
dq.rx,dq.ry,dq.rz=dq.sx*pv+pw*prg,dq.sy*pv+px*prg,-sin(prg*0.5)*bi*0.75
if prg>=1 then
local py=(target.def_armor or 0)/10
local dmg=max(1,dq.dmg-py)
pq(target,max(0,dq.knockback-py))
ps(target,dmg)
if dmg>1 then
bb"1"
br(target,"feedback",10)
else
bb"9"
br(target,"block",5)
end
br(target,"attacked",180)
br(target,"show_health",31)
ed(dq)
end
end
function ld(pz,b)
return max(abs(kl(b.rx-pz.rx)),abs(b.ry-pz.ry))
end
function qa(dq,range)
local qb,target=9999
for bt in all(jr) do
for player in all(cu) do
if player~=dq.player then
for fd in all(player[bt]) do
local dist=ld(dq,fd)
local qc=fd.def_range
if(qc<=0) qc=999
if dist<=range and not fd.eu and qc<=qb then
range,target,qb=dist,fd,qc
end
end
end
end
end
return target
end
function qd(dq)
if dq.eu then return end
local pp=a[dq.key].mr
local build_progress=dq.build_progress
if build_progress then
dq.build_tick+=1
if dq.build_tick>30 then
if not dq.attacked then
local bu=4+flr(pp*0.005)
po(dq,bu)
if not dq.building then
br(dq,"building",5)
br(dq,"show_building",31)
bb"8"
end
build_progress+=bu/pp
if build_progress>=1 then
dq.build_progress,dq.et=nil,true
else
dq.build_progress=build_progress
end
end
dq.build_tick=0
end
end
end
function qe(dq)
if(dq.eu) return
dq.upkeep_tick+=1
local player=dq.player
if dq.upkeep_tick>60 then
dq.upkeep_tick=0
local hf=dq.def_upkeep
local qf
if hf~=0 then
local pc=de(dq.x,dq.y).es
qf=(pc and pc.et and not pc.qg) and(pc.player==player or pc==dq)
dq.hf=qf and 1 or hf
end
if dq.hf and dq.hf>0 then
player.gold-=dq.hf
if player.gold<0 then
ps(dq,2)
br(dq,"upkeep_fail",10)
player.gold=0
bb"7"
return
end
end
if qf and not dq.attacked then
if po(dq,4) then
if not dq.heal then
br(dq,"heal",5)
br(dq,"show_health",30)
bb"6"
end
end
end
end
end
function qh(dq)
if(dq.eu) return
dq.att_tick+=1
if dq.att_tick>dq.def_rate then
local range=dq.def_range
local dmg=dq.def_dmg
if dmg and dmg~=0 then
local target=qa(dq,range/10)
if target then
bb"2"
nx(dq.def_shot,dq.player,dq.rx,dq.ry,target,dmg/10,dq.def_knockback/10,ld(dq,target))
if dq.dv then
dq.rz+=3
end
end
end
dq.att_tick=0
end
end
function ny(dq)
if dq.nv then
dq.nv.es=nil
local player=dq.player
if#player.cities<=0 then
player.qi=true
end
end
local nt=dq.nt
if nt and nt.dq==dq then
nt.dq=nil
end
end
function qj(dq)
if(dq.eu) then
dq.rz=0
end
local dv=dq.dv
if dv~=0 then
local nn=dq.nn+(dq.feedback and 0 or dq.def_speed*bd/100)
if nn>dq.dv then
nn=0
dq.x,dq.y=(dq.x+dq.dx)%be,dq.y+dq.dy
id(dq)
og(dq,ca[5])
local cc=dq.cc
if cc then
om(dq,cc)
dq.cc=nil
end
end
local prg=nn/dv
dq.rx,dq.ry,dq.rz=dq.x+dq.dx*prg,dq.y+dq.dy*prg,abs(sin(prg*0.5*dq.def_mv_freq))*dq.def_mv_z
dq.nn=nn
else
dq.rz=max(0,dq.rz-1)
if dq.que_num>0 then
local qk=dq.que[1]
local da=de(dg(dq.x,dq.y,qk))
if not da.dq then
ny(dq)
dq.nt,da.dq=da,dq
og(dq,qk)
dq.cc=qk
elseif not dq.blocked_delay then
br(dq,"blocked",5)
br(dq,"blocked_delay",180)
sfx"14"
end
end
end
end
function ql(fv,qm,cy,qn,...)
for kw,player in pairs(cu) do
if(qn) qn(player,...)
for ke,bt in pairs(qm) do
cy(player[bt],fv)
end
end
end
function qo(cy,qm)
for kw,player in pairs(cu) do
for ke,bt in pairs(qm) do
for g,dq in pairs(player[bt]) do
cy(dq,g)
end
end
end
end
function qp(player,qq,qr,eo,qs)
player.ik,player.il,player.io,player.im=qq,qr,eo,(not qs) and 222 or nil
end
function qt(dx,dy)
for oz,dh in pairs(ca) do
if dx==dh[1] and dy==dh[2] then
return oz
end
end
return nil
end
function qu(qv,w)
return(((qv)-1)%w)+1
end
function qw(player,qx,qy)
local o=player.o
o=qu(o+qx,jn)
local bt=jp[o]
player.o=o
player.fu[o]=qu(player.fu[o]+qy,#player[bt])
end
function qz(player,cc)
local dq=player.dq
local du=player.du
player.du=qu(du+cc,jy(dq))
dq.ec=false
end
ra=j"-1,1,0,0,0,0,-1,1"
rb=j"0,-1,1"
function rc(player,ga)
if btnp(4,player.of) then
eb(player,ga)
return true
end
end
function rd(player)
local o=player.o
local bt=jp[o]
local re=player[bt]
local rf=fx(player.fu[o],1,#re)
player.fu[o],player.kk,player.kg=rf,re,rf
nm(player,re[rf])
end
rg={
nav=function(player)
rd(player)
end,
unit_menu=function(player)
player.dq.ec=false
end,
stop=function(player)
local dq=player.dq
if dq then
ok(dq)
eb(player,"unit_menu")
end
end,
}
rh={
move=function(player)
qp(player)
end,
nav=function(player)
player.du=1
end,
}
function eb(player,ri,jb)
local rj=rh[player.ri] or bv
rj(player)
player.rk,player.ri,player.rl=false,ri,jb
local rm=rg[ri] or bv
rm(player)
end
rn={
nav=function(player,fv)
local dq=player.dq
if(dq) hr(dq,fv)
end,
unit_menu=function(player,fv)
hr(player.dq,fv)
end,
move=function(player,fv)
local dq=player.dq
hr(dq,fv)
ij(player,fv,hq(dq))
end,
}
ro={
unit_menu=function(player,fv)
hj(fv,player.dq)
end,
build=function(player,fv)
local dq,fd=player.dq,a[player.rl]
local fe=fd.ff
if fe then
for pc in all(player[a[fe].bt]) do
ii(pc,fv)
end
end
if fd.pop or fd.fa then
ih(dq,fv,fe and 239 or 238)
end
ij(player,fv,dq.x,dq.y)
end,
nav=function(player,fv)
if(player.dq) hj(fv,player.dq)
end,
}
rp={
nav=function(player,fv)
kf(player,fv)
end,
unit_menu=function(player,fv)
if player.dq.jz then
kc(player,player.dq,fv)
end
end,
}
function rq(player)
if btnp(5,player.of) then
player.rk=true
end
return player.rk
end
function rr(player)
local eo=(bo+5)
eo=205
if not btn(5,player.of) then
return true
end
qp(player,player.dq,5,eo,true)
end
rs={
nav=function(player)
local kw=player.of
for g=1,4 do
if btnp(g-1,kw) then
qw(player,ra[g],ra[g+4])
rd(player)
end
end
local dq=player.dq
if dq then
if btnp(5,kw) then
eb(player,"unit_menu")
end
km(player,dq.rx,dq.ry,0.1)
end
end,
unit_menu=function(player)
local kw=player.of
local dq=player.dq
if dq then
local jz=dq.jz
if jz then
for g,rt in pairs(rb) do
if(btnp(g,kw)) qz(player,rt)
end
if btnp(5,kw) then
local eg,du=kb(dq,player.du)
if eh(eg,du,dq) then
ef(eg,du,dq)
end
end
end
km(player,dq.rx,dq.ry,1)
end
rc(player,"nav")
end,
move=function(player)
local dq=player.dq
if dq then
local dx,dy=0,0
local kw=player.of
for g,rt in pairs(ci) do
if(btn(g-1,kw)) then
dx+=rt[1]
dy+=rt[2]
end
end
local ou=qt(dx,dy)
local x,y=hq(dq)
if(dx~=0 or dy~=0) and ou then
local my=nh(dq,dg(x,y,ca[ou]))
local ru=oh(dq)
local rv=(ru~=dq.cc and ru and ru[1]==-dx and ru[2]==-dy)
local eo=rv and 206 or(bo+ou)
local rw=rv and 5 or ou
qp(player,dq,rw,eo,my)
if my and btnp(5,kw) then
if rv then
oi(dq)
else
ol(dq,dx,dy)
end
end
player.rk=false
else
if rq(player) then
if rr(player) then
on(dq)
return"nav"
end
else
qp(player,dq,5,bo+5,true)
end
end
km(player,x,y,1)
end
if rc(player,"unit_menu") then
op(dq)
end
end,
build=function(player)
local dq,fc=player.dq,player.rl
local sa=fb(dq,fc,dq.x,dq.y)
if sa and rq(player) then
if rr(player) then
nu(fc,player,dq.x,dq.y)
ed(dq)
bb"4"
return"nav"
end
else
qp(player,dq,5,255,sa)
end
rc(player,"unit_menu")
end
}
sb={
killed=ed,
disabled=function(dq)
dq.eu=false
mm(dq)
end,
}
function _update()
for g,bt in pairs(d) do
for bs in all(bt) do
bs[g]-=1
if bs[g]<=0 then
local cy=sb[g] or bv
cy(bs)
bs[g]=nil
del(bt,bs)
end
end
end
for kw,player in pairs(cv) do
local ri=rs[player.ri](player)
if(ri) eb(player,ri)
end
qo(qj,jq)
qo(qd,jw)
qo(qe,jx)
qo(qh,js)
qo(ph,jt)
qo(pu,ju)
qo(pn,jv)
bk=(bk+bd)%1
end
function sc(player,sd)
pal(0,(player==sd) and 0 or 8)
end
function _draw()
cls()
for kw,player in pairs(cv) do
palt()
palt(0,false)
by=-1
local fv=player.fv
local l,t=fv.l*bi,fv.t*bi
clip(l,t,fv.w*bi,fv.h*bi)
camera(-l,-t)
gs(fv)
bw()
ql(fv,jq,hp,sc,player)
ql(fv,ju,hp,sc,player)
pal(0,0)
bw()
local ri=player.ri
local se=rn[ri] or bv
se(player,fv)
bw()
ql(fv,jr,ho)
ql(fv,jq,hn)
local se=ro[ri] or bv
se(player,fv)
ql(fv,jv,hn)
ql(fv,ju,hn)
local se=rp[ri] or bv
se(player,fv)
if player.qi then
print("game over",44,28,7)
end
clip()
camera()
end
if(stat(0)>975) print(stat(0),40,123,7)
end
__gfx__
0000000049a4999acc1c111c5d60555d56746667c77cccc733b4bb3b001000004335344349999449cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa1111111166666665666666667c7c7c7cbbbbbbb3001010104444444499999999cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa111111115677776566666666c7c7c7c7bbbbbbbb010101014444444499999999cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa1111111156777765666666667c7c7c7cbbbbbbbb101010104444444499999999cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa111111115677776566666666c7c7c7c7bbbbbbbb010101014444444499999999cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa1111111156777765666666667c7c7c7cbbbbbbbb101010104444444499999999cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa111111115666666566666666c7c7c7c73bbbbbb3010101014444444499999999cccccccc0000000000000000000000000000000000000000
00000000aaaaaaaa1111111155555555666666667c7c7c7c33bbbb33101010104444444499999999cccccccc0000000000000000000000000000000000000000
00000000cccccccccccccccccccccccc1233333333333321123333213333332112333333123333211233332133333333123333333333332112333321dcccccce
00000000dccc1122222222222211ccce2333333333333332233333323333333223333333233333322333333233333333233333333333333223333332dc1221ce
00000000ddc122333333333333221cee3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333d123321e
00000000dd12333333333333333321ee3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333d233332e
00000000d1233333333333333333321e3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333d233332e
00000000d1233333333333333333321e3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333d123321e
00000000d2333333333333333333332e3333333333333333233333322333333223333332233333333333333223333332233333333333333233333333d412214e
00000000d2333333333333333333332e3333333333333333123333211233332112333321123333333333332112333321123333333333332133333333df4444fe
00000000d2333333333333333333332e33333333333333331233333333333321d2333321cccccccc1233332eccccccccd2333333123333333333332e33333321
00000000d2333333333333333333332e33333333333333332333333333333332d2333332222222222333332e22222222d2333333233333333333332e33333332
00000000d2333333333333333333332e33333333333333333333333333333333d2333333333333333333332e33333333d2333333333333333333332e33333333
00000000d2333333333333333333332e33333333333333333333333333333333d2333333333333333333332e33333333d2333333333333333333332e33333333
00000000d2333333333333333333332e33333333333333333333333333333333d2333333333333333333332e33333333d2333333333333333333332e33333333
00000000d2333333333333333333332e33333333333333333333333333333333d2333333333333333333332e33333333d2333333333333333333332e33333333
00000000d2333333333333333333332e23333333333333323333333223333333d2333333233333333333332e33333332d2333332222222222333332e22222222
00000000d2333333333333333333332e12333333333333213333332112333333d2333333123333333333332e33333321d2333321444444441233332e44444444
e6e6e6e6d2333333333333333333332eccccccccccccccccccccccccd233332ed233332eccccccccccccccccccccccced23333211233332e0000000000000000
6e6e6e6ed2333333333333333333332edc1221cedc122222222221ced233332ed233332e22222222dcc1222222221ceed23333322333332e0000000000000000
e6e6e6e6d1233333333333333333321ed123321ed12333333333321ed233332ed233332e33333333dd123333333321eed23333333333332e0000000000000000
6e6e6e6ed1233333333333333333321ed233332ed23333333333332ed233332ed233332e33333333d12333333333321ed23333333333332e0000000000000000
e6e6e6e6d4123333333333333333214ed233332ed23333333333332ed233332ed233332e33333333d23333333333332ed12333333333321e0000000000000000
6e6e6e6edd41223333333333332214eed233332ed12333333333321ed123321ed233332e33333333d23333333333332ed41233333333214e0000000000000000
e6e6e6e6ddf411222222222222114feed233332ed41222222222214ed412214ed233332e22222222d23333322333332edd412222222214ee0000000000000000
6e6e6e6edfff4444444444444444fffed233332edf444444444444ffdf4444fed233332e44444444d23333211233332edff4444444444ffe0000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee79797eeee79eeee7e7eeeeeee2eeeeeeeeeeeeeeeeeeeeeeeefceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7797979ee769ee9ee7e7eeeee26eeeeeeeeeeeeeeeeeeeeeeeeffeeeeeeeeeee55eeeeee6aeeeeeeefceee56eeeeeb88
eeeeeeeeeeeeeeeeeee97eeeee7969ee7796979e7667e697e2e2eeeeee62e7eeee6eeeeee6eeeeeeeee5699eeeeeee6efc5eeeeefceeeee6e33e55ee77eb333e
eeeeeeeeeeee4ee4ee6967eee769697eee96969766692697e2e2e06672066eeee252e7eee65eeeee77e945eeff46747688e44477ffe3355eed55eeeeeb33b511
eeeeceeecfe9ee9ee669667ee7696977949e9e9e55e92e9ee555555ee6255e7e72566ee7666e8e8e779e4e5efce55e6e87467e4e33655eeee1ddddee377ee5fc
eeefeeeee59559eeeee9eeee94e9e9ee4040404466666666666666665500660ee555555e5553535e66ee49e599e999ee6e45654e44ebbeee6111166e65555551
e49f5e4ee444444ee444404e4040404e4404044e6060606e660606066666666666666666d666666d444444999944449e6d4d5e4e3b53353b1111111e11111111
e94444eeee4444eeee4444eee44444eee44444eee44444eee666666ee556565e5656565eed5555dee55ee55ef4fee55edee444ee55eeee55e555556ee556e55e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeef4f4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeee6e7eeeee5e6eee885e6eee55eeeeee6aeeeeeeeeeeeeee55eeeeeeeeeeeeeeeeeeeee24f7f4eeeebbbbedeeeeeeeeeeeeeeeeeeeeeee
eeefce4eeeefce4ee7e6ce4eeee5ce6eee85ce6ee5fc5eeee6fceee6eeee33eee5fce5eeeeeeeeee55eeeeeee4f4f4fe2ee5ee5e1deefcee5eeeeeee00e01cee
eeeffe4eeeeffe4eee46fe4eeee5fe67eee5fe6eeeffeeeeee445555eee3fce64333bbbeeeeeeeeefce00000e24f4f4e225fc5e771dd77dd15e556eee0000101
eefffffeee5995f4ee4a55fee44465feed6d6767e8447d7eebbf33feeeb45555e64f3f3eeeeeeeee97054440ee2424eeb3bbbb34e1111d1e111111151100000e
efeffeeeefe99ee4ee9aa4eee4645eeeed6d55fee8f8efeeee33eeee53bf33fee665e5eeeeeeeeee99e4054eeee24eeeee333337eee11eee5511115eee0000ee
eee44eeeeee99eeeee99e4eeee499eeeed6d5eeeee6e6eeeeebebeeeeeeeeeeeee5e5eeeeeeeeeee44d45e4eeee66eeee5eee3eeeee11eeeee3158eeee000eee
eefeefeeeefeefeeefeefeeeeefeefeeee5ee5eee5ee5eeee5be5eeeeeeeeeeee45e4eeeeeeeeeeefdfe44eeeee77eeeeeeeee5eee11eeeeeee5eeeee000eeee
eee2eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4e3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee8882ee4efceeeee4cee6eee866eeee6efce44e4e3ceeeeeeeeeeeeeeeeeeeee7e99eeeeee99eeeeee44e66eee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeefce5e4effeeeee4fe5eee5fceeeeefeffefeefeffe4eeeeeeeeeeeeeeeeee77e9c555eee9c11185e4ce55eeefceeeeeeeeeeeeeeeeeeeeedeeeeeeeeeeeee
eeeffefefffffc4eee95fc4ee6dec6eeeffffc4e4f33fc4eeeeeeeeeeeeeeeeeefeffe4eefeff17758effe66ee7ffeeeeeeeeeeeeeeeeeeeee55eeeeeeeee56e
eef88f5eeeffe4eeee99e4eee6767777eeffe4eee433e4eeeeeeeeeeeeeeeeeeeef44ffee56666f15fccce5fe8744eeeeeeeeeeeee2eeeeeee55eeeee8e8e55e
ef822e5ee44f44eee54444ee55955eeee44f44eee54344eeeeeeeeeeeeeeeeeeeee44e4e50566117eeecccfee84f8eeeeeeeeeeeee55eeeee111dd1153535666
ee8226564e4444ee5e4444eee8988eee4e4444ee5e4344eeeeeeeeeeeeeeeeeeeee44eee55511eeeeee11eeeeef66eeeeeeeeeee5665555e555dd6de15566661
eefeef6eee6ee6eeee5ee5eeedeedeeeee6ee6eeee6ee6eeeeeeeeeeeeeeeeeeeefeefeeee1ee1eeee1ee1eeeee55eeeeeeeeeeee11111eee11111eee115551e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6aeeeeeeeeeeeeeeeeee33eeeeeeeeee
eeeeeeeeeeeeeeeeeeeee4eeeee3e4eeee86eedeeeeeeeeeeeeeeeeeee6deeeeeee99eeeeee444eeeee44eeeee55eeeefce6eeeee6aeeeeee33efceeeeeeeeee
eeeeeeee6efceeee6e4cee4e5e3cee4e6e6ceeedeeeeeeeeeeeeeeeeeed6eeee3ee9ce5eee4fc9915554c555e5fc47d7f555eeee6fcedd6eefce33eeeedd8eee
eeeeeeeefeffeeeefeffeefefeffee4efe6f4444eeeeeeeeeeeeeeee8e1deee8e3eff5c5eeeffefee4eff565ee88fc4e3befc1eee33b11eee3dddd57edddd556
e000000eefffffee4f3fff4e433333fe45555fedeeeeeeeeeeeeeeee66666666e3f77f5eeef44feeeff4f55fee87e4eedddffddee3dddd16e11dd1eeee111fce
00000000eeffe4ee4e33e4ee4e99ee4eee53eedeeeeeeeeeeeeeeeee1555555eefe77efeefe44eeeeee44ffee54644eed11dd11dedddd1161d156d1aedddddde
00000000ee44e4eeee44eeee7e3e3e4eee3e6eeeeeeeeeeeeeeeeeeec1111ceeeee77e4eeee44eeeeee44eee5e4544ee15611561d111116e11d551d1d111111d
e000000eeefefeeeeefefeeeeefef4eeeefefeeeeeeeeeeeeeeeeeeeec11ceeeeefeefeeeefeefeeeefeefeeee5ee5eee55ee55e155556eee55ee55ee555556e
66666666eeeee9ae757ee7574eeeeeeeee4eeeeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebebbeeeeeeeeeeeeeeeeee
65555556eeeea9a95051150544eeeeeee446e6e6ee44eeee666eeeeeeeb3bbeeeeeeeeeeeeeeeeeee55ee55eeee66eeeeeeee5eeeb4ee4beeee3ee3eeeeeeeee
65555556eeeea449757117574446666644456565e4444eee66644444ebb3bb3eeee82eeeeee56eeeee5555eeeeeeeeeee50990eeee33c43ee3e3ee3eee66040e
65555556eeee44041115511154455d76444a8786444444ee66644444e3bb3bbee83b3b8eee666eeeeee55eeee66ee66eee9aa9eeebbccc3ee3eb3e3ee67777ee
65555556eb3b4444111551115545add644597875444444ee655c4c44e3bb3bbee2b8b3beeec6ceeee115511eeeeeee6eee9aa9eee34bcbbee3e43ebe666767ee
65555556eb3beeee757ee757555e9e56455e8786444444ae505ecec4e433334ee432323eeeeceeeeee1111eeeee66eeeee09905eee43334bebeebe4ee5e6e6ee
65555556e99b333e50511505605eeae6505eeaa5446644a9444eeeecee5454eeee4443eeeeeeeeeeeeeeeeeeeeee6eeee5eeee5eeeeeee4ee4ee4eeeeeeeeeee
666666669aa9bbbe757117576eaee9e66eeee9964655649e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
55555555a44a333e5551155565966e565eeeeee5655556ee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666e
505445054004bbbe50544505666006666e6ee6e6650056ae44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb736eee5e55e5eeeeeeeeeee823beeee45556e
555445554004eeee5654456555600655565ee56565005aae4c4c4c4ceeeaeeeeeee56deeeeeeeeeeeeeeeeeee636677eee0670eeeeeeeeeeee22323ee444446e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee99ececececeea9eeeaeee665deeeededeeeeeeeeeeeeb7677bee5676d5eee1001eeeee382bee644446e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4e99aee4ddd54eec55d5ceeeeeeeeee36b6b3ee5d66d5ee000100eee822ebee644446e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4e4eee45554eeeecc5ceeeeeeeeeee433634eee0550eeee1000eeee22eeeee664445e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeee44eeeeeeeeceeeeeeeeeeeee5454eee5eeee5eeeeeeeeeeeeeeeeee55544ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeeeeee9eeeeeee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee76767676ee7557eeee6556eeee8ee3b3eee994eee67e4444eeeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeee6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
66eeee6666666667ee5005eeee5665ee887eeb3bee9444eea06e4444eeeeeeeeeeeee5eeeeeee4eeeeeee6eeeeeee5eeeeeeeeeeeeeee6eeeeeeeeeeeeeeeeee
663eeb6676555566ee5005ee22650622778eeb3bee3444ee99454444eee6eeeeeeee4eeeeeee4eeeeeee6eeeeeee5eeeeeee7eeeeeee4eeeeeee4eeeeeee6eee
55bee35566555567ee7557ee2d555544885e3505e344494e549e5555eeeeeeeeee64eeeeeee4eeeeee76eeeeeee5eeeeeee5eeeeeee4eeeeeee4eeeeeee6eeee
3b3eeb3b76eeee66e455554e2d5055d2505eb595e349934454e95005eeeeeeeeeee6eeeeee4eeeeeee47eeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeeee
eeeeeeee66eeee67e455054eeeeeeeeeeeeeeceeee93039469445006eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee76666666e455554e9eeee666f2fee9ccee5535596674eee6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
663eeb6667676767e450554e4ddee606f2feec99ee505305606ee676eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
66bee36655555555ee4444ee29dee6662f2ae5ccee35355566eee066eeee9eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
553eeb5555555555eeeeeeee242ee5555559e505e35053ee556ee655eee4eeeeeeeeeeeeeee667eeeeeeeeeeeeeeeeeeeeee66eeeeeee8eeeeee88eeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55eeeeee67eeeeeee46eeeee06eeeeee56eeeeeee56eeeeee6eeeeee3b8eeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55eeeeee56eeeeee4e6eeeee00eeeee005eeeee00eeeeeee6eeeeee3b3eeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4eeeeeeeeeeeeeeee0eeeeeee0eeeee56eeeeeebb3eeeeeee00eee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeeebeeeeeee0000ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eee
eeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeee000eeeeeeeeeeeeeeee
ee66eeeee00eeeee63386eeee9e99eeeeeeeeeeeeeeeeeeeeeeeeeeeeee000ee00777700ee000eeeeee070eeeeeeeeeeee070eeeeeee00b0e00ee00eeeeeeeee
e6336eee6006eeee33333eee64966666eeeeeeeeee0000eeeeeeeeeeee0070ee07000070ee0700eeeee0770ee000000ee0770eeeeeee0b00e080080eeee00eee
e3bb39996556e6e633333a5a46466767eee00000e007700e00000eeeee0770ee070ee070ee0770eeeee07770e077770e07770eee00e00b0eee0880eeee0770ee
9b33b4b9685656563333356566655555eee07770e077770e07770eeeee0770ee070ee070ee0770eeeee00000e007700e00000eee0b00b00eee0880eeee0770ee
93663e34666656563666395969699eeeeee0770ee000000ee0770eeeee0070ee07000070ee0700eeeeeeeeeeee0000eeeeeeeeee00b0b0eee080080eeee00eee
96336ee43330565660006565649eeeeeeee070eeeeeeeeeeee070eeeeee000ee00777700ee000eeeeeeeeeeeeeeeeeeeeeeeeeeee00b00eee00ee00eeeeeeeee
43033eee3033535360006454464eeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeeeeeeeee
4eeeeeb4333333335555556566666767eeeeeeeeee000eeeeeeeeeee00000000ee0000eeeeee000000000000eeeeeeeeeee6eeeeeeeaee9ee8e8e8e8eeeeeeee
99eee999300030305656565566666666ee0e0eeeee0500eee000000005566670e009a00eeee0057006066060eeaaa7eeee5674eee9eae9ee8e8e8e8eeeeeeeee
449e9444300033335555555555555555e08080eee000600ee076667006555560009a9a000000575005055050eaa99a7eeee5674ee9ea9eaee8e8e8e8eee00eee
eeeeeeeeeeeeeeeeeeeeeeeecccccccc0888780ee056770ee060006000094000099999a00605750005555550ea7aa9aeeee4567eee9a9aee8e8e8e8eee0660ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0888880ee000600ee060e060ee0440ee065555600067500e05066050ea7aa9aeee4f4566ee9a9aeee8e8e8e8ee0660ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee08880eeee0500eee0600060ee0490ee06544560004600ee05644650eaa77aaee4f4ee5eee4444ee8e8e8e8eeee00eee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee080eeeee000eeee0766670ee0940ee06544560040060ee05644650e9aaaa9e4f4eeeeeee9a9aeee8e8e8e8eeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeee0000000ee0000ee00000000000000ee00000000ee9999eee4eeeeeee9ee9eae8e8e8e8eeeeeeeee
eeee666eeee77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000ee0000eeeeee000000000000eeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee
eee63b36ee7667eee444444ee5ee57e6eeee000ee00000000666666005555550e005500eeee0055005055050eeeeeeeeeeeeeeeeeeeeeeee0eeeeee0e000000e
ee6b3b3b7756657746555564ee5e7e65e000070ee07777700655556005555550005555000000555005055050eeea7eeeee56eeeeee9eeeee0eeeeee0e0eeee0e
663b666b66566566456556546e714ee7e060700ee08787800655556000055000055555500505550005555550eea997eeeee56eeeee9eeaee0eeeeee0e0eeee0e
653633366657756645566554e7e5147ee00600eee000000006555560ee0550ee055555500055500e05055050eea79aeeeef456eeeee9aeee0eeeeee0e0eeee0e
6e630003667aa76645655654444441e6e09060eeeeeeeeee06555560ee0550ee05555550005500ee05555550ee9aa9eeef4eeeeeeee44eee0eeeeee0e0eeee0e
6e630006777777774655556411141644e00000eeeeeeeeee06666660ee0550ee05555550050050ee05555550eee99eeeeeeeeeeeee9ee9ee0eeeeee0e000000e
60eeeee66666666664444446e4444411eeeeeeeeeeeeeeee00000000ee0000ee00000000000000ee00000000eeeeeeeeeeeeeeeeeeeeeeee00000000eeeeeeee
650eee0675700757066666607141117eeeeeeeeeeeeeeeeeee0000eeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555555e00ee00e
6050e0567570075776066067e714e7e6e000000eee00000eee03330ee03330eeeeeeeeeeeeeeeeeeeeeeeeeea7eeeeee88eeeeeeeeeeeeee5eeeeee507700770
56eeee657e7ee7e7e776677e6ee14e5ee056770ee009a700ee0bbb3003bbb0eee555555eee6667eeeeeeeeee9aeeeeee88eeeeeeeeeeeeee5eeeeee5070ee070
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee056770ee09a9970ee0bbb3003bbb0eee577775eee5555eeeeeee57eeeeeeeeeeeeeeeeeee8ee8ee5eeeeee5e0eeee0e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee056670ee09a79a0ee0bbb3003bbb0eeee5775eeeee44eeeee49456eeeeeeeeeeeeeeeeeeee88eee5eeeeee5e0eeee0e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee005600ee009aa00ee03330ee03330eeeee55eeeeee49eeeee94456eeeeeeeeeeeeeeeeeeee88eee5eeeeee5070ee070
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeee00000eee0000eeee0000eeeeeeeeeeeee94eeeeeeee66eeeeeeeeeeeeeeeeeee8ee8ee5eeeeee507700770
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555555e00ee00e
__gff__
0004000204000100010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8281c0808080800201010101040102010000000000000001020100020202010080c080828480800000000000000000000000000000000000000000000000000080808080000000000000000000000000000000000000000000000000000000008080c0c000008200000000000000000000000000000000000000000000000000
__map__
070702050505020202020505050202020202020207070707050505070202020202020707070707020202020202070707070705050505050505050707070707072533232125332c32322e312423212532323224223132322e313233382532323232243132321b3322253232242231323224233132323232323233212222222222
0702020505020205050202050502020303030202020202070707070702030505050202020207020202050502020202020707070707070707070707070707070733222331333a3d11133c3b31332c333a393b21253232243c292b393d331f121213312422223725323311133124222222312f39393939393939392d2422222225
020202020202050505050202020205030403020a040402020707020203040404050502020202020505050505020202020202020202020202020202070707070722221512122a352d2f3628122b3d1137223821343a362122313325331f1e12131d362c32321b331112141513311b323232323232323232242222223132323233
0202020202020202020202020205050403030a0a04060a020202020304040404040202050502050504040405050205050505050505050502020202020202020222253232322f3939392926322e351c21352a352a37333422222533342632322713353d1113381114111213151337111212121212121213312422222222222222
0a0a050505050505050202050a0a05040403050a0a0a0a020202060304060a040405050505020505040404040505050404040404030505050a0a0a0a0a0a0a0a293611122b39392913313334111331313237133c39293d242223113733331f312e12122633382122212215131512141112121212342215133539393939393939
0a05040404020205050505050a0a0a0a05050502020a060a02020606060a06060404040502020504040404040404040404040404030303050505050303030308383535393b353621152b393d2c2f393b311b33212238341f24233124231f11263c393b23353d21111422221512121214222222223c393b151212123a39393636
0a0808080404040404050a0a0a05050a02050202020a060602020a06060206060a0604040404040404040404040404040404040404040303030303030808060a2a2122223c3929393b2311122a1113371337111425373c3b211d1f31333831331f213c393939392d32323232242222222222222222253c39292b393d22223811
0a0608080808040a04040a0a0a0505020202020202060a060a0a06020202020a060606060606060606060606040404040404040404040808030308080606060a331f24222225371f3c3b31323321233127121422231f1f373a363435392d391f11142222222222222225321b3132322422222222222322222c332222112b3d31
020a060608080a080804040404040505020207070202020a0a060606060606060606060606060606060608060808080404040403030308030308060606060a021d1f3a3624231f1114281212121315133124111315121e353d111e12121212121422222222222532323322372222223132242535393b22353d22111226331f1c
0206060a0608080808040404040404040402070702020202060606060606060606060606060606080808080808080808080303050503030808060606060a060223353d3434152b2d24313232322f39393b2121232222222311142222222222222222253232323325323224222222222532111322253c3b222211142223343421
02020a0a060303090808080a0a06060a04020707020202020606060303030606060603080a0a08080a02080808080303090303030308030606060606060a06021512352a28353622212223353621231f37212123222222233124253539361b3232321f2e3536312e1f36313232243a3625312f393b2237291214222533383721
0702020a06090903080808060606060602020707070202020803030808080608080a02030902020809090909090303090901010903080806060606060a0a0202342222373724223414221511121415131114211513253233213a362425323725331f3634132836372b392d2422352a22232222213822222c322422233a3d391c
070702020a0903030808080606060606020707070702080808030a03080a08080a02030309020809090101030505030909030309030806060a0606060a0606022813221534213a3d2422222122222533211114222323111226371f1f2e1f21231f3d3a3d23373426332222341214372215353b143724112a3431242338111321
070707020a090301080808060606060a02070707070208080802020a080208080303030809090303010303030305050303050309090606060a0a06060a06060221151322382c37222125323132242334142122222323312423111a1f3738311735393d231d393536223a392d3624153a361438222211142328362c3338212321
070707020a09010108080a0a0a06060a0207070707020a08080202080202020309080803030a0909030301010103030305050303060606060a02060a0a06060221222322373822222c33353936312e3722212225331534313321231f111e131f222c323536342115353d22222235293d2422281312142223372e373a3d2c3321
0707070202080908080a0206020a06020707070702020a0a0202020202020a0903030909090a0909090901090909030803030303030606060602020a06060a0221222322233439112a342a1f281f3721351c222325322836392d2f392d321f31353b25322e3831323233221112143722112b2d2f3b22221513282b373a3d1f14
0707070202080a08080a0202020202020207070702060a03030303090909080a0a030901090a02020a01090808080808030308080306060606020206060a02071425332223371f2123382f292d2f292d24212223231f373a39393612121234353b372e22373739291f31111112121422312e2222372222253321233a3d1f1411
0707020202020208080a08020606020602070707020a090309090909090908090a0a030901090902020a090808080806080308060606060602020a060a0207073233222215122a312e371f383536371f21212223151f113732323224222238133c3b341315353621151f2121222222342237223a2d323233111434371f143a2d
020202020202020a08080a0a0a0a060a02070707070209090101010909090808090a0309090101020202060608080806060608060a02020202020a0a02020702322422222222153428133539393b1f341431241513232c332222223132323c3b13373727133233212223353b2222223c392a22381f29121214223c3614223825
060202020202020a06080808080a0a0a0202070707020801010101010101090809090a030302020202020206060808080a0606060602020202020202020707021f2122222222253734151212133c393d2422312423233422222222222222213815131f353611121422151328132225331f3c291e133124222222222222112a23
0202020202020a0606060308060606060a02020707020808080808080809090809030302020202020202020606060802020a060606060202070707070707070212142222222234111e12342211122b361f24222123233c291212121213121438223a36352914222222222331271333111e1f31241d3621223529121212142315
0702020202020a0606030306060606080802020707020206060808080808080809030909020202020702020206060a0202020206060202020207070707070707132222222222382125353d12142533151321222123151335363232241512122a22371d3621222222342215132c331f1c22151331331114222231323232241512
0702020202020a03030806060606080808020207070702020a0a0a0606060808030909010202070707070202060a06020202020a0a020202020202020207070723253224222237353622212225332222232122211513151235393b111213252f34253333212211121e1322233734342122221d35361c25321b32323224312422
070208020202020a0803030606080808080202070707070202020a060603030a030901020202070707070202020a060202020206060a02060a0606060a02070723231f312422153421353b323322222533212221221d362222253721223a361f38333311142221222223221512373721222223353b3433341f35393b1f242122
070202080202020a08080309080806060202020707070202020206060303080303010a020207070707070702020202020202020a060a0606060a0a06060207072315131f21222237311b372221223a36111422212223222222231126353d15353d33341422351c22221513222215121422252f1f3738111a3611133c36213124
07070202020202020a0809090808060202020707070702020202060608080308080a0a02020207070707070202020202020206060a0a06060a0a0a0a0a0202072f3b15121422221534382532312438111422111422232222222331333224342223112a2222222122222223222222222222231113352a31333a2d2f29361c2231
02070707070702020a06030109080602020707070707070702020a0909030308080a0a0202020707070707070202020207020606060a0a0a0a08080a080a0a02223c3939393b222238113422212c3721221114222215121322153431323a3d25332c33322422212222221513222222223423312f3b3c29393d353b3734353b22
02020202020707020a06030109080a02070707070707070702020a01010308080a0a06060202070707070707070707070702020a06060a080901080808080a0a2222253224281322373137222c37341411142222222222232222373124372223112a111321223124222222151212122b3d15121f3c3638341314283919132813
0a0a0a0602070702020a0909090a0a0207070707070707070202020a090808080a0a06060202020707070707070707070202020202020a080909080108060a0a2b393b1f212123221534282b3d112a222122222222222223222215341121253321232c3321222231242222222222222322222215121237381512382221342115
0a060a0202070707020a08080a0a0a0207070707070707070202020a0808080a0a0a060a0a020202070707070707070707020202020202060808080606060a0a3334371214312f3622373a3611263324313232323232323322222237352d33111423371113222222313232323232322f362222222222231f393919112b3d2125
06060202020202020202060a0a0a06020202020202020202020202020a0a0a0a0a0a0a0a0a0a02020202020202020202020202020202020a0a0a0606060a0a0a3a3d2c323232323224231f1114231f2125323232323232323224221511122b2d322f392d27132222253232323232322422222222222215111213352d33111423
060a0a05050505050a0a0a0a0a0a0a0a0a05050505050505050a0a0a0a0a0a05050505050a0a0a0a0a0505050505050a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a38111311121212131112121422151212131112121212121213111212142223111212121321151212131112121212131112121212121212142215121212142223
__sfx__
000600000d0400d5500f0301155015030185501b0601c5501e06012550110601455015050185501a0501b5501d0402055025530270302a5302b0302d5302d0203152032020335103401037510390103a5103d010
0001000011470104700f4700d4700c4600b4500945008440074400543004420034200341002410024100241001410014100145001450014500145000400004000040000400004000040000400004000040000400
000100002945024440204301c43017420134100f4100b410084100441002410014100d4000b4000a4000840007400074000640006400064000540004400044000340003400024000140001400014000140001400
000200002a150291502a15029150291501c1501b1501b1501b1501b1401a140121401214012130121201212012120121101111008150081500815008150081500715007150071500715007150071500715007150
00010000051600616008160091500c1500e15022640216301f6301e6200c6201d6201d6201c6101b6101a6101a610196100561018610176101761017610166101661015610156101561014610146101461003610
000200003125030250302502f2501a3501934019340193401a340243402233021330203301f3301e3301d3301d3301c3301b3301a330193301833018330183301732017320173201732009310083100831000310
000200000471005710097500a7400d73013710197101c720007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100001775014750117500f7300d7300b7300a7301d7301a7301673013730107200e7200b7200a720097200972008720087202c720297202772025720257200070000700007000070000700007000070000700
00010000151700f1501114014140171401b1200f6100d6100c6200a62008620076200661004620046200262001620016100161001610016100161001610016000160001600016000160001600016000160001600
000200001145034450124302e2502e250292402823023230182200f2200a210072100020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000200000733007330091300d1200f120096100961008610086100761006610056100461004610016100261001600016000160001600016000160001600016000160001600016000160001600016000160001600
00020000085500a5500d5500f5501355019540095300853006550065500654004560065600c560105701657016560071300713007130081300a1200d120101201212016110181101b1101e11023110261102a110
000300001c1501c1501c1501c1501c1401c1401d1300d1500c1500c1500d150061500615006120051500515005150051500515005150051500515005150051500515005150051500515005150051500515005150
000100001f3301f3301e3302532008510085100853007530065300652006520055100551005510055000550005500055000450004500007000070000700007000070000700007000070000700007000070000700
000100000b5200b520025200251007020060300503005030040200402003020030100201002010020100201001010010100000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
