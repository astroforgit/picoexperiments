pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--motorbike
--by savary benjamin

function _init()
 music(0)
end

scor=0
col=8
deadtim=0
benscor=9126
mus_sys={0}
function _update()
 if btnp(Ž) and mus_sys[1]==1 then
  mus_sys[1]=0
  music(1)
 elseif btnp(Ž) and mus_sys[1]==0 then
  mus_sys[1]=1
  music(-1)
 end
 if player[5]==0 then
  scor+=cgr[3] end
 car_generator()
 car_empty()
 if player[5]==0 then
 show_player()
 else end
 player_detect()
 col+=1
 if col==16 then col=8 end
end


function _draw()
 cls(9)
 road_system()
 player_front_back()
 score_dificult()
 dead()
 if star_setup>=9 then
 star_game() end
 if star_setup>=1 then
 starsetup() end
 if player[5]==0 then
  print("score :",1,1,7)
  print(scor,32,1,7)
  if scor>=9000 then
   print("ultimium speed",38,7,col)
  elseif scor>=3600 then
   print("mega speed",47,7,12)
  elseif scor>=900 then
   print("hight speed",44,7,10)
  else print("normal speed",42,7,7)
  end
  if scor==9000 or scor==3600 or scor==900 then
   sfx(3)
  end
  dead_tim_system()
  if mus_sys[1]==0 then
   print("Ž = music on",76,1,7)
  elseif mus_sys[1]==1 then
   print("Ž = music off",72,1,7)
  end
 end
end

--reste

function player_front_back()
 draw_player()
 car_draw()
 if f[1]==1 or f[2]==1 or f[3]==1 or f[4]==1 or f[5]==1 or f[6]==1 or f[7]==1 or f[8]==1 or f[9]==1 or f[10]==1 then
 player[4]=1
 draw_player()
 else player[4]=0 end
end

function dead_tim_system()
 if deadtim>=1 then
  deadtim-=1 end
 if deadtim==29 then
  map(0,32,0,0,16,16) sfx(1) end  
 if deadtim==28 then
  map(16,32,0,0,16,16) end
 if deadtim==27 then
  map(32,32,0,0,16,16) end
 if deadtim==26 then
  map(48,32,0,0,16,16) end
 if deadtim==25 then
  map(64,32,0,0,16,16) end
 if deadtim==24 then
  map(80,32,0,0,16,16) end
 if deadtim==23 then
  map(96,32,0,0,16,16) end
 if deadtim==22then
  map(112,32,0,0,16,16) end
 if deadtim>=8 then
  if deadtim<=21 then
   rectfill(0,0,128,128,7)
   dea[2]=0
   player[1]=32
   player[2]=88
   scor=0
   reboot_all_car()
   
  end
 end
 if deadtim==8 then
  map(112,32,0,0,16,16) sfx(2) end
 if deadtim==7 then
  map(96,32,0,0,16,16) end
 if deadtim==6 then
  map(80,32,0,0,16,16) end
 if deadtim==5 then
  map(64,32,0,0,16,16) end
 if deadtim==4 then
  map(48,32,0,0,16,16) end
 if deadtim==3 then
  map(32,32,0,0,16,16) end
 if deadtim==2 then
  map(16,32,0,0,16,16) end
 if deadtim==1 then
  map(0,32,0,0,16,16)
  player[5]=0
  cgr[1]=300
  cgr[2]=1
 end
end

function reboot_all_car()
 cc1[1]=-32
 cc2[1]=-32
 cf1[1]=-32
 cf2[1]=-32
 cs1[1]=-32
 cs2[1]=-32
 cn1[1]=-32
 cn2[1]=-32
 cv1[1]=-32
 cv2[1]=-32
 cc1[5]=1.5
 cc2[5]=1.5
 cf1[5]=1.5
 cf2[5]=1.5
 cs1[5]=1.5
 cs2[5]=1.5
 cn1[5]=1.5
 cn2[5]=1.5
 cv1[5]=1.5
 cv2[5]=1.5
end

function dead()
 if fx[2]>=1 then
  dea[1]=1
  player[1]-=4
   line(0,40,128,40,0)
   rectfill(0,42,128,43,0)
   rectfill(0,45,128,48,0)
  rectfill(0,50,128,78,0)
   rectfill(0,80,128,83,0)
   rectfill(0,85,128,86,0)
   line(0,88,128,88,0)
  print("game over",64-17,64-11,7)
  print("press — to restart",64-38,64-5,7)
 if scor>=benscor then
  print("ben score :",64-26,71,7)
  print("new best score :",64-46,65,col)
  print(benscor,64+21,71,7)
  print(scor,64+21,65,col)
 elseif scor<benscor then
  print("best score :",64-30,65,7)
  print("your score :",64-30,71,7)
  print(benscor,64+21,65,7)
  print(scor,64+21,71,7)
 end
  if (btnp(—)) and deadtim==0 then --extcmd("reset")
   reboot_all_car()
   player[1]=-500
   fx[1]=1
   fx[2]=0
   player[5]=0
   deadtim=30
   dea[1]=0
  end
 end
end

function score_dificult()
 if scor>=9000 then
   cgr[2]=3 --9000
  cc1[5]=4.5
  cf1[5]=4.5
  cn1[5]=4.5
  cs1[5]=4.5
  cv1[5]=4.5
  cc2[5]=4.5
  cf2[5]=4.5
  cn2[5]=4.5
  cs2[5]=4.5
  cv2[5]=4.5
 elseif scor>=3600 then
   cgr[2]=2 --3600
  cc1[5]=3.25
  cf1[5]=3.25
  cn1[5]=3.25
  cs1[5]=3.25
  cv1[5]=3.25
  cc2[5]=3.25
  cf2[5]=3.25
  cn2[5]=3.25
  cs2[5]=3.25
  cv2[5]=3.25
 elseif scor>=900 then
   cgr[2]=1.25 --900
  cc1[5]=2
  cf1[5]=2
  cn1[5]=2
  cs1[5]=2
  cv1[5]=2
  cc2[5]=2
  cf2[5]=2
  cn2[5]=2
  cs2[5]=2
  cv2[5]=2
 end
end

function player_detect()
 if f1[1]==1 and f2[1]==1 then
  f[1]=1 else f[1]=0 end
 if f1[2]==1 and f2[2]==1 then
  f[2]=1 else f[2]=0 end
 if f1[3]==1 and f2[3]==1 then
  f[3]=1 else f[3]=0 end
 if f1[4]==1 and f2[4]==1 then
  f[4]=1 else f[4]=0 end
 if f1[5]==1 and f2[5]==1 then
  f[5]=1 else f[5]=0 end
 if f1[6]==1 and f2[6]==1 then
  f[6]=1 else f[6]=0 end
 if f1[7]==1 and f2[7]==1 then
  f[7]=1 else f[7]=0 end
 if f1[8]==1 and f2[8]==1 then
  f[8]=1 else f[8]=0 end
 if f1[9]==1 and f2[9]==1 then
  f[9]=1 else f[9]=0 end
 if f1[10]==1 and f2[10]==1 then
  f[10]=1 else f[10]=0 end
