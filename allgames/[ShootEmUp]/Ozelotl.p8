pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ozelotl v1.0
-- by catzpaw
--[[

’’key assignment’’

cursor:move
[x]xv:fire
[o]zc:purge

’’mission’’

 assault enemy's
communication hubs and
gather boss' information.
 when enough information
is accumulated,head on to
the boss and defeat it!

’’weapons’’

[x]fire
rapid-fire:
  quick-fireing gun
power shell:
  slow but powerful!
wide shot:
  bullets spread forward
3way shot:
  foward and diagonally
  backward plasma balls
circular:
  rotating plasma balls
  and forward shot

[o]purge
 detach equipped weapon
and detonate for destroy
all enemies and bullets.

’’score multiplier’’

shield remains:
 99-90 1x  49-40 6x
 89-80 2x  39-30 7x
 79-70 3x  29-20 8x
 69-60 4x  19-10 9x
 59-50 5x   9-1 10x

’’’’

you can do:
’to play the game
’share screenshots and videos
’modding
 (you must change the
  cartdata name)

you cannot do:
’resell copy of the game
’diversion of the content
 (without lua source code)


(c)2019 catzpaw

]]
mdy,lbf,hss,dp,sv,ll,clc,shk,mus,si,mm,ph,fc,lpx,lpy,gh=
.2, 0,  16, 0, 0, -1,1,  0,  255,0, 1, 0, 0, 0,  0,  0
udp,   ip,udu,mi,lv,mp,mp2,sp2,msx,msy,msa,msc,sh,dco,co,w1,w2,w3=
0x4300,0, 0,  1, 1, 0, 512,1,  63, 144,0,  0,  59,0,  0, 0, 0, 0
nrc,  scm,sc1,sc2,sc3,hs1,hs2,hs3,ls1,ls2,ls3,gsp,gsa,gsc,gsn,gsw=
false,5,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
cll,bs,fg,bg,fx,pb,en,eb,gsv,gsm={},{},{},{},{},{},{},{},{},{}
udl,udi,esl,esi,gsl,gsi,ddl,ddi,sdl,sdi,tdl={},{},{},{},{},{},{},{},{},{},{}
pt={-160.5,24415.5,24410.5,23130.5,23050.5,2570.5,2560.5,0.5,-161,24415,24410,23130,23050,2570,2560,-23130.5,-3855.5,3855.5}pt[0]=-.5

function _init()
 cartdata("czp_ozelotl")
 if dget(63)~=255 then dset(2,1)dset(3,49)dset(63,255) end
 pre()
end
function _update()
 si=max(si-1,0)
 if ph<20 then
  if ph==0 then usp()
  elseif ph==10 then utt()
  elseif ph==11 or ph==12 then ugo()
  elseif ph==13 or ph==14 then gsx()foreach(fx,ufx)
  end
 else
  if sh>0 and ph~=20 then
   gsx()
  elseif sh<-999 and fc>120 then
   wcl(4)ph,fc=11,0
   return
  end
  if ph==20 then
   if fc<30 then msy=128+sin(fc/80)*40
   else ph=22 end
  else ups()end
  if ph<30 then if ph==22 then gbs()end
  elseif ph<40 then gcl()end
  foreach(bg,ubg)foreach(fg,ufg)
  foreach(pb,upb)foreach(en,uen)
  foreach(eb,ueb)foreach(fx,ufx)
 end
 fc=band(fc+1,16383)
end
function _draw()
 camera(rnd(shk)-shk*.5,rnd(shk)-shk*.5)shk*=.3
 if ph<20 then
  if ph==0 then dsp()end
  if ph==10 then dtt()end
  if ph==11 then dgo()end
  if ph==12 then ded()end
  if ph==13 then dms()camera(0,10)pal()foreach(fx,dfx)camera()end
  if ph==14 then cls(0)end
 else
  if ph<30 then
   dst(sp2)
   cst(4)foreach(bg,dbg)
   if ph==21 then cst(2)else cst(3)end
   foreach(fg,dfg)
  elseif ph<40 then
   cst(1)mdy=.2 dmp(1)dmo(6400)
   foreach(bg,dbg)
   cst(2)foreach(fg,dfg)
  else
   cst(1)mdy=3 dmp(ph-40)dmo(6912)
   cst(2)foreach(fg,dfg)
  end
  pal()foreach(en,den)
  dps()foreach(pb,dpb)
  pal(8,8+fc%2)foreach(eb,deb)
  pal()foreach(fx,dfx)dsc()
 end
end
function esx(i)local a,d,u,v=0,0,0,0 for j=0,32 do
 local h,l=hl(peek(i.p))i.p+=1
 if h==0 then if l==0 then i.t=0 return elseif l<8 then i.m=i.p i.c=flr(l*l*.25)+l+1 elseif l==8 then i.c-=1 if i.c>0 then i.p=i.m end end
 elseif h==1 then i.a=l*.5 elseif h==2 then i.d=l*.0625 elseif h==3 then i.r=l elseif h==4 then i.n=l i.i=0 i.q=ld(960+i.r)
 elseif h<8 then if h==6 then l*=3 elseif h==7 then l=(i.h%l)*3 end i.w+=1 if i.w<l then i.p-=1 i.d=(i.d+i.b)%1 i.x+=cos(i.d)*i.a i.y+=sin(i.d)*i.a return end i.w=0 i.h=flr(hsh(i.h)*256)
 elseif h<10 then d=atan2(msx-i.x,msy-i.y) if h==9 then d+=.5 end v=(1+i.d-d)%1 u=(l+1)*.03125 if abs(v)<u or abs(v)>1-u then i.d=d elseif v<.5 then i.d-=sgn(v)*u else i.d+=sgn(v)*u end
 elseif h==10 then i.a+=l*.1 elseif h==11 then i.f=l elseif h==12 then i.b=(l-8)*.015625+1 elseif h==13 then i.a-=l*.1 elseif h==14 then i.p=esi[ld(512+i.t)]+l
 elseif h==15 then
  if l==0 then i.y=8808-mp
  elseif l==1 then i.y=40
  end
 end
end end
function igs(m)mi,gsp,gsa,gh=m,0,0,m co%=100 end
function gsx()for i=1,64 do gsc=spk(gsp)gsp+=1
 if gsc<16 then gsn=spk(gsp)gsp+=1
  if gsc==0 then gsp=gsi[mi]
  elseif gsc==1 then gsa=gsn
  elseif gsc==2 then gsw+=1 if gsw<=gsn then gsp-=2 return end gsw=0
  elseif gsc==3 then gsp+=gsn
  elseif gsc==4 then afx(gsa,gsn,5,30+band(gsa,15)*54)
  elseif gsc==5 then igs(gsn)return
  elseif gsc==6 then if gsn==0 then lv=1 end if gsn==1 then lv=max(lv-1,1)end if gsn==2 then lv=min(lv+1,3)end
  elseif gsc==7 then afg(0,-384,gsn,0)afg(0,-256,gsn+1,0)afg(0,-128,gsn+2,0)
  elseif gsc==8 then sp2=gsn
  elseif gsc==9 then ph,fc=gsn,0
  elseif gsc==10 then if gsn<=dco then for j=1,2048 do if spk(gsp)==0 and spk(gsp+1)==0 then gsp+=2 return else gsp+=1 end end end
  elseif gsc==11 then local x,y,m=64,-32,2 if gsn==7 then y=40 end if lv>1 or gsn==12 then m=4 end local b=aen(x,y,gsn) bs=b if gsn>7 and gsn<13 then ami(50+gsn,m) end
  elseif gsc==12 then if #en>0 then gsp-=2 end
  elseif gsc==13 then if gsn==255 then music(-1,1500,7)mus=255 else if mus~=gsn then music(gsn,0,7)mus=gsn end end
  elseif gsc==14 then mp,hss,dp=gsn*128,16,0
  elseif gsc==15 then
   if gsn==0 then wcl(lv)end
   if gsn==1 then msy=144 end
   if gsn==2 then se(41,1)wip()end
   if gsn==10 then co+=gsa end
  end
 else gsc,gsn=hl(gsc)
  if gsc<9 then local x,y gsc-=1 if band(gsc,1)==1 and lv<2 then return end if gsc<4 then if gsn==0 then x=ghs(112)+8 else x=gsn*10-16 end if gsc<2 then y=-16 else y=144 end else if gsn==0 then y=ghs(112)+8 else y=gsn*10-17 end if gsc<6 then x=-16 else x=144 end end aen(x,y,gsa)
  elseif gsc==9 then afx(0,0,19+gsn,gsa*3)
  elseif gsc==10 then gsv[gsn]=gsa
  elseif gsc==11 then gsv[gsn],gsm[gsn]=gsa,gsp
  elseif gsc==12 then gsv[gsn]-=1 if gsv[gsn]>0 then gsp=gsm[gsn]end
  elseif gsc==13 then se(gsn,5)
  else
   local w=gsn*3 gsw+=1
   if gsc==14 then w*=10 end
   if gsw<=w then gsp-=1 return end
   gsw=0
  end
 end
end end
-->8
--spr&map

function wpn(w)w1,w2,w3=w,w1,w2 if w1==5 and w2~=5 then apb(16,0,8,0)apb(-16,0,8,.5)end end
function apb(x,y,t,d)local i={x=msx+x,y=msy+y,t=t,d=d,a=1,c=0}if t==7 then i.a=2 end if t==8 then i.a=4 end add(pb,i)end
function upb(i)if i.t<8 then if i.y<-16 or i.y>144 or i.x<-16 or i.x>144 then i.t=10 else i.x+=cos(i.d)*ld(943+i.t)i.y+=sin(i.d)*ld(943+i.t)if pbh(i.x,i.y,i.a)then if i.t<7 then i.t=10 end se(40,0)afx(i.x,i.y,1,.25)end end elseif i.t==8 and w1==5 then i.d=(i.d+.1)%1 i.x=msx+cos(i.d)*16+1 i.y=msy+sin(i.d)*16 if pbh(i.x,i.y,i.a)then se(40,0)afx(i.x,i.y,1,.25)end else del(pb,i)end end
function dpb(i)if i.t==1 then spr(2,i.x-4,i.y-8,1,2)elseif i.t==2 then spr(4,i.x-4,i.y-8,1,2)elseif i.t==3 then spr(4,i.x-4,i.y-8,1,2,true)elseif i.t>3 and i.t<7 then spr(5,i.x-4,i.y-4)elseif i.t==7 then spr(3,i.x-4,i.y-8,1,2)elseif i.t==8 then spr(5,i.x-4+cos(i.d+.25)*4,i.y-4+sin(i.d+.25)*4)spr(6,i.x-4,i.y-4)else end end
function pbh(x,y,a)for i in all(en)do if i.s>0 and i.t>7 and abs(i.x-x)<ld(640+i.t)and abs(i.y-y)<ld(704+i.t)then i.s-=a return true end end return false end
function aeb(x,y,t,xa,ya)local a=.8+lv*.2 local i={x=x,y=y,t=t,xa=xa*a,ya=ya*a}add(eb,i)end
function ueb(i)i.x+=i.xa i.y+=i.ya local x,y,z=abs(i.x-msx),abs(i.y-msy),i.t+1 if sh>0 and x*x+y*y<z*z then se(47,5)afx(0,0,4,0)sh-=i.t del(eb,i)return end if i.x>132 or i.x<-4 or i.y>132 or i.y<-4 then del(eb,i)end end
function deb(i)spr(24-i.t,i.x-4,i.y-4)end
function afx(x,y,t,d)local i={x=x,y=y,t=t,c=0,d=d}add(fx,i)end
function ufx(i)local t=i.t
 if t==1 then i.x+=cos(i.d)*1 i.y+=sin(i.d)*1 i.c+=1 if i.c>6 then i.t=0 end
 elseif t==2 then i.x+=cos(i.d)*4 i.y+=sin(i.d)*4+i.c*.5-6 i.c+=1 if i.c>16 then i.t=0 end
 elseif t==3 then i.c+=1 if i.c>2 then i.t=0 end
 elseif t==4 then i.c+=1 if i.c>4 then i.t=0 end
 elseif t==5 then i.c+=1 if i.c>i.d then i.t=0 end
 elseif t==6 then i.x+=cos(i.d)*4 i.y+=sin(i.d)*4+i.c*.5-6 i.c+=1 if i.c>16 then i.t=0 end
 elseif t==7 then i.c+=1 if i.c>16 then shk=20 i.c=0 i.d=7 i.t=3 se(42,30)end
 elseif t==8 then i.c+=1 if i.c%2==0 then afx(i.x+rnd(64)-32,i.y+rnd(32)-24,2,.75)se(41,1)end if i.c==30 then afx(i.x,i.y,7,.75)end if i.c>43 then i.t=0 end elseif t>19 and t<27 then i.c+=1 if i.c>i.d then i.t=0 end else del(fx,i)end
