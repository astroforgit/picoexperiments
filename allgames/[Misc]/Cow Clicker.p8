pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 music()
 begin = 208
end

function _update()
 begin -=1
 if(btnp(5) and begin < 0)then
  _update,_draw = cupdate,cdraw
  cinit()
 end
end

function _draw()
 cls(13)
 sspr(48, 0, 16, 16, 32, 32, 64, 64)
 cc = "cow clicker!"
 print(cc,hcenter(cc),16,10)
 cc = "press x to start"
 if(begin < 0) print(cc,hcenter(cc),105,10)
end

function cinit()
 init_keys()
 curs,screen,scrcol,sign,signy,ltimer,money,inv,farm,cows,maids,maidspeed,maidlevel,
 maidstl,maidcost,mtime,bstart,cheeses,cowcost,ccowcost,scowcost,yog1count,yog2count,
 yog3count,vanilla,chocolate,strawberry,tiny,goods,stl,sell,price,selltime,shop,press,
 bord,dbg,prices,win, val
 = 
 0,0,14,{},129,300,0,
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0, 0, 0, 0},{},{},.25,1,32767,10,50,
 100,{},100,750,5000,20,20,20,{},{},{},{},{},{},2,
 {5, 5, 15, 2.5, 10, 8, 3, 12,10,4, 15},45,{false,false,false,false,false,false,
 false,false,false,false,false,false},false,{col=0,p1={x=0,y=0},p2={x=0,
 y=0},d1={x=2,y=2},d2={x=72,y=79}},"",{25, 50, 100, 125, 250, 500, 750, 1500,
 3000, 6200, 12500, 25000, 30000}, false, 1
 
 mcntreset()
 buttercount = bstart
 
 addcow(1)
 btnp = is_pressed
end

