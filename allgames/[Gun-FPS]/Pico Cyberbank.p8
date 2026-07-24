pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- picocyberbank

-- optimize tokens
haircolm={2,3,4,8,10,14}
haircols={1,5,5,2,9,2}
skincolm={6,15,4}
clotcolm={2,8,9,10,11,12,13,14}
clotcols={8,9,10,9,7,7,12,8}
bootcolm={2,4,7,8,9,10,11,12,13}

cors,cpum={},{}
debug=false

--r g b plasma
--phase 0 shoot 
--      1 change door
--mode 0-game 1-endround 2-intro
--     3-endgame
local t,r,g,b,portes,seq,iseq,
 score,slot,islot,phase,day,
 mode,vfx,hiscore,block_key,
 glpart,txtpart,bad_left,seqidx=
  0,{},{},{},{},{},0,
  0,{},0,0,1,
  2,{},0,false,
  {},{},{},0

function _init()
 cartdata"picocyberbank"
 hiscore=dget(0)
 ach=dget(1)
 menuitem(1,"reset hiscore",
  function()
   dset(0,0)
   dset(1,0)
   hiscore=0
  end)
 init_intro()
end

function init_game()
 music(-1,500)
 glpart,score,lastscore,
 live,day=
  {},0,0,
  5,1
 init_round()
 --
-- day=9
-- phase=3
-- mode,ach=4,10
-- nbcrchip=55
 --
end

function init_round()
 --init round
 --init plasma
 for i=0,15 do
		r[i]=sget(i,0)
		g[i]=sget(i,1)
		b[i]=sget(i,2)
	end
	--init etat partie
 for i=0,2 do
  portes[i]={}
 	portes[i].etat=0
 	portes[i].ouv=0
 	portes[i].delai=60
  portes[i].perso={i=i}
  local co=cocreate(init_perso)
  add(cors,co)
  coresume(co,portes[i].perso)
 end
 seq,iseq,slot,islot,
 dec,mode,shoot_ok,aie,phase,
 nbcrchip=
  {},0,{},0,
  0,0,true,0,2,
  0
 generer_bad_left()
 -- preparation des slots
 for i=0,8 do
  slot[i],vfx[i]=0,0
 end
 block_key=true
end

function init_intro()
 music(0)
 init_ach()
end

function init_ach()
 load_gfx(40,0,96)
 load_gfx(41,24,96)
 load_gfx(42,40,112)
 load_gfx(43,64,112)
end

function _update()
 update_part(glpart)
 update_part(txtpart)
 --intro
 if mode==2 then
  iseq+=1
  update_intro()
  if (btn(—) or btn(Ž)) 
   and iseq>=30 then
   init_game()
  end
  return
 end
 --endround
 if mode==1 then
  iseq+=1
  update_endround()
  if (btn(—) or btn(Ž)) 
   and ibonus>=nbcrchip then
   init_round()
   if day==9 then
    --9 jours, good job !
    mode,iseq,ach=4,0,10
    music(15)
    init_ach()
    dset(1,ach)
   else
    day+=1
    mode=0
   end
  end
  return
 end
 --endgame
 if mode==3 or mode==4 then
  iseq+=1
  if (btn(—) or btn(Ž)) 
   and iseq>60 then
   --goto intro
   mode=2
   iseq=0
   init_intro()
  end
  return
 end
 -- debut de partie
 if phase==2 then
  iseq+=1
  if (iseq>=60) then
   phase=0
   iseq=0
  end
  return
 end
 -- fin de round transition
 if phase==3 then
  for i=0,8 do
   if iseq==0 then
    vfx[i]=60
   else 
    vfx[i]-=1
   end
  end
  iseq+=1
  if iseq>=60 then
   mode=1
   iseq=0
   ibonus=0
   sfx(57)
  end
  return
 end
 -- fin de round
 -- condition de victoire
 local victory=true
 for i=0,8 do
  victory=victory and slot[i]==1
 end
 if victory then
  iseq,phase=0,3
  return
 end
 -- fin de partie
 if live<0 then
  sfx(30)
  mode,iseq,ach=
   3,0,max(day,ach)
  dset(1,ach)
  return
 end
 
 -- chargement des personnages
 for c in all(cors) do
   if costatus(c)~="dead" then
     coresume(c)
     --une la fois
     break
   else
     del(cors,c)
   end
 end

 --les touches
 shoot,chg_porte,lasers=nil,0,{}
 if not block_key then
  if (btn(‹)) shoot=0
  if (btn(”)) shoot=1
  if (btn(‘)) shoot=2
  if (btn(—)) chg_porte=-1
  if (btn(Ž)) chg_porte=1
  if (shoot==nil) shoot_ok=true
 end
 if (btn()==0) block_key=false
  
 -- sequences des portes
 iseq+=1
 freq=31-day
 seqidx=flr(iseq/freq)

 --si fin de sequence et
 --changement de porte
 if chg_porte~=0 
  and seqidx>=#seq then
  islot=(islot+chg_porte)%9
  seq={-1}
  iseq=0
  phase=1
  dec=chg_porte
 elseif seqidx>#seq then
  seq=generer_seq(day)
  iseq=0
  phase=0
 end

 if iseq%freq==0 then
  local porte=
    portes[seq[seqidx]]
  -- si la porte est ferme
  -- alors on l'ouvre
  if porte~=nil
   and porte.etat==0 then 
   porte.etat=1
  end
 end
 
 if shoot_ok and shoot~=nil then 
  --le tir passe si la porte 
  --est ouverte
  if portes[shoot].etat==2 then
   local pers=portes[shoot].perso
   -- glitchy ? on resoud
   if pers.bad==2 then
    pers.bad=flr(rnd(3))
   else
    -- sinon on tue
    if pers.state~=1 then
     pers.state=1
     if pers.bad==0 then
      incscore(5)
     else
      --incscore(-50)
      live-=1
      aie=20
      sfx(62)
     end
    end
   end
  end
 end
 --mise jour des plasma
 --et des persos
 for i=0,2 do
  update_perso(portes[i].perso)
  update_door(portes[i])
 end
 --
 t+=0.0025
 if (aie>0) aie-=1
end

function incscore(plus)
 score=max(score+plus,0)
 --vie supplementaire
 if flr(score/1000)>
  flr(lastscore/1000) then
  live=min(live+1,9)
 end
 if (score>lastscore) lastscore=score
 --hiscore
 if (hiscore<score) hiscore=score
 dset(0,hiscore)
end

function update_endround()
 -- nbchip bonus 
 if iseq%5==0 and ibonus<nbcrchip then 
  ibonus+=1
  incscore(25)
  local part={
   x=98,y=39,
   vx=0,vy=1,
   i=0,e=10,
   c=1,msg=25}
  add(txtpart,part)
  if ibonus<50 then
   for i=0,2 do
    part={
     x=26+(ibonus%10)*8,
     y=68+8*flr(ibonus/10),
     vx=rnd(2)-1,vy=0.2+rnd(2),
     s=rnd(2),
     i=flr(rnd(2)),e=10,
     c=flr(rnd(2))==0 and 10 or 9
    }
    add(glpart,part)
   end
  end
  if ibonus==nbcrchip then 
   sfx(57,-2)
   sfx(56)
  end
 end
end

function update_part(parts)
 for p in all(parts) do
  p.x+=p.vx
  p.y-=p.vy
  p.i+=1
  if (p.ay~=nil) p.vy-=p.ay
  if p.i>p.e then
   del(parts,p)
  end
 end
end

