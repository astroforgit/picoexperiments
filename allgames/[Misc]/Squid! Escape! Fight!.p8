pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--					squid! escape! fight!
--		 							by @gnomael
function _init()
 cartdata("squid")
 poke(0x5f2e,1)--set perma pal
	
	--global players
	ticks,_mapw,_maph,
	ink,inkmax,inkd,inkr,inkcharge,
	inkbarperc,inkbarcor=
		0,128,128,
		0,100,20,0,30,
		0,nil

	lvl,lvlt,bestlvl,bestlvl_,
			totalt,fed,totalfed,
			menulvl,
			score,lives,--,todo: best
			hiscore,hiscores,hiscores_og,
			_bonusspd,_bonusi,_bonus
		=0,0,dget(0),dget(0),
			0,0,0,
			0,-- >0= easy mode
			0,1,
			dget(1),{},{},--hiscores
			0,0--,nil bonuses	
	for i=1,6 do hiscores[i]=dget(i)end
	update_hiscores()
	--global control vars
	_winperc,_camx,_camy,_fading=0,0,0,nil

 sqd=m_squid()
 sqd:upd()
	music(0)
	_upd,_drw=upd_intro,drw_intro
--	_upd,_drw=upd_end,drw_end
 --_upd,_drw=upd_play,drw_play next_lvl()
end
function _update60()
	ticks+=1
	_upd()
end
function _draw()
	_drw()
	runcors()
	palstr("5,14,15,140,142,143",1)
end
_coroutines={}
function runcors()
 for c in all(_coroutines) do
  if costatus(c) != 'dead' then
   coresume(c)
  else
   del(_coroutines,c)
  end 
 end
end
function update_hiscores(gameover)
 if(gameover)then
  hiscores={}
  for i=1,6 do
  	hiscores[i]=hiscores_og[i]
  end
 end
 if(score>hiscore)then
  hiscore=score
  dset(0,hiscore)
--	   ng_post_score(_scoreboard,score)
 end
 add(hiscores,score)
 sort(hiscores,function(a,b)
   return a<b
 end)
	for i=1,6 do
		dset(i,hiscores[i])
	end
end
-->8
--objs
_objs={}
function m_obj(x,y,r)
 s=
{
	x=x,y=y,
	r=r or 4,
	x0=x,y0=y,
	dx=0,dy=0,ax=0,ay=0,flipx,flipy,
	t=0,tst=flr(rnd(16)),prevtst=-1,
	st="idl",
	hit=nil,grab=nil,
	upd=u_obj,drw=d_obj,
	col=col,destroy=x_obj,
	chst=function(s,nst)--chst 2 nst
		if(nst==s.st)return--dont change bcuz is the same st
		s.pst,s.st,s.tst=s.st,nst,0
	end
}
 add(_objs,s) return s
end
function x_obj(s)
 del(_objs,s)
 return
end
function u_obj(s)
 s.t+=1
 s.tst=s.tst+1
 local frames,tst=25,s.tst
 if(sspeed)frames*=2
 s.anim2f0=((tst\frames/4)%1)
 s.anim2f1=tst\frames%2
 s.anim2f2=tst\(frames/2)%2
 s.anim2f3=tst\(frames/3)%2
-- s.anim2f4=tst\(frames/4)%2
-- s.anim3f0=tst\(frames*4)%3
 s.anim3f1=tst\frames%3
 s.anim3f2=tst\(frames/2)%3
 s.anim3f3=tst\(frames/3)%3
-- s.anim3f4=tst\(frames/4)%3
 s.anim3f5=tst\(frames/5)%3
-- s.anim4f1=tst\frames%4
-- s.anim4f2=tst\(frames/2)%4
 s.anim4f3=tst\(frames/3)%4
 s.anim4f4=tst\(frames/4)%4
-- s.anim6f1=s.tst\frames%6
-- s.anim6f2=s.tst\(frames/2)%6
-- s.anim6f3=s.tst\(frames/3)%6
-- s.anim8f1=s.tst\frames%8
-- s.anim8f2=s.tst\(frames/2)%8
-- s.anim8f3=s.tst\(frames/3)%8
-- s.anim12f1=s.tst/frames%10
-- s:out_of_bounds()
end
--function d_obj(s)--hitbox
--d_hitbox(s)
--end
--function d_hitbox(s)--hitbox
--	circfill(s.x,s.y,s.r,12)
--  rectfill(s.x-s.w/2,s.y-s.h/2,s.x+s.w/2-1,s.y+s.h/2-1,8)
--end

function dist(o1,o2)
 local dx,dy=abs(o1.x-o2.x),abs(o1.y-o2.y)
 return max(dx,dy)*0.9609+min(dx,dy)*0.3984
end
function sort(a,cmp)
	for i=1,#a do
  local j = i
  while j > 1 and cmp(a[j-1],a[j]) do
        a[j],a[j-1] = a[j-1],a[j]
   j -= 1
  end
 end
end
-----------------------------fxs
_fxs={}
function m_fx(x,y,dx,dy,life,c)
 s={x=x,y=y,dx=dx,dy=dy,
    life=life,c=c or {},ci=0,
    drw=function(s)
     u_fx(s)
--     circ(s.x,s.y,2.5,s.cnow)
    end,
    destroy=x_fx
   }
 add(_fxs,s) return s
end
function x_fx(s)
 del(_fxs,s)
