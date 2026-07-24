pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init
--[[
flag key
-------------------------------
0 solid
1 impassable to player
2 item
3 slot
4 moveable furniture
5 needs access to spawn
6 can be placed on
7 uses a counter bottom
----]]
--debug=true
--debug_tut=true
--debug_score=true

function _init()
	mw,
	mh,
	mx,
	my
	=
	7,
	8,
	0,
	0
	poke(0x5f2c,3)
	cash_l=0
	day_length=2048
	if debug_score then
		day_length=10
 end
	daypal={9,1,12,12,12,12,1,9}
--	else
----	end
--	buy_line={
--		v(2,6),
--		v(1,6),
--		v(1,5),
--		v(1,4),
--		v(1,3),
--		v(2,3)
--	}
--	sell_line={
--		v(4,6),
--		v(5,6),
--		v(5,5),
--		v(5,4),
--		v(5,3),
--		v(4,3),
--	}
	t=0
	
	
	if not first_load then
 	cartdata("storegalore_0_1_9")
  first_load=true
 end
	if debug then
--		newgame()
  load_game()
	else
		state_change(title_update,title_draw)
	end
--	newgame()
--	count_stock()
-- upd=stock_update
-- drw=stock_draw
-- drw=lose_draw
-- upd=lose_update
-- drw=win_draw
-- upd=win_update
-- drw=score_draw
-- upd=score_update
-- closing_time()
-- menuitem(1,"help",init_tutorial)
-- menuitem(2,"mute",init_tutorial)
-- menuitem(2,"palette",init_tutorial)
 if not debug then
 	music(0)
 end
 menuitem(4,"start new game",new_game)
 menuitem(1,"restart day",load_game)
end

function enable_tutorial()
	if not debug_tut then
		tutorial={    
	  get_obj(2,7),
	  get_obj(3,5),
	  "swap",
	  get_obj(4,5,slots),
	  get_obj(2,7,furniture),
	  v(2,5),
	  entrance,
	  buyvs[1]
	 }
	 tutorial_mes={
	  "grab item",
	  "grab another",
	  "Žswap items",
	  "place here",
	  "—grab table",
	  "—+dir place",
	  "open store",
	  "service",
	 }
	 debug_tut=true
 end
end

function resume()
 day=0
 day_n+=1
 day_start=false
 day_end=false
 door(false)
 state_change(main_update,main_draw)
end

function init_items()
--[[
0 food
1 weapon/tool
2 equipment
3 material 
]]--
 item_types={
  "food",
  "tool",
  "wear",
  "good",
  "furniture"
 }
 local items_init={
 	{"wheat", 133, 3,1,"ARTISAN ORGANIC","LOCALLY SOURCED"},
  {"fungi", 136, 4,1,"NOT THE MAGIC","KIND."},
  {"apple", 137, 5,1,"SWEET N` TASTY",""},  
  {"bread", 135, 6,1,"THE PROLETARIAT","PACIFER"},
  {"potion",128, 7,1,"NOW WITH REAL","ARTIFICAL APPLE FLAVOR"},
    
  {"shovel",150, 7,2,"RATED ’’’’\nBY SHOVEL ASOC."},
  {"hammer",148, 8,2,"*NAILS SOLD","SEPARATELY*"},
  {"axe",   145, 9,2,"AN AXE-LLENT","PURCHASE"},
  
  {"sword", 144,15,2,"ADS N' VENTURE","MORE YOUR STYLE"},
  {"spear", 153,13,2,"LESS METAL=","MORE PROFITS!"},
  {"shield",152,12,2,"MADE FROM ONLY","QUALITY BASAL"},
  {"bow",   151,17,2,"BOWS AND ARROWS","MODEL AT PLAY"},
  {"armor", 160,20,3,"SAVE $ IF NOT","YOUR LIFE!"},
  {"pants", 168,10,3,"PRE-WORN IN","GUARNTEE!"},
  {"boots", 161,10,3,"BRE: BOOT","READY TO EAT"},
   
  {"book",  180,20,4,"DUNGEONCRAWLING","FOR DUMMIES"},
  {"amulet",163,30,3,"GOLD SUTED","AND ZINC CORE"},
 
  {"table",  1,10,5,"showcase items","for patrons"},
  {"buyer",  5,15,5,"patrons buy","items for 125%"},
  {"seller", 4,15,5,"patrons sell","items for 75%"},
  {"request",6,15,5,"patron request","items for 150%"},
  {"hotdog", 138, 6,1,"BUT IS IT","A SANDWICH?"},
--  {"block",2,10,5,"decrotative.,"""}
 }
 unlocks={
 	{"shovel","apple","hotdog","table","buyer"},
  {"wheat","bread","seller"},
  {"hammer","request"},
  {"potion"},
  {"axe"},
  {"pants"},
  {"boots"},
  {"spear"},
  {"fungi"},
  {"shield"},
  {"sword"},
  {"armor"},
  {"bow"},
  {"book"},
  {"amulet"},
 }
 total_unlocks=#unlocks
 items={}
 local itemnames={}
 for i,item in ipairs(items_init) do
  local newitem={
  	name=item[1],
  	s=item[2],
  	cost=item[3],
  	type=item[4] or 1,
  	desc=item[5] or "",
  	desc2=item[6] or "",
  	count=0,
  	i=i
  }
  items[item[1]]=newitem
  items[newitem.s]=newitem
  
  add(itemnames,newitem.name)
--  add(items,newitem)
 end
-- if debug then
--  unlocks[1]=itemnames
-- end
end

function init_item(s,x,y)
	local entry=items[s] or {}
	local item=init_obj(entry.s or s,x,y)
	item.name=entry.name
	item.cost=entry.cost or 10
	item.spd=.5
	item.i=entry.i
	if fget(s,7) then
	 item.h=2
	end
 return item
end

function add_item(obj,s)
	local item=add(obj,type(s)=="number" and init_item(s) or s,1)
	if item then
	del(objs,item)
	item.ox=obj.ox
	item.oy=obj.oy-2
	item.pin=true
	end
end

function init_map()
 sellvs={}
 buyvs={}
 reqvs={}
 for x=mx,mx+mw do
  for y=my,my+mh do
   init_tile(x,y)
  end
 end
end

function init_floater(obj,t)
 add(particles,{s=t,x=obj.ox,y=obj.oy-8,t=32,draw=floater_draw})
end

function add_unlocks()
 while total_unlocks-#unlocks!=day_n and #unlocks!=0do
		for name in all(unlocks[1])do
--		 printh(name)
		 local item=items[name]
		 if item then
			 if not fget(item.s,4)then 
			 	add(rnd_items,item)
			 	add(buyables,item)
				else
				 add(buyables,item,1)
			 end
		 end
		end
		deli(unlocks,1)
	end
end


function count_stock()
	add_unlocks()
-- if debug then
--  buyables={}
--  for k,v in pairs(items)do
--   add(buyables,v)
--  end
-- end
 curs_i=1
 
 for item in all(buyables) do
  item.count=0
 end
 for item in all(p) do
--  printh(tostring(item))
  for buy in all(buyables) do
	  if buy.s==item.s then
	   buy.count+=1
	  end
	 end
	 del(p,item)
 end
end

function set_stock()
 for item in all(buyables) do
  if item.count!=0 then
	  for i=1,item.count do
	   add_item(p,item.s)
	  end
  end
 end
 curs_i=1
end

function init_furniture(m,x,y)
 local obj=type(m)=="table" and m or init_obj(m,x,y,nil,nil,1,2)
 local m=obj.s
 obj.x=x
 obj.y=y
 del(objs,obj)
 add(acts,obj)
 if m==1 and not get_obj(x,y) then
 	add(slots,obj)
 elseif m==5 then
  add(buyvs,obj)
 elseif m==4 then
  add(sellvs,obj)
 elseif m==6 then
 	add(reqvs,obj)
 else
  del(acts,obj)
 end
 add(furniture,obj)
end

function init_tile(x,y)
 local m=mget(x,y)
 local xy=v(x,y)
 if m==13 or m==14 then
	 entrance=init_obj(m,x,y,nil,draw_base,1,2)
  add(acts,entrance)
  door(false)
  mset(x,y,29)
 elseif m==63 then
  spawn=xy
 elseif m==64 then
	 p=init_obj(m,x,y,update_player,draw_char,1,2)
 	p.z=2
 	p.cash=50
-- 	p.flpx=true
 	bx,by=0,0
 	mset(x,y)
 else
  if fget(mget(x,y),2) then
	  add(inv_shop,init_item(m,x,y))
	  mset(x,y,1)
	  m=1
	 end
	 if fget(m,4)then
  	init_furniture(m,x,y)
  end
 end
end
-->8
--update
function _update60()
 upd()
 t+=1
 if day_start and not day_end then
 	day+=1
 end
 
end

function closing_time()
 open=false
 day_end=true
 door(false)
 if #customers==0 then
  ledger_i=1
  ledger_lerps={nil,nil,nil,0,0,0,0,0,nil,loan}
--  loan_pay=-min(flr(max(5+day_n,p.cash*.1)),loan)
--  loan_pay=max(loan_pay,-20)
  printh(loan)
  if loan>0then
	  loan_pay-=1
--	  local payed=loan_pay
	  p.cash+=loan_pay
	  loan+=max(-p.cash,loan_pay)
	  loan=max(loan,0)
	  
  end
  state_change(score_update,score_draw)
 end
end

