pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init() t,shake,dpal,dirx,diry=0,0,explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14"),explodeval("-1,1,0,0,1,1,-1,-1"),explodeval("0,0,-1,1,-1,1,1,-1") 
 itm_name=explode("big scythe,sharpy knife,iron sword,fat book,big hammer,huge shovel,dino's blazer,winter pants,broken shield,dino's jacket,leather armor,golden chestplate,melted icecream,stunny stew,??? potion,tasty taco,monster candy,medical pill,heavy brick,metal fork,spike ball,garbage,plastic bottle,glass cup,??? potion,plushy toy,big raspberry,blessed shirt,blessed apple,rusty axe,glasses,??? potion,choco-candy,raw fish,brass knuckles,umbrella,broken pencil,mom's hat,old dress")
 itm_type=explode("wep,wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,arm,fud,fud,fud,fud,fud,fud,thr,thr,thr,thr,thr,thr,fud,thr,fud,arm,fud,wep,arm,fud,fud,fud,wep,arm,thr,arm,arm")
 itm_stat1=explodeval("1,2,2,2,4,3,,,,1,1,1,1,2,2,3,1,,2,2,1,1,1,2,2,1,3,,1,2,,1,2,2,3,1,1,,")
 itm_stat2=explodeval(",,,,,,1,1,2,2,2,3,,,,,,,,,,,,,,,,2,,,,,,,,2,,2,5")
 itm_stat3=explodeval(",,,,1,1,,,,,,,,1,2,,,2,,,,,,,3,,,4,4,1,,5,,,1,,,,")
 itm_minf=explodeval(",3,2,4,7,5,,,1,2,3,3,,1,6,2,,4,1,1,,,1,2,6,2,3,5,5,3,9,6,1,1,6,2,,2,9")
 mob_ani=explodeval("240,192,196,200,204,208,212,216,220,224,228,232,236")
 mob_name=explode("player,slaim,goast,skorpy,snek,zombus,squid,bads,ssief,manki,danser,death,croco")
 mob_hp=explodeval("5,1,2,3,2,8,4,3,5,7,3,99,6")
 mob_atk=explodeval("1,1,2,2,2,3,3,1,2,3,2,99,3")
 mob_los=explodeval("4,4,5,4,6,4,5,3,6,8,2,-1,5")
 mob_spec=explode(",,curse,stun,,slow,scared,vamp,stealitm,stealeqp,,,")
 mob_minf=explodeval(",1,5,4,2,7,6,3,8,11,4,-1,10")
 crv_sig,crv_msk,free_sig,free_msk,wall_sig,wall_msk=explodeval("255,214,124,179,233"),explodeval("0,9,3,12,6"),explodeval("0,0,0,0,16,64,32,128,161,104,84,146"),explodeval("8,4,2,1,6,12,9,3,10,5,10,5"),explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252"),explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")
 startgame() end

function _update60() t+=1 _upd() dofloats() dohpwind() end

function _draw() doshake() _drw() drawind() checkfade() end

function startgame() steps,kills,meals,tani,fadeperc,buttbuff,skipai,mob,dmob,killer,p_t,inv,eqp=0,0,0,0,1,-1,false,{},{},"",0,{},{}
 p_mob=addmob(1,8,10) makeipool()
 wind,float,fog,talkwind={},{},blankmap(0)
 hpwind,thrdx,thrdy,_upd,_drw=addwind(2,2,28,7,{}),0,-1,update_game,draw_game
 genfloor(0) unfog() music(0) end
-->8
--upd
function update_game()
 if talkwind then if getbutt()==5 then talkwind.dur,talkwind=0 end
 else dobuttbuff() dobutt(buttbuff) buttbuff=-1 end end

function update_inv() move_mnu(curwind)
 if btnp(4) then
  if curwind==invwind then _upd,invwind.dur,statwind.dur=update_game,0,0
  elseif curwind==usewind then usewind.dur,curwind=0,invwind end
 elseif btnp(5) then
  if curwind==invwind and invwind.cur!=3 then showuse()
  elseif curwind==usewind then triguse() end end end

function move_mnu(wnd)
 if btnp(2) then sfx(11) wnd.cur-=1
 elseif btnp(3) then sfx(11) wnd.cur+=1 end wnd.cur=(wnd.cur-1)%#wnd.txt+1 end

function update_throw() local b=getbutt()
 if b>=0 and  b<=3 then thrdx,thrdy=dirx[b+1],diry[b+1] end
 if b==4 then _upd=update_game
 elseif b==5 then throw() end end

function update_pturn() dobuttbuff() p_t=min(p_t+0.16,1)
 if p_mob.mov then p_mob:mov() end
 if p_t==1 then _upd=update_game
  if trig_step(tle) then return end
  if checkend() and not skipai then doai() end skipai=false end end 

function update_aiturn() dobuttbuff() p_t=min(p_t+0.125,1)
 for m in all(mob) do if m!=p_mob and m.mov then m:mov() end end
 if p_t==1 then _upd=update_game
  if checkend() then if p_mob.stun then p_mob.stun=false doai() end end end end

function update_gover() if btnp(—) then fadeout() startgame() end end

function dobuttbuff() if buttbuff==-1 then buttbuff=getbutt() end end

function getbutt() for i=0,5 do if btnp(i) then return i end end return -1 end

function dobutt(butt)
 if butt<0 then return end
 if butt<4 then moveplayer(dirx[butt+1],diry[butt+1])
 elseif butt==5 then showinv() end end
-->8
--drw
function draw_game() cls(0) if fadeperc==1 then return end animap() map()
 for m in all(dmob) do
  if sin(time()*8)>0 or m==p_mob then drawmob(m) end m.dur-=1
  if m.dur<=0 and m!=p_mob then del(dmob,m) end end
 for i=#mob,1,-1 do drawmob(mob[i]) end
 if _upd==update_throw then
  local tx,ty=throwtile()
  local lx1,ly1=p_mob.x*8+3+thrdx*4,p_mob.y*8+3+thrdy*4
  local lx2,ly2=mid(0,tx*8+3,127),mid(0,ty*8+3,127) rectfill(lx1+thrdy,ly1+thrdx,lx2-thrdy,ly2-thrdx,0)
  local thrani,mb=flr(t/7)%2==0,getmob(tx,ty)
  if thrani then fillp(0b1010010110100101)
  else fillp(0b0101101001011010) end line(lx1,ly1,lx2,ly2,7) fillp() oprint8("+",lx2-1,ly2-2,7,0)
  if mb and thrani then mb.flash=1 end end
 for x=0,15 do for y=0,15 do if fog[x][y]==1then rectfill2(x*8,y*8,8,8,0) end end end
 for f in all(float) do oprint8(f.txt,f.x,f.y,f.c,0) end end

function drawmob(m) local col=8
 if m.flash>0 then m.flash-=1 col=0 end drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp) end

function draw_end() cls(0) spr(80,28,32,9,2) color(5) cursor(44,50) print("floor: "..floor) print("steps: "..steps) print("kills: "..kills) print("meals: "..meals) print("press: —") print("killed by: "..killer,32,44,5) end

