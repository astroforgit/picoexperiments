pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--basic functions
function _init()
 state="start"
end

function _update()
 if state=="start" then
  upd_start()
 elseif state=="game" then
  upd_game()
  ps_upd()
 elseif state=="game-pc" then
  upd_pc()
 elseif state=="gameover" then
  upd_gameover()
 end
end

function _draw()
 if state=="start" then
  drw_start()
 elseif state=="game" then
  if timel>=7 then
   pal_grey()
  end
  drw_game()
  pal()
 elseif state=="game-pc" then
  drw_pc()
 elseif state=="gameover" then
  drw_gameover()
 end
end

--update functions
function upd_start()
 if btnp(—) then
  game_init()
 end
end

function upd_game()
 controls_upd()
 flag_upd()
 anim_upd()
end

function upd_pc()
 anim_upd()
 if btnp(—) then
  if money>=100 then
   if buy_t<0 then
    buy_t=170
    sfx(4)
   end
  else
   sfx(1)
   if nobuy_t<0 then
    nobuy_t=90
   end
  end
 end
 if buy_t==0 then
  state="game"
  check_script()
 end
 if nobuy_t==0 then
  state="game"
  check_script()
 end 
end

function upd_gameover()
 if pos<226 then
  pos+=0.25
 end
 
 if btnp(—) then
  state="start"
 end
end
-->8
--draw functions
function drw_start()
 cls()
 --pal_grey()
 sspr(0,92,127,36,0,45)
 print_hc(" fficide",28+1,5)
 print_hc(" fficide",28,7)
 pal(4,5)
 spr(49,45,26)
 pal()
 spr(49,45,25)
 line(48,0,48,25,4)
 
 print("v 1.1",100,120,5)
 print_hc("press — to play",105,5)
 drawx(58,105)
end

function drw_game()
 cls()

 back_draw()
 ps_drw()

--money
 if timel>=2 then
  dx=2+121*(money/100)
  dy=4
  rectfill(2,2,125,8,8*bool(timel==2 and anim%4>=2 and fly>0))
  rectfill(4,4,dx,6,3+(8*bool(anim%2>=1)*bool(fly>0)))
  rect(2,2,125,8,7+4*bool(money>=100))
  dx=2+105*(money/100)
  spr(48,dx-4,2)
 	print("$"..tostr(money),dx+1,dy,0)
 	print("$"..tostr(money),dx,dy+1,0)
 	print("$"..tostr(money),dx+1,dy+1,0)
 	print("$"..tostr(money),dx,dy,7)
 end

--text bubbles
 if onel_t>0 and onel_del==0 then
  txt_bubbl(onel_txt,20)
 end

--requester
 if int_flag then
  requesters_drw()
 end

--player
 if walk then
  sspr(walk_sp*8,8,8,8,64-1,78,16,20,fl_x)
  clip(66,54,10,24,11)
 else
 	sspr(8,8,8,8,64,78,16,20,fl_x)
 end
 if fl_x then
  sspr(8,0,8,8,64+bool(walk)*((walk_sp/2)-4),54+(anim/2)*bt(‹)+(anim/2)*bt(‘),16,16,fl_x)
 	rectfill(66,70,79,78,7)
 else
  sspr(8,0,8,8,64+bool(walk)*((walk_sp/2)-2),54+(anim/2)*bt(‹)+(anim/2)*bt(‘),16,16,fl_x)
  rectfill(64,70,77,78,7)
 end
 clip()

--inventory
	if inv>0 and inv~=5 then
	 draw_box(65-pop/2,40+anim/2-pop/2,11+pop,10+pop,1,13)
	 spr(inv,67,40+anim/2+1)
	end
	
--ui
 if fly>0 and flytext~="" then
  dx=59+2*cos(fly/15)*(2*(1-fly/15))
  dy=40
  print(flytext,dx+10,dy+2+fly/2,0)
  print(flytext,dx+9,dy+3+fly/2,0)
  print(flytext,dx+10,dy+3+fly/2,0)
  print(flytext,dx+9,dy+2+fly/2,11)
  pal_black()
  spr(48,dx+1,dy+fly/2)
  spr(48,dx,dy+1+fly/2)
  spr(48,dx+1,dy+1+fly/2)
  pal()
  spr(48,dx,dy+fly/2)
 end
 
 --print(pos,100,100,7)
end

function drw_gameover()
 cls()
 --pal(15,0)
 --pal(6,0)
 --pal(13,0)
 pal_grey()

 --sspr(64,56,8,36,8,32,16,56)
 --pal()
 --sspr(72,56,64,36,16,32,108,56)
 back_draw()

	sspr(8,8,8,8,t_pos*2-pos*2+64,78,16,20,fl_x)
 sspr(8,0,8,8,t_pos*2-pos*2+64,54,16,16,fl_x)
 rectfill(t_pos*2-pos*2+64,70,t_pos*2-pos*2+77,78,7)

 
 rectfill(0,0,128,23,0)
 rectfill(0,93,128,128,0)
 print_hc("please talk to your collegaues",8,7)
 print_hc("about suicide",16,7)

 print_hc("officide was made by ilya, ilya",96,6)
 print_hc("and alexey",104,6)
end




