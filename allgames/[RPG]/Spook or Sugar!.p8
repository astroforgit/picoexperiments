pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function mobflip(mb,dx,dy)
 mb.flpx = dx==0 and mb.flpx or dx<0
 if dy then
 mb.flpy = dy==0 and mb.flpy or dy<0
 end
end

function mobbump(mb,dx,dy)
 mb.sox,
 mb.soy,
 mb.ox,
 mb.oy,
 mb.mov
 =
 dx*8,
 dy*8,
 0,
 0,
 mov_bump
end

function mov_bump(self)
 local tme=p_t>0.5 and 1-p_t or p_t
 self.ox,self.oy=self.sox*tme,self.soy*tme
end

function mov_walk(self)
 self.ox,self.oy=self.sox*p_t,self.soy*p_t
end


function drawspr(m)
 spr(m.s,m.x*8+m.ox,m.y*8+m.oy,m.w or 1,m.h or 1,m.flpx,m.flpy)
end


function create_object(s,x,y,draw,update,w,h)
 ob= {
  s=s,
  draw=draw or drawspr,
  update=update or empty,
  d=0,
  x=x or 8,
  y=y or 8,
  dx=0,
  dy=0,
  ox=0,
  oy=0, 
  w=w or 1,
  h=h or 1
 }
 add(objects,ob)
 return ob
end


function isorty(t) --insertion sort, ascending y
 for n=2,#t do
  local i=n
  while i>1 and t[i].y*8+t[i].oy+(t[i].z or 0)<t[i-1].y*8+t[i-1].oy+(t[i-1].z or 0) do
   t[i],t[i-1]=t[i-1],t[i]
   i-=1
  end
 end
end
-------------------------------
--compression
-------------------------------
function explodeval(s)
 local retval,lastpos,subarray={},1
 for i=1,#s do
  subes=sub(s,i,i)
  if subes=="{" then
   i+=1
   subarray=i
  elseif subes=="}" then
   add(retval,explodeval(sub(s,subarray,i-1)))
   subarray=nil
  elseif subes=="," and not subarray then
   local subs=sub(s, lastpos, i-1)
   add(retval,tonum(subs) or subs)---#subs!=0 and
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

-------------------------------
--connversion/getting data
-------------------------------
function contains(array,a)
 for i in all(array) do
  if i==a then
   return true
  end
 end
end

function get_sig(x,y)
  local sig=0
  for i=1,4 do
    local dx,dy=x+dirx[i],y+diry[i]
    sig=bor(sig,shl(not check_tile(dx,dy,2) and not out_of_bounds(dx,dy) and 0 or 1,8-i))
  end
  return sig
end

function check_tile(_x,_y,_f)
  m=get_object(_x,_y)
  return m and fget(m.s,_f) or fget(mget(_x,_y),_f)
end

function get_object(_x,_y,filter,truth)
  -- local static_backup=nil
  for m in all(objects) do
    if m.x==_x and m.y==_y and m[filter]==truth then
      -- if m.satic then
       -- static_backup=m
      -- end
      return m
    end
  end
  -- return static_backup
end

-- function out_of_bounds(_x,_y)


function compare_sig_mask(sig,match,mask)
  return bor(sig,mask)==bor(match,mask)
end

function convert_spr(s) 
  return s%16*8,flr(s/16)*8
end

function convert_cord_to_spr(x,y) 
  return flr(x/8)%16+flr(y/8)*16
end

function flag_check(x,y,f)
  if f then return fget(getm(x,y),f) end
 return fget(getm(x,y))
end

function mflr(obj)
  return flr(obj.x/8),flr(obj.y/8)
end

function convert_cord(obj)
   return {x=flr(obj.x/8),y=flr(obj.y/8)}
end
-------------------------------
--collision
-------------------------------



function get_buttons()
 p.dx,p.dy=0,0
 for i=1,4 do
  if btn(i-1) then
   p.dx+=dirx[i]
   p.dy+=diry[i]
  end
 end
end

function getbtn(n)
 for i=0,5 do
  if btnp(i,n) then
   return i+1
  end
 end
 return 0
end

-------------------------------
--pathfinding
-------------------------------
function find_matching_tiles(position,sprite)
 local found,pos=2048,convert_cord(position)
 founds={}
 for x=0,mapwidth do
   for y=0,mapheight do
     if mget(x,y)==sprite then
      add(founds,{x=x,y=y})
     end
   end
 end
 return founds
end



function heuristic( nodea, nodeb )
 return nodea==nodeb and 0 or check_tile(nodea.x,nodea.y,0)
    and 
    255 
    or 
    distance(nodea,nodeb) 
end


function ípathfinding(start,goal,ja)
 --í
 closedset,
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
 while openset do
  local current = lowest_f_score(openset,f_score)
  if current==goal then
   local path={}
   while goal do
   -- êdebug_square(goal.x,goal.y,g_scr[goal])
    add(path,goal)
    goal=came_from[goal]
    
    -- if mob then
    -- êdebug_print(filter,goal.x,goal.y,step+1)
    -- end
    -- wait(2)
   end
   return path
  end
  del(openset,current)
  add(closedset,current)
  for i=1,4 do 
   local dx,dy=current.x+dirx[i],current.y+diry[i]
   if not out_of_bounds(dx,dy) then
    local ngb=graph[dx][dy]
    if not_in(closedset, ngb)  then
     tg_scr,
     notopen 
     = 
     g_scr[current]+distance(current,ngb),
     not_in(openset,ngb)
     
     if notopen or tg_scr<g_scr[ngb] then
      came_from[ngb],
      g_scr[ngb]
      =
      current,
      tg_scr
      f_score[ngb]=g_scr[ngb]+heuristic(ngb,goal)
      if notopen then
       add( openset, ngb )
      end
     end
    end
   end
  end
 end
end

-------------------------------
--dijkstra maps
-------------------------------
--ídijkstra_map
function calcdist(tx,ty)
 local cand,step={{x=tx,y=ty}},0
 distmap=blankmap()
 distmap[tx][ty]=0
 repeat
  step+=1
  candnew={} 
  for c in all(cand) do
   for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if not out_of_bounds(dx,dy) and not distmap[dx][dy] then
     distmap[dx][dy]=step
     if not check_tile(dx,dy,0) then
      add(candnew,{x=dx,y=dy})
     end
    end
   end
  end
  cand=candnew
 until #cand==0
end

function find_nearest_tile(tx,ty,filter,truth)
 local cand,step={{x=tx,y=ty}},0
 distmap=blankmap()
 distmap[tx][ty]=0
 truth=truth and truth or true
 repeat
  step+=1
  candnew={} 
  for c in all(cand) do

   if mget(c.x,c.y)==filter then
     -- cls()
     -- _draw()
    return c
   end
   for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    printh(dx.." "..dy)
    printh(out_of_bounds(dx,dy))
    if not out_of_bounds(dx,dy) and not distmap[dx][dy] then

     distmap[dx][dy]=step
     local mob=get_mob(dx,dy)
     if mob and mob[filter]==truth then
      return mob
     end
     if not check_tile(dx,dy,0) then
      add(candnew,{x=dx,y=dy})
     end
    end
   end
  end
  cand=candnew
 until #cand==0
end

function round(x)
    return flr(x + .5)
end

function sign0(n)
  if n<=0 then return 0 end
  return 1
end


-------------------------------
--fading
-------------------------------
dpal,
fadeperc
=
explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14"),
1
function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

dpal2=explodeval("0,2,7,7")

function fade(path,length)
 wait(length*4)
 fadeperc=path==1 and 0 or 4
 repeat
  fadeperc+=1*path
  for j=fadeperc,4 do
   pal(palate[j],palate[j-fadeperc],1)
  end
  wait(length)
 until fadeperc==4 or fadeperc==0
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-.04,0)
  dofade()
 end
end
-------------------------------
--data
-------------------------------
dirx,
diry
=
explodeval("-1,1,0,0,1,1,-1,-1,"),
explodeval("0,0,-1,1,-1,1,1,-1,")
dirx[0]=0
diry[0]=0
function sin_time()
  return sin(time()*4)
end

