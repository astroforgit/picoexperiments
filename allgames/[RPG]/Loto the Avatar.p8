pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--loto the avatar
--(c)@tekkamansoul
--music by unclesporky

function _init()
 cartdata("loto_the_avatar")
 scene,entrance,safe,onboat,“,i“,bm“,wait“,atk“,damage“,dis“,damaged,pinput,talking,cursel,leaveshop,lastmobroll,openshop=0,false,false,false,0,0,0,0,0,99,0,false,4,"none",0,false,0,nil
 --0:disabled 1:normal/walk 2;dead 3;shop 4;mainmenu 5:manual
 talktemp,itemstemp,yesno,selno,dark,actions,_st,_dg,_sw="",{},false,0,false,nil,"stick","dagger","sword"
 starvation,bgobj,fgobj,npc,loto,telep,effects,trophy,frig={stren=1},{},{},{},{},{},{},{},{}
 key,hunger,failspawn,magsel,ambush,px,py,pdir,moved=false,0,0,0,0,128,104,3,false
 plvl,gold,food,signs=1,100,50,{false,false,false,false}
 dungeoninit()
 makehero()
 equiphero()
 mobflash“,nextatk_wait,scrflash“,bossmsg,mobflash,flashing,boat,orbs=0,false,0,false,false,false,false,{false,false,false,false}
 curtgt,activemob,lastdmg,lastpdmg=loto,loto,0,0
 godain,dmgplayer,‰blocked,dissolvebg=false,false,false,false
 buildscene(90)
 music(8)
end

function equiphero()
  loto.mhp=plvl*30
  loto.mmp=plvl*5
  if(signs[0])loto.weap="blaster"
 if(loto.weap==_st)loto.stren=1+plvl+1
 if(loto.weap==_dg)loto.stren=1+plvl+3
 if(loto.weap==_sw)loto.stren=1+plvl+5
 if(loto.weap=="blaster")loto.stren=1+plvl+6
 if(loto.arm=="undies")loto.def=plvl
 if(loto.arm=="leather")loto.def=2+plvl
 if(loto.arm=="plate")loto.def=4+plvl
 if(signs[1])loto.stren+=1
 if(signs[2])loto.def+=1
 if(signs[3])loto.mmp+=5
end

function makehero()
  loto={spr=7,atktmr=0,mv=false,attacking=false,hp=30,mhp=30,
  mmp=5,mp=5,xp=0,x_act=px,y_act=py,arm="",def=0,stren=2,weap=""}
  loto.base=1
 end

function maketelep(_mx,_my,_scn,_tmx,_tmy,_faux,_st)
 t={mx=_mx,my=_my,scn=_scn,tmx=_tmx,tmy=_tmy,st=_st}
 t.faux=false
 t.faux=_faux
 add(telep,t)
end

function makemerch(_n,_x,_y,_t,store)
 n={spr=0,name=_n,x=_x*8,y=_y*8,t“=0,talk=_t}
 --store types: 1(weapon)2(armor)3(food)4(boat)
 n.store=store
 n.items={}
 if n.store!=0 then
   if n.store==1 then
    n.items={_st,_dg,_sw}
    n.prices={50,200,1000}
   elseif n.store==2 then
    n.items={"undies","leather","plate"}
    n.prices={50,300,1400}
   elseif n.store==3 then
    n.items={"10 food","100 food"}
    n.prices={5,50}
   else
    n.items={"nice boat"}
    n.prices={100}
   end
 end
  
 add(npc,n)
end

function makeboat(x,y)
 frig.x=x*8
 frig.y=y*8
end

function makenpc(_n,s,x,y,_t,_p)
 n={name=_n,x=x*8,y=y*8,spr=s,base=s,talk=_t,t“=0,p=0}
 if(_p)n.p=_p
 add(npc,n)
end

function makefx(i,_x,_y)
 fx={x=_x,y=_y,frames=3,spr=26}
 fx.next=0
 if i==1 then
  fx.spr=29
  fx.frames=2
 end
 add(effects,fx)
end

function animate‰()
 if “%15==0 then 
  loto.spr+=1
  if(loto.spr>loto.base+1+(pdir*2))loto.spr=loto.base+(pdir*2)
 end
end

function changedir‰(d)
 pdir=d
 loto.spr=loto.base+(pdir*2)
end

function move‰(d)
 if(d==0)px-=4
 if(d==1)px+=4
 if(d==2)py-=4
 if(d==3)py+=4
end

function scrwipe(s)
 palt(0,false)
 local ix=127
 local iy=0
 camera()
 for i=1,12 do
  for iz=i,12*i do
   for j=1,128 do
    pset(ix-i-iz+2,iy+j-1,0)
   end
  end
  flip()
 end
 camera()
 if(s)then
  print(s,5,116,7)
 for w=0,30 do
  flip()
 end
end
 palt(0,true)
end


function ‰attack()
 loto.attacking=true
 pinput=0
 ticktock()
 local fxx=px
 local fxy=py
 if pdir==0 then 
  px-=4
  fxx=px-4
 elseif pdir==1 then
  px+=4
  fxx=px+4
 elseif pdir==2 then
  py-=4
  fxy=py-4
 else
  py+=4
  fxy=py+4
 end
 makefx(0,fxx,fxy)
 if(flr(rnd(10))<2)then
  mobflash=false
  sfx(0)
 else
  findcurtgt()
  hurt(curtgt,loto)
  mobflash“=0
  mobflash=true
 end
 actions=cocreate(taketurns)
end

function findcurtgt()
 local tgtx=px
 local tgty=py
 if(pdir==0)tgtx=px-4
 if(pdir==1)tgtx=px+4
 if(pdir==2)tgty=py-4
 if(pdir==3)tgty=py+4
 for m in all(npc) do
  if(m.x==tgtx and m.y==tgty)then
    curtgt=m
  end
 end
end

function flash‚()   
   local m=curtgt
   for p=1,15 do
    pal(p,6)
   end
   spr(m.spr,m.x,m.y)
   pal()
end

function killplayer()
 actions=nil
 loto.spr=13
 pinput=2
 dissolvebg=true
 onboat=false
 frig.x,frig.y=14,12
 gold=ceil(gold/2)
end

function checklvlup()
if plvl<8 then
 if loto.xp>=((plvl*plvl)*40) then
  plvl+=1
  loto.mhp+=30
  loto.hp+=30
  loto.mmp+=5
  loto.mp+=5
  equiphero()
 end
 end
end

function hurt(a,b)
  if a==loto then
   lastpdmg=b.stren+flr(rnd(2))-loto.def
   if b==starvation then
    lastpdmg=1+flr(rnd(2))
   end
   if(lastpdmg<1)lastpdmg=1
   a.hp-=lastpdmg
  else
   lastdmg=b.stren+flr(rnd(2))
   a.hp-=lastdmg
  end
 if a.hp<=0 then
  if a!=loto then
   loto.xp+=a.xp
   checklvlup()
   gold+=a.gold
   if a.trophy then
    add(trophy,a.trophy)
    bossmsg=true
    bm“=0
   end
  else
   killplayer()
  end
  sfx(2)
  del(npc,a)
  if a.mondain then
    ::_::
    camera()
    cls()
    print("you did it!!!’’’’’\nthe evil dragonlord mondain has\nbeen defeated once and for all,\nand the princess laura has been\nsafely returned to lorasia.\n\nwhat comes next for our hero?\n\nfame? glory? turn-based combat?\n\nwho knows!\n\nbut thanks for playing anyway!!\n\n(c)tekkamansoul,unclesporky",7)
    flip()
    goto _
  end
  curtgt=loto
 else
  sfx(1)
 end
end


function savegame()
 local a_int
 local w_int
 if loto.weap==_st then
  w_int=1
 elseif loto.weap==_dg then
  w_int=2
 elseif loto.weap==_sw then
  w_int=3
 elseif loto.weap=="blaster" then
  w_int=4
 end
 if loto.arm=="undies" then
  a_int=1
 elseif loto.arm=="leather" then
  a_int=2
 elseif loto.arm=="plate" then
  a_int=3
 end
 dset(0,loto.hp)
 dset(2,loto.mp)
 dset(4,loto.xp)
 dset(5,a_int)
 dset(6,w_int)
 dset(7,plvl)
 dset(8,gold)
 dset(9,food)
 if boat then dset(10,1) else dset(10,0) end
 local t=0
 for c=1,#trophy do
  if trophy[c]=="cube" then dset(11,1) end
  if trophy[c]=="lich" then dset(12,1) end
  if trophy[c]=="crawler" then dset(13,1) end
  if trophy[c]=="balron" then dset(14,1) end 
 end
 for h=1,4 do
  if orbs[h] then dset(h+14,1) end 
 end
  for k=1,4 do
   if signs[k-1] then dset(k+18,1) end
  end
 if key then dset(23,1) end
end 

function loadgame()
 
 loto.hp=dget(0)
 loto.mp=dget(2)
 loto.xp=dget(4)
 loto.arm=""
 if dget(5)==1 then
  loto.arm="undies"
 elseif dget(5)==2 then
  loto.arm="leather"
 elseif dget(5)==3 then
  loto.arm="plate"
 end
 loto.weap=""
 if dget(6)==1 then
  loto.weap=_st
 elseif dget(6)==2 then
  loto.weap=_dg
 elseif dget(6)==3 then
  loto.weap=_sw
 elseif dget(6)==4 then
  loto.weap="blaster"
 end
 plvl=dget(7)
 gold=dget(8)
 food=dget(9)
 if dget(10)==1 then boat=true else boat=false end
 if dget(11)==1 then add(trophy,"cube") end
 if dget(12)==1 then add(trophy,"lich") end
 if dget(13)==1 then add(trophy,"crawler") end
 if dget(14)==1 then add(trophy,"balron") end
 for u=15,18 do
  if dget(u)==1 then orbs[u-14]=true end
 end
 for b=19,22 do
  if dget(b)==1 then signs[b-19]=true end
 end
 if dget(23)==1 then key=true end

 equiphero()
end

function collide‰(d)
 if(pdir!=d)changedir‰(d)
 local mx=0
 local my=0
 --lrud
 if d==0 then
  mx-=8
 elseif d==1 then
  mx+=8
 elseif d==2 then
  my-=8
 elseif d==3 then
  my+=8
 end
 ox=flr(px+mx)
 oy=flr(py+my)
 for n in all(npc) do
  if n.x==px+mx then
   if n.y==py+my then
    if n.spr<64 or n.spr>111 then
     n.t“=0
     talking=n.name
     if(n.store!=0)then
      talktemp=n.talk
      itemstemp=n.items
     end
     if n.name=="hawkwind" then
      loto.hp=loto.mhp
      loto.mp=loto.mmp
      savegame()
      scrflash“=0
      sfx(10)
      flashing=true
     end
     return true
    else
     ‰attack()
     return true
    end
   end
  end
 end
 local mg=mget(flr(ox/8),flr(oy/8))  
 if onboat then
  if not fget(mg,4) then
   if not fget(mg,0) then
    if mg!=0 then
     onboat=false
     frig.x=px
     frig.y=py
     loto.mv=true
     loto.base=1
     changedir‰(pdir)
     return false
    else
     return false
    end
   end
   return true
  else
   return false
  end
 end
 
 if fget(mg,0) then
  if(frig.x==ox and frig.y==oy)return false
  return true
 else
  return false
 end
