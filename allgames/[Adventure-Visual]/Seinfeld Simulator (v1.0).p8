pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--seinfeld simulator
--by rangee
function _init()
eggy=stat(102)
if eggy==0 or eggy=="www.lexaloffle.com" or eggy=="v6p9d9t4.ssl.hwcdn.net" or eggy=="game.itch" then
cartdata("seinsim")
logo_init()
calc_perc()
end
end
function _update60() update() end
function _draw() draw() end

-->8
--function init
function function_init()
jokes_init()

poke(0x5f2d,1)
if dget(3)==0 then
  input="key" else input="mouse"
end
can_click=true		

filt=dget(4)

sein={sp,x,y}

function draw_box(x,y,w,h,c1,c2)
  for i=0,1 do
    rectfill(x+i,y-i,x+w+i,y+h-i,c1+((c2-c1)*i))
  end
end

function draw_bord()
for i=0,1 do rect(i,i,126+i,126+i,0) end
rect(2,2,125,125,1)
end

function draw_crown()
if dget(2)>=100 and game_time>0.2 then
spr(99,sein[2]+10,sein[3]-6+sin(-0.2+(time())/2)*2,2,1)
end
end

function draw_mouse()
if input=="mouse" then
  if dget(2)>=100 then pal(13,9)pal(5,4) end
  if stat(34)==0 then
    spr(94,stat(32)-1,stat(33)-1) else spr(95,stat(32)-1,stat(33)-1)
  end
  pal()
end
end

function reset_jokes()
avail_jokes={}
avail_jokes_kid={}
for i=1,#joke do
  add(avail_jokes,i,i)
  if kid[i]==1 then
    add(avail_jokes_kid,i)
  end
end
end
reset_jokes()

dusts={}
function make_dust(x,y,dx,dy)
dust={x=x,
y=y,
dx=dx,
dy=dy}
add(dusts,dust)
end
function dust_upd()
for i=1,32 do
  if #dusts<32 then
    make_dust(rnd(128),rnd(128),rnd(0.5)-0.25,rnd(0.5)-0.25)
  end
end
for dust in all(dusts) do
  dust.x+=dust.dx
  dust.y+=dust.dy
  if dust.x<0 or dust.x>128 or dust.y<0 or dust.y>128 then
    del(dusts,dust)
  end
end
end
function draw_dust()
for dust in all(dusts) do   
  pset(dust.x,dust.y,1)
end
end

ptcls={}
function make_ptcl(x,y,col,dx,dy)
ptcl={x=x,
y=y,
col=col,
w=10,
dx=dx,
dy=dy}
add(ptcls,ptcl)
end
function ptcl_upd()
for ptcl in all(ptcls) do
if ptcl.x<-16 or ptcl.x>164 or ptcl.y<-16 or ptcl.y>164 then
  del(ptcls,ptcl)
end
end
end

fires={}
function make_fire(x,y,col)
fire={x=x,
y=y,
col=col,
tmr=0,}
add(fires,fire)
end

function shake()
local sh_x=0.25-rnd(0.5)
local sh_y=0.25-rnd(0.5)
sh_x*=sh
sh_y*=sh
camera(sh_x,sh_y)
sh*=0.75
if sh<0.25 then sh=0 end
end

function draw_pod(x)
palt(0,false) palt(2,true)
map(0,0,x,0,16,16)
palt(0,true) palt(2,false)
end

function scr_snap(scr)
if scr>16 then scr=16
elseif scr<0 then scr=0 end
return scr
end

function click_rel()
if stat(34)==0 then can_click=true end
end

function mouse_in(x1,y1,x2,y2)
if stat(32)-1>=x1 and stat(33)-1>=y1 and stat(32)-1<x2 and stat(33)-1<y2 then
  return true
end
end

sel_orig={-400,69,49,15}
sel_to={41,69,49,15}

function sel_tween()
for i=1,#sel_orig do
  sel_orig[i]=tween(sel_orig[i],sel_to[i],4)
end
if dget(2)<100 then
  sel_col=7
else
  sel_col=10
end
end

function txt(txt,x,y,col,out,out_col,sinus,sinus_pow,sinus_spd,sinus_del,txt_num)
--outline
  for i=-1,1 do
    for j=-1,out do
      if sinus==nil then
        print(txt,x+i,y+j,out_col)
      else
        --sinus
  						for k=1,#txt do print(sub(txt,k,k),x+i+(k*4-4),y+j+cos(k*sinus_del+(time())*sinus_spd)*sinus_pow,out_col) end
      end
    end
  end
--normal 
if sinus==nil then
		print(txt,x,y,col)
else
  --sinus
  for k=1,#txt do print(sub(txt,k,k),x+(k*4-4),y+cos(k*sinus_del+(time())*sinus_spd)*sinus_pow,col) end
end    
end

function tween(pos,dest,spd)
pos+=(dest-pos)/spd
--snap
if pos>dest then
  if pos<=dest+1.5 then pos=dest end
elseif pos<dest then
  if pos>=dest-1.5 then pos=dest end
end
return pos
end

function draw_data(bkg_x,time_y,wins_y,pct_y)
draw_box(bkg_x,time_y-1,84,19,1,1)
line(bkg_x+1,time_y+3,bkg_x+85,time_y+3,0)
circfill(bkg_x+6,time_y+9,2,0)
draw_box(bkg_x+8,time_y,21,16,0,12)
draw_box(bkg_x+31,wins_y,25,16,0,12)
draw_box(bkg_x+58,pct_y,25,16,0,12)
txt("time",bkg_x+12,time_y+1,7,1,0)
txt("games",bkg_x+35,wins_y+1,7,1,0)
txt("done",bkg_x+64,pct_y+1,7,1,0)
end

title_init()
end
-->8
--game init
function game_init()
music(2)
update,draw=game_update,game_draw

--shake
sh=0
--round
round=0
event,event_bank=0,{0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,3}
react_tmr,game_time=0,0
--star
star_opts={1,2,3}
star_chan={0,0,1}
--menu
menu_x,menu_xto,menu_uses=144,121,1
menu_open=false
--scrs
if tut==1 then
  scr_bmr,scr_gnz=4+flr(rnd(6)),4+flr(rnd(6))
else
  scr_bmr,scr_gnz=8,8
end
scr_bmr_new,scr_gnz_new=scr_bmr,scr_gnz  
scr_x,scr_xto=-64,1
--pals
opt_pal={9,10,11,12,14,15}
joke_pal={12,10,11,14}
--tut  
tut_x,tut_y,tut_num,tut_tmr=1,1,1,0

function init_joke()
--ptcls
for ptcl in all(ptcls) do
  del(ptcls,ptcl)
end
--state
if tut==1 then
  state="joke" else state="tut" music(18)
end
--data
scr_net,doub=0,1
--round
round+=1
round_skip,round_show=false,false
--star
star_x,star_xto=-32,-32
star_y,star_yto=64,64
star_end,star_opt=false,0 
--joke
joke_y,joke_yto=-64,-64
image_y,image_yto=-64,-64
joke_num,joke_tmr,done_pick=0,0,0
--sel
sel,sel_sine,sel_col=1,0,7