end

function print_rnd_line()
 print(f[1],20,0,11)
 print(f[2],20,6)
 print(f[3],20,12)
 print(f[4],20,18)
 print(f[5],20,24)
 print(f[6],25,0)
 print(f[7],25,6)
 print(f[8],25,12)
 print(f[9],25,18)
 print(f[10],25,24) 

 print(cc1[4],0,0,7)
 print(cs1[4],0,6)
 print(cc1[4],0,12)
 print(cf1[4],0,18)
 print(cv1[4],0,24)
 print(cc2[4],5,0)
 print(cs2[4],5,6)
 print(cc2[4],5,12)
 print(cf2[4],5,18)
 print(cv2[4],5,24)

 print(cc1[6],10,0,10)
 print(cs1[6],10,6)
 print(cc1[6],10,12)
 print(cf1[6],10,18)
 print(cv1[6],10,24)
 print(cc2[6],15,0)
 print(cs2[6],15,6)
 print(cc2[6],15,12)
 print(cf2[6],15,18)
 print(cv2[6],15,24)
 
 print(cc1[7],30,0,12)
 print(cs1[7],30,6)
 print(cc1[7],30,12)
 print(cf1[7],30,18)
 print(cv1[7],30,24)
 print(cc2[7],35,0)
 print(cs2[7],35,6)
 print(cc2[7],35,12)
 print(cf2[7],35,18)
 print(cv2[7],35,24)
end
-->8
--world system

--road system-----------------

function road_system()
 rd[1]-=rdx
 rd[5]-=rdx
 rd[6]-=4
 rectfill(0,0*8,128,3*8,8)
 map(0,0,0,0,16,8)
 pal(8,2)
 map(0,0,0,-4*8,16,8)
 pal(8,8)
 circfill(14*8,6*8,18,7)
 rectfill(0,7*8,128,12*8,1)
 batiment_print()
 poto_draw()
 rectfill(0,14*8,128,16*8,0)
 rectfill(0,9*8,128,15*8,5)
 rectfill(0,123,128,16*8,1)
 system_1_animation()
 if rd[1]==-64 then
  rd[1]=64
  rd[5]=96
 end
 line_system()
end

 rdx=4
 rd={64,1.8,3.25,5,32,0,}
 route={0,0,0,0,0,}
 bati={0,0,}
 
function line_system()
 --x1 y1 x2 y1 c1
 line(rd[1]*rd[2]+64,9.8*8,rd[5]*rd[2]+64,9.8*8,6)
 line(rd[1]*rd[3]+64,11.25*8,rd[5]*rd[3]+64,11.25*8,6)
 line(rd[1]*rd[4]+64,13*8,rd[5]*rd[4]+64,13*8,6)
 --vitesse
 map(16,8,route[1],8*8,16,2)
 map(0,10,route[2],10*8,16,1)
 map(0,11,route[3],11*8,16,2)
 map(16,13,route[4],13*8,16,1)
 map(16,14,route[5],14*8,16,3)
 --2
 map(16,8,route[1]+128,8*8,16,2)
 map(0,10,route[2]+128,10*8,16,1)
 map(0,11,route[3]+128,11*8,16,2)
 map(16,13,route[4]+128,13*8,16,1)
 map(16,14,route[5]+128,14*8,16,3)
end

function system_1_animation()
 batiment_gestion()
 --route
 route[1]-=5.5
 route[2]-=8.5
 route[3]-=10.75
 route[4]-=12
 route[5]-=15
 if route[1]<=-128 then
  route[1]=0
 end
 if route[2]<=-127.5 then
  route[2]=0
 end
 if route[3]<=-128 then
  route[3]=0
 end
 if route[4]<=-128 then
  route[4]=0
 end
 if route[5]<=-128 then
  route[5]=0
 end
end

--batiment--------------------

function batiment_print()
 --loin
 pal(11,0)
 map(112,0,bati[2],2,16,16)
 map(112,0,bati[2]+128,2,16,16)
 --proche
 map(96,0,bati[1],-2,16,16)
 map(96,0,bati[1]+128,-2,16,16)
 pal(11,11)
end

function batiment_gestion()
 bati[1]-=2
 bati[2]-=1
 if bati[1]==-128 then
  bati[1]=0
 end
 if bati[2]==-128 then
  bati[2]=0
 end
end

--poto

poto={4.5*8,10*8,128,128/30,192,(128+32)/(28/3*2),3*8}

function poto_draw()
 poto[3]-=poto[4]
 poto[5]-=poto[6]
 if poto[3]<0 then
 poto[3]=128
 poto[5]=192
 end
 line(poto[3],poto[1],poto[3],poto[2],1)
 line(poto[3]+1,poto[1],poto[3]+1,poto[2],5)
 line(poto[3]-1,poto[1],poto[3]-1,poto[2],1)
 line(poto[3]+2,poto[1],poto[3]+2,poto[2],5)
 line(poto[3],poto[1],poto[5],poto[7],1)
 line(poto[3]+1,poto[1],poto[5]+1,poto[7],5)
 line(poto[3]-1,poto[1],poto[5]-1,poto[7],1)
 line(poto[3]+2,poto[1],poto[5]+2,poto[7],5)

 --lumiere
 map(16,0,poto[5]-8*8,poto[7]-3.25*8,16,7)
 rectfill(poto[5],22,poto[5]+7,29,7)
end
 

-->8
--player

player={32,88,1,0,1}
--larg,haut,l,r,up,down
latence={0,0,0,0,0,0}
f1={0,0,0,0,0,0,0,0,0,0}
f2={0,0,0,0,0,0,0,0,0,0}
f={0,0,0,0,0,0,0,0,0,0}
l=5
hit=0,12
dea={0,0}

function hit_box_front()
 rect(player[1]-6,player[2]+6,player[1]+6,player[2]+8,7)
end

function show_player()
 if btn(‹) then
  latence[1]-=1
  latence[3]=1
 else
  latence[3]=0
 end
 if btn(‘) then
  latence[1]+=1
  latence[4]=1
 else
  latence[4]=0
 end
 if btn(”) then
  latence[2]-=1
  latence[5]=1
 else
  latence[5]=0
 end
 if btn(ƒ) then
  latence[2]+=1
  latence[6]=1
 else
  latence[6]=0
 end
 latence_impact()
 latence_player()
 if player[1]<8 then player[1]=8 end
 if player[1]>120 then player[1]=120 end
 if player[2]<65 then player[2]=65 end
 if player[2]>113 then player[2]=113 end
