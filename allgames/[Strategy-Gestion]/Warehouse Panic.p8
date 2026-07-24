pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- warehouse panic
-- benjamin soule


--fast_tax=false
--crate_test=false 
--test_item=5

zgx=8
zgy=4
zxm=11
zym=11
xmax=24
ymax=15
tempo=250--500
en_loss=.0005
intro=20

buy_prices={0,-2,1,2,3,5,3,8,8,15}
sell_prices={0,1,-2,-4,-6,-9,-6,-14,-16,-30}
item_prices={50,80,40,30,15}
ddr={1,0,0,1,-1,0,0,-1}


function _init()
 t=0
 logs={}
 init_menu()

end

function init_menu() 
 t=0
 go=nil
 print("warehouse",0,0,7)
 print("  panic  ",0,6,7)
 pxls={}
 xm=35
 ym=11
 for x=0,xm do
  for y=0,ym do
   add(pxls,pget(x,y))
  end
 end
 
 function loop()
  if t>intro and btnp(4) then
   go=1
   sfx(18)
   music(-1,2000)
  end
  if go then   
   go+=1
   if go>40 then   
    init_game()
   end
  end
  if t==intro then
   music(0,800)
  end
  
 end
 
 
  
 function mdraw()
  cls(0)
  map(32,0)
  if go and go>20 then
   dark( (go-20)/20 )
  end
  srand(32)
  c=max(1-t/64,0)
  ok=t%2==0
  for x=0,xm do for y=0,ym do
   if pxls[1+x*(ym+1)+y]==7 then
    px=11+x*3    
    k=rand(intro)
    s=rand(3)
    if t==k and ok then 
     ok=false
     sfx(13,0,18+s,1) 
    end
    
    py=6+y*3+min(0,t-k)
    sspr(88,64,3,5,px,py)
   end
  end end 

  if t>intro then
   g=cos(t/10)+.5
   rectfill(0,109+g,127,120-g,go and (9+t%2) or 8)
   if not go or t%2==0 then
    print("press <z> to start",27,112,7)
  	end
  end 
 end

end


function init_game()
 mdraw=dr_game
 loop=upd_game
 t=0
 gmo=false
 timer=0
 day=0
 offer_coef=1.5+rand(.2)
 new_day()
 hour=8
 gold=20
 energy=1
 rat_counter=4+rand(3)
 pool=4

 ents={} 
 hands={}
 grid={}
 trucks={}
 htail={}
 inv={}
 
 -- caracs
 strength=1
 whz=0
 whs=0
  
 -- furnitures
 desk=mke(150)
 desk.szx=24
 
 phone=mke(181)
 phone.upd=function(e)
  e.fr=181
  if e.cring then
   e.fr=182-mod(2,16)
   if t%32==0 then
    sfx(16) 
    local e=mke(97,e.x,e.y)
    e.upd=function()
     e.vx=cos(t/20)
    end
    init_phys(e)
    e.vy=-.75
    e.life=40
   end
   if act(e) then
    e.cring=nil
    frz=true
    open_shedule()
   end   
  end
 end
 
 comp=mke(134)
 comp.dr=function(e,x,y)
  if mail then
   
   spr( (hour<22 or t%2==0 or mail.id>0 ) and 135 or 153,x,y+cos(t/20)+.5-12)
  end
 end
 comp.upd=function(e)
  if mail and act(e) and not mail.active then
   read_mail()
  end
 end
 
 plan=mke(132);
 plan.x=68
 plan.y=20
 plan.szx=16
 plan.szy=10
 plan.dr=function(e,x,y)
  spr(132,x+18,y,2,1.2)
 end
 
 clock=mke()
 clock.dr=function(e,x,y)
  circfill(x,y,6,1)
  circfill(x,y,5,7)

  function l(an,r,cl)
   line(x,y,x+cos(an)*r,y+sin(an)*r,cl)
  end
  
  l(.25-timer/tempo,4,13)
  l(.25-hour/12,2,1)

  for i=0,3 do
   an=i/4
   r=4
   pset(x+cos(an)*r,y+sin(an)*r,6)
  end
 end
 
 bed=mke(167)
 bed.szx=16
 bed.dk=0
 
 local slp=function(fl)
  sfx(15,0,fl and 24 or 27,3)
  hero.vis=not fl
  bed.full=fl
  bed.t=0
 end
 
 bed.upd=function()
  if not bed.full then
   if bed.t>10 and #hands==0 and not phone.cring and act(bed) then
    slp(true)
   end
  else
   if btnp(4) or phone.cring then
    slp(false)
   end
  end
  
  if bed.full then
   local n=en_loss
   if hv(6) then n*=2 end
   energy=min(energy+n,1)
   bed.dk=min(bed.dk+.01,0.5)
   dark(bed.dk)  
  elseif bed.dk then
   bed.dk=max(bed.dk-.04,0)
   dark(bed.dk)
  end
  
 end
 
 bed.dr=function(e,x,y)
  local k=0
  if bed.full then
  	spr(183,x,y-4,2,1)
  	k-=1
  end
 	if hv(6) then
 	 spr(113,x+2,y+k-5)
 	end
  
 end
  
 -- inter
 int=mke()
 int.dp=11
 int.dpl=0
 int.upd = function(e)
  dx=hero.x-plan.x
  dy=hero.y-plan.y
  if dx>0 and dx<32 and dy<16 and hero.di==3 then
   e.dpl+=.1
  else
   e.dpl-=.1
  end
  e.dpl=mid(0,e.dpl,1)
 end
 int.dr=dr_inter

 
 -- draw_map
 maj_map()
 
 -- hero 
 hero=mke(16,128,80)
 hero.upd=upd_hero 
 hero.di=0
 hrn=0
 
 
 --
 trg=mke()
 trg.dr=function(e,x,y,z)
  if frz then return end  
  if e.valid then  
   rect(x,y+z,x+7,y+z+7,8+t%8)
  else
   spr(81,x,y+z-1)
  end
 end
 -- crates
 for k=0,3 do 
  local x=0
  local y=0
  
  for i=0,40 do
   x=zgx+rand(zxm)
   y=zgy+rand(zym)
   if is_drop_free(x,y,true, true) then
    break
   end
  end
 
  
  local c=mkc(k+1)
  cins(c,x,y)
  cpos(c)
 end
 


end



function crunch(e)
 sfx(13,1,16,2)
 local fr=(e.mcr.tp-3)*2+rand(2)
 
 local p=mke(0,e.x,e.y)
 p.z=e.z
 init_phys(p)
 p.dr=function(e,x,y,z)
  sspr(64+fr*3,69,3,3,x,y+z)
 end
 
 p.vx=hrnd(1)
 p.vy=hrnd(1)
 p.vz=-rnd(2)
 p.we=rnd(.2)+.1
 p.frict=0.96
 p.life=16
 
end

function mk_cat()
 local e=mke(101,86,64)
 e.an=rnd()
 e.wf=0
 
 e.upd=function(e)
  if e.twc then
   return
  end
 
  walk(e)
  e.fr=101+(e.wf/3)%2
  
  for r in all(ents) do
  	if not r.mcr and not e.cfeast and r.stomach and dst(e,r)<32 then
 			e.cfeast=80
 			function feast()
 			 sfx(17,0,14,1)
 			 corpse=mke(117,r.x,r.y)
 			 corpse.life=150
 			 kl(r)
 			end
 			function atk()
 			 sfx(17,0,12,2)
 	   e.fr=102
 	  	moveto(e,r.x,r.y,-3,feast)
 	  	e.jmp=12
     curv(e,2)
    end
    sfx(17,0,10,2)
    e.fr=103
    e.flp=e.x<r.x
    move(e,0,1,40,atk)
    
   end
  end
  
 end 
 


end

function jump_out(e)
 sfx(17,0,8,2)
	move(e,hrnd(8),hrnd(8),16)
 e.ez=0
 e.jmp=8 
 if e.mcr then
  e.mcr.rat=nil
  e.mcr=nil
 end
end