end

function fl5(n)
cls(n)
for c=0,5 do
   flip()
   end
end

function checktile()
 local tx=flr(px/8)
 local ty=flr(py/8)
  for j in all(telep) do
   if j.mx==tx and j.my==ty then
    sfx(11)
    scrwipe()
    if j.faux!=true and moved then 
     tlpt(j)  
     return
    else
     faketele(j)
     return
    end
   end
  end
  if scene<4 then
   if(px==frig.x and py==frig.y and not onboat)boardboat()
   if px<0 then
    scrwipe("sailing west...")
    if scene==0 then
     tlpt({tmx=62,tmy=flr(py/8),scn=1})
    elseif scene==2 then
     tlpt({tmx=62,tmy=flr(py/8),scn=3}) 
    end
   end
   if px>=(256+((mapdx-1)*8)) then
    scrwipe("sailing east...")
    if scene==1 then
     tlpt({tmx=0,tmy=flr(py/8),scn=0})
    elseif scene==3 then
     tlpt({tmx=0,tmy=flr(py/8),scn=2})
    end
   end
   if py<0 then
    scrwipe("sailing north...")
    if scene==0 then
     tlpt({tmx=flr(px/8),tmy=63,scn=2})
    elseif scene==1 then
     tlpt({tmx=flr(px/8),tmy=63,scn=1})
    end
   end
   if py>504 then
    scrwipe("sailing south...")
    if scene==2 then
      tlpt({tmx=flr(px/8),tmy=0,scn=0})
    elseif scene==3 then
     tlpt({tmx=flr(px/8),tmy=0,scn=1})
    end
   end
   if (scene==0 or scene==2) and px>248 then
      scrwipe("sailing east...")
      tlpt({tmx=32,tmy=flr(py/8),scn=scene+1})
   end
   if (scene==1 or scene==3) and px<256 then
    scrwipe("sailing west...")
    tlpt({tmx=31,tmy=flr(py/8),scn=scene-1})
   end
   if (scene==0 or scene==1) and py>248 then
    scrwipe("sailing south...")
    tlpt({tmx=flr(px/8),tmy=32,scn=scene+2})
   end
   if (scene==2 or scene==3) and py<256 then
    scrwipe("sailing north...")
    tlpt({tmx=flr(px/8),tmy=31,scn=scene-2})
   end
 end
 if fget(mget(flr(px/8),flr(py/8)),6) then
  s={t“=0,spr=0,name="signpost"}
  talking=s.name
  if scene==0 and not signs[0] then
    if loto.weap==_sw then
    signs[0]=true
    loto.weap="blaster"
    s.talk="you found a\n magical blaster weapon!"
   else
    s.name="loto"
    talking=s.name
    s.talk="nothing out of the\n ordinary."
   end 
  elseif scene==1 and not signs[1] then
   signs[1]=true
   s.talk="the strength of\n heroes flows! +1 str!"
   fl5(14)
  elseif scene==2 and not signs[2] then
   signs[2]=true
   s.talk="the courage of\n heroes flows! +1 def!"
   fl5(11)
  elseif scene==3 and not signs[3] then
   signs[3]=true
   s.talk="the wisdom of\n heroes flows! +5 mp!"
   fl5(12)
  end
  if(s.talk)add(npc,s)
  equiphero()
 end
end

function boardboat()
 onboat=true
 loto.base=120
 loto.spr=120+2*pdir
end

function gobritish()
 dissolvebg=false
 loto.hp=1
 t={tmx=71,tmy=2,scn=4}
 tlpt(t)
 pinput=1
 pal()
end


function tlpt(t)
 changedir‰(3)
 for ob in all(fgobj) do
  del(fgobj,ob)
 end
 for ob in all(bgobj) do
  del(bgobj,ob)
 end
 for ob in all(npc) do
  del(npc,ob)
 end
 for ob in all(effects) do
  del(effects,ob)
 end
 px=t.tmx*8
 py=t.tmy*8
 loto.x_act=px
 loto.y_act=py
 loto.mv=false
 if scene<5 then
  entrance=true
 end
 scene=t.scn
 for ob in all(telep) do
  del(telep,ob)
 end
 buildscene(scene)
 
end

function faketele(t)
 px=t.tmx*8
 py=t.tmy*8
 loto.x_act=px
 loto.y_act=py
 loto.mv=false
end

function newmob(x,y,s)
 m={destx=px,desty=py,adjacent=false,tgtsq=flr(rnd(9)),o_x=0,o_y=0,x=x*8,y=y*8,
 lvl=plvl,hp=plvl*20,xp=50,gold=100,stren=loto.stren}
 if s=="despise" then
  m.spr,m.base=104,104
  m.trophy="cube"
 elseif s=="savage" then
  m.spr,m.base=106,106
  m.trophy="lich"
 elseif s=="doom" then
  m.spr,m.base=108,108
  m.trophy="crawler"
 elseif s=="violence" then
  m.spr,m.base=110,110
  m.trophy="balron"
 elseif s=="dain" then
  m.spr,m.base,m.mondain=96,96,true
  m.hp=m.hp*2 
 end
  
 add(npc,m)
end

function spawn(side,dng)
 m={destx=px,desty=py,adjacent=false,tgtsq=flr(rnd(9))}
 local offset=24
 if(dng!=true)offset=64
 m.lvl=ceil(rnd(plvl))
 m.hp=4*m.lvl+(flr(plvl))
 m.xp=ceil(1.75*m.lvl)
 m.gold=flr(m.xp*(1+rnd(2)))
 m.stren=(2*m.lvl)+1
 m.spr=64+(2*flr(rnd(2)))+(4*(m.lvl-1))
 m.base=m.spr
 
 local newsd=flr(rnd(4))
 local ct=flr(rnd(17))*8
 if side==0 then
  m.x=max(camxmin,px-offset)
  m.y=(py-offset)+ct
 elseif side==1 then
  m.x=min(camxmax+128,px+offset)
  m.y=(py-offset)+ct
 elseif side==2 then
  m.x=(px-offset)+ct
  m.y=max(camymin,py-offset)
 elseif side==3 then
  m.x=(px-offset)+ct
  m.y=min(camymax+128,max(py+offset,128))
 end
 local fx=flr((m.x)/8)
 local fy=flr((m.y)/8) 
 if fget(mget(fx,fy),0) then
  failspawn+=1
  if(failspawn<20)spawn(side)
  return
 end
 if m.x<0 or m.y<0 or m.x>camxmax+128 or m.y>camymax+128 then--todo: upper region
  failspawn+=1
  if(failspawn<20)spawn(newsd)
  return
 end
  if fget(mget(fx-1,fy),0) then
   if fget(mget(fx+1,fy),0) then
    if fget(mget(fx,fy+1),0) then
      if fget(mget(fx,fy-1),0) then
        failspawn+=1
        if(failspawn<20)spawn(newsd)
        return
      end
    end
  end
end
 for mn in all(npc) do
  if mn.x==m.x then
   if mn.y==m.y then
    failspawn+=1
    if(failspawn<20)spawn(newsd)
    return
   end
  end
 end
 m.o_x=0
 m.o_y=0
 add(npc,m)
 failspawn=0
end

