pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- picopolis
-- made by kim wijsbeek

function _init()
	poke(0x5f2d, 1)

 music()
 screen='start'
 game='none'
 mouse_reset=false
 
 cx=0 -- camera x
 cy=-10 -- camera y
 mx=0 -- mouse x
 my=0 -- mouse y
 mapx=0 -- mouse map x
 mapy=0 -- mouse map y
 help_scroll=20
 
 -- directions
 rx={}    ry={}
 rx[0]=-1 ry[0]=0
 rx[1]=0  ry[1]=-1
 rx[2]=1  ry[2]=0
 rx[3]=0  ry[3]=1
 rx[4]=0  ry[4]=0
 
 -- products
 prods=15
 _gold=0
 _wood=1
 _stone=2
 _grain=3
 _eggs=4
 _milk=5
 _meat=6
 _wool=7
 _bread=8
 _beer=9
 _clothes=10
 _shoes=11
 _faith=12
 _books=13
 _fun=14
  
 prod_name={}
 prod_name[_gold]='gold'
 prod_name[_wood]='wood'
 prod_name[_stone]='stone'
 prod_name[_grain]='grain'
 prod_name[_eggs]='eggs'
 prod_name[_milk]='milk'
 prod_name[_meat]='meat'
 prod_name[_wool]='wool'
 prod_name[_bread]='bread'
 prod_name[_beer]='beer'
 prod_name[_clothes]='clothes'
 prod_name[_shoes]='shoes' 
 prod_name[_faith]='faith' 
 prod_name[_books]='books' 
 prod_name[_fun]='fun' 
 
 -- buildings
 _tree=0
 _mine=1
 _woodchopper=2
 _stonecutter=3
 _house_1=4
 _farm=5
 _field=6
 _chickens=7
 _cows=8
 _pigs=9
 _sheep=10
 _brewery=11
 _bakery=12
 _tailor=13
 _shoemaker=14
 _church=15
 _univ=16
 _theater=17
 _house_2=18
 _house_3=19
 _path_1=20
 _path_2=21
 _path_3=22
 _bridge=23
  
 build_name={}
 build_name[_tree]='tree'
 build_name[_mine]='mine'
 build_name[_woodchopper]='wood chopper'
 build_name[_stonecutter]='stone cutter'
 build_name[_house_1]='house lvl 1'
 build_name[_farm]='farm'
 build_name[_field]='field'
 build_name[_chickens]='chickens'
 build_name[_cows]='cows'
 build_name[_pigs]='pigs'
 build_name[_sheep]='sheep'
 build_name[_brewery]='brewery'
 build_name[_bakery]='bakery'
 build_name[_tailor]='tailor'
 build_name[_shoemaker]='shoemaker'
 build_name[_church]='church'
 build_name[_univ]='university'
 build_name[_theater]='theater'
 build_name[_house_2]='house lvl 2'
 build_name[_house_3]='house lvl 3'
 build_name[_path_1]='path 1'
 build_name[_path_2]='path 2'
 build_name[_path_3]='path 3'
 build_name[_bridge]='bridge'
 
 -- emoji's
 _happy=128
 _sad=129
 _question=130
 
 prod={}
  
 level_init()
 human_init()
 build_init()
 world_init()
 menu_init()
 help_init()
end

 
function level_init()
 levels={}
 
 -- level 1
 local new={}
 new.prod_type=_wood
 new.build_type=nil
 new.prod_nr=100
 new.minutes=nil
 new.gold=150
 new.wood=50
 new.stone=50
 new.max_house=1
 new.max_build=_sheep
 new.max_path=1
 new.trees=3
 new.mines=3
 new.river=false
 add(levels,new)
 
 -- level 2
 new={}
 new.prod_type=nil
 new.build_type=_farm
 new.build_nr=2
 new.gold=300
 new.wood=50
 new.stone=50
 new.max_house=1
 new.max_build=_sheep
 new.max_path=1
 add(levels,new)
 
 -- level 3
 new={}
 new.prod_type=_grain
 new.build_type=_nil
 new.prod_nr=50
 new.minutes=nil
 new.gold=500
 new.wood=50
 new.stone=50
 new.max_house=1
 new.max_build=_sheep
 new.max_path=2
 add(levels,new)
 
 -- level 4
 new={}
 new.prod_type=nil
 new.build_type=_house_1
 new.build_nr=3
 new.minutes=nil
 new.gold=500
 new.wood=50
 new.stone=50
 new.max_house=1
 new.max_build=_sheep
 new.max_path=2
 add(levels,new)
 
 -- level 5
 new={}
 new.prod_type=_gold
 new.prod_nr=2000
 new.build_type=nil
 new.minutes=20
 new.gold=750
 new.wood=750
 new.stone=750
 new.river=true
 new.max_build=_shoemaker
 new.max_house=2
 new.max_path=3
 add(levels,new)
 
 -- level 6
 new={}
 new.prod_type=_nil
 new.build_type=_church
 new.build_nr=1
 new.minutes=10
 new.gold=500
 new.wood=300
 new.stone=300
 new.river=true
 new.max_build=_theater
 new.max_house=3
 new.max_path=3
 add(levels,new)
 
 -- level 7
 new={}
 new.prod_type=_fun
 new.prod_nr=250
 new.build_type=nil
 new.minutes=20
 new.gold=500
 new.wood=500
 new.stone=500
 new.max_house=3
 new.max_path=3
 new.max_build=_theater
 add(levels,new)
 
 -- level 8
 new={}
 new.prod_type=_gold
 new.prod_nr=5000
 new.build_type=nil
 new.minutes=30
 new.gold=1500
 new.wood=500
 new.stone=500
 new.max_house=3
 new.max_path=3
 new.max_build=_theater
 add(levels,new)
end


function _update()
 if (screen=='start') then
  mouse_update()
  start_update()
 end
 
 if (screen=='game' or screen=='continue') then
  camera_update()
  mouse_update()
  menu_update()
  build_update()
  human_update()
  world_update()
  prod_update()
 end
 
 if (screen=='help') help_update()
end


function camera_update()
 if (btn(0)) cx=limit(cx-2,0,128)
 if (btn(1)) cx=limit(cx+2,0,128)
 if (btn(2)) cy=limit(cy-2,-10,160)
 if (btn(3)) cy=limit(cy+2,-10,160)
end


function mouse_update()
 mx=limit(stat(32),0,127)
 my=limit(stat(33),0,127)
 mapx=flr((mx+cx)/8)
 mapy=flr((my+cy)/8)
 if (stat(34)==0) mouse_reset=false
end


-- draw functions


function _draw()
 cls()
 
 if (screen=='start') then
  start_draw()
 end
 
 if (screen=='game') then
  camera(cx,cy)
  map()
  world_draw()
  human_draw()
  menu_draw()
  info_draw()
  gamestate_draw()
  spr(63,mx+cx,my+cy)
 end
 
 if (screen=='help') then
  help_draw()
 end
 
end


