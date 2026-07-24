pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- picopolis 1.1
-- by jeb

local mapdim=48
local guih=3
local constructs={
 road={
  sprite=19,
  cost={2,0},
  onwater=true,
 },
 bulldoze={
  sprite=53,
  cost={2,5},
 },
 residental={
  sprite=8,
  cost={2,5},
  maxpop={1},
  eduq=.1,
  upgrades={
   {
    minpop={1},
    sprite=9,
    values={
     value=1,
     eduq=.1,
    },
    bints={
     maxpop={9},
    },
   },
   {
    minpop={8},
    sprite=10,
    bints={
     maxpop={1,0},
    },
    values={
     value=1.5,
     eduq=.2,
    }
   },
   {
    minpop={1,4},
    minvalue=4,
    sprite=11,
    school=true,
    bints={
     maxpop={3,5},
    },
    values={
     value=2,
     eduq=.3,
    }
   },
  },
 },
 industrial={
  sprite=24,
  cost={2,5},
  polution=-.5,
  income={0},
  maxlojobs={1},
  upgrades={
   {
    sprite=25,
    minunemploy={5},
    values={
     value=1,
     polution=-.5,
    },
    bints={
     maxlojobs={1,0},
     income={4},
    },
   },
   {
    sprite=26,
    minupdates=10,
    minunemploy={5},
    values={
     value=1,
     polution=-1,
    },
    bints={
     maxlojobs={8},
     maxhijobs={2},
     income={8},
    },
   },
   {
    sprite=27,
    minupdates=25,
    minunemploy={5},
    values={
     value=1,
     polution=-1.5,
    },
    bints={
     maxlojobs={1,2},
     maxhijobs={6},
     income={1,5},
    },
   },
  },  
 },
 commercial={
  sprite=12,
  cost={3,5},
  income={0},
  upgrades={
   {
    sprite=13,
    values={
     value=1,
    },
    bints={
     maxlojobs={5},
     maxhijobs={2},
     income={4},
    },
   },
   {
    sprite=14,
    minvalue=4,
    minupdates=10,
    values={
     value=2,
    },
    bints={
     maxlojobs={5},
     maxhijobs={7},
     income={6},
    },
   },
   {
    sprite=15,
    minvalue=5,
    minupdates=25,
    values={
     value=3,
    },
    bints={
     maxlojobs={4},
     maxhijobs={1,0},
     income={1,8},
    },
   },
  },
 },
 residental2={
  sprite=40,
  size=2,
  cost={5,0,0},
  eduq=.2,
  income={0},
  maxpop={1},
  upgrades={
   {
    minpop={1},
    sprite=42,
    school=true,
    values={
     value=2,
     eduq=.4,
    },
    bints={
     maxpop={3,9},
    },
   },
   {
    minpop={2,8},
    sprite=44,
    bints={
     maxpop={2,0,0},
    },
    values={
     value=2.5,
     eduq=.5,
    }
   },
   {
    minpop={1,8,4},
    minvalue=4,
    sprite=46,
    hospital=true,
    bints={
     maxpop={9,5,0},
    },
    values={
     value=3,
     eduq=.6,
    }
   },
  },
 },
 industrial2={
  sprite=72,
  cost={5,0,0},
  polution=-.5,
  income={0},
  maxlojobs={1},
  size=2,
  upgrades={
   {
    sprite=74,
    minunemploy={1,5},
    values={
     value=1,
     polution=-1.5,
    },
    bints={
     maxlojobs={3,0},
     income={4,0},
    },
   },
   {
    sprite=76,
    minupdates=25,
    minunemploy={1,5},
    values={
     value=1,
     polution=-3,
    },
    bints={
     maxlojobs={8,0},
     maxhijobs={2,0},
     income={8,0,0},
    },
   },
   {
    sprite=78,
    minupdates=75,
    minunemploy={1,5},
    values={
     value=1,
     polution=-4,
    },
    bints={
     maxlojobs={1,4,0,0},
     maxhijobs={6,0},
     income={1,5,0,0},
    },
   },
  },  
 },
 commercial2={
  sprite=104,
  cost={7,5,0},
  income={1},
  size=2,
  upgrades={
   {
    sprite=106,
    minvalue=3.5,
    minunemploy={1,5},
    values={
     value=2,
    },
    bints={
     maxlojobs={2,5},
     maxhijobs={2,0},
     income={4,0},
    },
   },
   {
    sprite=108,
    minvalue=6,
    minupdates=25,
    values={
     value=3,
    },
    bints={
     maxlojobs={1,0},
     maxhijobs={9,0},
     income={2,6,0},
    },
   },
   {
    sprite=110,
    minvalue=9,
    minupdates=75,
    values={
     value=4,
    },
    bints={
     maxlojobs={2,4,0},
     maxhijobs={1,2,5,0},
     income={2,8,0,0},
    },
   },
  },
 },
 mayor={
  sprite=6,
  size=2,
  value=10,
  maxhijobs={4},
  police=true,
  income={4},
 },
 park={
  sprite=28,
  cost={2,5},
  value=4,
  polution=.5,
 },
 police={
  sprite=29,
  cost={5,0,0},
  value=.5,
  police=true,
 },
 hospital={
  sprite=70,
  cost={1,5,0,0,0},
  value=4,
  size=2,
 },
 school={
  sprite=30,
  cost={2,5,0},
  value=1,
 },
 museum={
  sprite=192,
  size=2,
  cost={2,5,0,0,0},
  value=8,
  income={9,9},
 },
 tivoli={
  sprite=194,
  size=2,
  cost={5,0,0,0,0},
  value=8,
  income={4,9,9},
 },
 stadium={
  sprite=196,
  size=2,
  cost={1,5,0,0,0,0},
  value=8,
  income={2,4,9,9},
 },
 statue={
  sprite=198,
  size=2,
  cost={1,0,0,0,0,0,0,0},
  value=10,
 },
}

menus={
 construct={
  title="select construction",
  lines=0,
  options={
   {
    sprite=53,
    title="bulldoze $25",
    subtitle="destroy development",
    construct="bulldoze",
   },
   {
    sprite=19,
    title="road $20",
    subtitle="connects the city",
    construct="road",
   },
   {
    sprite=8,
    title="residental $25",
    subtitle="residental zone",
    construct="residental",
   },
   {
    sprite=24,
    title="industrial $25",
    subtitle="industrial zone",
    construct="industrial",
   },
   {
    sprite=12,
    title="commercial $35",
    subtitle="commercial zone",
    construct="commercial",
   },
   {
    sprite=8,
    title="l residental $500",
    subtitle="2x2 residental",
    construct="residental2",
   },
   {
    sprite=24,
    title="l industrial $500",
    subtitle="2x2 industrial",
    construct="industrial2",
   },
   {
    sprite=12,
    title="l commercial $750",
    subtitle="2x2 commercial",
    construct="commercial2",
   },
   {
    sprite=20,
    title="more options...",
    subtitle="list next page",
    construct="next page",
   },
  },
  onselect=function()
   construct=menus.construct.options[menuoption].construct
   if construct=="next page" then
    construct=nil
    return "construct2"
   end
   return nil
  end,
 },
 construct2={
  title="select construction",
  lines=0,
  options={
   {
    sprite=29,
    title="police $500",
    subtitle="police department",
    construct="police",
   },
   {
    sprite=30,
    title="school $250",
    subtitle="elementary school",
    construct="school",
   },
   {
    sprite=70,
    title="hospital $15,000",
    subtitle="regional hospital",
    construct="hospital",
   },
   {
    sprite=28,
    title="park $25",
    subtitle="recreational area",
    construct="park",
   },
   {
    sprite=192,
    title="museum $25,000",
    subtitle="city museum",
    construct="museum",
   },
   {
    sprite=194,
    title="tivoli $50,000",
    subtitle="amusement park",
    construct="tivoli",
   },
   {
    sprite=196,
    title="stadium $150,000",
    subtitle="sports stadium",
    construct="stadium",
   },
   {
    sprite=198,
    title="statue $10,000,000",
    subtitle="victory monument",
    construct="statue",
   },
  },
  onselect=function()
   construct=menus.construct2.options[menuoption].construct
   return nil
  end,
 }, 
 mayor={
  title="mayor information",
  lines=4,
  options={
   {
    sprite=64,
    title="land value",
    subtitle="display land value",
    data="value",
   },
   {
    sprite=65,
    title="polution",
    subtitle="display polution",
    data="polution",
   },
   {
    sprite=97,
    title="crime",
    subtitle="display crime",
    data="crime",
   },
  },
  getline=function(l)
   if l==1 then
    return "population: "..binttostr(population)
   elseif l==2 then
    return "hi: "..binttostr(hijobs).." / "..binttostr(maxhijobs)
   elseif l==3 then
    return "lo: "..binttostr(lojobs).." / "..binttostr(maxlojobs)
   elseif l==4 then
    local ue=bintsub(bintsub(population,hijobs),lojobs)
    return "unemployed: "..binttostr(ue)
   end
   return "test"
  end,
  onselect=function()
   datadisplay=menus.mayor.options[menuoption].data
   return nil
  end,
 },
 residental={
  title="residental information",
  lines=4,
  options={},
  getline=function(l)
   if l==1 then
     return "residents: "..binttostr(selected.pop or {0}).." / "..binttostr(selected.maxpop or {0})
   elseif l==2 then
     return "hi income: "..binttostr(selected.hijobs or {0})
   elseif l==3 then
     return "lo income: "..binttostr(selected.lojobs or {0})
   elseif l==4 then
     return "unemployed: "..binttostr(selected.unemployed or {0})
   end
  end,
 },
 industrial={
  title="industrial information",
  lines=3,
  options={
   {
    sprite=65,
    title="polution",
    subtitle="display polution",
    data="polution",
   },
  },
  getline=function(l)
   if l==1 then
    return "income: "..binttostr(selected.income or {0})
   elseif l==2 then
    return "lo jobs: "..binttostr(selected.maxlojobs or {0})
   elseif l==3 then
    return "hi jobs: "..binttostr(selected.maxhijobs or {0})
   end
  end,
  onselect=function()
   datadisplay=menus.industrial.options[menuoption].data
   return nil
  end,
 },
 commercial={
  title="commercial information",
  lines=3,
  options={
   {
    sprite=64,
    title="land value",
    subtitle="display land value",
    data="value",
   },
  },
  getline=function(l)
   if l==1 then
    return "income: "..binttostr(selected.income or {0})
   elseif l==2 then
    return "lo jobs: "..binttostr(selected.maxlojobs or {0})
   elseif l==3 then
    return "hi jobs: "..binttostr(selected.maxhijobs or {0})
   end
  end,
  onselect=function()
   datadisplay=menus.commercial.options[menuoption].data
   return nil
  end,
 },
 police={
  title="police station",
  lines=0,
  options={
   {
    sprite=97,
    title="crime",
    subtitle="display crime",
    data="crime",
   },
  },
  getline=function(l)
   return "test"
  end,
  onselect=function()
   datadisplay=menus.police.options[menuoption].data
   return nil
  end,
 },
 statue={
  title="victory monument",
  lines=1,
  options={},
  getline=function(l)
   if l==1 then
     return "established: "..datestr(selected.est[1],selected.est[2])
   end
  end,
 },
}
menus.residental2=menus.residental
menus.industrial2=menus.industrial
menus.commercial2=menus.commercial