end
function dfx(i)local t=i.t
 if t==1 then fpt(4)color(7+(fc%2)*5)circfill(i.x,i.y,6-i.c/2)fillp(0)
 elseif t==2 then fpt(4)color(0+(i.c%2)*8)circfill(i.x,i.y,13-i.c/2)fillp(0)color(7+((i.c+1)%4))circfill(i.x,i.y,7-i.c/3)
 elseif t==3 then cls(i.d)
 elseif t==4 then circfill(msx,msy,6,12*(i.c%2))
 elseif t==5 then local c,l,j local y=57 c,l=hl(i.x)prc(tdl[c],y,ld(951+c))y+=8 for j=1,l do prc(tdl[i.y+j-1],y,ld(951+c))y+=8 end
 elseif t==6 then fpt(4)color(0+(i.c%2)*8)circfill(i.x,i.y,26-i.c)fillp(0)color(7+((i.c+1)%4))circfill(i.x,i.y,14-i.c/1.5)
 elseif t==7 then fpt(4)color(0+(i.c%2)*10)circfill(i.x,i.y,13+i.c)fillp(0)color(7+((i.c+1)%4))circfill(i.x,i.y,16+i.c*2)
 elseif t==20 or t==21 then fpt(17+i.c%2)drw(i.t-8,0,40)drw(20+mi,82,43)drw(20+lv,77,48)
 elseif t>21 and t<27 then fpt(17+i.c%2)drw(i.t-8,0,40)
 else end
end
function ehi(i)if i.s>0 and abs(i.x-msx)<ld(640+i.t)and abs(i.y-msy)<ld(704+i.t)then local a=min(sh,i.s)se(47,5)afx(0,0,4,0)i.s-=a sh-=a end end
function eou(i)local sx,sy=ld(640+i.t),ld(704+i.t)if i.x<-sx-8 or i.x>136+sx or i.y<-sy-8 or i.y>136+sy then return true end return false end
function wip()if ph~=24 then foreach(en,des) end eb={}end
function des(i)if i.t<7 or i.t>13 then afx(i.x,i.y,2,.75)i.t=0 i.q=0 end end
function ami(t,n)local e for i=1,n do e=wir(i)e=aen(e.x,e.y,t)e.j=i end end
function wir(i)local p={}local r,a,d d=848+i*4+bs.t*16-132 r=ld(d+2)a=ld(d+3)*.0078125 p.u=bs.x+ld(d)-64 p.v=bs.y+ld(d+1)-64 p.x=p.u+cos(a)*r p.y=p.v+sin(a)*r return p end
function aen(x,y,t)local i={x=x,y=y,t=t,a=4,b=0,c=0,d=.75,f=0,m=0,w=0,i=0,q=0,r=0}i.h=ghs(256)i.p=esi[ld(512+t)]i.s=ld(576+t)add(en,i)return i end
function uen(i)local t=i.t
 if t==0 then del(en,i)
 elseif t<7 then i.y+=1 if abs(i.x-msx)<8 and abs(i.y-msy)<8 then if t==6 then se(43,5)i.t=0 sh=min(sh+10,99)else se(44,5)wpn(t)i.t=0 end end if i.y>136 then i.t=0 end
 elseif t<14 then
  if i.s<-99 then i.s-=1 if i.s<-145 then i.t=0 end
  elseif i.s<1 then i.s=-100 i.q=0 sca(t)se(45,3)wip()afx(i.x,i.y,8,.75)shk=10
  else ehi(i)esx(i) end
 elseif t<20 then if i.s<1 then i.t-=13 i.a=-.5 se(41,2)afx(i.x,i.y,2,.75)sca(t)elseif i.y<-16 then i.t=0 else if i.c==0 then i.a=2 end i.a-=.03 i.y+=i.a i.c+=1 end
 elseif t<22 then ehi(i)if i.s<1 then if t==20 then co+=20 else co+=30 end sca(t)i.t,i.q,shk=0,0,5 se(45,4)afx(i.x,i.y,6,.75)if lv>2 then i.n,i.i,i.q,i.r=14,0,1,0 end elseif eou(i)then i.t=0 i.q=0 else esx(i)end
 elseif t<52 then ehi(i)if i.s<1 then sca(t)i.t,i.q=0,0 se(41,2)afx(i.x,i.y,2,.75)if lv>2 then i.n,i.i,i.q,i.r=1,0,1,0 end elseif eou(i)then i.t,i.q=0,0 else esx(i)end
 elseif t==52 then esx(i)
 elseif t<64 then
  ehi(i)
  if i.s<1 then
   sca(t)i.t,i.q=0,0 shk=2 se(45,4)afx(i.x,i.y,6,.75)if lv>2 then i.n,i.i,i.q,i.r=14,0,1,0 end
  elseif t<58 and eou(i)then i.t,i.q=0,0
  else esx(i)
   if t>57 then
    local p=wir(i.j)
    if t==62 then i.x,i.y=p.x,p.y else i.x,i.y=i.x*.8+p.x*.2,i.y*.8+p.y*.2 end
    if bs.s<1 then i.t,i.q=0,0 afx(i.x,i.y,2,.75)end
   end
  end
 else del(en,i)return end
 t=i.r
 if i.q>0 and i.i%ld(1008+t)==0 then
  local co,si local b=i.n local n,s,e,c,a,v=ld(384+b),ld(400+b),ld(416+b),ld(432+b),ld(976+t),ld(992+t)
  if i.x>64 then v=128-v end
  if a==127 then a=atan2(msx-i.x,msy-i.y)*128 else a+=32 end i.q-=1 v-=64 if t<14 then a+=i.q*v else a+=rnd(v*2)-v end
  for j=1,n do
   local f=(a+c*(j-1)-e)/128
   si=s*.7+1.3 co=si*cos(f)si*=sin(f)
   if i.t>55 and i.t<60 then aeb(i.x-7,i.y+8,s,co,si)aeb(i.x+7,i.y+8,s,co,si)else aeb(i.x,i.y,s,co,si)end
   if b==15 then s+=1 end
  end
 end i.i+=1
end
function den(i) local t,s=i.t,ld(448+i.t)
 if s==2 then sps(2+flr(fc*.5)%4,i.x,i.y)
 elseif t>0 and t<7 then spr(6+i.t,i.x-4,i.y-4)
 elseif t>6 and t<14 then cst(5)sps(s,i.x,i.y)pal()
 elseif t>13 and t<20 then sps(s,i.x,i.y)spr(i.t-7,i.x-4,i.y-2)
 elseif t>19 then if t>57 and fc%2==0 then local p=wir(i.j)line(p.u,p.v,i.x,i.y,2)end if s==24 then s+=i.q%4 end sps(s+i.f,i.x,i.y)
 else end
end
function ups()
 if sh<1 then if sh>-999 then fc=0 music(-1)si=0 se(45,30)sh=-1000 afx(msx,msy,2,.75)afx(0,0,26,110)msy=160 end return end
 local k=band(btn(),15)local t=ld(832+k)*.125 local w
 if k>0 then
  msa=mid(1,msa+.5,3)
  if t<1 then
   msx,msy=mid(6,msx+cos(t)*msa,120),mid(6,msy+sin(t)*msa,121)
  end
 else msa,msx,msy=0,flr(msx),flr(msy)end
 msc-=1
 if msc<1 and btn(5)then if w1==0 or w1==5 then apb(-3,-4,1,.25)apb(5,-4,1,.25)msc=5
  elseif w1==1 then apb(-3,-4,1,.25) apb(5,-4,1,.25) msc=3 elseif w1==2 then apb(-3,-4,7,.25)apb(5,-4,7,.25)msc=20
  elseif w1==3 then apb(-3,-4,2,.3) apb(6,-4,3,.2) msc=3 elseif w1==4 then apb(1,-4,4,.25)apb(6,3,5,.875)apb(-3,3,6,.625)msc=3 end
 end
 if w1>0 and btnp(4)then w,w1,w2,w3=w1,w2,w3,0 afx(0,0,3,7) se(45,10) wip() if w1==5 and w~=5 then apb(16,0,8,0) apb(-16,0,8,.5)end end
end
function dps()if sh>0 then spr(0,msx-7,msy-7,2,2)end end
function sps(id,x,y)local p,n=sdi[id],#sdl[id]/6 local w,h,s,ox,oy
 for i=1,n do h=peek(p)s=band(h,63)w=1+shr(band(h,128),7)h=1+shr(band(h,64),6)ox=peek(p+1)oy=peek(p+2)p+=3 spr(s,x+band(ox,127)-64-w*4,y+band(oy,127)-64-h*4,w,h,band(ox,128)>0,band(oy,128)>0)end
end
function gcl()if rnd(10)<2 then afg(rnd(160)-16,-60,1,rnd(100)) end if rnd(10)<3 then abg(rnd(160)-16,-60,1,rnd(100))end end
function gbs()local i mp=(mp+1)%30720 if mp%16==0 then i=sbs() afg(i.x1-64,-64,2,i.c1) afg(i.x2+64,-64,2,i.c2)end if mp%32==0 then mp+=1 i=sbs() mp-=1 abg(i.x1-64,-64,2,i.c1) abg(i.x2+64,-64,2,i.c2) end end
function sbs()local i={x1,x2,c1,c2} local h=hsh(mp/4000) i.x1=flr(h*8)*16 if i.x1>64 then i.x1=64 end h=hsh(h) i.c1=flr(h*16)h=hsh(h)
 if h>.5 then i.x2=64-i.x1 i.c2=i.c1 if i.c2>11 then i.c2=((i.c2+2)%4)+12 end
 else h=hsh(h)i.x2=flr(h*8)*16 if i.x2>64 then i.x2=0 end h=hsh(h) i.c2=flr(h*16) h=hsh(h) if h>.5 then if i.x1<64 then i.x2=i.x1-64 end if i.x2>0 then i.x1=i.x2+64 end end
 end return i
