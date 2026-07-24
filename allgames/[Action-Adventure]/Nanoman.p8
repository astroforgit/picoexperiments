pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--nanoman v1.0
--by fun fetched/gruber music
a=-1 b={"nano","laser","armor","dash","seek","hammer"} c={0,2,2,2,2,2} d={6,2,13,10,11,4} e={13,9,6,12,3,2} f={{g=108,h=17},{g=65,h=21,i="/70005161405261a0f170c0f171e0f370022f70d2d370e3f361062960daff70dbff605caf71ecff705dafc93e4f716e9fc9becf703f4f70bfcf.6e426f526ea26fb2/7000f261606371d0e37e21417e91b170c3f3600afa700b0f70cbff71dcef701dbf.7d117f417d817fb17003c5336d63c583c42c/7000f070010360c8ff70c9ff71daef609bbf709cbf71adbf600e8f700f8f.c5b170f1d9d7d9aa/60a5b570f6ff606878602b3b.fa824ef5/7030f16071c170324a70f2fa6075c570060f5e96af5fa6af60586860d8e8707b8f618b8f61bbcf70cbcf601e6f60deff701f6f70dfff.fa834f054e954fa56e3a6f4a/7000f04b909f71014a70414a70e1ff71f1f570023a7d03397e13397f333961043860d7f771f9fd600edf700fdf.c3d3c258705ac3db/7000f04b909f70013f71112470d1f661d2f560164670e7ff71f7fb71182b704c4f70dcdf605e8f60aecf705f8f70afcf.c242ff66c3d8c24a/70000f4b202f7070fa7181b97d92a87fa2a86193a7605464604767603a6a70cbff601fbf.d953d946d9394b9f/7000f05ef0f370010f7013634b232f61040e70546461455f70555f6069b9706aaf717b9e60beff70bfff.6d91c5d16ef36144ff36c266ff17ff1bff3cc2bd704f/5f00f17010f1600eff700fff.5f02c5826df26f03d94dd99dd9ed/7000f070c1f671d1d570f7ff5e697f5f797f704b5f615b5f618b9f709b9f600e3f60aebf700f3f70afbf.fa444e684f78/7000b070f0ff7001846002727094b470050f604bec704cec704d4f707def718dee705f6f.10a3ae5daf6dbe5ebf6e/70000f7040f04d50734d90b37041c26151736191b370f1ff6d53736d93b3601cef701def712e4f7e7e9e71bedf.02cb7d6e7f9e"},{g=81,h=17,i="/63e0f272f0f24d223673030f5d23365b1526620a3f733a3f63caff62daff73faff720b2f72dbef624cbd724dbd.7c257c36/7200f27050b27501315d61745d91a475d1f16d64746d94a4633c7f624c7f737c7f724d6f63bdff62cdff73fdff72ceef.fc17fc99/7200f27030927501115d41545d718475b1d163f3fb6d44546d7484633b7f624b7f737b7f724c6f63beff62ceff72cfff.fc98fc19/7240f05e80925f909273010b5bc1f163f1fb6217b74b272f72475f628bfb620e3f626eff720f3f726fff.73006c105b206b305e505f606d316e516f61727172a16ab17ce196526e826f926db29683ff15ef98efa8ff39ff1a/7300235d102373040b63f4ff620eef720fff.6c225c326c135c23faa370c570977069703b/5d60f17270f15d626b63f2ff62043473050f6247584b979f5db7bf724858621b3b621ebf73bebf720faf.c5b2c2154b965aa66bb6c2796c6b5c7b/7200b073b0b163f0ff72011173020f6255f563b6ff72c6ff4dd8ed5dd9ed726b7f737b7f6ddded621e6e720f5f.c581c2155b075c17c21b720e/72007063b0ff72c0ff73010f71d1e46245a571d6e9621a7a71dbee624faf.7370ff11ff14ff16ffa6ff19ffa9ff1bffabff1effae/73000f7240e05d41d17281925d62735da2b462073f62e7ff72083872e8f872092f62495f62c9df72f9ff723a5a72caea711b4c724b4f626b7f62abbf72dbfe71ebfe725c7c72accc723d3f725d6f628d9f72bdcf7e2e4e727eaf72dfef.5dc06ad05ce06ec16fd16e426f5296c296436e636f7396646ea46fb496a57d1e7f4e/63f0ff6214b463051f73151f72080f5b98f97299f95b6a8a721ebf622ebe73bebf.6304fac662076a885d895a5a7c8a/7200b063f0ff5b01947271947391947202625d626572435472043473050f625bbb725c7c737c7f634d4f727eff628efe725f6f.73b06b616b335d346d356d65634b634cefbcae5daf6d109defadbe5ebf6e/73000f6340f17250f163f2ff620b4f62bbff720c4c72bcfc720d2f625daf706d9f72ddff723e5f4a7e8e72cecf.03ba6a4e5b5e5bae6bbe5d4f72af5dbf"},{g=65,h=25,i="/74005274a0f25d21245d41445db1b45dd1d474030f74f3fa4d6b9f656c9f757c8f745d5f74adaf641f4f64bfff.6d236d436db36dd37524754475b475d44e7b4f8b/7400f074010a6415f54b353a74f6ff640aea4bcacf640fef.ee43ed18ee7d/7400f074f1ff6405a574060f645aea641fbf.c3e8c219/7400b074f0ff74010f6455e5641aaa644fef.c56174b1c215c3ea/74000f7440f77051857eb1d170f1f57eb3d37564747eb5d5ca57f7641c4f747c7f74acaf74dcdf741d6fc95d6ec98d9fc9bdcfc9edff645efe748f9f74bfcf74efff.7da17fd17da37fd37da57fd5/7400375d50627001255b41527504144b95bf64a5bf64e5ff74a6bf74e6ffca0727740c0f643c4fc91d4f743d4f640e2e645e9f741f2f745f9f.7c517c62fcc2fcd8/74004175103165f0f56401414b557f64657f64a5bf74667f74a6bf64cbff74ccff65ddfe75edfe640e5f740f5f.fc92fc88/7400f55d20235dd0d35b33d34e43b65e44b65f54565f74765f94965fb4b66e46b674f6ff640bbf740cbf650d0e652d5e753d4e657dae758d9e.7d417e517f617d917ea17fb16c234f534f734f934fb37cd36f566f766f966fb696479667968796a7/7400b074f0ff74010f6485f6c91627c966f67486f665f6fc64172764679764ccfc641d2f74cdef741e6fc93e6fc9aebf643f6f64afbf.6db76dd775b875d8/74006074a0f074010f74a1b474f1ff6474b4644cac654d4f657daf748dafc9beef745f6f74bfef.c5d110e864e9ae5daf6dbe5ebf6e4a9e/74000f6540f07450627480f065414265717274f1ff65070f65f7ff641cef741ded7d3dcd7e4d8d757d8d7eadcd741fef.6da16dc16e526f6204db7f6d7fcd"},{g=81,h=25,i="/7600f25d30346750645d808477e0f14a51626702226652626792c267d3f35b448466d9ff76daff77ebfe660ccf760dce675d6e772e9e4a5e6e760f4f767fcf.674367736c345c545a647c84/6710f05d50815de0f17601036d51816de1f15b19f9760a0f.760067036609fc2afc5afc8afcbafcea/5d00f06720f06d01115b099966699f766a9f777b8e66accf76adcf66dfff.fc1afc4a/7600f06710b067e0f076010c76c1dc66758f5b568676768f5be6f65b19295b5c6c67ccfc5becfc660f6f669fff.ef71ef81ff65d9f5ff68ff1bd9fb670c/6700f076a0a35b337366637f5be3f376647f76d4d65b86d65b39595bb9f976aaac66dcff76ddff77eeff660f5f668fcf.67a366d35b0667d6d948ede866a95b0c67ac/6700f076203376506376d0f65ee0f65ff0f66733636693af7624297694af6606195b56867607196709695b496966b9ff763a3c76baff67cbef666c8f79ccef760d0f766d8f777e9f661f5f.4a416642ee3467d66ee66ff6ee686639660cee1c673c/7600065b40f076607176a0c267617167a2c24b686f66889f4bf8ff76899f760a0f661e7f66aeff761f7f76afff.6c3076f067f1966296f267066609/7600f05b10205b60705ba0e076315276819276f1ff67325267829266182f4b888f66a8bf76192f76a9bf663e9f763f9f.6be067015de16ce29683660e760f/7600b067106076f0ff76010f7671b267a1a56772827693b466354f76b5b976364b66586f76596f667b8f763c3f767c8f774e7f669eef769fef.4aa266a3ff856795ff26ff57ff7967b9674a4a4b764dff1e/76000f7630f24e31f15b51625b91a25bd1f15e32e26752626792a267d2e276f3ff66182f66586f6698af76192f76596f7699afc93c4fc97c8fc9bccf663d4f667d8f66bdcf763e4f767e8f76becf.4f414f814fc15f425f825fc26e336f436e736f836eb36fc39634967496b4/6710c076f0ff76010f66175867185866c9ef76caeb664ccc76cccf76ecef764d4f767dbf778dae76dddf765f6f.76001326103667da4adbae5daf6dbe5ebf6e/76000f7640f27770b267426267c2e277738477a3b476f3ff67748467a4b4661cef761dee675daf795eaf761f2f76dfef.679205cb673d67cd4a3e4ace764f76bf"},{g=97,h=30,i="/7800f27d11437e21437f41435b71a17dc1f37ed1f37ff1f378035378b3f3680bff780cff702dee5b3dde.5a615ca1/7800f36910636990e469142569546578f4f769b5c6680bff780cff791d6f799def.6e336f4396346ed46fe46e156f256e556f656e956fa596d59616965696966eb66fc696b768f7/7800f04bd0d478010778f1ff6844e4680747688a9a780c0f68ddef78deef681fcf.ed34680beebb/7800f04b202778010f7841f47951635b91f15b93f378f5ff68172768879778787f4bd8df681a2a688a9a685d6f785e6f78cecf78eeef781f4f788fbf.5a815a8378774bd768e768cd68edff1eff2eff3eff4eff8eff9effaeffbe/7800f04bd0d578010f78f1ff6815e54b252a681aea4bdadf681fef.fa844b2f/7800f04b202f78010f78f1ff68154f78164779172f78383f68587f78192f78497a5b0a2b5c2a2b794a5f786b6f688baf784c5f787cad5a1d5e5b2d5e5c5d5e797d8f789e9f68beef4bdedf787f8f78afcf.1014d934d967d99a78ef/7800f078010f4b212f4b515b4b818b4bb1bb4be1ebc94eff783fff.ed43ee49681e683e781f/7800f06889bf788aba684b7f789bbd784c8c680d3f785d8f780e4f789eaf68ceff78bfff.fa75/7800f54e22f25b42525b82925bc2d25e23355f33355e63755f73755ea3b55fb3b55ee3f55ff3f5680c3f686cbf68ecff780d3f786dbf7e8dad78edffc94f5fc9cfdf.5d214f324f724fb24ff26e256f356e656f756ea56fb56ee56ff59626966696a696e67d7d7fad7dfd/7800f55d70755b02727eb2e25e23355f33355e63755f73757eb4e478f6ff680c3f686cbf7e0d3f783d3f786dbf7e8dad780e2fc94f5f.4e224f324e624f727da27fe27da47fe46e256f356e656f75962696667f2d7d7d7fad/7800b378f0ff71214271618278041f69a4b878b4b86858a8685bec785cec785d5f788def799dee786f7f.10671387ae6daf7dbe6ebf7e/78001f7850f16851d178e2ff69181a69e8ea686a9f786b9f682c5f68acdf792d5f5d7d8f79addf782f5f78afdf.7d627e727f827da27eb27fc206894e7c4f8c"}} function j(k,g,h,l) l=l or 7 for m=0,1 do for n=0,1 do print(k,g+n,h+m,0) end end print(k,g,h,l) end function o(p,q) if not q then _draw() end
for r=1,p do flip() end end function s(t,u,v,w,x) if btnp(t) then
v-=1 elseif btnp(u) then v+=1 else return v end if v<w then v=x end
if v>x then v=w end
sfx(9) return v end function y(z,ba) return flr(z*(ba/16))%ba+1 end function bb(i,bc,bd) bd=bd or 0 return sub(i,bc,bc+bd) end function be() camera() cls(0) o(8,true) end function bf() pal() palt(0,false) palt(14,true) end bf() function bg(bh,bi) return flr(bh/bi) end function bj() bk=0 dset(0,0) dset(1,0) for r=2,6 do dset(r,-1) end end function _init() f[1].i=""for r=0x2000,0x2000+1964 do f[1].i=f[1].i..bb("0123456789abcdef./",peek(r)) end bk=1 if cartdata("funfetched_nanoman")==false then
bj() end bl() end function _update60() bm+=1 if a>=0 and bm%60==0 then
a=min(32766,a+1) end bn() end function _draw() bo() end function bl() bp,bq,bm,bn,bo=bk,0,0,br,bs music(2) end function bt() be() music(4) menuitem(1) bm,bu,bv,bw,bn,bo=0,0,0,0,bx,by end function bx() if bu==0 then
bv,bw=s(0,1,bv,0,2),s(2,3,bw,0,1) end bz=bw*3+bv+1 if btnp(5) then
if bz>1 or dget(0)==5 then
music(-1) sfx(10,3) bu=100 end end if bu>0 then
bu-=1 if bu==0 then
ca() end end end function by() for h=0,128,8 do for g=0,128,8 do local cb=(bm%32)/4 spr(198,g-cb,h-cb) end end map(48,19,0,24,16,10) local cc=16 for r=1,6 do local g,h,cd,ce=((r-1)%3)*40,bg(r-1,3)*48,13,7 if dget(r)>-1 then
cd,ce=0,13 end local p=b[r].."man"if r==1 then
if dget(0)==5 then
cc+=16 p,cd,ce="dr. pico",13,7 else p=""end end j(p,g+24-#p*2,h+58,ce) if r==bz then
if bm%16<8 then
map(26,16,g+8,h+24,4,4) elseif bu>0 then cd=7 end end rectfill(g+15,h+31,g+32,h+48,cd) end map(cc,22,0,24,16,10) j("stage select",40,10,7) end function ca() cf,cg,bk=f[bz],0,1 if bz>1 then
cg=60+bz*2 end be() ch={} local r,i=0,cf.i for ci=1,#i do local l=bb(i,ci) if l=="/"then
r+=1 cf[r]=""else cf[r]=cf[r]..l end end menuitem(1,"main menu",bt) cj() bm,ck,cl,cm,cn,co,cp,bm,cq,cr,cs,ct,cu=0,1,0,0,0,0,120,0,nil,0,0,nil,""cv(cn) music(bz*10-10,0,3) bn,bo=cw,cx end function cy() rectfill(0,0,128,128,0) local cz=rnd() srand(1) for r=1,100 do pset((rnd(128)-bm*((rnd()^2)*.75+.1))%128,rnd(128),6+(r%2)*7) end srand(cz) end function br() if bq==0 then
bp=s(2,3,bp,0,bk) if btnp(5) then
bq=80 sfx(10) music(-1) end else bq-=1 if bq==0 then
if bp==0 then
bj() a=0 end bt() end end end function bs() cy() map(16,16,24,36,10,3) local k={"new game","continue"} for r=0,bk do if bp~=r or bq%16<8 then
j(k[r+1],48,75+r*10,7) end end j("—",37,75+bp*10,8) j("game created by @funfetched\nwith music by @gruber_music",10,116,13) end function da() repeat ck=s(2,3,ck,1,6) until db()>-1 if btnp(4,1) then
bn,bo,cs=cw,cx,db() sfx(13) end end function dc() camera(-18,-24) rectfill(0,4,94,73,2) rect(1,5,93,72,7) for r=1,6 do local dd=dget(r) if r==1 then
dd=ct.de end if dd>-1 then
local df=r*10 spr(r,14,df) j(b[r],26,df+1,7) rectfill(54,df,86,df+6,0) for bi=1,dd do local n=54+bi*2-1 line(n,df+1,n,df+5,7) end end j(">",8,ck*10+1,7) end end function db() return dget(ck) end function dg(g,h,dh,l) rectfill(g,h,g+6,h+32,0) for bi=1,dh do local m=h+33-bi*2 line(g+1,m,g+5,m,l) end end function di(dj,dh) if dj<dh then
dj=min(dh,dj+.15) if bm%4==0 then sfx(8) end
dk=true end return dj end function cw() if cr>0 then
cr-=1 if cr==60 then
music(5,0,3) end end if co~=0 then
cm+=co*2 ct.h+=.25*co if cm>=128 or cm<=-128 then
ch={} cn+=co cv(cn) ct.h-=128*co if ct.dl==6 then ct.dm=0 end
co,cm=0,0 dn(true) o(20) end return end if cp>0 then
cp-=1 if cp>0 then return end
ct=dp(cl+56) end dk=false if ct then
ct:di() end if cq and cq.dq==0 then
cq:di() end cs=di(cs,db()) if not dk then
for bi in all(dr) do if bi.ds then
bi:ds() end if bi.dt==true then
for du in all(dv) do if dw(du) and
dx(bi:dy(),du:dy()) then local dz=du:ea(bi) if dz>0 and not bi.eb then
ec(bi) end if dz==2 and not bi.eb then
sfx(12) end end end elseif ct and dx(bi:dy(),ct:dy()) then if ct:ea(bi) and not bi.eb then
ec(bi) end end bi.g+=bi.ed bi.h+=bi.dm bi.ee-=1 if bi.ee==0 then ec(bi) end
end if ct then ct:ds() end
for du in all(dv) do if dw(du,true) or ef[du.eg].eh then
du:ds() if ct and dx(du:dy(),ct:dy(),2) then
if ct.ei==0 then
ct:ea(du) else du:ea(ct) end end end end if co==0 then
dn(false) end foreach(ej,ek) foreach(el,ek) end if ct then
local em=cl cl,cm=flr(mid(0,ct.g-56,128*7)),0 if not en(cl,cn*128) then
cl=bg(em,128)*128 end if not en(cl+127,cn*128) then
cl=bg(cl,128)*128 end if co==0 then
if ct.h<0 and ct.dl~=5 then
co=-1 end if ct.h>111 then
co=1 end end if co~=0 and en(ct.g+8,(cn+co)*128) then
o(20) if co==-1 then
ct.h=-1 else ct.h=112 end eo(bg(ct.g,128),cn+co,0,16) else co=0 if ct.h>128 then
music(-1) o(30) ct:ep() end end end if eq then
eq-=1 if eq==0 then
eq=nil ca() end end if er then
er-=1 end if es then
es-=1 if es==280 then
music(9) end if es==0 then es=nil
if bz==1 then
for et in all(ch) do mset(et.g,et.h,0) sfx(12) o(8) end music(0) ct.dr=0 else bt() end end end end function ec(bi) if bi.dt==true and bi.eu==1 and ct then
ct.dr-=1 end if bi.ep then bi:ep() end
del(dr,bi) end function cj() dr,dv,el,ev,ef,ej={},{},{},{},{},{} if ct then ct.dr=0 end
end function dn(ew) for r=1,#ef do local ci=ef[r] local eh=abs(ci.g*8-cl-60)<72 if not ci.du and(ci.eh==eh or ew) then
if ci.r<7 and not ex(ci.g*8) then
return end ci.du=ey[ci.r](ci.g*8,ci.h*8,r) add(dv,ci.du) end end end function cx() camera() if cr<=60 and cr%12>6 then
pal(0,6) end cy() camera(cl,cm) if co~=0 then
map(0,16,cl,co*128,16,16) end map(0,0,0,0,128,16) bf() local ez=bg(cl,8)-1 local fa=ez+17 for h=1,15+abs(co*16) do for g=ez,fa do if h~=16 then
local cc,dm=g,h if h>16 then
cc-=ez+1 dm+=co*16-16 end local ci=mget(cc,h) if band(fget(mget(cc,h-1)),0x5)>0 and ci>0 and fget(ci)==0 then
spr(233,g*8,dm*8) end end end end foreach(el,fb) foreach(dv,fb) if ct then ct:fc() end
foreach(dr,fb) foreach(ej,fb) camera() if ct then
dg(4,4,ct.fd,7) if ck~=1 then
dg(10,4,cs,12) end end if cq then
dg(116,4,cq.fd,10) end if cp%16>7 then
j("ready",54,61,7) end if es and es<220 and cu~=""then
j(cu,64-#cu*2,61,7) end if fe then
j(fe,16,52,7) end end function ek(r) r:ds() end function fb(r) r:fc() end function dw(cb,ff) local h=0 if ff then h=8192 end
return dx(cb:dy(),{cl-4,-h,136,128+h*2}) end fg="202122232425262728290001303122322433263428350203"fh={} fi="011211120111121211120111"for r=1,#fi,2 do fh[bg(r,2)+1]={g=bb(fi,r)-1,h=bb(fi,r+1)-1} end function fj(g,fk) local fl={g=g,h=0,ed=0,dm=.05,fm=2.25,fn=.225,fo=4,dl=1,fp=0,fk=fk,fq=0,fr=0,fs=0,de=16,fd=0,ft=true,fu=false,fv=12,fw={2,3,4,3},fx=-32,dq=1,ei=0,fy=0} fl.bm=0 local fz=false for h=0,15 do if fget(mget(bg(fl.g,8),h))>0 then
if fz==true then
fl.h=h*8-15 break end else fz=true end end function fl:di() self.fd=di(self.fd,self.de) end function fl:ds() if self~=ct and cr>0 then
return end if self.dq>0 then
if self.dq==1 then
self.fx+=8 if self.fx>=self.h then
self.fx=self.h self.dq-=.1 sfx(11) end elseif self.dq<1 then self.dq=max(0,self.dq-.1) end return end self.bm+=1 if self.ei~=0 then
local ci=sgn(self.ei) self.ed=ci*4.5 self.ei-=ci if self.ei==0 then
self.ed=max(min(self.ed,self.dq),-self.dq) end self.fy-=self.ed else self.fy*=.7 if abs(self.fy)<4 then
self.fy=0 end end self.g+=self.ed if self.g<cl-4 then
self.g=cl-4 end if self.g>cl+116 then
self.g=cl+116 end local cc={} cc.dl,cc.ga,gb=gc(self,0x81) if cc.dl>0 then
self.g-=sgn(self.ed)*cc.ga self.ed=0 end cc.dl,cc.ga,gb=gc(self) self.ed*=.7 self.h+=self.dm local gd={} gd.dl,gb,gd.ga=gc(self) local ge,gf,gg=gc(self,2) if band(gd.dl,4)==4 then
self:gh() end if self.dl<=4 then
self.dm=.05 if band(gd.dl,1)==1 or(band(gd.dl,2)==2 and band(cc.dl,2)==0) then
self.h-=sgn(self.dm)*gd.ga end self.dl=1 if self:gi(0) then
self.ed-=self.fn self.dl=2 self.fk=true end if self:gi(1) then
self.ed+=self.fn self.dl=2 self.fk=false end if self.dl~=1 then
self.fp=(self.fp+.175)%4 self.dl=self.fw[flr(self.fp)+1] end if band(gd.dl,3)==0 then
self.dl=5 elseif self:gi(4) and self.fu==true then self.dm=-self.fm self.dl,self.fu=5,false sfx(1) end if not self:gi(4) then
self.fu=true end elseif self.dl==5 then if band(gd.dl,1)==1 or(self.dm>0 and band(gd.dl,2)==2 and band(cc.dl,2)==0) then
if self.dm<0 and gd.ga>4 then
gd.ga-=4 end self.h-=sgn(self.dm)*gd.ga if self.dm>0 then
self.dl,self.dm=1,.05 sfx(2) if not self:gi(4) then
self.fu=true end else self.h+=.1 self.dm=.05 end elseif self.ei==0 then self.dm=gj(self.dm) end if self==ct and not self:gi(4) and self.dm<0 then
self.dm*=.5 end if self:gi(0) then
self.ed-=self.fn self.fk=true end if self:gi(1) then
self.ed+=self.fn self.fk=false end elseif self.dl==6 then if self.dm<0 and band(gd.dl,1)==1 then
self.h+=sgn(self.dm)*gd.ga+5 self.dm=0 end if self.fq==0 then
if self:gi(2) then
self.dm-=.2 self.fk=self.h%8<4 elseif self:gi(3) then self.dm+=.2 self.fk=self.h%8<4 end end if self:gi(0) then
self.ft=true end if self:gi(1) then
self.ft=false end if self:gi(4) or
(band(gd.dl,2)==0 and self.dm>0) then self.dl,self.dm,self.fk=5,0,self.ft end if self.dm>0 and band(gd.dl,1)==1 then
self.h-=sgn(self.dm)*gd.ga self.dl=1 end if self.dm<0 and
band(gk(self.g+8,self.h+12),2)~=2 and band(gk(self.g+8,self.h+4),2)==0 then self.h,self.dl=bg(self.h,8)*8+1,1 end self.dm*=.7 if self.dl==1 then
self.dm,self.fk=.05,self.ft end end if self.dl~=6 then
if(self:gi(2) and gg>=1) or
(self:gi(3) and gg<1) then if gf>3 then
self.g,self.dl,self.ed,self.dm,self.ft=bg(self.g,8)*8+4,6,0,0,self.fk if not self:gi(2) and self:gi(3) then
self.h+=4 end end end end if self:gi(5) and self.fr==0 then
self.fq=20 local g,ed local h=self.h+7 if self.dl==6 then
self.fk,self.dm=self.ft,0 end if self.fk then
g,ed=self.g,-1 else g,ed=self.g+15,1 end if self.dl==5 or self.dl==6 then
h-=1 end self:gl(g,h,ed,dm) end if self.fr>0 then
if not self:gi(5) or self.fr>1 then
self.fr-=1 end end if self.fq>0 then
self.fq-=1 end self.fs=max(0,self.fs-1) end function fl:gl(g,h,ed,dm) local gm,gn=self.go,self==ct if gn then gm=ck end
if gm==3 then gm=1 end
if gn then
if db()<c[gm] then
return end dset(ck,db()-c[gm]) cs=db() end if gm==1 then
if not gn or self.dr<3 then
local bi=gp(g,h+1,ed*2.5,0,0,gn) bi.dq,bi.eu,bi.fo,bi.ee,bi.dt=11,1,1,48,gn self.fr=2 if gn then self.dr+=1 end
end elseif gm==2 then gq(g,h,ed,gn) self.fr=30 elseif gm==4 then self.ei=12 if self.fk==true then
self.ei=-12 end self.fy=0 self.fr,self.dm=30,0 self.h-=1 sfx(3) elseif gm==5 then gr(g,h,ed,gn) self.fr=30 elseif gm==6 then gs(g,h,ed,gn) self.fr=30 end end function fl:fc() local gm=self:gt() local gu=self.go pal(13,e[gm]) pal(6,d[gm]) if self.dq>0 then
if self.dq==1 then
spr(203,self.g+4,self.fx,1,2) else local ci=204 if self.dq<.5 then
ci=206 end spr(ci,self.g,self.h,2,2) end return end local dl=self.dl if self.fq>0 then
dl+=6 end if self.fs%4>1 then
pal(0,7) end local gv,gw=-1,(dl-1)*4+1 if self.fk then gv=1 end
spr(bb(fg,gw,1)+self.fv,self.g+gv*4+4,self.h,1,2,self.fk) spr(bb(fg,gw+2,1)+self.fv,self.g-gv*4+4,self.h,1,2,self.fk) if dl~=6 and dl~=12 then
if self~=ct then bf() end
if self.fs%4>1 then pal(0,7) end
spr(gu,self.g+4+fh[dl].g*-gv,self.h+fh[dl].h,1,1,self.fk) end bf() if self.fy~=0 then
sspr(64,64,16,16,self.g+8-sgn(self.fy),self.h,self.fy,16) end end function fl:dy() return{self.g+5,self.h+1,6,15} end function fl:ea(cb) if cb==ct then
if ct.ei==0 then
return 0 end else if not cb.dt or self.ei~=0 then
return 0 end end if self.fs>0 then return 0 end
self.de-=cb.fo*(bb(self.gx,cb.eu*4,2)+0) self.fd,self.fs=self.de,20 sfx(4) if self.de<=0 then
self:gh() end return 1 end function fl:gh() music(-1) dr={} o(30) local g,h,gm=self.g+7.5,self.h+7.5,self:gt() gy(g,h,10,d[gm]) for bh=0,.875,.125 do gy(g,h,3,d[gm],64,cos(bh)*1.5,sin(bh)*1.5) end self:ep() end function fl:ep() sfx(5) local gm=self:gt() if dget(gm)==-1 then
cu=b[gm].." acquired"dset(0,dget(0)+1) end dset(gm,16) del(dv,self) es,cq=360,nil end function fl:gt() if self==ct then
return ck end return self.go end return fl end function dp(g,fk) gz=fj(g,fk) gz.go,gz.fd,gz.eu,gz.dr,gz.gx=1,16,4,0,"   4.0,016,1.0,1.0,1.0,1.0"function gz:ha(dq) local de,hb=0,0 if dq==16 then de=8 end
if dq==22 then de=2 end
if dq==19 then hb=8 end
if dq==25 then hb=2 end
self.de=min(self.de+de,16) if ck~=1 then
dset(ck,min(db()+hb,16)) end end function gz:ea(cb) if self.fs>0 or self.ei>0 then
return 0 end local hc=cb.fo if cb.eu then
hc*=(bb(self.gx,cb.eu*4,2)+0) end if ck==3 then
local hd=min(dget(3),hc*2) hc=max(0,hc-hd/2) dset(3,max(dget(3)-hd,0)) cs-=hd end local he,hf=hg(self) local hh,hi=hg(cb) local ci=sgn(he-hh) if cb.eu==2 then
ci=sgn(cb.g-(self.g+8)) end if self.dl<=4 then
self.dm=-1 else self.dm=0 end sfx(7) self.de-=hc self.fd,self.fs,self.ed,self.fk,self.dl,self.fu=self.de,100,ci*4,ci==1,5,false if self.de<=0 then
self:gh() end return 1 end function gz:ep() sfx(5) ct,eq=nil,180 end function gz:gi(r) if btnp(4,1) then
bn,bo=da,dc sfx(13) end if self.fs<80 and(not cq or cq.dq==0) then
return btn(r) else return false end end return gz end function hj(g,fk) bi=fj(g,fk) function bi:gi(bi) local r=bg(self.bm,10)%#self.hk+1 local hl,hm=bb(self.hk,r),bb(self.hn,r) if hl~="."then
if bi==hl+0 then
return true end elseif ct and self.go~=6 then self.fk=self.g>ct.g end if hm~="."and bi==hm+0 then
return true end return false end return bi end function ho(g,fk) if not ex(g) then
return end cq=hj(g,fk) cq.de,cq.hp,cq.hk,cq.hn,cq.gx=16,128,".",".","   999,999,999,999,999,999"function cq:ds() if cr==60 then
self.dq,fe=0,"fool! you can't stop me\n\n    i created you!"end if er==120 then
self.hp=132 elseif er==0 then be() print("the end!",48,60,7) music(9) o(100,true) if a>=0 then
local hq="(time: "..flr(a/60)..":"..a%60 .."."..flr((bm%60)*1.66)..")"print(hq,64-#hq*2,96,13) end o(500,true) be() bl() end end function cq:fc() spr(self.hp,self.g,self.h,2,2) end function cq:ea(cb) if self.hp~=128 then
return 0 end self.de,self.fd,self.hp,self.ed,er,fe=0,0,130,1,240,""music(-1) sfx(17) return 1 end return cq end function hr(g,fk) cq=hj(g,fk) cq.go,cq.fn,cq.gx,cq.hk,cq.hn=2,.5,"   1.0,4.0,1.0,0.5,0.5,0.5",".......00000......11111",".5...........5....4...."return cq end function hs(g,fk) cq=hj(g,fk) cq.go,cq.gx,cq.hk,cq.hn=3,"   0.5,2.0,0.5,0.5,0.5,.75",".......000000000.......111111111",".....5.5.5.5.44......5.5.5.5.44."return cq end function ht(g,fk) cq=hj(g,fk) cq.go,cq.gx,cq.hk,cq.hn=4,"   1.0,012,1.0,.25,0.5,0.5",".........................","..5..445....5....5..445.."return cq end function hu(g,fk) cq=hj(g,fk) cq.go,cq.gx,cq.hk,cq.hn=5,"   1.0,4.0,1.0,.75,.25,0.5","......0000000000......1111111111","..5...............5............."return cq end function hv(g,fk) cq=hj(g,fk) cq.go,cq.fn,cq.fm,cq.gx,cq.hk,cq.hn=6,.24,2,"   1.0,4.0,1.0,0.5,1.7,.25","0000......11..1111......00..","4.....5..4..454.....5..4..45"return cq end function ex(g) if not ct or bg(ct.g,128)~=bg(g,128) then
return false end ct.fk,cr=false,120 music(-1) return true end function hw(g,h,eg) du={g=g,h=h,ed=0,dm=0,fs=0,bm=0,fo=2,de=1,eg=eg} function du:hx() self.bm+=1 self.fs=max(0,self.fs-1) local he,hf=false,false self.g+=self.ed if self.hy then
local dl,hz,ia=gc(self,1) if dl==1 then
self.g-=sgn(self.ed)*hz he=true end end self.h+=self.dm if self.hy then
local dl,hz,ia=gc(self,1) if dl==1 then
self.h-=sgn(self.dm)*ia hf=true end end return he,hf end function du:ea(cb) if self.ib==true then
sfx(12) return 2 end self.fs=14 self.de-=cb.fo sfx(4) if self.de<=0 then
self:gh() end return 1 end function du:gh() ef[self.eg].du=nil del(dv,self) ic(self) end function du:dy() return{self.g,self.h,8,8} end function du:id() if self.fs>0 and flr(self.fs)%4<3 then
pal(0,7) end end return du end function ie(g,h,eg) local ci=hw(g,h+1,eg) ci.de,ci.fo,ci.ig,ci.ib,ci.hy=2,2,0,true,true function ci:ds() self.ig=max(0,self.ig-1) local he,hf=self:hx() if self.ib and hf then
self.ed*=.7 if ct then
local ed,dm=ct.g-self.g,ct.h-self.h if ih(ed,dm)<32 and self.ig==0 then
self.ib,self.dm,self.ed=false,-1.75,min(.65,max(-.65,ed/40+ct.ed*.5)) sfx(1) end end else if hf then
if self.dm>0 then
self.ib=true self.ig=16 else self.h+=.1 self.dm=.05 end end self.dm=gj(self.dm) end end function ci:fc() self:id() if self.ib then
spr(217,self.g,self.h,1,1,sgn(self.ed)) else spr(218,self.g,self.h-8,1,2,sgn(self.ed)) end bf() end function ci:dy() if self.ib then
return{self.g,self.h,8,8} else return{self.g,self.h-8,8,16} end end return ci end function ii(g,h,eg) local du=hw(g,h,eg) du.de,du.hy,du.dq=10,true,ef[eg].r if du.dq==255 then
du.ij,du.ik,du.il=y(h,103),1,0 else du.ij,du.ik,du.il=y(g,103),0,1 end function du:ds() self.ij=max(0,self.ij-1) if self.ij==0 then
self.ed,self.dm=self.ik,self.il end local he,hf=self:hx() if he or hf then
self.ik*=-1 self.il*=-1 self.ed,self.dm,self.ij=0,0,104 sfx(12) end end function du:fc() self:id() spr(self.dq,self.g,self.h) bf() end return du end function im(g,h,eg) local du=hw(g,h,eg) du.de,du.ij,du.hy,du.dq,du.ed,du.dm,du.io,du.ip,du.iq,du.ir=3,y(g+h,59),true,ef[eg].r,0,0,false,false,0,0 if du.dq<196 then
du.dm,du.iq=.5,2 else du.ed,du.ir=.5,-2 end if du.dq==195 then
du.dq-=1 du.dm*=-1 du.iq*=-1 du.io=true end if du.dq==197 then
du.dq-=1 du.ed*=-1 du.ir*=-1 du.ip=true end function du:ds() self.ij=max(0,self.ij-1) if self.ij==0 then
gp(self.g+self.iq*2+2.5,self.h+self.ir*2+2.5,du.iq,du.ir) self.ij=60 end local he,hf=self:hx() if he or hf then
self.ed*=-1 self.dm*=-1 end end function du:fc() self:id() spr(self.dq+(self.ij/4)%2,self.g,self.h,1,1,self.io,self.ip) bf() end return du end function is(g,h,eg) local du=hw(g,h,eg) du.it,du.de=bg(g,128)*128+64,6 du.iu,du.iv=ih(g-du.it,h-64),atan2(g-du.it,h-64) function du:ds() self.g,self.h=cos(du.iv)*du.iu+du.it-4,sin(du.iv)*du.iu+60 du.iv+=.075/du.iu if self.bm%40==0 then
for bh=0,1,.25 do local iw=bh-self.bm/100 local g,h=cos(iw),sin(iw) gp(self.g+4+g*6,self.h+4+h*6,g,h) end end self:hx() end function du:fc() self:id() for bh=0,1,.25 do spr(251,self.g+cos(bh-self.bm/100)*4,self.h+sin(bh-self.bm/100)*4) end spr(250,self.g,self.h) bf() end return du end function ix(g,h,eg) local du=hw(g,h,eg) du.de,du.iy,du.h,du.dm=4,h,128,-1.5 function du:ds() if self.dm~=-1.5 then
self.dm=gj(self.dm) if self.h>256 then
self.h,self.dm=128,-1.5 end else sfx(15,-1,30) if self.h<=du.iy then
self.dm=-.995 for ed=-1,1,.66 do gp(self.g+3.5,self.h,ed,-1.5,.1) end end end self:hx() end function du:fc() if self.dm==-1.5 then
spr(235,self.g,self.h+8-(self.bm*.5)%3) end self:id() spr(252+(self.bm*.3)%3,self.g,self.h) bf() end return du end function iz(g,h,eg) local du=hw(g,h,eg) du.de,du.ja,du.ed,du.g=1,h,-1,cl+172 du.bm+=h if ef[eg].r==237 then
du.ed,du.g=1,cl-84 end du.g+=g%40 function du:ds() self.h=sin(self.bm*.0175)*15+du.ja self:hx() if(self.g<cl-32 and self.ed<0) or(self.g>cl+160 and self.ed>0) then
self:gh() end end function du:fc() spr(237+(self.bm*.2)%2,self.g,self.h,1,1,self.ed<0) end return du end function jb(g,h,eg) local du=hw(g,h,eg) du.ib,du.hy,du.ij,du.hi,du.fo=true,true,y(g/2,39),h,4 function du:ds() local he,hf=self:hx() if hf then
if self.dm>0 then
self.dm=-1 sfx(16) else du.ij,self.dm=40,0 end end if du.ij>0 then
du.ij-=1 if du.ij==0 then
self.dm=4 end end end function du:fc() sspr(104,64,8,8,self.g+4,self.hi,8,self.h-self.hi) spr(150,self.g,self.h,2,1) end function du:dy() return{self.g,self.h,16,8} end return du end function jc(g,h,dq,jd) if gk(g,h)~=0 then
return end local dz={g=bg(g,8)*8,h=h,dm=-1,dq=dq,ee=360,jd=jd} function dz:ds() self.h+=max(0,self.dm) if self.jd then
self.dm=gj(self.dm) local dl,hz,ia=gc(self,1) if dl==1 then
self.h-=ia self.dm=0 end self.ee-=1 if self.ee==0 then
del(el,self) return end end if ct and dx(self:dy(),ct:dy()) then
ct:ha(self.dq) del(el,self) return end end function dz:fc() if self.ee>140 or self.ee%10<5 then
spr(self.dq+(bm/12)%3,self.g,self.h) end end function dz:dy() return{self.g,self.h,8,8} end add(el,dz) return dz end ey={[1]=ho,[2]=hr,[3]=hs,[4]=ht,[5]=hu,[6]=hv,[217]=ie,[239]=ii,[255]=ii,[250]=is,[252]=ix,[237]=iz,[238]=iz,[194]=im,[195]=im,[196]=im,[197]=im,[150]=jb} je={[16]=jc,[19]=jc} function gy(g,h,jf,l,ee,ed,dm) local du={g=g,h=h,jf=jf,l={7,l},ee=ee,ed=ed,dm=dm} du.ed=ed or 0 du.dm=dm or 0 du.ee=ee or 0 function du:ds() self.g+=self.ed self.h+=self.dm if self.ee>0 then
self.ee-=1 if self.ee==0 then
del(ej,self) end else self.jf-=.25 if self.jf==0 then
del(ej,self) end end end function du:fc() local jf=self.jf if self.ee>0 then
jf=self.ee*.5 end circfill(self.g,self.h,self.jf+cos(jf/3)*2,self.l[flr(jf)%2+1]) end add(ej,du) return du end function ic(du) local jg,jh,ji,jj=jk(du:dy()) local g,h=hg(du) gy(g,h,max(ji/2,jj/2),8) if ct and rnd()>.67 then
local ci=16 if rnd()<.5 then ci+=3 end
if rnd()>.33 then ci+=6 end
jc(g,h,ci,true) end end function gp(g,h,ed,dm,jl,gn) bi={g=g-2.5,h=h-2.5,ed=ed,dm=dm,ee=128,fo=2,jl=jl or 0,dq=140} function bi:ds() self.dm=min(3.5,self.dm+self.jl) end function bi:fc() spr(self.dq,self.g,self.h) end function bi:dy() return{self.g+1,self.h+1,4,4} end if gn then
sfx(0) else sfx(6) end add(dr,bi) return bi end function gq(g,h,ed,dt) bi={g=g,h=h,ed=ed*.25,dm=0,eu=2,dt=dt,eb=true,ee=60,fo=.25,jm=0} if dt then bi.ee=44 end
function bi:ds() if self.ee==42 then
self.ed*=32 end if self.ee>16 and self.ee<44 then
self.jm-=self.ed end end function bi:fc() local g,h,jn,jo=self.g,self.h,self.g+self.jm,(self.ee/4)%2 line(g,h,jn,h,10) line(g,h-1,jn,h-1,8+jo) line(g,h+1,jn,h+1,9.99-jo) circfill(self.g+self.jm+rnd(3)-1,self.h,(self.ee-8)/8,7) end function bi:dy() return{min(self.g,self.g+self.jm),self.h-1,abs(self.jm),2} end sfx(14) add(dr,bi) return bi end function gr(g,h,ed,dt) bi={g=g,h=h,ed=0,dm=0,iv=0,eu=5,ee=180,fo=2,dt=dt,jp=nil,jq=32768} if ed<0 then bi.iv=.5 end
function bi:jr() local js,jt=32767,nil if self.dt then
for du in all(dv) do if dw(du) then
local ga=ih(hg(du),self.g,self.h) if ga<js then
js,jt=ga,du end end end else return ct,js end return jt,js end function bi:ds() local et,ga=self:jr() if ga<self.jq*.9 then
self.jp=et self.jq=ga end if et then
local ju,jv=hg(et) local jw,bh=1,atan2(ju-self.g,jv-self.h) if abs(bh-self.iv)>.5 then
jw=-1 end if self.iv<bh then
self.iv+=.01*jw else self.iv-=.01*jw end self.iv%=1 end self.ed,self.dm=cos(self.iv)*1.5,sin(self.iv)*1.5 end function bi:fc() local bh,n,m=((self.iv+.06)%1)*8,self.g-3.5,self.h-3.5 spr(134+(bm/4)%2,n-self.ed*3,m-self.dm*3) spr(7+bh%4,n,m,1,1,bh>2 and bh<6,bh>4) end function bi:dy() return{self.g-2,self.h-2,4,4} end function bi:ep() gy(self.g,self.h,4,10) end sfx(15) add(dr,bi) return bi end function gs(g,h,ed,dt) bi={g=g-8+ed*8,h=h-7,ed=0,dm=0,eu=6,dt=dt,eb=true,ee=20,fo=4,fk=ed<0} function bi:fc() spr(142,self.g,self.h,2,2,self.fk) if self.ee>=10 then
if self.ee<15 then
spr(156,self.g,self.h-8,2,1,self.fk) else spr(138,self.g,self.h-16,2,2,self.fk) end end end function bi:dy() return{self.g,self.h,16,16} end sfx(16) add(dr,bi) return bi end function gk(g,h) return fget(mget(bg(g,8),bg(h,8))) end function gc(cb,jx) local jg,jh,ji,jj=jk(cb:dy()) jj-=1 local dl,hz,ia=0,0,0 jx=jx or 255 for g=jg,jg+ji+7,8 do for h=jh,min(jh+jj+7,127),8 do local cc,gd=bg(g,8),bg(h,8) local ej,jy,gw=cc*8,gd*8,fget(mget(cc,gd)) if band(gw,jx)~=0 then
local jz,ka=min(jg+ji-ej,ej+8-jg),min(jh+jj-jy,jy+7-jh) if jz>0 and ka>0 then
dl=bor(dl,gw) hz,ia=jz,ka end end end end return dl,hz,ia end function dx(bh,bi,cb) cb=cb or 0 local kb,kc,kd,ke=jk(bh) local kf,df,kg,kh=jk(bi) local hz,ia=min(kb+kd-kf,kf+kg-kb),min(kc+ke-df,df+kh-kc) if hz>0+cb and ia>0+cb then
return hz,ia end return end function jk(jf) return jf[1],jf[2],jf[3],jf[4] end function hg(du) local jf=du:dy() return jf[1]+jf[3]/2,jf[2]+jf[4]/2 end function ih(g,h) return sqrt(g*g+h*h) end function gj(dm) return min(dm+.1,3.5) end function en(g,h) return mget(cf.g+bg(g,128),cf.h+bg(h,128))>0 end function cv(ki) cj() local g=cl+128 repeat g-=128 until not en(g-128,ki*128) for kj=0,7 do if not en(g+kj*128,ki*128) then
break end eo(bg(g,128)+kj,ki) end end function eo(kj,ki,hh,hi) if not hh then
hh,hi=kj*16,0 end local kk=mget(kj+cf.g,ki+cf.h) if kk==0 then return end
function kl(i) local jf={("0x"..sub(i,1,2))+0} for r=3,#i do jf[r-1]=("0x"..bb(i,r))+0 end return jf end for kf=0,15 do for df=0,15 do local km=0 if cg>0 then
km=cg+kf%2+(df%2)*16 end mset(kf+hh,df+hi,km) end end local r,kn,i=1,1,cf[kk] repeat if bb(i,r)=="."then
kn+=1 r+=1 else if kn==1 then
local ko=kl(bb(i,r,5)) local et,g,h,jg,jh=ko[1],ko[2],ko[3],ko[4],ko[5] for m=h,jh do for n=g,jg do local kp,kq=n+hh,m+hi mset(kp,kq,et) if et==76 then
add(ch,{g=kp,h=kq}) end end end r+=6 else ko=kl(bb(i,r,3)) local et,g,h=ko[1],ko[2],ko[3] if ey[et]~=nil then
add(ef,{r=et,g=g+hh,h=h,du=nil,eh=et==237 or et==238}) elseif je[et]~=nil then je[et]((g+hh)*8,(h+hi)*8,et) else mset(g+hh,h+hi,et) end r+=4 end end until r>=#i end
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
eeeeeeeeeee000eeee00000ee000000ee0e000eeee0000eee000000eeeeeeeeeeeeee00eeee00eeeeeeee00eeeeeeeeeeee00e0000eeeeeeeee00e0000eeeeee
eeeeeeeeee066d0ee099202000d666000a0ccc0ee033bb0e02449940e0000eeeeee00aa0ee0aa0eeeee00aa0e0000eeeee0dd066dd0eeeeeee0dd066660eeeee
ee7ee7eee0dd06d0022990900d6d67600aaaaca003333bb0024499400333300eee03b3a0ee0330eeee03b3a0077770eeee0d0d66ddd0eeeeee0d06dddd60eeee
eee77eee06ddddd0022290900d0d66600000aca00030000000000000e03bb3a0e03bbb0ee03bb30ee03bbb0e077770eeee0d0d66ddd0eeeeee0d0dddddd0eeee
eee77eee06d70d000000080000d000000cc70a0003008990024f0900e03bb3a00333b30ee03bb30e0333b30ee0000eeeee060d66dd6000eeee06066d70d0eeee
ee7ee7eee0d70f00e0229090e0dd60600cc70f00e0300000024499400333300ee00330eee033330ee00330eeeeeeeeeeee060ddddd60d0eeee06066d70f0000e
eeeeeeeeee0dfff0ee099090ee0dd0d0e0cffff0ee033330e0249940e0000eeeee030eeee030030eee030eeeeeeeeeeeeee060dddd00d0eeeee060dddff0ddd0
eeeeeeeeeee0000eeee0000eeee0000eee00000eeee0000eee00000eeeeeeeeeeee0eeeeee0ee0eeeee0eeeeeeeeeeeeeeee0600006660eeeeee060006666dd0
ee0000eeee6666eeee0000eee111111ee777777eecccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee066666600eeeeeee06666660000e
e077770ee600006ee066660e1e1cc1e17e7117e7cec77ceceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0d0ddddd0eeeeeee0d0ddddd0eeee
07700770600770060660066011ecce1177e11e77cce77eccee0000eeee7777eeee0000eeee1111eeee7777eeeecccceeeee0d66ddd60eeeeeee0d66ddd60eeee
0706607060700706060770601cc77cc1711cc117c771177ce007700ee770077ee007700ee1ecce1ee7e11e7eece77eceeee000000660eeeeeee000000660eeee
0706607060700706060770601cc77cc1711cc117c771177ce077770ee700007ee077770ee1c77c1ee71cc17eec7117ceeeeeeeee0660eeeeeeeeeeee0660eeee
07700770600770060660066011ecce1177e11e77cce77ecce077770ee700007ee077770ee1c77c1ee71cc17eec7117ceeeeeeeee0dd0eeeeeeeeeeee0dd0eeee
e077770ee600006ee066660e1e1cc1e17e7117e7cec77cece007700ee770077ee007700ee1ecce1ee7e11e7eece77eceeeeeeeee0dd0eeeeeeeeeeee0dd0eeee
ee0000eeee6666eeee0000eee111111ee777777eecccccceee0000eeee7777eeee0000eeee1111eeee7777eeeecccceeeeeeeeee0000eeeeeeeeeeee0000eeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0dd0eeeeeee0dd0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0dd0eeeeeee0dd0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeee00eee0d600000006d0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000e
ee066600000eeeeeeeeee00eeeeeeeeeeeee066000eeeeeeeee000eeeee0dd0eee06666666660eeeee0000000000000e0000000e0000000e0000000e6666ddd0
e06666666660eeeeeeee066000eeeeeeeee06666660eeeeeee0666000000dd0eeee066666660eeeee0d666666666ddd06666ddd06666ddd06666ddd066660dd0
e0d60666666d0eeeeee06606660eeeeeee06606666600eeee0d0666666660d0eeeee0666660eeeee0ddd666666660dd066660dd066660dd066660dd06600000e
e0dd0666660d0eeeeee060dd060eeeeeee0ddd06660dd0eee0dd0066666000eeeeee0dddd00eeeee0dd006666660000e0600000e6600000e6600000ed00eeeee
e0dd0dddd0dd0eeeee000ddd060eeeeeeee0dd0ddd0dd0eee0dd0000660eeeeeeeee066d66d0eeeee00e0666600eeeee060eeeeedd0eeeee660eeeee66d0eeee
ee00666d6600eeeeee0dd000dd0eeeeeeeee0066d6000eeeee00d06600eeeeeeeee066006dd0eeeeeeee0dddd660eeeedd0eeeeed60eeeee00eeeeee6dd0eeee
eee06600660eeeeeee0dd6dd6660eeeeeeee0d66060eeeeeeee0dd0660eeeeeeeee066d00ddd0eeeeee0666d66d0eeee6660eeee060eeeee60eeeeee0ddd0eee
ee0dd0e0dd0eeeeeee0d000006dd0eeeeeee0dd000eeeeeeeee0d00dd0eeeeeeeeee0dd0e0000eeeee0dd6000dd0eeee06dd0eee00eeeeeed0eeeeeee0000eee
ee0dd0e0ddd0eeeeee00eeeee0ddd0eeeeeee0dd0eeeeeeeeee00e0ddd0eeeeeeeee0dd0eeeeeeeeee0dd0ee0ddd0eeee0ddd0ee0eeeeeeedd0eeeeeeeeeeeee
ee0000e00000eeeeeeeeeeeee00000eeeeeee0000eeeeeeeeeeeee00000eeeeeeeeee00eeeeeeeeeee0000ee00000eeee00000ee0eeeeeee000eeeeeeeeeeeee
1111105050000500105501111111015555511111111155551111101110111111511015dd5511015d11111111060000d0776177611d66d5000d6767766d6dd500
1111105050010500105510111110011150001000001110550000100000100000511011111111015d12222221066666d076d176d1d6776d50d676777766d6dd50
00000050500005000011100111055011555511111115555500101001001010015110015d5110015d12788821065555d076d176d1d6776d50d676777766d6dd50
55555555555555555501055000155100550001000111055501101101011011015110015d5110015d12899821060000d071d171d1d6776d50d676777766d6dd50
05000000000500005510555555011015555551111155555500000001000000015110015d5110015d12899821060000d071d171d1d6776d50d676777766d6dd50
05000000000500001110555555500111555000101110555511101111111011115101015d5110105d12888821066666d076d176d1111111101111111111111110
05001111110500111001551115551011555555111555555500101000001010001011015d51101105122222c1065555d076d176d1d6776d50d676777766d6dd50
05001011010500000101115511511000000000011100000000001001001000010000015d5110000011111111060000d06dd16dd1111111101111111111111110
55001111110555555501111551111055111155555551111101111011101111015511015d511015dd1dddd1d1dddddddd1d1dddd1d6776d502f828ff882212820
05000000000500005550111111110555001110555000100000001001001000011111015d51101111d666616166666666161666ddd6776d502f828ff882212820
55555555555555551511001111100155111555555555111100101000001010005110015d5110015d67777171777777771717776dd6776d502f828ff882212820
00000050000005001110510000055011011105555500010011101111111011115110015d5110015d67777171777777771717776dd6776d502f828ff882212820
00000050000005001000105550155101115555555555511100000001000000015110015d5110015dd666616166666666161666ddd6776d502f828ff882212820
11111050011105000555055555011100111055555550001001101101011011015110105d5101015d5dddd1d1dddddddd1d1dddd5d6776d502f828ff882212820
1111105000000500501105115550005515555555555555110010100100101001511011051011015d055551515555555515155550d6776d502f828ff882212820
1000105555555500500001555511055511000000000000010000100000100000511000000000015d000000000000000000000000d6776d502f828ff882212820
2424242424944210fff917ff666d17916666666660d1116166666666d151151dfffffff9f94294205dddddddddddd500d6776ddd111111101111111111111110
4949494949a99420fff41fff666d1f410000000060dc116177777777d155551d99999949f9424420dd6666666666dd50d6776666d6776d50d666777766d6dd50
9a9a9a9a2494421044441444666d1441dddd000060dcc16166666666d111111d44444244f9429220d667777777766d50d6777777111111101111111111111110
4949494949a9942011111111666d11111cccc11160dccc61dddddddddd1111dd22222222f9429410d677777777776d50d6677777d6776d50d676777766d6dd50
494949492494421015515555dddd17ff11cccc11600ccc61dd1111dddddddddd94999999f9429420d677666666776d50dd666666d6776d50d676777766d6dd50
2424242449a994201111111111111fff111cccc16001cc61d111111ddddddddd44244444f9229420d6776dddd6776d505dddddddd6776d50d676777766d6dd50
121212122494421055551515766d14446666666660011c61d155551d5555555522212222f4429420d6776d55d6776d5005555555dd66dd50d676777766d6dd50
0000000049a9942011111111666d11111111111160011161d151151d111111110000000099429420d6776d50d6776d50000000001dddd5000dd6d66dddddd500
7777777166d16dd17fffff91ff91666d999999913b313b31d155551dd1666d1dffffff400999900077777777d6ee566dd6776d50111111111111111111111111
7d666d616dd16dd1ffffff41ff41666d94449991bab1bab1d111151dd16dd51dff4f44209999000066666666d6e56e6d66776d501dd667777777777777766dd1
766666616dd1ddd1444444414441666d94499941bab1bab1d155551dd16dd51df44424209990000965eeee56d656ee6d77776d50101155555555555555551101
766666616dd11511111111111111666d94999441bab1bab1d151111dd16dd51df424442099000099e65ee56ed66eee6d77766d501dd667777777777777766dd1
766666616dd166d1ff917fffff91dddd99994441bab1bab1d155551dd16dd51df444422090000999ee6556eed665ee6d6666dd50101155555555555555551101
7d666d616dd16dd1ff41ffffff41111199944491bab1bab1d111151dd16dd51df44242200000999955566555d6e65e6dddddd5501dd667777777777777766dd1
76666661ddd16dd1444144444441766d994449413b313b31d155551dd1d5551d422222200009999066666666d6ee656d55555500101155555555555555551101
1111111115116dd1111111111111666d1111111111111111d151111dd111111d000000000099990011111111d6eee66d00000000111111111111111111111111
eeee0e0e00eeeeeeeeeee0e0e00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeee1676d1eeeee00000000eeee
eee07070770e0eeeeeee07070770e0eeeeeeeeeeeeeeeeeeee8888eeeeeeeeeeaaaaaaeeeeeeeeeeeeeeeeeeeeeeeeee007700eee1676d1eeee0666777760eee
eeee0777766060eeeeeee077776606eeeeeeeeeeeeeeeeeee889988eeee88eeee7777777777e7eeeeeeeeeeeeeeeeeee077770eee1676d1eeee0556677650eee
eee0777699660eeeeeee0777699660eeeeeeeeeeeeeeeeeee89aa98eee8aa8eee7777777eeeeeeeeeeeeeeeeeeeeeeee077770eee1676d1eeee0000000000eee
eeee099999660eeeeeeee059559660eeeeeeeeeeeeeeeeeee89aa98eee8aa8eeeccccccccceeeeeee77eeeeeeeeeeeee007700eee1676d1eeee0224499420eee
eeee05f5596660eeeeeee00f079666eeeeeeeeeeeeeeeeeee889988eeee88eeecccccccccecceeeeeeee77eeeeeeeeeee0000eeee1676d1eeee0224499420eee
eeee005079960eeeeeeee00f079960eeeeeeeeeeeeeeeeeeee8888eeeeeeeeeee7777777eeeeeeeeeeeeee77eeeeeeeeeeeeeeeee1676d1e0000224499420eee
e0000ffff90000eeeeeee0ffff9000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaeaa7777eee77eeeeeeeeeeeeeeee1676d1e6776024499420eee
0ff70fff9066660eeeeee0f0f90660eeee0ee00eeeeeeeee0000000000000000eeaaaaaaaaaeeeeeee7777ee77eeeeeeeeeeeeee7eeeeeee5555024499420eee
e096600006666660eeee07000066660ee07007700eeeeeee02499fff99944220777777777eeeeeeeeeee777e77eeeeeeeeeeeeeee7eeeeee0000224499420eee
ee00007066660990eeee076f9060760eee0777776000eeee02499fff99944220cccccccccceeeeee777ee777777eeeeeeeeee7eeeeeeeeeeeee0224499420eee
eeee07707766000eeeeee0000760f90ee0777777066600ee02499fff99944220eaaaaaaaaaaaeeeeee777e77777eeeeeeeeeee7eee7eeeeeeee0224499420eee
eeee0777076660eeeeeee077076600ee077777760666660e02499fff999442207777777eeeeeeeeeeee777777777eeeeeee7ee77ee77eeeeeee0000000000eee
eeee0777066660eeeeee0777066660eee0777776606760400000000000000000ccccccccccecceeeeee777777777eeeeeee77e777e77eeeeeee0556677650eee
eee04422004220eeeee04422004220ee07776766600f904001d06707606d0110eccccceeeeeeeeeeeeee77777777eeeeeeee77777777eeeeeee0555555550eee
eee00000ee0000eeeee00000ee0000ee000000000000000ee00e00e00e00e00eeeeeeeeeeeeeeeeeeeee77777777eeeeeeee77777777eeeeeeee00000000eeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e00ee0eeeeeeeeeee00eeeeeee1111111111111111
eeee000000000eeeeeeee000000eeeeeee0e00000000e0eeeeee00000000eeeeee000000000000eeeee00707700700eeeeeee007700eeeee1661166622211111
eee00922200220eeeee00d6666d00eeee0a00cccccd1090eeee000b3bbb30eeee099fff99944420ee00777707777070eeee001d77d100eee1617871717778dd1
ee0099a22200220eee0dd677776dd0eee0a0cccccddd990eee01130b3baa30eee049ff994442220e070777777777770eeee01dd66dd10eee16171771777778d1
ee01099a22002a0ee0d6d677776d6d0ee0aaccccaaa9990ee0113330b3baa30ee049ff994442220e077777777777f770ee01ddd00ddd10ee16771717117771d1
e0110099a200290ee0d6d677776d6d0ee0aacccaaaa9990ee0113330b3baa30ee049ff994442220e0667f9777779f670ee01ddd66ddd10ee1111111111777111
e01120099900990ee0d6d677776d6d0ee0aacccaa999900ee00000000000000ee04999944222220ee06fff99779ff670e071ddd00ddd170e12dd77711d777111
e01122009900920ee000d666666d000eee0aaaa99000010ee01033000000700ee00000000000000ee09f555f9555f960e071000dd000170e12dd777117771111
e00000000088000ee0d0000000000d0eee00aa90054d110ee010330089aa780ee00000006444220e069f62044026f90ee06167000706160e12d7777777771111
ee0000000088000ee0dd00000000dd0eee070007079dd10ee010330089aa780ee007ff007442220e0669ffffffff960ee01170cff0c7110e12d7777777711181
ee0122219a00a20ee0dd67700776dd0eee00df90d79dd10ee00000000000600ee049ff994442220ee069f0f99f0f960eee01fff99fff10ee12d7771111111181
ee00121999009a0eee0d67700776d0eeee0fff99f99d10eeee0033300000000ee049ff9944422000ee009f0000f900eeee01df0000f110ee11777711111118d1
e00101449000090e000d66700766d000ee0f0000f9d100ee00000333333bb30e0049ff9944400222ee0609ffff9060eeee0019fffff100ee11777111dddd88d1
01111004000004006d00d660066d00d6e000ffff9d004400011110333333300e4049ff9940022222ee076099990670ee006d00999900d60011d11111dd888dd1
211111000000002266d00dd00dd00d660aa90000004444493311100000000bb0440000000222222200777600006777006666dd0000dd666611dd1118888dddd1
221111111111222266d0000000000d66aaaa944444444499333111111111bbbb4444222222222222770777660677707766666dddddd666661111111111111111
60676d06eeeeeeee000eeeee000eeeeeeee00eeeeee00eee11111111000000006666666670007000d0d0d0d0eeecceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
60676d06000000004990eeee0990eeeeee0920eeee0920ee10000011dddddddd6666666660706070d0d0d0d0eec77ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d0676d0d666666660aa90e0e4aa90e0eeee00eeeeee00eee10011001dddddddddddddddd60606060d0d0d0d0eec77ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
60676d06777707074990909009909090ee0920eeee0920ee10011001dddddddd66666666d060d060d0d0d0d0eec77ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d0600d0d666606060990202049902020e090020ee090020e1001100166666666ddddddddd0d0d0d0d060d060eec77ceeeeeeeeeeeeeeeeeeeeeeecccccceeeee
d0676d0ddddddddd42220e0e02220e0e09a9922009a9922010011001ddddddddddddddddd0d0d0d060606060eec77ceeeeeeeeeeeeeeeeeeeeeecc7777cceeee
d0600d0d000000000220eeee4220eeee09a9922009a992201001100166666666ddddddddd0d0d0d060706070eec77ceeeeeeeeecceeeeeeeeeeec777777ceeee
00676d00eeeeeeee000eeeee000eeeee0404040000404040111111116666666600000000d0d0d0d070007000eec77ceeeeeeeec77ceeeeeeeeeec777777ceeee
e000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eee0000eeee0000eeeec77ceeeeeeeec77ceeeeeeeeeec777777ceeee
00766d0000000000eeeeee77ee777eee77777eee777eee777eee77777eeeeeee00766d00e03bb30ee03bb30eeec77ceeeeeeec7777ceeeeeeeec7c7777c7ceee
071111d066666666eeeee7772e7772e7777772ee7777e2777ee77777777eeeee078888d003bbab3003bbab30eec77ceeeeecc777777cceeeeec77cccccc77cee
061712d070707777eeee7777277722777727772e77777227772777222777eeee068788d003bbab3003bbab30eec77ceeecc7777777777cceec77cc7777cc77ce
061112d060606666eee77777777722777227772e777777277722777222777eee068888d00000000000000000eec77ceec77777777777777cecccc777777cccce
0d1222d0ddddddddee76672766722767777766727667277667727667222767ee0d8888d003bbab30e00a0a0eeec77ceec77c77777777c77ceeec77cccc77ceee
00dddd0000000000e7dd7227dd727dd72227dd727dd7227ddd72277d777ddd7e00dddd0003bbab30ee0000eeeec77ceeecc7777777777cceeeeec7ceec7ceeee
e000000eeeeeeeee7777222777727777222777727777222777722227777777eee000000e00000000e056760eeeecceeeeeecccccccccceeeeeecccceecccceee
00676d00eeeeeeeee222222e222222222ee222222222e222222e222222222eeeeeeeeeee00000000ee0000eeee8aa8eeeeeeeeeeee0000eeee0000ee00eeee00
d0600d0deeeeee7777722277777222222e77777777777e2222ee7777722277777eeeeeee00000000e056760eee8aa8eeeeeeeeeee0aaaa0ee0aaaa0e06000060
d0676d0deeeee7777772e7777772eeeeee77777777777eeeeee2777777e2777777eeeeee00000000ee0000eeee8998eeeeeeeeee0aaa700e0aaa700ee07cc70e
d0600d0deeee7777777277777772eeeee7777777777777eeeee2777777722777777eeeeeeeeeeeeee056760eeee88eeeeeeeeeee0aaa7080000a7080e016610e
60676d06eee77777777777777772eeeee7777772777777eeeee27777777727777777eeeeeeeeeeee00000000eeeeeeeeeeeeeeee0aaaa80e0990a80ee016610e
d0676d0dee766667766667766672eeee776667727766677eeee276666667727666667eeeeeeeeeee03bbab30eeeeeeeeeeeeeeee0aa0988009999880e07cc70e
60676d06e7666672766676766672eeee766667727766667eeee2766666667777666667eeeeeeeeee03bbab30eeeeeeeeeeeeeeeee009990ee099990e06000060
60676d0677777772777727777772eee77777772e27777777eee27777777777777777777eeeeeeeee00000000eeeeeeeeeeeeeeeeee0000eeee0000ee00eeee00
eeeeeee7ddddd7227d7227dddd72eee7ddddd72e27ddddd7eee27dddddd777ddddddddd7eeeeeeeeee0000eeeeeeeeeee000000ee000000ee000000e00eeee00
eeeeee7dddddd72277227ddddd72ee7dddddd72e27dddddd7ee27dddddd7277ddddddddd7eeeeeeee0666d0eee0000ee0d676dd00d676dd00d676dd006000060
eeeee71111117222722271111172ee7111111777771111117ee27111111722777111111117eeeeee067006d0e006600ee000000ee000000ee000000ee071170e
eeee77777777722ee22777777772e777777777777777777777e277777777222277777777777eeeee060780d0e0676d0e0c0cc0c00cc0cc0000cc0cc0e0c66c0e
eee777777777222ee22777777772e777777772222277777777e2777777777222277777777777eeee060880d0e066dd0e0c0cc0c00cc0cc0000cc0cc0e0c66c0e
ee777777777722eeee77777777727777777772eee27777777772777777777e222227777777777eee0d600dd0e00dd00ee000000ee000000ee000000ee071170e
eee22222222222eeeee2222222222222222222eee2222222222222222222eeee222222222222eeeee0dddd0eee0000ee0d676dd00d676dd00d676dd006000060
eeee2222222222eeeee2222222222222222222eee2222222222222222222eeeee2222222222eeeeeee0000eeeeeeeeeee000000ee000000ee000000e00eeee00
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010201010101000000000000000000000101010101010101010101010101010101010101010101010101010101010100010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000010100000000000000000004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
12080b070b0a0c0801070c0a0c0801070d071008010a0d0a10080b010e0610080b0b0e10100801010f06100801080f091008010b0f1010110204020d0204040d0b0f080d0b10090d0c0f080e0c10090e12080110011010080b06040c04050c05050510080107050c05080107060810080b02090609080b0c090f0a050c010a01
100801030a061008010c0a0f0a060f050c060f0610060c060f080b010e0210080b090e0c100801010f02100801090f0c1011050c0504100b0406050c0109050f050b0510060b070f050f0710060f12080101010c01080110011010080101020110080c04050407070105060f06080c0d0a0d0c0701020b0c0b080c040f041007
0105100f10110d0506050d050a0a0d05090f12080101010110080c04011004080105011004050e07020905050e0b020d0507020703090507020b030d05070e07050905070e0b050d050801100510100701020c0f0c0801060c0b0c050d070c0a0c0701050f0f10080105100f101101030d0b0204060e02010b0e120801010101
1008010501100208011003101007040504060508040604060508010b050c09080c0c050c09070302080a09080102090a09080c050a060c0801060a060c07040b0c0c0d08040c0c0c0d0703050f0f10080105100f101110100f031010070410100a0510100a071010070b10100a0c10100a0d10100f0e12080101010110080105
011003080306020802050b0a020b0208030d020f020801100410100703020a050c0801050a050c08010c0a0f0c07030d0a0f0a0801020b040c080b020c040c0801060c0b0c050d070c0a0c080b0d0c0f0c0703050f0f10080105100f101101040c090204060e02010b0e12080101010110080105011001080108020808080110
021010070509040c04050c0a040a0b08010c040c0b0705020504050705050807080705020b0b0b0705050f0f10080105100f10110f0f07030f0e02070f0f0f0a0f0e050d12080101010110080105011001080105020904080c0602080308010c021004080c0d020f03060c0a030b030801100510100705020c0f0c0801060c0b
0c050d070c0a0c0705040f0f10080104100f101101050d0b0204060e02010b0e1208010101011008010401100108011002101007070506080907070b060d09080705070d090d0a09070a09080b02080d0907080508080907080b080d09080102090d090707040e06100707090e0c100807040f0c100d0a070f0810070804100f
10080b07100810080b0d100f10110e0a07050e0a0c050e0a050d0e0a0a0d12080101010110080104011004070704020f04080704030f04070809030a05070804040f04060e09040a05080110051010080b020c0f0c0801060c0b0c050d070c0a0c080b050f0f10080105100f10110708060307080d03060e0604060e0d04070e
0605060b0805080d0905070d0a05060d0b05070e0d0501060d0b0204060e02010b0e12080101010110050f05011001051006010a03080107010a01060c0d011001080110011010060f05020703080109020c020709020a0c0b0801020b0c0b0801020c02100709060f0f10080106100f101105100c01070c0f0106100602050f
0702070f0b0207100c02070d0f02070f05030710060306100803050f09030a070b030a070504070f070407100804060f090406100a040a070705070f090507100a050a0709060a07060c0a070a0c1208010101020c080106011003070907020e03060e08020903060e0c020d03070e08030903070e0c030d0308010f04101007
0a0206020b070a0f060f0b0709070a0a0c0801070b0a0c080a080b090b0709030c060c050d0b0c0e0c0801010d01100709050f0e10080105100e1011010709090204060e02010b0e12080101010110080105011001060e08020d03080109020c04060f0a020b0506100b020b050801050c06100801080c091008010c0c0d1008
010f0c1010080c060d0610080c080d081008010a0d0b10080c0d0d0d10080c0f0d0f10080b020e04100801020f041011050f0a0105100b01070d0803080d0d03070f0a0507100b050a070a06100d0709100d0e0912080101011001060e04020b04080105020b02080110021010060c0c030f030801060406050801010c0c0c08
0b040c0b0c0801010d031008010c0d0c10080b040f0b10080104100b1011070b0802060c0902070c0a02070b0503060c0603070c070308010903050f0a0305100b03050f04040510050408010904060f0a0406100b04060f040506100505050f070505100805070f0a0507100b05070f040607100506060f0706061008060a07
0a060a070407070f0707071008070a0707080d05060e12080101010c01080110011010080101020110080b05040f04080b02070d07080b050a0f0a080b020d0d0d080105100f10110801040408010d07100b04090801040a08010d0d12080101010110080105011001060e0602070408010702070508010a021002060c0c020f
0208010a030b04080110031010080108040905070f07050a05080b020d0f10050f020e0f100801040e0d10060c060f0c0f050b080f0a0f110b0f08020b100902070b0b020c0f08030c100903060e0b03070d0604080d0b040710080507100a0501020d0c0510030e05100f0e060f020f0610030f070b050f060d070f060b0a0f
070c0c0f060f0e0f06100f0f070f021007100310060b0410080d0510070d0c10060d0d10070f0e1007100f10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000d2d3d4d5d6d70000d80000d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000e1e2e3e4e5e6e7e800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102030405060000000000000000000000000000000000000000000102000000000000000000000000000000000000
00000000000000000000000000000000f0f1f2f3f4f5f6f7f8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090a0b00000000000000000000000000070000000000000000000000000000000000000000000003000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000d80000d800000000000000000000000000000000000000d0d1c1d000d0d1c1d000d0d1c1d00000000000000008000c00000000000000000000000000080000000000000000000000000000000000000000000004000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c7e00000e0c7e00000e0c7e00000e0c700000000000007000d00000000000000000000000000090a00000000000000000000000000000000000000000005000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c8c00000c0c8c00000c0c8c00000c0c800010203040506000000000000000000000000000000000b00000000000000000000000000000000000000000006000000000000000000000000000000000000
00464746767676767600000000000000000000000000000000000000000000000000000000000000000000000000000000d0d1c1d000d0d1c1d000d0d1c1d00000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000007000000000000000000000000000000000000
005657566767676767000000000000000000acad000000a0a1000000a2a300000000aaab000000a0a1000000a2a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000
004647464746474647000000000000000000bcbd000000b0b1000000b2b300000000babb000000b0b1000000b2b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000
00565756575657565700000000000000000000000000000000000000000000000000000000000000000000000000000000d0d1c1d000d0d1c1d000d0d1c1d0000001020300000000000000000000000000010203040506070800000000000000000000000000000000000000000a000000000000000000000000000000000000
004647466666666666000000000000000000000000000000000000000000000000000000000000000000000000000000c7e00000e0c7e00000e0c7e00000e0c700000004000000000000000000000000000000000000000009000000000000000000000708090a0000000000000b000000000000000000000000000000000000
005657567676767676000000000000000000000000000000000000000000000000000000000000000000000000000000c8c00000c0c8c00000c0c8c00000c0c80000000506070800000000000000000000000000000000000a000000000000000000000600000b0000000000000c000000000000000000000000000000000000
00464746767667677600000000000000000000000000000000000000000000000000000000000000000000000000000000d0d1c1d000d0d1c1d000d0d1c1d0000000000000000900000000000000000000000000000000000b000000000000000000000500000c0000000000000d0e0000000000000000000000000000000000
0056575676764b4b76000000000000000000a4a5000000a6a7000000a8a900000000a4a5000000a6a7000000a8a90000000000000000000000000000000000000000000000000a00000000000000000000000000000000000c0000000000000000000004000000000000000000000f0000000000000000000000000000000000
000000000000000000000000000000000000b4b5000000b6b7000000b8b900000000b4b5000000b6b7000000b8b90000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000001020300000000000000000000100000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001d251202512f2512c2513e2513d2511d0001d0001d0001d0001d0001d0001d00000201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201
0100000006470084600d4600f4501a450214402243000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000200002e6253c62500000000002e6153c6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000161105621086310c6410f65113661186611c66121661276612c66132661366613a6613c6613e6513e6513f6513f6513f6513d6413b641366412d64123631166310f6310a62107621036210261101611
0003000036650016501065023650306503f6503e4403e4303e420246300d43005430026200c40005400156000c20000200002000b2001720007200192001620000200002001d6000020000200002000020000200
00050000352732f2732127316273114730f4730e4730d473352532f2532125316253114530f4530e4530d453352332f2332123316233114330f4330e4330d433352132f2132121316213114130f4130e4130d413
000300002e4412b24126431232112e301153010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301
000300002265205652136522d6523b6523f252252522b64233242096323d2220f6120000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000400003023234232302323423230202342023420200202002020020200202002020020200202002020020200202002020020200202002020020200202002020020200202002020020200202002020020200202
000c00002c570255702e5002e5002e5002d5003f5013f501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
00060000231502e1503e150231402e1403e140231302e1303e130231202e1203e120231102e1103e1100010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000223601c360173601330013300213602c3603c3601a300263003c300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100000f2520a2523a2522c2523f2523f2423f2323f2223f2120020200202002020020200202002020020200202002020020200202002020020200202002020020200202002020020200202002020020200202
000a00001a77015770327703e77026700267003270032700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000700003406334063340633406334053340533405334053340433404334043340433403334033340233401334003000000000000000000000000000000000000000000000000000000000000000000000000000
000400001325307373016610c66124651366413c6413f6413f6313f6313f6313f6313f6313f6213f6213e6213e6213d6213b62139621376213662134611316112d61128611216111a611126110b6110661103610
00020000026211367110661066510964101621273733f2603f2403f2203f6033d2002b20035200392012220122201222012220122201222012220122201000010000100001000010000100001000010000100001
0008000018373233030630001305223001d3002930027300273002730227302010020100025305010000100524300010000100001000010000100001002223022230222302223022230522302223021036316665
010c00001525510205102551025517255102051025510255182551020510255102551a2551825517255182551525510205102551025517255102051025510255182551020510255102551a205182551725518255
010c000017255132051225512255192551720512255122551a2551b20512255122551c2551a255192551a25517255132051225512255192551720512255122551a2551b20512255122551c2551a255192551e255
010c00001c2451c245094551c24530645094551c2451c245094551c2451c24509455306451c245094551c2451c2451c245094551c24530645094551c2451c245094551c2451c24509455306451c245094551c245
010c00001e2451e2450b4551e245306450b4551e2451e2450b4551e2451e2450b455306451e2450b4551e2451e2451e2450b4551e245306450b4551e2451e2450b4551e2451e2450b455306451e2450b4551e245
000d00003c6253c625246052464524645102050c6550c6551860500655006550c1400c14505140051400514005145001400014000145111401114011142111321112211122111221112211112111121111211115
000d000029043290432400324043240431b1001d0431d04329100294402644028440294402910000100051002d100294402b4402d1002d4402d4402d4322d4322d4322d4222d4222d4222d4122d4122d4122d415
000d00001860518605054050c40515405114053b003186052460515435114351343518435186051860518605186051a4351c4351d4001d4301d4301d4321d4321d4321d4221d4221d4221d4121d4121d4121d415
0118000022430224252243022425224301d4302943027430274302743227422274122543025425244302442524400254002440022400224002240022402224022240222402224022240522402224022240222402
011800002443025430244302243022430224302243222432224222242222412224150040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
010c0000183430d2450d2350d235316250d2450d2350d2350c3430d2450d2350d235316250d245316250d24518343082450823508235316250824508235082351834308245082350823531625082453162508245
010c00001834305245082350a235316251824516235142351834305245082350a235316251824531625142451834305245082350a235316251824516225142451834305245082350a23531625182453162514245
010f00001723016230122300f2303c6253c6051723016230122300f2300f2320f2323c6253c6253c605082021723016230122300f2303c6253c6051723016230122300d2300d2320d2323c6253c6053c6253c625
010f00000c57314455084551445514455084550c5731445514455084551445514455084551445514455084550c57314455084551445514455084550c573144551445508455144551445508455144551445508455
010e00000c0430c0431b4451b2153c6151b4451b2150f4150c0430c04327445272153c61527445272151b4150c0431b4351d2351e4353c6151d235184350c0430c0431b4351d2351e4353c6151d2351843500445
010e000005445054453f51511425111150f4250c42511115034450344511115182451b245182451d2451111501445014452024511115111152024511115202450344520245224452324522445202361d4451b245
010e00000c0430c43511115184453c6151424511245054350c0430a4253f515134253c6151342518425054350c043111151b4253f5153c6151b4253f5151b4250c0231b4351d2351e4353c6151d2351843516235
010e00000144520245224452324522435202451d44503445034050344503445182451b445182451d445111150044520245224452324522445202361d4451b245014450144511115182451b445182451d44511115
010e00000c0431b4351d2351e4353c6151d235184350c04317200131153f515134253c6151342518425014350c0331b4351d2351e4353c6151d235184351623511115111153f515134253c615134251842500445
010e0000004450044520445111151d115204451d1152911501445014452c445111151d1152c4451d11529115034452c2452e4452f2452e4452c2452944503445044452c2452e4452f2452e4452c236294451b211
011200000d5450d5450d5450b155345241c1030d5450d5450d5450d5450b1550b1350d1450115534524011550454504545045451015534524101350454504545105450a5450a5450414504145041453452401145
0112000028435262352343521230345341f4302123621435172352353517734235352f7341753534734175350154526230234301f230214301f2302143221232014351f2302143022230214302b2361c4301a230
011200000c043012350123501235186250123519725012350c0430123519725186250123501235012350c0430c043042350423504235186250623510235072350c04307235186351862513235062350423518625
011200001a4351f2351c4351c2301c5341c4301c2361c435172352353517734235352f7341753534734175351a4351f2351c4351c2301c5341c430264352b23528435282302853428430214302b2361c4301a230
011200000c04307435134350743518625134351f725074350c0430723519725186350723517235072350c0430c0430a4350a4350a435186250a4350a235094350c04309235186350a43509235074350423502435
01100000013403f5150b340306150d340251001c1013f51504340235050b3400d3403061534514345103f515063403f5150b340306150d340191101c11121202073403f5150b3400d34030615345143f5153f515
011000000c0430d525171300d525191300d20501604065140c0430d52517130191200d5350d52525614014140c0430d525171300d525191300d5253f5150d5250c0430d525171301912013214255110d5250d525
011000000c0430d525171300d2351913027230284301e2321e4301c23020430202301f4312043220222202120c0430d525171300d23525230274312723225430252302343125230254302522225412252150d525
011000000c0430d525171300d2351913027230284301e2321e4301c23020430202301f4312043220222202120c0430d525171300d435202301f4301f2222a430292312a42028230254302522225412252150d525
01100000064403f5150b340306150d340063253f5150631507440073150b3400d34030615073153f50507325084403f5150b340306150d340083351c11108335094403f5150b3400d34030615093153f51509325
010d00000c0430444504245134353f6150444513235044450c0431343513235044453f6150444513235134350c0430444504245134353f6150444513235044450c0431343513235044453f615044451323513435
010d000028545234352d2252b5452a4352b2252f54532235395203724536530374253b2403953537420342453653034225325452f2302d5252b2402a4352b520284452623623520214451f23023525284202a235
010d00002b5452a4352822523545214351f2251e5451c4352b225235452a435232252d5452b4352a2252b545284352a225285452643523225215451f4351c2251a545174351e2251a5451c4351e2251f54523225
010d00000c0430044500245104353f6150044510235004450c0430043500235104453f6150044510235104350c0430044500245104353f6150044510235004450c0431043510235004453f615004451023500445
010d00000c0430244502245124353f6150244512235024450c0431243512235024453f6150244502245124350c0430244502245124353f6150244512235024450c0430243512235024453f615124450223512435
010d00002b5452a44528245235452b5352a43528535235352b5252a02528525235252b0252a02528725237252b0252a02528725237251f7251e7251c725177251f7151e7151c715177151371512715107150b715
010c00200c0430c235004303a324004453c3253c3240c043306250c0430044000440002353e5253e5250c0530c0430f244034451b32303445370243752237025306253e5250334003440032351b3230c0431b323
010c00200c04312235064303a324064453c3253c3240c043306250c0430644006440062353e5253e5250c0430c04311244054451b323054453a0242e5223a025306253e52503345054451323605436033451b323
010c00202202524225244202432422425243252432422325223252402522420242242222524425245252422522325222242442524326224252402424522220252452524524223252442522227244262432522325
010c0000224002b4202e42030420304203042033420304203042030222294202b2202e420302202b420272202a4202a4222a42227420274202742025421274212742027420274202722027422272222742227222
010c00002a4202a4222a422274202742027422272222742527400254202a2202e4202b2202a426252202a4202742027422274222442024222244222242124421244202442024420244202422024422182210c421
001c00000c05300155001552272400124001552272422725001550015522524001550a025160252e7242e5250c05300155001552272400124001552272422725001550015522524001550a025160252e7243a525
001c00000012407145071451b7243062507145277242772507145071452752407145306250c05327724275250012407145071451b7243062507145277242772507145071452752407145306250c0532772433525
01140000224001b400194001b4001b40016400194001b400224001b400194001b4001b400164001b4002240020400204022040220402204021d4002040021400214002140021400214022140221402214023c200
01140000224001b400194001b4001b40016400194001b400224001b400194001b4001b400164001b400224002040022200204001b200204001e400232001d4001d4001d4001d4001d4021d4021d4021d4023c200
011400001e4051e4051c4001d4051c4001b4001b4021b4051e4051e4051c4001d4051c4001b4001b4021b40519400194001940019400194021940216400194001a4001a4001a4001a4001a4021a4021a4021a402
000200001a2651a2651a2651a26501205012051a2651a2651a2651a2651c2051d2051c2051b2051b2051b20519205192051920519205192051920517205162051620516205162051620516205162051620516205
__music__
03 3a 3b 43 44
03 41 42 43 44
01 1b 19 43 44
02 1c 1a 43 44
03 1d 1e 43 44
01 12 14 43 44
00 12 14 43 44
00 13 15 43 44
02 13 15 43 44
04 16 17 18 44
01 2f 42 43 44
00 32 42 43 44
00 33 42 43 44
00 2f 42 43 44
00 2f 31 43 44
00 32 31 43 44
00 33 30 43 44
02 2f 34 43 44
00 41 42 43 44
00 41 42 43 44
00 2a 42 43 44
00 2a 42 43 44
01 2a 2b 43 44
00 2a 2b 43 44
00 2e 2b 43 44
00 2e 2b 43 44
00 2a 2c 43 44
00 2a 2d 43 44
00 2e 2c 43 44
02 2e 2d 43 44
00 20 42 43 44
00 20 42 43 44
01 20 21 43 44
00 20 21 43 44
00 20 21 43 44
00 20 21 43 44
00 22 23 43 44
00 22 23 43 44
02 24 1f 43 44
00 41 42 43 44
00 35 42 43 44
00 36 42 43 44
01 35 37 43 44
00 36 37 43 44
00 35 37 43 44
00 36 37 43 44
00 35 38 43 44
00 36 39 43 44
00 35 38 43 44
02 36 39 43 44
01 27 42 43 44
00 27 42 43 44
00 27 25 43 44
00 27 25 43 44
00 27 26 43 44
00 27 28 43 44
00 27 26 43 44
00 27 28 43 44
00 29 26 43 44
02 29 28 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