end

function draw_player()
 if dea[1]==0 then
  spr(2,player[1]-2,player[2]-8)
  palt(0,false)
  palt(14,true)
  if player[3]<=2 then
  spr(3,player[1]-8,player[2])
  spr(4,player[1],player[2])
  elseif player[3]>=3 then
  spr(5,player[1]-8,player[2])
  spr(6,player[1],player[2])
  end
  player[3]+=1
  if player[3]>=6 then player[3]=0 end
  palt(0,true)
  palt(14,false)
 elseif dea[1]==1 or dea[2]==1 then
  palt(0,false)
  palt(14,true)
  spr(76,player[1]-4,player[2]-4)
  spr(77,player[1]+4,player[2]-4)
  spr(92,player[1]-4,player[2]+4)
  spr(93,player[1]+4,player[2]+4)
  palt(0,true)
  palt(14,false)
 end
end

function latence_player()
 --latence imput
 if latence[1]>l then latence[1]=l end
 if latence[1]<-l then latence[1]=-l end
 if latence[2]>l then latence[2]=l end
 if latence[2]<-l then latence[2]=-l end
 
 --latence detect
 
 if latence[1]==0 then
 else
  if latence[1]>=1 and latence[4]==0 then
   latence[1]-=1
  elseif latence[1]<=-1 and latence[3]==0 then
   latence[1]+=1
  end
 end
 if latence[2]==0 then
 else
  if latence[2]>=1 and latence[6]==0 then
   latence[2]-=1
  elseif latence[2]<=-1 and latence[5]==0 then
   latence[2]+=1
  end
 end
 --latence corect
end

function latence_impact()
 player[1]+=(latence[1]/3)
 player[2]+=(latence[2]/3)
end
--devant_derrier--

-->8
--voiture

x1=1 -- 2x2 car
y1=8
w1=14
h1=15
x2=1 -- 3x2 car
y2=8
w2=22
h2=15
x3=1 -- 4x2 car
y3=8
w3=30
h3=15

--car-x,y,on,lign,mulx,ady,skin
cc1={-32,63,1,0,1.5,0,0} --short
cf1={-32,74,1,0,1.5,0,0} --familial
cn1={-32,88,1,0,1.5,0,0} --normal
cs1={-32,105,1,0,1.5,0,0} --sport
cv1={-32,62,1,0,1.5,0,0} --van
cc2={-32,63,1,0,1.5,0,0} --short
cf2={-32,74,1,0,1.5,0,0} --familial
cn2={-32,88,1,0,1.5,0,0} --normal
cs2={-32,105,1,0,1.5,0,0} --short
cv2={-32,62,1,0,1.5,0,0} --van
crnd={rnd(4),0}
--timer,negatime,ontime,onrebot
cgr={300,0,1,1}

function car_generator()
 if cgr[3]==1 then
  cgr[1]-=cgr[2]
 elseif cgr[3]==2 then end
 if cgr[1]==270 then cc1[1]=130
  cc1[4]=flr(rnd(4))
  cc1[7]=flr(rnd(4))
  if cc1[4]==0 then cc1[6]=flr(rnd(2))
  elseif cc1[4]==1 then cc1[6]=flr(rnd(6))
  elseif cc1[4]==2 then cc1[6]=flr(rnd(8))
  elseif cc1[4]==3 then cc1[6]=flr(rnd(12)) end end
 if cgr[1]==240 then cf1[1]=130 
  cf1[4]=flr(rnd(4))
  cf1[7]=flr(rnd(4))
  if cf1[4]==0 then cf1[6]=flr(rnd(2))
  elseif cf1[4]==1 then cf1[6]=flr(rnd(6))
  elseif cf1[4]==2 then cf1[6]=flr(rnd(8))
  elseif cf1[4]==3 then cf1[6]=flr(rnd(12)) end end
 if cgr[1]==210 then cn1[1]=130 
  cn1[4]=flr(rnd(4))
  cn1[7]=flr(rnd(4))
  if cn1[4]==0 then cn1[6]=flr(rnd(2))
  elseif cn1[4]==1 then cn1[6]=flr(rnd(6))
  elseif cn1[4]==2 then cn1[6]=flr(rnd(8))
  elseif cn1[4]==3 then cn1[6]=flr(rnd(12)) end end
 if cgr[1]==180 then cs1[1]=130 
  cs1[4]=flr(rnd(4))
  cs1[7]=flr(rnd(4))
  if cs1[4]==0 then cs1[6]=flr(rnd(2))
  elseif cs1[4]==1 then cs1[6]=flr(rnd(6))
  elseif cs1[4]==2 then cs1[6]=flr(rnd(8))
  elseif cs1[4]==3 then cs1[6]=flr(rnd(12)) end end
 if cgr[1]==150 then cv1[1]=130 
  cv1[4]=flr(rnd(4))
  cv1[7]=flr(rnd(4))
  if cv1[4]==0 then cv1[6]=flr(rnd(2))
  elseif cv1[4]==1 then cv1[6]=flr(rnd(6))
  elseif cv1[4]==2 then cv1[6]=flr(rnd(8))
  elseif cv1[4]==3 then cv1[6]=flr(rnd(12)) end end
 if cgr[1]==120 then cf2[1]=130 
  cf2[4]=flr(rnd(4))
  cf2[7]=flr(rnd(4))
  if cf2[4]==0 then cf2[6]=flr(rnd(2))
  elseif cf1[4]==1 then cf2[6]=flr(rnd(6))
  elseif cf2[4]==2 then cf2[6]=flr(rnd(8))
  elseif cf2[4]==3 then cf2[6]=flr(rnd(12)) end end
 if cgr[1]==90 then cc2[1]=130 
  cc2[4]=flr(rnd(4))
  cc2[7]=flr(rnd(4))
  if cc2[4]==0 then cc2[6]=flr(rnd(2))
  elseif cc2[4]==1 then cc2[6]=flr(rnd(6))
  elseif cc2[4]==2 then cc2[6]=flr(rnd(8))
  elseif cc2[4]==3 then cc2[6]=flr(rnd(12)) end end
 if cgr[1]==60 then cn2[1]=130 
  cn2[4]=flr(rnd(4))
  cn2[7]=flr(rnd(4))
  if cn2[4]==0 then cn2[6]=flr(rnd(2))
  elseif cn2[4]==1 then cn2[6]=flr(rnd(6))
  elseif cn2[4]==2 then cn2[6]=flr(rnd(8))
  elseif cn2[4]==3 then cn2[6]=flr(rnd(12)) end end
 if cgr[1]==30 then cv2[1]=130 
  cv2[4]=flr(rnd(4))
  cv2[7]=flr(rnd(4))
  if cv2[4]==0 then cv2[6]=flr(rnd(2))
  elseif cv2[4]==1 then cv2[6]=flr(rnd(6))
  elseif cv2[4]==2 then cv2[6]=flr(rnd(8))
  elseif cv2[4]==3 then cv2[6]=flr(rnd(12)) end end
 if cgr[1]==0 then cs2[1]=130 
  cs2[4]=flr(rnd(4))
  cs2[7]=flr(rnd(4))
  if cs2[4]==0 then cs2[6]=flr(rnd(2))
  elseif cs2[4]==1 then cs2[6]=flr(rnd(6))
  elseif cs2[4]==2 then cs2[6]=flr(rnd(8))
  elseif cs2[4]==3 then cs2[6]=flr(rnd(12)) end end
 if cgr[4]==1 and cgr[1]<=0 then
  cgr[1]=300 end
