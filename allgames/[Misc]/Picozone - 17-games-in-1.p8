pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--picozone
--17-in-1 collab cart
cartdata"17in1jam"
function nx(i)
j=0::_:: 
cls()p(nc[i],22,35,15)p("your score: "..nb.." —",28,75)flip()m()
if(not btn(5))j=1 goto _
if(j<1)goto _
if (nb>nh) poke4(0x5e01,nb)
warp()
j=0::…:: 
cls()p("  picozone - the 16 anomalies\n\n\n\n      brought to you by:",3,5,15)
p("         elneil\n\ndollarone    viza\nunclesporky  platformalist\nhodge        johanpeitz\nkometbomb    p01 / gruber",14,42)
p("tombrinton   2darray\nelgregos     liquidream\nenargy       egordorichev\n\n\n\n  thanks for playing!\n",14,78)
rect(0,0,127,127)
p("‡", 100, 114,8)
flip()
if(not btn(5))j=1 goto …
if(j<1)goto …
run()
end
function _init()
warp()
b={} -- planet
c={} -- flame
e=all
f=flr
g=128 -- gas
l=0 -- xtals
m=camera
n=17 -- game#
o={} -- xtals
p=print
q={} -- alien
r=rnd
s=0 -- spd
x=0
y=0
na={}for i=1,16 do add(na,i)end
nb=0 -- score
nc={" all anomalies found!\n\nyou are the winner  Œ","you're out of fuel!\n\n please try again."}
nd={}
a=r() -- ang
nh=peek4"0x5e01"
-- planets
for i=1,4 do
k=(i-1%2)*.125
for j=0,3 do
h=na[f(r(#na))+1]del(na,h)
add(b,{i*cos(k+j/4)*110,i*sin(k+j/4)*110,f(r(15)+1),h})
end
end
-- xtals
for i in e(b) do
for j=0,2 do
h=(r()+j)*.33
k=r(20)+30
add(o,{i[1]+k*cos(h),i[2]+k*sin(h)})
end
end
-- aliens
for i in e(o)do
for j=0,2 do
h=(r()+j)*.33
k=r(8)+10
add(q,{i[1]+k*cos(h),i[2]+k*sin(h)})
end
end
--stars
for i=1,16 do add(nd,{f(r(128)),f(r(128))})end
ref={q,o}
end
function _update()
	u[n]()	
end
function _draw()
	d[n]()
end
--------------------init functions
t={
function() 
mx,mx2,mbf,mlx,mt,mps,memx,mtx,mbx,mby,mvx,mvy=56,56,{},0,0,{},0,0,64,32,rnd()>0.5 and -1 or 1,1
end,-- lateris
--------------------
function() 
fq,fh,fr,fa,ft,fv,fs=0,0,{},1,0,{},143
fm='press Ž to fish!'
for i=1,15 do make_wave() end
end,-- fishing
--------------------
function() 
lpx,lpy,ltc,lpm=7,6,f(r"3")+3,0
for i=0,31 do
for j=0,31 do
mset(i,j,mget(i%16+32,j%16))
end
end
lmx,lmy=f(r"16"),f(r"16")
repeat
ltx,lty=f(r"12")+lmx+2,f(r"12")+lmy+2
until mget(ltx,lty)==0
while mget(lpx+lmx,lpy+lmy)>0 do
lpy-=1
end
end,-- treasure
--------------------
function() g_lvl=0 g_init() end,-- gregos
--------------------
function() 	ww={{x=35,y=30},{x=30,y=30}}
wh,wt=ww[1],ww[2]
wh.c,wax,way,wtime=wt,64,68,90
music(8)end,-- worm
--------------------
function()   tg,tx,ty,tv,td,tcc,tcn,ts,tb,tn=false,8,8,30,60,0,3+ceil(rnd"6"),0,{},{} end,--bug collector
--------------------
function() 
music(16)pt,pn,pm=0,0xfffe,1
end,--dirt
--------------------
function() 	
ka,kgo,kar,krv,kx,ky,kdx,kdy=.25,0,.25,0,56,330,0,0
for j=0,47 do
for i=0,31 do
local t=sget(i/2+64,j/2+64)
local ft=sget(t%4*2+72+i%2,88+flr(t/4)*2+j%2)
mset(i,j,ft>0 and ft%4+flr(ft/4)*16+136)
end
end
end,--thrust
--------------------
function()  at,ad,ag,al=0xffff,0,0,30 end,--rungeon
--------------------
function()  
palt(0,false)
palt(3,true)
music"4"
dst,dend,dbob,dbd,dbt,dscore,dnum,dd,dpigs=
75,100,8,0,false,0,0,0,{}
for i=1,4 do
dip(i)
end
dnd()
end,--birb
--------------------
function() 
ea,et,etm,es,exd,eg,ew,ebt,epy,epd,eps=1,80,80,0,.25,0,{},false,64,0,164
sfx"39"
for h=2,6 do
er(h*20+7)
end
end,--flop
--------------------
function()palt(0,false)palt(11,true)ua,ut,up,uc={},0,0,0
ua[1]={130,60,60,30}for h=2,6 do
ua[h]={131,128,128,149}end
music"55"end,--pants
function()sx,sy,sl,ss,sw=120,8,1,false,128
palt(0,false)palt(14,true)music"52"end,
--rpg
function()rt,rl,rp,rd,rb,rs=45,1,rw,101,0xffff,"         ” to draw gun\n         — to shoot"end,
--alien
function()cls"1"dx,dm,dp,dd,dq,dw,ds,dc,dl,dr,du=60,24,212,0,60,700,0,{},{},{},{1,10,9,15,4,3,11,6,13,2,8,0}for di=0,128 do dc[di],dl[di],dr[di]=60,20,111 end;music"60"
end,--lake
function()nl,nm,nn,np,nq,nr,ns,nt,nu,nw,nz=3.25,0,19,{{128}},0,{},0,1,0,{},{"‹","‘","”","ƒ"}sfx(56,3)end,
--teapot
}
--------------------update functions
u={
function() end, -- lateris (no code)
--------------------
function()
if btnp"4" then
if fa>=13 then
pal()
ret(min(fh,128))
end
if fn then
fn,fr[fa],fm,fs=false,3,"got it! ‡",159
fh+=11
sfx"23"
fa+=1
elseif not fg then
fg,ft,fm,fs=true,60+rnd"3"*60,'',143
else
fn=false
fg=false
fr[fa]=8
fa+=1
fm,fs="too soon! :(\npress Ž",158
sfx"22"
end
end
if (fg or fn) ft-=1
if ft<=0 then
if fg then
fg,fn,ft=false,true,15
elseif fn then
fr[fa],fn,fm,fs=8,false,"miss!",158
fa+=1
sfx"22"
end
end
if fe then
fe-=1
if fe<=0 then
fm,fe,fs=nil,nil,143
end
end
end,-- fishing
--------------------
function()
local x,y=lpx,lpy
if lpm>1 then
lt-=1 
if lpm<4 then
if (lt%5==0) lpm+=1 
if (lpm>3) lpm=2
end
if lt<1 and lpm>1 and lpm<4 then
lpm=0
sfx(0xffff,0)
if ltx==x+lmx and lty==y+lmy then
done(128,"found treasure!")
else
ltc-=1
if ltc>0 then
lpm,lt,lrs=4,50,126
if ltx==x+lmx then
lrs=127
elseif lty==y+lmy then
lrs=125
end
if (ltx>x+lmx) lrfx=true
if (lty<y+lmy) lrfy=true
else
done(0,"  time's up!")
end
end
elseif lt<1 then
lpm=0
end
else
lrfx,lrfy,lpm=false,false,0
lpm=0 
for k=0,1 do
if(btnp(k))x+=k*2-1
if(btnp(k+2))y+=k*2-1
end
if (btnp"4") lpm=2 lt=50 sfx(13,0)
if not fget(mget(lmx+x,lmy+y),0) then 
x,y=mid(x,15),mid(y,15)
if (x+y!=lpx+lpy) lpm=1 sfx"12"
lpx,lpy=x,y
end
end
end,-- treasure
--------------------	
function()
if(btn"0")g_pl.a+=.02
if(btn"1")g_pl.a-=.02
if(btn"4"and g_pll>5)add(g_mobs,{t=1,x=g_bx,y=g_by,r=1,a=g_pl.a,s=2,d=50})g_pl.s-=.2 g_pll-=1 sfx(26)
if(btnp"5")ret(g_lvl*7)
g_pl.s*=.98
cls(g_colr"0")
for mobn=#g_mobs,1,-1 do
local mob=g_mobs[mobn]
for m2=#g_mobs,mobn+1,-1 do
local mob2=g_mobs[m2]
local ts=mob.t+mob2.t
local dx,dy=mob.x-mob2.x,mob.y-mob2.y
if mob.r+mob2.r>=sqrt(dx*dx+dy*dy)then
if(ts>=6)sfx"25"g_pll-=1
if ts==3 then
sfx"24"
mob.r*=.5
if mob.r<2 then
del(g_mobs,mob)
else
mob2.r,mob2.t,mob2.s=mob.r,2,mob.s
end
end
end
end
mob.x+=cos(mob.a)*mob.s
mob.x%=128
mob.y+=sin(mob.a)*mob.s
mob.y%=128
circfill(mob.x,mob.y,mob.r,g_colr(mob.t))
if mob.t==1 then
mob.d-=1
if(mob.d<0)del(g_mobs,mob)
end
end
g_bx,g_by,g_pll=g_pl.x+cos(g_pl.a)*g_pl.r*1.5,g_pl.y+sin(g_pl.a)*g_pl.r*1.5,mid(0,g_pll,100)
circfill(g_bx,g_by,2,g_colr"1")
p("ishiharoid   level "..g_lvl.."\n\n‹‘Žplay   —quit",13,105,g_colr"3")
if(#g_mobs<2)g_lvl+=1 g_init()sfx"27"
if(g_pll<=0)g_init()
rect(13,111,13+g_pll,115)
g_pll+=.1
end, -- gregos
--------------------
function()
wtime-=.0333
if(wtime<0xfffd)ret(#ww*3.5)
if(wtime<0)return
cls"1"
map"64"
if(abs(wh.x-wax)+abs(wh.y-way)<5)repeat wax=rnd"128"way=rnd"128"until 0==mget(wax/8+64,way/8)wn={x=wt.x,y=wt.y+1}add(ww,wn)wt.c,wt=wn,wn
local ix,iy=0,0
if (btn"0") ix-=.28
if (btn"1") ix+=.28
if (btn"2") iy-=.28
if (btn"3") iy+=.28
for k=1,6 do
wh.x+=ix
wh.y+=iy
for i,w in pairs(ww) do
for j=i-1,1,0xffff do
if (ww[j].x<w.x) break
ww[j+1],i=ww[j],j
end
ww[i]=w
end
for i,w in pairs(ww) do
local wx,wy,c=w.x,w.y
for j=i-1,#ww do
c=j==i and w.c
if j>i then
c=ww[j]
if(c.x>wx+5)break
end
local dx,dy
if (mget(wx/8+64,wy/8)>0)dx=wx%8-4 dy=wy%8-4
if (c) dx=c.x-wx dy=c.y-wy
if dx then
local d=sqrt(dx*dx+dy*dy)
local t1=j==i and .2 or .5
if d<5 or i==j then
//d=sqrt(d)
local e=(c and d*.5-2.5 or 2)/d
dx*=e
dy*=e
if(c)c.x-=dx-dx*t1 c.y-=dy-dy*t1
w.x+=dx*t1
w.y+=dy*t1
end
end
end
spr(w==wh and 81 or 65,wx-3,wy-3)
end
end
spr(66,wax-2,way-2)
?"snakeworm (2darray)        “"..flr(wtime),2,121,15
end,-- worm
--------------------
function()
tv+=1
if tv>29 then
td-=1
local b={}
::redo::
b.x,b.y=3+flr(rnd"10"),4+flr(rnd"8")
for i=1,#tb do
if((tb[i].x==b.x and tb[i].y==b.y) or (b.x==tx and b.y==ty)) goto redo
end
tv,b.t,b.tt=0,0,30+flr(rnd"120")
add(tb,b)
end
if(td<1)tg=true
if(td<0xfffe) ret(ts*8)
if not tg then
if(tcc==tcn)sfx"10";ts+=1;tn={};tcn=3+ceil(rnd"6")
if(btnp"1" and tx<12)tx+=1
if(btnp"0" and tx>3)tx-=1
if(btnp"3" and ty<11)ty+=1
if(btnp"2" and ty>4)ty-=1
if(btnp"5") tn={}
if(btnp()>0) sfx"11"
end
end,--bug collector	
--------------------
function()
m(0xffc0,0xffc8)ps=f(128-pt/100)
if(pm>5)rectfill(0xffc0,0xffd0,64,0xfff0,0)sspr(56,32,8,8,0xffc8,0xffd2,32,32)pp("\\o/ you won $"..ps.."\n\n— to continue",0xfff0,0xffd8,7)return btnp"5"and ret(ps)
cls"4"for z=0xffc0,192 do
i=z/256w=sin(i+pm%2*i)v=32+16*w+8*sin(i*3)-4*sin(i*(2+pm))circ(v*cos(i),v*sin(i),7+3*w,5)
?"•",64*sin(v),z
v+=16+v%.4*139spr(68+z%2,v*cos(i),v*sin(i)-8)end
v=mget(pget(px,py),16)/3-4
if pn<pm then
pn+=.02 ptl,pl,pgs,pa,px,py,pb=1337,1,{},.2,32,0,0
else
sfx(16,3,pt%6+v*8)pt+=1ptl+=1py-=v*cos(pa)px+=v*sin(pa)
if(btn"0")pa+=.01
if(btn"1")pa-=.01
end
spr(72,44,0xfff8)spr(72,16)pgs[ptl]={a=pa,x=px,y=py}for i=2674,0,0xfac7 do
h=pgs[ptl-i] if(h!=nil)pal(8,i<1 and 8or 12)v=h.a%1spr(84+sgn(.5-v)*v%.5*16,h.x-4,h.y-4,1,1,v<.5)end
v=24/min(1,pm-pn)sspr(64,32,32,8,v*0xfffe.1,v/0xfffd.3-26,v*4,v)pp("  lap "..pl.."/3\ntrack "..pm.."/5\n time "..(pt/100).."\"\n    $ "..ps.."\n\ndirt’racing (p01+gruber)",0xffc2,35,7)v=pb-atan2(px,py)
if(v>.9)pl+=1ptl=pl*1337
if(pl>3)pm+=1
pb-=v
end,-- dirt
--------------------
function()
if kgo<1 then
if(btn"0")ka+=.02
if(btn"1")ka-=.02
if(btn"2")sfx(21) krv+=sin(kar-ka)*.00052 kdx+=cos(ka)/40 kdy+=sin(ka)/40
kar+=krv
krv*=.99
kdy+=.01
kx+=kdx
ky+=kdy
end
kgo=max(0,kgo-1)
if(kgo==1 or ky<8)ret(102-ky/3)
end,--thrust
--------------------	
function() 
if at<0 then
if (btnp"5") a_make_level()
return
end
if (al<1) return 
at+=1
v,w=apx,apy
if (btnp"2") apy-=1
if (btnp"3") apy+=1
if (btnp"0") apx-=1
if (btnp"1") apx+=1 
if a_pmget(32) then
apx,apy=v,w
elseif a_pmget(51) then
a_make_level()
elseif a_pmget(35) then
ag+=1
sfx"0"
elseif a_pmget(50) then
ag+=10
sfx"0"
elseif a_pmget(33) then
al+=10
sfx"1"  
elseif a_pmget(34) then
al-=5
sfx"2"
mset(apx,apy,50)
apx,apy=v,w
end
mset(v,w)
mset(apx,apy,49)
if (at%30==0) al-=1
end,--rungeon
--------------------
function()
for i=1,4 do
dpigs[i].timer=max(0,dpigs[i].timer-1)
end
if dst<0 then
dbob-=1
if dbob<1 then
dbob,dbt=17,false
end
dt+=1
if dt==45 then
if dn!=0 then
if dpigs[dn].fd==df then
dip(dn)
dscore+=4
sfx(7,3,16,7)
else
sfx(7,3,8,7)
end
end
if dnum>=32 then
dend=50
else
dnd()
end
end
dlx,dly=0,0
if dn==1 then
dly=0xffff
elseif dn==2 then
dly=1
elseif dn==3 then
dlx=0xffff
elseif dn==4 then
dlx=1
else
dlx,dly=0xffff,1
if dx>51 and dx<72 then
dn=dbd
if dbd!=0 then
dbt=true
sfx(7,3,0,7)
end
end
end
dx+=dlx*2.9
dy+=dly*2.9
dbd=0
if btn"0" then dbd=3
elseif btn"1" then dbd=4
elseif btn"2" then dbd=1
elseif btn"3" then dbd=2
end
if(dend<100) dend-=1
if(dend<0) ret(dscore)
else
dst-=1
end
end,--birb
-------------------- 
function()		
if ea == 1 then
if (ee() and btnp"4")	eg,ea=0,2	sfx"-1"
elseif ea == 2 then
em_ep()
foreach(ew,em_ew)
if (et>0) et-=1 else local q=ceil((es+1)/5) exd,etm=q/4,80/q et,es=etm,es+1 sfx"38" er(128)
elseif ea ==3 then
if ee() and
btnp"4" then
if (es>16) es=16
ret(es*8)
end
end
end,--flop	
--------------------	
function()--pants
ux,uy=ua[1][2],ua[1][3]
ut+=1
if (btn"0" and ux>0) ua[1][2]-=1
if (btn"1" and ux<120) ua[1][2]+=1
if (btn"2" and uy>0) ua[1][3]-=1
if (btn"3" and uy<112) ua[1][3]+=1
for h=0,270 do
pal(6,h%2*7+6)spr(144,h%17*8,f(h/17)*8)
end
srand"0"for h=1,up do
spr(145,r"120",r"120")
end
srand(ut)for h=0,128 do
for i in e(ua) do
j,k,v,w=i[1],i[2],i[3],i[4]
if v==h then
spr(j,k,v,1,2,ut%30<15 and j<161)if j>159 then
if btn"4" and abs(k-ux)<9 and abs(v-uy)<9 then
if (uc<1 and ((j==160 and uy>v) or (j==162 and uy<v) or (j==161 and ux>k) or (j==163 and ux<k))) uc=ut+90
i[1],i[4]=131,ut+30
up+=1sfx"43"
end
if (ut>w) i[4]=ut+r(30)+30-(up*1.5) i[1]=(j+1)%4+160
end
if (j==131 and ut>w) i[1],i[2],i[3],i[4]=160,f(r(104)+8),f(r(96)+8),ut+30
end
end
end
if (ut<150) pp("        pants thief\n\npress Ž to steal pants when\n standing behind a citizen.\n\n     don't get caught!",9,20,10)
if (uc>0) pp("you were caught!\npants stolen: "..up,33,64,10)
if (ut-uc==0xffff) ret(up*3)
pp("pants thief (@unclesporky)",2,121,7)end,--pants
--------------------	
function() --rpg
if mget(sx,sy)<206 or mget(sx,sy)>235 then
srand"6"for i=0,15 do
for j=0,15 do
spr(f(r"4"+204),i*8,j*8)end
end
map(106,14,32,32,8,16)rectfill(41,57,78,78,2)rect(42,58,77,77,9)spr(238,48,64)spr(239,64,64)sh=16+5*sl
if sx==120 then
pp("   hero, slay the lich! kill\n  monsters to level up. visit\n   towns for healing and aid.\nyour health drains as you move!",3,23,10)elseif sx==125 then
pp("use this sword to slay the lich!",1,29,10)ss=true
elseif sx>126 then
rectfill(0,0,128,128,2)sw=sl*6
sh=0
if sx==128 then
pp("you have died.",37,29,7)else
if ss==true then
pp("you have saved the world!",15,29,7)else
pp("   the lich destroys you.\nnext time seek out a weapon!",11,29,7)end
end
else
pp("welcome! your wounds are healed.",1,29,10)end
pp("press Ž to continue",25,89,7)
if (btnp"4" and sx>126)ret(sw)
if (btnp"4")sy+=1
else
map(f(sx/16)*16,f(sy/16)*16,0,0,16,16)if mget(sx,sy)==223 then
rectfill(0,0,128,128,8)sfx"47"mset(sx,sy,mget(sx,sy+1))sl+=1
end
spr(238,sx%16*8,sy%16*8)
if(btnp"0"and mget(sx-1,sy)<253)sx-=1 sh-=1
if(btnp"1"and mget(sx+1,sy)<253)sx+=1 sh-=1
if(btnp"2"and mget(sx,sy-1)<253)sy-=1 sh-=1
if(btnp"3"and mget(sx,sy+1)<253)sy+=1 sh-=1
end
if(sh==1)sx=128
pp("lv "..sl.." hp",2,2,10)rectfill(35,3,sh+35,5,8)
if(ss==true)spr(252,1,8)
pp("micro rpg (@unclesporky)",2,121,7)
end,
--------------------
function() --alien
rt-=1
rp""   
?rs,0,109,0
?"alien shootout (@viza)",2,121,7
flip""end,--alien
--------------------
function() --lake
if ds==0 then dm+=3;for di=125,128 do dt=(dm/10+20)*(0.0572*cos(4.667*3*dm)+0.0218*cos(12.22*3*dm))dl[di],dr[di]=20+dm/160+dt,110-dm/155+dt end;for di=0,125 do dl[di],dr[di]=dl[di+3],dr[di+3]end;if pget(dx,38)==5 or pget(dx+2,40)==5 or pget(dx+4,38)==5 or pget(dx+2,40)==0 then ds,d_g=f(dm/5626*100), " crash!"if ds>99 then ds,d_g=128,"congrats!"end end;dp=(dp+1)%3
if(btn"0")dd-=0.1 
if(btn"1")dd+=0.1 
dx+=min(max(dd,-1.5),1.5);for di=4,2,-1 do dc[di]=dc[di-1]end;dc[1]=dx;if dw-dm<-150 then dw+=308;dq=30+dm%50 end elseif btn"5"then ret(ds)end 
end,--lake
--------------------
function()nq+=1
for i in e(nr)do
i[1]+=i[3]i[2]-=i[4]i[4]-=1.2
if(i[2]>130)del(nr,i)end
if(#np<1 and nm==0 and #nr<1)sfx(-1,3)ret(nu*7)
nm=max(nm-.03,0)for i in e(np)do
i[1]-=1
h=i[1]
if(h<20)del(np,i)nm=.25
if(h>45 and h<57 and ns==1.9)nu+=1 del(np,i)for i=1,9 do add(nr,{58,83,r(8)-4,r"9",1})sfx(58)end
end
if(nq%65<1 and nn>0)add(np,{128})nn-=1
ns=max(ns-.3,0)if #nw<1 then
for i=1,nl do add(nw,f(r"4"))end
end
if(btnp(nw[nt]))sfx(59,2)nt+=1
if nt>#nw then
sfx(57)nw={}nt=1 nl=min(nl+.25,8)ns=1.9
end
end,-- teapot
--------------------
function() --meta
if(g<1 and s==0)nx(2)
if(#b<1)nx(1)
for i in e(c) do
i[3]*=.9
if(i[3] < 1) del(c,i)
end
if(btn(0))a+=.02
if(btn(1))a-=.02
if btn(2)and g>0 then
if(#c<4) then
j=a-.55+r(.1) 
i=4+r(2)
add(c,{x+(i*cos(j)),y+(i*sin(j)),r(3)})
end
sfx(62)
g=max(g-.3,0)
s=min(s+.1,3)
else
s*=.95
end
x+=s*cos(a)
y+=s*sin(a)
m(x-64,y-64)
--check xtals
for i in e(o) do
if(abs(x-i[1])<5 and abs(y-i[2])<5)del(o,i)sfx(63)l+=1
end
for i in e(q) do
if(abs(x-i[1])<5 and abs(y-i[2])<5)sfx(61,1,r(11))g-=1
end
for i in e(b) do
if(abs(x-i[1])<7 and abs(y-i[2])<7 and l>2)del(b,i) l-=3 n=i[4] --[[n=16]] warp() t[n]()m()
end
end--meta
}
--------------------draw functions
d={
function()
mt+=1
cls()rect(0,0,127,127,1)
if(mtx==3)rectfill(2,2,125,125,1)
?"lateris (@egordorichev)",2,121,1
spr(12,mx,115+mtx,2,1)spr(12,mx2,-1-mtx,2,1,false,true)mmx=0
if(btn(‹))mmx=-1
if(btn(‘))mmx+=1
mx=mid(2,110,mmx*2+mx)if mt>30 then
if mlx~=mmx then
add(mbf,{mmx,mt+mt/20})mlx=mmx
end
for m in e(mbf) do
if m[2]<=mt then
memx=m[1]del(mbf,m)end
end
mx2=mid(2,110,memx*2+mx2)mbx+=mvx
mby+=mvy
msc=flr(mid((mt-30)/8,0,128))if mbx<4 or mbx>123 then
sfx(32)mvx*=-1
elseif mby<4 or mby>120 or msc==128 then
ret(msc)
end
mtx=max(0,mtx-mtx*0.1-0.05)if pget(mbx+mvx*2,mby+mvy*2)>1 then
mvy*=-1
if (mby>4 and mby<120) sfx(32,0)
mtx=3
end
if #mps>32 then
del(mps,mps[1])end
add(mps,{mbx+rnd(4)-2,mby+rnd(4)-2})else
mx2=mid(2,110,mmx*2+mx2)end
mv,mr=mbx,mby
for i=#mps,1,-1 do
mn=mps[i]line(mn[1],mn[2],mv,mr,i%8+7)line(mn[1],mn[2]-1,mv,mr-1,i%8+8)mv,mr=mn[1],mn[2]end
spr(14,mbx-2,mby-2)
end,-- lateris
--------------------
function()
cls(12)
palt(0,false)
palt(11,true)
rectfill(0,96,127,127,1)
sspr(112,64,8,8,0,84,64,32)
--clouds
for k,c in pairs(fv) do
for i=0,3 do
local x,y=c.x+i*3,c.y+i%2
circfill(x,y+95,c.r,13)
circfill(x-12,y,c.r*6,7)
end
c.x-=c.r
fv[k].x%=140
end
spr(140,24,56,2,4)
spr(fs,30,62)
--?'chances:'
for i=1,12 do
?'†',25+i*7,0,fr[i] or 0
end
if fg then
?sub('...',1,ft%20/5),26,43
line(56,50,80,107,7)
line(38,80,56,50,0)
end
if fn and ft%15<7 then
?'press Ž',30,43
line(48,46,80,107,7)
line(38,80,48,46,0)
end
if fm then
?fm,68-#fm*2,32
end
?"'simple fishin' (@enargy)",3,122,7
fq+=.005
for i=1,12 do
memcpy(0x7980+i*0x40,0x7980+cos(fq)*i+i*0x40,0x40)
end
if fm=="got it! ‡" then
pal(12,fa)
pal(10,fa+1)
spr(174,64,48,2,1)
end
end,-- fishing
--------------------
function()
srand(lmx)
cls"3"
palt(0,false)
for i=1,40 do
?"•",r"128",r"128",11
end
map(lmx,lmy,0,0,16,16)
local n=lpm<4 and 76+lpm or lrs
spr(n,lpx*8,lpy*8,1,1,lrfx,lrfy)
pp("treasure hunt (liquidream)",2,121,7)
end,-- treasure
--------------------
function() end,--gregos (no code)
--------------------
function() end,-- worm (no code)
--------------------
function() 
cls()
map(48,0,0,0,16,16)
if tg then
?"final score:"..ts,35,61,rnd"15"
else
foreach(tb,tmb)
spr(25,tx*8,ty*8)
tcc=0
for i=1,#tn do
tcc+=tn[i]
?"—",23,20,1
spr(8+tn[i],23+i*8,19)
end
?tcc.."/"..tcn,93,20,6
?"points:"..ts.."\t\t\t\t\ttime:"..td,24,104
?"bug collector (brintown)",2,121,1
end
end,-- bug collector	
--------------------
function() end,-- dirt (no code here)
--------------------
function()
cls()
camera(kx-64,ky-64+4*sin(rnd(kgo)))
map(0,0,0,0,32,48)
local ax,ay,bx,by=cos(kar)*10.656+kx,
sin(kar)*10.656+ky,
cos(kar)*0xfffb.328+kx,
sin(kar)*0xfffb.328+ky
-- pod collision check
for i=0,35 do
if(kgo<1 and pget(bx+i%6-3,by+i/6-3)>0)sfx(20)kgo=30
end
-- draw pod	 
circ(bx,by,3+rnd(kgo),6)
for col=0,1 do
for i=0,16,2 do
local h="0x"..sub("063345748394c5d306",i,i+2)
local r,d=h%16+rnd(kgo),h/256+ka
kpx,kpy,kgx,kgy=kgx,kgy,ax+cos(d)*r,ay+sin(d)*r
--draw line on col>1 and i>1
if(col*i>0)line(kgx,kgy,kpx,kpy,7)
--check collision on col<1
if(col+kgo<1 and pget(kgx,kgy)>0)sfx(20)kgo=30
end
end
if(kgo<1)line(ax,ay,bx,by,5)
camera()
pp("picothrust (kometbomb)",2,121,12)
end,-- thrust
--------------------
function() 
cls()
if (aox) spr(48,aox*8,aoy*8)
map()
if at<0 then
?" rungeon ",38,40,7
?"wounded but greedy",28,63,6
?"descend in search of riches",10,70,13
spr(48,48,86,4,1)
?"—",60,98
return
end
if (at<20 and at%4==0) circ(apx*8+3,apy*8+3,4+at/2) 
?"depth: "..ad.."   gold: "..ag.."   life: "..al
?"rungeon (johan peitz)",0,123
if al<1 then
rectfill(0,32,127,47,0)
?"you died "..ag.." gold richer. (—)",8,37,10
color"8"
if (btnp"5") ret(ag)
end
end,--rungeon
--------------------
function()
cls"3"
for i=1,4 do
if i==1 then
px,py,fp=56,17,false
elseif i==2 then
px,py,fp=56,112,true
elseif i==3 then
px,py,fp=1,60,false
elseif i==4 then
px,py,fp=112,60,true
end
spr(132,px,py,2,2,fp)
if dpigs[i].timer==0 then
circfill(px+7,py-9,8,15)
spr(dpigs[i].fd+19,px+4,py-12)
end
end
spr(df+19,dx,dy)
spr(164,48,59-flr(dbob/9),4,2,dbt)
pp("  birbserve          (hodge)",2,121,14)
end, -- birb
--------------------
function()	
cls"7"
rectfill(0,20,127,107,5)
if ea == 1 then
sspr(32,24,27,4,10,54,108,16)
?"Ž flop",48,74,7
else
spr(eps,14,epy)
foreach(ew,ed_ew)
end
i,j=es,62
if (ea==3) i,j="Ž quit",48 
?i,j,112,5
?"‡‡flopger‡‡ (platformalist)",2,121
end,--flop
--------------------
function()end,--pants
function()end,--rpg
function()end,--alien
--------------------
function()--lake
cls"5"for di=0,127 do for dj=-2,4,2 do if dm+di>5625 then dj=0 end;line(dl[di],di-dj,dr[di],di+dj,du[f((dm+di+489)/512)])end end;for dk=1,4 do spr(196,dc[dk],32-dk*8)end;spr(dp+212,dx,32)spr(215,dq,dw-dm)spr(231,dq+33,dw-dm+99)p(f(dm/5626*100).."%",112,113,7)if ds>0 then p(d_g,48,46)if ds>dget"9"then dset(9,ds)end;p("     score: "..ds.."\n\n      hi: "..dget"9".."\n\npress \x97 to return",28,64)end;p("lake of black gold (@dollarone)",2,121)	
end,--lake
--------------------
function()cls"1"for i=1,50 do
j=r"128"k=r"128"line(j,k,j+2,k+3,5)end
if(r()<.005)cls"10"
for i in e(nr)do
spr(240+f(r"3"),i[1],i[2])end
spr(192+f(ns)*2,45,56,2,3)for i in e(np)do spr(243,i[1],72)end
spr(243,20,128+55*sin(nm))line(29,80,128,80,7)pset(56,81)for i=1,#nw do
if(i<nt)color"10"else color"9"
p(nz[nw[i]+1],45+i*9,30)end
p("press",30,30,7)p("teapot vandal (@elneil)",2,121)p("hits: "..nu,1,1)p("remaining: "..nn,76,1)end,--teapot
--------------------
function()--meta 
cls()
for i in e(nd) do
pset(((i[1]-(x%128)+128)%128)+x-65,((i[2]-(y%128)+128)%128)+y-65,5+r(2))
end
fillp(shl(r(32767),1)+r(2))
-- planets
for i in e(b) do
circfill(i[1]-2,i[2]-2,5,i[3])
j="come\n in!" if (l<3) j="need\n 3"
p(j,i[1]-9,i[2]+7,7)
end
-- smoke
for i in e(c) do
circfill(i[1],i[2],i[3],r(16))
end
fillp()
--xtals/mons
for i=1,2 do
for j in e(ref[i])do
spr(228+i,j[1]-2,j[2]-2)
end
end
-- player
spr(228,x-3,y-3)
pset(f(x)+.5+2*cos(a),f(y)+.5+2*sin(a),1)
if(x==0 and y==0)sspr(32,120,32,8,-48,-45,96,24)p("the 16 anomalies\n\n\n\npress ” to fly!\n\n  hiscore: "..nh,-32,-15,15)
--hud
rectfill(f(x)-64,f(y)+56,f(x)+g-64,f(y)+62,8+(g*.03))
p("fuel",f(x)-63,f(y)+57,0)
p("sector ["..10+f((x+125)/250)..","..10+f((y+125)/250).."]",f(x)-63,f(y)+50,7)
for i=1,min(l,7) do p("",f(x)+i*6-5,f(y)+50)end
p("…:"..16-#b,f(x)+45,f(y)+50)
end--meta
}
-----------------------------------------------------

function ret(k)
k=flr(mid(0,k,128))
music"-1"palt""nb+=k
g=min(128,g+k)
n=17
m()
i=120
sfx(33+min(k,1))
while i>0 do 
cls()
?"you found "..k.." tons of fuel.",14,50,7
flip()
i-=1
end
reload()
warp()
end

--------------------dev globals
function tmb(b)
if(b.tt>0)b.tt-=1
if(b.tt==0 and b.t==0)b.t=ceil(rnd"3");b.tt=-1
spr(8+b.t,b.x*8,b.y*8)
if b.x==tx and b.y==ty then
if b.t>0 then
if b.t<4 then
add(tn,b.t);del(tb,b)
sfx"9"
end
else
sfx"8"
b.t,b.tt=16,30
if(ts>0)ts-=1
end
end
if(b.tt==0 and b.t==16)del(tb,b)
end

function a_make_level()
at=0
ad+=1
reload()
for i=0,3 do
local r,mx,my=flr(rnd"8"),(i%2)*8,1+flr(i/2)*7
for x=0,7 do
for y=0,6 do
if (sget(r*8+x,y)>0) mset(mx+x,my+y,32)
end
end
end
a_rmset"48" 
apx,apy=flr(arx),flr(ary)
aox,aoy=apx,apy
a_rmset"51" 
a_rmset"33"
for i=0,ad do
a_rmset"34" 
a_rmset"35" 
end
sfx"3"
end

function a_rmset(tid)
arx,ary=rnd"16",rnd"14"+1
if (mget(arx,ary)==0) return mset(arx,ary,tid)
a_rmset(tid)
end

function a_pmget(id)
return mget(apx,apy)==id
end



function rg()
cls"4"
rectfill(0,0,128,64,12)
for i=2,6 do local y=i*i+64
line(0,y,128,y,15)
end
end
function ra()
local o=12+sin(rt/100)*2 sspr(64,96,8,16,32,o,30,50)
if sin(rt/60)<0then sspr(72,96,8,16,62,o,30,50)
else sspr(88,96,8,16,62,o,30,50)
end
sspr(64,112,16,16,32,60,60,50)
end
function re()
local s=2^(rl-1)rs="           score: "..s
if rt<-60 then ret(s)
end
end
function rw()
if rt<=0 then
rt,rp,rs=90,r_sc,"           duel: "..rl.."/7"
end
rg""
if rl>1 then sspr(80,120, 16,8, 32,70, 60,30)
sspr(88,112, 8,8, 69,128-rt, 45,45)
end
end

function r_sc()
rg""
for i=10,rt,30 do circfill(10,i, 7, 10)
end ra""
if rt==10 then
rt,rp,rs = 100,r_ss,"        ” to draw gun"
end
end
function r_ss()
local b=128*(((rd-rt)*(rl+2))/100)^1.8
rg"" ra""
if rt<0 then rs=""
if rl==8 then sspr(80,120, 16,8, 32,70, 60,30)
music"58"
rp=re
elseif not (rb>70 and rb<90) then
cls"8"
sfx"48"
sspr(80,96, 16,16, 32,10, 60,50)
sspr(64,112, 16,16, 32,60, 60,50)
sspr(80,112, 8,8, 34,36, 30,30)
music"59"
rp=re
else
rt,rd,rp,rb=45,101,rw,0xffff
music"57"
end
end
if rd>100 then
if btn"2" then
rd=rt
end 
else
rectfill(0,0,128,7,1)rectfill(70,0,90,7,11)
?"—",77,1,7
local p = rb>=0 and rb or b
line(p,0,p,9,10)
sspr(88,112, 8,8, 69,83, 45,45)
if btnp"5" then
sfx"48"
sspr(80,112, 8,8, 55,54, 60,60)
rb,rt=b,0 rl+=1
end
end
end



function pp(h,i,j,k)
?h,i-1,j,0
?h,i+1,j
?h,i,j-1
?h,i,j+1
?h,i,j,k
end

function em_ep()
eps=36
if (btn"4") eps=37
if (btn"4" and ebt==false) sfx"36" epd,ebt=-2.5,true
if (epd<2) epd+=.25 else epd=2
epy+=epd
if (epy<19 or epy>103)	ed() 
if (btn"4"==false)	ebt=false
end

function ee()
if (eg<15) eg+=1 else return true
end

function em_ew(v)
if (v.y>15)	v.y-=v.v else v.y=110
if (v.x>-8)	v.x-=exd else del(ew,v)
if	v.x>21 or
v.x<11 or
v.y>epy+5 or
v.y+5<epy then
else
ed() 
end
end

function ed()
ea=3
sfx"37"
end

function ed_ew(v)
spr(38,v.x,v.y)
end

function er(j)
local q=rnd()
for i=1,3 do	
add(ew,{x=j,y=i*32,v=q})
end
end

function dip(n)
dpigs[n]={fd=ceil(r"4");timer=12}
end

function dnd()
dx,dy,dt,dn,df=136,0xfff8,0,0,dpigs[ceil(r"4")].fd
dnum+=1
end

function draw_pig(pn)
if pn==1 then
px,py,fp=56,17,false
elseif pn==2 then
px,py,fp=56,112,true
elseif pn==3 then
px,py,fp=1,60,false
elseif pn==4 then
px,py,fp=112,60,true
end

spr(4,px,py,2,2,fp)

if dpigs[pn].timer==0 then
circfill(px+7,py-9,8,15)
spr(dfood[dpigs[pn].fd],px+4,py-12)
end
end

function g_init()
g_pl,g_pll={t=4,x=64,y=64,r=3,a=.25,s=0},100
g_mobs={g_pl}
for n=1,g_lvl do
add(g_mobs,{t=2,x=r"100"-50,y=r"100"-50,a=r(),s=r".5"+.1,r=r"10"+5})
end
end


function g_colr(n)
return sget(g_lvl%16,n+64)
end


function done(n,txt)
pp(txt,35,50,10) 
for i=1,75 do 
flip() 
end
ret(n)
end

function warp()
sfx"14"
for w=1,16 do
cls()
for v=0,8191 do
poke(0x6000+v,rnd"256")
end
flip()
end
end

function make_wave()
add(fv,{x=130,y=rnd"18",r=rnd"1"})
end

__gfx__
99900999444004449990099900000440000009994440044409900000000000440000000000000000000000000000000067787787777787760e80000000000000
9000000944000044900000094404444090000009440000440999909004444044000ff000000aa000000bb0000eeeee007722872772822787e788000000000000
909999094400004490000009040000009999090940040004000000000400000400ff7f00009aaa0000bbbb00eee0eee072442242242442278882000000000000
00900000000000000000000004444040000009000044040009909990000444000ffff7f0009a0a000b0bb0b0e0eee0e024444444444444420820000000000000
90999909440000449000000900000040909999094000044400000000040004000ffffff0009aaa000bbbbbb0eeeeeee012444444444444210000000000000000
900000094400004490000009044444409090000940444444099909900444440409fffff0009aaa000b3333b0e22e22e000000000000000000000000000000000
9990099944400444999009990000044099900999400000440000099000000004009fff0000999900030000302002002000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000033377333333333cc3333333339aa3333000ff00000077000000100000000000000000000000000000000000000000000
00000000000000000000000000000000337777333333cccc3333333339aaa33300fff00000077000011101000011000000000000000000000000000000000000
00000000000000000000000000000000377aa773333cc1c3337537369aa5aaa300ff000000055000011001100111100000000000000000000000000000000000
0000000000000000000000000000000077aaaa7733ccccc33775756d9aaaaaaa0f0000f007577570000011100001110000000000000000000000000000000000
0000000000000000000000000000000077aaaa7733cccc33775776579aaaa5aa000ff0ff70077007110011001100000000000000000000000000000000000000
00000000000000000000000000000000377aa773ccccc333cccccccc9a5aaaa3ff00f0ff00055000111010000110011000000000000000000000000000000000
00000000000000000000000000000000337777333cc333333cccccc339aaa333fff000ff00700700011000000110111000000000000000000000000000000000
000000000000000000000000000000003337733333c3333333cccc3339aa33330ff0000007700770000000000000110000000000000000000000000000000000
551551550000000000bb000000000000000000000000000070777070000000000011000000110000000000000000000000000000000000000000000000000000
111111110000000000b3000000000000000000000000000077777770000000000111011001110110000001100000000000000000000000000000000000000000
14441555000000000004bb0000000000000777700007777070777070000000000110011001100110000101110000000000000000000000000000000000000000
111111110244006000b440b000900000007707000007070000777000000000000100000000000011001100111111011100000000000000000000000000000000
555155150ee446660b0550000aa90000000777700007777070777070000000000001100000111000011100001110111100000000000000000000000000000000
111111110ef422000005050000000900000000000070000077777770000000000000110000011110011001100000000000000000000000000000000000000000
1555122200420000000d00d000000000000000000000000070777070000000000110111000001100001011100000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000110011000000000000010000000000000000000000000000000000000000000
d600000000e8000000000000dddddddd777070007770777077707770777000000000000000000000000000000000000000000000000000000000000000000000
d60000000e87600000000000d111111d700070007070707070007700707000000000000000000000000000000000000000000000000000000000000000000000
d65d000000465007000a0000d5d1111d777070007070777070707000770000000000000000000000000000000000000000000000000000000000000000000000
115d00000007700600a99000d5d0000d700077707770700077707770707000000000000000000000000000000000000000000000000000000000000000000000
115d1500006dd0700aaa9900d5d1500d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111115000d077d6000999000d5d1500d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111115000006d00000000090d5d1501d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111110000d0050000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd6600008990000a7700000000000000bbb300500000000008828f009aa70000000057007777d0777707777747777033000333330003333000033330000330
0ddd66600889a900aaaa700000000000033bbbb00000005002088888aa9aaa9a0005717100771770177107767141771033000333330003333300033333000330
5dddd6664889aa909aaa7000000000004bbb33bb00000000272028209099a90a0001171600777710777707717704774030000033300000333300033333000303
5ddddd66488899909aaaa0000000000033bbbb3b000b000002000200044999a00001717500111100111101101100110030000033000000033330003333300033
55ddddd648888880099a00000000000035333b3b0000b00b074f72f000444400005155500007770d760d7707477d47d030000033030003033300000333000003
55ddddd6048888000000000000000000035533500030303007f277f0000220000015000000077d07170711074717471733000333330003333030000333300003
055ddd600044400000000000000000000005250005522445274f42f000499a000010000000071701770177074747477733030333330303330330330333303303
005556000000000000000000000000005552200000000000f2002f20000000000210000000014104110411014141411130030033303330330300300333003003
00dddd000089900000dee0000000000000888800007780000077800000077800000d7700008d77000008d7000008dd0033343333333333333333333333333333
0dddddd0088999000ddefe0000000000007777000077778000d7780000d77800088d7780008d7700008d770008dd7700333543333333333333bbbb3333333333
dddddddd487997902ddeffe0000000000077770000dd7780088d7780088d7780081d778008d7788008d778800877770033335433333333333b7bb7b333333333
dddddddd488899902dddeee00000000000dddd000888dd100818d780081d7780081d778008d7787008778870017788803333354333333333b7b7bbbb33333333
dddddddd487777802dddddd000000000008118000821882001818810018288100888888001888d1001888d1002888d7033a3a35433333333bbbbbb7b33333333
dddddddd0487780002dddd000000000000888800012881200118811002881120011111100211872001187110021871104a4a4a4433333333bbbb7bbb33333333
0dddddd00044400000222000000000000011110002111200021112000211210002122120021211200221112000211120444444443333333333bbbb3333333333
00dddd00000000000000000000000000001111000221120000221000002122000222220000221200000212000021122055555555333333333334233333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333337c3bb34233333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333337c3c33cbb34233333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033666d33c33c33333324233333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036dd55d333337c333334233333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006dd66d5d333c33cc3334233333333333
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd5555d57c3333333334233333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333c333cc3344443333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333ccc333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333a333333333a33333aa333
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003366663333aa33333a33aaa3333aa333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036dd65633aaaaaa33a3aaa33333aa333
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006dd6d6563aaaaaa33aaaa3333aaaaaa3
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd6d556533aa33333aaa333333aaaa33
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333a33333aaaaa33333aa333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
0ce986c8f9edbae7bbffffbbfb4444bf3333330003333333000000000000000011b0000c111111112222999922224444bbbbbbbbbbbbbbbb44444444fdddffff
baa8aa99c3d8eeacb000000bf444444f333300eee033333300000000000000001d10000a11111e114444999944444400bbbb0000000bbbbb44444444ffffdffd
8123ee30e1823638b00ff00b847070483330eeee7e033333000000000000000011123000004511d14444999944440000bbb00ddddd000bbbddddddddf000fff0
baa8aa99c3d8eeacbbf99fbb82effe28330e67eee0033363000000000000000011111123000045114444999944000000bb00dddddddd00bbbbbdbbbd00700ff0
c77777777777777955ffffbb82f00f2830ee6eee0ee0336300000000000000001111d111230000119999224400000000bb0ddddddffdd00bbbbdbbbdf704fff7
00000000000000005677775b2889988233006eee0ee03063000000000000000011d11111112300119999440000000000b00dddddffffdd00bbbdbbbdffffffff
000000000000000050000005b288882b330e0eeee00d030300000000000000001e10000045890011994400000000000000dddddddffffdd0bbbdbbbdffffff9f
000000000000000096677655b288882b30ee0eeeeed033030000000000000000111b00000000001144000000000000000ddddddffdfffdd0bbbbbbbbffffeee0
77767666b111111bf000ff55b288882b30e00eeeee0333030000000000000000111100c230006711442299992222999900ddddd00ffffdd0ffdffffdddddfffd
76666666b41a914bb6669955b666666b444444444444444400000000000000001111001111111111004499994444999900ddddd700fffdd0fffdffffffffffff
76666665b110010bb055550bbf7777fb444444444444444400000000000000001890061e1d1111110000449944449999b0dddd704ffffdd0ffffdffdf000fff0
66666666b10bb10bb000000bbff77ffb4430eeeee833334400000000000000001000011111111d110000004444449999b0ddddfffffffdd0f000fff000f00ff0
76666665b10bb10bb00bb00bbffbbffb4430eeeee833334400000000000000001000045894111e11000000004444222200ddddfffff9fdd00fff0ff0ffffffff
66666665b10bb10bb00bb55bffbbbbff44330ee0ee0333440000000000000000100000000011d11100000000004444440ddddffffeeefdd0fff0ffffffffffff
66666660b10bb10bb4bbb55bffbbbbff443330e00e0333440000000000000000100000000045111100000000000044440dddddffffff0dd0ffffff9fbfffff9f
66565500bbbbbbbbbbbbb44b44bbbb4444330003300033440000000000000000123006710000111100000000000000440ddddd000000ddd0ffffeeffbffeeeeb
bb4444bbbb4444bbbb4444bbbb4444bb33333333333333333333333333acc6631111111100004511bb0000000000000000ddd00ffff00dd0bb00000bbb00bbbb
b444444bb44444bbb444444bbb44444b3333333333333333333333336aac5c66111111e12300004133bb0000000000000dddd2000fff0dd0b0ccccc0b0aa0bbb
b470704bb44970bbb444444bbb07944b33333333333333333333336bbaccc55d18904511112000014433bb00000000000ddd222200002dd00cc70ccc0aaa0bbb
bbffffbbbb5fffbbbb4554bbbbfff5bb3333333333333333333336bab35ccc9d100000a890000001444433bb0000000000d2222222222d0b0cc00cccaaaa0bbb
bbf99fbbbbbff9bbbbf99fbbbb9ffbbb333333333333333333676baa955554ee100000000000000199992233bb00000002d202222222220b0cccccccaaa0bbbb
b888888bbb888bbbb888888bbbb888bb333333333333333336666baa9421139312300000000636719999444433bb00000fd202222222220bb0ccccc0aaaa0bbb
82888828bb8828bb82888828bb8288bb33333333333333336bb6baaa944433331d123000067d1111999944449933bb000f22022222222000bb0ccc0b0aaa0bbb
82888828bb8822bb22888822bb2288bb333333333333333bbbbbbaaa9e4433331111111111111d1199994444999933bb0ff00222222200f0bbb000bbb000bbbb
82288228bb2882bb22222222bb2882bb33333333333333bbbbbbbe999e4333332222999900ccab0000000000000000bb0ff00222222200f0bbbbbbbbbbbbbbbb
9f4994f9bb449fbb94444449bbf944bb3333333333333bbb3bbbc449ee4333334444999900ccccab000000000000bb33b0f0002222220000bbbbbbbbbbbbbbbb
bf1111fbbb11ffbbb111111bbbff11bb33333333333bbcccbbb64524443333334444999967cc00ef0000000000bb3399b0000222222220bbbbbbbbbbbbbbbbbb
b110011bbbb00bbbb110011bbbb00bbb3333333333bbbbbbba69555513333333444499990067efcc00000000bb339999bbbb02222222200bbbbbbbbbbbbbbbbb
b10bb01bbbb01bbbb10bb01bbbb10bbb333333336bbbbbabbabb55533333333399992222cc23ccca000000bb33992222bbb022200022220bbbbbbbbbbbbbbbbb
b10bb01bbbb01bbbb10bb01bbbb10bbb3333366bbbbbcc966abbb333333333339999444423007ccc0000bb3399994444bb02220040000000bbbbbbbbbbbbbbbb
b10bb01bbbb01bbbb10bb01bbbb10bbb3333bbbc33333333c6aba666f333333399994444fc27360000bb334499994444bb00004440044440bbbbbbbbbbbbbbbb
b44bb44bbbb444bbb44bb44bbb444bbb3336c33333333333336666f6ff33333399994444ccafbe00bb33444499994444bbbb000000000000bbbbbbbbbbbbbbbb
00004444000000000000044400000000116110000000000000000000000000000003000000003000000300000000300033ff94333333333333333333337b3233
0004444466600000000044444000000011611000000000000000000000000000000303333330300000030333333030003f999443333ff93333b433333b313313
0ff44444000666660000444440000000116110000000000000000000000000000003333333333000000333333333300099994d44339d94433333333337bbb312
0ff1fff40000006600004ffff00000001161100000000000000000000000000000003313313300000000331331330000d994d2d439d6d94433333b43b3311331
08821f1f300000660000ff1f1b20000011611000000000000000000000000000000003333330000000000333333000007ddd646346777dd333333333bbbb3b31
0882fff3b300000000000ffffb28000011611000000000000000000000000000000003aaaa300000000003aaaa30000077776663369476623343333331000001
02882222b30000000002b555b3280000116110000000000000000000000000000033663333333300000066333333000069476d52364476223333333332294011
02288882b300000000283bbbb3280000116110000000000000000000000000000333663333333330003366333333330034465225333333333333333333210113
00008883bb300000008883bbb3880000d5cd5000cd5cd0005cd5c000000550000333366333330333033336633333330033333333fffff5ff6242424633221133
00002223b3300000000883bbbb880000cd5cd0005cd5c000d5cd5000005555503330366633330033033336663333333033fb1233ff4ffff45042422532111113
00001bbbbb3000000008883bb38830005cd5c000d5cd5000cd5cd00005555555330033666333003333222366633303302bd2ff02ffffffff6242422632a21a13
000013bb33300000000082b333883000d5cd5000cd5cd0005cd5c0005555555533003336663300333321233666330330bddbb6d1ffff4fff5022424552122110
00001bbbbbb300000000288bbb883000cd5cd0005cd5c000d5cd5000555555503300333366330033032223336633033033bb333df5ffffff6222424601a49410
000003333333000000000888bff240005cd5c000d5cd5000cd5cd00055555550333003336660033003332333666033003b333b33ffffff5f5042424595080059
00000444999400000000048ffff2400005cd00000d5c00000cd50000055555003300033336600330003303333660330033333333fff4ffff6242224632551175
00009949999400000000044ff62440000050000000d0000000c000000000000003300333366000000000033336600000333333334fffffff5042224532100610
0000a949999000000000049406444000006770000333000000700000000000000111555555550000000a000002200000ff1110556d004110ec5cd5dee994944e
0000a99499400000600004990649900006ccc7003ff3300006970000005500000011335555330000000a000002220000f166d00500002750ecdddddee944442e
000a9940aa400000000049a900644400dccccc70f0ff30006489700005555500001133555533000000aaa0000222200017868d05f0002d60c509905d94099042
000a99404444000006004994006444005ccccc703ff3300006470000555555500011335555333000aaa7aaa00021200017d6dd10ff000205cf0ff0fd4f0ff0f4
000a99400444400000049990006444005ccccc603333330000d0000055555550000333555503330000aaa0000021120017766d10ff100405e89ff92ee29ff91e
00a9940000444000000699400064440005ccc6002b2b2b0000000000055555000033305555033300000a00000022120011707100f11102258212212221011011
005555000045550000055600006655000055d0000000000000000000005550000033305555003330000a000000021120100011001d500020f944449ff22aa22f
005550000055550000555500606655000000000000000000000000000000000003333355550333300000000000ff21227d00a005ff11d525ed500d5ee820082e
ff000000ff0000000f000000000000000099109109109109991091099109910000333355553333000033000033300000eeee002a11111111bb7b3b7b33377333
f00000000ff000000f000000000000000091919191091910091919191919100000003335533300000333330033333000eee04411111116c130b302b333767633
0000000000000000f0000000000f000000a1a1a1a10a1a10a10a1a1a1a1a100000003335533300000333333666333300eee07850111111112232222233666d23
0000000000000000f0000000ff0ff4f7a1aa10a1a10a1a10a10a1a1a1a1aa1a100003335503300000033335553303300ee076d4016c1111144249902366d6d53
0000000000000000000000000f444f0700a100a1a10a1a1a100a1a1a1a1a100000033300003330000033335533333300e076d00e111111119924942266ddd452
00000000000000000000000000ffff0f9191009191091919100919191919109100333300003333003333335533333333076d0eee1111111194444442d66dd552
00000000000000000000000000ffffff009100919109191910091919191910000333333000033330033335553333333306d0eeee1116cc11944244425d455550
000000000000000000000000000ffff00081008108108108881081081818810033333030000033330305555550033333000eeeee111111112422442235520003
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020001000000000000000000000000000101010000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404040404040404040404040404000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
202020202020202020202020202020200000000000000000000000000000000000000000000000005e000000006c0000000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000ffffddddddddffffffddddddddddddddddddddffffddddddffffddddffffddec
200000000000000000000000000000200000000000000000000000000000000000000000000000006e00005e00000000000000000000000000000000000000004000004040400040000040404000004000000000000000000000000000000000ffdddddddddfddffddddffffffffffffffddddffddddddddffddddddddffdded
2000000000000000000000000000002000000000000000000000000000000000006c00005e0000000000006e0000000000002a2b2b2b2b2b2b2b2b2b2b1b00004000400000000040000000000000004000000000000000000000000000000000ffddddddddddddffdddfddffffddddddddddddffddddffddddddffffddffddff
2000000000000000000000000000002000000000000000000000000000000000000000006e0000000000000000005e00000028000000000000000000002800004000400000000000000040004000004000000000000000000000000000000000fffefedefeffddddffddddffffddddffffffffffddddffffffffffffddffddff
2000000000000000000000000000002000000000000000000000000000000000000000000000006c006d6d6d6d6d6e00000028000000000000000000002800004000400040404040000040004000004000000000000000000000000000000000ffffdcdcdfffffddddddffffffddddddddddddddddffffdcdcdcdcffddddddff
200000000000000000000000000000200000000000000000000000000000000000005e00000000006d6d6d6d6d6d0000000028000000000000000000002800004000000000000000000040000040004000000000000000000000000000000000ffdcdcdcdcdcffffffffffdcffffffffffffffffffdcdcdcdcdcdcdcffddddff
200000000000000000000000000000200000000000000000000000000000000000006e00000000006d6d6d6d6d000000000028000000000000000000002800004000404000004040004000004000004000000000000000000000000000000000fffedefefefefefedcdcdcdcdcffffdcdcdccedcdcdccececececedcdcffffff
2000000000000000000000000000002000000000000000000000000000000000005e6d6d6d5e000000000000006c0000000028000000000000000000002800004000404000000000000000004000004000000000000000000000000000000000ffdcdcdcdcdcdcdcdcdccecedcdcdccececfcececececececccecfcfcedcffff
2000000000000000000000000000002000000000000000000000000000000000006e6d6d6d6e000000005e0000000000000028000000000000000000002800004000000000400000400040400040004000000000000000000000000000000000ffffdcdcffffdfdccecececececececececececfcfcecececececececececeff
20000000000000000000000000000020000000000000000000000000000000000000000000000000006c6e0000000000000028000000000000000000002800004040400000400040000000004000404000000000000000000000000000000000ffffdcdcffffdccecececefefececfcecececffefececececececedcdccecfff
2000000000000000000000000000002000000000000000000000000000000000006c0000000000000000000000000000000028000000000000000000002800004000004040000040004000400040004000000000000000000000000000000000ffffcedcdcdccecececefefdfdcececececfcffdfdfecedfcecedcdcdcceceff
200000000000000000000000000000200000000000000000000000000000000000000000005e000000000000000000000000292b2b2b2b2b2b2b2b2b2b1a00004000000000000040400040000000404000000000000000000000000000000000ffcececececececedfcffdfdfdcececececfcffdfdfdcececececececececeff
20000000000000000000000000000020000000000000000000000000000000005e000000006e00000000006c6d6d6d6d000000000000000000000000000000004000004040004040000000400040004000000000000000000000000000000000ffcfcecececfcfcececffdfdcecececececececececececececedfcececfffff
20202020202020202020202020202020000000000000000000000000000000006e0000006c000000005e006d6d6d6d6d000000000000000000000000000000004000000000000000400040004000004000000000000000000000000000000000ffcfcfcecececececececececececececececececececececececececfcfffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000006e006d6d6d6d00000000000000000000000000000000005050505050505050505050505050505000000000000000000000000000000000ffcfcfcecececececececececececececececececececececececececfcfffff
000d0f0d0d0f0d0d0d0d460f494a4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfcecfcececececececfcecececfcecececececececececececececeffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcecececececfcfcececececececececececececececececfcedfcececeffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcececfcfcfcfcfcecececececececececececdcccecececececececedcff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfcecfcccdcfcfcecececececececececececececececececececedcdcff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfcecfcfcfcfcececececececececececececececececececedcdfdcdcff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfcececfdfcfcececececececececececfcfcfcecedcdccedcdcdcdcfefe
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffcecececfcfcececececfcfcecfcfcecedcdccfcfcefefefefefefefefdfd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffcfcecececececfcffefefedefefefefefefefefefefdfdfdfdfdfdfdfdfd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfcfcececfcfcffefdfdfddefdfdfdfdfdfdfdfdfdfdffdccecfcfcfcffd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfdfcfcfcfcffffefdfdfdfddefdfdfdfdfdcececefdfddccecececfcfcffd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfcfcffffffffdfdfdcececedcdcdcdcdcdccecfcefdfedefefefedefefd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffcfcfcfcffefdfdcecedfcecedcdcdcdccecececefdfddefdfdfddefdfd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffcffdfdcecfcfcecececececececefedefefdfddefdfdcececefd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffdfcfcfcfffcffdfdcecfcfcfcecffefecececffdcecedfcececefdcecdcefd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffcfcfffcfcfcffdfdfececfcecefefdfdfefefefdcececfcffefefdcedcdcfd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffefefdfdfdfefefefefdfdfdfdfdfdfdfefefefefdfdfdfefefefd
__sfx__
010600002b15535236303273041500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000024554270042755429004295542d0042d55400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000b6550b65504200012000b250072400423001210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001b62601603016000160020646016000160001400286660140001400024000100000000000000000001600000000000000000000000000000000000000000000000000000000000000000000000000000
011b0000022250e225022250e225022250e225022250e225022250e225022250e225022250e225022250e2250722513225072251322509225152250922515225022250e225022250e225022250e225022250e225
011b000000523000003c6130000000523005233c6130000000523000003c6130000000523005233c6130000000523000003c6130000000523005233c6130000000523000003c61300000005233c6133c61300000
011b00000000026425244252642529425264252442526425000002642524425264252b4252642524425264252d425000002d425000002b4250000029425000002942526425244252642500000000000000000000
010300003522134221332213322134221392213b2210000007232062320523204232032320223201232000003632038320393203a320000000000000000000000000000000000000000000000000000000000000
000600000d420166100e6300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000210112e025000002e015000002e0150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000160101f0112801035026000003c026000003c016000003c015000003c0130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c61007600076100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000505002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070006016301c621296100160000600006000060000600006000060000600006000060000600310000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200001a010262100e3102c0101361016210106102201019010146101f3102321019610090102061023610256101b6101b6101101026310196102c6102b610216100f3101f2102e01016610146103701019610
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000000500015000013501255010750c65502175012450015501561020710156100151015650a775107351371014735147201573516750167351775018765197501a7701b7401c7251e7501f7452272027310
0014000027535287651b50527565285351b50524565275052e7352d0652e5352d7652b0352d56502505015052b5301f5311f7350150500505015052b5001f5011f505015051b7351c5651f037217652753528065
001400000c033001550f0451031500155001450f04510315001550c033185130f045113150f04510315001450c033051551404515027185130515515025163150c0330715518315110450c615131450f14501021
00140000001550c04315315160450c6150c03315315160450c0330015505100153151604515315160450c043051550c0431a0171b0450c6150c0251b3151c025071550c033161150c033071452b5150d0110c033
000300000a660093500a640073400b3600864007330073300533004320066200f3200a32007320043200432004640036300d3100931007310033100564007620096000b6100262006310026100c3100160003610
010100001b610196101b610196101b610196103f6003c600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000f070110700d0700a070080700607005070040700f0000e0000d0000d0000d0000d2000c2000d2000d2001e1000d1000d1000d1000d1000d1000d1001310013100131000310003100031000010000100
010400002015020150211502215024150271502b150341502b1003410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001334007131074210711500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010e00000024022200282002b20000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010400002973000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
01040000243461f3461c316183161f3461c3461831618316243461f3461c3161831628346243461f3461834628346243461f3461834628346243461f3361833628326243261f3161831628300243001f30018300
011000000d153000000d153000000000000000000000000000000000000d153000000d15300000000000d1530d153000000d153000000000000000000000000000000000000d1530d1530d1530d1530000000000
011000000960000000000000000004650046000560000000000000000000000000000465000000000000000000000000000000000000046500000004650000000000004650000000000004650000000000000000
011000001b4001b4001b4231b4231b4231b4001b4231b4231b4001b4001b4001b4231b4231b4231b4231b4231b4001b4231b4231b4231b4231b4001b4001b4001b4001b4231b4231b4231b4231b4231b4231b423
001000000a0550a0551b0551d0550a0550a0551b0551d0550a0550a055180551b0550a0550a055180551b0550a0550a0551b055180550a0550a0551b055180550a0550a05511055110550a0550a0551f05522055
001000001b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012800001a3241a322193241932218324183221732417322173221732217325173000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000133500000018350000001c350000001f3500000000000000001c350000001f3501f3501f3501f3501f3401f3301f3201f310000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003437500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001c37300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002442300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000011660116600537409374093700937015473000000000000000000001f6730527105271054710547100000000000000000000000000000000000000000000000000000000000000000000000000000000
011200000c05015015100500c0151305010015150501301516050150151505016015130501501510050130151105010015150501101518050150151a050180151b0501a0151a0501b015180501a0151505018015
0112000004050241001c1351c1051b1351c1351c1050c6001c1351c1001b1351c1351c10004050070500c0500905018100211350c6002013521135181000c6002113518100201352113518100000500405007050
0112000000005000050c6350000000000000000c6350000500005000050c63500005000050c6050c6350000500005000050c6350000500005000050c6350000500005000050c63500005000050c6050c63518635
01030000241102611128121291212a1312a14129151291512a1412b1312b121291212912128111271112611125111241112610119101311013010130101311013010130101302003020000200002000020000200
012000201f7621f7551811618116181161a7421f75222752217521d7521a7521d7521f7621f7551811618116181161a7521d752217521f7521a75216752187521a7621a7551811618116181161a7421d7521a742
012000200e1420e135246251f002240050a1222462513132111320e132246250c1320e1420e1352462500002240050a12224625111320e1320a13224625091320a1420a1352462500002240050a122246250a122
011000202b03524015260352b0152b035260152e0352b0152d0352e015290352d015260352901529035260152b03529015260352b01529035260152d035290152b0352d015260352b01522035260152403522015
010100000e6301162015640186201c6401f6202364026630296502d6303065034630376503b6303e66034600180001a0001c0001d0001f0001800018000180001800018000180001800018000180001800018001
000100003b77038770327702f7702a7702677024770217701f7701e7701d7701c7601a7601776018760167601777016770157701376012760127501175010740107400f7400f7300f7300f7300e7300d7300d730
001000000e050000000e05010050100500d0500000000000000000e0500e050100500000010050110500000000000130500000000000110501105010050000000000000000110501105000000110501005000000
001000001861000000386100000000000000001161000000000000000035610000000000000000000001361000000376100160037610000000000000000096100000038610000000000000000000000000000000
001000001d05021050230500000016050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0500000018050000000c0500000018050000000c05016050180501b0501b0520000018050000000c0500000018050000000c0500000018050000001105013050160501305011050130500f05000000
011000000c133002050c1031d6031d613000001b00000000180501b0501d0501f05020052000001f050000000c103000001b000000001d603050001b000000001305016050180501b05018050160501805000000
011000000c133002250c1530c1531d6230c1530c153002250c1530022500225002251d6231d62300205002250c1530022500225002251d6231d6030c1530c1530c153002250c1530c1531d6230c1530c15300225
011000000f0500c1531b050032250f0501d6231b0500c1530c1530322503225032251d6231d623032250c1530f0501d6231b0500c1530f050032251b0501d6231d623032250c1530c1531d6231d6231d6231d623
0001001f0261002610026100261002610026100261001610016100161001610016100161001610016100161002610026100261002610026100261002610026100261001610016100161001610016100161001610
000100000f6201762022620306203f62034620336202f6202c620276201f6201c6201d600246002b60031600396003d6003f60000000000000000000000000000000000000000000000000000000000000000000
010100002c0103d6103d6103d610296102361022110381102b110116102b1101161033110261100d6102a610096102d11035110251103b610036102e6102011033610331102e61026110371102f6103061027010
000500001d0100a000336002c600296002360022100381002b100116002b1001160033100261000d6002a600096002d10035100251003b600036002e6002010033600331002e60026100371002f6003060000000
000f00000d0500e050000001005000000160500c0500c0500c0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000372006720097200d720117201472016720197201a7201d72020720227202870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000002610096000660003600056000a6000560003600066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002e5101d51024510375102e5103f51031500080000b0000e00011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 04 05 43 44
00 04 05 43 44
00 04 05 06 44
02 04 05 06 44
00 1c 42 43 1f
00 1c 42 1e 1f
01 1c 1d 1e 1f
00 1c 1d 1e 1f
00 1c 1d 43 44
00 41 42 1e 44
00 41 42 1e 1f
02 41 1d 1e 1f
01 12 42 43 44
00 12 13 43 44
00 12 11 43 44
02 41 13 43 44
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
00 41 42 2e 44
00 2c 42 2e 44
03 2c 2d 2e 44
03 28 29 2a 44
00 41 42 43 44
04 31 32 43 44
04 41 42 33 44
04 41 42 43 3c
01 34 42 36 44
00 41 35 37 44
00 34 35 36 44
02 34 35 36 44