function main_update()
	if day>day_length then
 	closing_time()
 end
 if open and #customers<#furniture/4 and rnd()>.99 and open then
  local new=init_obj
  (flr(rnd(31))+65,
  spawn.x,spawn.y,update_customer,draw_char,1,2)
  add(customers,new)
  if new.s>79 then
   new.s+=16
  end
  new.state=customer_enter
  local emoji=init_obj(94,0,0,nil,draw_emoji)
  emoji.parent=new
  emoji.z=1000
  new.emoji_obj=emoji
  new.tone=ceil(rnd(2))
  new.pal=rnd({8,9,11,12})
 end
	foreach(objs,function(obj)obj:update()end)
end

function update_player(obj)
 local dx,dy=
 btnp(0) and -1 or btnp(1) and 1 or 0,
 btnp(2) and -1 or btnp(3) and 1 or 0
 building=btn(—)
 if building then
  local dx,dy=
 	btn(0) and -1 or btn(1) and 1 or 0,
 	btn(2) and -1 or btn(3) and 1 or 0
  if dx!=0then
   dy=0
  end
  if dx!=0 or dy!=0 then
   bx,by=dx,dy
   sfx(57)
	 end
	 if (bx!=0 or by!=0) and dx==0 and dy==0 then
	  build_tile(obj.x+bx,obj.y+by)
	  bx,by=0,0
	 end
 else
	 if dx!=0 or dy!=0 then
	  move(obj,dx,dy)
	 end	 
 end
	local item=obj[1]
	if btnp(Ž) and item and #p>1 then
	 deli(obj,1)
	 add(obj,item)
	 sfx(49)
	 tutorial_check("swap")
	end 
end

function title_update()
 if btnp(Ž) or btnp(—) then
  load_game()
--  extcmd("rec")
  sfx(54)
 end
end

function score_update()
 if btnp(Ž) or btnp(—) then
  if not game_over() then
   save_game()
   count_stock()
   profits=0
 		expense=0
   state_change(stock_update,stock_draw)  
  end
  sfx(54)
 end
end

function stock_update()
 if btnp(”) then
  curs_i=(curs_i-2)%#buyables+1
  sfx(48)
 end
 if btnp(ƒ) then
  curs_i=(curs_i)%#buyables+1
  sfx(48)
 end
 local item=buyables[curs_i]
 if btnp(‹) and item.count>=1 then
  item.count-=1
  p.cash+=item.cost
  sfx(50)
  profits+=item.cost
 end
 if btnp(‘) and p.cash>=item.cost then
  item.count=min(item.count+1,99)
  p.cash-=item.cost
  expense-=item.cost
  sfx(51)
 end
 if btnp(Ž) or btnp(—) then
  resume()
  set_stock()
  sfx(54)
 end
end

function game_over()
 local cash=p.cash
 if (loan<=0 or cash<0) and not win then
 	win=loan<=0
-- 	win=true
 	if win then
 		state_change(win_update,win_draw)
 	else
	 	state_change(lose_update,lose_draw)
 	end
 	
 	return true
 end
end

function win_update()
	if btnp(—) then
  count_stock()
  profits=0
 	expense=0
  state_change(stock_update,stock_draw)  
  sfx(54)
 end
 if btnp(Ž)then
  state_change(title_draw,title_update)
  sfx(54)
 end
end

function lose_update()
 if btnp(Ž) then
  state_change(title_update,title_draw)
  sfx(54)
 end
 if btnp(—)then
  load_game()
 end
end

function build_tile(x,y)
 if not bounds(x,y) then
  local m=mget(x,y)
  if fget(m,4) then
   local obj=get_obj(x,y)
   local furn=get_obj(x,y,furniture)
   if furn and (m==4 or m==5 or m==6)and #furn!=0 then 
    furn[1].t=0
    init_floater(p,"declined!")
   elseif obj then
    tile_interaction(x,y)
   else
		  mset(x,y)
		  add_item(p,furn)
		  if fget(m,7) and not fget(mget(x,y+1),4) then
		   mset(x,y+1)
		  end
		  auto_tile(x,y-1)
		  del(objs,furn)
		  del(furniture,furn)
		  del(slots,furn)
		  del(sellvs,furn)
		  del(buyvs,furn)
		  del(reqvs,furn)
		  del(acts, furn)
		  tutorial_check(furn)
	  end
  elseif fget(m,6) then
   local item=p[1]
   local obj=get_obj(x,y)
   if item and not obj and fget(item.s,4) then
	   local s=item.s
		  mset(x,y,16)
	   local accessible=true
	   local access=dijkstra_map(spawn.x,spawn.y)
--		  for mx=0,mw do
--		   for my=0,mh do
-- 		   if fget(mget(mx,my),5) then
--				   if not ’pathfinding(spawn,v(mx,my))then
--				    accessible=false
-- 			    break
--			    end
--			   end
--			  end	
--			 end
    for obj in all(furniture)do
     if not access[obj.x][obj.y] then
      accessible=false
      break
     end
    end
			 for obj in all(objs)do
			  if obj.draw==draw_char then
			  	if not access[obj.x][obj.y] then
				   accessible=false
 			   break
			   end
			  end
			 end
	   if accessible then
	    mset(x,y,s)
     auto_tile(x,y)
		   del(p,item)
		   local xy=v(x,y)
		   init_furniture(item,x,y)
		   tutorial_check(xy)
		   sfx(60)
			 else
			  mset(x,y,0)
			  auto_tile(x,y-1)
			  init_floater(p,"blocking!")
		  	sfx(61)
		  end		  
		 end
  end
 end
end

function auto_tile(x,y)
 local m=mget(x,y)
	if fget(m,7) and mget(x,y+1)==0 then
		mset(x,y+1,m+16)
	end
end
-->8
--draw
function _draw()
	palchange()
 drw()
-- if t==7000then
--  extcmd("video")
-- end
end

function main_draw()
 isorty(objs)
 cls(2)
 rect(3,0,60,64,4)
 rectfill(4,-1,59,64,0)
