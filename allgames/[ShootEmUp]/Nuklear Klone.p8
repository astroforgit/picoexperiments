pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- nuklear klone
-- by freds72
local a=0
local b=0
local c={}
local d={}
local e={}
local f=0
local g=0
local h=1
local i
local j=64
local k=32
local l,m,n=0x1,0x2,0x0
local o={
['true']=true,
['false']=false}
function p() end
local q={
l=l,
m=m,
n=n,
p=p}
local r={['{']="}",['[']="]"}
local function s(t,u)
for v=1,#u do
if(t==sub(u,v,v)) return true
end
return false
end
local function w(x,y,z,ba)
if sub(x,y,y)!=z then
if(ba) assert('delimiter missing')
return y,false
end
return y+1,true
end
local function bb(x,y,bc)
bc=bc or''
if y>#x then
assert('end of input found while parsing string.')
end
local bd=sub(x,y,y)
if(bd=='"') return q[bc] or bc,y+1
return bb(x,y+1,bc..bd)
end
local function be(x,y,bc)
bc=bc or''
if y>#x then
assert('end of input found while parsing string.')
end
local bd=sub(x,y,y)
if(not s(bd,"-xb0123456789abcdef.")) return tonum(bc),y
return be(x,y+1,bc..bd)
end
function bf(x,y,bg)
y=y or 1
if(y>#x) assert('reached unexpected end of input.')
local bh=sub(x,y,y)
if s(bh,"{[") then
local bi,bj,bk={},true,true
y+=1
while true do
bj,y=bf(x,y,r[bh])
if(bj==nil) return bi,y
if bh=="{"then
y=w(x,y,':',true)
bi[bj],y=bf(x,y)
else
add(bi,bj)
end
y,bk=w(x,y,',')
end
elseif bh=='"'then
return bb(x,y+1)
elseif s(bh,"-0123456789") then
return be(x,y)
elseif bh==bg then
return nil,y+1
else
for bl,bm in pairs(o) do
local bn=y+#bl-1
if sub(x,y,bn)==bl then return bm,bn+1 end
end
end
end
local bo,bp,bq={},{}
local br
local bs={}
local bt,bu,bv=8
local bw=bf('[{"ob":[[17,18,19,18,17],[17,33,34,33]]},{"ob":[[49,50,51,50,49],[49,56,57,56]],"palt":3}]')
local bx=0
local by,bz,ca,cb=0,0
q.cc=function(self,cd,ce)
local cf=self.cf or 1
palt(0,false)
palt(self.palt or 14,true)
local t=self.cg and self.cg[flr(self.ch)%#self.cg+1] or self.spr
spr(t,cd-4*cf,ce-4*cf,cf,cf)
end
q.ci=function(self,cd,ce)
local t=self.cg and self.cg[flr(self.ch)%#self.cg+1] or self.spr
local cj,ck=band(t*8,127),8*flr(t/16)
cl(cj,ck,cd-4,ce-4,1-self.cm)
end
q.cn=function(self,cd,ce)
local co=1.5*#self.cp
print(self.cp,cd-co+1,ce-2,0)
print(self.cp,cd-co,ce-2,7)
end
q.cq=function(self,cd,ce)
local t=self.cg[flr(self.ch)+1]
cd-=8
ce-=8
palt(0,false)
palt(14,true)
spr(t,cd,ce,1,1)
spr(t,cd+8,ce,1,1,true)
spr(t,cd,ce+8,1,1,false,true)
spr(t,cd+8,ce+8,1,1,true,true)
palt()
end
q.cr=function(self)
if flr(self.ch)==#self.cg-1 then
return false
end
if self.ch==0 then
bx=8
cs(rnd(),rnd(),5)
end
self.ch=self.ch+0.25
if self.ch>2 then
for ct,cu in pairs(e) do
local cv,cw=mid(self.cd,cu.cd-cu.cx,cu.cd+cu.cx)-self.cd,mid(self.ce,cu.ce-cu.cy,cu.ce+cu.cy)-self.ce
if cu.cz<a and abs(cv)<2 and abs(cw)<2 then
local da=cv*cv+cw*cw
if da<4 then
da=1-db(da/4)
local dc,dd=de(cv,cw,0.5*da)
cu.cv+=dc
cu.cw+=dd
cu:df(flr(8*da)+1)
end
end
end
end
if self.ch==3 then
for v=1,8 do
local cu=rnd()
dg(self.cd,self.ce,0,br.dh,cos(cu)/8,sin(cu)/8)
end
di(self)
end
dj(self)
return true
end
q.dk=function(self)
if(self.dl<a or self.da<0) return false
if bor(self.cv,self.ce)!=0 then
if dm(self.cd+self.cv,self.ce) then
self.cv=-self.cv
end
if dm(self.cd,self.ce+self.cw) then
self.cw=-self.cw
end
end
self.cd+=self.cv
self.ce+=self.cw
self.dn+=self.dp
self.cv=dq(self.cv,self.dr)
self.cw=dq(self.cw,self.dr)
self.dp=dq(self.dp,self.dr)
self.da+=self.ds
self.ch+=self.dt
dj(self)
return true
end
q.du=function(self,cd,ce)
circfill(cd,ce,8*self.da,self.bd)
end
br=bf('{"part_cls":{"dr":1,"da":1,"ds":0,"ch":0,"dt":0.01,"hc":"du","jb":"dk"},"ig":{"hv":8,"da":0.8,"bd":7,"ds":-0.1},"blood_splat":{"hu":"chunk_base","spr":129},"head":{"hu":"chunk_base","spr":201},"turret_splat":{"hu":"chunk_base","spr":165,"cf":2,"no":2},"goo_splat":{"hu":"chunk_base","spr":130},"nk":{"cw":-0.05,"rnd":{"da":[0.05,0.2],"hv":[24,32],"bd":[11,3,true]}},"el":{"sfx":37,"ha":3,"cv":0,"cw":0.04,"bd":7,"rnd":{"da":[0.1,0.2],"hv":[24,32]}},"df":{"ds":-0.02,"rnd":{"da":[0.3,0.4],"hv":[8,12],"bd":[9,10,true]}},"dh":{"dr":0.95,"ds":-0.03,"rnd":{"da":[0.8,1.2],"hv":[15,30]},"bd":1},"slash":{"cg":[196,197,198],"hc":"ci","hv":12},"candle":{"cx":0.1,"cy":0.1,"dr":0.9,"rnd":{"bd":[8,9,10],"da":[0.1,0.2],"ds":[-0.01,-0.02],"dp":[0.04,0.06],"hv":[12,24]}},"hy":{"hu":"chunk_base","rnd":{"spr":[202,203,204]}},"goo_chunks":{"hu":"chunk_base","rnd":{"spr":[199,200,199]}},"green_chunks":{"hu":"chunk_base","rnd":{"spr":[215,216,215]}},"fireimp_chunks":{"hu":"chunk_base","rnd":{"spr":[219,220,220]}},"notice":{"ha":3,"dr":0.91,"hv":72,"hc":"cn"},"blast_splat":{"hu":"chunk_base","cg":[212,213,214],"dt":0.20},"blast_chunks":{"hu":"chunk_base","rnd":{"spr":[217,218,217]}},"blast":{"sfx":51,"cx":1,"cy":1,"hv":30,"ib":0,"dr":0,"cg":[192,193,208,209,194,195,210,211],"rnd":{"hx":[2,4]},"jb":"cr","hc":"cq","hw":"blast_splat","hy":"blast_chunks"},"chunk_base":{"ha":1,"dr":0.85,"da":1,"ds":0,"ch":0,"dt":0.01,"rnd":{"hv":[600,900]},"hc":"cc","jb":"dk"}}')
local dv={}
q.dw=function(self,cd,ce)
local dx,dy,dz,ea=cd,ce,eb(self.ec,self.ed)
local cv,cw=shr(dz-cd,2),shr(ea-ce,2)
for v=1,8 do
circfill(cd,ce,1,12)
cd+=cv
ce+=cw
end
line(dx,dy,cd,ce,7)
end
q.ee=function(self,cd,ce)
local dz,ea=eb(0,self.ea)
local cx=self.cx-2*rnd()
rectfill(cd-cx-2,ce+5,cd+cx+2,ea,2)
rectfill(cd-cx,ce+3,cd+cx,ea,8)
rectfill(cd-cx/4,ce,cd+cx/4,ea,7)
circfill(cd,ce,2*cx,7)
end
q.ef=function(self)
if self.dl>a then
if(not self.eg) self.eg=0
self.eg+=1
self.cx=eh(0.5,5,db(self.eg/54))
local dx,dy,ea=self.cd,self.ce,self.ea or self.ce
ea+=self.cw
if ei(bu.cd,bu.ce,bu.cx,dx,dy,dx,ea,self.cx/8) then
bu:df(self.ej.ek)
bu.cw+=self.cw/2
self.ea=bu.ce
dg(bu.cd,bu.ce,0.25,br.df,0,1.5*self.cw)
elseif not dm(dx,ea) then
self.ea=ea
end
dg(dx+self.cx*(rnd(2)-1)/16,eh(dy,self.ea,rnd()),0,br.el)
dj(self)
return true
end
return false
end
local em=bf('{"base_gun":{"sfx":55,"cg":[42],"ek":1,"iu":0.05,"dd":0.1,"ja":[90,100],"hv":32},"goo":{"cg":[63],"ek":1,"iu":1,"dd":0,"ja":[120,300],"hv":64,"ha":1},"acid_gun":{"sfx":49,"cg":[26,27],"is":3,"ie":0.9,"iu":0.2,"ek":3,"dd":0.1,"xy":[1,0],"ja":[160,200],"hv":24},"oc":{"il":"uzi","sfx":63,"la":21,"cj":32,"ck":8,"cg":[10,11],"iu":0.04,"ek":1,"dd":0.4,"ja":[15,24],"hv":5,"iv":75,"oh":2,"ep":1},"minigun":{"il":"minigun","sfx":55,"la":25,"cj":64,"ck":8,"cg":[10,11],"iu":0.04,"ek":2,"dd":0.45,"ja":[25,35],"hv":3,"iv":250,"oh":2,"ep":4},"shotgun":{"il":"pump","ho":"l","la":37,"cj":32,"ck":16,"cg":[10],"iu":0.05,"is":3,"ek":3,"dr":0.97,"dd":0.35,"ie":1,"ja":[32,48],"hv":56,"iv":33,"oh":2,"ep":3},"glock":{"il":"g.lock","la":53,"sfx":50,"cj":32,"ck":24,"cg":[10,11],"iu":0.01,"ek":4,"dd":0.5,"ja":[30,30],"hv":32,"iv":17,"oh":2,"ep":2},"rpg":{"il":"rpg","ek":0,"la":23,"cj":48,"ck":8,"spr":58,"iu":0.02,"dd":0.2,"dr":1.01,"ii":true,"ja":[32,48],"hv":72,"iv":8,"oh":3,"ep":5,"hc":"ci"},"grenade":{"il":"grenade","la":55,"cj":48,"ck":24,"ek":0,"cg":[44],"iu":0.02,"dd":0.2,"dr":0.98,"ie":1,"ii":true,"ja":[60,70],"hv":72,"iv":12,"oh":2.1,"ep":4},"ni":{"cj":48,"ck":8,"cg":[43,28],"sfx":52,"ek":5,"iu":0.05,"dd":0.1,"ja":[50,55],"hv":32,"ik":"mega_sub","im":5},"mega_sub":{"cj":48,"ck":8,"cg":[26,27],"ek":5,"iu":0,"dd":0.1,"ja":[900,900],"hv":12,"iq":4},"rifle":{"sfx":50,"cj":64,"ck":16,"cg":[10,11],"ek":5,"iu":0,"dd":0.5,"ja":[90,90],"hv":80,"my":true},"nh":{"ha":3,"sfx":36,"ek":0.5,"hv":60,"dd":1,"cv":0,"cw":1,"iu":0,"ja":[90,90],"hc":"ee","jb":"ef"},"bite":{"sfx":37,"ek":1,"hv":30,"iu":0.02,"dd":0.1,"hc":"p","ja":[4,4],"ij":"slash"},"snowball":{"cg":[60],"ek":1,"iu":0.01,"dd":0.5,"dr":0.9,"ja":[70,90],"hv":80},"horror_spwn":{"ix":"horror_cls","iu":1,"dd":0.2,"hv":145,"iv":5},"zapper":{"il":"laser","ep":5,"ho":"n","ie":1,"iv":30,"sfx":53,"cj":48,"ck":16,"la":39,"ek":5,"iu":0.01,"dd":0.6,"ja":[90,100],"hv":12,"hc":"dw"},"turret_minigun":{"sfx":55,"cg":[10,11],"iu":0.25,"ek":1,"dd":0.1,"ja":[60,80],"hv":8,"is":5},"radiation":{"cg":[12],"iu":0.1,"ek":3,"dd":0.1,"dr":0.985,"sfx":52,"is":3,"ja":[200,240],"hv":120},"cop_spwn":{"ix":"cop_cls","iu":1,"dd":0.1,"hv":145,"iv":4}}')
local en=-1
for eo,dd in pairs(em) do
q[eo]=dd
if dd.ep then
dv[dd.ep]=dv[dd.ep] or{}
en=max(en,add(dv[dd.ep],dd).ep)
end
end
local eq={}
function er(v)
return sget(88+2*flr(v/8)+1,24+v%8)
end
for v=0,15 do
local es=er(v)
for et=0,15 do
eq[bor(v,shl(et,4))]=bor(es,shl(er(et),4))
end
end
local eu=bf("[[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[27],[25],[24],[23],[22],[21],[20],[19],[19,28],[18,26],[17,25],[17,24],[16,23],[16,22],[15,22],[15,21,28],[15,20,27],[14,20,25],[14,19,25],[14,19,24],[13,18,23],[13,18,23],[13,18,22],[13,17,22],[12,17,21],[12,17,21],[12,16,20],[12,16,20],[12,16,20],[11,16,19],[11,16,19],[11,15,19],[11,15,19],[11,15,19],[11,15,19],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[10,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,19],[11,15,19],[11,15,19],[11,15,19],[11,16,19],[11,16,19],[12,16,20],[12,16,20],[12,16,20],[12,17,21],[12,17,21],[13,17,22],[13,18,22],[13,18,23],[13,18,23],[14,19,24],[14,19,25],[14,20,25],[15,20,27],[15,21,28],[15,22],[16,22],[16,23],[17,24],[17,25],[18,26],[19,28],[19],[20],[21],[22],[23],[24],[25],[27],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[27],[25],[24],[22],[21],[21],[20],[19],[18,29],[18,27],[17,25],[17,24],[16,23],[16,22],[15,22],[15,21,29],[14,20,27],[14,20,26],[14,19,25],[13,19,24],[13,18,23],[13,18,23],[12,18,22],[12,17,22],[12,17,21],[12,17,21],[12,16,20],[11,16,20],[11,16,20],[11,16,19],[11,15,19],[11,15,19],[11,15,19],[10,15,18],[10,15,18],[10,15,18],[10,15,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,15,18],[10,15,18],[10,15,18],[10,15,18],[11,15,19],[11,15,19],[11,15,19],[11,16,19],[11,16,20],[11,16,20],[12,16,20],[12,17,21],[12,17,21],[12,17,22],[12,18,22],[13,18,23],[13,18,23],[13,19,24],[14,19,25],[14,20,26],[14,20,27],[15,21,29],[15,22],[16,22],[16,23],[17,24],[17,25],[18,27],[18,29],[19],[20],[21],[21],[22],[24],[25],[27],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[27],[25],[24],[22],[21],[20],[20],[19],[18,30],[18,27],[17,25],[16,24],[16,23],[15,22],[15,22],[15,21,30],[14,20,28],[14,20,26],[13,19,25],[13,19,24],[13,18,23],[12,18,23],[12,17,22],[12,17,22],[12,17,21],[11,16,21],[11,16,20],[11,16,20],[11,16,20],[11,15,19],[10,15,19],[10,15,19],[10,15,19],[10,15,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,17],[10,14,17],[9,14,17],[10,14,17],[10,14,17],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,15,18],[10,15,19],[10,15,19],[10,15,19],[11,15,19],[11,16,20],[11,16,20],[11,16,20],[11,16,21],[12,17,21],[12,17,22],[12,17,22],[12,18,23],[13,18,23],[13,19,24],[13,19,25],[14,20,26],[14,20,28],[15,21,30],[15,22],[15,22],[16,23],[16,24],[17,25],[18,27],[18,30],[19],[20],[20],[21],[22],[24],[25],[27],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]]")
q.ev=function()
local ew,da=0x6000,flr(rnd(#eu))+1
for ce=1,128 do
local co=eu[da][ce]
local dx,dz,ex=co[1] or 31,co[2] or 31,co[3] or 31
memset(ew,0,dx+1)
memset(ew+63-dx,0,dx+1)
for cd=dx+1,dz do
poke(ew+cd,eq[eq[peek(ew+cd)]])
poke(ew+63-cd,eq[eq[peek(ew+63-cd)]])
end
for cd=dz+1,ex do
poke(ew+cd,eq[peek(ew+cd)])
poke(ew+63-cd,eq[peek(ew+63-cd)])
end
ew+=64
end
end
local ey
local ez=bf('[{"ki":[68,64,65,67,111],"jv":[66],"jt":110,"ol":1,"cx":[8,12],"cy":[6,8],"jz":[1,3],"kd":{"cx":[3,4],"ke":[8,12]},"jk":[[8,12,"bandit_cls"],[5,8,"worm_cls"],[-5,-3,"scorpion_cls"],[2,3,"cactus"],[-9,-5,"cop_box_cls"]]},{"on":"ev","ki":[86,87,87,88],"jv":[90,89,91],"jt":94,"om":[10,11,3],"ol":3,"cx":[2,3],"cy":[2,3],"jz":[2,4],"kd":{"cx":[1,2],"ke":[10,12]},"jk":[[10,15,"slime_cls"],[5,10,"barrel_cls"],[-4,-2,"frog_cls"]]},{"cursor":93,"ki":[70,71,72,75],"jv":[74],"jt":95,"om":[5,1,7],"ol":7,"cx":[6,8],"cy":[5,6],"jz":[2,3],"kd":{"cx":[3,5],"ke":[10,12]},"jk":[[8,10,"dog_cls"],[5,8,"bear_cls"],[-2,-1,"turret_cls"]]},{"ki":[102,105],"jv":[103,104,106],"jt":107,"om":[6,7,5],"ol":5,"on":"ev","cx":[4,6],"cy":[3,5],"jz":[1,4],"kd":{"cx":[1,2],"ke":[8,12]},"jk":[[3,4,"cop_cls"],[5,8,"fireimp_cls"],[5,8,"barrel_cls"]]},{"ki":[96,100],"jv":[97,98,99,108],"jt":101,"om":[7,0,5],"ol":5,"cx":[8,10],"cy":[8,10],"jz":[1,3],"kd":{"cx":[2,3],"ke":[10,12]},"jk":[[4,8,"horror_cls"],[4,4,"horror_spwnr_cls"],[-4,-2,"slime_cls"],[2,3,"candle_cls"]]},{"music":0,"jj":true,"ol":0,"om":[7,0,5],"jn":103,"jo":0,"kg":13,"kh":31,"oj":[110,28],"jk":[{"cu":"throne_cls","cd":112,"ce":6},{"cu":"lb","cd":106,"ce":27},{"cu":"lb","cd":107,"ce":27},{"cu":"lb","cd":106,"ce":28},{"cu":"lb","cd":107,"ce":28},{"cu":"ld","cd":114,"ce":27},{"cu":"ld","cd":115,"ce":27},{"cu":"ld","cd":114,"ce":28},{"cu":"ld","cd":115,"ce":28}]}]')
local fa=bf('[false,false,false,true,true,true,false,false]')
function fb(fc)
fc=fc or c
for ct,fd in pairs(fc) do
if not coresume(fd) then
del(fc,fd)
end
end
end
function fe(ff,fc)
return add(fc or c,cocreate(ff))
end
local fg=bf("[[-1,0],[0,-1],[0,1],[-1,-1],[1,1],[-1,1],[1,-1]]")
local fh,fi,fj=false,-1,false
function fk(bd,t,fl)
fh=bd or false
fi=t or-1
fj=fl or false
end
function fm(x,cd,ce,fn)
if fh then
cd-=flr((4*#x)/2+0.5)
end
if fi!=-1 then
print(x,cd+1,ce,fi)
if fj then
for ct,dd in pairs(fg) do
print(x,cd+dd[1],ce+dd[2],fi)
end
end
end
print(x,cd,ce,fn)
end
function fo(cu)
if#cu>0 then
local fp=cu[#cu]
cu[#cu]=nil
return fp
end
end
function fq(cu,ff)
for ct,dd in pairs(cu) do
if not dd[ff](dd) then
del(cu,dd)
end
end
end
function fr(fs,ft)
ft=ft or{}
for eo,dd in pairs(fs) do
if(not ft[eo]) ft[eo]=dd
end
if fs.rnd then
for eo,dd in pairs(fs.rnd) do
if not ft[eo] then
ft[eo]=dd[3] and fu(dd) or fv(dd[1],dd[2])
end
end
end
return ft
end
function dq(cd,cv)
cd*=cv
return abs(cd)<0.001 and 0 or cd
end
function eh(cu,fl,dl)
return cu*(1-dl)+fl*dl
end
function fv(cu,fl)
return eh(fl,cu,1-rnd())
end
function db(dl)
dl=mid(dl,0,1)
return dl*dl*(3-2*dl)
end
function fw(fx)
return flr(fv(fx[1],fx[2]))
end
function fu(cu)
return cu[flr(rnd(#cu))+1]
end
function fy(cu,fp)
local bd,t=cos(cu),-sin(cu)
return{fp[1]*bd-fp[2]*t,fp[1]*t+fp[2]*bd}
end
function cl(cj,ck,cd,ce,cu)
local fz,ga=cos(cu),sin(cu)
local gb,gc,gd,ge=fz,ga
fz*=4
ga*=4
local gf,gg,bd=ga-fz+4,-fz-ga+4
for gh=0,7 do
gd,ge=gf,gg
for gi=0,7 do
if band(bor(gd,ge),0xfff8)==0 then
bd=sget(cj+gd,ck+ge)
if bd!=14 then
pset(cd+gh,ce+gi,bd)
end
end
gd-=gc
ge+=gb
end
gf+=gb
gg+=gc
end
end
function gj(dx,dy,dz,ea)
local cv,cw=dz-dx,ea-dy
if abs(cv)>128 or abs(cw)>128 then
return 32000
end
return cv*cv+cw*cw
end
function de(dc,dd,gk)
gk=gk or 1
local gl=sqrt(dc*dc+dd*dd)
if(gl>0) dc/=gl dd/=gl
return dc*gk,dd*gk
end
function gm(dl,ff)
local v=1
while v<=dl do
if ff then
if not ff(v) then
return
end
end
v+=b
yield()
end
end
function ei(cd,ce,da,dx,dy,dz,ea,cx)
local cv,cw=dz-dx,ea-dy
local gn,go=cd-dx,ce-dy
local dl,gl=gn*cv+go*cw,cv*cv+cw*cw
if gl==0 then
dl=0
else
dl=mid(dl,0,gl)
dl/=gl
end
local gh,gi=dx+dl*cv-cd,dy+dl*cw-ce
da+=(cx or 0.2)
return gh*gh+gi*gi<da*da
end
local gp={}
function gq()
gp={}
end
function dj(bi)
add(gp,bi)
end
function gr()
local gs={{},{},{}}
local gt,gu,gv={},256,-128
for ct,bi in pairs(gp) do
local gw,gx=eb(bi.cd,bi.ce)
local gy=bi.dn and 8*bi.dn or 0
local gz=bi.ha or 2
bi=add(gs[gz],{bi=bi,cd=gw,ce=gx-gy,bj=gx+gy})
if gz==2 then
local dn=flr(bi.bj)
gu,gv=min(gu,dn),max(gv,dn)
local hb=gt[dn] or{}
add(hb,bi)
gt[dn]=hb
end
end
for ct,dd in pairs(gs[1]) do
dd.bi:hc(dd.cd,dd.ce)
end
for v=max(-16,gu),min(144,gv) do
local hb=gt[v]
if hb then
for ct,dd in pairs(hb) do
dd.bi:hc(dd.cd,dd.ce)
end
end
end
for ct,dd in pairs(gs[3]) do
dd.bi:hc(dd.cd,dd.ce)
end
end
local hd={}
local he=bf('[0,1,129,128,127,-1,-129,-128,-127]')
function hf(bi,ff)
if bor(bi.cx,bi.cy)!=0 then
for cd=flr(bi.cd-bi.cx),flr(bi.cd+bi.cx) do
for ce=flr(bi.ce-bi.cy),flr(bi.ce+bi.cy) do
ff(bi,hd,cd+128*ce)
end
end
end
end
function hg(bi,hd,cy)
hd[cy]=hd[cy] or{}
add(hd[cy],bi)
end
function hh(bi,hd,cy)
if hd[cy] then
del(hd[cy],bi)
if#hd[cy]==0 then
hd[cy]=nil
end
end
end
local hi,hj,hk,hl,hm=0
function hn(cd,ce,ho)
hj,hk,hm=1,1,ho or n
hl=flr(cd)+128*flr(ce)
hi+=1
end
function hp()
while(hk<=9) do
local cy=hl+he[hk]
local hq=hd[cy]
if hq and hj<=#hq then
local bi=hq[hj]
hj+=1
if bi.hi!=hi and band(bi.ho,hm)==0 then
return bi
end
bi.hi=hi
end
hj=1
hk+=1
end
return nil
end
function cs(dc,dd,hr)
by,bz=min(4,by+hr*dc),min(4,bz+hr*dd)
end
function hs()
by*=-0.7-rnd(0.2)
bz*=-0.7-rnd(0.2)
if abs(by)<0.5 and abs(bz)<0.5 then
by,bz=0,0
end
camera(by,bz)
end
function ht(cd,ce)
ca,cb=flr(8*cd)-4,flr(8*ce)-4
end
function eb(cd,ce)
return 64+8*cd-ca,64+8*ce-cb
end
function dg(cd,ce,dn,fs,cv,cw,dp,cu)
local fp=fr(br[fs.hu or"part_cls"],
fr(fs,{
cd=cd,
ce=ce,
dn=dn,
cv=cv or 0,
cw=cw or 0,
dp=dp or 0,
cm=cu or 0}))
if(fp.sfx) sfx(fp.sfx)
fp.dl=a+fp.hv
return add(bs,fp)
end
function di(self)
dg(self.cd,self.ce,0,br[self.hw or"blood_splat"])
for v=1,self.hx do
local cu=rnd()
dg(self.cd+fv(-self.cx,self.cx),self.ce+fv(-self.cy,self.cy),0,br[self.hy or"hy"],cos(cu)/10+self.cv,sin(cu)/10+self.cw,0,cu)
end
end
function hz(fp,cd,ce)
local cv,cw=fp.dc,fp.dd
line(cd+2*cv,ce+2*cw,cd+80*cv,ce+80*cw,8)
end
function ia(self)
local dz,ea=self.cd,self.ce
if self.dl>a then
local dx,dy=self.cd,self.ce
dz,ea=dx+self.cv,dy+self.cw
if self.ej.dr then
self.cv*=self.ej.dr
self.cw*=self.ej.dr
end
hn(dz,ea,self.ho)
local cu=hp()
while cu do
if ei(cu.cd,cu.ce,cu.cx,dx,dy,dz,ea) then
if cu.ib!=0 then
cu.cv+=self.cv
cu.cw+=self.cw
end
cu:df(self.ej.ek+h-1)
goto ic
end
cu=hp()
end
local id,ie=false,self.ie or 0
if dm(dz,dy) then
dz=dx
self.cv*=-ie
self.dc=-self.dc
id=true
end
if dm(dx,ea) then
ea=dy
self.cw*=-ie
self.dd=-self.dd
id=true
end
if id then
if self.ie then
self.ho=self.ej.ho
dg(dz,ea,0.25,br.ig)
sfx(self.ej.ih or 58)
else
goto ic
end
end
self.ec,self.ed,self.cd,self.ce=dx,dy,dz,ea
dj(self)
return true
end
::ic::
if self.ej.ii then
dg(dz,ea,0,br["blast"])
else
dg(dz,ea,0.25,br[self.ej.ij or"df"],self.cv/4,self.cw/4,0,self.cm)
end
local ej=self.ej.ik
if ej then
ej=em[ej]
local ho,il=self.ho,self.ej.im
fe(function()
local io,ip=0,1/il
for eo=1,ej.iq do
io=0
for v=1,il do
ir({
cd=dz,ce=ea,
ho=ho,
cm=io},ej)
io+=ip
end
gm(ej.hv)
end
end)
end
return false
end
function ir(cu,ej)
local il=ej.is or 1
local io,it
if il==1 then
io,it=cu.cm+ej.iu*(rnd(2)-1),0
else
io,it=cu.cm-ej.iu/il,ej.iu/il
end
for v=1,il do
if cu.iv then
if cu==bu and cu.iv<=0 then
sfx(57)
return
end
cu.iv-=1
end
if ej.sfx then
sfx(ej.sfx)
end
local dc,dd=cos(io),sin(io)
local cd,ce=cu.cd+0.5*dc,cu.ce+0.5*dd
local fl={
dc=dc,dd=dd,
cv=ej.dd*dc,cw=ej.dd*dd,
ho=cu.ho,
cm=io,
iw=flr(8*(io%1))
}
if ej.ix then
iy(cd,ce,
fr(iz[ej.ix],fl))
else
fr({
cd=cd,ce=ce,
ej=ej,
ie=ej.ie,
ha=ej.ha,
ho=cu.ho,
dl=a+eh(ej.ja[1],ej.ja[2],rnd()),
ec=fl.cd,ed=fl.ce,
spr=ej.spr,
jb=ej.jb or ia,
hc=ej.hc or jc},fl)
add(bs,fl)
end
if(v==1) dg(cd,ce+0.5,0.5,br.ig)
io+=it
end
end
function jc(fl,cd,ce)
palt(0,false)
palt(14,true)
local cg=fl.ej.cg
if#cg==2 then
local jd,je=cd-2*fl.dc,ce-2*fl.dd
spr(cg[2],jd-4,je-4)
end
spr(cg[1],cd-4,ce-4)
end
local jf,jg
local jh=bf('[[0,0],[1,0],[0,1],[-1,0],[0,-1]]')
function ji()
ey=0
i=ez[g]
if i.jj then
for t in all(i.jk) do
iy(t.cd,t.ce,iz[t.cu])
end
else
while jl()<7 do
end
for jm in all(i.jk) do
local il=min(fw(jm)+h*h,15)
for v=1,il do
local da=jf[flr(rnd()*#jf)+1]
local cd,ce=da.cd+fv(1,da.cx-1),da.ce+fv(1,da.cy-1)
iy(cd,ce,iz[jm[3]])
end
end
end
end
function jl()
jf={}
jg={}
for v=0,k-1 do
memset(0x2000+v*128,127,j-1)
end
local jn,jo=j/2,k/2
jp(
jn,jo,0,13)
jq(0,j-1,0,k-2,true)
return#jf
end
function jr(cu)
return jg[flr(cu.cd)+shl(flr(cu.ce),8)] or 1
end
function js(jn,jo)
local bd=0
for v=0,#jh-1 do
local fp=jh[v+1]
local t=mget(jn+fp[1],jo+fp[2])
if t==0 or fget(t,7) then
bd=bor(bd,shl(1,v))
end
end
return bd
end
function jq(dx,dz,dy,ea,jt)
local ju,dl
local jv={}
for v=dx,dz do
for et=dy,ea do
ju=js(v,et)
if band(ju,1)!=0 then
ju=shr(band(ju,0xfffe),1)
dl=112+ju
mset(v,et,dl)
if band(ju,0x2)==0 then
if rnd()<0.8 then
dl=i.jv[1]
else
dl=fu(i.jv)
end
add(jv,{v,et+1,dl})
end
end
end
end
for cx in all(jv) do
mset(cx[1],cx[2],cx[3])
if(jt) mset(cx[1],cx[2]+1,i.jt)
end
end
function jp(cd,ce,cu,ja)
if(ja<0) return
if rnd()>0.5 then
local jw=fy(cu,{fw(i.cx),fw(i.cy)})
local da={
cd=cd-jw[1]/2,ce=ce-jw[2]/2,
cx=jw[1],cy=jw[2]}
da=jx(da,#jf+1)
if da then
add(jf,da)
end
end
local il,jy=fw(i.jz),flr(rnd(3))
local ka={-0.25,0,0.25}
for v=1,il do
local kb=cu+ka[(jy+v)%#ka+1]
kc(cd,ce,kb,ja-1)
end
end
function kc(cd,ce,cu,ja)
local jw=fy(cu,{fw(i.kd.ke),
fw(i.kd.cx)})
local bd={
cd=cd,ce=ce,
cx=jw[1],cy=jw[2]}
bd=jx(bd)
if bd then
local dc=fy(cu,{1,0})
jp(
cd+dc[1]*bd.cx,ce+dc[2]*bd.cy,
cu,ja-1)
end
end
function jx(da,kf)
local kg,kh=j-2,k-3
local dx,dy=mid(da.cd,1,kg),mid(da.ce,1,kh)
local dz,ea=mid(da.cd+da.cx,1,kg),mid(da.ce+da.cy,1,kh)
dx,dz=flr(min(dx,dz)),flr(max(dx,dz))
dy,ea=flr(min(dy,ea)),flr(max(dy,ea))
kg,kh=dz-dx,ea-dy
if kg>0 and kh>0 then
for v=dx,dz do
for et=dy,ea do
if rnd()<0.9 then
mset(v,et,i.ki[1])
else
mset(v,et,fu(i.ki))
end
if(kf) jg[v+shl(et,8)]=kf
end
end
return{cd=dx,ce=dy,cx=kg,cy=kh}
end
end
function dm(cd,ce)
return fget(mget(cd,ce),7)
end
function kj(cu,cv,cw)
local cd,ce,cx,cy=cu.cd+cv,cu.ce+cw,cu.cx,cu.cy
return
dm(cd-cx,ce-cy) or
dm(cd+cx,ce-cy) or
dm(cd-cx,ce+cy) or
dm(cd+cx,ce+cy)
end
function kk(dz,ea,ex,kl,km)
dz,ea=flr(dz),flr(ea)
ex,kl=flr(ex),flr(kl)
local cv=ex-dz
local gh=cv>0 and 1 or-1
cv=shl(abs(cv),1)
local cw=kl-ea
local gi=cw>0 and 1 or-1
cw=shl(abs(cw),1)
if(cv==0 and cw==0) return true,0
if cv>=cw then
kn=cw-cv/2
while dz!=ex do
if(kn>0) or(kn==0 and gh>0) then
kn-=cv
ea+=gi
end
kn+=cw
dz+=gh
km-=1
if(km<0) return false,-1
if(dm(dz,ea)) return false,km
end
else
kn=cv-cw/2
while ea!=kl do
if(kn>0) or(kn==0 and gi>0) then
kn-=cw
dz+=gh
end
kn+=cv
ea+=gi
km-=1
if(km<0) return false,-1
if(dm(dz,ea)) return false,km
end
end
return true,km
end
function ko(cu,cv,cw)
hn(cu.cd+cv,cu.ce+cw,cu.cx,cu.cx)
local kp=hp()
while kp do
if kp!=cu then
local cd,ce=(cu.cd+cv)-kp.cd,(cu.ce+cw)-kp.ce
if abs(cd)<(cu.cx+kp.cx)/2 and
abs(ce)<(cu.cy+kp.cy)/2
then
if kp.ek and cu.kq<a and band(cu.ho,kp.ho)==0 then
cu.kq=a+30
cu:df(kp.ek)
end
if cv!=0 and abs(cd)<
abs(cu.cd-kp.cd) then
local dd=cu.cv+kp.cw
cu.cv=dd/2
kp.cv=dd/2
return true
end
if cw!=0 and abs(ce)<
abs(cu.ce-kp.ce) then
local dd=cu.cw+kp.cw
cu.cw=dd/2
kp.cw=dd/2
return true
end
end
end
kp=hp()
end
return false
end
function kr(cu,cv,cw)
return kj(cu,cv,cw) or ko(cu,cv,cw)
end
local ks=0
function kt()
return btnp(4) or btnp(5)
end
function ku(self)
di(self)
fe(function()
bv=false
local dl=0
while not kt() do
local et=48*db(dl/90)
rectfill(0,0,127,et,0)
rectfill(0,127,127,128-et,0)
if dl==90 then
fk(true,2,true)
fm("game over",64,32,14)
fm(h.."-"..g,64,96,14)
end
dl=min(dl+b,90)
yield()
end
bq=bp
end,d)
end
q.kv=function(self)
di(self)
if self.kw then
ey-=1
if ey==0 then
iy(self.cd,self.ce,iz.kx)
return
end
local da=rnd()
if da>0.7 then
local ej=fu(dv[flr(rnd(min(en,g+h)))+1])
iy(self.cd,self.ce,
fr(iz.ky,{
kz=ej,
iv=ej.iv,
spr=ej.la,
cp=ej.il}))
elseif da>0.6 or bu.iv<2 then
iy(self.cd,self.ce,iz.lb)
elseif da>0.4 and bu.lc!=bt then
iy(self.cd,self.ce,iz.ld)
end
end
end
q.le=function(self,ek)
self.cz=a+8
self.lc-=ek
sfx(61)
if not self.lf and flr(self.lc)<=0 then
self.lf=true
self:ic()
hf(self,hh)
del(e,self)
end
end
local lg=bf('[[1,0],[0,1],[-1,0],[0,-1]]')
function lh(cd,ce,li)
local lj,lk=32000
for ct,dd in pairs(li) do
local ll=gj(dd.cd,dd.ce,cd,ce)
if ll<lj then
lk,lj=dd,ll
end
end
return lk
end
function lm(self)
::lr::
while self.lc>0 do
local dz,ea
if self.ln then
local lo,lp=jr(bu),jr(self)
local da=jf[flr(16*lo+8*lp+self.lq)%#jf+1]
dz,ea=fv(da.cd,da.cd+da.cx),fv(da.ce,da.ce+da.cy)
else
dz,ea=bu.cd,bu.ce
if gj(dz,ea,self.cd,self.ce)>96 then
yield()
goto lr
end
end
local cd,ce=self.cd,self.ce
local eo,lt=flr(cd)+96*flr(ce),flr(dz)+96*flr(ea)
local lu,lv={[eo]={cd=cd,ce=ce,eo=eo}},1
local lw,lx,ly={},{}
while lv>0 and lv<24 do
ly=lh(dz,ea,lu)
cd,ce,eo=ly.cd,ly.ce,ly.eo
if(eo==lt) break
lu[eo],lw[eo]=nil,true
lv-=1
for ct,gl in pairs(lg) do
local lz,ma=cd,ce
if not kj({cd=lz,ce=ma,cx=self.cx,cy=self.cy},gl[1],gl[2]) then
lz+=gl[1]
ma+=gl[2]
end
eo=flr(lz)+96*flr(ma)
if not lw[eo] and not lx[eo] then
lu[eo],lx[eo]={cd=lz,ce=ma,eo=eo},ly
lv+=1
end
end
end
local kd,mb={},ly
while ly do
add(kd,ly)
mb,ly=ly,lx[ly.eo]
end
self.kd=kd
local dl=a+self.mc
while#self.kd>0 do
if(dl<a) break
yield()
end
self.md=nil
end
end
function me(mf,mg)
gm(90,function(v)
local da=eh(mf,mg,1-db(v/90))
local mh=da*da
for et=0,127 do
local ce=64-et
local cd=sqrt(max(mh-ce*ce))
rectfill(0,et,64-cd,et,0)
rectfill(64+cd,et,127,et,0)
end
return true
end)
end
q.mi=function(self)
self.ch+=0.25
if(self.mj) return
local cv,cw=bu.cd-self.cd,bu.ce-self.ce
local gl=cv*cv+cw*cw
if gl<4 then
self.mj=true
fe(function()
me(16,96)
me(96,16)
end,d)
fe(function()
bv,gl,cu=false,sqrt(gl),atan2(cv,cw)
gm(90,function(v)
local km=eh(gl,0,v/90)
bu.cd,bu.ce=self.cd+km*cos(cu),self.ce+km*sin(cu)
cu+=0.1
return true
end)
bv=true
mk()
end)
end
end
q.ml=function(self)
if gj(bu.cd,bu.ce,self.cd,self.ce)<1 then
bu.lc=min(bt,bu.lc+2)
dg(self.cd,self.ce,0,br["notice"]).cp="heal!"
sfx(60)
del(e,self)
end
end
q.mm=function(self)
if gj(bu.cd,bu.ce,self.cd,self.ce)<1 then
local mn=flr(bu.ej.iv/2)
bu.iv=min(bu.ej.iv,bu.iv+mn)
dg(self.cd,self.ce,0,br["notice"]).cp="ammo!"
sfx(59)
del(e,self)
end
end
q.mo=function(self)
if(self.cz>a) return
if self.mp<a and#self.kd>0 then
local md=self.md
if not md or gj(self.cd,self.ce,md.cd,md.ce)<0.25 then
md=fo(self.kd)
self.md=md
end
if md then
local dc,dd=de(md.cd-self.cd,md.ce-self.ce,0.8*self.ib)
self.cv+=dc
self.cw+=dd
end
end
if self.lq==(a%ks) then
assert(coresume(self.mq,self))
end
if self.mr and self.ms<a then
self.mt=a+self.mr
self.ms=a+self.mr+self.mu
end
if self.ej and self.mv<a and self.mt<a then
self.mw=false
if kk(self.cd,self.ce,bu.cd,bu.ce,self.mx) then
local cv,cw=bu.cd-self.cd,bu.ce-self.ce
self.cm=atan2(cv,cw)%1
self.iw,self.mw=flr(8*self.cm),true
if self.ej.my then
self.mp,self.mt=a+45,a+30
if abs(cv)>0 and abs(cw)>0 then
cv,cw=de(cv,cw)
dg(self.cd,self.ce,0,{
dc=cv,dd=cw,
hv=30,
ha=3,
hc=hz
})
end
end
end
self.mv=a+self.ej.hv
end
if self.mw and self.mt<a then
ir(self,self.ej)
self.mt=a+self.ej.hv
end
end
q.mz=function(self,cd,ce)
local io=atan2(self.cv,self.cw)
cl(self.cj,self.ck,cd-4,ce-4,1-io)
end
q.na=function(self,cd,ce)
q.nb(self,cd,ce)
if self.nc>a then
q.cn(self,cd,ce-8)
end
end
q.nd=function(self)
if self.ne<a and gj(bu.cd,bu.ce,self.cd,self.ce)<4 then
self.nc=a+30
if btnp(5) or stat(34)==2 then
dg(self.cd,self.ce,0,br["notice"]).cp=self.cp
local ej,io=bu.ej,rnd()
iy(bu.cd,bu.ce,
fr(iz.ky,{
ne=a+30,
cv=0.2*cos(io),
cw=0.2*sin(io),
kz=ej,
iv=bu.iv,
spr=ej.la,
cp=ej.il}))
bu.ej=self.kz
bu.iv=self.iv
del(e,self)
end
end
end
q.nf=function(self)
self.cm=0.75
local ng=function()
return bu.lc>0 and self.lc>0
end
fe(function()
local lc=self.lc
while(abs(bu.ce-self.ce)>4 and lc==self.lc) do
yield()
end
gm(60,ng)
if not ng() then
return
end
ir(self,em.nh)
gm(60,ng)
local co=1
while ng() do
gm(90,ng)
if co%4==0 then
ir(self,em.nh)
else
local cv,cw=bu.cd-self.cd,bu.ce-self.ce
local cu,cm=eh(0,0.2,abs(cos(a/16))),atan2(cv,cw)%1
ir({cd=self.cd-2,ce=self.ce+1,cm=cm-cu,ho=m},em.ni)
ir({cd=self.cd+2,ce=self.ce+1,cm=cm+cu,ho=m},em.ni)
end
gm(20,function()
hf(self,hh)
self.ce+=0.025
hf(self,hg)
return ng()
end)
if self.ce>25 then
bu:df(bt)
break
end
co+=1
end
end)
end
q.nj=function(self)
local io=rnd()
local dc,dd=0.16*cos(io),0.15*sin(io)
dg(self.cd+dc,self.ce+dd-0.5,0,br.nk)
end
q.nl=function(cu,cd,ce)
cd,ce=cd-4*cu.kg,ce-4*cu.kh
palt(0,false)
rectfill(cd,ce+4,cd+8*cu.kg,ce+4+8*cu.kh,1)
local nm=cu.palt or 14
if cu.cz>a then
memset(0x5f00,0xf,16)
pal(nm,nm)
end
palt(nm,true)
map(cu.jn,cu.jo,cd,ce,cu.kg,cu.kh)
palt(nm,false)
pal()
palt(0,false)
end
q.nb=function(cu,cj,ck)
if cu.nn and cu.nn>a and band(a,1)==0 then
return
end
local cf,no=max(1,flr(2*cu.cx+0.5)),max(1,flr(2*cu.cy+0.5))
cj,ck=cj-4*cf,ck-4*no
palt(14,true)
sspr(0,8,8,8,cj,ck+7*no,8*cf,8)
palt(14,false)
local nm=cu.palt or 14
if cu.cz>a then
memset(0x5f00,0xf,16)
pal(nm,nm)
end
local t,np=cu.spr,false
if cu.cg then
np=fa[cu.iw+1]
t=cu.cg[flr(cu.ch%#cu.cg)+1]
end
palt(0,false)
palt(nm,true)
spr(t,cj,ck,cf,no,np,nq)
palt(nm,false)
pal()
local ej=cu.ej
if ej and ej.cj then
palt(14,true)
local dc,dd=cos(cu.cm),sin(cu.cm)
local fd=-mid(cu.mt-a,0,8)/4
cl(ej.cj,ej.ck,cj+4*dc+fd*dc,ck+4*dd+fd*dd,1-cu.cm)
palt()
end
end
iz=bf('{"ix":{"cv":0,"cw":0,"ib":0.02,"ch":0,"dr":0.6,"ie":1,"lc":1,"kq":0,"kd":[],"mp":0,"rnd":{"mc":[120,180],"mv":[50,80],"hx":[2,4]},"cz":0,"mw":false,"mt":0,"ms":0,"cx":0.4,"cy":0.4,"mx":8,"cm":0,"iw":0,"ho":"m","hc":"nb","df":"le","jb":"mo","ic":"kv"},"barrel_cls":{"ho":"n","spr":128,"dr":0.7,"hw":"blast","hy":"green_chunks","jb":"p"},"bandit_cls":{"lc":3,"ej":"base_gun","cg":[4,5,6],"ek":1,"kw":true,"rnd":{"mu":[90,120],"mr":[90,120]}},"scorpion_cls":{"rnd":{"mu":[180,220]},"ib":0.01,"ek":2,"mr":120,"cx":0.8,"cy":0.8,"lc":10,"ej":"acid_gun","palt":5,"cg":[131,133],"kw":true},"worm_cls":{"hx":0,"ln":true,"palt":3,"cx":0.2,"cy":0.2,"dr":0.8,"ek":1,"cg":[7,8],"kw":true},"slime_cls":{"cx":0.2,"cy":0.2,"ib":0.02,"dr":0.75,"ek":2,"cg":[31,29,30,29],"ej":"goo","kw":true,"hw":"goo_splat","hy":"goo_chunks"},"dog_cls":{"mx":1,"dr":0.2,"lc":5,"ib":0.06,"ej":"bite","cg":[61,62],"kw":true},"bear_cls":{"lc":8,"ln":true,"dr":0.2,"cg":[1,2,3],"ek":1,"kw":true,"ej":"snowball"},"throne_cls":{"ha":1,"cx":6,"cy":2,"lc":75,"palt":15,"dr":0,"ib":0,"jn":87,"jo":18,"kg":12,"kh":5,"jb":"nj","hc":"nl","nr":"nf","hw":"blast","hy":"blast","rnd":{"hx":[10,20]},"kw":true},"ld":{"spr":48,"cx":0,"cy":0,"jb":"ml","df":"p"},"lb":{"spr":32,"cx":0,"cy":0,"jb":"mm","df":"p"},"ky":{"cx":0,"cy":0,"ne":0,"nc":0,"hc":"na","jb":"nd","df":"p"},"cop_cls":{"lc":8,"ln":true,"ib":0.05,"cg":[13,14,15,14],"rnd":{"mu":[160,210],"mr":[120,160]},"ej":"rifle","kw":true},"fireimp_cls":{"lc":5,"ek":1,"cg":[45,46,47,46],"ib":0.05,"kw":true,"hw":"blast","hy":"fireimp_chunks"},"turret_cls":{"cx":1,"cy":1,"ej":"turret_minigun","lc":10,"ib":0,"ie":0,"cg":[163],"mu":180,"mr":120,"hw":"turret_splat","hy":"blast","kw":true},"horror_cls":{"lc":12,"ek":2,"cg":[160,161,162],"ej":"radiation","mu":180,"mr":120,"hw":"goo_splat","kw":true,"hy":"goo_chunks"},"kx":{"ha":1,"cx":0,"cy":0,"ib":0,"mj":false,"cg":[69,82,81,80],"hc":"cc","jb":"mi","df":"p"},"cactus":{"lc":5,"ib":0,"spr":83,"jb":"p","hw":"goo_splat","hy":"green_chunks"},"candle_cls":{"nt":"candle","nv":4,"nu":0,"ib":0,"spr":178,"ic":"p","jb":"p"},"frog_cls":{"lc":18,"rnd":{"mu":[160,180]},"mr":120,"cx":0.8,"cy":0.8,"ej":"acid_gun","cg":[231,233,235,233],"kw":true},"horror_spwnr_cls":{"cg":[84],"ib":0,"kw":true,"lc":10,"ej":"horror_spwn","hy":"green_chunks"},"cop_box_cls":{"cx":0.8,"cy":0.8,"cg":[237],"ib":0,"kw":true,"lc":20,"ej":"cop_spwn","hw":"turret_splat","hy":"blast"}}')
function iy(cd,ce,fs)
local cu=fr(iz.ix,
fr(fs,{
lq=ks,
cd=cd,
ce=ce}))
if(cu.nr) cu:nr()
if(cu.kw) ey+=1 ks+=1 cu.mq=cocreate(lm)
if(cu.mu) cu.mu+=33*h
hf(cu,hg)
return add(e,cu)
end
function ns(cu)
if cu.jb then
cu:jb()
if cu.lf then
hf(cu,hh)
return
end
end
if cu.nt and cu.nu<a then
dg(
cu.cd+fv(-cu.cx,cu.cx),cu.ce-0.5,0,
br[cu.nt])
cu.nu=a+cu.nv
end
hf(cu,hh)
local nw=cu==bu and kr or kj
if not nw(cu,cu.cv,0) then
cu.cd+=cu.cv
else
cu.cv*=-cu.ie
end
if not nw(cu,0,cu.cw) then
cu.ce+=cu.cw
else
cu.cw*=-cu.ie
end
cu.cv=dq(cu.cv,cu.dr)
cu.cw=dq(cu.cw,cu.dr)
cu.ch+=abs(cu.cv)*4
cu.ch+=abs(cu.cw)*4
hf(cu,hg)
dj(cu)
end
function nx()
bv=true
local ny=fu(bw)
bu=iy(18,18,{
nz=0,oa=0,
ib=0.045,
lc=bt,
ho=l,
ob=ny.ob,
cg=ny.ob[2],
ej=em["oc"],
iv=em.oc.iv,
nn=a+30,
od=a+30,
palt=ny.palt or 14,
ic=ku,
jb=p,
hw="head"
})
return bu
end
function oe()
if bv then
local ej,cm,of,cv,cw=bu.ej,bu.cm,false,0,0
if(btn(0)) bu.cv-=bu.ib cv=-1 cm=0.5
if(btn(1)) bu.cv+=bu.ib cv=1 cm=0
if(btn(2)) bu.cw-=bu.ib cw=-1 cm=0.25
if(btn(3)) bu.cw+=bu.ib cw=1 cm=0.75
if f==1 then
of=stat(34)==1
cv,cw=stat(32),stat(33)
bu.nz,bu.oa=cv,cw
cm=(0.5+atan2(64-cv,64-cw))%1
else
of=btn(4)
if(bor(cv,cw)!=0) cm=atan2(cv,cw)
end
if of and bu.mt<a then
if bu.iv>0 then
bu.mt=a+ej.hv
bu.og=a+8
ir(bu,ej)
local dc={cos(cm),sin(cm)}
bu.cv-=0.05*dc[1]
bu.cw-=0.05*dc[2]
cs(dc[1],dc[2],ej.oh or 0)
end
end
if f==1 or bu.og<a then
bu.cm,bu.iw=cm,flr(8*cm)
end
end
if abs(bu.cv)+abs(bu.cw)>0.1 then
bu.cg=bu.ob[1]
bu.od=a+30
end
if bu.od<a then
bu.cg=bu.ob[2]
if a%8==0 then
bu.ch+=1
end
end
end
function mk()
a=0
ks=0
g+=1
local oi
if g>#ez then
h+=1
g=1
oi=true
end
bt=8*h
hd,e={},{}
bs={}
ji()
add(e,bu)
if i.jj then
bu.cd,bu.ce=i.oj[1]+0.5,i.oj[2]+0.5
else
local da=jf[1]
bu.cd,bu.ce=da.cd+da.cx/2,da.ce+da.cy/2
end
bu.cv,bu.cw,bu.cz,bu.mt,bu.og=0,0,0,0,0
bu.nn=a+30*h
bv=true
if oi then
dg(bu.cd,bu.ce,0.5,br["notice"]).cp="i feel stronger!"
end
music(-1,250)
music(i.music or 14)
end
local ok=false
bp.jb=function()
if not ok and kt() then
ok=true
fe(function()
me(16,96)
me(96,16)
end,d)
fe(function()
gm(90)
g,h=0,1
bt=8
bu=nx()
mk()
ok=false
bq=bo
gm(90)
end)
end
end
bp.hc=function()
cls(2)
fillp(0xa5a5)
local cu,da,cd,ce=a/32,0
for v=1,196 do
cd,ce=da*cos(cu),da*sin(cu)
circfill(64+cd,64-ce,da/8,0x10)
cu+=0.02
da+=0.5
end
fillp()
cd,ce=cos(a/64),sin(-a/64)
cl(8,8,64+12*cd,64+12*ce,atan2(cd,ce))
palt(0,false)
palt(14,true)
sspr(0,112,56,16,10,12,112,32)
palt()
fk(true,3)
if a%32>16 then
fm("press start",64,108,11)
end
fm(f==1 and"[keyb.+mouse]"or"[keyboard]",64,116,7)
fk(true,0,true)
fm("freds72 presents",64,3,6)
end
bo.jb=function()
bx-=1
if(bx>0) return
bx=0
gq()
oe(bu)
for ct,dd in pairs(e) do
ns(dd)
end
fq(bs,"jb")
hs()
end
bo.hc=function()
ht(bu.cd,bu.ce)
cls(i.ol)
local jn,jo=i.jn or 0,i.jo or 0
local cj,ck=64-ca+8*jn,64-cb+8*jo-4
pal()
palt(0,false)
map(jn,jo,cj,ck,j,k,1)
gr()
pal()
palt()
if i.om then
pal(10,i.om[1])
pal(9,i.om[2])
pal(1,i.om[3])
end
map(jn,jo,cj,ck,j,k,2)
pal()
if(i.on) i.on()
if f==1 then
spr(i.cursor or 35,bu.nz-3,bu.oa-3)
end
if bv then
rectfill(1,1,34,9,0)
rect(2,2,33,8,6)
local lc=max(flr(bu.lc))
rectfill(3,3,3+flr(29*lc/bt),7,8)
fk(false,0)
fm(lc.."/"..bt,12,3,7)
palt(14,true)
palt(0,false)
spr(bu.ej.la,2,10)
fm(bu.iv,14,12,7)
end
end
function _update60()
a+=1
b+=1
local dl=stat(1)
fb(c)
bq.jb()
end
function _draw()
local dl=stat(1)
bq.hc()
fb(d)
b=0
end
function _init()
poke(0x5f2d,1)
if cartdata("freds72_nuklear_klone") then
f=dget(0)
end
menuitem(1,"mouse on/off",function()
f=bxor(f,1)
dset(0,f)
end)
bq=bp
music(0)
end
__gfx__
00000000e000000ee0000000e000000ee000000ee000000ee000000e333333333333333300000000eeeeeeeeeeeeeeeeee3333eee000000ee000000ee000000e
070000700676767006676760056676700f66ff600f66ff600f66ff60333333333333333300000000eeeeeeeeeeeeeeeee3bbbb3e01111a10011111a001111110
00777700079898600579898006579890055858500558585005585850333333333333333300073000eee99eeeeee99eee3b7777b301c00000011c00000111c000
007777000694047006694040056694000ff66ff00ff66ff00ff66ff0333000333333333300073000ee9aa9eeee9999ee3b7777b30ccc0c000cccc0c00ccccc00
0077770007676760057676700657676006ff66f006ff66f006ff66f0330fef033300003300000000ee9aa9eeee9999ee3b7777b30cccccc00cccccc00cccccc0
007777000444444004444440044444400f66f6600f66f6600f66f660330e0e0330efef0300000000eee99eeeeee99eee3b7777b3055556500555556005555550
0700007005000050e050010ee005100ee06f0ff0e006f0f00f006f0e30ef0fe00ef00fe000000000eeeeeeeeeeeeeeeee3bbbb3e07000070e070070ee006700e
00000000000ee000e000000eeee00eeeee00e00eeee00e0ee0ee00ee330030033003300300000000eeeeeeeeeeeeeeeeee3333eee0eeee0eee0ee0eeeee00eee
e111111eee00000eee00000eee00000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeee00eee
11111111e0999aa0e09999a0e0999990eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeee777eeeeeeee33eeeeeeeeeeeee7777eeee0370eeee0000eeee0370ee
e111111e099414100999414009999410eeeeeeeeeeeeeeeee0000000e77777770bb0000070077777ee3bb3eeeee33eeee777777ee03bb70ee03bb70eee0370ee
eeeeeeee094444400994444009994440ee00000eee77777ee0b333b0e700000703b6606070000707e3b77b3eee3333eee777777ee03bbb0e03bbbb70ee03b0ee
eeeeeeee044455500444455004444450ee000eeeee707eeee0113110e70000070335505070000707e3b77b3eee3333eee777777ee03bbb0e03bbbbb0ee03b0ee
eeeeeeee0333bab003333ba0033333b0eee0eeeeeee7eeeee0000000e77777770550000070077777ee3bb3eeeee33eeee777777e03bbbbb003bbbbb0e03bbb0e
eeeeeeee05000050e050050ee005500eeee0eeeeeee7eeeeeeeeeeeeeeeeeeee0660eeee7007eeeeeee33eeeeeeeeeeeee7777ee03bbbbb003bbbbb003bbbbb0
eeeeeeeee0eeee0eee0ee0eeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeee7777eeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
ee00000eee00000eeeeeeeee77077000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777eeeeeeeeeee000000ee000000ee000000e
e0bbbbb0e0999aa0ee00000e70007000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7bbbb7eee00eeee022898900228898002288890
e077777009944440e0999aa000700000ee000000ee777777eeee0e0eeeee7e7eeeeeeeeeeeeeeeeeeeeaaeee7b3333b7e0e00eee0228a8a002288a80022888a0
e0373730094414100994141070007000e0496660e7000007ee001010ee770707e0000000e7777777eea77aee7b3333b7ee03b0ee022888800228888002288880
e0353530044444400944444077077000e0445550e7000007e055c1c0e70000070046666077000007eea77aee7b3333b7ee0130ee022767600228767002288760
e0333330044455500444555000000000e0400000e7077777e0501010e70707070410000070077777eeeaaeee7b3333b7eee00eee022686800228686002288680
e05333500333bab00333bab000000000ee0eeeeeee7eeeeeee0e0e0eee7e7e7ee00eeeeee77eeeeeeeeeeeeee7bbbb7eeeeeeeee02000020e020010ee002100e
ee00000ee000000ee000000e00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777eeeeeeeeee00eeee00ee0ee0eeeee00eee
ee00000e330000033300000333000003eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3300000333333333eeeeeeee0082018feeeeeeeee0e0eeeee0e0eeeeeeeeeeee
e066666030222ee0302222e030222220eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee30222ee033000003ee88eeee10941d9aeeeeeeee090900ee0909000eeeeeeeee
e0777770022f1f100222f1f002222f10ee00000eee77777eee000000ee777777022ffff030222ee0e000000e21a92ea7eee55eee0dd8480e0dd84540eeeeeeee
e0dd8dd0022ffff00222fff002222ff0e076670ee700007ee03bb660e7000007022f1f10022f1f10e088777031b33bb6ee5675ee0d4454400d447070eeeebbee
e0d888d00ffff8f00fffff800ffffff0e055000ee700777e0453b000700007770f2ffff0022ffff0e055667045c149c7ee5665ee0447070e0441110eeebbbbbe
e0d686d0055555500555555005555550e050eeeee707eeee04400eee70077eee0ffff8f00ffff8f0e000000e51d156d6eee55eee044444400447070eee3bbb3e
e0dd6dd0070000703070060330067003ee0eeeeeee7eeeeee00e0eeee77e7eee0555555005555550ee88eeee65e267efeeeeeeee0404004004044440eee333ee
e0000000303333033303303333300333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3000000330000003eeeeeeee76fd77f7eeeeeeeee0e0ee0ee0e0000eeeeeeeee
4444444444444444040404044444444444444444eee222ee666666666666666666666166666166665c775c5c66666666d1dddddddddddddd121212eed2dddddd
4444444444994444404040404444444444444444ee21112e66666666666666666116666666156666ccc7c7c561111116d01dddddd1eddddd21ee21de20ddd2ed
44b4b44445495444040404044944444444444444e2122212666666666666666665566666615666661cc7c77c15d5d5d1d00dddddd11ddddd11dde212ddd0d02d
435b5344445544444040404045444494444444442121122166666666611116666666666165166666c111ccc56d5d5d66ddddd11ddddddddd21dde121dd02dd0d
4535354444444444040404044444445444444444212121216666666615d5d66666666666665166665c5cc77c15d5d666ddd11001ddddeedd12111212d02d0ddd
445554444444444440404040444944444444444421222121666666665d5d51666666166666156666c5c5c1c75d5d51161dd00000ddd12e1d2121de21dd0dd0dd
4444444444444444040404044445444444444444e21112216666666665d5d5666666666666566666515c7ccc65d5d5560dd0000ddddd11dd12121d12d2dd02d0
4444444444444444404040404444444444444444ee22221e66666666666d5d666666666666666666c115c7c5665d56d6dddd00dddddddddd2121212100dd2ddd
ee222eeee12222eeeee1111eeee00eeeeee00eee66666666555555555555555555dddd5536111161313131313535353555555155110110001111111111111111
e21112ee1221112eee122221e00bb0eee00bb00e6666656655555555555555455d5555d515666653131313135377775355151055100010005151515161616161
2122212e12122212e12211220b05300ee07bb70e666666665555555555555555d55dd55d31555511313131313700007551000015001000001515151516161616
2121121212121212e1212212030350b0e037730e665666665555555555555555d5d51d5d13111113131313135600006355000001100010005555555566666666
2122121212211212e1211212e0353530e033330e666666665555555554455555d5d11d5d36111161313131313622206555500000110110005555555566666666
221122122122212ee2122212ee03500ee033330e666666665555555554455555d55dd55d156666531313131355eee65355100005000000005555555566666666
1222212ee21112eeee21112eee0530eee003300e6666656655555555555554555d5555d531555511313131313522553551500055000000005555555566666666
e11112eeee222eeeeee222eeee0000eeeee00eee66666666555555555555555555dddd5513111113131313135322535355150515000000005555555566666666
666166669991999999000009906000606660666600000000dddd11116666666667676666ddddd11d6dddddd65555555599959999eeeeeeee5555555544444444
661516664491444440445440402222206605066611010111dddd11116555555665656666dddd11116dd77dd6111100004aaaa774ee00000e5555555544444444
615551661111111110095900108000806666666610111011dddd11116000000665656666dddd11116d7667d6111100005acccc75ee06940e5454545447444744
155555169999919990440440908080800066606655555556dddd111160b0280665656666dddd111d6d6666d6dddd11119a333ca9ee09a60e4444444441676144
6555556644449144409565904088888065600566655555661111dddd6000000665656666d1dddddd6d5665d61111dddd4a3333a4ee05450e4444444444777444
6655566611111111100454001088088066655666665556661111dddd6677776665656666111ddddd6dd55dd61111dddd5aaaaaa5ee04540e4444444444161444
6665666699919999909959909020502066656666666566661111dddd66666666656566661111dddd6dddddd61111dddd92212229ee05450e4444444444444444
6666666644914444400000004001110066666666666666661111dddd6666666660606666dd1ddddd667777661111dddd44954444ee00000e4444444444444444
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9111111991111111911111199111111111111119111111111111111911111111
a111111aa1111111a111111aa11111111111111a111111111111111a111111119111111991111111911111199111111111111119111111111111111911111111
91111119911111119111111991111111111111191111111111111119111111119111111991111111911111199111111111111119111111111111111911111111
91111119911111119111111991111111111111191111111111111119111111119111111991111111911111199111111111111119111111111111111911111111
91111119911111119111111991111111111111191111111111111119111111119111111991111111911111199111111111111119111111111111111911111111
91111119911111119111111991111111111111191111111111111119111111119111111991111111911111199111111111111119111111111111111911111111
91111119911111119111111991111111111111191111111111111119111111119111111991111111911111199111111111111119111111111111111911111111
99999999999999999111111991111111999999999999999911111119111111119999999999999999911111199111111199999999999999991111111911111111
eeeeeeeeee88eeeeeeeeeeee55555555555555555555555000555555ffffffffccccccccccccccccffffffffffffffffcccc00000000ccccfffaafff00000000
ee0000eee22ee22eeeeeeeee55555550005555555555550eee055555ffffffffccccccccccccccccffffffffffffffffccc0666576660cccfff99fff00000000
e07bb70ee8eee28eeee3eeee5555550eee05555555555502e2055555ffffffffcccccc0000ccccccffffffffffffffffccc0666666660cccfff88fff00000000
e0b77b0eeeeeeeee3eeb2ee355555502e20555555555550070055555ffffffffccccc0eee70cccccffffffffffffffffccc0777777770cccfff00fff00000000
e03bb30ee8ee8ee8ebe2eebe5555550070055555555555010105555500ffff00cccc02eee7e0cccc0000000000000000ccc0555555550ccc0000000000000000
e0b77b0eeee888e2eeeeeeee55555501010555555555550111055555c000000ccc6002eee7e006ccccccccc00cccccccccc0555555550cccccc00ccc00000000
e03bb30eeee28eeeee3eee3e55555011111055555555501111105555c1cccc1ccc6602eee7e066ccccccccc00cccccccccc0555555550ccccc0000cc00000000
ee0000eeeeeeeeeeeb2eeeeb55000122122100555550012222210005cccccccccc5502eee7e055ccccccccc00cccccccccc0066666600cccc060060c00000000
0000e000eeeeeeeeeeeeeeee50222211111222055502221111122220cc0000cccc1102eee7e011ccccccccc00ccccccccccc06655660ccccc071170c00000000
0b700bb0eaaaaaaeeee82eee55000122222100205020012222210005c0bbbb0ccccc02eee7e0cccccccc00000000ccccccc0665bb5660cccc057750c00000000
0bb0bb30e919119eeeee82ee502221eeeee12205550221eeeee12220c0bbbb0ccc60020000e006cccccc01100110ccccccc066bbbb660cccc055550c00000000
0bbbb30ee999999eeeee82ee5500028fef8200205020028fef820005c077770ccc660025620066cccccc05500550ccccccc066bbbb660cccc055550c00000000
0bbbbb0ee911919eeee82eee50222122f221220555022122f2212220c033330ccc550256762055cccccc00000000cccccccc06666660ccccc100001c00000000
03b03bb0eee55eeeee82eeee50200070007000205020007000700020c033330ccc110256762011ccccccccc00cccccccccc1100000011ccccc1111cc00000000
033003b0eee99eeeeeeeeeee55011101110110205020110111011105cc1111cccccc00567600ccccccccccc00cccccccccc1105555011ccccccccccc00000000
0000e000eee99eeeeeeeeeee55551111111111055501111111111555cccccccccccc1156760cccccccccccc00ccccccccccc11000011cccccccccccc00000000
eee0ee0eeeee0eeeee0ee0eeeeeeee0000eeeeeeeeeeeeeeeeeeeeeecccccccccccccc56671cccccccccccc00cccccccccc7e222222e7cccccccccc000000000
e00b00b0e000b00ee0b00b0eeeee00666600eeeeeeeeeeeeeeeeeeee777777777777775005777777777777700777777777777777777777777777777000000000
0b0b0bb00bb0b0b00bbb0b0eeee0666666660eeeeeeeeeeeeeeeeeee111111111111115005111111111111100111111111152222222251111111111000000000
0bbbbbb00bbbbbb00bbbbbb0eee0666666660eeeeeeeeeeeeeeeeeee111111111111111551111111111111100111111111152222222251111111111000000000
0bbb33300bbbb3300bbbbb30ee056666666650eeeeeeeeeeeeeee55e111111111111111111111111111111100111111111152222222251111111111000000000
0bbbbbb00bbbbbb00bbbbbb0e06577666677560ee0eeeeeeeeee000e000000000000000000000000000000000000000000055555555550000000000000000000
0b0000b0e0b0030e000b3000056055777755065005e00e5eddeeee50cccccccccccccc0000ccccccccccccc00cccccccccc7eeeeeeee7ccccccccccc00000000
00eeee00ee0ee0eeeee00eee0560005555000650eeedee5ed000eeeeccccccccccccccccccccccccccccccc00cccccccccc7eeeeeeee7ccccccccccc00000000
eeeeeeeeeeeeeeeeeeeeeeee0556000000006550eeee00ee0500eeeeccccccccccccccccffffffffccccccc00cccccccccc7eeeeeeee7ccc6667eeeeeeee7666
eeeeeeeeeeeeeeeeeeeaeeee0555660000665550eee1051e1111eeee7777777777777777ffffffff777777700777777777777777777777776617eeeeeeee7666
0eeeeeeee0eeeeeeee070eee055555666655555005ee11eeeeeeeeee1111111111000111ffffffff111111100111111111152222222251116157eeeeeeee7166
e0eee0ee0eeee0eee06760ee05555555555555500dee5ee5eeeeeeee1111111110567011ffffffff111111100111111111152222222251111557eeeeeeee7516
0ee00f0ee0e00f0eee060eeee05550505055550ee0deee11eeeeee0e1111111110567011ffffffff111111100111111111152222222251116557eeeeeeee7566
0e05580e0e05580eee050eeeee055151515550ee500eeeeeee5ed55e0000000000576000ffffffff000000000000000000000000000000006657eeeeeeee7666
e0555550e0555550e05050eeeee0055555500eee555ee55deeeee50efffffffff00650ffffffffffffffffffffffffffffffffffffffffff6667eeeeeeee7666
ee00000eee00000ee00e00eeeeeee000000eeeeeeeeee0000eeee00effffffffff000fffffffffffffffffffffffffffffffffffffffffff6667eeeeeeee7666
eeeee777eeeeeeeeeeeee111eeeeee1eeee8eeeeeee8eeeeeee8eeeeeee0eeeeeeeeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
eee77777eeeeeeeeeee11111eee1e1e1eeee8eeeeeee8eeeeeee8eeeee0b0eeeeee000eeee07770eeeeee0eeee0e0eeeeee00eee000000000000000000000000
ee777777eeeee000ee111888ee1e1e1eeeee88eeeeee88eeeeee88eeeee0eeeeee03330ee0707070ee0e070ee07070eeee0770ee000000000000000000000000
e7777777eeee0000e1188888e1e1eeeeeeee8eeeeeee88eeeeee88eeeeeee0eee0b33b0ee0670760e07070eeee070eeeeee0070e000000000000000000000000
e7777777eee00000e1188999ee1eeeeeeeeeeeeeeee888eeeee888eee0ee030eee0bb0eeee07770eee07070eee070eeeeeeee0ee000000000000000000000000
77777777ee00000011889999e1eeeeeeeeeeeeeeeeeee8eeee8888ee030e0bb0eee00eeeee06660ee070e0eee07070eee0eeeeee000000000000000000000000
77777777ee0000001188999a1eeeeeeeeeeeeeeeeeeeeeeee8888eeee0eee00eeeeeeeeeeee000eeee0eeeeeee0e0eee070eeeee000000000000000000000000
77777777ee000000118899a7e1eeeeeeeeeeeeeeeeeeeeeeee88eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeee000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeee000000000000000000000000
eeeeeeeeeeeeee88eeeee1e1eeeee1e1ee080eeeeee080eeeee00eeeeee00eeeeee00eeeeeeeeeeeeeeeeeeeee080eeeeee000ee000000000000000000000000
eeeeeeeeeeee8899ee1eeeeeee1eeeeeee080eeeee0080eeee0880eeee0bb0eeee0b70eeeeee0eeeeee00eeeeee0eeeeee02220e000000000000000000000000
eeeee888eee899aaeee1eeeeeee1eeeeee0990eee08990eee099980ee0377b0eee07330eeeeeeeeeee0560eeeeeee0eee082280e000000000000000000000000
eeee8999ee89aaaaeeeeeeeeeeeeeeeee09a990ee09a790ee09aa90ee033370eee0330eee00eeeeeee05560ee0ee020eee0880ee000000000000000000000000
eee899aaee89a777e1eeeeeee1eeeeeee0a7aa0ee0a77a0ee0a77a0ee003300eee10011ee00eeeeee1100011020e0880eee00eee000000000000000000000000
eee89aa7e89aa7771eeeeeee1eeeeeeeee0000eeee0000eeee0000eee110011eeee111eeeeeeee0eee11111ee0eee00eeeeeeeee000000000000000000000000
eee89a77e89aa777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
000ee000000ee0000000000000000eee0000000ee000000e0000000eeeee00000000eeeeeeee00000000eeeeeeee00000000eeeeeeeeeeeeeeeeeeee00000000
07700770077007700b700bb007770eee0777770e0077770007777700ee00bbbbbbbb00eeee00bbbbbbbb00eeee00bbbbbbbb00eeeeee000000000eee00000000
07770770077007700bb0bb3007770eee0776660e0770077007700770e0773bbbbbb3770ee0773bbbbbb3770ee0333bbbbbb3330eeee0ccc161ccc0ee00000000
07777770077007700bbbb30007770000077000ee0770077007700760078873bbbb378870078873bbbb378870033333bbbb333330eee0cc15751cc0ee00000000
07767770077007700bbbbb0007777770077770ee077667700777770e068073bbbb378060068073bbbb370860013331bbbb133310eee0ccc111ccc0ee00000000
067067700677776003b03bb0067777700677770e0777777007777770e0663bbbbbb3660ee0663bbbbbb3660ee0111bbbbbb1110eeee0ccccccccc0ee00000000
0660066000666600033003b0066666600666660e0660066006606660ee056666666650eeee056666666650eeee056666666650eeeee07777777770ee00000000
000ee000e000000e00000000000000000000000e00000000000e0000e03333333333330ee03333333333330ee03333333333330eeee01111011110ee00000000
eeeeeeeeeeeeeeee0000000000000eeee000000e000ee0000000000ee03000000022030ee03000000220030ee03000002200030eeee01661016610ee00000000
eeeeeeeeeeeeeeee0b700bb007770eee00777700077007700777770ee03333333312330ee03333331223330ee03333332133330eeee01771017710ee00000000
eeeeeeeeeeeeeeee0bb0bb3007770eee07766770077707700776660ee00111111111100eee011111111110ee00011111111110eeeee01111011110ee00000000
eeeeeeeeeeeeeeee0bbbb300077700000770077007777770077000ee0bb3301001033bb000011333333110000bb3313133311000eee00101010100ee00000000
eeeeeeeeeeeeeeee0bbbbb00077777700770077007767770077770ee03333131131333300bb3313113133bb00333313113133bb0eee01010001010ee00000000
eeeeeeeeeeeeeeee03b03bb00777777006777760077067700677770e066001311310066003333131131333300660003113133330eee00101010100ee00000000
eeeeeeeeeeeeeeee033003b00666666000666600066006600666660e000ee0b11b0ee00006600b3113b00660000ee0b103b00660eee01010001010ee00000000
eeeeeeeeeeeeeeee0000000000000000e000000e000ee0000000000eeeeee000000eeeee000ee00ee00ee000eeeee000e00ee000eee00000000000ee00000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010501010101010101050101010501010101008201010101050505010101010105050501010105050105010501010182828282828282828282828282828282
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000008282000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7f7f7f7d7d7d7d7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7f7f7f7f7f7f7f7f7f0000000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f0000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f00000000000000
7f7f7e424242427b7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7d7d7d7d7d7d7d7e4242424242424242424242424242424242427b7f7d7d7d7d7d7d7f0000000000000000000000000000000000000000000000007f7f7d7d7d7d7d7d7d7d7f7f0000007f7f7d7d7d7d7d7d7d7d7d7d7d7d7d7d7f7f00000000000000
7f7d7c6e6e6e6e797d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7c42424242424242786e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e7b7e4242424242427b0000000000000000000000000000000000000000000000007f7e42424242424242427b7f0000007f7e63616161616161616161616161637b7f00000000000000
7e424244444444424242424242424242424242424242424242424242426e6e6e6e6e6e6e424444444444444444444444444444444444417b7e6e6e6e6e6e6e7b0000000000000000000000000000000000000000000000007f7e6e6e6e6e6e6e6e6e7b7f0000007f7e65656565656565656565656565657b7f00000000000000
7e6e6e4444446f6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e444444414443446e404444444044446f444444444444444444447b7e4444444444447b0000000000000000000000000000000000000000000000007f7e44444444444444447b7f0000007f7e60646064606060646064606460607b7f00000000000000
7e4444444444444344444444414444444444444444444444444444444444446f4444444444446f444444446f4444404444444444444441797c4444444444447b0000000000000000000000000000000000000000000000007f7e4441444444446f447b7f0000007f7e64605555556055555555555555607b7f00000000000000
7e444444444444444444444444444444444444444444444444444444444444444444444444446f4444444444444444444444444444444442424444444444447b0000000000000000000000000000000000000000000000007f7e44444444444444447b7f0000007f7e60605560555555646055555555607b7f00000000000000
7f7777777777777777777644444444444444737777764140446f737776444444444444444444444444444444446f4444444444444444446e6e4444444444447b0000000000000000000000000000000000000000000000007f7e44444444444444447b7f0000007f7e60555555645555645564645560607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444444444444407b7f7f7e4444446f7b7f7e444444444444444444444444444444444444444444444444444444444044444444447b0000000000000000000000000000000000000000000000007f7e44454443444440447b7f0000007f7e60646460645555556055605564607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444444444144447b7f7f7e44444444797d7c444444444444444444444444444441444444444444446f44444444444444444444447b0000000000000000000000000000000000000000000000007f7e44444444444444457b7f0000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444044444444447b7f7f7e44444444424242446f43444444444444444444444444444444444444444444444044444444444444447b0000000000000000000000000000000000000000000000007f7e44444344444444447b7f0000007f7e606064606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7d7c44444444444441797d7d7c444444446e6e6e4444444444444471777777777644446f4444444444444444444444444444444444447b0000000000000000000000000000000000000000000000007f7e44444440404444447b7f0000007f7e606460646060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e424244444444444444424242424444444441444444444444444444427b7f7f7f7e4444444444444344444444444444444144444444447b0000000000000000000000000000000000000000000000007f7f77777777777777777f7f0000007f7e606060606060bebf6064606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e6e6e444444444444446e6e6e6e4444444444444444446f444444436e7b7f7f7f7e4444444444444444444444444444434444444444447b0000000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f0000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e434444444444444444444444444444446f40444444444444444444447b7f7f7f7e4444444441444444444444414444444444444444447b0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e4441444444444444444443444444444444446f4444444444446f4444797d7d7d7c444444444444444444444444446f444444444473777f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e444444444444444444447377764444444444444444444444444044444242424242444443444444444473777777764444444444447b7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e444444444444444444447b7f7e4444444444444440444444444444446e6e6e6e6e44737776444444447b7f7f7f7e4444444444447b7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e646060646060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7e444444444444444444447b7f7e4444444144444440444444444444444144444444407b7f7e444144447b7f7f7f7e4444444444447b7f7f00000000000000000000000000000000000000000000008b8b8e8787878787878e8a8a000000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f777644444444737777777f7f7e444444444444446f444444444440444444444343447b7f7e44444444797d7d7d7c4444444444447b7f7f00000000000000000000000000000000000000000000009b9b9e88898c8d88899e9a9a000000007f7e606060646460bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444444447b7f7f7f7f7f7f7777777777777777777777777777777777777777777f7f7e4444404442424242424444444444447b7f7f00000000000000000000000000000000000000000000009b9b9798999c9d9899979a9a000000007f7e606060606060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444444447b7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e44446f446e6e6e6e6e4444444444447b7f7f00000000000000000000000000000000000000000000009baba7a8a9acada8a9a7aa9a000000007f7e646060646060bebf6464606064607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444444447b7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e4444444444434444444444444444447b7f7f0000000000000000000000000000000000000000000000bbb8b8b8b8bcbdb8b8b8b8ba000000007f7e606060606060bebf6064606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444344447b7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e444444444444434044444444444444797d7f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060646460bebf6060646060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7e444444447b7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e44444444737777777644444444444342427b0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e646060646060bebf6064646060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f777777777f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e4444446f7b7f7f7f7e4444444444446e6e7b0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060606060bebf6060646060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f777777777f7f7f7f7e44444444444444447b0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e646060646060bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e44444444444344447b0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060606060bebf6060606464607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e44444444737777777f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e606060646460bebf6060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7e6f4444447b7f7f7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7e60606060606060606060606060607b7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f777777777f7f7f7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000007f7f77777777777777777777777777777f7f00000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f00000000000000
__sfx__
010a00000b1500b1300c1300b1200b1200c1200b1200b1200c1200b1200b1200c1200b1200b1200c1200b1200b1200c1200b1200b1200c1200b1200b1200c1200b1200b1200c1200b1200b1300c1300b1300b130
010a00000c14000000000000c12000000000000c12000000000000c12000000000000c12000000000000c12000000000000c12000000000000c12000000000000c12022110221151811022110221151611022120
010a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1101a115211101a1101a1151f1101a120
010a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022110221152111022110221151f11022120
010a00000c1300b1300b1300c130131201a1200c130181201a1200c130161201a1200c130181301a1300c1400b1400b1400c1400b1400b1400c1400b1400b1400c1400b1500b1500c150131401a1400c15018140
010a00002212518120221202212513120221202212518120221202212516120221202212518130221302213513130221302213518130221302213516130221302213518130221302213513140221402214518140
010a00001a125211201a1201a1252612022120221252112022120221251f1202212022125211302213022135261301a1301a135211301a1301a1351f1301a1301a135211301a1301a13526140221402214521140
010a000022125211202212022125261201a1201a125211201a1201a1251f1201a1201a125211301a1301a1352613022130221352113022130221351f1302213022135211302213022135261401a1401a14521140
010a00001a1400c150161401a1400c150181401a1400c1502614022140221452114022140221451f14022140221452114022140221452614022140221452114022140221451f1402214022145211402214022145
010a000022140221451614022140221451814022140221451f1401a1401a145181401a1401a145161401a1401a145181401a1401a1452614022140221452114022140221451f1402214022145211402214022145
010a000022140221451f14022140221452114022140221451f1401a1401a145181401a1401a145161401a1401a145181401a1401a145131401a1401a145181401a1401a145161401a1401a145181401a1401a145
010a00001a1401a1451f1401a1401a145211401a1401a1452614022140221452114022140221451f1402214022145211402214022145131401a1401a145181401a1401a145161401a1401a145181401a1401a145
010a00002714024140241452314024140241451f14024140241452314024140241452714024140241452314024140241451f14024140241452314024140241452614021140211451f14021140211451e14021140
010a00002714024140241451a1401b1401b145181401b1401b1451a1401b1401b145131401b1401b1451a1401b1401b145181401b1401b1451a14024140241452614021140211451f14021140211451e14021140
010a00001f1401b1401b1451a1401b1401b145181401b1401b1451a1401b1401b145131401b1401b1451a1401b1401b145181401b1401b1451a1401b1401b145211401a1401a145181401a1401a145151401a140
010a00001f1401b1401b1452314024140241451f14024140241452314024140241452714024140241452314024140241451f1402414024145231401b1401b145211401a1401a145181401a1401a145151401a140
010a0000211451f14021140211452614021140211451f14021140211451e14021140211451f1402114021145221401f1401f1451e1401f1401f1451a1401f1401f1451e1401f1401f145221401f1401f1451e140
010a0000211451f14021140211452614021140211451f14021140211451e1402114021145181402114021145221401f1401f1451e1401f1401f1451a1401f1401f1451e1401f1401f145221401f1401f1451e140
010a00001a145181401a1401a145121401a1401a145181401a1401a145151401a1401a145181401a1401a1451f1401a1401a145181401a1401a145161401a1401a145181401a1401a145131401a1401a14518140
010a00001a145181401a1401a145121401a1401a145181401a1401a145151401a1401a1451f1401a1401a1451f1401a1401a145181401a1401a145161401a1401a145181401a1401a145131401a1401a14518140
010a00001f1401f1451a1401f1401f1451e1401f1401f145241401f1401f1451e1401f1401f1451b1401f1401f1451e1401f1401f145241401f1401f1451e1401f1401f1451b1401f1401f1451e1401f1401f145
010a00001a1401a145161401a1401a145181401a1401a1452414018140181451514018140181451314018140181451514018140181450f1401814018145151401814018145131401814018145151401814018145
010a0000221401f1401f1451e1401f1401f1451a1401f1401f1451e1401f1401f145221401f1401f1451e1401f1401f1451a1401f1401f1451e1401f1401f145211401e1401e1451c1401e1401e1451a1401e140
010a00002214016140161451514016140161451314016140161451514016140161450e14016140161451514016140161451314016140161451514016140161452114015140151451314015140151451214015140
010a00001e1451c1401e1401e145211401e1401e1451c1401e1401e1451a1401e1401e1451c1401e1401e1451f1400b1300c1300b1200b1200c1200b1200b1200c1200b1200b1300c130211400b1300c1300b130
010a00001e1451c1401e1401e145211401e1401e1451c1401e1401e1451a1401e1401e1451c1401e1401e1451f1401a1401a1450c1201a1401a1450c1201a1401a1450c1301a1401a145211401a1401a1450c140
010a0000151451314015140151450e1401514015145131401514015145121401514015145131401514015145221401a1401a145181401a1401a145161401a1401a145151401a1401a145211401a1401a14518140
010a0000151451314015140151450e140151401514513140151401514512140151401514513140151401514522140221402214518140181450000016140161450000015140151450000021140211402114518140
010a00000b1400c1400e1400b1400c1500b1500b1500c1502614022140221452114022140221451f14022140221452114022140221452614022140221452114022140221451f1402214022145211402214022145
010a00001a1401a1450e1401a1401a1450c1501a1401a1452614022140221452114022140221451f14022140221452114022140221452614022140221452114022140221451f1402214022145211402214022145
010a00001a1401a1452a1401a1401a145181401a1401a1451f1401a1401a145181401a1401a145161401a1401a145181401a1401a145131401a1401a145181401a1401a145161401a1401a145181401a1401a145
010a000018145000002a1402a1402a1451814018145000001f1401a1401a145181401a1401a145161401a1401a145181401a1401a145131401a1401a145181401a1401a145161401a1401a145181401a1401a145
010a0000221401f1401f1451e1401f1401f1451a1401f1401f1451e1401f1401f145221401f1401f1451e1401e145000001a1401f1401f1451e1401f1401f145211401e1401e1451c1401e1401e1451a1401e140
010a00002214016140161451514016140161451314016140161451514016140161450e14016140161451514015145000001314016140161451514016140161452114015140151451314015140151451214015140
010f000023140000002314000000211400000023140000000014000145000000000000000000000000000000001400014500000071450622500000171400000018140000001f1401f14500140001450000000000
010f0000231402314523140231453662500000231402314500140001450714007145001400014507140071450014000145071400714500140001451f1401f1451f1401f1451f1401f14500140001450714007145
00020000144601d470317703b77032470284701e4701a4701747013470116700f470135700e4600c4600b4600e6600b4500a450095500a4400944009440094400b64008430084300843009630074300642006420
000200000f4500e4600d4700d4500d44017440124400d4500b4600a4700a4700a460094600a4500b450144500d45009450074500646005460054500545006450104500e4600b460094600846008460084600d460
010f00001c140000001c140062201a140000001c14000000366250000009140091450014000145091400914536625000000914006220001400014515140000001714000000306253661536625000000914009145
010f0000211402114530625366151f1401f1453062536615306250000030625366153662500000306253661506220062253062536615366250000030625366153662500000181400622030625000003062536615
010f0000211400000021140000001f14000000211400000000140001450000000000000000000000000000000014000145000000914506225000001c140000001c140000001c1401c14500140001450000000000
010f0000306250000021140211453662500000211402114500140001450914009145001400014509140091450014000145091400914500140001451c1401c1451c1401c1451c1401c14500140001450914009145
010f00001d140000001d140062201c140000001d14000000366250000005140051450014000145051400514536625000000514006220001400014515140000001714000000306253661536625000000514005145
010f00001d1401d14530625366151f1401f1453062536615306250000030625366153662500000306253661506220062253062536615366250000030625366153662500000181400622030625000003062536615
010f0000211400000021140000001f14000000211400000000140001450000000000000000000000000000000014000145000000514506225000001d140000001d140000001d1401d14500140001450000000000
010f0000211402114521140211453662500000211402114500140001450514005145001400014505140051450014000145051400514500140001451d1401d1451d1401d1451d1401d14500140001450514005145
010f00001f140000001f140062201d140000001f1400000036625000000714007145001400014507140071453662500000071400622000140001451f140000001f14000000306253661536625000000714007145
010f00001f1401f145306253661521140211453062536615306250000030625366153662500000306253661506220062253062536615366250000030625366153662500000062200622030625000003062536615
010f000023140000002314000000211400000023140000000014000145000000000000000000000000000000001400014500000071450622500000171400000018140000001f1401f14500140001450000000000
00010000203502436024370213701a370173601e3501c34017340153501b3501b33017340123401734018330133300e3301032011320093200a320073200a3100001000000000000000000000000000000000000
000200002f66032660306702a63026610216501d6501965014650116500d6400a6500863007630066200561004600076000760006600056000560004600036000360003600026000160002600016000160001600
0002000029670216700e6702c670246600b6502763013660256301c640126300c6200864005620016200162001600076000760006600056000560004600046000460004600046000360002600026000160001600
000100000936012370203702f37024370133700b3700a370093700836008350073300734006350063500534005330043200432004320043100432004330043300434004340033400534004340043300433004330
00010000381503b1503b1603916035160321602e16028160231501c1501615014150111500f1500e1400c1400b1300b1300a1200a1200a1100a1100a1000d3001430013200142001320012000120000000000000
0002000037650386603667004660015602b5002050016500025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b660106600c65007640016300161002600176000f6000960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000006220092400a26009250082500625005240052300421005200022002220022200202002020020200202002020022200117000e7000d7000e7000f700036000360003600036000360004600046000d600
000100003f6603c750046000260002600026000160001600016000160002400024000160001600016000240002400034000240003400024000240002400024000240002400024000240002400024000240001400
000200002b1602a6602a160291602366020160166600b160071500514002130011200111001110011100111001610000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c4402e460334502e4502d4502c440294502a43027430244202241021450144501f4501e4501e4501e4501f45024450384503240023400134001e40024400304002d400194001e400294002e4002d400
00030000263402f350323601b360113600235002300013002c3502235014320013000230021350143500735000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000186502f25017650242400d640012002f600296001e600156000d60008600116000e6000c6000960006600036000560004600036000260001600000000000000000000000000000000000000000000000
00020000085500d550065500255001550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002c6702b6702a6702067015670116600464007630046100160006600026000160002600016000160004500035000350003500025000250002500025000150001500047000470004700047000470004700
__music__
01 00 01 02 03
00 04 05 06 07
00 08 09 0a 0b
01 0c 0d 0e 0f
00 10 11 12 13
00 14 14 15 15
00 16 16 17 17
00 18 19 1a 1b
00 1c 1d 1e 1f
00 0c 0c 0e 0e
00 10 10 12 12
00 14 14 15 15
00 20 20 21 21
02 18 19 1a 1b
01 26 27 28 29
00 2a 2b 2c 2d
02 2e 2f 22 23
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