end

function car_empty()
 cc1[1]-=cc1[5]
 if cc1[4]==0 then cc1[2]=63-cc1[6] end 
 if cc1[4]==1 then cc1[2]=74-cc1[6] end
 if cc1[4]==2 then cc1[2]=88-cc1[6] end
 if cc1[4]==3 then cc1[2]=105-cc1[6] end
 cc2[1]-=cc2[5]
 if cc2[4]==0 then cc2[2]=63-cc2[6] end 
 if cc2[4]==1 then cc2[2]=74-cc2[6] end
 if cc2[4]==2 then cc2[2]=88-cc2[6] end
 if cc2[4]==3 then cc2[2]=105-cc2[6] end
 cf1[1]-=cf1[5]
 if cf1[4]==0 then cf1[2]=63-cf1[6] end 
 if cf1[4]==1 then cf1[2]=74-cf1[6] end
 if cf1[4]==2 then cf1[2]=88-cf1[6] end
 if cf1[4]==3 then cf1[2]=105-cf1[6] end
 cf2[1]-=cf2[5]
 if cf2[4]==0 then cf2[2]=63-cf2[6] end 
 if cf2[4]==1 then cf2[2]=74-cf2[6] end
 if cf2[4]==2 then cf2[2]=88-cf2[6] end
 if cf2[4]==3 then cf2[2]=105-cf2[6] end
 cn1[1]-=cn1[5]
 if cn1[4]==0 then cn1[2]=63-cn1[6] end 
 if cn1[4]==1 then cn1[2]=74-cn1[6] end
 if cn1[4]==2 then cn1[2]=88-cn1[6] end
 if cn1[4]==3 then cn1[2]=105-cn1[6] end
 cn2[1]-=cn2[5]
 if cn2[4]==0 then cn2[2]=63-cn2[6] end 
 if cn2[4]==1 then cn2[2]=74-cn2[6] end
 if cn2[4]==2 then cn2[2]=88-cn2[6] end
 if cn2[4]==3 then cn2[2]=105-cn2[6] end
 cs1[1]-=cs1[5]
 if cs1[4]==0 then cs1[2]=63-cs1[6] end 
 if cs1[4]==1 then cs1[2]=74-cs1[6] end
 if cs1[4]==2 then cs1[2]=88-cs1[6] end
 if cs1[4]==3 then cs1[2]=105-cs1[6] end
 cs2[1]-=cs2[5]
 if cs2[4]==0 then cs2[2]=63-cs2[6] end 
 if cs2[4]==1 then cs2[2]=74-cs2[6] end
 if cs2[4]==2 then cs2[2]=88-cs2[6] end
 if cs2[4]==3 then cs2[2]=105-cs2[6] end
 cv1[1]-=cv1[5]
 if cv1[4]==0 then cv1[2]=63-cv1[6] end 
 if cv1[4]==1 then cv1[2]=74-cv1[6] end
 if cv1[4]==2 then cv1[2]=88-cv1[6] end
 if cv1[4]==3 then cv1[2]=105-cv1[6] end
 cv2[1]-=cv2[5]
 if cv2[4]==0 then cv2[2]=63-cv2[6] end 
 if cv2[4]==1 then cv2[2]=74-cv2[6] end
 if cv2[4]==2 then cv2[2]=88-cv2[6] end
 if cv2[4]==3 then cv2[2]=105-cv2[6] end
end

function reset_color_car()
 pal(1,1) pal(12,12)
 pal(1,1) pal(12,12)
 pal(1,1) pal(12,12)
end

function car_draw()
 palt(0,false)
 palt(15,true)
 if cc1[7]==0 then end 
 if cc1[7]==1 then pal(1,4) pal(12,9) end
 if cc1[7]==2 then pal(1,3) pal(12,11) end
 if cc1[7]==3 then pal(1,2) pal(12,14) end
  draw_short_car_1()
 reset_color_car()
 if cf1[7]==0 then end 
 if cf1[7]==1 then pal(1,4) pal(12,9) end
 if cf1[7]==2 then pal(1,3) pal(12,11) end
 if cf1[7]==3 then pal(1,2) pal(12,14) end
  draw_familial_car_1()
 reset_color_car()
 if cn1[7]==0 then end 
 if cn1[7]==1 then pal(1,4) pal(12,9) end
 if cn1[7]==2 then pal(1,3) pal(12,11) end
 if cn1[7]==3 then pal(1,2) pal(12,14) end
  draw_normal_car_1()
 reset_color_car()
 if cs1[7]==0 then end 
 if cs1[7]==1 then pal(1,4) pal(12,9) end
 if cs1[7]==2 then pal(1,3) pal(12,11) end
 if cs1[7]==3 then pal(1,2) pal(12,14) end
  draw_sport_car_1()
 reset_color_car()
 if cv1[7]==0 then end 
 if cv1[7]==1 then pal(1,4) pal(12,9) end
 if cv1[7]==2 then pal(1,3) pal(12,11) end
 if cv1[7]==3 then pal(1,2) pal(12,14) end
  draw_van_1()
 reset_color_car()
 if cc2[7]==0 then end 
 if cc2[7]==1 then pal(1,4) pal(12,9) end
 if cc2[7]==2 then pal(1,3) pal(12,11) end
 if cc2[7]==3 then pal(1,2) pal(12,14) end
  draw_short_car_2()
 reset_color_car()
 if cf2[7]==0 then end 
 if cf2[7]==1 then pal(1,4) pal(12,9) end
 if cf2[7]==2 then pal(1,3) pal(12,11) end
 if cf2[7]==3 then pal(1,2) pal(12,14) end
  draw_familial_car_2()
 reset_color_car()
 if cn2[7]==0 then end 
 if cn2[7]==1 then pal(1,4) pal(12,9) end
 if cn2[7]==2 then pal(1,3) pal(12,11) end
 if cn2[7]==3 then pal(1,2) pal(12,14) end
  draw_normal_car_2()
 reset_color_car()
 if cs2[7]==0 then end 
 if cs2[7]==1 then pal(1,4) pal(12,9) end
 if cs2[7]==2 then pal(1,3) pal(12,11) end
 if cs2[7]==3 then pal(1,2) pal(12,14) end
  draw_sport_car_2()
 reset_color_car()
 if cv2[7]==0 then end 
 if cv2[7]==1 then pal(1,4) pal(12,9) end
 if cv2[7]==2 then pal(1,3) pal(12,11) end
 if cv2[7]==3 then pal(1,2) pal(12,14) end
  draw_van_2()
 reset_color_car()
 palt(15,false)
 palt(0,true)
