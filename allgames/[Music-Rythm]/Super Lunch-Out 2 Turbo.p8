pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--super lunch-out 2 turbo
--by joseph3000

ring_colors,crowd_sprite={1,9,13},{221,222,223}

--functions------------------------------

function animate_player(p)
 if(p.t>0) then

  --punch, bad
  if(p.condition==1) then

   --punch body
   if(p.t>25) then
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf=96,64,32,40,-1,-2,false,false
   --bad body
   else
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf=56,64,40,32,3,10,false,false
   end
   --bad head
   p.head_sprite_x=p.head_sprite_x0+16

 if(p.t==30) then
  p.dead_food=true
 else
  p.dead_food=false
 end

  --punch, good
  elseif(p.condition==2) then

   --punch body
   if(p.t>25) then
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf=96,64,32,40,0,-2,false,false
   --good body
   else
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf=0,96,40,32,-1,0,false,false
   end
   --good head
   p.head_sprite_x=p.head_sprite_x0

 if(p.t==30) then
  p.dead_food=true
 else
  p.dead_food=false
 end

  --eat, bad
  elseif(p.condition==3) then

   p.dead_food=false

   --eat body
   if(p.t>25) then
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf=40,96,32,32,1,-2,true,false

   --bad body
   else
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove=56,64,40,32,3,10,false
    if(p.t==25) then
     p.barf=true
    else
     p.barf=false
    end
   end

   --bad head
   p.head_sprite_x=p.head_sprite_x0+16

  --eat, good
  elseif(p.condition==4) then

   p.dead_food=false

   --eat body
   if(p.t>25) then
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf=40,96,32,32,1,-2,true,false

   --good body
   else
    p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove=0,96,40,32,-1,0,false

    if(p.veg_mode==true and p.t==25) then
     p.barf=true
    else
     p.barf=false
    end

   end

   --eat head
   p.head_sprite_x=p.head_sprite_x0+32

  end

 --loser
 else
  --round end idle
  if(round_end==true and p.winner==false) then
   p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf,p.dead_food,p.head_sprite_x=56,64,40,32,3,10,false,false,false,p.head_sprite_x0+16

  --neutral
  else
   p.head_sprite,p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.head_x,p.head_y,p.glove,p.barf,p.dead_food,p.head_sprite_x=p.head_sprite_x0,0,96,40,32,0,0,false,false,false,p.head_sprite_x0

  end
  --animate head
  if(p.player==1) then
   p.head_x=p.head_x-sin(t/70)
  else
   p.head_y=sin(t/145)+p.head_y
  end

 end

 --head snap
 if(p.t>24 and p.t<=25) then
  p.head_y=p.head_y-1
 end
 if(p.t<20 and p.t>0) then
  p.head_x=p.head_x+1
 end

 p.t-=1 --------------------------this needs to be in its own function, causing problems; rewrite dead food code too

end

function animate_food(p)
 if(p.food.x>27) p.food.x-=1
 for index=1,6 do
  p.food[index].y=3*sin((t+p.food[index].offset)/50)+p.y+49
 end
end

function animate_crowd(p)
 if(t%10==0) then
  index,col=flr(rnd(3))+1,flr(rnd(16))+1
  p.crowd[col]=crowd_sprite[index]
 end
end

function animate_mario()
 if(mario_x>103) mario_x-=3
end

function init_food(p)
 for index=1,6 do
  food_sprite,p.food[index]=flr(rnd(6))+9,{}
  p.food[index].spr,p.food[index].offset=food_sprite,flr(rnd(100))
  p.food[index].y=3*sin((t+p.food[index].offset)/50)+p.y+49
 end
end

function what_did_i_eat(p)

  --bread
  if(p.food[1].spr==15) then
   p.condition=4
   sfx(8)

  --meat (good)
  elseif(p.food[1].spr<12)then
   p.hunger+=1
   p.condition,p.should_bread=4,true
   sfx(3)
   p.combo+=1

  --vegetable (bad)
  else
   p.hunger-=5
   if(p.hunger<0) p.hunger=0
   p.condition,p.flawless,p.combo,p.should_bread=3,false,0,true
   sfx(4)
  end

 p.food.x=41
 food_update(p)
 p.t=30

end

function what_did_i_punch(p)

  --bread
  if(p.food[1].spr==15) then
   p.condition=2
   sfx(8)

  --vegetable (good)
  elseif(p.food[1].spr>11)then
   p.hunger+=1
   p.condition,p.should_bread=2,true
   sfx(3)
   p.combo+=1

  --meat (bad)
  else
   p.hunger-=5
   if(p.hunger<0) p.hunger=0
   p.condition,p.flawless,p.combo,p.should_bread=1,false,0,true
   sfx(4)
  end

 p.dead_food_spr,p.food.x=p.food[1].spr+16,41
 food_update(p)
 p.t=30

end

function did_i_win(p)
 if(p.hunger==60) then
  p.wins+=1
  p.winner=true
  round_end_init()
 end
end