function mk_rat(x,y)
 local e=mke(0,x,y)
 e.wf=0
 e.inv=true
 e.stomach=0
 e.an=rnd()
 init_phys(e)
 e.dr=function(e,x,y,z)
  fr=flr((e.wf%12)/4)
  sspr(16,64+fr*5,11,5,x,y+z,11,5,e.flp)
 end
 
 

 e.upd=function(e)
  
  if e.twc and t%4==0 then
   e.wf+=1
  end
  local c=e.mcr
  if c then   
   e.x=c.x
   e.y=c.y
   e.z=c.z-6
   
   --eat
   if fget(c.tp+64,5) then
    e.flp=false   
    c.eat+=1
    e.wf+=1
    if c.eat%8==0 then
     crunch(e)
    end    
    if c.eat>300 then
     c.tp=0 
     e.stomach+=2    
     jump_out(e)
     return
    end 
   else
    if not(c.twc) and e.t>40 then
     jump_out(e)
     return
    end  
   end
   
   local top=c.pz and gcr(c.px,c.py,c.pz+1)
   if not c.handed and top then
    e.res=0
   end
   
   if e.res<=0 then    
    e.cesc=100
    e.stomach+=1
    jump_out(e)
    return
   end
  elseif not e.twc then
  
   -- seek food
   if t%40==0 and not e.cesc then
    seek(e)
    return
   end   
   
   -- seek camion
   if e.stomach>4 and e.t%10==0 then
    for tr in all(trucks) do
     dx=tr.x+48-e.x
     dy=tr.y+16-e.y   
     if abs(dy)<32 and abs(dx)<80 then
      moveto(e,tr.x+48,tr.y+48,-2,function()kl(e)end)   
      return
     end   
    end  
   end
 
   --wander
   walk(e)
  end
 end
 return e

end

function impulse(e)
 vx=cos(e.an)*spd
 vy=sin(e.an)*spd
end

function walk(e)

 -- mergency recal
 local tt=0
 while bounce(e) do
  e.an=atan2(104-e.x,72-e.y)
  spd=3
  impulse(e)
  e.x+=vx
  e.y+=vy
  tt+=1
  if tt>100 then
   kl(e)
   return
  end
 end 

 -- walk
	if e.t%2==0 then
   e.wf+=1
 end  
 e.an+=hrnd(.05)
 spd=e.cesc and 1 or 0.3  
 local hd=dst(e,hero)
 if hd<16 then
  e.an=atan2(dx,dy)
  spd *= 3-(hd/16)*2
 end
 impulse(e)
 if e.flp and vx<-0.1 then e.flp=false end   
 if not e.flp and vx>0.1 then e.flp=true end   
 e.x+=vx
 if bounce(e) then   	
  e.x-=vx
  vx*=-1
  e.an=atan2(vx,vy)
 end   
 e.y+=vy
 if bounce(e) then   	
  e.y-=vy
  vy*=-1
  e.an=atan2(vx,vy)
 end  
     
end


function bounce(e)
 bn= e.x>=zgx*8 and e.y>=zgy*8 and e.x+e.szx<(zgx+zxm)*8 and e.y+e.szy<(zgy+zym)*8
 return not bn
end


function gncr(px,py)
 dd=999
 cr=nil
 for e in all(ents) do
		if e.tp then
		 dx=e.px-px
		 dy=e.py-py
		 d=sqrt(dx*dx+dy*dy)
		 if d<dd then
		  dd=d
		  cr=e
		 end
		end 
 end
 return cr
 
end


function hrnd(n)
 return rnd(n*2)-n
end

function is_edible(c)
 if c.twc then return false end
 return not c.rat and not c.handed and not gcr(c.px,c.py,c.pz+1) 
 
end

function seek(e)


 local a={}
 for c in all(ents) do
  if (c.tp==3 or c.tp==4) and dst(e,c)<24 then
   if is_edible(c) then
    add(a,c)
   end
  end
 end 

 
 if #a>0 then
  c=steal(a)
  function climb()
   if is_edible(c) then
    invade(e,c)
   end
  end
  moveto(e,c.x,c.y,-.5,climb)
  smooth(e)
 end
 
end


function dst(a,b)
 dx=a.x-b.x
 dy=a.y-b.y
 return sqrt(dx^2+dy^2)
end