function _init()
 curx,cury=0,0
 tickanim=0
 ticker=nil
 tickercol=7
 buildings={}
 popups={}
 selected=nil
 construct=nil
 constructcost=nil
 money={5,0,0}
 year,month,monthticks=2017,1,30*15
 population={1}
 lojobs={0}
 maxlojobs={0}
 hijobs={1}
 maxhijobs={1}
 menu=nil
 menuoption=2
 mapdata={
  value={},
  polution={},
  crime={},
 }
 datadisplay=nil
 palt(0,false)
 
 while true do
  local tx,ty=flr(rnd(mapdim)),flr(rnd(mapdim))
  local free=true
  for y=-1,2 do
   for x=-1,2 do
    if not mapfree(tx+x,ty+y) then
     free=false
     break
    end
   end
  end
	 if free then
   curx,cury=tx,ty
   placeroad(tx,ty+2)
   placeroad(tx+1,ty+2)
   placebuilding(tx,ty,"mayor")
   break
	 end
 end

 for k,v in pairs(mapdata) do
  for x=0,mapdim-1 do
   mapdata[k][x]={}
   for y=0,mapdim-1 do
    mapdata[k][x][y]=0
   end
  end
 end

 _update=titleupdate
end

function gameupdate()
 tickanim+=1
 if tickanim > 10*30 then
  tickanim=0
 end

 --if not menu then
  updatepopups()
  
  local tx,ty=flr(rnd(mapdim)),flr(rnd(mapdim))
  updatepolution(tx,ty)
  updatelandvalue(tx,ty)
  local b=getbuilding(tx,ty)
  if b then
   if not b.police then 
    updatecrime(tx,ty)
   end
   if rnd(12)<-mapdata.crime[tx][ty] then
    addpopup(tx*8,ty*8,"\x82",8)
    sfx(5)
   else
    updatebuilding(b)
   end
  end
  monthticks-=1
  if monthticks==0 then
   month+=1
   if month>12 then
    month=1
    year+=1
   end
   monthticks=30*15
  end

 --end
 --money=bintadd(money,{1,1,2,3,0,1,1})
 --ticker+=1
 if btnp(5) then
  menu=nil
  datadisplay=nil
  construct=nil
  constructcost=nil
 end

 --if btnp(5,1) and selected then
 -- updatelandvalue(selected.x,selected.y)
 -- updatebuilding(selected)
 --end
 
 if not menu then
	 local ox,oy=curx,cury 
	 local ot=ticker
	 if btnp(0) then curx=max(0,curx-1) end
	 if btnp(1) then curx=min(mapdim-1,curx+1) end
	 if btnp(2) then cury=max(0,cury-1) end
	 if btnp(3) then cury=min(mapdim-1,cury+1) end
	 if not construct then
		 local b=getbuilding(curx,cury)
		 if b~=selected or (selected==nil and (ox~=curx or oy~=cury)) then
		  selected=b
		  if b then
		   ticker=b.t
		  elseif mapwater(curx,cury) then
		   ticker="water"
		  elseif maproad(curx,cury) then
		   ticker="road"
		  elseif mapforest(curx,cury) then
		   ticker="forest"
		  elseif maprocks(curx,cury) then
		   ticker="mountains"
		  else
		   ticker=""
		  end
		 end
		 if btnp(4) then
		  if b then
		   menu=menus[b.t]
		  else
		   menu=menus.construct
		  end
		  menuoption=1
		 end
		elseif construct then
		 constructcost=getconstructcost()
		 if not constructcost then
		  ticker="can't place here"
		 elseif not findroad(construct~="road") and construct~="bulldoze" then
		  ticker="no adjacent road"
		  constructcost=nil
		 elseif btnp(4) then
		  if bintless(money,constructcost) then
  		 addpopup(curx*8,cury*8,"no funds",8)
		  else
		   money=bintsub(money,constructcost)
		   if construct=="road" then
		   	placeroad(curx,cury)
      sfx(2)
		   elseif construct=="bulldoze" then
      bulldoze(curx,cury)
      sfx(3)
     else
		    placebuilding(curx,cury,construct)
      sfx(2)
		   end
		   addpopup(curx*8,cury*8,"-$"..binttostr(constructcost),2)
		  end
		 else
		  ticker="place "..construct.." ($"..binttostr(constructcost)..")"
		 end
		end
	 
	 if ot~=ticker then
	  tickanim=0
	 end
	else
	 if btnp(5) then
	  menu=nil
	 elseif btnp(4) and menu.onselect then
   sfx(1)
	  local nextmenu = menu.onselect()
    if nextmenu then
     menu=menus[nextmenu]
     menuoption=1
    else
     menu=nil
    end
	 elseif btnp(2) then
	  menuoption=menuoption-1
   if menuoption==0 then menuoption=#menu.options end
   sfx(0)
	 elseif btnp(3) then
	  menuoption=menuoption+1
   if menuoption>#menu.options then menuoption=1 end
   sfx(0)
	 end	 
	end
end