-- printh(daypal[flr(day/day_length)+1])
 rectfill(4,-1,59,11,daypal[flr(day/day_length*#daypal)+1])
 camera(-4,8)
 map()
 foreach(objs,function(obj) obj:draw() end)
 foreach(particles,function(obj)obj:draw()end)
-- foreach(debugs,debug_square)
 if debug then
	 for slo in all(furniture) do
	  x,y=slo.x*8,slo.y*8
	  rect(x,y,x+7,y+7,6)
	 end 
	 for slo in all(slots) do
	  x,y=slo.x*8,slo.y*8
	  rect(x,y,x+7,y+7,11)
	 end
	 for slo in all(inv_shop) do
	  x,y=slo.x*8,slo.y*8
	  rect(x,y,x+7,y+7,7)
	 end
	 for slo in all(buyvs) do
	  x,y=slo.x*8,slo.y*8
	  rect(x,y,x+7,y+7,9)
	 end
	 for slo in all(sellvs) do
	  x,y=slo.x*8,slo.y*8
	  rect(x,y,x+7,y+7,3)
	 end
	 for slo in all(reqvs) do
	  x,y=slo.x*8,slo.y*8
	  rect(x,y,x+7,y+7,10)
	 end
--	 	 for slo in all(objs) do
--	  x,y=slo.x*8,slo.y*8
--	  rect(x,y,x+7,y+7,13)
--	 end
 end


 draw_ui()
 camera()
end

function draw_ui()
 camera(0,0)
 if tutorial and #tutorial!=0then
  outline(function()
  
  local obj=tutorial[1]
  local x,y=p.ox,p.oy
  if type(obj)=="table"then
   x,y=obj.x*8,obj.y*8
  end
  y+=sin(t/32)*2
  if(obj==entrance)y+=11
  spr(237,x+4,y-16)
  local mes=tutorial_mes[1]
  print(mes,x-#mes*2+8,y-17,7)
  end)
 end 
-- draw_clock()
 draw_cash()
 if log then
	 rectfill(0,49,63,63,3)
	 fillp(0b0101101001011010.1)
	 rect(0,49,63,63,11)
	 fillp()
	 print(log,2,51,7)
	 if log_t==0 then
	  log=nil
	 end
	 log_t-=1
 end
end

function draw_cash()
 cash_l=lerp(cash_l,p.cash,.25)
 outline(function()
 digit_print("$"..flr(cash_l),44,2,9,4)
 end)
end

function draw_clock(obj)
 angle=day/day_length-.5
 x,y=obj.ox,obj.oy
 xr,yr=x+3*sin(angle)+4,
       y+3*cos(angle)+4
 circfill(x+4,y+4,3,7)
 line(x+4,y+4,xr,yr,0)
 spr(44,x,y)
end

function background()
 cls(3)
 fillp(0b0101101001011010.1)
 rect(1,1,62,62,5)
 fillp()
end

function textscreen(y)
	background()
 local pa={5,0,2,4,15,7}
 for f=1,5 do
 	for i=0,5 do
   pal(1,pa[f])
   local m=mget(i,y)
   if m!=0 then
  		spr(m,10+i*9,10+sin((t+i*4+f*8)/80)*5)
  	end
  	local m=mget(i,y+1)
  	if m!=0 then	
  		spr(m,6+i*9,18+sin((t+i*4+f*8)/80)*5)
   end
  end
 end
end

function title_draw()

 textscreen(10)
-- spr(128,0,30,8,1)
-- map()
-- print("press Ž\n(z or c)\nto start",16,40,flr(t/32)%2==0 and 15 or 11)
 cprint("—start",36,blink(7,11))
 cprint("CODE BY MUNRO",51,11)
 cprint("MUSIC BY JOHN",56)

end

function score_draw()
 background()
 cursor(3,3,7)
 x=4
 local net=profits+expense+loan_pay
	local ledger={
--	 {"	~ day "..day_n.." ledger~",3,6},
	 {"",7},
	 {"",27},
	 {"",41},
		{"gained $",11,profits>0 and 11 or 7,profits},
	 {"spent  $",17,expense<0 and 8 or 7,expense},
		{"loans  $",23,8,loan_pay},
	 {"net    $",31,net<0 and 8 or 11,net},
		{"balance$",37,7,p.cash},
		{"remaining loan",45},
		{"$",51,8,loan},
		{"    —next",56,blink(7,11)},
	}
	cprint("~day "..day_n.."~",3,6)
 for i=1,ledger_i do
  local txt=ledger[i]
  local ler=ledger_lerps[i]
 	sprint(txt[1]..(ler and flr(ler)or ""),4,txt[2],txt[3])
 end
 local fin=ledger[ledger_i][4]
 local ler=ledger_lerps[ledger_i]
 if fin and ler and fin!=ler then
 	ledger_lerps[ledger_i]=lerp(ler,fin,.1)
  if fin-ler>1 then
   sfx(53)
  elseif fin-ler<-1 then
   sfx(52)
  end
 else
 	ledger_i=min(#ledger,ledger_i+1)
 end
end

function draw_char(obj)
	update_lerp(obj)
--	printh("char")
 local x,y=obj.ox,obj.oy+
 (check_move(obj) and 0 or 
 sin(t/16)/2
 )
 outline(function(n,i)
  if i==0 then
  	if obj.tone==2 then
	   pal(15,4)
	 		pal(4,15)
 		end
-- 		pal(9,1)
 		pal(11,0)
  end
	 spr(obj.s,x,y-(obj.h*8-7),1,obj.h,obj.flpx,obj.flpy)
 end,0)
-- if obj.state==customer_queue_buy or
--    obj.state==customer_queue_sell then
--	 fillp()
--	 rectfill(x+1,y-6,x+7,y+6,0)
--	 fillp()
-- end
 --hands
 for i=#obj,1,-1 do
  local item=obj[i]
 
	 if item then
		 local target=v(x,y-(#obj-i)*2-item.h*3)
	  
	  local build=(item==p[1] and building and fget(item.s,4))
	  if build then
		  target.x=(p.x+bx)*8
		  target.y=(p.y+by)*8
		 end  
	  item.x=target.x/8
	  item.y=target.y/8
--	  printh("char item")
--   if not item.s then
--	  printh(tostring(item))
--	  end
--	  printh(item.s)

	  if item.pin then
	   item.ox=lerp(item.ox,target.x,mid(0,1,1/(#obj-i+.1)))
	   item.oy=lerp(item.oy,target.y,mid(0,1,1/(#obj-i+.1)))
	  elseif check_move(item) then
	   item.pin=true
	  end
	
		 item:draw()
	 end
 end
 if #obj!=0 then
  if obj.tone==2 then
	  pal(15,4)
	 	pal(4,15)
 	end
	 spr(47,x,y)
	end
	palchange()
-- if debug then
--  line()
--	 color(8)
--	 for p in all(obj.path) do
--	  x,y=p.x*8+4,p.y*8+4
--	  line(x,y)
--	 end
--	 for p in all(obj.path) do
--	  x,y=p.x*8+4,p.y*8+4
--	  circ(x,y,2,14)
--	 end
-- end
 if obj==p and building then
  outline(function()
  for i=1,4do
   local l=3
   if dirx[i]==bx and diry[i]==by then
    l=5
   end
   spr(233+i,x+dirx[i]*l,y+diry[i]*l)
  end
--  ?"  ",x-4,y,7
--  spr(235,x,y-4,1,2)
  end)
--  p[1].ox=20
 end
 if debug then
  local states={
   customer_browse,
   customer_enter,
   customer_buy,
   customer_return,
   customer_leave,
--   customer_queue,
--   customer_queue_sell,
   customer_sell,
   customer_wander,
   customer_request,
  }
  local state_codes={
  "bro",
  "ent",
  "buy",
  "ret",
  "lea",
--  "que",
--  "qse",
  "sel",
  "wan",
  "req",
  }
--  outline(function()
--		print(state_codes[contains(states,obj.state) or 1],x,y,7)
--  end)
 end
end

function draw_emoji(obj)
 local par=obj.parent
 local x,y=par.ox,par.oy-12
 local emoji=par.emoji
	if emoji then
  spr(238,x-1,y,2,2)
--  local c=0
  if type(emoji)=="table" then
  	spr(emoji.s,x,y)
  else
	 	local f=type(emoji)=="number" and digit_print or  print
	--	 printh(emoji)
	--	 printh(par.state==customer_sell)
		 f(
			 emoji,
			 x,y+1,
			 par.emoji_c,
			 2
		 )
	 end
--	  spr(66,x+1,y-12)
--		spr(150,x,y-1)
	end
end

function stock_draw()
 cls()
 background()
 for i=0,4 do
  local n=curs_i+i-2
  if n>0 and n<=#buyables then
  local item=buyables[n]
 
  local txt=item.name
 
  y=i*7+2
  rectfill(3,y+1,60,y+6,3)
		local sx,sy=spr_sspr(item.s)
--		spr(item.s,3,y)
		sspr(sx+1,sy+1,6,6,3,y+1)
  sprint(item.name,23,y+1,n==curs_i and 7 or 6)
  sprint(item.count,52,y+1)
  sprint("$"..item.cost,10,y+1)
  end
 end
 camera()
 local sx,sy=convert_spr(1)
 clip()
 local item=buyables[curs_i]
-- outline(function()
-- digit_print("$"..flr(p.cash),44,2,9,4)
-- end)

 local typ=item_types[item.type]
 
 cprint("",37,6)
-- cprint(item.name,40)
 sprint(" "..item.count.."",44,17,7)
 sprint(item.desc,3,42,6)
 sprint(item.desc2,3,49)
 pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
-- spr(item.type*16+112,2,42)
 palchange()
 cprint("—done",56,7)
 draw_cash()
end

function lose_draw()
-- cls(14)
 textscreen(14)
-- print("you went\ninto debt",16,40,7)
-- print("press Ž\n(z or c)\nto try",16,40,flr(t/32)%2==0 and 15 or 11)
 local y=sin(t/100)*1.5
 cprint("oh no! you",36+y,8)
 cprint("went into debt!",42+y)
 cprint("Žmain menu or",49,blink(11,7))
 cprint("—retry day",55,blink(7,11))
end

function win_draw()
 textscreen(12)
--	local c=flr(t/32)%2==0 and 15 or 11
 cprint("payed off loans",36,11)
 cprint("good job!",42)
 cprint("Žretire or",49,blink(11,7))
 cprint("—keep playing",55,blink(7,11))

end

function floater_draw(obj)
 outline(function()
  print(obj.s,obj.x-#obj.s*2,obj.y+obj.t/4,9)
 end)
 obj.t-=1
 if obj.t==0 then
  del(particles,obj)
 end
end
-->8
--shared logic
function door(state)
 if not day_end then
		open=state
	 entrance.s=open and 13 or 14
	 entrance.z=open and 1000 or 0
	 if state then
	 	if not day_start then
	 		day_start=true
	 		sfx(56)
	 	end
	 end
 end
end

function tutorial_check(obj)
 local tut=tutorial[1]
 if tut then
		if obj==tut or 
			(tutorial_mes[1]=="—+dir place" and type(obj)=="table" and obj.x==tut.x and obj.y==tut.y) 
			then
		 deli(tutorial,1)
		 deli(tutorial_mes,1)
		end
	end
end

function tile_interaction(x,y)
 local m=mget(x,y)
 local obj=get_obj(x,y)
 local act=get_obj(x,y,acts)
 local item=p[1]
 local customer
 if act then
  customer=act[1]
 end
 if m==5 and obj then
--		printh("grab_play_sell")
		grab_item(p,obj)
		tutorial_check(get_obj(x,y,buyvs))
	elseif m==4 and obj then
	 local cost=flr(obj.cost*.75)
	 if p.cash>=cost then
--	  printh("grab_play_buy")
	 	grab_item(p,obj)
	 	drop_cash(p,x,y,cost)
	 end
	elseif m==6 then
	 local req=get_obj(x,y,reqvs)[1]
	 if obj then
	  grab_item(p,obj)
	 end
	 if item and req and req.emoji and item.s==req.emoji.s then
	 	drop_item(p,x,y)
	 end
	elseif act==entrance and #tutorial<=2 then
	 door(true)
	 tutorial_check(entrance)
 elseif fget(m,3) then
 	if obj then
   grab_item(p,obj)
   tutorial_check(obj)
  else
   drop_item(p,x,y) 
  end 
 end
end

function grab_item(obj,item)
 --!!grab error
 del(inv_shop,item)
 del(objs,item)
 if mget(item.x,item.y)==1 then
  add(slots,get_obj(item.x,item.y,furniture))
 end
 if item.s==191 then
--  add(particles,
--  {
--  s=191,
--  spd=.5,
--  ox=item.ox,
--  oy=item.oy,
--  draw=money_draw,
--  parent=obj,
--  cost=item.cost
--  })
--  del(particles,obj)
	 local cost=item.cost
	 obj.cash+=cost
	 del(obj,item)
	 if obj==p then
	  sfx(58)
	  profits+=cost
	  init_floater(p,"+$"..cost)
	 else
		 expense-=cost
			sfx(47)
			init_floater(p,"-$"..cost)
	 end
 else
 	add(obj,item,1)
 end
 sfx(59)
end

--function money_draw(obj)
-- obj.x=obj.parent.ox/8
-- obj.y=obj.parent.oy/8
-- draw_spr(obj)
-- if check_move(obj)then
--  del(particles,obj)
--	 local cost=obj.cost
--	 obj.parent.cash+=cost
--	 del(obj,item)
--	 if obj.parent==p then
--	  sfx(58)
--	  profits+=cost
--	  init_floater(p,"+$"..cost)
--	 else
--		 expense-=cost
--			sfx(47)
--			init_floater(p,"-$"..cost)
--	 end
-- end
--end

function drop_item(obj,x,y)
 local item=obj[1]
 if item and not fget(item.s,4) then
	 deli(obj,1)
		item.x=x
		item.y=y
		item.ox=obj.ox
		item.oy=obj.oy-2
		add(objs,item)
		if mget(x,y)==1 then
			add(inv_shop,item)
			tutorial_check(del(slots,get_obj(x,y,slots)))
		end
		item.pin=false
		sfx(62)
		del(obj,item)
 end
 return item
end

function drop_cash(obj,x,y,amount)
 amount=flr(amount)
 local item=add(obj,init_item(191,obj.x,obj.y),1)
 del(objs,item)
 drop_item(obj,x,y)
 obj.cash-=amount
 obj.emoji=amount
 item.cost=amount
 item.owner=obj
 item.spd=.75
 return item
end

function move(obj,dx,dy)
 local x,y=obj.x,obj.y
 obj.flpx = dx==0 and obj.flpx or dx<0
 if not bounds(x+dx,y+dy) then
  if dx!=0 then
   dy=0
  end
  if obj==p then
		 tile_interaction(x+dx,y+dy)
		end
	 if check_tile(x+dx,y+dy,1) and obj==p then
	  dx=0
	  dy=0
	 else
	  sfx(63)
		end
	 obj.x+=dx
	 obj.y+=dy
	end
end

function state_change(nupd,ndrw)
 upd=nupd
 drw=ndrw
 if t!=0 then
	 fadedown()
	 fadeup()
 end
end
-->8
--ai
--[[
-------+-------------------------
target | desired point
path   | path to point
-------+-------------------------
init   | first frame of state
arrive | first frame at point
ready  | is currently at point
-------+-------------------------
state  | current action state
lstate | change state if dif
nstate | stored next state
-------+-------------------------
emoji  | visual aid for state
emoji_c| emoji color
t      | track timed actions
flash  | if timer is running out
--]]
function update_customer(obj)
-- if not open then
--  if obj.state==customer_sell then
--   grab_item(obj,obj.target)
--  end
--  if obj.state==customer_buy or 
--   obj.nstate==customer_buy then
--   obj.state=customer_return
--  else
--   obj.state=customer_leave
--  end
-- end
 state_update(obj)
end

function state_update(obj)
 obj.t=max(obj.t-1,0)
 if not obj[1] or obj[1].pin then
  if obj.state!=obj.lstate then
	  obj.lstate=obj.state
	  obj.ready=false
	  obj.arrive=false
	  obj.init=true
	  obj.flash=false
	  obj.emoji=nil
	  obj.emoji_c=0
	  obj.target=nil
	 else
 		obj.init=false
	 end
	 local result=obj:state()
 	obj.state=result or obj.state
  obj.arrive=false
 end
 --create path
 if (obj.target and obj.init) or obj.repath then
 	obj.path=’pathfinding(obj,obj.target)
 	if not obj.path then
 	 if obj.state==customer_buy then
 	  obj.state=customer_return
 	 else
 	 	obj.lstate=nil
 	 end
-- 	 printh("failed path")
 	end
 	obj.repath=false
 end
 --player removed target,retry
	if contains(p,obj.target) then
	 obj.lstate=nil
	 obj.target=nil
	end
 --move on path
 if (not obj[1] or obj[1].pin) and obj.path then
 	if move_on_path(obj) then
 	 obj.arrive=true
 	 obj.ready=true
 	 obj.path=nil
 	end
 end
end

function customer_enter(obj)
 if obj.init then
  obj.target=v(3,3)
 end
 if obj.ready then
  local r=rnd(#reqvs+#sellvs+#buyvs)
	 if #buyvs!=0 and r<=#buyvs then
	  if #inv_shop!=0 then
	   return customer_browse
	  else
	  	return customer_wander
	  end
	 elseif #sellvs!=0 and r<=#sellvs+#buyvs then
	 	add_item(obj,rnd(rnd_items).s)
	  return customer_sell
	 else
   return customer_request 
  end
 end
end

function customer_browse(obj)
	--!!
	if obj.init then
  local target=del(inv_shop,rnd(inv_shop))
  if target then
  	obj.target=target
  else
 	 return customer_leave 
  end
	end
	if obj.arrive then
	 obj.t=128
	 obj.emoji="??"
	 obj.flpx =obj.target.x-obj.x<0
	end
	if obj.ready and obj.t<=0 then
	 local r=rnd()
	 --chance to leave
	 if r>.9 and obj.lstate==customer_browse then
	  add(inv_shop,obj.target)
	  return customer_leave
	 end
	 if r>.2 then
	  --decide to buy
	 	grab_item(obj,obj.target)
			return customer_buy
	 else
	  --try browsing again
	  obj.lstate=nil
	  add(inv_shop,obj.target)
	 end
	end
end

function customer_buy(obj)
 if #buyvs==0 then
  return customer_return
 end
	if obj.init then
	 del(obj.target,obj)
	 obj.target=rnd(buyvs)
	 add(obj.target,obj)
	end
 if obj.arrive then
  obj.t=256+#obj.target*32
 end
 if obj.ready then
  --item sold by player
  --!!
  --drop cash once first in line
  if not obj.done then
	  if contains(obj.target,obj)==1 then
	  	if obj[1] then
		  	local cost=ceil(obj[1].cost*1.25)
		  	drop_cash(obj,obj.target.x,obj.target.y,cost)
		   obj.done=true
		   obj.t=256
	   else
	    return customer_return
	   end
   end
  else
   local item=get_obj(obj.target.x,obj.target.y)
  --player sold item to customer
   if not item then
    del(obj.target,obj)
		  return customer_leave
		 end
		 --player did not sell item, return to a rnd slot
	  if obj.t<=0 then
	 		grab_item(obj,item)
	 		sfx(61)
	 		del(obj.target,obj)
  		return customer_return
	  end
  end
 end
end

function customer_return(obj)
 if not contains(slots,obj.target) or not obj.target then
  obj.target=rnd(slots)
 end
 if obj.ready then
  if obj[1].s!=191 then
	  drop_item(obj,obj.target.x,obj.target.y)
	  return customer_leave
  end
 end
end

function customer_sell(obj)
 if #sellvs==0 then
  return customer_leave
 end
	if obj.init then
  obj.target=rnd(sellvs)
	end 
	local x,y=obj.target.x,obj.target.y
 if obj.arrive then
  add(obj.target,obj)
  obj.t=256+#obj.target*32
 end
 if obj.ready then
  local item=get_obj(x,y)
  if obj.done then
  	if obj.emoji>p.cash then
			 obj.emoji_c=8
			else
				obj.emoji_c=0
			end
	  if item and item.s==191 then
				grab_item(obj,item)
				del(obj.target,obj)
				return customer_leave
		 end
  elseif contains(obj.target,obj)==1 then
	  obj.done=true
	  obj.emoji=flr(obj[1].cost*.75)
  	drop_item(obj,x,y)
  	obj.t=256
	 end
	 if obj.t<=0 then
		 if obj.done and item then
		 	grab_item(obj,item)
		 end
		 del(obj.target,obj)
			return customer_leave
		end
 end
end

function customer_request(obj)
 if #reqvs==0 then
  return customer_leave
 end
 if obj.init then
  obj.target=rnd(reqvs)
  add(obj.target,obj)
  obj.t=512+#obj.target*32
 end
 local x,y=obj.target.x,obj.target.y
 if obj.ready then
  if obj.done then
  	local item=get_obj(x,y)
   if item then
				grab_item(obj,item)
				local cash=drop_cash(obj,x,y,item.cost*1.5)
				grab_item(p,cash)
				del(obj.target,obj)
				return customer_leave
		 end
		elseif contains(obj.target,obj)==1 then
	  obj.done=true
	  obj.emoji=rnd(rnd_items) 
	  obj.t=512
  end
  if obj.t<=0 then
		 del(obj.target,obj)
			return customer_leave
		end
 end
end

function customer_leave(obj)
 if obj.init then
	 obj.target=spawn
	 obj.emoji="Š"
	 obj.t=32
	end
 if obj.t==0 then
  obj.emoji=nil
 end
 if obj.ready then
  del(objs,obj)
  del(customers,obj)
  del(objs,obj.emoji_obj)
 end
end 

function customer_wander(obj)
 if obj.ready then
  if #inv_shop!=0 then
   return customer_browse
  elseif obj.t<15 then
   return customer_leave
  else
   obj.lstate=nil
  end
 end
 if obj.init then
  if(obj.t==0)obj.t=255
  obj.target=rnd(slots)
 end
end

function move_on_path(obj)
 local path=obj.path
 if #path==0 or(#path==1 and fget(mget(path[1].x,path[1].y),0)) then
  return true
 end
 local nextnode=path[#path]
 if	check_move(obj) and nextnode then
  if fmget(nextnode.x,nextnode.y,0) then
   obj.repath=true
  else
	  move(obj,nextnode.x-obj.x,nextnode.y-obj.y)
	  del(obj.path,nextnode)
  end
 end
end
-->8
--save system and unused/debug code
function save_game()
 dset(0,p.cash)
 dset(1,day_n)
 local i=2
 for x=0,6do
  for y=2,8do
   local item=get_obj(x,y,inv_shop)
   local obj=get_obj(x,y)
   if obj==p then
    dset(i,obj.s)
   elseif item then
    dset(i,item.s)
   else
   	dset(i,mget(x,y))
   end
   i+=1
  end
 end
 for i,item in ipairs(p)do
  dset(50+i,item.s)
--  printh(item.s)
 end
end


function new_game()
 for i=0,63do
  dset(i,0)
 end
 load_game()
end


--reset_pin=true
function load_game()
 if reset_pin then
  for i=0,63do
   dset(i,0)
  end
 end
 reload(0x2000, 0x2000, 0x1000)
 if dget(0)!=0then
  local f=2
	 for x=0,6do
	  for y=2,8do
	   mset(x,y,dget(f))
	   f+=1
	  end
	 end
	 init_game()
	 init_map()
	 p.cash=dget(0)
	 day_n=dget(1)
	 
	 loan_pay+=day_n
	 for i=1,day_n do
	 	loan=max(0,loan-5-i)
	 end
	 if loan==0then
	  win=true
	 end
	 for i=51,63do
	  local s=dget(i)
--	  printh(s)
	  if s!=0then
	   add_item(p,s)
	  end
	 end
--	 resume()
	 count_stock()
	 profits=0
 	expense=0
	 state_change(stock_update,stock_draw)
	else
--	 printh("new_game")
	 init_game()
	 init_map()
	 resume()
	 enable_tutorial()
	end
end

function restart_day()
 load_game()
end

function init_game()
 objs={}
 inv_shop={}
	entrances={}
	customers={}
	furniture={}
 rnd_items={}
 buyables={}	
	slots={}
	acts={}
	particles={}
	profits=0
	expense=0
	init_items()
 graph=init_graph(true)
 init_obj(0,0,1,nil,draw_clock)
 day_n=0
	tutorial={}
	loan=150
	loan_pay=-5
	win=false	
	add_unlocks()
end

--function init_game()

--	if debug then
--	 day_n=1
--	 count_stock()
--	end




--[[
00 title song

15 main song?

47 end of day tune

48 menu cycle
49 cycle items
50 menu decline
51 menu confirm
52 money lose score
53 money gain score
54 next scene
55 
56 !buy item player
57 building
58 grab money player
59 grab item
60 furniture thunk
61 mistake
62 drop item thunk
63 footstep


points of failure

no sellv
no buyv
no tables after grabbing
all tables filled after grabbing




]]--

--function debug_square(x,y,c)
-- if btn(—,1) then
-- repeat
-- camera(-4,8)
-- rect(x*8+1,y*8+1,x*8+6,y*8+6,c or 8)
-- flip()
-- camera()
-- until btn(Ž)
-- end
--end

function wait(t)
 for i=0,t do
  flip()
 end
end
function tostring(any)
 if type(any)=="function" then 
  return "function" 
 end
 if any==nil then 
  return "nil" 
 end
 if type(any)=="string" then
  return any
 end
 if type(any)=="boolean" then
  if any then return "true" end
  return "false"
 end
 if type(any)=="table" then
  local str = "{ "
  for k,v in pairs(any) do
   str=str..tostring(k).."->"..tostring(v).." "
  end
  return str.."}"
 end
 if type(any)=="number" then
  return ""..any
 end
end

--function customer_queue(obj)
--	--get into line, if obj is the first one then change to buy
-- if obj.init then
--		if not obj.line then
--		 add(obj.queue,obj)
--		end
--		obj.line=contains(obj.queue,obj)
--		if obj.line==1 then
--	 	return obj.nstate
--		end	
--		obj.target=obj.queue
-- end
-- --move up in line
---- printh("queue2")
-- if contains(obj.queue,obj)!=obj.line then
--	 obj.lstate=nil
--	end
--end

--	elseif m==37 then
--	 if item.owned and p.cash>item.cost then
--	  item.owned=false
--	  drop_cash(p,x,y,item.cost)
----	  	tutorial_check(get_obj(x,y,buyvs))
----	  tutorial_check(get_obj(x,y,sellvs))
--	 end
-- elseif m==31 then
-- 	for item in all(p) do
--	  if item.owned then
--	   log="you must pay\nfor "..item.name
--	   log_t=128
--	   return
--	  end
--	 end
--	 travel(0)
-- elseif m==8 then
--  p.update=update_menu

-- if debug then
----	 for slo in all(slots) do
----	  x,y=slo.x*8,slo.y*8
----	  rect(x,y,x+7,y+7,7)
----	 end
----	 for slo in all(inv_shop) do
----	  x,y=slo.x*8,slo.y*8
----	  rect(x,y,x+7,y+7,10)
----	 end
----	 for slo in all(buyvs) do
----	  x,y=slo.x*8,slo.y*8
----	  rect(x,y,x+7,y+7,9)
----	 end
----	 for slo in all(sellvs) do
----	  x,y=slo.x*8,slo.y*8
----	  rect(x,y,x+7,y+7,11)
----	 end
----	 for slo in all(furniture) do
----	  x,y=slo.x*8,slo.y*8
----	  rect(x,y,x+7,y+7,11)
----	 end
-- end
-- print("–‘“\nwewwe\nkwekrwr\newrew\n",4,37,6)
-- print("sum|stk|upg|a",2,56,7)
--  clip(4,y+1,6,6)
--		spr(item.s,3,y)
--  outline(function()
--  x=0
--  printh(y)
--  rectfill(x,y,x+61,y+7,i%2==0 and 5 or 3)
--		end)
--		clip()
-- sspr(sx,sy,8,8,44,4,16,16)
-- local sx,sy=convert_spr(items[curs_i].s)
-- print(" own"..item.count.."",20,44,6)
 
-- function update_menu()
-- if btnp(Ž) then
--  p.update=update_player
-- end
--end
-- elseif m==32 then
--  local item=init_item(rnd(rnd_items).s,x,y)
--  item.owned=true
--    add(owned,item)
-- elseif m==69 then
--  local clerk=init_obj(m,x,y,nil,draw_char,1,2)
--  mset(x,y)
-- elseif m==253 then
--  cat=init_obj(m,x,y,state_update,draw_char)
--  cat.state=cat_wander
--  cat.spd=0.1
--  mset(x,y)
--	news=init_obj(nil,-.25,10,update_news,draw_news)
-- news.z=10
-->8
--auxilary
dirx,
diry
=
split("-1,1,0,0,1,1,-1,-1,"),
split("0,0,-1,1,-1,1,1,-1,")
dirx[0]=0
diry[0]=0	

function init_graph(vecs)
 local graph={}
 for _x=mx,mh+mw do
  graph[_x]={}
  for _y=my,my+mh do
   if vecs then
   	graph[_x][_y]={x=_x,y=_y}
   else
   	graph[_x][_y]=nil
   end
  end
 end
 return graph
end

function init_obj(s,x,y,update,draw,w,h)
 local obj={
  s=s,
  draw=draw or draw_spr,
  update=update or empty,
  x=x or 0,
  y=y or 0,
  w=w or 1,
  h=h or 1,
  t=0,
  z=0,
  cash=0,
  emoji=nil,
  spd=.2,
 }
 obj.ox,obj.oy=obj.x*8,obj.y*8
 add(objs,obj)
 return obj
end

function empty()end

function isorty(t) --insertion sort, ascending y
 for n=2,#t do
  local i=n
  while i>1 and t[i].y*8+t[i].oy+(t[i].z or 0)<t[i-1].y*8+t[i-1].oy+(t[i-1].z or 0) do
   t[i],t[i-1]=t[i-1],t[i]
   i-=1
  end
 end
end

function lerp(a,b,v)
 if abs(a-b)<.1 then
  return b
 end
 return a+(b-a)*v
end

function round(x)
 return flr(x + .5)
end

function draw_spr(obj)
 if not obj.pin then
		update_lerp(obj)
	end
 outline(
	 function()
--			palt(15,true)
--			palt(12,true)
		 draw_base(obj)
	 end,
 	obj==p[1] and 7 or 0,obj)
-- palt()
end

function draw_base(obj)
 spr(obj.s,obj.ox,obj.oy,obj.w or 1,obj.h or 1,obj.flpx,obj.flpy)
end

function check_tile(_x,_y,_f)
 local m=get_obj(_x,_y)
 return m and fget(m.s,_f) or fget(mget(_x,_y),_f)
end

function fmget(x,y,f)
 return fget(mget(x,y),f)
end

function get_obj(_x,_y,array)
 for m in all(array or objs) do
  if m.x==_x and m.y==_y then
   return m
  end
 end
end

function outline(func,c,passed)
 local camx,camy=peek(0x5f28)+peek(0x5f29)*256,peek(0x5f2a)+peek(0x5f2b)*256
 for i=0,15 do
  pal(i,c)
 end
 for i=4,0,-1 do
  camera(camx+dirx[i],camy+diry[i])
  if i==0 then
   palchange()
  end
  func(passed,i)
 end
end

function sprint(t,x,y,c,func)
 local camx,camy=peek(0x5f28)+peek(0x5f29)*256,peek(0x5f2a)+peek(0x5f2b)*256
 for i=0,15 do
  pal(i,c2)
 end
 local d={8,0}
 local func=func or print
 for i=1,2 do
  camera(camx+dirx[d[i]],camy+diry[d[i]])
  if i==2 then
   palchange()
  end
  func(t,x,y,c or peek(0x5f25))
 end
end

function string_width(txt)
 local ws=0
 for i=1,#txt do
  ws+=1
  if ord(sub(txt,i,i))>128 then
   ws+=1
  end
 end
 return ws
end

function cprint(txt,y,c)
 local wid=string_width(txt)
 sprint(txt,32-wid*2,y,c)
end

function palchange()
	pal()
--	palt(15,true)
	pal(0,133,1)
--	pal(5,131,1)
	pal(2,132,1)
	pal(1,140,1)
	pal(14,136,1)
	pal(3,131,1)
--	pal(11,3,1)
	pal(5,3,1)
--	pal(5,3,1)
--	pal(13,142)
--	pal(9,137,1)
--	pal(10,9,1)
--	poke(0x5f2e,1)
end
fadetable={
{[0]=128,140,132,131,4,5,6,7,8,9,10,139,12,13,136,15},
{[0]=128,140,132,131,4,5,6,6,8,9,10,139,12,13,136,143},
{[0]=128,140,132,131,132,133,134,6,136,9,138,3,12,141,136,143},
{[0]=128,140,130,1,132,133,13,6,136,4,138,3,140,141,2,134},
{[0]=128,131,130,129,132,133,13,134,136,4,138,3,140,5,2,134},
{[0]=128,131,130,129,132,133,13,134,136,4,4,3,140,5,132,134},
{[0]=128,1,128,129,132,130,141,134,132,4,4,3,140,5,132,134},
{[0]=0,1,128,129,132,130,5,134,132,132,4,131,131,133,130,5},
{[0]=0,1,128,129,130,128,5,5,132,132,132,129,131,133,130,5},
{[0]=0,129,128,129,128,128,5,5,130,132,132,129,131,130,130,5},
{[0]=0,129,128,129,128,128,133,5,128,128,133,129,1,129,128,133},
{[0]=0,129,128,0,128,128,130,133,128,128,128,129,129,129,128,133},
{[0]=0,129,0,0,128,128,128,130,128,128,128,0,129,128,128,128},
{[0]=0,0,0,0,0,0,128,128,128,128,128,0,129,128,0,128},
{[0]=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
}
function fadeup()
 wait(10)
	_draw()
	for i=15,1,-1 do
	 pal(fadetable[i],1)
	 flip()
	end
end

function fadedown()
	for i=1,15 do
	 pal(fadetable[i],1)
	 flip()
	end
end

function bounds(_x,_y)
 return _x<mx or _y<my or _x>mx+mw or _y>my+mh
end

function contains(array,a)
 for i=1,#array do
  if array[i]==a then
   return i
  end
 end
end

function v(x,y)
 return {x=x,y=y}
end

function lowest_f_score ( set, f_scre )
 local lowest = 10000
 for node in all(set) do
  local score = f_scre[node]
  if score < lowest then
   lowest, bestnode = score, node
  end
 end
 return bestnode
end

function heuristic( nodea, nodeb )
 return nodea==nodeb and 0 
 or fmget(nodea.x,nodea.y,0)
    and 
    "fail"
    or 
    dist_6(nodea,nodeb) 
end

function ’pathfinding(start,goal)
 --’
 local start,goal=graph[round(start.x)][round(start.y)],graph[round(goal.x)][round(goal.y)]
 local closedset,
 openset,
 came_from,
 g_scr,
 f_score
 =
 {},
 {start},
 {},
 {},
 {}
 
 g_scr[start],
 f_score[start]
 =
 0,
 heuristic(start,goal)
-- debug_square(goal.x,goal.y,8)
 while #openset!=0 do
  local current = lowest_f_score(openset,f_score)
  if current==goal then
   local path={}
   while goal do
    add(path,goal)
    goal=came_from[goal]
   end
   return path
  end
  del(openset,current)
  add(closedset,current)
  for i=1,4 do 
   local dx,dy=current.x+dirx[i],current.y+diry[i]
--   debug_square(dx,dy,9)
   if not bounds(dx,dy) then
    local ngb=graph[dx][dy]
    if not contains(closedset, ngb)  then
     tg_scr,
     notopen 
     = 
     g_scr[current]+dist_6(current,ngb),
     not contains(openset,ngb)
     if notopen or tg_scr<g_scr[ngb] then
      came_from[ngb],
      g_scr[ngb]
      =
      current,
      tg_scr
      local h=heuristic(ngb,goal)
      if h!="fail" then
	      f_score[ngb]=g_scr[ngb]+heuristic(ngb,goal)
	      if notopen then
	       add(openset,ngb)
	      end
--	     else
--	     debug_square(dx,dy,9)
	     end
     end
    end
   end
  end
 end
end

function check_move(obj)
 return obj.x*8==round(obj.ox) and obj.y*8==round(obj.oy)
end

function update_lerp(obj)
	obj.ox=lerp(obj.ox,obj.x*8,obj.spd)
	obj.oy=lerp(obj.oy,obj.y*8,obj.spd)
end

function convert_spr(s) 
  return s%16*8,flr(s/16)*8
end

function dist_6(a,b)
  local dx=(a.x-b.x)/64
  local dy=(a.y-b.y)/64
  local dsq=dx*dx+dy*dy
  if(dsq<0) return 32767.99999
  return sqrt(dsq)*64
end

function digit_print(t,x,y,c,n)
 for i=1,n-#tostr(t) do
  t=" "..t
 end
 print(t,x,y,c)
end

function spr_sspr(s) 
  return s%16*8,flr(s/16)*8
end

function blink(c1,c2)
return flr(t/16)%2==0 and c1 or c2
end

function dijkstra_map(tx,ty)
 local cand,step={{x=tx,y=ty}},0
 local distmap=init_graph()
 distmap[tx][ty]=0
-- printh(distmap[1][1])
 repeat
  step+=1
  candnew={} 
  for c in all(cand) do
   for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if not bounds(dx,dy) and not distmap[dx][dy] then
     distmap[dx][dy]=step
     if not check_tile(dx,dy,0) then
      add(candnew,{x=dx,y=dy})
     else
      distmap[dx][dy]=step+1
     end
    end
   end
  end
  cand=candnew
 until #cand==0
-- for x=0,mw do
--  for y=0,mh do
--   print(distmap[x][y],x*8,y*8,distmap[x][y])
--   flip()
--  end
-- end
 return distmap
end
__gfx__
00000000555555535555555355333355eeeeeeee11111111999999995577775577777773ffffffffffffffff44444444ffffffffffffffffffffffff22000000
00000000555555535555555353333335e888888e1cccccc19aaaaaa95a7777a570000073fffffffffffffffffffffffffffffffff444444ff444444f77000000
00700700555355535553555333333333e8eeee8e1c111cc19a9999a95aaaaaa577777773ffffffffffffffffff4444ffffffffff400000044222222477000000
00077000553535535533355333333333e8e8888e1c1cc1c19a9aa9a95999999570007073ffffffff44444444f4cccc4fffffffff000000002222222277000000
00077000555355535553555333333333e8eeee8e1c111cc19a999aa95a4242a577777773ffffffff4ffffffff4cccc4fffffffff000000002220022277000000
00700700555555535555555333333333e8888e8e1c1cc1c19a9aa9a95a2424a570700073444444444f2772fff4cccc4fffffffff000000002220022277000000
00000000555555535555555353333335e8eeee8e1c111cc19a9aa9a959999995ddddddd3000000004f2442ffff4444ffffffffff000000002224422277000000
00000000333333353333333555333355e888888e1cccccc19aaaaaa95555555533333333000000004fffffffffffffffffffffff000000002222222277000000
00000000444444424444444244444442eeeeeeee11111111999999994444444244444442000000000000000044444442ffffffff000000002222222200000000
00000000422222424222224242222242eeeeeeee11111111999999994222224242222242000000000000000042222242ffffffff000000002222242200000000
000000004444444244444442444444424eeeeee241111112499999924444444244444442000000000000000044444442ffffffff000000002222222200000000
000000002222222422222224222222242222222422222224222222242222222422222224222222220000000022222224ffffffff000000002222222200000000
000000000000000000000000000000000000000000000000000000000000000000000000444224440000000077777755ffffffff000000002222222200000000
00000000000000000000000000000000000000000000000000000000000000000000000044422444000000007777335544444444000000002222222200000000
00000000000000000000000000000000000000000000000000000000000000000000000044422444000000007755335500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044422444000000003355335500000000000000000000000000000000
55555553cccccccc0000000055333355555555530000000000000000000000000000000000000000ffffffffffffffffffffffff444444427777777700000000
55555553c11cc11c0000000053555535555a55530000000000000000000000000000000000000000f22444444444422ffff222ff422222427777775500000000
55333553c1cccc1c000000003535535355a4a5530000000000000000000000000000000000000000f22004000040022fff20002f444444427777335500000000
55353553cccccccc0000000035533553555a55530000000000000000000000000000000000000000f22004000040022ff200000222222224775533550ff00ff0
55333553cccccccc0000000035533553555b55530000000000000000000000000000000000000000f22444444444422ff2000002777777553355335500000000
55555553c1cccc1c00000000353553535ccccc530000000000000000000000000000000000000000f22004000040022ff2000002777733553355332200000000
55555553c11cc11c000000005355553555ccc5530000000000000000000000000000000000000000f22004000040022fff20002f775533553355222200000000
33333335cccccccc0000000055333355333333350000000000000000000000000000000000000000f22444444444422ffff222ff335533553322222200000000
44444442444444420000000034222243000000000000000000000000000000000000000000000000ffffffffffffffff00000000000000000000000000000000
42222242422222420000000042244224000000000000000000000000000000000000000000000000ffffffffffffffff0000000000000000000000000bbbbbb0
44444442444444420000000034222243000000000000000000000000000000000000000000000000ffffffffffffffff0000000000000000000000000b0000b0
22222224222222240000000033444433000000000000000000000000000000000000000000000000ffffffffffffffff0000000000000000000000000b0000b0
00000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff0000000000000000000000000b0000b0
0000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444440000000000000000000000000b0000b0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbb0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000909090000990000000000000000000000000000000000000000000044440000000000000000000000000000000000000000000
00499900000000000000000000099900077794400000000000000000000000000000000009900099004444000000000000000000000070000000000000000000
04944490009999000099990000444400074794000044440000999900077000000009990000944090004444000044440000099000009090000099990000000000
049444900444444009999990044fff00004444000444444000777700077777000099990004994490099999900044440000999900009999000044444000ffff00
00fbfb00009bfb00099bfb9004fbfb40004bfb00044bfb40044bfb40007bfb00099bfb9004fbfb0000fbfb00004bfb0000fbfb0000fbfb0000fbfb00007bfb00
00ffff00009fff00099fff9004ffff4000ffff00044fff40044fff4000ffff00099fff9000ffff0000ffff0000ffff0000f4440000ffff0000ffff0000777700
04497940044494400779f970099494900794f4900997f790949494940997f7900477f940044fff40044979400449494004944440077949700997479000477700
0444744004449440077797700994949007997790099797904949494909994990047799400f44f4f0044979400449494009794970049979400999499004477740
044979400999499009779790074494700f9977f0099777900f9494f009994990049977400f44f4f0044979400994449004947490049979400997479004477740
0f4474f0074444700f7797f00f4979f00f4444f00f4444f00f7777f007774770049977400f9999f00749497009444490097979700f7777f00499494004447440
0f4494f00f9449f00f4444f00f4979f00f7799f00f9777f00f9494f00f4444f00f7799f00f4444f00f4979f00f4444f00f4444f00f4444f00f9747f00f9999f0
00440400007997000044440004497940007799000097770000400400004444000077990000444400004979000090090000400400094994000099090000444400
004404000070070000f00f0004977790009004000097770000400400004444000040040000940400004979000090090000400400094994000070070000444400
00900900009009000090090009777770009004000099990000900900007007000040040000900900004909000090090000900900094994000040040000444400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004444400000000000000000000999900004444000000000000444400000000000000000000444400000000000000000000000000
00000000000000000009990000444400004444000000000009999990004444000000000009999990009999000000700000444400000440000909999000000000
00999900009999000099999009999990009999000044440009999990009999000990000004444440099944900000400000447400004444000999990000444000
0099990009999990099999904444444404444440009999000999999004444440099fff00009999000994bb400099990000999900004444000044440004444400
009bfb00099bfb0009fbfb90099bfb90009bfb00009bfb00009bfb00009bfb0000fbfb0000fbfb000994bb40009b9b0000fbfb00009b4b0000fbfb00044bfb00
0099f90000ffff0009ffff90099fff9000ffff0000ffff0000ffff0000ffff0000ffff0000ffff00009944000099990000ffff0000ff4f0000ffff00044fff00
0444744007777770077777700997779007797970077979700444744004479740099979900444f4400999999004444440044979400444f4400ffffff00799f970
044474400f7777f00f7777f009977790077979700f7999f00444744004479740099979900944f490094979900944749004497940044949400ffffff007994970
0f9977f00f7777f00f7777f00f7777f00f7979f00f9999f00f4474f004479740099979900f44f4f00449994004444440044979400ff444f007ffff700799f970
047799400f4444f00f9999f00f9999f00f4444f0044444400f4474f0094777900f4444f00f4494f00944449009444490044979400ff444f0079999700f4444f0
047799400f9999f00f9999f00f4444f00f4444f0049999400f9999f00f4444f00f9979f00f9999f009499490049999400f4949f00f9999f00f4444f00f9999f0
0077990000900900009009000044440000400400009999000090090000400400009979000090090000400400004004000049090000990f000040040000700700
00f00f0000900900004004000044440000400400004004000090090000400400009979000090090000900900009009000099090000f00f0000f00f0000400400
004004000090090000400400004444000040040000400400009009000090090000400400009009000090090000400400004004000090090000f00f0000400400
0000000000000000000000000000000000000a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0066660000000bb000044200007007000009a9a0000090a004444440000044000087880000022000000000000000000000000000000000000000000000000000
0006600000049bb000444420070770700b9a9a0000029a9000244200000ff44007888780008288000aaaaaa00000000000000000000000000000000000000000
006006000099490004474420008888000ba9a900002229a002044020004444200887888008788880888888880000000000000000000000000000000000000000
06888860094994000444420007777770bbba900009a22200024444200ff442000eeeeee0088888e0eaaaaaae0000000000000000000000000000000000000000
06eeee60099440000244200000888800bbbbb0000aa92000022442200444200000066000088888e0099999900000000000000000000000000000000000000000
00666600090000000022000000077000bbb00000009a0000002222000022000000077000008e8e00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000006600000002000000060080000700066d0000000666000006600004006400042420000000660000008800000044000066020008877000444444000444dd0
00006d60000dd40000000d6008887770000d4d000006dd000006dd60044060400242424000006d60000008e000000040006d04000888777004d22d40006002d0
0406d600000d4d6000004060088877700004dd60006dd0000000dd60000600400246d2400000460000004000000044000060d060088dd7700422224000602040
004d60000004d66000040060077788800040060006dd00000004060000602400024dd24000040000000400000004000000040d60077dd8800422224000620040
00240000004066000040060007778880020000000040000000400000060042d002424240004000000040000000400000004066000777888004d22d4000466640
0400400002000000020000000077880000000000040000000200000004440dd00042420002000000020000000200000002000000007788000044440004000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00440400000022000024440000aa900000000cc000dddd00000878e0000402400222422000760600000000000000000000000000000000000000000000000000
0444044002204400024444400a00090000aacc100dddddd000878e80004024200444444007760670000000000000000000000000000000000000000000000000
0224242004404400024000400a0000900a0011000dddddd0087888e0004442400244442007776770000000000000000000000000000000000000000000000000
022222200440440002440440008000900a0009000666666007888e80024d44000440044000776700000000000000000000000000000000000000000000000000
002444000440244002440440088e00a009000a000dd00d000878e800024440000440022000776700000000000000000000000000000000000000000000000000
00244400024400000024040008e09a000099a0000dd00d00078e8000022200000220000000776700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000aa000000000000000000000000000000000
044044404ff00000000ffff00000400004444f2000aaaa006660666002828280000094000000770000007a00aa000aa000aaaa0000000000aa00000000009000
0004442044404ff0042424200000040004994f200a0000a00d000d000282828000094420000766d00007aa90aa0009900aaaaaa03bb3bb30990000aa00040090
0044422000004ff0040424200007400004444f2000aaaa00060d06000282828000949420007676d0007a7a90990000000aa99aa0bbb33bb0aa00009904444000
0fff22004ff04440040424200077700004994f20099999900d060d00028282800949420007676d0007a7a900000aa0000aaaaaa0bb33bbb0990990aa44440000
0f4f20004ff00000042424200777000004444f200aaaaaa0000d000002828280024420000766d00009aa9000000aa00009aaaa903bb3bb30aa0aa09944420900
0fff000044400000000424200770000004444f200099990000666000028282800022000000dd000000990000000990000099990000000000990990aa02200000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111000111101011111100011110101111111000000000000000000000000000000000000000000222220000000000111111110000000000000000
0111111011000010111001100110011011100110010001100000000000000000000000000000000000000000070244400000000022222d770000000000000000
0100001011001010110000100110001011000000010101100000000000000000000000000000000000000000070200000000000088888d770090000009000000
010110101101110011000000011000101111111011111110000000000000000000000000000000000bbb0000070200000000000022222d770900900900909009
010000101100101011000010011000101100000010010110008880000044440000060600002222000bbbbbb00702000000aaaa0088888d660900997909009979
0111111011000010111001100110011011100110100001100888880004444480006666000044440000bbbb004442000000aaaa00444444440099977700999777
01111110111111000111101011111100011110100111111008f0f00004f0f0400660f0600041f1000091f1000222220000000000411111140077777000777770
00000000000000000000000000000000000000000000000088ffff0004ffff4006ffff0000ffff00099fff000000000000000000111111110000000000000000
0111101011100000011111000111110011001110111100000774f4700778b8700447f740077272700bbbbbb002222200bbbbbbb3eeeeeeee0000000000000000
111001100110000010101010100110101100010001101000077474700788b870044414400f7222f00bbbbbb007020700b22222b3eeeeeeee0000000000090090
1100001001111100001010000011000011010100011000000744447007444470044414400f2222f00fbbbbf007024440b7b2b7b3ee5566ee0090900909099790
110011000110011000101000001100001111100001100000074444700488b8400444144004dddd400fbbbbf007020000b7b2b7b3ee5566ee090099799009c7c0
1100101001100110001010001001100011010100011000100f4444f00f88b8f00f1111f0042222400fbbbbf04442000044424443eeeeeeee0900947490497770
111001000110010010101010100010001100010001100110004444000020020000100100002222000030030000020000bbb2bbb3eeeeeeee009947770994a400
01111000111000100111110001110000110011101111111000700700007007000010010000c00c000030030002222200b22222b3eeeeeeee0077777009777700
0000000000000000000000000000000000000000000000000040040000400400000000000040040000400400000000003333333beeeeeeee0000000007070700
11111110100111000111100010111100001100001001110010000110000000000000000000222200000000000000000000000000000000000777777700000000
01100100011001101110110001100110001100000110011001000110000000000000000000772200000000000000000000070000000000007777777770000000
011011000110011011000100011001100011000001100110011011100000070000e00e0000772200007000000000700000777000000000007777777770000000
011111000110011011001110011001000011000001100100001111000077770000e00e0000222200077000000000770007777700000000007777777770000000
010101000110011011000100011110000000000001101000000110000777777000e00e0002222220777000000000777000000000000000007777777770000000
010001000110010011101100011000000011000001100110000110000711117000eeee0000777700077000000000770000000000077777007777777770000000
1000111011100010011110001010000000110000111000100010100007f0f07000e1e10007f1f100007000000000700000000000007770007777777770000000
0000000000000000000000000000000000000000000000000000000000ffff0000eeee0000ffff00000000000000000000000000000700000777777700000000
01111010111111101110111011101110111011101110111010111110071741700eeeeee004242440000000000000000000000000000000000000700000000000
11100110101100100100010001000100010001000110010011001010071971700ee777e004442440000000000000000000000000000000000000000000000000
11100000001100001100010001000100010101000011100010010100071771700ee777e004242440000000000000000000000000000000000000000000000000
01111110001100001100010000101100011111000001000000101000071741700ee777e00f4424f0000000000000000000000000000000000000000000000000
100111100011000011001000001010000110110000111000010100100f4444f000e7770002442420000000000000000000000000000000000000000000000000
110000101011010001001010001110000100010001001100101001100040040000e00e0000200200000000000000000000000000000000000000000000000000
101111000111101000110100000101001111111011101110111110100040040000e00e0000200200000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000040040000e00e0000400400000000000000000000000000000000000000000000000000
__gff__
40bb9311b3b3b3939340030383020200034040404040404040000000400000009b93800b93839300000083830300008040404b4040404000000040400000000004040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404048504040404040404040400000000000000000100000004000000000000000000000000000000000000040000000000000000000000000000000400000000000000000000000000040004
__map__
0000003f0000001000000000000000101010103f101010101010103f10101010000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010
0c2a2b0d2a2b0c100c2a2b0d2a2b0c000c2a2b0d2a2b0c100c2a2b0d2a2b0c1000000b0b0b0d0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100b0b0b0d0b0b0b10
090909000909091009090900090909000201011d010102100201011d0101021000000909091d090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102020201f20202010
0000004000000010000000000000000001111160111101100111116011110110000001000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101111110011111110
000089898a000010000089898a00000001008787870001100100878787000110000011001100110011000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102020200020202010
000011890100001000001189010000000100898989000110010089898900011000000100010001000100000b0b0b0d0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102020200020202010
000000111100001000000011110000000100111111000110010011111100011000001100110011001100002020201d2020200000000a0b0c0d0a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101111110011111110
00009605000000100000960500400000020104010500021002010401050002100000020205020402020000303030003030300000000201011d0101020a0b0c000a0b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100202240225020210
0000111500000010000011150000000011111411150011101111141115001110000011111111111111000089898900202020000000801111001111010201011d01010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101111144515111110
1010101010101010101010101010100010101010101010101010101010101010000000000000000000000030303000303030000000800001010100010111110011110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010
f0f1e2e5c4000000000000000000000000000000000000000000000000000000000000000000000000000089898900200420000000800001010100010100898989000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0c5d5e2e5c40000000000000000000000000000000000000000000000000000000000000000000000000030303000051430000000010011111100010100111111000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e6e2f200000000000000000000000000000000000000000000000000000000000000000000000000000020202000200000000000020604070500020206040705005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f4e2e1e40000000000000000000000000000000000000000000000000000000000000000000000000000303030003000000000001b1114111560111b11141115601100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e6e2f200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d5e2f0c4e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01110301117401173011720117101f740007001d7401d7301d7201d7101d7101d7101d7101d7000074000700117401173011720117101f740007001d7401d7301d7201d7101d7101d7101d710007000074000700
011102001170011700117001170022740007002174021730217202171021710217102171000700007001b7001170011700117001170022740007002174021730217202171021710217102171000700007001b700
011100000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001001515016150
001100001813018100181301810018130181001813018120181120c100161300c100151300c100131300c100131300c1001513015130151221511215112001000010000100001000010000100001001515016150
00110000117401173011720117101f740007001d7401d7301d7201d7101d7101d7101d7101d70000740007000f7400f7300f7200f7101f740007001b7401b7301b7201b7101b7101b7101b710007000074000700
001100001170011700117001170022740007002174021730217202171021710217102171000700007001b7001170011700117001170022750007001f7401f7301f7201f7101f7101f7101f71000700007001b700
011100001813011132181001813011130181001813011130181300c100161300c100151300c100131300c100131300c1001513015132161320c100131301312013110131221313213132131120c1001513016140
011100000a7400a7300a7200a7101f740187001d7401d7301d7201d7101d7101d7101d7101d70016740187000e7400e7300e7200e7100e740187000d7400d7300d7200d7100d7100d7100d710187001874000700
01110000227002270022700227001b740187001a7401a7301a7201a7121a7121a7121a7101d7001d74018700157401573015720157101574018700147401473014720147121471214712147101d7001d74018700
011100001113000000111300000011130000001a1301a1301a1301a1301a1321a1321a1321a1321a1320000018130181301813016130151301313011130111301112211122111121111200000000000000000000
01110000137401373013720137101371018700157401573015720157101571015710157101d700167401673016720167101674016710167401870018740187301872018710187101871018710187000070000000
011100001a7401a7301a7201a7101a71018700187401873018720187101871018710187101d7001d7401d7301d7201d7101d7401d7101d740187001c7401c7301c7201c7101c7101c7101c710187000070000000
0111000022100001002210000100161300c1001513015120151101511215100211001a134181001813418120181121811218100181001f135181001d1341d1201d1101d1121d1122910029100001000010000100
01110201117301173011720117101f730007001d7301d7301d7201d7101d7101d7101d7101d7000073000700117301173011720117101f730007001d7301d7301d7201d7101d7101d7101d710007000073000700
011102001170011700117001170022730007002173021730217202171021710217102171000700007001b7001170011700117001170022730007002173021730217202171021710217102171000700007001b700
011100000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001001511016120
011100001813018100181301810018130181001813018120181120c100161300c100151300c100131300c100131300c1001513015130151221511215112150121501215012001000010000100001001512016130
01110000117301173011720117101f740007001d7301d7301d7201d7101d7101d7101d7101d70000730007000f7300f7300f7200f7101f740007001b7301b7301b7201b7101b7101b7101b710007000073000700
011100001170011700117001170022730007002173021730217202171021710217102171000700007001b7001170011700117001170022730007001f7301f7301f7201f7101f7101f7101f71000700007001b700
011100000a7300a7300a7200a7101f740187001d7301d7301d7201d7101d7101d7101d7101d70016730187000e7300e7300e7200e7100e740187000d7300d7300d7200d7100d7100d7100d710187001873000702
01110000227002270022700227001b730187001a7301a7201a7201a7121a7121a7121a7101d7001d73018700157301572015720157101574018700147301473014720147121471214712147101d7001d73018700
01110000137301373013720137101371018700157301573015720157101571015710157101d700167301673016720167101674016710167401870018730187301872018710187101871018710187000070000000
011100001a7301a7201a7201a7101a71018700187301873018720187101871018710187101d7001d7301d7301d7201d7101d7401d7101d740187001c7301c7301c7201c7101c7101c7101c710187000070000000
0111000015144151301114011130161340c1001513415120151101511215100211001a134181001813418120181121811218100181001f135181001d1341d1201d1101d1121d1122910029100001000010000100
01110000111351153511125111051f1351f5351d1351d5251d1251d5151d1151d5151d5051d1050053500115115351113511525111151f5351f1151d5351d1351d5251d1151d5151d1151d515001050053500105
011100000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005001555016550
011100001853018500185301850018530185001853018520185120c500165300c500155300c500135300c500135300c5001553015530155221551215512155121551215512005000050000500005001555016550
011100001853011532185001853011530185001853011530185300c500165300c500155300c500135300c500135300c5001553015532165320c500135301352013510135221353213532135120c5001553016540
01110000111151151511115115151f115005051d1151d5151d1151d5151d1151d5151d1151d50500115005050f1151151513125165251b1351a5001b1351d5351f135225251b1252952527525220151f11522015
011100001153000500115300050011530005001a5301a5301a5301a5301a5321a5321a5321a5321a5320050018530185301853016530155301353011530115301152211522115121151200500005000050000500
011100000a1150a5150a115165151f115185051d1151d5151d1151d5151d1151d5151d1151d50516115185050e1151a5151a1151a5150e11518505195150d1151951519115195150d1150d515181050c51500705
0111000015544155301154011530165340c5001553415520155101551215500215001a534185001853418520185121851218500185001f535185001d5341d5201d5101d5121d5122950029500005000050000500
011100001f5152151526515215251f5251a52518535155351353515525185251a5151c515215252452526535295352e5353053532525305152b525285252453528535295252b5352d5252b525295152851524515
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
0007000023755207551e7552c7052d705317050070500705007052870500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500005000050000500005
000c00001d04527005000050000500005000050000500005000050000500005000050000500005000051900500005000050000500005000050000500005000050000500005000050000500005000050000500005
010200002004023030220002404014000130001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000270351e045000050000500005000050000500005000050000500005000050000500005190050000500005000050000500005000050000500005000050000500005000050000500005000050000500000
001000001e04527035000050000500005000050000500005000050000500005000050000500005000051900500005000050000500005000050000500005000050000500005000050000500005000050000500005
00010000274551e455004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500405004050040500400
0001000021055270551b0050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000700001205518055200550d00500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0107000018052210421704220032170321f022160221e012140121d01220002210021900200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010a000026055211052f0552d1052a055241052d055151051a0452110523045211051e0451810521045211051a0352110523035211051e0251810521025211051a0152110523025211051e015181052101515105
000a0000100400e040000000000000000000000000000000000000000000000000000000000000190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900002a7552c7552f7552a705207052d7053170500705007050070528705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705000000000000000
000500001573017740187401a75000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000500001a64018630176301562014610126100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00090000276541b6541265408704207042d7043170400704007040070428704007040070400704007040070400704007040070400704007040070400704007040070400704007040070400704000000000000000
000500000e6400c6300b6300962000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100001073015730107200500005000040000500005000050000500005000050000600005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0d 0e 43 44
01 0d 0e 0f 44
00 0d 0e 10 44
00 11 12 06 44
00 13 14 09 44
00 15 16 17 44
00 0d 0e 43 18
00 0d 0e 19 18
00 0d 0e 1a 18
00 11 12 1b 1c
00 13 14 1d 1e
02 15 16 1f 20
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