end

fx={1,0}
function contact_dead()
 if fx[1]==1 then sfx(0) dea[2]=1 end
 fx[1]-=1
 fx[2]+=1
 cgr[2]=0
 player[5]-=1
 
end

--car_model-------------

function draw_short_car_1()
 spr(42,cc1[1],cc1[2])
 spr(43,cc1[1]+8,cc1[2])
 spr(58,cc1[1],cc1[2]+8)
 spr(59,cc1[1]+8,cc1[2]+8)
 if player[1]-7<=cc1[1]+w1 and player[2]+5<=cc1[2]+h1 then
  if player[1]+6>=cc1[1]+x1 and player[2]+8>=cc1[2]+y1 then
   contact_dead()
  end
 end
 if player[1]-7<=cc1[1]+w1+1 and player[2]+5<=cc1[2]+h1+45 then
  f1[1]=1 else f1[1]=0 end
 if player[1]+6>=cc1[1]+x1-2 and player[2]+8>=cc1[2]+y1+8 then
  f2[1]=1 else f2[1]=0 end
end

function draw_familial_car_1()
 spr(32,cf1[1],cf1[2])
 spr(33,cf1[1]+8,cf1[2])
 spr(34,cf1[1]+16,cf1[2])
 spr(48,cf1[1],cf1[2]+8)
 spr(49,cf1[1]+8,cf1[2]+8)
 spr(50,cf1[1]+16,cf1[2]+8)
 if player[1]-7<=cf1[1]+w2 and player[2]+5<=cf1[2]+h2 then
  if player[1]+6>=cf1[1]+x2 and player[2]+8>=cf1[2]+y2 then
   contact_dead()
  end
 end
 if player[1]-7<=cf1[1]+w2+1 and player[2]+5<=cf1[2]+h2+45 then
  f1[2]=1 else f1[2]=0 end
 if player[1]+6>=cf1[1]+x2-2 and player[2]+8>=cf1[2]+y2+8 then
  f2[2]=1 else f2[2]=0 end
end

function draw_normal_car_1()
 spr(13,cn1[1],cn1[2])
 spr(14,cn1[1]+8,cn1[2])
 spr(15,cn1[1]+16,cn1[2])
 spr(39,cn1[1],cn1[2]+8)
 spr(40,cn1[1]+8,cn1[2]+8)
 spr(41,cn1[1]+16,cn1[2]+8)
 if player[1]-7<=cn1[1]+w2 and player[2]+5<=cn1[2]+h2 then
  if player[1]+6>=cn1[1]+x2 and player[2]+8>=cn1[2]+y2 then
   contact_dead()
  end
 end
 if player[1]-7<=cn1[1]+w2+1 and player[2]+5<=cn1[2]+h2+45 then
  f1[3]=1 else f1[3]=0 end
 if player[1]+6>=cn1[1]+x2-2 and player[2]+8>=cn1[2]+y2+8 then
  f2[3]=1 else f2[3]=0 end
end

function draw_sport_car_1()
 spr(7,cs1[1]+3,cs1[2])
 spr(8,cs1[1]+11,cs1[2])
 spr(10,cs1[1],cs1[2]+8)
 spr(11,cs1[1]+8,cs1[2]+8)
 spr(12,cs1[1]+16,cs1[2]+8)
 if player[1]-7<=cs1[1]+w2 and player[2]+5<=cs1[2]+h2 then
  if player[1]+6>=cs1[1]+x2 and player[2]+8>=cs1[2]+y2+2 then
   contact_dead()
  end
 end
 if player[1]-7<=cs1[1]+w2+1 and player[2]+5<=cs1[2]+h2+45 then
  f1[4]=1 else f1[4]=0 end
 if player[1]+6>=cs1[1]+x2-2 and player[2]+8>=cs1[2]+y2+8 then
  f2[4]=1 else f2[4]=0 end
end

function draw_van_1()
 spr(35,cv1[1],cv1[2])
 spr(36,cv1[1]+8,cv1[2])
 spr(37,cv1[1]+16,cv1[2])
 spr(38,cv1[1]+24,cv1[2]) 
 spr(51,cv1[1],cv1[2]+8)
 spr(52,cv1[1]+8,cv1[2]+8)
 spr(53,cv1[1]+16,cv1[2]+8)
 spr(54,cv1[1]+24,cv1[2]+8)
 if player[1]-7<=cv1[1]+w3 and player[2]+5<=cv1[2]+h3 then
  if player[1]+6>=cv1[1]+x3 and player[2]+8>=cv1[2]+y3 then
   contact_dead()
  end
 end
 if player[1]-7<=cv1[1]+w3+1 and player[2]+5<=cv1[2]+h3+45 then
  f1[5]=1 else f1[5]=0 end
 if player[1]+6>=cv1[1]+x3-2 and player[2]+8>=cv1[2]+y3+8 then
  f2[5]=1 else f2[5]=0 end
end

--car2

function draw_short_car_2()
 spr(42,cc2[1],cc2[2])
 spr(43,cc2[1]+8,cc2[2])
 spr(58,cc2[1],cc2[2]+8)
 spr(59,cc2[1]+8,cc2[2]+8)
 if player[1]-7<=cc2[1]+w1 and player[2]+5<=cc2[2]+h1 then
  if player[1]+6>=cc2[1]+x1 and player[2]+8>=cc2[2]+y1 then
   contact_dead()
  end
 end
 if player[1]-7<=cc2[1]+w1+1 and player[2]+5<=cc2[2]+h1+45 then
  f1[6]=1 else f1[6]=0 end
 if player[1]+6>=cc2[1]+x1-2 and player[2]+8>=cc2[2]+y1+8 then
  f2[6]=1 else f2[6]=0 end
end

function draw_familial_car_2()
 spr(32,cf2[1],cf2[2])
 spr(33,cf2[1]+8,cf2[2])
 spr(34,cf2[1]+16,cf2[2])
 spr(48,cf2[1],cf2[2]+8)
 spr(49,cf2[1]+8,cf2[2]+8)
 spr(50,cf2[1]+16,cf2[2]+8)
 if player[1]-7<=cf2[1]+w2 and player[2]+5<=cf2[2]+h2 then
  if player[1]+6>=cf2[1]+x2 and player[2]+8>=cf2[2]+y2 then
   contact_dead()
  end
 end
 if player[1]-7<=cf2[1]+w2+1 and player[2]+5<=cf2[2]+h2+45 then
  f1[7]=1 else f1[7]=0 end
 if player[1]+6>=cf2[1]+x2-2 and player[2]+8>=cf2[2]+y2+8 then
  f2[7]=1 else f2[7]=0 end