function update_perso(perso)
 --perso mort, animation
 if perso.state==1 then
  perso.frm+=1
  if perso.frm>15 then
   local part={
    x=8+rnd(16),y=32+rnd(16),
    vy=0.2+rnd(2),s=1+rnd(2),
    i=flr(rnd(2))}
   add(perso.part,part)
  elseif perso.frm==1 then
   sfx(61)
  end
  --evenement sur perso vivant
 elseif perso.pret then
  --action avant la fermeture
  local frm=iseq-perso.pret
  if frm==58 and
   perso.state==0 then
   if perso.bad==1 then
    local islot=(perso.i+islot)%9
    slot[islot],vfx[islot]=1,15
    incscore(5)
    nbcrchip+=1
    sfx(63)
   elseif perso.bad==0 then
    live-=1
    aie=20
    sfx(62)
    add(lasers,perso.i)
   end
  elseif perso.bad==3 
   and frm==33 then
   perso.bad=flr(rnd(3))-1
  elseif perso.bad==4 
   and frm==33 then
   perso.bad=0
   sfx(59)
  end
 end

 -- burning particles
 for p in all(perso.part) do
  p.x+=cos(p.i/16)
  p.y-=p.vy
  p.i+=1
  if p.i>20 then
   del(perso.part,p)
  end
 end
end

-- etat porte:
-- 0 ferme
-- 1 s'ouvre
-- 2 ouverte
-- 3 se ferme
function update_door(porte)
 --est-ce que la porte s'ouvre ?
 if porte.etat==1 then
  porte.ouv+=0.05
  if porte.ouv>=1 then
   porte.etat=2
   porte.perso.pret=iseq
  end
 --est-ce que la porte est ouverte ?
 elseif porte.etat==2 then
   porte.delai-=1
   if porte.delai==0 then
    porte.etat=3
    porte.delai=60
   end
 --est-ce que la porte se ferme ?
 elseif porte.etat==3 then
  porte.ouv-=0.05
  if porte.ouv<=0 then
   porte.ouv=0
   porte.etat=0
   
   --charge perso suivant
   local co=cocreate(init_perso)
   add(cors,co)
   coresume(co,porte.perso)
  end 
 end
end


function _draw()
 
 if mode==4 then
  dessine_goodjob()
  return
 elseif mode==3 then
  dessine_endgame()
  return
 elseif mode==2 then
  dessine_intro()
  return
 elseif mode==1 then
  dessine_endround()
  return
 end
 -- debut partie
 cls()
 if phase==2 then
  camera(-50,-44)
  dessine_day()
  camera()
  dessine_hud()
  if iseq%(60/day)==0 then
   sfx(58)
   glitch_block()
  end 
  return 
 end
 -- partie
 local dx,s,e,offs=0,0,2,islot
 -- animation changement porte
 if phase==1 then
  dx=-min(iseq,freq)/freq*40*dec
  if dec>0 then
   e=3
   offs=islot-1
  else
   s=-1
   offs=islot+1
  end
 end

 dessine_jeu(s,e,dx,offs)
 
 dessine_hud()
 dessine_part(glpart)
 for laser in all(lasers) do
  dessine_ennemi_laser(laser)
 end
 dessine_laser(shoot)
 --
 if (aie>0) glitch_block()
 if (aie>10 and aie<14) pal_aie()
 
