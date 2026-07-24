pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- space crawler v1.2.4
-- by emanuele ionta

--music by robby duguay
--station:empire 00-05
--mission:mission 06-11
--combat :out of control 12-21

--utils
function curpos(x,y)
 if (x) poke(0x5f26,x)
 if (y) poke(0x5f27,y)
 return peek(0x5f26),peek(0x5f27)
end
function cpy(s,c)
 c=c or {}
 for k,v in pairs(s) do c[k]=v end
 return c
end
function rndi(mn,mx)
 mn=mn or 0;mx=mx or 32000--32768
 if (mn>=mx) return mn
 return flr(mn+rnd(mx-mn)+0.5)
end
--math
function rng(p1,p2)
 local dx,dy=p2.x-p1.x,p2.y-p2.y
 return sqrt((dx*dx)+(dy*dy))
end
function d360(a)
 while a>=360 do a-=360 end
 while a<0 do a+=360 end
 return a
end
function rot4(x,y,d)
 local rx,ry={x,y,-x,-y},{y,-x,-y,x}
 local dd=(d360(d)\90)+1
 return rx[dd],ry[dd]
end
--#include lib.p8:2
--write
function write(msg,w)
 local x,y=curpos()
 w=w or 127-x;w\=4
 local i,sw,se=2,1,0
 while i<#msg do
		local c=sub(msg,i,i)
		if c=='\n' then sw=0;se=0
		elseif c==' ' then se=i end
		if sw>=w then
		 msg=sub(msg,0,se-1)..'\n'..sub(msg,se+1)
		 sw=0;i=se+1
	 else i+=1;sw+=1 end
 end print(msg)
end
--matrix
function matrix(w,h,dv)
 local m={w=w,h=h,v=dv,d={}}
 function m:get(x,y)
  local v,r=self.v,self.d[x]
  if (r and r[y]) v=r[y]
  return v
 end
 function m:put(x,y,v)
  local r=self.d[x] or {}
  if (v==self.v) v=nil
  r[y]=v;self.d[x]=r
 end
 return m
end

--bsp rooms
function bsp(w,h,mn)
	function _area(x,y,w,h)
	 return {x=x,y=y,w=w,h=h,fx=x+w,fy=y+h}
	end
	function _bsp_split(a,mn)
	 local a1,a2
	 if a.w>mn<<1 and a.h>mn<<1 then
		 local v=0
		 if a.w>a.h then v=1
			elseif a.w==a.h then v=rndi(0,1) end
		 if v==1 then
				local s=rndi(mn,a.w-mn)
				a1=_area(a.x,a.y,s,a.h)
				a2=_area(a.x+s,a.y,a.w-s,a.h)
			else
				local s=rndi(mn,a.h-mn)
				a1=_area(a.x,a.y,a.w,s)
				a2=_area(a.x,a.y+s,a.w,a.h-s)
			end
		end	return a1,a2
	end
	function _bsp(a,al,mn)
	 local a1,a2=_bsp_split(a,mn)
	 if a1 then
		 al=_bsp(a1,al,mn)
		 al=_bsp(a2,al,mn)
		else add(al,a)	end
		return al
	end
	return _bsp(_area(0,0,w,h),{},mn)
end
--bsp doors
function bsp_door(r1,r2)
 if r1.fy==r2.y and r1.x<r2.fx and r2.x<r1.fx then --vert
  local mx,mn=max(r1.x,r2.x),min(r1.fx,r2.fx)
  if abs(mx-mn)>1 then
   return {x=(mx+mn)\2,y=r1.fy}
  end
 elseif r1.fx==r2.x and r1.y<r2.fy and r2.y<r1.fy then --hori
  local mx,mn=max(r1.y,r2.y),min(r1.fy,r2.fy)
  if abs(mx-mn)>1 then
   return {x=r1.fx,y=(mx+mn)\2}
  end
 end
end
--ui
--colors: bckg,str,slct
function ui_redraw() ui_drw=1 end
function ui_opt(o)
 add(ui_opl,o)
end
function ui_print(str,x,y)
 curpos(x,y);print(str,ui_c[2])
end
function ui_dop(o)
 ui_print(o)
end
function ui_slctr(w,h,dop)
 dop=dop or ui_dop
 local x,y=curpos()
 for i,o in pairs(ui_opl) do
  if i==ui_op then
   rectfill(x,y,x+w,y+h-1,ui_c[3])
  end dop(o);y+=h
 end
end
function ui_btnlbl(la,lb)
 color(ui_c[2])
 if (la) print('Ž'..la,0,123)
 if (lb) print('—'..lb,64,123)
end
function ui_clear(scr,dt)
 _ui_scr=scr;_ui_dt=dt or {}
 ui_op=1;ui_redraw()
end
function ui_to(scr,dt)
 add(_ui_sscr,{s=_ui_scr,d=_ui_dt,o=ui_op})
 ui_clear(scr,dt)
end
function ui_back()
 local i=#_ui_sscr
 if i>0 then
  local sc=_ui_sscr[i]
  deli(_ui_sscr,i)
  _ui_scr=sc.s;_ui_dt=sc.d
  ui_op=sc.o;ui_redraw()
 end
