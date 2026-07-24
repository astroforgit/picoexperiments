pico-8 cartridge // http://www.pico-8.com
version 28
__lua__
-- benjamin soule

cartdata("archeos")
gp_types=16
gp_fam=4

forcemon=nil
start_items={}

cls()
dir={1,0,0,1,-1,0,0,-1}
und={5,10,14}
logs={}
anims={}


function _init()
 t=0
 nd=0
 ents={}
 gmo=nil
 --
 
 max_dif=dget(1)
 max_dif=max_dif==0 and 3 or max_dif
 
 --init_game()
 init_menu()
 

end

function init_menu()
 
 menu=mk()
 
 local sy=0
 local go=0
 dif=nil
 
 menu.u=function()
  if go>0 then 
   go+=1 
   if go>48 then    
    kl(menu)
    init_game()
   end
    
	 elseif t>12 then
	  
	  if bp(4,20) then
		  if not dif then
			  dif=dget(0) or 0
			  menu.csel=16
		  else
		   go=1
		   dset(0,dif)
		  end
		 elseif dif and go==0 then		 
		  if bp(2) then
		  	dif=(dif-1)%max_dif  	
			 elseif bp(3) then
			  dif=(dif+1)%max_dif 
		  end
		 end
	 end	 
	 
 end
 
 
 menu.dr=function()
	 r=0
	 if t==10 then sfx(21) end
	 
	 if t>10 then
	  r=max(20-t,0) 
	  pal()  
	 else
	  dx=t*10-100
	  apal(1)
	 end	 
	 
	 local gg=(go*go)/4
	 local dy=-gg
	 for i=0,2 do
	  spr(163+i*2,38+i*16+rr(r)+dx,8+rr(r)+dy,2,2)
	  spr(169+i*2,34+i*16+rr(r)-dx,27+rr(r)+dy,3,2)
	 end
	 	 
	 if t>10 then 
	
	  print("version 1.1",42,45+dy,1)
	 	
		 -- wall		 
		 for i=0,1 do  
		  for g=0,1 do
			  for k=0,3 do
			   local y=-(((t+gg)/(k+1))%128)
			   local x=i*120+k*(1-i*2)*8	   
				  x+=(i*2-1)*max(go-16,0)
			   map(i+k==0 and 55 or 56+k,0,x,y+g*128,1,16)	   
			  end
		  end
		 end		 
		 -- press start
	  spr(128,53,22+dy,2,1)
	  local bl=dif and 2 or 20
	  if t%bl<bl/2 and (not dif or menu.csel) then
	   print("press <action> to play",22,90,7)
	 	end	 	
	 	
	 	-- dif sel
   if dif and not menu.csel then
	 	 for i=0,4 do
	 	  local s=dif_name[i+1]
	 	  local cl=dif==i and 12 or 7
	 	  if i>=max_dif then cl=1 end
	 	  if go==0 or (dif==i and t%2==0 and go<16 ) then
	 	   print(s,64-#s*2,70+i*7,cl)
	 	  end
	 	 end
	 	 -- desc
	 	 if go==0 then
		 	 local st=dif>0 and 2 or 0
		 	 for i=st,dif do	 	 
		 		 local s=dif_desc[1+i]
		 		 print(s,64-#s*2,102+12+(i-st)*6-(dif-st)*3,i==0 and 11 or 8)
		 	 end
	 	 end	 	 
	 	end
	 end 
 end

end


function rr(n)
 return rd(n*2)-n
end

function loop(f)
 local e=mk()
 e.u=f
 return e
end


function play()
 
 --
 if pass then
  trn+=1
  pass=nil
 	aev(move_boulders)
 	aev(slime_split)
  aev(chk_bomb)

 	if arc<=0 then
 	 aev(archeos_die)
 	elseif lvl_has(16) and trn%6==0 then
 	 aev(archeos_refill)
 	end
 end


 -- events 
 if #events>0 then
  local f=events[1]
  del(events,f)
  f()
  return 
 end
 
 -- check life
 if life<=0 then 
  if fxp==0 and not lup then
  	dl(10,game_over)
  else
   dl(2,play)
  end
  return
 end
 
 
 playing=loop(usl)
 cursor_move(0,0)
end

function stp()
 kl(playing)
 playing=nil
end


function chk_bomb()
 
 for e in all(els) do
  if e.bomb then 
  
   if e.bomb>0 then
    sfx(40,nil,8,4)
	   e.bomb-=1  
	   local n=mk(0,e.x+2,e.y)
	   n.dr=function(n,x,y)
	    print(e.bomb+1,x,y,7)
	   end
	   n.vy=-2
	   n.h=.75
	   n.hp=24
	   n.brd=0
		  dl(24,play)
	  else
	   sfx(40,nil,0,8)
	   for dx=-2,2 do for dy=-2,2 do
	    local sq=gsq(e.px+dx,e.py+dy)	    
	    if sq and sq.el and is_minion(sq.el) then
	     local m=sq.el	
	     dl(sqrt(dx*dx+dy*dy)*4, function() xpl(m) end)
	    end	   
	   end end
	   ac(e.x+3,e.y+3,4,32,5,12)
	   dl(24,chf)
	  end
	  
	  return
  end 
 end
 
 play()
 

end


function init_game()

 --h.d=draw_game
 dif=dif or 0
 
 
 t=0
 nfc=0
 fxp=0
 trn=0
 ffy=0
 nxp=0
 fl=0
 ar=nil
 arc=dif>=2 and 60 or 30
 xmax=11
 ymax=13
 poison=false
 fdy=-128
 elmax=xmax*ymax-1
 els={}
 events={}
 inv={}
 
 -- bg
 bg=mk()
 bg.dp=0
 bg.dr=draw_game
 
 -- grid
 grid={}
 for x=0,xmax-1 do
  for y=0,ymax-1 do
   local g={x=x,y=y}
   add(grid,g)
  end
 end

 -- inventory
 for i=0,3 do
  local e=mk(53)
  e.x=101+(i%2)*13
  e.y=86+flr(i/2)*13
  inv[i+1]=e
  if i==0 then
   item=e
  end  
  
  e.u=function()
   e.brd=nil
   if e.cshow then
    e.brd=8+t%8
   end
  end
  
 end
 
 -- cursor
 v=mk()
 v.px=6
 v.py=6
 v.ix=0
 v.iy=0
 v.vx=0
 v.vy=0
 v.a=0
 v.dp=2
 v.•=true
 v.dr=function(v,x,y)

		apal(sget(32+t%4,8+v.a))
	 spr(224,x+v.vx,y+v.vy,2,2)
	 pal()
	 v.vx/=2
	 v.vy/=2
 end
 
 
 --
 lev(1)
 life=hearts*2

 -- shuffle monsters
 local a={}
 for i=0,3 do add(a,{}) end
 for x=17,40 do
  local n=mget(x,0)
  add(a[1+mget(x,1)-192] ,n)
 end
 for x=0,11 do
  local g=a[flr(x/3)+1]
  local n=g[rd(#g)+1]
  del(g,n) 
  mset(x,16,n)
 end
 mset(12,16,80)
 if forcemon then
  mset(0,16,forcemon)
 end
 
 -- shuffle items
 item_pool={}
 for i=0,15 do
  add(item_pool,i)
 end
 
 
 --[[
 while count(item_pool)<12 do
  ok=1 
  k=rd(12)
  for n in all(item_pool) do 
  	if(n==k) ok=nil 
  end
  if ok then
   add(item_pool,k)
  end
 end
 --]]


 aev(refill_lvl)
 play()
 -- 
 for k in all(start_items) do
  it=mk(-3)
  it.fr=144+k
  del(ents,it)
  s=gfsl()
  git(s,it)
 
 end
end


function ctrl()
 tg=gl(v.px,v.py) 
 if(bp(0)) cursor_move(-1,0)
 if(bp(1)) cursor_move(1,0)
 if(bp(2)) cursor_move(0,-1)
 if(bp(3)) cursor_move(0,1)
  
 v.x=v.px*8-1 
 v.y=v.py*8-1
 v.a=0 
 v.•=nil
 tt=-5
 grp={} 
 gra=0
 if tg then
  tt=tg.k
  grp=tg.gr
 end 
end

function cursor_move(x,y)
 if(is_in(v.px+x,v.py+y)) v.px+=x v.py+=y
 tg=gl(v.px,v.py)
 if tg then
  tg.cbase_desc=64
 end
end

function usl(ev)
 
 if gmo then stp() return end
 

 ctrl()
 nd=0
 gr={}
 
 if tg and not tg.ice then
  gr=tg.gr
  v.a=1
  if tt==-2 or ( tt==-1 and tg.fr!=32) then
   v.a=2
  end   
   
  
   
  -- damage
  d=tg.atk
  --if dif>=3 then d+=1 end
  
  local g=get_group(tg.gr)
  
  -- add weapon dmg & check protector
  for e in all(els) do
   e.prt=nil
  end
  for m in all(g) do
 		d+=m.wp  
 		if m.guard then	 	
	 	 m.guard.prt=m
	 	end
  end  
  
  -- add wolf pack
  if tg.gr and #tg.gr<=3 and tg.k==19 then
   d-=2
  end
  
  -- defense
  if #gr>=6 and iv(1) then  
   d-=1
  end
  if #gr==1 and iv(0) then
   d-=1
  end
  if tg.py<=6 and iv(11) then
   d-=1
  end
  if is(tg,und) and iv(9) then
   d-=1
  end
  
  if poison then d+=1 end
  if(d<0) d=0
  nd=d   

 end

 if btnp(4) then
  stp()
  act()
 elseif ev.t>1 and bp(5,9) then
  stp()
  bag=loop(uinv)
 end
 
end

function utrg(ev)

 v.•=nil

 ctrl()
 if(tt>=0) v.a=3
 if tg!=nil then 
  if td==tg.im or tg.k==16 then
   v.a=2
  end
 end
 
 -- cancel
 if bp(5,10) then
  kl(ev)
  bag=loop(uinv)
 end
 
 -- validate
 if v.a==3 then
  if btnp(4) and ev.t>1 then
   kl(ev)
   spd()
  end
 else
  bp(4,8)
 end
end

function spd()
 --h.u=nil
 w=8
 v.•=true
 
 -- manage
 if fget(144+td,2) and not fget(144+td,7) then
  item.used=1
 else
  item.id=nil
  item.fr=53
 end 
 
 -- sword
 if td==12 then
  local n=1
  for y=0,ymax-1 do
   local e=gsq(tg.px,y).el
   if e and e.k>=0 then
	   function slash()
	    local s=mk()
	    s.hp=8
	    s.dr=function()
	     clip_board()
	     for l=-1,1 do
	      local x=e.x+4+l
	      local y=e.y+abs(l)*4
	      line(x,y,x,y+8+(1-abs(l))*8,sget(32+s.hp,15))
	     end
	     clip()
	    end	    
	    xpl(e)
	   end   
    dl(n,slash)
    n+=1
   end   
  end 
  dl(n+8,chf) 
 end
 
 -- bow
 if td==2 then
  w=24 
  ncf=1 
  sfx(14)
  e=mk(39,-4,tg.y) 
  e.u=function(e)
   e.x+=10
   if e.x>tg.x then
    sfx(15)
    e.x=tg.x
    e.fr+=1
    e.hp=12
    flh(tg,6)
    dl(12,function() xpl(tg) end)
    dl(24,chf)
    e.u=nil
   end
  end
 end
 

 -- ice rod
 if td==3 then
  for e in all(grp) do   
   e.ice=1
   e.k=50
   flh(e,3) 
  end
  sfx(12)
  dl(12,play)
 end

 -- fire rod 
 if td==4 then
  w=20 
  ncf=1 
  sfx(16)  
  for x=0,2 do
   for y=0,2 do
    burn(tg.px+x-1,tg.py+y-1,1+(x+y*2)*2,td)
   end 
  end
  dl(24,chf)   
 end
 
 -- heal potion
 if td==5 then
  poison=false
  uu=heal 
  t=0
  dl(10,play)
 end
 
 -- book
 if td==8 then
  --w=28 
  sfx(19)
  for i=0,40 do 
   dl(i,gxp)
  end
  dl(40,play)
 end
 
 -- kill monster type
 if td==10 then  
  ncf=1 
  sfx(17)
  for e in all(els) do
   if(e.k==tg.k) then
    f=function()
     anm(e.x,e.y,140,3,0.34)
     kl(e)
    end
    dl(1+e.px+e.py,f)
   end
  end
  dl(32,chf)  
 end
  
 -- necklace
 if td==14 then
  sfx(39)
  local a={}
  for sq in all(grid) do
   add(a,sq)
  end  
  local k=8
  for el in all(els) do
   local sq=rc(a)
   mvt(el,sq.x,sq.y,false,k)
   el.jmp=16
   el.jma=rnd()  
   el.twcv=function(c)
    return .5-cos(c/2)*.5
   end
   k+=1/5
  end
  dl(flr(k+1),chf)  
 end
 
 -- bomb
 if td==15 then
  tg.bomb=3
  dl(16,play)
 end

 
end

function is_minion(e) 
 return e and e!=ar and e.k>=0 
end

function burn(nx,ny,t,d)
 if is_in(nx,ny) then
  function f()
   anm(nx*8+3,ny*8+3,55,7,1/2)
   e=gl(nx,ny)
   if is_minion(e) and e.im!=d then
    kl(e)
   end
  end
  dl(t,f)
 end
end

function bp(k,s)
 if(s==nil) s=0
 if(btnp(k)) sfx(s)
 return btnp(k)
end

function uinv(ev)


 if bp(0) then v.ix=0 end
 if bp(1) then v.ix=1 end
 if bp(2) then v.iy=0 end
 if bp(3) then v.iy=1 end
 if ev.t>=2  and bp(5,10) then
  kl(ev)
  bag=nil
  rmv=nil
  play() 
 end
 
 item=inv[1+v.ix+v.iy*2]
 td=item.id
 v.x=item.x-4
 v.y=item.y-4
 v.a=0
 v.•=nil
 
 if td then
  v.a=2
  if fget(144+td,0) and not item.used then
   v.a=1
  end
 else
  bp(4,8)
 end
 
 if(rmv and td) v.a=1
 
 if v.a==1 then
  if ev.t>=2 and btnp(4) then
   kl(ev)
   bag=nil
   use_item()
  end
 else
  bp(4,8)
 end
end

function use_item()
 if rmv then
  git(item,rmv)   
  ncf=1 
  rmv=nil 
  chf()
  return
 end

 sfx(9)
 if fget(144+td,1) then
  loop(utrg)
 else
  spd()
 end
end

function is_in(x,y)
 return x>=0 and y>=0 and x<xmax and y<ymax
end

function dor(e)
 e.k=-1
 e.fr=33+min(2,flr(fl/3))
 e.a=0
end

function cancel(str)

 if str then
	 v.error=str
	 v.cerr=40
 end
 sfx(8)
 dl(16,play)
end


function act()

 v.•=true
 -- wrong ( cancel )
 if v.a!=1 or tt==16 then
  local n=tt==16 and 6 or tt+6
  cancel(error_desc[n])
  return
 end
 
 if tt>=0 then
 
  -- 50% evade
  if (tg.k==1 or tg.k==14) and rd(2)!=0 then
   a=gnei(tg)
   for o in all(a) do 
    if tg.k!=o.e.k then
     x=tg.px 
     y=tg.py 
     flh(tg,3)
     mvt(tg,o.e.px,o.e.py) 
     mvt(o.e,x,y)
     chg() 
     sfx(3) 
     dl(12,play)
     return
    end
   end
  end  
  
  -- fairy
  local chk=function(sq)
   return not sq.el and gdn(sq,1).e
  end
  local fp=free_pos(chk)
	 if #fp>0 and #grp==1 and tg.k==17 and not gdn(tg.sq,3).free then
   sfx(33)
	  local fairy=grp[1]
	  local e=mk(88,fairy.x,fairy.y)
	  local trg=rc(fp)
	  fairy.•=true
	  local land=function()
	   mvt(fairy,trg.x,trg.y,true)
	   chf()
	   del(ents,e)
	   fairy.•=nil
	  end
	  local x,y=gpos(trg.x,trg.y)
			moveto(e,x,y,32,land)--16
			e.flx=(x-e.x)>0
			e.jmp=24
			e.jma=.25
			e.twk=true
	  return
	 end

  -- attack
  atk()
  
 else
  
  -- door
  if tt==-1 then
   kl(tg)
		 if iv(13,true) then
    aev(del_extra)
   end   
   aev(nxt_floor)
   aev(refill_lvl)
   play() 
  end
  
  -- item 
  if tt==-3 then
   s=gfsl()
   if s then
    git(s,tg)
    dl(16,chf)
   else
    rmv=tg 
    loop(uinv)
   end
  end
  
  -- apple
  if tt==-4 then
   if life==hearts*2 then
    cancel("already full health")
    return
   end  
   sfx(38)
   life=min(life+1,hearts*2)
   tg.fr+=1
   if tg.fr==204 then
    kl(tg)
    dl(16,chf)
   else
    dl(8,play)
   end
   for i=0,2 do
    e=mk(204,tg.x,tg.y)
    e.flx=rnd()<0.5
    e.fly=rnd()<0.5
    e.we=.2
    e.vy=-rnd(3)
    e.vx=rnd(3)-1
    e.hp=16+rd(16)
    e.brd=0
   end
  end
    
 end
 
 --[[
 v.vis=nil
 alpow()
 h.u=nil
 h.n=endt
 dl(12,chf)
 --]]
 
 
 --dl(6,chf)
end

function git(s,tg)
 kl(tg)
 sfx(32) 
 s.id=tg.fr-144
 s.fr=tg.fr
 flh(s,3)
 ac(s.x+3,s.y+3,4,16,5,20)
end

function hit(d)
 life-=d 
 sfx( life<=0 and 31 or 1)
end

function atk()
 pass=true
 fs=2
 hit(nd)
 local tmp=12
  
  
 -- check poison
 if not poison and tg.k==18 then
  poison=true
 end
  
 -- clone
 local clone=tg.k==12
 if clone then
  sfx(26) 
  tmp+=12 
 end
   
   
 -- burst
 burst={}
 for e in all(grp) do  
 
  if clone then
   kl(e)	   
			local mt=nil
			while not mt or mt==12 do
			 local fr=mget(rd(fm),16)	  
 			mt=get_mid(fr)		 				 
			end   
			local px=e.px
			local py=e.py
	  local f=function()
	   local e=mkm(mt,px,py)	
	   e.cln=12	  
	  end	     
   for i=0,3 do
    local dx=rnd(7)-3
    local dy=rnd(7)-3
    local ee=mk(242+i,e.x+dx,e.y+dy)
    local a=atan2(dx,dy)
    local d=8+rnd(8)
    local nd=function()
     kl(ee)
     if f then f() end
     f=nil
    end	    
    move(ee,cos(a)*d,sin(a)*d,tmp-14,nd)
    ee.twcv=function(c)
     return -sin(c/2)
    end	    
   end  
 
  elseif e.guard then

  elseif e.a>0 and not e.ice then
   nud(e)
  else
   add(burst,e)
   xpl(e)
  end  
  
  a=gnei(e)
  for n in all(a) do 
   blast(n.e,e)
  end
 end
 
 -- ring
 r=iv(7)
 if r then
  flh(r,0) 
  p=mk(140,r.x,r.y) 
  p.lp=3 
  p.vx=rnd(2)-1
  p.vy=-4 
  p.xp=1 
  p.we=0.5
  fxp+=1
 end
 
 -- spawn vamp
 if tt==0 and #gr>=6 then
   sfx(5)
   b=rc(burst)
   m=mkm(10,b.px,b.py)
   f=flh(m,1)
   f.s=1/4
 end
 
 -- spawn skel
 if lvl_has(5) and tt!=5 then
  
  local bonus_tmp=0
  for b in all(burst) do
   local g=gl(b.px,b.py)   
   if not g and rd(5)==0 then
    m=mkm(5,b.px,b.py) 
    spn(m,0,1) 
    if bonus_tmp==0 then
     dl(6,function() sfx(42) end )
    end
    bonus_tmp=12    
   end
  end
  tmp+=bonus_tmp
 end
 
 -- check fall
 dl(tmp,chf)
 
 
end

-- modif
function gl(px,py) 
 local sq=gsq(px,py) 
 if sq then
  return sq.el
 else
  return nil
 end
end


function gnei(e,al)
 a={}
 for di=0,3 do 
  o=gdn(e.sq,di)
  if(o.e!=nil or al) add(a,o)
 end
 return a
end

function gdn(sq,di)
 r={}
 r.x=sq.x+dir[1+di*2]
 r.y=sq.y+dir[2+di*2]
 r.sq=gsq(r.x,r.y)
 r.di=di
 if is_in(r.x,r.y) then
  r.e=r.sq.el
  r.free=not r.sq.el
 end
 return r
end

function free_pos(chk) 
 if not chk then
  chk=function(sq)
   return not sq.el
  end 
 end
 local a={}
 for sq in all(grid) do
  if chk(sq) then
   add(a,sq)
  end
 end
 return a
end



function mvt(e,px,py,up,twt)
 
 if e.sq and e.sq.el==e then
  e.sq.el=nil
  e.sq=nil
 end
 
 
 e.sq=gsq(px,py)
 e.sq.el=e 
 e.px=e.sq.x
 e.py=e.sq.y
 
 -- updatepos
 if up then
  usp(e)
 end
 
 -- tween
 if twt then
  local tx,ty=gpos(px,py)
  moveto(e,tx,ty,twt)
 end
 
end



function nud(e)
 p=pop(e,e.fr+1+(e.a+e.wp)*16,3)
 p.we=0.2 
 p.hp=40
 e.a=max(e.a-1,0)
 e.wp=max(e.wp-1,0)
end

function gfsl()
 for i in all(inv) do if(i.id==nil) return i end
 return nil
end




function lvl_has(n)
 for e in all(els) do
  if(e.k==n) return e
 end
 return false
end

function iv(n,fl)
 for i=1,4 do
  local it=inv[i]
  if it and it.id==n then
   if fget(144+it.id,3) then
    it.cshow=2
   end
   if fl then
    local f=function()
     ac(it.x+3,it.y+3,4,8,1,10)
 		 end
 		 for i=0,2 do dl(1+i*10,f) end
   end
   return it
  end
 end
 return false
end
function is(e,cu)
 for n in all(cu) do
  if(e.k==n) return true
 end
 return false
end

function slime_split() 

 local bbp={}
 for e in all_t(2) do
  a=gnei(e,1)
  for b in all(a) do 
   if b.free then
    add(bbp,b) 
   end
  end
 end 
 p=rc(bbp)
 if p then
  sfx(6)
  m=mkm(2,p.x,p.y)
  spn(m,-dir[1+p.di*2],-dir[1+p.di*2+1])
  flh(m,1)
  dre(m)
  anm(m.px*8+3,m.py*8+3,21,5,1/4)
  dl(20,chf)
 else
  play()
 end
 
 
 
end

function chf()
 nxt=nxt or play

 tot=0
 for x=0,xmax-1 do
  f=0
  for y=1,ymax do
   m=gl(x,ymax-y)
   if m then			
    if m.k==20 and not m.stun then
					f=0
				else
					m.fall=f 
					tot+=f
    end
    
     
   else 
    f+=1 
   end
  end
 end 


 if tot>0 then
  ffy=0
  loop(fall)  
 else
 
  chg()
  nxt()
 end
 
 
end



function fall(ev)

 ffy+=2 
 s=1 
 if ffy==8 then
  ffy=0  
  for i=0,elmax do
  	y=(ymax-1)-flr(i/xmax)
   x=i%xmax
   m=gl(x,y)
   if m then
    if(m.fall>1) s=0
    if m.fall>0 then
     m.fall-=1
     mvt(m,m.px,m.py+1,true) 
     if m.fall==0 then
      sfx(36)
     end    
    end
   end
  end
  if s==1 then
   kl(ev)
   chg()
   nxt()     
  end
 end
end


function gxp(k)
 if(gmo) return
 nxp-=k and k or 1
 if nxp<=0 then 
  t=0 
  sfx(29) 
  lev(lvl+1) 
  lup=1 
  poison=false
  uu=heal
 end

end

function heal()
 
 if(t<10) return
 if t%4==0 then
  if life<hearts*2 then 
   life+=1 sfx(28)
  else 
   lup=nil 
   uu=nil 
  end
 end
end


function spn(e,x,y)
 s={} s.x=x s.y=y s.t=8
 e.spn=s
end



function anm(x,y,st,max,s)
 a={} a.x=x a.y=y
 a.st=st a.max=max a.t=0 a.s=s
 add(anims,a) return a
end


function acos(x)
 return atan2(x,-sqrt(1-x*x))
end


function draw_game()
 if fdy then
  camera(0,fdy)
  fdy+=16
  if fdy>=0 then
   camera()
   fdy=nil
  end
 end
 
 
 map()
	


 -- xp / levelup
	if lup then
	 print("levelup",98,74,8+t%3)
	else
	 x=102
	 if(nxp>99) x-=2
	 print("xp:",x,74,12)
	 print(nxp.."",x+12,74,7)
	end

 -- life or bag
 clip(2,114,123,11)
 if nfc>0 then
  local c=nfc*2-1
  c= sgn(c)*c*c  
  cl=sget(32+nfc*8,14)
  local y=117+c*8
  print("floor "..(fl+1),50,y,cl)
	elseif bag and td then
	 local s=nit(td)
	 if #s<16 then	 
	  print(s,6,117,7)
	 else
   
   local l=#s*4+16
   print(s.." -- "..s,(-t)%l-l,117,7)
	 end	
	elseif v.cerr then
	 if t%4<2 then
	  print(v.error,64-#v.error*2,117,8) 
	 end
	else	 
		for j=0,1 do
			b=life
			if j==1 and playing and uu==nil then
			 b-=nd
			end
			for i=0,hearts-1 do
			 n=mid(2,2+b-i*2,4)+j*3
			 if life<=0 then
			  n=1+(t%4)/2
			 end
			 if poison then
			  pal(8,11)
			  pal(2,3)
			 end			 
			 spr(n,4+i*8,(ymax+1.5)*8)
			 pal()
			end
		end 
 end
 clip()
 -- monster desc
	if tg and playing then	
	 spr(tg.fr,101,3)
	 x=114
	 if(#gr>9) x-=2
	 print("x",x,5,12)
	 print(#gr.."",x+4,5,7)
	 print("lvl:",99,12,12)
	 print(tg.lvl.."",118,12,7)
	 print("atk:",99,18,12)
	 print(nd.."",118,18,7)
	 if tg.cbase_desc then
	  print(g_name(tt+4),99,24,7)
	 else
	  local s=skill_desc[tt+5]
	  if s then -- patch ( need chk )
		  local l=#s*4+4
		  clip(99,24,24,8)
		  print(s.." "..s,99+(-t)%l-l,24,7)
			 clip()
			end
	 end
	end
 
 
 -- archeos / next monsters
	if fl<9 then	
	
	 -- current	
		clip(116,34,8,35)
		c=max(0,(nfc-0.5)*2)
		for i=0,gp_fam do
		 fr=mget(gp_fam-i,16)		 
		 if vnh!=fr-64 or t%2==1 then
		  spr(fr,116,25+(i+c)*9)
		 end
		end
		-- next
		clip(99,35,8,8)
		c=min(nfc*2,1)
		spr(mget(gp_fam,16),99,35-c*8)
		clip()
		
	else
		rectfill(96,32,127,71,0)
		map(16,9,96,32,4,5)
		pal(1,sget(16+(t%32)/4,12))
		spr(220,100,39,3,3)
		pal()
		spr(80,108,47)
		print("archeos",98,34,7)
		print("life:",98,64,12)
		print(arc,118,64,7)
	end
  
end

function dl(t,f) 
 local e=mk()
 e.hp=t
 e.nxt=f
end

function clip_board()
 clip(3,3,88,104)
end

function dre(e)

 if e.• or e.dp!=dp then
  return
 end

 local x=e.x
 local y=e.y
 local fr=e.fr


 if e.sq then 
  if e.k==vnh and t%2==0 then
   return
  end
  -- clip
  clip_board()
  
  -- ice,armor & weapon  
  if e.ice then
   fr+=48
  else  
	  fr+=e.a*16
	  if e.wp then fr+=e.wp*16 end
	 end
	  
  -- fall
	 if e.fall>0 then
	  y+=ffy
	 end  
	 
	 --hilight
	 if playing then

	  if t%2==0 and e.gr==gr and v.a==1 and not e.guard then
	   apal(2)
	  end
	 end	
	 
	 -- guardian eyes
	 if e.prt then
	  pal(12,8)
	 end 
	 
	 -- bomb
	 if e.bomb and t%4<2 then
	  apal(8+(t/4)%3)
	 end
	 
	 -- clone blink
	 if e.cln and t%4<2 then
	  apal(3)
	 end
	 
	 -- wolf
	 if e.k==19 and e.gr and #e.gr>3 then
		 fr+=16		 
	 end

  --
  if e.k==20 and e.stun then
   fr+=16
  end

 end
 
 -- spawn
 if e.spn then
  clip(e.x,e.y,8,8)
  local s=e.spn
  if t%2==0 or s.r then
   s.t-=1
  end
  local st=s.t
  if(s.r) st=7-st
  x+=s.x*st
  y+=s.y*st
  if s.t==0 then
   e.spn=nil
   if(s.r) kl(e)
  end
 end 
 
 -- dark
 if e.dk then
  kk=1
  for i=0,15 do
   pal(i,sget(i,8+e.dk))
  end
 end
 
 -- green
 if e.green then pal(11,e.green) end
 
 -- opening door
 if fr==32 then
  fr=48+flr(e.ov/3)
 end 

 -- classic draw
 uflh(e)
 
 -- loop anim 
 if e.lp and t%2==0 then
  fr+=(t/2)%e.lp
 end
 -----------
 -- draw ---
 -----------
 local d=function()
	 if fr>0 then 
	  spr(fr,x,y,1,1,e.flx,e.fly)
	 end
	 if e.dr then dr=e.dr(e,x,y) end
 end
 if e.brd then
	 brd(d,e.brd)
 end 
 d() 

 -- icecube
 if e.ice then 
  spr(54,e.x,e.y)
 end

 -- protected
	if e.gr==gr and e.guard and playing then
	 spr(206,x,y)
	end
	
	--
 pal() 
 clip()
 
end



function brd(d,cl)
 --log(cl)
 apal(cl)
 --camera(-1,-1)
 --d()
 camera(-1,0)
 d()
 camera(1,0)
 d()
 camera(0,-1)
 d()
 camera(0,1)
 d()

 pal()
 camera()
end


function chg()

 for m in all(els) do 
  m.gr=nil 
  m.guard=nil
  m.stun=nil
 end
 
 
 for m in all(els) do
  if not m.gr then
   g={}
   build(m,g) 
  end
  if m.k!=11 then
	  local a=gnei(m)
	  for o in all(a) do
	   if o.e and o.e.k==11 then
	    m.guard=o.e
	   end
	  end 
  end 
 end
 
end

function get_group(gr)
 local a={}
 for m in all(els) do
  if m.gr==gr then
   add(a,m)
  end
 end
 return a
end 



function build(e,g)
 e.gr=g 
 add(g,e)
 a=gnei(e)
 for o in all(a) do
  if o.e.k==e.k and not o.e.gr and o.e.k>=0 then
   build(o.e,g)
  end 
 end
end


function get_mid(mfr)
 for x=17,40 do
  if mfr==mget(x,0) then
   return x-17
  end
 end
 return nil
end

function mkm(mt,x,y)
 fm=gp_fam
 if(fl==9) fm-=1
 
 if not mt then
  local mfr=mget(rd(fm),16)
	 mt=get_mid(mfr)
 end
 
 --f(mt==nil) mt=mget(rd(fm),16)
 
 local e=mk(0)
 e.k=mt
 local sk=function(i) 
  return e.k<0 and 0 or mget(17+e.k,i)-191 
 end
 
 e.fr=sk(0)+191
 mvt(e,x,y,true)
 e.ov=0 
 e.fall=0
 e.lvl=sk(1)
 e.atk=sk(2)
 e.a=sk(3) 
 e.im=sk(4)+47
 e.wp=sk(5)

 if mt==-4 then
  e.fr=201
 elseif mt==-2 then
  e.fr=36
 elseif mt==-1 then
	 e.fr=33+min(2,flr(fl/3))

 end

 
 if mt==16 then

  ar=e
 end
 

  
 e.u=function(e)
	 e.ov=mid(0,e.ov+(e==tg  and 1 or -1),12) 
 end
 
 
 add(els,e)
 return e
end


function flh(e,g,s,t) 
 f={}
 f.g=g
 f.s=s or 1
 f.t=t or 7
 e.flh=f
 return f
end

function uflh(e)
 if e.used then
  apal(e.used)
 end
 f=e.flh
 if(f==nil) return
 f.t-=f.s
 apal(sget(16+f.t,8+f.g))
 if(f.t<=0) e.flh=nil 
end


function blast(e,from)

 -- ice
 if e.ice then
  xpl(e)
  for i=0,3 do
   p=pop(e,226+i,3)
   p.h=0.95
   p.hp=10+rd(10)
   flh(p,3)
  end
 end
 
 -- nude
 if e.k!=from.k and (e.a>0 or e.wp>0)then
   nud(e)
 end
 
 -- door
 if e.k==-1 and e.fr>32 then
  e.fr-=1
 end
 
 -- chest
 if e.k==-2 then
  e.fr+=1
  if e.fr==39 then
   e.k=-3
   flh(e,3)
   k=item_pool[rd(#item_pool)+1]
   del(item_pool,k)
   e.fr=144+k
  end
 end
 
 -- diablotin
 if e.k==3 and e.k!=from.k then
  spn(e,e.px-from.px,e.py-from.py)
  e.spn.r=1
 end
 
 -- archeos
 if e.k==16 then
  arc-=from.lvl
  if arc<0 then arc = 0 end
  ac(e.x+4,e.y+4,1,12,1,5)
  flh(e,6)
  sfx(27)
 end
 
 --
 if e.sq then
  e.stun=true
 end
 
 
end

function xpl(e)
 if e.k==16 then
  arc-=3
  return
 end
 kl(e)
 local p=pop(e,e.fr+48,4)
 p.vx*=2
 p.h=0.95
 p.xp=e.lvl
 --p.brd=0
 fxp+=1
end

function kl(e)
 del(ents,e)
 del(els,e)
 if e.sq and e.sq.el==e then
  e.sq.el=nil
 end
 if e.xp then
  fxp-=1
  gxp(e.xp) 
 end
 if e.nxt then
  local f=e.nxt
  e.nxt=nil
  f()
 end   
 
end



function mk(f,x,y)
 e={
  x=x or 0,
  y=y or 0,
  fr=f or 0,
  vx=0,vy=0,we=0,
  h=1,t=0,
  dp=1,
  
 }
 add(ents,e)
 return e
end
function pop(e,f,j)
 p=mk(f)
 p.x=e.x
 p.y=e.y
 p.vx=rnd(4)-2
 p.vy=rnd(4)-2-j
 p.we=0.5
 return p
end

function rd(x) return flr(rnd(x)) end

function apal(n) 
 for i=0,15 do pal(i,n) end
end

function lev(n)
 lvl=min(n,12)
 nxp+=10+lvl*10
 if dif>=4 then
  nxp+=flr(nxp/4)
 end
 hearts=lvl+2
 if dif>=3 then
  hearts-=1
 end
end

function clb()
 n=2
 if(iv(6)) n+=2 
 return n
end


function aev(f) 
 add(events,f)
end


function del_extra()
 sfx(37)
 vnh=get_mid( mget(0,16) )
 local f=function()
  for m in all(els) do
   if m.k==vnh then
    spn(m,0,1)
    m.spn.r=true
   end
  end 
  vnh=nil    
  play()
 end 
 dl(32,f)
end

function nxt_floor()
 sfx(41)
 local function f()
  nfc=e.t/36 
 end
 
 local ev=loop(f)
 ev.hp=36
 
 ev.nxt=function()
  fl+=1 
  nfc=0
  for i=0,clb()-1 do down() end
  for i=0,16 do
   mset(i,16,mget(i+1,16))
  end
  for i=0,3 do 
   inv[i+1].used=nil 
  end  
   
  aev(chk_vampire)  
  
  -- play
  play()
  
 end
 
end


function chk_vampire()


 local va=lvl_has(10) 
 if va then
  c=ac(va.x+4,va.y+4,16,-16,1,10)
  sfx(24)
  f=function() 
   life-=1 
   flh(va,0)
   play() 
  end
  dl(8,f)
 else
  play()
 end
 
 
 
end

function refill_lvl()

 local a=free_pos()
 local b=free_pos()
 function insert(n)
  rc(b).spa=n
 end
 
 
 if fl<9 then 
  insert("door")
  if fl>0 then
   insert("chest")
  end  
  if dif==0 then
   insert("apple")  
  end
 elseif not ar then
  insert("arch")  
 end   

 
 -- spawner 
 for p in all(a) do  
  mt=nil
  
  if p.spa=="arch" then
   mt=16
  elseif p.spa=="door" then
   mt=-1
  elseif p.spa=="apple" then
   mt=-4
  elseif p.spa=="chest" then
   mt=-2 
  end
  
  m=mkm(mt,p.x,p.y)  
  p.spa=nil
 end 

 local f=function(e)  
  for p in all(a) do  
	  m=p.el
	  if m then 
	   m.dk=flr(6-e.t/3)
		  if e.t==18 then
	    m.dk=nil
	   end   
	  end
  end
  if e.t==18 then
   kl(e)
	  chg(k)
	  play()
  end
 end 
 loop(f)
end

function archeos_refill()
 sfx(34)
 local anm=function(e)
	 ar.fr=80.5-sin((e.t%16)/32)*2
	 if e.t==32 then
	  kl(e)
	  aev(refill_lvl)
	  play()	  
	 end
 end
 loop(anm) 
end

function archeos_die(e)

 local explode=function()
  sfx(23)
  for i=0,32 do 
   e=pop(ar,9,0)
   e.lp=4
   e.we=0
   e.h=0.99
   e.hp=40+rd(40)
  end
  dl(80,_init) 
  if dif==max_dif-1 and max_dif<5 then
   dset(1,max_dif+1)
  end 
  kl(ar) 
 end


 local f=16 
 local hit=nil
	hit=function()
		
		sfx(22)
	 if(ar.fr<96) ar.fr=96	
	 ar.fr+=1
	 if(ar.fr>99) ar.fr-=4

	 fs=8
	 f*=0.92
	 if f>=1 then
	  dl(flr(f),hit)
	 else
			explode()
	 end
	end
	
	hit() 
 
end




function game_over()
 sfx(30)
 t=0 
 gmo=1 
end



function ac(x,y,r,a,g,s)
 local e=mk(0,x,y)
 local t=0
 e.u=function(e)
  t+=1
  if t==s then
   kl(e)
  end
 end 
 e.dr=function(e,x,y)
  local c=t/s
  circ(x,y,r+a*sqrt(c),sget(16+flr(c*7),8+g))
 end 
end


function rc(cu,dl) 
 local n=cu[1+rd(#cu)]
 del(cu,n)
 return n
end


function move_boulders()

 local spd=4 
 
 d=nil
 for e in all_t(7) do
  for i=0,1 do
   if gdn(e.sq,i*2).free then
    bo=gdn(e.sq,1).e
    if bo and gdn(bo.sq,i*2).free then
     e.fr=8 
     d=1
     mvt(e,e.px+1-i*2,e.py,false,spd)
    end
   end
  end
 end
 
 
 if d then
  sfx(35)
  local function f()
	  nxt=move_boulders
	  chf()
  end
  dl(spd,f)  
  
 else
  for e in all_t(7) do 
   e.fr=64+e.k 
  end
  play()
 end
 
end

function all_t(k)
 cu={}
 for e in all(els) do 
  if e.k==k then
   add(cu,e) 
  end
 end
 return all(cu)
end

error_desc={
 "nothing to activate here !",
 "you are already full health",
 "you can't take this",
 "hit nearby monsters to open !",
 "hit nearby monsters to open !",
 "you can't reach archeos !"
}

dif_name={ 
	"easy",
	"normal",
	"hard",
	"very hard",
	"nightmare"
}

dif_desc={
 "+1 apple per level",
 "",
 "double archeos life",
 "-1 heart",
 "need +25% xp to level up",
}

skill_desc={

 "consume apple to heal 1 damage.",
 "take item to your inventory.",
 "open chest to find a magic item.",
 "open door to climb tower and refill level.",

 "bats will morph in a vampire.",
 "rats have 50% chance to dodge and swap position.",
 "each turn, a random blob split in two.",
 "flee if a nearby monster is hit.",
 
 "deal +1 damage for each daggers in the group.",
 "each dead monster have 20% chance to spawn a skeleton.",
 "need two hits to die. kill nearby monsters to lower armor.",
 "roll down to a free nearby space if near a hole.",
 
 "resiste ice spells",
 "resiste fire spells",
 "if you leave a floor with at least one vampire.", 
 "protect nearby allies from your attacks.",
 
 "copy a random ally when attacked.",
 "need three hits to die. kill nearby monsters to lower armor.",
 "ghosts have 50% to dodge and swap position.",
 "no special power",
 
 "hit nearby monsters to tower archeos life.", 
 "if attacked, lonely fairies fly to a free space.",
 "poison your hero until next level up ( poison deal +1 dmg on each fights )",
 "fighting 3 or less wolves lower damage by 2.",
}



function g_name(k)
 na={
  "apple","item","chest","door",
  "morph","dodge","split","coward",
  "weapon","raise","armor","roll",
  "r.cold","r.fire","drain","protect",
  "clone","armor","dodge","",
  "boss","escape","venom","pack",
 }
 return na[k+1]
end
function nit(k)
 na={ 
  "reduce damage of solo target",
  "reduce damage of 6+ groups",
  "kill one monster",
  "ice a group of monsters",
  
  "burn a 3x3 zone",
  "heal all your wounds",
  "climb tower faster",
  "+1xp for each fight",
  
  "+40 xp",
  "reduce damage of undeads",
  "kill a monster type",
  "reduce damage of upper group",
  
  "slash monsters in a column",
  "destroy deprecated monsters when you ascend",
  "randomize monster positions",
  "",
  
 }
 return na[k+1]
end

function usp(e)
	e.x,e.y=gpos(e.px,e.py)
end

function gpos(px,py)
 return px*8+3,py*8+3+nfc*clb()*8
end


function upe(e)
 e.t+=1

 
 e.vy+=e.we
 e.x+=e.vx
 e.y+=e.vy
 e.vx*=e.h
 e.vy*=e.h
  
 if e.u then e.u(e) end

 if e.sq then
  usp(e)
 end
 
 if e.x<0 or e.x>120 then
  e.x=mid(0,e.x,120)
  e.vx*=-1
 end
 
 -- gain xp
 if e.xp and e.y>128 then
  kl(e)
  sfx(2)
 end

 -- twinkle
 if e.twk and t%4==0 then
  local p=mk(140,e.x,e.y)
  p.lp=2
  p.green=12
  p.hp=12+rd(8)
  p.we=-rnd(.2)
  p.x+=rd(5)-2
  p.y+=rd(5)-2
 end

 -- life
 if e.hp then
	 e.hp-=1
	 if e.hp<=0 then
	  kl(e)
	 end
 end
 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   if n<=0 then
    e[v]=nil
   else
    e[v]=n
   end
  end
 end 
 
 -- tweens
 if e.twc then
  local c=min(e.twc+1/e.tws,1)
  local cc=e.twcv and e.twcv(c) or c
  e.x=e.sx+(e.ex-e.sx)*cc
  e.y=e.sy+(e.ey-e.sy)*cc
  if e.jmp then   
   --e.y+=sin(c/2)*e.jmp
   local n=sin(c/2)*e.jmp  
   e.x+=cos(e.jma)*n
   e.y+=sin(e.jma)*n   
  end  
  e.twc=c  
  if c==1 then
   e.twc=nil
   e.jmp=nil
   e.twcv=nil
   local f=e.twf
   if f then
    e.twf=nil
    f()
   end
  end
  --]]
 end
  
 
end

function _update()
 t+=1

 if(uu) uu() return
 
 
 foreach(ents,upe)
 
end

function _draw()
 cls()

 if fs then
  rectfill(0,0,127,127,fs)
  fs=nil
 end
 

 -- draw ents
 for i=0,2 do
  dp=i
  foreach(ents,dre)
 end

 -- anims
 for a in all(anims) do
  fr=flr(a.st+a.t)
  a.t=a.t+a.s
  if a.t>=a.max then
   del(anims,a)
  else
   spr(fr,a.x,a.y)
  end
 end
 
 -- draw game over
 if gmo then
  if(t<60) then
   for i=0,256 do
    x=i%16
    y=flr(i/16)
    spr(207+mid(0,t-10-(x+y*2),12),x*8,y*8)
   end
  else
   if(btn(4)) t+=20
   r=sget(30,8+min((t-60)/8,3))
   sr=sget(30,8+mid(0,(t-240)/8,3))
   rectfill(0,0,127,127,r)
   if(t>=280)_init()
   print("game over",46,62+6-t/10,sr)   
  end
 end
 
 -- print log
 for i=0,1 do
	 cursor(3-i,2-i)
	 color(i==0 and 1 or 7)
	 for l in all(logs) do	  
	  print(l)	  
	 end
 end
end


function down()
 for i=0,elmax do
  x=flr(i/ymax)
  y=ymax-(i%ymax)-1
  e=gl(x,y)
  if e!=nil then
   if y+1==ymax then
    kl(e)
   else
    mvt(e,x,y+1)
   end
  end
 end
end

function log(n)
 add(logs,n) 
 while #logs>20 do
  del(logs,logs[1])
 end
end



-->8

-->8
-- new

function gsq(x,y)
 return grid[x*ymax+y+1]

end
-->8
-- tweening
function move(e,dx,dy,n,f)
 moveto(e,e.x+dx,e.y+dy,n,f)
end

function moveto(e,tx,ty,n,f)
 
 e.sx=e.x
 e.sy=e.y
 e.ex=tx
 e.ey=ty
 e.twc=0
 e.tws=n
 e.twf=f 
 e.jma=-.25
 
 if n<0 then
  local dx=e.ex-e.sx
  local dy=e.ey-e.sy
  local dd=sqrt(dx^2+dy^2)
  e.tws=-dd/n
 end

end
__gfx__
000000000880880007707700022077000220220000000000088100000880880000000000000000000000000000c77c000c0000c0077777777777777777777700
0000000080080080700c00702221007022222220000000008f8100008f88f8800004440000000000001cc1000c1001c0c000000c7000000000000000000000c0
000000008022028070110170222001702222222000000000888100008888882000444550000cc00001c77c10c100001c000000007000000000000000000000c0
0000000080222220701111c0222011c02222222000000000888100008888882005a4954100c77c000c7777c070000007000000007000000000000000000000c0
000000000822220007111c0002201c00022222000000000008810000088882000455555100c77c000c7777c070000007000000007000000000000000000000c0
00000000008220000071c0000020c0000022200000000000008100000088200001515511000cc00001c77c10c100001c000000007000000000000000000000c0
0000000000020000000c000000010000000200000000000000010000000200000011111000000000001cc1000c1001c0c000000c7000000000000000000000c0
000000000000000000000000000000000000000000000000000000000000000000011100000000000000000000c77c000c0000c07000000000000000000000c0
001121d62493d18e13ba7777012012802211000000000000022000082200000020000000200000000ccccccccccccccccccccc007000000000000000000000c0
0000105d15415028288e777702101320676c0000002200002f8200202820000082000000000000000000000000000000000000007000000000000000000000c0
000000150150101211113ba7102023102288000002f22800282200000200200000002000000000000777777777777777777777007000000000000000000000c0
00000001001000011dc7777712012300eeff000002882028022020280000000200000000000020007000000000000000000000c07000000000000000000000c0
000000000000000028e8211120122110aabb000000228822000000020000000000000000000000007000000000000000000000c07000000000000000000000c0
00000000000000009abcdef72109abc00000000000228800000000000000000000000000000000007000000000000000000000c07000000000000000000000c0
000000000000000022228888000228801c7777c100022000020000800000000000000000000000007000000000000000000000c07000000000000000000000c0
000000000000000011111111000eeff0111dcc7700000000000220002000000800000000000000007000000000000000000000c07000000000000000000000c0
0066d6000066d6000066d6000066d600a444444aa445444aa445414a00000000000000000000000002202200020077001c7777c17000000000000000000000c0
0611116006111160061111604444444479999997795959974959599500000000000000000000000022222220222c0070c10c0ccc7000000000000000000000c0
d111111dd111111d4444444411111111a444444aa544454aa544554a000000000000000000750000222222202221017070707c0c7000000000000000000000c0
61144116611441161111111144444444955555594555555945515559bb000050bb0000000057500022222220222111c07c07c01c7000000000000000000000c0
6414414644444444d111111d1111111199a99a9999a99a9499499a940544446605440000000570000222220002211c0070cc010c7000000000000000000000c0
d414414d111111114444444444444444515115155151101551511011bb000050bb00000000000000002220000021c0007cc0100c7000000000000000000000c0
64144146d111111d111111111111111151111115511101151111011500000000000000000000000000020000000c0000cc01001c0ccccccccccccccccccccc00
6414414664144146d111111dd111111d51111115511010155010101500000000000000000000000000000000000000001cccccc1000000000000000000000000
0066d6000066d6000066d6000066d6000066d600111001111c777771000000000000000000080000000400000904000080000000000000001110111011101110
061111600611116006111160061100600600006010000001710000cc00000000000800000008000000a800000000000000050000400000001110111011101110
d111111dd114111dd141110dd111000dd100000d1000000170700001000000000009000000a880000008400a0004000000000000000500001110111011101110
61144116641411166441110664110006610000060000000070170011000000000087800000888070000840000004000000000000000000000000000000000000
64144146641411166441110664110006610000060000000070c0010000a77a00009a970000898800904880000004000000050000000000001011101110111010
d414414dd414111dd441110dd411010dd101010d100000017c0000000a7777a0089aa9800a899800008880000004490000050080000000001011101110111010
641441466414111664410016641010166110101610000001c00000110a7777a0087aa990009a99000488a4000048400000550000000500041011101110111010
6414414664140006640011166401111661111116111001111c1011c100a77a00899aa998089aa980088888000048440000555000000550000000000000000000
0000000000000000000000000000000000000000000000000000000000055000cacac0000808000000effe200cfc000000000000400900000566500040040000
00d0d0000f0f000000222200006066000b3bb33b0677600004940000004455000ccc00000a8a00000008e8000fffef0000bb3500989900000677700094490550
011d1100044400f0027fe8200ddcc0d0003a3930057570000999244000a4950000dd00000888880000dfee1000eeeff00b676350898944900575700044440005
d1ddd1d00444000f2fe88882009ca000000bb30006776000004222090044554000ccddd0002288800dd7171d0e5fffff0b716330099444090677600072274405
117071100545450f282e2e82000d1c00004535400656567000902200005151500dccdddd082822800d11d111fe44feff0bd6d330400994090666605048844540
100000100054445f2e8f8fe20c10ddc000344430000065070902444204111114d0cc00dd828222200f0ddd0ef044450f3333353300966d000566600504444544
1000001000f5f5f502ffff200000dd0000044400000056000009000405011105d0dccccd00022220000ddd0000f45e0003323550094dd490005666550e5f5554
010001000000000000000000000c00c000b303b00006006000009040000505000d0dddd000020020000e0e0000f00f000538555009000009000555500e0f0e0f
005777500057775097999979a7aaaa7a00000000000000000000000000000000000dd00000000000000000d000004b00000b8e00400900000000000000000000
505868509958685052585825525858250b3bb33b00000000007888000000000000eed07603bbbb0000d0d00d0b40200b00737800989908820000000000000000
95066680557966800226662202266622003a3930007500004978e8800088200000fe26dd93ab15b006d7d0dd00244422000ccd00898922220020020000000000
59522880025599800028882000288820750bb300005750009972888008e88200000fe2d003b133b001ddddddb44686400c00dcc00992266d0022220000000000
057588800022557900888820008888205735354b0005700000472220088882000ff3be0000033b0f0ddddddd004777420ddbcddc402882090028820000000000
00595820008882550088882000888820033444000000000004047770e22222e00009b00000bbb0040055dd5d00244420000bbc0c00d66d0000d66d0000000000
008575200088822200888820008888200004440000000000004044400f77fe0000f009000b3000bf0050d00d0040202b0003bc00094224900002200000000000
0222595002222220022222200222222000b303b0000000000000404000000000000f00f003bbbb300050d0000b20b00000c000c0090000090000000000000000
00577750055000000057775000000550001666100000000000000000000000000000000000000000000000d000002b0000000000400900000000000000000000
005c6c5007c70007005c6c5070007c70101c6c1000000000000000000000000000000000000000000000000d0b24440b00000000989908820777760000000000
70066687066662827006668728266660c10666c0000000000000000000000000000000000000000000d0d0dd00467642000000008987777607888d0000000000
0882288226c628820882288228826c621c111cc0000000000000000000000000000000000000000008d8d5ddb2478740000000000997888d07882d0000000000
028888222558882002888822028885520161ccc0000000000000000000000000000000000000000001dddddd00467642000000004027882d07822d0000000000
00288220722882200028822002288227001c1c1000000000000000000000000000000000000000007d7ddd5d002444200000000000d7822d07222d0000000000
0088882000888820008888200288880000c1611000000000000000000000000000000000000000000055d50d0040202b000000000947222d006dd00000000000
0222222002222220022222200222222001111c100000000000000000000000000000000000000000050d00000b20b0000000000009006dd40000000000000000
0000000000000000000000000000000000000000000000000000000000011000c6c6c0000c0c000000ccccc00c6c000000111100100c000001cc1000c00c0000
00c0c000000000000000000000c0cc0006c66cc60c66c0000c6c000000cc11000ccc000006c600000006c6000666c60001ccc110c6cc00000c6660006cc60110
011c110006060000001111000c1cc0c000c161c00161600006661cc0006c6100001100000ccccc0000cccc1000ccc6601c666c116c6c11c001616000cccc0001
c1ccc1c00ccc00600176cc10006c600000066c000c66c00000c1110600cc11c000cc11100011ccc00cc6161c0c1666661c616cc10cc1110c0c66c0006116cc01
117071100ccc000616ccccc1000c1c0000c111c001cc1c60006011000011111001cc11110c1c11c00c11c1116c116c661c666cc1100cc10c0cccc010c11cc1c0
1000001001c1c1061c1c1cc10c1011c000c111c00000c1060601ccc10c11111c10cc0011c1c11110060ccc0660111106cccccccc00c6660001ccc0010cccc1cc
10000010001ccc161c1616c1000011000001110000001c000006000c01011101101cccc100011110000ccc0000611c001cc6c1c10c1661c0001ccc110d161116
01000100006161610166661000010010006c0c60000c00c0000060c0000101000101111000010010000606000060060011c611110c00000c000111100d060d06
00001110111000000000000000000000000000000000000000000000000000000001100000000000000000c000001c0000000000000000000000000000000000
0001aaa1a991000000000330000000000000000000000000000000000000000000cc10cc0ccccc0000c0c00c0c10100c0000000000030000b00000b000000000
1111a1a19111110000003b300000000000000000000000000000000000000000006c1c116c6c11c006c6c0cc001ccc1100000000000b00000b333b0000000000
9451a191991549000003bb3000000000000000000000000000000000000000000006c1100cc111c001ccccccc1c616c0000b00000007000003bbb30000000000
1111919191111100003bbb300000000000000000000000000000000000000000066ccc0000011c060ccccccc00c666c100b7b0003b777b3003b7b30000000000
000199919100000003bbbb300000000000000000000000000000000000000000000cc00000ccc00c0011cc1c001ccc10000b00000007000003bbb30000000000
000011111000000003333330000000000000000000000000000000000000000000600c000c1000c60010c00c0010101c00000000000b00000b333b0000000000
00000000000000000000000000000000000000000000000000000000000000000006006001cccc100010c00001c0c0000000000000030000b00000b000000000
7777777600d66d007505444400d000000000000000044000000000000000000000d6d00000077000047777f000000000dd00000000000000010000010000000f
7ccc776d676556665654000907c66000098600000065560000044400000b30000d666d00000760000fffff4f00677661d7600000007788000d00000d0001110f
7ccc766d76d66d6605500070dc1d0000082d000000611d00000a99000006d000d666ddd007776660004545440d7766dd067600000ee7228007000007001111f0
7ccc666ddd6dd6dd5404070006d6100006d62800061711d00004947700700d007d6ddd5507666660004455440666dddd006760008228111207000007016d1111
7776555d06666660400070000601d1000002d1006172881d0a4497dd070000d0d7ddd5650006d00000ff44ff061d116d00067649081811200070007001dd1112
066655d005dddd504007040000001610000816106162221d49447d70060000600d7d56500007600000f4f4ff0611116d000067900028120000d878d001111112
00665d0005dddd504070004b000001610000016161d1111d999944000060060000d76500000760000777774f0d10006d0000494500082000000e220000111120
0006d00000dddd00470000b000000016000000160dddddd00000000000066000000d50000007600004fffff00d0000d000009054000000000008210000012200
000440000000000000000000666666666666666600888080808220066b66bb66666d0000000000022222022220000222022002202222022220028888288a8200
00655600000000000000000006666666b333ddd000080080802000003ddddd3dddddd00000000002222202200220220022200220220022002288888228888920
00611d000000000000000000006666bb3333dd000008008220220000300ddd00000ddd0000000022222202200220220002200220820022002882000008278220
061711d0000000000000000000000066d0000d0000080020202000003006d3000000dd0000000022002202800820880008800280880082002820000008222700
6179aa1d000000000000000000000066d00003000002002020222000300663000000dd0000000880002808822800880008888880888082002220000008220000
6169991d000000000000000000000066d0000300000000000000000000066d000000dd0000000880002808822800280008800880820088002122200002880000
61d1111d000000000000000000000066d00000000000000000666ddddd06660000066d0000008800002808802880220008800880880088008202222000000000
0dddddd0000000000000000000000066d00000000000000000066000dd0666666666d00000008800002808800280220088800880880088008800022220000000
00000000000000000000000000000066d000dddd00060000060d60000d0b6ddddddd000000088000002808800088022208800880888808888000000222200000
99999999000000000000000000000066d00dd00660dd0000066d6000000b6d00dd00000000088000002808800008000000000000000000000000000002222000
94444449000000000000000000000066d0ddd00666dd6000666d60d00006bd000dd0000000822222222808811111811ddd6666666666666666ddd11111128811
a555555a000000000000000000000066d0ddd00666dd6000666d6dd00006b3000066000000800000002808200000080000000000000000000000022222008820
aa9aa9aa00000000000000000000006630dd6006660d6060660660d0000663000006b00008200000002808200000000000000000000000000002220000228820
94944949000000000000000000000066d0d660066d0d6666660660000d0663000003bb0008000000000808000000000000000000000000000088800000088820
9444444900000000000000000000066666066006d0006666600660006d066d0000030b6082000000000808000000000000000000000000000088888888888200
944444490000000000000000000066666660666d00006606600666666dd666600000006680000000000202000000000000000000000000000008888888882000
00000000000000000000000000000000000000000000000000000000000000000000000000334bbb00334bbb00334bbb00000000000000000000000000000000
00007000000770000007700000070000007777000007700000777700000770000007700000882bb000882bb000882bb000000000000005600088880000000000
00077000007007000070070000700000007000000070000000000700007007000070070008888222009882220098822200000000000056500880088000000000
00007000000070000000700000707000007770000077700000007000000770000007770008788822000988220009889900f90000009565000800808000000000
0000700000070000007007000077770000000700007007000007000000700700000007000888882d000f882d00008990009f8800009650000808008000000000
0007770000777700000770000000700000777000000770000070000000077000000770000888822d00ff822d00008900000f8800054990000880088000000000
000000000000000000000000000000000000000000000000000000000000000000000000002222d000ff22d0000f290000098800045000000088880000000000
0000000000000000000000000000000000000000000000000000000000000000000000000002dd000002dd0000022d0000000000000000000000000000000000
80008000800080008080808080808080808080808080808080808080808080808080808088808880888088808888888800000000011111100000000000057000
00000000000000000000000000000000000800080808080808880888888888888888888888888888888888888888888800000001100110011000000005975000
00000000008000800080008080808080808080808080808080808080808080808080808080888088888888888888888800000110000110000110000009440000
00000000000000000000000000000000080008000808080888088808880888088888888888888888888888888888888800001000001001000001000054450000
80008000800080008080808080808080808080808080808080808080808080808080808088808880888088808888888800010000001001000000100075000000
00000000000000000000000000000000000800080808080808880888888888888888888888888888888888888888888800100000010000100000010000000000
00000000008000800080008080808080808080808080808080808080808080808080808080888088888888888888888800100000010000100000010000000000
00000000000000000000000000000000080008000808080888088808880888088888888888888888888888888888888801111111111111111111111000000000
000000000000000000000000000000000000000000007000ddddd1dd0111000000000000000000002e2e20000000000001000000100000010000001056777777
0000000000000000000000000000000000007c000000c000ddddd111011100110110000000000000efee80000000000011100001000000001000011160000000
00077700007770000077c1000000000000070c0000070c001dddd16d011100110110000000100000eee880000000000010011001000000001001100170aa4444
0077770000777700007011000007c00000700100000c0100111111dd000000000000000000000000288820000000000010000110000000000110000160000000
007700000000770000c01000000c100007c1110000701100dddd11dd000111000000000000000000028200000000000010000011100000011100000156777777
007700000000770000c10000000000000000000000111100ddddd111000111000000011000000000000000000000000010000100011001100010000100000000
000000000000000000000000000000000000000000000000ddddd16d000111000000011000000100000000000000000010000100000110000010000100000000
000000000000000000000000000000000000000000000000ddddd1dd000000000000000000000000000000000000000001001000011001100001001000000000
000000000000000000000000000000000000000000000000dd1ddddd011000000000000000000000000000000000000001001001100000011001001000000000
000000000000000000000000000000000000000000000000111ddddd011001110000000000000000000000000000000000110110000000000110110000000000
0077000000007700000333000003300000b30000000000006d11dddd000001110000000000000000000000000000000000111000000000000001110000000000
0077000000007700003b3330003b33000033000000067600dd111111011001110001100000000000000000000000000000010000000000000000100000000000
007777000077770000333530003353000000000000071600dd1dddd1011000000001100000001000000000000000000000001000000000000001000000000000
0007770000777000003555300003300000000000000d6d00111ddddd011011100000000000000000000000000000000000000110000000000110000000000000
0000000000000000000333000000000000000000000000006d1ddddd000011100000000000000000000000000000000000000001100000011000000000000000
000000000000000000000000000000000000000000000000dd1ddddd000000000000000000000000000000000000000000000000011111100000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000008080707070100000108030887000503000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0d0e0e0e0e0e0e0e0e0e0e0f0d0e0e0f00404142434445464748494a4b4c4d4e4f5058595a5b0000000000000000000000000000000000e6f6e7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f1d00001ff1c0c0c0c0c1c1c1c1c2c2c2c2c3c3c3c3c8c0c2c1c20000000000000000000000000000000000e6f6f7e8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f1d00001fcdc0c0c1c0bfc2c1c2c3c3c2c1c2c2c4c5c3c1c1c2c20000000000000000000000000000000000e6f6f7f8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f2d2e2e2fcebfbfbfbfbfbfc0bfbfbfbfbfbfc1bfbfbfbfbfbfbfbfbfbfbf00000000000000000000000000e6f6e7f8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f0d0f0d0f000000000000000000939400000000000000000000000000000000000000000000000000000000e6f6f7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f2d2f1d1fbfbfbfbfbfc0bfbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfbf000000000000000000000000e6f6f7f8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f3e3f1d1f000000000000580000000000000000000000000000000000000000000000000000000000000000e6f6e7e8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f3e3f1d1f000000000000000000000000000000000000000000000000000000000000000000000000000000e6f6e7f8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f3e3f2d2f000000000000000000000000000000000000000000000000000000000000000000000000000000e6f6e7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f0d0e0e0f0d0e0e0f0000000000000000000000000000000000000000000000000000000000000000000000e6f6f7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f1a1b1b1c1d00001f0000000000000000000000000000000000000000000000000000000000000000000000e6f6f7e8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f1d00001f1d00001f0000000000000000000000000000000000000000000000000000000000000000000000e6f6f7f8f90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d000000000000000000001f1d00001f1d00001f0000000000000000000000000000000000000000000000000000000000000000000000e6f6e7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2e2e2e2e2e2e2e2e2e2e2f2d2e2e2f2d2e2e2f0000000000000000000000000000000000000000000000000000000000000000000000e6f6e7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f000000000000000000000000000000000000000000000000000000000000000000000000000000e6f6e7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2e2e2e2e2e2e2e2e2e2e2e2e2e2e2f000000000000000000000000000000000000000000000000000000000000000000000000000000e6f6f7e8e90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010400001817501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000004701f370243751830018300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002732500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000004750c471000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000029170113602725011150243400f230221300f3201f2200c1201d3100c2101b1100a310182100a11016310082100000000000000000000000000000000000000000000000000000000000000000000000
011000001c3751c375103721037210372103721037500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001810310402104021817300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003747526405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000025009230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001b37522375000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000223751b375000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003a77022770227752270022700227050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000273723a3753a3353a3253a3153a315004003a405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c000033605336552e4552e4152e4052e4053810036200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003765400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000327103202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01200000036540a655186042e60500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000221700a260223500f450272401334027130182302b4201d2202b120223102e210274102e2102b110303002e2003040030200331003330033200351000030000000000000000000000000000000000000
00100000181731b1431d1331f133221232412327113291132b1130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000024654186251f6540c635216540c6251f6540c6351f6541862518604186040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000180751f0521f0421f0321f0321f0321f0221f0221f0221f0121f0121f0150010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
010800002265518073180030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003047318405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000187731b37522175182451b34522045184351b13522235183251b02522425183151b21522015184151b21522315180151b215220150040000000000000000000000000000000000000000000000000000
011000001807030071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000018375222751b1750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000c57413551135150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000030274032710a2720a2520a2520a2420a2520a2320a2420a2220a2320a2120a2220a2020a2120000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000037500100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000181751b475222752437230462241523044224332242223001400400003000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000183751a3751b3751f3721d3751b3751a375163751a3751d3721b3751a3751837513375183751b3751a375163751837218362183521834218332183221831218315183021830218302183021830218702
01100000184730c4750c4450c4350c4250c4150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000371543a5723a5223a51522100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001855524555185552453224515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001105218052110211802211011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f6342b615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c02300200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f2551d1550c5551802518015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000013652136512b6512b6452b6341363113625136141f60407605136041f6052b604076051f6042b60500000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f5510c551215512b535185222b51521502180021d0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f473074731f6541365200632006220061100600241702412224115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000136751d67500000136451d64500000136351d63500000136251d62500000136151d615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001f6222b512000001f6423751200000000001f6523051200000000001f6021f652375120000000000000001f60237502000001f60237502000000000000000000001f6023750200000000000000000000
011000001d1551d1150010000100241552411500100001002015520115001000010022155221151b1551b1151d1551d1150010000100201552011500100001001b1551b115001000010022155221151b1551b115
011000002c0502b05029052290322903229032290222b050270502705027032270122e0502e0522e0322e02230050330502e0502e0522e0322e0322c0322b0502905029052290322901227050270522702227015
011000002c0502b05029052290322903229032290222b050270502705027032270122205022052220322202224050270502705027052270322702227015220502905029035270502705522050220522202222015
012000000515505115001000010003055030150010000100081550811500100001000305503015031050310505155051150010000100030550301500100001000815508115001000010003055030150310503105
0110000000000200052c5552c5552b5552c5052c5552e5552e5052c5552b5052b5552955524500275552400000000200052c5552c5552b5552c5052c5552e5552e5052c5552b5052b55524555245002755524000
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
01 2b 42 43 44
00 2b 42 43 44
00 2b 2c 43 44
00 2b 2d 43 44
00 2b 42 43 44
00 2b 42 43 44
00 41 2c 2e 44
00 2b 2d 2e 44
00 2b 2c 2e 2f
02 2b 2d 2e 2f
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