end
function afg(x,y,t,c)local i={x=x,y=y,t=t,c=c}add(fg,i)end
function abg(x,y,t,c)local i={x=x,y=y,t=t,c=c}add(bg,i)end
function ufg(i)if i.t==1 then i.y+=14 if i.y>200 then i.t=0 end elseif i.t==2 then i.y+=3 if i.y>127 then i.t=0 end elseif i.t>5 and i.t<12 then i.y+=sp2 if i.y>127 then i.t=0 end else del(fg,i)end end
function ubg(i)if i.t==1 then i.y+=10 if i.y>200 then i.t=0 end elseif i.t==2 then i.y+=2 if i.y>127 then i.t=0 end else del(bg,i)end end
function dfg(i)local h,x,y,r
 if i.t==1 then h=hsh(i.c)r=20+h*10 color(6)fpt(4)circfill(i.x,i.y,r)fillp(0)
  if r>20 then r*=.7 circfill(i.x,i.y,r)circfill(i.x+cos(h)*r,i.y+sin(h)*r,10+hsh(h)*5)h=hsh(h)circfill(i.x+cos(h)*r,i.y+sin(h)*r,10+hsh(h)*5)end
 elseif i.t==2 then x=(i.c%4)*8+96 y=flr(i.c*.25)*8 map(x,y,i.x,i.y,8,8)
 elseif i.t>5 and i.t<12 then drw(i.t,i.x,i.y)
 else end
end
function dbg(i)if i.t==1 then h=hsh(i.c)r=20+h*10 color(6)fpt(4)circfill(i.x,i.y,r)fillp(0)elseif i.t==2 then x=(i.c%4)*8+96 y=flr(i.c*.25)*8 map(x,y,i.x,i.y,8,8)end end
function dst(s)cls(0)local y,h mp2=(mp2+s)%1024 for i=0,127 do h=hsh((mp2+1024-i)%1024)color(1+flr(h*200%2)*5)pset(h*128,i)end end
function dmp(s)
 s=mid(0,s,8)if hss>0 then s=8 hss-=1 end sv+=s s=flr(sv) sv-=s
 mp=(16384-s+mp)%16384 dp=(144-s+dp)%144
 local l,d=flr(mp*.125),flr(dp*.125)
 if l~=ll then
  for i=0,17 do
   local a=lbf+i
   poke(a+36,peek(a+18))
   poke(a+18,peek(a))
   poke(a,flr(fbm(i+111,l)*14.5)+3)
  end
  local f,h=fget(flr(l*.125)),band(flr(l*.25),1)*4
  for i=0,15 do
   local t=h+flr(i*.25)
   if band(shr(f,t),1)==0 then
    local b=lbf+i t=gett(b,8)
   	if t==0 then t=gett(b,7)end
   	if t==0 then t=gett(b,6)end
   	if t==0 then t=93 end
   	if t>252 and hsh(i*l+51)>.3 then
   	 t=peek(6192+flr(hsh(i*l+l)*16))
    end
   else
    if peek(lbf+i+18)>8 then t=84 else t=94 end
    poke(lbf+i+19,8)
   end
   mset(i,d,t)
  end
 end
 ll=l l=dp%8
 map(0,d,0,-l,16,18-d)
 map(0,0,0,(18-d)*8-l,16,d)
 d=(d+1)%18
end
function gett(x,y)local t=0
 if peek(x+19)<=y then return 0 end
 if peek(x+18)>y then t+=8 end
 if peek(x+37)>y then t+=4 end
 if peek(x+20)>y then t+=2 end
 if peek(x+1)>y then t+=1 end
 return peek(6048+t+y*16)
end
function dmo(b)
 for j=0,4 do
  local f=band(flr(shr(mp,6))+255+j,255)
  for i=0,1 do
   local a=f*4+i*2
   local o=peek(a+b)
   if o<64 then
    local x,y=hl(peek(a+b+1))
    a=6208+o*3
    local u,v=peek(a),peek(a+1) 
    local w,h=hl(peek(a+2))
    x=x*8-16
    y=y*8-96+j*64-band(mp,63)
    map(u,v,x,y,w+1,h+1)
   end
  end
 end
end
function dms()
 pal(5,2)pal(6,14)pal(11,3+(fc%2)*8)
 map(80,0,0,0,16,16)rectfill(24,76,24,88,11)
 for i=0,10 do pal(6,1+flr(((fc+i)%7)/6)*11)local y=84+i*4 spr(101,48,y)spr(101,72,y)end
 msy-=(msy-88)*.02 pst(21)sps(37,65,76)sps(1,65,msy+2)
 pst(17)sps(37,64,74)sps(1,64,msy)
end
-->8
--utils&ui

function pre()
 local b=""for i=1,#td do local s=sub(td,i,i)if s=="|"then add(tdl,b)b=""else b=b..s end end
 for s in all(esl)do add(esi,udp)dec(s)end for s in all(sdl)do add(sdi,udp)dec(s)end lbf=udp udp+=54
end
function ttl()
 fg,bg,fx,pb,en,eb={},{},{},{},{},{}
 nrc,  mp,  hss,dp,fc,ph,msx,mi,     sh,     hs1,    hs2,    hs3=
 false,3616,13, 0, 0, 10,63, dget(2),dget(3),dget(4),dget(5),dget(6)
end
function utt()
 if btnp(0)then se(46,0)sh-=10 end
 if btnp(1)then se(46,0)sh+=10 end
 sh=mid(9,sh,99)scm=10-flr(sh*.1)
 if btnp(2)then se(46,0)mi+=1 end
 if btnp(3)then se(46,0)mi-=1 end
 mi=mid(1,mi,4)
 if btnp(5)then
  sp2,sc1,sc2,sc3,co,dco,lv,ph,fc,gh,w1,w2,w3=
  3,  scm,0,  0,  0, 0,  1, 20,0, mi,0, 0, 0
  if mi==1 then music(0,0,7)mus=1 else sfx(44,0)mus=255 end
  dset(2,mi)dset(3,sh)igs(mi)bs.s=0
  cll={0,0,0,0,0,0,0,0}clc=mi*2-1
 end
end
function dtt()
 cst(1)mdy=.2 dmp(.5)dmo(6400) if hss>0 then rectfill(0,0,127,127,1)end
 pal()drw(5,0,0)
 color(0)drw(3,17,25)
 if(flr(rnd(16))<1)then color(8)drw(4,16,25)color(12)drw(4,18,25)color(6)drw(4,17,25)
 else color(7)drw(4,17,25)end
 prc("hiscore "..ssc(hs3,hs2,hs1),74,12)prc("        .  .  .",75,12)
 prc("mission \x83    \x94  ",82,7)prc("shield  \x8b    \x91  ",90,7)
 prb(mi,78,82,7)prc("        "..sh,90,7)prc("score multiplier x"..scm,98,10)
 prc("\x97start ",106,7)prc("(c)2019 catzpaw",115,14)
end
function dcl(y)local b=" "
 for i=1,8 do local a=cll[i]+1 b=b..sub("-123x",a,a) if i%2==0 then b=b.." "end end
 prc(b,y,7)prc("score "..ssc(sc3,sc2,sc1),y+12,12) if nrc then prc("- new record -",y+20,8)end
 prc("       .  .  . ",y+13,12)prc("\x97ok ",115,7)
end
function csc()
 local r=false if hs3<sc3 then r=true
 elseif hs3==sc3 and hs2<sc2 then r=true
 elseif hs3==sc3 and hs2==sc2 and hs1<sc1 then r=true end
 if r then hs1,hs2,hs3=sc1,sc2,sc3 dset(4,hs1)dset(5,hs2)dset(6,hs3)end
 return r