end

function draw_normal_car_2()
 spr(13,cn2[1],cn2[2])
 spr(14,cn2[1]+8,cn2[2])
 spr(15,cn2[1]+16,cn2[2])
 spr(39,cn2[1],cn2[2]+8)
 spr(40,cn2[1]+8,cn2[2]+8)
 spr(41,cn2[1]+16,cn2[2]+8)
 if player[1]-7<=cn2[1]+w2 and player[2]+5<=cn2[2]+h2 then
  if player[1]+6>=cn2[1]+x2 and player[2]+8>=cn2[2]+y2 then
   contact_dead()
  end
 end
 if player[1]-7<=cn2[1]+w2+1 and player[2]+5<=cn2[2]+h2+45 then
  f1[8]=1 else f1[8]=0 end
 if player[1]+6>=cn2[1]+x2-2 and player[2]+8>=cn2[2]+y2+8 then
  f2[8]=1 else f2[8]=0 end

end

function draw_sport_car_2()
 spr(7,cs2[1]+3,cs2[2])
 spr(8,cs2[1]+11,cs2[2])
 spr(10,cs2[1],cs2[2]+8)
 spr(11,cs2[1]+8,cs2[2]+8)
 spr(12,cs2[1]+16,cs2[2]+8)
 if player[1]-7<=cs2[1]+w2 and player[2]+5<=cs2[2]+h2 then
  if player[1]+6>=cs2[1]+x2 and player[2]+8>=cs2[2]+y2+2 then
   contact_dead()
  end
 end
 if player[1]-7<=cs2[1]+w2+1 and player[2]+5<=cs2[2]+h2+45 then
  f1[9]=1 else f1[9]=0 end
 if player[1]+6>=cs2[1]+x2-2 and player[2]+8>=cs2[2]+y2+8 then
  f2[9]=1 else f2[9]=0 end
end

function draw_van_2()
 spr(35,cv2[1],cv2[2])
 spr(36,cv2[1]+8,cv2[2])
 spr(37,cv2[1]+16,cv2[2])
 spr(38,cv2[1]+24,cv2[2]) 
 spr(51,cv2[1],cv2[2]+8)
 spr(52,cv2[1]+8,cv2[2]+8)
 spr(53,cv2[1]+16,cv2[2]+8)
 spr(54,cv2[1]+24,cv2[2]+8)
 if player[1]-7<=cv2[1]+w3 and player[2]+5<=cv2[2]+h3 then
  if player[1]+6>=cv2[1]+x3 and player[2]+8>=cv2[2]+y3 then
   contact_dead()
  end
 end
 if player[1]-7<=cv2[1]+w3+1 and player[2]+5<=cv2[2]+h3+45 then
  f1[10]=1 else f1[10]=0 end
 if player[1]+6>=cv2[1]+x3-2 and player[2]+8>=cv2[2]+y3+8 then
  f2[10]=1 else f2[10]=0 end
end
-->8
--game system
mapx=0
mapy=0
map_y=0.5
star_setup=30
star_setup_tim=1
function star_game()
 mapx-=1
 mapy-=0.5
 map_y+=0.5
  map(0,16,mapx,mapy,16,16)
 map(0,16,mapx+128,mapy,16,16)
 map(0,16,mapx,mapy+128,16,16)
 map(0,16,mapx+128,mapy+128,16,16)
  map(32,16,mapx,map_y,16,16)
 map(32,16,mapx+128,map_y,16,16)
 map(32,16,mapx,map_y-128,16,16)
 map(32,16,mapx+128,map_y-128,16,16)
  line(0,29,128,29,0)
  rectfill(0,31,128,33,0)
  rectfill(0,35,128,38,0)
 rectfill(0,40,128,88,0)
  rectfill(0,90,128,93,0)
  rectfill(0,95,128,96,0)
  line(0,98,128,98,0)
 map(16,16,0,40,16,16)
 print("by savary benjamin",29,74,7)
 print("presse — to start",29,81,7)
 if mapx==-64 then mapx=0 end
 if mapy==-64 then mapy=0 end
 if map_y==64.5 then map_y=0.5 end
 if btnp(—) then star_setup_tim=0 end

end

function starsetup()
 if star_setup_tim==0 then
  star_setup-=1
 end

 if star_setup==29 then
  map(0,32,0,0,16,16) sfx(1) end  
 if star_setup==28 then
  map(16,32,0,0,16,16) end
 if star_setup==27 then
  map(32,32,0,0,16,16) end
 if star_setup==26 then
  map(48,32,0,0,16,16) end
 if star_setup==25 then
  map(64,32,0,0,16,16) end
 if star_setup==24 then
  map(80,32,0,0,16,16) end
 if star_setup==23 then
  map(96,32,0,0,16,16) end
 if star_setup==22 then
  map(112,32,0,0,16,16) end
 if star_setup>=8 then
  if star_setup<=21 then
   rectfill(0,0,128,128,7)end
 end
 if star_setup==8 then
  map(112,32,0,0,16,16) sfx(2) end
 if star_setup==7 then
  map(96,32,0,0,16,16) end
 if star_setup==6 then
  map(80,32,0,0,16,16) end
 if star_setup==5 then
  map(64,32,0,0,16,16) end
 if star_setup==4 then
  map(48,32,0,0,16,16) end
 if star_setup==3 then
  map(32,32,0,0,16,16) end
 if star_setup==2 then
  map(16,32,0,0,16,16) end
 if star_setup==1 then
  map(0,32,0,0,16,16)
  player[5]=0
  cgr[2]=1
 end
  
  