function info_draw()
 box(cx,cy,128,10,5)
 color(7)
 spr(24,cx+1,cy+1)
 spr(40,cx+43,cy+1)
 spr(56,cx+85,cy+1)
 print(prod[_gold],cx+11,cy+3)
 print(prod[_wood],cx+53,cy+3)
 print(prod[_stone],cx+95,cy+3)
 
 -- draw prices
 if (menu.sel!=nil) then
  if (menu.sel<9) then
   if (get_price(_gold)<=prod[_gold]) color(11) else color(8)
   print('/'..get_price(_gold),cx+11+#tostr(prod[_gold])*4,cy+3)
   if (get_price(_wood)<=prod[_wood]) color(11) else color(8)
   print('/'..get_price(_wood),cx+53+#tostr(prod[_wood])*4,cy+3)
   if (get_price(_stone)<=prod[_stone]) color(11) else color(8)
   print('/'..get_price(_stone),cx+95+#tostr(prod[_stone])*4,cy+3)
  end
 end
 
end


function mouse_draw()
 spr(63,mx+cx,my+cy)
end


function prod_update()
 for i=0,prods-1 do
  local lim=999
  if (i<=_stone) lim=9999
  if (prod[i]>lim) prod[i]=lim
 end
end


-- commonly used functions


function limit(val,mn,mx)
 if (val<mn) val=mn
 if (val>mx) val=mx
 return val
end


function cycle(val,mn,mx)
 if (val<mn) val=mx-val+mn+1
 if (val>mx) val=mn+val-mx-1
 return val
end


function click(left,top,w,h)
 local inside=false
 if (mx>=left and my>=top and mx<left+w and my<top+h) inside=true
 return inside 
end


function square(x,y,w,h,col)
 rect(x,y,x+w-1,y+h-1,col)
end


function box(x,y,w,h,col)
 rectfill(x,y,x+w-1,y+h-1,col)
end


function panel(x,y,w,h)
 square(x,y,w,h,10)
 square(x+1,y+1,w-2,h-2,4)
 box(x+2,y+2,w-4,h-4,9)
end


function button(x,y,w,h)
 square(x,y,w,h,4)
 square(x+1,y+1,w-2,h-2,10)
 box(x+2,y+2,w-4,h-4,9)
end


function cprint(text,x,y,c)
 print(text,x-(2*#text),y-3,c)
end
-->8
-- human

function human_init()
 human={}
end

function human_new(x,y,build)
 local new={}
 new.tox=x
 new.toy=y
 new.x=new.tox*8
 new.y=new.toy*8
 new.frame=0
 new.base=7
 new.image=6
 new.hide=false
 new.xflip=false
 new.face=2
 new.step=0
 new.delay=0
 new.speed=0
 new.state="idle"
 new.build=build
 new.wait=0
 new.emoji=nil
 new.dist=0
 add(human,new)
 return new
end


function human_set_target(id,x,y)
 id.tox=x
 id.toy=y
 local dx=id.tox-(id.x/8)
 local dy=id.toy-(id.y/8)
 if (abs(dx)>abs(dy)) then
  if (dx<0) id.face=0 else id.face=2
 else
  if (dy<0) id.face=1 else id.face=3
 end
end


function human_update()
 local id
 for id in all(human) do
 
 	local gridx=flr(id.x/8)
 	local gridy=flr(id.y/8)
  
  if (id.state=='to work' or id.state=='return' or id.state=='to shop' or id.state=='to supply' or id.state=='start return') then
  
  	-- start walking
   if (id.step==0 and id.speed==0) then
    local dist={}
    local best=nil
    local high=-1000
    dist[0]=gridx-id.tox
    dist[1]=gridy-id.toy
    dist[2]=id.tox-gridx
    dist[3]=id.toy-gridy
    for i=0,3 do
     if (i!=cycle(id.face+2,0,3)) then
      local img=mget(gridx+rx[i],gridy+ry[i])
      if (fget(img,0) or fget(img,7)) then
       if (dist[i]>high) then
        high=dist[i]
        best=i
       end 
      end
     end
    end
    if (best!=nil) then
     id.face=best 
    else 
     id.face=cycle(id.face+2,0,3)
    end       
   end
  
   -- move
   if (id.speed==0) then
    id.x+=rx[id.face]
    id.y+=ry[id.face]
    id.step=cycle(id.step+1,0,7)    
    id.speed=2
    if (fget(mget(gridx,gridy),3)) id.speed=1
    if (fget(mget(gridx,gridy),4)) id.speed=0
    id.dist+=1
    if (id.dist==500) then
     id.state='start return'
     id.emoji=_sad
    end
    if (id.dist==1000) then
     id.build.state='time out'
     id.build.wait=30
     del(human,id)
    end
   else
    id.speed-=1
   end
  end
  
  -- animation
  if (id.delay==0) then 
   id.xflip=false
  	id.frame=cycle(id.frame+1,0,3)
  	if (id.frame==0 or id.frame==2) id.image=1
  	if (id.frame==1) id.image=2
  	if (id.frame==3) then
  	 if (id.face==0 or id.face==2) then
  	  id.image=3
  	 else
  	  id.image=2
  	  id.xflip=true
  	 end
  	end
  	if (id.face==2) id.xflip=true
  	if (id.face==1) id.image+=3
  	if (id.face==3) id.image+=5
  	id.delay=5
  else
   id.delay-=1
  end
 
  if (id.step==0) then
   gridx=flr(id.x/8)
 	 gridy=flr(id.y/8)
 	
   -- state to work
   if (id.state=='to work' and gridx==id.tox and gridy==id.toy) then
    id.hide=true
    id.wait=30
    id.state='work'
   end
   
   -- state to shop
   if (id.state=='to shop' and gridx==id.tox and gridy==id.toy) then
    id.hide=true
    id.wait=30
    id.state='shopping'
   end
   
   -- state to supply
   if (id.state=='to supply' and gridx==id.tox and gridy==id.toy) then
    id.hide=true
    id.wait=30
    id.state='get supplies'    
   end
   
   -- state work
   if (id.state=='work' and id.wait==0) then
    local source=build_get_id(gridx,gridy-2)
    if (source!=nil) then   
     if (source.class==_tree) prod[_wood]+=1
     if (source.class==_mine) prod[_stone]+=1
     if (source.class==_field) prod[_grain]+=1
     if (source.class==_chickens) prod[_eggs]+=1
     if (source.class==_cows) prod[_milk]+=1
     if (source.class==_pigs) prod[_meat]+=1
     if (source.class==_sheep) prod[_wool]+=1
    end
    id.state='start return'
   end
   
   -- state shopping
   if (id.state=='shopping' and id.wait==0) then
    id.emoji=_sad
    local source=build_get_id(gridx,gridy-2)
    if (source!=nil) then
     if (source.class==_farm and id.buy<=_wool) then
      if (prod[id.buy]>0) then
       prod[id.buy]-=1
       prod[_gold]+=5
       id.emoji=_happy
       if (id.build.class==_house_1) id.build.happy+=1     
      end
     end
     local allow=false
     if (id.buy==_bread and source.class==_bakery) allow=true
     if (id.buy==_beer and source.class==_brewery) allow=true
     if (id.buy==_clothes and source.class==_tailor) allow=true
     if (id.buy==_shoes and source.class==_shoemaker) allow=true
     if (allow) then 
      if (prod[id.buy]>0) then
       prod[id.buy]-=1
       prod[_gold]+=10
       id.emoji=_happy
       if (id.build.class==_house_2) id.build.happy+=1
					 end
					end
     local allow=false
     if (id.buy==_faith and source.class==_church) allow=true
     if (id.buy==_books and source.class==_univ) allow=true
     if (id.buy==_fun and source.class==_theater) allow=true
     if (allow) then 
      if (prod[id.buy]>0) then
       prod[_gold]+=20
       prod[id.buy]-=1
       id.emoji=_happy
       if (id.build.class==_house_3) id.build.happy+=1
					 end
					end
				end
				if (id.emoji==_sad) then
				 if (id.build.happy>-5) id.build.happy-=1
				end
    id.state='start return'
   end
   
   -- state get supplies
   if (id.state=='get supplies' and id.wait==0) then
    local source=build_get_id(gridx,gridy-2)
    if (source!=nil) then
     if (source.class==_farm) then
      if (prod[id.buy]>0) then
       prod[id.buy]-=1
       if (id.build.class==_brewery) prod[_beer]+=1
       if (id.build.class==_bakery) prod[_bread]+=1
       if (id.build.class==_tailor) prod[_clothes]+=1
       if (id.build.class==_shoemaker) prod[_shoes]+=1       
      end
     end
    end
    id.state='start return'
   end
   
   -- state start return
   if (id.state=='start return') then 
    id.hide=false
    --id.face=cycle(id.face+2,0,3)
    human_set_target(id,id.build.x,id.build.y+2)
    id.state='return' 
    id.dist=0  
    if (id.emoji==_confused) id.emoji=nil
   end
   
   -- state return
   if (id.state=='return' and (gridx==id.tox or gridx==id.tox+1) and gridy==id.toy) then 
    id.build.state='time out'
    id.build.wait=30
    if (id.build.job=='shop') id.build.wait=90
    del(human,id)
   end
  
   -- wait
   if (id.wait>0) id.wait-=1
  end   
 end
end


function human_draw()
 local id
 for id in all(human) do
  if (not id.hide) then
   spr(id.image+id.base,id.x,id.y-2,1,1,id.xflip)
   if (id.emoji!=nil) spr(id.emoji,id.x,id.y-10)   
   if (id.state=='to shop') then
    local img=(id.buy%3)*16+flr(id.buy/3)+24
    spr(img,id.x,id.y-11)
   end
  end
 end
end  
-->8
-- menu

function menu_init()
 menu={}
 menu.sel=nil
 menu.tab=0
 menu.scroll=2
 menu.wait=0
 
 builds=18 
 build_img={}
 for i=0,7 do build_img[i]=64+i*2 end
 for i=0,6 do build_img[8+i]=96+i*2 end
 build_img[_church]=192
 build_img[_univ]=195
 build_img[_theater]=198
 build_img[_house_2]=110
 build_img[_house_3]=160
 build_img[_bridge]=246
 
 price={}
 price[_woodchopper]='010.000.010' 
 price[_stonecutter]='010.010.000' 
 price[_house_1]='000.020.020' 
 price[_farm]='050.030.030' 
 price[_field]='030.010.000' 
 price[_chickens]='040.010.000' 
 price[_cows]='075.010.000' 
 price[_pigs]='050.010.000' 
 price[_sheep]='040.010.000'
 price[_brewery]='080.020.040'
 price[_bakery]='080.020.030'
 price[_tailor]='100.020.020'
 price[_shoemaker]='100.020.020' 
 price[_church]='250.50.100'
 price[_univ]='250.50.100'
 price[_theater]='250.50.100'
 price[_path_1]='001.000.000'
 price[_path_2]='005.000.002'
 price[_path_3]='010.000.005'
 price[_bridge]='050.010.020'
end


function menu_update()
 if (game=='play' or game=='continue') then
 
  -- select tab
  if (stat(34)==1 and my>=96 and mx<11) then
   menu.tab=limit(flr((my-98)/10),0,2)
   if (menu.tab==2) then
    screen='start'
    continue=true
    menu.tab=0
   end
  end
  
  -- scroll buildings
  if (menu.wait==0) then
   if (stat(34)==1 and my>=96) then
    if (click(12,103,8,8)) menu.scroll-=1
    if (click(119,103,8,8)) menu.scroll+=1
    menu.scroll=limit(menu.scroll,2,builds-5)
    menu.wait=5
   end
  else
   menu.wait-=1
  end
   
  -- select building
  if (stat(34)==1 and my>=96) then
   for i=0,4 do
    if (click(20+(i*19),98,18,18)) then
     menu.sel=i    
    end
   end
   if (click(20,117,10,10)) menu.sel=5
   if (click(31,117,10,10) and levels[level].max_path>1) menu.sel=6
   if (click(42,117,10,10) and levels[level].max_path>2) menu.sel=7
   if (click(53,117,10,10)) menu.sel=8
   if (click(64,117,10,10)) menu.sel=9
  end
  
  -- deselect
  if (stat(34)==2 and menu.sel!=nil) then
   menu.sel=nil
  end
  
  -- build
  if (stat(34)==1 and not mouse_reset and menu.sel!=nil and my<96 and menu.sel<9) then
   local w=2
   local h=2
   if (menu.sel+menu.scroll>=_church) w=3 h=3
   if (menu.sel>=5) w=1 h=1  
   if (build_allow(mapx,mapy,w,h)) then
    if (menu.sel<5) then 
     build_on_map(build_img[menu.scroll+menu.sel],mapx,mapy,w,h)
     build_new(mapx,mapy,menu.scroll+menu.sel)
    else 
     if (menu.sel==5) mset(mapx,mapy,19)
     if (menu.sel==6) mset(mapx,mapy,137)
     if (menu.sel==7) mset(mapx,mapy,201)
     if (menu.sel==8) then
      if (mget(mapx,mapy)==244) mset(mapx,mapy,246)
      if (mget(mapx,mapy)==245) mset(mapx,mapy,247)
     end    
     path_update(mapx,mapy)
    end
    
    prod[_gold]-=get_price(0)
    prod[_wood]-=get_price(1)
    prod[_stone]-=get_price(2)
   end
  end
  
  -- remove
  if (stat(34)==1 and menu.sel==9 and my<96) then
   local img=mget(mapx,mapy)
   if (not fget(img,1) and not fget(img,2) and not fget(img,6)) then
    -- remove path
    if (fget(img,0)) then
     mset(mapx,mapy,32)
     path_update(mapx,mapy)
    end
    -- remove building
    if (not fget(img,0) and not fget(img,7)) then
     local left=mapx
     local top=mapy
     local w=2
     local h=2
     if (img<192) then
      if (img%32>=16) top-=1
      if (img%2==1) left-=1
     else
      w=3
      h=3
      left-=(img%16)%3
      top-=flr((img-192)/16)
     end
     for i=0,w-1 do
      for j=0,h-1 do
       mset(left+i,top+j,32)
      end
     end
     build_remove(left,top)
    end
    -- remove bridge
    if (fget(img,7)) mset(mapx,mapy,img-2)
   end
  end
  
 end 
end


function path_update(x,y)
 -- change sprites for path
 local top,bot,left,right,img
 local i,j
 for side=0,4 do
  i=x+rx[side]
  j=y+ry[side]
  if (fget(mget(i,j),0)) then
   img=22
   top=fget(mget(i,j-1),0) or fget(mget(i,j-1),7)
   bot=fget(mget(i,j+1),0) or fget(mget(i,j+1),7)
   left=fget(mget(i-1,j),0) or fget(mget(i-1,j),7)
   right=fget(mget(i+1,j),0) or fget(mget(i+1,j),7)
   if (right) img=38
   if (left) img=39
   if (bot) img=54
   if (top) img=55
   if (right and bot) img=19
   if (left and bot) img=21
   if (right and top) img=51
   if (left and top) img=53
   if (left and right) img=22
   if (top and bot) img=23
   if (left and right and bot) img=20
   if (top and bot and right) img=35
   if (top and bot and left) img=37
   if (left and right and top) img=52
   if (left and right and top and bot) img=36
   if (mget(i,j)>100 and mget(i,j)<200) img+=118
   if (mget(i,j)>200) img+=182
   mset(i,j,img)
  end
 end
end


function build_allow(left,top,w,h)
 local allow=location_empty(left,top,w,h)
 if (menu.sel>=5 and menu.sel<=7 and fget(mget(left,top),0)) then
  local p2=fget(mget(left,top),3)
  local p3=fget(mget(left,top),4)
  if (menu.sel==5 and (p2 or p3)) allow=true
  if (menu.sel==6 and not p2) allow=true
  if (menu.sel==7 and not p3) allow=true  
 end
 if (menu.sel==8) then
  if (mget(left,top)==244 or mget(left,top)==245) allow=true else allow=false
 end
 
 -- check resources
 if (get_price(0)>prod[_gold] and get_price(_gold)>0) allow=false
 if (get_price(1)>prod[_wood]) allow=false
 if (get_price(2)>prod[_stone]) allow=false
 
 return(allow)
end


function build_on_map(base,x,y,w,h)
 for i=0,w-1 do
  for j=0,h-1 do
   mset(x+i,y+j,base+i+(j*16))
  end
 end
end
    
    
function location_empty(left,top,w,h)
 local empty=true
 for i=0,w-1 do
  for j=0,h-1 do
   if (not fget(mget(left+i,top+j),1)) empty=false
  end
 end
 
 return empty
end


function get_price(res)
 local value
 local p=menu.sel+menu.scroll
 if (menu.sel>=5) p=menu.sel+_path_1-5
 
 if (res==0) value=tonum(sub(price[p],1,3))
 if (res==1) value=tonum(sub(price[p],5,7))
 if (res==2) value=tonum(sub(price[p],9,11)) 
 return value
end


function menu_draw()
 -- draw menu
 square(cx,cy+96,128,32,7)
 box(cx+1,cy+97,126,30,5)
 
 -- draw tabs
 box(cx+1,cy+97+menu.tab*10,10,10,6)
 spr(30,cx+2,cy+98)
 spr(31,cx+2,cy+108)
 spr(29,cx+2,cy+118)
 line(cx+11,cy+97,cx+11,cy+126,7)
 
 -- draw content
 if (menu.tab==0) menu_build_draw()
 if (menu.tab==1) menu_prod_draw()
end


function menu_build_draw()
 -- draw arrow icons
 spr(46,cx+12,cy+103)
 spr(47,cx+119,cy+103)
 
 -- draw buildings
 for i=0,4 do
  box(cx+20+(i*19),cy+98,18,18,0)
  spr(build_img[i+menu.scroll],cx+21+(i*19),cy+99,2,2)
 end
 
 -- draw path icon
 spr(22,cx+21,cy+118)
 square(cx+20,cy+117,10,10,0)
 if (levels[level].max_path>1) then
  spr(140,cx+32,cy+118)
  square(cx+31,cy+117,10,10,0)
 end
 if (levels[level].max_path>2) then
  spr(204,cx+43,cy+118)
  square(cx+42,cy+117,10,10,0)
 end
 spr(246,cx+54,cy+118)
 square(cx+53,cy+117,10,10,0)
 
 -- draw destroy icon
 spr(49,cx+65,cy+118)
 square(cx+64,cy+117,10,10,0)
 
 -- draw select
 if (menu.sel!=nil) then
  if (menu.sel<5) then
   square(cx+20+(menu.sel*19),cy+98,18,18,7)
  else
   square(cx+20+((menu.sel-5)*11),cy+117,10,10,7)   
  end
  local label
  if (menu.sel<5) label=build_name[menu.sel+menu.scroll]
  if (menu.sel>=5 and menu.sel<9) label=build_name[menu.sel-5+_path_1]
  if (menu.sel==9) label='remove'
  print(label,cx+78,cy+120,7)
 end
 
end


function menu_prod_draw()
 for i=0,3 do
  for j=0,2 do
   if (i*3+j+3<prods) then
    spr(25+i+j*16,cx+13+i*28,cy+98+j*10)
    print(prod[i*3+j+3],cx+23+i*28,cy+99+j*10,7)
   end
  end
 end 
end
-->8
-- building

function build_init()
 build={}
 
 -- add all trees and mines
 local i,j
 for i=0,127 do
  for j=0,127 do
   if (mget(i,j)==64) build_new(i,j,0)
   if (mget(i,j)==66) build_new(i,j,1)
  end
 end
 
end


function build_new(x,y,class)
 local new={}
 new.x=x
 new.y=y
 new.class=class
 new.job='field'
 if (class==_tree or class==_mine) new.job='source'
 if (class==_woodchopper or class==_stonecutter or class==_farm) new.job='producer'
 if (class==_house_1) new.job='house'
 if (class==_brewery or class==_bakery or class==_tailor or class==_shoemaker) new.job='shop'
 if (class==_church or class==_univ or class==_theater) new.job='public'
 
 new.fx=nil
 new.fy=nil
 new.target_class=nil
 new.human=false
 new.state='idle'
 new.wait=0
 new.happy=0
 new.emoji=nil
 add(build,new)
end


function build_remove(x,y)
 local id=build_get_id(x,y)
 if (id!=nil) then
  if (id.human!=nil) del(human,id.human)
  if (id==world.sel) world.sel=nil
  del(build,id)
 end
end


function build_get_id(x,y)
 local id,found=nil
 local w,h
 for id in all(build) do
  w=2
  h=2
  if (id.class>=_church and id.class<=_theater) w=3 h=3
  if (x>=id.x and x<id.x+w and y>=id.y and y<id.y+h) found=id
 end
 return found
end


function build_find_class(x,y,class)
 local id,found=nil
 local best=1000
 local dist
 for id in all(build) do
  if (class==id.class) then
   dist=abs(id.x-x)+abs(id.y-y)
   if (dist<best) then
    found=id
    best=dist
   end
  end
 end
 return found
end


function build_update()
 local id
 for id in all(build) do
  
  -- state idle producer
  if (id.state=='idle' and id.job=='producer') then
   if (id.fx!=nil and fget(mget(id.x,id.y+2),0)) then
    id.human=human_new(id.x,id.y+2,id)
    id.state='working'
    human_set_target(id.human,id.fx,id.fy+2)
    id.human.state='to work'
    prod[_gold]-=1
    id.emoji=nil
   else 
    id.state='time out'
    id.wait=150 
    id.emoji=_question 
   end
  end
  
  -- state idle house
  if (id.state=='idle' and id.job=='house') then   
   local buy=flr(rnd(5))+3
   if (id.class==_house_2 and flr(rnd(3))>0) then
    buy=flr(rnd(4))+8
   end 
   if (id.class==_house_3 and flr(rnd(2))==0) then
    buy=flr(rnd(3))+_faith
   end
   local target=nil
   local allow=false
   if (id.fx!=nil) then
    if (buy<=_wool and id.target_class==_farm) allow=true
    if (buy==_bread and id.target_class==_bakery) allow=true
    if (buy==_beer and id.target_class==_brewery) allow=true
    if (buy==_clothes and id.target_class==_tailor) allow=true
    if (buy==_shoes and id.target_class==_shoemaker) allow=true
    if (buy==_faith and id.target_class==_church) allow=true
    if (buy==_books and id.target_class==_univ) allow=true
    if (buy==_fun and id.target_class==_theater) allow=true
   end
   if (not allow) then
    local class=_farm
    if (buy==_bread) class=_bakery
    if (buy==_beer) class=_brewery
    if (buy==_clothes) class=_tailor
    if (buy==_shoes) class=_shoemaker
    if (buy==_faith) class=_church
    if (buy==_books) class=_univ
    if (buy==_fun) class=_theater
    target=build_find_class(id.x,id.y,class)
   end   
   if ((allow or target!=nil) 
   and fget(mget(id.x,id.y+2),0)) then
    id.human=human_new(id.x,id.y+2,id)
    id.human.base=0
    id.state='shopping'
    if (allow) then
     human_set_target(id.human,id.fx,id.fy+2)
    else
     if (target.class<_church) then
      human_set_target(id.human,target.x,target.y+2)
     else
      human_set_target(id.human,target.x+1,target.y+3)
     end
    end
    id.human.state='to shop'
    id.human.buy=buy
    id.emoji=nil
   else
    id.state='time out'
    id.wait=90
    id.emoji=_question
   end
  end
  
  -- state idle shop
  if (id.state=='idle' and id.job=='shop') then
   target=nil
   if (id.fx==nil) then
    target=build_find_class(id.x,id.y,_farm)
   end
   if (fget(mget(id.x,id.y+2),0) and (id.fx!=nil or target!=nil)) then
    local buy=_grain
    id.human=human_new(id.x,id.y+2,id)
    id.human.base=143
    id.state='supplies'
    if (id.fx!=nil) then
     human_set_target(id.human,id.fx,id.fy+2)
    else
     human_set_target(id.human,target.x,target.y+2)
    end
    id.human.state='to supply'
    if (id.class==_tailor) buy=_wool
    if (id.class==_shoemaker) buy=_meat
    id.human.buy=buy
    id.emoji=nil
   else
    id.state='time out'
    id.wait=90
    id.emoji=_question
   end
  end
  
  -- idle public
  if (id.state=='idle' and id.job=='public') then
   if (id.class==_church) prod[_faith]+=1
   if (id.class==_univ) prod[_books]+=1
   if (id.class==_theater) prod[_fun]+=1
   id.state='time out'
   id.wait=90   
   prod[_gold]-=2
  end
  
  -- upgrade house
  if (id.class==_house_1 or id.class==_house_2) then
   if (id.happy>=5) then
    if (id.class==_house_1 and levels[level].max_house>1) then
     id.class=_house_2
     build_on_map(build_img[_house_2],id.x,id.y,2,2)     
    elseif (id.class==_house_2 and levels[level].max_house==3) then
     id.class=_house_3
     build_on_map(build_img[_house_3],id.x,id.y,2,2)
    end
    id.happy=0
   end 
  end
  
  -- state time out
  if (id.state=='time out') then 
   id.wait-=1
 	 if (id.wait==0) id.state='idle'
  end
  
 end
end
-->8
-- world

function world_init()
 world={}
 world.sel=nil
 world.frame=0
end


function world_generate()
 -- grass
 local i,j
 for i=0,31 do
  for j=0,31 do
   if (flr(rnd(30))==0) mset(i,j,48) else mset(i,j,32)
  end
 end   
 
 -- river
 if (flr(rnd(2)==0)) then
  local x=flr(rnd(32))
  local y=0
  local turn
  while y<32 do
   mset(x,y,245)
   y+=1
   turn=flr(rnd(3))
   if (turn==1) then
    mset(x,y,243) 
    mset(x-1,y,240)
    x-=1
    y+=1
   end
   if (turn==2) then
    mset(x,y,242) 
    mset(x+1,y,241)
    x+=1
    y+=1
   end
  end  
 end
   
 -- trees and mines
 local x,y,res,nr
 for res=0,1 do
  for nr=0,flr(rnd(12))+3 do
   repeat
    x=flr(rnd(30))
    y=flr(rnd(30))
   until (location_empty(x,y,2,2))
   local base=build_img[res]
   for i=0,1 do
    for j=0,1 do
     mset(x+i,y+j,base+i+(j*16))
    end
   end
   build_new(x,y,res)
  end
 end
end


function world_update()
 -- objectives ok
 if (game=='start' and btnp(4)) then
  game='play'
  if (levels[level].minutes!=nil) then
   world.minutes=levels[level].minutes
   world.seconds=0 
   world.timer=0
  end
 end
	  
 if (game=='play' or game=='continue') then
  -- select building
  if (stat(34)==1 and my<96) then
   world.sel=build_get_id(mapx,mapy)
  end
  
  -- select target
  if (stat(34)==2 and my<96 and world.sel!=nil) then  
   local id=world.sel
   local target=build_get_id(mapx,mapy)
   if (target!=nil) then
    if (id.job!='field') then
     local allow=false
     if (id.class==_woodchopper and target.class==_tree) allow=true
     if (id.class==_stonecutter and target.class==_mine) allow=true
     if (id.class==_farm and target.job=='field') allow=true
     if (id.job=='house' and target.class==_farm) allow=true
     if (id.job=='shop' and target.class==_farm) allow=true
     if (allow) then
      id.fx=target.x 
      id.fy=target.y
      id.target_class=target.class
      if (id.human) id.human.state='start return'
     end
    end
    if (target.x==id.x and target.y==id.y) then
     id.fx=nil
     id.fy=nil 
     if (id.human) then
      id.human.tox=id.x 
      id.human.toy=id.y+2
      id.human.state='return'
     end
    end
   end
  end
 
  -- check objectives
  if (game!='continue') then
   local won=true
   local pt=levels[level].prod_type
   if (pt!=nil) then
    local pn=levels[level].prod_nr
    if (prod[pt]<pn) won=false
   end
   local bt=levels[level].build_type 
   if (bt!=nil) then
    local bn=levels[level].build_nr
    local nr=0
    for id in all(build) do
     if (id.class==bt) nr+=1
    end
    if (nr<bn) won=false
   end
   if (levels[level].minutes!=nil) then
    if (world.minutes==0 and world.seconds==0) game='lost'
   end
   if (won) game='won'
 	end
 	
 	-- timer
 	if (levels[level].minutes!=nil) then
 	 world.timer+=1
 	 if (world.timer==30) then
 	  world.timer=0
 	  world.seconds-=1
 	  if (world.seconds<0) then
 	   world.seconds=59
 	   world.minutes-=1
 	   if (world.minutes<0) then
 	    world.minutes=0
 	    world.seconds=0
 	   end
 	  end
 	 end
 	end
 end

 -- won panel
 if (game=='won' or game=='lost') then
  if (btnp(4) and game=='won') game='continue'
  if (btnp(5)) then
   screen='start'
   mouse_reset=true
   game='none'
  end
 end
end


function world_draw()
 -- all animations
 world.frame+=1
 if (world.frame==10) world.frame=0
 
 -- draw emoji
 local id
 for id in all(build) do
  if (id.emoji!=nil) then
   local y=-8
   if (id.y==0) y=4
   spr(id.emoji+flr(world.frame/5),id.x*8+4,id.y*8+y)
  end
 end

 -- draw build location
 if (menu.sel!=nil and my<96) then
  if (menu.sel<9) then
   local col=8
   local w=2 
   local h=2
   if (menu.sel+menu.scroll>=_church) w=3 h=3
   if (menu.sel>=5) w=1 h=1
   if (build_allow(mapx,mapy,w,h)) col=3
   square(mapx*8,mapy*8,w*8,h*8,col)
  else
   spr(49,mapx*8,mapy*8)
  end
 end
 
 -- draw map selection
 if (world.sel!=nil) then
  local id=world.sel
  local left=id.x*8-1
  local top=id.y*8-1 
  local w=17
  local h=17
  if (id.class>=_church and id.class<_house_2) w=25 h=25
  rect(left,top,left+w,top+h,7)
  if (id.fx!=nil) then
   spr(61+flr(world.frame/5),id.fx*8+6,id.fy*8-2)
  end
 end
end


function gamestate_draw()
 -- draw objectives
 if (game=='start') then
  panel(cx+16,cy+26,96,56)
  cprint('level '..level..' objectives',cx+64,cy+32,7)
  local y=cy+44
  local char
  if (levels[level].prod_type!=nil) then
   print('collect '..levels[level].prod_nr,cx+20,y,7)
   char=#tostr(levels[level].prod_nr)+8
   spr(16,cx+22+char*4,y-1)
   print(prod_name[levels[level].prod_type],cx+35+char*4,y,7)
   y+=12
  end
  if (levels[level].build_type!=nil) then
   print(levels[level].build_nr,cx+20,y,7)
   char=#tostr(levels[level].build_nr)
   spr(16,cx+24+char*4,y-1)
   print('build '..build_name[levels[level].build_type],cx+35+char*4,y,7)
   y+=12
  end
  if (levels[level].minutes!=nil) then
   print('in '..levels[level].minutes..' minutes',cx+20,y,7)
  end
  
  cprint('press c to start',cx+64,cy+73,7)
 end
 
 -- draw play
 if (game=='play') then
  if (levels[level].minutes!=nil) then
   if (world.seconds>9) then
    print(world.minutes..':'..world.seconds,cx+1,cy+11,7)
   else
    print(world.minutes..':0'..world.seconds,cx+1,cy+11,7)
   end
  end
 end
 
 -- draw won
 if (game=='won') then
  panel(cx+16,cy+32,96,44)
  cprint('level complete!',cx+64,cy+39,7)
  cprint('press x to stop', cx+64,cy+51,7)
  cprint('press c to continue',cx+64,cy+63,7)
 end
 
 -- draw lost
 if (game=='lost') then
  panel(cx+16,cy+32,96,44)
  cprint('you have lost...',cx+64,cy+39,7)
  cprint('press x to stop', cx+64,cy+51,7)
 end
 
end
-->8
-- start screen

function start_update()
 if (stat(34)==1 and not mouse_reset) then
  
  -- start new level
  for i=0,1 do
   for j=0,3 do
    if (click(35+i*30,35+j*13,28,11)) then 
     level=i+j*2+1
     screen='game'
     game='start'
     for p=0,prods-1 do 
      prod[p]=0
     end
     prod[_gold]=levels[level].gold
     prod[_wood]=levels[level].wood
     prod[_stone]=levels[level].stone        
     build={}
     human={}
     world_generate()
     menu.sel=nil
     menu.scroll=2
     world.sel=nil
     cx=0
     cy=-10
     builds=levels[level].max_build+1
    end   
   end
  end    
 
  -- continue
  if (click(43,87,42,11) and game!='none') then
   menu.sel=nil
   world.sel=nil
   screen='game'
  end
  
  -- help
  if (click(43,100,42,11)) then
   screen='help'
  end
 end
 
 if (stat(34)==0) mouse_reset=false
end


function start_draw()
 -- background
 camera(0,0)
 map(112,0)
 
 -- menu
 panel(31,15,66,100)
 
 -- logo
 spr(162,36,18,7,2)
 
 for i=0,1 do
  for j=0,3 do
   button(35+i*30,35+j*13,28,11)
   cprint('lvl '..tostr(i+j*2+1),49+i*30,41+j*13,7)
  end
 end 
 button(43,87,42,11)
 button(43,100,42,11)
 local col=5
 if (continue) col=7
 cprint('continue',64,93,col)
 cprint('help',64,106,7)
 
 spr(63,mx,my)
end
-->8
-- help screen

function help_init()
 help_text={
 'color 13',
 'rules:',
 'color 7',
 '- build roads from door to ',
 '  door.',
 "- humans can't plan ahead,",
 "  keep your road map simple.",
 "- select a building with left",
 "  mouse button.",
 "- select destination by",
 "  placing a flag with right",
 "  mouse button.",
 "- you need gold, wood and ",
 "  stone to construct buildings.",
 '- use the arrow keys to scroll.',
 '- all active buildings except',
 '  houses cost money.',
 '- to deactivate a building,',
 '  place the flag on itself.',
 '- if villagers get lost, help',
 '  them by selecting a target.',
 
 '',
 -- wood chopper
 'color 13',
 'wood chopper and tree:',
 'image 068 004 2 2',
 'image 064 024 2 2',
 'color 7',
 'offset 44',
 'produces wood:',
 'image 040 044 1 1',
 '','',
 'offset 4',
 'color 7',
 'you must place a flag on a',
 'tree to start harvesting wood.',
 '',
 -- stone cutter
 'color 13',
 'stone cutter and mine:',
 'image 070 004 2 2',
 'image 066 024 2 2',
 'offset 44',
 'color 7',
 'produces stone:',
 'image 056 044 1 1',
 '','',
 'offset 4',
 'color 7',
 'you must place a flag on a',
 'mine to start collecting',
 'stone.',
 '', 
 -- farm
 'color 13',
 'farm:',
 'image 074 004 2 2',
 'color 7',
 'offset 24',
 'produces grain, eggs',
 'milk, meat, wool.',
 'image 025 024 1 1',
 'image 041 044 1 1',
 'image 057 064 1 1',
 'image 026 084 1 1',
 'image 042 104 1 1',
 '','',
 'color 7', 
 'offset 4',
 'you must select a field with', 
 'the right mouse button.',
 'build a road from the farm to',
 'the fields.',
 '',
 -- fields
 'color 13',
 'fields:',
 'image 076 004 2 2',
 'image 078 029 2 2',
 'image 096 054 2 2',
 'image 098 079 2 2',
 'image 100 104 2 2',
 'color 7',
 '','','',
 'grain chickens cows pigs sheep',
 '',
 -- house lvl 1
 'color 13',
 'house level 1:',
 'image 072 004 2 2',
 'image 024 024 1 1',
 'color 7',
 'offset 36',
 'villagers will try to',
 'buy grain, eggs, milk,',
 'offset 24',
 'meat and wool at the',
 'offset 4',
 'nearest farm. villagers pay',
 'in gold.',
 '',
 -- paths
 'color 13',
 'paths:',
 'image 022 004 1 1',
 'image 140 016 1 1',
 'image 204 028 1 1',
 'image 246 040 1 1',
 'color 7',
 'offset 52',
 'people only walk',
 'on paths. the',
 'offset 4',
 'first path is the cheapest,',
 'but the slowest to travel.',
 'build bridges across the river.',
 '',
 -- shops
 'color 13',
 'shops:',
 'image 102 004 2 2',
 'image 104 034 2 2',
 'image 106 064 2 2',
 'image 108 094 2 2',
 '', '', '',
 'color 7',
 'brewery bakery tailor shoemaker',
 'offset 4', 
 'shops produce beer, bread,',
 'clothes and shoes.',
 'image 027 004 1 1',
 'image 058 024 1 1',
 'image 043 044 1 1',
 'image 059 064 1 1',
 '','',
 'beer and bread need grain.',
 'clothes need wool and shoes',
 'need meat (leather).',
 '',
 -- house lvl 2
 'color 13',
 'house level 2:',
 'image 110 004 2 2',
 'color 7',
 'offset 24',
 'happy villagers upgrade',
 'their houses. level 2',
 'houses mainly buy', 
 'offset 4', 
 'products from shops.',
 '',
 -- house lvl 3
 'color 13',
 'house level 3:',
 'image 160 004 2 2',
 'color 7',
 'offset 24',
 'level 3 houses also visit',
 'the church, university',
 'and theater.',
 '', 
 -- public places
 'color 13',
 'offset 4',
 'public places:',
 'image 192 004 3 3',
 'image 195 040 3 3',
 'image 198 076 3 3',
 '','','','',
 'color 7',
 'church university theater',
 'they produce faith, books and',
 'fun:',
 'image 028 004 1 1',
 'image 044 024 1 1',
 'image 060 044 1 1', 
 '','','',
 'color 15',
 'picopolis was made by',
 'kim wijsbeek' 
 }
end


function help_update()
 if (btn(2)) help_scroll+=2
 if (btn(3)) help_scroll-=2
 help_scroll=limit(help_scroll,-750,20)
 if (btn(5)) screen='start'
end

 
function help_draw()
 cls()
 panel(0,0,128,128)
 print('help - scroll with up and down',4,4,8) 
 cprint('press x to exit',64,120,8)
 local hy=help_scroll
 local hx=4
 
 clip(4,16,120,92)
 color(7)
 
 for i in all(help_text) do
  if (sub(i,1,5)=='color') then
   -- change color
   color(tonum(sub(i,7,8)))
  elseif (sub(i,1,5)=='image') then
   local img=tonum(sub(i,7,9))
   local x=tonum(sub(i,11,13))
   local w=tonum(sub(i,15,15))
   local h=tonum(sub(i,17,17))
   square(x,hy,w*8+2,h*8+2,7)
   box(x+1,hy+1,w*8,h*8,0)
   spr(img,x+1,hy+1,w,h)
   color(7)
  elseif (sub(i,1,6)=='offset') then
   hx=tonum(sub(i,8,10))
  else
   -- print line
   print(i,hx,hy)
   hy+=8
  end
 end

end

__gfx__
00000000000990000009900000099000000990000009900000099000000990000011100000111000001110000001100000011000000110000001100000000000
00000000000f9000000f9000000f90000009900000099000000ff000000ff000000f9000000f9000000f90000009900000099000000ff000000ff00000000000
0070070000088000000880000008800000888800008888000028820000288200000dd000000dd000000dd00000dddd0000dddd00001dd100001dd10000000000
0007700000082000000820000008220000288200002880200028820002088200000d1000000d1000000d1100001dd100001dd010001dd100010dd10000000000
000770000008200000f2800000088f0000288200000880f0002882000f088200000d100000f1d000000ddf00001dd100000dd0f0001dd1000f0dd10000000000
007007000001f000080110000801100000f11f000001100000f11f000001f0000001f000090110000901100000f11f000001100000f11f000001f00000000000
00000000000110000810018008100180000110000001000000011000000100000001100009100190091001900001100000010000000110000001000000000000
00000000000880000000008000000080000880000008000000088000000800000009900000000090000000900009900000090000000990000009000000000000
000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bb0077aa0000090a0000000ee000077700000ff000099999900008800000ffff00
000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5444bb0a9999a00a00a0a0000eef7e00777770000aa00009aaaa90008888000f4444f0
007070000000000000000000bbb444444454444445444bbb44445444bb4444bb799aa99a0090a90000eefffe666aaa600ffaaff009999990088668800dffffd0
000700000000000000000000bb44444444444444444444bb45444444bb4444bb79aaaa9aa00a00000eeeeee8606999600aaaaaa009aaaa908867768804dddd40
007070000000000000000000bb44444544444544444544bb44444454bb4445bba9aaaa9a090a9a00effeee8060699960000aa000099999908677776804444440
000000000000000000000000bb44444444444444444444bb44454444bb5444bba99aa99a00a00000ef7fe80006699960000aa00009aaaa9007447c700d4444d0
000000000000000000000000bb44544bb444444bb44444bbbbbbbbbbbb4444bb0a9999a0a9a9a0000efe800000699960000aa0000999999007447c7004dddd40
000000000000000000000000bb4444bbbb4444bbbb4444bbbbbbbbbbbb4454bb00aaaa0000a000000088000000066600000aa00009aaaa900744777000444400
bbbbbbbb0000000000000000bb4444bbbb4454bbbb5444bbbbbbbbbbbbbbbbbb00001110000fff00000676000011110000000000000000005555555555555555
bbbbbbbb0000000000000000bb54444bb444444bb44444bbbbbbbbbbbbbbbbbb0001444100f7fff0006000600d1441d0fff1fff0000000005557555555557555
bbbbbbbb0000000000000000bb44444444444444444444bbbbb4444444454bbb00144441007ffff007007007d11dd11dfff1fff0000000005576555555556755
bbbbbbbb0000000000000000bb44444454445445444444bbbb445444444444bb011444410fffffff0607060611111111fff1fff0000000005766777557776675
bbbbbbbb0000000000000000bb44444444444444444454bbbb444444544444bb144144100fffffff7006007000111100fff1fff0000000005666666556666665
bbbbbbbb0000000000000000bb45444444444444444444bbbbb4444444444bbb4ff411000fffff6f6000670600499400fff1fff0000000005566555555556655
bbbbbbbb0000000000000000bb44444bb445444bb44444bbbbbbbbbbbbbbbbbb4ff4100000fff6f06000000600111100fff1fff0000000005556555555556555
bbbbbbbb0000000000000000bb4445bbbb4444bbbb4544bbbbbbbbbbbbbbbbbb04410000000fff00000000000111111044444440000000005555555555555555
bbbbbbbb0000000000000000bb4444bbbb4444bbbb4444bbbbbbbbbbbb4444bb000d60000ccccc00000000aa00009400011166600900ee0009ee00ee11100000
b3bbbbbb0800008000000000bb44444bb444444bb44444bbbbbbbbbbbb4454bb00dd66000c776c0000000999000914100111666007ee22ee0782ee2817711000
b33bbbbb0080080000000000bb44444444445444444445bbbbb44bbbbb4444bb0d61d66000c6c0000000aa900091441401016060078822880782882817777110
bb3bbbbb0008800000000000bb44544444444444444444bbbb4454bbbb4544bb6d661d600c777c00000999000044414401116660078800880700880001777771
bbbbb3bb0008800000000000bb44444445444454444444bbbb4444bbbb4444bb61d66ddd0c777c0000aa90000001144001116660070000000700000001777771
bbbb33bb0080080000000000bbb444454444444445444bbbbb5444bbbbb45bbb01dd6d1d0c776c00099900000044440001016060070000000700000000177710
bbbb3bbb0800008000000000bbbbbbbbbbbbbbbbbbbbbbbbbb4454bbbbbbbbbb0d6ddd100c776c00aa9000009444400001100660070000000700000000177171
bbbbbbbb0000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbb006d11d000ccc000990000000444000000116600070000000700000000011010
bbbbb555555bbbbbbbbbb555555bbbbb9a999a09a99a9a99dddddddddddddddd22222222222222229f777fafaaafafa967676767676767676767676767676767
bbbb5b3b3b35bbbbbbb55566d6555bbbaa9a904099a99a99d55555550555555d28e28e00000e28e29a757aa00aaaaaf967676767676767676767676767676767
bbb533b3333b5bbbbb556666666655bba9aa0c0409a9999ad5dddd00c0dddd5d28828807770828829a777af040aafaa974444444444444467444444444444446
bb5b3333b333b5bbb5566d66666d655b99a0ccc04099a9a9d5ddd04c0ddddd5d22822800700822829a666aaa040aaaa969a9a99aa99a99a66444844454444446
bb533b3333b335bbb56d666dd6d6665b9a990ccc0409a9a9d5ddd0c00ddddd5d2222222070222222996669999040009974444444444444477449744444444447
b5b3333333333b5b56665ddddddd66659a9990c090409999d5dd0c0040dddd5d28e28e00700e28e29a999aafaa0ccc0969a99a9a99a9a9966444777444448446
b53333333333335b56dd5ddddddddd65a9aa990a9904099ad5dd0c0d040ddd5d28828807770828829afaaaaaaa0c00c074444444444444477444774444447947
b55333333333355b5ddddddd5dddddd5a999a999a9900a99d55550555040555d22822800000822829aaaafaaaa0c0a096a9a999a999a99966454494444777446
b53535333335335b5d5ddddd5ddd5dd59a9a99a9a9a99a9adddddddddd00dddd22222222222222229faafafaaaa0c0a974444444444444477444444444477447
bb535333533335bb5dddddddddddddd5111111111111111155555555555555555555555555555555999999999999099969a99aa99a99a9a66444448445494446
bbb5335333535bbb5dddddddddddddd515555555555555511dd1dd1dd1dd1dd1effffffffffffeee444444444444444474444444444444477444497444444447
bbbb55555555bbbb5ddddd0000ddddd514444444444444411111111111111111ef2222eefddffffe46666646664666646a99a99a9a999a966444447774444546
bbbbb544445bbbbb5d5dd000000dd5d5155111555cc5555111d444d1ddccd1d1ee2882ffdccdeefe44555444cc44cc4474444444444444477454447744444447
bbbbb544445bbbbb5dddd000000dd5d5144111444cc444411114441111cc1111ef2882ffddddfffe465c5646cc46cc6469a999a9a99a99a66444444944444446
bbbbbb5555bbbbbb5dd5d055550dddd515511155555555511dd4441dd1dd1dd1ef2882fffffffffe465556466646666467177717676767676717771767676767
bbbbbbbbbbbbbbbb5dd5d555555dddd514411144444444411114441111111111ee2882eeeeeeeeee4d555d4ddd4dddd467166617676767676716661767676767
676767676767676767676767676767676767676767676767d1d1d1d1d1d1d1d12222222222222222bbbb4bbbbbbbbbbbbb288288288282bb1661661661661661
67676767676767676767676767676767676767676767676711111110000111112ee2ee2002ee2ee2bbbb4bbbb000000bbb288280000082bb1dd1d00000001dd1
7bbbfbbbbbbbbbb674444444444444467bbbbbbbbbbbbbb61d1d100777701d1d2882880990882882bbb4d41401111110bb200804444402bb1111107777701111
6b707bbbbbb3bbb664444544444e44466bbbbffbbbbbbbb611110666666011112ee2e0aa90ee2ee2bbb4d41401100110b28040005550822b1661600707001661
7b7770070bbbbbb774444444444ee4477b3bb00ffffbbbb7d1d106069960d1d128820999028ddd82bb4dfd4100111100b28044444440822b1dd1dd07070d1dd1
6bbb70700bbbbbb664444444eeee0e466bbbb00fffffb3b611110606996011112ee0aa90e2ed0de2bb4dfd414049940bb22204444440222b1111100707001111
7bbb77777bbbb3b77444444eeeeee4477bbbbbbfffffbbb71d1d066699601d1d28099908828ddd82b4df77d41011110b28828000000828821661607777701661
63bb7bbe7bbfbbb665444444eeee44466bbbbbb0bbb0bbb6111110066660111120aa902ee2e555e2b4dfffd41400001b28828828828828821dd1d00000001dd1
7bbbbbbbbbb707b77444e444e44e44477bffbbbbbbbbbbb7d1d1d1000000d1d120990222222555224df77ffd4144444122222222222222221111111111111111
6bbbbb30700777b6644ee444444444466b00ffffbbbbbbb61111111111111111ff00fffffff555ffdfffffffddddddddeffeffeffeffeffe1555555555555551
7bbbbbb00707bbb774e0eeee444444577b00fffffbbbbbb74fffff4ffffffff477777777777555774f77f77f4f77f77feeeeeeeeeeeeeeee1777777777777771
6bbbbbb77777bbb6644eeeeee44444466bbbfffffbb3bbb644444444444444447772222777d555d74fffffff4fffffffff2222ffefccffef1771111771117771
7b3bbbb7ebb7bbb77444eeee444444477bbb0bbb0bbbbbb74f111f4fccffccf4777288277d55055d4ff888f74fccfccfee2882eeeecceeee1771221771c17771
6bbbbbbbbbbbbbb66444e44e444544466bbbb3bbbbbbbbb64f111f4fccffccf4777288277550005547f888ff4fccfccfef2882effeffeffe1771221771117771
6717771767676767671777176767676767177717676767674f111f4ffffffff477728827755909554ff888ff477fffffee2882eeeeeeeeee1771221777777771
6716661767676767671666176767676767166617676767674d111d4dddddddd4fff2882ff55555554ff8887f4fffff77ff2882ffeffeffef1dd1221dddddddd1
007777000077770000777000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5dd5bb0000000000000000
07aaaa700788887007000700007770000077770000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5dd5bb0000000000000000
7a1aa1a77818818700000700070007000000007000000000000000000000000000000000bb55555555555555555555bb55555555bb56d5bb0000000000000000
7aaaaaa77888888700007000000007000777707000000000000000000000000000000000bb5dddd6d6ddddddd6ddd5bbddd6ddddbb5dd5bb0000000000000000
7a1aa1a77881188700070000000070000700707000000000000000000000000000000000bb5d6ddddddddd6ddddd65bbddddd6ddbb5dd5bb0000000000000000
7aa11aa77818818700000000000700000700007000000000000000000000000000000000bb5dd555555dd555555dd5bb55555555bb5dd5bb0000000000000000
07aaaa700788887000070000000000000077770000000000000000000000000000000000bb5dd5bbbb5d65bbbb5dd5bbbbbbbbbbbb5d65bb0000000000000000
007777000077770000000000000700000000000000000000000000000000000000000000bb56d5bbbb5dd5bbbb5d65bbbbbbbbbbbb5dd5bb0000000000000000
000dd000000dd000000dd000000dd000000dd000000dd000000dd0000000000000000000bb5dd5bbbb5dd5bbbb5dd5bbbbbbbbbbbbbbbbbb0000000000000000
000f9000000f9000000f90000009900000099000000ff000000ff0000000000000000000bb56d5bbbb56d5bbbb5dd5bbbbbbbbbbbbbbbbbb0000000000000000
000770000007700000077000007777000077770000d77d0000d77d000000000000000000bb5dd555555dd5555556d5bbb55555555555555b0000000000000000
0007d0000007d0000007dd0000d77d0000d770d000d77d000d077d000000000000000000bb5dddddd6ddddddddddd5bbb5dddd6ddddddd5b0000000000000000
0007d00000fd700000077f0000d77d00000770f000d77d000f077d000000000000000000bb5dddd6ddddddd6d6ddd5bbb5d6dddddd6ddd5b0000000000000000
000df000040dd000040dd00000fddf00000dd00000fddf00000df0000000000000000000bb5dd555555dd555555dd5bbb55555555555555b0000000000000000
000dd00004d00d4004d00d40000dd000000d0000000dd000000d00000000000000000000bb56d5bbbb56d5bbbb5dd5bbbbbbbbbbbbbbbbbb0000000000000000
000440000000004000000040000440000004000000044000000400000000000000000000bb5dd5bbbb5dd5bbbb56d5bbbbbbbbbbbbbbbbbb0000000000000000
bbbbbb2222bbbbbb00000000000000000000000000000000000000000000000000000000bb5dd5bbbb5dd5bbbb5dd5bbbbbbbbbbbb5dd5bb0000000000000000
bbbb000000000bbb00000000000000000000000000000000000000000000000000000000bb56d5bbbb5dd5bbbb5dd5bbbb5555bbbb5dd5bb0000000000000000
bb220777777702bb00000000000000000000000000000000000000000000000000000000bb5dd555555d6555555dd5bbbb5dd5bbbb5d65bb0000000000000000
22ef007070700e2200000000000000000000000000000000000000000000000000000000bb5dd6dddd6dddddddd6d5bbbb56d5bbbb5dd5bb0000000000000000
2feee0707070eef200777740000000000000000000000000000000000000000000000000bb5dddddddddddd6ddddd5bbbb5dd5bbbb56d5bb0000000000000000
2eef007070700ee200740074074000774000774000777400007740007400007400777400bb55555555555555555555bbbb5d65bbbb5dd5bb0000000000000000
2fee077777770ef200740074000007400007407400740740074074007400000007400000bbbbbbbbbbbbbbbbbbbbbbbbbb5dd5bbbb5555bb0000000000000000
2eef000000000ee200740074074074000074000740740740740007407400007407400000bbbbbbbbbbbbbbbbbbbbbbbbbb5dd5bbbbbbbbbb0000000000000000
2f225566665522f20077774007407400007400074070074074000740740000740077400000000000000000000000000000000000000000000000000000000000
22556666666655220074000007407400007400074077740074000740740000740000740000000000000000000000000000000000000000000000000000000000
55666666666666550074000007400740000740740074000007407400740000740000740000000000000000000000000000000000000000000000000000000000
44222244444444440074000007400077400077400074000000774000777740740777400000000000000000000000000000000000000000000000000000000000
462ee265c5665c540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
462ee265c5665c540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
462ee265556655540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
462ee266666666640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb1bbbbbbbbbbbbbbbbbbbb5555bbb000000000bbbb5555bbbbbbbb50000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb6666bbbbbbbbbb00000000
bb161bbbbbbbb000bbbbbbbb56655550fff5fff055555665bbbb5555605556605555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb6776bbb776776b00000000
bb1c1bbbbbbb00900bbbbbbb5d65d660fff5fff0666d5665b5556666605050606666555bbb66666666666666666666bb66666666bb6776bbb776776b00000000
b16cc1bbbbbb09990bbbbbbb5665d660fff5fff0666d5665566666666055566066666665bb67777767777777677776bb67777777bb6776bbb666666b00000000
b1ccc1bbbbbb00900bbbbbbb5665d660fff5fff0666d5d65566666666050506066666665bb67777767777777677776bb67777777bb6776bbb776776b00000000
16cc6c1bbbbbb090bbbbbbbb5665d660fff5fff0666d5665555566666050006066665555bb67766666677666666776bb66666666bb6776bbb776776b00000000
1ccccc1bbbbbb000bbbbbbbb56d5d66044454440666d5665544455556605560655554445bb6776bbbb6776bbbb6776bbbbbbbbbbbb6776bbb666666b00000000
1111111bbbbbbbbbbbbbbbbb5665d66000000000666d56655fff4444555000554444fff5bb6776bbbb6776bbbb6776bbbbbbbbbbbb6776bbbbbbbbbb00000000
1fffff1111111111111111115555d66666666666666d55555fffffff44444444fffffff5bb6666bbbb6666bbbb6666bbbbbbbbbbbbbbbbbb0000000000000000
1ff1ff1cccccccccccc6ccc15dd555555555555555555dd55ff11ffffffffffffff11ff5bb6776bbbb6776bbbb6776bbbbbbbbbbbbbbbbbb0000000000000000
1f1d1f1c6cccc6ccccccccc15dd5dddddddddddddddd5dd55ff11fff11ffff11fff11ff5bb67766666677666666776bbb66666666666666b0000000000000000
1f1d1f1ccc6cccccc6ccccc15dd5d1dd1dd11dd1dd1d5dd55fffffff11ffff11fffffff5bb67777767777777777776bbb67777776777776b0000000000000000
1f111f1cccccccccccccccc15dd5d1dd1dd11dd1dd1d55d55ffffffffffffffffffffff5bb67777767777777777776bbb67777776777776b0000000000000000
1fffff1cc6cccc6ccccc6cc155d5dddddddddddddddd5dd55444ffffffffffffffff4445bb67766666677666666776bbb66666666666666b0000000000000000
1111111cccccccccc6ccccc15dd5dddddddddddddddd5dd55fff4444ffffffff4444fff5bb6776bbbb6776bbbb6776bbbbbbbbbbbbbbbbbb0000000000000000
1fffff1cccc6cccccccccc615dd555555555555555555dd55fffffff44444444fffffff5bb6776bbbb6776bbbb6776bbbbbbbbbbbbbbbbbb0000000000000000
1fffff1111111111111111115dd5dddddd6d6ddddddd5dd55ff11ffffffffffffff11ff5bb6666bbbb6666bbbb6666bbbbbbbbbbbb6666bb0000000000000000
1fffff1ffffffffffffffff15dd5d11d5655556dd11d5dd55ff11ffff555555ffff11ff5bb6776bbbb6776bbbb6776bbbb6666bbbb6776bb0000000000000000
1fffff1fffff555ffffffff15dd5d11d65444456d11d5dd55ffffffff522225ffffffff5bb67766666677666666776bbbb6776bbbb6776bb0000000000000000
1ff1ff1f1ff54445ff1ff1f15d55ddddd544445ddddd5dd55ffffffff522225ffffffff5bb67777767777777677776bbbb6776bbbb6776bb0000000000000000
1ff1ff1f1f5444445f1ff1f15dd5d5dd65444456dddd5dd55ffffffff522225ffffffff5bb67777767777777677776bbbb6776bbbb6776bb0000000000000000
1ff1ff1f1f5555555f1ff1f15dd5ddddd544445dd5dd5dd5b555fffff522225fffff555bbb66666666666666666666bbbb6776bbbb6776bb0000000000000000
1fffff1fff5444445ffffff15dd5dddd65444456dddd5dd5bbbb5555f522225f5555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb6776bbbb6666bb0000000000000000
111111111155555551111111555555555555555555555555bbbbbbbb55555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb6776bbbbbbbbbb0000000000000000
bbbbbbbbbbbbbbbbb1cccc1bb1cccc1bbbbbbbbbb1cccc1bb555555bb1cccc1b0000000000000000000000000000000000000000000000000000000000000000
bbbb11111111bbbbb1ccccc11ccccc1b11111111b1cccc1b15999951555555550000000000000000000000000000000000000000000000000000000000000000
bbb1cccccccc1bbbb1cccccccccccc1bccccccccb1cccc1bc544445c594949450000000000000000000000000000000000000000000000000000000000000000
bb1cccccccccc1bbb1cccccccccccc1bccccccccb1cccc1bc599995c594949450000000000000000000000000000000000000000000000000000000000000000
b1cccccccccccc1bbb1cccccccccc1bbccccccccb1cccc1bc544445c594949450000000000000000000000000000000000000000000000000000000000000000
b1cccccccccccc1bbbb1cccccccc1bbbccccccccb1cccc1bc599995c594949450000000000000000000000000000000000000000000000000000000000000000
b1ccccc11ccccc1bbbbb11111111bbbb11111111b1cccc1b15444451555555550000000000000000000000000000000000000000000000000000000000000000
b1cccc1bb1cccc1bbbbbbbbbbbbbbbbbbbbbbbbbb1cccc1bb555555bb1cccc1b0000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000001010101010000000000000000020000010101010100000000000000000200000101010101000000000000000004040404000000000000000000000000040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000909090909000000000000000000000009090909090000000000000000000000090909090900000000000000000000000000000000000000000000000000000011111111110100000000000000000000111111111100000000000000000000001111111111000040404040404080800000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020302020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020424320202020202020202040412020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020525320202030202020202050512020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020131616
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016161615202020202020202020172020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202017202020202030131616352020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202033161616141616352020203020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020172020202020202020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020172020202020202020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020331616152020444540
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020172020545550
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030202020202020202020331616161616
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020484920202020302020202020202020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020585920202020202020202020202020
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202616161615204041202020202020
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
011400200077300000246052460500645000000077300000000000000000773000000064500000000000000000773000000000000000006450000000773000000000000000007730000000645000000000000000
011400200077300000246052460500645000000077300000000000000000773000000064500000000000000000773000000000000000006450000000773000000064500000007730000000665007730066500665
01140000025200252509510095150e5100e51510510105150e5100e5150951009515025100251509510095150b5200b52509510095150e5100e51509520095250b5050950509510095150e5100e5150951009515
012800001c5141c5101c5151e5141e5101e5101e5101e5151a5141a5101a51519514195101951019510195151c5001c5001c5001e5001e5001e5001e5001e5001750017500175001550015500155001550015500
012800201c5141c5101c5151e5141e5101e5101e5101e515175141751017515155141551015510155101551500700000000000000000006000000000700000000000000000007000000000600000000000000000
01140020287202a7212a7202a7202a7202a7202d7202d7202d7202d7202d7202d7202d7202d7202d7202d7252d7202f72132720327202f7202f7202d7202d7202d7202d7202d7202d7202d7202d7202d7202d725
011400002d7202f7212f7222f72232720327202d7202f7212f7202f7252d7202d7202d7222d7222d7222d722287222a7212a7202a7202d7202d7202872028720287202872228722287222872228711237111c711
01140000000000000000000000000000000000000000000000000000002172021720267202672028720287202a7212a7202d7202d7202a7202a72028721287202872028720287202872500000000000000000000
01140000000000000000000000000000000000000000000000000000001e7201e7201f7201f720217202172023721237202672026720237202372021721217202172021720217202172500000000000000000000
0114000007520075250b5200b5250e5200e52513520135250000000000000000000000000000000000000000065200652509520095250e5200e52512520125250000000000000000000000000000000000000000
01140000045200452507520075250b5200b52510520105250000000000000000000000000000000000000000065200652509520095250e5200e52512520125250000000000000000000000000000000000000000
0114000009520095250e5200e52510520105251552015525000000000000000000000000000000000000000009520095250d5200d525105201052515520155250000000000000000000000000000000000000000
011400001751417510175101751017510175101751017510175101751017510175101751017510175101751515514155101551015510155101551015510155101551015510155101551015510155101551015515
011400001351413510135101351013510135101351013510135101351013510135101351013510135101351512514125101251012510125101251012510125101251012510125101251012510125101251012515
01140000155141551015510155151a5101a5101a5101a5151c5101c5101c5101c5101c5101c5101c5101c51515514155101551015515195101951019510195151c5101c5101c5101c5101c5101c5101c5101c515
01140000237002370021700217001e7001c7001a7001a7002f7212f7202d7202d7202a72028720267202672000000000000000000000000000000000000180002a7212a72028720287202a7202a7202d7202d720
01140000000000000000000000000000000000327213272031720317202f7202d7202d7202b7202a7202a7202a7222a7222a7222a7252a7002a70000000000000000000000000000000000000000000000000000
011400002d70032700347003270021700267002d7003272131720317202f7202d7202d7202a7202872028720287202872028720287202872028720287202f7213472134722347223472234722347223472234725
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
00 00 02 43 44
00 01 02 43 44
01 00 02 03 05
00 00 02 04 06
00 00 02 03 07
00 00 02 04 08
00 00 02 03 07
00 01 02 04 08
00 00 09 0c 0f
00 00 0a 0d 10
00 00 09 0c 0f
02 01 0b 0e 11
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