function read_mail()

 sfx(15,0,16,3)

 hero.vis=false
 --frz=true
 sel=0
 mail.active=true
 comp.cml=10
 mail.dr=function()
  cls(12)
  
  for i=0,4 do
   spr(min(85+i,87),8,4+i*16)
  end 
  
  rectfill(0,121,127,127,6)
  sspr(69,64,5,5,2,122)
  sspr(74,64,6,5,96,122)
  ?"start",8,122,13
  ?gdat().."",108,122,13
  
  if comp.cml then
   camera(0,-comp.cml*8)  
  end
		rectfill(13,17,117,113,13)
  rectfill(12,16,116,112,6)
  rectfill(13,24,115,98,7)
  
  cx=14
  cy=26
  function pr(str,cl)
   cl=cl or 6
   print(str,cx,cy,cl)
   cy+=6
  end

  local aa="delete"
  local bb="pay now"
  
  if mail.id==0 then
   
   title="tax payment inquiry"
   pr("-------------------------") 
   pr("  we need you to pay")
   pr("")
   pr("     "..mail.pr.." gold")
   pr("")
   pr("  before day "..(day+1).." 0:00 am" )
   pr("-------------------------") 
   pr("") 
   pr("") 
   pr("       your beloved ruler") 
   aa="wait..."

  else
   title="an offer you can't refuse"
   cy+=3

   rectfill(16,26,34,44,fget(39+mail.id,0))
   spr(222+mail.id*2,17,27,2,2)
   
   function pv(nm,cl)
     while #nm<19 do nm=" "..nm.." " end
     pr("      "..nm,cl)
   end
   srand(mail.seed)
   pv(arand(great_nm),13)
   srand(rand(999))
   pv(item_nm[mail.id],13) 
   cy+=12 
   pr("   you can buy it now")
   pr("  for the amazing price")
   pr("           "..mail.pr.." $",8+t%3)
   
   pr("")
   pr( desc_nm[mail.id*2-1] )
   pr( desc_nm[mail.id*2] )
   --pr("        no refund  ")
  
  end
  print(title,14,18,13)
  
  -- buttons
  can_pay=gold>=mail.pr
  dx=14
  for i=0,1 do
  	cl=13
  	clt=6
  	if sel==i then
	 		cl=3
   	clt=7  	 
  	 if i==1 and not can_pay then
  	  cl=8
  	  clt=15
  	  if hero.cwr and t%4<2 then
  	   cl=2
  	   clt=3
  	  end  	  
  	 end  	 
  	end
  	
  	rectfill(dx,101,dx+48,110,cl)
   str=i==0 and aa or bb

   print(str,dx+(48-#str*4)/2,103,clt)
  	dx+=52
  end 
  if btnp(0) or btnp(1) then
   sel=1-sel
   beep()  
  end
  
  if btnp(4) and not comp.cml then
   
   function lv()
    hero.vis=true
    sfx(15,0,19,3) 
   end
   
   -- cancel
   if sel==0 then    
    if mail.id==0 then
     mail.active=nil
    else
     mail=nil
    end
    lv()
    
   else    
    if can_pay then
     --- buy 
     inc_gold(-mail.pr)
     if mail.id>0 then
      add_tool(mail.id)
     end
     mail=nil
     lv()
    else
     wrong()
    end   
   end
  end
 end
end

function hv(n)
 for k in all(inv) do
  if k==n then return true end
 end
 return false 
 
end

function add_tool(n)
 add(inv,n)
 

 if n==2 then
  strength+=2
 end 
 if n==3 then
  whz+=1
 end 
 if n==4 then
  wt(20, function() expand(2) end )
 end
 if n==5 then
  mk_cat()
 end
 
end

function expand(n)
 whs+=1
 lim=104
 for e in all(ents) do
  if e.x>=lim then
   e.x+=8
  end
  if e.tp and e.px>12 then
   cdel(e)
   e.px+=1
   cins(e,e.px,e.py,e.pz)
  end  
 end
 
 for y=4,14 do
  function f()
   local e=mke(161,lim+rnd(8),y*8+rnd(8))
   init_phys(e)
   e.we=-rnd()*.2
  end
   wt(rand(24),f)
   f() 
 end
 
 
 maj_map()
 sfx(17,1,0,4)
 n-=1
 if n>0 then
  frz=true
  wt(40, function() expand(n) end )
 else
  unfreeze()
 end
 
 
 
 
end

function arand(a)
 return a[1+rand(#a)]
end

function dr_inter(e)
 if e.dpl>0 then
  for i=0,1 do  
   local tr=gtr(i+1)
   if tr then
 			draw_plan(tr,e.dpl)
   end    
  end
 end  
 
 -- mail
 if mail and mail.active then
  mail.dr()
  return
 end

 -- gold
 local str=gold.."" 
 border(function()
  print(str,128-#str*4-10,120,7)
  spr(136,120,120,.74,.74)
  
  print("day "..day,3,120,7)
  
 end)
 
 -- energy
 hh=max(52*energy,3)
 cl=0x9a
 bcl=7
 
 if hero.ctir and t%2==0 then
  bcl=8
 end
 
 if energy<.25 then
  cl=0x28 
 elseif energy<.5 then
  cl=0x89
 end  
 
 rectfill(119,116-hh,125,116,bcl)
 fillp(0b1100100100110110)
 rectfill(120,117-hh,124,115,cl)
 fillp()


end



function border(f)
 apal(1)
 camera(0,1)
 f()
 camera(0,-1)
 f()
 camera(1,0)
 f()
 camera(-1,0)
 f()
 rpal()
 camera()
 f()
end


function act(e)

 local tx=hero.x+4+8*ddr[1+hero.di*2]
 local ty=hero.y+4+8*ddr[2+hero.di*2]
 adx=abs(e.x+e.szx/2-tx)
 ady=abs(e.y+e.szy/2-ty)
 return not gmo and adx<e.szx/2 and ady<e.szy/2 and btnp(4)
end


function draw_plan(tr,c)
 
 local dd=(1-c)*64
 local i=tr.id-1
 
 camera(-(4+i*64+(i*2-1)*dd),-3)
 map(22,25,0,0,7,3)
 pal(5,15)
 spr(59+i,8,8)
 rpal()
 local list=get_list(tr.stock)
 local y=3
 for l in all(list) do
  print(l.n.."."..names[l.id+1],19,y,4)
  y+=6
 end
 camera()
end

function get_list(a)
 local b={}
 local c={}
 for i=0,11 do add(b,0) end
 for n in all(a) do b[1+n]+=1 end
 for i=0,11 do
  local n=b[i+1]
  if n>0 then
   local k={id=i,n=n}
   add(c,k)
  end
 end
 return c
end

function gtopcr(x,y)
 for i=0,3 do
  local cl=gcr(x,y,3-i)
  if cl then return cl end
 end
 return nil
end
function gcr(x,y,z)
 return grid[x..","..y..","..z]
end




function mkc(tp)
 local c=mke(80) 
 c.tp=tp
 c.eat=0
 c.dr=function(e,x,y,z)
  spr(64+c.tp,x,y+z-4)
 end
 if c.tp==1 or rand(8)==0 then
  rat_counter-=1
  if rat_counter<=0 then
   rat_counter=max(4+rand(4)-day,1)
   r=mk_rat()
   invade(r,c)
  end
 end

 return c
end

function invade(e,c)
	c.rat=e
 e.mcr=c
 e.res=80
end

function cdel(c)
 if c.px then 
  grid[ckey(c)]=nil
 end
end
function cins(c,px,py,pz)
 pz = pz or getz(px,py)

 cdel(c)
 c.px=px
 c.py=py
 c.pz=pz
 grid[ckey(c)]=c
 
end

function cpos(c)
 c.x=c.px*8
 c.y=c.py*8
 c.z=-c.pz*4
end

function ckey(c)
 return c.px..","..c.py..","..c.pz
end


function next_hour()
    
 timer=0
 hour+=1
 if hour==24 then
  new_day()
 end
 if hour%4==1  then
  phone.cring=tempo*2
  phone.t=0
 end 
 for tr in all(trucks) do
  tr.wait-=1
  if tr.wait==0 then
  	gameover()
   return
  end
 end
 

end

function new_day()
 hour=0
 day+=1
 tax_coef=0.3+rnd(.5) 
 offer_coef-=1
 if mail and mail.id==0 then
  gameover()
 end
 
end





function mk_truck(id,stock)
 if id==1 and gtr(1) then
  id=2
 end

 local tr=mke()
 sfx(14,1)
 tr.unpink=1+rand(7)
 tr.id=id
 tr.dp=1
 tr.stock=stock
 tr.wait=14-day*2
 add(trucks,tr)
 
 -- draw
 tr.dr=function(e,x,y)
  local wr=8
  map(22,16,x,y,12,8)
  for i=0,1 do   
   wx=x+16+i*18+(id>0 and 46 or 0)
   wy=y+60
   circfill(wx,wy,wr,1)   
   circfill(wx,wy+1,4,6)
   circfill(wx,wy,3,13)
   
			--srand(x)
   --line(wx-5,wy+rnd(2)-4,wx-2,wy+rnd(2)-6,6)
   
   for n=0,3 do
    local an=-x/3+n/4
    local r=3
    circfill( wx+cos(an)*r, wy+sin(an)*r,1,1)
   end
  end  
 end 

 -- specific
 if id>0 then
  tr.x=-96
  tr.y= 8+(id-1)*40
  tr.sns=1
  
  -- arrival
  local f=function()
   local e=mke(16,tr.x+88,tr.y+44)
   e.dr=function(e,x,y)
    if e.waiting and tr.wait<=3 then
     ?tr.wait,x+2,y-6,7+mod(2,4)
    end
   end
   
   local nxt=function()   
    load_truck(e,tr) 
   end   
   move(e,10,0,10,nxt)  
  end
  move(tr,60,0,64,f)
 
 else
  tr.x=xmax*8
  tr.y=32 
  tr.sns=-1
  -- arrival
  local f=function()
   local e=mke(16,tr.x,tr.y+44)
   e.flp=true
   local nxt=function() unload(e,tr) end
   move(e,-10,0,10,nxt)  
  end
		move(tr,-52,0,64,f)  
 end  

end






function gameover()
	sfx(15,3,0,9)
 gmo=true
 hero.cdie=128
end

function smooth(e)
 e.twcv=function(c) return .5-cos(c*.5)*.5 end
end

function wt(n,f)
 local e=mke()
 e.nxt=f
 e.life=n
end

function turn(e)
 e.flp = not e.flp
end

function curv(e,n)
 
 e.twcv=function(c) return c^n end
end

function gtr(id)
 for tr in all(trucks) do
  if tr.id==id then 
   return tr
  end
 end
 return nil
end



function truck_leave(e,tr)
 local f=function ()
  kl(tr)
  del(trucks,tr)
 end 
 local go=function()
  kl(e)
  sfx(14,1)
  move(tr,-64*tr.sns,0,60,f)
 end
 turn(e)
 move(e,-10*tr.sns,0,10,go)
  
end
function load_truck(e,tr)
 if #tr.stock==0 or gmo then
  truck_leave(e,tr)
  return
 end
 
 local a={}
 local n=5*(tr.id-1)
 for x=8,10 do for y=5+n,8+n do
  cl=gtopcr(x,y)
  for n in all(tr.stock) do
   if cl and n==cl.tp then
    add(a,cl)
    break
   end
  end 
 end end
 
 local again=function()
  load_truck(e,tr)
 end
 e.waiting=#a==0
 if e.waiting or not playin() then
  wt(40,again)
  return
 end

 local cr=steal(a)
 
 local reg=function()
  kl(cr)
  del(tr.stock,cr.tp)
  pool+=1
  turn(e)
  wt(20,again)
  sfx(19,0,0,3)
 end
  
 local launch=function()
   sfx(19,0,3,2)
   move(cr,-16,0,-2,reg)
   cr.ez=-12
   cr.jmp=8
   
 end
 
 local bring_bk=function()
   turn(e)
   moveto(e,64,cr.y,-.5,launch)
   moveto(cr,64,cr.y,-.5)
   cr.ez=-8 
 end
 
 local lift=function()
  
  move(cr,0,0,12,bring_bk)
  cr.ez=-8
 end
 cdel(cr)
 moveto(e,cr.x,cr.y,-.5,lift)

end


function unload(e,tr)
 if #tr.stock==0 or gmo then
  truck_leave(e,tr)
  return
 end

 a={}
 for x=xmax-10,xmax-9 do for y=8,11 do
   if not gcr(x,y,0) then
    add(a,{x=x,y=y})
   end 
 end end
 
 local again=function() 
  unload(e,tr) 
 end
 
 if #a==0 then
  e.cred=8
  sfx(13,0,4,3)
  wt(40,again)
  return
 end
 
 turn(e)
 local p=steal(a)
 
 
 local launch=function ()

  local c=mkc(pop(tr.stock))
  c.x=e.x-tr.sns*8
  c.y=e.y
  c.z=-8
  
  
  --- move
  local land=function()
   pool-=1
   cins(c,p.x,p.y)
   cpos(c)
   wt(12,again)
  end
  sfx(13,0,10,2)
  moveto(c,p.x*8,p.y*8,8,land)
  c.ez=0
  c.jmp=8
  wt(6,function() turn(e) end )
 end 
 local seek=function()
  move(e,-8*tr.sns,-4,20,launch)
  e.twcv=function(c) return -sin(c*.5) end 
 end
 
 moveto(e,e.x,p.y*8-4,-2,seek)

end



function steal(a)
 local n=a[1+rand(#a)]
 del(a,n)
 return n
end

-- hero
function upd_hero(e)
 if not playin() or not e.vis then
  return 
 end 
 
 hcr=nil
 running=false
 if btn(0) then hmov(2,-1,0) end
 if btn(1) then hmov(0,1,0) end
 if btn(2) then hmov(3,0,-1) end
 if btn(3) then hmov(1,0,1) end

 e.px=flr(e.x/8)
 e.py=flr(e.y/8)

 if running and #hands>0 then
  local loss=en_loss*(1+#hands)
  if hv(1) then
   loss/=2
  end
  energy=max(energy-loss,0)
 end
 
 
 if #hands==0 then
  if hcr then
   if btnp(4) then
    grab(hcr)
   elseif btnp(5) then
    grab_all(hcr)
   end
  end
 else
  if btnp(4) then
   drop(false)
  elseif btnp(5) then
   drop(true)
  end
 end
  
 -- recal
 while ecol(hero) and #htail>0 do
  local p=pop(htail)
  hero.x=p.x
  hero.y=p.y
 end
 
 -- tail
 if running then
  add(htail,{x=e.x,y=e.y})
  if #htail>100 then
   del(htail,htail[1])
  end 
 end 
  
 -- crates
 local z=-8
 for c in all(hands) do
  if not c.twc then
   c.x=e.x
   c.y=e.y
   c.z=e.z+z
  end
  z-=4
  if c.rat and running then
   c.rat.res-=1
  end
  
 end

 -- gfx
 e.fr=e.di+1
 if #hands>0 then
  e.fr+=32
 end 
 e.z=0
 if running  then  
  if t%8==0 then 
   sfx(10,3,hrn*2,2)
   hrn=(hrn+1)%2
  end 
  if t%8<4 then
   e.fr+=16 
   e.z=-1
 	end
 end
 

 
 
 -- trg
 
 local fx=e.x/8
 local fy=e.y/8--+.25
 if e.di==0 then fx+=.25 end
 if e.di==1 then fy+=.25 end
 tpx=flr(fx+.5)+ddr[e.di*2+1]
 tpy=flr(fy+.5)+ddr[e.di*2+2]
 tpz=getz(tpx,tpy)

 trg.x=tpx*8
 trg.y=tpy*8 
 trg.z=-tpz*4
 trg.vis=hcr==nil and #hands>0 and is_in(tpx,tpy)
 trg.valid=is_drop_free(tpx,tpy)

 --stuff
 if not hcr or btn(4) or btn(5) then
  e.chint=16
 end

end



function fade_out()
 hero.cfad=16
 
end


function pop(a)
 local n=a[#a]
 del(a,n)
 return n
end

function wrong()
 hero.cwr=12
 sfx(13,0,0,4)
end

function grab(c)

 if #hands>strength then
  wrong()
  hero.cred=8
  return
 end
 
 hcr=nil
 sfx(11)
 
	local cr= gtopcr(c.px,c.py)
	grb(cr)
 
 
end

function grb(cr)
 frz=true
 cdel(cr)  
 add(hands,cr) 
 cr.handed=true  
 moveto(cr,hero.x,hero.y,4,unfreeze)
 cr.ez=-4-#hands*4
 on_move(cr)
end

function grab_all(c)

 if energy<.5 then
  wrong()
  hero.ctir=20
  return  
 end

 sfx(11)
 
 
 -- get pile
 local a={}
 for n=0,8 do
  cr=gcr(c.px,c.py,n)
  if cr then 
   add(a,cr)
  else
      break
  end
 end
 
 -- test strength
 while #a>strength+1 do
  del(a,a[1])
 end
 -- grab
 for cr in all(a) do  
  grb(cr) 
 end

end

function gzmax()
 return strength+whz
end

function drop(al)
 
 if not trg.vis or not trg.valid then
  return
 end

 sfx(12)
 
 local z=getz(tpx,tpy)
 local a={}
 for cr in all(hands) do
  add(a,cr)
 end 

 local dm = al and gzmax()+1-z or 1
 while #a>dm do
  del(a,a[1])
 end
  

 for cr in all(a) do
  
  cins(cr,tpx,tpy,z) 
  moveto(cr,tpx*8,tpy*8,6)
  cr.ez=-z*4
  cr.jmp=4
  del(hands,cr) 
  cr.handed=nil
  z+=1 
		on_move(cr)    
 end
 
end

function on_move(cr)
 if cr.rat then
  cr.rat.res-=10
 end

end


function getz(px,py)
 zmax=8
 local pz=8
 for z=0,8 do
  if gcr(px,py,pz) then
   return pz+1
  end
  pz-=1
 end 
 return 0
end

function is_in(px,py)
 return px>=zgx and py>=zgy and px<zgx+zxm and py<zgy+zym
end

function hmov(di,dx,dy)
 running=true
 spd=2
 if energy<.25 then 
  spd=1 
 end
 for it in all(hands) do
  if it.tp==6 then
   spd*=.5
  end
 end
 
 
 hero.di=di
 hero.x+=dx*spd
 while ecol(hero) do
  hero.x-=sgn(dx)
  running=false
 end 
 
 hero.y+=dy*spd
 while ecol(hero) do
  hero.y-=sgn(dy)
  running=false
 end 
 
end
-- ents
function mke(fr,x,y)
 local e={
  fr=fr or 0,x=x or 0,y=y or 0,z=0,
  t=0,szx=8,szy=8,dp=0,
  flp=false,vis=true,
 }
 add(ents,e)
 return e
end



function dre(e)
 if not e.vis or depth!=e.dp then
  return
 end
 local fr=e.fr
 local x=e.x
 local y=e.y
 local z=e.z



 if hcr==e then
  z-=1
 end
 
 if fget(fr,3) and e.t%4==0 then
  fr+=1
  e.fr=fr
  if fget(fr,0) then
   kl(e)
   return
  elseif fget(fr,1) then
   fr-=2
   e.fr=fr
  end
 end
 
 function dr(x,y)
  if fr>0 then
   spr(fr,x,y+z,e.szx/8,e.szy/8,e.flp)
  end 
  if e.dr then e.dr(e,x,y,z) end
 end

 
 if e.cred and t%4<2 then
  apal(8)
 end 
 if e.unpink then
 
  for y=1,3 do
   pal(sget(0,y),sget(e.unpink,y))
  end
 end
 dr(x,y)
 rpal() 
end

function rpal()
 for i=0,15 do pal(i,i,0) end
end

function apal(n)
 for i=0,15 do pal(i,n,0) end
end

function kl(e)
 del(ents,e)
 if e.rat then kl(e.rat) end 
 if e.nxt then e.nxt() end
end

function init_phys(e)
 e.vx=0
 e.vy=0
 e.vz=0
 e.frict=1
 e.we=0
end

function upe(e)
 e.t+=1
 if e.tp then crates+=1 end
 if e.upd then e.upd(e) end
 if e.vx then
  e.x+=e.vx
  e.y+=e.vy
  e.z+=e.vz
  e.vx*=e.frict
  e.vy*=e.frict
  e.vz*=e.frict
  e.vz+=e.we  
 end

 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   e[v]= n>0 and n or nil
  end
 end 

 -- life
 if e.life then
  e.life-=1
  if e.life<=0 then kl(e) end
 end 

 --  tweens
 if e.twc then
  local c=min(e.twc+1/e.tws,1)
  cc=e.twcv and e.twcv(c) or c
  e.x=e.sx+(e.ex-e.sx)*cc
  e.y=e.sy+(e.ey-e.sy)*cc
  e.z=e.sz+(e.ez-e.sz)*cc
  if e.jmp then
   e.y+=sin(c/2)*e.jmp
  end  
  e.twc=c  
  if c==1 then
   e.twc=nil
   e.jmp=nil
   e.twcv=nil
   f=e.twf
   if f then
    e.twf=nil
    f()
   end
  end
 end 
end

function move(e,dx,dy,n,f)
 moveto(e,e.x+dx,e.y+dy,n,f)
end

function moveto(e,tx,ty,n,f)
 e.sx=e.x
 e.sy=e.y
 e.sz=e.z
 e.ex=tx
 e.ey=ty
 e.ez=e.z
 e.twc=0
 e.tws=n
 e.twf=f 
 
 
 if n<0 then
  dx=e.ex-e.sx
  dy=e.ey-e.sy
  e.tws=-sqrt(dx^2+dy^2)/n
 end
 
 if e.inv then
  e.flp=e.sx<e.ex
 end
 
 
end

function ecol(e)
 local x=flr(e.x/8)
 local y=flr(e.y/8)
 a={0,0,1,0,1,1,0,1}
 for i=0,3 do
  local x=e.x+a[i*2+1]*(e.szx-1)
  local y=e.y+a[i*2+2]*(e.szy-1)
  if pcol(x,y,e) then 
   return true 
  end
 end
 return false
end

function smk(x,y)
 local e=mke(161,x,y)
 init_phys(e)
 return e
end

function pcol(x,y,e)
 local px=flr(x/8)
 local py=flr(y/8)
 
 if py>=16 then
  return false
 end
 
 local tl=mget(px,py)
 if not fget(tl,0) then
  return true
 end
 
 if e==hero and #hands>0 and fget(tl,2) then
  return true
 end
 
 local cr=gtopcr(px,py,0)
 if cr then
  if #hands==0 and e==hero then 
   hcr=cr
  end
  return true
 end 
 
 
 return false
end
 
--tools
function rand(n)
 return flr(rnd(n))
end

function _update()
 t=t+1
 n=0
 if bed and bed.full then
  n=3
 end
 for i=0,n do loop() end
end

function upd_game()
 
 crates=0
	foreach(ents,upe)
	
	if gmo and btnp(4) then
	 init_menu()
	end
	
	if playin() then
 	timer+=1
 	if timer>tempo then 
 	 next_hour()
 	end	
 	coef=(hour+timer/tempo)/24
 	if tax_coef and coef>tax_coef then
 	 gen_tax() 
 	 sfx(17,0,4,4)
 	elseif not mail and coef>offer_coef then
 	 gen_offer()
 	 sfx(17,0,4,4)
 	end
 	
	end
 ysort(ents) 
end

function gen_tax()
 tax_coef=nil
 mail={pr=6+(day^2),id=0}
 
end

function gen_offer()

 offer_coef+= 0.2+rnd(.25)
 mail={pr=0,id=0}
 
 local a={}
 for i=1,#item_prices do
  add(a,i)
 end
 for it in all(inv) do
  if it!=4 then del(a,it) end
 end
 mail.id=steal(a)

 local pr=item_prices[mail.id]
 if mail.id==4 then
  pr+=whs*15
 end
 mail.pr=flr(pr*.8+rnd(.7)) 
 mail.seed=rand(1000)
 if test_item then
  mail.id=test_item
  mail.pr=8
 end
 
 
end


function playin()
 return not gmo and not frz
end


function ysort(a)
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1].y-a[j-1].z/100 > a[j].y-a[j].z/100 do
   a[j],a[j-1] = a[j-1],a[j]
   j = j - 1
  end
 end
end

function mod(n,k)
 return flr((t%(n*k))/k)
end

function maj_map()

 
 n=13
 -- ext
 for x=0,whs-1 do for y=0,ymax do
  local tl=mget(x+11,y+ymax+1)
  mset(n+x,y,tl)  
 end end
 
 n+=whs
 -- arrival
 for x=0,13 do for y=0,ymax do
  local tl=mget(x,y+ymax+1)
  mset(n+x,y,tl)  
 end end 
 zxm=9+whs
 xmax=24+whs
 
 -- desk
 desk.x=(xmax-10)*8-9
 desk.y=30
 
 phone.x=desk.x+2
 phone.y=desk.y
 phone.z=-3
 
 comp.x=desk.x+13
 comp.y=desk.y
 comp.z=-4

 clock.x=128+whs*8
 clock.y=18
 
 bed.x=desk.x+8
 bed.y=110

end


function drs(e)
 if not e.tp then
  return
 end
 local x=e.x+1-e.z/4
 local y=e.y+1-e.z/4
 rectfill(x,y,x+7,y+7,1)
end


function is_drop_free(x,y,chk_arr,chk_dep)
 
 if not is_in(x,y) then
  return false
 end
 
 tl=mget(x,y)
 if not fget(tl,0) then
  return false
 end
 if fget(tl,1) then
  if chk_dep and x<=10 then
   return false
  end
  if chk_arr and x>10 then
   return false
  end  
 end
 if gcr(x,y,gzmax()) then
  return false
 end
 
 
 return true
end

function beep()
 sfx(13,0,12,1)
end

function dark(c) 
 for i=0,15 do
  pal(i,sget(24+i,88+flr(c*6)),1)
 end
end

function gdat()
 mn=flr((timer/tempo)*60)..""
 while #mn<2 do mn ="0"..mn end
 return (hour%12)..":"..mn.." "..(hour<12 and "am" or "pm")
end

function open_shedule()
 
 sfx(15,0,16,3)
 
 -- inventory
 tot={}
 total=0
 for i=1,10 do tot[i]=0 end
 
 for e in all(ents) do
  if e.tp then 
   tot[1+e.tp]+=1  
   total+=1
  end
 end
 
 --
 local a={}
 for i=0,2 do  
  local o={ tp=0, a={} }
  add(a,o)
  o.tp=rand(2)
  if total<10 and i==0 then
  	o.tp=0
  end
  if total>30+5*whs and i==2 then
  	o.tp=1
  end
  
  
  local nc={1,2,2,2,3,3,3,3}  
  local al=get_cats(steal(nc),o.tp)
  k=4+rand(3)
  if o.tp==0 then 
   -- xtra for arrival
   k+=2    
  else
   -- seek empty crate  
   for ii=0,9 do
    if tot[ii+1]>=k and rand(4)==0 then
     tot[ii+1]=0
     if rand(2)==0 then
      al={ii}   
     end  
    end
   end    		
  end
  
  for n=1,k do
   add(o.a,arand(al))
  end  
  o.pr=0
  local prices = o.tp==0 and buy_prices or sell_prices
  for n in all(o.a) do
   o.pr+=prices[1+n]
  end 
  if o.tp==1 then
   o.pr+=max(k-4,0)
  end

 
  
 end
 
 add(a,{tp=2})
 
 -- shedule
 local ww=96
 local hh=120
 local sel=0
 shed=mke()
 shed.dp=10
 shed.dr=function(e,x,y)
  err=nil
  rectfill(x,y,x+ww,y+hh,7)
  srand(32)
  for i=0,14 do
   spr(165+rand(2),x-8,y+i*8)
  end
  line(x+10,y,x+10,y+120,15)
  
  py=y+4
  print(gdat().." delivery",x+22,py,15)
  py+=11
  print("choose a contract",x+20,py,14)
	 py+=16
  
  local nm=0
  for sh in all(a) do
   
   -- box
   tit={"buy","sell","exit"}
   local cl=3
   if sh.tp==1 then cl=8 end
   print(tit[1+sh.tp],x+14,py,cl)
   
   -- price
   if sh.pr then
   	str=""..(-sh.pr)
   	if sh.pr<0 then str="+"..str end
   	while #str<13 do str="."..str end
  	 print(str,x+32,py,13)   	   
  	 spr(138,x+32+#str*4,py-1)
   end
    
   -- selection
   local al=sh.a
   if sel==nm then    
    
    if no_money then err="not enough money" end
    if full then err="no free dock left" end
    if err and t%32<16 then
     print(err,x+16,py+10,8)
     al={}
    end
    spr(err and 96 or 112,x,py-1)
   
   end
  
   -- list
   py+=7
   list= get_list(al)
   px=x+26
   for g in all(list) do    
    spr(80,px,py+4)
    spr(64+g.id,px,py)
    print( g.n.."x ",px-8,py+3,9)
    px+=20
   end

   nm+=1   
   py+=20
  end

  
  
 end
 
 --
 shed.upd=function()
  local sh=a[1+sel]
  function mvc(n)
   sel+=n
   sel=sel%4
   beep()   
  end 
  if btnp(2) then mvc(-1) end
  if btnp(3) then mvc(1) end
  if btnp(4) and shed.t>20 then
   if err then
    wrong()
   else
    shed.upd=nil
    move(shed,0,128,10,unfreeze)
    curv(shed,2)
    sfx(15,0,19,3)
    if sh.tp<2 then
     
     function f()      
      mk_truck(sh.tp,sh.a)
     end
     wt(20,function() inc_gold(-sh.pr) end)
     wt(60,f)
    end
   end
  end

  no_money = sh.pr and gold-sh.pr<0
  full= false  
  if sh.tp==0 then
   full=gtr(0)
  elseif sh.tp==1 then
   full=gtr(1) and gtr(2)
  end  
  
 end
 
 -- positon
 shed.y=128
 shed.x=18
 move(shed,0,-120,10)

end


function inc_gold(n)
 sfx(13,0,13,1)
 gold+=sgn(n)
 n-=sgn(n)
 if n!=0 then
  wt(4,function() inc_gold(n) end)
 end
 
end

function unfreeze()
 del(ents,shed)
 frz=false
end

function get_cats(n,tp)

 local a={}
 for i=1,min(3+day+rand(2),9) do 
  add(a,i)
 end 
 
 local res={}
 for i=1,n do  
  
   local c=rnd()^2
   local r=a[1+flr(c*#a)]

   del(a,r) 
   add(res,r) 
   --for g=0,11-i do
    add(res,r)
   --end
 end  
 return res
end

function dr_game()
 if hero.cfad then
  dark( 1-hero.cfad/16 )
 end
 rectfill(0,0,127,127,11)
 -- camera
 cx=xmax*4+4
 cy=ymax*4+4
 dx=hero.x+4-cx
 dy=hero.y+4-cy 
 cx+=dx/2-64
 cy+=dy/3-64
 camera(cx,cy)
 
 
 --warehouse
 n=12+whs+11
 map(0,0,0,0,n,ymax+1)
 spr(58,xmax*8-70,77)
 spr(59,70,53)
 spr(60,70,93)
 

 
 
 --map(0,0,0,0,n,20)
 --map(21,0,n*8,0,n,20)
 
 --
 
 -- shades 
 foreach(ents,drs)
 fillp()
 
 -- ents 
 draw_ents(0)
 draw_ents(1)


 -- hints
 if hcr and not hero.chint then
 	k=names[1+hcr.tp]
 	print(k,hcr.x+4-#k*2,hcr.y+hcr.z-12,7)
 end 

 -- inter
 camera(0,0)
 draw_ents(10)
 draw_ents(11)
 
 -- game over
 if gmo then
  for i=0,3 do
   rt=t+i*2
   x=46
   y=61
   if hero.cdie then
    x+=cos(rt/64)*hero.cdie/2
    y+=sin(rt/77)*hero.cdie/2
     if hero.cdie==1 then
      sfx(15,2,9,0)
     end
   else
    rectfill(0,59,127,67,8)
   end

   print("game over",x,y,sget(i,0))
  end
 end
 
end

function _draw()
 cls()
 mdraw()
 
 
 -- log
 camera(0,0)
 cursor(0,0)
 color(8)
 for l in all(logs) do
  print(l)
 end

end

function draw_ents(dp)
 depth=dp
 foreach(ents,dre)
end


function log(str)
 add(logs,str)
 while #logs>20 do
  del(logs,logs[1])
 end
 
end

names={
 "crate",
 "waste",
 "sugar",
 "salad",
 "apple",
 "fish",
 "brick",
 "cacao",
 "meat",
 "wine",
 "???",
 "???",
 "???",
}

item_nm={
 "pallet jack",
 "freight elevator",
 "ladder",
 "extension",
 "cat",
 "teddy bear",
 "???",
 "???",
 "???",
 "???",
}

desc_nm={
 "  -50% tiredness speed   ",
 "                         ",
 
 "       +2 strength					  ",
 "     															     ",
 
 "     +1 column size      ",
 "   															       ",
 
 "  extend your warehouse  ",
 "   ( very fast work )    ",
 
 "    chase the mouses     ",
 "    may eat fishes       ",
 
 "     +100% recovery      ",
 " guardian of your sleep  " 
}

great_nm={
 "incredible",
 "unbelievable",
 "amazing",
 "marvelous",
 "kick-ass",
 "deadly",
 "efficient",
 "surprising",
 "state of the art",
 "super cheap",
 "black friday"
}
__gfx__
28e776d100bbb77000bbb7000bbb770000bbb700666d1e6688888888eeeeeeee4442444244424442555555555555555555555555555511111111555511111111
85d4d25900333bbb00333b00333bbb000033bb000000000088888888822282224442444244424442599959995999599959995995555511111111555511111111
e4c96d6a002949400249942004949800002288000000000088288888eeeeeeee4442444244424442599959995999599959995995555511111111555511111111
f96a7e7702299ff00299ff200999f280022228200000000088288888888888884442222244424442599555555555555555555555555511111111555511111111
00110000023333000233332000333b20022222200000000082222228888888884442444244424442555555555555555555555995555511111111555511111111
21d600000933bb3f0933bbf09333bb90092222900000000088888288888888884442444244424442599555555555555555555995555511111111555511111111
249300000033bb000033bb000033bb000033bb000000000088888888888888884442444244424442599555555555555555555995555511111111555511111111
d2de0000001001000010010000100100001001000000000088888888888888884442444244424442599555555555555555555555555511111111555511111111
00ccc77000bbb77000bbb7000bbb770000bbbb008888888888888888888888884442444244422222555555555555555555555995555555555555111111115555
00dddccc00333bbb02333b20333bbb0000333b008888222222228888888888884442444244424442599555555555555555555995555555555555111111115555
004e4e40222949400249942004949288022288808888828888288888888888884442444244424442599555555555555555555995555555555555111111115555
004eeff002299ff00299ff200999f220022222208888828888288888888888884442444244424442599555555555555555555555555555555555111111115555
00dddd009333333f933333bf93333bbf9322223f8222222222222228888888884442444244424442555555555555555555555995555555555555111111115555
09ddccdf0033bb000033bb000033bb00003333008882888828888288888888884442444222224442599555555555555555555995555555555555111111115555
00ddcc000133bb100133bb100133bb100133bb108882888828888288888888884442444244424442599555555555555555555995566666655666555115556665
00100100000000000000000000000000000000008822222222222288888888882222444244424442599555555555555555555555566666655666555115556665
0ccc7700009bb77009bbbbf00bbbb9000933333f0000000022212221222122211111111111111111555555555555555555555995bbbbbbbbbbbb33333333bbbb
dddccc0000333bbb03333330333bb3000333333b0000000022212221222122212221222122212221599555555555555555555995bbbbbbbbbbbb33333333bbbb
04e4e4000039494003499430049493000322222b0000000022212221222122212221222122212221599555555555555555555995bbbbbbbbbbbb33333333bbbb
0eeefe0002399ff00399ff300999f3800322288b0000000022211111222122211111111111111111599555555555555555555555bbbbbbbbbbbb33333333bbbb
00dddd00023333000233332000333320002228800000000022212221222122211111111111222111555555555555555555555995bbbbbbbbbbbb33333333bbbb
edccddf00033bb000033bb000033bb00002228000000000022212221222122211111111111222111599599959995999599959995bbbbbbbbbbbb33333333bbbb
00ccdd000033bb000033bb000033bb000033bb000000000022212221222122213333333333222333599599959995999599959995bbbbbbbbbbbb33333333bbbb
00100100001001000010010000100100001001000000000022212221222122213333333333333333555555555555555555555555bbbbbbbbbbbb33333333bbbb
00000000009bb77009bbbbf00bbbb9000933333f00000000009ff000000000004444444400000000559999555999995555999955bbbbbbbbbbbbbbbb33333333
0000000000333bbb03333330333bb3000333333b00000000077fff00000000009999999900000000599559955995599559955995bbbbbbbbbbb77bbb33333333
000000008239494003499430049493880322222b00000000977fff90000000002222222200000000599559955995599559955555bbbbbbbbbbb77bbb33333333
0000000002399ff00399ff30099ff3200322288b00000000fffff990000000002222222200000000599999955999995559955555bbbb3bbbb779977b33333333
000000000033330000333300003333000032288000000000f11f1190000000004444444400000000599559955995599559955555b3b3bbbbb7799773bbbbbbbb
000000000033bb000033bb000033bb00003228800000000091191190000000009999999900000000599559955995599559955995bb3bbbbbbb377333bbbbbbbb
000000000133bb100133bb100133bb100133bb100000000009999900000000002222222200000000599559955999995555999955bbbbbbbbbbb773bbbbbbbbbb
00000000000000000000000000000000000000000000000009090900000000002222222200000000555555555555555555555555bbbbbbbbbbbb33bbbbbbbbbb
aaaaaaa9a6aaa339aaa66aa9aaaabb9aaaaaaba9aaaac1c9aaaaaaa9aaa545a9aa777aa9aa2aa2a9000000000000000000000000000000000000000000000000
a14444496dd43533a4677649bb33b319a4884889a11cccc9a4444449a4545459a788e719a1211219000000000000000000000000000000000000000000000000
a11222296ddd5b33a6777669b3133119b8832889a1ddcc19adddddd9a5454549a788e729ab33b339000000000000000000000000000000000000000000000000
a111111926d3b52da6776669911bb33988222229a11dd119ad666d69a4545459a78e87d9a7337339000000000000000000000000000000000000000000000000
a1111119226552dda6666669a33b31bba2222389ccc111d9adddddd9a5454559a2688789ab33b339000000000000000000000000000000000000000000000000
a1111119a2252559a6666669bb3311b3a28b2889c1dd1dc9ad6d66d9a5555559a8262789a3553559000000000000000000000000000000000000000000000000
a1111119ad525259a6666669b3133331a2882239cddd1cc9adddddd9a5555559a222dd29a3553559000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999000000000000000000000000000000000000000000000000
a1111119000000000ffff99999999999994999990ddd777707666670a679990011dddd1100000000000000000000000000000000000000000000000000000000
a111111901100110fff999ffffffffffff9ffff9dddd7cc77dddddd6aa6774001dddddd100000000000000000000000000000000000000000000000000000000
a111111918811881f9999ffffffffffffffffff9dddd7cc77dddddd6aaa66770dddddddd00000000000000000000000000000000000000000000000000000000
99999999128888219999fffffffffffffffffff9dddd7cc707666660aaad6660dddddddd00000000000000000000000000000000000000000000000000000000
4444444401888810999ffffffffffffffffffff9dddd7cc707776660aaad6660dddddddd00000000000000000000000000000000000000000000000000000000
949999491882288199fffffffffffffffffffff90ddd7777077b3660aaad6600dddddddd00000000000000000000000000000000000000000000000000000000
94444449122112219ffffffffffffffffffffff900111dd0007b36000aad60001dddddd100000000000000000000000000000000000000000000000000000000
9499994901100110999fffffffffffffff9f99400ddd66660077660000ad000011dddd1100000000000000000000000000000000000000000000000000000000
88000000000010009ffffffffffffffffffffff900000001010101610000000100000100111dd111111111111111111100000000000000000000000000000000
888800000001a1009ffffffffffffffffffffff901010016161610160000001600001d1011dddd11111dd1111111111100000000000000000000000000000000
888888000001aa109ffffffffffffffffffffff91616101da6a6111d0000001d000001d11dddddd111dddd11111dd11100000000000000000000000000000000
888888880001a1a19ffffffffffffffffffffff9a6a6111d1ddd66610000011d000001d1dddddddd1dddddd111dddd1100000000000000000000000000000000
888888110011a1109ffffffffffffffffffffff91ddd666111dd66611101166111011661dddddddd1dddddd111dddd1100000000000000000000000000000000
8888111001aaa1009fffffffffffffffffffff9401dd6661dd16111d16166661161666611dddddd111dddd11111dd11100000000000000000000000000000000
8811100001aa10009ffffffffffffffffffff94001d161d111010001a6a6d1d1a6a6d1d111dddd11111dd1111111111100000000000000000000000000000000
01100000001100004999fffffffffffffffffff901d1d1d100000000ddd1d1d1ddd1d1d1111dd111111111111111111100000000000000000000000000000000
33000000000000009ffffffffffffffffffffff90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33330000000000009ffffffffffffffffffffff90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333300000000009ffffffffffffffffffffff90000010000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333f000ff509ffffffffffffffffffffff91001121100000000000000000000000000000000000000000000000000000000000000000000000000000000
333333114090fff09fffff9ffffffffffffff9f94114121f00000000000000000000000000000000000000000000000000000000000000000000000000000000
333311104442fff49ffff9ffffffffffffff90f94818484100000000000000000000000000000000000000000000000000000000000000000000000000000000
33111000444444409fff49ffffff9ffffff990994488144100000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000244444449994999999994999999900001822f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0101000000000000fffffffffffffff006777760000000000aaa00080000a07000ddd000aaa0000000000000000000000000000000000000
eeeeeeeeeeeeeeee1f1f111000000000f4f949f94449f4f20777777004444440a999a097f0aa70000daaad00a290000000000000000000000000000000000000
eeeeeeeeeeeeeeee1441444100100000fff4f4f4f4f4fff20dccccd049ffff94a9aaaa777e99a007da999ad09990000000000000000000000000000000000000
eeeeeeeeeeeeeeee1444444411f10000fff444f4ff49fff20dccccd04f9ff9f4a9aaa0b7d099a000da9aaad04440000000000000000000000000000000000000
eeeeeeeeeeeeeeee1f142244ff100000fffffffffffffff20dccccd04ff99ff40aaa000c0000a070da9aaad04440000000000000000000000000000000000000
eeeeeeeeeeeeeeee0101000000000000fff444f449f9fff1067676704ffffff4b303b008000000000daaad000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0111111000000000fff4f4f4f4f4fff20767676004444440bb333088f09f000000ddd0000000000000000000000000000000000000000000
ffffffffeeeeeeee1f4f444101100000f4f494fff4f4f4f20dddddd0000000000330000f90900000000000000000000000000000000000000000000000000000
8888888808888888144444441ff10000fffffffffffffff209999999999999999999999000000000000000000000000000000000000000000000000000000000
88888888d8888888f4424424f1100000022222222222222209999999999999999999999007777770000000000000000000000000000000000000000000000000
88888888c38888880101000000000000000000000000000009999999999999999999999078eeee87000000000000000000000000000000000000000000000000
88888888b32222220f1f11100000000000000000000000000999999999999999999999907e8ee8e7000000000000000000000000000000000000000000000000
88888888484922cc144144410000000000000000100000000999999999999999999999907ee88ee7000000000000000000000000000000000000000000000000
88888888899922dd14444444f111000000000000f10000000444444444444444444444407eeeeee7000000000000000000000000000000000000000000000000
88888888333322dd1f1242441ff10000000000001f00000001221111111111111111221007777770000000000000000000000000000000000000000000000000
88888888222228880000000000000000000000000000000001441111111111111111441000000000000000000000000000000000000000000000000000000000
88888888000d666000000d5000000000000000007777777777777777088888888777677000000000000000000000000000000000000000000000000000000000
888888880dd6666d0000d6d500000050000000007777777777777777088888888777677000000000000000000000000000000000000000000000000000000000
88888888d6dd66d55500dd5500000555000000007700077770000777088888888777677000000000000000000000000000000000000000000000000000000000
88888888666ddd55dd500555d50000505000000070000077000000770888888887776dd000000000000000000000000000000000000000000000000000000000
8888888866dd5550dd50555055000000000000007000007700000077088888888777666000000000000000000000000000000000000000000000000000000000
ddddddddddd5d6555555dd5500050000000000007000007700000077022222222666ddd000000000000000000000000000000000000000000000000000000000
dddddddd05556d550005dd5500000d50005000007700077770000777022222222666ddd000000000000000000000000000000000000000000000000000000000
dddddddd000555500000555000000550000000507777777777777777044444444444444000000000000000000000000000000000000000000000000000000000
1111111111111111111111110123456789abcdef0000000007dd1110000000000000000000000000000000000000000000000000000000000000000000000000
111111111111111111111111001121d62493d5de07dd1110dd100111000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111110000105d2241515ddd10011100100100000000000000003000000000000000000000000000000000000000000000000000000000
0110000001111110000000000000001511201015007d1100007d1100008888888770f43b00000000000000000000000000000000000000000000000000000000
011111111dddd11111111111000000010010000107d6611007d66110088888888773f93b00000000000000000000000000000000000000000000000000000000
00000000011111100000000000000000000000000d1661140d16611408888888877394bb00000000000000000000000000000000000000000000000000000000
0000000001111110000000000000000000000000004444440044444408888888877399b700000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000008888888877222b700000000000000000000000000000000000000000000000000000000
00000000088888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d888888888d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000dcc88888888cd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dccc222222222cd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000dccc8cdc2cccd22c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee8ddd8dddd2ddddd2880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeee888ddddd2ddddd2288000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88eeee22222228888822288800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
688e2222222222222222222800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d8822222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22622211112222222211112200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22d2216d11122222216d111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222d11111222222d11111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0022211dd1122222211dd11200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000011dd1100000011dd11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110000000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dd1000000d0009aa000000000000004400000000000000000000000000000000000000002220000444000000000000000000000000000000000
00000000000dd11100000010944a4a00000000000044000000000000000044400000000600000000000022244444424400000000000000000000000000000000
0000000000d111010000d010404a44a000000000049000000000000000444444000d006600000660000022444444422400000000000000000000000000000000
000000000010010100001010400a444a00000000454900440000000044444445000d06d60000600d000004454444444400000000000000000000000000000000
000000000010010100001110400a044a00000004900494400000004444444500000dd6660000d000000004444445444000000000000000000000000000000000
000000000011011000001110400a004a00000045490044000000444444450000006da66600000d000000044f5f44440000000000000000000000000000000000
000000000001111000001110400a000a00000490049440000044444445444000000dd666600000d0000002ff9ff4440000000000000000000000000000000000
000000000000010000001114400aaaaa000045490044000000ff4445444444400000ddd66600000d000000f99ff4420000000000000000000000000000000000
00000000000901000000111144aaaa9900049004944000000000994444444550000000566660000d0000002ff944200000000000000000000000000000000000
0009aa0000991100000010111499999900454900440000000000444444455000000000566d66000d000002222222220000000000000000000000000000000000
000049aa0099990000001111411199110490049440000000004444444550000000006666ddd6d0d0000042442222220000000000000000000000000000000000
9aa000499499111100001014111119164549004400000000444444455000000000066ddddd66d550000422444422222000000000000000000000000000000000
049aa00044911111dddd1114116610114004944000000000ff44455000000000007ddd55056dd500000224444422222200000000000000000000000000000000
00049aa0091d61110000011011661000000044000000000000fff000000000000007005005ddd0000ff44444fff2442200000000000000000000000000000000
0000049a9916611100000010011100000004400000000000000000000000000000000550555dd00009ff4442fff2442200000000000000000000000000000000
00000004990111000dddddd10000000000440000000000000000000000000000000005505ddd0000009ff422fff2222000000000000000000000000000000000
__gff__
0000000000000000010103030300000000000000000000000101030303000000000000000000000000000303030000000000000000000000070003030300000000000020200000000000000000000000000000000000000002000000000000000000000000000008080202020000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000808080801010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2d2d2d2d2d2d2d2d2d2d2d2d2d000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2d2d2d2d2d2d0707070707000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d3e2d2d2d2d2d2d1717151617000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d3d2d2d2d2d3e2d1706171706000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2d3d2d2d2d2d0809080908000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2d2d2d2d2d2e0b0b0c1918000000000000000000000000000000000000000f6b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b0d1b1b1c0908000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1e1b1b1c1918000000000000000000000000000000000000000f0f6b0f0f6b0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b0d2b2b2c0908000000000000000000000000000000000000006b6b0f0f6a6969690f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b0d1819181918000000000000000000000000000000000000006b6b6b696a58585869690f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d2d2d3d2d3d2d2e0b0b0c1918000000000000000000000000000000000000006b6b0f6a695858586b6a6a0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b0d1b1b1c0908000000000000000000000000000000000000006b6a6a6b6969696a6a6a0f0f0f0f0f6b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1e1b1b1c1918000000000000000000000000000000000000006a6a6a6b6b6b6a6a6a0f6b0f0f6b6b6b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b0d2b2b2c09080000000000000000000000000000000000000069696a6a6a6a69696b6a6a0f0f6b6b0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b0d181918191800000000000000000000000000000000000000696958586b58585869586a6b6b6b6b6b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d3d2d2d3e2d2e2829283838000000000000000000000000000000000000006b6958585858585858696969696a0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d81818181818181818181818100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070707072d2d2d2d2d2d2d070707070707070707070781818181818181818181818100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
151617172d2d2d2d2d2d2d171717171717061516171780808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
171717172d2d2d2d2d2d2d061717150617171717171790909090909090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
272627092d2d2d2d2d2d2d090809080908090809080990909090909090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181918192f2d2d2d2d2d2d191819181918191819181990909090909090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080908092f2d2d2d2d2d2d0908090809080908090809a0a0a0a0a0a0a0a0a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181918192f3e2d3d2d2d2d1918191819181918191819b0b1b2b1b0b1b2b1b1b1b0b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080a0b0b2f2d2d2d2d2d2d090809080908090808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181a1b1b0e1b1b1b1b1b1b191819181918191808080852535353535354000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181a1b1b1f1d1d1d1d1d1d191819181918191808080862636363636364000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
082a2b2b0e1b1b1b1b1b1b090809080908090808080872737373737374000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181918190e1b1b1b1b1b1b1918191819181918191819c3c3c3c3c3c3c3c3c3c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080908092f2d2d2d2d3e2d0908090809080908090809d3d3d3d3d3d3d3d3d3d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
182627192f3d2d3d2d2d2d191819181918191819181900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
282829282f2d2d2d2d2d2d282829282828292828292800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0101000000000000000000000000000000000000000000000000000000010500a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000011625000001862500000000000000000000000001d4150000024415000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000243522b3252b3150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002b35224325243150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000023700231502350021151a5710e251021211f47537451374251f6541f615300553732500000000003562435615131250c125091250000000000000000000000000000000000000000000000000000000
01080000186251f615186451f625186651f635186751f655186651f655186751f665186551f665186551f665186451f655186551f645186351f615186251f635186151f614186341f625186141f615186141f615
011000001f47018260114551f44018220114151f42018210114152b0522b0322b022370113701137015000001d61424525240151d614240252451537355000002b555285351852524552245352b5552852500000
010800002434524375243552433524355243752435524335240002400024000240002400024000240002400000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000130531165011620116102405518165243352b5351f24537221290343501137664246352b3530000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f1752317524165211551f035230252401521015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000046651103311615130522b051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000021355003052430524355213051d35521355213051f3551f3151f3050030026355243552635518300293552d3052d305283552b3052635524355263052435524315243052635526315003000000000000
012000001c5551a5451c535155251c5351a5251c545155351c5551a5451c535155251c5351a5251c545155351a545185551a545135351a525185151a535135551a545185551a545135351a525185151a53513555
0110000021555215522155221555215522153221522215122355524555265522655226552265522655226552285522855526552265552855228555265522655523552215521f5521f5421f5321f5221f5221f512
01100000185551754518535115251854517555185651155518575175551853511525185151752518535115451a555185451a535135451a535185451a555135651c5751d5551c5351d5251c5351a5251853517545
0110000011550115501155011550115521155211552115521c5501c5501c5501c5501c5521c5521c5521c5521f5501f5501f5501f5501f5521f5521f5521f5522155523555215551f5552155523555215551f555
012000002105021012000002405023050000001c0501f0001a0501a0101a0121a0001f0301f0101f0121f002210502101200000240501c0501c0001d0501d0121f0501f0201f0121f01217000170001700200000
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
01 15 42 43 44
03 15 19 43 44
00 15 16 43 44
00 17 18 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