function requesters_drw()
 --requesters
 local dx,dy

 --nick head
 if reqs[req_id].nm=="nick" then
  sspr(56,0,8,7,206-pos*2,35,16,16)
 end

 dx=64-pos*2+(reqs[req_id].x+reqs[req_id].l/2)*2
 
 --arrow left
 if dx<0 and arrow then
  if arrow then
   spr(32,0+anim,96,1,1,true)
  end
 --arrow right
 elseif dx>128 then
  if arrow then
   spr(32,120-anim,96)
  end
 --resource icon
 else
	 arrow=false
	 if wrong_res>0 then
	  dx+=anim%2
  end
  dy=30+anim/2
  if timel~=8 then
	  draw_box(dx-3,dy-8,16,18,1+(bool(wrong_res>0)),13-(bool(wrong_res>0)*5))
  	print("need",dx-2,dy-7,13-(bool(wrong_res>0)*5))
 	 spr(req_res,dx+2,dy+1)
   if req_tim>=0 then
    rectfill(dx-4,dy+13,dx+14,dy+16,0)
    rect(dx-4,dy+13,dx+14,dy+16,7)
    rectfill(dx-3,dy+14,dx-3+16*(req_tim/task_time),dy+15,11-2*bool(req_tim<task_time/2)-bool(req_tim<task_time/4))
   end
  end
 end
 
 dx=64-pos*2+(reqs[req_id].x+reqs[req_id].l/2)*2
 
 if timel<6 and (dx<0 or dx>128) and arrow==false and int_flag then
  dx=2
  dy=48
  draw_box(dx,dy,9,9,1,13)
  spr(req_res,dx+2,dy+1)
  if req_tim>=0 then
   rectfill(dx-1,dy+12,dx+10,dy+14,0)
   rect(dx-1,dy+12,dx+10,dy+14,7)
   line(dx,dy+13,dx+9*(req_tim/task_time),dy+13,11-2*bool(req_tim<task_time/2)-bool(req_tim<task_time/4))
  end
 end

 --resource helper
 if show_prov>0 then
  dx=66-pos*2+(provs[show_prov].x+provs[show_prov].l/2)*2
  circ(dx+3,112,7,7)
  drawx(dx,110)
 end
 
 if timel==6 and inv==5 then
  sspr(104,0,24,24,64-pos*2,72,32,32)
 end
end

function back_draw()
--bg
 rectfill(0,0,128,24,15)
 rectfill(0,98,128,128,13)
 if pos<160 then
  sspr(pos-32,92,64,36,0,24,128,74)
	 if pos>=96 then
	  sspr(0,56,pos-96,36,128-(pos-96)*2,24,(pos-96)*2,74)
	 end
	end
	if pos>=160 then
 	sspr(pos-160,56,64,36,0,24,128,74)
  rectfill(454-pos*2,0,455-pos*2,37,7)
  rectfill(454-pos*2,96,455-pos*2,128,7)

  if timel>6 then
   --open door
   rectfill(432-pos*2,38,453-pos*2,95,9)
   rectfill(431-pos*2,38,432-pos*2,95,6)
   rectfill(454-pos*2,38,455-pos*2,95,4)
   rectfill(431-pos*2,94,432-pos*2,95,5)
   rectfill(436-pos*2,67,437-pos*2,72,5)
   rectfill(434-pos*2,69,435-pos*2,74,6)

   if pos>180 then
   --toilet
    if timel>=7 then
     rectfill(456-pos*2,0,575-pos*2,23,0)
     rectfill(456-pos*2,98,575-pos*2,128,0)
     if timel<9 then
      fillp(0b0100000101000001)
      rectfill(488-pos*2,38,492-pos*2,91,1)
      rectfill(488-pos*2,92,492-pos*2,97,2)
      fillp(0b0101101001011010)
      rectfill(493-pos*2,38,498-pos*2,91,1)
      rectfill(493-pos*2,92,498-pos*2,97,2)
      fillp()
      rectfill(498-pos*2,0,575-pos*2,128,0)
      --sspr(104,0,24,24,468-pos*2,70,12,12)
     end
    end
    if timel>=8 then
     --rectfill(456-pos*2,0,575-pos*2,24,0)
     --rectfill(456-pos*2,98,575-pos*2,128,0)
     rectfill(473-pos*2,24,474-pos*2,40,4)
     sspr(8,24,8,8,465-pos*2,40-anim/2,16,16)    
    end
   else
    rectfill(456-pos*2,0,574-pos*2,128,0)
   end
  else
  --toilet fow
   rectfill(456-pos*2,0,574-pos*2,128,0)
  end
 end
 
 if pos<32 then
  rectfill(16-pos*2,24,64-pos*2,93,15)
  rectfill(16-pos*2,94,64-pos*2,95,6)
  rectfill(16-pos*2,96,64-pos*2,97,13)
 end
 if pos<117 then
  rectfill(108-pos*2,0,231-pos*2,27,6)
  rectfill(106-pos*2,0,107-pos*2,27,7)
  rectfill(232-pos*2,0,233-pos*2,27,7)
 end
 
 if timel>=7 then
  sspr(56,8,8,8,184-pos*2,57,16,16)
  sspr(64,8,8,8,200-pos*2,56,16,16)
 end
 
end

