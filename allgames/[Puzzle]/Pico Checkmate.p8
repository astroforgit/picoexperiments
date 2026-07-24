pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pico checkmate
-- by lazy devs

function _init()
 pirate,ver,url=true,"v6",stat(102)
 whitecpu,blackcpu,b_offset,shake,whiteout,scroll_x,scroll_y,thinkdts,cpucur_x,cpucur_y,cpuwait,cpuspeed,cpumove,cputhinking,cpu_leaf1,cpu_leaf2,peevee,cpu_time_start,cpu_time_end=false,true,16,0,0,0,0,{},0,0,0,10,nil,false,0,0,{},0,0
 wlist={0,"www.lexaloffle.com","v6p9d9t4.ssl.hwcdn.net","game.itch","www.playpico.com","uploads.ungrounded.net","game296419.konggames.com"}
 for e in all(wlist) do
  if (url==e) pirate=false
 end

 igm,igm_x,igm_y,igm_w,igm_h,igm_dh,igm_content,igm_sel,igm_cputrgt,igm_col,seloffset,seloffset2,selani,dpal,bigt_off,igm_add,igm_fillc,pice_outlline,text_ol=false,0,0,0,0,0,nil,1,1,1,0,0,0,explode"0,1,1,2,1,13,6,4,4,9,3,13,1,13,14",explode"-2,0,2,2,2,0,2,2,0,-2,2,2,0,2,2,2,-1,-1,2,2,2,2,2,2,-2,2,2,2,1,-1,2,2,0,3,2,2,-1,3,2,2,1,3,2,2,-1,0,2,7,1,0,2,7,0,1,2,7,0,-1,2,7",explode"-3,-4,-4,-3,-2,-2,-1,-1,0,0,3,5,4,4,2,2,1,1,0,0",explode"2,2,7,2,6",explode"-1,0,1,0,0,-1,0,1,-1,-1,1,1,-1,1,1,-1",explode"-1,0,1,0,0,-1,0,1,-1,1,-1,-1,1,1,1,-1"

 --pos values
 t_offboard,t_empty,t_white,t_black,t_pawn,t_knight,t_bishop,t_rook,t_queen,t_king,wkcp,wqcp,bkcp,bqcp,spritelist,backrow,promolist,pdirections,ponemove=-2,0,1,-1,1,2,3,4,5,6,0b0001,0b0010,0b0100,0b1000,explode"4,8,10,6,12,14",explode"4,2,3,5,6,3,2,4",explode "5,4,3,2" ,explode "0,8,4,4,8,8",explode "1,1,0,0,0,1"

 -- evaluation
 init_eval()
 --hash keys
 genkeys()

 --movement offsets
 poffset={
 {},
 explode"-21,-19,-12,-8,8,12,19,21",
 explode"-11,-9,9,11",
 explode"-10,-1,1,10",
 explode"-11,-10,-9,-1,1,9,10,11",
 explode"-11,-10,-9,-1,1,9,10,11"
 }

 mailbox64,inv64,mailbox120,mailbox120x,mailbox120y={},{},{},{},{}
 for x = 0,119 do
  mailbox120[x],mailbox120x[x],mailbox120y[x]=-1,-1,-1
 end
 for x = 0,7 do
  for y = 0,7 do
   local k,mb=x+y*8,21+10*y+x
   mailbox64[k]=mb
   inv64[k]=x+(7-y)*8
   mailbox120x[mb],mailbox120y[mb],mailbox120[mb]=x,y,k
  end
 end
 show_logo()
end

function _update60()
 upd()
 fadeperc=max(fadeperc-0.05,0)
end

function _draw()
 local i
 drw()
 if (fadeperc>0) dofade()
 if whiteout>0 then
  whiteout-=1
  for i=0,15 do
   pal(i,7,1)
  end
 end
end

function show_logo()
 wait,upd,drw,fadeperc=60,update_logo,draw_logo,0
end

function show_menu()
 cls()
 logo1_y,igmwait,wait,mnucur,upd,drw,igm_content,igm_x,igm_y,igm_w,igm_h,igm_dh,igm,igm_sel=-300,60,10,2,update_menu,draw_menu,igm_menu,22,88,84,0,52,true,2
end

function start_game()
 cls(0)
 igm,movedots,bigt,board,upd,drw,uimode,sel_x,sel_y,cur_x,cur_y,movesdirty,cpumove,check,infotextd,infotext=false,{},{},newpos(),update_game,draw_game,"select",3,3,3,3,true,nil,false,"",""
 startboard_classic(board)
 anistart()
end

function cputurn()
 --returns if it's the computer's turn
 if board.side==t_white then
  return whitecpu
 else
  return blackcpu
 end
end

function lerp(_v,_d,_t)
 return _v+(_d-_v)*_t
end

--outputs a parabolic arc
--for "jumping" pieces
function jlerp(_v,_t)
 return sin(_t/2)*_v
end

function tween_cubic(_t)
 if _t<0.5 then
  return 2*_t*_t
 else
  return -1+(4-2*_t)*_t
 end
end

function distance(x1,y1,x2,y2)
 local dx=x1-x2
 local dy=y1-y2
 return sqrt(dx*dx+dy*dy)
end
-->8
-- ui stuff
function drawpiece(x,y,piece,side,outline)
 -- draws a chess piece
 -- x and y are pixel locations
 -- piece is piece
 -- side means color
 -- outline refers to red outline for preview take moves
 local sprite,otlp,i=spritelist[piece],0

 if outline then
  pal(7,8)
  --pal(6,8)
  pal(0,8)
  palt_red()
  if (seloffset2==0) otlp=#pice_outlline/2
  for i=0,#pice_outlline/4-1 do
   spr(sprite,x+pice_outlline[i*2+1+otlp],y+pice_outlline[i*2+2+otlp],2,2)
  end
  pal()
 end
 palt_red()
 if side==t_black then
  pal_blk()
 else
  pal_gb()
 end
 spr(sprite,x,y,2,2)
 pal()
end

function makemovedots(list)
 --fills movedots with locations
 --of possible destinations for a piece
 --list -> list of moves
 local x
 movedots={}
 for x=0,119 do
  movedots[x]=0
 end
 if list!=nil and #list>0 then
  for x = 1,#list do
   local mylist=list[x]
   local thisdot
   if mylist.cap then
    if mylist.enpas then
     thisdot=3
     if board.side==t_white then
      movedots[mylist.to+10]=4
     else
      movedots[mylist.to-10]=4
     end
    else
     thisdot=2
    end
   else
    if mylist.castle==0 and mylist.promo==t_empty then
     thisdot=1
    else
     thisdot=3
    end
   end
   movedots[mylist.to]=thisdot
  end
 end
end

function drawarrow(x1,y1,x2,y2,col,angle)
 -- draws and arrow from one tile to another
 if not(x1==x2 and y1==y2) then
  local dx,dy=x2-x1,y2-y1
  local ang,dist=atan2(y2-y1, x2-x1),sqrt(dx*dx + dy*dy)
  local ang2=ang+0.25

  -- stop the stem of the arrow short to allow for arrowhead
  local newx2,newy2=x1+sin(ang)*(dist-7),y1+cos(ang)*(dist-7)

  -- variables for the stem
  local sang2,cang2=sin(ang2),cos(ang2)
  local stem={
   x1+sang2*3,
   y1+cang2*3,
   x1-sang2*3,
   y1-cang2*3,
   newx2-sang2*3,
   newy2-cang2*3,
   newx2+sang2*3,
   newy2+cang2*3
  }
  local tmparr={
   newx2+sang2*6,
   newy2+cang2*6,
   newx2-sang2*6,
   newy2-cang2*6,
   x2,y2
  }
  -- render stem
  render_poly(stem,col)
  -- render arrowhead
  render_poly(tmparr,col)
 end
 -- render blob
 pal(8,col)
 spr(64,x1-8,y1-7,2,2)
 pal()
end