function cupdate()
 upd_keys()
 if(btnp(0) and curs == 14) then
  cursor13()
 elseif(btnp(0) and (curs == 13 or curs == 15)) then
  cursor0()
 elseif(btnp(0)
 and(curs ==1
 or curs ==4
 or curs ==7
 or curs ==10)) then
  cursor0()
 elseif(btnp(0) and curs !=0) then
  curs -=1
  if(curs==0) then
   cursor0()
  else
   sfx(2)
   bord.d1.x -= 14
   bord.d2.x -= 14
  end
 end

 if(btnp(1) and curs == 0) then
  curs = 1
  bord.d1.x = 81
  bord.d1.y = 10
  bord.d2.x = 94
  bord.d2.y = 20
  sfx(2)
 elseif(btnp(1) and curs > 0
 and curs <= 11
 and curs !=3
 and curs !=6
 and curs !=9) then
  curs +=1
  bord.d1.x += 14
  bord.d2.x += 14
  sfx(2)
 elseif(btnp(1)
 and curs == 13) then
  cursor14()
 end
    
 if(btnp(2) and curs >3) then
  if(curs <= 12) then
   curs -= 3
   bord.d1.y -= 11
   bord.d2.y -= 11
   sfx(2)
  elseif(curs == 13) then
   curs = 10
   bord.d1.x = 81
   bord.d1.y = 43
   bord.d2.x = 94
   bord.d2.y = 53
   sfx(2)
  elseif(curs == 14) then
   curs = 12
   bord.d1.x = 109
   bord.d1.y = 43
   bord.d2.x = 122
   bord.d2.y = 53
   sfx(2)
  elseif(curs == 15) then
   cursor13()
  end
 end
    
 if(btnp(3) and (curs ==10 or curs ==11)) then
  cursor13()
 elseif(btnp(3)and (curs == 13 or curs == 14)) then
  curs =15
  bord.d1.x = 80
  bord.d1.y = 68
  bord.d2.x = 122
  bord.d2.y = 76
  sfx(2)
 elseif(btnp(3)
 and curs == 12) then
  cursor14()
 elseif(btnp(3) and curs >0 and curs <=9) then
  curs +=3
  bord.d1.y += 11
  bord.d2.y += 11
  sfx(2)
 end
    
 local check = true
 for s=1, #shop do
  if(not shop[s]) check = false
 end
 
 if(curs > 0 and
 curs < 13 and
 screen == 1 and
 check) then
  bord.d1.x = 92
  bord.d1.y = 21
  bord.d2.x = 111
  bord.d2.y = 40
  sfx(2)
  if(btnp(0))then
   cursor0()
  elseif(btnp(5)) then
   cutinit()
  elseif(btnp(3)) then
   cursor13()
  end
 end

 if(curs == 0 and btnp(5)) gotmilk()
    
 if(btnp(4)) then
  setscreen(0, 14)
  cursor0()
 end

 if(curs == 13 and btnp(5)) setscreen(0, 14)
 if(curs == 14 and btnp(5)) setscreen(1, 12)
 if(curs == 15 and btnp(5)) setscreen(2, 15) 

 if(screen ==0) then
  if(curs == 1 and btnp(5)) then
   if(money >= maidcost and maidcost > 0)then
    money -= maidcost
    addmaid()
    mcntreset()
    maidcost *= 2
    if(maidcost < 0 and #maids < 12) maidcost = 20480
   end
  end
  if(curs == 2 and btnp(5)) then
   if(shop[1] and inv[2] > 0 and buttercount <= 1) then
    mcntreset()
    buttercount = bstart
    inv2me1()
    inv[3] += 2
    tinygoods(15)
    tinygoods(15)
   elseif(shop[1] and inv[2] > 0) then
    mcntreset()
    buttercount -= 1
    resetyogurt()
   end
  end
  if(curs == 3 and btnp(5)) then
   if(shop[4] and inv[2] > 0) then
    inv2me1()
    chz = 9000
    if(shop[12])chz=3600
    add(cheeses, chz)
    buttercount = bstart
    resetyogurt()
   end
  end

  if(curs == 4 and btnp(5)) then
   if(money >= cowcost and cowcost > 0 and farm[1] < 16) then
    money -= cowcost
    cowcost = flr(cowcost * 1.5)
    if(cowcost < 0) cowcost = 20480
    addcow(1)
   end
  end
  if(curs == 5 and btnp(5)) then
   if(shop[7] and inv[2] > 0 and yog1count <= 1) then
    mcntreset()
    yog1count = 20
    inv2me1()
    inv[5] += 4
    for i=1, 4 do tinygoods(9) end
   elseif(shop[7] and inv[2] > 0) then
    mcntreset()
    yog1count -= 1
    buttercount = bstart
    yog2count = 20
    yog3count = 20
   end
  end
  if(curs == 6 and btnp(5)) then
   if(shop[10] and inv[2] > 0) then
    inv2me1()
    add(vanilla, 1800)
    buttercount = bstart
    resetyogurt()
   end
  end

  if(curs == 7 and btnp(5)) then
    if(money >= ccowcost and ccowcost > 0) then
     money -= ccowcost
     ccowcost = flr(ccowcost * 1.5)
     addcow(2)
   end
  end
  if(curs == 8 and btnp(5)) then
   if(shop[7] and inv[7] > 0 and yog2count <= 1) then
    mcntreset()
    yog2count = 20
    inv[7] -= 1
    inv[8] += 4
    for i=1, 4 do tinygoods(10) end
   elseif(shop[7] and inv[7] > 0) then
    mcntreset()
    yog2count -= 1
    buttercount = bstart
    yog1count = 20
    yog3count = 20
   end
  end
  if(curs == 9 and btnp(5)) then
   if(shop[10] and inv[7] > 0) then
    inv[7] -= 1
    add(chocolate, 1800)
    buttercount = bstart
    resetyogurt()
   end
  end

  if(curs == 10 and btnp(5)) then
   if(money >= scowcost and scowcost > 0) then
    money -= scowcost
    scowcost = flr(scowcost * 1.5)
    addcow(3)
   end
  end
  if(curs == 11 and btnp(5)) then
   if(shop[7] and inv[10] > 0 and yog3count <= 1) then
    mcntreset()
    yog3count = 20
    inv[10] -= 1
    inv[11] += 4
    for i=1, 4 do tinygoods(11) end
   elseif(shop[7] and inv[10] > 0) then
    mcntreset()
    yog3count -= 1
    buttercount = bstart
    yog1count = 20
    yog2count = 20
   end
  end
  if(curs == 12 and btnp(5)) then
   if(shop[10] and inv[10] > 0) then
    inv[10] -= 1
    add(strawberry, 1800)
    buttercount = bstart
    resetyogurt()
   end
  end
 elseif(screen ==1) then
  buy()
 end

 updatecheese()
 updatevanilla()
 updatechocolate()
 updatestrawberry()
 movecows()

 for m in all(maids) do
  if(m.active) then
   seekcow(m)
   xt,yt = false,false
   if(m.x < m.dx) then 
    m.x+=maidspeed
    m.flip = true
   elseif(m.x > m.dx) then 
    m.x-=maidspeed
    m.flip = false
   else
    xt = true
   end
   if(m.y < m.dy) then
    m.y+=maidspeed
   elseif(m.y > m.dy) then
    m.y-=maidspeed
   else
    yt = true
   end
   if(xt and yt) m.active = false
  else
   if(#cows > 0) then
    m.timer-=1
    if(not cows[m.dcow]) m.dcow = randcow()
    newm.flip = not cows[m.dcow].flip
    if(m.timer == 0) then
     if(cows[m.dcow].col == 1) inv[1] += maidlevel
     if(cows[m.dcow].col == 2) inv[13] += maidlevel
     if(cows[m.dcow].col == 3) inv[14] += maidlevel
     tinycow(cows[m.dcow].col)
     m.active = true
     m.dcow = randcow()
     m.timer = mtime
    end
   end
  end
 end

 if(#maids > 0) then
  maidcrnt -=1
  if(maidcrnt < 0) then
   if(maidcost < 0) maidcost = 20480
   if(cowcost < 0) cowcost = 29071
   mcntreset()
   local search = true
   local clr = 1
   
   if(farm[3] > 0) then
    for c0 in all(cows) do
     if(c0.col == 3
     and search) then
      del(cows, c0)
      farm[3] -=1
      clr = 3
      search = false
     end
    end
   end
   
   if(farm[2] > 0) then
    for c1 in all(cows) do
     if(c1.col == 2
     and search) then
      del(cows, c1)
      farm[2] -=1
      clr = 2
      search = false
     end
    end
   end
   
   if(farm[1] > 0) then
    for c2 in all(cows) do
     if(c2.col == 1
     and search) then
      del(cows, c2)
      farm[1] -=1
      search = false
     end
    end
   end
   
   if(search != true) then
    newrunaway(32, 32, clr)
    addcow(4) 
    del(maids, maids[1])
   end
  end
 end

 if(#stl > 0) then
  sign[1] = "A milk maid has stolen your cow!"
  stl[1].x += stl[1].dir
  if(stl[1].x < -7
  or stl[1].x > 127) then
   del(stl,stl[1]) 
  end
 end

 movetiny()
 
 for g in all(goods) do
  g.y += g.spd
  if(g.y > 128) del(goods, g)
 end

 if(inv[1] > 350) then
  inv[1] -= 350
  inv[2] +=1
 end
 if(inv[13] > 350) then
  inv[13] -= 350
  inv[7] +=1
 end
 if(inv[14] > 350) then
  inv[14] -= 350
  inv[10] +=1
 end
 if(money < 0) money = 32767

end

function cdraw()
 cls(1)
 rectfill(2, 2, 72, 79, 3)
 rectfill(76, 9, 125, 79, scrcol)
 rect(2, 82, 125, 125, 8)
 rect(2, 2, 72, 79, 8)
 rect(76, 9, 125, 79, 8)
 rect(76, 54, 125, 55, 8)
 rectfill(81, 58, 99, 66, 14)
 rectfill(103, 58, 121, 66, 12)
 rectfill(80, 68, 122, 76, 15)
 rect(81, 58, 99, 66, 8)
 rect(103, 58, 121, 66, 8)
 rect(80, 68, 122, 76, 8)
 print("farm", 83, 60, 1)
 print("shop", 105, 60, 1)
 print("sell goods", 82, 70, 1)

 color(10)
 menu1 = {
 "squirts of milk",
 "gallons of milk",
 "sticks of butter",
 "wheels of cheese",
 "cups of yogurt",
 "bowls of ice cream"}
 menu2 = {
 "gallons of choc milk",
 "cups of choc yogurt",
 "bowls of choc ice cream",
 "gallons of strawb milk",
 "cups of strawb yogurt",
 "bowls of strawb ice cream"}
    
 if(ltimer > 150) then
  inv1()
  ltimer-=1
 elseif(inv[7] > 0 or inv[8] > 0 or inv[9] > 0 or
 inv[10] > 0 or inv[11] > 0 or inv[12] > 0) then
  inv2()
  ltimer-=1
  if(ltimer < 0) then
   ltimer = 300
  end
 else
  inv1()
  ltimer-=1
  if(ltimer < 0) then
   ltimer = 300
  end
 end

 del(sign, sign[1])
 if(screen == 0 or screen == 1) then
  del(sign, sign[1])
  for f=0,3 do
   rectfill(81, 11+f*11, 93, 19+f*11, 0)
  end
  for f=0,3 do
  rectfill(96, 11+f*11, 107, 19+f*11, 0)
  end
  for f=0,3 do
   rectfill(110, 11+f*11, 121, 19+f*11, 0)
  end
 end

 if(curs == 0 and inv[2] < 1 and money < 5 and #cows == 1) then
    add(sign, "press x to milk")
 end
 
 if(screen == 0) then
  if((money >= maidcost and maidcost > 0) or #maids < 1) then
   spr(1,  83, 12)
   if(curs == 1) then
    add(sign, "$"..tostr(maidcost).." - milk maid")
   end
  end
  if(shop[1] and inv[2] > 0 and not shop[9]) then
   spr(8, 98, 12)
   if(buttercount < bstart and curs == 2) print(buttercount, 96, 15, 10)
  elseif(shop[1] and inv[2] > 0 and shop[9]) then
   spr(44, 98, 12)
   if(buttercount < bstart and curs == 2) print(buttercount, 96, 15, 10)
  end
  if(shop[4] and inv[2] > 0 and not shop[12]) then
   spr(24,112, 12)
  elseif(shop[4] and inv[2] > 0 and shop[12]) then
   spr(13,112, 12)
  end
  if(#cheeses > 0) print(#cheeses, 110, 15, 10)
  
  if(money >= cowcost and cowcost > 0 and farm[1] < 16) then
   spr(2, 83, 23)
   if(curs == 4) then
    add(sign, "$"..tostr(cowcost).." - cow")
   end
  end
  if(shop[7] and inv[2] > 0) then
   spr(9, 98, 22)
   if(yog1count < 20 and curs == 5) print(yog1count, 96, 26, 10)
  end
  if(shop[10] and inv[2] > 0) then
   spr(25,112, 22)
  end
  if(#vanilla > 0) print(#vanilla, 110, 26, 10)
     
  if(money >= ccowcost and ccowcost > 0) then
   spr(3,  83, 34)
   if(curs == 7) then
    add(sign, "$"..tostr(ccowcost).." - chocolate cow")
   end
  end
  if(shop[7] and inv[7] > 0) then
   spr(10, 98, 33)
   if(yog2count < 20 and curs == 8) print(yog2count, 96, 37, 10)
  end
  if(shop[10] and inv[7] > 0) then
   spr(26,112, 33)
  end
  if(#chocolate > 0) print(#chocolate, 110, 37, 10)
     
  if(money >= scowcost and scowcost > 0) then
   spr( 4, 83, 45)
   if(curs == 10) then
    add(sign, "$"..tostr(scowcost).." - strawberry cow")
   end
  end
  if(shop[7] and inv[10] > 0) then
   spr(11, 98, 44)
   if(yog3count < 20 and curs == 11) print(yog3count, 96, 48, 10)
  end
  if(shop[10] and inv[10] > 0) then
   spr(27,112, 44)
  end
  if(#strawberry > 0) print(#strawberry, 110, 48, 10)
     
 elseif(screen ==1) then
  if(money >= 25
  and not shop[1]) then
   if(curs == 1) then
    add(sign, "$25 - churn milk into butter")
   end
   spr(8,  83, 12)
  elseif(shop[1]) then
   if(curs == 1) then
    add(sign, "$25 - churn milk into butter")
   end
   spr(8,  83, 12)
   rect(80,10,94, 20, 13)
  end
  if(money >= 50 and chshop(1)) then
   if(curs == 2) then
    add(sign, "$50 - maids get +1 squirt")
   end
   spr(14, 98, 11)
  elseif(shop[2]) then
   if(curs == 2) then
    add(sign, "$50 - maids get +1 squirt")
   end
   spr(14, 98, 11)
   rect(95, 10, 108, 20, 13)
  end
  if(money >= 100 and chshop(2)) then
   if(curs == 3) then
    add(sign, "$100 - coffee for maids")
   end
   spr(12,112, 12)
  elseif(shop[3]) then
   if(curs == 3) then
    add(sign, "$100 - coffee for maids")
   end
   spr(12,112, 12)
   rect(109, 10, 122, 20, 13)
  end
  
  if(money >= 125 and chshop(3)) then
   spr(24, 83, 22)
   if(curs == 4) then
    add(sign, "$125 - cheese cave:takes 5 min")
   end
  elseif(shop[4]) then
   if(curs == 4) then
    add(sign, "$125 - cheese cave:takes 5 min")
   end
   spr(24, 83, 22)
   rect(80, 21, 94, 31, 13)
  end
  if(money >= 250 and chshop(4)) then
   if(curs == 5) then
    add(sign, "$250 - maids get +2 squirts")
   end
   spr(29, 98, 22)
  elseif(shop[5]) then
   if(curs == 5) then
    add(sign, "$250 - maids get +2 squirts")
   end
   spr(29, 98, 22)
   rect(95, 21, 108, 31, 13)
  end
  if(money >= 500 and chshop(5)) then
   if(curs == 6) then
    add(sign, "$500 - energy drink for maids")
   end
   spr(28,112, 23)
  elseif(shop[6]) then
   if(curs == 6) then
    add(sign, "$500 - energy drink for maids")
   end
   spr(28,112, 23)
   rect(109, 21, 122, 31, 13)
  end
     
  if(money >= 750 and chshop(6)) then
   if(curs == 7) then
    add(sign, "$750 - active yogurt culters")
   end
   spr(9,  83, 33)
  elseif(shop[7]) then
   if(curs == 7) then
    add(sign, "$750 - active yogurt culters")
   end
   spr(9,  83, 33)
   rect(80, 32, 94, 42, 13)
  end
  if(money >= 1500 and chshop(7)) then
   if(curs == 8) then
    add(sign, "$1500 - maids get +3 squirts")
   end
   spr(30, 98, 33)
  elseif(shop[8]) then
   if(curs == 8) then
    add(sign, "$1500 - maids get +3 squirts")
   end
   spr(30, 98, 33)
   rect(95, 32, 108, 42, 13)
  end
  if(money >= 3000 and chshop(8)) then
   if(curs == 9) then
    add(sign, "$3000 - advanced butter churner")
   end
   spr(44,112, 34)
  elseif(shop[9]) then
   if(curs == 9) then
    add(sign, "$3000 - advanced butter churner")
   end
   spr(44,112, 34)
   rect(109, 32, 122, 42, 13)
  end
     
  if(money >= 6200 and chshop(9)) then
   if(curs == 10) then
    add(sign, "$6200 - ice cream freezer:1 min")
   end
   spr(25, 83, 44)
  elseif(shop[10]) then
   if(curs == 10) then
    add(sign, "$6200 - ice cream freezer:1 min")
   end
   spr(25, 83, 44)
   rect(80, 43, 94, 53, 13)
  end
  if(money >= 12500 and chshop(10)) then
   if(curs == 11) then
    add(sign, "$12500 - maids get +4 squirts")
   end
   spr(45, 98, 44)
  elseif(shop[11]) then
   if(curs == 11) then
    add(sign, "$12500 - maids get +4 squirts")
   end
   spr(45, 98, 44)
   rect(95, 43, 108, 53, 13)
  end
  if(money >= 25000 and chshop(11)) then
   if(curs == 12) then
    add(sign, "$25000 - advanced freezer")
   end
   spr(13,112, 45)
  elseif(shop[12]) then
   spr(13,112, 45)
   rect(109, 43, 122, 53, 13)
  end
  
  local check = true
  for s=1, #shop do
   if(not shop[s]) check = false
  end
  if(check) then
   del(sign, sign[1])
   rectfill(81, 11, 121, 52, 0)
   sspr(112, 16, 8, 8, 94, 23, 16, 16)
   if(curs > 0 and curs < 13) add(sign, "$30000 - ??????????")
  end
 elseif(screen == 2) then
  cursor0()
  while(inv[sell] == 0)do
   sell+=1
  end
  if(selltime > 0 and screen == 2 and sell < 13) then
   if(sell == 2) sspr(72, 16, 8, 8, 94, 17, 16, 16)
   if(sell == 3) sspr(120, 0, 8, 8, 94, 17, 16, 16)
   if(sell == 4) sspr(120, 8, 8, 8, 94, 17, 16, 16)
   if(sell == 5) sspr(72, 0, 8, 8, 94, 17, 16, 16)
   if(sell == 6) sspr(72, 8, 8, 8, 94, 17, 16, 16)
   if(sell == 7) sspr(80, 16, 8, 8, 94, 17, 16, 16)
   if(sell == 8) sspr(80, 0, 8, 8, 94, 17, 16, 16)
   if(sell == 9) sspr(80, 8, 8, 8, 94, 17, 16, 16)
   if(sell == 10) sspr(88, 16, 8, 8, 94, 17, 16, 16)
   if(sell == 11) sspr(88, 0, 8, 8, 94, 17, 16, 16)
   if(sell == 12) sspr(88, 8, 8, 8, 94, 17, 16, 16)
   print(inv[sell].."x"..tostr(price[sell-1]).."=$"..tostr(inv[sell]*price[sell-1]), 78, 40, 1)
   selltime -= 1
  elseif(sell > 12) then
   selltime = 45
   sell = 2
   setscreen(0, 14)
  elseif(inv[sell] > 0 and selltime <= 0)then
   money += inv[sell]*price[sell-1]
   inv[sell] = 0
   selltime = 45
   sell +=1
  else
   selltime = 45
   sell = 2
   setscreen(0, 14)
  end
 end

 rect(bord.p1.x,bord.p1.y, bord.p2.x,bord.p2.y, bord.col)
        
 if(bord.p1.x > bord.d1.x) then 
  bord.p1.x-=4 end
 if(bord.p1.x < bord.d1.x) then 
  bord.p1.x+=5 end
 if(bord.p1.y > bord.d1.y) then 
  bord.p1.y-=4 end
 if(bord.p1.y < bord.d1.y) then 
  bord.p1.y+=5 end
        
 if(bord.p2.x > bord.d2.x) then 
  bord.p2.x-=4 end
 if(bord.p2.x < bord.d2.x) then 
  bord.p2.x+=5 end
 if(bord.p2.y > bord.d2.y) then 
  bord.p2.y-=4 end
 if(bord.p2.y < bord.d2.y) then 
  bord.p2.y+=5 end
      
 bord.col +=0.35

 drawsign()
 drawcows()

 for m in all(maids) do
  spr(17,m.x,m.y,1,1,m.flip)
 end

 if(#stl > 0) then
  if(stl[1].dir < 0) then
   spr(1+stl[1].c, stl[1].x,
    stl[1].y)
   spr(17, stl[1].x+1, stl[1].y-4)
  else
   spr(1+stl[1].c,
    stl[1].x, stl[1].y, 1, 1, true)
   spr(17, stl[1].x-1,
    stl[1].y-4, 1, 1, true)
  end
 end

 drawtiny()

 for g in all(goods) do
  g.cnt -= g.spd * 0.05
  spr(g.c, g.x, g.y, 1, 1, (g.cnt > g.spd))
  if(g.cnt < 0) then
   g.cnt=g.spd*2
  end
 end
end

keys={}

function is_held(k) return band(keys[k], 1) == 1 end
function is_pressed(k) return band(keys[k], 2) == 2 end
function is_released(k) return band(keys[k], 4) == 4 end

function upd_key(k)
 if keys[k] == 0 then
  if btn(k) then keys[k] = 3 end
 elseif keys[k] == 1 then
  if btn(k) == false then keys[k] = 4 end
 elseif keys[k] == 3 then
  if btn(k) then keys[k] = 1
  else keys[k] = 4 end
 elseif keys[k] == 4 then
  if btn(k) then keys[k] = 3
  else keys[k] = 0 end
 end
end

function init_keys()
 for a = 0,5 do keys[a] = 0 end
end

function upd_keys()
 for a = 0,5 do upd_key(a) end
end
-->8
function gotmilk()
 mcntreset()
 inv[1] += farm[1]
 for m=1, farm[1] do
  tinycow(1)
 end
 inv[13] += farm[2]
 for m=1, farm[2] do
  tinycow(2)
 end
 inv[14] += farm[3]
 for m=1, farm[3] do
  tinycow(3)
 end
end

function drawsign()
 if(not win) then
  print("$", 90, 2, 10)
  print(money, 95, 2, 10)
 end
 if(#sign > 0)then
  if(signy > 118) signy-=1
  sspr(8, 16, 8, 8, 1, signy-1, 126, 8)
  print(sign[1],hcenter(sign[1]),signy,5)
 else
  signy = 129
 end
end

function setscreen(s, c)
 screen = s
 scrcol = c
end

function updatecheese()
 if(cheeses[val]) then
  cheeses[val] -= 1
  if(cheeses[val] < 1) then
   inv[4] += 1
   del(cheeses, cheeses[val])
   tinygoods(31)
  end
  val+=1
  if(cheeses[val]) then
   updatecheese()
  else
   val = 1
  end
 end
end

function updatevanilla()
 if(vanilla[val]) then
  vanilla[val] -= 1
  if(vanilla[val] < 1) then
   inv[6] += 1
   del(vanilla, vanilla[val])
   tinygoods(25)
  end
  val+=1
  if(vanilla[val]) then
   updatevanilla()
  else
   val = 1
  end
 end
end

function updatechocolate()
 if(chocolate[val]) then
  chocolate[val] -= 1
  if(chocolate[val] < 1) then
   inv[9] += 1
   del(chocolate, chocolate[val])
   tinygoods(26)
  end
  val+=1
  if(chocolate[val]) then
   updatechocolate()
  else
   val = 1
  end
 end
end

function updatestrawberry()
 if(strawberry[val]) then
  strawberry[val] -= 1
  if(strawberry[val] < 1) then
   inv[12] += 1
   del(strawberry, strawberry[val])
   tinygoods(27)
  end
  val+=1
  if(strawberry[val]) then
   updatestrawberry()
  else
   val = 1
  end
 end
end

function inv1()
 i = 0
 j = 5
 if(j>5) j=5
 while(i <=j) do
  if(inv[i+1] > 0 or i == 0) then
   print(flr(inv[i+1]), 4, i*7 + 84)
   print(menu1[i+1], 18, i*7 + 84)
  end
  i+=1
 end

 if(inv[13] > 0) then
  rectfill(81, 83, 102, 89, 3)
  print(inv[13], 83, 84, 10)
  spr(35, 96, 84)
 end
 if(inv[14] > 0) then
  rectfill(103, 83, 124, 89, 3)
  print(inv[14], 104, 84, 10)
  spr(36,117, 84)
 end
end

function inv2()
 i = 6
 j = 11
 t = 0
 while(i <=j) do
  if(inv[i+1] > 0) then
   print(flr(inv[i+1]), 4, t*7 + 84)
   print(menu2[t+1], 18, t*7 + 84)
  end
  i+=1
  t+=1
 end	
end

function inv2me1()
 inv[2] -= 1
end

function cursor0()
 curs = 0
 bord.d1.x = 2
 bord.d1.y = 2
 bord.d2.x = 72
 bord.d2.y = 79
end

function cursor13()
 curs = 13
 bord.d1.x = 81
 bord.d1.y = 58
 bord.d2.x = 99
 bord.d2.y = 66
 sfx(2)
end

function cursor14()
 curs = 14
 bord.d1.x = 103
 bord.d1.y = 58
 bord.d2.x = 121
 bord.d2.y = 66
 sfx(2)
end
-->8
function addcow(col)
 newcow = {}
 newcow.x = 34
 newcow.y = 34
 newcow.dx = flr(rnd(61) + 3)
 newcow.dy = flr(rnd(69) + 3)
 newcow.sp = flr(rnd(4) + 2)
 newcow.spc = newcow.sp
 newcow.wait = rnd(80)
 newcow.col = col
 farm[col] +=1
 newcow.flip = false
 newcow.eat = false
 add(cows, newcow)
end

function movecows()
 for c in all(cows) do
  wx = false
  wy = false
        
  if(c.spc > 0) then
   c.spc -= 1
  else
   c.spc = c.sp
   if(c.x < c.dx) then
    c.x += 1
    c.flip=true
   elseif(c.x > c.dx) then
    c.x -= 1
    c.flip = false
   else
    wx = true
   end
        
   if(c.y < c.dy) then
    c.y += 1
   elseif(c.y > c.dy) then
    c.y -= 1
   else
    wy = true
   end
        
   if(wx and wy) then
    c.eat=true
    if(c.wait > 0) then
      c.wait-=1
      if(c.wait <10) then
       c.eat=false
      end
    else
     c.eat=false
     c.wait = rnd(80)
     if(win)then
      c.dx = flr(rnd(120) + 3)
      c.dy = flr(rnd(120) + 3)
     else
      c.dx = flr(rnd(61) + 3)
      c.dy = flr(rnd(69) + 3)
     end
    end
   end
  end     
 end
end

function drawcows()
 for c in all(cows) do
  if(c.flip) then
   if(c.eat) then
    spr(c.col+17,c.x,c.y,1,1,true)
   else
    spr(c.col+1,c.x,c.y,1,1,true)
   end
  else
   if(c.eat) then
    spr(c.col+17,c.x,c.y)
   else
    spr(c.col+1,c.x,c.y)
   end
  end
 end
end

function randcow()
 return flr(rnd(#cows)+1)
end

function buy()
 for b=1, 12 do
  if(curs == b and btnp(5))then
   if(money >= prices[b] and not shop[b])then
    if(shop[b-1] or b == 1)then
     shop[b] = true
     money -= prices[b]
     if(b==2)maidlevel = 2
     if(b==3)then
      maidspeed = .5
      resetmaids()
     end
     if(b==5)maidlevel = 3
     if(b==6)then
      maidspeed = 1
      mtime = 25
      resetmaids()
     end
     if(b==8)maidlevel = 4
     if(b==9)then
      bstart = 25
      buttercount = bstart
     end
     if(b==10)maidlevel = 5
    end
   end
  end
 end
end

function resetmaids()
 for m in all(maids) do
  m.x = flr(m.x)
  m.y = flr(m.y)
 end
end

function resetyogurt()
 yog1count = 20
 yog2count = 20
 yog3count = 20
end
-->8
function cutinit()
 _update = cutupdate
 _draw = cutdraw
 rocket = 60
 spd = 0.01
 blast = false
 cowsc = {}
 start = 120
 for b=1, 3 do
  for c=1, farm[b] do 
   add(cowsc, {col=1+b, x=start})
   start+=20
  end
 end
end

function cutupdate()
 if(#cowsc == 0) blast = true
 if(blast)then
  rocket-=1*spd
  spd+=.1
 end
 if(rocket < -100) spinit()
end

function cutdraw()
 cls(12)
 circfill(64, 496, 400, 3)
 sspr(112, 16, 8, 8, 5, rocket, 60, 60)
 for c in all(cowsc) do
  c.x-=1
  if(c.x < 23) del(cowsc, c)
  sspr(8 * c.col, 0, 8, 8, c.x, 91, 16, 16)
 end
 if(not blast) rectfill(20, 90, 49, 104, 7)
end

function rndship()
 local dab = {}
 for r = 1, flr(rnd(7)+3) do
  add(dab, flr(rnd(13)+1))
 end
 ship(flr(rnd(128)), -8, 8, 8, flr(rnd(14)+48), 1, false, dab, 50)
end

function spinit()
 _update,_draw,ships,bullets,tx,ty,boss,player,kills,wint,clock,text
 =
 spupdate,spdraw,{},{},{8, 8, 8,32,32,60, 60, 60,90,90,114, 114, 114, 64},
 {8,40,72,30,56,16, 40, 72,30,56,  8,  40,  72, -20},{x=40,y=-100,hp=1000,phase=0, hit=false, dx=40, dy=40, move = false,
  movetime = 200, hpp = 120,eye={blink = true, btime = 10},larm={off=-3, length = -24, tlen=24, up=false, height = 0, 
  thei =8},rarm={off=-3, length = -24, tlen=24, up=false, height = 0, thei =8}},{upgrade = 0, hp = {farm[1], farm[2], farm[3]}, hpp = 120},
  0,100,100,{"conglaturation !!!", "this is the end of the game!","i had more planned", "i ran out of tokens :)", "cow clicker 2 in 2020",
  "just kidding","give your hand a rest", "your cows are now safe", "thank you for playing my game"}
 ship(64, 114, 8, 8, 46, 0, true, false)
end

function spupdate()
 clock-=1
 if(clock == 0) clock = 100
 if(win)then
  movecows()
  movetiny()
  if(#text > 1) then
   wint -=1
   if(wint%20 == 0) gotmilk()
   if(wint <=0)then
    wint = 240
    del(text, text[1])
   end
  end
  sign[1] = text[1]
 else
  upd_keys()
  for s in all(ships)do
  if(s == ships[1])then
   if(btn(0) and s.x > 0) s.x-=2
   if(btn(1) and s.x < 120) s.x+=2
   if(btn(2) and s.y > 0) s.y-=2
   if(btn(3) and s.y < 120) s.y+=2
   if(btnp(5))then
    if(player.upgrade < 4)then 
     bullet(s.x+3, s.y+4, 1, 1+player.upgrade, 2, 2, player.upgrade, true)
     sfx(4+player.upgrade)
    end
    if(player.upgrade == 4)then 
     bullet(s.x+3, s.y+4, 2, 5, 2, 3, player.upgrade, true)
     sfx(10)
    end
    if(player.upgrade == 5)then 
     bullet(s.x+3, s.y+4, 2, 10, 2, 6, player.upgrade, true)
     sfx(9)
    end
   end 
  else
   if(collide(s, ships[1])) player.hpp-=2
   if(s.d[1] > 0) then
    local chx,chy = false,false
    if(s.x < tx[s.d[1]]) then
     s.x+=1
    elseif(s.x > tx[s.d[1]])then 
     s.x-=1
    else
     chx = true
    end
    if(s.y < ty[s.d[1]]) then
     s.y+=1
    elseif(s.y > ty[s.d[1]]) then
     s.y-=1
    else
     chy = true
    end
    if(chx and chy)then
     if(s.x < -10 or s.x > 138 or s.y < -10 or s.y > 138)then
      del(ships, s)
     else
      del(s.d, s.d[1])
      if(#s.d == 0) add(s.d, #tx)
     end 
    end
   end
   if(s.type == 1) then
    if(clock == s.data) then 
     bullet(s.x+3, s.y+3, 1, 1, 3, 2, 0, false)
     sfx(4)
     s.data = flr(rnd(100))
    end
   elseif(s.type == 99) then
    s.data -=1
    if(s.data < 1) del(ships, s)
   end
  end
 end
  for b in all(bullets)do
  if(b.dir == 0) b.x -=b.spd
  if(b.dir == 1) b.x +=b.spd
  if(b.dir == 2) b.y -=b.spd
  if(b.dir == 3) b.y +=b.spd

  for s in all (ships) do
   local col = collide(b, s)
   if(col and b.good != s.good and not s.good) then 
    ship(s.x, s.y, 8, 8, 62, 99, true, {0}, 30)
    del(ships, s)
    del(bullets, b)
    kills +=1
    sfx(15)
    if(kills > 25) player.upgrade = 3
    if(kills > 50 and boss.phase == 0)then
     boss.move = true
     boss.phase = 7
     kills = 0
    end
    if(kills > 75) player.upgrade = 4
    if(kills > 150) player.upgrade = 5
   elseif(col and b.good != s.good) then
    player.hpp-=20
    del(bullets, b)
   end
  end
  if(b.x < -8 or b.x > 128 or b.y < -8 or b.y > 128) del(bullets, b)
 end
  movecows()
 end
end

function spdraw()
 cls(1)
 if(win)then
  rectfill(0, 0, 127, 127, 3)
  drawcows()
  drawtiny()
  drawsign()
 else
  drawboss()
  for b in all(bullets)do
   if(b.type == 0 or b.type == 3)rectfill(b.x, b.y, b.x+b.w-1, b.y+b.h-1, 7+player.upgrade)
   if(b.type == 4)rectfill(b.x, b.y, b.x+b.w-1, b.y+b.h-1, 9)
   if(b.type == 5)rectfill(b.x, b.y, b.x+b.w-1, b.y-b.h-1, 14)
   if(b.type == 99)spr(99, b.x+8, b.y+8)
  end
  for s in all(ships)do
   pals = {0, 4, 8, 9, 10}
   if(s.type == 99) pal(pals[flr(rnd(5)+1)], pals[flr(rnd(5)+1)])
   spr(s.spr, s.x, s.y)
   pal()
  end
  drawhp()
 end
end

function drawhp()
 if(player.hpp < 0)then
  if(player.hp[3] > 0) then
   player.hp[3] -=1
   player.hpp+=120
  elseif(player.hp[2] > 0) then
   player.hp[2] -=1
   player.hpp+=120
  elseif(player.hp[1] > 0) then
   player.hp[1] -=1
   player.hpp+=120
  else
   spinit()
  end
 end
 for hp = 0, player.hpp do
  local col = 7
  if (player.hp[2] > 0) col = 4
  if (player.hp[3] > 0) col = 14
  rect(hp+3, 119, hp+4, 125, col)
 end
 if(player.hp[3] > 0)then num = player.hp[3] 
 elseif(player.hp[2] > 0)then num = player.hp[2]
 else num = player.hp[1] end
 print(num, 4, 120, 5)
 if(boss.hpp <= 0)then
  boss.eye.blink = true
  wint -= 1
  boss.dy = -200
  ship(rnd(32)+boss.x, rnd(32)+boss.y, 8, 8, 62, 99, true, {0}, 30)
  for s=2, #ships do
   ships[s].type = 99
  end
  if(wint < 0)then
   win = true
   wint = 240
   music(3)
  end
 end
 if(boss.hpp < 80) boss.phase = 4
 if(boss.hpp < 40) boss.phase = 14
 for bhp = 0, boss.hpp do
  rect(bhp+3, 3, bhp+4, 9, 8)
 end
end

function mcntreset()
 maidcrnt = maidstl
end

function bullet(px, py, pw, ph, pdir, pspd, ptype, pgood)
 nb = {
     x=px,
     y=py,
     w=pw,
     h=ph,
     dir=pdir,
     spd=pspd,
     type=ptype,
     good=pgood
     }
 add(bullets, nb)
end

function ship(px, py, pw, ph, pspr, ptype, pgood, pd, pdata)
 ns = {
  x = px,
  y = py,
  w = 8,
  h = 8,
  spr = pspr,
  type = ptype,
  good = pgood,
  d = pd,
  data = pdata
 }
 add(ships, ns)
end

function beye()
 if(boss.eye.btime >= 6)then
  spr(100, boss.x+8, boss.y+16, 2, 2)
 elseif(boss.eye.btime >= 0)then
  spr(102, boss.x+8, boss.y+16, 2, 2)
 end
end

function drawboss()
 pal(14, boss.phase)
 if(boss.hit) pal(14, 8)

 rectfill(boss.x+7, boss.y+16, boss.x+21, boss.y+29, 7)
 spr(115, boss.x+(ships[1].x/26)+10.75, boss.y+(ships[1].y/40)+20, 1, 1)
 spr(72, boss.x, boss.y, 4, 4)

 if(boss.eye.blink)then
  boss.eye.btime -=1
  beye()
  if(boss.eye.btime <= 0) then
   boss.eye.blink = false
   boss.hit = false
  end
 elseif(boss.eye.btime < 10)then
  boss.eye.btime+=1
  beye()
 end
 barms(-3, 8, -3, 1, boss.rarm)
 barms(34, -8, 26, 30, boss.larm)

 if(flr(rnd(100)) == 10) then
  boss.eye.blink = true
  boss.eye.btime = 10
 end
 
 local pick = flr(rnd(50))
 if(pick == 10)setlen(flr(rnd(100))-50, 0)
 if(pick == 20)sethei(flr(rnd(24)-16), 0)
 if(pick == 30)setlen(flr(rnd(100))-50, 1)
 if(pick == 40)sethei(flr(rnd(24)-16), 1)
 if(pick == 15 or (pick == 25 and boss.phase == 14))rndship()
 pal()


 movearms(boss.larm)
 movearms(boss.rarm)

 local eye = {x=boss.x+11, y=boss.y+24, w=10, h=4}
 local arms = {}

 if(boss.larm.length < 0)then add(arms, {x=boss.x+25+boss.larm.length, y=boss.y+40-boss.larm.height, w=-1*boss.larm.length+2, h=8})
 else add(arms,{x=boss.x+25, y=boss.y+40-boss.larm.height, w=boss.larm.length+2, h=8})end
 if(boss.rarm.length > 0) then add(arms, {x=boss.x, y=boss.y+38-boss.rarm.height, w=boss.rarm.length+2, h=8})
 else add(arms,{x=boss.x, y=boss.y+38-boss.rarm.height, w=boss.rarm.length+2, h=8})end

 if(pick == 35 and boss.phase > 0)then
  bullet(arms[1].x+boss.larm.length, arms[1].y+8, 2, 2, 3, 3, 4, false)
  sfx(8)
 elseif(pick == 45 and boss.phase > 0)then
  bullet(arms[2].x+boss.rarm.length, arms[2].y+8, 2, 2, 3, 3, 4, false)
  sfx(8)
 end

 for b in all(bullets) do
  if(collide(b, eye) and b.good and boss.eye.btime > 9)then
   bullet(boss.x+8, boss.y+16, 3, 4, 3, 2, 99, false)
   del(bullets, b)
   boss.eye.blink = true
   boss.hit = true
   boss.hpp -= player.upgrade-1
   sfx(16)
  end
  for a in all(arms) do
   if(collide(b, a) and b.good)then
    del(bullets, b)
   end
   if(collide(a, ships[1])) player.hpp-=.5
  end
 end
 if(boss.move)then
  if(boss.x < boss.dx) boss.x+=1
  if(boss.x > boss.dx) boss.x-=1
  if(boss.y < boss.dy) boss.y+=1
  if(boss.y > boss.dy) boss.y-=1
 end
 if(boss.x == boss.dx) boss.dx = flr(rnd(80)+10)
 if(boss.y == boss.dy) boss.dy = flr(rnd(40))
 boss.movetime-=1
 if(boss.movetime <= 0 and boss.phase != 14 and boss.phase > 0)then
  boss.movetime = 200
  boss.move = not boss.move
 elseif(boss.movetime <= 0 and boss.phase > 0)then
  boss.move = true
  boss.movetime = 200
 end
end

function movearms(arm)
 if(arm.length < arm.tlen) arm.length += 1
 if(arm.length > arm.tlen) arm.length -= 1
 if(arm.length > 0) arm.off = 3
 if(arm.length < 0) arm.off = -3
 
 if(arm.height < arm.thei) arm.height += 0.5
 if(arm.height > arm.thei) arm.height -= 0.5
end

function setlen(len, arm)
 if(arm == 0) boss.larm.tlen = len
 if(arm == 1) boss.rarm.tlen = len
end

function sethei(hei, arm)
 if(arm == 0) boss.larm.thei = hei
 if(arm == 1) boss.rarm.thei = hei
end

function barms(n1, n2, n3, n4, arm)
 sspr(15*8, 32, 8,  24, boss.x+n1, boss.y+18, n2, 24-arm.height)
 spr(127, boss.x+n3, boss.y-arm.height+40, 1, 1, (arm.off == 3))
 sspr(12*8, 56, 24, 8, arm.off+boss.x+n4, boss.y-arm.height+40, arm.length, 8, true)
end

function collide(a, b) return (a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y) end

function chshop(num)
 return not shop[num+1] and shop[num]
end

function addmaid()
 newm = { 
 x = 34,
 y = 34,
 dcow = randcow(),
 flip = false,
 active = true,
 timer = 50 
 }
 newm.dx = cows[newm.dcow].x
 newm.dy = cows[newm.dcow].y 
 add(maids, newm)
end


function seekcow(m)
 if(#cows > 0)then 
  if(cows[m.dcow]) then
   m.dx = cows[m.dcow].x
   m.dy = cows[m.dcow].y
  else
   m.dcow = randcow()
   m.dx = cows[m.dcow].x
   m.dy = cows[m.dcow].y
  end
 else
  m.timer-=1
  if(m.timer == 0) then
   m.timer = 100
   m.dx = flr(rnd(61) + 3)
   m.dy = flr(rnd(69) + 3)
  end
 end
end
-->8
function tinycow(c)
 tc = {
  x = flr(rnd(122)),
  y = -4,
  c = c,
  spd = rnd(2) + 0.5
 }
 tc.cnt = tc.spd
 add(tiny, tc)
end

function tinygoods(g)
 tg = {
  x = flr(rnd(122)),
  y = -6,
  c = g,
  spd = rnd(2) + 0.5,
  cnt = rnd(4) + 0.5
 }
 add(goods, tg)
end

function movetiny()
 for t in all(tiny) do
  t.y += t.spd
  if(t.y > 128) del(tiny, t)
 end
end


function drawtiny()
 for t in all(tiny) do
  sprr = 33
  if(t.c > 37) sprr = 0
  t.cnt-=  1
  spr(sprr + t.c, t.x, t.y, 1, 1, (t.cnt > t.spd))
  if(t.cnt < 0) then
   t.cnt=rnd(4) + 0.5
  end
 end
end

function newrunaway(x, y, c)
 ra = {
  x = x,
  y = y,
  c = c,
  dir = 0
 }
 if(rnd(2) < 1) then
  ra.dir = -1
 else
  ra.dir = 1
 end
 add(stl, ra)
end

function hcenter(s)
  return 64-#s*2
end
 
function vcenter(s)
  return 61
end
__gfx__
00000000000777000000000500000001000000050000000000f00f0000000000004000000000000000000000000000000666000066666666eeeeeeee0aaaaa00
00000000000aa770577500071551000552250002000000000f0000f0000000050040aaaa0666666006666660066666606656600061111116ee2e2eee0aaaaa00
00700700000ffa70077955570559111502295552050500500f0000f0000000070040aaaa067777600644446006eeee606555677066666666ee2e2eee00000000
00077000000ffa700ee775770ee551550ee225220666966005f77f500000007700400000066666600666666006666660665660776d6555560eeeeee000000000
000770000008f80000077777000555550002222200606660553773550000007005550000001111000011110000111100766670076665a9560200000000000000
0070070000787870000700e7000500e5000200e20000606000777797755557700444000000117700001144000011ee00777770776d659a560000000000000000
000000000f78887f00050005000100010005000500000000007ee7977555577004440000007711000044110000ee1100777777706665a9560000000000000000
000000000f01110f0000000000000000000000000000000000eeee97775577700555000000111100001111000011110077777000666666660000000000000000
11111000000777000000000500000001000000050000000000eeee07777777700000000000000000000000000000000000111a00eeeeeeeeeeeeeeee09990000
18111000000aa700000000070000000500000002000000000000000777777770005550000dddddd00dddddd00dddddd000116600ee2e2eeeee2e2e2e9aa99900
18811000000fa700577555571551111552255552000000500a0a0a07070eee7000555500dd7777dddd4444ddddeeeedd00116600ee2e2eeeee2e2e2e9a9aa990
1888100000088000077775770555515502222522050596600a9a9a070700ee7000505500dd7777dddd4444ddddeeeedd008888000eeeeee00eeeeee09aa9aa99
18811000007117000ee777770ee555550ee22222066666600a9a9a0505005050055005002dddddd22dddddd22dddddd2006a8100020200000202000099999999
1811100000f11f00000700e7000500e5000200e2006060600444440000000000050005502222222222222222222222220066110000000000000000009a9aa9a9
1111100000011000000500050001000100050005000000000a9a9a0000000000050900500222222002222220022222200066160000000000000000009aaa9aa9
00000000000880000000000000000000000000000000000000000000000000005509905500dddd0000dddd0000dddd0000611100000000000000000099999999
a0000000777777770000050000000100000005000550500000000000000000000000000000cc000000bb0000009900000000d0000eeeeeee000cc00000000000
000000007777777757575700151515005252520006696000000000000000000000000000067766600644666006ee66600000d0000e2e2e2e002cc20000000000
00000000777777770e9777000e9555000e9222000006600000000000000000000000000067776006644460066eee60060000d0000e2e2e2e002cc20000000000
00000000777777770007e7000005e5000002e2000000000000000000000000000000000067777606644446066eeee606006666600eeeeee00d2772d000000000
00000000777777770000000000000000000000000000000066666666666666660000000067777766644444666eeeee6600636860020202000d7777d000000000
00000000777777770000000000000000000000000000000005000050505005050000000067777760644444606eeeee600066686000000000bd7777db00000000
00000000777777770000000000000000000000000000000056500565060000600000000067777760644444606eeeee600066686000000000bd2cc2db00000000
0000000000000000000000000000000000000000000000000500005050500505000000000666660006666600066666000066666000000000bd0000db00000000
6086680660b66b06660000666600006699000099dd0000dd00b00b00008008002020020220200202600000066000000600c00c0000f00f000044440004000040
685555866b5555b6c6cccc6c969999699aaaaaa9deeeeeedb066660b8066660820222202202222026d0dd0d66a0aa0a600c44c0000f33f000449944004400440
685555866b5555b6c661166c966116699aa55aa9dee55eed666556666665566626255262262552626dddddd66aaaaaa6c004400cf003300f049aa94004444440
6086680660b66b060c1111c00911119099a55a99dde55edd06655660066556602e2552e22e2552e20d5dd5d00a5aa5a0c44cc44cf33ff33f449aa94444999944
0086680000b66b000c1111c009111190990aa099dd0ee0dd006666000066660026222262262222620d5555d00a5555a0004cc400003ff30044999944449aa944
0086680000b66b0000c11c0000911900990aa099dd0ee0dd0006600000066000200220022002200200d55d0000a55a00004554000035530004444440049aa940
0086680000b66b0000cccc000099990099000099dd0000dd00066000000660000002200000022000000dd000000aa000004cc400003ff3000440044004499440
0006600000066000000cc00000099000aa0000aaee0000ee000bb00000088000000ee000000ee000000dd000000aa000000cc000000ff0000400004000444400
07000070007007000777777007777770000770000007700007000070070000700000000000000222200000000000000077707000777700000707000000002222
00777700007777007777777777777777007777000077770000700700007007000000000000002222222000000000000007007770700707770770000000222eee
07777770077777707007007777007007077777700777777000777700007777000000000000022e2ee222200000000000070070707707070707070000002eeeee
0707707007077070777777777777777707707070070707700777777007777770000000000022e22ee2ee22000000000000000000000000000000000002eee2ee
777777777777777707700770077007700777777007777770770770777707707700000000022ee2e2e22ee2000000000070707770707007770000000002eeeeee
70777707707777070007700000077000007007000070070007777770077777700000000222eee2eeee2ee2200000000007007070707007000770077022e2eeee
707007077070070707700770077007700707707007077070070000700700007000000022eeee22eeee22ee22000000000700777077700770707070002eeee2ee
70077007070770707700007707700770707007070770077007700770770000770000022ee2ee2eeeeee2e2e2200000000000000000000700777070002eeeeee2
0002200000000000000070000000200007770000000000000000000007022220000022eeeee22eee2ee22eee220000007770700000000000000070002eeeeee2
002222000777000000007000000222007707700000000070000000000702200000022eeeee22eeeeeeee22eee22000007070707770000000000000002e2eeee2
02222220070700000000777000222220700000000000007707770000777202000022ee2ee22eeeeeeeeee2e2ee20000077707070707000707000000022eeee22
0002200077000070070777000000200070000777000007707007077707000220022eeeeee2eee2eeeee2e22eee220000700070707707070000000000022e2e20
000222227000007007000700000020007000070777770070777707070700022002ee2eee22eeeeee2eeeee2eeee22000700070770700700700000000002eee20
0000222270007070070007702222222277070707700700707000070707002200022eeee22eeeeeeeeeeeee22e2ee2000000000000000700707770777022eee20
00000000700770777700007022200222077700777007007077770707000220000022ee22ee2eeeeeeeee2ee22eee200000000000007770070707070722e2ee22
00000000777700077000007000000000000000007007000000000000000000000002222eeeeee2eee2eeeeee2ee220000000000000000000000007772eeeeee2
0000000000000000000000000c000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000002eeeeeeeeeeeeeeeeee222200000000000006660000000000772eeeeee2
000d0d0000000000000000001c1000002eeee222222eee2e2eeee222222eee2e000002ee2eeee222222eee2ee20000000505005066566000000007772eee2ee2
000d0d0000000c00c0000000c7c00000eeee22222222eeeeeeee22222222eeee00002eeeeeee22222222eeeee20000000666966065556770000000002e2eee22
000ddd0000000c00c000000b1c100000ee2222eee2222ee2ee2222eee2222ee200002ee2ee22220002222ee2e22000000060666066566077005505002eeeee20
00dddd0000000c0cc000000b00000000ee22eeeeee2222eeee22eeeeeee222ee00002eeeee220000000222eeee20000000006060766670070066960022eeee20
00dddd0000000ccc0000000b00000000e22eeeeee220022ee22eeeeeeeeee22e00002eeee22000000000222eee20000000000000777770770000660002eeee20
0d0dd0d0e00e0ccc0000000b00000000e2eeeee22200022ee2eeeeeeee22222e00002e2ee22000000000022e2e20000000000000777777700000000002e2ee22
dd0d00d0ee0e0c0c0099900b00000000222222220000222e22eeeeee2222222e00002eee220000000000022eee20000000000000777770000000000022eeeee2
d00000d00ee00c0c0090900b001110002220000000022e2e22e22222222eee2e00002eee220000000000002eee2000000002222222222002200002222eeeeee2
0000000000e0c00cc099900b01111100220000000022ee2e222222222eeeee2e000022ee220000000000002eee2000000022eeeeeeee2222222222eee2eee2e2
000000000e00c0000000900b1111111022000000222eee2e2222222eeeeeee2e000002ee220000000000002eee200000022e2eeee2eeeeeeeee22eeeeeeeeee2
0aaaaa000e000000000000b011111110220022222eeee22e22eeeeeeeeeee22e000002ee220000000000022ee220000002eeee2eeeeeeeeeeeeeee2eeeeeee22
0a000a00e00000aaa000000011111110222222eeeeee22ee222eeeeeeeee22ee000002ee22200000000022eee20000002e2eeeeeeeeee2eeee2eeeeeeee2e220
00000000e00aaa000aaaaa0011111110e222eeeeee222eeee222eeeeee222eee0000022ee222000000222eee220000002ee222eeeeeeeeeeeeeeeeeeeeee2200
00000000000000000000000001111100ee222222222eeee2ee222222222eeee200000022ee222222222eeee2200000002e20022ee22222ee222222eeee222000
00000000000000000000000000000000222222222222222222222222222222220000000222222222222222220000000022000022220002222000022222200000
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
000f00001804000000000000000013050000000000000000180500000000000200001305000000000000000015050000001505000000150500000000000000001305000000000000000000000000000000000000
000f00001c040000001b040000001c0400000000000000001a0400000019040000001a04000000000000000000000000000000000000000000000000000180400000000000000000000000000000000000000000
000a000019000037500475016700023001910019100187001720018200182001c700173001630016300217001640016400164001650017500175001770017700177001d600000001e6001e600000000000000000
00040000001500015000150001500015000150021500315007150091500a1500b1500c1500c1500c1500c1500c1500c1500a15009150081500715006150051500315001150011500015000100021000110000100
000200000000000000360202f0202c02027020210101c0101801015010130100b0100501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000227301e720177600f7600a7600d720147201c740207302375027700267001a7001f700247002a70033700000000000000000000000000000000000000000000000000000000000000000000000000000
011700000d0500d0500000012050000001205012050000001205012050120500000000000140501605000000160501605000000160501605016050000000000019050190501900019050190501b0501905000000
0002000006000091500a1600e1601014014120191202012009130161000f1000c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001175011740047400474004740047300472004750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000541011410104200d4300a440114401d4401745020450354503d450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000e7501075012750167501675013750127500f750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000d0500d0500000012050000001205012050000001205012050120500000000000140501605000000160501605000000160501605016050000000000019050190501900019050190501b0501905000000
011000001605012050000001405016050000001605014050000001405000000000000000000000000001205000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002562019610196100d610036100161001600000001e6001e6001e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002f15029150221502515020150211501a150191501c1501515016150221003e050270500c05000050270000d000020003600033000300000e1002c00028000240001d0001300007000141000a10001100
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00 42 43 44
00 01 42 43 44
00 41 42 43 44
00 0b 42 43 44
00 0c 42 43 44
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