end
function u_fx(s)
	if not sspeed or ticks%5==0then
		s.cnow,s.cnow2=s.c[ceil(s.ci)%#s.c+1],
		               s.c[ceil(s.ci+2)%#s.c+1]
		s.ci+=.125
		if(s.life<0)s:destroy()return
		s.x+=s.dx
		s.y+=s.dy
		s.life-=1
	end
end
--[[
_dusts={}
function m_dust(x,y,dx,dy,life,c)
	local s=m_fx(x,y,dx,dy,life,c)
	s.upd=function(s)
		u_fx(s)
			if(not sspeed or ticks%10==0)then
			 s.y+=(20-s.life)--grav
			end
 end
	s.drw,s.destroy=function(s)
		s:upd() pset(s.x,s.y,s.cnow)
	end,function(s)--destroy
		del(_dusts,s) x_fx(s)
	end
	add(_dusts,s) return s
end
--]]
_points={}
function m_points(x,y,txt,life)
 
 local s=m_fx(x,y,0,-.3,
         life or 45,
         (#txt>3)and {14} or {8})
s.txt=txt..""
 s.drw,s.destroy=function(s)
 	u_fx(s) 
 	printo(s.txt,s.x,s.y,
 	 (ticks%15>7) and s.cnow or 6,1)
 end,function(s)--destroy
 	del(_points,s) x_fx(s)
 end
 add(_points,s)return s
end
--[[_hearts={}
function m_heart(x,y,dx,dy,life)
	local s=m_fx(x,y,dx,dy,life,{8,12,8,7,8,7})
	s.drw,s.destroy=function(s)
		u_fx(s) printo("‡",s.x,s.y,s.cnow,cnoww)
	end,function(s)--destroy
		del(_hearts,s) x_fx(s)
	end
	add(_hearts,s) return s
end--]]--
bubbles={}
function m_bubble(x,y,dx,dy,
                   life,c,r,dr)
 s=m_fx(x,y,dx,dy,life,c)
 s.r=r or 1
 s.dr=dr or 0
 s.drw=function(s)
  u_fx(s)
  s.r+=s.dr
  if s.cnow==0 or s.cnow==1 
  or s.cnow==2 then
   circfill(s.x,s.y,s.r,s.cnow)
  else
  	circ(s.x,s.y,s.r,s.cnow)
  end
 end
 s.destroy=function(s)
  del(bubbles,s)
  x_fx(s)
 end
 add(bubbles,s) return s
end
----------------------fin de fxs

------biblioteca de display-----
function spro2(sp,x,y,a,b,h,v,out,pals)
	spro(sp,x,y,a,b,h,v,out)
	if(pals and pals!="")then
		palstr(pals)
	end
	spr(sp,x,y,a,b,h,v)
end
function spro(sp,x,y,a,b,h,v,out)
-- local a=a or 1
-- local b=b or 1
-- local h=h or false
-- local v=v or false
-- local out=out or 0
-- local transp=transparent or 0
 for i=0,15 do pal(i,out or 1) end
 for i=-1,1 do for j=-1,1 do
  spr(sp,x+i,y+j,a or 1,b or 1,h or false,v or false)
 end end
 pal()
end
function printo(str,x,y,c0,c1)
--	local xx,yy
	for xx = -1, 1 do
	 for yy = -1, 1 do
	 print(str, x+xx, y+yy,c1 or 1)
	 end
	end
	print(str,x,y,c0)
end
function printoc(str,y,c0,c1)
 local x=(128-(#str*4)+2)/2
	for xx = -1, 1 do
	 for yy = -1, 1 do
	 print(str, x+xx, y+yy, c1 or 1)
	 end
	end
 print(str,x,y,c0)
end
--[[function printc(str,y,c0)
 local xs=0
 for i=0,#str do
  if(sub(str,i,i)=="—")xs+=1
 end
 local x=(128-(#str*4+xs*4)+2)/2
 print(str,x,y,c0)
end--]]
function draw_rwin2(_x,_y,_w,_h,_c1,_c2,_c3,_c4)
 draw_rwin(_x,_y,_w,_h,_c2,_c1)
 draw_rwin(_x+2,_y+2,_w-4,_h-4,_c4,_c3)
end
function draw_rwin(_x,_y,_w,_h,_c1,_c2)
 -- would check screen bounds but may want to scroll window on?
 if (_w<12 or _h<12) return(false) -- min size
 -- okay draw inside
 rectfill(_x+3,_y+1,_x+_w-3,_y+_h-1,_c1) -- x big middle bit
 line(_x+2,_y+3,_x+2,_y+_h-3,_c1) -- x left edge taller
 line(_x+1,_y+5,_x+1,_y+_h-5,_c1) -- x left edge shorter
 line(_x+_w-2,_y+3,_x+_w-2,_y+_h-3,_c1) -- x right edge taller
 line(_x+_w-1,_y+5,_x+_w-1,_y+_h-5,_c1) -- x right edge shorter
 --now the border left side
 line(_x,_y+5,_x,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+1,_y+3,_x+1,_y+4,_c2) -- x 2 left top
 line(_x+1,_y+_h-4,_x+1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+2,_y+2,_c2)  -- x 1 top dot
 pset(_x+2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+3,_y+1,_x+4,_y+1,_c2)  -- x 2 top curve
 line(_x+3,_y+_h-1,_x+4,_y+_h-1,_c2)  -- x 2 btm curve
 --now the border right side
 line(_x+_w,_y+5,_x+_w,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+_w-1,_y+3,_x+_w-1,_y+4,_c2) -- x 2 left top
 line(_x+_w-1,_y+_h-4,_x+_w-1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+_w-2,_y+2,_c2)  -- x 1 top dot
 pset(_x+_w-2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+_w-3,_y+1,_x+_w-4,_y+1,_c2)  -- x 2 top curve
 line(_x+_w-3,_y+_h-1,_x+_w-4,_y+_h-1,_c2)  -- x 2 btm curve
 -- top and bottom!
 line(_x+5,_y,_x+_w-5,_y,_c2) -- x top
 line(_x+5,_y+_h,_x+_w-5,_y+_h,_c2) -- x bottom
end

-----------extra
function palstr(str,after)
	local arr=split(str)
	if(arr==nil)return
	for i=1,#arr\2 do
		pal(arr[i],arr[#arr\2+i],after)
	end
end
-->8
--squid
function m_squid(x,y)
	s=m_obj(x or 64,y or 10,9)
--	s.ddx,s.ddy=.5,.5
	s.boost,s.idlboost=3.2,.2
	s:chst"end"
	--3con20 atraviesa,4 con 15 se atraviesa
	s.idlboost=.2
	s.upd,s.drw=
	function(s)-----------------upd
		u_obj(s)
		local st,idlboost,boost
			=s.st,
				s.idlboost+.25*_bonusspd,
				s.boost+.55*_bonusspd
 	if btnp(Ž) and st!="end"then	 	
 	 if ink>=inkmax then
			 s:chst"ink"
			 sfx(58)-- enough ink
			else
				sfx(59)--not enough ink
				m_points(s.x-24,s.y-10,(rnd()>.5) and"need more ink"or"eat more fish",24)				
		 end
		end--Ž is more important than other btns
 	if st=="idl"then
	 	local	ax,ay=0,0
			if btn(‹) then
			 ax,s.flipx,s.dx=-1,true,-s.idlboost
			elseif btn(‘) then
			 ax,s.flipx,s.dx=1,false,s.idlboost
			elseif btn(ƒ)and s.y<_maph then
			 ay,s.flipy,s.dy=1,true,s.idlboost*3
			elseif btn(”) then
				ay,s.dy=-1,-s.idlboost
			else
			 s.flipx,s.flipy=false,false
			 if(s.y<_maph)s.dy=s.idlboost--gravity
			end
			s.ax,s.ay=ax,ay
			if btnp(—)then--boost
				s:chst"bst"
				sfx(63)
				if ay==1 then-----------dive
				 s.dy=boost*1.35
			 elseif ax==0 then---------up
			 	s.dy=-boost
			 else-----------------sideways
			 	s.dx=s.ax*boost*.707
			 	s.dy=-boost*.707
			 end
			end
		elseif st=="bst"then
			if(abs(s.dy)<.2)s.dy=0 s:chst"idl"		
		elseif st=="hit"then
			if s.tst==1 then
				sfx(62)
				m_points(sqd.x-10,sqd.y-8,"ouch!",50)
			 if(s.dx>0)then s.flipx=true
			 else s.flipx=false end
				s.dx=-1*sgn(s.dx)*boost/2
				s.dy=-1*sgn(s.dy)*boost/2
				
			elseif s.tst==45then
				s:chst"idl"
			end
		elseif st=="fed"then
			if s.tst==1 then
			 s.dy/=-2.5
			elseif s.tst==8 then
			 s.dy*=-1.5
			elseif s.tst==15 then
			 s.dy*=-1			 
			elseif s.tst==25 then
			 s:chst"idl"
			end
		elseif st=="ded"then
			if s.tst==1 then
				sfx(60)--spr falling in draw
			elseif s.tst==60then
--		sqd:chst"end"
				_upd,_drw,_winperc,ticks
							=upd_gover,drw_gover,0,0
			 if(lvl>bestlvl_)then

						bestlvl_,bestlvl=lvl,lvl 
						dset(0,lvl)						
printh("bestlvl "..bestlvl)
				end
											
				add(_coroutines,cocreate(function()
												_winperc=0
												while _winperc<1 do
													_winperc+=1/16 yield()
												end
										end))				
					end
			
		elseif st=="ink"then			
			if ink>0then
				inkr+=2
				ink-=2
			else
				s:chst"idl"
			end
		else--default state
		end
		s.x+=s.dx
	 s.y+=s.dy--+(s.y>_maph and 0 or .1)
	 s.dx*=.94
  s.dy*=.92

		if st!="ink"and inkr>0 then 
			inkr-=3--make the inkblob smaller
	 elseif st=="ink" then	 
		 for n in all(_npcs) do
		 	if n.dst<inkr then
		 		n:chst"ink"
		 	end
			end--for all npcs 
	 elseif st!="hit"then---collides	 
		 for n in all(_npcs) do
		 	if n.dst<s.r+n.r then
		 		if n.typ>0 then
		 		 if btn(ƒ)then--from above
			 		 n:chst"hit"
			 		 if(s.st!="fed")then
								local howmuch=inkd
								if(n.dx>1)howmuch*=1.5
								if(n.typ==5)howmuch*=2
								if(n.r<2.5)howmuch*=.9
								if(n.typ>5)howmuch*=1.1
								howmuch=flr(howmuch)
								--printh(howmuch)
			 		 
			 		 	addink(howmuch)--then collect
			 		 	dset(50+n.typ,dget(50+n.typ)+1)--collect
			 		 	s:chst"fed"
			 		 end
			 		 sfx(61)
		 		 end
		 		elseif n.typ<0 then
		 		 shake=15
						if(dropink())then
				 		s:chst"hit"
				 		n.flipx=not n.flipx
				 		n.dx=-n.dx
				 	else
				 		s:chst"ded"
				 	end
			 	end
		 		return
		 	end--distance
		 end
		end
		
		s.x=mid(0,s.x,_mapw)--todo:bug
	end,function(s)-------------drw
		local ofx,ofy,w,ani,sp,st,x,y,r,ax,ay,pals
		 =0,0,2,0,64,s.st,s.x,s.y,s.r,s.ax,s.ay,""
		if st=="idl" or st=="end"then
		 if ay==-1 then--”
			 w,ani,sp=2,s.anim2f1,64
				pals="12,11,7,1"
			elseif ay==1 then--ƒ
			 w,ani,sp=2,s.anim2f2,64			
				pals="12,11,1,7"
				if(ani==0)ani,sp,w=0,128,3
			elseif ax==0then--center
			 w,ani,sp=2,s.anim2f1,64
				pals="12,11,1,7"
	 	else--left/right
	 		w,ani,sp=3,s.anim2f1,70
			end		
			if(y>_maph)ani=1--immobile
		elseif st=="fed"then
			w,ani,sp=3,(1+s.anim2f3)%2,131
		elseif st=="hit"then
			w,ani,sp=3,0,137
			if(ani==0)then
				m_bubble(x-ax*3-1,
													y+10,
												 (rnd(2)-1)/2,-rnd()/2,
	    						  35+rnd(45),{0,1,13},rnd(),.06)
 		end
 	elseif st=="ink"then
 	 w,ani,sp=3,0,140
 	 ofy+=s.anim2f3
 	 local inksizeperc=max(s.tst,60)/60
 	 if s.tst>2 then
   end
 	elseif st=="ded"then
			w,ani,sp=3,0,137 	
			ofy=s.tst
		elseif st=="bst"then
		 if ay==1 then------------dive
		  w,ani,sp=3,s.anim2f2,128
		  if(ani==0)then
 			m_bubble(x-ax*3-1,
 												y+8,
 											 (rnd(2)-1),-rnd()/2,
     						  20+rnd(25),{6,7},rnd(),.04)
	 		end
			elseif(ax==0)then--------up
			 w,ani,sp=2,(2+s.anim3f2)%3,64
				pals="12,11,1,7"
	 	else-----------------sideways
	 		w,ani,sp=3,(2+s.anim3f2)%3,70
			end
			if(ani==2 and s.tst%2==0)then
 			m_bubble(x-ax*3,
 												y+12,
 											 (rnd(2)-1)/4,rnd()/2,
     						  40+rnd(15),{6,7},rnd(),.05)
			end
		else

		end

  --outline
  local outl=1
  if s.anim2f2==0 then
			if(ink>=inkmax)outl=0
			if(ink<=0)outl=8
			if(st=="hit" and s.tst%6>3) outl=8
		end
  
  if inkr>0 then
   circfill(x,y,inkr,0)
  	for i=0,inkr*2,3 do
  	 fillp""
  		if(i>inkr*1.5)fillp"0b1101101101011011.1"

	   circ(x,y,2*inkr+1-i,0)

	   circ(x,y,2*inkr-i,1)

  	end

  end
		spro2(sp+w*ani,
		      x+1-w*8/2+ofx,
		      y-12+ofy,
		      w,3,s.flipx,false,
		      outl,
		      --(st=="hit" and s.tst%6>3) and 8 or 1,
		      pals)
--		d_hitbox(s)		
		--?st,s.x,s.y-20,7
		--?s.dy,s.x,s.y-13,7
		pal()
	end--drw
	return s
end
--ink is global
function addink(i)
	i=i or inkd
	score+=i
	m_points(sqd.x-#("+"..i)*2,sqd.y-15,"+"..i,45)
	if(menulvl>0)i*=1.5
	if ink<inkmax then
		if ink+inkd>=inkmax and ink<inkmax then
			msg("press Ž to use your ink attack ")
			m_points(sqd.x-30,sqd.y-8,"ink attack ready",70)				
		end
	 ink+=i
	 if(ink>inkmax)ink=inkmax
	 return true
	end
	return false
end
function dropink(i)
 i=i or inkd*3
 if(ink<=0)return false
 ink-=i
 if(ink<0)ink=0
 return true
end

-->8
--npcs
_npcs={}
function m_npc(typ,y,x)
	local r,sp,dx,
											x,y=
															2,112,.5,
								x or rnd(_mapw/2)+_mapw/4,
								y or rnd(_maph-40)+8
 if typ==1 then
  sp,r,dx=112,3,.6
 elseif typ==2 then
  sp,r,dx=116,1.5,.2+rnd(.2)
 elseif typ==3 then
  sp,dx=118,.2+rnd(.2)	
 elseif typ==4 then--greenangel
  sp,r,dx=120,3.5,.7+rnd(.5)	
 elseif typ==5 then--puffer
  sp,dx=122,.15
 elseif typ==6 then--blueangel
  sp,r,dx=124,3.5,1+rnd(.5)	
 elseif typ==7 then
  sp,r,dx=58,3.5,.3+rnd(.3)  
 elseif typ==8 then
  sp,dx=60,1+rnd(.5)  
 elseif typ==9 then
  sp,r,dx=126,3.5,1.2+rnd(.7)  
 elseif typ==10 then
  sp,r,dx=62,3.5,1+rnd(.6)    
 elseif typ==-1 then
 	sp,dx=114,.04
 elseif typ==-2 then----eel left
  sp,r,dx,x=0,14,2,19
  if(menulvl>0)dx*=.5
 elseif typ==-3 then---eel right
  sp,r,dx,x=0,14,-2,_mapw-19
  if(menulvl>0)dx*=.5
 elseif typ==-4 then--empty
  sp,r,dx=0,14,3
  if(menulvl>0)dx*=.5  
 elseif typ==-5 then--puffer
 	--originalmente es tipo 5
 elseif typ==-6 then---+eel left
  sp,r,dx,x=0,14,3.25,19
  if(menulvl>0)dx*=.75
 elseif typ==-7 then--+eel right
  sp,r,dx,x=0,14,-3.25,_mapw-19
  if(menulvl>0)dx*=.75
// else
// 	typ=0
 end
	s=m_obj(x,y,r)
	if(rnd()>.5)s.flipx=true dx*=-1
	s.sp,s.typ,s.r,s.dst,s.dx,s.nosleep
      	=sp,typ,r,9999,dx
	s.upd,s.drw,s.destroy=
	function(s)-----------------upd
		u_obj(s)
	 st,tst,x,y,r,typ
	 		=s.st,s.tst,s.x,s.y,s.r,s.typ
		s.dst=dist(s,sqd)
	 if(s.dst>150 and not s.nosleep)return
	 if abs(s.x0-s.x)>88 then
	 	s.dx*=-1
	 	s.flipx=not s.flipx
	 end
	 
		if st=="idl" then
			if typ>0 then
			 s.x+=s.dx

			 if(typ==5)then--puffer off
				 local limit=150
				 if(menulvl>0)limit=220--easy
				 if tst>limit then--transformer
				 	s.typ,s.r,s.dx,s.sp,s.tst
				 		=-5,9,s.dx/10,10,rnd(99)
				 end
			 end	
			elseif typ==-5 then--pufferon
				if(tst>4)s.sp=12
				if(tst>135)s.sp=10
				if tst>150then
			 	s.typ,s.r,s.dx,s.sp,s.tst
			 		=5,2,s.dx*10,122,rnd(64)
			 end	--------------------eels
			elseif typ==-2 or typ==-3 
							or typ==-6 or typ==-7 then
				s.x+=s.dx					
			elseif typ==-1 then
			 if(y<_maph)then 
			 	s.dy=.5	
			 	if(menulvl>0)s.dy=.25
			 	s.y+=s.dy
			 else
			 	s.x+=s.dx s.dy=0
			 end
			end
		//idl		
		elseif st=="hit"then
			rnd(5)
		 m_bubble(sqd.x+tst/2.2*(tst%2==0 and -1 or 1),
 											sqd.y+6,
 											0,
 											.5+tst\15,
     						 10+rnd(30),

     						 tst%2==0 and 
     						 											{11,10,9,8,14,12,15}
     						 								or
     						 											{15,12,14,8,9,10,11},
     						 rnd()+.5,.05)
   rnd(ticks)
   if(tst%4==0)s.flipx=not s.flipx s.y+=(sqd.x<x and -1 or 1)
   if tst>22 then
   	fed+=1
   	totalfed+=1
    s:destroy()
   end
		end
	end,function(s)-------------drw
		if(s.dst>150and not s.nosleep)return--too far
		local x,y,r,sp,typ,st,tst
					=s.x,s.y,s.r,s.sp,s.typ,s.st,s.tst
--				d_hitbox(s)		
  if st=="ink" and tst>5then
			if tst%6==0 then 
			 local bdx,bdy=
			 								x>sqd.x and 1 or -1,
			 								y>sqd.y and 1 or -1
				m_bubble(x+bdx*tst/2,y+bdy*tst/3,
													bdx,bdy*rnd()/2,
													25,{13,6,1},
													1,.35)
			end
			if tst>22 or inkr==0 then
				score+=10
				s:destroy()
			end
  
		elseif typ==-2 or typ==-6 then--left eel
			if(typ==-6)palstr("9,4,2,8,10,11,3,14")
			spr(0,x-r+4-(8*3),y-r-1,4,4)
		 local ani=s.anim4f4
		 if(ani==3)ani=2
		 if(s.dx<0)ani=0
		 --head
			spr(4+ani*2,x-r+4+8,y-r-1,2,4)
			for i=-12,-2,2 do--body
			 spr(1,x-r+4-(3-i)*8,y-r-1,2,4)
			end
			if(y>sqd.y-60 and y<sqd.y+40)printo("!",sqd.x-16,sqd.y-8,1,tst%20>8 and 8 or 10)
			pal()
		elseif typ==-3 or typ==-7 then--right eel
			if(typ==-7)palstr("9,4,2,8,10,11,3,14")			
			spr(0,x-r-4+(8*3),y-r-1,4,4,true)
		 local ani=s.anim4f4
		 if(ani==3)ani=2
		 if(s.dx>0)ani=0
			spr(4+ani*2,x-r-4+8,y-r-1,2,4,true)
			for i=-12,-2,2 do
			 spr(1,x-r-4+(3-i)*8,y-r-1,2,4,true)			
			end
			if(y>sqd.y-60 and y<sqd.y+40)printo("!",sqd.x+16,sqd.y-8,1,tst%20>8 and 8 or 10)
			pal()
		elseif typ==4 then
			spro2(sp+s.anim2f3,x-r-1,y-r-1,1,1,s.flipx,nil,1)
		elseif typ==5 then
			spro2(sp+s.anim2f1,x-r-1,y-r-1,1,1,s.flipx,nil,s.tst>105 and s.tst%7>3 and 8 or 1)
		elseif typ==-5 then
			spro2(sp,x-r-1,y-r-1,2,2,s.flipx,nil,s.tst%30>20 and 1 or 8)
		elseif typ==-1 then
			spro2(sp,x-r-1,y-r-1,1,1,s.flipx,s.dy>0,s.tst%80>20 and 1 or 8)
		else
			spro2(sp+(abs(s.dx)>1.1 and s.anim2f2 or s.anim2f1),x-r-1,y-r-1,1,1,s.flipx,nil,1)
		end
		//?s.typ,x-r,y-10,7
	end,function(s)---------destroy
		x_obj(s)
		del(_npcs,s)	
	end
	add(_npcs,s) return s
end
-->8
--updates
function upd_intro()
	if(ticks==1)then
		_winperc=0
		destroy_npcs()
		for i=1,14 do
			h=dget(i+50)
			if(h>0)then
				npc=m_npc(i,95+rnd(28),rnd(120))
				npc.nosleep=true
			end
		end
	end
	--for s in all(_npcs)do s:upd()end
	update_objs()
	if btn(Ž) then
		if(_winperc<1)_winperc+=.1
	else
		if(_winperc>0)_winperc-=.1
	end
	if btnp(—) and ticks>60 
				and not _fading then
		totalt,totalfed,lvl,
		bestlvl_,
		score,lives,_bonusspd
			=0,0,max(menulvl-1,0),
			 bestlvl,
				0,2,0--score,lives
	  hiscores_og={}
	 	for i=1,6 do
	 		hiscores_og[i]=hiscores[i]
	 	end
		_fading,__upd,__drw
				=true,upd_play,drw_play
		add(_coroutines,cocreate(fadecor))
	end
end
function upd_play()
	srand(ticks)
	lvlt+=.0166
	totalt+=.0166--1/60
	update_objs()
	if sqd.y<=0 and not _fading then
		--reached the surface
		sqd:chst"end"
		_upd,_drw,_winperc,ticks
					=upd_score,drw_score,0,0
		if(lvl>bestlvl)then
			bestlvl=lvl dset(0,lvl)
		end
		add(_coroutines,cocreate(function()
										_winperc=0
										while _winperc<1 do
											_winperc+=1/16 yield()
										end
								end))	
	end
end
function upd_score()
	update_objs()
	if btnp(—) and ticks>60 
				and not _fading then
		update_hiscores()		
		if (lvl%3==0)then
		 _upd,_drw,_bonusi,_bonus
		 		=upd_bonus,drw_bonus,0
		 		
		else
 		_fading,__upd,__drw=true,upd_play,drw_play		
			add(_coroutines,cocreate(fadecor))
		end
	end
end
function upd_bonus()
 update_objs()
	if not _bonus then
		_bonusi=(_bonusi+.25)%5--0..4
 	if(not _bonusi)sfx(61)
		if btnp(—) then
			_bonus=flr(_bonusi)
					if _bonus>0 then
					 sfx(58)
					else
						sfx(60)
					end
		end
	else 
				if btnp(—) --and _bonus
							and not _fading then
					if(_bonus==1)ink=inkmax
					if(_bonus==2)lives+=1
					if(_bonus==3)lives+=2
					if(_bonus==4)_bonusspd+=1
					_fading,__upd,__drw,
						_bonus
						=true,upd_play,drw_play
					add(_coroutines,cocreate(fadecor))
				end
	end
end
function upd_gover()
 update_objs()
	if btnp(—) and ticks>60 
				and not _fading then
		_fading=true	
		if lives>0 then--continue
			lvl,lives,__upd,__drw
					=lvl-1,lives-1,upd_play,drw_play
		else--end
			lvl,__upd,__drw=0,upd_intro,drw_intro
		end
		music(0)
		update_hiscores(true)--for gover re uses hiscores_og
		add(_coroutines,cocreate(fadecor))
	end
end
function upd_end()
	if(ticks==1)then
		_winperc=0
		--for n in all(_npcs)do n:destroy()end
		destroy_npcs()
		for i=1,20 do
			if(i%10!=5)m_npc(i%10,rnd(120)+8,rnd(120))
		end
	end
	
	update_objs()
	if btnp(—) and ticks>60 
				and not _fading then
		_fading,__upd,__drw=true,upd_intro,drw_intro
--		bestlvl=lvl dset(0,lvl)
		add(_coroutines,cocreate(fadecor))
	end
end
function update_objs()
	for s in all(_objs)do s:upd()end
end
function destroy_npcs()
		for n in all(_npcs)do n:destroy()end
end
-->8
--draws
function drw_intro()
	draw_bg()
	_camy=-74
	_camx=_mapw/2-64
	_mapw,_maph=128,128
	sqd.y,sqd.x=10,_mapw/2--dont show
	local menutxt="level"
	camera()
	for s in all(_npcs)do s:drw()end
	pal()
	if ticks>100 and ticks%50>15 then
		local txtpress="PRESS — TO START"
		if(ticks%200<100)txtpress="HOLD Ž FOR SCOREBOARD"
		printoc(txtpress,121,12,1)
	end
	--title
	spro2(204,48,87+max(-34,50-ticks*2),4,4,nil,nil,2)
	--SCOREBOARD
 draw_rwin2(37,52,54,58*_winperc,2,14,15,2) 
 for i=1,_winperc*6 do
 	printo(i..". ",50,58+i*8,6,1)
 	printo(hiscores[i],63,58+i*8,7,1)
 	if(i>2)printoc("high scores",58,15,1)
 end         	
	--squid
	spro2(66+2*(ticks\24%2),58,28-2*(ticks\24%2)+max(4,180-ticks*2),2,3,nil,nil,1,"11,13,12,1,13,7")
	if(ticks>150 and bestlvl>0) then
		local y=-16+min(ticks\4-30,17)
	 printo("GAME MODE: ",14,y,15,2)
	 if(menulvl==0)then
	 	menutxt="normal"
	 else
	  printo("‹",3,y,btn(‹)and 8 or 14,2)
			menutxt="easy (LVL: "..(menulvl>9and""or"0")..menulvl..")"
  end
	 printo(menutxt,58,y,15,2)
	 if(menulvl<min(20,bestlvl))printo("‘",58+#(menutxt.." ")*4,y,btn(‘)and 8 or 14,2)
		if(btnp(‘)and menulvl<min(20,bestlvl))menulvl+=1
		if(btnp(‹) and menulvl>0)menulvl-=1
	end
	local move=max(ticks/2,0)-65
	spro2(189,28,0-move,1,1,nil,nil,2,ticks>45 and "" or "15,7")
	printoc("  gnomael PRESENTS",1-move,ticks>45 and 14or 15,2)
	camera(0,-87)
end
function drw_play()
	draw_bg() 
	for s in all(_npcs)do s:drw()end
	sqd:drw()
	for s in all(_fxs)do s:drw()end
	draw_fg()
	draw_hud()
	_camx,_camy
				=mid(-16,flr(sqd.x-63.5),_mapw-111),
					flr(sqd.y-75.5)
	camera()
	draw_msg()		
 --screenshake --todo not working
--	if(shake>0)then
	--(shake)
--  camera(_camx+rnd(6)-3,_camy+rnd(4)-2)
--  shake-=1
-- else--if shake==0 then
  camera(_camx,_camy)
-- else
-- 	printh"shake stop"
--  shake=0
-- end	
end
function drw_bonus()
	drw_score()
	local right,top=32,88

	local wx,wy,ww,wh=
										 _camx+right,_camy+top,
											127-right*2,
											28//top*2
	local txtx,txtx2,txty=wx+4,wx+58,wy+2

	draw_rwin2(wx,wy,ww,wh,2,14,9,1)
	printo("win a bonus",txtx+6,txty-5,10,2)
	for i=0,4 do
		local sel=nil
		palt(0,false)palt(11,true)
		if(i==flr(_bonusi))spr(180,txtx+8+8*i,txty+4)sel=true
		spr(181+i,txtx+8+8*i,txty+12+(sel and rnd(2) or 0))
	end
	pal()
if _bonus then
		local txtb
			if(_bonus==0)txtb="nothing at all"
			if(_bonus==1)txtb="an ink refill"
			if(_bonus==2)txtb="1 extra life"
			if(_bonus==3)txtb="2 extra lives"
			if(_bonus==4)txtb="a speed boost"		
		printo("you just won "..txtb,txtx-22,txty+30,8,1)
	end
	if(ticks>60and ticks%45>15)then
		local txtbtn="— TO SPIN"
		if(_bonusi)txtbtn="— TO STOP"
		if(_bonus)txtbtn,txtx="— TO CONTINUE",txtx-8
		printo(txtbtn,txtx+8,txty+22,6,1)
	end
end
function drw_score()
	draw_bg()
	for s in all(_objs)do s:drw()end	
	for s in all(_fxs)do s:drw()end		
	if(_winperc<1)draw_fg()
	local right,top=24,32
	local wx,wy,ww,wh=
										 _camx+right,_camy+top,
											127-right*2,
											(127-top*2)*_winperc
	local txtx,txtx2,txty=wx+12,wx+58,wy+2
	clip(right,top-6,ww+15,wh+8)
	draw_rwin2(wx,wy,ww,wh,2,14,9,1)
	local blink=(score>hiscore and ticks%45>15) and 8 or 2
	printo(score>hiscore and "new high score!" or "level "..lvl.." cleared!",txtx-1,wy-4,10,blink)
	printo("LIVES:",txtx,txty+10,7,2)
	spr(188,txtx2-8,txty+8)
	printo("X"..lives,txtx2,txty+10,10,2)
	printo("SCORE:",txtx,txty+20,7,2)	
	printo(score,txtx2,txty+20,10,blink)	
	printo("EATEN:",txtx,txty+30,7,2)	
	printo(totalfed,txtx2,txty+30,10,2)	
	if menulvl>0then
		printo("EASY MODE",txtx+12,txty+40,10,2)		
	else
		printo("TIME:",txtx,txty+40,7,2)	
		printo((flr(totalt*10)/10).."S",txtx2-8,txty+40,10,2)
	end
	if(ticks>60and ticks%45>15)printo("— TO CONTINUE",txtx,txty+54,6,1)	
	clip()
end
function drw_gover()
	draw_bg()
	for s in all(_objs)do s:drw()end	
	for s in all(_fxs)do s:drw()end		
	draw_fg()
	local right,top=24,32
	local wx,wy,ww,wh=
										 _camx+right,_camy+top,
											127-right*2,
											(127-top*2)*_winperc
	local txtx,txtx2,txty=wx+12,wx+49,wy-2
	clip(right,top-6,ww+15,wh+8)
	draw_rwin2(wx,wy,ww,wh,2,14,9,1)
	printo(lives>0 and "squid down!" or "game over!",txtx+8,wy-4,10,2)	
	printo("LEVEL:",txtx,txty+10,7,2)	
	printo(lvl,txtx2,txty+10,10,2)	
	printo("LIVES:",txtx,txty+20,7,2)
	spr(188,txtx2-8,txty+18)
	printo("X"..lives,txtx2,txty+20,10,2)
	printo("SCORE:",txtx,txty+30,7,2)	
	printo(score,txtx2,txty+30,10,(score>=hiscore and ticks%45>15) and 8 or 2)
	printo("EATEN:",txtx,txty+40,7,2)	
	printo(fed,txtx2,txty+40,10,2)	
	printo("TIME:",txtx,txty+50,7,2)	
	printo((flr(totalt*10)/10).."S",txtx2-12,txty+50,10,2)
	if(ticks>60and ticks%45>15)printo(lives>0 and "— TO TRY AGAIN"or "— TO START OVER",txtx-2,txty+58,6,1)	
	clip()
end
function drw_end()
	cls(1)
	camera()
	_maph=130
	sqd.y=50

	draw_bg()
		for s in all(_npcs) do s:drw()end
--have you heard about the kraken?
	printoc("you did it!",10,7)
	printoc("after surviving that hell,",30,6,2)
	printoc("no wonder you needed an out.",38,6,2)
	printoc("squids migrate hundreds of miles",58,6,2)
	printoc("at a time. you could do better.",66,6,2)
	printoc("sometimes we must navigate new",84,6,2)
	printoc("waters, even though it's scary.",92,6,2)
	printoc("never give up!",110,8)
	printo("-gnomael.",92,121,14,1)

end
function draw_bg()
	cls(5)
	if sqd.y>_maph-99 then---floor
		for i=16,(_mapw+16),4 do
			srand(i)
			if(rnd()>.7)then
				local r=rnd(2)
			 for j=-1-r,3 do
					srand(flr(t()*3)+i)
					spr(143+flr(rnd(4))*16,i,_maph-20+j*8)
				end
				spr(190,i-.5+(sqd.anim2f1+r)%2,
								(sqd.anim3f2+r)%3+_maph-20+(-2-r)*8)
			end
		end
	end
 if sqd.y>_maph-50 then---floor
 	rectfill(-16,_maph+4,_mapw+16,_maph+127,9)--sand
		srand(2)
		for i=0,_mapw,4 do
		 palstr"9,10,2,14"--)pal(10,14)
		 if(rnd()>.3)palstr"9,10,13,6"--)pal(10,6)
		 spr(95,i,_maph+rnd(50),1,1,rnd()>.5,rnd()>.9)
		 pal()
		end
		srand(ticks)	
	elseif sqd.y<111 then----surface
 	rectfill(-16,0,_mapw+16,-127,12)--air		
		circfill(_mapw/2,-74,12,7)--sun
		--fillp"0b0101101001011010.1"
			fillp"0b0010010010100101.1"
		srand(t()\4)
 	for i=0,_mapw,rnd(16)+18 do
 		local r=rnd(8)+12
 		ovalfill(i-r,-40-r*1.35,i+r*2,-40,7)
 		ovalfill(i+r,-52,i+r*3,-36,7)
 	end
 	srand(flr(t()*2))
 	fillp"0b0111101011011011.1"
		for i=-16,_mapw+16,rnd(6)+20 do
			for r=0,2+rnd(6)do
			 line(i+r*1.5,5+r*2,i+r+8,32+r*.75,12)
			end
		end
		fillp""
		draw_surface_line()
	end
	srand(3)--bg dots
	for i=3,_maph,3 do
	 pset(rnd(_mapw)+ticks\44%2.5,i,1)
	end
	srand(ticks)
end
function draw_fg()--uses sqd
	if sqd.x<88 or sqd.y>_maph-64 then----------left
		srand(1)
		rectfill(-16,64,-2,_maph+99,1)
		circfill(16,_maph+60,40,2)
		for i=64,_maph+88,11 do
			local x,y,r,r2=-rnd(16),i,rnd(10),rnd()
			if i>=sqd.y-99 and i<=sqd.y+99 then
				if(y>_maph-16)x+=16 r+=5
				if(y>_maph+16)x+=16 r+=5
				fillp""
				circfill(x-2,y+2,r+9,1)
				circfill(x,y,r+7,2)
				fillp"0b1010010101010101.1"
				circfill(x+2.5,y-3,r+3,13)
				spr(95,x+r,y+r,1,1,r2>.5,r2>.5)
				spr(r2>.5 and 79or 111,x-r2*8,y-r-r2*8,1,1,r2>.5)
			end
		end 	
		fillp""
	end
	if sqd.x>_mapw-88 or sqd.y>_maph-64 
		then---right
		srand(1)
		rectfill(_mapw+16,64,_mapw+2,_maph+99,1)
		circfill(_mapw-16,_maph+60,40,2)
		for i=64,_maph+88,11 do
		 local x,y,r,r2=_mapw+rnd(16),i,rnd(10),rnd()
			if i>=sqd.y-99 and i<=sqd.y+99 then					
				if(y>_maph-16)x-=16 r+=5
				if(y>_maph+16)x-=16 r+=5
				fillp""
				circfill(x+2,y+2,r+9,1)
				circfill(x,y,r+7,2)
				fillp"0b1010010101010101.1"
				circfill(x-2.5,y-3,r+3,13)
				spr(95,x-r*2,y+r,1,1,r2>.5,r2>.5)
				spr(r2>.5 and 79or 111,x-r2*8,y-r-r2*8,1,1,r2>.5)
			end--if
		end--for
		fillp""
	end
	srand(4)--fg dots
	for i=0,_maph,4 do
	 pset(rnd(_mapw)+sqd.anim2f0,i,12)
	end
	srand(ticks)
	if sqd.y<82 then----surface
		draw_surface_line()		
	elseif sqd.y>_maph-60then--floor
		for i=16,(_mapw+16),7 do
			srand(i)
			if(rnd()>.5)then
				local y,r=rnd(10),rnd(4)
			 for j=-4-r,5 do
					srand(flr(t()*3)+i)
					spr(143+flr(rnd(4))*16,i,6+y+_maph+34+j*8)
				end
			end
		end
	end--floor/surface
end
function draw_surface_line()
 srand(t()\.5)
	local i,j=-16,0
	while i<_mapw+16 do
		local w=rnd(7)+6
		line(i,j,i+w,j,7)
		line(i,j+1,i+w,j+1,6)
		j=(j+1)%2
		i+=w
	end
	srand(ticks)
end
function draw_hud()
		camera()
		--deep/ink meters
		rect(2,1,4,121,1)--deep
		local perc=min(max(sqd.y,0)/_maph,1)
		line(3,1+120*perc,3,120,2)
		for i=0,120,30 do
			line(1,i+1,5,i+1,1)
		end
		printo(flr((1-perc)*100).."%",1,1+121*perc,15,1)
		printo("LEVEL "..lvl,
 						(10-max(0,min(1-perc,.15)-.05)*100) +2,
							122,15,1)
		printo("      "..lvl,
 						(10-max(0,min(1-perc,.15)-.05)*100) +2,
							122,14,1)
		
		rect(123,8,125,121,(ink==inkmax and ticks%30>10)and 0 or 1)--ink
		line(124,118-110*(ink/inkmax),124,120,0)
		for i=8,110,111/4 do
			line(122,i,126,i,1)
		end
		palt(15,true)palt(0,false)pal(1,(ink==inkmax and ticks%30>10)and 0 or 1)spr(187,121,0)pal()
		printo("INK",116,122,15,ink==inkmax and 0 or 1)
		printo("‡",121,119-110*(ink/inkmax),8,(ink==0and ticks%30>10) and 2 or 1)
		
		local ys=122-(8-max(0,min(1-perc,.15)-.05)*80)
		pal(12,1)
		spro2(116,50+#(score.." ")*4+5,ys,1,1,nil,nil,1,"12,13,6,15,15,15")pal()
		printo(score.."",58,ys,14,1)
		printo("SCORE",54,ys+8,15,1)
		if(menulvl<1)then
--			printo("“"..(flr(totalt)).."S",88,ys,15,1)
--			printo("  "..(flr(totalt)),88,ys,14,1)
--			printo("TIME",88,ys+8,15,1)	
if _bonusspd>0 then
	for i=1,_bonusspd do
			spro2(179,92-i*6,ys-1,1,1,nil,nil,1)
	end
end
			
			spro2(186,93,ys-1,1,1,nil,nil,1)
			printo("X"..lives,101,ys,14,1)
			printo("LIVES",94,ys+8,15,1)
		end
		
end
_msgs={}
_msgt,_msg,_msgptr=0,"",0
function msg(txts)--todo
	local msgs={}
	for m in all(_msgs)do
		add(msgs,m)
		del(_msgs,m)
	end
 for txt in all(split(txts))do 
		add(_msgs,txt)
	end
	for m in all(msgs)do
		add(_msgs,m)
	end	
end
function draw_msg()
	if(#_msgs>0 and _msgt==0)then
		_msg,_msgptr
				=_msgs[1],0
		_msgt=(1+(#_msg\5))*60
		del(_msgs,_msg)
	end
	if _msg!="" and _msgt>0 then
		if(_msgptr<#_msg)_msgptr+=.5
		printoc(sub(_msg,0,_msgptr),
										-9+min(_msgt,10),
										15,1)
		_msgt-=1
	end
end
-->8
--gm
levels={}
for l in all(split("128,150|148,182|168,256|182,384|182,448|150,448|150,512|150,576|150,640,150,720|128,784|128,848|128,912|128,1024|128,1100|128,1250|128,1350|128,1450|128,1550|128,1650|128,1750|150,150","|"))--150 150 es el 21
do
	add(levels,split(l))
end
--[[
{
	{128,150},--1
	{148,182},--2
	{168,256},--3
	{182,384},--4
	{182,448},--5
	{150,448},--6
	{150,512},--7
	{150,576},--8
	{150,640},--9
	{128,720},--10
	{128,784},--11
	{128,848},--12
	{128,912},--13
	{128,1024},--14
	{128,1124},--15
	{128,1224},--16
	{128,1324},--17
	{128,1424},--18
	{128,1524},--19
	{128,1700},--20
}--]]
function next_lvl()
	for s in all(_npcs)do s:destroy()end
	lvl+=1
 if(lvl==21)then
		_fading,__upd,__drw=true,upd_end,drw_end
		add(_coroutines,cocreate(fadecor))
		return 
 end
	sqd:chst"idl"
	lvlt,_mapw,_maph=0,levels[lvl][1],levels[lvl][2]
	local mapw2=_mapw/2
 for i=0,32 do
 	m_npc(1+flr(min(rnd(lvl/2),9)))
 end
 if(lvl>=2)m_npc(-1,_maph-84,mapw2+45)
 if(lvl>=3)m_npc(-1,_maph-84,mapw2-45)
	if(lvl>=4)m_npc(-1,_maph-182,mapw2)
	if(lvl>=5)m_npc(-1,_maph-384,mapw2+30)m_npc(-1,_maph-384,mapw2-30)
	--4 puffers
	if(lvl>=6)m_npc(5,_maph-88)for i=1,3 do m_npc(5)end
	--4 more puffers
	if(lvl>=7)for i=1,4 do m_npc(5)end
	--eel
	if(lvl>=8)m_npc(-2,_maph-140)
	--left eel
	if(lvl>=9)m_npc(-3,_maph-256-rnd(64))
	--5 more puffers top half
	if(lvl>=10)for i=1,5 do m_npc(5)end
	--2 crabs @-600
	if(lvl>=11)m_npc(-1,_maph-600,mapw2+30)m_npc(-1,_maph-600,mapw2-30)
	--eels
	if(lvl>=12)m_npc(-2,_maph-400-rnd(64))
	if(lvl>=13)m_npc(-3,_maph-550-rnd(64))
	--3+ more puffers top half
	if(lvl>=14)for i=0,lvl-12 do m_npc(5,rnd(_maph/2)+8)end
	--eels
	if(lvl>=15)m_npc(-2,_maph-700-rnd(64))
	if(lvl>=16)m_npc(-3,_maph-750-rnd(64))
	if(lvl>=17)m_npc(-7,_maph-1100-rnd(64))
	if(lvl>=18)m_npc(-6,_maph-1100-rnd(64))
	if(lvl>=19)m_npc(-7,_maph-1400)m_npc(-6,_maph-1400-rnd(128))
	if(lvl>=20)m_npc(-6,100)m_npc(-7,100)
 
	
	sqd.x,sqd.y=_mapw/2,
													_maph-9
													--25
	ticks,fed=0,0
	if(ink<=0)ink=inkd
	--for m in all(_msgs)do del(_msgs,m)end
	_msgt,_msg,_msgs=0,"",{}
	if(lvl==1)msg("press — to swim,hold ƒ over a fish to eat it ,swim to the surface,hold ‹/‘ then press — to move   ")
	if(lvl==2)msg("watch out for that crab!,if you touch it you'll lose ink,if you have no ink left...,you'll die")
	if(lvl==3)msg("feed to gain more ink,swim over a fish then hold ƒ ,squids are cephalopods,they have the biggest eyes,no animal matches those eyes")
	if(lvl==4)msg("these are hermit crabs,they carry their home around,they like claiming empty shells,as their homes,but when there aren't enough,things tend to go bad")
	if(lvl==5)msg("as these crabs grow,they need to find better shells,hermit crabs are fierce fighters,they kill to get a new shell,depending of availability")
	if(lvl==6)msg("look a puffer fish!,they are an angry lot,try to avoid them,if they are not puffed,you may eat them from above")
	if(lvl==7)msg("most puffer fish are toxic,sometimes they have tetrodotoxin,quite deadly if eaten,but they are also eaten in japan,even considered a delicatessen")
	if(lvl==8)msg("watch out on your left!,that's what you call an eel,a moray eel to be specific,they are also called muraenidae,they hunt by smell,their jaws are huge...,and quite scary")
	if(lvl==9)msg("eels are opportunistic hunters,they prefer to eat small fishes,but they also like squids")
	if(lvl==10)msg("this kind of eel's called moray,many morays are apex predators,they don't have natural enemies,...but humans")
	if(lvl==11)msg("you've reached level 11!,congratulations,you are half through the game,this is gonna get harder now,i hope you are enjoying it")
	if(lvl==12)msg("morays are sometime recruited,by coral fishes to help them,together they flush prey,eels are great at flushing prey")
	if(lvl==13)msg("moray eel can be found in both,freshwater and saltwater,but most prefer warm saltwater,they like occuping reefs,preferably dead patch reefs")
	if(lvl==14)msg("pufferfish have many names:,blowfish,puffers,ballonfish,blowies,bubblefish,globefish,toadfish,and a lot more names,they are quiet popular,popular and deadly")
	if(lvl==15)msg("squid make use of camouflage,matching the background color,this helps to protect them,from their predators,and allow them to approach prey")
	if(lvl==16)msg("some squids glow in the dark,made possible by bacteria,symbiotic life living in it,roughly 2/3 of sea creatures,use this bioluminiscence")
	if(lvl==17)msg("there are 200 species of morays,their body is patterned,and they come in many colors,an small amount of eels,feed exclusively on crustaceans,that's why they have big teeth,even molars for crushing shells")
	if(lvl==18)msg("squids use ink to evade attacks,by ejecting a cloud of ink,the ink exits near it's anus,the ink is made of melanin,just like your hair,it forms a dark obscuring cloud,and it quickly disperse,predators don't like it,as it messes with senses,even the chemical receptors")
	if(lvl==19)msg("giant squids are not monsters,but there have been sightings,of squids 15 meters long,there's no way to know how,big they could get,but they usually stay away,they are deep dwellers,usually living half mile from,the surface,trying to find whales to eat,yes... whales,but they rarely succeed")
	if(lvl==20)msg("squid don't eat people,and they are really smart,maybe you shouldn't eat squid,thanks a lot for playing,i hope you had a great time,just this one more level to go,you got this!")

end

--uses _fading,_upd,_drw,__upd,__drw
function fadecor()
	for i=0,1,.03333 do
		srand(t()\4)
		for j=0,1,.2 do
			local x,y=_camx+64+cos(j+i/3)*42*i,
			 									_camy+64+sin(j+i/3)*42*i
			fillp"0b0101101001011010.1"
			circfill(x,y,i*64,1)--ticks%2)
			fillp""
			circfill(x,y,i*42,1)
		end
		yield()
	end
	next_lvl()
	_upd,_drw,ticks,__upd,__drw
		=__upd,__drw,0--nil,nil
	cls(1)yield()
	for i=32,0,-1 do
		fillp"0b0101101001011010.1"				
	 circfill(sqd.x,sqd.y,i*10,2)
		fillp""
	 circfill(sqd.x,sqd.y,i*4,1)
		yield()
	end
	_fading=nil
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000a0000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00a000a000000000000000000
1110101111111000111111000000000000000000000000000000000000000000000000000000000000000a00a0000000000a00999990a0000000000000000000
22212122222221112222221110000000000000000000000000000000000000000000000000000000000000a0a000a0000000a99a9dd9d5000000000000000000
88228282282822228888822221100000000000000000000000000000000000000000000000000000000a0099990a00000a009999d51dd1000000000000000000
288288888882828228828822222111000000000000000000000000000000000000000000000000000000a999dd9d500000a99999d11d990a0000000000000000
828828282888882882882882882222100000000000000000000000000000000000000000000000000000999d51dd1000009999a99dd999900000000000000000
8828888282848882888488888288822100000000000000000000000000000000000000000001111000a09a9d11d990a0a09a9999666622200000000000000000
48848884288124444181422288288822110000000000000011100000000000001111111111122221096666666d9229000a9997666662666a0000000000000000
12212221222221212222229912218882221100000000000022211000000000002222222222244422099ddd67666d6000009966667667d6d00000000000000000
22222229299922229999999999222221222211100000000022222111000000002224294244412442009d0dd66dd7070096666666666ddd700000000000000000
99999999999999999999999999999999999422211000000099942222111111109999999499999222000000ddddd00000996dd67667dddd000000000000000000
999999449999999999999999999999994499994221100000449999422222222144999119999922210000070d7d0700000970dd666ddd70700000000000000000
944999449994499999944999999999444499999444211000449999944444442244992d1199922610000000070700000007000ddddddd00070000000000000000
9449999999944999999449994499994499992119994421109999211999912442999211d1992221000000000000000000000070d7d7d070000000000000000000
9999999999999994499999994499999999921d119991442199921d11999992229992111922261000000000000000000000070070007007000000000000000000
99999449999999944999999999994499999211d199992442999211d1999922219999299922210000000000000000000000000000000000000000000000000000
99999449999999999999999999994499999921199999922299992119992226109999992226100000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999222199999999222221009999922261000000000000000000000000000000000000000000000000000000
9999999994494449999999994444994499999999992222229999992222261110999926d110000000000000000000000000000000000000000000000000000000
99991111444444444444444444444444999992222222999499992222262444419996dd1000000000000000000000000000000000000000000000000000000000
4491111142444444444444444444442449222222299999424922222622dd6229492dd11000000000000000000000000000000000000000000000000000000000
4412222142444444422224422444442222222229999944212222226d6d62229422d2222111100000000000000000000000000000000000000000000000000000
91222222444444444444444422222222444444449944421044222222222999424222d26622d11111000000000000000000000000000000000000000000000000
1222221122222222224442222222222224244444422221002444444499994421242d2d2d6d6d622900f040000040f00000000000000000000000000000000000
1111111122222224444444444444444222222222211110002224444444444210244444422222229400020400000202000b00000000b00000c000000000000000
1111122244444442222222222222222222211111100000002222222222222100222444449999994280e8e8e080e8e8e0b0bbb000013bb000dc066660dc066660
2222222222222222444444444444222221100000000000002112222111111000222222244449442184884f1efe88f81f617b1300637b13000ccccc1c6ccccc1c
44444444444444442222222222222221100000000000000010011110000000001112222222244210fe4f8f484404e4fe30b33000103330006c666c6c0c666c66
22222222222222222222222222221110000000000000000000000000000000000001111111122100f000f0e0f00f00e000000000000000000d1dcdd0d1dddcd0
1111111111111111111111111111000000000000000000000000000000000000000000000001100000000000000000000000000000000000d10cdd000d1dc000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00d0000d0000000
0000000e000000000000000000000000000000eee0000000000000000000000000ee000000000000000000000000000000000000000000000eeffe000e0080e0
000000eff00000000000000e000000000000eefffee0000000000000000000eeefffe00000000000000000000ee0000000000000000000eeeffffe008ee80ee8
0000eefffee0000000000eeffe00000000ee2fffffeee00000000000000eeeefffffee00000000000000000efffe0000000000000000eeeeffffeee008e00e80
00ee2fffffeee0000000eefffee000000eeeeffffffeee00000000000000eeffffff2ee0000000000000eeeffffee000000000000000eeefffff2ee008ee0e8e
0eeeeffffffeee0000ee2fffffeee0000e22effffff22e000000000000222fffffffeeee00000000000eeefffff2ee00000000000000e2ffffffeeeee08ee80e
00e2effffff2e0000ee2effffff2ee00022fffffffff22000000000002eeffffffff2e000000000000eeeffffffeee00000000000002effffffe2eee8e0e80ee
002eeffffffe20000222eeffffe2220002eeffffffffe200000000002eefffffffffe200000000000222ffffffe2eee000000000002eeffffffee2e0088e8e88
02eeffffffffe20022eeffffffffe2202eeefffffffffe20000000002effffffffffee20000000002eeffffffffee2200000000002effffffffee20000088800
2eeefffffffffe202eeefffffffffe202eeeeffffffffe2000000002eefffffffffeee2000000002eefffffffffeee20000000002efffffffffee20000000000
2eeeeffffffffe202eeefffffffffe202eeee22222eeee2000000002ee2222ffffeeee2000000002e22222fffeeeee2000000002ee22222ffeeee20000aa9000
2eee2222222efe202ee222222222ee202ee221111122ee200000000221111222eeeee200000000022111122222eee20000000002211111222eeee200aa909a90
2222111111122220222111111111222022221d7e7d122220000000001e77711111222000000000001e77711111222200000000001e117e1112222200a9999a9a
021ebb7e7bbe1200021ebb7e7bbe12000217117e7117120000000000071d7e777e12000000000000071d7e777712000000000000e7d17e7111120000aa0a099a
00e7cd7e7dc7e00000e7cd7e7dc7e000002e77eee77e2000000000000e11ee71d7e0000000000000ee11ee71d7e00000000000000e77ee7d17e0000099aaaa0a
000eccefecce0000000ecceeecce0000000eeefefeee000000000000efeeffe11e00000000000000efeeffe11e00000000000000efefefe77e00000009a0a999
000eeefffeee000000eeeefffeeee00000efffffffffe0000000000effffeffeee00000000000002fffffffeef00000000000000effffffee000000009999000
00efffffffffe0000efffffffffffe0000efffffffffe0000000002e2ffe2ff2f20000000000022effffeffffe00000000000002fffffffff000000000a00a00
00effffeffffe0002efffffefffffe2000efffffffffe000000002e2ffe2eff2e2000000000002ee2ffe2ff2ff20000000000022fffeffffe000000009aa09a0
02efeff2ffefe2002ee2efe2efe2ee2000fffff2fffff00000000222efe2efe22000000000000022ffe22eff2e2000000000002effe2ff2f20000000009a09a0
02e2efe2efe2e2002222efe2efe2222002f2efe2efe2f20000000002ef22ee22000000000000002effe02efe220000000000022ffe2eff2e00000000009aa0a0
0222efe0efe222000002ee202ee2000002e2efe2efe2e20000000002ee202200000000000000002ffe200220000000000000022efe2efe22000000009a09a0a9
0000ee202ee0000000002220222000000222efe0efe222000000000222000000000000000000000222000000000000000000002ef22ee2200000000099a0a99a
000022202220000000000000000000000000ee202ee000000000000000000000000000000000000000000000000000000000002ee2022000000000000999a9a9
00000000000000000000000000000000000022202220000000000000000000000000000000000000000000000000000000000022200000000000000000999990
000000000000000001d6767701d67677000000000000000000000000000000000000000003bb000000000000000000000cc10000000000000000000002880000
0000000000000000001d6676001d6676000000000000000000090900000909000bb3b000003b30000000a9000000a90000ccc00001cc10000882800000282000
80088680200886800001d6670001d667c0ccc0000d1cc000a0eaeee0a0eaeee0003b3bb000bb3bb0e0a915a0091a15a0001c1cc000cc1cc00028288000882880
88886818228868180d721d660d721d66cc6c1d00cd6c1d00a4aa491e9eaa9a19303bbd1bb03bbd1bfeee1190effe1190101ccd1cc01ccd1c20288d1880288d18
6868688868686888271721d6871721d6d0ddd00010ddd0009e49a94a4404e49e7377611337b7611390d6f6600f06f6607177611117c761117277f1122787f112
82dd8d20212d2d202d7d221d2d7d221d0000000000000000900090e0900900e0bd6d7b6676d777660000dd000006dd00cd6d7c6676d777668efe78ff7fe777ff
20082d0010122000080802018020802100000000000000000000000000000000600bb6d0d00dbdd0000000000000000060ccc6d0d00dcdd0f0888fe0e00e8ee0
000200000000000002020200200020200000000000000000000000000000000000b0dd000003dd0000000000000000000000dd000010dd000000ee000020ee00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e20000000000000eee0000000000000000b3100
00000000000e000000000000000000ee0000000ee0000000000000000000000000000000000000000eee000ee2002000000000eefffee00000000000003b3310
00000ee20eeffe02ee000000000000ee2000002ee0000000000000000000000000000000000000000eeeeefffe22e2000000eeefffff2ee0000000000003b310
00000eeeeefffeeeee0000000000000eeeeffeee000000000000000eeeeffeee00000000000000000eeeeffffeeee200000eeeffffffeeee00000000003b3310
000000ee2fffffeee0000000000000ee2fffffeee0000000000000ee2fffffeee00000000000000000eef2f2fe2ee200000e22ffffffe22e00000000003b3100
00000ee2effffff2ee00000000000ee2effffff2ee00000000000ee2effffff2ee000000000000000eef22f22eee200000022fffffffff2200000000003b3310
0000022eeeffffee2200000000000e2eeffffffe2e00000000000e2eeffffffe2e0000000000000222ffffffe2e200000002effffffffee200000000003b3310
000002eeffffffffe2000000000002eeeeffffeee200000000000e2eefffffff2e0000000000002eefff22f22ee20000002efffffffffeee20000000003b3100
00002eeefffffffffe20000000002eeefffffffffe20000000000e2eefffffff2e000000000002eefffff2f2feee2000002effffffffeeee20000000000b3100
00002eeefffffffffe20000000002eeefffffffffe200000000002eeeefffffee2000000000002e22222fffeeeee2000002eeee22222eeee2000000003b33100
00002eefffffffffee20000000002eefffffffffee20000000002eeefffffffffe2000000002222111122222eee22000022ee221111122ee2200000003b31000
0000222222222222222000000000222eeeeeeeee2220000000002eeefffffffffe2000000022e11222211111111200002f22221d7e7d17222f20000003b33100
00000211111111111200000000002122222222222120000000002eefffffffffee200000002ee121eee2222222200000fee277117e7117f22ef20000003b3100
000220e7117e7117ee2200000002ef11111111111fe20000000022eeefffffeee22000000002e2ee11eeeee2222200002fee2777e222f2e2eef2000003b33100
0002efee77eee77eefe200000002e22e711e117e22e20000000022eeeeeeeeee2220000000222ef22ee111ee22e2000002222eee2ee12e222f20000003b33100
0002efefeefffeefefe2000000022eeeeeeeeeeeee22000000021122eeeeeee22112000002feef21222eee102e200000002e22eeff111feef2000000003b3100
00022e2effefeffe2e2200000000222e22efe22e22200000002221122eeeee221122000002eefe111fffeefe22000000022efeeeff111efe22000000000b3100
0000222efef2fefe2220000000000022222222222000000000222211222222211222000000222e111fffffffe200000002efffff2ee2ee222220000003b33100
0000002eee222eee2000000000000002ee202ee200000000000222221111111122200000000002e2ee2f2feee200000002eee22f2222e2eef220000003b31000
000000022200022200000000000000000000000000000000000002ee222ee2eee200000000002eee22fff22220000000002222fff22eee2e2200000003b33100
0000000000000000000000000000000000000000000000000000022220222222200000000002effe02efff200000000000002fffe22effe220000000003b3310
0000000000000000000000000000000000000000000000000000000000000000000000000002ffe2002efe200000000000002efe22e2eff200000000003b3100
000000000000000000000000000000000000000000000000000000000000000000000000000022200002200000000000000000222eee222000000000003b3100
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222000000000000003b3310
eee0ee00e000e00000000000000eee00bbbbbbbbbbbbbbbbbbb1bbbbbbbebbbbbbebbebbbbbaaa9b000f0000fff1ffff000e000000fff00000031000003b3100
e0e0eee0e0e0e00000000000000ee000bbbbbbbbb8bbbb8bbb101bbbbbff2bbbbff2ff2bbbbaa9bb00fff000ff101fff00ff20000f000f00003b310000b31000
e0e0e000eeee0000f0fff00000ee00002222222bb28bb82bb10d01bbbfefe2bbfeefefe2bbaa9bbb0fffff00f10d01ff0fefe200f00f00f003bbb31003b33100
e0e0eee0e0ee0000ffffff0000eeee002aaaaa2bbb2882bb1000d01bb22222bb22222222bbaaaabb0fffff001000d01f02222200f0f0f0f03bbbbb31003b3100
0000000000000000f0fff0000000e0002a99992bbbb88bbb1000001bbb070bbbb071070bbbbba9bb00fff0001000001f00d7d000f00f0f00333b3331003b3100
000000000000000000000000000e0000b2a992bbbb8228bb1100011bbbfffbbbbff2fffbbbba9bbb0fffff001100011f00fff0000f000000000b3100003b3310
00000000000000000000000000e00000bb2a2bbbb82bb28bb11111bbbefefebbefeefefebba9bbbb0f0f0f00f11111ff0efefe0000ffff000003b100003b3100
00000000000000000000000000000000bbb2bbbbb2bbbb2bbbbbbbbbb2e2e2bb2e22e2e2bb9bbbbb00000000ffffffff02e2e20000000000000b3100003b3100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff000ff00f00f0ff00ff000f000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00f0f00f0f00f00000f0f00f000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00f0f00f0f00f00f00f00f0f000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00f0f00f00f00f00f0f000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000f00f0f00f00f00f00f0f000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00e00e0e00e00e00e00e0e000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0e00e0e00e00e00e00e00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00e0e00e0e00e00e00e00e00000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00e0e0e00e0ee00e00e00e0e000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000e0e00e0e00e00eee00e000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff00ff000ff000ff00ff000fff0f0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000f00f0f00f0f00f0f0f00f000f0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000f00f0f0000f00f0f00f0f000f0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000f0000f0000f00f0f00f0f000f0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f000f0000f00f0f00f0f000f0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee0000e00e0000eeee0eee00ee00e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000000e0e0000e00e0e0000e00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000e00e0e0000e00e0e0000e00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000e00e0e00e0e00e0e0000e000e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eee00ee000ee00e00e0e0000eee0e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff00f000ff00f00f0ffff0f000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00f00f0f00f00f000f000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00f0000f00f00f000f000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00f0000f00f00f000f000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000f00f0000f00f00f000f000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000e00e0ee0eeee00e000e000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000e00e00e0e00e00e0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000e00e00e0e00e00e0000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000e00e00e0e00e00e000e000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000e000eee0e00e00e000e000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c0301f03024030280300000028030000002b030260300000029030000002803000000240302403500000180301c0301f030240300000024030000002603023030000002603000000240302403024032
01100000180301c0301f030240300000024030000001c0302303000000260300000024030000001f0301f0350000013030180301c0301f030000001f03000000170301f0300000023030000001f0301f0301f032
012000181101021015210100e01021015210101301022015220100c01022015220100000000000000000000000000000001101021015210100e01021015210101301022015220100c0100e010100100000000000
011000001074500000177450000011745000000e74500000000001074517745117450e74500000000000000010745000001574500000117450000017745000000000010745117451374515745000000000000000
0110000000000000000000000000000000000000000000001a7151c7151d7151e71521710217102171500000187151a7151d7151f715237102371023715000001c7151f715207152371524710247102471500000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000e13010130141401615019170131701816014140121301113010130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000131300b1500b1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000151500c150111500f0600c0700d0600905008050060400304001030000300002001020010200301000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000170500000016050000001e05200000000000000000000200500000016050000001e052000000000000000170500000016050000001e05200002000000000000000000000000000000000000000000000
01040000151700c15011140111520c152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000155520c552115520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 01 02 43 44
01 03 42 43 44
02 03 05 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