function animap() tani+=1
 if (tani<15) return
 tani=0
 for x=0,15 do for y=0,15 do
   local tle=mget(x,y)
   if tle==64 or tle==66 then tle+=1
   elseif tle==65 or tle==67 then tle-=1 end mset(x,y,tle) end end end
-->8
--tls
function getframe(ani) return ani[flr(t/20)%#ani+1] end

function drawspr(_spr,_x,_y,_c,_flip) palt(0,false) pal(8,_c) spr(_spr,_x,_y,1,1,_flip) pal() end

function rectfill2(_x,_y,_w,_h,_c) rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c) end

function oprint8(_t,_x,_y,_c,_c2) for i=1,8 do print(_t,_x+dirx[i],_y+diry[i],_c2) end print(_t,_x,_y,_c) end

function dist(fx,fy,tx,ty) local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy) end

function dofade()
 local p,kmax,col,k=flr(mid(o,fadeperc,1)*100)
 for j=1,15 do col,kmax=j,flr((p+j*1.46)/22)
 for k=1,kmax do col=dpal[col] end pal(j,col,1) end end

function checkfade() if fadeperc>0 then fadeperc=max(fadeperc-0.04,0) dofade() end end

function wait(_wait) repeat _wait-=1 flip() until _wait<0 end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0 
 repeat fadeperc=min(fadeperc+spd,1) dofade() flip()
 until fadeperc==1 wait(_wait) end

function blankmap(_dflt) local ret={}
 if (_dflt==nil) _dflt=0
 for x=0,15 do ret[x]={} for y=0,15 do ret[x][y]=_dflt end end return ret end

