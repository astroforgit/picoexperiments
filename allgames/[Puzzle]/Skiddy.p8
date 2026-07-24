pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--bigbangpixel's
--skiddy
--v1.1 - tk 7005 - ch 35296 - cm 99.47%

--zep's font
fdat = [[  0000.0000! 739c.e038" 5280.0000# 02be.afa8$ 23e8.e2f8% 0674.45cc& 6414.c934' 2100.0000( 3318.c618) 618c.6330* 012a.ea90+ 0109.f210, 0000.0230- 0000.e000. 0000.0030/ 3198.cc600 fef7.bdfc1 f18c.637c2 f8ff.8c7c3 f8de.31fc4 defe.318c5 fe3e.31fc6 fe3f.bdfc7 f8cc.c6308 feff.bdfc9 fefe.31fc: 0300.0600; 0300.0660< 0199.8618= 001c.0700> 030c.3330? f0c6.e030@ 746f.783ca 76f7.fdecb f6fd.bdf8c 76f1.8db8d f6f7.bdf8e 7e3d.8c3cf 7e3d.8c60g 7e31.bdbch deff.bdeci f318.c678j f98c.6370k def9.bdecl c631.8c7cm dfff.bdecn f6f7.bdeco 76f7.bdb8p f6f7.ec60q 76f7.bf3cr f6f7.cdecs 7e1c.31f8t fb18.c630u def7.bdb8v def7.b710w def7.ffecx dec9.bdecy defe.31f8z f8cc.cc7c[ 7318.c638\ 630c.618c] 718c.6338^ 2280.0000_ 0000.007c``4100.0000`a001f.bdf4`bc63d.bdfc`c001f.8c3c`d18df.bdbc`e001d.be3c`f3b19.f630`g7ef6.f1fa`hc63d.bdec`i6018.c618`j318c.6372`kc6f5.cd6c`l6318.c618`m0015.fdec`n003d.bdec`o001f.bdf8`pf6f7.ec62`q7ef6.f18e`r001d.bc60`s001f.c3f8`t633c.c618`u0037.bdbc`v0037.b510`w0037.bfa8`x0036.edec`ydef6.f1ba`z003e.667c{ 0188.c218| 0108.4210} 0184.3118~ 02a8.0000`*013e.e500]]
cmap={}
for i=0,#fdat/11 do
	local p=1+i*11
	cmap[sub(fdat,p,p+1)] = tonum("0x"..sub(fdat,p+2,p+10))
end

function pr(str,sx,sy,col)
	local sx0=sx
	local p=1
	while (p <= #str) do
		local c=sub(str,p,p)
		local v

		if c=="\n" then
			--linebreak
			sy+=9 sx=sx0
		else
			--single (a)
			v = cmap[c.." "]
			if not v then
			--double (`a)
			v= cmap[sub(str,p,p+1)]
			p+=1
		end
		--adj height
		local sy1=sy
		if (band(v,0x0.0002)>0)sy1+=2

		--draw pixels
		for y=sy1,sy1+5 do
			for x=sx,sx+4 do
				if (band(v,0x8000)<0) pset(x,y,col)
					v=rotl(v,1)
				end
			end
			sx+=6
		end
		p+=1
	end
end

c2n={} --char to int
chars="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,"

function b_print(s,x,y,c)
	margin+=4
	s_print(s,x,y,c)
	margin-=4
end
			
function s_print(s,x,y,c)
	if x == 256 then x = 64-2*#s
	elseif x == 512 then x = 128-4*#s-margin
	end
	
	?s,x+1,y,1
	?s,x,y+1,1
	?s,x+1,y+1,1
	?s,x,y,c
	
	return x
end

function s_big_print(s,x,y,c)	
	if x == 256 then x = 64-3*#s
	elseif x == 512 then x = 128-6*#s
	end

	pr(s,x+1,y+1,1)			
	pr(s,x,y,c)
end

function _init()
	cartdata("bbp_skiddy")

	menuitem(2, lbl_clr, clear_data)
	menuitem(3, lbl_mus, music_toggle)

	--init char to int function
	for i=1,#chars do
		s=sub(chars,i,i)
		c2n[s]=i-1
	end

	l={}

	--load cart data
	for i=1,64 do
		pdata[i] = dget(i)
	end
	
	if (pdata[62]==0) pdata[62]=1 --set starting level	
	
	--set player's data
	p={l=1}

	cx,cy = 0,0 --camera offsets
	do_sky()

	for i=1,8 do
		cloud_add(rnd(128),rnd(128))
	end

	cdir=1 --set clouds direction
	
	music()
	to_title()
end

function get_slot(l)
	assert(l<=110)

	local slot = l%4
	if(slot==0) slot = 4
	slot-=1

	local num = flr((l-1)/4)+1

	return num,slot
end

function clear_data()
	old_u = _update
	old_d = _draw

	_update = cl_update
	_draw = cl_draw
end

function music_toggle()
	if music_on then music_on = false else music_on = true end
	if music_on then
		music()
	else
		music(-1)
	end
end

function save_level(l,pass,mm,cm,perf)
	--save data structure:
	--[0] - header, [1..30]-120 easy levels data, [31..60]-120 hard levels data, [61]-tutorial, [62]-last level - [63..64]-reserved
	--4 levels per slot, 1 byte per level, (+space for coin levels)
	--b0 - passed, b1 - mm, b2 - cm, b3 - perfect, b4 b5 b6 b7

	local num,slot = get_slot(l)

	local ld=0

	if(pass)ld = bor(ld,pass_mask)
	if(mm)	ld = bor(ld,mm_mask)
	if(cm)	ld = bor(ld,cm_mask)
	if(perf)ld = bor(ld,perf_mask)

	pdata[num] = bor(shl(ld,slot*8),pdata[num])
	--printh("aft set: "..tostr(pdata[num],true).." "..pdata[num])
	dset(num,pdata[num])
	
	num = 62
	--if (l > pdata[num]) then 
		pdata[num] = l
		dset(num,pdata[num])
	--end
end

function get_level(l,s)
	local num,slot = get_slot(l)

	local ld=0

	if s=="mm" then ld = bor(ld,mm_mask)
	elseif s=="cm" then	ld = bor(ld,cm_mask)
	elseif s=="pf" then ld = bor(ld,perf_mask) end

	--printh("getting "..s.." from num: "..num.." slot: "..slot)
	--printh("pdata: "..tostr(pdata[num],true).." "..pdata[num])
	ld = shl(ld,slot*8)

	return band(ld,pdata[num]) == ld
end

function _draw()
end

function _update()
end

function cloud_draw()
-- draw shadows first
	for cloud in all(clouds) do
		for p=1,parts do
			circfill(cloud.x+cloud.parts[p].x+c_sx,cloud.y+cloud.parts[p].y+c_sx,cloud.parts[p].r,6)
		end
	end
	for cloud in all(clouds) do
		for p=1,parts do
			circfill(cloud.x+cloud.parts[p].x,cloud.y+cloud.parts[p].y,cloud.parts[p].r-1,7)
		end
	end
end

function cloud_update()	
	for cloud in all(clouds) do
		local sp = cloud.s/30
		if cdir == 1 then
			cloud.x+=sp
			if (cloud.x > 128) del(clouds,cloud) cloud_add(-1,rnd(128))
		elseif cdir == 0 then
			cloud.x-=sp
			if (cloud.x+cloud.w < 0) del(clouds,cloud) cloud_add(-128,rnd(128))
		elseif cdir == 3 then
			cloud.y+=sp
			if (cloud.y-.5* c_max_r > 128) del(clouds,cloud) cloud_add(rnd(128),-1)
		else
			cloud.y-=sp
			if (cloud.y+5* c_max_r <0) del(clouds,cloud) cloud_add(rnd(128),-128)
		end
	end
end

function cloud_add(xpos,ypos)
		local c={}
		c.parts={}
		c.w=0
		local lr=0

		for p=1,parts do
			c.parts[p] = {}
			local r = flr(c_min_r+rnd(c_max_r-c_min_r))
			c.parts[p].r = r
			c.parts[p].x = lr+r
			c.parts[p].y = flr(-.5+rnd(1)*r)
			c.w+=lr
			lr=flr(1.5*r)
		end

		if xpos == -1 then
			c.x=-c.w
		elseif xpos ==-128 then
			c.x=-xpos
		else
			c.x=xpos
		end

		if ypos == -1 then
			c.y=-flr(c_max_r*.5)
		elseif ypos ==-128 then
			c.y=-ypos
		else
			c.y=ypos
		end
		c.s = 5+rnd(c_speed)
		add(clouds,c)
end

function cl_draw()
	local oy = 48
	map(8,0,0,0,16,16)
	cloud_draw()
	s_print(lbl_cl1,4,oy,8)
	s_print(lbl_cl2,4,oy+16,7)
	s_print(lbl_cl3,4,oy+32,7)
	draw_bar(map_timer,lbl_clr)
end

function cl_update()
	if (not btn(5)) map_timer = 0

	if btn(5) then
		map_timer+=1
		map_timer%=rst_delay
		if (map_timer==0) for p=1,#pdata do pdata[p]=0 dset(p) end extcmd("reset") return
	end

	if (btnp(4)) _update = old_u _draw=old_d return
	cloud_update()
end

function w_update()

	if (not btn(5)) ready = true

	local wrl = (flr((s_lv-1)/10)+1)

	if (ready and btnp(4)) to_level() l_reset()return
	if (ready and btnp(5)) to_title() return

	cloud_update()

	if btnp(2) then sfx(50) s_lv-= 10 if s_lv < 1 then s_lv = 110 end
	wrl = (flr((s_lv-1)/10)+1)
	elseif btnp(3) then sfx(50) s_lv += 10 if s_lv > 110 then s_lv = 1 end
	wrl = (flr((s_lv-1)/10)+1)
	elseif btnp(0) then sfx(50) s_lv-=1 if s_lv <= 10*(wrl-1) then s_lv += 10 end
	elseif btnp(1) then sfx(50) s_lv+=1 if s_lv > 10*wrl then s_lv -= 10 end
	end

	p.l = s_lv

end

even=false

function w_draw()
--sky
	map(8,0,0,0,16,16)

	cloud_draw()

	local st = s_lv%10
	if (st==0) st=10

	local wrl = (flr((s_lv-1)/10)+1)


	local oy = 68

	local med = 0

	for lv=1,10 do
		local ox = -12
		local yy = 0
		if (lv%2 == 1) yy=-24 ox+=4
		local sp=lv*12
		tx=ox+sp
		ty=oy+yy
		local ll = lv + (wrl-1)*10
		if get_level(ll,"mm") then spr(47, tx, 8+ty) med+=1 else spr (63, tx, 8+ty) end
		if get_level(ll,"cm") then spr(31, tx+8, 8+ty) med+=1 else spr (63, tx+8, 8+ty) end
		if get_level(ll,"pf") then spr(15, tx+4, ty) med+=1 else spr (63, tx+4, ty) end
		if(lv == st and even) rect(tx-1,ty-1,tx+16,ty+16,7)
	end

	ox = margin
	oy = 12

	s_print("‹  ‘",ox,4,7)
	s_print(lbl_lev..wrl.."-"..st,ox,oy,7)
	--s_print(s_lv,ox,oy+10,7)

	s_print(lbl_mdl..med.."/"..med_lvl,ox,92,7)
	
	local s = lbl_wrl..wrl	
		
	if wrl<10 then		
		margin+=4
		local rx = s_print(s,512,oy,7)
		margin-=4
		s_print("”  ƒ",rx,4,7)
	else		
		local rx = s_print(s,512,oy,7)
		s_print("”  ƒ",rx,4,7)	
	end
	
	ox=90
	for ic in all(l_icons[wrl]) do
		spr(ic,ox,oy+10)
		ox+=10
	end	
	
	s = lbl_tot..p.tot.."/"..med_tot
	
	s_print(s,512,92,7)
	
	s_print(lbl_ply,margin,120,7)
	b_print(lbl_ttl,512,120,7)
	
	even = not even

	--print_stat()
end

function print_stat()
	s_print("mem: "..stat(0),1,1,7)
	s_print("cpu: "..(stat(1)*100),85,1,7)
end

function t_update()
	if (btnp(4)) cam_rst() to_map() return
	if (btnp(5)) p.l=-1 cam_rst() tut_step = 1 _update = l_update _draw=tut_draw l_reset() return

	cloud_update()

	local r_spd = 0.1667/5--1 rotation (360) takes /n sec : 0.1667/1 = 1sec
	
	cy=(cy+r_spd) % 1
end

function t_draw()
	--sky
	local tx = 16	
	
	map(8,0,0,0,16,16)
	cloud_draw()

	--gray logo
	for p=2,15 do pal (p,1) end	
	pal(5,5)
	pal(6,6)
	pal(7,7)
	map(24,0,tx,32+2*sin(cy-.1),16,16)	
		
	pal()
	for p=5,7 do palt (p,1) end
	palt(1,1)	
	
	--gray logo
	logo_pal(2)
 	map(24,0,tx,32+2.5*sin(cy-.1),16,16)
	
	--brown logo
	--logo_pal(2)
	map(24,0,tx,32+2.75*sin(cy-.07),16,16)
	
	--normal red logo
	pal()
	for p=5,7 do palt (p,1) end
	palt(1,1)	
	map(24,0,tx,32+4*sin(cy-.025),16,16)		
	map(24,0,tx,32+4*sin(cy),16,16)		

	pal()
	s_big_print(lbl_tag,256,68,7)	
	s_print(lbl_crd,256,82,7)		
	
	s_print(lbl_ply,margin,120,7)
	b_print(lbl_tut,512,120,7)
	--print_stat()
end

function logo_pal(r_col)
	for p=8,10 do pal (p,r_col) end
	pal(2,r_col)
	pal(4,r_col)
	pal(14,r_col)
	pal(15,r_col)	
end

function do_mult()
	if mult == 0 then
		mult = m1
	elseif mult == m1 then
		mult = m2
	elseif mult == m2 then
		mult = m3
	else mult = m4
	end
	return mult
end

function mc_calc(t)
	mult = 0
	tot = 0
	for y=1,l.h-2 do
		for x=1,l.w-2 do
			if (mget(x,y) == t)	tot += do_mult()
		end
	end
	return tot
end

function chain_r(sk,x,y)
	mset(x,y,mget(x,y+8))
	local index = l.w*y + x
	m[m_i[index]].scoring = true
	--m[m_i[index]].frm = 0

	p.score += do_mult()
	if (sk == mget(x+1,y)) chain_r(sk,x+1,y)
	if (sk == mget(x-1,y)) chain_r(sk,x-1,y)
	if (sk == mget(x,y+1)) chain_r(sk,x,y+1)
	if (sk == mget(x,y-1)) chain_r(sk,x,y-1)
end

--block functions

function b_set(x,y)
	local t=0
	local att = 0

	local isl = false
	local isy = false

	local n = false
	local e = false
	local s = false
	local w = false

	if y > 0 then
		if fget(mget(x, y - 1))==1 then
			att+=1
			isy = true
			n = true
		end
	end

	if y < l.h - 1 then
		if fget(mget(x, y + 1))==1 then
			att+=1
			isy = true
			s = true
		end
	end

	if x > 0 then
		if fget(mget(x - 1, y))==1 then
			att+=1
			if (att==2) isl = true
			w = true
		end
	end

	if x < l.w - 1 then
		if fget(mget(x + 1, y))==1 then
			att+=1
			if(att == 2 and isy) isl = true
			e = true
		end
	end

	if att == 0 then
		--4side
		t=18
	elseif att == 1 then
		--3side
		if n then
		t=37
		elseif s then
		t=5
		elseif w then
		t=22
		elseif e then
		t=20
		end
	elseif att == 2 then
		--2side

		if not isl then
			if n and s then t=16
			else--if w and e then
				t=32
			end
		else
			if n and w then t = 35
			elseif n and e then t = 33
			elseif s and e then t = 1
			elseif s and w then t = 3
			end

		end
	elseif att == 3 then
		--1side
		if not n then
		t=2
		elseif not s then
		t=34
		elseif not e then
		t=19
		elseif not w then
		t=17
		end
	elseif att == 4 then
		--empty
		t=21
	end

	return t
end

--level functions

function l_make(i)
	if i == -1 then
		s = tut_l
	else
		s = lev[i]
	end

	l.id = i
	l.w = tonum(sub(s,1,1))
	l.h = tonum(sub(s,2,2))
	l.mm = tonum(sub(s,3,3))
	l.cm=0

	local even = true
	local pos = 0
	local t = 18

	--fill borders and inner plane	
	local t_off=0
	if(p.l >80) t_off=3
	
	for y=0,l.h-1 do
		for x=0,l.w-1 do
			if x==0 or y==0 or x== l.w-1 or y==l.h-1 then
				t = 18				
			else
				if not even then
					t=4+t_off					
				else
					t=36+t_off					
				end
			end
			mset(x,y,t)
			mset(x,draw_board_offset+y,t)
			even = not even
		end
		if ((l.w % 2) == 0) even = not even
	end

	even = true

	for cc=4, #s do

		ss = sub(s,cc,cc)

		if even then
			pos = c2n[ss]
			--print(sub(s,cc,cc) .. "=" .. pos)
		else
			local y = flr(pos/l.w)
			local x = pos % l.w
			if ss == "p" then
				if x==0 or y==0 or x== l.w-1 or y==l.h-1 then
					t = goal_p
					mset(x,draw_board_offset+y,t)
				else
					t = skiddy_p
				end
			elseif ss == "s" then
				if x==0 or y==0 or x== l.w-1 or y==l.h-1 then
					t = goal_s
					mset(x,draw_board_offset+y,t)
				else
					t = skiddy_s
				end
			elseif ss == "c" then
				t = box
			elseif ss == "g" then
				t = ice
			elseif ss == "f" then
				t = pit
				mset(x,draw_board_offset+y,t)
			elseif ss == "b" then
				t = 18
				mset(x,draw_board_offset+y,t)
			end
			mset(x,y,t)
			--print (x.."  "..y.."  "..ss.."  "..t)
		end
		even = not even
	end

	m={}
	m_i={}

	for y=0,l.h-1 do
		for x=0,l.w-1 do
			local b = mget(x,y)
			if b!= goal_p and b!= goal_s and fget(b) == 1 then
				t = b_set(x,y)
				if (t >0) mset(x,y,t) mset(x,draw_board_offset+y,t)
			end
			if (fget(b,1)) m_add(x,y,x,y)
		end
	end

	--set max combo
	l.cm += mc_calc(skiddy_p)
	l.cm += mc_calc(skiddy_s)

	--init level
	p.score=0
	p.moves=l.mm+10
	p.combos = {}
	--set camera
	cam_rst()
	if (p.l >-1) menuitem(1, lbl_rst, l_reset)
	state="wait"
end

function l_next()
	p.l = (p.l)%#lev+1
	l_reset()
end

function l_resolve()
	sx=1
	sy=1				
	ex=l.w-2
	ey=l.h-2
	dx=1
	dy=1
	if dir <2 then
		--h
		cy=0
		dy=1
		if dir == 0 then
			dx =1
		else
			dx=-1
			sx=l.w-2
			ex=1
		end
		cx=dx*2
	else
		--v
		cx=0
		dx=1
		if dir == 2 then
			dy =1
		else
			dy=-1
			sy=l.h-2
			ey=1
		end
		cy=dy*2
	end

	for y=sy, (dy*ey + 1)/dy, dy do
		for x=sx, (dx*ex + 1)/dx, dx do
			local b=mget(x,y)
			if fget(b) == 3 then
				if dir <2 then
					do_box(dx, 0, ex, ey, x, y, 0, y)
				else
					do_box(0, dy, ex, ey, x, y, x, 0)
				end
			elseif fget(b,1) then --> goal and mget(x,y) < mov then
				if dir<2 then
					do_row(dx,sx,x,y)
				else
					do_col(dy,sy,x,y)
				end	 		
			end			
		end	
	end
	on_box = false;
end

function l_update()
	cloud_update()
	if state == "wait" then
		if p.l == -1 then
			tut_input()
		else
			do_input()
		end
	elseif state == "move" then
		m={} -- moveables

		for x=1, (l.w)*(l.h) do m_i[x]=0 end

		l_resolve()

		for x=1,l.w-2 do
			for y=1,l.h-2 do
				local sk = mget (x,y)
				if fget(sk,7) then
					mult=0
					chain_r(sk+16,x,y)
					local a = 1
					if (mult>100) a = combos[mult]
					if sk == skiddy_p-s_offset then
						add(p.combos,{a,skiddy_p})
					else
						add(p.combos,{a,skiddy_s})
					end
				end
			end
		end

		scoring = false

		if not hasmoved then
			cam_rst()
		else
			if (p.moves>-1)	p.moves-=1
			cdir=dir
			hasmoved=false
		end
		stp = 2 --anim step
		state="moving" 	
	elseif state == "moving" then
		if not m_update() then
			for i in all(m) do
				if (i.scoring and i.sp != sp_win) i.frm = 0 i.sp = sp_win i.snd=55 --switch to win anim
				if (not i.scoring ) i.sp = nil
			end
			state="end"
			stp=1
		end
	elseif state == "end" then
		if not m_anim() then

			tots=m_count()

			if m_count() == 0 then
				state="win"
			else
				state="wait"
			end

			if (p.l==-1) tut_step+=1

		end
	elseif state == "win" then
		menuitem(1)
		if (p.l > -1) save_level(l.id,true,p.moves == 10,p.score == l.cm,p.score == l.cm and p.moves == 10)
		bt=0
		step=0
		if p.score == l.cm and p.moves == 10 then tot_steps=6 else tot_steps = 4 end
		count_medals()		
		_update = s_update
		_draw = s_draw
		music(-1)
		if p.moves >-1 then
			sfx(25) --win music
		else
			sfx(26) --lose music
		end
 	end
end

function l_reset()
	l_make(p.l)
end

function l_draw()
	--sky
	map(8,0,0,0,16,16)

	cloud_draw()

 	cam_update()

	local mx = ((16-l.w)/2)*8
	local my = ((16-l.h)/2)*8

	camera(cx,cy)

	rectfill(mx+2,my+2,mx+1+8*l.w,my+1+8*l.h,5)

	--set world color
	if (p.l > 40 and p.l<=60) or p.l > 80then
		pal(2,3)
		pal(3,2)
		pal(14,11)
		pal(11,14)
	elseif (p.l > 30 and p.l<=60) or p.l > 70then
		pal(3, 7)
		pal(11, 6)
		pal(9, 4)
		pal(10, 9)
		pal(13, 3)
		pal(6, 11)
	elseif p.l > 20 or p.l >60 then
		pal(3, 9)
		pal(11, 10)
		pal(9, 14)
		pal(10, 15)
	end
	pal(12,9) -- for yellow goal recolor
	map(0,8,mx,my,l.w,l.h)

	pal()

	for i in all(m)	do
		m_draw(i,mx,my)
		--spr(i.t,mx+i.x,my+i.y)
		--[[if i.delay then
			print(i.delay,mx+i.x+1,my+i.y-8+1,1)
			print(i.delay,mx+i.x,my+i.y-8,11)
		end	]]
	end

	camera()

	local ox = margin
	local oy = 12	

	--rectfill(ox,oy,ox+4*#("moves:"..p.moves)-1,oy+5,13)
	st = l.id%10
	if (st==0) st=10
	s_print(lbl_lev..(flr((l.id-1)/10)+1).."-"..st,ox,oy,7)
	oy+=10

	print_moves()

	draw_bar(rst_timer,lbl_rst)
	draw_bar(map_timer,lbl_btm)

 --[[debug
	local dcol = 3
	ox=98
	oy=90

	print(state,ox+8,oy,dcol)

	print ("s", ox,oy+10,dcol)
	print ("d", ox+10,oy+10,dcol)
	print ("e", ox+20,oy+10,dcol)
	print ("x", ox-10,oy+20,dcol)
	print ("y", ox-10,oy+30,dcol)

	print (sx, ox, oy+20,dcol)
	print (sy, ox, oy+30,dcol)

	print (ex, ox+10, oy+20,dcol)
	print (ey, ox+10, oy+30,dcol)

	print (dx, ox+20, oy+20,dcol)
	print (dy, ox+20, oy+30,dcol)
 ]]--
	if (p.moves< l.mm+10) s_print(lbl_rxt,margin,120,7)
	b_print(lbl_map,512,120,7)
 	--print_stat()
end

function draw_bar(t,s)
	if(t>0) rectfill(10,108,117,114,0) rectfill(10,108,10+(107/rst_delay)*t,114,8) print(s,64-2*#s,109,7)
end

--score screen functions

-- waits t frames
function sch_delay(t)
	for c=1,t do
		yield()
	end
end

function next_step(t)	
	for i = 1,t do
		if step == 0 then
			sch_delay(50)		
		else			
			sch_delay(15)			
		end				
		step+=1
		sfx(53)
	end	
end

function s_update()
	if (step == 0 and not scene_update_cor) scene_update_cor = cocreate(next_step)

	if scene_update_cor then
		if costatus(scene_update_cor) != 'dead' then
			if p.l == -1 then
				coresume(scene_update_cor,2)
			else
				coresume(scene_update_cor,tot_steps)
			end
		else
			scene_update_cor = nil
		end
	else		
		if btnp(4) and step < tot_steps then
				tut_step+=1
				scene_update_cor = cocreate(next_step)
		elseif btnp(4) and step == tot_steps then		
			if (music_on) music()
			if p.l == -1 then
				to_title()
				if pdata[61] == 0 then
					pdata[61] = 1
					dset(61,pdata[61])					
				end	
			else				
				to_level()
				if p.moves > -1 then					
					if p.tot == 330 then
						medals={}
						bt=0
						_update=end_update
						_draw=end_draw
					else
						l_next()					
					end	
				else			
					l_reset()
				end
			end
		elseif btnp(5) and p.l > -1 and step == tot_steps then		
			if (p.tot < 330 and music_on) music()			
			if p.score == l.cm and p.moves == 10 then
				if (p.tot == 330) return
				to_map()
			elseif p.moves>-1 then
				if (p.tot == 330) return
				to_level()
				l_reset()
			else
				to_map()
			end
		elseif (p.l==-1 and btnp(5) and pdata[61] > 0) then to_title() return		
		end
	end
	cloud_update()
end

function s_draw()
	bt+=2
	local lbl = lbl_lev..(flr((l.id-1)/10)+1).."-"..st..lbl_cmp
	local col = 7
	local s, s2
	st = l.id%10
	if (st==0) st=10
	
	if p.score == l.cm and p.moves == 10 then
		s=lbl_nxt
		s2=lbl_map		
		rotate_bg()

		if p.l == -1 then
			lbl = lbl_tlv..lbl_cmp
		end
		
		if step >= tot_steps-1 then
			spr(63, 100, 75)
			s_big_print(lbl_prf,256,76,col)
			if (step == tot_steps)	spr(15, 100, 75)
		end
		
	else
		map(8,0,0,0,16,16) --sky

		cloud_draw()

		if p.moves>-1 then
			s=lbl_nxt
			s2=lbl_rtx
		else
			lbl = lbl_lev..(flr((l.id-1)/10)+1).."-"..st..lbl_fld			
			s=lbl_rto
			s2=lbl_map
		end
	end
	
	s_big_print(lbl, 256,28, col)

	if p.l == -1 and step>0 then
		local tut_label = tut_txt[tut_step]
		s_print(tut_label, margin, 94, col)
		if(not scene_update_cor) s_print(lbl_nxt, margin, 120, col)
		if (step == tot_steps) s_print(tut_txt[9],256,8,col)
	elseif step == tot_steps then
		s_print(s,margin,120,col)
		if (p.tot<330 or p.moves==-1) b_print(s2,512,120,col)
	end

	if step >0 then
		local oy = 46
		spr(63, 100, oy-1)
		s=lbl_mov
		local ox = s_print(s,256,oy,col)
		if step >1 then
			if p.moves < 10 or p.moves<0 then
				line(ox-3,oy+3,ox+#s*4+4,oy+3,1)
				line(ox-4,oy+2,ox+#s*4+3,oy+2,col)
			else
				spr(47, 100, oy-1)
			end
			
			if step >2 then
				oy = 56
				spr(63, 100 , oy-1)
				s=lbl_cmb
				ox = s_print(s,256,oy,col)
				draw_combos(64)
				if step >3 then
					if p.score != l.cm or p.moves < 0 then
						line(ox-3,oy+3,ox+#s*4+4,oy+3,1)
						line(ox-4,oy+2,ox+#s*4+3,oy+2,col)
					else
						spr(31, 100, oy-1)
					end
				end
			end
		end
	end
	--s_print(step,1,10,7)
	--print_stat()
end

mt=15
function medal_add()
		local c={}
		c.t = mt	
		c.x=60
		c.y=60		
		c.sy = (-2 + rnd(5))
		c.sx = (-2 + rnd(5))		
		add(medals,c)
		mt+=16
		if(mt>47)mt=15
end

function end_update()

	if (btnp(5)) to_map() return

	if (#medals < 110)	medal_add()
	for md in all(medals) do
		md.x+=md.sx
		md.y+=md.sy
		if (md.x > 128 or md.x<-8 or md.y <-8 or md.y>128) del(medals,md) medal_add()
	end	
end

function end_draw()
	bt+=2
	rotate_bg()
	
	for md in all(medals) do
		spr(md.t,md.x,md.y)
	end
	
	spr(12,60-4,60-4)
	spr(13,60+4,60-4)
	spr(28,60-4,60+4)
	spr(29,60+4,60+4)
	--spr(skiddy_p,60,60)
	
	s_big_print(lbl_cgr,256,28,7)
	s_print(lbl_end,(128-(#lbl_end*2))/2,90,7)
	b_print(lbl_ttl,512,120,7)
end

function rotate_bg()
		--rotating bg
		local c=0 ln=127
		for t=1,ln do
			c=flr(1+((t+bt)/21)%3)
			line(t,0,ln-t,ln,colors[c])
			line(0,ln-t,ln,t,colors[c])
		end
end

function count_medals()
	p.tot = 0
	for ll=1,110 do
		if (get_level(ll,"mm")) p.tot+=1
		if (get_level(ll,"cm")) p.tot+=1
		if (get_level(ll,"pf")) p.tot+=1
	end
end

function to_map()
	s_lv=pdata[62]
	count_medals()
	_update=w_update
	_draw=w_draw
end

function to_title()		
	_update = t_update
	_draw = t_draw
end

function to_level()
	_update=l_update
	_draw=l_draw
end

function do_input()
	if (not btn(4)) rst_timer = 0
	if (not btn(5)) map_timer = 0

	if btn(4) and p.moves< l.mm+10 then
		rst_timer+=1
		rst_timer%=rst_delay
		if (rst_timer==0) l_reset() return
	elseif btn(5) then
		map_timer+=1
		map_timer%=rst_delay
		if (map_timer==0) to_map() ready = false return
	--elseif btnp(5,1) then
		--l_next() --@remove
	else
		dir = -1
		if btnp(2) then dir=2 sp = sp_up
		elseif btnp(3) then dir=3 sp = sp_dn
		elseif btnp(0) then dir=0 sp = sp_lf
		elseif btnp(1) then dir=1 sp = sp_rt
		end

		if dir>-1 then
			state = "move"
			--a=30
		end
	end
end

function do_sky()
--sky map expansion
	for x=draw_board_offset+1, draw_board_offset+sky_size -1 do
		for y= 0, sky_size -1 do
			mset(x,y,mget(draw_board_offset,y))
		end
	end
end

function draw_combos(y)
	local ox=0
	for i in all (p.combos) do
		for x=0, i[1]-1 do
			ox+=8
		end
		ox+=4
	end
	ox = (128-ox)/2	+ 2

	for i in all (p.combos) do
		--print(i[1]..i[2].."  ",10+ox,y,7)
		for x=0, i[1]-1 do
			spr(i[2],ox,y) --todo, finish this
			ox+=8
		end
		ox+=4
	end
end

--tutorial functions

function tut_input()
	dir = -1
	if (btnp(5) and pdata[61]>0) to_title() return
	if btnp(4) then
		if tut_step == 1 then
			--tut_step += 1
		elseif tut_step == 2 then
			dir = 0 --left
			sp = sp_lf
		elseif tut_step == 3 then
			dir = 2 --up
			sp = sp_up
		elseif tut_step == 4 then
			dir = 1 --right
			sp = sp_rt
		elseif tut_step == 5 then
			dir = 2
			sp = sp_up
		end
		
		if dir > -1 then state = "move"
		else
			tut_step += 1
		end		
	end
end

function tut_draw()
	--sky
	map(8,0,0,0,16,16)

	cloud_draw()
 	cam_update()

	local mx = ((16-l.w)/2)*8
	local my = ((16-l.h)/2)*8

	camera(cx,cy)

	rectfill(mx+2,my+2,mx+1+8*l.w,my+1+8*l.h,5)

	map(0,8,mx,my,l.w,l.h)

	for i in all(m)	do
		m_draw(i,mx,my)
	end

	camera()	

	st = l.id%10
	if (st==0) st=10

	print_moves()

	local tut_label = tut_txt[tut_step]
	if (tut_step<=5) s_print(tut_label, margin, 94, 7)	
	if (state!="moving") s_print(lbl_nxt, margin, 120,7)
end

function print_moves()
	local pm = p.moves	
	local col = 7

	if pm<=0 then col = 8
	elseif (pm==10 and state =="wait") or pm<10 then col = 10
	end
	
	if pm<0 then pm = 0
	elseif pm<10 then pm= " "..pm
	end
	s_print(lbl_mxx..pm,512,12,col)
end

function cam_rst()
	cx=0
	cy=0	
end

function cam_update()
	if cx>0 then cx-=.5
	elseif cx <0 then cx+=.5
	end

	if cy>0 then cy-=.5
	elseif cy <0 then cy+=.5
	end
end

--block functions

function m_collide(x,y,x2,y2)
	m_add (x,y,x2,y2)
	local t=mget(x, y)
	if not scoring then
		--blockboard
		mset(x2, y2, t)
		else
		mset(x2, y2, t-16)
	end
	--draw board
	mset(x, y, mget(x,y+draw_board_offset))
	if (not hasmoved) hasmoved = true
end

function m_add (x,y,x2,y2)
	local t=mget(x, y)
	local p={}
	p.x= x*cell_size
	p.y= y*cell_size
	p.ex=x2*cell_size
	p.ey=y2*cell_size
	p.scoring = scoring
	p.t = t
	p.tk = 0
	p.snd = 0
	p.frm = -1

	if p.x == p.ex and p.y == p.ey then

	elseif p.t == skiddy_p or p.t == skiddy_s then
		p.sp = sp
		p.frm = 0
		p.snd = 50
	elseif p.t == ice then p.snd = 51
	elseif p.t == box then p.snd = 52
	end

	if (box_delay>=0) p.delay = box_delay*cell_size
	if on_box and (abs(x2-x)==1 or abs(y2-y)==1) then
		p.snd = 0
		if (p.t == skiddy_p or p.t == skiddy_s) p.frm = 9
	end
	add(m,p)

	local index = l.w*y2+x2
	m_i[index] = #m
end

--frm = -2 no draw, -1 simple sprite, 0-8 animation frame, 9 blink

function m_draw(item,mx,my)
	if item.frm < -1 then
		--don't draw
	elseif item.frm <=0 or item.frm == 9 then
		if item.frm == 9 then
			spr(item.t-blink_offset,mx+item.x,my+item.y)			
		else
			--for blink
			local r = flr(rnd(l.w+1)*2) * cell_size
			local c = flr(rnd(l.h+1)*2) * cell_size

			if item.t < ice and r == item.x and c == item.y then
				spr(item.t-blink_offset,mx+item.x,my+item.y) --draw blink
			else
				spr(item.t,mx+item.x,my+item.y)						
			end
		end
	else
		if item.t==skiddy_s then
			spr(item.sp[item.frm]+s_offset,mx+item.x,my+item.y)
		else
			spr(item.sp[item.frm],mx+item.x,my+item.y)
			--s_print(item.frm,mx+item.x,my+item.y+10,7)
		end
	end	
end

function m_anim()
	local updating = false

	for i in all(m) do
		if i.sp then --have animation
			--printh("have win animation, frame "..i.frm)
			local u = animate(i)
			if (not updating and u) updating=true
		end
	end
	return updating
end

function m_update()
	local updating = false

	for i in all(m) do

		if i.delay and i.delay> 0 then
			i.delay -= spd
			if (i.delay< 0) i.delay = 0
		else

			if i.x < i.ex then
				i.x+=spd
				updating=true
			elseif i.x > i.ex then
				i.x-=spd
				updating=true
			end

			if i.y < i.ey then
				i.y+=spd
				updating=true
			elseif i.y>i.ey then
				i.y-=spd
				updating=true
			end

			if i.y==i.ey and i.x==i.ex then --reached destination
				if i.frm == 9 then i.frm = -1 end
				--do animation
				if i.sp then --animation is set
					local u = animate(i)
					if (not updating and u) updating=true

				end
				--do sound
				if i.snd >0 then
					sfx(i.snd)
					i.snd=0
				end
			end
		end
	end
	return updating
end

function animate(i)
	if i.frm >0 and i.frm < 9 then --advance frames
		i.tk=(i.tk+1)%stp --tick fwd
		if i.tk==0 then
			i.frm=i.frm+1
			if i.frm == #i.sp+1 then
				if i.scoring and i.sp == sp_win then
					i.frm = -2 --set no draw
					return false
				else
					i.frm = -1 --set draw static sprite
					return false
				end
				--updating=false --this is a bug
			end
		end
		return true
	elseif i.frm == 0 then --start animation
		if (i.sp == sp_win) sfx(i.snd)
		i.frm = 1
		return true
	end
	return false
end

function m_count()
	local tots=0
	for x=1,l.w-1 do
		for y=1,l.h-1 do
			if (mget(x,y)==skiddy_p or (mget(x,y)==skiddy_s)) tots+=1
			--if (mget(x,y)==skiddy_p-16 or (mget(x,y)==skiddy_s-16)) tots+=1
		end
	end
	return tots
end

function do_score(t,x,y)
	if t == goal_p and mget(x,y) == skiddy_p then
		if (not hasmoved) hasmoved = true
		return true
	elseif t == goal_s and mget(x,y) == skiddy_s then
		if (not hasmoved) hasmoved = true
		return true
	end
	return false
end

function do_row(dx,sx,x,y)
	for x2 = x-dx, sx-dx-1/dx, -dx do

			local t=mget(x2,y)
			scoring = do_score(t,x,y)

			if fget(t,1) or fget(t,0) then --t<mov) then
				if dx*(x2+dx-x)<0 then
					m_collide(x,y,x2+dx,y)
				else
					m_add (x,y,x,y)
					if scoring then
						mset(x, y, mget(x,y)-16)
					end
				end
				break
			elseif fget(t,2) then --(t<=pit) then
				m_collide(x, y, x2, y)
				break
			end
			--scoring = false
	end
	scoring = false
end

function do_col(dy,sy,x,y)
	for y2 = y-dy, sy-dy-1/dy, -dy do

			local t=mget(x,y2)
			scoring = do_score(t,x,y)

			if fget(t,1) or fget(t,0) then --t<mov) then
				if dy*(y2+dy-y)<0 then
					m_collide(x,y,x,y2+dy)
				else
					m_add (x,y,x,y)
					if scoring then
						mset(x, y, mget(x,y)-16)
					end
				end
				break
			elseif fget(t,2) then --(t<=pit) then
				m_collide(x, y, x, y2)
				break
			end
			--scoring = false
	end
	scoring = false
end

function do_check_h(step, en, x, y)
	local gap = false
	--local i = x + step
	for i = x + step, en + 1/step, step do
	--while step * (i - en) <= 0 do
		target = mget(i, y)

		if fget(target) == 0 then --(target > pit) then
			gap = true
		elseif fget(target) == 3 then
			if gap then
				break
			else
				if box_delay<0 then
					box_delay = 1
				else
					box_delay += 1
				end
			end
		elseif fget(target,0) or fget(target,2) then --target == pit then
			break
		else
			if box_delay == -1 then
				box_delay = abs(x - i) - 1
			else
				box_delay = abs(x - i) - 1 - box_delay
			end
			return true
		end
		--i += step
	end
	return false
end

function do_check_v(step, en, x, y)
	local gap = false
	--local i = y + step
	for i = y + step, en + 1/step, step do
	--while step * (i - en) <= 0 do
		target = mget(x, i)

		if fget(target) == 0 then --(target > pit) then
			gap = true
		elseif fget(target) == 3 then
			if gap then
				break
			else
				if box_delay<0 then
					box_delay = 1
				else
					box_delay += 1
				end
			end
		elseif fget(target,0) or fget(target,2) then --target == pit then
			break
		else
			if box_delay == -1 then
				box_delay = abs(y - i) - 1
			else
				box_delay = abs(y - i) - 1 - box_delay
			end
			return true
		end
		--i += step
	end
	return false
end

function do_box(dx, dy, ex, ey, x, y, x2, y2)
	if dy == 0 then
		x2 = x - dx
	else
		y2 = y - dy
	end

	--local b = mget(x, y)
	local t = mget(x2, y2)

	if not fget(t,0) and not fget(t,1) then --(t>=pit) then
		local cm = false
		box_delay = -1

		if dy == 0 then
			cm = do_check_h(dx, ex, x, y2)
		else
			cm = do_check_v(dy, ey, x2, y)
		end

		if cm then
			m_collide(x, y, x2, y2)
			on_box = true
		else
			m_add (x,y,x,y)

		end
	else
		m_add(x,y,x,y)
	end
	box_delay = -1
end

--globals
tots = 0 --total skiddies in play
rst_timer = 0 --timer for hold button
map_timer = 0 --timer for map button
box_delay = -1 --squares to reach the last moveable pushing a box
pdata = {} --64 numbers for saving
music_on = true
tut_step = 1
s_lv=1
--constants
pass_mask = 0x0000.0001
mm_mask = 0x0000.0002
cm_mask = 0x0000.0004
perf_mask = 0x0000.0008
clear_mask = 0x0000.000F

colors = {12,12,6} --colors for perfect bg
combos = {[300]=2, [500]=3, [700]=4}

draw_board_offset = 8
sky_size = 16
cell_size = 8
spd = 2
rst_delay = 30

margin = 6
lbl_crd = "by big bang pixel"
lbl_tag = "the slippery puzzle"
lbl_clr = "clear data"
lbl_btm = "back to map"
lbl_mus = "music toggle"
lbl_rst = "restart level"
lbl_mov = "10 moves left"
lbl_cmb = "max combo"
lbl_prf = "perfect!"
lbl_tlv = "tutorial"
lbl_lev = "level "
lbl_mxx = "moves "
lbl_mdl = "medals "
lbl_tot = "tot "
lbl_wrl = "world "
lbl_cmp = " completed"
lbl_fld = " failed"
lbl_nxt = "Ž next"
lbl_map = "— map"
lbl_rxt = "Ž restart"
lbl_ttl = "— title"
lbl_tut = "— tutorial"
lbl_ply = "Ž play"
lbl_rtx = "— retry"
lbl_rto = "Ž retry"
lbl_cgr = "congratulations!"
lbl_end = " you completed skiddy\nand got all the medals"

lbl_cl1 = "this will erase your progress!"
lbl_cl2 = "hold — to confirm erasing"
lbl_cl3 = "press Ž to resume playing"

tut_txt = { "help skiddies to exit\n\neach level",
			"move them around\n\nin any of the 4 directions",
			"they slide together\n\nuntil they hit an obstacle",
			"you cannot stop or change\n\ndirection while moving",
			"a skiddy will exit\n\nwith the ones around him",			
			"you cleared the level using\n\nas few moves as possible",
			"all the skiddies reached\n\na goal in the same move",
			"you got the max combo\n\nwithin the minimum moves",
			"can you get all 330 medals?"}

--multipliers
m1 = 100
m2 = 300
m3 = 500
m4 = 700

--blocks sprite
goal_p = 6
goal_s = 38
s_offset = 16
blink_offset = 32
skiddy_p = 41
skiddy_s = 42
ice = 43
box = 44
pit = 45

--clouds
clouds = {} 	
c_speed = 30	
c_max_r = 7
c_min_r = 2
c_sx = 1
parts = 6

--animation frames
sp_up = {64,65,65,64}
sp_dn = {66,67,67,66}
sp_lf = {68,69,69,68}
sp_rt = {70,71,71,70}
sp_win = {72,73,74,75}

l_icons = {	{skiddy_p}, {pit}, {box}, {ice-16},
			{skiddy_p,skiddy_s}, {skiddy_p,skiddy_s,pit}, {skiddy_p,skiddy_s,box}, {skiddy_p,skiddy_s,ice-16},
			{skiddy_p,pit,box}, {skiddy_p,pit,ice-16}, {skiddy_p,box,ice-16} }

tut_l = "7645pJbQpVp"			
		
lev = {--"8529pBcDcKcLfMgRfAp",
	"5426p8pGp",
	"553BpEpHpIb",
	"5535p7b9pGpIp",
	"6649pApFbGbLpMpXp",
	"7552p8bCpHpMpQbWp",
	"5676b9pBbGpHbLp",
	"6657b8p9bAbCpFbGbMpPpSbXp",
	"6577b8p9bBpEpFpIpKbLpMb",
	"6657b9pCpEpFbGpLpPbSbXp",
	"7667p9bApBbDpMbQbUpVbWp",

	"7443pGpHfIp",
	"6558p9pEbFbIpKfLfNp",
	"5536pApCfGbIpMp",
	"754BbCpEpHfKpMpNb",
	"7543p8b9bCpGpHfIpMpPbQbVp",
	"7579pBpFpGbHbIbJpOfVp",
	"7553p8p9bBbCpHfMbNpPpQb",
	"5666pBpCbGpIfJpLpMb",
	"6651p4p7fAfEbFbJpMpPbQpRpSb",
	"666EbFpJpLbOpPfQpVp",

	"5567pCpHcMp",
	"5546b9pBpCcDpFpIb",
	"6443p7p8bApFcKp",
	"5542p6p8pCcGbHpIb",
	"6566p9pAbDbEcGbJpKcLpMpQp",
	"7555pBpFbGpHcIpJbNpTp",
	"7553p8bBcCpFpJbMbPcQpVp",
	"6452p9cApDpEcLp",
	"667ApDcEpIpKbLpRcWp",
	"6649bCpDcFpKpMcNpQb",

	"5442p6p7gBbDp",
	"7441p5p9pAgBpFbJb",
	"6453p8gApDpEgGb",
	"5542p6p7gBbDbHgIp",
	"5643p7pBbDgHpLbNg",
	"5661p7b8bBgCpHpIgLbMbSp",
	"6686p7g8b9bAgBpJbMbPbQpRpSb",
	"6544p7bAgBpDpEpFpGpIpJgMbPp",
	"7562pBbCpFgJgMpNbWp",
	"756ApEpFgHbIpJbOp",

	"5545s7s8pCbGsHpJp",
	"5541p3p5s9sBsDsGbHpIb",
	"6541s4p8pBsDsGsIsLpPpSs",
	"6556sBsDpEpFpGpIpKsLsNp",
	"5531s3s5p7s9pCpGpHsIp",
	"5563s6pBsEpGbHpIs",
	"6551s4pCpEpFsHsJbKsLpMb",
	"6572s6p8p9bApJsKbLsNsRp",
	"7788pAbFbHsLpPpQbZsdbeshpjs",
	"7795s8bDsEpGsIbNbOpSpUbVbWsebipkp",

	"5541s7p8sCbDpFpGfJsLp",
	"7442s4p7pAsBfCpFsGfHpKsNsPp",
	"5555p7s9pBpCfDpLsNs",
	"7555p9sBsEpGfIfKsNpPpTs",
	"7472s5p7s9fApCfDpFbGpIbJs",
	"6667p9fBpDbEbFsGbJsLfNsPbQbRpSb",
	"6581p4s8s9pEpFsIsKfLfNp",
	"7681s3pAfBbCbFpHsIbJbMbNbOpQsTbUbVfcsep",
	"7573p8pCsEpFfHbJfKsNsPpVs",
	"6676s9pDfEbFsGsKbLbOpRfVsYp",

	"5562p6p7c8pAsEsHs",
	"5572s6s7c8sGpIpMp",
	"6541p3s8s9cCsEpFsHpKcLpQpSs",
	"6576p8s9sBpEpFpIsKcLcNs",
	"5551s7pApBcCpDsHcJpMs",
	"7442s4p8sAcCpHpNpPs",
	"5542s6s8pAsCcEpGpIbMp",
	"7441p4sApBcCsFpGcHsNpQs",
	"7453p7p9sBpDsGpHcIsMsQp",
	"5661s3s7pBpCcDpKpMsOp",

	"5463s5p7s8g9pBsCpDp",
	"5562p6s8pApCgEsGpIbMs",
	"5596s7b8sAsEsGpHgIpMp",
	"7552s4sAbEpKpMpNgOsPgQp",
	"5585s7b9sBpCsDpHgMp",
	"5662p6p8sApBgDbGsIpKsLgNbRs",
	"6651s9bApCpDgEsHpLbMpOpPgQsTpVs",
	"7572s4sAsEpGbIbKpMpOgQp",
	"7473s8p9bBsCbFsHgIpNpQs",
	"6686s8b9sAbFpGpIpJgKbMbQgWsYp",

	"7453p8b9bAfBbCbFpHcJpNpPp",
	"6523p7p8p9fDcGcKfLpMpQp",
	"7458p9cHfIcJpOp",
	"4655p9fAcBpDcHp",
	"664ApCpEfFpGcJcKpLfNpPp",
	"6639cApCpDfFbGcJpPbQpRfXp",
	"6552p7p9cApEfFfJpKcMpRp",
	"7468pAfCpGpHcIpOp",
	"7549pAbDpFpGfHcIfJpLpObPp",
	"6678f9pCpDcFbGpMfPpRcXp",

	"5457p8pCfDgHp",
	"5527g8pApBfCpDfEpGpHg",
	"4687p9pAgDfEgHpIb",
	"5577pCfDpFpGgLp",
	"5666p8pBfDfGgHpIgKpMbOp",
	"7473p9bAfBbFgGpHpIpJg",
	"7572p8gAbCpGfIfMpObQgWp",
	"6666p8b9bDfEpGgJgLpMfQbRbTp",
	"6561p7g8p9fDbGbKfLpMgSp",
	"6669pAbEgGpKfLgOpVp",

	"5462p7cBpCgDp",
	"5532p6p7cCpDcEpFpGgIpLp",
	"5632p6p8pFpHcJpLgMpNg",
	"6652p7p8gDcIpKbMgNpRcSpWp",
	"7552p5p8pAcFbHgJbOcQpTpWp",
	"6542p7g8c9pApCpHpJpKpLcMgRp",
	"6643p7b9cCpFpGcHpJgPpQgSbXp",
	"5676b7g9pCpDcGcHpKpMgNb",
	"6658p9cCpFbGcJgMpOpQgVpXp",
	"5673p6b7gBpCcEpGbHgLpMcOpSp"
}

med_lvl = 3*10
med_tot = 3*#lev
__gfx__
00000000a9a999999999999999999999d5d5d5d5a9a99999444444442eaeaeae0000000008888880099999902800008200000000000000000000000000999900
000000009555555555555555555555595ddddddd9555555948888884eeeeeeea0000000088888888999999990280082000448888888844000000000009a79a90
00700700a53b3b33b33b3b33b33b3b39ddddddd5a53b3b39488888842eeeeeee000000008888888899999999002882000488888888888840000000009a7a79a9
0007700095b3b33b33b3b33b33b3b3395ddddddd95b3b33948844884eeeeeeea000000008228822894499449000880000488888888888840000000009aa7a799
00077000953b3b33b33b3b33b33b3b39ddddddd5953b3b39488448842eeeeeee00000000888888889999999900822800488e77e88e77e8840000000099aa7a79
0070070095b3b33b33b3b33b33b3b3395ddddddd95b3b33948888884eeeeeeea000000008888888899999999082002804887117887117884000000009a9aa7a9
0000000095333333b3333333b3333339ddddddd595333339488888842eeeeeee0000000028888882499999948200002828875578875578820000000009a9aa90
00000000953b3b3b3b3b3b3b3b3b3b395d5d5d5d953b3b3944444444e2e2e2e200000000022222200444444020000002488e88e88e88e8840000000000999900
95b3b3b995b3b3b399999999b3b3b3b9a9a99999b3b3b3b39999999900000000000000000eeeeee00aaaaaa0777c7c5528888888888888820000000000555500
953333399533333b9555555933333339955555553333333b555555590000000000000000ee7ee7eeaa7aa7aa76cc66c528888888888888820000000005675650
953b3b39953b3b33953b3b39b33b3b39a53b3b33b33b3b33b33b3b390000000000000000e717717ea717717a7c6cc76524888888888888420000000056767565
95b3b33995b3b33b95b3b33933b3b33995b3b33b33b3b33b33b3b3390000000000000000e717717ea717717accc7cc6328888888888888820000000056676755
953b3b39953b3b33953b3b39b33b3b39953b3b33b33b3b33b33b3b390000000000000000eeeeeeeeaaaaaaaa76cc7cc324888888888888420000000055667675
95b3b33995b3b33b95b3b33933b3b33995b3b33b33b3b33b33b3b3390000000000000000eeeeeeeeaaaaaaaac67cc6c524488888888884420000000056566765
953333399533333395333339b333333995333333b3333333b333333900000000000000002eeeeee24aaaaaa45c66cc6502444444444444200000000005656650
953b3b39953b3b3b999999993b3b3b39999999993b3b3b3b99999999000000000000000002222220044444405553355300222222222222000000000000555500
9999999995b3b3b3b3b3b3b3b3b3b3b96d6d6d6d95b3b3b94444444452d2d2d200000000088888800999999077c7ccc344949444155555550000000000444400
555555559533333b3333333b33333339d6666666953333394cccccc42222222d00000000887887889979979976cc66cc442222425111111500000000049e4940
b33b3b33953b3b33b33b3b33b33b3b396666666d953b3b394cccccc452222222000000008717717897177179cc6cc7639244442251111115000000004999e4e4
33b3b33b95b3b33b33b3b33b33b3b339d666666695b3b3394cc44cc42222222d0000000087177178971771797cc7cc6c4422224251111115000000004e999e44
b33b3b33953b3b33b33b3b33b33b3b396666666d953b3b394cc44cc452222222000000008888888899999999c6cc7cc392444422511111150000000044e999e4
33b3b33b95b3b33b33b3b33b33b3b339d666666695b3b3394cccccc42222222d000000008888888899999999c67cc6cc4422224251111115000000004e4e9994
b333333395333333b3333333b33333396666666d953333394cccccc452222222000000002888888249999994cc66cc634244442251111115000000000494e940
99999999999999999999999999999999d6d6d6d69999999944444444252525250000000002222220044444403c3c3c3c22222222555555510000000000444400
ddddddddcdddcdddcdcdcdcdcdcdcdcdcccdcccdcccccccccccccccc6ccc6ccc6c6c6c6c6c6c6c6c666c666c0000000000000000000000000000000000111100
dddddddddddddddddddcdddcdcdcdcdcdcdcdcdcccccccccccccccccccccccccccc6ccc6c6c6c6c6c6c6c6c60000000000000000000000000000000001505010
ddcdddcdcdcdcdcdcdcdcdcdcdcccdcccccccccccccccccccc6ccc6c6c6c6c6c6c6c6c6c6c666c66666666660000000000000000000000000000000015000001
dddddddddddddddddcdddcdddcdcdcdcdcdcdcdcccccccccccccccccccccccccc6ccc6ccc6c6c6c6c6c6c6c60000000000000000000000000000000010000001
cdddcdddcdcdcdcdcdcdcdcdcccdcccdcccccccccccccccc6ccc6ccc6c6c6c6c6c6c6c6c666c666c666666660000000000000000000000000000000015000001
dddddddddddcdddcdcdcdcdcdcdcdcdcdcccdcccccccccccccccccccccc6ccc6c6c6c6c6c6c6c6c6c666c6660000000000000000000000000000000010000001
cdcdcdcdcdcdcdcdcdcdcdcdcccccccccccccccccccccccc6c6c6c6c6c6c6c6c6c6c6c6c66666666666666660000000000000000000000000000000001000010
dddddddddcdddcdddcdcdcdcdcdcdcdcccdcccdcccccccccccccccccc6ccc6ccc6c6c6c6c6c6c6c666c666c60000000000000000000000000000000000111100
02888820028888200888888002888820088888800888882008888880028888800028820000000000000000000000000000000000000000000000000000000000
88788788287887822888888228888882878878887887888288878878288878870288882000288200000220000000000000000000000000000000000000000000
87177178871771788878878888888888717717881771788288717717288717712878878202888820002882000002200000000000000000000000000000000000
87188178888888888717717888788788717717881771788288717717288717718717717808177180028228200028820000000000000000000000000000000000
88888888888888888717717887177178888888888888888288888888288888882888888208888880028888200028820000000000000000000000000000000000
88888888288888828888888888888888888888888888888288888888288888882888888202888820002882000002200000000000000000000000000000000000
28888882222222222888888228888882288888822888882228888882228888820288882000288200000220000000000000000000000000000000000000000000
02222220022222200222222002222220022222200222222002222220022222200022220000000000000000000000000000000000000000000000000000000000
04999940049999400999999004999940099999900999994009999990049999900049940000000000000000000000000000000000000000000000000000000000
99799799497997944999999449999994979979997997999499979979499979970499994000499400000440000000000000000000000000000000000000000000
97177179971771799979979999999999717717991771799499717717499717714979979404999940004994000004400000000000000000000000000000000000
97199179999999999717717999799799717717991771799499717717499717719717717909177190049449400049940000000000000000000000000000000000
99999999999999999717717997177179999999999999999499999999499999994999999409999990049999400049940000000000000000000000000000000000
99999999499999949999999999999999999999999999999499999999499999994999999404999940004994000004400000000000000000000000000000000000
49999994444444444999999449999994499999944999994449999994449999940499994000499400000440000000000000000000000000000000000000000000
04444440044444400444444004444440044444400444444004444440044444400044440000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000077600677280000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077760000776000000000006711567511028008200000000000000000000000000000000000000000000000000000000000000000
00000067777777777777777761176006567600000000067611111111002882000000000000000000000000000000000000000000000000000000000000000000
00000671111111111111111111111661111560000000675122111111000880000000000000000000000000000000000000000000000000000000000000000000
00006711111111111111111111111111a91156000006751188211111008228000000000000000000000000000000000000000000000000000000000000000000
000671144999afaa9942111a9841111f99911700000751118882111e082002800000000000000000000000000000000000000000000000000000000000000000
000771499999999999942119998211faeee116600007111288821114820000280000000000000000000000000000000000000000000000000000000000000000
000764999999999999942119998219a9e88115605676111288211114200000020000000000000000000000000000000000000000000000000000000000000000
00079999111111111111111598119a99882660006765111288811156280000820000000000000000000000000000000000000000000000000000000000000000
000799a411111111111111118819a99e821700001111111288811111028008200000000000000000000000000000000000000000000000000000000000000000
006799a2111111111111111198fa99e2215600001111111288811111002882000000000000000000000000000000000000000000000000000000000000000000
0076999e222222222111111288e9ee8815600000ee9a99ee88811112000880000000000000000000000000000000000000000000000000000000000000000000
007599e8888888888211112888888888660000008888888888811128008228000000000000000000000000000000000000000000000000000000000000000000
00759e88888888888821118888888888000000008888888888811188082002800000000000000000000000000000000000000000000000000000000000000000
00758222222222228881118888222222000000001212821218811188820000280000000000000000000000000000000000000000000000000000000000000000
00751111111111118881118888211111000000002822822828811188200000020000000000000000000000000000000000000000000000000000000000000000
00675111000067518881118811111111111111118888888828821600111111280000000000000000000000000000000000000000000000000000000000000000
00067651000006718881118822111111222222228888888828821700222222880000000000000000000000000000000000000000000000000000000000000000
00675111000000728881118888211112888888888888888828825600888888880000000000000000000000000000000000000000000000000000000000000000
00761222000000718881118888211112888888888888888888827000888888810000000000000000000000000000000000000000000000000000000000000000
00752888000000658881118811111111111111118888888888827000111111110000000000000000000000000000000000000000000000000000000000000000
00752888000000068821112815677765511111118888888888827000111111560000000000000000000000000000000000000000000000000000000000000000
00671222000000002211111277600006677777772222222288817000777777600000000000000000000000000000000000000000000000000000000000000000
00061111000000001111111100000000000000001111111188217000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010100018100000202010101000001010101010101000082820201010000010101010001810000020202030400000000000000000000000000000000000000000000000000000202020000000000000000000000000002020200000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
07272d0000000000300000000000000000000000000000008081828383848584858400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
242b290000000000310000000000000000000000000000009091929392929596959686840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
042c2a000000000032000000000000000000000000000000a091a2a2a2a2a5a2a5a291a60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000033000000000000000000000000000000a1a3a3a3a4a3a4a3a4a4a7940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000300150050222515297172b71529014297123501500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000000000000071320000004132000000005100050000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c20000000000001c2051c20000000000000000000000000000000000000000000000000000000000c21400000132141c205182141c20200000000000000000000051051e2001c2041c2020000000000
011000000c20400000132041c2051820404000091000910000000040000910017400174001740000000000001821400000132141c2050c2140000000000000002760024600000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b2201c2201c2221c215000000000000603051051b2201c2201c212051051e2201c2201c212001051b2201c2201c2221c215000000000000105001051c2201b2201b212001051a220192201921205105
011000001822017222172221721500105000000000000000152201722017212051051922017220172120010515220172221722217215001050010502105000001732217210001051732217210152221521005105
011000000000014332142100210500000123221221005105000000210000000000000000005105051050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001132211210051001132211210133221321005105153221522215225000000510005101051030710311322112100510511322112101332213210051001532215222152250510300000000000510100000
010e00000c3220c210000000c3220c2100e3220e210000000c3220c2220c22500000000000000000000000000c3220c210000000c3220c2100e3220e210000000c3220c2220c22500000000000c3000000000000
010e00001332213210000001332213210153221521000000173221722217225000000000000000000000000013300132000000013300132001730017200000000000000000000000000000000000000000000000
011000001732217210001051732217210152221521005105001001433214210001050010512322122100010500000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000061300000001250000024603246030512500000006130000005125000000061300000001250000000613000000000000000186132460300000000000061300000001250000000613000000512500000
01100000006130c603001250510500000000000512500000000000000000125001050512105120051250510505115006030000000000005130000000603000000012500105051210512005125051000512500000
011000000061300000001250000000000000000512500000000000000005125000000000000000051250000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000005130c603001250510500000000000512500000000000000000125001050012100120001250510500125006030000000000006130000000000000000012500105001210012000125051000012500000
011000000061300000001250000000000000000512500000000000000000125000000000000000051250000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c7340e7401174014740167401776018760187601777015770147701277011770107600e7600c7600b7500a7500975008750087500775007740067400674006720057200472004720047200472004725
000100003235032351393503935330350303000130030300033000430004300043000430003300033000330003300033000230001300013000130001300013000000000000000000000000000000000000000000
000400001563015631156301463001600036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000026410264102d4102d41024413000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000120141b01021010220102202021020200301e0301c0401a05016050120500f0500d0500c0500a04008030060300503003020010100001000000000000000000000000000000000000000000000000005
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 28 44
00 05 1e 28 44
00 04 42 2a 44
00 41 1f 28 44
00 05 1e 28 44
00 41 1f 29 44
00 41 1e 2b 44
00 41 42 29 44
02 04 42 2a 44
00 41 42 43 44
00 41 42 43 44
00 04 42 2c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