end
__gfx__
000000002222110000000000eeeee22222eeeeeeeeeee22222eeeeeeffffffffffffffff00707070f777777111117777777cccccffffffffffffffffffffffff
000000002221210000000000ee9992222e22eeeeee9992222e22eeeeffffffffffffffff00000777c777711117711111777cccccffffffffffffffffffffffff
007007002222110000000000999991888ee9999e999991888ee9999effffffffffffffff00707070c771117717777771111cccccfffffcccccccccffffffffff
000770002221210000000000eeee999888991eeeeeee999888991eeeffffffffffffffff00000777c11111111111111111111111ffff7ccccccccc7fffffffff
000770002222110000000000ee00e988880de00eee00e988880de00effffffffffffffff00707070111110011111111111001111fff77ccccccccc77ffffffff
007007002221210000088800e0d1098d000d0d10e01d098d000d01d0ffffcccccfffffff00000777111105501111111110550111fcc77111111111777fffffff
000000002222110000282100e01d0eeeddde01d0e0d10eeeddde0d10ff77ccccc7777fff00707070f1110550111111111055011fccc71177177771177ccccccf
000000002221210022288800ee00eeeeeeeee00eee00eeeeeeeee00e7777ccccc777777700000777ffddd00ddddddddddd00ddffccc11777177777117ccccccc
000000000000000000000000000000000000000000000000000000000012122200000000dddddddddddddddd11111111b1b00b1b00000b1b22222222b1b00000
66666666666666660000000000000000000000000000000000b1b1b100112222b1b1b100dd2222dddd1111dd212121211bb00bb100000bb1222222221bb00000
555555555555555511111111000000000000000000000000001b1b1b001212221b1b1b00dd2666dddd1222dd12121212b1b00b1b00000b1b21122112b1b00000
dddddddddddddddd0000000000000000000000000000000000b11111001122221111b100dd2666dddd1222dd222222221bb00bb100000bb1211221121bb00000
111111111111111100000000000000000000000011111111001b11110012122211111b00dd2666dddd1222dd22222222b1b00b1b00000b1b21122112b1b00000
001d56000000000000000000111111110000000000000000001122220011222222212100dd2666dddd1222dddddddddd1bb00bb100000bb1211221121bb00000
001d56000000000000000000000000000000000000000000001212220012122222221100dd2666dddd1222ddddddddddb1b00b1b00000b1b22222222b1b00000
001d56000000000000000000000000001111111100000000001122220011222222212100dddddddddddddddddddddddd1bb00bb100000bb1222222221bb00000
ffffffffffffffffffffffffffcccccccccccccccccccccfffffffffc1111777177777711cccccccffffffffffffffff88888888808080808080808000000000
fffcccccccccccfffffffffffcccccccccccccccccccccc7ffffffff11111111111111111111111cffffffffffffffff88888888888888880808080880808080
ff7ccccccccccc7ffffffffffcccccccccccccccccccccc77fffffff111111111111111111111111fffccccccccfffff88888888808080808080808000000000
ff7ccccccccccc77fffffffffc111111111111111111111777ffffff111111111111111111111111ff7ccccccccfffff88888888888888880808080880808080
f7711111111111777fffffffc11111111111111111177711777fffff111110011111111111001111f77cccccccc7ffff80808080808080800000000000000000
f71171777717711777ffffffc11111111111111111177771177ccffff1110550111111111055011ff77111111117ffff88888888080808088080808000000000
c71771777717771177cccccfc11111111111111111177777117ccccffddd0550ddddddddd0550ddfc711771777177fff80808080808080800000000000000000
c11771777717777117cccccc111111111111111111177777711cccccfffdd00ddddddddddd00ddffc117771777117ccf88888888080808088080808000000000
c11771777717777711cccccc11111111111111111117777771111ccc000000007070707070000000c177771777717ccc70707070007070707070707070707070
11111111111111111111111c1111111111111111111111111111111c0000000000000000000000001177771777711ccc77770000000007077777777707000000
11111111111111111111111111111111111111111111111111111111000070707070707070707000111111111111111c70707070000070707070707070707000
11111111111111111111111111111111111111111111111111111111000000000000000000000000111111111111111177770000000000070707070700000000
11111001111111111100111111111001111111111111111110011111000070707070707070707000111001111110011170707070000070707070707070707000
f1110550111111111055011ff111055011111111111111110550111f000000000707070700000000f10550111105501f77770000000000000000000000000000
fddd0550ddddddddd0550ddffddd0550dddddddddddddddd0550dddf007070707070707070707070fd0550dddd0550df70707070000000007070707070000000
fffdd00ddddddddddd00ddfffffdd00dddddddddddddddddd00ddfff000000777777777777070000ffd00dddddd00dff77770000000000000000000000000000
111111111111111111111111111122220000000000000000000000000000000000000000000000000000000000000000eeeeeee2e118eeee0000000000000000
111111111111111111111111222222220000000000000000000000000000000000000000000000000000000000000000eeeeee2ee8828eee0000000000000000
111111111111111111112222222222220000000000000000000000000000000000000000000000000000000000000000eeeeee2222888eee0000000000000000
111111111111111122222222222222220000000000000000000000000000000000000000000000000000000000000000eeeeeeee2228eeee0000000000000000
111111111111222222222222222222220000000000000000000000000000000000000000000000000000000000000000eeeeeee22222eeee0000000000000000
111111112222222222222222222222220000000000000000000000eeee00000000000000000000000000000000000000eeeeee2222e222ee0000000000000000
11112222222222222222222222222222000000000000000000000e888877000000000000000000000000000000000000eee8888222eeeeee0000000000000000
22222222222222222222222222222222000000000000000000008888cccc700000000000000000000000000000000000ee8888882e999eee0000000000000000
22222222222222222222222222221111000000000000000000008881ccccce000000aaaa000000000000000000000000e88eeee88999eeee0000000000000000
222222222222222222222222111111110000000000000000000088811cc8880000aaaa999990000000000000000000008e999ee99944e00e0000000000000000
22222222222222222222111111111111000000000000000000008888118880000aaa99944000000000000000000000009999999940de01d00000000000000000
222222222222222211111111111111110000000000000000000008888880000aa9999450000000000000000000000000eeee994400de0d100000000000000000
2222222222221111111111111111111100000000000000000000008880000aa999944500000000000000000000000000ee00e400dd0de00e0000000000000000
222222221111111111111111111111110000000000000000000000000022099aa9944500000000000000000000000000e01d04dd000deeee0000000000000000
22221111111111111111111111111111000000000000000000000ddd222200999aa45100055500000000000000000000e0d10eeedddeeeee0000000000000000
1111111111111111111111111111111100000000000000000000d2222222000999941111500055000000000000000000ee00eeeeeeeeeeee0000000000000000
000000000000000000000000000000000000000000000000000d2222222000999994101116660500000000000000000000000000000000000000000007000700
00000000000000000000000000000000000000000000000000d22222222000999945105011006050000000000000000000700070007000707070707070707070
00000000000000000000000000000000000000000000000000d22222222009999945105060106050000000000000000000000000000000000000000000070007
00000000000000000000000000000000000000000000000002222222222009999455005060006050000000000000000000000000700070007070707070707070
00000000000000000000000000000000000000000000000002222222228eee999455000506660500000000000000000000000000000000000000000007000700
0000000000000000000000000000000000000000000000002222222288888e994555000550005500000000000000000000700070007000707070707070707070
00000000000000000000000000000000000000000000000022222288888888e94555000005550000000000000000000000000000000000000000000000070007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700070007070707070707070
000000000000000000000000000000000ccc000000ccc000ccc00cccccc00ccc000ccccc00cccc00cc0cc00cc0ccccc007070707070707070707070777777777
000000000000000000000000000000000cccc0000cccc00ccccc0cccccc0ccccc00cccccc0ccccc0cc0cc0cc00ccccc070707070777077707770777077707770
000000000000000000000000000000000ccccc00cc0cc0ccc0ccc00cc00ccc0ccc0cc00cc0cc00c0cc0cccc000cc000007070707070707070707070777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070707070707070707077707770777077
00000000000000000000000000000000088008880008808800088008800880008808888800888880880888800088888007070707070707070707070777777777
00000000000000000000000000000000088000800008808880888008800888088808800880880080880888880088000070707070777077707770777077707770
00000000000000000000000000000000088000000008800888880008800088888008800880888880880880888088888007070707070707070707070777777777
00000000000000000000000000000000088000000008800088800008800008880008800880888800880880088088888070707070707070707077707770777077
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7d7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000037383900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001b1b1800000000000014000000000000001414000000000014
2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c0000000000000009003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001b1b0000000000191a0100000000161b1e1f1414000000001e1e1f141414001e
2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d000000000000003d3e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1900000000001a1a01161b1b1b171a1e1c1e1e001414001e1e1c1e1e1e001e
2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1a001b1b1b001a1a01171a1a1a17191e1c1e1e1d1e1e001e1e1c1e1e1e001e
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1a001a1a1a001a1a0117191a1a171a1e1c1e1e1d1e1e001e1e1c1e1e1e001e
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000191a001a1a1a001a1901171a1a1a171a1e1c1e1e1d1e1e001e1e1c1e1e1e001e
0000000000000000000000000000000010111011101110111011101110111011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1a001a191a001a1a01171a1a19171a1e1c1e1e1d1e1e001e1e1c1e1e1e001e
0000000000000000000000000000000012121212000000000000000012121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1a001a1a1a001a1a01171a1a1a171a1e1c1e1e1d1e1e001e1e1c1e1e1e001e
0000000013131300000000131313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a1a001a1a1a001a1a01171a1a1a171a1e1c1e1e1d1e1e001e1e1c1e1e1e001e
0000141414000000000000141414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515000000000015151500000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000012121200000000000013131300000000000000000000000000000000001416161612161612000000141414161600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000013131313130000000000001515000000000000000000000000000000000000001616001612161616161616161616161200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000121212120000000012121212000000000000000000000000000000000000000016161200000000001216160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000046470000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000056575859000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000066676869000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50514243404152535051424340415253000000007475767778797a7b00000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000000000000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000000000000000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000000000000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000000000000000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000000000000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000000000000000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000000000000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000000000000000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000000000000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000000000000000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041525350514243404152535051424300000000000000000000000000000000000052530000424300005253000042430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051424340415253505142434041525300000000000000000000000000000000000042430000525300004243000052530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300002845300003314632e4632945327453224531e4531a44317443124430f433314032d4332a43324433204231c4231942315423124230e423334032d4132941325413224131f41319413144130f4130c413
00020000044130b4230f443184532346325473254732347321473204731f4731e4631e4531e4531d4531b4531a4531b4431a44318443164431444313443104430f4330b433094330642304423044230341302413
00020000064130f4231b44323453284632847329473284732547322473204731f4631d4531c4531a4531845316453134431144311443104430f4430e4430d4430c4330a433084330642305423044230341301413
00020000141430a1130f11315123171331b1331e14323153271532b1532f163331633a1733e173371031d1032210327103221031e103331031e1032110326103211031e103321031510316103001030010300103
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00200c0731b300193431b300246350000319343000030c07300003193430000324635000031b3431b3430c073000031b3430000324635000031b343000030c07300003193430000324635000031934324635
010c002002165021350211502165021350211502165021150a1650a1150a1650a1350a1150a1650a1350a11507165071350711507165071350711507165071150516505115051650513505115051650513505115
000c000002165021350211502165021350211502165021150a1650a1150a1650a1350a1150a1650a1350a11507165071350711507165051350511505165051150216502115021650213504115041650513507165
010c00002454218115285521f1221d555291252b5721f11518572181251f5621c1151d1251c5521d5421f13524542181152b5521f135295622b175285721c12518562181151d5521f1251d1151f5521c5621c115
010c00002454218115285521d125295621f1352b5721c12518542181251f5721c1151c5521d1251d5621f13524542181152b5721f135295621c125285521d12518542181151d5521f1351f5721d1251c5621c115
000c00002454224525285522852529552295252b5722b5250c1450c12510145101251114511125131451312524542245252b5522b525295622952528572285250c1450c125111551112513155131251014510125
010c00002454224521245112451528552295622b5722b5250c1320c1210c1110c11513132101121112211115245422452124511245152b5722956228552285250c1320c1210c1110c11511122131321011210115
000c00001803429072290512903129021290112f0002f0002f0002f0002f0002f0000710008100091000a1000010100101001010010100114001110111102121031210412105131061310714108151091610a171
010c00000c0001b300193001b300246000000019300000000c00000000193000000024600000001b3001b3000c073000031b30000003246351b343193430c073193430c0731930000003246350c0731934324635
010c00000c0731b300193431b300246350000319343000030c07300003193430000324635000031b3431b3430c073000031b3430000324635000031b343000030c00000000193000000024600000001930024600
010c00000c073000000000000000246350000000000000000c073000000000000000246350000000000000000c073000000000000000246350000000000000000c07300000000000c07324635000000000000000
000c000002165021350211502165021350211502165021150a1650a1150a1650a1350a1150a1650a1350a11507165071350711507165051350511504132041110311103111021110111505100051000510005100
010c00000c073000000000000000246350000000000000000c073246350000000000246350000000000000000c000000000000000000246000000000000000000c00000000000000c00024600000000000000000
000c0000246350000118600000010c625000012460100001186150000018600000000c600000002460100001246350000118600000010c62500001246010000118615000000c073000000c6000c0730c0730c073
010c000002161021010210102101021310210102101021010a1610a1010a1010a1010a1110a1010a1010a10107161071010710107101071310710107101071010516105101051010510105111051010510105101
010c000002161021010210102101021310210102101021010a1610a1010a1010a1010a1110a1010a1010a1010716107101071010710107131071010110101114011110212102121031310414106151081610a172
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
__music__
00 0e 0d 43 44
01 06 07 43 44
00 0f 08 43 44
00 06 07 09 44
00 06 08 0a 44
00 06 07 09 44
00 0f 08 0a 44
00 10 07 0b 44
00 10 08 0c 44
00 10 07 0b 44
00 12 11 0c 44
00 06 07 09 44
00 06 08 0a 44
00 06 07 09 44
00 0f 08 0a 44
00 13 14 0b 44
02 13 15 0c 44
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
