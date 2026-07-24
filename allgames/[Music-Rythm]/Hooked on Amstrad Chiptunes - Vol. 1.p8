pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--amstradchips1
--carlc27843
function mkzt(n) local t={}for i=1,n do add(t,0) end return t end

ayvols={
 0,
 0.01,
 0x.03b3,
 0x.0564,
 0.0307,
 0x.0ba9,
 0.0645,
 0x.1b7c,
 0x.2068,
 0x.347a,
 0.2922,
 0x.5f72,
 0x.7e16,
 0x.a2a5,
 0x.ce3b,
 1
}

local adjbuf,adjpos,adjsum
function ayupdate(ay,wts)
 local aynoise=ay.noise
 aynoise.counter+=wts
 aynoise.bit^^=(aynoise.counter/aynoise.period)&1
 aynoise.counter%=aynoise.period

 local r=aynoise.rng
 r^^=((r&0x.0001)^^(r>>3&0x.0001))<<17
 r>>=1
 aynoise.rng=r
 local nb=r&aynoise.bit

 local vadj=adjsum/(2*256)
  
 local s=0
 for i=1,3 do
  local chn=ay.chns[i]
  if chn.period==0 then
   chn.bit=1
   chn.counter=0
  else
   chn.counter+=wts
   chn.bit^^=(chn.counter/chn.period)&1
   chn.counter%=chn.period
  end

  -- mix channel volumes
  local cnd=chn.noise_disable
  local v=((chn.bit)&(nb|cnd)==0) and chn.volume or 0
  s+=v

  -- oscilloscope view
  local obit=chn.obit
  chn.obit=chn.bit&(aynoise.bit|cnd)
  if(obit!=chn.obit)chn.lz=chn.osci
  local col=cnd!=0 and chn.col or 2
  local oi=(chn.osci&1023)+1
  chn.oscv[oi]=((v-vadj)&0xffff.ff)|(col>>16)
  chn.oscz[oi]=chn.lz*2+chn.bit
  chn.osci+=1
 end
 s=s*ay.mvol

 -- move offcenter signal to zero-line
 adjsum+=s-adjbuf[adjpos]
 adjbuf[adjpos]=s
 adjpos=(adjpos&255)+1
 s-=adjsum>>8
 return mid(s,-1,1)
end

function ayvol(v)
 ay.mvol=v*2/3
end

function ayinit()
 local newchn=function() 
  return {
   period=0,counter=0,volume=0,bit=0,noise_disable=1,
   osci=0,oscv=mkzt(1024),oscz=mkzt(1024),lz=0,col=0,obit=0} 
 end
 ay={noise={period=1,counter=0,bit=0,rng=1>>15}}
 ay.chns={newchn(),newchn(),newchn()}
 ayvol(1)
 adjbuf=mkzt(256)
 adjpos=1
 adjsum=0
end
local wtss={22.6778,40.2179}
local wtupds={488.2812,865.9409}

function sndlaunch(chni,subi)
 local cmda=%(dr.subs+2*subi)
 if @cmda==241 then
  cmda+=1
  chni=@cmda
  cmda+=1
 end
 local pri=10
 if @cmda==240 then
  cmda+=1
  pri=@cmda
  cmda+=1
 end
 if chni>3 then
  if dr.chns[1].pri==0 then chni=1
  elseif dr.chns[2].pri==0 then chni=2
  else chni=3
  end
 end
 local chn=dr.chns[chni]
 if(pri<chn.pri)return
 chn.pri=pri&127
 chn.a=cmda
 chn.reta=cmda
 chn.cmda=chn.reta
 chn.d=1
 chn.v=0
 chn.pd=0
 chn.pt=0
 chn.tt=0
end

function envreset(env)
 env.e=%(dr.envs+2*env.q)
 env.a=env.e
 env.d=0
 env.c=0
end

function envstep(env)
 env.d+=1
 if(env.d!=@env.a)return 0
 local v=@(env.a+1)-128
 env.d=0
 env.c+=1
 if env.c==@(env.a+2) then
  env.c=0
  env.a+=3
  if(@env.a==255)env.a=env.e
 end
 return v
end

function playnote(chn,p,d)
 chn.p=p
 chn.d=d
 chn.sd=d
 chn.t=%(dr.pitches+2*p)
 chn.v=0
 envreset(chn.venv)
 envreset(chn.penv)
 if chn.ne!=0 then
  chn.ne=0
  envreset(dr.nenv)
  chn.ay.noise_disable=chn.ond
 else
  chn.ay.noise_disable=1
 end
 chn.ay.col=0
end

local rng2t={
 0,3,5,7,10,7,10,12,15,17,12,15,17,19,22,12,
 15,17,19,22,19,22,24,27,29,31,34,24,27,29,0,0 }

function sndchnstep(chn)
 if(chn.pri==0)return
 chn.d-=1
 local i=20
 while chn.d==0 do
  i-=1 if(i==0)break
  local p,d=peek(chn.a,2)
  chn.a+=2
  if p==0 then
   playnote(chn,p,d)
   break
  elseif p<6 then
   sndlaunch(p,d)
  elseif p<101 then
    playnote(chn,p+chn.pd,d)
    break
  elseif p<128 then
    chn.a-=1
    dr.nt=p-101
    chn.ne=1
  elseif p<229 then
    chn.a-=1
    p&=127
    if(p!=0)p+=chn.pd
    playnote(chn,p,chn.sd)
    break
  elseif p==229 then
   chn.pri=0
   chn.v=0
   chn.t=0
   return
  elseif p==238 then
   dr.rng*=41
   dr.pr=(dr.rng>>8&d)+1
  elseif p==239 then
   dr.rng*=21
   dr.pr=rng2t[(dr.rng>>8&d)+1]
  elseif p==230 then
   playnote(chn,chn.pd+dr.pr,d)
   break
  elseif p==231 then
   dr.nt=d
   chn.ne=1
  elseif p==232 then
   chn.reta=chn.a
   chn.a=%(dr.subs+2*d)
  elseif p==233 then
   chn.pd=d
  elseif p==234 then
   chn.venv.q=d
  elseif p==235 then
   chn.penv.q=d
  elseif p==236 then
   dr.nenv.q=d
  elseif p==237 then
   chn.pt=d
  elseif p==243 then
   dr.h=d
  elseif p==242 then
   chn.a=chn.reta
   chn.reta=chn.cmda
  elseif p==244 then
   chn.a-=1
   chn.p=0
   chn.d=1
   chn.t=0
   break
  elseif p==245 then
   for i=1,3 do
    dr.chns[i].ond=(d>>(2+i))&1
   end
  end
 end
 -- process chn note
 chn.v+=envstep(chn.venv)
 if chn.t!=0 then
  if chn.pt==0 then
   chn.t+=envstep(chn.penv)
  else
   chn.tt^^=1
   chn.t=%(dr.pitches+2*(chn.p+chn.tt*chn.pt))
   chn.ay.col=chn.tt
  end
 end
end

function sndupdate()
 local chn1,chn2,chn3=unpack(dr.chns)
 -- process commands and note
 sndchnstep(chn1)
 sndchnstep(chn2)
 sndchnstep(chn3)
 -- process noise
 local nt=dr.nt+envstep(dr.nenv)&dr.ntmsk
 if nt>=dr.ntlim then
  chn1.ay.noise_disable=1
  chn2.ay.noise_disable=1
  chn3.ay.noise_disable=1
  nt=dr.nt
 end
 dr.nt=nt
 dr.ay.noise.period=nt>0 and nt or 1
 -- process overtone
 local h=dr.h
 if h!=8 then
  local hd=(h&15)-8
  local hm=h\32+1
  if h&16!=0 then
   chn3.t=chn1.t*hm+hd
  elseif chn3.pri==0 then
   local t=chn2.pri!=0 and chn2.t or chn1.t
   if t!=0 then
    chn3.t=t*hm+hd
    chn3.v=chn2.v
   end
  end
 end
 -- set ay regs
 for chn in all(dr.chns) do
  chn.ay.period=max(chn.t,0)
  chn.ay.volume=ayvols[1+(chn.v&15)]*dr.vol
 end
 return dr.wtupd
end

function sndinit(addr,ay)
 local newenv=function()
  local env={q=0}
  envreset(env)
  return env
 end
 local newchn=function(i)
  return {id=i,pri=0,p=0,t=0,v=0,penv=newenv(),venv=newenv(),ne=0,ond=0,ay=ay.chns[i]}
 end
 local hw=@(addr+8)
 dr={ay=ay,
  wts=wtss[hw],
  pitches=addr+9,
  envs=%addr,
  subs=%(addr+2),
  wtupd=wtupds[hw]/(@(addr+4)>>8),
  ntmsk=@(addr+5),
  ntlim=@(addr+6),
  vol=@(addr+7)/255,
  rng=0x28b2,
  nt=0,
  h=8}
 dr.nenv=newenv()
 dr.chns={newchn(1),newchn(2),newchn(3)}
 sndlaunch(1,0)
end
-- px9 https://www.lexaloffle.com/bbs/?tid=34058
function px9_decomp(x0,y0,src,vget,vset)
 local function vlist_val(l, val)
  local v,i=l[1],1
  while v!=val do
   i+=1
   v,l[i]=l[i],v
  end
  l[1]=val
 end
 local cache,cache_bits=0,0
 function getval(bits)
  if cache_bits<16 then
   cache+=%src>>>16-cache_bits
   cache_bits+=16
   src+=2
  end
  local val=cache<<32-bits>>>16-bits
  cache=cache>>>bits
  cache_bits-=bits
  return val
 end
 function gnp(n)
  local bits=0
  repeat
   bits+=1
   local vv=getval(bits)
   n+=vv
  until vv<(1<<bits)-1
  return n
 end
 local w,h_1,eb,el,pr,x,y,splen,predict=
  gnp"1",gnp"0",gnp"1",{},{},0,0,0
 for i=1,gnp"1" do
  add(el,getval(eb))
 end
 for y=y0,y0+h_1 do
  for x=x0,x0+w-1 do
   splen-=1
   if(splen<1) then
    splen,predict=gnp"1",not predict
   end
   local a=y>y0 and vget(x,y-1) or 0
   local l=pr[a]
   if not l then
    l={}
    for e in all(el) do
     add(l,e)
    end
    pr[a]=l
   end
   local v=l[predict and 1 or gnp"2"]
   vlist_val(l, v)
   vlist_val(el, v)
   vset(x,y,v)
  end
 end
 return w,h_1+1,src-cache_bits\8
end