function ticktock()
  hunger+=1
  if not dark and rnd(2)>1 then ambush+=1 end
  if dark then ambush+=1 end
  if ambush>4 then
   ambush=0
   if(#npc<10 and not safe)spawn(flr(rnd(4)),dark)
  end
 if hunger>15 then
  hunger=0
  if food>0 then
   food-=1
  else
   hurt(loto,starvation)
   damaged=true
   damage“=0
  end
 end
end

function atk‚fx()
atkfx=true
end

function girafx()
 for r=0,4,1 do
  for o=-8,8,8 do
   for y=-8,8,8 do
    if abs(o)+abs(y)!=16 and o+y!=0 then
     circfill(px+o+3,py+y+3,r,8)
     circfill(px+o+3,py+y+3,r-1,9)
    end
   end 
  end
  flip()
 end
 for v=-8,8,8 do
 for b=-8,8,8 do
 for c=0,#npc do
  if npc[c] then
   if npc[c].hp then
    if npc[c].x==px+v and npc[c].y==py+b then
     hurt(npc[c],loto)
    end
   end
  end
 end
 end
 end 
end

function hoimifx()
 for c=0,15 do
  pal(c,12)
 end
 spr(loto.spr,px,py)
 for c=0,10 do
  flip()
 end
 cls(12)flip()pal() 
end

function flashp()
 for b=1,15 do
    pal(b,14)
  end
 spr(loto.spr,px,py)
 pal()
 flip()
end

function _update()
 “+=1
 if(“>32000)“=0
 if(bossmsg)bm“+=1
 
 if bm“>300 then bossmsg=false end
 if scene==90 then
  px=camxmin
  py=camymin
  if pinput==5 and btnp(5) then
   pinput=4
  end
 end
 
 if(flashing)scrflash“+=1
 if scrflash“>5 then 
  flashing=false
  scrflash“=0
  pal()
 end
 if(“%2==0 and dissolvebg)dis“+=1
 if dis“>15 then
  gobritish()
  dis“=0
 end
 if(damaged)damage“+=1
 if(damage“>90)damaged=false
 if(mobflash)mobflash“+=1

 if nextatk_wait then
  pinput=0
  wait“+=1
  if wait“>2 then
   atk‚(activemob)
   if lastmobroll>4 then
    dmgplayer=true
   end
   atk“+=1
   if atk“>3 then
    if dmgplayer then
      hurt(loto,activemob)
      damaged=true
      flashp()
      damage“=0
    else
     sfx(0)
    end
    nextatk_wait=false
    wait“=0
    atk“=0
    endturn‚(activemob)
    if(actions and costatus(actions)!='dead')then 
      atkfx=false
      coresume(actions)
    else
      actions=nil
      if(pinput==0)pinput=1
    end
   end
  end
 else 
  if actions and costatus(actions)!='dead' then
    wait“=0
    coresume(actions)
  else
   actions=nil
   if(pinput==0)pinput=1
  end
 end

 if loto.mv then
  moved=true
  move‰(pdir)
  loto.mv=false
  loto.x_act=flr(px/8)*8
  loto.y_act=flr(py/8)*8
  ticktock()
 end
 if loto.attacking then
  loto.atktmr+=1
  if loto.atktmr>3 then
   if(pdir==0)px+=4
   if(pdir==1)px-=4
   if(pdir==2)py+=4
   if(pdir==3)py-=4
   loto.attacking=false
   loto.atktmr=0
  end
 end
 --lrud movement
 if pinput==1 and not loto.attacking and not loto.mv and actions==nil then
  if btnp(0) then
   ‰blocked=collide‰(0)
   if not ‰blocked then
    loto.x_act-=8
    loto.mv=true
    move‰(0)
    if(pdir!=0)changedir‰(0)
    actions=cocreate(taketurns)
   end  
  elseif btnp(1) then
   ‰blocked=collide‰(1)
   if not ‰blocked then
    loto.x_act+=8
    loto.mv=true
    move‰(1)
    if(pdir!=1)changedir‰(1)
    actions=cocreate(taketurns)
   end
  elseif btnp(2) then
   ‰blocked=collide‰(2)
   if not ‰blocked then
    loto.y_act-=8
    loto.mv=true
    move‰(2)
    if(pdir!=2)changedir‰(2)
    actions=cocreate(taketurns)
   end
  elseif btnp(3) then
   ‰blocked=collide‰(3)
   if not ‰blocked then
    loto.y_act+=8
    loto.mv=true
    move‰(3)
    if(pdir!=3)changedir‰(3)
    actions=cocreate(taketurns)
   end
  end
  if btnp(4) then
   pinput=6 --menu
  end
 elseif pinput==3 then
  if(btnp(3))cursel+=1
  if(btnp(2))cursel-=1
  if(btnp(5))leaveshop=true
  if(btnp(4))then 
   shopsel(cursel)
   cursel=0
  end
 elseif pinput==4 then
  if(btnp(3))cursel+=1
  if(btnp(2))cursel-=1
  if(btnp(4))menusel(cursel)
 elseif pinput==6 then
  if btnp(5) then
   pinput=1
  elseif btnp(4) then
   if loto.mp>4 then
    if magsel==0 then
     hoimifx()
     loto.mp-=5
     loto.hp+=30
     if loto.hp>loto.mhp then loto.hp=loto.mhp end
     pinput=1
     actions=cocreate(taketurns)
    else
     girafx()
     loto.mp-=5
     pinput=1
     actions=cocreate(taketurns)
     end
   else
   end
  end
  if btnp(2) then
   if magsel==1 then
    magsel=0
   end
  elseif btnp(3) then
   if magsel==0 then
    magsel=1
   end
  end
 end
 if btnp()==0 and btn()==0 then
  i“+=1
 else
  if(not btnp(5) or not btn(5))i“=0
 end
 if btnp(5) or btn(5) then i“+=61 end
 
 if godain then
  pinput=9
  if “>1 then
  scrwipe()
  tlpt({tmx=72,tmy=44,scn=12})
  newmob(72,34,"dain")
  godain=false
  end
 end

 animate‰()
 if(not loto.attacking)camera(min(camxmax,max(camxmin,px-60)),min(camymax,max(camymin,py-60)))
end

function drawboat()
 if scene<5 and boat and not onboat then
  if “%30<15 then
   spr(120,frig.x,frig.y)
  else
   spr(121,frig.x,frig.y)
  end
 end
end

function _draw()
 cls()
 map(mapx,mapy,mapx*8,mapy*8,mapdx,mapdy)
 if(scene<90)then
  foreach(bgobj,drawbg)
  foreach(npc,drawnpc)
  drawboat()
  if(loto.hp>0)spr(loto.spr,px,py)
  if(loto.hp<=0)spr(13,px,py)
  if(mobflash)then
    if(mobflash“<=3)then
       flash‚()
    else
      mobflash=false
    end
  end
  foreach(fgobj,drawbg)
  if(dark)drawdark()
  foreach(effects,drawfx)
  if i“>60 or pinput==3 or pinput==6 then
   timedgui()
  end
  if pinput==6 then
    magicgui()
  end
  if(damaged)timedgui()
 else--scene>90
  if pinput!=5 then
   m={"new game","continue","manual"}
   showmenu(m)
   print("loto\n   the avatar",camxmin+30,camymin+20,7)
  elseif pinput==5 then
   cls()
   print("\nwelcome to loto: the avatar!\n\nthis is my very first attempt\nat a game jam! go me!!\n\nuse the arrow keys to move,\ntalk, and attack. the Ž button\nconfirms and — cancels.\n\nŽ also opens the magic menu.\nbuy food! visit shops!\n\nthe evil dragonlord mondain is\nthreatening sosaria! collect\nthe magic orbs, rescue the prin-\ncess,go back in time and de-\nfeat mondain before it's too\nlate!!\n\ngood luck, loto!   (press —)",camxmin,camymin,7)
  end
  end
  gui()
  foreach(npc,talk)
  if bossmsg then 
   palt(0,false)
   print("the beast is slain!!\n\nreturn to claim\n your reward!!",camxmin+33,camymin+35,0)
   print("the beast is slain!!\n\nreturn to claim\n your reward!!",camxmin+32,camymin+34,7)
   palt()
  end
  if not loto.attacking and not loto.mv and moved then 
   checktile()
  end
  if(flashing)flashscr()
  if(dissolvebg)dissolve(dis“)
end

function magicgui()
    local guix=px+8
    local guiy=py+4
    if px>camxmax+64 then guix-=38 end
    if py>camymax+108 then guiy-=16 end
    palt(0,false)
    rectfill(guix,guiy,guix+30,guiy+16,0)
    palt(0,true)
    print("hoimi\ngira",guix+8,guiy+2,7)
    if(loto.mp<5)print("hoimi\ngira",guix+8,guiy+2,5)
    palt()
    spr(14,guix,guiy+1+(magsel*6)) 
end

function drawdark()
 palt(0,false)
 rectfill(px-128,py-128,px-17,py+128,0)
 rectfill(px-128,py-128,px+24,py-17,0)
 rectfill(px-128,py+24,px+24,py+128,0)
 rectfill(px+24,py-128,px+128,py+128,0)
 palt(15,true)
 for c=0,5 do
  spr(30,px-16+(c*8),py-16)
  spr(30,px-16+(c*8),py+16)
  spr(30,px-16,py-16+(c*8))
  spr(30,px+16,py-16+(c*8))
 end
 palt()
end

function flashscr()
  for c=1,15 do
   pal(c,7)
  end
  flip()
 end

function dissolve(i)
  palt(0,false)
  for j=0,i do
   pal(j,0)
  end 
  flip()    
end

function drawfx(f)
 if(f.next<f.frames)spr(f.spr+f.next,f.x,f.y)
 if(“%2==0)f.next+=1
end

function gui()
 if not loto.attacking then
  guix=max(camxmin+2,min(camxmax+2,px-60))
  guiy=max(camymin+120,min(camymax+120,py+60))
  spr(36,guix,guiy)
  print(""..loto.stren.."",guix+8,guiy,1)
  print(""..loto.stren.."",guix+7,guiy+1,7)
  spr(37,guix+15,guiy)
  print(""..loto.def.."",guix+22,guiy,1)
  print(""..loto.def.."",guix+21,guiy+1,7)
  if orbs[1] then
    pal(15,11)
    spr(38,guix+100,guiy)
  end
  if orbs[2] then
   pal(15,2)
   spr(38,guix+106,guiy)
  end
  if orbs[3] then
   pal(15,10)
   spr(38,guix+112,guiy)
  end
  if orbs[4] then
   pal(15,8)
   spr(38,guix+118,guiy)
  end
  if key then spr(117,guix+60,guiy) end
  pal()
 end
end

function timedgui()
 if not loto.attacking then
 local guix=max(camxmin+92,min(camxmax+92,px+32))
 local guiy=max(camymin,min(camymax,py-60))
 if(px>guix-30)guix-=84
 palt(0,false)
 rectfill(guix-5,guiy+3,guix+31,guiy+40,0)
 palt(0,true)
 print("  hp:"..loto.hp.."\n  mp:"..loto.mp.."\nfood:"..food.."\n   g:"..gold.."\n  xp:"..loto.xp.."\n lvl:"..plvl.."",guix-4,guiy+4,7) 
 if(food<10)print("\n\nfood:"..food,guix-4,guiy+4,14)
 if loto.hp<=loto.mhp/4 then c=14 elseif loto.hp<=loto.mhp/2 then c=10 else c=7 end
 print("  hp:"..loto.hp,guix-4,guiy+4,c)
end
end

function checktrophies(n)
 for c in all(trophy) do
  if c=="cube" and n.name=="british" then
   n.talk="well done! now take\n my magic orb!!"
   orbs[1]=true
  elseif c=="lich" and n.name=="fuedal" then
   n.talk="a great feat!!\n you deserve this orb."
   orbs[2]=true 
  elseif c=="crawler" and n.name=="olumpus" then
   n.talk="magnificent!! you\n may have my orb!!"
   orbs[3]=true 
  elseif c=="balron" and n.name=="shamino" then
   n.talk="a true hero!\n take this magic orb."
   orbs[4]=true
  end
 end
 if n.name=="thief" then
  if orbs[1] and orbs[2] and orbs[3] and orbs[4] then
   n.talk="hero!! take this\n key and save the princess!"
   key=true
  end
elseif n.name=="princess" then
 n.talk="time is of the essence.\nwe must go to mondain now!"
 godain=true
 “=0
end
end

function talk(n)
 if(talking==n.name) then
  n.t“+=1
  palt(0,false)
  local urx=max(camxmin+2,min(camxmax+2,px-58))
  local ury=max(camymin+110,min(camymax+110,py+50))
  rectfill(urx,ury,urx+124,ury+12,0)
  palt(0,true)
  checktrophies(n)
  print(n.name..":"..n.talk,urx+1,ury+1,7)
  if n.items then
   showmenu(n.items)
   openshop=n
   pinput=3
  end
  if leaveshop then
   cursel=0
   yesno=false
   openshop.items=itemstemp
   openshop.talk=talktemp
   leaveshop=false
   n.t“=121
   pinput=1
  end
  if n.t“>120 and pinput!=3 then
   n.t“=0
   talking="none"
  end
 end
end


function drawnpc(n)
 if n.spr!=0 then
  if “%30==0 then
   n.spr-=1
  elseif “%15==0 then
   n.spr+=1
  end
  if(n.spr<n.base)n.spr+=1
 end
 if not n.p then
  pal()
 elseif n.p==2 then
  pal(4,9)
  pal(9,4)
  pal(1,3)
  pal(3,1)
  pal(13,8)
  pal(8,13)
  pal(14,2)
  pal(2,14)
  pal(10,9)
 end
 spr(n.spr,n.x,n.y)
 pal()
end

-->8
--scene builder
function buildscene(i)
  cursel=0
  moved=false
  talking="none"
  scene=i
 if i==0 then
  mapx=0
  mapy=0
  maketelep(15,13,4,71,14)
  maketelep(2,10,5,87,14)
  maketelep(3,16,51,100,55)
  if(boat and frig.x==nil)makeboat(14,12)
 elseif i==1 then
  mapx=32
  mapy=0
  maketelep(50,15,6,103,14)
  maketelep(43,27,7,119,14)
  maketelep(55,25,61,100,55)--55,25
 elseif i==2 then
  mapx=0
  mapy=32
  maketelep(18,49,8,71,17)
  maketelep(9,37,9,81,23)
  maketelep(18,54,71,100,55)
 elseif i==3 then
  mapx=32
  mapy=32
  maketelep(53,43,10,110,23)
  maketelep(43,58,11,119,17)
  maketelep(49,57,81,100,55)
 elseif i==4 then
  mapx=64
  mapy=0
  maketelep(71,15,0,16,13)
  maketelep(72,15,0,16,13)
  makenpc("man",17,69,5,"lord british gives magic\norbs for slaying beasts.",2)
  makenpc("adventurer",115,65,8,"the legendary beasts\n lurk at bottoms of dungeons.",2)
  makenpc("man2",17,75,13)
  makenpc("man4",17,67,1)
  makemerch("weaponsmith",75,12,"buy somethin',\n will ya!",1)
  makemerch("innkeep",67,2,"rations? 10 for 5gp,\n or 100 for 50gp!",3)
  makenpc("british",23,71,1, "go forth and slay an\ngelatinous cube!")
  makenpc("princess",41,76,1,"you're not supposed to\nbe here") 
  makenpc("hawkwind",11,73,2,"i have saved your game\nand restored you. now go.")
  makenpc("guard",46,78,4,"the princess is impris-\n oned for her own safety.")
  if key then
   mset(77,3,32)
  end 
elseif(i==5)then
  mapx=80
  mapy=0
  maketelep(87,15,0,2,9)
  maketelep(88,15,0,2,9)
  makemerch("shipwright",83,8,"i'll sell ya\n a boat fer cheap!",4)
  makenpc("man1",17,83,9)
  makenpc("boat",120,80,9)
  makemerch("armorsmith",93,12,"yew has the\n finest armors!",2)
  makenpc("man3",17,93,13)
  makemerch("innkeep",93,2,"ten rations for 5g,\n a hundred for 50.",3)
  makenpc("man4",17,93,1)
  makenpc("ranger",115,88,2,"i am on a quest for all\n four kings' magic orbs.")
  makenpc("man",17,94,4,"if i had a boat i'd sail\n to the other continents!",2)
  makenpc("guard b",46,90,12,"princess british knows\n how to stop mondain!")
  elseif i==6 then
  mapx=96
  mapy=0
  maketelep(103,15,1,50,16)
  maketelep(104,15,1,50,16)
  makenpc("fuedal",23,103,1,"it's good to be king!\n go and kill me a lich!",2)
  makenpc("attendant",17,98,2,"this is the king's\n private chamber.") 
  makemerch("innkeep",99,11,"times are tough.\n 10 for 5, 100 for 50.",3)
  makenpc("1",17,99,10)
  makenpc("guard",46,106,11,"this is the slums. if you\n have no business, keep out.")
  makenpc("drunk",17,108,8,"the signs...\n the signs know...",2)
  makenpc("girl",41,109,1,"why do some have so\n much and others so little?",2)
  makenpc("man",115,108,4,"a lich lurks in the\n dungeon savage, to the south.",2)
 elseif i==7 then
  mapx=112
  mapy=0
  maketelep(119,15,1,43,28)
  maketelep(120,15,1,43,28)
  makemerch("weaponsmith",116,2,"we got all the\n best deals.",1)
  makemerch("armorsmith",123,2,"best and only\n armors on the continent!",2)
  makenpc("1",17,116,1)
  makenpc("2",17,123,1)
  makenpc("farmer",17,115,9,"tilling is hard work.",2)
  makenpc("thief",115,123,9,"return with the orbs\n and i'll give you a key.",2)
  makenpc("girl",41,126,11,"you never know what you\n may learn through conversation.",2) 
  makenpc("guard",46,118,6,"there are rumors that\n mondain is a dragon.")
 elseif i==8 then
  mapx=64
  mapy=16
  maketelep(71,16,2,18,48)
  maketelep(72,16,2,18,48)
  makemerch("innkeep",76,22,"rations a-plenty.\n 10 for 5g, 100 for 50g!",3) 
  makenpc("olumpus",23,71,27,"eye oh he hum!\n hunt for me a carrion crawler!!",2) 
  makenpc("c",17,76,23) 
  makenpc("prophetess",41,66,22,"mondain can only\n be defeated in the past!",2) 
  makenpc("adventurer",115,67,29,"the dungeon doom\n is on the island to the south.",2) 
  makenpc("jester",17,74,28,"we are a town\n of bardic tradition.",2)
 elseif i==9 then
  mapx=80
  mapy=16
  maketelep(80,23,2,8,37)
  maketelep(80,24,2,8,37) 
  makemerch("armsman",84,18,"swords are life,\n kid. buy one.",1)
  makemerch("shieldsman",91,18,"plate is the\n only proper defense!",2) 
  makenpc("1",17,84,17)
  makenpc("2",17,91,17)
  makenpc("dupre",115,82,28,"visit the sign near\n britain when holding a sword.",2)  
  makenpc("fighter",46,92,28,"don't starve on\n your journeys.")
  makenpc("guardian",46,85,23,"we are a martial\n town. this is the coloseum.")
  makenpc("",64,87,24)
  makenpc("3",66,88,26)   
 elseif i==10 then
  mapx=96
  mapy=16
  makenpc("shamino",23,103,17,"hero!! go forth and\n slay an balron!!",2)
  maketelep(111,23,3,53,43)
  maketelep(111,24,3,53,43)
  makenpc("man1",17,106,30)
  makenpc("man2",17,98,30)
  makemerch("armorsmith",106,29,"defense comes first.",2)
  makemerch("innkeep",98,29,"rations a-plenty.\n 10 for 5, 100 for 50.",3)
  makenpc("man",17,99,22,"princess british can travel\n through time!",2)
  --makenpc("girl",41,107,18,"what do magic orbs\n actually do...?",2) 
  makenpc("guard",46,99,17,"ours is a peaceful land.")
 elseif i==11 then
  mapx=112
  mapy=16
  maketelep(119,16,3,43,57)
  maketelep(120,16,3,43,57)
  makemerch("innkeep",124,19,"buy some food or\n starve! yargh!",3) 
  makemerch("weaponsmith",115,19,"don't just walk\n around with a stick!",1)
  makenpc("m1",17,124,18)
  makenpc("m2",17,115,18)
  makenpc("traveler",115,113,26,"a thief in linda has\n the prison key.",2) 
  makenpc("warrior",46,123,24,"the dungeon of\n violence lies to the east.") 
  makenpc("man",17,117,29,"signposts have mystical\n powers. did you know?",2) 
 elseif i==12 then
  mapx,mapy=64,32
  pinput=1
  makenpc("",41,73,38)
 elseif(i==51)then --despise fl1
  makedungeon("despise",1)
 elseif(i==52)then
  makedungeon("despise",2) 
 elseif(i==53)then
  makedungeon("despise",3)
 elseif(i==54)then
  makedungeon("despise",4)
 elseif i==61 then
  makedungeon("savage",1)
 elseif i==62 then
 makedungeon("savage",2)
 elseif i==63 then
 makedungeon("savage",3)
 elseif i==64 then
 makedungeon("savage",4)
 elseif i==71 then
  makedungeon("doom",1)
 elseif i==72 then
  makedungeon("doom",2)
 elseif i==73 then
  makedungeon("doom",3)
 elseif i==74 then
  makedungeon("doom",4)
 elseif i==81 then
  makedungeon("violence",1) 
 elseif i==82 then
  makedungeon("violence",2)
 elseif i==83 then
  makedungeon("violence",3)
 elseif i==84 then
  makedungeon("violence",4)
 elseif(i==90)then
  mapx=112
  mapy=48
 end

 if i>3 then
  mapdx=16
  mapdy=16
 else
  dark=false
  mapdx=32
  mapdy=32
 end
 if i<50 then dark=false end
 if i>3 and i<12 then safe=true else safe=false end
 if i>50 and i<90 then
  dark=true
  mapx=96
  mapy=48
 end
 
 camxmin=mapx*8
 camxmax=((mapx+mapdx)*8)-128
 camymin=mapy*8
 camymax=((mapy+mapdy)*8)-128
 equiphero()
 if(onboat)boardboat()
end
-->8
--dungeon info
desp={}
savage={}
doom={}
violence={}

function dungeoninit()
    add(desp,"11x111s1d111111110001001000000111000111111111011111010000000001111001011111101111100100001011111110111110001001110000001010101111111110100010001100001010101000110010001000100011100111110110111e00000000000000w11111111111011111000000000000011111111n111111111")
    add(desp,"11111111u11111111000001000100001e01010100010010w101010100011111110101011010000011110111000100001e00000001000000w11000110001111111100011111111d011110011000001001111001100111110111100111001111011100011001110001110011110011000111000000000000011111111111111111")
    add(desp,"1111111s1111s111e00000000001010w11111110011101011d00000000010101100111111111010111110000000100011d1101111100010110110100010011111011011111001u111001000011001011100011001100101111100110100100111000100010010101101110111001010110000010000101011111111n1111n111")
    add(desp,"111s111111111111100001000000000111100100001000011u10000000100001101001000010000111111111111110111u0010100000000110001010000b00011110111000000001100000100000000110000011111111111000000000000001111111100000000110000010000000011000000000000001111n111111111111")
  add(savage,"111111111s1111111000000100000011e00110011111000w1110000100001111100011000110001110010001000100111001001x10010011100100101001001110000000000000111111011111011111100101010000000110000001111111011011110000000011101d0011101110011000000010100001111111111n111111")
  add(savage,"111111111111111110000000000000d111010101010100011000000000011101e01111111111d00w11d0000000010001100111111001111110000000000000011111111111111111e00000000000010w1110111111111101100000100011d1011011101010000101101u10101111110110000010000000011111111111111111")
  add(savage,"11111111111s11111d001000001000u110111110100000011000000011111111111111111111u00111u1110000d10001100000001001000111111111111110111d0011000000100110000000110000011111111101111101100000001000u10110111110101001011011111010001101100000001000110111111111111n1111")
  add(savage,"11111111111111111u00001000000001101010101111110110010010000000011010101001111111e000001001u1000w111111111101000110010001000100011u00000000010001100100010001000111111111111110111000011000010001100b000000010001100101010100000110010101010001111111111111111111")
add(doom,"1111111111111x1110000000000010011000000000001001100011111100100110001000d100100110001000010010011000100111001001100010011100100110001001110010011000100111001001100010000000100110001000000010011000111111111001100000000000000110000000000000011111111111111111")
add(doom,"11111111111111111000000000000001100111111111100110010001110d100110010010u1001001100011100100100110000000011000011111111111111111100000000100000110001110010000011001d010010000011001000011000001100111111100011110011111111111d1e00001000000000w1111111111111111")
add(doom,"11111111111s111110000000010001d1100011000101010110011110010u01011010000101000101100011000011100110000000000000011111111111111111100000011100001110011101100010011001u10100010011100101010010001110010001000100111d011101000010u1100000010000100111111111111n1111")
add(doom,"11111111s111111110000001010000u110100000010010011011111111001111e01000000001000w110011111111000111000000000000011111111111111001100000000000000110011111111111111001111111111111100110000b00000110011010101010011u01100101010101100110000000000111111111n1111111")
add(violence,"11111111111111111d01111110000001100000001001100111111110100110011000001010011001e00010101000000w1111101011111111e00000100000000w1001001000001111100100100001000110000011111000011101110000001001100000011100000111111111x1111101e00000000000010w1111111111111111")
add(violence,"11111111111111111u1001010101010110000000000000011111111111111001e00000000000010w111111111111001110000000000000011011111111111101e01000000010010w1010010111d10111e01001000001010w111001111111010110000000000001011111111111100101e00000000000010w1111111111111111")
add(violence,"11111111111111111d000000000000d110000000000000011000000000000001100011000011000110001100001100011000000000000001100000000000000110000000001000011000110001u100011000110000000001100000000000000110000000000000011d000000000000d110000000000000011111111111111111")
add(violence,"11111111111111111u010000000010u1100111010100100110000111100010011111000010001001100111101000100110000010100010011000001110000001111111111111111110000000000000b11001110001000001100111000111111111000000000000111u111110011111u110000000000000011111111111111111")
end

function makedungeon(s, fl)
 local c=0
 local dun={}
 if s=="despise" then dun=desp
 elseif s=="savage" then dun=savage 
 elseif s=="doom" then dun=doom
 elseif s=="violence" then dun=violence
 end
  --if(s=="despise")then
    for j=48,63 do
      for i=96,111 do
        local indx=(i-95)+((j-48)*16)
        local bloc=sub(dun[fl],indx,indx)
        if bloc=="1" then
         c=54--wall  
        elseif bloc=="x" then
         c=29
          if entrance==true then
           px=i*8
           py=j*8+8
           entrance=false
          end
          if s=="despise" then
           maketelep(i,j,0,3,17)
          elseif s=="savage" then
           maketelep(i,j,1,55,25)
          elseif s=="doom" then
           maketelep(i,j,2,18,54)
          elseif s=="violence" then
           maketelep(i,j,3,49,58)
          end
        elseif bloc=="e" then
         c=0
         maketelep(i,j,scene,i+14,j,true)
        elseif bloc=="w" then
         c=0
         maketelep(i,j,scene,i-14,j,true)
        elseif bloc=="n" then
         c=0
         maketelep(i,j,scene,i,j-14,true)
        elseif bloc=="s" then
         c=0
         maketelep(i,j,scene,i,j+14,true)
        elseif bloc=="d" then
         c=15
         maketelep(i,j,scene+1,i,j+1)
        elseif bloc=="u" then
         c=31
         maketelep(i,j,scene-1,i,j+1)
        elseif bloc=="b" then
         c=0
         newmob(i,j,s)
        else
          c=0
        end
        mset(i,j,c)
      end
    end
  --end
end

-->8
--sfx list:
--00:miss!
--01:hit!
--02:dead
-->8
--ai
function findnearesttop(n)
 for c=-1,1 do
  for d=-1,1 do
   if(abs(c)+abs(d)==2 or abs(c)+abs(d)==0)then
    “=“
   else
      if(fget(mget(flr((loto.x_act+(c*8))/8), flr((loto.y_act+(d*8)/8))),0)==true)then
        “=“
      else
        n.destx=loto.x_act+(c*8)
        n.desty=loto.y_act+(d*8)
        return
      end
   end
  end 
 end
 n.destx=loto.x_act
 n.desty=loto.y_act
end

function move‚(n)
findnearesttop(n)
local tgtx=n.x
local tgty=n.y
local xdis=n.destx-n.x
local ydis=n.desty-n.y
local col
local movex=false
if(abs(xdis)>=abs(ydis))then
  movex=true
 if(xdis>0)then
  tgtx=n.x+8
  tgty=n.y
 elseif(xdis<0)then
  tgtx=n.x-8
  tgty=n.y
 end
elseif(abs(xdis)<abs(ydis))then
  movex=false
 if(ydis>0)then
  tgty=n.y+8
  tgtx=n.x
 elseif(ydis<0)then
  tgty=n.y-8
  tgtx=n.x
 end
end
col=collide‚(n,tgtx,tgty) 
if(col==false)then
 n.x=tgtx
 n.y=tgty
else
 retrymove(n,movex)
end
end

function padjacent(n)
 for v=-1,1 do
  for b=-1,1 do
    if(n.x+(v*8)==loto.x_act and n.y==loto.y_act)return true
    if(n.y+(b*8)==loto.y_act and n.x==loto.x_act)return true
  end
 end
end

function taketurns()
 --for enemies
 for n in all(npc) do
 if(n.spr>63 and n.spr<111)then
  lastmobroll=flr(rnd(10))
  if(not padjacent(n))then
   nextatk_wait=false
   move‚(n)
  else
    n.o_x=flr(n.x/8)*8
    n.o_y=flr(n.y/8)*8
    pinput=0
    nextatk_wait=true
    wait“=0
   activemob=n
   yield()
  end
 end
end
end

function atk‚(n)
  if(activemob)then
   if py==n.y then
   if(px>n.x)then
    n.x=px-5
   elseif(px<n.x)then
    n.x=px+3
   end
  else
   if(py>n.y)then
    n.y=py-5
   elseif(py<n.y)then
    n.y=py+3
   end
  end 
end
end

function endturn‚(n)
  atk“=0
  if(n)then
   n.x=n.o_x
   n.y=n.o_y
 activemob=nil
end
end

function retrymove(n,xmov)
  local tgtx=loto.x_act
  local tgty=loto.y_act
 if(xmov==true)then
  local ydis=loto.y_act-n.y
  if(ydis>=0)then
   tgty=n.y+8
   tgtx=n.x
  elseif(ydis<0)then
   tgty=n.y-8
   tgtx=n.x
  end
 else
  local xdis=loto.x_act-n.x
  if(xdis>=0)then
    tgtx=n.x+8
    tgty=n.y
  elseif(xdis<0)then
   tgtx=n.x-8
   tgty=n.y
  end
 end
 col=collide‚(n,tgtx,tgty) 
 if(col==false)then
  n.x=tgtx
  n.y=tgty
 end
end

function collide‚(n,x,y)
 for i=1,#npc do--another npc?
  local it=npc[i]
  if(it!=n)then
   if(it.x==x and it.y==y)return true
  end
 end
 if(fget(mget(flr(x/8),flr(y/8)),0)==true)then
  if(fget(mget(flr(x/8),flr(y/8)),4)==true)then
   if(fget(n.spr,2)==true)then
    return false
   end
  end
  return true
 end
 if(loto.x_act==x)then
  if(loto.y_act==y)return true
 end 
 return false
end

-->8
--menus
function showmenu(obj)
 if(cursel>=#obj-1)cursel=#obj-1
 if(cursel<0)cursel=0
 palt(0,false)
 rectfill(camxmin+2,camymin+50,camxmin+55,camymin+50+#obj*7,0)
 palt(0,true)
 for z=1,#obj do
  c=obj[z]
  print(c,camxmin+10,camymin+51+(7*(z-1)),7)
 end
 spr(14,camxmin+2,camymin+51+(7*(cursel)))
end

function menusel(cursel)
 if cursel==0 then
 scrwipe()
  buildscene(0)
  pinput=1
  px=128
  py=104
 elseif cursel==1 then
  
  if(dget(0)>0)then
   scrwipe()
   loadgame()
   pinput=1
   px=568
   py=16
   buildscene(4)
  else
   menusel(0)
  end
 else
  pinput=5
 end
end

function shopsel(cursel)
--not update
  yn={"yes","no"}
  local w="that's weaker!!"
  sel=openshop.items[cursel+1]
  if(openshop.store!=3)then
    if(not yesno)then
      
      if(sel==loto.weap or sel==loto.arm or (sel=="nice boat" and boat))then
        openshop.talk="you already\n own that!"
      elseif(loto.weap==_dg and sel==_st)then
        openshop.talk=w
       elseif loto.weap==_sw and (sel==_dg or sel==_st) then
        openshop.talk=w
       elseif loto.weap=="blaster" and openshop.store==1 then
        openshop.talk=w
       elseif loto.arm=="leather" and sel=="undies" then
        openshop.talk=w
       elseif loto.arm=="plate" and (sel=="leather" or sel=="undies") then
        openshop.talk=w
       else
        openshop.talk="that's "..openshop.prices[cursel+1].." gp.\n sound good?"
        openshop.items=yn
        selno=cursel+1
        showmenu(yn)
        yesno=true
       end
      
    else
      if(cursel==0)then --yes
        if(gold>=openshop.prices[selno])then
           gold-=openshop.prices[selno]
           if(openshop.store==1)loto.weap=itemstemp[selno]
           if(openshop.store==2)loto.arm=itemstemp[selno]
           if(openshop.store==4) then
            boat=true
            makeboat(3,11)
           end
           equiphero()
           yesno=false
           leaveshop=true
        else
          openshop.talk="can't afford it!"
        end
      else
        yesno=false
        leaveshop=true
      end
    end
  elseif openshop.store==3 then
    if sel=="10 food" then
      if gold>=5 then
        food+=10
        gold-=5
        openshop.talk="thank ye kindly."
      else
        openshop.talk="yer broke, ya bum!"
      end
    elseif sel=="100 food" then
      if gold>=50 then
        food+=100
        gold-=50
        openshop.talk="thank ye kindly."
      else
        openshop.talk="yer broke, ya bum!"
      end
    end
  end 
end

__gfx__
0000000000000d000cccddc000d000000cddccc0d000000dd000000dd000000dd000000d6666666666666666000000000b222220004444000000000055555555
000000000cccddc00f7fccc00cddccc00cccf7f0dccccccddccccccddccccccddccccccd5d655d65d65d65d60b222220055522200449a44000a0000050000005
000000000f7fccc00f5fccc00cccf7f00cccf5f00cccccc00cccccc00c7ff7c00c7ff7c05d655d65d65d65d6055522200fff2220049aaa409944444050400405
000000000f5fccc000fcdd000cccf5f000ddcf000cccccc00cccccc00c5ff5c00c5ff5c066666666666666660fff222000f2cc000449a440aa99999450444405
0000000000fcdd000011c10000ddcf00001c110000cccc0000cccc0000cffc0000cffc005d655d65d65d65d600f2cc00001121c00549a45000a0000050400405
000000000011c10000ccfc00001c110000ccfc00cc1111cccc1111cccc1111cccc1111cc5d655d65d65d65d6001121c00022f20c005444000000000050444405
0000000000ccfc000cc0011000ccfc000cc001100fcccc0ff0ccccf00fcccc0ff0ccccf066666666d65d65d60022f2c00222211c005444000000000050400405
000000000011cc00000000000011cc00000000000011cc0000cc11000011cc0000cc11005d655d65666666660011220c00000000005555000000000055555555
60cccc06004444000044440053bb53535555555545454545333533330a6aa6a00a6aa6a065666665000000000000000000000000777777770f0f0f0f55455455
dd7ff7dd04f4ff4004f4ff403b33b3355dddd4655454545433575335caaaaaa00aaaaaa0d65555d600000770000007700000000076444465f0f0f0f050400405
0c0ff0c0045ff540045ff5405bbbbb53544dddd54545454555677556d65ff560c65ff560d65555d6000077000000770000000000747777450f0f0f0f50444405
00cffc0000ffff0000ffff0033545335566dd4455454545465666675d6ffff60d6ffff606666666600070000000777000007700074777745f0f0f0f050400405
dd1111dd11111d1111111d113b333bb35dddd6654545454556650666f1166111d1166111d655d0d6000000000007700000770000747777450f0f0f0f50444405
ccdc5dccf011adf00f11ad0fbbb5b33b5446ddd55454545466500066d444444ff44444f0d655ddd600000000007700000070000074777745f0f0f0f050400405
0fcccc0f001dd100001dd1005433bbbb5446ddd54545454566500056d1111110d111111066666666000000000070000000700000747666450f0f0f0f50000005
0001cc0000445000000544003353354355555555545454546550006501111220d2211110565555d600000000000000000000000074666645f0f0f0f055555555
555d5555000000000333333000000000000000000000000000000000554444555555555500aaaa0000aaaa00111111119f11111130000000000d6000000d6000
55d5d555000333333bbbbbb33000000000000590055555500000000054444445444444440aaaaaa00aaaaaa01111111139f171110445454000d6660000d66600
5d555d550033bbbbbb33bb3bb3333000000059a005999a500006600059444445544545540a5ff5a00a5ff5a011111c11b9f11111055455500dd556600dd55660
d55555d5003bbbb3bbbbb33bbbbb330050059a5005999a500067f60054999995455454450affffa00affffa01711111139111111045444500dffff600dffff60
5d55555d0033bbbbb3333333bb3bb3009559a50005999a50006ff6005544445544444444eaeeeeaeeaeeeeae1111111c9f111111000040000d6dd6600d6dd660
55d555d5000333333333333bb4bb3300999a500005999a50000660005545545599999999f2a22af00fa22a2f1ff11ff139f11c1133304033dd5665dddd5665dd
555d5d550000334333bbbb334bb333005a950000005aa5000000000055555555555545550eeeeee00eeeeee0f999f99f39f11111333040330f6dd60ff06dd6f0
5555d55500000003433333543333000095995000000550000000000055555555555555550eeee110011eeee093b393399f1c111133b040b30066050000506600
33333333111111113bb3bbb343434343333348333335333377777777988888841c1c1c1c5b5553551111c1f99333333393393b39333333399f1111111c1111f9
3b3b333311111c110333333034343434535345353357533576d6666548989889c1c1c1c13f353bf511111f93ff933b33f99f999f333339ff3ff1111c11111ff3
33b33333c1111111004244404343434365654656556775567d666665988989841c1c1c1cb3bfbfb311c11f931ff933331ff11ff13b339ff139ff11111117ff93
333333331111111104224940343434345d6666656566667576d6666548989889c1c1c1c15bfb3b35111111f911ff9333c11111113339ff11339ff711111ff933
3333333311171111042949404343434356d66665566576667d666665988989841c1c1c1c524b4b2511111193117ff93311111171339ff1113339ff1111ff9333
3333b3b3111111c1d2994440343434345d6556656665756676d6666548989889c1c1c1c15222222511111f9b1111ff9311c1111139ff711133339ff11ff933b3
33333b331c111111029d449d4343434356500565665766567d6d6665988989841c1c1c1c5121121511171f93c1111ff3111111113ff1111133b339ffff933333
3333333311111111d4d0dd4d343434345d500565356666637555555548888889c1c1c1c152121125111111f9111111f9111111119f1111c13333333993333333
000000000000000000000000020000200ee00ee00000000000000000000660000000009000000000000770000007700920000002022112200007700000077000
00000000000050000000000022000022000ee2000ee00ee000066000f06556000000a00909000000007667090076670902211220202112020075570000755700
000500000055c50002000020227227220099eeee000ee200006556000655556f00aaaaa0900a0000075775790757757700211200002222007767667777676677
005c5500057cc7502272272222522522097979000099eeee06555560005666000aaa90000aaaaa00705775070757750000222200000222007776677777766777
057cc7505c5cc5c522522522002882000959599009797900f056660f0056660090090a000009aaa0005335000053350000022200000222007077760600667707
5c5cc5c55cc88cc52228822200022000098899090959599000566600006566009900009000a09009002222000022220000022200002220000066776000777606
5cc88cc505cccc502002200200200200008999900888990900656600066555600000099009000099005005000050050000222000002200006077070066707700
05cccc50005555000020020000000000000000000099999006655560000000000000000009900000000006000060000000220000000000000677000000007700
002227070000000004000040000000000700007000000000005f55000055f5000099990000999900000600000006000000000000033300000000000000000000
077228287722270704744740040000400502205007000070056ff650056ff6500095590000955900000dd000000dd0000333000003bb37000000000000005000
76722999077228280084480004744740002ee200050220505f5ff5f55f5ff5f599aaaa9999aaaa9900d55d0000d55d0003bb3700003bb5300005000000557500
7662f990767229990414414000844800002fe200002ee2005ff88ff55ff88ff5999aa999999aa999605ddd06605ddd06333bb5303333bbb30056550005766750
067f00007662f990041111440414414002eefe20002ef20005ffff5005ffff5090999a0000a99909dd5226d4dd5222dd3b3bbbb33bbb33300576675056566565
7722ff20002f0000004444004411114002eefe2002efee200d0d0d0000dddd0000a9990000999a000d252240d02574403bb3333033b33f005656656557688665
700222000022ff200088020000444400022fe22002efee200d0d0d0000d0d0d00099090000909900002227000022720033b3bf000b3bbf305768866505776650
0000000000022200000000000020880002000020222ef2220d0d00d000d0d0dd009900000000990000112070000211000b3bbf30bb0000000577665000555500
050220440502205000000000000000000000000000000000000000000000000000bbbbb000bbbbb000000000c0055000040a90000009a0400500005005000050
052cc254052cc2440000000000000000000000000000000000000000000000000b3733bb0b3333bb00055000f057750000a9940000499a000588885005888850
2272272422722724000000000000000000000000000000000000000000000000b3333b3bb3733b3bc05775004587785f09990004400099900040040000400400
c0a77a0c0ca77a04000000000000000000000000000000000000000000000000bbbbb33bbbbbb73b4587785040855500409999a00a9999040094490000944900
012a9214012a921c000000000000000000000000000000000000000000000000b333b37bb333b33bf085550f40855500000409a00a9040009959959999599599
0122221401222214000000000000000000000000000000000000000000000000b373b33bb333b33b408555000058550000707904409707000499590440995940
0122211401122214000000000000000000000000000000000000000000000000b333b3b0b337b3b0405855000558885000595a0000a595000008990000998000
12211221122112210000000000000000000000000000000000000000000000000bbbbb000bbbbb0005588850000000000099a000000a99000000880000880000
79999997799999977999999700000000090999990000000000000000000000000000488000000000088400000000000007c497c00ccc7cc00000000004555400
7944a44579444445794a4a45090999990999f5f0000000000000000000000000000048000000488000840000088400007c44887cc7c497c70455540009444500
7944a44579aaaa45794aa4450999f5f00999fff0000000600000000000000000000040000000480000040000008400007c9484577c4884770944450009884500
7944a44579aaaa45794a4a450999fff000433f0066666656000000000000000004445440000040000445444000040000c0945450c094845c0948850009484500
794aaa4579aaaa45794aa44500433f0004131100656555650000000000000000994444440444544044444499044544400094445000945450c94845cc09454500
7944a445794aa445794a444504131100043f3300505000500000000000000000c5999999994444449999995c4444449900944450009444507945457cc744440c
7d9444657d4444657d9a4465043f3300401333300000000000000000000000007c555550c5999999055555c79999995c0049994000944450c74444c77c754c7c
7555555575555555755555554033110000000000000000000000000000000000c7c700007c55555000007c7c055555c700000000004999400c754c700cc7ccc0
13131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
63636363636363636363636363636363131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
1313b2b21313131313b2b2131313131313b2b21313b21313131313b2b21313131313131313131313131313b2b213131313131313131313131313b2b2b2131313
63000000000000000000000000000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a33131e3131313a30303e3b2131313a33131e3f331c2131313a35353e31313131313b2b2131313b2b2f35353e313131313131313131313b2f3030331c21313
63000063636363630063636363630063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a3d25353c21313f303030331e3131313b331313131c213131313b35353c2131313a331d2c213f3313131530303e3131313131313b2b2f30303035353c21313
63000000000000000000000000000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a35353d31313a3030331313131e3b213a3313131d31313131313a35353c2131313a331d313a35331533131030303c213131313f33103030353535353e31313
63000000000063636363636363000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
1313c3c3131313a30341533131530303c2a3313131e3b21313131313f331c213131313c31313f30353313103030303c21313b2f303313103035353313131c213
63000000000063000000000063000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
1313131313131313b303533153530303e3f30303313153e3b21313a33131c2131313131313f3030353313103330303c213f3030303313103035331313131c213
63000000000063000000000063000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
131313b2b2131313f303535353030303030303033153535353e3b2f33131c2131313b213a3030303313153033303d313a303030331313131030303313103c213
63000063000063000000000063000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
1313f35353e313a353535303030303030303030331535353030303033131c21313a303e3f3030303315353033303e3b2b2b3033131313131030303030303c213
63000000000063000000000063000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a331315331e3f353535303333333333333030303315331030303030331c21313a3030353535353535303033303030303030331313131310303030303d31313
63000000000063636363636363000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a331313131313153030303330303030333030303030303030303030303c21313a30303315353530303030333330303535303535353d3c3c3c3c3c3c3131313
63000000000000000000000000000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a3313131313153530303333303033103333333333333330303d3b30353c21313a3033131315353030303030333333331533153534313b21313131313b21313
63000000000000000000000000000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a3535353030303030303330303313103033303030303035303c2a30353c21313a30331315353d3c3c3b303030303313131313153c2a353c21313b2f303c213
63000063636363630063636363630063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a3535353030303033333330331313103033303313103035353c2a35353c21313a303315353d313131313c3b3030331313131d3c31313c31313f3033131c213
63000000000000000000000000000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13a353530303d3b3033303030331313131033303313103035353c2a35353c2131313b33153d313131313131313c3b3330331d31313b2b21313a303313131c213
63000000000000000000000000000063131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
1313c3b303d313a3033303030353033131033303313131030353e313b353c2131313b2c3c3131313131313131313f33303d31313a35353c213a3033131d31313
63636363636363636363636363636363131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
13131313c31313a303330303533131313103330331d3b331035353c2a353c21313a331e31313131313131313b2f3033131c21313a35331c21313c3c3c3131313
13131313131313131313131313131313131313131313131313131313131313136363636363636363636363636363636363636363636363636363636363636363
13131313131313f3333303535331d3b331034303d313a331035353c2a353c21313a33131e3131313131313f303033131d313b2b213c3c3131313b2b2b2131313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
13131313b2b2f30333035353d3c313a331d3c3c31313f331030353c213c313131313b33131e313131313a303033131e313a33131e3b21313b2f3315353c21313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
131313f303530333330353d313b21313c313131313a30303030303e3b21313131313f3313131e3131313a30303313131e3f331030331c2a33153313153e31313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
1313a3535353033303d3c313f353c21313b2b2b21313c3b331b3030331e3131313a30331313131c21313f30303333131313103033131c2f3315331315353c213
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000d20000000000000063
1313a3535303033303c213f35353c213a3535353c21313f331c2b3313131c21313a33131d33131e3b2f30303333303030303033131d3a331315331315353c213
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
1313a3030303033303e3f30303d31313a3536153c213a33103c2a3310303c2131313c3c313b33131030303333303030303030331d313f3310353533131d31313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000340000000064000063
131313c3b30303030303030303e3131313c3c3c31313f35353c213b30303c2131313131313a3535303030333030303d3c3c3c3c313f3310331d3535331c21313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
13131313a3035353030303033131c2131313131313a3533131e3b2f30353c2131313131313a353d3b30303330303d313b2b2b213a3310331d313a30303c21313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000001222320000000063
13131313f3535353310303313131e3131313131313a33131313131313103c2131313b21313a353c2a3030303d3c313a3536153c2a3030331e3b2f30303e31313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000140023000000000063
131313a35353313131030331313131c21313131313f33131313153310303c21313a353e31313c313a3030341131313a35303d31313b33131535353310303c213
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000d00000000001000063
131313f353313131d3b30331313131c213131313a35353535353d3b30303c21313a35353c213b2b2f3030303e3b2b213c3c3131313a33131313153310303c213
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
1313a331313131d31313c3b3313131c213131313a353535353d313a303d3131313a35331e3f3313103030303030353e3b2b2b2b21313c3b3535353310303c213
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363000000000000000000000000000063
131313c3c3c3c31313131313c3c3c3131313131313b353535353c213c313131313a3533131313131035353535353535353535353e3131313b30303030303c213
131313131313131313131313131313131313131313131313131313131313131363030303030303030303030303030363630000000000009200b0000000000063
13131313131313131313131313131313131313131313c3c3c3c31313131313131313c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3b3535353c2131313c3c3c3c3c31313
13131313131313131313131313131313131313131313131313131313131313136303030303030303030303030303036363060000000000000000000000000063
1313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313c3c3c31313131313131313131313
13131313131313131313131313131313131313131313131313131313131313136363636363636363636363636363636363636363636363636363636363636363
__gff__
0000000000000000000101000000000000000000000000000001000000000000000000000000000101000011114000000011010002010100000111101110101000000404040400000000000004040000040400000000040400000000040400000000000000000000000000000000000001010100000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3131312b2b2b2b2b2b31313131313131313131312b2b2b313131312b2b3131313131313131313131312b3131313131313131313131313131313131313131313136363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636
31313f3535353530303e31313131312b312b2b3f3035352c31313f132d2c3131313131313131312b3f303e3131313131312b2b2b2b313131313131313131313136272020203620373720362020202036362020202020362027202027202020363627282827362037372039361515303636202020202027202027202020202036
313f13353535133030303e3131313a303f3030303030352c313a3013132c313131312b2b2b2b3f303030133e2b2b31313f353535133e2b313131312b2b31313136282828283620373720362020202036362828282828362720202028282828363639373720202037372039361515153636282828282828282828282828282836
3a131313131313133333303e2b313a30303030303030133e2b313b30302c3131313a1313353513303030131313132c3a133535351335353e31313a30303e313136202020203620373720360909190936362020202020362027202020202027363639373720202037372039363636153636202020202020202020202020202036
3a30131330303d3b30333030303e313b3030303030131335353e313b302c313131313b13353513133030131313132c3a13132d35133513132c313f3030302c3136722020363620202020362020202036363620157036363636362020202020363627282827362037372039361515153636202020202039363639202020202036
3a30303330303e3a3033333330303e3f303030303013133530302c313c31313131313a35353535133030301313132c313b131335131313132c3a351330302c3136202020202020303020362020202036363920151515151515362020202020363636363636362037372039361515153636367015203636363636362015713636
3a3033333030302c3b35353333333330303030303035303030302c312b31313131313a35353513133030301313132c313a353535133535132c3a351330302c3136202020202030313130363636203636363620153636361515363672151536363639303020202037372020363636153636151515201515151515152015151536
3a1333303030302c3a353530303033133030303030353530303d313f302c31313131313b3535133030333030303d31313a1313131313353d313a3535353d313136202020202020303020202020202036362020202020361515202020151539363630313130202037372020363015153636151515202020202020202015153936
3a1333133030302c313b353513303313133030303035353030303e30302c31313131313a3030303033333030352c3131313b353535353d31313f1335352c313136202020202020202020202020202036362828282828361515151515151520363639303020202037372020361515153636153015301530152015363636363636
3a133313133d3c3131313c3b131333331313303030303035303030303d3131313131313a3030303333303030352c3131313a353d3c3c312b3f3013133d31313136393915151515151515151515393936313120202020361515151515151539363636363636362037372020363636153636153015301530152015361515271536
3a1314133d31312b2b2b31313b131333331330303030303535353013132c3131313131313b303033303035303d31313131313c3131313f133030133d3131313136363615157136151536701515363636363636363636361515202071151536363620202020362020202020361515153636153015301530152015361515151536
3a13133d31313a3035352c31313b1313333030303030303030353513132c31313131312b3a303033303535352c31312b2b313131313a3030353d3c312b31313136202020202036151536202020202036362030202020201515202036202020363628282828722020202020361515153636153015301530152015151515151536
313c3c313131313b30302c3131313b30333030303030303035131313302c313131313a302c3b3033301335352c313a35302c313131313b353d31313f352c313136282828282836151536282828282836363031303620361515362036282828363620202020202020202020151515153636153015301530152015361515151536
31313131313131313c3c313131313a34333030303030333035351313302c31313131313c313a3033331313352c313a353d31312b3131313c31313f35352c313136202020202036151536202020202036362030203620361515362036202020363639202020363620203636151515303636151515151515152015363915271536
31312b2b2b2b31313131313131313a131313303030303330303535133d3131313131312b2b313b30333013132c31313c31313f132c313131313a3035352c313136363636363636151536363636363636363636363636361515363636363636363636363636363620203636363636363636363636363636202036363636363636
313a353535353e2b313131312b2b2b3c3b131330303033303030303d3131313131313a30303e3f30333013132c313131313f34132c313131313f30353d31313100000000000000151500000000000000000000000000001515000000000000000000000000000020200000000000000000000000000000202000000000000000
313f3516353530302c31313f3030133e313b1313303033303030303e2b31313131313a3030303030333030132c3131313a3013132c3131313a3030353e31313100000000000000202000000000000000003636363636363636363636363636363636363636363636363636363636360000000000000000151500000000000000
3a131313133530303e313a30303013133e3f13133030303030303013132c31313131313b30303033333030303e313131313c3c3c313131313f303035353e313136363636363636202036363636363636003620272020202036202720202020363613333333363737373633333313360036363636363636151536363636363636
313b131313353030133e313b13303013131313133030303030131313302c31313131313a3535333330303030303e2b2b2b2b2b313131313a3030303535352c3136391515151515202015151515153936003628282828282836282828282828363633333333333737373333333333360036202020202036151536202020202036
313a13133535303030133e3a133030303013133030303330131313133d3131313131313a3535333530303030303030303033303e2b31313a30303535353d313136151515152020202020201515151536003620202020202036202020202020363633333333333333333333333333360036282828282836151536282828282836
313a3030303013133013133f13303030303030303030333013353d3c313131313131313a13131335353030303030303030333030303e2b3f30303535352c313136363636152036202036201572363636003636361520703636367115203636363633363333363333333633333633360036202020202036151515202020202036
31313b30303d3c13133030131330303030303535303033303535352c313131313131313a1313131335353030303030303033303030303030303030353d31313136152715151539202039151515151536003636201520202020202015202036363633333333333315333333333333360036202020202036151515202020203936
31313a3035352b3b133030303030353535353530303030303035352c31313131313131313b13131313353530303030333333333330303030303030352c31313136271515151536202036282828282836003620201515151515151515151520363633333030333315333333333333360036367015203636151572363636363636
31313f303035353513131330303535353535303030303030303d3c313131313131313131313b351313353535353030303030303030303030303030352c31313136151515151539202039151515151536151515151520363636363636201520363615303131301515151515151515151536202015202020151515333333302c31
313a3030303035353030131330353d3c3c3b30303030303030353e313131313131313131313a353533333535353530303030303030303535353030132c313131363636363636362020363636363636361515151515203620202020362015203636153031313015151515151515151515362020152020201515153333303d3131
313a303d3c3c3c3c3c3c3c3c3c3c312b2b3f3030303013131313352c313131313131313131313c3c3b333513133535303030303030133516353013132c31313136301539151520202020151539153036003620201520360a0a190a3620152036363333303033333333391515393336003639201520202015151533303d313131
31313c31313131313131313131313f3535353535351313133d3c3c31313131313131312b2b3131313a33351313133535353030301313353c351313302c31313136301515151520373720151515153036003620201520362020202036201520363636363636363636363615153636360036202015152020151515303d31313131
313131313131313131313131313a353535353d3c3b35353d313131313131313131313a13302c31313f333514131313133530301313303d3a131330352c31313136363615153636373736361515363636003620201520363636363636201520367220202027202020202020202020710036202015151515151515302c31313131
31313131313131313131313131313c3c3c3c31313a35352c313131313131313131313a13132c313a303333333330303d3c3013133d3c313a301335352c31313136151515151536363636151515151536003620201520202020202020201527363620202020202020202020202020360036392020202020151515303e31313131
3131313131313131313131313131313131313131313b352c31313131313131313131313c3c3131313b30303030303d31313b13132c31313a3535353d313131313633333333333333333333333333333600362720151515151515151515152736362828282828282828282828282836003620202020202015151533303e2b3131
313131313131313131313131313131313131313131313c3131313131313131313131313131313131313c3c3c3c3c313131313c3c313131313c3c3c313131313136303030303030303030303030303036003636202020202020202020202036363620202020202027202020202020360036393939202020151515333330303e31
313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c003636363636363636363636363636363636363636363636363636363636360036363636363636363636363636363636
__sfx__
010700000c6440c645000000000500000182050000018205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000134300f4200b430074300645014405011011d1011b100121000c100091001b4001b4001c4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d45112411154211e4310e6310c6310b63109621076110561100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200001a0551d055220551f000210551f000220551f000210550000022055000002105500000240551e000210551a0001f0551a00021055220001f0550000021055000001f0550000021055000002205521000
0112000021055210001d055000001c055000001d055000001c055000001d055000001c055200001d05500000220550000021055000001a0551d0001c00000000220551c000210512105121051210551a0001c000
0112000021055210001d055000001c055000001d055000001c055000001d055000001c055200001d05500000220550000021055000001a0551d0001c000000001a0551c0551a0551c0001a0551c0551a0551c000
01120000046351a600006000000000605096000060000000026350000000000000000460500000000000000004635000000960000000046050000000000000000463500000096000000004605000000000000000
011200001a0551d055220542205022050220502205022050220502205022050220552100500000240542405021050210501f0501f0501f0501f0501f0501f0501f0501f0501f0501f05521000210002105421050
011200001f0501f0501d0501d0501d0501d0501d0501d0501d0501d0501d0501d0551c0001c00020054200501f0501f0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0551a000000000000000000
011200001f0501f0501d0501d0501d0501d0501d0501d0501d0501d0501d0501d0501c0001c0001b0501b0501f0501f050220502205022050220502205022050220502205022050220501a000000000000000000
000200001204015040190401d04020030260302b0303003038030390201e0202002024020280202c02032020380253a03024010250102d0103201039010000000000000000000000000000000000000000000000
010600001e640000000000018600186300000000000000001e6201e60000000000001861000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002175021750217502175021750217502175021750217502174021730217202171021710217102171523750237502375023750237502375023750237502375023740237302372023710237102371023715
011000002475224752247422474224732247322472224725007000070000700247002675025751247512475523752237522374223742237322373223722237251c7021c7021c7021c70524750247552375023755
0110000021752217522174221742217322173221722217250000000000237502375521750217551f7501f7551c7521c7521c7421c7421c7321c7321c7221c7250000000000000000000021750217552375023755
011000002475224752247422474224732247322472224725237502375023750237552475024750247502475526752267522674226742267322673226722267252475024750247502475526750267502675026755
011000002875228752287422874228732287322872228722287122871228712287122871228712287122871500000000000000000000000000000000000000002175021750217502175523750237502375023755
011000002475224752247422474224732247322472224725267502675026750267552475024750247502475523752237522374223742237322373223722237252175221752217422174221732217351f7501f755
01100000237502375023750237552175221752217422174221732217322172221725247002470024700247002170021705210502104020050200401d0501d0401c0501c0401a0501a04018050180401705017040
0110000009070090751c5450c505215451c51524545215151c54524515215451c51524545215151c5452451507070070751a545005051f5451a515235451f5151a545235151f5451a515235451f5151a54523515
0110000009070090751c5450c505215451c51524545215151c54524515215451c51524545215151c545245150b0700b07517555000001c55517515235551c51517555235151c55517515235551c5151755523515
0110000009070090751c5450c505215451c51524545215151c54524515215451c51524545215151c5452451509070090751c5450c505215451c51524545215151c54524515215451c51524545215151c54524515
0110000009070090751c5450c505215451c51524545215151c54524515215451c51524545215151c5452451509050090551d0301d0201c0301c0201a0301a0201803018020170301702015030150201403014020
011000001505015040280502804026050260402805028040240502404028050280402305023040280502804021050210402104021030210302102021020210151a500235001f5001a500235001f5001a50023500
011000000e0500e0402905029040280502804029050290402605026040290502904024050240402905029040230502304023040230302303023020230202301517500235001c50017500235001c5001750023500
0110000015050150402b0502b04029050290402b0502b04028050280402b0502b04025050250402b0502b040290502904029040290302b0502b0402b0402b0302d0502d0402d0402d0302b0502b0402905029040
011000002805028040280402803024050240402805028040260502604026040260302705027040270402703028050280402804028030280302802028020280150000000000000000000000000000000000000000
0110000009030090200000000000000000000000000000000000000000000000000000000000000000000000150301502009030090200c0300c02010030100201503015020130301302011030110201003010020
0110000002030020201a0301a02018030180201a0301a02017030170201a0301a02015030150201a0301a02014030140201003010020140301402017030170201c0301c020100301002012030120201403014020
0110000009030090201c0301c0201a0301a0201c0301c02019030190201c0301c02015030150201c0301c0201a0301a02015030150201c0301c02015030150201d0301d02015030150201c0301c0201a0301a020
01100000180301802013030130201c0301c020130301302017030170201d0301d02015030150201e0301e02020030200201003010020140301402017030170201c0301c0201a0301a02018030180201703017020
0110000015055150052d0552c0552d055000002805527055280550000024055230552405500000210550000013055130002d0552c0552d0550000028055270552805500000240552305524055000002105500000
0110000023050230401f0501f04024050240401f0501f040290502904021050210402405024040210502104028050280401c0501c0402005020040230502304028050280401f0501f04025050250402805028040
0110000015055150052d0552c0552d055000002905528055290550000026055250552605500000210550000013055130002d0552c0552d0550000029055280552905500000260552505526055000002105500000
0110000023050230401f0501f04024050240401f0501f04029050290402105021040240502404029050290402805028040210502104020050200401d0501d0401c0501c0401a0501a04021130211202213022120
01100000090350000018035170351803500000180351703518035000001c0351b0351c035100001803500000070350000018035170351803510000180351703512035000001c0351b0351c035000001803500000
0110000011030110201102011020100301002010020100200e0300e0200e0200e0200f0300f0200f0200f02010030100201002010020100201002010020100201503015020150201502015020150201502015020
0110000002035000001d0351c0351d035000001a035190351a035000001d0351c0351d035000001a0350000000035000001d0351c0351d035000001a035190350b035000001d0351c0351d035000001a03500000
0110000011030110201102011020100301002010020100200e0300e0200e0200e0200e0200e0200e0200e02010030100201d0301d0201c0301c0201a0301a0201803018020170301702015000000000000000000
01100000241302412029130291202813028120261302612024130241202412024120261302612021130211202213022120221202212022122221222212222125000000000000000000001f1301f1202113021120
011000002213022120281302812026130261202413024120241302412022130221201f1301f120221302212021130211202112021120221302212022120221202413024120241202412026130261202813028120
011000002913524000221352213522135000002613526000291302912229122291222813028120261302612024135000002113521135211350000024135000002913029122291222912224130241202213022120
01100000211302112021120211201d1301d12021130211201f1301f1201f1201f1202913029120291202912028130281202913029120261302612028130281202413024120241202412026130261202813028120
0110000021130211202213022120231302312026130261202413024120221302212021130211201f1301f120211302112523000000001f1301f12500000000001d1301d125000000000021750217552375023755
011000001103011020150301502018030180201d0301d0201203012020150301502018030180201a0301a020130301302016030160201a0301a0201f0301f02012030120201a0301a02011030110201a0301a020
0110000010030100201803018020170301702018030180200c0300c020130301302010030100201303013020110301102018030180201303013020180301802015030150201d0301d02022030220202403024020
01100000260350000011035110351103500000160351a0001a0301a0201a0201a020240302402022030220200c035000001103511035110350000015035000001803018020180201802000000000000000000000
01100000170301702017020170201a0301a0201a0201a0201703017020170201702018030180201a0301a020180301802018020180201a0301a0201a0201a0201c0301c0201c0201c0201c0001c0001c0001c000
011000001103011020130301302014030140201703017020180301802019030190201a0301a0201c0301c0201d035000001800000000180350000000000000001503500000000000000000000000000000000000
0110000018700247202472029720297202872028720267202672024720247202472024720267202672021720217202272022720227202272022720227202272022725000000000000000000001f7201f72021720
01100000217202272022720287202872026720267202472024720247202472022720227201f7201f7202272022720217202172021720217202272022720227202272024720247202472024720267202672028720
011000002872029725240002272522725227250000026725260002972029720297202972028720287202672026720247250000021725217252172500000247250000029720297202972029720247202472022720
0110000022720217202172021720217201d7201d72021720217201f7201f7201f7201f72029720297202972029720287202872029720297202672026720287202872024720247202472024720267202672028720
011000002272021720217202272022720237202372026720267202472024720227202272021720217201f7201f720217202172523000007001f7201f72500000000001d7201d7250000000000000000000000000
010800201862511605000000000000000000000000000000186000000000000000001862500000000000000018625000000000000000000000000000000000000063200622006220062200612006120061200615
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
01 03 06 43 44
00 04 06 43 44
00 03 06 43 44
00 05 06 43 44
00 07 06 43 44
00 08 06 43 44
00 07 06 43 44
02 09 06 43 44
00 0c 42 43 44
01 0d 13 43 44
00 0e 14 43 44
00 0f 13 43 44
00 10 15 43 44
00 0d 13 36 44
00 0e 14 36 44
00 11 13 36 44
00 12 16 36 44
00 17 1b 43 44
00 18 1c 43 44
00 19 1d 43 44
00 1a 1e 43 44
00 1f 23 43 44
00 20 24 43 44
00 21 25 43 44
00 22 26 43 44
00 27 2c 43 36
00 28 2d 43 36
00 29 2e 43 36
00 2a 2f 43 36
00 29 2e 43 36
02 2b 30 43 36
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