function drw_pc()
 cls(15)
 rectfill(0,84,127,127,9)
 rectfill(4,12,114,74,6)
 rectfill(8,8,118,70,7)
 rectfill(54,73,74,88,7)
 rectfill(54,73,55,88,6)
 rectfill(44,88,84,92,7)
 rectfill(12,12,114,66,1)

 rectfill(16,16,110,22,6)
 print("http://makeawish.com",17,17,5)
 print("’",103,17,10)
 print("’",102,17,9)

 local dx,dy,dw,dh
 if buy_t<0 then
	 sspr(104,0,24,24,24,32)

  dx=56
  dy=36
  print("$99.99",dx+1,dy,0)
  print("$99.99",dx,dy+1,0)
  print("$99.99",dx,dy,7)
  
  dx=81
  dy=49
  dw=28
  dh=12
  rectfill(dx-2,dy+2,dx+dw+2,dy+dh-2,0)
  rectfill(dx-1,dy+1,dx+dw+1,dy+dh-1,0)
  rectfill(dx,dy,dx+dw,dy+dh,0)
 
  dx=80
  dy=48
  rectfill(dx-2,dy+2,dx+dw+2,dy+dh-2,3)
  rectfill(dx-1,dy+1,dx+dw+1,dy+dh-1,3)
  rectfill(dx,dy,dx+dw,dy+dh,3)
 
  dx=89
  dy=52
  print("buy",dx,dy,7+(flr(anim/3))*4)
  
  if nobuy_t>0 then
   rectfill(14,34,112,54,7+(flr(anim/3)))
   rect(14,34,112,54,8-(flr(anim/3)))
   rect(16,36,110,52,8-(flr(anim/3)))
   print_hc("not enough money",42,8-(flr(anim/3)))
  else
   print_hc("press — to buy",116,4)
  end
 else
 --delivery
  dx=23
  dy=37
  line(dx-1,dy+16,dx+81,dy+16,12)
  line(dx-2,dy+17,dx+82,dy+17,6)
  sspr(8,16,8,8,dx,dy,16,16)
  sspr(24,16,8,8,dx+67,dy,16,16)

  if buy_t>120 then
   rectfill(14,34,112,54,3+4*(flr(anim/3)))
   rect(14,34,112,54,7-4*(flr(anim/3)))
   rect(16,36,110,52,7-4*(flr(anim/3)))
   print_hc("success",42,7-4*(flr(anim/3)))
  elseif buy_t>60 then
   sspr(16,16,8,8,dx+16+33*(1-((buy_t-60)/60)),dy,16,16)
  elseif buy_t>30 then
   sspr(16,16,8,8,dx+49,dy,16,16)
   sspr(32,16,8*(1-(buy_t-30)/30),8,dx+57,dy-12,16*(1-((buy_t-30)/30)),16)
  else 
   sspr(16,16,8,8,dx+49,dy,16,16)
   sspr(32,16,8,8,dx+57,dy-12,16,16)
  end
 end
end
-->8
--gameplay
function game_init()
 money=0
 pos=23
 office_len=218

	rp_init()
 
 onel_txt=""
 onel_t=0
 onel_act=0
 onel_del=0
 success=false

 show_prov=0

 fl_x=false

	fly=0
	flytext=""
 
 walk=false
 walk_sp=0
 
	anim=0
	anim_i=0.5
	buy_t=-1
	nobuy_t=-1
	popup=0
	pop=0

 timel=0
 script()
 
 ps_init()
 
 t_pos=0
 
 music(0,900)
 state="game"
end

function controls_upd()
 local btns=false
 --pos+=bt(‘)-bt(‹)
 if btn(‘) then
  pos+=1
  fl_x=false
  pos=min(pos,office_len-32)
  btns=true
 end
 if btn(‹) then
  pos-=1
  fl_x=true
  pos=max(16,pos)
  btns=true
 end

 if walk then
  if not btns then
   walk=false
  end
  show_prov=0
  
  if walk_sp==3 and anim%2==1 then
   sfx(0)
  end
  
  for i=1,provs_num do
   if pos>provs[i].x and pos<provs[i].x+provs[i].l then
    if timel<=4 and i~=4 and i~=1 then
     show_prov=i
    end
    if i==1 and timel==6 and inv~=6 then
     show_prov=i
    end
   end
  end

 else
  if btns then
   walk=true
   walk_sp=2
  end
 end
 
 if btnp(4) then
  music(-1)
 end
 
 if btnp(—) then
  if pos>reqs[req_id].x and pos<reqs[req_id].x+reqs[req_id].l then
   interact_req()
  end
  for i=0,provs_num do
   if pos>provs[i].x and pos<provs[i].x+provs[i].l then
    interact_prov(i)
    show_prov=0
   end
  end
  --

  if inv==22 and pos>reqs[1].x and pos<reqs[1].x+reqs[1].l then
   money+=50
   fly=15
   flytext="+$50"
   onel_txt="oh dear, i really needed     that, thank you"
 	 onel_t=200
 	 onel_del=15
 	 onel_act=1
   inv=5
   check_script()
  end
 end
end
-->8
--particles
function ps_init()
 ps_p1={}
 p1_count=0
 p1_grav=0.15
 p1_col=0
 p1_enable=false
end

function ps_emit(ex,ey,count,col)
 local rad=4
 local max_sp=2
 local max_ttl=15
 local min_ttl=5
 local i
 p1_count=count
 p1_col=col
 for i=0,p1_count do
  ps_p1[i]={}
  ps_p1[i].x=ex-rad/2+rnd(rad)
  ps_p1[i].y=ey-rad/2+rnd(rad)
  ps_p1[i].hs=sgn(rnd(2)-1)*rnd(max_sp)
  ps_p1[i].vs=sgn(rnd(2)-1)*rnd(max_sp)
  ps_p1[i].ttl=min_ttl+flr(rnd(max_ttl-min_ttl))
 end
 p1_enable=true
end

function ps_upd()
 if p1_enable then
  local i
  local c=0
  for i=0,p1_count do
   if ps_p1[i].ttl>0 then
    ps_p1[i].x+=ps_p1[i].hs
    ps_p1[i].y+=ps_p1[i].vs
    ps_p1[i].vs+=p1_grav
    ps_p1[i].ttl-=1
    c+=1
   end
  end
  if c==0 then
   p1_enable=false
  end
 end
end