end
function ui_read(nx)
 for b in all({”,ƒ,—}) do if btnp(b) then
  ui_redraw();if b==” then
   if (ui_op>1) ui_op-=1
  elseif b==ƒ then
   if (ui_op<#ui_opl) ui_op+=1
  elseif not nx then
   ui_back();return true
  end
 end end
end
--ui color
function ui_init(scr,c)
 ui_op=1;ui_drw=1
 _ui_scr=scr;_ui_sscr={}
 _ui_dt={};ui_c=c
end
function ui_draw()
 if ui_drw then
 cls(ui_c[1]);ui_drw=nil
 ui_opl={};return true
 end
end
--ui popup
function scr_popup(msg)
 rectfill(0,0,127,20,ui_c[1])
 color(ui_c[2])
 rect(0,0,127,20)
 print(msg,2,2)
 print('—close',2,14)
 if btnp(—) then ui_back() end
end
function ui_popup(msg)
 ui_to(scr_popup,msg)
end

function _init()
cartdata('snake_scrwl_12')
menuitem(1,'reset record',function()dset(0,0);ui_redraw()end)
ui_init(scr_title,{0,12,2})
for i,s in pairs(_skl) do
 s.snm=s[1];s.id=i
 _skm[s.snm]=s
	ply_skl[i]=0;ply_skd[i]=0
end
for i,t in pairs(_itl) do
 t.ico=t[2];t.nme=t[3]
 t.eqp=t[4];t.ac=t[5]
 t.id=i;_itm[t[1]]=t
	if (i<6) add(_shptl,t)
end
for i,f in pairs(_fct) do
	f.nme=f[1];f.id=i
	ply_rel[i]=50;fct_pwr[i]=50
end
for i,e in pairs(_enl) do
 e.ico=e[2];e.nme=e[3]
 _enm[e[1]]=e
end
music(0)
pload()
end

function _update()
_ui_scr(_ui_dt)
end
-->8
--draw
function draw_fct(f)
 local fid,txt=0,'galactic council'
 if f then
  local sts={' (hostile)',' (neutral)',' (fliendly)'}
  fid=f.id
  txt=f.nme..sts[fct_rel(fid)]
 end
 x,y=curpos()
 spr(22+fid,x,y)
 spr(38+fid,x+8,y)
 ui_print(txt,x+17,y+2)
 curpos(x,y+9)
end
--item
function draw_itm(it,x,y)
 x,y=curpos(x,y)
 local g,txt=48,'none'
 if it and it.ico then
  g=it.ico;txt=it.nme
 end
 spr(g,x,y)
 ui_print(txt,x+9,y+2)
 curpos(x,y+9)
end
function draw_itmi(it,x,y,en)
	draw_itm(it,x,y)
	if it then
	local _wpt={'kinetic weapon','energy weapon','melee weapon'}
	local _efp={'% of stun','% of blind','% of poison'}
 local _efr={'adds action\npoints','removes blind','cures poisoning'}
	if (it.wpt) ui_print(_wpt[it.wpt])
	if (it.pwr) ui_print('power: '..it.pwr)
	if (it.hp) ui_print('hp   : '..it.hp..' ('..itm_hp(it,_ply)..')')
	if not en then
	 if (it.ac) ui_print('ac   : '..it.ac)
	 ui_print('value: '..it.cr..'cr')
	 if it.sk then
	  local sk=_skm[it.sk]
	  ui_print('skill: '..sk.snm..'('..ply_skl[sk.id]..')')
	 end
	end
	if (it.xp) ui_print('xp   : '..it.xp)
	if it.efr then
	 ui_print(_efr[it.eff])
	elseif it.eff then
	 ui_print(''..it.efp.._efp[it.eff])
	end
	if it.def then
	 local txt='protection\n'
	 for i=1,3 do txt..=_def[i]..it.def[i] end
	 ui_print(txt)
	end
 end
end
function draw_itmq(it)
 if it then
  draw_itmi(it,64,12)
  if it.eqp>0 then
   ui_print('\nequipped')
   draw_itmi(ply_eqp[it.eqp])
  end
 end
end
--player
function draw_ply_store()
 ui_print('money:'..ply_cr..'cr\nspace:'..ply_spc(),0,105)
end
function draw_ply_combat()
 ui_print('hp:'..ply_hp..'/'..ply_mhp..' ac:'..ply:ac()..'\nxp:'..ply_xp..'/'..xpnl()..' ap:'..ply.ap,0,105)
end
--skill
function draw_sk(s,tr)
 ui_print(s.snm..': '..ply_skl[s.id]..'+'..ply_skd[s.id])
end
--enemy
function draw_eff(a,x,y)
 if (a.blind) spr(122,x,y)
	if (a.burn) spr(123,x,y+8)
end
function draw_eninfo(en,eq)
 spr(en.ico,64,64)
	ui_print(en.nme..'-l'..en.lv..'\nhp:'..en.hp..' ap:'..en.ap,73,66)
	draw_eff(en,119,64)
	if eq==1 then
	 draw_itmi(en.wpn,64,78,en)
	elseif eq then
	 draw_itmi(en.arm,64,78,en)
	end curpos(64)
end
--level
function draw_map(md)
 local m,p=md.m,md.p
 local h,mcol=m.h,{3,11,8,2,11,11}
 clip(0,64,m.w,h)
 for iy=0,h-1 do for ix=0,m.w-1 do
	 local v,c=m:get(ix,iy),5
	 if (v>=0) c=mcol[v+1]
		pset(ix,63+h-iy,c)
	end end
	local cx,cy=p.x,63+h-p.y
	pset(cx,cy,6);circ(cx,cy,5,12)
	clip()
	rectfill(0,115,40,121,11)
	rectfill(0,115,md.alert<<3,121,8)
	print('alert',10,116,5)
	spr(28+(p.d\90),41,114)
end
--inventory
function draw_msg(r)
 local im={
  'no space in inventory!'
 ,'no enough ac!'
 ,'no enough credits!'
 ,'can not use it!'
 ,'no enought ap!'
 }
 local msg=im[r]
 if msg then ui_popup(msg) end
	ui_redraw()
end
-->8
--screens
function scr_title(dt)
 if ui_draw() then
  sspr(0,64,64,64,0,0,128,128)
  spr(216,56,100,2,1)
  curpos(0,65)
  ui_print('music:robby duguay\n',0,65)
  ui_opt('land to station')
  if (ply_st>0) ui_opt('new carreer')
  ui_slctr(63,6)
  ui_btnlbl('select','back to earth')
 end
 if ui_read() then
  cls();stop('see you soon!')
 elseif btnp(Ž) then
  if ui_op==1 then
   ui_to(scr_base)
   if ply_st==0 then
    game_init()
    ui_to(scr_info)
   end
  else
   preset()
  end
 end
end

function scr_base()
 if ui_draw() then
	 ui_print('station hub (record:'..dget(0)..'cr)\n')
	 foreach({
	 	'dump cantina'
	 ,'junk store'
	 ,'your hovel sweet hovel'
	 ,'iron waste (skp:'..ply_skp..')'
	 ,'infopoint'
	 },ui_opt)
	 ui_print('welcome to dump station 9\ncrawler!\n')
	 ui_slctr(128,6)
	 draw_ply_store()
	 ui_btnlbl('go to ...','take off')
 end 
	if ui_read() then psave()
	elseif btnp(Ž) then
		if ui_op==1 then
		 ui_to(scr_msnlist,msn_heads())
		elseif ui_op==2 then
	  ui_to(scr_shop)
		elseif ui_op==3 then
	  ui_to(scr_inventory)
		elseif ui_op==4 then
	  ui_to(scr_skill)
	 elseif ui_op==5 then
	  ui_to(scr_info)
		end
	end
end

function scr_shop()
 local it,la=_shpil[ui_op]
 if it.id then la='buy' else it=nil end
 if ui_draw() then
  ui_print('junk store - all junk you need!\n')
  foreach(_shpil,ui_opt)
  ui_slctr(62,9,draw_itm)
  draw_itmq(it)
  draw_ply_store()
  ui_btnlbl(la,'exit')
 end ui_read()
 if btnp(Ž) and la then
  draw_msg(shop_buy(ui_op))
 end
end

function scr_inventory(dt)
 local en,it=dt.en,ply_inv[ui_op]
 local msn,lc,la=dt.mh or en,''
 if it then 
  if it.eqp<=0 then
   if en then
    if it.eqp<0 then
     la='use ap:'..it.ac
    else
     local ht,ap=cmbt_atk(ply,en,1,it)
     la='use '..ht..'% ap:'..ap
    end
   else la='use' end
  elseif en then
   la='equip ap:'..it.ac
  else la='equip' end
	 if msn then lc='‹drop'
	 else lc='‹sell' end
	end
 if ui_draw() then
  ui_print('inventory - ‘equipment\n')
  foreach(ply_inv,ui_opt)
  ui_slctr(62,9,draw_itm)
  if (it) draw_itmq(it)
  if en then draw_ply_combat()
  else draw_ply_store() end
  ui_btnlbl(la,'exit  '..lc)
 end ui_read()
 if btnp(Ž) and la then
  draw_msg(ply_use(ui_op,en))
  ui_redraw()
 elseif btnp(‹) then
  if msn then ply_rmv(ui_op)
  else shop_sell(ui_op) end
  ui_redraw()
 elseif btnp(‘) then
  ui_back();ui_to(scr_equip,dt)
 end
end

function scr_equip(dt)
 local it=ply_eqp[ui_op]
 if ui_draw() then
  ui_print('equipment - ‘inventory\n')
  foreach(ply_eqp,ui_opt)
  ui_slctr(62,9,draw_itm)
  draw_itmi(it,64,12)
  draw_ply_info()
  ui_btnlbl(la,'exit')
 end ui_read()
 if btnp(‘) then
  ui_back();ui_to(scr_inventory,dt)
 end
end

function scr_skill()
 local sk,skd,la=_skl[ui_op],ply_skd[ui_op]
 if ui_draw() then
  foreach(_skl,ui_opt)
  ui_print('iron waste - train soul and body!\n(maximum skill level is 4)\n')
  ui_slctr(32,6,draw_sk)
  ui_print('\nskill points (skp): '..ply_skp..'\nlevel:'..ply_lv..'\n\n‹remove skp    ‘ add skp')
  curpos(40,18)
  write(sk[2])
  ui_btnlbl('train','exit')
 end ui_read()
 for i=0,5 do if btnp(i) then
  if i==‹ and skd>0 then  
   ply_skd[ui_op]-=1;ply_skp+=1
  elseif i==‘ and ply_skp>0 and ply_skl[ui_op]<4 then
   ply_skd[ui_op]+=1;ply_skp-=1
  elseif i==Ž then
   ply_train()
  elseif i==— then
   ply_train(1)
  end ui_redraw()
 end end
end

function scr_info()
 local fi=ui_op-1
 local f=_fct[fi]
 if ui_draw() then
  ui_opt('combat')
  foreach(_fct,ui_opt)
  draw_fct()
  ui_print('\nwellcome crawler! some info!\n-dump cantina > missions/jobs\n-junk store   > buy equipment\n-your hovel   > player inventory\n-iron waste   > train skills\n')
  if f then
   ui_print('four factions fight each other\nto control the galactic council.\n')
   draw_fct(f)
   write('pwr:'..fct_pwr[fi]..'/100 rel:'..ply_rel[fi]..'/100\n\n'..f[2])
  else
   ui_print('during a fight keep this in mind\n-hp    : health point\n-ap    : number of action point\n  (more ap more actions)\n-ac    : number of ap used\n-stun  : removes target\'s ap\n  (target ac + wpn level)\n-blind : halves hit chance and\n  doubles flee chance\n-poison: reduces target hp each\n  target\'s turn (1 + wpn level)')
  end
  print('”ƒfaction info   —goodbye',0,123)
 end ui_read()
end

function scr_msnlist(dt)
 local mh=_mhl[ui_op]
 if ui_draw() then
	 foreach(_mhl,ui_opt)
	 ui_print('dump cantina - job ('..ui_op..'/'..#ui_opl..')\n')
	 draw_fct(mh.fct)
	 local st='\n'..mh.tit..'\nlevel:'..mh.lv..'\n\nwe need to '
	 if mh.trg then st..='steal a '
 	else st..='recover a ' end
	 st..=mh.it.nme..' from '
	 if mh.trg then st..=mh.trg.nme..'`s '
	 else st..='our abandoned '	end
	 st..=mh.lnm
	 if mh.lnm=='starship' then st..=' orbits around'
	 else st..=' located on' end
  st..=' a planet in this sector.\nyou will receive '..mh.cr..'cr	on success.\nexact location will be provided upon acceptance of the job.\n\nremember to buy medikits!'
	 write(st)
	 ui_print('”previous      ƒnext',0,116)
  ui_btnlbl('begin mission','leave cantina')
	end ui_read()
	if btnp(Ž) then
	 psave();rcast_init(126,62)
	 ui_clear(scr_travel,{md=msn_level(mh)})
	end
end

function scr_travel(dt)
 if _atm then
  if _atm>36 or btnp(—) then
    _atm=nil;ui_clear(_ascr,dt.md) 
  else
   _atm+=1
   _adst+=_astp+_astp*_adst/16
  end
 elseif dt.ln then
  music(0)
  _atm=8;_agx=104;_astp=-1;
  _adst=80;_ascr=scr_debrief
 else
  music(6)
  _atm=0;_agx=96;_astp=1;
  _adst=0;_ascr=scr_level
 end cls()
 local dst=flr(_adst+0.5)
 sspr(32,96,32,32,0,32,64,64)
 sspr(64,_agx,16,8,32+dst,60+dst,16+_adst,8+dst\2)
end

function scr_level(md)
 if ui_draw() then
  rcast_draw(md,1,1)
  rect(0,0,127,63,11)
	 draw_map(md)
	 ui_print('hp:'..ply_hp..'/'..ply_mhp..'\ncr:'..ply_cr..'\n\nmission item',64,65)
	 draw_itm(md.it)
		ui_btnlbl(nil,'inventory')
	end	game_pad(md)
end

function scr_interact(dt)
 local c,md,la=dt.c,dt.md
 local clck=c.lck
	if clck then
	 if clck>0 and ply_sklv('hck')>0 then la='unlock' end
	elseif c.it then
	 la='loot'
	end
 if ui_draw() then
  local txt=c.nme
  if (c==md.cn) txt..=' (mission)'
  spr(c.g);ui_print(txt,9,3)
		if clck then
		 if clck==0 then
		  ui_print('permanently locked')
			else
			 ui_print('locked (hck:'..ply_sklv('hck')..')')
			end
		elseif c.it then
		 draw_itmi(c.it)
		end
		ui_btnlbl(la,'exit')
	end ui_read()
	if btnp(Ž) and la then
		draw_msg(cn_interact(c,md))
  ui_redraw()
	end
end

function _cmbt(dt,atk,trg,t)
 local r=cmbt_hit(atk,trg,t)
 if atk.burn and atk:heal(atk.burn)<0 then r=-1;trg=atk end
 if r and r<0 then
	 if trg==ply then
	  ui_clear(scr_title)
	  ui_to(scr_end,{pd=1})
	  music(0)
	 else
	 	ui_back()
	 	music(rndi(6,11))
	 end
	end
	cmbt_msg(atk,trg,r)
	cmbt_turn(dt)
end

function scr_combat(dt)
 if not dt.trn then
  music(rndi(12,21));_en_eq=1
	 cmbt_init(dt)
	end
 local md,en,trn=dt.md,dt.en,dt.trn
 --local flee='flee'
 if (dt.md.alert>=5) flee=nil
 if ui_draw() then
  foreach({'enemy info','attack','equipment'},ui_opt)
  rcast_draw(dt.md,1,1)
  rect(0,0,127,63,11)
  clip(1,1,126,62)
		sspr((en.ico<<3)&127,(en.ico\16)<<3,8,8,32,2,64,64)
		clip()
		curpos(0,65)
		ui_slctr(60,6)
		draw_eff(ply,0,89)
	 draw_ply_combat()
	 curpos(64,65)
	 if ui_op==1 then
	  draw_eninfo(en,_en_eq)
		 ui_btnlbl('weapon','armour')
		elseif ui_op==2 then
		 draw_eninfo(en)
		 ui_print('----------------',64)
		 for i=1,2 do
			 local ht,ap=cmbt_atk(ply,en,i)
				ui_print(_atk[i]..' ('..ht..'%) '..'ap:'..ap)
			end
			ui_btnlbl('fast','aim')
		elseif ui_op==3 then
		 for i=1,2 do draw_itm(ply_eqp[i] or {eqp=i}) end
		 ui_btnlbl('flee '..cmbt_flee(md,en,1)..'%','inventory')
		end
	end
	if dt.trn==2 then
	 _cmbt(dt,en,ply,rndi(1,2))
	elseif dt.inv then
	 cmbt_turn(dt);dt.inv=nil
	else
	 ui_read(true)
	 if btnp(Ž) then
	  if ui_op==1 then
	   _en_eq=1;ui_redraw()
	  elseif ui_op==2 then
		  _cmbt(dt,ply,en,1)
		 else--if flee then
			 if cmbt_flee(md,en) then
			  ui_back();music(rndi(6,11))
				 ui_popup('you flee from combat')
			 else
			  ui_popup('you fail to flee')
			  cmbt_turn(dt)
			 end
		 end
	 elseif btnp(—) then
	  if ui_op==1 then
	   _en_eq=2;ui_redraw()
	  elseif ui_op==2 then
		  _cmbt(dt,ply,en,2)
		 else
			 ui_to(scr_inventory,dt)
			 dt.inv=true
		 end
	 end
	end
end

function scr_msnexit(md)
 if ui_draw() then
		ui_print(md.mh.lnm..' exit\n')
		if md.it then
		 ui_print('work completed.\nyou can go back to base.')
		else
   ui_print('the work is not completed.\nthis can jeopardize relationship\nwith your employer faction.')
--		 ui_print('your job is not complete.\nyou will deteriorate the\n\nrelationship with your employer\nfaction.')
		end
	 ui_btnlbl('leave','back')
	end
	if btnp(Ž) then
	 msn_end(md)
		ui_clear(scr_travel,{ln=1,md=md})
	elseif btnp(—) then
	 md.p.d=0;ui_back()
	end
end

function scr_debrief(md)
 if ui_draw() then
  local f=md.mh.fct
  draw_fct(f)
		ui_print('\ndear crawler\n')
		if md.it then
		 write('we are really satisfied with you.\n'..md.mh.cr..'cr are accredited on your account.')
		else
		 local _frm={
		  'this ends our collaboration.'
		 ,'mistakes can always happen.\nwe are watching you.'
		 ,'we are sure that next time you will not fail.'
		 }
		 write('your failure is disappointing.\n'.._frm[fct_rel(f.id)])
		end
	 ui_btnlbl(nil,'exit')
	end
	if btnp(—) then
		local ge=game_end()
		if ge then
		 ui_to(scr_end,ge)
  else
   ui_clear(scr_title)
   ui_to(scr_base)
  end
	end
end

function scr_end(ge)
 if ui_draw() then
	 ui_print('space crawler - the end\n')
  if ge.pd then
   write('you are killed during a mission. your body was lost in the depth of space.')
  elseif ge.fw then--7094
   local _frm={
    '\nyou are arrested as an enemy of the galactic council.'
    ,nil
    ,'\nthanks to the friendship with the faction you were put in charge of the galactic police.'
   }
   local f,fm=_fct[ge.fw],_frm[fct_rel(ge.fw)]
   draw_fct(f)
   write('has obtained enough power to control galactic council.\n\n'..f[3])
   if fm then
    write(fm)
   elseif ply_cr>5000 then
    write('\nyou have earned enough credits to retire to a luxury estate.')
   end
  elseif ge.ef then
   write('all factions want you dead.\nyou try to escape but a killer catch you and done his job.')
  elseif ge.pw then
   write('you retired, after reach the apex of your career, with '..ply_cr..'cr.')
  end
  if ply_cr>dget(0) then
   write('\nthanks to your '..ply_cr..' credits you are the richest crawler in the galaxy.')
   dset(0,ply_cr)
  end
	 ui_btnlbl(nil,'end')
	end
	if btnp(—) then
	 ui_clear(scr_title)
	 preset()
	end
end

-->8
--raycast
function rcast_init(w,h)
 _rc_w=w;_rc_h=h
 _rc_aow=(w/h)/1.9
end

function _tcol(ti,x,y)
 x+=(ti<<3)&127
 y+=(ti\16)<<3
 return sget(x,y)
end
function _addo(odl,o)
 local i,ok=1
 while i<=#odl do
  if o.vd>odl[i].vd then
   for j=#odl,i,-1 do odl[j+1]=odl[j] end
   odl[i]=o;ok=o;i=#odl+1
  else i+=1 end
 end
 if (not ok) add(odl,o)
end
function _robj(ol,p)
 local xol,odl,w2={},{},_rc_w\2
 for i=0,_rc_w-1 do xol[i]={} end
 for o in all(ol) do if o.g then
  local ox,oy=rot4(o.x-p.x,o.y-p.y,-p.d)
  if oy>0 then
   local od={g=o.g,vd=oy}
   od.wh=flr(_rc_h/oy)
   od.ox=flr(ox*_rc_h/oy)
   _addo(odl,od)
  end
 end end
 for od in all(odl) do
  local wx,d,dx=0,od.wh\2,1/od.wh
  local sx,fx=od.ox-d+w2,min(od.ox+d+w2,_rc_w-1)
  if sx<0 then wx-=dx*sx;sx=0 end
  for i=sx,fx do
   add(xol[i],{wx=wx,o=od});wx+=dx
  end
 end return xol
end
function _dobj(di,x,cy)
 local ti,wh=di.o.g,di.o.wh
 local tx=min(7,flr(8*di.wx))
 local sy=cy-(wh>>1)
 for i=0,wh-1 do
  local ty=min(7,flr(8*i/wh))
  local c=_tcol(ti,tx,ty)
  if (c!=0) pset(x,sy+i,c)
 end
end
function _pwd(m,p,st,rd)
return (m-p+(1-st)/2)/rd
end
function _rwll(sd,m,p,st,rd,wh)
 local px,py,d,wx=p.x+0.5,p.y+0.5
 if sd==0 then
  d=_pwd(m[1],px,st[1],rd[1])
  wx=py+d*rd[2]
 else
  d=_pwd(m[2],py,st[2],rd[2])
  wx=px+d*rd[1]
 end wx-=flr(wx)
 return wx,flr(wh/d),d
end
function _dwll(ti,wx,wh,x,cy)
 local tx=min(7,flr(8*wx))
 local sy=cy-(wh>>1)
 for i=0,wh-1 do
  local ty=min(7,flr(8*i/wh))
  pset(x,sy+i,_tcol(ti,tx,ty))
 end
end

function rcast_draw(dt,x,y)
 local m,p=dt.m,dt.p
	local gfx,cy=dt.gfx,y+(_rc_h>>1)
	local dx,dy=rot4(0,1,p.d)
	local pla=d360(p.d+90)
	local plx,ply=rot4(0,_rc_aow,pla)

 clip(x,y,_rc_w,_rc_h)
 rectfill(x,y,x+_rc_w,y+cy,dt.cl)
 rectfill(x,y+cy,x+_rc_w,y+_rc_h,dt.fl)
	local xol=_robj(dt.obl,p)
	for sx=0,_rc_w-1 do
	 local camx=2*sx/_rc_w-1
		local mx,my=p.x,p.y
		local rdx,rdy=dx+plx*camx,dy+ply*camx
		local ddx,ddy=abs(1/rdx),abs(1/rdy)
		local sdx,sdy=0.5*ddx,0.5*ddy
		local stx,sty,pwd,side=1,1
		if (rdx<0) stx=-1
		if (rdy<0) sty=-1
		--dda
		local v,dol=0,xol[sx]
		while v<=0 do
			if sdx<sdy then
			 sdx+=ddx;mx+=stx;side=0
			else
			 sdy+=ddy;my+=sty;side=1
			end v=m:get(mx,my)
		end
		--wall
		local wx,wh,pwd=_rwll(
			side,{mx,my},p,{stx,sty},{rdx,rdy},_rc_h
		)
--		if v!=2 then
--		 if side==0 and rdx>0 then wx=1-wx end
--		 if side==1 and rdy<0 then wx=1-wx end
--		end
		_dwll(gfx+v,wx,wh,x+sx,cy)
		--objects
		for d in all(dol) do
	 if d.o.vd<pwd then
	  _dobj(d,x+sx,cy)
		end end
	end clip()
end

-->8
--data
--factions
_fct={
{'trade lg'
,'a traders association wich controls all legal trading in the galaxy.'
,'trading was deregulated and this bring a new era of continuous economic crisis.'
},
{'biotech'
,'it has a virtual monopoly in the market for prothesis and biotech implants of all kind.'
,'biotech implants become diffuse and by them governament controls mankimd.'
},
{'chemlab'
,'it is a market leader in chemical and genetic technology. rumors indicate it conducts classified experiments.'
,'experiments with aliens goes bad. powerful beasts decimate mankind.'
},
{'newlight'
,'a sect that worships greek-like gods. it is popular among all galaxy due to its charity work. it has ears and eyes everywhere.'
,'gods of newlight are powerfull aliens that now control mankind through galactic repulic.'
},
}
--skills
_skl={
{'knw',
'kinetic weapons\n\nincrease chances to hit when using chinetic weapons (gun)'},
{'enw',
'energy weapons\n\nincrease chances to hit when using energy weapons (laser)'},
{'mlw',
'melee weapons\n\nincrease chances to hit when usinge melee weapons (blade)'},
{'trw',
'throwable weapons\n\nincrease chances to hit when use throwable weapons (grenades)'},
{'agl',
'agility\n\nincrease ability to move in combat (ac)\n(ap = action points)\n(ac = action restored per turn)'},
{'med',
'medicine\n\nincrease efficency (hp) in using medikits\n(hp = health points)'},
{'hck',
'hacking\n\nability to hack electronic or software lock systems\n(0=you can not hack locks)'},
{'crw',
'crawler\n\nincrease the ability to find items'},
{'stl',
'stealth\n\nreduce the frequency of the encounters with enemies'}
}
_skm={}
--items
_eqp={'wpn','arm'}
_typ={'lgh.','med.','hvy.'}
_def={'-kinetic:','\n-energy :','\n-melee  :'}
--{snm,ico,nme,eqp,ac}
_itl={
--player equipment
{'wpn',70
,{'gun','laser','blade'}
,1},
{'arm',102,nil,2},
--consumables
{'grn',104
,{'stun grnd','flash grnd','psn grnd'}
,0,-2,eff=1,sk='trw'
},
{'drg',107
,{'stimulant','unblind','antidote'}
,-1,-1,efr=1
},
{'mdk',79,'medikit',-1,-2
,hp=10,sk='med'
},
--no market
{'dst',95,'datastick',-1,-1,xp=1
},
{'crs',111,'credits',-1,0,mn=30
},
--enemy equip
{'ewp',86,{'gun','laser','claw'},1
},
--mission item
{'mdd',124,'datadisk',-1},
{'mcs',125,'chest',-1},
}
_itm,_shptl,_shpil,_shpav={},{},{},{}
--containers
_cnl={
 'computer desk'--,itl={'mdk','wpn'}
,'computer table'--,itl={'crs','dst'}
,'crate'--,itl={'wpn','arm','grn'}
,'crate'--,itl={'wpn','arm','grn'}
,'console'--,itl={'dst'}
}
--enemies
--{snm,ico,nme,hp,wpn,wpt}
_enl={
{'bot',64
,{'eagle','spider','cerberus'}
,0,'ewp',{1,2}
},
{'aln',80
,{'dragon','skorpion','guardian'}
,4,'ewp',{3}
},
{'scr',-1,'security'
,2,'wpn',{1,2}
},
{'kil',54,'killer'
,2,'wpn',{2,3}
},
{'crw',55,'crawler'
,2,'wpn',{1,3}
},
}
_enm={}
--levels
_lvl={'office','lab','starship','mine'}
--missions
_msn_tit={'steal','rescue'}
_msn_itm={'mdd','mcs'}
_msn_enl={{'scr'},{'aln','crw'}}

-->8
--game
function rnds()
 srand(rndi())
end

function game_init()
 ply_st=1
 add(ply_eqp,itm_build(2064))
 add(ply_eqp,itm_build(2080))
 add(ply_inv,itm_build(14608))
 add(ply_inv,itm_build(28432))
 ply_cr=250;ply_skp=2
 ply_hp=100;ply_mhp=100
 ply_xp=0;ply_lv=0
 game_next()
end
function shop_cr(it)
 function _scr(cr,div,fid)
  return cr*(3-fct_rel(fid))\div
 end
 if it.cr then
  local cr=it.cr
  if it.eqp>0 then--biotech
   cr+=_scr(cr,4,2)
  else--chemlab
   cr+=_scr(cr,6,3)
  end
  --trade inc
  it.cr=cr+_scr(it.cr,10,1)
 end
 return it
end
function game_next()
 ply_sd=rndi()
 srand(ply_sd)
 --shop items
 _shpil={}
	for i=0,9 do
	 local it=itm(_shptl[i%#_shptl+1],ply_lv,rndi(0,255))
	 add(_shpil,shop_cr(it))
	 --add(_shpil,itm(rndel(_shptl),ply_lv,rndi(0,255)))
	end
 psave()
end
function game_end()
 local ge,ef,ck={},0,0
 for f=1,4 do
  if (fct_rel(f)==1) ef+=1
  if (fct_pwr[f]>90) ge.wf=f
 end
 if ef==4 then ge.ef=1
 elseif ply_lv>9 then ge.pw=1
 end
 --ge={fw=1};ply_rel[1]=0;ply_cr=10000
 for _,v in pairs(ge) do ck+=1 end
 if (ck==0) ge=nil
 return ge
end
--player
ply_inv={};ply_eqp={}
ply_skl={};ply_skd={}
ply_rel={};fct_pwr={}
ply={nme='player'}
function ply_sklv(skn)
 return ply_skl[_skm[skn].id]
end
function ply_spc()
 return 10-#ply_inv
end
function ply_add(it)
 if #ply_inv<10 then
	 add(ply_inv,it);return 0
	else return 1 end
end
function ply_rmv(i)
 deli(ply_inv,i)
end
function ply_use(i,en)
 local it=ply_inv[i]
 if (en and ply.ap+it.ac<-3) return 5
	if it.eqp>0 then
	 local eit=ply_eqp[it.eqp]
	 if ply:ac()>=eit.ac-it.ac then
	  ply_add(eit)
	  ply_eqp[it.eqp]=it
	 else return 2 end
	elseif it.efr then
	 if en then
	  if ti.efr==2 then
	   ply.blind=nil
	  elseif ti.efr==3 then
			 ply.burn=nil
			end
		else return 4 end
	elseif it.eff then
	 if en then
			cmbt_usew(ply,en,it)
			cmbt_msg(ply,en)
		else return 4 end
	elseif it.hp then
	 if ply_hp<ply_mhp then
	  ply:heal(itm_hp(it))
	 else return 4 end
	end
	ply_cr+=it.mn or 0
	ply_xp+=it.xp or 0
	ply_rmv(i)
	if (en) ply.ap+=it.ac
 return 0
end
function xpnl() return (ply_lv+1)*100 end
function ply_levelup()
	if ply_xp>xpnl() then
	 ply_xp-=xpnl();ply_lv+=1
	 ply_skp+=2;ply_mhp+=5
	 ply_hp=ply_mhp
	end
end
function ply_train(canc)
 for sk=1,#_skl do
  if canc then
   ply_skp+=ply_skd[sk]
  else
   ply_skl[sk]+=ply_skd[sk]
  end ply_skd[sk]=0
 end psave()
end
--player combat
function ply:ac()
 local ap,it=(ply_sklv('agl')+1)*3
	for i=1,#_eqp do
	 it=ply_eqp[i]
	 if it then ap+=it.ac end
	end	return ap
end
function ply:attack(w)--skv,w
 local w=w or ply_eqp[1]
	return ply_sklv(w.sk),w
end
function ply:defence(w)--ac,def
 return self:ac(),cmbt_def(ply_eqp[2],w)
end
function ply:heal(v)
 if v then ply_hp+=v end
 if ply_hp>ply_mhp then ply_hp=ply_mhp end
 return ply_hp
end
--item
function itm_build(v)
 if v!=0 then
  return itm(_itl[(v\16)&15],v&15,v\256)
 end
end
function itm(typ,lv,sd)
 local it=cpy(typ,{sd=sd or rndi(0,255)})
 srand(it.sd)
	it.lv=rndi(0,lv)
	if (sd) it.lv=lv
	local lv1,ac=it.lv+1,rndi(0,2)
	it.cr=lv1*50
	if typ.eqp>0 then
	 it.ac=-1-ac
	 if typ.eqp==1 then --weapon
	  it.wpt=it.wpt or rndi(1,#typ.nme)
	  it.sk=_skl[it.wpt].snm
	  it.ico+=(it.wpt-1)*3+ac
	  it.nme=_typ[-it.ac]..typ.nme[it.wpt]
	  it.pwr=8+lv1+ac
	  --lv1>1
	  if lv1>0 and rndi(0,99)<=9+lv1 then
	   it.eff,it.efp=it.wpt,4+lv1
	   it.cr+=it.cr\2
	  end
		else --armour
		 it.ico+=ac
	  it.nme=_typ[-it.ac]..'ar_'
	  it.def={0,0,0}
	  for i=0,lv1 do
	   it.def[rndi(1,3)]+=4+ac
	  end
	  local dt={'k','e','m'}
	  for i=1,3 do
	   if (it.def[i]>0) it.nme..=dt[i]
	  end
		end
	else --item
	 if typ.hp then
	  it.bhp=it.hp
	  it.hp=lv1*typ.hp
		end
		if typ.eff or typ.efr then
		 it.eff,it.efp=rndi(1,3),100
		 it.ico+=it.eff
		 it.nme=typ.nme[it.eff]
		 if it.efr then
		  if it.eff==1 then
		   it.ac=2+lv1
		  else it.cr=50 end
		 end
		end
		if typ.mn then
		 it.mn=lv1*typ.mn
			it.cr=it.mn
		end
		if it.xp then
		 it.xp+=it.lv--newlight
		 it.cr*=(fct_rel(4)-1)
		end
	end
	if (it.eqp>=0) it.nme..='-l'..it.lv
	rnds()
	return it
end
function itm_hp(it)
 return it.hp+it.bhp*ply_sklv('med')
end
--factions
function fct_rel(fid)
	local r=ply_rel[fid]
	if r<25 then return 1
	elseif r>75 then return 3
	else return 2 end
end
function fct_set(fv,f,v)
 local r=fv[f.id]+v
 if r<0 then r=0 elseif r>100 then r=100 end
 fv[f.id]=r
end
--shop
function shop_buy(i)
 local r,it=0,_shpil[i]
 if it then
	 if it.id then
	 if it.cr<=ply_cr then
		 r=ply_add(it)
		 if r==0 then
			 _shpil[ui_op]={}
			 ply_cr-=it.cr
			 psave()
			end
		else r=3 end
		else r=5 end
	end	return r
end
function shop_sell(i)
 if ply_inv[i] then
  ply_cr+=ply_inv[i].cr
  ply_rmv(i);psave()
 end
end
--containers
function cn_interact(c,md)
 local r=0
 if not c.lck then
	 if c.it then
		 if c!=md.cn then
			 r=ply_add(c.it)
			else md.it=c.it end
		end
		if (r==0) c.it=nil
	elseif c.lck>0 then
		if rndi(0,ply_sklv('crk'))>=c.lck then c.lck=nil
		else c.lck=0;r=-10
		 if (md.alert<5) md.alert+=1
		end
	end	return r
end
--exploration
function step(p,md,sp)
	local sx,sy=rot4(0,sp,p.d)
	local x,y,m=p.x+sx,p.y+sy,md.m
	local mv=m:get(x,y)
	while mv==2 do
		x+=sx;y+=sy;mv=m:get(x,y)
	end
	local nx,en=m:get(x+sx,y+sy)
	if mv==0 then
  p.x,p.y=x,y;en=(nx==0)
	elseif sp<=0 then mv=nil end
	if en then
	 local sl=5+md.alert-ply_sklv('stl')
	 en=rndi(0,200)<=sl
	end
	if en and sp<0 then p.d=d360(p.d+180) end
	return mv,en
end
function game_pad(md)
 for b=0,5 do if btnp(b) then
  local p,v,en=md.p
		if b==” then
		 v,en=step(p,md,1)
		elseif b==ƒ then
		 v,en=step(p,md,-1)
		elseif b==‹ then
		 p.d=d360(p.d-90)
		elseif b==‘ then
		 p.d=d360(p.d+90)
		elseif b==— then
		 ui_to(scr_inventory,md)
		end
		if en then
		 ui_to(scr_combat,{md=md})
		elseif v then
		 if v<0 then
		  local cn=md.obl[-v]
			 if cn.nme then
			  ui_to(scr_interact,{c=cn,md=md})
			 end
		 elseif v==3 then
		  ui_to(scr_msnexit,md)
		 end
		end
		b=8;ui_redraw()
 end end
end

-->8
--mission
function msn_head(f,l)
 local mh,mi={lv=l,seed=rndi()},1
	mh.fct=f
	mh.trg=rnd(_fct)
	mh.lid=rndi(1,4)
	mh.lnm=_lvl[mh.lid]--level name
	mh.it=_itm[rnd(_msn_itm)]
	mh.enl={'bot'}
	if mh.trg==f then
	 mh.trg=nil;mi=2
	end
	mh.tit=mh.it.nme..' '.._msn_tit[mi]
	for e in all(_msn_enl[mi]) do
	 add(mh.enl,e)
	end
	if (mh.lid==4) add(mh.enl,'aln')
	for fi=1,4 do
	 if (fct_rel(fi)<2) add(mh.enl,'kil')
	end
	mh.cr=(mh.lv+1)*100+(ply_rel[f.id]\5)*10
	if (mh.trg) mh.cr+=mh.cr\2
	return mh
end

function msn_heads()
 srand(ply_sd);_mhl={}
	local ffct={}
	for f in all(_fct) do
	 if (fct_rel(f.id)>=2) add(ffct,f)
	end
	for i=-3,5 do
	 mh=msn_head(
	  rnd(ffct),
		 max(0,ply_lv+(i\3))
		);add(_mhl,mh)
	end
end

function msn_level(mh)
	function _setwll(m,x,y)
	 local v=m:get(x,y)
	 if v==1 and rndi(0,4)==0 then
		 if x==0 or x==m.w-1
		  or y==0 or y==m.h-1 then
		  v=5
		 else v=4 end
		end
		m:put(x,y,v)
	end
	function posck(m,x,y)
	 local v=true
	 for j=-1,1 do for i=-1,1 do
		 if (m:get(x+i,y+j)!=0) v=false
		end end return v
	end
	function cn_new(mh,x,y,lid)
		local ci=sget(rndi(3,7),lid)
		local cn={nme=_cnl[ci],g=5+ci,x=x,y=y}
		if cn.nme then
		 local psl=ply_sklv('hck')+1
			if rndi(0,psl)>0 then
			 cn.lck=rndi(0,mh.lv+1)
			 if (cn.lck==0) cn.lck=nil
				--content
			 cn.it=itm(_itl[sget(rndi(0,7),ci+7)],mh.lv)
			end
		end
		return cn
	end
	srand(mh.seed)
	local md,l={mh=mh},mh.l
	local lid=mh.lid-1
	md.alert=0
	md.gfx=lid*16
	--create rooms
	local w,h,mn=rndi(30,50),rndi(30,50),rndi(4,6)
	local rl=bsp(w,h,mn)
	local pr=rl[1]--start room
	for r in all(rl) do
	 if (r.y<pr.y) pr=r
	end
	--create map
	md.cl,md.fl=sget(0,lid),sget(1,lid)
 local m=matrix(w,h,1)
	--rooms
	for r in all(rl) do
  for cy=1,r.h-1 do for cx=1,r.w-1 do
	  local x,y=r.x+cx,r.y+cy
   if x==w-1 or y==h-1 then
	   _setwll(m,x,y)
	  else
	   m:put(x,y,0)
	  end
	 end end
	 for y=r.y,r.fy do
	  _setwll(m,r.x,y)
	 end
	 for x=r.x,r.fx do
	  _setwll(m,x,r.y)
	 end
	end
	--add doors
	for r1 in all(rl) do for r2 in all(rl) do
	 local d=bsp_door(r1,r2)
	 if (d) m:put(d.x,d.y,2)
	end end
	--player
	md.p={
	 d=0,x=pr.x+rndi(1,pr.w-2),y=1
	}
	m:put(md.p.x,0,3)
	md.m=m
	--objects
	md.obl={}
	local mobl={}
	while #md.obl<15 do
	 local x,y=rndi(2,m.w-3),rndi(2,m.h-3)
	 if posck(m,x,y) then
	  local cn=cn_new(mh,x,y,lid)
	  add(md.obl,cn)
	  m:put(x,y,-#md.obl)
	  if (cn.nme) add(mobl,cn)
	 end
	end
	--for y=0,m.h-1 do for x=0,m.w-1 do
	--if rndi(0,15)==0 and posck(m,x,y) then
	-- cn_add(md,m,x,y,lid)
	--end end end
	md.cn=rndel(mobl)
	md.cn.lck=nil;md.cn.cr=nil
	md.cn.it=itm(mh.it,0)
	srand()
	return md
end

function msn_end(md)
 --mission outcome
	local rel=5+mh.lv
 local f,t=md.mh.fct,md.mh.trg
	if (t) fct_set(ply_rel,t,-rel)
 if md.it then
	 ply_cr+=md.mh.cr
	 fct_set(ply_rel,f,rel)
	 fct_set(fct_pwr,f,6)
	 if (t) fct_set(fct_pwr,t,-3)
	else
  fct_set(ply_rel,f,-rel\2)
  if (t) fct_set(fct_pwr,t,3)
	end
	--day variation
	for f in all(_fct) do
	 local fp,f1,f2=fct_pwr[f.id],1,1
	 if fp<45 then f1=-2
	 elseif fp>55 then f2=2
	 end
	 fct_set(fct_pwr,f,rndi(f1,f2)*5)
	 --fct_set(fct_pwr,f,rndi(-pwr,pwr))
	end
	ply_levelup()
	game_next()
end

-->8
--combat
_atk={'fast','aim '}
function cmbt_ap(a)
 if (not a.ap) a.ap=0
 a.ap+=a:ac()+1
end
function cmbt_init(dt)
 dt.trn=2
 dt.en=en_new(dt.md)
 ply.blind,ply.burn=nil,nil
 cmbt_ap(ply);cmbt_ap(dt.en)
 cmbt_turn(dt)
 rnds()
end
function cmbt_turn(dt)
 local en,t=dt.en,1
	while ply.ap<0 or en.ap<0 do
	 cmbt_ap(ply);cmbt_ap(en)
	end
	if ply.ap>en.ap then t=1
	elseif ply.ap<en.ap then t=2
	elseif t==1 then t=2
	end
	dt.trn=t
end
function cmbt_atk(atk,trg,t,w)
 local skv,w=atk:attack(w)
	local ac,def=trg:defence(w)
	skv+=4+t-ac
	skv*=10
	if (trg.blind) skv*=2
	if (atk.blind) skv\=2
	ac=w.ac-((t-1)*2)
	return min(skv,99),ac,def,w
end
function cmbt_def(arm,w)
 if arm then
  return arm.def[w.wpt or 0] or 0
 else return 0 end
end
function _cmbt_eff(trg,w)
 if trg==ply or rndi(0,trg.lv)<=w.lv then
  if w.eff==1 then
   trg.ap-=trg:ac()+w.lv
  elseif w.eff==2 then
   trg.blind=1
  elseif w.eff==3 then
   trg.burn=-1-w.lv
  end
  trg.efm=w.eff
 else trg.eff=0 end
end
function cmbt_hit(atk,trg)
 local skv,ac,def,w=cmbt_atk(atk,trg,1)
	local pwr
	if rndi(0,99)<skv then
	 pwr=w.pwr-def
		if pwr<0 then pwr=0 end
		if trg:heal(-pwr)<=0 then pwr=-1 end
	 if w.efp and rndi(0,99)<w.efp then
	  _cmbt_eff(trg,w)
	 end
	end atk.ap+=ac
	return pwr
end
function cmbt_flee(md,en,info)
 local pap,fp=ply.ap+1,0
 if pap>1 then
  fp=50*pap\(pap+en.ap+md.alert*2)
  if (en.blind) fp*=2
  if (fp>100) fp=100
 end
 if (info) return fp
 if rndi(0,99)<fp then
  if (md.alert<5) md.alert+=1
  return true
 else
  ply.ap=min(0,ply.ap-ply:ac())
 end
end

function cmbt_usew(atk,trg,w)
 local skv,ac,def=cmbt_atk(atk,trg,1,w)
 if rndi(0,99)<skv then
  if rndi(0,trg.lv)<=w.lv then
   _cmbt_eff(trg,w)
  else trg.efm=0 end
 end
end
function cmbt_msg(atk,trg,r)
 local act={' resist.',' stunned.',' is blinded.',' is poisoned.'}
 if r then if r>=0 then
	 ui_popup(trg.nme..' was hit for '..r..' of\ndamage.')
	elseif trg.snm=='bot' then
	 ui_popup(trg.nme..' is destroyed')
	else
  ui_popup(trg.nme..' is dead')
 end end
 if trg.efm then
  ui_popup(trg.nme..act[1+trg.efm])
 elseif not r then
  ui_popup(atk.nme..' misses.')
 end
 trg.efm=nil
end
--enemy
function en_new(md)
 local ac,mh=rndi(1,3),md.mh
 local t,lv=_enm[rndel(mh.enl)],mh.lv
 local en=cpy(t,{lv=lv})
 --weapon
 local typ=cpy(_itm[t[5]])
	typ.wpt=rndel(t[6])
	en.wpn=itm(typ,lv,rndi())
	en.wpn.pwr\=2
	--armour
	en.arm=itm(_itm['arm'],lv,rndi())
	for i=1,3 do en.arm.def[i]\=2	end
	--enemy features
 if type(t.nme)=='table' then
  en.ico+=ac-1
  en.nme=t.nme[ac]
  en.arm.ico=t.ico+2+ac
 elseif en.ico<0 then
	 local i=mh.fct.id
		if mh.trg then i=mh.trg.id end
		en.ico=38+i
	end
	en.hp=t[4]+rndi(10,12)+lv*5+ac*3
	en.mhp=en.hp
	en.wsk=4*lv\9
	en._ac=3-ac
	function en:ac()
	 return self._ac
	end
	function en:attack()
	 return self.wsk,self.wpn
	end
	function en:defence(w)--ac,def
	 return self._ac,cmbt_def(self.arm,w)
	end
	function en:heal(v)
  if (v) self.hp+=v 
  return self.hp
 end
	return en
end
-->8
--storage
function _save(i,v)
 dset(i,v);return i+1
end
function _load(i)
 return i+1,dget(i)
end

function save_itm(i,it)
 local v=0
 if it and it.id then
  v=(it.sd*256)|(it.id*16)|it.lv
 end return _save(i,v)
end
function load_itm(i)
 local i,v=_load(i)
 return i,itm_build(v)
end

function psave()
dset(1,ply_st)
if ply_st>0 then
 dset(2,ply_sd)
 local i=_save(3,ply_cr)
 --inventory
 for c=1,10 do
  i=save_itm(i,ply_inv[c])
 end
 --factions
 for c=1,4 do
  i=_save(i,(fct_pwr[c]*256)+ply_rel[c])
 end
 --shop
 for c=1,10 do
	 i=save_itm(i,_shpil[c])
	end
 i=_save(i,ply_mhp)--max hp
 i=_save(i,ply_hp)--curr. hp
 i=_save(i,ply_xp)--exp.points
 i=_save(i,ply_lv)--level
 i=_save(i,ply_skp)--skill point
	--skills
	for v in all(ply_skl) do
	 i=_save(i,v)
	end
	for c=1,2 do
	 i=save_itm(i,ply_eqp[c])
	end
end
end

function pload()
ply_st=dget(1)
if ply_st>0 then
 ply_sd=dget(2)
	local i,v=3
	i,ply_cr=_load(i)--credits
	--inventory
	for c=1,10 do
		i,ply_inv[c]=load_itm(i)
	end
	--factions
	for c=1,4 do
	 i,v=_load(i)
	 fct_pwr[c]=v\256
	 ply_rel[c]=v%256
	end
	--shop
	for c=1,10 do
	 --i,_shpil[c]=load_itm(i)
	 i,it=load_itm(i)
	 _shpil[c]=shop_cr(it or {})
	end
	--player
	i,ply_mhp=_load(i)--max health point
	i,ply_hp=_load(i)--current health point
	i,ply_xp=_load(i)--experience points
	i,ply_lv=_load(i)--level
	i,ply_skp=_load(i)--skill point
	--skills
	for c=1,#_skl do
		i,ply_skl[c]=_load(i)
	end
	--equip
	for c=1,2 do
		i,ply_eqp[c]=load_itm(i)
	end
end
end

function preset()
ply_st=0;for i=1,63 do dset(i,0) end
run()
end
__gfx__
79012117a666666aa666666aa666666aa666666aa666666a000000000000000000000000000000000bbbbbb00000000033300000333000000055550000dddd00
760214287777777777777777777bb777777777777777777700000000000000000000000000000000b000000b0000000000330bbb00330bbb005cb5000005d000
6d03455977777777772222777722217779999997741111470bbbb00000bbbb000000000000000000b000000b000000000003b0000003b000005bc5000005d000
d501233a77777777772222777722217779acc397741111470bbbb00000bbbb0055555555555dd5550b0000b0000000000bb3b3300bb3b330005cb5000005d000
0000000077777777772222777722c17779111397741111470d5d5060005d5d065d5665d5c6dccd6cccd5d5cc00000000b003b003b003b003005bc5000005d000
000000007777777777222d7777225377799999977433334711111111111111115d5555d5c66dd66c11111111000000000cccccc008888880005cb5000005d000
00000000777777777722227777222377777777777777777712222181000110005dddddd5c666666c01c11c10000000000011110000222200005bc5000005d000
0000000044444444442222444422234444444444444444441222211101122110555555555555555511c11c110000000000cccc00008888000055550000555500
1122444566aaaa6666aaaa666aa66aa666aaaa6666aaaa6600000000000000000000000000000000000000000000000000002000000000000000200000000000
666677777777777777777777777bb77777777777777777770044cc000333333000f550000033c0000cccccc00000000000008000020000000288888200000020
112244537777777777cccc7777ddd177777877777d1111d7040000c00338333000f550000333c0000ccaacc00000000000028200088200000088888000002880
112244537777777777cccc7777ddd1777c787aa77d1111d7040000c00008300000555f000333c00000caac000000000000088800088882000028882000288880
777777777777777777cccc7777ddb177744444477d1111d7040400c0000830000055ff000033cc0000aaaa000000000000288820288888820008880028888882
000000007777777777ccc57777dd5377777777777d3333d7040400c00008388005500ff00003ccc00aaaaaa00000000000888880088882000002820000288880
000000007777777777cccc7777ddd37777777777777777770044cc000008888005500ff00333ccc00aaaaaa00000000002888882088200000000800000002880
000000005555555555cccc5555ddd355555555555555555500000000000000000000000000000000000000000000000000002000020000000000200000000020
0000000055aaaa5555aaaa55555bb55555aaaa5555aaaa5500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddcdddddd11ddddd1110ddd666666dd666666d000ff000000ff0000006f000000ff000000440000000000000000000000000000000000000000000
00000000cccccccccc1111ccc111110cc6bbbb6cc600006c000ff000000ff0000006f000000ff000004ff4000000000000000000000000000000000000000000
00000000dcddddcdd116611dd166110bd6bbbb6dd600006d001141000055350000dddd000033c3000444c4400000000000000000000000000000000000000000
00000000dcddddcdd16cc61dd1661106d651516dd600006d0f01c0f00f0580f0060dd0f00f0330f00f44a4f00000000000000000000000000000000000000000
00000000ccccccccc16cc6bcc111110cc615156cc666666c0001100000055000000dd000000cc000004444000000000000000000000000000000000000000000
00000000dcddddddd116611ddd1110ddd666666ddcdddddd00100100005005000050050000300300004444000000000000000000000000000000000000000000
00000000555555555111111555555555566666655555555500100100005005000050050000300300005005000000000000000000000000000000000000000000
0088880055aaaa5555aaaa5555aaaa5555aaaa5555aaaa55000000000000000000000000000000000000000000000000000000000000000000000000dddddddd
080000805424444554244445542bb4455426644554266445000ff000000ff00000000000000000000000000000000000000000000000000000000000d775577d
808000085424444554666645566666055460064554600645000ff000000ff000000000000000000000000000000000000000000000000000005dd500d755557d
80080008524224455260064556666605526666455266664500dddd000044440000000000000000000000000000000000000000000000000055dccd55d755557d
80008008544442255466662556ddd60b54600625546006250f0dd0f00f0440f000000000000000000000000000000000000000000000000055dccd55d755557d
800008085442244554666d455ddbdd0d544664455446644500dddd0000444400000000000000000000000000000000000000000000000000005dd500d775577d
08000080542442455466664556ddd605542442455424424500d11d000042240000000000000000000000000000000000000000000000000000000000d555555d
00888800dddddddddd6666ddd666660ddddddddddddddddd005005000050050000000000000000000000000000000000000000000000000000000000dddddddd
0118811000000000000880001111111111111111111111110000000000000000000000000000000000000000000000000000c0000000c000dc00000000000000
50111105000000000a0110a01dddddd11dddddd11dddddd1000000000000000000000000000000000000000000000000000cd000000cd000cdc0000000000000
50a00a0500000000051111501dccccd11dbbbbd11d8888d1655555556dd555556dddddddadddddd5adddddd5accccccc000cd000000cd0000cdc000008888880
0000000000000000501cc1051dccccd11dbbbbd11d8888d100005dd06dddd00565555555a5555555a5555555a5555555000cd000000cd00000cdc00088878888
000000000a1881a0a011110a1ddccdd11ddbbdd11dd88dd100000dd00005dd05000d005d00005dc005005dc0000d005c000cd000000cd000000cdc5088777888
00000000001111000011110011dccd1111dbbd1111d88d1100000dd00000dd55000d000d00000dc005000dc0000d000c00666600005555000000cd5088878888
00000000051111500550055011dddd1111dddd1111dddd1100000000000000000000000000000dd000500dc00000000000044000050440000000554008888880
01111110500000055d5005d511111111111111111111111100000000000000000000000000000000000555500000000000044000050440000000000400000000
044884400000000000088000499999944933339449888894000000000000000000000000000000000000000000000000009999990099949900999499000cc000
42099024000022000409904049999994499999944999999400000000000000000000000000000000000000000000000009999999094994990949949900555500
400990040009000040499404444444444444444444444444000000dd000000dd0555555d000000550000005cadddddd6999444499994444999944449005cc500
00400400440440444004400424999942249339422498894265555555655555556ddddddda6666666addddddcad888866994000044940000449400204005cc500
0400004040488404040990402244442222444422224444220005dd5500dd5dd56ddddddda55ccc55a55ccc55a1cccc55940000009400000094020000005cc500
0020020000499400000990002222222222222222222222220000dd0000dd0dd00555555d0000000000000000a1111115940000009400000094000000005cc500
0000000022444422222442220244442002444420024444200000000000000000000ddd0000000000000000000000000040000000400000004020000000555500
01111110200000022000000200222200002222000022220000000000000000000000000000000000000000000000000040000000400000004000000000055000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000005500550055005500550055000055d0000055d0000055d00000e80000006c000000b300003333333
0000000000000000000000000000000000000000000000005dd55dd55dd55dd55dd55dd5000e80d00006c0d0000b30d000e88800006ccc0000b33300c3a3aa33
00000000000000000000000000000000000000000000000000cddc0000bddb00008dd80000e888d0006cccd000b333d000e88800006ccc0000b33300caaaaaa3
00000000000000000000000000000000000000000000000000cddc0000bddb00008dd80000e88800006ccc0000b33300007666000076660000766600c3a3a3a3
00000000000000000000000000000000000000000000000000cddc0000bddb00008dd80000e88800006ccc0000b33300007666000076660000766600c33aa3a3
000000000000000000000000000000000000000000000000005555000055550000555500000e80000006c000000b3000000760000007600000076000c3333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555550000000000000000008000080
000000000000000000000000000000000000000000000000000000000000000000000000000000000077770d000b000055555550000000000666666608080880
000000000000000000000000000000000000000000000000005dd500005dd500005dd5000000000007000dd0000bb00055ccc5500dddddd0cdd656dd08898980
00000000000000000000000000000000000000000000000055dccd5555dbbd5555d88d55000000007007d00500b333005ccccc50d655556dcd6d5d66899a9a98
00000000000000000000000000000000000000000000000055dccd5555dbbd5555d88d5500000000700d50050b3333305ccdcc5055cccc55cdd65d6689aaaa98
000000000000000000000000000000000000000000000000005dd500005dd500005dd500000000000dd000500b3333305ccccc50d655556dcd6656dd08999980
00000000000000000000000000000000000000000000000000000000000000000000000000000000d055550000b3330055ccc550d666666dc666666600888800
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555505dddddd50000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1010000100000001000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1070000100000001000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111010000116116111000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001110000000000101000000000000000000000000000000000000000000000000
00000000000111111000111111000111111000011111000111111000000000001010000000000101000000000000000000000000000000000000000000000000
000000000011ccccc101cccccc101cccccc1001ccccc101cccccc100000000001010000000000101000000000000000000000000000000000000000000000000
00000000001cc1111001cc111c101cc111c101cc1111001cc1111000000000001020000000000301000000000000000000000000000000000000000000000000
00000000001cc1110001cc111c101cc111c101cc1000001cc1100000000000001010000000000101000000000000000000000000000000000000000000000000
000000000001cccc1001cccccc101cccccc101cc1000001cccc10000000000001010000000000101000000000000000000000000000000000000000000000000
000000000000111cc101cc1111001cc111c101cc1000001cc1100000000000001010000000000101000000000000000000000000000000000000000000000000
000000000000001cc101cc0000001cc101c101cc1000001cc1000000000000001111115111100111000000000000000000000000000000000000000000000000
000000000001111cc101cc0000001cc101c101cc1111001cc1111000000000001000000000100101000000000000000000000000000000000000000000000000
00000000001ccccc1001cc0000001cc101c1001ccccc101cccccc100000000001000000000100401000000000000000000000000000000000000000000000000
00000000000111110000110000000110001000011111000111111000000000001000000000100101000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111000000000000000000000000000000000000000000000000
00011111000111111000111111000100001000111000000111111000111111000000000000000000000000000000000000000000000000000000000000000000
001ccccc101cccccc101cccccc101c1001c101cc1000001cccccc101cccccc100000000000000000000000000000000000000000000000000000000000000000
01cc1111001cc111c101cc111c101c1001c101cc1000001cc1111001cc111c100000000000000000000000000000000000000000000000000000000000000000
01cc1000001cc111c101cc111c101c1001c101cc1000001cc1100001cc111c100000000000000000000000000000000000000000000000000000000000000000
01cc1000001cccccc101cccccc101c1111c101cc1000001cccc10001cccccc100000000000000000000000000000000000000000000000000000000000000000
01cc1000001ccc111001cc111c101c1cc1c101cc1000001cc1100001ccc111000000000000000000000000000000000000000000000000000000000000000000
01cc1000001cc1c10001cc001c101c1cc1c101cc1000001cc1000001cc1c10000000000000000000000000000000000000000000000000000000000000000000
01cc1111001cc01c1001cc001c1001cccc1001cc1111001cc1111001cc01c1000000000000000000000000000000000000000000000000000000000000000000
001ccccc101cc001c101cc001c1001c11c1001cccccc101cccccc101cc001c100000000000000000000000000000000000000000000000000000000000000000
00011111000110001100110001000010010000111111000111111000110001100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000ccccccc000000000000000000000000000000000000000000000000600000000ccccccc000000000000
000000000000000000000000000000000000000000ccc0000000ccc000000000000000000000000000000000000000000006760000ccc0000000ccc000000000
0000000000000000000000000000000000000000cc0000054c40000cc000000000000ddd55500000000000000000000000006000cc0000054c40000cc0000000
000000000000000000000000000000000000000c000000054c4000000c000000ddddd6dcc5d5555500000000000000000000000c000000054c4000000c000000
00000000000000000000000000000000000000c0000000050000000000c00000d66666dcc5ddddd50000000000000000000000c0000000050000000000c00000
0000000000000000000000000000000000000c000000ddd500000000000c00000ddd66dd55dd5550000000000000000000000c000000ddd500000000000c0000
000000000000000000000000000000000000c00ddd00ddd500dddd000000c0000000dddd5555000000000000000000000000c00ddd00ddd500dddd000000c000
00000000000000000000000000000000000c000ddd00ddd500dddd0000660c000000000d500000000000000000000000000c000ddd00ddd500dddd0000660c00
00000000000000000000000000000000000c066ddd00ddd566dddd6600660c0000000000000000000000000000000000000c066ddd00ddd566dddd6600660c00
0000000000000000000000000000000000c0066ddd66ddd566dddd66dd6600c00000000000000000000000000000000000c0066ddd66ddd566dddd66dd6600c0
0000000000000000000000000000000000c0066ddd66ddd566dddd66dd6600c000000ddd55500000000000000000000000c0066ddd66ddd566dddd66dd6600c0
0000000000000000000000000000000000c0066ddd66ddd566dddd66dd6600c0000dd66d5dd55000000000000000000000c0066ddd66ddd566dddd66dd6600c0
000000000000000000000000000000000c0dd66ddd66ddd566dddd66dd66dd0c0dd6666d5dddd55000000000000000000c0dd66ddd66ddd566dddd66dd66dd0c
000000000000000000000000000000000c0dd66ddd66ddd566dddd66dd66dd0cd666aa6d5daaddd500000000000000000c0dd66ddd66ddd566dddd66dd66dd0c
000000000000000000000000000000000c0dd66ddd66ddd566dddd66dd66dd0cddddaa6d5daa555500000000000000000c0dd66ddd66ddd566dddd66dd66dd0c
00000000000000000000006000000000066666666666666666666666666666660000dddd55550000000000000000000006666666666666666666666666666666
00000000000000060000067600000000005555555555555555555555555555500000000000000000000000000000000000555555555555555555555555555550
00006000000000676000006000000000000055555555555555555555555550000000000000000000000000000000000000005555555555555555555555555000
00067600000000060000000000000000000000055555555555555555550000000000000000000000000000000000000000000005555555555555555555000000
00006000000000000000000000000000000000000055555555555550000000000000000000000000000000000000000000000000005555555555555000000000
00000000000000000000000000000000000000000000555555550000000000000000000000000000000000000000000000000000000055555555000000000000
00000000000000000000000060000000000000000000005555000000000000000000000000000000000000000000000000000006600000555500000000000000
000000000000000000000006760000000000000000000005500000000000000000000000000000000000000000000000000d6666d00000055000000060000000
00000000000000000000000060000000000000000000000550000000000000000000000000000000000000000000000000ddd66d000000055000000676000000
000000000006000000000000000000000000000000000005500000000000000000000000000000000000000000000000dd555dd0000000055000000060000000
06000000006760000000000000000000000000000000000550000000000000000000000000000000000000000000000005a5a500000000055000000000000000
67600000000600000000000000000000000000000000000550000000000000000000000000000000000000000000000000555000000000055000000000000000
06000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000050000000000000000
00000000000000000000000000060000000000000000000500000000000000000000000000000000000000000000000000000000000000050000000000000000
00000000000000000000000000676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010200000101010101000101010000000102000000000000000000000000000001020000010101010100000000000000010200000101000000000000000001010100000000000000000000000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01140018186251860010000186251862518625186251860017000186201862518000186251000010000186251860018600186251860018625186251300018625186000c0001100013000150000c0001100013000
013c0020025500255004550055500455004550055500755005550055500755007550045500455000550005500255002550045500555004550045500555007550055500555007550095500a550095500755009550
013c00201a54500000155451a5451c545020001a5451c5451d5451c5451a545185451a5450500005000050001a5450700021545070001c5451700018545170001a5450c0001c5450c0001a5450c0000c0000c000
010f00200c0730270026700100000c073000000e0000e0000c0730000000000100000c0730000000000000000c0730000000000110000c0730000010000100000c0730000001000110000c073000000000000000
011e0020055700557502565170000256510000055700557500100100000256518000045700457004575001000557005575025651500002565110000557005575025650f600025651500007570075700757500100
013c00201d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f1251d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f125
011e0020091350910009135020000200009100091350910009145050000500007100071400714007145091000913509100091350200002000091000913509100091450c0000c0000c0000c0000c0000c00000000
010f0020001631000000143170000f655100001500000163001631000000163180000f655100001300000163001631100000163150000f655110001300000163001630f65500163150000f655110001300000163
013c0020100350270026700100351f600000000e0300e035100350000000000100351f600000000000000000110350000000000110351f600000001003010035110350000001000110351f600000000000000000
011e00201813500000000001713500000000001513500000000001013010130101350000000000000000000015135000000000010135000000000000000000000000000000111301113011130111350000000000
010c00200c133100000061500615176551000000615006150c133100000061500615176551000000615006150c133110000061500615176551100000615006150c13329000006150061517655230000061500615
0118002002070020700207002070040700407004070040700c0700c0700c0700c0700a0700a0700a0700a0700e0700e0700e0700e0700d0700d0700d0700d070100701007010070100700e0700e0700e0700e075
011800200000015540155401554015545115401154011540115451354013540135401354510540105401054010545115401154011540115451054010540105401054513540135401354013545155401554015545
0118002009070090700907009070070700707007070070700907009070090700907002070020700207002070030700307003070030700a0700a0700a0700a0700707007070070700707007070070700707007075
01180020001001054010540105401054511540115401154011545105401054010540105450e5400e5400e5400e545075400754007540075450e5400e5400e5400e54505540055400554005540055400554005545
010c00201024500000000001023500000000001022500000000001022500000000001021500000000001021013245000000000013235000000000013225000000000013225000000000013215000000000013215
00100000091000000009100000000200002000091000400009100050000500005000071000710007100050000910000000091000000002000020000910004000091000c0000c0000c0000c0000c0000c0000c000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c100100000060000600176001000000600006000c100100000060000600176001000000600006000c100110000060000600176001100000600006000c10029000006000060017600230000060000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 00 43 44
00 01 00 43 02
00 01 00 43 02
00 41 00 04 03
00 05 00 04 03
02 41 00 06 44
01 08 07 03 06
00 08 07 03 06
00 08 07 03 09
00 08 07 03 09
00 08 07 03 44
02 08 07 03 44
01 0b 42 0a 44
00 0b 42 0a 44
00 0b 0c 0a 44
00 0b 0c 0a 44
00 0d 42 0a 44
00 0d 42 0a 44
00 0d 0e 0a 44
00 0d 0e 0a 44
00 0d 0f 0a 44
02 0d 0f 0a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
