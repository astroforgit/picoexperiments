pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--the demon within
--variables
function _init()
 t=0
 
 dpal=explodeval("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")

 dirx=explodeval("-1,1,0,0,1,1,-1,-1")
 diry=explodeval("0,0,-1,1,-1,1,1,-1")
 
 mob_name=explode("player,lesser demon,carnivorous slime,corrupt wizard,assasin,berserker")
 mob_ani=explodeval("240,244,224,208,228,196")
 mob_atk=explodeval("1,1,2,3,10,6")
 mob_hp =explodeval("10,3,4,6,1,7")
 mob_los=explodeval("4,4,3,4,10,3")
 mob_minf =explodeval("0,1,6,17,37,47")
 mob_maxf =explodeval("0,16,36,49,49,49")

 itm_name =explode("falchion sword,sweet potato,scimitar,earth magic scroll,green glowing peach,rat poison,moldy clothes,bronze chainmail,leather armor,bread,throwing dagger,rusty sword,apple,super fruit,poison vial,golden javelin,fireball magic scroll,lightning magic scroll,water magic scroll,golden platemail,trash,rotten food,cursed greaves,cursed vambraces,poisoned dagger,cursed helmet,cursed couter,bronze javalin,silver javalin,bowl o' soup,hurtful words,spiteful words,mystery meat")
 itm_type =explode("wep,fud,wep,mgc,fud,fud,arm,arm,arm,fud,thr,wep,fud,fud,fud,thr,mgc,mgc,mgc,arm,thr,fud,spl,spl,thr,spl,spl,thr,thr,fud,thr,thr,fud")
 itm_stat1=explodeval("3,2,2,3,-2,-1,0,0,0,2,3,1,3,10,-2,6,4,6,4,0,0,-1,-1,2,2,-1,-2,2,4,1,4,3,-2")
 itm_stat2=explodeval("0,0,0,0,0,0,0,3,1,0,0,0,0,0,0,0,0,0,0,5,0,0,2,-1,0,1,2,0,0,0,0,0,0")
 itm_minf =explodeval("15,0,0,13,13,13,13,16,0,0,5,0,10,25,0,20,13,26,19,25,30,23,26,37,37,37,37,37,37,37,37,37,37")
 itm_maxf =explodeval("23,0,0,30,23,23,15,23,8,14,27,10,30,33,4,30,20,37,23,32,36,50,32,40,40,40,40,40,40,40,40,40,40")
 crv_sig={0b11111111,0b11010110,0b01111100,0b10110011,0b11101001}
 crv_msk={0,0b00001001,0b00000011,0b00001100,0b00000110}
 
 wall_sig=explodeval("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
 wall_msk=explodeval("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")
 
 debug={}
 startgame()
end 


function _update60()
 t+=1
 _upd()
 dofloats()
 dohpwind()
end

function _draw()
 _drw()
 drawind()
 drawlogo()
 --fadeperc=0
 checkfade()
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end

function startgame()
 tani=0
 fadeperc=1
 buttbuff=-1
 
 logo_t=120
 logo_y=35
 
 skipai=false
 win=false
 winfloor=50
 mob={}
 dmob={} 
 p_mob=addmob(1,1,1)
 p_t=0
 
 inv,eqp,eqp={},{},{}
 makeipool()
 --takeitem(1)
  
 wind={}
 float={}
 
 talkwind=nil
 
 hpwind=addwind(5,5,36,13,{})
 
 thrdx,thrdy=0,-1
 
 _upd=update_game
 _drw=draw_game
 
 st_steps,st_kills,st_meals,st_killer=0,0,0,""
 
 genfloor(0)
 
 
 
end

--https://www.lexaloffle.com/bbs/?pid=46114 for binary help
--dirx each of the directional buttons represents
--how much you subtract or add {-x,x,y,y,lower corner,lower corner,upper corner,upper corner}
--wind==window pop-up
--p_ox=0==player tile movement offest
--p_t== a timer that runs & controls animation  
--starts at 0
--p_sox saves the starting positiom of the offset
--talkwind==popup window for talking to npc's
--mob_atk={1,1}={x,y} x,y=1 atk for two sprites
--mob_hp ={5,1}={x,y} x=spr1 hp,y=spr2 hp
--p_mob=addmob(1,1,1)=(x,y,z) x=enemy#, y=x location, z=y location
--cursor=sets text cursor somewhere
--dmob here means where mobs go to die
--dpal tell dofade function what color to transition to
--how much colors fade in transition
--inv here means inventory, eqp means equipment
--if nil value in eqp array means theres nothing there
--logo_t=240 will show for 240 frames
-->8
--updates
function update_game()
 if talkwind then
  if getbutt()==5 then
   talkwind.dur=0
   talkwind=nil
  end
 else
  dobuttbuff()
  dobutt(buttbuff)
  buttbuff=-1
 end
end

function update_inv()
 --inventory
 move_mnu(curwind)
 if btnp(4) then
  if curwind==invwind then
   _upd=update_game
   invwind.dur=0
   statwind.dur=0
   --$
  elseif curwind==usewind then
   usewind.dur=0
   curwind=invwind
  end 
 elseif btnp(5) then
  if curwind==invwind and invwind.cur!=3 then
   showuse()
   --&
  elseif curwind==usewind then  
  -- use window confirm
 triguse()
  end 
 end
end

function update_throw()
 local b=getbutt()
 if b>=0 and b<=3 then
  thrdx=dirx[b+1]
  thrdy=diry[b+1]
 end  
 if b==4 then 
  _upd=update_game
 elseif b==5 then
  throw()
 end
end

function move_mnu(wnd)
 if btnp(2) then
  wnd.cur=max(1,wnd.cur-1)
 elseif btnp(3) then
  wnd.cur=min(#wnd.txt,wnd.cur+1)
 end
end


function update_pturn()
 dobuttbuff()
 p_t=min(p_t+0.125,1)
 
 if p_mob.mov then
  p_mob:mov()
 end 
 --’
 if p_t==1 then
  _upd=update_game
  if trig_step() then return end
  
  if checkend() and not skipai then
   doai()
  end
  skipai=false
 end
end

function update_aiturn()
 dobuttbuff()
 p_t=min(p_t+0.125,1)
 for m in all(mob) do
  if m!=p_mob and m.mov then
   m:mov()
  end
 end
 if p_t==1 then
  _upd=update_game
  checkend()
 end
end

function update_gover()
 if btnp(—) then
  fadeout()
  startgame()
  reload(0x2000, 0x2000, 0x1000)
  copymap(0,0) 
  fog=blankmap(0)
 end
end

function dobuttbuff()
 if buttbuff==-1 then
  buttbuff=getbutt()
 end
end

function getbutt()
 for i=0,5 do
  if btnp(i) then
   return i
  end
 end
 return -1
end

function dobutt(butt)
 if butt<0 then return end
 if butt<4 then
  moveplayer(dirx[butt+1],diry[butt+1])
 elseif butt==5 then
  showinv()
  sfx(45) 
 elseif butt==4 then
-- p_mob.hp=0
 -- genfloor(floor+1)
 -- floormsg() 
 -- mapgen()
 end 
end

 
-- p_t+=min(p_t+x,w) x will control animation speed
--min will take 2 numbers & return the lower number from (1,2)
--mid will take 3 numbers & return the middle number (3,4,5)                               
--update_gover()==game over update
--thrdx means save dest x (dx) of throwable object
--b=btnp
-->8
--draws
function draw_game()
 cls(1)
 if fadeperc==1 then return end
 
 map()
 for m in all(dmob) do
  if sin(time()*8)>0 then
   drawmob(m)
  end
  m.dur-=1 
  if m.dur<=0 then
   del(dmob,m)
  end 
 end 
 
 for i=#mob,1,-1 do
  drawmob(mob[i])
 end
 
 if _upd==update_throw then
  --’ 
  local tx,ty=throwtile()
  local lx1,ly1=p_mob.x*8+3+thrdx*6,p_mob.y*8+3+thrdy*6
  local lx2,ly2=mid(0,tx*8+3,127),mid(0,ty*8+3,127)
  local thrani,mb=flr(t/7)%2==0,getmob(tx,ty)
  if thrani then
   fillp(0b0001001001001000)
  else
   fillp(0b0010010010010000)
  end
  line(lx1,ly1,lx2,ly2,12)
  fillp()
  oprint8("…",lx2-1,ly2-2,7,12)
  
  if mb and thrani then
   mb.flash=1
  end
 end
 
 for x=0,15 do
  for y=0,15 do
   if fog[x][y]==1 then
    rectfill2(x*8,y*8,8,8,1)
   end
  end
 end 
  
 for f in all(float) do
  oprint8(f.txt,f.x,f.y,f.c,0)
 end
end

function drawlogo()
 if logo_t>-100 then
  logo_t-=1
  if logo_t<=0 then
   logo_y+=logo_t/20
  end
  spr(128,19,logo_y,11,4)
  oprint8("survive and escape",26,logo_y+35,12,7)
 end
end

function drawmob(m)
 local col=7
 if m.flash>0 then
  m.flash-=1
  col=12
 end
 drawspr(getframe(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp)
end

function draw_gover()
 cls(1)
 
 print("your tale ends here.",25,21,7)
 print("press — to try again",22,73,7+(sin(time(2)/3*2)))
 color(6)
 print("slain by a(n) "..st_killer,6,33,6) 
 cursor(30,40)
 print("floor reached: "..floor)

 print("enemies slain: "..st_kills)
 print("food eaten   : "..st_meals)
 
end

function draw_win()
 cls(1)
 print("this is no exit. just an",15,8,7)
 print("entrance to more of the",16,16,7)
 print("labyrinth. that demon is",15,24,7)
 print("toying with me. curse him.",13,32,7)
 print("i don't think there truly is",9,40,7)
 print("an end to this place.",20,48,7)
 print("i begin to head back to the",10,56,7)
 print("abandoned safe room. i",19,64,7)
 print("find it stangely comforting.",10,72,7)
 color(6)
 cursor(30,90)
 print("enemies slain: "..st_kills)
 print("food eaten   : "..st_meals)
 print(" ")
 print("press — to accept your fate",8,118,7+(sin(time(2)/3*2)))

function animap()
 tani+=1
 if (tani<15) return
 tani=0
 for x=0,15 do
  for y=0,15 do
   local tle=mget(x,y)
   if tle==96 or tle==97 then
    tle+=1
  -- elseif tle==65 or tle==67 then
   -- tle-=1
   end
   mset(x,y,tle)
  end
 end
end

 --print("congratulations!",29,88,7)
 --print("you are one of 0.01% of",16,96,7)
 --print("players who cleared all",16,104,7)
 --print("50 floors! well done!",18,112,7)
end



--t=0 / 4 - 0 rest 0
--t=1 / 4 - 0 rest 1
--t=2 / 4 - 0 rest 2
--t=3 / 4 - 0 rest 3
--t=4 / 4 - 1 rest 0 
--t=5 / 4 - 1 rest 1
--you can divide t/15 to make frames
--use flr to fix frames if dividing flr(t/2)%4+1--slower
--each tile takes 8 pxls hence why *8
--*11,*6=(x,y) coord
--palt changes transparanceny of spr
--p_ox==player tile movement offest      
--line(p_mob.x,p_mob.y,p_mob.x+thrdx*16,p_mob.y+thrdy*16,12== 12 means color
--local lx1=line x 1
--fillp=fill pattern, fills objects and shapes
--format=fillp(0b010101)
--for binary 
--line(lx1+thrdy) == p_mob is moving in the opposite direction you are throwing
--local lx1=p_mob.x*8+3+thrdx*6-- thrdx*6=throwing line x offest from p_mob-- +3=throwing line start point
-- if t%2==0 means every 2nd frame will use fillp
--  spr(128,7,logo_y,14,3) 128=spr#,7 loc, logo_y=y loc, 14=w,3=h
--abs=absolute
-->8
--tools
function getframe(ani)
 return ani[flr(t/15)%#ani+1]
end
 
function drawspr(_spr,_x,_y,_c,_flip)
 palt(1,false)
 pal(6,_c)
 spr(_spr,_x,_y,1,1,_flip)
 pal() 
end

function rectfill2(_x,_y,_w,_h,_c)
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end
 print(_t,_x,_y,_c)
end 

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end  

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

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end  

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end  

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end 

function blankmap(_dflt)
 local ret={}
 if (_dflt==nil) _dflt=0
 
 for x=0,15 do
  ret[x]={}
  for y=0,15 do
   ret[x][y]=_dflt
  end
 end 
 return ret
end
   
function getrnd(arr)
 return arr[1+flr(rnd(#arr))]
end  

function copymap(x,y)
 local tle
 for _x=0,15 do
  for _y=0,15 do
   tle=mget(_x+x,_y+y)
   mset(_x,_y,tle)
   if tle==15 then
    p_mob.x,p_mob.y=_x,_y
   end
  end
 end
end

function explode(s)
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)=="," then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(_i+0))
 end
 return _retarr
end
   
--(_spr,_x,_y,1,1,) 1,1=1*1 tile sprite
--#ani pulls from previous animation array
--ani[flr(t/x) x=speed of animation
--(_spr,_x,_y,1,1,) 1,1=1*1 tile sprite
--here oprint8 prints text in outline prints text,8==thick outline
--function dist==here it calculates dist of () variables
--dofade here means color transition fade, slowly changes colors to black
--wait here means stop everything and wait for 'x' # frames
--fadeout how fast fading out and how long to wait
--getrnd(arr) returns a random entry from an array
-->8
--gameplay,collisions,sounds

function moveplayer(dx,dy)
 local destx,desty=p_mob.x+dx,p_mob.y+dy
 local tle=mget(destx,desty)
  
 if iswalkable(destx,desty,"checkmobs") then
  sfx(63)
  mobwalk(p_mob,dx,dy)
  st_steps+=1 
  p_t=0
  _upd=update_pturn
 else
  --not walkable
  mobbump(p_mob,dx,dy)
  p_t=0
  _upd=update_pturn
  
  local mob=getmob(destx,desty)
  if mob then
   sfx(58)
   hitmob(p_mob,mob)
  else
   if fget(tle,1) then
    trig_bump(tle,destx,desty)
   else
    skipai=true 
   end 
  end
 end
 unfog()
end

function trig_bump(tle,destx,desty)
 if tle==7 or tle==8 then
  --vase
  sfx(59)
  mset(destx,desty,1)
  if rnd(3)<1 then
   if freeinvslot()==0 then
	   showmsg("my bag's full",120)    
   else 
    local itm=getrnd(fipool_com)
    takeitem(itm)
    showmsg(itm_name[itm],60)
   end  
  end 
 elseif tle==6 then
  --stone tablet
--  if destx==4 and desty==1 then 
 --  showtalk({"you wake up dazed & confused.","you can only faintly make out","   your surroundings. you","  struggle to remember who","you are and how you got here."," the only thing you know is","      you need to find","     a way out of here."})
 --  sfx(61) 
-- elseif destx==10 and desty==9 then
 --  showtalk({" ","     i hear creatures..."," things... in the next floor."," "})
 --  sfx(61)
  if destx==7 and desty==1 then
   showtalk({" ancient carvings have been"," scrawled here. i can barely ","   make it out. i think it ","  says...arrow keys to move.","  to attack press arrow key","     facing the monster."," 'huh, wonder what it means'","     you say to yourself."})
   sfx(61)  
  end  
 elseif tle==10 or tle==12 then
  --chest
  if freeinvslot()==0 then
	  showmsg("my bag's full",120)
	  sfx(43)  
   skipai=true
  else
	  local itm=getrnd(fipool_com)  
   if tle==12 then 
    itm=getitm_rar()
   end 
	  sfx(61)
	  mset(destx,desty,tle-1)
	  takeitem(itm)
	  showmsg(itm_name[itm],60)
	 end 
 elseif tle==13 then
  --door
  sfx(62)
  mset(destx,desty,1)
 elseif tle==187 or tle==188 or tle==189 then
	 --end doorway
	 if floor==winfloor then
	  win=true
	 end	 
	elseif tle==96 then
  --tutorial npc
  if destx==13 and desty==3 then 
   showtalk({"   let me teach you how to","to throw items. first select","the item. press x and select","  throw. then press x again.","you'll see a line projecting","  where the item will land.","   press the arrow keys to","     change direction.","  finally press x to throw."})
   sfx(56)  
  elseif destx==4 and desty==9 then  
   showtalk({"  food in this place will"," heal you. open up your bag.","    press the x button."," select the food then press","      'x' to nom (eat),","      throw or discard."," finally press 'z' to exit."})
   sfx(56)  
  elseif destx==9 and desty==3 then  
   showtalk({"  hey newbie, you might of"," noticed how small your bag","   is. it can only hold 6","   items at a time, once"," it's full you can't pick up"," any more items, you'll have","   to discard some items."})
   sfx(56) 
  elseif destx==10 and desty==1 then  
   showtalk({"      i see you found","   some weapons and armor.","       open your bag.","    press 'x', select the"," weapon or armor then press","   'x' to equip, unequip","    or discard. finally","     press 'z' to exit."})
   sfx(56)    
  elseif destx==13 and desty==7 then  
   showtalk({"     you gotta learn how","    the enemies move and"," attack. it's all turn based.","you move once,they move once.","you attack once, they attack"," once. you eat an item once,","  they move or attack once.","   one action can be done"," each turn. be wary of that."})
   sfx(56)       
  end 
	elseif tle==64 then
  --cursed tutorial npc
  if destx==3 or destx==11 and desty==5 or 1 then 
   showtalk({"   you'll find some cursed","  armor soon. it is powerful","    armor that will help","    you. it has a small","  cost to one of your stats.","  beware! once equipped you","  cannot unequip the armor!"})
   sfx(56)  
  end 
	elseif tle==112 then
  --flr 1 armored npc 
  if destx==5 and desty==3 then 
   showtalk({"   you made it this far...","  you'd do well to call it","   quits here. it's safe."})
   sfx(56)
  elseif destx==13 and desty==5 then 
   showtalk({" ","        go bugger off."," "})
   sfx(56)   
  end     
	elseif tle==80 then
  --magic scroll hint npc 
  if destx==13 and desty==4 then 
   showtalk({" ","  keep an eye out for magic","scrolls in the deeper floors."," "})
   sfx(56)
  elseif destx==8 and desty==5 then 
   showtalk({"      i hear there is","      a powerful magic","       scroll deep in","       the dungeons."})
   sfx(56)   
  end              
 elseif tle==216 or tle==217 then
  --boss demon
  if destx==68 or 69 and desty==4 then 
   showtalk({"        hello mortal.","  i am neiter friend or foe.","   this dungeon, this place","        is my home.","  please do enjoy yourself..."})
   sfx(51)
  elseif destx==42 or 43 and desty==7 then 
   showtalk({" go ahead, the exit is right"," there. you do want to leave,","         don't you?"})
   sfx(51)
  elseif destx==84 or 85 and desty==5 then 
   showtalk({"  you look weary small one.","  you've done well to make","        it this far.","   an exit? why do you ask","  about that? you think i'd"," tell you where to find that?"})
   sfx(51)      
  end 
 elseif tle==123 or tle==124 or tle==233 then
  --blue lost soul
  if destx==1 or destx==2 and desty==3 or desty==2 then 
   showtalk({"      the exit is.. who","    are you? where is the","     grey man? he said if","     i'm good i can find","        my..my..my...","      where's the exit?","      and who are you?"})
   sfx(56)
  elseif destx==12 or destx==13 and desty==5 then 
   showtalk({"     man i could go for","      drink right now,"," i'm so thirsty. the tall man","    told me the exit is","       just up ahead.","    but i can't..i can't","      find the stairs...","       i'm so thirsty.."})
   sfx(56)   
  end     
 elseif tle==93 or tle==94 then
  --purple lost soul
  if destx==1 or destx==2 and desty==7 then 
   showtalk({"    all walk and no play","     makes me a dull boy.","    all walk and no play","     makes me a dull boy.","    all walk and no play","     makes me a dull boy.","    all walk and no play","     makes me a lull boy.","    all talk and no play","     makes me a dull boy.","    all walk and no play","     makes me a dull boy.","    all walk and no play","     makes me a dim boy."})
   sfx(56)  
  end    
 elseif tle==248 or tle==249 then
  --greater demon
  if destx==8 or 9 and desty==7 then 
   showtalk({"  do you enjoy the killing?","    you seem to be doing","      quite alot of it.","      you're a monster.","        heh heh heh."})
   sfx(51)
  end  
 elseif tle==121 then
  --messy clothes
  if destx==8 or 11 and desty==9 then 
   showtalk({"  messy clothes are strewn"," all across the room. they","  look quite worn and old."})
   sfx(56)
  end 
 elseif tle==85 then
  --messy table left
  if destx==6 and desty==6 then 
   showtalk({"    there's spoiled food","   on the table. it looks","      like juices are","   flowing down the table.","   did someone live in"," this room? was it recently?"," "})
   sfx(56)
  end 
 elseif tle==86 then
  --messy table right
  if destx==7 and desty==6 then 
   showtalk({" the smell is overwhelming.","      you try to hold","     back from vomiting."})
   sfx(56)
  end
 elseif tle==103 or tle==104 then
  --clothes dresser
  if destx==8 or 9 and desty==1 then 
   showtalk({"    a couple of dressers.","      they seem to be","      the only things.","     in the room that's","   not filthy. they're in","  supringly good condition."})
   sfx(56)
  end  
 elseif tle==73 or tle==74 then
  --messy bed 
  if destx==10 or 1 and desty==1 then 
   showtalk({"     a filthy bed. it's","   festering with mold and","   sweat stains. the smell"," is pretty bad, but bearable"," compared to the table food."," "})
   sfx(56)
  end 
 end   
end   
function trig_step()
 local tle=mget(p_mob.x,p_mob.y)

	 if tle==14 then
	  fadeout()
	  genfloor(floor+1)
	  floormsg()
	  return true
	 end 
	 if tle==3 then
	  showtalk({" ","    there's lost souls up","      against the walls.","      i wonder how long"," they wandered these floors.."," "})
	 end  
	 if tle==62 then
   showtalk({"you wake up dazed & confused.","you can only faintly make out","   your surroundings. you","  struggle to remember who","you are and how you got here."," the only thing you know is","      you need to find","     a way out of here."})
	 end 	 
	 if tle==63 then
	  showtalk({" ","     i hear creatures..."," things... in the next floor."," "})
	 end 	 	 
	 return false

end

function getmob(x,y)
 for m in all(mob) do
  if m.x==x and m.y==y then
   return m
  end
 end
 return false
end

function iswalkable(x,y,mode)
 local mode = mode or "test"
 
 --sight
 if inbounds(x,y) then
  local tle=mget(x,y)
  if mode=="sight" then
   return not fget(tle,2)
  else
   if not fget(tle,0) then
    if mode=="checkmobs" then
     return not getmob(x,y)
    end
    return true
   end
  end
 end
 return false
end

function inbounds(x,y)
 return not (x<0 or y<0 or x>15 or y>15)
end

function hitmob(atkm,defm,rawdmg)
 local dmg= atkm and atkm.atk or rawdmg
 
 local def=defm.defmin+flr(rnd(defm.defmax-defm.defmin+1))
 dmg-=min(def,dmg)
 
 defm.hp-=dmg
 defm.flash=10
 
 addfloat("-"..dmg,defm.x*8,defm.y*8,12)
 
 if defm.hp<=0 then
  if defm!=p_mob then
   st_kills+=1
   else
    st_killer=atkm.name 
   end

  add(dmob,defm) 
  del(mob,defm)
  defm.dur=25
--  local gold=flr(rnd(#gold_name))+1
  --takegold(gold)
 -- showmsg(gold_name[gold],60) 
--  local i=invwind.cur
--  local gold=eqp[i]
 
-- elseif gold_name=="1 gold" then
--  local slot=3
 -- eqp[slot]=gold  
  
-- invwind.cur=4
 end
end

function healmob(mb,hp)
 hp=min(mb.hpmax-mb.hp,hp)
 mb.hp+=hp
 mb.flash=10
 
 addfloat("+".. hp,mb.x*8,mb.y*8,12) 
end

function hurtmob(mb,hp)
 hp=min(mb.hpmax-mb.hp,hp)
 mb.hp+=hp
 mb.flash=10
 
 addfloat("".. hp,mb.x*8,mb.y*8,12) 
end

function checkend()
--’
 if win then
  wind={}
  _upd=update_gover
  _drw=draw_win
  fadeout(0.02)
  return false
 elseif p_mob.hp<=0 then
 wind={}
  _upd=update_gover
  _drw=draw_gover
  fadeout(0.02)
  return false
 end
 return true 
end 

function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true
 
 if dist(x1,y1,x2,y2)==1 then return true end
 if x1<x2 then
  sx,dx=1,x2-x1
 else
  sx,dx=-1,x1-x2
 end
 if y1<y2 then  
  sy,dy=1,y2-y1
 else
  sy,dy=-1,y1-y2
 end 
 local err,e2=dx-dy
 
 while not(x1==x2 and y1==y2) do
  if not frst and iswalkable(x1,y1,"sight")==false then return false end
  e2,frst=err+err,false
  if e2>-dy then
   err-=dy
   x1+=sx 
  end
  if e2<dx then
   err+=dx
   y1+=sy
  end
 end
 return true   
end 

function unfog()
 local px,py=p_mob.x,p_mob.y
 for x=0,15 do
  for y=0,15 do 
  --
   if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then
    unfogtile(x,y) 
   end  
  end
 end 
end

function unfogtile(x,y)
 fog[x][y]=0
 if iswalkable(x,y,"sight") then
  for i=1,4 do
   local tx,ty=x+dirx[i],y+diry[i]
   if inbounds(tx,ty) and not iswalkable(tx,ty,"sight") then
    fog[tx][ty]=0    
   end
  end 
 end
end

function calcdist(tx,ty)
 local cand,step,candnew={},0
 distmap=blankmap(-1)
 add(cand,{x=tx,y=ty})
 distmap[tx][ty]=0
 repeat
  step+=1 
	 candnew={}
	 for c in all(cand) do
	  for d=1,4 do
	   local dx=c.x+dirx[d]
	   local dy=c.y+diry[d]
	   if inbounds(dx,dy) and distmap[dx][dy]==-1 then 
	    distmap[dx][dy]=step
	    if iswalkable(dx,dy) then  
	     add(candnew,{x=dx,y=dy})
	    end   
	   end
	  end  
	 end 
	 cand=candnew
	until #cand==0 
end

function updatestats()
 local atk,dmin,dmax=1,0,0
 
 if eqp[1] then
  atk+=itm_stat1[eqp[1]]
 end

 if eqp[2] then
  dmin+=itm_stat1[eqp[2]]
  dmax+=itm_stat2[eqp[2]] 
 end
 
 if eqp[3] then
  dmax+=itm_stat2[eqp[3]]
  atk+=itm_stat1[eqp[3]]      
 end
 
 p_mob.atk=atk
 p_mob.defmin=dmin
 p_mob.defmax=dmax
end

function eat(itm,mb)
 local effect=itm_stat1[itm] 
 
 if mb==p_mob then st_meals+=1 end
 
 if effect==1 then
 --heal
  healmob(mb,1)
  sfx(53)
 elseif effect==2 then
 --heal
  healmob(mb,2)
  sfx(53) 
 elseif effect==3 then
 --heal
  healmob(mb,3)
  sfx(53)   
 elseif effect==10 then
 --heal
  healmob(mb,10)
  sfx(50) 
 elseif effect==-3 then
 --poison
  hurtmob(mb,-2)
  sfx(52)      
 elseif effect==-2 then
 --poison
  hurtmob(mb,-2)
  sfx(52) 
 elseif effect==-1 then
 --poison
  hurtmob(mb,-1)
  sfx(52)  
 end
end

function throw()
 local tx,ty=throwtile()
 local itm=inv[thrslt]
 
 if inbounds(tx,ty) then
  local mb=getmob(tx,ty)
  if mb then
   if itm_type[itm]=="fud" then
    eat(itm,mb)
    sfx(53)
   elseif itm_type[itm]=="mgc" and itm_name[itm]=="fireball magic scroll" then
    hitmob(nil,mb,itm_stat1[itm])
    sfx(49) 
   elseif itm_type[itm]=="mgc" and itm_name[itm]=="water magic scroll" then
    hitmob(nil,mb,itm_stat1[itm])
    sfx(48) 
   elseif itm_type[itm]=="mgc" and itm_name[itm]=="lightning magic scroll" then
    hitmob(nil,mb,itm_stat1[itm])
    sfx(47) 
   elseif itm_type[itm]=="mgc" and itm_name[itm]=="earth magic scroll" then
    hitmob(nil,mb,itm_stat1[itm])
    sfx(46)              
   else
    hitmob(nil,mb,itm_stat1[itm])
    sfx(54)
   end
  end
 end
 mobbump(p_mob,thrdx,thrdy)
 
 inv[thrslt]=nil
 p_t=0
 _upd=update_pturn
end

function throwtile()
 local tx,ty=p_mob.x,p_mob.y
 repeat
  tx+=thrdx
  ty+=thrdy
 until not iswalkable(tx,ty,"checkmobs")
 return tx,ty
end

--unfog(fx,fy) fy,fy==from x, from y
--addfloat("-"..dmg,defm.x*8,defm.y*8,12) 12=floater main color
--checkend here means game checks when you are about to expend hp
--xx() if returning, xx if just a function
--los here means line of sight for ai
--ternarray statement= x = [cond] and y1 or y2, if mode==nil then mode="" end
--local cand={}, here means local ai destination canidates
--dmg-=defm.defmin==you always subtract the defense minimum
--function throwtile()
--local tx,ty--tx,ty is target dest for throwable object
--showmsg(itm_name[itm],60)--60 means showing message for 60 frames
 
-->8
--ui, pop-up windows

function addwind(_x,_y,_w,_h,_txt)
 local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          txt=_txt}
 add(wind,w)
 return w
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  if w.cur then
   wx+=6
  end
  for i=1,#w.txt do
   local txt,c=w.txt[i],6
   if w.col and w.col[i] then
    c=w.col[i]
   end 
   
   print(txt,wx,wy,6)
   if i==w.cur then
    spr(255,wx-5,wy)
   end
   wy+=6
  end
  clip()
  
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/8
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("—",wx+ww-15,wy-1+sin(time()),6,0)
   end
  end
 end
end

function showmsg(txt,dur)
 local wid=(#txt+2)*4+3
 local w=addwind(63-wid/2,50,wid,13,{" "..txt})
 w.dur=dur                     
end

function showtalk(txt)
 talkwind=addwind(2,35,123,#txt*6+7,txt)                     
 talkwind.butt=true
end

function addfloat(_txt,_x,_y,_c)
 add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(float) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>70 then
   del(float,f)
  end
 end
end

function dohpwind()
 hpwind.txt[1]="‡"..p_mob.hp.."/"..p_mob.hpmax
 local hpy=5
 if p_mob.y<8 then
  hpy=110
 end
  hpwind.y+=(hpy-hpwind.y)/5 
end


function showinv()
 local txt,col,itm,eqt,eqt={},{},{}
 _upd=update_inv
 for i=1,2 do
  itm=eqp[i]
  if itm then
   eqt=itm_name[itm]
  else 
   eqt= i==1 and "[weapon]" or "[armor]" 
  end
  add(txt,eqt)  
 end
 for i=3,3 do
  itm=eqp[i]
  if itm then
   eqt=itm_name[itm]
  else 
   eqt= i==3 and "[cursed armor]"
  end 
  add(txt,eqt)
 -- color(2) 
 end 
 add(txt,"")
 for i=1,6 do
  local itm=inv[i]
  if itm then
   add(txt,itm_name[itm])   
  else
   add(txt,"")  
  end
 end
 
 invwind=addwind(1,17,104,70,txt)
 invwind.curmode=true
 invwind.cur=4
 
-- invwind.col=col
 
 statwind=addwind(1,5,84,13,{"atk: "..p_mob.atk.."  def: "..p_mob.defmin.."-"..p_mob.defmax})

 curwind=invwind
end

function showuse()
 local itm=invwind.cur<4 and eqp[invwind.cur] or inv[invwind.cur-4]
 if itm==nil then return end
 local typ,txt=itm_type[itm],{}
 
 if (typ=="wep" or typ=="arm" or typ=="spl") and invwind.cur>4 then 
  add(txt,"equip")
 end
 if typ=="fud" then
  add(txt,"nom")
 end
 if typ=="thr" or typ=="fud" then
  add(txt,"throw") 
 end 
 if typ=="mgc" then
  add(txt,"cast") 
 end  
 add(txt,"discard")

 
 usewind=addwind(84,invwind.cur*6+11,42,7+#txt*6,txt)
 usewind.cur=1
 curwind=usewind
end

function triguse()
 local verb,i,back=usewind.txt[usewind.cur],invwind.cur,true
 local itm=i<4 and eqp[i] or inv[i-4]
  
 if verb=="discard" then
  if i<4 then
   eqp[i]=nil  
  else 
   inv[i-4]=nil
   sfx(59)    
  end
 elseif verb=="equip" then
  local slot=2 
  if itm_type[itm]=="wep" then
   slot=1
   elseif itm_type[itm]=="spl" then
   slot=3 
   end 
   sfx(42)   
  inv[i-4]=eqp[slot]
  eqp[slot]=itm
 elseif verb=="nom" then
  eat(itm,p_mob)
  _upd,inv[i-4],p_mob.mov,p_t,back=update_pturn,nil,nil,0,false
 elseif verb=="throw" then
  _upd,thrslt,back=update_throw,i-4,false 
 elseif verb=="cast" then
  _upd,thrslt,back=update_throw,i-4,false 
 end
 
 updatestats() 
 usewind.dur=0
 
 if back then
  del(wind,invwind)
  del(wind,statwind)
  showinv()
  invwind.cur=i
 else  
  invwind.dur=0
  statwind.dur=0
 end 
end

function floormsg()
 showmsg("floor "..floor,120)
end
--clip contains any draw functions in array of the screen
--for i=1,#w.txt do==to know whixh line cureently drawing
--showmsg will be used to show text that disappears after a certain amount of time.
--showmsg(txt,dur) dur==how many frames text will appear
--rectfill2== modified rectfill
--local dif=w.h/4==for here represents how much box'll close in this frame
--for w in all(wind) do==loops thru all elements in 'w' array
--line of text is 6 pixels high hence why wy+=6
--text is 4 pixels wide.
--local wid==text width here
-- drawwind()==draw pop-up windows
--talkwind.butt=true displays windows that have icons that blinks that must press button to dismiss
--sin==goes between -1 & +1
--time==returns how many seconds game has been running
--function dofloats()==animates floating pop-ups
--ty==target y location
--showtmsg here means talking message
--update_inv here means game inventory
--addwind(5,5,84,13)-5,17=x,y--84=width--64=height
--triguse will trigger a use of an item
--eqp[1] is slot 1 for weapon
--local verb,i,after --after means when happens after verb[i] has been excuted
--"close"== animations for windows to shut down
--showmsg("floor "..floor,60)--60 means showing message for 60 frames
--cur==cursor position 
--col means color
-->8
--ai, mobs & items

function addmob(typ,mx,my)
 local m={
  x=mx,
  y=my,
  ox=0,
  oy=0,
  flp=false,
  ani={},
  flash=0,
  hp=mob_hp[typ],
  hpmax=mob_hp[typ],
  atk=mob_atk[typ],
  defmin=0,
  defmax=0,
  los=mob_los[typ],
  task=ai_wait,
  name=mob_name[typ]
 }
 for i=0,3 do
  add(m.ani,mob_ani[typ]+i)
 end
 add(mob,m)
 return m
end

function mobwalk(mb,dx,dy)
 mb.x+=dx --?
 mb.y+=dy

 mobflip(mb,dx)
 mb.sox,mb.soy=-dx*8,-dy*8
 mb.ox,mb.oy=mb.sox,mb.soy
 mb.mov=mov_walk
end

function mobbump(mb,dx,dy)
 mobflip(mb,dx)
 mb.sox,mb.soy=dx*8,dy*8
 mb.ox,mb.oy=0,0
 mb.mov=mov_bump
end


function mobflip(mb,dx)
 mb.flp = dx==0 and mb.flp or dx<0

end


function mov_walk(self)
 local tme=1-p_t 
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function mov_bump(self)
 --’
 local tme= p_t>0.5 and 1-p_t or p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function doai()
 local moving=false
 for m in all(mob) do
  if m!=p_mob then
   m.mov=nil
   moving=m.task(m) or moving
  end
 end
 if moving then 
  _upd=update_aiturn 
  p_t=0
 end
end

function ai_wait(m)
 if cansee(m,p_mob) then
  --aggro
  m.task=ai_attac
  m.tx,m.ty=p_mob.x,p_mob.y
  addfloat("!",m.x*8+2,m.y*8,12)
  sfx(56)
  return true
 end 
 return false		
end

function ai_attac(m)
 if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then
  --attack player
  local dx,dy=p_mob.x-m.x,p_mob.y-m.y
  mobbump(m,dx,dy)
  hitmob(m,p_mob)
  sfx(57)
  return true
 else
  --move to player
  if cansee(m,p_mob) then  
   m.tx,m.ty=p_mob.x,p_mob.y
  end  
  
  if m.x==m.tx and m.y==m.ty then
   --de aggro
   m.task=ai_wait
   addfloat("?",m.x*8+2,m.y*8,12)
   sfx(55)
  else 
   local bdst,cand=999,{}
   calcdist(m.tx,m.ty)
   for i=1,4 do
    local dx,dy=dirx[i],diry[i]
    local tx,ty=m.x+dx,m.y+dy
    if iswalkable(tx,ty,"checkmobs") then
     local dst=distmap[tx][ty]
     if dst<bdst then
      cand={}
      bdst=dst
     end
     if dst==bdst then
      add(cand,i)
     end
    end
   end
   if #cand>0 then
    local c=getrnd(cand)
    mobwalk(m,dirx[c],diry[c])
    return true
   end
  end
 end
 return false
end

function cansee(m1,m2)
 return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

function spawnmobs()
 mobpool={}
 for i=2,#mob_name do
  if mob_minf[i]<=floor and mob_maxf[i]>=floor then
   add(mobpool,i)
  end 
 end
 if #mobpool==0 then return end
 
 local minmons=3
 local placed,rpot=0,{}
 
 for r in all(rooms) do
  add(rpot,r)
 end
 
 repeat
  local r=getrnd(rpot)
  placed+=infestroom(r)
  del(rpot,r) 
 until #rpot==0 or placed>minmons
end

function infestroom(r)
 local target=1+flr(rnd(3))
 local x,y
 
 for i=1,target do
  repeat
   x=r.x+flr(rnd(r.w))
   y=r.y+flr(rnd(r.h))
  until iswalkable(x,y,"checkmobs")
  addmob(getrnd(mobpool),x,y)    
 end
 
 return target

end

-------------------------
-- items 
-------------------------

function takeitem(itm)
 local i=freeinvslot()
 if i==0 then return false end
 inv[i]=itm
 return true
end

function freeinvslot()
 for i=1,6 do
  if not inv[i] then
   return i
  end
 end
 return 0
end

function makeipool()
 ipool_rare={}
 ipool_com={}
 
 for i=1,#itm_name do
  local t=itm_type[i]
  if t=="nil" then
   add(ipool_rar,i)
  else
   add(ipool_com,i)
  end
 end
end

function makefipool()
 fipool_rare={}
 fipool_com={}
 
 for i in all(ipool_rar) do 
  if itm_minf[i]<=floor 
   and itm_maxf[i]>=floor then
   add(fipool_rare,i)
  end
 end
 for i in all(ipool_com) do 
  if itm_minf[i]<=floor 
   and itm_maxf[i]>=floor then
   add(fipool_com,i)
  end
 end
end

function getitm_rar()
 if #fipool_rare>3 then
  local itm=getrnd(fipool_rar)
  del(fipool_rar,itm)
  del(ipool_rar,itm)
 else
  return getrnd(fipool_com)
 end
end

--bdst=best distance,bx=best x value,by=best y value
--takeitem is active inventory
--freeinvslot loop thru inventory and look for free inventory slot
--rpot=roompot
--minmons=minimum amount of monsters
--makeipool gives rare status or common status to items
--makefipool the item pool for the current floor
--itm_minf mean if this item belongs on this floor
--function getitm_rar will allow you to have that item 3 times then it'll change to common items
-->8
--generation

function genfloor(f)
 floor=f
 makefipool()
 mob={}
 add(mob,p_mob)
 
 if floor==0 then 
  fog=blankmap(0)
  copymap(0,0)
 elseif floor==5 then
  copymap(63,0)
  fog=blankmap(0) 
 elseif floor==15 then 
  copymap(48,0) 
  fog=blankmap(0)  
 elseif floor==25 then 
  copymap(17,0)
  fog=blankmap(0) 
 elseif floor==33 then
  copymap(93,0)
  fog=blankmap(0)   
 elseif floor==40 then  
  copymap(78,0)
  fog=blankmap(0)     
 elseif floor==winfloor then
  copymap(32,0)
  fog=blankmap(0)
 else
  fog=blankmap(1)
  mapgen()
  unfog()
 end 
end

 
function mapgen()
 for x=0,15 do
  for y=0,15 do
   mset(x,y,2)
  end
 end

 rooms={}
 roomap=blankmap(0)
 doors={}
 genrooms()
 mazeworm()
 placeflags()
 carvedoors()
 carvescuts()
 startend()
 fillends()
 prettywalls()
 installdoors()
 
-- snapshot()
 spawnchests()
 spawnmobs()
 decorooms()
end 

--’
--function snapshot()
-- cls()
-- map()
-- flip()
--end
-----------------
--rooms
-----------------

function genrooms()
 -- tweak this
 local fmax,rmax=5,4
 local mw,mh=6,6
 
 
 repeat
  local r=rndroom(mw,mh)
  if placeroom(r) then 
   rmax-=1
  else
   fmax-=1
   if r.w>r.h then
    mw=max(mw-1,3)
   else 
    mh=max(mh-1,3)
   end 
  end
 until fmax<=0 or rmax<=0
 
end

function rndroom(mw,mh)
 --clamp max area
 local _w=3+flr(rnd(mw-2))
 mh=mid(35/_w,8,mh)
 local _h=3+flr(rnd(mh-2))
 return {
  x=0,
  y=0,
  w=_w,
  h=_h,
 }
end

function placeroom(r)
 local cand,c={}
 
 for _x=0,16-r.w do
  for _y=0,16-r.h do
   if doesroomfit(r,_x,_y) then
    add(cand,{x=_x,y=_y})
   end
  end
 end
 
 if #cand==0 then return false end
 
 c=getrnd(cand)
 r.x=c.x
 r.y=c.y
 add(rooms,r)
 for _x=0,r.w-1 do
  for _y=0,r.h-1 do
   mset(_x+r.x,_y+r.y,1)
   roomap[_x+r.x][_y+r.y]=#rooms		
  end
 end
 return true
end

function doesroomfit(r,x,y) 
 for _x=-1,r.w do
  for _y=-1,r.h do
   if iswalkable(_x+x,_y+y) then
    return false
   end
  end
 end

 return true
end

-----------------
--maze
-----------------

function mazeworm()
 repeat
  local cand={}
  for _x=0,15 do
   for _y=0,15 do
    if cancarve(_x,_y,false) and not nexttoroom(_x,_y) then
     add(cand,{x=_x,y=_y})  
    end
   end 
  end
  
  if #cand>0 then 
   local c=getrnd(cand)
   digworm(c.x,c.y)
  end
 until #cand<=1   
end

function digworm(x,y)
 local dr,stp=1+flr(rnd(4)),0
  
 repeat   
  mset(x,y,1)
  if not cancarve(x+dirx[dr],y+diry[dr],false) or (rnd()<0.5 and stp>=2) then
   stp=0
   local cand={}
   for i=1,4 do
    if cancarve(x+dirx[i],y+diry[i],false) then
     add(cand,i)
    end
   end
   if #cand==0 then
    dr=8
   else
    dr=getrnd(cand) 
   end
  end
  x+=dirx[dr]
  y+=diry[dr] 
  stp+=1
 until dr==8
 
end



function cancarve(x,y,walk)
 if not inbounds(x,y) then return false end
 local walk= walk==nil and iswalkable(x,y) or walk

 if iswalkable(x,y)==walk then
  local sig=getsig(x,y)
  for i=1,#crv_sig do
   if bcomp(sig,crv_sig[i],crv_msk[i]) then
    return true
   end
  end
 end
 return false
end

function bcomp(sig,match,mask)
 local mask=mask and mask or 0
 return bor(sig,mask)==bor(match,mask)
end
 
function getsig(x,y)
 local sig,digit=0
 for i=1,8 do
  local dx,dy=x+dirx[i],y+diry[i]
  --’
  if iswalkable(dx,dy) then
   digit=0
  else
   digit=1
  end
  sig=bor(sig,shl(digit,8-i))
 end
 return sig
end
-----------------
-- doorways
-----------------

function placeflags()
local curf=1
 flags=blankmap(0)
 for _x=0,15 do
  for _y=0,15 do
   if iswalkable(_x,_y) and flags[_x][_y]==0 then
    growflag(_x,_y,curf)
    curf+=1
   end
  end
 end
end

function growflag(_x,_y,flg)
 local cand,candnew={{x=_x,y=_y}}
 flags[_x][_y]=flg
 repeat
  candnew={}
  for c in all(cand) do
   for d=1,4 do
    local dx,dy=c.x+dirx[d],c.y+diry[d]
    if iswalkable(dx,dy) and flags[dx][dy]!=flg then
     flags[dx][dy]=flg
     add(candnew,{x=dx,y=dy})
    end
   end
  end
  cand=candnew
 until #cand==0
end


function carvedoors()
 local x1,y1,x2,y2,found,_f1,_f2,drs=1,1,1,1
 repeat
  drs={}
  for _x=0,15 do
   for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y)
     found=false
     if bcomp(sig,0b11000000,0b00001111) then
      x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then
      x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
     end
     _f1=flags[x1][y1]
     _f2=flags[x2][y2]
     if found and _f1!=_f2 then
      add(drs,{x=_x,y=_y,f=_f1})
     end
    end
   end
  end
  
  if #drs>0 then
   local d=getrnd(drs)
   --’
   add(doors,d)
   mset(d.x,d.y,1)

   growflag(d.x,d.y,d.f)  
  end
 until #drs==0
end

function carvescuts()
 local x1,y1,x2,y2,cut,found,drs=1,1,1,1,0
 repeat
  drs={}
  for _x=0,15 do
   for _y=0,15 do
    if not iswalkable(_x,_y) then
     local sig=getsig(_x,_y)
     found=false
     if bcomp(sig,0b11000000,0b00001111) then
      x1,y1,x2,y2,found=_x,_y-1,_x,_y+1,true
     elseif bcomp(sig,0b00110000,0b00001111) then
      x1,y1,x2,y2,found=_x+1,_y,_x-1,_y,true
     end
     if found then
      calcdist(x1,y1)
      if distmap[x2][y2]>20 then
       add(drs,{x=_x,y=_y})
      end
     end
    end
   end
  end
  
  if #drs>0 then
   local d=getrnd(drs)
   add(doors,d)
   mset(d.x,d.y,1)
  -- snapshot()
   cut+=1
  end
 until #drs==0 or cut>=3
end

function fillends()
 local filled,tle
 repeat
  filled=false
  for _x=0,15 do
   for _y=0,15 do
    tle=mget(_x,_y)
    --’
    if cancarve(_x,_y,true) and tle!=14 and tle!=15 then
     filled=true
     mset(_x,_y,2)
     --snapshot()
    end
   end
  end
 until not filled
end

function isdoor(x,y)
 local sig=getsig(x,y)
 if bcomp(sig,0b11000000,0b00001111) or bcomp(sig,0b00110000,0b00001111) then
  return nexttoroom(x,y)
 end
 return false
end

function nexttoroom(x,y)
 for i=1,4 do
  if inbounds(x+dirx[i],y+diry[i]) and 
     roomap[x+dirx[i]][y+diry[i]]!=0 then
   return true
  end
 end
 return false
end

function installdoors()
 for d in all(doors) do
  if mget(d.x,d.y)==1 or mget(d.x,d.y)==4 and isdoor(d.x,d.y) then
   mset(d.x,d.y,13)
  end
 end
end


-----------------
-- decoration
-----------------

function startend()
 local high,low,px,py,ex,ey=0,9999
 repeat
  px,py=flr(rnd(16)),flr(rnd(16))
 until iswalkable(px,py)
 calcdist(px,py)
 --’
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if iswalkable(x,y) and tmp>high then
    px,py,high=x,y,tmp
   end
  end
 end 
 calcdist(px,py)
 high=0
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if tmp>high and cancarve(x,y) then
    ex,ey,high=x,y,tmp
   end
  end
 end
 mset(ex,ey,14)
 
 for x=0,15 do
  for y=0,15 do
   local tmp=distmap[x][y]
   if tmp>=0 and tmp<low and cancarve(x,y) then
    px,py,low=x,y,tmp
   end
  end
 end  
 --’
 mset(px,py,15)
 p_mob.x=px
 p_mob.y=py
end

function next2tile(_x,_y,tle)
 for i=1,4 do
  if inbounds(_x+dirx[i],_y+diry[i]) and mget(_x+dirx[i],_y+diry[i])==tle then
   return true
  end
 end
 return false
end

function prettywalls()
 for x=0,15 do
  for y=0,15 do
   local tle=mget(x,y)
   if tle==2 then
    local sig,tle=getsig(x,y),3
    for i=1,#wall_sig do
     if bcomp(sig,wall_sig[i],wall_msk[i]) then
      tle=i+15
      break
     end
    end
    mset(x,y,tle)
   elseif tle==1 then
    if not iswalkable(x,y-1) then
     mset(x,y,4)     
    end
   end
  end
 end
end

function decorooms()
 for r in all(rooms) do
  local funcs,func={
   deco_torch
  }
  func=getrnd(funcs)
  
  for x=0,r.w-1 do
   for y=1,r.h-1 do
    func(r,r.x+x,r.y+y+y,x,y)
   end 
  end
 end 
end

--function deco_carpet(r)
-- for x=0,r.w-1 do
--  for y=0,r.h-1 do
--   if x>0 and y>0 and x<r.w-1 and y<r.h-1 then  
--    mset(r.x+x,r.y+y,140)
--   end 
--  end
-- end 
--end

--function deco_dirt(r)
-- for x=0,r.w-1 do
--  for y=0,r.h-1 do
 --   mset(r.x+x,r.y+y,142)  
 -- end
-- end 
--end
function deco_torch(r,tx,ty,x,y)
 if y%2==1 and not next2tile(tx,ty,12) and not next2tile(tx,ty,10) and not next2tile(tx,ty,12) and not next2tile(tx,ty,13) and not next2tile(tx,ty,16) and not next2tile(tx,ty,17) and not next2tile(tx,ty,18) and not next2tile(tx,ty,34) and not next2tile(tx,ty,50) and not next2tile(tx,ty,49) and not next2tile(tx,ty,48) and not next2tile(tx,ty,32) and not next2tile(tx,ty,19) and not next2tile(tx,ty,20) and not next2tile(tx,ty,36) and not next2tile(tx,ty,35) and not next2tile(tx,ty,51) and not next2tile(tx,ty,52) and not next2tile(tx,ty,21) and not next2tile(tx,ty,22) and not next2tile(tx,ty,23) and not next2tile(tx,ty,24) and not next2tile(tx,ty,25) and not next2tile(tx,ty,26) and not next2tile(tx,ty,27) and not next2tile(tx,ty,28) and not next2tile(tx,ty,29) and not next2tile(tx,ty,30) and not next2tile(tx,ty,31) and not next2tile(tx,ty,37) and not next2tile(tx,ty,38) and not next2tile(tx,ty,39) and not next2tile(tx,ty,40) and not next2tile(tx,ty,41) and not next2tile(tx,ty,42) and not next2tile(tx,ty,43) and not next2tile(tx,ty,44) and not next2tile(tx,ty,45) and not next2tile(tx,ty,46) and not next2tile(tx,ty,47) and not next2tile(tx,ty,53) and not next2tile(tx,ty,54) and not next2tile(tx,ty,55) and not next2tile(tx,ty,56) and not next2tile(tx,ty,57) and not next2tile(tx,ty,58) and not next2tile(tx,ty,59) and not next2tile(tx,ty,60) and not next2tile(tx,ty,61) then
	 if x==0 then
	  mset(tx,ty,155)
	 elseif x==r.w-1 then
	  mset(tx,ty,139)
  end
 end
end

function spawnchests()
 local chestdice,rpot,rare,place=explodeval("1,1,1,1,2,2,3"),{},true
 place=getrnd(chestdice)
 
 for r in all(rooms) do
  add(rpot,r)
 end
 
 while place>0 and #rpot>0 do 
  local r=getrnd(rpot)
  placechest(r,rare)
  rare=false
  place-=1
  del(rpot,r)
 end 
end

function placechest(r,rare)
 local x,y 
 repeat
  x=r.x+flr(rnd(r.w-2))+1
  y=r.y+flr(rnd(r.h-2))+1
 until mget(x,y)==1 and not next2tile(x,y,13)  
 if rare then
  mset(x,y,12)
 else
  mset(x,y,10) 
 end
end
--rndroom(5,5)--5,5=max x & y space for room
--rndroom(mw,mh)--mw=max width,mh=max height
--w=3+flr=max min w of 3, +flr will make space for object
--c=getrnd(cand) will get us a random room from our position if it is suitable
--fmax,rmax here will controls how many times try to place room,fmax=how many failures we can have,rmax=how many rooms to be placed
--mh=max(35/w,3)==max height will equal 35/width and reach a value smaller than 3 
--shl=shift left
--bcomp here means binary comparison
--sig the tile signature that came out of getsig 
--match means the match the binary we are checking against
--dr means direction
--curf means current flag
--carvescuts means carve shortcuts in map
-- if distmap[x2][y2]>15, 15 is frequency of shortcuts
--fillends carves out exits to deadends
--stat(0) returns how much memory we are using
--px,py means player x/y position
--ex,ey means exit x/y position
--flip() shows one frame
--break will cancel loops
--del(rpot,r) to prevent multiple chests from spawing in same room
__gfx__
000000000000000055550050000000005555005055550050cccccccc00ccc00000ccc00000000000000000000000000000ccc000c0ccc0c00000000000000000
000000000000000000000000000000000000000000000000c000000c0c000c000c000c00055555500cccccc055555550c0ccc0c0000000000000000000000000
007007000000000055055550000000005505555050000050c0cc0c0c0c000c000c000c00050000500c0000c050000050c00000c0c0ccc0c0c000000050000000
0007700000000000000000000000000000000000000000000000000000ccc000c0ccc0c0050000500c0cc0c050000050c00c00c000ccc000c0c0000050500000
000770000000000055550050000000000000000050000050c000000c0c00cc00cc00ccc0055555500cccccc055555550ccc0ccc0c0ccc0c0c0c0c00050505000
007007000000000000000000000000000000000000000000c0c0cc0c0ccccc000ccccc000000000000000000000000000000000000ccc000c0c0c0c050505050
000000000005000050055550000500000005000050055550c000000c00ccc00000ccc000055555500cccccc055555550ccccccc0c0ccc0c0c0c0c0c050505050
000000000000000000000000000000000000000000000000cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005555550555555000555555005555500555555005550555055555550000055505550000055555550000055500000555055500000
00000000000000000000000055555550555555505555555055555550555555505550555055555550000055505550000055555550000055500000555055500000
00000000000000000000000055555550555555505555555055505550555555505550055055555550000005505500000055555550000055500000055055500000
00000000000000000000000055500000000055505550000055505550000055505550000000000000000000000000000000000000000055500000000055500000
00000050555555505000000055500000000055505550555055505550555055505550055055000550550005505500055000000550550055505555555055500550
00000550555555505500000055500000000055505550555055505550555055505550555055505550555055505550555000005550555055505555555055505550
00005550555555505550000055500000000055505550555055505550555055505550555055505550555055505550555000005550555055505555555055505550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005550055555005550000055500000000055500555555055505550555555005550555055505550555055505550555055505550555000005550555055555550
00005550555555505550000055500000000055505555555055505550555555505550555055505550555055505550555055505550555000005550555055555550
00005550555555505550000055500000000055505555555055000550555555505500055055005550550005505500055055500550550000005500555055555550
00005550555055505550000055500000000055505500000000000000000005500000000000005550000000000000000055500000000000000000555000000000
00005550555555505550000055555550555555505555555055000550555555505555555055005550000005505500000055500000555555500000555055000000
00005550555555505550000055555550555555505555555055505550555555505555555055505550000055505550000055500000555555500000555055500000
00005550055555005550000005555550555555000555555055505550555555005555555055505550000055505550000055500000555555500000555055500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005550555555505550000055555550555055505550555055505550555055500000555055500000000055500000000055505550555000000000000000000000
00000550555555505500000055555550555055505550555055505550555055500000555055500000000055500000000055505550555000000000000000000000
00000050555555505000000055555550555055505550555055505550555055500000055055000000000005500000000055000550550000000000000000000000
00000000000000000000000000000000555055505550000055505550000055500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055555550555055505555555055505550555555505500000000000550000005505500055000000000550000000000000000000000
00000000000000000000000055555550555055505555555055555550555555505550000000005550000055505550555000000000555000000000000000000000
00000000000000000000000055555550555055500555555005555500555555005550000000005550000055505550555000000000555000000005000000050000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070000000000000000000000000000000000000000000000000000000000000000056666666666666500000000000000000000000000000000000000000
0ddd007000000000000000000000000000000000000000000000000000000000000000000061616161616000000000000000000000000000d000000000000000
0ddd0000000000000000000000000000000000000000000000000000000000000000000055616161616165500000000000005000000d00ddd00d000700000000
0ddd0070000000000000000000000000000000000000000000000000000000000000000000617a77777160000000005555555500000000dd000d000700000000
ddddd0000000000000000000000000000000000000000000000000000000000000000000006677aaa7a660000000055656655500000d0dddd0ddd00700000000
ddd0d000000000000000000000000000000000000000000000000000000000000000000000557a777a755000000055655556655000dd0dd7ddddd00000000000
0ddd000000000000000000000000000000000000000500000000000000000000000000000035555555555000000555655655566000dd7d777dd7d00700000000
0d0d0000000000000000000000000000000000000000000000000000000000000000000000555553355550000055665555665550000d7776677dd00000000000
00dd00070000000000000000000000000000000000666666bb666600000000000000000000353335553550000055555565555550000dd766667dd00000000000
0ddd000700000000000000000000000000000000006666666bb56600000000000000000000355553355330000055556655555505000d77766677dd0d00000000
ddddd700000000000000000000000000000000000066665665bb560000000000000000000055533555555000055556555500000000dd77666667dd0d00000000
0ddd0707000000000000000000000000000000000066b5b665bb560000000000000000000066666666666000056555555000000000ddd6776676dd0000000000
ddddd700000000000000000000000000000000000066bbb6665566005555555055555550006161616161600055565555500000000000d776667dd00000000000
ddd0d700000000000000000000000000000000000066bbb66666660055666666666665500061616161616000055655655500000000d0dd76767d000000000000
0ddd0700000000000000000000000000000000000066666666666600556666666666655000666666666660000055555555500000000d00d6d6d0d00000000000
0d0d0700000000000000000000000000000000000006000000006000006666666666600000600000000060000000555500000000000000000000000000000000
ddddd0070dddd0070000000000000000000000000500000000000000556666666666605000565500005565000000000000000000000000000000000000000000
11717107071710070000000000000000000000000550000000000000005555555555500005655000055565500000000000000000000000000000000000000000
dddddd000dddd000000000000000000000000000050566660000000055665665665665500555056005656550000000cc00000007000000000000000000000000
ddddd0070dddd00700000000000000000000000005006666000000000066666566666000565566555656555000cc000000000007000000000000000000000000
0011000000110000000000000000000000000000055066660000000000555555555550005656555055555650000cc00c0000c007000000000000000000000000
0dddd0000dddd000000000000000000000000000000566660000000000666666666660005555555005556500000cccccc000c000000000000000000000000000
d0dd0d00d0dd0d00000000000000000000000000000500050000000000555555555550000555000005565500000c7cc7cccc0007000000000000000000000000
0d00d0000d00d000000000000000000000000000000000000000000000665665665660000000000000555000000cc77557ccc000000000000000000000000000
0000000700000000000000000000000000000000000000500555555000666665666660000000000000000000000cc75555ccc000000000000000000000000000
000770070000000000000000000000000000000000000550005005000055555555555000055550000055500000cc7755577cc000000000000000000000000000
007777000000000000000000000000000000000066665050005005000066666666666000555565500555550000cc7555557cc000000000000000000000000000
00ddd0070000000000000000000000000000000066660050006666000000000000000000666556555655666000cc5755775cc000000000000000000000000000
0ddddd0000000000000000000000000000000000666605500066660000000000000000005556556555555560000cc755577cc000000000000000000000000000
d0dd00d0000000000000000000000000000000006666500000666600000000000000000055655555055665500000cc5757cc0c00000000000000000000000000
007770000000000000000000000000000000000050005000006666000005000000050000055655500055550000c00c5c5c00cc00000000000000000000000000
00707000000000000000000000000000000000000000000000500500000000000000000000055000005650000000000000000000000000000000000000000000
00000000007777777777777777777777777777777777777777777777777777777777777777000000000000000000777005005000555500500500500005000000
000000000077ddddddd7ddd77dd7ddddd77ddddd777ddddd7dddd77dd7dddddd7ddd77dd77000000000000000007777750050050000000000005005050000000
000000000077dcccccc7dcc77cc7dcccc77dcccc777dcccc7dccd77cc7dccccc7dcc77cc77000000000000000005575570500500550555500000000000500000
000000000077dcccccc7dcc77cc7dcccc77dccccc77dcccc7dccdd7cc7dcc7cc7dcc77cc77000000000000000007757775005000000000000000500005005000
000000000077dddcc777dcc77cc7dcc7777dccdcc77dcc777dcccdccc7dcc7cc7dccc7cc77000000000000000007777750050050500500505000005050050050
00000000007777dcc777dcc77cc7dcc7777dccd7cc7dcc777dcccdccc7dcc7cc7dccc7cc77000000000000000000707000500500005005000050000000500000
00000000007777dcc777dcc77cc7dcc7777dccd7cc7dcc777dccccccc7dcc7cc7dcccccc77000000000000000000000005005000050050000500500000005000
00000000000077dcc777dcc77cc7dcc7777dccd7cc7dcc777dccccccc7dcc7cc7dcccccc77000000000000000000000000000000000000000000000000000000
00000000000077dcc777dcccccc7dcccc77dccd7cc7dcccc7dccdc7cc7dcc7cc7dcc7ccc77000000000000000000000000000070000000000000000000000000
00000000000077dcc777dcc77cc7dcc7777dccd7cc7dcc777dccdc7cc7dcc7cc7dcc7ccc77000000000000000070000000000077000000000000000000000000
00000000000077dcc777dcc77cc7dcc7777dccd7cc7dcc777dccd77cc7dcc7cc7dcc77cc77000000000000000770000000000700000000000000000000000000
00000000000077dcc777dcc77cc7dcc7777dccd7cc7dcc777dccd77cc7dcc7cc7dcc77cc77000000000000000007000000007000000000000000000000000000
00000000000077dcc777dcc77cc7dcc7777dccdcc77dcc777dccd77cc7dcc7cc7dcc77cc77000000000000000000770000000000000000000000000000000000
00000000000077dcc777dcc77cc7dcccc77dccccc77dcccc7dccd77cc7dcc7cc7dcc77cc77000000000000000000700000000000000000000000000000000000
00000000000077dcc777dcc77cc7dcccc77dcccc777dcccc7dccd77cc7dccccc7dcc77cc77000000000000000000000000000000000000000000000000000000
00000000000077777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000000
00000000000077777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000000
00000000000000000000077ddd777dd7ddd7ddddddd7ddd77dd7ddd7dddd7dd77000000000000000000000000000000000000000000000000000000055555555
00000000000000000000077dcc777cc7dcc7dcccccc7dcc77cc7dcc7dccd7cc77000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077dcc777cc7dcc7dcccccc7dcc77cc7dcc7dccddcc770000000000000000000000000000000cccccccc000000000000000055555555
00000000000000000000077dcc777cc7dcc7dddcc777dcc77cc7dcc7dcccdcc7700000000000000000000000000000ccc777777ccc0000000000000000000000
00000000000000000000077dcc777cc7dcc777dcc777dcc77cc7dcc7dcccdcc770000000000000000000000000000ccc77777777ccc000000000000055555555
00000000000000000000077dcc777cc7dcc777dcc777dcc77cc7dcc7dcccccc77000000000000000000000000000cc777777777777cc00000000000000000000
00000000000000000000077dcc7c7cc7dcc777dcc777dcc77cc7dcc7dcccccc7700000000000000000000000000cc77777777777777cc0000000000055555555
00000000000000000000077dcc7c7cc7dcc777dcc777dcccccc7dcc7dcc7ccc7700000000000000000000000000c7777777777777777c0000000000000000000
00000000000000000000077dccccccc7dcc777dcc777dcc77cc7dcc7dcc7ccc770000000000000000000000000cc7777777777777777cc000000000000000000
00000000000000000000077dccccccc7dcc777dcc777dcc77cc7dcc7dcc77cc77000000000000000000000000cc777777777777777777cc00000000000000000
00000000000000000000077dccc7ccc7dcc777dcc777dcc77cc7dcc7dcc77cc77000000000000000000000000c77777777777777777777c00000000000000000
00000000000000000000077dccc7ccc7dcc777dcc777dcc77cc7dcc7dcc77cc7700000000000000000000000c7777777777777777777777c0000000000000000
00000000000000000000077dcc777cc7dcc777dcc777dcc77cc7dcc7dcc77cc7700000000000000000000000c7777777777777777777777c0000000000000000
00000000000000000000077dcc777cc7dcc777dcc777dcc77cc7dcc7dcc77cc7700000000000000000000000c7777777777777777777777c0000000000000000
0000000000000000000007777777777777777777777777777777777777777777700000000000000000000000c7777777777777777777777c0000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000700000000dd0dd000000000000000000000000000dd0dd000000
00000000000000000000000000000000000cc07000cc070000cc0000000cc07000000dd0dd0070000000d00000d0000000000dd0dd0000000000d00000d00000
0000000000000000000000000000000000cccc770cccc7700cccc00700cccc770000d00000d000000000d00000d000000000d00000d000000000d00000d00000
0000000000000000000000000000000000ccc0770ccc07700ccc007700ccc0770000d00000d0700000000ddddd0000700000d00000d0000000000ddddd000070
000000000000000000000000000000000ccccc70ccccc700ccccc7700ccccc7000000ddddd00007000000d2d2d00007000000ddddd00007000000d2d2d000070
00000000000000000000000000000000c0cc0000ccc00000ccc07700c0cc000000000d2d2d000070000000ddd000077700000d2d2d000070000000ddd0000777
0000000000000000000000000000000000777000077000000777000000777000000000ddd0000777000dd0ddd0dd0070000000ddd0000777000dd0ddd0dd0070
0000000000000000000000000000000000707000070700000700700000707000000dd0ddd0dd007000dd0ddddd0dd070000dd0ddd0dd007000dd0ddddd0dd070
00cc000000cc000000cc0000000cc0000000000000000000000000000000000000dd0ddddd0dd07000ddd0ddd0ddd07000dd0ddddd0dd07000ddd0ddd0ddd070
0ccc00000ccc00000ccc000000ccc000ccc00000ccc00000ccc000000ccc000000ddd0ddd0ddd07000dddd0d0dddd07000ddd0ddd0ddd07000dddd0d0dddd070
ccccc700ccccc000ccccc7000ccccc00cccc0000cccc0000cccc00000cccc00000dddd0d0dddd07000dd0dd0dd0ddd7000dddd0d0dddd07000dd0dd0dd0ddd70
0ccc07000ccc00700ccc070000ccc000ccc00000ccc00000ccc000000ccc000000dd0dd0dd0ddd7000dd00d0d00ddd7000dd0dd0dd0ddd7000dd00d0d00ddd70
ccccc700cccccc70ccccc7000ccccc00cc077700cc0777c0cc07770c0cc0777000dd00d0d00ddd7000d000d0d000007000dd00d0d00ddd7000d000d0d0000070
ccc0c700ccc00700ccc0c70007777777cccc7000cccc7000cccc70000cccc70000d000d0d0000070000000d0d000007000d000d0d0000070000000d0d0000070
0ccc07000ccc07000ccc070000ccc000cc000000cc000000cc0000000cc00000000000d0d0000070000000d0d0000070000000d0d0000070000000d0d0000070
0c0c07000c0c70000c0c07000cc00c00cc000000c0c00000c0c000000cc000000000dddd000000700000dddd000000000000dddd000000700000dddd00000000
0000000000ccc00000ccc00000000000011111000011111000011110001111100000000000000007000000000000000000000000000000000000000000000000
00ccc0000c1c1c000ccccc0000ccc000011717100011717100111171001171710000000000000007000000000000000000000000000000000000000000000000
0c1c1c00ccccccc0cc1c1cc00c1c1c00011111100011111100111111001111110000000000000000000000000000000000000000000000000000000000000000
ccccccc0ccccccc0ccccccc0ccccccc00111110000011110000111100001111000000d00000d0007000000000000000000000000000000000000000000000000
cc717cc0c11111c0cc111cc0cc717cc000011000011110000111100001111000000000d000d00000000000000000000000000000000000000000000000000000
c11111c0ccccccc0ccccccc0c11111c000111100000110000001100000011000000ccc00000ccc00000000000000000000000000000000000000000000000000
cc717cc00ccccc000ccccc00cc717cc0010110100110100000111000001110000000ccc000ccc000000000000000000000000000000000000000000000000000
0ccccc0000000000000000000ccccc00001001000000100000101000001010000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000dddd0000dddd000000000000dddd0000d00000000000d00000000000000000000000000000000000000000c0000000
000cc000000cc000000cc00000000cc000d11d0000d11d0000dddd0000d11d000d0dd0000000dd0d0000000000000000000000000000000000000000cc000000
00cccc0000cccc0000cccc000000cccc00d11d0000d11d0000d11d0000d11d00000dcd00000dcd000000000000000000000000000000000000000000ccc00000
00ccc00000ccc00000ccc0000000ccc000ddd0000ddddd0000d11d0000ddd000000dccdddddccd000000000000000000000000000000000000000000cc000000
0ccccc000ccccc000ccccc00000cccc00ddddd00d0ddd0d000dddd000ddddd00000ddccdcdccdd000000000000000000000000000000000000000000c0000000
c0cc00c00ccc00c00ccc00c000c0cc0cd0ddd0d000ddd0000ddddd00d0ddd0d00000ddcccccdd000000000000000000000000000000000000000000000000000
00ccc00000cc000000ccc0000000ccc0000dd000000dd000d0ddd0d0000dd00000000ddddddd0000000000000000000000000000000000000000000000000000
00c0c00000c0c00000c00c000000c0c00ddd00000ddd00000ddd00000ddd00000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000050200050303030103010307020005050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505020203000000000000030303030000030300030300000003030303020000000303000303000000000003030000030300000003030000000000000003000303000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303000000000000000000000303000000000000000000000000000003030000000000000000000000000000030300000000000000000000000000000303000000000000
__map__
1011111111113b11111111111111111200101111111111111111111111111112001011111111111111111111111111121011111111111111111111111111121011111111111111111111111111121011111111111111111111111111121011111111111111575811115758120000000000000000000000000000000000000000
200f040c040436060404600404040a22002004040c0404040404040440040a2200200404040404040404040404040422200404040404040404040404040422200404040404040404040a0404082220040404040404040404040404042220040404040c040a6768494a6768220000000000000000000000000000000000000000
200101013e010d0101010101010101220020010101010101010101010e0101220020010101010101010101010101012220010f01010101010101010e010122200e01010101010101010101010122206b6c010101010e01010101010122200e0101010101017778595a7778220000000000000000000000000000000000000000
200101013e010d0101010101010101220020010101010101010101010101012200200101010101abacad0101010101222001010101700101016001010160222001010101c8c90101010101010122207b7c01010101010101010101012220010101010145456a0101010101220000000000000000000000000000000000000000
200101010101131c3333270d0d25333d0020010101010101010101010101012200200101010101bbbcbd0101010101222001010101010101010101010101222001010101d8d90101010101015022200101010101c8c9010101016b6c2220010101016a010101010101016a220000000000000000000000000000000000000000
2001010101012220040404010104042200200f0140010101015001010101702200200101010101afafaf010101010122200701010101010101010101010722200f01010101010101010101010122200101010101d8d9010101017b7c22200f010101010176010169010101220000000000000000000000000000000000000000
3a33270d25333d2001010101010101220030313131313131313131313131313200200101010101afafafc8c9010101222001010101010101e8e90101010122200101010101010101010801010722204d4e010101010101010101010122200101010165555675014b4c0176220000000000000000000000000000000000000000
200404010404222001010101016001220000000000000000000000000000000000200101010101afafafd8d9010101222001010101010101f8f90101010122303131313131313131313131313132205d5e010101010101010101010122200101010101010101015b5c0101220000000000000000000000000000000000000000
200101010101223a3333270d0d25333d0000000000000000000000000000000000200101010101010101010101010122200801010101010101010101010a220000000000000000000000000000002001010101010101010101010101222001010101010101010101010101220000000000000000000000000000000000000000
20010101600122200404040101040c2200000000000000000000000000000000002001010101010101010101010101223031313131313131313131313131320000000000000000000000000000002001010101010101010101010101222001016a01010101790101790101220000000000000000000000000000000000000000
3a33270d25333d20010101010101012200000000000000000000000000000000002001111111120101011011111101220000000000000000000000000000000000000000000000000000000000002001010101010101010101010101223031313131313131313131313131320000000000000000000000000000000000000000
20040401040422200101010101010122000000000000000000000000000000000020010404042201010120040404012200000000000000000000000000000000000000000000000000000000000020010a0101160303031601010a01220000000000000000000000000000000000000000000000000000000000000000000000
207a014b4c6a22203f0101010101012200000000000000000000000000000000002001010101220101012001010101220000000000000000000000000000000000000000000000000000000000002001010101340101013401010101220000000000000000000000000000000000000000000000000000000000000000000000
206a015b5c0122200e3f01010101012200000000000000000000000000000000002001010101220101012001010101220000000000000000000000000000000000000000000000000000000000002001010101340101013401010101220000000000000000000000000000000000000000000000000000000000000000000000
303131313131323031313131313131320000000000000000000000000000000000200101010122010f01200101010122000000000000000000000000000000000000000000000000000000000000200101010134010f013401010101220000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000003031313131313131313131313131320000000000000000000000000000000000000000000000000000000000003031313131313131313131313131320000000000000000000000000000000000000000000000000000000000000000000000
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
010100200002001310000200102000020010200002001020000200102000020010200002001310000200102000020013100002001020000200102000020010200002001020000200102000020013100042001020
01020020304103b410006140b614304103b410304103b410304103b410304103b410306153b410304103b410304103b614304103b410304103b410304103b410304103b410304103b410304103b410306143b410
01020000185101e4112b1130010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200085000850008500085000850008500085000850008500085000850008500085000850008500085000850008500085000850008500085000850008500085000850008500085000850008500085000850
001000003091030910309103c91430910309103091030910309103c91430910309103091030910309103091030910309103091030910309103c9143091030910249103091030910309143091030910309103c914
001000000000014a1414a1014a5015a1015a1004a1017a0000000000000000021a5022a5022a5004a000000000000000000000004a0000000000000da500da500ca500ca5000000000001ea501da0004a0000000
001400000b0530d0500f0500f0501d0001e0000c0031a00018000120501305014050180001a0001c000000000c003000001100014000190001a0001700013000150001a0001a0000000000000000000000000000
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
0003000015030190301300023030220301d0302d00023000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002755027550285002a5002d5002e5502f550305502f7002f70000000211002910027100241000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000170301303017000170001300010000100001600014000110000f0000000000000000000000000000000000000000000180001a0001c0001f0002200022000200001c0001900019000000000000000000
010400001303017030170000b0001500010000100001600014000110000f0000000000000000000000000000000000000000000180001a0001c0001f0002200022000200001c0001900019000000000000000000
000900001f650206502262029620276202162020620206201e62020620276202a620006002d6002d6000060000600006000060000600006000060029600296002960000600006000060000600006000060000600
000e00002d6203e6203f6203a620346202f6202b6202f6002b60028600246002f6002b60028600246002260000600006000060026600006000060000600006000060000600006000060000600006000060000600
000500002162023630276302b6402f640326303563037620396203a6203b6203b62038620346202f6202a6202662023620206202a600266002560024600226000060700607006070060700607006070060700607
000500002d6203263034640336402d630296301c63018620126100f61023600246000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00020000105501255015550185501a5501c5501d5501e5501f5502055021550225502355024550245500050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000600002423324233242432520325203262432625326253322033020300203212032620324203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
000300001e5501d5501c5501a55018550165501455012550105500d55000500005000050000500005000050000500005000050023400005000050000500005000050000500005000050000500005000050000500
00020000105501255015550185501a5501c5501d5501e550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000226502260000600216001f6101b6001760015610146001360012600116000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002775027750287002a7002d7002e7502f750307502f7002f70000000211002910027100241000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003403036030370003a000390303a0302e00036000320003000000000210002600024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e1501e150181501865028150106501065022650000001b65000000186502730013650146000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001c6530b55308553196531965313653106530d6530c6530965306653000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000200002006020050200502e600000001e600000001d0401c0402f60017600150001500019040190303160012000130001800000000000000200028600296002a6002b600000000000000000000000000000000
00010000210302103016030160302a2302823025210202101c2101721013210102100e2100b210092100921008210082100821008210082100821008210082100821008210082100821008210082100720000000
000100001e0301f03015030140303101032010350102a0102a0102a01025010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000009650086500b1000b1001560010650106501660014600116000f6000000000000000000000000000000000000000000182001a2001c2001f2002220022200202001c2001920019200000000000000000
00010000000000e520145200d51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 08 42 43 0b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