games={{a=1525,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY cHRIS wOOD - GAME BY jUKKA tAPANIMAKI (c64) AND cHRIS wOOD (cpc) - (C) 1988 hewson',dbglc=318,dis=split"13,15,15,2,2,12,11,1,10,10,8,14,2,2,0",l=1408,n='netherworld',pal=split"1,2,3,4,5,6,7,8,9,-15,-13,12,13,-8,-3"},{a=1121,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY sTEVE cROW AND mARK jONES - GAME BY mICHAEL cROUCHER AND dOMINIC rOBINSON - (C) 1987 hewson',dbglc=644,dis=split"11,14,3,10,10,6,12,15,1,9,8,13,2,2,0",l=3584,n='zynaps',pal=split"1,2,3,4,5,6,7,8,-15,-13,11,12,-8,-5,-4"},{a=910,c='COMPOSED BY sTEVE tURNER - ARRANGED BY dAVE rOGERS - GRAPHICS BY aNDREW bRAYBROOK - GAME BY aNDREW bRAYBROOK (c64) AND nEIL lATARCHE (cpc) - (C) 1987 hewson',dbglc=233,dis=split"5,15,9,11,2,6,12,13,1,3,8,10,2,2,0",l=1280,n='uridium',pal=split"1,2,-15,-10,-9,6,7,8,9,-8,-7,12,-4,-1,15"},{a=1419,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY rAFAELLE cECCO - GAME BY rAFAELLE cECCO - (C) 1988 hewson',dbglc=436,dis=split"12,15,1,5,5,11,10,9,14,6,8,13,2,2,0",l=2048,n='cybernoid',pal=split"1,2,3,4,-15,-12,7,8,9,10,-9,12,-8,-7,-4"},{a=1098,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY hUGH bINNS - GAME BY rAFAELLE cECCO - (C) 1988 hewson',dbglc=472,dis=split"12,10,9,14,6,11,15,3,5,5,8,13,2,2,0",l=2048,n='cybernoid2',pal=split"1,2,3,4,-13,-12,7,8,9,10,11,-9,-8,-7,-5"},{a=1108,c='COMPOSED BY jOHN m pHILLIPS - ARRANGED BY dAVE rOGERS - GRAPHICS BY cHRIS wOOD - GAME BY jOHN m pHILLIPS (c64) AND cHRIS wOOD (cpc) - (C) 1988 hewson',dbglc=380,dis=split"12,15,1,5,5,11,14,3,7,7,10,9,13,8,0",l=1472,n='nebulus',pal=split"1,2,3,4,-15,6,-13,-12,9,10,11,12,-7,-5,-4"},{a=1210,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY rORY gREEN - GAME BY cASEY bEE gAMES - (C) 1988 hewson',dbglc=227,dis=split"13,15,15,2,2,11,10,9,14,7,8,12,2,2,0",l=1344,n='marauder',pal=split"1,2,3,4,5,6,-12,8,9,10,-9,-8,13,-7,-3"},{a=1275,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY hUGH bINNS - GAME BY rAFAELLE cECCO - (C) 1989 hewson',dbglc=1019,dis=split"12,15,1,4,4,7,6,13,5,11,10,9,14,8,0",l=2240,n='stormlord',pal=split"1,2,3,-15,5,6,7,-12,9,10,-11,12,-10,-7,-4"},{a=1311,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY mARK wASHBROOK - GAME BY rAFAELLE cECCO - (C) 1990 hewson',dbglc=762,dis=split"15,10,9,9,11,13,14,5,12,1,8,2,2,2,0",l=1984,n='stormlord2',pal=split"1,2,-16,-15,5,6,7,8,9,10,-12,-11,13,-10,-9"},{a=911,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY jOHN cUMMING - GAME BY mICHAEL sENTINELLA (c64) AND mICHAEL cROUCHER (cpc) - (C) 1987 hewson',dbglc=221,dis=split"12,15,6,1,4,11,10,9,14,7,8,13,13,2,2",l=1152,n='anarchy',pal=split"1,2,3,-15,-14,-13,-12,8,9,10,-9,12,-8,-7,-4"},{a=1676,c='COMPOSED BY jEROEN tEL - ARRANGED BY dAVE rOGERS - GAME BY j wILDSMITH AND s wELLARD - (C) 1988 rack it/hewson',dbglc=196,dis=split"12,10,9,14,7,8,13,13,2,2,11,15,3,6,6",l=1920,n='battlevalley',pal=split"1,2,3,4,5,-13,-12,8,9,10,11,-9,-8,-7,-5"},{a=782,c='COMPOSED BY nIGEL gRIEVE - ARRANGED BY dAVE rOGERS - GAME BY sTEVEN cOLLINS (c64) AND dAVID wARD (cpc) - (C) 1987 rack it/hewson',dbglc=701,dis=split"11,10,9,14,4,9,14,8,12,2,8,12,12,2,2",l=3136,n='herobotix',pal=split"1,2,3,-12,5,6,7,8,9,10,-9,-8,13,-7,-3"},{a=1574,c="COMPOSED BY dAVE rOGERS - GRAPHICS BY jULIAN wOOD - GAME BY jIM gARDNER - (C) 1988 mIND'S eYE sOFTWARE/silverbird",dbglc=310,dis=split"12,13,5,1,3,8,10,10,2,2,9,15,11,4,7",l=1536,n='turboboat',pal=split"1,2,-15,4,-13,6,-12,8,9,-8,-7,12,-4,14,-2"},{a=1427,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY cHRIS wOOD - GAME BY cHRIS wOOD - PUBLISHED IN sINCLAIR uSER ISSUE 80: mEGATAPE 9',dbglc=330,dis=split"12,15,6,1,5,11,10,9,14,7,8,13,13,2,2",l=1984,n='bearagrudge',pal=split"1,2,3,4,-15,-13,-12,8,9,10,-9,12,-8,-7,-4"},[1]={a=1525,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY cHRIS wOOD - GAME BY jUKKA tAPANIMAKI (c64) AND cHRIS wOOD (cpc) - (C) 1988 hewson',dbglc=318,dis=split"13,15,15,2,2,12,11,1,10,10,8,14,2,2,0",l=1408,n='netherworld',pal=split"1,2,3,4,5,6,7,8,9,-15,-13,12,13,-8,-3"},[2]={a=1121,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY sTEVE cROW AND mARK jONES - GAME BY mICHAEL cROUCHER AND dOMINIC rOBINSON - (C) 1987 hewson',dbglc=644,dis=split"11,14,3,10,10,6,12,15,1,9,8,13,2,2,0",l=3584,n='zynaps',pal=split"1,2,3,4,5,6,7,8,-15,-13,11,12,-8,-5,-4"},[3]={a=910,c='COMPOSED BY sTEVE tURNER - ARRANGED BY dAVE rOGERS - GRAPHICS BY aNDREW bRAYBROOK - GAME BY aNDREW bRAYBROOK (c64) AND nEIL lATARCHE (cpc) - (C) 1987 hewson',dbglc=233,dis=split"5,15,9,11,2,6,12,13,1,3,8,10,2,2,0",l=1280,n='uridium',pal=split"1,2,-15,-10,-9,6,7,8,9,-8,-7,12,-4,-1,15"},[4]={a=1419,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY rAFAELLE cECCO - GAME BY rAFAELLE cECCO - (C) 1988 hewson',dbglc=436,dis=split"12,15,1,5,5,11,10,9,14,6,8,13,2,2,0",l=2048,n='cybernoid',pal=split"1,2,3,4,-15,-12,7,8,9,10,-9,12,-8,-7,-4"},[5]={a=1098,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY hUGH bINNS - GAME BY rAFAELLE cECCO - (C) 1988 hewson',dbglc=472,dis=split"12,10,9,14,6,11,15,3,5,5,8,13,2,2,0",l=2048,n='cybernoid2',pal=split"1,2,3,4,-13,-12,7,8,9,10,11,-9,-8,-7,-5"},[6]={a=1108,c='COMPOSED BY jOHN m pHILLIPS - ARRANGED BY dAVE rOGERS - GRAPHICS BY cHRIS wOOD - GAME BY jOHN m pHILLIPS (c64) AND cHRIS wOOD (cpc) - (C) 1988 hewson',dbglc=380,dis=split"12,15,1,5,5,11,14,3,7,7,10,9,13,8,0",l=1472,n='nebulus',pal=split"1,2,3,4,-15,6,-13,-12,9,10,11,12,-7,-5,-4"},[7]={a=1210,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY rORY gREEN - GAME BY cASEY bEE gAMES - (C) 1988 hewson',dbglc=227,dis=split"13,15,15,2,2,11,10,9,14,7,8,12,2,2,0",l=1344,n='marauder',pal=split"1,2,3,4,5,6,-12,8,9,10,-9,-8,13,-7,-3"},[8]={a=1275,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY hUGH bINNS - GAME BY rAFAELLE cECCO - (C) 1989 hewson',dbglc=1019,dis=split"12,15,1,4,4,7,6,13,5,11,10,9,14,8,0",l=2240,n='stormlord',pal=split"1,2,3,-15,5,6,7,-12,9,10,-11,12,-10,-7,-4"},[9]={a=1311,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY mARK wASHBROOK - GAME BY rAFAELLE cECCO - (C) 1990 hewson',dbglc=762,dis=split"15,10,9,9,11,13,14,5,12,1,8,2,2,2,0",l=1984,n='stormlord2',pal=split"1,2,-16,-15,5,6,7,8,9,10,-12,-11,13,-10,-9"},[10]={a=911,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY jOHN cUMMING - GAME BY mICHAEL sENTINELLA (c64) AND mICHAEL cROUCHER (cpc) - (C) 1987 hewson',dbglc=221,dis=split"12,15,6,1,4,11,10,9,14,7,8,13,13,2,2",l=1152,n='anarchy',pal=split"1,2,3,-15,-14,-13,-12,8,9,10,-9,12,-8,-7,-4"},[11]={a=1676,c='COMPOSED BY jEROEN tEL - ARRANGED BY dAVE rOGERS - GAME BY j wILDSMITH AND s wELLARD - (C) 1988 rack it/hewson',dbglc=196,dis=split"12,10,9,14,7,8,13,13,2,2,11,15,3,6,6",l=1920,n='battlevalley',pal=split"1,2,3,4,5,-13,-12,8,9,10,11,-9,-8,-7,-5"},[12]={a=782,c='COMPOSED BY nIGEL gRIEVE - ARRANGED BY dAVE rOGERS - GAME BY sTEVEN cOLLINS (c64) AND dAVID wARD (cpc) - (C) 1987 rack it/hewson',dbglc=701,dis=split"11,10,9,14,4,9,14,8,12,2,8,12,12,2,2",l=3136,n='herobotix',pal=split"1,2,3,-12,5,6,7,8,9,10,-9,-8,13,-7,-3"},[13]={a=1574,c="COMPOSED BY dAVE rOGERS - GRAPHICS BY jULIAN wOOD - GAME BY jIM gARDNER - (C) 1988 mIND'S eYE sOFTWARE/silverbird",dbglc=310,dis=split"12,13,5,1,3,8,10,10,2,2,9,15,11,4,7",l=1536,n='turboboat',pal=split"1,2,-15,4,-13,6,-12,8,9,-8,-7,12,-4,14,-2"},[14]={a=1427,c='COMPOSED BY dAVE rOGERS - GRAPHICS BY cHRIS wOOD - GAME BY cHRIS wOOD - PUBLISHED IN sINCLAIR uSER ISSUE 80: mEGATAPE 9',dbglc=330,dis=split"12,15,6,1,5,11,10,9,14,7,8,13,13,2,2",l=1984,n='bearagrudge',pal=split"1,2,3,4,-15,-13,-12,8,9,10,-9,12,-8,-7,-4"}}

local wt,sc

function serialupdate(n)
 local wts=dr.wts
 sc+=n
 n=sc\1
 for i=0,n-1 do
  if(wt<wts)wt+=sndupdate()
  local s=ayupdate(ay,wts)*127
  poke(17152+i,s+128)
  wt-=wts
 end
 serial(0x808,17152,n)
 sc-=n
end

function serialinit()
 wt=0
 sc=0
 for i=1,512,128 do serialupdate(128) end
end

function peekstr(a,len) local s=""for i=a,a+len-1 do s..=chr(@i) end return s,a+len end
function pokestr(s,a) for i=1,#s do poke(a+i-1,ord(s,i)) end end

function rominit(a)
 pokestr(binstr,a)
 for g in all(games) do
  g.audio,a=peekstr(a,g.a) 
  local w,h
  w,h,a=px9_decomp(0,0,a,pget,pset)
  g.logo=peekstr(0x6000,64*h)
 end
end

local gi,nextgi,gfade
function gameinit()
 gi=nextgi
 local g=games[gi]
 pokestr(g.logo,8192)
 pokestr(g.audio,12288)
 pal(g.pal,1)
 pal(g.dis)
 ayinit()
 sndinit(12288,ay)
 serialinit()
 local sp="                                "
 cred=g.c..sp.."ã/ë SWITCH GAMES"..sp.."CART BY @CARLC27843"
 credx=128
 gfade=0
end

local parts={}
local partsfree={}
local partsfreen

function _init()
 memset(0x5f10,0,16)
 poke(0x5f36,16)
 rominit(-#binstr)
 cls()
 for i=1,1120 do add(parts,{x=0,y=0,t=5,vx=0,c=0}) end
 for i=1,1120 do add(partsfree,parts[i]) end
 partsfreen=1120
 nextgi=1 gameinit()
 poke(0x5f2e,1) -- persist palette
end

function _update60()
 if(stat(108)<1024)serialupdate(91.8667)
 if gi==nextgi then
  if(btnp(0))nextgi=(gi-2)%#games+1
  if(btnp(1))nextgi=gi%#games+1
 else
  ayvol(1-gfade/8)
  gfade+=1
  if(gfade==8)gameinit()
 end
end

function _draw()
 -- cpc transition
 if gi!=nextgi then
  for a=24576+64*gfade,32767,512 do
   memset(a,0,64)
  end
  return
 end

 local g=games[gi]

 local a=0x6000
 local o=max(0,22-g.l\128)*64 
 memset(a,0,o)a+=o -- cls above logo
 memcpy(a,8192,g.l)a+=g.l -- logo
 memset(a,0,0x8000-a) -- cls below logo

 if(credx<-#cred*4)credx=128
 credx-=1
 print(cred,credx,123,5)

 for i=1,1120 do
  local p=parts[i]
  local pt=p.t+1
  if pt<5 then
   p.t=pt
   p.x+=p.vx
   p.y+=-2
   pset(p.x,p.y,p.c+pt)
  elseif p.t<5 then
   p.t=5
   partsfreen+=1
   partsfree[partsfreen]=p
  end
 end

 local y=64
 local hw=64
 for aychn in all(ay.chns) do
  local zi=aychn.oscz[((aychn.osci-hw)&1023)+1]
  if(zi&1>0)zi=aychn.oscz[((zi\2-1)&1023)+1]
  local zj=aychn.oscz[((zi\2-1)&1023)+1]
  local i=zi\2+(zj-zi)\4+hw
  for x=127,0,-1 do
   local vc=aychn.oscv[(i&1023)+1]
   local ny=y-(vc&0xffff.ff)*30\1
   local c=((vc<<16)&0xff)*5+1
   if x==127 then
    line(x,ny,x,ny,c)
   else
    line(x,ny,c)
   end
   if partsfreen>=1 and rnd(1)<0.6 then
    local p=partsfree[partsfreen]
    partsfreen-=1
    p.x=x+.5
    p.vx=(rnd(1)-.5)-(x-63.5)/32
    p.y=ny
    p.t=0
    p.c=c
   end
   i-=1
  end
  y+=24
 end
end

binstr='—0˘0ˇ ø\0\0%L~\rΩY∂\n\nã		Äì&ø^¨[≈Å@…ì`/÷≠ác@ Â…∞òÅkWC1 Ú\0Â\0ÿ\0Ã\0¿\0∂\0´\0¢\0ô\0ê\0à\0Ä\0y\0r\0l\0f\0`\0[\0V\0Q\0L\0H\0D\0@\0=\0009\0006\0003\0000\0-\0+\0(\0&\0$\0"\0 \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0+1/191L1V1]1m1t1~1à1í1ú1£1∂1¿1 1‘1ﬁ1‚1ı12Ô22ì3Ø3∫3≈3‚3ˆ34494P4`4±45#5$5/5C5F5r5Ç5§5–5»Ä»ˇäz|ˇãÅÅ»Ä»ˇè»Ä»ˇçˇéÅ	»Ä»ˇã\nˇç»Ä»ˇç»Ä»ˇåˇí~	»Ä»ˇâ(	ˇÇ~ÇÉ}ÉˇÇ|ÇˇÉzÉˇPò»Ä»ˇÄ¥»Ä»ˇÅ»ˇçÇ»Ä»ˇâ~Å~»Ä»ˇÒÙÈ\0Ì\0ËËÍËËËËË	ËËË	ËÍËÍÈ\0ËËËËËË	ËÍËÍÌÈ	ËËÈËËÈËÍËËËÍ	È\0Ë\rÍË\rÍÌË\rÍ	ÈË\rÍÈ\0Ë\rÌÍËÍÈËÈ\0ÍËËËËË( Í(†ËÈ\0ËËÈËËÈËÈ	ËÈËÈË\0,\0ËÚÂÙÍ\0\0\\Î\0ÍÙË\0ÍÈ\0Î\nË\nÍÈËÎ\nÈ\0ÍË\nÈÍËÌÈ	ËËÈËËÈÍ\0¿ËËË<ª94≤∞Ø≠Ì\0ÍÎ\0|M¿ÈÍÎ\0ËÍ	Ì\0ËÍÈÌ\0\0ËÍ	È\0ËÎÍËË\0 ÈËÌÈÍËËËËÈÍ	Ë\rÚÍÈ	ËËÈËËÈÍËËË\0»ÄÚÎ!!üúÚÎ!#§úÚÍÌÏ\0~9~0xÄr∞l≤f∞≤Ítπl7ÚÍ	Î\rÏf<f¥fªf¥fπf¥ÚÍ	Ïf\0fÄfÄfÄfÄfÄÚÍ	ÌÏfHf¿f«f¿f≈f¿\0|Ú9Î9 8º70∑6 25 -Î\n00\0Ú9πππ∏º∑∑∑7625-0ÚÏfHf¿f«f¿f≈f¿ÚÌüÌ†  Ì¢""Ì$§$$•%$Ìü"¢""Ì§$$Ì§¢†üÚ$)´¨§©´¨§©§©¢©¢©§©´¨§©´¨Æ•©Æ¨•Æ©∞Æ¨´®©´®´¨´©•ß§•¢•©´©•¢•´•´•©¢•¢§©´¨§©´¨§•¢§†¢ü\0ÚÏ\0ÍÌhHÄh»\0hHÄh»h»h»ÄÆ¨´©ÚÚÍ	Ì"""ÚÍÌÏfCfΩf¿f∫fΩf∑ÚËÂ  †  †††††üùùùùÚ)(ß$ß+\'$•ÚÍÏf\0ÍÎ\r?=øÍf\0Íl\0l\0lÄ\0|Ú•••ôôô•ßß®®Ú\'%´•ß•´•ß•´•ß•´•ß•¨•ß•¨•®•¨•®•¨•\0Úˇˇˇkº!Ñ>ÅB¯OíH!IûH‰bÑã+I$âóóP~·#‡G¬G~"ú·$¸∆¡A¯X“D¯{aººÑèè\0·‡‡/¬ˇ%ú¸8¯©â\r·JC‰ˇﬂ?\'Ñ>ÅB¯OíH!IûH‰bÑã+…ˇˇO»@·%îB!ÑB!ÑB∏!¸ˇˇ\r!\\ÑÚF\n!Ñ¬ï$.Bˇˇ?AB	·%îB!|ÑB!ÑpB¯ˇˇ	F¯(°Ñ¬G!M$í$O$B∏í¸ˇˇøÇÑ¬>B·I	!$…â\\åpq%â$ÒÚ /|‡7¬G~"ú·$¸∆¡A¯X“D¯{aººÑèè\0·‡‡/¬ˇ%ú¸8¯©â\r·J«0€02ø\0\06\\ç\rÀe¬\n\'\nï		äõ.«e	≥aÀÜEŒóc3Ÿ∞äeC"ÁÀ≤ôÇmXE3!Û\0Ê\0Ÿ\0Õ\0¡\0∂\0¨\0¢\0ô\0ë\0â\0Å\0z\0s\0l\0f\0a\0[\0V\0Q\0M\0H\0D\0@\0=\0009\0006\0003\0000\0.\0+\0)\0&\0$\0"\0 \0\0\0\0\0\0\0\0\0\0ı0˘0\0001111%1/161I1S1¿12E2o2Æ2È23\n3,3<3r3Ì3»Ä»ˇÑ»Ä»ˇç»Ä»ˇèÅ»Ä»ˇè»Ä»ˇéqˇå|»Ä»ˇÅˇÅÅÅˇÅ2ÄÜcˇÏ\0ÍÎ	È\0!@+¿ÎËËËÈËÍÈËÍÎ	ÈËÈËÈ\0ËË\nÍËÍÈËÈÍËËË\0@ÍÎÈ\0ËÈËÈËÍËÍÈËÈËÈ\0ËÚ-°≠°s≠®§®≠°≠°s™û™û´ü´üs´¶§¶´ü´üs´¶§¶≠°≠°s≠®k¶k®s≠°≠°s™û™û´üs´üs´i¶s§¶´ü´üs™¶§¶Ú\09ªº\0(9ª<æ7@5∑¥µ≤¥00Øπªº\0(<æBæC0\0√«√»√…√JÚ4π¿4π@ ∂2∑æ≤∑æ≤∑¥π¿E√E ∂2∑æ≤\0>≤∑\0Ú&¶¶¶¶¶≠≠$òs§ò§§s§§©ùs©ù©§sÆ§©ùs©ù©§s©©sÆ¢Æ¢Æ©ß©s§´s®´p§p§p§§Ú\09æ¬Ä√Ä¬¿æÄπÄπª<9ÄπÄπª<AÄ≈Ä∆Ä≈√¡ÄºÄºæøæº∫A @æ<C\0Ú\06πæÄ¿ÄæªπÄ! 4@90:Ä<@¡√Ú@ö†úÚB∆ƒ¿ƒ¬º¿æ∫æº∂∫∏¥∏∂∞¥≤Æ≤∞™Æ¨®¨™§®Ú6∏∏∞≤≤™¨¨§& (@ÚEÄ≈Ä≈¿º¿ºπºπ∂π∂≤/4297<ª∑≤Ø∞Ø≠≤∞Ø¥≤∞∂¥≤6≤7@ÍÄÚı0ÍÎ	È-@< ;†ÎÍËı\0ÍÈ\0ËËÈËÈËÎ	ÈËÈËÍÈ\0ËÍÎÈËÎËÎ\0ÍÈË\nÈÍËËË\n\0@ÍÎÈ\0ËÈËÈËÍË\nÍÎÈËÈËÈ\0ËÚÍÎ	È9@4 ≤2ÄÎÍËÈ\0ËËÈËÈËÍÎ	ÈËÈËÈ\0Ë	ÍÎÈË\nÍËÍÈËÈÍ\0ËËË\n\0008ÍÈ\0ËÈËÈËÍËÍÎÈËÈËÈ\0Ë	ÚˇˇˇoÅ?˛œ|¸ˇ˜»≥Õˇ_è<€¸ˇupÄˇøˇ˜∏≤¸&8¿I˛ˇÀ$«¬OÇc∏π"‰ˇØÄc¯EÆ·&<HÚøów„ò∏§\\ñ‰ºìL~HÚ…O¸∞$oxB#ç<ÖN“ÃvC8‰ßm˛X8ûê–â£é$ë_ñ$ˆKX‚üâø8áßPpåÑcˇü	â&˛„ûPpo"åˇc‰ˇÅÖ\'ëƒÓD8bIT˛kè|Y˛ô,<ã\\‡áLx¯ÅáÚCÏˇ5l·ëH“$·Ô$M2ÆÖˇS‚ô8x¿ö¯ø.ÒˇI<ëŒÉP{	?ÜÉoK˛/âgb|Â†rÜ$)ÑásI˛âgâÉáÑ ˇ0\\vÛøœpQñ(ˇø\rﬂí¸‰ÆLm¸O√5>˛\\√ ˇ7sE.˘ùk8C˘YN˛\rGû·\rÂøp0~W¯üÑg∏C˘-\\Ñø√óy‰ﬂL¸ _·?áo8¿ü‡\0ÑÚS∏√ø·\'8¿/°¸˛†¸æ·\0Ç¸ /â_Öo‚\0ÇG˛‚ê_¯eI>y√∑pÄ?¡ﬂ!<¸∂%·‡å|¯¸Œ¡ˇcI.~K<Çˇˇì%y¯+ÒL¸	˛¸_ñ‰àÑí<&˘$∆¯,¸í‰˛ﬂ°··A¯Bá¸œCy¬ˇ\\°√˛Ô°·ˇû–·\0ˇ˚P˛?tËpÄˇ? ˇ#6t‚\0ˇˇ îÒì#ÚÄˇøê(ˇGˇB˘øÜg¯ˇ°¸O√3¸ˇã0˛ß√˛ˇFˇ”·\0ˇˇ#‡:‡ˇèˇ[˛ˇ?ÄÚˇg‰ˇ∆ˇˇ˛ˇˇ\0¸ˇB¯ˇˇˇ˛ô1≥12ˇ≤\0\0C\r	.SÜ\r√_º\n!\nê		Ö\nó*√bØ^»ÉBÀïa1ÿØàdB!Ê ±òÅlWD2!Û\0Â\0ÿ\0Ã\0¡\0∂\0¨\0¢\0ô\0ê\0à\0Å\0y\0s\0l\0f\0`\0[\0V\0Q\0L\0H\0D\0@\0=\0009\0006\0003\0000\0-\0+\0)\0&\0$\0"\0 \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0/\0?\0I\0P\0]\0a\0k\0u\0\0â\0ê\0ë\0ò\0ü\0¶\0≥\0√\0Õ\0‘\0ﬁ\0Â\0ı\0˘\0\0\n"&\0\0/\0N\0W\0~\0∑\0¸\0GR]dkxÅÜìöß≤º√ —‹˚-29@GNU\\cnu~áêù§´∏¡»„˙#»Ä»ˇÄ¥ˇˇè~≈1…1–1›11\0002222"2/2?2I2S22û2ß2“2\r3>3W3É3»Ä»ˇÄ¥ˇè~Ç»Ä»ˇèÄ»Ä»ˇé0»Ä»ˇñ»ˇÜ}»Ä»ˇÅÅˇÅ~ÅˇèÄ»Ä»ˇvä»Ä»ˇéÄrˇàÅqˇÍ	Ï\ns\0sÄÈÍËËËÈ	ËËËÛËÍ\0\0P\0ÚÈÍËËÈÍËÍÈ	ËÍ\0ËÍ\0\0‹ÚÈÍÎËÚÎ&(\n¶ö&(\n¶ú)+\n©ù))+\n©ùÚÎ2Pπ97\nπæºªº97\nπÎ>Î<\nªÎ2PπÎ9Î7\nπæºªº≈π√πÎ¡Î¿>ÚÏ\0s\0ÏÛf>ÛÄfÄÄÏ\0i\0Ïf\0fÄfÄfÄÏ\0s\0Ïf\0ÄfÄÄÚ!-\n!≠)\n©&\n¶(ÄÚÎ@\n√≈√E√¿ºπ∑¥∞-Î-\n-≠--\nÎ0Î5\nÎ¥2(ÄÚÍÈ	ËÍ\0ËÚˇˇˇcà∂£Mˇ¬?ë∑"â¸I‰óààH*rWD§r“d…ˇ»~„·ÁÃ≈ì¯âˇ]¯áÉ+ÀÑˇ8i"L~ê&B¯Uê0¬/˙ˇíˇ88¯9$Ö¸Â¯ˇõ!éÜÁ…\'i"©»O˘_ÑÉÚ?‰ˇÔÑq?„ˇ/<¸Â˙=1˛ˇÒ?…ÂˇO˙‚˚É;ëpÛˇ/˛!·ˇ/∆˘„\r…Èg∆˛!¸ﬂΩwH^ˇÒˇw˜!ÓÚˇ˘#¸ˇß˘?…˛&I˛îﬂ‹ˇﬂˇèr¯ÒKíˇÉî˘+\0—0Û02ˇˇ\0\0›¿≤¥ƒ‚B\rÑ–&Ü\nÔ	`	ŸZ‚q°BËìC˜∞m-Ò∏ÉP!Ù °|X6˘‹¡®êzeQ>,¸\0Ó\0·\0‘\0»\0Ω\0≤\0®\0ü\0ñ\0é\0Ü\0~\0w\0p\0j\0d\0^\0Y\0T\0O\0K\0G\0C\0?\0<\0008\0005\0002\0/\0-\0*\0(\0%\0#\0!\0 \0\0\0\0\0\0\0\0\0\0\0#1\'111;1B1O1\\1i1s1}1á1ë1õ1•1¨1∞1∫1«1u2v22ä2∞2	3\\3x3î3∂3¡3≈3ÿ384J4¨4¬4◊4Ó455:5M5z5»Ä»ˇÅ\r		»Ä»ˇçwˇá»Ä»ˇå\n»Ä»ˇç»Ä»ˇç	»Ä»ˇàÇ»Ä»ˇÅÅˇÅÅˇây»Ä»ˇÇ~Çˇáyáˇà\nñ»ˇ»ˇÄ¥»Ä»ˇÄã¥»Ä»ˇÒÍ\0\0000ËËË\0TËËËËk\0kÄË\rËË\rËËËËËËËËËÌ\0k:kπË\rËË\rËËk\0kÄË	ËË	ËÈËf\0Ëf\0ÈËf\0ËËËËËk\0kÄË\rË\rËËËËÚÂÍ\0\0`ËËÚË	Í\0\0000ËËÚÈÍÎ	Ì\0ü¢§¶Ì¶Ì¶¶Ì¢Ì\0¢ñ¢ñÌ§Ì\0ò§ÚÈÍÌÏf0f±f≤f∞f≤fµÏ\0k:Ïf<fπfÄfÄfÄfÄÏ\0k\0Ïf\0fÄfÄfÄfÆfÄÏ\0k0Ïf2f∞fÄfÄfÄfÄÏ\0k\0ÚÏf0f±f≤f∞f≤fµÏ\0k:Ïf<fπfÄfÄfÄfÄÏ\0k9Ïf5fÄfÄfÄfÄfÄÏ\0k7Ïf4fÄfÄfÄfÄfÄÏ\0k\0ÚÍÏf\0fÄfÄfÄÏ\0k\0Ïf\0fÄÚÍÏf\0fÄfÄfÄÏ\0k\0Ïf\0fÄÚÈÍÏ\0Î\0ÏfCf¡sºfæÏ\0k\0Ïk\0kÄÚÈÍÎ\0H®Â\0ÄÚÍÏf\0fÄfÄfÄÏ\0k\0ÚÈÍÎÌÌ\0üÌüÌ\0üÏkÄüÌüÌ\0üÌûÌ\0ûÌûÌ\0ûkÄûÌûÌ\0ûÌüÌ\0üÌüÌ\0üÏkÄüÌüÌ\0üÌ°Ì\0°Ì°Ì\0°k°°Ì°Ì\0°Úk\0kÄË\rÍ<0Hê<0HêÚÌ"Ì\0¢Ì¢Ì\0¢ÏkÄ¢Ì¢Ì\0¢Ì(ùÌ\0ùÌ(ùÌ\0ùkÄùÌ)kùÌ\0ùÏÌ!f§Ì\0f§Ìf§Ì\0f§Ìk§Ì\0§§§Ìs§o§l§i§Ì\0f§i§o©s´ÚÈÍÎ\0¢§¶-Ä≠Ä-Æ\0000ÂÈÍÎ-+Ä´Ä+$Î\r∑\0`ÂÍÎ	$ß´Æ\'$()-.∞\0`ÂÍÌ\0ÎÏf0Æf¨©Ï\0kß§f¢§ÏfßÄf§ÄÏ\0k´ÄfßßÏfÄÄfÄÄÏ\0k©Äf¶¶ÏfÄÄfÄÄÏ\0kÄÄÚÈËÚÈÍÎ H"#HÍ%xË\nÂÈÍÌ7∑5Ïi≥02i≥iµ6∂5i≥/1Ïk≥Í5`Ì\0ÚÈ7Í\nÎ\0ÓÊìÊüÊÚˇˇˇÈ«ü¯;ˇ?2)$˚ˇ”Ÿéÿ‰ˇoGll[í¯ˇ€É%,íƒˇèòD$âˇøëL∂ˇÖ˝e ∂Æ,ì<I"Wí…ìdI$√ˇd±üû,ŸX_rπí»\\Å|IHé¡ˇe	ˆÉ%ëdY6Î`I¬¬HñõÖâ%˘ˇ&^!ôÅCÉ $ñm[¯ﬂKÇ‹D»a¡i¿`Ä\0	¿ˇÁZÒ⁄#ë„IÜ¬Ç\n0¿pd¡ˇËZ2s⁄cÀB$!O\r[1a0¿\0«ƒˇÎZÛqÿíÂb«5 Å(`ÄÜâˇŸµ%Ê‚»´YíCÚ`âM a&`Äa âˇ€µây'
__gfx__
87ce8c661ecc46b5c4221610608106858620ff3bb6b44c1cbbc229cb27c6b0846915211909940b2c32ff7bb6b444ded569f121f461942331c1bd2ad8ca3c7cff
ee2944cca3bcfffde329442cfffbf30c8fffbf708078effac14efff1d10079eff62702ffff9a080ffb2194efff55848ff7981efff611eff581efff95a91ffb11
3cfff5b58ff1168fff771ef7381effff58ff9068fffff1044eff5cfff530fff21cf51d035e0323ff11ff100000f971c461c051dd310c212b114b014cf02ee0c0
e024d048c00db062b068a0fe9006909d80a5802e70177060701a6024608e50395034507f400b40d640d2401f308b303830053012304f20ac201a20c720852063
2071209f10cd101c108a100910a71056101510e310c210b110b010cf00ee001e004d008c00db002b008a00f9006900e8006800e70077000700a6004600e50095
004500f400b40074003400f300c300830053002300f200d200a20082005200320012000200e100c100b10091008100610000007113b113b2135313f3139413f5
13c613971368133913c323f3232423d423b923da23db23ff231433c433d63328337833d933cb330e339e336f3310432143f14382433343c3438c088cff10a810
10182020f770c0f7608c088cff10383011f7508c088cff10981010d7308c088cff10182020f730301810ff10391010d61010f72010184010f7401018208c088c
ff10081010e710203e108c088cff10a81010e71020f7308c088cff10681010581010f7308c088cff10b81010e71020f7308c088cff1f100ff0301020309e00de
00be40ae108e508e508e508e50303020018e408e50303020218e408e6020d030908e7020e08e80203130308e409ea08e5030c020419e508e408e5020618e608e
40309020d09e008e7020e08e80303020718e4020118e50203130308e4020818e508e508e5020318e5020818e508e508e5020318e5030109e90de31ae9020108e
508e508e608e608e508e508e608e609ee020518e508e508e5020108e202f0f365e00832f9ef1ae70dec08e408e502fce60be505612701a56da1aa6ba56f956f9
56ba56d9d9569ad9a65b56d956c9569a56d9d9569ad9a68a56c956c9568a56a956a9566a56a9a62b56a95689566a56f9f956baf9a67b56f956f956ba2f565170
561a56ba56daa6da561a56f9561a2f56e170aa56e98aa66b56aa568a56aa2f56f17056f956ba56ba96fa56fa563a56fa564a564a56c956f9960b564a56c956f9
564a568956c956f9960b564a56c956f9563a563a568a56aa96fa563a568a56aa2f563270563a567a56fa96da56da561a56da56c956c9568a568a964b568a56c9
568a56a956a9566a56a9962b56a9566a56a9565a565a561b565a963a563a56fa563a2f9ef1ae70be008e708e802f00701ac94a6a8a6a4a3a123251707951e0f1
701af1e0d170f9d1a2c170b9c1c12f00e08470ac8c5c0c7c544534c114a20470fb04c12fae708e402f9e81ae80dec000e032704a6a3a4a6a824582c182832f9e
81ae80dec072e072708aaa7a8aaac2a2c170e902e08270aac2e0fad2832f12e04a3a6a42706a8a9a8a6a4a3a12e0593af1701232a170d9c959a9d9c959f9d9c9
592fae20be408eb08e115e9e42ae20be3032e0be4012645e9e42ae20be408ea08e115e9e42ae80de818ea032a200e0d170c9a95e9ed1ae90dec08ef08e508e50
2f9ed1ae90dec08e502f9ed1ae20dec08ef0a1835eae80de818eb08e115eae90de8100e0c370bbcb089b082fffffff0ff79e707bf3a98ff171fff7f3239ad5cf
ff96958382ffffa346161952efff678c288c21ffff24819ff764c291952efff64339ff78df56a2bd2383c46b9dc69d85469e2675299c3946aadccff52b193dab
ca122955a894c2c37060d430c31c2c394c550ef739de1e34664e8d6c8591c1f840165048c032c02842eff3bd4ce460638094526a127c33023e32042279044221
184220ef73b4c8f3804484223900b3ab128c8f80098c520198c32058cff7e29c4cf26422fc191e80604f3b0098c520198c32092d09ff3d39c4cf1968d80e80c1
708307104227904422f804e123dff5d52952e71b23122c170042870098c520198c3209111ef7679422e7096011d0938c01c1114098c520198c32091948ffbd52
988b9729840ec8c80b0248d024229018e88dffce294ccf49c42ee0705298c03e880024ce11678cc6a4f7db444c96dc6257787819cc01ea00c8399d06408fbf2b
c23fb8efff12bffdc3942cfff533c40fff8708fffff2870875f27c9e97c579efffba2c5a3b3c1fa7e0fc79afff75d06cf16faeb948cfff3b0fffa360fff7d0cf
f803cfff93f0b0fff013cfff8ff3678ff9c128ffff758ff500cfff3c1eff012cff2934eff7cff06b693e74bbc17be4936e99b8effb8fd354e7399cc6c8b00301
2c048c301d03be0323ff12ff10000053c1f9a112918b71366112512f313d215c115c014df01fe0a1e005d009c0cdb023b019a09f90a6902e803680ae709770d0
708a608460ee5099508450cf405b40174013405f30cb307830453042307f20cc204a20e720a52093209120bf10ed103c10aa102910b71066102510f310d210c1
10c010df00fe002e005d009c00eb003b009a000a007900e8006800f70087001700a6005600f500a50055000500b40074003400f300c300830053002300f200d2
00a20082006200420022000200e100c100b100008750139013311302130313d31374131513a6134713e713b8135913f9135623c133f53347337833ba332c336d
33af330343e34315438c088cff1068101028108c088cff10981040f74080f7508c088cff10b81020081020f74020f7608c088cff10981020f71090f7408c088c
ff10a810c0f7908c088cff10e81010e7708c088cff10182010f72010181010f71010182010f72020181020f710ff20381010d720203810ff10f72010e7208c08
8cff10b81010d73010f7208c088cff1068101018108c088cff10681010f7108c088cff1f103f6020109e00ae300010be00de008e208e208e209e208e208e208e
208e508e50de428e508e509e40de008e508e50de038e508e50ae30de009e004f8e809e308e809e208e809e008e809e208e80de819e308e809e208e809e008e80
9e208e80de008e209e108e209ee08e208e208e20b600c08e209e504f8eb0ae608e508e508e509e208e508e50ae309e608e209e708e508e509e408e508e508e20
9e208e208eb08e808e808e808e80ae209e108e70ae108e70aeb08e70aec08e70ae008e708ec010005e9e00ae400020be709e818e209e008e308e408e308e409e
208e308e708e408e708e308e40ae208e608e609e408e608e60ae509ec04f8e90ae40be008eb08eb09eb08eb08eb09e20be7000c0dec08e308e708e408e708e30
8e708e20de00ae109ec04f8eb000068ea09e908ea09ec18eb08eb09e708ea09e408ea09e01bea08e709e408e409ee08e709e208e408eb08e809e518e809ea18e
809e128e80ae109ed08e70aeb08e70aec08e70aec08e70aec08e708ec010005e66d2c0ce9066d26066dab6d2c066d26066b2c066b26066ba66bab6aa66aa668a
668a66d2c066d26066dab682c066d26066f2c066f26066fa66fab62b662bb64b664b2f046066eb0ceb04c0e36004c0e3600ceb3c2c34c02f046066eb0ceb04c0
b360e3c0b360e3e100602f662360ce9066da66aa666ab61b66da66aa665a66aa66da661b66dab6aa66da661b66da2fa4819c54604c2c44c05421a4819cc4c0a4
6094c054212f43c043604b43c0436063c063606b6b7b7b9b9b2f663260ce9066aa66fa66aab63a66aa66da66aa663a66aa66ba66aab6da66ba66aa666a2f6623
601b66fa1bb60823216623601b66fa1bb60823216653604b662b4bb6085321be80669303668306666b663b669b668b666b663b2fa4819c54604c2c44c0542154
062f43c01360d2c0a260daaa1bfa1b4b6b4b1bda2f00062fffffff0ff6b0fc682705acf048f8782705649792705e36c943cffc80fff728f8f12cfff95e6e780f
71f250d0fff730c87e210d2c358f1e0093224b0f51a58f12cb58720968b02d1248780f30f252c70e02cf058f0c14689c719624107132cff08b8056cdc8b80f09
98f18c0393830c8b98c198401e3e248b311eb1e221844e913134ce693ce46274813e722cd9c0758f6b807029c48d61e7a8db2d429a40e09ff572980967129836
98f78f72c1111a2fffc58f489c6e0b061e858e036cf981102161927d0fb485868f16999c40742019698729193d6213d48c231b7c070516028ac91bf32119bf81
1a44212233184001230080f0fc218642ce112917d148b19098383ab4298c290a42c8f146306c01a1e34850c81246222d340642c21d520848942b184021e02422
9c6b8061228f52842b8063166127011bc4ea8444321bff95856a1ef238074860742bce3b529668858acfff5c36123b21bbeb4428ffff922c4695ee906fff7490
9946cf46ffff3bc431ffffe39566effff708ff001d037f0323ff11fb100000bdd041d085c07ab0ffa016a0cc90f390bb80d3807c707570ee60a860c2603d5008
5013506e400a40d540f1403e30ca30773054306130ae200c20892037200520f220f0202f106d10bb102a10b81057100610c410a3108210711080109f00be00ed
001d006c00ab000b006a00d9004900c8004800c7005700f60096003600d50085003500e400a40064002400e300b300730043001300f200c200a2007200520032
001200f100d100c100a100910071006100510041002100110001000100f000e000d0001d007113b1135213c213331334130513d51346131713b7135813f81339
130a13da134b131c13bc135d134723df23f53387334b33dd33a1432343b443e4439643374308430b439b438c088cff10482010381061f7c0ff10b8108c088cff
10e8108c088cff10e81020f72080f740e0f7508c088cff10e81010f71040f7408c088cff10e81010e74010f7108c088cff10f8108c088cff10f81020081010e7
10303710ff108020100d308c088cff10281010e720102810ff10281010c710102810ff201810ff10e81010e72010f7108c088cff3018c080f73023f7908c088c
ff10171010a810ff10d81030d71010b71020b710ff10f81070f7f08c088cff10182010f730101810ff1f103f6020103020aee0beb09e00def0b31ade008e308e
308e308e308e308e308e308e308e308e308e308e308e30de31be00ae709e508e709e708e709ec08e709e508e709e708e709e008e308e308ec08e30de008ec09e
30de31ae709e118e709e318e709e418e709e618e7030f09e008e308e308e308e308e308e308e308e308e308e308e308e309e508e709e708e709ec08ed030f08e
508eb08eb08e902faee0be219ec0de310051d4cfdef0ae10c30e8ee000c8aed0dec0be218e40aed08e40de81ae309e508e809e708ea09ec08e809e508ea09e70
8ea0de819e0003c1004503c100459ec08ed003c18ee08ed030b0de00bea0ae309e508e809e708ea09e808e809ea08ea0aed09ec000c130500045dec0000e0007
8e608e609e508e809e708ea09e818ec05eaee0beb09ec0def000a2f37eae20de008e508e508e508e508e508e508e508e508e508e508e508e50dec0bea0ae3066
53c1ae208e509e318e509e008e509e118e509e318e509ec08e508e508e509e418e509e318e509ec08e509e418e509ec08e502fbe90ae7081320070ae11a908ae
70be90b1320070bea0e9f92f03e0b2c13370085b3b5b3b53e073708b73e033c133703b2b3b2beab2e003702b03e0b2c13370085b3b5b3b53e073708b73c1ae10
3b2be2e003702b2fae40cec06603c1ae60b63370370bb6ab378cae40cec0b6c3e0ae60b6f37037cbb60b663bb6cb66082f00e073708ba3e08b7b8b3370087b5b
3b5b7b5b33e02b3b037008bb0bea0bda0bca0bc2e00bb27008bacaeacaba9abacabaca72e0cab2510070b2e09a2fdec0817008690881e0de00bea0b170a981a2
de00e170f92fae20de003370082b0833e0de31ae3003702b3b08ab08a3c12f00072fae20de003370082b0833e0de31ae3003702b3b08ab087b5b3b082fce00ae
4066005100702fae80bea0de0042830ad9d9f92fae50be00dec003700b0bea23e03b0370baca9aba7a9a6a6a6a6a4a62e09a62706a6a4a62e09ab2707a9a6a7a
4a6a082fde00bef0ae0173452f5effffff0f7630f70715e90f58f12cf21e46c11ec0fb3f0721e10f1f7c0f70ffd0f68fd92f28b8fb78f1839582f3c0f73ff0f1
873cf1cf13c54830cf0cfe160e730f282838073823ac828b9b828ff3090728f18074828380701e0487932cf01a1ef901a1ef77c823a42c8ff33778f128077838
0701e0050f28b343cf3148b9f1848f1878b24838783872cd1e0a160e1e790f180f7c0f301e700f273758e0016105acf6c1492f303e60ff68b9480f0d05e20d08
3249f19bb0f28183878ffb1d0f30fff7993832cfff37e4efffc371fff7f9fffffc0effff7081fffff70cffff740ffff9001d03fe0391ff12ff10000048a17091
f971c461c051dd310c212b114b014cf02ee0c0e024d048c00db062b068a0fe9006909d80a5802e70177060701a6024608e50395034507f400b40d640d2401f30
8b303830053012304f20ac201a20c7208520632071209f10cd101c108a100910a71056101510e310c210b110b010cf00ee001e004d008c00db002b008a00f900
6900e8006800e70077000700a6004600e50095004500f400b40074003400f300c300830053002300f200d200a20082005200320012000200e100c100b1009100
c100f1133213631394133513d513a613471378131913e9138a13fa139b13fc133d1374232b23fc239d23ff235133e33336331833a9335b336e335143b4432543
a543b643e6437743c8438c437d432f4320188cff10e81010e71010771010981010e710106710ff10e81010e71010b71010481010e710107710ff10c81010e710
8c088cff10b81010f7408c088cff10d81010f73030f7308c088cff10a81010e7108c088cff10b81020f73030f72080f730d0f7308c088cff10c81010f7808c08
8cff10e81010f71010e7508c088cff10782020f7e08c088cff10781041f770ff10381010d720103810ff70081010f71010181010f710101810103aa010d5a0ff
1098f7ff1f102010de00bec09ec0ae20ce0030708ea03020ae108ea08e3130218ea0302030608e318e318e519ee0a600218e318e318e51ae208e308e308e308e
3030809ef08e308e309ea08e308e309ef08e308e3000213070ae60cee09e31de508e419e31de508e413020000630902001ae70de008e112fbed09e31ae308ea0
dec09e008eb08e41de009e318ea0dec09e008ee000608ec08ed08e619e2000818ee08ec08ed08e619ee08e408e408e408e409ef08e508ef08e508e019ea08e50
8ef08e508e019ef08e508ef08e508e01ae30de009ec0bed000278ea08ea08ee0007e2f9ec08e609ef08e609ec08e609ef08e609ec08e609e118e609ef08e602f
d160d9b989818189892fae509230089a087a0803c042302a4a0060ae40c230cacaba00c092309a9aba083b2b0be6082fdec0ae509230089a087a0803c0429000
30ae3042602fdec0ce00ae60567330ba565b9a275b279aae80e60360ae605603304a56cb4a27cb274aae80e673602fdec0ae60567330ba565b9a275b9aae80e6
0360ae605603304a56cb4a27cb4aae80e673602fdec0ae609e34fef0566e3008566e3008ae902700c0aea05608ae9027082f1f409ec3aeb0dec0fef06e10fef0
6e10fef06e10fef06e102f9260d181b160d9f1c0024212c0228102602a42c05221526072212fe6d360c330084c083c0814c0cb8360a33008cb088b0833815643
605b7330088b08a3c08b73605330087b088b08a3c0cb2f0060e600c03360db5bab00c0e62560e6ed5330087b088b08ab08e664c0833008ab08c36008ab0883c0
e6f460e6dc2f565360cb53305bc36000c03360fbdb08abe6d4c0e6b460e694c08330abcb08db08cb08a3c08330087b0873c03330087b0853c0e6082f565360cb
5bcb2fde90c2c0ea8bab2fde8003c0de90eac260de500bde90e2c02f14ab2f9e008e609e818e602f9260d181b160d902c0224242c0528172214281d92fe6d360
c330084c083c0814c0cb83308bab08cb088b085381de009ec0e68360cbd33008cb08a3c08330087b0873c03330087b0853c09e00dec0e6082f72605221728130
714a30700700602f8330abc360d33008cb08a3c08330087b08de003481dec00700602fbed0ae30c38100d52fffffff0ff3ae3015c67ffff78909fffff601288c
ff832122ff3b568cfbbc2c84cef7842619ca2fff16a1904ef188534a1a4eff6788429ca2ff33b56ca2f78c1613856bff3190ad6740ff3b96803dca9f56d662e9
4bd9ff7112f8a3ae7d5b9f94d707c8fd46b88d6bff7421951437094ff6c43f535172164ff36958982bfdbda8497a6de43bc1fb449685d4456b3abd0c3be4a8f3
237e39ce855abf7f29ce80732c674cf2d43b46b10d3290ad226119af5601e19c3b5a3f3e2b4f796370e850bf7663b4721ab36170ba38911bc19644a66932b04a
e0dc61b43fbd1bc6c485e0e85634ec0754564cc42695ce899945691c1911b9309d4f37876746a4e7af270d4cab5698c966b52e845a12116ea81328480bc88c56
54e096ad305999722742fb4e8a485f8ca952f52bc7dd69d23174694c3b36b52ae10d4094520994804a5374c211707c486ab46278f52d40d4e8c2b0815b3a7832
9aa9e2c25d386698304635e84c4fbde84909c542510943942bc1cad2ee7a9da122b4812b6845f86c142dd2984286cce983c832b987809a9f09685ab42b0e8563
9509e81e41b2132c84229d6b81de0ccf3c48d645238b843644a4a9621706c1311c16299d660c3690f9186e867b4b5912dd19d229b6d46b4a9d84274a5b52a188
95094c1bc2c2269ec168e1c6a9c161956e410128074369421dd098809ca984667cc4d1c270194431c11b074b116b6448ad698edae856b1f9891211ce27c699ca
a13258a37d3c16ab36378a3429d4296f885802b0899c4a94546a967b3c12b5ea407439ee988d854229434d6985212e2331c03461b195ad54c13a02983c4a8461
599639c21c42f1d884a1b4211915cf15a1b94088de9598908a729884c8a363b9b42d0b337439429d5694a43b098b3be17c221c1c4c5d5e8ce8c1a1d34c1ba5a1
0f431339872361885069f2b5e8293a7476d8d0791b44e132225b7e3c11a05e099cc3654c89362d119d1a885290274274018762471d86f0b5c97088d282259a88
6e94524629074cc86eea847b890b942dd2981701b42d361dee2946546b5d384a62a7c220d8eea5398843ab52621b942b423a198c0195639c11119d11b1836323
8867431f0469562962121b633e01b34453ae03f80c2b9c644701e419299c76b6231d8ce966b13d322fc195ab007ee88d428d44eb42b4bec40812d40788429862
999be8dab53fc23390031e8633ea9e16bbccadc80e0431dd1d9205294c531065b0990cb4e8c25de2d50f546964ac2880196ea46119c4a1fd6d0bca1a19f542cf
148fbc0113567844cdbe6394a137c12b9d697cce0595445bc2310b6dffe318083c1015bc836b32c49c1eb9650994278c848c139afff33242bd147394483e7147
d55ad4a212226fff754622a49970d5cc466e44280e3efffd99f8d69639875ffffaa443c4572e101d03fe0323ff12ff10000088f13cd181c148a17091f971c461
c051dd310c212b114b014cf02ee0c0e024d048c00db062b068a0fe9006909d80a5802e70177060701a6024608e50395034507f400b40d640d2401f308b303830
053012304f20ac201a20c7208520632071209f10cd101c108a100910a71056101510e310c210b110b010cf00ee001e004d008c00db002b008a00f9006900e800
6800e70077000700a6004600e50095004500f400b40074003400f300c300830053002300f200d200a20082005200320012000200e10000009013d01362130313
3413d4137513d6139813f9136a139b13db137c134d131e13b423c423da234133633334336f33824317433d43b05341538c088cff10981010f72010181010f720
10181010f72010181050f780ff10781010f720a0f750ff10f81010f75060081010381020f750108710ff10b81010f71090f790ff10c81010f7408c088cff10b8
1010a71010481010281040f73010181012f790ff10571010b81030f71010182020f72020182010f73010184010f720ff10b81010f71010181030f720c0f760c0
189021f790ff20f710101810ff10071010091010f71010281010d710102810ff10388cff10d92010763010c820ff1048102018a040f7e08c088cff10581010e7
1010281010b710ff1f100f1830b020c0ae30be7000cc20103010ce90f6008108f608202030309ec100c08e408e40ce009e018e50510600819ec18e408e40beb0
61069e42ae50be708e409ee1ae30f600c00042f600038e408e408e40ae808e50128ace009ec000818e5051c3ae20e2cf082f5e9e40ae40be708e60dec0ae508e
60de00ae408e708e70f3818e609ef2ae508e40bec0ae40b2c69ea4aed0be708e50f0039e60ae40008100c334605c64428e608e60ae509ed3f600818e409e52ae
808e50d18a9e8100108e5051c3ae208e6000cf2f9ec1ae60be7000108e808e909e01de81ae808ea09ec1dec0ae608e909e40bea08e60ae80beb084c6dec09ec0
ae10be708e609ee1ae40814242609a72428e808e909e60bea08e60aee08e70ae808e7062849ef1ae1000c0f600818e709e81ae208e708e7010002fce90f04501
c0114521c03145e0c0f045e0c0f04501c0110329314551c06181a0842f810669414531c011068969492f5673c056eb567360567bd7f3c0567b56eb567360567b
f6f3c056ab56eb569360569bd7f3c0569b56eb569360569bf6c3c0569b56ab767360767bf6c3c0569b56ab567360567bf6c3c0569b56ab567360567bd7c3c056
7b56abf6cbf6eb76ab56eb567360567bd7f3c0567b56ebf67b56fbf6ab56eb569360569bd7f3c0569b56eb76c36076cbf6a3c0569b565b562360562bd773c056
2b565b562360562bd673c0ce00d62b5b23602bd773c02bab96cbd7eb2fd614c06ccbd73cfb6ccbf63cfbab6cd73cfb3c56cbf61ccb8b1cd7fbcb1ccbd6fbebcb
56fbd7ebcbfb76f360b6fbf6e3c02fb260dae2c053849260ea03c02384b260dae2c00822602a03c0ead281e206e260dab281f672c02381eab230dab2609221d9
9260ba62212260b2c09242c1c0d103c1c0d181f1c0d1032fb260dae2c05384e260ea03c02384e2600bde40e2815700c0de3003600bde40e2c0de30d281b206de
00e260dab2815773c0dec0e281dab230dab26092815700c09260ba6281ce00b2c09242de00ae40f6d1c062604a6281b2c09281f608d708f6082f008173c03b2b
__gff__
c880c8ff028101027f02028101ff0182050c7f08c880c8ff018c01017d04c880c8ff018c01017e01027f03c880c8ff018d01c880c8fff101f05af30602010302ea01ec00ed00e900e803e803e803e8030205e902e803e906e8030201e900e803e8030208e918e808e809f2f05aea01ec00eb00ed00e90ce803e910ea06e806e9
0ee806e90ce806e910e807e807e91ae808f2f05aea05ec00eb00ed0ce90ce804e804e804e804e90eed13e804ed00e906e804e900ed0ce804e90ce804e90ce91fe808e809e809f2f05aeb021c2a1c1c170eeb04a5eb02a3212a211c1e159c1a2a1a1c150eeb04a3eb02a11f2a1f1c1c159a182a181c130eeb04a1eb029f1d2a9d
__map__
30243006b3320c30182b06a92b182e0c2e1830a83006b3320c2e182b0c2e242b06ae300c32182e06a92e18320c321830c0f2e91ceb07ea06e804f2e940ed0cea02ef07e60cf2fffffff03fe90b6c35de17f44c76daffd6a439b20359dbffebf35cd7c56348e6c9fc914cb63d496485e8f534bd574fe6c266791269dafd0f2ac7
73c8fa0c8ea74d921fbab6d7714802e9f2e4823c9a0ce9f2d4e1708c9846b65c4f9e6e939163597a1c93fdd0c7ae39883ecf4512b9328958136bc1f11c8f2dc9cc5fe13a2a578ea3590e3b642cc7417d1c69c79e94688f344b32cf3f6639b4837a12d9819964b1b4b2072449b9d5f3f4e8938ac6d1b4194969d61dc4213df2df
a4c75217971c33b7fcba908d8b3f8c3cfca9a8355ac7ec57e4482e3c32e09129394e04113973e4d963ff873cc72292861f91c618a349123c8f26d4c3c8951c207c1b4b0fdbe31fc39be782204f33fc913cbb92c70a476dcb0f39ae439784245ce42077fb1c4b9ed2bfc67e10fc7cf4e99125c7398ba4b1c461c7a1a7433ac94f
fcff85c7bae4b0240ed2ed391c017c976da2a933cb8f7c763c0d7124f6248403218f669339b698604a2dc9f3241162760445441df35bcc8e902188c3818c68b384901d03391c27921cc2c84622c1f1a46247380eb2e498e7723892a867c921ff3cb215d3e4b1e310c34e2b797664697f780e1bd932ed5413962ec85663be2ccd
92e7692bfe6904dd91e120d91c24d11a12fe9143733c76d065120fc6f51ec5225ef9e7dc71e44986e1937d22dbe63a0e0efb8727637de2e8727038c44d33ff87b54f10f9ab499b330ec731f9993ed13d751c69fc3f33ffa6c661ff7f9dffc7ae95fd2ab6edb77c7922ffffe4eaf33c5bfe54f99edfd68a0be3ff7f6ca85412ff
75ea8f7c1c8d0b4be2ff8fe4a9d035fe9beebf6c4bfdff153187439643ba894e49a0a92e471afeffd3138c1c873470e4cc2273d1873d5b3a4bb244feff51be688888ebf0653e3bc5714a1247d4b1c00e91452af6ff8fb238723cbe67d944e58898204f1c230eb54593fcff23412657722c530b72101387f16c8625d5ccffdfd9
8e4ae6328dc0b11d89c921128dc521e8024d9e44feffcf5a59d492e9b104a4be581c1974079099a301ffffa5e95022c7f3ffeb91e648f3ff47c2ff35e937470ad130e73032ff118c0100000c15dd13c012b211b410c40fe20e0c0e420d840cd00b260b860aef096009d9085a08e20771070607a1064206e80593054305f704b0
046d042d04f103b803830350032103f402ca02a1027c02580236021702f901dc01c101a80190017a01650151013e012c011b010b01fc00ee00e100d400c800bd00b200a8009f0096008e0086007e00770070006a0064005e00590054004f004b00470043003f003c003800350032002f002d002a00280025002300210020001e
001c001b0019001800160015001400000009310d3114311e312e3144314e3164316e31783182318c31ab31d531e6310432223240325f3278329c32a632b532d432ea322c3338337233c880c8ff01800101b401ff018d01017f01017401ff018f01018001017801018801c880c8ff018f01017f02027f02057f02087f020e7f07
c880c8ff018f01017e07c880c8ff018f01017701018901017b010185010b7f0fc880c8ff018c01017c03c880c8ff028102027f03028101ff018101017f02018101ff018201017c01018201ff0201ea03eb08e906e806e806e806e809ea03e80ce80ce80ce80ce80ce80ef20302ea02eb07e912e8073c18bb80e807c0be80ed00
e808ea02e80aed00eb09ea06e80d0310ea06e80ff2e803e803e803e803e803e803e803e80bf2ec01ea04eb0ae90673370666b473b966b4ec006bbbec0166b473b966b4f2ec01ea04eb0ae90673320666b773b066b7ec006bbbec0166b773b066b7f2ec01ea04eb00e90673510666cc73c866c5ec006bc0ec0166bc73b966b4f2
1c0c9ca89e9f9fababa4a4a4a4a1a1adadababababa4a4afaf3018b0af80f237243418320cb4b93724343c2f18300cb23418340cb63718f23b0cbb803b183c0cbbb937243430000c32090003320cafb43218370cb6b4bb4018be80f21c0c9ca89e1f30a4a1f237243418320cb4b93724b4320cb0f2ec01ea04eb0a73370666b7
ec006bbbec0166bbec006bbebeec006bbb6bbbf203042b0cabafa6ab9aabac0305adadb4adadadadacf22f60003c370cb9bc3b18b7323000243c06803c0cbe4306803e6c003c370cb9bc3e18bcbb3e0cbbbcbb80b7bcbb340680341832540030ea053c0c3b04bcbb390cb7f22130a4a8ab9d9d9d9d9d80f2340c300680370c34
0680370c340680b7803b183706803e0c3b06803e0c3b0680be804348410cc03e48400cc1c380c0c1c380ea02b2b4b2ed0cf2ed13e906ea032130a4a8abed00e904e804e804e804e804e904e80b80f2fffffff05b0785f8052cbc8c3fc03f845f08e124209c84f013e507f00f3f0d3ff1ff931f1221e10de187107e61fc11045c
0840b81084f00fe50ef8879f02fea1fcffffbf83bc1c3c7cd224ff0b69925b9ae496837ff8998b22c9298790331192e4130c42bec4c397e462141c3471243eaec495e40a1f7f273ebe70501e6e8e70317e0d17a3e0a0fc02899497bfb9f9979b87979bf19ffcc6ffbf217c2c09fe12893f28ff7f2554fea3494a84442627ff7f
285c8c8327c9ff439ae47f214df2ca21e4e4a6f225f91fc825e46fb9845cf225f9dfcbffff8f26fe20fc7f00d130f33019ff11ff010000db0d140d580ca70bff0a610acc093f09bb083d08c7075707ee068a062c06d30580053105e604a0045d041f04e303ac03770345031603ea02c0029802730250022f020f02f201d601bb
01a2018b01750160014c013a01280117010801f900eb00de00d100c600ba00b000a6009d0094008c0084007c0075006f00690063005d00580053004e004a00460042003e003b003700340031002f002c002a0027002500230021001f001d001c001a001900170016001500140012001100100010000f000e000d00018319311d
313f31463150315a3164316e317b3185318f319931ac31b031f931fd3107321432be32f9330b34303442348734a134dd340f352b35493567357a35bd35cf3507363f365136c880c8ff018c01017f02018101027f02028102037f01038101047f010481010b7f06c880c8ff018a01c880c8ff018c01017e06c880c8ff018a0108
7f0ac880c8ff018a01037f0ac880c8ff018a01027f0ac880c8ff018b01018001017c01c880c8ff018b01027c01c880c8ff028102027f03028101ff018102017f03018101ff018801027802018801028801017802028801ff0187c8ff078001018101017f01018102017f03018101018202017e03018201018302017d03018301
018402017c03018401018502017b03018501018402017c03018401018202017e03018201ff0181c8ff01800101b401c880c8ff018001018b0101b401c880c8fff101f014f3060201ea06eb09ed00e90cf4e803ea05eb0ae803e803ed0ce803ed07ea07e900e804e804e804e804e918ea01ed00eb0de805ea07e90eed0ce807e9
0fe807e90ee807e913e807e918ed00eb0dea01e80ae80bea07ed0ce80de80de91ae80de80de90ce807e807e807ed00ea05eb00e9180040e811e80ee811e91be80eed0ce918e811e80ee811e91be80eea01eb0ded00e90ce812e918e812e90eed0ce807e90ce8070100f2f014ea05eb0aed00e900f4e803ea02eb0b188098ea08
eb00e802e802e802e802e802e802e802e802e802e802e802e802e808e808e905e808e907e808e900e808e808e808e808e905e808e907e808e900e808e808e902e806e806e903e806e806e902e806e806e907e806e806e90cea03e809e809e90ae809e809e908e809e90ae809e90ce809e809e809e809e90ae809e809e908e809
e90ae809e90ce809e809ea04e900e80ce80ce80ce80ce902e80ce80ce80ce80ce900ea08e806e806e806e806e806e806ea05eb00e90ce80fe80fe90ae810e90ce80fe90de810e90ce80fe90ae810e90ce80fe90de810e90ce80fe90ae810e90ce80fe90de810e90ce80fe90ae810e90ce80fe90de810e90ce80fe90ae810e90c
e80fe90de810e90ce80fe90ae810e90ce80fe90de810e902e806e806e900e806e8060100f21804989f9898a09f98989d989f98a09d9ff22404a424081f04202c2404a424081d041f2c2404a424081b041d2c2404a21f081b04182cf230083004300830043008b0b03004b03008f2184018109b9a961d401f109d1b0896989a18
4080a422109fa2a41d401f109d9b9a1840eb0cec0eea076b37086b35046b34086b32046b30086baf6bad6b2b046ba96b2808f2180498a4a4a29f9d9898a4a4ec0f661f0266a16622049f9d9bf2ec1066270466a766a76b00086b00046b8073a76bab73806bab7380a9a7a96ba7ec106b8066806b807300086b00046b806b8066
806b806b806b0014f2ed181804ed0098ed119fed1898ed0098ed10a0ed119fed0098ed1898ed009ded1898ed009fed1898ed10a0ed139ded009ff2ec0f66180466986698661802669866180466986618026698661804f2240ca42608270ca62408260ca422081d201b0c9d1f08220ca426082440f2240ca42608270ca92b0829
0cae29082620240ca72908270ca622082440f218082404abaeadab9818082404abaeadaba9f2ec0f691f046980a47380699f6980a46ba0698069a420081d0469806ba46b00026b80691f0469802408691f046980a46ba7698069a624086926046980a26b00026b80f222049d9a969a9da29da6a2a6a9a6a29d9af2ec10ed1366
1804ed00668c6b8ced136698ed006698668ced1f6b8ced006b98668f668fed106b9bed00668f6693ed186b93ed006b9f6b93f2ec10ed13661804ed0066986b98ed136698ed006698668ced1f6b8ced006b9866906690ed0f6b9ced0066906693ed186b93ed006b936b93f218049b9fa4989b9f98989b9fa4a7a6a49ff2240ca7
24082b0ca92708290ca624082220240ca72b082e0cab2e082c402b0cb02b08330cb23008320cae29083220330cb73308300cb330083140f2fffffff0ff68411d7fe392c9e492c9e492c9e492c964dc5c32f91fc925ffff5fc0cdf8472617e396ff64fccff8ffff46f9878bff29ffff9e31c6c518ff73c6ffff9731c618e3ff1f
f03fe4ffff1becffdfd8b819ff23feffbf828bff39171717ffff5fc5ffffff1fd8988dc92593c9b81937974c266332fe475cfcff7f89dcfc8fb8f9ffff36f9877ff89f70c9c5c5ff9cffff6f605cfccf183717ffffdfc7f81ff20fe37fc6ffff37c8ece27fc0b81937e37fccffff3730c6c57f5c5c5c5c5cfcff7f14d130df30
32ff11cc010000ae0edb0d140d580ca70bff0a610acc093f09bb083d08c7075707ee068a062c06d30580053105e604a0045d041f04e303ac03770345031603ea02c0029802730250022f020f02f201d601bb01a2018b01750160014c013a01280117010801f900eb00de00d100c600ba00b000a6009d0094008c0084007c0075
006f00690063005d00580053004e004a00460042003e003b003700340031002f002c002a0027002500230021001f001d001c001a001900170016001500140012001100100010000f000e000000f730fb30083112311c31263133313a316f319631cb3117326b328032a932b532c932ce32f032c880c8ff018b010182010c7f0d
__sfx__
ffff17c0065330e823312133e100309173ff773fb073fe66078721d1373fb303ff771f9063ff77178302b8673f7273ef773f5003cf773f3101f8473ff363cf773f31038f773f7203e8073ff3407e773f77520b26
1e69ea493f777166031e8203ff731c85330f10117100b26532d2608f0325564365413b01207b3105b760e14423e401c9202f017052663d97203d143124413a24031151523619a22011700931436d012d44333b07
90c726d9369012ec442f405253400f7033d00125855149702a0121ea6212240363071c4542440412436364030e94218a6026d6502a222815121f7024d152c4602192401d14196232901728544210453626336c50
9304d90f1143412a373884513171329063414113e710202707334233061e501091141376404a26234551303226e5616652099313126518b130496224210313061b4070d14012f060a4342677103173193110e062
0d63b21d07705021130703626c060765214512045363f10316a47091300b2650b831197312d616021110fb10258143f433263463ba2124d3000a113024209e011a3510cc412f04008d702c832059141740102775
f01bbf803c8342ea032de341a2640845526b06372322b43422c7733a361075032457035150d31528407047063f1241183524d4402770110613cb2711c30388113d311162023500202a0620627230450844423b40
6b48836a2de7401e2406f30380121aa230f8223b8312cc0033344132130b31217c31241473b44512c7720422211511c0241e8730477109e2035e060107000d7502710042013e90427271093470207704a0523827
0cea8a3503d020914407a231364536a2210226127642ea0614d5512a30343453277218a132377001d3126c62041522be341183211e052dd512682224032099213c66402326392321bd172b5662db35053442eb11
e149c2c225954242320be4431e0613616071702266406b750964417a20167113e543122660722220560211700845118f25380130ba7608b240187004a6638043320610f33124f7409e7201073191022171404151
7f90df783b2660ff032dd511c65502b762c34438f7708f773f81620f773f71138b473ff7731c473f7111ca203f7513f8173f93624f77047731cb673f7403e7711cb613cf772107727b2620f772fe072747107c77
8a080f0828c773fd111f14718c773ff211fb473ff543cb143ff7526b363ff7133f773ff7708a673ff7702c0530c36300133f7010c600000001e001374701c1700e6600b36013060265500235027050166400c440
330121011b6302e43007330261300a0303362021520144200b3200622005120080200e7101761023510334100541019310312100a21025110031102201004010277000c7003260019600026002d5001850005500
2b00290011400024003330026300193000d30001300362002c20022200192001120009200012003a100331002c10026100211001b10016100111000d1000810004100001003d000390003600033000300002e000
61336433260002400022000200001e0001d0001b0001a00018000170001600014000130001200011000100000f00000000174031b403224032940336403005030a503145031e50328503325033c5033f0130e313
01c880c803613266130671329713070232402302123251230b223342231d3230d4231d523136233862315723367230f0331b03308b0008f77018200384400a443f7000d60008b0008f7701c70014003f51001c00
017c01013f7000f600014770e84400a443f70003610094770484400a443f7000c600010670384400a443f70034500018200384400a443f700012100147703400016003f700016000147702400016003f70002600
08e80ce9026003ff070101001410028660085603c460cc5608c460184604846068460484606c5609c460d84604c460184606846088460a846088460c85604846170000184613846068460685603846088460a846
16e816ea0085601c460c8460f85604c5609c46018461684616c46008461684616c46058461684616c460a8461684616c460c8461684616c460e84616c460084616c460a84616c460984616c460784616c4606846
ea03e90c0284616c4605846168461685603c460484613846068461384606c560ac461084613c460484606c4604846088460c856048461485605c460c846058460784607c4600846070002a462388460381731310
ea03eb0a2a3202b3502976028320283302b330283202b340283302a710297002872028730287402875028740283702a32028731004002a7002872028330287302a71028740287502874028370293602a70028301
3238009a287012a3202930128711283302b330287112b340283302b3002a7102932028720287302a320293202a71028740283702a32028321004302a720293602872000430287300043028730293002873000421
03e90de832f070385603c4630c46018460585604c46198461385601c46018560384607856018461400001856038460584607c460d846098460bc5608846098460d8560484617c461985601846058461584607856
0ee80700098460bc5608846098460dc461385601c46248461085603c5608c460c84612c461c8461300028a4613c460b84606c5608c46048460584607c4610846098460d85604846140000e85605c460c84605000
360e37070e84607c460084607000380001aa1700011323320785126a511ae0223e1225951329711ea5132922242172462624a2224e1223e1223e1223a172b34032070324302b3303b0702b3402b3403905237430
0e3b0739360703743036070344303207030430323320783226a3226a3226a32329323293226a3232922242172462624a22329222fe722fe622de6232f56080130e01307c56060730ec5608c56084432a45307063
000ead000e433070330e023070130e003078171f4301fe5232d711fe521fe712b2171fe712be0221e6232d0221e6221e022d21721e022da172f0702f43034070324212f430320703443032070314302f0702d430
2a07adf207c623277107c712b2171fe712be711fe5232d711fe521aa512621718a4124e1223e7232d0221e6232f5608c56064720ec5608c5608c52004302ae5200e622b3302f0702b3402b340324302d05200061
3607370e2343023e7232d1223e7223e122f21723e122fa711ea52329711ea521ea712a2171ea712a21721e022d21721e022da172f0703143032070344303607037430390703b4303907000430390700043039070
2307240e3643039070004303907000430323330e023070330e403070130e023070330e433074030e000074030e000074030e443074530e443070230e000070230e0000781723070214301f0701d4211f43021070
65370700264302807029430280700043028070004302807024430260701f4301f4211fe611da611ca511aa1723070214301f0702142123430240702643028070294302b0702d4302b070004302b0700043000052
a62b0e2d0e426374300007028533070000e04637430000702a3202b533074560065600656376560065600266372660026600266372660026600a1729070294302b0702c4031f0521f0701d4301f0702906124421
2954f226074422ac4229a422a24215822242322a022154122a012145220e432074220e07207462149170005225070254302707029430290522807026430280702d4552e0522de522b662145422a44214d4229052
0780b2000785126a511ae0223e1225951329711ea5132941182171862618a611f4121c43018a172b34000070055302b330071702b3402b730055302b34000070055302b3300c1702b3400a5030005232f5608013
1b63fff00ec560602307c56080130e462074720e003310002a8172516007426186262462618e7124a172d4302de6232d6229d6225d6232f773ff77307172f0032e5753a3120ce671f813318373fa4406b453f722
e5086f383ff773f74221777138772f36724c512c9131123221d030b6072451631e7518434360311b133364521fc771b8200b6330ce503fc1438a473f6070422102947007400e17720320274003fa070fc1608450
18050343281423fc2003a3012b070347309f772001122c770af143fb000be7335f7700f7002e770b04334f1627d34017300683415010060311a8761000330a05217300e077213001850205a202786002e0031714
cf14fee310051067003ed362034037424084303f50504207307770a43023f713075023b160f07306724084700b4303f3473ea073fa0620b06170770843025f7030f773ff77272333e7750c67509c773785407f77
5246187822b1620f062230214e70313070360106f140bf24118540580031050029433834738c10307312714608040237401740624147002011e07606743248200363014e200f2130614027474184063c86030f07
730433040071002d4700d043814708c7300c0530c26304413f7013f31000000363701f07014560152602075035450142503c7402d54025340261402d7303b530104302a2300a130307201b6200a5203e32036220
a0009700377103e610086101551025410383100d310252103f1101b11039010190103b7001f700047002b600136003c5002750013500005002e4001d4000d4003e3002f3002230015300093003e2003320029200
160015000e200062003f10038100311002b100251001f1001a10015100101000b10007100031003f0003c000380003500032000300002d0002a00028000260002400022000200001e0001c0001b0001900018000
c734e13414000130001200011000100000f0000e00000000114031b40328403324030e5031b503255032f50339503036030d6031311302413195130b7131e7132f71305023320233012335123042231122321223
8101017f38323164232542333423215230262308b0008b4400a4408b0008f7701850014003e50001467014003b5003f7003f50001c00024003f5003f700016000147701400016000147701400016000147701400
c880c8ff014000aa443f3300060001c10044003d12008b0008f7701c50014003f11008b0008f770147702400012200147702c7701860014003e5000447708c7701c40014603f54008b0008f7701477014003e500
16e80be8313103334201400004002c7402a7002b3302d300293311d0041fa5607c4618c66008460b8460a8460c8460a8460b8460a8460c8460a8460d8460b8460a8460b8460a8460c8460a8460d8460b8460ac46
0de805e80a8460c8460a8460b8460a8460c8460ac46198460a8460a8460c8460a8460b8460ac46168460b8460ac46198460a8460a8460c8460a8460b8460ac46168460a8460bc460c84613846138461384613c46
eb02ed0004846058460484605846048460584604846048460584604c461084605c460d84605846058460584605846058460584604c4610846058460584606846058460684605846068460584606000189172a340
ed0ce811293312830129341283012d3601f004293412d300283502835029341283702d7302b00429341283702d36029771287602a340293312d36028770230222a7000b0022a3402b7102d300297412877029741
e804e8042a7001a0042a340283112d720230432a340297412d3002f02030a461185601c56020320095608c560384612c66054123cc660c46104c71293602a7202d3602832128321297602b3202d3002a34028320
19e80be8283202873029301287302976028730293012873028340297012d360024402834028340020102871032f46168460b8460ac46188460b8460ac46198460b8460ac46168460b8460ac46188460c8460cc46
a82604280ac461b8460c8460cc6600c460b84613846138460684606c460f84613846138461384613c461284606846048460584606846048460584606846048460400000a172d3602933126040250202606226040
00eb03402c04208c42280202902229060297412d340200432d3602502023e221c00122060280612a0202ba5601042308560803204c1225e022a3401c00125060280611f0201ee660cc460b84615c661884615c66
9ff2ec0900d460f85605c660c8461484614c46128460b8460a846108460c8460a8461045220010008172c74033100048003390000a660045600a660980000a0032b660941104c111fe712c3002b9222c7401fe71
f23204b42610004036002360023600a660045600236002360023600a172c7403201034e332fa1337a1337a1334e332fa2337a133720304c33342031442302c4330e2339e2339a0334e3330a2337a0334e332b002
0704879337e7232e332fa1337e7232633084720481337a0334e3330a2337a0334e3330a2337a033401037040000103002035e4330e2339a0339a0334e3330a2337a2337652300320484226a4232f461184605817
8f669b6713a660045607e1126d3026d113273004c3013e112c3002b9411ae611fa172c740070200723613e112c3002bd611aa6118a172c74026160040360c23618236186560e2360e6361a2361aa66090360f236
0080739d1b65611636116561d6361da172d7203200326001300032d710260012d3402be712d7202e04022e660381330a172804029020260602b50208822260202302121040230201d0602402032761048611da66
a367a3731fe712d3601d0401c0202c3001d6361c6171de7121e712d30032772144521003204412084120482226a2226a172b0202d672180320484229e1224a3223a171902019e222c3002561719e2219e2217e31
5c2704a817e1217e1216a3122a660081233931226361663622e3117e1227d123393122e3123a172900125202044610c071048021ea0200043290202a64210c22290202a0402a0202ca722ca720000432b5601042
0317072700a522a3402c0603602035a173ff773fb073f446016211f97721b360f1763eb06267713e3260c67338041237720e83438f10036033eb063f0033eb0602c162f0723087720310237703ef160f1703e320
007ff01707430074323f317307323f11731917378471fd003f72238f771f8060f00702e772984300f770c0650ce771dc160f8343f1600c67724b110b1001c06020b362f0763e30038241007731c8611c0611c865
c9ff80f1374320087722b0604c16263100747730834017731c2063c776008341f16120310388433975100c7732907274773250732770233063cf64388041f8063fd0438f103173138f771f3611c2613cf2401f04
f107ff1b3ff7238f300b67700f043f77724b063f100309073ff700180031f771f9043f8653c770008001b6073107606f773f200378473ff350ce1001e773fb6400f243ff7726f771f95509b431943038f7003e11
0037ff0006f04008340080003860310300060730800319073fa26227770ef24018073f81622b06223002377705f0405b471f9101b8670fd040d8773f72000877373603cf700072000e1003000380003091001650
__music__
00 17 1c 1c 2a
00 1c 1c 1c 0e
04 20 07 1e 1c
01 1b 1a 1c 1e
07 21 26 43 44
00 41 34 0e 2f
06 41 34 2f 34
05 2f 42 34 2f
03 34 31 43 34
07 31 34 36 44
07 34 31 32 2d
06 41 32 2d 32
05 2d 42 32 2d
03 32 2f 43 32
07 34 2b 2f 44
07 32 2f 30 2b
06 41 30 32 30
05 2b 42 30 2b
03 29 2d 43 30
07 2d 30 2d 44
07 30 29 28 2c
06 41 2f 2c 2f
05 2c 42 2f 2c
03 32 2d 43 32
07 2d 36 2d 44
07 39 2d 43 44
02 41 42 02 44
02 05 42 04 44
02 01 42 05 44
02 03 42 0a 44
02 0d 42 0b 44
01 41 42 28 07
07 26 24 1f 22
07 28 2b 29 28
07 26 24 1f 22
07 28 2b 29 29
07 24 21 1d 21
01 24 2d 09 2b
00 05 29 07 24
07 21 1d 21 24
00 29 09 27 05
03 41 42 43 28
06 07 26 24 1f
07 24 28 2b 29
03 41 42 43 28
06 07 24 1f 1c
07 24 1f 1c 18
07 1f 1c 18 13
07 1c 18 13 10
03 41 42 43 00
06 38 42 43 44
01 41 18 2d 19
00 00 0e 2d 1c
00 2e 0e 30 1c
01 32 00 0e 32
04 33 1c 35 37
00 00 0e 37 1c
04 38 0e 3a 3c
00 41 42 0e 44
01 41 42 00 0e
03 2d 00 2d 1c
00 2e 0e 30 1c
01 32 00 0e 32
04 34 1c 35 37