-- if glitch then
--  glitch_block()
-- end
 --debug--
 local cpu=stat(1)
 if cpu>1 then
  add(cpum,cpu)
  color(7)
 else
  color(1)
 end


 if debug then
 print(""--"ouv="..portes[0].ouv
--  .." etat="..portes[0].etat
--  .." delai="..portes[0].delai
   .."–"..stat(1)
   .." mem "..stat(0),0,0 )

  print("cors="..#cors,0,65,7) 
  print("t="..t,0,71,7) 
  print("cpum="..#cpum.." "..
   max(1,#cpum-5),0,77,7) 
  print("iseq "..iseq,0,83,7)
  for i=#cpum,max(1,#cpum-5),-1 do
   print(""..cpum[i],
    0,83+6*(#cpum-i))
  end
  for i=1,#seq do
   if flr(iseq/freq)==i then
    color(8) else color(6)
   end
   print(""..seq[i],64,59+6*i)
  end
  for i=1,#bad_left do
   print(""..bad_left[i],80,59+6*i,6)
  end
 end
end

function dessine_jeu(s,e,dx,offs)
 for i=s,e do
  local sx,porte=
   8+i*40+dx,portes[i%3]
  if porte.etat!=0 then 
   dessine_perso(sx,16,porte.perso)
  end
  dessine_porte_ori(sx,16,
   t+0.1111*(i+offs)%9,
   porte.ouv*16)
 end
 dessine_decor(dx)
 if seqidx>=#seq 
  and (iseq)%8<4 then
  print("—",3,90,6)
  print("Ž",116,90,6)
 end
end

function dessine_day()
 local msg="day "..day
 local stx=0 --64-2*#msg
 dessine_boite(stx,0,stx+#msg*4+8,22)
 print(msg,stx+6,3,6)
 pal_number(day-1)
 spr(3,#msg*2+1,12,1,1)
 rect(#msg*2,11,#msg*2+9,20,1)
 pal()
end

function dessine_endgame()
 if (iseq%2==0) glitch_block()
 dessine_final()
end

function dessine_goodjob()
 update_intro()
 if rnd(15)<1 then  
  local x,y=rnd(96)+16,rnd(32)+16
  for i=0,5 do
   local part={
    x=x,y=y,
    vx=2-rnd(4),vy=1+rnd(4),
     ay=0.75,s=1+rnd(1),
    i=flr(rnd(2)),e=8,
    c=10}
   add(glpart,part)
  end
 end
 
 dessine_city()
 dessine_final()

end

function dessine_final()
 dessine_boite(40,40,86,66)
 print(" game over ",42,42,6)
 print("final score",42,48,6)
 print("   "..pad6(score),
  40,54,6)
 print("   day "..day,42,60,6)
end

function dessine_boite(x,y,x2,y2)
 fillp(0x0f0f)
 rectfill(x,y,x2,y2,0x10)
 fillp(0xf0f0)
 rect(x,y,x2,y2,0x70)
 fillp()
end

function dessine_endround()
 dessine_boite(16,8,112,104)
 camera(-50,-10)
  dessine_day()
 camera()
 -- credchip
 local e=min(nbcrchip-1,flr(iseq/5))
 print("credchip collected "..(e+1),22,56,6)
 for i=0,e do
  if i<50 then
   spr(146,24+(i%10)*8,
    64+8*flr(i/10))
  end
 end
 -- score ++++
 local padscore=pad6(score)
 print("score          "
 ..padscore,22,39)
 -- text particules
 dessine_part_txt(txtpart) 
 dessine_part(glpart)
 -- unlock
 if day>ach and day%2==0 then
  print("something unlocked",
    30,47,6)
 end
end

function dessine_part(parts)
 for p in all(parts) do
  --local offset=flr(p.i*7/20)
  --local c=shr(
  -- peek(0x0c0+offset/2),
  -- offset%2*4)
  if (p.pat~=nil) fillp(p.pat)
  circfill(p.x,p.y,p.s,p.c)
  if (p.pat~=nil) fillp()
 end
end

function dessine_part_txt(parts)
 for p in all(parts) do
  local c=peek_spr(0x00c4,flr(p.i/2))
  print(p.msg,p.x,p.y,c)
 end
end

function dessine_hud()
 fillp(0xf0f0)
 rectfill(0,104,127,127,0x2d)
 fillp()
 rect(0,104,127,127,6)
 for i=0,8 do
  if slot[i]==1 then
   pal(5,8)
  end
  local slotx=4+i*14
  spr(128,slotx,108,1,1)
  pal()
  if vfx[i]>0 then
   if vfx[i]>10 then
    local part={
     x=slotx+rnd(8),y=112,
     vx=rnd(2)-1,vy=0.5+rnd(2),
     s=rnd(2),
     i=flr(rnd(2)),e=10,
     c=flr(rnd(2))==0 and 10 or 9}
    add(glpart,part)
   end
   --anim
   spr_grd(128,4+i*14,108,7,7,
    0x01c0,vfx[i],5,16)
   vfx[i]-=1
  end
  --surround
  if i==islot or i==(islot+1)%9
   or i==(islot+2)%9 then
   rect(3+i*14,107,12+i*14,116,7)   
  end
 end
 print(max(0,live).."xup"
  .." day "..day
  .." sco."..pad6(score)
  .." hi."..pad6(hiscore)
  ,2,121,7)
end

function dessine_decor(dx,offs)
 local sx,ex,offs=0,120,islot
 if phase==1 then
  if dec>0 then
   ex=ex+40
   offs=islot-1
  elseif dec<0 then
   sx=-40
   offs=islot+1
  end
 end
 --todo optimize tokens
 --use tilemap ?
 for x=sx,ex,40 do
  camera(-dx,0)
  spr(16,x,8,1,1)
  spr(32,x,16,1,2)
  spr(32,x,32,1,2)
  spr(32,x,48,1,2)

  spr(17,x+8,8,2,1)
  spr(19,x+32,8,1,1)
  pal_number((offs+x/40)%9)
  spr(3,x+24,8,1,1)
  pal()
  palt(13,true)
  sspr(7,16,1,16,x+8,16)
  sspr(7,16,1,16,x+8,32)
  sspr(7,16,1,16,x+8,48)
  sspr(0,16,1,16,x+39,16)
  sspr(0,16,1,16,x+39,32)
  sspr(0,16,1,16,x+39,48)
  palt()

  camera()
  local x1,x2,x3,x4=
   dx+x-56,dx+x-24,
   dx+x-39,dx+x-31
  color(1)
  p01_trapeze_h(
   64+x1,63+x2,
   64+x1*2,63+x2*2,
   65,96)
  color(6)
  p01_trapeze_h( 
   64+x3*1.25,63+x4*1.25,
   64+x3,63+x4,
   0,6)
  -- line gradient
  line(0,81,127,81,0)
  line(0,89,127,89,0)
  line(0,93,127,93,0)
  line(0,95,127,95,0)

--  otri(64+x2,64,64+x1*2,96,64+x2*2,96,1)
 end
end

function dessine_laser()
 if shoot==nil or 
  not shoot_ok then
   return
 end
 --one shot
 shoot_ok=false
 sfx(60)

 local cx,cy=shoot*40+24,40
 color(3)
 p01_trapeze_h(cx-1,cx+1,
   94,98,cy,96)
 color(11)
 p01_trapeze_h(cx,cx,
   95,96,cy+1,95)
end

function dessine_ennemi_laser(i)
 sfx(60)
 local cx,cy=i*40+32,40
 color(8)
 p01_trapeze_h(cx-1,cx+1,
   64,68,cy,96)
 color(14)
 p01_trapeze_h(cx,cx,
   65,66,cy+1,95)
end

function pal_aie()
 for i=2,15 do
  pal(i,7,1)
 end
end

function pal_number(n)
 palt(0,false)
 pal(0,6)
 for i=1,9 do
  pal(i,i-1<=n and 5 or 6)
 end 
end

function dessine_porte_ori(dx,dy,z,op)
 if (op>=16) return
 local lr,lg,lb=r,g,b

 for y=0,47,3 do
  for x=0,31,1 do
   if ((x+y)%2==0) then 
   
    local v1,v2=
	 			128+96*sin(y+z),
	 			sin(z-x/512+y/256)
    local colr,colg,colb=
	 			8+7*sin((z+x)/v1+(z+y)+v2),
	 			8+7*sin((x-y)/v1*v2),
	 		 8+7*cos((v2*x-y)/v1)

	  	local col=lr[flr(colr+op)]
	  	if col!=nil then
     line(dx+x,dy+y,dx+x+1,dy+y,col)
    end
    col=g[flr(colg+op)]
	  	if col!=nil then
     line(dx+x,dy+y+1,dx+x+1,dy+y+1,col)
    end
    col=b[flr(colb+op)]
	  	if col!=nil then
     line(dx+x,dy+y+2,dx+x+1,dy+y+2,col)
    end
   end
  end
 end
end

function dessine_perso(x,y,pers)
 camera(-x,-y)
 clip(x,y,32,48)

 set_pal_perso(pers)
 rectfill(0,0,31,47,1)
 dessine_sprite(pers)
 pal()
 local pos=pers.i%3
 if pers.bad==2 then
  glitch_clipped(0x6404+20*pos,
   16,48)
 elseif pers.bad==4 and pers.pret then
  local frm=iseq-pers.pret
  if frm>=28 and frm<=32 then
   glitch_clipped(0x6404+20*pos,
    16,48)
  end
 end
 -- pan !
 if pers.state==1 then
  --copy back
  if pers.frm==1 then
   block_memcpy(
    0x0c10+16*pos,
    0x6404+20*pos,
    16,47)
  end
  circfill(16,24,pers.frm*2.5,7)
  circfill(16,24,(pers.frm-15)*2.5,1)
  set_pal_mask(pers)
  spr(100+4*pos,0,0,4,6)
  pal()
  --copy sprite on blue
  if pers.frm>=22 then
   for i=0,128 do
    local x,y=i%16,flr(i/16)
    if pget(x+8,y+40)==1 then
     pset(x+8,y+40,sget(x,y+72))
    end
   end
  end
  if pers.bad>=1 then
   --
   text_ombre("oops !",4,2,7)
  end
 end
 fillp(0b0101101001011010.1)
 for p in all(pers.part) do
  local offset=flr(p.i*7/20)
  local c=peek_spr(0x0c0,offset/2)
  circfill(p.x,p.y,p.s,c)
 end
 fillp()

 pal()
 camera()
 clip()
end

function text_ombre(txt,x,y,c)
 print(txt,x+1,y+1,0)
 print(txt,x,  y+1,0)
 print(txt,x+1,y,0)
 print(txt,x,  y,7)
end

function set_pal_mask(pers)
 --custom cheveux
 for i=2,15 do
  palt(i,true)
 end
 palt(0,true)
end

function set_pal_perso(pers)
 --custom cheveux
 pal(4, haircolm[pers.hair])
 pal(2, haircols[pers.hair])
 --peau
 pal(6, skincolm[pers.skin])
 --habits
 pal(3, clotcolm[pers.clot])
 pal(10,clotcols[pers.clot])
 pal(7 ,clotcolm[pers.trou])
 --bottes
 pal(13,bootcolm[pers.boot])
 palt(1,true)
 palt(0,false)
end

function dessine_sprite(pers)
 --position perso
 local i=(pers.i%3)*4
 spr(4+i,8,sin(t*15),2,2)
 spr(36+i,0,8+cos(t*15),4,4)
 spr(6+i,8,32,2,2)
 --bad people ?
 if pers.bad==0 then
  spr(64,16,19+cos(t*15),2,2)
 elseif pers.bad==1 
   or pers.bad==4 then
  if pers.g==1 then
   --$$ man
   spr(66,16,16+cos(t*15),2,2)
  else
   --$$ woman
   spr(98,16,16+cos(t*15),2,2)
  end
 end
end

-- list des persos
function generer_bad_left()
 for i=0,min(day,4) do
  add(bad_left,0)
  add(bad_left,1)
 end
 if day>1 then
  add(bad_left,2)
 end
 if day>2 then 
  add(bad_left,2)
  add(bad_left,3)
 end
 if day>3 then 
  add(bad_left,3)
  add(bad_left,4)
 end
 if day>4 then 
  add(bad_left,4)
 end
end

-- hasard controle
function pick_bad()
 if #bad_left==0 then 
  generer_bad_left()
 end
 local badidx=1+flr(rnd(#bad_left))
 local res=bad_left[badidx]
 del(bad_left,res)
 return res
end

function init_perso(pers)
 --particules
 pers.part={}
 pers.frm=0
 pers.pret=nil
 --0 alive, 1 dead
 pers.state=0
 --0 bad, 1 good, 2 glitchy
 --3 neutral
 --4 fourbe
 pers.bad=pick_bad(day)--flr(rnd(5))
--pers.bad=4--cheat
 pers.hair=flr(rnd(#haircols))+1

 repeat 
  pers.skin=flr(rnd(#skincolm))+1
  yield()
 until haircolm[pers.hair]
     ~=skincolm[pers.skin]
 
 pers.clot=flr(rnd(#clotcolm))+1

 repeat
  pers.boot=flr(rnd(#bootcolm))+1
  yield()
 until bootcolm[pers.boot]
     ~=skincolm[pers.skin]
   and bootcolm[pers.boot]
     ~=clotcolm[pers.clot]

 repeat
  pers.trou=flr(rnd(#clotcolm))+1
  yield()
 until clotcolm[pers.trou]
     ~=clotcolm[pers.clot]
   and clotcolm[pers.trou]
     ~=skincolm[pers.skin]
   and clotcolm[pers.trou]
     ~=bootcolm[pers.boot]

 local g=flr(rnd(2))
 pers.g=g
 --
 local dec=32*(pers.i%3)
 for x=0,1536 do
  sset(32+x%32+dec,flr(x/32),1)
 end
 yield()
 -- head/hair
 load_gfx(g*8+flr(rnd()*8),32+dec,0)
 yield()
 
 -- torso
 load_gfx(g*4+24+flr(rnd()*4),32+dec,16)
 yield()
 
 -- legs
 load_gfx(g*4+32+flr(rnd()*4),48+dec,0)
 yield()
 
 -- accessory
 load_gfx(16+flr(rnd()*8),0,96)
 yield()
 copytransp(32+dec,0,16,16)
end

function copytransp(tx,ty,sx,sy)
 for x=0,(sx*sy)-1 do
  local col=sget(x%sx,x/sy+96)
  if col~=1 then
   sset(x%sx+tx,x/sy+ty,col)
  end
 end
end

-- generer une sequence
-- d'ouverture de porte
function generer_seq(lvl)
 -- one step, 1 sec
 local nbstep,lseq,last=
  flr(rnd(6)+4),{},true,0
 -- 0 nothing
 -- 1 left
 -- 2 center
 -- 3 right
 repeat
  val=flr(rnd(3))
  if val==last then
   val=(val+1+flr(rnd(2)))%3
  end
  add(lseq,val)
  last=val
  -- pause en fonction lvl
  -- moins de pause avec le lvl
  if (rnd(100)>(25+lvl*5)) add(lseq,-1)
  add(lseq,-1)
 until #lseq>=nbstep
 add(lseq,-1)
 add(lseq,-1)
 return lseq
end

-->8
-- 2. load the compressed data
-- (from the cart it was
-- compressed to)

base_offset=0x2000

-- skip through compressed data
-- blocks and load the one at
-- index
function load_gfx(index,x,y)

 local offset=base_offset
 for i=0,index-1 do
  offset+=peek(offset+0)+peek(offset+1)*256+2
 end

 -- use pget,pset to write on screen
 -- use sget,sset to write back
 -- to the spritesheet instead
 -- of the screen 
 decomp(offset+2,x,y,sget,sset)
-- decomp(offset+2,x,y,readpixel,sset)
-- decomp(offset+2,x,y,_memget,_memset)
end

function remap(i,w,h)
 local sx=flr((i/64)%(w/8))
 local sy=flr((i/64)/(w/8))
 local x=(i%8)
 local y=flr(flr(i%64)/8)
 return (sx*8+x)+(sy*8+y)*w
end

function decomp(src, px,py,
 xget,xset)

 local pn={}
 src-=1 
 local bit=256
 local b=0
 
 function getval(bits)
  val=0
  for i=0,bits-1 do

   --get next bit from stream
   if (bit==256) then
    bit=1
    src+=1
    byte=peek(src)
   end
   if band(byte,bit)>0 then
    val+=shl(1,i)
   end
   bit*=2
   
  end
  return val
 end
 
 -- read header
 local w = getval(8)
 local h = getval(8)
 local cbits = getval(3)
 local rmp = getval(1) 
 local maxci = getval(8)
 local bpp = getval(3)+1
 local clist={}
 for i=0,maxci do
  clist[i]=getval(bpp)
 end
 
 -- spans
 local i = 0
 local span = 0
 
 while (i < w*h) do

  -- span length 
  local bl = 1
  while getval(1)==0 do
   bl += 1 end
  
  local minv=shl(1,bl-1)
  if (bl==1) minv=0
  
  local len=
   getval(max(1,bl-1))+minv+1

  for j=0,len-1 do
  
   local i1 = i
   
   if (rmp==1) i1=remap(i,w,h)
   
   x = px+(i1)%w
   y = py+flr(i1/w)
   
   -- predict colour
   local t=xget(x+0,y-1)/16
   local l=xget(x-1,y+0)*16
   if (y==py) t=0
   if (x==px) l=0
   
   pc=pn[t+l] or pn[t] or pn[l]
   
   if (span%2 == 0) then
    -- raw literal
    local index=0
    
    repeat
     v=getval(cbits)
     index += v
    until (v < shl(1,cbits)-1)
    
    local pindex=999
    for i=0,maxci do
     if (pc==clist[i]) pindex=i
    end
    
    if (pindex <= index) index+=1
    
    col = clist[index]
    
    -- move to front
    for i=index,1,-1 do
     clist[i]=clist[i-1]
    end
    clist[0] = col
    
   else
    -- predicted
    col = pc
    
   end

   xset(x,y,col)
      
   -- adjust predictions
   pn[t]=col
   pn[l]=col
   pn[t+l]=col
   i += 1
  end
  span += 1
  -- allow loading over
  -- multiple frames
  if (span%64==0) yield()
 end
end
-->8
-- decomp function
function readpixel(x,y)
 local byte=peek(x/2+y*64)
 return band(0xf,x%2==0 and byte or byte/16)
end

function _memget(x,y)
-- local addr = 0x4300 + flr(y)*64 + x/2
 local addr = flr(y)*64 + x/2
 local pbyte = peek(addr)
 local left = pbyte % 16
 if x%2 == 0 then
   return left
 else
   return (pbyte - left) / 16
 end
end

function _memset(x,y,col)
-- local addr = 0x4300 + flr(y)*64 + x/2
 local addr = flr(y)*64 + x/2
 local left = peek(addr) % 16
 local right = (peek(addr) - left) / 16
 local val
 if x%2 == 0 then
   val = col+16*right
 else
   val = left+16*col
 end
 poke(addr,val)
end
-->8
-- based on p01
-- https://www.lexaloffle.com/bbs/?tid=31478

function otri(x0,y0,x1,y1,x2,y2,colr,flp)
 color(colr)
 if (flp~=nil) fillp(flp)
 local y0,y1,y2=
  band(y0,0xffff),
  band(y1,0xffff),
  band(y2,0xffff)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 local col=x0+(x2-x0)/(y2-y0)*(y1-y0)
 p01_trapeze_h(x0,x0,x1,col,y0,y1)
 p01_trapeze_h(x1,col,x2,x2,y1,y2)
 fillp()
end

function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0 
 y1=min(y1,127)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end
-->8
--w nb byte, h nb line
function block_memcpy(dst,src,w,h)
 for i=0,h do
  memcpy(dst+64*i,src+64*i,w)
 end
end

function glitch_block()
 local source=0x0000
  +flr(rnd(0x7e00))
 local range=flr(rnd(64))
 local dest=0x6000
  +rnd(rnd(0x1e00))
 for i=1,8 do
  memcpy(dest+i*64,source+i*64,range)
 end
end

--w nb byte, h nb line
function glitch_clipped(offset,w,h)
 for i=0,h do
  memcpy(0x4300+w*i,offset+64*i,w)
 end

 local size,chunck=w*h,8*w
 local source=0x4300
  +flr(rnd(size-chunck))
 local range=flr(rnd(w))
 local dest=0x4300
  +flr(rnd(size-chunck))
 for i=0,6 do
  memcpy(dest+i*w,source+i*w,range)
 end
 
 for i=0,h do
  memcpy(offset+64*i,0x4300+w*i,w)
 end
end

-- sprite gradient
function spr_grd(nbs,x,y,w,h,
  col_addr,offset,acol,mod,tcol)
 local sprx,spry,scol=
  nbs%16 *8,flr(nbs/16)*8,0
 for j=0,h do
  for i=0,w do
   scol=sget(sprx+i,spry+j)
   if scol==acol then
    pset(x+i,y+j,
     peek_spr(col_addr,offset)
    )
   elseif scol!=tcol then
    pset(x+i,y+j,scol)
   end
  end
  offset=(offset+1)%mod
 end
end

function peek_spr(addr,offset)
 return shr(
  peek(addr+offset/2),
  offset%2*4)
end

function sspr_blk(sx,sy,w,h,x,y)
 if flr(rnd(10))%10>0 then
  palt(0,false)
  sspr(sx,sy,w,h,x,y)
 else 
  pal(1,0)
  pal(2,0)
  pal(14,0)
  palt(0,false)
  sspr(sx,sy,w,h,x,y)
 end
 pal()
 palt(0,true)
end
-->8
function pad6(nb)
 return sub("000000"..nb,-6)
end

function update_intro()
 -- part
 local pat=flr(rnd(2))==0 and
  0b1110010110110101.1 or
  0b0101101001011010.1
 local part={
  x=0,y=104+rnd(8),
  vx=1+rnd(0.75),vy=0.1+rnd(0.1),
  s=2+rnd(6),
  i=flr(rnd(2)),e=112,
  c=6,pat=pat}
 add(glpart,part)
   
 if (ach>2) addspark(32+rnd(18),66)
 if (ach>4) addspark(96+rnd(18),66)
 if (ach>6) addspark(104+rnd(24),36)
 if (ach>8) addspark(4+rnd(24),56)
    
end

function addspark(x,y)
 if rnd(200)<1 then
  local part={
   x=x,y=y,
   vx=0.5-rnd(1),vy=0,
    ay=0.75,s=1+rnd(1),
   i=flr(rnd(2)),e=8,
   c=10}
  add(glpart,part)
 end
end

function dessine_intro()
 cls()
 dessine_city()
 -- title
 spr_grd(197,44,8,71,15,
  0x0404,-iseq,11,24,14)

 -- message
 spr(130,64,120,2,1)
 print("start —Ž    @yourykiki",
  21,121,1)
end

function dessine_city()
 local y,bgcol=-8,{0,1,2,14,10,15,12}
 local patl,patr,col1,col2,col3,col4=
  0b0100000000010000,
  0b0011000011000000,
  0xcd,0xc0,0xf0,0xfd
 -- sky
 for col in all(bgcol) do
  rectfill(0,y-2,127,y-2,col)
  rectfill(0,y,127,y+15,col)
  y+=16
 end
 -- bat 1
 draw_batr(0,8,31,15,111,col4,patr)
 -- bat 2
 if ach>9 then
  draw_beam(64,0,64,64,300)
 end
 draw_batl(32,24,48,16,111,col2,patl)
 draw_batr(48,16,55,20,111,col2,patr)
 -- bat 3
 draw_batr(56,64,80,68,111,col1,patr)
 -- bat 4
 draw_batl(96,32,104,28,111,col3,patl)
 draw_batr(104,28,127,32,111,col3,patr)
 -- bat 5
 if ach>9 then
  draw_beam(80,0,96,56,333)
 end
 draw_batl(88,52,96,48,111,col1,patl)
 draw_batr(96,48,112,52,111,col1,patr)
 -- pubs
 if (ach>2) sspr_blk(0,96,18,32,32,64)--3
 if (ach>4) sspr_blk(24,96,16,21,98,64)--5
 if (ach>6) sspr_blk(40,112,24,16,104,33)--7
 if (ach>8) sspr_blk(64,112,24,16,4,48)--9
 
 -- particules
 dessine_part(glpart)

 -- fg
 otri(0,111,127,95,127,103,5)
 otri(0,111,127,103,0,119,5)
 otri(0,119,127,103,127,119,6)
 rectfill(0,120,127,127,6)
end

function draw_beam(sx,sy,ex,ey,d)
 local cx=sx+24*cos(iseq/d)
 color(3)
 p01_trapeze_h(cx-3,cx+3,
  ex-2,ex+1,sy,ey)
 color(11)
 p01_trapeze_h(cx-1,cx+1,
  ex-1,ex,sy,ey)
end

function draw_batl(x1,y1,x2,y2,yb,col,pat)
 otri(x1,y1,x2,y2,x2,y1,col,pat)
 fillp(pat)
 rectfill(x1,y1,x2,yb,col)
 fillp()
 line(x1,y1,x2,y2,col)
 line(x1,y1,x1,yb,col)
 line(x2,y2,x2,yb,col)
end

function draw_batr(x1,y1,x2,y2,yb,col,pat)
 otri(x1,y1,x2,y2,x1,y2,col,pat)
 fillp(pat)
 rectfill(x1,y2,x2,yb,col)
 fillp()
 line(x1,y1,x2,y2,col)
 line(x1,y1,x1,yb,col)
 line(x2,y2,x2,yb,col)
end
__gfx__
11122888888888211000000000000000111111111111111111111111111111111111110001111111111110dddddd011111111111111110001111111111111111
11133bb331113b31100000000400055011111111111111111111111111111111111110ccc0111111111110ddd5dd011111111111111102320111111111111111
11dcd111ddcccdd110000000004010001111111111111111111111111111111111110ccccc0111111111110dd5dd011111111111111022232011111111111111
7a982555a965100000000000099917701111111111111111111111111111111111110cccccc011111111110ddddd011111111111111022223201111111111111
111228888888221110000000002010001111111111111111111111111111111111110ccc66cc01111111110dd5dd011111111111111033331320111111111111
11133bbbbbbb331110000000020863001111111111111111111111111111111111110ccc666c01111111110ddddd011111111111111022266620111111111111
111ddcccccccdd111000000000806030111111111111111111111111111111111110ccc6a6ac01111111110ddd5d011111111111110222616120111111111111
8888888889a7a9885555555500000000111111111111111111111111111111111110ccc6666c0111111110dd5ddd011111111111110222666620111111111111
11000011111111111111111111111111111111111111111111111111111111111110ccc6666c0111111110ddddddd01111111111110222666620111111111111
dd1001ddddddddddddddddd565dddddd111111111111111111111111111111111110ccc5666cc01111110dddddddd01111111111110222566622011111111111
dd1001ddddddddddddd9dd565ddddddd111111111111111111111111111111111110ccc1551cc01111110ddddd5dd01111111111110222155122011111111111
ddd11ddddddddddddddd5dd565ddd9dd111111111111111111111111111111111110cc11661cc0111110ddd5dddddd0111111111110221166122011111111111
dddddddddddddddddd5555565ddd5ddd111111111111111111111111111111111110d6666666d0111110ddddddddddd011111111110333333333011111111111
ddddddddddddddddd9ddddd56555dddd11111111111111111111111111111111110ddd66666ddd01110d5ddddddd5dd011111111103333333333301111111111
dddddddddddddddddddddd565ddddddd1111111111111111111111111111111110ddddd6666ddd0110dddd5dd5ddddd011111111033333333333301111111111
dddddddd5555555555555556655555551111111111111111111111111111111110dddddd66dddd010dd5ddddddddddd011111111033333333333301111111111
ddd9dddd99999999999999aaaa771100111111111111111111111111111111111111111111111111111111111111111111111110333533333335301111111111
dd5dd555000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111103335005335335301111111111
55dd5ddd000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111103350110553553301111111111
ddd9ddd5000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111033501110333333011111111111
dddddd5d000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111033011110333333011111111111
5559dd5d000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111103301110333303011111111111
dddddd5d000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111105330110333303301111111111
59dd9555000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111110533003333303301111111111
dddddddd00000000000000000000000011111111111111111111111111111111111111110ddd0ddddddddd011111111111111111056663533330330111111111
55dd9ddd0000000000000000000000001111111111111111111111111111111111111110ddd50ddddddd5d011111111111111111106633353330330111111111
dd5dd5550000000000000000000000001111111111111111111111111111111111111110dd50105dd5dd5d011111111111111111110033333530360111111111
ddd9dddd000000000000000000000000111111111111111111111111111111111111110dd50111055555d0111111111111111111111033335333665011111111
59ddd9dd000000000000000000000000111111111111111111111111111111111111110dd011110dddddd0111111111111111111111063335333065011111111
dddd5ddd0000000000000000000000001111111111111111111111111111111111111110dd01110dddd5d0111111111111111111111106335336055601111111
5555dd9500000000000000000000000011111111111111111111111111111111111111105dd0110dddd5dd011111111111111111111106635366000060111111
dddddddd000000000000000000000000111111111111111111111111111111111111111105dd00ddddd5dd011111111111111111111106665666011106011111
111111111111111111111111111111111111111111111111111111111111111111111111105666d5dddd5dd01111111111111111111106660666011110601111
11111111111111111111111111111111111111111111111111111111111111111111111111066ddd5ddd5dd01111111111111111111106660666011111060111
11111300011111111111033011111111111111111111111111111111111111111111111111100ddddd5d5d601111111111111111111110660660111111106011
11111305011111111111033011111111111111111111111111111111111111111111111111110dddd5ddd6650111111111111111111110660660111111110601
11111355501111111111033011111111111111111111111111111111111111111111111111110dddd5ddd0650111111111111111111110660660111111111001
111103505011111111110330111181111111111111111111111111111111111111111111111110ddd5ddd0556011111111111111111110660660111111111111
111103555011111111110333018888111111111111111111111111111111111111111111111110ddd5ddd0006601111111111111111110660660111111111111
111103656011111111110333018118111111111111111111111111111111111111111111111110ddd5dd01110660111111111111111110650560111111111111
111100356011111111111033018888111111111111111111111111111111111111111111111110dddddd01111066001111111111111110660660111111111111
111111066011111111111033018181111111111111111111111111111111111111111111111110ddd5dd01111106660111111111111110660660111111111111
1111111001111111111110330181111111111111111111111111111111111111111111111111110dd5dd01111106666011111111111110660660111111111111
1111111111111111111110366001111111111111111111111111111111111111111111111111110ddddd01111110666011111111111110660660111111111111
1111111111111111111110668800111111111111111111111111111111111111111111111111110dd5dd01111111000111111111111110660660111111111111
1111111111111111111111068888011111111111111111111111111111111111111111111111110ddddd01111111111111111111111106660666011111111111
1111111111111111111111100088011111111111111111111111111111111111111111111111110ddd5d01111111111111111111111106660666011111111155
111111111111111111111111110011111111111111111111111111111111111111111111111110dd5ddd01111111111151111111111110001000111111111555
99999999aa7711991111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000001111111111111111111111111111111111111111111111111111111111111100001111111111111111111111111111000011111111110111
000000000000000011111111111181111111111111111111111111111111111111111111111110eeee0111111111111111111111111110eeee0111111110b011
00000000000000001110330111888811111111111111111111111111111111111111111111110eeeeee01111111111111111111111110eeeeee011111110b011
0000000000000000111033011181181111111111111111111111111111111111111111111110eee66eee011111111111111111111110eee66eee01111110b011
0000000000000000111033301188881111111111111111111111111111111111111111111110ee6666eee01110001111111111111110ee6666eee0111000b011
00000000000000001111033011818111111111111111111111111111111111111111111111105ec66ce5011106650111111111111110eec66cee01110665b001
00000000000000001111103301811111111111111111111111111111111111111111111111105e6666e5011106550111111111111110ee6666ee01110655b0b0
00000000000000001111103660111111111111111111111111111111111111111111111111105e6666e50111105501111111111111102e6666e201111055b0b0
00000000000000001111106688001111111111111111111111111111111111111111111111110ee66ee01111105550111111111111110ee66ee01111105550b0
000000000000000011111106888801111111111111111111111111111111111111111111111110e55e0111111105501111111111111102e55e20111111055b01
00000000000000001111111000880111111111111111111111111111111111111111111111110026620011111105501111111111111100066000111111055b01
00000000000000001111111111001111111111111111111151111111111111151111111111103b6666b300000004501111111111111036666663000000045011
00000000000000001111111111111111511111111111111111111111111111111111111111033b6666b330555544401111111111110336666663305555444011
1111111111111111666666cc6c666666111111111111111111111111111111111111111110333b6666b330555554011111111111103333666633305555540111
1111511111111111cc666cccc666666600000000000000000000000000000000111111110333bbb66bbb30555000111111111111033333333333305550001111
11555511111111116cc66ccccc66666600000000000000000000000000000000111111103335bbbbbbbb30d00111111111111110333553333335300001111111
1151151111111111cccccccc66666666000000000000000000000000000000001111111033500bb33bb330501111111111111110335005533553301111111111
11555511111111116ccccccc66666666000000000000000000000000000000001111110335010333333335550111111111111103350103333333301111111111
115151111111111166ccccc666666666000000000000000000000000000000001111110330110333333035050111111111111103301103333330301111111111
1151111111111111cccccc6666666666000000000000000000000000000000001111111033010333333035550111111111111110330103333330301111111111
11111111111111116666666666666666000000000000000000000000000000001111111053300333333036560111111111111110533003333330301111111111
11111111111111110a8a000000000000000000000000000000000000000000001111111105666353333303560111111111111111056663533330330111111111
11111111111111110989800000000000000000000000000000000000000000001111111110063335333330660111111111111111106633353330330111111111
11111111111111110888800000000000000000000000000000000000000000001111111111103333353330001111111111111111110033333530360111111111
11111166666111110888000000000000000000000000000000000000000000001111111111103333533330111111111111111111111033335333665011111111
11116656566661110888880000000000000000000000000000000000000000001111111111106333533360111111111111111111111063335333065011111111
11166666656566110848880000000000000000000000000000000000000000001111111111110633533601111111111111111111111106335336055601111111
11656565666665610444440000000000000000000000000000000000000000001111111111110663536601111111111111111111111106635366000060111111
16665666565666660000000000000000000000000000000000000000000000001111111111110666566601111111111111111111111106665666011106011111
1111111111111111111111111111111111111111111105c010cc0111111111111111111111110666066601111111111111111111111106660666011110601111
1111111111111111111111111111111511111111111105c010cc0111111111111111111111110666066601111111111111111111111106660666011111060111
111111111111111111111111111111111111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111106011
111111111111110000111111111111151111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111110601
111111111111104444011111111111111111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111001
111111111111044444401111111111151111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
1111111111110400ff440111111111111111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
1111111111110405fcf4011111111115111111111111055010550111111111111111111111111065056011111111111111111111111110650560111111111111
111111111111044ffff44011111111111111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
111111111110844ffff48011111111151111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
111111111108a844ff48a011111111111111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
11111111110a0a84554a0801111111151111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
11111111110a0a84ca1a0a01111111111111111111110ff010ff0111111111111111111111111066066011111111111111111111111110660660111111111111
11111111110000a0000a0001111111151111111111110ff010ff0111111111151111111111110666066601111111111111111111111106660666011111111111
11111111110000a0000a000011111111111111111110fff010fff011111111111111111111110666066601111111111111111111111106660666011111111115
1111111111000a077700a0001111111551515151510fff01110fff01515151511111111111111000100011111111111151111111111110001000111111111155
0000000000000000000000000000000000000000e000000000000000e00000ee00000000000000eee00000ee0000000e00000000000000000000000000000000
0000000000000000000000000000000000000000e0bbbbb00bb00bb0e0bbb0ee0bbbbbb00bbbb0eee0bbb0ee0bbbbb0e0bb00bb00bb00bb00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bbb0eee0bb00bb00bb00bb00bb0eeee0bb00bb00bb00bb00bb00bb00bbb0bb00bb0bb0e0000000000000000
000000000000000000000000000000000000000000000eee0000000000000000000000ee000000000000000000000000000000000000000e0000000000000000
00000000000000000000000000000000000000000bb0eeeee0bbbb0e0bbbbb0e0bbbb0ee0bbbb0ee0bbbbb0e0bbbbbb00bbbbbb00bbbb0ee0000000000000000
00000000000000000000000000000000000000000000eeeee000000e00000000000000ee0000000e0000000000000000000000000000000e0000000000000000
00000000000000000000000000000000000000000bb0eeeeee0bb0ee0bb00bb00bb0eeee0bb0bb0e0bb00bb00bb00bb00bb0bbb00bb0bb0e0000000000000000
000000000000000000000000000000000000000000000eeeee0000ee000000000000eeee00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bbb0eeeee0bb0ee0bb00bb00bb0eeee0bb00bb00bb00bb00bb00bb00bb00bb00bb00bb00000000000000000
000000000000000000000000000000000000000000000000ee0000ee000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000e0bbbbb0ee0bb0eee0bbbb0e0bbbbbb00bb00bb0e0bbbb0e0bb00bb00bb00bb00bb00bb00000000000000000
0000000000000000000000000000000000000000e0000000ee0000eee000000e0000000000000000e000000e0000000000000000000000000000000000000000
0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
0000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3e00101069b00032960ae4345a9daf4fd7dac4363368ad90d6e5a6d24b4d979adbdfa95d76ef1de9bafc561fd1774743abbfaf4edd17fbcb9adc5763ef233f583d00101069b00032960ae4345a9daf4f57ad276f5683d60a695d3c6e2abd6a2c7f53bbecde1df94668f17d4eef6868f5f7d5a953b1903ea62fbd4f0a7fb00032
00101059b00032ae404ea3d5f94a9bdfeadcd4a0a590d6e5e752abe8c6d3975bc7c587f7d88b86f6ea6a6e8786857c68d81d163300101059b00032ae404ea3d5f9fa5c37df7a83a6f1f42a57a56b6f462e84d771ebb8f8f01e7bd1d05e5dcdedd0b0900f0dbbc3023c00101069b00032960ae4345a9daf4fd7dac4363368ad90
d6e5a6d24b4d578de56f6a97ebd29d7d7a894f55ab4743d3df57a74e4543233d5f7d6e85040b3600101059b00032ae404aa3d5f9fa5c3437a9e946431fa6150f8f5a4f8d35963bbb39371a9abfa7fae6ba68fabd3a752decc7bfb0edc2013c00101069b0004ae30aa4345a9d593bb336a4a85c35742b744877a9dd68d817378f
5b458ad97bebd4129feebb737751a2afa3a161de57ffb9589f7b371c3000101059b00032ae404ea3d559b59e1b8d022d85b42ed62ad66878faceade3e2c37bec4543bbba9adba161211f1a7687052f00101059b00032ae80248d56e7eb73d52ae85548eb7253b92a9ebe73ab4855a4b878eca2a1bdf4deb182e4972387050b2d
00101059b00032ae404ea3d5f9fa5c54b61ab456e8f0b0622f6e8e5b458a0fefb1170d25d7351a1a16f2a16177583200101059b00032aec0cdf3fa7cb1aa91528396e3f6a576b1a22f9ebedc3a2e2a2fa6895d34b45757733b34eccb8eb356e4c1023200101059b00032aec0126cc517b93ab366f35b0b7de8b04284b42e563c
7d73ebb8f8f01e7bd1d0aeaee6766858c88786dd61013100101059b00032aec0166c45a4ddac4de7fa05ed30ad88b78d55c58aa76f6e1d171fde632f1adad5d5dc0e0d0bf9d0b03b2c3100101059b00032ae404ea3d5f9fa5c37970a5a0a695d6e2a57455ae1e9cbade3e2c37bec45437b7535b743c3423e34ec0e0b2a001010
49b000e30a48d26875be3e97023d850e0f2b9ededc3a2e3ebc632f1adad5d5dc0e0d0bf9d0b03b2c3a00101059b00032ae404ea3d5f9fa5c3572bb41ab425a979b8a9cca2fdefae656f9aed6e73772e5bd908e86a6dfd553d7225349a9d2af8a84f6b00007001010098001f4031700101039b080da8072552595160de882a9df
d42a660678021e00101049b080ca0d18ad58e502a3954a17c9cdee0e6975a0d2c4c28a1648002000101039b080da80727dba6a351a303de4a948d1ade58b16385acdadb156ac40021600101029a0a001b5006e8158f1c58a072caa48a10b1c001a00101049b080ca0f98a5dd68c0a81621da51f7f10754adefd4811615001010
39b028d8c016605c1fd8a12924942c9b0358002000101039b080dac01648d1b0345d2a1af4a1411f9a2e92dfec810454d58d3570026d00202059b08051ab00d53c33ed5cbe73371af8edb177375615a0a0686aed7ea7766baa9ba63afa1c651326c9c77029359542845ed771000779fa79a9d2db2a794adf7ea3611eb9f5d805
2170a5eaadf65b4d2e26d3f1e53ab802e6a141142b1a1a1a9aa3d0b065251a1a1a1ae0009800202059b050289b0047c1a4e4ca3babf5dd8d066215a7a64a779772a253ae6777d653ab15c77514afb2e45ce5054f2061f6e28b86268277f5eef24824f16e17f56a25b6983c5ba7e7464f55d37125139bd96e2a2254aae3b87975
bd5880ab76f2d5e549cd433a1a9684baaa90146a4108ac547daa2595945ca753ee5cb8b002beabe81c4792aa3c56c58a86e628342c8da7baba58d1d000079400202059b0801ad300cf905491d689b5697534f03b92d96ec9a46a3460176cc5a548a98ed457ed97a630a5e384e9b9e69dd26fad1a236c2527ad25541b9c524b4f
4f75ebad564bbb6a5a7593a6a91e1519d22a56b45c4c6fddd2aca62a4024effa7aa9d26d959c52b7142b1a1a6a2004ae54f936bfd5acc9eaa8ab6870c50a28e7e61bba68686868264a4a97eb8d150d0d0d0d70007300202059b000b5a900d53c4b6b4bbba74603bf3d445b4c2be02590302bbe6868227088a857496c1775b592
172c6e6aa4f78d15e9caec92148508bdaee3000e6c4f5e5d3ea9dd7548d120c26e4c415c10022b556fb5bd9935591de93645c135601e1a44b1a2a1a1a1390a0d5b56a2a1a1a1010e007d00202069b0009db20b701494aad32db26c6a170d4485b78f48b3a9b9808ec2565c3cf0563a4c2457adb32c37b5baaebe7e17bde77117
949ea9f1522da9545779a9548a3af00508150f0d8b73d427d2442f767d4920a1e1e9b79eded6ac2742ea53abc12d601be738c739ce718e5347eaec34e538c739ce716aa48e7380027500202069b0001dab0b70b47275aa6e11bbbbba65a381e7bbf8b96e7dfa76230508289af5a636a970487db478a45581b1930be738c77929
347a4017a093e31c56ea9bad332ed6d54855a4140b246a5f2ad5cd89a4a425515ea72830034c532bda2e45a1718e739ce31ca9526868de94e31ce7380728007b00202069b0009d3a0b50b522d6acd56a2a1a10bc757a2bbdf1000216b968965ce7968bab3a8a723930ace450756da93ace52974ad103ba401648686868f0d9c4
a9bbbad5f23b77ebfbd6d9d53d96a228c7e291aaeaa914e5ceb59576ba4a758e022d40758f15b5c3539ce31ce738e7ae38c7ab38c739ce718e7380027000202059a060ee0354f3bcd22c6d7ea381df347a7add4801fb4a64299a25d7718e73344773d468b1b2c139ce718e43a3077481424ca4860d78b299eaaabbe5ce73755d
2a1a1a9a3709a42a526aca3dd7aeb4d355aa73146801aa39ce718e739ce31ce738c7718e739ce31ce738c73940012d00101039b000ebc05d1da9465a458aa60d1a69644de4455c58c054215548d1d0b0f573d179151a1a1a1abe58390c3400101039b080aec0cda34558d3e84548d368d04d910be669df5aac55fc31db342ed6
68d8fa5cc73939459e6ad288bc68f8d25550002400101039b080ae803a0a0de8e2b0456fec6217b97eaee3d09c4ea5ad8d15d1e06b51f1d0102400101039b000eb807b5534a023457cb1a21b3be44ae6d0d0682b34a4152298413b858586012800101029b0800e28d358aa02639a5375880be738c739ced19a8864a1b592739c
e31ce738ae43f2f5062b00101039b080ae80390e0df8e2d13ada2a3fc716ce91a9d86c64a1f5a92456691dad36e5585a6fa7f6a5fa062a00101029b0800e18f3c8a202639e727574159f424e718e733433912db4aee23a2690d2718eb3e878bede002e00101039b080ea802ba5bc3e5f2df046c3aa58d2f92ace718e6626b285
565bb199da6423e5564d1a2979743c5f6f005000182069306009d7170efe3aa51488852aa594828ea28212d5cd75410f693434704b0d6a204651a08586174d9deb82de03435307e228e8c068d0fb686035d03454af141290a4145e9ae3c2341a5a0e3a68460010184930e958108aa2402e121a3535d6b9de29170ddd91aa68a7
b47391544a29246aa594a2a0434af597aacdf5ad566e57756397eb725d781d150daaa0152b1aba5497eb810638001810493081de174a29205045aa28e89452204529bdb90a2d28ad945268159a42aa94aaaa40d9105d41156934202844554a212129055a9000340018104930e9f815482057290a8952948a065d343434e8aa45
205ae8564810294aa19d4a410742a4810c68435343b48a041d6490000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000020370153700f3700937007170051700417003170021700117001170011700117001160011400111001400014000000000000000000000000000000000000000000000000000000000000000000000000
0012000400775007750c7750077500775007750c7750077500705007050c7050070500705007050c7050070500000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f6701a67016660146601265011650106500f6400e6400d6400c6300b6300a6300a6200a6200a61009600096000960008600086000860007600076000760007600076000760006600056000560005600
000100100c7600c7600c7600c7600c7600c7600c7500c7400c7500c7600c7600c7600c7600c7600c7600c76000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001835018355183041832500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000000000000017805168051480512805118050f8050d8050c8030a803088030680304803028030180301803018030180301803010030100301103011030120301203013030130301403014000000000000
0112002000255003550c4550025500355004550c2550035500455002550c3550045500255003550c4550025500355004550c2550035500455002550c3550045500255003550c4550025500355004550c25500355
0112002000255003550c4550025500355004550c2550035500455002550c3550045500255003550c4540025207355074551325507355074550725513355074550525505355114550525505355054551125405352
011200000000000000000000000000000000000000000000000000000000000000003ca003ca003c6000c6000c8700c8143c6000c8700c814000000c8500c814000050c8700c8140c8003ca203ca123c6230c612
011200100c8700c8143c6003c6003ca203ca1200000000000c8500c81400005000053c6230c61200000000000c8000c80000000000000000000000000002e6000000000000000000000000000000000000000000
0112002018b7018b7218b7218b7218b6218b6218b4218b4218b3218b3218b4218b4218b6218b6218b7218b7518b7218b7218b7218b7218b6218b6218b4218b4218b3218b3218b4218b4218b6218b6218b7218b75
0112002018b7018b7218b7218b7218b6218b6218b4218b4218b3218b3218b4218b4218b6218b6218b7218b751fb721fb721fb621fb421fb321fb421fb621fb721db721db721db621db421db321db421db621db75
011200200c8500c8550c8000c8533ca303ca12000000c8500c8150c8000c8730c815306333061500000000000c8700c875000000c8700c875000000c8700c87500000000000c8700c87530633306153063330615
011200100c8500c8550c8000c8533ca303ca12000000c8500c8150c8000c8730c815306333061500000000000c8000c805000000c8000c805000000c8000c80500000000000c8000c80530603306050000000000
011200201f2551835513455002551f3551845513255003551f2551835513455002551f355184551325500352234551c2551735504455232551c3551745504255213551a4551525502355214551a2551535502452
011200202b2551835513455002552b3551845513255003552b2551835513455002552b3551845513255003522f4551c25517355044552f2551c35517455042552d3551a45515255023552d4551a2551535502452
011200200025013350184501f2500035013450182501f3500045013250183501f4500025013350184501f25004350174501c2502335004450172501c3502345002250153501a4502125002350154501a25021350
011200200c8700c8143c6003c6003ca203ca1200000000000c8500c81400005000053c6230c61200000000000c8700c814182553c6003ca203ca1218255000000c8500c81400005244553c6230c6122445524405
011200200025013350184502b2500735018450132500c3500045013250183502b4500725018350134500c25004350174501c2502f3500b4501c250173501045002250153501a4502d250093501a450152500e350
011200200025413350184502b2500735018450132500c3550045413250183502b4500725018350134500c25504354174501c2502f3500b4501c250173501045502254153501a4502d250093501a450152500e355
01120020182501a3521c4521f2541c000184421c2321f3121f4521c2521f35218454230001f3421c43218212183521f452212522335421000232422333223412233522344223232233121f4021f2021f3021f402
01120020232502335223452232522300023442232322331221452212522135221452210002134221432212121f3521f4521f2521f3521f0001f2421f3321f4121f3521f44218232183121f4021f2021f3021f402
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003b000370003b66337663336632e66328663226631e6631b66318663136630f6630c653086530564303633016130a60309603076030560304603036030160301603000000000000000000000000000000
010e00002b4052b450244552f45524b0024b0024b0024b0024b0024b002bb012bb012db012db012fb012fb0100000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200201fc500cc5013c5000c501fc500cc5013c5000c5023c5010c5017c5004c5023c5010c5017c5004c5021c500ec5015c5002c5021c500ec5015c5002c501fc500cc5013c5000c501fc500cc5013c5000c50
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
000400000c5500c500185500c50024550045000c500105000c500105000c500105000c500105000c500105000c500105000c500105000c500105000c5000c5000c5000c5000c5000c5000c5000c5000c5000c500
010400200c5500c5000c5500c5000c550105000c550105000c550105000c550105000c550105000c550105000c550105000c550105000c550105000c5500c5000c5500c5000c5500c5000c5500c5000c5500c500
010800002465000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f6400a6200860037000260052d0000f00526000180050f000140051800011005140000f605113000e1050f6000f6052810021200183030f603126030560301603006030000300003000030000300003
0103000037160000032d26537140263652d2400f65526330181550f630142451812011335142200f615113100e1050f6100f6052810021200183030f603126030560301603006030000300003000030000300003
011000000a6100c6200d6200d6300d6300c6200962007610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000036600326503264506600176000a6000760006600016000360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000295532d543303231d51300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 08 0c 43 44
00 09 0d 43 0a
01 08 0c 43 0b
00 09 0d 13 44
00 41 0d 10 0b
00 41 0d 10 0e
00 41 0d 11 0b
00 41 0d 11 0e
00 41 0d 12 0f
00 41 0d 14 0e
00 41 0d 14 0f
00 41 0d 15 0e
00 41 42 16 0b
02 41 42 17 0e
00 41 42 43 44
00 41 42 16 44
04 41 42 17 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 41 0d 14 0f
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