function render_poly(v,col)
 col=col or 5
 local x1,x2={},{}
 for y=0,127 do
  x1[y],x2[y]=128,-1
 end
 local y1,y2=128,-1
 for i=1, #v/2 do
  local next=i+1
  if (next>#v/2) next=1
  local vx1,vy1,vx2,vy2=flr(v[i*2-1]),flr(v[i*2]),flr(v[next*2-1]),flr(v[next*2])
  if vy1>vy2 then
   local tempx,tempy=vx1,vy1
   vx1,vy1=vx2,vy2
   vx2,vy2=tempx,tempy
  end
  if vy1~=vy2 and vy1<128 and vy2>=0 then
   if (vy1<0) vx1,vy1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1,0
   if (vy2>127) vx2,vy2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1,127
   for y=vy1,vy2 do
    if (y<y1) y1=y
    if (y>y2) y2=y
    x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    if (x<x1[y]) x1[y]=x
    if (x>x2[y]) x2[y]=x
   end
  end
 end
 for y=y1,y2 do
  local sx1,sx2,c=flr(max(0,x1[y])),flr(min(127,x2[y])),col*16+col
  local ofs1,ofs2=flr((sx1+1)/2),flr((sx2+1)/2)
  memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
  pset(sx1,y,c)
  pset(sx2,y,c)
 end
end

function cprint(t,x,y,c)
 --centered print
 print(t,x-#t*2,y,c)
end

function print_border(t,x,y)
 for i=0,7 do
  print(t,x+text_ol[i*2+1],y+text_ol[i*2+2],2)
 end
 print(t,x,y,7)
end

function cprint_border(t,x,y)
 --centered print with border
 local rx,i=x-#t*2
 print_border(t,rx,y)
end

function palt_red()
 palt(0, false)
 palt(8, true)
end

function pal_gb()
 pal(0,2)
 pal(5,13)
end

function pal_blk()
 pal(7,2)
 pal(6,2)
 pal(0,7)
end

function pal_blk2()
 pal(7,2)
 pal(6,13)
 pal(5,13)
 pal(0,7)
end

function curani()
 --cursor animations
 selani+=1
 if selani>38 then
  selani,seloffset=0,0
 elseif selani>28 then
  seloffset=1
 end
 seloffset2 = 0
 if ((flr(selani/8))%2==1) seloffset2=1
end

function fadeout(spd)
 if (spd==nil) spd=0.04
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
end

function dofade()
 -- 0 means normal
 -- 1 is completely black
 local p,kmax,col,j,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=(p+(j*1.46))/22
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end




function anistart()
 local x,s,w,b,i
 uimode,a_board="ani",board
 board,anis,w,b=newpos(),{},0,0
 for x=21,98 do
  if a_board.piece120[x]>0 then
   if a_board.color120[x]==t_black then
    s=-3
    b+=1
    i=b
   else
    s=-1
    w+=1
    i=w
   end
   local a=anipiece(a_board.piece120[x],a_board.color120[x],s,x)
   a.d=20+flr(i*1.5+(rnd(15)))
   a.sfx_start=-1
   add(anis,a)
  end
 end
end

function anipiece(piece,side,from,to)
 local tx,ty,tx2,ty2
 if from==-1 then
  tx,ty=-1,-1
 elseif from==-3 then
  tx,ty=8,-1
 else
  tx,ty=mailbox120x[from],mailbox120y[from]
 end
 if to==-1 then
  tx2,ty2=-1,-1
 elseif to==-3 then
  tx2,ty2=8,-1
 else
  tx2,ty2=mailbox120x[to],mailbox120y[to]
 end

 local d=distance(tx,ty,tx2,ty2)
 return {
  piece=piece,
  c=side,
  x=tx*16,
  y=b_offset-3+ty*14,
  fx=tx*16,
  fy=b_offset-3+ty*14,
  dx=tx2*16,
  dy=b_offset-3+ty2*14,
  j=0,
  mj=d*4,
  t=0,
  t_spd=0.2/d,
  d=0,
  sfx_start=4,
  sfx_end=5
 }
end

function animove(pos,mov)
 local a1,a2
 uimode,a_board,anis="ani",clonepos(pos),{}
 makemovedots({})
 makemove(a_board,mov)
 a1=anipiece(pos.piece120[mov.from],pos.color120[mov.from],mov.from,mov.to)
 add(anis,a1)
 clearpiece(pos,mov.from)

 if mov.cap then
  local takenpos=mov.to
  if mov.enpas then
   takenpos=mov.to+10
   if pos.side==t_black then
    takenpos=mov.to-10
   end
  end
  local od=pos.color120[takenpos]-2
  a2=anipiece(pos.piece120[takenpos],pos.color120[takenpos],takenpos,od)
  a2.d=flr(1/a1.t_spd)-4
  a2.sfx_start=6
  a2.sfx_end=-1
  a2.t_spd=a2.t_spd*1.5
  add(anis,a2)
  clearpiece(pos,takenpos)
 elseif mov.castle!=0 then
  local rookfrom,rookto
  if (mov.castle==wkcp) rookfrom,rookto=98,96
  if (mov.castle==wqcp) rookfrom,rookto=91,94
  if (mov.castle==bkcp) rookfrom,rookto=28,26
  if (mov.castle==bqcp) rookfrom,rookto=21,24

  a2=anipiece(pos.piece120[rookfrom],pos.color120[rookfrom],rookfrom,rookto)
  a2.d=10
  add(anis,a2)
  clearpiece(pos,rookfrom)
 end
end

function finishani()
 uimode,board,sel_x,sel_y,movesdirty="select",a_board,cur_x,cur_y,true
 roundstart()
end

function roundstart()
 itext("black to move")
 if board.side==t_white then
  itext("white to move")
 end
 winconditions()
end

function newbigt(srcx,srcy,srcw,srch,inv)
 local tx=64-flr(srcw/2)
 return {
  x=tx,
  y=-32,
  sy=0,
  sx=0,
  dx=tx,
  dy=58,
  t=60,
  move=true,
  srcx=srcx,
  srcy=srcy,
  srcw=srcw,
  srch=srch,
  inv=inv,
  muzak=0,
  txt="check"
 }
end

function showcheck(_blk)
 add(bigt,newbigt(32,16,53,16,_blk))
end

function showmate(_blk)
 if _blk then
  itext("black wins!")
 else
  itext("white wins!")
 end
 local mytc,myt=newbigt(32,16,53,16,_blk),newbigt(85,16,43,16,_blk)
 uimode,mytc.t,myt.x,myt.dx,myt.y,myt.dy,myt.sx,myt.move,myt.txt,myt.t,myt.muzak="over",0,130,70,58,58,-5,false,"mate",70,1
 add(bigt,mytc)
 add(bigt,myt)
end

function showdraw()
 local myt=newbigt(32,32,49,16,false)
 uimode,myt.txt,myt.t="over","draw",0
 add(bigt,myt)
end

function bigtext(myt)
 bigtextdraw(myt.x,myt.y,myt.srcx,myt.srcy,myt.srcw,myt.srch,myt.inv)
end

function bigtextdraw(tx,ty,sx,sy,w,h,inv)
 local c=3
 if (inv==true) c=4
 local i
 palt_red()
 for i=0,#bigt_off/4-1 do
  pal(7,bigt_off[i*4+c])
  sspr(sx,sy,w,h,tx+bigt_off[i*4+1],ty+bigt_off[i*4+2])
 end
 pal(7,7)
 if (inv) pal(7,2)
 sspr(sx,sy,w,h,tx,ty)
 pal()
end

function update_bigtext()
 local mybt,i

 for i=#bigt,1,-1 do
  mybt=bigt[i]
  if mybt.move then
   if mybt.y!=mybt.dy then
    mybt.y+=mybt.sy
    mybt.sy+=0.5
    if mybt.y>mybt.dy then
     mybt.y,mybt.move=mybt.dy,false
     if mybt.y>128 then
      del(bigt,mybt)
     else
      if mybt.txt=="draw" then
       show_gamemnu()
       igmwait,uimode,igm_sel,whiteout=60,"over",2,4
       shake+=0.2
      else
       shake+=0.1
      end
      music(mybt.muzak)
     end
    end
   end
   if mybt.x!=mybt.dx then
    mybt.x+=mybt.sx
    mybt.sx-=0.5
    if mybt.x<mybt.dx then
     mybt.x,mybt.move=mybt.dx,false
     shake+=0.2
     local j
     for j=1,#bigt do
      if bigt[j].txt=="check" then
       bigt[j].x,bigt[j].dx=mybt.x-55,mybt.x-55
      end
     end
     show_gamemnu()
     igmwait,uimode,igm_sel,whiteout=60,"over",2,4
     music(mybt.muzak)
    end
   end
  else
   if mybt.t>0 then
    mybt.t-=1
    if mybt.t<=0 then
     mybt.t,mybt.move=0,true
     if (mybt.txt=="check") mybt.sy,mybt.dy=0,130
    end
   end
  end
 end
end

function show_promo(side)
 uimode,igm_content,igm_x,igm_y,igm_w,igm_h,igm_dh,igm,igm_col,igm_sel="promo",igm_promo,22,65,84,0,34,true,side,1
end

function update_igm()
 if igmwait>0 then
  igmwait-=1
  if (igmwait<=0) sfx(3)
  return
 end
 if igm_dh!=igm_h then
  igm_h+=(igm_dh-igm_h)/4
  if (abs(igm_dh-igm_h)<0.5) igm_h=igm_dh
  if (igm_h==0) igm=false
 end
end

function draw_igm()
 if (igm==false or igm_h==0) return
 local y1=igm_y-(igm_h/2)
 local x2,y2,i=igm_x+igm_w-1,y1+igm_h-1

 for i=0,#igm_add/4-1 do
  rectfill(igm_x+igm_add[i*2+1],y1+igm_add[i*2+2],x2+igm_add[i*2+1+#igm_add/2],y2+igm_add[i*2+2+#igm_add/2],igm_fillc[i+1])
 end
 igm_content(igm_x,y1,igm_w,igm_h)
end

function igm_promo(x,y,w,h)
 local px,i,cx,cy={5,24,44,64}

 clip(x,y,w,h)
 rectfill(x+1,y+1,x+w-2,y+7,2)
 cprint("promote pawn",64,y+2,7)
 for i=1,#px do
  cy=y+14
  if (i==igm_sel) cy-=1
  drawpiece(x+px[i],cy,promolist[i],igm_col,false)
 end
 clip()
 cx=px[igm_sel]+seloffset+8
 cy=24+seloffset
 if (h>cy) drawhandcursor(x+cx,y+cy,board.side)
end

function igm_menu(x,y,w,h)
 clip(x,y,w,h)
 if (pirate) then
  print_border("play this game at",x+8,y+15)
  print_border("bit.ly/picocheckmate",x+3,y+26)
  return
 end
 drawpiece(x+4,y+2,t_pawn,t_white)
 drawpiece(x+4,y+18,t_pawn,t_black)
 local bx,bw=x+18,x+80
 if (igm_sel==2) bx,bw=x+27,x+69
 rectfill(bx,y+6+16*igm_sel,bw,y+16+16*igm_sel,7)
 local mct1,mct2="human","human"
 if (whitecpu) mct1="computer"
 if (blackcpu) mct2="computer"

 palt(8,true)
 if igm_sel<2 then
  sspr(8,48,5,7,x+23-seloffset,y+8+16*igm_sel)
  sspr(8,48,5,7,x+69+seloffset,y+8+16*igm_sel,5,7,true,false)
 end
 cprint_border(mct1,x+49,y+9)
 cprint_border(mct2,x+49,y+25)
 cprint_border("play",x+49,y+41)

 palt_red()
 pal_gb()
 local cx=x+seloffset-11
 if (igm_sel==2) cx+=24
 clip()
 spr(66,cx,y+7+igm_sel*16,2,2)
 pal()
end

function drawhandcursor(x,y,col)
 palt_red()
 pal_gb()
 if col==t_black then
  spr(101,x,y,2,2)
 else
  spr(2,x,y,2,2)
 end
 pal()
end

function setcpucur(loc)
 cpucur_x,cpucur_y=mailbox120x[loc],mailbox120y[loc]
end

function itext(s)
 infotext,infotextd="",s
end

function update_itext()
 if infotext!=infotextd then
  sfx(12)
  infotext=sub(infotextd,1,#infotext+1)
 end
end

function add_thinkdts()
 add(thinkdts,128)
end

function update_thinkdts()
 local d,dd,i=#infotext*4+3
 for i=1,#thinkdts do
  dd=d+i*3
  if (not cputhinking) dd=128+i*3
  thinkdts[i]+=(dd-thinkdts[i])/10
 end
end

function draw_thinkdts()
 for i=1,#thinkdts do
  pset(thinkdts[i],9,7)
 end
end

function show_gamemnu()
 uimode,igm_content,igm_x,igm_y,igm_w,igm_h,igm_dh,igm,igm_sel="gmenu",igm_gamemnu,32,102,64,0,37,true,0
end

function igm_gamemnu(x,y,w,h)
 local txt,i={"take back","restart","quit"}
 clip(x,y,w,h)
 rectfill(x+7,y+3+igm_sel*10,x+60,y+13+igm_sel*10,7)
 for i=1,#txt do
  print_border(txt[i],x+10,y-4+i*10)
 end
 palt_red()
 pal_gb()
 clip()
 i=3+igm_sel*10
 if (h>i+6) spr(66,x-10+seloffset,i+y,2,2)
 pal()
end

-->8
-- game logic stuff

function newpos()
 local x
 local pos={
  king_w=0,
  king_b=0,
  piece120={},
  color120={},
  enpas=-1,
  castleperm=0b1111,
  cancastle=-1,
  fiftymove=0,
  ply=0,
  poskey=0,
  side=true,
  history={}
 }

 --fill it with offboard values first
 for x = 0,119 do
  pos.piece120[x],pos.color120[x]=t_offboard,t_offboard
 end
 --now set empty squares
 for x = 0,63 do
  local mb=mailbox64[x]
  pos.piece120[mb],pos.color120[mb]=t_empty,t_empty
 end

 return pos
end

--makes a duplicate of a board position
function clonepos(origa)
 local pos,x=newpos()
 pos.king_w,pos.king_b,pos.enpas,pos.castleperm,pos.cancastle,pos.fiftymove,pos.ply,pos.poskey,pos.side=origa.king_w,origa.king_b,origa.enpas,origa.castleperm,origa.cancastle,origa.fiftymove,origa.ply,origa.poskey,origa.side
 for x = 0,119 do
  pos.piece120[x],pos.color120[x]=origa.piece120[x],origa.color120[x]
 end
 --note: this copies by reference
 --might be not what we want?
 if #origa.history>0 then
  for x = 1,#origa.history do
   pos.history[x]=origa.history[x]
  end
 end
 return pos
end

function genmove(list,from,to,kind,pos,promo)
 -- generates a move

 -- kind - indicating the type of move
 --      - 0 quiet (no capture)
 --      - 1 capture
 --      - 2 enpas
 --      - 3 king side castle
 --      - 4 qeen side castle
 local piece,side=pos.piece120[from],pos.color120[from]
 local mov={
  from=from,
  to=to,
  prevenpas=pos.enpas,
  cap=false,
  enpas=false,
  castle=0,
  cappiece=t_empty,
  prevcastleperm=pos.castleperm,
  prevcancastle=pos.cancastle,
  promo=t_empty,
  prevfifty=pos.fiftymove,
  val=0
 }
 if kind==1 then
  mov.cap,mov.cappiece=true,pos.piece120[to]
 elseif kind==2 then
  mov.cap,mov.enpas,mov.cappiece=true,true,t_pawn
 elseif kind==3 then
  mov.castle=bkcp
  if side==t_white then
   mov.castle=wkcp
  end
 elseif kind==4 then
  mov.castle=bqcp
  if side==t_white then
   mov.castle=wqcp
  end
 end
 if (promo!=nil) mov.promo=promo
 if (mov.cap) mov.val=1000+mvvlva[piece][mov.cappiece]
 if (mov.castle) mov.val+=90
 if (mov.promo==t_queen) mov.val+=900
 add(list,mov)
end

function startboard_classic(pos)
 local i
 for i=0,7 do
  restorepiece(pos,mailbox64[i+8],t_pawn,t_black)
  restorepiece(pos,mailbox64[i+48],t_pawn,t_white)
  restorepiece(pos,mailbox64[i],backrow[i+1],t_black)
  restorepiece(pos,mailbox64[i+56],backrow[i+1],t_white)
 end
 pos.side=t_white
end

function piecemoves(pos,loc120,list,attac)
 -- generates moves for a piece
 -- attac -> only capture moves
 local p,side,j,n,n2,col=pos.piece120[loc120],pos.color120[loc120]

 if p==0 then
  return
 elseif p!=t_pawn then
  --not pawn moves
  for j=1,pdirections[p] do
   n=loc120
   repeat
    n+=poffset[p][j]
    col=pos.color120[n]
    if col==t_empty and attac==false then
     --quiet move
     genmove(list,loc120,n,0,pos)
    elseif col==-side then
     --capture move
     genmove(list,loc120,n,1,pos)
    end
   until col!=t_empty or ponemove[p]==1
  end
  if p==t_king and attac==false then
   if (pos.cancastle==-1) checkcastle(pos)
   n=pos.cancastle
   if side==t_white then
    if (band(n,wkcp)==wkcp) genmove(list,loc120,97,3,pos)
    if (band(n,wqcp)==wqcp) genmove(list,loc120,93,4,pos)
   else
    if (band(n,bkcp)==bkcp) genmove(list,loc120,27,3,pos)
    if (band(n,bqcp)==bqcp) genmove(list,loc120,23,4,pos)
   end
  end
 else
  local promo,first=false,false
  --pawn moves
  if side==t_white then
   n=loc120-10
   n2=n-10
   first,promo=mailbox120y[loc120]==6,mailbox120y[n]==0
  else
   n=loc120+10
   n2=n+10
   first,promo=mailbox120y[loc120]==1,mailbox120y[n]==7
  end
  if pos.color120[n]==t_empty and attac==false then
   --quiet move
   if promo then
    addpromos(list,loc120,n,0,pos)
   else
    genmove(list,loc120,n,0,pos)
   end
   if first and pos.color120[n2]==t_empty then
    --quiet 2-step move
    genmove(list,loc120,n2,0,pos)
   end
  end
  if pos.color120[n-1]==-side then
   --capture move
   if promo then
    addpromos(list,loc120,n-1,1,pos)
   else
    genmove(list,loc120,n-1,1,pos)
   end
  elseif n-1==pos.enpas and attac==false then
   genmove(list,loc120,n-1,2,pos)
  end
  if pos.color120[n+1]==-side then
   --capture move
   if promo then
    addpromos(list,loc120,n+1,1,pos)
   else
    genmove(list,loc120,n+1,1,pos)
   end
  elseif n+1==pos.enpas and attac==false then
   genmove(list,loc120,n+1,2,pos)
  end
 end
end

function addpromos(list,from,to,kind,pos)
 genmove(list,from,to,kind,pos,t_queen)
 genmove(list,from,to,kind,pos,t_rook)
 genmove(list,from,to,kind,pos,t_bishop)
 genmove(list,from,to,kind,pos,t_knight)
end

function makemove(pos,mov)
 local side,piece,to,from=pos.color120[mov.from],pos.piece120[mov.from],mov.to,mov.from
 --set enpas
 if piece==t_pawn and mov.enpas==false and mov.cap==false then
  local dst=to-from
  if dst==-20 and side==t_white then
   pos.enpas=from-10
  elseif dst==20 and side==t_black then
   pos.enpas=from+10
  else
   pos.enpas=-1
  end
 else
  pos.enpas=-1
 end

 if mov.cap then
  if mov.enpas then
   if side==t_white then
    clearpiece(pos,to+10)
   else
    clearpiece(pos,to-10)
   end
  else
   clearpiece(pos,to)
  end
 end

 if mov.castle!=-1 then
  if (mov.castle==wkcp) movepiece(pos,98,96)
  if (mov.castle==wqcp) movepiece(pos,91,94)
  if (mov.castle==bkcp) movepiece(pos,28,26)
  if (mov.castle==bqcp) movepiece(pos,21,24)
 end

 if piece==t_king then
  if side==t_white then
   pos.castleperm=band(pos.castleperm,0b1100)
  else
   pos.castleperm=band(pos.castleperm,0b0011)
  end
 end
 
 if (from==98 or to==98) pos.castleperm=band(pos.castleperm,0b1110)
 if (from==91 or to==91) pos.castleperm=band(pos.castleperm,0b1101)
 if (from==28 or to==28) pos.castleperm=band(pos.castleperm,0b1011)
 if (from==21 or to==21) pos.castleperm=band(pos.castleperm,0b0111)
 
 pos.cancastle=-1
 movepiece(pos,from,to)
 if mov.promo!=t_empty then
  clearpiece(pos,to)
  restorepiece(pos,to,mov.promo,side)
 end
 pos.ply+=1
 pos.fiftymove+=1
 if (mov.cap or piece==t_pawn) pos.fiftymove=0
 pos.history[#pos.history+1]=mov
 pos.side=-pos.side
end

function takemove(pos)
 if (#pos.history==0) return
 local mov=pos.history[#pos.history]
 del(pos.history,mov)
 pos.enpas=mov.prevenpas

 local side=pos.color120[mov.to]
 if mov.promo!=t_empty then
  clearpiece(pos,mov.to)
  restorepiece(pos,mov.to,t_pawn,side)
 end

 movepiece(pos,mov.to,mov.from)
 if mov.cap then
  if mov.enpas then
   if pos.color120[mov.from]==t_white then
    restorepiece(pos,mov.to+10,t_pawn,t_black)
   else
    restorepiece(pos,mov.to-10,t_pawn,t_white)
   end
  else
   restorepiece(pos,mov.to,mov.cappiece,-pos.color120[mov.from])
  end
 end
 if mov.castle!=-1 then
  if (mov.castle==wkcp) movepiece(pos,96,98)
  if (mov.castle==wqcp) movepiece(pos,94,91)
  if (mov.castle==bkcp) movepiece(pos,26,28)
  if (mov.castle==bqcp) movepiece(pos,24,21)
 end
 pos.castleperm,pos.cancastle,pos.fiftymove,pos.side=mov.prevcastleperm,mov.prevcancastle,mov.prevfifty,-pos.side
end

function clearpiece(pos,loc120)
 if pos.piece120[loc120]!=t_empty then
  pos.poskey=addhash(pos.poskey,pos.piece120[loc120],pos.color120[loc120],loc120)
  pos.piece120[loc120],pos.color120[loc120]=t_empty,t_empty
 end

end

function movepiece(pos,from120,to120)
 local piece,side=pos.piece120[from120],pos.color120[from120]

 pos.poskey=addhash(pos.poskey,piece,side,from120)
 pos.poskey=addhash(pos.poskey,piece,side,to120)

 pos.piece120[to120],pos.color120[to120]=pos.piece120[from120],pos.color120[from120]
 pos.piece120[from120],pos.color120[from120]=t_empty,t_empty

 if pos.piece120[to120]==t_king then
  if pos.color120[to120]==t_white then
   pos.king_w=to120
  else
   pos.king_b=to120
  end
 end
end

function restorepiece(pos,loc120,pce,col)
 pos.poskey=addhash(pos.poskey,pce,col,loc120)

 pos.piece120[loc120],pos.color120[loc120]=pce,col
 if pos.piece120[loc120]==t_king then
  if pos.color120[loc120]==t_white then
   pos.king_w=loc120
  else
   pos.king_b=loc120
  end
 end
end

function getallmoves(pos,moves,side,attac)
 local x
 for x=21,98 do
  if pos.piece120[x]>0 and pos.color120[x]==side then
   piecemoves(pos,x,moves,attac)
  end
 end
end

function ischeck(pos,side)
 if side==t_white then
  return isattacked(pos,pos.king_w,t_black)
 else
  return isattacked(pos,pos.king_b,t_white)
 end
end

function isattacked(pos,loc,side)
 --pawn attacks
 local pwn1,pwn2
 if side==t_white then
  pwn1,pwn2=loc+11,loc+9
 else
  pwn1,pwn2=loc-11,loc-9
 end
 if (pos.color120[pwn1]==side and pos.piece120[pwn1]==t_pawn) return true
 if (pos.color120[pwn2]==side and pos.piece120[pwn2]==t_pawn) return true

 --rook, bishop and queen
 if (findatacker(pos,loc,side,t_rook)) return true
 if (findatacker(pos,loc,side,t_bishop)) return true

 --knight,king
 if (findatacker(pos,loc,side,t_knight)) return true
 if (findatacker(pos,loc,side,t_king)) return true

 return false
end

function findatacker(pos,loc,side,piece)
 local j,n,pce,col
 for j=1,pdirections[piece] do
  n=loc
  repeat
   n=n+poffset[piece][j]
   pce=pos.piece120[n]
   col=pos.color120[n]
   if (col==side and (pce==piece or (pce==t_queen and ponemove[piece]==0))) return true
  until col!=t_empty or ponemove[piece]==1
 end
 return false
end

function ismate(pos)
 local moves,m={}
 getallmoves(pos,moves,pos.side,false)
 if #moves>0 then
  for m in all(moves) do
   makemove(pos,m)
   if ischeck(pos,-pos.side)==false then
    takemove(pos)
    return false
   end
   takemove(pos)
  end
 end
 return true
end

function winconditions()
 --if player begins the turn checking the other one
 --we screwed up and its actually checkmate
 if ischeck(board,-board.side) then
  showmate(-board.side==t_white)
  return
 end

 if board.fiftymove >= 100 then
  itext("draw by fifty-move rule")
  showdraw()
  return
 end

 --now the regular check
 check=ischeck(board,board.side)
 if check then
  if ismate(board) then
   showmate(board.side==t_white)
   return
  else
   showcheck(board.side==t_white)
   return
  end
 end

 --now stalemate
 local moves={}
 getallmoves(board,moves,board.side,false)
 purgebadmoves(board,moves)
 if #moves==0 then
  itext("stalemate")
  showdraw()
 end

end

--removes discovered checks and mates
function purgebadmoves(pos,movs)
 local i,m
 for i=#movs,1,-1 do
  m=movs[i]
  makemove(pos,m)
  if (ischeck(pos,-pos.side)) del(movs,m)
  takemove(pos)
 end
end

function getbestmove()
 cpu_time_start,bestmove,peevee=time(),nil,{}

 local maxdepth,pos,j,v=3,clonepos(board)
 cpu_leaf1,cpu_leaf2=0,0

 for j=0,maxdepth do
  v=alphabeta(j,pos,-32767,32767)
  bestmove=peevee[pos.poskey]
  if (bestmove!=nil) setcpucur(bestmove.from)
  --logcutoffpurge()
 end
 cputhinking,cpumove=false,bestmove
 cpu_time_end=time()
 if (cpumove==nil) winconditions()
 --logcutoffpurge()
end

function alphabeta(depth,pos,alpha,beta)
 local side,moves,oldalpha,score,bestmove,i,m=pos.side,{},alpha

 if (pos.fiftymove >= 100) return 0

 if depth<=0 then
  addleaf()
  --return evalpos(pos)*side
  return quiescence(pos,alpha,beta)
 end

 getallmoves(pos,moves,side,false)
 purgebadmoves(pos,moves)

 if #moves==0 then
  if ischeck(pos,side) then
   return -mate
  else
   return 0
  end
 end
 awardpv(moves,pos.poskey)
 for i=1,#moves do
  m=picknextmove(moves,i)
  makemove(pos,moves[i])
  score=-alphabeta(depth-1,pos,-beta,-alpha)
  takemove(pos)
  if score>alpha then
   if (score>=beta) return beta
   alpha,bestmove=score,m
  end
 end
 if (oldalpha!=alpha) peevee[pos.poskey]=bestmove
 if (stat(1)>=0.87) yield()
 return alpha
end

function quiescence(pos,alpha,beta)
 local score,side,moves,oldalpha,bestmove,i,m=evalpos(pos)*pos.side,pos.side,{}

 addleaf()
 --check reptetition
 if (score>=beta) return beta
 if (score>alpha) alpha=score

 getallmoves(pos,moves,side,true)
 purgebadmoves(pos,moves)
 oldalpha=alpha
 awardpv(moves,pos.poskey)
 for i=1,#moves do
  m=picknextmove(moves,i)
  makemove(pos,moves[i])
  score=-quiescence(pos,-beta,-alpha)
  takemove(pos)
  if score>alpha then
   if (score>=beta) return beta
   alpha,bestmove=score,m
  end
 end
 if (oldalpha!=alpha) peevee[pos.poskey]=bestmove
 if (stat(1)>=0.87) yield()
 return alpha
end


function picknextmove(lst,i)
 local best,j,tmp,bestnum=-1

 for j=i,#lst do
  if lst[j].val>best then
   best,bestnum=lst[j].val,j
  end
 end
 tmp=lst[i]
 lst[i]=lst[bestnum]
 lst[bestnum]=tmp
 return lst[i]
end

function checkcastle(pos)
 local ret,prms,nprms,i,j,fp,s=pos.castleperm,{wkcp,wqcp,bkcp,bqcp},{0b1110,0b1101,0b1011,0b0111}
 local freepos={
  {96,97},
  {92,93,94},
  {26,27},
  {22,23,24}
 }
 local atcpos={
  {95,96,97},
  {95,93,94},
  {25,26,27},
  {25,23,24}
 }

 for i=1,4 do
  if band(ret,prms[i])==prms[i] then
   fp=freepos[i]
   for j=1,#fp do
    if pos.piece120[fp[j]]!=t_empty then
     ret=band(ret,nprms[i])
     break
    end
   end
  end
 end
 if ret==0b0000 then
  pos.cancastle=ret
  return
 end

 for i=1,4 do
  if band(ret,prms[i])==prms[i] then
   fp=atcpos[i]
   for j=1,#fp do
    s=t_black
    if (i>2) s=t_white
    if isattacked(pos,fp[j],s) then
     ret=band(ret,nprms[i])
     break
    end
   end
  end
 end
 pos.cancastle=ret
end

function addleaf()
 cpu_leaf1+=1
 if cpu_leaf1>=2000 then
  cpu_leaf2+=1
  cpu_leaf1-=2000--used to be 10000
 end
end

function addhash(key,piece,side,loc)
 local i=piece*loc
 if (side==t_black) i=(piece+6)*loc
 return bxor(key,piecekeys[i])
end

function genkeys()
 local i
 srand(1)
 piecekeys={}
 for i=1,12*119 do
  piecekeys[i]=rnd(-1)
 end
end

function awardpv(list,poskey)
 local i,pvm,m
 pvm=peevee[poskey]
 if pvm!=nil then
  for i=1,#list do
   m=list[i]
   if (m.from==pvm.from and m.to==pvm.to and m.promo==pvm.promo) m.val=32000
  end
 end
end
-->8
--update

function update_game()
 --cursor animations
 curani()
 update_itext()
 update_thinkdts()
 if uimode=="ani" then
  update_ani()
 elseif uimode=="over" or uimode=="gmenu" then
  update_gmenu()
 -- if btnp(4) or btnp(5) then
 --  fadeout()
 --  show_menu()
 -- end
 else
  if cputurn() then
   update_cpu()
  else
   if uimode=="promo" then
    update_promo_h()
   else
    update_human()
   end
  end
  -- regenerate moves if new piece
  if movesdirty then
   movesdirty,tmpmoves=false,{}
   piecemoves(board,mailbox64[sel_x+sel_y*8],tmpmoves,false)
   if (board.color120[mailbox64[sel_x+sel_y*8]]==board.side) purgebadmoves(board,tmpmoves)
   makemovedots(tmpmoves)
  end
 end
 update_bigtext()
 if (igm) update_igm()
end

function update_gmenu()
 local newcur=igm_sel
 if (btnp(2)) newcur-=1
 if (btnp(3)) newcur+=1
 newcur=newcur%3
 if newcur!=igm_sel then
  sfx(0)
  igm_sel=newcur
 end
 if btnp(4) then
  if uimode=="gmenu" then
	  sfx(1)
	  igm_dh,uimode=0,"select"
  end
 end
 if btnp(5) then
  sfx(13)
  if igm_sel==0 then
   fadeout(0.1)
   takemove(board)
   takemove(board)
   bigt,movesdirty,igm_dh,uimode={},true,0,"select"
   roundstart()
   igm,igm_h,igm_dh=false,0,0
  elseif igm_sel==1 then
   fadeout()
   start_game()
  elseif igm_sel==2 then
   fadeout()
   show_menu()
  end
 end

end

function update_human()
 local moved,nextx,nexty,i,loc120=false,cur_x,cur_y

 if btnp(4) and uimode=="select" then
  sfx(3)
  show_gamemnu()
  return
 end
 if (btnp(0)) nextx-=1
 if (btnp(1)) nextx+=1
 if (btnp(2)) nexty-=1
 if (btnp(3)) nexty+=1
 nextx,nexty = mid(0,nextx,7),mid(0,nexty,7)
 if nextx!=cur_x or nexty!=cur_y then
  sfx(0)
  moved=true
 end
 cur_x,cur_y,loc120=nextx,nexty,mailbox64[cur_x+cur_y*8]

 if uimode=="select" then
  sel_x,sel_y=cur_x,cur_y
  if (moved) movesdirty=true
  if btnp(5) then
   --check if moveable piecce
   -- if so, select it
   if (board.piece120[loc120]!=t_empty and board.side==board.color120[loc120]) then
    uimode="move"
    sfx(3)
   end
  end
 elseif uimode=="move" then
  if btnp(5) then
   if cur_x==sel_x and cur_y==sel_y then
    --cancel selection
 	  sfx(1)
    uimode,movesdirty="select",true
   else
   	for i = 1,#tmpmoves do
   	 if tmpmoves[i].to==loc120 then
   	  if tmpmoves[i].promo==t_empty then
       animove(board,tmpmoves[i])
   	  else
   	   show_promo(board.side)
 	     sfx(3)
      end
   	  break
   	 end
   	end
  	end
  elseif btnp(4) then
   --cancel selection
	 sfx(1)
   uimode,sel_x,sel_y,movesdirty="select",cur_x,cur_y,true
  end
 end

end

function update_ani()
 local ez_t,i,aniend,a
 aniend=0
 for a in all(anis) do
  if a.d>0 then
   a.d-=1
  else
   if a.t<1 then
    if (a.t==0 and a.sfx_start!=-1) sfx(a.sfx_start)
    a.t=min(a.t+a.t_spd,1)
    ez_t=tween_cubic(a.t)
    a.x,a.y,a.j=lerp(a.fx,a.dx,ez_t),lerp(a.fy,a.dy,ez_t),jlerp(a.mj,a.t)
    if (a.t==1 and a.sfx_end!=-1) sfx(a.sfx_end)
   else
    aniend+=1
   end
  end
 end

 if #anis==0 or aniend==#anis then
  finishani()
 end

end

function update_cpu()
 if cpumove==nil then
  if cputhinking then
   local cstatus,err=coresume(cputhread)
   if not cstatus then
    --cls()
    stop(err)
   end
  else
   thinkdts,cputhinking={},true
   setcpucur(mailbox64[sel_x+sel_y*8])
   cputhread=cocreate(getbestmove)
   coresume(cputhread)
  end

  if (cpu_leaf2>#thinkdts) add_thinkdts()

  if cpuwait<=0 then
   if cpu_movecur()==false then
    sfx(0)
    sel_x,sel_y,movesdirty=cur_x,cur_y,true
   end
   cpuwait+=cpuspeed
  else
   if (#bigt==0)	cpuwait-=1
  end
 else
  if cpuwait<=0 then
   if uimode=="select" then
    if cpu_movecur() then
     cpuwait+=cpuspeed*5
     uimode="move"
     sfx(3)
     setcpucur(cpumove.to)
    else
     sfx(0)
     sel_x,sel_y,movesdirty=cur_x,cur_y,true
    end
   elseif uimode=="move" then
    if cpu_movecur() then
     if cpumove.promo==t_empty then
      animove(board,cpumove)
      cpumove,movesdirty=nil,true
     else
   	  show_promo(board.side)
   	  cpuwait+=cpuspeed*5
   	  local i
   	  for i=1,#promolist do
   	   if (promolist[i]==cpumove.promo) igm_cputrgt=i
   	  end
 	    sfx(3)
     end
    else
     sfx(0)
    end
   elseif uimode=="promo" then
    update_promo_cpu()
   end
   cpuwait+=cpuspeed
  else -- end wait else
   if (#bigt==0)	cpuwait-=1
  end -- end wait if
 end --end cpumove if
end

function cpu_movecur()
 if cur_x==cpucur_x and cur_y==cpucur_y then
  return true
 end
 if cpucur_y!=cur_y then
  cur_y+=sgn(flr(cpucur_y-cur_y))
 else
  cur_x+=sgn(flr(cpucur_x-cur_x))
 end
 return false
end

function update_promo_cpu()
 if igm_sel==igm_cputrgt then
  animove(board,cpumove)
  igm_dh,cpumove,movesdirty=0,nil,true
  sfx(3)
 else
  igm_sel+=sgn(igm_cputrgt-igm_sel)
 	sfx(0)
 end
end

function update_promo_h()
 local newcur=igm_sel
 if btnp(4) then
  igm_dh,uimode,sel_x,sel_y,movesdirty=0,"select",cur_x,cur_y,true
  sfx(1)
 end
 if btnp(5) then
  local loc120,i=mailbox64[cur_x+cur_y*8]
  uimode,igm_dh="move",0
  sfx(3)
 	for i = 1,#tmpmoves do
 	 if tmpmoves[i].to==loc120 and tmpmoves[i].promo==promolist[igm_sel] then
    animove(board,tmpmoves[i])
 	  break
 	 end
 	end
 end
 if (btnp(0)) newcur-=1
 if (btnp(1)) newcur+=1
 newcur=((newcur-1)%4)+1
 if newcur!=igm_sel then
  sfx(0)
  igm_sel=newcur
 end
end

function update_menu()
 local newcur=igm_sel
 curani()
 update_igm()

 if wait<=0 then
  logo1_y+=(24-logo1_y)/10
 else
  wait-=1
 end

 scroll_x+=1
 scroll_y+=0.5
 if scroll_x>64 then
  scroll_x-=64
  scroll_y-=16
 end
 if scroll_y>64 then
  scroll_y-=64
  scroll_x+=16
 end

 if (pirate) return
 --scroll_y=(scroll_y+0)%64
 if (btnp(2)) newcur-=1
 if (btnp(3)) newcur+=1

 if btnp(0) or btnp(1) or btnp(5) then
  if igm_sel==0 then
   whitecpu=not whitecpu
   sfx(3)
  elseif igm_sel==1 then
   blackcpu=not blackcpu
   sfx(3)
  else
   sfx(2)
   fadeout()
   start_game()

  end
 end

 newcur=newcur%3
 if igm_sel!=newcur then
  igm_sel=newcur
  sfx(0)
 end
end

function update_logo()
 if wait==0 then
  fadeout()
  show_menu()
 end
 wait-=1
end
-->8
--draw

function draw_game()
 local loc120,drwoutline,tle,col,tx,ty,dx,dy,hover=mailbox64[cur_x+cur_y*8]
 cls()
 doshake()
 rectfill(0,0,127,127,2)
 rectfill(0,b_offset,127,127,13)
 for x = 0,7 do
  for y = 0,7 do
   loc120,tx,ty=mailbox64[x+y*8],x*16,b_offset+y*14
   -- draw board tile
   if ((x+y)%2==0) rectfill(tx,ty,tx+15,ty+13,6)
   -- draw move dot
   if movedots[loc120]==1 or movedots[loc120]==3 then
    palt_red()
 	  if board.color120[mailbox64[sel_x+sel_y*8]]==1 then
 	   pal_gb()
 	  else
  	 pal_blk2()
 	  end
 	  if movedots[loc120]==1 then
  	  spr(32,tx,ty,2,2)
  	 else
  	  spr(34,tx,ty,2,2)
  	 end
 	  pal()
   end
  end
 end

 --draw shadow
 if uimode=="ani" then
  palt_red()
  for a in all(anis) do
   if abs(a.j)>0.5 then
    spr(0,a.x+0.5,a.y+0.5,2,2)
   end
  end
  palt()
 end

 if uimode=="move" or uimode=="promo" then
  loc120,tx,ty=mailbox64[cur_x+cur_y*8],sel_x*16+8,b_offset+sel_y*14+7
  dx,dy=tx,ty
  if movedots[loc120]>0 and movedots[loc120]<=3 then
   dx,dy=cur_x*16+8,b_offset+cur_y*14+7
  end
  drawarrow(tx,ty+1,dx,dy+1,2,false)
  drawarrow(tx,ty,dx,dy,8,false)
 end

 for x = 0,7 do
  for y = 0,7 do
   loc120=mailbox64[x+y*8]
   tle,col,tx,ty,hover=board.piece120[loc120],board.color120[loc120],x*16,b_offset+y*14,0
   -- draw selection cursor
   if (x==sel_x and y==sel_y) hover=1
   -- draw piece
   if tle != 0 then
    drwoutline=false
    if (movedots[loc120]==2 or movedots[loc120]==4) drwoutline=true
    if (check and tle==t_king and board.side==col) drwoutline=true
    drawpiece(tx,ty-3-hover,tle,col,drwoutline)
   end
  end
 end

 if uimode=="ani" then
  for a in all(anis) do
   drawpiece(a.x,a.y+a.j,a.piece,a.c,false)
  end
 end
 -- draw selection cursor
 tx,ty=cur_x*16,b_offset+cur_y*14+1
 drawhandcursor(tx+9-seloffset,ty+7-seloffset,board.side)

 for x=1,#bigt do
  bigtext(bigt[x])
 end

 draw_igm()

 print(infotext,5,5,7)
 draw_thinkdts()
 --printcpudbg()
 --print(debug,0,0,7)
 --print(debug2,0,6,7)
 --if #debuglist>0 then
 -- for x=1,#debuglist do
 --  print(debuglist[x],0,6+(6*x),8)
 -- end
 --end
end

function draw_menu()
 -- draw menu here
 local my,x,y,px,py,t=50
 cls()
 doshake()
 rectfill(0,0,127,127,6)
 for x=-3,4 do
  for y=-3,3 do
   if (x+y)%2==0 then
    px,py=x*32-y*8+scroll_x,y*32+x*8+scroll_y
    render_poly({px,py,px+31,py+8,px+31-8,py+31+8,px-8,py+31},13)
   end
  end
 end

 --bigtext(menulogo)

 bigtextdraw(16,logo1_y,32,16,96,16,false)

 t="youtube.com/lazydevs"
 if (pirate) t=stat(102)
 cprint(t,65,logo1_y+20,2)
  
 sspr(81,32,30,11,16,logo1_y-11)
 sspr(81,43,45,11,43,logo1_y-11)
 print(ver,2,122,2)
 draw_igm()
end

function doshake()
 local shakex,shakey=16-rnd(32),16-rnd(32)
 camera(shakex*shake,shakey*shake)
 shake*=0.95
 if (shake<0.05) shake=0
end

function draw_logo()
 cls(12)
 sspr(78,85,50,43,39,39)
end


-->8
--eval
function init_eval()
 --piece values
 mate,pvalue=32760,explode("100,320,330,500,900,20000")

 plocvalue={
 --pawn
 explode("0,0,0,0,0,0,0,0,50,50,50,50,50,50,50, 50,10,10,20,30,30,20,10,10,5,5,10,25,25,10,5,5,0,0,0,20,20,0,0,0,5,-5,-10,0,0,-10,-5,5,5,10,10,-31,-31,10,10,5,0,0,0,0,0,0,0,0"),
 --knight
 explode("-50,-40,-30,-30,-30,-30,-40,-50,-40,-20,0,0,0,0,-20,-40,-30,0,10,15,15,10,0,-30,-30,5,15,20,20,15,5,-30,-30,0,15,20,20,15,0,-30,-30,5,10,15,15,10,5,-30,-40,-20,0,5,5,0,-20,-40,-50,-40,-30,-30,-30,-30,-40,-50"),
 --bishop
 explode("-20,-10,-10,-10,-10,-10,-10,-20,-10,0,0,0,0,0,0,-10,-10,0,5,10,10,5,0,-10,-10,5,5,10,10,5,5,-10,-10,0,10,10,10,10,0,-10,-10,10,10,10,10,10,10,-10,-10,5,0,0,0,0,5,-10,-20,-10,-10,-10,-10,-10,-10,-20"),
 --rook
 explode("0,0,0,0,0,0,0,0,5,10,10,10,10,10,10,5,-5,0,0,0,0,0,0,-5,-5,0,0,0,0,0,0,-5,-5,0,0,0,0,0,0,-5,-5,0,0,0,0,0,0,-5,-5,0,0,0,0,0,0,-5,0,0,0,5,5,0,0,0"),
 --queen
 explode("-20,-10,-10,-5,-5,-10,-10,-20,-10,0,0,0,0,0,0,-10,-10,0,5,5,5,5,0,-10,-5,0,5,5,5,5,0,-5,0,0,5,5,5,5,0,-5,-10,5,5,5,5,5,0,-10,-10,0,5,0,0,0,0,-10,-20,-10,-10,-5,-5,-10,-10,-20"),
 --king
 explode("-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-20,-30,-30,-40,-40,-30,-30,-20,-10,-20,-20,-20,-20,-20,-20,-10,20,20,0,0,0,0,20,20,20,30,10,0,0,10,30,20"),
 --king endgame
 explode("-50,-40,-30,-20,-20,-30,-40,-50,-30,-20,-10,0,0,-10,-20,-30,-30,-10,20,30,30,20,-10,-30,-30,-10,30,40,40,30,-10,-30,-30,-10,30,40,40,30,-10,-30,-30,-10,20,30,30,20,-10,-30,-30,-30,0,0,0,0,-30,-30,-50,-30,-30,-30,-30,-30,-30,-50")
 }

 local mvvlvat=explode("100,200,300,400,500,600")
 mvvlva={}
 local atk,vic
 for atk=1,6 do
  mvvlva[atk]={}
  for vic=1,6 do
   mvvlva[atk][vic]=mvvlvat[vic]+6-(mvvlvat[atk]/100)
  end
 end

end

function evalpos(pos)
 local bq,wq,mpb,mpw,endw,endb,v,x,pv,pce,col,loc=0,0,0,0,0,0,0
 if (pos.piece120[pos.king_w]!=t_king) return -mate
 if (pos.piece120[pos.king_b]!=t_king) return mate

 for x=0,63 do
  loc=mailbox64[x]
  pce=pos.piece120[loc]
  if pce>0 and pce!=t_king then
   col=pos.color120[loc]
   pv=pvalue[pce]
   if col==t_black then
    pv+=plocvalue[pce][inv64[x]+1]
    pv=-pv
    if (pce==t_queen) bq+=1
    if (pce==t_bishop or pce==t_knight) mpb+=1
   else
    pv+=plocvalue[pce][x+1]
    if (pce==t_queen) wq+=1
    if (pce==t_bishop or pce==t_knight) mpw+=1
   end
   v+=pv
  end
 end
 if (wq==0 or (wq>0 and mpw<2)) endw=1
 if (bq==0 or (bq>0 and mpb<2)) endb=1
 if (pos.piece120[pos.king_w]==t_king) v+=pvalue[t_king]+plocvalue[t_king+endw][mailbox120[pos.king_w]+1]
 if (pos.piece120[pos.king_b]==t_king) v-=pvalue[t_king]+plocvalue[t_king+endb][inv64[mailbox120[pos.king_b]]+1]
 return v
end

function explode(s)
 local retval,lastpos,i={},1,1,1
 for i=1,#s do
  if sub(s,i,i)=="," then
   add(retval,flr(sub(s, lastpos, i-1)+0))
   i+=1
   lastpos=i
  end
 end
 add(retval,flr(sub(s,lastpos,#s)+0))
 return retval
end
__gfx__
88888888888888888008888800088888888888888888888888888777777888888888888777888888888888877888888888888887788888888888887777888888
88888888888888880770880067708888888888888888888888887000000788888888887000788888888888700788888888778870078877888888870000788888
88888888888888880777006706770888888888888888888888870077770078888888870707078888888887077078888887007707707700788888770770778888
88888888888888880677770677770888888888877888888888870700006078888888870777078888888870076007888870770007600077078887000770007888
88888888888888888067777777577088888888700788888888870777776078888888707777607888888870700707888870760770077076078887077777707888
88888888888888888806777757757088888887077078888888870077770078888887077077607888888707077060788887000760076000788870077777700788
88888888888888888800677775777088888870777607888888887000000788888870777777607888888707077060788870700000000006078707000770006078
88888888888888888805567777777008888870777607888888887077760788888707777777607888888707777760788870770776077076077077770770777607
88888888888888888805667777770770888887076078888888870777776078888707770777607888888870777607888870777776077776077077777777777607
88888888888888888880667777767770888870700607888888870777776078888870007777607888888707000060788887077777777760787077777777776607
88888222222888888888066666077608888870777607888888707777777607888887077777760788887077777776078887077777777760788707777777766078
88882222222288888888800000676088888707777760788888707777777607888870777777760788887077777776078888707777777607888870077777600788
88882222222288888888888805660888888707777760788888707777777607888870777777760788887077777776078888870000000078888887000000007888
88888222222888888888888805508888888870777607888888870777776078888887077777607888888707777760788888870777776078888887077777607888
88888888888888888888888880088888888887000078888888887000000788888888700000078888888870000007888888887000000788888888700000078888
88888888888888888888888888888888888888777788888888888777777888888888877777788888888887777778888888888777777888888888877777788888
88888888888888888888888888888888887777778887777887777877777778887777778887777888777787777778887777788877777778777777777787777777
88888888888888888888888888888888877777777887777887777877777778877777777887777887777787777778887777788877777778777777777787777777
88888888888888888888888888888888777777777787777887777877777778777777777787777887777887777778887777788877777778777777777787777777
88888888888888888888888888888888777788777787777887777877778888777788777787777877778887777777877777788877787778888777788887777888
88888877778888888888887777888888777788777787777887777877778888777788777787777877778887777777877777788877787778888777788887777888
88888777777888888888877667788888777788777787777887777877778888777788777787777777788887777777877777788777787777888777788887777888
88888777777888888888877667788888777788777787777777777877778888777788777787777777788887777877878777788777787777888777788887777888
88888777777888888888877777788888777788888887777777777877777778777788888887777777888887777877878777788777787777888777788887777777
88888777777888888888877667788888777788888887777777777877777778777788888887777777788887777877778777788777888777888777788887777777
88888577775888888888857777588888777788777787777777777877777778777788777787777777788887777877778777788777888777888777788887777777
88888855558888888888885555888888777788777787777887777877778888777788777787777877778887777877778777788777777777888777788887777888
88888888888888888888888888888888777788777787777887777877778888777788777787777877778887777877778777787777777777788777788887777888
88888888888888888888888888888888777788777787777887777877778888777788777787777887777887777877778777787777777777788777788887777888
88888888888888888888888888888888777777777787777887777877777778777777777787777887777887777887788777787777888777788777788887777777
88888888888888888888888888888888877777777887777887777877777778877777777887777888777787777887788777787777888777788777788887777777
88888888888888888888888888888888887777778887777887777877777778887777778887777888777787777887788777787777888777788777788887777777
00000000000000008888800008888888777777778887777777788888777777787777888777888777702222200022200022220000222000000000000000000000
00000888888000008880077770888888777777777887777777778888777777787777888777888777728888820288820288882022888220000000000000000000
00088888888880008807777000888888777777777787777777777888777777787777888777888777728888882288822888882288888882000000000000000000
00888888888888008007777777000008777788777787777887777888777877787777887777788777728882888288828888882888828888200000000000000000
00888888888888000767777777777770777788777787777887777888777877788777787777787777828882888288828882222888202888200000000000000000
08888888888888800777777777777770777788777787777887777887777877778777787777787777828888888288828882002888202888200000000000000000
08888888888888800767777777666600777788777787777777777887777877778777787777787777828888882288828882222888202888200000000000000000
08888888888888800767777777600088777788777787777777788887777877778777787787787777828882220288828888882888828888200000000000000000
08888888888888800767777776088888777788777787777777778887778887778777787787787777828882000288822888882288888882000000000000000000
00888888888888000666777760088888777788777787777887777887778887778777787787787777828882000288820288882022888220000000000000000000
00888888888888000600666660888888777788777787777887777887777777778777787787787777802220000022200022220000222000000000000000000000
00088888888880008080066600888888777788777787777887777877777777777877787787787778800000220000000000000000000000000000000000000000
00000888888000008888000008888888777788777787777887777877777777777877787787787778800002820000000000000000000000000000000000000000
00000000000000008888888888888888777788777787777887777877778887777877777888777778800028822222222222222222222222222222222002200000
00000000000000008888888888888888777777777887777887777877778887777877777888777778800288888888888888888888888888888888888028820000
00000000000000008888888888888888777777778887777887777877778887777877777888777778802888888888888888888888888888888822222022200000
22dd6677888880077777777777777777777777008008888800088888000000000000000000000000028888888888888888888888888888888888882282000000
22dd6677888820722222222222222222222222700770880067708888000000000000000000000000002888888888888888888888888888888888822220002000
22dd6677888227277777777777777777777777270777006706770888000000000000000000000000000288888888888888888888888888888888888882028200
22dd6677882227277777777777777777777777270677770677770888000000000000000000000000000028822222222222222222222222222222222220002000
22dd6677888227277777777777777777777777278067777777577088000000000000000000000000000002820000000000000000000000000000000000000000
22dd6677888827277777777777777777777777278806777757757088000000000000000000000000000000220000000000000000000000000000000000000000
22dd6677888887277777777777777777777777278800677775777088000000000000000000000000000000000000000000000000000000000000000000000000
22dd6677000007277777777777777777777777278805567777777008000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007277777777777777777777777278805667777770570000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007222227777222222222222222278880667777705550000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000722222772222222222222222708888066666050008000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000077772722777777777777777008888800000000088000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000072227000000000000000008888888800000888000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000072270000000000000000008888888800008888000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000072700000000000000000008888888880088888000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077000000000000000000008888888888888888000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccc777cccc777777777cccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccc7777ccc77777777c777ccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccc77cccccc77777cccc777777cc777cc7777ccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc7cc777cccccc77777ccccccc777ccc77777777c7ccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc77cc777cccccc777777ccccc777cccc7777777cc77cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777ccccc777c777cccc7777ccccc77777ccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777ccccc777c777cccc777ccccccc777cccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777cccc777777777cc777cccccccc777cccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777cccc777777777cc7777777cccc777cccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777777c777ccc777c77777777cccc777cccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777777c77ccccc77c77777777cccc777cccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc7777cccccccccccccccccccccccccc7ccccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cccccccccccccccccccccccccccccccccccccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cccc7777cccc777777c777cccc777cc7777ccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc77777777cc777777c777ccc7777c777777cc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777777777c777ccccc777cc777c777777ccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777cc7777c777ccccc777cc777c777cccccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777cc777ccc777c777777cc777c777cc77777cccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc77ccc777cc777c777777ccc777777ccc77777ccc777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777cc777cc777c777cccccc77777cccccc7777cc77cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777cc777c7777c777cccccc77777ccc7ccc777c777cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777cc7777777cc777777cccc777ccc77777777c777cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777cc777777ccc777777cccc777cccc777777cc777cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777ccc77cccccccccccccccccccccccc7777ccc777cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccc7777cccccccccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777777777777777777777777777777777777777777cccc
00000000000000000000000000000000000000000000000000000000000000000000000000000077777777777777777777777777777777777777777777777777
0000000000000000000000000000000000000000000000000000000000000000000000000000007777777777777ccc77ccc77ccc77cccc7c777c777777777777
000000000000000000000000000000000000000000000000000000000000000000000000000000c777777ccc77c77777c7c77c77c7c7777cc7cc7c777c77777c
000000000000000000000000000000000000000000000000000000000000000000000000000000c77777cc7cc7c7777c777c7c77c7cccc7c7c7c7cc7cc77777c
000000000000000000000000000000000000000000000000000000000000000000000000000000cc7777c777c7c7777c777c7c77c7c7777c777c77ccc77777cc
000000000000000000000000000000000000000000000000000000000000000000000000000000cc7777ccccc7c7777ccccc7c77c7c7777c777c777c777777cc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccc777c777c77ccc7c777c7ccc77cccc7c777c777c77777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc7777777777777777777777777777777777777777777ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccc777777777777777777777777777777777777777777cccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc7777777777cccccccccccccccccccc7777777777ccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccc77777ccccccccccc7777ccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc77777cccccccc77777cccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccc7777777cc7777777ccccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc777777777777ccccccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccc77777777ccccccccccccccccccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccc77cccccccccccccccccccccccc
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0110020210100202101002022d10010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101020210100202101002021010020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020210100202101002020c0d0202101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020210100202101002021c1d0202101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010020206070202080902022a2b020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010020216170202181902023a3b020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202101002020405021226270202242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202101002021415021236370202343500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000240301f03022030200000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000270102b01029020200200a000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000028050280502f0302f03027020270202f0202f02028010280102f0102f01028010280152f0102f01028010280102e0002e000280002800000000000000000000000000000000000000000000000000000
01010000270102b0102b020250202b0002b0002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003271001700007000070000700007000070000700007000070000700007000070000700007000070027000007000070000700007000070000700007000070000700007000070000700007000070000700
000200000c72000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003271035720357000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00020000316332b600186000c6000c6000c600186003a5003b5003a5003b5003b5003a5003b5003a5003a5003b5003a5003b5003a500215022150221502005000050000500005000050000500005000050000500
010700002b631186110c6110c6110c6150c605186003a5003b5003a5003b5003b5003a5003b5003a5003a5003b5003a5003b5003a500215022150221502005000050000500005000050000500005000050000500
001500003163304700316000370003700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100002b631186110c6110c6110c6150c605186003a5003b5003a5003b5003b5003a5003b5003a5003a5003b5003a5003b5003a500215022150221502005000050000500005000050000500005000050000500
000900000875006750057300473003710017100171001710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001701017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002805728057350373503735010270002f0002f00028000280002f0002f00028000280052f0002f00028000280002e0002e000280002800000000000000000000000000000000000000000000000000000
00010000036150361005610096100f6101461017610196101b6101c6101d6101d6101c6101b6101861015610126100f6100d6100a610086100761005610056100461002610026100161001610016100161001610
000200001800013000160001600016000130001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__music__
04 07 08 43 44
00 09 0a 0b 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