function gamedraw()

 if menu or datadisplay then
  pal(1,5)
  pal(2,5)
  pal(3,5)
  pal(4,5)
  pal(5,5)
  pal(8,6)
  pal(9,5)
  pal(10,6)
  pal(11,6)
  pal(12,6)
  pal(13,6)
  pal(14,6)
  pal(15,6)
 end

 local mapx=max(0,min(mapdim-16,curx-7))
 local mapy=max(0,min(mapdim-16+guih,cury-7))
 map(mapx,mapy,0,0,16,16-guih)
 drawpopups(mapx,mapy)
 
 if datadisplay then
  palt(14,true)
  local a=mapdata[datadisplay] or {}
  for y=mapy,mapy+12 do
   for x=mapx,mapx+15 do
    a[x] = a[x] or {}
    local v=a[x][y] or -10+rnd(20)
    if v>0.1 or v<-.1 then
     if v<-9 then
      pal(7,8)
	    elseif v<-7 then
	     pal(7,4)
	    elseif v<-4 then
	     pal(7,9)
	    elseif v<0 then
	     pal(7,10)
	    elseif v<4 then
	     pal(7,13)
	    elseif v<7 then
	     pal(7,3)
     elseif v<9 then
      pal(7,11)
	    else
	     pal(7,7)
	    end
	    spr(20,(x-mapx)*8,(y-mapy)*8)
	   end
   end
  end
  pal()
  palt(0,false)
 end

 palt(14,true)
 do
  local b=getbuilding(curx,cury)
  if b and b.size==2 then
   spr(38,(b.x-mapx)*8,(b.y-mapy)*8,2,2)
	 else
   spr(37,(curx-mapx)*8,(cury-mapy)*8)
  end
 end
 palt(14,false)
 
 map(64,0,0,(16-guih)*8,16,3)
 print(binttostr(money),8,106,7)
 print(binttostr(population),8,114,7)
 print(datestr(month,year),80,114,7)
 if ticker then
  print(ticker,max(0+min(0,128-(#ticker)*4),128-tickanim),122,tickercol)
 end
 
 pal()
 palt(0,false)
 if menu then
	 palt(14,true)
	 map(65,3,8,8,14,14)
	 sprint(menu.title,16,16)
	 local y=24
	 if menu.lines>0 then
	  for i=1,menu.lines do
	   sprint(menu.getline(i),24,y+2,12)
	   y+=8
	  end
	 end
	 for i=1,#menu.options do
	  local o=menu.options[i]
	  if i==menuoption then
	   map(66,17,16,y,12,3)
	   spr(o.sprite,24,y+4)
	   sprint(o.title,34,y+6,7)
	   print(o.subtitle,34,y+14,0)
	   y+=24
	  else
	   print(o.title,24,y+2,0)
	   y+=8
	  end
	 end
	elseif construct and (flr(tickanim/2)%6)>0 then
  local c=constructs[construct]
  palt(14,true)
  if not constructcost and (flr(tickanim/2)%3)>0 then
   for i=0,15 do
    pal(i,8)
   end
  end
  spr(c.sprite,(curx-mapx)*8,(cury-mapy)*8,c.size or 1,c.size or 1)
  pal()
  palt(0,false)
	end
end

function sprint(text,x,y,clr)
 print(text,x+1,y+1,0)
 print(text,x+1,y,0)
 print(text,x,y+1,0)
 print(text,x,y,clr or 7)
end

local months={"jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"}
function datestr(month,year)
 return months[month].." "..year
end

function mapfree(x,y)
 if x<0 or y<0 or x>=mapdim or y>=mapdim then
  return false
 end
 return fget(mget(x,y),0)
end

function mapwater(x,y)
 return mget(x,y)==4
end

function maproad(x,y)
 return fget(mget(x,y),1)
end

function mapforest(x,y)
 return mget(x,y)==2
end

function maprocks(x,y)
 return mget(x,y)==3
end

function placebuilding(x,y,t)
 local data=constructs[t]
 local size=data.size or 1
 local sprite=data.sprite
 for sx=0,size-1 do
  for sy=0,size-1 do
   mset(x+sx,y+sy,(sprite+sx)+sy*16)
  end
 end
 local b={
  t=t,
  x=x,
  y=y,
  size=size,
  value=data.value,
  polution=data.polution,
  maxpop=data.maxpop,
  eduq=data.eduq,
  updates=0,
  police=data.police,
  maxlojobs=data.maxlojobs,
  maxhijobs=data.maxhijobs,
  income=data.income,
  est={month,year},
 }
 maxlojobs=bintadd(maxlojobs,data.maxlojobs or {0})
 maxhijobs=bintadd(maxhijobs,data.maxhijobs or {0})
 add(buildings,b)
end

function bulldoze(x,y)
 local b=getbuilding(x,y)
 local newsprite=1
 if b then
  del(buildings,b)
  maxhijobs=bintsub(maxhijobs,b.maxhijobs or {0})
  maxlojobs=bintsub(maxlojobs,b.maxlojobs or {0})
  population=bintsub(population,b.pop or {0})
  if b.size==2 then
   bulldoze(b.x,b.y)
   bulldoze(b.x+1,b.y)
   bulldoze(b.x+1,b.y+1)
   bulldoze(b.x,b.y+1)
   return
  end
 elseif fget(mget(x,y),2) then
   newsprite=4
 end
 mset(x,y,newsprite)
 for k,v in pairs(mapdata) do
  v[x][y]=0
 end
end

function placeroad(x,y)
 if not mapfree(x,y) and not mapwater(x,y) and not mapforest(x,y) then
  return
 end
 if mapwater(x,y) then
  if maproad(x+1,y) or maproad(x-1,y) then
   mset(x,y,50)
  else
   mset(x,y,49)
  end
 else
  mset(x,y,19)
 end
 updateroad(x,y)
 updateroad(x+1,y)
 updateroad(x,y+1)
 updateroad(x-1,y)
 updateroad(x,y-1)
end

function updateroad(x,y)
 if not maproad(x,y) or fget(mget(x,y),2) then
  return
 end
 local e,w,n,s=
  fget(mget(x+1,y),1) and 1 or 0,
  fget(mget(x-1,y),1) and 1 or 0,
  fget(mget(x,y-1),1) and 1 or 0,
  fget(mget(x,y+1),1) and 1 or 0
 local r=19
 if e+w+n+s <= 2 then
  if e+w>0 and n+s==0 then
   r=18
  elseif e+w==0 and n+s>0 then
   r=17
  elseif e+n==2 then
   r=33
  elseif w+n==2 then
   r=34
  elseif e+s==2 then
   r=35
  elseif w+s==2 then
   r=36
  end
 end
 mset(x,y,r)
end

function findroad(wide)
 if maproad(curx-1,cury) or maproad(curx+1,cury) or maproad(curx,cury-1) or maproad(curx,cury+1) then
  return true
 end
 return wide and (maproad(curx-2,cury) or maproad(curx+2,cury) or maproad(curx,cury-2) or maproad(curx,cury+2))
end

function getconstructcost()
 if construct=="bulldoze" then
  if maproad(curx,cury) or getbuilding(curx,cury) then
   return constructs[construct].cost
  end
  return nil
 end
 local c=constructs[construct]
 local onwater=c.onwater
 local base=c.cost
 local size=c.size or 1
 for y=cury,(cury-1+size) do
  for x=curx,(curx-1+size) do
   if maproad(x,y) or maprocks(x,y) or getbuilding(x,y) then
    return nil
   end
   
   if mapwater(x,y) then
    if onwater then
     base=bintadd(base,{1,5,0})
    else
     return nil
    end
   end
   if mapforest(x,y) then
    base=bintadd(base,{7,5})
   end
  end
 end
 return base
end

function getbuilding(x,y)
 if not fget(mget(x,y),7) then
  return nil
 end
 for b in all(buildings) do
  if b.x==x and b.y==y then
   return b
  end
  if b.size==2 and ((b.x==x-1 and b.y==y) or (b.x==x-1 and b.y==y-1) or (b.x==x and b.y==y-1)) then
   return b
  end
 end
 return nil
end

function getmapdata(data,x,y)
 if x<0 or y<0 or x>=mapdim or y>=mapdim then
  return 0
 end
 return mapdata[data][x][y] or 0
end

function setmapdata(data,x,y,v)
 if x<0 or y<0 or x>=mapdim or y>=mapdim then
  return
 end
 mapdata[data][x][y]=v
end

function updatebuilding(b)
 local s=(b.size or 0) * 2
 b.updates+=1
 
 local income={1}
 if b.maxpop then
  local p=b.pop or {0}
  local employmentcount={0}
  while bintless(p,b.maxpop) and (bintless(employmentcount,bintadd(bintsub(maxlojobs,lojobs),bintsub(maxhijobs,hijobs))) or rnd(1)>.90) do
   p=bintadd(p,{1})
   population=bintadd(population,{1})
   b.unemployed=b.unemployed or {0}
   b.unemployed=bintadd(b.unemployed,{1})

   employmentcount=bintadd(employmentcount,{5,0})
  end
  b.pop=p
  --income=bintadd(income,p)
 end

 if b.unemployed and b.eduq then
  while (bintless({0},b.unemployed) and rnd(1)>.2) or bintless({10},b.unemployed) do
   if rnd(1)<b.eduq and bintless(hijobs,maxhijobs) then
    b.unemployed=bintsub(b.unemployed,{1})
    b.hijobs=bintadd(b.hijobs or {0},{1})
    hijobs=bintadd(hijobs,{1})
   elseif bintless(lojobs,maxlojobs) then
    b.unemployed=bintsub(b.unemployed,{1})
    b.lojobs=bintadd(b.lojobs or {0},{1})
    lojobs=bintadd(lojobs,{1})
   else
    break
   end
  end
 end

 if b.hijobs then
  for i=1,3 do
   income=bintadd(income,b.hijobs)
  end
 end
 if b.lojobs then
  income=bintadd(income,b.lojobs)
 end
 income=bintadd(income,b.income or {0})
 local level=b.level or 0
 local upgrades=constructs[b.t].upgrades
 if upgrades and #upgrades>level then
  local nl=upgrades[level+1]
  local levelup=true
  if nl.minpop and bintless(b.pop,nl.minpop) then
   levelup=false
  elseif nl.minupdates and b.updates<nl.minupdates then
   levelup=false
  elseif nl.minvalue and getmapdata("value",b.x,b.y)<nl.minvalue then
   levelup=false
  elseif nl.minunemploy and bintless(bintsub(bintsub(population,lojobs),hijobs),nl.minunemploy) then
   levelup=false
  elseif nl.school and not buildingwithin("school",b.x,b.y,12) then
   levelup=false
  elseif nl.hospital and not buildingwithin("hospital",b.x,b.y,20) then
   levelup=false
  end
  if levelup then
   b.level=level+1
   mset(b.x,b.y,nl.sprite)
   if b.size==2 then
    mset(b.x+1,b.y,nl.sprite+1)
    mset(b.x,b.y+1,nl.sprite+16)
    mset(b.x+1,b.y+1,nl.sprite+17)
   end
   for k,v in pairs(nl.values) do
    b[k]=v
   end
   for k,v in pairs(nl.bints) do
    b[k]=bintadd(b[k] or {0},v)
   end
   maxlojobs=bintadd(maxlojobs,nl.bints.maxlojobs or {0})
   maxhijobs=bintadd(maxhijobs,nl.bints.maxhijobs or {0})
  end
 end
 
 if bintless({0},income) then
  addpopup(b.x*8+s,b.y*8+s,"+$"..binttostr(income),9)
  money=bintadd(money,income)
  if bintless(money,{1,0,0,0,0}) or rnd(1)<.1 then
   sfx(4)
  end
 end

 if b.police then
  updatepolice(b)
 end
end

function buildingwithin(btype,x,y,req)
 for b in all(buildings) do
  if b.t==btype then
   if abs(b.x-x)+abs(b.y-y)<=req then
    return true
   end
  end
 end
 return false
end

function recursiveroad(roads,x,y,depth)
 if not maproad(x,y) then
  return
 end
 local index=x+y*mapdim
 if roads[index] and roads[index]>=depth then
  return
 end
 roads[index]=depth
 if depth>1 then
  recursiveroad(roads,x-1,y,depth-1)
  recursiveroad(roads,x+1,y,depth-1)
  recursiveroad(roads,x,y-1,depth-1)
  recursiveroad(roads,x,y+1,depth-1)
 end
end

function updatepolice(b)
 local roads={}
 local openroads={}
 local size=b.size or 1

 local range=10
 for y=-1,size do
  for x=-1,size do
   local tx,ty=x+b.x,y+b.y
   recursiveroad(roads,tx,ty,range)
  end
 end
 for k,v in pairs(roads) do
  local rx=k%mapdim
  local ry=flr(k/mapdim)
  for y=-2,2 do
   for x=-2,2 do
    setmapdata("crime",rx+x,ry+y,0)
   end
  end
 end

end

function updatelandvalue(x,y)
 local d="value"
 local n=getmapdata(d,x-1,y)+getmapdata(d,x+1,y)+getmapdata(d,x,y-1)+getmapdata(d,x,y+1)
 local r=n/4
 
 local b=getbuilding(x,y)
 if b then
  r+=(b.value or 0)
 end
 r+=getmapdata("polution",x,y)
 r=max(-10,min(10,r))
 mapdata.value[x][y]=r
 --addpopup(x*8,y*8,""..r,12)
end

function updatepolution(x,y)
 local d="polution"
 local n=getmapdata(d,x-1,y)*2+getmapdata(d,x,y-1)+getmapdata(d,x,y+1)
 local r=n/4
 
 r+=getmapdata(d,x,y)
 local target=0
 local b=getbuilding(x,y)
 if b then
  target=b.polution or 0
 elseif mapforest(x,y) then
  target=.5
 elseif maproad(x,y) then
  target=-.1
 end
 r+=(target-r)*.5
 r=max(-10,min(0,r))
 mapdata.polution[x][y]=r
 --addpopup(x*8,y*8,""..r,4)
end

function updatecrime(x,y)
 local r=getmapdata("crime",x-1,y)+
  getmapdata("crime",x+1,y)+
  getmapdata("crime",x,y-1)+
  getmapdata("crime",x,y+1)
 mapdata.crime[x][y]=max(-10,mapdata.crime[x][y]+r*.3-.05)
end

function addpopup(x,y,text,col)
 add(popups,{text=text,col=col,life=90,x=x,y=y})
end

function updatepopups()
 for pp in all(popups) do
  pp.life-=1
  if pp.life<=0 then
   del(popups,pp)
  else
   pp.y-=.004*pp.life
  end
 end
end

function drawpopups(mx,my)
 for pp in all(popups) do
  sprint(pp.text,pp.x-mx*8,pp.y-my*8,pp.col)
 end
end

function bintequals(a,b)
 if #b==#a then
  for i=1,#a do
   if a[i]~=b[i] then
   	return false
   end
  end
  return true
 end
 return false
end

function bintless(a,b)
 if #a<#b then
  return true
 end
 if #a>#b then
  return false
 end
 for i=1,#a do
  if a[i]<b[i] then
  	return true
  elseif a[i]>b[i] then
   return false
  end
 end
 return false
end

function bintadd(a,b)
 local r={}
 if #b>#a then
  local c=a
  a=b
  b=c
 end
 local t=0
 for i=1,#a do
  local n=a[#a+1-i]
  if i<=#b then
   n+=b[#b+1-i]
  end
  n+=t
  add(r,n%10)
  t=flr(n/10)
 end
 if t>0 then
  add(r,t)
 end
 local r2={}
 for i=1,#r do
  r2[#r-i+1]=r[i]
 end
 return r2
end

function bintsub(a,b)
 if bintless(a,b) then
  return {0} --cant handle negatives
 end
 local r={}
 for i=1,#a do
  add(r,a[i])
 end
 for i=1,#b do
  local c=b[#b+1-i]
  for j=i,#r do
   local c2=r[#r+1-j]-c
   if c2<0 then
    c=1
    r[#r+1-j]=c2+10
   else
    r[#r+1-j]=c2
    break
   end   
  end
 end
 local r2={}
 for i=1,#r do
  if #r2>0 or r[i]>0 then
   add(r2,r[i])
  end
 end
 return r2
end

function binttostr(bint)
 local r=""
 if #bint<=5 then
	 for i=1,#bint do
	  r=r..bint[i]
	  if i==#bint-3 then
	   r=r..","
	  end
	 end
	elseif #bint<=8 then
	 for i=1,#bint-3 do
	  r=r..bint[i]
	 end
	 r=r.."."..bint[#bint-2].."k"
	else
	 for i=1,#bint-6 do
	  r=r..bint[i]
	 end
	 r=r.."."..bint[#bint-5].."m"
	end
 return r
end



local titleimage="dddddddddddddddddddddddddddddddddddddddddd7777777777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddcdddcdddcdddcdddcddd77777777777777cdddcdddcdddcdddcdddcdddcdddcdddcdcdddcdddcdddcdddcdddcdddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777777777777777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddcdddddcdddcdddcdddcddd777777777777777777cdc77dddcdcdcdddcdcdcdddcdcdcdddddcdddcdddcdddcdddcdddcdcdddddddddddddddddddddddddddddddddddddddddddddddddddd7777777777777777777dd7777ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddcdddcdcdddcd7dddcdcdcdddcdcd777777777777777777777777777dddcdcdcdddcdcdcdddcdcdcdcdcdcdddcdcdcdddcdcdcdddddcdcdddcddddddddddddd7777777777ddd77777ddddddd77777777777777777777777777777777dd7777dddddddddddddddddddddd7777777dddddddddddddddddddddddddddddddd77c7777777777777c77777777777777777777777777777777777777777777dcd7777cdcdcdcdcdcdcdcdcd77777777777dcdcdddcdcdcdcdcdddcdddddcdddcddddddddddddd77777777777ddddd777777ddddddddddddd7777777777ddddddddddddddddd77777dddddd7777777777777777ddddddddddddddddddddd77777dcdddddcdcdcdcdddcd77cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd7777777777cdcd777777777777777777cdcdcdcdddcdcdd7777777777ddddddddddddddddddddddddddddddddddddddddddcdddcdddcdddcdddcdddcdddcd7dcdddcdddcddd7d777777777777777777777777ddddddd7777777777777dcdcdcdddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc7777777777777777777777777777777777777777ddddddddddddddddddddddcdddcdddcdddcdddcdddddcdddcdddcdddcdddcdddcdddcdddcdd7cdddcdddcdcdddcdddcdddcdddcdddcddddddddddddddddddddddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcddddddddddddddddcdddcdcdddcdddcdddcdddcdddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdddcdddcdddcdddcdddcdddcdcdddcddddddddddddddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcddddddcdddcdddddcdddcdcdcdcdcdcdcdcdcdcdcdcdcdddcdcdcdddcdcdcdddcdcdcdddcdcdcdddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdddcdddddcddddddddddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcddcdddddcdddcdcdcdcdcdddcdcdcdddcdcdcdddcdcdcdcdcdc777cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdddcdcdcdddcdcdcdddcdcdcdcdcdcdcdddcdcdddcddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd77cdcccdcdcdc7777777cccdcdcdcccdcdcdcccdcdcdcccdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdccdddcdcdcdcdcdddcdcdcdcdcdcdcdcdc7777777cdcdcdcdc777777777cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdddcdcdcdcdcdddcddddcdcdcdcdcdcdcdcdcdcdcdcdccc777777777777dcdcccdcd7777777777cccdcdcdcccdcdcdcccdcdcdcccdcdcccdcdc9cccdcdcdcccdcdcdcdcdcdcdcdcdcdccdcdcdddcdcdcdcdcdcdcdcdcd7777777777777777777dc7cdcdcd77777777cdcdcdc7cdcdcdcdcdcdcdcdcdcdcdc9c9c9c9c9cdcdcdcdcdcdcdcdddcdcdcdcddcdcdcdcdcdcdcdcdcccccd777777777777777777777777cdcccdcccdcccdccc7cccdcccdcccdcccdcccdcdcdcdccc9c9c9c9cdcdcdcccdcdcccdcdcdcdcdcdccdcdcdcdcdcdcdcdcdcd7dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd777dcdcdc9c9c99999c9c9cdcdcdcdcdcdcdcdcdcdcddddcdcdcdcdcccdcdc7cdcdcccdcccdcccdcccdcccdcdcccdcccdcccdcccdcccdcccdcccdcccdcccdcc77777ccdccc9c99aaaa9c9cdc7cdcdcdcdcdcdcdcdcdcdccdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc7777777cdc777777dcdcdc9c99aaaaaa9c97777cdcdcdcdcdcdcdcdcdcdd77cdcdcdcdcccccdcccccdcccdcccdcccdcccdccccccccccccccccccccccccccccc7777777777777777ccdccc9c99aaaaaaaa7777777cccdcccccdcdcccdcdc7777cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc7777777777777777777cdcdcdc9c9aaaaaaaa77777777777dcdcdcdcdcdcdcd77777777dcccdcdcccdcccccccccccccccccccccccccccccccccccccccccc77c77777777777777777777cccccccc99aaaaaaa7777777777777dcdcccdcdcccdc777777777dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcccdcccdcccdcccdc7cdcccdcccdcccdcccdcccdc77dcd7dc9c9aaaaaa777777777777777dcdcdcdcdcdc77777777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77cccc9c9c9aaaa77777777777777777ccdcccc777777777777777777777cdc777cccdcccdcccdcccdcccccdcdcdcccdcdcdcccdcdcdcccdcdcdcccdcdcdcccdcdc7cdc9c9c9a77777777777777777777dcdcd777777ccdccccccccccccccccc777ccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccc777777777777777777777777777777777777cdcdcdcdcdcdcdcccdcdcdcdcccdcdcdcccdcdcdcccccdcccccccdcccccccdcccccccdcccccccdcccccccdcdc77777777777777777777777777777777dcdcdcdcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdcdcdcccdcccdcdcccccdcccccccdcccccccdcccccdcccdcccdcccdcccdcccdcccdcccdcccdcccdcccdcccccccccdcccccccdcccccccdcdcccccdcccdcdcdcdccccccccccccccccccccccccccccccccccccccccccccccccccccc5cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdcccdcdcccdcdcccccdcccdcccdcccdcccdcccdccccccccccccc5cccccccccccccccccccccccccccccccccdcccdcccdcccdcccdcccdcccccccdcdcdcdcccdcccccccccccccccccccccccccccccccccccccccccccccccccccccc55cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdcdcccccccccdcccccccccccccccccccccccccccccc5cccc5555ccccccccccccc55cccccccccccccccccccccccccccccccccccccccccdcccccdcccccdcdcdcccccccccccccccccccccccccccccccccccccccccccccc5ccc556565cccccccccccc55cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdcccdcccccccccccccccccccccccccccccccccc5ccc565116ccccccccccc5555ccccccccccccccccccccccccccccccccccccccccccccdcccdcccccdccccccccccccccccccccccccccccccccccccccccccccc1cc515c556565ccc1ccc1c55566666cc1ccc1ccc1cccccccccccccccccccccccccccccccccccccccc777ccccdcccccccccccccccccccccccccccccccccccccccccc5c5c565116ccccccccc55566666cccccccccccccccccccccccccccccccccccccccccccccccc77777777cccccccccccccccccc1ccc1ccc1ccc1ccc1ccc1c1ccc55555556565c1ccc1ccc555555551ccc1ccc1ccc1c1ccc1ccc1ccc1ccc1ccc1ccccccc7cccccccccccc77777ccccccccc7cccccccccccccccccccccccccccccc55115565116ccccccccc55565656ccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777c7cccccc1ccccc1ccc1ccc1ccc1ccc15cc1c1c555555565656666c1c1c555555551c1c1c1c1c1c1ccc1ccc1ccc1ccc1ccc1ccc1c1cccccccccccccccccccccccccccccccccccccccccccccccccccccc5cccccc551155651166116ccccc55565656cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccc1c1ccc1c1c1c1c1c1c1c1c1c1c151c1ccc555555565656666c1c1c555555551ccc1c1c1ccc1c1c1c1c1c1c1c1c1c1c1c1c1ccc1c1ccc1cccccccccccccccccccccccccccccccccccccccccccc5c5ccc1cc551155651166116ccccc55565656c1ccccccc1cccccccccccccccccccccccccccccccccccccccccccccccc1c1ccc1ccc1c1c1ccc1c1c1ccc15556666666c1c1c555555565656666c1c1c555555551c1c1c1c1c1c1c1c1ccc1c1c1ccc1c1c1ccc1c1c1ccc1ccccc1ccc1cccccccccccccccccccccccccc1ccc5556666666ccccc551155651166116ccccc55565656ccccccccccccccccc1ccccccc1ccccccc1cccccccccccccccccccccc1ccc1c1c1c1c1c1c1c1c1c1c1c1c15656767676c1c1c555555565656666c1c1c555555551c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1ccc1cccccccccccccccccccc1ccccccccccc5656767676cc1cc551155651166116cc1cc55565656c1ccc1ccc1ccccccccccccccccccccccccccccccc1cccccccccccccc1c1c1c1c1ccc1c1c1c1c1c1c1c1c15556666666c1c1c555555565656666c1c1c555555551c1c1c1c1c1c1c1c1c1c1c1c1c1c151c1c1c1c1c1ccc1c1c1c1c1c1cccccccccc1ccccccccccc1ccc1ccc5556666666cccc15511556511661164444444565656ccc1ccc1ccc1c1ccc1ccc1ccc1ccc5ccc1cccccccccccccccccccccc1ccc1c1c1c1c1c1c1c1c1c1c1c1c15656767676c1c1c55555556565666655666666665551c1c1c1c1c1c1c1c556565651c1c151c1c1c1c1c1c1c1c1c1ccc1c1cc1ccccccccccc1ccc1c1ccc1ccc1c56567676761c1c15511556511661165566999966656c1c1c1c1c1c1ccc155565656ccc1c5c1ccc1c1ccc1ccccccc1cccccc1c1c1c1c1c1c1c1c1c1c1c1c1c1c15556666666c1c1c5555555656566665566666666555556666666c1c1c1c252525251c1c15151c1c1c1c1c1c1c1c1c1c1c1cccccc1ccc1ccccc1ccc1c1c1c1c1c555666666665656551155651166116d5dddddddd6555566666661c1c1c155565656c1c1c5c5c1c1ccc1ccccc1cccccccccc1c1c1c1c1c1c5c1c1c1c1c1c1c1c15656767676565655555555656566665566666666555556666666c1c1c1c252525251c1c555555555c1c1c1c1c1c1c1c1c1cc1ccccc1ccc151c5c1c1c1c1c1c1c565676767665656551155651166116d5dddddddd6555566666661c1c1c155565656c15565656565656561c1ccc1c1ccc1cc1c1c1c1c1c1c5c151c1c1c1c1c1c1555666666656565555555565656666556666666655525626262611c1c1c252525251c555116115116115c1c1c1c1c1c1c11ccc1c1c1c1c556565651c1c5c1c1c555666666665656551155651166116d5dddddddd6555566666661c1c1c155565656c15565656565656561c1c1c1ccc1cccc1c1c1c1c1c155565656c1115111c15656767676565655555555656566665566666666555256262626c11111c2525252511555116115116115c1c1c1c1c1c1c11c1c1c1c1c1c556565651c1c5c1c1c565676767665656551155651166116d5dddddddd6555566666661c1c1c155565656c15565656565656561c1c1c1c1c1c1cc1c1c1c1c1c15556565611c151c51155566666665656555555556565666655666666665552562626261111c11252525251c55511611511611511c1c1c1c1c1c11c1c1c1c1c1c556565651c1c5c151c555666666665656551155651166116d5dddddddd6555566666661c1c1c155565656c15565656565656561c1c1c1c1c1c1cc1c1c111c111555656561155656565565676767656565555555565656666556666666655525626262614444444444444441544444444444115c1c111c1c1c1c11c1c1c1c1c1c556565651c55565656565676767665656551155651166116d5dddddddd655556666666556666666666666666666666666666561c1c1c1c1c1c1cc111c1c111c15556565611556565655556666666565655555555656566665566666666555256262626556d6d666d6d666d6d666d6d66d6d6651111c11111c1111c1c1c1c1c1c556565651c55565656555666666665656551155651166116d5dddddddd655556666666556666666666666666666666666666561c1c1c1c1c1c1c11c111111111555656561155656565565676767656565555555565656666d566666666555256262626556d6d666d6d666d6d666d6d66d6d66511111111c13b3b1c1c1c1c1c1c556565651c55565656565676767b3b35655115565116611655dddddddd655556666666556666666666666666666666666666561c1c1c1c3b33b3b1111111111155565656115565656b3b33b3b3b3333b3bb3b3b56565666655dddddddd555256262626d5dddddddddddddddddddddddddddd651111b3b3b3b33b3b33b3bc1c11556565651c5b3b33b3b3b33b3b333b33b3333b33b356666655dddddddd555556666666d5ddddddddddddddddddddddddddb3b3b3b33b3b3b33b3b33b333b3b3b3b3b3b33b3b3b33b33333333333b3333333b333333b3333b3b3b33b3b33b3b333333b33333b33b33b33b33b33bb3b3b3b33b3b3b3333b333b33b33b333b3b3b33333b3b333333333333333333333333333333333333333333333b33b33333333333333b3333333bb3333b33333333333333333b33b33333333333333b3333b33b3b3333333333333333333333333333333333333333333333333333333333333333333b3333333bb3333b333333333b333333b33b333b333b3333b333b33b33333333b3333b3b33b33333111111133333331111113b3333b3b3b33b3b33b3b333331133333b33113b33b33b33bb3b3b3b3333333333333333333333333333333333333351c11cb33b3b3b3cb3b333b33c3333b33b3c666611111c11ddd5555c111111115c111111111cdddd11111c1ddddb3b3c3b33b3b3bc3b3b111111111115556565611111111111111d3b3dd111b3c11b3b56c6dd1111c111111dc5552562c2626d5dc777d1111111ddd1111111ddddd651111b11111111111111111c111c1c111c5ccc5c6c6c6c6c6c6c6cbcbc565c1c5c651c6c1c655cdc7caddc5c5c611c1c6c566c6c6c6c6c6c6c6c6c6c6c6c6c611c1c111cc3b33b311c111111111111111111155656565565676767656577111111565656666116666666651111111211dd511dd666d6d666111111d6d66d6d66511111111c13b3b1c1c111111111567c1c111c771c111c111c766c661c1c1c1c5c6c1c6c1c6c5cdcdcdcdc5c5c6c6c6c6c5c6c666c166c111c611c111c11111c11c1111111111111111111111111156565611111565111111116666565655555555611566665566666666555256262626556d6d666d6d666d6d666d6d66d6777711111111111111111ddd1c1c1111116565cc55c111c656c676c676c5c565c115c651c661c6d5cdddcdddc555c111c666c566c6c666c666c666c666c666c6661111111c1c1c1c1cc1c1c111c11157771156111111117756567676765dddd155555565656666556666666655525626262614444444444111441547111d1d44111111c1111111c1c1111111117c1c5111116d111111111117561111d11dd5c551c556c116c116c5ddcdddcd65c556c666c61ccc1c155565656c11111156565656561c1c1c1c1c1c11c1c11111c111c111dddc11c151c511111166666656565555555565657776556666666655527626267777a1711252525251c55511611511611511c111c1dd11111c1c1111111c556565651c1c5c1c1c565676767665656551155651166116d5dddddddd6555566666661c1c1c155111156c15565656565656561c1c1c1c1c1c1cc1c1c11111c11116c671111151777a5656767676565655555555656566665566666667555256262626c11111c152525d1111151111111111c5c1c1c1c1c1c1111111111111111ddd6511111111111111111d666665656551155651166116d5dddddddd6555566666661c1c1c155565656c15565656575777711111111111111cc1c1c1c1c1c1c5c151c1c1c1c1c1c155c666c661c6565555555565656666556666666655525626262611c1c1c252c252c1c5c511c115c16115c1c1c1c1c1c1c11c1ccccc1ccc15111111111ddc1c11165111111611d1dd51155651166116d5dddddddd6555566666661c1c1c155565656c15565656515111161c111d1d111111c1c1c1cdd1c11111c1c11111c1c1c15656c676765656c555c555c565c666c566c666c657ca5ac667c6c1c1c1c2c2525211c1111111c11111c1c111c111c1c1c1ccccc1111300000000031c100000000156d00000000001100000000d610000000005ddd00000000d6d00001c155565d0000000035c1000000000031cccccccccc7c1c1c130ccccccccc0310cccccccc03d0cccccccccc00cccccccc0d0ccccccccc0dd0cccccccc0d0cccc01c2c1c10cccccccc0310cccccccccc031c1c1c1c11c11cccc0c666666666c00c66666666c00c6666666666cc66666666c0c666666666c00c66666666c0c6666c0155560c66666666c00c6666666666c011dd11c11c1c1c1c10c677777776cc0c67777776c00c6777777776cc67777776ccc677777776cc0c67777776ccc6776c0c5c650c67777776c00c6777777776c0dcdc1c1c1cccccccc0c67777777666cc67777776c0c66777777776c66777777666c67777777666c66777777666c6776c0cc1cc0c67777776c0c66777777776c0cccccccccc1c1c1c10c67766666776cc66677666c0c67766666666c67766666776c67766666776c67766666776c6776c0c1c1c0c66677666c0c67766666666c01c1c1c1c11c111c1c0c6776ccc6776c0cc6776cc00c6776cccccccc6776ccc6776c6776ccc6776c6776ccc6776c6776c0ccccc10cc6776cc00c6776ccccccc01c1c1c1c1cc1ccc1c10c6776c0c6776c00c6776c0d0c6776c000000c6776c0c6776c6776c0c6776c6776c0c6776c6776c0c1c1c130c6776c010c6776c0000001c1c1ccc1cc1c1c1c1c0c6776c0c6776c00c6776c010c6776c0cccc0c6776c0c6776c6776c0c6776c6776c0c6776c6776c0cc1cccc0c6776c0c0c6776ccccc01c1c1c1c1c1cc1c1c1c10c6776c0c6776c00c6776c050c6776c0c1c10c6776c0c6776c6776c0c6776c6776c0c6776c6776c0c1ccc1c0c6776c010c677666666c01c1c1c1c1c11c1c1c1c0c6776ccc6776c00c6776c0c0c6776c0cc1c0c6776c0c6776c6776ccc6776c6776c0c6776c6776c0ccccccc0c6776c0c0c667777776cc01c1c1c1c1cccc1c1c10c67766666776c00c6776c010c6776c0c1c10c6776c0c6776c67766666776c6776c0c6776c6776c0c1c1c1c0c6776c0130c6777777666c01c1c1c1c11c1c1c1c0c67777777666c00c6776c0c0c6776c01c1c0c6776c0c6776c67777777666c6776c0c6776c6776c01c1c1c10c6776c0c10c6666666776c0c1c1c1c1cc1c1c1c10c677777776cc030c6776c010c6776c0c1c10c6776c0c6776c677777776ccc6776c0c6776c6776c0c1c1c1c0c6776c01c10cccccc6776c01ccc1c1c11c1c1c1c0c677666666c0d10c6776c0c0c6776c01c1c0c6776c0c6776c677666666c0c6776c0c6776c6776c01c1c1c10c6776c0c1c100000c6776c0c1c1c1c1cccc1ccc10c6776ccccc031c0c6776c010c6776c0c1c10c6776c0c6776c6776ccccc00c6776c0c6776c6776c0c1c1c1c0c6776c01c1c1c1c0c6776c01c1c1ccc11c1c1c1c0c6776c000031c10c6776c030c6776c000000c6776c0c6776c6776c000030c6776c0c6776c6776c000000310c6776c0313000000c6776c0c1c1c1c1cc1ccc1c10c6776c0c1c1c10cc6776cc00c6776cccccccc6776ccc6776c6776c0c1c10c6776ccc6776c6776ccccccc00cc6776cc030ccccccc6776c01ccccc1cc1c1c1c1c0c6776c01c1c10c66677666c0c67766666666c67766666776c6776c01c1c0c67766666776c67766666666cc66677666c0c66666666776c0c1c1c1c1ccccccccc0c6776c0ccc1c0c67777776c0c66777777776c66777777666c6776c0ccc10c66777777666c67777777776cc67777776c0c67777777666c0cc1cccccc1c1c1c1c0c6776c01c1c10c67777776c00c6777777776cc67777776ccc6776c01c1c10c67777776ccc67777777776cc67777776c0c677777776cc01c1c1c1c1ccccccccc0c6666c0c1c1c0c66666666c00c6666666666cc66666666c0c6666c0c1c1c0c66666666c0c66666666666cc66666666c0c666666666c03cccccccccccc1c1c1c10cccc031c1c130cccccccc0130cccccccccc00cccccccc010cccc031c1c130cccccccc010ccccccccccc00cccccccc010ccccccccc01c1c1c1c1c1cccccccccc300003cccccc13000000003c13000000000033000000001c3000031ccc1cc3000000001c30000000000013000000003c10000000003cccccccccccc1ccc1c1ccc1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1ccc1c1c1cccccccccccccccccccccccccccccccccccccccccccccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1ccc1cccccccccccccccccccccccccccccccccccccccccccc1ccc1c1ccc1c1ccc1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1ccc1c1c1c1ccccc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccc1ccccc1ccc1c1c1c1c1ccc1c1c1ccc1c1c1ccc1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1ccc1c1c1ccc1c1c1ccc1c1c1c1ccccc1ccc1c1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccc1c1ccccc1c1c1ccc1c1c1ccc1c1c1c1c1c1ccc1c1c1ccc1c1c1ccc1c1c1ccc1c1c1ccc1c1c1c1ccc1c1c1ccc1c1c1ccc1c1ccc1c1ccc1ccccccc"
local convert="0123456789abcdef"
local function convertletter(c)
 for i=1,16 do
  if sub(convert,i,i)==c then
   return i-1
  end
 end
 return 0
end
local function draw_rle_image(image)
 local index=1
 local count=0
 local color=0
 for y=0,127 do
  for x=0,127 do
   if count==0 then
    count=convertletter(sub(image,index,index))
    index+=1
    color=convertletter(sub(image,index,index))
    index+=1
   end
   pset(x,y,color)
   count-=1
  end
 end
end
local function draw_image(image)
 local index=1
 for y=0,127 do
  for x=0,127 do
   pset(x,y,convertletter(sub(image,index,index)))
   index+=1
  end
 end
end


local done=false
local palanim=0
local palanimtick=0
local palanims={
 { 0, 0, 1, 5, 0, 0, 1, 5, 5, 5, 5, 5, 1, 1, 1, 5},
 { 0, 1, 1, 3, 5, 0, 5, 6, 5, 4, 4, 3, 2, 1, 2, 4},
 { 0, 1, 2, 3, 4, 5, 5, 6, 4, 4, 9, 3,13, 2, 2, 9},
 { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15},
}
function titleupdate()
 if not done then
  for i=0,15 do
   pal(i,0,1)
  end
  draw_image(titleimage)
  done=true
  music(0)
 end
 
 palanimtick+=1
 if palanimtick>=7 then
  palanimtick=0
  palanim+=1
  if palanim<=4 then
   for i=0,15 do
    pal(i,palanims[palanim][i+1],1)
   end
  end
 end

 if btnp(4) then
  _update=gameupdate
  _draw=gamedraw
  music(-1)
 end
end

-- intro junk
function intro()
 local c1,c2=7,7
 local t=0
 local open=-1
 palt(0,false)
 sfx(63)
 while not btnp(4) do
  cls(0)
  rectfill(54,38,73,65,1)
  t+=1
  if t==7 then
   if c1==c2 then
    if c2%2==0 then
     c1+=1
    else
     c2+=1
    end
   elseif c2>c1 then
    c1=c2
   else
    c2=c1
   end
   t=0
  end
  pal(9,c1%16)
  pal(10,c2%16)
  spr(238,56,40,2,2)
  print("jeb_",57,58,7)
  
  if open<20 then
   rectfill(0,0,64-open,128,0)
   rectfill(64+open,0,128,128,0)
  elseif open>40 then
   rectfill(0,0,10+open,128,0)
   rectfill(118-open,0,128,128,0)
   if open>60 then
    break
   end
  end
  open+=.5
  flip()
 end
 pal()
end
intro()
__gfx__
00000000bbbbbbbb31b313135055565b7cccccc700000000bbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbbbbb65555550cccccccc775d66bbb7777775b7777775
000000009b3bb9bb1b0331b305556503ccc7cccc00000000bbbbbbbbbbbbbbbbbb000bbbb440bbbb6699499066666660ccc000cc765d66bbb7d66d65b7d66d65
00700700bbbbbb3bb330394056553555cccccccc00000000bbbbbb555553bbbbbb0bb0bbb440bbbb6694494099944440cc0ccccc555d6666b7dd6dd5b7dd6dd5
000770003bb9bbbb3133100365555655cccccc7c00000000bbbbb55555553bbbbb000bbbb000bbbb6644444090404040cc0ccccc6ddd6666b5555555b5555555
00077000bbbbbbbb1b01b113350550567c77cccc00000000b7eeee5555553bbbbb0bb0bbbbbbb666bb11100099444440cc0ccccc767676767676767676767676
00700700bbbbb3bbb940333150565555ccccc77c00000000b7eeee5555553bbbbb0bb0bbbbbbb440b1cc1bbb90404040ccc000cc6666775d77775d6677777775
00000000b3bbbbbb310b031b55556550cccccccc00000000b7eeee5555553bbbbbbbbbbbbbbbb440b1cc1bbb99444440ccccccccbb66765d76665dd676666665
00000000bbb9bbbb13b331b336535503cc77c7cc00000000b7bbb55555553bbb33333333bbbbb000bb11bbbb0000000311111111bbb6555d75555ddd75555555
000000005667766555555555566776657777777700000000b7bbb557775533bbaaaaaaaa4444444444444444476666d4bbbb433b77777777dddddddd00000000
000000005666666566666666666666667e7e7e7700000000b7bbb577777533bbaa000aaa466544444777766546766d54a38493a37d9444d7d222222d00000000
0000000056677665666666666667766677eeeee700000000b7bbb770707733bbaaa0aaaa46654444476666654667dd54bb4663bb7da999c7d299994d00000000
000000005666666576767676767676767eeeee7700000000b7bbb7707077333baaa0aaaa45554444455555554667dd543967c63a7dc99cc7d249944d00000000
0000000056677665767676767677767677eeeee700000000b7bbb7777777333baaa0aaaa44444444477776654667dd54346cc6b377777777dddddddd00000000
000000005666666566666666666666667eeeee7700000000b73bb7070707333baa000aaa47676767476666654667dd54934663937ccccccdd944444200000000
0000000056677665666666666667766677e7e7e700000000bbb337070707333baaaaaaaa4767676745555555467ddd54b8444bbb71c1c1cdd040040200000000
000000005666666555555555566666657777777700000000b66666ddddddddd6444444444666666644444444475555d4bbb343bb7cccc1cdd042240200000000
0000000056677665566776655555555555555555000ee0000000eeeeeeee0000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777775b777777777777775
0000000056666666666666655666666666666665077ee7700777eeeeeeee7770bbbbbbbbbbbbbbbb9b666666666666bbbbbbbbbbb7666665b766655566555665
000000005667766666677665566666666666666507eeee7007eeeeeeeeeeee70bbbbbbbbbbbbbbbbb6666666666666bbb777777537666665b766666666666665
0000000056667676767676655666767676767665eeeeeeee07eeeeeeeeeeee70bbbbbbbbbbbbbbbbb66555555555553bb766666537666665b555555555555555
0000000056677676767776655667767676777665eeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbbb66540404040443bb766666535555555b994222222222222
000000005666666666666665566666666666666507eeee70eeeeeeeeeeeeeeeebbb000bbbb00bbbb6654444444444433b555555536666665b040404040404042
0000000056666666666666655667766666677665077ee770eeeeeeeeeeeeeeeebbb0bb0bb0bb0bbb6654333333333333b999499235656565b944444444444442
0000000055555555555555555666666556666665000ee000eeeeeeeeeeeeeeeebbb000bbbbb0bbbb6654333bbbbbbbbbb040404236666665b040404040404042
00000000c567765cc55cc55c0000000000000000eeeeeeeeeeeeeeeeeeeeeeeebbb0bb0bbb0bbbbb66543bbbbbbbbbbbb944444235656565b944444444444442
000000005566665555555555000000000000000055550eeeeeeeeeeeeeeeeeeebbb0bb0bb0000bbb66663bbbbb9b666bb040404236666665b040404040404042
0000000055677655666666660000000000000000511660eeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbbb46666b9bbb66663b944444235656565b944444444444442
00000000c566665c767676760000000000000000511160eeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbbb466663bb9b65553b040404236666665b040404000404042
00000000c567765c767676760000000000000000511160ee07eeeeeeeeeeee70bbbbbbbbbbbbbbbbb4555533bbbb4043b944444235656565b944444005444442
00000000556666556666666600000000000000009a9aa06007eeeeeeeeeeee70bbbbbbbbbbbbbbbbbb4404333bbb4443b944444235555555b222222055222222
0000000055677655555555550000000000000000a9a9a5600777eeeeeeee7770bbbbbbbbbbbbbbbb666ddddd66666ddd66dddddd6ddddddd666ddddddddddddd
00000000c566665cc55cc55c0000000000000000555550560000eeeeeeee0000333333333333333366666dd666666666bb666ddd666ddd3bbb66dddddddddd33
0009a000ee00000eeeeeeeeeeeeeeeeeeeeeeeee00000000bbbbbbbb8888888baaaaaaaaaaaaaaaabbb3bb9bbb3bbbbbb9bbbb3bbbbbbb50bbbb5000bbbb50bb
09aaaa00e0594550ee444444444444444444440e00000000b77777778ddddd8baaaaaaaaaaaaaaaabbbbbbbbbbbbbb4bbbb3bb9bbb3bbb0bbbb550bbb055000b
9a09a9a005945995e4444444444444444444444000000000b7dddddd8d66668baaaaaaaaaaaaaaaab3bbbbbbbbbbbbb9bbbbbbbbbbbbb50bbb0000bbbb0000bb
9a09a00059459445e44ffffffffffffffffff44000000000b7d266268d66668baaaaaaaaaaaaaaaab676676676676676bbbbbb3b9bbbb0bbb655555bb675555b
09aaaa0059459450e4499999999999999999944000000000b7d2222622222223aaaaaaaaaaaaaaaab676676676676676b3bbbbbbbbbb755bb676655bb677655b
0009a9a005949440e44ffffffffffffffffff44000000000b7d2662670606053aaaa000aaa00aaaab66656666666666bbbbb4bbb4bbb765bb676655bb676655b
9a09a9a0e0544400e4499999999999999999944000000000b7d2662676666653aaaaa0aaa0aa0aaab4bbbbbbbbbbb9bbbbb44bb44bb47653b676655b36766553
09aaaa00e05490eee44ffffffffffffffffff44000000000b777777670606053aaaaa0aaaaa0aaaabbbbb3bbbbbbbbbb3b44444444446653b676655336776553
0000000000000000e4499999999999999999944000000000b755555576666653aaaaa0aaaa0aaaaabb4abb4abb4abbbbb44a441a441a6653b677655336776553
003bb00055555550e44ffffffffffffffffff44000000000b760606070606053aaaa000aa0000aaab4a9b4a9b4a94bb3b4a911a911a946532677655226776552
003bb00056666666e4499999999999999999944000000000b766666666666653aaaaaaaaaaaaaaaa4a994a994a994bbb4a991a991a9945534676655446766552
03bbbb0056060606e44ffffffffffffffffff44000000000b760606060606053aaaaaaaaaaaaaaaaa99999999999942b99999999999945234476654444766542
3b0003b056060606e4499999999999999999944000000000b766666666666653aaaaaaaaaaaaaaaaa99999999999942399999999999994239444449999444492
003bb00056060006e44ffffffffffffffffff44000000000b760606060600653aaaaaaaaaaaaaaaa909090909090902390909090909090239999999999999992
003bb00056066606e4499999999999999999944000000000b766666666600653aaaaaaaaaaaaaaaa444444444444442390909090909090239090909090909092
03bbbb0056666666e44ffffffffffffffffff440000000006ddddddddddddddd4444444444444444666666666666666644444444444444234444444444444442
0000000000000000e44999999999999999999440000000000000000000000000ccccccccccccccccbbbbbbbbb6666665bbbbb3bb3bbbbbbbbb7777777777766b
0000000000288800e44ffffffffffffffffff440000000000000000000000000ccccccccccccccccbbbbbbbbb6ddddd53bbbbbbbbbbbb3bbbb7dddddddddd56b
0000000002888880e44999999999999999999440000000000000000000000000ccccccccccccccccb666666536ddddd5b77777777777776bbb7777777777766b
0000000028808088e44ffffffffffffffffff440000000000000000000000000ccccccccccccccccb6ddddd536daddd5b7ddddddddddd67bb976666666666d5b
0000000028888888e44999999999999999999440000000000000000000000000ccccccccccccccccb6dadad5355a5555b7d66ddd66dd6d73bb76767676767d53
0000000028800088e44444444444444444444440000000000000000000000000cccc000ccc00ccccb55aaa553ddaadd5b7dddd66dd66d673bb76767676767d53
0000000002808080ee444444444444444444440e000000000000000000000000ccc0ccccc0cc0cccbddadad530d0d0d5b7d666dd66dd6d73bb76666666666d53
5555555500288800eee0000000000000000000ee000000000000000000000000ccc0ccccccc0ccccb0d0d0d53dddddd5b777777777777773bb76767676767d53
0000000000000000000000000000000000000000000000000000000000000000ccc0cccccc0cccccbdddddd530d0d0d5b7666666666666539b76767676767d53
0000000000000000000000000000000000000000000000000000000000000000cccc000cc0000cccb0d0d0d53dddddd5b762222222626653bb76666666666d53
0000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccbdddddd530d0d0d53762222d22626653bb76767676767d53
0000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccb0d0d0d53dddddd5b7626226222226533b76767676767d53
0000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccbdddddd530000005b766666666666653bb76666776666d53
0000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccb555555535555555b765565555655653bb76767557767d53
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc66dddddd6dddddddb765565555655653bb76767557767553
00000000000000000000000000000000000000000000000000000000000000001111111111111111bb666ddd666ddd3bdddddddddddddddd6666dddddddddddd
10101010101010101010101010101040404040101010101010101010101010101010101010101010101010202020101000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010101040404040401010101010101010404010101010101010101010102020202020101000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010101040404040401010101010101040404040101010101010101010102020202010101000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010202010101010101010404040404040101010104040404040101010101010202020202020201010101000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101020202020102020101010404040404040101010404040404010101010101010202020202020202010103000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101020202020202020201010101040404040404040404010101010101010102020202020202020202020203000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010102020202020201010101040404040404040401010101010101010102020202020202020202020203000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010301010102020202020202010101010404040401010101010101010101020202020202020202020202020203000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101030303030101010202020202020101010101040401010101010101010101020202020202020202010202020203000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101030303030301010202020202020101010101040401010101010101010101010102020202020201010101010103000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010303030301010101020202020202010101040401010101010101010101010101010101010101010101010303000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101030303010101020202020202010101040401010101010101010101010101010101010101010101030303000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010202020202010101040401010101010101030101010101010101010101010103030303000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010202020202010101040401010101010101010101010101010101010101010303030303000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010102020201010101040401010101010101010101010101010101010303030303030303000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010102020101010101040401010101010101010101010101010303030303030303030303000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb66bbbbbbb4444444444444444bbbb5555555533bbbbbbabba9bbabbbb0000000000000000000000000000000000000000000000000000000000000000
b6666667f666666b4333333333333334b3b555d55d55533bbbbbaaba9ba9bbb30000000000000000000000000000000000000000000000000000000000000000
b67776777f67776343bab6bb2bbb8bb4bb55d000000d5533bb3bbaabba9bbbbb0000000000000000000000000000000000000000000000000000000000000000
b6777677ff6f776343b9b6b258225224b55d06d6d6d055533333bbaaa9b33b3b0000000000000000000000000000000000000000000000000000000000000000
b67776777f67776343bbb6b833335324b5550d6d6d60d553b3b33bba9b33b33b0000000000000000000000000000000000000000000000000000000000000000
b6777677ff6f776343000665223bbb84b55d06444460d553b3333bba9bb3333b0000000000000000000000000000000000000000000000000000000000000000
b67776777f677763405b50d5d523bb24b55d047bb740d553bb44bb6a96bb34bb0000000000000000000000000000000000000000000000000000000000000000
b67776766f6f776340b0b03d65328254b55504b77b40d553bb44667a966644bb0000000000000000000000000000000000000000000000000000000000000000
b677766776677763405b503b66353554b55d04bbbb40d553bb6677aaa96766bb0000000000000000000000000000000000000000000000000000000000000000
b6777677776f776343000333b6653534b5dd04777740d553667766aa946677660000000000000000000000000000000000000000000000000000000000000000
b666666666666663430b03bbb66bbbb4b55504bbbb405553667766aa94d677660000000000000000000000000000000000000000000000000000000000000000
b67767677676776343bbbbabb66600b4b55d50000005d5533b6677ddddd766b30000000000000000000000000000000000000000000000000000000000000000
b677676556767763431ccbbb006694b4bb555d5d5d5d5533bbbb6676ddddbbbb0000000000000000000000000000000000000000000000000000000000000000
b67767655676776343177c9b94b6bbb49bb55d5d5d55533bb3bbbb677d3333bb0000000000000000000000000000000000000000000000000000000000000000
6ddddddddddddddd4545454545454545666655555555dd6666666666666ddd660000000000000000000000000000000000000000000000000000000000000000
66dddddddddddddd4545454545454545666666666666666667767767767767760000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011a9a9a9a9a9a9a9
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111aaaaaaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9a9a9a919a9a9a9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009ffffffa1aaaaaaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a07ff70919a9a9a9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009ffffffa1aaaaaaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9feefa919a9a9a9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a922a9a1aaaaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111119a9a9a9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a9a19a911111111
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019a91a9a1a9a19a9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001fff1fff1fff1fff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004333433433344333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004344434443444434
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444444444444
__gff__
0001000000008080808080808080808000020202000080808080808080808000000202020200000080808080808080800006060000000000808080808080808000000000000080808080808080808080000000000000808080808080808080800000000000000000808080808080808000000000000000008080808080808080
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080808080800000000000000000808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020101010101010101010101010101010101010101010101010101010101010101010103030303030000000000000000000000000000000040606060606060606060606060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020201010101010101010101010101010101010101010101010101010101010101030303030000000000000000000000000000000050606060606060605160606060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202010101010101010101010101010101030101010101010101010101010101030303010000000000000000000000000000000060606060606060606060606060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202010101010101010101010101010101010101010101010101010104040101010101010000000000000000000000000000000000424343434343434343434343434400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202010101010101010101010101010101010101010101010101010104010101010101010000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202040404010101010101010101010101010101010101010101010104040401010101010101010000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020204040404040101010101010101010101010101010101010101010104040101010101010101010000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202010404040404010101010101010101010101010101010101010404040404040101010101010101010000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020201010101010101010101010101010301010101010101010101010404040404040101010104040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020201010101010101010101010101010101010101010101010104040404040401010101010104040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020101010101010101010101010101010101010101010101010104040404040401010101040404040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020101010101010101010101010101010101010101010104040404040404040401040404040404040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020201010101010101010101010101010101010101010101010104040404040404040401040404040404040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020201010101010101010101010101010101010101010101040404040404040404040404040404040404040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101040404040404010404040404040404040404040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101030301010101040404040202010104040404040404040404040404040000000000000000000000000000000000525353535353535353535353535400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010404010101010101010101010101030303030301010404040404020202010404040404040404040404040404040000000000000000000000000000000000626363636363636363636363636400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101040404040101010202020201010101030303030301040404040401010201040404040404040404040404040404040000000000000000000000000000000000004243434343434343434343440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101040404040101010202020201010103030303030304040404040404040404040404040404040404040404040404040000000000000000000000000000000000005253535353535353535353540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040404010102020202010101010103030304040404040404040404040404040404040101010404010104040404040000000000000000000000000000000000006263636363636363636363640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040404010102020202010101010101030304040404040404040404040404040404040101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040401010102020202010101010101010404040404040404040404040101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040401010102020202010101010101010404040404040404010101010101010101010101010101030101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102020202020101010101010404040404040404040401010101010101020201010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102020202020101010101010404040404040404040101010101020202020202010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101020202020202010101010101040404040404040401010101010102020202020202020101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202010101010101040404040404040401010101010202020202020202020303010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020201010101010404040404040404010101010101020202020202020201030303030101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020101010101010404040404040404010101010202020202020202020201010303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202010101010101010404040404010101010102020202020202020202020101010101030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101020201010101030101010404040404010101010102020202020202020202010101010101030301010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010404010101010101020202020202020101010101010101010101010102020101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000217300a7300a7200b7200b720097100871006710047100371003710037100271004710007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00010000277300d7300d7200c7200b710097100871007710067100571004710047100371003710047100471003710000000000000000000000000000000000000000000000000000000000000000000000000000
000100001f63020630150301403012020100200e0100d0100d0100c0100b0100b0100c0100c0101e6000f6000d6000d6000d6000d6000d6000d6000e6000e6000d6000d6000d6000d6000d6000d6000d60000600
0002000017120181301813016130131500f1500d150086300a130056300812007120061200464006140061200412007110046300b1400d1400463002630036200162000000000000000000000000000000000000
000200001a7141d71235711357122471314703397032471322703397032471339700147003970021700317003870038700397003970033700237003b7003b70034700157003c7003d7003d700257003d7003d700
00030000083300a30008330053000833005300053302e5002e5001c5001c5001c5000830008300083000930009300093000930009300093000930009300093000030000300003000030000300003000030000300
01100000185501b5501f5501f5051f550000001f55000000185501b55020550205002055000000205500000024550225501f550000001f550000001f550000001f5501b550185500000018550000001855000000
011000001f0001b000180501f000180501f000180501f000200001b0001805018000180502000018050200001f00022000240502400024050240002405024000180001b0001f0501f0001f0501f0001f0501f000
0110000024550225501f550000001f550000001f55000000205501b550185501f500185501f500185501b500165501b5501f550000001f550000001f5500000016550185501d550000001d550000001d55000000
0010000010203182030000018203000001820300000182031f2031f203000001f203000001f203000001f20300000202030000020203000002020300000202030000018203000001820300000182030000018203
010a0000185511b5511f551185511b5511f551185511b5511f551185511b5511f551185511b55120551185511b55120551185511b55120551185511b5512055116551175511b55116551175511b5511655118551
01100000200501b05018050200501b05018050200501b05018050200501b050180501f0501b050180501f0501b050180501f0501b050180501f0501b05018050180501b0501f050180501b0501f050180501b050
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000135501b550185501b550185501b550185501b5501a5501d5501a5501d5501a5501d5501a5501d5501b5501f5501b5501f5501b5501f5501b5501f5502455020550245502055024550205502455020550
__music__
04 06 07 43 44
00 06 07 43 44
02 08 42 43 44
02 08 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