end
function ugo()if fc==1 then nrc=csc()end if fc>10 and btnp(5)then music(-1,1500,7)mus=255 ttl()end end
function dgo()pal()dst(-1)rectfill(0,41,127,43,9)prc("g a m e  o v e r",40,7)dcl(70)end
function ded()pal()dst(0)drw(6,0,0)color(9)drw(3,17,25)color(0)drw(4,17,25)dcl(56)prc("thank you for playing!",106,10)prc("(c)2019 catzpaw",97,14)end
function sca(p)local sc=ld(768+p)*50 for i=1,scm do sc1+=sc if(sc1>9999)then sc2+=flr(sc1/10000)sc1%=10000 end if(sc2>9999)then sc3+=flr(sc2/10000)sc2%=10000 end end end
function ssc(s3,s2,s1)local ss3,ss2,ss1="0000"..s3,"0000"..s2,"0000"..s1 return sub(ss3,#ss3-3,#ss3)..sub(ss2,#ss2-3,#ss2)..sub(ss1,#ss1-3,#ss1)end
function dsc()if dco~=co then dco+=sgn(co-dco)end scs=ssc(sc3,sc2,sc1)sco=flr(dco).."%" ssh=""..max(sh,0) spr(13,1,1)prb(scs,10,3,7)prb(".  .  .",20,4,7)spr(14,59,1)prb(sco,68,3,7)spr(15,85,1)prb(ssh,94,3,7)local w=w1 if w>0 then spr(6+w,103,1)end pal(14,2)w=w2 if w>0 then spr(6+w,111,1)end w=w3 if w>0 then spr(6+w,119,1)end pal(14,14)end
function usp()if fc>70 then ttl()end end
function dsp()cls(0)if fc>10 and fc<60 then cls(14)drw(1,49,40)drw(2,32,75)end end
function dec(p)for i=1,#p,2 do poke(udp,h2i(p,i))udp+=1 end end
function h2i(x,y)return tonum("0x"..sub(x,y,y+1))end
function spk(p)return h2i(gsl[mi],p*2+1)end
function ld(p)return peek(16064+shr(band(p,16320),6)*68+band(p,63))end
function se(x,y)if si==0 or x==47 then sfx(x,3)si=y end end
function wcl(l)cll[clc]=l clc+=1 end
function fpt(p)fillp(pt[p])end
function cst(p)p=p*64+mi*16-80 for i=0,15 do pal(i,ld(p+i))end pal(8,ld(352+fc%32))end
function pst(p)p*=16 for i=0,15 do pal(i,ld(p+i))end end
function sb(p)local b=peek(p)if b>127 then b=-band(b,127)end return b end
function hl(p)return shr(band(p,240),4),band(p,15)end
function hsh(p)return band(sin(p*337.313)*341.131,0x.ffff)end
function vns(x,y)local a,b=flr(x),flr(y)x-=a y-=b a+=b*2 x*=x*(3-2*x)y*=y*(3-2*y)return (hsh(a)*(1-x)+hsh(a+1)*x)*(1-y)+(hsh(a+2)*(1-x)+hsh(a+3)*x)*y end
function fbm(x,y)return max(vns(x*.07,y*.08)*.4+vns(x*.14,y*.14)*.4+cos(y*.001)*mdy,0)end
function ghs(p)gh=hsh(gh)return flr(gh*p)end
function prb(s,x,y,c)color(0)print(s,x-1,y)print(s,x+1,y)print(s,x,y-1)print(s,x,y+1)print(s,x,y,c)end
function prc(s,y,c)prb(s,64-#s*2,y,c)end
function drw(s,x,y)local ox,oy,lx,ly,c,b,p=x,y,x,y,0,0,peek2(0xffe+s*2)local h,l,g,w
 for i=1,999 do h,l=hl(peek(p))p+=1 local x,y=lx,ly
  if h==0 then if l==0 then return elseif l==1 then lx=ox elseif l==2 then ly=oy elseif l==3 then lx,ly=ox,oy
   elseif l==4 then g=peek(p)p+=1 for i=0,g do w=peek(p)p+=1 if band(w,16)>0 then pset(x,y)end if band(w,32)>0 then pset(x,y+1)end if band(w,64)>0 then pset(x,y+2)end if band(w,128)>0 then pset(x,y+3)end x+=1 if band(w,1)>0 then pset(x,y)end if band(w,2)>0 then pset(x,y+1)end if band(w,4)>0 then pset(x,y+2)end if band(w,8)>0 then pset(x,y+3)end x+=1 end ly+=4 end
  elseif h==8 then circfill(lx,ly,l*2)elseif h==9 then rectfill(lx,ly,lx+peek(p),ly+l)p+=1 ly+=l+1
  elseif h==4 then for j=0,l do g,w=hl(peek(p))p+=1 x+=g rectfill(x,y,x+w,y)x+=w+1 end ly+=1
  elseif h==5 then for j=0,l do g,w=hl(peek(p))p+=1 x+=g rectfill(x,y,x+w,y+1)x+=w+1 end ly+=2
  elseif h==6 then g,w=peek(p),peek(p+1)p+=2 for j=0,l do x=(g*(l-j)+w*j)/l rectfill(lx,y,x,y) y+=1 end ly+=l+1
  elseif h==7 then g=peek(p)p+=1 for j=0,l do x=sin(j/(l*2))*g-2.5 rectfill(lx-x,y,lx+x,y)y+=1 end
  elseif h==10 then for j=0,l do x,y=hl(peek(p))g,w=hl(peek(p+1))p+=2 rectfill(x+lx,y+ly,g+lx,w+ly)end
  elseif h==11 then for j=0,l do x,y=hl(peek(p))p+=1 pset(x+lx,y+ly)end
  elseif h==12 then lx+=l elseif h==13 then lx+=(l-8)*8 elseif h==14 then ly+=l elseif h==15 then ly+=(l-8)*8
  elseif h==1 then c=l color(c+b*16)elseif h==2 then b=l color(c+b*16)elseif h==3 then fpt(l)
  else return end
 end
end
-->8
--data

gsl={
"091708010d010e0f01110409e2011491e109160121040ae301ffb101ffa1010e15010f1be40102b2011e250108b3012f1df2c3e2011e2b0108b3012e13f2c3e2c2e20108b301212d1bf2c3e20108b301212315f2c3e20102b20106b3012110f320f4c30106b3012110f120f110f120f1c3c2e4010ab3011c121ef4121e011628f4c3011493e10104b30116222ef4c30114180106b30116121e242ce1c3e20a28010e1501111be40108b3012e"
.."12012f1ef6012e12012f1ef3011e242cf3c3e30136252b0106b3011613f228f3c30106b301161df228f3c3e20107b301203cf44ef434f442f4c3e30119b3011c10f120f1c3e1011493e3011e222ee1011418e10104b3011e121ee1242ce1c30a2801210413e301110414e301210415e106020114920278c100000111040be1011495e20121040c0917e3091508040709e20e0a091ee30121040de30121040ee30111040fe301210410e301110411e10601011492"
.."e201210412011318f40f0001ffb101ffa101101501121be40103b3012f1e1d1cf32e2d2cf3c3e30103b3012e141312f3242322f3c3e40102b3011a131df8252bf81719f8c3e60108b3011e1416f31a1cf32426f32a2cf3c3e40104b3012030f640f6c30114930278011518011eb3013010f120f110f120f1c30a64010f1501101be40119b3011c10f120f1c3e2010ab30116131df4232df4c3e20137242c011e"
.."b3013010f120f1013010f120f1c3010ab3011c10f120f10116131df2011c10f120f10116252bf2c3e401149302780121141cf9011518010cb30121141c013020f320f320f3c30a6401210413e301110414e301210415e106020114920278c1000001110416e1011495e20121041708040706e20915e308010917e1013104180dffe20d0d011494e10b080c000dff01010f0a01210419e1011496e20111041ae30f0005020001"
,"091708010d010e50e2011491e10916e3011318f4060101ffb101ffa1011115010e1be40103b3011e141ce128e1c3e20102b30121131de1232de1011a18e128e1c3e40102b20104b3012110f120f1012c5df3c30104b3012110f120f4c30104b3012110f120f1012d7df3c30104b3012110f120f4c3c2e2010cb3011610f320f3c3e3011493e10104b30121222ef4c30114180106b30121121e242ce1c3e20a28010e1501111be4"
.."0102b20104b3011c10f120f1012c5df3c30104b3011c10f120f4c30104b3011c10f120f1012d7df3c30104b3011c10f120f4c3c2e4013815281bea0102b2011e14232d1c0106b3012e18f2012f18f2c3c2e30106b2012230f140f10103b3011c10f120f1c3c2e3011493e3011e222ee1011418e10103b3011e121ee2242ce2c30a2801210413e301110414e301210415e106020114920278c100000111040be1011495e20121040c0917e3"
.."091508040709e20e28091ee30121041be30111041ce301110411e10601011492e20121041d011318f40f0001ffb101ffa101101501121be40102b20104b3012812f401292cf4c30104b301291ef4012824f4c3c2e4010ab3011a15220106b2011c10f120f1c2c3e40110b3012118f210f120f1c3e4010cb301281401292c012d7df28df27df28df2c3e40114930278011518010cb301291cf3012814f301292cf3012824f3c30a6401111501121be4010ab3"
.."011e10f420f4012030f440f4c3e40104b20103b3012030f140f140f1c3e2c2e2010ab3011a1b2e0106b2011c10f120f1c2c3e4010cb3011c1020012d7df28df2011c1020012d7df28df2c3e40114930278011518010cb30117343cf4434df4424ef4c30a6401210413e301110414e301210415e106020114920278c1000001110416e1011495e20121042508040706e20915e308010917e10141041e0dffe20d0d011494e10b090c000dff01010f0a01210419e1"
.."011496e20111041fe30f0005030001"
,"091708010d010e3ce2011491e10916e3011318f4060101ffb101ffa1010f1401121ce40102b2011a1d230106b3012e15f2c3e3011a132d0106b3012f1bf2c3e3c2e20103b20123151b0106b301161719f3232df3c3c2e40103b30123131517191b1de2012720e2c30104b30123131517191b1df7c3e6011493e10123232527292b2de1011418e10123131517191b1de90a28010f1501111be40107b301211425f2c30107b30121"
.."1627f2c30107b301211a29f2c30107b301211c2bf2c3e5013915281bea0106b2011a100108b3011d10f220f2c3c2e50106b20120333df240f20102b3012118f8c3c2e4011493e3011418010ab30120323ef6444cf6c30a2801210413e301110414e301210415e106020114920278c100000111040be1011495e20121040c0917e3091508040709e20e51091ee301210420e301110421e301210422e301220423e501110411e10601011492e20121041d011318f40f0001ff"
.."b101ffa101101501121be40103b3012718e1141ce1444ce1c3e40114b3011610011740f4c3e40102b20126737577797b7d010ab3012e1325f3012f1d2bf3c3c2e40102b20125535557595b5d0105b30116131df60117434df6c3c2e401149302780115180112b3011d10f220f2c3e20a64010e14010f1ce40104b2012718480104b3011f1523f81b2df8c3c2e40106b2011a100108b3011d10f220f2c3c2e50102b20123"
.."131517191b1df30105b3012a54f2c3e20123131517191b1df30105b3012b74f2c3e2c2e50107b301211c2b013010f2c30107b301211a29013010f2c30107b301211627013010f2c30107b301211425013010f2c3e501149302780115180108b2011f10f2200104b3013010f2c3c2e20a6401210413e301110414e301210415e106020114920278c1000001110416e1011495e20121042508040706e20915e308010917e1015104260dffe20d0d011494e10b0a"
.."0c000dff01010f0a01210427e1011496e201110428e30f0005040001"
,"091708010d010e28e2011491e10916e3011318f4060101ffb101ffa1010e1501101be40104b3011b16281afa011b14281cfac3e40104b30118526456685a0119728476887ae2c3e40108b2011f10f2200106b3011d151bf2c3e1c2e30102b20127537367870104b30121161afa262afac3c2e5011493e10114180108b3011b10f6c3e50a28010f1501111be4010eb3012110f620011730f6c3e5013515281bea0102b201275373"
.."67870104b3011b161afc262afcc3c2e30102b20104b3f701231317191dc30107b30121151bf2252bf2c3e3c2e2011493e30114180110b3012c5d012d7df2012c6d012d8df2c3e40a2801210413e301110414e301210415e106020114920278c100000111040be1011495e20121040c0917e3091508040709e20e64091ee301120429e50122042be50111042de301110411e30601011492e20121041d011318f40f0001ffb101ffa1010e1501101be40108b3013110e120e1"
.."c3e50103b20123121e0124343c0104b30118546601197486fcc3c2e30102b201243739e10105b301281301292df3c3e20105b301291d012823f3c3e2c2e30103b2012433383de10105b3012a53f2012b75f2012a67f2c3e2c2e301149302780115180124353b0104b3011a131df828f8c3e50a64010e1501121be40102b2012554585c012674787c0104b30120333d012128f6012118f6c3e2c2e20108b2013110f3200104b30130"
.."10f2c3c2e40103b2012554585c012674787ce10105b3012a53f2012b75f2012a67f2c3e2c2e30103b2012554585c012674787ce10103b3011b10f3012110f320f3c3e2c2e301149302780115180124353b0104b3011b131df828f8c3e50a6401210413e301110414e301210415e106020114920278c1000001110416e1011495e20121041708040706e20915e308010917e10161042e0dffe20d0d011494e10b0b0c000dff01010f0a01210419e10a68011496e201120442"
.."e50f00090ee1090be100000f00e40111042fe30114950d0e01110430e30121040ce10917e3091508040709e20e56092ce301210431e301110432e3011318f4010e13010f1df801101501111bf4011318f4e501710433f50b0cf5011494e1092af20929f209280c00010718e301210434e30929f2092af2092c01110435e308040706092af10929f101210415e20dff0915e308010917e10d27011494e10b0d0c000918013418e201810436e301210437e301810438e301130439e70183043ce70121043fe401810440e20dff"
.."09170f0201600f0ae401210441e50d0f01149601120442e50121040ae30802f30803f30804f30805e3090ee10f01090de601120444e501130446e701210449e30112044ae50121044ce6090ee1090ce10001"
}

sdl={
"c04040"
,"334444333c4433443c333c3c224040"
,"334245333b4233453e333e3b224040"
,"334045333b4033454033403b224040"
,"334542333e4533423b333b3e224040"
,"363bc23645c22e40423e40bc"
,"2e403f25453e25bb3e3e4044"
,"3540453444bd343cbd3f4040"
,"2f4043344541343b413f403d"
,"2b39be2bc7be2e403f3f4043"
,"2240423c45433cbb4329c43d293c3d3e40bb"
,"2240433c46433cba4329c43d293c3d3e40bb"
,"2240443c48433cb84329c43d293c3d3e40bb"
,"26473c26474426393c263944224040"
,"25473b2547c525b93b253945224040"
,"24c547243b4724453924bb39224040"
,"234447233c47234439233c39224040"
,"3445c4343bc434453c343b3c224040"
,"24444324bc432d45bd2d3bbd3e4040"
,"2b3c442b3cbc2bc4442bc4bc2e40c0"
,"2f404024474124b9412bc7bc2b39bc2d4039"
,"29c4c2293cc23e404b3f4044abcd3cab333c3d403c"
,"3540472e393d2e473dbbcdbfbb33bf3e40573f40503f404aabcf3aab313a2d40373d403f"
,"324545323b4532453b323b3b224040"
,"324346323a4332463d323d3a224040"
,"324047323940324740324039224040"
,"324643323d4632433a323a3d224040"
,"3e40ab2d52352dae35abda38ab26382a52472a2e472a5a3d2a263d3f40313a4436393c363bc8b33b38b329c4bd293cbd29c435293c3522403d2e483e2e383e364b38363538e7523fe72e3fe04043"
,"b740ceb0494db0b74d2644cd2a5b3eabddbb2a253eab23bb2a52452a2e45263ccd264ccc2634cc29c4c3293cc32a40352240c32e4844364cc62e38443634c63644c7363cc7e7503de7303de0403b"
,"29373129c9312a47b72a39b73e40a83e485335484f3e385335b84febd336eb2d362e47c82a4a442e39c82a36443f4033b74044293cc629c4c6224046ebd4c5eb2cc53540303849bd3737bde0403e"
,"e75a35abe03be7a635b75942ab1f3bb7a742e052c5e02ec56e52482a553b2a4e3c6e2e482a2b3b3540442a323cab4fb7abb1b729c7c52939c5abde34ab22342e483e2e383e223a3d22c63de04038"
,"6d51cd6d2fcd6d2f336d5133e740b6e7404a9c4f409e3140ab2b46abd546abd5bae040402e44b42a4a482a36482a4ab82a36b82e3cb4ab2bba29c5c5293bc529c53b293b3b2240402e444c2e3c4c"
,"e740b6e7404a29cec8e040402a4a482a36482a4ab82a36b829b7392e4a402e37c02e444c29c5c5293bc529c53b293b3b2240402948c829b6462ebcb42e3c4c294aba2e44b429b4c529cf3e29313c"
,"35b946354746ab383fabc83f6e404134403a"
,"9c40c122403ebb46bbbbbabb6f47436f3943"
,"e0404029c5c5293bc529c53b293b3b224040"
,"410c90411c98406498407490410ca0411ca84074a0410cb0411cb84064b84074b0410cc04064c84074c0410cd0411cd84064d84074d0410ce0411ce84074e0"
,"31444431bc443144bc31bcbc2e4040"
,"29c5c4293bc42c443c2cbc3c3e403f"
}

td="[tepeyollotl cdc]|[jaguar3]|[tlecuezalotl]|[tlapetlanillotl]|[teoatl]|[tonaltzintli]|[tlalloliniliztli]|[tlaltecuhtli]|"
.."jaguar3, cleared to engage.|roger.|head on to the next target.|roger, jaguar3 descent.|forests and...huge facilities.|they look like factories.|is anyone there?|negative. it's unmanned.|jaguar3, enemies in sight.|engaging.|lost target.|beware of reinforcements.|copy.|jaguar3, the target detected.|roger, jaguar3 go up.|"
.."who are you?|target destroyed.|great. let's go the next.|the sunset...wow.|oh...i can't see from here.|jaguar3 engage.|did you come from the space?|ok. we came half.|"
.."where's the night view of rio?|the mankind cities have gone.|a flock of bats on the radar.|animals are often seen,|but no human.|roger, jaguar3 ascent.|are you human?|bagged one.|awsome. next is the last one.|"
.."jaguar3, airtight is losing.|what's up?|i tried to ventilate.|nice air. sweet!|come on...|welcome back, human.|jaguar3, mission update.|enemy's base detected.|attack on the enemy base.|good luck.|"
.."look at our achievements.|the target ran away.|jaguar3, chase it.|i carried out your order.|save the nature of the earth.|yes, it is.|it's our mistake that|didn't include humanity|in the definition of nature.|"
.."i was a little lonely because|there was no one to report|the results for 364 years.|you did it...excellent.|thank you.|my pleasure.|jaguar3, mission is over.|return to the carrier.|"
.."welcome back...|is what i'd like to say...|but you have to wait to|raise a toast till your|medical checkup is over.|huh? why?|you breathed the air of|the earth...you ventilated.|aieee! i screwed up...|"

esl={
"6510654216078162086f6f00"
,"1301654f6808156f6f00"
,"188001654468086f6f00"
,"16b004a161084a07a161086f00"
,"12240268420807a1610800"
,"1477426f426f6f00"
,"1707d161081104419f650807d2620800"
,"1707d161081104479f650807d2620800"
,"1606d1610810304252024664081220681034436812286810304252024664081228681034436812206810e6"
,"1507d161081064324f6a6a6a2c166610682412663f45666610e6"
,"1606d1610810206a324218c75858c8106a34436a324218c75858c8106a3e456a324218c75858c8106a3e436a324218c75858c8106a3749e7"
,"1605d16108102c04136210354d5d344c5d082430041362104852495808e6"
,"1007f052f052f052f05208100235496834426808023e4f6808eb"
,"162c06d1610810043a4b643b4b6408023c4a68304e3d4a6f304e0868043d4564304c533c4564304c530868033e4f683f4f680868e6"
,"106fb161b26633426fb161b06fe1"
,"201a66c9065908c86f00"
,"281a66c7065908c86f00"
,"2c1868cc59c865c459c86f00"
,"2c1868c459c865cc59c86f00"
,"b30652d10811b261b161b0076f0800"
,"200752d208b161b261b3116f106f2c07a252086f6f00"
,"280752d208b161b261b3116f106f2c07a252086f6f00"
,"24b30655d3082c11b261b161b0076f0800"
,"24b36f6f00"
,"05168f642144139f64086f6f00"
,"162c633341ca05a25208c605d2520841c605a25208ca05d25208e400"
,"162c633341c605a25208ca05d2520841ca05a25208c605d25208e400"
,"1520c752c86332426f6f00"
,"1528c952c86332426f6f00"
,"246410654416078162086f6f00"
,"206310654416078162086f6f00"
,"286310654416078162086f6f00"
,"156511024761426a08156f6f00"
,"18806433416f6f00"
,"1365324a6f6f6f00"
,"6410046437426408146f6f00"
,"6410016437446c446c3f416708146f6f00"
,"641001103245686868374a686808146f6f00"
,"61110466b161b26633426fb161b06f08146f6f00"
,"661002643c416f3442683d416f34426808146f6f00"
,"106f6637426fe2"
,"106f6637446f446f6f663f4167e2"
,"106f6f3245686868374a6868e2"
,"106f6f013c416f3442683d416f3442680802354b6808e3"
,"f0102407a261086f6f00"
,"f1106fe2"
,"1a6f6f00"
,"1467761068354a6f32426f6f9f146f6f00"
}
__gfx__
0000000000000000000cc000000cc0000cc0000000cccc00000000000eeeeee00eeeeee00eeeeee00eeeeee00eeeeee007777770004444000055550000111100
00000007600000000007700000c77c00077000000c7777c0000cc000ee7ee7eeee7ee7eeeeeeeeeeeee77eeeeee777ee7e7ee7e70444444005585550011cc110
000000c7cc000000000770000077770007700000c770077c00c77c00ee7ee7eee776776ee76ee67eeee66eeee6e66e7e777887774a9a99a455588555115cc511
000000c71c000000000770000c7777c000770000c700007c0c7007c0ee7ee7eee776776ee76ee67eeeeeeeeeeeeeee6e7e8888e7449a994455588555115cc511
000650c71c065000000770000c7777c000770000c700007c0c7007c0ee6ee6eee7e67e6eee7ee7eee77ee77ee6eeeeee7e8888e74449944455577555117bb711
000650cc1c0650000007c0000c07c0c000c70000c770077c00c77c00eeeeeeeeee6ee6eeee6ee6eee66ee66ee7e77e6e77788777444554445557755517777771
0006507766065000000c7000000c7000000c70000c7777c0000cc000ee6ee6eeee6ee6eeeeeeeeeeeeeeeeeeee766eee7e7ee7e7049a99400555755001755710
0006577b367650000007c0000c07c0c00007c00000cccc00000000000eeeeee00eeeeee00eeeeee00eeeeee00eeeeee007777770004444000055550000111100
0006777b36675000000c7000000c7000000c70000088880000000000000000000224444444444220000000000000000044444229922444449444444444444442
00077677775670000007c0000007c0000000c7000899998000888800000000000002244444422000000000000000000044422994499224449444444444444442
0077717677166700000c0000000c000000000c00899aa99808899880000880000000022442200000000000000000000042299444444992249444444444444442
07777776677667700000c0000000c0000000c00089aaaa98089aa980008aa8000000000220000000000000000000000029944444444449929444444444444442
0bb0677557750bb0000c0000000c000000000c0089aaaa98089aa980008aa8000000000000000000900000000000000994444444444444429224444444444229
00000650065000000000c0000000c000000000c0899aa99808899880000880000000000000000000499000000000099494444444444444424992244444422994
0000000000000000000000000000000000000c000899998000888800000000000000000000000000444990000009944494444444444444424449922442299444
00000000000000000000c0000000c000000000c00088880000000000000000000000000000000000444449900994444494444444444444424444499229944444
00000999999000000077760000000000000050000000000000000000000666666666600000000001566666650044440000000000006666000010010006666660
00099aa9999990000711116000576500000575000000050000000000066777777776665000001001651111560499999766666000067116600550055066111166
009aaa99999994007118811600576500000576500005575005555550677777777777666500005005611551160499997777777660067776601151151161555556
09aaa997799999407187881500576500005765000557766507777770677777777777666500105111615115160049997777777776067116600815518061111115
99aaa779977999447188281500576500005765005776655006666660677777777777666500105005615115160004477777775756067776600055550061555555
9aaa9997799999446118811500576500057650000565500005555550677777777777666501115181611551160000066777775556067776601111111161111115
9aaa9799997999440611115000576500005650000050000000000000677777777777666500855511561111650000000667777776067766600550055066555565
9aaa999779999944006555000000000000050000000000000000000069aa99999999999515515155056666500000000006666660006666000010010006655550
99aa999999999944009999000000000006666550065656509999999499aaaaaa9a9999949444444444444442000000000000000009a999400170061006000060
49aa99999999944409aaaa90009994006777766565165165999999949a99999999999994944444444444444204444666666666609a9779941771176167100166
099a9999999994409aaaaaa9099aa940666665550011110067777775994444444444449494444444444444424999977777777776977997740717816067711765
04999911119944409aaaaa9909aaa9406777766500565500677777759415555555555144944444444444444249999777777757569a9779941718216167178165
00499999999444009aaaaa9409aa9940677776650001100006777750445666666666654494444444444444420449977777775556979999740671176067182165
00049911114440009aaaa994049999400667665000565500006775000415555555555140944444444444444200044666777777764a9779940070060067711765
000044994444000009a9994000444400001111000001100000065000045666666666654094444444444444420000000066666660049999400070060067100165
00000044440000000099440000000000066766500001100000011000004444444444440094444444444444420000000000000000004444000070060006000050
000000099000000094444446644444421666666116666661333333333333333333333333ffffffff3f3fff3f33333333d1d111d1ffffffff56666d5555555555
000009944990000094444664466444426666666566555566333333333333333331313331fffffffff3f3f3f3333333331f1f1f1fffffffff677666d566656665
000994444449900094444446644444426656656565122156333333333333333313331313ffffffff3f33333333333333f1ffffffffffffff6766665166616661
0994444444444990944446444464444266666665652e1256333333333333333331313131ffffffff3333333333333333ffffffffffffffff6666665166616661
944444444444444292244446644442296666666565211256333333333313331313131313ffffffff3333333333333333ffffffffffffffff6666655166616661
944444444444444249922444444229946656656565122156333333333131333131313131ffffffff3333333333f33333ffffffffff1fffffd666555151115111
944444444444444244499224422994446666666566555566333333331313131313131313ffffffff333333333f3f3f3ffffffffff1f1f1f15d5555115555d5d5
944444444444444244444992299444441555555116666661333333333131313131313131ffffffff33333333f3f3fff3ffffffff1d1d111d5511111555555555
944444444444444200000000065066501555555566566656131313131313111311111113ffffffff3f3fffff11111111d1d11111111111115555555511111111
944444444444444266666666065606505155555555555555313131113131313111113111fffff3f3f3ffffff11111d1f1f111111111111115555555511111116
944444444444444255555555065506501555555566566656111313111313131111131311ffff3f3f333f3fff1111d1f1fff1d111111111115555555511111166
944444444444444260056005065056505155555555555555313111311111111111111131fff3f33333f3f3ff111d1fffff1f1d11111111115555555511111666
022444444444422006500650065066501515555566566656131311111131111313131111ffff3f33333f3fff1111f1fffff1f111111111115555555511116666
000224444442200066666666065606505155555555555555111111113333333311111111f3f33333333333f31d1fffffffffff1d111111115555555511166666
0000022442200000555555550655065015155555665666561111111333333333111111133f33333333333f3fd1fffffffffff1f1111111115555555511666666
000000022000000000000000065056505155555555555555313111313333333331311131f3f33333333333f31f1fffffffffff1d111111115555555516666666
6666d666666666666666d666655555551555555555566555d555555d55555555555555553f3333333333333fd1fffffffffffff1ff3f3fff1333333315111111
6555d555555555566555d556655555551155555555566555d111111d5555555558111185f3333333333333f31fffffffffffff1df3f3f3ff3133333361511111
6556d666566565566555d556d11111111115555555566555d111111d555dd55551111115ff3333333333333f11fffffffffffff13f33333f1333333356151111
6556d566566565666566d656d11111111111555555555555d111111d5dd55dd551155515f3333333333333ff1fffffffffffff11f33333f33133333315615111
65566666566565666566d556655555551111155555566555d555555d555dd555511555153f3333333333333fd1fffffffffffff13333333f1313333311561511
655555555555556665666656655555551111115555566555d111111d5d5555d551155515f3f33333333333f31f1fffffffffff1df3f333f33133333311156151
655666666666666665666656d11111111111111555566555d111111d555dd555581111853f33333333333f3fd1fffffffffff1f1ff33333f1313333311115611
666666666666666665666656d11111111111111155555555d111111d5555555555555555f3333333333333f31fffffffffffff1dfff3f3ff3133333351111561
55555555555555556555555665555555111dd111155665553333333355555555555555553f33333333333f3fd1fffffffffff1f1111111116666666616666651
55555555555555556566665665555555111dd11111566555333131335555555511111111f3f333333333f3f31f1fffffffff1f1d511111115555555516666516
111111111111111165666656d1111111111dd111111665553333131366666666555555553f333333333f3f3fd1fffffffff1f1d1551111115555555516665166
111111111111111165555556d11111111111111111115555313131336666666611111111fff3f3333333ffff111f1fffffff1111555111115555555516651666
55555555555555556566665665555555111dd111111dd555331311135555555555555555ff3f3f333f3f3fff11d1f1fff1f1d111555511115555555516516666
55555555511111156555555661111115111dd111111dd155311131135555555511111111fff3f333f3f3ffff111d1fff1f1d1111555551115555555515166666
11111111511111156556666661111115111dd111111dd115331111331111111155555555ffffff3f3fffffff111111f1f1111111555555115555555511666666
111111115111111566666666611111151111111111111111333333331111111111111111fffff3f3f3ffffff11111d1d1d111111555555511111111116666666
04019701fb013e01a7111b111621ae21a031d2319b31a6417d4124513a51806107617e61257135719571f5715671b67117717771d77138719871545454545454
716e2a039611883069be2a039d118f30609c3e4a0077219842b9c4c76a9a30ac2a039611883069ac6e2a039611883069be2a039611883069007140f1ec373303
ec3773cef03f0300008088fc07ec3773cec07e33e70cff00f00f00ff40f173cecc0c73ceccff30e7cccce03f110100ffccec3730e7ccfc0f73ce7ee7ec37008c
8e483e483c482099626c99b230fd9f483c3e482079817cb991ad202a040729591278002e64f760e3f760131464f580f2f580323264f490f2f490323264f3a0f2
f3a013143c0a0004ad54373238433c32102c0a0004ad54383238423d3210c432133383923232133332321314c532323292923232323232323232c43213338293
32321333323213147442463238384d32327443443338384c333264d3f350f24033f264b4f450f23034f26495f550f22035f25457f750f337e30091f9f739f773
39f76339f75339f74339f73339f72339f71339f7af2e1339f72339f73339f74339f75339f76339f783f9f7f9f759f78300112379f74379f76379f78379f7d2e3
39f7c339f7a339f79339f7619339f7a329f7c329f7e329f78329f771628319f7e319f7b339f79339f761d2e339f7c359f7a359f7d1128359f7e359f7c359f7a3
89f7118389f72f614760fc4760bd5701dd5741ed4780108e6780bd4760ad4e67a0cd6721cd8e8702108eedc703aebdf705101f5e712720fc2720fc2730bd3760
fc2740cd3790bd2720104e9c2740fc3760bd47014ebd4701dd37a010cd4e47210061f9f711f9f7f9f761f9f73112c3f9f7f9f7f9f78361f9f730af4348ac48cc
48ac48dc58fc68ac788310389d289d389d289d38ac38cc48ec58bd88f932f93210288d389d389d288c38ac48fc48ac28ec58fc7810af2e43b8bd88bd68ad48cc
68ec58ec48fc68108398fc68fc58fc48cc38cc48ec58ec48ec48ec3810df4eb8cd98cd88bd48bd88830061f9f7f9f7f9f7f9f7f8cdd8cdf8cda8cdf81043bfa8
cdf8cdb8cdf8cdc883006143dfa8cdf8cdb8cdf8cdc81083bff8cdd8cdf8cda8cdf810f9f7f9f7f9f7f9f7830061f9f73112c3f9f7f9f7f9f76183f9f711f9f7
f9f761f9f72ff942f94230afdc78fc48bd88cd98cdb810df2e48ec48ec58ec58cc48cc48fc58ad68bd98104368fc58fc58ec68cc58ad68bd88bdb810dd83af6e
78fc58ec28ac48fc48ac388c289d389d388d2810ddcf88bd58ec48cc38ac389d289d389d289d3810fd4378ac68fc58dc48ac48cc48ac488300118389f7d112a3
89f7c359f7e359f78359f761d2a359f7c359f7e339f771629339f7b339f7e319f78319f761d229f7e329f7c329f7a329f79339f7119339f7a339f7c339f7e339
f78379f76379f74379f72379f7306183fd7f2ef705bdcec70310cebd8702aecd6721cd67a0ad6e4760bd6780108e4780ed5741dd5701bd4760fc47602e4d7147
215e3d47011e3d37a04efd4701bd37a0bd3760104e3720fc2720fc3730bd3760fc2740cd3790bd27200001e9f72083611e09f73e49913e09f720fddd6c5e4991
30bd5c3e4081fffb00bfff00fff11feff00fbadf05badf05ffe09f7ff01fef4040ffeaaaaeff341001021120ad1c8e40e0ff8808ffbb09fff807ffbb09ff8808
20dd3c3e4040feccec8f8c4040ebbff1bb1f241001310001e9f72083611e09f73e49913e09f720fddd6c5e499130bd5c3e4081f65b60fe6e00fff11feff00fba
df05badf05ffe09f7ff01fef4040fbbeb01dbd2411121120ad1c8e40e0ff8808ffbb09fff807ffbb09ff880820dd3c3e404076dbb0bbbb4040f31f10f91f1411
230001e9f72083a11e09f73e49913e09f720fddd6c5e499130bd9c3e40406660f6ef664040bbb0fbffbb14106120cc5e4021fff50bff5501fff00ffff09feff0
9f7ff05f1574404152121111114120dd3e4040aaeebbeeaa4040b8ff7b73cb1410610001e9f72083811e09f73e49913e09f720fddd6c5e499130bd7c3e4040fa
fe7eaf6e4040f07f77e73f047120cc5e4041fff00ffff09feff09f7ff01feff00ffff10efed10da4511211111111111111114120dd3c3e40406467ff66064040
f3bfbbfb3f04710001e9f72083b11e09f73e49913e09f720fddd6c5e499130bdac3e4071fd7d70fcfc0011ff01fff50efff50bfed90dffbb09f11f01404050ff
f55f8d14304120fc8e40e0ff5501fef907f7f80ffff10efff90e20cd2c3e4040ff5555f50f404077ddd57d8f1430410001e9f72083c11e09f73e49913e09f720
fddd6c5e499130bd4c3e40b1ee6676ef67000000f01ffff10effa0fb5da0fb5df00ffef907fff10e4040fff30fff9b2410113120bc8e4081fe9909fef907fff1
1feff05f37f08f88f0bf9b10ff11f0bf9b20ed3c3e4040e66ee67fee4040fccffc83ff1414210001e9f72083611e09f73e49913e09f720fddd6c5e499130bd9c
3e40816467ff660600fff11feff00fbadf05badf05ffe09f7ff01fef4040bbfbffbfbb14202420fc8e40f0ff5501fef50ffff08f88f0bf9bf09fef20cd5c3e40
40fff5ef6fee40407775976f9f2410311100004020fef90700402010ff00004020d9bf0a004020b9ff0500402077e40e004020bbdf05004020ffea0600402011
f10f004020fefb0600402077f50e0054545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
54545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
000000b70000b5b600c700d4c5c6c494d6d6d697d6009596d6a700b4a5a6a46467756775740074df6775656574ef84ff6565757574df84ef6565656565656565
010055610032610072910052c10041c10043610079c1007611607201607411e01301807401817f02817f91807851807c228074320067020067b2007513007601
817f03817f23007bf3008554008a728076e28075438077c38072f390a66490b6010124010161010164610124614124611154c10123c141330201734201721201
75720117722157f2015993015504512f00814200d122308133308173708164d49071e4907101710b017107017103c0816070f107d08160e081600501ff04817f
f051e11eb055f11a7052215c2131113c04420442044204420442044204420442d1644367306b0442124b0442b27bb2ab504c30690199031af045f100f045f100
804ab145804a11beb0492132044204420442a3ce3346924b0442b34604420442044204420377037f7071605b044204420442037f044204420442044204420442
04420442044204420442044204420442044204421224326a0442d164044204420442044204420442a13381ada133818cc232c2723343d1473343634783410442
04420442044204420442044262830442702b0442700b9246830a722c044204420442044204424085044204428087229a9086216c8087214cf082f14c04420442
04427306038a044104420442044204424147044204420442923972644286426242380442044204420442221f044204420442305304420369044204425033815f
0442813e0442818f816c0442044204420442206404420442027104420442044204421073044204420442722c3123202a3103044240630442726fb27b50611056
105504424033202d106d103913440442706b0442105610752165114f43aa434f432fd135d195044243504355434043450442039bf28af135b33a2088329f2044
025104420441822e5072134b5026505a04420442d124d127a151203a0442a1515253206e2221604a1224219972a31111313a3164f292311a3164313a311a0442
102cc1010032e15be01243a78013433c80131146801311268013a22d801320118013502cf262a013a19e01420442804360078043f10be042b1579042429a8043
b15790428043c3538043c3431143f2c2b370d2a95290d269d229d267f272d2243113210bc1007071d242d283d22b6051600b60412131024db113a1756050d2ba
7032d27831116037205e601252613107044202400442044202a00442306e628a62630442407f2023203e60342043503804420442728a728ec23ac27a227ec23a
7101216d04428143044204420442044213440335f10601868047a38a1064804733c88047634e53447344804a804a1224804aa34d6379112a3313636933336359
04421025d13322360442044270307037734291609130122b73420442044611bd73fb334dc21b336d136e034b135313791334d2a8d268e2516344734612019118
6009b1027302210ba247a24d04420442136413a404420442029310540244815b2314812904420442044204424142b15e123b4254044204420442044204420442
c13b00ab908b2193808cc39c808cc37c21730442b00ba3d64201d14304420442d11f7298c133704bb246b38a0442b3060442044204420442626a044204420442
044204424396314b4339435c0442044252810442044204420442044203530442044204425046307a6292629fa241a24ef28233080155b17a905560599055205a
0442044204420442044204420442044204420442044204420442044204420442f3420442e34204420442044261420442d0420442d0420442d0420442d0420442
d0420442d0420442d0420442d0420442d0420442d0420442d0420442d0420442d0420442d0420442d04204425142044204420442044204420442044204420442
04420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442
04420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442044204420442
10000000111111111000000011111111111111111111000011110000100000006565656500000000555555551111111111111111331313131313131313131313
11000000011111110100000001111111111111111111000011110000110000005555555566606660555555551111111111111111313131313131311131313131
11100000001111111000000000111111111111111111000011110000111000006666666666616661555555551111111111111111131313131311131113131313
1111000000011111010000000001111111111111111100001111000011110000666566656661666166656665ddd1ddd111111111313131313131311131313131
1111100000001111101000000000000000000000000000001111000011110000666566656661666166656665ddd1ddd111110000333313131313131313131313
11111100000001110100000000000000000000000000000011110000111100006665666501110111555555551111111111110000333131313131311331313131
1111111000000011101000000000000000000000000000001111000011110000655565550000d0d0555555551111111111110000331313131113111313131313
11111111000000010100000000000000000000000000000011110000111100006666666600000000555555551111111111110000313131313131113331313131
__gff__
0011f009000000000040440000000000000000000066000000a00000800000000000000000000000000033333333110000000000cc0c0000000000e0eeeeee0e00000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000660000c0cccc0c00000000000000006600000030333300000077707700000000000000ff11ff0f00ee00000030030000003303000000cc0c00000010110060ff0e000000000000000000000000000020909f00001011
__map__
56fffd56ff57565656564756565656ff5555555555006061006061006200620000000062616162000000006200000062005e6278444478626278444478625e00606100000000606100000060610000006f5d6f787777777777777777787f5e7f0000000000000000445244404144524444525252525252444440414041404144
57ff5656565648fffe5748564757ffff5560726155006370006370007200720055550072645e72005555007261686072004f556f5d5d5f55556f5d5d5f554e62645e62000062645e620062645e6200006f5d6f787855787272785578787f5e7f00000000000000001b1a1b1e1f1a1b1a00000000000000001b1e1f1e1f1e1f1a
56575656565656fffdff56565648ff565555555555f06371f06061f063f063f06868f7725d5572f06868f76370f06370f04f556f70707f55556f70707f554e72587672000072587672007258767200006ffb6f5d5e5e5e5e5e5e5e5e5e7ffa7f0000000000000000393a393a393a393a0000000000000000393a393a393a393a
565656565656fffe5648fffeff48565673706770715df15d5d63705d735d735d6868f6726161725d6868f662615d60625d5e556f70707f55556f70707f555e73606171000073606171007360617100006f5d6ffb5efa5e5e5e5efa5efa7f5e7f00000000000000001819181c1d1918190000000000000000181c1d1c1d1c1d19
fd565756ff5656fd5647ffffffff56ff735d5d5d715d6061006371f0f15df15d5555f6637070705d5555f672705d63725d5e556f70707f55556f70707f555e63736770f00063736770f063736770f0006f5d6f5d5e5e5e5e5e5e5e5e5e7f5e7f00000000000000001b1a1b42431a1b1a00000000000000001b1e1f42431e1f1a
4756565756ffff56fd475657fe56ff56f15d745d5d5d637000f15d5d550055007878f6637171705d7878f66370f06363f04e556f70707f55556f70707f554f736370715df7736370715d716370715df76f5d6f5d5e5e5e5e5e5e5e5e5e7f5e7f0000000000000000393a393a393a393a0000000000000000393a393a393a393a
56ff4756fffdfeff56ff56feffff5756765e655e76006371f000000078f778f7f3f4f5f15d5d5d5df3f4f5635d5df1635d4e556f70707f55556f70707f554ff173715d5df6f173715d5df673715d5df66f5d6f5d5e5e655e5e655e5e5e7f5e7f00000000000000001819181c1d1918190000000000000000181c1d1c1d1c1d19
565756475647ff56ffff56fe56565656765e655e7600f15d5d000000f3f5f3f50000005757575757575757f15d6800f15d5e7278444478727278444478725e00f15d5dfcf500f15d5dfcf5f15d5dfcf56f5d6f5d5e5e655e5e655e5e5e7f5e7f0000000000000000445244505144524444525252525252444450515051505144
565657ffff565756ff47ff48ffff5656765e655e767777777777777777777777777700777777000000606161610060620060610062006200620062005555000000f3f4f5000000f3f4f50000f3f4f5006f5d6f5d5e5e5e5e5e5e5e5e5e7f5e7f4400000000000044440000000000004400000000000000000000000000000000
5657ffff5657ff4756fe4756fffd56fe765e655e765e5e5e5e5e5e5e5e5e5e5e5e5e785d745d786200636666700063720063700072007200720072005555f760f855f861000060f855f86100005556556f5d6f5d5e5e5e5e5e5e5e5e5e7f5e7f5300000000000053534452454552445300001b1a1b1a000000001b1a1b1a0000
5756ffff5656ffff5656ffff56ff57565e5e655e5e77777777777777777777777777005e655e00720063717170f06072f05555f063f063f063f063f07371f672645e5e720000636255627000005f567d6f5d6f5d5efa5e5e5e5efa5e5e7f5e7f530000000000005353531b1e1f1a53530000393a393a00000000393a393a0000
fe5656ff56ffff56ffffff57575756565e5e655e5e785d5d5d785d745d785d5d5d78005e655e0072f0f15d5d5d5d63705d60615d6062615d6362635df3f4f572586256720000637268727000007f56646f5d6f5d5e5e655e5e655e5e5e7f5e7f530000000000005353451d1c1d1c455300401d1c1d1c410000401d1c1d1c4100
5657fffffffffdff56ff56ff4857ffff765e655e7600000000005e655e0000000000005e655e00635d606161610060615d6061006372705d6072615d55550072586356720000637268727000007f566f6f5d6f5d5e5e655e5e655e5e5e7f5e7f530000000000005353451f42431e455300501f1e1f1e510000501f42431e5100
56564848ffff56ff4756575656fe4857765e655e7600000000005e655e0000000000005e655e00635d636666700063675d6370f0636370f0636770005555f760f855f861f0006055555561f0007f566f6f5d6f5d5e5e655e5e655e5e5e7f5e7f53000000000000535353181c1d1953530000393a393a00000000393a393a0000
56ff47565656fe5656565656ff4748ff007e7e7ef200000000005e655e0000000000005e655e00f15d63717170f07371f063715df1635d5d637170f07371f663666766705df063f872f8705df07f566f6ffb6f5d5e5e655e5e655e5e5e7ffa7f5300000000000053534452454552445300001819181900000000181918190000
47565656ffff5656ffff565756feff4800787878f200000000005e655e0000000000005e655e000000f15d5d5d5df15d5df15d5d00f15d00f15d5d5df3f4f563667866705d5d63666766705d5d7f567d6f5d6ffb5e5e655e5e655e5efa7f5e7f4400000000000044440000000000004400000000000000000000000000000000
56ffff575656ffff56ff56ff56565757f9f900f9f9004e4ef94e4e0068f968f900f9f900f9f900556f5f5e5e5e4e550060610060610060610062006200620063667866705d5d63667066705d005556556f655e5e5e5e5e5e5e5e5e5e5e5e657f0000445252440000000000000000000000404126264041000000000000000000
5756ff5656575656fe5656484757ff566868006868004e4ef94e4e000000000000555500555500556f7f5e675e4f550063700063700063700072f063f072f063665d66705d5d63667066705d005f567d6f655e5e5e5555555555555e5e5e657f00005300005300001b1a000000001b1a1b1e1f1a1b1e1f1a00001b1a1b1a0000
18191819181918191819181918191819f9f900f9f9004e4e004e4e0068f968f9005570f76355f70000f80000f80000606171606171606171f060615560615df15d5d5d5d5d5df16670665d5df07f565e6f655e444455555555555544445e657f4452455555455244393a26444426393a393a393a393a393a2644393a393a4426
1b262626261b26261a1b2626261a1717000000000000000000000000000000000063fcf5f363f6556563000063655563705d63675d63705d5d63706770705d00f15d5d5d5d5d00f15d5d5d5d5d5556556f5e5e44445545645e45554444645e7f5300556868550053181c444041441d1918191819181918190053181c1d195300
2317231b192326002323172323231717f9f900f9f900f9f900f9f900f9f9f9f90055f5f90055f5556573f0007375556371f06371f06371f00063717071705d787878787878780000f3f4f4f5007878786f5e55555555645d785e555555555e7f53005568685500531b1e445051441f1a1b1a1b1a1b1a1b1a00531b42431a5300
18261926262626261826261923182626686800686800f9f90000f900f96868f9005555005555f75e657d5d5e7d745ef15d5df15d5df15d5d00f15d5d5d5d5d5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e6f5e555555555d68687855555555647f4452455555455244393a26444426393a393a393a393a393a2644393a393a4426
1b1a1b1a1b1a1b1a1b1a1b1a1b1a1b1af9f900f9f900f90000f9f900f96868f9006371f77370f6fa67fafafafa67fafafafafafafafafafafafafafafafafafafafafafafafafafafafafafafafafafa6f5e6344445545686845554444705d7f00005300005300001819000000001819181c1d19181c1d190000181918190000
77777777777777777777777777777777787878787878787878787878f9f9f9f900f3f4f5f3f4f55e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e6f5e7d444455555555555544445d5d7f0000445252440000000000000000000000505126265051000000000000000000
606100655e5e654455554400f7f200006f6f5d777777777777777777775d7f7f6f6f5d777777777777777777775d5f7f6f655e5e5e5e5e5e5e5e5e5e5e5e657f565856565858575756565657565658566f5e5e637855555555555578705d5e7f0000000000000000000000404100000000000000000000000000004041000000
72720065686865555d5d55f7f600f2006f6f446f5d5d5d44445d5d5d7f447f7f6f6f446f5d5d5d44445d5d5d5f447f7f6f655e5e5e5e5e5e5e5e5e5e5e5e657f565657565656565856585656575756566f655e7d5d6378787878705d5d5d657f00001b1a0000000000001b42431a0000000000001b1a000000001b42431a0000
6366756568686555747455f6f6f2f2005e6f446f65786544447478657f447f5e6f6f446f65786544447478657f447f7f77655e5e5e5e5e5e5e5e5e5e5e5e65775e56585757585656565656585656565e6f655e5e5e7d5d5d5d5d5d5d5e5e657f0045393a525252440045393a393a524444525252393a45004452393a393a4500
637074655e5e6555747455f6f6f2000078645e6f65676544447467657f5e5e786f77776f65676544447467657f77777f6f77775e5e5e5e5e5e5e5e5e5e77775f78645e565656565658565756565e5e786f655e5e5e5e5e5e5e5e5e5e5e5e657f0023181c4100002300401d1918190023230000401d19230023001819181c4100
f15d74655e5e6544555544f6f600f200787878645e5e5e5e5e5e5e5e5e7878786f6f5d777777777777777777775d5f7f6f6f5d777777777777777777775d5f7f787878645e5e5e5e5e5e5e5e5e7878786f655e5e5e5e5e5e5e5e5e5e5e5e657f00231b1e5100002300501f1a1b1a0023230000501f1a230023001b1a1b1e5100
68fa686568686573717171f6f6f20000587878787878787878787878787878586f6f446f5d5d5d5d5d5d5d5d5f447f7f6f6f44555d5d5d72725d5d5d55447f7f687878787878787878787878787878686f655e5e5e5e5e5e5e5e5e5e5e5e657f0045393a525252440045393a393a524444525252393a45004452393a393a4500
65676565686865f3f4f4f4f5f500f200565858565656575658565658565856566f6f446f7e6668666668667e7f447f7f6f6f4455746265727274626555447f7f6f745d5d5d5d5d5d5d5d5d5d5d5d745f6f655e5e5e5e5e5e5e5e5e5e5e5e657f00001819000000000000181c1d19000000000000181900000000181c1d190000
68fa68655e5e65f3f4f4f4f4f4f4f400565657575656565656565756575756566f77776f7e6668666668667e7f77777f6f77775574637572727463755577777f6f655e5e5e5e5e5e5e5e5e5e5e5e657f6f655e5e5e5e5e5e5e5e5e5e5e5e657f0000000000000000000000505100000000000000000000000000005051000000
__sfx__
000100002067017370123700f3700b370093700737005370043600335002340013300132020630173300e3300a330073300532003320023100031000310000000000000000000000000000000000000000000000
000100002d640143702b6201237011370103700f3600e3600d3500c3500b3400a340093302b620133302961011320103200f3200e3200d3100c3100b3100a31009310083100c300113000c300113000c30011300
010300200c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c3300c3301c330
010300200c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c330113300c33011330
010300200c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c330123300c33012330
010200002067017370123600f35000450004500045000450004500045000450004500045000450004500045000450004500045000450004500045000450004500045000450004500045000440004300042000410
011000182973524735217351d73521735247352973524735217351d73521735247352973524735217351d73521735247352973524735217351d73521735247350000000000000000000000000000000000000000
0180002005e7505e7507e7507e7509e7507e7505e7504e7505e7505e7507e7507e7504e7504e7504e7504e7505e7505e7507e7507e7504e7504e7505e7505e7500e7500e7502e7502e7504e7504e7504e7504e75
018000200ce720ce720ee720ee7210e720ee720ce720be720ce720ce720ee720ee720be720be720be720be720ce720ce720ee720ee720be720be720ce720ce7207e7207e7209e7209e720be720be720be720be72
010e00001a83316635024050e6251a833024051d625024051a83316635024050e6251a833024051d625024051a83316635024050e6251a833024051d625024551a83316635024550e6251a833024551d62502455
011c0000245471f5371d527265171f50010323159250c3231d6052d6250c925396151d5501d5451f5501f54223500235002350023500100001c600100001c600245001f5001d5002610010000150001c60034600
011c000021a6021a5221a4221a2021a1021a0021a001ca05184061343618416134060c5500c5450e5500e54218500175001550013500115000e500115001a5001a5001850018500185002b500245002b5001a500
010e00201a83316635024550e6251a833024551d625024551a83316635024550e6251a833024551d625024551a83316635024550e6251a833024551d625024551a83316635024550e6251a833024551d62502455
011c000021540215451d5451f5401f5401f5421f5451c635245371f5271d517261072454024540245452354023540235402354223545100231c635100231c635245371f5271d5172610710023150001c63534605
011c000011540115450c5450e5400e5400e5420e54500000131001843613416181001554015540155451354013540135401354213545000001c423000001043313100184361341618100000001f4231042310503
011c002018560175601556013560115600e5601156013560135621c546135161c5061f506185361f5160e56018560175601556013560115600e560115601a5601a5621856018562185652b506245362b5161a506
010e002029522117452b52213745265220e745245220c74529522117452b52213745265220e745245220c74529522117452b52213745265220e745245220c74529522117452b52213745265220e745245220c745
011c000024a6024a5224a3224a1034735347151da6024a6024a6024a5224a3224a1034735347151da6024a6024a6024a5224a3224a1034735347151da6024a6024a2025a6025a2226a6226a2227a6227a2226a60
011c000026a6026a5226a3226a1036735367151da6026a6026a6026a5226a3226a1036735367151da6026a6026a6026a5226a3226a1036735367151da6026a6026a2025a6025a2224a6224a2223a6223a2222a60
011c00000754504547025450554530525025450454502545075450454702545055453052502545045450554507545045470254505545305250254504545025450754505547045450254504545055450654507545
011c00000954506547045450754532525045450654504545095450654704545075453252504545065450754509545065470454507545325250454506545045450954507547065450454506545055450454503545
0110001c188331d023286252461518833246151d0232862518833286252461518833286251d023188331b0232862524615188331b02324615286251883324615286251b02318833286250c003075002960507700
0120001c0545505155114550f1550c4550a455084550445504155104550d1550a455084550745503455031550f4550c1550a455084550745501455011550d4550a15508455074550645500000000000000000000
011c0000140361d036180361b036140361d036180371b036160361f036190361c036160361f036190371c03618036200361b0361d03618036200361b0371d03619036220361c0361f03619036220361c0371f036
012000200ed500ed520ed50000000ed500ed520ed50000000ed500ed520ed50000000ed500ed520ed50000000ed500ed520ed50000000ed500ed520ed50000000ed500ed520ed50000000ed500ed520ed5000000
0140000025b4025b4225b3225b2022b4022b4222b3222b2029b4029b4229b3229b2026b4026b4226b3226b202ab402ab422ab322ab2027b4027b4227b3227b2028b4028b4228b3228b2029b4029b4229b3229b20
014000001dc401dc421dc321dc201ac401ac421ac321ac2021c4021c4221c3221c201ec401ec421ec321ec2022c4022c4222c3222c201fc401fc421fc321fc2020c4020c4220c3220c2021c4021c4221c3221c20
0110001811d50176350545518950054550545511d501763511d5018950176351763511d50176350545518950054550545511d501763511d501895007440074450000000000000000000000000000000000000000
011000180fd5017635034551894003455034550fd50176350fd501894017635176350fd5017635034551894003455034550fd50176350fd501894005440054450000000000000000000000000000000000000000
0110001821565215351d5651f5601f5601f5621f5621f5651f53522560225652256521565215351d5651f5601f5601f5621f5621f5651f5353572535715357050000000000000000000000000000000000000000
011000181f7701f7601f7521f7321f7151f7321d7701d7601d7521d7321d7151d7322177021760217522173221715217321d7701d7601d7521d7321d7151d7320000000000000000000000000000000000000000
011000181b7701b7601b7551d7701d7651d7751f7701f7601f7551d7701d7601d7521d7421d7351d7321d7221d7150000024b3024b10357253571500000000000000000000000000000000000000000000000000
011000181b7701b7601b7521b7321b7151b7221d7701d7601d7521d7321d7151d7221f7701f7601f7521f7321f7151f7221d7701d7601d7521d7321d7151d7220000000000000000000000000000000000000000
011000182177021760217551d7701d7651d7751b7751b7651b7551d7701d7601d7551b7701b7601b7551a7701a7601a7551877518765187551677016760167550000000000000000000000000000000000000000
011000183572535715185601856018560185651856218565185351a5601a565185651b5601b5651b5351a5601a5651a5351856018565185351656016565165350000000000000000000000000000000000000000
0110001815565165651856511560115650f5600f5650f5351556015560155651553528b4028b201656016560165651653529b4029b20175601756017565175350000000000000000000000000000000000000000
011000181556516565185651b5601b5651f5601f5651f5351d5601d5601d5651d53530b4030b201b5601b5601b5651b5352eb402eb201a5601a5601a5651a5350000000000000000000000000000000000000000
010c000022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b3022b30
010c000021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b3021b30
010c000024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b3024b30
000200003a7400f1300f6101b32000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000206501d4501a6501845014650111500e6500d1500b6500915006650051500365003150026500264001640013300132001220012100000000000000000000000000000000000000000000000000000000
000800003a7502c650083501d6501b6501865017650166501565014650136501265011650106500f6400e6400d6400c6400b6400a640096300863007630066300563004630036200362002620026100161001610
00040000137502135018750233501c750253502075027350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000a650020503b3400934014630083300c6200a320036100c310017003b6003b6003a6003a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000393702f6700056026660005501e6500054016640005300f630005300a6200052007620005200561000510036100051002610005100161000000000000000000000000000000000000000000000000000
000200002c03023020170200d030390503a0402c3002a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001965034270033503423000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000400024100442006430084400a4500c4600e4700001002020020200a430084400a4400d020094400000001400014000d460084600d4600d4200d46000400024100442006430084400a4500c4600e470
0010000000400024100442006430084400a4500c4600e4700001002020020200f430084400a4400d020094400000001400014000d030084600d4600d4200d46000400024100442006430084400a4500c4600e470
001000000040002410084200d430080700f4500c4600e4700040002410044200d430084400a4500c4600e47000400014100d4200d43008030074500c4600e4700040001410034200d430084500a4500c4600e470
0010000000000014000240005460080400d4600d4200d46000000014000240005460080200d4600d4200d4600000000400014000d460084600d4600d4200d4600000000400014000d460084100d4600d4200d460
0010000000400024100842006430080700f4500c4600e47000400024100440005030084400a4500c4600e4700040002410024200643008460064500c4600e47000400024100142006430084100b4500c4600e470
0010000000400024100442006430084400a4500c4600e470004000140001400014000140001400014000140007070080700804008040080400804008040080400804008040040200402004020020100201002010
001000000040001400020100202004020100400800210410004000241001010034000241001010034000240000000000000403008410034100000000000000000000000000080601001002010080011002008000
0010000001430084400a4500c4021c4611e47120402154211542115421164310201002010060300743008040090500e0700e0700e011134111341114021140212643200000240410b02222412224121845024000
0010000001400014000140001462090500b0600d07001400014000140007040010711f002024020301204412050301802117421164411a4511c46110401124112f003000002e0322704224422290522b4702c000
001000000040001400014000140038147381473814701400014000140010041020100201006030014000402004410200022000220030034100341004020040200100100000381033000330003300033000330000
00100000000000000000000000001c0611c0611c0500804008040080400a0500804008040080400804008040080400a0500a0500a050080400804008040080400804000000000500a0500a0500a0500a0500a000
0010000000000000000000000000080400804008050080400804008040080400804008040080400804008040080400a0500a0500a050080400804008040080400804000000000400804008040080400804008000
00100000000000000000000000262412624126241260201002010020101404202010020100a050014000402004410060300603006030020100201001400014000102100000000422804228042280422804228000
0010000008020000400241001010064200703008020000402d43412005125341200725463140441a5631404724073180441b173180472d42412045125241204635024180050a1241800738033140030713314001
001000002a4531b044155531b047310631b0050e1631b00736434180440a5341804736433180530a533180300000000000000000000000000000000000000000080400803006030040400c0500e4400d43004450
0010000001420054200341005420054200542030003080403f5773f5773f1043f1043f57700104001043f577001040010400104001043d4143f4043a034081050106314010020100201002010020100140002010
__music__
01 09 0a 0b 44
00 0c 0d 0e 44
00 0c 0d 0e 44
00 0c 0f 10 44
00 0c 0f 10 44
00 0c 0d 0e 44
00 0c 0d 0e 44
00 0c 0f 10 44
00 0c 0f 10 44
00 0c 11 13 44
00 0c 12 14 44
00 0c 11 13 44
02 0c 12 14 44
03 15 16 17 44
03 18 19 1a 44
01 1b 1d 06 26
00 1c 1d 06 25
00 1b 1d 06 27
00 1c 1d 06 25
00 1b 1e 06 26
00 1c 1f 06 25
00 1b 20 06 27
00 1c 1f 06 25
00 1b 1d 06 26
00 1c 1d 06 25
00 1b 1d 06 27
00 1c 1d 06 25
00 1b 1e 06 26
00 1c 1f 06 25
00 1b 20 06 27
00 1c 21 06 25
00 1c 22 06 25
00 1b 23 06 27
00 1c 22 06 25
00 1b 24 06 27
00 1c 22 06 25
00 1b 23 06 27
00 1c 22 06 25
02 1b 24 06 27
03 07 08 18 44
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