--pick joke
function find_joke(for_kids)
  local num=0
  if for_kids==0 then
    if #avail_jokes==1 then reset_jokes() end
    num=avail_jokes[flr(rnd(#avail_jokes))+1]
  else
    if #avail_jokes_kid==1 then reset_jokes() end
    num=avail_jokes_kid[flr(rnd(#avail_jokes_kid))+1]
  end
  if for_kids==0 then
    joke_num=num
    return true
  else
    if kid[num]==0 then 
      return false
    elseif kid[num]==1 then 
      joke_num=num
      return true
    end
  end
end
--kid
if filt==0 then
  while find_joke(1)==false do find_joke(1) end   
else
--adult
  find_joke(0)
end
joke_curr=joke[joke_num]

--sub from available jokes
if filt==1 then
del(avail_jokes,joke_num)
else
del(avail_jokes_kid,joke_num)
end

--pick event
if round>1 then
  event=event_bank[flr(rnd(#event_bank))+1]
end 
--lightning
if event==1 then
  music()
  lit_tmr=0
--double
elseif event==2 then
  doub=2
  music(32)
--all or none
elseif event==3 then
  music()
end
event_x,event_xto=-128,-128

--opt box
opt1_x,opt1_xto,opt1_col=-128,-128,rnd(opt_pal)
opt2_x,opt2_xto,opt2_col=-128,-128,rnd(opt_pal)
opt3_x,opt3_xto,opt3_col=-128,-128,rnd(opt_pal)

----    
end

--1st joke
music(2)
init_joke()
end
-->8
--game update
function game_update()
click_rel()

--round time
game_time+=1/60

--lit tmr
if event==1 and state!="tween_out" and state !="reaction" then
  lit_tmr+=1
else
  lit_tmr=0
end

--make ptcls
dust_upd()
ptcl_upd()
if event==1 and state!="tween_out" and state!="reaction" then
  make_ptcl(-16,rnd(128),flr(rnd(2)+1),2,0)
elseif event==2 then    
  make_ptcl(rnd(1024),-8,0,sin(time()),rnd(1))  
end

--sein (neu)
if state!="reaction" then
  sein={2,46,24+sin(time()/2)*1.5,5,6}
end

--bkg
bkg_x=tween(bkg_x,bkg_xto,5)

--opt box
opt1_x=tween(opt1_x,opt1_xto,5)
opt2_x=tween(opt2_x,opt2_xto,6)
opt3_x=tween(opt3_x,opt3_xto,7)

--menu
menu_x=tween(menu_x,menu_xto,5)
if menu_open then
  menu_xto=93 else menu_xto=121
end

event_x=tween(event_x,event_xto,8)

--scrs
scr_x=tween(scr_x,scr_xto,5)

--sel
sel_tween()
--pos/size
if sel==1 then
  sel_to={3,70,122,18}
elseif sel==2 then
  sel_to={3,88,122,18}
elseif sel==3 then
  sel_to={3,106,122,18}
elseif sel==4 then
  sel_to={100,31,26,13}
elseif sel==5 then
  sel_to={100,44,26,13}
end

--joke
joke_y=tween(joke_y,joke_yto,5)  
image_y=tween(image_y,image_yto,5)	

--star
star_x=tween(star_x,star_xto,8)
star_y=tween(star_y,star_yto,8)

--state machine

--joke--		
if state=="joke" then
joke_yto,image_yto=2,1

--txt crawl
if joke_tmr<#joke_curr then
  joke_tmr+=0.5
  sfx(63,3,rnd(8)+24,8)
end
--skip
if (btnp(Ž) or (stat(34)==1 and can_click)) and joke_y==joke_yto then
  can_click=false
  joke_tmr=#joke_curr
end
joke_final=sub(joke_curr,1,joke_tmr)

--"tween_in"
if (tut==1 and joke_tmr==#joke_curr)
or (tut==0 and tut_num==3) then		
  --star
  if tut==1 and star_chan[flr(rnd(3)+1)]==1 then
    --# q's
    local q=3
    if #opt3[joke_num]==0 then q=2 end
    star_opt=star_opts[flr(rnd(q)+1)]
  end	    
  sfx(63,3,8,8)
  state="tween_in"
end

--tween in--		
elseif state=="tween_in" then

--star pos
if star_opt>0 then
  star_xto=0
  star_yto=68+star_opt*18-18
end

--show opts
opt1_xto,opt2_xto=7,7
--2 q's
if #opt3[joke_num]>0 then
  opt3_xto=7
end

--"choose"
if (opt3_x==opt3_xto and #opt3[joke_num]>0) or (opt2_x==opt2_xto and #opt3[joke_num]==0) then
  state="select"
end

--choose--		
elseif state=="select" then

--sel hover
sel_sine+=0.02

--mouse
if input=="mouse" then
  --sel
  if mouse_in(-32,64,160,86) then
    sel=1
  elseif mouse_in(-32,87,160,104) then
    sel=2
  elseif mouse_in(-32,105,160,124) and #opt3[joke_num]!=0 then
    sel=3
  elseif menu_open==true then
    if mouse_in(-32,32,160,43) then
      sel=4
    elseif mouse_in(-32,44,160,63) then
      sel=5
    end
  elseif mouse_in(0,0,127,72) then
    sel=1
  end		  
  --menu
  if mouse_in(-32,-32,148,63)==true and tut==1 and event!=3 then
    menu_open=true else menu_open=false
  end
end

--key
if input=="key" then
  if btnp(ƒ) then
  if menu_open==false then
    sel+=1
    --2 q's
    if sel>3 or (sel>2 and #opt3[joke_num]==0) then
      sel=1
    end
  else
    --menu
    sel+=1
    if sel>5 then
      sel=4
    end
  end
  elseif btnp(”) then
  if menu_open==false then
    sel-=1
    if sel<1 and #opt3[joke_num]>0 then
      sel=3
    --2 q's
    elseif sel<1 and #opt3[joke_num]==0 then
      sel=2
    end
  else
    --menu
    sel-=1
    if sel<4 then
      sel=5
    end
  end
  end
  --every move
  if btnp(”) or btnp(ƒ) then
    sfx(62,3,0,8)
    sel_sine=0
  end		
  --help menu
  if btnp(—) then
    sfx(63,3,8,8)
    --can't open
    if tut==1 and event!=3 then
      if sel<=3 then
        sel,menu_open=4,true
      else
        sel,menu_open=1,false
      end
    else
      sfx(62,3,8,8)
    end
  end
end

--out of time
if lit_tmr==480 then
  sel,state=0,"tween_out"
end

--"tween_out"
if (btnp(Ž) and input=="key") or (stat(34)==1 and can_click and input=="mouse") then
  can_click=false
  --if punch line
  if sel<=3 then
    sh=12
    sfx(63,3,0,8)
    state="tween_out"
  --skip
  elseif sel==4 and menu_uses>0 then
    sh=4
    sfx(63,3,0,8)
    menu_uses-=1
    round_skip,state=true,"tween_out"
  --show
  elseif sel==5 and round_show==false and menu_uses>0 then
    sh=4
    sfx(63,3,0,8)
    menu_uses-=1
    round_show=true
    --close help menu (key)
    if input=="key" then
      menu_open,sel=false,1
    end
  else
    --no uses
    sh=2
    sfx(62,3,8,8)
  end
end

--tween out--		
elseif state=="tween_out" then

--move star
if star_end==false then
  if sel>0 and sel==star_opt then
    star_xto,star_yto=134,24
    menu_uses+=1
    sfx(60,3)
  else star_xto=-16 end
  star_end=true
end

--hide opts
opt1_xto,opt2_xto=144,144
--2 q's
if #opt3[joke_num]>0 then
  opt3_xto=144
end

--close menu
menu_open=false

--"reaction"
if tut==1 or (tut==0 and tut_num==8) then
  if (opt3_x==opt3_xto and #opt3[joke_num]>0)
  or (opt2_x==opt2_xto and #opt3[joke_num]==0) then
    if round_skip==false then
      state="reaction"
    else
      --skip
      music(2)
      init_joke()
    end
  end
end

--reaction--
elseif state=="reaction" then
react_tmr+=1

if react_tmr==1 and event!=0 then
  music(2)
end

--calc new scrs (optimize)
if react_tmr==1 then
  if sel==1 then
    scr_bmr_new+=opt1_scr_bmr[joke_num]*doub
    scr_gnz_new+=opt1_scr_gnz[joke_num]*doub
  elseif sel==2 then
    scr_bmr_new+=opt2_scr_bmr[joke_num]*doub
    scr_gnz_new+=opt2_scr_gnz[joke_num]*doub
  elseif sel==3 then
    scr_bmr_new+=opt3_scr_bmr[joke_num]*doub
    scr_gnz_new+=opt3_scr_gnz[joke_num]*doub
  elseif sel==0 then
    --out of time
    scr_bmr_new-=2
    scr_gnz_new-=2
  end
end

--calc net scr
if react_tmr==1 then
  scr_net=(scr_bmr_new-scr_bmr)+(scr_gnz_new-scr_gnz)
end

--scr snap
scr_bmr_new,scr_gnz_new=scr_snap(scr_bmr_new),scr_snap(scr_gnz_new)
		  
--fx--
  --good
  if scr_net>1 then
    if react_tmr==1 then
      sein_y=32
      sfx(41,1)
      sfx(42,2)
      --add to iary
      nums[joke_num]=2
      --all or not
      if event==3 then
        end_init("win")
      end
    end
    sein_y+=(24-sein_y)/16		    
    sein={7,46,sein_y,5,6}  
  --bad
  elseif scr_net<-1 then    
    if react_tmr==1 then
      sein_y=32
      sfx(43,1)
      sfx(44,2)
      --all or not
      if event==3 then
        end_init("lose")
      end
    end
    sein_y+=(36-sein_y)/48
    sein={112,46+sin(time()*4)*1.5,sein_y,5,5}		      
  --meh
  else
    sein={101,46,24,5,6}    
  end		  

--add/sub scrs
if scr_bmr!=scr_bmr_new then
  scr_bmr+=sgn(scr_bmr_new-scr_bmr)/4
end
if react_tmr>=30 then
  if scr_gnz!=scr_gnz_new then
    scr_gnz+=sgn(scr_gnz_new-scr_gnz)/4
  end
end
--sfx
if react_tmr==1 then
  if scr_bmr<scr_bmr_new then
    sfx(62,3,24,(scr_bmr_new-scr_bmr)*2)
  elseif scr_bmr>scr_bmr_new then
    sfx(62,3,16,(scr_bmr-scr_bmr_new)*2)
  end
elseif react_tmr==30 then
  if scr_gnz<scr_gnz_new then
    sfx(62,3,24,(scr_gnz_new-scr_gnz)*2)
  elseif scr_gnz>scr_gnz_new then
    sfx(62,3,16,(scr_gnz-scr_gnz_new)*2)
  end
end

--game win/lose
if scr_bmr>=16 or scr_gnz>=16
or scr_bmr<=0 or scr_gnz<=0 then
  --hide gui
  menu_xto,joke_yto,image_yto,scr_xto=144,-64,-64,-64
  if joke_y==joke_yto then
    --game won/lost
    if scr_bmr>=16 or scr_gnz>=16 then
      sh=16
      end_init("win") else end_init("lose")
    end
  end
end

--next
if tut==1 and react_tmr>=90 then
  react_tmr=0
  init_joke()
end		
end
----
end
-->8
--game draw
function game_draw()
cls()
shake()

--ptcls
if event==3 then
  rectfill(1,1,126,126,1)
  circfill(64,64,sin(time()/2)*16+64,0)
end
draw_dust()
for ptcl in all(ptcls) do
  if ptcl.x>128 then del(ptcls,ptcl) end
  ptcl.x+=ptcl.dx
  ptcl.y+=ptcl.dy
if event==1 and state!="tween_out" and state!="reaction" then   
  line(ptcl.x,ptcl.y,ptcl.x+ptcl.w,ptcl.y,ptcl.col)
  ptcl.dx*=1.05
  ptcl.w+=1
elseif event==2 then
  spr(flr(3*time()%3)+201,ptcl.x,ptcl.y)
end
end

draw_bord()

--sein
spr(sein[1],bkg_x+sein[2]-4,sein[3],sein[4],sein[5])  
draw_crown()
draw_pod(bkg_x)
if state=="joke" then
  spr(flr(9*time()%3)+205,bkg_x+sein[2]+12,sein[3]+16)
end

--joke
txt(joke_final,2,joke_y,joke_pal[event+1],2,1)
if image[joke_num]!=nil then
  rectfill(53,image_y+1,76,image_y+16,1)
  spr(image[joke_num],54,image_y,3,2)
end
txt("Ž",opt1_x/8+132,joke_y+15+sin(time()*2)/2,0,2,1)

--opts
draw_box(opt1_x-3,73,118,14,1,joke_pal[event+1])
draw_box(opt2_x-3,91,118,14,1,joke_pal[event+1])
draw_box(opt3_x-3,109,118,14,1,joke_pal[event+1])
if sel==1 then
txt(opt1[joke_num],opt1_x,74+sin(sel_sine)*2,opt1_col,2,0)
else
txt(opt1[joke_num],opt1_x,74,opt1_col,1,0)
end  
if sel==2 then
txt(opt2[joke_num],opt2_x,92+sin(sel_sine)*2,opt2_col,2,0)
else
txt(opt2[joke_num],opt2_x,92,opt2_col,1,0)
end
if sel==3 then
txt(opt3[joke_num],opt3_x,110+sin(sel_sine)*2,opt3_col,2,0)
else
txt(opt3[joke_num],opt3_x,110,opt3_col,1,0)
end

--menu
rectfill(menu_x-1,28,menu_x+48,58,1)
rectfill(menu_x,27,menu_x+48,57,12)
txt("h\ne\nl\np",menu_x+1,26,12,1,7)
txt("—",menu_x-1,52+sin(time()),12,2,7)
txt("USES:",menu_x+8,25,7,1,12)
txt(menu_uses,menu_x+29,25+sin(time()),12,1,7)
--skip
rectfill(menu_x+8,34,menu_x+30,43,0)
rectfill(menu_x+9,33,menu_x+31,42,8)
if sel==4 then
  txt("skip",menu_x+13,35,7,1,0,true,1.25,1.5,0.25,4)
else
  txt("skip",menu_x+13,36,7,1,0)
end
--show
rectfill(menu_x+8,47,menu_x+30,56,0)
rectfill(menu_x+9,46,menu_x+31,55,10)
if sel==5 then
  txt("show",menu_x+13,48,7,1,0,true,1.25,1.25,1.5,4)
else
  txt("show",menu_x+13,49,7,1,0)
end

--scrs--
  
--pal
  local bar_col={8,8,8,8,8,8,10,10,10,10,10,11,11,11,11,11,11}  
  local bar_bkg_col={2,2,2,2,2,2,4,4,4,4,4,3,3,3,3,3,3}
  --waves
  for i=0,7 do
    for j=1,2 do
      pset(scr_x+6+i,66-scr_bmr*2+j-sin(i*0.03+time()*1.25)*2,bar_bkg_col[flr(scr_bmr)+1])
      pset(scr_x+19+i,66-scr_gnz*2+j+sin(i*0.03+time()*1.25)*2,bar_bkg_col[flr(scr_gnz)+1])
      pset(scr_x+6+i,66-scr_bmr*2+j+sin(i*0.03+time()*1.25)*2,bar_col[flr(scr_bmr)+1])
      pset(scr_x+19+i,66-scr_gnz*2+j-sin(i*0.03+time()*1.25)*2,bar_col[flr(scr_gnz)+1])
    end
  end
  --wave mask
  rectfill(scr_x+6,66,scr_x+26,70,0)
  --bars
  rectfill(scr_x+6,65-scr_bmr*2+2,scr_x+13,66,bar_col[flr(scr_bmr)+1])
  rectfill(scr_x+19,65-scr_gnz*2+2,scr_x+26,66,bar_col[flr(scr_gnz)+1]) 
  --outline
  for i=0,13,13 do
    rect(scr_x+i+5,33,scr_x+i+14,66,0)
    rect(scr_x+i+4,32,scr_x+i+15,67,7)
  end
  --names
  txt("b\no\no\nm\ne\nr",scr_x+1,33,12,1,7)
  txt("g\ne\nn\n.\nz",scr_x+29,33,12,1,7)
  --faces
  local aud={flr(scr_bmr)+1,flr(scr_gnz)+1}
  local aud_face={46,46,46,46,46,46,30,30,30,30,30,14,14,14,14,14,14}
  for i=1,#aud do
    spr(aud_face[aud[i]]+ceil(sin(time()*2)/2),scr_x+4+(i*11)-8,23+cos(time()*2)/2)
  end

--opt tips
local opt={opt1_scr_bmr[joke_num]+5,opt2_scr_bmr[joke_num]+5,opt3_scr_bmr[joke_num]+5,opt1_scr_gnz[joke_num]+5,opt2_scr_gnz[joke_num]+5,opt3_scr_gnz[joke_num]+5}
local opt_face={46,46,46,46,30,14,14,14,14}
if state=="select" and round_show==true then
  local q=0
  --2 q's
  if #opt3[joke_num]!=0 then
    q=2 else q=1
  end
  for i=0,q do
    spr(opt_face[opt[i+1]],110,84+(i*18))
    spr(opt_face[opt[i+4]],119,84+(i*18))
  end
end

--events--

--lit rnd
if event==1 then
  txt("lightning round!",event_x-32+lit_tmr/8,24-sin(time()/2)*4,10,1,2,true,2,1.5,0.075)
  --tmr
  if state=="tween_in" or state=="select" then
    rect(opt1_x+83,62,opt1_x+117,68,7)
    rectfill(opt1_x+115-(lit_tmr/16),64,opt1_x+85,66,12)
    spr(110,opt1_x+75,62)
  end
elseif event==2 then
  txt("double score!",event_x+6,24-sin(time()/2)*4,11,1,2,true,0.5,1,1.5)
elseif event==3 then
  txt("all or nothing!",event_x+4,24-sin(time()/2)*4,15,1,2)
end
if state=="tween_out" or state=="reaction" then
event_xto=256 else event_xto=32
end

----

--tut
if tut==0 then
tutorial()
end
if tut==0 then
draw_box(tut_x,tut_y,66,32,1,12)
line(tut_x+7,tut_y-1,tut_x+7,tut_y+31,1)
line(tut_x+1,tut_y+5,tut_x+67,tut_y+5,2)
txt(tut_txt_final,tut_x+3,tut_y+1,7,1,0)
if tut_tmr>=#tut_txt[tut_num] then
  txt("Ž",tut_x+64,tut_y+28+sin(time()*2)/2,12,2,1)
end
end

--sel
if state=="select" then
  rect(sel_orig[1],sel_orig[2],sel_orig[1]+sel_orig[3],sel_orig[2]+sel_orig[4],sel_col)
end
	
--star
pal(10,1)pal(9,1)pal(2,1)
for i=-1,1 do
 	for j=-1,1 do
    spr(111,star_x+i,star_y+j)
 	end
end
pal()
spr(111,star_x,star_y)

draw_mouse()

end
-->8
--jokes
function jokes_init()
--jokes
joke={
"",
"",
"",
"",
"",
"",
"",
"",
"what's the best episode of\nseinfeld?",
"why did the chicken cross\nthe road?",
"what did the red light say to\nthe green light?",
"are traps gay?",
"why is this joke as slow as\nmolasses",
"we missed the truck!",
"spongebob? i'm talking to you!\nare you mad?",
"fruit salad",
"it's not ashton kutcher,",
"baba",
"skadoo skadae",
"i'm reading a book about\nanti-gravity",
"what kind of music do planets\nlike?",
"what do you call a fish\nwithout eyes?",
"here i am i got a j.o.b.\nmaking plenty of dough for my\nfamily",
"why does stephen hawking do\none-liners",
"what do you call a boy with no\narms or legs",
"why couldn't the bike stand\nup by itself",
"best minecraft music disc",
"simp:",
"james charles",
"you can have...",
"'i call it 'bold and brash.''\n'more like..'",
"what is obama infamous for",
"what did the janitor say when\nhe jumped out of the utility\ncloset?",
"i used to be addicted to\nsoap..",
"what does a zombie vegetarian\neat?",
"how many tickles does it take\nto make an octopus laugh?",
"i made a pencil with 2 erasers",
"spring is here, i got so\nexcited i wet",
"smoke weed every",
"i had a dream i weighed\n<1/1000th of a gram",
"how do you steal a coat?",
"the guy who cut off the left\nside of his body",
"my wife gets upset at me for\nhiding kitchen utensils",
"what does garlic do when it\ngets hot?",
"what's 8 minus 4",
"is this pool safe for diving?",
"the only thing flat-earthers\nhave to fear..",
"why was the math textbook so\nsad?",
"how do you organize a space\nparty?",
"what do you call an elephant\nthat doesn't matter?",
"my wife asked 'what starts\nwith f and ends with k?'\ni said..",
"wanna hear a joke about pizza",
"my",
"son",
"hit or miss",
"we built",
"do you think that god stays in\nheaven",
"what's the best university?",
"hey pac-man what's up?",
"who is best girl",
"sayori",
"pearl harbor",
"what's the deal with..",
"femboy hooters",
"what rock group has 4 men\nthat don't sing?",
"you spin me right round\nbaby right round like a",
"who lives in a pineapple",
"what happened when the red\nship crashed into the blue\nship?",
"fanboy and chum-chum",
"bff",
"what do you call a cheap\ncircumcision?",
"one book says to the other\nbook 'you look so much\nthinner!' the other book says..",
"it's free real estate",
"what's brown and sticky?",
"it takes guts to be a",
"you are",
"i'm on patrol",
"why wouldn't you buy anything\nwith velcro?",
"what's the least spoken\nlanguage in the world?",
"what did the coffee report to\nthe police?",
"what did the cannibal do after\nhe dumped his girlfriend?",
"where does the solar system go\nto work out?",
"donkey kong",
"god left me",
"i've asked many people what\nlgbtq stands for..",
"why couldn't the toilet paper\ncross the road?",
"i got hairy legs that",
"why can't a nose be 12 inches?",
"my wife told me to take the\nspider out instead of killing\nhim",
"when you have a bladder\ninfection",
"a man has fallen into the\nriver in",
"will you",
"what is kirby star allies?",
"terraria",
"go to",
"i'm too lazy to put a joke\nhere",
"this game sucks because",
"bowsette",
"why",
"this is the last joke in\nthe list",

}

image={
224,227,230,192,195,198,170,173
}

kid={
1,1,1,1,1,1,1,0,0,1,
0,0,1,1,1,1,1,1,0,1,
0,1,1,0,1,1,1,0,0,0,
0,0,0,0,1,0,1,0,0,1,
0,0,0,0,1,1,1,0,1,1,
0,1,0,0,0,1,1,1,0,1,
0,0,1,0,0,0,1,1,1,0,
0,1,1,0,0,1,1,1,1,1,
0,1,1,1,0,1,1,0,0,0,
1,0,1,1,1,1,1,0,0,1
}

opt1={
"du du du du du",
"krump",
"a still image of kirby\nsitting at a desk",
"crab rave",
"we're rangee to the max",
"garfield kart",
"teletubbies",
"pink guy??",
"the episode where they're not\nall a-holes",
"weed eater",
"what is up my dude",
"stop sending me hentai stop\nsending me anime pictures",
"fax idk",
"i see what u did there",
"squidward dab!!",
"don't i get a wish too? fruit\nprevents scurvy!",
"it's kevin malone",
"boeing 747",
"today is a wonderful day",
"i'm 14 and this is deep.",
"neptunes",
"a blind fish",
"i don't condone these kind of\nlyrical poems",
"he is dead",
"names",
"it was crippled",
"cat",
"squirels in my pants",
"hot",
"the big gay dance",
"'belongs in my *ss'",
"bald",
"'supplies!'",
"until i dropped it",
"excuse me i am vegan",
"henry the octopus",
"you wanna see my pencil",
"my peepee",
"week",
"i was like 0MG",
"is that your grandma's coat",
"he's all right now",
"too bad",
"kills a vampire",
"4",
"it deep ends",
"is sphere itself",
"we couldn't find its x",
"social distancing",
"an irrelephant",
"something we're not gonna do",
"this one's on the house",
"ding a ling",
"where'd you find this?",
"i guess they never miss huh",
"simcity",
"because he loves us",
"squidward community college",
"me you b*tches i'm high on\ncrack",
"monika",
"i gently open the door",
"birth of anime",
"jerry seinfeld",
"would not be commercially\nprofitable",
"mount rushmore",
"record baby",
"under a pineapple under a\npineapple",
"revolutionary war casualties",
"brain freeze",
"the best friends forever club",
"something that should be\ncommonplace with insurance",
"thanks, i had my appendix\nremoved",
"tik tok",
";)",
"person writing these jokes\nfor a video game",
"my most favorite creation",
"chase is on the case",
"it's a total rip-off",
"6502 assembly",
"a mugging",
"wiped his *ss",
"planet fitness",
"on iphone x",
"the way the truth and the\nlight",
"lesbian gay bi trans queer",
"it doesn't have legs",
"turn blonde in the sun",
"because then it would be a\nfoot",
"went out. nice guy. he's\na web designer",
"urine trouble",
"lego city",
"shut up man",
"masterful switch game",
"better than minecraft",
"joe",
"i understand",
"too rushed",
"worse than peach",
"but daddy i have to know why",
"nobody cares"
}
  
opt1_scr_bmr={2,-2,-2,-3,0,-3,1,2,-2,2,-3,-2,-3,-1,-2,-1,2,-2,1,-1,2,-2,2,-4,2,-2,2,2,2,-1,-2,-1,2,-2,-2,-2,-2,-2,-2,3,-1,4,-1,-1,2,4,4,3,-3,3,-1,-3,2,-1,-1,-1,2,-1,-2,3,-1,-3,-2,4,3,-1,-1,-1,-2,2,0,4,-3,-1,4,2,-2,3,-1,2,3,3,-2,3,0,-2,-3,2,2,2,1,2,-4,2,2,1,3,-3,2,2}

opt1_scr_gnz={-3,4,4,-3,0,-2,-1,-2,-3,3,-2,4,-1,3,-2,0,1,-1,-1,-3,-1,-2,-3,-3,1,1,1,1,2,3,2,-2,1,3,-3,-2,2,-2,3,1,-1,-2,1,2,-1,-2,1,1,-2,-1,2,1,1,2,1,2,-1,2,4,1,2,-3,-3,-2,-2,-2,2,2,-2,1,1,-2,-2,2,4,2,-3,0,2,1,2,1,4,-4,1,2,1,1,2,1,1,0,-4,2,0,1,0,-3,1,1}

opt2={
"alright sharky i got u a\neggy to eat",
"marg himpson",
"that's the name you should\nknow",
"moar",
"balonga in our slacks",
"gotta drink the funny\nwater to make me funny",
"baby",
"can i habe pusy plz",
"lmao lmfao jerry",
"to get to the other side",
"don't look at me i'm changing",
"yes traps are very much\nbig gay",
"it's malass joke",
"we're not aiming for the\ntruck!",
"i'm sorry but i do not watch\nchildren's programming",
"yummy yummy",
"itsa me, mario",
"booey",
"traps are gay",
"it's impossible to put down",
"planet music",
"big f rip fish",
"twisting the accelerator",
"he can't do stand-up",
"finn from that episode where\nhe turned into a foot",
"it's a bike",
"stal",
"what you are",
"minecraft ghast",
"a free dad joke",
"'too big for smash'",
"he was gonna pre dude",
"'i am a janitor'",
"but i'm clean now",
"grains",
"i've seen enough hentai to\nknow where this is going",
"it was pointless",
"my skin-tight hooded leotards",
"day",
"it was a nightmare",
"you jacket",
"he had to be hospitalized",
"amber heard",
"it takes its cloves off",
"8",
"we're playing 8-ball",
"earth-chan",
"because people threw it in a\nbonfire every year",
"get rick",
"dumbo",
"no it doesn't",
"it's for the customer",
"sims agents",
"daddy? daddy? dad.",
"it's a dude",
"cities skylines",
"because he too lives in fear\nof what he's created",
"cunity college",
"whoa holy sh*t",
"yuri",
"best girl",
"usa entered ww2",
"airplane food",
"goth ihop is better",
"ghostbusters",
"fidget spinner",
"under the sea",
"the crew was marooned",
"scampers!!!",
"youtube poop reference..",
"a rip-off",
"i actually gained wait i'm\noffended oh my god",
"re-max",
"a stick",
"organ donor",
"adopted",
"more seaweed medley dear",
"who wears that anymore?",
"sign language",
"it got grounded",
"he shot himself into an enemy\nfortress",
"the earth is flat",
"dankey kang",
"unfinished",
"no one has given me a\nstraight answer",
"because it got stuck in a\ncrack",
"turn, that that that that\nthat turn",
"it's not my boyfriend",
"i did bc i'm a beta",
"i actually can't think of\nanother option here",
"lego city",
"shut up man",
"solid entry in the series",
"absolute trash",
"30330",
"it's okay",
"jokes aren't funny",
"c*cking peach",
"i don't even know",
"ok smart one" 
}

opt2_scr_bmr={-2,-4,1,0,3,2,-3,-2,-2,3,4,-2,4,2,2,1,-1,1,-2,3,-1,-3,-2,3,-1,-3,-4,-2,-1,2,-3,-1,-3,3,3,-2,3,-2,2,-1,3,-1,-2,3,-1,-2,-2,-3,-1,-2,4,-1,-1,-2,2,-2,1,4,-3,-1,-3,2,4,-4,1,-1,2,4,0,-3,4,0,2,4,2,-1,1,-3,2,-2,-1,-1,-2,-2,4,3,4,-2,-2,0,1,2,-2,-3,2,1,3,2,2,2}

opt2_scr_gnz={4,0,0,2,-2,-2,-3,4,3,-2,-3,2,-2,-2,-2,2,1,0,4,-1,3,2,4,1,2,-2,-4,3,1,-3,-2,4,2,-1,-1,2,-1,2,1,2,1,1,-2,2,3,-3,-2,-2,2,-3,-1,2,2,-2,2,0,2,-2,1,2,-3,-1,-2,-4,4,3,1,-1,3,2,1,-3,1,-2,-2,1,2,-3,1,-3,1,2,-1,4,-2,0,0,1,0,0,1,0,-2,-3,0,1,0,2,1,1}

opt3={
"",
"homey",
"jigglypuff",
"more",
"2020 animaniacs==trash",
"i gotta have a good meal",
"good morning sunday morning",
"pink mensch",
"kramer warming his shirt in\nthe pizza oven",
"because it can, of course!",
"ey yo baby lemme suck on\ndem toes",
"not unless u say no homo",
"nice one peppermint larry",
"oh no you can't talk about\nthat",
"shut your mouth you mediocre\nclarinet player",
"16 ideas for amazing fruit\nsalads - buzzfeed",
"it's ashton kutcher",
"boi",
"do u know de wae",
"big brain",
"penis music",
"a fsh",
"richard! pants on!!",
"he is unable to talk in real-\ntime due to his paralysis",
"an unfortunate individual",
"it was 2-tired",
"chirp",
"belle delphine gamer girl\nbath water",
"leaked his own nudes",
"my phone number",
"'belongs in the trash'",
"insert political humor i\ncan't say",
"'little kid lover 69'\n-michael scott",
"dubloons!!",
"vegetables",
"ten tickles",
"ok doodle, this looks like a\ndraw",
"my plants",
"long span of time",
"a christmas gram? i want one!",
"u kill the person and hide\nthe body",
"i'll have your rear-ends cut\noff",
"but that's a whisk i'm\nwilling to take",
"wario",
"wrong you're eliminated",
"no",
"scimandan",
"5318008",
"you planet",
"your mom",
"firetruck",
"nah it'll be too cheesy",
"mom is dad",
"are ya winnin'?",
"mia khalifa",
"this city",
"spy kids 2",
"collegehumor",
"waka waka waka waka",
"natsuki",
"left me hanging!",
"'those are fighting words'\n-usa",
"pet russian dolphin",
"hooters' twitter",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"",
"lego city",
"",
"game sucks",
"",
"",
"i forgive you",
"too much sein",
"",
"but daddy what would happen",
"big facts it is"
}

opt3_scr_bmr={0,2,-2,2,1,-2,4,-3,2,-2,-1,-2,0,-2,-1,-1,-3,1,-3,-2,-4,2,-2,-1,-2,3,0,-4,-2,-2,2,1,-4,-3,1,3,-2,3,-4,1,-3,-4,4,-3,-3,-1,-2,-1,4,-2,0,4,-3,3,-2,3,-1,-1,2,-2,4,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,2,0,0,1,3,0,2,2}

opt3_scr_gnz={0,-2,-3,-2,1,4,-2,-3,1,-3,3,-2,1,-3,3,-3,-3,2,1,2,0,1,0,2,-3,-1,1,1,-2,-4,1,0,0,-2,-2,-1,-1,2,-4,-3,2,0,-2,-3,-2,2,3,2,-2,3,-1,-2,-2,1,-3,1,-2,-4,-2,-4,-2,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,2,0,0,1,0,0,1,1}

end
-->8
--win/lose
function end_init(results)
result=results  
--set new
update,draw=end_update,end_draw

--count fx
state="begin"
time_final=0
games_final=dget(1)
pct_final=dget(2)  
wait_tmr=0

--menu pos
bkg_x,bkg_xto=-128,4
wallet_y,wallet_yto=128,88
time_y,time_yto=132,132
wins_y,wins_yto=132,132
pct_y,pct_yto=132,132

end_type=""

for ptcl in all(ptcls)do del(ptcls,ptcl)end

--save stats
if result=="win" then
  --best time
  if game_time<dget(0) or dget(0)==0 then
    dset(0,flr(game_time))
  end
  --# of games
  dset(1,dget(1)+1)
  --pct complete
  save_game()
end

--end music
sfx(-1)
sfx(63,3,0,8)
if result=="win" then
  music(14)
else
  music(16)
end
end

function end_update()

shake()

--dust
dust_upd()
ptcl_upd()

--tween--
bkg_x=tween(bkg_x,bkg_xto,6)
wallet_y=tween(wallet_y,wallet_yto,8)
time_y=tween(time_y,time_yto,5)
wins_y=tween(wins_y,wins_yto,5)
pct_y=tween(pct_y,pct_yto,5)

--end sequence

--sein
if result=="win" then
  sein={7,46+cos(time()/2)*16,28+sin(time()*2)*4,5,6} else sein={112,46+sin(time()*4)*1.5,32,5,5}
end

--tween in
if state=="begin" then
  --wait
  wait_tmr+=1
  time_yto=75
  --"count_time"
  if wait_tmr>=60 then
    state,wait_tmr="count_time",0
  end
--count time
elseif state=="count_time" then
  if time_final<flr(game_time) then
    sfx(62,3,0,8)
    time_final+=1
  else
    --wait
    wait_tmr+=1
    wins_yto=75
    --"count_games"
    if wait_tmr>=60 then
      state,wait_tmr="count_games",0
    end
  end
--count games
elseif state=="count_games" then
  if games_final<dget(1) then
    sfx(62,3,0,8)
    games_final+=1
  else
    --wait
    wait_tmr+=1
    pct_yto=75
    --"count_pct"
    if wait_tmr>=60 then
      state,wait_tmr="count_pct",0
    end
  end
elseif state=="count_pct" then
  if pct_final<dget(2) then
    sfx(62,3,0,8)
    pct_final+=1
  else
    --wait
    wait_tmr+=1
    --result anim
    if wait_tmr>=60 then
      wait_tmr=0
      --win
      if result=="win" then
        state="win_anim"
      --lose
      else
        state="lose_anim"
      end
    end
  end
--win anim
elseif state=="win_anim" then
  wait_tmr+=1
  if wait_tmr==1 or wait_tmr==40 then
    sfx(63,3,0,8)
    bkg_xto=20
  elseif wait_tmr==24 or wait_tmr==64 then
    bkg_xto=4
  elseif wait_tmr==88 then
    sfx(63,3,8,8)
    bkg_xto=128
  elseif wait_tmr==124 then
    sfx(63,3,0,8)
    sh=1
    state="end"
  end
elseif state=="lose_anim" then
  wait_tmr+=1
  if wait_tmr==1 then
    bkg_xto=-32
  elseif wait_tmr==24 then
    sfx(61,3,0,8)
    bkg_xto=128
  elseif wait_tmr>24 and wait_tmr<40 then
    make_fire(110+rnd(2),86,8+flr(rnd(3)))
    sfx(61,3,8,16)
  elseif wait_tmr==88 then
    state="end"
  end
elseif state=="tween_out" then
  wallet_yto=-48
  if wallet_y==wallet_yto then
    if end_type=="title" then
      title_init()
    else
      bkg_xto=4
      game_init()
    end
    music(24)
  end
end

--restart
if state=="end" then
  if btnp(Ž) or (stat(34)==1 and can_click) then
    can_click=false
    end_type="title"
    state="tween_out"
    sfx(61,3,0,8)
  end
  if btnp(—) then
    end_type="new"
    state="tween_out"
    sfx(61,3,0,8)
  end
end

end

function end_draw()
cls()

draw_dust()

for fire in all(fires) do
  fire.x+=rnd(2)-1
  fire.y-=rnd(3)
  pset(fire.x,fire.y,fire.col)
  fire.tmr+=1
  if fire.tmr==15 then del(fires,fire) end
end

--fx
if result=="win" then
  make_ptcl(rnd(2048),-8,0,-1,rnd(1)) 
else
  make_ptcl(rnd(2048),-8,0,rnd(1)-1,2) 
end
for ptcl in all(ptcls) do
  ptcl.x+=ptcl.dx
  ptcl.y+=ptcl.dy
  if result=="win" then
    spr(159,ptcl.x,ptcl.y)
  else
    spr(204,ptcl.x,ptcl.y)
  end
end

draw_bord()

--sein
spr(sein[1],sein[2],sein[3],sein[4],sein[5])
draw_pod(4)
draw_crown()

--oven front
if result=="lose" then
  spr(92,104,wallet_y-4,1,4)
end

--stat bkg
draw_data(bkg_x,96,96,96)
--stats
txt(time_final.."S",bkg_x+12,time_y+30,7,1,0)
txt(games_final,bkg_x+38,wins_y+30,7,1,0)
txt(pct_final.."%",bkg_x+65,pct_y+30,10,1,0)
--wallet mask
rectfill(112,wallet_y+1,128,wallet_y+34,0)
line(125,wallet_y+1,125,wallet_y+34,1)
line(2,2,125,2,1)
if result=="win" then
  --wallet
  if wait_tmr<120 then
    spr(106,104,wallet_y,2,4)
  else
    spr(126,104,wallet_y-cos(time()/2)*5,2,2)
  end
  --lines
  if state=="win_anim" then
    if ((wait_tmr>4 and wait_tmr<8) or (wait_tmr>44 and wait_tmr<48)) then
      sh=1
      spr(156,96,85)
      spr(156,96,115,1,1,false,true)
    elseif wait_tmr>120 then
      spr(156,100,80)
      spr(156,116,80,1,1,true)
    end
  end
else
  --oven front
  spr(93,112,wallet_y-4,1,4)
end

--txt
if result=="win" then
  txt("~~congratulations!!~~",22,16,11,1,1,true,2.5,1.5,0.075,17)
else
  txt("~~boo you stink!~~",28,16,8,1,1,true,2,1,1.5,14)
end

if state=="end" then
  txt("—:restart",2,121,0,1,1)
  txt("Ž:title",95,121,0,1,1)
end

draw_mouse()

end
-->8
--title screen
function title_init()

update,draw=title_update,title_draw

--scr shake
sh=0

state="intro"
sel=1

kid_col=0

--logo
logo_y,logo_yto=-32,1
--bkg
bkg_x,bkg_xto=-128,4
--sein
sein_sps={2,7,101}
sein_sp=sein_sps[flr(rnd(3)+1)]

--tut?
tut=dget(5)

end

function title_update()
--mouse
click_rel()

--dust
dust_upd()

--tween logo
logo_y=tween(logo_y,logo_yto,12)
--tween bkg
bkg_x=tween(bkg_x,bkg_xto,5)
--tween sel
sel_tween()
  
--state machine--

--intro
if state=="intro" then
  --tween in bkg
  bkg_xto,sel_to=4,{41,68,49,16}
  --"title"
  if bkg_x==bkg_xto then
    state="title"
  end
--title
elseif state=="title" then
  --sel pos/size
  if sel==1 then
    sel_to={41,68,49,16}
  elseif sel==2 then
    sel_to={89,68,21,16}
  elseif sel==3 then
    sel_to={30,83,15,12}
  elseif sel==4 then
    sel_to={44,83,42,12}
  elseif sel==5 then
    sel_to={85,83,15,12}
  end
  --mouse control
  if input=="mouse" then
    if mouse_in(bkg_x+36,65,bkg_x+87,77) then
      sel=1
    elseif mouse_in(89,61,123,77) then
      sel=2
    elseif mouse_in(6,78,45,94) then
      sel=3
    elseif mouse_in(45,78,84,91) then
      sel=4
    elseif mouse_in(84,78,123,91) then
      sel=5
    end
  end 
  --key control
  if input=="key" then
    if btnp(”) or btnp(ƒ) then
      if sel<3 then
        sel=4 else sel=1
      end
    end
    if btnp(‹) then
      if sel>2 then
        if sel>3 then
          sel-=1 else sel=5
        end
      else
        sel-=1
        if sel<1 then
          sel=2
        end
      end
    end
    if btnp(‘) then
      if sel>2 then
        if sel<5 then
          sel+=1 else sel=3
        end
      else
        sel+=1
        if sel>2 then
          sel=1
        end
      end
    end
    if btnp(”) or btnp(ƒ) or btnp(‹) or btnp(‘) then
      sfx(62,3,0,8)
    end
  end

--click btns
if (input=="key" and btnp(Ž))
or (input=="mouse" and stat(34)==1 and can_click) then
  can_click=false
  if sel==1 then
    state="start"
  elseif sel==2 then
    state,iary_y="iary",40
    iary_y=40
    sel_to={-400,69,49,15}
  elseif sel==3 then
    sh=2
    if input=="key" then
      input="mouse" else input="key"
    end
  elseif sel==4 then
    sh=2
    filt+=1
    if filt>1 then filt=0 end
    dset(4,filt)
  elseif sel==5 then
    sh=2
    tut+=1
    if tut>1 then tut=0 end
    dset(5,tut)
  end
  sfx(63,3,0,8)
end

--joke-iary
elseif state=="iary" then
  bkg_xto=-128    
  --mouse control
  if input=="mouse" then
    if mouse_in(-32,96,160,160) then
      iary_y-=1.7
    elseif mouse_in(-32,-32,160,32) then
      iary_y+=1.7
    end
  end       
  --key control
  if input=="key" then
    if btn(ƒ) then
      iary_y-=1.5
    elseif btn(”) and iary_y<32 then
      iary_y+=1.5
    end
  end    
  --"intro"
  if ((input=="key" and btnp(Ž)) or (input=="key" and btnp(Ž)) or (input=="mouse" and stat(34)==1 and can_click)) then
    sel=1
    can_click=false
    state="intro"
    sfx(63,3,16,8)
  end    
elseif state=="start" then
  bkg_xto=-128
  sel_to={-400,69,49,15}
  logo_yto=-32
  if logo_y==logo_yto then
    bkg_xto=4
    game_init()
  end
end

end

function title_draw()
cls()
pal()
shake()

--dust
draw_dust()

--sein
sein={sein_sp,bkg_x+43,26+sin(time())}
spr(sein[1],sein[2],sein[3],5,6)  
draw_pod(bkg_x)

--iary
if state=="iary" then
  if iary_y>=0 then
    txt("-----~joke-iary~-----",bkg_x+150,iary_y,0,2,1,true,0.9,1,1.5)
  end
  if iary_y>=-32 then
    txt(" to unlock a joke, get the\nbest possible score on one!",bkg_x+139,iary_y+16,1,0)
  end
  for i=1,#joke do
    local y=iary_y+(i*32)+16
    if y>=-16 and y<144 then
      if nums[i]==2 then
        txt(joke[i],bkg_x+133,y,0,1,1)
        if image[i]!=nil then
          rectfill(bkg_x+181,y+1,bkg_x+204,y+16,1)
          spr(image[i],bkg_x+182,y,3,2)
          pal()
        end
      else
        txt("???",bkg_x+188,y,0,1,1)
      end
      txt("--~"..i.."~--",bkg_x+180,y-8,0,1,1)
    end
  end
end

--border
draw_bord() 
txt("V1.0",bkg_x-2,2,0,1,1)
txt("@rangee",bkg_x+95,2,0,1,2)
txt("this game contains adult humor",bkg_x+1,121,0,1,1)

if state=="iary" then
txt("Ž:back",bkg_x+227,121,0,1,1)
txt(dget(2).."/100",bkg_x+227,2,0,1,1)
end

--bkg cards
draw_box(bkg_x+8,79,102,17,1,12)
line(bkg_x+9,83,bkg_x+111,83,2)
circfill(bkg_x+14,89,2,2)

--start btn
draw_box(bkg_x+38,71,45,12,0,8)
txt("tell jokes!",bkg_x+41,74,7,2,0,true,1.5,1,0.075)

--settings bkg
for i=0,1 do
  for j=0,1 do
    rectfill(bkg_x+27+i*55+j,86-j,bkg_x+38+i*55+j,94-j,10*j)
  end
end

--iary
draw_box(bkg_x+86,71,17,12,0,8)
spr(62,bkg_x+88,67-sin(time())*1.5,2,2) 

--key/mouse
if input=="key" then
  dset(3,0)
  spr(158,bkg_x+30,85)
else
  dset(3,1)
  spr(157,bkg_x+30,85)
end

--joke filt
draw_box(bkg_x+41,86,38,8,1,kid_col)
if filt==0 then
  txt("kid mode",bkg_x+45,87,7,1,0)
  kid_col=11
else
  txt("18+ mode",bkg_x+45,87,7,1,0)
  kid_col=8
end

--tut
if tut==1 then
  spr(97,bkg_x+85,86)
else
  spr(98,bkg_x+85,86)
end

--stats bkg
draw_data(bkg_x+16,100,100,100)
--stats
txt(dget(0).."S",bkg_x+28,109,7,1,0)
txt(dget(1),bkg_x+54,109,7,1,0)
txt(dget(2).."%",bkg_x+81,109,10,1,0)

--sel outline 
rect(sel_orig[1],sel_orig[2],sel_orig[1]+sel_orig[3],sel_orig[2]+sel_orig[4],sel_col)
--mouse
draw_mouse()

--logo
spr(217,36,logo_y,7,3)
txt("SIMULATOR",55,logo_y+19,10,1,2,true,0.75,0.8,-0.125)
end
-->8
--tutorial
function tutorial()
tut_txt={
  "jerry seinfeld\nneeds your help\nwith his comedy\nact!",
  "seinfeld will\ntell the first\nhalf of his joke\nabove.",
  "your job is to\nfinish the joke!",
  "how funny the\npunch line is\nwill affect the\nratings of your\naudience.",
  "the 2 different\ngenerations\nin your audience\nare boomers and\ngenz-ers.", 
  "the boomers find\npuns, word-play,\nand cheesy humor\nfunny.",
  "..and gen-z's\nfind edgy humor,\nmemes, and\nreferences\nfunny.",
  "let's see what\nthey each\nthought of\nyour joke!",
  "if one groups'\napproval is\nfull, you win!",
  "however, if one\ngroup's approval\nis empty, you'll\nlose.",
  "that's all!\ni hope you enjoy\ncrafting your\nvery own standup\nroutine!",
}

tut_xtos={
  40,40,40,40,40,1,18,1,1,1,32
}  
tut_ytos={
  84,84,30,30,30,73,73,94,1,73,1
}

--tween
tut_x=tween(tut_x,tut_xtos[tut_num],10)
tut_y=tween(tut_y,tut_ytos[tut_num],10)

--txt tmr
if tut_tmr<#tut_txt[tut_num] then
  tut_tmr+=0.75
end

--key control
if (input=="key" and btnp(Ž)) or (input=="mouse" and stat(34)==1) then
  if tut_tmr>=#tut_txt[tut_num] then
    if tut_num!=3 then
      can_click=false
    end
    sfx(63,3,16,8)
    if tut_num==1 then
      state="joke"
    end
    if tut_num==11 then
      tut=1
      dset(5,tut)
      music(2)
    else
      tut_num+=1
      tut_tmr=0
      --swoosh
      if tut_x!=tut_xtos[tut_num] or tut_y!=tut_ytos[tut_num] then
        sfx(61,2,0,8)
      end
    end 
  end  
end

--txt crawl
tut_txt_final=sub(tut_txt[tut_num],1,tut_tmr)
end
-->8
--100 percent
function calc_perc()
mult={10000,1000,100,10,1}
nums,big_nums={},{}
 
for i=1,100 do nums[i]=1 end
for i=1,20 do big_nums[i]=11111 end  

for i=1,20 do
  if dget(i+20)!=0 then
    big_nums[i]=dget(i+20)
  end
end

for i=1,20 do dset(i+20,11111) end 

for i=1,20 do
  for j=1,5 do     
    nums[(i*5-5)+j]+=sub(big_nums[i],j,j)-1     
  end
end

for i=1,20 do big_nums[i]=11111 end


function sep(num)
  row=ceil(num/5)
  pos=num-(row*5-5)
  add_num(row,pos)
end

function add_num(row,pos)
  big_nums[row]+=mult[pos]
end


function save_game()

  for i=1,100 do
    if nums[i]==2 then
      sep(i)
    end
  end

  for i=1,20 do
    dset(i+20,big_nums[i]) 
    big_nums[i]=11111 
  end

  local pct=0
  for i=1,#nums do
    if nums[i]==2 then
      pct+=1
    end
  end
  dset(2,pct) 
end

save_game()
end
-->8
function logo_init()
update,draw=logo_update,logo_draw
t,l,ly,lyto=0,{16,17,32,33,48,48},{},{}
b,f={0,1,5,4,9},{1,1,5,6,7}
for i=1,6do ly[i]=94lyto[i]=94end
function tw(p,pt,s)p+=(pt-p)/s return p end function r()
cls()t+=1
rectfill(0,0,127,127,9)circfill(47,55,12,7)ovalfill(48,53,82,76,7)circ(47,55,12,9)
for i=0,13,13 do line(40+i,53,40+i,58,9)end line(42,61,51,61,9)
spr(80,35,36,1,2,1)spr(80,52,36,1,2)spr(49,47,71)spr(49,75,72,1,1,0)for i=0,1do spr(64,62-i,45+i*31)end spr(65,84,56)spr(81,30,55)spr(81,56,55,1,1,true)
if t<22then pal()pal(7,f[flr((t-10)/2)])pal(9,b[flr((t-10)/2)])end
if t>150then pal()pal(7,f[5-flr((t-150)/2)])pal(9,b[5-flr((t-150)/2)])end        
for i=1,#l do if t<=120then ly[i]=tw(ly[i],lyto[i],i+1%3*2)end spr(l[i],28+i*9,ly[i])end    
for i=1,3 do if t==30then lyto[i]=84sfx(59)music(22)
elseif t==60then lyto[i]=94lyto[i+3]=84
elseif t==90then lyto[i+3]=94end end
if t>120then for i=1,6do ly[i]=93-cos(i*-0.09+time())/4end end
if t==180 then function_init()end end end
function logo_update()r()end
function logo_draw()end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222220111111001222210
000000000000000000000000000000000011100000000000000000000000000000000000000000000000000000000000222222222222222212bbbb2112bbbb21
00700700000000000000000000000001101101100000000000000000000000000000001011110000000000000000000022221111111111111b2bb2b11b2bb2b1
00077000000000000000000000000015210211011000000000000000000000000000000122101221000000000000000022211111000000001bbbbbb11bbbbbb1
00077000000000000000000000000152100520120000000000000000000000000000011252202210100000000000000022111111111111111b2cc2b11b2222b1
00700700000000000000000000001121025220225100000000000000000000000000110520010001100000000000000021111111111111111cb22bc11cc22cc1
000000000000000000000000000120024eee4500210000000000000000000000000010001154ee410100000000000000111111111111111112cccc2112cccc21
0000000000000000000000000002104e9999e450010000000000000000000000000100124e999994210000000000000000000000000000000111111001111110
077777700077770000000000000001e9fff99e4210000000000000000000000000010204e999fff9520000000000000022222222215122220111111001222210
7777777707777770000000000000219fffff9ee51100000000000000000000000001051d999fffff9200000000000000222222222152222214aaaa4114aaaa41
7770007777700777000000000010259fffff9ee41100000000000000000000000001025d9999ffff910000000000000011101111111111111aaaaaa11aaaaaa1
770000007700077700000000001015f44d9942541100000000000000000000000000002d9d44efedd10000000000000011100000000000001aa2a2a11aa2a2a1
7700000077000777000000000011029ed4992de51200000000000000000000000000420494ef9f9f4000000000000000111011111111111119aaaaa119aaaaa1
770000007700777700000000001f95f976fe279d21000000000000000000000000009d14e9e6fee6900000000000000011101111111111111992229119222221
77000000777777770000000000197efffff94ee450000000000000000000000000019454efff9e9ff00000000000000011101111111111111499994114999941
7700000007777077000000000004f9ffff9fdee44000000000000000000000000001ed44d9ffed9ff10000000000000000000000000000000111111001111110
077777700077777000000000000299ff9eff9ee450000000000000000000000000012e94d9f9e999f20000000000000022222222222221520111111001222210
77777777077777770000000000104e99e999eed420000000000000000000000000010294d99f7779920110000000000022222222222225121288882112888821
77000077077000770000000000012599de444544100000000000000000000000000000024e94eed9e2000110004f000022222222222215221888888118888881
770000770777777700000000001052e999eede45000000000000000000000fe0110000154d964479e200000100ff000011112222222251221822822118228221
7700007700777777000000000001229e9e99ed41000000000000000000000ff10000005d4d9977f9d100000010ff004911111222222152221488888114882881
7700007777000077000000000000d59de999d41000000000000000000ee009f20000001d54d9999d1000000151fe099911111222222512221444244114442441
7700007777777777000000000000ddfedd4441000000000000000000f4e40eff00000001d554ee41500000055e99e9f421115512222522221244442112444421
7700007707777770000000000001d6669eed52500000000000000000fe4ef49ee100000057d222251000000549994eff22222152221522220111111001111110
07777770000000000000000000105d666d4e216100000000000000000fe9f9ef9e1000001dd445d500000005e9ff4ff011111111000000000000000000000000
777777770007000000000000011005d66d62155d0000000000000000009effeffe40000015dd55d100000001e9eff7f011111111111111110011111111111100
7700007700777000000000010010005d65d505d100011000000000000009efffffe200000155d6d000000005444eff001111111100000000001494a7aaaa9100
77777777077770000000001000000001d56d5150000001100000000000014efffffe000001d56610000000014efff00011111111111111110019997a9a9aa100
777777700777000000000001100000001566d10000000001000000000001114ee9ff0000005d6d1000000001dfff40001111111100000000001a99aaaaaaa100
77000000077000000001dd5d000000000156600000000000100000000001115d666d1000001d650000000005dfe4d0001111111111111111001799aa999aa100
7777777700000000000dd5d650000000006d6510000000005100000000051156666750000005d1000000000d6666d1001111111100000000001799a99999a100
07777770000000000006dd66665000000056d6510000000055100000000511d6666dd00000015000000000067666d5001111111111111111001a99aa999aa100
0000000000007770001d6d6ddd610000000166d10000000055100000000511d666ddd10000001000000000066666dd101000000011111111001999aaaaaaa100
0000000000077777005dd66dd6dd100000001d600000000055500000000515d55dd66600000010000000000d665d6d501000000011111111001999aa9a9a9100
0077000000077777015dd6666dddd000000005600000000015510000000515dd5d666600000000000000000566d566d01000000011111111001d9d4444444100
007770000077777701566666ddd66500000001d0000000000d51000000051dd6dd667d000000000000000017d665666010000000100000000014446766671200
007770000077777001566d66dd6dd65000000000000000000dd510000001dd6ddd6d6500000000000000005ddddd6660000000001111111100144476667c1200
0077700007777700010d666666ddddd100000000000000001dd551000051d6dddddd610000000000000000166d66ddd010000000100000000012424444444100
00777000777770000105d6d666dddddd00000000000000001dd555000055d6666666d000000000000000001d6666dd1000000000111111110011111111111100
00000000777000000105666dd6665dd61000000000000000d5dd5510005dd666666dd000000000000000001ddddddd1010000000100000000000000000000000
00000000000000000105d666ddd66d5dd000000000000011d5ddd150005ddd666dddd0000000000000000011dddddd000001dddccd1000000000000051000015
0000000000099000010ddd666dddd6dd50000000000001dd55ddd150005ddddd666dd0000000000000000011ddddd100000d151151d00000001110001d1110d1
00000000009779000015dd66666666655100000000001dddd55ddd510055dd6666dd00000000000000000011111111000000055550000000015d5100015d5100
0000000000977900001056d66666666d111000000115d5dddd1dddd10055d6666ddd0000000000000000000111111000000005555000000001d5d10001d5d100
000077700009990000010d66666666dd55d15115155d5ddddd1dddd10005ddddddd000000000000000000000000000000000077661000000015d5210015d5210
00777777000977900000101666666dd65165511d1155d5dddd1d55d5000000000000000000000000000000000000000000001244421000000011122100111221
077777770009779000000101666dd666116d515d11556d5d51555dd500000000000000000000000000000000000000000001255444210000000011211d001121
777777770000999000000101566666651d6ddd6d555d655515555551000000000000000000000000000000000000000000126662449910000000011151000111
077777770011110000111100e41551299215514e0000000000000000000000000000000000000000015555555555555100247776299421001677771000000000
0007777711499511114995114e45529aa92554e400000000000000000000000000000000000000002d424992d82222250056777765444210750c056000000000
000077771928825119945551249449aaaa9449420000000000000000000000000000000000000000ddd29994884224220147777775444520700c0070000a0000
000007771985581119555511429e4aa77aa4e9240000000000000000001210111000000000000000d2d29994884224220267777776522221700ccc70009a9000
000000771985581019155110e4499aa77aa9944e0000000000000000100221110000000000000000d2d29994884224220477777777222222700000709aaaaa90
0000007019288210191111102e449aaaa7a944e20000000000000001010100102100000000000000d2d299948842242214777777772222226500057002a9a200
000000001111110011111100049eeaa7aaaee940000000000000001001000001221000000000000053d29994884224222677777777622222177776100a000a00
000000000000000000000000024999aaaa9994200000000000000010014e4421110100000000000035d299948842242226777777776222250000000000000000
0000000000000000000000000000000000000000000000000000110014e9999e212200000000000055d299948842242257762267777225441115555555555551
000000000000000000000000011110000000000000000000000001005e999fff921200000000000055d299948842242247726726777549991276422222222225
00000000000000000000000110011011000000000000000000001001ee99ff77791000000000000053d299948842242247727776777499451667224444444422
00000000000000000000110000000000121000000000000000001002de99ff77741220000000000035d299948842242267617776777645221667244444444442
00000000000000000000010000000021012100000000000000001212522eff77f42210000000000033d14992d882242167127776777622221667244224422442
0000000000000000000014201111005201010000000000000000021e9652f44df41100000000000033d155555555555177127776777722221667242444244442
000000000000000000019e11244410010010000000000000000004de99e4fe64f92100000000000033d511111111111577127676777722221667242424244442
00000000000000000004e124deeeed1001210000000000000000124e999d7ffff4f0000000000000d3d1111111111111661276767d6722221667242224222442
0000000000000000000924dee9999ed501550000000000000000014d99ef77ff77f00000000000003dd111111111111176127576766d22221767244444444442
000000000000000001024de24999ffed01120000000000000000104de999fff77f4000000000000053d5111111111115771d6576777722221777244444444442
000000000000000001244e9f249ffffe001000000000000000000154eedeeff7f4100000000000006ed15555555555517776ddd6777722221777244444444442
00000000000000000024d999729ffff9001000000000000000000114ed444eff422000000000000077d12d62dc22222177777777777722221776244444444442
0000000000000000014de99ee599ff9e0100000000000000000000054e9ff9f9121000000000000077d24664cc42242246777777777722541776254444444452
0000000000000000024de9ee9f52499410000000000000000000001d4efff9f4110000000000000077d24664cc42242211446677777725421676222555555222
0000000000000000124ee994ffe7494100000000000000000000116d5d999fd0000000000000000077d24664cc42242200011446677644211267422222222225
0000000000000000144ed4e9f94def000000000000000000000100d66ededde1000000000000000077d24664cc42242200000011444442111115555555555551
0000000000000010144eed4e4deff10000000000000000000100005666499955000000000000000077d24664cc42242200000000000000000000000000001582
0000000000100011014deee9fffe100000000000000000011000000d66d49ed5000000000000000077d24664cc42242200000000001111101111111100008825
0000000010000011101429ffff9100000000000000000150010000005665d55d00111000000000007ed24664cc4224227750000001d767d11676767100002882
000000100000001111002fff4400101000000000000056651010000005656d550000011000000000d2d24664cc42242277700000017767711767676100218810
000015000000000110019ff920000001000000000001dd66d01100000051d6500000005100000000d2d24664cc4224220770075001ddddd11777777100132000
00015510000000001002eff90000000d510000000001dddd6501000000006dd10000001510000000ddd24664cc42242200770770017777711766667102320000
000ddd50000000000004ef9d00000016650000000005dd6dd6100000000066d500000005510000002d422d62dc22222500075070016777611dddddd113230000
0015ddd1000000000005d666100000d666000000000dd6666d501000000016dd1000000551000000015555555555555100007500001111101111111131000000
00555d6500000000001d666650100166660000000015dd66dd6011000000016d5000000151102ffe77f66a6666ccccccc6666a66fffeeeeeeee444422222dfff
0055556d100000000017d666d0010666dd000000001dd56dddd001000000005dd000000015ef7f94777666af666cfafc666fa666fffeeeeee444444422222fff
0055556651000000001dd66dd000dd666d000000005666d555d00100000000015000000059ff7f00f7f666faa6aaaaaaa6aaf666fff6e444dddd111122222fff
00dd5dd6d500000000065555650dddd6660000000056666655d010000000000000000002fffffef4c66f666aaaaaaaaaaaaa666cffff4dddddd1111112222eff
005dddddd500000000066ddd66d6dd6666000000005d666654777f777f4000000000002f9fe9779fccc77f66a9a99999a9a666ccffff1115dd515577d522d222
00555dd66d00000000016dddd66d66666600000000dddd6622ff7ef777f100000000004ff9feefd0cccc7766aa99ffff9aa66cc6ffff11111ddd7777d5222222
005555dd660000000000d5dddd6ddd666d000000006666d5005554f7f77f410000000049efe411d066cccc6fa999ffff99afcc66ffff61577dddddd66d222222
0015dddddd1000000000655dddd66dddd500000000dd666d551111ef7979f400000000124444116166666faaa999999999aaaf66fffffe777d6ddd66dd222222
001dd555dd50000000005555dd666dddd1000000005dddd555511149efefef0000000051244216d5666666aaa99d999d99aaa666fffffe666d66ddddd5222222
000ddd555dd100000000055dd666dddd510000000055d6d5511115154926d00000000051522516556666666fa99f999f99af6666fffff6d665d6d55d55222225
000dddd666d500000000015d66d55dd55000000000d655d551111d677771d0000000001515215d55ccccccc6aa99ddd99aacccccffffffed55dd55dddd122254
0005d66666dd000000000055dd555dd550000000006d566555111d667751d0000000001d11116d5dcccccc66a9a99999a9acccccffffffeedddddde7d2122544
00015d666d550000000000556d55ddd5d10000000055d66511551d66661510000000001d1111d5d1ccccc66aaaaaaaaaaaaaccccffffffeeedde777ed1125444
0001555dd55d660000000005d6ddddddf9000000005d66d6155115d6651d000000000015d11555d07f7766faacaaaaaaa6aafcccffffffeeee6deeed21224444
00005d55ddd66ddd51155101566ddd66ff000000001ddd665511515d11d100000000000151165d50777776af77ccfafc6f7fa6cfffffff6eeeeddddd12224444
000015d666dd55d5115511101d66d6669f000000001ddd6dd51151155d10000000000001155dd100cc677acc77fccccc77777a67fffffff6eeee442222254444
33333333f9f33f9f33333333ddddddddddddddddddd0d0dd77777777f994494477777777011111100000000001111100003513009eff9ee49eff9ee49eff9ee4
3333333d888dd888d3333333ddddddddddddddd67dd7add777777744999949947777777711255210001111101233351018533581e4444ed4e9949ed4e4994ed4
33333338b1b88b1b83333333dddddddddddeedd77008700777777779949999997777777712555510001555211333325128853882d4444544d9e49544de44e544
333333348884488843333333dddddddddddfeeddddd00ddd777777799499499977777777153331000015555111122251258888529944de4599e4de4599eede45
333333333332333333333333dd20dddddddddddddddeed7d77777779aa71e17a77777777133331000112225100155551222552229e99ed419e99ed419e99ed41
3333333333d2d33333333333dd0d20ddddddddddddeeee6d777777799aaa9aa97777777715333310033332510015555112222221e999d410e999d410e999d410
339833333d248d3333333893dd0d0dddddddedddd877dddd7777777f9999999f7777777711533310023335100011111001222210dd444100dd444100dd444100
33f33333d2488848848333f3ddd770dddddeedddd888d22d777777776499449997777777011111100111110000000000000000009eed52509eed52509eed5250
338d83332288888833338d83dd078d027ddefddddd88822d777777774499999997777777000000000000000000002222000011555aaaaaaaaaaa555110000000
3388d33d2484ff48d333d883dddd00dd76ddddddddd770dd77777777444999946777777700000002888880000000888885aaaaaaaa9889aaaaa888aaa5888000
3384333224820028833338d3dd20d002ddefdedd0cc02ddd7777777754444446777777770000002880088000000128889aaaaaaaaa8898aaaaa988aaaa988100
338333c2228cffc88c333833d67dd444444444d7cccddddd77777d55d5996997777777770000008820028000155aa989aaaaaaaaa98aa8aaaaaa8aaaaaa88500
33884ccc224888884ccc8433d7d0024444444ddd2c002ddd7777755555994997777777770000008800008155aaaaaa9aaaaaaaaaa88aa9aaaaaa8aaaaaa88a10
33d88ccdc2248884ccccd333dd00d44ddd467dd7070d00dd777775999f9999f99f7777770000008800018aa9888aaaaaaaaaaaaaa88aaa888aaa8aaaaa989a50
333333dcccdcdcdccd333333dddd776dddd7ddd767dddddd77777999999499999977777700000088215aaa988a98a88a888aaaaa8888988988a98aaaaa889aa0
333333cccccdcdcccc333333dddddddddddddddddddddddd777779494994994949777777000000288aaaaa88aaa8a98aa88988aaa89a88aaa8a98aa88888aaa0
cccccccccccccccccccccccceeeeeeeeeeeeeeeeee4cccccddddd225551111111111555500000012889aaa88aaa8a98aa888888aa89a8aaaa8a88a88aa88aa20
cccccccccccccccccccccccceeeeeeeeeeeeeeeeee4cccccddddd2255511111111115555000015aa8888aa889a88a88aa88a988aa8a989aa88a88a89aa88aa20
cccccccccccccccccccccccceeeccceeeeeeeeeeee2dccccddddd225551111111111555500015aaa98889a888888a88aa89aa88a98a888888aa89a8aaa88a210
cccccccccccccccccccccccceecccccceeeee9aa9e222222ddddd22555111111111155550005aaaaa9888988aaaaa89a98aaa88a98a88aaaaaa8a88aaa882100
ccc666cccccccccccccccccceeccccccccee9aaaaa944444ddddd2255511111111115555001aaaaaaa988988aaa9a89a98aaa89a88a89aaaaaa8a88aaa821000
cccdd6665ccccccccccccccceeeccccccccefa444aa44444ddddd24ff9eeeeeee94ff455005aa8aaaaa88988aaa8a89a88aaa89a88a89aaaa8a8a88aaa810000
cccd12d6666ccccccccccccceeeecccccca7794444444444ddddd2ff9e72e72eee9fff5500aaa8aaaaa88988aaa8a8aa88aa98aa89a88aaaa898a88a22800000
cccc2621d6666cccccccccccd22222ccca77aab344444444ddddd2f9ee22e22eeee9ff5500aaa89aaaa88988aa9898aa89aa88aa89a88aaa8a98a88210800000
cccc512615d6666ccccccccc222229aaa9aaabbb32222222ddddd26eee24e24eeeeef65500aaa889aa988a889a8898aa8aaa89aa8aa989a88a88a88128820000
ccccc51121dd66666dcccccc21119a9112bbbbbbbb344444ddddd26eeeeeeeeeeeee6655002aa88899889a98888a889888a888a8889a8888a888218888880000
cccccc5111dddd666244dccc2119a11112bbbbbbbbbbb344ddddd2eee222222eeeee6655002aa888889aaaa988aaaaaaaaaaaaaaaaaaa22a2210000000000000
ccccccc561ddddddd222244d211aa11113bbbbbbbbbbb944dddddeeeeeeeeeeeeeee66550012aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2210000000000000000
ccccccc615ddddddd2222222333333333bbbbbbbbbbb9a33445449eee4444549eee54444000122aaaaaaaaaaaaaaaaaaaaaaaaaaa22222100000000000000000
ccccccc15ddddcccd5222222333d44449bbbbbbbbbb9a9d4454444454444544444544444000012222aaaaaaaaaaaaaaaaaaa2222222100000000000000000000
cccccccdddcccccccccccd52d44444aaa9dddcccccccaad454444454444544444544444500000001222222222222222222222221000000000000000000000000
cccccccccccccccccccccccc44444aa9ddddcccccccddd4444444544445444445444445400000000011222222222222222211000000000000000000000000000
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
000000000000000000002c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000002d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000c1c0d0d0d1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004d3c3c3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004c3c3c3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004c3d3d3d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004c3d3d3d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000003030000300303000435508355043250b350083250e3500e352093550535509355093250c35009355003000c325043550c30008355043250b350083250935009352093520235105350093250935505325
011000001455014024104301002417556140241043014412155501503211430110241855615024114301541214550150241043010024205502003210430144122655026044114301102418556150241834315412
01100000303551c00230312000001c0501c02214420144121d0501d022000000000021050210221442018412303551700030312000001c5501c522144201741229550295221d0221d0321d137211371d23721227
011000000c35300300303000435524663043250b350083250c3530e352093550535524663093250c350093550c3530c325043550c30024663043250b350083250c3530935209352023512b6422b6250935530643
01100000145501402410430100241755614024104301441215550150321143011024185561502411430154121455015024104301002428014280321755014320180032902429566110242b0062b0041145030602
01100000303551c00230312000001c0501c0221442014412303551d02230312000002105021022144201841230355170003031200000303551c522144201741230355295221d0221d03230355211371d23721227
010f00001034304412044120445010343084120b4500b412103430e4120e4120e4121034308412084120945010343094120945009412103430941207450074121034306412064120641210343054120541204450
010f00001034310455044500441210343064120645006412103430741207412084501034308412084120945010343124501241212412103431521214255152551034315212094550945010343094120940009415
010f00001034310455044500441210343064120645006412103430741207412084501034308412084120945010343124501241212412103431521214255132551034321245202452124210343044120442204432
010f00001034305412054120545010343094120c4500c412103430f4120f4120f4121034309412094120a450103430a4120a4500a412103430a41208450084121034307412074120741210343064120641205450
010f00001034311455054500541210343074120745007412103430841208412094501034309412094120a4501034313450134121341210343162121525514255103431f2451e2451f245103431f2251f2021f215
010f000012343064120641206450123430a4120d4500d41212343104121041210412123430a4120a4550b450123430b4120b4500b412123430b41209450094121234308412084120841212343074120745506450
010f0000123431245506450064121234308412084500841212343094120941209312123430a4120a4120b450123431a210172521721212343152121325213212123430e2120b2500b21212343092120725007212
010f00001034311455054500541210343074120745007412103430841208412084121034309410094120a450103431345013412134121034310312103121031210343113120d3400d312103430e3120334003312
010f00001034310455044500441210343064120645006412103430741207412084501034308412084550945009312093121135412351133511534115332153220e3550e3550f3551035010312103120940000000
010f00001051014510175121a5121052014520175201a5101051014510175121a5121052014520175201a51015510195101c51221512105201952021520195101051012510135121951213520125201052012510
010f00001051014510175121a5121052014520175201a5101051014510175121a5121052014520175201a51015510195101c51221512192551925518255192501923219212135121951213520125201052012510
010f00001051014510175121a5121052014520175201a5101051014510175121a5121052014520175201a51015510195101c51221512192551925518255172501723217212135121951213520125201052012510
010f0000185101b5101d512185121b5461d526185101b5101d510185101b5121d512185461b5261d51018510145101a5101d512145121a5461d526145101a5101f510145101a5121d51220546265261d51020510
010f0000185101b5101d512185121b5461d526185101b5101d510185101b5121d512185461b5261d51018510145101a5101d512145121a2551a25519255182501154613526145121a5120e546135261152013510
010f0000195101c5101e512195121c5461e526195101c5101e510195101c5121e512195461c5261e51019510155101b5101e512155121b5461e526155101b51020510155101b5121e51221546275261e51021510
010f0000195101c5101e512195121c5461e526195101c5101e510195101c5121e512195461c5261e5101951023220232121f2201f21219220192121a2201a21217220172121f2201f21219220192121a2201a222
010f00001d2211d2201d2121d2111b5461d526185461b5261d546185261b5121d546185261b5121d51218512145461a5261d546145261a5461d526145461a5261f546145261a5121d5461d5261b5121d51220512
010f0000185461b5261d546185261b5461d526185461b5261d546185261b5121d546185261b5121d51218512145461a5261d54614526193301932019312193121a3201a3121d3201d3121d3201d3121f3201f312
010f00001c3211c3201c3121c3121a5461c526175461a5261c546175261a5121c546175261a5121c5121751213546195261c54613526195461c52613546195261e54613526195121c5461c5261a5121c5121f512
010f0000175461a5261c546175261a5461c526175461a5261c546175261a5121c546175261a5121c5121754613526195101931019310193101932219322193221e3351e3351f3352033513500125001050012500
010f000000605006241863518645246550c6150c635006150c625006051863518645246550c6550c6350061500605006241863518645246550c6150c635006150c62500605186351864524655186551863500615
010f000021630216222161221612246550c6150c635006150c625006051863518645246550c6550c6350061500605006241863518645246550c6150c635006150c62500605186351864524655186551863500615
010f000000605006241863518645246550c6150c635006150c625006051863518645246550c6550c6351832318303006001860018600246000c6001f6151f6152463524635246452163021622216121863518645
000e00001c4501c41519452194153062317432154521545210450104150d45230615306230b432094520945206451064400643206432064220642206415064551245012415020000200002000020000200002000
010e00002d3442d33228342283122734728312253422531221344213321c3421c3121b3441b31219342193121e3141e3201e3301e3401e3421e3421e3421e3421e3221e312020000200002000020000200002000
010e00000e3432541221420214120e3431b4121c4201c4120e34319412214200e3430e3431b4120e3431c4120e3432231022310223222232222322223220e3432665522315223050200002000020000200002000
011000000535002000053101a40009350020000c350093100f3500c3100f31002000093500200009310020000a350020000a310020000a35002000083500a3100735008310073100200006350020000631002000
010f00000935509355043550935504355093551035504350043400434203351023510134100331003210031100000000000000000000000000000000000000000000000000000000000000000000000000000000
010f0000000000000000000000002135521355213552035120350203502035220342203322032220312203121c355235002250121501000000000000000000000000000000000000000000000000000000000000
010f00000000000000000000000524555245552455523550235502353223522235122340023400234002340016000190001d00022000234022340223402234020730008300073000200006300020000630002000
0107000030510325313252232512325120c0000c0000c0000000032510325313252232402324023240030401000000000030510325313252232512325120c5000c50032510325223253132522315113051100000
010f00001c0501c022175301007514070100321753000000140120000017070170721a0711a0701a0721a07215070000001553015075100701503215530000001507015070150721507214070150321553011070
010f0000100700000010032100751407010032100720000010032000001a0701a072210712107021072200722107000000210321c075150701c03210032000001a0701a0701a0621a0521b0701b0701b0621b051
010f00000c553000001c5301c11213553000001c530000000c553000000c55300000145501405014530141120c553000001953019112135530000019550000000c55300000135530000010550100500f5300f112
010f00000c553000001c5300c55313553000001c530135530c503135530c553000001c5501c0501c5301b1120c5531c532155301511213533000000c5530c5531e0101e0101e0221e0221f0301f0301f0421f041
01080000295752857526575245752957528575265752457522570225722202222025285702857028032280202a5712a5702a0222a0222a0222a0122a0122a012000002a015000000000000000000000000000000
010800001c0221c0221c0221c02223021230222302223022260312603226032260322457024570240322402026570265702602226022260222601226012260120000026015000000000000000000000000000000
010d000012555145551555015550155521451212550125501255015512105500f5110e5110d511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00001775517755127501275012752127121575015750157501571214750147321472214712000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000231002311023110231102311023110231102311023110231103311023110331102311033110231103321023210332102321033210232103321033210332103321033210332103321033210332103321
010800000e2300e2100e212022350b2300b2100b2120e21209240092100b2260b212072400721007212092450e3400e3200e312023450b3400b3200b3120231209350093300b3260b31207350073300731209312
011000000b35304230044220425025655082200b2502a6150e2502a6150b35302200256552641527435284350b35304255042552a61525655082200b2300b4150e2502a6150b3532643525655234352565525655
011000000c353052301d4100525026655092201d4202b6150f2502b6151d4301d41226655274151d440294350c353052551d4442b61526655092201d4440c4150f2502b6151d4412743526655244351d44326655
011000000d35306230284222a250276552a2200d2502c615102502c6150d353283202765528415294352a4350d35306255282552d245276552d2202a2350d415102502d0350d3532843527655254352a23227655
011000000e3532b2300742207250286552b2122b2502d6152645726437234271f417286500e353286550e3530e3532b230072552b230286550b2202a2300e4152645726437234271f41728655234222341228655
011000000e3532b2300742207250286552b2122b2502d6152645726437234271f417286500e353286550e3530e353224101f4521f412286551d4121b3521b3120e35316312133501331228655113120f3500f312
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001833305310053300533018333083100c3100c330183330b3100b3300b330183330831008330083301833305310053300533018333093100c3100c330183330f3100f3300f33018333003100033000330
010f0000112351123513235132351423014212100000000022405000002040500000142351423513235132351123511235132351323514230142122040520400204051c000244302441222430204201d4351b425
010f00001d4301d4301d4221d4121423014212100000000022405000002040500000142351423513235132351123511235132351323514230142122040520400204051c000244302441222430204201d4351b425
010f00001d5201d51200000000002052020512000000000020520000001e52020512205201e512205120000020520000001e52020512205201b512205120000020520000001e52020512195201e5121e52019512
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000193511a3511c2511e2511e25220252202422024220232202322023220332203321d3521a3511b3511c3511e3511e3411e3511e3421e3521e3421e3521e3421e3321e3321e0221e0221e0121e0221e012
01040000263502b3502f35032350263402b3402f44232432284322c4222f42234422294222d4123041235412294152d41530415354150c0000c0000c0000c0000000000000000000000000000000000000000000
01050000186101a6201c6321d6421c6321a622186151c6152461526625286351d645246452d6352b625296152461526605286151d605246152d6052b615296050000000000000000000000000000000000000000
0106000024365284252431500000000000000000000000001f3731f37300000000000000000000000000000018350183551735017355163501635515350153552435024355263502635528350283552935029355
010500001f3531f63024652216421d6301a640186201f610186251864518655186750c635186750c63518675197771b7671e746207262270025700277001970013155131551525515405182550c575125751e305
__music__
01 00 01 02 44
02 03 04 05 44
01 06 0f 1a 44
00 07 10 1a 44
00 06 0f 1a 44
00 08 11 1a 44
00 09 12 1a 44
00 0a 13 1a 44
00 0b 14 1b 44
00 0c 15 1a 44
00 09 16 1b 44
00 0d 17 1a 44
00 06 18 1b 44
02 0e 19 1c 44
00 1d 1e 1f 44
03 20 42 43 44
00 21 22 23 44
03 24 42 43 44
01 25 27 1a 44
00 25 27 1b 44
00 25 27 1a 44
02 26 28 1b 44
00 2d 42 43 44
00 2e 42 43 44
01 2f 42 43 44
00 2f 42 43 44
00 30 42 43 44
00 30 42 43 44
00 31 42 43 44
00 31 42 43 44
00 32 42 43 44
02 33 42 43 44
00 36 37 39 1a
03 36 38 39 1a
00 29 2a 43 44
00 2b 2c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
