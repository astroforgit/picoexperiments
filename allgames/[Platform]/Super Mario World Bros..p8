pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--original: super mario bros. (authentic)
--by @matthughson
--super mario world bros.
local a={}
b=mget
function mget(c,d)
c=flr(c)
d=flr(d)
if a[c] and a[c][d] then
return a[c][d].e
end
return 0
end
f=mset
function mset(c,d,g)
if not a[c] then
a[c]={}
end
if not a[c][d] then
a[c][d]={}
end
a[c][d].e=g
end
h=map
function map(i,j,k,l,m,n,o)
local p=peek(0x5f29)
p=bor(shl(p,8),peek(0x5f28))
local q=peek(0x5f2b)
q=bor(shl(q,8),peek(0x5f2a))
local r=flr(p/8)
local s=flr(q/8)
local t=r+16
local u=flr(q/8)+16
for v=r,t do
local w=a[i+v]
if w then
for x=s,u do
local y=w[j+x]
if y then
if y.e!=0 then
local z=k+(v*8)
local ba=l+(x*8)
local bb=false
if fget(y.e,7) then
bc()
bb=true
elseif y.bd!=nil then
be(bf[y.bd])
bb=true
end
spr(y.e,z,ba,1,1,y.bg,y.bh)
if(bb) bi()
end
end
end
end
end
end
bf=
{
{1,0,4,1,15,13},
{7,11,12,3},
}
bj={0,19,28}
bk={1,3,5,6}
bl=
{
{
map="07814724570063017701c97168f2e77397fb06835c01d722e70003a76c02b322e301e70747a05706a701d300d70107816720932203a31c6117216f33c763d862e961fa604fb387639c01b763c862d961ea6039f18721a701b72039f15f386dc1af26",
}
}
bm={
{
bn=446,
bo=30,
cls=12,
bj=1,
bp="ff00d2000101010201030e000101020201031b000101010201030e000101020201031b000101010201030e000101020201031b000101010201030e000101020201030e0001040c0001010102010311000101010201030800010501060107050001010302010304000105020601071000010101020103080001050106010705000101030201030400010502060107100001010102010308000105010601070500010103020103040001050206010710000101010201030800010501060107050001010302010304000105020601070e0001080100010101020103080001050106010705000101030208000105010601071000010503060107180001050106010710000105030601071800010501060107100001050306010718000105010601071000010503060107160001080100010501060107100001050306160001093900080a0300030a01090e0001090b00030a0400010a0209010a3800020b08000108d300030b08000108d200040b08000108d100050b08000108280001090300010a0109010a0109010a1500010c010d0900010c010d1200010a0109010a0e00010a0500020a0400010902000109020001090500010a0a00020a0600010b0200010b0a00020b0200010b0c00020a0109010a0c00060b080001081a00010e2300010c010d0600010f01100200010e0600010f01102700010e2500020b0200020b0400010e0300030b0200020b1a00070b0400010e0300010819000111011201130d00010e0a00010c010d0800010f01100600010f011001000111011201130500010f01100600010e1f000111011201130d00010e1500030b0200030b02000111011201130100040b0200030b0300010e0100010c010d0e00010c010d0100080b0300011101120113020001080a00010e0d0001110112011401150113060001010302010301110112011304000101010201030200010f01100800010f011001000101020201030100010f0110011101120114011501130400010f011001010302010301110112011304000101010201030f00010102020103030001110112011401150113060001010302010301110112011304000101010201030c00040b0202040b0111011201140115050b0200040b0103011101120113010f011002000101010201030900010f0110090b0200011101120114011501130100010b090001110112011304000101010201030500451602000f16030040160200891602000f160300401602004416",
bq="000000000000007b6c6d6b6b00007c0000007575008b00008c8d00007d000000767676766768777863636464696a797a818291928384939400008787a1a2a1a2a3a4a3a4008686a3a385a3a38600a386a3a3a3a385a3a3a361627172",
br="98c00598c00698c00798c00898c00998c00a98c00b98c00c98c00d98c00e98c00f98c01098c01198c01298c01398c0148050158650158c501592501598501598c0158060168660168c601692601698601698c0168070178230178670178830178c70178e301792701794301798701798c0179a30178080188240188680188840188c80188e40189440189880189a40188090198250198690198850198c90198e50199450199890199a5019",
bs="18b006650a00080c0a40080c0da00a940800109502a0129409c012940bc012990ca012970d60172d02c0180c0500180c0660180c0690180c0c20180c0c50180c0e40180c0e70180c0f80180c0fb0180c1000180c1030180c15c0180c15f0180c",
bt={
{116,18,2,4,0,0},
},
bd="0171882202f18422053186220771882208f184220b3186220d7188220ef184221141842214f184221af1842213e19112",
},
{
bn=34,
bo=30,
pal=1,
bj=2,
bp="01000301070004010102010301000301070004010102010301000301070004010102010301000e010102010301000e010102010301000401050405010102010301000e010102010301000301070404010102010301000e010102010301000301070404010102010301000301070504010102010301000301070002010106010701020103010003010700020101080109010201030d0a01080109010201030d0a0108010901020103",
bq="6464646400000000a4a3a4a3a2a1a2a1999aa9aa636364648182919283849394a1a2a1a2a3a4a3a461627172",
br="81e00081f00082000082100081e00181f00182000182100181e00281f00282000282100281e00381f00382000382100381e00481f00482000482100481e00581f00582000582100581e00681f00682000682100681e00781f00782000782100781e00881f00882000882100881e00981f00982000982100981e00a81f00a82000a82100a81e00b81f00b82000b82100b81e00c81f00c82000c82100c81e00d81f00d82000d82100d81e00e81f00e82000e82100e81e00f81f00f82000f82100f81e01081f01082001082101081e01181f01182001182101181e01281f01282001282101281e01381f01382001382101381e01481f01482001482101481e01581f01582001582101581e01681f01682001682101681e01781f01782001782101781e01881f01882001882101881e01981f01982001982101981e01a81f01a82001a82101a81e01b81f01b82001b82101b81e01c81f01c82001c82101c81e01d81f01d82001d82101d",
bs="",
bt={
{28,22,1,328,22,2},
},
},
{
bn=384,
bo=30,
pal=1,
bj=2,
bp="ff00810001010500840117000701010201031101030003013500020102000601020004010600040158000102010307010d0003013500020102000601020004010600040158000102010307010d00030128000404070002010800020103000101040002010a0006044e000102010307010d000301330002010800020103000101040002015e000102010307010d000301260001010100040101000101050002010800020103000101040002010a0006014e000102010307010d0003011c00010109000101010401010200010101040101050002010400040402010300010101040101020002010a000601370006010f00010501060102010307010d0003010900050708000108010001080d0003010200030105000401020006010300030102000201020004011d0001050106190002081c00010201030102010307010d0003011400010801000108010001080100010803000108160002012f00010501060400010201030b0002010b00030816000601010201030102010307010100010501060200010501060200010501060200030112000108010001080100010801000108010001080300010801000108140002012f0001020103040001020103040001050106050002010a000408160006010102010301020103070101000102010302000102010302000102010302000301100001080100010801000108010001080100010801000108030001080100010845000102010304000102010304000102010305000201090005081600060101020103010201030701010001020103020001020103020001020103020002015009030025090200020902000c09070008090700060901020103010201036609030025090200020902000c09070008090700060901020103010201031609",
bq="0000000064646464a1a2a1a2a3a4a3a4999aa9aa818291928384939467687778696a797a61627172",
br="",
bs="0b2004950920080c1350097305c00e9711700e7203a0109908a01094092010990980100c09b0100c1110100c12c01094014012940db012b010e0120c0cf014b00220160c0e7016b00580172d05b0172d0760172d1240172f0200180c03a0180c07c0180c0800180c0c60180c0c90180c0cc0180c0e20180c1350197311701a72",
bt={
{208,20,4,4,0,0},
{358,20,4,4,0,0},
{366,20,4,4,0,0},
{374,20,4,4,0,0},
{334,16,1,360,22,2},
},
},
{
bn=34,
bo=30,
pal=1,
bj=2,
bp="01000e010102010301000e0101020103010002010c0001020103010002010c0001020103010002010c0001020103010002010c000102010301000c0102000102010301000c010200010201030100030108040101020001020103010002010c000102010301000c0102000102010301000e01010201030100020109040301010201030d0501060107010201030d050108010901020103",
bq="6464646400000000a4a3a4a3a2a1a2a1999aa9aa616271728182919283849394a1a2a1a2a3a4a3a4",
br="81e00081f00082000082100081e00181f00182000182100181e00281f00282000282100281e00381f00382000382100381e00481f00482000482100481e00581f00582000582100581e00681f00682000682100681e00781f00782000782100781e00881f00882000882100881e00981f00982000982100981e00a81f00a82000a82100a81e00b81f00b82000b82100b81e00c81f00c82000c82100c81e00d81f00d82000d82100d81e00e81f00e82000e82100e81e00f81f00f82000f82100f81e01081f01082001082101081e01181f01182001182101181e01281f01282001282101281e01381f01382001382101381e01481f01482001482101481e01581f01582001582101581e01681f01682001682101681e01781f01782001782101781e01881f01882001882101881e01981f01982001982101981e01a81f01a82001a82101a81e01b81f01b82001b82101b81e01c81f01c82001c82101c81e01d81f01d82001d82101d",
bs="01801299",
bt={
{28,26,3,232,22,2},
},
},
{
bn=310,
bo=30,
cls=12,
bj=1,
bp="ff0049000101020201030f0002041b000101020201032c000101020201032200010505000101020201030b000106020701081d000101020201030b000106020701081d000101020201030b000106020701081d00010102020103010001090500010602070108140003040a00010a050b010c0400010602070108050004041d000204020002040106020701082c00010602070108010001091c00010a030b010c0a00050d0e00010a020b010c15000204210002041400020e080001091d00030d0800010101020103050d040002040900020d0d00010a040b010c04000101010201032d000101010201030500020e080001090b000101010201030f00030d0500010101020103010601070108050d0b000101010201030100020d0e00040d02000101010201030106010701080f00010a060b010c13000101010201030106010701080300040e08000109010101020100030f05000106010701080f00030d0500010a030b010c0100050d0b000106010701080100020d0e00040d02000106010701081300060d14000106010701080600040e080001090106010701000110011101121400010a060b010c0400030d0200050d0f00020d0700010a010b010c0400040d1800060d0500010a020b010c0200010a020b010c0c00060e080001090200010f0313010f1400060d0500030d0200050d0d0001140100020d0800010d0500040d1800060d0600020d0400020d0d00060e0800010902000211011502111400060d020001040200030d0200050d0101010201030c00020d0800010d04000101040d0d000101010201030100010a020b010c0300060d0600020d0400020d010201030b00060e01030700010902000211011602110d00010a020b010c0300060d0100010a010b010c0100030d0200050d0106010701080c00020d0800010d04000106040d0d000106010701080200020d0400060d020003040100020d0400020d010701080b00060e01080700010e020010170300020d0400060d0200010d0200030d0200050d0400010a020b010c0500010a030b010c0100010a030b010c0100010d0500040d1200020d0400060d0200010a010b010c0100020d0400020d04002a170300020d0400060d0200010d0200030d0200050d0500020d0700030d0300030d0200010d0500040d1200020d0400060d0300010d0200020d0400020d04001a17",
bq="000000000000007b6c6d6b6b00007c00999aa9aa00007575008b00008c8d00007d00000076767676b3b4c3c4b4b4c4c4b4b3c4c35d5d5d5d696a797ab5b5b7b7b7c6b7c6b7b7b7b7c6b7c6b7b6b6b7b767687778c5c5c6c6c6c6c6c661627172",
br="93000593000693000785d00893000885d00993000983d00a87f00a93000a83d00b87f00b93000b8a300c93000c8a300d93000d8df00e93000e8df00f93000f80301080501080701084f01093001084f01193001183f0128910128ef0128fb01293001283f0138910138ef0138fb0139300138010148030148050148070148090149300149300158050168cb0169300168cb01793001782b01884501882b01984501986b01a87f01a88b01a8e701a86b01b87f01b88b01b8e701b",
bs="0580060c05c0060c12f0066503c0072f0940079a0e40099a0a000a0c0dc00b2f06e00c750ff00c740a5010740b5012740760149410a0172f",
bt={
},
},
{
bn=320,
bo=30,
bj=3,
bp="ff0041009301010224010d002301080001010700010108000701130005010e000201030001030c0018010d002301080001040700010408000701130005010e00020103000103230001010d00230146000201030001032300010406000105060001040b0001040a000104060001044f0001030c000301900001030c0004018f0001030c0005011e0025010400010407000104070001042f0001060301030001030c000d0102000b010300010101040101030045010c000401030005010d070301030001030c000d01020009010108010103000301030045010c000401030005010d000301030001030c000d0102090b0103090301030945010c000401030005010d0903010300010a0c000d01020b0b01030b0301030b5d010d0b2001020b0b01030b0301030b5d010d0b1301",
bq="00000000e1e1f1f10000757576767676696a797a6768777800d3d300e2e2f2f2e1e1e1e1e3e3f3f3f1f1f1f1f3f3f3f3",
br="92600592600692600792600892600992600a92600b92600c92600d92600e92600f926010926011926012926013926014926015926016926017",
bs="125006650b10095f0d600a980dc00a980e200a9803c00c9410d00c7406300d6f07900d6f08700d6f0cb010b90fe010b91070109f0d4012980da012980e0012980e5012b90990136f0a90136f03d0156f",
bt={
},
},
}
bu=0
bv=1
bw=2
bx=3
function by(r,s,g)
if type(g)!="table"then
g={g,g+1,g+16,g+17}
end
local count=1
for x=0,1 do
for v=0,1 do
mset(r+v,s+x,g[count])
count+=1
end
end
end
function bz(ca)
for v=1,#ca.bs,8 do
local c=cb(ca.bs,v,2)
v+=3
local d=cb(ca.bs,v,2)
v+=3
local cc=cb(ca.bs,v,1)
local g=
{
[12]=cd,
[176]=ce,
[45]=cf,
[47]=cg,
[95]=ch,
[111]=ch,
[154]=ci,
[159]=cj,
[185]=ck,
[101]=cl,
[114]=cm,
[115]=cm,
[116]=cm,
[117]=cm,
[148]=cn,
[149]=cn,
[151]=cn,
[152]=cn,
[153]=cn,
}
if g[cc]!=nil then
local co=g[cc](c*8,d*8,cc)
if co then
co.c+=co:cp()
co.d+=co:cq()
co.cr=co.c
co.cs=co.d
end
end
end
local c=0
local d=0
for v=1,#ca.bp,4 do
local count=cb(ca.bp,v,1)
local bq=cb(ca.bp,v+2,1)
bq=(bq*8)+1
for x=0,count-1 do
local g={}
for ct=0,6,2 do
local cu=cb(ca.bq,bq+ct,1)
add(g,max(0,cu-1))
end
by(c,d,g)
if g[1]==102 and cv(c*8,d*8)==nil then
co=cn(c*8+8,d*8+8,152)
end
c+=2
if c>=ca.bn then
c=0
d+=2
end
end
end
for v=1,#ca.br,6 do
local cw=cb(ca.br,v,2)
local cx=cb(ca.br,v+3,2)
local c=band(cw,0x7ff)
local d=band(cx,0x7ff)
a[c][d].bg=band(cw,0x800)!=0
a[c][d].bh=band(cx,0x800)!=0
end
local bd=ca.bd
if bd then
for v=1,#bd,8 do
local cy=cb(bd,v,2)
local cz=cb(bd,v+3,1)
local da=cb(bd,v+5,0)
local db=cb(bd,v+6,0)
local dc=cb(bd,v+7,0)
for d=cz,cz+db-1 do
for c=cy,cy+da-1 do
a[c][d].bd=dc
end
end
end
end
for dd in all(ca.bt) do
local de=0
if dd[6]==1 then
de=1
elseif dd[6]==2 then
de=-1
end
df(dd,de)
end
end
function cb(dg,v,dh)
return tonum("0x"..sub(dg,v,v+dh))
end
function di(dj,dk)
local dl,dm,dn,dp=dj:dq()
local dr,ds,dt,du=dk:dq()
return dv(
dl,dm,dn,dp,
dr,ds,dt,du)
end
function dw(dj,dx,dy,dz,ea)
local dl,dm,dn,dp=dj:dq()
return dv(dl,dm,dn,dp,dx,dy,dz,ea)
end
function eb(cy,cz,dk)
local dr,ds,dt,du=dk:dq()
return ec(cy,cz,dr,ds,dt,du)
end
function ec(cy,cz,c,d,bn,bo)
if flr(cy)>=flr(c-(bn)) and flr(cy)<flr(c+(bn)) and
flr(cz)>=flr(d-(bo)) and flr(cz)<flr(d+(bo)) then
return true
else
return false
end
end
function dv(
dx,dy,
dz,ea,
ed,ee,
ef,eg)
local eh=dx-ed
local ei=dz+ef
if(abs(eh)>=ei) return false
local ej=dy-ee
local ek=ea+eg
if(abs(ej)>=ek) return false
return true
end
function el(self)
local em,en,eo,ep=self:dq()
local eq=eo
local er=0
if self.z<0 then
eq*=-1
er=8
elseif self.z==0 then
return
end
local c=(em+eq)/8
for es=-(ep)+1,(ep)-1,2 do
local d=(en+es)/8
if fget(mget(c,d),0) then
if self.et!=nil then
self:et()
else
self.z=0
self.c=(flr((c))*8)+er-eq
end
return true
elseif self.eu==-1 and self.ev and self.ew then
for dd in all(bs) do
if dd!=self and dd.ev and dd.ew and dd.ex then
if eb(c*8,d*8,dd) then
self.z*=-1
return true
end
end
end
end
end
return false
end
function ey(self)
if self.ba<0 then
return false
end
local em,en,eo,ep=self:dq()
local d=(en+ep)/8
for v=-(eo)+2,(eo)-2,2 do
local ez=nil
if fget(mget((em+v)/8,d),0) then
ez=(flr(d)*8)-(self:cq())
else
for dd in all(bs) do
if self==fa and dd.fb then
if di(self,dd) then
ez=(flr(dd.d-dd:cq()))-(self:cq())+1
break
end
end
end
end
if ez then
if self.fc!=nil then
self:fc(ez)
else
self.ba=0
self.d=ez
self.fd=true
self.fe=0
end
return true
end
end
if self.ff then
self.z*=-1
self.c+=self.z
end
return false
end
function fg(self)
if self.ba>=0 then
return
end
fh={}
local d=flr((self.d-(self:cq()))/8)
for v=-(self:cp())+2,(self:cp())-2,2 do
local c=flr((self.c+v)/8)
fi=nil
if self==fa then
fi=cv(c*8,d*8)
end
local fj=mget(c,d)
if fget(fj,0) or fi!=nil then
add(fh,{fj,c,d,fi})
end
end
if#fh>0 then
self.ba=0
self.d=flr(d)*8+8+(self:cq())
self.fk=0
local fi=fh[flr(#fh/2)+1]
if self==fa then
if fi[4]!=nil then
fi[4]:fl(self)
else
fj=fi[1]
c=fi[2]
d=fi[3]
if(fget(fj,1)) fm(c,d,104)
if(fget(fj,2)) then
if fa.fn then
fm(c,d,0)
else
fm(c,d)
end
end
end
end
else
return nil
end
end
function fo(c,d)
local dd=
{
c=c,
d=d,
fp=function(self)
return sqrt(self.c^2+self.d^2)
end,
fq=function(self)
local dh=self:fp()
return fo(self.c/dh,self.d/dh),dh;
end,
}
return dd
end
function fr(c,d)
function fs(dj)
return(dj%2==0) and dj or dj-1
end
return fs(c),fs(d)
end
function cv(c,d)
for dd in all(bs) do
if dd.ft==true and eb(c,d,dd) then
return dd
end
end
return nil
end
function fm(c,d,e)
local r,s=fr(c,d)
for dd in all(bs) do
if dd.fu!=nil and dw(dd,r*8+8,s*8+8-16,8,8) then
dd:fu({c=r*8+8,d=s*8+8})
end
end
if fget(mget(r,s-1),7) then
local fv,fw=fr(flr(r),flr(s-1))
by(fv,fw,{0,0,0,0})
fa:fx()
fy(fv*8+8,fw*8+8)
end
if e==0 then
for v=0,1 do
for x=0,1 do
fz(
(r+v)*8+4,
(s+x)*8+4,
-1+(v*2),((1-x+1)*-3),mget(r+v,s+x))
end
end
by(r,s,{0,0,0,0})
sfx(55)
return
end
if e==nil then
e={}
for d=0,1 do
for c=0,1 do
add(e,mget(r+c,s+d))
end
end
end
ga(r*8+8,s*8+8,e)
sfx(52)
by(r,s,{127,127,127,127})
end
function gb(dg,gc,
gd,ge,
gf)
for d=-1,1 do
for c=-1,1 do
print(dg,gc+c,gd+d,gf)
end
end
print(dg,gc,gd,ge)
end
function gg(
dg,c,d,
ge,gf,
gh)
local gi=(#dg*4)+(gh*3)
local gc=c-(gi/2)
local gd=d-2
gb(dg,gc,gd,ge,gf)
end
function gj(c,d)
local co=
{
c=c,
d=d,
z=0,
ba=0,
bn=16,
bo=16,
gk=0,
cp=function(self)
return self.bn*0.5
end,
cq=function(self)
return self.bo*0.5
end,
dq=function(self)
if self.gl and self.gm then
return
self.c,
self.d+self:cq()-self.gl/2,
self.gm/2,self.gl/2
else
return self.c,self.d,self.bn/2,self.bo/2
end
end,
gn=1,
go=9999,
gp=9999,
gq=0,
bg=false,
bh=false,
ev=true,
gr=false,
o=1,
gs=
{
["idle"]=
{
gt={26},
},
},
gu="idle",
gv=1,
gw=0,
gx=function(self,gy)
if(gy==self.gu) return
self.gw=self.gs[gy].gz or 0
self.gu=gy
self.gv=1
end,
ha=function(self)
self.gw-=1
if self.gw<=0 then
self.gv+=1
local dj=self.gs[self.gu]
self.gw=dj.gz or 0
if self.gv>#dj.gt then
if self.hb!=nil then
self:hb()
end
self.gv=1
end
end
end,
hc=function(self)
self.gk+=1
self.z=mid(-self.go,self.z,self.go)
self.c+=self.z
if self.ev then
local hd=self.z
if el(self) then
self.z=-hd
end
end
self.ba+=self.gq
self.ba=mid(-self.gp,self.ba,self.gp)
self.d+=self.ba
if self.he!=nil then
local hf=self.gk/60
if self.he.hg==true then
self.c=self.cr+((sin(hf/self.he.hh)+1)*0.5)*self.he.hi
else
self.d=self.cs+((sin(hf/self.he.hh)+1)*0.5)*self.he.hi
end
end
if self.ev then
ey(self)
fg(self)
end
self:ha()
end,
hj=function(self)
local dj=self.gs[self.gu]
local hk=dj.gt[self.gv]
if(self.pal) be(self.pal)
if type(hk)=="table"then
local r=self.c-(self:cp())
local s=self.d-(self:cq())
local count=1
local hl=flr(self.bo/8)
local hm=flr(self.bn/8)
local hn=8
local ho=8
if self.bg then
r=r+((hm-1)*8)
hn=-8
end
if self.bh then
s=s+((hl-1)*8)
ho=-8
end
local d=s
for hp=1,hl do
local c=r
for hq=1,hm do
local hr=hk[count]
local bg=self.bg
local bh=self.bh
if hr!=nil and hr!=0 then
if hr<0 then
hr=abs(hr)
bg=not bg
end
if hr>=256 then
hr-=256
bh=not bh
end
sspr((hr*8)%128,flr((hr/16))*8,8,8,
c,d,8,8,
bg,bh)
end
count+=1
c+=hn
end
d+=ho
end
else
local bg=self.bg
local bh=self.bh
if hk<0 then
bg=not bg
hk=abs(hk)
end
if hk>=256 then
hk-=256
bh=true
end
sspr((hk*8)%128,flr((hk/16))*8,self.bn,self.bo,
self.c-(self:cp()),self.d+(self:cq())-(self.bo/self.gn),
self.bn,self.bo/self.gn,bg,bh)
end
if(self.pal) bi()
end,
hs=function(self,g)
for ct,dd in pairs(g) do
self[ct]=dd
end
return self
end,
}
add(ht,co)
return co
end
function hu(c,d)
local hv=gj(c,d):hs(
{
go=2,
gp=4,
hw=9999,
hx=9999,
hy=-4,
hz=0.1,
ia=0.8,
ib=1,
gq=0.3,
ic=id(5),
ie=id(4),
fk=0,
ig=5,
ih=20,
fd=false,
fe=0,
gs=
{
["idle"]=
{
gt={10},
},
["run"]=
{
gz=2,
gt={6,4,2},
},
["jump"]=
{
gt={0},
},
["slide"]=
{
gt={8},
},
["dead"]=
{
gt={93},
},
["fire"]=
{
gz=15,
gt={
ii("06075d5e6d6e3637")
},
},
},
ij=3,
ik=0,
il=0,
fn=false,
im=false,
io=function(self,ip)
for ct,dd in pairs(self.gs) do
for iq,ir in pairs(dd.gt) do
if type(ir)=="table"then
for is,it in pairs(ir) do
self.gs[ct].gt[iq][is]+=ip
end
else
self.gs[ct].gt[iq]+=ip
end
end
end
end,
iu=function(self)
if self.fn==false then
self:io(32)
self.bo=32
self.d-=8
self.fn=true
self.iv=60
elseif self.im==false then
self.im=true
self.iv=60
end
sfx(58)
end,
iw=function(self,ix)
if self.fn==true then
self:io(-32)
self.bo=16
self.d+=8
self.fn=false
self.im=false
if not ix then
self.iv=60
sfx(56)
end
end
end,
iy=function(self)
self.iz=0
self:iw(true)
self:ja(nil)
end,
ja=function(self,jb)
if self.iz<=0 then
if self.fn then
self:iw()
self.iz=120
else
self.jc=true
self.z=0
self.ba=-10
self.bh=false
self.fd=false
self.cz=self.d
self.eu=0
self.bn=16
self.jd=0
self:gx("dead")
music(24)
end
end
end,
je=function(self,cy,cz)
self.c=cy
self.d=cz-self:cq()
self.z=0
self.ba=0
self.iz=0
self.iv=0
self.jf=0
self.jg=0
self.jh=nil
self.jc=false
self.ji=false
self.jd=0
self:gx("idle")
end,
jj=function(self)
self.z=0
self.ba=0
self.ji=true
self.il=0
music(-1)
end,
jk=function(self)
self.jd=900
music(23)
end,
fx=function(self)
self.ik+=1
if self.ik>=100 then
self.ij+=1
self.ik=self.ik%100
sfx(59)
else
sfx(61)
end
end,
})
hv:je(0,0)
hv.jl=hv.hc
hv.hc=function(self)
if self.jd>0 then
self.jd-=1
if self.jd==0 then
music(bj[bm[jm].bj])
end
end
self.iz=max(0,self.iz-1)
if self.jc then
self.eu+=1
if self.eu<30 then
return
end
local gi=120
local jn=(self.eu-30)/gi
if jn>0.5 then
self.d+=self.ba
if(self.d>jo.jp.d+256) and self.eu>200 then
self.ij-=1
if self.ij<=0 then
jq(bx)
else
jq(bv)
end
end
return
end
jr=(sin(jn)*80)+self.cz
if(jn>=0.5) then
self.ba=jr-self.d
end
self.d=jr
return
end
if self.jh!=nil then
self.jf-=1
if self.jf==0 then
self.jh:js()
self.jh=nil
self.jg=0
else
self.d+=1*self.jg
end
return
end
if self.ji then
if self.il==60 then
music(30)
end
self.il+=1
if self.il>60 then
self.d+=1
if ey(self) then
if(self.il>400) then
jt+=1
if jt>#bk then
stop("to be continued...",32,64,7)
end
jm=bk[jt]
jq(bv)
end
elseif gz%4==0 then
fa:fx()
fy(self.c+rnd(16)-8,self.d-rnd(8))
end
end
return
end
if(self.d>jo.jp.d+64) then
self:iy()
end
if self.iv>0 then
self.iv-=1
return
end
local ju=btn(0) and not self.jc
local jv=btn(1) and not self.jc
if ju==true then
self.z-=self.hz
jv=false
elseif jv==true then
self.z+=self.hz
else
if self.fd then
self.z*=self.ia
else
self.z*=self.ib
end
end
local jw=self.go*0.5
if btn(4) then
self.hw=0
else
self.hw=min(999,self.hw+1)
end
if self.hw<15 then
jw=self.go
end
self.z=mid(-jw,self.z,jw)
self.c+=self.z
el(self)
local jx,jy=jo:jz()
if self.c-self:cp()<jx then
self.z=0
self.c=jx+self:cp()
elseif self.c+self:cp()>jx+128 then
self.z=0
self.c=jx+128-self:cp()
end
self.ic:hc()
if self.ic.ka and not self.jc then
local kb=(self.fd or self.fe<5)
local kc=self.ic.kd<10
if self.fk>0 or(kb and kc) then
if(self.fk==0) sfx(63)
self.fk+=1
if self.fk<self.ih then
self.ba=self.hy
end
end
else
self.fk=0
end
self.ba+=self.gq
self.ba=mid(-self.gp,self.ba,self.gp)
self.d+=self.ba
if not self.jc and not ey(self) then
self:gx("jump")
self.fd=false
self.fe+=1
end
if self.fd==true and btn(3) then
for dd in all(bs) do
if dd.ke!=nil then
if eb(self.c,self.d,dd) then
self.jh=dd
self.jf=60
self.jg=1
sfx(56)
music(-1)
return
end
end
end
end
for x=-1,1 do
for v=-1,1 do
local c=(self.c-(v*self:cp()))/8
local d=(self.d-(x*self:cq()))/8
if fget(mget(c,d),3) then
local r,s=fr(flr(c),flr(d))
by(r,s,{0,0,0,0})
self:fx()
end
end
end
if(not self.jc) fg(self)
if self.hx<5 then
self:gx("fire")
elseif self.fd then
if(jv and self.z<0) or(ju and self.z>0) then
self:gx("slide")
elseif ju or jv then
self:gx("run")
self.gs["run"].gz=((self.go-abs(self.z))+1)*3
else
self:gx("idle")
end
end
if self.fd then
if(jv) self.bg=false
if(ju) self.bg=true
end
self.ie:hc()
if self.ie.kf and self.im and#kg<2 then
local de=1
if(self.bg) de=-1
kh(self.c,self.d,de)
self:gx("fire")
self.hx=0
else
self.hx=min(9999,self.hx+1)
end
self:ha()
end
hv.ki=hv.hj
hv.hj=function(self)
if self.iz%2==0 then
if self.jd>0 then
local kj={{9,7,5,9},{8,1,5,4,9,15},{8,3,5,9,9,7}}
local kk=self.jd<120 and 8 or 2
local v=(flr(gz/kk)%4)
self.pal=kj[v]
elseif self.im then
self.pal={8,15,5,8}
else
self.pal=nil
end
self.gn=1
if self.iv%20>10 then
if self.fn then
self.gn=2
else
self.gn=0.5
end
end
self:ki()
end
end
return hv
end
function kl(c,d)
local co=gj(c,d)
co.ev=false
co.hb=function(self)
del(bs,self)
end
return co
end
function km(c,d)
local co=kl(c,d)
co.gs=
{
["idle"]=
{
gz=5,
gt={
ii("0087ff790187fe79",4),
ii("0088ff780188fe78",4),
ii("0089ff770189fe77",4)
}
}
}
end
function fy(c,d)
kl(c,d):hs(
{
bn=8,
ba=-6,
gq=0.3,
}).gs["idle"]=
{
gz=5,
gt={
{252,508},
{253,509},
{254,510},
{255,511},
{252,508},
{253,509},
{254,510},
{255,511},
}
}
end
function kh(c,d,kn)
sfx(53)
local ko=2
local co=gj(c,d):hs(
{
bn=8,
bo=8,
gq=0.2,
z=kn*ko*2,
ba=ko,
fc=function(self,d)
self.ba=-ko
self.d=d
end,
et=function(self)
km(self.c,self.d)
del(kg,self)
end,
kp=function(self)
for dd in all(bs) do
if dd.ex and dd.eu==-1 and not dd.kq and di(self,dd) then
self:et()
dd:fu(self)
break
end
end
end,
})
co.gs["idle"]=
{
gz=5,
gt=ii("005f006ffea1fe91",4)
}
co.kr=co.hc
co.hc=function(self)
self:kr()
self:kp()
local jx,jy=jo:jz()
if self.c+self.bn<jx or self.c-self.bn>jx+128 or self.d-self.bo>jy+128 then
del(kg,self)
end
end
del(ht,co)
add(kg,co)
end
function df(dd,ks)
gj(dd[1]*8,dd[2]*8):hs({
bn=10,
bo=32,
ke=dd[3],
kt=dd[4]*8,
ku=dd[5]*8,
ks=ks,
hj=function() end,
js=function(self)
kv(self.kt,self.ku,self.ke,self.ks)
end
})
end
function cm(c,d,g)
local co=gj(c,d):hs({
bn=48,
bo=8,
fb=true,
})
co.gs["idle"].gt={
ii("727272727272")
}
co.kw=co.hc
if g==114 then co.ba=0.5 end
if g==115 then co.ba=-0.5 end
if g==116 then co.he={hh=5,hi=56,hg=true} end
if g==117 then co.he={hh=10,hi=112,hg=false} end
co.hc=function(self)
local kx=di(self,fa)
local ky=self.c
local kz=self.d
self:kw()
if kx then
fa.c+=self.c-ky
fa.d+=self.d-kz
end
if self.he==nil then
self.d=(self.d+(jo.jp.d+64))%(jo.jp.d+64)
end
end
co.la=co.hj
co.hj=function(self)
local kz=self.d
local ky=self.c
lb(self)
self:la()
self.c=ky
self.d=kz
end
return co
end
function cn(c,d,g)
local co=gj(c,d)
co.g=g
co.lc=-1
co.ft=true
co.fl=function(self)
if self.g==148 or self.g==149 then
local co=ld(self.c,self.d)
if self.g==149 then
co.pal={4,3}
co.le=true
elseif fa.fn then
co.lf=true
co.gs["idle"]=
{
gt={
ii("0096ff6a00a6ff5a",4)
},
}
co.z=0
end
elseif self.g==151 then
lg(self.c,self.d)
elseif self.g==152 or self.g==153 then
fy(self.c,self.d)
fa:fx()
if self.lc==-1 then
self.lc=60*4
end
end
local c,d=fr(self.c/8,self.d/8)
if self.g!=153 or self.lc<=0 then
fm(c,d,104)
del(bs,self)
else
fm(c,d)
end
end
co.hc=function(self)
if self.lc>0 then
self.lc-=1
end
end
co.hj=function(self) end
return co
end
function lh(c,d)
local co=gj(c,d)
co.ev=false
co.lf=false
co.pal={}
co.fu=function(self,li)
self.z=sgn(self.c-li.c)*abs(self.z)
self.ba=-2
end
co.lj=co.hc
co.hc=function(self)
if di(self,fa) then
if self.lk then
self:lk()
end
del(bs,self)
end
if self.gk==32 then
self.o=1
self.ev=true
elseif self.gk<32 then
self.d-=0.5
self.gk+=1
return
end
self:lj()
end
co.ll=co.hj
co.hj=function(self)
if self.lf then
local kj={{7,15,9,4,4,2},{7,9,9,3},{4,3}}
local v=(flr(gz/2)%4)
self.pal=kj[v]
end
self:ll()
end
co.o=0
return co
end
function lm(g)
pal()
if g then
for v=1,#g,2 do
pal(g[v],g[v+1])
end
end
end
function be(ln)
add(lo,ln)
lm(ln)
end
function bi()
del(lo,lo[#lo])
lm(lo[#lo])
end
function bc()
local kj={{9,4},{},{9,10},{}}
local v=(flr(gz/10)%4)+1
if kj[v]!=nil then
be(kj[v])
end
end
function ld(c,d)
sfx(57)
local co=lh(c,d):hs({
z=0.75,
gq=0.1
})
co.gs["idle"]=
{
gt={148},
}
co.lk=function(self)
if co.le then
fa.ij+=1
sfx(59)
else
fa:iu()
end
del(bs,self)
end
return co
end
function lg(c,d)
sfx(57)
local co=lh(c,d):hs(
{
z=0.75,
ba=-3,
gq=0.1,
lf=true,
fc=function(self,ez)
self.ba=-3
self.d=ez
end,
lk=function(self)
fa:jk(self)
end,
})
co.gs["idle"]=
{
gt={
ii("0097ff6900a7ff59",4)
}
}
end
function ga(c,d,lp)
local co=gj(c,d)
co.g=0
co.cz=d
co.lq=lp
co.gs["idle"].gt={lp}
if bm[jm].pal!=nil then
co.pal=bf[bm[jm].pal]
end
co.hc=function(self)
self.g+=1
local jn=self.g/30
jr=(sin(self.g/30)*4)+self.cz
self.d=jr
if(self.d>=self.cz) then
del(bs,self)
by((self.c-8)/8,(self.cz-8)/8,self.lq)
end
end
end
function lr(c,d)
local co=gj(c,d):hs({
z=-0.5,
gq=0.1,
eu=-1,
ex=true,
ew=true,
gl=10,
gm=10,
lt=1,
fu=function(self,li)
self.lt-=1
if self.eu==-1 and self.lt==0 then
self.eu=240
self.z=sgn(self.c-li.c)*0.5
self.ba=-3
self.ev=false
self.bh=true
self.he=nil
self.gq=0.1
sfx(54)
end
end
})
co.gs["idle"]=
{
gz=5,
gt={12,-12},
}
co.lu=function(self)
end
co.lv=function(self,lw)
if lw.ja then
lw:ja(self)
end
end
co.ja=co.fu
co.lx=co.hc
co.hc=function(self)
self:lx()
if self.z<0 then
self.bg=true
elseif self.z>0 then
self.bg=false
end
if self.eu>=0 then
self.eu-=1
if self.eu<=0 then
del(bs,self)
end
return
end
if self.eu==-1 and not fa.jc and fa.jh==nil then
if di(fa,self) then
if fa.jd>0 then
self:fu(fa)
else
local ly,lz=fa.c,fa.d+(fa:cq())
local ma,mb,mc,md=self:dq()
if mb>lz then
if fa.ba>=0 then
self:lu()
end
else
self:lv(fa)
end
end
end
end
end
co.me=co.hj
co.hj=function(self)
local kz=self.d
local ky=self.c
if self.eu==-1 then
lb(self)
end
self:me()
self.c=ky
self.d=kz
end
return co
end
function lb(self)
local jx,jy=jo:jz()
local mf=10
if self.d>=jy+128 then
local ez=jy+128
circfill(self.c,ez,mf+1,1)
circfill(self.c,ez,mf,7)
self.d=ez
elseif self.d<=jy then
local ez=jy
circfill(self.c,ez,mf+1,1)
circfill(self.c,ez,mf,7)
self.d=ez
end
end
function cd(c,d)
local co=lr(c,d):hs(
{
lu=function(self)
self.gn=4
self.eu=60
self.z=0
self.ba=0
fa.ba=fa.gp*-1
sfx(54)
end,
})
if bm[jm].pal==1 then
co.pal={4,13,15,12}
end
return co
end
function ce(c,d)
local co=lr(c,d):hs(
{
bo=24,
z=0,
ev=false,
gq=0,
o=0,
fu=function(self,li)
del(bs,self)
sfx(54)
end,
})
co.gs["idle"]=
{
gz=15,
gt=
{
ii("00b0ff5000c0ff4000d0ff30",4),
ii("00b1ff4f00c1ff3f00d1ff2f",4)
},
}
co.mg=co.hc
co.hc=function(self)
if abs(self.c-fa.c)>32 or self.d!=self.cs then
self.d=mid(self.cs,self.cs-self:cq()+cos(self.gk*0.003)*36,self.cs-self.bo)
end
self:mg()
end
return co
end
function cf(c,d)
local co=lr(c,d):hs({
bo=24,
gl=12,
gm=8,
lu=function(self)
mh(self.c,self.d+4).pal=self.pal
del(bs,self)
fa.ba=fa.gp*-1
sfx(54)
end
})
co.gs["idle"]=
{
gz=5,
gt={44,46},
}
return co
end
function cg(c,d)
local co=cf(c,d):hs(
{
pal={3,8},
ff=true,
})
return co
end
function ci(c,d)
local co=cg(c,d):hs(
{
he={hh=7,hi=96,hg=false},
ff=false,
z=0,
ba=0,
gq=0,
cs=d,
bg=true,
})
co.gs["idle"]=
{
gz=15,
gt={
ii("9a2daa3d4c4d"),
ii("9b2fab3f4e4f"),
},
}
return co
end
function ii(dg,cu)
local g={}
if(not cu) cu=2
for v=1,#dg,cu do
add(g,cb(dg,v,cu-1))
end
return g
end
function ck(c,d)
local co=lr(c,d):hs(
{
z=-1,
bn=24,
bo=8,
ew=false,
ev=false,
gq=0,
kq=true
})
co.gs["idle"]=
{
gz=5,
gt=
{
185,
441
}
}
return co
end
function cj(c,d)
local co=lr(c,d):hs({
bn=32,
bo=32,
gl=30,
gm=16,
gq=0.025,
lt=6,
he={hh=30,hi=128,hg=true}
})
co.gs["idle"]=
{
gz=5,
gt=
{
ii("00009e9facadaeafbcbdbe00cccd0000"),
ii("00009e9facadaeafbcbdbe00cecf0000"),
}
}
co.mi=co.hc
co.hc=function(self)
self:mi()
self.bg=true
if self.eu==-1 then
if gz%180<20 then
self.ba=-1
self.fd=false
end
if gz%240==0 then
ck(self.c-8,self.d)
end
end
end
co.lu=function(self)
self:lv(fa)
end
return co
end
function mj(c,d,eq,de)
local co=lr(c,d):hs(
{
bn=8,
bo=8,
gq=0,
z=0,
cr=c,
cs=d,
kq=true,
de=de,
ev=false,
eq=eq
})
co.gs["idle"]=
{
gz=5,
gt=ii("005f006ffea1ff91",4)
}
co.mk=co.hc
co.hc=function(self)
self.c=self.cr+(sin(self.gk*de/240))*self.eq
self.d=self.cs+(cos(self.gk*de/240))*self.eq
self:mk()
end
return co
end
function ch(c,d,g)
for v=1,6 do
mj(c,d,v*8-8,g==95 and 1 or-1)
end
end
function mh(c,d)
local co=lr(c,d):hs(
{
z=0,
ba=0,
gl=12,
gm=8,
iz=0,
ml=function(self,mm)
self.z=sgn(self.c-mm.c)*2.5
self.iz=15
self.ew=false
sfx(52)
end,
lu=function(self)
if self.z==0 then
self:ml(fa)
elseif self.iz<=0 then
self.z=0
self.ew=true
fa.ba=fa.gp*-1
end
sfx(54)
end,
lv=function(self,lw)
if self.z!=0 and self.iz<=0 then
lw:ja(self)
else
self:ml(lw)
end
end,
})
co.gs["idle"]=
{
gt={
ii("000efff2001effe2",4)
}}
co.mn=co.hc
co.hc=function(self)
self:mn()
self.iz=max(0,self.iz-1)
for dd in all(bs) do
if dd!=self and dd.ev and dd.ex then
if self.z!=0 and di(self,dd) then
dd:fu(self)
end
end
end
end
return co
end
function cl(c,d)
local co=gj(c,d)
co.mo=false
co.gs["idle"]=
{
gt={
ii("64650064")
},
}
co.hc=function(self)
if self.mo then
self.d=fa.d
elseif fa.c>self.c then
fa:jj(self)
self.mo=true
end
end
return co
end
function id(cc)
local dk=
{
hc=function(self)
self.kf=false
if btn(cc) then
if not self.ka then
self.kf=true
end
self.ka=true
self.kd+=1
else
self.ka=false
self.kf=false
self.kd=0
end
end,
kf=false,
ka=false,
kd=0,
}
return dk
end
function mp(lw)
local kj=
{
mq=lw,
mr=fo(lw.c+lw:cp(),lw.d+lw:cq()),
ms=16,
mt=fo(max(64,lw.c+16),78),
jp=fo(3504,152),
hc=function(self)
if self:mu()<self.mq.c then
self.mr.c+=self.mq.c-self:mu()
end
if self:mv()>self.mq.c then
self.mr.c+=self.mq.c-self:mv()
end
if self:mw()<self.mq.d+(self.mq:cq()) then
self.mr.d+=self.mq.d+self.mq:cq()-self:mw()
end
if self:mx()>self.mq.d+(self.mq:cq()) then
self.mr.d+=self.mq.d+self.mq:cq()-self:mx()
end
self.mr.c=mid(self.mt.c,self.mr.c,self.jp.c)
self.mr.d=mid(self.mt.d,self.mr.d,self.jp.d)
self:my()
self:mz()
end,
jz=function(self)
return self.mr.c-64,self.mr.d-64
end,
mu=function(self)
return self.mr.c-16
end,
mv=function(self)
return self.mr.c-16
end,
mw=function(self)
return self.mr.d+self.ms
end,
mx=function(self)
return self.mr.d-self.ms
end,
my=function(self)
self.mt.c=max(self.mt.c,fa.c-128)
for dd in all(bs) do
if dd.c+dd.bn<self.mt.c-64 or dd.d-dd.bo>self.jp.d+64 then
del(bs,dd)
end
end
end,
mz=function(self)
for dd in all(ht) do
if dd.c<=(flr(self:jz()/256)+1)*256+128+dd.bn then
add(bs,dd)
del(ht,dd)
end
end
end,
}
return kj
end
function fz(na,nb,nc,nd,ne)
local co=gj(na,nb):hs(
{
z=nc,
ba=nd,
bn=8,
bo=8,
gq=0.3,
ev=false,
gs=
{
["idle"]=
{
gt={ne},
}
},
})
return co
end
function nf()
ng=0
gz=0
bs={}
ht={}
kg={}
lo={}
menuitem(1,
"[cheat] next level",
function() jt+=1
jm=bk[jt]
jq(bv) end)
end
function jq(nh)
if ng==bu then
fa=hu(0,0)
fa:gx("idle")
jt=1
end
ng=nh
gz=0
if ng==bv then
jm=bk[jt]
ni(40,96,jm)
elseif ng==bx then
music(26)
end
end
function kv(cy,cz,nj,jg)
nk={cy,cz,nj,jg}
end
function ni(cy,cz,nl,jg)
bs={}
ht={}
kg={}
a={}
lo={}
fa:je(cy,cz)
if jg!=nil and jg!=0 then
fa.jh={js=function() end,}
fa.jf=60
fa.jg=-1
fa.d+=60
end
jo=mp(fa)
jm=nl
local nj=bm[jm]
jo.jp=fo((nj.bn*8)-64-8,(nj.bo*8)-64-24),
bz(nj)
music(bj[nj.bj])
end
function _init()
nf()
end
function _update60()
gz+=1
if ng==bu then
if btnp(4) or btnp(5) then
jq(bv)
end
elseif ng==bv then
if gz>=120 then
jq(bw)
end
elseif ng==bw then
if btnp(2,1) then
fa:iu()
end
if not fa.jc and fa.iv==0 then
for co in all(bs) do
co:hc()
end
for co in all(kg) do
co:hc()
end
end
fa:hc()
jo:hc()
if nk!=nil then
ni(nk[1],nk[2],nk[3],nk[4])
nk=nil
end
elseif ng==bx then
if btnp(4) or btnp(5) then
jq(bu)
end
end
end
local nm=15
local nn="00000000000000011111110000000022222211100000033333311100000044422222110000055555111110000066dddd55551110076666ddd5551100888822222200000999444444550000aa9994445555000bbb333333300000ccccc3311111100ddd555511111000eeed44222221100ff6ddd555551100"
function no(v)
for kj=0,15 do
if flr(v+1)>=nm then
pal(kj,0,1)
else
local np=kj*nm+v+1
pal(kj,cb(nn,np,0),1)
end
end
end
function _draw()
if ng==bu then
cls(0)
gg("super mario world bros.",60,64,7,1,0)
elseif ng==bv then
cls(0)
camera(0,0)
spr(10,32,56,2,2)
gg("   x   "..fa.ij,64,64,7,1,0)
if gz<=nm then
no(nm-gz)
elseif gz>=100-nm then
local jn=gz-(100-nm)
jn/=nm
no(flr((jn)*nm))
end
elseif ng==bw then
if bm[jm].cls then
cls(bm[jm].cls)
else
cls(0)
end
camera(jo:jz())
if fa.jh!=nil then
fa:hj()
end
if(bm[jm].pal!=nil) be(bf[bm[jm].pal])
for co in all(bs) do
if co.o==0 then
co:hj()
end
end
map(0,0,0,0,32,446)
for co in all(bs) do
if co.o==1 then
co:hj()
end
end
if(bm[jm].pal!=nil) bi()
for co in all(kg) do
co:hj()
end
if fa.jh==nil then
fa:hj()
end
camera(0,0)
bc()
sspr(64,72,16,16,54,0,8,8)
bi()
gb("x "..fa.ik,64,2,7,1)
elseif ng==bx then
cls(0)
gg("game over",64,64,7,1,0)
end
pal(13,12+128,1)
end
__gfx__
00002222222004400000000000000000000022222220000000002222222000000000022222200000000000000000000000000055550000000000000000000000
000288eeea7247740000222222200000000288eeea720000000288eeea720000000027aeee822000000022222220000000000544445000000000000000000000
0022222111111182000288eeea720000002222211111110000222221111111000011111111112200000288eeea72000000005444444500000000093333900000
001e11ee71e028820022222111111100001e11ee71e00000001e11ee71e0000000000e17ee111820002222211111110000054444444450000000339999330000
00e4f1ff77ffff42001e11ee71e0000000e4f1ff77ffff4000e4f1ff77ffff40004fff77ff1e4420001e11ee71e0000000511444444115000003393333933000
00e4e11fff1fff4200e4f1ff77ffff4000e4e11fff1fff4000e4e11fff1fff40004fff1ff114774000e4f1ff77ffff4005447144441744500003933333393000
001eeeff1111112000e4e11fff1fff40001eeeff11111100001eeeff1111110000011111ffe4774000e4e11fff1fff4005447111111744500039333333339300
00014eefffff4200001eeeff1111110000014eefffff400000014eefffff40000002888224444400001eeeff1111110054447174471744450093933333393900
0048e8118818200000014eeffff400000048e811881820000048e81188182000000028e84776400000014eeffff4000054447774477744450933393333933390
0474e82ddeed800000002281182000000474e82ddeed82000474e82ddeed82000000222247764000000022811820000054444444444444450333339999333330
477742d77dd7e00000028e8d77d20000477742d77dd7e740477742d77dd7e740000001ddc444f10000028e8d77d2000005554999999455507773393333933777
47771dd77cc710000002444d77d1000047771dd77cc7174047771dd77cc717400000001dcd44f1000002444d77d1000000009ffffff900007777933333397777
014111dddd14f10000047774ccd10000044111dddd111400014111dddd14f4000000001ddd11100000047774ccd1000000119ffffff9000009f7733333377f90
01441111114411000004771ddd100000011111111144f100014111111144110000000001111000000004771ddd100000011111ffff91100009ff77333377ff90
0144f1001441100000004144f100000001444f11444410000144f100144110000000000144f1000000004144f10000000111111999111000009ff777777ff900
00111000011100000000011111100000001111001111000000111000011100000000000111110000000001111110000000111110011100000009997777999000
00000000000066600000002222200000000000000000000000000000000000000000002222222000000000222220000000000000000000000000000000010000
0000000000067d7600002288889000000000022222000000000000000000000000111288888a9000000022888890000000000000000010000000000000671000
0000002222277dd6000288888a900000000228888900000000000002222200000155222288890000000288888a90000000000000000671000000000000677900
0000228888977776000222222222220000288888a9000000000002288889000006755ff422222200000222222222220000000000009776000000000009771900
000288888a955551000444ff1fff000000222222222220000000288888a9000067775ff4ff1ff220000444ff1fff00000000000009f771900000000009771f90
0002222222222251004ff4ff11ffff0000444ff1fff00000000022222222222067775ff4ff11f000004ff4ff11ffff000000000009f771900000000009771f90
000444ff1fff5551004ff44ffffffff004ff4ff11ffff0000000444ff1fff00067672fff4ffffff0004ff44ffffffff00000000009f771900000000009777f90
004ff4ff1fffff51044ff44fff4ffff004ff44ffffffff000004ff4ff11ffff0667682fffff4ffff044ff44fff4ffff00000000009f777900000000009f7ff39
004ff44ffffffff1044fffff4444440044ff44fff4ffff000004ff44ffffffff6668855ff4444fff044fffff444444000000000009ff7ff90000000009f99ff9
004ff44fff4ffff10444fffff444440044fffff4444440000044ff44fff4ffff0001555ffff444400444fffff44444000000000009ffff3900033333099009f9
044fffff4444441000044ffffffff000044fffff444440000044fffff4444440001855555fffff0000044ffffffff00000033333009f9ff90039333937900099
04444ffff4444f1000000155ff0000000044ffffffff000000044fffff444440001557775588851000002fffff10000000393339309909f90033939337f90000
00044ffffffff51000002888552000600002225ff0000000000001ffffffff0000157777788855100000125555810000033393933099009903773933337f9000
00002222552555100001555885520676001855855100000000001822fff000000015777775585510000158555585100003773933337f909903739393337ff990
01115558858551000015555588581776018555885100000000018555210000000000677775555551001558555585510003739393337f909009393339397ff900
15555555855851000155555588558776018555885510000000018555581000000011876775555551015558555585551009393339397f90000393333393779000
155555558858100001555555885585710185555888100000001585555582660000288877555555510155885555885510039333339377f9000939333939379000
15775555885520000155555888558510018555557710000000188555555577660028888885555551155588555588555109393339393790000333939333979000
17777558888590001555558889859100018555577760000000188855555577760002888888555551155588888888555103339393339790000333393333360000
67777588898820001555888888882000028555577772000000028855555557760000444888885510155589888898555103333933333600006773939333760000
67777888888820006777788888882000028855577778200000028885555556660000044444888820677788888888777666739393337600000977733977790000
60778888888820046777788888882004028885577788200000028888855520000044444444888820677788888888777600677339777f900009ff66667ff90000
0668888888882044677788888888204402888884488820000002888888882000004ffff444482200067788888888776009ff666669fff90009f900009f900000
0002888888884444066788888884444400288884448200000002888888882000004ffffff4420000067888888888876099990000009999900099900999000000
000288888888444400022888888444440002884444440000444488888882820000002888ff200000002888822888820044444444000000000000000000888800
44482288888844440048828888844444000284444440000044448888822882004002888882000000028888200288882044544454000028e77e820000088aa880
44488822228844444448882222244444000028444400000044448882288820004400488820000000028882000028882044544454000222222222200088a7aa80
444888820022444444448822000444440000488844400000444422200288200044444448200000000288820000288820445444540041e717717e14008a7aa880
4448888200000000444442000000000000004444044000004444000004444000044444440000000000444400004444004544454404414777777414408aa88800
44422220000000000444000000000000000444440000000044000000044440000044444400000000004444000044440045444544477474eeee47477488a80008
44000000000000000444000000000000000444444400000040000000044444400004444000000000444444000044444445444544477741111114777408880800
4000000000000000004440000000000000000444440000000000000004444440000044400000000044444400004444444444444447744ff77ff4477400888080
9ffffffff14ffff49999994299999921677777777777777700111111111111000011111111111100777777770000001111000000044e4ef11fe4e44000888800
f999999991f99991944444219444442106777777733333770177744444444210017aa999999921107777777700000177771000000011d4e11e4d1100088aa880
f944444421f9442122222221222222210067777733737337177911111119442117a44444444442117777777700011777777100001111d74ee47d111188aa7a88
f944444421f944211111111111111111000677773773773717917777777194211a4444444444421177777777001777777771010014f11dccccd11f418888a7a8
f944444421f122219921999999219999000067773733373717177777777714211a44444444444211777777770017777777771710144411dddd1144418008aaa8
f944444421411114442194444421944400000677333733371417771117771421194444444444421177777777001777777c777771014411111111441008088a88
f944444421fffff12221222222212222000000673333333717911111177714211a441444444142117777777701777cc777c77771001110000001110080008880
f944444421f999911111111111111111000000067733377714999177777194211944414444144211777777771777c77777777771000000000000000000800000
f944444421f9442188888888000000111100000030000000149991777119942119444414414442110000011110010000777771000004ff44ffffffff00000000
f944444421f94421999999990000017bbb10000030000000149999111999942119444444444442110000177710171000777777100044ff44fff4ffff00000000
112244421f944421aa2222aa000017bbbbb1000030000000149991777199942119444444444442110001777771771000777777710044fffff444445000000000
ff1122221f944421a200008a000017bbbbb10000300000001499917771999421194444444444421100077777777710107777777000044fffff44777600000000
f9ff1111f9444421a200008a00001bbbbbb100003000000014499911199944211244444444442211011777777777717177777110000001ff5557776000000000
f999fff1f9444221aa8888aa00001bbbbbb100003000000012444444444442211122222222222111177777777777777117711000000018855555760000000000
f9229991f9222211aaaaaaaa000001bbbb1000003000000001222222222222100111111111111110177777777777777101100000000188555551600000000000
91111114f11111149999999900000011110000003000000000111111111111000011111111111100017777777777771000000000000185555510000000000000
1111111111111111111111111111111133333133000000010000000000000000000000000008008800177c77777777777c777777000185555581000000000000
1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1333311130000001300000000000000000000800008008888000177c77c777777c7777777000185555881000000000000
133333bbbbbb3333333333333333333133331113000001330000000000000000000008080088888a0000177cccc777cccc7777c7000028558885100000000000
1bbb33bbbbbb3bb3333333333b3b3bb133331113000013330000000000000000000088888088a8a80000177777cccccc7ccccc77000028888888100000000000
1bbb33bbbbbb3bb33333333333b3bbb13113111300013333000000000000008000808a8a008a8aaa000001117777cc7777ccc777000028888988200000000000
1bbb33bbbbbb3bb3333333333b3b3bb13113313300133333000001110000808800088a7a0888a7a7000000001777777177777777000288888888200000000000
1bbb33bbbbbb3bb33333333333b3bbb13113333301333333001113330000088a0008aa7788a8a777000000000117771011777711000288888888200000000000
1bbb33bbbbbb3bb3333333333b3b3bb1311333331333333311333333000088aa00888a77888aa777000000000001110000111100000288888888200000000000
1bbb33bbbbbb3bb33333333333b3bbb1000000444400000000007777000000090000001111000000000000000000000000000000000000000777000000000000
1bbb33bbbbbb3bb3333333333b3b3bb1000004999820000000777777000000090000117777110000066000000000000000000000000000000097773300000000
1bbb33bbbbbb3bb33333333333b3bbb10000499988820000077799990000009a0001779999941000677600000000000000000000000000000099773330000000
1bbb33bbbbbb3bb3333333333b3b3bb10004999988882000779998880000009a000179a77a941000677760000000000000000000000000000039933337700000
1bbb33bbbbbb3bb33333333333b3bbb1004999999888940077999888000009aa00179a7a91a94100067776000000000000000000000000000033333337730090
1bbb33bbbbbb3bb3333333333b3b3bb104988899999999400777999909999aaa00179a7a91a94100006797600000000000000000000000000333333337733909
1111111111111111111111111111111104888889999999400077777709aaaa8a00179a7a91a94100067779600000666000000000000000000333339333777999
00111111111111111111111111111100498888899999889400007777009aaa8a00179a7a91a94100067779760006797600000000000000000333399933379999
001bbb33bbbbb3bb33333333b3bbb1004988888999998884000000030009aa8a00179a7a91a94100006777960067779600000000000733377333393799339997
001bbb33bbbbb3bb333333333b3bb10049988899999998843330000300009aaa00179a7a91a94100060677960677779600000000039773377333393339999070
001bbb33bbbbb3bb33333333b3bbb100499999999999999403b3000300009aaa00179a7991a94100066777960677777600000777399777377333397337377070
001bbb33bbbbb3bb333333333b3bb100041116666661114003bb30030009aaaa00179a7991a94100006779736777777300000977339973377733399300070000
001bbb33bbbbb3bb33333333b3bbb1000000677777760000003bb3030009aaa900019aa11a941000033377736773773300073993333333337773399700000000
001bbb33bbbbb3bb333333333b3bb1000000677777d60000003bb3030009a9900001999999441000033393936733939300073333333333333777339900000000
001bbb33bbbbb3bb33333333b3bbb1000000677777d6000000033333009a90000000114444110000093933390939333900033333777333333777339997000000
001bbb33bbbbb3bb333333333b3bb100000006666d6000000000003b009900000000001111000000039333330393333300777333977337777773300990000000
00000080000000000033333333333333ffff0000ffff992199999921000000000000000000000080088088800880000000977333993377999330000000000000
0000087000800000033bbbbbbbbbbbbb992f0000992f442194444421000000000000000000008888880888888888000000993333333779990700999000000000
000088800877700003bbbbbbbbbbbbbb442f0000442f222122222221000000000000000008888aaa888888888888800007333333333739970999079900000000
000078800887000033bbbbbbbbbbbbbb442f0000442f111111111111000000000000000087aaaaaaaaaaaaa88880000079333777333733009999009900000000
00088870078877003bbbbbbbbbbbbbbb442f0000442f9999992199990000000000000000887777aaaaa888888888888800333977337733799999907900000000
00088880888770003bbbbbbbbbbbbbbb442f0000442f944444219444000000000000000088aaaa88aaaa88aa8888800007733993337733339999900900000000
00787880788887703bbbbbbbbbbbbbbb222f0000222f222222212222000000000000000000888888888888888880000077733333337733339999907000000000
00888880887887003bbbbbbbbbbbbbbb111fffff111fffff11111111000000000000000000000800888888000000000009937733337333330999700000000000
00888780888880003bbbbbbbbbbbbbbb999991111111111100000000000000000000000000000000000000000000000003933933377333330393393337733333
00878880878888703bbbbbbbbbbbbbbb944411111111111100000000000000000000000000000000000000000000000003333337773333300333333377333330
00888870888878703bbbbbbbbbbbbbbb222111111111111100000000000000000000000000000000000000000000000003333777733333000333377773333300
00878880078888803bbbbbbbbbbbbbbb112111111111111100000000000000000000000000000000000000000000000077777773333339007777777333333000
00088780088788803bbbbbb3bbbbbbb3991111111111111100000000000000000000000000000000000000000000000077777999933997707777799993399000
000888800088887033bbbb313bbbbb31441111111111111100000000000000000000000000000000000000000000000007799999999997770779779977999900
00007870000878880133331413333314221111111111111100000000000000000000000000000000000000000000000000999977997700009999777977799770
00000080000008780011112221111122111111111111111100000000000000000000000000000000000000000000000009999977797770000000009999999777
33000003330000030000006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3300033b3300030000060500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b3300303b330030000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
033b3303033b33030006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033b3030033b3030005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333b3300333b330650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033333000333336050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000333000003335500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77517777077707770000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66517666077707770008980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66517666077707770089980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66517666077707778899980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66517666066606669999998800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66517666266626669799999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55515555266626667979999700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111266626669979977900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777751266626669999999900000000000000000000000000000000000000000000000000000000000000000000000000011000000110000001100000011000
766666512666266699999999000000000000000000000000000000000000000000000000000000000000000000000000001aa100001aa100001aa100001aa100
76666651266626669999999900000000000000000000000000000000000000000000000000000000000000000000000000174100017994100017410001797410
76666651066606669999999900000000000000000000000000000000000000000000000000000000000000000000000000174100017aa410001741000177a410
766666510888088899999999000000000000000000000000000000000000000000000000000000000000000000000000017a941017a71a41017a9410177a7a41
766666510888088899999999000000000000000000000000000000000000000000000000000000000000000000000000017a941017a71a41017a941017a7a741
555555510888088899999999000000000000000000000000000000000000000000000000000000000000000000000000017a941017a71a41017a9410177a7a41
111111110000000099999999000000000000000000000000000000000000000000000000000000000000000000000000017a941017a71a41017a941017a7a741
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010101010101010000000000000000000000000000000000000000000101050500008383838300000000000001010500000083838383000000000001
0101010100000000000000000000000001010101000000008888000000000000010100010000000088880000000000000000010100000000000000000000000000000101000000000000000000000000000000000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000969700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000969700000000000000009697000096970000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011200200a135161450713513145081351414507100071000710013100131000a1000a13516145071351314508135141450810008100141001410014100141001f3001f3001f3000030000300003000030000300
01120020031350f145001350c145011350d1450f1000f10000100001000010000100031350f145001350c145011350d14501100011000d1000d1050d1450c1350b1450a1550c155003000b155091550b15500000
010e00000e1000e0050e1000e005021050e1050e1000e00500100001000e1000e0050e1000e005001000010013100131051310500100001000010000100001000710007100071050010000100001000010000100
010800003c615186533c6053c00518610186533c615186533c6053c60518610186533c61518653186533c6053c6151865318653186533c6053c6053c6053c6053c615186533c615186533c615186533c61518653
011000002413518153001001f1351f153001001c1351c153001002113521153231352315322135211350c1231f135281351c1532b1352d13521153291352b1351f153281351c153241352613523135231530c123
011000001c5251c55300500185251855300500135251f5530050018525185531a5251a5531952518525185530c5231f5251f553235253c515185532152523525235531f5251f5531c5253c5151a5251a55300500
01100000133353f2153f250103353c6153f2153f2350c0000c023113353f215133353c61512335113353f21510335183353f2151c3351d3351d3501a3351c33511023183353f215153351733513335133543f215
010c0000241301a015241301a01524f501a0151a015241301a015241301a0151a01524f501a015241301a0152313018035231301801523f501803518015231301801523130180151803523f50180352313018035
01100000000002b3052b1352a13529135271353f215281350c0232013521135241353c61521135241352613526120001002b1352a135291352713526125281352912030135341203013530135000000000000000
011000000c0230a015283252732526325243153f205243050c0031c3051d3251f3251d325183151c3251d3251c31000000283252732526325253252331524325000002b3252a3102b3253c615000000000000000
01100000001353f21500000071353c615235250c13524525051351c5253f2150c1350c1353f215051353f215001353f2153f215041353c61523525071350c1350c023295253f21529525295253f215071353f215
01100000001002b1052b1352a135291352713526110281350c1232013521135241353c1152113524135261352811000100271352611529105261352411528105241352311507100301303c115001000010000100
001000000050000500285052752526525235053f515245050c5031c5051d5251f5253c505185251c5251d52500500005002052527505265051d52524505245051c5352b505005002b5053c5053f5050050000500
01100000001353f21528325071353c615233250c13524325051351c3253f2150c1350c1353f215051353f215001353f215081353f2153c6150a1353f2150c1050c1350c1053f21507135071353f215001353f215
01100000241352413518153241351815324135261351a153281352413518153211351f1351f1533f1150010024135241351312024135131202413526135281350c123151503f1050c123151503f1153f1153f115
011000000c5232050500500205253c5052052522525005001f5251c505005001c52518525005003f505005000c5232050500500205250050020525225251f5250c5031c5503f505115531c5503f5053f5053f505
0010000008135203253f2150f1353c6153f2151413500000131351c325000000c1353c6153f615071353f6150813520325336150f135306153f215141351f3251313500000000000c13500000000000713500000
0110000013134181341c1341f13424134281342b1342b1302b13014134181341b1342013424134271342c1342c1302c130161301a1341d1342213426134291342e1342e130161002e1352e1352e1353013030130
0010000008135203253f2150f1353c61520325141350a150131350c023100500c1353f61503155071353f6150e1350e1353f6150e135041100e1350e13500000131350f110000000c023071353f6153f6153f615
01100000241352413518153241351815324135261351a153281352413518153211351f1351f1533f1153f15028135281351c153281351c15324135281351c1532b1351f15300100001001f1351f153001001f153
011000000c523185530050020525235532050522525235531f5251c5251c5531c52518525185533f505005000c5231e525235531e525235531e5251e5252355323525235530050000500135251f553005001f553
011000002813524135181531f1353f11523153201352315321135291351d1532913521135211533f11523153231352d135211532d1352d1352b1351f15329135281352413518153211351f1351f1533f11523153
011000002452521525215531c5251c553005001d5251d5531d5252452518553245250c535185533f505005001f525295251d553295253f515285251c553265252452518553005001d5053f515235533f50523553
01100000001353f2153f21506135071351f3530c1353f215051353f215051353f2153f6150c135051351d353021353f2152335305135071353f2150b1353f2150713521325071351d3250c1350c135071351f353
01100000001353f2153f21506135071351f3530c1353f215051353f215051353f2150c1350c135051353f215071353f215233530713507135091353f2150b1350c1353f215071353f21500135183533f21523353
011000002813524135181531f1353f11523153211352115321135291351d153291352113521153001000010023135291351d1532913529135281351c15326135241351c1351c1531c13518135181530010018153
011000002452521525215531c5251c553005001d5251d5531d5252452518553245253f5152355300500005001f525265251a553265253f5152452518553235251f5251f553005001d5053f515235530050023553
010c00200e0301d5151d430150303cb301d5151d5151a0300c0331d5301d015150303cb301a5301a0300c0330c0301c5151c430130303cb301c5151c315180300c0331c5301c015130303cb301c015180300c033
0110002028135281352810028135281052413528135281052b1352b1052b105001001f1350010000100001002b1052b1052b105001002b1050010000100001001f1001f1001f1050010000100001000010000100
011000201e5251e5251e5001e5251e5051e5251e525005002352523505235050050013525005000050000500235052350523505005001f5050050000500005001350013500135050050000500005000050000500
011000200e3350e3351a2530e3351a2530e3350e3351a253133351f2531310500100071351f253001000010013105131051310500100131050010000100001000710007100071050010000100001000010000100
010a00003c6053c0053c6053c005186003c0053c6053c0053c0053c005186003c0053c6053c0053c0053c0053c6053c0053c0053c0053c0053c6053c6053c6053c6053c0053c6053c0053c605000053c60500005
011200200a122161320712213132081221413214113071020710213102131020a1020a12216132071221313208122141321411308102141020810214102051021110206102121020010000100001000010000100
01120020031250f125001250c125011250d1250d1150f10500105001050010500105031250f125001250c125011250d1250d115011050d1050d1050d1250c1250b1250a1151f1050010500105001050010500105
010d00000a1450a7250a7150d1400d7250d7150c1400c7250c7150614006725067150514005725057150b1400b7250b7150a135101450f1350e145141351314512135111100d1450b11009145081100814507305
010d00000a120161130a1050d1200d113001000c1200c113001000612012113001000512011113001000b12017113001000a120101200f1200e120141201312012120121130d1200d11309120151130812014113
000e002007145131330614512133001050610500105001050510500105001050b10500105001050a305103050f3050e305143051330512305000000d305000000930500000083050730500000000000000000000
010e00200712013113061201211300105001050c10500105001050610500105001050510500105001050b10500105001050a10500100001000010000100001000010000100001000010000100001000010000100
01120000037300373003730037300373003730037300373002730027300273002730067300673006730067300573005730057300573005730057300573005730047300473004730047300a7300a7300a7300a730
010900000973009730097300973009730097300973009730047300473004730047300473004730047300473003730037300373003730037300373003730037300473004730047300473004730047300473004730
011200001f117221171f117211171f117201171f117211171f117221171f117231171f117221171f117211171e117211171e117201171e117211171e117221171e117211171e117221171e117211171e11720117
010900002211726117221172711722117261172211725117221172611722117251172211724117221172511722117261172211727117221172611722117251172211726117221172511722117241172211725117
0108000023130231202913029110131151311529130291252913029125291002813028125281002613026125261002413024125241000010000100001000010000100181130c1310010000100001000010000100
0108000013030130251f313133312631312331130301302513030130251d00015030150251c00017030170251a0001f3130a3311c3131333113030130201c313103310c0300c0200c00000000000000000000000
01100000007001072013720187201c7201f720247202472024720287000f72014720187201b720207202472024720247202070011720167201a7201d720227202672026720227001a7251a7251a7251c7201c720
010a00002413424130001000010000100001001f1341f130001000010000100001001c1341c1301c1301c13021134211302112023134231302312021134211302112020134201302012020120221342213022120
010f000022120201342013020120201201f1341f1301f1301f1301f1201f1201f1201f1201f1101f1101f1101f1101f1101f11000100001000010000100001000010000100001000010000100001000010000100
010a00001c7341c73000700007000070000700187341873000700007000070000700137341373013730137301d7341d7301d7301d7301d7301d7301d7301d7301d7301d7341d7301d7301d7301d7301d7301d730
010b00201073020737237172073520730207301173021730217102173524717217171273022730227102273522730227301f730137101f736137361f736137361f736137361f7361370700700007000070000700
010a00001303013030000000000000000000001003010030000000000000000000000c0300c0300c0300c0301103011030110301103011030110301103011030110300d0300d0300d0300d0300d0300d0300d030
011000000d0300d0300d0300d0320d0320c0300c0300c0300c0220c0220c0120c0150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00201c03026030260102603526030260301d03027030270102703527030270301e03028030280102803528030280302903029010290262302629026230262902623026290262300000000000000000000000
01040000101500c1510e1501015010100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
01020000137751f7752b7753777537705007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010200002476025751277412f7002b7512c7512d7412e7312f7212f7052f70032700037000070037700377002f7002f7002f7002f700007003370004700007000070000700007000070000700007000070000700
010200001c6500553000505216500a530005051b65004530005052065009530005051a65003530005051f65008530005051965002530005051b65004530006000060000600006000060000600006000060000600
01030000347502d750347502d75028750217501c75015750107500a75004750347502d750347502d75028750217501c75015750107500a75004750347502d750347502d75028750217501c75015750107500a750
01050000187401f740207401974020740217401a74021740227401b7402274023740007000070000700007000070000700007001a70021700227001b700227002370000700007000070000700007000070000700
01040000245401f54024540285402b540305402b5402054024540275402c540275402c540305403354038540335402254026540295402e540295402e54032540355403a540355400050000500005000050000500
01100000371553c15534c703c1553e15537c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000015720167201772018720197201a7201b7201c7201d7201e7201f720207202172022720237202472025720267202772028720297202a7202c7202d7202f72030720327203372035720367203872039720
010400002f7502f7502f7503475034750347503474034740347403474034740347303473034720347203472034710347103471500700007000070000700007000070000700007000070000700007000070000700
010200001f1601f1602213022130211312113023160231601f150211512110021100231012310023100231001f1001f1001f1001f105211002110523100231051f1002010122101231001f100001000010000100
0103000021160211602115021150211502115022140231302412025120261202712028120291202a1202b1102c1102d1100010000100001000010000100001000010000100001000010000100001000010000100
__music__
00 1c 1d 1e 03
01 04 06 05 44
00 04 06 05 44
00 08 0a 09 44
00 0b 0d 0c 44
00 08 09 0a 44
00 0b 0c 0d 44
00 0e 10 0f 44
00 13 12 14 44
00 04 05 06 44
00 04 05 06 44
00 15 17 16 44
00 19 18 1a 44
00 15 17 16 44
00 19 18 1a 44
00 0e 10 0f 44
00 13 12 14 44
00 15 16 17 44
02 19 1a 18 44
01 00 20 43 02
00 01 21 43 02
00 22 23 43 44
02 24 25 43 44
03 07 1b 43 44
00 3e 42 43 44
04 2a 2b 43 44
00 2d 31 43 44
04 2e 32 43 44
01 26 28 43 44
02 27 29 43 44
00 3c 42 43 44
04 11 2c 43 44
04 33 30 43 44
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