function getrnd(tab)
  return tab[ceil(rnd(#tab))]
end

function blankmap()
 local blank={}
 for _x=0,mapwidth do
  blank[_x]={}
 end
 return blank
end

-------------------------------
--strings
 -------------------------------
 chars,
 s2c,
 c2s
 =
 " !\"#$%&'()*+,-./:;<=>?@abcdefghijklmnopqrstuvwxyz0123456789[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~",
 {},
 {}

 for i=1,95 do
  c,s=i+31,sub(chars,i,i)
  c2s[c],s2c[s]=s,c 
 end

 function chr(i)
  return c2s[i]
 end

 function ord(s,i)
  return s2c[sub(s,i,i)]
 end

function string_width(txt)
  local ws=0
  for i=1,#txt do
   if check_for_style(sub(txt,i,i)) then
    i+=1
   else
    ws+=1
    if not ord(txt,i) then
     ws+=1
    end
   end
  end
  return ws
end


function check_for_style(charf)
 comds="\0\1\2\3"
 for r=1,#comds do
  if charf==sub(comds,r,r) then
   return r-1
  end
 end
end

function binary(num)
 local bin=""
 while num!=0 do
  bin=(num%2)..bin
  num-=num%2
  num/=2
 end
 return bin
end

function increase(string,newlength)
  for f=#string,newlength do
   string=string.." "
  end
  return string
end

function rincrease(string,newlength)
  for f=#string,newlength do
   string=" "..string
  end
  return string
end



function grid_string(text)
 combine={}
 for i=1,flr(#text/3) do
  local te=""
  for f=0,2 do
   if text[f+i*3] then
    te=te..increase(text[f+i*3],10)
   end
  end
  add(combine,te)
 end
 return combine
end

function time_stamp()
 return stat(91).."/"..stat(92).."/"..sub(stat(90),3,4).." "..stat(93)..":"..(stat(94)<10 and "0"..stat(94) or stat(94).." ")
end

function string_size(txt)
 height,
 width,
 ws
 =
 5,
 0,
 0
 for i=1,#txt do
  subs=sub(txt,i,i)
  if subs=="\n" then
   height+=6
   if ws>width then
    width=ws
   end
   ws=0
  else
   ws+=string_width(subs)
  end
 end
 if ws>width then
  width=ws
 end
 return width,height
end

function string_position(txt,x)
 local ws=0
 for i=1,#txt do
  if ws>=x then
   return i
  end 
  if not ord(txt,i) then
   ws+=2
  else
   ws+=1
  end
 end
 return #txt
end

function divide_text(txt,max_size)
 text_array,start={},1
 w=0
 for i=1,#txt do
  char=sub(txt,i,i)
  w+=string_width(char)
  if char==" " then
   last=i
  end
  if w>max_size then
   newtext=sub(txt,start,last-1)
   add(text_array,newtext)
   w=w-string_width(sub(txt,start,last))
   start=last+1
  end  
 end
 add(text_array,sub(txt,start,#txt))
 return text_array
end

function combine_text(txt,max_size)
 txt=divide_text(txt,max_size)
 final=del(txt,txt[1])
 for f in all(txt) do
  final=final.."\n"..f
 end
 return final
end

-------------------------------
--palates
-------------------------------
palates={

 {0,3,11,7,"green"},
 {0,2,8,15,"red"},
 {0,9,10,7,"candy corn"},
 {2,4,5,15,"quake"},
 {1,2,14,15,"taffy"},
 {0,1,9,7,"spooky"},
 {0,12,14,7,"cga1"},
 {0,11,8,10,"cga2"},
 {0,8,7,10,"rca"},
 {0,5,6,7,"grayscale"},
 {0,7,7,7,"binary"},
 {2,1,12,15,"blue days"},
 {0,2,13,6,"mortician",},
 {0,2,7,9,"halloween"},--current pal
 {0,1,3,11,"gameboy"},
 {1,2,4,9,"steampunk"},
 {2,4,8,9,"choc bar"},
 {1,3,2,10,"ugly zombie"},
 {15,12,7,14,"alpine"},
 {5,8,6,12,"pico 8"},
 {0,5,7,9,"amber"},
 {0,1,2,3,"truth"},
 {0,1,12,7,"celestial"},

 -- {0,1,9,15,""},
 -- {0,10,}

}
-- flood=explodeval("0,0,0,0")
palatecolor=13
function palate_swap()
 pal()
 for i=0,3 do
  pal(i,palate[i+1])
 end
 -- cls(palate[1])
end

function palchange(di)
 palatecolor=(palatecolor+(di or 0))%#palates+1 
 palate=palates[palatecolor]
 -- palatecolor+=1 
 menuitem(1,palatecolor.." "..palate[5],palchange)

end
-- menuitem(1,"change platte",palchange)
palchange()
-------------------------------
--debug
-------------------------------
function oprint(_t,_x,_y,c1,c0)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],c0 or 0)
 end
 print(_t,_x,_y,c1 or 1)
end

function outline_sprite(obj,c)
  for i=1,15 do
   pal(i,c or 7)
  end
  for i=1,8 do
   -- local s=obj
   local s={flp=obj.flp,s=obj.s,x=obj.x,y=obj.y,ox=obj.ox+dirx[i],oy=obj.oy+diry[i]}
   -- s.ox+=dirx[i]
   -- s.oy+=diry[i]
   drawspr(s)
  end
  pal()
  drawspr(obj)
end

function wait(_wait)
 while _wait>0 do
  _wait-=1
  flip()
 end
 -- until _wait<0
end

cpu_high=0
function stat_print(y,x)
 x=x or 0
 if stat(1)>cpu_high and time()>1 then
  cpu_high=stat(1)
 end
 oprint("cpu "..stat(1),x,y)
 oprint("spi "..cpu_high,x,y+6)
 oprint("fps "..flr(stat(7)),x,y+12)
end

function êdebug_square(x,y,c)
 rectfill(x*8,y*8,x*8+8,y*8+8,c or 8)
end

function select_square(x,y,c)
 rect(x-1,y,x+7,y+7,c or 8)
end

function êdebug_print(t,x,y,c)
 oprint(t,x*8+2,y*8+2,c,7)
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

function snapshot()
 cls()
 map()
 flip()
end

function êprint(text)
 printh('\n'..tostring(text))
 print(tostring(text),0,16,12)
end

function empty() end
-------------------------------
--binary save
-------------------------------
bintable={}
for i=1,2048 do
 bintable[i]=false
end
function commit_bintable()
 for i=0,127 do
  poke(0x5e00+i,get_poker(i))
 end
end
function get_poker(_i)
 _i=_i*8+1
 local _poker=0
 for n=0,7 do
  if(bintable[_i+n])_poker+=2^n
 end
 return _poker
end
function load_bintable()
 for i=0,127 do
   local _poker=peek(0x5e00+i)
   for j=0,7 do
    bintable[i*8+1+j]=get_bit(_poker,j)
   end
 end
end
function get_bit(_value,_n)
 return flr(shr(_value,_n))%2==1
end
function numtobintable(_value,_dest,_nbits)
 for i=0,_nbits-1 do
  bintable[_dest+i]=get_bit(_value,i)
 end
end
function bitstonum(_addr,_nbits)
 local _p=0
 for i=0,_nbits-1 do
  if(bintable[_addr+i])_p+=2^i
 end
 return _p
end

function check_los_dist(m,t)
 return distance(m,t)<=m.los and los(m,t) 
end

function check_tile(_x,_y,_f)
  m=get_mob(_x,_y)
  return 
    m and fget(m.s,_f) 
    or 
    fget(mget(_x,_y),_f)
end

function los(a,b)
 x1,y1=a.x,a.y
 x2,y2=b.x,b.y
 dx,
 dy
 =
 x2-x1,
 y2-y1
 
 abs_dx,
 abs_dy,
 sign_x,
 sign_y
 =
 abs(dx),
 abs(dy),
 sgn(dx),
 sgn(dy)
 abs2_dx,abs2_dy=abs_dx*2,abs_dy*2
 dis=distance(a,b)
 if abs_dx>abs_dy then
   ta=abs2_dy-abs_dx
  while 
   not out_of_bounds(x1,y1) 
   and not check_tile(x1,y1,2)
--   and distance(x1,y1,p.x,p.y)<p.los 
  do
   if x1==x2 and y1==y2 then
    return true
   end  
   if ta>=0 then
    y1+=sign_y
    ta-=abs2_dx
   end
   x1+=sign_x
   ta+=abs2_dy
  end
 else
  ta=abs2_dx-abs_dy
  while 
   not out_of_bounds(x1,y1) 
   and not check_tile(x1,y1,2)
  do
   if x1==x2 and y1==y2 then
    return true
   end 
   if ta>=0 then
    x1+=sign_x
    ta-=abs2_dy
   end
   y1+=sign_y
   ta+=abs2_dx  
  end
 end
end
function get_mob(_x,_y)
 for m in all(mobs) do
  if m.x==_x and m.y==_y then
   return m
  end
 end
end

actions,select={},1
function menu_update()

 if btnp(é) then
  do_action(select)
 elseif btnp(É) then
  sfx(62)
  select=select%#actions+1
  show_select()
 elseif btnp(î)  then
  sfx(62)
  select=(select-2)%#actions+1
  show_select()

 elseif btnp(ó) and actions[#actions].icon=='ó' then
   sfx(61)
   do_action(#actions)

 end
end
-- selection={}
-- selectpwr
function show_select(i)
  selection={}
  selectpwr=actions[select].pwr
  -- printh("show")
  selectmode={}
  mode=actions[select].mode
  if mode then
   for m=1,#mode do
     printh(mode[m])
    selectmode[mode[m]]=true
   end
  else
   selectmode["hp"]=true
  end
  -- actions[select].mode or "hp"
  actions[select].over()
 
end

function do_action(i)
  local act=actions[i]
  local r = actions[i].act
  if r then
   local actionsave=actions
   actions={}

   error=r(p,target,act)
   if type(error)=="string" then
    sfx(60)
    actions=actionsave
    actions[select].name="*"..error--set to error message
   else
    if error then
     turn()
    end 
    sfx(63)
    select=1
   end
  else
   sfx(60)
  end
  show_select()
end

function create_action(name,act,icon,desc,pwr,over,mode)
act={
  name=name,
  act=act,
  icon=icon,
  desc=desc,
  pwr=pwr,
  over=over or empty,
  mode=mode
 }
 add(actions,act)
 return act
end

function create_item(name,use,icon,pwr,price)
 -- if use=="eathp" then

 -- elseif use=="eatmp" then

 -- elseif
 newitem={name=name,use=use,icon=icon,pwr=pwr,price=price}
 newitem.desc,newitem.use,newitem.over,newitem.mode=getitem(newitem)
 return newitem

end

yoffset=96
xoffset=1
xoffset=0

optionsh=flr((120-yoffset)/6)
optionsh1=optionsh+1
optionsw=flr(128/2)

function menu_draw()
 rectfill(0,yoffset,optionsw,127,1)
 color(3)
 selected=actions[select]
 if not selected then
  return
 end
 local name,icon,desc=selected.name,selected.icon,selected.desc
 for r=1,#actions do
  color(2) 
  pal(1,palate[3])
  local f=r-1
  local xo,yo=flr(f/optionsh)*optionsw,yoffset+f%optionsh*6+1
  iconr=actions[r].icon
  if r==select then
   rectfill(xo,yo-1,xo+optionsw,yo+5,1)
   xo+=1 
   color(3)
   pal(1,palate[4])
   draw_icon(xo,yo,iconr)
  end
  print(actions[r].name,9+xo,yo)
   if iconr=='ó' then
    print(iconr,xo,yo)
   end
 end
 rectfill(0,121,127,127,3)
 if type(desc)=='string' then
  pal(1,palate[3])
  print(desc,9,122,1)
  draw_icon(1,122,icon)
 end
  pal(1,palate[2])
end

-- soft_zone_y=0
function menu_draw_single_column()
 xo=xoffset*21
 rectfill(xo,yoffset+1,xo+optionsw,118,1)
 rectfill(xo+1,yoffset,xo+optionsw-1,119,1)
 selected=actions[select]
 if not selected then
  return
 end
 local name,icon,desc=selected.name,selected.icon,selected.desc
 
 --select>#actions-4 and #actions-4 or select-2
 ioffset=#actions<6 and 1 or select<=3 and 1 or select-2
 maxoff=min(#actions,ioffset+4)
 color(2)
 if ioffset>1 then
  print("î",xo+1,yoffset+1)
 end
 if #actions>maxoff or (ioffset==1 and #actions>5) then
  print("É",xo+1,yoffset+25)
 end
 -- print("ë",optionsw-6,yoffset)
 for r=ioffset,maxoff do
  -- color(1) 
  pal(1,palate[3])
  -- local f=r-1
  local xor=xo
  yo=yoffset+(r-ioffset)*6+1
  iconr=actions[r].icon
  -- printh("ioff "..ioffset.." sele "..select.." max "..maxoff.." y "..yo)
  if r==select then
   rectfill(xo,yo,optionsw+xo,yo+4,1)
   rectfill(xo+1,yo-1,optionsw+xo-1,yo+5)
   xor+=1 
   -- color(1)
   pal(1,palate[4])
   draw_icon(xor+1,yo,iconr)
  elseif iconr=='ó' then
   print(iconr,xor+1,yo)
  end
  print(actions[r].name,9+xor,yo)
 end

 rectfill(0,122,127,126,3)
 rectfill(1,121,126,127,3)
 if type(desc)=='string' then
  pal(1,palate[3])
  print(desc,10,122,2)
  draw_icon(2,122,icon)
 end
 pal(1,palate[2])
end

btnicons=explodeval("é,ó,î,ã,ë,É")
function draw_icon(xo,yo,icon)
 if type(icon) == "number" then
  spr(icon,xo,yo-1)
 else
  print(icon,xo,yo)
 end
end
-->8
--trick or treat
--spooked sugar
--sugary spook
--spookysugar
--turducken
--the witch, the wolf and the horse
--#include module_shared.p8
--#include module_console.p8
--#include module_menurpg.p8
console_height=42
console_width=127

progress=0
mapsize=28
objects={}
optionsw=106
yoffset=89
console_y=0
optionsh=flr((120-yoffset)/5)
cash=4
function all_enemys()
	selection=enemy
end

function select_player()
	add(selection,p)
end

function single_target()
	for f=1,#objects do
		if objects[f].name==actions[select].name then
			add(selection,objects[f])
			return
		end
	end
end

function _init()
	reset()
	item_list={
		create_item("candy corn","eatmp",86,3,3),
		create_item("chocolate","eathp",87,6,4)
	}
	skill_table={
	 [0]={trick},
	 {regen,leach,attack},
	 {attack},--defend
	 {leach,megaspook,regen},
	 {},
	 {attack,candy,regen}
	}
	bestiary=explodeval(
	--name,s,hp,mp,dice,sides,def,xp,loot
	"witch,226,10,4,2,2,0,0,0"..
	",bat,72,4,2,1,2,0,1,1"..
	",skele,42,6,2,1,3,0,1,1"..
	",vampi,78,8,4,1,3,0,1,1"..
	",ghost,42,6,0,1,3,0,1,1"..
	",headless,110,10,6,3,3,0,3,1"..
	",frank,42,6,0,1,3,0,1,1"..
	",witch,42,6,0,1,3,0,1,1"..
	",plagu,42,6,0,1,3,0,1,1"..
	",scare,42,6,0,1,3,0,1,1"..
	",pumpk,42,6,0,1,3,0,1,1"..
	",devil,42,6,0,1,3,0,1,1"..
	",death,42,6,0,1,3,0,1,1"..
	",statu,42,6,0,1,3,0,1,1"
	)
	p=add_mob(0,108,89,"\3")
	p.inventory={
		item_list[1],
		item_list[2]
	}
	p.lvl=0
	p.draw=draw_player
	_drw=title_draw
	_upd=title_update
	ttext=title
	music(8)
end

title={0,1,2,2,3,12,2,4,12,0,5,6,7,4}
function title_draw()
 big_text(ttext,20)
	print("ó start game",36,50+sintime,time()*4%2+2)
	map(112,0)
	
	mes="ã"..palate[5].."ë"
	print("palate",52,60,3)
	print(mes,64-string_width(mes)*2,67,2)
end

function big_text(text,x)
	for i=1,#text do
		sx,sy=convert_spr(text[i]+176)
		sspr(sx,sy,8,24,i*8-#text*4+55,sin(time()+i/16)*6+8)
	end
end

win={10,2,5,12,8,2,9,11}

function title_update()
	if btnp(ó) then
		remove_enemys()
  actions={}
	 moving()
	 _upd=menu_update
	 _drw=main_draw
	 print_table('welcome to \3spook or sugar\2!')
--	 print_table('spook your way to the eye!')
	elseif btnp(ã) then
		palchange(-2)
	elseif btnp(ë) then
		palchange()
 end
end

function _draw()
	sintime=round(sin(time()))
	palate_swap()
	 cls(palate[1])
	_drw()
end

function main_draw()
 map(pic*16,0,0,45,16,5)
-- rectfill(0,0,127,console_height,8) 
 draw_log()
 menu_draw_single_column()
 foreach(objects,function(obj) obj:draw() end) 
end

function draw_player(m)
bar=41
	ex=m.x
	ey=m.y
	uibar(ex,ey+25,m,18)	
	color(3) 
	if contains(selection,m) then
		ey+=sintime
		color(2)
	end
	rect(ex,ey+1,ex+18,ey+17)
	rect(ex+1,ey,ex+17,ey+17)
	xs,ys=convert_spr(m.s)
	palt(0,false)
	sspr(xs,ys,15,16,ex+2,ey+1)
	pset(ex+2,ey+1)
	pset(ex+16,ey+1)
	palt(0,true)
	print(m.name,ex,ey+19,2)
end

function _update60()
	_upd()
	log()
end

function add_mob(_typ,x,y,c)
 local entry=_typ*9+1
 local m={
		name=bestiary[entry],
		hp=bestiary[entry+2],
		mp=bestiary[entry+3]/2,
		dice=bestiary[entry+4],
		sides=bestiary[entry+5],
		def=bestiary[entry+6],
		xp=bestiary[entry+7],
		loot=bestiary[entry+8],
		flash=0,
		skills=skill_table[_typ]
 }
 m.maxhp=m.hp
 m.maxmp=bestiary[entry+3]
 m.namec=c..m.name
 obj=create_object(bestiary[entry+1],x,y,draw_mob)
 for k,v in pairs(m) do
 	obj[k]=v
 end
 return obj
end

function draw_mob(m)
	ex=m.x
	ey=m.y
	xs,ys=convert_spr(m.s)
	uibar(ex,ey+39,m,32)
 palate_swap()
	if m.flash>0 then
		c=palate[1]
		if m.hp<=0 then
			c=palate[3]
		end
		for i=0,3 do
			pal(i,c)
		end
		m.flash-=1
	elseif m.hp<=0 then
		del(objects,m)
	 return
	elseif contains(selection,m) then
		for i=0,3 do
			pal(i,palate[4])
		end
		ex+=sintime
		spr(84,ex+sintime,ey-2)
		for i=1,8 do
			sspr(xs,ys,16,16,ex+dirx[i],ey+6+diry[i],32,32)
		end
		palate_swap()
	end
	print(m.name,ex+16-string_width(m.name)*2,ey,1)
	print(m.name,ex+16-string_width(m.name)*2,ey-1,2)
	
	sspr(xs,ys,16,16,ex,ey+6,32,32)
 palate_swap()
end

function uibar(x,y,m,bar)
 rectfill(x,y,x+bar,y+1,1)
 barhp=(m.hp/m.maxhp)*bar
 barmp=(m.mp/m.maxmp)*bar
 if m.hp>0 then
  rectfill(x,y,x+barhp,y+1,2)
 end
 if m.maxmp>0 then
  rectfill(x,y+3,x+bar,y+4,1)
  if m.mp>0 then
  	rectfill(x,y+3,x+barmp,y+4,3)
 	end
 end
-- printh(time()%2) flr(time()*4)%2==0 and 1 or 3
 if contains(selection,m) then
-- 	printh(selectmode.hp)
  if selectmode.hp  then
  	newhp=mid(-barhp,(selectpwr/m.maxhp)*bar,bar-barhp)
  	if newhp!=0 then
--  		barhp=min(barhp+sign0(newhp),bar-newhp)
	  	rectfill(
				x+barhp,y,
				x+barhp+newhp,
				y+1,3)
			end
		elseif selectmode.mp then
			newmp=mid(-barmp,(selectpwr/m.maxmp)*bar,bar-barmp)
   if newmp!=0 then
--  		barmp=min(barhp+sign0(newmp),bar-newmp)
	  	rectfill(
				x+barmp,y+3,
				x+barmp+newmp,
				y+4,2)
			end
  end
 end
end

function floater_draw(f)
 f.y+=(f.ty-f.y)/8
 f.tr+=1
 if f.tr>64 then
  del(objects,f)
 end 
 oprint(f.s,f.x*8,f.y*8,f.c,1)
end

function add_floater(_txt,_x,_y,c)
 obj=create_object(_txt,_x+.375,_y,floater_draw)
 obj.c=c or 2
 obj.ty=_y-1
 obj.tr=0
end

function stat_floater(t,m,c)
	add_floater(t,m.x/8+2+rnd()-.5,m.y/8+2+rnd()-.5,c)
end

-->8
--main updates
function moving()
	menu=moving
	create_action("forward",forward,"à","continue venturing")
	create_action("treat",inventory,71,"eat candy")
	create_action("go home",home,"ä","go home")
	pic=0
end

function forward()
	progress+=1
	eventroll=flr(rnd(16))
	if progress==mapsize then
		actions={} 
		combat_start({5})
	elseif lastspawn>1 and eventroll<lastspawn then
	 actions={} 
		combat_start(getrnd(formations))
	elseif eventroll<lastspawn-1 then
		print_table("a merchant hails you")
		midshop()	
	else
		st="\3ä\2"
		for i=1,mapsize do
			if i==mapsize then
				st=st.."\1à"
			elseif i>progress then
				st=st.."?"
			elseif i==progress then
				st=st.."\3â\1"
			else
				st=st.."."
			end
		end
		if progress_bar and progress_bar+max_rows>#message_stack then
			message_stack[progress_bar]=st
		else
			print_table(st)
			progress_bar=#message_stack
		end
--		print_table(p.namec.." takes a step")
	 sfx(58)
		lastspawn+=1
		moving()
		if eventroll>15 then
			print_table("a chest lies before you")
		 loot()
		end
	end
end


formations={{1},{1,1},{2,2},{1,1,1},{1,2,1},{1,3,1}}
	--bat squad
--	{1,2,1},--skele and bats
--	{1,3,1},--vampire and bats

--printh(tostring(formations))
function combat_start(formation)
 pic=-1
 if not formation then
  formation={}
  for i=1,ceil(rnd(3)) do
  	formation[i]=ceil(rnd(2))
  end
 end
 enemy={}
 encounter="boo! "
	div=(128-#formation*32)/(#formation+1)
	for i=1,#formation do
		new=add_mob(formation[i],(i-1)*32+div*i,44,"\1")
		final=""
		for m in all(enemy) do
			if sub(m.name,1,#new.name)==new.name then
			 if m.name==new.name then
			 	m.name=m.name.." a"
			 end
			 if sub(m.name,#m.name,#m.name)=="b" then
			 	final=" c"
			 else
			  final=" b"
			 end
			end
		end
		add(enemy,new)
		if #formation>1 and i==#formation then
		 encounter=encounter.." \2and "
		elseif i>1 then
		 encounter=encounter.."\2, "
		end
		encounter=encounter..new.namec
		new.name=new.name..final
		new.namec=new.namec..final
--		printh(encounter)
	end
	print_table(encounter)
	menu=combat_menu
	menu()
 music(-1,1000)
	music(8,1000)
end

function turn()
	for e in all(enemy) do
	 if e.hp<=0 then
	  p.xp+=e.xp
	 	del(enemy,e)
	 	if e.name=="headless" then
--	 		win_screen()
	 		_drw=title_draw
				_upd=title_update
				ttext=win
				reset()
				music(-1)
				music(24,1000)
--				moving()
				create_action("")
	 		return
	 	end
	 else
	 	ai_action(e,p)
--getrnd(e.skills)(e,p)
		end
		if p.hp<=0 then
			defeat()
		 return
	 end
	end
	if menu==combat_menu and #enemy==0 then
		victory()
	else
	 menu()
	end
end

function defeat()
	remove_enemys()
	p.draw(p)
	music(-1)
	fade(1,10)
	sfx(56)
	reset()
	 cls(palate[1])
	for f=0,8 do
		print_table("")
	end
	print_table(p.namec.." \2awaken in your home")
	select=1
	progress=0
	home()
	main_draw()
	fade(1,0)
	fade(-1,10)
	music(0,1000)
end

function remove_enemys()
	music(-1,1000)
 music(0,1000)
 for m in all(objects) do
		if m!=p then
			del(enemy,m)
			del(objects,m)
		end
	end
	lastspawn=0
end

function victory()
--	pic=5
	remove_enemys()	
	lv=p.xp/nextlvl*8
	xptxt="xp:"
	for i=0,7 do
		if i<lv then
			xptxt=xptxt.."\3Ä"
		else
			xptxt=xptxt.."\1ê"
		end
	end
	for r=0,rnd(nummob) do
		loot()
	end
	lootcash=flr(rnd(nummob))
	cash+=lootcash
	if lootcash then
		print_table(p.namec.." \2grabs $"..cash)
	end
	if p.xp>=nextlvl then
		levelup()
		xptxt=xptxt.." "..p.namec.." \2lvl "..p.lvl.."!"	
	end
	create_action("continue",moving,"à","continue venturing")
	print_table(xptxt)
end

function loot()
	rnditem=getrnd(item_list)
	add(p.inventory,rnditem)
	print_table(p.namec.."\2 grabs "..rnditem.name)
end

function combat_menu()
	create_action("trick",tricks,64,"scare foes")
	create_action("treat",inventory,71,"eat candy")
--	create_action("trade",skills,80,"trade items")
	create_action("trace",scan,"à","look at stats")
	create_action("flee",flee,"â","run away, dropping candy")
end

function flee()
--	if rnd()>.25 then
		print_table(p.namec.." \2runs away!")
	 if #p.inventory!=0 then
		 lostitem=getrnd(p.inventory)
		 print_table(p.namec.." \2drops "..lostitem.name)
		 del(p.inventory,lostitem)
	 end
		remove_enemys()
		moving()
		progress-=3
--	else
--		print_table(p.namec.." \2fails to flee!")
--		return true
--	end
end

function scan()
	for obj in all(objects) do
		desc=obj.name
		.." á"..obj.hp.."/"..obj.maxhp
		.." í"..obj.mp.."/"..obj.maxmp
		.." è"..obj.dice.."-"..(obj.dice*obj.sides)
		create_action(
			obj.name,
			nil,
			"à",
			desc,
			0,
			single_target
		)
	end
	create_action("back",menu,'ó')
end

function tricks()
 pwr=p.dice*p.sides*-.5
	create_action(
		"parlor trick",
		function() 
			choose_target(attack,"spook",pwr) 
		end,
		65,
		"spook one for "..p.dice..'-'..(p.sides*p.dice)..' spook',
		pwr,
		all_enemys
	)
	pwr=p.dice*p.sides*-.25
	create_action(
		"cackle",
		multihit,
		68,
		"spook all for "..(p.dice*.5)..'-'..(p.sides*p.dice*.5),
		pwr,
		all_enemys
	)
	create_action(
		"leach",
		function() 
			choose_target(leach,"leach",pwr) 
		end,
		68,
		"leach "..(p.dice*.5)..'-'..(p.sides*p.dice*.5).." sugar",
		pwr,
		all_enemys
	)	
		create_action("back",menu,'ó')
end

function home()
	progress=0
	if p.hp>0 then
	 create_action("venture",moving,82,"venture out!")
	end
	create_action("rest",rest,81,"recover",999)
	create_action("shop",function() menu=home print_table(p.namec.." \2has $ "..cash) print_table("trader:\3welcome! anything strike \3your sweet tooth?") shop() end,"$$","buy more candy")
	pic=2
end

function getitem(item)
	if item.use=="eathp" then
		return "gain "..item.pwr.." spook",eat,select_player,{"hp"}
	elseif item.use=="eatmp" then
		return "gain "..item.pwr.." sugar",eat,select_player,{"mp"}
		end
end

function midshop()
	create_action("shop",function()print_table(p.namec.." \2has $ "..cash) print_table("trader:\3welcome! anything strike \3your sweet tooth?") shop() end,"$$")
	moving()
	menu=midshop
end

function shop()
	music(-1)
	music(16,1000)
	pic=1
 for v in all(item_list) do
  local desc=getitem(v)
 	create_action(v.name.." $"..v.price,browse,v.icon,desc,v)
 end
 create_action("talk",talk,"â","talk to the trader")
 create_action("back",menu,'ó')
end

function talk()
	print_table("trader:\3i sell candy for corn$")
	shop()
end

function browse(n,n,act)
	print_table("trader:\3i'll part with it for $"..act.pwr.price)
	create_action(act.pwr.pwr.."$ buy",buy,act.icon,act.desc,act.pwr)
	create_action("back",shop,'ó')
end

function buy(n,n,act)
	if cash>=act.pwr.price then
	 add(p.inventory,act.pwr)
	 print_table("bought "..act.pwr.name)
		cash-=act.pwr.price
		print_table(p.namec.." has \2$ "..cash)
	 shop()
	else
		return "not enough $"
	end
end
-->8
--stat manipulation
function recovermp(t,p)
	t.mp=mid(0,t.mp+p,t.maxmp)
--	print_table(t.name.."\2 eat "..i.name.." and gain "..i.pwr)
--	return true
	 stat_floater("+"..p,t,3)
end

function recoverhp(t,p)
--	printh(tostring(i))
	t.hp=mid(0,t.hp+p,t.maxhp)
	stat_floater("+"..p,t)
--	return true
end

function rest()
	print_table(p.namec.."\2 rest and recover hp")
	recoverhp(p,999)
--	recoverhp(p,0)
	recovermp(p,999)
	home()
end

function eat(t,n,i)
	if i.name=="candy corn" then
		recovermp(t,i.pwr)
	elseif i.name=="chocolate" then
		recoverhp(t,i.pwr)
	end
--	printh(tostring(i))
--	desc=i.desc or getitem(i)
--	print_table(p.namec.."\2 eat "..i.name.." and gain "..i.pwr)
	print_table(t.namec.." \2ate "..i.name..", "..i.desc)
--	printh(#t.inventory)
	for item in all(t.inventory) do
		if item.name==i.name then
		del(t.inventory,item)
		break
		end
	end
--	printh(#t.inventory)
--	printh(tostring(i))
	return true
end

function attack(a,d,mod)
	sfx(55)
	mod=mod or 1
 dam=ceil(roll(a.dice,a.sides,d.def)*mod)
-- d.hp=max(0,p.hp-dam)
 d.hp=mid(0,d.hp-dam,d.maxhp)
 d.flash+=8
 print_table(a.namec..'\2 trick '..d.name..'\2 for '..dam..'!')
-- print_table(a.namec..'\2 trick '..d.namec)
 if d.hp<=0 then
 	print_table(d.namec.." \2got spooked!")
 	d.flash+=32
 end
 stat_floater(-dam,d)
 printh(a.name.." rolled "..dam)
	return true
end

function roll(dice,side,def)
 local dmg = 0
	for i=1,dice do
		dmg+=ceil(rnd(side))
 end
 dmg-=min(def,0)
 return dmg
end

nextlvl=2
function levelup()
	nextlvl=nextlvl*2
--	levelup()+nextlvl*1.1
--	actions={}
--	print_table("+1 max spook and +1 max sugar")
--	moving()
--	create_action("spooky",moving,67,"+spook power")
--	create_action("nerves",nil,"á","+max spook")
-- create_action("grabby",nil,68,"+candy loot")
--	create_action("insuln",nil,66,"+max sugar")
	p.lvl+=1
	p.xp=0
	p.maxhp+=1
	p.hp=p.maxhp
	sfx(54)
--	p.mp=p.maxmp
end
-->8
--inventory

function inventory(n,n,act) 
 for v in all(p.inventory) do
-- 	local desc,use,over,mode=getitem(v)
 	create_action(v.name,v.use,v.icon,v.desc,v.pwr,v.over,v.mode)
 end
	create_action("back",menu,"ó","go back")
end



-->8
--skills
function multihit()
	if p.mp>=p.dice then
		for ene in all(enemy) do
			attack(p,ene,.5)
		end
		p.mp=max(p.mp-p.dice,0)
		return true
	end
	return "need more sugar"
end

function leach(a,d)
	local dam=min(roll(a.dice,a.sides),d.mp)
	 recovermp(a,dam)
	d.mp-=dam
	print_table(a.namec.." \2sucks \3"..dam.." \2sugar from "..d.namec)
	return true
end

function regen(a)
	dam=min(a.mp,a.maxhp-a.hp)
	recovermp(a,-dam)
	recoverhp(a,dam)
	print_table(a.namec.." \2gains "..dam.." spook from sugar")
	return true	
end

function candy(a)
	eat(a,1,getrnd(item_list))
end

function megaspook(m,p)
	attack(m,p,2)
	m.mp-=m.dice
end

function choose_target(act,desc,pwr,require)
 if #enemy==1 then 
 	act(p,enemy[1])
 	turn()
 else
	 print_table('who to target with '..desc..'?')
	 for s in all(enemy) do
	--  if require==nil or require(s)==true then
	  create_action(s.name,
	  function() 
	  act(p,s) 
	  return true end,
	  84,desc.." "..s.name,
	  pwr,
	  single_target
	  ) 
	--  end
	 end
	 create_action("back",menu,'ó')
	end
end

function defend(a,d)
--	local dam=max(roll(a.dice,a.sides),d.mp)
--	 recovermp(a,dam)
--	d.mp-=dam
	defbuff=ceil(roll(a.dice,a.sides)/2)
	a.def+=defbuff
	print_table(a.namec.." defends!")
	return true
end
-->8
function log()
 if (toggle or m_i<=#message_stack ) and #message_stack!=0 then
  f=0
  repeat
   smoothscroll() 
    f+=1
  until f>0 or m_i>=#message_stack
 end
end

function smoothscroll()
 ::scroll_label::
  local message=message_stack[m_i]
  if check_for_style(char) then
   goto scroll_label
  end
   if m_i<=#message_stack then
    if m_i+flr(m_y/font_height)==max_rows then
     m_y-=1
     toggle=true
    end
    m_i+=1
   end
 if  toggle then
  m_y-=1
  if m_i+ceil(m_y/font_height)<=max_rows then
   toggle=false
  end
 end
end


function draw_log()
 clip(0,console_y,console_width,max_rows*font_height)
 fsder=min(max_rows-ceil(m_y/font_height),m_i)
 for i=max(min(ceil(-m_y/font_height)-1,m_i),1),fsder do
  local messager=message_stack[i]
  if not messager then break end
  divide=1
  offset=0
  endoff=0
  textcolor=2
--  backcolor=0
  y=i*font_height+m_y+console_y
  for f=1, #messager do
    style=check_for_style(sub(messager,f,f))
    if style then
      font_function(sub(messager,divide,f),offset,y,textcolor)
      offset+=string_width(sub(messager,divide,f))*font_width
      textcolor=style
      divide=f+1
    elseif f==#messager then
     endoff=string_width(sub(messager,divide,#messager))*font_width+offset
     font_function(sub(messager,divide,f),offset,y,textcolor)
    end 
  end
 end
 clip()
end

function wavy_text(text,x,y,col)
  for i=1,#text do
   xr=x+string_width(sub(text,1,i))*font_width
   yr=y-abs((time()+xr)%(2*y)-y)/2
   font_function(sub(text,i,i),xr,y+yr,col)
  end
end

function grid_string(text)
 combine={}
 for i=0,ceil(#text/3) do
  local te=""
  for f=0,2 do
   local tex=text[f+i*3+1]
   if tex then
    te=te..increase(tex,10)
   end
  end
  add(combine,te)
 end
 return combine
end

function print_table(tab)
 if type(tab)=="string" then
  tab={tab}
 end
 foreach(tab,function(p) 
--  text=divide_text(p,max_columns+1)
--  printh(#text)
--  foreach(text,function(n)  add(message_stack,n) printh(n)  end)
  	add(message_stack,p)
  end)
end


function reset()
 m_i,
 m_t,
 m_y,
 c_i,
 com,
 com_index,
 com_stack,
 message_stack=
 1,--current index of text
 1,--current char
 0,--offset char y
 2,--cursor position player
 "> ",
 0,
 {},
 {}
 progress_bar=nil
  font_function=print
  font_height=6
  font_width=4
  max_rows=console_height/font_height
  max_columns=console_width/font_width
end
function reserve_rows(number)
 for i=1,number do
   print_table("")
 end
end

function refresh_rows(number)
 for i=#message_stack-max19,#message_stack do
  message_stack[i]=""
 end
end

-->8
--ai
function ai_action(m)
	local skills=m.skills
	while #skills!=0 do
		local choice=getrnd(skills)
--		printh("testing")
		if (choice==leach and (m.mp>=m.maxmp or p.mp<=0)) or
					(choice==megaspook and m.mp<m.dice)  or
					(choice==regen and (m.mp<=0 or m.hp>=m.maxhp))
		then
			del(skills,choice)
		else
					printh(m.name..tostr(choice==regen))
			choice(m,p)
			return
		end
	end
	printh("not found")
end
__gfx__
00033300000030000012200000011000000200000032300000333000001111103330000220000000000000333333000010102200000022000001120221110000
00332330000113000122120000023100002220000333330003211300001333101110002222000000000000222222000010102003333002000001122221110000
00323230001221303122222000232310002220003230123003111300111112103330003333000000000003333333300010102233333322000001332331330000
00332330012221003112222012323210033333003300011003111300133313103300033333300000000002222221000011102231331322000003333331130000
00133300312210003311221013232000033333002310121003111300122211100100011111100000303022221121000001000033333300000003121312130000
01000000031100000331110001320000111111100121110000020000133310002201111111111000333022222221000001000333113330000003111311130000
10000000003000000033300000110000011111000011200000020000111110000100331221330000313020111111000001003333223333000003333333330000
00000000000000000000000000000000000000000000000000000000000000000100322222230000010002211112200001033233333333300013331113331000
00003000000002200000200000001200000000003333333000001100003330000223112112113220010022222222220001333033333323300211333333311200
00001300000322200003020000001120000322003000003000001210031113000223111221113220013222222222222031330013331103300221111111112200
00111130033332000001002000333110002232301010101000013110312221300133111111113300223333313333333033300111111103300222222122222200
00121000113333000033102000323000002323201212121000131000312121300101111111111000220033313333333301001111111003300222222121222200
31111000111330000013300011333000003232201212121011310000312221300100033333300000010033313333302201001110111000000332222122223300
03100000011130000331330021100000001223001212121012100000031113000100011111100000010022222222202201000111011100000332222121223300
00300000001100003133133002100000010000001212121001100000003330000100111111110000010033313333300001000011001100000002222122220000
00000000000000000000000000000000100000000000000000000000000000000100111111110000010033313333300001000020002000000000110001100000
11200000000001000000010000002100003330000001110000111000000001000000022200000000010022222220000003330001111111100133333333000000
11210000000311100032211000010030032223000011100000030000000021100002222222000000120222222222000003230111111110000332222222222200
22222000002331000223230000010030322322300011100000222000000232000002222222000000120221222122000003330111111110000100011111111000
11211000033233000232320000310000132223100111110002232200002320000022122212200000120221212122000000101122222211000100112221110000
22221000013320000323220001300000113331100122110002232200023200000022122212200000030022222220000000101022222201000100120002100000
33332000111300001122300021000000011111000322330033222330112000000022122212200000031112222211100000101021221201000100120002100000
33333000010000000100000000000000001110001111111033333330010000000022222222200000031112121212222000101022222201000100112221100000
00000000000000000000000000000000000000000000000000000000000000000022221222203000031111111123311200100100220010000133311111330000
00321000002220000003330003333300000000000011100000000000011111000022222222203000032202222223311200103110000113000133332123333000
03211300022222000032223032222230102330100100010000010330133333100022222222202300030201121123311200303331111333103133312121333000
32113210332223300322231013333310123323103333333001022330133333100032222222222300232000222021133200311333333331112233332123333300
21132110333333303111311011111110033233003233323022211300122333100032222222222230220021111121133200221111111111112230332123303300
11321130133333101333110013222310132332103333333011111300122111100032222222222230030022111221133200201111111111113330332123302200
03211300111111103111300013222310103320103322233011133300000111100032222222222230030002111202222000300333333330023300333233302200
00113000011111000000000001111100000000000333330033300000000111000003322222233300030003000300000000300111111110220100033333300000
00000000000000000000000000000000000000000000000000000000000000000000033333300000030002000200000000100111111110000100003333330000
00000000000000000000000000000000000000000000000000000000000000001111100000011111000000222200000000011100001110000000011111100000
00010000000100001110010000001100010000000111111100111100000010002222110000112222000002222220000020001221122100020000111111110000
01111100011111001110010000011100100110000101110100011000001111000222211001122220000022222222000022201131131102220222222112222220
11111110101110101001110001111000001111000111111100100100001110000022211001122200000021311312000021222111111222120002232222322000
11010110111011101001110000110000011111000011111001111110011110000002110000112000000021112222000021211112211112120033222222223303
10000010011111000111100001010000001110000010101000111100001000000001110000111000000222222222000021211211112112123003223113223003
00000000000000000000000000000000000000000000000000000000000000000222110000112220002202211110000020212211112212023333123223213333
00000000000000000000000000000000000000000000000000000000000000002222110000112222020021122222000020002221122200003333111111113333
00000000000000000000000000000000000000000000000000000000000010000022211001122200000122211221200000111221122111001111113333111111
01111100110111101100110010101000001000000010100000010000000111000000211001120000002211222112110001111221122111101111112112111111
00000100110111101100110010110100001100001010110000000000001001100000111111110000022222111221222001111221122111101111113333111111
01010100000000001100110010111010001110001111111000111000010001000001221331221000222111222221222200111221122111001331112112111331
01000000111111101110111010110100001100001010110000000000110010000000021331200000111022200112022200011220022110002211123113211122
01111100100000101110111010101000001000000010100001111100011100000000000110000000022021000022022000112200002211002210123113210122
00000000000000000000000000000000000000000000000000000000001000000000000000000000020012000022020000333333333333001110231111320111
00000000000000000000000000000000000000000000000000000000000000000000000000000000020022000022020000222222222222001000231111320001
00011000000000000000000000000000000000000000000003330000220000000000000000000000000000022200000000000232222000000002200002200000
01100100001000000000000000000000000000000000000001110002222000000000000000000000020000022000001000000111111000000002000132231000
10010100101100000000000000000000000000000000000003330003333000000000000222000000020033322333001000022222222220000332330111111000
10101010100111100000000000000000000000000000000003300033333300000000000220000000220331333313301100003133331300003133313133312330
01010010110100000000000000000000000000000000000000100011111100000000033223300000200331333313300100003333333300003133313132312333
01001100010000000000000000000000000000000000000002201111111111000000333333330000220333333333301100001131131100003331333132312333
00110000000000000000000000000000000000000000000000100332222330000000331331330000020131311313101000000111111000000322331132311222
00000000000000000000000000000000000000000000000000100332222330000000333333330000220011111111001102222222222222200022111333331111
00000002000000003300003300000000333333300000000002223131223331000000113113110000200000212100000102222323323222200001111333331111
00000033300000003333333300000000111111100000000002223111113311100000011111100000201110212102220101032222222230100000001111111211
00000333330000000311113000000000130330100000000000133111111111100222000120001110201010212102020101003232232300100033333333333231
00002322232000000312213000000000132332100000000000101111111113300202222121111010201000212100020133303222222303330003333333333231
00002221222000000312213000000000111111100000000000101133333312200201112121222010201100212100220133000333333000330000001100001200
00000211120000000322223000000000133303100000000000100111111112200201011122202010200111212222200100000001100000000000002200001100
00000033300000003333333300000000133323100000000000100111111110000001000000002000220000212200001100000001100000000000003300002200
00003333333000003300003300000000111111100000000000100111111110000001000000002000022222211111111000000001100000000000003300003300
00033333333300000000000002222200022200000000000000000000000000000011101111011100000000012222000000000000000000000000000333300000
00232223222320000000000023333320233320000000000000000000000000000133311221133310000000112222000000000002200220000000000330000000
00222022202220000000000033333330331330000000000000000000000000001222111111112221000000111200000000000002200220000002222332222000
00020012100200000000000031111130311130000000000000000000000000001333122222213331000033111133000000000000222200000022222222222200
00000333330000000000000033333330331330000000000000000000000000000122133113312210003333311333330000000022223220000113333113333110
00033333333300000000000031111130031300000000000000000000000000000033111221113300033113333331133000000222222223000113113113113110
00333333333330000000000033333330033300000000000000000000000000000002112332112000331121333312113300002222222200000223333223333220
03333333333333000000000000000000000000000000000000000000000000000021222112221200331221333312213300022222222200300222222222222220
23222322232223203111113022222122000310000030030033002000203333000111121111211110333333333333333300222222222200300222232323232220
22202221222022202333332033333123003311000033330033033300231313300222122222212220331131333313113302222222222200300022323232322200
02000211120002003111113033333123000330000032230033111110233333301111121111211111133111111111133132222223222300300002222222222000
00000011100000003333333011111111033311100032233010322230203322332212122112212122133331111113333132222223222300300001331331331000
00000111110000001132311022122222003331000013331012122212311122331102112222112011223333333333332233222222222003300111332112331110
00001111111000003111113033123333333311110111111110111110203133220113111301110113220133333333102203222222222333001111132332311111
00111111111110003311133033123333000110000322222310011100003113200303011301100303020220000002202000022222221100001111112332113311
11111111111111100000000011111111000330000020002010011110001001000300221001220300000220000002200000002211000000001111112332111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333300333330000333300033003300033330003300330003333000033330003300330003333000330033000033000000000000000000000000000000000000
03333320333332000333320033203320033332003320332003333200033332003320332033333300332033200033200000000000000000000000000000000000
33333321333333103333331033213321333333103321332133333310333333103321332133333320332133210033210000000000000000000000000000000000
33333321333333203333332033213321333333203321332133333320333333203321332133333321332133210033210000000000000000000000000000000000
33222221332233213322332133213321332233213321332133222221332233213321332133223321332133210033210000000000000000000000000000000000
33211111332133213321332133213321332133213321332133211111332133213321332133213321332133210033210000000000000000000000000000000000
33210000332133213321332133213321332133213321332133210000332133213321332133213321332133210033210000000000000000000000000000000000
33210000332133213321332133213321332133213321332133210000332133213321332133213321332133210033210000000000000000000000000000000000
33333000333333213321332133332221333332213321332133210000333333213321332133213321333333210033210000000000000000000000000000000000
33333200333333213321332133332111333332113321332133210000333333213321332133213321333333210033210000000000000000000000000000000000
03333310333332213321332133332100333332103321332133210000333333213321332133213321333333210033210000000000000000000000000000000000
03333320333332113321332133332100333332103321332133210000333333213321332133213321033332210033210000000000000000000000000000000000
00223321332222103321332133223300332333103321332133213300332233213333332133213321003322110002210000000000000000000000000000000000
00013321332111103321332133213320332333203321332133213320332133213333332133213321003321100000110000000000000000000000000000000000
00003321332100003321332133213321332133213321332133213321332133213333332133213321003321000000000000000000000000000000000000000000
00003321332100003321332133213321332133213321332133213321332133213333332133213321003321000000000000000000000000000000000000000000
33333321332100003333332133213321332133213333332133333321332133213333332133213321003321000033000000000000000000000000000000000000
33333321332100003333332133213321332133213333332133333321332133213333332133213321003321000033200000000000000000000000000000000000
33333221332100000333322133213321332133210333322103333221332133213333332133213321003321000033210000000000000000000000000000000000
33333211332100000333321133213321332133210333321103333211332133210333322133213321003321000033210000000000000000000000000000000000
02222210022100000022221002210221022102210022221000222210022102210022221102210221000221000002210000000000000000000000000000000000
00111110001100000001111000110011001100110001111000011110001100110001111000110011000011000000110000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003000300000000000000000000000000002220000000000033333330000000000000000000000000022222220000000003232323000000000000000000000
00033000330000000000000200000000000002200000000000033333330000000000000000000000000222222222000000003333333000000000000000000000
00033000330000000000002220000000000332233300000000022222330000000000000000000000000222222222000000003333333000000000000000000000
00333333333000000000033333000000003333333330000000021112330000000000022022000000000212212222000000003133133000000000000000000000
00332222333300000000111111100000003133133330000000022122330000000000022222000000000222222220000000003133133000000000000000000000
00323223233300000011111111111000003333333330000000032123330000000000002220000000000022221000000000003133133000000000000000000000
00321221233300000000322223130000003311333330000000032123330000000000002220000000000022221000000000003333333000000000000000000000
00332222333100000003312213133000000333333300000000032123330000000000033333000000000003333300000000003333333000000000000000000000
00322112233110000003322223313000003111111111000000311111111100000003111111111000000311111111100000031111111110000000000000000000
01332222331110000003321122313000033133313332220003313331333222000033133313332220003313331333222000331333133322200000000000000000
01313223331110000033332223133000033133313332220003313331333222000033133313332220003313331333222000331333133322200033332222333300
01111333131111000031111313331000333133313332220033313331333222000333133313332220033313331333222003331333133322200033222222223300
01111331131131000111332213333100111133313332220011113331333222000111133313332220011113331333222001111333133322203332222222222333
01111131111131000111111311333100331333332223330033133333222333000331333332223330033133333222333003313333322233303033222222223303
01131111131111101111332211111110331333332223330033133333222333000331333332223330033133333222333003313333322233303333332222333333
01131111111111101111111311111110331333332223330033133333222333000331333332223330033133333222333003313333322233300333333333333330
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
9494949494000000000094949494949493939393939393939393939393939393949400939393939393939393939494949494940000000000000000000000949493930093939393729393939372939393000004000400040000040004000400004444444441444444414444444444444400000000000000000000000000000000
94949494940000000000009494949494930104010493008e8f00930401040193940000937474749292747474939494949494000084830083008300840094949493000074749300000000930000000093000000000000000000000000000000004444444144444441444444444444444400000000000000000000000000000000
94949494940000960000949494949494930104010493009e9f00930401040193949494930000000000000000930094949494940000000000000000000000949493000000000000009600000000920093000400040004000000000400040004004444414444444144444444444444444400000000000000000000000000000000
9494949400000000000094009494949493010401049393939393930401040193949494930000009600000000930094949494940083008384008300840094949493000000009300000000930000000093000000000000000000000000000000004441444444414444444444444444444400000000000000000000000000000000
9494949494000000000094949494949493939393939393939393939393939393949400930000000000000000930094949494000000000000960000000000949493939393939393000093939393939393000004000400040000040004000400004144444441444444444444444444444400000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9393939393939393939393939393939300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
930105050593008e8f0093939301019300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070710000000000000000000000007071
930501050593009e9f0093939301019300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080810000000000000000000000008081
9301010593939393939393939301019300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090917071000000000000000070719091
9393939393939393939393939393939300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070718081000000666700000080817071
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080819091000000767700000090918081
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090917071000000000000000070719091
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070718081000000000000000080817071
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080819091707100000000707190918081
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090917071808170717071808170719091
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002455526555285552b5552455526545285252b515185551a5551c5551f555185551a5451c5251f5152455526555285552b5552455526545285252b5153055532555345553755530555325453452537515
011000000e0500e0500c0500000010050100500c050000000c0500c050100500000010050100500c050000000c0500c05010050000000c0500e0500e050000000e0500e0500c050000000c0500c0500c05000000
01100000180501a0501c050000001c0501a0501805018000180501a0501a05018000180501a05018050180001c0501c0501a050180001a0501a05018050180001a0501a0501c05018000180501a0501a05000000
0110000027750277502d750327503275000000000000000032750327502d750277502775000000000000000027750277502d75027750277500000026750267502d75033750337500c0002d750327503275000000
0110000036750367503675030750307502c7502c75026750267500000025750257502b7502b7503175031750297502975021750217501d7001d7001d7501d750217502170027750277502d750327503275000000
00100000217502175021750187001f7501f7501f750187001d7551d7511d750187001c7551c7511c750187001f7501d7501c750187001f7541d7541c750187001c7501d7561f7501d7001f7501f7001f75000700
01200020097250752509725075250972507525097250552509725055250972505525097250552509725055250b525047250b525047250b525047250b525047250952505725095250572509525057250952505725
001000000550005500055510555104551025510055100551055000550005551055510455102551005510055105551055000555105551045510255100551005510550005500055510555104551025510055100551
000e00000062300613026230261300623006130262302613006230061302623026130462304613026230261300623006130462304613026230261304623046130062300613026230261304623046130262302613
001000002d2152e4252f5253a5253142532225325353b525332453352533255334552b55523455202453253520235214352243538535262152b5152f2153c515322252f5252a4352243533525212252242525545
01100000245552a505265552450524505245552650526555255052d505265552b5052855529505245052655529505285552450529505285552655524555245052f50526555255052855500000000000000000000
002000202c75031750297002470029700247002970024700287002f7002c7502f700327502f700287002f700267002d700267002d700267002d700267002d700287002f700287002f700287002f700287002f700
002000201d525247251d525247251d525247251d525247251c525237251c525237251c525237251c525237251a525217251a525217251a525217251a525217251c525237251c525237251c525237251c52523725
0010002015055177651305210765150551776213055107651105513765100520e7651105213765100550e7651305215765110550c7621305515765110520c7651105513762100550e7651105213765100550e762
002000201d52524525185241d52524525185241d525245251d52524525185241c52523525185241c525235251c52523525185241c52523525185241a525215251a52521525185241a52521525185241a52521525
001000000c0500e050100501105010050150501705015050150500c0500e05010050180001700017000100000c0000e0001000011000100001500017000100000c0000e000100001100010000150001700010000
001000200d7751377517775137750a775137751777513775097751377517775137750577513775177751377508775127751777512775097751277517775127750677512775177751277505775127751777512775
001000200f7721377217772137720f7721377217772137720e7721377217772137720d7721377217772137720c7721277217772127720c7721277217772127720d7721277217772127720d772127721777212772
0010002004772137621775213772057621375218772137520977213762177721375208762137721c7521976207772127521776212772077521277418762127720775212762177741275205762127721c75217762
001000200c7751377517775137750c7721377517775137750d7751377217775137750d7751377217775147750d7721277517775127750d7721277517775137720d7751277517772127750d775127721777213775
0010002007772137721777513775087721377518772137750977213772177721377508772137751c7721977507772127721777512772077721277518775127750777212772177751277505772127751c77217772
001000200f7751377517775137750f7751377517775137750e7751377517775137750d7751377517775137750c7751277517775127750c7751277517775127750d7751277517775127750d775127751777512775
00100020107051377517775137751070513775177751377538600137751777513775386001377517775137750f7051277517775127750f7051277517775127750f7051277517775127750f705127751777512775
00100020287051f775217751f775287051f7751d7751c775287051f7751d7751d775287051f7751d7002177527705217752f7051f775277052177521775217752177521775237752177528705217751d7001f775
001000002405026050240501c0002105023050210502300021050000001f05000000210500000021050210502105000000210501f05021050210002300021050000002305021050000001c050000000000000000
002500202b535305422f5622a55500502285452a5522a542285450050500505265452855228552265420050228555295552754526552265502755527562275552954529550275552656225555265452655000000
00110000215552355520555180051b5051e5551f5051c555195051b5551d5551a5552e505315051b55537505225551f5551c5551855513555285050d555345053d505265552a555285552655534505205552a505
00100000175501f550135501d550105501c5500d5501a550155501d550115501c5500e5501a5500c550185500b5001350007500115000450010500015000e500155001d500115001c5000e5001a5000c50018500
00100020107751377517775137751077513775177751377510775137751777513775107751377517775137750f7751277517775127750f7751277517775127750f7751277517775127750f775127751777512775
001d0a1e1d154231052215500105001051d1550010523155001051a105001051f1552175424145241051e1551e7542213500105207052113524714261451e1051f1552175423155217541d155000050000500004
002000201d525245251d525245251d525245251d525245251c525235251c525235251c525235251c525235251a525215251a525215251a525215251a525215251c525235251c525235251c525235251c52523525
001000000c055100551305517055180551a05517055180551a055180551c0551c0551c05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000c5550e5551055511555135551355513555105551055511555115551355513555105551555516555195501b550000001c550000001b55000000000000000000000000000000000000000000000000000
01010000105500f55015550185501a5501c5501d5501f5501f5501e5501c55019550165500e550125501655019550195501a5501a550145500f55011550125501355013550125500e55006550005500055000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000010551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002455726557285572b5572455726547285272b517315070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
010400001201014010170101c02021030260402a65026670246501d62018610106100c61008610066000160015b0015b0015b001f200000000000000000000000000000000000000000000000000000000000000
0006000022050200501d0501b0501d05018050170501a0501505014050160501105010050140500e0500d050100550b0450b04509035080350803507025060250501504015030150101500015000100011000110
001000000a751137511c751247512d751357513575135751007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
0001000009550075301850019500195001a5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010400001201014010170101c02021030260402a650266701c0502302029650246601c650146300c62007610016100061008600006000d6000000000000000000000000000000000000000000000000000000000
0004000019351153410f3312b5012450126501285012b501315010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501005010050100501
0008000010040130401a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000130401a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001054014540215000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
__music__
01 2c 42 43 44
00 2c 42 43 44
02 1a 42 43 44
00 26 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 2a 42 43 44
00 2a 42 43 44
00 23 42 43 44
02 1e 42 43 44
00 21 42 43 44
02 20 42 43 44
00 41 42 43 44
00 41 42 43 44
03 1b 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 0e 10 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