function getrnd(arr) return arr[1+flr(rnd(#arr))] end

function copymap(x,y)
 for _x=0,15 do for _y=0,15 do tle=mget(_x+x,_y+y) mset(_x,_y,tle)
   if tle==15 then p_mob.x,p_mob.y=_x,_y end end end end

function explode(s)
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)=="," then add(retval,sub(s, lastpos, i-1)) i+=1 lastpos=i end end add(retval,sub(s,lastpos,#s)) return retval end

function explodeval(_arr) return toval(explode(_arr)) end

function toval(_arr) local _retarr={}
 for _i in all(_arr) do add(_retarr,flr(tonum(_i))) end return _retarr end

function doshake()
 local shakex,shakey=16-rnd(32),16-rnd(32) camera(shakex*shake,shakey*shake) shake*=0.95
 if (shake<0.05) shake=0 end
-->8
--gmp
function moveplayer(dx,dy) local destx,desty=p_mob.x+dx,p_mob.y+dy
 local tle=mget(destx,desty)
 if iswalkable(destx,desty,"checkmobs") then
  sfx(0) mobwalk(p_mob,dx,dy) p_t,_upd=0,update_pturn steps,stps+=1,1
  if stps==150 then for x=0,15 do for y=0,15 do if mget(x,y)==15 then sfx(4) showmsg("the death appeared!",120) addmob(12,x,y) end end end end
 else mobbump(p_mob,dx,dy) p_t,_upd=0,update_pturn
  local mob=getmob(destx,desty)
  if mob then sfx(1) hitmob(p_mob,mob)
  else if fget(tle,1) then trig_bump(tle,destx,desty)
   else skipai=true end end end unfog() end

function trig_bump(tle,destx,desty)
 if tle==7 or tle==8 then sfx(2) mset(destx,desty,76)
  if rnd(3)<1 and floor>0 then
   if rnd(5)<1 then sfx(4) addmob(getrnd(mobpool),destx,desty)
   else if freeinvslot()!=0 then
     local itm=getrnd(fipool_com)
     takeitem(itm) addfloat(itm_name[itm].."!",64-(#itm_name[itm]*2),128,11) end end end
 elseif tle==10 or tle==12 then
  if freeinvslot()==0 then sfx(4) addfloat("full",p_mob.x*8-4,p_mob.y*8,3) skipai=true
  else local itm=getrnd(fipool_com) if tle==12 then itm=getrnd(fipool_rar) end sfx(5) mset(destx,desty,tle-1) takeitem(itm) addfloat(itm_name[itm].."!",64-#itm_name[itm]*2,128,11) end
 elseif tle==13 then sfx(3)
  if not iswalkable(destx,desty-1) then mset(destx,desty,4)
  else mset(destx,desty,1) end
 elseif tle==6 then showtalk({"reward floor!","open chests & climb 9","more floors for","the next reward!"}) end end

function trig_step() if mget(p_mob.x,p_mob.y)==14 then sfx(7) fadeout() genfloor(floor+1) return true end return false end

function getmob(x,y) for m in all(mob) do if m.x==x and m.y==y then return m end end return false end

function iswalkable(x,y,mode) local mode=mode or "test"
 if inbounds(x,y) then local tle=mget(x,y)
  if mode=="sight" then return not fget(tle,2)
  else if not fget(tle,0) then if mode=="checkmobs" then return not getmob(x,y) end return true end end end return false end

function inbounds(x,y) return not (x<0 or y<0 or x>15 or y>15) end

function hitmob(atkm,defm,rawdmg) local dmg=atkm and atkm.atk or rawdmg local col,def=2,defm.defmin+flr(rnd(defm.defmax-defm.defmin+1)) dmg-=min(def,dmg)
 if defm==p_mob then col=3 end
 if atkm==p_mob and rnd()<0.25 then if itm_stat3[eqp[1]]==1 then dmg=dmg*2 addfloat("crit",defm.x*8-4,defm.y*8-8,col) end end defm.hp-=dmg defm.flash=10
 if mob_spec[atkm]=="stun" then addfloat("stun"..dmg,defm.x*8,defm.y*8,col) stunmob(defm) end addfloat("-"..dmg,defm.x*8,defm.y*8,col)
 if defm==p_mob then shake=0.04 end
 if defm.hp<=0 then
  if defm==p_mob then killer=atkm.name
  else kills+=1 end add(dmob,defm) del(mob,defm) defm.dur=10 end end

function healmob(mb,hp) local col=2 hp=min(mb.hpmax-mb.hp,hp)
 if mb==p_mob then col=3 end mb.hp+=hp mb.flash=10 addfloat("+"..hp,mb.x*8,mb.y*8,col) end

function stunmob(mb) mb.stun,mb.flash=true,10 addfloat("stun",mb.x*8-4,mb.y*8-8,11) end

function givecurse(mb)
 local curse=getrnd(explode("mapfog,hphud,stathud")) 
 if (mb==p_mob and itm_stat3[eqp[2]]==4) return givebless()
 if curse=="mapfog" then fog=blankmap(1) unfog()
 elseif curse=="hphud" then hpwind.x=-32
 elseif curse=="stathud" then statcurse=true end sfx(4) mb.flash=10 addfloat("curse",mb.x*8-4,mb.y*8-8,11) end

function givebless() hpwind.x,p_mob.flash=2,10 sfx(8) addfloat("bless",p_mob.x*8-4,p_mob.y*8-8,11) end

function checkend()
 if p_mob.hp<=0 then music(17) wait(45)
  wind,_upd,_drw={},update_gover,draw_end
  fadeout(0.02) return false end return true end

function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true
 if dist(x1,y1,x2,y2)==1 then return true end
 if y1>y2 then x1,x2,y1,y2=x2,x1,y2,y1 end sy,dy=1,y2-y1
 if x1<x2 then sx,dx=1,x2-x1
 else sx,dx=-1,x1-x2 end local err,e2=dx-dy
 while not(x1==x2 and y1==y2) do
  if not frst and iswalkable(x1,y1,"sight")==false then return false end e2,frst=err+err,false
  if e2>-dy then err-=dy x1+=sx end
  if e2<dx then err+=dx y1+=sy end end return true end

function unfog()
 if eqp[2]==31 then p_mob.los=999
 else p_mob.los=4 end local px,py=p_mob.x,p_mob.y
 for x=0,15 do for y=0,15 do if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then unfogtile(x,y) end end end end

function unfogtile(x,y) fog[x][y]=0
 if iswalkable(x,y,"sight") then for i=1,4 do
 	 local tx,ty=x+dirx[i],y+diry[i]
 	 if inbounds(tx,ty) and not iswalkable(tx,ty,"sight") then fog[tx][ty]=0 end end end end
 
function calcdist(tx,ty) local cand,step,candnew={},0 distmap=blankmap(-1) add(cand,{x=tx,y=ty}) distmap[tx][ty]=0
 repeat step+=1 candnew={}
  for c in all(cand) do for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if inbounds(dx,dy) and distmap[dx][dy]==-1 then distmap[dx][dy]=step
     if iswalkable(dx,dy) then add(candnew,{x=dx,y=dy}) end end end end cand=candnew
 until #cand==0 end

function updatestats() local atk,dmin,dmax=1,0,0
 if eqp[1] then atk+=itm_stat1[eqp[1]]end
 if eqp[2] then dmin+=itm_stat1[eqp[2]] dmax+=itm_stat2[eqp[2]] end p_mob.atk,p_mob.defmin,p_mob.defmax=atk,dmin,dmax end

function eat(itm,mb)
 if itm_stat3[itm]==1 then sfx(4) stunmob(mb)
 elseif itm_stat3[itm]==2 then
  mb.hpmax+=1 sfx(8) addfloat('+1‡',mb.x*8-4,mb.y*8-8,11) 
 elseif itm_stat3[itm]==3 then
  if itm_stat3[eqp[2]]!=4 then if mb==p_mob then sfx(4) givecurse(mb) end
  else sfx(8) givebless() end
 elseif itm_stat3[itm]==4 then
  if mb.name=="goast" then hitmob(nil,mb,mb.hp)
  elseif mb==p_mob then givebless() end sfx(8)
 elseif itm_stat3[itm]==5 then for m in all(mob) do if m!=p_mob then m.stun=true if m.task!=ai_wait then m.task=ai_wait addfloat("?",m.x*8+2,m.y*8,2) end end end end
 if mb==p_mob then meals+=1 end healmob(mb,itm_stat1[itm]) end

function throw()
 local itm,tx,ty=inv[thrslt],throwtile()
 if inbounds(tx,ty) then local mb=getmob(tx,ty)
  if mb then
   if itm_type[itm]=="fud" then eat(itm,mb)
   else hitmob(nil,mb,itm_stat1[itm]) sfx(1) end end end mobbump(p_mob,thrdx,thrdy) p_t,_upd,inv[thrslt]=0,update_pturn end

function throwtile() local tx,ty=p_mob.x,p_mob.y
 repeat tx+=thrdx ty+=thrdy
 until not iswalkable(tx,ty,"checkmobs")
 return tx,ty end
-->8
--ui
function addwind(_x,_y,_w,_h,_txt) local w={x=_x,y=_y,w=_w,h=_h,txt=_txt} add(wind,w) return w end

function drawind()
 for w in all(wind) do local wx,wy,ww,wh=w.x,w.y,w.w,w.h rectfill2(wx,wy,ww,wh,0) rect(wx-1,wy-1,wx+ww,wy+wh,11) rect(wx-2,wy-2,wx+ww+1,wy+wh+1,0) clip(wx,wy,ww-1,wh-1)
  if w.cur then wx+=6 end
  for i=1,#w.txt do local txt,c=w.txt[i],11
   if w.col and w.col[i] then c=w.col[i] end print(txt,wx+1,wy+1,c)
   if i==w.cur then spr(255,wx-5+sin(time()),wy) end wy+=6 end clip()
  if w.dur then w.dur-=1
   if w.dur<=0 then local dif=w.h/4 w.y+=dif/2 w.h-=dif
   if w.h<3 then del(wind,w) end end
  else if w.butt then oprint8("—",wx+wh+60,wy-1+sin(time()),11,0) end end end end 

function showmsg(txt,dur) local wid=(#txt+2)*4+1
 local w=addwind(63-wid/2,50,wid,7,{" "..txt})
 if wind[w] then wind[w].dur=0 end w.dur=dur end

function showtalk(txt) talkwind=addwind(16,50,94,#txt*6+1,txt) talkwind.butt=true end

function addfloat(_txt,_x,_y,_c) add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0}) end

function dofloats()
 for f in all(float) do f.y+=(f.ty-f.y)/10 f.t+=1
  if f.t>70 then del(float,f) end end end

function dohpwind() hpwind.txt[1]="‡"..p_mob.hp.."/"..p_mob.hpmax local hpy=2
 if p_mob.y<8 then hpy=118 end
 hpwind.y+=(hpy-hpwind.y)/5 end

function showinv() sfx(10) local txt,col,itm,eqt={},{} _upd=update_inv
 for i=1,2 do itm=eqp[i]
  if itm then eqt=itm_name[itm] add(col,11)
  else eqt=i==1 and "[weapon]" or "[armor]" add(col,3) end add(txt,eqt) end add(txt,"") add(col,11)
 for i=1,6 do itm=inv[i]
  if itm then add(txt,itm_name[itm]) add(col,11)
  else add(txt,"...") add(col,3) end end invwind=addwind(2,24,84,62,txt) invwind.cur,invwind.col,curwind=3,col,invwind
 if statcurse then statwind=addwind(5,5,84,7,{""})
 else statwind=addwind(2,13,84,7,{"atk:"..p_mob.atk..",def:"..p_mob.defmin.."-"..p_mob.defmax..",flr:"..floor}) end end

function showuse()
 local itm=invwind.cur<3 and eqp[invwind.cur] or inv[invwind.cur-3]
 if itm==nil then return end
 local typ,txt=itm_type[itm],{}
 if (typ=="wep" or typ=="arm") and invwind.cur>3 then add(txt,"equip") end
 if typ=="fud" then add(txt,"eat") end
 if typ=="thr" or typ=="fud" then add(txt,"throw") end add(txt,"trash") sfx(10) usewind=addwind(84,invwind.cur*6+11,36,1+#txt*6,txt) usewind.cur,curwind=1,usewind end
 
function triguse() local verb,i,back=usewind.txt[usewind.cur],invwind.cur,true
 local itm=i<3 and eqp[i] or inv[i-3]
 if verb=="trash" then
  if i<3 then eqp[i]=nil
  else inv[i-3]=nil end
 elseif verb=="equip" then local slot=2
  if itm_type[itm]=="wep" then slot=1 end
  inv[i-3],eqp[slot]=eqp[slot],itm
 elseif verb=="eat" then eat(itm,p_mob) _upd,inv[i-3],p_mob.mov,p_t,back=update_pturn,nil,nil,0,false
 elseif verb=="throw" then _upd,thrslt,back=update_throw,i-3,false
 end updatestats() usewind.dur=0
 if back then curwind=invwind del(wind,invwind) del(wind,statwind) showinv() invwind.cur=i
 else invwind.dur,statwind.dur=0,0 end end
-->8
--mob, itm
function addmob(typ,mx,my) local m={x=mx,y=my,ox=0,oy=0,flp=false,ani={},flash=0,stun=false,charge=1,lastmoved=false,spec=mob_spec[typ],hp=mob_hp[typ],hpmax=mob_hp[typ],atk=mob_atk[typ],defmin=0,defmax=0,task=ai_wait,los=mob_los[typ],name=mob_name[typ]}
 for i=0,3 do add(m.ani,mob_ani[typ]+i) end add(mob,m) return m end

function mobwalk(mb,dx,dy) mb.x+=dx mb.y+=dy mobflip(mb,dx) mb.sox,mb.soy=-dx*8,-dy*8 mb.ox,mb.oy,mb.mov=mb.sox,mb.soy,mov_walk end

function mobbump(mb,dx,dy) mobflip(mb,dx) mb.sox,mb.soy=dx*8,dy*8 mb.ox,mb.oy,mb.mov=0,0,mov_bump end

function mobflip(mb,dx) mb.flp=dx==0 and mb.flp or dx<0 end

function mov_walk(self) local tme=1-p_t self.ox,self.oy=self.sox*tme,self.soy*tme end
 
function mov_bump(self)
 local tme=p_t>0.5 and 1-p_t or p_t
 self.ox,self.oy=self.sox*tme,self.soy*tme end
 
function doai() local moving=false
 for m in all(mob) do
  if m!=p_mob then m.mov=nil
   if m.stun then m.stun=false
   else m.lastmoved=m.task(m) moving=m.lastmoved or moving end end end
 if moving then _upd,p_t=update_aiturn,0
 else p_mob.stun=false end end

function ai_wait(m)
 if cansee(m,p_mob) or m.los==-1 then m.task,m.tx,m.ty=ai_attac,p_mob.x,p_mob.y
  if m.los!=-1 then addfloat("!",m.x*8+2,m.y*8,2) end end return false end

function ai_attac(m)  
 if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
  local dx,dy=p_mob.x-m.x,p_mob.y-m.y mobbump(m,dx,dy)
  if m.spec=="stun" and m.charge>0 then stunmob(p_mob) m.charge-=1
  elseif m.spec=="curse" and m.charge>0 then
   if itm_stat3[eqp[1]]==4 then givebless()
   else givecurse(p_mob) m.charge-=1 end
  elseif m.spec=="vamp" then if rnd()<0.3 then healmob(m,m.atk) end hitmob(m,p_mob) 
  elseif m.spec=="stealitm" and m.charge>0 then addfloat("steal",p_mob.x*8-4,p_mob.y*8,3) inv[flr(rnd(6))]=nil m.charge-=1
  elseif m.spec=="stealeqp" and m.charge>0 then addfloat("steal",p_mob.x*8-4,p_mob.y*8,3) eqp[flr(rnd(3))]=nil m.charge-=1
  else hitmob(m,p_mob) end updatestats() sfx(6) return true  
 else
  if cansee(m,p_mob) then m.tx,m.ty=p_mob.x,p_mob.y end
  if m.x==m.tx and m.y==m.ty or (m.spec=="scared" or m.spec=="still") and not cansee(m,p_mob) then m.task=ai_wait addfloat("?",m.x*8+2,m.y*8,2)
  else if m.spec=="slow" and m.lastmoved then return false end local bdst,cand=999,{} calcdist(m.tx,m.ty)
   for i=1,4 do local dx,dy=dirx[i],diry[i]
    local tx,ty=m.x+dx,m.y+dy
    if iswalkable(tx,ty,"checkmobs") then
     local dst=distmap[tx][ty]
     if m.spec=="scared" then dst=-dst end
     if dst<bdst then cand,bdst={},dst end
     if dst==bdst then add(cand,i) end end end
   if #cand>0 then local c=getrnd(cand)
    if m.spec!="still" then mobwalk(m,dirx[c],diry[c]) end return true end end end return false end
    
function cansee(m1,m2) return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y) end

function spawnmobs()
 mobpool={}
 for i=2,#mob_name do if mob_minf[i]<=floor and mob_minf[i]!=-1 then add(mobpool,i) end end
 if #mobpool==0 then return end
 local minmobs,maxmobs,placed,rpot=3+(floor%7),5+(floor%7),0,{}
 for r in all(rooms) do add(rpot,r) end
 repeat local r=getrnd(rpot) placed+=infestroom(r) del(rpot,r)
 until #rpot==0 or placed>maxmobs
 if placed<minmobs then
  repeat local x,y
   repeat x,y=flr(rnd(16)),flr(rnd(16))
   until iswalkable(x,y,"checkmobs") and (mget(x,y)==1 or mget(x,y)==4) addmob(getrnd(mobpool),x,y) placed+=1
  until placed>=minmobs end end

function infestroom(r) if r.nospawn then return 0 end
 local target,x,y=2+flr(rnd((r.w*r.h)/6-1)) target=min(5,target)
 for i=1,target do
  repeat x,y=r.x+flr(rnd(r.w)),r.y+flr(rnd(r.h))
  until iswalkable(x,y,"checkmobs") and (mget(x,y)==1 or mget(x,y)==4) addmob(getrnd(mobpool),x,y) end return target end
 
------items------

function takeitem(itm) local i=freeinvslot()
 if not i then return false end inv[i]=itm return true end

function freeinvslot() for i=1,6 do if not inv[i] then return i end end return 0 end

function makeipool() ipool_rar,ipool_com={},{}
 for i=1,#itm_name do local t=itm_type[i]
  if t=="wep" or t=="arm" then add(ipool_rar,i)
  else add(ipool_com,i) end end end

function makefipool() fipool_rar,fipool_com={},{}
 for i in all(ipool_rar) do if itm_minf[i]<=floor then add(fipool_rar,i) end end
 for i in all(ipool_com) do if itm_minf[i]<=floor then add(fipool_com,i) end end end

function getitm_rar()
 if #fipool_rar>0 then local itm=getrnd(fipool_rar) del(fipool_rar,itm) del(ipool_rar,itm) return itm
 else return getrnd(fipool_com) end end
-->8
--gen
function genfloor(f)
 hpwind.x,statcurse,floor,stps=2,false,f,0
 makefipool() mob={} add(mob,p_mob)
 if f==0 then copymap(16,0) if rnd()<0.25 then mset(8,7,12) end
 elseif f%9==0 then copymap(32,0)
 else poke(0x3101,66) fog=blankmap(1) showmsg("floor "..floor,120) mapgen() unfog() end end
  
function mapgen()
 repeat copymap(48,0) rooms,roomap,doors={},blankmap(0),{} genrooms() mazeworm() placeflags() carvedoors()
 until #flaglib==1 carvescuts() startend() fillends() prettywalls() installdoors() spawnchests() spawnmobs() decorooms() end

------rooms------

function genrooms()
 local fmax,rmax,mw,mh=5,4,8,8
 if floor>9 then fmax,rmax=6,5 end
 repeat local r=rndroom(mw,mh)
  if placeroom(r) then if #rooms==1 then mw/=2 mh/=2 end rmax-=1
  else fmax-=1
   if r.w>r.h then mw=max(mw-1,3)
   else mh=max(mh-1,3) end end
 until fmax<=0 or rmax<=0 end

function rndroom(mw,mh)
 local _w=3+flr(rnd(mw-2)) mh=mid(35/_w,3,mh)
 local _h=3+flr(rnd(mw-2))
 return {x=0,y=0,w=_w,h=_h} end
 
function placeroom(r)
 local cand,c={}
 for _x=0,16-r.w do for _y=0,16-r.h do if doesroomfit(r,_x,_y) then add(cand,{x=_x,y=_y}) end end end
 if #cand==0 then return false end
 c=getrnd(cand) r.x,r.y=c.x,c.y add(rooms,r)
 for _x=0,r.w-1 do for _y=0,r.h-1 do mset(_x+r.x,_y+r.y,1) roomap[_x+r.x][_y+r.y]=#rooms end end return true end

function doesroomfit(r,x,y) for _x=-1,r.w do for _y=-1,r.h do if iswalkable(_x+x,_y+y) then return false end end end return true end

------maze------

function mazeworm()
 repeat local cand={}
  for _x=0,15 do for _y=0,15 do if cancarve(_x,_y,false) and not nexttoroom(_x,_y) then add(cand,{x=_x,y=_y}) end end end
  if #cand>0 then local c=getrnd(cand) digworm(c.x,c.y) end
 until #cand<=1 end


function digworm(x,y)
 local dr,stp=1+flr(rnd(4)),0
 repeat mset(x,y,1)
  if not cancarve(x+dirx[dr],y+diry[dr],false) or (rnd()<0.5 and stp>2) then stp=0 local cand={}
   for i=1,4 do if cancarve(x+dirx[i],y+diry[i],false) then add(cand,i) end end
   if #cand==0 then dr=8
   else dr=getrnd(cand) end end x+=dirx[dr] y+=diry[dr] stp+=1
 until dr==8 end

function cancarve(x,y,walk)
 if not inbounds(x,y) then return false end
 local walk= walk==nil and iswalkable(x,y) or walk
 if iswalkable(x,y)==walk then local sig=getsig(x,y)
  for i=1,#crv_sig do if bcomp(sig,crv_sig[i],crv_msk[i]) then return true end end end return false end


function bcomp(sig,match,mask)
 local mask=mask and mask or 0
 return bor(sig,mask)==bor(match,mask) end

function getsig(x,y)
 local sig,digit=0
 for i=1,8 do
  local dx,dy=x+dirx[i],y+diry[i]
  if iswalkable(dx,dy) then digit=0
  else digit=1 end sig=bor(sig,shl(digit,8-i)) end return sig end

function sigarray(sig,arr,marr) for i=1,#arr do if bcomp(sig,arr[i],marr[i]) then return i end end return 0 end
 
------halls------

function placeflags()
 local curf=1 flags,flaglib=blankmap(0),{}
  for _x=0,15 do for _y=0,15 do
    if iswalkable(_x,_y) and flags[_x][_y]==0 then
     growflag(_x,_y,curf) add(flaglib,curf)
     curf+=1 end end end end

function growflag(_x,_y,flg)
 local cand,candnew={{x=_x,y=_y}} flags[_x][_y]=flg
 repeat candnew={}
  for c in all(cand) do for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if iswalkable(dx,dy) and flags[dx][dy]!=flg then flags[dx][dy]=flg add(candnew,{x=dx,y=dy}) end end end cand=candnew
 until #cand==0 end

function carvedoors()
 local x1,y1,x2,y2,cut,found,_f1,_f2=1,1,1,1,0
 repeat drs={}
  for _x=0,15 do for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y) found=false
     if bcomp(sig,0b11000000,0b00001111) then x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true end
     _f1,_f2=flags[x1][y1],flags[x2][y2]
     if found and _f1!=_f2 then add(drs,{x=_x,y=_y,f1=_f1,f2=_f2}) end end end end
  if #drs>0 then local d=getrnd(drs) add(doors,d) mset(d.x,d.y,1) growflag(d.x,d.y,d.f1) del(flaglib,d.f2) end
 until #drs==0 end

function carvescuts()
 local x1,y1,x2,y2,cut,found,drs=1,1,1,1,0
 repeat drs={}
  for _x=0,15 do for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y) found=false
     if bcomp(sig,0b11000000,0b00001111) then x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true end
     if found then calcdist(x1,y1) if distmap[x2][y2]>20 then add(drs,{x=_x,y=_y}) end end end end end
  if #drs>0 then local d=getrnd(drs) add(doors,d) mset(d.x,d.y,1) cut+=1 end
 until #drs==0 or cut>=3 end

function fillends() local filled,tle
 repeat filled=false
  for _x=0,15 do for _y=0,15 do tle=mget(_x,_y) if cancarve(_x,_y,true) and tle!=14 and tle!=15 then filled=true mset(_x,_y,2) end end end
 until not filled end

function isdoor(x,y) local sig=getsig(x,y) if bcomp(sig,0b11000000,0b00001111) or bcomp(sig,0b00110000,0b00001111) then return nexttoroom(x,y) end return false end

function nexttoroom(x,y,dirs) local dirs=dirs or 4 for i=1,dirs do if inbounds(x+dirx[i],y+diry[i]) and roomap[x+dirx[i]][y+diry[i]]!=0 then return true end end return false end

function installdoors() for d in all(doors) do local dx,dy=d.x,d.y if (mget(dx,dy)==1 or mget(dx,dy)==4) and isdoor(dx,dy) and not next2tile(dx,dy,13) then mset(dx,dy,13) end end end

------deco------

function startend() local high,low,px,py,ex,ey=0,9999
 repeat px,py=flr(rnd(16)),flr(rnd(16))
 until iswalkable(px,py) calcdist(px,py)
 for x=0,15 do for y=0,15 do local tmp=distmap[x][y] if iswalkable(x,y) and tmp>high then px,py,high=x,y,tmp end end end calcdist(px,py) high=0
 for x=0,15 do for y=0,15 do local tmp=distmap[x][y] if tmp>high and cancarve(x,y) then ex,ey,high=x,y,tmp end end end mset(ex,ey,14)
 for x=0,15 do for y=0,15 do local tmp=distmap[x][y] if tmp>=0 then local score=starscore(x,y) tmp=tmp-score if tmp<low and score>=0 then px,py,low=x,y,tmp end end end end
 if roomap[px][py]>0 then rooms[roomap[px][py]].nospawn=true end mset(px,py,15) p_mob.x,p_mob.y=px,py end

function starscore(x,y)
 if roomap[x][y]==0 then
  if nexttoroom(x,y,8) then return -1 end
  if freestanding(x,y)>0 then return 5
  else if (cancarve(x,y)) return 0 end
 else local scr=freestanding(x,y)
  if scr>0 then return scr<=8 and 3 or 0 end end return -1 end

function next2tile(_x,_y,tle) for i=1,4 do if inbounds(_x+dirx[i],_y+diry[i]) and mget(_x+dirx[i],_y+diry[i])==tle then return true end end return false end

function prettywalls()
 for x=0,15 do for y=0,15 do local tle=mget(x,y)
   if tle==2 then local ntle=sigarray(getsig(x,y),wall_sig,wall_msk) tle=ntle==0 and 3 or 15+ntle mset(x,y,tle)
   elseif tle==1 then if not iswalkable(x,y-1) then mset(x,y,4) end end end end end

function decorooms() tarr_dirt,tarr_farn,tarr_vase=explodeval("1,74,75,76"),explodeval("1,70,70,70,71,71,71,72,73"),explodeval("1,1,7,8") local funcs,func,rpot={deco_dirt,deco_torch,deco_carpet,deco_farn,deco_vase},deco_vase,{}
 for r in all(rooms) do add(rpot,r) end
 repeat local r=getrnd(rpot) del(rpot,r) for x=0,r.w-1 do for y=r.h-1,1,-1 do if mget(r.x+x,r.y+y)==1 then func(r,r.x+x,r.y+y,x,y) end end end func=getrnd(funcs)
 until #rpot==0 end

function deco_torch(r,tx,ty,x,y)
 if rnd(3)>1 and y%2==1 and not next2tile(tx,ty,13) then
  if x==0 then mset(tx,ty,64)
  elseif x==r.w-1 then mset(tx,ty,66) end end end

function deco_carpet(r,tx,ty,x,y) deco_torch(r,tx,ty,x,y) if x>0 and y>0 and x<r.w-1 and y<r.h-1 then mset(tx,ty,68) end end

function deco_dirt(r,tx,ty,x,y) mset(tx,ty,getrnd(tarr_dirt)) end

function deco_farn(r,tx,ty,x,y) local t=getrnd(tarr_farn) if t==244 then addmob(14,tx,ty)
 else mset(tx,ty,t) end end

function deco_vase(r,tx,ty,x,y) if iswalkable(tx,ty,"checkmobs") and not next2tile(tx,ty,13) and not bcomp(getsig(tx,ty),0,0b00001111) then mset(tx,ty,getrnd(tarr_vase)) end end

function spawnchests() local chestdice,rpot,rare,place=explodeval("1,2,2,2,3"),{},true place=getrnd(chestdice) 
 for r in all(rooms) do add(rpot,r) end 
 while place>0 and #rpot>0 do local r=getrnd(rpot) placechest(r,rare) rare=false place-=1 del(rpot,r) end end

function placechest(r,rare) local x,y
 repeat x,y=r.x+flr(rnd(r.w-2))+1,r.y+flr(rnd(r.h-2))+1
 until mget(x,y)==1 mset(x,y,rare and 12 or 10) end

function freestanding(x,y) return sigarray(getsig(x,y),free_sig,free_msk) end
__gfx__
000000000000000044404440044442002220222000000000bbbbbbbb00bbb00000bbb00000000000000000000000000000bb3000b0b0b0b0b000000011111110
000000000000000000000000444444200000000000000000bbbbbbbb0b000b000b000b00044442200bbbb33044442220b0bb303000000000b033000000000000
007007000000000040444040444244202022202000000000b000000b0b000b000b000b00040000200b0bb03040000020b0000030b03330b0b0330bb011000000
0007700000000000000000004420442000000000000000000033030000bbb00030bbb030040000200b00003040000020b00b00300033300000330bb011011000
000770000000000044404440444444200000000000000000b000000b0303330033003330044422200bbb333044444220bbb0b330b03030b0b0000bb011011010
0070070000010000000000002444422000010000000000003030330303333300033333000000000000000000000000000000000000333000b033000011011010
000000000000000040444040022222000000000000000000300000030033300000333000044222200bb3333044442220bbbb3330b03330b0b0330bb011011010
00000000000000000000000000000000000000000000000033333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004444444444442000444444404444200444442004420444444444444000044444420000044444444000044200000444444200000
00000000000000000000000044444444444444204444444444424420444444204420244444444444000024444220000044444444000044200000244444200000
00000000000000000000000044222222222244204422222244204420222244204420022222222222000002222200000022222222000044200000022244200000
00000000000000000000000044200000000044204420000044204420000044204420000000000000000000000000000000000000000044200000000044200000
00000444444444444200000044200000000044204420044444204420420044204420044442000444420004444200044400000444420044204444444444200444
00004444444444444420000044200000000044204420444444204420442044204420444444204444442044444420444400004444442044204444444444204444
00004422222222224420000044200000000044204420442244204420442044204420442244204422442044224420442200004422442044202222222244204422
00004420000000004420000044200000000044204420442044204420442044204420442044204420442044204420442000004420442044200000000044204420
00004420044442004420000044200000000044200444444444204444444442004420444444204420442044444420444444204444442000004420442044444444
00004420444444204420000044200000000044204444444442202444444444204220244442204420422024444220244444202444422000004220442044444444
00004420444244204420000044200000000044204422222222000222222244202200022222004420220002222200022244200222220000002200442022222222
00004420442044204420000044200000000044204420000000000000000044200000000000004420000000000000000044200000000000000000442000000000
00004420444444204420000044444444444444204444444442000444444444204444444442004420000004444200000044200000444444440000442042000000
00004420244442204420000024444444444442202444444444204444444442204444444444204420000044444420000044200000444444440000442044200000
00004420022222004420000002222222222222000222222244204422222222002222222244204420000044224420000044200000222222220000442044200000
00004420000000004420000000000000000000000000000044204420000000000000000044204420000044204420000044200000000000000000442044200000
00004444444444444420000044444444442044204420444444204420442044200000444444200000000044440000000044204444442000000000000000000000
00002444444444444220000044444444442044204420244444204420422044200000244442200000000024440000000042202444422000000000000000000000
00000222222222222200000022222222442044204420022244204420220044200000022222000000000002220000000022000222220000000000000000000000
00000000000000000000000000000000442044204420000044204420000044200000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000044444444442044204444444444444420444444204200000000000444000004444200044400000000420000000000000000000000
00000000000000000000000044444444442044202444444424444220444442204420000000004444000044444420444400000000442000000000000000000000
00000000000000000000000022222222442044200222222202222200222222004420000000004422000044224420442200000000442000000000000000000000
00000000000000000000000000000000442044200000000000000000000000004420000000004420000044204420442000000000442000000000000000000000
09000000000000000000090000000000101010102220222000000000000110000000000000000000000000000000000000000000000000000000000000000000
90000000090000000000009000000900000000000000000000100000000000100100001001010010001000000000001000100000000000000000000000000000
a90000009a000000000009a000000a90101010102022202000010100011001000100001001000000000001000010011000000100000000000000000000000000
00000000000000000000000000000000000000000000000001010000111010000001000000001000000001100000000001000000000000000000000000000000
44000000440000000000044000000440101010101010101000001010000010100001010000001010001100000000000000011000000000000000000000000000
00010000000100000001000000010000000000000000000000101000000100000101010001000010011100000011001000100100000000000000000000000000
40000000400000000000004000000040101010101010101000001000000100000100000001010010000001000111100000111000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666500666500000000000000000000dddd100000000000000000bbbb3000099940000000000000000000000000000000000000000000000000000000000000
000650000650000000000000000000000d10d1000bbb30eeeee2000b30b300009400000000000000000000000000000000000000000000000000000000000000
000065006500bbbb300aaa900aaa90000d100d1000b3000e2002000b300b30009400000000000000000000000000000000000000000000000000000000000000
00000666500b3000b300a90000a900000d1000d100b3000e2000000b3000b3009400000000000000000000000000000000000000000000000000000000000000
0000066650b300000b30a90000a900000d1000d100b3000e2000000b3000b3009400000000000000000000000000000000000000000000000000000000000000
0000006500b300000b30a90000a900000d1000d100b3000eee20000b3000b3099940000000000000000000000000000000000000000000000000000000000000
0000006500b300000b30a90000a900000d1000d100b3000e2000000b3000b3000000000000000000000000000000000000000000000000000000000000000000
0000006500b300000b30a90000a900000d100d1000b3000e2000000b300b30009400000000000000000000000000000000000000000000000000000000000000
00000065000b3000b3000a900a9000000d10d10000b3000e2002000b30b300099940000000000000000000000000000000000000000000000000000000000000
000006665000bbbb300000aaa9000000dddd10000bbb30eeeee200bbbb3000009400000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000880000888800000000000000000000000000002888000028888800288800002888000
00000000008880000000000000000000000880000000000000088000008888002800080008888000000000000888800000880880008808800088088000888880
00888000028808000088800000000000008888000008800000888800008080002000000028000800088888802800080002888880028880000288888002888880
08880800028808000888080008888880008080000088880000808000208888802880000028800000288000002880000000200000002000000020000000200000
28888080028888002888808028888008208888800080800020888880228880800288800002888000028880000288800020288000002880002028800000288000
22888880022888002288888022888888228880802088888022888080022200002028088020280880202808802028088020028800000288002002880000028800
02222200002220000222220002222220022200002288808002220000000000002020220020202200202022002020220002222000222220000222200022222000
00000000000000000000000000000000000000000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000000888000088800000088800088008800000000000800080000000000800000088200000802000000000000000008880000000000000888000008880
08808000008808000880800000880800800080000880088000800080088008808020000000000000080000008820000000228080000088800022808000228880
28880880028880882888000002888000800080008000800008000800800080000000000000000000000000000000000002288880002280800228888002288880
28888080028888082888888002888888088808000888080008880800088808000000802000000000000008000000882002288800022888800228880002288800
02808000028088000280808002888808208080802880808028888080208880800000080000008820000080200000000000228880022888000022888000228880
28000000280280002800000028028000280880202088802020808020288080200000000000800000088200000802000002208000022080800220800002208000
02200000022022000220000002202200222222002220220022022200202222000882000008020000000000000080000002002200020022000200220002002200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000288000002880000000000080000000000000000000800000000000000000008000000000000000000000000000000000000000000000000000000
00288800002888000028880000288800200880000088000000880080000880000808880028888800080888000008880008888800088888000000000008888800
02888800028080800288888002888800208880000088808000888080208880002880808022088080288080800880808028000000280000000888880028000000
02808080028888800288888002888880028888002008808002888800208800802208888020808880220888802888888028888000288880002800000028888000
22288880222888802228888022288880028800800288880020088800028888002080880020880800208088002208880022808880228088802288800022808880
22080080220800802208008022080080002880800028880020288000022880002028088000288080202808802020888022280000222222202220888022222220
20280280202802802028028020280280022220000222200000222200002222000022808000228880002280802022088002022220020020002022222002002000
00000000000000000000000000000000000000000000000000000000000000000222222002222220022222200222202000000000000000000000000000000000
00000000000b0b0000000000000b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b0b0000b33300000b0b0000b3330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000
00b333000003033300b333000003033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00000
0003033300b333330003033300b3333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbb0000
030333330030000000b333330300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00000
3300000003303300033000003303330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000
33033303033033000330330033033303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00300300000330000030030000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000050100000303030103010307020005050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000001011120000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000010111200000000000000000000101111240e231111120000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000101111240e23111112000000000000002004454544454504220000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000200445454445450422000000000000002040444406444443220000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000204044440a444442220000000000000020490a4444440a46220000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000204b44444444444c2200000000000000200144440c44444a220000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002001074a014b084a22000000000000002008484701014b07220000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000303131140f1331313200000000000000303131140f133131320000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000303132000000000000000000000000003031320000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000b770147600b7701800018000180001800018000180001800000000000000000000000000000c0000c0000c0000c0000c0000c0000c00000000000000000000000000000000000000000000000000000
00010000236302362018620276300f6300f6301a63018630166301463016600156001463000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00020000175301b530176401353015500005001762015530175301b53000500015001e50014500205001250012500005001d500145001f5001250000500005000050000500005000050000500005000050000500
000200001203012630160401203010600125000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000d0420c0420b0421300215002000021700215002160020e0020c002090020900200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010100001b6461c7361d7461e7361c706117061d7461e6361f74620736017061c7061d7061e7061f706017061b7061c7061d7061e706017060170601706017060170601706017060170601706017060170601706
01010000231452313518135271450f6450f6451a64518645166451464516605156051464500105001050010500105001050010500105000050000500005000050000500005000050000500005000050000500005
010300000f614106350f6250e614106040c604106040d604106040c6041660410604106340f6250e6140d60411604006041c604136043760423604086040e6140f6350e6250d6140c60500605006050060500605
0104000017024231251c0242812500004000050000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
011600000217502105021150210002135001000210402104021250010002105001000215500100001000211401175011050111500105011350010500105001050112500105001050010501135001000010000100
000200001056514555185453450500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050000000000
000200001054512545235053450500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050000500005
00160000215101d510195251a535215351d520195151a5152151221515215252252521525215150e51511515205141c510195251c535205351c520195151c5152051220515205252152520525205150d51510515
0016000000000215101d510195151a515215151d510195151a5152151221515215152251521515215150e51511515205141c510195151c515205151c510195151c5152051220515205152151520515205150d515
00160000150051d00515015150151a0251a0151d0151d015220252201521025210151d0251d0151502515015140201402214025140151400514004140050d000100140c0100d0201003014030150201401210015
001600000217502705021150200002135000000000000000021250000000000000000215500000000000211405175001050511500105051350010500105001050512500105001050010505135000000000000000
00160000215141d510195251a525215251d520195151a5152151221515215202252021525215150e52511515205141d5101852519525205251d520185151951520512205151c5201d52020525205151052511515
0116000000000215141d510195151a515215151d510195151a5152151221515215102251021515215150e51511515205141d5101851519515205151d510185151951520512205151c5101d510205152051510515
00010000236302362018620276300f6300f6301a63018630166301463016600156001463000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00020000175301b530176401353015500005001762015530175301b53000500015001e50014500205001250012500005001d500145001f5001250000500005000050000500005000050000500005000050000500
000200001203012630160401203010600125000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000170001b00017000130001500500005170051500516005180201602013020100200d0200a0200702007020070200702007020070200702007020070200702007020070200702007020070200102000000
000100001b6461c7361d7461e7361c706117061d7461e6361f74620736017061c7061d7061e7061f706017061b7061c7061d7061e706017060170601706017060170601706017060170601706017060170601706
00010000231402313018130271400f6400f6401a64018640166401464016600156001464000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000f614106350f6250e614106040c604106040d604106040c6041660410604106340f6250e6140d60411604006041c604136043760423604086040e6140f6350e6250d6140c60500605006050060500605
0004000017024231251c0242812500004000050000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
01160000000002000015015150151a0251a0151d0251d015220252201521015210151d0251d01526015260152502025012250152501518000000000000000000100000d02011030140401505014040190301d010
000200001056514555185453450500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050000000000
000200001054512545235053450500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050000500005
011600000717502005071150200007135000000000000000071250000000000000000715500000000000711403175001050311500105031350010500105001050312500105001050010503155000000000000000
01160000091750200509115020000913500000000000000009125000000000000000091550000000000091140a175001050a115001050a1250010504105001050a125001050910500105041350c1000912500100
01160000225121f5201a5251f515225251f5201a5151f515215122151222525215251f5251f5150e52513515225141f5101b5251f525225251f5201b5151f515215122151222525215251f5251f5150f52513515
01160000215141c510195251d515215251c520195151d5152151222510215201f51021512215150d52510515205141d5101a52516515205151d5201a5151651520522205151d515205251f5251d5151c52519515
0116000000000225121f5101a5151f515225151f5101a5151f515215122151222515215151f5151f5150e51513515225141f5101b5151f515225151f5101b5151f515215122151222515215151f5151f5150f515
0016000000000215141c510195151d515215151c510195151d5152151222510215101f51021510215150d51510515205141d5101a51516515205151d5101a5152051520510205151d515205151f5151d5151c515
01160000000000000022015220151f0251f0151a0151a01522025220151f0151f01519020190221a0251a0151f0201f0221f0151f01518000000000000000000000000f010130201603015030160321502013015
011600001902519015220252201521015210151c0251c015220252201521025210151c0221c0151d0251d01520020200222001520015110051a0151d015220152601226012280102601625010250122501025015
011600000217509035110150203502135090351101502104021250000002105000000212511035110150211401175080351001501035011350803510015001050112500105001050010501135100351001500000
0116000002175090351101502035021350903511015021040212500000021050000002155110351101502114051750c0351401505035051350c03514015001050512500105001050010505135140351401500000
01160000071750e0351601507035071350e0351601502104071250000002105000000715516035160150711403175160351301503035031351603513015001050312500105001050010503135160351601500000
0116000009175100351101509035091351003511015021040912500000021050000009155100350d015091140a17510035110150a0350a1351003511015001050a12500105001050010509135150350d01509020
0116000002215020451a7051a7050e70511705117050e7050e71511725117250e7250e53511535115450e12501215010451a6001a70001205012051a3001a2001071514725147251072510535155351554514515
0016000002215020451a7051a7050e70511705117050e7050e71511725117250e7250e53511535115450e12505215050451a6001a70001205012051a3001a2001171514725147251172511535195351954518515
0116000007215070451a7051a7050e70511705117050e705137151672516725137251353516535165451312503215030451a6001a70001205012051a3001a2001371516725167250d7250f535165351654513515
0116000009215090451a7051a7050e70511705117050e7050d715157251572510725115351653516545157250a2150a0451a6001a70001205012051a3001a2000e71510725117250e7250d5350e5351154510515
0016000021005210051d00515015150151a0151a0151d0151d015220152201521015210151d0151d01515015150151401014012140151401518000000000000000000100100c0100d01010010140101501014010
0116000000000000002000015015150151a0151a0151d0151d015220152201521015210151d0151a01526015260152501019015190151900518000000000000000000000000d0101101014010150101401019010
0116000000000000000000022015220151f0151f0151a0151a01522015220151f0151f01519010190121a0151a0151f0101f012130151300518000000000000000000000000f0101301016010150101601215010
01160000190051901519015220152201521015210151c0151c015220152201521015210151c0121c0151d0151d015200102001220015200051d0051a015220152901029012260102801628010280122801528005
01160000097140e720117300e730097250e7251173502735057240e725117350e735097450e7401174002740087400d740107200d720087350d7351072501725047240d725107250d725087350d7301074001740
01160000097240e720117300e730097450e745117350e735117240e725117350e735097450e740117400e740087400d740117200d720087350d735117250d725117240d725117250d725087350d730117400d740
011600000a7240e720137300e7300a7450e745137350e735137240e725137350e7350a7450e740137400e7400a7400f740137200f7200a7350f735137250f725137240f725137250f7250a7350f730137400f740
0116000010724097201073009730107450974510735097351072409725107350973510745097401074009740117400e740117200e720117350e735117250e725117240e725117250e725097350d730107400d740
011300000d2200c2200b220195001d500215001c50019500297202873026726267452874021730297202173226730267322673520500205001d500205001f5001d5001c500000000000000000000000000000000
0113000000000000000000000000000000000000000000000e1100d1200a1300e1350d1350c1000a120091300e1220e1200e1200c1000c1000c1000c100001000010000000000000000000000000000000000000
0113000000000000000000000000000000000000000000000a14300000000000a0600906000000000000000002072020720207200000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001f5002b5002e5002e5000000000000000002750027500285002a500000000000000000275002950029500000000000000000000002450024500245002750029500000000000000000000000000000000
000100001e5001e5001c5001c50013200132001320013200112000f2000d2000b2000920007200072000720007200072000720007200072000720007200072000720007200072000720007200072000600002200
000100001e5001e5001c5001c5002e500305002e5002b5002b5002b50029500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e500265001e500235001e500215001e50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000247000c1002460018200303000c5000c6000c3001840030700245000c1001820030500247000c100186003040024600305000c6001810024200305002420018300304000c50024700302000c50018400
__music__
03 09 42 43 44
01 09 0e 2d 44
00 0f 1a 2e 44
00 1d 23 2f 44
00 1e 24 30 44
00 25 0c 0d 44
00 26 10 11 44
00 27 1f 21 44
00 28 20 22 44
00 09 31 0e 44
00 0f 32 1a 44
00 1d 33 23 44
00 1e 34 24 44
00 09 29 43 44
00 0f 2a 43 44
00 1d 2b 43 44
02 28 2c 43 44
00 35 36 37 44
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