function scroll_text_s(text,x,y)
 if(t%3==0 and text.i<#text.str) then
  text.i+=1
  if(sub(text.str,text.i,text.i)==" ") text.i+=1
  sfx(3)
 end
 print(sub(text.str,1,text.i),x+1,y+1,5)
 print(sub(text.str,1,text.i),x,y,6)

end

function scroll_text(text,x,y,c)
 if(t%3==0 and text.i<#text.str) then
  text.i+=1
  if(sub(text.str,text.i,text.i)==" ") text.i+=1
  sfx(3)
 end
 print(sub(text.str,1,text.i),x,y,c)

end

--draw------------------------------

function draw_table(p)
 local table_color=p.table_color
 local y=p.y
 rectfill(20,y+55,127,y+56,table_color)
 rectfill(19,y+57,127,y+58,table_color)
 rectfill(18,y+59,127,y+61,table_color)
 line(17,y+62,127,y+62,table_color)
end

function draw_ring(p)
 local y=p.y

 --ring
 rectfill(0,y,127,y+62,ring_color)

 draw_table(p)

 --crowd: top row
 palt(0,false)
 for x=0,119,16 do
  spr(236,x,y+7)
  spr(237,x+8,y+7)
 end

 --crowd: bottom rows
 for col=1,16 do
  spr(p.crowd[col],(col-1)*8,y+15)
 end
 palt()

 line(0,y+23,127,y+23,0)

 --hud
 rectfill(0,y,127,y+6,12)
 print(p.name,2,y+1,7)
 rectfill(35,y+1,85,y+5,0)
 print("wins",93,y+1,7)
 circfill(112,y+3,2,0)
 circfill(118,y+3,2,0)
 circfill(124,y+3,2,0)
 if(p.wins>=1) then
  rectfill(111,y+2,113,y+4,7)
  pset(113,y+2,6)
 end
 if(p.wins>=2) then
  rectfill(117,y+2,119,y+4,7)
  pset(119,y+2,6)
 end
 if(p.wins==3) then
  rectfill(123,y+2,125,y+4,7)
  pset(125,y+2,6)  
 end

 if(p.bread>0) then
  pal(4,13)
  pal(5,13)
  spr(15,2,y+8+p.bread_offset)
  pal()
  spr(15,1,y+7+p.bread_offset)
  print(p.bread,12,y+9+p.bread_offset,13)
  print(p.bread,11,y+8+p.bread_offset,7)
 end

 rectfill(0,63,127,64,0)

 if(game_t>9) then
  print(game_t,120,y+9,9)
  print(game_t,119,y+8,10)
 else
  print("0"..game_t,120,y+9,9)
  print("0"..game_t,119,y+8,10)
 end

end

function draw_plate(p)
 palt(0,false)
 palt(13,true)
 sspr(96,120,16,8,37,p.y+55)
 palt()
end

function draw_ryan(p)
 palt(9,true)
 palt(0,false)
 if(p.player==1) then
  pal(12,15)
  sspr(p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.body_x,p.body_y)
  sspr(p.head_sprite_x,p.head_sprite_y,16,24,p.head_x+36,p.head_y+p.head_y0)
  if(p.glove==true) sspr(114,112,14,16,36,p.body_y+1)
 else
  pal(8,0)
  pal(4,5)
  pal(12,4)
  sspr(p.body_sprite_x,p.body_sprite_y,p.body_w,p.body_h,p.body_x,p.body_y)
  pal(8,8)
  pal(4,4)
  pal(12,12)
  sspr(p.head_sprite_x,p.head_sprite_y,16,24,p.head_x+36,p.head_y+p.head_y0)
  pal(8,0)
  pal(4,5)
  if(p.glove==true) sspr(114,112,14,16,36,p.body_y+1)
  pal(8,8)
  pal(4,4)
 end
 palt()

 if(p.barf==true) make_barf_ps(p.head_x+42,p.head_y0+p.head_y+22,p.y)
 if(p.dead_food==true) make_dead_food_ps(41,p.body_y+26,p.dead_food_spr,p.y)

end

function draw_shadows(p)
 local y=p.y
 local food_x=p.food.x
 for index=1,#p.food do
  rectfill(food_x+(14*index)+2,y+58,food_x+(14*index)+5,y+58,5)    
  rectfill(food_x+(14*index)+3,y+58,food_x+(14*index)+4,y+58,0)
  if(p.food[index].y>=y+48) then
   rectfill(food_x+(14*index)+3,y+58,food_x+(14*index)+4,y+58+1,5)
   rectfill(food_x+(14*index)+1,y+58,food_x+(14*index)+6,y+58,5)
   rectfill(food_x+(14*index)+2,y+58,food_x+(14*index)+5,y+58,0)
  end
  if(p.food[index].y>=y+50) then
   rectfill(food_x+(14*index),y+58,food_x+(14*index)+7,y+58,5)
   rectfill(food_x+(14*index)+1,y+58,food_x+(14*index)+6,y+58,0)
   rectfill(food_x+(14*index)+2,y+58+1,food_x+(14*index)+5,y+58+1,5)
   rectfill(food_x+(14*index)+3,y+58,food_x+(14*index)+4,y+58+1,0)
  end
  if(p.food[index].y>=y+59) then
   rectfill(food_x+(14*index)-1,y+58,food_x+(14*index)+8,y+58,5)
   rectfill(food_x+(14*index),y+58,food_x+(14*index)+7,y+58,0)
   rectfill(food_x+(14*index)+1,y+58+1,food_x+(14*index)+6,y+58+1,5)
   rectfill(food_x+(14*index)+2,y+58,food_x+(14*index)+5,y+58+1,0)
  end
 end
end

function draw_food(p)
 for index=1,6 do
  spr(p.food[index].spr,p.food.x+(14*index),p.food[index].y)
 end
end

function draw_hunger(p)

 local hunger=p.hunger*.81
 local y=p.y

 if(hunger>1) then
  rectfill(36,y+2,36+hunger,y+4,7)
 elseif(hunger>0) then
  rectfill(36,y+2,36,y+4,7)
 end

end

function draw_combo(p)
 local display_combo_y=p.display_combo_y
 if(p.display_combo>0) then

  local color
  if(p.display_combo%4==0) then
   color=10
  else
   color=8
  end

  print(p.combo_level,10,display_combo_y+1,0)
  print("combo!!",2,display_combo_y+9,0)
  print(p.combo_level,9,display_combo_y,color)
  print("combo!!",1,display_combo_y+8,color)

  if(p.display_combo%40==0) display_combo_y-=1
  p.display_combo-=1
 end
end

function draw_eat(p)
 local y=p.y

 if(t==161) then
  circfill(63,y+32,1,7)
 end 

 if(t==162) then
  circfill(63,y+32,2,7)
 end 

 if(t==163) then
  circfill(62,y+32,3,7)
  circfill(64,y+32,3,7)
  rectfill(62,y+29,64,y+35,7)
 end 

 if(t==164) then
  circfill(61,y+32,3,7)
  circfill(65,y+32,3,7)
  rectfill(61,y+29,65,y+35,7)
 end

 if(t==165) then
  circfill(60,y+32,3,7)
  circfill(66,y+32,3,7)
  rectfill(60,y+29,66,y+35,7)
 end

 if(t==166) then
  circfill(59,y+32,3,7)
  circfill(67,y+32,3,7)
  rectfill(59,y+29,67,y+35,7)
 end

 if(t==167) then
  circfill(58,y+32,3,7)
  circfill(68,y+32,3,7)
  rectfill(58,y+29,68,y+35,7)
 end

 if(t==168) then
  circfill(57,y+32,3,7)
  circfill(69,y+32,3,7)
  rectfill(57,y+29,69,y+35,7)
 end

 if(t==169) then
  circfill(56,y+32,3,7)
  circfill(70,y+32,3,7)
  rectfill(56,y+29,70,y+35,7)
 end

 if(t>=170 and t<220) then
  circfill(55,y+32,3,7)
  circfill(72,y+32,3,7)
  rectfill(55,y+29,72,y+35,7)
  print("e\65\84!!",55,y+30,0)
 end

 if(t==170) sfx(1)

end

function intro_draw()
 cls()

 if(t<100) then
  rectfill(0,0,127,127,12)
  print("\"winners don't eat vegetables\"",4,97,10)
  print("ryan ward, champion",27,107,10)

  circfill(63,49,36,10)
  circfill(63,49,33,1)
  circ(63,49,36,9)
  circ(63,49,33,9)

  palt(12,true)
  palt(0,false)
  sspr(0,0,36,48,46,25)

  palt()

 end

 if(t==100) music(0)

 if(t>=100 and t<550) then
  scroll_text_s(text1,6,30)
 end

 if(t>=250 and t<550) then
  scroll_text_s(text2,6,51)
 end

 if(t>=350 and t<550) then
  scroll_text_s(text3,6,65)
 end

 if(t>=413 and t<550) then
  scroll_text_s(text4,6,72)
 end

 if(t>=550 and t<2500) then
  rectfill(0,20,127,77,1)
 
  --ruins
  palt(0,false)
  sspr(40,8,32,16,0,27)
  sspr(40,24,32,16,32,27)
  sspr(40,8,32,16,64,27)
  sspr(40,24,32,16,96,27)
  line(0,43,127,43,5)
  rectfill(0,44,127,82,13)

 for q=0,120,8 do
  spr(5,q,44)
  spr(6,q,52)
 end

  palt()

  --if(t>=1527 and t<2200) then
   spr(paper_sprite,paper_x,paper_y)
   spr(can_sprite,can_x,can_y) --68
  --end

  if(t<2200) draw_ryan(p2)
  if(t==2200) then
   sfx(63)   
   rectfill(0,20,127,82,7)
  end

  if(t>=1500 and t<2327) then
   if(t%4==0) then
    circfill(45,54,timebubble_r,12)
   elseif(t%4==2) then
    circfill(45,54,timebubble_r,0)
   end

  end 

  draw_table(p2)
  draw_shadows(p2)
  draw_plate(p2)
  draw_particles()

 end

 if(t>=650 and t<850) then
  scroll_text(text5,5,87,7)
 end

 if(t>=719 and t<850) then
  scroll_text(text6,5,94,7)
 end
  
 if(t>=550 and t<850) spr(p2.food[1].spr,p2.food.x+14,p2.food[1].y)

 if(t>=900 and t<1100) then
  scroll_text(text7,5,87,7)
 end

 if(t>=969 and t<1100) then
  scroll_text(text8,5,94,7)
 end


 if(t>=1100 and t<1300) then
  scroll_text(text9,5,87,7)
 end
 
 if(t>=1169 and t<1300) then
  scroll_text(text10,5,94,7)
 end

 if(t>=1300 and t<1500) then
  scroll_text(text11,5,87,7)
 end

 if(t>=1369 and t<1500) then
  scroll_text(text12,5,94,7)
 end

 if(t>=1500 and t<1800) then
  scroll_text(text13,5,87,7)
 end

 if(t>=1569 and t<1800) then
  scroll_text(text14,5,94,7)
 end

 if(t>=1638 and t<1800) then
  scroll_text(text15,5,101,7)
 end

 if(t>=1800 and t<2500) then
  scroll_text(text16,5,87,7)
 end

 if(t>=1869 and t<2500) then
  scroll_text(text17,5,94,7)
 end

 if(t>=1938 and t<2500) then
  scroll_text(text18,5,101,7)
 end

 if(t>=2010 and t<2500) then
  scroll_text(text19,5,108,7)
 end

 if(t>=2100 and t<2500) then
  scroll_text(text20,5,122,7)
 end


end

function title_draw()
 cls()

 if(t<100) then
  pal(1,7)
  pal(13,7)
  pal(10,7)
  pal(14,7)
 elseif(t==100) then
  pal(1,0)
  pal(13,0)
  pal(10,0)
  pal(14,0)
  rectfill(0,0,127,127,7)
  sfx(63)
 else
  pal(1,1)
  pal(13,13)
  color_a,color_b=1,13
  if(t%10<=5 and t%10>=0) then
   pal(10,1)
   pal(14,13)
  else
   pal(10,13)
   pal(14,1)
  end
 end

 --s
 rectfill(21,33,30,37,1)
 rectfill(28,35,32,39,1)
 rectfill(30,37,34,41,1)
 rectfill(19,35,23,39,1)
 rectfill(17,37,21,43,1)
 rectfill(19,41,23,45,1)
 rectfill(24,43,25,45,1)
 line(24,45,27,45,1)
 rectfill(17,53,21,57,13)
 rectfill(19,55,23,59,13)
 rectfill(21,57,30,61,13)
 rectfill(28,55,32,59,13)
 rectfill(30,51,34,57,13)
 rectfill(28,49,32,53,13)
 rectfill(26,50,27,51,13)
 line(24,49,27,49,13)
 pset(21,46,14)
 pset(22,46,10)
 pset(23,46,14)
 pset(24,46,10)
 pset(25,46,14)
 pset(26,46,10)
 pset(27,46,14)
 pset(21,47,10)
 pset(22,47,14)
 pset(23,47,10)
 pset(24,47,14)
 pset(25,47,10)
 pset(26,47,14)
 pset(27,47,10)
 pset(28,47,14)
 pset(29,47,10)
 pset(30,47,14)
 pset(24,48,10)
 pset(25,48,14)
 pset(26,48,10)
 pset(27,48,14)
 pset(28,48,10)
 pset(29,48,14)
 pset(30,48,10)
 --u
 rectfill(37,33,41,45,1)
 rectfill(49,33,53,45,1)
 rectfill(37,49,41,57,13)
 rectfill(39,55,43,59,13)
 rectfill(47,55,51,59,13)
 rectfill(41,57,49,61,13)
 rectfill(49,49,53,57,13)
 pset(37,46,14)
 pset(38,46,10)
 pset(39,46,14)
 pset(40,46,10)
 pset(41,46,14)
 pset(37,47,10)
 pset(38,47,14)
 pset(39,47,10)
 pset(40,47,14)
 pset(41,47,10)
 pset(37,48,14)
 pset(38,48,10)
 pset(39,48,14)
 pset(40,48,10)
 pset(41,48,14)
 pset(49,46,14)
 pset(50,46,10)
 pset(51,46,14)
 pset(52,46,10)
 pset(53,46,14)
 pset(49,47,10)
 pset(50,47,14)
 pset(51,47,10)
 pset(52,47,14)
 pset(53,47,10)
 pset(49,48,14)
 pset(50,48,10)
 pset(51,48,14)
 pset(52,48,10)
 pset(53,48,14)
 --p
 rectfill(56,33,60,45,1)
 rectfill(61,33,68,37,1)
 rectfill(66,35,70,39,1)
 rectfill(68,37,72,45,1)
 rectfill(66,43,68,45,1)
 line(56,45,65,45,1)
 line(56,49,68,49,13)
 rectfill(56,50,60,61,13)
 pset(56,46,10)
 pset(57,46,14)
 pset(58,46,10)
 pset(59,46,14)
 pset(60,46,10)
 pset(61,46,14)
 pset(62,46,10)
 pset(63,46,14)
 pset(64,46,10)
 pset(65,46,14)
 pset(66,46,10)
 pset(67,46,14)
 pset(68,46,10)
 pset(69,46,14)
 pset(70,46,10)
 pset(56,47,14)
 pset(57,47,10)
 pset(58,47,14)
 pset(59,47,10)
 pset(60,47,14)
 pset(61,47,10)
 pset(62,47,14)
 pset(63,47,10)
 pset(64,47,14)
 pset(65,47,10)
 pset(66,47,14)
 pset(67,47,10)
 pset(68,47,14)
 pset(69,47,10)
 pset(70,47,14)
 pset(56,48,10)
 pset(57,48,14)
 pset(58,48,10)
 pset(59,48,14)
 pset(60,48,10)
 pset(61,48,14)
 pset(62,48,10)
 pset(63,48,14)
 pset(64,48,10)
 pset(65,48,14)
 pset(66,48,10)
 pset(67,48,14)
 pset(68,48,10)
 --e
 rectfill(75,33,92,37,1)
 rectfill(75,38,79,44,1)
 line(75,45,92,45,1)
 line(75,49,92,49,13)
 rectfill(75,50,79,61,13)
 rectfill(80,57,92,61,13)
 pset(75,46,14)
 pset(76,46,10)
 pset(77,46,14)
 pset(78,46,10)
 pset(79,46,14)
 pset(80,46,10)
 pset(81,46,14)
 pset(82,46,10)
 pset(83,46,14)
 pset(84,46,10)
 pset(85,46,14)
 pset(86,46,10)
 pset(87,46,14)
 pset(88,46,10)
 pset(89,46,14)
 pset(90,46,10)
 pset(91,46,14)
 pset(92,46,10)
 pset(75,47,10)
 pset(76,47,14)
 pset(77,47,10)
 pset(78,47,14)
 pset(79,47,10)
 pset(80,47,14)
 pset(81,47,10)
 pset(82,47,14)
 pset(83,47,10)
 pset(84,47,14)
 pset(85,47,10)
 pset(86,47,14)
 pset(87,47,10)
 pset(88,47,14)
 pset(89,47,10)
 pset(90,47,14)
 pset(91,47,10)
 pset(92,47,14)
 pset(75,48,14)
 pset(76,48,10)
 pset(77,48,14)
 pset(78,48,10)
 pset(79,48,14)
 pset(80,48,10)
 pset(81,48,14)
 pset(82,48,10)
 pset(83,48,14)
 pset(84,48,10)
 pset(85,48,14)
 pset(86,48,10)
 pset(87,48,14)
 pset(88,48,10)
 pset(89,48,14)
 pset(90,48,10)
 pset(91,48,14)
 pset(92,48,10)
 --r
 rectfill(95,33,99,45,1)
 rectfill(100,33,107,37,1)
 rectfill(105,35,109,39,1)
 rectfill(107,37,111,45,1)
 rectfill(105,43,107,45,1)
 line(95,45,104,45,1)
 line(95,49,107,49,13)
 rectfill(95,50,99,61,13)
 rectfill(99,49,103,53,13)
 rectfill(101,51,105,55,13)
 rectfill(103,53,107,57,13)
 rectfill(105,55,109,59,13)
 rectfill(107,57,111,61,13)
 pset(95,46,10)
 pset(96,46,14)
 pset(97,46,10)
 pset(98,46,14)
 pset(99,46,10)
 pset(100,46,14)
 pset(101,46,10)
 pset(102,46,14)
 pset(103,46,10)
 pset(104,46,14)
 pset(105,46,10)
 pset(106,46,14)
 pset(107,46,10)
 pset(108,46,14)
 pset(109,46,10)
 pset(95,47,14)
 pset(96,47,10)
 pset(97,47,14)
 pset(98,47,10)
 pset(99,47,14)
 pset(100,47,10)
 pset(101,47,14)
 pset(102,47,10)
 pset(103,47,14)
 pset(104,47,10)
 pset(105,47,14)
 pset(106,47,10)
 pset(107,47,14)
 pset(108,47,10)
 pset(109,47,14)
 pset(95,48,10)
 pset(96,48,14)
 pset(97,48,10)
 pset(98,48,14)
 pset(99,48,10)
 pset(100,48,14)
 pset(101,48,10)
 pset(102,48,14)
 pset(103,48,10)
 pset(104,48,14)
 pset(105,48,10)
 pset(106,48,14)
 pset(107,48,10)


 pal()

 if(t>220) then

 --l
 sspr(0,72,12,19,logo_x-1,49)
 --u
 spr(128,logo_x+12,60)
 --n
 spr(129,logo_x+21,60)
 --c
 spr(130,logo_x+30,60) 
 --h
 spr(131,logo_x+39,60) 

 --hyphen
 line(logo_x+51,63,logo_x+55,63,9)
 line(logo_x+51,64,logo_x+55,64,8)

 --o
 sspr(12,72,13,19,logo_x+61,49)
 --u
 spr(128,logo_x+75,60)
 --t
 spr(132,logo_x+84,60)
 --ii
 sspr(26,78,14,13,logo_x+95,55)
  print("turbo",99,70,10)

  print("made by joseph3000 (c) 2017",11,120,5)

 end

 if(title_flag) then
  if (t%4==0) print("press any button",32,90,7)
 elseif(t>300 and t%100>=0 and t%100<50) then
  print("press any button",32,90,7)
 end

end

function instructions_draw()
 cls()

 print("controls:",0,0,7)
 print("1p: \148 eat food; \131 punch food",0,7,7)
 print("2p: e eat food; d punch food",0,14,7)

 cls()
 print("how to play",44,1,7)
 spr(10,10,21)
 spr(11,10,31)
 spr(9,10,41)
 spr(12,70,21)
 spr(13,70,31)
 spr(14,70,41)

 print("steak",21,22)
 print("chicken",21,32)
 print("bacon",21,42)
 print("apple",81,22)
 print("eggplant",81,32)
 print("broccoli",81,42)

 print("eat!",20,12,11)
 print("don't eat!",74,12,8)

 print("   satisfy your hunger before",3,52,13)
 print("your opponent! eating/punching",3,59,13)
 print("correctly earns +1 point; a",3,66,13)

 print("mistake costs -5 points!",3,73,13)

 spr(15,16,81)
 print("bread is just filler!",27,83,5)

 print("controls:",47,93,7)

 print("eat food   \148 (1p)  e (2p)",11,101,7)
 print("punch food \131 (1p)  d (2p)",11,108,7)

 if(p1.ready) then
  print("p1 ok!",19,120,3)
  print("p1 ok!",18,119,11)
 else
  print("p1 ready?",13,120,2)
  print("p1 ready?",12,119,14)
 end

 if(p2.ready) then
  print("p2 ok!",86,120,3)
  print("p2 ok!",85,119,11)
 else
  print("p2 ready?",80,120,9)
  print("p2 ready?",79,119,10)
 end

end

function game_draw()
 cls()
 draw_ring(p1)
 draw_ring(p2)
 draw_shadows(p1)
 draw_shadows(p2)
 draw_plate(p1)
 draw_plate(p2)
 draw_ryan(p1)
 draw_ryan(p2)
 draw_particles()
 rectfill(0,63,127,64,0)
 draw_food(p1)
 draw_food(p2)
 draw_hunger(p1)
 draw_hunger(p2)
 draw_combo(p1)
 draw_combo(p2)
 draw_eat(p1)
 draw_eat(p2)
end

function draw_text(p)
 print("draw",56,p.y+31,0)
 print("draw",55,p.y+30,12)
end

function round_end_draw()

 draw_ring(p1)
 draw_ring(p2)
 draw_shadows(p1)
 draw_shadows(p2)
 draw_plate(p1)
 draw_plate(p2)
 draw_ryan(p1)
 draw_ryan(p2)
 draw_particles()
 rectfill(0,63,127,64,0)
 draw_hunger(p1)
 draw_hunger(p2)
 draw_combo(p1)
 draw_combo(p2)

 if(wait==0) then

  if(p1.winner) then
   draw_mario(p1)
   win_lose_text(p1,p2)
  elseif(p2.winner) then
   draw_mario(p2)
   win_lose_text(p2,p1)
  else
   draw_text(p1)
   draw_text(p2)
  end

  draw_food(p1)
  draw_food(p2)

  if((p1.winner or p2.winner) and mario_t==45) sfx(2)

  if(mario_t>=110) then
   print("ready: ",2,50,5)
   print("ready: ",1,49,7)
   if(p1.ready) then
    print("ok!",2,57,5)
    print("ok!",1,56,11)
   else
    print("\148/\131",2,57,5)
    print("\148/\131",1,56,7)
   end
   print("ready: ",2,115,5)
   print("ready: ",1,114,7)
   if(p2.ready) then
    print("ok!",2,122,5)
    print("ok!",1,121,11)
   else
    print("e/d",2,122,5)
    print("e/d",1,121,7)
   end
  end

 else
  draw_food(p1)
  draw_food(p2) 
  draw_time_over(p1)
  draw_time_over(p2)
 end

end

function draw_mario(p)
 local y=p.y

 palt(0,false)
 palt(3,true)
 sspr(72,96,24,24,mario_x,y+31)
 palt()

 if(mario_t>=45) then
  --speech bubble
  circfill(75,y+48,3,7)
  circfill(84,y+48,3,7)
  rectfill(75,y+45,75+9,y+51,7)
  rectfill(86,y+47,75+13,y+49,7)
  rectfill(88,y+48,75+14,y+49,7)
  rectfill(90,y+48,75+17,y+48,7)
  pset(94,y+48,7)
  print("ko!",75,y+46,0)
 end

end

function win_lose_text(pa,pb)
 print("you win!",50,pa.y+31,0)
 print("you win!",49,pa.y+30,7)
 print("you lose",50,pb.y+31,0)
 print("you lose",49,pb.y+30,11)
 if(pa.flawless) then
  print("flawless victory",34,pa.y+38,0)
  if(t%4==0) then
   print("flawless victory",33,pa.y+37,9)
  else
   print("flawless victory",33,pa.y+37,8)
  end
 end

end

function win_screen_draw()
 cls()
 palt(9,true)
 palt(0,false)
 if(p1.wins==3) then
  sspr(p1.head_sprite_x0,p1.head_sprite_y,16,24,31,40)
  sspr(p2.head_sprite_x0+16,p2.head_sprite_y,16,24,80,40)
 else
  sspr(p1.head_sprite_x0+16,p1.head_sprite_y,16,24,31,40)
  sspr(p2.head_sprite_x0,p2.head_sprite_y,16,24,80,40)
 end
 palt()
 print("go home and be a family man!",10,85,7)
end

function draw_particles()
 for ps in all(particle_systems) do
  draw_ps(ps)
 end
end

--update------------------------------

function food_update(p)

 local food_sprite
 local coinflip

 --shift food left
 for index=2,6 do
  p.food[index-1].spr,p.food[index-1].offset,p.food[index-1].y=p.food[index].spr,p.food[index].offset,p.food[index].y
 end

 --generate new food
 if(p.bread~=0) then
  coinflip=flr(rnd(2))
  if(coinflip==0) then
   food_sprite=15
   p.bread-=1
  else
   food_sprite=flr(rnd(6))+9   
  end
 else
  food_sprite=flr(rnd(6))+9
 end

 p.food[6].spr,p.food[6].offset=food_sprite,flr(rnd(100))

end

function intro_update()
 t+=1

 if(t>=1527) then
  if(t%2==0) paper_sprite+=1
  if(paper_sprite==106) paper_sprite=96
  paper_x+=(4*accel)
  if(paper_x>151) then
   paper_x=-8
   paper_y=flr(rnd(20))+50
  end

  if(t%2==0) can_sprite+=1
  if(can_sprite==122) can_sprite=112
  can_x+=(2*accel)
  if(can_x>135) then
   can_x=-8
   can_y=flr(rnd(10))+58
  end
 end

 if(t>=1527 and t<2300) then
  if(accel>=1) then
   accel=1
  else
   accel+=0.005
  end
 end

 if(t>=2300) then
  if(accel<=0) then
   accel=0
  else
   accel-=0.006
  end
 end

 if(t==850) then
  p2.condition,p2.t=3,30
 end

 animate_player(p2)
 update_psystems_intro()

 if(t>=550 and t<1500) then
  if(p2.food.x>27) p2.food.x-=1
  p2.food[1].y=3*sin(t/50)+p2.y+49
 end

--timebubble_r
 if(t>=1500 and t<2300) then
  if(timebubble_r<27) timebubble_r+=1
 end

 if(t>2300) then
  if(timebubble_r>0) timebubble_r-=1
 end

 if(t==2450) then
  t=0
  title_init()
 end

 if(btnp()!=0) then
  t=220
  title_init()
  music(-1)
 end

end

function title_update()
 t+=1
 if(t==900 and title_flag==false) intro_init()
 if(t>220 and (flr(logo_x)>14)) then
  logo_x=logo_x*.8
 end
 if(btnp()!=0 and title_flag==false and t<220) then
  t=220
  music(-1)
 end

 if((btnp()!=0) and title_flag==false and t>220) then
  sfx(62)
  title_flag=true
 end
 if(title_flag) t_title-=1
 if(t_title==0) instructions_init()
end

function instructions_update()
 if(p1.ready==true and p2.ready==true) then
  t_ready-=1
  if(t_ready==0) then
   music(12)
   game_init()
  end
 end
 if((btnp(2) or btnp(3)) and p1.ready~=true) then
  p1.ready=true
  sfx(21)
 end
 if((btnp(2,1) or btnp(3,1)) and p2.ready~=true) then
  p2.ready=true
  sfx(21)
 end
end

function game_update()
 t+=1

 if(t==1) sfx(0)
 if(t==110) sfx(7)

 animate_player(p1)
 animate_player(p2)
 update_psystems()
 animate_food(p1)
 animate_food(p2)
 animate_crowd(p1)
 animate_crowd(p2)

 bread_update(p1,p2)
 bread_update(p2,p1)

 if(t>=220) then

  if(game_t==0) then
   wait=150
   round_end_init()
  else
   if(t%30==0) game_t-=1
   did_i_win(p1)
   did_i_win(p2)

   --check button up p1
   if(btn(2)) then
    if(prevbtn_p1_2!=2) then
     what_did_i_eat(p1)
     prevbtn_p1_2=2
    end
   else
    prevbtn_p1_2=nil
   end

   --check button down p1
   if(btn(3)) then
    if(prevbtn_p1_3!=3) then
     what_did_i_punch(p1)
     prevbtn_p1_3=3
    end
   else
    prevbtn_p1_3=nil
   end

   --check button up p2
   if(btn(2,1)) then
    if(prevbtn_p2_2!=2) then
     what_did_i_eat(p2)
     prevbtn_p2_2=2
    end
   else
    prevbtn_p2_2=nil
   end

   --check button down p2
   if(btn(3,1)) then
    if(prevbtn_p2_3!=3) then
     what_did_i_punch(p2)
     prevbtn_p2_3=3
    end
   else
    prevbtn_p2_3=nil
   end

  end
 end
end

function bread_update(pa,pb)
 if(pb.bread_offset~=0) pb.bread_offset-=1
 if(pa.combo>0 and pa.combo%10==0 and pa.should_bread==true) then
  pb.bread+=pa.combo
  pa.should_bread,pa.display_combo,pa.display_combo_y,pa.combo_level,pb.bread_offset=false,120,pa.y+29,pa.combo,3
  sfx(5)
 end
end

function draw_time_over(p)
 local y=p.y
 print("time over",47,y+31,9)
 print("time over",46,y+30,10)
end

function round_end_update()
 t+=1
 animate_player(p1)
 animate_player(p2)
 update_psystems()
 animate_food(p1)
 animate_food(p2)
 animate_crowd(p1)
 animate_crowd(p2)

 if(wait==0) then

  round_end=true

  mario_t+=1

  animate_mario()

  bread_update(p1,p2)
  bread_update(p2,p1)

  if((p1.winner or p2.winner) and mario_t==70) sfx(0)

  if(p1.ready==true and p2.ready==true) then
   t_ready-=1
   if(t_ready==0) then
    if(p1.wins==3 or p2.wins==3) then
      win_screen_init()
     else
      game_init()
    end
   end
  end

  if(mario_t>=110) then
   if((btnp(2) or btnp(3)) and p1.ready~=true) then
    p1.ready=true
    sfx(21)
   end
   if((btnp(2,1) or btnp(3,1)) and p2.ready~=true) then
    p2.ready=true
    sfx(21)
   end
  end

 else
  wait-=1
 end

end

function win_screen_update()
 t+=1
 if(t==300) then
  t=220
  title_init()
 end
end

--init------------------------------

function intro_init()
 mode,t,round_end,p1,p2,timebubble_r,paper_sprite,paper_x,can_sprite,can_x,paper_y,can_y,accel=0,0,false,{},{},0,96,-8,112,-8,flr(rnd(20))+50,flr(rnd(10))+58,0

p1.player,p1.y,p1.head_y0,p1.head_sprite_x0,p1.head_sprite_y,p1.body_sprite0,p2.player,p2.head_y0,p2.head_sprite_x0,p2.head_sprite_y,p2.body_sprite0=1,0,9,80,40,0,2,75,80,16,0

 p2.y=20

 p2.food={}
 p2.food[1]={}
 p2.food.x=128
 p2.food[1].spr=8
 p2.food[1].offset=0
 p2.food[1].y=3*sin((t+p2.food[1].offset)/50)+p2.y+49

 p2.table_color,p2.condition,p2.winner,p2.t=6,0,false,0

 p2.body_x,p2.body_y,p2.head_x,p2.head_y=30,p2.y+23,0,0

 p2.head_y0=p2.y+10
 
--

p2.body_sprite_x,p2.body_sprite_y,p2.body_w,p2.body_h,p2.head_sprite_x=0,96,40,32,p2.head_sprite_x0
  text1,text2,text3,text4,text5,text6,text7,text8,text9,text10,text11,text12,text13,text14,text15,text16,text17,text18,text19,text20={str="in the year 20xx...",i=0},{str="animals have gone extinct.",i=0},{str="there is no more meat in the",i=0},{str="world.",i=0},{str="old ryan: \"t\73\77\69 \70\79\82 \77\89 \68\65\73\76\89",i=0},{str="\82\65\84\73\79\78 \79\70 s\79\89\76\69\78\84...\"",i=0},{str="\"barf!",i=0},{str=" t\72\65\84 \84\65\83\84\69\83 \68\73\83\71\85\83\84\73\78\71!\"",i=0},{str="\"i \67\65\78'\84 \83\84\65\78\68 \69\65\84\73\78\71",i=0},{str="\83\89\78\84\72\69\84\73\67\83 \65\78\89 \76\79\78\71\69\82.\"",i=0},{str="\"i \77\85\83\84 \79\78\67\69 \65\71\65\73\78 \80\82\79\86\69 i \65\77",i=0},{str="\84\72\69 \66\69\83\84 \69\65\84\69\82 \73\78 \84\72\69 \87\79\82\76\68.\"",i=0},{str="\"i \87\73\76\76 \84\82\65\86\69\76 \66\65\67\75 \73\78",i=0},{str="\84\73\77\69, \87\72\69\78 \70\73\78\69 \66\69\65\83\84\83 \83\84\73\76\76",i=0},{str="\82\79\65\77\69\68 \84\72\69 \76\65\78\68 \70\82\69\69\76\89,",i=0},{str="\"\84\79 \68\73\78\69 \79\78 \84\72\79\83\69 \83\85\67\67\85\76\69\78\84",i=0},{str="\67\85\84\83 \79\78\67\69 \65\71\65\73\78, \65\78\68 \84\79",i=0},{str="\67\72\65\76\76\69\78\71\69 \84\72\69 \71\82\69\65\84\69\83\84",i=0},{str="\69\65\84\69\82 \79\70 \65\76\76 \84\73\77\69:",i=0},{str="\77\89\83\69\76\70!\"",i=0}
end

function title_init()
 mode,logo_x,t_title,title_flag=1,128,100,false
end

function instructions_init()
 mode,p1.wins,p2.wins,ring_color,p1.ready,p2.ready,t_ready=2,0,0,ring_colors[flr(rnd(3))+1],false,false,40
 music(26)
end

function crowd_init(p)
 for col=1,16 do
  local index=flr(rnd(3))+1
  p.crowd[col]=crowd_sprite[index]
 end
end

function game_init()
 mode,t,game_t,wait,round_end,p1.crowd,p2.crowd=3,0,99,0,false,{},{}

 crowd_init(p1)
 crowd_init(p2)

 p1.food,p2.food={x=128},{x=128}

 init_food(p1)
 init_food(p2)
 p1.hunger,p2.hunger,p1.table_color,p2.table_color,p1.condition,p2.condition,p1.winner,p2.winner,p1.t,p2.t,p1.name,p2.name=0,0,14,10,0,0,false,false,0,0,"    ryan","old ryan"

 p2.y=65
 p2.head_y0,p1.body_x,p1.body_y,p1.head_x,p1.head_y,p2.body_x,p2.body_y,p2.head_x,p2.head_y=p2.y+10,30,23,0,0,30,88,0,0
 p1.body_sprite_x,p1.body_sprite_y,p1.body_w,p1.body_h,p1.head_sprite_x,p2.body_sprite_x,p2.body_sprite_y,p2.body_w,p2.body_h,p2.head_sprite_x,p1.flawless,p2.flawless,p1.combo,p2.combo,p1.bread,p2.bread,p1.should_bread,p2.should_bread,p1.bread_offset,p2.bread_offset,p1.display_combo,p2.display_combo,p1.combo_level,p2.combo_level,p1.display_combo_y,p2.display_combo_y=0,96,40,32,p1.head_sprite_x0,0,96,40,32,p2.head_sprite_x0,true,true,0,0,0,0,true,true,0,0,0,0,0,0,p1.y+30,p2.y+30

prevbtn_p1_2,prevbtn_p1_3,prevbtn_p2_2,prevbtn_p2_3=nil,nil,nil,nil

end

function round_end_init()
 mode,t,mario_x,mario_t,t_ready,p1.ready,p2.ready=4,0,128,0,40,false,false
 sfx(6)
 if(game_t==0) then
  if(p1.hunger>p2.hunger) then
   p1.wins+=1
   p1.winner=true
  elseif(p2.hunger>p1.hunger) then
   p2.wins+=1
   p2.winner=true
  end
 end
end

function win_screen_init()
 t,mode=0,5
 music(24)
end

--modes------------------------------

function _init()
 intro_init()
end

function _update60()
 if(mode==0) then
  intro_update()
 elseif(mode==1) then
  title_update()
 elseif(mode==2) then
  instructions_update()
 elseif(mode==3) then
  game_update()
 elseif(mode==4) then
  round_end_update()
 elseif(mode==5) then
  win_screen_update()
 end
end

function _draw()
 if(mode==0) then
  intro_draw()
 elseif(mode==1) then
  title_draw()
 elseif(mode==2) then
  instructions_draw()
 elseif(mode==3) then
  game_draw()
 elseif(mode==4) then
  round_end_draw()
 elseif(mode==5) then
  win_screen_draw()
 end
end


-- particle system constructor -------------------------

function make_barf_ps(ex,ey,py)
 local ps = make_psystem(2,3, 1,2,0.5,0.5)
 
 add(ps.emittimers,
  {
   timerfunc = emittimer_burst,
   params = { num = 5}
  }
 )
 add(ps.emitters, 
  {
   emitfunc = emitter_point,
   params = { x = ex, y = ey, minstartvx = -3, maxstartvx = 0, minstartvy = -3, maxstartvy= -2 }
  }
 )
 add(ps.drawfuncs,
  {
   drawfunc = draw_ps_pixel,
   params = { colors = {11} }
  }
 )
 add(ps.affectors,
  { 
   affectfunc = affect_force,
   params = { fx = 0, fy = 0.3 }
  }
 )
 add(ps.affectors,
  { 
   affectfunc = affect_stopzone,
   params = { zoneminx = 20, zonemaxx = 127, zoneminy = py+55, zonemaxy = py+62 }
  }
 )
end

function make_dead_food_ps(ex,ey,dead_food_spr,py)
 local ps = make_psystem(2,3, 1,2,0.5,0.5)
 
 add(ps.emittimers,
  {
   timerfunc = emittimer_burst,
   params = { num = 1}
  }
 )
 add(ps.emitters, 
  {
   emitfunc = emitter_point,
   params = { x = ex, y = ey, minstartvx = -1, maxstartvx = 0, minstartvy = -3, maxstartvy= -2 }
  }
 )
 add(ps.drawfuncs,
  {
   drawfunc = draw_ps_dead_food,
   params = { sprite = dead_food_spr }
  }
 )
 add(ps.affectors,
  { 
   affectfunc = affect_force,
   params = { fx = 0, fy = 0.3 }
  }
 )
 add(ps.affectors,
  { 
   affectfunc = affect_stopzone,
   params = { zoneminx = 0, zonemaxx = 127, zoneminy = py+53, zonemaxy = py+60 }
  }
 )
end


-- particle system library -----------------------------------
particle_systems = {}

function make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)
 local ps = {}
 -- global particle system params
 ps.autoremove = true

 ps.minlife = minlife
 ps.maxlife = maxlife
 
 ps.minstartsize = minstartsize
 ps.maxstartsize = maxstartsize
 ps.minendsize = minendsize
 ps.maxendsize = maxendsize
 
 -- container for the particles
 ps.particles = {}

 -- emittimers dictate when a particle should start
 -- they called every frame, and call emit_particle when they see fit
 -- they should return false if no longer need to be updated
 ps.emittimers = {}

 -- emitters must initialize p.x, p.y, p.vx, p.vy
 ps.emitters = {}

 -- every ps needs a drawfunc
 ps.drawfuncs = {}

 -- affectors affect the movement of the particles
 ps.affectors = {}

 add(particle_systems, ps)

 return ps
end

function deleteallps()
 for ps in all(particle_systems) do
  del(particle_systems, ps)
 end
end

function update_psystems()
 local timenow = time()
 for ps in all(particle_systems) do
  update_ps(ps, timenow)
 end
end

function update_ps(ps, timenow)
 for et in all(ps.emittimers) do
  local keep = et.timerfunc(ps, et.params)
  if (keep==false) then
   del(ps.emittimers, et)
  end
 end

 for p in all(ps.particles) do
  p.phase = (timenow-p.starttime)/(p.deathtime-p.starttime)

  for a in all(ps.affectors) do
   a.affectfunc(p, a.params)
  end

  p.x += p.vx
  p.y += p.vy
  
  local dead = false

  if (p.x<0 or (p.y>63 and p.y<80) or p.y>127) then
   dead = true
  end

  if (timenow>=p.deathtime) then
   dead = true
  end

  if (dead==true) then
   del(ps.particles, p)
  end
 end
 
 if (ps.autoremove==true and count(ps.particles)<=0) then
  del(particle_systems, ps)
 end
end

--------

function update_psystems_intro()
 local timenow = time()
 for ps in all(particle_systems) do
  update_ps_intro(ps, timenow)
 end
end

function update_ps_intro(ps, timenow)
 for et in all(ps.emittimers) do
  local keep = et.timerfunc(ps, et.params)
  if (keep==false) then
   del(ps.emittimers, et)
  end
 end

 for p in all(ps.particles) do
  p.phase = (timenow-p.starttime)/(p.deathtime-p.starttime)

  for a in all(ps.affectors) do
   a.affectfunc(p, a.params)
  end

  p.x += p.vx
  p.y += p.vy
  
  local dead = false

  if (p.x<0 or p.y>82) then --fix me!
   dead = true
  end

  if (timenow>=p.deathtime) then
   dead = true
  end

  if (dead==true) then
   del(ps.particles, p)
  end
 end
 
 if (ps.autoremove==true and count(ps.particles)<=0) then
  del(particle_systems, ps)
 end
end


-------


function draw_ps(ps, params)
 for df in all(ps.drawfuncs) do
  df.drawfunc(ps, df.params)
 end
end


function emittimer_burst(ps, params)
 for i=1,params.num do
  emit_particle(ps)
 end
 return false
end


function emitter_point(p, params)
 p.x = params.x
 p.y = params.y

 p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
 p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function draw_ps_dead_food(ps, params)
 for p in all(ps.particles) do
  if(t%2==0) spr(params.sprite,p.x,p.y)
 end 
end

function draw_ps_pixel(ps, params)
 for p in all(ps.particles) do
  pset(p.x,p.y,11)
 end 
end

function affect_force(p, params)
 p.vx += params.fx
 p.vy += params.fy
end

function affect_stopzone(p, params)
 if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
  p.vx,p.vy=0,0
 end
end

function emit_particle(psystem)
 local p = {}

 local e = psystem.emitters[flr(rnd(#(psystem.emitters)))+1]
 e.emitfunc(p, e.params) 

 p.phase = 0
 p.starttime = time()
 p.deathtime = time()+rnd(psystem.maxlife-psystem.minlife)+psystem.minlife

 p.startsize = rnd(psystem.maxstartsize-psystem.minstartsize)+psystem.minstartsize
 p.endsize = rnd(psystem.maxendsize-psystem.minendsize)+psystem.minendsize

 add(psystem.particles, p)
end
__gfx__
ccccccccccccccc000000ccccccccccccccccccc00000000d5d5d5d5000000003bbbbbb30005440000770000000054400004000000000050003b3b3005444450
ccccccccccccc00000000000cccccccccccccccc000660005d5d5d5d00000000b33333350054ff0077887770000544440004bb0000005440b3b3b3b0549fff45
ccccccccccc00000000000000ccccccccccccccc00000000dddddddd00000000b333333554ff000478888887005444490084b0000002e5453b3b3b3049fffff4
ccccccccc000000000000000000ccccccccccccc555555555d5d5d5d00000000b33333354f40004f788778870044449408888880022e2224b3b3b30049fffff4
ccccccc000000000000000000000cccccccccccc5d5d5d5ddddddddd00000000b3333335f40004f57887788700644940088887802e7222203b3b3b0054ffff45
ccccc000000000000000000000000ccccccccccc55555555dd5ddd5d00000000b333333500004f507788887f0776900008888e802222221053b3b330049fff40
cccc000000000000000000000000000cccccccccd5d5d5d5dddddddd00000000b333333500044f006f7777f677f0000008888880122221000000533304999940
ccc00000000000000000000000000000cccccccc5d5d5d5dd5ddd5dd000000003555555305f5f00006ffff600f60000000828800011110000000053305444450
ccc00000000000000000ff9000000000cccccccc1111111011111111111111111111111104044000087700080000440000000000001200040000000005440450
cc0000000999ffffffffff9f9f9000000ccccccc111111110111111111111111111111114000f0400088007000ff0004004080bb0121004453000000549f0045
cc00000099f9ffffffffffffff99900000cccccc11055510101110011111111111111111004000047000088700ff440904888000012222043b00300049f50ff4
cc0000099f9f9ffffffffffffff9990000cccccc11000551001110111111100111100111f440000f7800088700044404088ff0802222f002b303b30049ff05f4
c000000999f9fffffffffffffffff99000cccccc100555050011001100010001110011114f04000078800887f004944088ff008802f00f223b300b0554f0ff45
c00000099f9fffffffffffffffff9f90000ccccc1005050500010101005000051100100000004f4077008877ff00400088f00f882200f1215000003304905f40
c000000999fffffffffffffffffff990000ccccc0005055500010000055551051005151040004004f070887fff00094088000f88220012110b30033304509940
c00000099ffffffffffffffffffff990000ccccc0005550500005000050050550155550004f00040f000f87f0ff00000000088800200002253b3033505405450
c000000999ffffffffffffffffff9f99000ccccc0005555500000500050550150555055000000000999999666999999999999996669999999999996669999999
c00000999ffffffffffffffffff9f999000ccccc0055555500005500055550050055550000000000999666666669999999996666666699999996666666699999
c000009990000fffffffffffff9f9f99000ccccc0005500550000550055155550055055000000000996666666666999999966666666669999966666666669999
c000099900000000fffffffffffff999000ccccc0005550500505550055055555055550000000000966666666666699999666666666666999666666666666999
00f009900fffff000ffff00000999900000ccccc0055555550550550055005555555550000000000656666666666669996566666666666696566666666666699
09f90999ff0000f00fff0000f0000990000ccccc0055555505055550055555555555555000000000656666666666669996566666666666696566666666666699
0f09099ff00700700ffff0f00fff0090000ccccc5055555555055550055555555555555500000000606ffffff66666699606ffffff666666606ffffff6666669
0900099fffffffff00ff0f70000ff090000ccccc555555555555555555555555555555550000000060ffffffff666669960ffffffff6666660ffffffff666669
0900099fffffffff0ff0999f0770f9900990cccc1111111111111111111111111111111100000000660fffffff6666699660fffffff66666660fffffff666669
099009f9ffffffff0ffff99ffffff990ff90cccc111111101155555501111111001100110000000066f0fffffff6656996660ffff6ff665666f0fffffff66569
0990099ffffffff00ff00f9ffffff990ff0ccccc110151100150050001111100001100110000000066660fff66f60f69966770ff6f6f60f666660fff66f60f69
099909fffffffff0ffff0ff99ffff990f90ccccc110055000050050011111010000110010000000066ff50f6ff60ff699677750fffff0ff666ff50f6ff60ff69
c09999ffffffff90ffff09fffffff90ff90ccccc100105010055555550111010000101000000000096ff5f000006ff69997575f000006ff696ff5f000006ff69
c0990fffffffff990ff0099ffffff99ff0cccccc10000500105005005501101000000100000000009675fff00006ff69997775ff00006ff69675fff00006ff69
cc0900ffffff000090099999ffff990f90cccccc0000050001500500550111000000101000000000967f5fff0806f669997775fff0506f66967f5fff0806f669
ccc0000fff000000099000ffffff90090ccccccc005505500055555555000100000000000000000096ff5ffffff00599996775ffffff005996ff5ffffff00599
cccc00000f090000000000000fff00090ccccccc005500550055050055000000000000050000000096f5ff5fff666699996f5ff5fff6666996f5ff5fff666699
cccc00000f000777777700000f990090cccccccc0055505500500500050000000000005500000000996655666f6666999996655666f666699966556666666699
cccc0000000007777777777009900000cccccccc0000555550550555550000000000005000000000996666666666699999966666666666999966666666666699
cccc000000000000777770000900000ccccccccc000005055050050555000000000005500000000099667777766669999996666666666699996666fffff66699
ccccc0000000fff0000000f0000000cccccccccc0050555550550550550000000000055000000000996666666666999999966600666669999966666666666699
ccccc00000000ffffffffff0000000cccccccccc0550555555555555550000005500055000000000999666666669999999996600066699999996666666666999
cccccc00000009990099900000000ccccccccccc0555555555550055500000055500055500000000999666666669999999996666666699999996666666669999
ccccccc000000000000900000000cccccccccccc5555555555555555555555555555555500000000999966666699999999999666666999999999666666999999
cccccccc0000000000000000000ccccccccccccc0000000000000000000000000000000000000000999999444999999999999994449999999999994449999999
cccccccc000000000000000000cccccccccccccc0000000000000000000000000000000000000000999444444449999999994444444499999994444444499999
ccccccccc0000000000000000ccccccccccccccc0000000000000000000000000000000000000000994444444444999999944444444449999944444444449999
cccccccccc00000000000000cccccccccccccccc0000000000000000000000000000000000000000944444444444499999444444444444999444444444444999
ccccccccccc000000000000ccccccccccccccccc0000000000000000000000000000000000000000444444444444449994444444444444494444444444444499
cccccccccccc0000000000cccccccccccccccccc0000000000000000000000000000000000000000444444444444449994444444444444494444444444444499
cccccccccccccc000000cccccccccccccccccccc0000000000000000000000000000000000000000444ffffff44444499444ffffff444444444ffffff4444449
cccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000044ffffffff444449944ffffffff4444444ffffffff444449
0000000000000000000000000000000000000000000000000000000000000000000000000000000044ffffffff444449944ffffffff4444444ffffffff444449
0000000000000000000000000000000000007000000007000700000000000000000000000000000044fffffffff4444994444ffff4ff444444fffffffff44449
000000000000000000077700000770000077770000777700077777700070000000770000007770004444fff444f44f49944fffff4f4f44f44444fff444f44f49
0077770000777700007777000077770007777000077777000077770000777770007777000077770044ff4fffff44ff49944ff4ffffff4ff444ff4fffff44ff49
0077770000777700007777000777770000770000000700000000000000777700007777000077770094ff4fff7ff4ff49994f74fff7ff4ff494ff4fff7ff4ff49
007777000077770000777000007770000000000000000000000000000000770000077700007777009474fff747f4ff4999777fff777f4ff49474fff747f4ff49
00777700007777000077000000000000000000000000000000000000000000000007700000077700947f4fff77f4f44997777477777f4f44947f4fff77f4f449
0077770000777000000000000000000000000000000000000000000000000000000000000000000094ff4ffffff444997777f47777ff444994ff4ffffff44499
0000000000000000000000000000000000000000000000000000000000000000000000000000000094f4ff4fff444499747f47777ff4444994f4ff4fff444499
00005500000005000000000000060000000660000006660000006600000000000005000000055500994444444f4444997774474744f44449994444444f444499
00066550000665500066655000666000006666000006660000066660005666600055600000066600994444444444499999944777444444999944444444444499
0066660000666650006666500066665000666600000666000066666000566660005666000006660099447777744449999994444444444499994444ffff444499
06666000006666000066665000066550000665500006650000556600005566600006666000066600999447774444999999994447474449999994444444444999
00660000006600000000000000006500000655000005550000055000000000000000660000006600999944444449999999999474744499999999444444449999
00000000000000000000000000000000000000000000000000000000000000000000000000000000999944444499999999999444444999999999444444999999
00000000000000000000000000000000000000000000000000000000000000000000000000000000999994444999999999999944449999999999944449999999
9900009999000099000999009900009999999999000000000000000099999999999999999999999999444499999999999999999999999999999f499999999999
9900009999900099099999999900009999999999000000000000000099999999999999999999999994ffff49999999999999999999999999999f499999999999
990000999999009999900099990000990009900000000000000000009999999994449999999999444ffffff4999999999999999999999999fffff49999999999
98000089898980899800000089898989000890000000000000000000999999994fffffffffffffffffffffff49999999999999999944ffffffffff4444999999
89000098980898988900000098989898000980000000000000000000999999944ffffffffffffffffffffffff49999999999999944ffffffffffffffff449999
880000888800888888800088880000880008800000000000000000009999994ffffffffffffffffffffffffff499999999998888fffffffff4ffffffffff4999
888888888800088808888888880000880008800000000000000000009999994ffffffffffffffffffffffffff4499999999888888ffff4ffff4ffffffffff499
08888880880000880008880088000088000880000000000000000000999994fffffffffffffffffffffffffffff49999998888884ff44ffffffffffffff4f499
99990000000000999999999000000000000000000000000000000000999994ffffffffffffffffffffffffffffff4999998888884fffffffffffffffffff4f49
9999000000000999999999990000000000000000000000000000000099994fffffffffffffffffffffffffffffff4999988888884fffffffffffffffffff4f49
99990000000009999000999900000000000000000000000000000000999944ffffffffffffffffffffffffffff4ff499988888884fffffffffffffffffff4f49
999900000000999900000999900000000000000000000000000000009994fffffff4fffffffffffffffffffffff4f49998888884ffffffffffffffffffffff49
999900000000999900000999900000000000000000000000000000009994fffff4f4ffffffffffffffff4f4ffff4f499888888488fffff4fffffff4fffffff49
999900000000999900000999900000000000000000000000000000009994ffffff4ffffffffffffffffff4fffffff499848884888fffff4fffffff4fffffff49
99990000000099990000099990999999999999000000000000000000994fffffff4ffffffffffffffffff4fffffff499884448888cffff4fffffff4f4fffff49
99990000000099990000099990999999999999000000000000000000994ff888888fffffffffffffffff48888ffff49988884888ffccff4ffffffff4ffff4f49
99990000000099990000099990000990099000000000000000000000994f88888888fffffffffffffff48888888f4f498888888ffffccf4fffffff4ffffff499
9999000000009999000009999000099009900000000000000000000094ff888888888fffffffffffff8488888884fff4888888f4fffccc4fffffff4ffffff499
9999000000009999000009999000099009900000000000000000000094f8888888888ffffff6666ff848888888848ff4488884ff4fffc4c4fffff4fffffff499
9999000000009999000009999000099009900000000000000000000094f8888888888ffffff4f66666488888888848f4844448ff4f444ccc4444f4fffffff499
9999000000009999000009999000099009900000000000000000000094f8888888884ffcfff466fff8488888888848f4888888ff4ffffccccffff4fffffff499
999900000000999900000999900009900990000000000000000000004f888888884894ffccf4fffff8488888888848498888444ff4ffffcc888888fffffff499
898900000000898900000898900008900890000000000000000000004f888888848894fff44c4444ff488888888484998444f4fff4f444444444888ffff4f499
989800000000989800000989800009800980000000000000000000004884888849999944ffccccffff488888888999994ffffffff448888888884488ffff4999
888888888888088880008888000008800880000000000000000000004888448899999994fff444cffff48888889999994fffffff4488888888888448ffff4999
888888888888088888888888008888888888880000000000000000004ff8889999999994f44f4c44fffff888899999994ffffff448888888888888488ff44999
888888888888008888888880008888888888880000000000000000004ffff49999999994ffff4fcccffffff49999999994ffff4848888888888888848ff49999
000000000000000000000000000000000000000000000000000000004ffff49999999994fff00000000ffff499999999994ff48488888888888888848ff49999
0000000000000000000000000000000000000000000000000000000094ff4999999999990000000000000000999999999994488488888888888888848f4f4999
0000000000000000000000000000000000000000000000000000000099449999999999900000000000000000999999996666988488888888888888848f4f4999
0000000000000000000000000000000000000000000000000000000099999999999999005555555555555500999999999996688488888888888888848f4f4999
00000000000000000000000000000000000000000000000000000000999999999999990505555555555550509999999966666664888888888888888484ff4999
99999999999994ffff4444999999999999999999999999999999999999f49999999999993333888888833333333fff3399966884888888888888848449999999
99999999999444fffffff4449999999999999999999999999888899999f4449999999999333888888888333333fffff366666984888888888888848499999999
99999999944ff4fffffff4ff4499999999999999999999998888889999ff4f44999999993388888888803333330fffff99999994888888888888848999999999
999999944fffffffffffffffff4449999999999999999998888888899f4f4fff4499999933888808888083333ff0ffff99999994888888888888849999999999
9999994ffffffffffffffffffffff499999999999999448888888889ff4fffffff44999933888080888808333ff00fff99999999488888888888499999999999
999994ffffff4fffffff444fffffff49999999999994ff8888888888ffffffffffff499933800000008888333f0f0fff99999999948888888884999999999999
99994ffffffff444ff44ff6f6f6ffff499999999994fff88888888888ff4ffffff4ff49930088888880088833ffffff399999999999888889999999999999999
9994444fffffffffffffff6f6f6fffff49999999994f848888888888844ffffffff4f499088088888088088333ffff3399999999999999999999999999999999
994888848ffffffff4ffff6f6f6fffff49999999994884884888888848fffffffff4f499300f0fff0f0f00333000000311111111666666666666666666666666
9948888848fffffff4ffff66666fff4ff49999999948884848888884888fffffffffff4930ff0fff0fff00033077770310101010666666666666666666666666
9488888848fffffff4fffff666fffff4f499999994888884488888488884ff4fffffff4930f77fff77ff00033000000311111111000000000000000000000000
9488888848fcfffff4ffffff6f4ffff4ff4999999488888884448848884f4f4f4fff4f4930f70fff07ff00033077770310101010444444444400000404040400
4888888848ffccfff4ffffff6f44ffffff4999999488888888fc444884fff4f4ffff4f4933f70fff07ff0f033077770311111111440000444044440004444400
4888888848fffccff4ffff848888ffffff4999994888888888ffccc484ffff4fffff4f4933f0ffffffffff033077770310101010404444044004404004000404
4888888884fffccc4f4ff84888888ffffff499994888888884fffccc4ffffff4fff4f4993f0ffffff0ffff033077770311111111040440404044444004000400
4888888844ffffc4ccf488488888884ffff499994888848884ffffc4c4fffff4fffff4993f0ffffff0f0f0033077770310101010044404404040004040444040
4888888444ff444cc4cf848888888844fff49999488884884ff4444cc4ffffffffff4999300ffffff000f0307777770300000000000000000099988889999999
4888884f44fffffcc4cf8488888888484fff4999488888494ffffffcc44ffffffff499993f00ffff000f03077770770300000000000000000099888888999999
4884444f494fffff4c448488888888484fff49999488844994ffffff4c4fffffff4499993300000000ff00777777003300000000000000000098888888899999
9488484f494ffff4f4cc8488888888484fff49994844489994fffff4f4c4fffff4f4999933f000007ff077777777703340000004440004440088888888899999
9444884f494fff4ff4ccf888888884884fff49994888849994ffff4ff4cc4fff4ff49999333ff777ff0777777777033340444004444004040088888888889999
948884f44994ff4ff4cccf8888848484fff4999994884f99994fff4ff4cc4fff4f4499993333fffff07777777777033304444040404404440088888888888999
94884fff4994f4fff4fccf4888448449444999994f44ff99994ff4fff4ccf444f4f4999933070077077777777770333304040044444044400088888888888999
9944fff49994f4fff4ffccf4ff4f4999999999994fffff99994ff4fff4fccff4ff44999937000077077777777703333304404044004000440088488888884899
994ffff49994f4fff4fffcf4f4f44999999999994ffff499994ff4fff4ffcff4f4f49999000000000000000000000000dddddddddddddddd0048488888848889
9994ff499994fffff4ffffcfff4f4999999999994ffff499994ffffff4fffcffff499999000000000000000000000000dddd77777777dddd0094488888488884
999944999994ffff0000000ffff499999999999994ff4999994ffff0000000fff4499999000000000000000000000000d77777777777777d0099944488488849
99999999999000000000000000009999999999999944999999000000000000000009999900000000000000000000000077767777777767770099999944488499
999999999990000000000000000009999999999999999999990000000000000000009999000000000000000000000000077766666666777d0099999999948499
9999999999050555555555555050099999999999999999999050555555555555050099990000000000000000000000005007777777777ddd0099999999994999
999999999900555555555555550509999999999999999999900555555555555550509999000000000000000000000000dd5500000055dddd0099999999999999
999999999905055555555555505009999999999999999999905055555555555505009999000000000000000000000000dddddddddddddddd0099999999999999
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005757570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005757570057000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000057575757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010700000d6111a6111c6111d6211d6211d6211c6211b6211a6211961118611186111761116611166111662116621176211862118621196211b6111b6111b6111b6111b6111a6111962117621166211261111611
010300001217012170121701117013100101001310015100000001010013100151001010013100151001010011100151001810015100181001110015100181001110011100151001810013100171001a10017100
0103000012170121701117012100111000f1700e070000000000034100341003410032100341003210034100321002f1002f1002b1002b1002b10000000000000000000000000000000000000000000000000000
0108000017553121001110012100111000f1000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0109000004570025700157312100111000f1000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000000770047700705002050050500905004050070500c05010050130500e05011050150501005013050180501c0501f0501a0501d000210001c0001f0000000000000000000000000000000000000000000
010a00002b5702b5702b5752b5702b5702b5752b5702b5702b5750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00002b5702b5702b5750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000e0732b5002b5052b5002b5002b5052b5002b5002b5052b5002b5002b5050a0000c0000c000166002b5002b5002b5052b5002b5002b5052b5002b5002b5052b5002b5002b5051f3021f3021f3021f305
010f00003c600306003060030600246002460024600186002b3022c3022b3022c3022b3022c3022b3022c3022c3022d3022c3022d3022c3022d3022c3022d3021e3001e3001e3001e3051e3001e3051e3001e305
011400001163311633116051163328302116331163328302283022800228002116031163311633116031163311603116331163326302243022430224302243022330223302233022330221302213022030220302
011400001a5501c5501c5501d5501d5501d5521d5521d5521d5521d5421d5421d5421d5421d5421d5421d5321d5321d5321c5501c5501c5501c55018550185503030230302303023030200000000000000000000
011400001155011550115521155211552115521154211542115421154211542115421153211532115321153211532115321152211522115221152211522115220000000000000000000000000000000000000000
011400002155021550215522155221552215522154221542215422154221542215421f5501f5501f5521f5521f5521f5521f5521f5421f5421f5421f5421f542060000600012000000000b000000001200000000
01140000110531105308000110530900011053110530b0002963300000116330000011053110531300011053110031105311053040052963307005116330b0050c0000900000000000000c000000000000000000
011400000205002050020500205002050020500204002040020400204002040020400203002030020300203002030020300202002020020200202002020020203c605000003c6053c6053c605000003c6053c605
011400003c6103061130611306112461124611246111861118611186110c6110c6110c6110c6110c6110c6150c6000c6000c6000c6000c6000c6000c6000c600000000000000000000003c6003c6053c6053c600
011400000202002020020200202002020020200202002020020200202002020020200201102010020100201002010020100201002010020100201002010020150e4000e4051d2021d2051d2021d2021c2021c202
011400001355013550135521355213552135521354213542135421354213542135421353213532135321353213532135321352213522135221352213522135220c4000c4050c4000c4050c4000c4050c4000c405
01140000115501155011552115521155211552115421154211542115421154211542115321153211532115321153211532115221152211522115220e5520e5520a4000a4050a4000a4050a4000a4051a2021a202
011400001155011550115521155211552115521154211542115421154211542115421055010550105521055210552105521054210542105421054210542105420d4000d4050d4000d4050d4000d4050d4000d405
010400001d330243312430002104091040e10402104091040e10402104091040e10402104091040e10402104091040e10402104091040e10402104091040e1040f4000f4050f4000f4050f4000f4050f4000f405
010b0000180532b6070060500605180533760537625006050060500605180532b605180532b6053762537605180532b607006052b605180532b6053762537605006052b600180532b605180532b6043762537605
010b0000180532b6070060500605180533760537625006050060500605180532b605180532b6053762537605180532b607006050060518053180533762537605180532b600180532b605180532b6043762537605
010b00001043010430104300e400104200e403044350e10304435021000443509100044350b302044350a2020e4300e4300e4300c4050e4200c4020243500405024350b402024350940202435004000243516202
010b00000c4300c4300c430213020c42000000004350000000435000000043500000004351c302004351c3020e4300e4300e4301a3020e42000000024350000002435043020243504305024351c302024551c305
010b0000174301743017430100001742021302154051f302154050000015405080001540521302154052130215430154301543013302154200000013405000001340524302134052430213405233021340523302
010b000013430134301343018302134201c3001140500000114050000011405183021140518302114051730215430154301543000000154200000013405000001340500000134050000013405000001340500000
010b00000b4300b4300b430263020b430263020b435263020b435263020b435263020b435263020e43026302104301043010430213021043026302044352d3020e4300e4300e4302b3020e430297020243529302
010b00000b4320b4320b4320b4320b4320b4320b4320b4320b4220b4220b4220b4220b4220b4220b4220b4220b4120b4120b4120b4120b4120b4120b4120b4120b4120b4120b4120b4120b4120b4000e4300b400
010b000012430124301243026302124300b400064351240006430263020643026302064302630206435263021743017430174302130217430263020b435293021543015430154302830215430283020943526302
010b00001243212432124321243212432124321243212432124221242212422124221242212422124221242212412124121241212412124121241212412124121241212412124121241212412293021543012400
010b0000180532b6070060500605180033760518053006050060500605180032b605180032b6051805337605180032b607006052b605180032b60518053376052100321003210531f0531d0531f0031d05337605
010b000023325213251f325213252432521325233252432523325213251f3252132523325213251f3252132523325213251f325213252432521325233252432523325213251f3252132523325213251f32521325
010e00001a0331c0032f6001f003240331a6050f6023d6021c0332f6022a602256051003319602126020b6051c0333a602366022100323033230032160018033180331f003180331f0030e0330f0031c60015600
010e00003e0111c0032f6001f003240111a6050f6023d6021c0112f6020d01125605100001c0001c0110b605280113a602366022100317011230031301124000180001f0033c0111f0030e0111a0111f00021000
010d00001755021550215002055020550205502055020550205502055020550205502055020550205502055020550205502055020550235502355023550235501755017550175501e5501e5501c5501a55015550
010d0000175551755020500205002050020500205002050020500205002050020500205002050020500205002350023500235002350023500235001e5001e5001e5001c5001a5001550017505175001700515005
010d0000186001a6001c6001d6001d6001d6001c6001750017550205501f5001f5501f5501f5501f5501f5501f5501f5501f5501f5501a5501a5501a5501a5501f5501f5501f5501f5501e5501c5551c5551c555
010d000023555235501c50029600216001a6050f6023d602366022f6022a602256051c60219602126020b605066023a60236602306052960218602216001c6001760013600356003160026600216001c60017500
010d00000e0532a6352a6150e0530e0031d3051a0331a03318033180331d304150331a033180331703315033356153561535610356150e0531d3050e0031c3000e0531a3042a6352a6150e0531a3042a6352a615
010d00002a6352a6352a6151f3051d3021d3051c3001c3001c3050f2050f2000f2050f2000f2050f2000f2050f2000f2050f2000f2050f200183001a3001c3001d3021d3021d3051c3021c3021a3001830218305
010d00000b1200e0000e0000b1200b1200b1200b1200b1200b1200b1200b1200b1200b1200b1200b1200b12507120071200712007125071200712007120071201711017110171151700017110171101711017115
010d00000e0000e0000e0000e0000e0000e0000e0000e000093000930009300093000930009305093050930505300053000530005300053050530505300053050730007300073050730007305073050530005305
011400003c610306113061130611246112461502050020500205002050020500205004050040500405004050040500405005050050500505005050050500505019202243022430224302266000e6000260002600
011400000a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a050020500205002050020500205002050040500405004050040500405004050227052b705287052b705227052b705287052b705
011400000505005050050500505005050050500505005050050500505005050050500405004050040500405004050040500405004050040500405004050040501f7052970528705297052b705297052870526705
011400000a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500005000050000500005000050000500205002050020500205002050020500c0001000013000180000c000100001300018000
01140000070000700027702277022770200000000500005000050000500005000050020500205002050020500205002050040500405004050040500405004050287022b70228702287022b702297022970229702
011400000005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000502d7022b70229702287022b702297022870227702
0103000037640336502f65029660216601a6550f6523d652366422f6422a632256251c63219632126220b625066223a62236622306352963218632216411c6411767113671356113165126651216111c65115641
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
010300000c2721027213272182720c2721027213272182720e27211272152721a2721027213272172721c27213270172701c2701f2700c0001000013000180000c0001000013000180000c000100001300018000
0103000037620336302f63029640216401a6350f6323d632366222f6222a612256051c61219612126120b615066123a61236612306152961218612216211c6211764113641356003163126631216001c63115615
__music__
01 09 0a 10 0f
00 09 0a 43 11
00 09 0e 0b 2c
00 09 0e 0c 2d
00 09 0e 0b 2c
00 09 0e 0d 2e
00 09 0e 0b 2f
00 09 0e 12 30
00 09 0e 13 2f
00 09 0e 14 31
00 09 0a 0f 10
04 09 0a 11 44
01 16 18 1a 44
00 17 19 1b 44
00 16 18 1a 44
00 17 19 1b 44
00 16 18 21 44
00 17 19 21 44
00 16 18 1a 44
00 17 19 1b 44
00 16 19 1b 44
00 17 1c 1e 44
00 16 19 1b 44
02 20 1d 1f 44
00 24 26 28 2a
04 25 27 29 2b
03 22 23 43 44
00 41 42 43 44
00 1e 42 24 25
00 13 16 1a 25
02 1c 1d 1b 26
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
