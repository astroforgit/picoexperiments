pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

g_a=0
g_b=0
g_c=0
g_d=0
g_e=7
g_f=50
g_g=0.075
g_h={tr=0,cb=13,m=6,fr=7}
g_i={tr=9,cb=13,m=1,fr=0}
g_j={tr=10,cb=13,m=1,fr=0}
g_k={tr=2,cb=13,m=6,fr=7}
g_l=20
g_m=7
g_n=8
g_o=19
g_p=1000.0/30.0
g_q=0
g_r=0
g_s=false
g_t=false
g_u="ai;-667;-2;you had no right! go away!;;ai;-123;1;no! please! what do you want?!;;bye;2;-1;leave me alone!;;bye;3;0;bye;;bye;4;0;see you around;;bye;5;1;take care;;hi;6;-2;mhm;;hi;7;0;hello;;hi;8;0;hey, you!;;hi;9;1;good to see you;;cmd;11;-1;follow me;exit this valley with me;cmd;12;-1;stay here;;ai;20;0;i will join you there;;ai;22;0;i don't understand;;ai;23;0;i don't understand;;ai;24;0;i don't understand;;ai;25;0;what?;;ai;26;0;repeat that?;;ai;27;0;please, repeat that;;ai;28;0;please, explain;;que;101;1;how is your day?;;ans;102;-1;leave me alone!;;ans;103;0;not your buisness!;;ans;104;0;too tired to do anything;;ans;105;0;it could be better;;ans;106;0;nothing special;;ans;107;0;quite good;;ans;108;0;good, thanks;;ans;109;1;great day, well rested;;que;111;2;do you need help?;;ans;112;-2;leave me alone!;;ans;113;-1;not your buisness!;;ans;114;0;i don't need your help;;ans;115;0;i think i can handle this;;ans;116;0;no needed;;ans;117;0;no, but thanks;;ans;118;0;thanks for asking, no;;ans;119;1; i'm good, thank you;;st;200;1;bridge is destroyed;;que;201;-1;who else lives here?;;ans;202;-2;leave me alone!;;ans;203;-1;not your buisness!;;ans;204;0;i don't know anyone here;;ans;205;0;i think i'm alone here;;ans;206;0;i only know %ai%;;ans;207;0;I know %ai% and %ai%;;ans;208;0;%ai%, %ai% ;;ans;209;1;%ai%, %ai% and maggus;;st;210;2;my name is...;;que;211;0;what is your name?;;ans;212;-1;leave me alone!;;ans;213;0;not your buisness!;;ans;214;0;and yours is?;;ans;215;0;...;;ans;216;0;...;;ans;217;0;my name is...;;ans;218;1;my name is...;;ans;219;1;my name is...;;que;1021;-3;someone in your house?;;ans;1022;-1;leave me alone!;;ans;1023;0;not your buisness!;;ans;1024;0;no;;ans;1025;0;who knows?;;ans;1026;0;maybe? why?;;ans;1027;0;yes;;ans;1028;0;yes, why?;;ans;1029;1;yes, there is…;;que;1031;-6;can I check your house?;;ans;1032;-1;leave me alone!;;ans;1033;0;definetely no!;;ans;1034;0;no;;ans;1035;0;i prefer not;;ans;1036;0;i guess, but quickly!;;ans;1037;0;yes;;ans;1038;0;yes;;ans;1039;1;yes, no need to ask me;;que;1041;0;someone new?;;ans;1042;-1;leave me alone!;;ans;1043;0;not now;;ans;1044;0;no;;ans;1045;0;didn't pay attention;;ans;1046;0;maybe?;;ans;1047;0;yes;;ans;1048;0;yes;;ans;1049;1;yes, name was...;;que;1051;0;where is ...?;;ans;1052;-1;leave me alone!;;ans;1053;0;i will not tell you;;ans;1054;0;i don't know;;ans;1055;0;somewhere around;;ans;1056;0;hm, around...;;ans;1057;0;hm, around...;;ans;1058;0;hm, around...;;ans;1059;1;hm, around...;;st;2000;1;came here today;;st;2010;2;i'm looking for a mage;;st;2020;2;i'm bounty hunter;;st;2030;2;nice weather today;;threat;2200;-10;kill you;i will kill you;threat;2201;-10;kill your family;i will kill your family;threat;2202;-10;tell your secret;i will tell your secret;threat;2203;-10;found the diary;i found the diary;threat;2204;-10;guards will find you;i will tell guards about you;threat;2205;-10;destroy your home;i will destroy your home;ai;2300;-1;leave me alone!;;ai;2301;-1;leave me alone!;;ai;2302;-1;you hear me, leave me alone!;;ai;2303;-1;last time, leave me alone!;;ai;2304;-1;...;;ai;2305;-1;...;;ai;2306;-1;...;;ai;2307;-1;...;;ai;2308;-1;...;;ai;2309;-1;...;;ai;2310;0;mhm;;ai;2311;0;mhm;;ai;2312;0;mhm;;ai;2313;0;i see;;ai;2314;0;now i know;;ai;2315;0;good to know;;ai;2316;0;good to know;;ai;2317;0;thanks for telling me;;ai;2318;0;thanks for telling me;;ai;2319;0;thank you for saying;;"
g_v={}
g_w=1
g_x=1
g_y=1
g_z=false
g_aa=false
g_ab={rv=0.0, d=false, u=false}
g_ac={rv=0.0,lrv=0.0, d=false, u=false}
g_ad={rv=0.0, d=false, u=false}
g_ae={rv=0.0, d=false, u=false}
g_af=false
g_ag=false
g_ah=false
g_ai=0
g_aj=0
g_ak=false
g_al=0
g_am=0
g_an=64
g_ao=30
g_ap=0
g_aq=0
g_ar=80
g_as=0
g_at=0
g_au=0
g_av=128
g_aw=128
g_ax=0
g_ay=0
g_az=false
g_ba=false
g_bb=1
g_bc=false
g_bd=false
g_be=false
g_bf=0
g_bg=false
g_bh="maggus"
g_bi=nil
g_bj={
192,193,194,195,
208,209,210,211,
}
g_bk={
132,133,134,135,
136,137,138
}
g_bl=true
g_bm=false
g_bn=false
g_bo=0
g_bp="alys;merek;anastas;ulric;tybalt;alianor;carac;borin;millicent;ayleth;"
g_bq={"key","type"}
g_br={}
g_bs={}
g_bt=g_h
g_bw=g_l
g_bx={}
g_by={}
g_bz={}
g_ca={}
g_cb={}
g_cc={}
g_cd=nil
g_cf={}
g_cg={}
g_ch={}
g_ci={}
g_cj={}
g_ck={}
function f_a()
g_bl=not g_bl
music(g_bl and 1 or -1,0,7) 
menuitem(2,"turn music"..(g_bl and " off" or " on"), f_a)
end
function _init()
f_b()
menuitem(2,"turn music off", f_a)
menuitem(3,"show controls", function() g_bg=false end)
end
function _update()
if not g_bg then
if btn(4) or btn(5) then
g_bg=true
f_f()
return
end
end
f_i()
if g_ba then
g_al=min(max(0,g_cb.x-g_an+g_ap),896)
g_at=min(g_cb.y-g_ar+g_as,128)
g_am=f_ao(g_al)
g_au=f_ao(g_at)
g_ax=g_al-f_ap(g_am)
g_ay=g_at-f_ap(g_au)
f_o()
f_p()
end
end
function _draw()
if g_bg then
f_q()
else
f_s()
end
end
function f_b()
f_g()
f_e()
f_d()
f_c()
end
function f_c()
local bs="64;65;66;67;68;69;70;71;80;81;82;83;84;85;86;87;"
local bsw="224;225;226;227;228;229;196;197;240;241;242;243;244;245;212;213;"
for i=1,125 do
for j=0,31 do
local contains, key=f_an(f_aq(bs),mget(i,j).."")
if contains then 
local obj={}
f_at(obj,f_ap(i),f_ap(j))
obj.spr=252
add(g_ci,obj)
mset(i,j,f_aq(bsw)[key]+0)
end
end
end
end
function f_d()
for i=-1,125 do
for j=-3,29 do
local el = {}
local obj=g_bj[flr(rnd(#g_bj))+1]
local ct=mget(i,29-j)
local ct_d=mget(i,29-j+1)
if(j>10 and rnd(10)<4) obj=g_bk[flr(rnd(#g_bk))+1]
if obj~=nil and (ct~=253 and ct~=230) and (ct_d==253 or ct_d==230) and (ct<128 or ct>131) and ct~=89 and ct~=112 then
if (ct==1 or (i==8 and 29-j==4)) obj=g_bk[2]
el.spr=obj
local ts=15+f_ap(j) 
if not (i>3 and i<7 and j==25) then
el.x=f_ap(i)
el.y=128-f_ap(el.h or 1)-ts
el.flpx=rnd(10)<4
add(g_cj,el)
end
end
end
end
end
function f_e()
for i=0,8 do
add(g_cf,{
x=rnd(128),
y=rnd(20),
spd=1+rnd(4),
w=32+rnd(32)
})
end
for i=0,24 do
add(g_cg,{
x=rnd(128),
y=rnd(128),
s=0+flr(rnd(5)/4),
spd=0.25+rnd(5),
off=rnd(1),
c=6+flr(0.5+rnd(1))
})
end
end
function f_f()
g_ba=false
f_h()
f_k()
end
function f_g()
g_v=f_aq(g_u,f_aq("id;tid;ef;msg;msg_long;"))
foreach(g_v,function(dialog)
dialog.is_a_threat_or_a_command=(dialog.id=="cmd" or dialog.id=="threat") and true or false
end)
g_br=f_aq(g_bp)
end
function f_h()
if not g_ba then
local new_actor={}
g_ba=true
f_bp(new_actor,32,32)
g_cb=new_actor
end
end
function f_k()
local farmer={}
local royal={}
if(rnd(1)<0.85) f_ct(farmer,f_ap(19),f_ap(29))
if(rnd(1)<0.75) f_cz(royal,f_ap(114),f_ap(29))

local mercenary={}
f_cr(mercenary,64,32)

local recluse_spawn_pois={}
for i=0,127 do
for j=0,31 do
if(mget(i,j)==63) add(g_ck,{x=i,y=j})
if(mget(i,j)==61) add(recluse_spawn_pois,{x=i,y=j})
end
end
g_cc={} 

local recluse=recluse_spawn_pois[flr(rnd(#recluse_spawn_pois-1))+1]
del(recluse_spawn_pois,recluse)
f_dd({},f_ap(recluse.x),f_ap(recluse.y))

local spawn_poi=g_ck[flr(rnd(#g_ck-1))+1]
local recluse=recluse_spawn_pois[1]
f_dh(g_cc,f_ap(spawn_poi.x),f_ap(spawn_poi.y),f_ap(recluse.x),f_ap(recluse.y))

end

function f_i()
if not g_ba and (btnp(5) or btnp(4)) then
if not g_ak and not g_af then
g_ak=true
else
run()
return
end
end
if (not g_bg) return
g_q+=g_p/1000.0
if g_q>=3600 then
g_q-=3600
g_r+=1
end
f_l()
f_m()

f_n()

end
function f_j() 
local mins=g_c+(g_p/33)*g_g 
if mins>60 then
mins=0
g_b+=1
end
if g_b>=24 then
g_a+=1
g_b=0
end
g_c=mins
end
function f_l()
if(not g_ba) return
local mins=g_f+(g_p/33)*g_g 
f_j()
if mins>60 then
mins=0
g_e+=1
end
if g_e>=24 then
g_d+=1
g_e=0
end
if g_e>=g_l or g_e<g_m then
g_bt=g_k
g_bs=g_h
g_bw=g_l
end
if g_e>=g_m and g_e<g_n then
g_bt=g_h
g_bs=g_i
g_bw=g_m
end
if g_e>=g_n and g_e<g_o then
g_bt=g_i
g_bs=g_j
g_bw=g_n
end
if g_e>=g_o and g_e<g_l then
g_bt=g_j
g_bs=g_k
g_bw=g_o
end
g_f=mins
end
function f_m()
local lx=g_ab.rv
local ly=g_ac.rv
local la=g_ad.rv
local lb=g_ae.rv

local xa = btn(0) and -1.0 or (btn(1) and 1.0 or 0.0) 
local ya = btn(2) and -1.0 or (btn(3) and 1.0 or 0.0) 
local ab= btn(5) and 1.0 or 0.0
local bb= btn(4) and 1.0 or 0.0

g_ab.rv=xa
g_ab.u=xa==0 and lx!=0
g_ab.d=xa!=0
g_ac.rv=ya
g_ac.u=ya==0 and ly!=0
g_ac.d=ya!=0
g_ad.rv=ab
g_ad.u=ab==0 and la!=0
g_ad.d=ab!=0
g_ae.rv=bb
g_ae.u=bb==0 and lb!=0
g_ae.d=bb!=0

g_ac.lrv=ly
end
function f_n()
foreach(g_bx,function(obj)
f_ay(obj,obj.spd_x,obj.spd_y)
obj.upd(obj) 
end)
end
function f_o()
foreach(g_ci, function(this)
this.lx=this.x-g_al
this.ly=this.y-g_at
this.lx2=this.lx+8
this.ly2=this.ly+8
this.drwitfrm= this.lx<128 and this.ly<128 and this.lx2>0 and this.ly2>0
end)
end
function f_p()
foreach(g_cj, function(this)
this.lx=this.x-g_al
this.ly=128-g_at+this.y
this.drwitfrm=this.lx+8>0 and this.ly+8>0 and this.lx<128 and this.ly<128
end)
end

function f_q()
f_x()
if not g_ba then
pal()
palt()
f_w()
if(g_ak) f_t()
return
end
f_y()

f_ab()

f_z()
f_aa()
f_ac()

pal()
palt()
f_br(g_cb)
f_ad()
f_ae()
f_ag()
f_ah()

end
function f_r(ts)
local y=1

rectfill(0,0,128,128,0)
foreach(f_aq(ts,{"m","c","s"}),function(obj)
print(obj.m,0,y,obj.c)
y+=obj.s
end)
end
function f_s()
f_r("pico8 controls (keyboard);10;16;‹‘”ƒ (directional arrows);11;8;movement;9;12;Ž (z);11;8;conversation menu/cancel;9;12;— (x);11;8;search house/confirm;9;12;pause (enter);11;8;general options;9;16;press Ž/— to continue;8;8;save yourself v1.0c by;7;8;dagondev, copyright 2016;7;8;")
end
function f_t()
f_r("don't give up!;10;30;this game was meant to be played\nseveral times over;9;16;game has several variables that \nare randomly generated, \nnext game may be different!;9;24;explore world, observe details,\nand enjoy yourself;9;24;good luck next time!;11;9;")
end
function f_w()
local ts="game over;10;16;summary:;10;8; ;10;8;"
local score=0
if g_ag then
ts=ts.."+015| got back on time;11;8;"
score+=15
end
if g_af then
ts=ts.."+100| brought back the mage;11;8;"
score+=100
elseif g_ah then
ts=ts.."-025| abandoned the hunt;8;8;"
score-=25
end
if g_ai==0 then
ts=ts.."+020| didn't threaten anyone;11;8;"
score+=20
else
ts=ts.."-0"..(g_ai<10 and "0" or "")..g_ai.."| used threat "..g_ai.." times;8;8;"
score-=g_ai
end
if g_aj>0 then
ts=ts.."-0"..(g_aj<10 and "0" or "")..g_aj.."| "..g_aj.." angered npcs;8;8;"
score-=g_aj
else
ts=ts.."+020| didn't angered anyone;11;8;"
score+=20
end
if g_bo>0 then
ts=ts.."-0"..(g_bo<10 and "0" or "")..g_bo.."| searched house without permission "..g_bo.." times;8;8;"
score-=g_bo
end
if g_ah then
if not g_ag then
if g_d>2 then
ts=ts.."-020| didn't get back on time;8;8;"
score-=20
end
end
else
ts=ts.."-100| died by falling;8;8;"
score-=100
end
ts=ts.." ;10;8;your score is: "..score..";10;8;game time: "..g_a.."D "..g_b.."H "..flr(g_c).."M;9;8;"

f_r(ts)

end

function f_x()
pal()
palt()
pal(g_h.tr,g_bs.tr) 
pal(g_h.cb,g_bs.cb)
pal(g_h.m,g_bs.m)
pal(g_h.fr,g_bs.fr)

rectfill(0,0,128,128,g_h.tr)

local tdd=abs(g_e*60+g_f-g_bw*60)*2.5
if(tdd>160) return
pal(g_h.tr,g_bt.tr)
local y=127-tdd
rectfill(0,0,128,y,0)

line(0,y+2,128,y+2,0)
line(0,y+3,128,y+3,0)
line(0,y+5,128,y+5,0)
line(0,y+9,128,y+9,0)
line(0,y+17,128,y+17,0)

pal(g_h.tr,g_bs.tr)
y=128-tdd-4
line(0,y,128,y,0)

pal(0,0)
end

function f_y()
local delta=-((g_at+60)/5)
foreach(g_cf, function(c)
c.x += c.spd
rectfill(c.x,c.y+delta,c.x+c.w,c.y+4+(1-c.w/64)*12+delta,new_bg~=nil and 14 or 1)
if c.x > 128 then
c.x = -c.w
c.y=rnd(28)
end
end)

foreach(g_cg, function(p)
p.x += p.spd
p.y += sin(p.off)
p.off+= min(0.05,p.spd/32)
rectfill(p.x,p.y,p.x+p.s,p.y+p.s,p.c)
if p.x>128+4 then 
p.x=-4
p.y=rnd(128)
end
end)

foreach(g_ch, function(p)
p.x += p.spd_x
p.y += p.spd_y
p.t -=1
if p.t <= 0 then del(g_ch,p) end
rectfill(p.x-p.t/5,p.y-p.t/5,p.x+p.t/5,p.y+p.t/5,14+p.t%2)
end)
end
function f_z()

local ydelta=17
map(g_am,g_au,-g_ax,-g_ay,17,ydelta,1)
end
function f_aa()
foreach(g_bx, function(o)
o.draw(o)
end)
end
function f_ab()
foreach(g_ci, function(this)
if(this.drwitfrm) rectfill(this.lx,this.ly,this.lx2,this.ly2,13)
end)

map(g_am,g_au,-g_ax,-g_ay,17,17,32)
end
function f_ac()
foreach(g_cj, function(this)
if (this.drwitfrm) spr(this.spr,this.lx,this.ly,1,1,this.flpx,this.flpy)
end)
map(g_am,g_au,-g_ax,-g_ay,17,17,128)
end
function f_ad()
if(not g_be and g_bf==0) return 

local delta_time=g_q-g_cl
local bh=128
if delta_time>=3 or not g_be or g_cm then
if g_be or g_cm then
bh=max(g_cm and 0 or 15,128-g_bf)
else
bh=max(0,15-g_bf)
end
g_bf+=1
end
if(bh==0) g_bf=0
palt(0,false)
rectfill(0,128-bh,128,128,0) 
rectfill(0,0,128,bh,0) 
palt()
end
function f_ae()
local s=0
foreach(g_by, function(o)
s-=8
f_bh(o,g_al,g_at-s)
end)
end
function f_af(desc,sy)
rectfill(15,30,112,80,0)
rect(15,30,112,80,9)
local sel_x=sy and 45 or 75
print(desc,46-2-#desc/2,42,11)
print("no",49,62,11)
print("yes",78,62,8)
rect(sel_x,60,sel_x+15,70,8)
end
function f_ag()
if(not g_s) return
f_af("do you want to leave\nthis place for ever?",g_t)
end
function f_ah()
if(not g_bn) return
f_af("do you want to \nsearch this house?",not g_bm)
end

function f_ai(x,y,w,h,flag)
for i=max(0,f_ao(x)),min(127,f_ao(x+w-1)) do
for j=max(0,f_ao(y)),min(31,f_ao(y+h-1)) do
if fget(mget(i,j),flag) then
return true
end
end
end
return false
end

function f_aj(val,target,amount)
return val > target and max(val - amount, target) 
or min(val + amount, target)
end
function f_ak(v)
return v>0 and 1 or v<0 and -1 or 0
end
function f_al()
return rnd(1)<0.5
end
function f_am(table)
if(table==nil) return nil
local out_table={}
for key,val in pairs(table) do
out_table[key]=val
end
return out_table
end
function f_an(table, value)
for key,val in pairs(table) do
if(val==value) return true,key
end
return false,nil
end
function f_ao(val) return flr(val/8) end
function f_ap(val) return val*8 end
function f_aq(s,idtb,dttb)
local dlm=";"
if(dttb==nil) dttb={}
if(idtb==nil) idtb={}
local n_max=#idtb
local val_table={}
local lastpos = 1
local n=1
for i=1,#s do
if sub(s,i,i) == dlm then
local id=idtb[n]
local new_pos=i-1
local val=sub(s, lastpos, new_pos)

i += 1
n+=1
if n_max==0 then
add(dttb,val)
else
if(lastpos<=new_pos) val_table[id]=val
if n>n_max then
n=1
add(dttb,val_table)
val_table={}
end
end
lastpos = i
end
end
return dttb
end

function f_ar()
if(g_be) return
g_be=true
g_bf=1
g_cl=g_q
sfx(31+flr(rnd(2)),3)
end
function f_ba(skipped)
if(not g_be) return
g_be=false
g_bf=1
g_cm=skipped
 music(0,0,7)
end

function f_as(this,idtytb)
foreach(idtytb,function(value)
local t=value.type
local key=value.key
this[key]=false
if(t=="i") this[key]=0
end)
end
function f_at(this,x,y)
f_as(this,f_aq("flpx;b;flpy;b;hx;i;hy;i;spd_x;i;spd_y;i;rem_x;i;rem_y;i;lx;i;ly;i;lx2;i;ly2;i;drwitfrm;b;",g_bq))
 
this.x = x
this.y = y

this.hw=8
this.hh=8

this.draw=f_bc
this.move_y=f_bb

end
function f_aw(this)
del(g_bx,this)
end

function f_ax(this,ox,oy)
local x=this.x+this.hx+ox
local y=this.y+this.hy+oy
return f_ai(x,y,this.hw,this.hh,0) or y>=252 or ((x<0 and y>=36) or x>1024)
end
function f_ay(this,ox,oy)
local amount

this.rem_x += ox
amount = flr(this.rem_x + 0.5)
this.rem_x -= amount
f_az(this,amount,0)


this.rem_y += oy
amount = flr(this.rem_y + 0.5)
this.rem_y -= amount
this.move_y(this,amount)
end
function f_az(this, amount,start)
local step = f_ak(amount)
for i=start,abs(amount) do
if not f_ax(this,step,0) then
this.x += step
else
this.spd_x = 0
this.rem_x = 0
break
end
end
end
function f_bb(this, amount)
local step = f_ak(amount)
for i=0,abs(amount) do
if not f_ax(this,0,step) then
this.y += step
else
this.spd_y = 0
this.rem_y = 0
break
end
end
end
function f_bc(this)
spr(this.spr,this.x,this.y,1,1,this.flpx,this.flpy)
end

function f_bd(this,x,y)
f_at(this,x,y)
add(g_bx,this)

f_as(this,f_aq("spr;i;ispl;b;spr_off;i;killed;b;flltm;i;anmstt;i;lanst;i;clmb;b;ulddr;b;sitting;b;sttngu;b;lying_d;b;is_waking_u;b;waked_u;b;askplr;i;",g_bq))

this.hx=1
this.hy=3
this.hw=4
this.hh=5

f_be(this)
this.killed=false

this.maxrun=0.5
this.mxdcrn=0.2
this.maxfall=8
this.safefall=5
this.deccel=0.15
this.acc=0.6
this.dfallt=20

this.msgclr=(5+#g_by)%15+1
this.drwmsgq={}

this.unqid=g_bb
g_bb+=1
local new_name=g_br[1]
this.dlnm=new_name
del(g_br,new_name)

this.upd=f_bf
this.kill=f_ca
this.f_mva=f_bj
this.move_y=f_bk
this.say=f_bm

add(g_by,this)
end
function f_be(this)
this.left = false
this.right = false
this.u= false
this.d= false
this.ab=false
this.bb= false 
end
function f_bf(this)
if (g_az) return
if(this.killed) return

if this.process !=nil then
this.process(this)
end

local input_x = this.right and 1 or (this.left and -1 or 0)
local input_y =this.u and -1 or (this.d and 1 or 0) 

this.ulddr= (f_bl(this,0,0) and this.u) or (this.d and f_bl(this,0,8)) 

local was_clmb=this.clmb
this.clmb=this.u and not f_ax(this,0,-1) and this.flltm<this.dfallt and abs(this.spd_y)<this.safefall and
((not this.flpx and f_ax(this,1,0)) or (this.flpx and f_ax(this,-1,0)) ) and not this.ulddr
if (was_clmb and not this.clmb) this.spd_y-=0.5

local ogr=f_ax(this,0,1)

if ogr then
if (this.flltm!=0) sfx(63,2)
this.flltm=0
else
this.flltm+=1
end

local gravity=abs(this.spd_y) <= 0.15 and 0.105 or 0.21
if not ogr then
this.spd_y=f_aj(this.spd_y,this.maxfall,gravity)
this.acc=0.4
else 
this.acc=0.6
end

local mxspd=this.d and this.mxdcrn or this.maxrun

this.f_mva(this,input_x,input_y,mxspd)

f_bi(this,input_x,ogr)

this.was_ogr=ogr
end
function f_bg(this)
spr(this.spr,this.x,this.y,1,1,this.flpx,this.flpy) 
end

function f_bh(this,x,y)
x=this.x-x
y=this.y-y

palt(0,false)
foreach(this.drwmsgq,function(obj)
local dt=g_q-obj.time
local ts=#obj.m*2
local tt=ts/10.0+1
local x1=x-ts-2
local x2=x+ts+2
if x1<0 and x2>128 then

else
while(x2>128) do
x1-=1
x2=x1+ts*2
end
while(x1<0) do
x1+=1
x2+=1
end
end
if dt<tt then
if obj.ntplysfx then
obj.ntplysfx=false
sfx(obj.sound,2)
end
rectfill(x1-6,y-12,x2,y-4,0)
print(obj.m,x1,y-10,obj.color)
end
end)
palt()
end
function f_ca(this)

this.killed=true

del(g_by,this)
f_aw(this)
end
function f_bi(this,input_x, ogr)
local anmstr="lying_d;17;1;-2;1;waking_u;17;7;-1;1;clmb;11;6;0;1;ulddr;28;4;1;1;falling;6;4;2;1;ducking;4;1;3;1;standing;0;1;4;1;sitting;32;5;5;1;moving;0;4;6;1;sit;35;6;7;0.1;"
local anmtb=f_aq(anmstr,f_aq("id;sprite;offset;anmstt;speed_mult;"))
local sprite=0
local offset=1
local index=0
local speed_mult=1
if this.lying_d then
index=1
elseif this.is_waking_u and not this.waked_u then
index=2
elseif this.clmb then
index=3
this.flltm=0
elseif this.ulddr then
index=4
this.flltm=0
elseif not ogr and this.flltm>this.dfallt then 
index=5
elseif this.d and not this.is_attacking then 
index=6
if(this.left or this.right) offset=2
elseif this.sitting and not this.sttngu then
index=8
elseif this.sttngu then
index=10
elseif this.spd_x==0 or (not this.left and not this.right) then
index=7
else 
index=9
end
if index>0 then
local t=anmtb[index]
sprite=t.sprite
if(offset==1) offset=t.offset 
anmstt=t.anmstt
speed_mult=t.speed_mult
end
if (this.lanst~=this.anmstt) this.spr_off=0
this.lanst=this.anmstt
this.spr=sprite+(this.spr_off*speed_mult)%offset
this.spr_off+=0.25
if index==2 then
if this.spr_off%offset==0 and this.lanst==this.anmstt then
this.waked_u=true
return
end
end
if index==8 then
if this.spr_off%offset==0 and this.lanst==this.anmstt then
this.sttngu=true
return
end
end
end
function f_bj(this,input_x, input_y, mxspd)
if this.clmb or this.ulddr then
this.spd_y=f_aj(this.spd_y,input_y*mxspd/1.4,this.acc/1.5)
end

local a=this.spd_x
local b=abs(this.spd_x) > mxspd and f_ak(this.spd_x)*mxspd or input_x*mxspd
local c=this.acc
this.spd_x=f_aj(a,b,c)

if this.spd_x!=0 then
local flipcur=this.spd_x<0

if flipcur!=this.flpx then
this.spd_x=0
end
this.flpx=flipcur
end
end
function f_bk(this,amount)
local step = f_ak(amount)
for i=0,abs(amount) do

if not f_ax(this,0,step) or (this.ulddr and f_bl(this,0,step)) then
this.y += step
else
if (amount==this.maxfall) this.kill(this)
this.spd_y = 0
this.rem_y = 0
break
end
end
end
function f_bl(this,ox,oy)
return f_ai(this.x+this.hx+1+ox,this.y+this.hy+oy,this.hw-1,this.hh,2)
end
function f_bm(this,message)
local msg=f_am(message)
local tid_i=(msg.tid or 0)+0
if tid_i==210 or tid_i>214 and tid_i<220 then 
f_bn(msg,this.dlnm,false)
if(this.unqid!=g_cb.unqid and not f_an(g_cb.knwnm,this.dlnm)) add(g_cb.knwnm,this.dlnm)
end
local text=msg.msg_long~=nil and msg.msg_long or msg.msg
if(#this.drwmsgq>0) this.drwmsgq={}
local sound_offset=(this.unqid-1)%3
add(this.drwmsgq,{m=text,color=this.msgclr,time=g_q,ntplysfx=true,sound=(#text>14 and (f_al() and 20 or 23)+sound_offset or (#text>9 and 17+sound_offset or 14+sound_offset))})
foreach(g_bz,function(ai)
local sayx=this.x
local sayy=this.y
local maxx=ai.inhs and 0 or (msg.is_a_threat_or_a_command and 24 or 64)
local maxy=ai.inhs and 0 or (msg.is_a_threat_or_a_command and 4 or 64)

msg.saying_actor=this 

local ignore = ai.inhs or ai.isasl or this~=g_cb or (msg.directed_to_id~=nil and msg.directed_to_id~=ai.unqid)
if not ignore and ai.unqid!=this.unqid and ai.x>sayx-maxx and ai.x<sayx+maxx and ai.y>sayy-maxy and ai.y<sayy+maxy then

msg.flip=ai.x>this.x
add(ai.hrdmsgque,msg)
end
end)
end
function f_bn(dialog,to_insert,is_question)
dialog.msg=sub(dialog.msg,0,#dialog.msg-(is_question and 4 or 3)).." "..to_insert..(is_question and "?" or "")
end
function f_bo(this,range)
local r= range or 5
for i=-r,r do
local x=this.x+f_ap(i)
local y=this.y
if(fget(mget(f_ao(x),f_ao(y)),4)) return x,y
end
return nil,nil
end

function f_bp(this,x,y)
f_bd(this,x,y)

this.ispl=true

this.process=f_bw
this.upd=f_cd
this.draw=f_bq
this.kill=f_bt

this.askabtsm=false
f_cb(this)
end
function f_cb(this)
gl_cn={}
local htb={}
local fidtb=f_aq("greet/bye;greet/bye;question;statement;command;threat;",f_aq("hi;bye;que;st;cmd;threat;"))
local hidtb={"question","statement","greet/bye","threat","command"}
foreach(g_v,function(option)
local id=fidtb[1][option.id]
if id~=nil then
local idtb=htb[id] or {id=id}
if(idtb.values==nil)idtb.values={}
add(idtb.values,option)
htb[id]=idtb
end
end)

for i=1,#hidtb do
for key,val in pairs(htb) do
if(val.id==hidtb[i]) add(gl_cn,val) 
end
end
this.knwnm={"maggus"}
end
function f_bq(this,tdd)
local x=this.x-g_al-4+(this.hw-this.hx)
local y=this.y-g_at-2+(this.hh-this.hy)

local below=mget(f_ao(this.x+this.hx),f_ao(this.y+this.hy)+1)
if(below==203 or below==201 or below==96 or below==99) y+=1

spr(this.spr,x,y,1,1,this.flpx,this.flpy)
end
function f_br(this)
if (not g_aa) return
local len=this.askabtsm and #this.knwnm or #gl_cn
local x1=1
local y1=1
local x2=x1+36
local y2=y1-1
rectfill(x1-1,y1-1,x2,y1-1+6*len,0)
local sel1=flr(g_w)-1
local sel2=flr(g_x)-1
local clgclr=10
if this.askabtsm then
local sel3=flr(g_y)-1
foreach(this.knwnm,function(ai)
print(ai,x1,y1,clgclr)
y1+=6
end)
rect(x1-1,sel3*6,x2,(sel3+1)*6,8)
return
end
foreach(gl_cn,function(obj)
print(obj.id,x1,y1,clgclr)
y1+=6
end)
y1=1 
if(not g_z) rect(x1-1,y1-1+sel1*6,x2,y1-1+(sel1+1)*6,8)
y2+=sel1*6
local options=gl_cn[sel1+1]
if options~=nil then
local len2=#options.values
rectfill(x2+1,y2,127,y2+6*len2,0)
if g_z then
if(len2>0) rect(x2+1,y2+sel2*6,127,y2+(sel2+1)*6,8)
else
rect(x2+1,y2,127,y2+1+6*len2,8)
end
local last_id
foreach(options.values,function(obj)
if last_id!=obj.id then
if(last_id~=nil) line(x2+2,y2,126,y2,1)
last_id=obj.id
end
print(obj.msg,x2+2,y2+1,clgclr)
y2+=6
end)
y1=1
end
end
function f_bs()
return g_aa or g_s or g_bn
end
function f_bt(this)
g_ba=false
g_cb_killed=0
player={} 
f_ca(this)
sfx(61,3)
music(38,7)
menuitem(1)
end
function f_bw(this)
if(this.killed) return

if(this.x<0 or this.x>1016) g_s=true

if g_be then
if (g_ad.u and g_q>1) f_ba(true)
return
end

this.left = g_ab.rv<0
this.right = g_ab.rv>0
this.u=g_ac.rv<0
this.d=g_ac.rv>0
this.ab=g_ad.u
this.bb=g_ae.u

if this.bb and not g_s and not g_bn then 
g_aa=not g_aa
this.askabtsm=false
end

if f_bs(this) then
f_bz(this)
f_bx(this)
f_cc(this)
f_be(this)
return
end
local x,y=f_bo(this,1)
if this.ab and x~=nil then
g_bn=true
end 

if (this.left) g_ap=max(-g_ao,g_ap-(g_ap>0 and 1.5 or 0.75))
if (this.right) g_ap=min(g_ao,g_ap+(g_ap<0 and 1.5 or 0.75))
if (this.u) g_as=max(-g_aq,g_as-(g_as>0 and 2 or 1))
if (this.d) g_as=min(g_aq,g_as+(g_as<0 and 2 or 1))
end
function f_bx(this)
if(not g_s) return
if (g_ab.u) g_t=not g_t
local exited=this.ab

if not g_t and exited then
this.kill(this)

g_ah=true
g_ag=g_d>0 and g_d<3
end

if this.bb or exited then
g_s=false
this.x=this.x>100 and 984 or 1
end
end
function f_by(val,max)
return val>max and 1 or val<1 and max or val
end
function f_bz(this)
if(not g_bn) return
if (g_ab.u) g_bm=not g_bm
local exited=this.ab
if g_bm and exited then
local rspn=f_am(gl_cn[1].values[1])
rspn.tid="-666"
rspn.msg_long=nil
local x,y=f_bo(this,1)
local said=false
foreach(g_bz,function(ai)
if f_ao(x)==f_ao(ai.x) and f_ao(y)==f_ao(ai.y) and ai.inhs then
rspn.msg="get out!"
this.say(this,rspn)
if ai.isasl then 
f_cq(ai)
rspn.msg="i was sleeping! get out!"
else
rspn.msg="i'm leaving already!"
ai.inhs=false
ai.gtouths=true
end
ai.say(ai,rspn)
said=true
end
end)
if not said then
rspn.msg="there is nobody there"
this.say(this,rspn)
end
end

if this.bb or exited then
g_bn=false
end
end
function f_cc(this)
if(not g_aa) return
local len1=#gl_cn

local ydelta=g_ac.u and g_ac.lrv or 0

if this.askabtsm then
g_y+= ydelta
elseif g_z then
g_x+= ydelta
else
g_w+=ydelta
end
g_w=f_by(g_w,len1)
local option=gl_cn[g_w]
local len2=#(option.values) 
local len3=#this.knwnm
g_x=f_by(g_x,len2)
g_y=f_by(g_y,len3)
if this.ab and g_z and len2>0 then 
local selection = f_am(option.values[g_x])
local tid_i=selection.tid+0
if tid_i==1011 or tid_i==1051 and not this.askabtsm then
this.askabtsm=true
else
if(this.askabtsm) f_bn(selection,this.knwnm[g_y],true)
if(tid_i>2199 and tid_i<2206) g_ai+=1
this.say(this,selection)
this.askabtsm=false
g_z=false
end
end
g_z=this.right or (not this.left and g_z)
end
function f_cd(this)
f_bf(this)
this.lying_d=g_be and g_q<7
this.is_waking_u=g_be and g_q>=7
end
function f_ce(this,x,y)
f_bd(this,x,y)
add(g_bz, this)
add(g_ca,this.dlnm)
this.process=f_ch
this.draw=f_ck 
this.kill=f_cl
this.hrdmsgque={} 
this.saymsgq={}
this.rltb={}
this.cnvtb={}
this.rsptb={}
f_as(this,f_aq("yllaplrcld;i;allplyrsrch;b;gvcmd;b;inhs;b;isasl;b;own_a_house;b;tmtslp;b;mggstyhs;b;istrr;b;gtouths;b;",g_bq))
foreach(g_v,function(option)
local topic=option.tid
if(topic+0<2000 or topic+0>(2001)) this.rsptb[topic]=option
end)
f_dj(this)
end
function f_cf(this,tid)
return f_am(this.rsptb[tid..""])
end
function f_cg(this,unqid)
return this.rltb[unqid] or rnd(90)+30
end
function f_ch(this)
if(this.killed) return
this.tmtslp=g_e<=g_m or g_e>=g_o
if this.gtouths then
local dx=this.drobjx-this.x
this.right=dx>-8
this.gtouths=dx>-8
elseif this.tmtslp then
if this.own_a_house then
if f_ao(this.x)==f_ao(this.drobjx) then
this.inhs=true
this.isasl=true
this.left=false
this.right=false
else
local dx=this.drobjx-this.x
this.left=dx<0
this.right=dx>0
this.y=this.drobjy 
end
else
this.isasl=true
this.lying_d=true
end
elseif this.isasl then
this.inhs=false
this.isasl=false
this.lying_d=false
end
if(this.inhs) return
foreach(this.hrdmsgque,function(msg) 
local rspn = f_ci(this,msg) 
if rspn~=nil then
rspn.wait_for=#msg.msg/5.5+1
rspn.flip=msg.flip
f_cm(this,rspn)
end
end)
this.hrdmsgque={}
local del_table={}
foreach(this.saymsgq,function(msg)
local t=g_q
if msg.timestamp+msg.wait_for<t then
this.say(this,msg)
add(del_table,msg)
end
end)
foreach(del_table,function(msg)
del(this.saymsgq,msg)
end)
if this.gvcmd then
this.left=false
this.right=false
end 
end
function f_ci(this,msg)
if this.askplr>3 then
local r=f_cf(this,"1022")
if(f_al()) r.msg="..."
this.say(this,r) 
return
end
local len=#msg.msg
local rspn=nil
if(msg.id==nil) return
local sayer_unqid=msg.saying_actor.unqid
local rlval=f_cg(this,sayer_unqid)
local cnv_tb=this.cnvtb[sayer_unqid] or {}
local tid_string=msg.tid
local tid_i=tid_string+0
local rprng=1
local minrp=0
local rspn_boost=1+rlval/10
local rpb3p=this.istrr and 3 or min(max(rspn_boost,0),3)
local rpb6p=this.istrr and 6 or min(max(rspn_boost,0),6)
if msg.id=="hi" then
minrp=6
rprng=this.istrr and 1 or rpb3p
elseif msg.id=="bye" then
minrp=2
rprng=this.istrr and 1 or rpb3p
elseif msg.id=="st" then
minrp=2312
rprng=this.istrr and 1 or rpb6p
elseif msg.id=="que" then
minrp=tid_i+1
if tid_i==201 then
rprng=rpb3p*2
elseif tid_i==1021 then
rprng=this.mggstyhs and rpb6p or rpb3p
else
rprng=rpb6p
end
end
add(cnv_tb,tid_string)
local maxrp=minrp+rprng
if this.itinrspnumneg and rlval<this.lkactbp then
rspn=f_cj(this,minrp,maxrp,1,tid_i,cnv_tb)
else 
rspn=f_cj(this,maxrp,minrp,-1,tid_i,cnv_tb)
end
if tid_i>2199 then 
if tid_i==2200 then 
rspn=f_cp(this)
else
if (this.aitrr(tid_i)) then
return f_cp(this)
else
return f_cq(this)
end
end
end
if msg.id=="cmd" and msg.saying_actor.ispl then
rspn=f_cf(this,"1024") 
if (this.istrr or ((g_e>g_l or g_e<g_m) and not this.isasl)) then
this.gvcmd=tid_i==11 
rspn=f_cf(this,tid_i==11 and "20" or "1027")
if(tid_i==11 and this.ismgg) f_dj(this)
else
rspn=f_cq(this,tid_string)
end
end 
if tid_string=="-666" and not this.istrr and not this.allplyrsrch and not this.ismgg then
rspn=f_cf(this,"-667")
g_bo+=1
end
if rspn!=nil then 
local rspn_tid=rspn.tid+0
rspn.directed_to_id=sayer_unqid
if (rspn_tid)%10==2 and tid_i<2200 then
f_cq(this,tid_string)
end
if tid_i==1031 then
this.allplyrsrch=rspn_tid>1035
end
if tid_i==201 then
if rspn_tid>205 then
local stnm,scdnm,rdnm
foreach(g_ca,function(name) 
if name ~= this.dlnm then
if stnm==nil then 
stnm=name 
elseif scdnm==nil then 
scdnm=name
elseif rdnm==nil then 
rdnm=name
end
end
end)
if rspn_tid>207 and #g_ca>3 then
rspn.msg=stnm..", "..scdnm.." and "..rdnm
if(not f_an(g_cb.knwnm,rdnm)) add(g_cb.knwnm,rdnm)
else
rspn.msg="there is "..stnm.." and "..scdnm
end
if(not f_an(g_cb.knwnm,stnm)) add(g_cb.knwnm,stnm) 
if(not f_an(g_cb.knwnm,scdnm)) add(g_cb.knwnm,scdnm) 
end
elseif tid_i==1041 then
local recluse_condition=this.dlnm~=g_bi
if rspn_tid>1045 then
rspn.msg= recluse_condition and g_bi.." moved in about month ago?" or "nope, nobody new here" 
if rspn_tid<1048 then 
if this.ismgg then
rspn.msg=g_bi.." a month ago and recently "..stnm or stnm.." moved here a week ago"
if(not f_an(g_cb.knwnm,stnm)) add(g_cb.knwnm,stnm) 
else
rspn.msg=recluse_condition and g_bi.." a month ago and recently "..g_bh or g_bh.." moved here a week ago"
if(not f_an(g_cb.knwnm,g_bh)) add(g_cb.knwnm,g_bh)
end
end
if(not f_an(g_cb.knwnm,g_bi)) add(g_cb.knwnm,g_bi) 
end
elseif tid_i==1051 and rspn_tid>1054 then
local name=sub(msg.msg,11,#msg.msg-1) 
if this.dlnm==name then
rspn.msg="i am here..."
elseif name == "maggus" then
rspn.msg="i don't know anyone by that name"
else
foreach(g_bz,function(ai)
if ai.dlnm==name then
if(ai.house_desc~=nil) rspn.msg=ai.house_desc
if(ai.house_desc==nil) rspn.msg="hm... i don't know" 
end
end)
end
end
end
this.rltb[sayer_unqid]=rlval
this.cnvtb[sayer_unqid]=cnv_tb
return rspn
end
function f_cj(this,min,max,incr,tid,cnv_tb)
for i=min,max,incr do
if (tid==210) i=210
return f_cf(this,i)
end 
return nil
end
function f_ck(this,tdd)
if(this.inhs) return
local ly=0
local below=mget(f_ao(this.x+this.hx),f_ao(this.y+this.hy)+1)
this.lx=this.x-g_al
this.ly=this.y-g_at
if(f_an({203,201,96,99},below)) ly+=1
spr(this.spr,this.lx,this.ly+ly,1,1,this.flpx,this.flpy)
end
function f_cl(this)
del(g_bz,this)
f_ca(this)
end
function f_cm(this,msg)
if(msg.timestamp==nil) msg.timestamp=g_q
add(this.saymsgq,msg)
end
function f_cn(this,tile_x,tile_y)
this.drobjx=tile_x
this.drobjy=tile_y
end
function f_co(this,pxlx,pxly)
if(pxlx==136 and pxly==232) this.house_desc="around the farm house"
if(pxlx==656 and pxly==184) this.house_desc="house between slopes"
if(pxlx==736 and pxly==32) this.house_desc="house on the highest slope"
if(pxlx==904 and pxly==232) this.house_desc="probably sitting, as always"
end
function f_cp(this)
this.istrr=true
return f_cf(this,"-123") 
end
function f_cq(this,tid_string)
local rspn_id=1022
this.askplr+=1
if tid_string~=nil and tid_string=="-666" and this.askplr<5 then 
rspn_id=-667 
else
rspn_id=2300+min(this.askplr,9)
end
if(this.askplr==4) g_aj+=1
return f_cf(this,rspn_id)
end
function f_cr(this,x,y)
f_ce(this,x,y)
local iro1="2.5;wake up;f1;3;hey, wake up;;3.5;get up, quickly!;;3;bridge is destroyed;f1;4;could be done by our target...;f2;3;now, remember;f1;3;we are searching for maggus,;;3;which was royal mage before;;4;may be dangerous...;;3;but is worth more alive;;3;i will guard the exit;;3;till you get back with mage;f2;4;we have two days for this...;f1;3;good luck...;;1;"
this.dialogs=f_aq(iro1,{"length","msg","action"})
this.nxtdlgt=-1
this.process=f_cs
f_ar()
end
function f_cs(this)
if(this.killed) return
if(this.x<0 or this.x>1024) this.kill(this)
local seconds=flr(g_q)
local t=g_q
if #this.dialogs>0 and g_be then
if t>=this.nxtdlgt then
local obj=this.dialogs[1]
if(obj==nil) return
this.nxtdlgt=t+(obj.length or 1)
this.say(this,obj)
if obj.action!=nil then
this.flpx=obj.action=="f1"
end
del(this.dialogs,obj)
end
else
this.left=true
f_ba(false)
end
end
function f_ct(this,x,y)
f_ce(this,x,y)
local drx,dry=f_bo(this)
this.own_a_house=true
f_cn(this,drx,dry)
f_co(this,drx,dry)
this.frmprcs=0
this.rvrsfrm=false
this.process=f_cw
this.aitrr=f_cy
g_bc=true
end
function f_cw(this)
f_ch(this)
if(not this.gvcmd) f_cx(this,false)
end
function f_cx(this,ismgg)
if this.inhs or this.tmtslp then 
this.d=false
return
end
local prcs=this.frmprcs
local dlstrx=164-this.x
local dlenx=192-this.x
if prcs==0 then
this.left=dlstrx<0
this.right=dlstrx>0 
prcs=f_ao(dlstrx)==0 and 1 or 0
else
local frmval=ismgg and 0.04 or 0.01
prcs+=(this.rvrsfrm and -frmval or frmval)
prcs=max(min(100,prcs),0) 
this.rvrsfrm= this.rvrsfrm and prcs>0 or prcs==100
local dlfrmx=164+(prcs*0.30)-this.x 
this.left=dlfrmx<-3
this.right=dlfrmx>3
local abs_delta=abs(dlfrmx)
local p=abs_delta%1.0
this.d=(p>0.1 and p<0.3) or (p>0.45 and p<0.55) or (p>8.5 and p<0.98)
end
this.frmprcs=prcs
if not ismgg and not this.istrr then
if g_cb.x>160 and g_cb.x<192 and f_ao(g_cb.y)==29 and this.yllaplrcld<0 then
local rspn=f_cq(this)
rspn.msg=f_al() and "my crops!! use ladder!" or "get out and use ladder!"
this.say(this,rspn)
this.yllaplrcld=240
else
this.yllaplrcld=max(-1,this.yllaplrcld-1)
end
end
end
function f_cy(tid_i)
return tid_i==2203 or tid_i==2205
end
function f_cz(this,x,y)
f_ce(this,x,y)
local drx,dry=f_bo(this)
this.own_a_house=true
f_cn(this,drx,dry)
f_co(this,drx,dry)
this.process=f_da
this.aitrr=f_dc
g_bd=true
this.maxrun=0.2
end
function f_da(this)
f_ch(this)
if(not this.gvcmd) f_db(this,false)
end
function f_db(this,ismgg)
if this.inhs or this.tmtslp then 
this.sitting=false
this.sttngu=false
return
end
local delta_x=912-this.x 
local at_chair=abs(delta_x)<1
this.sttcld=this.sttcld and this.stttm!=1
this.sitting=at_chair and not this.sttcld
this.left= not at_chair and delta_x<0
this.right=not at_chair and delta_x>0
this.sttngu=at_chair and this.sttngu or false
if this.sitting and this.stttm<(ismgg and 600+rnd(240) or 2100) and not this.sttcld then
this.stttm+=1
else
this.sitting=false
this.sttngu=false
this.sttcld=true
this.stttm=max(1,this.stttm-4)
end
end
function f_dc(tid_i)
return tid_i==2201 or tid_i==2202 or tid_i==2205
end
function f_dd(this,x,y)
f_ce(this,x,y)
local drx,dry=f_bo(this)
this.process=f_de
this.aitrr=f_dg
g_bi=this.dlnm
if drx~=nil then
this.own_a_house=true
f_cn(this,drx,dry)
f_co(this,drx,dry)
end
this.maxrun/=2.0
end
function f_de(this)
f_ch(this)
if(not this.gvcmd) f_df(this,false)
end
function f_df(this, ismgg)
if (this.inhs or this.tmtslp) return
local right=f_ax(this,4,1) and not f_ax(this,4,0) and this.x<1000
this.left=f_ax(this,-4,1) and not f_ax(this,-4,0) and this.x>8 and not this.right 
this.right=not this.left and right
end
function f_dg(tid_i)
return (f_al() and tid_i==2201) or tid_i==2204 or (f_al() and tid_i==2202)
end
function f_dh(this,x,y,recluse_x,recluse_y)
f_ce(this,x,y)
this.aitrr=f_dl
this.process=f_dk
this.ismgg=true
g_bh=this.dlnm
local drx,dry=f_bo(this)
local didnt_find_a_house=true
if drx~=nil then
if f_di(this,drx,dry) then
this.x=drx
this.y=dry
f_cn(this,drx,dry)
this.inhs=true
didnt_find_a_house=false
end
end
if drx==nil or didnt_find_a_house then
this.mmsfr=not g_bc
this.mmsry=not g_bd and not this.mmsfr
if this.mmsry then
this.x=f_ap(114)
this.y=f_ap(29)
this.moving_time=0
elseif this.mmsfr then
this.x=f_ap(19)
this.y=f_ap(29)

this.frmprcs=0
this.rvrsfrm=false
else
this.mmsrcl=true
this.x=recluse_x
this.y=recluse_y
this.maxrun+=0.25
end
end
end
function f_di(this,door_x,door_y)
local stay=true
foreach(g_bz,function(ai) 
if ai.drobjx!=nil then
if ai.unqid!=this.unqid and ai.drobjx==door_x and ai.drobjy==door_y then
stay=f_cg(ai,this.unqid)>25
ai.mggstyhs=stay
end
end
end)
return stay
end
function f_dj(this) 
f_as(this,f_aq("mmsfr;b;mmsry;b;mmsrcl;b;sttngu;b;sitting;b;sttcld;b;",g_bq))

this.stttm=1

end
function f_dk(this) 
if this.inhs then 
return
end

f_ch(this)
this.tmtslp=false
this.isasl=false
this.lying_d=false


if(this.mmsfr) f_cx(this,true)
if(this.mmsry) f_db(this,true)
if(this.mmsrcl) f_df(this,true)

g_af=this.gvcmd

end
function f_dl(tid_i)
return tid_i==2201 or tid_i==2204
end
__gfx__
00006600000066000000000000000000000000000000000000006600000066000000660000006600000066000006670000066000000660000006600000066000
00006600000066000000660000006600000000000000000070006670000066000000660000006600000066000006700000066700000660000006600000066000
00666000006660000000660000006600000000000000000007666700706660700066600000666000006660000067600000667000006660000066600000666000
00666000006660000066600000666000000000000000660000766000077667007776677007766700007660000066600000676000006777000067600000676000
00666000006660000066600000666000000066000066660000666000006660000066600070666070076667000066600000666000006660000066700000667000
00666000006660000066600000666000006666000066600000666000006660000066600000666000706660700066600000666000006660000066670000667000
00666000006660000066600000666000006660000066600000666000006660000066600000666000006660000066600000666000006660000066600000666000
00666000006660000066600000666000006660000066600000666000006660000066600000666000006660000066600000000000000000000000000000666000
00066000000000000000000000000000000000000000000000000000000000000000660000006600000000000000000000066000000660000006600000066000
00066000000000000000000000000000000000000000000000000000000066000000660000006600000066000000660007066000000660000006607000066000
00666000000000000000000000000000000000000000000000000000000066000066600000666000000066000000660007666600076666700066667007666670
00676000000000000000000000000000000000000000000000006600006660000067600000676000006660000066600007666670076666700766667007666670
00676000000000000000000000660000000660000000660000666600006760000067600000676000006760000067600000666670006666000766660000666600
00667000660000000066000000660000000660000066660000676000006760000067600000676000006760000067600000666600006666000066660000666600
00666000666666600667666000676600006766000067600000676000006760000066600000666000006760000067600000666600006666000066660000666600
00666000666666600666776000077600006766000067600000676000006660000066600000666000006660000066600000666600000000000066660000000000
00006600000066000006600000066000006600000006600000006600000660000066000000006600000066000000660000006600000066000000660000006600
00006600000066000006600000066000006600000006600000006600000660000066000000006600000066000000660000006600000066000000660000006600
00666000006660000066600000666600006666000066660000666600006666000066660000666000006660000066600000666000006660000066600000666000
00666000006660000066600000666600006666000066660000666600006666000066660000676000007760000067600000676000006760000067600000677700
00666000006660000066600000666600006666000066660000666600006666000066660000676000007660000067600000677000006677000066770000666000
00666000006660000066600000666600006666000066660000666600006666000066660000676000006660000066600000666000006660000066600000666000
00666000006660000066600000666600006666000066660000666600006666000066660000666000006660000066600000666000006660000066600000666000
00666000000000000000000000000000000000000000000000000000000000000000000000666000006660000066600000666000006660000066600000666000
00006600000066000000660000006600000066000000660000006600000066000000660000006600000000007767777776777777ccc00cc00ccc00cc90000009
000066000000660000006600000066000000660000006600000066000000660000006600000066000000000077766677677d7767c0c0c00c0ccc00cc99000099
0066600000666000006660000066600000666000006660000066600000666000006660000066600006000000d7d77d677dd77dddc0c000c0ccccc0cc90900909
0067770000677700006777000067770000677700006760000067600000676000006760000067600076777770d6dd77677d77ddddccc00c00cc0cc0cc90099009
0066600000666000006660000066600000666000006677000066770000677000006760000067600006000000d6ddd777777dddddc0c0c00ccc0cc0cc90099909
0066600000666000006660000066600000666000006660000066600000666000006660000067600000000000d766667777ddddddc0c00cc0ccccc0cc90090009
0066600000666000006660000066600000666000006660000066600000666000006660000066600000000000d6dddd677dddddddc0c00000cc0cc0cc90009009
0066600000666000006660000066600000666000006660000066600000666000006660000066600000000000d6dddd677dddddddc0c000c0cc0cc0cc90999009
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77dddddd7777777777777777d7777ddd7777777777777777d6dddd6766666666
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77dddddd7666666766666666766677777dddddddddddddd7ddd6dd77666ddd66
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77dddddd7666666766666666d66666677dddddddddddddd7dddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77dddddd76666667666666667d66666d7dddddddddddddd7d6dddddddddddddd
7777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77dddddd76666667666666667666666d7dddddddddddddd7d6dddd6ddddddddd
777777777777ddddddd777777777ddd7ddd77ddddddddddddddddddd7777ddd7d77ddddd7666666766666666766666677dddddddddddddd7dddddddddddddddd
ddd777777777777777777777777777777777777d777dddddddddddd777777777d77ddddd7666666766666666777666777dddddddddddddd7d6dddd6ddddddddd
dd77ddddddd777777777ddddddd7777d7777d777777ddddddddddd77d777777dd77ddddd777777777777777777777ddd7dddddddddddddd7ddddddd7dddddddd
dd77ddddddd77ddddd77ddddddd77ddddd77d77dddddddddddddddddd77dd77777dddddd766666677666666777dd77ddddddddd700000000dddddddd6666dddd
dd7dddddddd77ddddd7dddddddd77ddddd7dd777dddddddddddddddd777dd7dd77dddddd7666666776666667d7777ddddddddd7600000000dddddddd6ddddddd
dd7ddddddddd7ddddd7ddddddddd7ddddd7dd777ddddddddddddddd7777dd7dd77dddddd7666666776666667dd676dddddddddd700000000dddddddddddddddd
dd77ddddddd77ddddd7ddddddddd7ddddd7dd7777dddddddddddddd7d77dd77d77dddddd7666666776666667ddddddddddddddd700000000dd77dddddddddddd
dd77777777777ddddd7ddddddddd7ddddd7dd77d7dddddddddddd777d77ddd7d77dddddd7666666776606667ddddddddddddddd70000000077dddddddddddddd
d77ddd77dddd7dddd77ddddddddd7dddd77dd77d777dddddddddd7ddd77ddd7dd77ddddd7666666776000667dddddddddddddd7600000000d667dddddddddddd
d7ddddddddd77dddd7ddddddddd77dddd7ddd77dd77dd777ddd777ddd77ddd7dd77ddddd76666667760000077dddddddddddd7d70000000066667d7ddddddd6d
d7ddddddddd7ddddd7ddddddddd7ddddd7ddd77dd7777777ddd7ddddd77ddd7dd77ddddd76666667700000007ddddddd767776770000000076776667ddd66d66
7777dddd7777777777777777ddd77777ddd766dd77777777777777777777777777777777dddddddddddddddd7ddddddd76ddddddd6dddd67dddddddddddddddd
77777777777777777777777777777777ddd67ddd77777777777777777777777777777777dddddddddddddddd67dddddd676dddddd7666677dddddddddddddddd
dddd7777dddddddddddddddd777ddddddd677ddddd7777dd7dddddddddddddddddddddd7dddddddddddddddd7ddddddd777dddddd6dddd67dddddddddddddddd
ddddddddddddddddddddddddddddddddddd77dddddd77ddd7dddddddddddddddddddddd7dddddddddddddddd7dddddddd676dddddddddd67dddddddddddddddd
ddddddddddddddddddddddddddddddddddd766ddddd766dd7dddddddddddddddddddddd7dddddddddddddddd7ddddddd7677677dddddddd7dddddddddddddddd
ddddddddddddddddddddddddddddddddddd67dddddd67ddd7dddddddddddddddddddddd7dddddddddddddddd67dddddd67767777d76dddd7dddddddddddddddd
dddddddddddddddddddddddddddddddddd667ddddd667ddd7dddddddddddddddddddddd777ddddddddddddd777ddd7dd777d7767dddddd67d7dddddddddddddd
ddddddddddddddddddddddddddddddddddd77dddddd77ddd7dddddddddddddddddddddd777d77dddd7ddddd77677767776777677ddddddd77677d6dd76d77677
0dddddd06666666066600000dddd6666ddd766ddddd766dd7d777dddddddddd6ddddddd7dddddddddddddddd00000000ddddddddd6dddd6d0000000000000000
0d0000d06666666666600000dddd7676ddd67dddddd67ddd7d7dddddddddddddddddddd7dddddddddddddddd00000000ddddddddd766667d0000000000000000
0dddddd06666006666000000ddd67776dd677ddddd677ddd7d7ddddd6ddd6666ddddddd7dddddddddddddddd00000000ddddddddd6dddd6d0000000000000000
0dddddd0dd0001d000000000ddd67666ddd77dddddd77ddd7d77dddd6d666666ddddddd7dddddddddddddddd00000000ddddddddd6dddd6d0000000000000000
01111110dd001d000000000066666666ddd766ddddd766dd7dd7dddd66666666ddddddd77ddddddddddddddd00000000ddddddddd6dddd6d0000000000000000
0dddddd0dd01d0000000000066666666ddd67dddddd67d777dd7ddddd6666666ddddddd7ddddd7dddddddddd00000000ddddddddd766667d0000000000000000
0dd00dd0dd1d00000000000076666666dd6666dd776677777dd7dddd66666666ddddddd7777d777dddddd77d07000700d7ddd7ddd6ddd76d0700000000000000
0dd00dd0ddd000000000000076666666ddd76ddd777777777dd7dddd66666666ddddddd77777777777dd777d7677767776777677767776677677060076077677
60d000d000ddddd000d000d000000d06000000000000000000000000000000000000000000000000000000000666666666660666666666666666666666666000
7ddddddddddd0ddddddddddd00d00dd700000000000000000000000000000000000000000000000000000000666666666666666666666d6dddd6666666666606
60d000d00d0000d000d000d00dd0dd0600000000000000000000000000000000000000070000000700000000dddddddddddddddddddddddddddddddddddddddd
7ddddddd000000dddddddddd0dddddd707700000000000000000000070000000000700077070070700000000dddddddddddddddddddddddddddddddddddddddd
60d000d0000000d000d000d00d000d0670070000077000000000000070077000007777070777707000000000dddddddddddddddddddddd1111dddddddddddddd
7ddddddd7dddddddddddddddddddddd707077770777700700707077707007000707777777777777007000770dddddddddddddddddddd11111111dddddddddddd
60d070d770707070707070707d707d7677777777777777777777777777777777777077777777777777777777ddddddddddddddddddd1111111111ddddddddddd
6667676776767676767676767677767677707770000070707770777007777770070070700700707077077770ddddddddddddddddddd1111111111ddddddddddd
6666666666666666666666666666600067666676000000066666666666666666666666666666666666666666dddddddddddddddddddd111111111ddddddddddd
6666666666666666666666666666660067777776000000066666666666666666666666666666666666666666dddddddddddddddddddd111111111ddddddddddd
6666dd66dd6666dddd6666dd6666d600676666760000000d6666dd6666dd6666dd6666dd6666d6666666d666dddddddddddddddddddd111111111ddddddddddd
ddddddddddddddddddddddddddddddd0676666760000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd111111111ddddddddddd
dddddddddddddddddddddddddddddddd676666760000000d0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111111111ddddddddddd
dddddddddddddddddddddddddddddddd677777760000000d0dddddddddddddddddddddddddddddddddddddd0ddddddddddddddddddd1111111111ddddddddddd
dddddddddddddddddddddddddddddddd676666760000000d0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111111111ddddddddddd
dddddddddddddddddddddddddddddddd6766667600000006dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd111111111ddddddddddd
dddddddddddddddddddddddddddddddd6666666666666666ddddddddddddddddddddddddddddddddddddddddddddddd66ddddddd000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6666dddddd000000000000000000000000
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0ddddd666666ddddd000000000000000000000000
ddddddddddddddddd1111111dddddddddddddddddddddddd0dddddddddddddddddddddddddddddddddddddd0dddd66666666dddd000000000000000000000000
ddddddddddddddddd11111111ddddddddddddddddddddddd00ddddddddddddddddddddddddddddddddddddd0ddd6666666666ddd000000000000000000000000
ddddddddddddddddd11111111ddddddddddddddddddddddd0ddd111111166dddddddddddddddddd1111111d0dd666666666666dd000000000000000000000000
ddddddddddddddddd11111111dddddddddddd1111111dddd0ddd11111116666dddddddddddddddd111111dddd66666666666666d770000000000000700000077
ddddddddddddddddd11111111dddddddddddd1111111dddddddd11111116666dddddddddddddddd111111ddd6666666666666666770770000700000777077777
ddddddddddddddddd11111111dddddddddddd1111111dddddddd11111116666ddddddddddddddd1111111ddd6666666666666666077000000000000000000000
1dddddddddddddddd11111111dddddddddddd1111111dddddddd11111116666ddddddddddddddd1111111ddd6666666dd6666666077000000ddd00000dd00000
ddddddddddddddddd11111111dddddddddddd1111111dddddddd11111116666ddddddddddddddd11111111dd666666dddd66666607700d000ddd00000dd00000
ddddddddddddddddd11111111dddddddddddd1111111dddddddd11111116666ddddddddddddddd1111111ddd66666dddddd666667700dd00770dd0000dd00000
ddddddddddddddddd11111111dddddddddddd1111111ddddddddddddddddd66dddddddddddddddd111111ddd6666dddddddd66667700d000770dd0707dd00000
ddddddddddddddddd11111111dddddddddddd1d111d1ddddddddddddddddddddddddddddddddddd1111111dd666dddddddddd666770dd770770dd7707dd00070
1dddddddddddddddd11111111dddddddddddd1ddddd1dddd0dddddddddddddddddddddddddddddd111111ddd66dddddddddddd66770dd777770dd77d77d77777
1dddddddddddddddd11111111dddddddddddd1ddddd1ddddddddddddddddddddddddddddddddddd111111ddd6dddddddddddddd6770dd777770d777d77077777
00000000000000000000000000000000000000000000000006000060d6dddd6d77777777777700007777777700077777d6dddd67d6dddd6d6766667606000060
00000000000070000000000000000000000000000000000007666670d766667d77777777777777777777777777777777d7666677d766667d6777666607666670
07000000000707000000000000700000000000000000000006000060d6dddd6dd6dddd6d000077770000000077700000d6dddd67dddddd6d6666666600000060
70700000770700007070070700777077000000000000000006000060d6dddd6dd6dddd6d000000000000000000000000d6dddd67dddddddd6666667606000000
00070000007000000707707007070700000000000000000006000060d6dddd6dd6dddd6d000000000000000000000000d6dddd67dddddd6d6666666600000000
0707007007070070070707700707077000000000777700070766667077766777d766667d000000000000000000000000d7666677dddddd7d6776676600000000
7777777777777777777777777777777700000007777777770600006077777777d6dddd6d000000000000000000000000d6dddd67dddddddd6766666600000000
77707770000070700700707077077770000000770777777006000060d777776dd6dddd6d000000000000000000000000d6dddd67d6dddddd6666667600000060
000000000000000000000000000770000000000007700777d6dddd6dddddddd77ddddddd0007660077777777666666660000000d0000000660000000d0000000
000000000000700000077700007007000000000077700700d766667ddddddd7667dddddd000670007777777766666666000000dd0000006666000000dd000000
070077000007070077770777007000000000000777700700d6dddd6dddddddd77ddddddd0067700000777700d666666600000ddd0000066666600000ddd00000
707770077707000070700707777770700000000707700770d6dddd6dddddddd77ddddddd0007700000077000dd6666660000dddd0000666666660000dddd0000
000700770070777707077070070707070000077707700070d6dddd6dddddddd77ddddddd0007660000076600d6666666000ddddd0006666666666000ddddd000
070700700707707077070770070707770000070007700070d766667ddddddd7667dddddd0006700000067000d666666600dddddd0066666666666600dddddd00
777777777777777777777777777777770007770007700070d6dddd6dddddddd77ddddddd0066700000667000d66666660ddddddd0666666666666660ddddddd0
777077700777777007007070770777700007000007700070d6dddd6dddddddd77ddddddd000770000007700066666666dddddddd6666666666666666dddddddd
000000000000000000000000000000000000000000000000676666760000000770000000000766000007660066666666dddddddd6666666666666666dddddddd
000000000000000000000000000000000000000000000000677777760000007667000000000670000006700066666666ddddddd066666660066666660ddddddd
000000000000000000000000000000000000000000000000676666760000000770000000006770000067700066666666dddddd00666666000066666600dddddd
0000000000000000000000000000000000000000000000006766667600000007700000000007700000077000d6666666ddddd0006666600000066666000ddddd
7777000000000000000000000000000000000000000000006766667600000007700000000007660000076600dd666666dddd000066660000000066660000dddd
7777777777770000000777777777000700077000000000006777777600000076670000000006700000067077ddddd666ddd00000666000000000066600000ddd
0007777777777777777777777777777777777770777000006766667600000007700000000066660077667777dddddd66dd0000006600000000000066000000dd
0077000000077777777700000007777077770777777000006766667600000007700000000007600077777777ddddddd6d000000060000000000000060000000d
007700000007700000770000000770000077077000000000770000000770000000770007000000000000000011111111dddddddd6666666677777777eeeeeeee
007000000007700000700000000770000070077700000000770000000770000007700076000000000700000011111111dddddddd6666666677777777eeeeeeee
007000000000700000700000000070000070077700000000770000000770000007700007000000000700000011111111dddddddd6666666677777777eeeeeeee
007700000007700000700000000070000070077770000000770000007700000077000007000000000700000011111111dddddddd6666666677777777eeeeeeee
007777777777700000700000000070000070077070000000770000007700000077000007000000007700d00711111111dddddddd6666666677777777eeeeeeee
07700077000070000770000000007000077007707770000007700000770000007700007600000000d77ddd7711111111dddddddd6666666677777777eeeeeeee
07000000000770000700000000077000070007700770077707700000770000007700000770000000d77dd77d11111111dddddddd6666666677777777eeeeeeee
07000000000700000700000000070000070007700777777707700000770000007700000777000000d77d77dd11111111dddddddd6666666677777777eeeeeeee
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000272300000020202020202020202043434320202420202020202020202020434320200020202323232320232020202020202024202020230020202020432020208020248080
202020208080808080808023232323232323232324202323232323202020302020202020232320202020204b4b80808020203020203020202020304b4b80808080808080808024242783838324242724808080808080242020808343204b4b208080808080802720208080432043432080808080808080802020202020438300
__map__
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfdfdfdfdfdfdfd
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfcbcfdbbbcfdfd
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfcfcfcfcdbfd
ffffffffffe2e1e4e5ffffffffffffffffffffffffffffffffffffffc4c5e1e2e3e4e2e1e1e2e1e2e3e1e1e2e2e2e3e1e1e2e1e2e3e1e1e2e1e2e3e1e1e2e1e2e3e1e1e2e1e2e3e1e1e2e1e2e3e3e1e1e2e1e2e3e1e1e2c5ff8b8c8d8e8fffc5e1e2e1e1e2e1e2e1e1e2e1e2e1e1e2e1e2e1e1e2e1e2e3e2e3e1e1fcfcfcebfd
7efffffffff3f3f4f5f9ffffffffffffffffffffffffffffffffffffd4d5f1f2f3f4f5f3f2f2f3f2f3f3f0f1f3f2f0f1f3f2f2f3fff2f3ffd4d5f1f2f3f2f2f1f3f4f5f3f2f2f3f2f3f3f3f2f2f3f2f3f3f0f1f3f2f0f1d53f9b9c9d9e9f3df4f3f2f2f3f2f3f3f0f1f3f2f0f3f2f2f3f2f3f3f0f1f3f2f0f1d4d5f1797377fd
fd3c3bfdfdfdfdfdfdf6fffffffffffffffffffffffffffffffdfdfdfdfde6fdfdfdfdc9cac9cbcac9c9cadac9c9cacac9c9c9cacbc9cacbfdfdfdfdfdfde6fdfdcefdc9cac9cbcac9cbc9dac9cbcac9cbcacac9c9cacafde6fdfdfdfde6fdfdc9cac9cbcac9cbcacac9c9cac9dac9cbcac9cbcacac9c9cacae6fdfdfdfdfdfd
fdd8ccfdfdfdfdfdfdf7fffffffffffffffffffffffffffffffdfdfdfcfcd6fcfcfcfcffffffffffffffffd9fffffffffffffffffffffffffffcfcfcfc65d665fcfcfcfcffffffffffffffd9fffffffffffffffffffffffcd6fcfcfcfcd6fcfcfcffffffffffffffffffffffffd9fffffffffffffffffffffc94fdfdfdfdfdfd
fdd8ccfdfdfdfdfdfdf6fffffffffffffffffffffffffffffffffffffcfcd6fcfcfcfcffffffffffffffffd9fffffffffffffffffffffffffffffcfcfc64d664fcfcfcfcffffffffffffffd9fffffffffffffffffffffffccdfcfcfcfcd6fcfcfcffffffffffffffffffffffffd9fffffffffffffffffffffc94fdfdfdfdfdfd
fdd8ccfdfdfdfdfdfdf7fffffffffffffffffffffffffffffffffffffcfcd6fcfcffffffffffffffffffffd9fffffffffffffffffffffffffffffffcfc64d664fcfcffffffffffffffffffd9fffffffffffffffffffffffccdfcfcfcfcd6fcfcfcffffffffffffffffffffffffd9ffffffffffffffffffffffc6fdfdfdfdfdfd
fdd8ccfdfdfdfdfdfdf6fffffffffffffffffffffffffffffffffffffcfcd6fcfcffffffffffffffffffffeae1e4e2e1e2e3e1e1e2e2e2e3e1e1e2434275c7754442e3e1e1e2e2e2e3e1e1eae1e2e3e1e1e2e2e3e1e1e241e2424445fcd64647fcffffffffffffffffffffffffd9ffffffffffffffffffffffd6fdfdfdfdfdfd
fdd8ccfdfdfdfdfdfdf6fffffffffffffffffffffffffffffffffffffffcd6fcfcffffffffffffffffffffeaf1f4f3f2f2f3f2f3f3f0f1f3f2f0f15352fcd6525353f0f1f3f2f0f1f3f2f2d9f2f3f3f0f1f3f2f0f1f3ff53f4fc5455fcd65657fcfffffffffffffffffffff6f5e9ffffffffffffffffffffffd6fdfdfdfdfdfd
fdd8ccfdfdfdbbfcdff7fffffffffffffffffffffffffffffffffffffffcd6fcfcffffffffffffff3fffe7fefefec9cac9cbcac9cbcbcadac9caca606262c8626060cacacbc9c9cac9c9c9dacac9cbcbcac9c9cacac9c960e6fdfdfdfde6fdfd58fffffffffffffffffffffdfdfdfdffffffffffffffffffffd6fcfdfdfdfdfd
fdd84e4f5ffcfcfcecf6fffffffffffffffffffffffffffffffffffffcfcd6fcfcfffffffffffffdfdfde6fdfdfdffffffffffffffffffd9fffffffcfcfcd6fcfccdfcffffffffffffffffd9ffffffffffffffffffffffefcdfcfcfcfcd6fcfcfcfffffffffffffffffffffcfdfdfdffffffffffffffffffffd6fcfdfdfdfdfd
fd4bcc77fd79fcfcfdf6fffffffffffffffffffffffffffffffffffffcfcd6fcfcfffffffffffffdfdfd94fdfdfdffffffffffffffffffd9fffffcfcfcfccdfcfcd6fcffffffffffffffffd9ffffffffffffffffffffffffcdfcfcfcfcd6fcfcfcfffffffffffffffffffffcfcfdfdfdfcffffffffffffffffd6fcfcfcfdfdfd
fd5bccfdfdfdfdfdfdf6fffffffffffffffffffffffffffffffffffcfcfcd6fcfffffffffffffffcfcfcd6fcfcfcffffffffffffffffffd9fffffcfcfcfccdfcfcd6fcffffffffffffffffd9fffffffffffffffffffffffffffcfcfcfcd6fcfcfdfdfffffffffffffffffffcfcfcfcfcfcfcffffffffffffffc6fcfcfc4c4dfd
fdd8ccfdfdfdfdfdfdf7fffffffffffffffffffffffffffffffffffcfcfcd6fcfffffffffffffffffcfcd6fcfcfcffffffffffffffffffd9fffffcfcfcfcfcfcfccdfcffffffffffffffffd9fffffffffffffffffffffffffffcfcfcfcd6fcfcfdfcfffffffffffffffffffffcfcfcfcfdfdffffffffffffffc6fcfcfc6668fd
fdd8ccfdfdfdfdfdfdf6fffffffffffffffffffffffffffffffffcfcfcfcd6fcfcfffffffffffffffcfcd6fcfcfcffffffffffffffffffd9fffffffcfcfcfcfcfcfcfcffffffffffffffffd9fffffffffffffffffffffffccdfcfcfcfcd6fcfcfcfcfcfffffffffffffffffffcfcfcfcfcfcfdffffffffffffd66efc7c4c4dfd
fdd8ccfdfdfdfdfdfdf7ffffffffffffffffffffffffffffffff44454243c74342e1e2e2e3e1e1e24142c7414242e2e3e1e1e2e1e2e1e2eae1e2e14243424341414242e2e3e4e5ffffffffd9c4c5e1e2e3e4e2e1e1424142c741424141c74242424342e3e1e1e2e2e2e3e4e5fcfcfcfcfcfcfcfcfcffffffffccfdfdfd7678fd
fdd8ccfdfdfdfdfdfdf6ffffffffffffffffffffffff3fffffff54555252d652f2f2f3f2f0f1f3525251d6505153f2f0f1f3f2f2f3f2f2d9f2f3f3505153525253cdd4d5f1f4f5ffffffffe9d4d5f1f2f3f4f5f3f2525352d653525253d65350515352f0f1f3ffd4d5f1f4f56efcfcfcfcfcfcfcfcfcff3fffccfdfdfd4949fd
fdd8ccfdfdfdfdfdfdf6fffffffffffffdfdfde6fdfdfdfdfdfdfdfd6062c8cac9cacac9cacada606062c8626260c9cacac9c9c9cac9c9dacac9c9616160c86060c863fdfdfdfdfde6fdfdfdfdfdfdfdfdfdfdc961606161c860616061c8606161606063cac9c9cbfdfdfdfde6fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd8d7fd
fdd8ccfdfdfdfdbbfcf7ffffffffffffeefdfd94fdfdfdfdfdbbfcfcfcfccdffffffffffffffd9fcfcfcd6fcfcfcffffffffffffffffffd9fcfcfcfcfcfcd6fcfccdfcfdfdfdfdfd94fdfdfdfdfdfdfdbbecfffffcfcfcfcd6fcfcfcfcd6fcfcfcfcfcfcfffffffffffffdfd94fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd8d7fd
fdd8ccfdfdfdfdfcfff6fffffffffffffffdfd94fdfdfdfcfcfcfcfcfcfccdffffffffffffffd9fcfcfcd6fcfcfcffffffffffffffffffd9fcfcfcfcfcfcd6fcfcfcfcfcfcfdfdfd94fdfdfdfdfdfdbbecffffff5855fcfccdfcfcfcfcd6fcfcfcfcfcfcfcdfffffffffdcfcd65959fcfcfcfcfcfcfc65696afcfc65fdd8d7fd
fdd8ccfdfdfdfdfcfff6fffffffffffffffffcd6fcfcfcfcfcfcfcfcfcfcffffffffffffffffd9fcfcfcd6fcfcfcdfffffffffffffffffd9effcfcfcfcfcd6fcfcfcfcfcfcfdfdfd94fdfdfdfdfdbbec968b8ffffdfd48fcd6fcfcfed8d6fc7a7cfc7cfcfc7afcffff7e697c7d5959797c6a7c796a7c754949fcfc7459d8d7fd
fdd8ccfdfdfdbbfcffffffffffffffffffffffd6fcfcfcfcfcfcfcfcfcfcffffffffffffffffd9fcfcfcd6fcfcfcfcdfffffffffffffffd9ffeffcfcfcfccdfdfdfdfcfcfcfcfcfcd6fcfcfcfcfc3fffb09dba3dfdfd58fcd6fcd7fdfdfdfdfdfdfdfdfdfdfdd8fce7fdfdfd94fdfdfdfdfdfdfdfdfdfdfdfdfdfc7559d8d7fd
fdd8ccfdfdfdfcffffffffffffffffffffffffc6fffffcfcfcfcfc6efc7acdffffff7e7fffffd9fcfcfcd6fcfcfcfcfcffffffffffffffd9fffffcfcfcfffffdfdfcfcfcfcfcfcfcd6fcfcfdfdfdfdfdfdfdfdfdfdfd58fccdfcd7fdfdfdfdfdfdfdfdfdfdfdd8fcdfffffffc6fffcfcfcfcfcfcbcfdfdfdfdfdfdfdfdd8d7fd
fdd8ccfdfdbbfcffffffffffffffffffffffffc6fffffffcfcfcd7fdfdfdfdfdfdfdfdfde87be96ffcfcd6fc7c6ffcfc7eff7fffff7b7fe9ffffeffcfcfffffffcfcfcfcfcfcfcfce6fdfdfdfdfdfdfdfdfdfdfdfdfdf6fcfc6e5cfdfdfdfdfdfdfdfdfdfdfdfdfdd8ffffffc6ffffffffffeffcfcfcfcbcfdfdfdfdfdd8d7fd
fdd8ccfdfcfcffffffffffffffffffffffffffc6fffffffffcfcd7fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd86f6ecdfcfcfcfcfcfcfcfcfcd6fcfcfcfcfcfcfcfcfcfffffffffffc6dfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd8fcffffc6ffffffffffffffeffcfcfcfc65bcfdfdd8d7fd
fdd8ccfdfcffffffffffffffffff9590919293c6fffffffffcfc5cfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd8fcfcfcfcfcfcfcfcfcd6fcfcfcfcfcfcfcfcfcfffffffffcfcccfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd8fcfcffc6969798999a71ffffeffcfcfc74fcbcfdd8d7fd
fdd86d5affffffffffffffffffa4a5a0a1a2a3c6ffffffffef5cfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd87c6efcfcfcfcd6fcfcfcfcfcfcfcfcecfffffffffcfcccfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd8fcfcffc6a6a7a8a9aafffffffffffffc74fcfc59d8d7fd
fd6c5e7effffffffffffffffffb8b1b0b1b2b3d68082818283fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd87cfcfcd6fc6e7c6ffc6ffcecfffffffffffcfcd6daffffdaffffdaffffdaffffffffdafcfcfcfcc6b6b7b8b9ba703fffffffffff75fcfc59d8d7fd
fdfdfdfdbfbebffaad7baff8fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdd86e7c7deaadaeeaae3feaafadeaafffadffead7fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfd
fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfd
__sfx__
0152002009050110500e05015050150401105009050110500e05015050150401a0500a050130500e05016050130500e0500a050150500a050130500e0501c05009050110500e0501505015040110500905011050
015200200e05015050150401a0500a050130500e05016050130500e0500a050150500a050130500e0501c05009050110500e05015050150401105009050110500e05015050150401a0500a050130500e05016050
013e00202612527125291252b1252c1252c11518105181053012532125331253512537125371152210522105181251a1251b1251d1251f1251f1252c1252c115261252912527125291252c1252c1252712527115
003e00200c135181350c135181350c135181350c135181351413520135141352013514135201352213522135131351f135131351f135131351f1352013520135111351d135111351d1350e1351a1350f1351b115
00520000157641a7641d764217641d7641a7641576426764217641d7641a76415761167641a7641f764227641f7641a7641676428764217641f7641a76416761157641a7641d7642176426764217641d7641a764
005200001576421764157641d764167641a7641f7642276426764217641f7641a764167641f764167641a764157641a7641d764217641d7641a7641576426764217641d7641a76415761167641a7641f76422764
005200001f7641a7641676428764217641f7641a76416761157641a7641d7642176426764217641d7641a7641576421764157641d764167641a7641f764227642676421764217642176421764217642176421764
002900002176416764167641a7641a7641f7641f76422764227642676426764267642676416764167641a7641a7641f7641f76421764217642876428764287642876428764287642876428764287642876128735
01520020130500e0500a050150500a050130500e0501c05009050110500e05015050150401105009050110500e04015040150401a0400a040130400e040160401304015040150401503015030150201502015015
012000201573515736157351573515735157351573415700157351573615735157361573515736157351574215735157301573515735157351573615735157001573516735157351673515735167351573215752
013e002013122131220f1220f1221312213122181221812214122141220e1221a12214122141221b1221b1220c1220c1220f1221b1220f1220e12218122181220e1220e1220f1220f12211122111220f1220f122
004000201263518102016050060312605006030060535615126350160301605006031260500603006053561512635016030160512603126350060500605006351263501603016050060312635356050060535615
0180002028744287142f744307442d7442d7342d7242d7142f7442f7342f7242f7142b7442b7242a7442a72428744287142f744307442d7442d7342d7242d7142b7442b7242d7442d7242f734307342f71430712
0180002028742287122f742307422d7422d7322d7222d7122f7422f7222b7122b74228742287122f742307422d7422d7322d7222d7122f7222f7322f7222f7122b7222b7422d7222d7422f722307222f71230712
0014000027511255112751125515255112f5012d501315013c501375012f5012d5012a5012d501335013350136501375010050100501005010050100501005010050100501005010050100501005010050100501
001400001552115521175211652515521005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
00140000095310b531095310a53509531005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
000f00001f511235112151124515245112051120511185111e5011c5111c511205111e5111a511205111c51120511355013250130501215011d5011a50117501125010f5010d5010a50108501045010250100501
000f00001852115521155211752513521155211752115521185211a5211a5211850118521195211c521145211552113521155211a501195011850116501135011150111501005010050100501005010050100501
000f0000105310e5310c5310e5350a5310c531105310f5310f5010e5310c5310d5310e5310c5310e5310e5310d5310b5310a5310d501005010050100501005010050100501005010050100501005010050100501
000f00001f51123511215111b5151d5111a511205011b511175111c5111c511175111b5111b51114511145111a51119511195011851118511165111c5111b511125010f5010d5010a50108501045010250100501
000f0000115211152111521115250f521115211750112521125211252112521135211452115521155211352112521135010f52110521115211152112521115211152111501005010050100501005010050100501
000f0000085310853108531075350b5310d5310b5310e53109531095310c5010b5310b5310b531095310b5310d5310f5310e5310a531005010c5310c5310c5310b53100501005010050100501005010050100501
000f00001c5111851125511235151e5111a511205111b511225111f5111d511215111e5111b5111b511205111c51120511195011751121511155111f5111e511185110f5010d5010a50108501045010250100501
000f0000145211d5211652113525185211a5211552115521185211a5211352119521195211d521155211c521155211350118521155211a5211b5211b521185211852111501005010050100501005010050100501
000f0000085310853108531075350b5310d5310b5310e53109531095310c5310b5310b5310b531095310b5310d5310f5310e5310a531005010c5310c5310c5310b53100501005010050100501005010050100501
01200000213151f3152231522315213151f3151f3141f3142631524315273152731526315243152431424314213151f3152231522315213151f3151f3141f3142631527315243152731526315243152431424314
01200000214121d4121d4121c412214121c412214121a4121c4121d4121d4121c4121a4121a4121c4121d412214121d4121d4121c412214121f4121f4121f4121a4121d4121d4121c4121a4121d4121a4121c412
003e0020261142711427114261142c1242c114181041810430114301143311433114371143711422104221042611426114271142711430114301141d1041d1043211432114331143311424124241143012430114
013e00200c134181340c134181340c134181340c134181341413420134141342013414134201342213422134131341f134131341f134131341f1342013420134111341d134111341d1340e1341a1340f1341b135
003e00202611427114291142b1142c1242c11418104181043011432114331143511437124371142210422104181141a1141b1141d1141f1141f1142c1242c114261142911427114291142c1142c1142712427114
015000201a6121a6121a6120e6120e6120e6120e6120e6120e6120e6120e6120e6120e6120e6121a6121a6121a6121a6121a6121a6121a6121a6121b612196121a6121a6120f6120f6120f6120f6120f6120f612
0150002002612016120161202612036120b6120961208612066120f612176121561214612126121261212612126121461215612176120d6120f6120f61212612116120e6120e6121761213612116120e61217612
015000201a61219612196121a6121b6122361221612206121e6121b6122361221612206121e6121e61212612126121461215612176120d6120f6120f61212612116120e6120e6121761213612116120e61217612
013e00200c135181050c135181050c135181050c135181051413520105141352010514135201352210522135131351f105131351f105131351f1352010520135111351d105111351d1050e1351a1050f1351b105
00520000097640e7641176415764117640e764097641a76415764117640e764097610a7640e7641376416764137640e7640a7641c76415764137640e7640a761097640e76411764157641a76415764117640e764
00520000097641576409764117640a7640e76413764167641a76415764137640e7640a764137640a7640e764097640e7641176415764117640e764097641a76415764117640e764097610a7640e7641376416764
00520000137640e7640a7641c76415764137640e7640a761097640e7641d764157641a76415764117640e764097641576409764117640a7640e76413764167641a76415764137640e7640a764137640a7640e764
0040102028754287342873428724287141c70410704107041070410704107041c704180051c005180051700510005170051c00517005180051c00518005170051e0052100512005150051c0051f0052800513005
014000201263518102016050060312605006031d615356151263501603016050060312605006031d615356151263501603016051260312635006051d615356151263501603016050060312635356051d61535615
0140002010035170351c03517035180351c03518035170351e0352103512035150351c0351f035280351303510035170351c03517035180351c03518035170351e0352103512035150351c0351f0352803513035
014000001532510325103251f325213251c3252332517325233251e3251e3251f325213251732518325183251532510325103251f325213251c3252332517325233251e3251e3251f32521325173251832518325
0140002010025170251c02517025180251c02518025170251e0252102512025150251c0251f025280251302510025170251c02517025180251c02518025170251e0252102512025150251c0251f0252802513025
014000001533210332103321f332213321c3322333217332233321e3321e3321f332213321733218332183321533210332103321f332213321c3322333217332233321e3321e3321f33221332173321833218332
0140002010032170321c03217032180321c03218032170321e0322103212032150321c0321f032280321303210032170321c03217032180321c03218032170321e0322103212032150321c0321f0322803213032
01200020126350c635126351e63512605006031d62535625126350c635126351e63512605006031d62535625126350c635126351e63512635006051d62535625126350c635126351e63512635356251d62535625
00800020102051720510205172050c205102050c20517205122051520512205152051c2051f205102051320510205172051020523205182051020518205172051e2052120512205152051c2051f2051020513205
014000201c2272322724227282272a2272d227282271f2272a2272d2271e22721227282272b227342271f2271c2272322724227282272a2272d227282271f2272a2272d2271e22721227282272b227342271f227
014000201c027230272802723027240272802724027230272a0272d0271e02721027280272b027340271f0271c027230272802723027240272802724027230272a0272d0271e02721027280272b027340271f027
01200020126450c635126051e645126051d6251d64535625126451e6351e6051e6451d605356451d60535645126450c635356450563512605006051d64535625126450c635126451e63512645356251d64535645
0120000015756157561575116752157561375613756137561a7561a7561a7511b7520e756187561875618756151461514615141161421514613146131461314621136211362113122132211361f1361f1361f136
01200020157500e7501075011750107500e7501575010750157501514015750151300e75011750107500e7501575011750107500e75010750117501113011150107601013010750101501d1501c7501a15011150
012000000955005550055500455009550045500955002550045500555005550045500255005550045500255009550055500555004550095500455009550025500455005550055500455002550055500455002550
01200020212221a2221c2221d2221c2221a222212221c222212272121721227212171a2221d2221c2221a222212221d2221c2221a2221c2271d2271d2171d2271c2271c2171c2271c2271d2161c2261a2161d216
01300000097640e7641176415764117640e764097641a76415764117640e764097610a7640e7641376416764137640e7640a7641c76415764137640e7640a761097640e76411764157641a76415764117640e764
01300000097641576409764117640a7640e76413764167641a76415764137640e7640a764137640a7640e764097640e7641176415764117640e764097641a76415764117640e764097610a7640e7641376416764
01300000137640e7640a7641c76415764137640e7640a761097640e7641d764157641a76415764117640e764097641576409764117640a7640e76413764167641a76415764137640e7640a764137640a7640e764
001300002176416764167641a7641a7641f7641f76422764227642676426764267642676416764167641a7641a7641f7641f76421764217642876428764287642876428764287642876428764287642876128735
003000001f7641a7641676428764217641f7641a76416761157641a7641d7642176426764217641d7641a7641576421764157641d764167641a7641f764227642676421764217642176421764217642176421764
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001b0500b0500706006060050700507003070110700307002070020700307001770077700e7700377003770027700177001770017700177005760057600576004760037600276001750000400003000010
00ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b0300b0300704006040050400504003050110500305002050020500305001750077500e7500375003750027500175001750017500175005740057400574004740037300273001720000200000000000
__music__
00 2e 42 43 44
01 02 42 43 44
00 02 03 43 44
00 02 03 43 44
00 02 0a 43 44
00 02 0a 22 44
00 1c 0a 22 44
00 1c 0a 22 44
00 1c 1d 22 44
00 1e 0a 22 44
00 0a 1d 43 44
00 41 1d 43 44
00 2e 42 43 44
00 23 42 43 44
00 24 42 43 44
00 25 42 43 44
00 04 00 43 44
00 05 01 43 44
00 06 08 43 44
00 07 42 43 44
00 0c 42 43 44
00 0b 0d 43 44
00 0b 0c 43 44
00 0b 26 43 44
00 3e 42 43 44
00 2e 42 43 44
00 0b 2a 43 44
00 29 28 27 44
00 29 28 27 44
00 2b 42 27 44
00 2b 2c 2d 44
00 2b 2c 2d 44
00 2b 30 31 44
00 30 2f 31 44
00 2b 2c 2d 44
00 29 2c 27 44
00 2b 2c 31 44
00 29 28 27 44
00 09 42 0b 44
00 33 42 2d 44
00 33 42 2d 44
00 32 33 2d 44
00 32 33 27 44
00 09 42 0b 44
00 33 42 43 44
00 35 34 43 44
00 35 34 27 44
00 35 34 2d 44
00 35 34 31 44
00 35 34 2d 44
00 35 34 27 44
00 41 34 43 44
00 33 42 43 44
00 3e 42 43 44
00 36 42 43 44
00 37 42 43 44
00 38 42 43 44
00 36 42 43 44
00 37 42 43 44
00 3a 42 43 44
00 39 42 43 44
00 41 42 43 44
00 3e 42 43 44
00 41 42 43 44
