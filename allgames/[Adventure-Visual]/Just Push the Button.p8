pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--just push the button v0.9.0
--by gregory "elgregos" beal
--for the meta game jam 03/2018
--twitter: @gregosel

function _init()
-- poke(0x5f2d,1)
 fps=.5
 const_init()
 cfg={
  grid=false
 }
 game_init()
 dias_init()
 tckts_init()
 plyr_init()
 funcs_init()
 levs_init()
 gtm=0
 titl_bary=96
 tit_hko=false
 button_clk=false
-- test_init()
end

function _update60()
 plyr_action()
 for funcn=1,#lev.funcs do
  lev.funcs.action(lev.funcs[funcn])
 end
 gtm+=1
end

function _draw()
 lev_draw()
 plyr_draw()
 if cfg.grid then
  for cy=0,15 do
   for cx=0,15 do
    pset(cx*8,cy*8,0)
   end
  end
 end
 if(button_clk)return
 if func_is('dv_stats',_yes)then
  color(7) cursor(1,1)
  print('cpu:'..(flr(stat(1)*1000)/10)..'%')
  print('ram:'..flr(stat(0))..'k')
 end
end

function const_init()
--	pats={0x1248,0x36c9,0x7edb,0xffff}
-- _map=1
-- _tckt=2
-- _func=3
 _idle=1
 _walk=2
 _done=3
 
 --unused?
 _on=5
 _off=6

	_inherit="inherit"
	_no="no"
	_yes="yes"
 _noyes={_inherit,_no,_yes}
  
 plts={
  grey='015dd567d6766d67',
  dark='001121d62493d124',
  dkgr='001551d65d6dd5d6',
 }
 sprs_init()
end

--flr that ceils negative nbrs.
function flr2(n,e)
 f=10^(e or 0)
 return sgn(n)*flr(abs(n)*f)/f
end

function frnd(n)
 return flr(rnd(n))
end

function game_init()
-- game_set(_map)
end

function game_is(gn)
 return game==gn
end

function game_set(gn)
 game=gn
end