function ps_drw()
 if p1_enable then
  local i
  for i=0,p1_count do
   if ps_p1[i].ttl>0 then
   local s=(ps_p1[i].ttl/15)*3
    rectfill(ps_p1[i].x,ps_p1[i].y,ps_p1[i].x+s,ps_p1[i].y+s,p1_col)
    --pset(ps_p1[i].x,ps_p1[i].y,p1_col)
   end
  end
 end
end
-->8
--misc
function hc(s)
 return 64-#s*2
end

function print_hc(s,py,pc)
 print(s,64-#s*2,py,pc)
end

function bt(b)
 if btn(b) then
  return 1
 else
  return 0
 end
end

function bool(b)
 if b then
  return 1
 else
  return 0
 end
end

function sh_pal()
 local i
 for i=1,16 do
  pal(i,0)
 end
end

function anim_upd()
 anim+=anim_i
 if anim>=5 or anim<=0 then
  anim_i=-anim_i
 end

 if buy_t>0 then
  buy_t-=1
 end
 if nobuy_t>0 then
  nobuy_t-=1
 end

 if state=="game" then
  if fly>0 then
   fly-=1
  end
  if fly==0 then
   flytext=""
  end
  
  if onel_del>0 then
   onel_del-=1
  end
  if onel_t>0 and onel_del==0 then
   onel_t-=1
  end
  
  if walk and anim%2==0 then
   walk_sp+=1
   if walk_sp==6 then
    walk_sp=2
   end
  end
  
  if wrong_res>0 then
   wrong_res-=1
  end
  
  if popup>0 then
   popup-=1
   pop=3-abs(popup-3)
  end
  
 end
end

function round(var)
 if var-flr(var)>=0.5 then
  return ceil(var)
 else
  return flr(var)
 end
end

function drawx(dx,dy)
 print("—",dx,dy,6)
 rectfill(dx+1,dy,dx+4,dy+3,0)
 print("—",dx,dy-round(time()%1.05),7)
end

function txt_bubbl(t,ty)
 local dx,dy,str_len,str_sep,str_num,i
 dy=ty--12
 dx=4
 str_len=flr((128-10)/4)
 str_sep=8
 str_num=flr(#t/str_len)

 rectfill(4,dy-8,#reqs[onel_act].nm*4+8,dy,0)
 print(reqs[onel_act].nm..":",6,dy-7,reqs[onel_act].c)
  
 draw_box(dx,dy,118,str_sep*(str_num+1),0,7)
 for i=0,str_num do
  if #t-str_len>=0 then
   ptxt=sub(t,1,str_len)
   t=sub(t,str_len+1)
  else
   ptxt=t
  end
  print(ptxt,dx+1,dy+1+i*str_sep,7)
 end

end

function draw_box(dx,dy,dw,dh,col1,col2)
 rectfill(dx,dy,dx+dw,dy+dh,col1)
 line(dx,dy-1,dx+dw,dy-1,col2)
 line(dx-1,dy,dx-1,dy+dh,col2)
 line(dx,dy+dh+1,dx+dw,dy+dh+1,col2)
 line(dx+dw+1,dy,dx+dw+1,dy+dh,col2)
end

function pal_black()
 local i
 for i=1,15 do
  pal(i,0)
 end
end

function pal_grey()
 pal(1,0)
 pal(2,5)
 pal(3,5)
 pal(4,5)
 pal(5,0)
 pal(6,5)

 pal(8,6)
 pal(9,5)
 pal(10,7)
 pal(11,7)
 pal(12,5)
 pal(13,5)
 pal(14,7)
 pal(15,6)
end
-->8
--mechanics
function rp_init()
 reqs={{nm="barbra",x=36,l=18,c=14},
 {nm="nick",x=75,l=10,c=3},
 {nm="chef",x=108,l=12,c=13},
 {nm="flower",x=136,l=11,c=7},
 {nm="pc",x=62,l=12,c=7},
 {nm="wc",x=180,l=10,c=7},
 {nm="rope",x=190,l=20,c=7}}
 
 provs={{nm="door",x=0,l=32,r=6,c=14},
 {nm="cooler",x=84,l=10,r=4,c=12},
 {nm="printer",x=121,l=13,r=2,c=7},
 {nm="mwave",x=156,l=2,r=22,c=10},
 {nm="coffee",x=165,l=12,r=3,c=4}}
 provs[0]={nm="gizmo",x=0,l=0,r=5,c=11}
	
	inv=5
 reqs_num=4
 provs_num=5

 int_flag=false
 int_t=0
 req_id=0
 prov_id=0
 req_res=0
 req_tim=0
 task_time=30*15
 task_price=12
 wrong_res=0

 flag_t=-1

end

function flag_reset()
 int_flag=false
 flag_t=60+flr(rnd(120))
end

function flag_upd()
 if int_flag==false then
  if flag_t>1 then
   flag_t-=1
  else
   --sfx(10)
   int_flag=true
   arrow=true
   req_id=flr(rnd(reqs_num))+1
   req_res=flr(rnd(3)+2)
   req_tim=task_time
   sfx(9)
   local i
   for i=1,provs_num do
    if provs[i].r==req_res then
     prov_id=i
    end
   end
  end
 end
 if req_tim>0 and arrow==false then
  req_tim-=1
 end
	if req_tim==0 then
	 req_tim=-1
	 sfx(3)
  success=false
  flag_reset()
  oneliner()
 end
end

function interact_prov(p)
 if (timel<=4 and p~=1)
 or (timel==6 and p==1) then
	 inv=provs[p].r
	 ps_emit(70,45,20,provs[p].c)
  popup=6
  sfx(3+p)
  if timel==6 and p==1 then
   music(-1,900)
   music(3,900)
  end
 end
end

function interact_req()
 if int_flag then
  if req_res==inv or req_res==5 then
   local bonus=flr(task_price*(req_tim/task_time))
   if bonus>=0 then
    if bonus==0 then
     bonus=1
    end
    money+=bonus
    sfx(4)
    fly=20+20*bool(money>=100)
    flytext="+$"..tostr(bonus)
    inv=5
    ps_emit(64,48,20+10*bool(money>=100),11)
   end
   if not check_script() then
    success=true
    flag_reset()
    oneliner()
   end
   req_tim=-1
  else
   sfx(1)
   wrong_res=15
  end
 end
end
-->8
--scripts

 --1 barbra --2 nick   --3 chef
 --4 flower --5 pc     --6 wc
 --7 rope
 
 --2 docs
 --3 coffee
 --4 water
 --5 no res interaction
 --6 gift
 
function oneliner()
 onel_act=req_id
 if reqs[req_id].nm=="barbra" then
  --docs
  if req_res==2 then
   if success then
    onel_txt="you know, this is, like, the only thing i've read in      years. this and 'twilight',  of course."
  		if rnd(2)>1 then
  		 onel_txt="reading a pile of documents! finally, some good use of my education."
  		end
  	else
  	 onel_txt="i thought better of you."
  	end
  --coffee
  elseif req_res==3 then
   if success then
    onel_txt="it's never too early for an  irish. never."
  		if rnd(2)>1 then
  		 onel_txt="hey handsome, don't you want to have a coffee with me     sometime? oh, ok."
  		end
  	else
  	 onel_txt="that was the same reason nicknever became a barista, you  know"
  	end
  --water
  elseif req_res==4 then
   if success then
    onel_txt="only way for me to see an    ocean."
  		if rnd(2)>1 then
  		 onel_txt="so, i drank a little last    night. who're you to judge?"
  		end
  	else
  	 onel_txt="do you want me to die of     thirst here, baby boy?"
  	end
  end
  
 elseif reqs[req_id].nm=="nick" then
  --docs
  if req_res==2 then
   if success then
    onel_txt="why is it signed by wife's   attorney?"
  		if rnd(2)>1 then
  		 onel_txt="work in office is what       grownups do"
  		end
  	else
  	 onel_txt="you know, forget about it.   it's only my career at stake here"
   end
  --coffee
  elseif req_res==3 then
   if success then
    onel_txt="wanted to become a barista.  never happened."
  		if rnd(2)>1 then
  		 onel_txt="i read online that coffee's  good for you health"
  		end
  	else
  	 onel_txt="should we talk about pattern here?"
   end
  --water
  elseif req_res==4 then
   if success then
    onel_txt="that's the most fancy drink  in my new diet"
  		if rnd(2)>1 then
  		 onel_txt="yay, water! ..."
  		end
  	else
  	 onel_txt="you'd to pretty try to fail  that."
  	end
  end
  
 elseif reqs[req_id].nm=="chef" then
  --docs
  if req_res==2 then
   if success then
    onel_txt="why is it always in          powerpoint?"
  		if rnd(2)>1 then
  		 onel_txt="everything is the same as    in last month. and in last   year."
  		end
  	else
  	 onel_txt="best description of your     results."
  	end
  --coffee
  elseif req_res==3 then
   if success then
    onel_txt="not that cold. unusual."
  		if rnd(2)>1 then
  		 onel_txt="so, you're actually able to  get things done in time!     wo-o-ow."
  		end
  	else
  	 onel_txt="that's what i call 'a team ofprofessionals'!"
  	end
  --water
  elseif req_res==4 then
   if success then
    onel_txt="at least something is liquid here!"
  		if rnd(2)>1 then
  		 onel_txt="m-m... cold as my dinners    with family."
  		end
  	else
  	 onel_txt="here goes your bonus."
  	end
  end
  
 elseif reqs[req_id].nm=="flower" then
  --docs
  if req_res==2 then
   if success then
    onel_txt="giving some dead trees to a  live one?"
    onel_act=2
  		if rnd(2)>1 then
  		 onel_txt="wasn't that the report i am  still waiting for?"
  		 onel_act=3
  		end
  	else
  	 onel_txt="you can't even get a joke."
  	 onel_act=2
  	end
  --coffee
  elseif req_res==3 then
   if success then
    onel_txt="the only good thing to do    with that coffee"
    onel_act=1
  		if rnd(2)>1 then
  		 onel_txt="yes, pour some coffee in it. this plant is more productivethan whole team."
  		 onel_act=3
  		end
  	else
  	 onel_txt="well i hope at least you     helped yourself with that    coffee"
  	 onel_act=1
  	end
  --water
  elseif req_res==4 then
   if success then
    onel_txt="you know, watering the plantsmay become your actual job   one day"
    onel_act=3
  		if rnd(2)>1 then
  		 onel_txt="we really appreciate your    efforts."
  		 onel_act=2
  		end
  	else
  	 onel_txt="can't you care a bit more    about the only growing       investment here?"
  	 onel_act=3
  	end
  end
 end
 onel_t=100
 onel_del=30
end

function script()

--start
 if timel==0 then
  onel_txt="you're 10 minutes late again!"
	 onel_t=200
	 onel_del=45
	 onel_act=3
	 arrow=true
	 req_id=5
	 req_res=5
	 req_tim=-1
	 flag_t=0
	 inv=5
	 int_flag=true
--enter the computer
 elseif timel==1 then
  state="game-pc"
--first task
 elseif timel==2 then
  onel_txt="try to look busy to get paid."
	 onel_t=200
	 onel_del=30
	 onel_act=1
	 flytext=""
	 fly=60
	 arrow=true
	 req_id=3
	 req_res=2
	 req_tim=-1
	 prov_id=3
	 flag_t=0
	 int_flag=true
--game game game
 elseif timel==3 then
  onel_txt="can't you move faster? or    bringing the papers is some  kind of rocket science for   you?"
	 onel_t=200
	 onel_del=45
	 onel_act=3
	 success=true
  money+=10
  fly=20
  flytext="+$10"
  inv=5
  sfx(4)
  ps_emit(64,48,20,11)
  flag_reset()
  --oneliner()
--he got the money
 elseif timel==4 then
	 req_id=5
	 req_res=5
	 req_tim=-1
	 arrow=true
	 inv=5
	 flag_t=0
	 int_flag=true
--back to pc
	elseif timel==5 then
	 state="game-pc"
 	buy_t=-1
 	nobuy_t=-1
--the gift is arrived
	elseif timel==6 then
	 money-=100
	 req_id=5
	 req_res=6
	 req_tim=-1
	 prov_id=1
	 inv=5
	 flag_t=0
	 arrow=true
	 int_flag=true
--unpacking
	elseif timel==7 then
	 office_len=236
	 req_id=7
	 req_res=25
	 req_tim=-1
	 prov_id=1
	 inv=25
	 flag_t=0
	 arrow=true
	 int_flag=true
--toilet
	elseif timel==8 then
	 --office_len=256
	 req_id=7
	 req_res=5
	 req_tim=-1
	 inv=5
	 flag_t=0
	 arrow=true
	 int_flag=true
--that's all folks
	elseif timel==9 then
  music(-1,900)
  music(1,900)
  t_pos=pos
	 state="gameover"
 end
end

function check_script()
 local cont=false
 if timel<=2 then
  timel+=1
  script()
  cont=true
 elseif timel==3 then
  if money>=100 then
   timel=4
   script()
   cont=true
  end
 elseif timel>=4 then
  timel+=1
  script()
  cont=true
 end
 return cont
end
__gfx__
0000000000aaa00077777700000000000777700000aa000007700770000000000000000000000000000000000000000000000000000000077700017770000000
0000000000a4400076666700077700007111170000aa400007077070004444000004440000000000000000000000000000000000000000777770077777000000
0070070000a44000777777007444770077777d0000aa4000ee7777ee00774400000ff00003333333000a40000000000000000000000007760677770077700000
000770000044400076666700777760707ccccd0000aa40007777777700744400000ff000bbbbbbb300aaa4000000000000000000000006700067760077600000
000770000077700077777700777760707ccccd0000aa4000eee77eee00044000000f0000b53535b300a994000000000000000000000006700007700077600000
007007000777770077766600777767007ccccd0000044000222662220033330000eee000b35553b3000940000000000000000000eeeee677eee77ee776eeeeee
0000000077777770777660007777600007ccd00000aa400022266222033333300eeeee00bbbbbbb000000000ffffffffffffffffeeeeee677ee77e776eeeeeee
0000000077777770777600000776000007ddd0000004400022266222333333300eeeee000000000000000000ffffffffffffffffeeeeeee667e77e66eeeeeeee
00076000773333700037730000333300033377000033337f000a000000000000ee0700000000000400000000777777ffffffffff777777776666666777777777
00777600f33333f00033f3000033330003333f000003333300abbaa00000000eeeee7eee0000004000aaa400000007ffffffffff777777777776677777777777
0777776003303300000333000003333003333000003330330a44aaaa000000ee2e55555e000004500aaa9940000007ffffffffffeeeeeeeeeee77eeeeeeeeeee
7767677603303300000333000133333003333300003300330a44aaa900000ee26555555e000044950aa99940000007ff11111fffeeeeeeeeeee77eeeeeeeeeee
760760760330330000333300013333003330330003330333a84aaa900000ee2622222222004400400a999940777777ff11111fffeeeeeeeeeee77eeeeeeeeeee
000760000330330013333300010330003300033033300330a88aa900000ee26022222222040000400999994097779999111119ff222222222226622222222222
000760000330330011003300000330003300033031000330a4ba9000000e260022227722040004000099940099999777111119ff222222222226622222222222
0007600001151110115511100051110011155111115051110aba00000000600022266262004440000000000055555555111115ff222222222226622222222222
00077000055000000707000000000000000000b3000000000000000000000000000000000000000000000000ffffffff11111fff222222222226622222222222
000677000005000007770000000cc000000000b3000000000000000000000000000000000000000000000000fffffffff0f05fff222222222226622222222222
00006770ccccc000ee6ee00000cccc0000000b30000000000000000000000000000000000000000000000000fffffff1111111ff222222222226622222222222
77777777ccccc000ee6eecc00cccccc030000b30000000000000000000000000000000000000000000000000fffffff1111111ff222222222226622222222222
66666776c7c7ccc022622c77ccccccccb300b300000000000000000000000000000000000000000000000000ffffffffff065fff222222222226622222222222
00007760ccccccc022622c770c7c77c00b30b300000000000000000000000000000000000000000000000000ffffffffff005fff222222222226622222222222
00077600c7c7c7c0cccccccc0c7c77c000bb3000000000000000000000000000000000000000000000000000ffffffffff065fff222222222226622222222222
00066000ccccc7c00c0000c00c7cccc0000b30000000000000000000000000000000000000000000000000006666666600000666222222222226622222222222
00000300000440000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000033300000a00000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033b53000a90000000a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333b3b5004004000004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b3b333004004000004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3533b335004004000004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33553350004004000004004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03300000000440000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff611111111111111111111111116111111111111611111111111611111111
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff611111111111111111111111116111111111111611111111111611111111
fffffffffffffffffffffffffffff6555555555565555555555fffffffffffffffff611111111111111111111111116111111111144411111111111611111111
fffffffffffffffffffffffffffff6555555555565555555555fffffffffffffffff6111111111111111111111111161111111111f4441111111111441111111
fffffffffffffffffffffffffffff6555555555565555555555fffffffffffffffff61111111111111111111111111611111111111f441111111117774111111
fffffffffffffffffffffffffffff6555555555565555555555fffffffffffffffff61111111111111111111111119611111111111ff61111111117744111111
fffffffffffffffffffffffffffff6555555555565555555555fffffffffffffffff611111111111111111111119999611111111116661111111114441111111
fffffffffffffffffffffffffffff6555555559565555555595ffffffffffffffff941111111111111111111111eee96911111111eeee1111111116661111111
fffffffffffffffffffffffffffff6555555555565555555555fffffffffffffff6941111111111111111111119eeee911111111eeeeee111111133333111111
fffffffffffffffffffffffffffff6999999999999999999999fffffffffffffff69411111111111111111111116666611111111eeeeee111111333333311111
fffffffffffffffffffffffffffff666666666666666666666ffffffffffffffff694111111111111111111111ccccccc1111111eeeeee111111333333311111
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff69411111111111111111111ccccccccc111111eeeeee111111333333311111
fffffffffffff3f3ffffffffffffffffffffffffffffffffffffffffffffffffff6941111111111111111111cccccccccc111111eeeeee111111333333311111
fffffffffff3f3bff3fffff57fffffffffffffffffffffffffffffffffffffffff6941111111111111111111ccccccccccc11111eeeeef111111333333311111
ffffffffff6f3f3f3ffffff57fffffffffffffffff5000005fffffffffffffffff6941111111111111111111ccccccccccc11111feeee1111111138888311111
fffffffff63b33333f3fff657ffffffffffffffff65555555fffffffffffffffff6941111111111111111111ccccccccccc111111eeee1111111148888411111
ffffffffff663f333f3fff657ffffffffffffffff65555525fffffffffffffffff6941111111111111111111ceeeeeeeeec111111eeee1111111188188111111
ffffffffff336333fbffff657fffff777777777ff60000000fffffffffffffffff6941111111111111111111c2eeeee222e111111dddd1111111188188111111
ffffffffff63333333ffff657ffff6755555727ff60077000fffffffffffffffff6941111111111111111111e222222222e111111dddd1111111188188111111
77777ffffff33b333f3fff657ffff6755555757ff60077700fffffffffffffffff694111111111111111111111222222211111111dddd1111111188188111111
66666ffff633333333ffff657ffff6755555757ff60077000fffffffffffffffff694111111111111111111111222122211111111f1f11111111188188111111
77777ffffff63333ffffff657ffff67777777776665555555ffffffffffffffff559411111111111111111111112212211111111141411111111188188111111
55557ffffff3333b33ffff657fff699999999999999999999999ffffffffffff6569411111111111115111111112212211111111411411111111144144111111
77777fffffff6333ffffff657fff699999999999999999999999ffffffffffff6569411111111111777711111112212211111111111111111111141141111111
00000ffffffff64fffffff657fff655555556555555565555555ffffffffffff6f69411111111110777711111114414411111111111111111111114114111111
55555ffffffff64fffffff657fff655555556555555565555555ffffffffffffff69411111111110777711111111411411111111111111111111111111111111
00044ffffffff64fffffff657fff655555556555555565555555ffffffffffffff69411111111110777711111114111411111111111111111111111111111111
44444ffffffff343ffffff657fff655555556555555565555555ffffffffffffff69411111111110777711111111111111111111111111111111111111111111
55555fffff69999999ffff657fff655555556555555565555555ffffffffffffff69411111fffffff55111111141111111111111144441111111111110441111
00044ffffff699999fffff657fff655555756555557565555575ffffffffffffff69411111077777775111111044444444111114044441111111044444441111
44444ffffff699999fffff657fff655555556555555565555555ffffffffffffff69411111107777771111111041110411111111044441111111104110441111
44444ffffff699999fffff657fff655555556555555565555555ffffffffffffff69411111110777711111111041110411111111044441111111104110441111
55555666666644444666666576666555555565555555655555556666666666666669411111111077711111111044444444111114044441111111044444441111
55555dddddd544444ddddd557ddd555555556555555565555555dddddddddddddd594222222222ddd22222222242222222222222244442222222222222442222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd59422222222222222222222222222222222222222222222222222222222222
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd22222222222222222222222222222222222222222222222222222222222
fffffffffffffffffffff7666666666666666666666666666666666666666666666666666666666666667fffff777fffffffffffffffffffffffffffffffffff
fffffffffffffffffffff7666666666666666666666666666666666666666666666666666666666666667ffff77577ffffffffffffffffffffffffffffffffff
fffffffffffffffffffff7666666666666666666666666666666666666666666666666666666666666667fff7775777fffffffffffffffffffffffffffffffff
fffffffffffffffffffff7666666666666666666666666666666666666666666666666666666666666667fff7755777fffffffffffffffffffffffffffffffff
fffffffffffffffffffff7666666666666666666666666666666666666666666666666666666666666667fff7777777fffffffffffffffffffffffffffffffff
fffffff7777777fffffff7666666666666666666666666666666666666666666666666666666666666667fff677777ffffffffffffffffffffffffffffffffff
fffffff7373337fffffff7666666666666666666666666666666666666666666666666666666666666667ffff6777fffffffffffffffffffffffffffffffffff
fffffff7777777fffffff7666666666666666666666666666666666666666666666666666666666666667fffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffff7666666666677777777777777777777777777777777777777777777777777777fffffffffffffffffffffffffffffffffffffffffff
ff44444444444444444ff7666666666676666666666666666666666666666666666666666666666666667fffffffffffffffffffffffff4444444444ffffffff
ff44444444444444444ff7666666666677777777777777777777777777777777777777777777777777777ffffffffffff4444444444f6499999999994fffffff
f644455554445555444ff7666666666676666666666666666666666666666666666666666666666666667fffffffffff64666666664f6499999999994fffffff
f644456554445655444ff7666666666676666666666666666666666666666666666666666666666666667fffffffffff64555555554f6499999999994fffffff
f644456554445655444ff7666666666677777777777777777777777777777777777777777777777777777fffffffffff64666666664f6499666666994fffffff
f644456554445655444ff766666666667ffffffffffffffffffffffff657ffffffffffffffffffffff657fffffffffff64005555554f6499655556994fffffff
f644456554445655444ff766666666667fffffffffffafff44fffffff657ffffffffffffffffffffff657fffffffffff64666666664f6499666666994fffffff
f644456554445655444ff766666666667ffffffffffffff4444fffaaf657ffffffffffffffff3f3fff657fffffffffff64225555554f6499999999994fffffff
f644456554445655444ff766666666667ffaaf67777777fe444fffaaf657fff67777777fffff3f3fff657fffffffffff64666666664f6499999999994fffffff
f644456554445655444ff766666666667ffaaf67000007fe4444fffff657fff67000007fffff33ffff657fffffffffff64111555554f6499999999994fffffff
f644456554445655444ff766666666667fffff6700000cccc44cccfff657fff67000007ffffff3ffff657ffff6ccccff64111155554f6499999999994fffff77
f644456554445655444ff766666666667fffff6700000ccc11111ccff657fff67000007fffff444fff657ffff6cffcff64111115554f6499999999994fffff66
f644455554445555444ff766666666667fffff67777ccccc11111ccff657fff67777777fffff444fff657ffff6cffcff64111115554f6499999999994ffff677
f644444444444444444ff7dddddddddd7fff699997cccccc11111cccf657f699997779999779999fff657ffff6ccccff64444444444f6499999999794ffff675
f644444444444444444ff766666666667fff6999eccccccc11111cccf657f699999999999999999fff657ffff6ccccff6666666666ff6499999999994ffff677
f644444474447444444ff766666666667fff65555555cccc11111cccf657f655555555555555555fff657fffff6ccfffffffffffffff6499999999994ffff600
f644444454445444444ff7dddddddddd7ffff65fffffcccc11111ccff657ff65ffffffffffff65ffff657ffff67777ffffffffffffff6499999999994ffff655
f644444444444444444ff766666666667ffff65fffffeeeee0e0eeeff657ff65ffffffffffff65ffff657ffff67c87ffffffffffffff6499999999994ffff644
f644444444444444444ff7dddddddddd7ffff65ffffff2211111112ff657ff65ffffffffffff65ffff657ffff67667ffffffffffffff6499999999994ffff644
f644444444444444444ff7dddddddddd7ffff65fffffff211111112ff657ff65ffffffffffff65ffff657ffff67667ffffffffffffff6499999999994ffff655
f644444444444444444ff766666666667ffff65ffffffff22202522ff657ff65ffffffffffff65ffff657ffff67777ffffffffffffff6499999999994ffff644
f644444444444444444ff7dddddddddd7ffff65ffffffff22200522ff657ff65ffffffffffff65ffff657ffff67777ffffffffffffff6499999999994ffff644
f644444444444444444ff7ddddddddd57ffff65fffffffff2206522ff657ff65ffffffffffff65ffff657ffff67777ffffffffffffff6499999999994ffff644
f644444444444444444ff7ddddddddd5666666566666666400000446665766656666666666666566666576666677776666666666666654999999999546666655
f644444444444444444ff7ddddddddddddddd50555555555055505ddd557dd5055555555555550dddd557dddd57777ddddddddddddddddddddddddddddddd555
6644444444444444445666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010a00000e62300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000000000a4400a4400a4400a4000a4400a4400b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000f7000f7000f7000f70001773007000070000700007000870306773007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000f00001b7501e75018750137500775007750077000970004700097003f7003f70039700017000f7003c7000a700277001670027700277003270032700327000d7003c7000e7003c70000700267000070000700
000700003175233750357503775039750366002d600266001a6001260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000001731a131001731a131001731a131001731a131001731a13100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000000000000
010f00000c62010430104300c6200c6200e430000000c62010430104300c620043000c62010430043000030000300003000030000300003000030000300000000000000000000000000000000000000000000000
001400003605036030360103e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000021330d161021330d161021330e161011330e161021330c10200103001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000000
010a00002973029550295402952029510015000e500015000e500025000c500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
012800000f7321674212742167420f7421674212732167220f732000000f0200f0200f0200f0200f0200f0200f7321674212742167420f7421674212732167220f7001670012700167000f700167001270016700
01280000125000f5000f500125001250016500125001450000000000000f5550f55512555125551655512555145540f5000f5000f500125001250016500125001450000000000000000000000000000000000000
012800000f7321674212742167420f7421674212732167220f7321674212742167420f74216742127321672200000000000000000000000000000000000000000000000000000000000000000000000000000000
012808000f7321674212742167420f742167421273216722000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012800000d0000d7000d5500d55011550115501455011550125500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e00000000028000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0f 0d 43 44
01 10 0a 0b 44
02 11 0c 0e 44
03 12 02 43 44
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