function last(tab)
 return tab[#tab]
end

function log(txt)
 if(true)return
 printh(txt)
end

--convert pixel to cell coord
function p2c(n)
 return flr(n/8)
end
--convert pixel to grid coord
function p2g(n)
 return p2c(n)*8
end

function pac_draw()
 local vbs={'open','pick up','push','close','look at','pull','give','talk to','use'}
 local xo,yo,h=1,104,8
 local ws={24,31,20}
 rectfill(0,yo,127,127,0)
 for y=0,2 do
  local px=xo
  for x=0,2 do
   local w=ws[x+1]
   local vb=vbs[y*3+x+1]
   local py=yo+y*h
--   px+=w/2+w-#vb*2
   rectfill(px-1,py-1,px+w-3,py+h-3,1)
   print(vb,px,py,3)
   px+=w
  end
 end
end

function plt_change(p)
 for n=1,#p do
  local i=sub(p,n,n)
  pal(n-1,"0x"..i)
 end
end

function plt_reset(pal_too)
 if(pal_too==nil)pal_too=true
 if(pal_too)pal()
 palt(0,false)
 palt(11,true)
end

function print2(t,x,y,i,k,typ)
 k=k or 0
 print(t,x-1,y,k)
 print(t,x,y-1)
 print(t,x+1,y)
 print(t,x,y+1)
 print(t,x,y,i)
end

function sprs_init()
 sprs={
  pointer=0,
  floor=31,
  tckts={6,7,8,9},
  swtchs={61,60},obsts={56,57,58,59},
  respwn={46,47},
  funcs={ui=1,gp=2,ct=3,dv=4},
  arrows={48,49,50,51},
 }
end

--tables functions
function tab_indof(t,e)
 for n=1,#t do
  if(t[n]==e)return n
 end
 return nil
end

function tab_isin(t,e)
 return tab_indof(t,e)!=nil
end

function test_init()
-- plyr.l=20
 funcs.ui_rpg.v=_yes
 funcs.gp_rspwn.v=_yes
-- funcs.ct_platform.v=_yes
-- funcs.ct_levloop.v=_yes
end

function txt_draw(txts)
 if(#txts==0)txts={txts}
 local tx={x=0,y=0,w=127,i=7,k=nil}
 for txtn=1,#txts do
  local txt=txts[txtn]
  tx.x=txt.x or tx.x
  tx.y=txt.y or tx.y
  tx.w=txt.w or tx.w
  tx.i=txt.i or tx.i
  tx.k=txt.k or tx.k
  txt.t=txt.t.." "
 	local ts,w={""},""
  for cn=1,#txt.t do
   local c=sub(txt.t,cn,cn)
   if c=="|" then
    add(ts,w)
    w=""
   else
    w=w..c
    if c==" "then
     if (#w+#ts[#ts])*4<=tx.w then
      ts[#ts]=ts[#ts]..w
     else
      add(ts,w)
     end
     w=""
    end
   end
  end
  if tx.k!=nil then
   rectfill(tx.x-1,tx.y-1,tx.x+tx.w-5,tx.y+#ts*6-1,tx.k)
  end
  for tn=0,#ts-1 do
   print(ts[tn+1],tx.x,tx.y,tx.i)
   tx.y+=7
  end
 end
end

-->8
--player
function plyr_action()
 local sx,sy=0,0
 plyr_xp_check()
 
 if tckt!=nil then
  if(btn(5))tckt_hide()

 elseif levfunc!=nil then
  local gf=levfunc.gf
  if gf.st==_idle then
   if(btnp(4))func_learn(gf)
  elseif gf.st==_walk then
   func_learn(gf)
  elseif gf.st==_done then
   if(btnp(0))func_changev(levfunc,-1)
   if(btnp(1))func_changev(levfunc,1)
   if btnp(4)then
    func_setv(levfunc)
    func_hide()
   end
  
  end
  if(btn(5))func_hide()
  
 else
  local res=plyr_checkcel()
  if not(res.typ==_walk and tab_isin({1,2},res.dr))then
   if(btn(0))plyr.vx=-1
   if(btn(1))plyr.vx=1
  end
  
  if func_is('ct_platform',_yes)then
   if lev_coll(plyr.x,plyr.y+1)
   and btn(2)
   then
    plyr.vy=-2.1
   end
   plyr.vy=min(64,plyr.vy+0.08)
   if lev_coll(plyr.x,plyr.y-1)and plyr.vy<0 then
    plyr.vy=0
   end
   sy=min(1,plyr.vy)
  else
   if not(res.typ==_walk and tab_isin({3,4},res.dr))then
    if(btn(2))plyr.vy=-1
    if(btn(3))plyr.vy=1
   end
  end
  if(btn(4))plyr_click()
 
  sx=plyr.vx
  sy=plyr.vy
  plyr.vx*=.83
  if func_is('ct_platform',_no)then
   plyr.vy*=.83
  end
  plyr.vx=flr2(plyr.vx,2)
  plyr.vy=flr2(plyr.vy,2)
  
  --out of screen?
  local xout=(plyr.x+sx)%128!=plyr.x+sx
  local yout=(plyr.y+sy)%128!=plyr.y+sy
  if xout then
   lev_exit(plyr,sx,0)
  elseif yout then
   lev_exit(plyr,0,sy)
  else
   --x coll?
 		if sx!=0 and lev_coll(plyr.x+sx,plyr.y)then
  		sx=0 plyr.vx=0
 		end
   --y coll?
 		if sy!=0 and lev_coll(plyr.x,plyr.y+sy)then
  		sy=0
  		if func_is('ct_platform',_yes)then
   		plyr.vy=-plyr.vy/3--bounce
  		else
   		plyr.vy=0--stop
  		end
 		end
   plyr.x+=sx plyr.y+=sy
  end
 end
end

function plyr_checkcel()
 local cel=lev_getcel(p2c(plyr.x),p2c(plyr.y))
 if cel==sprs.swtchs[1] then
  --switches
  lev_swapcels(sprs.swtchs)
  lev_swapcels({sprs.obsts[1],last(sprs.obsts)})
  sfx(8)
 elseif tab_isin(sprs.arrows,cel)then
  --arrows
  local dr=tab_indof(sprs.arrows,cel)
  if(dr==1)plyr.vx=-1
  if(dr==2)plyr.vx=1
  if(dr==3)plyr.vy=-1
  if(dr==4)plyr.vy=1
  return{typ=_walk,dr=dr}
 end
 return {typ=nil}
end

function plyr_click()
 if plyr.click.t>0 or tckt!=nil then
  return
 end
 local cx,cy=p2c(plyr.x),p2c(plyr.y)
 local cel=lev_getcel(cx,cy)
 
 if tab_isin(sprs.tckts,cel)then
  --show ticket
  tckt_show()
  
 elseif lev_istitle()then
  if plyr_inrect(98,15,111,40)then
   --fix title
   tit_hko=true
  elseif plyr_inrect(48,48,79,79)then
   --click button
   if func_is('ct_button',_yes)then
    button_clk=true
    music(0)
   else
    sfx(13)
   end
  end
  
 elseif plyr_onfunc()!=nil then
  --func
  func_show(plyr_onfunc())
 end
 
 plyr.click={
  x=plyr.x,y=plyr.y,t=20
 }
end

function plyr_draw()
 if(button_clk)return
 if tckt==nil and levfunc==nil then
  clk=plyr.click
  if clk.t>0 then
   local r=clk.t/4
   circ(clk.x,clk.y,r,0)
--   local gx,gy=p2g(plyr.x),p2g(plyr.y)
--   rect(gx-1,gy-1,gx+8,gy+8,10)
--   rect(gx-1-r,gy-1-r,gx+8+r,gy+8+r,10)
   clk.t-=4*fps
  end
  pal(7,0)
  spr(sprs.pointer,plyr.x-1,plyr.y,1,2)
  spr(sprs.pointer,plyr.x,plyr.y-1,1,2)
  spr(sprs.pointer,plyr.x+1,plyr.y,1,2)
  spr(sprs.pointer,plyr.x,plyr.y+1,1,2)
  pal()
  spr(sprs.pointer,plyr.x,plyr.y,1,2)
 end
 plyr_xp_show()
end

function plyr_getlearnspd(gf)
 local d=max(.5,gf.l-plyr.l)
-- if(d>=14)return -1
-- local spd=1/2^d
 local spd=1/d
 spd=mid(0,spd,8)
-- spd=8
 return spd
end

function plyr_init()
 plyr={
--  x=60,y=60,
  vx=0,vy=0,
  click={t=0},
  l=1,xp=0,
 }
end

function plyr_inrect(x1,y1,x2,y2)
 if plyr.x>=x1 and plyr.x<=x2
 and plyr.y>=y1 and plyr.y<=y2
 then
  return true
	end
	return false
end

function plyr_onfunc()
 return lev_func_find(p2c(plyr.x),p2c(plyr.y))
end

function plyr_respwn()
 local rspn=plyr_respwn_get()
 if rspn!=nil then
  plyr.x=rspn.cx*8
  plyr.y=rspn.cy*8
 end
end

function plyr_respwn_get()
 local dstmin,nrst=999,nil
 for rspn=1,#lev.respwns do
  local rsp=lev.respwns[rspn]
  local dst=sqrt((plyr.x-rsp.cx*8)^2+(plyr.y-rsp.cy*8)^2)
  if dst<dstmin then
   dstmin=dst
   nrst=rsp
  end
 end
 return nrst
end

function plyr_xp_add(xpa)
 plyr.xp+=xpa
end

function plyr_xp_check()
 if plyr.xp>plyr_xp_getmax() then
  plyr.l+=1
  plyr.xp-=plyr_xp_getmax()
 end
end

function plyr_xp_getmax()
 return plyr.l*100
end

function plyr_xp_show()
 if(not func_is('ui_rpg',_yes))return
 local xo,yo,lt=117,2,plyr.l..""
-- lt="12"
 local xt=xo+4-#lt*2
-- plyr.xp=plyr_xp_getmax()
 local xp=mid(0,flr(11*plyr.xp/plyr_xp_getmax()),11)
 rectfill(xo-3,yo-1,xo+9,yo+7,7)
 line(xo-2,yo+6,xo+8,yo+6,6)
 if(xp>0)line(xo-2,yo+6,xo-2+xp-1,yo+6,12)
 print(lt,xt,yo,12)
end

-->8
--levels

function lev_change(mx,my)
 mx%=4 my%=4
 plyr.click.t=0
 lev_init(mx,my)
end

function lev_cls(pat)
 if pat!=nil then
  fillp(pat)
  rectfill(0,0,127,127,lev.k*16)
  fillp()
 else
  rectfill(0,0,127,127,lev.k)
 end
end

function lev_coll(px,py)
 local cel=lev_getcel(p2c(px),p2c(py))
 return cel==0 or fget(cel,0)
end

function lev_draw()
 if tckt!=nil
 or levfunc!=nil
 then
  if lev.k==1 then
   lev_cls(0x8421)
   plt_change(plts.dkgr)
  else
   plt_change(plts.dkgr)
   lev_cls()
  end
 else
  lev_cls()
 end
 plt_reset(false)
 map(lev.mx*16,lev.my*16,0,0,16,16)

 if func_is('gp_rspwn',_yes) then
  local rspwn=plyr_respwn_get()
  if rspwn!=nil then
   spr(sprs.respwn[2],rspwn.cx*8,rspwn.cy*8)
  end
 else
  for rn=1,#lev.respwns do
   local r=lev.respwns[rn]
   spr(sprs.floor,r.cx*8,r.cy*8)
  end
 end
 if lev.mx==1 and lev.my==2 then
--  pac_draw()--point and click
 end
 pal()
 
 if(lev_istitle())titl_draw()
 
 for lfn=1,#lev.loc_funcs do
  local lf=lev.loc_funcs[lfn]
  lev.funcs.draw(lf)
 end
 if tckt!=nil then
  tckt_draw()
 end
 if levfunc!=nil then
  func_draw()
 end
end

function lev_exit(obj,sx,sy)
-- sx,sy=flr(sx),flr(sy)
 local lsx,lsy=mid(-1,sx,1),mid(-1,sy,1)
 local levloop=func_is('ct_levloop',_yes)
	--on x
 if lsx!=0 then
  local loopx=false
  if not levloop or lev_coll((obj.x+sx)%128,obj.y)then
   if not lev_coll(obj.x+sx,obj.y)then
    --next x level
    lev_change(lev.mx+sgn(lsx),lev.my)
    loopx=true
   else
    plyr.vx=0
   end
  else
   --level x loop
	  loopx=true
   lev_subset(lev.mx,lev.my,lsx,lsy)
  end
  if loopx then
   obj.x=0 if(lsx<0)obj.x=127
  end
 end
 
	--on y
 if lsy!=0 then
  local loopy=false
  if not levloop or lev_coll(obj.x,(obj.y+sy)%128)then
   if not lev_coll(obj.x,obj.y+sy)then
    --next y level    
    lev_change(lev.mx,lev.my+sgn(lsy))
    loopy=true
   else
    plyr.vy=0
   end
  else
   --level y loop
   loopy=true
   lev_subset(lev.mx,lev.my,lsx,lsy)
  end
  if loopy then
   obj.y=0 if(lsy<0)obj.y=127
  end
 end 
end

function lev_findcel(cel)
 cel_coors={}
 for cy=0,15 do
  for cx=0,15 do
   local cf=mget(lev.mx*16+cx,lev.my*16+cy)
   if cf==cel then
   	add(cel_coors,{cx=cx,cy=cy})
   end
  end
 end
 return cel_coors
end

function lev_func_find(cx,cy)
 for fn=1,#lev.loc_funcs do
  local f=lev.loc_funcs[fn]
  if(f.cx==cx and f.cy==cy)return f
 end
 return nil
end

function lev_funcs_init()
 if(lev.loc_funcs==nil)lev.loc_funcs={}
 lev.funcs={}
 for lfn=1,#lev.loc_funcs do
  local lf=lev.loc_funcs[lfn]
  if lf.cx!=nil then
   lf.cx%=16 lf.cy%=16
  end
  lev.funcs[lf.f]=lf.v
 end
 
 function lev.funcs:action()
  local func=self
  if func.st==_idle then
   if rnd()<.01 then
--    lev.funcs.walk(self)
   end
  end
 end

 function lev.funcs:draw()
  if self.cx!=nil and self.cy!=nil then
   local s=1+time()%4
   if(self.g)s+=16
   local p=sprs.funcs[sub(self.f,1,2)]
   if(p==2)pal(10,15)pal(11,6)pal(12,13)pal(13,5)
   if(p==3)pal(11,9)pal(12,14)pal(13,4)
   if(p==4)pal(7,12)pal(10,12)pal(11,5)pal(12,1)pal(13,0)
   spr(s,self.cx*8,self.cy*8)
   pal()
--   print(p,self.cx*8,self.cy*8-7,7)
  end
 end
 
end

function lev_getcel(cx,cy)
 return mget((lev.mx*16+cx)%64,(lev.my*16+cy)%64)
end

function lev_init(mx,my)
 log('level:'..mx..','..my)
 lev=levs[mx+1][my+1]
 levfunc=nil
 tckt=nil
 lev.typ=lev.typ or _top
 lev.mx,lev.my=mx,my
-- lev.k,lev.i=2,15
-- lev.k,lev.i=5,14
-- lev.k,lev.i=3,9
 if(lev.funcs==nil)lev_funcs_init()
-- lev.k=1
-- if(func_is('ct_platform',_yes))lev.k=0
-- if(lev.typ==top)plyr.vy=0
 lev_subinit(lev.mx,lev.my)
 lev.respwns=lev_findcel(sprs.respwn[1])
 if plyr.x==nil then
  plyr.x,plyr.y=100,60
  plyr_respwn()
 end
 menu_init()
end

function lev_istitle()
 return (lev.mx==0 and lev.my==0)
end

function lev_subget(x,y)
 return levsubs[x+1][y+1]
end

function lev_subinit(x,y)
 if(levsubs[x+1]==nil)levsubs[x+1]={}
 if(levsubs[x+1][y+1]!=nil)return
 levsubs[x+1][y+1]={x=0,y=0}
end

function lev_subset(x,y,sx,sy)
-- lev_subinit(x,y)
 sb=levsubs[x+1][y+1]
 sb.x=(sb.x+sx)%10
 sb.y=(sb.y+sy)%10
end

function lev_swapcels(cels)
 local cel_coors={
  lev_findcel(cels[1]),
  lev_findcel(cels[2])
 }
 for cn=1,2 do
  for coorn=1,#cel_coors[cn] do
   local coor=cel_coors[cn][coorn]
   mset(lev.mx*16+coor.cx,lev.my*16+coor.cy,cels[3-cn])
  end
 end
end

function levs_init()
 levs={
  {--x=0
   {--0,0
    loc_funcs={
--	    {cx=5,cy=5,f='dv_stats',v=_no},
    }
   },
   {--0,1
   },
   {--0,2
   },
   {--0,3
    loc_funcs={
	    {cx=5,cy=14,f='ct_platform',v=_yes},
    },
   }
  },
  {--x=1
   {--1,0
   },
   {--1,1
    loc_funcs={
	    {cx=5,cy=5,f='ct_platform',v=_yes},
    }
   },
   {--1,2
   },
   {--1,3
   }
  },
  {--x=2
   {--2,0
    k=1,
    loc_funcs={
	    {cx=3,cy=5,f='ui_rpg',v=_inherit},
	    {cx=5,cy=5,f='gp_rspwn',v=_inherit},
	    {cx=7,cy=5,f='ct_levloop',v=_inherit},
	    {cx=11,cy=5,f='ct_platform',v=_inherit},
	    {cx=3,cy=3,f='dv_stats',v=_inherit},
	    {cx=5,cy=3,f='ui_snd',v=_inherit},
	    {cx=7,cy=3,f='ui_monit',v=_inherit},
	    {cx=9,cy=3,f='ui_unknown',v=_inherit},
	    {cx=11,cy=3,f='ct_slide',v=_inherit},
	    {cx=3,cy=7,f='dv_optim',v=_inherit},
	    {cx=5,cy=7,f='dv_boost',v=_inherit},
    },
   },
   {--2,1
    k=0,
    tckts=tckts.scope,
    loc_funcs={
	    {cx=35,cy=30,f='ct_platform',v=_yes},
	    {g=true,cx=43,cy=26,f='ct_slide'},
    },
   },
   {--2,2
    tckts=tckts.close,
    loc_funcs={
	    {cx=45,cy=36,f='ct_platform',v=_yes},
	    {cx=44,cy=46,f='ct_levloop',v=_yes},
    },
   },
   {--2,3
    loc_funcs={
	    {cx=5,cy=5,f='ct_platform',v=_yes},
    },
   }
  },
  {--x=3
   {--3,0
    k=1,
    tckts=tckts.useless,
    loc_funcs={
	    {g=true,cx=8,cy=8,f='ct_button'},
    },
   },
   {--3,1
    k=1,
    tckts=tckts.ui_xp,
    loc_funcs={
	    {g=true,cx=56,cy=21,f='ui_rpg'},
	    {g=true,cx=53,cy=29,f='gp_rspwn'},
	    {cx=50,cy=26,f='ct_levloop',v=_inherit},
    },
   },
   {--3,2
    tckts=tckts.types,
    loc_funcs={
	    {cx=52,cy=46,f='ct_platform',v=_yes},
	    {cx=4,cy=1,f='dv_hide',v=_inherit},
	    {cx=8,cy=7,f='dv_minify',v=_inherit},
	    {cx=4,cy=11,f='dv_crypt',v=_inherit},
	    {cx=3,cy=11,f='dv_protect',v=_inherit},
	    {cx=5,cy=11,f='dv_ram',v=_inherit},
	    {cx=6,cy=11,f='dv_ui',v=_inherit},
    },
   },
   {--,3,3
   }
  }
 }
 levsubs={}--infos (x,y) of sublevel
 lev_init(0,0)
end

-->8
--tickets
function tckt_draw()
 local tw,th=88,88
 local x1,y1,x2,y2=64-tw/2,64-th/2,63+tw/2,63+th/2
 ui_box(x1,y1,x2,y2,9,7,"close")
 txt_draw({t=tckt,i=2,x=x1+2,y=y1+2,w=x2-x1})
end

function tckt_hide()
 tckt=nil
end

function tckt_show()
 tckt=lev.tckts
end

function tckts_init()
 tckts={
  useless="most of those notes are useless. you'll figure out all by yourself. nobody remembers who wrote them anyway. ||but you don't have to trust me.",
  scope="global functions have legs and affect all the game. ||local functions have no leg and affect current screen only. ||local functions overshadow global ones.",
  ui_xp="your stats show your ability to read code. you'll have no problem learning functions that fit your ability, but you won't gain a lot of experience. which is shown by the little bar below.",
  close="if a function takes too much time to learn, you can close it at any time. what you've learn won't be lost.",
  types="functions have many types, each one having its own color: ui (user interface) is blue, controls is pink, gameplay is grey, development functions are dark blue with deep blue eyes.",
 }
end

-->8
--menus & dialogues
function dias_init()
 dias={
  t="i don't know why the button didn't react. maybe you should explore more and see if you get any info. sorry for the trouble."
 }
end

--pico-8 "enter" menu
function menu_init()
 menuitem(1,"respawn",function()plyr_respwn()end)
 if plyr_respwn_get()==nil
 or func_is('gp_rspwn',_no)
 then
  menuitem(1)
 end
end

function ui_box(x1,y1,x2,y2,k,bi,tx,tc)
 rectfill(x1-1,y1-1,x2+1,y2+7,0)
 rectfill(x1,y1,x2,y2,k)
 if(tx!=nil)print('—'..tx,x1,y2+2,bi)
 if(tc!=nil)print('Ž'..tc,x2-#tc*4-6,y2+2,bi)
end

-->8
--title screen

function titl_bar_draw()
 local yo=titl_bary
 rectfill(0,yo,128,yo+8,0)
 if button_clk then
  local txt="thanks for playing"
  local x=64-#txt*2
  print(txt,x,yo+2,8)
 else
  shortgame="an incredibly short game"
  local txts={
   '"just push the button"',
   shortgame,
   "use arrow keys to move pointer",
   "use Ž/c for any action",
   "say, like, pushing the button",
   "sorry, had no time for a tutorial",
   "it was a game jam, you know",
   "so you'll have no preparation",
   "don't rush",
   "there's electricity involved",
   "but you can press enter for help",
   "if i have time to add this",
   "nuff talking, it's time to play",
   '"just push the button"',
   shortgame,
   "well, a bit less short now",
   "if you're stuck, press Ž/c",
   "(yes, you know, for any action)",
   "press it anytime, anywhere",
   "with joy, anger or despair",
   "it might give results",
   "",
   "still here?",
   "",
   "well, if you're still stuck",
   "can you do me a favor?",
   "the title's \"h\" has a problem",
   'it really spoils the effect',
   "can you fix it for me, please?",
   "yeah, maybe you already did that",
   "in which case, why this message?",
   "well, i'm just a scrolltext",
   "but still, hurray!",
   "there's a game to play!",
  }
  local txt=txts[(flr(gtm/256))%#txts+1]
  local x=128-gtm%256
  -- if(gtm%(256+pau)>pau)x=64-#txt*2
  -- print(txt,x,yo+2,4)
  print(txt,x,yo+2,4)
 end
end

function titl_butn_draw(butn)
 if button_clk then
  --butn shape
--  rectfill(butn.x,butn.y+8,butn.x+31,butn.y+butn.h+31-8,4)
--  rectfill(butn.x+8,butn.y+8,butn.x+23,butn.y+butn.h+31)
--  plt_reset()
--  pal(7,4) pal(15,14)
--  spr(64,butn.x,butn.y+butn.h+32-8,1,1,true,true)
--  spr(64,butn.x+24,butn.y+butn.h+32-8,1,1,false,true)
  plt_reset()
  rectfill(butn.x+8,butn.y,butn.x+31-8,butn.y+31,0)
  rectfill(butn.x,butn.y+8,butn.x+31,butn.y+31-8)
  pal(7,0)pal(15,2)
  spr(64,butn.x,butn.y,1,1,true)
  spr(64,butn.x+24,butn.y)
  spr(64,butn.x,butn.y+24,1,1,true,true)
  spr(64,butn.x+24,butn.y+24,1,1,false,true)
  --butn picto
  butn.y+=1
--  pal(15,10) pal(9,11)
  pal(6,2)pal(9,2)pal(10,2)pal(12,8)pal(15,1)
  spr(80,butn.x+8,butn.y+8,1,1,true,true)
  spr(80,butn.x+16,butn.y+8,1,1,false,true)
  spr(80,butn.x+8,butn.y+16,1,1,true)
  spr(80,butn.x+16,butn.y+16)
  rectfill(butn.x+13,butn.y,butn.x+18,butn.y+16,0)
  rectfill(butn.x+15,butn.y+5,butn.x+16,butn.y+14,8)
 else
  --butn shape
  rectfill(butn.x,butn.y+8,butn.x+31,butn.y+butn.h+31-8,4)
  rectfill(butn.x+8,butn.y+8,butn.x+23,butn.y+butn.h+31)
  plt_reset()
  pal(7,4) pal(15,14)
  spr(64,butn.x,butn.y+butn.h+32-8,1,1,true,true)
  spr(64,butn.x+24,butn.y+butn.h+32-8,1,1,false,true)
  plt_reset()
  rectfill(butn.x+8,butn.y,butn.x+31-8,butn.y+31,7)
  rectfill(butn.x,butn.y+8,butn.x+31,butn.y+31-8,7)
  spr(64,butn.x,butn.y,1,1,true)
  spr(64,butn.x+24,butn.y)
  pal(15,6)
  spr(64,butn.x,butn.y+24,1,1,true,true)
  spr(64,butn.x+24,butn.y+24,1,1,false,true)
  --butn picto
  butn.y+=1
  pal(15,10) pal(9,11)
  spr(80,butn.x+8,butn.y+8,1,1,true,true)
  spr(80,butn.x+16,butn.y+8,1,1,false,true)
  spr(80,butn.x+8,butn.y+16,1,1,true)
  spr(80,butn.x+16,butn.y+16)
  rectfill(butn.x+13,butn.y,butn.x+18,butn.y+16,7)
  rectfill(butn.x+15,butn.y+5,butn.x+16,butn.y+14,12)
 end
end

function titl_draw()
 local butn={x=48,y=48,h=4}
 if button_clk then
  cls(8)
  titl_butn_draw(butn)
  titl_titl_draw()
  titl_bar_draw()
  plt_reset()
  print('by gregory beal',3,120,2)
  pal(12,0)
  spr(96,83,120)
  print('@gregosel',90,120,2)
 else
  titl_butn_draw(butn)
  titl_part_draw()
  titl_titl_draw()
  titl_bar_draw()
  plt_reset()
  print('by gregory beal',3,120,4)
  spr(96,83,120)
  print('@gregosel',90,120,13)
 end
 pal()
end

function titl_let_draw(let)
 --1st char=width
 local tls={
  j="137a",u="233778a",s="20e82ca",
  t="117b",p="2024ab ",h="23346bb"
 }
 local l=tls[let.l]
 if l!=nil then
  let.sp=sub(l,1,1)
  for sn=0,#l-2 do
   local s=sub(l,sn+2,sn+2)
   if s!=" "then
    local sp="0x"..s
    sp=65+16*flr(sp/4)+sp%4
    local x=let.x+(sn%let.sp)*8
    local y=let.y+flr(sn/let.sp)*8
    spr(sp,x,y)
   end
  end
 end
end

function titl_part_draw()
 if parts!=nil then
  for partn=1,#parts do
   local part=parts[partn]
   pset(part.x,part.y,part.c)
   if part.c>4 or part.y<titl_bary-1 then
    part.y=min(130,part.y+part.vy)
    if part.y<130 then
     part.x+=part.vx
     part.vx*=.99
     part.vy*=1.1
    end
   else
    part.x-=1
    part.y=titl_bary-1
   end
  end
 end
end

function titl_part_launch(x,y,hko)
 parts={}
 local nmax=5+frnd(15)
 if(hko)nmax*=3
 for n=1,nmax do
  part={
   x=x,y=y,
   vx=rnd()-.5,vy=rnd(.8)+.1,
   c=frnd(3)
  }
  if(not hko)part.c=frnd(2)*3+7
  if(part.c==1)part.c=4
  add(parts,part)
 end
end

function titl_titl_draw()
 local hko=tit_hko
 local tit="just push"
 local x,yo=17,15
 plt_reset()
 palt(4,true)
 if not button_clk then
  pal(2,4)pal(1,2)
 end
 for letn=1,#tit do
  local l=sub(tit,letn,letn)
  if l!=" "then
   if(l=="t")x+=2
   local y=0
   if gtm%200<=100 then
    y=gtm-(letn+2.5)*10
    if hko or l!="h" then
     y=sin((y)/100)*35-28
    else
     y=sin((y)/100)*10-8
    end
   end
   y=max(yo,yo+y)
   if button_clk then
    y=yo
   else
    if(not hko and l=="h")y+=rnd(2)-1
    if gtm%200>=80 and gtm%200<=82 and l=="h" then
     if hko then
      sfx(9)
 	   else
 	    sfx(10)
 	   end
     titl_part_launch(x+8,y+15,hko)
    end
   end
   let={x=x,y=y,l=l}
   titl_let_draw(let)
   x+=(let.sp-1)*8+4
  else
   x+=10
  end
 end
 pal()
end

-->8
--functions (ingame)

function func_changev(func,sv)
 local vn=tab_indof(func.gf.vs,func.cv)
 local cvn=(vn-1+sv)%#func.gf.vs
 func.cv=func.gf.vs[cvn+1]
end

function func_draw()
 local tw,th=100,96
 local x1,y1,x2,y2=64-tw/2,64-th/2,63+tw/2,63+th/2
 local i,i2,k=11,3,1
 local lf=levfunc.lf
 local gf=levfunc.gf
 local tx,tc="close",nil
 if(gf.st==_done)tx,tc="abort","confirm"

 ui_box(x1,y1,x2,y2,k,12,tx,tc)
 rectfill(x1,y1,x2,y1+26,i2)
 cursor(x1+2,y1+2)color(k)
 local sc=lf.g and 'global' or 'local'
 print('scope:'..sc)
 print('type:'..func_gettyp(lf.f))
 print('complexity:'..gf.l)
 if(gf.st==_walk)color(i)
 print('learnt:'..(flr(gf.k*100)/100)..'%')
 color(k)
 txt_draw({t='i '..gf.d,i=i,x=x1+2,y=y1+29,w=x2-x1})

 if gf.st==_idle then
  rectfill(x1+5,y2-15,x2-5,y2-5,i2)
  print("press Ž/c to learn",x1+12,y2-12,k)
  
 elseif gf.st==_walk then
  local r100=x2-x1-14
  local r=gf.k/100*r100
  rectfill(x1+7,y2-13,x2-7,y2-7,i2)
  rectfill(x1+7,y2-13,x1+7+r,y2-7,i)
  rect(x1+5,y2-15,x2-5,y2-5,i2)
  local inf='learning function'
  local sk=plyr_getlearnspd(gf)
  if(sk<0)inf='function too complex!'
  print(inf,64-#inf*2,y2-12,k)
  
 else
  local t=levfunc.cv
  rect(x1+5,y2-15,x2-5,y2-5,i2)
  print("‹",x1+8,y2-12)
  print("‘",x2-14,y2-12)
  if not gf.on then
   local t2='not implemented yet'
   rectfill(x1+5,y2-23,x2-5,y2-15,i2)
			print(t2,64-#t2*2,y2-21,k)
   print(t,64-#t*2,y2-12,i2)
		else
   print(t,64-#t*2,y2-12,i)
  end
 end
end

function func_gettyp(f)
 local t=sub(f,1,2)
 if(t=='ct')return 'controls'
 if(t=='gp')return 'gameplay'
 if(t=='dv')return 'development'
 return t
end

function func_getv(f)
 local v=funcs[f].v
 if lev.funcs[f]!=nil then
  vt=lev.funcs[f]
  if(vt!=_inherit)v=vt
 end
 return v
end

function func_hide()
 levfunc=nil
end

function func_is(f,v)
 return func_getv(f)==v
end

function func_learn(gf)
 if(gf.st==_done)return
 if gf.st==_idle then
  gf.st=_walk
 elseif gf.st==_walk then
  local sk=plyr_getlearnspd(gf)
  gf.k=mid(0,gf.k+sk,100)
  if gf.k==100 then
   local d=mid(-1,gf.l-plyr.l,13)
--   local xpa=2^(d/4)*50
   local xpa=(d+2)*5*gf.l
   plyr_xp_add(xpa)
   gf.st=_done
  end
 end
end

function func_setv(func)
 if func.lf.g then
  func.gf.v=func.cv
 else
  func.lf.v=func.cv
 end
 lev.funcs=nil
 lev_init(lev.mx,lev.my)
end

function func_show(f)
 local gf=funcs[f.f]
 gf.st=_idle--func state
-- gf.k=100
 levfunc={
  lf=f,--local func
  gf=gf,--global func
  cv=f.v,--current value
 }
 if(f.g)levfunc.cv=gf.v--if f is global
 if(gf.k>0)gf.st=_walk
 if(gf.k>=100)gf.st=_done
end

function funcs_init()
 --l=level,d=description,vs=values
 funcs={
  ui_rpg={l=1,d="enhance the rpg flavor with tiny stats showing up/right.",vs=_noyes,v=_no,cpu=5,ram=50,k=0,on=true},
  gp_rspwn={l=1,d="add respawn points. press enter to go to nearest one. never be lost again!",vs=_noyes,v=_no,ram=10,k=0,on=true},
  ct_levloop={l=5,d="join inner screen exits instead of outer screens if possible. that's 50% more puzzling.",vs=_noyes,v=_no,k=0,on=true},
  ct_button={l=20,d="make the button clickable. i wonder why anybody set me off. people get sued for less.",vs=_noyes,v=_no,k=0,on=true},
  ct_platform={l=10,d="set controls for a platformer instead of a top-down game.",vs=_noyes,v=_no,k=0,on=true},
  dv_stats={l=2,d="show cpu & ram stats. feel like a real dev!",vs=_noyes,v=_no,cpu=1,k=0,on=true},
  
  ui_snd={l=3,d="trigger sounds to enhance your playing experience.",vs=_noyes,v=_yes,ram=50,k=0,on=false},
  ui_monit={l=7,d="turn your screen into those old monochrome monitors. because retro is bestro.",vs={_inherit,"color","green","grey"},v="color",k=0,on=false},
  ui_unknown={l=8,d="put a question mark above each unknown function head. more useful than a hat.",vs=_noyes,n=_no,k=0,on=false},
  ct_slide={l=5,d="ease out pointer before it stops. nice but slippery.",vs={_inherit,'none','a bit','normal','a lot','glissandooo'},v='normal',k=0,on=false},
  dv_optim={l=10,d="set some code optimizations to use less cpu. but it uses more ram.",vs=_noyes,v=_no,ram=100,k=0,on=false},
  dv_boost={l=13,d="add some black magic to clip cpu use and keep at 60 fps as much as possible",vs=_noyes,v=_yes,ram=250,k=0,on=false},
  dv_hide={l=18,d="hide all functions around. you know, for security reasons. this doesn't affect myself though.",vs=_noyes,v=_yes,cpu=5,k=0,on=false},
  dv_minify={l=12,d="minify code so that it's hard to read",vs=_noyes,v=_yes,cpu=3,k=0,on=false},
  dv_crypt={l=17,d="obfuscate code so that no one can read that, not even devs!",vs=_noyes,v=_yes,cpu=3,k=0,on=false},
  dv_protect={l=15,d="close other functions api. you may read their description, but not set them.",vs=_noyes,v=_yes,cpu=10,k=0,on=false},
  dv_ram={l=19,d="annex a part of that cute ssd to emulate almost infinite ram!",vs=_noyes,v=_no,k=0,on=false},
  dv_ui={l=5,d="change colors of that dev ui. enough of those old greens, bring modern colors!",vs=_noyes,v=_no,k=0,on=false},
 }
end
__gfx__
70000000000000000000000000000000000000000000000000000000444444444444444444444444bbbbbbb0bbbbbbb022222222222222219999999900000000
7700000000bab00000bab00000000000000000000000000000000000ccccccc4eeeeeee4aaaaaaa4bbbbbb00bbbbbb0022222222222222219999999900000000
777000000cbbbc000cbbbc0000bab00000bab0000000000000000000c1c111c4e222eee4a44a44a4bbbbbbb0bbbbbbb022222222222222119999999900000000
777700000ccccc000ccccc000cbbbc000cbbbc000000000000000000ccccccc4eeeeeee4aaaaaaa4bbbbbb00bbbbbb0000000000000000009999999900000000
777770000c7c7c000ccccc000ccccc000ccccc000000000000000000c11c1cc4e2e22ee4a444a4a4bbbbbbb0bbbbbbbb0b0000b00b000b009999999900000000
777777000cdcdc000ddcdd000c7c7c000ccccc000000000000000000ccccccc4eeeeeee4aaaaaaa4bbbbbb00bbbbbb0bbbbbbbbbbbbbbbb09999999900000000
777700000ccccc000ccccc000cdcdc000ddcdd000000000000000000c111ccc4e22eeee4a44a4aa4bbbbbb00bbbbbbbbb0bb000bb0bb00004444444400000000
7007000000ccc00000ccc000ccccccc0ccccccc00000000000000000ccccccc4eeeeeee4aaaaaaa4bbbbbbb0bbbbbbbbbbbbbbbbbbbbbbb02222222200000000
0007700000000000000000000000000000000000000000000000000000000000000000000000000099999999eeeeeeee10000000777777779999999944444444
0000700000baab0000baab0000000000000000000000000000000000000000000000000000000000222222225555555510000000777777779999999944444444
000000000ccbbcc00ccbbcc000baab0000baab000000000000000000000000000000000000000000111010110000000010000000777777779999999944444444
000000000c7cc7c00cccccc00ccbbcc00ccbbcc00000000000000000000000000000000000000000001000100000000000000000777777779999999944444444
00000000ccdccdcccddccddc0c7cc7c00cccccc00000000000000000000000000000000000000000101111100000000010000000777777779999999944444444
00000000ccccccccccccccccccdccdcccddccddc0000000000000000000000000000000000000000100000000000000010000000777777779999999944444444
00000000c0c00c0cc0c00c0ccccccccccccccccc0000000000000000000000000000000000000000101010100000000011101011777777779999999944444444
0000000000c00c0000c00c00c0c00c0cc0c00c0c0000000000000000000000000000000000000000000000000000000000100010777777779999999944444444
00000000000000000000000000000000000000004444422222222222444444424444444444444444444444444000000444444444444444444444444444444444
00000000000000000000000000000000000000004444422222222222444444224444444444444444444444444000000442222224422222244424444444944444
00000000000000000000000000000000000000004444422222222222444442224444444444444444440000444000000442eeee2442aaaa244422444444994444
00000000000000000000000000000000000000004444422244444222444442224441144444400444440000444000000442444424429999244422244444999444
00000000000000000000000000000000000000004444422244444222444442224441144444400444440000444000000442444424429999244422224444999944
00000000000000000000000000000000000000004444422244444222444442224444444444444444440000444000000442444424429999244424244444949444
00000000000000000000000000000000000000004444422244444222444442224444444444444444444444444222222442222224421001244444424444444944
00000000000000000000000000000000000000004444422244444222444442224444444444444444444444444422224444444444442112444444444444444444
44444444444444444444444444444444000000004444422222222222222222224444444444444444444444444444444444444444444444440000000011111111
44449444449444444444444444444444000000004444422222222222222222244444444442222214422222144222221442222224429999240000000011111111
44494444444944444449444444444444000000004444422222222222222222444444444442221214422212144222121442444424429999240000000011111111
44944444444494444494944449444944000000004444444444444444444444444441144444444214412121144121211442444424429999240000000011111111
44494444444944444944494444949444000000004444444444444444444444444440044444444214411110044111100442444424429999240000000011111111
44449444449444444444444444494444000000004444444444444444444444444444444444411214422221044101010442444424424444240000000011111111
44444444444444444444444444444444000000004444444444444444444444444444444444411214422221044000000442222224422222240000000011111111
44444444444444444444444444444444000000004444444444444444444444444444444444444444444444444444444444444444444444440000000011111111
7777fbbb444444444444444444444444444444440077700000007700000000000000000000000000000000000000000000000000000000000000000000000000
777777bb444444444444444444444444444444440700070000070070000000000000000000000000000000000000000000000000000000000000000000000000
7777777b444442000000000000244444444004447000007000700707000000000000000000000000000000000000000000000000000000000000000000000000
7777777f444400000000000000004444444004447000007000700007000000000000000000000000000000000000000000000000000000000000000000000000
77777777444200122220022221002444444004440700070000070070000000000000000000000000000000000000000000000000000000000000000000000000
77777777444001222220022222100444444004440077700000007700000000000000000000000000000000000000000000000000000000000000000000000000
77777777444002222220022222200444444004440077700000007700000000000000000000000000000000000000000000000000000000000000000000000000
77777777444002444440044444200444444004440007000000007700000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb6cc444004444440044444400444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb9cc444004444440044444400444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbcc9444000000000000000000444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb6cca444000000000000000000444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb6cccb444002222220022222200444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
69ccccfb444002222220022222200444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccfbb444002222220022222200444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc9abbbb444004444440044444400444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cbbcccbb444004444440044444400444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccbbb444100444440044444001444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bccccbbb444200000000000000002444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbcccbbb444221000000000000122444444004440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bcccbbbb444422222222222222224444444224440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb444422222222222222224444444224440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb444442222222222222244444444224440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444000000000000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444000000000000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444222222222222222222444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444222222222222222222444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444222222222222222222444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000f1f1f15200000052000000005200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000e2f1f15200000052000000005363636363636200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000c36373f1f1f1520000735362000000b1b1b1b1b1235200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000b30000f1f1f1520000f1f1520000000000000000235200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000f16200f1f1f1520000f1f1520000000000000000235200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000d35200f1f1f1520000b1b1b10000000000000000235200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000835200f1f1f15200000000000000000000000000235200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000f15200f1f1f15363636363636363636363636373e25200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000c3520000f172b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b100000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000b3520000f1520000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000f1520000f1520000636363620000636363636363636200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000d3520000f1520000f1f1e2520000f1f1f1f1f1f1f15200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000083520000f1520000f1f1f1520000f17200000000f15200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000f1520000f1520000f1f1f1520000f15200636200f15200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000805363e2f1520000f1f1f1536373f15200f15200905200000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000f1520000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000001010101000000000000000000000000010101000000000000000000000001010101000000000000000000000000000101010000000000010101010000000000000000000000000101010100000000000000000000000001010101000000000000000000000000010101000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e000000000000000000000000000000000000000000000000000000000000000000000a1f1f1f1f1e1e1f1f1f1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0000000000000000000000000000000000000a1f1f1f1f1f1f1f1f1f00000000000a1f1f1f1f1f1e1e1f1f1f1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000000000a1f1f1f1f1f1f1f1f1f1f1f0000000a1f1f1f0c0c0d1e1e0c0c0d1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000000000a1f1f1f1f1f1f1f1f1f1f1f0000000a1f1f0c00000a1e1e00000b0d1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000000000a1f1f1f1f1f1f1f1f1f1f1f0000000a1f1f000a1e1e1e1e1e1e000a1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000000000a1f1f1f1f1f1f1f1f1f1f1f0000000a1f1f000a1e1d1d1d1d1e000a1f1f3100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0000000000000000000000000000000a1e0a1f1f1f1f1f1f1f1f1f1f1f1f00000a1f1f000a1e1d1d1d1d1e000a1f1f0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0000000000000000000000000000000b0c0b0d1f1f1f1f1f2e1f1f1f1f1f1f1f1f1f1f000a1e1d1d1d1d1e000a1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0000000000000000000000000000000000000b0d1f1f0c0c0c0c0c0d1f1f1f1f1f1f0c000a1e1d1d1d1d1e000a1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000a1e1e00000a1f1f0000000a1e0a1f1f0c0c0c0c00000a1e1e1e1e1e1e000a1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e00000000000000000000000000000a1e1e000a1f1f1f1f0a1e0b0c0a1f1f1f00000000000b0c0c0c0c0c0c000b0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000b0c0c000a1f1f1f1f0b0c00000a1f1f1f000a1f1f1f00000a1f1e1e1e1e1e1e303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e000000000000000000000000000000000a1e0a1f1f1f1f1f1f1f000b0d1f1f1f1f1f1f1f00000a1f1e1f1f1f1f1f0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e000000000000000000000000000000000b0c0a1f1f1f1f0c0d1f000a1f1f1f0c0d1f1f1f00000a1f1e1f2e1f081f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e000000000000000000000000000000001e000b0c0c0c0c000a1f0a1f1f1f1f000b0d1f0c00000a1f1e1f1f1f1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000025001f1f250000000a1f0000000a1f1f1f1f1f1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000363636363636363725001f27000000000a1f0000000a1f1f1f1f1f1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001f1f1f1f1f1f1f1f25001f353636361f1f1f0000000b0d2e0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001b1b1f1f1f1f091f25001f1f2700000c0d1f00000a1f1f1f1f1f00001e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000036371f1f271b1b1b25000000250000000b0c00000a1f1e1e1e1f000a1e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001f1f1f1f353636003536363725000000000000000a1f1e1e1e1f000a1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001f271b1b1b1f1f001f1f1f2e25000000000000000a1f0e0e0e1f000b0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001f353636371f1f001f1f1f1f3536361f1f1f2e000a1f1f1f1f2e0a1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001b1b1b1b1b1b1b001f271b1b1b1b1b0c0c0c0c000b0c0d1f0c0c0b0c0a1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000363636363636371f353636260000000000000000000a1f000000000b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000001f1f1f1f1f1f1f1f1f1f1f250000000a1f0a1f1f1f3d383c1f1f1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001f27001f250000000a1f0a1f0c0c0d1f0c0c0d1f091f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000363636362600001f35371f250000000a1f0a1f00000a1f00000a1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000001f1f1f1f2500001f1f1f1f3536361f1f1f0a1e1e1e0a1f00000a1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000001f1f1f1f250000270000000000000c0d1f0a1e1e1e0a1f1f1f2e1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000001b1b1b1b25000025000000000000000a1f0b0c0c0c0b0c0c0c0c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800001805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003462000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000006143c621000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003e3453a3053e3753a3053f3453a3053e3353a3053f325303053f315303053030530305303053030530305303053030530305303053030530305303053030530305303053030530305303053030530305
0105000026470264702546026400244602540022460234001e450214001f4001b4501d4001b400134501740013400104000b44009400074000040004400044400040000400004000040000400004000043000400
000300003f6403f6403f6403f6403c6403c6403c6403a6403864038630356303563035630346303363030630306302d6302c6302a6302763024620216201d6201962015620116200e6200b620076100461001610
010400003e42500400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
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
__music__
00 0b 0c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
